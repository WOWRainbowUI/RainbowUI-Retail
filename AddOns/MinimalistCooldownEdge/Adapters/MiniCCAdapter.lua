-- Adapters/MiniCCAdapter.lua – MiniCC frame cooldown discovery
--
-- MiniCC frame hierarchy (from IconSlotContainer.lua):
--   MiniCC_Cooldown_N  (cooldown widget, depth 0)
--     parent: MiniCC_Layer_N      (depth 1)
--     parent: MiniCC_Slot_N       (depth 2)
--     parent: MiniCC_Container_N  (depth 3)  ← top MiniCC frame
--     parent: anchor frame (nameplate / unit frame / UIParent)
-- The depth is always fixed at 3 hops – no deep scanning required.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("MiniCCAdapter")

local type = type
local strfind, strlower = string.find, string.lower

local CATEGORY = C.Categories
local MINICC_FRAME_TYPE = C.MiniCCFrameTypes
local CLASSIFIER_CONSTANTS = C.Classifier
local MINICC_PREFIX = CLASSIFIER_CONSTANTS.MiniCCNamePrefix
local NP_PATTERNS = CLASSIFIER_CONSTANTS.NameplatePatterns
local UF_PATTERNS = CLASSIFIER_CONSTANTS.UnitFramePatterns
local MINICC_MODULE_TO_FRAME_TYPE = {
    Alerts = MINICC_FRAME_TYPE.Overlay,
    CC = MINICC_FRAME_TYPE.CC,
    ["Friendly CDs"] = MINICC_FRAME_TYPE.FriendlyCD,
    ["Friendly Indicators"] = MINICC_FRAME_TYPE.FriendlyCD,
    Nameplates = MINICC_FRAME_TYPE.Nameplate,
    Portraits = MINICC_FRAME_TYPE.Portrait,
    ["Healer CC"] = MINICC_FRAME_TYPE.Overlay,
    ["Kick Timer"] = MINICC_FRAME_TYPE.Overlay,
    Precognition = MINICC_FRAME_TYPE.Overlay,
}
local MINICC_ANCHOR_TO_FRAME_TYPE = {
    MiniCCHealerContainer = MINICC_FRAME_TYPE.Overlay,
    MiniCCPrecogGuesser = MINICC_FRAME_TYPE.Overlay,
}

-- Fixed number of parent hops from cooldown to container frame.
local CONTAINER_DEPTH = 3

local Registry
local trackedCooldowns = setmetatable({}, addon.weakMeta)

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.MiniCC, self)
end

-- =========================================================================
-- FRAME IDENTITY HELPERS
-- =========================================================================

local function IsMiniCCNamedFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string" and strfind(name, MINICC_PREFIX, 1, true) == 1
end

local function ContainsAnyPattern(value, patterns)
    for i = 1, #patterns do
        if strfind(value, patterns[i], 1, true) then return true end
    end
    return false
end

local function ExtractUnitToken(unit)
    if type(unit) == "string" then return unit ~= "" and unit or nil end
    if type(unit) ~= "table" then return nil end
    local token = unit.unitid or unit.unitID or unit.unitToken
        or unit.displayedUnit or unit.unit
    if type(token) == "string" and token ~= "" then return token end
    return nil
end

local function IsNameplateContext(name, objType, unit)
    local unitToken = ExtractUnitToken(unit)
    local lowerName = name and type(name) == "string" and strlower(name) or ""
    return objType == CLASSIFIER_CONSTANTS.NameplateObjectType
        or ContainsAnyPattern(lowerName, NP_PATTERNS)
        or (unitToken and type(unitToken) == "string"
            and strfind(strlower(unitToken), NP_PATTERNS[1], 1, true))
end

local function IsUnitFrameContext(frame)
    if not frame then return false end
    local unit = ExtractUnitToken(frame.unit) or ExtractUnitToken(frame.unitid)
        or ExtractUnitToken(frame.unitToken) or ExtractUnitToken(frame.displayedUnit)
    if unit and not strfind(unit, NP_PATTERNS[1], 1, true) then return true end
    local name = MCE:GetFrameName(frame) or ""
    return ContainsAnyPattern(name, UF_PATTERNS)
end

local function GetFrameUnit(frame)
    if not frame then return nil end
    return ExtractUnitToken(frame.unit) or ExtractUnitToken(frame.unitid)
        or ExtractUnitToken(frame.unitToken) or ExtractUnitToken(frame.displayedUnit)
end

-- =========================================================================
-- MINICC HIERARCHY HELPERS
-- =========================================================================

