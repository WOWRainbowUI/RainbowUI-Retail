# API Reference

This page describes the public API of LibBabble-SubZone-3.0. For embedding and load order, see [Integration.md](Integration.md).

```lua
local SubZone = LibStub("LibBabble-SubZone-3.0")
```

All lookup keys are English location names exactly as they appear in the client's enUS data, for example `"Dun Morogh"` or `"The Plagueworks"`.

## Lookup Tables

| Method | Returns | Missing key | Uses client API resolver |
|---|---|---|---|
| `GetLookupTable()` | English key → localized name | Warns, then returns the English name | Yes |
| `GetUnstrictLookupTable()` | English key → localized name | `nil`, no warning | No |
| `GetBaseLookupTable()` | English key → English name | `nil`, no warning | No |
| `GetReverseLookupTable()` | Localized name → one English key | `nil`, no warning | No |

Every method returns the same table each time it is called, so you can call it once and keep the result in a local.

### `GetLookupTable()`

Returns the main lookup table. Use it when you want to display a name.

```lua
local L = SubZone:GetLookupTable()
local name = L["Dun Morogh"]
```

The first time a key is read, it is resolved in this order:

1. **Client API, AreaTable:** the generated `AreaNameToIDs` index maps the English name to one or more AreaTable IDs. Each ID is passed to `C_Map.GetAreaInfo`. If every non-empty result is the same, that result is used.
2. **Client API, UiMap:** the same check with the `UiMapNameToIDs` index and `C_Map.GetMapInfo(id).name`.
3. **Legacy area ID:** the single ID from `AreaToID`, passed to `C_Map.GetAreaInfo`.
4. **Static translation:** the current locale's table in `Locale/`.
5. **English fallback:** if the key exists only in the English base table, the lookup reports `Translation "<key>" not found for locale "<locale>"` through the error handler and returns the English name.
6. **Unknown key:** reports `Translation "<key>" not found.` and returns the key itself.

The result is cached in the table, so later reads are plain table lookups and the warning is reported only once per key.

The client API steps return the name that the running game client has for that ID. This keeps names correct for the current patch and locale, even when the static tables are older. If candidate IDs return different names, the resolver skips the API result and uses the static table, so an ambiguous name never picks a random variant.

The client API steps only run when the current client has a generated index (Mainline, Classic Era, Classic Forever, Classic Progression, and Classic TBC). On any other client, the lookup uses the static tables only.

> **Avoid probing with `GetLookupTable()`.** Reading a key that might not exist triggers a warning. Check `GetBaseLookupTable()[name]` first.

### `GetUnstrictLookupTable()`

Returns the raw static translation table for the current locale. It does not use the client API resolver and does not warn.

```lua
local LU = SubZone:GetUnstrictLookupTable()
local name = LU["Dun Morogh"] or "Dun Morogh"
```

On an enUS client, this is the English base table.

### `GetBaseLookupTable()`

Returns the English base table, in which each key maps to itself. Use it to check whether the library knows a name, or to iterate every known key.

```lua
local base = SubZone:GetBaseLookupTable()
if base["Dun Morogh"] then
	-- The library knows this name.
end
```

### `GetReverseLookupTable()`

Returns a table from localized name to English key. It is built from the static translation table, not from client API results.

If several English keys share the same localized name, this table holds only one of them. Use `GetReverseIterator()` to get all of them.

```lua
local R = SubZone:GetReverseLookupTable()
local english = R[GetSubZoneText()]
```

## Iterators

### `Iterate()`

Iterates over the static translation table for the current locale as `englishName, localizedName` pairs.

```lua
for englishName, localizedName in SubZone:Iterate() do
	-- ...
end
```

### `GetReverseIterator(localizedName)`

Iterates over every English key whose static translation equals `localizedName`. The results are cached per value.

```lua
for englishName in SubZone:GetReverseIterator(localizedName) do
	-- ...
end
```

## Client API Helper

### `GetAreaInfo(englishName)`

Returns the localized name that the running client provides for an English name, or `nil`.

```lua
local name = SubZone:GetAreaInfo("Dun Morogh")
```

It uses the same AreaTable, UiMap, and legacy ID steps as `GetLookupTable()`, but it never falls back to the static tables. It returns `nil` when:

- the argument is `nil`,
- the name is not in the current client's indexes,
- the client has no name for the ID, or
- the candidate IDs return different names.

One difference from `GetLookupTable()`: if the name has AreaTable candidates, `GetAreaInfo()` uses only those. When they disagree or return nothing, it returns `nil` without trying UiMap.

Use it when you specifically want the client's own name and want to handle missing names yourself.

## Map Data

`SubZone.MapData` holds the generated indexes for the current client. Only one copy of the library builds it, even when many addons embed the library.

| Field | Type | Description |
|---|---|---|
| `AreaToID` | `name → id` | Legacy map: the lowest AreaTable ID for each English name |
| `AreaNameToIDs` | `name → { id, ... }` | Every AreaTable ID with this English name |
| `UiMapNameToIDs` | `name → { id, ... }` | Every UiMap ID with this English name |

These tables are read-only data for the resolver. The layout can change between releases, so prefer `GetLookupTable()` or `GetAreaInfo()` to reading them directly.

## Internal Methods

These methods are used by the library's own data files. Addons should not call them. Calling them from an addon would change the shared tables for every addon that uses the library.

- `SetBaseTranslations(table)`
- `SetCurrentTranslations(table or true)`
- `SetLookupResolver(function)`

## Library Versions

| Library | MAJOR | MINOR |
|---|---|---|
| LibBabble-SubZone-3.0 | `"LibBabble-SubZone-3.0"` | `100301` (12.1-release4) |
| LibBabble-3.0 core | `"LibBabble-3.0"` | `3` |

The bundled LibBabble-3.0 core adds `SetLookupResolver()` and the resolver step in `GetLookupTable()`. Its MINOR is higher than the original LibBabble-3.0 (`2`), so LibStub uses this version even when another LibBabble library loads the older core first. Libraries that do not register a resolver keep the original behavior.
