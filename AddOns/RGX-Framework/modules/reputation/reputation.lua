--=====================================================================================
-- RGX-Framework | RGXReputation
-- Reputation and Renown tracking library for any RGX-Framework addon.
-- Normalizes WoW's hostile reputation API so addons don't need to.
--
-- WoW's C_Reputation API differs significantly between expansions and
-- between classic/retail — this module handles all of that complexity.
--
-- Usage (zero boilerplate):
--   local Rep = RGX:GetReputation()
--
--   Rep:OnRankUp(function(factionName, factionID, oldRank, newRank)
--       print(factionName .. " rank up: " .. oldRank .. " -> " .. newRank)
--   end)
--
--   Rep:OnGain(function(factionName, factionID, amount, newTotal)
--       -- fires on every rep tick
--   end)
--
--   Rep:OnRenownUp(function(factionName, factionID, oldLevel, newLevel)
--       -- retail: major factions (Dragonscale Expedition, etc.)
--   end)
--
--   Rep:GetAll()           -- returns flat array of { id, name, standing, value, max }
--   Rep:Get(factionID)     -- single faction data
--   Rep:GetByName(name)    -- lookup by faction name
--   Rep:IsMaxed(factionID) -- true if Exalted (or max renown)
--
-- Rank constants (exported as Rep.Ranks):
--   Hated=1, Hostile=2, Unfriendly=3, Neutral=4,
--   Friendly=5, Honored=6, Revered=7, Exalted=8
--=====================================================================================

local addonName, RGX = ...

local Rep = {}

-- ── Constants ─────────────────────────────────────────────────────────────────

Rep.Ranks = {
    [1] = "Hated",
    [2] = "Hostile",
    [3] = "Unfriendly",
    [4] = "Neutral",
    [5] = "Friendly",
    [6] = "Honored",
    [7] = "Revered",
    [8] = "Exalted",
}

local SCAN_DELAY = 0.10

-- ── State ─────────────────────────────────────────────────────────────────────

Rep._factions     = {}   -- [name]       = { id, standing, value }
Rep._factionsById = {}   -- [id]         = { name, standing, value, max }
Rep._renown       = {}   -- [factionID]  = { level }
Rep._pendingScan  = false
Rep._eventsInit   = false

Rep._onRankUp    = {}
Rep._onGain      = {}
Rep._onRenownUp  = {}

-- ── Callback helpers ──────────────────────────────────────────────────────────

local function AddCb(list, fn)
    if type(fn) == "function" then table.insert(list, fn) end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXReputation] Callback error: " .. tostring(err)) end
    end
end

-- ── Public callback registration ─────────────────────────────────────────────

-- fn(factionName, factionID, oldRankIndex, newRankIndex)
function Rep:OnRankUp(fn)   AddCb(self._onRankUp, fn)   end

-- fn(factionName, factionID, amount, newTotal)
function Rep:OnGain(fn)     AddCb(self._onGain, fn)     end

-- fn(factionName, factionID, oldLevel, newLevel)  — retail only
function Rep:OnRenownUp(fn) AddCb(self._onRenownUp, fn) end

-- ── Scan helpers ──────────────────────────────────────────────────────────────

local function GetFactionDataRetail(index)
    if C_Reputation and C_Reputation.GetFactionDataByIndex then
        local ok, d = pcall(C_Reputation.GetFactionDataByIndex, index)
        if ok and d then return d end
    end
    return nil
end

local function GetFactionCount()
    if C_Reputation and C_Reputation.GetNumFactions then
        local ok, n = pcall(C_Reputation.GetNumFactions)
        return ok and n or 0
    end
    return 0
end

-- Scan and cache all faction standings
function Rep:Scan()
    local count = GetFactionCount()
    for i = 1, count do
        local d = GetFactionDataRetail(i)
        if d and d.name and d.reaction then
            local id   = d.factionID or 0
            local name = d.name

            self._factions[name] = {
                id       = id,
                standing = d.reaction,
                value    = d.currentStanding or 0,
            }

            if id and id > 0 then
                self._factionsById[id] = {
                    name     = name,
                    standing = d.reaction,
                    value    = d.currentStanding or 0,
                    max      = d.nextReactionThreshold or 0,
                    index    = i,
                }
            end
        end
    end

    -- Renown (retail TWW/DF major factions)
    if C_MajorFactions and C_MajorFactions.GetMajorFactionIDs then
        local ok, ids = pcall(C_MajorFactions.GetMajorFactionIDs, LE_EXPANSION_LEVEL_CURRENT or 9)
        if ok and ids then
            for _, fid in ipairs(ids) do
                local ok2, data = pcall(C_MajorFactions.GetMajorFactionData, fid)
                if ok2 and data then
                    self._renown[fid] = {
                        level = data.renownLevel or 0,
                        name  = data.name or ("Faction " .. fid),
                    }
                end
            end
        end
    end
