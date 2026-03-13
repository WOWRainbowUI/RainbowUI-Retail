-- Styler.lua – Style application, hooks, batch processing & nameplates (AceModule)
--
-- Uses AceHook for auto-unhook on disable and AceEvent for clean event lifecycle.

local MCE        = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Styler     = MCE:NewModule("Styler", "AceEvent-3.0", "AceHook-3.0")
local Classifier = MCE:GetModule("Classifier")

local pairs, ipairs, type, pcall, wipe = pairs, ipairs, type, pcall, wipe
local math_abs = math.abs
local strfind = string.find
local setmetatable = setmetatable
local select = select
local C_Timer_After = C_Timer.After
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local EnumerateFrames  = EnumerateFrames
local hooksecurefunc = hooksecurefunc
local issecretvalue = issecretvalue
local canaccessallvalues = canaccessallvalues

-- =========================================================================
-- CACHES  (weak-keyed → auto-collected with their frames)
-- =========================================================================

local trackedCooldowns = setmetatable({}, { __mode = "k" })
local styledCategory   = setmetatable({}, { __mode = "k" })
local fontStringStyleState = setmetatable({}, { __mode = "k" })
local cooldownTextRegionState = setmetatable({}, { __mode = "k" })

-- Anti-flicker: track last-applied API values per frame to skip redundant calls
local lastAppliedEdge      = setmetatable({}, { __mode = "k" })
local lastAppliedEdgeScale = setmetatable({}, { __mode = "k" })
local lastAppliedHideNums  = setmetatable({}, { __mode = "k" })

-- Re-entrancy guards for API enforcement hooks
local suppressEdgeEnforcement      = setmetatable({}, { __mode = "k" })
local suppressEdgeScaleEnforcement = setmetatable({}, { __mode = "k" })
local suppressHideNumsEnforcement  = setmetatable({}, { __mode = "k" })
local hookedFontStringSetFont      = setmetatable({}, { __mode = "k" })
local suppressFontStringSetFont    = setmetatable({}, { __mode = "k" })

-- =========================================================================
-- DURATION-BASED TEXT COLORING
-- =========================================================================
-- Uses WoW-native APIs and DurationObjects with Midnight-safe secret-value
-- checks and public API fallbacks.

local durationColoredFrames = setmetatable({}, { __mode = "k" })
local cooldownDurationInfo = setmetatable({}, { __mode = "k" })
local durationColorTicker = nil

local durationColorCurve = nil

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

local function StopDurationColorTicker()
    if durationColorTicker then
        durationColorTicker:Cancel()
        durationColorTicker = nil
    end
end

local compactPartyAuraFrames = setmetatable({}, { __mode = "k" })
local RefreshTrackedDurationColor
local pendingAuraDurationRefresh = setmetatable({}, { __mode = "k" })

local MAX_COOLDOWN_OWNER_SCAN_DEPTH = 10
local MAX_COMPACT_AURA_SCAN_DEPTH = 10

local function ExtractUnitToken(unit)
    if type(unit) == "string" then
        return unit ~= "" and unit or nil
    end

    if type(unit) ~= "table" then
        return nil
    end

    local token = unit.unitid
        or unit.unitID
        or unit.unitToken
        or unit.displayedUnit
        or unit.memberUnit
        or unit.unit

    if type(token) == "string" and token ~= "" then
        return token
    end

    return nil
end

local function GetFrameUnitToken(frame)
    if not frame then return nil end

    return ExtractUnitToken(frame.unitToken)
        or ExtractUnitToken(frame.unit)
        or ExtractUnitToken(frame.displayedUnit)
        or ExtractUnitToken(frame.memberUnit)
        or ExtractUnitToken(frame.auraDataUnit)
end

local function GetFrameAuraInstanceID(frame)
    if not frame then return nil end

    return frame.auraInstanceID
        or frame.auraDataInstanceID
        or frame.auraInstanceId
        or frame.auraDataInstanceId
end

local function GetCompactGroupFrameTypeFromUnit(unitToken)
    if type(unitToken) ~= "string" then
        return nil
    end

    if strfind(unitToken, "raid", 1, true) == 1 then
        return "raid"
    end

    if strfind(unitToken, "party", 1, true) == 1 then
        return "party"
    end

    return nil
end

local function GetCompactPartyAuraFrameType(cdFrame)
    local current = cdFrame
    local sawAuraContext = false

    for _ = 1, MAX_COMPACT_AURA_SCAN_DEPTH do
        if not current then break end

        local name = current.GetName and current:GetName() or ""
        local isAuraFrame = strfind(name, "Buff", 1, true)
            or strfind(name, "Debuff", 1, true)
            or strfind(name, "Aura", 1, true)
        if isAuraFrame then
            sawAuraContext = true
            if strfind(name, "CompactPartyFrame", 1, true) then
                return "party"
            end
            if strfind(name, "CompactRaidFrame", 1, true) then
                return "raid"
            end
        end

        local unitToken = GetFrameUnitToken(current)
        local unitType = GetCompactGroupFrameTypeFromUnit(unitToken)
        if sawAuraContext and unitType and strfind(name, "Compact", 1, true) then
            return unitType
        end

        current = current.GetParent and current:GetParent() or nil
    end

    return nil
end

local function GetCompactPartyAuraConfig()
    return MCE.db and MCE.db.profile and MCE.db.profile.compactPartyAuraText or nil
end

local function ShouldUseCompactPartyAuraText(config, frameType)
    if not config then return false end
    if frameType == "raid" then
        return config.raidEnabled
    end
    if frameType == "party" then
        return config.enabled
    end
    return false
end

local function GetCompactPartyAuraNativeText(cdFrame)
    local nativeText = cdFrame.GetCountdownFontString and cdFrame:GetCountdownFontString()
    if nativeText and not MCE:IsForbidden(nativeText) then
        return nativeText
    end
    return nil
end

local function rawEqual(left, right)
    return left == right
end

local function IsSameValueSafe(a, b)
    local ok, same = pcall(rawEqual, a, b)
    return ok and same or false
end

local function rawNearlyEqual(left, right)
    return math_abs(left - right) < 0.001
end

local function IsNearlyEqual(a, b)
    local ok, same = pcall(rawEqual, a, b)
    if ok and same then
        return true
    end

    if type(a) ~= "number" or type(b) ~= "number" then
        return false
    end

    local approxOk, approxSame = pcall(rawNearlyEqual, a, b)
    return approxOk and approxSame or false
end

local function GetFontStringStyleState(region)
    local state = fontStringStyleState[region]
    if not state then
        state = {}
        fontStringStyleState[region] = state
    end
    return state
end

