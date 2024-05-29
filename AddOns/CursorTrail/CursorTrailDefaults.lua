--[[---------------------------------------------------------------------------
    Addon:  CursorTrail
    File:   CursorTrailDefaults.lua
    Desc:   This file contains default settings for this addon.
-----------------------------------------------------------------------------]]

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Aliases to Globals                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local Globals = _G
local _  -- Prevent tainting global _ .
----local DEFAULTS = _G.DEFAULTS  -- Blizzard's localized string: "Defaults"
local print = _G.print

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Declare Namespace                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local CursorTrail = _G.CursorTrail or {}
if (not _G.CursorTrail) then _G.CursorTrail = CursorTrail end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Remap Global Environment                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Constants                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kDefaultModelID = (isClassic and 166498 or 1417024)  -- "Electric, Blue & Long"
kDefaultStrata = "HIGH"

kDefaultConfigKey = (isClassic and "閃電" or "我愛彩虹")   -- Max name length is kProfileNameMaxLetters!
kDefaultConfig =
{
    -- NOTES:
    --      Default names are limited to kProfileNameMaxLetters characters (defined in ProfilesUI.lua).
    --
    --      UserScale          - User model scale.  It is 1/100th the value shown in the UI.
    --      UserAlpha          - Solid = 1.0.  Transparent = 0.0
    --      UserShadowAlpha    - Solid = 0.99.  Transparent = 0.0
    --      UserOfsX, UserOfsY - User model offsets are 1/10th the values shown in the UI.
}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       ALL WoW VERSIONS                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

