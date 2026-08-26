--=====================================================================================
-- RGX-Framework | RGXAuras
-- Aura scanning and watching through an accessible-only boundary.
-- Generalizes the PlayerHasAuraSpellID pattern proven in BattlePetUtility and is
-- the core aura-trigger primitive for rgx-mod.
--
-- Built against the six pinned client-source baselines documented in AURAS.md.
-- Potentially secret event values and AuraData remain opaque until Blizzard's
-- access and aura-specific predicates approve them. Denied or unverifiable data
-- is never indexed, compared, cached, formatted, or forwarded to consumers.
--
-- Usage (zero boilerplate):
--   local Auras = RGX:GetAuras()
--
--   -- Player fast path (always taint-safe, BPU pattern)
--   if Auras:HasPlayerAura(33264) then ... end
--   local data = Auras:GetPlayerAura(160599)
--
--   -- Any-unit results are delivered only while their aura data is accessible.
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

-- Watched-unit caches contain only predicate-approved snapshots. A denied event
-- invalidates and empties the cache without synthesizing removal callbacks.
Auras._cache      = {}
Auras._watched    = {}
Auras._onApplied  = {}
Auras._onRemoved  = {}
Auras._onUpdated  = {}
Auras._generations = {}
Auras._callbackQueue = {}
Auras._dispatchingCallbacks = false

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

local function CanAccessValue(value)
    local api = RGX.API
    return type(api) == "table"
        and type(api.CanAccessValue) == "function"
        and api.CanAccessValue(value) == true
end

local function CanAccessTable(value)
    local api = RGX.API
    return type(api) == "table"
        and type(api.CanAccessTable) == "function"
        and api.CanAccessTable(value) == true
end

local function DebugError(prefix, err)
    if CanAccessValue(err) then
        RGX:Debug(prefix .. tostring(err))
    else
        RGX:Debug(prefix .. "<inaccessible error>")
    end
end

local function NextGeneration(unit)
    local generation = (Auras._generations[unit] or 0) + 1
    Auras._generations[unit] = generation
    return generation
end

local function IsCurrentBatch(batch)
    local cache = Auras._cache[batch.unit]
    return type(cache) == "table"
        and cache.valid == true
        and cache.generation == batch.generation
end

local function QueueCallbacks(unit, generation, actions)
    if #actions == 0 then return end
    Auras._callbackQueue[#Auras._callbackQueue + 1] = {
        unit = unit,
        generation = generation,
        actions = actions,
    }
    if Auras._dispatchingCallbacks then return end

    Auras._dispatchingCallbacks = true
    local index = 1
    while index <= #Auras._callbackQueue do
        local batch = Auras._callbackQueue[index]
        index = index + 1
        for _, action in ipairs(batch.actions) do
            if not IsCurrentBatch(batch) then break end
            for _, fn in ipairs(action.callbacks) do
                if not IsCurrentBatch(batch) then break end
                local ok, err = pcall(fn, batch.unit, action.value)
                if not ok then DebugError("[RGXAuras] Callback error: ", err) end
            end
        end
    end
    Auras._callbackQueue = {}
    Auras._dispatchingCallbacks = false
end

local function NormalizeUnit(unit)
    if type(unit) == "nil" then
        return "player"
    end
    if not CanAccessValue(unit) or type(unit) ~= "string" or unit == "" then
        return nil
    end
    return unit
end

local function IsValidSpellID(spellID)
    return CanAccessValue(spellID) and type(spellID) == "number"
end

local function IsValidInstanceID(auraInstanceID)
    return CanAccessValue(auraInstanceID)
        and type(auraInstanceID) == "number"
        and auraInstanceID == auraInstanceID
        and auraInstanceID > 0
        and auraInstanceID < math.huge
end

local function IsIndexQueryAccessible(unit, index, filter)
    local predicate = RGX.API and RGX.API.ShouldUnitAuraIndexBeSecret
    return type(predicate) == "function" and predicate(unit, index, filter) == false
end

local function IsInstanceQueryAccessible(unit, auraInstanceID)
    local predicate = RGX.API and RGX.API.ShouldUnitAuraInstanceBeSecret
    return type(predicate) == "function" and predicate(unit, auraInstanceID) == false
end

-- ── Guarded C_UnitAuras access ────────────────────────────────────────────────

