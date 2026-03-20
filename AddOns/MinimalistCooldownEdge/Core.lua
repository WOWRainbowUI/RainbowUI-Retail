-- Core.lua – addon bootstrap and Ace lifecycle

local addonName, addon = ...
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, "MinimalistCooldownEdge",
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local select = select
local tostring = tostring
local type = type
local tconcat = table.concat
local pairs = pairs
local C_Timer_NewTimer = C_Timer.NewTimer

local function BuildChatMessage(...)
    local prefix = (MCE.Constants and MCE.Constants.CHAT_PREFIX) or "|cff00ccffMiniCE|r"
    local count = select("#", ...)
    if count == 0 then
        return prefix
    end

    local parts = {}
    for i = 1, count do
        parts[i] = tostring(select(i, ...))
    end

    return prefix .. " " .. tconcat(parts, " ")
end

function MCE:Print(...)
    DEFAULT_CHAT_FRAME:AddMessage(BuildChatMessage(...))
end

function MCE:UpgradeProfile()
    local profile = self.db and self.db.profile
    if not profile then return end

    profile.categories = profile.categories or {}
    profile.categories.global = nil

    local actionbarCategory = profile.categories.actionbar
    local legacyConfig = actionbarCategory and actionbarCategory.textColorByDuration

    if not profile.durationTextColors then
        if type(legacyConfig) == "table" then
            profile.durationTextColors = CopyTable(legacyConfig)
        else
            profile.durationTextColors = CopyTable(self.DurationTextColorDefaults())
        end
    end

    if actionbarCategory then
        actionbarCategory.textColorByDuration = nil
    end

    local categoryDefaults = self.defaults and self.defaults.profile and self.defaults.profile.categories or nil
    local partyRaidDefaults = categoryDefaults and categoryDefaults.partyraidframes or nil
    local unitframeCategory = profile.categories.unitframe
    local partyRaidCategory = rawget(profile.categories, "partyraidframes")
    local legacyCompactAuraText = type(rawget(profile, "compactPartyAuraText")) == "table" and profile.compactPartyAuraText or nil

    if not partyRaidCategory then
        if type(unitframeCategory) == "table" then
            partyRaidCategory = CopyTable(unitframeCategory)
        elseif type(partyRaidDefaults) == "table" then
            partyRaidCategory = CopyTable(partyRaidDefaults)
        else
            partyRaidCategory = {}
        end
        profile.categories.partyraidframes = partyRaidCategory
    end

    if type(partyRaidDefaults) == "table" then
        if partyRaidCategory.enableForRaidOverFive == nil then
            partyRaidCategory.enableForRaidOverFive = partyRaidDefaults.enableForRaidOverFive
        end
    end

    if legacyCompactAuraText then
        if partyRaidCategory.enabled == nil or partyRaidCategory.enabled == (partyRaidDefaults and partyRaidDefaults.enabled) then
            partyRaidCategory.enabled = (unitframeCategory and unitframeCategory.enabled)
                or legacyCompactAuraText.enabled
                or legacyCompactAuraText.raidEnabled
                or false
        end

        if legacyCompactAuraText.raidEnabled ~= nil then
            partyRaidCategory.enableForRaidOverFive = legacyCompactAuraText.raidEnabled and true or false
        end

        if legacyCompactAuraText.font then
            partyRaidCategory.font = legacyCompactAuraText.font
        end
        if legacyCompactAuraText.fontSize then
            partyRaidCategory.fontSize = legacyCompactAuraText.fontSize
        end
        if legacyCompactAuraText.fontStyle then
            partyRaidCategory.fontStyle = legacyCompactAuraText.fontStyle
        end
        if type(legacyCompactAuraText.textColor) == "table" then
            partyRaidCategory.textColor = CopyTable(legacyCompactAuraText.textColor)
        end
        if legacyCompactAuraText.textAnchor then
            partyRaidCategory.textAnchor = legacyCompactAuraText.textAnchor
        end
        if legacyCompactAuraText.textOffsetX ~= nil then
            partyRaidCategory.textOffsetX = legacyCompactAuraText.textOffsetX
        end
        if legacyCompactAuraText.textOffsetY ~= nil then
            partyRaidCategory.textOffsetY = legacyCompactAuraText.textOffsetY
        end

        profile.compactPartyAuraText = nil
    end

    if partyRaidCategory.enableForRaidOverFive == nil and partyRaidCategory.raidAuraTextEnabled ~= nil then
        partyRaidCategory.enableForRaidOverFive = partyRaidCategory.raidAuraTextEnabled and true or false
    end

    partyRaidCategory.partyAuraTextEnabled = nil
    partyRaidCategory.raidAuraTextEnabled = nil

    self.EnsureDurationTextColorConfig(profile.durationTextColors)
