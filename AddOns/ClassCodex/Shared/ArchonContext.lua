local _, ns = ...

-------------------------------------------------------------------------------
-- ArchonContext: Archon per-encounter build accessors + zone auto-detection.
--
-- The Archon scraper writes Data\{Class}\archon-talents.lua files keyed by
-- "zoneType:difficulty:encounter" (e.g. "mythic-plus:high-keys:skyreach",
-- "raid:mythic:imperator"). This module provides:
--
--   - ns.GetArchonSpecData(class, spec) — full per-spec record from the
--     ClassCodexArchonData global, or nil.
--   - ns.GroupArchonContexts(specData) — bucketed view: { mplusOverview,
--     mplusDungeons[], raidOverviewHeroic, raidOverviewMythic,
--     raidHeroicBosses[], raidMythicBosses[] }.
--   - ns.FindArchonBuild(class, spec, contextKey) — the single best build
--     stored for that context (the scraper picks the highest-popularity
--     main entry per page).
--   - ns.GetActiveArchonContext() — heuristic match from the player's
--     current zone / current pull to a contextKey, or nil if unknown.
--   - ns.RegisterArchonContextCallback(fn) — fires whenever the active
--     context changes so the talent pane / Compendium can refresh their
--     auto-pick.
--
-- Slug↔ID mapping is hand-curated below. Slugs change at season
-- transitions; updating one season's worth of dungeons + bosses is a
-- small recurring chore documented near the table itself.
-------------------------------------------------------------------------------

local ARCHON_DATA = _G.ClassCodexArchonData

-- Re-resolve at use time too — toc load order means the global may not
-- be present at this file's load (we are listed after the data files,
-- but be defensive in case that ever changes).
local function GetArchonGlobal()
    return ARCHON_DATA or _G.ClassCodexArchonData
end

-------------------------------------------------------------------------------
-- Slug → in-game ID lookup
--
-- Update once per season transition. Sources:
--   - Dungeon mapID: GetInstanceInfo() returns it as the 8th return.
--     Open the dungeon and run /run print(select(8, GetInstanceInfo()))
--   - Boss encounterID: ENCOUNTER_START fires with encounterID as arg #1.
--     Pull the boss in LFR / open Adventure Guide.
-- Entries with id = 0 fall through to name-matching, which works on
-- enUS clients only. For non-English clients, fill in the IDs.
-------------------------------------------------------------------------------

-- Manaforge Omega season — TWW Season 3. The `name` field doubles as
-- the display label override: Archon abbreviates names in its encounter
-- dropdown ("Magisters'" instead of "Magisters' Terrace"), so we render
-- the in-game full name from this table instead of the bare metadata.
local DUNGEON_BY_SLUG = {
    ["algethar-academy"]    = { id = 0, name = "Algeth'ar Academy" },
    ["magisters"]           = { id = 0, name = "Magisters' Terrace" },
    ["maisara-caverns"]     = { id = 0, name = "Mai'sara Caverns" },
    ["nexus-point-xenas"]   = { id = 0, name = "Nexus-Point Xenas" },
    ["pit-of-saron"]        = { id = 0, name = "Pit of Saron" },
    ["seat"]                = { id = 0, name = "Seat of the Triumvirate" },
    ["skyreach"]            = { id = 0, name = "Skyreach" },
    ["windrunner-spire"]    = { id = 0, name = "Windrunner Spire" },
}

-- Fast lookup for display-label resolution.
local DUNGEON_DISPLAY = {}
for slug, info in pairs(DUNGEON_BY_SLUG) do DUNGEON_DISPLAY[slug] = info.name end
local BOSS_DISPLAY = {}

-- Manaforge Omega raid bosses.
local RAID_BOSS_BY_SLUG = {
    ["imperator"]      = { id = 0, name = "Imperator" },
    ["vorasius"]       = { id = 0, name = "Vorasius" },
    ["salhadaar"]      = { id = 0, name = "Salhadaar" },
    ["vaelgor-ezzorak"]= { id = 0, name = "Vaelgor & Ezzorak" },
    ["vanguard"]       = { id = 0, name = "Vanguard" },
    ["crown"]          = { id = 0, name = "Crown" },
    ["chimaerus"]      = { id = 0, name = "Chimaerus" },
    ["beloren"]        = { id = 0, name = "Belo'ren" },
    ["midnight-falls"] = { id = 0, name = "Midnight Falls" },
}
for slug, info in pairs(RAID_BOSS_BY_SLUG) do BOSS_DISPLAY[slug] = info.name end

