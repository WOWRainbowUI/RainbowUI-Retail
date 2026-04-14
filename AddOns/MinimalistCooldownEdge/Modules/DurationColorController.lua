-- DurationColorController.lua – Duration-based text color theming
--
-- Owns the color curve, per-frame duration tracking, ticker loop,
-- and all DurationObject caching. StyleEngine delegates duration
-- color updates here.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local DurationColor = MCE:NewModule("DurationColorController")

local pairs, type, pcall, wipe = pairs, type, pcall, wipe
local setmetatable = setmetatable
local strfind, strlower = string.find, string.lower
local GetTime = GetTime
local C_Timer_After = C_Timer.After
local issecretvalue = issecretvalue or function() return false end

local CATEGORY = C.Categories
local VIEWER_TYPE = C.CooldownManagerViewers
local STYLER_CONSTANTS = C.Styler
local CLASSIFIER_CONSTANTS = C.Classifier
local weakMeta = addon.weakMeta
local frameState = addon.frameState

-- Module references (lazy)
local StyleEngine, Registry, CompactAura

function DurationColor:OnEnable()
    StyleEngine = MCE:GetModule("StyleEngine")
    Registry = MCE:GetModule("TargetRegistry")
    CompactAura = MCE:GetModule("CompactGroupAuraController")
end

-- =========================================================================
-- STATE
-- =========================================================================

local durationColoredFrames = setmetatable({}, weakMeta)
local activeDurationFrames  = setmetatable({}, weakMeta)
local hookedCooldowns       = setmetatable({}, weakMeta)
local activeDurationFrameCount = 0
local durationCacheSweepCounter = 0
local durationColorTicker = nil
local durationColorCurve = nil

local durationObjectCache = setmetatable({}, {
    __call = function(self, endTime, duration, modRate)
        if type(endTime) ~= "number" or type(duration) ~= "number" then return nil end
        local key = endTime .. ":" .. duration .. ":" .. (modRate or 1)
        local cached = self[key]
        if not cached then
            if not (C_DurationUtil and C_DurationUtil.CreateDuration) then return nil end
            cached = C_DurationUtil.CreateDuration()
            self[key] = cached
        end
        if not (cached and cached.SetTimeFromEnd) then return nil end
        cached:SetTimeFromEnd(endTime, duration, modRate or 1)
        return cached
    end
})

-- =========================================================================
-- TICKER CONTROL
-- =========================================================================

local function StopTicker()
    if durationColorTicker then
        durationColorTicker:Cancel()
        durationColorTicker = nil
    end
    durationCacheSweepCounter = 0
end

local function AddActiveDurationFrame(cdFrame)
    if not cdFrame or activeDurationFrames[cdFrame] then return end
    activeDurationFrames[cdFrame] = true
    activeDurationFrameCount = activeDurationFrameCount + 1
end

local function RemoveActiveDurationFrame(cdFrame)
    if not activeDurationFrames[cdFrame] then return end
    activeDurationFrames[cdFrame] = nil
    if activeDurationFrameCount > 0 then
        activeDurationFrameCount = activeDurationFrameCount - 1
    end
end

-- =========================================================================
-- LIFECYCLE HOOKS (per-cooldown show/hide/done)
-- =========================================================================

local StartTicker  -- forward ref

local function OnTrackedCooldownShow(cooldown)
    if not cooldown or StyleEngine.IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
    if durationColoredFrames[cooldown] then
        AddActiveDurationFrame(cooldown)
        StartTicker()
    end
end

local function OnTrackedCooldownHide(cooldown)
    if not cooldown or StyleEngine.IsSecretValue(cooldown) then return end
    RemoveActiveDurationFrame(cooldown)
    if activeDurationFrameCount == 0 then StopTicker() end
end

local function OnTrackedCooldownDone(cooldown)
    if not cooldown or StyleEngine.IsSecretValue(cooldown) then return end
    DurationColor:ClearTrackedDurationColor(cooldown)
end

