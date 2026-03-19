-- Styler.lua

local MCE        = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Styler     = MCE:NewModule("Styler")
local Classifier = MCE:GetModule("Classifier")

local pairs, ipairs, type, pcall, wipe = pairs, ipairs, type, pcall, wipe
local math_abs = math.abs
local strfind = string.find
local setmetatable = setmetatable
local select = select
local C_Timer_After = C_Timer.After
local GetTime = GetTime
local EnumerateFrames  = EnumerateFrames
local hooksecurefunc = hooksecurefunc
local issecretvalue = issecretvalue or function() return false end
local canaccessallvalues = canaccessallvalues

local weakMeta = { __mode = "k" }

local frameState = setmetatable({}, weakMeta)
local fontState  = setmetatable({}, weakMeta)

local trackedCooldowns      = setmetatable({}, weakMeta)
local durationColoredFrames = setmetatable({}, weakMeta)
local compactPartyAuraFrames = setmetatable({}, weakMeta)
local activeDurationFrames  = setmetatable({}, weakMeta)
local hookedCooldowns       = setmetatable({}, weakMeta)

local durationColorTicker = nil
local durationColorCurve = nil
local activeDurationFrameCount = 0
local durationCacheSweepCounter = 0
local durationObjectCache = setmetatable({}, {
    __call = function(self, endTime, duration, modRate)
        if type(endTime) ~= "number" or type(duration) ~= "number" then
            return nil
        end

        local key = endTime .. ":" .. duration .. ":" .. (modRate or 1)
        local cached = self[key]
        if not cached then
            if not (C_DurationUtil and C_DurationUtil.CreateDuration) then
                return nil
            end

            cached = C_DurationUtil.CreateDuration()
            self[key] = cached
        end

        if not (cached and cached.SetTimeFromEnd) then
            return nil
        end

        cached:SetTimeFromEnd(endTime, duration, modRate or 1)
        return cached
    end
})

local function GetFrameState(frame)
    local s = frameState[frame]
    if not s then
        s = {}
        frameState[frame] = s
    end
    return s
end

local function GetFontState(region)
    local s = fontState[region]
    if not s then
        s = {}
        fontState[region] = s
    end
    return s
end

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
    durationCacheSweepCounter = 0
end

local RefreshTrackedDurationColor
local ClearTrackedDurationColor
local StartDurationColorTicker
local ResolveCooldownContext

local function AddActiveDurationFrame(cdFrame)
    if not cdFrame or activeDurationFrames[cdFrame] then
        return
    end

    activeDurationFrames[cdFrame] = true
    activeDurationFrameCount = activeDurationFrameCount + 1
end

local function RemoveActiveDurationFrame(cdFrame)
    if not activeDurationFrames[cdFrame] then
        return
    end

    activeDurationFrames[cdFrame] = nil
    if activeDurationFrameCount > 0 then
        activeDurationFrameCount = activeDurationFrameCount - 1
    end
end

local function OnTrackedCooldownShow(cooldown)
    if not cooldown or IsSecretValue(cooldown) or MCE:IsForbidden(cooldown) then
        return
    end

    if durationColoredFrames[cooldown] then
        AddActiveDurationFrame(cooldown)
        StartDurationColorTicker()
    end
end

local function OnTrackedCooldownHide(cooldown)
    if not cooldown or IsSecretValue(cooldown) then
        return
    end

    RemoveActiveDurationFrame(cooldown)
    if activeDurationFrameCount == 0 then
        StopDurationColorTicker()
    end
end

local function OnTrackedCooldownDone(cooldown)
    if not cooldown or IsSecretValue(cooldown) then
        return
    end

    ClearTrackedDurationColor(cooldown)
end

local function EnsureCooldownLifecycleHooks(cooldown)
    if not cooldown or hookedCooldowns[cooldown] or type(cooldown.HookScript) ~= "function" then
        return
    end

    cooldown:HookScript("OnShow", OnTrackedCooldownShow)
    cooldown:HookScript("OnHide", OnTrackedCooldownHide)
    cooldown:HookScript("OnCooldownDone", OnTrackedCooldownDone)
    hookedCooldowns[cooldown] = true
