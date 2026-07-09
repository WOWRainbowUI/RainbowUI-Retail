-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    Profiles.lua

    Profile management layer. Profiles are named snapshots of the
    full BIT.db settings table, all stored under
    `BliZziInterruptsSavedVars.profiles[<name>]`. The currently active
    profile's name lives at `BliZziInterruptsSavedVars.activeProfile`,
    and `BIT.db` always points at the active profile's table — so
    every existing read/write to `BIT.db.X` continues to work without
    needing changes elsewhere.

    The "Default" profile cannot be deleted or renamed; it acts as
    the fallback when other profiles disappear or migration runs.

    Auto-switch: each spec ID can be mapped to a profile name in
    `BliZziInterruptsSavedVars.specProfileMap`. PLAYER_SPECIALIZATION_CHANGED
    triggers `OnSpecChanged` which switches automatically when a
    mapping is set.
]]

BIT          = BIT or {}
BIT.Profiles = BIT.Profiles or {}
local P      = BIT.Profiles

local DEFAULT_NAME = "Default"

local function SV()  return BliZziInterruptsSavedVars       end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function _shallowCopy(t)
    local out = {}
    for k, v in pairs(t or {}) do
        if type(v) == "table" then
            local sub = {}
            for k2, v2 in pairs(v) do sub[k2] = v2 end
            out[k] = sub
        else
            out[k] = v
        end
    end
    return out
end

local function _applyDefaults(p)
    for k, v in pairs(BIT.DEFAULTS or {}) do
        if p[k] == nil then p[k] = v end
    end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------
function P:GetActiveName()
    local sv = SV() or {}
    return sv.activeProfile or DEFAULT_NAME
end

function P:GetAll()
    local sv = SV()
    sv.profiles = sv.profiles or { [DEFAULT_NAME] = {} }
    return sv.profiles
end

function P:Exists(name)
    if not name or name == "" then return false end
    return self:GetAll()[name] ~= nil
end

