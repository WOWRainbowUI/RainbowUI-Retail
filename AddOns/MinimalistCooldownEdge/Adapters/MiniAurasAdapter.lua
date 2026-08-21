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
local RunNextFrame = addon.RunNextFrame
local GetParentSafe = addon.GetParentSafe
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
local trackedAuraButtons = setmetatable({}, addon.weakMeta)
local hookedDurationTexts = setmetatable({}, addon.weakMeta)
local initializationStyling = setmetatable({}, addon.weakMeta)
local initializationHookInstalled = false
local durationCooldownHookInstalled = false
local durationTextHookInstalled = false
local applicationCountHookInstalled = false
local customAuraButtonAPI
local InstallNativeDurationTextHooks

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
        frame = GetParentSafe(frame)
        if not frame then return nil, nil end
        if IsMiniAurasContainer(frame) then
            return frame, GetParentSafe(frame)
        end
    end
    return nil, nil
end

local function ResolveMiniAurasFrameTypeFromModule(moduleName)
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
    -- MiniAuras Nameplate Auras (Enemy - Bar 1/2) are deliberately unsupported.
    local moduleName = ReadMiniAurasModule(container)
        or ReadMiniAurasModule(anchor)
        or ReadMiniAurasModule(cooldown)
    if moduleName == "Nameplates" then return nil end

    local moduleFrameType = ResolveMiniAurasFrameTypeFromModule(moduleName)
    if moduleFrameType then
        return moduleFrameType
    end

    -- 2. Direct parent check for untagged containers.
    if anchor then
        local anchorName  = MCE:GetFrameName(anchor) or ""
        local anchorObjT  = anchor.GetObjectType and anchor:GetObjectType() or ""
        local anchorUnit  = GetFrameUnit(anchor)

        if IsNameplateContext(anchorName, anchorObjT, anchorUnit) then return nil end
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

        if IsNameplateContext(relativeName, relativeObjT, relativeUnit) then return nil end
        if IsUnitFrameContext(relativeTo) then
            return MINIAURAS_FRAME_TYPE.CC
        end
    end

    return MINIAURAS_FRAME_TYPE.Overlay
end

local function IsObjectTypeSafe(object, expectedType)
    local getObjectType = object and MCE:SafeTableGet(object, "GetObjectType") or nil
    if type(getObjectType) ~= "function" then return false end
    local ok, objectType = pcall(getObjectType, object)
    return ok and objectType == expectedType
end

local function MarkTrackedCooldown(cooldown, frameType, button)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end

    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end
    state.allowBlacklisted = true
    if MCE:CanUseFrameAsTableKey(button) then
        InstallNativeDurationTextHooks(button)
        trackedAuraButtons[button] = cooldown
    end

    trackedCooldowns[cooldown] = frameType or true
    if Registry then
        Registry:Register(cooldown, CATEGORY.MiniAuras, frameType)
    end
    return state
end

local function RefreshCapturedDurationText(cooldown)
    local styleEngine = MCE:GetModule("StyleEngine", true)
    if styleEngine and styleEngine:IsEnabled() then
        pcall(styleEngine.ApplyStyle, styleEngine, cooldown, CATEGORY.MiniAuras)
    end
end

local function EnsureDurationTextAlphaHook(cooldown, durationText)
    if hookedDurationTexts[durationText]
       or type(MCE:SafeTableGet(durationText, "SetAlpha")) ~= "function" then
        return
    end

    local hookOk = pcall(hooksecurefunc, durationText, "SetAlpha", function(region, alpha)
        local state = frameState[cooldown]
        if not state or state.miniAurasSuppressDurationTextAlpha then return end
        if type(alpha) == "number" and not MCE:IsSecretValue(alpha) then
            state.miniAurasRequestedDurationTextAlpha = alpha
        end
        if state.miniAurasNativeDurationTextActive ~= true
           or state.miniAurasDurationText ~= region then
            return
        end

        local desiredAlpha = state.miniAurasDurationTextHidden == true and 0 or 1
        local sameOk, isSame = pcall(function() return alpha == desiredAlpha end)
        if sameOk and isSame then return end

        state.miniAurasSuppressDurationTextAlpha = true
        pcall(region.SetAlpha, region, desiredAlpha)
        state.miniAurasSuppressDurationTextAlpha = nil
    end)
    if hookOk then
        hookedDurationTexts[durationText] = true
    end