function DurationColor:EnsureCooldownLifecycleHooks(cooldown)
    if not cooldown or hookedCooldowns[cooldown] or type(cooldown.HookScript) ~= "function" then
        return
    end
    cooldown:HookScript(STYLER_CONSTANTS.CooldownLifecycleEvents.OnShow, OnTrackedCooldownShow)
    cooldown:HookScript(STYLER_CONSTANTS.CooldownLifecycleEvents.OnHide, OnTrackedCooldownHide)
    cooldown:HookScript(STYLER_CONSTANTS.CooldownLifecycleEvents.OnDone, OnTrackedCooldownDone)
    hookedCooldowns[cooldown] = true
end

-- =========================================================================
-- DURATION OBJECT MANAGEMENT
-- =========================================================================

function DurationColor:CreateDurationFromEndTime(endTime, duration, modRate)
    return durationObjectCache(endTime, duration, modRate or 1)
end

function DurationColor:CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
    if not StyleEngine.CanAccessAllValues(startTime, duration, modRate) then return nil end
    if type(startTime) ~= "number" or type(duration) ~= "number" then return nil end
    return self:CreateDurationFromEndTime(startTime + duration, duration, modRate or 1)
end

function DurationColor:CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
    if not StyleEngine.CanAccessAllValues(expirationTime, duration, modRate) then return nil end
    return self:CreateDurationFromEndTime(expirationTime, duration, modRate or 1)
end

local function getDurationEvaluate(obj)
    return obj.EvaluateRemainingDuration
end

local function IsSupportedDurationObject(durationObject)
    local dt = type(durationObject)
    if dt ~= "table" and dt ~= "userdata" then return false end
    local ok, fn = pcall(getDurationEvaluate, durationObject)
    return ok and type(fn) == "function"
end

function DurationColor:SetCooldownDurationObject(cdFrame, durationObject)
    if not cdFrame or StyleEngine.IsSecretValue(cdFrame) then return end
    if durationObject and (StyleEngine.IsSecretValue(durationObject) or not StyleEngine.CanAccessAllValues(durationObject)) then
        durationObject = nil
    end
    if durationObject and not IsSupportedDurationObject(durationObject) then
        durationObject = nil
    end
    if not durationObject then
        durationObject = self:GetFallbackDurationObject(cdFrame)
    end
    local fs = frameState[cdFrame]
    if durationObject then
        if not fs then fs = StyleEngine:GetFrameState(cdFrame) end
        fs.durationObject = durationObject
    elseif fs then
        fs.durationObject = nil
    end
end

