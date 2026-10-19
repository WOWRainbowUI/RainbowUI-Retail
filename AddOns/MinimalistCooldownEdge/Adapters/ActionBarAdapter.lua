-- Adapters/ActionBarAdapter.lua – Discovers Blizzard + third-party action bar cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("ActionBarAdapter")

local type, ipairs, tonumber = type, ipairs, tonumber
local strfind, strsub = string.find, string.sub

local CATEGORY = C.Categories
local ACTIONBAR_FRAME_TYPE = C.ActionBarFrameTypes
local AB = C.Adapter.ActionBars
local DOM = C.Adapter.Dominos
local BT4 = C.Adapter.Bartender4

local Registry

local function GetFrameName(frame)
    return MCE:GetFrameName(frame)
end

local function IsBT4ManagedButton(button)
    local name = GetFrameName(button)
    return type(name) == "string" and strfind(name, BT4.ButtonPrefix, 1, true) == 1
end

local function IsDominosManagedButton(button)
    if not button or MCE:IsForbidden(button) then
        return false
    end

    local current = button
    for _ = 1, DOM.MaxAncestorDepth + 1 do
        if not current or MCE:IsForbidden(current) then
            break
        end

        local name = GetFrameName(current)
        if type(name) == "string" and strfind(name, C.Addon.DominosName, 1, true) == 1 then
            return true
        end

        current = current.GetParent and current:GetParent() or nil
    end

    return false
end

local function GetKnownBlizzardButtonFamily(button)
    local name = GetFrameName(button)
    if type(name) ~= "string" then return nil end

    for _, family in ipairs(AB.BlizzardFamilies) do
        local prefix = family.prefix
        if strfind(name, prefix, 1, true) == 1 then
            local index = tonumber(strsub(name, #prefix + 1))
            if index ~= nil
               and index >= 1
               and index <= family.count
               and name == prefix .. index
               and _G[name] == button then
                return family
            end
            return nil
        end
    end

    return nil
end

local function IsStanceButtonStylingEnabled()
    local profile = MCE.db and MCE.db.profile
    local categories = profile and profile.categories
    local config = categories and categories[CATEGORY.Actionbar]
    if config and config.stanceButtonEnabled ~= nil then
        return config.stanceButtonEnabled == true
    end
    return C.Defaults.Actionbar.StanceButtonEnabled == true
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Actionbar, self)
end

local function RegisterButton(button, subtype)
    if not button or MCE:IsForbidden(button) or IsDominosManagedButton(button) or IsBT4ManagedButton(button) then return end
    if subtype == ACTIONBAR_FRAME_TYPE.StanceButton
       and not IsStanceButtonStylingEnabled() then
        return
    end

    for _, key in ipairs(AB.CooldownKeys) do
        local cd = button[key]
        if cd and not MCE:IsForbidden(cd) then
            Registry:Register(cd, CATEGORY.Actionbar, subtype)
        end
    end

    for _, key in ipairs(AB.ChargeCooldownKeys) do
        local cd = button[key]
        if cd and not MCE:IsForbidden(cd) then
            Registry:Register(cd, CATEGORY.Actionbar, subtype)
        end
    end
end

function Adapter:Rebuild()
    for _, family in ipairs(AB.BlizzardFamilies) do
        for i = 1, family.count do
            RegisterButton(_G[family.prefix .. i], family.subtype)
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

    local hasAction = type(parent.action) == "number"
    local isCooldownMember = parent.cooldown == cooldown or parent.Cooldown == cooldown
    local isChargeCooldownMember = parent.chargeCooldown == cooldown
        or parent.ChargeCooldown == cooldown
    if not hasAction and not isCooldownMember and not isChargeCooldownMember then
        return nil
    end

    if IsDominosManagedButton(parent) then return nil end
    if IsBT4ManagedButton(parent) then return nil end

    if MCE:IsLossOfControlCooldown(cooldown) then return nil end

    local family = GetKnownBlizzardButtonFamily(parent)
    local subtype = family and family.subtype or nil
    if subtype == ACTIONBAR_FRAME_TYPE.StanceButton
       and not IsStanceButtonStylingEnabled() then
        return nil
    end

    if hasAction then
        RegisterButton(parent, subtype)
        return CATEGORY.Actionbar, subtype
    end

    -- Special Blizzard buttons such as StanceButton1..10 own a standard
    -- cooldown member but do not expose the numeric action slot or secure
    -- action type used by ordinary action buttons. Restrict this fallback to
    -- the exact configured Blizzard globals so unrelated cooldown owners are
    -- not claimed as action bars.
    if (isCooldownMember or isChargeCooldownMember) and family then
        RegisterButton(parent, subtype)
        return CATEGORY.Actionbar, subtype
    end

    if isCooldownMember then
        if parent.GetAttribute and parent:GetAttribute("type") then
            RegisterButton(parent)
            return CATEGORY.Actionbar
        end
    end

    if isChargeCooldownMember then
        if parent.GetAttribute and parent:GetAttribute("type") then
            RegisterButton(parent)
            return CATEGORY.Actionbar
        end
    end

    return nil
end
