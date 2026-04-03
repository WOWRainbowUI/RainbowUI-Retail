-- StyleEngine.lua – Core visual style application for cooldown frames
--
-- Owns frameState / fontState helpers, text region discovery, font styling,
-- swipe/edge application, stack count styling, charge cooldown detection,
-- cooldown context resolution, and the main ApplyStyle entry point.
-- Duration colors and compact-group aura overrides are handled by their
-- respective controller modules.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local StyleEngine = MCE:NewModule("StyleEngine")

local pairs, type, pcall, wipe = pairs, type, pcall, wipe
local math_abs = math.abs
local strfind = string.find
local select = select
local hooksecurefunc = hooksecurefunc
local issecretvalue = issecretvalue or function() return false end
local canaccessallvalues = canaccessallvalues

local CATEGORY = C.Categories
local VIEWER_TYPE = C.CooldownManagerViewers
local MINICC_FRAME_TYPE = C.MiniCCFrameTypes
local SARENA_FRAME_TYPE = C.SArenaFrameTypes
local STYLE_CONSTANTS = C.Style
local STYLER_CONSTANTS = C.Styler
local LARGE_AURA_WIDTH_THRESHOLD = 20

-- Shared state from addon namespace
local frameState = addon.frameState
local fontState = addon.fontState

-- Lazy module references (resolved on first use in OnEnable)
local Registry, DurationColor, CompactAura, Classifier

function StyleEngine:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    DurationColor = MCE:GetModule("DurationColorController")
    CompactAura = MCE:GetModule("CompactGroupAuraController")
    Classifier = MCE:GetModule("Classifier")
end

-- =========================================================================
-- SAFE VALUE HELPERS
-- =========================================================================

function StyleEngine.IsSecretValue(value)
    if not issecretvalue then return false end
    local ok, result = pcall(issecretvalue, value)
    return ok and result or false
end

function StyleEngine.CanAccessAllValues(...)
    if not canaccessallvalues then return true end
    local ok, result = pcall(canaccessallvalues, ...)
    return ok and result or false
end

local IsSecretValue = StyleEngine.IsSecretValue
local CanAccessAllValues = StyleEngine.CanAccessAllValues

local function IsInspectableUIObject(value)
    local valueType = type(value)
    if valueType ~= "table" and valueType ~= "userdata" then
        return false
    end
    if IsSecretValue(value) and not CanAccessAllValues(value) then
        return false
    end
    return true
end

local function GetObjectTypeSafe(region)
    if not IsInspectableUIObject(region) or type(region.GetObjectType) ~= "function" then
        return nil
    end
    local ok, objectType = pcall(region.GetObjectType, region)
    if not ok then
        return nil
    end
    return objectType
end

local function IsUsableFontString(region)
    return GetObjectTypeSafe(region) == "FontString"
        and not MCE:IsForbidden(region)
end

-- =========================================================================
-- FRAME STATE
-- =========================================================================

function StyleEngine:GetFrameState(frame)
    local s = frameState[frame]
    if not s then
        s = {}
        frameState[frame] = s
    end
    return s
end

function StyleEngine:GetFontState(region)
    local s = fontState[region]
    if not s then
        s = {}
        fontState[region] = s
    end
    return s
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
-- UNIT / AURA HELPERS
-- =========================================================================

local function ExtractUnitToken(unit)
    if type(unit) == "string" then
        return unit ~= "" and unit or nil
    end
    if type(unit) ~= "table" then return nil end
    local token = unit.unitid or unit.unitID or unit.unitToken
        or unit.displayedUnit or unit.memberUnit or unit.unit
    if type(token) == "string" and token ~= "" then return token end
    return nil
end

function StyleEngine:GetFrameUnitToken(frame)
    if not frame then return nil end
    return ExtractUnitToken(frame.unitToken)
        or ExtractUnitToken(frame.unit)
        or ExtractUnitToken(frame.displayedUnit)
        or ExtractUnitToken(frame.memberUnit)
        or ExtractUnitToken(frame.auraDataUnit)
end

