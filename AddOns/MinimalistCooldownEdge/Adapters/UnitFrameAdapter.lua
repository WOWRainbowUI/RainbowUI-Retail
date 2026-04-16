-- Adapters/UnitFrameAdapter.lua – Blizzard + third-party unit frame cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("UnitFrameAdapter")

local ipairs, type = ipairs, type
local strfind = string.find

local CATEGORY = C.Categories
local UF = C.Adapter.UnitFrames
local MINICC_PREFIX = C.Classifier.MiniCCNamePrefix

-- MiniCC portrait containers are parented directly to unit frames.
-- Skip them here so MiniCCAdapter retains ownership.
local function IsMiniCCFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string" and strfind(name, MINICC_PREFIX, 1, true) == 1
end

local Registry
local GroupFrameAdapter
local FALLBACK_UNIT_TOKENS = {
    player = true,
    target = true,
    focus = true,
    pet = true,
}

local function IsCompactGroupFrameName(name)
    name = MCE:GetNonSecretString(name)
    if not name then
        return false
    end

    return strfind(name, "CompactPartyFrame", 1, true)
        or strfind(name, "CompactRaidFrame", 1, true)
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    GroupFrameAdapter = MCE:GetModule("GroupFrameAdapter")
    Registry:RegisterAdapter(CATEGORY.Unitframe, self)
end

-- Scan an aura container for cooldown children
local function ScanAuraContainer(container)
    if not container or MCE:IsForbidden(container) then return end

    if container.GetChildren then
        local children = { container:GetChildren() }
        for i = 1, #children do
            local child = children[i]
            if child and not MCE:IsForbidden(child) then
                local cd = child.cooldown or child.Cooldown
                if cd and not MCE:IsForbidden(cd) then
                    Registry:Register(cd, CATEGORY.Unitframe)
                end
                if child.IsObjectType and child:IsObjectType("Cooldown") and not MCE:IsForbidden(child) then
                    Registry:Register(child, CATEGORY.Unitframe)
                end
            end
        end
    end
end

local function ScanUnitFrame(frame)
    if not frame or MCE:IsForbidden(frame) then return end

    local buffFrame = frame.BuffFrame or frame.buffFrame
    if buffFrame then ScanAuraContainer(buffFrame) end

    local debuffFrame = frame.DebuffFrame or frame.debuffFrame
    if debuffFrame then ScanAuraContainer(debuffFrame) end

    local auraFrame = frame.AuraFrame or frame.auraFrame
    if auraFrame then ScanAuraContainer(auraFrame) end
end

function Adapter:Rebuild()
    for _, rootName in ipairs(UF.BlizzardRoots) do
        local root = _G[rootName]
        if root then ScanUnitFrame(root) end
    end

    for _, pattern in ipairs(UF.ThirdPartyPatterns) do
        local root = _G[pattern]
        if root and not MCE:IsForbidden(root) then
            ScanUnitFrame(root)
        end
    end
end

local function ExtractUnitToken(unit)
    if type(unit) == "string" then
        return unit ~= "" and unit or nil
    end
    if type(unit) ~= "table" then
        return nil
    end

    local token = unit.unitid or unit.unitID or unit.unitToken
        or unit.displayedUnit or unit.unit
    if type(token) == "string" and token ~= "" then
        return token
    end

    return nil
end

function Adapter:TryClaim(cooldown)
    if not cooldown then return nil end
    -- MiniCC cooldowns carry the MiniCC_ prefix; skip them entirely.
    if IsMiniCCFrame(cooldown) then return nil end
    local compactGroupType = GroupFrameAdapter and GroupFrameAdapter.ResolveCompactPartyAuraType
        and GroupFrameAdapter:ResolveCompactPartyAuraType(cooldown) or nil
    local current = cooldown.GetParent and cooldown:GetParent()
    for _ = 1, UF.MaxAncestorDepth do
        if not current then break end
        local name = MCE:GetFrameName(current) or ""
        local unitToken = ExtractUnitToken(current.unit)
            or ExtractUnitToken(current.unitToken)
            or ExtractUnitToken(current.displayedUnit)

        if IsCompactGroupFrameName(name) or compactGroupType then
            return nil
        end

        for _, rootName in ipairs(UF.BlizzardRoots) do
            if name == rootName then return CATEGORY.Unitframe end
        end

        for _, pattern in ipairs(UF.ThirdPartyPatterns) do
            if strfind(name, pattern, 1, true) then return CATEGORY.Unitframe end
        end

        if unitToken and FALLBACK_UNIT_TOKENS[unitToken] then
            if name ~= "" and (strfind(name, "Frame", 1, true)
                or strfind(name, "UF", 1, true)) then
                return CATEGORY.Unitframe
            end
        end

        current = current.GetParent and current:GetParent()
    end
    return nil
end
