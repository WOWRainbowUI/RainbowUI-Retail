--=====================================================================================
-- RGX-Framework | RGXCombat
-- Combat event library for any RGX-Framework addon.
-- Designed to make combat-related addon development trivially easy.
--
-- Usage (zero boilerplate):
--   local Combat = RGX:GetCombat()
--
--   -- Core combat state
--   Combat:OnEnter(function() print("entered combat") end)
--   Combat:OnLeave(function() print("left combat") end)
--   Combat:OnKill(function(victimName, victimGUID) ... end)
--   Combat:OnPlayerDied(function() ... end)
--   Combat:OnPlayerDamaged(function(amount, spellName) ... end)
--   Combat:OnPlayerHealed(function(amount, spellName) ... end)
--   Combat:OnCrit(function(amount, spellName) ... end)
--   Combat:OnCritHeal(function(amount, spellName) ... end)
--   Combat:OnKillingBlow(function(victimName) ... end)   -- alias: OnKill
--
--   -- Health / resource thresholds (fires on first crossing only)
--   Combat:OnLowHealth(function(pct) ... end)         -- player < 35%
--   Combat:OnExecuteWindow(function(pct) ... end)     -- target < 20%
--   Combat:OnResourceCapped(function() ... end)       -- player power at 100%
--   Combat:OnResourceLow(function(pct) ... end)       -- player power < 20%
--
--   -- Target / proc events
--   Combat:OnTargetLost(function() ... end)           -- PLAYER_TARGET_CHANGED, no target
--   Combat:OnProc(function() ... end)                 -- UNIT_AURA gained on player
--
--   -- Encounter / PvP
--   Combat:OnEncounterEnd(function(encounterID, name, diffID, groupSize, success) ... end)
--   Combat:OnEncounterVictory(function(encounterID, name, diffID, groupSize) ... end)
--   Combat:OnPvPVictory(function() ... end)
--
--   Combat:IsInCombat()    -- bool
--   Combat:GetDuration()   -- seconds in current combat (0 if not in combat)
--
-- All callbacks are fire-and-forget; multiple addons can register independently.
-- Errors in callbacks are caught and do not break other callbacks.
--=====================================================================================

local addonName, RGX = ...

local Combat = {}

-- ── State ─────────────────────────────────────────────────────────────────────

Combat._inCombat        = false
Combat._combatStartTime = 0
Combat._eventsInit      = false

Combat._onEnter            = {}
Combat._onLeave            = {}
Combat._onKill             = {}
Combat._onPlayerDied       = {}
Combat._onPlayerDamaged    = {}
Combat._onPlayerHealed     = {}
Combat._onCrit             = {}
Combat._onCritHeal         = {}
Combat._onLowHealth        = {}
Combat._onExecuteWindow    = {}
Combat._onResourceCapped   = {}
Combat._onResourceLow      = {}
Combat._onTargetLost       = {}
Combat._onProc             = {}
Combat._onEncounterEnd     = {}
Combat._onEncounterVictory = {}
Combat._onPvPVictory       = {}

Combat._prevHealthPct   = {}  -- ["player"|"target"] pct at last fire
local LOW_HEALTH_PCT    = 0.35
local EXECUTE_PCT       = 0.20
local RESOURCE_LOW_PCT  = 0.20

-- ── Callback helpers ──────────────────────────────────────────────────────────

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    table.insert(list, fn)
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXCombat] Callback error: " .. tostring(err)) end
    end
end

local function IsUnitBelowThreshold(unit, valueFunc, maxFunc, threshold)
    local ok, isBelow = pcall(function()
        if type(valueFunc) ~= "function" or type(maxFunc) ~= "function" then return nil end
        local max = maxFunc(unit)
        if not max or max <= 0 then return nil end
        return ((valueFunc(unit) or 0) / max) < threshold
    end)
    if ok and type(isBelow) == "boolean" then
        return isBelow
    end
    return nil
end

local function GetUnitPowerState(unit)
    local ok, capped, low = pcall(function()
        if type(UnitPower) ~= "function" or type(UnitPowerMax) ~= "function" then return nil, nil end
        local max = UnitPowerMax(unit)
        if not max or max <= 0 then return nil, nil end
        local pct = (UnitPower(unit) or 0) / max
        return pct >= 1.0, pct < RESOURCE_LOW_PCT
    end)
    if ok then
        return capped, low
    end
    return nil, nil
end

-- ── Public callback registration ─────────────────────────────────────────────