function StyleEngine:GetFrameAuraInstanceID(frame)
    if not frame then return nil end
    return frame.auraInstanceID
        or frame.auraDataInstanceID
        or frame.auraInstanceId
        or frame.auraDataInstanceId
end

function StyleEngine:GetCooldownSpellID(owner)
    if not owner then return nil end
    if type(owner.GetSpellID) == "function" then
        local ok, spellID = pcall(owner.GetSpellID, owner)
        if ok and spellID then return spellID end
    end
    return owner.spellID
end

-- =========================================================================
-- ACTION BAR HELPERS
-- =========================================================================

function StyleEngine:GetActionIDFromButton(parent)
    if not parent then return nil end
    local actionID = parent.action
    if type(actionID) == "number" then return actionID end
    if parent.GetAttribute then
        local ok, attr = pcall(parent.GetAttribute, parent, "action")
        if ok and type(attr) == "number" then return attr end
    end
    return nil
end

function StyleEngine:IsChargeCooldownFrame(cooldown, parent)
    if not cooldown or not parent then return false end
    return parent.chargeCooldown == cooldown or parent.ChargeCooldown == cooldown
end

function StyleEngine:IsMainCooldownWithActiveChargeCooldown(cdFrame)
    local parent = cdFrame:GetParent()
    if not parent then return false end
    local mainCD = parent.cooldown or parent.Cooldown
    if mainCD ~= cdFrame then return false end
    local chargeCD = parent.chargeCooldown or parent.ChargeCooldown
    if chargeCD and chargeCD ~= cdFrame and not MCE:IsForbidden(chargeCD)
       and chargeCD.IsShown and chargeCD:IsShown() then
        return true
    end
    return false
end

function StyleEngine:IsAssistedCombatActionCooldown(cdFrame)
    if not cdFrame or not C_ActionBar or type(C_ActionBar.IsAssistedCombatAction) ~= "function" then
        return false
    end

    local fs = self:GetFrameState(cdFrame)
    local parent = cdFrame.GetParent and cdFrame:GetParent() or nil
    if not parent or MCE:IsForbidden(parent) then return false end

    local actionID = self:GetActionIDFromButton(parent)
    if not actionID then
        local context = self:ResolveCooldownContext(cdFrame)
        actionID = context and context.actionID ~= false and context.actionID or nil
    end

    if type(actionID) ~= "number" then
        fs.assistedCombatActionID = nil
        fs.assistedCombatAction = nil
        return false
    end

    if fs.assistedCombatActionID == actionID and fs.assistedCombatAction ~= nil then
        return fs.assistedCombatAction == true
    end

    local ok, isAssisted = pcall(C_ActionBar.IsAssistedCombatAction, actionID)
    fs.assistedCombatActionID = actionID
    fs.assistedCombatAction = ok and isAssisted == true or false
    return fs.assistedCombatAction
end

-- =========================================================================
-- COOLDOWN CONTEXT RESOLUTION
-- =========================================================================

local MAX_OWNER_SCAN_DEPTH = STYLER_CONSTANTS.MaxCooldownOwnerScanDepth

function StyleEngine:ResolveCooldownContext(cdFrame, forceRefresh)
    local fs = self:GetFrameState(cdFrame)
    if fs.contextResolved and not forceRefresh then return fs end

    local current = cdFrame and cdFrame.GetParent and cdFrame:GetParent() or nil
    local actionButton, actionID
    local spellOwner, auraInstanceOwner, auraUnitOwner
    local compactPartyCenterDefensiveBuff = false
    local hasAuraNamedAncestor = false

    for _ = 1, MAX_OWNER_SCAN_DEPTH do
        if not current then break end

        if not actionButton then
            local resolvedActionID = self:GetActionIDFromButton(current)
            if resolvedActionID then
                actionButton = current
                actionID = resolvedActionID
            end
        end

        if not spellOwner and self:GetCooldownSpellID(current) ~= nil then
            spellOwner = current
        end

        if not auraInstanceOwner and self:GetFrameAuraInstanceID(current) ~= nil then
            auraInstanceOwner = current
        end

        if not auraUnitOwner and self:GetFrameUnitToken(current) ~= nil then
            auraUnitOwner = current
        end

        if not compactPartyCenterDefensiveBuff then
            local parent = current.GetParent and current:GetParent()
            if parent and parent.CenterDefensiveBuff == current then
                compactPartyCenterDefensiveBuff = true
                hasAuraNamedAncestor = true
            end
        end

        local name = current.GetName and current:GetName() or ""
        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true) then
            hasAuraNamedAncestor = true
        end

        current = current.GetParent and current:GetParent() or nil
    end

    fs.contextResolved = true
    fs.actionButton = actionButton or false
    fs.actionID = actionID or false
    fs.spellOwner = spellOwner or false
    fs.auraInstanceOwner = auraInstanceOwner or false
    fs.auraUnitOwner = auraUnitOwner or false
    fs.compactPartyCenterDefensiveBuff = compactPartyCenterDefensiveBuff or false
    fs.hasAuraNamedAncestor = hasAuraNamedAncestor or false
    return fs
