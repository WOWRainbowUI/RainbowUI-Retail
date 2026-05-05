# RGX Fonts System

Complete documentation for the font registry, blocked fonts, dropdown schemas, style objects, and all font controls.

---

## Overview

The Fonts module (`RGXFonts`) provides:

- A **font registry** with named entries, metadata, and availability checks
- A **blocklist** of 10 in-tree fonts with corrupted assets (not selectable; 36 bundled + 8 WoW defaults = ~44 total, 10 blocked, ~34 available)
- **Style objects** — normalized tables describing a complete text appearance
- **Apply helpers** — one-call font application to FontStrings and frame trees
- **Dropdown schemas** — dual-schema menu items for both RGX and legacy PB2 consumers
- **UI controls** — font dropdown, font setting control, style selector, preview panel
- **Default management** — framework-wide default font, size, and flags

---

## Registry

### Register

```lua
Fonts:Register(name, path, info)
```

- `name` — unique registry key (e.g. `"Inter-Regular"`)
- `path` — absolute font path (e.g. `"Interface\\AddOns\\RGX-Framework\\media\\fonts\\Inter-Regular.otf"`)
- `info` — optional metadata table: `{ family, category, displayName, license, available }`

Registering a font that already exists overwrites the entry and invalidates the `_groupedFontsCache`.

### RegisterAddonFont

```lua
Fonts:RegisterAddonFont(addonName, fontName, fontFile, info)
```

Convenience for external addons. `fontFile` is relative to the addon directory; RGX resolves the full path:

```lua
Fonts:RegisterAddonFont("MyFontPack", "CoolFont", "fonts/CoolFont.ttf", {
    family = "CoolFont", category = "display"
})
```

### RegisterFontPack

```lua
Fonts:RegisterFontPack(addonName, definitions)
```

Batch-register multiple fonts:

```lua
Fonts:RegisterFontPack("MyFontPack", {
    ["PixelPro"] = { file = "fonts/PixelPro.ttf", family = "PixelPro", category = "pixel" },
    ["PixelPro-Bold"] = { file = "fonts/PixelPro-Bold.ttf", family = "PixelPro", category = "pixel" },
})
```

### Query

```lua
Fonts:Exists(name)          -- boolean; true if registered (even if unavailable)
Fonts:IsAvailable(name)     -- boolean; false if in unavailableFonts blocklist
Fonts:GetPath(name)         -- absolute path string, or nil
Fonts:Get(name, size, flags)-- returns path, size, flags (resolved)
Fonts:GetFont(name, size, flags) -- alias for Get
Fonts:GetInfo(name)         -- full registry entry table
Fonts:List()                -- all registered names (including unavailable)
Fonts:ListAvailable()       -- only available names (excludes blocklist)
Fonts:ListByCategory(cat)   -- names in a category
Fonts:GetCategories()       -- distinct category strings
Fonts:GetFamilies()         -- distinct family strings
Fonts:GetGroupedFonts()     -- nested { [cat] = { [family] = { name, ... } } }
Fonts:FindByPath(path)      -- reverse lookup: path → name
Fonts:ResolveName(value, fallback) -- accepts name or saved path, returns canonical name
Fonts:ResolvePath(value, fallback) -- returns safe path, name
```

---

## Blocked Fonts

10 fonts are in-tree but have corrupted asset files (HTML placeholders downloaded instead of actual font files). They are listed in `definitions.lua` as `unavailableFonts`:

| Font | Category | Family |
|---|---|---|
| Audiowide-Regular | display | Audiowide |
| Cinzel-Regular | fantasy | Cinzel |
| Merriweather-Regular | serif | Merriweather |
| Merriweather-Bold | serif | Merriweather |
| Montserrat-Regular | sans | Montserrat |
| Montserrat-Bold | sans | Montserrat |
| Orbitron-Regular | display | Orbitron |
| Oswald-Regular | display | Oswald |
| PlayfairDisplay-Regular | serif | PlayfairDisplay |
| PlayfairDisplay-Bold | serif | PlayfairDisplay |

**Behavior:**

- `Fonts:Exists("Montserrat-Regular")` → `true` (it is registered)
- `Fonts:IsAvailable("Montserrat-Regular")` → `false` (it is blocked)
- `Fonts:ListAvailable()` → excludes all 10
- `Fonts:List()` → includes all 10
- Font dropdowns and selectors only show available fonts
- `BuildGroupedFontItems` only includes available fonts in menu items

**Fixing:** Replace the corrupted files with real font assets in `media/fonts/`, then remove the entries from `unavailableFonts` in `definitions.lua`.

---

## Applying Fonts

### Direct apply

```lua
Fonts:Apply(fontString, name, size, flags) -- SetFont on an existing FontString
Fonts:Quick(fontString, name, size, flags) -- same, with nil guards (no error if fontString is nil)
Fonts:ApplyChildren(frame, name, size, flags) -- apply to all child FontStrings recursively
```

### Create with font

```lua
Fonts:CreateString(parent, name, size, flags, layer) -- create FontString + apply font in one call
```

