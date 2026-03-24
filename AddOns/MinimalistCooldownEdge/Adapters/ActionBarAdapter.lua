-- Adapters/ActionBarAdapter.lua – Discovers Blizzard + third-party action bar cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("ActionBarAdapter")

local type, ipairs = type, ipairs

local CATEGORY = C.Categories
local AB = C.Adapter.ActionBars

local Registry

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Actionbar, self)
end

local function RegisterButton(button)
    if not button or MCE:IsForbidden(button) then return end

    for _, key in ipairs(AB.CooldownKeys) do
        local cd = button[key]
        if cd and not MCE:IsForbidden(cd) then
            Registry:Register(cd, CATEGORY.Actionbar)
        end
    end

    for _, key in ipairs(AB.ChargeCooldownKeys) do
        local cd = button[key]
        if cd and not MCE:IsForbidden(cd) then
            Registry:Register(cd, CATEGORY.Actionbar)
        end
    end
end

function Adapter:Rebuild()
    for _, family in ipairs(AB.BlizzardFamilies) do
        for i = 1, family.count do
            RegisterButton(_G[family.prefix .. i])
        end
    end

    for _, prefix in ipairs(AB.ThirdPartyPrefixes) do
        if _G[prefix .. "1"] then
            for i = 1, AB.ThirdPartyMaxIndex do
                local button = _G[prefix .. i]
                if button then
                    RegisterButton(button)
                elseif i > 12 then
                    break
                end
            end
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not cooldown then return nil end
    local parent = cooldown.GetParent and cooldown:GetParent()
    if not parent or MCE:IsForbidden(parent) then return nil end

    if type(parent.action) == "number" then
        RegisterButton(parent)
        return CATEGORY.Actionbar
    end

    for _, key in ipairs(AB.CooldownKeys) do
        if parent[key] == cooldown then
            if parent.GetAttribute and parent:GetAttribute("type") then
                RegisterButton(parent)
                return CATEGORY.Actionbar
            end
        end
    end

    for _, key in ipairs(AB.ChargeCooldownKeys) do
        if parent[key] == cooldown then
            if type(parent.action) == "number"
               or (parent.GetAttribute and parent:GetAttribute("type")) then
                RegisterButton(parent)
                return CATEGORY.Actionbar
            end
        end
    end

    return nil
end
