-- CompactGroupAuraController.lua – Compact party / raid frame aura styling
--
-- Intercepts cooldowns belonging to Blizzard CompactPartyFrame and
-- CompactRaidFrame aura icons, applying dedicated text / swipe overrides.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local CompactAura = MCE:NewModule("CompactGroupAuraController")

local pairs, type, pcall, wipe = pairs, type, pcall, wipe
local setmetatable = setmetatable

local CATEGORY = C.Categories
local GROUP_FRAME_TYPE = C.GroupFrameTypes
local STYLE_CONSTANTS = C.Style
local DEFAULT_EDGE_SCALE = 1
local weakMeta = addon.weakMeta
local frameState = addon.frameState

local StyleEngine, DurationColor, Registry, GroupFrameAdapter

-- Tracks compact aura cooldowns for cleanup on disable
local compactPartyAuraFrames = setmetatable({}, weakMeta)

function CompactAura:OnEnable()
    StyleEngine = MCE:GetModule("StyleEngine")
    DurationColor = MCE:GetModule("DurationColorController")
    Registry = MCE:GetModule("TargetRegistry")
    GroupFrameAdapter = MCE:GetModule("GroupFrameAdapter")
end

-- =========================================================================
-- CONFIG ACCESS
-- =========================================================================

function CompactAura:GetConfig()
    local profile = MCE.db and MCE.db.profile
    if not profile then return nil end
    return profile.compactPartyAuraText
end

-- =========================================================================
-- FRAME TYPE DETECTION
-- =========================================================================

function CompactAura:GetCompactPartyAuraFrameType(cdFrame)
    local subtype = Registry and Registry:GetSubtype(cdFrame)
    if subtype == GROUP_FRAME_TYPE.Party or subtype == GROUP_FRAME_TYPE.Raid then
        return subtype
    end

    local fs = frameState[cdFrame]
    if fs and fs.compactPartyAuraTypeResolved then
        local frameType = fs.compactPartyAuraType
        return frameType and frameType ~= false and frameType or nil
    end

    local frameType = GroupFrameAdapter and GroupFrameAdapter.ResolveCompactPartyAuraType
        and GroupFrameAdapter:ResolveCompactPartyAuraType(cdFrame) or nil

    fs = fs or StyleEngine:GetFrameState(cdFrame)
    fs.compactPartyAuraTypeResolved = true
    fs.compactPartyAuraType = frameType or false
    return frameType
end

function CompactAura:ShouldUseCompactPartyAuraText(config, frameType)
    if not config or not config.enabled then return false end
    if frameType == GROUP_FRAME_TYPE.Raid then return config.raidEnabled end
    if frameType == GROUP_FRAME_TYPE.Party then return true end
    return false
end

-- =========================================================================
-- NATIVE TEXT HELPERS
-- =========================================================================

local function GetNativeText(cdFrame)
    local nativeText = cdFrame.GetCountdownFontString and cdFrame:GetCountdownFontString()
    if nativeText and not MCE:IsForbidden(nativeText) then return nativeText end
    return nil
end

local function SetNativeTextVisible(cdFrame, visible)
    local nativeText = GetNativeText(cdFrame)
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

local function SetNativeHide(cdFrame, hide)
    if not cdFrame.SetHideCountdownNumbers then return end
    local fs = StyleEngine:GetFrameState(cdFrame)
    if fs.hideNums == hide then return end
    fs.suppressHideNums = true
    pcall(cdFrame.SetHideCountdownNumbers, cdFrame, hide)
    fs.suppressHideNums = nil
    fs.hideNums = hide
end

-- =========================================================================
-- FONT SIZE
-- =========================================================================

local function GetAuraFontSize(cdFrame, config)
    if not config then return nil end
    local fs = StyleEngine:ResolveCooldownContext(cdFrame)
    if fs and fs.compactPartyCenterDefensiveBuff == true then
        return config.defensiveBuffFontSize or config.fontSize
    end
    return config.fontSize
end

-- =========================================================================
-- TEXT STYLING
-- =========================================================================

