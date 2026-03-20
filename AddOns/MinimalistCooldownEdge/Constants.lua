-- Constants.lua – shared constants and configuration defaults

local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")

local function CategoryDefaults(enabled, fontSize)
    return {
        enabled = enabled,
        font = "GAMEDEFAULT", fontSize = fontSize or 18, fontStyle = "OUTLINE",
        textColor = { r = 1, g = 0.8, b = 0, a = 1 },
        textAnchor = "CENTER", textOffsetX = 0, textOffsetY = 0,
        hideCountdownNumbers = false,
        drawSwipe = true,
        edgeEnabled = true, edgeScale = 1.4,
        stackEnabled = true,
        hideStackText = false,
        stackFont = "GAMEDEFAULT", stackSize = (fontSize - 2) or 16, stackStyle = "OUTLINE",
        stackColor = { r = 1, g = 1, b = 1, a = 1 },
        stackAnchor = "BOTTOMRIGHT", stackOffsetX = 0, stackOffsetY = 0,
    }
end

local function DurationTextColorDefaults()
    return {
        enabled = true,
        offset = 0,
        thresholds = {
            { threshold = 5, color = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 } },
            { threshold = 60, color = { r = 1.0, g = 0.8, b = 0.0, a = 1.0 } },
            { threshold = 300, color = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 } },
        },
        defaultColor = { r = 0.67, g = 0.67, b = 0.67, a = 1.0 },
    }
end

local Constants = {
    CHAT_PREFIX = "|cff00ccffMiniCE|r",
    OPTION_SLIDER_DEBOUNCE_DELAY = 0.15,
    CLASSIFIER_SCAN_DEPTH = 10,
    MAX_COOLDOWN_OWNER_SCAN_DEPTH = 10,
    SUPPORTED_CATEGORIES = {
        actionbar = true,
        nameplate = true,
        unitframe = true,
        partyraidframes = true,
        cooldownmanager = true,
        minicc = true,
    },
    ROOT_SCAN_DEPTH = {
        actionbar = 5,
        unitframe = 8,
        partyraidframes = 8,
        nameplate = 10,
        cooldownmanager = 6,
        minicc = 6,
    },
    COOLDOWN_MEMBER_KEYS = { "cooldown", "Cooldown", "chargeCooldown", "ChargeCooldown" },
    ACTION_BAR_BUTTON_SPECS = {
        { prefix = "ActionButton", count = 12 },
        { prefix = "MultiBarBottomLeftButton", count = 12 },
        { prefix = "MultiBarBottomRightButton", count = 12 },
        { prefix = "MultiBarRightButton", count = 12 },
        { prefix = "MultiBarLeftButton", count = 12 },
        { prefix = "MultiBar5Button", count = 12 },
        { prefix = "MultiBar6Button", count = 12 },
        { prefix = "MultiBar7Button", count = 12 },
        { prefix = "PetActionButton", count = 10 },
        { prefix = "StanceButton", count = 12 },
        { prefix = "PossessButton", count = 2 },
        { prefix = "OverrideActionBarButton", count = 6 },
        { prefix = "BT4Button", count = 120 },
        { prefix = "BT4PetButton", count = 10 },
        { prefix = "DominosActionButton", count = 120 },
        { prefix = "DominosPetActionButton", count = 10 },
    },
    BLACKLIST_NAME_CONTAINS = {
        "Glider", "Party", "Compact",
        "Raid", "VuhDo", "Grid",
        "PVEFrame", "PVPQueueFrame",
        "LossOfControlFrame",
        "ContainerFrameCombinedBagsCooldown",
        "HousingDashboardFrame",
    },
    BLACKLIST_EXACT_PAIRS = {
        ["CharacterBackSlot"] = { ["CharacterBackSlotCooldown"] = true },
        ["CharacterShirtSlot"] = { ["CharacterShirtSlotCooldown"] = true },
        ["CharacterMainHandSlot"] = { ["CharacterMainHandSlotCooldown"] = true },
        ["CharacterLegsSlot"] = { ["CharacterLegsSlotCooldown"] = true },
        ["CharacterFinger0Slot"] = { ["CharacterFinger0SlotCooldown"] = true },
        ["CharacterHeadSlot"] = { ["CharacterHeadSlotCooldown"] = true },
        ["CharacterFeetSlot"] = { ["CharacterFeetSlotCooldown"] = true },
        ["CharacterShoulderSlot"] = { ["CharacterShoulderSlotCooldown"] = true },
        ["CharacterWristSlot"] = { ["CharacterWristSlotCooldown"] = true },
        ["CharacterHandsSlot"] = { ["CharacterHandsSlotCooldown"] = true },
        ["CharacterTabardSlot"] = { ["CharacterTabardSlotCooldown"] = true },
        ["CharacterSecondaryHandSlot"] = { ["CharacterSecondaryHandSlotCooldown"] = true },
        ["CharacterFinger1Slot"] = { ["CharacterFinger1SlotCooldown"] = true },
        ["CharacterWaistSlot"] = { ["CharacterWaistSlotCooldown"] = true },
        ["CharacterChestSlot"] = { ["CharacterChestSlotCooldown"] = true },
        ["CharacterNeckSlot"] = { ["CharacterNeckSlotCooldown"] = true },
        ["CharacterTrinket1Slot"] = { ["CharacterTrinket1SlotCooldown"] = true },
        ["CharacterTrinket0Slot"] = { ["CharacterTrinket0SlotCooldown"] = true },
    },
    CURSEFORGE_URL = "https://www.curseforge.com/wow/addons/minice-cooldown-styler",
    DEVELOPER_URL = "https://www.curseforge.com/members/anahkas/projects",
    MINICC_URL = "https://www.curseforge.com/wow/addons/minicc",
    SMART_PVP_TAB_TARGETING_URL = "https://www.curseforge.com/wow/addons/pvp-tab-targeting",
    FONT_OPTIONS_BASE = {
        ["GAMEDEFAULT"] = "Game Default",
        ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata",
        ["Fonts\\FRIZQT___CYR.TTF"] = "Friz Quadrata (Cyrillic)",
        ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
        ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
        ["Fonts\\skurri.ttf"] = "Skurri",
        ["Fonts\\2002.TTF"] = "2002",
        ["Interface\\AddOns\\MinimalistCooldownEdge\\Fonts\\expressway.ttf"] = "Expressway",
        ["Interface\\AddOns\\MinimalistCooldownEdge\\Fonts\\bazooka_regular.ttf"] = "Bazooka",
    },
    OUTLINE_OPTIONS = {
        ["NONE"] = L["None"],
        ["OUTLINE"] = L["Outline"],
        ["THICKOUTLINE"] = L["Thick"],
        ["MONOCHROME"] = L["Mono"],
    },
    ANCHOR_OPTIONS = {
        ["CENTER"] = L["Center"],
        ["TOPLEFT"] = L["Top Left"],
        ["TOPRIGHT"] = L["Top Right"],
        ["BOTTOMLEFT"] = L["Bottom Left"],
        ["BOTTOMRIGHT"] = L["Bottom Right"],
    },
}

