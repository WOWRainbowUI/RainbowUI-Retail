-- Adapters/ElvUIAdapter.lua – Dedicated ElvUI cooldown registration

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("ElvUIAdapter", "AceEvent-3.0")

local pairs, type = pairs, type
local strfind = string.find
local hooksecurefunc = hooksecurefunc

local CATEGORY = C.Categories
local frameState = addon.frameState

local Registry

local ELVUI_ADDON_NAME = "ElvUI"
local AURA_CONTAINER_TYPES = {
    auras = true,
    buffs = true,
    debuffs = true,
}
local ACTIONBAR_HOLDER_NAMES = {
    ElvUI_BarPet = true,
    ElvUI_StanceBar = true,
    ElvUI_ExtraActionBarHolder = true,
    ElvUI_ZoneAbilityHolder = true,
}

local modules = {
    E = nil,
    AB = nil,
    UF = nil,
    NP = nil,
}

local hooksInstalled = {
    actionStyle = false,
    actionCharge = false,
    unitAura = false,
    nameplateAura = false,
}

local function IsEnabled()
    return MCE:IsElvUIAdapterEnabled()
end

local function GetElvUIModule(name)
    local E = _G.ElvUI
    if type(E) ~= "table" or type(E.GetModule) ~= "function" then
        return nil
    end

    local ok, module = pcall(E.GetModule, E, name, true)
    if ok then
        return module
    end

    return nil
end

local function RefreshModules()
    modules.E = type(_G.ElvUI) == "table" and _G.ElvUI or nil
    modules.AB = GetElvUIModule("ActionBars")
    modules.UF = GetElvUIModule("UnitFrames")
    modules.NP = GetElvUIModule("NamePlates")
end

local function IsElvUILoaded()
    return modules.E ~= nil
end

local function IsCooldownFrame(cooldown)
    return cooldown
        and not MCE:IsForbidden(cooldown)
        and cooldown.IsObjectType
        and cooldown:IsObjectType("Cooldown")
end

local function MarkSupportedCooldown(cooldown)
    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end

    state.allowBlacklisted = true
    state.elvuiSupported = true
end

local function RegisterCooldown(cooldown, category)
    if not IsEnabled() or not IsCooldownFrame(cooldown) then
        return
    end

    MarkSupportedCooldown(cooldown)
    Registry:Register(cooldown, category)
end

local function GetFrameName(frame)
    if not frame or MCE:IsForbidden(frame) or not frame.GetName then
        return nil
    end

    local name = frame:GetName()
    if type(name) == "string" and name ~= "" then
        return name
    end

    return nil
end

local function IsElvUIFrameName(frame, prefix)
    local name = GetFrameName(frame)
    return type(name) == "string" and strfind(name, prefix, 1, true) == 1
end

local function IsElvUIActionButton(button)
    if not button or MCE:IsForbidden(button) then
        return false
    end

    local AB = modules.AB
    if AB and type(AB.handledbuttons) == "table" and AB.handledbuttons[button] then
        return true
    end

    if IsElvUIFrameName(button, "ElvUI_Bar") or IsElvUIFrameName(button, "ElvUI_StanceBarButton") then
        return true
    end

    if type(button.parentName) == "string" then
        if ACTIONBAR_HOLDER_NAMES[button.parentName] or strfind(button.parentName, "ElvUI_Bar", 1, true) == 1 then
            return true
        end
    end

    local holder = button.holder
    if holder and ACTIONBAR_HOLDER_NAMES[GetFrameName(holder) or ""] then
        return true
    end

    local current = button.GetParent and button:GetParent() or nil
    for _ = 1, 3 do
        if not current or MCE:IsForbidden(current) then
            break
        end

        local name = GetFrameName(current)
        if name and (ACTIONBAR_HOLDER_NAMES[name] or strfind(name, "ElvUI_Bar", 1, true) == 1) then
            return true
        end

        current = current.GetParent and current:GetParent() or nil
    end

    return false
end

