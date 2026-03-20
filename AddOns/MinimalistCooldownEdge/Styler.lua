-- Styler.lua

local MCE        = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Styler     = MCE:NewModule("Styler")
local Classifier = MCE:GetModule("Classifier")
local Constants  = MCE.Constants
local GetDurationTextColorsConfig = MCE.Helpers.GetDurationTextColorsConfig

local pairs, ipairs, type, pcall, wipe = pairs, ipairs, type, pcall, wipe
local math_abs = math.abs
local strfind = string.find
local setmetatable = setmetatable
local select = select
local _G = _G
local C_Timer_After = C_Timer.After
local C_Timer_NewTimer = C_Timer.NewTimer
local GetTime = GetTime
local hooksecurefunc = hooksecurefunc
local issecretvalue = issecretvalue or function() return false end
local canaccessallvalues = canaccessallvalues

local SUPPORTED_CATEGORIES = Constants.SUPPORTED_CATEGORIES

local weakMeta = { __mode = "k" }

local frameState = setmetatable({}, weakMeta)
local fontState  = setmetatable({}, weakMeta)
local stackRegionState = setmetatable({}, weakMeta)

local trackedCooldowns      = setmetatable({}, weakMeta)
local durationColoredFrames = setmetatable({}, weakMeta)
local compactPartyAuraFrames = setmetatable({}, weakMeta)
local activeDurationFrames  = setmetatable({}, weakMeta)
local hookedCooldowns       = setmetatable({}, weakMeta)

local durationColorTicker = nil
local durationColorCurve = nil
local activeDurationFrameCount = 0
local durationCacheSweepCounter = 0
local IsSecretValue
local CanAccessAllValues
local RefreshTrackedDurationColor
local ClearTrackedDurationColor
local StartDurationColorTicker
local IsSupportedCategory
local ResetQueuedFrameUpdates
local QueueAuraRecovery
local ApplyCountdownAbbrevThreshold
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

local function GetStackRegionState(region)
    local s = stackRegionState[region]
    if not s then
        s = {
            nativeVisible = region and region.IsShown and region:IsShown() or false,
        }
        stackRegionState[region] = s
    end
    return s
end

local function InvalidateFontRegionState(region)
    if not region then
        return
    end

    GetFontState(region).dirty = true
end

local function EnsureStackRegionVisibilityHooks(region)
    if not region or MCE:IsForbidden(region) then
        return
    end

    local state = GetStackRegionState(region)
    if state.visibilityHooksInstalled then
        return
    end

    if type(region.Show) == "function" then
        hooksecurefunc(region, "Show", function(self)
            local s = stackRegionState[self]
            if s and not s.suppressVisibility then
                s.nativeVisible = true
            end
        end)
    end

    if type(region.Hide) == "function" then
        hooksecurefunc(region, "Hide", function(self)
            local s = stackRegionState[self]
            if s and not s.suppressVisibility then
                s.nativeVisible = false
            end
        end)
    end

    state.visibilityHooksInstalled = true
end

local function SetManagedStackRegionVisible(region, visible)
    if not region then
        return
    end

    local state = GetStackRegionState(region)
    local isVisible = region.IsShown and region:IsShown() or false
    if isVisible == visible then
        return
    end

    state.suppressVisibility = true
    if visible then
        region:Show()
    else
        region:Hide()
    end
    state.suppressVisibility = nil
end

local function InvalidateCooldownTextStyleState(cdFrame)
    local fs = GetFrameState(cdFrame)
    fs.styledCat = nil
    fs.appliedTextColor = nil
    return fs
end

local function NormalizeRefreshSelection(selection)
    if selection == nil or selection == true or selection == "all" then
        return nil
    end

    if type(selection) == "string" then
        return IsSupportedCategory(selection) and { [selection] = true } or {}
    end

    if type(selection) ~= "table" then
        return {}
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

        if IsSupportedCategory(category) then
            normalized[category] = true
            hasEntries = true
        end
    end

    return hasEntries and normalized or {}
end

local function GetManagedCooldownCategory(cdFrame)
    local category = Classifier:GetCategory(cdFrame)
    if not category and compactPartyAuraFrames[cdFrame] and Classifier:GetCompactPartyAuraFrameType(cdFrame) then
        return "partyraidframes"
    end

    return category
end

local function MatchesRefreshSelection(cdFrame, selection, category)
    if selection == nil then
        return true
    end

    if category and selection[category] then
        return true
    end

    if selection.partyraidframes and compactPartyAuraFrames[cdFrame] then
        return Classifier:GetCompactPartyAuraFrameType(cdFrame) ~= nil
    end

    return false
