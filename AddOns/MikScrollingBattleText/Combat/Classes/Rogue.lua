-- Each Mutilate rank strikes with both weapons.
local mutilate = { directHits = 2 }

MikSBT.CombatEngine.classRules.ROGUE = {
    spellFacts = {
        [1310707] = mutilate, [399956] = mutilate,
        [1241582] = mutilate, [1241584] = mutilate,
    },
    windfuryTotemTriggers = {
        -- Backstab
        [53] = true, [2589] = true, [2590] = true, [2591] = true, [8721] = true,
        [11279] = true, [11280] = true, [11281] = true, [25300] = true,
        -- Sinister Strike
        [1752] = true, [1757] = true, [1758] = true, [1759] = true, [1760] = true,
        [8621] = true, [11293] = true, [11294] = true,
    },
}
