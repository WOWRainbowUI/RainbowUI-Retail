-- Core.lua – Addon skeleton, shared utilities, and database defaults

local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, C.Addon.AceName,
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(C.Addon.AceName)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- === UPVALUE LOCALS (Performance) ===
local pcall = pcall
local select = select
local tostring = tostring
local tconcat = table.concat
local C_Timer_NewTimer = C_Timer.NewTimer
local CHAT_PREFIX = C.Chat.Prefix
local OPTION_SLIDER_DEBOUNCE_DELAY = C.Options.SliderDebounceDelay

MCE.Constants = C

-- =========================================================================
-- SHARED UTILITIES  (used across all modules)
-- =========================================================================

--- Safe forbidden-frame check (pcall guards tainted frames).
--- Must use pcall because indexing a tainted frame itself throws.
--- Pre-defined helper avoids creating a closure on every call.
local function checkForbidden(frame)
    return frame:IsForbidden()
end

function MCE:IsForbidden(frame)
    if not frame then return true end
    local ok, val = pcall(checkForbidden, frame)
    return not ok or val
end

--- WoW API expects "" not "NONE" for font outline flags.
function MCE.NormalizeFontStyle(style)
    if not style or style == C.Style.FontStyles.None then return "" end
    return style
end

--- Resolves "GAMEDEFAULT" to WoW's native font path.
function MCE.ResolveFontPath(fontPath)
    if fontPath == C.Style.Fonts.GameDefault then
        return GameFontNormal:GetFont()
    end
    return fontPath
end

function MCE:IsMiniCCAvailable()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(C.Addon.MiniCCName) or false
end

local function BuildChatMessage(...)
    local count = select("#", ...)
    if count == 0 then
        return CHAT_PREFIX
    end

    local parts = {}
    for i = 1, count do
        parts[i] = tostring(select(i, ...))
    end

    return CHAT_PREFIX .. " " .. tconcat(parts, " ")
end

function MCE:Print(...)
    DEFAULT_CHAT_FRAME:AddMessage(BuildChatMessage(...))
end

-- =========================================================================
-- DATABASE DEFAULTS
-- =========================================================================

local function CategoryDefaults(enabled, fontSize)
    local defaults = C.Defaults.Category
    return {
        enabled = enabled,
        font = defaults.Font,
        fontSize = fontSize or defaults.FontSize,
        fontStyle = defaults.FontStyle,
        textColor = CopyTable(defaults.TextColor),
        textAnchor = defaults.TextAnchor,
        textOffsetX = defaults.TextOffsetX,
        textOffsetY = defaults.TextOffsetY,
        hideCountdownNumbers = defaults.HideCountdownNumbers,
        drawSwipe = defaults.DrawSwipe,
        edgeEnabled = defaults.EdgeEnabled,
        edgeScale = defaults.EdgeScale,
        stackEnabled = defaults.StackEnabled,
        hideStackText = defaults.HideStackText,
        stackFont = defaults.StackFont,
        stackSize = defaults.StackSize,
        stackStyle = defaults.StackStyle,
        stackColor = CopyTable(defaults.StackColor),
        stackAnchor = defaults.StackAnchor,
        stackOffsetX = defaults.StackOffsetX,
        stackOffsetY = defaults.StackOffsetY,
    }
end

local function DurationTextColorDefaults()
    local defaults = C.Defaults.DurationTextColors
    local thresholds = {}

    for i = 1, #defaults.Thresholds do
        thresholds[i] = {
            threshold = defaults.Thresholds[i].threshold,
            color = CopyTable(defaults.Thresholds[i].color),
        }
    end

    return {
        enabled = defaults.Enabled,
        offset = defaults.Offset,
        thresholds = thresholds,
        defaultColor = CopyTable(defaults.DefaultColor),
    }
end

local actionbarDefaults = CategoryDefaults(true, 18)
actionbarDefaults.hideChargeTimers = C.Defaults.Actionbar.HideChargeTimers
actionbarDefaults.swipeAlpha = C.Defaults.Actionbar.SwipeAlpha

local nameplateDefaults = CategoryDefaults(false, C.Defaults.Nameplate.FontSize)
nameplateDefaults.stackSize = C.Defaults.Nameplate.StackSize
nameplateDefaults.stackAnchor = C.Defaults.Nameplate.StackAnchor
nameplateDefaults.stackOffsetX = C.Defaults.Nameplate.StackOffsetX
nameplateDefaults.stackOffsetY = C.Defaults.Nameplate.StackOffsetY

