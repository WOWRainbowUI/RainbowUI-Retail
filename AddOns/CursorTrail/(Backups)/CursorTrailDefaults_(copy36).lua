--[[---------------------------------------------------------------------------
    File:   CursorTrailDefaults.lua
    Desc:   This file contains default settings for this addon.
-----------------------------------------------------------------------------]]

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Aliases to Globals                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local Globals = _G
local _  -- Prevent tainting global _ .
local assert = _G.assert
local CopyTable = _G.CopyTable
----local DEFAULTS = _G.DEFAULTS  -- Blizzard's localized string: "Defaults"
local pairs = _G.pairs
----local print = _G.print

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Declare Namespace                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local CursorTrail = _G.CursorTrail or {}
if (not _G.CursorTrail) then _G.CursorTrail = CursorTrail end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Remap Global Environment                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Constants                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kDefaultModelID = 166498  -- "Electric, Blue & Long"
kDefaultStrata = "HIGH"

kNoChange = nil  -- Must be nil so compareToDefaultProfile() in UDProfiles.lua can work.

-- The main table.
kDefaultConfig =  -- Initialize this variable to an empty table.
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
kDefaultConfig["Electric"] = {  -- [ Keywords: kDefaultConfigKey ]
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = kDefaultModelID,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = true,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Electric B&W Rings"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring Soft 1.tga",
            ModelID = 166498,  -- "Electric, Blue & Long"
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = true,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = false,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring 1.tga",
            ModelID = 0,
            ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.15,
            UserAlpha = 1,
            Strata = "BACKGROUND",
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = true,
        },
        [3] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring 1.tga",
            ModelID = 0,
            ShapeColorR = 0.5, ShapeColorG = 0.5, ShapeColorB = 0.5,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.27,
            UserAlpha = 0.25,
            Strata = "BACKGROUND",
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = true,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Electric Large"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = kDefaultModelID,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.35,
            UserAlpha = 0.50,
            Strata = kDefaultStrata,
            UserOfsX = 1.0, UserOfsY = -0.9,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Electric Small"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = kDefaultModelID,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.50,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 3.4, UserOfsY = -2.8,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Electric Huge"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Glow Purple"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Glow Purple Fade"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Glow Purple Fade 2"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = 166923,  -- "Burning Cloud, Purple"
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.50,
            UserScale = 1.5,
            UserAlpha = 0.80,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0.025,
            -- - - - - - - - - - - - - - --
            FadeOut = true,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Glow Soft Fade"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Star Glow Red"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Star 1.tga",
            ModelID = 166294,  -- "Burning Cloud, Red"
            ShapeColorR = 1, ShapeColorG = 0.502, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.35,
            UserScale = 1.05,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = 166159,  -- "Trail - Swirling, Firestrike"
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Ring & Electric Trail"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring Soft 4.tga",
            ModelID = 0,
            ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.98,
            UserAlpha = 0.65,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Ring Dark Edges"] = {
    MasterScale = 0.9,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring 2.tga",
            ModelID = 0,
            ShapeColorR = 0.992, ShapeColorG = 0.792, ShapeColorB = 0.635,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.3,
            UserScale = 0.9,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring Soft 4.tga",
            ModelID = 0,
            ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.98,
            UserAlpha = 0.65,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Ring Dim Mouse Look"] = {
    MasterScale = 0.9,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring 2.tga",
            ModelID = 0,
            ShapeColorR = 0.992, ShapeColorG = 0.792, ShapeColorB = 0.635,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.9,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = false,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring Soft 2.tga",
            ModelID = 0,
            ShapeColorR = 0.992, ShapeColorG = 0.792, ShapeColorB = 0.635,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.05,
            UserScale = 0.9,
            UserAlpha = 0.3,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = true,
        },
        [3] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring Soft 4.tga",
            ModelID = 0,
            ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.99,
            UserAlpha = 0.65,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = true,
        },
    },
}----------------________________________-----------------------------------
kDefaultConfig["Ring Sparkle"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Star Dark Edge"] = {
    MasterScale = 1.25,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Star 1.tga",
            ModelID = 0,
            ShapeColorR = 0.992, ShapeColorG = 0.792, ShapeColorB = 0.635,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.14,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Star 1.tga",
            ModelID = 0,
            ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.83,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [3] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = 0,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.1,
            UserScale = 0.75,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Star Doubled"] = {
    MasterScale = 1.25,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Star 1.tga",
            ModelID = 0,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.14,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Star 1.tga",
            ModelID = 0,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.83,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [3] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = 0,
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.2,
            UserScale = 0.75,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Star Glow Green"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Cross Yellow Pulse"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Cross Glow Shadow"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Ring & Bones"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
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
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
    },
}

