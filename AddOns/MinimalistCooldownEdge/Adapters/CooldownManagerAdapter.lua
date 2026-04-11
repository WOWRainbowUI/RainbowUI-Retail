-- Adapters/CooldownManagerAdapter.lua – CooldownManager viewer cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("CooldownManagerAdapter")

local ipairs = ipairs
local strfind = string.find
local tinsert = table.insert

local CATEGORY = C.Categories
local VIEWER_TYPE = C.CooldownManagerViewers
local CM = C.Adapter.CooldownManager
-- Verified against Ayije_CDM/Core/Constants.lua viewer names.
local VIEWER_PATTERNS = C.Classifier.CooldownManagerViewerPatterns
local BLACKLIST_NAME_CONTAINS = C.Classifier.BlacklistNameContains

local Registry

local CMC_ADDON = "CooldownManagerCentered"
local CMC_BLACKLIST_PATTERN = "CooldownViewer"

local function IsAddonLoadedByName(addonName)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(addonName)
    end

    return IsAddOnLoaded and IsAddOnLoaded(addonName) or false
end

local function EnsureBlacklistEntry(entries, value)
    for i = 1, #entries do
        if entries[i] == value then
            return
        end
    end

    tinsert(entries, value)
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")

    if IsAddonLoadedByName(CMC_ADDON) then
        -- Defer Blizzard Cooldown Manager viewers to CooldownManagerCentered.
        EnsureBlacklistEntry(BLACKLIST_NAME_CONTAINS, CMC_BLACKLIST_PATTERN)
        return
    end

    Registry:RegisterAdapter(CATEGORY.CooldownManager, self)
end

-- Determine viewer type from a parent chain frame name
local function DetermineViewerType(name)
    if strfind(name, VIEWER_PATTERNS.Essential, 1, true) then return VIEWER_TYPE.Essential end
    if strfind(name, VIEWER_PATTERNS.Utility, 1, true) then return VIEWER_TYPE.Utility end
    if strfind(name, VIEWER_PATTERNS.BuffIcon, 1, true) then return VIEWER_TYPE.BuffIcon end
    return nil
end

-- Walk up parent chain to find the viewer type
local function ResolveViewerType(cooldown)
    local current = cooldown.GetParent and cooldown:GetParent()
    for _ = 1, CM.MaxAncestorDepth do
        if not current then break end
        local name = current.GetName and current:GetName() or ""
        local vt = DetermineViewerType(name)
        if vt then return vt end
        current = current.GetParent and current:GetParent()
    end

    -- Heuristic fallback: check structural markers on the immediate parent
    local parent = cooldown.GetParent and cooldown:GetParent()
    if parent then
        if parent.Applications and parent.Applications.Applications then
            return VIEWER_TYPE.BuffIcon
        end
        if parent.ChargeCount and parent.ChargeCount.Current then
            return VIEWER_TYPE.UtilityOrEssential
        end
    end
    return nil
end

-- Scan a viewer frame for cooldown children
local function ScanViewer(viewerFrame, viewerType)
    if not viewerFrame or MCE:IsForbidden(viewerFrame) then return end
    if not viewerFrame.GetChildren then return end

    local children = { viewerFrame:GetChildren() }
    for i = 1, #children do
        local child = children[i]
        if child and not MCE:IsForbidden(child) then
            local cd = child.cooldown or child.Cooldown
            if cd and not MCE:IsForbidden(cd) then
                Registry:Register(cd, CATEGORY.CooldownManager, viewerType)
            end
            -- Some viewers nest deeper
            if child.GetChildren then
                local grandchildren = { child:GetChildren() }
                for j = 1, #grandchildren do
                    local gc = grandchildren[j]
                    if gc and gc.IsObjectType and gc:IsObjectType("Cooldown") and not MCE:IsForbidden(gc) then
                        Registry:Register(gc, CATEGORY.CooldownManager, viewerType)
                    end
                end
            end
        end
    end
end

function Adapter:Rebuild()
    -- Scan known viewer globals
    for viewerName, viewerType in pairs({
        [VIEWER_PATTERNS.Essential] = VIEWER_TYPE.Essential,
        [VIEWER_PATTERNS.Utility] = VIEWER_TYPE.Utility,
        [VIEWER_PATTERNS.BuffIcon] = VIEWER_TYPE.BuffIcon,
    }) do
        local frame = _G[viewerName]
        if frame then ScanViewer(frame, viewerType) end
    end
end

function Adapter:TryClaim(cooldown)
    if not cooldown then return nil end
    local viewerType = ResolveViewerType(cooldown)
    if viewerType then
        return CATEGORY.CooldownManager, viewerType
    end
    return nil
end