local defaultDurationTextColors = DurationTextColorDefaults()
local compactPartyAuraTextDefaults

local function EnsureDurationTextColorConfig(config)
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

local function EnsureCompactPartyAuraTextConfig(config)
    if type(config) ~= "table" then
        return CopyTable(compactPartyAuraTextDefaults)
    end

    if config.enabled == nil then
        config.enabled = compactPartyAuraTextDefaults.enabled
    end
    if config.raidEnabled == nil then
        config.raidEnabled = compactPartyAuraTextDefaults.raidEnabled
    end
    if config.font == nil then
        config.font = compactPartyAuraTextDefaults.font
    end
    if type(config.fontSize) ~= "number" then
        config.fontSize = compactPartyAuraTextDefaults.fontSize
    end
    if type(config.defensiveBuffFontSize) ~= "number" then
        config.defensiveBuffFontSize = compactPartyAuraTextDefaults.defensiveBuffFontSize
    end
    if config.fontStyle == nil then
        config.fontStyle = compactPartyAuraTextDefaults.fontStyle
    end
    if config.textAnchor == nil then
        config.textAnchor = compactPartyAuraTextDefaults.textAnchor
    end
    if type(config.textOffsetX) ~= "number" then
        config.textOffsetX = compactPartyAuraTextDefaults.textOffsetX
    end
    if type(config.textOffsetY) ~= "number" then
        config.textOffsetY = compactPartyAuraTextDefaults.textOffsetY
    end

    if type(config.textColor) ~= "table" then
        config.textColor = CopyTable(compactPartyAuraTextDefaults.textColor)
    else
        local defaultColor = compactPartyAuraTextDefaults.textColor
        if config.textColor.r == nil then config.textColor.r = defaultColor.r end
        if config.textColor.g == nil then config.textColor.g = defaultColor.g end
        if config.textColor.b == nil then config.textColor.b = defaultColor.b end
        if config.textColor.a == nil then config.textColor.a = defaultColor.a end
    end

    return config
end

local function IsCompactPartyAuraConfigAtDefaults(config)
    if type(config) ~= "table" then
        return false
    end

    local defaults = compactPartyAuraTextDefaults
    local color = config.textColor
    local defaultColor = defaults.textColor

    return config.enabled == defaults.enabled
        and config.raidEnabled == defaults.raidEnabled
        and config.font == defaults.font
        and config.fontSize == defaults.fontSize
        and config.defensiveBuffFontSize == defaults.defensiveBuffFontSize
        and config.fontStyle == defaults.fontStyle
        and config.textAnchor == defaults.textAnchor
        and config.textOffsetX == defaults.textOffsetX
        and config.textOffsetY == defaults.textOffsetY
        and type(color) == "table"
        and color.r == defaultColor.r
        and color.g == defaultColor.g
        and color.b == defaultColor.b
        and color.a == defaultColor.a
end

