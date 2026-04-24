-- HookBridge.lua – Cooldown metatable hooks
--
-- Installs permanent hooksecurefunc hooks on the Cooldown widget metatable.
-- Routes cooldown lifetime events to TargetRegistry, DurationColorController,
-- CompactGroupAuraController, and BatchProcessor.
-- Also installs enforcement hooks that prevent Blizzard from silently reverting
-- visual state (edge, swipe, hideNums) between style passes.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local HookBridge = MCE:NewModule("HookBridge")

local type, pcall, ipairs = type, pcall, ipairs
local strfind = string.find
local hooksecurefunc = hooksecurefunc
local GetTime = GetTime
local C_Timer_After = C_Timer.After
local CreateFrame = CreateFrame

local CATEGORY = C.Categories
local CLASSIFIER_CONSTANTS = C.Classifier
local STYLER_CONSTANTS = C.Styler
local AURA_RETRY_MIN_INTERVAL = STYLER_CONSTANTS.AuraRetryMinInterval or 0.25
local UNMANAGED_AURA_RETRY_INTERVAL = STYLER_CONSTANTS.UnmanagedAuraRetryInterval or (AURA_RETRY_MIN_INTERVAL * 4)
local BLACKLIST_NAME_CONTAINS = CLASSIFIER_CONSTANTS.BlacklistNameContains
local BLACKLIST_PARENT_NAMES = CLASSIFIER_CONSTANTS.BlacklistParentNames

local frameState = addon.frameState

local Registry, BatchProcessor, DurationColor

local hookBlacklistParentNameLookup = {}
for _, parentName in ipairs(BLACKLIST_PARENT_NAMES) do
    hookBlacklistParentNameLookup[parentName] = true
end

-- =========================================================================
-- SECRET / FORBIDDEN GUARDS
-- =========================================================================

local IsSecretValue = addon.IsSecretValue
local CanAccessAllValues = addon.CanAccessAllValues

local function IsRestrictedCooldown(cooldown)
    return not cooldown
       or IsSecretValue(cooldown)
       or not CanAccessAllValues(cooldown)
       or MCE:IsForbiddenCached(cooldown)
end

local function GetTrackedFrameState(cooldown)
    if not cooldown then
        return nil
    end

    return MCE:SafeTableGet(frameState, cooldown)
end

local function IsBlacklistAllowed(cooldown)
    local state = GetTrackedFrameState(cooldown)
    return state and state.allowBlacklisted == true or false
end

local function GetOrCreateTrackedFrameState(cooldown)
    local state = GetTrackedFrameState(cooldown)
    if state then
        return state
    end
    if not MCE:CanUseFrameAsTableKey(cooldown) then
        return nil
    end

    state = {}
    frameState[cooldown] = state
    return state
end

local function ClearUnmanagedAuraClaimRetry(cooldown)
    local state = GetTrackedFrameState(cooldown)
    if state then
        state.unmanagedAuraRetryAt = nil
    end
end

local function MarkUnmanagedAuraClaimRetry(cooldown, delay)
    local state = GetOrCreateTrackedFrameState(cooldown)
    if not state then
        return
    end

    state.unmanagedAuraRetryAt = GetTime() + (delay or UNMANAGED_AURA_RETRY_INTERVAL)
end

local function IsUnmanagedAuraClaimRetryPending(cooldown, now)
    local state = GetTrackedFrameState(cooldown)
    local retryAt = state and state.unmanagedAuraRetryAt or nil
    return type(retryAt) == "number" and retryAt > (now or GetTime())
end

-- =========================================================================
-- NUMERIC COMPARISON
-- =========================================================================

local IsNearlyEqual = addon.IsNearlyEqual
local IsSameSwipeColor = addon.IsSameSwipeColor

local function IsMasqueManagedCooldown(cooldown)
    if not cooldown
       or IsSecretValue(cooldown)
       or not CanAccessAllValues(cooldown)
       or MCE:IsForbiddenCached(cooldown) then
        return false
    end

    return cooldown._MSQ_Color ~= nil
end

local IsMUIStyledCooldown = addon.IsMUIStyledCooldown

local function IsLossOfControlCooldown(cooldown)
    return MCE:IsLossOfControlCooldownCached(cooldown)
