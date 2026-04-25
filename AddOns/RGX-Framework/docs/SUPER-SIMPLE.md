# SUPER SIMPLE RGX Integration

## The Absolute Minimum Code

### 1. Add RequiredDeps

```
## RequiredDeps: RGX-Framework
```

### 2. Get Font Path

```lua
local path = _G.RGXFonts:GetPath("Inter-Regular")
myText:SetFont(path, 12, "OUTLINE")
```

## That's It!

## Slightly Better: One Shared Style Table

```lua
local Fonts = _G.RGXFonts

local style = Fonts:CreateStyle({
    font = "Inter-Regular",
    size = 14,
    flags = "OUTLINE",
})

Fonts:ApplyTextStyle(myText, style)
```

## Easiest UI Integration

### Full-Scope Easiest

```lua
_G.RGXFonts:AttachStyleSelector(parent, db, "titleText")
_G.RGXFonts:ApplyTextStyle(myText, db.titleText)
```

That is the intended "one line to mount UI, one line to apply" path.

```lua
local Fonts = _G.RGXFonts

local fontSelector = Fonts:CreateSimpleFontSelector(parent, {
    label = "Font",
    value = "Inter-Regular",
    onChange = function(fontName)
        saved.font = fontName
        Fonts:ApplyTextStyle(myText, saved)
    end,
})

local styleSelector = Fonts:CreateSimpleStyleSelector(parent, {
    label = "Text Style",
    value = saved,
    onChange = function(style)
        saved = style
        Fonts:ApplyTextStyle(myText, saved)
    end,
})
```

### Font-Only Binding

```lua
_G.RGXFonts:AttachFontSelector(parent, db, "titleFont")
```

## Complete Example

```lua
-- .toc file
## Interface: 110002
## Title: MyAddon
## RequiredDeps: RGX-Framework

MyAddon.lua
```

```lua
-- MyAddon.lua
-- Get a font path
local fontPath = _G.RGXFonts:GetPath("Inter-Regular")

-- Create text with RGX font
local text = UIParent:CreateFontString(nil, "OVERLAY")
text:SetFont(fontPath, 14, "OUTLINE")
text:SetPoint("CENTER")
text:SetText("Hello with Inter font!")
```

## PB2 Example

```lua
-- Add RGX fonts to PB2's list
for _, info in ipairs(_G.RGXFonts:ListAvailable()) do
    addon:RegisterMedia("font", info.name, info.path)
end

-- Use RGX font (one line!)
local path = _G.RGXFonts:GetPath(selectedFont)
myText:SetFont(path, 12, "OUTLINE")
```

## What Addon Authors Should Actually Use

- `GetPath(fontName)` when you only need a path
- `CreateStyle(styleTable)` when you want one normalized style object
- `ApplyTextStyle(fontString, style)` when you want one-call application
- `CreateSimpleFontSelector(parent, opts)` for a grouped nested font dropdown
- `CreateSimpleStyleSelector(parent, opts)` for a reusable style widget
- `AttachFontSelector(parent, db, key)` for one-line DB-bound font UI
- `AttachStyleSelector(parent, db, key)` for one-line DB-bound style UI

## Why This Works

1. `## RequiredDeps: RGX-Framework` ensures RGX loads first
2. `_G.RGXFonts` is created by RGX-Framework
3. The simple path is just `_G.RGXFonts`, `CreateStyle`, `ApplyTextStyle`, and the selector helpers

No bridge layer, no per-addon font plumbing, and no need to rebuild dropdowns by hand.