local function EnsureFontStringSetFontHook(region)
    if hookedFontStringSetFont[region] or not region.SetFont then return end

    local ok = pcall(hooksecurefunc, region, "SetFont", function(self, fontPath, fontSize, fontStyle)
        if suppressFontStringSetFont[self] then return end

        local state = fontStringStyleState[self]
        if not state or not state.enforceFont then return end

        if IsSameValueSafe(fontPath, state.fontPath)
           and IsNearlyEqual(fontSize, state.fontSize)
           and IsSameValueSafe(fontStyle, state.fontStyle) then
            return
        end

        suppressFontStringSetFont[self] = true
        pcall(self.SetFont, self, state.fontPath, state.fontSize, state.fontStyle)
        suppressFontStringSetFont[self] = nil
    end)

    if ok then
        hookedFontStringSetFont[region] = true
    end
end

local function HaveCooldownTextRegionsChanged(cdFrame, textRegions, textRegionCount)
    local state = cooldownTextRegionState[cdFrame]
    if not state then
        state = {}
        cooldownTextRegionState[cdFrame] = state
    end

    local changed = (state.count ~= textRegionCount)
    for i = 1, textRegionCount do
        if state[i] ~= textRegions[i] then
            changed = true
        end
        state[i] = textRegions[i]
    end
    for i = textRegionCount + 1, state.count or 0 do
        state[i] = nil
    end
    state.count = textRegionCount

    return changed
end

local function ApplyFontStringStyle(region, relativeFrame, fontPath, fontSize, fontStyle,
                                    color, point, relativePoint, offsetX, offsetY,
                                    drawLayer, drawLayerSubLevel, enforceFont)
    if not region or MCE:IsForbidden(region) then return end

    relativePoint = relativePoint or point
    drawLayerSubLevel = drawLayerSubLevel or 0

    local state = GetFontStringStyleState(region)
    state.enforceFont = enforceFont or false

    if state.fontPath ~= fontPath
       or state.fontSize ~= fontSize
       or state.fontStyle ~= fontStyle then
        if state.enforceFont then
            EnsureFontStringSetFontHook(region)
        end
        suppressFontStringSetFont[region] = true
        region:SetFont(fontPath, fontSize, fontStyle)
        suppressFontStringSetFont[region] = nil
        state.fontPath = fontPath
        state.fontSize = fontSize
        state.fontStyle = fontStyle
    end

    if color then
        if state.colorR ~= color.r
           or state.colorG ~= color.g
           or state.colorB ~= color.b
           or state.colorA ~= color.a then
            region:SetTextColor(color.r, color.g, color.b, color.a)
            state.colorR = color.r
            state.colorG = color.g
            state.colorB = color.b
            state.colorA = color.a
        end
    end

    if point and relativeFrame then
        if state.point ~= point
           or state.relativeFrame ~= relativeFrame
           or state.relativePoint ~= relativePoint
           or state.offsetX ~= offsetX
           or state.offsetY ~= offsetY then
            region:ClearAllPoints()
            region:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
            state.point = point
            state.relativeFrame = relativeFrame
            state.relativePoint = relativePoint
            state.offsetX = offsetX
            state.offsetY = offsetY
        end
    end

    if drawLayer and region.SetDrawLayer then
        if state.drawLayer ~= drawLayer
           or state.drawLayerSubLevel ~= drawLayerSubLevel
        then
            region:SetDrawLayer(drawLayer, drawLayerSubLevel)
            state.drawLayer = drawLayer
            state.drawLayerSubLevel = drawLayerSubLevel
        end
    end
end

local function ApplyCompactPartyAuraTextStyle(cdFrame, config)
    local text = GetCompactPartyAuraNativeText(cdFrame)
    if not text then return nil end

    local anchor = config.textAnchor or "CENTER"
    local offsetX = config.textOffsetX or 0
    local offsetY = config.textOffsetY or 0

    ApplyFontStringStyle(
        text,
        cdFrame,
        MCE.ResolveFontPath(config.font),
        config.fontSize,
        MCE.NormalizeFontStyle(config.fontStyle),
        config.textColor,
        anchor,
        anchor,
        offsetX,
        offsetY,
        nil,
        nil,
        false)
    return text
end

local function SetCompactPartyAuraNativeTextVisible(cdFrame, visible)
    local nativeText = GetCompactPartyAuraNativeText(cdFrame)
    if nativeText then
        if visible then
            nativeText:SetAlpha(1)
            nativeText:Show()
        else
            nativeText:SetAlpha(0)
            nativeText:Hide()
        end
    end
    return nativeText
end

local function SetCompactPartyAuraNativeHide(cdFrame, hide)
    if not cdFrame.SetHideCountdownNumbers then return end
    if lastAppliedHideNums[cdFrame] == hide then return end

    suppressHideNumsEnforcement[cdFrame] = true
    pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hide)
    suppressHideNumsEnforcement[cdFrame] = nil
    lastAppliedHideNums[cdFrame] = hide
end

local function SyncCompactPartyAuraCooldown(cdFrame)
    local frameType = GetCompactPartyAuraFrameType(cdFrame)
    if not frameType then return false end
    compactPartyAuraFrames[cdFrame] = true

    local config = GetCompactPartyAuraConfig()
    if not ShouldUseCompactPartyAuraText(config, frameType) then
        durationColoredFrames[cdFrame] = nil
        SetCompactPartyAuraNativeTextVisible(cdFrame, false)
        SetCompactPartyAuraNativeHide(cdFrame, true)
        return true
    end

    local text = ApplyCompactPartyAuraTextStyle(cdFrame, config)
    SetCompactPartyAuraNativeHide(cdFrame, false)
    if text then
        SetCompactPartyAuraNativeTextVisible(cdFrame, true)
    end

    -- Apply abbreviation threshold
    local profile = MCE.db and MCE.db.profile
    if profile and cdFrame.SetCountdownAbbrevThreshold then
        pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame, profile.abbrevThreshold or 59)
    end

    if RefreshTrackedDurationColor then
        RefreshTrackedDurationColor(cdFrame, "compactPartyAura", config)
    end

    return true
end

local COOLDOWN_MEMBER_KEYS = { "cooldown", "Cooldown", "chargeCooldown", "ChargeCooldown" }

local function QueueKnownCooldownMembers(frame, queueUpdate, forcedCategory)
    -- Dedup without table allocation: at most 2 unique cooldowns (main + charge)
    local seen1, seen2
    for i = 1, 4 do
        local cooldown = frame[COOLDOWN_MEMBER_KEYS[i]]
        if type(cooldown) == "table"
           and cooldown ~= seen1 and cooldown ~= seen2
           and not MCE:IsForbidden(cooldown) then
            if not seen1 then seen1 = cooldown else seen2 = cooldown end
            queueUpdate(cooldown, forcedCategory)
        end
    end
end