----------------________________________-----------------------------------
kDefaultConfig["Cross & Ring, Red"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Cross 1.tga",
            ModelID = 0,  -- None.
            ShapeColorR = 1, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 0.75,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = true,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring 1.tga",
            ModelID = 165784,  -- "Trail - Sparkling, Red"
            ShapeColorR = 1, ShapeColorG = 0, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.2,
            UserScale = 1.15,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = true,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = false,
        },
    },
}

----------------________________________-----------------------------------
kDefaultConfig["Ring Glow Green"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring 1.tga",
            ModelID = 0,
            ShapeColorR = 1, ShapeColorG = 0.761, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0.15,
            UserScale = 1.26,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = true,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Ring Soft 3.tga",
            ModelID = 0,
            ShapeColorR = 0.502, ShapeColorG = 1, ShapeColorB = 0,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.35,
            UserAlpha = 1,
            Strata = "BACKGROUND",
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = true,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = false,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["Evil Eye"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = 166334,  -- "Object - Ring, Yellow"
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1,
            UserAlpha = 0.85,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [2] = {
            IsLayerEnabled = true,
            ShapeFileName = 458999,  -- "Ring (Meat)"
            ModelID = 166334,  -- "Object - Ring, Yellow"
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 0.5,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.15,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = false,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = kNoChange,
        },
        [3] = {
            IsLayerEnabled = true,
            ShapeFileName = kShape_None,
            ModelID = 166159,  -- "Trail - Swirling, Firestrike"
            ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
            ShapeSparkle = false,
            -- - - - - - - - - - - - - - --
            UserShadowAlpha = 0,
            UserScale = 1.15,
            UserAlpha = 1,
            Strata = kDefaultStrata,
            UserOfsX = 0, UserOfsY = 0,
            -- - - - - - - - - - - - - - --
            FadeOut = true,
            UserShowOnlyInCombat = kNoChange,
            UserShowMouseLook = false,
        },
    },
}
----------------________________________-----------------------------------
kDefaultConfig["(Start Here)"] = {
    MasterScale = 1,
    Layers = {
        [1] = {
            IsLayerEnabled = true,
            ShapeFileName = kMediaPath.."Cross 1.tga",
            ModelID = 0,  -- None.
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
            UserShowOnlyInCombat = false,
            UserShowMouseLook = false,
        },
        [2] = {
            IsLayerEnabled = false,
            ShapeFileName = kMediaPath.."Ring 1.tga",
            ModelID = 0,  -- None.
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
            UserShowOnlyInCombat = false,
            UserShowMouseLook = false,
        },
    },
}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       RETAIL, CATA & WRATH WoW                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if isWrathWoW_Min() then
    ----------------________________________-----------------------------------
    kDefaultConfig["Ice Cold"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
                ModelID = 166028,  -- "Glow - Cloud, Blue"
                ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0,
                UserScale = 2.6,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
            [2] = {
                IsLayerEnabled = true,
                ShapeFileName = 458995,  -- "Ring (Ice)"
                ModelID = 166538,  -- "Glow - Burning Cloud, Blue"
                ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0.2,
                UserScale = 1.15,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Soul Skull Trail"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Ring & Soul Skull"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Small Blue Green"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kMediaPath.."Glow Reversed.tga",
                ModelID = 166491,  -- "Trail - Electric, Green"
                ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 1,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0,
                UserScale = 0.42,
                UserAlpha = 0.88,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0.05,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Sphere Orange Swirl"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       RETAIL WoW                                        ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if isRetailWoW() then
    ----------------________________________-----------------------------------
    kDefaultConfig["Flashy Ball Bearing"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
                ModelID = 1414694,  -- "Object - Pentagon Flashers"
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
            [2] = {
                IsLayerEnabled = true,
                ShapeFileName = 457566,  -- "Ring (Atramedes)"
                ModelID = 1536474,  -- "Trail - Cloud, Blue & Green"
                ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0,
                UserScale = 1.17,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Ring & Rainbow"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kMediaPath.."Ring Soft 2.tga",
                ModelID = 1417024,  -- "Sparkling, Rainbow"
                ShapeColorR = 1, ShapeColorG = 0.882, ShapeColorB = 0.882,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0.7,
                UserScale = 0.88,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = true,
            },
            [2] = {
                IsLayerEnabled = true,
                ShapeFileName = kMediaPath.."Ring Soft 2.tga",
                ModelID = 0,
                ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
                ShapeSparkle = true,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0,
                UserScale = 1.07,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = true,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = false,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Ring & Rainbow 2"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
                ModelID = 165943,  -- "Sparkle, Blue"
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
            [2] = {
                IsLayerEnabled = true,
                ShapeFileName = kMediaPath.."Ring 2.tga",
                ModelID = 1417024,  -- "Sparkling, Rainbow"
                ShapeColorR = 1, ShapeColorG = 0.592, ShapeColorB = 0,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0.3,
                UserScale = 0.9,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
            [3] = {
                IsLayerEnabled = true,
                ShapeFileName = kMediaPath.."Ring Soft 4.tga",
                ModelID = 0,
                ShapeColorR = 0, ShapeColorG = 0, ShapeColorB = 0,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0,
                UserScale = 0.98,
                UserAlpha = 0.65,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Star Flame"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Swirly Green"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kMediaPath.."Swirl.tga",
                ModelID = 975870,  -- "Spots - Swirling, Purple & Orange"
                ShapeColorR = 0.502, ShapeColorG = 1, ShapeColorB = 0,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0,
                UserScale = 0.8,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0.15, UserOfsY = -0.15,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Big Donut"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = kNoChange,
            },
        },
    }
    ----------------________________________-----------------------------------
    kDefaultConfig["Fireball"] = {
        MasterScale = 1,
        Layers = {
            [1] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
                ModelID = 166159,  -- "Trail - Swirling, Firestrike"
                ShapeColorR = 1, ShapeColorG = 1, ShapeColorB = 1,
                ShapeSparkle = false,
                -- - - - - - - - - - - - - - --
                UserShadowAlpha = 0.12,
                UserScale = 1.5,
                UserAlpha = 1,
                Strata = kDefaultStrata,
                UserOfsX = 0, UserOfsY = 0,
                -- - - - - - - - - - - - - - --
                FadeOut = false,
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = false,
            },
            [2] = {
                IsLayerEnabled = true,
                ShapeFileName = kShape_None,
                ModelID = 1513210,  -- "Trail - Solar Wrath"
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
                UserShowOnlyInCombat = kNoChange,
                UserShowMouseLook = true,
            },
        },
    }
end

kDefaultConfigKey = "Electric"  -- Used when the addon is first installed.
assert( kDefaultConfig[kDefaultConfigKey] )

kNewConfigKey = "(Start Here)"  -- Used when user creates a new profile.
assert( kDefaultConfig[kNewConfigKey] )

-------------------------------------------------------------------------------
-- Copy default values into layers that don't have any data yet.
kDefaultConfigLayer = kDefaultConfig[kNewConfigKey].Layers[2]
for name, data in pairs(kDefaultConfig) do
    assert( data.Layers and data.Layers[1] and data.Layers[1].IsLayerEnabled, 'Structure error in default data for "' .. name .. '".' )
    for i = 1, kMaxLayers do
        if not data.Layers[i] then
            data.Layers[i] = CopyTable(kDefaultConfigLayer)
            data.Layers[i].IsLayerEnabled = false
            ----data.Layers[i].FadeOut = kNoChange
            ----data.Layers[i].UserShowOnlyInCombat = kNoChange
            ----data.Layers[i].UserShowMouseLook = kNoChange
        end
    end
end

--- End of File ---
