local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("ShinyAurasAdapter")

local CATEGORY = C.Categories
local SA = C.Adapter.ShinyAuras

local Registry

local function SA_IsExternalCooldownMode()
    local db = _G.ShinyAurasDB
    if type(db) ~= "table" then
        return true
    end

    return (db.combatCooldownMode or 0) == 1
end

local function IsShinyButton(frame)
    if not frame or MCE:IsForbidden(frame) then return false end

    if frame.__SA_AuraButton or frame.__SA_Owner then
        return true
    end

    local name = frame.GetName and frame:GetName() or nil
    if type(name) == "string" then
        if name:find("ShinyBuffButton", 1, true) == 1
            or name:find("ShinyDebuffButton", 1, true) == 1
            or name:find("ShinyWeaponButton", 1, true) == 1 then
            return true
        end
    end

    local parent = frame.GetParent and frame:GetParent() or nil
    if parent and parent.GetName and parent:GetName() == SA.RootFrameName then
        return true
    end

    return false
end

local function IsEnabled()
    return MCE:IsShinyAurasAdapterEnabled()
end

local function RegisterCooldown(frame)
    if not frame or MCE:IsForbidden(frame) then return end

    local parent = frame.GetParent and frame:GetParent() or nil
    if not IsShinyButton(frame) and not IsShinyButton(parent) then
        return
    end

    local cooldown = frame.cooldown or frame.Cooldown
    if cooldown and not MCE:IsForbidden(cooldown) then
        Registry:Register(cooldown, CATEGORY.Unitframe)
    end

    if frame.IsObjectType and frame:IsObjectType("Cooldown") then
        Registry:Register(frame, CATEGORY.Unitframe)
    end
end

local function ScanChildren(frame, depth)
    if not frame or depth > SA.MaxScanDepth or MCE:IsForbidden(frame) then return end

    if depth > 0 then
        RegisterCooldown(frame)
    end

    if frame.GetChildren then
        local children = { frame:GetChildren() }
        for i = 1, #children do
            ScanChildren(children[i], depth + 1)
        end
    end
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Unitframe, self)
end

function Adapter:Rebuild()
    if not IsEnabled() or not SA_IsExternalCooldownMode() then
        return
    end

    local root = _G[SA.RootFrameName]
    if root then
        ScanChildren(root, 0)
    end
end

function Adapter:TryClaim(cooldown)
    if not IsEnabled() or not cooldown or MCE:IsForbidden(cooldown) then
        return nil
    end

    if not SA_IsExternalCooldownMode() then
        return nil
    end

    local owner = cooldown.__SA_Owner
    if owner and IsShinyButton(owner) then
        return CATEGORY.Unitframe
    end

    local parent = cooldown.GetParent and cooldown:GetParent() or nil
    if IsShinyButton(parent) then
        return CATEGORY.Unitframe
    end

    local grand = parent and parent.GetParent and parent:GetParent() or nil
    if IsShinyButton(grand) then
        return CATEGORY.Unitframe
    end

    return nil
end
