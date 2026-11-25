MikSBT.CombatEngine.classRules.HUNTER = {
    spellFacts = {
        [2643] = { maxDirectTargets = 3 }, -- Multi-Shot
    },
    queuedStrikes = {
        -- Raptor Strike
        [2973] = true, [14260] = true, [14261] = true, [14262] = true,
        [14263] = true, [14264] = true, [14265] = true, [14266] = true,
    },
    rangedAttackSpell = 75, -- Auto Shot
    targetlessHealRecipients = {
        [136] = "pet", -- Mend Pet, including ranks with the same spell name
    },
    windfuryTotemTriggers = {
        -- Mongoose Bite
        [1495] = true, [14269] = true, [14270] = true, [14271] = true,
        -- Counterattack
        [19306] = true, [20909] = true, [20910] = true, [1242634] = true,
    },
}