end

-- =========================================================================
-- HOOK REGISTRATION
-- =========================================================================

local hooksInstalled = false
local cooldownHookAPI

local function EnsureDependencies()
    if not Registry then
        Registry = MCE:GetModule("TargetRegistry")
    end
    if not BatchProcessor then
        BatchProcessor = MCE:GetModule("BatchProcessor")
    end
    if not DurationColor then
        DurationColor = MCE:GetModule("DurationColorController")
    end

    return Registry ~= nil and BatchProcessor ~= nil and DurationColor ~= nil
end

local function GetCooldownHookAPI()
    if cooldownHookAPI then
        return cooldownHookAPI
    end

    if type(CreateFrame) ~= "function" then
        return nil
    end

    local probeCooldown = CreateFrame("Cooldown")
    if not probeCooldown then
        return nil
    end

    local probeMeta = getmetatable(probeCooldown)
    local api = probeMeta and probeMeta.__index or nil
    if type(api) ~= "table" then
        return nil
    end

    cooldownHookAPI = api
    return cooldownHookAPI
end

local VIEWER_TYPE = C.CooldownManagerViewers

local function IsAuraRetryCategory(category, cooldown)
    if category == CATEGORY.Nameplate
       or category == CATEGORY.Unitframe
       or category == CATEGORY.CompactPartyAura then
        return true
    end
    if category == CATEGORY.CooldownManager and Registry then
        return Registry:GetSubtype(cooldown) == VIEWER_TYPE.BuffIcon
    end
    return false
end

local function HasAuraLikeAncestor(cooldown)
    local current = cooldown and cooldown.GetParent and cooldown:GetParent() or nil
    for _ = 1, STYLER_CONSTANTS.MaxCooldownOwnerScanDepth do
        if not current then break end

        local name = MCE:GetFrameName(current) or ""
        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true)
           or current.auraInstanceID
           or current.auraDataInstanceID
           or current.auraInstanceId
           or current.auraDataInstanceId then
            return true
        end

        current = current.GetParent and current:GetParent() or nil
    end
    return false
end

local function HasHookBlacklistMatch(cooldown)
    if IsBlacklistAllowed(cooldown) then
        return false
    end

    local current = cooldown
    for _ = 1, STYLER_CONSTANTS.MaxCooldownOwnerScanDepth + 1 do
        if not current then break end
        if IsSecretValue(current) or not CanAccessAllValues(current) or MCE:IsForbiddenCached(current) then
            return true
        end

        local name = MCE:GetFrameName(current) or ""
        if name ~= "" then
            for i = 1, #BLACKLIST_NAME_CONTAINS do
                if strfind(name, BLACKLIST_NAME_CONTAINS[i], 1, true) then
                    return true
                end
            end

            if hookBlacklistParentNameLookup[name] then
                return true
            end
        end

        current = current.GetParent and current:GetParent() or nil
    end

    return false
end

local function ShouldIgnoreCooldown(cooldown)
    if IsRestrictedCooldown(cooldown) or IsLossOfControlCooldown(cooldown) then
        return true
    end

    return HasHookBlacklistMatch(cooldown)
end

local function TryRegisterUnknown(cooldown)
    if not EnsureDependencies() then
        return nil
    end
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end

    local category = Registry:GetCategory(cooldown)
    if category then
        ClearUnmanagedAuraClaimRetry(cooldown)
        return category
    end

    category = Registry:TryClaim(cooldown)
    if category then
        ClearUnmanagedAuraClaimRetry(cooldown)
    end
    return category
end

local function InvalidateResolvedFrameState(fs, refreshDuration)
    if not fs then
        return
    end

    if refreshDuration then
        fs.durationObject = nil
    end
    fs.forceTextRegionRefresh = true
    fs.appliedTextColor = nil
    fs.contextResolved = nil
    fs.liveNameplateAuraContextResolved = nil
    fs.liveNameplateAuraContext = nil
    fs.compactPartyAuraTypeResolved = nil
    fs.compactPartyAuraType = nil
    fs.isForbidden = nil
    fs.isLoC = nil
end

