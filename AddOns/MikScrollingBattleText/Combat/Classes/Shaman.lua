local engine = MikSBT.CombatEngine
local windfuryWeapon = {
    iconSpell = 8232,
    procSpell = 439440,
    triggerSpell = 17364, -- Stormstrike
    groupDelay = 1,
    enchants = { [283] = true, [284] = true, [525] = true, [1669] = true },
}

local chainLightning = { maxDirectTargets = 3 }

engine.classRules.SHAMAN = {
    spellFacts = {
        [421] = chainLightning, [930] = chainLightning,
        [2860] = chainLightning, [10605] = chainLightning,
    },
    windfuryWeapon = windfuryWeapon,
    spellReach = {
        [windfuryWeapon.triggerSpell] = "melee",
    },
}

-- Shared signal and display code uses the same class-owned spell data.
engine.WindfuryWeapon = windfuryWeapon