end

local function ForEachManagedCooldown(selection, callback)
    local normalizedSelection = NormalizeRefreshSelection(selection)
    local seen = {}

    for cdFrame in pairs(trackedCooldowns) do
        if cdFrame and not MCE:IsForbidden(cdFrame) and not seen[cdFrame] then
            seen[cdFrame] = true
            local category = normalizedSelection and GetManagedCooldownCategory(cdFrame) or nil
            if MatchesRefreshSelection(cdFrame, normalizedSelection, category) then
                callback(cdFrame, category)
            end
        end
    end

    for cdFrame in pairs(compactPartyAuraFrames) do
        if cdFrame and not MCE:IsForbidden(cdFrame) and not seen[cdFrame] then
            seen[cdFrame] = true
            local category = normalizedSelection and GetManagedCooldownCategory(cdFrame) or nil
            if MatchesRefreshSelection(cdFrame, normalizedSelection, category) then
                callback(cdFrame, category)
            end
        end
    end
end

local function ReleaseManagedCooldown(cdFrame)
    ClearTrackedDurationColor(cdFrame)
    trackedCooldowns[cdFrame] = nil

    local fs = frameState[cdFrame]
    if fs then
        fs.visualManaged = compactPartyAuraFrames[cdFrame] and true or nil
    end
end

local function QueueManagedCooldownRefresh(cdFrame)
    if not cdFrame or IsSecretValue(cdFrame) or MCE:IsForbidden(cdFrame) then
        return
    end

    local fs = frameState[cdFrame]
    if not fs or not fs.visualManaged then
        return
    end

    Styler:QueueUpdate(cdFrame)
end

IsSecretValue = function(value)
    if not issecretvalue then return false end

    local ok, result = pcall(issecretvalue, value)
    return ok and result or false
end

CanAccessAllValues = function(...)
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

local function EnsureManagedCooldownVisualHooks(cooldown)
    if not cooldown or MCE:IsForbidden(cooldown) or IsSecretValue(cooldown) then
        return
    end

    local fs = GetFrameState(cooldown)
    if fs.visualHooksInstalled then
        return
    end

    if type(cooldown.SetDrawEdge) == "function" then
        hooksecurefunc(cooldown, "SetDrawEdge", function(self, enabled)
            if not self or IsSecretValue(self) or MCE:IsForbidden(self) or IsSecretValue(enabled) then return end

            local state = frameState[self]
            if not state or not state.visualManaged or state.suppressEdge then
                return
            end

            if state.edge ~= nil and state.edge ~= enabled then
                state.suppressEdge = true
                pcall(self.SetDrawEdge, self, state.edge)
                state.suppressEdge = nil
            end
        end)
    end

    if type(cooldown.SetEdgeScale) == "function" then
        hooksecurefunc(cooldown, "SetEdgeScale", function(self, scale)
            if not self or IsSecretValue(self) or MCE:IsForbidden(self) or IsSecretValue(scale) then return end

            local state = frameState[self]
            if not state or not state.visualManaged or state.suppressEdgeScale then
                return
            end

            if state.edgeScale ~= nil and not IsNearlyEqual(state.edgeScale, scale) then
                state.suppressEdgeScale = true
                pcall(self.SetEdgeScale, self, state.edgeScale)
                state.suppressEdgeScale = nil
            end
        end)
    end

    if type(cooldown.SetSwipeColor) == "function" then
        hooksecurefunc(cooldown, "SetSwipeColor", function(self, r, g, b, a)
            if not self or IsSecretValue(self) or MCE:IsForbidden(self) then return end
            if IsSecretValue(r) or IsSecretValue(g) or IsSecretValue(b) or IsSecretValue(a) then return end

            local state = frameState[self]
            if not state or not state.visualManaged or state.suppressSwipe then
                return
            end

            if state.swipeColor and not IsSameSwipeColor(state.swipeColor, r, g, b, a) then
                state.suppressSwipe = true
                pcall(self.SetSwipeColor, self, state.swipeColor.r, state.swipeColor.g, state.swipeColor.b, state.swipeColor.a)
                state.suppressSwipe = nil
            end
        end)
    end

    if type(cooldown.SetHideCountdownNumbers) == "function" then
        hooksecurefunc(cooldown, "SetHideCountdownNumbers", function(self, hide)
            if not self or IsSecretValue(self) or MCE:IsForbidden(self) or IsSecretValue(hide) then return end

            local state = frameState[self]
            if not state or not state.visualManaged or state.suppressHideNums then
                return
            end

            if state.hideNums ~= nil and state.hideNums ~= hide then
                state.suppressHideNums = true
                pcall(self.SetHideCountdownNumbers, self, state.hideNums)
                state.suppressHideNums = nil
            end
        end)
    end

    if type(cooldown.SetDrawSwipe) == "function" then
        hooksecurefunc(cooldown, "SetDrawSwipe", function(self, enabled)
            if not self or IsSecretValue(self) or MCE:IsForbidden(self) or IsSecretValue(enabled) then return end

            local state = frameState[self]
            if not state or not state.visualManaged or state.suppressSwipeDraw then
                return
            end

            if state.drawSwipe ~= nil and state.drawSwipe ~= enabled then
                state.suppressSwipeDraw = true
                pcall(self.SetDrawSwipe, self, state.drawSwipe)
                state.suppressSwipeDraw = nil
            end
        end)
    end

    fs.visualHooksInstalled = true