-- Fired when the player enters combat (PLAYER_REGEN_DISABLED)
function Combat:OnEnter(fn)   return AddCb(self._onEnter, fn)         end

-- Fired when the player leaves combat (PLAYER_REGEN_ENABLED)
function Combat:OnLeave(fn)   return AddCb(self._onLeave, fn)         end

-- Fired when the player delivers a killing blow.
-- fn(victimName, victimGUID, victimIsPlayer)
function Combat:OnKill(fn)    return AddCb(self._onKill, fn)          end
Combat.OnKillingBlow = Combat.OnKill

-- Fired when the player dies.
function Combat:OnPlayerDied(fn) return AddCb(self._onPlayerDied, fn) end

-- Fired when the player takes damage.
-- fn(amount, spellName, school)
function Combat:OnPlayerDamaged(fn) return AddCb(self._onPlayerDamaged, fn) end

-- Fired when the player receives a heal.
-- fn(amount, spellName, overheal)
function Combat:OnPlayerHealed(fn) return AddCb(self._onPlayerHealed, fn) end

-- Fired when the player scores a critical hit.
-- fn(amount, spellName, isMelee)
function Combat:OnCrit(fn)    return AddCb(self._onCrit, fn)          end

-- Fired when the player scores a critical heal.
-- fn(amount, spellName)
function Combat:OnCritHeal(fn) return AddCb(self._onCritHeal, fn)     end

-- Fired when the player's health drops below 35% (threshold crossing only).
-- fn(pct)  where pct is 0..1
function Combat:OnLowHealth(fn)       return AddCb(self._onLowHealth,      fn) end

-- Fired when the target's health drops below 20% (threshold crossing only).
-- fn(pct)
function Combat:OnExecuteWindow(fn)   return AddCb(self._onExecuteWindow,  fn) end

-- Fired when the player's primary resource reaches 100%.
-- fn()
function Combat:OnResourceCapped(fn)  return AddCb(self._onResourceCapped, fn) end

-- Fired when the player's primary resource drops below 20% (threshold crossing only).
-- fn(pct)
function Combat:OnResourceLow(fn)     return AddCb(self._onResourceLow,    fn) end

-- Fired when the player's target is cleared (PLAYER_TARGET_CHANGED, no unit).
-- fn()
function Combat:OnTargetLost(fn)      return AddCb(self._onTargetLost,     fn) end

-- Fired when a buff/proc aura is gained on the player (UNIT_AURA).
-- fn()
function Combat:OnProc(fn)            return AddCb(self._onProc,           fn) end

-- Fired at the end of a raid/dungeon encounter (any outcome).
-- fn(encounterID, encounterName, difficultyID, groupSize, success)
function Combat:OnEncounterEnd(fn)    return AddCb(self._onEncounterEnd,     fn) end

-- Fired at the end of a raid/dungeon encounter when the group wins.
-- fn(encounterID, encounterName, difficultyID, groupSize)
function Combat:OnEncounterVictory(fn) return AddCb(self._onEncounterVictory, fn) end

-- Fired when a PvP match completes and the player is on the winning side.
-- fn()
function Combat:OnPvPVictory(fn)      return AddCb(self._onPvPVictory,      fn) end

-- ── State queries ─────────────────────────────────────────────────────────────

function Combat:IsInCombat()
    return self._inCombat
end

-- True when combat-log payload callbacks (OnKill, OnCrit, OnCritHeal,
-- OnPlayerDamaged, OnPlayerHealed) can fire on this client. False on Retail
-- 12.x, where addon registration of COMBAT_LOG_EVENT_UNFILTERED is rejected.
function Combat:HasCombatLogEvents()
    return RGX:HasCapability("combatLogEvent")
end

function Combat:GetDuration()
    if not self._inCombat then return 0 end
    return (GetTime and GetTime() or 0) - self._combatStartTime
end

-- ── Combat log parsing ────────────────────────────────────────────────────────
--
-- COMBAT_LOG_EVENT_UNFILTERED is registered ONLY on flavors where the client
-- accepts addon-side CLEU registration (Classic Era, TBC, Wrath/Titan,
-- Cataclysm, Mists). Retail 12.x rejects it via the protection layer, so the
-- event is never requested there. Callbacks that depend on combat-log payload
-- data (OnKill/OnKillingBlow, OnCrit, OnCritHeal, OnPlayerDamaged,
-- OnPlayerHealed) degrade to never firing on clients without the capability;
-- query Combat:HasCombatLogEvents() to detect that. All other Combat features
-- (combat state, health/resource thresholds, target/proc, encounter, PvP)
-- work independently of CLEU.