MCE.Constants = Constants
MCE.CategoryDefaults = CategoryDefaults
MCE.DurationTextColorDefaults = DurationTextColorDefaults

local defaultDurationTextColors = DurationTextColorDefaults()

function MCE.EnsureDurationTextColorConfig(config)
    if type(config) ~= "table" then
        return CopyTable(defaultDurationTextColors)
    end

    if config.enabled == nil then
        config.enabled = defaultDurationTextColors.enabled
    end

    if type(config.offset) ~= "number" then
        config.offset = defaultDurationTextColors.offset
    end

    if type(config.thresholds) ~= "table" then
        config.thresholds = {}
    end

    for i = 1, #defaultDurationTextColors.thresholds do
        local defaultThreshold = defaultDurationTextColors.thresholds[i]
        local threshold = config.thresholds[i]

        if type(threshold) ~= "table" then
            config.thresholds[i] = CopyTable(defaultThreshold)
        else
            if threshold.threshold == nil then
                threshold.threshold = defaultThreshold.threshold
            end
            if type(threshold.color) ~= "table" then
                threshold.color = CopyTable(defaultThreshold.color)
            else
                threshold.color.r = threshold.color.r or defaultThreshold.color.r
                threshold.color.g = threshold.color.g or defaultThreshold.color.g
                threshold.color.b = threshold.color.b or defaultThreshold.color.b
                threshold.color.a = threshold.color.a or defaultThreshold.color.a
            end
        end
    end

    if type(config.defaultColor) ~= "table" then
        config.defaultColor = CopyTable(defaultDurationTextColors.defaultColor)
    else
        config.defaultColor.r = config.defaultColor.r or defaultDurationTextColors.defaultColor.r
        config.defaultColor.g = config.defaultColor.g or defaultDurationTextColors.defaultColor.g
        config.defaultColor.b = config.defaultColor.b or defaultDurationTextColors.defaultColor.b
        config.defaultColor.a = config.defaultColor.a or defaultDurationTextColors.defaultColor.a
    end

    return config
end

local actionbarDefaults = CategoryDefaults(true, 18)
actionbarDefaults.hideChargeTimers = true
actionbarDefaults.swipeAlpha = 80
actionbarDefaults.stackOffsetX = -3
actionbarDefaults.stackOffsetY = 3

local nameplateDefaults = CategoryDefaults(true, 12)
nameplateDefaults.stackSize = 8

local cooldownManagerDefaults = CategoryDefaults(false, 18)
cooldownManagerDefaults.essentialFontSize = cooldownManagerDefaults.fontSize
cooldownManagerDefaults.utilityFontSize = cooldownManagerDefaults.fontSize
cooldownManagerDefaults.buffIconFontSize = cooldownManagerDefaults.fontSize

local partyRaidFramesDefaults = CategoryDefaults(false, 12)
partyRaidFramesDefaults.enableForRaidOverFive = false

local miniCCDefaults = CategoryDefaults(false, 18)
miniCCDefaults.ccFontSize = 18
miniCCDefaults.ccHideCountdownNumbers = false
miniCCDefaults.nameplateFontSize = 12
miniCCDefaults.nameplateHideCountdownNumbers = false
miniCCDefaults.portraitFontSize = 18
miniCCDefaults.portraitHideCountdownNumbers = false
miniCCDefaults.overlayFontSize = 18
miniCCDefaults.overlayHideCountdownNumbers = false

MCE.defaults = {
    global = {
        versionAlertsShown = {},
    },
    profile = {
        abbrevThreshold = 90,
        durationTextColors = defaultDurationTextColors,
        categories = {
            actionbar = actionbarDefaults,
            nameplate = nameplateDefaults,
            unitframe = CategoryDefaults(false, 12),
            partyraidframes = partyRaidFramesDefaults,
            cooldownmanager = cooldownManagerDefaults,
            minicc = miniCCDefaults,
        },
    },
}