-- Pre-defined callback to avoid closure allocation in ForceUpdateAll / StyleCooldownsInFrame
local function QueueUpdateCallback(cooldown, forcedCategory)
    Styler:QueueUpdate(cooldown, forcedCategory)
end

local function GetActionIDFromButton(parent)
    if not parent then return nil end

    local actionID = parent.action
    if type(actionID) == "number" then
        return actionID
    end

    if parent.GetAttribute then
        local ok, attr = pcall(parent.GetAttribute, parent, "action")
        if ok and type(attr) == "number" then
            return attr
        end
    end

    return nil
end

-- Scratch table reused by GetCooldownTextRegions to avoid per-call allocation
local textRegionScratch = {}

--- Vararg helper: filters FontString regions without allocating a table for GetRegions().
local function FilterFontStringRegions(count, firstRegion, ...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region ~= firstRegion
           and region.GetObjectType
           and region:GetObjectType() == "FontString"
           and not MCE:IsForbidden(region) then
            count = count + 1
            textRegionScratch[count] = region
        end
    end
    return count
end

local function GetCooldownTextRegions(cdFrame)
    -- Reuse scratch table; track count for accurate iteration
    local count = 0
    local firstRegion = nil

    local countdownText = cdFrame.GetCountdownFontString and cdFrame:GetCountdownFontString()
    if countdownText and not MCE:IsForbidden(countdownText) then
        count = 1
        textRegionScratch[1] = countdownText
        firstRegion = countdownText
    end

    if cdFrame.GetRegions then
        local numRegions = cdFrame.GetNumRegions and cdFrame:GetNumRegions() or 0
        if numRegions > 0 then
            count = FilterFontStringRegions(count, firstRegion, cdFrame:GetRegions())
        end
    end

    -- Nil out stale entries from previous calls
    for i = count + 1, #textRegionScratch do
        textRegionScratch[i] = nil
    end

    return textRegionScratch, count
end

--- Builds a WoW C_CurveUtil Step color curve from the threshold config.
local function BuildColorCurve(durationConfig)
    local thresholds = durationConfig.thresholds
    if not thresholds or #thresholds == 0 then return nil end

    local sortedThresholds = {}
    for i = 1, #thresholds do
        sortedThresholds[i] = thresholds[i]
    end

    table.sort(sortedThresholds, function(a, b)
        return (a.threshold or 0) < (b.threshold or 0)
    end)

    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Step)

    -- Point at 0: color for the shortest remaining time
    local c1 = sortedThresholds[1].color
    curve:AddPoint(0, CreateColor(c1.r, c1.g, c1.b, c1.a or 1))

    -- Intermediate threshold points (use exact threshold values for precise transitions)
    for i = 2, #sortedThresholds do
        local startAt = sortedThresholds[i - 1].threshold or 0
        local c = sortedThresholds[i].color
        curve:AddPoint(startAt, CreateColor(c.r, c.g, c.b, c.a or 1))
    end

    -- Default color for durations beyond the last threshold
    if durationConfig.defaultColor then
        local startAt = sortedThresholds[#sortedThresholds].threshold or 0
        local dc = durationConfig.defaultColor
        curve:AddPoint(startAt, CreateColor(dc.r, dc.g, dc.b, dc.a or 1))
    end

    return curve
end

local function GetDurationTextColorsConfig()
    local profile = MCE.db and MCE.db.profile
    if not profile then return nil end

    profile.durationTextColors = MCE.EnsureDurationTextColorConfig(profile.durationTextColors)
    return profile.durationTextColors
end

local function GetDurationTextSourceConfig(sourceKey)
    if sourceKey == "compactPartyAura" then
        return GetCompactPartyAuraConfig()
    end

    local categories = MCE.db and MCE.db.profile and MCE.db.profile.categories
    return categories and categories[sourceKey] or nil
end

local function ApplyTextColorToCooldownRegions(cdFrame, color)
    local textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and not MCE:IsForbidden(region) then
            region:SetTextColor(color.r, color.g, color.b, color.a)
        end
    end

    return true
end

local function CreateDurationFromEndTime(endTime, duration, modRate)
    if type(endTime) ~= "number" or type(duration) ~= "number" then
        return nil
    end
    if not C_DurationUtil or not C_DurationUtil.CreateDuration then
        return nil
    end

    local durationObject = C_DurationUtil.CreateDuration()
    if not durationObject or not durationObject.SetTimeFromEnd then
        return nil
    end

    durationObject:SetTimeFromEnd(endTime, duration, modRate or 1)
    return durationObject
end

local function IsSupportedDurationObject(durationObject)
    local durationType = type(durationObject)
    if durationType ~= "table" and durationType ~= "userdata" then
        return false
    end

    local okMethod, evaluateRemainingDuration = pcall(function()
        return durationObject.EvaluateRemainingDuration
    end)

    return okMethod and type(evaluateRemainingDuration) == "function"
end

local function IsChargeCooldownFrame(cooldown, parent)
    if not cooldown or not parent then return false end
    return parent.chargeCooldown == cooldown or parent.ChargeCooldown == cooldown
end

local function GetCooldownSpellID(owner)
    if not owner then return nil end

    if type(owner.GetSpellID) == "function" then
        local ok, spellID = pcall(owner.GetSpellID, owner)
        if ok and spellID then
            return spellID
        end
    end

    return owner.spellID
end

local function FindCooldownOwner(cdFrame, predicate)
    local current = cdFrame and cdFrame.GetParent and cdFrame:GetParent() or nil

    for _ = 1, MAX_COOLDOWN_OWNER_SCAN_DEPTH do
        if not current then break end
        if predicate(current) then
            return current
        end
        current = current.GetParent and current:GetParent() or nil
    end

    return nil
end

local function GetAuraDurationContext(cdFrame)
    local current = cdFrame and cdFrame.GetParent and cdFrame:GetParent() or nil
    local auraInstanceID
    local unitToken
    local auraOwner

    for _ = 1, MAX_COOLDOWN_OWNER_SCAN_DEPTH do
        if not current then break end

        if not auraInstanceID then
            auraInstanceID = GetFrameAuraInstanceID(current)
            if auraInstanceID then
                auraOwner = current
            end
        end

        if not unitToken then
            unitToken = GetFrameUnitToken(current)
        end

        if auraInstanceID and unitToken then
            return auraInstanceID, unitToken, auraOwner or current
        end

        current = current.GetParent and current:GetParent() or nil
    end

    return nil, nil, nil
end

local function GetSpellCooldownOwner(cdFrame)
    return FindCooldownOwner(cdFrame, function(frame)
        return GetCooldownSpellID(frame) ~= nil
    end)
end

local function IsAuraDrivenCooldown(cdFrame)
    local auraInstanceID, unitToken = GetAuraDurationContext(cdFrame)
    if auraInstanceID and unitToken then
        return true
    end

    local owner = cdFrame and cdFrame.GetParent and cdFrame:GetParent() or nil
    for _ = 1, MAX_COOLDOWN_OWNER_SCAN_DEPTH do
        if not owner then break end

        local name = owner.GetName and owner:GetName() or ""
        if strfind(name, "Buff", 1, true)
            or strfind(name, "Debuff", 1, true)
            or strfind(name, "Aura", 1, true) then
            return true
        end

        owner = owner.GetParent and owner:GetParent() or nil
    end

    return false
end

local function GetFallbackDurationObject(cdFrame)
    local parent = cdFrame and cdFrame.GetParent and cdFrame:GetParent()
    if not parent then return nil end

    local actionID = GetActionIDFromButton(parent)
    if actionID and C_ActionBar then
        if IsChargeCooldownFrame(cdFrame, parent) and C_ActionBar.GetActionChargeDuration then
            local ok, durationObject = pcall(C_ActionBar.GetActionChargeDuration, actionID)
            if ok and durationObject then
                return durationObject
            end
        end

        if C_ActionBar.GetActionCooldownDuration then
            local ok, durationObject = pcall(C_ActionBar.GetActionCooldownDuration, actionID)
            if ok and durationObject then
                return durationObject
            end
        end
    end

    local auraInstanceID, unitToken = GetAuraDurationContext(cdFrame)

    if auraInstanceID and unitToken and C_UnitAuras and C_UnitAuras.GetAuraDuration then
        local ok, durationObject = pcall(C_UnitAuras.GetAuraDuration, unitToken, auraInstanceID)
        if ok and durationObject then
            return durationObject
        end
    end

    local spellOwner = GetSpellCooldownOwner(cdFrame) or parent
    local spellID = GetCooldownSpellID(spellOwner)

    if spellID and C_Spell then
        if IsChargeCooldownFrame(cdFrame, spellOwner or parent) and C_Spell.GetSpellChargeDuration then
            local ok, durationObject = pcall(C_Spell.GetSpellChargeDuration, spellID)
            if ok and durationObject then
                return durationObject
            end
        end

        if C_Spell.GetSpellCooldownDuration then
            local ok, durationObject = pcall(C_Spell.GetSpellCooldownDuration, spellID)
            if ok and durationObject then
                return durationObject
            end
        end
    end

    return nil
end

local function SetCooldownDurationObject(cdFrame, durationObject)
    if not cdFrame or IsSecretValue(cdFrame) then return end

    if durationObject and (IsSecretValue(durationObject) or not CanAccessAllValues(durationObject)) then
        durationObject = nil
    end

    if durationObject and not IsSupportedDurationObject(durationObject) then
        durationObject = nil
    end

    if not durationObject then
        durationObject = GetFallbackDurationObject(cdFrame)
    end

    if durationObject then
        local info = cooldownDurationInfo[cdFrame]
        if not info then
            info = {}
            cooldownDurationInfo[cdFrame] = info
        end
        info.durationObject = durationObject
    else
        cooldownDurationInfo[cdFrame] = nil
    end
end

local function GetCooldownDurationObject(cdFrame)
    if IsAuraDrivenCooldown(cdFrame) then
        local durationObject = GetFallbackDurationObject(cdFrame)
        if durationObject then
            SetCooldownDurationObject(cdFrame, durationObject)
        else
            cooldownDurationInfo[cdFrame] = nil
        end
        return durationObject
    end

    local info = cooldownDurationInfo[cdFrame]
    if info and info.durationObject then
        return info.durationObject
    end

    local durationObject = GetFallbackDurationObject(cdFrame)
    if durationObject then
        SetCooldownDurationObject(cdFrame, durationObject)
    end
    return durationObject
end

--- Invalidates the cached color curve (call on any config change).
local function InvalidateColorCurve()
    durationColorCurve = nil
end

--- Returns the color curve, building it lazily from current config.
local function GetColorCurve()
    if durationColorCurve then return durationColorCurve end

    local config = GetDurationTextColorsConfig()
    if not config or not config.enabled then
        return nil
    end

    durationColorCurve = BuildColorCurve(config)
    return durationColorCurve
end

local function ResetCountdownTextColor(cdFrame, config)
    local tc = config and config.textColor
    if not tc then return false end

    return ApplyTextColorToCooldownRegions(cdFrame, tc)
end

local function ApplyCooldownDurationColor(cdFrame, config, curve)
    if not cdFrame or MCE:IsForbidden(cdFrame) then return false end
    if cdFrame.IsShown and not cdFrame:IsShown() then return false end

    local textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    local duration = GetCooldownDurationObject(cdFrame)
    if not duration then
        ResetCountdownTextColor(cdFrame, config)
        return false
    end

    local okMethod, evaluateRemainingDuration = pcall(function()
        return duration.EvaluateRemainingDuration
    end)
    if not IsSupportedDurationObject(duration) or not okMethod or type(evaluateRemainingDuration) ~= "function" then
        ResetCountdownTextColor(cdFrame, config)
        return false
    end

    local ok, color = pcall(evaluateRemainingDuration, duration, curve)
    if ok and color then
        local r, g, b, a = color:GetRGBA()
        for i = 1, textRegionCount do
            local region = textRegions[i]
            if region and not MCE:IsForbidden(region) then
                region:SetTextColor(r, g, b, a)
            end
        end
        return true
    end

    ResetCountdownTextColor(cdFrame, config)
    return false
end

local function ClearTrackedDurationColor(cdFrame)
    durationColoredFrames[cdFrame] = nil
    cooldownDurationInfo[cdFrame] = nil
end

local function UpdateDurationColors()
    local curve = GetColorCurve()
    if not curve then
        for cdFrame, sourceKey in pairs(durationColoredFrames) do
            ResetCountdownTextColor(cdFrame, GetDurationTextSourceConfig(sourceKey))
            durationColoredFrames[cdFrame] = nil
        end
        StopDurationColorTicker()
        return
    end

    local activeCount = 0

    for cdFrame, sourceKey in pairs(durationColoredFrames) do
        local config = GetDurationTextSourceConfig(sourceKey)
        if cdFrame and not MCE:IsForbidden(cdFrame)
           and config
           and ApplyCooldownDurationColor(cdFrame, config, curve) then
            activeCount = activeCount + 1
        else
            durationColoredFrames[cdFrame] = nil
        end
    end

    if activeCount == 0 then
        StopDurationColorTicker()
    end
end

local function StartDurationColorTicker()
    if durationColorTicker then return end
    durationColorTicker = C_Timer.NewTicker(0.1, UpdateDurationColors)
end

RefreshTrackedDurationColor = function(cdFrame, sourceKey, config)
    local durationConfig = GetDurationTextColorsConfig()
    if not durationConfig or not durationConfig.enabled then
        durationColoredFrames[cdFrame] = nil
        ResetCountdownTextColor(cdFrame, config)
        return false
    end

    local curve = GetColorCurve()
    if curve and ApplyCooldownDurationColor(cdFrame, config, curve) then
        durationColoredFrames[cdFrame] = sourceKey
        StartDurationColorTicker()
        return true
    end

    durationColoredFrames[cdFrame] = nil
    ResetCountdownTextColor(cdFrame, config)
    return false
end

local function HandleCooldownDurationUpdate(cooldown, durationObject)
    if not cooldown or MCE:IsForbidden(cooldown) or IsSecretValue(cooldown) then return end

    SetCooldownDurationObject(cooldown, durationObject)

    if SyncCompactPartyAuraCooldown(cooldown) then
        return
    end

    Styler:QueueUpdate(cooldown)

    if IsAuraDrivenCooldown(cooldown) and not pendingAuraDurationRefresh[cooldown] then
        pendingAuraDurationRefresh[cooldown] = true
        C_Timer_After(0, function()
            pendingAuraDurationRefresh[cooldown] = nil

            if not cooldown or MCE:IsForbidden(cooldown) or IsSecretValue(cooldown) then
                return
            end

            cooldownDurationInfo[cooldown] = nil

            if SyncCompactPartyAuraCooldown(cooldown) then
                return
            end

            Styler:QueueUpdate(cooldown)
        end)
    end
end

local function CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
    if not CanAccessAllValues(startTime, duration, modRate) then
        return nil
    end
    if type(startTime) ~= "number" or type(duration) ~= "number" then
        return nil
    end

    return CreateDurationFromEndTime(startTime + duration, duration, modRate or 1)
end

local function CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
    if not CanAccessAllValues(expirationTime, duration, modRate) then
        return nil
    end
    return CreateDurationFromEndTime(expirationTime, duration, modRate or 1)
end

-- =========================================================================
-- BATCH PROCESSOR  (coalesces rapid hook fires into a single pass)
-- Eliminates visual flickering caused by rapid sequential API calls.
-- =========================================================================

local dirtyFrames = {}
local dirtyCount = 0
local batchTimerScheduled = false

local function MarkFrameDirty(frame, forcedCategory)
    local existing = dirtyFrames[frame]
    if existing == nil then
        dirtyCount = dirtyCount + 1
    end

    -- Preserve the strongest category hint seen during the current batch.
    if forcedCategory then
        dirtyFrames[frame] = forcedCategory
    elseif existing == nil then
        dirtyFrames[frame] = true
    end
end

local function ProcessDirtyFrames()
    batchTimerScheduled = false
    if dirtyCount == 0 then return end

    for frame, forcedCategory in pairs(dirtyFrames) do
        if frame and not MCE:IsForbidden(frame) then
            Styler:ApplyStyle(frame, forcedCategory ~= true and forcedCategory or nil)
        end
    end
    wipe(dirtyFrames)
    dirtyCount = 0
end

function Styler:QueueUpdate(frame, forcedCategory)
    if not frame or MCE:IsForbidden(frame) then return end
    if Classifier:IsBlacklisted(frame) then return end

    -- Always coalesce rapid hook bursts into a single pass.
    -- This matters most on action buttons / assisted-combat suggestions,
    -- where Blizzard can touch the same cooldown multiple times in one tick.
    MarkFrameDirty(frame, forcedCategory)

    if not batchTimerScheduled then
        batchTimerScheduled = true
        C_Timer_After(0, ProcessDirtyFrames)
    end
end

-- =========================================================================
-- LIFECYCLE
-- =========================================================================

function Styler:OnEnable()
    self:SetupHooks()

    if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        if InCombatLockdown() then self:PLAYER_REGEN_DISABLED() end
    end

    C_Timer_After(2, function()
        self:ForceUpdateAll(true)
    end)
end

function Styler:OnDisable()
    if self.nameplateTicker then
        self.nameplateTicker:Cancel()
        self.nameplateTicker = nil
    end
    for cd in pairs(compactPartyAuraFrames) do
        if cd and not MCE:IsForbidden(cd) then
            SetCompactPartyAuraNativeTextVisible(cd, true)
            SetCompactPartyAuraNativeHide(cd, false)
        end
    end
    wipe(compactPartyAuraFrames)
    StopDurationColorTicker()
    wipe(durationColoredFrames)
    wipe(cooldownDurationInfo)
    wipe(pendingNameplates)
    wipe(pendingAuras)
    wipe(fontStringStyleState)
    wipe(cooldownTextRegionState)
    -- AceEvent auto-unregisters events; AceHook auto-unhooks.
end

-- =========================================================================
-- CHARGE COOLDOWN OVERLAP PREVENTION
-- =========================================================================
-- For charge-based abilities (e.g., Fire Blast, Shield of the Righteous),
-- WoW uses two separate cooldown frames on the same action button:
--   • button.cooldown       – the main/full cooldown (all charges spent)
--   • button.chargeCooldown – the per-charge recharge timer
-- When charges remain, only the chargeCooldown should show countdown text.
-- Without this guard, the addon's styling forces both frames to display
-- numbers simultaneously, causing the "overlapping timers" visual glitch.
local function IsMainCooldownWithActiveChargeCooldown(cdFrame)
    local parent = cdFrame:GetParent()
    if not parent then return false end

    -- Verify this frame is the *main* cooldown, not the charge cooldown
    local mainCD = parent.cooldown or parent.Cooldown
    if mainCD ~= cdFrame then return false end

    -- Check for a sibling charge cooldown that is currently visible
    local chargeCD = parent.chargeCooldown or parent.ChargeCooldown
    if chargeCD and chargeCD ~= cdFrame and not MCE:IsForbidden(chargeCD)
       and chargeCD.IsShown and chargeCD:IsShown() then
        return true
    end
    return false
end

local function GetDesiredHideCountdownNumbers(cdFrame, category, config)
    local hideNums = config.hideCountdownNumbers

    if category == "minicc" then
        local miniCCType = Classifier:GetMiniCCFrameType(cdFrame)
        if miniCCType == "cc" then
            if config.ccHideCountdownNumbers ~= nil then
                return config.ccHideCountdownNumbers
            end
            return hideNums
        end
        if miniCCType == "nameplate" then
            if config.nameplateHideCountdownNumbers ~= nil then
                return config.nameplateHideCountdownNumbers
            end
            return hideNums
        end
        if miniCCType == "portrait" then
            if config.portraitHideCountdownNumbers ~= nil then
                return config.portraitHideCountdownNumbers
            end
            return hideNums
        end
        if miniCCType == "overlay" then
            if config.overlayHideCountdownNumbers ~= nil then
                return config.overlayHideCountdownNumbers
            end
            return hideNums
        end

        return hideNums
    end

    -- Charge-based abilities: force-hide numbers on the main cooldown
    -- when a charge cooldown is actively displaying its own timer,
    -- preventing overlapping countdown text.
    if category == "actionbar" and not hideNums
       and IsMainCooldownWithActiveChargeCooldown(cdFrame) then
        hideNums = true
    end

    return hideNums
end

-- =========================================================================
-- STACK COUNT STYLING  (action bar + CooldownManager viewers)
-- =========================================================================

function Styler:StyleStackCount(cdFrame, config, category)
    if not config.stackEnabled then return end

    local parent = cdFrame:GetParent()
    if not parent then return end

    local countRegion

    if category == "actionbar" then
        -- Action bar: standard Count region on the button
        local parentName = parent.GetName and parent:GetName()
        countRegion = parent.Count or (parentName and _G[parentName .. "Count"])
    elseif category == "cooldownmanager" then
        -- CooldownManager viewers:
        -- EssentialCooldownViewer / UtilityCooldownViewer:
        --   ChargeCount is a Frame (setAllPoints), ChargeCount.Current is the FontString.
        -- BuffIconCooldownViewer:
        --   Applications is a Frame (setAllPoints), Applications.Applications is the FontString.
        local chargeCount = parent.ChargeCount
        if chargeCount and chargeCount.Current then
            countRegion = chargeCount.Current
        end
        if not countRegion then
            local applications = parent.Applications
            if applications and applications.Applications then
                countRegion = applications.Applications
            end
        end
    end

    if not countRegion or not countRegion.GetObjectType then return end
    if countRegion:GetObjectType() ~= "FontString" then return end
    if MCE:IsForbidden(countRegion) then return end

    ApplyFontStringStyle(
        countRegion,
        parent,
        MCE.ResolveFontPath(config.stackFont),
        config.stackSize,
        MCE.NormalizeFontStyle(config.stackStyle),
        config.stackColor,
        config.stackAnchor,
        config.stackAnchor,
        config.stackOffsetX,
        config.stackOffsetY,
        "OVERLAY",
        7)
end

local function GetCooldownFontSize(cdFrame, category, config)
    if category == "minicc" then
        local miniCCType = Classifier:GetMiniCCFrameType(cdFrame)
        if miniCCType == "cc" then
            return config.ccFontSize or config.fontSize
        end
        if miniCCType == "nameplate" then
            return config.nameplateFontSize or config.fontSize
        end
        if miniCCType == "portrait" then
            return config.portraitFontSize or config.fontSize
        end
        if miniCCType == "overlay" then
            return config.overlayFontSize or config.fontSize
        end
        return config.fontSize
    end

    if category ~= "cooldownmanager" then
        return config.fontSize
    end

    local viewerType = Classifier:GetCooldownManagerViewerType(cdFrame)
    if viewerType == "essential" then
        return config.essentialFontSize or config.fontSize
    end
    if viewerType == "utility" then
        return config.utilityFontSize or config.fontSize
    end
    if viewerType == "bufficon" then
        return config.buffIconFontSize or config.fontSize
    end

    return config.fontSize
end

-- =========================================================================
-- STYLE APPLICATION
-- =========================================================================
-- Main entry point called from the batch processor (ProcessDirtyFrames).
-- Uses change-detection on edge/countdown APIs to prevent visual flicker:
-- SetDrawEdge, SetEdgeScale, SetHideCountdownNumbers are only called when
-- their value actually differs from the last-applied value.

-- Aura-pending retry batching: coalesces deferred aura classifications
-- into a single timer pass, avoiding per-frame closure allocation.
local pendingAuras = {}
local auraRetryTimerScheduled = false

local function ProcessPendingAuras()
    auraRetryTimerScheduled = false
    for cdFrame in pairs(pendingAuras) do
        if cdFrame and not MCE:IsForbidden(cdFrame) then
            local retryCategory = Classifier:ClassifyFrame(cdFrame)
            if retryCategory == "aura_pending" then
                retryCategory = "global"
            end
            Classifier:SetCategory(cdFrame, retryCategory)
            Styler:ApplyStyle(cdFrame)
        end
    end
    wipe(pendingAuras)
end

function Styler:ApplyStyle(cdFrame, forcedCategory)
    if MCE:IsForbidden(cdFrame) then return end
    if Classifier:IsBlacklisted(cdFrame) then return end

    if forcedCategory == "nameplate" and Classifier:GetMiniCCFrameType(cdFrame) then
        forcedCategory = "minicc"
    end

    trackedCooldowns[cdFrame] = true

    -- Override cached category when a specific one is forced (e.g., "actionbar" from hooks)
    if forcedCategory and forcedCategory ~= "global" then
        if Classifier:GetCategory(cdFrame) ~= forcedCategory then
            Classifier:SetCategory(cdFrame, forcedCategory)
            styledCategory[cdFrame] = nil
        end
    end

    -- Guard: DB must be ready
    if not (MCE.db and MCE.db.profile and MCE.db.profile.categories) then return end

    local category = forcedCategory or Classifier:GetCategory(cdFrame)

    -- Handle deferred aura classification (single retry, then fallback to global)
    if category == "aura_pending" then
        Classifier:SetCategory(cdFrame, nil)
        pendingAuras[cdFrame] = true
        if not auraRetryTimerScheduled then
            auraRetryTimerScheduled = true
            C_Timer_After(0.1, ProcessPendingAuras)
        end
        return
    end

    if category == "blacklist" then return end

    local config = MCE.db.profile.categories[category]
    if not config or not config.enabled then
        ClearTrackedDurationColor(cdFrame)
        lastAppliedEdgeScale[cdFrame] = nil
        lastAppliedHideNums[cdFrame] = nil

        if category == "minicc" then
            local textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
            for i = 1, textRegionCount do
                fontStringStyleState[textRegions[i]] = nil
            end
            cooldownTextRegionState[cdFrame] = nil
        end

        -- Disabled category: clear edge only if we previously set it (anti-flicker)
        if lastAppliedEdge[cdFrame] ~= false then
            if cdFrame.SetDrawEdge then
                lastAppliedEdge[cdFrame] = false
                suppressEdgeEnforcement[cdFrame] = true
                pcall(cdFrame.SetDrawEdge, cdFrame, false)
                suppressEdgeEnforcement[cdFrame] = nil
            end
        else
            lastAppliedEdge[cdFrame] = false
        end
        return
    end

    -- === Edge glow — only call API when value actually changed ===
    if cdFrame.SetDrawEdge then
        if lastAppliedEdge[cdFrame] ~= config.edgeEnabled then
            suppressEdgeEnforcement[cdFrame] = true
            pcall(cdFrame.SetDrawEdge, cdFrame, config.edgeEnabled)
            suppressEdgeEnforcement[cdFrame] = nil
            lastAppliedEdge[cdFrame] = config.edgeEnabled
        end
        if config.edgeEnabled and cdFrame.SetEdgeScale then
            if lastAppliedEdgeScale[cdFrame] ~= config.edgeScale then
                suppressEdgeScaleEnforcement[cdFrame] = true
                pcall(cdFrame.SetEdgeScale, cdFrame, config.edgeScale)
                suppressEdgeScaleEnforcement[cdFrame] = nil
                lastAppliedEdgeScale[cdFrame] = config.edgeScale
            end
        else
            lastAppliedEdgeScale[cdFrame] = nil
        end
    end

    -- === Hide/show countdown numbers — only call API when value changed ===
    if cdFrame.SetHideCountdownNumbers then
        local hideNums = GetDesiredHideCountdownNumbers(cdFrame, category, config)

        if lastAppliedHideNums[cdFrame] ~= hideNums then
            suppressHideNumsEnforcement[cdFrame] = true
            pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
            suppressHideNumsEnforcement[cdFrame] = nil
            lastAppliedHideNums[cdFrame] = hideNums
        end
    end

    -- Skip full font re-style if category/viewer type hasn't changed.
    -- MiniCC text regions are tracked separately so recreated font strings
    -- still get styled without reapplying the style on every cooldown tick.
    local styleKey = category
    if category == "cooldownmanager" then
        local viewerType = Classifier:GetCooldownManagerViewerType(cdFrame) or "default"
        styleKey = category .. ":" .. viewerType
    elseif category == "minicc" then
        local miniCCType = Classifier:GetMiniCCFrameType(cdFrame) or "default"
        styleKey = category .. ":" .. miniCCType
    end

    local needsFullRestyle = styledCategory[cdFrame] ~= styleKey
    local textRegions, textRegionCount, textRegionsChanged

    if needsFullRestyle or category == "minicc" then
        textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
        textRegionsChanged = HaveCooldownTextRegionsChanged(cdFrame, textRegions, textRegionCount)
    end

    if needsFullRestyle then
        styledCategory[cdFrame] = styleKey

        -- Stack / charge counts (actionbar + CooldownManager viewers)
        self:StyleStackCount(cdFrame, config, category)
    end

    if needsFullRestyle or textRegionsChanged then
        -- Font string styling & positioning
        do
            local fontStyle    = MCE.NormalizeFontStyle(config.fontStyle)
            local resolvedFont = MCE.ResolveFontPath(config.font)
            local fontSize     = GetCooldownFontSize(cdFrame, category, config)
            local enforceFont = (category == "minicc")

            for i = 1, textRegionCount do
                local region = textRegions[i]
                ApplyFontStringStyle(
                    region,
                    cdFrame,
                    resolvedFont,
                    fontSize,
                    fontStyle,
                    config.textColor,
                    config.textAnchor,
                    config.textAnchor,
                    config.textOffsetX,
                    config.textOffsetY,
                    nil,
                    nil,
                    enforceFont)
            end
        end
    end

    -- Apply abbreviation threshold
    local profile = MCE.db and MCE.db.profile
    if profile and cdFrame.SetCountdownAbbrevThreshold then
        pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame, profile.abbrevThreshold or 59)
    end

    RefreshTrackedDurationColor(cdFrame, category, config)

