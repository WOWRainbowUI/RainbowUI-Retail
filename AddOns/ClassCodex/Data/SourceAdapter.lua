-- Source adapter for the permission-clean migration.
--
-- The addon UI reads a handful of legacy globals (ClassCodexData for stat
-- priorities / talents / rotation, etc.). Rather than rewrite every consumer,
-- this file — loaded after all Data\ files — (1) declares the globals whose
-- legacy sources are gone as empty so nothing errors, and (2) rebuilds the
-- ones we DO have, from the permissioned sources (u.gg, Icy Veins, Blizzard
-- armory for PvP), into the shape the UI expects.

ClassCodexData = ClassCodexData or {}
ClassCodexGearData = ClassCodexGearData or {}               -- Gear.lua falls back to Icy Veins
ClassCodexUggBuilds = ClassCodexUggBuilds or {}
ClassCodexUggStatTargets = ClassCodexUggStatTargets or {}   -- secondary-stat targets summed from u.gg BiS
ClassCodexUggGearData = ClassCodexUggGearData or {}
ClassCodexUggPvp = ClassCodexUggPvp or {}                   -- PvP gear/enchants/stats (u.gg)
ClassCodexBnetPvpTalents = ClassCodexBnetPvpTalents or {}   -- PvP talents/honor (Blizzard armory)
ClassCodexCraftingData = ClassCodexCraftingData or {}
ClassCodexEmbellishmentEffects = ClassCodexEmbellishmentEffects or {}

-- Stat priorities: Icy Veins feeds the Guide. IV publishes a single ordered
-- priority per spec (no per-context split), so the Guide shows one order and its
-- context dropdown disappears. We drop entries that aren't a weighable secondary
-- stat — the spec's fixed main stat (Strength/Agility/Intellect) and item level
-- ("always more", not a stat you weigh) — and normalize names to the full WoW
-- terms the tooltip stat-priority matcher expects (see STAT_KEYS below).
local EXCLUDED_STAT = {
    Strength = true, Agility = true, Intellect = true, ["Item Level"] = true,
}
local STAT_ALIAS = { ["致命一擊"] = "致命一擊", Crit = "致命一擊" }
if ClassCodexIcyVeinsData then
    for class, specs in pairs(ClassCodexIcyVeinsData) do
        ClassCodexData[class] = ClassCodexData[class] or {}
        for spec, sd in pairs(specs) do
            local stats = {}
            for _, tier in ipairs(sd.statPriority or {}) do
                local kept = {}
                for _, name in ipairs(tier) do
                    if not EXCLUDED_STAT[name] then kept[#kept + 1] = STAT_ALIAS[name] or name end
                end
                if #kept > 0 then stats[#stats + 1] = kept end
            end
            local entry = ClassCodexData[class][spec] or {}
            if #stats > 0 then
                entry.priorities = { { heroTalent = "All", context = "General", stats = stats } }
            end
            ClassCodexData[class][spec] = entry
        end
    end
end

-- Talents: the Guide's inline talent preview is Icy Veins too. IV builds carry no
-- hero-talent split, so tag them "All" — GetAllTalentBuildsForHero then surfaces
-- them for whatever hero the player has. (The Compendium keeps u.gg/IV/PvP as
-- explicit selectable sources; this only feeds the Guide preview.)
if ClassCodexIcyVeinsTalentData then
    for class, specs in pairs(ClassCodexIcyVeinsTalentData) do
        ClassCodexData[class] = ClassCodexData[class] or {}
        for spec, sd in pairs(specs) do
            local talents = {}
            for _, b in ipairs(sd.talents or {}) do
                talents[#talents + 1] = {
                    heroTalent = "All",
                    context = b.leveling and "升級" or (b.context or "General"),
                    buildLabel = b.buildLabel,
                    exportString = b.exportString,
                }
            end
            local entry = ClassCodexData[class][spec] or {}
            if #talents > 0 then entry.talents = talents end
            ClassCodexData[class][spec] = entry
        end
    end
end

-- Rotations: merge Icy Veins rotation builds into ClassCodexData[class][spec].
-- rotation — the field the Rotation section reads (a list of
-- { heroTalent, context, steps }). Runs after the stat-priority pass above and
-- reuses the same entry, so both .priorities and .rotation coexist.
if ClassCodexIcyVeinsRotation then
    for class, specs in pairs(ClassCodexIcyVeinsRotation) do
        ClassCodexData[class] = ClassCodexData[class] or {}
        for spec, sd in pairs(specs) do
            local entry = ClassCodexData[class][spec] or {}
            entry.rotation = sd.rotations
            ClassCodexData[class][spec] = entry
        end
    end
end
