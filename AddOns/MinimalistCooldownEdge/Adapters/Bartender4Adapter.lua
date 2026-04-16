-- Adapters/Bartender4Adapter.lua – Dedicated Bartender4 action bar cooldown registration
--
-- Bartender4 uses LibActionButton-1.0 (LAB10), which calls SetCooldownFromDurationObject
-- on every button for each ACTIONBAR_UPDATE_COOLDOWN / SPELL_UPDATE_COOLDOWN event.
-- With up to 180 buttons (15 bars x 12), plus chargeCooldown frames per button,
-- the generic TryClaim path is too expensive.
--
-- This adapter pre-registers all known BT4 cooldown frames and uses a fast set-based
-- lookup to claim newly created ones (e.g. lazy chargeCooldown) in O(1).

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("Bartender4Adapter", "AceEvent-3.0")

local ipairs, type = ipairs, type
local strfind = string.find

local CATEGORY = C.Categories
local AB = C.Adapter.ActionBars
local BT4 = C.Adapter.Bartender4
local frameState = addon.frameState

local Registry

-- Set of known BT4 parent buttons for O(1) lookup in TryClaim
local bt4ButtonSet = {}

local function IsEnabled()
    return MCE:IsBartender4AdapterEnabled()
end

local function MarkSupportedCooldown(cooldown)
    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end
    state.allowBlacklisted = true
    state.bt4Supported = true
end

local function RegisterCooldown(cooldown)
    if not cooldown or MCE:IsForbidden(cooldown) then return end
    MarkSupportedCooldown(cooldown)
    Registry:Register(cooldown, CATEGORY.Actionbar)
end

local function RegisterButton(button)
    if not button or MCE:IsForbidden(button) then return end

    bt4ButtonSet[button] = true

    for _, key in ipairs(AB.CooldownKeys) do
        RegisterCooldown(button[key])
    end

    for _, key in ipairs(AB.ChargeCooldownKeys) do
        RegisterCooldown(button[key])
    end
end

function Adapter:InitializeBartender4()
    return MCE:IsBartender4Available()
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Actionbar, self)

    if not self:InitializeBartender4() then
        self:RegisterEvent("ADDON_LOADED")
    end
end

function Adapter:OnDisable()
    self:UnregisterAllEvents()
end

function Adapter:ADDON_LOADED(_, addonName)
    if addonName ~= BT4.AddonName then return end

    if self:InitializeBartender4() then
        self:UnregisterEvent("ADDON_LOADED")
    end
end

function Adapter:Rebuild()
    if not IsEnabled() or not self:InitializeBartender4() then return end

    for i = 1, BT4.MaxButtonIndex do
        local button = _G[BT4.ButtonPrefix .. i]
        if button then
            RegisterButton(button)
        elseif i > 12 then
            break
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not IsEnabled() or not self:InitializeBartender4() or not cooldown or MCE:IsForbidden(cooldown) then
        return nil
    end

    local parent = cooldown.GetParent and cooldown:GetParent() or nil
    
    if not parent or MCE:IsForbidden(parent) then return nil end
    
    if MCE:IsLossOfControlCooldown(cooldown) then
        return nil
    end

    -- Fast set lookup (populated after Rebuild)
    if bt4ButtonSet[parent] then
        RegisterButton(parent)
        return CATEGORY.Actionbar
    end

    -- Name-based fallback so TryClaim works before Rebuild populates the set.
    -- All BT4 buttons are named "BT4Button<id>".
    local name = MCE:GetFrameName(parent) or ""
    if type(name) == "string" and strfind(name, BT4.ButtonPrefix, 1, true) == 1 then
        RegisterButton(parent)
        return CATEGORY.Actionbar
    end

    return nil
end