end

-- Keyed by the cooldown rather than the button: a restricted AuraButton cannot be
-- used as a table key, but its cooldown always can, and the cooldown is the frame
-- every consumer of this state looks the region up from.
local function ApplyCapturedDurationText(cooldown, durationText)
    if not cooldown or not IsObjectTypeSafe(durationText, "FontString") then return end

    local state = frameState[cooldown]
    if not state or state.miniAurasDurationText == durationText then return end

    state.miniAurasDurationText = durationText
    state.miniAurasNativeDurationText = true
    state.miniAurasNativeDurationTextReady = true
    state.appliedTextColor = nil
    state.textRegions = nil
    state.forceTextRegionRefresh = true

    EnsureDurationTextAlphaHook(cooldown, durationText)
    RefreshCapturedDurationText(cooldown)
end

-- trackedAuraButtons is only populated for buttons usable as a table key, which a
-- restricted AuraButton is not. Fall back to the cooldown the button itself is
-- bound to, so the API hooks still land on the right frame state.
local function ResolveCooldownForButton(button)
    local cooldown = trackedAuraButtons[button]
    if cooldown then return cooldown end

    local getDurationCooldown = MCE:SafeTableGet(button, "GetDurationCooldown")
    if type(getDurationCooldown) ~= "function" then return nil end

    local ok, bound = pcall(getDurationCooldown, button)
    if ok and bound and frameState[bound] then return bound end
    return nil
end

local function CaptureNativeDurationText(button, durationText)
    ApplyCapturedDurationText(ResolveCooldownForButton(button), durationText)
end

-- MiniAuras registers its stack count through SetApplicationCount. Capturing it
-- is what lets StyleEngine reach the count at all; otherwise the region keeps
-- MiniAuras' own icon-derived size whatever the profile asks for.
local function ApplyCapturedStackText(cooldown, countRegion)
    if not cooldown or not IsObjectTypeSafe(countRegion, "FontString") then return end

    local state = frameState[cooldown]
    if not state or state.miniAurasStackText == countRegion then return end

    state.miniAurasStackText = countRegion
    RefreshCapturedDurationText(cooldown)
end

local function CaptureNativeStackText(button, countRegion)
    ApplyCapturedStackText(ResolveCooldownForButton(button), countRegion)
end

local function ReadAccessibleNumber(object, methodName)
    local method = object and MCE:SafeTableGet(object, methodName) or nil
    if type(method) ~= "function" then return nil end
    local ok, value = pcall(method, object)
    if not ok or type(value) ~= "number" or MCE:IsSecretValue(value) then return nil end
    return value
end

local function ReadAccessibleBoolean(object, methodName)
    local method = object and MCE:SafeTableGet(object, methodName) or nil
    if type(method) ~= "function" then return nil end
    local ok, value = pcall(method, object)
    if not ok or type(value) ~= "boolean" or MCE:IsSecretValue(value) then return nil end
    return value
end

