local _, ns = ...

-------------------------------------------------------------------------------
-- UggTalentAdapter: feed ClassCodexUggBuilds from ClassCodexUggTalents.
--
-- u.gg is the u.gg replacement, so instead of new UI we reshape u.gg talent
-- builds into the exact structure UggContext.lua / the talent pane already
-- consume: ClassCodexUggBuilds[class][spec] = { contexts = { [key] = {
--   zoneType, difficulty, encounter, encounterLabel, builds = {...} } },
--   contextOrder = { key, ... } }.
--
-- exportString comes from the offline-encoded data when present; otherwise we
-- encode the raw node list in-game for the ACTIVE spec (TalentEncode.lua needs
-- the loaded tree). That lets the active spec light up before every spec has
-- been dumped/encoded; other specs fall back to Icy Veins until then.
-------------------------------------------------------------------------------

if not ClassCodexUggTalents then return end

-- Encounter id -> display name. u.gg's context ids are its own internal ids
-- (not WoW journal ids), so the game can't name them — we resolve against the
-- scraped ClassCodexUggEncounters map (dungeons / bosses). A miss just yields a
-- generic label, and the build itself is unaffected.
local function ResolveName(kind, id)
    if not id then return nil end
    local enc = ClassCodexUggEncounters
    if not enc then return nil end
    local map = (kind == "mplus" and enc.dungeons) or (kind == "raid" and enc.bosses)
    return map and map[id] or nil
end

-- Offline-encoded string when present; otherwise encode the raw node list in
-- game. Runtime encoding uses the ACTIVE spec's loaded tree, so it is only
-- valid for the active spec — never encode another spec's nodes against it.
local function ResolveExport(build, canEncode)
    if build.exportString and build.exportString ~= "" then return build.exportString end
    if canEncode and build.talents and ns.EncodeUggTalents then
        local ok, s = pcall(ns.EncodeUggTalents, build.talents)
        if ok and s and s ~= "" then return s end
    end
    return nil
end

-- ctxKey ("mplus:all" | "mplus:<id>" | "raid:all" | "raid:<id>") -> u.gg
-- context descriptor, or nil to skip.
local function DescribeContext(ctxKey)
    local bucket, sub = ctxKey:match("^(%a+):(.+)$")
    if bucket == "mplus" then
        if sub == "all" then
            return "mythic-plus:high-keys:all-dungeons", "mythic-plus", nil, "all-dungeons", "All Dungeons", true
        end
        local id = tonumber(sub)
        local label = ResolveName("mplus", id) or ("Dungeon " .. sub)
        return "mythic-plus:high-keys:ugg-" .. sub, "mythic-plus", nil, "ugg-" .. sub, label, false
    elseif bucket == "raid" then
        -- Heroic raid (u.gg's default /all/ payload).
        if sub == "all" then
            return "raid:heroic:all-bosses", "raid", "heroic", "all-bosses", "All Bosses", true
        end
        local id = tonumber(sub)
        local label = ResolveName("raid", id) or ("Boss " .. sub)
        return "raid:heroic:ugg-" .. sub, "raid", "heroic", "ugg-" .. sub, label, false
    elseif bucket == "raidm" then
        -- Mythic raid (u.gg's /5/ payload).
        if sub == "all" then
            return "raid:mythic:all-bosses", "raid", "mythic", "all-bosses", "All Bosses", true
        end
        local id = tonumber(sub)
        local label = ResolveName("raid", id) or ("Boss " .. sub)
        return "raid:mythic:ugg-" .. sub, "raid", "mythic", "ugg-" .. sub, label, false
    end
    return nil
end

function ns.BuildUggData()
    if not ClassCodexUggTalents then return end
    -- Only the active spec can be encoded in-game (its tree is the one loaded).
    local activeClass, activeSpec
    if ns.GetClassAndSpec then activeClass, activeSpec = ns.GetClassAndSpec() end
    ClassCodexUggBuilds = ClassCodexUggBuilds or {}
    for class, specs in pairs(ClassCodexUggTalents) do
        ClassCodexUggBuilds[class] = ClassCodexUggBuilds[class] or {}
        for spec, sd in pairs(specs) do
            local canEncode = (class == activeClass and spec == activeSpec)
            local contexts = {}
            local overview, encounters = {}, {}
            for ctxKey, refs in pairs(sd.contexts or {}) do
                local uggKey, zoneType, difficulty, encounter, label, isOverview = DescribeContext(ctxKey)
                if uggKey then
                    local builds = {}
                    for _, ref in ipairs(refs) do
                        local b = sd.builds and sd.builds[ref.b]
                        if b then
                            local export = ResolveExport(b, canEncode)
                            if export then
                                builds[#builds + 1] = {
                                    exportString = export,
                                    heroTalent = b.hero,
                                    pickrate = ref.pickrate,
                                }
                            end
                        end
                    end
                    if #builds > 0 then
                        contexts[uggKey] = {
                            zoneType = zoneType,
                            difficulty = difficulty,
                            encounter = encounter,
                            encounterLabel = label,
                            builds = builds,
                        }
                        if isOverview then
                            overview[#overview + 1] = uggKey
                        else
                            encounters[#encounters + 1] = uggKey
                        end
                    end
                end
            end
            -- Overview contexts first, then per-encounter (matches u.gg's
            -- dropdown order well enough without a hand-curated pull order).
            local order = {}
            for _, k in ipairs(overview) do order[#order + 1] = k end
            for _, k in ipairs(encounters) do order[#order + 1] = k end

            if next(contexts) then
                ClassCodexUggBuilds[class][spec] = { contexts = contexts, contextOrder = order }
            end
        end
    end
    -- Refresh UggContext's name-match lookups against the data we just
    -- populated so zone auto-detection sees the new dungeons/bosses.
    if ns.RebuildUggLookups then ns.RebuildUggLookups() end
end

-- Build once now (offline-encoded specs) and again once the player's spec /
-- tree is loaded (so the active spec's node lists can be encoded in-game).
ns.BuildUggData()

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:SetScript("OnEvent", function()
    ns.BuildUggData()
end)
