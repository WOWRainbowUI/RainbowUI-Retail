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
local floor, max = math.floor, math.max
local GetTime = GetTime
local NewTicker = addon.NewTicker
local GetParentSafe = addon.GetParentSafe

local issecretvalue = issecretvalue

local CATEGORY = C.Categories
local VIEWER_TYPE = C.CooldownManagerViewers
local STYLER_CONSTANTS = C.Styler
local CLASSIFIER_CONSTANTS = C.Classifier
local weakMeta = addon.weakMeta
local frameState = addon.frameState

-- Module references (lazy)
local StyleEngine, Registry

function DurationColor:OnEnable()
    StyleEngine = MCE:GetModule("StyleEngine")
    Registry = MCE:GetModule("TargetRegistry")
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
local clearListScratch = {}  -- reusable scratch table for ticker clear passes
local nativeDurationFormatters = {}
local nativeFlatColorCurves = {}

local durationObjectCache = {}
local durationObjectCacheCount = 0

-- The cache is fed only by owned, active cooldowns that need setter duration
-- capture. Purging is still self-driven because future end-time buckets can
-- outlive a duration-color tracking phase.
local function PurgeExpiredDurationObjects()
    local now = GetTime()
    local remaining = 0
    for endTime in pairs(durationObjectCache) do
        -- endTime is an absolute timestamp; entries past it are expired
        if endTime <= now then
            durationObjectCache[endTime] = nil
        else
            remaining = remaining + 1
        end
    end

    -- Still saturated means the buckets are mostly future end times, which no
    -- sweep can reclaim. Drop them wholesale: the cache only deduplicates, and
    -- objects already bound to a cooldown stay referenced by that cooldown.
    if remaining >= STYLER_CONSTANTS.DurationCacheMaxEntries then
        wipe(durationObjectCache)
        remaining = 0
    end

    durationObjectCacheCount = remaining
end

local function GetOrCreateDurationObject(endTime, duration, modRate)
    if type(endTime) ~= "number" or type(duration) ~= "number" or duration <= 0 then return nil end
    modRate = modRate or 1

    local byEnd = durationObjectCache[endTime]
    if not byEnd then
        if durationObjectCacheCount >= STYLER_CONSTANTS.DurationCacheMaxEntries then
            PurgeExpiredDurationObjects()
            byEnd = durationObjectCache[endTime]
        end
        if not byEnd then
            byEnd = {}
            durationObjectCache[endTime] = byEnd
            durationObjectCacheCount = durationObjectCacheCount + 1
        end
    end

    local byDur = byEnd[duration]
    if not byDur then
        byDur = {}
        byEnd[duration] = byDur
    end

    local cached = byDur[modRate]
    if not cached then
        cached = C_DurationUtil.CreateDuration()
        byDur[modRate] = cached
    end

    if not (cached and cached.SetTimeFromEnd) then return nil end
    cached:SetTimeFromEnd(endTime, duration, modRate)
    return cached
end

-- GetTime()-derived end times are unique per call, so caching them can never
-- hit. Hand back a plain object the garbage collector can reclaim instead.
local function CreateUncachedDurationObject(endTime, duration, modRate)
    if type(endTime) ~= "number" or type(duration) ~= "number" or duration <= 0 then return nil end

    local object = C_DurationUtil.CreateDuration()
    if not (object and object.SetTimeFromEnd) then return nil end

    object:SetTimeFromEnd(endTime, duration, modRate or 1)
    return object
end

-- =========================================================================
-- TICKER CONTROL
-- =========================================================================

local function StopTicker()
    if durationColorTicker then
        durationColorTicker:Cancel()
        durationColorTicker = nil
    end
    durationCacheSweepCounter = 0
    -- The periodic sweep only runs while the ticker is alive; purge here so
    -- expired entries don't accumulate between tracking phases.
    PurgeExpiredDurationObjects()
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
    if not cooldown or StyleEngine.IsSecretValue(cooldown) or MCE:IsForbiddenCached(cooldown) then return end
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

    local state = frameState[cooldown]
    if state and state.unitFrameCustomAura == true then
        -- SetDurationCooldown owns the cooldown's secret Shown aspect. Its
        -- Duration updates and Clear calls already arrive through HookBridge;
        -- do not attach tainted visibility scripts to that secret aspect.
        hookedCooldowns[cooldown] = true
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
    return GetOrCreateDurationObject(endTime, duration, modRate or 1)
