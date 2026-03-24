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

local Registry

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.CompactPartyAura, self)

    self:RegisterEvent("GROUP_ROSTER_UPDATE", "Rebuild")
end

function Adapter:OnDisable()
    self:UnregisterAllEvents()
end

-- Scan a compact member frame for cooldown children in aura containers
local function ScanMemberFrame(memberFrame, groupType)
    if not memberFrame or MCE:IsForbidden(memberFrame) then return end

    local buffFrame = memberFrame.BuffFrame or memberFrame.buffFrame
    local debuffFrame = memberFrame.DebuffFrame or memberFrame.debuffFrame
    local auraDisp = memberFrame.DispelDebuffFrame or memberFrame.dispelDebuffFrame

    local containers = { buffFrame, debuffFrame, auraDisp }
    for _, container in ipairs(containers) do
        if container and not MCE:IsForbidden(container) and container.GetChildren then
            local children = { container:GetChildren() }
            for i = 1, #children do
                local child = children[i]
                if child and not MCE:IsForbidden(child) then
                    local cd = child.cooldown or child.Cooldown
                    if cd and not MCE:IsForbidden(cd) then
                        Registry:Register(cd, CATEGORY.CompactPartyAura, groupType)
                    end
                end
            end
        end
    end

    -- CenterDefensiveBuff (Midnight addition)
    local defensiveBuff = memberFrame.CenterDefensiveBuff
    if defensiveBuff and not MCE:IsForbidden(defensiveBuff) then
        local cd = defensiveBuff.cooldown or defensiveBuff.Cooldown
        if cd and not MCE:IsForbidden(cd) then
            Registry:Register(cd, CATEGORY.CompactPartyAura, groupType)
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

local function ResolveCompactPartyAuraType(cooldown)
    if not cooldown then return nil end
    local current = cooldown.GetParent and cooldown:GetParent()
    local sawAuraContext = false

    for _ = 1, GF.MaxAncestorDepth do
        if not current then break end
        local name = current.GetName and current:GetName() or ""

        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true) then
            sawAuraContext = true
        end

        -- CenterDefensiveBuff (unnamed: detect by parent relationship)
        if not sawAuraContext and current.GetParent then
            local grandparent = current:GetParent()
            if grandparent and grandparent.CenterDefensiveBuff == current then
                sawAuraContext = true
            end
        end

        if sawAuraContext then
            if strfind(name, "CompactPartyFrame", 1, true) then
                return GROUP_FRAME_TYPE.Party
            end
            if strfind(name, "CompactRaidFrame", 1, true) then
                return GROUP_FRAME_TYPE.Raid
            end
        end

        current = current.GetParent and current:GetParent()
    end
    return nil
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