local function ApplyTextStyle(cdFrame, config)
    local text = GetNativeText(cdFrame)
    if not text then return nil end

    StyleEngine:GetFrameState(cdFrame).appliedTextColor = nil

    local anchor = config.textAnchor or STYLE_CONSTANTS.Anchors.Center
    local offsetX = config.textOffsetX or 0
    local offsetY = config.textOffsetY or 0

    StyleEngine:ApplyFontStringStyle(
        text, cdFrame,
        MCE.ResolveFontPath(config.font),
        GetAuraFontSize(cdFrame, config),
        MCE.NormalizeFontStyle(config.fontStyle),
        config.textColor,
        anchor, anchor, offsetX, offsetY,
        nil, nil, false)
    return text
end

-- =========================================================================
-- SWIPE STYLING
-- =========================================================================

local function ApplySwipeStyle(cdFrame, config)
    local fs = StyleEngine:GetFrameState(cdFrame)
    local wantSwipe = config.drawSwipe ~= false
    fs.compactAuraSwipeReset = nil

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

    StyleEngine:ResetSwipeColor(cdFrame)
end

local function ResetSwipeStyle(cdFrame)
    local fs = StyleEngine:GetFrameState(cdFrame)
    if fs.compactAuraSwipeReset then return end

    if cdFrame.SetDrawSwipe then
        if fs.drawSwipe ~= true then
            fs.suppressSwipeDraw = true
            pcall(cdFrame.SetDrawSwipe, cdFrame, true)
            fs.suppressSwipeDraw = nil
        end
    end

    if cdFrame.SetDrawEdge then
        if fs.edge ~= true then
            fs.suppressEdge = true
            pcall(cdFrame.SetDrawEdge, cdFrame, true)
            fs.suppressEdge = nil
        end
        if cdFrame.SetEdgeScale then
            if fs.edgeScale ~= DEFAULT_EDGE_SCALE then
                fs.suppressEdgeScale = true
                pcall(cdFrame.SetEdgeScale, cdFrame, DEFAULT_EDGE_SCALE)
                fs.suppressEdgeScale = nil
            end
        end
    end

    StyleEngine:ResetSwipeColor(cdFrame)
    fs.drawSwipe = nil
    fs.edge = nil
    fs.edgeScale = nil
    fs.compactAuraSwipeReset = true
end

-- =========================================================================
-- MAIN SYNC
-- =========================================================================

function CompactAura:SyncCooldown(cdFrame)
    local frameType = self:GetCompactPartyAuraFrameType(cdFrame)
    if not frameType then return false end
    compactPartyAuraFrames[cdFrame] = true

    local config = self:GetConfig()
    if not self:ShouldUseCompactPartyAuraText(config, frameType) then
        if DurationColor then DurationColor:ClearTrackedDurationColor(cdFrame) end
        SetNativeTextVisible(cdFrame, false)
        SetNativeHide(cdFrame, true)
        ResetSwipeStyle(cdFrame)
        StyleEngine:StyleStackCount(cdFrame, config, CATEGORY.CompactPartyAura)
        return true
    end

    local text = ApplyTextStyle(cdFrame, config)
    SetNativeHide(cdFrame, false)
    if text then SetNativeTextVisible(cdFrame, true) end

    local profile = MCE.db and MCE.db.profile
    if profile and cdFrame.SetCountdownAbbrevThreshold then
        pcall(cdFrame.SetCountdownAbbrevThreshold, cdFrame,
              profile.abbrevThreshold or C.Options.DefaultAbbrevThreshold)
    end

    if DurationColor then
        DurationColor:RefreshTrackedDurationColor(cdFrame, CATEGORY.CompactPartyAura, config)
    end

    ApplySwipeStyle(cdFrame, config)
    StyleEngine:StyleStackCount(cdFrame, config, CATEGORY.CompactPartyAura)
    return true
end

-- =========================================================================
-- RESET / DISABLE
-- =========================================================================

function CompactAura:Reset()
    for cd in pairs(compactPartyAuraFrames) do
        if cd and not MCE:IsForbidden(cd) then
            SetNativeTextVisible(cd, true)
            SetNativeHide(cd, false)
            ResetSwipeStyle(cd)
            -- Restore Blizzard default stack count visibility
            local fs = StyleEngine:GetFrameState(cd)
            if fs.stackCountHidden then
                local countRegion = StyleEngine:GetStackCountRegion(cd, CATEGORY.CompactPartyAura)
                if countRegion then
                    countRegion:SetAlpha(1)
                    countRegion:Show()
                end
                fs.stackCountHidden = nil
            end
        end
    end
    wipe(compactPartyAuraFrames)
end