end

-- ── Check for changes since last scan ────────────────────────────────────────

function Rep:CheckChanges()
    local count = GetFactionCount()

    for i = 1, count do
        local d = GetFactionDataRetail(i)
        if d and d.name and d.reaction then
            local id   = d.factionID or 0
            local name = d.name
            local old  = self._factions[name]

            local oldStanding = old and old.standing or 0
            local oldValue    = old and old.value    or 0
            local newStanding = d.reaction
            local newValue    = d.currentStanding or 0

            -- Rep gained (value went up within same rank, or rank changed)
            if newValue > oldValue or newStanding > oldStanding then
                local gained = newValue - oldValue
                if newStanding > oldStanding then
                    -- crossed a threshold; gained = (max of old rank - old value) + new value
                    gained = newValue
                end
                if gained > 0 then
                    Fire(self._onGain, name, id, gained, newValue)
                end
            end

            -- Rank up
            if newStanding > oldStanding then
                Fire(self._onRankUp, name, id, oldStanding, newStanding)
            end

            -- Update cache
            self._factions[name] = { id = id, standing = newStanding, value = newValue }
            if id and id > 0 then
                self._factionsById[id] = {
                    name     = name,
                    standing = newStanding,
                    value    = newValue,
                    max      = d.nextReactionThreshold or 0,
                    index    = i,
                }
            end
        end
    end

    -- Renown changes
    if C_MajorFactions and C_MajorFactions.GetMajorFactionIDs then
        local ok, ids = pcall(C_MajorFactions.GetMajorFactionIDs, LE_EXPANSION_LEVEL_CURRENT or 9)
        if ok and ids then
            for _, fid in ipairs(ids) do
                local ok2, data = pcall(C_MajorFactions.GetMajorFactionData, fid)
                if ok2 and data then
                    local oldLevel = self._renown[fid] and self._renown[fid].level or 0
                    local newLevel = data.renownLevel or 0
                    if newLevel > oldLevel then
                        local fname = data.name or ("Faction " .. fid)
                        Fire(self._onRenownUp, fname, fid, oldLevel, newLevel)
                        self._renown[fid] = { level = newLevel, name = fname }
                    end
                end
            end
        end
    end
end

function Rep:_QueueCheck()
    if self._pendingScan then return end
    self._pendingScan = true
    if C_Timer and C_Timer.After then
        C_Timer.After(SCAN_DELAY, function()
            self._pendingScan = false
            self:CheckChanges()
        end)
    else
        self._pendingScan = false
        self:CheckChanges()
    end
end

-- ── Public accessors ──────────────────────────────────────────────────────────

-- Returns array of all known factions: { id, name, standing, rankName, value }
function Rep:GetAll()
    local result = {}
    for id, data in pairs(self._factionsById) do
        table.insert(result, {
            id       = id,
            name     = data.name,
            standing = data.standing,
            rankName = self.Ranks[data.standing] or "Unknown",
            value    = data.value,
            max      = data.max,
        })
    end
    table.sort(result, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    return result
end

-- Returns data for a single faction by numeric ID
function Rep:Get(factionID)
    return self._factionsById[factionID]
end

-- Case-insensitive name lookup
function Rep:GetByName(name)
    local lower = string.lower(name)
    for fname, data in pairs(self._factions) do
        if string.lower(fname) == lower then
            return data
        end
    end
    return nil
end

function Rep:IsMaxed(factionID)
    local d = self._factionsById[factionID]
    return d and d.standing == 8
end

-- Returns all renown data: { [factionID] = { level, name } }
function Rep:GetRenown()
    return self._renown
end

-- ── Init ──────────────────────────────────────────────────────────────────────

function Rep:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("UPDATE_FACTION", function()
        Rep:_QueueCheck()
    end)

    RGX:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        Rep:Scan()
    end)

    RGX:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function()
        Rep:_QueueCheck()
    end)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXReputation = Rep
RGX:RegisterModule("reputation", Rep)