end

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MinimalistCooldownEdgeDB_v2", self.defaults, true)
    self:UpgradeProfile()
    self.pendingOptionRefresh = nil
    self.pendingOptionRefreshRequest = nil

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)

    do
        local status = AceConfigDialog:GetStatusTable(addonName)
        status.width = math.max(status.width or 0, 900)
        status.height = math.max(status.height or 0, 600)
        status.groups = status.groups or {}
        status.groups.treewidth = math.max(status.groups.treewidth or 0, 210)
        status.groups.treesizable = true
    end

    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, L["MinimalistCooldownEdge"], nil, "general")
    AceConfigDialog:AddToBlizOptions(addonName, L["Action Bars"], L["MinimalistCooldownEdge"], "actionbar")
    AceConfigDialog:AddToBlizOptions(addonName, L["Nameplates"], L["MinimalistCooldownEdge"], "nameplate")
    AceConfigDialog:AddToBlizOptions(addonName, L["Unit Frames"], L["MinimalistCooldownEdge"], "unitframe")
    AceConfigDialog:AddToBlizOptions(addonName, L["Party / Raid Frames"], L["MinimalistCooldownEdge"], "partyraidframes")
    AceConfigDialog:AddToBlizOptions(addonName, L["CooldownManager"], L["MinimalistCooldownEdge"], "cooldownmanager")
    AceConfigDialog:AddToBlizOptions(addonName, L["MiniCC"], L["MinimalistCooldownEdge"], "minicc")
    AceConfigDialog:AddToBlizOptions(addonName, L["Help & Support"], L["MinimalistCooldownEdge"], "help")
    AceConfigDialog:AddToBlizOptions(addonName, L["Profiles"], L["MinimalistCooldownEdge"], "profiles")

    self:RegisterChatCommand("mce", "SlashCommand")
    self:RegisterChatCommand("minice", "SlashCommand")
    self:RegisterChatCommand("minimalistcooldownedge", "SlashCommand")
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

    self.pendingOptionRefreshRequest = nil
end

local function NormalizeRefreshSelection(selection)
    if not selection then
        return nil
    end

    if selection == true or selection == "all" then
        return "all"
    end

    if type(selection) == "string" then
        return { [selection] = true }
    end

    if type(selection) ~= "table" then
        return nil
    end

    local normalized = {}
    local hasEntries = false

    for key, value in pairs(selection) do
        local category = nil

        if type(key) == "number" then
            category = value
        elseif value then
            category = key
        end

        if type(category) == "string" then
            normalized[category] = true
            hasEntries = true
        end
    end

    return hasEntries and normalized or nil
end

local function MergeRefreshSelection(existing, incoming)
    local left = NormalizeRefreshSelection(existing)
    local right = NormalizeRefreshSelection(incoming)

    if left == "all" or right == "all" then
        return "all"
    end

    if not left then
        return right
    end

    if not right then
        return left
    end

    local merged = {}
    for category in pairs(left) do
        merged[category] = true
    end
    for category in pairs(right) do
        merged[category] = true
    end

    return merged
end

local function NormalizeRefreshRequest(request)
    if request == true then
        return true
    end

    if request == nil or request == false then
        return {
            visuals = "all",
            invalidateColorCurve = true,
        }
    end

    return {
        discovery = request.discovery or false,
        classification = request.classification or false,
        visuals = request.visuals ~= nil and request.visuals or false,
        invalidateColorCurve = request.invalidateColorCurve == true,
        resetScheduler = request.resetScheduler == true,
        wipeClassifierCache = request.wipeClassifierCache == true,
    }
end

local function MergeRefreshRequests(existing, incoming)
    local left = NormalizeRefreshRequest(existing)
    local right = NormalizeRefreshRequest(incoming)

    if left == true or right == true then
        return true
    end

    return {
        discovery = MergeRefreshSelection(left.discovery, right.discovery) or false,
        classification = MergeRefreshSelection(left.classification, right.classification) or false,
        visuals = MergeRefreshSelection(left.visuals, right.visuals) or false,
        invalidateColorCurve = left.invalidateColorCurve or right.invalidateColorCurve,
        resetScheduler = left.resetScheduler or right.resetScheduler,
        wipeClassifierCache = left.wipeClassifierCache or right.wipeClassifierCache,
    }
end

function MCE:RequestDebouncedOptionRefresh(request, delay)
    self.pendingOptionRefreshRequest = MergeRefreshRequests(self.pendingOptionRefreshRequest, request)

    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
    end

    local refreshDelay = delay
        or (self.Constants and self.Constants.OPTION_SLIDER_DEBOUNCE_DELAY)
        or 0.15

    self.pendingOptionRefresh = C_Timer_NewTimer(refreshDelay, function()
        local pendingRequest = self.pendingOptionRefreshRequest
        self.pendingOptionRefresh = nil
        self.pendingOptionRefreshRequest = nil
        self:ForceUpdateAll(pendingRequest)
    end)
end

function MCE:ForceUpdateAll(refreshRequest)
    self:CancelDebouncedOptionRefresh()
    self:GetModule("Styler"):ForceUpdateAll(refreshRequest)
end
