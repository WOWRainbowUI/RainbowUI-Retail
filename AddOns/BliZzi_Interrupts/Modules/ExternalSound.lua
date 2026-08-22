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

local function IsEnabled()
    return BIT.db and BIT.db.externalSoundEnabled == true
end

-- Enumerate the player's currently-active external defensives by aura
-- INSTANCE ID. One GetUnitAuras fetch, then a per-aura category probe —
-- the same taint-safe pattern the overlay uses. IsAuraFilteredOutBy...
-- returns a clean boolean even for secret auras, and auraInstanceID is
-- a clean number. Everything is pcall'd (these APIs are the throw-prone
-- ones under taint).
local function ForEachExternal(fn)
    local ok, list = pcall(C_UnitAuras.GetUnitAuras, "player", "HELPFUL")
    if not ok or type(list) ~= "table" then return end
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
    if IsEnabled() then
        if not _frame then
            _frame = CreateFrame("Frame")
            _frame:SetScript("OnEvent",
                (BIT.Prof and BIT.Prof.Wrap) and BIT.Prof.Wrap("PARTY_CDS", OnEvent) or OnEvent)
        end
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