local function SafeGetPlayerAuraBySpellID(spellId)
    if not IsValidSpellID(spellId) then return nil end
    local getter = RGX.API and RGX.API.GetPlayerAuraBySpellID
    if type(getter) ~= "function" then return nil end
    local ok, auraData = pcall(getter, spellId)
    if not ok or type(auraData) == "nil" or not CanAccessTable(auraData) then
        return nil
    end
    return auraData
end

local function SafeGetAuraDataByIndex(unit, index, filter)
    if not IsIndexQueryAccessible(unit, index, filter) then
        return nil, "restricted"
    end
    local getter = RGX.API and RGX.API.UnitAura
    if type(getter) ~= "function" then return nil, "restricted" end
    local ok, auraData, accessStatus = pcall(getter, unit, index, filter)
    if not ok then return nil, "restricted" end
    if accessStatus == "restricted" then return nil, "restricted" end
    if type(auraData) == "nil" then
        return nil, accessStatus == "missing" and "missing" or "restricted"
    end
    if not CanAccessTable(auraData) then return nil, "restricted" end
    return auraData, "accessible"
end

local function SafeGetAuraDataByInstanceID(unit, auraInstanceID)
    if not IsValidInstanceID(auraInstanceID)
        or not IsInstanceQueryAccessible(unit, auraInstanceID) then
        return nil, "restricted"
    end
    local getter = RGX.API and RGX.API.GetAuraDataByInstanceID
    if type(getter) ~= "function" then return nil, "restricted" end
    local ok, auraData, accessStatus = pcall(getter, unit, auraInstanceID)
    if not ok then return nil, "restricted" end
    if accessStatus == "restricted" then return nil, "restricted" end
    if type(auraData) == "nil" then
        return nil, accessStatus == "missing" and "missing" or "restricted"
    end
    if not CanAccessTable(auraData) then return nil, "restricted" end
    return auraData, "accessible"
end

local function AuraMatchesSpellID(auraData, spellId)
    if not CanAccessTable(auraData) then return false end
    local auraSpellID = auraData.spellId
    return CanAccessValue(auraSpellID)
        and type(auraSpellID) == "number"
        and auraSpellID == spellId
end

-- ── Query API ─────────────────────────────────────────────────────────────────

-- The native player lookup is AllowedWhenTainted and RequiresNonSecretAura, so
-- a restricted match is represented as no result rather than exposed data.
function Auras:GetPlayerAura(spellId)
    return SafeGetPlayerAuraBySpellID(spellId)
end

function Auras:HasPlayerAura(spellId)
    return type(SafeGetPlayerAuraBySpellID(spellId)) ~= "nil"
end

local function IterateAccessibleAuras(unit, filters, callback)
    local visited = 0
    for _, f in ipairs(filters) do
        local index = 1
        while true do
            local auraData, status = SafeGetAuraDataByIndex(unit, index, f)
            if status == "missing" then break end
            if status ~= "accessible" then return visited, false end

            visited = visited + 1
            local ok, keepGoing = pcall(callback, auraData)
            if not ok then
                DebugError("[RGXAuras] IterateAuras callback error: ", keepGoing)
            elseif type(keepGoing) ~= "nil" then
                if not CanAccessValue(keepGoing) then return visited, false end
                if keepGoing == false then return visited, true end
            end
            index = index + 1
        end
    end
    return visited, true
end

-- Enumerate accessible aura snapshots. A restricted or unverifiable entry ends
-- the scan before it can reach the callback.
function Auras:IterateAuras(unit, filter, callback)
    if type(callback) ~= "function" then return 0 end
    unit = NormalizeUnit(unit)
    if type(unit) == "nil" then return 0 end

    local filters
    if type(filter) == "nil" then
        filters = { "HELPFUL", "HARMFUL" }
    elseif CanAccessValue(filter) and type(filter) == "string" and filter ~= "" then
        filters = { filter }
    else
        return 0
    end

    local visited = IterateAccessibleAuras(unit, filters, callback)
    return visited
end

-- Find an accessible aura by spellId. Current Retail/Classic clients provide a
-- RequiresNonSecretAura lookup; verified legacy clients use the guarded scan.
function Auras:GetAura(spellId, unit)
    if not IsValidSpellID(spellId) then return nil end
    unit = NormalizeUnit(unit)
    if type(unit) == "nil" then return nil end

    if unit == "player" then
        return SafeGetPlayerAuraBySpellID(spellId)
    end

    if RGX:HasCapability("unitAuraBySpell") then
        local getter = RGX.API and RGX.API.GetUnitAuraBySpellID
        if type(getter) ~= "function" then return nil end
        local ok, auraData = pcall(getter, unit, spellId)
        if not ok or type(auraData) == "nil" or not CanAccessTable(auraData) then
            return nil
        end
        return auraData
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
    return type(self:GetAura(spellId, unit)) ~= "nil"
