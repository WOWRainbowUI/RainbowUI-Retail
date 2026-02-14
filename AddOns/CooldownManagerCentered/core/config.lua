local _, ns = ...
CooldownManagerCentered = LibStub("AceAddon-3.0"):NewAddon("CooldownManagerCentered", "AceConsole-3.0")
ns.Addon = CooldownManagerCentered

-- Default Settings
ns.DEFAULT_SETTINGS = {
    profile = {
        -- cooldownManager_centerBuffIcons = false,
        cooldownManager_alignBuffIcons_growFromDirection = "CENTER",
        -- cooldownManager_alignBuffBars = false,
        cooldownManager_alignBuffBars_growFromDirection = "BOTTOM",
        -- cooldownManager_centerEssential = false,
        cooldownManager_centerEssential_growFromDirection = "TOP",
        -- cooldownManager_centerUtility = false,
        cooldownManager_centerUtility_growFromDirection = "TOP",

        cooldownManager_utility_dimWhenNotOnCD = false,
        cooldownManager_utility_dimOpacity = 0.3,

        cooldownManager_cooldownFontName = "Friz Quadrata TT",
        cooldownManager_cooldownFontFlags = { OUTLINE = true },
        cooldownManager_cooldownFontSizeEssential_enabled = false,
        cooldownManager_cooldownFontSizeEssential = "NIL",
        cooldownManager_cooldownFontSizeUtility_enabled = false,
        cooldownManager_cooldownFontSizeUtility = "NIL",
        cooldownManager_cooldownFontSizeBuffIcons_enabled = false,
        cooldownManager_cooldownFontSizeBuffIcons = "NIL",

        cooldownManager_stackFontName = "Friz Quadrata TT",
        cooldownManager_stackFontFlags = { OUTLINE = true },

        cooldownManager_stackFontSizeEssential = nil,
        cooldownManager_stackFontSizeUtility = nil,
        cooldownManager_stackFontSizeBuffIcons = nil,

        cooldownManager_stackAnchorEssential_enabled = false,
        cooldownManager_stackAnchorEssential_point = "BOTTOMRIGHT",
        cooldownManager_stackAnchorEssential_offsetX = 0,
        cooldownManager_stackAnchorEssential_offsetY = 0,

        cooldownManager_stackAnchorUtility_enabled = false,
        cooldownManager_stackAnchorUtility_point = "BOTTOMRIGHT",
        cooldownManager_stackAnchorUtility_offsetX = 0,
        cooldownManager_stackAnchorUtility_offsetY = 0,

        cooldownManager_stackAnchorBuffIcons_enabled = false,
        cooldownManager_stackAnchorBuffIcons_point = "BOTTOMRIGHT",
        cooldownManager_stackAnchorBuffIcons_offsetX = 0,
        cooldownManager_stackAnchorBuffIcons_offsetY = 0,

        -- Square Icons Styling
        cooldownManager_squareIcons_Essential = false,
        cooldownManager_squareIconsBorder_Essential = 1,
        cooldownManager_squareIconsBorder_Essential_Overlap = false,
        cooldownManager_squareIconsZoom_Essential = 0.3,

        cooldownManager_squareIcons_Utility = false,
        cooldownManager_squareIconsBorder_Utility = 1,
        cooldownManager_squareIconsBorder_Utility_Overlap = false,
        cooldownManager_squareIconsZoom_Utility = 0.3,

        cooldownManager_squareIcons_BuffIcons = false,
        cooldownManager_squareIconsBorder_BuffIcons = 1,
        cooldownManager_squareIconsBorder_BuffIcons_Overlap = false,
        cooldownManager_squareIconsZoom_BuffIcons = 0.3,

        -- Keybinds Display
        cooldownManager_keybindFontName = "Friz Quadrata TT",
        cooldownManager_keybindFontFlags = { OUTLINE = true },

        cooldownManager_showKeybinds_Essential = false,
        cooldownManager_keybindAnchor_Essential = "TOPRIGHT",
        cooldownManager_keybindFontSize_Essential = 14,
        cooldownManager_keybindOffsetX_Essential = -3,
        cooldownManager_keybindOffsetY_Essential = -3,

        cooldownManager_showKeybinds_Utility = false,
        cooldownManager_keybindAnchor_Utility = "TOPRIGHT",
        cooldownManager_keybindFontSize_Utility = 10,
        cooldownManager_keybindOffsetX_Utility = -3,
        cooldownManager_keybindOffsetY_Utility = -3,

        cooldownManager_limitUtilitySizeToEssential = false,

        -- Rotation Highlight (Assisted Combat)
        cooldownManager_showHighlight_Essential = false,
        cooldownManager_showHighlight_Utility = false,

        cooldownManager_buttonPress = false,
        cooldownManager_buttonPress_texture = "Blizzard",

        -- Icon Size Normalization
        cooldownManager_normalizeUtilitySize = false,

        cooldownManager_customSwipeColor_enabled = false,
        cooldownManager_customActiveColor_r = 1,
        cooldownManager_customActiveColor_g = 0.95,
        cooldownManager_customActiveColor_b = 0.57,
        cooldownManager_customActiveColor_a = 0.69,
        cooldownManager_customCDSwipeColor_r = 0,
        cooldownManager_customCDSwipeColor_g = 0,
        cooldownManager_customCDSwipeColor_b = 0,
        cooldownManager_customCDSwipeColor_a = 0.69,

        cooldownManager_experimental_hideAuras = false,
        cooldownManager_experimental_enableRectangularIcons = false,
        cooldownManager_experimental_trinketRacialTracker = false,

        trinketRacialTracker_position = nil,
        trinketRacialTracker_squareIcons = false,
        trinketRacialTracker_borderThickness = 1,
        trinketRacialTracker_iconZoom = 0.3,
        trinketRacialTracker_stackAnchor = "BOTTOMRIGHT",
        trinketRacialTracker_stackFontSize = 14,
        trinketRacialTracker_stackOffsetX = -1,
        trinketRacialTracker_stackOffsetY = 1,
        trinketRacialTracker_ignoredRacials = {},
        trinketRacialTracker_ignoredItems = {},

        editMode = {
            trinketRacialTracker = {},
        },
    },
}