### From template

```lua
Fonts:FromTemplate(parent, template, text, layer)
```

Templates: `"header"`, `"title"`, `"small"`, `"default"` — each pre-defines font, size, and flags.

---

## Defaults

```lua
Fonts:SetDefault(name)         -- set the framework-wide default font name
Fonts:GetDefault()             -- returns current default (initially "Inter-Regular")
Fonts:SetDefaultSize(size)     -- set default size (initially 12)
Fonts:SetDefaultFlags(flags)   -- set default flags (initially "")
Fonts:SetAutoScale(enable)     -- enable auto-scaling based on UI scale
```

---

## Style Objects

A style is a plain table describing a complete text appearance:

```lua
local style = {
    font = "Inter-Regular",     -- registered font name
    size = 14,                  -- point size (6–72, clamped by NormalizeStyle)
    flags = "OUTLINE",          -- font flags string
    color = "highlight",        -- named color, hex string, or {r,g,b,a}
    shadowColor = {0,0,0,0.5},  -- shadow color table
    shadowOffset = {x=1, y=-1}, -- shadow offset
    justifyH = "LEFT",          -- horizontal justification
    justifyV = "MIDDLE",        -- vertical justification
    spacing = 0,                -- line spacing
    letterSpacing = 0,          -- letter spacing
    alpha = 1.0,                -- text alpha
}
```

### Create and apply

```lua
local style = Fonts:CreateStyle({ font = "Inter-Regular", size = 14, flags = "OUTLINE" })
Fonts:ApplyStyle(fontString, style)   -- applies all fields
Fonts:ApplyTextStyle(fontString, style) -- alias
```

### Normalize

```lua
Fonts:NormalizeStyle(style) -- fills missing fields with framework defaults
```

Normalization clamps `size` to [6, 72], resolves `color` via the Colors module, and fills in missing fields from `Fonts:GetDefault()` / `GetDefaultSize()` / `GetDefaultFlags()`.

### Resolve

```lua
Fonts:ResolveName(value, fallback) -- accepts a registered name or a saved font path; returns canonical name
Fonts:ResolvePath(value, fallback) -- returns safe path and canonical name
```

These handle the common case where a SavedVar stores either a font name or a path and the consumer needs the canonical form.

---

## Flag Helpers

```lua
Fonts:SplitFlags(flags)      -- "OUTLINE MONOCHROME" → { "OUTLINE", "MONOCHROME" }
Fonts:NormalizeFlags(flags)  -- normalizes string or table to canonical string
Fonts:DescribeFlags(flags)   -- human-readable description string
Fonts:GetFlagPresets()       -- table of preset flag combinations
```

**Flag presets:**

| Preset | Flags |
|---|---|
| Normal | `""` |
| OUTLINE | `"OUTLINE"` |
| THICKOUTLINE | `"THICKOUTLINE"` |
| MONOCHROME | `"MONOCHROME"` |
| MONOCHROMEOUTLINE | `"MONOCHROME,OUTLINE"` |

---

## Dropdown Schemas

The font system produces menu items in **two schemas** for dual compatibility:

### RGX MenuUtil Schema (native)

Used by `CreateNestedDropdown`, `CreateFontDropdown`, and all RGX-native selectors:

```lua
{
    text = "Inter",
    children = {          -- nested submenu items
        { text = "Regular", value = "Inter-Regular", path = "...", checked = false,
          isNotRadio = true, keepShownOnClick = true,
          func = function() end,  -- legacy compat
          onClick = function() end -- RGX MenuUtil path
        },
    },
    menuList = <same table as children>,  -- dual reference for PB2 compat
    hasArrow = true,
    notCheckable = true,
}
```

### Legacy UIDropDownMenu Schema (PB2 compat)

Used by `CreateFontMenuItems` for consumers that build their own `UIDropDownMenu`:

```lua
{
    text = "Inter",
    menuList = {          -- PB2 reads menuList
        { text = "Regular", value = "Inter-Regular",
          func = function() end,  -- PB2 reads func
          onClick = function() end, -- also present for RGX consumers
        },
    },
    hasArrow = true,
    notCheckable = true,
}
```

### Dual-schema fields

Every leaf item produced by `BuildGroupedFontItems` carries **both**:

- `children` AND `menuList` — same table reference; RGX reads `children`, PB2 reads `menuList`
- `func` AND `onClick` — `func` for legacy PB2 path, `onClick` for RGX MenuUtil path

This ensures a single `CreateFontMenuItems` call works for both RGX-native and PB2-legacy context menus.

### BuildGroupedFontItems

```lua
local items = Fonts:BuildGroupedFontItems(opts)
```

- `opts.keepShownOnClick` — if true, leaf items get `keepShownOnClick = true`
- Returns a flat array of category group headers and family submenus with leaf font items
- Only includes available fonts (blocklist excluded)
- Results are cached in `_groupedFontsCache` and invalidated on `Register()` calls

---

## UI Controls

### CreateFontDropdown

