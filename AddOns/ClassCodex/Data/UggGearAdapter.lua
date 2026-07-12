local _, ns = ...

-------------------------------------------------------------------------------
-- UggGearAdapter: feed ClassCodexUggGearData (read by ns:GetUggGearSpecData)
-- from the generated ClassCodexUggGear.
--
-- u.gg gear is stored per context (mplus/raid overview + each dungeon/boss);
-- the Gear section wants a bisGear list of tabs { label, slots = { { slot,
-- item = { itemId } } } }. We surface the two overview contexts as the Mythic+
-- and Raid tabs (BiS doesn't vary enough per-encounter to justify 20 tabs).
--
-- The same u.gg gear carries per-slot enchant ids/names, so we also emit an
-- `enchants` list the Enhancements section consumes.
-------------------------------------------------------------------------------

if not ClassCodexUggGear then return end

local TAB_LABEL = { ["mplus:all"] = "傳奇+", ["raid:all"] = "團隊" }
local TAB_ORDER = { "mplus:all", "raid:all" }

local function BuildUggGearData()
    if not ClassCodexUggGear then return end
    ClassCodexUggGearData = ClassCodexUggGearData or {}
    for class, specs in pairs(ClassCodexUggGear) do
        ClassCodexUggGearData[class] = ClassCodexUggGearData[class] or {}
        for spec, sd in pairs(specs) do
            local bisGear = {}
            local enchants, seenEnchant = {}, {}
            for _, ctxKey in ipairs(TAB_ORDER) do
                local ctx = sd.contexts and sd.contexts[ctxKey]
                if ctx then
                    local slots = {}
                    for _, s in ipairs(ctx) do
                        slots[#slots + 1] = { slot = s.slot, item = { itemId = s.itemId } }
                        -- Collect distinct enchants (first-seen wins across tabs).
                        -- Shape matches the Enhancements row: { slot, best = { name } }.
                        -- enchantSpellId (resolved offline from the enchanting spell
                        -- name) drives the icon + tooltip; name-only when unresolved.
                        if s.enchantId and s.enchantId > 0 and s.enchantName and not seenEnchant[s.slot] then
                            seenEnchant[s.slot] = true
                            enchants[#enchants + 1] = {
                                slot = s.slot,
                                best = { name = s.enchantName, enchantId = s.enchantId, spellId = s.enchantSpellId },
                            }
                        end
                    end
                    if #slots > 0 then
                        bisGear[#bisGear + 1] = { label = TAB_LABEL[ctxKey], slots = slots }
                    end
                end
            end
            if #bisGear > 0 then
                ClassCodexUggGearData[class][spec] = {
                    bisGear = bisGear,
                    enchants = (#enchants > 0) and enchants or nil,
                }
            end
        end
    end
end

BuildUggGearData()