function DurationColor:GetFallbackDurationObject(cdFrame, forceContextRefresh)
    local parent = cdFrame and cdFrame.GetParent and cdFrame:GetParent()
    if not parent then return nil end

    local fs = StyleEngine:ResolveCooldownContext(cdFrame, forceContextRefresh == true)
    local category = Registry and Registry:GetCategory(cdFrame)
    local actionButton = fs.actionButton ~= false and fs.actionButton or parent
    local actionID = fs.actionID ~= false and fs.actionID or StyleEngine:GetActionIDFromButton(actionButton)

    if actionID and C_ActionBar then
        if StyleEngine:IsChargeCooldownFrame(cdFrame, actionButton) and C_ActionBar.GetActionChargeDuration then
            local ok, obj = pcall(C_ActionBar.GetActionChargeDuration, actionID)
            if ok and obj then return obj end
        end
        if C_ActionBar.GetActionCooldownDuration then
            local ok, obj = pcall(C_ActionBar.GetActionCooldownDuration, actionID)
            if ok and obj then return obj end
        end
    end

    local shouldUseAura = self:ShouldUseAuraDurationFallback(cdFrame, category)
    if shouldUseAura then
        local auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
        local unitOwner = fs.auraUnitOwner ~= false and fs.auraUnitOwner or nil
        local auraInstanceID = auraOwner and StyleEngine:GetFrameAuraInstanceID(auraOwner)
        local unitToken = unitOwner and StyleEngine:GetFrameUnitToken(unitOwner)
        -- CooldownManager always tracks the player's own auras; default to
        -- "player" when the icon frame hierarchy exposes no unitToken.
        if not unitToken and category == CATEGORY.CooldownManager then
            unitToken = "player"
        end
        if auraInstanceID and unitToken and C_UnitAuras and C_UnitAuras.GetAuraDuration then
            local ok, obj = pcall(C_UnitAuras.GetAuraDuration, unitToken, auraInstanceID)
            if ok and obj then return obj end
        end

        -- Aura-driven displays should wait for aura data rather than falling
        -- back to a spell cooldown, which can incorrectly push them into the
        -- shortest threshold band.
        if category == CATEGORY.CooldownManager or self:IsAuraDrivenCooldown(cdFrame, category) then
            return nil
        end
    end

    local spellOwner = (fs.spellOwner ~= false and fs.spellOwner) or actionButton or parent
    local spellID = StyleEngine:GetCooldownSpellID(spellOwner)
    if spellID and C_Spell then
        local useChargeDuration = StyleEngine:IsChargeCooldownFrame(cdFrame, spellOwner or parent)
        if not useChargeDuration and category == CATEGORY.CooldownManager then
            useChargeDuration = StyleEngine:IsCooldownManagerChargeDisplay(cdFrame, parent)
        end

        if useChargeDuration and C_Spell.GetSpellChargeDuration then
            local ok, obj = pcall(C_Spell.GetSpellChargeDuration, spellID)
            if ok and obj then return obj end
        end
        if C_Spell.GetSpellCooldownDuration then
            local ok, obj = pcall(C_Spell.GetSpellCooldownDuration, spellID)
            if ok and obj then return obj end
        end
    end

    return nil
end

function DurationColor:ShouldUseAuraDurationFallback(cdFrame, category)
    if not category then
        category = Registry and Registry:GetCategory(cdFrame)
    end
    if category == CATEGORY.Actionbar or category == CATEGORY.MiniCC then return false end
    if category == CATEGORY.CooldownManager then
        local subtype = Registry and Registry:GetSubtype(cdFrame)
        return subtype == VIEWER_TYPE.BuffIcon
    end
    if category == CATEGORY.Nameplate or category == CATEGORY.Unitframe then return true end
    local fs = frameState[cdFrame]
    return fs and fs.hasAuraNamedAncestor == true
end

function DurationColor:IsAuraDrivenCooldown(cdFrame, category)
    if not self:ShouldUseAuraDurationFallback(cdFrame, category) then return false end
    local fs = StyleEngine:ResolveCooldownContext(cdFrame)
    local auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
    local unitOwner = fs.auraUnitOwner ~= false and fs.auraUnitOwner or nil
    if auraOwner and unitOwner then
        local auraID = StyleEngine:GetFrameAuraInstanceID(auraOwner)
        local unitToken = StyleEngine:GetFrameUnitToken(unitOwner)
        if auraID and unitToken then return true end
    end
    return fs.hasAuraNamedAncestor == true
end

local function GetStoredDurationObject(cdFrame, allowFallback)
    local fs = frameState[cdFrame]
    if fs and fs.durationObject then return fs.durationObject end
    if allowFallback == false then return nil end
    local obj = DurationColor:GetFallbackDurationObject(cdFrame)
    if obj then DurationColor:SetCooldownDurationObject(cdFrame, obj) end
    return obj
end

local function GetCooldownDurationObject(cdFrame, sourceKey)
    if sourceKey == CATEGORY.Actionbar then
        local current = DurationColor:GetFallbackDurationObject(cdFrame, true)
        if current then return current end
        return GetStoredDurationObject(cdFrame, false)
    end
    if sourceKey == CATEGORY.Nameplate then       
        local current = DurationColor:GetFallbackDurationObject(cdFrame, true)
        if current then
            DurationColor:SetCooldownDurationObject(cdFrame, current)
            return current
        end
        return nil
    end
    return GetStoredDurationObject(cdFrame, true)