local function ScheduleAuraRetry(cooldown, wantsDurationRefresh)
    local fs = GetOrCreateTrackedFrameState(cooldown)
    if not fs then
        return
    end

    if wantsDurationRefresh then
        fs.pendingAuraDurationRefresh = true
    end
    if fs.pendingAuraRefresh then
        return
    end

    local now = GetTime()
    if type(fs.nextAuraRefreshAt) == "number" and fs.nextAuraRefreshAt > now then
        return
    end

    fs.nextAuraRefreshAt = now + AURA_RETRY_MIN_INTERVAL
    fs.pendingAuraRefresh = true

    C_Timer_After(0, function()
        if ShouldIgnoreCooldown(cooldown) then
            ClearUnmanagedAuraClaimRetry(cooldown)
            return
        end

        if not EnsureDependencies() then
            return
        end

        local fs2 = GetTrackedFrameState(cooldown)
        local refreshDuration = fs2 and fs2.pendingAuraDurationRefresh == true

        if fs2 then
            fs2.pendingAuraRefresh = nil
            fs2.pendingAuraDurationRefresh = nil
        end

        local retryCategory = Registry:GetCategory(cooldown)
        if not retryCategory then
            retryCategory = TryRegisterUnknown(cooldown)
        end

        if not retryCategory then
            MarkUnmanagedAuraClaimRetry(cooldown)
            return
        end

        InvalidateResolvedFrameState(fs2, refreshDuration)

        if refreshDuration then
            DurationColor:HandleCooldownDurationUpdate(cooldown, nil)
        end
        BatchProcessor:QueueUpdate(cooldown)
    end)
end

local function ProcessCooldownUpdate(cooldown, durationObject)
    if IsLossOfControlCooldown(cooldown) then
        ClearUnmanagedAuraClaimRetry(cooldown)
        return
    end

    if not EnsureDependencies() then
        return
    end

    local category = Registry:GetCategory(cooldown)
    if category then
        local fs = frameState[cooldown]
        if fs and fs.unmanagedAuraRetryAt then
            fs.unmanagedAuraRetryAt = nil
        end

        DurationColor:HandleCooldownDurationUpdate(cooldown, durationObject)
        BatchProcessor:QueueUpdate(cooldown)

        if IsAuraRetryCategory(category, cooldown) then
            ScheduleAuraRetry(cooldown, durationObject == nil or category == CATEGORY.Nameplate)
        end
        return
    end

    if IsRestrictedCooldown(cooldown) then
        return
    end

    local now = GetTime()
    if IsUnmanagedAuraClaimRetryPending(cooldown, now) then
        return
    end

    category = Registry:TryClaim(cooldown)
    if category then
        ClearUnmanagedAuraClaimRetry(cooldown)
        DurationColor:HandleCooldownDurationUpdate(cooldown, durationObject)
        BatchProcessor:QueueUpdate(cooldown)

        if IsAuraRetryCategory(category, cooldown) then
            ScheduleAuraRetry(cooldown, durationObject == nil or category == CATEGORY.Nameplate)
        end
        return
    end

    if HasHookBlacklistMatch(cooldown) then
        ClearUnmanagedAuraClaimRetry(cooldown)
        return
    end

    if not HasAuraLikeAncestor(cooldown) then
        ClearUnmanagedAuraClaimRetry(cooldown)
        return
    end

    MarkUnmanagedAuraClaimRetry(cooldown, UNMANAGED_AURA_RETRY_INTERVAL)
    ScheduleAuraRetry(cooldown, durationObject == nil)
end

local function ProcessCooldownClear(cooldown)
    if IsLossOfControlCooldown(cooldown) then
        ClearUnmanagedAuraClaimRetry(cooldown)
        if EnsureDependencies() then
            DurationColor:ClearTrackedDurationColor(cooldown)
        end
        return
    end

    if not EnsureDependencies() then
        return
    end

    if Registry:IsRegistered(cooldown) then
        ClearUnmanagedAuraClaimRetry(cooldown)
        DurationColor:ClearTrackedDurationColor(cooldown)
        return
    end

    if ShouldIgnoreCooldown(cooldown) then
        return
    end

    ClearUnmanagedAuraClaimRetry(cooldown)
    DurationColor:ClearTrackedDurationColor(cooldown)
end