end

local MAX_COOLDOWN_OWNER_SCAN_DEPTH = 10

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
    local fs = ResolveCooldownContext and ResolveCooldownContext(cdFrame) or nil
    local frameType = fs and fs.compactPartyAuraType
    return frameType and frameType ~= false and frameType or nil
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
    if issecretvalue(a) or issecretvalue(b) then 
        return false 
    end
    return a == b
end

local function rawNearlyEqual(left, right)
    return math_abs(left - right) < 0.001
end

local function IsNearlyEqual(a, b)
    if issecretvalue(a) or issecretvalue(b) then 
        return false 
    end

    if a == b then return true end
    
    if type(a) ~= "number" or type(b) ~= "number" then
        return false
    end
    
    return math_abs(a - b) < 0.001
end

local function GetSwipeShadeAlpha(config)
    local alphaPercent = config and config.swipeAlpha
    if type(alphaPercent) ~= "number" then
        alphaPercent = 80
    end

    if alphaPercent < 0 then
        alphaPercent = 0
    elseif alphaPercent > 100 then
        alphaPercent = 100
    end

    return alphaPercent / 100
end

local function IsSameSwipeColor(state, r, g, b, a)
    return state
       and IsNearlyEqual(state.r, r)
       and IsNearlyEqual(state.g, g)
       and IsNearlyEqual(state.b, b)
       and IsNearlyEqual(state.a, a)
end

local function ResetSwipeColor(cdFrame)
    if not cdFrame or type(cdFrame.SetSwipeColor) ~= "function" then
        return
    end

    local fs = frameState[cdFrame]
    if not fs or not fs.swipeColor then
        return
    end

    fs.suppressSwipe = true
    pcall(cdFrame.SetSwipeColor, cdFrame, 0, 0, 0)
    fs.suppressSwipe = nil
    fs.swipeColor = nil
end

local function EnsureFontStringSetFontHook(region)
    local fs = GetFontState(region)
    if fs.hooked or not region.SetFont then return end

    hooksecurefunc(region, "SetFont", function(self, fontPath, fontSize, fontStyle)
        -- Protection Midnight : on ignore si la frame ou la police est un secret
        if issecretvalue(self) or issecretvalue(fontPath) then return end

        local s = fontState[self]
        if not s or s.suppressSetFont or not s.enforceFont then return end

        -- Fast path absolu
        if IsSameValueSafe(fontPath, s.fontPath) 
           and IsNearlyEqual(fontSize, s.fontSize) 
           and IsSameValueSafe(fontStyle, s.fontStyle) then
            return
        end

        s.suppressSetFont = true
        pcall(self.SetFont, self, s.fontPath, s.fontSize, s.fontStyle)
        s.suppressSetFont = nil
    end)

    fs.hooked = true
end

local function HaveCooldownTextRegionsChanged(cdFrame, textRegions, textRegionCount)
    local fs = GetFrameState(cdFrame)
    local trState = fs.textRegions
    if not trState then
        trState = {}
        fs.textRegions = trState
    end

    local changed = (trState.count ~= textRegionCount)
    for i = 1, textRegionCount do
        if trState[i] ~= textRegions[i] then
            changed = true
        end
        trState[i] = textRegions[i]
    end
    for i = textRegionCount + 1, trState.count or 0 do
        trState[i] = nil
    end
    trState.count = textRegionCount

    return changed
end

local function ApplyFontStringStyle(region, relativeFrame, fontPath, fontSize, fontStyle,
                                    color, point, relativePoint, offsetX, offsetY,
                                    drawLayer, drawLayerSubLevel, enforceFont)
    if not region or MCE:IsForbidden(region) then return end

    relativePoint = relativePoint or point
    drawLayerSubLevel = drawLayerSubLevel or 0

    local state = GetFontState(region)
    state.enforceFont = enforceFont or false

    if state.fontPath ~= fontPath
       or state.fontSize ~= fontSize
       or state.fontStyle ~= fontStyle then
        if state.enforceFont then
            EnsureFontStringSetFontHook(region)
        end
        state.suppressSetFont = true
        region:SetFont(fontPath, fontSize, fontStyle)
        state.suppressSetFont = nil
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

    GetFrameState(cdFrame).appliedTextColor = nil

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
    local fs = GetFrameState(cdFrame)
    if fs.hideNums == hide then return end

    fs.suppressHideNums = true
    pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hide)
    fs.suppressHideNums = nil
    fs.hideNums = hide