end

-- =========================================================================
-- COLOR CURVE
-- =========================================================================

local function BuildColorCurve(durationConfig)
    local thresholds = durationConfig.thresholds
    if not thresholds or #thresholds == 0 then return nil end
    local sorted = {}
    for i = 1, #thresholds do sorted[i] = thresholds[i] end
    table.sort(sorted, function(a, b) return (a.threshold or 0) < (b.threshold or 0) end)

    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)

    local c1 = sorted[1].color
    curve:AddPoint(0, CreateColor(c1.r, c1.g, c1.b, c1.a or 1))

    local offset = type(durationConfig.offset) == "number" and durationConfig.offset or 0
    for i = 2, #sorted do
        local startAt = (sorted[i - 1].threshold or 0) + offset
        if startAt < 0 then startAt = 0 end
        local c = sorted[i].color
        curve:AddPoint(startAt, CreateColor(c.r, c.g, c.b, c.a or 1))
    end

    if durationConfig.defaultColor then
        local startAt = (sorted[#sorted].threshold or 0) + offset
        if startAt < 0 then startAt = 0 end
        local dc = durationConfig.defaultColor
        curve:AddPoint(startAt, CreateColor(dc.r, dc.g, dc.b, dc.a or 1))
    end

    return curve
end

function DurationColor:InvalidateColorCurve()
    durationColorCurve = nil
end

local function GetDurationTextColorsConfig()
    local profile = MCE.db and MCE.db.profile
    if not profile then return nil end
    return profile.durationTextColors
end

local function GetColorCurve()
    if durationColorCurve then return durationColorCurve end
    local config = GetDurationTextColorsConfig()
    if not config or not config.enabled then return nil end
    durationColorCurve = BuildColorCurve(config)
    return durationColorCurve
end

-- =========================================================================
-- SOURCE CONFIG RESOLUTION
-- =========================================================================

local function GetDurationTextSourceConfig(sourceKey)
    if sourceKey == CATEGORY.CompactPartyAura then
        if CompactAura and CompactAura.GetConfig then
            return CompactAura:GetConfig()
        end
        return nil
    end
    local categories = MCE.db and MCE.db.profile and MCE.db.profile.categories
    return categories and categories[sourceKey] or nil
end

local function IsThresholdColorAllowedForSource(sourceKey, config)
    if not config then return false end
    if config.allowThresholdColors ~= nil then
        return config.allowThresholdColors == true
    end
    local defaults = C.Defaults and C.Defaults.AllowThresholdColorsByCategory
    return defaults and defaults[sourceKey] == true or false
end

local function ContainsNameplatePattern(value)
    for i = 1, #CLASSIFIER_CONSTANTS.NameplatePatterns do
        if strfind(value, CLASSIFIER_CONSTANTS.NameplatePatterns[i], 1, true) then return true end
    end
    return false
end

local function IsLiveNameplateAuraContext(cdFrame)
    local fs = frameState[cdFrame]
    if fs and fs.liveNameplateAuraContextResolved then
        return fs.liveNameplateAuraContext == true
    end

    local resolved = StyleEngine:ResolveCooldownContext(cdFrame)
    if not (resolved and (resolved.hasAuraNamedAncestor or resolved.auraInstanceOwner ~= false)) then
        fs = fs or resolved or StyleEngine:GetFrameState(cdFrame)
        fs.liveNameplateAuraContextResolved = true
        fs.liveNameplateAuraContext = false
        return false
    end

    local current = cdFrame and cdFrame.GetParent and cdFrame:GetParent() or nil
    local depth = 0
    local sawAuraContext = false
    while current and current ~= UIParent and depth < CLASSIFIER_CONSTANTS.ScanDepth do
        depth = depth + 1
        if not sawAuraContext then
            local name = current.GetName and current:GetName() or ""
            if type(name) == "string"
               and (strfind(name, "Buff", 1, true) or strfind(name, "Debuff", 1, true) or strfind(name, "Aura", 1, true)) then
                sawAuraContext = true
            elseif StyleEngine:GetFrameAuraInstanceID(current) ~= nil then
                sawAuraContext = true
            end
        end
        if sawAuraContext then
            local objType = current.GetObjectType and current:GetObjectType() or nil
            if objType == CLASSIFIER_CONSTANTS.NameplateObjectType then
                fs = fs or resolved or StyleEngine:GetFrameState(cdFrame)
                fs.liveNameplateAuraContextResolved = true
                fs.liveNameplateAuraContext = true
                return true
            end
            local name = current.GetName and current:GetName() or ""
            if type(name) == "string" and name ~= "" then
                if ContainsNameplatePattern(strlower(name)) then
                    fs = fs or resolved or StyleEngine:GetFrameState(cdFrame)
                    fs.liveNameplateAuraContextResolved = true
                    fs.liveNameplateAuraContext = true
                    return true
                end
            end
            local unitToken = StyleEngine:GetFrameUnitToken(current)
            if type(unitToken) == "string"
               and strfind(strlower(unitToken), CLASSIFIER_CONSTANTS.NameplatePatterns[1], 1, true) then
                fs = fs or resolved or StyleEngine:GetFrameState(cdFrame)
                fs.liveNameplateAuraContextResolved = true
                fs.liveNameplateAuraContext = true
                return true
            end
        end
        current = current.GetParent and current:GetParent() or nil
    end

    fs = fs or resolved or StyleEngine:GetFrameState(cdFrame)
    fs.liveNameplateAuraContextResolved = true
    fs.liveNameplateAuraContext = false
    return false
end

local function ShouldSuppressDurationColorsForNameplate(cdFrame, sourceKey)
    if sourceKey == CATEGORY.Nameplate or sourceKey == CATEGORY.Actionbar
       or sourceKey == CATEGORY.CooldownManager or sourceKey == CATEGORY.MiniCC then
        return false
    end
    return IsLiveNameplateAuraContext(cdFrame)
end

local function GetDurationResetConfig(cdFrame, sourceKey, config)
    if not ShouldSuppressDurationColorsForNameplate(cdFrame, sourceKey) then return config end
    local categories = MCE.db and MCE.db.profile and MCE.db.profile.categories
    return categories and categories[CATEGORY.Nameplate] or config
end

local function GetStateOverrideTextColor(cdFrame, sourceKey, config)
    if sourceKey ~= CATEGORY.CooldownManager or not config then
        return nil
    end

    if not StyleEngine:IsCooldownManagerAuraDisplay(cdFrame) then
        return nil
    end

    if config.auraColorEnabled == false then
        return config.textColor
    end

    return config.auraColor or config.textColor
end

local function IsDurationColorEnabledForSource(cdFrame, sourceKey, config)
    local durationConfig = GetDurationTextColorsConfig()
    if not durationConfig or not durationConfig.enabled or not config then return false end
    if sourceKey == CATEGORY.SArena then
        return false
    end
    if ShouldSuppressDurationColorsForNameplate(cdFrame, sourceKey) then return false end
    if sourceKey == CATEGORY.CompactPartyAura then
        if CompactAura then
            local frameType = CompactAura:GetCompactPartyAuraFrameType(cdFrame)
            local compactConfig = CompactAura:GetConfig() or config
            return frameType
                and CompactAura:ShouldUseCompactPartyAuraText(compactConfig, frameType)
                and IsThresholdColorAllowedForSource(sourceKey, compactConfig) or false
        end
        return false
    end
    return config.enabled == true and IsThresholdColorAllowedForSource(sourceKey, config)
end

-- =========================================================================
-- COLOR APPLICATION
-- =========================================================================

local function ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve)
    if not cdFrame or MCE:IsForbidden(cdFrame) then return false end
    if cdFrame.IsShown and not cdFrame:IsShown() then return false end

    local textRegions, textRegionCount = StyleEngine:GetCachedCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    local duration = GetCooldownDurationObject(cdFrame, sourceKey)
    if not duration then
        StyleEngine:ResetCountdownTextColor(cdFrame, config)
        return false
    end

    local ok, evalFn = pcall(getDurationEvaluate, duration)
    if not ok or type(evalFn) ~= "function" then
        StyleEngine:ResetCountdownTextColor(cdFrame, config)
        return false
    end

    local colorOk, color = pcall(evalFn, duration, curve)
    if colorOk and color then
        local r, g, b, a = color:GetRGBA()
        return StyleEngine:ApplyRGBAColorToCooldownRegions(cdFrame, r, g, b, a)
    end

    StyleEngine:ResetCountdownTextColor(cdFrame, config)
    return false
end

-- =========================================================================
-- PUBLIC API
-- =========================================================================

function DurationColor:IsTracked(cdFrame)
    return durationColoredFrames[cdFrame] ~= nil
end

function DurationColor:ClearTrackedDurationColor(cdFrame)
    local trackedSource = durationColoredFrames[cdFrame]
    local wasActive = activeDurationFrames[cdFrame] == true
    local fs = frameState[cdFrame]
    local hadDurationObject = fs and fs.durationObject ~= nil
    local hadAppliedTextColor = fs and fs.appliedTextColor ~= nil

    if not trackedSource and not wasActive and not hadDurationObject and not hadAppliedTextColor then
        return false
    end

    RemoveActiveDurationFrame(cdFrame)
    durationColoredFrames[cdFrame] = nil
    if fs then
        fs.durationObject = nil
        fs.appliedTextColor = nil
    end
    if activeDurationFrameCount == 0 then StopTicker() end
    return true
end

function DurationColor:RefreshTrackedDurationColor(cdFrame, sourceKey, config)
    local overrideColor = GetStateOverrideTextColor(cdFrame, sourceKey, config)
    if overrideColor then
        self:ClearTrackedDurationColor(cdFrame)
        return StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, overrideColor)
    end

    if not IsDurationColorEnabledForSource(cdFrame, sourceKey, config) then
        self:ClearTrackedDurationColor(cdFrame)
        StyleEngine:ResetCountdownTextColor(cdFrame, GetDurationResetConfig(cdFrame, sourceKey, config))
        return false
    end

    local curve = GetColorCurve()
    if curve and ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve) then
        self:EnsureCooldownLifecycleHooks(cdFrame)
        durationColoredFrames[cdFrame] = sourceKey
        if cdFrame.IsVisible and cdFrame:IsVisible() then
            AddActiveDurationFrame(cdFrame)
            StartTicker()
        else
            RemoveActiveDurationFrame(cdFrame)
        end
        return true
    end

    self:ClearTrackedDurationColor(cdFrame)
    StyleEngine:ResetCountdownTextColor(cdFrame, GetDurationResetConfig(cdFrame, sourceKey, config))
    return false
