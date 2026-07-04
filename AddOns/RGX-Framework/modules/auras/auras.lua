--=====================================================================================
-- RGX-Framework | RGXAuras
-- Taint-safe aura scanning and watching for any RGX-Framework addon.
-- Generalizes the PlayerHasAuraSpellID pattern proven in BattlePetUtility and is
-- the core aura-trigger primitive for rgx-mod.
--
-- Built against Blizzard_APIDocumentationGenerated/UnitAuraDocumentation.lua
-- (Midnight 12.0.7). Midnight adds SECRET AURAS: on restricted units, aura
-- fields are secret values and comparing/branching on them taints execution
-- (pcall does NOT prevent taint). The safe primitives this module leans on:
--   * C_UnitAuras.GetPlayerAuraBySpellID(spellId)  -- AllowedWhenTainted
--   * UNIT_AURA UnitAuraUpdateInfo instance IDs    -- NeverSecretContents
--
-- Usage (zero boilerplate):
--   local Auras = RGX:GetAuras()
--
--   -- Player fast path (always taint-safe, BPU pattern)
--   if Auras:HasPlayerAura(33264) then ... end
--   local data = Auras:GetPlayerAura(160599)
--
--   -- Any unit (PvE-safe; on secret-restricted units returns nil/false)
--   if Auras:HasAura(spellId, "target") then ... end
--   Auras:IterateAuras("target", "HARMFUL", function(aura) ... end)
--
--   -- Watch a unit and react to changes (incremental UNIT_AURA cache)
--   Auras:WatchUnit("target")
--   Auras:OnApplied(function(unit, aura) ... end)
--   Auras:OnRemoved(function(unit, auraInstanceID) ... end)
--   Auras:OnUpdated(function(unit, aura) ... end)
--=====================================================================================

local addonName, RGX = ...

local Auras = {}

-- Watched-unit caches: cache[unit] = { byInstance = { [id] = auraData } }
-- bySpell is best-effort (spellId can be secret on restricted units); byInstance
-- is authoritative because instance IDs are never secret.
Auras._cache      = {}
Auras._watched    = {}
Auras._onApplied  = {}
Auras._onRemoved  = {}
Auras._onUpdated  = {}

-- ── Callback helpers (house pattern: AddCb returns an unsubscribe closure) ────

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
        if not ok then RGX:Debug("[RGXAuras] Callback error: " .. tostring(err)) end
    end
end

-- ── Safe C_UnitAuras access ───────────────────────────────────────────────────

local function SafeGetPlayerAuraBySpellID(spellId)
    if type(spellId) ~= "number" then return nil end
    if not C_UnitAuras or type(C_UnitAuras.GetPlayerAuraBySpellID) ~= "function" then
        return nil
    end
    local ok, auraData = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellId)
    if not ok then return nil end
    return auraData
end

local function SafeGetAuraDataByIndex(unit, index, filter)
    if not C_UnitAuras or type(C_UnitAuras.GetAuraDataByIndex) ~= "function" then
        return nil
    end
    local ok, auraData = pcall(C_UnitAuras.GetAuraDataByIndex, unit, index, filter)
    if not ok then return nil end
    return auraData
end

local function SafeGetAuraDataByInstanceID(unit, auraInstanceID)
    if not C_UnitAuras or type(C_UnitAuras.GetAuraDataByAuraInstanceID) ~= "function" then
        return nil
    end
    local ok, auraData = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, auraInstanceID)
    if not ok then return nil end
    return auraData
end

-- Compare a (possibly secret) aura field to a wanted value entirely inside a
-- pcall boundary. On secret-restricted units the comparison itself errors or
-- taints-and-errors; pcall converts that to "no match" so callers stay safe
-- and simply see nil/false for restricted units.
local function AuraMatchesSpellID(auraData, spellId)
    local ok, matches = pcall(function()
        return auraData ~= nil and auraData.spellId == spellId
    end)
    return ok and matches == true
end

-- ── Query API ─────────────────────────────────────────────────────────────────

-- Player fast path. Always taint-safe (SecretArguments = AllowedWhenTainted).
function Auras:GetPlayerAura(spellId)
    return SafeGetPlayerAuraBySpellID(spellId)
end

function Auras:HasPlayerAura(spellId)
    return SafeGetPlayerAuraBySpellID(spellId) ~= nil
end