end

-- =========================================================================
-- SWIPE / EDGE
-- =========================================================================

function StyleEngine:GetSwipeShadeAlpha(config)
    local alphaPercent = config and config.swipeAlpha
    if type(alphaPercent) ~= "number" then
        alphaPercent = STYLER_CONSTANTS.DefaultSwipeAlpha
    end
    if alphaPercent < STYLER_CONSTANTS.AlphaPercentMin then
        alphaPercent = STYLER_CONSTANTS.AlphaPercentMin
    elseif alphaPercent > STYLER_CONSTANTS.AlphaPercentMax then
        alphaPercent = STYLER_CONSTANTS.AlphaPercentMax
    end
    return alphaPercent / STYLER_CONSTANTS.AlphaPercentMax
end

function StyleEngine:ResetSwipeColor(cdFrame)
    if not cdFrame or type(cdFrame.SetSwipeColor) ~= "function" then return end
    local fs = frameState[cdFrame]
    if not fs or not fs.swipeColor then return end
    fs.suppressSwipe = true
    pcall(cdFrame.SetSwipeColor, cdFrame, 0, 0, 0)
    fs.suppressSwipe = nil
    fs.swipeColor = nil
end

function StyleEngine:ReleaseManagedVisualState(cdFrame, category)
    local fs = self:GetFrameState(cdFrame)
    fs.edgeScale = nil
    fs.edgeColor = nil
    fs.hideNums = nil
    fs.drawSwipe = nil
    fs.edge = nil
    fs.swipeColor = nil
    fs.appliedTextColor = nil
    fs.assistedCombatTextHidden = nil

    if category == CATEGORY.MiniCC or category == CATEGORY.SArena then
        local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
        for i = 1, textRegionCount do
            fontState[textRegions[i]] = nil
        end
        fs.textRegions = nil
    end

    return fs
end

local DEFAULT_EDGE_COLOR = C.Colors.White

function StyleEngine:GetDesiredEdgeColor(cdFrame)
    local fs = frameState[cdFrame]
    if fs and fs.elvuiSupported then
        return DEFAULT_EDGE_COLOR
    end

    return nil
end

-- =========================================================================
-- TEXT REGION MANAGEMENT
-- =========================================================================

local textRegionScratch = {}

