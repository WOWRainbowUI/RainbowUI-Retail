local thunderClap = { maxDirectTargets = 4 }

MikSBT.CombatEngine.classRules.WARRIOR = {
    spellFacts = {
        [1680] = { maxDirectTargets = 4 }, -- Whirlwind
        [6343] = thunderClap, [8198] = thunderClap, [8204] = thunderClap,
        [8205] = thunderClap, [11580] = thunderClap, [11581] = thunderClap,
    },
    queuedStrikes = {
        -- Heroic Strike
        [78] = true, [284] = true, [285] = true, [1608] = true,
        [11564] = true, [11565] = true, [11566] = true,
        [11567] = true, [25286] = true,
    },
    windfuryTotemTriggers = {
        -- Mortal Strike
        [12294] = true, [21551] = true, [21552] = true, [21553] = true,
        [27580] = true,
        -- Slam
        [1464] = true, [8820] = true, [11604] = true, [11605] = true,
        [1240193] = true,
    },
}
