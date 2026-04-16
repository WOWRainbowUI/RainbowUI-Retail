-- Adapters/TellMeWhenAdapter.lua - TellMeWhen cooldown discovery

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("TellMeWhenAdapter")

local pairs, type = pairs, type
local strfind, strmatch = string.find, string.match

local CATEGORY = C.Categories
local CLASSIFIER_CONSTANTS = C.Classifier
local TMW = C.Adapter.TellMeWhen

local Registry

local function IsTellMeWhenIconFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string"
        and (strmatch(name, "^TellMeWhen_Group%d+_Icon%d+$") ~= nil
            or strmatch(name, "^TellMeWhen_GlobalGroup%d+_Icon%d+$") ~= nil)
end

local function IsTellMeWhenCooldownName(name)
    name = MCE:GetNonSecretString(name)
    return name ~= nil
        and strfind(name, CLASSIFIER_CONSTANTS.TellMeWhenNamePrefix, 1, true) == 1
        and strfind(name, TMW.CooldownNameFragment, 1, true) ~= nil
end

local function IsTellMeWhenCooldown(cooldown)
    if not MCE:IsTellMeWhenAvailable() or not cooldown or MCE:IsForbidden(cooldown) then
        return false
    end

    if cooldown.tmwMainCd or cooldown.tmwChargeCd then
        return true
    end

    if IsTellMeWhenCooldownName(MCE:GetFrameName(cooldown)) then
        return true
    end

    local owner = cooldown.GetParent and cooldown:GetParent() or nil
    if not owner or MCE:IsForbidden(owner) then
        return false
    end

    return IsTellMeWhenIconFrame(owner)
end

local function RegisterCooldown(cooldown)
    if IsTellMeWhenCooldown(cooldown) then
        Registry:Register(cooldown, CATEGORY.TellMeWhen)
    end
end

local function RegisterIconCooldowns(icon)
    if not icon or MCE:IsForbidden(icon) then return end

    local modules = icon.Modules
    local cooldownModule = modules and modules.IconModule_CooldownSweep or nil
    if cooldownModule then
        RegisterCooldown(cooldownModule.cooldown)
        RegisterCooldown(cooldownModule.cooldown2)
        return
    end

    RegisterCooldown(icon.cooldown or icon.Cooldown)
    RegisterCooldown(icon.chargeCooldown or icon.ChargeCooldown)
end

local function ScanDomainGroups(groups)
    if type(groups) ~= "table" then return end

    for _, group in pairs(groups) do
        if group and not MCE:IsForbidden(group) then
            local numIcons = group.numIcons or #group
            for iconIndex = 1, numIcons do
                RegisterIconCooldowns(group[iconIndex])
            end
        end
    end
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.TellMeWhen, self)
end

function Adapter:Rebuild()
    if not MCE:IsTellMeWhenAvailable() then return end

    local tellMeWhen = _G.TMW or _G.TellMeWhen
    if type(tellMeWhen) ~= "table" then return end

    for i = 1, #TMW.DomainKeys do
        ScanDomainGroups(tellMeWhen[TMW.DomainKeys[i]])
    end
end

function Adapter:TryClaim(cooldown)
    if IsTellMeWhenCooldown(cooldown) then
        return CATEGORY.TellMeWhen
    end
    return nil
end