end

-- =========================================================================
-- FORCE UPDATE
-- =========================================================================

function Styler:ForceUpdateAll(fullScan)
    -- Clear all caches so everything gets a fresh pass
    Classifier:WipeCache()
    wipe(styledCategory)
    wipe(fontStringStyleState)
    wipe(cooldownTextRegionState)
    wipe(lastAppliedEdge)
    wipe(lastAppliedEdgeScale)
    wipe(lastAppliedHideNums)
    wipe(durationColoredFrames)
    wipe(cooldownDurationInfo)
    InvalidateColorCurve()
    StopDurationColorTicker()

    if fullScan or not self.fullScanDone then
        self.fullScanDone = true
        local frame = EnumerateFrames()
        while frame do
            if not MCE:IsForbidden(frame) then
                if frame:IsObjectType("Cooldown") then
                    SyncCompactPartyAuraCooldown(frame)
                    self:QueueUpdate(frame)
                else
                    QueueKnownCooldownMembers(frame, QueueUpdateCallback)
                end
            end
            frame = EnumerateFrames(frame)
        end
        return
    end

    -- Incremental: only update previously tracked cooldowns
    for cd in pairs(trackedCooldowns) do
        if cd and cd.IsObjectType and cd:IsObjectType("Cooldown") then
            self:QueueUpdate(cd)
        end
    end

    for cd in pairs(compactPartyAuraFrames) do
        if cd and cd.IsObjectType and cd:IsObjectType("Cooldown") then
            SyncCompactPartyAuraCooldown(cd)
        end
    end