end

local function SyncCompactPartyAuraCooldown(cdFrame)
    local frameType = GetCompactPartyAuraFrameType(cdFrame)
    if not frameType then return false end
    compactPartyAuraFrames[cdFrame] = true

    local config = GetCompactPartyAuraConfig()
    if not ShouldUseCompactPartyAuraText(config, frameType) then
        ClearTrackedDurationColor(cdFrame)
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

-- Pre-defined callback to avoid closure allocation in ForceUpdateAll
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

local function IsAssistedCombatActionCooldown(cdFrame)
    if not cdFrame or not C_ActionBar or type(C_ActionBar.IsAssistedCombatAction) ~= "function" then
        return false
    end

    local parent = cdFrame.GetParent and cdFrame:GetParent() or nil
    if not parent or MCE:IsForbidden(parent) then
        return false
    end

    local actionID = GetActionIDFromButton(parent)
    if not actionID and ResolveCooldownContext then
        local fs = ResolveCooldownContext(cdFrame)
        actionID = fs and fs.actionID ~= false and fs.actionID or nil
    end

    if type(actionID) ~= "number" then
        return false
    end

    local ok, isAssisted = pcall(C_ActionBar.IsAssistedCombatAction, actionID)
    return ok and isAssisted == true
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

local function GetCachedCooldownTextRegions(cdFrame)
    local fs = frameState[cdFrame]
    local trackedRegions = fs and fs.textRegions
    if trackedRegions and (trackedRegions.count or 0) > 0 then
        return trackedRegions, trackedRegions.count
    end

    local textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
    HaveCooldownTextRegionsChanged(cdFrame, textRegions, textRegionCount)

    fs = frameState[cdFrame]
    trackedRegions = fs and fs.textRegions
    if trackedRegions then
        return trackedRegions, trackedRegions.count or 0
    end

    return textRegions, textRegionCount
end