end

-- =========================================================================
-- TICKER
-- =========================================================================

local function PurgeExpiredDurationObjects()
    for key, obj in pairs(durationObjectCache) do
        if obj and obj.IsZero and obj:IsZero() then
            durationObjectCache[key] = nil
        end
    end
end

local function UpdateDurationColors()
    local curve = GetColorCurve()
    if not curve then
        local clearList
        for cdFrame, sourceKey in pairs(durationColoredFrames) do
            local config = GetDurationTextSourceConfig(sourceKey)
            local overrideColor = GetStateOverrideTextColor(cdFrame, sourceKey, config)
            if overrideColor then
                StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, overrideColor)
            else
                StyleEngine:ResetCountdownTextColor(cdFrame, GetDurationResetConfig(cdFrame, sourceKey, config))
            end
            clearList = clearList or {}
            clearList[#clearList + 1] = cdFrame
        end
        if clearList then
            for i = 1, #clearList do
                DurationColor:ClearTrackedDurationColor(clearList[i])
            end
        end
        StopTicker()
        return
    end

    durationCacheSweepCounter = durationCacheSweepCounter + 1
    if durationCacheSweepCounter >= STYLER_CONSTANTS.DurationCacheSweepThreshold then
        durationCacheSweepCounter = 0
        PurgeExpiredDurationObjects()
    end

    local activeCount = 0
    local clearList
    for cdFrame in pairs(activeDurationFrames) do
        local sourceKey = durationColoredFrames[cdFrame]
        if not sourceKey then
            RemoveActiveDurationFrame(cdFrame)
        else
            local config = GetDurationTextSourceConfig(sourceKey)
            local overrideColor = GetStateOverrideTextColor(cdFrame, sourceKey, config)
            if overrideColor then
                StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, overrideColor)
                clearList = clearList or {}
                clearList[#clearList + 1] = cdFrame
            elseif cdFrame and not MCE:IsForbidden(cdFrame)
               and IsDurationColorEnabledForSource(cdFrame, sourceKey, config)
               and ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve) then
                activeCount = activeCount + 1
            else
                if config then
                    StyleEngine:ResetCountdownTextColor(cdFrame, GetDurationResetConfig(cdFrame, sourceKey, config))
                end
                DurationColor:ClearTrackedDurationColor(cdFrame)
            end
        end
    end

    if clearList then
        for i = 1, #clearList do
            DurationColor:ClearTrackedDurationColor(clearList[i])
        end
    end

    if activeCount == 0 then StopTicker() end