end

-- For end times derived from GetTime(): unique per call, so never cached.
function DurationColor:CreateTransientDuration(endTime, duration, modRate)
    return CreateUncachedDurationObject(endTime, duration, modRate or 1)
end

-- Diagnostics: lets /run inspect cache growth without a debug UI.
function DurationColor:GetDurationCacheSize()
    return durationObjectCacheCount
end

function DurationColor:CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
    if not StyleEngine.CanAccessAllValues(startTime, duration, modRate) then return nil end
    if type(startTime) ~= "number" or type(duration) ~= "number" or duration <= 0 then return nil end
    return self:CreateDurationFromEndTime(startTime + duration, duration, modRate or 1)
end

function DurationColor:CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
    if not StyleEngine.CanAccessAllValues(expirationTime, duration, modRate) then return nil end
    if type(expirationTime) ~= "number" or type(duration) ~= "number" or duration <= 0 then return nil end
    return self:CreateDurationFromEndTime(expirationTime, duration, modRate or 1)
end

local function getDurationEvaluate(obj)
    return obj.EvaluateRemainingDuration
end

local function GetColorRGBA(color)
    return color:GetRGBA()
end

local function getDurationIsZero(obj)
    return obj.IsZero
end

local function GetAccessibleBoolean(value)
    if MCE:IsSecretValue(value)
       or not addon.CanAccessAllValues(value)
       or type(value) ~= "boolean" then
        return nil
    end
    return value == true
end

local function IsCooldownVisibleSafe(cdFrame)
    local method = cdFrame and MCE:SafeTableGet(cdFrame, "IsVisible") or nil
    if type(method) == "function" then
        local ok, visible = pcall(method, cdFrame)
        if ok then
            local accessibleVisible = GetAccessibleBoolean(visible)
            if accessibleVisible ~= nil then
                return accessibleVisible
            end
        end
    end

    -- SetDurationCooldown gives the public cooldown a secret Shown aspect.
    -- Visibility cannot be read in restricted contexts, but OnShow/OnHide and
    -- OnCooldownDone still maintain the active set without declassifying it.
    local state = cdFrame and frameState[cdFrame] or nil
    return state and state.unitFrameCustomAura == true or false
end

local function IsSupportedDurationObject(durationObject)
    local dt = type(durationObject)
    if dt ~= "table" and dt ~= "userdata" then return false end
    local ok, fn = pcall(getDurationEvaluate, durationObject)
    return ok and type(fn) == "function"
end

local function NormalizeDurationObject(durationObject)
    if not durationObject then
        return nil
    end

    if StyleEngine and (StyleEngine.IsSecretValue(durationObject) or not StyleEngine.CanAccessAllValues(durationObject)) then
        return nil
    end

    if not IsSupportedDurationObject(durationObject) then
        return nil
    end

    local ok, fn = pcall(getDurationIsZero, durationObject)
    if ok and type(fn) == "function" then
        local zeroOk, isZero = pcall(fn, durationObject)
        local accessibleIsZero
        if zeroOk then
            accessibleIsZero = GetAccessibleBoolean(isZero)
        end
        if accessibleIsZero == true then
            return nil
        end
    end

    return durationObject
end

function DurationColor:SetCooldownDurationObject(cdFrame, durationObject)
    if not cdFrame or StyleEngine.IsSecretValue(cdFrame) then return end
    durationObject = NormalizeDurationObject(durationObject)
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

