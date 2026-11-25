local swipe = { maxDirectTargets = 3 }

MikSBT.CombatEngine.classRules.DRUID = {
    spellFacts = {
        -- Swipe (Bear)
        [779] = swipe, [780] = swipe, [769] = swipe,
        [9754] = swipe, [9908] = swipe,
    },
    queuedStrikes = {
        -- Maul
        [6807] = true, [6808] = true, [6809] = true, [8972] = true,
        [9745] = true, [9880] = true, [9881] = true,
    },
    windfuryTotemTriggers = {
        -- Claw
        [1082] = true, [3029] = true, [5201] = true, [9849] = true, [9850] = true,
        -- Shred
        [5221] = true, [6800] = true, [8992] = true, [9829] = true, [9830] = true,
    },
}