end

-- =========================================================================
-- HOOKS  (AceHook: auto-unhook on Disable)
-- =========================================================================
-- All hooks queue frames into the batch processor instead of applying styles
-- directly, eliminating flickering from rapid sequential hook fires.

function Styler:SetupHooks()
    if not self.enforcementHooksInstalled then
        local sampleCooldown = ActionButton1Cooldown
            or (ActionButton1 and (ActionButton1.cooldown or ActionButton1.Cooldown))

        if sampleCooldown then
            local cooldownAPI = getmetatable(sampleCooldown)
            cooldownAPI = cooldownAPI and cooldownAPI.__index or sampleCooldown

            if type(cooldownAPI) == "table" then
                if type(cooldownAPI.SetDrawEdge) == "function" then
                    hooksecurefunc(cooldownAPI, "SetDrawEdge", function(cooldown, value)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
                        if suppressEdgeEnforcement[cooldown] then return end

                        local desired = lastAppliedEdge[cooldown]
                        if desired == nil or IsSameValueSafe(desired, value) then return end

                        suppressEdgeEnforcement[cooldown] = true
                        pcall(cooldown.SetDrawEdge, cooldown, desired)
                        suppressEdgeEnforcement[cooldown] = nil
                    end)
                end

                if type(cooldownAPI.SetEdgeScale) == "function" then
                    hooksecurefunc(cooldownAPI, "SetEdgeScale", function(cooldown, value)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
                        if suppressEdgeScaleEnforcement[cooldown] then return end

                        local desired = lastAppliedEdgeScale[cooldown]
                        if desired == nil or IsSameValueSafe(desired, value) then return end

                        suppressEdgeScaleEnforcement[cooldown] = true
                        pcall(cooldown.SetEdgeScale, cooldown, desired)
                        suppressEdgeScaleEnforcement[cooldown] = nil
                    end)
                end

                if type(cooldownAPI.SetHideCountdownNumbers) == "function" then
                    hooksecurefunc(cooldownAPI, "SetHideCountdownNumbers", function(cooldown, value)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
                        if suppressHideNumsEnforcement[cooldown] then return end

                        local desired = lastAppliedHideNums[cooldown]
                        if desired == nil or IsSameValueSafe(desired, value) then return end

                        suppressHideNumsEnforcement[cooldown] = true
                        pcall(cooldown.SetHideCountdownNumbers, cooldown, desired)
                        suppressHideNumsEnforcement[cooldown] = nil
                    end)
                end

                if type(cooldownAPI.SetCooldown) == "function" then
                    hooksecurefunc(cooldownAPI, "SetCooldown", function(cooldown, startTime, duration, modRate)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end

                        local durationObject = CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
                        HandleCooldownDurationUpdate(cooldown, durationObject)
                    end)
                end

                if type(cooldownAPI.SetCooldownDuration) == "function" then
                    hooksecurefunc(cooldownAPI, "SetCooldownDuration", function(cooldown, duration, modRate)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end

                        local durationObject
                        if CanAccessAllValues(duration, modRate)
                           and type(duration) == "number"
                           and duration > 0 then
                            durationObject = CreateDurationFromEndTime(GetTime() + duration, duration, modRate or 1)
                        end

                        HandleCooldownDurationUpdate(cooldown, durationObject)
                    end)
                end

                if type(cooldownAPI.SetCooldownFromDurationObject) == "function" then
                    hooksecurefunc(cooldownAPI, "SetCooldownFromDurationObject", function(cooldown, durationObject)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
                        HandleCooldownDurationUpdate(cooldown, durationObject)
                    end)
                end

                if type(cooldownAPI.SetCooldownFromExpirationTime) == "function" then
                    hooksecurefunc(cooldownAPI, "SetCooldownFromExpirationTime", function(cooldown, expirationTime, duration, modRate)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end

                        local durationObject = CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
                        HandleCooldownDurationUpdate(cooldown, durationObject)
                    end)
                end

                if type(cooldownAPI.Clear) == "function" then
                    hooksecurefunc(cooldownAPI, "Clear", function(cooldown)
                        if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then return end
                        ClearTrackedDurationColor(cooldown)
                    end)
                end

                self.enforcementHooksInstalled = true
            end
        end
    end

    -- Primary hook: fires on every cooldown start/reset
    self:SecureHook("CooldownFrame_Set", function(f)
        if f and not IsSecretValue(f) and not MCE:IsForbidden(f) then self:QueueUpdate(f) end
    end)

    -- Action button specific hook (provides forced "actionbar" category)
    if ActionButton_UpdateCooldown then
        self:SecureHook("ActionButton_UpdateCooldown", function(button)
            local cd = button and (button.cooldown or button.Cooldown)
            if cd then self:QueueUpdate(cd, "actionbar") end

            local chargeCD = button and (button.chargeCooldown or button.ChargeCooldown)
            if chargeCD then self:QueueUpdate(chargeCD, "actionbar") end
        end)
    end

    -- LibActionButton support (Bartender4, etc.)
    local LAB = LibStub("LibActionButton-1.0", true)
    if LAB then
        LAB:RegisterCallback("OnButtonUpdate", function(_, button)
            local cd = button and (button.cooldown or button.Cooldown)
            if cd then
                self:QueueUpdate(cd, "actionbar")
            end

            local chargeCD = button and (button.chargeCooldown or button.ChargeCooldown)
            if chargeCD then
                self:QueueUpdate(chargeCD, "actionbar")
            end
        end)
    end