function DurationColor:GetFallbackDurationObject(cdFrame)
    local getParent = cdFrame and MCE:SafeTableGet(cdFrame, "GetParent") or nil
    if type(getParent) ~= "function" then return nil end

    local parentOk, parent = pcall(getParent, cdFrame)
    if not parentOk or not parent or MCE:IsForbiddenCached(parent) then
        -- Public cooldowns in 12.1 custom AuraButtons receive their Duration
        -- through SetCooldownFromDurationObject. Never inspect the restricted
        -- parent as a fallback when that cached Duration is unavailable.
        return nil
    end

    local fs = StyleEngine:ResolveCooldownContext(cdFrame)
    local category = Registry and Registry:GetCategory(cdFrame)
    local actionButton = fs.actionButton ~= false and fs.actionButton or parent
    local actionID = fs.actionID ~= false and fs.actionID or StyleEngine:GetActionIDFromButton(actionButton)

    if actionID then
        if StyleEngine:IsChargeCooldownFrame(cdFrame, actionButton) then
            local ok, obj = pcall(C_ActionBar.GetActionChargeDuration, actionID)
            obj = ok and NormalizeDurationObject(obj) or nil
            if obj then return obj end
            return nil
        end

        local ok, obj = pcall(C_ActionBar.GetActionCooldownDuration, actionID, true)
        obj = ok and NormalizeDurationObject(obj) or nil
        if obj then return obj end
    end

    local shouldUseAura = self:ShouldUseAuraDurationFallback(cdFrame, category)
    if shouldUseAura then
        local auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
        local unitOwner = fs.auraUnitOwner ~= false and fs.auraUnitOwner or nil
        -- Pass the raw handle through: on 12.1 aura items it is a secret
        -- value. C_UnitAuras.GetAuraDuration returns nil for every addon
        -- while aura data is restricted, so this only resolves outside those
        -- contexts, but dropping the handle also loses the owner frame.
        local auraInstanceID = auraOwner and StyleEngine:GetFrameAuraInstanceIDValue(auraOwner)
        local unitToken = unitOwner and StyleEngine:GetFrameUnitToken(unitOwner)
        -- CooldownManager always tracks the player's own auras; default to
        -- "player" when the icon frame hierarchy exposes no unitToken.
        if not unitToken and category == CATEGORY.CooldownManager then
            unitToken = "player"
        end
        if auraInstanceID and unitToken then
            local ok, obj = pcall(C_UnitAuras.GetAuraDuration, unitToken, auraInstanceID)
            obj = ok and NormalizeDurationObject(obj) or nil
            if obj then return obj end
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
    if spellID then
        local useChargeDuration = StyleEngine:IsChargeCooldownFrame(cdFrame, spellOwner or parent)
        if issecretvalue(useChargeDuration) then useChargeDuration = false end
        if not useChargeDuration and category == CATEGORY.CooldownManager then
            useChargeDuration = StyleEngine:IsCooldownManagerChargeDisplay(cdFrame, parent)
            if issecretvalue(useChargeDuration) then useChargeDuration = false end
        end

        if useChargeDuration then
            local ok, obj = pcall(C_Spell.GetSpellChargeDuration, spellID)
            obj = ok and NormalizeDurationObject(obj) or nil
            if obj then return obj end
            return nil
        end

        local ok, obj = pcall(C_Spell.GetSpellCooldownDuration, spellID, true)
        obj = ok and NormalizeDurationObject(obj) or nil
        if obj then return obj end
    end

    return nil
end

function DurationColor:ShouldUseAuraDurationFallback(cdFrame, category)
    if not category then
        category = Registry and Registry:GetCategory(cdFrame)
    end
    if category == CATEGORY.Actionbar or category == CATEGORY.MiniAuras then return false end
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
        local auraID = StyleEngine:GetFrameAuraInstanceIDValue(auraOwner)
        local unitToken = StyleEngine:GetFrameUnitToken(unitOwner)
        if auraID and unitToken then return true end
    end
    return fs.hasAuraNamedAncestor == true
end

local function GetStoredDurationObject(cdFrame, allowFallback)
    local fs = frameState[cdFrame]
    if fs and fs.durationObject then
        local normalized = NormalizeDurationObject(fs.durationObject)
        if normalized then
            return normalized
        end
        fs.durationObject = nil
    end
    if allowFallback == false then return nil end
    local obj = DurationColor:GetFallbackDurationObject(cdFrame)
    if obj then DurationColor:SetCooldownDurationObject(cdFrame, obj) end
    return obj
end

local function GetCooldownDurationObject(cdFrame, sourceKey)
    if sourceKey == CATEGORY.Actionbar then
        local current = DurationColor:GetFallbackDurationObject(cdFrame)
        if current then return current end
        return GetStoredDurationObject(cdFrame, false)
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
    local categories = MCE.db and MCE.db.profile and MCE.db.profile.categories
    return categories and categories[sourceKey] or nil