end

local function GetCompactPartyAuraConfig()
    local categories = MCE.db and MCE.db.profile and MCE.db.profile.categories
    return categories and categories.partyraidframes or nil
end

local function ShouldEnableRaidOverFiveAuraText(config)
    if not config or not config.enableForRaidOverFive then
        return false
    end

    return IsInRaid and IsInRaid() and GetNumGroupMembers and GetNumGroupMembers() > 5 or false
end

local function ShouldUseCompactPartyAuraText(config, frameType)
    if not config then return false end
    if frameType == "raid" then
        return ShouldEnableRaidOverFiveAuraText(config)
    end
    if frameType == "party" then
        return true
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

        InvalidateFontRegionState(self)

        local ownerCooldown = s.ownerCooldown
        if ownerCooldown then
            InvalidateCooldownTextStyleState(ownerCooldown)
            QueueManagedCooldownRefresh(ownerCooldown)
        end
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
    local forceStyle = state.dirty
    state.enforceFont = enforceFont or false
    if state.enforceFont
       and relativeFrame
       and relativeFrame.IsObjectType
       and relativeFrame:IsObjectType("Cooldown") then
        state.ownerCooldown = relativeFrame
    else
        state.ownerCooldown = nil
    end

    if forceStyle
       or state.fontPath ~= fontPath
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
        if forceStyle
           or state.colorR ~= color.r
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
        if forceStyle
           or state.point ~= point
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
        if forceStyle
           or state.drawLayer ~= drawLayer
           or state.drawLayerSubLevel ~= drawLayerSubLevel
        then
            region:SetDrawLayer(drawLayer, drawLayerSubLevel)
            state.drawLayer = drawLayer
            state.drawLayerSubLevel = drawLayerSubLevel
        end
    end

    state.dirty = nil
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

local function ClearCompactPartyAuraCooldown(cdFrame)
    if not compactPartyAuraFrames[cdFrame] then
        return
    end

    compactPartyAuraFrames[cdFrame] = nil
    ClearTrackedDurationColor(cdFrame)
    SetCompactPartyAuraNativeTextVisible(cdFrame, true)
    SetCompactPartyAuraNativeHide(cdFrame, false)

    local fs = frameState[cdFrame]
    if fs and not trackedCooldowns[cdFrame] then
        fs.visualManaged = nil
    end
end

local function SyncCompactPartyAuraCooldown(cdFrame)
    local frameType = Classifier:GetCompactPartyAuraFrameType(cdFrame)
    if not frameType then
        ClearCompactPartyAuraCooldown(cdFrame)
        return false
    end
    local config = GetCompactPartyAuraConfig()
    if not config or not config.enabled then
        ClearCompactPartyAuraCooldown(cdFrame)
        return false
    end

    compactPartyAuraFrames[cdFrame] = true
    GetFrameState(cdFrame).visualManaged = true
    EnsureManagedCooldownVisualHooks(cdFrame)

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

    ApplyCountdownAbbrevThreshold(cdFrame, GetFrameState(cdFrame))

    if RefreshTrackedDurationColor then
        RefreshTrackedDurationColor(cdFrame, "compactPartyAura", config)
    end

    return true
end

IsSupportedCategory = function(category)
    return category and SUPPORTED_CATEGORIES[category] or false
end

