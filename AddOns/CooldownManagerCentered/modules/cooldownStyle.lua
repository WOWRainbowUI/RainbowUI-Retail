local addonName, ns = ...

local MiscPanel = ns.MiscPanel

local CooldownStyle = ns.CooldownStyle or {}
ns.CooldownStyle = CooldownStyle
local MENU_TITLE = "|cff008945C|r|cff1e9a4eo|r|cff3faa4fol|r|cff5fb64ado|r|cff7ac243wn|r |cff8ccd00Manager Centered|r"

local DEFAULT_ALWAYS_SHOW_COOLDOWN_EDGE = false
local DEFAULT_SHOW_AURAS = true

local function GetCooldownFrames()
    local frames = {}

    local essentialViewer = _G["EssentialCooldownViewer"]
    if essentialViewer then
        for _, child in ipairs({ essentialViewer:GetChildren() }) do
            if child.Cooldown then
                table.insert(frames, child)
            end
        end
    end

    local utilityViewer = _G["UtilityCooldownViewer"]
    if utilityViewer then
        for _, child in ipairs({ utilityViewer:GetChildren() }) do
            if child.Cooldown then
                table.insert(frames, child)
            end
        end
    end

    return frames
end

local function GetBuffIconFrames()
    local frames = {}

    local buffViewer = _G["BuffIconCooldownViewer"]
    if buffViewer then
        for _, child in ipairs({ buffViewer:GetChildren() }) do
            if child.Cooldown then
                table.insert(frames, child)
            end
        end
    end

    return frames
end

local desaturationCurve = C_CurveUtil.CreateCurve()
desaturationCurve:AddPoint(0, 0)
desaturationCurve:AddPoint(0.001, 1)

local function ApplyIconSettings(cdmFrame)
    local cooldownInfo = cdmFrame:GetCooldownInfo()
    if cooldownInfo == nil then
        return
    end

    local spellID = cooldownInfo.overrideSpellID or cooldownInfo.spellID
    if not spellID then
        return
    end

    if CooldownStyle.GetShowAuras(spellID) and cdmFrame.wasSetFromAura then
        cdmFrame.Cooldown:SetDrawSwipe(cdmFrame.cooldownShowSwipe == true)
        cdmFrame.Icon:SetDesaturation(0)
        return
    end

    if cdmFrame.wasSetFromAura then
        cdmFrame.Icon:SetDesaturation(cdmFrame._CMCTracker_Desaturation)

        local spellCharges = C_Spell.GetSpellCharges(spellID)
        if spellCharges then
            if issecretvalue(spellCharges.currentCharges) or issecretvalue(spellCharges.maxCharges) then
                if issecretvalue(cdmFrame.Icon:IsDesaturated()) then
                    local flashIsShown = cdmFrame.CooldownFlash:IsShown()
                    cdmFrame.Cooldown:SetDrawSwipe(flashIsShown)
                    cdmFrame.Cooldown:SetDrawEdge(not flashIsShown or CooldownStyle.GetAlwaysShowCooldownEdge(spellID))
                else
                    cdmFrame.Cooldown:SetDrawSwipe(false)
                    cdmFrame.Cooldown:SetDrawEdge(true)
                end
            else
                cdmFrame.Cooldown:SetDrawSwipe(spellCharges.currentCharges == 0)
                cdmFrame.Cooldown:SetDrawEdge(
                    spellCharges.currentCharges < spellCharges.maxCharges
                        or CooldownStyle.GetAlwaysShowCooldownEdge(spellID)
                )
            end
        else
            cdmFrame.Cooldown:SetDrawSwipe(true)
        end
    end
end

local function GetCustomActiveSwipe()
    local r = ns.db.profile.cooldownManager_customActiveColor_r or 1
    local g = ns.db.profile.cooldownManager_customActiveColor_g or 0.95
    local b = ns.db.profile.cooldownManager_customActiveColor_b or 0.57
    local a = ns.db.profile.cooldownManager_customActiveColor_a or 0.69
    return r, g, b, a
end