end

local function IsThresholdColorAllowedForSource(sourceKey, config)
    if not config then return false end
    -- Nameplate is excluded outright: WoW 12.1 gives addons no readable
    -- remaining duration for Blizzard nameplate auras once aura data is
    -- restricted, so thresholds could only ever apply outside combat.
    if sourceKey == CATEGORY.HealerCC or sourceKey == CATEGORY.MiniAuras
       or sourceKey == CATEGORY.Nameplate then
        return false
    end
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

    local current = GetParentSafe(cdFrame)
    local depth = 0
    local sawAuraContext = false
    while current and current ~= UIParent and depth < CLASSIFIER_CONSTANTS.ScanDepth do
        depth = depth + 1
        if not sawAuraContext then
            local name = MCE:GetFrameName(current) or ""
            if strfind(name, "Buff", 1, true)
               or strfind(name, "Debuff", 1, true)
               or strfind(name, "Aura", 1, true) then
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
            local name = MCE:GetFrameName(current)
            if name then
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
        current = GetParentSafe(current)
    end

    fs = fs or resolved or StyleEngine:GetFrameState(cdFrame)
    fs.liveNameplateAuraContextResolved = true
    fs.liveNameplateAuraContext = false
    return false
end

local function ShouldSuppressDurationColorsForNameplate(cdFrame, sourceKey)
    if sourceKey == CATEGORY.Nameplate or sourceKey == CATEGORY.Actionbar
       or sourceKey == CATEGORY.CooldownManager or sourceKey == CATEGORY.MiniAuras then
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
    return config.enabled == true and IsThresholdColorAllowedForSource(sourceKey, config)
end

-- Global Cooldown hooks call these before retaining or constructing a Duration.
-- Keep the checks limited to configuration and cached frame state: this path is
-- paid by every owned cooldown update while threshold colors are enabled.
function DurationColor:NeedsDurationUpdate(cdFrame, sourceKey, categoryIsActive)
    if not cdFrame or not sourceKey
       or (categoryIsActive ~= true and not MCE:IsCategoryActive(sourceKey)) then
        return false
    end

    local durationConfig = GetDurationTextColorsConfig()
    local config = GetDurationTextSourceConfig(sourceKey)
    if not (durationConfig and durationConfig.enabled == true)
       or not IsThresholdColorAllowedForSource(sourceKey, config) then
        return false
    end

    local fs = frameState[cdFrame]
    if fs and (fs.unitFrameNativeDurationText == true
       or fs.miniAurasNativeDurationText == true) then
        return false
    end

    return true
end

function DurationColor:NeedsDurationCapture(cdFrame, sourceKey, needsDurationUpdate)
    -- Action Bars always resolve the current main/charge duration from the live
    -- action APIs. Setter-created objects are both redundant and prone to going
    -- stale after an action swap.
    if needsDurationUpdate == nil then
        needsDurationUpdate = self:NeedsDurationUpdate(cdFrame, sourceKey)
    end
    return sourceKey ~= nil
        and sourceKey ~= CATEGORY.Actionbar
        and needsDurationUpdate == true
        or false
end

