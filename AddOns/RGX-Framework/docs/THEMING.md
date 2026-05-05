# RGX Theming and Design System

Visual identity, color palette, textures, and styling conventions.

---

## Design Palette (`RGXDesign`)

`RGXDesign` provides a static color palette used across all RGX-family addons. Access colors directly:

```lua
local Design = RGX:GetDesign()
local primary = Design.Colors.primary    -- {r=0.345, g=0.745, b=0.506}
local accent  = Design.Colors.accent     -- {r=0.737, g=0.435, b=0.659}
```

### Brand Colors

| Key | Hex | RGB | Usage |
|---|---|---|---|
| `primary` | `#58be81` | Green | Brand identity, positive actions, `[RGX]` chat prefix |
| `accent` | `#bc6fa8` | Purple | Brand secondary, highlights, active states |

### Surface Colors

| Key | Usage |
|---|---|
| `surface` | Panel and card backgrounds |
| `background` | Main window / frame backgrounds |

### Text Colors

| Key | Usage |
|---|---|
| `text` | Primary text (light on dark) |
| `subtext` | Secondary / dimmed text |

### Semantic Colors

| Key | Usage |
|---|---|
| `success` | Positive indicators (completed, enabled, etc.) |
| `warning` | Caution indicators (pending, attention) |
| `error` | Error / negative indicators (failed, disabled) |

### Border Colors

| Key | Usage |
|---|---|
| `border` | Default panel / widget borders |
| `borderActive` | Focused / selected widget borders |
| `hover` | Hover state highlights |

---

## Using Colors in Code

### Via Design palette

```lua
local Design = RGX:GetDesign()
local c = Design.Colors.primary
myFontString:SetTextColor(c.r, c.g, c.b, c.a or 1)
```

### Via Colors module

```lua
local Colors = RGX:GetColors()
Colors:ApplyText(myFontString, "primary")     -- if registered as named color
Colors:ApplyStatusBar(myBar, "success")
```

### Wrapping text with colors

```lua
local Colors = RGX:GetColors()
local wrapped = Colors:Wrap("Hello", "primary")  -- |cff58be81Hello|r
local classText = Colors:WrapClass("Hunter", "HUNTER")
local qualText = Colors:WrapQuality("Epic", 4)
```

### Color math

```lua
local Colors = RGX:GetColors()
local dimmed = Colors:Darken("primary", 0.3)      -- 30% darker
local bright = Colors:Lighten("accent", 0.2)      -- 20% lighter
local mid    = Colors:Lerp(Colors:Get("primary"), Colors:Get("accent"), 0.5)
local health = Colors:Health(0.75)                  -- green → yellow → red gradient
```

---

## Visual Building Blocks

`RGXDesign` provides helper methods for creating consistent UI elements:

- Panel backgrounds with the RGX surface color
- Section headers using brand fonts and primary/accent colors
- Consistent border styling with `border` and `borderActive`

---

## Font Styling Conventions

### RGX default font

`Inter-Regular` at 12pt with no flags. This is the framework default set in `config.lua`.

### Template styles

| Template | Font | Size | Flags | Use |
|---|---|---|---|---|
| `header` | Inter-Bold | 18 | — | Section headers |
| `title` | Inter-Bold | 14 | — | Panel titles |
| `small` | Inter-Regular | 10 | — | Captions, dimmed text |
| `default` | Inter-Regular | 12 | — | Body text |

```lua
local fs = Fonts:FromTemplate(parent, "title", "My Panel Title")
```

### Style objects for consumers

```lua
local Fonts = RGX:GetFonts()
local style = Fonts:CreateStyle({
    font = "Inter-Regular",
    size = 13,
    flags = "OUTLINE",
    color = "primary",       -- resolved from Design.Colors
    justifyH = "LEFT",
})
Fonts:ApplyStyle(myFontString, style)
```

---

## Statusbar Textures

```lua
local Textures = RGX:GetTextures()
Textures:ApplyToStatusBar(myBar, "Smooth")      -- apply by name
Textures:ImportLibSharedMedia()                   -- pull in LSM textures
```

Default texture: `"Blizzard"`.

---

## Consistent UI Patterns

### Options panel

```lua
local panel = RGX:Options({
    title = "My Addon",
    tabs = {
        { text = "General", content = function(parent)
            RGX:Toggle(parent, { label = "Enable", value = true, onChange = function(v) end })
            RGX:Slider(parent, { label = "Size", min = 8, max = 32, step = 1, value = 14, onChange = function(v) end })
            RGX:Section(parent, { title = "Fonts" })
            RGX:GetFonts():AttachFontSelector(parent, db, "fontFamily")
        end },
    },
})
```

### Minimap button with brand colors

```lua
RGX:CreateMinimapButton({
    name = "MyAddonMinimap",
    icon = "Interface\\AddOns\\MyAddon\\media\\logo.tga",
    tooltip = {
        title = Colors:Wrap("My Addon", "primary"),
        lines = {
            { left = Colors:Wrap("Left-Click", "primary"), right = "Open options" },
            { left = Colors:Wrap("Drag", "accent"), right = "Reposition" },
        },
    },
    onLeftClick = function() panel:Open() end,
})
```

### Dropdown with semantic color

```lua
local Drops = RGX:GetDropdowns()
local dd = Drops:CreateNestedDropdown(parent, {
    label = "Priority",
    items = {
        { text = "High",   value = "high",   colorCode = Colors:GetHex("error") },
        { text = "Medium", value = "medium", colorCode = Colors:GetHex("warning") },
        { text = "Low",    value = "low",    colorCode = Colors:GetHex("success") },
    },
    onChange = function(value) end,
})
```

---

## Icon and Texture Paths

Framework media layout:

```
media/
├── fonts/          — bundled font files (.ttf, .otf)
├── logo.tga        — framework icon (used in TOC IconTexture)
└── textures/       — statusbar textures
```

Consumer addons should use their own `media/` directories and reference icons via full `Interface\\AddOns\\AddonName\\media\\...` paths.
