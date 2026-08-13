-- Adapters/MiniAurasAdapter.lua - MiniAuras frame cooldown discovery
--
-- MiniAuras has two cooldown hierarchies:
--   Legacy IconSlotContainer (12.0): Cooldown -> Layer -> Slot -> Container
--   AuraContainerDisplay (12.1):     Cooldown -> AuraButton -> AuraContainer
-- Both container types carry the legacy MiniCCModule field as MiniAuras' documented
-- compatibility tag for third-party addons. The frame names themselves use MiniAuras_.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("MiniAurasAdapter")

local type = type
local strfind, strlower = string.find, string.lower
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local _G = _G

local CATEGORY = C.Categories
local MINIAURAS_FRAME_TYPE = C.MiniAurasFrameTypes
local CLASSIFIER_CONSTANTS = C.Classifier
local ADAPTER_CONSTANTS = C.Adapter.MiniAuras
local MINIAURAS_PREFIX = CLASSIFIER_CONSTANTS.MiniAurasNamePrefix
local NP_PATTERNS = CLASSIFIER_CONSTANTS.NameplatePatterns
local UF_PATTERNS = CLASSIFIER_CONSTANTS.UnitFramePatterns
local MINIAURAS_MODULE_TO_FRAME_TYPE = {
    Alerts = MINIAURAS_FRAME_TYPE.Overlay,
    CC = MINIAURAS_FRAME_TYPE.CC,
    ["Enemy CDs"] = MINIAURAS_FRAME_TYPE.LegacyEnemyCD,
    ["Friendly CDs"] = MINIAURAS_FRAME_TYPE.LegacyFriendlyCD,
    ["Friendly Indicators"] = MINIAURAS_FRAME_TYPE.RaidFrameAura,
    Nameplates = MINIAURAS_FRAME_TYPE.Nameplate,
    Portraits = MINIAURAS_FRAME_TYPE.Portrait,
    ["Healer CC"] = MINIAURAS_FRAME_TYPE.Overlay,
    ["Kick Timer"] = MINIAURAS_FRAME_TYPE.Overlay,
    Precognition = MINIAURAS_FRAME_TYPE.Overlay,
    Trinkets = MINIAURAS_FRAME_TYPE.Overlay,
    ["Custom Auras"] = MINIAURAS_FRAME_TYPE.Overlay,
}
local MINIAURAS_ANCHOR_TO_FRAME_TYPE = {
    MiniAurasHealerContainer = MINIAURAS_FRAME_TYPE.Overlay,
    MiniAurasPrecog = MINIAURAS_FRAME_TYPE.Overlay,
}

local LEGACY_CONTAINER_PREFIX = "MiniAuras_Container_"
local AURA_CONTAINER_PREFIX = "MiniAuras_AC_Container_"
local LEGACY_COOLDOWN_PREFIX = "MiniAuras_Cooldown_"
local AURA_COOLDOWN_PREFIX = "MiniAuras_AC_Cooldown_"
local MAX_CONTAINER_DEPTH = 4

local Registry
local frameState = addon.frameState
local trackedCooldowns = setmetatable({}, addon.weakMeta)
local initializationStyling = setmetatable({}, addon.weakMeta)
local initializationHookInstalled = false

-- =========================================================================
-- FRAME IDENTITY HELPERS
-- =========================================================================

local function IsMiniAurasNamedFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string" and strfind(name, MINIAURAS_PREFIX, 1, true) == 1
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
-- MINIAURAS HIERARCHY HELPERS
-- =========================================================================

local function GetMiniAurasPointRelativeFrame(frame)
    if not frame or not frame.GetPoint then return nil end
    local ok, _, relativeTo = pcall(frame.GetPoint, frame, 1)
    if ok then return relativeTo end
    return nil
end

local function ReadMiniAurasModule(frame)
    if not frame then return nil end
    -- MiniAuras intentionally retains this legacy public field for integrations.
    local moduleName = MCE:SafeTableGet(frame, "MiniCCModule")
    if type(moduleName) == "string" and moduleName ~= "" then
        return moduleName
    end
    return nil