-- Walk exactly CONTAINER_DEPTH parent hops to reach MiniCC_Container_N.
-- Returns (container, anchor) or (nil, nil) on failure.
local function GetMiniCCContainerAndAnchor(cooldown)
    local frame = cooldown
    for _ = 1, CONTAINER_DEPTH do
        frame = frame.GetParent and frame:GetParent()
        if not frame then return nil, nil end
    end
    -- Sanity check: the container must also carry the MiniCC_ prefix
    if not IsMiniCCNamedFrame(frame) then return nil, nil end
    return frame, frame:GetParent()
end

local function GetMiniCCPointRelativeFrame(frame)
    if not frame or not frame.GetPoint then return nil end
    local ok, _, relativeTo = pcall(frame.GetPoint, frame, 1)
    if ok then return relativeTo end
    return nil
end

local function ReadMiniCCModule(frame)
    if not frame then return nil end
    local moduleName = frame.MiniCCModule
    if type(moduleName) == "string" and moduleName ~= "" then
        return moduleName
    end
    return nil
end

local function ResolveMiniCCFrameTypeFromModule(container, anchor, cooldown)
    local moduleName = ReadMiniCCModule(container)
        or ReadMiniCCModule(anchor)
        or ReadMiniCCModule(cooldown)
    if not moduleName then return nil end
    return MINICC_MODULE_TO_FRAME_TYPE[moduleName]
end

local function ResolveMiniCCFrameTypeFromAnchor(anchor)
    local anchorName = MCE:GetFrameName(anchor)
    if not anchorName then return nil end
    return MINICC_ANCHOR_TO_FRAME_TYPE[anchorName]
end

-- =========================================================================
-- MINICC TYPE RESOLUTION
-- =========================================================================

local function ResolveMiniCCFrameType(cooldown)
    -- Quick reject: cooldown must carry the MiniCC_ name prefix
    if not IsMiniCCNamedFrame(cooldown) then return nil end

    -- Fixed 3-hop walk: cooldown → layer → slot → container
    local container, anchor = GetMiniCCContainerAndAnchor(cooldown)
    if not container then return nil end

    -- 1. MiniCC mirrors its module label onto the container frame as
    --    instance.Frame.MiniCCModule in IconSlotContainer:New so it is readable here.
    --    This now covers the explicit module-tagged containers, including Portraits.
    local moduleFrameType = ResolveMiniCCFrameTypeFromModule(container, anchor, cooldown)
    if moduleFrameType then
        return moduleFrameType
    end

    -- 2. Direct parent check (Nameplate and Portrait modules parent the
    --    container directly to the nameplate / unit frame).
    if anchor then
        local anchorName  = MCE:GetFrameName(anchor) or ""
        local anchorObjT  = anchor.GetObjectType and anchor:GetObjectType() or ""
        local anchorUnit  = GetFrameUnit(anchor)

        if IsNameplateContext(anchorName, anchorObjT, anchorUnit) then
            return MINICC_FRAME_TYPE.Nameplate
        end
        if IsUnitFrameContext(anchor) then
            return MINICC_FRAME_TYPE.Portrait
        end
    end

    -- 3. Dedicated MiniCC anchors identify standalone widgets even when the
    --    module metadata is not exposed on the frame yet.
    local anchorFrameType = ResolveMiniCCFrameTypeFromAnchor(anchor)
    if anchorFrameType then
        return anchorFrameType
    end

    -- 4. GetPoint fallback for containers parented to UIParent (CC, Alerts,
    --    FriendlyIndicator, KickTimer, Trinkets …) – use the SetPoint anchor.
    local relativeTo = GetMiniCCPointRelativeFrame(container)
    if relativeTo then
        local relativeName = MCE:GetFrameName(relativeTo) or ""
        local relativeObjT = relativeTo.GetObjectType and relativeTo:GetObjectType() or ""
        local relativeUnit = GetFrameUnit(relativeTo)

        if IsNameplateContext(relativeName, relativeObjT, relativeUnit) then
            return MINICC_FRAME_TYPE.Nameplate
        end
        if IsUnitFrameContext(relativeTo) then
            return MINICC_FRAME_TYPE.CC
        end
    end

    return MINICC_FRAME_TYPE.Overlay
end

-- =========================================================================
-- ADAPTER API
-- =========================================================================

function Adapter:Rebuild()
    for cooldown in pairs(trackedCooldowns) do
        if cooldown and not MCE:IsForbidden(cooldown) then
            local frameType = ResolveMiniCCFrameType(cooldown)
            if frameType then
                Registry:Register(cooldown, CATEGORY.MiniCC, frameType)
            else
                trackedCooldowns[cooldown] = nil
            end
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not MCE:IsMiniCCAvailable() then return nil end
    local frameType = ResolveMiniCCFrameType(cooldown)
    if frameType then
        trackedCooldowns[cooldown] = true
        return CATEGORY.MiniCC, frameType
    end
    return nil
end