local function GetCustomGCDSwipe()
    local r = ns.db.profile.cooldownManager_customCDSwipeColor_r or 0
    local g = ns.db.profile.cooldownManager_customCDSwipeColor_g or 0
    local b = ns.db.profile.cooldownManager_customCDSwipeColor_b or 0
    local a = ns.db.profile.cooldownManager_customCDSwipeColor_a or 0.69
    return r, g, b, a
end

local function ApplyCooldownSettings(cdmFrame)
    local cooldownInfo = cdmFrame:GetCooldownInfo()
    if cooldownInfo == nil then
        return
    end

    local spellID = cooldownInfo.overrideSpellID or cooldownInfo.spellID
    if not spellID then
        return
    end

    if CooldownStyle.GetAlwaysShowCooldownEdge(spellID) then
        cdmFrame.Cooldown:SetDrawEdge(true)
    end

    if CooldownStyle.GetShowAuras(spellID) and cdmFrame.wasSetFromAura then
        local _r, _g, _b, _a = GetCustomActiveSwipe()
        cdmFrame.Cooldown:SetSwipeColor(_r, _g, _b, _a)
        return
    end

    cdmFrame.Cooldown:SetReverse(false)

    local _r, _g, _b, _a = GetCustomGCDSwipe()
    cdmFrame.Cooldown:SetSwipeColor(_r, _g, _b, _a)

    local cooldownDuration = C_Spell.GetSpellCooldownDuration(spellID)
    cdmFrame.Cooldown:SetCooldownFromDurationObject(cooldownDuration)
    if C_Spell.GetSpellCharges(spellID) then
        cdmFrame.Cooldown:SetCooldownFromDurationObject(C_Spell.GetSpellChargeDuration(spellID))
    else
        cdmFrame.Cooldown:SetDrawSwipe(true)
    end

    local cooldown = C_Spell.GetSpellCooldown(spellID)
    if cooldown and cooldown.isOnGCD then
        cdmFrame._CMCTracker_Desaturation = 0
    else
        cdmFrame._CMCTracker_Desaturation = cooldownDuration:EvaluateRemainingPercent(desaturationCurve)
    end

    ApplyIconSettings(cdmFrame)
end

local function HookCooldownFrame(cdmFrame)
    if cdmFrame._CMCTracker_Hooked or cdmFrame.Cooldown == nil or cdmFrame.Icon == nil then
        return
    end

    hooksecurefunc(cdmFrame.Cooldown, "SetCooldown", function(self)
        ApplyCooldownSettings(self:GetParent())
    end)

    hooksecurefunc(cdmFrame.Icon, "SetDesaturated", function(self)
        ApplyIconSettings(self:GetParent())
    end)

    cdmFrame._CMCTracker_Hooked = true
end

local function HookBuffIconFrame(cdmFrame)
    if cdmFrame._CMCTracker_Hooked or cdmFrame.Cooldown == nil or cdmFrame.Icon == nil then
        return
    end

    hooksecurefunc(cdmFrame.Cooldown, "SetCooldown", function(self)
        local cdmFrame = self:GetParent()
        local cooldownInfo = cdmFrame:GetCooldownInfo()
        if cooldownInfo == nil then
            return
        end

        local spellID = cooldownInfo.overrideSpellID or cooldownInfo.spellID
        if not spellID then
            return
        end

        cdmFrame.Cooldown:SetDrawEdge(CooldownStyle.GetAlwaysShowCooldownEdge(spellID))
    end)

    cdmFrame._CMCTracker_Hooked = true
end

local function HookFrames()
    local cooldownFrames = GetCooldownFrames()

    for _, cdmFrame in ipairs(cooldownFrames) do
        if not cdmFrame._CMCTracker_Hooked then
            if cdmFrame.Cooldown ~= nil then
                HookCooldownFrame(cdmFrame)
            end
        end
    end

    local buffIconFrames = GetBuffIconFrames()

    for _, cdmFrame in ipairs(buffIconFrames) do
        if not cdmFrame._CMCTracker_Hooked then
            if cdmFrame.Cooldown ~= nil then
                HookBuffIconFrame(cdmFrame)
            end
        end
    end
end

local function RefreshCooldownManagerFrames()
    if InCombatLockdown() then
        return
    end

    HookFrames()

    for _, cdmFrame in ipairs(GetCooldownFrames()) do
        if cdmFrame.Cooldown and cdmFrame.Icon then
            ApplyCooldownSettings(cdmFrame)
            ApplyIconSettings(cdmFrame)
        end
    end