-- Public helper: resolves the display label for a context. The scraper
-- now extracts the full in-game name from the Archon page's
-- seo.description and stamps it onto encounterLabel, so we just trust
-- it. The slug-keyed *_DISPLAY tables still serve the auto-detect
-- name-match path on non-localised clients.
function ns.GetArchonEncounterLabel(ctx)
    if not ctx then return "" end
    if ctx.encounterLabel and ctx.encounterLabel ~= "" then
        return ctx.encounterLabel
    end
    local slug = ctx.encounter
    if slug and DUNGEON_DISPLAY[slug] then return DUNGEON_DISPLAY[slug] end
    if slug and BOSS_DISPLAY[slug] then return BOSS_DISPLAY[slug] end
    return ""
end

-- Pull order for the current raid. Archon serves bosses in this order
-- in its encounter dropdown; storing it explicitly here lets us match
-- without depending on JSON key ordering (Lua tables don't preserve
-- string-key insertion order). Update once per raid release.
local RAID_BOSS_ORDER = {
    "imperator",
    "vorasius",
    "salhadaar",
    "vaelgor-ezzorak",
    "vanguard",
    "crown",
    "chimaerus",
    "beloren",
    "midnight-falls",
}
local RAID_BOSS_RANK = {}
for i, slug in ipairs(RAID_BOSS_ORDER) do RAID_BOSS_RANK[slug] = i end

-- Reverse lookups, populated lazily.
local DUNGEON_BY_ID, DUNGEON_BY_NAME
local BOSS_BY_ID, BOSS_BY_NAME

local function BuildReverseLookups()
    DUNGEON_BY_ID, DUNGEON_BY_NAME = {}, {}
    for slug, info in pairs(DUNGEON_BY_SLUG) do
        if info.id and info.id ~= 0 then DUNGEON_BY_ID[info.id] = slug end
        if info.name then DUNGEON_BY_NAME[info.name:lower()] = slug end
    end
    BOSS_BY_ID, BOSS_BY_NAME = {}, {}
    for slug, info in pairs(RAID_BOSS_BY_SLUG) do
        if info.id and info.id ~= 0 then BOSS_BY_ID[info.id] = slug end
        if info.name then BOSS_BY_NAME[info.name:lower()] = slug end
    end
end
BuildReverseLookups()

-------------------------------------------------------------------------------
-- Data accessors
-------------------------------------------------------------------------------

function ns.GetArchonSpecData(class, spec)
    local data = GetArchonGlobal()
    if not data then return nil end
    local cls = data[class]
    if not cls then return nil end
    return cls[spec]
end

-- Returns the single build entry stored for a context, or nil.
function ns.FindArchonBuild(class, spec, contextKey)
    local sd = ns.GetArchonSpecData(class, spec)
    if not sd or not sd.contexts then return nil end
    local ctx = sd.contexts[contextKey]
    if not ctx or not ctx.builds or #ctx.builds == 0 then return nil end
    return ctx.builds[1], ctx
end

-- Find an Archon build by exportString across every context for a spec.
-- Used for "currently-active" detection in the talent pane.
function ns.FindArchonBuildByExportString(class, spec, exportString)
    if not exportString then return nil end
    local sd = ns.GetArchonSpecData(class, spec)
    if not sd or not sd.contexts then return nil end
    for ctxKey, ctx in pairs(sd.contexts) do
        if ctx.builds then
            for _, b in ipairs(ctx.builds) do
                if b.exportString == exportString then
                    return b, ctx, ctxKey
                end
            end
        end
    end
    return nil
end

