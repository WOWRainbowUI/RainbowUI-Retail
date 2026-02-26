local addonName, ns = ...

local MiscPanel = ns.MiscPanel

local CooldownStyle = ns.CooldownStyle or {}
ns.CooldownStyle = CooldownStyle
local MENU_TITLE = "|cff008945C|r|cff1e9a4eo|r|cff3faa4fol|r|cff5fb64ado|r|cff7ac243wn|r |cff8ccd00Manager Centered|r"
local GCD_SPELL_ID = 61304

local DEFAULT_ALWAYS_SHOW_COOLDOWN_EDGE = false
local DEFAULT_SHOW_AURAS = true
local DEFAULT_DISABLE_PROCS_GLOW = false
local DEFAULT_REVERSE_AURA_SWIPE = false

CooldownStyle.FORCE_DISABLED_INSTANT_CASTS = {
    -- Druid
    [8921] = true, -- Moonfire
    [93402] = true, -- Sunfire
    [191034] = true, -- Starfall

    -- Warlock
    [980] = true, -- Agony
    [172] = true, -- Corruption
    [348] = true, -- Immolate
    [5740] = true, -- Rain of Fire
    [1214467] = true, -- Raid of Fire
    [316099] = true, -- Unstable Affliction
    [1259790] = true, -- Unstable Affliction
    [17877] = true, -- Shadowburn

    -- Priest
    [589] = true, -- Shadow Word: Pain
    [34914] = true, -- Vampiric Touch
    [15407] = true, -- Mind Flay,
    [335467] = true, -- Shadow Word: Madness
}

-- local FIX_BLIZZARD_MISSING_DEBUFF = {
--     [204596] = true, -- Sigil of Flame
--     [207684] = true, -- Sigil of Misery
--     [202137] = true, -- Sigil of Silence
-- }
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

    local baseSpellId = FindBaseSpellByID(spellID)

    local shouldShowAuras = true
    if not CooldownStyle.GetShowAuras(cooldownInfo.spellID) or not CooldownStyle.GetShowAuras(baseSpellId) then
        shouldShowAuras = false
    end

    if shouldShowAuras and cdmFrame.wasSetFromAura then
        cdmFrame.Cooldown:SetDrawSwipe(cdmFrame.cooldownShowSwipe == true)
        cdmFrame.Icon:SetDesaturation(0)
        return
    end
    if cdmFrame._CMCTracker_Desaturation ~= nil then
        cdmFrame.Icon:SetDesaturation(cdmFrame._CMCTracker_Desaturation)
    end
    if cdmFrame.wasSetFromAura then
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
    local baseSpellId = FindBaseSpellByID(spellID)
    local shouldShowAuras = true
    if not CooldownStyle.GetShowAuras(cooldownInfo.spellID) or not CooldownStyle.GetShowAuras(baseSpellId) then
        shouldShowAuras = false
    end

    if CooldownStyle.GetAlwaysShowCooldownEdge(spellID) then
        cdmFrame.Cooldown:SetDrawEdge(true)
    end

    if shouldShowAuras and cdmFrame.wasSetFromAura then
        cdmFrame.Cooldown:SetReverse(CooldownStyle.GetReverseAuraSwipe(baseSpellId))
        local _r, _g, _b, _a = GetCustomActiveSwipe()
        cdmFrame.Cooldown:SetSwipeColor(_r, _g, _b, _a)
        return
    end
    local shouldHideAuras = not shouldShowAuras and cdmFrame.wasSetFromAura

    cdmFrame.Cooldown:SetReverse(false)

    local _r, _g, _b, _a = GetCustomGCDSwipe()
    cdmFrame.Cooldown:SetSwipeColor(_r, _g, _b, _a)

    local cooldown = C_Spell.GetSpellCooldown(spellID)

    cdmFrame._CMCTracker_Desaturation = nil

    if shouldHideAuras then
        if cooldown.isOnGCD then
            cdmFrame.Cooldown:SetCooldownFromDurationObject(C_Spell.GetSpellCooldownDuration(GCD_SPELL_ID))
        else
            if C_Spell.GetSpellCharges(spellID) then
                cdmFrame._CMCTracker_Desaturation = 1
                cdmFrame.Cooldown:SetCooldownFromDurationObject(C_Spell.GetSpellChargeDuration(spellID))
            else
                local cooldownDuration = C_Spell.GetSpellCooldownDuration(spellID)
                cdmFrame.Cooldown:SetCooldownFromDurationObject(cooldownDuration)
                cdmFrame._CMCTracker_Desaturation = cooldownDuration:EvaluateRemainingDuration(desaturationCurve)
            end
        end
    end
    if shouldHideAuras and CooldownStyle.FORCE_DISABLED_INSTANT_CASTS[baseSpellId] then
        if cooldown.isOnGCD then
            local cooldownDuration = C_Spell.GetSpellCooldownDuration(GCD_SPELL_ID)
            cdmFrame.Cooldown:SetCooldownFromDurationObject(cooldownDuration)
        else
            cdmFrame.Cooldown:SetCooldownFromDurationObject(C_DurationUtil.CreateDuration())
        end
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

    -- local cooldownInfo = cdmFrame:GetCooldownInfo()
    hooksecurefunc(cdmFrame.Icon, "SetDesaturated", function(self)
        ApplyIconSettings(self:GetParent())
    end)
    -- if FIX_BLIZZARD_MISSING_DEBUFF[cooldownInfo.spellID] then
    --     print("Applying fix for missing desaturation for spellID", cooldownInfo.spellID)
    --     hooksecurefunc(cdmFrame.Cooldown, "Clear", function(self)
    --         ApplyCooldownSettings(self:GetParent(), true)
    --     end)
    -- end

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
        end
    end
