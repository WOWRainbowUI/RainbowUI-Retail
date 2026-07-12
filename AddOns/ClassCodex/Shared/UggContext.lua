local _, ns = ...

-------------------------------------------------------------------------------
-- UggContext: u.gg per-encounter build accessors + zone auto-detection.
--
-- The u.gg scraper writes Data\{Class}\ugg-talents.lua files keyed by
-- "zoneType:difficulty:encounter" (e.g. "mythic-plus:high-keys:skyreach",
-- "raid:mythic:imperator"). This module provides:
--
--   - ns.GetUggSpecData(class, spec) — full per-spec record from the
--     ClassCodexUggBuilds global, or nil.
--   - ns.GroupUggContexts(specData) — bucketed view: { mplusOverview,
--     mplusDungeons[], raidOverviewHeroic, raidOverviewMythic,
--     raidHeroicBosses[], raidMythicBosses[] }.
--   - ns.FindUggBuild(class, spec, contextKey) — the single best build
--     stored for that context (the scraper picks the highest-popularity
--     main entry per page).
--   - ns.GetActiveUggContext() — heuristic match from the player's
--     current zone / current pull to a contextKey, or nil if unknown.
--   - ns.RegisterUggContextCallback(fn) — fires whenever the active
--     context changes so the talent pane / Compendium can refresh their
--     auto-pick.
--
-- Slug↔ID mapping is hand-curated below. Slugs change at season
-- transitions; updating one season's worth of dungeons + bosses is a
-- small recurring chore documented near the table itself.
-------------------------------------------------------------------------------

local UGG_DATA = _G.ClassCodexUggBuilds

-- Re-resolve at use time too — toc load order means the global may not
-- be present at this file's load (we are listed after the data files,
-- but be defensive in case that ever changes).
local function GetUggGlobal()
    return UGG_DATA or _G.ClassCodexUggBuilds
end

-------------------------------------------------------------------------------
-- Slug → in-game lookups (auto-derived from scraped data)
--
-- The dungeon/boss list and their display names are NOT hand-maintained.
-- They are built at runtime from the scraped contexts in
-- ClassCodexUggBuilds — every context carries its encounter slug plus
-- the full in-game `encounterLabel` (the scraper pulls it from u.gg's
-- seo.description). So when a season rotates dungeons or a new raid tier
-- ships, the next data refresh updates these lookups with zero code
-- changes here.
--
-- NAME_OVERRIDE is the only hand-edited surface, and only for the rare
-- case where u.gg's spelling differs from Blizzard's in-game name
-- (which is what the name-match path compares against). ID_OVERRIDE lets
-- a non-enUS client pin numeric IDs; empty by default since name-match
-- covers enUS.
-------------------------------------------------------------------------------

-- u.gg label -> in-game name, by encounter slug. Add an entry only when
-- the two disagree; everything else flows straight from encounterLabel.
local DUNGEON_NAME_OVERRIDE = {
    ["maisara-caverns"] = "Mai'sara Caverns", -- u.gg renders "Maisara Caverns"
}
local BOSS_NAME_OVERRIDE = {}

-- Optional numeric-ID pins (instanceMapID / encounterID) for localized
-- clients where name-match can't work. Empty by default.
local DUNGEON_ID_OVERRIDE = {}
local BOSS_ID_OVERRIDE = {}

-- Reverse lookups, (re)built from ClassCodexUggBuilds.
local DUNGEON_BY_ID, DUNGEON_BY_NAME
local BOSS_BY_ID, BOSS_BY_NAME
-- slug -> in-game display name, for the non-localised label fallback.
local DUNGEON_DISPLAY, BOSS_DISPLAY

-- The in-game name we match the player's current zone against: the
-- spelling override when present, else the scraped encounterLabel.
local function DungeonName(slug, label)
    return DUNGEON_NAME_OVERRIDE[slug] or label
end
local function BossName(slug, label)
    return BOSS_NAME_OVERRIDE[slug] or label
end

-- True once we've built against a populated data global. Distinguishes
-- "built, legitimately empty" from "global wasn't ready yet" so the lazy
-- rebuild fires exactly once when the data appears — without depending on
-- both name tables being non-empty (a partial dataset, e.g. M+ contexts
-- but no raid yet, must still count as built).
local lookupsBuilt = false

