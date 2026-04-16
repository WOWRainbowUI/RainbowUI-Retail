-- Adapters/GroupFrameAdapter.lua – Compact party/raid aura cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("GroupFrameAdapter", "AceEvent-3.0")

local type, ipairs = type, ipairs
local strfind = string.find
local tostring = tostring

local CATEGORY = C.Categories
local GROUP_FRAME_TYPE = C.GroupFrameTypes
local GF = C.Adapter.GroupFrames
local COOLDOWN_MEMBER_KEYS = C.Styler.CooldownMemberKeys

local Registry

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.CompactPartyAura, self)

    self:RegisterEvent("GROUP_ROSTER_UPDATE", "Rebuild")
end

function Adapter:OnDisable()
    self:UnregisterAllEvents()
end

local function ExtractUnitToken(unit)
    if type(unit) == "string" then
        return unit ~= "" and unit or nil
    end
    if type(unit) ~= "table" then
        return nil
    end

    local token = unit.unitid or unit.unitID or unit.unitToken
        or unit.displayedUnit or unit.memberUnit or unit.unit
    if type(token) == "string" and token ~= "" then
        return token
    end

    return nil
end

local function GetCompactGroupFrameTypeFromUnit(unitToken)
    if type(unitToken) ~= "string" then
        return nil
    end

    if strfind(unitToken, "raid", 1, true) == 1 then
        return GROUP_FRAME_TYPE.Raid
    end
    if strfind(unitToken, "party", 1, true) == 1 then
        return GROUP_FRAME_TYPE.Party
    end

    return nil
end

local function GetCompactGroupFrameType(frame)
    if not frame or MCE:IsForbidden(frame) then
        return nil
    end

    local name = MCE:GetFrameName(frame) or ""
    if strfind(name, "CompactPartyFrame", 1, true) then
        return GROUP_FRAME_TYPE.Party
    end
    if strfind(name, "CompactRaidFrame", 1, true) then
        return GROUP_FRAME_TYPE.Raid
    end

    return GetCompactGroupFrameTypeFromUnit(
        ExtractUnitToken(frame.unit)
            or ExtractUnitToken(frame.unitToken)
            or ExtractUnitToken(frame.displayedUnit)
            or ExtractUnitToken(frame.memberUnit))
end

local function IsKnownCooldownMember(frame, cooldown)
    if not frame or MCE:IsForbidden(frame) or not cooldown then
        return false
    end

    for i = 1, #COOLDOWN_MEMBER_KEYS do
        if frame[COOLDOWN_MEMBER_KEYS[i]] == cooldown then
            return true
        end
    end

    return false
end

local function GetCompactPartyAuraTypeFromMember(parent, child)
    if not parent or MCE:IsForbidden(parent) or not child then
        return nil
    end

    local auraFrame = parent.CenterDefensiveBuff
    if not auraFrame or MCE:IsForbidden(auraFrame) then
        return nil
    end

    if auraFrame == child or IsKnownCooldownMember(auraFrame, child) then
        return GetCompactGroupFrameType(parent)
    end

    return nil
end

local function ResolveCompactPartyAuraType(cooldown)
    if not cooldown then return nil end
    local child = cooldown
    local current = cooldown.GetParent and cooldown:GetParent() or nil
    local sawAuraContext = false

    for _ = 1, GF.MaxAncestorDepth do
        if not current then break end
        if MCE:IsForbidden(current) then break end

        local name = MCE:GetFrameName(current) or ""

        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true) then
            sawAuraContext = true

            if strfind(name, "CompactPartyFrame", 1, true) then
                return GROUP_FRAME_TYPE.Party
            end
            if strfind(name, "CompactRaidFrame", 1, true) then
                return GROUP_FRAME_TYPE.Raid
            end
        end

        if sawAuraContext and strfind(name, "Compact", 1, true) then
            local unitType = GetCompactGroupFrameType(current)
            if unitType then
                return unitType
            end
        end

        local unitType = GetCompactPartyAuraTypeFromMember(current, child)
        if unitType then
            return unitType
        end

        child = current
        current = current.GetParent and current:GetParent() or nil
    end

    return nil
end

local function RegisterCooldown(cd, groupType)
    if not cd or MCE:IsForbidden(cd) then return end

    local resolvedType = groupType or ResolveCompactPartyAuraType(cd)
    if resolvedType then
        Registry:Register(cd, CATEGORY.CompactPartyAura, resolvedType)
    end
end

local function ScanAuraSubtree(node, groupType, depth)
    if not node or depth > GF.MaxAncestorDepth or MCE:IsForbidden(node) then
        return
    end

    local resolvedType = groupType or GetCompactGroupFrameType(node)

    local cd = node.cooldown or node.Cooldown
    if cd and not MCE:IsForbidden(cd) then
        RegisterCooldown(cd, resolvedType)
    end

    if node.IsObjectType and node:IsObjectType("Cooldown") then
        RegisterCooldown(node, resolvedType)
    end

    if node.GetChildren then
        local children = { node:GetChildren() }
        for i = 1, #children do
            ScanAuraSubtree(children[i], resolvedType, depth + 1)
        end
    end
end

-- Scan a compact member frame for cooldown children in aura containers
local function ScanMemberFrame(memberFrame, groupType)
    if not memberFrame or MCE:IsForbidden(memberFrame) then return end
    groupType = groupType or GetCompactGroupFrameType(memberFrame)

    local buffFrame = memberFrame.BuffFrame or memberFrame.buffFrame
    local debuffFrame = memberFrame.DebuffFrame or memberFrame.debuffFrame
    local auraDisp = memberFrame.DispelDebuffFrame or memberFrame.dispelDebuffFrame
    local defensiveBuff = memberFrame.CenterDefensiveBuff

    local containers = { buffFrame, debuffFrame, auraDisp, defensiveBuff }
    for _, container in ipairs(containers) do
        if container and not MCE:IsForbidden(container) then
            ScanAuraSubtree(container, groupType, 0)
        end
    end
end

function Adapter:Rebuild()
    -- Party members
    for i = 1, GF.PartyMemberCount do
        local name = GF.PartyMemberPrefix .. tostring(i)
        local frame = _G[name]
        if frame then
            ScanMemberFrame(frame, GROUP_FRAME_TYPE.Party)
        end
    end

    -- Raid frames
    for i = 1, GF.RaidFrameMaxCount do
        local name = GF.RaidFramePrefix .. tostring(i)
        local frame = _G[name]
        if frame then
            ScanMemberFrame(frame, GROUP_FRAME_TYPE.Raid)
        end
    end
end

function Adapter:ResolveCompactPartyAuraType(cooldown)
    return ResolveCompactPartyAuraType(cooldown)
end

function Adapter:TryClaim(cooldown)
    local groupType = ResolveCompactPartyAuraType(cooldown)
    if groupType then
        return CATEGORY.CompactPartyAura, groupType
    end
    return nil
end