local function HandleBootstrappedCooldown(cooldown, forcedCategory)
    Classifier:RegisterDiscoveredCooldown(cooldown, forcedCategory)
    SyncCompactPartyAuraCooldown(cooldown)
    Styler:QueueUpdate(cooldown, forcedCategory)
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
        local frameType = Classifier:GetCompactPartyAuraFrameType(cdFrame)
        return config.enabled == true and frameType and ShouldUseCompactPartyAuraText(config, frameType) or false
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

local function GetFallbackDurationObject(cdFrame, forceContextRefresh, skipAuraFallback)
    local parent = cdFrame and cdFrame.GetParent and cdFrame:GetParent()
    if not parent then return nil end

    local contextState = Classifier:ResolveCooldownContext(cdFrame, forceContextRefresh == true)
    local actionButton = contextState and contextState.actionButton ~= false and contextState.actionButton or parent
    local actionID = contextState and contextState.actionID ~= false and contextState.actionID or Classifier:GetActionIDFromButton(actionButton)
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

    if not skipAuraFallback and Classifier:ShouldUseAuraDurationFallback(cdFrame) then
        local auraInstanceID, unitToken = Classifier:GetAuraDurationContext(cdFrame)

        if auraInstanceID and unitToken and C_UnitAuras and C_UnitAuras.GetAuraDuration then
            local ok, durationObject = pcall(C_UnitAuras.GetAuraDuration, unitToken, auraInstanceID)
            if ok and durationObject then
                return durationObject
            end
        end
    end

    local spellOwner = Classifier:GetSpellCooldownOwner(cdFrame) or actionButton or parent
    local spellID = Classifier:GetCooldownSpellID(spellOwner)

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

local function ClearStoredCooldownDurationObject(cdFrame)
    local fs = frameState[cdFrame]
    if fs then
        fs.durationObject = nil
    end
end

local function GetLiveActionBarDurationObject(cdFrame)
    return GetFallbackDurationObject(cdFrame, true, true)
end

local function SetStoredCooldownDurationObject(cdFrame, durationObject)
    if not cdFrame or IsSecretValue(cdFrame) then return end

    if durationObject and (IsSecretValue(durationObject) or not CanAccessAllValues(durationObject)) then
        durationObject = nil
    end

    if durationObject and not IsSupportedDurationObject(durationObject) then
        durationObject = nil
    end

    if durationObject then
        GetFrameState(cdFrame).durationObject = durationObject
    else
        ClearStoredCooldownDurationObject(cdFrame)
    end
end

local function GetStoredCooldownDurationObject(cdFrame, allowFallbackLookup)
    local fs = frameState[cdFrame]
    if fs and fs.durationObject then
        return fs.durationObject
    end

    if allowFallbackLookup == false then
        return nil
    end

    local durationObject = GetFallbackDurationObject(cdFrame)
    if durationObject then
        SetStoredCooldownDurationObject(cdFrame, durationObject)
    end
    return durationObject
end

local function GetCooldownDurationObject(cdFrame, sourceKey)
    if sourceKey == "actionbar" then
        -- Action slots can be rebound/reused while the global discovery pass is
        -- still classifying other cooldowns. Read the current slot duration
        -- fresh so we do not keep evaluating a stale/shared DurationObject.
        local currentDurationObject = GetLiveActionBarDurationObject(cdFrame)
        if currentDurationObject then
            return currentDurationObject
        end

        return GetStoredCooldownDurationObject(cdFrame, false)
    end

    return GetStoredCooldownDurationObject(cdFrame, true)
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

local function ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve)
    if not cdFrame or MCE:IsForbidden(cdFrame) then return false end
    if cdFrame.IsShown and not cdFrame:IsShown() then return false end

    local textRegions, textRegionCount = GetCachedCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    local duration = GetCooldownDurationObject(cdFrame, sourceKey)
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
        ClearStoredCooldownDurationObject(cdFrame)
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
               and ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve) then
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
    if curve and ApplyCooldownDurationColor(cdFrame, sourceKey, config, curve) then
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

    SetStoredCooldownDurationObject(cooldown, durationObject)

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
            ApplyCooldownDurationColor(cooldown, sourceKey, config, curve)
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

    local category = Classifier:GetCategory(cooldown)
    if not category then
        ReleaseManagedCooldown(cooldown)
        return
    end

    if Classifier:IsAuraDrivenCooldown(cooldown, category) then
        QueueAuraRecovery(cooldown, 0)
        return
    end

    Styler:QueueUpdate(cooldown, category ~= "aura_pending" and category or nil)
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

