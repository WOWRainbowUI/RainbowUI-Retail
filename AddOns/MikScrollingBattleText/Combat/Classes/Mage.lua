-- Arcane Missiles cast ranks from the Forever 1.60.1.70888 client spellbook.
-- https://www.60.tools/spellbook/mage
-- The channel start and stop events supply its actual lifetime.
local arcaneMissiles = {
    damages = true, school = 64, direct = true, ticks = false,
    allowUntargetedChannel = true,
    source = "forever-client", sourceBuild = "1.60.1.70888",
}

local spellFacts = {}
for _, spellID in ipairs({ 5143, 5144, 5145, 8416, 8417, 10211, 10212, 25345 }) do
    spellFacts[spellID] = arcaneMissiles
end

local arcaneExplosion = { area = true, areaWindow = 0.2 }
for _, spellID in ipairs({ 1449, 8437, 8438, 8439, 10201, 10202 }) do
    spellFacts[spellID] = arcaneExplosion
end

MikSBT.CombatEngine.classRules.MAGE = {
    spellFacts = spellFacts,
}