end

function CooldownStyle:RefreshHooks()
    HookFrames()
end

function CooldownStyle:Initialize()
    HookFrames()

    Menu.ModifyMenu("MENU_COOLDOWN_SETTINGS_ITEM", function(owner, rootDescription, contextData)
        local cooldownID = owner.cooldownID
        local cdInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
        local category = cdInfo.category
        local spellID = owner:GetBaseSpellID()

        rootDescription:CreateDivider()
        rootDescription:CreateTitle(MENU_TITLE)

        rootDescription:CreateCheckbox("Always Show Cooldown Edge", function()
            return CooldownStyle.GetAlwaysShowCooldownEdge(spellID)
        end, function()
            CooldownStyle.ToggleAlwaysShowCooldownEdge(spellID)
            RefreshCooldownManagerFrames()
        end)

        --[[category:
            HiddenAura: integer = -2,
            HiddenSpell: integer = -1,
            Essential: integer = 0,
            Utility: integer = 1,
            TrackedBuff: integer = 2,
            TrackedBar: integer = 3,
        ]]
        if category == 0 or category == 1 then
            rootDescription:CreateCheckbox("Show Auras", function()
                return CooldownStyle.GetShowAuras(spellID)
            end, function()
                CooldownStyle.ToggleShowAuras(spellID)
                RefreshCooldownManagerFrames()
            end)
        end

        rootDescription:CreateButton("Reset to Defaults", function()
            local db = CooldownStyle.GetDB()
            db.spellSettings[spellID] = nil
            RefreshCooldownManagerFrames()
        end)
    end)
end
function CooldownStyle.GetDB()
    return ns.db.profile.cooldownStyleSettings
end

function CooldownStyle.GetSpellSettings(spellID)
    local db = ns.db.profile.cooldownStyleSettings
    if not db or not db.spellSettings or db.spellSettings[spellID] == nil then
        return nil
    end
    return db.spellSettings[spellID]
end

function CooldownStyle.EnsureSpellSettings(spellID)
    local db = ns.db.profile.cooldownStyleSettings
    if db.spellSettings[spellID] == nil then
        db.spellSettings[spellID] = {}
    end
    return db.spellSettings[spellID]
end

function CooldownStyle.GetAlwaysShowCooldownEdge(spellID)
    local settings = CooldownStyle.GetSpellSettings(spellID)
    if settings and settings.alwaysShowCooldownEdge ~= nil then
        return settings.alwaysShowCooldownEdge
    end
    return DEFAULT_ALWAYS_SHOW_COOLDOWN_EDGE
end

function CooldownStyle.SetAlwaysShowCooldownEdge(spellID, value)
    if value == DEFAULT_ALWAYS_SHOW_COOLDOWN_EDGE then
        local settings = CooldownStyle.GetSpellSettings(spellID)
        if settings ~= nil then
            settings.alwaysShowCooldownEdge = nil
        end
        return
    end

    local settings = CooldownStyle.EnsureSpellSettings(spellID)
    settings.alwaysShowCooldownEdge = value
end

function CooldownStyle.ToggleAlwaysShowCooldownEdge(spellID)
    local current = CooldownStyle.GetAlwaysShowCooldownEdge(spellID)
    CooldownStyle.SetAlwaysShowCooldownEdge(spellID, not current)
end

function CooldownStyle.GetShowAuras(spellID)
    local settings = CooldownStyle.GetSpellSettings(spellID)
    if settings and settings.showAuras ~= nil then
        return settings.showAuras
    end
    return DEFAULT_SHOW_AURAS
end

function CooldownStyle.SetShowAuras(spellID, value)
    if value == DEFAULT_SHOW_AURAS then
        local settings = CooldownStyle.GetSpellSettings(spellID)
        if settings ~= nil then
            settings.showAuras = nil
        end
        return
    end

    local settings = CooldownStyle.EnsureSpellSettings(spellID)
    settings.showAuras = value
end

function CooldownStyle.ToggleShowAuras(spellID)
    local current = CooldownStyle.GetShowAuras(spellID)
    CooldownStyle.SetShowAuras(spellID, not current)
end
