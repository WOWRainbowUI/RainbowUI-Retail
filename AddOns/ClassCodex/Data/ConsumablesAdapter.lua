local _, ns = ...

-------------------------------------------------------------------------------
-- ConsumablesAdapter: feed the Enhancements (Consumables) section from Icy Veins.
--
-- The section reads ClassCodexGearData[class][spec].consumables as one item per
-- UI category (flask / combatPotion / food / augmentRune). Icy Veins lists
-- ranked items per category (flask / potions / food / augmentRune), so we take
-- each category's top pick and map it onto the UI's keys.
-------------------------------------------------------------------------------

if not ClassCodexConsumables then return end

local function top(list) return list and list[1] or nil end

local function BuildConsumables()
    ClassCodexGearData = ClassCodexGearData or {}
    for class, specs in pairs(ClassCodexConsumables) do
        ClassCodexGearData[class] = ClassCodexGearData[class] or {}
        for spec, c in pairs(specs) do
            local out = {
                flask = top(c.flask),
                combatPotion = top(c.potions),
                food = top(c.food),
                augmentRune = top(c.augmentRune),
            }
            if out.flask or out.combatPotion or out.food or out.augmentRune then
                local entry = ClassCodexGearData[class][spec] or {}
                entry.consumables = out
                ClassCodexGearData[class][spec] = entry
            end
        end
    end
end

BuildConsumables()