local function FilterFontStringRegions(count, firstRegion, ...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region ~= firstRegion
           and IsUsableFontString(region) then
            count = count + 1
            textRegionScratch[count] = region
        end
    end
    return count
end

function StyleEngine:GetCooldownTextRegions(cdFrame)
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

    for i = count + 1, #textRegionScratch do
        textRegionScratch[i] = nil
    end

    return textRegionScratch, count
end

local function HaveCooldownTextRegionsChanged(fs, textRegions, textRegionCount)
    local trState = fs.textRegions
    if not trState then
        trState = {}
        fs.textRegions = trState
    end

    local changed = (trState.count ~= textRegionCount)
    for i = 1, textRegionCount do
        if trState[i] ~= textRegions[i] then changed = true end
        trState[i] = textRegions[i]
    end
    for i = textRegionCount + 1, trState.count or 0 do
        trState[i] = nil
    end
    trState.count = textRegionCount
    return changed
end

local function GetTrackedTextRegionCount(fs)
    local trackedRegions = fs and fs.textRegions
    return trackedRegions and trackedRegions.count or 0
end

function StyleEngine:GetCachedCooldownTextRegions(cdFrame)
    local fs = frameState[cdFrame]
    local trackedRegions = fs and fs.textRegions
    if trackedRegions and (trackedRegions.count or 0) > 0 then
        return trackedRegions, trackedRegions.count
    end

    local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
    if not fs then fs = self:GetFrameState(cdFrame) end
    HaveCooldownTextRegionsChanged(fs, textRegions, textRegionCount)

    trackedRegions = fs.textRegions
    if trackedRegions then
        return trackedRegions, trackedRegions.count or 0
    end
    return textRegions, textRegionCount
end

function StyleEngine:SetCooldownTextRegionsVisible(cdFrame, visible)
    local textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
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

-- =========================================================================
-- TEXT COLOR APPLICATION
-- =========================================================================

function StyleEngine:ApplyRGBAColorToCooldownRegions(cdFrame, r, g, b, a)
    local textRegions, textRegionCount = self:GetCachedCooldownTextRegions(cdFrame)
    if textRegionCount == 0 then return false end

    local fs = self:GetFrameState(cdFrame)
    if IsSameSwipeColor(fs.appliedTextColor, r, g, b, a) then return true end

    for i = 1, textRegionCount do
        local region = textRegions[i]
        if region and not MCE:IsForbidden(region) then
            region:SetTextColor(r, g, b, a)
        end
    end

    local applied = fs.appliedTextColor or {}
    applied.r, applied.g, applied.b, applied.a = r, g, b, a
    fs.appliedTextColor = applied
    return true
end

function StyleEngine:ApplyTextColorToCooldownRegions(cdFrame, color)
    if not color then return false end
    return self:ApplyRGBAColorToCooldownRegions(cdFrame, color.r, color.g, color.b, color.a)
end

function StyleEngine:ResetCountdownTextColor(cdFrame, config)
    local tc = config and config.textColor
    if not tc then return false end
    return self:ApplyTextColorToCooldownRegions(cdFrame, tc)
end

-- =========================================================================
-- FONT STRING STYLING
-- =========================================================================

local function EnsureFontStringSetFontHook(region)
    local fs = fontState[region]
    if not fs then
        fs = {}
        fontState[region] = fs
    end
    if fs.hooked or not region.SetFont then return end

    hooksecurefunc(region, "SetFont", function(self, fontPath, fontSize, fontStyle)
        if issecretvalue(self) or issecretvalue(fontPath) then return end
        local s = fontState[self]
        if not s or s.suppressSetFont or not s.enforceFont then return end
        if (not issecretvalue(fontPath) and fontPath == s.fontPath)
           and IsNearlyEqual(fontSize, s.fontSize)
           and (not issecretvalue(fontStyle) and fontStyle == s.fontStyle) then
            return
        end
        s.suppressSetFont = true
        pcall(self.SetFont, self, s.fontPath, s.fontSize, s.fontStyle)
        s.suppressSetFont = nil
    end)

    fs.hooked = true
end

function StyleEngine:ApplyFontStringStyle(region, relativeFrame, fontPath, fontSize, fontStyle,
                                          color, point, relativePoint, offsetX, offsetY,
                                          drawLayer, drawLayerSubLevel, enforceFont)
    if not region or MCE:IsForbidden(region) then return end

    relativePoint = relativePoint or point
    drawLayerSubLevel = drawLayerSubLevel or 0

    local state = self:GetFontState(region)
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
        if state.colorR ~= color.r or state.colorG ~= color.g
           or state.colorB ~= color.b or state.colorA ~= color.a then
            region:SetTextColor(color.r, color.g, color.b, color.a)
            state.colorR, state.colorG, state.colorB, state.colorA = color.r, color.g, color.b, color.a
        end
    end

    if point and relativeFrame then
        if state.point ~= point or state.relativeFrame ~= relativeFrame
           or state.relativePoint ~= relativePoint
           or state.offsetX ~= offsetX or state.offsetY ~= offsetY then
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
        if state.drawLayer ~= drawLayer or state.drawLayerSubLevel ~= drawLayerSubLevel then
            region:SetDrawLayer(drawLayer, drawLayerSubLevel)
            state.drawLayer = drawLayer
            state.drawLayerSubLevel = drawLayerSubLevel
        end
    end
end

-- =========================================================================
-- STACK COUNT STYLING
-- =========================================================================

local function ResolveCountRegion(container)
    if not container or MCE:IsForbidden(container) then return nil end

    local region = container.Count
        or container.count
        or container.StackCount
        or container.stackCount
    if IsUsableFontString(region) then
        return region
    end

    local containerName = container.GetName and container:GetName() or nil
    if type(containerName) == "string" and containerName ~= "" then
        region = _G[containerName .. "Count"] or _G[containerName .. "StackCount"]
        if IsUsableFontString(region) then
            return region
        end
    end

    return nil
end

local function GetStackCountRegion(cdFrame, category)
    local parent = cdFrame:GetParent()
    if not parent then return nil, nil end
    local countRegion

    if category == CATEGORY.Actionbar then
        countRegion = ResolveCountRegion(parent)
    elseif category == CATEGORY.Nameplate
           or category == CATEGORY.Unitframe
           or category == CATEGORY.CompactPartyAura then
        local countFrame = parent.CountFrame or parent.countFrame
        countRegion = ResolveCountRegion(countFrame) or ResolveCountRegion(parent)
    elseif category == CATEGORY.CooldownManager then
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

    if not IsUsableFontString(countRegion) then return nil, parent end
    return countRegion, parent
end

function StyleEngine:GetStackCountRegion(cdFrame, category)
    return GetStackCountRegion(cdFrame, category)
end

function StyleEngine:StyleStackCount(cdFrame, config, category)
    local countRegion, parent = self:GetStackCountRegion(cdFrame, category)
    if not countRegion or not parent then return end

    local fs = self:GetFrameState(cdFrame)

    if config.hideStackText then
        if not fs.stackCountHidden then
            countRegion:SetAlpha(0)
            countRegion:Hide()
            fs.stackCountHidden = true
        end
        return
    end

    if fs.stackCountHidden then
        countRegion:SetAlpha(1)
        countRegion:Show()
        fs.stackCountHidden = nil
    end

    if not config.stackEnabled then return end

    if category ~= CATEGORY.Nameplate
       and category ~= CATEGORY.Unitframe
       and category ~= CATEGORY.CompactPartyAura then
        countRegion:SetAlpha(1)
        countRegion:Show()
    end

    self:ApplyFontStringStyle(
        countRegion, parent,
        MCE.ResolveFontPath(config.stackFont),
        config.stackSize,
        MCE.NormalizeFontStyle(config.stackStyle),
        config.stackColor,
        config.stackAnchor, config.stackAnchor,
        config.stackOffsetX, config.stackOffsetY,
        STYLER_CONSTANTS.StackTextLayer,
        STYLER_CONSTANTS.StackTextSubLevel)
end

-- =========================================================================
-- FONT SIZE RESOLUTION
-- =========================================================================

function StyleEngine:GetCooldownFontSize(cdFrame, category, config)
    if category == CATEGORY.MiniCC then
        local subtype = Registry and Registry:GetSubtype(cdFrame)
        if subtype == MINICC_FRAME_TYPE.CC then return config.ccFontSize or config.fontSize end
        if subtype == MINICC_FRAME_TYPE.FriendlyCD then return config.friendlyCdFontSize or config.fontSize end
        if subtype == MINICC_FRAME_TYPE.Nameplate then return config.nameplateFontSize or config.fontSize end
        if subtype == MINICC_FRAME_TYPE.Portrait then return config.portraitFontSize or config.fontSize end
        if subtype == MINICC_FRAME_TYPE.Overlay then return config.overlayFontSize or config.fontSize end
        return config.fontSize
    end

    if category == CATEGORY.SArena then
        local subtype = Registry and Registry:GetSubtype(cdFrame)
        if subtype == SARENA_FRAME_TYPE.ClassIcon then return config.classIconFontSize or config.fontSize end
        if subtype == SARENA_FRAME_TYPE.DR then return config.drFontSize or config.fontSize end
        if subtype == SARENA_FRAME_TYPE.Trinket or subtype == SARENA_FRAME_TYPE.Racial then
            return config.trinketRacialFontSize or config.fontSize
        end
        return config.fontSize
    end

    if category == CATEGORY.CooldownManager then
        local subtype = Registry and Registry:GetSubtype(cdFrame)
        if subtype == VIEWER_TYPE.Essential then return config.essentialFontSize or config.fontSize end
        if subtype == VIEWER_TYPE.Utility then return config.utilityFontSize or config.fontSize end
        if subtype == VIEWER_TYPE.BuffIcon then return config.buffIconFontSize or config.fontSize end
        return config.fontSize
    end

    return config.fontSize
end

-- =========================================================================
-- HIDE COUNTDOWN NUMBERS RESOLUTION
-- =========================================================================

function StyleEngine:GetDesiredHideCountdownNumbers(cdFrame, category, config, isAssistedCombat)
    local hideNums = config.hideCountdownNumbers

    if category == CATEGORY.MiniCC then
        local subtype = Registry and Registry:GetSubtype(cdFrame)
        if subtype == MINICC_FRAME_TYPE.CC then
            return config.ccHideCountdownNumbers ~= nil and config.ccHideCountdownNumbers or hideNums
        end
        if subtype == MINICC_FRAME_TYPE.FriendlyCD then
            return config.friendlyCdHideCountdownNumbers ~= nil and config.friendlyCdHideCountdownNumbers or hideNums
        end
        if subtype == MINICC_FRAME_TYPE.Nameplate then
            return config.nameplateHideCountdownNumbers ~= nil and config.nameplateHideCountdownNumbers or hideNums
        end
        if subtype == MINICC_FRAME_TYPE.Portrait then
            return config.portraitHideCountdownNumbers ~= nil and config.portraitHideCountdownNumbers or hideNums
        end
        if subtype == MINICC_FRAME_TYPE.Overlay then
            return config.overlayHideCountdownNumbers ~= nil and config.overlayHideCountdownNumbers or hideNums
        end
        return hideNums
    end

    if category == CATEGORY.Actionbar and isAssistedCombat then
        return true
    end

    if category == CATEGORY.Actionbar and not hideNums then
        local parent = cdFrame.GetParent and cdFrame:GetParent() or nil
        local isChargeCooldown = self:IsChargeCooldownFrame(cdFrame, parent)
        if config.hideChargeTimers and isChargeCooldown then
            hideNums = true
        elseif not config.hideChargeTimers
               and self:IsMainCooldownWithActiveChargeCooldown(cdFrame) then
            hideNums = true
        end
    end

    if category == CATEGORY.Unitframe and not hideNums and config.auraCdTextOnlyMine then
        local isLargeAura = self:IsUnitFrameLargeAura(cdFrame)
        if isLargeAura ~= nil then
            return not isLargeAura
        end
    end

    return hideNums
end

-- =========================================================================
-- UNIT FRAME LARGE AURA
-- =========================================================================

function StyleEngine:IsUnitFrameLargeAura(cdFrame)
    local fs = self:ResolveCooldownContext(cdFrame)
    -- Preserve pre-refactor behavior: once a cooldown is already classified as a
    -- unit-frame aura, the "Only Mine" heuristic should still run even if the
    -- current parent chain does not expose Buff/Debuff/Aura in frame names.
    if not fs.hasAuraNamedAncestor then
        local category = Registry and Registry:GetCategory(cdFrame)
        if category ~= CATEGORY.Unitframe then
            return nil
        end
    end

    local auraOwner = fs.auraInstanceOwner ~= false and fs.auraInstanceOwner or nil
    if not auraOwner then
        local parent = cdFrame.GetParent and cdFrame:GetParent()
        if parent and not MCE:IsForbidden(parent) then
            auraOwner = parent
        else
            return nil
        end
    end

    local auraInstanceID = self:GetFrameAuraInstanceID(auraOwner)
    if auraInstanceID
       and auraOwner.mceAuraTextOnlyMineInstanceID == auraInstanceID
       and auraOwner.mceIsLargeAura ~= nil then
        return auraOwner.mceIsLargeAura == true
    end

    local width = auraOwner.GetWidth and auraOwner:GetWidth() or nil
    if type(width) ~= "number" or width <= 0 then return nil end

    local isLargeAura = width > LARGE_AURA_WIDTH_THRESHOLD
    if auraInstanceID then
        auraOwner.mceAuraTextOnlyMineInstanceID = auraInstanceID
        auraOwner.mceIsLargeAura = isLargeAura
    end
    return isLargeAura
end

-- =========================================================================
-- MAIN STYLE APPLICATION
-- =========================================================================

function StyleEngine:ApplyStyle(cdFrame, forcedCategory)
    if MCE:IsForbidden(cdFrame) then return end

    -- Check compact party/raid aura before generic styling
    if CompactAura and CompactAura:SyncCooldown(cdFrame) then
        return
    end

    -- Check blacklist
    if Classifier and Classifier:IsBlacklisted(cdFrame) then return end

    -- Get category from registry
    local category = forcedCategory
    if not category then
        category = Registry and Registry:GetCategory(cdFrame)
    end
    if not category then return end

    -- Override: MiniCC takes precedence when detected
    if forcedCategory == CATEGORY.Nameplate and Registry then
        local sub = Registry:GetSubtype(cdFrame)
        if sub and (sub == MINICC_FRAME_TYPE.CC or sub == MINICC_FRAME_TYPE.FriendlyCD
                    or sub == MINICC_FRAME_TYPE.Nameplate or sub == MINICC_FRAME_TYPE.Portrait
                    or sub == MINICC_FRAME_TYPE.Overlay) then
            category = CATEGORY.MiniCC
        end
    end

    if category == CATEGORY.Blacklist then return end

    -- Guard: DB must be ready
    if not (MCE.db and MCE.db.profile and MCE.db.profile.categories) then return end

    local config = MCE.db.profile.categories[category]
    local isAssistedCombat = (category == CATEGORY.Actionbar and self:IsAssistedCombatActionCooldown(cdFrame))

    if not config or not config.enabled then
        if DurationColor then
            DurationColor:ClearTrackedDurationColor(cdFrame)
        end
        self:ReleaseManagedVisualState(cdFrame, category)
        return
    end

    local fs = self:GetFrameState(cdFrame)
    local parent = cdFrame.GetParent and cdFrame:GetParent()

    local isChargeCooldown = self:IsChargeCooldownFrame(cdFrame, parent)
    local hasActiveCharge = isChargeCooldown and self:IsMainCooldownWithActiveChargeCooldown(cdFrame)

    -- Draw Swipe
    local wantSwipe = config.drawSwipe ~= false and (not isChargeCooldown or hasActiveCharge)
    if cdFrame.SetDrawSwipe then
        if fs.drawSwipe ~= wantSwipe then
            fs.suppressSwipeDraw = true
            pcall(cdFrame.SetDrawSwipe, cdFrame, wantSwipe)
            fs.suppressSwipeDraw = nil
            fs.drawSwipe = wantSwipe
        end
    end

    -- Draw Edge
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

    if config.edgeEnabled and cdFrame.SetEdgeColor then
        local edgeColor = self:GetDesiredEdgeColor(cdFrame)
        if edgeColor and not IsSameSwipeColor(fs.edgeColor, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a) then
            fs.suppressEdgeColor = true
            pcall(cdFrame.SetEdgeColor, cdFrame, edgeColor.r, edgeColor.g, edgeColor.b, edgeColor.a)
            fs.suppressEdgeColor = nil
            fs.edgeColor = {
                r = edgeColor.r,
                g = edgeColor.g,
                b = edgeColor.b,
                a = edgeColor.a,
            }
        elseif not edgeColor then
            fs.edgeColor = nil
        end
    else
        fs.edgeColor = nil
    end

    -- Swipe Color
    if cdFrame.SetSwipeColor then
        if category == CATEGORY.Actionbar then
            local r, g, b, a = 0, 0, 0, self:GetSwipeShadeAlpha(config)
            if not IsSameSwipeColor(fs.swipeColor, r, g, b, a) then
                fs.suppressSwipe = true
                pcall(cdFrame.SetSwipeColor, cdFrame, r, g, b, a)
                fs.suppressSwipe = nil
                fs.swipeColor = { r = r, g = g, b = b, a = a }
            end
        else
            self:ResetSwipeColor(cdFrame)
        end
    end

    -- Hide countdown numbers
    local hideNums
    if cdFrame.SetHideCountdownNumbers then
        hideNums = self:GetDesiredHideCountdownNumbers(cdFrame, category, config, isAssistedCombat)
        if fs.hideNums ~= hideNums then
            fs.suppressHideNums = true
            pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hideNums)
            fs.suppressHideNums = nil
            fs.hideNums = hideNums
        end
    end

    -- Style key for change detection
    local styleKey = category
    if category == CATEGORY.CooldownManager then
        local subtype = Registry and Registry:GetSubtype(cdFrame) or "default"
        styleKey = category .. ":" .. subtype
    elseif category == CATEGORY.MiniCC or category == CATEGORY.SArena then
        local subtype = Registry and Registry:GetSubtype(cdFrame) or "default"
        styleKey = category .. ":" .. subtype
    end

    local needsFullRestyle = fs.styledCat ~= styleKey
    local textRegions, textRegionCount, textRegionsChanged
    local needsDeferredTextRefresh = fs.forceTextRegionRefresh == true
    local shouldRefreshTextRegions = needsFullRestyle
        or category == CATEGORY.MiniCC
        or category == CATEGORY.SArena
        or needsDeferredTextRefresh
        or (not hideNums and GetTrackedTextRegionCount(fs) == 0)

    if shouldRefreshTextRegions then
        textRegions, textRegionCount = self:GetCooldownTextRegions(cdFrame)
        textRegionsChanged = HaveCooldownTextRegionsChanged(fs, textRegions, textRegionCount)
        fs.forceTextRegionRefresh = nil
    end

    if needsFullRestyle then fs.styledCat = styleKey end

    -- Stack count (enforced every pass)
    self:StyleStackCount(cdFrame, config, category)

    -- Assisted combat action: hide text
    if isAssistedCombat then
        if not fs.assistedCombatTextHidden then
            self:SetCooldownTextRegionsVisible(cdFrame, false)
            fs.assistedCombatTextHidden = true
        end
        if DurationColor then DurationColor:ClearTrackedDurationColor(cdFrame) end
        return
    elseif fs.assistedCombatTextHidden then
        self:SetCooldownTextRegionsVisible(cdFrame, not hideNums)
        fs.assistedCombatTextHidden = nil
    end

    -- Font styling (only when category/viewer changed or text regions changed)
    if needsFullRestyle or textRegionsChanged then
        fs.appliedTextColor = nil
        local fontStyle = MCE.NormalizeFontStyle(config.fontStyle)
        local resolvedFont = MCE.ResolveFontPath(config.font)
        local fontSize = self:GetCooldownFontSize(cdFrame, category, config)

        -- Some third-party addons recalculate cooldown font size after MiniCE
        -- applies styling. Enforce our chosen font for those integrations so
        -- the configured text size remains stable.
        local enforceFont = (category == CATEGORY.SArena or category == CATEGORY.MiniCC)

        for i = 1, textRegionCount do
            self:ApplyFontStringStyle(
                textRegions[i], cdFrame,
                resolvedFont, fontSize, fontStyle,
                config.textColor,
                config.textAnchor, config.textAnchor,
                config.textOffsetX, config.textOffsetY,
                nil, nil, enforceFont)
        end
    end

    -- Abbreviation threshold
    local profile = MCE.db and MCE.db.profile
    if profile and cdFrame.SetCountdownAbbrevThreshold then
        pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame, profile.abbrevThreshold or C.Options.DefaultAbbrevThreshold)
    end

    -- Duration colors
    if DurationColor then
        DurationColor:RefreshTrackedDurationColor(cdFrame, category, config)
    end
end

-- =========================================================================
-- STATE MANAGEMENT
-- =========================================================================

function StyleEngine:WipeState()
    wipe(frameState)
    wipe(fontState)
end