local function GetNativeDurationFormatter()
    local profile = MCE.db and MCE.db.profile
    local abbrevThreshold = profile and profile.abbrevThreshold
        or C.Options.DefaultAbbrevThreshold
    local millisecondsThreshold = profile and profile.countdownMillisecondsThreshold
        or C.Options.DefaultMillisecondsThreshold

    abbrevThreshold = max(0, type(abbrevThreshold) == "number" and abbrevThreshold or 0)
    millisecondsThreshold = max(
        0, type(millisecondsThreshold) == "number" and millisecondsThreshold or 0)

    local key = abbrevThreshold .. ":" .. millisecondsThreshold
    local formatter = nativeDurationFormatters[key]
    if formatter then return formatter end

    local ok, created = pcall(function()
        local fmt = C_StringUtil.CreateNumericRuleFormatter()
        local down = Enum.NumericRuleFormatRounding.Down
        local up = Enum.NumericRuleFormatRounding.Up
        local minuteAt = max(abbrevThreshold + 1, millisecondsThreshold)
        local hourAt = max((abbrevThreshold * 60) + 1, minuteAt + 1)

        if millisecondsThreshold > 0 then
            fmt:AddBreakpoint({ threshold = 0, step = 0.1, format = "%.1f" })
            if minuteAt > millisecondsThreshold then
                fmt:AddBreakpoint({
                    threshold = millisecondsThreshold,
                    step = 1,
                    rounding = down,
                    min = 1,
                    format = "%d",
                })
            end
        else
            fmt:AddBreakpoint({
                threshold = 0,
                step = 1,
                rounding = down,
                min = 1,
                format = "%d",
            })
        end

        fmt:AddBreakpoint({
            threshold = minuteAt,
            step = 1,
            rounding = down,
            min = 1,
            format = "%dm",
            components = { { div = 60, rounding = up } },
        })
        fmt:AddBreakpoint({
            threshold = hourAt,
            step = 1,
            rounding = down,
            min = 1,
            format = "%dh",
            components = { { div = 3600, rounding = up } },
        })
        return fmt
    end)

    if not ok or not created then return nil end
    nativeDurationFormatters[key] = created
    return created
end

local function GetNativeFlatColorCurve(color)
    color = color or C.Colors.White
    local r, g, b, a = color.r or 1, color.g or 1, color.b or 1, color.a or 1
    local key = floor(r * 1000 + 0.5) .. ":"
        .. floor(g * 1000 + 0.5) .. ":"
        .. floor(b * 1000 + 0.5) .. ":"
        .. floor(a * 1000 + 0.5)
    local curve = nativeFlatColorCurves[key]
    if curve then return curve end

    curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, CreateColor(r, g, b, a))
    curve:AddPoint(1, CreateColor(r, g, b, a))
    nativeFlatColorCurves[key] = curve
    return curve
end

local function UsesThresholdColorsForSource(sourceKey, config)
    local durationConfig = GetDurationTextColorsConfig()
    return durationConfig and durationConfig.enabled == true
        and config and config.enabled == true
        and IsThresholdColorAllowedForSource(sourceKey, config)
        or false
end

local function GetNativeDurationTextCurve(sourceKey, config)
    if UsesThresholdColorsForSource(sourceKey, config) then
        local curve = GetColorCurve()
        if curve then return curve end
    end
    return GetNativeFlatColorCurve(config and config.textColor)
end

function DurationColor:UsesThresholdColorsForSource(sourceKey, config)
    return UsesThresholdColorsForSource(sourceKey, config)
end

function DurationColor:GetDurationTextCurve(sourceKey, config)
    return GetNativeDurationTextCurve(sourceKey, config)
end

function DurationColor:RefreshNativeUnitFrameDurationText(cdFrame, sourceKey, config)
    local fs = frameState[cdFrame]
    if not (fs and fs.unitFrameNativeDurationText == true
       and fs.unitFrameNativeDurationTextReady == true) then
        return false
    end

    local button = fs.unitFrameAuraButton
    local durationText = fs.unitFrameCountdownText
    local setDurationText = button and MCE:SafeTableGet(button, "SetDurationText") or nil
    if type(setDurationText) ~= "function" or not durationText then
        return false
    end

    local curve = GetNativeDurationTextCurve(sourceKey, config)
    local formatter = GetNativeDurationFormatter()
    if not curve then return false end

    if fs.unitFrameBoundDurationCurve == curve
       and fs.unitFrameBoundDurationFormatter == formatter
       and fs.unitFrameBoundDurationText == durationText then
        return true
    end

    local options = {
        textColor = {
            curve = curve,
            property = Enum.DurationTextBindingProperty.RemainingDuration,
        },
    }
    if formatter then
        options.textFormatter = formatter
    end

    local ok = pcall(setDurationText, button, durationText, options)
    if not ok then return false end

    fs.unitFrameBoundDurationCurve = curve
    fs.unitFrameBoundDurationFormatter = formatter
    fs.unitFrameBoundDurationText = durationText
    return true
end

-- =========================================================================
-- COLOR APPLICATION
-- =========================================================================

