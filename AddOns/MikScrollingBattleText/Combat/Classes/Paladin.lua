local sealFacts = {
    -- Applying a seal is separate from any damage its melee proc deals.
    damages = false, helpful = true, direct = false, ticks = false,
    weaponProc = "seal", procSchool = 2,
    source = "nameplatesct-reforged", sourceBuild = "1.60.1.70888",
}

local spellFacts = {}
for _, spellID in ipairs({
    20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, 21084, -- Righteousness
    20375, 20915, 20918, 20919, 20920, -- Command
    20163, 20419, 20421, 20422, 20423, 1311649, 1311656, -- Fury
    20164, -- Justice
    20165, 20347, 20348, 20349, -- Light
    20166, 20356, 20357, -- Wisdom
    20162, 20305, 20306, 20307, 20308, 21082, -- the Crusader
    407798, -- Martyrdom
}) do
    spellFacts[spellID] = sealFacts
end

local holyWrath = { area = true, areaWindow = 0.2 }
spellFacts[2812] = holyWrath
spellFacts[10318] = holyWrath

MikSBT.CombatEngine.classRules.PALADIN = {
    spellFacts = spellFacts,
    windfuryTotemTriggers = {
        -- Holy Strike ranks can trigger Windfury Totem on Forever.
        [678] = true, [679] = true, [680] = true, [1866] = true,
        [2495] = true, [5569] = true, [10332] = true, [10333] = true,
    },
}