----------------________________________-----------------------------------
kDefaultConfig["閃電"] = {
    ShapeFileName = nil,
    ModelID = 166498,
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 1,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["閃電-大"] = {
    ShapeFileName = nil,
    ModelID = kDefaultModelID,
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 1.35,
    UserAlpha = 0.50,
    Strata = kDefaultStrata,
    UserOfsX = 2.0, UserOfsY = -1.6,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["閃電-小"] = {
    ShapeFileName = nil,
    ModelID = kDefaultModelID,
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 0.50,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 2.0, UserOfsY = -2.1,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["閃電-巨大"] = {
    ShapeFileName = nil,
    ModelID = kDefaultModelID,
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.30,
    UserScale = 1.8,
    UserAlpha = 0.65,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["紫光"] = {
    ShapeFileName = nil,
    ModelID = 166923,  -- "Burning Cloud, Purple"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 2.0,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["紫光-淡出"] = {
    ShapeFileName = nil,
    ModelID = 166923,  -- "Burning Cloud, Purple"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 2.5,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = true,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["紫光-淡出2"] = {
    ShapeFileName = nil,
    ModelID = 166923,  -- "Burning Cloud, Purple"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.50,
    UserScale = 1.5,
    UserAlpha = 0.80,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0.1,
    -- - - - - - - - - - - - - - --
    FadeOut = true,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["光暈-淡出"] = {
    ShapeFileName = nil,
    ModelID = 166991,  -- "Cloud, Purple (Soft)"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 2.4,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = true,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["環形和閃電"] = {
    ShapeFileName = kMediaPath.."Ring 2.tga",
    ModelID = kDefaultModelID,
    ShapeColorR = 0, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.3,
    UserScale = 0.9,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["環形-閃爍"] = {
    ShapeFileName = kMediaPath.."Ring 3.tga",
    ModelID = 0,
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = true,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.65,
    UserScale = 0.65,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["星星綠光"] = {
    ShapeFileName = kMediaPath.."Star 1.tga",
    ModelID = 167214,  -- "Trail - Electric, Green Pulse"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0,
    UserScale = 1,
    UserAlpha = 0.88,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0.025,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = true,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["十字黃色脈動"] = {
    ShapeFileName = kMediaPath.."Cross 2.tga",
    ModelID = 166339,  -- "Spots - Pulsing, Holy"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 0,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.55,
    UserScale = 1.06,
    UserAlpha = 0.85,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = true,
    --UserShowMouseLook = false,
}
----------------________________________-----------------------------------
kDefaultConfig["十字暗影光暈"] = {
    ShapeFileName = kMediaPath.."Cross 2.tga",
    ModelID = 166255,  -- "Glow - Cloud, Purple"
    ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.99,
    UserScale = 0.88,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = false,
    --UserShowMouseLook = true,
}
----------------________________________-----------------------------------
kDefaultConfig["環形和骸骨"] = {
    ShapeFileName = kMediaPath.."Ring Soft 2.tga",
    ModelID = 165751,  -- "Object - Ring of Bones"
    ShapeColorR = 1, ShapeColorG = 0.882, ShapeColorB = 0.882,
    ShapeSparkle = false,
    -- - - - - - - - - - - - - - --
    UserShadowAlpha = 0.44,
    UserScale = 0.75,
    UserAlpha = 1,
    Strata = kDefaultStrata,
    UserOfsX = 0, UserOfsY = 0.05,
    -- - - - - - - - - - - - - - --
    FadeOut = false,
    --UserShowOnlyInCombat = true,
    --UserShowMouseLook = true,
}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       RETAIL & WRATH WoW                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if isRetailWoW() or isWrathWoW() then
    ----------------________________________-----------------------------------
    kDefaultConfig["靈魂骸骨"] = {
        ShapeFileName = nil,
        ModelID = 166926,  -- "Soul Skull"
        ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0,
        UserScale = 1.5,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = false,
        --UserShowMouseLook = false,
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["環形和靈魂骸骨"] = {
        ShapeFileName = kMediaPath.."Ring Soft 2.tga",
        ModelID = 166926,  -- "Soul Skull"
        ShapeColorR = 0.984, ShapeColorG = 0.714, ShapeColorB = 0.82,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0.3,
        UserScale = 0.7,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = false,
        --UserShowMouseLook = false,
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["藍綠合"] = {
        ShapeFileName = kMediaPath.."Glow Reversed.tga",
        ModelID = 166491,  -- "Trail - Electric, Green"
        ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 1,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0,
        UserScale = 0.42,
        UserAlpha = 0.88,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0.025,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = false,
        --UserShowMouseLook = false,
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["橘球"] = {
        ShapeFileName = nil,
        ModelID = 240896,  -- "Trail - Swirling, Orange"
        ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0.5,
        UserScale = 1,
        UserAlpha = 0.88,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = (isVanillaWoW() and -2.2) or 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = true,
        --UserShowMouseLook = false,
    }
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       RETAIL WoW                                        ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if isRetailWoW() then
    ----------------________________________-----------------------------------
    kDefaultConfig["環和彩虹"] = {
        ShapeFileName = kMediaPath.."Ring 3.tga",
        ModelID = 1417024,  -- "Sparkling, Rainbow"
        ShapeColorR = 1, ShapeColorG = 0.882, ShapeColorB = 0.882,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0.99,
        UserScale = 0.65,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = true,
        --UserShowMouseLook = false,
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["火焰星星"] = {
        ShapeFileName = kMediaPath.."Star 1.tga",
        ModelID = 1617293,  -- "Spots - Fire Orb"
        ShapeColorR = 1, ShapeColorG = 0.502, ShapeColorB = 0,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0.35,
        UserScale = 1,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = false,
        --UserShowMouseLook = false,
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["綠色螺旋"] = {
        ShapeFileName = kMediaPath.."Swirl.tga",
        ModelID = 975870,  -- "Spots - Swirling, Purple & Orange"
        ShapeColorR = 0.502, ShapeColorG = 1, ShapeColorB = 0,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0,
        UserScale = 0.8,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0.15, UserOfsY = 0.1,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = false,
        --UserShowMouseLook = true,
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["大甜甜圈"] = {
        ShapeFileName = kMediaPath.."Glow Reversed.tga",
        ModelID = 1417024,  -- "Sparkling, Rainbow"
        ShapeColorR = 1, ShapeColorG = 0.475, ShapeColorB = 0.906,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0,
        UserScale = 1.17,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = true,
        --UserShowMouseLook = false,
    }
	----------------________________________-----------------------------------
    kDefaultConfig["我愛彩虹"] = {
        ShapeFileName = nil,
        ModelID = 1417024,  -- "Sparkling, Rainbow"
        ShapeColorR = 1, ShapeColorG = 0.475, ShapeColorB = 0.906,
        ShapeSparkle = false,
        -- - - - - - - - - - - - - - --
        UserShadowAlpha = 0,
        UserScale = 1.17,
        UserAlpha = 1,
        Strata = kDefaultStrata,
        UserOfsX = 0, UserOfsY = 0,
        -- - - - - - - - - - - - - - --
        FadeOut = false,
        --UserShowOnlyInCombat = true,
        --UserShowMouseLook = false,
    }
end

--- End of File ---
