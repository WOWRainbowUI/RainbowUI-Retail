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

local type, pcall = type, pcall
local math_abs = math.abs
local strfind = string.find
local hooksecurefunc = hooksecurefunc
local GetTime = GetTime
local C_Timer_After = C_Timer.After
local issecretvalue = issecretvalue or function() return false end
local canaccessallvalues = canaccessallvalues

local CATEGORY = C.Categories
local STYLER_CONSTANTS = C.Styler
local AURA_RETRY_MIN_INTERVAL = STYLER_CONSTANTS.AuraRetryMinInterval or 0.25

local frameState = addon.frameState

local Registry, BatchProcessor, DurationColor

-- =========================================================================
-- SECRET / FORBIDDEN GUARDS
-- =========================================================================

local function IsSecretValue(value)
    if not issecretvalue then return false end
    local ok, result = pcall(issecretvalue, value)
    return ok and result or false
end

local function CanAccessAllValues(...)
    if not canaccessallvalues then return true end
    local ok, result = pcall(canaccessallvalues, ...)
    return ok and result or false
end

-- =========================================================================
-- NUMERIC COMPARISON
-- =========================================================================

local EPSILON = STYLER_CONSTANTS.NumericComparisonEpsilon

local function IsNearlyEqual(a, b)
    if issecretvalue(a) or issecretvalue(b) then return false end
    if a == b then return true end
    if type(a) ~= "number" or type(b) ~= "number" then return false end
    return math_abs(a - b) < EPSILON
end

local function IsSameSwipeColor(state, r, g, b, a)
    return state
       and IsNearlyEqual(state.r, r)
       and IsNearlyEqual(state.g, g)
       and IsNearlyEqual(state.b, b)
       and IsNearlyEqual(state.a, a)
end

-- =========================================================================
-- HOOK REGISTRATION
-- =========================================================================

local hooksInstalled = false

local function IsAuraRetryCategory(category)
    return category == CATEGORY.Nameplate
        or category == CATEGORY.Unitframe
        or category == CATEGORY.CompactPartyAura
end

local function HasAuraLikeAncestor(cooldown)
    local current = cooldown and cooldown.GetParent and cooldown:GetParent() or nil
    for _ = 1, STYLER_CONSTANTS.MaxCooldownOwnerScanDepth do
        if not current then break end

        local name = current.GetName and current:GetName() or ""
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

local function TryRegisterUnknown(cooldown)
    if Registry:IsRegistered(cooldown) then return end
    -- Only adapters can register cooldowns; unsupported frames are silently ignored
    local category = Registry:TryClaim(cooldown)
    if category then
        BatchProcessor:QueueUpdate(cooldown)
    end
end