local function ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve)
    if not cdFrame or MCE:IsForbiddenCached(cdFrame) then return false end
    if not IsCooldownVisibleSafe(cdFrame) then return false end

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
        -- A curve evaluated from a secret Duration returns a secret colour;
        -- reading it must never abort the style pass.
        local rgbaOk, r, g, b, a = pcall(GetColorRGBA, color)
        if rgbaOk then
            return StyleEngine:ApplyRGBAColorToCooldownRegions(cdFrame, r, g, b, a)
        end
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
    local fs = frameState[cdFrame]
    -- MiniAuras owns both its native duration binding and countdown colors.
    if fs and fs.miniAurasNativeDurationText == true then
        self:ClearTrackedDurationColor(cdFrame)
        return false
    end
    if fs and fs.unitFrameNativeDurationText == true then
        self:ClearTrackedDurationColor(cdFrame)
        return self:RefreshNativeUnitFrameDurationText(cdFrame, sourceKey, config)
    end

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
        if IsCooldownVisibleSafe(cdFrame) then
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

local function UpdateDurationColors()
    local curve = GetColorCurve()
    if not curve then
        local clearCount = 0
        for cdFrame, sourceKey in pairs(durationColoredFrames) do
            local config = GetDurationTextSourceConfig(sourceKey)
            local overrideColor = GetStateOverrideTextColor(cdFrame, sourceKey, config)
            if overrideColor then
                StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, overrideColor)
            else
                StyleEngine:ResetCountdownTextColor(cdFrame, GetDurationResetConfig(cdFrame, sourceKey, config))
            end
            clearCount = clearCount + 1
            clearListScratch[clearCount] = cdFrame
        end
        for i = 1, clearCount do
            DurationColor:ClearTrackedDurationColor(clearListScratch[i])
            clearListScratch[i] = nil
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
    local clearCount = 0
    for cdFrame in pairs(activeDurationFrames) do
        local sourceKey = durationColoredFrames[cdFrame]
        if not sourceKey then
            RemoveActiveDurationFrame(cdFrame)
        else
            local config = GetDurationTextSourceConfig(sourceKey)
            local overrideColor = GetStateOverrideTextColor(cdFrame, sourceKey, config)
            if overrideColor then
                StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, overrideColor)
                clearCount = clearCount + 1
                clearListScratch[clearCount] = cdFrame
            elseif cdFrame and not MCE:IsForbiddenCached(cdFrame)
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

    for i = 1, clearCount do
        DurationColor:ClearTrackedDurationColor(clearListScratch[i])
        clearListScratch[i] = nil
    end

    if activeCount == 0 then StopTicker() end
end

StartTicker = function()
    if durationColorTicker then return end
    durationColorTicker = NewTicker(STYLER_CONSTANTS.DurationColorTickerInterval, UpdateDurationColors)
end

-- =========================================================================
-- HOOK HANDLER (called from HookBridge)
-- =========================================================================

function DurationColor:HandleCooldownDurationUpdate(cooldown, durationObject)
    if not cooldown or MCE:IsForbiddenCached(cooldown) or StyleEngine.IsSecretValue(cooldown) then return end

    -- Nothing outside this module reads fs.durationObject, and every reader here
    -- goes through GetStoredDurationObject, which re-resolves it on demand. So
    -- with duration colors off and this cooldown untracked, the work below --
    -- above all GetFallbackDurationObject's parent walk plus its C_ActionBar /
    -- C_UnitAuras / C_Spell queries, paid on every aura refresh -- produces
    -- nothing observable. Enabling the option runs ForceUpdateAll, which
    -- rebuilds this state from scratch.
    if not durationColoredFrames[cooldown] then
        local durationConfig = GetDurationTextColorsConfig()
        if not (durationConfig and durationConfig.enabled) then return end
    end

    -- Action bars re-fetch live duration data, so avoid extra validation work.
    local category = Registry and Registry:GetCategory(cooldown)
    local trackedState = frameState[cooldown]
    if trackedState and (trackedState.unitFrameNativeDurationText == true
       or trackedState.miniAurasNativeDurationText == true) then
        return
    end
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
    durationObjectCacheCount = 0
    wipe(nativeDurationFormatters)
    wipe(nativeFlatColorCurves)
    self:InvalidateColorCurve()
end