end

-- ── Watching (incremental UNIT_AURA cache) ────────────────────────────────────

local function RebuildUnitCache(unit)
    local byInstance = {}
    local cacheSafe = true
    local _, complete = IterateAccessibleAuras(unit, { "HELPFUL", "HARMFUL" }, function(auraData)
        local id = auraData.auraInstanceID
        if type(id) == "nil" then return end
        if not IsValidInstanceID(id) or not IsInstanceQueryAccessible(unit, id) then
            cacheSafe = false
            return false
        end
        byInstance[id] = auraData
    end)

    if not complete or not cacheSafe then
        Auras._cache[unit] = {
            byInstance = {},
            valid = false,
            generation = NextGeneration(unit),
        }
        return false
    end

    Auras._cache[unit] = {
        byInstance = byInstance,
        valid = true,
        generation = NextGeneration(unit),
    }
    return true
end

local function InvalidateUnitCache(unit)
    Auras._cache[unit] = {
        byInstance = {},
        valid = false,
        generation = NextGeneration(unit),
    }
end

local function InvalidateWatchedCaches()
    for unit in pairs(Auras._watched) do
        InvalidateUnitCache(unit)
    end
end

local function EnsureRestrictedEventGuard()
    if Auras._restrictedEventGuard then return true end
    local handlerID = RGX:RegisterEvent("UNIT_AURA", function(_, eventUnit)
        if not CanAccessValue(eventUnit) then
            InvalidateWatchedCaches()
        end
    end, "RGXAuras_RestrictedGuard")
    if type(handlerID) ~= "string" then return false end
    Auras._restrictedEventGuard = handlerID
    return true
end

local function IsAuraEventAccessible()
    local predicate = RGX.API and RGX.API.ShouldAurasBeSecret
    return type(predicate) == "function" and predicate() == false
end