```lua
local control = Fonts:CreateFontDropdown(parent, {
    label = "Font",
    value = "Inter-Regular",    -- may also be a saved font path
    onChange = function(name, path) end,
    width = 200,
})
```

Internally calls `BuildGroupedFontItems({keepShownOnClick = true})` and creates a `CreateNestedDropdown`. Selection is handled via the `onChange` callback on the dropdown holder.

### CreateFontSettingControl

```lua
local control = Fonts:CreateFontSettingControl(parent, {
    label = "Quest Font",
    storage = db,              -- SavedVar table
    key = "questFont",         -- stores the font PATH in db[key]
    showReset = true,          -- show reset-to-default button
    onChange = function(holder, name, path) end,
})
control:Reset()                -- revert to default
```

Compound widget: font dropdown + optional reset button + optional flag dropdown + optional size slider. Auto-binds to `storage[key]`.

### CreateStyleSelector

```lua
local selector = Fonts:CreateStyleSelector(parent, opts)
```

Full style editor: font dropdown + size slider + flag dropdown + preview text. Returns composite `{font, size, flags}` via `selector.value`.

### CreateSimpleFontSelector / CreateSimpleStyleSelector

Minimal single-concern selectors.

### AttachFontSelector / AttachStyleSelector

```lua
Fonts:AttachFontSelector(parent, db, "titleFont", opts)
Fonts:AttachStyleSelector(parent, db, "titleText", opts)
```

One-line binding to a SavedVar key. Reads/writes `db[key]` automatically.

### FontPreview

```lua
FontPreview:Create(parent)
```

Live preview panel showing selected font at the chosen size/flags.

---

## Menu Item Factories

For addons building their own context menus:

```lua
Fonts:CreateFontMenuItems({ current = db.font, onSelect = function(name) end })
Fonts:CreateFlagMenuItems({ current = db.flags, onSelect = function(flags) end })
Fonts:CreateSizeMenuItems({ current = db.size, onSelect = function(size) end })
Fonts:CreateStyleMenuItems({ db = db, key = "titleText", onChange = function(style) end })
```

`CreateFontMenuItems` delegates to `BuildGroupedFontItems` — single source of truth for grouped font menu data.

---

## Font Coverage

### Available (26 bundled names across 14 families + 8 WoW defaults = 34 selectable)

| Category | Family | Weights |
|---|---|---|
| Sans / UI | Inter | Regular, Bold |
| Sans / UI | Ubuntu | Regular, Bold |
| Sans / UI | Liberation Sans | Regular, Bold, BoldItalic, Italic |
| Sans / UI | DejaVu Sans | Regular, Bold, Condensed, Condensed-Bold |
| Sans / UI | Lato | Regular, Bold |
| Sans / UI | Poppins | Regular, Bold |
| Sans / UI | Rajdhani | Regular, Bold |
| Serif | Crimson Text | Regular |
| Monospace | IBM Plex Mono | Regular |
| Monospace | JetBrains Mono | Regular, Bold |
| Display | Bebas Neue | Regular |
| Display | Bangers | Regular |
| Display | Creepster | Regular |
| Display | Anton | Regular |
| Pixel | Press Start 2P | Regular |
| Pixel | Silkscreen | Regular |
| Pixel | VT323 | Regular |
| Fantasy | Uncial Antiqua | Regular |

### WoW Defaults (8 names, always available)

Friz Quadrata, Arial Narrow, Morpheus, Skurri (plus 4 variant names)

### Blocked (10 names, in-tree but not selectable)

Montserrat-Regular, Montserrat-Bold, Merriweather-Regular, Merriweather-Bold, PlayfairDisplay-Regular, PlayfairDisplay-Bold, Oswald-Regular, Orbitron-Regular, Audiowide-Regular, Cinzel-Regular

---

## File Layout

```
modules/fonts/
├── definitions.lua   — 36 font definitions + unavailableFonts blocklist
├── init.lua          — Fonts:Init() + RegisterModule("fonts")
├── registry.lua      — Register, RegisterAddonFont, RegisterFontPack
├── query.lua         — GetPath, Get, Exists, IsAvailable, List, ListAvailable, etc.
├── defaults.lua      — SetDefault, GetDefault, SetDefaultSize, etc.
├── apply.lua         — Apply, Quick, ApplyChildren, CreateString, FromTemplate
├── normalize.lua     — SplitFlags, NormalizeFlags, DescribeFlags, GetFlagPresets
├── styles.lua        — NormalizeStyle, NormalizeColorValue, CreateStyle, ApplyStyle
├── grouping.lua      — BuildGroupedFontItems, _groupedFontsCache
├── dropdowns.lua     — CreateFontDropdown, buildItems
├── controls.lua      — CreateFontSettingControl
├── menuitems.lua     — CreateFontMenuItems, CreateFlagMenuItems, etc.
├── selectors.lua     — CreateStyleSelector, AttachStyleSelector, etc.
└── preview.lua       — FontPreview:Create, _ApplyPreviewSelection
```
