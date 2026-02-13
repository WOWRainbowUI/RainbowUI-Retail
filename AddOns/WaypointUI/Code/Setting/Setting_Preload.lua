local env = select(2, ...)
local Path = env.WPM:Import("wpm_modules\\path")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Setting_Preload = env.WPM:New("@\\Setting\\Preload")

local ATLAS_TAB_BUTTON = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Setting\\TabButton.png", inset = 128 }
local ATLAS_CONTAINER = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Setting\\WidgetContainer.png", inset = 70, sliceMode = Enum.UITextureSliceMode.Stretched }
Setting_Preload.UIDef = {
    Divider                         = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Shape\\Square.png" },

    --Tab Button
    UITabButton                     = ATLAS_TAB_BUTTON{ left = 0 / 768, top = 0 / 512, right = 256 / 768, bottom = 256 / 512, scale = 0.575 },
    UITabButton_Highlighted         = ATLAS_TAB_BUTTON{ left = 256 / 768, top = 0 / 512, right = 512 / 768, bottom = 256 / 512, scale = 0.575 },
    UITabButton_Pushed              = ATLAS_TAB_BUTTON{ left = 512 / 768, top = 0 / 512, right = 768 / 768, bottom = 256 / 512, scale = 0.575 },
    UITabButtonSelected             = ATLAS_TAB_BUTTON{ left = 0 / 768, top = 256 / 512, right = 256 / 768, bottom = 512 / 512, scale = 0.575 },
    UITabButtonSelected_Highlighted = ATLAS_TAB_BUTTON{ left = 256 / 768, top = 256 / 512, right = 512 / 768, bottom = 512 / 512, scale = 0.575 },
    UITabButtonSelected_Pushed      = ATLAS_TAB_BUTTON{ left = 512 / 768, top = 256 / 512, right = 768 / 768, bottom = 512 / 512, scale = 0.575 },

    --Container
    UICContainer                    = ATLAS_CONTAINER{ left = 0 / 512, right = 256 / 512, top = 0 / 512, bottom = 256 / 512, scale = 0.25 },
    UICSubcontainer                 = ATLAS_CONTAINER{ left = 256 / 512, right = 512 / 512, top = 0 / 512, bottom = 256 / 512, scale = 0.25 },

    --Widget
    UIWidget                        = UIKit.Define.Texture_NineSlice{ path = Path.Root .. "\\Art\\Setting\\WidgetBackground.png", inset = 70, scale = 0.125, sliceMode = Enum.UITextureSliceMode.Stretched }
}

Setting_Preload.NAME = env.NAME
Setting_Preload.FRAME_NAME = "WUISettingFrame"
Setting_Preload.DB_GLOBAL_NAME = "WaypointDB_Global"
