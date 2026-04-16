-- Adapters/NameplateAdapter.lua – Nameplate cooldown discovery via events

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("NameplateAdapter", "AceEvent-3.0")

local type, ipairs, pairs = type, ipairs, pairs
local strfind, strlower = string.find, string.lower

local CATEGORY = C.Categories
local MAX_DEPTH = C.Adapter.Nameplates.MaxAncestorDepth
local NP_PATTERNS = C.Classifier.NameplatePatterns
local MINICC_PREFIX = C.Classifier.MiniCCNamePrefix

local Registry

-- MiniCC creates cooldowns at a fixed depth inside containers that are parented
-- to nameplates.  Skip them here so MiniCCAdapter retains ownership.
local function IsMiniCCFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string" and strfind(name, MINICC_PREFIX, 1, true) == 1
end

function Adapter:OnEnable()
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
    if not frame or depth > 4 or MCE:IsForbidden(frame) then return end
    -- Bail out of any MiniCC-managed subtree; MiniCCAdapter owns these.
    if IsMiniCCFrame(frame) then return end

    if frame.IsObjectType and frame:IsObjectType("Cooldown") then
        Registry:Register(frame, CATEGORY.Nameplate)
        return
    end

    local cd = frame.cooldown or frame.Cooldown
    if cd and not MCE:IsForbidden(cd) then
        Registry:Register(cd, CATEGORY.Nameplate)
    end

    if frame.GetChildren then
        local children = { frame:GetChildren() }
        for i = 1, #children do
            ScanChildren(children[i], depth + 1)
        end
    end
end

local function RegisterNameplate(np)
    if not np then return end
    local unitFrame = np.UnitFrame or np
    ScanChildren(unitFrame, 0)
end

function Adapter:NAME_PLATE_UNIT_ADDED(_, unit)
    local np = C_NamePlate.GetNamePlateForUnit(unit)
    if np then RegisterNameplate(np) end
end

function Adapter:NAME_PLATE_UNIT_REMOVED()
    -- Weak references in the registry handle cleanup
end

function Adapter:Rebuild()
    local nameplates = C_NamePlate.GetNamePlates()
    if nameplates then
        for _, np in ipairs(nameplates) do
            RegisterNameplate(np)
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not cooldown then return nil end
    -- MiniCC cooldowns carry the MiniCC_ prefix; skip them entirely.
    if IsMiniCCFrame(cooldown) then return nil end
    local current = cooldown.GetParent and cooldown:GetParent()
    for _ = 1, MAX_DEPTH do
        if not current then break end
        if current.GetObjectType and current:GetObjectType() == "NamePlate" then
            return CATEGORY.Nameplate
        end
        local unit = current.unitToken or current.unit
        if type(unit) == "string" and strfind(strlower(unit), "nameplate", 1, true) then
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
        current = current.GetParent and current:GetParent()
    end
    return nil
end
