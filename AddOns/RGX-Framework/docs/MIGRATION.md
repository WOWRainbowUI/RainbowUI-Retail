# Migrating to RGX-Framework

Guide for addon authors moving from Ace3, LibSharedMedia, or standalone implementations to RGX-Framework.

---

## From Ace3

### Addon Object / Lifecycle

| Ace3 | RGX |
|---|---|
| `LibStub("AceAddon-3.0"):NewAddon(...)` | `local RGX = assert(_G.RGXFramework, "Addon: RGX not loaded")` |
| `:OnInitialize()` | `RGX:OnReady(function() ... end)` |
| `:OnEnable()` / `:OnDisable()` | `RGX:RegisterEvent("PLAYER_LOGIN", fn)` / manual cleanup |
| Embedding mixins | `RGX:Mixin(target, source)` |

RGX does not use `LibStub` or embedding. Your addon is a plain Lua table — no framework base class required.

### Events

| Ace3 | RGX |
|---|---|
| `self:RegisterEvent("EVENT", handler)` | `RGX:RegisterEvent("EVENT", handler, id)` |
| `self:UnregisterEvent("EVENT")` | `RGX:UnregisterEvent("EVENT", id)` |
| `self:RegisterMessage("MSG", handler)` | `RGX:RegisterMessage("MSG", handler, id)` |

RGX requires an `id` string for targeted unregistration. This is a deliberate choice — it makes cleanup explicit and avoids the "which addon leaked this handler?" problem.

### Timers

| Ace3 | RGX |
|---|---|
| `self:ScheduleTimer(fn, delay)` | `RGX:After(delay, fn)` |
| `self:ScheduleRepeatingTimer(fn, interval)` | `RGX:Every(interval, fn)` |
| `self:CancelTimer(timer)` | `RGX:CancelTimer(timer)` |

RGX timers use a native `OnUpdate` driver — no `C_Timer` dependency. The `Every` callback receives the timer reference as its first argument for self-cancellation.

### Hooks

| Ace3 | RGX |
|---|---|
| `self:Hook(target, "Method", handler)` | `RGX:Hook(target, "Method", handler)` |
| `self:Unhook(target, "Method")` | Not supported — RGX uses `hooksecurefunc` (unhookable) |

RGX hooks are post-only and permanent. If you need pre-hooks or unhooking, use your own wrapper.

### Slash Commands

| Ace3 | RGX |
|---|---|
| `self:RegisterChatCommand("cmd", handler)` | `RGX:RegisterSlashCommand("cmd", handler, id)` |

### Saved Variables

| Ace3 | RGX |
|---|---|
| `LibStub("AceDB-3.0"):New("MyAddonDB", defaults)` | `RGX:DB("MyAddonDB", defaults)` (basic) |
| Profiles, namespaces, char/realm scopes | Not yet available — see roadmap |

RGX's current DB is simpler than AceDB. Profile support is planned (see [docs/ROADMAP.md](ROADMAP.md)).

---

## From LibSharedMedia

### Font Registration

| LSM | RGX |
|---|---|
| `LSM:Register("font", name, path)` | `Fonts:Register(name, path, info)` |
| `LSM:Fetch("font", name)` | `Fonts:GetPath(name)` |
| `LSM:List("font")` | `Fonts:ListAvailable()` |

RGX fonts carry richer metadata (family, category, license) and are grouped automatically in dropdowns by category then family.

### Texture Registration

| LSM | RGX |
|---|---|
| `LSM:Register("statusbar", name, path)` | `Textures:RegisterBar(name, path, opts)` |
| `LSM:Fetch("statusbar", name)` | `Textures:GetBar(name)` |
| `LSM:List("statusbar")` | `Textures:ListBars()` |

### Import LSM into RGX

```lua
local Textures = RGX:GetTextures()
Textures:ImportLibSharedMedia()
```

This pulls all registered LSM statusbar textures into the RGX registry. Fonts and sounds from LSM can be registered manually or via `RegisterAddonFont` / `RegisterFontPack`.

---

## From Manual Font Management