local function RegisterActionButton(button)
    if not IsElvUIActionButton(button) then
        return
    end

    RegisterCooldown(button.cooldown or button.Cooldown, CATEGORY.Actionbar)
    RegisterCooldown(button.chargeCooldown or button.ChargeCooldown, CATEGORY.Actionbar)
end

local function ResolveActionButton(cooldown)
    local button = cooldown and cooldown.GetParent and cooldown:GetParent() or nil
    if not button or MCE:IsForbidden(button) then
        return nil
    end

    if button.cooldown == cooldown
       or button.Cooldown == cooldown
       or button.chargeCooldown == cooldown
       or button.ChargeCooldown == cooldown then
        if IsElvUIActionButton(button) then
            return button
        end
    end

    return nil
end

local function IsAuraContainer(container)
    if not container or MCE:IsForbidden(container) then
        return false
    end

    return AURA_CONTAINER_TYPES[container.type] == true
end

local function IsElvUIUnitFrame(frame)
    if not frame or MCE:IsForbidden(frame) or frame.isNamePlate then
        return false
    end

    if frame.unitframeType ~= nil then
        return true
    end

    return IsElvUIFrameName(frame, "ElvUF_")
end

local function IsElvUINameplate(frame)
    if not frame or MCE:IsForbidden(frame) then
        return false
    end

    if frame.isNamePlate then
        return true
    end

    return IsElvUIFrameName(frame, "ElvNP_")
end

local function ResolveAuraButtonAndContainer(cooldown)
    local button = cooldown and cooldown.GetParent and cooldown:GetParent() or nil
    if not button or MCE:IsForbidden(button) then
        return nil, nil
    end

    if button.cooldown ~= cooldown and button.Cooldown ~= cooldown then
        return nil, nil
    end

    local container = button.GetParent and button:GetParent() or nil
    if not IsAuraContainer(container) then
        return nil, nil
    end

    return button, container
end

local function ResolveUnitframeAuraCooldown(cooldown)
    local _, container = ResolveAuraButtonAndContainer(cooldown)
    if not container or container.isNamePlate then
        return nil
    end

    local owner = container.GetParent and container:GetParent() or nil
    if IsElvUIUnitFrame(owner) then
        return owner
    end

    return nil
end

local function ResolveNameplateAuraCooldown(cooldown)
    local _, container = ResolveAuraButtonAndContainer(cooldown)
    if not container then
        return nil
    end

    local owner = container.__owner or (container.GetParent and container:GetParent() or nil)
    if IsElvUINameplate(owner) then
        return owner
    end

    return nil
end

local function ScanAuraContainer(container, category)
    if not IsAuraContainer(container) or not container.GetChildren then
        return
    end

    local children = { container:GetChildren() }
    for i = 1, #children do
        local button = children[i]
        if button and not MCE:IsForbidden(button) then
            RegisterCooldown(button.Cooldown or button.cooldown, category)
        end
    end
end

local function RegisterUnitFrame(frame)
    if not IsElvUIUnitFrame(frame) then
        return
    end

    ScanAuraContainer(frame.Auras, CATEGORY.Unitframe)
    ScanAuraContainer(frame.Buffs, CATEGORY.Unitframe)
    ScanAuraContainer(frame.Debuffs, CATEGORY.Unitframe)
end

local function RegisterNameplate(frame)
    if not IsElvUINameplate(frame) then
        return
    end

    ScanAuraContainer(frame.Auras_ or frame.Auras, CATEGORY.Nameplate)
    ScanAuraContainer(frame.Buffs_ or frame.Buffs, CATEGORY.Nameplate)
    ScanAuraContainer(frame.Debuffs_ or frame.Debuffs, CATEGORY.Nameplate)
end

local function ScanHeaderFrames(header)
    if not header or MCE:IsForbidden(header) or not header.GetChildren then
        return
    end

    local children = { header:GetChildren() }
    for i = 1, #children do
        RegisterUnitFrame(children[i])
    end
end

