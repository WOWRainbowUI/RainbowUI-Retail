-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    ExternalSound.lua - BliZzi Party Tools
    -----------------------------------------------------------------------
    Plays ONE configurable sound whenever an external defensive lands on
    the LOCAL player (Pain Suppression, Blessing of Sacrifice/Protection,
    Ironbark, Guardian Spirit, Life Cocoon, Time Dilation, ...).

    Why this is taint-safe where the earlier per-spell attempt crashed:
      * The server classifies the aura — we enumerate active externals
        via the HELPFUL|EXTERNAL_DEFENSIVE filter and never need the
        spellId (which is a SECRET value in 12.x, even on the player's
        own auras — indexing a table with it throws).
      * Dedup is keyed on `auraInstanceID`, which is a CLEAN number: it
        is safe to compare and to use as a table key. So the sound fires
        exactly once per received cast, and no per-spell configuration
        is needed.
    -----------------------------------------------------------------------
]]

BIT = BIT or {}
BIT.ExternalSound = BIT.ExternalSound or {}
local EXT = BIT.ExternalSound

local FILTER = "HELPFUL|EXTERNAL_DEFENSIVE"
local _seen  = {}   -- auraInstanceID -> true, for one-shot-per-aura dedup
local _cur   = {}   -- reused per-scan "present" set
local _frame
-- Suppress rings until a post-load baseline is captured. Set true on
-- enable and on every PLAYER_ENTERING_WORLD; a delayed Prime() clears
-- it once the world + aura data are actually available, so externals
-- that were already on you at login / after a zone change (or that
-- persisted through it) never ring retroactively.
local _priming = true

-- Module switched off as a whole (listed as "Unavailable" in the settings,
-- together with the defensive overlay) while it is being reworked. The
-- saved settings are untouched; set this to false to bring it back.
EXT.UNAVAILABLE = true

local function IsEnabled()
    if EXT.UNAVAILABLE then return false end
    return BIT.db and BIT.db.externalSoundEnabled == true
end

------------------------------------------------------------------------
-- Engine-played sounds (12.1+): C_UnitAuras.AddAuraSound
--
-- In combat the game refuses every addon aura read (secret auras), so the
-- scan below can only ring out of combat — useless for externals, which
-- land mid-fight. 12.1 lets an addon register "play this file when spell X
-- is applied to unit Y"; the ENGINE then plays it, in and out of combat,
-- without the addon ever seeing the aura. It is keyed by spell ID (there
-- is no category filter for it), hence the list of common externals.
-- Registration itself is done out of combat and re-done whenever the
-- chosen sound changes.
------------------------------------------------------------------------
local EXTERNAL_SPELLS = {
    33206,   -- Pain Suppression
    47788,   -- Guardian Spirit
    197268,  -- Ray of Hope
    102342,  -- Ironbark
    116849,  -- Life Cocoon
    357170,  -- Time Dilation
    1022,    -- Blessing of Protection
    6940,    -- Blessing of Sacrifice
    204018,  -- Blessing of Spellwarding
    3411,    -- Intervene
    147833,  -- Intervene (alternate id)
    223658,  -- Safeguard
    53480,   -- Roar of Sacrifice
}

local AddSoundNew = C_UnitAuras and C_UnitAuras.AddAuraSound
local AddSoundOld = C_UnitAuras and C_UnitAuras.AddAuraAppliedSound
local RemoveSound = C_UnitAuras and (C_UnitAuras.RemoveAuraSound or C_UnitAuras.RemoveAuraAppliedSound)
local ENGINE_SOUNDS = (AddSoundNew or AddSoundOld) and RemoveSound and true or false

local _soundIDs = {}      -- handles returned by AddAuraSound
local _soundSig           -- what is registered right now ("" = nothing)
local _soundPending = false

local function ClearEngineSounds()
    for i = #_soundIDs, 1, -1 do
        pcall(RemoveSound, _soundIDs[i])
        _soundIDs[i] = nil
    end
    _soundSig = ""
end

-- Register (or re-register on a sound change). Deferred to the end of
-- combat when called during it. Returns true when the engine path is in
-- charge (so the addon-side scan must stay off to avoid double rings).
local function SyncEngineSounds()
    if not ENGINE_SOUNDS then return false end
    local path = IsEnabled() and BIT.Media and BIT.Media.GetSoundPath
        and BIT.Media:GetSoundPath(BIT.db.externalSound) or nil
    local sig = path or ""
    if sig == _soundSig then _soundPending = false; return true end
    if InCombatLockdown and InCombatLockdown() then
        _soundPending = true
        return true
    end
    _soundPending = false
    ClearEngineSounds()
    if not path then return true end
    local trigger = (Enum and Enum.UnitAuraSoundTrigger and Enum.UnitAuraSoundTrigger.Added) or 0
    for _, id in ipairs(EXTERNAL_SPELLS) do
        local info = { unitToken = "player", spellID = id,
                       soundFileName = path, outputChannel = "Master" }
        local ok, handle
        if AddSoundNew then ok, handle = pcall(AddSoundNew, trigger, info)
        else ok, handle = pcall(AddSoundOld, info) end
        if ok and handle then _soundIDs[#_soundIDs + 1] = handle end
    end
    _soundSig = sig
    return true
end

-- Enumerate the player's currently-active external defensives by aura
-- INSTANCE ID. One GetUnitAuras fetch, then a per-aura category probe —
-- the same taint-safe pattern the overlay uses. IsAuraFilteredOutBy...
-- returns a clean boolean even for secret auras, and auraInstanceID is
-- a clean number. Everything is pcall'd (these APIs are the throw-prone
-- ones under taint).
-- Reused list for the index-walk fallback below.
local _walk = {}