end

-- =========================================================================
-- NAMEPLATE EVENTS
-- =========================================================================

-- Nameplate add batching: coalesces multiple NAME_PLATE_UNIT_ADDED events
-- into a single deferred scan pass, avoiding per-event closure allocation.
local pendingNameplates = {}
local nameplateAddTimerScheduled = false

local function ProcessPendingNameplates()
    nameplateAddTimerScheduled = false
    for plate in pairs(pendingNameplates) do
        if plate and not MCE:IsForbidden(plate) then
            Styler:StyleCooldownsInFrame(plate, "nameplate", 10)
        end
    end
    wipe(pendingNameplates)
end

function Styler:NAME_PLATE_UNIT_ADDED(_, unit)
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return end

    -- Batch nameplate adds to avoid per-event closure allocation
    pendingNameplates[plate] = true
    if not nameplateAddTimerScheduled then
        nameplateAddTimerScheduled = true
        C_Timer_After(0.05, ProcessPendingNameplates)
    end
end

function Styler:RefreshVisibleNameplates()
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end

    for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do
        if plate and not MCE:IsForbidden(plate) then
            self:StyleCooldownsInFrame(plate, "nameplate", 10)
        end
    end
end

function Styler:PLAYER_REGEN_DISABLED()
    if self.nameplateTicker then return end
    self.nameplateTicker = C_Timer.NewTicker(0.5, function()
        self:RefreshVisibleNameplates()
    end)