local function InstallHooks()
    local AB = modules.AB
    if AB and not hooksInstalled.actionStyle and type(AB.StyleButton) == "function" then
        hooksecurefunc(AB, "StyleButton", function(_, button)
            RegisterActionButton(button)
        end)
        hooksInstalled.actionStyle = true
    end

    if AB and not hooksInstalled.actionCharge and type(AB.LAB_ChargeCreated) == "function" then
        hooksecurefunc(AB, "LAB_ChargeCreated", function(_, _, cooldown)
            local button = cooldown and cooldown.GetParent and cooldown:GetParent() or nil
            if IsElvUIActionButton(button) then
                RegisterCooldown(cooldown, CATEGORY.Actionbar)
            end
        end)
        hooksInstalled.actionCharge = true
    end

    local UF = modules.UF
    if UF and not hooksInstalled.unitAura and type(UF.Construct_AuraIcon) == "function" then
        hooksecurefunc(UF, "Construct_AuraIcon", function(_, button)
            RegisterCooldown(button and (button.Cooldown or button.cooldown), CATEGORY.Unitframe)
        end)
        hooksInstalled.unitAura = true
    end

    local NP = modules.NP
    if NP and not hooksInstalled.nameplateAura and type(NP.Construct_AuraIcon) == "function" then
        hooksecurefunc(NP, "Construct_AuraIcon", function(_, button)
            RegisterCooldown(button and (button.Cooldown or button.cooldown), CATEGORY.Nameplate)
        end)
        hooksInstalled.nameplateAura = true
    end
end

function Adapter:InitializeElvUI()
    RefreshModules()
    if not IsElvUILoaded() then
        return false
    end

    InstallHooks()
    return true
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Actionbar, self)
    Registry:RegisterAdapter(CATEGORY.Unitframe, self)
    Registry:RegisterAdapter(CATEGORY.Nameplate, self)

    if not self:InitializeElvUI() then
        self:RegisterEvent("ADDON_LOADED")
    end
end

function Adapter:OnDisable()
    self:UnregisterAllEvents()
end

function Adapter:ADDON_LOADED(_, addonName)
    if type(addonName) ~= "string" or strfind(addonName, ELVUI_ADDON_NAME, 1, true) ~= 1 then
        return
    end

    if self:InitializeElvUI() then
        self:UnregisterEvent("ADDON_LOADED")
    end
end

function Adapter:Rebuild()
    if not IsEnabled() or not self:InitializeElvUI() then
        return
    end

    local AB = modules.AB
    if AB and type(AB.handledbuttons) == "table" then
        for button in pairs(AB.handledbuttons) do
            RegisterActionButton(button)
        end
    end

    local UF = modules.UF
    if UF then
        if type(UF.units) == "table" then
            for _, frame in pairs(UF.units) do
                RegisterUnitFrame(frame)
            end
        end

        if type(UF.headers) == "table" then
            for _, header in pairs(UF.headers) do
                ScanHeaderFrames(header)

                local groups = header and header.groups
                if type(groups) == "table" then
                    for i = 1, #groups do
                        ScanHeaderFrames(groups[i])
                    end
                end
            end
        end
    end

    local NP = modules.NP
    if NP and type(NP.Plates) == "table" then
        for frame in pairs(NP.Plates) do
            RegisterNameplate(frame)
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not IsEnabled() or not self:InitializeElvUI() or not IsCooldownFrame(cooldown) then
        return nil
    end

    local actionButton = ResolveActionButton(cooldown)
    if actionButton then
        RegisterActionButton(actionButton)
        return CATEGORY.Actionbar
    end

    if ResolveUnitframeAuraCooldown(cooldown) then
        RegisterCooldown(cooldown, CATEGORY.Unitframe)
        return CATEGORY.Unitframe
    end

    if ResolveNameplateAuraCooldown(cooldown) then
        RegisterCooldown(cooldown, CATEGORY.Nameplate)
        return CATEGORY.Nameplate
    end

    return nil
end