-- GetUnitAuras first; when it fails (seen live: it errors in combat,
-- exactly when externals land) fall back to walking the auras with
-- GetAuraDataByIndex — same fallback as the defensive overlay.
local function ReadHelpful()
    local ok, list = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
    if ok and type(list) == "table" and pcall(function() local _ = list[1] end) then
        return list
    end
    wipe(_walk)
    pcall(function()
        for i = 1, 60 do
            local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
            if not a then break end
            _walk[#_walk + 1] = a
        end
    end)
    return _walk
end

local function ForEachExternal(fn)
    local list = ReadHelpful()
    for _, aura in ipairs(list) do
        if aura and aura.auraInstanceID then
            local okE, filteredOut = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID,
                "player", aura.auraInstanceID, FILTER)
            -- filteredOut == false → the aura DOES match the external filter
            if okE and filteredOut == false then fn(aura.auraInstanceID) end
        end
    end
end

local function PlayIt()
    local name = BIT.db and BIT.db.externalSound
    if name and name ~= "" and name ~= "None"
       and BIT.Media and BIT.Media.PlayKickSound then
        BIT.Media:PlayKickSound(name)
    end
end

-- Silent baseline: record the currently-active externals as "seen" so
-- they never ring. Clears the priming gate.
local function Prime()
    wipe(_seen)
    ForEachExternal(function(instId) _seen[instId] = true end)
    _priming = false
end

local function Scan()
    if not IsEnabled() or _priming then return end
    wipe(_cur)
    ForEachExternal(function(instId)
        _cur[instId] = true
        if not _seen[instId] then
            _seen[instId] = true
            PlayIt()   -- fresh external → ring once
        end
    end)
    -- Forget auras that are gone so their instance IDs can re-trigger
    -- if the same slot is reused later.
    for id in pairs(_seen) do
        if not _cur[id] then _seen[id] = nil end
    end
end

local function OnEvent(_, event, unit)
    if event == "PLAYER_REGEN_ENABLED" then
        if _soundPending then SyncEngineSounds() end
        return
    end
    if event == "UNIT_AURA" then
        if unit == "player" then Scan() end
    else
        -- PLAYER_ENTERING_WORLD: gate rings and re-baseline once the
        -- aura data has settled (auras aren't reliably readable in the
        -- same frame the event fires).
        _priming = true
        C_Timer.After(0.5, Prime)
    end
end

-- Arm / disarm according to the enable toggle. Idempotent.
function EXT:ApplyEnabled()
    if not _frame then
        _frame = CreateFrame("Frame")
        _frame:SetScript("OnEvent",
            (BIT.Prof and BIT.Prof.Wrap) and BIT.Prof.Wrap("PARTY_CDS", OnEvent) or OnEvent)
    end
    -- 12.1+: the engine plays the sound (works in combat). The addon-side
    -- scan stays off so nothing rings twice.
    if ENGINE_SOUNDS then
        _frame:UnregisterAllEvents()
        _priming = true
        wipe(_seen)
        SyncEngineSounds()   -- registers, re-registers or clears (when disabled)
        if _soundPending then _frame:RegisterEvent("PLAYER_REGEN_ENABLED") end
        return
    end
    if IsEnabled() then
        -- RegisterUnitEvent is fine here: this only ever watches the
        -- LOCAL player, whose UNIT_AURA delivery is reliable (the
        -- party-slot delivery gap that forces broad registration
        -- elsewhere doesn't apply to "player").
        _frame:RegisterUnitEvent("UNIT_AURA", "player")
        _frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        -- Baseline shortly after arming so whatever is already on the
        -- player at enable time doesn't ring. The gate suppresses any
        -- UNIT_AURA in the meantime.
        _priming = true
        C_Timer.After(0.5, Prime)
    else
        if _frame then _frame:UnregisterAllEvents() end
        _priming = true
        wipe(_seen)
    end
end

-- Audition hook for the settings dropdown speaker button already plays
-- via BIT.Media; nothing extra needed here.

do
    local boot = CreateFrame("Frame")
    boot:RegisterEvent("PLAYER_LOGIN")
    boot:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_LOGIN")
        C_Timer.After(0, function()
            if BIT.ExternalSound and BIT.ExternalSound.ApplyEnabled then
                BIT.ExternalSound:ApplyEnabled()
            end
        end)
    end)
end