local function MigrateLegacyPartyRaidFramesConfig(profile)
    local categories = type(profile.categories) == "table" and profile.categories or nil
    if not categories then
        return
    end

    local legacyCategory = rawget(categories, "partyraidframes")
        or rawget(categories, C.Categories.CompactPartyAura)
    if type(legacyCategory) ~= "table" then
        return
    end

    local explicitCompactConfig = rawget(profile, "compactPartyAuraText")
    local shouldMigrateLegacy = type(explicitCompactConfig) ~= "table"
    if not shouldMigrateLegacy and next(explicitCompactConfig) == nil then
        shouldMigrateLegacy = true
    end
    if not shouldMigrateLegacy and IsCompactPartyAuraConfigAtDefaults(EnsureCompactPartyAuraTextConfig(CopyTable(explicitCompactConfig))) then
        shouldMigrateLegacy = true
    end

    if shouldMigrateLegacy then
        explicitCompactConfig = {}
        profile.compactPartyAuraText = explicitCompactConfig

        if legacyCategory.enabled ~= nil then
            explicitCompactConfig.enabled = legacyCategory.enabled and true or false
        elseif legacyCategory.partyAuraTextEnabled ~= nil then
            explicitCompactConfig.enabled = legacyCategory.partyAuraTextEnabled and true or false
        end

        if legacyCategory.enableForRaidOverFive ~= nil then
            explicitCompactConfig.raidEnabled = legacyCategory.enableForRaidOverFive and true or false
        elseif legacyCategory.raidAuraTextEnabled ~= nil then
            explicitCompactConfig.raidEnabled = legacyCategory.raidAuraTextEnabled and true or false
        end

        if legacyCategory.font ~= nil then
            explicitCompactConfig.font = legacyCategory.font
        end
        if legacyCategory.fontSize ~= nil then
            explicitCompactConfig.fontSize = legacyCategory.fontSize
        end
        if legacyCategory.defensiveBuffFontSize ~= nil then
            explicitCompactConfig.defensiveBuffFontSize = legacyCategory.defensiveBuffFontSize
        end
        if legacyCategory.fontStyle ~= nil then
            explicitCompactConfig.fontStyle = legacyCategory.fontStyle
        end
        if type(legacyCategory.textColor) == "table" then
            explicitCompactConfig.textColor = CopyTable(legacyCategory.textColor)
        end
        if legacyCategory.textAnchor ~= nil then
            explicitCompactConfig.textAnchor = legacyCategory.textAnchor
        end
        if legacyCategory.textOffsetX ~= nil then
            explicitCompactConfig.textOffsetX = legacyCategory.textOffsetX
        end
        if legacyCategory.textOffsetY ~= nil then
            explicitCompactConfig.textOffsetY = legacyCategory.textOffsetY
        end
    end

    categories.partyraidframes = nil
    categories[C.Categories.CompactPartyAura] = nil
end

MCE.DurationTextColorDefaults = DurationTextColorDefaults
MCE.EnsureDurationTextColorConfig = EnsureDurationTextColorConfig
MCE.EnsureCompactPartyAuraTextConfig = EnsureCompactPartyAuraTextConfig

local cooldownManagerDefaults = CategoryDefaults(false, 18)
cooldownManagerDefaults.essentialFontSize = C.Defaults.CooldownManager.EssentialFontSize
cooldownManagerDefaults.utilityFontSize = C.Defaults.CooldownManager.UtilityFontSize
cooldownManagerDefaults.buffIconFontSize = C.Defaults.CooldownManager.BuffIconFontSize

local miniCCDefaults = CategoryDefaults(false, 18)
miniCCDefaults.ccFontSize = C.Defaults.MiniCC.CCFontSize
miniCCDefaults.ccHideCountdownNumbers = C.Defaults.MiniCC.CCHideCountdownNumbers
miniCCDefaults.nameplateFontSize = C.Defaults.MiniCC.NameplateFontSize
miniCCDefaults.nameplateHideCountdownNumbers = C.Defaults.MiniCC.NameplateHideCountdownNumbers
miniCCDefaults.portraitFontSize = C.Defaults.MiniCC.PortraitFontSize
miniCCDefaults.portraitHideCountdownNumbers = C.Defaults.MiniCC.PortraitHideCountdownNumbers
miniCCDefaults.overlayFontSize = C.Defaults.MiniCC.OverlayFontSize
miniCCDefaults.overlayHideCountdownNumbers = C.Defaults.MiniCC.OverlayHideCountdownNumbers

local compactPartyAuraDefaults = C.Defaults.CompactPartyAuraText
compactPartyAuraTextDefaults = {
    enabled = compactPartyAuraDefaults.Enabled,
    raidEnabled = compactPartyAuraDefaults.RaidEnabled,
    font = compactPartyAuraDefaults.Font,
    fontSize = compactPartyAuraDefaults.FontSize,
    defensiveBuffFontSize = compactPartyAuraDefaults.DefensiveBuffFontSize,
    fontStyle = compactPartyAuraDefaults.FontStyle,
    textColor = CopyTable(compactPartyAuraDefaults.TextColor),
    textAnchor = compactPartyAuraDefaults.TextAnchor,
    textOffsetX = compactPartyAuraDefaults.TextOffsetX,
    textOffsetY = compactPartyAuraDefaults.TextOffsetY,
}

MCE.defaults = {
    global = {
        versionAlertsShown = {},
    },
    profile = {
        abbrevThreshold = C.Options.DefaultAbbrevThreshold,
        compactPartyAuraText = compactPartyAuraTextDefaults,
        durationTextColors = defaultDurationTextColors,
        categories = {
            [C.Categories.Actionbar] = actionbarDefaults,
            [C.Categories.Nameplate] = nameplateDefaults,
            [C.Categories.Unitframe] = CategoryDefaults(false, 12),
            [C.Categories.CooldownManager] = cooldownManagerDefaults,
            [C.Categories.MiniCC] = miniCCDefaults,
            [C.Categories.Global] = CategoryDefaults(false, 18),
        },
    },
}

