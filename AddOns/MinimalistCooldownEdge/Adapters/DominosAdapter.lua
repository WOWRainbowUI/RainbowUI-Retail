-- Adapters/DominosAdapter.lua – Dedicated Dominos action bar cooldown registration

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("DominosAdapter", "AceEvent-3.0")

local ipairs = ipairs
local strfind = string.find

local CATEGORY = C.Categories
local AB = C.Adapter.ActionBars
local DOM = C.Adapter.Dominos
local frameState = addon.frameState

local Registry

local function IsEnabled()
    return MCE:IsDominosAdapterEnabled()
end

local function GetFrameName(frame)
    return MCE:GetFrameName(frame)
end

local function IsDominosNamedFrame(frame)
    local name = GetFrameName(frame)
    return type(name) == "string" and strfind(name, C.Addon.DominosName, 1, true) == 1
end

local function IsDominosButton(button)
    if not button or MCE:IsForbidden(button) then
        return false
    end

    local current = button
    for _ = 1, DOM.MaxAncestorDepth + 1 do
        if not current or MCE:IsForbidden(current) then
            break
        end

        if IsDominosNamedFrame(current) then
            return true
        end

        current = current.GetParent and current:GetParent() or nil
    end

    return false
end

local function MarkSupportedCooldown(cooldown)
    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end

    state.allowBlacklisted = true
    state.dominosSupported = true
end

local function RegisterCooldown(cooldown)
    if not cooldown or MCE:IsForbidden(cooldown) then
        return
    end

    MarkSupportedCooldown(cooldown)
    Registry:Register(cooldown, CATEGORY.Actionbar)
end

local function RegisterButton(button)
    if not IsDominosButton(button) then
        return
    end

    for _, key in ipairs(AB.CooldownKeys) do
        RegisterCooldown(button[key])
    end

    for _, key in ipairs(AB.ChargeCooldownKeys) do
        RegisterCooldown(button[key])
    end
end

local function ScanPrefix(prefix, maxCount)
    if not _G[prefix .. "1"] then
        return
    end

    for i = 1, maxCount do
        local button = _G[prefix .. i]
        if button then
            RegisterButton(button)
        elseif i > 12 then
            break
        end
    end
end

function Adapter:InitializeDominos()
    return MCE:IsDominosAvailable()
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Actionbar, self)

    if not self:InitializeDominos() then
        self:RegisterEvent("ADDON_LOADED")
    end
end

function Adapter:OnDisable()
    self:UnregisterAllEvents()
end

function Adapter:ADDON_LOADED(_, addonName)
    if addonName ~= C.Addon.DominosName then
        return
    end

    if self:InitializeDominos() then
        self:UnregisterEvent("ADDON_LOADED")
    end
end

function Adapter:Rebuild()
    if not IsEnabled() or not self:InitializeDominos() then
        return
    end

    for _, prefix in ipairs(DOM.ButtonPrefixes) do
        ScanPrefix(prefix, AB.ThirdPartyMaxIndex)
    end

    for _, family in ipairs(AB.BlizzardFamilies) do
        ScanPrefix(family.prefix, family.count)
    end
end

function Adapter:TryClaim(cooldown)
    if not IsEnabled() or not self:InitializeDominos() or not cooldown or MCE:IsForbidden(cooldown) then
        return nil
    end

    local parent = cooldown.GetParent and cooldown:GetParent() or nil
    if not parent or not IsDominosButton(parent) then
        return nil
    end

    if MCE:IsLossOfControlCooldown(cooldown) then
        return nil
    end

    if parent.cooldown == cooldown
       or parent.Cooldown == cooldown
       or parent.chargeCooldown == cooldown
       or parent.ChargeCooldown == cooldown then
        RegisterButton(parent)
        return CATEGORY.Actionbar
    end

    return nil
end