-- Bucket contexts by zone type + difficulty for menu rendering.
-- Returns a table with these keys (each entry has { contextKey, ctx }):
--   mplusOverview        -- single context (high-keys / all-dungeons), or nil
--   mplusDungeons        -- ordered list, alphabetical by encounterLabel
--   raidOverviewHeroic   -- single context, or nil
--   raidOverviewMythic   -- single context, or nil
--   raidHeroicBosses     -- ordered list, by encounter slug
--   raidMythicBosses     -- ordered list, by encounter slug
function ns.GroupArchonContexts(specData)
    local out = {
        mplusDungeons = {},
        raidHeroicBosses = {},
        raidMythicBosses = {},
    }
    if not specData or not specData.contexts then return out end

    -- Iterate in the scraper-provided discovery order when available.
    -- contextOrder mirrors Archon's encounter dropdown order (M+
    -- overview + dungeons; then raid overviews + bosses in pull order),
    -- so dropping the entries into their buckets in this order means
    -- we don't need a hand-curated season-by-season pull-order table.
    -- Falls back to pairs() when the field isn't there (older snapshots).
    local order = specData.contextOrder
    local seen = {}
    local function process(ctxKey)
        if seen[ctxKey] then return end
        seen[ctxKey] = true
        local ctx = specData.contexts[ctxKey]
        if not ctx then return end
        if ctx.zoneType == "mythic-plus" then
            if ctx.encounter == "all-dungeons" then
                out.mplusOverview = { contextKey = ctxKey, ctx = ctx }
            else
                out.mplusDungeons[#out.mplusDungeons + 1] = { contextKey = ctxKey, ctx = ctx }
            end
        elseif ctx.zoneType == "raid" then
            if ctx.encounter == "all-bosses" then
                if ctx.difficulty == "mythic" then
                    out.raidOverviewMythic = { contextKey = ctxKey, ctx = ctx }
                else
                    out.raidOverviewHeroic = { contextKey = ctxKey, ctx = ctx }
                end
            else
                local bucket = (ctx.difficulty == "mythic") and out.raidMythicBosses or out.raidHeroicBosses
                bucket[#bucket + 1] = { contextKey = ctxKey, ctx = ctx }
            end
        end
    end

    if type(order) == "table" then
        for _, ctxKey in ipairs(order) do process(ctxKey) end
    end
    -- Catch any contexts that the order list missed (e.g. an order
    -- list from a stale snapshot whose dataset has new entries).
    for ctxKey in pairs(specData.contexts) do process(ctxKey) end

    -- When contextOrder is missing entirely, fall back to the previous
    -- behaviour: alphabetical M+ dungeons + RAID_BOSS_RANK bosses. With
    -- a present contextOrder the buckets are already in pull order so
    -- we leave them alone.
    if type(order) ~= "table" then
        table.sort(out.mplusDungeons, function(a, b)
            return ns.GetArchonEncounterLabel(a.ctx) < ns.GetArchonEncounterLabel(b.ctx)
        end)
        local function byRank(a, b)
            local ra = RAID_BOSS_RANK[a.ctx.encounter] or math.huge
            local rb = RAID_BOSS_RANK[b.ctx.encounter] or math.huge
            if ra ~= rb then return ra < rb end
            return (a.ctx.encounter or "") < (b.ctx.encounter or "")
        end
        table.sort(out.raidHeroicBosses, byRank)
        table.sort(out.raidMythicBosses, byRank)
    end

    return out
end

-------------------------------------------------------------------------------
-- Zone / encounter detection
-------------------------------------------------------------------------------

local activeContextKey -- cached "where is the player right now" key
local lastEncounterID  -- remembered between ENCOUNTER_START and ENCOUNTER_END
local lastDifficulty   -- "heroic" | "mythic" | nil
local callbacks = {}

-- "Heroic Raid" / "Mythic Raid" difficulty IDs.
-- 14 = Normal, 15 = Heroic, 16 = Mythic, 17 = LFR.
local DIFFICULTY_TO_ARCHON = {
    [14] = "heroic",  -- Normal — no Archon data; treat as heroic for fallback
    [15] = "heroic",
    [16] = "mythic",
    [17] = "heroic",  -- LFR — no Archon data; fall back to heroic
}

local function ResolveDungeonSlug(instanceMapID, instanceName)
    if instanceMapID and DUNGEON_BY_ID[instanceMapID] then
        return DUNGEON_BY_ID[instanceMapID]
    end
    if instanceName and DUNGEON_BY_NAME[instanceName:lower()] then
        return DUNGEON_BY_NAME[instanceName:lower()]
    end
    return nil
end

local function ResolveBossSlug(encounterID, encounterName)
    if encounterID and BOSS_BY_ID[encounterID] then
        return BOSS_BY_ID[encounterID]
    end
    if encounterName and BOSS_BY_NAME[encounterName:lower()] then
        return BOSS_BY_NAME[encounterName:lower()]
    end
    return nil
end

local function ComputeActiveContext()
    local _, instanceType = IsInInstance()
    local instanceName, _, difficultyID, _, _, _, _, instanceMapID = GetInstanceInfo()

    if instanceType == "party" then
        local slug = ResolveDungeonSlug(instanceMapID, instanceName)
        if slug then
            return "mythic-plus:high-keys:" .. slug
        end
        return "mythic-plus:high-keys:all-dungeons"
    end

    if instanceType == "raid" then
        local archonDiff = DIFFICULTY_TO_ARCHON[difficultyID] or "heroic"

        -- Mid-pull: prefer the boss the player just engaged.
        if lastEncounterID then
            local slug = ResolveBossSlug(lastEncounterID, nil)
            if slug then
                return "raid:" .. archonDiff .. ":" .. slug
            end
        end
        -- Between pulls: fall back to the difficulty-appropriate overview.
        return "raid:" .. archonDiff .. ":all-bosses"
    end

    return nil
end

local function FireCallbacks()
    for i = 1, #callbacks do
        local ok, err = pcall(callbacks[i], activeContextKey)
        if not ok then
            -- Surface the error but don't break the chain — one bad
            -- listener shouldn't take the others down with it.
            geterrorhandler()(err)
        end
    end
end

local function RefreshContext()
    local newKey = ComputeActiveContext()
    if newKey == activeContextKey then return end
    activeContextKey = newKey
    FireCallbacks()
end

function ns.GetActiveArchonContext()
    if activeContextKey == nil then RefreshContext() end
    return activeContextKey
end

function ns.RegisterArchonContextCallback(fn)
    callbacks[#callbacks + 1] = fn
end

-------------------------------------------------------------------------------
-- Event wiring
-------------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("ENCOUNTER_START")
f:RegisterEvent("ENCOUNTER_END")
f:SetScript("OnEvent", function(_, event, encounterID, _, difficultyID)
    if event == "ENCOUNTER_START" then
        lastEncounterID = encounterID
        lastDifficulty = DIFFICULTY_TO_ARCHON[difficultyID]
    elseif event == "ENCOUNTER_END" then
        -- Keep lastEncounterID so the post-pull state still surfaces the
        -- right boss in the picker (TTL-style by relying on next zone
        -- change or pull to overwrite). Reset only on zone change.
    end
    RefreshContext()
end)

-------------------------------------------------------------------------------
-- Source persistence — stored per-character × per-specID.
-- ClassCodexCharDB.archonSource[specID] = "wowhead" | "archon"
-- ClassCodexCharDB.archonContext[specID] = contextKey  (manual override)
-------------------------------------------------------------------------------

local function CurrentSpecID()
    if not GetSpecialization then return nil end
    local idx = GetSpecialization()
    if not idx then return nil end
    local id = GetSpecializationInfo and GetSpecializationInfo(idx)
    return id
end

function ns.GetPersistedTalentSource()
    if not ClassCodexCharDB then return nil end
    local specID = CurrentSpecID()
    if not specID or not ClassCodexCharDB.archonSource then return nil end
    return ClassCodexCharDB.archonSource[specID]
end

function ns.SetPersistedTalentSource(source)
    if not ClassCodexCharDB then return end
    local specID = CurrentSpecID()
    if not specID then return end
    ClassCodexCharDB.archonSource = ClassCodexCharDB.archonSource or {}
    ClassCodexCharDB.archonSource[specID] = source
end

function ns.GetPersistedArchonContext()
    if not ClassCodexCharDB then return nil end
    local specID = CurrentSpecID()
    if not specID or not ClassCodexCharDB.archonContext then return nil end
    return ClassCodexCharDB.archonContext[specID]
end

function ns.SetPersistedArchonContext(contextKey)
    if not ClassCodexCharDB then return end
    local specID = CurrentSpecID()
    if not specID then return end
    ClassCodexCharDB.archonContext = ClassCodexCharDB.archonContext or {}
    ClassCodexCharDB.archonContext[specID] = contextKey
end

-- Default-source resolver: "archon" if the player is in a known Archon
-- context (dungeon / raid), else "wowhead". Falls back to the persisted
-- per-spec choice if one is set.
function ns.GetEffectiveTalentSource()
    local persisted = ns.GetPersistedTalentSource()
    if persisted then return persisted end
    local activeKey = ns.GetActiveArchonContext()
    if activeKey then return "archon" end
    return "wowhead"
end