function MCE:UpgradeProfile()
    local profile = self.db and self.db.profile
    if not profile then return end

    MigrateLegacyPartyRaidFramesConfig(profile)

    if not profile.durationTextColors then
        local legacyConfig = profile.categories
            and profile.categories[C.Categories.Actionbar]
            and profile.categories[C.Categories.Actionbar].textColorByDuration

        if type(legacyConfig) == "table" then
            profile.durationTextColors = CopyTable(legacyConfig)
        else
            profile.durationTextColors = CopyTable(defaultDurationTextColors)
        end
    end

    EnsureDurationTextColorConfig(profile.durationTextColors)
    profile.compactPartyAuraText = EnsureCompactPartyAuraTextConfig(profile.compactPartyAuraText)
end

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(C.Addon.SavedVariables, self.defaults, true)
    self:UpgradeProfile()
    self.pendingOptionRefresh = nil
    self.pendingOptionRefreshFullScan = false

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)

    do
        local status = AceConfigDialog:GetStatusTable(addonName)
        status.width = math.max(status.width or 0, C.Options.FrameWidth)
        status.height = math.max(status.height or 0, C.Options.FrameHeight)
        status.groups = status.groups or {}
        status.groups.treewidth = math.max(status.groups.treewidth or 0, C.Options.TreeWidth)
        status.groups.treesizable = true
    end

    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, C.Addon.ShortName, nil, "general")
    AceConfigDialog:AddToBlizOptions(addonName, L["Action Bars"], C.Addon.ShortName, C.Categories.Actionbar)
    AceConfigDialog:AddToBlizOptions(addonName, L["Nameplates"], C.Addon.ShortName, C.Categories.Nameplate)
    AceConfigDialog:AddToBlizOptions(addonName, L["Unit Frames"], C.Addon.ShortName, C.Categories.Unitframe)
    AceConfigDialog:AddToBlizOptions(addonName, L["Party / Raid Frames"], C.Addon.ShortName, C.Categories.CompactPartyAura)
    AceConfigDialog:AddToBlizOptions(addonName, L["CooldownManager"], C.Addon.ShortName, C.Categories.CooldownManager)
    AceConfigDialog:AddToBlizOptions(addonName, L["MiniCC"], C.Addon.ShortName, C.Categories.MiniCC)
    AceConfigDialog:AddToBlizOptions(addonName, L["Others"], C.Addon.ShortName, C.Categories.Global)
    AceConfigDialog:AddToBlizOptions(addonName, L["Help & Support"], C.Addon.ShortName, "help")
    AceConfigDialog:AddToBlizOptions(addonName, L["Profiles"], C.Addon.ShortName, "profiles")

    for i = 1, #C.Addon.SlashCommands do
        self:RegisterChatCommand(C.Addon.SlashCommands[i], "SlashCommand")
    end
end

function MCE:OnDisable()
    self:CancelDebouncedOptionRefresh()
end

function MCE:SlashCommand(input)
    if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[addonName] then
        AceConfigDialog:Close(addonName)
        return
    end

    AceConfigDialog:Open(addonName)
end

--- Public API – delegates to Styler module.
function MCE:CancelDebouncedOptionRefresh()
    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
        self.pendingOptionRefresh = nil
    end

    self.pendingOptionRefreshFullScan = false
end

function MCE:RequestDebouncedOptionRefresh(fullScan, delay)
    self.pendingOptionRefreshFullScan = self.pendingOptionRefreshFullScan or fullScan or false

    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
    end

    self.pendingOptionRefresh = C_Timer_NewTimer(delay or OPTION_SLIDER_DEBOUNCE_DELAY, function()
        local needsFullScan = self.pendingOptionRefreshFullScan
        self.pendingOptionRefresh = nil
        self.pendingOptionRefreshFullScan = false
        self:ForceUpdateAll(needsFullScan)
    end)
end

function MCE:ForceUpdateAll(fullScan)
    self:CancelDebouncedOptionRefresh()
    self:GetModule("Styler"):ForceUpdateAll(fullScan)
end