local queuedFrameUpdates = {}
local queuedFrameCount = 0
local queuedFrameTimer = nil
local queuedFrameDueAt = nil

local ProcessQueuedFrameUpdate

local function CancelQueuedFrameTimer()
    if queuedFrameTimer then
        queuedFrameTimer:Cancel()
        queuedFrameTimer = nil
    end

    queuedFrameDueAt = nil
end

local function RemoveQueuedFrame(frame)
    if queuedFrameUpdates[frame] ~= nil then
        queuedFrameUpdates[frame] = nil
        if queuedFrameCount > 0 then
            queuedFrameCount = queuedFrameCount - 1
        end
    end
end

local function ScheduleQueuedFrameProcessor(delay)
    local clampedDelay = delay or 0
    if clampedDelay < 0 then
        clampedDelay = 0
    end

    local dueAt = GetTime() + clampedDelay
    if queuedFrameTimer and queuedFrameDueAt and dueAt >= queuedFrameDueAt then
        return
    end

    CancelQueuedFrameTimer()
    queuedFrameDueAt = dueAt
    queuedFrameTimer = C_Timer_NewTimer(clampedDelay, function()
        queuedFrameTimer = nil
        queuedFrameDueAt = nil

        if queuedFrameCount == 0 then
            return
        end

        local now = GetTime()
        local nextDelay = nil

        for frame, request in pairs(queuedFrameUpdates) do
            local requestDueAt = request and request.dueAt or 0

            if not frame or MCE:IsForbidden(frame) then
                RemoveQueuedFrame(frame)
            elseif requestDueAt <= now + 0.0001 then
                RemoveQueuedFrame(frame)
                ProcessQueuedFrameUpdate(frame, request)
            else
                local remainingDelay = requestDueAt - now
                if not nextDelay or remainingDelay < nextDelay then
                    nextDelay = remainingDelay
                end
            end
        end

        if nextDelay then
            ScheduleQueuedFrameProcessor(nextDelay)
        end
    end)
end

local function QueueFrameUpdateRequest(frame, request)
    if not frame or MCE:IsForbidden(frame) then
        return
    end

    if Classifier:IsBlacklisted(frame) then
        RemoveQueuedFrame(frame)
        ReleaseManagedCooldown(frame)
        return
    end

    local entry = queuedFrameUpdates[frame]
    if not entry then
        entry = {}
        queuedFrameUpdates[frame] = entry
        queuedFrameCount = queuedFrameCount + 1
    end

    local forcedCategory = request and request.forcedCategory or nil
    if forcedCategory and IsSupportedCategory(forcedCategory) then
        entry.forcedCategory = forcedCategory
    elseif request and request.reclassify then
        entry.forcedCategory = nil
    end

    if request and request.clearContext then
        entry.clearContext = true
    end

    if request and request.resetDurationObject then
        entry.resetDurationObject = true
    end

    if request and request.reclassify then
        entry.reclassify = true
    end

    if request and request.retryOnAuraPending then
        entry.retryOnAuraPending = true
    end

    local dueAt = GetTime() + math.max(request and request.delay or 0, 0)
    entry.dueAt = entry.dueAt and math.min(entry.dueAt, dueAt) or dueAt

    local nextDelay = entry.dueAt - GetTime()
    if nextDelay < 0 then
        nextDelay = 0
    end
    ScheduleQueuedFrameProcessor(nextDelay)
end

QueueAuraRecovery = function(frame, delay)
    QueueFrameUpdateRequest(frame, {
        clearContext = true,
        resetDurationObject = true,
        reclassify = true,
        retryOnAuraPending = true,
        delay = delay or 0,
    })
end

local function ResolveQueuedFrameCategory(frame, request)
    local forcedCategory = request and request.forcedCategory or nil

    if forcedCategory and forcedCategory ~= "minicc" and Classifier:GetMiniCCFrameType(frame) then
        forcedCategory = "minicc"
    end

    if request and request.reclassify then
        Classifier:ClearFrameClassification(frame)
    end

    if forcedCategory and IsSupportedCategory(forcedCategory) then
        Classifier:SetCategory(frame, forcedCategory)
        return forcedCategory
    end

    return Classifier:GetCategory(frame)
end

