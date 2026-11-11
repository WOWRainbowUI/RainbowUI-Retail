# Integration Guide

This guide explains how to embed LibBabble-SubZone-3.0 in an addon, how it behaves when several addons embed it, and how to use it efficiently. For the method list, see [API.md](API.md).

## Embedding

### With the CurseForge packager

Add the library as an external in your `.pkgmeta`. Either repository works; both hold the same files.

From GitHub:

```yaml
externals:
  Libs/LibBabble-SubZone-3.0:
    url: https://github.com/arithmandar/LibBabble-SubZone-3.0
```

From WoWAce SVN, using the latest release tag:

```yaml
externals:
  Libs/LibBabble-SubZone-3.0:
    url: https://repos.wowace.com/wow/libbabble-subzone-3-0/trunk
    tag: latest
```

Without `tag`, the SVN external uses `trunk`, which follows the GitHub `main` branch and can include changes that are not released yet. With `tag: latest`, it uses the newest release tag. See the CurseForge guide to [preparing the PackageMeta file](https://support.curseforge.com/support/solutions/articles/9000197952-preparing-the-packagemeta-file).

The library needs [LibStub](https://www.curseforge.com/wow/addons/libstub). If your addon does not already embed it, add it too:

```yaml
externals:
  Libs/LibStub:
    url: svn://svn.wowace.com/wow/libstub/mainline/trunk
    tag: latest
```

### Load order

Load LibStub first, then the library's `lib.xml`:

```xml
<Include file="Libs\LibStub\LibStub.lua"/>
<Include file="Libs\LibBabble-SubZone-3.0\lib.xml"/>
```

or, in the TOC:

```text
Libs\LibStub\LibStub.lua
Libs\LibBabble-SubZone-3.0\lib.xml
```

Always load `lib.xml` and never list the individual Lua files. `lib.xml` loads the files in a fixed order:

1. `Core/LibBabble-3.0.lua`: the shared LibBabble-3.0 core.
2. `Core/Core.lua`: registers the library with LibStub.
3. `Data/*.lua`: map data indexes. Each file loads only on its own client.
4. `Locale/*.lua`: the English base table, then the current locale's translations.
5. `Core/Cleanup.lua`: removes the temporary loading key.

Files from step 3 onward find the library through a temporary key in the host addon's private table (the second value of `...`). The key is set in step 2 and removed in step 5, so nothing is left in your addon's namespace. If the files load in a different order, or `Core/Cleanup.lua` is skipped, the data does not load or the key stays behind.

### Standalone installation

The library also installs as its own addon. Its TOC has `## LoadOnDemand: 1`, so it does not load until something requests it.

If your addon supports a standalone installation instead of, or in addition to, an embedded copy, declare it and load it on demand:

```text
## OptionalDeps: LibBabble-SubZone-3.0
```

```lua
local SubZone = LibStub("LibBabble-SubZone-3.0", true)
if not SubZone and C_AddOns and C_AddOns.LoadAddOn then
	C_AddOns.LoadAddOn("LibBabble-SubZone-3.0")
	SubZone = LibStub("LibBabble-SubZone-3.0", true)
end
```

`LibStub(name, true)` returns `nil` instead of raising an error when the library is not loaded.

## Several Embedded Copies

Many addons embed the library, so a client often loads several copies. LibStub keeps a single instance:

- The copy with the highest `MINOR_VERSION` wins. Every copy that loads later with the same or a lower `MINOR_VERSION` stops right after the version check in `Core/Core.lua`. Its data files also skip themselves, so only the winning copy builds the data tables.
- If a newer copy loads after an older one, it upgrades the shared instance in place. Lookup tables you already hold are refreshed with the new data.

What this means for you:

- **Get the library through `LibStub`.** All addons share one instance, so do not keep your own copy of its tables beyond what [Caching](#caching) describes.
- **Embed a recent release.** An older embedded copy is never used when a newer one is present. But if your addon is the only one installed, users get the version you ship.
- **Do not modify the returned tables.** They are shared by every addon that uses the library.

The same rules apply to the bundled LibBabble-3.0 core. This library ships core MINOR `3`, which adds the lookup resolver. It wins over the original MINOR `2` used by other LibBabble libraries, which keep working as before.

## Usage Patterns

### Display a name

```lua
local L = LibStub("LibBabble-SubZone-3.0"):GetLookupTable()

frame.title:SetText(L["The Plagueworks"])
```

### Check before you look up

`GetLookupTable()` warns for keys it does not know. If a key may be missing, for example when it comes from saved data or another addon, check the base table first:

```lua
local SubZone = LibStub("LibBabble-SubZone-3.0")
local base = SubZone:GetBaseLookupTable()
local L = SubZone:GetLookupTable()

local function Localize(englishName)
	if base[englishName] then
		return L[englishName]
	end
	return englishName
end
```

### Map a localized name back to English

Game APIs such as `GetSubZoneText()` and `GetZoneText()` return localized names. To use them as keys, convert them back to English:

```lua
local SubZone = LibStub("LibBabble-SubZone-3.0")
local R = SubZone:GetReverseLookupTable()

local english = R[GetSubZoneText()]
```

Names are not always unique. When several English names share one translation, use `GetReverseIterator()` and choose by context, such as the current map ID:

```lua
for english in SubZone:GetReverseIterator(GetSubZoneText()) do
	-- Pick the entry that matches the current map.
end
```

Reverse lookups use the static translation tables. If the client's name for a place has changed since the data was generated, the reverse lookup may not find it.

### Caching

The library already caches every resolved name in the lookup table, so repeated lookups are plain table reads. Store the lookup table itself in a local; there is no need to build your own cache:

```lua
local L = LibStub("LibBabble-SubZone-3.0"):GetLookupTable()
```

Avoid resolving every key at login. The library knows more than 10,000 names, and the first read of each name may call the client API. Resolve names when you display them.

### Build a combined table

Some addons, such as Atlas, merge names from several sources into one table. Iterate the base table and read each name through `GetLookupTable()` so the client API resolver is used:

```lua
local function GetSubZoneNames()
	local library = LibStub("LibBabble-SubZone-3.0")
	local lookup = library:GetLookupTable()
	local names = {}

	for englishName in pairs(library:GetBaseLookupTable()) do
		names[englishName] = lookup[englishName]
	end

	return names
end
```

This resolves every key at once, so run it only when the table is needed. Do not build it during the loading screen.

## Locales

| Locale file | Client locales |
|---|---|
| `enUS.lua` | enUS, enGB (English base table) |
| `deDE.lua` | deDE |
| `esES.lua` | esES |
| `esMX.lua` | esMX |
| `frFR.lua` | frFR |
| `itIT.lua` | itIT |
| `koKR.lua` | koKR |
| `ptBR.lua` | ptBR |
| `ruRU.lua` | ruRU |
| `zhCN.lua` | zhCN |
| `zhTW.lua` | zhTW |

Only the current locale's file installs translations; the others return right away. An enGB client reports `enUS` from `GetLocale()`.

Some entries keep their English text in another locale. Usually the game uses the English name there as well, or the client data has no translation.

## Known Limitations

- **One translation per key.** The same English name can appear in several game records with different translations, depending on context. The static tables hold one translation per English key. The client API resolver avoids the problem when every candidate ID agrees, and otherwise falls back to the static table.
- **Client data, not curated text.** The names come from client data, including internal, test, and placeholder entries. Addons that list every key should filter what they show.
- **Regenerated data.** Translations are regenerated from client data for each release. Corrections that are not in the client data can be overwritten. When you report one, explain where the name appears so it can be kept.

## Reporting Problems

Open an issue on [GitHub](https://github.com/arithmandar/LibBabble-SubZone-3.0/issues) with:

- the English name and the expected localized name,
- the client (Retail or a Classic flavor), the build, and the locale,
- where the name appears (map, zone, instance), with a screenshot, coordinates, or an area ID if possible, and
- your addon and which lookup method it uses.