function HookBridge:SetupHooks()
    if hooksInstalled then return end

    -- Aura-driven cooldowns can finish constructing their countdown text after
    -- the first cooldown setter runs. Queue one deferred follow-up pass so
    -- nameplate aura styling wins on the first visible application. If the
    -- initial hook also lacked duration data, rebuild that in the same retry.
    local function MaybeRetryAuraRefresh(cooldown, durationObject)
        local category = Registry:GetCategory(cooldown)
        if category then
            if not IsAuraRetryCategory(category) then return end
        elseif not HasAuraLikeAncestor(cooldown) then
            return
        end

        local fs = frameState[cooldown]
        if not fs then
            fs = {}
            frameState[cooldown] = fs
        end

        if durationObject == nil or category == CATEGORY.Nameplate then
            fs.pendingAuraDurationRefresh = true
        end
        if fs.pendingAuraRefresh then return end

        local now = GetTime()
        if type(fs.nextAuraRefreshAt) == "number" and fs.nextAuraRefreshAt > now then return end
        fs.nextAuraRefreshAt = now + AURA_RETRY_MIN_INTERVAL
        fs.pendingAuraRefresh = true
        C_Timer_After(0, function()
            if not cooldown or MCE:IsForbidden(cooldown) then return end
            local fs2 = frameState[cooldown]
            local refreshDuration = fs2 and fs2.pendingAuraDurationRefresh == true
            if fs2 then
                fs2.pendingAuraRefresh = nil
                fs2.pendingAuraDurationRefresh = nil
                if refreshDuration then
                    fs2.durationObject = nil
                end
                fs2.forceTextRegionRefresh = true
                fs2.appliedTextColor = nil
                fs2.contextResolved = nil
                fs2.liveNameplateAuraContextResolved = nil
                fs2.liveNameplateAuraContext = nil
                fs2.compactPartyAuraTypeResolved = nil
                fs2.compactPartyAuraType = nil
            end
            if refreshDuration then
                DurationColor:HandleCooldownDurationUpdate(cooldown, nil)
            end
            TryRegisterUnknown(cooldown)
            BatchProcessor:QueueUpdate(cooldown)
        end)
    end

    local function HandleCooldownUpdate(cooldown, durationObject)
        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
        TryRegisterUnknown(cooldown)
        DurationColor:HandleCooldownDurationUpdate(cooldown, durationObject)
        BatchProcessor:QueueUpdate(cooldown)
        MaybeRetryAuraRefresh(cooldown, durationObject)
    end

    local sampleCooldown = ActionButton1Cooldown
        or (ActionButton1 and (ActionButton1.cooldown or ActionButton1.Cooldown))

    if not sampleCooldown then return end

    local cooldownAPI = getmetatable(sampleCooldown)
    cooldownAPI = cooldownAPI and cooldownAPI.__index or sampleCooldown

    if type(cooldownAPI) ~= "table" then return end

    -- =====================================================================
    -- COOLDOWN LIFETIME HOOKS
    -- =====================================================================

    if type(cooldownAPI.SetCooldown) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldown", function(cooldown, startTime, duration, modRate)
            local durationObject = DurationColor:CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
            HandleCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.SetCooldownDuration) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldownDuration", function(cooldown, duration, modRate)
            local durationObject
            if CanAccessAllValues(duration, modRate)
               and type(duration) == "number"
               and duration > 0 then
                durationObject = DurationColor:CreateDurationFromEndTime(GetTime() + duration, duration, modRate or 1)
            end

            HandleCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.SetCooldownFromDurationObject) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldownFromDurationObject", function(cooldown, durationObject)
            HandleCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.SetCooldownFromExpirationTime) == "function" then
        hooksecurefunc(cooldownAPI, "SetCooldownFromExpirationTime", function(cooldown, expirationTime, duration, modRate)
            local durationObject = DurationColor:CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
            HandleCooldownUpdate(cooldown, durationObject)
        end)
    end

    if type(cooldownAPI.Clear) == "function" then
        hooksecurefunc(cooldownAPI, "Clear", function(cooldown)
            if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
            DurationColor:ClearTrackedDurationColor(cooldown)
        end)
    end

    -- =====================================================================
    -- ENFORCEMENT HOOKS
    -- =====================================================================

    if type(cooldownAPI.SetDrawEdge) == "function" then
        hooksecurefunc(cooldownAPI, "SetDrawEdge", function(cooldown, enabled)
            if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
            if IsSecretValue(enabled) then return end
            local fs = frameState[cooldown]
            if not fs or fs.suppressEdge then return end
            if fs.edge ~= nil and fs.edge ~= enabled then
                fs.suppressEdge = true
                pcall(cooldown.SetDrawEdge, cooldown, fs.edge)
                fs.suppressEdge = nil
            end
        end)
    end

    if type(cooldownAPI.SetEdgeScale) == "function" then
        hooksecurefunc(cooldownAPI, "SetEdgeScale", function(cooldown, scale)
            if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
            if IsSecretValue(scale) then return end
            local fs = frameState[cooldown]
            if not fs or fs.suppressEdgeScale then return end
            if fs.edgeScale ~= nil and not IsNearlyEqual(fs.edgeScale, scale) then
                fs.suppressEdgeScale = true
                pcall(cooldown.SetEdgeScale, cooldown, fs.edgeScale)
                fs.suppressEdgeScale = nil
            end
        end)
    end

    if type(cooldownAPI.SetSwipeColor) == "function" then
        hooksecurefunc(cooldownAPI, "SetSwipeColor", function(cooldown, r, g, b, a)
            if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
            if IsSecretValue(r) or IsSecretValue(g) or IsSecretValue(b) or IsSecretValue(a) then return end
            local fs = frameState[cooldown]
            if not fs or fs.suppressSwipe then return end
            if fs.swipeColor and not IsSameSwipeColor(fs.swipeColor, r, g, b, a) then
                fs.suppressSwipe = true
                pcall(cooldown.SetSwipeColor, cooldown, fs.swipeColor.r, fs.swipeColor.g, fs.swipeColor.b, fs.swipeColor.a)
                fs.suppressSwipe = nil
            end
        end)
    end

    if type(cooldownAPI.SetHideCountdownNumbers) == "function" then
        hooksecurefunc(cooldownAPI, "SetHideCountdownNumbers", function(cooldown, hide)
            if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
            if IsSecretValue(hide) then return end
            local fs = frameState[cooldown]
            if not fs or fs.suppressHideNums then return end
            if fs.hideNums ~= nil and fs.hideNums ~= hide then
                fs.suppressHideNums = true
                pcall(cooldown.SetHideCountdownNumbers, cooldown, fs.hideNums)
                fs.suppressHideNums = nil
            end
        end)
    end

    if type(cooldownAPI.SetDrawSwipe) == "function" then
        hooksecurefunc(cooldownAPI, "SetDrawSwipe", function(cooldown, enabled)
            if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
            if IsSecretValue(enabled) then return end
            local fs = frameState[cooldown]
            if not fs or fs.suppressSwipeDraw then return end
            if fs.drawSwipe ~= nil and fs.drawSwipe ~= enabled then
                fs.suppressSwipeDraw = true
                pcall(cooldown.SetDrawSwipe, cooldown, fs.drawSwipe)
                fs.suppressSwipeDraw = nil
            end
        end)
    end

    hooksInstalled = true
end

-- =========================================================================
-- LIFECYCLE
-- =========================================================================

function HookBridge:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    BatchProcessor = MCE:GetModule("BatchProcessor")
    DurationColor = MCE:GetModule("DurationColorController")

    self:SetupHooks()
end
