-- Adapters/NameplateAdapter.lua – Nameplate cooldown discovery via events

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("NameplateAdapter", "AceEvent-3.0")

local type, ipairs, pcall = type, ipairs, pcall
local strfind, strlower = string.find, string.lower

local CATEGORY = C.Categories
local MAX_DEPTH = C.Adapter.Nameplates.MaxAncestorDepth or 4
local NP_PATTERNS = C.Classifier.NameplatePatterns
local MINIAURAS_PREFIX = C.Classifier.MiniAurasNamePrefix

local Registry

local function IsObjectTypeSafe(frame, objectType)
    local isObjectType = MCE:SafeTableGet(frame, "IsObjectType")
    if type(isObjectType) ~= "function" then
        return false
    end

    local ok, result = pcall(isObjectType, frame, objectType)
    if not ok or MCE:IsSecretValue(result) or not addon.CanAccessAllValues(result) then
        return false
    end

    return result == true
end

local function GetParentSafe(frame)
    local getParent = MCE:SafeTableGet(frame, "GetParent")
    if type(getParent) ~= "function" then
        return nil
    end

    local ok, parent = pcall(getParent, frame)
    if not ok or not MCE:CanUseFrameAsTableKey(parent) then
        return nil
    end

    return parent
end

-- MiniAuras creates named cooldowns inside containers associated with nameplates.
-- Skip them here so MiniAurasAdapter retains ownership of both display backends.
local function IsMiniAurasFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string" and strfind(name, MINIAURAS_PREFIX, 1, true) == 1
end

function Adapter:OnEnable()
    if MCE:IsBetterBlizzPlatesAvailable() then return end

    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Nameplate, self)

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

function Adapter:OnDisable()
    self:UnregisterAllEvents()
end

-- Scan a nameplate subtree for Cooldown children (limited depth)
local function ScanChildren(frame, depth)
    if depth > MAX_DEPTH or not MCE:CanUseFrameAsTableKey(frame) then return end
    -- Bail out of any MiniAuras-managed subtree; MiniAurasAdapter owns these.
    if IsMiniAurasFrame(frame) then return end

    if IsObjectTypeSafe(frame, "Cooldown") then
        Registry:Register(frame, CATEGORY.Nameplate)
        return
    end

    local cd = MCE:SafeTableGet(frame, "cooldown")
    if not MCE:CanUseFrameAsTableKey(cd) then
        cd = MCE:SafeTableGet(frame, "Cooldown")
    end
    if MCE:CanUseFrameAsTableKey(cd) then
        Registry:Register(cd, CATEGORY.Nameplate)
    end

    local getChildren = MCE:SafeTableGet(frame, "GetChildren")
    if type(getChildren) ~= "function" then return end

    local children = { pcall(getChildren, frame) }
    if not children[1] then return end

    for i = 2, #children do
        ScanChildren(children[i], depth + 1)
    end
end

local function RegisterNameplate(np)
    if MCE:IsBetterBlizzPlatesAvailable() then return end
    if not MCE:CanUseFrameAsTableKey(np) then return end
    local unitFrame = MCE:SafeTableGet(np, "UnitFrame")
    if not MCE:CanUseFrameAsTableKey(unitFrame) then
        unitFrame = np
    end
    ScanChildren(unitFrame, 0)
end

function Adapter:NAME_PLATE_UNIT_ADDED(_, unit)
    if MCE:IsBetterBlizzPlatesAvailable() then return end
    local np = C_NamePlate.GetNamePlateForUnit(unit)
    if np then RegisterNameplate(np) end
end

function Adapter:NAME_PLATE_UNIT_REMOVED()
    -- Weak references in the registry handle cleanup
end

function Adapter:Rebuild()
    if MCE:IsBetterBlizzPlatesAvailable() then return end
    local nameplates = C_NamePlate.GetNamePlates()
    if nameplates then
        for _, np in ipairs(nameplates) do
            RegisterNameplate(np)
        end
    end
end

function Adapter:TryClaim(cooldown)
    if MCE:IsBetterBlizzPlatesAvailable() then return nil end
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end
    -- MiniAuras cooldowns carry the MiniAuras_ prefix; skip them entirely.
    if IsMiniAurasFrame(cooldown) then return nil end
    local current = GetParentSafe(cooldown)
    for _ = 1, MAX_DEPTH do
        if not current then break end
        if IsObjectTypeSafe(current, "NamePlate") then
            return CATEGORY.Nameplate
        end
        local unit = MCE:GetNonSecretString(MCE:SafeTableGet(current, "unitToken"))
            or MCE:GetNonSecretString(MCE:SafeTableGet(current, "unit"))
        if unit and strfind(strlower(unit), "nameplate", 1, true) then
            return CATEGORY.Nameplate
        end
        local name = MCE:GetFrameName(current)
        if name then
            local lowerName = strlower(name)
            for i = 1, #NP_PATTERNS do
                if strfind(lowerName, NP_PATTERNS[i], 1, true) then
                    return CATEGORY.Nameplate
                end
            end
        end
        current = GetParentSafe(current)
    end
    return nil
end