function HookBridge:SetupHooks()
    if hooksInstalled then return end

    local cooldownAPI = GetCooldownHookAPI()
    if not cooldownAPI then return end

    -- =====================================================================
    -- COOLDOWN LIFETIME HOOKS
    -- =====================================================================

    if type(cooldownAPI.SetCooldown) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldown", function(cooldown, startTime, duration, modRate)
            if IsLossOfControlCooldown(cooldown) then
                ClearUnmanagedAuraClaimRetry(cooldown)
                return
            end
            if not EnsureDependencies() then
                return
            end
            local durationObject = DurationColor:CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
            ProcessCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.SetCooldownDuration) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldownDuration", function(cooldown, duration, modRate)
            if IsLossOfControlCooldown(cooldown) then
                ClearUnmanagedAuraClaimRetry(cooldown)
                return
            end
            if not EnsureDependencies() then
                return
            end
            local durationObject
            if CanAccessAllValues(duration, modRate)
               and type(duration) == "number"
               and duration > 0 then
                durationObject = DurationColor:CreateDurationFromEndTime(GetTime() + duration, duration, modRate or 1)
            end

            ProcessCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.SetCooldownFromDurationObject) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldownFromDurationObject", function(cooldown, durationObject)
            if IsLossOfControlCooldown(cooldown) then
                ClearUnmanagedAuraClaimRetry(cooldown)
                return
            end
            ProcessCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.SetCooldownFromExpirationTime) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldownFromExpirationTime", function(cooldown, expirationTime, duration, modRate)
            if IsLossOfControlCooldown(cooldown) then
                ClearUnmanagedAuraClaimRetry(cooldown)
                return
            end
            if not EnsureDependencies() then
                return
            end
            local durationObject = DurationColor:CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
            ProcessCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.Clear) == "function" then
        hooksecurefunc(cooldownAPI, "Clear", function(cooldown)
            if IsLossOfControlCooldown(cooldown) then
                ClearUnmanagedAuraClaimRetry(cooldown)
                if EnsureDependencies() then
                    DurationColor:ClearTrackedDurationColor(cooldown)
                end
                return
            end
            ProcessCooldownClear(cooldown)
        end)
    end

    -- =====================================================================
    -- ENFORCEMENT HOOKS
    -- Reordered: try the tracked frameState lookup first, which still lets
    -- unmanaged frames short-circuit quickly while safely ignoring secret
    -- cooldown objects that cannot be used as table keys.
    -- =====================================================================

    if type(cooldownAPI.SetDrawEdge) == "function" then
        hooksecurefunc(cooldownAPI, "SetDrawEdge", function(cooldown, enabled)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressEdge then return end
            if IsSecretValue(enabled) then return end
            if fs.edge == nil or fs.edge == enabled then return end
            fs.suppressEdge = true
            pcall(cooldown.SetDrawEdge, cooldown, fs.edge)
            fs.suppressEdge = nil
        end)
    end

    if type(cooldownAPI.SetEdgeScale) == "function" then
        hooksecurefunc(cooldownAPI, "SetEdgeScale", function(cooldown, scale)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressEdgeScale then return end
            if IsSecretValue(scale) then return end
            if fs.edgeScale == nil or IsNearlyEqual(fs.edgeScale, scale) then return end
            fs.suppressEdgeScale = true
            pcall(cooldown.SetEdgeScale, cooldown, fs.edgeScale)
            fs.suppressEdgeScale = nil
        end)
    end

    if type(cooldownAPI.SetEdgeColor) == "function" then
        hooksecurefunc(cooldownAPI, "SetEdgeColor", function(cooldown, r, g, b, a)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressEdgeColor then return end
            if IsSecretValue(r)
               or IsSecretValue(g)
               or IsSecretValue(b)
               or IsSecretValue(a) then
                return
            end
            if not fs.edgeColor or IsSameSwipeColor(fs.edgeColor, r, g, b, a) then return end
            fs.suppressEdgeColor = true
            pcall(cooldown.SetEdgeColor, cooldown, fs.edgeColor.r, fs.edgeColor.g, fs.edgeColor.b, fs.edgeColor.a)
            fs.suppressEdgeColor = nil
        end)
    end

    if type(cooldownAPI.SetSwipeColor) == "function" then
        hooksecurefunc(cooldownAPI, "SetSwipeColor", function(cooldown, r, g, b, a)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressSwipe then return end
            if IsMUIStyledCooldown(cooldown) then return end
            if IsMasqueManagedCooldown(cooldown) then return end
            -- Let BT4 cast VFX hide the swipe without triggering a revert loop.
            if fs.bt4Supported and type(a) == "number" and a == 0 then return end
            if IsSecretValue(r)
               or IsSecretValue(g)
               or IsSecretValue(b)
               or IsSecretValue(a) then
                return
            end
            if not fs.swipeColor or IsSameSwipeColor(fs.swipeColor, r, g, b, a) then return end
            fs.suppressSwipe = true
            pcall(cooldown.SetSwipeColor, cooldown, fs.swipeColor.r, fs.swipeColor.g, fs.swipeColor.b, fs.swipeColor.a)
            fs.suppressSwipe = nil
        end)
    end

    if type(cooldownAPI.SetHideCountdownNumbers) == "function" then
        hooksecurefunc(cooldownAPI, "SetHideCountdownNumbers", function(cooldown, hide)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressHideNums then return end
            -- hide can be a tainted boolean (MiniCE-written value flowing back through Blizzard);
            -- issecretvalue() does not detect taint, so wrap the comparison in pcall instead.
            local ok, shouldRestore = pcall(function() return fs.hideNums ~= nil and fs.hideNums ~= hide end)
            if not ok or not shouldRestore then return end
            fs.suppressHideNums = true
            pcall(cooldown.SetHideCountdownNumbers, cooldown, fs.hideNums)
            fs.suppressHideNums = nil
        end)
    end

    if type(cooldownAPI.SetCountdownAbbrevThreshold) == "function" then
        hooksecurefunc(cooldownAPI, "SetCountdownAbbrevThreshold", function(cooldown, seconds)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressCountdownAbbrevThreshold then return end
            local ok, shouldRestore = pcall(function()
                return fs.countdownAbbrevThreshold ~= nil and fs.countdownAbbrevThreshold ~= seconds
            end)
            if not ok or not shouldRestore then return end
            fs.suppressCountdownAbbrevThreshold = true
            pcall(cooldown.SetCountdownAbbrevThreshold, cooldown, fs.countdownAbbrevThreshold)
            fs.suppressCountdownAbbrevThreshold = nil
        end)
    end

    if type(cooldownAPI.SetCountdownMillisecondsThreshold) == "function" then
        hooksecurefunc(cooldownAPI, "SetCountdownMillisecondsThreshold", function(cooldown, seconds)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressCountdownMillisecondsThreshold then return end
            local ok, shouldRestore = pcall(function()
                return fs.countdownMillisecondsThreshold ~= nil and fs.countdownMillisecondsThreshold ~= seconds
            end)
            if not ok or not shouldRestore then return end
            fs.suppressCountdownMillisecondsThreshold = true
            pcall(cooldown.SetCountdownMillisecondsThreshold, cooldown, fs.countdownMillisecondsThreshold)
            fs.suppressCountdownMillisecondsThreshold = nil
        end)
    end

    if type(cooldownAPI.SetDrawSwipe) == "function" then
        hooksecurefunc(cooldownAPI, "SetDrawSwipe", function(cooldown, enabled)
            local fs = GetTrackedFrameState(cooldown)
            if not fs or fs.suppressSwipeDraw then return end
            -- enabled can be tainted for the same reason as hide above.
            local ok, shouldRestore = pcall(function() return fs.drawSwipe ~= nil and fs.drawSwipe ~= enabled end)
            if not ok or not shouldRestore then return end
            fs.suppressSwipeDraw = true
            pcall(cooldown.SetDrawSwipe, cooldown, fs.drawSwipe)
            fs.suppressSwipeDraw = nil
        end)
    end

    hooksInstalled = true
end

function HookBridge:HandleCooldownUpdate(cooldown, durationObject)
    ProcessCooldownUpdate(cooldown, durationObject)
end

function HookBridge:HandleCooldownClear(cooldown)
    ProcessCooldownClear(cooldown)
end

-- =========================================================================
-- LIFECYCLE
-- =========================================================================

function HookBridge:OnEnable()
    EnsureDependencies()
    self:SetupHooks()
end