end

local function IsMiniAurasContainer(frame)
    if not frame then return false end
    if ReadMiniAurasModule(frame) then return true end

    local name = MCE:GetFrameName(frame)
    return type(name) == "string"
        and (strfind(name, LEGACY_CONTAINER_PREFIX, 1, true) == 1
            or strfind(name, AURA_CONTAINER_PREFIX, 1, true) == 1)
end

-- Locate either supported container without assuming the hierarchy depth.
-- Returns (container, anchor) or (nil, nil) on failure.
local function GetMiniAurasContainerAndAnchor(cooldown)
    local frame = cooldown
    for _ = 1, MAX_CONTAINER_DEPTH do
        frame = frame.GetParent and frame:GetParent()
        if not frame then return nil, nil end
        if IsMiniAurasContainer(frame) then
            return frame, frame.GetParent and frame:GetParent() or nil
        end
    end
    return nil, nil
end

local function ResolveMiniAurasFrameTypeFromModule(container, anchor, cooldown)
    local moduleName = ReadMiniAurasModule(container)
        or ReadMiniAurasModule(anchor)
        or ReadMiniAurasModule(cooldown)
    if not moduleName then return nil end
    return MINIAURAS_MODULE_TO_FRAME_TYPE[moduleName]
end

local function ResolveMiniAurasFrameTypeFromAnchor(anchor)
    local anchorName = MCE:GetFrameName(anchor)
    if not anchorName then return nil end
    return MINIAURAS_ANCHOR_TO_FRAME_TYPE[anchorName]
end

-- =========================================================================
-- MINIAURAS TYPE RESOLUTION
-- =========================================================================

local function ResolveMiniAurasFrameType(cooldown)
    -- Quick reject: MiniAuras names both legacy and AuraContainer cooldowns.
    if not IsMiniAurasNamedFrame(cooldown) then return nil end

    local container, anchor = GetMiniAurasContainerAndAnchor(cooldown)
    if not container then return nil end

    -- 1. Prefer MiniAuras' compatibility module tag. It covers both container
    --    implementations and remains stable when the anchor hierarchy changes.
    local moduleFrameType = ResolveMiniAurasFrameTypeFromModule(container, anchor, cooldown)
    if moduleFrameType then
        return moduleFrameType
    end

    -- 2. Direct parent check for untagged containers.
    if anchor then
        local anchorName  = MCE:GetFrameName(anchor) or ""
        local anchorObjT  = anchor.GetObjectType and anchor:GetObjectType() or ""
        local anchorUnit  = GetFrameUnit(anchor)

        if IsNameplateContext(anchorName, anchorObjT, anchorUnit) then
            return MINIAURAS_FRAME_TYPE.Nameplate
        end
        if IsUnitFrameContext(anchor) then
            return MINIAURAS_FRAME_TYPE.Portrait
        end
    end

    -- 3. Dedicated MiniAuras anchors identify standalone widgets even when the
    --    module metadata is not exposed on the frame yet.
    local anchorFrameType = ResolveMiniAurasFrameTypeFromAnchor(anchor)
    if anchorFrameType then
        return anchorFrameType
    end

    -- 4. GetPoint fallback for containers parented to UIParent.
    local relativeTo = GetMiniAurasPointRelativeFrame(container)
    if relativeTo then
        local relativeName = MCE:GetFrameName(relativeTo) or ""
        local relativeObjT = relativeTo.GetObjectType and relativeTo:GetObjectType() or ""
        local relativeUnit = GetFrameUnit(relativeTo)

        if IsNameplateContext(relativeName, relativeObjT, relativeUnit) then
            return MINIAURAS_FRAME_TYPE.Nameplate
        end
        if IsUnitFrameContext(relativeTo) then
            return MINIAURAS_FRAME_TYPE.CC
        end
    end

    return MINIAURAS_FRAME_TYPE.Overlay
end

-- =========================================================================
-- ADAPTER API
-- =========================================================================

