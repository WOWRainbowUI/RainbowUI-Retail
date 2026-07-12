local _, ns = ...

-------------------------------------------------------------------------------
-- UggTrinketAdapter: feed the Trinkets section from u.gg trinket data.
--
-- The Trinkets section (and the tooltip tier lookup) read
-- ClassCodexGearData[class][spec].trinkets — a legacy shape once produced by
-- the old gear pipeline. u.gg publishes the same per-spec trinket list as
-- ClassCodexUggTrinkets[class][spec].trinkets ({ itemId, tier, popularity,
-- contexts }), which the section consumes directly, so we just point the
-- legacy field at it.
-------------------------------------------------------------------------------

if not ClassCodexUggTrinkets then return end

local function BuildUggTrinketData()
    ClassCodexGearData = ClassCodexGearData or {}
    for class, specs in pairs(ClassCodexUggTrinkets) do
        ClassCodexGearData[class] = ClassCodexGearData[class] or {}
        for spec, sd in pairs(specs) do
            if sd.trinkets then
                local entry = ClassCodexGearData[class][spec] or {}
                entry.trinkets = sd.trinkets
                ClassCodexGearData[class][spec] = entry
            end
        end
    end
end

BuildUggTrinketData()