-- MiniAuras is an optional dependency and can finish its ADDON_LOADED setup before
-- this adapter runs, so its text regions are recovered from the AuraButton's
-- anonymous overlay. Returns (durationText, stackText): MiniAuras tags the stack
-- count with MiniAurasFace, which tells the two apart without relying on region
-- order.
local function FindExistingButtonTextRegions(cooldown, button)
    -- Deliberately NOT CanUseFrameAsTableKey: an AuraButton is restricted once its
    -- initialization callback returns and fails that test, even though its children
    -- and regions stay readable through pcall. Requiring it left those buttons'
    -- duration text unreachable, so it could be neither resized nor hidden.
    if not button
       or type(MCE:SafeTableGet(button, "SetDurationText")) ~= "function" then
        return nil, nil
    end

    local getDurationCooldown = MCE:SafeTableGet(button, "GetDurationCooldown")
    if type(getDurationCooldown) == "function" then
        local ok, boundCooldown = pcall(getDurationCooldown, button)
        if ok and boundCooldown then
            local sameOk, isSame = pcall(function() return boundCooldown == cooldown end)
            -- Bail only on a conclusive mismatch: the bound cooldown can be a
            -- secret value, which makes the comparison throw rather than answer,
            -- and the button was reached through this cooldown's own parent.
            if sameOk and not isSame then return nil, nil end
        end
    end

    local getChildren = MCE:SafeTableGet(button, "GetChildren")
    if type(getChildren) ~= "function" then return nil, nil end
    local children = { pcall(getChildren, button) }
    if not children[1] then return nil, nil end

    local durationText, stackText, ambiguous
    for childIndex = 2, #children do
        local child = children[childIndex]
        if child and child ~= cooldown then
            local getRegions = MCE:SafeTableGet(child, "GetRegions")
            if type(getRegions) == "function" then
                local regions = { pcall(getRegions, child) }
                if regions[1] then
                    for regionIndex = 2, #regions do
                        local region = regions[regionIndex]
                        if IsObjectTypeSafe(region, "FontString") then
                            if MCE:SafeTableGet(region, "MiniAurasFace") ~= nil then
                                stackText = stackText or region
                            elseif durationText and durationText ~= region then
                                -- Two unmarked FontStrings: the duration text
                                -- cannot be told apart, so claim neither. The
                                -- stack count above stays valid regardless.
                                ambiguous = true
                            else
                                durationText = region
                            end
                        end
                    end
                end
            end
        end
    end

    if ambiguous then durationText = nil end
    return durationText, stackText
end

local function RecoverExistingButtonTextRegions(cooldown, button)
    local state = frameState[cooldown]
    if not state then return false end
    if state.miniAurasNativeDurationText == true and state.miniAurasStackText then
        return true
    end

    local durationText, stackText = FindExistingButtonTextRegions(cooldown, button)

    -- The stack count is styled from the cooldown's own frame state, so it is
    -- recovered even when the duration text stays ambiguous.
    if stackText then
        ApplyCapturedStackText(cooldown, stackText)
    end

    if state.miniAurasNativeDurationText ~= true and durationText then
        state.miniAurasRequestedDurationTextAlpha = ReadAccessibleNumber(durationText, "GetAlpha")
        state.miniAurasRequestedHideCountdownNumbers =
            ReadAccessibleBoolean(cooldown, "GetHideCountdownNumbers")
        ApplyCapturedDurationText(cooldown, durationText)
    end

    return state.miniAurasNativeDurationText == true
end

local function TrackNativeAuraButton(button, cooldown)
    if not MCE:IsMiniAurasAvailable()
       or not MCE:CanUseFrameAsTableKey(button)
       or not MCE:CanUseFrameAsTableKey(cooldown) then
        return
    end

    local frameType = ResolveMiniAurasFrameType(cooldown)
    if not frameType then return end
    MarkTrackedCooldown(cooldown, frameType, button)
    RecoverExistingButtonTextRegions(cooldown, button)
end

-- =========================================================================
-- ADAPTER API
-- =========================================================================

-- Both MiniAuras display backends expose stable, globally named Cooldown
-- frames. Targeted lookup registers buttons that MiniAuras created before
-- MiniCE's lifetime hooks were installed without using EnumerateFrames().
--
-- MiniAuras keeps thousands of pooled cooldowns alive at once, so the scan is
-- a resumable job with two limits:
--
--   * Each pass claims a bounded number of unknown frames and continues on the
--     next frame instead of walking the whole name space in one script call.
--   * A rebuild resumes just past the highest ID that existed on the previous
--     scan. MiniAuras numbers its pools upwards, so only that tail can hold
--     new frames; re-probing the thousands of names below it found nothing but
--     cooldowns MiniCE already tracks.
--
-- Anything the tail scan still misses is picked up by MiniAuras' own API hooks
-- the moment the pooled cooldown is handed an aura, so no display is lost.
local COOLDOWN_PREFIXES = { LEGACY_COOLDOWN_PREFIX, AURA_COOLDOWN_PREFIX }
local discoveryResumeID = { 0, 0 }
local discoveryPrefixIndex, discoveryFrameID, discoveryMisses = 1, 1, 0
local discoveryScheduled = false
local RunDiscoveryPass

local function ScheduleDiscoveryPass()
    if discoveryScheduled then return end
    discoveryScheduled = true

    RunNextFrame(function()
        discoveryScheduled = false
        if MCE:IsMiniAurasAvailable() then
            RunDiscoveryPass(true)
        end
    end)