function P:GetNames()
    local out = {}
    for k in pairs(self:GetAll()) do out[#out + 1] = k end
    table.sort(out, function(a, b)
        if a == DEFAULT_NAME then return true end
        if b == DEFAULT_NAME then return false end
        return a < b
    end)
    return out
end

-- Initialise the SavedVars layout. On first run after upgrading from
-- the flat schema, every existing top-level setting is moved into a
-- "Default" profile so the user keeps everything they had configured.
-- Returns the active profile table (used to set BIT.db).
function P:Initialize()
    local sv = SV()
    if not sv.profiles then
        -- Migrate flat → profile structure. Move every existing key
        -- (except the new profile-system keys) into the Default profile.
        local default = {}
        for k, v in pairs(sv) do
            if k ~= "profiles" and k ~= "activeProfile"
               and k ~= "specProfileMap" then
                default[k] = v
                sv[k] = nil
            end
        end
        sv.profiles      = { [DEFAULT_NAME] = default }
        sv.activeProfile = DEFAULT_NAME
    end
    sv.profiles[DEFAULT_NAME] = sv.profiles[DEFAULT_NAME] or {}
    if not sv.profiles[sv.activeProfile or ""] then
        sv.activeProfile = DEFAULT_NAME
    end
    sv.specProfileMap = sv.specProfileMap or {}

    -- 3.5.0+ position migration: pre-3.5 stored the tracker position
    -- in BliZziInterruptsSavedVarsChar.posX/posY (per-character, shared
    -- across all profiles). Now each profile remembers its own position
    -- in its own settings table. Seed every existing profile that has
    -- no position yet from the legacy charDb position so the frame
    -- doesn't snap back to the default 100,200 anchor on the first
    -- post-update reload.
    local charDb = BliZziInterruptsSavedVarsChar
    if charDb then
        for _, prof in pairs(sv.profiles) do
            if not prof.posX   and charDb.posX   then prof.posX   = charDb.posX   end
            if not prof.posY   and charDb.posY   then prof.posY   = charDb.posY   end
            if not prof.posXUp and charDb.posXUp then prof.posXUp = charDb.posXUp end
            if not prof.posYUp and charDb.posYUp then prof.posYUp = charDb.posYUp end
        end
    end

    -- Apply defaults to *every* profile, not just the active one.
    -- When the addon adds new DEFAULTS keys in a release, this makes
    -- sure those keys are filled in on every saved profile (otherwise
    -- a profile only gets its missing keys whenever the user later
    -- switches into it, which can race with first-render).
    for _, prof in pairs(sv.profiles) do
        _applyDefaults(prof)
    end
    return sv.profiles[sv.activeProfile]
end

-- Switch the active profile in-place. Updates BIT.db reference and
-- pushes the change through every visual subsystem.
function P:Switch(name)
    if not self:Exists(name) then return false, "Profile not found." end
    local sv = SV()
    if sv.activeProfile == name then return true end
    sv.activeProfile = name
    BIT.db = sv.profiles[name]
    _applyDefaults(BIT.db)
    self:NotifyAllChanged()
    return true
end

-- Create a new profile populated with the addon defaults. The new
-- profile inherits the *current* tracker position so the frame
-- doesn't jump to the default anchor when the user switches into it
-- the first time — they can still drag it to a different spot
-- afterwards, which then sticks per-profile.
--
-- The font defaults to "Expressway" when LibSharedMedia has it
-- registered (most users do — the font ships with many popular
-- addons that depend on LSM). Without LSM or the font, we leave
-- fontPath / fontName nil and let BIT.Media's auto-detect chain
-- pick the best locally-available alternative the next time it runs.
function P:Create(name)
    if not name or name == "" then return false, "Empty name." end
    if self:Exists(name) then return false, "A profile with this name already exists." end
    local sv = SV()
    local p  = {}
    _applyDefaults(p)
    if BIT.db then
        if BIT.db.posX   then p.posX   = BIT.db.posX   end
        if BIT.db.posY   then p.posY   = BIT.db.posY   end
        if BIT.db.posXUp then p.posXUp = BIT.db.posXUp end
        if BIT.db.posYUp then p.posYUp = BIT.db.posYUp end
    end
    -- Seed Expressway as the default font for this fresh profile.
    local lsm = LibStub and LibStub("LibSharedMedia-3.0", true)
    if lsm and lsm.IsValid and lsm:IsValid("font", "Expressway") then
        local path = lsm:Fetch("font", "Expressway")
        if path and path ~= "" then
            p.fontName = "Expressway"
            p.fontPath = path
        end
    end
    sv.profiles[name] = p
    return true
end

-- Duplicate an existing profile under a new name.
function P:Clone(srcName, newName)
    if not self:Exists(srcName) then return false, "Source not found." end
    if not newName or newName == "" then return false, "Empty name." end
    if self:Exists(newName) then return false, "A profile with this name already exists." end
    local sv = SV()
    sv.profiles[newName] = _shallowCopy(sv.profiles[srcName])
    return true
end

-- Rename a profile. The Default profile can't be renamed.
function P:Rename(oldName, newName)
    if oldName == DEFAULT_NAME then return false, "Default profile can't be renamed." end
    if not self:Exists(oldName) then return false, "Profile not found." end
    if not newName or newName == "" then return false, "Empty name." end
    if self:Exists(newName) then return false, "A profile with this name already exists." end
    local sv = SV()
    sv.profiles[newName] = sv.profiles[oldName]
    sv.profiles[oldName] = nil
    -- Patch the spec→profile map so existing assignments keep pointing at this profile.
    for spec, prof in pairs(sv.specProfileMap or {}) do
        if prof == oldName then sv.specProfileMap[spec] = newName end
    end
    if sv.activeProfile == oldName then
        sv.activeProfile = newName
        BIT.db = sv.profiles[newName]
    end
    return true
end

-- Delete a profile. The Default profile can't be deleted. If the
-- active profile is removed, fall back to Default.
function P:Delete(name)
    if name == DEFAULT_NAME then return false, "Default profile can't be deleted." end
    if not self:Exists(name) then return false, "Profile not found." end
    local sv = SV()
    sv.profiles[name] = nil
    for spec, prof in pairs(sv.specProfileMap or {}) do
        if prof == name then sv.specProfileMap[spec] = nil end
    end
    if sv.activeProfile == name then
        return self:Switch(DEFAULT_NAME)
    end
    return true
end

-- Reset a profile back to addon defaults.
function P:Reset(name)
    name = name or self:GetActiveName()
    if not self:Exists(name) then return false, "Profile not found." end
    local sv = SV()
    local p  = {}
    _applyDefaults(p)
    sv.profiles[name] = p
    if sv.activeProfile == name then
        BIT.db = p
        self:NotifyAllChanged()
    end
    return true
end

-- Import wraps Profile.lua's ImportProfile.
--
-- Two flows depending on what the encoded string actually contains:
--   * Bundle (multi-profile + spec assignments): every exported profile
--     is restored under its original name, and the spec→profile map is
--     applied. The `name` argument is unused here because the bundle
--     ships its own profile names.
--   * Single profile: the legacy / one-profile case. We create or
--     overwrite a slot named `name`, point BIT.db at it, and let
--     ImportProfile write the settings into it.
function P:Import(name, encodedString)
    if not encodedString or encodedString == "" then return false, "Empty string." end

    local kind = (BIT.PeekProfileImport and BIT.PeekProfileImport(encodedString)) or "legacy"

    if kind == "bundle" then
        -- Pass the name through: for SINGLE-profile bundles the importer
        -- renames the shipped profile to it (spec map + active pointer
        -- follow); multi-profile bundles ignore it and keep their names.
        local ok, msg, meta = BIT.ImportProfile(encodedString, name)
        if ok then self:NotifyAllChanged() end
        return ok, msg, meta
    end

    -- Single-profile path needs a target name. Create / overwrite the
    -- target profile and switch to it so the existing ImportProfile
    -- pipeline writes into the right slot.
    if not name or name == "" then return false, "Empty name." end
    local sv = SV()
    sv.profiles[name] = sv.profiles[name] or {}
    local prevActive = sv.activeProfile
    sv.activeProfile = name
    BIT.db = sv.profiles[name]
    _applyDefaults(BIT.db)
    local ok, msg, meta = BIT.ImportProfile(encodedString)
    if not ok then
        -- Roll back the active reference so we don't strand the user
        -- on a half-written import slot.
        sv.activeProfile = prevActive
        BIT.db = sv.profiles[prevActive] or sv.profiles[DEFAULT_NAME]
        return false, msg
    end
    self:NotifyAllChanged()
    return true, msg, meta
end

---------------------------------------------------------------------------
-- Spec auto-switch
---------------------------------------------------------------------------
function P:GetSpecProfile(specID)
    if not specID then return nil end
    local sv = SV()
    return sv.specProfileMap and sv.specProfileMap[specID]
end

function P:SetSpecProfile(specID, profileName)
    if not specID then return end
    local sv = SV()
    sv.specProfileMap = sv.specProfileMap or {}
    if profileName == nil or profileName == "" or profileName == "(none)" then
        sv.specProfileMap[specID] = nil
    else
        sv.specProfileMap[specID] = profileName
    end
end

-- Called from the PLAYER_SPECIALIZATION_CHANGED handler. Switches the
-- active profile if a mapping exists for the new spec.
function P:OnSpecChanged(specID)
    if not specID then return end
    local target = self:GetSpecProfile(specID)
    if not target or target == self:GetActiveName() then return end
    if not self:Exists(target) then return end
    self:Switch(target)
    print(string.format(
        "|cff0091edBIT|r switched to profile |cffffd700%s|r for current spec.",
        target))
end

---------------------------------------------------------------------------
-- Visual refresh
---------------------------------------------------------------------------
-- Pushes a profile change through every renderer + the settings UI.
function P:NotifyAllChanged()
    -- Re-resolve the live media (font / bar texture / border texture)
    -- against the new profile's saved paths first, so the rebuilds
    -- below pick up the new visuals instead of the previous profile's.
    if BIT.Media and BIT.Media.Load then BIT.Media:Load() end
    if BIT.UI then
        if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
        if BIT.UI.CheckZoneVisibility then BIT.UI:CheckZoneVisibility() end
        if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
            BIT.UI.AttachedInterrupts:Rebuild()
        end
        if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
    end
    if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
    if BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.Refresh then
        BIT.OffensiveCDAlert:Refresh()
    end
    if BIT.ApplyLocale then BIT:ApplyLocale() end
    -- Re-layout the currently visible settings page so toggles re-read
    -- their getters and reflect the new profile values.
    if BIT.SettingsUI and BIT.SettingsUI.RefreshActivePage then
        BIT.SettingsUI:RefreshActivePage()
    end
end