end

StartTicker = function()
    if durationColorTicker then return end
    durationColorTicker = C_Timer.NewTicker(STYLER_CONSTANTS.DurationColorTickerInterval, UpdateDurationColors)
end

-- =========================================================================
-- HOOK HANDLER (called from HookBridge)
-- =========================================================================

function DurationColor:HandleCooldownDurationUpdate(cooldown, durationObject)
    if not cooldown or MCE:IsForbidden(cooldown) or StyleEngine.IsSecretValue(cooldown) then return end

    -- Action bars re-fetch live duration data, so avoid extra validation work.
    local category = Registry and Registry:GetCategory(cooldown)
    if category == CATEGORY.Actionbar then
        local sourceKey = durationColoredFrames[cooldown]
        if not sourceKey then return end
        local fs = frameState[cooldown]
        if fs then fs.appliedTextColor = nil end
        local curve = GetColorCurve()
        local config = GetDurationTextSourceConfig(sourceKey)
        if curve and IsDurationColorEnabledForSource(cooldown, sourceKey, config) then
            ApplyCooldownDurationColor(cooldown, sourceKey, config, curve)
        else
            if config then
                StyleEngine:ResetCountdownTextColor(cooldown, GetDurationResetConfig(cooldown, sourceKey, config))
            end
            self:ClearTrackedDurationColor(cooldown)
        end
        return
    end

    self:SetCooldownDurationObject(cooldown, durationObject)

    local fs = frameState[cooldown]
    if fs then fs.appliedTextColor = nil end

    local sourceKey = durationColoredFrames[cooldown]
    if sourceKey then
        local curve = GetColorCurve()
        local config = GetDurationTextSourceConfig(sourceKey)
        local overrideColor = GetStateOverrideTextColor(cooldown, sourceKey, config)
        if overrideColor then
            StyleEngine:ApplyTextColorToCooldownRegions(cooldown, overrideColor)
            self:ClearTrackedDurationColor(cooldown)
        elseif curve and IsDurationColorEnabledForSource(cooldown, sourceKey, config) then
            ApplyCooldownDurationColor(cooldown, sourceKey, config, curve)
        else
            if config then
                StyleEngine:ResetCountdownTextColor(cooldown, GetDurationResetConfig(cooldown, sourceKey, config))
            end
            self:ClearTrackedDurationColor(cooldown)
        end
    end
end

-- =========================================================================
-- RESET
-- =========================================================================

function DurationColor:Reset()
    StopTicker()
    wipe(durationColoredFrames)
    wipe(activeDurationFrames)
    activeDurationFrameCount = 0
    wipe(durationObjectCache)
    self:InvalidateColorCurve()
end
