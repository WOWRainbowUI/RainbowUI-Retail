-- Core.lua – Addon skeleton, shared utilities, and database defaults

local addonName, addon = ...
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, "MinimalistCooldownEdge",
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- === UPVALUE LOCALS (Performance) ===
local pcall = pcall
local InCombatLockdown = InCombatLockdown
local select = select
local tostring = tostring
local tconcat = table.concat
local C_Timer_NewTimer = C_Timer.NewTimer
local CHAT_PREFIX = "|cff00ccffMiniCE|r"
local OPTION_SLIDER_DEBOUNCE_DELAY = 0.15

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
    if not style or style == "NONE" then return "" end
    return style
end

--- Resolves "GAMEDEFAULT" to WoW's native font path.
function MCE.ResolveFontPath(fontPath)
    if fontPath == "GAMEDEFAULT" then
        return GameFontNormal:GetFont()
    end
    return fontPath
end

function MCE:IsMiniCCAvailable()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("MiniCC") or false
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
    return {
        enabled = enabled,
        font = "GAMEDEFAULT", fontSize = fontSize or 18, fontStyle = "OUTLINE",
        textColor = { r = 1, g = 0.8, b = 0, a = 1 },
        textAnchor = "CENTER", textOffsetX = 0, textOffsetY = 0,
        hideCountdownNumbers = false,
        edgeEnabled = true, edgeScale = 1.4,
        stackEnabled = true,
        stackFont = "GAMEDEFAULT", stackSize = 16, stackStyle = "OUTLINE",
        stackColor = { r = 1, g = 1, b = 1, a = 1 },
        stackAnchor = "BOTTOMRIGHT", stackOffsetX = -3, stackOffsetY = 3,
    }
end

local function DurationTextColorDefaults()
    return {
        enabled = true,
        thresholds = {
            { threshold = 5,    color = { r = 1.0, g = 0.0,  b = 0.0,  a = 1.0 } },
            { threshold = 60,   color = { r = 1.0, g = 0.8,  b = 0.0,  a = 1.0 } },
            { threshold = 3600, color = { r = 1.0, g = 1.0,  b = 1.0,  a = 1.0 } },
        },
        defaultColor = { r = 0.67, g = 0.67, b = 0.67, a = 1.0 },
    }
end

local actionbarDefaults = CategoryDefaults(true, 18)

local defaultDurationTextColors = DurationTextColorDefaults()

local function EnsureDurationTextColorConfig(config)
    if type(config) ~= "table" then
        return CopyTable(defaultDurationTextColors)
    end

    if config.enabled == nil then
        config.enabled = defaultDurationTextColors.enabled
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

MCE.DurationTextColorDefaults = DurationTextColorDefaults
MCE.EnsureDurationTextColorConfig = EnsureDurationTextColorConfig

local cooldownManagerDefaults = CategoryDefaults(false, 18)
cooldownManagerDefaults.essentialFontSize = cooldownManagerDefaults.fontSize
cooldownManagerDefaults.utilityFontSize = cooldownManagerDefaults.fontSize
cooldownManagerDefaults.buffIconFontSize = cooldownManagerDefaults.fontSize

local miniCCDefaults = CategoryDefaults(false, 18)
miniCCDefaults.ccFontSize = 18
miniCCDefaults.ccHideCountdownNumbers = false
miniCCDefaults.nameplateFontSize = 12
miniCCDefaults.nameplateHideCountdownNumbers = false
miniCCDefaults.portraitFontSize = 18
miniCCDefaults.portraitHideCountdownNumbers = false
miniCCDefaults.overlayFontSize = 18
miniCCDefaults.overlayHideCountdownNumbers = false

local compactPartyAuraTextDefaults = {
    enabled = false,
    raidEnabled = false,
    font = "GAMEDEFAULT", fontSize = 12, fontStyle = "OUTLINE",
    textColor = { r = 1, g = 0.8, b = 0, a = 1 },
    textAnchor = "CENTER", textOffsetX = 0, textOffsetY = 0,
}

MCE.defaults = {
    global = {
        versionAlertsShown = {},
    },
    profile = {
        compactPartyAuraText = compactPartyAuraTextDefaults,
        durationTextColors = defaultDurationTextColors,
        categories = {
            actionbar       = actionbarDefaults,
            nameplate       = CategoryDefaults(false, 12),
            unitframe       = CategoryDefaults(false, 12),
            cooldownmanager = cooldownManagerDefaults,
            minicc          = miniCCDefaults,
            global          = CategoryDefaults(false, 18),
        },
    },
}

function MCE:UpgradeProfile()
    local profile = self.db and self.db.profile
    if not profile then return end

    if not profile.durationTextColors then
        local legacyConfig = profile.categories
            and profile.categories.actionbar
            and profile.categories.actionbar.textColorByDuration

        if type(legacyConfig) == "table" then
            profile.durationTextColors = CopyTable(legacyConfig)
        else
            profile.durationTextColors = CopyTable(defaultDurationTextColors)
        end
    end

    EnsureDurationTextColorConfig(profile.durationTextColors)
end

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MinimalistCooldownEdgeDB_v2", self.defaults, true)
    self:UpgradeProfile()
    self.pendingOptionRefresh = nil
    self.pendingOptionRefreshFullScan = false

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)

    do
        local status = AceConfigDialog:GetStatusTable(addonName)
        status.width = math.max(status.width or 0, 900)
        status.height = math.max(status.height or 0, 600)
        status.groups = status.groups or {}
        status.groups.treewidth = math.max(status.groups.treewidth or 0, 210)
        status.groups.treesizable = true
    end

    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, addonName)

    self:RegisterChatCommand("mce", "SlashCommand")
    self:RegisterChatCommand("minice", "SlashCommand")
    self:RegisterChatCommand("minimalistcooldownedge", "SlashCommand")
end

function MCE:OnDisable()
    self:CancelDebouncedOptionRefresh()
end

function MCE:SlashCommand(input)
    if InCombatLockdown() then
        self:Print(L["Cannot open options in combat."])
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
