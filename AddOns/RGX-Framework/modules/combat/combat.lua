--=====================================================================================
-- RGX-Framework | RGXCombat
-- Combat event library for any RGX-Framework addon.
-- Designed to make combat-related addon development trivially easy.
--
-- Usage (zero boilerplate):
--   local Combat = RGX:GetCombat()
--
--   Combat:OnEnter(function() print("entered combat") end)
--   Combat:OnLeave(function() print("left combat") end)
--   Combat:OnKill(function(victimName, victimGUID) ... end)
--   Combat:OnPlayerDied(function() ... end)
--   Combat:OnPlayerDamaged(function(amount, spellName) ... end)
--   Combat:OnPlayerHealed(function(amount, spellName) ... end)
--   Combat:OnCrit(function(amount, spellName) ... end)
--   Combat:OnKillingBlow(function(victimName) ... end)   -- alias: OnKill
--   Combat:OnComboPoints(function(current, max) ... end)
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

Combat._onEnter         = {}
Combat._onLeave         = {}
Combat._onKill          = {}
Combat._onPlayerDied    = {}
Combat._onPlayerDamaged = {}
Combat._onPlayerHealed  = {}
Combat._onCrit          = {}

-- ── Callback helpers ──────────────────────────────────────────────────────────

local function AddCb(list, fn)
    if type(fn) == "function" then table.insert(list, fn) end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXCombat] Callback error: " .. tostring(err)) end
    end
end

-- ── Public callback registration ─────────────────────────────────────────────

-- Fired when the player enters combat (PLAYER_REGEN_DISABLED)
function Combat:OnEnter(fn)   AddCb(self._onEnter, fn)         end

-- Fired when the player leaves combat (PLAYER_REGEN_ENABLED)
function Combat:OnLeave(fn)   AddCb(self._onLeave, fn)         end

-- Fired when the player delivers a killing blow.
-- fn(victimName, victimGUID, victimIsPlayer)
function Combat:OnKill(fn)    AddCb(self._onKill, fn)          end
Combat.OnKillingBlow = Combat.OnKill

-- Fired when the player dies.
function Combat:OnPlayerDied(fn) AddCb(self._onPlayerDied, fn) end

-- Fired when the player takes damage.
-- fn(amount, spellName, school)
function Combat:OnPlayerDamaged(fn) AddCb(self._onPlayerDamaged, fn) end

-- Fired when the player receives a heal.
-- fn(amount, spellName, overheal)
function Combat:OnPlayerHealed(fn) AddCb(self._onPlayerHealed, fn) end

-- Fired when the player scores a critical hit.
-- fn(amount, spellName, isMelee)
function Combat:OnCrit(fn)    AddCb(self._onCrit, fn)          end

-- ── State queries ─────────────────────────────────────────────────────────────

function Combat:IsInCombat()
    return self._inCombat
end

function Combat:GetDuration()
    if not self._inCombat then return 0 end
    return (GetTime and GetTime() or 0) - self._combatStartTime
end

-- ── Combat log parsing ────────────────────────────────────────────────────────

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

    RGX:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(...)
        if not Combat._inCombat then return end
        OnCombatLogEvent(...)
    end)

    RGX:RegisterEvent("PLAYER_LOGIN", function()
        PLAYER_GUID = UnitGUID and UnitGUID("player") or ""
    end)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXCombat = Combat
RGX:RegisterModule("combat", Combat)