end

function Styler:PLAYER_REGEN_ENABLED()
    if self.nameplateTicker then
        self.nameplateTicker:Cancel()
        self.nameplateTicker = nil
    end
end

-- =========================================================================
-- SCOPED SCANNING
-- =========================================================================
-- Scans a frame tree and queues all Cooldown frames found for batch style
-- processing. Used primarily for nameplate scanning.
-- Refactored as methods to avoid per-call closure + table allocation.

--- Vararg helper: processes children without allocating a table from GetChildren().
function Styler:ScanChildren(forcedCategory, maxDepth, newDepth, ...)
    for i = 1, select("#", ...) do
        local child = select(i, ...)
        if child then
            self:ScanFrameRecursive(child, forcedCategory, maxDepth, newDepth)
        end
    end
end

function Styler:ScanFrameRecursive(frame, forcedCategory, maxDepth, depth)
    if not frame or depth > maxDepth then return end
    if MCE:IsForbidden(frame) then return end

    if frame.IsObjectType and frame:IsObjectType("Cooldown") then
        self:QueueUpdate(frame, forcedCategory)
    else
        QueueKnownCooldownMembers(frame, QueueUpdateCallback, forcedCategory)
    end

    local childCount = frame.GetNumChildren and frame:GetNumChildren() or 0
    if childCount > 0 and frame.GetChildren then
        self:ScanChildren(forcedCategory, maxDepth, depth + 1, frame:GetChildren())
    end
end

function Styler:StyleCooldownsInFrame(rootFrame, forcedCategory, maxDepth)
    if not rootFrame then return end
    self:ScanFrameRecursive(rootFrame, forcedCategory, maxDepth or 5, 0)
end