end

function CooldownStyle:RefreshHooks()
    HookFrames()
end

local isMenuModified = false
function CooldownStyle:Initialize()
    HookFrames()
    if isMenuModified then
        return
    end

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
        if cdInfo.hasAura or cdInfo.selfAura then
            if category == 0 or category == 1 then
                rootDescription:CreateCheckbox("Hide Aura", function()
                    return not CooldownStyle.GetShowAuras(spellID)
                end, function()
                    CooldownStyle.ToggleShowAuras(spellID)
                    RefreshCooldownManagerFrames()
                end)
            end

            if category == 0 or category == 1 then
                rootDescription:CreateCheckbox("Reverse Aura Swipe", function()
                    return CooldownStyle.GetReverseAuraSwipe(spellID)
                end, function()
                    CooldownStyle.ToggleReverseAuraSwipe(spellID)
                    RefreshCooldownManagerFrames()
                end)
            end
        end

        if category == 0 or category == 1 then
            rootDescription:CreateCheckbox("Disable Proc Glow", function()
                return CooldownStyle.GetDisableProcsGlow(spellID)
            end, function()
                CooldownStyle.ToggleDisableProcsGlow(spellID)
                -- RefreshCooldownManagerFrames()
            end)
        end

        rootDescription:CreateButton("Reset to Defaults", function()
            local db = CooldownStyle.GetDB()
            db.spellSettings[spellID] = nil
            RefreshCooldownManagerFrames()
        end)
    end)
    isMenuModified = true
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

function CooldownStyle.GetReverseAuraSwipe(spellID)
    local settings = CooldownStyle.GetSpellSettings(spellID)
    if settings and settings.reverseAuraSwipe ~= nil then
        return settings.reverseAuraSwipe
    end
    return DEFAULT_REVERSE_AURA_SWIPE
end

function CooldownStyle.SetReverseAuraSwipe(spellID, value)
    if value == DEFAULT_REVERSE_AURA_SWIPE then
        local settings = CooldownStyle.GetSpellSettings(spellID)
        if settings ~= nil then
            settings.reverseAuraSwipe = nil
        end
        return
    end

    local settings = CooldownStyle.EnsureSpellSettings(spellID)
    settings.reverseAuraSwipe = value
end

function CooldownStyle.ToggleReverseAuraSwipe(spellID)
    local current = CooldownStyle.GetReverseAuraSwipe(spellID)
    CooldownStyle.SetReverseAuraSwipe(spellID, not current)
end

function CooldownStyle.GetDisableProcsGlow(spellID)
    local settings = CooldownStyle.GetSpellSettings(spellID)
    if settings and settings.disableProcsGlow ~= nil then
        return settings.disableProcsGlow
    end
    return DEFAULT_DISABLE_PROCS_GLOW
end

function CooldownStyle.SetDisableProcsGlow(spellID, value)
    if value == DEFAULT_DISABLE_PROCS_GLOW then
        local settings = CooldownStyle.GetSpellSettings(spellID)
        if settings ~= nil then
            settings.disableProcsGlow = nil
        end
        return
    end

    local settings = CooldownStyle.EnsureSpellSettings(spellID)
    settings.disableProcsGlow = value
end

function CooldownStyle.ToggleDisableProcsGlow(spellID)
    local current = CooldownStyle.GetDisableProcsGlow(spellID)
    CooldownStyle.SetDisableProcsGlow(spellID, not current)
end