ProcessQueuedFrameUpdate = function(frame, request)
    if not frame or MCE:IsForbidden(frame) then
        return
    end

    if request and request.clearContext then
        Classifier:ClearContext(frame)
    end

    if request and request.resetDurationObject then
        ClearStoredCooldownDurationObject(frame)
    end

    if SyncCompactPartyAuraCooldown(frame) then
        return
    end

    local category = ResolveQueuedFrameCategory(frame, request)
    if category == "aura_pending" then
        if request and request.retryOnAuraPending then
            QueueAuraRecovery(frame, 0.1)
        end
        return
    end

    if not category then
        ReleaseManagedCooldown(frame)
        return
    end

    Styler:ApplyStyle(frame, category)
end

function Styler:QueueUpdate(frame, forcedCategory)
    if forcedCategory and not IsSupportedCategory(forcedCategory) then
        forcedCategory = nil
    end

    QueueFrameUpdateRequest(frame, {
        forcedCategory = forcedCategory,
        retryOnAuraPending = true,
    })
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
    wipe(trackedCooldowns)
    wipe(durationObjectCache)
    ResetQueuedFrameUpdates()
    wipe(frameState)
    wipe(fontState)
    wipe(stackRegionState)
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
    if category == "actionbar" and Classifier:IsAssistedCombatActionCooldown(cdFrame) then
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
-- STACK COUNT STYLING  (action bars, nameplates, and CooldownManager viewers)
-- =========================================================================

local function GetStackCountRegion(cdFrame, category)
    local parent = cdFrame:GetParent()
    if not parent then return nil, nil end

    local countRegion

    if category == "actionbar" then
        -- Action bar: standard Count region on the button
        local parentName = parent.GetName and parent:GetName()
        countRegion = parent.Count or (parentName and _G[parentName .. "Count"])
    elseif category == "nameplate" then
        countRegion = parent.Count
            or parent.CountText
            or parent.StackCount
            or (parent.CountFrame and parent.CountFrame.Count)
            or (parent.Applications and parent.Applications.Applications)
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

    local isNameplateStack = (category == "nameplate")
    if isNameplateStack then
        EnsureStackRegionVisibilityHooks(countRegion)
    end

    if config.hideStackText then
        countRegion:SetAlpha(0)
        if isNameplateStack then
            SetManagedStackRegionVisible(countRegion, false)
        else
            countRegion:Hide()
        end
        return
    end

    countRegion:SetAlpha(1)
    if isNameplateStack then
        local stackState = GetStackRegionState(countRegion)
        SetManagedStackRegionVisible(countRegion, stackState.nativeVisible == true)
        if not stackState.nativeVisible then
            return
        end
    else
        countRegion:Show()
    end

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

ApplyCountdownAbbrevThreshold = function(cdFrame, fs)
    local profile = MCE.db and MCE.db.profile
    if not profile or not cdFrame.SetCountdownAbbrevThreshold then
        return nil
    end

    local threshold = profile.abbrevThreshold or 59
    if fs.countdownAbbrevThreshold ~= threshold then
        pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame, threshold)
        fs.countdownAbbrevThreshold = threshold
    end

    return threshold
end

-- =========================================================================
-- STYLE APPLICATION
-- =========================================================================
local function ResolveStyleCategory(cdFrame, forcedCategory)
    local category = forcedCategory

    if category and category ~= "minicc" and Classifier:GetMiniCCFrameType(cdFrame) then
        category = "minicc"
    end

    if category and IsSupportedCategory(category) then
        if Classifier:GetCategory(cdFrame) ~= category then
            Classifier:SetCategory(cdFrame, category)
            local fs = frameState[cdFrame]
            if fs then
                fs.styledCat = nil
            end
        end

        return category
    end

    return Classifier:GetCategory(cdFrame)
end

local function ResetDisabledCategoryStyle(cdFrame, fs, category, config)
    local hadTrackedDurationColor = durationColoredFrames[cdFrame] ~= nil
    ClearTrackedDurationColor(cdFrame)
    if hadTrackedDurationColor and config then
        ResetCountdownTextColor(cdFrame, config)
    end

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
end

local function ApplySwipeAndEdgeStyle(cdFrame, fs, category, config, isChargeCooldown, hasActiveCharge)
    local wantSwipe = config.drawSwipe ~= false and (not isChargeCooldown or hasActiveCharge)

    if cdFrame.SetDrawSwipe and fs.drawSwipe ~= wantSwipe then
        fs.suppressSwipeDraw = true
        pcall(cdFrame.SetDrawSwipe, cdFrame, wantSwipe)
        fs.suppressSwipeDraw = nil
        fs.drawSwipe = wantSwipe
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

    if not cdFrame.SetSwipeColor then
        return
    end

    if category == "actionbar" then
        local r, g, b, a = 0, 0, 0, GetSwipeShadeAlpha(config)
        if not IsSameSwipeColor(fs.swipeColor, r, g, b, a) then
            fs.suppressSwipe = true
            pcall(cdFrame.SetSwipeColor, cdFrame, r, g, b, a)
            fs.suppressSwipe = nil
            fs.swipeColor = { r = r, g = g, b = b, a = a }
        end
        return
    end

    ResetSwipeColor(cdFrame)