end

local function ResumeDiscoveryAt(prefixIndex)
    discoveryPrefixIndex = prefixIndex
    discoveryFrameID = (discoveryResumeID[prefixIndex] or 0) + 1
    discoveryMisses = 0
end

local function ClaimNamedCooldown(cooldown, queueStyle)
    local frameType = ResolveMiniAurasFrameType(cooldown)
    if not frameType then return end

    local button = GetParentSafe(cooldown)
    MarkTrackedCooldown(cooldown, frameType, button)
    RecoverExistingButtonTextRegions(cooldown, button)

    -- Deferred passes run after Styler queued its restyle sweep, so a late
    -- discovery has to queue itself.
    if queueStyle then
        local batchProcessor = MCE:GetModule("BatchProcessor", true)
        if batchProcessor then
            batchProcessor:QueueUpdate(cooldown)
        end
    end
end

RunDiscoveryPass = function(deferred)
    local claimBudget = ADAPTER_CONSTANTS.DiscoveryClaimsPerPass
    local probeBudget = ADAPTER_CONSTANTS.DiscoveryProbesPerPass

    while discoveryPrefixIndex <= #COOLDOWN_PREFIXES do
        local prefix = COOLDOWN_PREFIXES[discoveryPrefixIndex]

        while discoveryFrameID <= ADAPTER_CONSTANTS.MaxNamedFrameID do
            if probeBudget <= 0 or claimBudget <= 0 then
                ScheduleDiscoveryPass()
                return
            end
            probeBudget = probeBudget - 1

            local frameID = discoveryFrameID
            discoveryFrameID = frameID + 1

            local cooldown = MCE:SafeTableGet(_G, prefix .. frameID)
            if cooldown then
                discoveryMisses = 0
                -- The cursor tracks the last ID that existed; the next rebuild
                -- resumes from there instead of re-walking the pool below it.
                if frameID > discoveryResumeID[discoveryPrefixIndex] then
                    discoveryResumeID[discoveryPrefixIndex] = frameID
                end
                if MCE:CanUseFrameAsTableKey(cooldown) and not trackedCooldowns[cooldown] then
                    claimBudget = claimBudget - 1
                    ClaimNamedCooldown(cooldown, deferred)
                end
            else
                discoveryMisses = discoveryMisses + 1
                if discoveryMisses >= ADAPTER_CONSTANTS.TrailingNamedFrameMissLimit then
                    break
                end
            end
        end

        ResumeDiscoveryAt(discoveryPrefixIndex + 1)
    end
end

function Adapter:Rebuild()
    for cooldown, claimedFrameType in pairs(trackedCooldowns) do
        if cooldown and not MCE:IsForbidden(cooldown) then
            -- The type recorded at claim time stays valid while the cooldown
            -- lives in its container; MiniAuras' creation and duration hooks
            -- re-resolve it whenever the frame is handed to another aura.
            local frameType = claimedFrameType ~= true and claimedFrameType
                or ResolveMiniAurasFrameType(cooldown)
            if frameType then
                trackedCooldowns[cooldown] = frameType
                Registry:Register(cooldown, CATEGORY.MiniAuras, frameType)

                -- The initialization hook claims a cooldown at the moment
                -- MiniAuras creates it, which is before the duration text and
                -- stack count exist. That claim also takes the cooldown out of
                -- the discovery scan's reach, so without retrying here its text
                -- regions would never be captured for the rest of the session.
                local state = frameState[cooldown]
                if state and (state.miniAurasDurationText == nil
                              or state.miniAurasStackText == nil) then
                    RecoverExistingButtonTextRegions(cooldown, GetParentSafe(cooldown))
                end
            else
                trackedCooldowns[cooldown] = nil
            end
        end
    end

    if not MCE:IsMiniAurasAvailable() then return end

    ResumeDiscoveryAt(1)
    RunDiscoveryPass(false)
end

function Adapter:TryClaim(cooldown)
    if not MCE:IsMiniAurasAvailable() then return nil end

    local frameType = ResolveMiniAurasFrameType(cooldown)
    if frameType then
        local button = GetParentSafe(cooldown)
        MarkTrackedCooldown(cooldown, frameType, button)
        RecoverExistingButtonTextRegions(cooldown, button)
        return CATEGORY.MiniAuras, frameType
    end
    return nil
