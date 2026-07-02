# Using RGX-Framework in BattlePetUtility

## Step 1: Add Dependency

In `BattlePetUtility.toc`:
```
## RequiredDeps: RGX-Framework
```

## Step 2: Replace Font Code

**OLD BPU code (in options.lua):**
```lua
-- Register fonts manually
addon:RegisterMedia("font", "Roboto", "Interface/AddOns/BattlePetUtility/media/fonts/Roboto.ttf")
-- ... etc for each font

-- Later: get font path
local fontPath = addon:FetchMedia("font", selectedFont)
```

**NEW with RGX-Framework:**
```lua
local RGX = _G.RGXFramework
local Fonts = RGX:GetModule("fonts")

local style = Fonts:CreateStyle({
    font = "Inter-Regular",
    size = 14,
    flags = "OUTLINE",
})

Fonts:ApplyTextStyle(myText, style)
```

## Step 3: Font Dropdown

**NEW:**
```lua
local Fonts = RGX:GetModule("fonts")

local styleSelector = Fonts:AttachStyleSelector(parent, db, "titleText", {
    label = "Title Text",
    onChange = function()
        addon:RefreshFonts()
    end,
})
```

## Step 4: Apply Fonts

```lua
-- Get RGX fonts module
local Fonts = RGX:GetModule("fonts")

-- Apply to BattlePetUtility's font objects
function addon:RefreshFonts()
    Fonts:ApplyTextStyle(BattlePetUtilityFontTitle, self.db.global.titleText)
    Fonts:ApplyTextStyle(BattlePetUtilityFontNormal, self.db.global.normalText)
    Fonts:ApplyTextStyle(BattlePetUtilityFontSmall, self.db.global.smallText)
end
```

## Benefits

1. **No font files in BPU** - All fonts live in RGX-Framework
2. **Shared fonts** - Other addons using RGX-Framework get the same fonts
3. **Automatic fallbacks** - If a font isn't available, automatically uses defaults
4. **Easy updates** - Update fonts in one place (RGX-Framework)