end

local function ApplyHideCountdownState(cdFrame, fs, category, config, isAssistedCombat)
    if not cdFrame.SetHideCountdownNumbers then
        return nil
    end

    local hideNums = isAssistedCombat or GetDesiredHideCountdownNumbers(cdFrame, category, config)
    if fs.hideNums ~= hideNums then
        fs.suppressHideNums = true
        pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
        fs.suppressHideNums = nil
        fs.hideNums = hideNums
    end

    return hideNums
end

local function GetCooldownStyleKey(cdFrame, category)
    if category == "cooldownmanager" then
        local viewerType = Classifier:GetCooldownManagerViewerType(cdFrame) or "default"
        return category .. ":" .. viewerType
    end

    if category == "minicc" then
        local miniCCType = Classifier:GetMiniCCFrameType(cdFrame) or "default"
        return category .. ":" .. miniCCType
    end

    return category
end

local function ApplyCooldownTypography(cdFrame, fs, category, config)
    local styleKey = GetCooldownStyleKey(cdFrame, category)
    local needsFullRestyle = fs.styledCat ~= styleKey
    local textRegions, textRegionCount, textRegionsChanged

    if needsFullRestyle or category == "minicc" then
        textRegions, textRegionCount = GetCooldownTextRegions(cdFrame)
        textRegionsChanged = HaveCooldownTextRegionsChanged(cdFrame, textRegions, textRegionCount)
    end

    if needsFullRestyle then
        fs.styledCat = styleKey
    end

    if not (needsFullRestyle or textRegionsChanged) then
        return
    end

    fs.appliedTextColor = nil

    local fontStyle = MCE.NormalizeFontStyle(config.fontStyle)
    local resolvedFont = MCE.ResolveFontPath(config.font)
    local fontSize = GetCooldownFontSize(cdFrame, category, config)
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

local function ApplyManagedTextState(cdFrame, fs, category, config, hideNums, isAssistedCombat)
    Styler:StyleStackCount(cdFrame, config, category)

    if isAssistedCombat then
        if not fs.assistedCombatTextHidden then
            SetCooldownTextRegionsVisible(cdFrame, false)
            fs.assistedCombatTextHidden = true
        end

        ClearTrackedDurationColor(cdFrame)
        return
    end

    if fs.assistedCombatTextHidden then
        SetCooldownTextRegionsVisible(cdFrame, not hideNums)
        fs.assistedCombatTextHidden = nil
    end

    ApplyCooldownTypography(cdFrame, fs, category, config)
    ApplyCountdownAbbrevThreshold(cdFrame, fs)
    RefreshTrackedDurationColor(cdFrame, category, config)
end

function Styler:ApplyStyle(cdFrame, forcedCategory)
    if MCE:IsForbidden(cdFrame) then return end
    if Classifier:IsBlacklisted(cdFrame) then return end

    -- Guard: DB must be ready
    if not (MCE.db and MCE.db.profile and MCE.db.profile.categories) then return end

    local category = ResolveStyleCategory(cdFrame, forcedCategory)
    local isAssistedCombat = (category == "actionbar" and Classifier:IsAssistedCombatActionCooldown(cdFrame))

    if not category or category == "blacklist" or not IsSupportedCategory(category) then
        ReleaseManagedCooldown(cdFrame)
        return
    end

    trackedCooldowns[cdFrame] = true
    Classifier:RegisterDiscoveredCooldown(cdFrame, category)

    local fs = GetFrameState(cdFrame)
    fs.visualManaged = true
    EnsureManagedCooldownVisualHooks(cdFrame)

    local config = MCE.db.profile.categories[category]
    if not config or not config.enabled then
        ResetDisabledCategoryStyle(cdFrame, fs, category, config)
        return
    end

    local parent = cdFrame.GetParent and cdFrame:GetParent()
    local isChargeCooldown = IsChargeCooldownFrame(cdFrame, parent)
    local hasActiveCharge = isChargeCooldown and IsMainCooldownWithActiveChargeCooldown(cdFrame)
    ApplySwipeAndEdgeStyle(cdFrame, fs, category, config, isChargeCooldown, hasActiveCharge)
    local hideNums = ApplyHideCountdownState(cdFrame, fs, category, config, isAssistedCombat)
    ApplyManagedTextState(cdFrame, fs, category, config, hideNums, isAssistedCombat)