local function ReadIDList(values)
    if type(values) == "nil" then return {}, true end
    if not CanAccessTable(values) then return nil, false end

    local result = {}
    for _, id in ipairs(values) do
        if not IsValidInstanceID(id) then return nil, false end
        result[#result + 1] = id
    end
    return result, true
end

local function ReadAddedAuras(unit, values)
    if type(values) == "nil" then return {}, true end
    if not CanAccessTable(values) then return nil, false end

    local result = {}
    for _, auraData in ipairs(values) do
        if not CanAccessTable(auraData) then return nil, false end
        local id = auraData.auraInstanceID
        if not IsValidInstanceID(id) or not IsInstanceQueryAccessible(unit, id) then
            return nil, false
        end
        result[#result + 1] = { id = id, auraData = auraData }
    end
    return result, true
end

local function ReadUpdatedAuras(unit, values)
    local ids, idsSafe = ReadIDList(values)
    if not idsSafe then return nil, false end

    local result = {}
    for _, id in ipairs(ids) do
        local auraData, status = SafeGetAuraDataByInstanceID(unit, id)
        if status == "restricted" then return nil, false end
        result[#result + 1] = {
            id = id,
            auraData = auraData,
            status = status,
        }
    end
    return result, true
end

local function HandleUnitAura(unit, updateInfo)
    local cache = Auras._cache[unit]
    if type(cache) ~= "table" then return end

    -- UNIT_AURA itself is secret-qualified on restricted Retail clients. Do not
    -- inspect its payload until the event-wide predicate says it is accessible.
    if not IsAuraEventAccessible() then
        InvalidateUnitCache(unit)
        return
    end

    if type(updateInfo) == "nil" then
        RebuildUnitCache(unit)
        return
    end
    if not CanAccessTable(updateInfo) then
        InvalidateUnitCache(unit)
        return
    end

    local isFullUpdate = updateInfo.isFullUpdate
    if not CanAccessValue(isFullUpdate) or type(isFullUpdate) ~= "boolean" then
        InvalidateUnitCache(unit)
        return
    end
    if isFullUpdate then
        RebuildUnitCache(unit)
        return
    end

    if cache.valid ~= true then
        RebuildUnitCache(unit)
        return
    end

    -- Validate the complete delta before mutating the cache or firing callbacks.
    local removed, removedSafe = ReadIDList(updateInfo.removedAuraInstanceIDs)
    local added, addedSafe = ReadAddedAuras(unit, updateInfo.addedAuras)
    local updated, updatedSafe = ReadUpdatedAuras(unit, updateInfo.updatedAuraInstanceIDs)
    if not removedSafe or not addedSafe or not updatedSafe then
        InvalidateUnitCache(unit)
        return
    end

    -- Publish the complete cache mutation before any consumer can reenter. A
    -- newer nested event advances the generation and stops this callback batch.
    local generation = NextGeneration(unit)
    cache.generation = generation
    local actions = {}
    for _, id in ipairs(removed) do
        cache.byInstance[id] = nil
        actions[#actions + 1] = { callbacks = Auras._onRemoved, value = id }
    end
    for _, item in ipairs(added) do
        cache.byInstance[item.id] = item.auraData
        actions[#actions + 1] = { callbacks = Auras._onApplied, value = item.auraData }
    end
    for _, item in ipairs(updated) do
        if item.status == "accessible" then
            cache.byInstance[item.id] = item.auraData
            actions[#actions + 1] = { callbacks = Auras._onUpdated, value = item.auraData }
        else
            cache.byInstance[item.id] = nil
        end
    end
    QueueCallbacks(unit, generation, actions)
end

-- Watch a unit: keeps an incremental aura cache and fires
-- OnApplied/OnRemoved/OnUpdated for it. Idempotent per unit.
function Auras:WatchUnit(unit)
    if type(unit) == "nil" then return false end
    unit = NormalizeUnit(unit)
    if type(unit) == "nil" then return false end
    if self._watched[unit] then return true end
    if not EnsureRestrictedEventGuard() then return false end
    self._watched[unit] = true

    RebuildUnitCache(unit)
    local handlerID = RGX:RegisterUnitEvent("UNIT_AURA", unit, function(_, _, updateInfo)
        HandleUnitAura(unit, updateInfo)
    end, "RGXAuras_" .. unit)
    if type(handlerID) ~= "string" then
        self._watched[unit] = nil
        self._cache[unit] = nil
        return false
    end
    return true
end

function Auras:UnwatchUnit(unit)
    if type(unit) == "nil" then return false end
    unit = NormalizeUnit(unit)
    if type(unit) == "nil" then return false end
    if not self._watched[unit] then return false end
    self._watched[unit] = nil
    NextGeneration(unit)
    self._cache[unit] = nil
    RGX:UnregisterUnitEvent("UNIT_AURA", "RGXAuras_" .. unit)
    return true
end

-- Cached lookup for a watched unit (falls back to a live scan when unwatched).
function Auras:GetAuraByInstanceID(unit, auraInstanceID)
    unit = NormalizeUnit(unit)
    if type(unit) == "nil" or not IsValidInstanceID(auraInstanceID) then
        return nil
    end
    if not IsInstanceQueryAccessible(unit, auraInstanceID) then
        if self._watched[unit] then InvalidateUnitCache(unit) end
        return nil
    end

    local cache = self._cache[unit]
    if RGX:HasCapability("auraByInstance") then
        local auraData, status = SafeGetAuraDataByInstanceID(unit, auraInstanceID)
        if status == "accessible" then
            if type(cache) == "table" and cache.valid == true then
                cache.byInstance[auraInstanceID] = auraData
            end
            return auraData
        end
        if type(cache) == "table" and cache.valid == true then
            cache.byInstance[auraInstanceID] = nil
        end
        if status == "restricted" and self._watched[unit] then
            InvalidateUnitCache(unit)
        end
        return nil
    end

    if type(cache) == "table" and cache.valid == true then
        local cached = cache.byInstance[auraInstanceID]
        if type(cached) ~= "nil" and CanAccessTable(cached) then
            return cached
        end
    end
    return nil
end

-- ── Change callbacks (fire only for watched units) ────────────────────────────

function Auras:OnApplied(fn) return AddCb(self._onApplied, fn) end
function Auras:OnRemoved(fn) return AddCb(self._onRemoved, fn) end
function Auras:OnUpdated(fn) return AddCb(self._onUpdated, fn) end

-- ── Init ──────────────────────────────────────────────────────────────────────

function Auras:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    -- Player is watched by default. Restricted events are suppressed, while the
    -- dedicated player spell lookup remains available for non-secret auras.
    self:WatchUnit("player")
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXAuras = Auras
RGX:RegisterModule("auras", Auras)