end

-- AuraContainer buttons can become forbidden as soon as their initialization
-- callback returns. Claim and style newly created MiniAuras cooldowns from a
-- setter MiniAuras calls inside that safe callback, while the button is still
-- externally inspectable.
local function TryStyleDuringInitialization(cooldown, requestedHide)
    if initializationStyling[cooldown] or not MCE:IsMiniAurasAvailable() then return end
    if not MCE:CanUseFrameAsTableKey(cooldown) then return end
    local existingState = frameState[cooldown]
    if existingState and existingState.suppressHideNums then return end

    local frameType = ResolveMiniAurasFrameType(cooldown)
    if not frameType then return end

    local button = GetParentSafe(cooldown)
    local state = MarkTrackedCooldown(cooldown, frameType, button)
    if state and not state.suppressHideNums
       and type(requestedHide) == "boolean"
       and not MCE:IsSecretValue(requestedHide) then
        state.miniAurasRequestedHideCountdownNumbers = requestedHide
    end

    local styleEngine = MCE:GetModule("StyleEngine", true)
    if not (styleEngine and styleEngine:IsEnabled()) then return end

    initializationStyling[cooldown] = true
    pcall(styleEngine.ApplyStyle, styleEngine, cooldown, CATEGORY.MiniAuras)
    initializationStyling[cooldown] = nil
end

local function GetCustomAuraButtonAPI(button)
    if customAuraButtonAPI then return customAuraButtonAPI end
    if not MCE:CanUseFrameAsTableKey(button) then return nil end

    local metaOk, meta = pcall(getmetatable, button)
    if not metaOk or type(meta) ~= "table" then return nil end
    local api = MCE:SafeTableGet(meta, "__index")
    if type(api) ~= "table"
       or type(MCE:SafeTableGet(api, "SetDurationCooldown")) ~= "function"
       or type(MCE:SafeTableGet(api, "SetDurationText")) ~= "function" then
        return nil
    end

    customAuraButtonAPI = api
    return customAuraButtonAPI
end

InstallNativeDurationTextHooks = function(button)
    if durationCooldownHookInstalled and durationTextHookInstalled
       and applicationCountHookInstalled then
        return
    end

    local api = GetCustomAuraButtonAPI(button)
    if not api then return end

    if not durationCooldownHookInstalled
       and type(MCE:SafeTableGet(api, "SetDurationCooldown")) == "function" then
        local hookOk = pcall(hooksecurefunc, api, "SetDurationCooldown", function(button, cooldown)
            TrackNativeAuraButton(button, cooldown)
        end)
        durationCooldownHookInstalled = hookOk
    end

    if not durationTextHookInstalled
       and type(MCE:SafeTableGet(api, "SetDurationText")) == "function" then
        local hookOk = pcall(hooksecurefunc, api, "SetDurationText", function(button, durationText)
            CaptureNativeDurationText(button, durationText)
        end)
        durationTextHookInstalled = hookOk
    end

    if not applicationCountHookInstalled
       and type(MCE:SafeTableGet(api, "SetApplicationCount")) == "function" then
        local hookOk = pcall(hooksecurefunc, api, "SetApplicationCount", function(button, countRegion)
            CaptureNativeStackText(button, countRegion)
        end)
        applicationCountHookInstalled = hookOk
    end
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

    hooksecurefunc(cooldownAPI, "SetHideCountdownNumbers", function(cooldown, hide)
        -- This hook sits on the shared Cooldown API, so it runs for every
        -- cooldown in the UI. IsMiniAurasNamedFrame costs several pcalls through
        -- GetFrameName, while the cached availability flag is a plain table
        -- lookup: keep the walk off the path entirely without MiniAuras loaded.
        if not MCE:IsMiniAurasAvailable() then return end
        if IsMiniAurasNamedFrame(cooldown) then
            TryStyleDuringInitialization(cooldown, hide)
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

-- A normal Cooldown hook safely discovers MiniAuras initialization. Rebuild
-- recovers older named buttons; either path installs AuraButton hooks from the
-- genuine provider-created button without instantiating Blizzard's template.
InstallInitializationHook()
