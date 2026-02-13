local env = select(2, ...)
local Path = env.WPM:Import("wpm_modules\\path")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Waypoint_Preload = env.WPM:New("@\\Waypoint\\Preload")

local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\Art\\Waypoint\\Waypoint.png" }
Waypoint_Preload.UIDef = {
    ContextIcon          = ATLAS{ left = 0 / 1792, right = 256 / 1792, top = 256 / 2560, bottom = 512 / 2560 },

    --Waypoint
    UIBeam               = ATLAS{ left = 768 / 1792, right = 1280 / 1792, top = 0 / 2560, bottom = 2560 / 2560 },
    UIBeamFX             = ATLAS{ left = 1280 / 1792, right = 1792 / 1792, top = 0 / 2560, bottom = 2560 / 2560 },
    UIWave               = ATLAS{ left = 512 / 1792, right = 768 / 1792, top = 256 / 2560, bottom = 512 / 2560 },
    UIBeamMask           = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Waypoint\\Mask-Beam.png" },
    UIBeamFXMask         = UIKit.Define.Texture{ path = Path.Root .. "\\Art\\Waypoint\\Mask-BeamFX.png" },

    --Pinpoint
    UIPinpointBackground = ATLAS{ inset = 75, scale = 0.125, left = 0 / 1792, right = 512 / 1792, top = 0 / 2560, bottom = 256 / 2560 },
    UIPinpointArrow      = ATLAS{ left = 512 / 1792, right = 768 / 1792, top = 0 / 2560, bottom = 256 / 2560 },

    --Navigator
    UINavigatorArrow     = ATLAS{ left = 0 / 1792, right = 256 / 1792, top = 512 / 2560, bottom = 768 / 2560 }
}
