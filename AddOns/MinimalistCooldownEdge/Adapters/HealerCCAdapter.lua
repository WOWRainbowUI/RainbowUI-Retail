-- Adapters/HealerCCAdapter.lua - HealerCC cooldown discovery

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("HealerCCAdapter")

local pairs, type = pairs, type
local gsub, strmatch = string.gsub, string.match

local CATEGORY = C.Categories
local HCC = C.Adapter.HealerCC

local Registry
local trackedCooldowns = setmetatable({}, addon.weakMeta)

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.HealerCC, self)
end

local function IsHealerCCContainerName(name)
    return type(name) == "string"
        and (strmatch(name, HCC.FriendlyContainerPattern) ~= nil
            or strmatch(name, HCC.EnemyContainerPattern) ~= nil)
end

local function IsHealerCCCooldownName(name)
    return type(name) == "string"
        and (strmatch(name, HCC.FriendlyCooldownPattern) ~= nil
            or strmatch(name, HCC.EnemyCooldownPattern) ~= nil)
end

local function IsHealerCCAnchorName(name)
    return name == HCC.FriendlyAnchorName or name == HCC.EnemyAnchorName
end

local function GetHealerCCContainerAndAnchor(cooldown)
    local frame = cooldown
    for _ = 1, HCC.ContainerDepth do
        frame = frame and frame.GetParent and frame:GetParent() or nil
        if not frame then
            return nil, nil
        end
    end

    local containerName = MCE:GetFrameName(frame)
    if not IsHealerCCContainerName(containerName) then
        return nil, nil
    end

    local anchor = frame.GetParent and frame:GetParent() or nil
    local anchorName = MCE:GetFrameName(anchor)
    if not IsHealerCCAnchorName(anchorName) then
        return nil, nil
    end

    return frame, anchor
end

local function IsHealerCCCooldown(cooldown)
    if not MCE:IsHealerCCAvailable() or not cooldown or MCE:IsForbidden(cooldown) then
        return false
    end

    if not IsHealerCCCooldownName(MCE:GetFrameName(cooldown)) then
        return false
    end

    local container = GetHealerCCContainerAndAnchor(cooldown)
    return container ~= nil
end

local function RegisterCooldown(cooldown)
    if IsHealerCCCooldown(cooldown) then
        Registry:Register(cooldown, CATEGORY.HealerCC)
    end
end

local function RegisterAnchorCooldowns(anchor)
    if not anchor or MCE:IsForbidden(anchor) or not anchor.GetChildren then
        return
    end

    local children = { anchor:GetChildren() }
    for i = 1, #children do
        local container = children[i]
        if container and not MCE:IsForbidden(container) then
            local containerName = MCE:GetFrameName(container)
            if IsHealerCCContainerName(containerName) then
                local cooldownName = gsub(containerName, "Container$", "Cooldown", 1)
                RegisterCooldown(_G[cooldownName])
            end
        end
    end
end

function Adapter:Rebuild()
    if not MCE:IsHealerCCAvailable() then return end

    RegisterAnchorCooldowns(_G[HCC.FriendlyAnchorName])
    RegisterAnchorCooldowns(_G[HCC.EnemyAnchorName])

    for cooldown in pairs(trackedCooldowns) do
        if cooldown and not MCE:IsForbidden(cooldown) and IsHealerCCCooldown(cooldown) then
            Registry:Register(cooldown, CATEGORY.HealerCC)
        else
            trackedCooldowns[cooldown] = nil
        end
    end
end

function Adapter:TryClaim(cooldown)
    if IsHealerCCCooldown(cooldown) then
        trackedCooldowns[cooldown] = true
        return CATEGORY.HealerCC
    end
    return nil
end