local PLAYER_GUID

local function GetPlayerGUID()
    if not PLAYER_GUID then
        PLAYER_GUID = UnitGUID and UnitGUID("player") or ""
    end
    return PLAYER_GUID
end

-- COMBAT_LOG_EVENT_UNFILTERED subevent dispatch
local handlers = {}

-- Killing blow: sourceGUID == player, UNIT_DIED or PARTY_KILL
handlers["UNIT_DIED"] = function(...)
    local timestamp, subEvent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags = ...

    if sourceGUID == GetPlayerGUID() then
        local isPlayer = bit.band(destFlags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
        Fire(Combat._onKill, destName, destGUID, isPlayer)
    end
end

handlers["PARTY_KILL"] = handlers["UNIT_DIED"]

-- Player died
handlers["UNIT_DIED_PLAYER"] = function(...)
    -- handled via PLAYER_DEAD event instead (more reliable)
end

-- Swing crits
handlers["SWING_DAMAGE"] = function(...)
    local timestamp, subEvent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          amount, overkill, school, resisted, blocked, absorbed, critical = ...

    if sourceGUID == GetPlayerGUID() and critical then
        Fire(Combat._onCrit, amount, "Melee", true)
    end
end

-- Spell crits
handlers["SPELL_DAMAGE"]           = function(...)
    local timestamp, subEvent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          spellId, spellName, spellSchool,
          amount, overkill, school, resisted, blocked, absorbed, critical = ...

    if sourceGUID == GetPlayerGUID() and critical then
        Fire(Combat._onCrit, amount, spellName, false)
    end
end
handlers["SPELL_PERIODIC_DAMAGE"] = handlers["SPELL_DAMAGE"]
handlers["RANGE_DAMAGE"]          = handlers["SPELL_DAMAGE"]

-- Critical heals
handlers["SPELL_HEAL"] = function(...)
    local timestamp, subEvent, hideCaster,
          sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
          destGUID, destName, destFlags, destRaidFlags,
          spellId, spellName, spellSchool,
          amount, overheal, absorbed, critical = ...

    if sourceGUID == GetPlayerGUID() and critical then
        Fire(Combat._onCritHeal, amount, spellName)
    end
end
handlers["SPELL_PERIODIC_HEAL"] = handlers["SPELL_HEAL"]

-- Player takes damage
handlers["SWING_DAMAGE_LANDED_PLAYER"] = function() end  -- placeholder

local function OnCombatLogEvent(...)
    -- CombatLogGetCurrentEventInfo is the retail API; the vararg form works on both
    local _, subEvent, _, sourceGUID, _, _, _, destGUID, destName, destFlags, _,
          spellId, spellName, spellSchool, amount, _, _, _, _, _, critical

    local ok, info = pcall(CombatLogGetCurrentEventInfo)
    if not ok then return end

    subEvent    = info and select(2, CombatLogGetCurrentEventInfo()) or select(2, ...)
    sourceGUID  = info and select(4, CombatLogGetCurrentEventInfo()) or select(4, ...)
    destGUID    = info and select(8, CombatLogGetCurrentEventInfo()) or select(8, ...)
    destName    = info and select(9, CombatLogGetCurrentEventInfo()) or select(9, ...)
    destFlags   = info and select(10, CombatLogGetCurrentEventInfo()) or select(10, ...)

    local handler = handlers[subEvent]
    if handler then
        handler(CombatLogGetCurrentEventInfo())
    end

    -- Player receives damage
    if destGUID == GetPlayerGUID() then
        if subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE"
            or subEvent == "SPELL_PERIODIC_DAMAGE" or subEvent == "RANGE_DAMAGE" then
            local dmgAmount = select(12, CombatLogGetCurrentEventInfo())
            -- For SWING_DAMAGE, amount is at index 12; for SPELL it's 15.
            -- Use pcall to avoid index errors
            local ok2, dmg, sn
            ok2, dmg = pcall(function()
                if subEvent == "SWING_DAMAGE" then
                    return (select(12, CombatLogGetCurrentEventInfo()))
                else
                    return (select(15, CombatLogGetCurrentEventInfo()))
                end
            end)
            ok2, sn = pcall(function()
                if subEvent == "SWING_DAMAGE" then return "Melee"
                else return (select(13, CombatLogGetCurrentEventInfo()))
                end
            end)
            if ok2 and dmg and dmg > 0 then
                Fire(Combat._onPlayerDamaged, dmg, sn)
            end
        end

        if subEvent == "SPELL_HEAL" or subEvent == "SPELL_PERIODIC_HEAL" then
            local ok3, healAmt, _, overheal = pcall(function()
                return select(15, CombatLogGetCurrentEventInfo()),
                       select(16, CombatLogGetCurrentEventInfo()),
                       select(17, CombatLogGetCurrentEventInfo())
            end)
            local healName
            pcall(function() healName = select(13, CombatLogGetCurrentEventInfo()) end)
            if ok3 then
                Fire(Combat._onPlayerHealed, healAmt, healName, overheal)
            end
        end
    end
end

-- ── Framework event wiring ────────────────────────────────────────────────────

function Combat:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    -- If we're in combat, defer to PLAYER_REGEN_ENABLED.
    if InCombatLockdown and InCombatLockdown() then
        self._eventsInit = false
        RGX:RegisterEvent("PLAYER_REGEN_ENABLED", function()
            self:Init()
        end, "RGXCombat_Retry")
        return
    end

    PLAYER_GUID = nil  -- reset so it's fetched after login

    RGX:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        Combat._inCombat = true
        Combat._combatStartTime = GetTime and GetTime() or 0
        Fire(Combat._onEnter)
    end)

    RGX:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        Combat._inCombat = false
        Fire(Combat._onLeave)
    end)

    RGX:RegisterEvent("PLAYER_DEAD", function()
        Fire(Combat._onPlayerDied)
    end)

    if RGX:HasCapability("combatLogEvent") then
        RGX:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(...)
            if not Combat._inCombat then return end
            OnCombatLogEvent(...)
        end)
    end

    RGX:RegisterEvent("PLAYER_LOGIN", function()
        PLAYER_GUID = UnitGUID and UnitGUID("player") or ""
    end)

    -- Health threshold crossings
    RGX:RegisterEvent("UNIT_HEALTH", function(_, unit)
        if unit ~= "player" and unit ~= "target" then return end

        if unit == "player" then
            local isBelow = IsUnitBelowThreshold("player", UnitHealth, UnitHealthMax, LOW_HEALTH_PCT)
            if isBelow == nil then return end
            local prev = Combat._prevHealthPct["player"]
            if isBelow and prev ~= true then
                Fire(Combat._onLowHealth)
            end
            Combat._prevHealthPct["player"] = isBelow
        elseif unit == "target" then
            local isBelow = IsUnitBelowThreshold("target", UnitHealth, UnitHealthMax, EXECUTE_PCT)
            if isBelow == nil then return end
            local prev = Combat._prevHealthPct["target"]
            if isBelow and prev ~= true then
                Fire(Combat._onExecuteWindow)
            end
            Combat._prevHealthPct["target"] = isBelow
        end
    end)

    -- Target lost
    RGX:RegisterEvent("PLAYER_TARGET_CHANGED", function()
        if not UnitExists("target") then
            Combat._prevHealthPct["target"] = nil
            Fire(Combat._onTargetLost)
        else
            Combat._prevHealthPct["target"] = nil
        end
    end)

    -- Resource capped / low
    RGX:RegisterEvent("UNIT_POWER_UPDATE", function(_, unit)
        if unit ~= "player" then return end
        local capped, low = GetUnitPowerState("player")
        if capped then
            Fire(Combat._onResourceCapped)
        elseif low then
            Fire(Combat._onResourceLow)
        end
    end)

    -- Procs / auras
    RGX:RegisterUnitEvent("UNIT_AURA", "player", function()
        Fire(Combat._onProc)
    end, "RGXCombat_Proc")

    -- Encounter end
    RGX:RegisterEvent("ENCOUNTER_END", function(_, encounterID, encounterName, difficultyID, groupSize, success)
        Fire(Combat._onEncounterEnd, encounterID, encounterName, difficultyID, groupSize, success)
        if success == 1 then
            Fire(Combat._onEncounterVictory, encounterID, encounterName, difficultyID, groupSize)
        end
    end)

    -- PvP victory
    RGX:RegisterEvent("PVP_MATCH_COMPLETE", function()
        local isWinner = false
        if C_PvP and C_PvP.GetActiveMatchResults then
            local results = C_PvP.GetActiveMatchResults()
            isWinner = results and results.isWinner or false
        end
        if isWinner then
            Fire(Combat._onPvPVictory)
        end
    end)

    -- Reset health tracking on combat transitions
    RGX:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        Combat._prevHealthPct = {}
    end)
    RGX:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        Combat._prevHealthPct = {}
    end)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXCombat = Combat
RGX:RegisterModule("combat", Combat)