local function BuildLookups()
    DUNGEON_BY_ID, DUNGEON_BY_NAME = {}, {}
    BOSS_BY_ID, BOSS_BY_NAME = {}, {}
    DUNGEON_DISPLAY, BOSS_DISPLAY = {}, {}

    local data = GetUggGlobal()
    lookupsBuilt = data ~= nil
    if data then
        for _, classData in pairs(data) do
            for _, specData in pairs(classData) do
                local contexts = type(specData) == "table" and specData.contexts
                if contexts then
                    for _, ctx in pairs(contexts) do
                        local slug = ctx.encounter
                        if slug and slug ~= "all-dungeons" and slug ~= "all-bosses" then
                            local label = ctx.encounterLabel
                            if ctx.zoneType == "mythic-plus" then
                                local name = DungeonName(slug, label)
                                if name and name ~= "" then
                                    DUNGEON_BY_NAME[name:lower()] = slug
                                    DUNGEON_DISPLAY[slug] = name
                                end
                            elseif ctx.zoneType == "raid" then
                                local name = BossName(slug, label)
                                if name and name ~= "" then
                                    BOSS_BY_NAME[name:lower()] = slug
                                    BOSS_DISPLAY[slug] = name
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Layer on any hand-pinned numeric IDs.
    for id, slug in pairs(DUNGEON_ID_OVERRIDE) do DUNGEON_BY_ID[id] = slug end
    for id, slug in pairs(BOSS_ID_OVERRIDE) do BOSS_BY_ID[id] = slug end
end
BuildLookups()

-- Rebuild the dungeon/boss lookups on demand — the u.gg adapter populates
-- ClassCodexUggBuilds after this file loads (and again once the active spec's
-- talents are encoded in-game), so it calls this to refresh the name-match
-- tables that drive zone auto-detection.
function ns.RebuildUggLookups()
    BuildLookups()
end

-- Public helper: resolves the display label for a context. The scraper
-- stamps the full in-game name onto encounterLabel, so we trust it; the
-- slug-keyed *_DISPLAY tables (also derived from the data) serve as the
-- fallback for the auto-detect name-match path.
function ns.GetUggEncounterLabel(ctx)
    if not ctx then return "" end
    if ctx.encounterLabel and ctx.encounterLabel ~= "" then
        return ctx.encounterLabel
    end
    local slug = ctx.encounter
    if slug and DUNGEON_DISPLAY[slug] then return DUNGEON_DISPLAY[slug] end
    if slug and BOSS_DISPLAY[slug] then return BOSS_DISPLAY[slug] end
    return ""
end

-------------------------------------------------------------------------------
-- Data accessors
-------------------------------------------------------------------------------

function ns.GetUggSpecData(class, spec)
    local data = GetUggGlobal()
    if not data then return nil end
    local cls = data[class]
    if not cls then return nil end
    return cls[spec]
end

-- Returns the single build entry stored for a context, or nil.
function ns.FindUggBuild(class, spec, contextKey)
    local sd = ns.GetUggSpecData(class, spec)
    if not sd or not sd.contexts then return nil end
    local ctx = sd.contexts[contextKey]
    if not ctx or not ctx.builds or #ctx.builds == 0 then return nil end
    return ctx.builds[1], ctx
end

-- Find an u.gg build by exportString across every context for a spec.
-- Used for "currently-active" detection in the talent pane.
function ns.FindUggBuildByExportString(class, spec, exportString)
    if not exportString then return nil end
    local sd = ns.GetUggSpecData(class, spec)
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
function ns.GroupUggContexts(specData)
    local out = {
        mplusDungeons = {},
        raidHeroicBosses = {},
        raidMythicBosses = {},
    }
    if not specData or not specData.contexts then return out end

    -- Iterate in the scraper-provided discovery order when available.
    -- contextOrder mirrors u.gg's encounter dropdown order (M+
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

    -- When contextOrder is missing entirely (legacy snapshots), fall back
    -- to a deterministic label sort. With a present contextOrder — which
    -- the scraper always emits now — the buckets are already in u.gg's
    -- pull order, so we leave them alone.
    if type(order) ~= "table" then
        local function byLabel(a, b)
            return ns.GetUggEncounterLabel(a.ctx) < ns.GetUggEncounterLabel(b.ctx)
        end
        table.sort(out.mplusDungeons, byLabel)
        table.sort(out.raidHeroicBosses, byLabel)
        table.sort(out.raidMythicBosses, byLabel)
    end

    return out
end

-------------------------------------------------------------------------------
-- Zone / encounter detection
-------------------------------------------------------------------------------