end

-- =========================================================================
-- FORCE UPDATE
-- =========================================================================

local function ResolveRefreshSelection(pathSelection, defaultSelection)
    if not pathSelection then
        return nil
    end

    if pathSelection == true then
        return defaultSelection
    end

    return pathSelection
end

local function NormalizeRuntimeRefreshRequest(request)
    if type(request) ~= "table" then
        local fullScan = request and true or false
        return {
            discovery = fullScan and "all" or nil,
            classification = fullScan and "all" or nil,
            visuals = "all",
            invalidateColorCurve = true,
            resetScheduler = fullScan,
            wipeClassifierCache = fullScan,
        }
    end

    local defaultSelection = request.categories or request.selection or "all"
    local visuals = request.visuals
    if visuals == nil then
        visuals = true
    end

    return {
        discovery = ResolveRefreshSelection(request.discovery, defaultSelection),
        classification = ResolveRefreshSelection(request.classification, defaultSelection),
        visuals = ResolveRefreshSelection(visuals, defaultSelection),
        invalidateColorCurve = request.invalidateColorCurve == true,
        resetScheduler = request.resetScheduler == true,
        wipeClassifierCache = request.wipeClassifierCache == true,
    }
end

ResetQueuedFrameUpdates = function()
    CancelQueuedFrameTimer()
    wipe(queuedFrameUpdates)
    queuedFrameCount = 0
    queuedFrameDueAt = nil
end

function Styler:RefreshDiscovery(selection)
    Classifier:RefreshSupportedCooldownSources(selection or "all", HandleBootstrappedCooldown)
end

function Styler:RefreshClassification(selection)
    ForEachManagedCooldown(selection, function(cdFrame)
        if cdFrame and cdFrame.IsObjectType and cdFrame:IsObjectType("Cooldown") then
            InvalidateCooldownTextStyleState(cdFrame)
            QueueFrameUpdateRequest(cdFrame, {
                clearContext = true,
                reclassify = true,
                retryOnAuraPending = true,
            })
        end
    end)
end

function Styler:RefreshVisuals(selection)
    ForEachManagedCooldown(selection, function(cdFrame)
        if cdFrame and cdFrame.IsObjectType and cdFrame:IsObjectType("Cooldown") then
            InvalidateCooldownTextStyleState(cdFrame)
            if compactPartyAuraFrames[cdFrame] then
                SyncCompactPartyAuraCooldown(cdFrame)
            end
            self:QueueUpdate(cdFrame)
        end
    end)
end

function Styler:RefreshRuntime(request)
    local refresh = NormalizeRuntimeRefreshRequest(request)

    if not self.fullScanDone then
        self.fullScanDone = true
        refresh.discovery = refresh.discovery or "all"
        refresh.classification = refresh.classification or "all"
        refresh.resetScheduler = true
        refresh.wipeClassifierCache = true
    end

    if refresh.invalidateColorCurve then
        InvalidateColorCurve()
    end

    if refresh.resetScheduler then
        ResetQueuedFrameUpdates()
    end

    if refresh.wipeClassifierCache then
        Classifier:WipeCache()
    end

    if refresh.discovery then
        self:RefreshDiscovery(refresh.discovery)
    end

    if refresh.classification then
        self:RefreshClassification(refresh.classification)
    end

    if refresh.visuals then
        self:RefreshVisuals(refresh.visuals)
    end
end

function Styler:ForceUpdateAll(fullScan)
    self:RefreshRuntime(fullScan)
end

-- =========================================================================
-- HOOKS  (AceHook: auto-unhook on Disable)
-- =========================================================================
-- Shared metatable hooks only capture cooldown durations. Visual enforcement
-- stays on tracked frames via EnsureManagedCooldownVisualHooks / font hooks.

function Styler:SetupHooks()
    self:SetupDurationCaptureHooks()
end

function Styler:SetupDurationCaptureHooks()
    if not self.cooldownDurationCaptureHooksInstalled then
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
                self.cooldownDurationCaptureHooksInstalled = true
            end
        end
    end
end
