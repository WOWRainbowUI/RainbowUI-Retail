-- Both spells heal their caster in every locale.
local leech = { leech = true }

MikSBT.CombatEngine.classRules.WARLOCK = {
    spellFacts = {
        -- Drain Life
        [689] = leech, [699] = leech, [709] = leech,
        [7651] = leech, [11699] = leech, [11700] = leech,
        -- Siphon Life
        [18265] = leech, [18879] = leech, [18880] = leech, [18881] = leech,
    },
}