local activeContextKey  -- cached "where is the player right now" key
local lastEncounterID   -- remembered between ENCOUNTER_START and ENCOUNTER_END
local lastEncounterName -- boss name from ENCOUNTER_START, for name-match
local lastDifficulty    -- "heroic" | "mythic" | nil
local callbacks = {}

-- The lookups are built at file load, but toc order means the data
-- global *might* not be populated yet. Rebuild lazily the first time we
-- need them after the data global appears.
local function EnsureLookups()
    if not lookupsBuilt and GetUggGlobal() then
        BuildLookups()
    end
end

-- "Heroic Raid" / "Mythic Raid" difficulty IDs.
-- 14 = Normal, 15 = Heroic, 16 = Mythic, 17 = LFR.
local DIFFICULTY_TO_UGG = {
    [14] = "heroic",  -- Normal — no u.gg data; treat as heroic for fallback
    [15] = "heroic",
    [16] = "mythic",
    [17] = "heroic",  -- LFR — no u.gg data; fall back to heroic
}

local function ResolveDungeonSlug(instanceMapID, instanceName)
    EnsureLookups()
    if instanceMapID and DUNGEON_BY_ID[instanceMapID] then
        return DUNGEON_BY_ID[instanceMapID]
    end
    if instanceName and DUNGEON_BY_NAME[instanceName:lower()] then
        return DUNGEON_BY_NAME[instanceName:lower()]
    end
    return nil
end

local function ResolveBossSlug(encounterID, encounterName)
    EnsureLookups()
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
        local uggDiff = DIFFICULTY_TO_UGG[difficultyID] or "heroic"

        -- Mid-pull: prefer the boss the player just engaged. Match on the
        -- encounter name (enUS) since u.gg doesn't expose Blizzard
        -- encounterIDs; a numeric ID is used first when one is pinned.
        if lastEncounterID or lastEncounterName then
            local slug = ResolveBossSlug(lastEncounterID, lastEncounterName)
            if slug then
                return "raid:" .. uggDiff .. ":" .. slug
            end
        end
        -- Between pulls: fall back to the difficulty-appropriate overview.
        return "raid:" .. uggDiff .. ":all-bosses"
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

function ns.GetActiveUggContext()
    if activeContextKey == nil then RefreshContext() end
    return activeContextKey
end

function ns.RegisterUggContextCallback(fn)
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
-- ENCOUNTER_START args: encounterID, encounterName, difficultyID, groupSize.
f:SetScript("OnEvent", function(_, event, encounterID, encounterName, difficultyID)
    if event == "ENCOUNTER_START" then
        lastEncounterID = encounterID
        lastEncounterName = encounterName
        lastDifficulty = DIFFICULTY_TO_UGG[difficultyID]
    elseif event == "ENCOUNTER_END" then
        -- Keep lastEncounterID so the post-pull state still surfaces the
        -- right boss in the picker (TTL-style by relying on next zone
        -- change or pull to overwrite). Reset only on zone change.
    end
    RefreshContext()
end)

-------------------------------------------------------------------------------
-- Source persistence — stored per-character × per-specID.
-- ClassCodexCharDB.uggSource[specID] = "ugg" | "ugg"
-- ClassCodexCharDB.uggContext[specID] = contextKey  (manual override)
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
    if not specID or not ClassCodexCharDB.uggSource then return nil end
    return ClassCodexCharDB.uggSource[specID]
end

function ns.SetPersistedTalentSource(source)
    if not ClassCodexCharDB then return end
    local specID = CurrentSpecID()
    if not specID then return end
    ClassCodexCharDB.uggSource = ClassCodexCharDB.uggSource or {}
    ClassCodexCharDB.uggSource[specID] = source
end

function ns.GetPersistedUggContext()
    if not ClassCodexCharDB then return nil end
    local specID = CurrentSpecID()
    if not specID or not ClassCodexCharDB.uggContext then return nil end
    return ClassCodexCharDB.uggContext[specID]
end

function ns.SetPersistedUggContext(contextKey)
    if not ClassCodexCharDB then return end
    local specID = CurrentSpecID()
    if not specID then return end
    ClassCodexCharDB.uggContext = ClassCodexCharDB.uggContext or {}
    ClassCodexCharDB.uggContext[specID] = contextKey
end

-- Default-source resolver. Icy Veins is the baseline (curated editorial builds);
-- honours whatever the player explicitly picked (u.gg / Icy Veins / PvP).
function ns.GetEffectiveTalentSource()
    local persisted = ns.GetPersistedTalentSource()
    if persisted == "ugg" or persisted == "icyveins" or persisted == "pvp" then return persisted end
    return "icyveins"
end