function Adapter:Rebuild()
    for cooldown in pairs(trackedCooldowns) do
        if cooldown and not MCE:IsForbidden(cooldown) then
            local frameType = ResolveMiniAurasFrameType(cooldown)
            if frameType then
                Registry:Register(cooldown, CATEGORY.MiniAuras, frameType)
            else
                trackedCooldowns[cooldown] = nil
            end
        end
    end

    if not MCE:IsMiniAurasAvailable() then return end

    -- Both MiniAuras display backends expose stable, globally named Cooldown
    -- frames. Targeted lookup registers buttons that MiniAuras created before
    -- MiniCE's lifetime hooks were installed without using EnumerateFrames().
    local function DiscoverNamedCooldowns(prefix)
        local trailingMisses = 0
        for frameID = 1, ADAPTER_CONSTANTS.MaxNamedFrameID do
            local cooldown = MCE:SafeTableGet(_G, prefix .. frameID)
            if cooldown then
                trailingMisses = 0
                if MCE:CanUseFrameAsTableKey(cooldown) then
                    local frameType = ResolveMiniAurasFrameType(cooldown)
                    if frameType then
                        local state = frameState[cooldown]
                        if not state then
                            state = {}
                            frameState[cooldown] = state
                        end
                        state.allowBlacklisted = true
                        trackedCooldowns[cooldown] = true
                        Registry:Register(cooldown, CATEGORY.MiniAuras, frameType)
                    end
                end
            else
                trailingMisses = trailingMisses + 1
                if trailingMisses >= ADAPTER_CONSTANTS.TrailingNamedFrameMissLimit then
                    break
                end
            end
        end
    end

    DiscoverNamedCooldowns(LEGACY_COOLDOWN_PREFIX)
    DiscoverNamedCooldowns(AURA_COOLDOWN_PREFIX)
end

function Adapter:TryClaim(cooldown)
    if not MCE:IsMiniAurasAvailable() then return nil end

    local frameType = ResolveMiniAurasFrameType(cooldown)
    if frameType then
        local state = frameState[cooldown]
        if not state then
            state = {}
            frameState[cooldown] = state
        end
        state.allowBlacklisted = true
        trackedCooldowns[cooldown] = true
        return CATEGORY.MiniAuras, frameType
    end
    return nil
end

-- AuraContainer buttons can become forbidden as soon as their initialization
-- callback returns. Claim and style newly created MiniAuras cooldowns from a
-- setter MiniAuras calls inside that safe callback, while the button is still
-- externally inspectable.
local function TryStyleDuringInitialization(cooldown)
    if initializationStyling[cooldown] or not MCE:IsMiniAurasAvailable() then return end
    if not MCE:CanUseFrameAsTableKey(cooldown) then return end

    local frameType = ResolveMiniAurasFrameType(cooldown)
    if not frameType then return end

    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end
    state.allowBlacklisted = true
    trackedCooldowns[cooldown] = true
    Registry:Register(cooldown, CATEGORY.MiniAuras, frameType)

    local styleEngine = MCE:GetModule("StyleEngine", true)
    if not (styleEngine and styleEngine:IsEnabled()) then return end

    initializationStyling[cooldown] = true
    pcall(styleEngine.ApplyStyle, styleEngine, cooldown, CATEGORY.MiniAuras)
    initializationStyling[cooldown] = nil
end

local function InstallInitializationHook()
    if initializationHookInstalled or type(CreateFrame) ~= "function" then return end

    local probe = CreateFrame("Cooldown")
    local meta = probe and getmetatable(probe)
    local cooldownAPI = meta and meta.__index
    if type(cooldownAPI) ~= "table"
        or type(cooldownAPI.SetHideCountdownNumbers) ~= "function" then
        return
    end

    hooksecurefunc(cooldownAPI, "SetHideCountdownNumbers", function(cooldown)
        if IsMiniAurasNamedFrame(cooldown) then
            TryStyleDuringInitialization(cooldown)
        end
    end)
    initializationHookInstalled = true
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.MiniAuras, self)
    self:Rebuild()
    InstallInitializationHook()
end