### Inline Font Application

**Before:**

```lua
local fontPath = "Interface\\AddOns\\MyAddon\\media\\fonts\\MyFont.ttf"
myFontString:SetFont(fontPath, 14, "OUTLINE")
```

**After:**

```lua
local Fonts = RGX:GetFonts()
Fonts:Apply(myFontString, "Inter-Regular", 14, "OUTLINE")
-- or
Fonts:Quick(myFontString, "Inter-Regular", 14, "OUTLINE") -- nil-safe
```

### Font Dropdown

**Before (manual UIDropDownMenu):** 50+ lines of initialization, item creation, event wiring.

**After:**

```lua
local Fonts = RGX:GetFonts()
Fonts:AttachFontSelector(parent, db, "fontFamily", { label = "Font" })
```

### Style Objects

**Before:**

```lua
db.titleFont = "Inter-Regular"
db.titleSize = 14
db.titleFlags = "OUTLINE"
-- apply each separately
myLabel:SetFont(Fonts:GetPath(db.titleFont), db.titleSize, db.titleFlags)
```

**After:**

```lua
Fonts:AttachStyleSelector(parent, db, "titleText")
-- db.titleText is now a style table: { font, size, flags }
Fonts:ApplyStyle(myLabel, db.titleText)
```

---

## From PetBuddy2's Media System

### Font Registration

**PB2 before:**

```lua
addon:RegisterMedia("font", "Roboto", "Interface/AddOns/PetBuddy2/media/fonts/Roboto.ttf")
local path = addon:FetchMedia("font", selectedFont)
```

**With RGX:**

```lua
local Fonts = RGX:GetFonts()
local path = Fonts:GetPath(selectedFont)
```

No per-addon font registration needed — RGX fonts are already available.

### Context Menu Fonts

**PB2 before:** Build font items manually for UIDropDownMenu context menus.

**With RGX:**

```lua
local fontItems = Fonts:CreateFontMenuItems({
    current = db.fontFamily,
    onSelect = function(name)
        db.fontFamily = name
        addon:RefreshFonts()
    end,
})
-- dual-schema: func (PB2) + onClick (RGX), menuList (PB2) + children (RGX)
```

### Saved Variables

PB2's saved variable keys are preserved:

- `fontFamily` — font name string
- `killFontFamily` — font name string
- `lootFontFamily` — font name string
- `percentFontFamily` — font name string

These can be read by `Fonts:ResolveName(db.fontFamily)` which handles both name and path values.

---

## From BLU's Systems

**Note:** BLU is not yet migrated. This section is future reference.

| BLU System | RGX Equivalent |
|---|---|
| `core/systems/database.lua` | `RGX:DB(name, defaults)` (basic); full profile system planned |
| `core/sharedmedia.lua` | `RGXSharedMedia` (dormant) + `Textures:ImportLibSharedMedia()` |
| `core/events.lua` | `RGX:RegisterEvent` / `RGX:RegisterMessage` |
| `core/runtime.lua` | `RGX:After` / `RGX:Every` / `RGX:Hook` |

---

## Checklist

When migrating an addon to RGX-Framework:

1. Add `## RequiredDeps: RGX-Framework` to your TOC
2. Add `local RGX = assert(_G.RGXFramework, "AddonName: RGX-Framework not loaded")` at the top of each file that uses RGX
3. Replace `C_Timer.After` with `RGX:After`
4. Replace manual `CreateFrame("Frame")` event frames with `RGX:RegisterEvent`
5. Replace `SLASH_X1 = ...` patterns with `RGX:RegisterSlashCommand`
6. Replace manual font path strings with `Fonts:GetPath(name)`
7. Replace manual font dropdowns with `Fonts:CreateFontDropdown` or `Fonts:AttachFontSelector`
8. Replace hardcoded RGB values with `Colors:Get(name)` / `Colors:Wrap(text, name)`
9. Wrap module-dependent init code in `RGX:OnReady(function() ... end)`
10. Remove any embedded copies of Ace3/LibSharedMedia if no longer needed
