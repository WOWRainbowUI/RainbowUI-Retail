local _, ns = ...

-------------------------------------------------------------------------------
-- UggGemAdapter: feed the Enhancements (Gems) section from u.gg gem data.
--
-- The Gems section reads ClassCodexGearData[class][spec].gems as
-- { primary = { itemId }, secondary = { { itemId }, ... } } — the legacy shape.
-- u.gg publishes the same per-spec gem picks as ClassCodexUggGems[class][spec]
-- (top socket loadout: one unique gem + the repeated stat gem), so we point the
-- legacy field at it.
-------------------------------------------------------------------------------

if not ClassCodexUggGems then return end

local function BuildUggGemData()
    ClassCodexGearData = ClassCodexGearData or {}
    for class, specs in pairs(ClassCodexUggGems) do
        ClassCodexGearData[class] = ClassCodexGearData[class] or {}
        for spec, sd in pairs(specs) do
            if sd.primary or (sd.secondary and #sd.secondary > 0) then
                local entry = ClassCodexGearData[class][spec] or {}
                entry.gems = { primary = sd.primary, secondary = sd.secondary }
                ClassCodexGearData[class][spec] = entry
            end
        end
    end
end

BuildUggGemData()