local function SetCooldownTextRegionsVisible(cdFrame, visible)
    local textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)

    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and not MCE:IsForbidden(region) then
            if visible then
                region:SetAlpha(1)
                region:Show()
            else
                region:SetAlpha(0)
                region:Hide()
            end
        end
    end
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

    local offset = durationConfig.offset
    if type(offset) ~= "number" then
        offset = 0
    end
    
    -- Intermediate threshold points (use exact threshold values for precise transitions)
    for i = 2, #sortedThresholds do
        local startAt = (sortedThresholds[i - 1].threshold or 0) + offset
        if startAt < 0 then
            startAt = 0
        end
        local c = sortedThresholds[i].color
        curve:AddPoint(startAt, CreateColor(c.r, c.g, c.b, c.a or 1))
    end

    -- Default color for durations beyond the last threshold
    if durationConfig.defaultColor then
        local startAt = (sortedThresholds[#sortedThresholds].threshold or 0) + offset
        if startAt < 0 then
            startAt = 0
        end
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

local function IsDurationColorEnabledForSource(cdFrame, sourceKey, config)
    local durationConfig = GetDurationTextColorsConfig()
    if not durationConfig or not durationConfig.enabled or not config then
        return false
    end

    if sourceKey == "nameplate" then
        return false
    end

    if sourceKey == "compactPartyAura" then
        local frameType = GetCompactPartyAuraFrameType(cdFrame)
        return frameType and ShouldUseCompactPartyAuraText(config, frameType) or false
    end

    return config.enabled == true
end

local function ApplyRGBAColorToCooldownRegions(cdFrame, r, g, b, a)
    local textRegions, textRegionCount = GetCachedCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    local fs = GetFrameState(cdFrame)
    if IsSameSwipeColor(fs.appliedTextColor, r, g, b, a) then
        return true
    end

    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and not MCE:IsForbidden(region) then
            region:SetTextColor(r, g, b, a)
        end
    end

    local applied = fs.appliedTextColor or {}
    applied.r = r
    applied.g = g
    applied.b = b
    applied.a = a
    fs.appliedTextColor = applied

    return true
end

local function ApplyTextColorToCooldownRegions(cdFrame, color)
    if not color then
        return false
    end

    return ApplyRGBAColorToCooldownRegions(cdFrame, color.r, color.g, color.b, color.a)
end

local function CreateDurationFromEndTime(endTime, duration, modRate)
    return durationObjectCache(endTime, duration, modRate or 1)
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

ResolveCooldownContext = function(cdFrame, forceRefresh)
    local fs = GetFrameState(cdFrame)
    if fs.contextResolved and not forceRefresh then
        return fs
    end

    local current = cdFrame and cdFrame.GetParent and cdFrame:GetParent() or nil
    local actionButton, actionID
    local spellOwner
    local auraInstanceOwner
    local auraUnitOwner
    local compactPartyAuraType = false
    local sawAuraContext = false
    local hasAuraNamedAncestor = false

    for _ = 1, MAX_COOLDOWN_OWNER_SCAN_DEPTH do
        if not current then break end

        if not actionButton then
            local resolvedActionID = GetActionIDFromButton(current)
            if resolvedActionID then
                actionButton = current
                actionID = resolvedActionID
            end
        end

        if not spellOwner and GetCooldownSpellID(current) ~= nil then
            spellOwner = current
        end

        if not auraInstanceOwner and GetFrameAuraInstanceID(current) ~= nil then
            auraInstanceOwner = current
        end

        if not auraUnitOwner and GetFrameUnitToken(current) ~= nil then
            auraUnitOwner = current
        end

        local name = current.GetName and current:GetName() or ""
        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true) then
            hasAuraNamedAncestor = true
            sawAuraContext = true
            if compactPartyAuraType == false then
                if strfind(name, "CompactPartyFrame", 1, true) then
                    compactPartyAuraType = "party"
                elseif strfind(name, "CompactRaidFrame", 1, true) then
                    compactPartyAuraType = "raid"
                end
            end
        end

        if compactPartyAuraType == false and sawAuraContext and strfind(name, "Compact", 1, true) then
            local unitType = GetCompactGroupFrameTypeFromUnit(GetFrameUnitToken(current))
            if unitType then
                compactPartyAuraType = unitType
            end
        end

        current = current.GetParent and current:GetParent() or nil
    end

    fs.contextResolved = true
    fs.actionButton = actionButton or false
    fs.actionID = actionID or false
    fs.spellOwner = spellOwner or false
    fs.auraInstanceOwner = auraInstanceOwner or false
    fs.auraUnitOwner = auraUnitOwner or false
    fs.compactPartyAuraType = compactPartyAuraType or false
    fs.hasAuraNamedAncestor = hasAuraNamedAncestor or false
    return fs
end

local function GetAuraDurationContext(cdFrame)
    local fs = ResolveCooldownContext(cdFrame)
    local auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
    local unitOwner = fs.auraUnitOwner ~= false and fs.auraUnitOwner or nil
    local auraInstanceID = GetFrameAuraInstanceID(auraOwner)
    local unitToken = GetFrameUnitToken(unitOwner)

    if (not auraInstanceID or not unitToken) and fs.hasAuraNamedAncestor then
        fs = ResolveCooldownContext(cdFrame, true)
        auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
        unitOwner = fs.auraUnitOwner ~= false and fs.auraUnitOwner or nil
        auraInstanceID = GetFrameAuraInstanceID(auraOwner)
        unitToken = GetFrameUnitToken(unitOwner)
    end

    if auraInstanceID and unitToken then
        return auraInstanceID, unitToken, auraOwner or unitOwner
    end

    return nil, nil, nil
end

local function GetSpellCooldownOwner(cdFrame)
    local fs = ResolveCooldownContext(cdFrame)
    return fs.spellOwner ~= false and fs.spellOwner or nil
end

local function ShouldUseAuraDurationFallback(cdFrame)
    local category = Classifier:GetCategory(cdFrame)
    if category == "actionbar" or category == "minicc" then
        return false
    end

    if category == "cooldownmanager" then
        local viewerType = Classifier:GetCooldownManagerViewerType(cdFrame)
        return viewerType == "bufficon"
    end

    if category == "nameplate" or category == "unitframe" then
        return true
    end

    local fs = ResolveCooldownContext(cdFrame)
    return fs.hasAuraNamedAncestor == true
end

local function IsAuraDrivenCooldown(cdFrame)
    if not ShouldUseAuraDurationFallback(cdFrame) then
        return false
    end

    local auraInstanceID, unitToken = GetAuraDurationContext(cdFrame)
    if auraInstanceID and unitToken then
        return true
    end

    local fs = ResolveCooldownContext(cdFrame)
    return fs.hasAuraNamedAncestor == true
end

local function GetFallbackDurationObject(cdFrame)
    local parent = cdFrame and cdFrame.GetParent and cdFrame:GetParent()
    if not parent then return nil end

    local fs = ResolveCooldownContext(cdFrame)
    local actionButton = fs.actionButton ~= false and fs.actionButton or parent
    local actionID = fs.actionID ~= false and fs.actionID or GetActionIDFromButton(actionButton)
    if actionID and C_ActionBar then
        if IsChargeCooldownFrame(cdFrame, actionButton) and C_ActionBar.GetActionChargeDuration then
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

    if ShouldUseAuraDurationFallback(cdFrame) then
        local auraInstanceID, unitToken = GetAuraDurationContext(cdFrame)

        if auraInstanceID and unitToken and C_UnitAuras and C_UnitAuras.GetAuraDuration then
            local ok, durationObject = pcall(C_UnitAuras.GetAuraDuration, unitToken, auraInstanceID)
            if ok and durationObject then
                return durationObject
            end
        end
    end

    local spellOwner = GetSpellCooldownOwner(cdFrame) or actionButton or parent
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
        GetFrameState(cdFrame).durationObject = durationObject
    else
        local fs = frameState[cdFrame]
        if fs then fs.durationObject = nil end
    end
end

local function GetCooldownDurationObject(cdFrame)
    local fs = frameState[cdFrame]
    if fs and fs.durationObject then
        return fs.durationObject
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

    local textRegions, textRegionCount = GetCachedCooldownTextRegions(cdFrame)
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
        return ApplyRGBAColorToCooldownRegions(cdFrame, r, g, b, a)
    end

    ResetCountdownTextColor(cdFrame, config)
    return false
end

ClearTrackedDurationColor = function(cdFrame)
    RemoveActiveDurationFrame(cdFrame)
    durationColoredFrames[cdFrame] = nil
    local fs = frameState[cdFrame]
    if fs then
        fs.durationObject = nil
        fs.appliedTextColor = nil
    end

    if activeDurationFrameCount == 0 then
        StopDurationColorTicker()
    end
end

local function PurgeExpiredDurationObjects()
    for key, durationObject in pairs(durationObjectCache) do
        if durationObject
           and durationObject.IsZero
           and durationObject:IsZero() then
            durationObjectCache[key] = nil
        end
    end
end

local function UpdateDurationColors()
    local curve = GetColorCurve()
    if not curve then
        for cdFrame, sourceKey in pairs(durationColoredFrames) do
            ResetCountdownTextColor(cdFrame, GetDurationTextSourceConfig(sourceKey))
            ClearTrackedDurationColor(cdFrame)
        end
        StopDurationColorTicker()
        return
    end

    durationCacheSweepCounter = durationCacheSweepCounter + 1
    if durationCacheSweepCounter >= 10 then
        durationCacheSweepCounter = 0
        PurgeExpiredDurationObjects()
    end

    local activeCount = 0

    for cdFrame in pairs(activeDurationFrames) do
        local sourceKey = durationColoredFrames[cdFrame]
        if not sourceKey then
            RemoveActiveDurationFrame(cdFrame)
        else
            local config = GetDurationTextSourceConfig(sourceKey)
            if cdFrame and not MCE:IsForbidden(cdFrame)
               and IsDurationColorEnabledForSource(cdFrame, sourceKey, config)
               and ApplyCooldownDurationColor(cdFrame, config, curve) then
                activeCount = activeCount + 1
            else
                if config then
                    ResetCountdownTextColor(cdFrame, config)
                end
                ClearTrackedDurationColor(cdFrame)
            end
        end
    end

    if activeCount == 0 then
        StopDurationColorTicker()
    end
end

StartDurationColorTicker = function()
    if durationColorTicker then return end
    durationColorTicker = C_Timer.NewTicker(0.5, UpdateDurationColors)
end

RefreshTrackedDurationColor = function(cdFrame, sourceKey, config)
    if not IsDurationColorEnabledForSource(cdFrame, sourceKey, config) then
        ClearTrackedDurationColor(cdFrame)
        ResetCountdownTextColor(cdFrame, config)
        return false
    end

    local curve = GetColorCurve()
    if curve and ApplyCooldownDurationColor(cdFrame, config, curve) then
        EnsureCooldownLifecycleHooks(cdFrame)
        durationColoredFrames[cdFrame] = sourceKey
        if cdFrame.IsVisible and cdFrame:IsVisible() then
            AddActiveDurationFrame(cdFrame)
            StartDurationColorTicker()
        else
            RemoveActiveDurationFrame(cdFrame)
        end
        return true
    end

    ClearTrackedDurationColor(cdFrame)
    ResetCountdownTextColor(cdFrame, config)
    return false
end

local function HandleCooldownDurationUpdate(cooldown, durationObject)
    if not cooldown or MCE:IsForbidden(cooldown) or IsSecretValue(cooldown) then return end

    SetCooldownDurationObject(cooldown, durationObject)

    -- Blizzard may reset visual state (text color, edge, etc.) alongside a
    -- cooldown update.  Invalidate the text-color cache so the next style
    -- pass unconditionally re-applies the correct color.
    local fs = frameState[cooldown]
    if fs then
        fs.appliedTextColor = nil
    end

    local sourceKey = durationColoredFrames[cooldown]
    if sourceKey then
        local curve = GetColorCurve()
        local config = GetDurationTextSourceConfig(sourceKey)
        if curve and IsDurationColorEnabledForSource(cooldown, sourceKey, config) then
            ApplyCooldownDurationColor(cooldown, config, curve)
        else
            if config then
                ResetCountdownTextColor(cooldown, config)
            end
            ClearTrackedDurationColor(cooldown)
        end
    end

    if SyncCompactPartyAuraCooldown(cooldown) then
        return
    end

    Styler:QueueUpdate(cooldown)

    local fs = frameState[cooldown]
    if IsAuraDrivenCooldown(cooldown) and not (fs and fs.pendingAuraRefresh) then
        GetFrameState(cooldown).pendingAuraRefresh = true
        C_Timer_After(0, function()
            local fs2 = frameState[cooldown]
            if fs2 then fs2.pendingAuraRefresh = nil end

            if not cooldown or MCE:IsForbidden(cooldown) or IsSecretValue(cooldown) then
                return
            end

            if fs2 then
                fs2.durationObject = nil
                fs2.contextResolved = nil
            end

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
    -- This matters most on action buttons,
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

    C_Timer_After(2, function()
        self:ForceUpdateAll(true)
    end)
end

function Styler:OnDisable()
    for cd in pairs(compactPartyAuraFrames) do
        if cd and not MCE:IsForbidden(cd) then
            SetCompactPartyAuraNativeTextVisible(cd, true)
            SetCompactPartyAuraNativeHide(cd, false)
        end
    end
    wipe(compactPartyAuraFrames)
    StopDurationColorTicker()
    wipe(durationColoredFrames)
    wipe(activeDurationFrames)
    activeDurationFrameCount = 0
    wipe(durationObjectCache)
    wipe(pendingAuras)
    wipe(frameState)
    wipe(fontState)
    -- AceHook auto-unhooks global hooks; per-frame HookScript hooks are harmless.
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

    -- Force hide countdown text on Assisted Combat action buttons
    if category == "actionbar" and IsAssistedCombatActionCooldown(cdFrame) then
        return true
    end

    if category == "actionbar" and not hideNums then
        local parent = cdFrame.GetParent and cdFrame:GetParent() or nil
        local isChargeCooldown = IsChargeCooldownFrame(cdFrame, parent)

        if config.hideChargeTimers and isChargeCooldown then
            hideNums = true
        elseif not config.hideChargeTimers
           and IsMainCooldownWithActiveChargeCooldown(cdFrame) then
            -- Default behavior: keep only the per-charge timer visible.
            hideNums = true
        end
    end

    return hideNums
end

-- =========================================================================
-- STACK COUNT STYLING  (action bar + CooldownManager viewers)
-- =========================================================================

local function GetStackCountRegion(cdFrame, category)
    local parent = cdFrame:GetParent()
    if not parent then return nil, nil end

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

    if not countRegion or not countRegion.GetObjectType then return nil, parent end
    if countRegion:GetObjectType() ~= "FontString" then return nil, parent end
    if MCE:IsForbidden(countRegion) then return nil, parent end

    return countRegion, parent
end

function Styler:StyleStackCount(cdFrame, config, category)
    local countRegion, parent = GetStackCountRegion(cdFrame, category)
    if not countRegion or not parent then return end

    if config.hideStackText then
        countRegion:SetAlpha(0)
        countRegion:Hide()
        return
    end

    countRegion:SetAlpha(1)
    countRegion:Show()

    if not config.stackEnabled then return end

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
-- SetDrawEdge, SetEdgeScale, SetSwipeColor, and SetHideCountdownNumbers are
-- only called when
-- their value actually differs from the last-applied value.

-- Aura-pending retry batching: coalesces deferred aura classifications
-- into a single timer pass, avoiding per-frame closure allocation.
local pendingAuras = {}
local auraRetryTimerScheduled = false

local function ProcessPendingAuras()
    auraRetryTimerScheduled = false
    for cdFrame in pairs(pendingAuras) do
        if cdFrame and not MCE:IsForbidden(cdFrame) then
            local fs = frameState[cdFrame]
            if fs then
                fs.contextResolved = nil
            end
            local cachedCategory = nil
            if Classifier:IsCached(cdFrame) then
                cachedCategory = Classifier:GetCategory(cdFrame)
            end

            local retryCategory = cachedCategory
            if retryCategory == nil or retryCategory == "global" or retryCategory == "aura_pending" then
                retryCategory = Classifier:ClassifyFrame(cdFrame)
                if retryCategory == "aura_pending" then
                    retryCategory = cachedCategory ~= "aura_pending" and cachedCategory or "global"
                end
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

    if forcedCategory and forcedCategory ~= "global" then
        if Classifier:GetCategory(cdFrame) ~= forcedCategory then
            Classifier:SetCategory(cdFrame, forcedCategory)
            local fs = frameState[cdFrame]
            if fs then fs.styledCat = nil end
        end
    end

    -- Guard: DB must be ready
    if not (MCE.db and MCE.db.profile and MCE.db.profile.categories) then return end

    local category = forcedCategory or Classifier:GetCategory(cdFrame)
    local isAssistedCombat = (category == "actionbar" and IsAssistedCombatActionCooldown(cdFrame))

    -- Handle deferred aura classification (single retry, then fallback to global)
    if category == "aura_pending" then
        local fs = frameState[cdFrame]
        if fs then
            fs.contextResolved = nil
        end
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
        local hadTrackedDurationColor = durationColoredFrames[cdFrame] ~= nil
        ClearTrackedDurationColor(cdFrame)
        if hadTrackedDurationColor and config then
            ResetCountdownTextColor(cdFrame, config)
        end
        local fs = GetFrameState(cdFrame)
        fs.edgeScale = nil
        fs.hideNums = nil
        fs.drawSwipe = nil
        ResetSwipeColor(cdFrame)

        if category == "minicc" then
            local textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
            for i = 1, textRegionCount do
                fontState[textRegions[i]] = nil
            end
            fs.textRegions = nil
        end

        if fs.edge ~= false then
            if cdFrame.SetDrawEdge then
                fs.edge = false
                fs.suppressEdge = true
                pcall(cdFrame.SetDrawEdge, cdFrame, false)
                fs.suppressEdge = nil
            end
        else
            fs.edge = false
        end
        return
    end

    local fs = GetFrameState(cdFrame)
    local parent = cdFrame.GetParent and cdFrame:GetParent()

    local isChargeCooldown = IsChargeCooldownFrame(cdFrame, parent)
    local hasActiveCharge = isChargeCooldown and IsMainCooldownWithActiveChargeCooldown(cdFrame)

    -- Draw Swipe (dark overlay animation)
    local wantSwipe = config.drawSwipe ~= false and (not isChargeCooldown or hasActiveCharge)

    if cdFrame.SetDrawSwipe then
        if fs.drawSwipe ~= wantSwipe then
            fs.suppressSwipeDraw = true
            pcall(cdFrame.SetDrawSwipe, cdFrame, wantSwipe)
            fs.suppressSwipeDraw = nil
            fs.drawSwipe = wantSwipe
        end
    end

    if cdFrame.SetDrawEdge then
        if fs.edge ~= config.edgeEnabled then
            fs.suppressEdge = true
            pcall(cdFrame.SetDrawEdge, cdFrame, config.edgeEnabled)
            fs.suppressEdge = nil
            fs.edge = config.edgeEnabled
        end
        if config.edgeEnabled and cdFrame.SetEdgeScale then
            if fs.edgeScale ~= config.edgeScale then
                fs.suppressEdgeScale = true
                pcall(cdFrame.SetEdgeScale, cdFrame, config.edgeScale)
                fs.suppressEdgeScale = nil
                fs.edgeScale = config.edgeScale
            end
        else
            fs.edgeScale = nil
        end
    end

    if cdFrame.SetSwipeColor then
        if category == "actionbar" then
            local r, g, b, a = 0, 0, 0, GetSwipeShadeAlpha(config)
            if not IsSameSwipeColor(fs.swipeColor, r, g, b, a) then
                fs.suppressSwipe = true
                pcall(cdFrame.SetSwipeColor, cdFrame, r, g, b, a)
                fs.suppressSwipe = nil
                fs.swipeColor = { r = r, g = g, b = b, a = a }
            end
        else
            ResetSwipeColor(cdFrame)
        end
    end

    local hideNums

    if cdFrame.SetHideCountdownNumbers then
        hideNums = isAssistedCombat or GetDesiredHideCountdownNumbers(cdFrame, category, config)

        if fs.hideNums ~= hideNums then
            fs.suppressHideNums = true
            pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
            fs.suppressHideNums = nil
            fs.hideNums = hideNums
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

    local needsFullRestyle = fs.styledCat ~= styleKey
    local textRegions, textRegionCount, textRegionsChanged

    if needsFullRestyle or category == "minicc" then
        textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
        textRegionsChanged = HaveCooldownTextRegionsChanged(cdFrame, textRegions, textRegionCount)
    end

    if needsFullRestyle then
        fs.styledCat = styleKey
    end

    -- Stack / charge counts can be shown again by Blizzard button updates,
    -- so visibility enforcement needs to run on every style pass.
    self:StyleStackCount(cdFrame, config, category)

    if isAssistedCombat then
        if not fs.assistedCombatTextHidden then
            SetCooldownTextRegionsVisible(cdFrame, false)
            fs.assistedCombatTextHidden = true
        end

        ClearTrackedDurationColor(cdFrame)
        return
    elseif fs.assistedCombatTextHidden then
        SetCooldownTextRegionsVisible(cdFrame, not hideNums)
        fs.assistedCombatTextHidden = nil
    end

    if needsFullRestyle or textRegionsChanged then
        -- Font string styling & positioning
        do
            fs.appliedTextColor = nil
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
    Classifier:WipeCache()
    wipe(frameState)
    wipe(fontState)
    wipe(durationColoredFrames)
    wipe(activeDurationFrames)
    activeDurationFrameCount = 0
    wipe(durationObjectCache)
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

                -- Enforcement hooks: prevent Blizzard from overriding our
                -- cached visual state between style passes.
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

                self.enforcementHooksInstalled = true
            end
        end
    end

end