-- Enumerate a unit's auras. filter is an AuraFilters string ("HELPFUL",
-- "HARMFUL", combinations); nil enumerates HELPFUL then HARMFUL.
-- callback(auraData) — return false to stop iteration early.
function Auras:IterateAuras(unit, filter, callback)
    if type(callback) ~= "function" then return 0 end
    unit = unit or "player"

    local filters = filter and { filter } or { "HELPFUL", "HARMFUL" }
    local visited = 0
    for _, f in ipairs(filters) do
        local index = 1
        while true do
            local auraData = SafeGetAuraDataByIndex(unit, index, f)
            if not auraData then break end
            visited = visited + 1
            local ok, keepGoing = pcall(callback, auraData)
            if not ok then
                RGX:Debug("[RGXAuras] IterateAuras callback error: " .. tostring(keepGoing))
            elseif keepGoing == false then
                return visited
            end
            index = index + 1
        end
    end
    return visited
end

-- Find an aura by spellId on any unit. Uses the player fast path when possible,
-- otherwise scans. On secret-restricted units this returns nil by design —
-- the module never leaks a taint-triggering comparison to the caller.
function Auras:GetAura(spellId, unit)
    if type(spellId) ~= "number" then return nil end
    unit = unit or "player"

    if unit == "player" then
        return SafeGetPlayerAuraBySpellID(spellId)
    end

    local found = nil
    self:IterateAuras(unit, nil, function(auraData)
        if AuraMatchesSpellID(auraData, spellId) then
            found = auraData
            return false
        end
    end)
    return found
end

function Auras:HasAura(spellId, unit)
    return self:GetAura(spellId, unit) ~= nil
end

-- ── Watching (incremental UNIT_AURA cache) ────────────────────────────────────

local function RebuildUnitCache(unit)
    local byInstance = {}
    Auras:IterateAuras(unit, nil, function(auraData)
        local ok, id = pcall(function() return auraData.auraInstanceID end)
        if ok and type(id) == "number" then
            byInstance[id] = auraData
        end
    end)
    Auras._cache[unit] = { byInstance = byInstance }
end

local function HandleUnitAura(unit, updateInfo)
    local cache = Auras._cache[unit]
    if not cache then return end

    if not updateInfo or updateInfo.isFullUpdate then
        RebuildUnitCache(unit)
        return
    end

    -- removedAuraInstanceIDs / updatedAuraInstanceIDs are NeverSecretContents.
    if updateInfo.removedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.removedAuraInstanceIDs) do
            cache.byInstance[id] = nil
            Fire(Auras._onRemoved, unit, id)
        end
    end

    if updateInfo.addedAuras then
        for _, auraData in ipairs(updateInfo.addedAuras) do
            local ok, id = pcall(function() return auraData.auraInstanceID end)
            if ok and type(id) == "number" then
                cache.byInstance[id] = auraData
                Fire(Auras._onApplied, unit, auraData)
            end
        end
    end

    if updateInfo.updatedAuraInstanceIDs then
        for _, id in ipairs(updateInfo.updatedAuraInstanceIDs) do
            local auraData = SafeGetAuraDataByInstanceID(unit, id)
            if auraData then
                cache.byInstance[id] = auraData
                Fire(Auras._onUpdated, unit, auraData)
            end
        end
    end
end

-- Watch a unit: keeps an incremental aura cache and fires
-- OnApplied/OnRemoved/OnUpdated for it. Idempotent per unit.
function Auras:WatchUnit(unit)
    if type(unit) ~= "string" or unit == "" then return false end
    if self._watched[unit] then return true end
    self._watched[unit] = true

    RebuildUnitCache(unit)
    RGX:RegisterUnitEvent("UNIT_AURA", unit, function(_, eventUnit, updateInfo)
        HandleUnitAura(eventUnit or unit, updateInfo)
    end, "RGXAuras_" .. unit)
    return true
end

function Auras:UnwatchUnit(unit)
    if not self._watched[unit] then return false end
    self._watched[unit] = nil
    self._cache[unit] = nil
    RGX:UnregisterUnitEvent("UNIT_AURA", "RGXAuras_" .. unit)
    return true
end

-- Cached lookup for a watched unit (falls back to a live scan when unwatched).
function Auras:GetAuraByInstanceID(unit, auraInstanceID)
    unit = unit or "player"
    local cache = self._cache[unit]
    if cache and cache.byInstance[auraInstanceID] then
        return cache.byInstance[auraInstanceID]
    end
    return SafeGetAuraDataByInstanceID(unit, auraInstanceID)
end

-- ── Change callbacks (fire only for watched units) ────────────────────────────

function Auras:OnApplied(fn) return AddCb(self._onApplied, fn) end
function Auras:OnRemoved(fn) return AddCb(self._onRemoved, fn) end
function Auras:OnUpdated(fn) return AddCb(self._onUpdated, fn) end

-- ── Init ──────────────────────────────────────────────────────────────────────

function Auras:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    -- Player is watched by default — it is the unit every consumer cares about
    -- and the one whose auras are never secret to the player.
    self:WatchUnit("player")
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXAuras = Auras
RGX:RegisterModule("auras", Auras)
