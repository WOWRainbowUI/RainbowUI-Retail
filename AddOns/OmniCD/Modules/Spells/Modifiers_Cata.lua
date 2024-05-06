local E = select(2, ...):unpack()

E.spell_cdmod_talents = {
	-- Death Knight
	[48982] = { -- Rune Tap
		48985, 10, -- Improved Rune Tap (Rank 1)
		49488, 20, -- Improved Rune Tap (Rank 2)
		49489, 30, -- Improved Rune Tap (Rank 3)
	},
	[49576] = { -- Death Grip
		49588, 5, -- Unholy Command (Rank 1) --> peridoic sync reset effect
		49589, 10, -- Unholy Command (Rank 2)
	},
	[46584] = { -- Raise Dead
		52143, 60, -- Master of Ghouls
	},
	[47476] = {
		85793, 30, -- Hand of Doom (Rank 1)
		85794, 60, -- Hand of Doom (Rank 2)
	},
	[45529] = {
		94553, 15, -- Improved Blood Tap (Rank 1)
		94555, 30, -- Improved Blood Tap (Rank 2)
	},
	-- Druid
	[5211] = { -- Bash
		16940, 5, -- Brutal Impact (Rank 1)
		16941, 10, -- Brutal Impact (Rank 2)
	},
	[80964] = { -- Skull Bash
		16940, 25, -- Brutal Impact (Rank 1)
		16941, 50, -- Brutal Impact (Rank 2)
	},
	[50516] = {
		63056, 3, -- Glyph of Monsoon
	},
	[5209] = {
		57858, 30, -- Glyph of Challenging Roar
	},
	[48505] = {
		54828, 30, -- Glyph of Starfall
	},
	[740] = {
		92363, 150, -- Malfurion's Gift ( Rank 1)
		92364, 300, -- Malfurion's Gift ( Rank 2)
	},
	[5217] = {
		94390, 3, -- Glyph of Tiger's Fury
	},
	[16979] = { -- Feral Charge (Bear)
		94388, 1, -- Glyph of Feral Charge
	},
	[49376] = { -- Feral Charge (Cat)
		94388, 2, -- Glyph of Feral Charge
	},
	[467] = {
		57862, 20, -- Glyph of Thorns
	},
	[48438] = {
		62970, -2, -- Glyph of Wild Growth
	},
	-- Hunter
	[1499] = { -- Freezing Trap
		34491, 2, -- Resourcefulness (Rank 1)
		34492, 4, -- Resourcefulness (Rank 2)
		34493, 6, -- Resourcefulness (Rank 3)
	},
	[13795] = { -- Immolation Trap
		34491, 2, -- Resourcefulness (Rank 1)
		34492, 4, -- Resourcefulness (Rank 2)
		34493, 6, -- Resourcefulness (Rank 3)
	},
	[13809] = { -- Ice Trap
		34491, 2, -- Resourcefulness (Rank 1)
		34492, 4, -- Resourcefulness (Rank 2)
		34493, 6, -- Resourcefulness (Rank 3)
	},
	[13813] = { -- Explosive Trap
		34491, 2, -- Resourcefulness (Rank 1)
		34492, 4, -- Resourcefulness (Rank 2)
		34493, 6, -- Resourcefulness (Rank 3)
	},
	[34600] = { -- Snake Trap
		34491, 2, -- Resourcefulness (Rank 1)
		34492, 4, -- Resourcefulness (Rank 2)
		34493, 6, -- Resourcefulness (Rank 3)
	},
	[3674] = { -- Black Arrow
		34491, 2, -- Resourcefulness (Rank 1)
		34492, 4, -- Resourcefulness (Rank 2)
		34493, 6, -- Resourcefulness (Rank 3)
	},
	[3045] = { -- Rapid Fire
		83558, 60, -- Posthaste (Rank 1)
		83560, 120, -- Posthaste (Rank 2)
	},
	[19574] = {
		56830, 20, -- Glyph of Bestial Wrath
	},
	[53209] = {
		63065, 1, -- Glyph of Chimera Shot
	},
	[5384] = {
		57903, 5, -- Glyph of Feign Death
	},
	[781] = { -- Disengage
		19286, 2, -- Survival Tactics (Rank 1)
		19287, 4, -- Survival Tactics (Rank 2)
		56844, 5, -- Glyph of Disengage
	},
	[19263] = {
		56850, 10, -- Glyph of Deterrence
	},
	[19386] = {
		56848, 6, -- Glyph of Wyvern Sting
	},
	-- Mage
	[12051] = { -- Evocation
		44378, 60, -- Arcane Flows (Rank 1)
		44379, 120, -- Arcane Flows (Rank 2)
	},
	[31661] = {
		56373, 3, -- Glyph of Dragon's Breath
	},
	-- Paladin
	[1022] = { -- Hand of Protection
		20174, 60, -- Guardian's Favor (Rank 1)
		20175, 120, -- Guardian's Favor (Rank 2)
	},
	[31884] = { -- Avenging Wrath
		93418, 30, -- Paragon of Virtue (Rank 1)
		93417, 60, -- Paragon of Virtue (Rank 2)
		53375, 20, -- Sanctified Wrath (Rank 1)
		90286, 40, -- Sanctified Wrath (Rank 2)
		53376, 60, -- Sanctified Wrath (Rank 3)
		31848, 20, -- Shield of the Templar (Rank 1)
		31849, 40, -- Shield of the Templar (Rank 2)
		84854, 60, -- Shield of the Templar (Rank 3)
	},
	[86150] = { -- Guardian of Ancient Kings
		31848, 40, -- Shield of the Templar (Rank 1)
		31849, 80, -- Shield of the Templar (Rank 2)
		84854, 120, -- Shield of the Templar (Rank 3)
	},
	[853] = { -- Hammer of Justice
		20487, 10, -- Improved Hammer of Justice (Rank 1)
		20488, 20, -- Improved Hammer of Justice (Rank 2)
	},
	[633] = { -- Lay on Hands
		57955, 180, -- Glyph of Lay on Hands
	},
	[6940] = { -- Hand of Sacrifice
		93418, 15, -- Paragon of Virtue (Rank 1)
		93417, 30, -- Paragon of Virtue (Rank 2)
	},
	[498] = { -- Divine Protection
		93418, 15, -- Paragon of Virtue (Rank 1)
		93417, 30, -- Paragon of Virtue (Rank 2)
	},
	[85673] = { -- Word of Glory
		85803, 5, -- Selfless Healer (Rank 1)
		85804, 10, -- Selfless Healer (Rank 2)
	},
	-- Priest
	[586] = { -- Fade
		15274, 3, -- Veiled Shadows (Rank 1)
		15311, 6, -- Veiled Shadows (Rank 2)
		55684, 9, -- Glyph of Fade
	},
	[34433] = { -- Shadowfiend
		15274, 30, -- Veiled Shadows (Rank 1)
		15311, 60, -- Veiled Shadows (Rank 2)
	},
	[8092] = { -- Mind Blast
		15273, 0.5, -- Improved Mind Blast (Rank 1)
		15312, 1.0, -- Improved Mind Blast (Rank 2)
		15313, 1.5, -- Improved Mind Blast (Rank 3)
	},
	[8122] = { -- Psychic Scream
		15392, 2, -- Improved Psychic Scream (Rank 1)
		15448, 4, -- Improved Psychic Scream (Rank 2)
		55676, -3, -- Glyph of Psychic Scream
	},
	[17] = { -- Power Word: Shield (Rank 1)
		63574, 1, -- Soul Warding (Rank 1)
		78500, 2, -- Soul Warding (Rank 2)
	},
	[47585] = {
		63229, 45, -- Glyph of Dispersion
	},
	[47540] = {
		63235, 2, -- Glyph of Penance
	},
	[6346] = {
		55678, 60, -- Glyph of Fear Ward
	},
	[47788] = {
		63231, 30, -- Glyph of Guardian Spirit
	},
	[64044] = {
		55688, 30, -- Glyph of Psychic Horror
	},
	[64843] = { -- Divine Hymn
		87430, 150, -- Heavenly Voice (Rank 1)
		87431, 300, -- Heavenly Voice (Rank 2)
	},
	-- Rogue
	[2094] = { -- Blind
		13981, 30, -- Elusiveness (Rank 1)
		14066, 60, -- Elusiveness (Rank 2)
	},
	[1856] = { -- Vanish
		13981, 30, -- Elusiveness (Rank 1)
		14066, 60, -- Elusiveness (Rank 2)
	},
	[31224] = { -- Cloak of Shadows
		13981, 15, -- Elusiveness (Rank 1)
		14066, 30, -- Elusiveness (Rank 2)
	},
	[74001] = { -- Combat Readiness
		13981, 15, -- Elusiveness (Rank 1)
		14066, 30, -- Elusiveness (Rank 2)
	},
	[1784] = { -- Stealth
		13975, 2, -- Nightstalker (Rank 1)
		14062, 4, -- Nightstalker (Rank 2)
	},
	[57934] = { -- Tricks of the Trade
		58414, 5, -- Filthy Tricks (Rank 1)
		58415, 10, -- Filthy Tricks (Rank 2)
	},
	[1725] = { -- Distract
		58414, 5, -- Filthy Tricks (Rank 1)
		58415, 10, -- Filthy Tricks (Rank 2)
	},
	[36554] = { -- Shadowstep
		58414, 5, -- Filthy Tricks (Rank 1)
		58415, 10, -- Filthy Tricks (Rank 2)
	},
	[14185] = { -- Preparation
		58414, 90, -- Filthy Tricks (Rank 1)
		58415, 180, -- Filthy Tricks (Rank 2)
	},
	[1766] = {
		56805, -4, -- Glyph of Kick --> cleu [cooldown is reduced by 6 sec when your Kick successfully interrupts a spell]
	},
	-- Shaman
	[8042] = { -- Earth Shock
		16040, 0.5, -- Reverberation (Rank 1)
		16113, 1.0, -- Reverberation (Rank 2)
	},
	[8050] = { -- Flame Shock
		16040, 0.5, -- Reverberation (Rank 1)
		16113, 1.0, -- Reverberation (Rank 2)
		63370, 1.0, -- Booming Echoes (Rank 1)
		63372, 2.0, -- Booming Echoes (Rank 2)
	},
	[8056] = { -- Frost Shock
		16040, 0.5, -- Reverberation (Rank 1)
		16113, 1.0, -- Reverberation (Rank 2)
		63370, 1.0, -- Booming Echoes (Rank 1)
		63372, 2.0, -- Booming Echoes (Rank 2)
	},
	[57994] = { -- Wind Shear
		16040, 5, -- Reverberation (Rank 1)
		16113, 10, -- Reverberation (Rank 2)
	},
	[8177] = { -- Grounding Totem
		55441, -35, -- Glyph of Grounding Totem
	},
	[2894] = {
		55455, 300, -- Glyph of Fire Elemental Totem
	},
	[51490] = { -- Thunderstorm
		63270, 10, -- Glyph of Thunder
	},
	[51514] = {
		63291, 10, -- Glyph of Hex
	},
	-- Warlock
	[7814] = { -- Lash of Pain
		18126, 3, -- Demonic Power (Rank 1)
		18127, 6, -- Demonic Power (Rank 2)
	},
	[50796] = {
		63304, 2, -- Glyph of Chaos Bolt
	},
	[5484] = {
		56217, 8, -- Glyph of Howl of Terror
	},
	[48020] = {
		63309, 4, -- Glyph of Demonic Circle
	},
	-- Warrior
	[871] = { -- Shield Wall
		29598, 60, -- Shield Mastery (Rank 1)
		84607, 120, -- Shield Mastery (Rank 2)
		84608, 180, -- Shield Mastery (Rank 3)
		63329, -120, -- Glyph of Shield Wall
	},
	[100] = { -- Charge
		64976, 2, -- Juggernaut -- TODO: makes Intercept share a cooldown with Charge
		58355, 1, -- Glyph of Rapid Charge
	},
	[2565] = { -- Shield Block
		29598, 10, -- Shield Mastery (Rank 1)
		84607, 20, -- Shield Mastery (Rank 2)
		84608, 30, -- Shield Mastery (Rank 3)
	},
	[46968] = {
		63325, 3, -- Glyph of Shockwave
	},
	[46924] = {
		63324, 15, -- Glyph of Bladestorm
	},
	[23920] = {
		63328, 5, -- Glyph of Spell Reflection
	},
	-- cata
	[20252] = { -- Intercept
		29888, 5, -- Skirmisher (Rank 1)
		29889, 10, -- Skirmisher (Rank 2)
	},
	[6544] = { -- Heroic Leap
		29888, 10, -- Skirmisher (Rank 1)
		29889, 20, -- Skirmisher (Rank 2)
	},
	[469] = {
		12321, 15, -- Booming Voice (Rank 1)
		12835, 30, -- Booming Voice (Rank 2)
	},
	[57755] = { -- Heroic Throw
		12311, 15, -- Gag Order (Rank 1)
		12958, 30, -- Gag Order (Rank 2)
	},
}

E.spell_cdmod_talents_mult = {
	-- Druid
	[1850] = {
		59219, .80, -- Glyph of Dash
	},
	-- Hunter
	[19574] = { -- Bestial Wrath
		53262, .90, -- Longevity (Rank 1)
		53263, .80, -- Longevity (Rank 1)
		53264, .70, -- Longevity (Rank 1)
	},
	[19577] = { -- Intimidation
		53262, .90, -- Longevity (Rank 1)
		53263, .80, -- Longevity (Rank 1)
		53264, .70, -- Longevity (Rank 1)
	},
--	[53271] = { -- Master's Call	-- no longer pet ability in Cata
--		53262, .90, -- Longevity (Rank 1)
--		53263, .80, -- Longevity (Rank 1)
--		53264, .70, -- Longevity (Rank 1)
--	},
	[26090] = { -- Pummel
		53262, .90, -- Longevity (Rank 1)
		53263, .80, -- Longevity (Rank 1)
		53264, .70, -- Longevity (Rank 1)
	},
	-- Mage
	[120] = { -- Cone of Cold
		31670, .93, -- Ice Floes (Rank 1)
		31672, .86, -- Ice Floes (Rank 2)
		55094, .80, -- Ice Floes (Rank 3)
	},
	[45438] = { -- Ice Block
		31670, .93, -- Ice Floes (Rank 1)
		31672, .86, -- Ice Floes (Rank 2)
		55094, .80, -- Ice Floes (Rank 3)
	},
	[122] = { -- Frost Nova
		31670, .93, -- Ice Floes (Rank 1)
		31672, .86, -- Ice Floes (Rank 2)
		55094, .80, -- Ice Floes (Rank 3)
	},
	[12472] = { -- Icy Veins
		31670, .93, -- Ice Floes (Rank 1)
		31672, .86, -- Ice Floes (Rank 2)
		55094, .80, -- Ice Floes (Rank 3)
	},
	[11958] = { -- Cold Snap
		31670, .93, -- Ice Floes (Rank 1)
		31672, .86, -- Ice Floes (Rank 2)
		55094, .80, -- Ice Floes (Rank 3)
		55091, .90, -- Cold as Ice (Rank 1)
		55092, .80, -- Cold as Ice (Rank 2)
	},
	[11426] = { -- Ice Barrier
		31670, .93, -- Ice Floes (Rank 1)
		31672, .86, -- Ice Floes (Rank 2)
		55094, .80, -- Ice Floes (Rank 3)
		55091, .90, -- Cold as Ice (Rank 1)
		55092, .80, -- Cold as Ice (Rank 2)
	},
	[31687] = { -- Summon Water Elemental
		55091, .90, -- Cold as Ice (Rank 1)
		55092, .80, -- Cold as Ice (Rank 2)
	},
	[12043] = { -- Presence of Mind
		44378, .88, -- Arcane Flows (Rank 1)
		44379, .75, -- Arcane Flows (Rank 2)
	},
	[12042] = { -- Arcane Power
		44378, .88, -- Arcane Flows (Rank 1)
		44379, .75, -- Arcane Flows (Rank 2)
	},
	[66] = { -- Invisibility
		44378, .88, -- Arcane Flows (Rank 1)
		44379, .75, -- Arcane Flows (Rank 2)
	},
	-- Paladin
	[1044] = { -- Hand of Freedom
		85446, .9, -- Acts of Sacrifice (Rank 1)
		85795, .8, -- Acts of Sacrifice (Rank 2)
	},
	[1038] = { -- Hand of Salvation
		85446, .9, -- Acts of Sacrifice (Rank 1)
		85795, .8, -- Acts of Sacrifice (Rank 2)
	},
	[6940] = { -- Hand of Sacrifice
		85446, .9, -- Acts of Sacrifice (Rank 1)
		85795, .8, -- Acts of Sacrifice (Rank 2)
	},
	[26573] = {
		54928, 1.2, -- Glyph of Consecration
	},
	-- Priest
	[33076] = { -- Prayer of Mending (Rank 1)
		47562, .94, -- Divine Providence (Rank 1)
		47564, .88, -- Divine Providence (Rank 2)
		47565, .82, -- Divine Providence (Rank 3)
		47566, .76, -- Divine Providence (Rank 4)
		47567, .70, -- Divine Providence (Rank 5)
	},
	[88625] = { -- Holy Word: Chastise
		14898, .85, -- Tome of Light (Rank 1)
		81625, .70, -- Tome of Light (Rank 2)
	},
	[88684] = { -- Holy Word: Serenity
		14898, .85,
		81625, .70,
	},
	[88685] = { -- Holy Word: Sanctuary
		14898, .85,
		81625, .70,
	},
	-- Shaman
	-- Warlock
	[47193] = { -- Demonic Empowerment
		63117, .85, -- Nemesis (Rank 1)
		63121, .70, -- Nemesis (Rank 2)
	},
	[47241] = { -- Metamorphosis
		63117, .85, -- Nemesis (Rank 1)
		63121, .70, -- Nemesis (Rank 2)
	},
	[74434] = { -- Soulburn
		63117, .85, -- Nemesis (Rank 1)
		63121, .70, -- Nemesis (Rank 2)
	},
	-- Warrior
	[18499] = { -- Berserker Rage
		46908, .90, -- Intensify Rage (Rank 1)
		46909, .80, -- Intensify Rage (Rank 2)
	},
	[1719] = { -- Recklessness
		46908, .90, -- Intensify Rage (Rank 1)
		46909, .80, -- Intensify Rage (Rank 2)
	},
	[12292] = { -- Death Wish
		46908, .90, -- Intensify Rage (Rank 1)
		46909, .80, -- Intensify Rage (Rank 2)
	},
}

E.spell_chmod_talents = E.BLANK
E.spell_cdmod_by_haste = E.BLANK -- Aimed Shot CD no longer affected by ranged weapon speed

--
-- P\CD
--

E.spell_cdmod_by_aura_mult = E.BLANK

E.spell_noreset_onencounterend = { -- they added raid CD resets on ENCOUNTER_END to WOTLKC
	[20608] = true, -- Reincarnation
	[18540] = true, -- Ritual of Doom -- NYI
	[556] = true, -- Astral Recall -- not in db
	[633] = true, -- Lay on Hands
}

-- Classic
E.talentNameToRankIDs = {}

local temp = {}
for _, v in E.pairs(E.spell_cdmod_talents, E.spell_cdmod_talents_mult) do
	for k = 1, #v, 2 do
		local id = v[k]
		local name = GetSpellInfo(id)
		if name and not temp[id] then
			E.talentNameToRankIDs[name] = E.talentNameToRankIDs[name] or {}
			tinsert(E.talentNameToRankIDs[name], id) -- index=rank to talentID
			temp[id] = true
		end
	end
end

local itemBonus = {
	-- Druid
	[29166] = {
		37297, 48, -- Improved Innervate
	},
	[17116] = {
		37292, 24, -- Improved Nature's Swiftness
	},
	[20484] = {
		26106, 600, -- Genesis Rebirth Bonus
	},
	[18562] = {
		38417, 2, -- Reduced Swiftmend Cooldown
	},
	-- Hunter
	[5116] = { -- Concussive Shot
		23158, 1, -- Concussive Shot Cooldown Reduction
		24465, 1, -- Improved Concussive Shot
	},
	[1499] = { -- Freezing Trap
		37481, 4, -- Trap Cooldown
		61256, 2, -- Trap Cooldown Reduction
		61255, 2, -- Trap Shot Cooldown Reduction -- cata version (set bonus moved to hand equip bonus)
	},
	[13795] = { -- Immolation Trap
		37481, 4,
		61256, 2,
		61255, 2,
	},
	[13809] = { -- Ice Trap
		37481, 4,
		61256, 2,
		61255, 2,
	},
	[13813] = { -- Explosive Trap
		37481, 4,
		61256, 2,
		61255, 2,
	},
	[34600] = { -- Snake Trap
		37481, 4,
		61256, 2,
		61255, 2,
	},
	[3674] = { -- Black Arrow (considered as fire trap spell)
		37481, 4,
		61256, 2,
		61255, 2,
	},
	[5384] = {
		24432, 2, -- Improved Feign Death (Item equip bonus)
	},
	[2643] = {
		44292, 1, -- Improved Multi-Shot
	},
--	[3045] = {
--		26174, 120, -- Striker's Rapid Fire Bonus (20% proc chance)
--	},
	-- Mage
	[1953] = {
		23025, 2, -- Blink Cooldown Reduction
	},
	[11113] = {
		37439, 4, -- Cooldown Reduction - Blast Wave
	},
	[45438] = {
		37439, 40, -- Cooldown Reduction - Ice Block
	},
	[12043] = {
		37439, 24, -- Cooldown Reduction - Presence of Mind
	},
	[12051] = {
		28763, 60, -- Evocation
	},
	-- Paladin
	[20216] = {
		37183, 15, -- Divine Favor Cooldown
	},
	[853] = {
		23302, 10, -- Hammer of Justice Cooldown Reduction
	},
	[633] = {
		28774, 720, -- Lay Hands
	},
	[31789] = {
		37181, 2, -- Reduced Righteous Defense Cooldown
	},
	[20271] = {
		61776, 1, -- Judgement Cooldown Reduction - Judgement of Light
	},
	-- Priest
	[586] = {
		18388, 2, -- Quick Fade (Item equip bonus)
	},
	[8122] = {
		44297, 3, -- Improved Psychic Scream (Item equip bonus)
	},
	-- Rogue
	[2094] = {
		24469, 5, -- Improved Blind
	},
	[5277] = {
		26112, 60, -- Deathdealer Evasion Bonus
	},
	[1776] = {
		23048, 1, -- Gouge Cooldown Reduction
	},
	[1766] = {
		24434, 0.5, -- Improved Kick (Item equip bonus)
	},
	[1856] = { -- Vanish
		21874, 30, -- Improved Vanish
		14064, 60, -- Vanish Cooldown Reduction	-- TODO: Where is this from ???
	},
	-- Shaman
	[8177] = {
		44299, 3, -- Improved Grounding Totem -- cata 1.5>3s
	},
	[16188] = { -- Nature's Swiftness
		37211, 24, -- Improved Nature's Swiftness
		38466, 24, -- Nature's Swiftness Cooldown Reduction
		38499, 24, -- Nature's Swiftness Cooldown Reduction
	},
	[20608] = {
		27797, 600, -- Reduced Reincarnation Cooldown (Item equip bonus) -- TODO: relic slot
	},
	[17364] = {
		33018, 2, -- Shaman Stormstrike Cooldown Reduction (Rank 1)
	},
	-- Warrior
	[20252] = {
		22738, 5, -- Intercept Cooldown Reduction
	},
	[5246] = {
		24456, 15, -- improved Intimidating Shout
	},
	-- Cata
	[48020] = {
		33063, 5, -- Demonic Circle Cooldown Reduction
	},
	[6789] = {
		23047, 30, -- Death Coil Cooldown Reduction
	},
}
local itemBonusMult = {
	-- Druid
	[740] = { 23556, .85 }, -- Tranquility		Decreased Tranquility and Hurricane Effect -- JANUARY 31, 2023 Hotfixed 50>15%
	-- Warlock
	[6789] = { 24487, .85 }, -- Death Coil		Improved Death Coil
}
local function MergeTable(src, dest)
	for id, t in pairs(src) do
		dest[id] = dest[id] or {}
		for i = 1, #t do
			local v = t[i]
			tinsert(dest[id], v)
		end
	end
end
MergeTable(itemBonus, E.spell_cdmod_talents)
MergeTable(itemBonusMult, E.spell_cdmod_talents_mult)
itemBonus = nil
itemBonusMult = nil

--
-- CD\CD
--

E.spell_linked = { -- Abilities that shared the full cd duration
	[1499] = { 1499, 13809 }, -- Freezing Trap	-- WOTLKC fire/frost traps are now separate
	[13809] = { 1499, 13809 }, -- Ice Trap
	[13813] = { 13813, 13795, 3674 }, -- Explosive Trap
	[13795] = { 13813, 13795, 3674 }, -- Immolation Trap
	[3674] = { 13813, 13795, 3674 }, -- Black Arrow
	-- WOTLKC Snake Trap isn't linked
	[8042] = { 8042, 8050, 8056 }, -- Earth Shock (Rank 1)	-- diff spell-types
	[8050] = { 8042, 8050, 8056 }, -- Flame Shock (Rank 1)
	[8056] = { 8042, 8050, 8056 }, -- Frost Shock (Rank 1)
	[6552] = { 6552, 72 }, -- Shield Bash 12s cd (shared cd is also 12s)
	[72] = { 6552, 72 }, -- Pummel 10s cd (shared cd is also 10s)
	[1122] = { 1122, 18540 }, -- Summon Infernal
	[18540] = { 1122, 18540 }, -- Summon Doomguard
}

E.spell_merged = {
	-- Druid
	[80965] = 80964, -- Skull Bash (Cat Form)
	[77764] = 77761, -- Stampeding Roar (Cat Form)
	-- Hunter
	[60192] = 1499, -- Freezing Trap (Trap Launcher)
	[82941] = 13809, -- Ice Trap (Trap Launcher)
	[82945] = 13795, -- Immolation Trap (Trap Launcher)
	[82939] = 13813, -- Explosive Trap (Trap Launcher)
	[82948] = 34600, -- Snake Trap (Trap Launcher)
	-- Shaman
	[32182] = 2825, -- Heroism
	-- Racial
	[33697] = 20572, -- Blood Fury (Shaman)
	[33702] = 20572, -- Blood Fury (Warlock)
	[25046] = 28730, -- Arcane Torrent (Rogue)
	[50613] = 28730, -- Arcane Torrent (DK)
	[59547] = 28880, -- Gift of the Naaru (Shaman)
	[59545] = 28880, -- Gift of the Naaru (DK)
	[59548] = 28880, -- Gift of the Naaru (Mage)
	[59544] = 28880, -- Gift of the Naaru (Priest)
	[59543] = 28880, -- Gift of the Naaru (Hunter)
	[59542] = 28880, -- Gift of the Naaru (Paladin)
	-- Trinket
	[55915] = 44055, -- Tremendous Fortitude (phase 1, ilvl 213)
	[67596] = 44055, -- Tremendous Fortitude (phase 3, ilvl 245)
	-- spell_merged_updateoncast
	[57386] = 26090, -- Stampede (Rank 1)
	[50433] = 26090, -- Bad Attitude (Rank 1)
	[50245] = 26090, -- Pin (Rank 1)
	[50285] = 26090, -- Dust Cloud
	[50479] = 26090, -- Nether Shock (Rank 1)
	[50519] = 26090, -- Sonic Blast (Rank 1)
	[50541] = 26090, -- Snatch (Rank 1)
	[4167] = 26090, -- Web (Rank 1 - no other rank info)
	[50518] = 26090, -- Ravage (Rank 1)
	[4511] = 19647, -- Felhunter: Phase Shift
	[7814] = 19647, -- Succubus: Lash of Pain (Rank 1)
	[7812] = 19647, -- Voidwalker: Sacrifice (Rank 1)
	[30151] = 19647, -- Felguard: Intercept
}

-- Classic
local talentRanks = { -- talent spells (not modifiers)
	-- Death Knight
	{ 49203 }, -- Hungering Cold
	{ 49222 }, -- Bone Shield
	{ 48982 }, -- Rune Tap
	{ 51271 }, -- Pillar of Frost
	{ 55233 }, -- Vampiric Blood
	{ 51052 }, -- Anti-Magic Zone
	{ 49028 }, -- Dancing Rune Weapon
	{ 63560 }, -- Dark Transformation
	{ 49184 }, -- Howling Blast
	{ 49016 }, -- Unholy Frenzy
	{ 49206 }, -- Summon Gargoyle
	{ 49039 }, -- Lichborne
	{ 49588, 49589 }, -- Unholy Command
	{ 52284, 81163, 81164 }, -- Will of the Necropolis
	-- Druid
	{ 33831 }, -- Force of Nature
	{ 17116 }, -- Nature's Swiftness*
	{ 18562 }, -- Swiftmend
	{ 16689 }, -- Nature's Grasp
	{ 50334 }, -- Berserk
	{ 16940, 16941 }, -- Brutal Impact
	{ 49377 }, -- Feral Charge (talent id for inspect)
	{ 33878 }, -- Mangle (Bear)
	{ 48505 }, -- Starfall
	{ 61336 }, -- Survival Instincts
	{ 50516 }, -- Typhoon
	{ 48438 }, -- Wild Growth
	{ 33891 }, -- Tree of Life
	{ 78674 }, -- Starsurge
	{ 78675 }, -- Solar Beam
	-- Hunter
	{ 19574 }, -- Bestial Wrath
	{ 19577 }, -- Intimidation
	{ 23989 }, -- Readiness
	{ 19503 }, -- Scatter Shot
	{ 34490 }, -- Silencing Shot
	{ 19434 }, -- Aimed Shot
	{ 19306 }, -- Counterattack
	{ 19386 }, -- Wyvern Sting
	{ 3674 }, -- Black Arrow
	{ 53301 }, -- Explosive Shot
	{ 53209 }, -- Chimera Shot
	{ 82726 }, -- Fervor
	{ 82692 }, -- Focus Fire
	{ 82898, 82899 }, -- Crouching Tiger, Hidden Chimera
	{ 56829 }, -- Glyph of Misdirection
	-- Mage
	{ 12042 }, -- Arcane Power
	{ 11958 }, -- Cold Snap
	{ 11129 }, -- Combustion
	{ 12472 }, -- Icy Veins
	{ 12043 }, -- Presence of Mind
	{ 31687 }, -- Summon Water Elemental
	{ 11113 }, -- Blast Wave
	{ 31661 }, -- Dragon's Breath
	{ 11426 }, -- Ice Barrier
	{ 44425 }, -- Arcane Barrage
	{ 44572 }, -- Deep Freeze
	{ 86948, 86949 }, -- Cauterize
	-- Paladin
	{ 35395 }, -- Crusader Strike
	{ 31842 }, -- Divine Favor
	{ 31842 }, -- Divine Illumination
	{ 20066 }, -- Repentance
	{ 31935 }, -- Avenger's Shield
	{ 20925 }, -- Holy Shield
	{ 20473 }, -- Holy Shock
	{ 31821 }, -- Aura Mastery
	{ 31850 }, -- Ardent Defender
	{ 64205 }, -- Divine Sacrifice
	{ 53385 }, -- Divine Storm
	{ 93418, 93417 }, -- Paragon of Virtue
	{ 70940 }, -- Divine Guardian
	{ 85696 }, -- Zealotry
	{ 75806, 85043 }, -- Grand Crusader
	-- Priest
	{ 89485 }, -- Inner Focus
	{ 33206 }, -- Pain Suppression
	{ 10060 }, -- Power Infusion
	{ 15487 }, -- Silence
	{ 724 }, -- Lightwell
	{ 47540 }, -- Penance
	{ 19236 }, -- Desperate Prayer
	{ 34861 }, -- Circle of Healing
	{ 47788 }, -- Guardian Spirit
	{ 64044 }, -- Psychic Horror
	{ 47585 }, -- Dispersion
	{ 62618 }, -- Power Word: Barrier
	{ 14898, 81625 }, -- Tome of Light
	{ 14751 }, -- Chakra
	{ 92295, 92297 }, -- Train of Thought
	{ 88625 }, -- Holy Word: Chastise
	-- Rogue
	{ 13750 }, -- Adrenaline Rush
	{ 13877 }, -- Blade Flurry
	{ 14177 }, -- Cold Blood
	{ 14183 }, -- Premeditation
	{ 14185 }, -- Preparation
	{ 14251 }, -- Riposte
	{ 36554 }, -- Shadowstep
	{ 51690 }, -- Killing Spree
	{ 31228, 31229, 31230 }, -- Cheat Death
	{ 51713 }, -- Shadow Dance
	{ 79140 }, -- Vendetta
	-- Shaman
	{ 16166 }, -- Elemental Mastery
	{ 16190 }, -- Mana Tide Totem
	{ 16188 }, -- Nature's Swiftness*
	{ 30823 }, -- Shamanistic Rage
	{ 17364 }, -- Stormstrike
	{ 51490 }, -- Thunderstorm
	{ 60103 }, -- Lava Lash
	{ 51533 }, -- Feral Spirit
	{ 30881, 30883, 30884 }, -- Nature's Guardian
	{ 61295 }, -- Riptide
	{ 55198 }, -- Tidal Force
	{ 86183, 86184, 86185 }, -- Feedback
	{ 98008 }, -- Spirit Link Totem
	{ 16190 }, -- Mana Tide Totem
	-- Warlock
	{ 18708 }, -- Fel Domination
	{ 17877 }, -- Shadowburn
	{ 30283 }, -- Shadowfury
	{ 48181 }, -- Haunt
	{ 47193 }, -- Demonic Empowerment
	{ 59672 }, -- Metamorphosis
	{ 50796 }, -- Chaos Bolt
	{ 30146 }, -- Summon Felguard
	{ 17962 }, -- Conflagrate
	{ 91713 }, -- Nether Ward
	{ 85106, 85107, 85108 }, -- Impending Doom
	{ 86121 }, -- Soul Swap
	-- Warrior
	{ 12809 }, -- Concussion Blow
	{ 12292 }, -- Death Wish
	{ 12975 }, -- Last Stand
	{ 12328 }, -- Sweeping Strikes
	{ 12294 }, -- Mortal Strike
	{ 23922 }, -- Shield Slam
	{ 46924 }, -- Bladestorm
	{ 60970 }, -- Heroic Fury
	{ 23881 }, -- Bloodthirst
	{ 46968 }, -- Shockwave
	{ 12311, 12958 }, -- Gag Order (talent id for inspect)
	{ 85730 }, -- Deadly Calm
	{ 85388 }, -- Throwdown
}
-- Merge talent ranks
for i = 1, #talentRanks do
	local t = talentRanks[i]
	local rank1 = t[1]
	rank1 = E.spell_merged[rank1] or rank1
	local name = GetSpellInfo(rank1)
	if name then
		for j = 2, #t do
			local rankN = t[j]
			E.spell_merged[rankN] = rank1
--			if not C_Spell.DoesSpellExist(rankN) then
--				print("Invalid rank" .. j .. "talent ID:", rankN)
--			end
		end

		-- Need to add all duplicate named talents as nested tables for inspect; index is rank
		local dupe = E.talentNameToRankIDs[name]
		if dupe then
			if type(dupe[1]) == "table" then
				tinsert(E.talentNameToRankIDs[name], t)
			else
				E.talentNameToRankIDs[name] = { dupe, t }
			end
		else
			E.talentNameToRankIDs[name] = t
		end
--	else
--		print("Invalid rank1 talent ID:", rank1)
	end
end

E.spell_merged_updateoncast = {
	[26090]={30}, -- Pummel
	[57386]={60}, [57389]={60}, [57390]={60}, [57391]={60}, [57392]={60}, [57393]={60}, -- Stampede
	[50245]={40}, [53544]={40}, [53545]={40}, [53546]={40}, [53547]={40}, [53548]={40}, -- Pin
	[50285]={40}, -- Dust Cloud
	[50479]={40}, [53584]={40}, [53586]={40}, [53587]={40}, [53588]={40}, [53589]={40}, -- Nether Shock
	[50519]={60}, [53564]={60}, [53565]={60}, [53566]={60}, [53567]={60}, [53568]={60}, -- Sonic Blast
	[50541]={60}, [53537]={60}, [53538]={60}, [53540]={60}, [53542]={60}, [53543]={60}, -- Snatch
	[4167]={40}, -- Web (Rank 1 - no other rank info)
	[50518]={40}, [53558]={40}, [53559]={40}, [53560]={40}, [53561]={40}, [53562]={40}, -- Ravage
	[50433]={120}, [52395]={120}, [52396]={120}, [52397]={120}, [52398]={120}, [52399]={120}, -- Bad Attitude
	[19647]={24}, -- Spell Lock
	[7812]={60}, [19438]={60}, [19440]={60}, [19441]={60}, [19442]={60}, [19443]={60}, [27273]={60}, [47985]={60}, [47986]={60}, -- Sacrifice
	[30151]={30}, [30194]={30}, [30198]={30}, [47996]={30}, -- Intercept
	[7814]={12}, [7815]={12}, [7816]={12}, [11778]={12}, [11779]={12}, [11780]={12}, [27274]={12}, -- Lash of Pain
}
for k, v in pairs(E.spell_merged_updateoncast) do
	if not v[2] then
		local _, icon = GetSpellTexture(k)
		v[2] = icon
	end
end

E.spellcast_shared_cdstart = {
	[42292] = { 59752, 120, 7744, 30 }, -- PvP Trinket -- Cata 45>30s with Will
	[59752] = { 42292, 120 }, -- Will to Survive
	[7744] = { 42292, 30 }, -- Will of the Forsaken
	[2894] = { 2062, 120 }, -- Fire Elemetal Totem (lasts 2 min = shared CD)
	[2062] = { 2894, 120 }, -- Earth Elemental Totem
	[16979] = { 49376, 15 }, -- Feral Charge-Bear (force 15s shared, Cat cd is 30 but shared cd is 15 only)
	[49376] = { 16979, 15 }, -- Feral Charge-Cat (force 15s shared, Cat cd is 30 but shared cd is 15 only)
	[871] = { 1719, 12, 20230, 12 }, -- Shield Wall	-- NOTE: no longer linked in WOTLKC
	[1719] = { 871, 12, 20230, 12 }, -- Recklessness
	[20230] = { 1719, 12, 871, 12 }, -- Retaliation
}

E.spellcast_cdreset = {
	[23989] = { -- Readiness
		nil, -- first key value = required talent check in cooldowns\cooldowns
		"*",
	},
	[11958] = { -- Cold Snap
		nil,
		45438, -- Ice Block
		11426, -- Ice Barrier
		120, -- Cone of Cold
		122, -- Frost Nova
		12472, -- Icy Veins
		6143, -- Frost Ward
		44572, -- Deep Freeze
		31687, -- Summon Water Elemental
		82676, -- Ring of Frost
	},
	[45438] = { -- Ice Block
		56372, -- Glyph of Ice Block
		122, -- Frost Nova
	},
	[14185] = { -- Preparation
		nil,
		2983, -- Sprint
		1856, -- Vanish
		36554, -- Shadowstep
		{ -- additional resets w/ talent
			56819, -- Glyph of Preparation	-- talent check
			76577, -- Smoke Bomb
			51722, -- Dismantle
			1766, -- Kick
		},
	},
	[60970] = { -- Heroic Fury
		nil,
		20252, -- Intercept
	}
}

E.spellcast_cdr = E.BLANK
E.spellcast_cdr_powerspender = E.BLANK
E.sync_cdr_by_powerconsumed = E.BLANK

--
-- CD\CLEU (NOTE: incl all ranks)
--

E.spell_aura_freespender = E.BLANK

E.spell_auraremoved_cdstart_preactive = {
	[17116] = 17116, -- Nature's Swiftness
	[5215] = 5215, -- Prowl
	[34477] = 34477, -- Misdirection
	[12043] = 12043, -- POM
	[14177] = 14177, -- Cold Blood
	[1784] = 1784, -- Stealth
	[16188] = 16188, -- Nature's Swiftness (Shaman)
	[28682] = 11129, -- Combustion - castID = spellID
	[89485] = 89485, -- Inner Focus
	[16166] = 16166, -- Elemental Mastery
	[5384] = 0, -- Feign Death -> own UNIT_AURA
}

E.spell_auraapplied_processspell = {
	[87023] = 86948, -- Cauterized
	[66233] = 31850, -- Ardent Defender
	[45182] = 31228, -- Cheating Death
	[31616] = 30881, -- Nature's Guardian
}

E.spell_dispel_cdstart = E.BLANK

E.selfLimitedMinMaxReducer = E.BLANK
E.spell_damage_cdr_totem = E.BLANK
E.spell_damage_cdr_pet = E.BLANK
E.spell_damage_cdr = E.BLANK
E.spell_energize_cdr = E.BLANK
E.spell_interrupt_cdr = E.BLANK
E.cdrr_heartstopaura_blackList = E.BLANK
E.runeforge_bonus_to_descid = E.BLANK
E.runeforge_specid = E.BLANK
E.runeforge_desc_to_powerid = E.BLANK
E.runeforge_unity = E.BLANK
E.covenant_to_spellid = E.BLANK
E.covenant_abilities = E.BLANK
E.spell_benevolent_faerie_majorcd = E.BLANK
E.covenant_cdmod_conduits = E.BLANK
E.covenant_chmod_conduits = E.BLANK
E.covenant_cdmod_items_mult = E.BLANK
E.soulbind_conduits_rank = E.BLANK
E.soulbind_abilities = E.BLANK
E.spell_cdmod_conduits = E.BLANK
E.spell_cdmod_conduits_mult = E.BLANK
E.spell_symbol_of_hope_majorcd = E.BLANK
E.spell_major_cd = E.BLANK

--
-- CM\INS
--

E.item_merged = {
	-- PvP Trinket: item - Medallion of the Alliance (phase 1, 128, TBC)
	[33046] = 37864, -- Insignia of PvP Pwn
	[28235] = 37864, -- Medallion of the Alliance (Druid)
	[30348] = 37864, -- Medallion of the Alliance (Warlock)
	[28238] = 37864, -- Medallion of the Alliance (Mage)
	[30351] = 37864, -- Medallion of the Alliance (Shaman)
	[28236] = 37864, -- Medallion of the Alliance (Paladin)
	[30349] = 37864, -- Medallion of the Alliance (Priest)
	[28234] = 37864, -- Medallion of the Alliance (Rogue)
	[28237] = 37864, -- Medallion of the Alliance (Hunter)
	[30350] = 37864, -- Medallion of the Alliance (Warrior)
	[37865] = 37864, -- Medallion of the Horde
	[28240] = 37864, -- Medallion of the Horde (Rogue)
	[28243] = 37864, -- Medallion of the Horde (Hunter)
	[30345] = 37864, -- Medallion of the Horde (Shaman)
	[28241] = 37864, -- Medallion of the Horde (Druid)
	[30343] = 37864, -- Medallion of the Horde (Warlock)
	[28239] = 37864, -- Medallion of the Horde (Mage)
	[30346] = 37864, -- Medallion of the Horde (Priest)
	[28242] = 37864, -- Medallion of the Horde (Paladin)
	[30344] = 37864, -- Medallion of the Horde (Warrior)
	[42123] = 37864, -- Medallion of the Alliance (phase 1, 200, WOTLKC)
	[42124] = 37864, -- Medallion of the Alliance (phase 2, 226)
	[51377] = 37864, -- Medallion of the Alliance (phase 4, 264)
	[42122] = 37864, -- Medallion of the Horde (phase 1, 200)
	[42126] = 37864, -- Medallion of the Horde (phase 2, 226)
	[51378] = 37864, -- Medallion of the Horde (phase 4, 264)
	[46081] = 37864, -- Titan-Forged Rune of Audacity -- WOTLKC req# (src: Wintergrasp)
	[46082] = 37864, -- Titan-Forged Rune of Determination -- WOTLKC req#
	[46083] = 37864, -- Titan-Forged Rune of Accuracy -- WOTLKC req#
	[46084] = 37864, -- Titan-Forged Rune of Cruelty -- WOTLKC req#
	[46085] = 37864, -- Titan-Forged Rune of Alacrity -- WOTLKC req#
	-- PvP Trinket: item2 - Insignia of the Alliance (Mage)
	[44098] = 18859, -- Inherited Insignia of the Alliance (heirloom) -- WOTLKC
	[40476] = 18859, -- Insignia of the Alliance -- WOTLKC
	[29593] = 18859, -- Insignia of the Alliance (Shaman)
	[18857] = 18859, -- Insignia of the Alliance (Rogue)
	[18864] = 18859, -- Insignia of the Alliance (Paladin)
	[18854] = 18859, -- Insignia of the Alliance (Warrior)
	[18862] = 18859, -- Insignia of the Alliance (Priest)
	[18858] = 18859, -- Insignia of the Alliance (Warlock)
	[18856] = 18859, -- Insignia of the Alliance (Hunter)
	[18863] = 18859, -- Insignia of the Alliance (Druid)
	[44097] = 18859, -- Inherited Insignia of the Horde (heirloom) -- WOTLKC
	[40477] = 18859, -- Insignia of the Horde -- WOTLKC
	[18850] = 18859, -- Insignia of the Horde (Mage)
	[18845] = 18859, -- Insignia of the Horde (Shaman)
	[18849] = 18859, -- Insignia of the Horde (Rogue)
	[29592] = 18859, -- Insignia of the Horde (Paladin)
	[18834] = 18859, -- Insignia of the Horde (Warrior)
	[18851] = 18859, -- Insignia of the Horde (Priest)
	[18852] = 18859, -- Insignia of the Horde (Warlock)
	[18846] = 18859, -- Insignia of the Horde (Hunter)
	[18853] = 18859, -- Insignia of the Horde (Druid)
	-- Trinket: item - Battlemaster's Perseverance - Tremendous Fortitude 44055
	[34049] = 34050, -- Battlemaster's Determination
	[34578] = 34050, -- Battlemaster's Determination
	[34163] = 34050, -- Battlemaster's Cruelty
	[34579] = 34050, -- Battlemaster's Audacity
	[33832] = 34050, -- Battlemaster's Determination
	[34576] = 34050, -- Battlemaster's Cruelty
	[35326] = 34050, -- Battlemaster's Alacrity
	[34580] = 34050, -- Battlemaster's Perseverance
	[35327] = 34050, -- Battlemaster's Alacrity
	[34162] = 34050, -- Battlemaster's Depravity
	[34577] = 34050, -- Battlemaster's Depravity
	-- ilvl 156
	[41588] = 34050, -- Battlemaster's Aggression
	[41587] = 34050, -- Battlemaster's Celerity
	[41590] = 34050, -- Battlemaster's Courage
	[41589] = 34050, -- Battlemaster's Resolve
	-- phase 1, ilvl 213 - Tremendous Fortitude 55915
	[42129] = 34050, -- Battlemaster's Accuracy
	[42130] = 34050, -- Battlemaster's Avidity
	[42132] = 34050, -- Battlemaster's Bravery
	[42131] = 34050, -- Battlemaster's Conviction
	[42128] = 34050, -- Battlemaster's Hostility
	-- phase 3, ilvl 245 - Tremendous Fortitude 67596
	[42133] = 34050, -- Battlemaster's Fury
	[42134] = 34050, -- Battlemaster's Precision
	[42136] = 34050, -- Battlemaster's Rage
	[42137] = 34050, -- Battlemaster's Ruination
	[42135] = 34050, -- Battlemaster's Vivacity

	-- Cata
	[64789] = 37864, -- Bloodthirsty Gladiator's Medallion of Cruelty
	[64792] = 37864, -- Bloodthirsty Gladiator's Medallion of Meditation
	[64794] = 37864, -- Bloodthirsty Gladiator's Medallion of Tenacity
	[64790] = 37864, -- Bloodthirsty Gladiator's Medallion of Cruelty (A)
	[64791] = 37864, -- Bloodthirsty Gladiator's Medallion of Meditation (A)
	[64793] = 37864, -- Bloodthirsty Gladiator's Medallion of Tenacity (A)
	[60795] = 37864, -- Vicious Gladiator's Medallion of Accuracy
	[60802] = 37864, --
	[60796] = 37864, -- Vicious Gladiator's Medallion of Alacrity
	[60803] = 37864, --
	[60798] = 37864, -- Vicious Gladiator's Medallion of Command
	[60805] = 37864, --
	[60794] = 37864, -- Vicious Gladiator's Medallion of Cruelty
	[60801] = 37864, --
	[70602] = 37864, --
	[70603] = 37864, --
	[60799] = 37864, -- Vicious Gladiator's Medallion of Meditation
	[60806] = 37864, --
	[70604] = 37864, --
	[70605] = 37864, --
	[60797] = 37864, -- Vicious Gladiator's Medallion of Prowess
	[60804] = 37864, --
	[60800] = 37864, -- Vicious Gladiator's Medallion of Tenacity
	[60807] = 37864, --
	[70606] = 37864, --
	[70607] = 37864, --
	-- Tremendous Fortitude 92223
	[64741] = 64740, -- Bloodthirsty Gladiator's Emblem of Meditation
	[64742] = 64740, -- Bloodthirsty Gladiator's Emblem of Tenacity
	[70565] = 64740, -- Vicious Gladiator's Emblem of Tenacity
	[61032] = 64740, -- Vicious Gladiator's Emblem of Tenacity
	[61029] = 64740, -- Vicious Gladiator's Emblem of Prowess
	[61030] = 64740, -- Vicious Gladiator's Emblem of Proficiency
	[70564] = 64740, -- Vicious Gladiator's Emblem of Meditation
	[61031] = 64740, -- Vicious Gladiator's Emblem of Meditation
	[70563] = 64740, -- Vicious Gladiator's Emblem of Cruelty
	[61026] = 64740, -- Vicious Gladiator's Emblem of Cruelty
	[61028] = 64740, -- Vicious Gladiator's Emblem of Alacrity
	[61027] = 64740, -- Vicious Gladiator's Emblem of Accuracy
	-- Badge
	[64688] = 64687, -- Bloodthirsty Gladiator's Badge of Dominance
	[64689] = 64687, -- Bloodthirsty Gladiator's Badge of Victory
	[70519] = 64687, -- Vicious Gladiator's Badge of Victory
	[61034] = 64687, -- Vicious Gladiator's Badge of Victory
	[70518] = 64687, -- Vicious Gladiator's Badge of Dominance
	[61035] = 64687, -- Vicious Gladiator's Badge of Dominance
	[70517] = 64687, -- Vicious Gladiator's Badge of Conquest
	[61033] = 64687, -- Vicious Gladiator's Badge of Conquest
}

E.item_equip_bonus = {
	[19617] = 24434, -- Zandalarian Shadow Mastery Talisman
	[14154] = 18388, -- Truefaith Vestments
	[33717] = 44297, -- Vengeful Gladiator's Mooncloth Gloves (season 3)
	[33744] = 44297, -- Vengeful Gladiator's Satin Gloves
	[35053] = 44297, -- Brutal Gladiator's Mooncloth Gloves (season 4)
	[35083] = 44297, -- Brutal Gladiator's Satin Gloves
	[41847] = 44297, -- Savage Gladiator's Mooncloth Gloves (season 5 - WOTLKC)
	[41937] = 44297, -- Savage Gladiator's Satin Gloves
	[41872] = 44297, -- Hateful Gladiator's Mooncloth Gloves
	[41938] = 44297, -- Hateful Gladiator's Satin Gloves
	[41873] = 44297, -- Deadly Gladiator's Mooncloth Gloves
	[41939] = 44297, -- Deadly Gladiator's Satin Gloves
	[41874] = 44297, -- Furious Gladiator's Mooncloth Gloves
	[41940] = 44297, -- Furious Gladiator's Satin Gloves
	[41875] = 44297, -- Relentless Gladiator's Mooncloth Gloves
	[41941] = 44297, -- Relentless Gladiator's Satin Gloves
	[51483] = 44297, -- Wrathful Gladiator's Mooncloth Gloves
	[51488] = 44297, -- Wrathful Gladiator's Satin Gloves
	[22345] = 20608, -- Totem of Rebirth
	[19621] = 24432, -- Maelstrom's Wrath

	-- Cata
	[64709] = 61255, -- Bloodthirsty Gladiator's Chain Gauntlets,	Trap Shot Cooldown Reduction
	[60424] = 61255, -- Vicious Gladiator's Chain Gauntlets 365
	[65544] = 61255, -- Vicious Gladiator's Chain Gauntlets 365
	[70534] = 61255, -- Vicious Gladiator's Chain Gauntlets 371
	[64795] = 44297, -- Bloodthirsty Gladiator's Mooncloth Gloves,	Improved Psychic Scream
	[60468] = 44297, -- Vicious Gladiator's Mooncloth Gloves 365
	[65556] = 44297, -- Vicious Gladiator's Mooncloth Gloves 365
	[70608] = 44297, -- Vicious Gladiator's Mooncloth Gloves 371
	[64838] = 44297, -- Bloodthirsty Gladiator's Satin Gloves
	[60473] = 44297, -- Vicious Gladiator's Satin Gloves 365
	[65577] = 44297, -- Vicious Gladiator's Satin Gloves 365
	[70643] = 44297, -- Vicious Gladiator's Satin Gloves 371
	[64747] = 33063, -- Bloodthirsty Gladiator's Felweave Handguards,	Demonic Circle Cooldown Reduction
	[60478] = 33063, -- Vicious Gladiator's Felweave Handguards 365,
	[65572] = 33063, -- Vicious Gladiator's Felweave Handguards 365,
	[70568] = 33063, -- Vicious Gladiator's Felweave Handguards 371
}

local class_set_bonus = {
	druid	= { 38417, 4 }, -- Reduced Swiftmend Cooldown
	hunter	= { 61256, 4 }, -- Trap Cooldown Reduction -- cata moved to hand equipped bonus
	paladin	= { 61776, 4 }, -- Judgement Cooldown Reduction
	shaman	= { 44299, 4 }, -- Improved Grounding Totem (resto, ele)
	enhance	= { 33018, 4 }, -- Shaman Stormstrike Cooldown Reduction -- cata removed
	warrior	= { 22738, 4 }, -- Intercept Cooldown Reduction -- cata removed
	warlock = { 23047, 4 }, -- Death Coil Cooldown Reduction -- cata added
}

E.item_set_bonus = { -- [item] = {bonusID, required num of set items}
	-- Druid
	[16828] = { 23556, 8 }, -- Cenarion Belt
	[16829] = { 23556, 8 }, -- Cenarion Boots
	[16830] = { 23556, 8 }, -- Cenarion Bracers
	[16833] = { 23556, 8 }, -- Cenarion Vestments
	[16831] = { 23556, 8 }, -- Cenarion Gloves
	[16834] = { 23556, 8 }, -- Cenarion Helm
	[16835] = { 23556, 8 }, -- Cenarion Leggings
	[16836] = { 23556, 8 }, -- Cenarion Spaulders
	[29087] = { 37292, 4 }, -- Chestguard of Malorne
	[29086] = { 37292, 4 }, -- Crown of Malorne
	[29090] = { 37292, 4 }, -- Handguards of Malorne
	[29088] = { 37292, 4 }, -- Legguards of Malorne
	[29089] = { 37292, 4 }, -- Shoulderguards of Malorne
	[31041] = { 38417, 2 }, -- Thunderheart Tunic
	[31032] = { 38417, 2 }, -- Thunderheart Gloves
	[31037] = { 38417, 2 }, -- Thunderheart Helmet
	[31045] = { 38417, 2 }, -- Thunderheart Legguards
	[31047] = { 38417, 2 }, -- Thunderheart Spaulders
	[34571] = { 38417, 2 }, -- Thunderheart Boots
	[34445] = { 38417, 2 }, -- Thunderheart Bracers
	[34554] = { 38417, 2 }, -- Thunderheart Belt
	[21355] = { 26106, 5 }, -- Genesis Boots
	[21353] = { 26106, 5 }, -- Genesis Helm
	[21354] = { 26106, 5 }, -- Genesis Shoulderpads
	[21356] = { 26106, 5 }, -- Genesis Trousers
	[21357] = { 26106, 5 }, -- Genesis Vest
	[29093] = { 37297, 4 }, -- Antlers of Malorne
	[29094] = { 37297, 4 }, -- Britches of Malorne
	[29091] = { 37297, 4 }, -- Chestpiece of Malorne
	[29092] = { 37297, 4 }, -- Gloves of Malorne
	[29095] = { 37297, 4 }, -- Pauldrons of Malorne
	-- arena season 5 (WOTLKC)
	[41268] = class_set_bonus.druid, -- Savage Gladiator's Kodohide Gloves
	[41269] = class_set_bonus.druid, -- Savage Gladiator's Kodohide Helm
	[41270] = class_set_bonus.druid, -- Savage Gladiator's Kodohide Legguards
	[41271] = class_set_bonus.druid, -- Savage Gladiator's Kodohide Spaulders
	[41272] = class_set_bonus.druid, -- Savage Gladiator's Kodohide Robes
	[41284] = class_set_bonus.druid, -- Hateful Gladiator's Kodohide Gloves
	[41319] = class_set_bonus.druid, -- Hateful Gladiator's Kodohide Helm
	[41296] = class_set_bonus.druid, -- Hateful Gladiator's Kodohide Legguards
	[41273] = class_set_bonus.druid, -- Hateful Gladiator's Kodohide Spaulders
	[41308] = class_set_bonus.druid, -- Hateful Gladiator's Kodohide Robes
	[41286] = class_set_bonus.druid, -- Deadly Gladiator's Kodohide Gloves
	[41320] = class_set_bonus.druid, -- Deadly Gladiator's Kodohide Helm
	[41297] = class_set_bonus.druid, -- Deadly Gladiator's Kodohide Legguards
	[41274] = class_set_bonus.druid, -- Deadly Gladiator's Kodohide Spaulders
	[41309] = class_set_bonus.druid, -- Deadly Gladiator's Kodohide Robes
	-- arena season 6 (WOTLKC)
	[41287] = class_set_bonus.druid, -- Furious Gladiator's Kodohide Gloves
	[41321] = class_set_bonus.druid, -- Furious Gladiator's Kodohide Helm
	[41298] = class_set_bonus.druid, -- Furious Gladiator's Kodohide Legguards
	[41275] = class_set_bonus.druid, -- Furious Gladiator's Kodohide Spaulders
	[41310] = class_set_bonus.druid, -- Furious Gladiator's Kodohide Robes
	-- arena season 7 (WOTLKC)
	[41288] = class_set_bonus.druid, -- Relentless Gladiator's Kodohide Gloves
	[41322] = class_set_bonus.druid, -- Relentless Gladiator's Kodohide Helm
	[41299] = class_set_bonus.druid, -- Relentless Gladiator's Kodohide Legguards
	[41276] = class_set_bonus.druid, -- Relentless Gladiator's Kodohide Spaulders
	[41311] = class_set_bonus.druid, -- Relentless Gladiator's Kodohide Robes
	-- arena season 8 (WOTLKC)
	[51420] = class_set_bonus.druid, -- Wrathful Gladiator's Kodohide Gloves
	[51421] = class_set_bonus.druid, -- Wrathful Gladiator's Kodohide Helm
	[51422] = class_set_bonus.druid, -- Wrathful Gladiator's Kodohide Legguards
	[51424] = class_set_bonus.druid, -- Wrathful Gladiator's Kodohide Spaulders
	[51419] = class_set_bonus.druid, -- Wrathful Gladiator's Kodohide Robes

	-- Hunter
	[28228] = { 37481, 2 }, -- Beast Lord Cuirass
	[27474] = { 37481, 2 }, -- Beast Lord Handguards
	[28275] = { 37481, 2 }, -- Beast Lord Helm
	[27874] = { 37481, 2 }, -- Beast Lord Leggings
	[27801] = { 37481, 2 }, -- Beast Lord Mantle
	[28334] = { 44292, 4 }, -- Gladiator's Chain Armor
	[28335] = { 44292, 4 }, -- Gladiator's Chain Gauntlets
	[28331] = { 44292, 4 }, -- Gladiator's Chain Helm
	[28332] = { 44292, 4 }, -- Gladiator's Chain Leggings
	[28333] = { 44292, 4 }, -- Gladiator's Chain Spaulders
	[31960] = { 44292, 4 }, -- Merciless Gladiator's Chain Armor
	[31961] = { 44292, 4 }, -- Merciless Gladiator's Chain Gauntlets
	[31962] = { 44292, 4 }, -- Merciless Gladiator's Chain Helm
	[31963] = { 44292, 4 }, -- Merciless Gladiator's Chain Leggings
	[31964] = { 44292, 4 }, -- Merciless Gladiator's Chain Spaulders
	[33664] = { 44292, 4 }, -- Vengeful Gladiator's Chain Armor
	[33665] = { 44292, 4 }, -- Vengeful Gladiator's Chain Gauntlets
	[33666] = { 44292, 4 }, -- Vengeful Gladiator's Chain Helm
	[33667] = { 44292, 4 }, -- Vengeful Gladiator's Chain Leggings
	[33668] = { 44292, 4 }, -- Vengeful Gladiator's Chain Spaulders
	[34990] = { 44292, 4 }, -- Brutal Gladiator's Chain Armor
	[34991] = { 44292, 4 }, -- Brutal Gladiator's Chain Gauntlets
	[34992] = { 44292, 4 }, -- Brutal Gladiator's Chain Helm
	[34993] = { 44292, 4 }, -- Brutal Gladiator's Chain Leggings
	[34994] = { 44292, 4 }, -- Brutal Gladiator's Chain Spaulders
	[41084] = class_set_bonus.hunter, -- Savage Gladiator's Chain Armor
	[41140] = class_set_bonus.hunter, -- Savage Gladiator's Chain Gauntlets
	[41154] = class_set_bonus.hunter, -- Savage Gladiator's Chain Helm
	[41202] = class_set_bonus.hunter, -- Savage Gladiator's Chain Leggings
	[41214] = class_set_bonus.hunter, -- Savage Gladiator's Chain Spaulders
	[41085] = class_set_bonus.hunter, -- Hateful Gladiator's Chain Armor
	[41141] = class_set_bonus.hunter, -- Hateful Gladiator's Chain Gauntlets
	[41155] = class_set_bonus.hunter, -- Hateful Gladiator's Chain Helm
	[41203] = class_set_bonus.hunter, -- Hateful Gladiator's Chain Leggings
	[41215] = class_set_bonus.hunter, -- Hateful Gladiator's Chain Spaulders
	[41086] = class_set_bonus.hunter, -- Deadly Gladiator's Chain Armor
	[41142] = class_set_bonus.hunter, -- Deadly Gladiator's Chain Gauntlets
	[41156] = class_set_bonus.hunter, -- Deadly Gladiator's Chain Helm
	[41204] = class_set_bonus.hunter, -- Deadly Gladiator's Chain Leggings
	[41216] = class_set_bonus.hunter, -- Deadly Gladiator's Chain Spaulders
	[41087] = class_set_bonus.hunter, -- Furious Gladiator's Chain Armor
	[41143] = class_set_bonus.hunter, -- Furious Gladiator's Chain Gauntlets
	[41157] = class_set_bonus.hunter, -- Furious Gladiator's Chain Helm
	[41205] = class_set_bonus.hunter, -- Furious Gladiator's Chain Leggings
	[41217] = class_set_bonus.hunter, -- Furious Gladiator's Chain Spaulders
	[41088] = class_set_bonus.hunter, -- Relentless Gladiator's Chain Armor
	[41144] = class_set_bonus.hunter, -- Relentless Gladiator's Chain Gauntlets
	[41158] = class_set_bonus.hunter, -- Relentless Gladiator's Chain Helm
	[41206] = class_set_bonus.hunter, -- Relentless Gladiator's Chain Leggings
	[41218] = class_set_bonus.hunter, -- Relentless Gladiator's Chain Spaulders
	[51458] = class_set_bonus.hunter, -- Wrathful Gladiator's Chain Armor
	[51459] = class_set_bonus.hunter, -- Wrathful Gladiator's Chain Gauntlets
	[51460] = class_set_bonus.hunter, -- Wrathful Gladiator's Chain Helm
	[51461] = class_set_bonus.hunter, -- Wrathful Gladiator's Chain Leggings
	[51462] = class_set_bonus.hunter, -- Wrathful Gladiator's Chain Spaulders

--	[21366] = { 26174, 5 }, -- Striker's Diadem
--	[21365] = { 26174, 5 }, -- Striker's Footguards
--	[21370] = { 26174, 5 }, -- Striker's Hauberk
--	[21368] = { 26174, 5 }, -- Striker's Leggings
--	[21367] = { 26174, 5 }, -- Striker's Pauldrons
	[19621] = { 24465, 3 }, -- Maelstrom's Wrath
	[19953] = { 24465, 3 }, -- Renataki's Charm of Beasts
	[19833] = { 24465, 3 }, -- Zandalar Predator's Bracers
	[19832] = { 24465, 3 }, -- Zandalar Predator's Belt
	[19831] = { 24465, 3 }, -- Zandalar Predator's Mantle
	[28613] = { 23158, 4 }, -- Grand Marshal's Chain Armor
	[28614] = { 23158, 4 }, -- Grand Marshal's Chain Gauntlets
	[28615] = { 23158, 4 }, -- Grand Marshal's Chain Helm
	[28616] = { 23158, 4 }, -- Grand Marshal's Chain Leggings
	[28617] = { 23158, 4 }, -- Grand Marshal's Chain Spaulders
	[28805] = { 23158, 4 }, -- High Warlord's Chain Armor
	[28806] = { 23158, 4 }, -- High Warlord's Chain Gauntlets
	[28807] = { 23158, 4 }, -- High Warlord's Chain Helm
	[28808] = { 23158, 4 }, -- High Warlord's Chain Leggings
	[28809] = { 23158, 4 }, -- High Warlord's Chain Spaulders
	[35376] = { 23158, 4 }, -- Stalker's Chain Armor
	[35377] = { 23158, 4 }, -- Stalker's Chain Gauntlets
	[35378] = { 23158, 4 }, -- Stalker's Chain Helm
	[35379] = { 23158, 4 }, -- Stalker's Chain Leggings
	[35380] = { 23158, 4 }, -- Stalker's Chain Spaulders
	[16466] = { 23158, 3 }, -- Field Marshal's Chain Breastplate
	[16465] = { 23158, 3 }, -- Field Marshal's Chain Helm
	[16468] = { 23158, 3 }, -- Field Marshal's Chain Spaulders
	[16462] = { 23158, 3 }, -- Marshal's Chain Boots
	[16463] = { 23158, 3 }, -- Marshal's Chain Grips
	[16467] = { 23158, 3 }, -- Marshal's Chain Legguards
	[16569] = { 23158, 3 }, -- General's Chain Boots
	[16571] = { 23158, 3 }, -- General's Chain Gloves
	[16567] = { 23158, 3 }, -- General's Chain Legguards
	[16565] = { 23158, 3 }, -- Warlord's Chain Chestpiece
	[16566] = { 23158, 3 }, -- Warlord's Chain Helmet
	[16568] = { 23158, 3 }, -- Warlord's Chain Shoulders
	[22843] = { 23158, 4 }, -- Blood Guard's Chain Greaves
	[22862] = { 23158, 4 }, -- Blood Guard's Chain Vices
	[23251] = { 23158, 4 }, -- Champion's Chain Helm
	[23252] = { 23158, 4 }, -- Champion's Chain Shoulders
	[22874] = { 23158, 4 }, -- Legionnaire's Chain Hauberk
	[22875] = { 23158, 4 }, -- Legionnaire's Chain Legguards
	[23292] = { 23158, 4 }, -- Knight-Captain's Chain Hauberk
	[23293] = { 23158, 4 }, -- Knight-Captain's Chain Legguards
	[23278] = { 23158, 4 }, -- Knight-Lieutenant's Chain Greaves
	[23279] = { 23158, 4 }, -- Knight-Lieutenant's Chain Vices
	[23306] = { 23158, 4 }, -- Lieutenant Commander's Chain Helm
	[23307] = { 23158, 4 }, -- Lieutenant Commander's Chain Shoulders
	[16531] = { 23158, 4 }, -- Blood Guard's Chain Boots
	[16530] = { 23158, 4 }, -- Blood Guard's Chain Gauntlets
	[16525] = { 23158, 4 }, -- Blood Guard's Chain Breastplate
	[16527] = { 23158, 4 }, -- Legionnaire's Chain Leggings
	[16526] = { 23158, 4 }, -- Champion's Chain Headguard
	[16528] = { 23158, 4 }, -- Champion's Chain Pauldrons
	[16425] = { 23158, 4 }, -- Knight-Captain's Chain Hauberk
	[16426] = { 23158, 4 }, -- Knight-Captain's Chain Leggings
	[16401] = { 23158, 4 }, -- Knight-Lieutenant's Chain Boots
	[16403] = { 23158, 4 }, -- Knight-Lieutenant's Chain Gauntlets
	[16428] = { 23158, 4 }, -- Lieutenant Commander's Chain Helmet
	[16427] = { 23158, 4 }, -- Lieutenant Commander's Chain Pauldrons
	-- Mage
	[35343] = { 23025, 4 }, -- Evoker's Silk Amice
	[35344] = { 23025, 4 }, -- Evoker's Silk Cowl
	[35345] = { 23025, 4 }, -- Evoker's Silk Handguards
	[35346] = { 23025, 4 }, -- Evoker's Silk Raiment
	[35347] = { 23025, 4 }, -- Evoker's Silk Trousers
	[28714] = { 23025, 4 }, -- Grand Marshal's Silk Amice
	[28715] = { 23025, 4 }, -- Grand Marshal's Silk Cowl
	[28716] = { 23025, 4 }, -- Grand Marshal's Silk Handguards
	[28717] = { 23025, 4 }, -- Grand Marshal's Silk Raiment
	[28718] = { 23025, 4 }, -- Grand Marshal's Silk Trousers
	[28866] = { 23025, 4 }, -- High Warlord's Silk Amice
	[28867] = { 23025, 4 }, -- High Warlord's Silk Cowl
	[28868] = { 23025, 4 }, -- High Warlord's Silk Handguards
	[28869] = { 23025, 4 }, -- High Warlord's Silk Raiment
	[28870] = { 23025, 4 }, -- High Warlord's Silk Trousers
	[16441] = { 23025, 3 }, -- Field Marshal's Coronet
	[16444] = { 23025, 3 }, -- Field Marshal's Silk Spaulders
	[16443] = { 23025, 3 }, -- Field Marshal's Silk Vestments
	[16437] = { 23025, 3 }, -- Marshal's Silk Footwraps
	[16440] = { 23025, 3 }, -- Marshal's Silk Gloves
	[16442] = { 23025, 3 }, -- Marshal's Silk Leggings
	[16536] = { 23025, 3 }, -- Warlord's Silk Amice
	[16533] = { 23025, 3 }, -- Warlord's Silk Cowl
	[16535] = { 23025, 3 }, -- Warlord's Silk Raiment
	[16539] = { 23025, 3 }, -- General's Silk Boots
	[16540] = { 23025, 3 }, -- General's Silk Handguards
	[16534] = { 23025, 3 }, -- General's Silk Trousers
	[22870] = { 23025, 4 }, -- Blood Guard's Silk Handwraps
	[22860] = { 23025, 4 }, -- Blood Guard's Silk Walkers
	[23263] = { 23025, 4 }, -- Champion's Silk Cowl
	[23264] = { 23025, 4 }, -- Champion's Silk Mantle
	[22883] = { 23025, 4 }, -- Legionnaire's Silk Legguards
	[22886] = { 23025, 4 }, -- Legionnaire's Silk Tunic
	[23304] = { 23025, 4 }, -- Knight-Captain's Silk Legguards
	[23305] = { 23025, 4 }, -- Knight-Captain's Silk Tunic
	[23290] = { 23025, 4 }, -- Knight-Lieutenant's Silk Handwraps
	[23291] = { 23025, 4 }, -- Knight-Lieutenant's Silk Walkers
	[23318] = { 23025, 4 }, -- Lieutenant Commander's Silk Cowl
	[23319] = { 23025, 4 }, -- Lieutenant Commander's Silk Mantle
	[16485] = { 23025, 4 }, -- Blood Guard's Silk Footwraps
	[16487] = { 23025, 4 }, -- Blood Guard's Silk Gloves
	[16491] = { 23025, 4 }, -- Legionnaire's Silk Robes
	[16490] = { 23025, 4 }, -- Legionnaire's Silk Pants
	[16489] = { 23025, 4 }, -- Champion's Silk Hood
	[16492] = { 23025, 4 }, -- Champion's Silk Shoulderpads
	[16369] = { 23025, 4 }, -- Knight-Lieutenant's Silk Boots
	[16391] = { 23025, 4 }, -- Knight-Lieutenant's Silk Gloves
	[16413] = { 23025, 4 }, -- Knight-Captain's Silk Raiment
	[16414] = { 23025, 4 }, -- Knight-Captain's Silk Leggings
	[16416] = { 23025, 4 }, -- Lieutenant Commander's Crown
	[16415] = { 23025, 4 }, -- Lieutenant Commander's Silk Spaulders
	[29076] = { 37439, 4 }, -- Collar of the Aldor
	[29080] = { 37439, 4 }, -- Gloves of the Aldor
	[29078] = { 37439, 4 }, -- Legwraps of the Aldor
	[29079] = { 37439, 4 }, -- Pauldrons of the Aldor
	[29077] = { 37439, 4 }, -- Vestments of the Aldor
	[22502] = { 28763, 2 }, -- Frostfire Belt
	[22503] = { 28763, 2 }, -- Frostfire Bindings
	[22498] = { 28763, 2 }, -- Frostfire Circlet
	[22501] = { 28763, 2 }, -- Frostfire Gloves
	[22497] = { 28763, 2 }, -- Frostfire Leggings
	[22496] = { 28763, 2 }, -- Frostfire Robe
	[22500] = { 28763, 2 }, -- Frostfire Sandals
	[22499] = { 28763, 2 }, -- Frostfire Shoulderpads
	[23062] = { 28763, 2 }, -- Frostfire Ring
	-- Paladin
	[22430] = { 28774, 4 }, -- Redemption Boots
	[22431] = { 28774, 4 }, -- Redemption Girdle
	[22426] = { 28774, 4 }, -- Redemption Handguards
	[22428] = { 28774, 4 }, -- Redemption Headpiece
	[22427] = { 28774, 4 }, -- Redemption Legguards
	[22429] = { 28774, 4 }, -- Redemption Spaulders
	[22425] = { 28774, 4 }, -- Redemption Tunic
	[22424] = { 28774, 4 }, -- Redemption Wristguards
	[23066] = { 28774, 4 }, -- Ring of Redemption
	[27702] = { 23302, 4 }, -- Gladiator's Lamellar Chestpiece
	[27703] = { 23302, 4 }, -- Gladiator's Lamellar Gauntlets
	[27704] = { 23302, 4 }, -- Gladiator's Lamellar Helm
	[27705] = { 23302, 4 }, -- Gladiator's Lamellar Legguards
	[27706] = { 23302, 4 }, -- Gladiator's Lamellar Shoulders
	[27879] = { 23302, 4 }, -- Gladiator's Scaled Chestpiece
	[27880] = { 23302, 4 }, -- Gladiator's Scaled Gauntlets
	[27881] = { 23302, 4 }, -- Gladiator's Scaled Helm
	[27882] = { 23302, 4 }, -- Gladiator's Scaled Legguards
	[27883] = { 23302, 4 }, -- Gladiator's Scaled Shoulders
	[32039] = { 23302, 4 }, -- Merciless Gladiator's Scaled Chestpiece
	[32040] = { 23302, 4 }, -- Merciless Gladiator's Scaled Gauntlets
	[32041] = { 23302, 4 }, -- Merciless Gladiator's Scaled Helm
	[32042] = { 23302, 4 }, -- Merciless Gladiator's Scaled Legguards
	[32043] = { 23302, 4 }, -- Merciless Gladiator's Scaled Shoulders
	[31992] = { 23302, 4 }, -- Merciless Gladiator's Lamellar Chestpiece
	[31993] = { 23302, 4 }, -- Merciless Gladiator's Lamellar Gauntlets
	[31997] = { 23302, 4 }, -- Merciless Gladiator's Lamellar Helm
	[31995] = { 23302, 4 }, -- Merciless Gladiator's Lamellar Legguards
	[31996] = { 23302, 4 }, -- Merciless Gladiator's Lamellar Shoulders
	[33749] = { 23302, 4 }, -- Vengeful Gladiator's Scaled Chestpiece
	[33750] = { 23302, 4 }, -- Vengeful Gladiator's Scaled Gauntlets
	[33751] = { 23302, 4 }, -- Vengeful Gladiator's Scaled Helm
	[33752] = { 23302, 4 }, -- Vengeful Gladiator's Scaled Legguards
	[33753] = { 23302, 4 }, -- Vengeful Gladiator's Scaled Shoulders
	[33695] = { 23302, 4 }, -- Vengeful Gladiator's Lamellar Chestpiece
	[33696] = { 23302, 4 }, -- Vengeful Gladiator's Lamellar Gauntlets
	[33697] = { 23302, 4 }, -- Vengeful Gladiator's Lamellar Helm
	[33698] = { 23302, 4 }, -- Vengeful Gladiator's Lamellar Legguards
	[33699] = { 23302, 4 }, -- Vengeful Gladiator's Lamellar Shoulders
	[35088] = { 23302, 4 }, -- Brutal Gladiator's Scaled Chestpiece
	[35089] = { 23302, 4 }, -- Brutal Gladiator's Scaled Gauntlets
	[35090] = { 23302, 4 }, -- Brutal Gladiator's Scaled Helm
	[35091] = { 23302, 4 }, -- Brutal Gladiator's Scaled Legguards
	[35092] = { 23302, 4 }, -- Brutal Gladiator's Scaled Shoulders
	[35027] = { 23302, 4 }, -- Brutal Gladiator's Lamellar Chestpiece
	[35028] = { 23302, 4 }, -- Brutal Gladiator's Lamellar Gauntlets
	[35029] = { 23302, 4 }, -- Brutal Gladiator's Lamellar Helm
	[35030] = { 23302, 4 }, -- Brutal Gladiator's Lamellar Legguards
	[35031] = { 23302, 4 }, -- Brutal Gladiator's Lamellar Shoulders
	[40780] = class_set_bonus.paladin, -- Savage Gladiator's Scaled Chestpiece
	[40798] = class_set_bonus.paladin, -- Savage Gladiator's Scaled Gauntlets
	[40818] = class_set_bonus.paladin, -- Savage Gladiator's Scaled Helm
	[40838] = class_set_bonus.paladin, -- Savage Gladiator's Scaled Legguards
	[40858] = class_set_bonus.paladin, -- Savage Gladiator's Scaled Shoulders
	[40782] = class_set_bonus.paladin, -- Hateful Gladiator's Scaled Chestpiece
	[40802] = class_set_bonus.paladin, -- Hateful Gladiator's Scaled Gauntlets
	[40821] = class_set_bonus.paladin, -- Hateful Gladiator's Scaled Helm
	[40842] = class_set_bonus.paladin, -- Hateful Gladiator's Scaled Legguards
	[40861] = class_set_bonus.paladin, -- Hateful Gladiator's Scaled Shoulders
	[40785] = class_set_bonus.paladin, -- Deadly Gladiator's Scaled Chestpiece
	[40805] = class_set_bonus.paladin, -- Deadly Gladiator's Scaled Gauntlets
	[40825] = class_set_bonus.paladin, -- Deadly Gladiator's Scaled Helm
	[40846] = class_set_bonus.paladin, -- Deadly Gladiator's Scaled Legguards
	[40864] = class_set_bonus.paladin, -- Deadly Gladiator's Scaled Shoulders
	[40788] = class_set_bonus.paladin, -- Furious Gladiator's Scaled Chestpiece
	[40808] = class_set_bonus.paladin, -- Furious Gladiator's Scaled Gauntlets
	[40828] = class_set_bonus.paladin, -- Furious Gladiator's Scaled Helm
	[40849] = class_set_bonus.paladin, -- Furious Gladiator's Scaled Legguards
	[40869] = class_set_bonus.paladin, -- Furious Gladiator's Scaled Shoulders
	[40792] = class_set_bonus.paladin, -- Relentless Gladiator's Scaled Chestpiece
	[40812] = class_set_bonus.paladin, -- Relentless Gladiator's Scaled Gauntlets
	[40831] = class_set_bonus.paladin, -- Relentless Gladiator's Scaled Helm
	[40852] = class_set_bonus.paladin, -- Relentless Gladiator's Scaled Legguards
	[40872] = class_set_bonus.paladin, -- Relentless Gladiator's Scaled Shoulders
	[51474] = class_set_bonus.paladin, -- Wrathful Gladiator's Scaled Chestpiece
	[51475] = class_set_bonus.paladin, -- Wrathful Gladiator's Scaled Gauntlets
	[51476] = class_set_bonus.paladin, -- Wrathful Gladiator's Scaled Helm
	[51477] = class_set_bonus.paladin, -- Wrathful Gladiator's Scaled Legguards
	[51479] = class_set_bonus.paladin, -- Wrathful Gladiator's Scaled Shoulders

	[35402] = { 23302, 4 }, -- Crusader's Ornamented Chestplate
	[35403] = { 23302, 4 }, -- Crusader's Ornamented Gloves
	[35404] = { 23302, 4 }, -- Crusader's Ornamented Headguard
	[35405] = { 23302, 4 }, -- Crusader's Ornamented Leggings
	[35406] = { 23302, 4 }, -- Crusader's Ornamented Spaulders
	[35476] = { 23302, 4 }, -- Crusader's Ornamented Spaulders (H)
	[35412] = { 23302, 4 }, -- Crusader's Scaled Chestpiece
	[35413] = { 23302, 4 }, -- Crusader's Scaled Gauntlets
	[35477] = { 23302, 4 }, -- Crusader's Scaled Gauntlets (H)
	[35414] = { 23302, 4 }, -- Crusader's Scaled Helm
	[35415] = { 23302, 4 }, -- Crusader's Scaled Legguards
	[35416] = { 23302, 4 }, -- Crusader's Scaled Shoulders
	[28679] = { 23302, 4 }, -- Grand Marshal's Lamellar Chestpiece
	[28680] = { 23302, 4 }, -- Grand Marshal's Lamellar Gauntlets
	[28681] = { 23302, 4 }, -- Grand Marshal's Lamellar Helm
	[28724] = { 23302, 4 }, -- Grand Marshal's Lamellar Legguards
	[28683] = { 23302, 4 }, -- Grand Marshal's Lamellar Shoulders
	[28709] = { 23302, 4 }, -- Grand Marshal's Scaled Chestpiece
	[28710] = { 23302, 4 }, -- Grand Marshal's Scaled Gauntlets
	[28711] = { 23302, 4 }, -- Grand Marshal's Scaled Helm
	[28712] = { 23302, 4 }, -- Grand Marshal's Scaled Legguards
	[28713] = { 23302, 4 }, -- Grand Marshal's Scaled Shoulders
	[28831] = { 23302, 4 }, -- High Warlord's Lamellar Chestpiece
	[28832] = { 23302, 4 }, -- High Warlord's Lamellar Gauntlets
	[28833] = { 23302, 4 }, -- High Warlord's Lamellar Helm
	[28834] = { 23302, 4 }, -- High Warlord's Lamellar Legguards
	[28835] = { 23302, 4 }, -- High Warlord's Lamellar Shoulders
	[28861] = { 23302, 4 }, -- High Warlord's Scaled Chestpiece
	[28862] = { 23302, 4 }, -- High Warlord's Scaled Gauntlets
	[28863] = { 23302, 4 }, -- High Warlord's Scaled Helm
	[28864] = { 23302, 4 }, -- High Warlord's Scaled Legguards
	[28865] = { 23302, 4 }, -- High Warlord's Scaled Shoulders
	[16473] = { 23302, 3 }, -- Field Marshal's Lamellar Chestplate
	[16474] = { 23302, 3 }, -- Field Marshal's Lamellar Faceguard
	[16476] = { 23302, 3 }, -- Field Marshal's Lamellar Pauldrons
	[16472] = { 23302, 3 }, -- Marshal's Lamellar Boots
	[16471] = { 23302, 3 }, -- Marshal's Lamellar Gloves
	[16475] = { 23302, 3 }, -- Marshal's Lamellar Legplates
	[29612] = { 23302, 3 }, -- General's Lamellar Boots
	[29613] = { 23302, 3 }, -- General's Lamellar Gloves
	[29614] = { 23302, 3 }, -- General's Lamellar Legplates
	[29615] = { 23302, 3 }, -- Warlord's Lamellar Chestplate
	[29616] = { 23302, 3 }, -- Warlord's Lamellar Faceguard
	[29617] = { 23302, 3 }, -- Warlord's Lamellar Pauldrons
	[29600] = { 23302, 3 }, -- Blood Guard's Lamellar Gauntlets
	[29601] = { 23302, 3 }, -- Blood Guard's Lamellar Sabatons
	[29602] = { 23302, 3 }, -- Legionnaire's Lamellar Breastplate
	[29603] = { 23302, 3 }, -- Legionnaire's Lamellar Leggings
	[29604] = { 23302, 3 }, -- Champion's Lamellar Headguard
	[29605] = { 23302, 3 }, -- Champion's Lamellar Shoulders
	[23272] = { 23302, 4 }, -- Knight-Captain's Lamellar Breastplate
	[23273] = { 23302, 4 }, -- Knight-Captain's Lamellar Leggings
	[23274] = { 23302, 4 }, -- Knight-Lieutenant's Lamellar Gauntlets
	[23275] = { 23302, 4 }, -- Knight-Lieutenant's Lamellar Sabatons
	[23276] = { 23302, 4 }, -- Lieutenant Commander's Lamellar Headguard
	[23277] = { 23302, 4 }, -- Lieutenant Commander's Lamellar Shoulders
	[16410] = { 23302, 4 }, -- Knight-Lieutenant's Lamellar Gauntlets
	[16409] = { 23302, 4 }, -- Knight-Lieutenant's Lamellar Sabatons
	[16433] = { 23302, 4 }, -- Knight-Captain's Lamellar Breastplate
	[16435] = { 23302, 4 }, -- Knight-Captain's Lamellar Leggings
	[16434] = { 23302, 4 }, -- Lieutenant Commander's Lamellar Headguard
	[16436] = { 23302, 4 }, -- Lieutenant Commander's Lamellar Shoulders
	[29062] = { 37183, 4 }, -- Justicar Chestpiece
	[29061] = { 37183, 4 }, -- Justicar Diadem
	[29065] = { 37183, 4 }, -- Justicar Gloves
	[29063] = { 37183, 4 }, -- Justicar Leggings
	[29064] = { 37183, 4 }, -- Justicar Pauldrons
	[28203] = { 37181, 4 }, -- Breastplate of the Righteous
	[27535] = { 37181, 4 }, -- Gauntlets of the Righteous
	[28285] = { 37181, 4 }, -- Helm of the Righteous
	[27839] = { 37181, 4 }, -- Legplates of the Righteous
	[27739] = { 37181, 4 }, -- Spaulders of the Righteous
	-- Rogue
	[28684] = { 23048, 4 }, -- Grand Marshal's Leather Gloves
	[28685] = { 23048, 4 }, -- Grand Marshal's Leather Helm
	[28686] = { 23048, 4 }, -- Grand Marshal's Leather Legguards
	[28687] = { 23048, 4 }, -- Grand Marshal's Leather Spaulders
	[28688] = { 23048, 4 }, -- Grand Marshal's Leather Tunic
	[28836] = { 23048, 4 }, -- High Warlord's Leather Gloves
	[28837] = { 23048, 4 }, -- High Warlord's Leather Helm
	[28838] = { 23048, 4 }, -- High Warlord's Leather Legguards
	[28839] = { 23048, 4 }, -- High Warlord's Leather Spaulders
	[28840] = { 23048, 4 }, -- High Warlord's Leather Tunic
	[35366] = { 23048, 4 }, -- Opportunist's Leather Gloves
	[35367] = { 23048, 4 }, -- Opportunist's Leather Helm
	[35368] = { 23048, 4 }, -- Opportunist's Leather Legguards
	[35369] = { 23048, 4 }, -- Opportunist's Leather Spaulders
	[35370] = { 23048, 4 }, -- Opportunist's Leather Tunic
	[16453] = { 23048, 3 }, -- Field Marshal's Leather Chestpiece
	[16457] = { 23048, 3 }, -- Field Marshal's Leather Epaulets
	[16455] = { 23048, 3 }, -- Field Marshal's Leather Mask
	[16446] = { 23048, 3 }, -- Marshal's Leather Footguards
	[16454] = { 23048, 3 }, -- Marshal's Leather Handgrips
	[16456] = { 23048, 3 }, -- Marshal's Leather Leggings
	[16563] = { 23048, 3 }, -- Warlord's Leather Breastplate
	[16561] = { 23048, 3 }, -- Warlord's Leather Helm
	[16562] = { 23048, 3 }, -- Warlord's Leather Spaulders
	[16564] = { 23048, 3 }, -- General's Leather Legguards
	[16560] = { 23048, 3 }, -- General's Leather Mitts
	[16558] = { 23048, 3 }, -- General's Leather Treads
	[22864] = { 23048, 4 }, -- Blood Guard's Leather Grips
	[22856] = { 23048, 4 }, -- Blood Guard's Leather Walkers
	[22879] = { 23048, 4 }, -- Legionnaire's Leather Chestpiece
	[22880] = { 23048, 4 }, -- Legionnaire's Leather Legguards
	[23257] = { 23048, 4 }, -- Champion's Leather Helm
	[23258] = { 23048, 4 }, -- Champion's Leather Shoulders
	[23298] = { 23048, 4 }, -- Knight-Captain's Leather Chestpiece
	[23299] = { 23048, 4 }, -- Knight-Captain's Leather Legguards
	[23284] = { 23048, 4 }, -- Knight-Lieutenant's Leather Grips
	[23285] = { 23048, 4 }, -- Knight-Lieutenant's Leather Walkers
	[23312] = { 23048, 4 }, -- Lieutenant Commander's Leather Helm
	[23313] = { 23048, 4 }, -- Lieutenant Commander's Leather Shoulders
	[16498] = { 23048, 4 }, -- Blood Guard's Leather Treads
	[16499] = { 23048, 4 }, -- Blood Guard's Leather Vices
	[16505] = { 23048, 4 }, -- Legionnaire's Leather Hauberk
	[16508] = { 23048, 4 }, -- Legionnaire's Leather Leggings
	[16506] = { 23048, 4 }, -- Champion's Leather Headguard
	[16507] = { 23048, 4 }, -- Champion's Leather Mantle
	[16392] = { 23048, 4 }, -- Knight-Lieutenant's Leather Boots
	[16396] = { 23048, 4 }, -- Knight-Lieutenant's Leather Gauntlets
	[16417] = { 23048, 4 }, -- Knight-Captain's Leather Armor
	[16419] = { 23048, 4 }, -- Knight-Captain's Leather Legguards
	[16420] = { 23048, 4 }, -- Lieutenant Commander's Leather Spaulders
	[16418] = { 23048, 4 }, -- Lieutenant Commander's Leather Veil
	[16827] = { 21874, 2 }, -- Nightslayer Belt
	[16824] = { 21874, 2 }, -- Nightslayer Boots
	[16825] = { 21874, 2 }, -- Nightslayer Bracelets
	[16820] = { 21874, 2 }, -- Nightslayer Chestpiece
	[16821] = { 21874, 2 }, -- Nightslayer Cover
	[16826] = { 21874, 2 }, -- Nightslayer Gloves
	[16822] = { 21874, 2 }, -- Nightslayer Pants
	[16823] = { 21874, 2 }, -- Nightslayer Shoulder Pads
	[19617] = { 24469, 3 }, -- Zandalarian Shadow Mastery Talisman
	[19954] = { 24469, 3 }, -- Renataki's Charm of Trickery
	[19836] = { 24469, 3 }, -- Zandalar Madcap's Bracers
	[19835] = { 24469, 3 }, -- Zandalar Madcap's Mantle
	[19834] = { 24469, 3 }, -- Zandalar Madcap's Tunic
	[21359] = { 26112, 3 }, -- Deathdealer's Boots
	[21360] = { 26112, 3 }, -- Deathdealer's Helm
	[21361] = { 26112, 3 }, -- Deathdealer's Spaulders
	[21362] = { 26112, 3 }, -- Deathdealer's Leggings
	[21364] = { 26112, 3 }, -- Deathdealer's Vest
	-- Shaman
	[31396] = class_set_bonus.shaman, -- Gladiator's Ringmail Armor
	[31397] = class_set_bonus.shaman, -- Gladiator's Ringmail Gauntlets
	[31400] = class_set_bonus.shaman, -- Gladiator's Ringmail Helm
	[31406] = class_set_bonus.shaman, -- Gladiator's Ringmail Leggings
	[31407] = class_set_bonus.shaman, -- Gladiator's Ringmail Spaulders
	[32029] = class_set_bonus.shaman, -- Merciless Gladiator's Ringmail Armor
	[32030] = class_set_bonus.shaman, -- Merciless Gladiator's Ringmail Gauntlets
	[32031] = class_set_bonus.shaman, -- Merciless Gladiator's Ringmail Helm
	[32032] = class_set_bonus.shaman, -- Merciless Gladiator's Ringmail Leggings
	[32033] = class_set_bonus.shaman, -- Merciless Gladiator's Ringmail Spaulders
	[33738] = class_set_bonus.shaman, -- Vengeful Gladiator's Ringmail Armor
	[33739] = class_set_bonus.shaman, -- Vengeful Gladiator's Ringmail Gauntlets
	[33740] = class_set_bonus.shaman, -- Vengeful Gladiator's Ringmail Helm
	[33741] = class_set_bonus.shaman, -- Vengeful Gladiator's Ringmail Leggings
	[33742] = class_set_bonus.shaman, -- Vengeful Gladiator's Ringmail Spaulders
	[35077] = class_set_bonus.shaman, -- Brutal Gladiator's Ringmail Armor
	[35078] = class_set_bonus.shaman, -- Brutal Gladiator's Ringmail Gauntlets
	[35079] = class_set_bonus.shaman, -- Brutal Gladiator's Ringmail Helm
	[35080] = class_set_bonus.shaman, -- Brutal Gladiator's Ringmail Leggings
	[35081] = class_set_bonus.shaman, -- Brutal Gladiator's Ringmail Spaulders
	[40987] = class_set_bonus.shaman, -- Savage Gladiator's Mail Armor
	[41004] = class_set_bonus.shaman, -- Savage Gladiator's Mail Gauntlets
	[41016] = class_set_bonus.shaman, -- Savage Gladiator's Mail Helm
	[41030] = class_set_bonus.shaman, -- Savage Gladiator's Mail Leggings
	[41041] = class_set_bonus.shaman, -- Savage Gladiator's Mail Spaulders
	[40986] = class_set_bonus.shaman, -- Savage Gladiator's Ringmail Armor
	[40998] = class_set_bonus.shaman, -- Savage Gladiator's Ringmail Gauntlets
	[41010] = class_set_bonus.shaman, -- Savage Gladiator's Ringmail Helm
	[41023] = class_set_bonus.shaman, -- Savage Gladiator's Ringmail Leggings
	[41024] = class_set_bonus.shaman, -- Savage Gladiator's Ringmail Spaulders
	[40989] = class_set_bonus.shaman, -- Hateful Gladiator's Mail Armor
	[41005] = class_set_bonus.shaman, -- Hateful Gladiator's Mail Gauntlets
	[41017] = class_set_bonus.shaman, -- Hateful Gladiator's Mail Helm
	[41031] = class_set_bonus.shaman, -- Hateful Gladiator's Mail Leggings
	[41042] = class_set_bonus.shaman, -- Hateful Gladiator's Mail Spaulders
	[40988] = class_set_bonus.shaman, -- Hateful Gladiator's Ringmail Armor
	[40999] = class_set_bonus.shaman, -- Hateful Gladiator's Ringmail Gauntlets
	[41011] = class_set_bonus.shaman, -- Hateful Gladiator's Ringmail Helm
	[41025] = class_set_bonus.shaman, -- Hateful Gladiator's Ringmail Leggings
	[41036] = class_set_bonus.shaman, -- Hateful Gladiator's Ringmail Spaulders
	[40991] = class_set_bonus.shaman, -- Deadly Gladiator's Mail Armor
	[41006] = class_set_bonus.shaman, -- Deadly Gladiator's Mail Gauntlets
	[41018] = class_set_bonus.shaman, -- Deadly Gladiator's Mail Helm
	[41032] = class_set_bonus.shaman, -- Deadly Gladiator's Mail Leggings
	[41043] = class_set_bonus.shaman, -- Deadly Gladiator's Mail Spaulders
	[40990] = class_set_bonus.shaman, -- Deadly Gladiator's Ringmail Armor
	[41000] = class_set_bonus.shaman, -- Deadly Gladiator's Ringmail Gauntlets
	[41012] = class_set_bonus.shaman, -- Deadly Gladiator's Ringmail Helm
	[41026] = class_set_bonus.shaman, -- Deadly Gladiator's Ringmail Leggings
	[41037] = class_set_bonus.shaman, -- Deadly Gladiator's Ringmail Spaulders
	[40993] = class_set_bonus.shaman, -- Furious Gladiator's Mail Armor
	[41007] = class_set_bonus.shaman, -- Furious Gladiator's Mail Gauntlets
	[41019] = class_set_bonus.shaman, -- Furious Gladiator's Mail Helm
	[41033] = class_set_bonus.shaman, -- Furious Gladiator's Mail Leggings
	[41044] = class_set_bonus.shaman, -- Furious Gladiator's Mail Spaulders
	[40992] = class_set_bonus.shaman, -- Furious Gladiator's Ringmail Armor
	[41001] = class_set_bonus.shaman, -- Furious Gladiator's Ringmail Gauntlets
	[41013] = class_set_bonus.shaman, -- Furious Gladiator's Ringmail Helm
	[41027] = class_set_bonus.shaman, -- Furious Gladiator's Ringmail Leggings
	[41038] = class_set_bonus.shaman, -- Furious Gladiator's Ringmail Spaulders
	[40995] = class_set_bonus.shaman, -- Relentless Gladiator's Mail Armor
	[41008] = class_set_bonus.shaman, -- Relentless Gladiator's Mail Gauntlets
	[41020] = class_set_bonus.shaman, -- Relentless Gladiator's Mail Helm
	[41034] = class_set_bonus.shaman, -- Relentless Gladiator's Mail Leggings
	[41045] = class_set_bonus.shaman, -- Relentless Gladiator's Mail Spaulders
	[40994] = class_set_bonus.shaman, -- Relentless Gladiator's Ringmail Armor
	[41002] = class_set_bonus.shaman, -- Relentless Gladiator's Ringmail Gauntlets
	[41014] = class_set_bonus.shaman, -- Relentless Gladiator's Ringmail Helm
	[41028] = class_set_bonus.shaman, -- Relentless Gladiator's Ringmail Leggings
	[41039] = class_set_bonus.shaman, -- Relentless Gladiator's Ringmail Spaulders
	[51509] = class_set_bonus.shaman, -- Wrathful Gladiator's Mail Armor
	[51510] = class_set_bonus.shaman, -- Wrathful Gladiator's Mail Gauntlets
	[51511] = class_set_bonus.shaman, -- Wrathful Gladiator's Mail Helm
	[51512] = class_set_bonus.shaman, -- Wrathful Gladiator's Mail Leggings
	[51514] = class_set_bonus.shaman, -- Wrathful Gladiator's Mail Spaulders
	[51497] = class_set_bonus.shaman, -- Wrathful Gladiator's Ringmail Armor
	[51498] = class_set_bonus.shaman, -- Wrathful Gladiator's Ringmail Gauntlets
	[51499] = class_set_bonus.shaman, -- Wrathful Gladiator's Ringmail Helm
	[51500] = class_set_bonus.shaman, -- Wrathful Gladiator's Ringmail Leggings
	[51502] = class_set_bonus.shaman, -- Wrathful Gladiator's Ringmail Spaulders

	[29032] = { 37211, 4 }, -- Cyclone Gloves
	[29029] = { 37211, 4 }, -- Cyclone Hauberk
	[29028] = { 37211, 4 }, -- Cyclone Headdress
	[29030] = { 37211, 4 }, -- Cyclone Kilt
	[29031] = { 37211, 4 }, -- Cyclone Shoulderpads
	[35391] = { 38466, 4 }, -- Seer's Ringmail Chestguard
	[35392] = { 38466, 4 }, -- Seer's Ringmail Gloves
	[35393] = { 38466, 4 }, -- Seer's Ringmail Headpiece
	[35394] = { 38466, 4 }, -- Seer's Ringmail Legguards
	[35395] = { 38466, 4 }, -- Seer's Ringmail Shoulderpads
	[31640] = { 38499, 4 }, -- Grand Marshal's Ringmail Chestguard
	[31641] = { 38499, 4 }, -- Grand Marshal's Ringmail Gloves
	[31642] = { 38499, 4 }, -- Grand Marshal's Ringmail Headpiece
	[31643] = { 38499, 4 }, -- Grand Marshal's Ringmail Legguards
	[31644] = { 38499, 4 }, -- Grand Marshal's Ringmail Shoulders
	[31646] = { 38499, 4 }, -- High Warlord's Ringmail Chestguard
	[31647] = { 38499, 4 }, -- High Warlord's Ringmail Gloves
	[31648] = { 38499, 4 }, -- High Warlord's Ringmail Headpiece
	[31649] = { 38499, 4 }, -- High Warlord's Ringmail Legguards
	[31650] = { 38499, 4 }, -- High Warlord's Ringmail Shoulderpads
	[25997] = class_set_bonus.enhance, -- Gladiator's Linked Armor
	[26000] = class_set_bonus.enhance, -- Gladiator's Linked Gauntlets
	[25998] = class_set_bonus.enhance, -- Gladiator's Linked Helm
	[26001] = class_set_bonus.enhance, -- Gladiator's Linked Leggings
	[25999] = class_set_bonus.enhance, -- Gladiator's Linked Spaulders
	[32004] = class_set_bonus.enhance, -- Merciless Gladiator's Linked Armor
	[32005] = class_set_bonus.enhance, -- Merciless Gladiator's Linked Gauntlets
	[32006] = class_set_bonus.enhance, -- Merciless Gladiator's Linked Helm
	[32007] = class_set_bonus.enhance, -- Merciless Gladiator's Linked Leggings
	[32008] = class_set_bonus.enhance, -- Merciless Gladiator's Linked Spaulders
	[33706] = class_set_bonus.enhance, -- Vengeful Gladiator's Linked Armor
	[33707] = class_set_bonus.enhance, -- Vengeful Gladiator's Linked Gauntlets
	[33708] = class_set_bonus.enhance, -- Vengeful Gladiator's Linked Helm
	[33709] = class_set_bonus.enhance, -- Vengeful Gladiator's Linked Leggings
	[33710] = class_set_bonus.enhance, -- Vengeful Gladiator's Linked Spaulders
	[35042] = class_set_bonus.enhance, -- Brutal Gladiator's Linked Armor
	[35043] = class_set_bonus.enhance, -- Brutal Gladiator's Linked Gauntlets
	[35044] = class_set_bonus.enhance, -- Brutal Gladiator's Linked Helm
	[35045] = class_set_bonus.enhance, -- Brutal Gladiator's Linked Leggings
	[35046] = class_set_bonus.enhance, -- Brutal Gladiator's Linked Spaulders
	[41078] = class_set_bonus.enhance, -- Savage Gladiator's Linked Armor
	[41134] = class_set_bonus.enhance, -- Savage Gladiator's Linked Gauntlets
	[41148] = class_set_bonus.enhance, -- Savage Gladiator's Linked Helm
	[41160] = class_set_bonus.enhance, -- Savage Gladiator's Linked Leggings
	[41208] = class_set_bonus.enhance, -- Savage Gladiator's Linked Spaulders
	[41079] = class_set_bonus.enhance, -- Hateful Gladiator's Linked Armor
	[41135] = class_set_bonus.enhance, -- Hateful Gladiator's Linked Gauntlets
	[41149] = class_set_bonus.enhance, -- Hateful Gladiator's Linked Helm
	[41162] = class_set_bonus.enhance, -- Hateful Gladiator's Linked Leggings
	[41209] = class_set_bonus.enhance, -- Hateful Gladiator's Linked Spaulders
	[41080] = class_set_bonus.enhance, -- Deadly Gladiator's Linked Armor
	[41136] = class_set_bonus.enhance, -- Deadly Gladiator's Linked Gauntlets
	[41150] = class_set_bonus.enhance, -- Deadly Gladiator's Linked Helm
	[41198] = class_set_bonus.enhance, -- Deadly Gladiator's Linked Leggings
	[41210] = class_set_bonus.enhance, -- Deadly Gladiator's Linked Spaulders
	[41081] = class_set_bonus.enhance, -- Furious Gladiator's Linked Armor
	[41137] = class_set_bonus.enhance, -- Furious Gladiator's Linked Gauntlets
	[41151] = class_set_bonus.enhance, -- Furious Gladiator's Linked Helm
	[41199] = class_set_bonus.enhance, -- Furious Gladiator's Linked Leggings
	[41211] = class_set_bonus.enhance, -- Furious Gladiator's Linked Spaulders
	[41082] = class_set_bonus.enhance, -- Relentless Gladiator's Linked Armor
	[41138] = class_set_bonus.enhance, -- Relentless Gladiator's Linked Gauntlets
	[41152] = class_set_bonus.enhance, -- Relentless Gladiator's Linked Helm
	[41200] = class_set_bonus.enhance, -- Relentless Gladiator's Linked Leggings
	[41212] = class_set_bonus.enhance, -- Relentless Gladiator's Linked Spaulders
	[51503] = class_set_bonus.enhance, -- Wrathful Gladiator's Linked Armor
	[51504] = class_set_bonus.enhance, -- Wrathful Gladiator's Linked Gauntlets
	[51505] = class_set_bonus.enhance, -- Wrathful Gladiator's Linked Helm
	[51506] = class_set_bonus.enhance, -- Wrathful Gladiator's Linked Leggings
	[51508] = class_set_bonus.enhance, -- Wrathful Gladiator's Linked Spaulders

	[28689] = class_set_bonus.enhance, -- Grand Marshal's Linked Armor
	[28690] = class_set_bonus.enhance, -- Grand Marshal's Linked Gauntlets
	[28691] = class_set_bonus.enhance, -- Grand Marshal's Linked Helm
	[28692] = class_set_bonus.enhance, -- Grand Marshal's Linked Leggings
	[28693] = class_set_bonus.enhance, -- Grand Marshal's Linked Spaulders
	[28841] = class_set_bonus.enhance, -- High Warlord's Linked Armor
	[28842] = class_set_bonus.enhance, -- High Warlord's Linked Gauntlets
	[28843] = class_set_bonus.enhance, -- High Warlord's Linked Helm
	[28844] = class_set_bonus.enhance, -- High Warlord's Linked Leggings
	[28845] = class_set_bonus.enhance, -- High Warlord's Linked Spaulders
	[35381] = class_set_bonus.enhance, -- Seer's Linked Armor
	[35382] = class_set_bonus.enhance, -- Seer's Linked Gauntlets
	[35383] = class_set_bonus.enhance, -- Seer's Linked Helm
	[35384] = class_set_bonus.enhance, -- Seer's Linked Leggings
	[35385] = class_set_bonus.enhance, -- Seer's Linked Spaulders
	-- Warlock
	[19605] = { 24487, 5 }, -- ezan's Unstoppable Taint
	[19957] = { 24487, 5 }, -- Hazza'rah's Charm of Destruction
	[19848] = { 24487, 5 }, -- Zandalar Demoniac's Wraps
	[19849] = { 24487, 5 }, -- Zandalar Demoniac's Mantle
	[20033] = { 24487, 5 }, -- Zandalar Demoniac's Robe
	-- Warrior
	[19951] = { 24456, 3 }, -- Gri'lek's Charm of Might
	[19577] = { 24456, 3 }, -- Rage of Mugamba
	[19824] = { 24456, 3 }, -- Zandalar Vindicator's Armguards
	[19823] = { 24456, 3 }, -- Zandalar Vindicator's Belt
	[19822] = { 24456, 3 }, -- Zandalar Vindicator's Breastplate
	[24544] = class_set_bonus.warrior, -- Gladiator's Plate Chestpiece
	[24549] = class_set_bonus.warrior, -- Gladiator's Plate Gauntlets
	[24545] = class_set_bonus.warrior, -- Gladiator's Plate Helm
	[24547] = class_set_bonus.warrior, -- Gladiator's Plate Legguards
	[24546] = class_set_bonus.warrior, -- Gladiator's Plate Shoulders
	[30486] = class_set_bonus.warrior, -- Merciless Gladiator's Plate Chestpiece
	[30487] = class_set_bonus.warrior, -- Merciless Gladiator's Plate Gauntlets
	[30488] = class_set_bonus.warrior, -- Merciless Gladiator's Plate Helm
	[30489] = class_set_bonus.warrior, -- Merciless Gladiator's Plate Legguards
	[30490] = class_set_bonus.warrior, -- Merciless Gladiator's Plate Shoulders
	[33728] = class_set_bonus.warrior, -- Vengeful Gladiator's Plate Chestpiece
	[33729] = class_set_bonus.warrior, -- Vengeful Gladiator's Plate Gauntlets
	[33730] = class_set_bonus.warrior, -- Vengeful Gladiator's Plate Helm
	[33731] = class_set_bonus.warrior, -- Vengeful Gladiator's Plate Legguards
	[33732] = class_set_bonus.warrior, -- Vengeful Gladiator's Plate Shoulders
	[35066] = class_set_bonus.warrior, -- Brutal Gladiator's Plate Chestpiece
	[35067] = class_set_bonus.warrior, -- Brutal Gladiator's Plate Gauntlets
	[35068] = class_set_bonus.warrior, -- Brutal Gladiator's Plate Helm
	[35069] = class_set_bonus.warrior, -- Brutal Gladiator's Plate Legguards
	[35070] = class_set_bonus.warrior, -- Brutal Gladiator's Plate Shoulders
	[40778] = class_set_bonus.warrior, -- Savage Gladiator's Plate Chestpiece
	[40797] = class_set_bonus.warrior, -- Savage Gladiator's Plate Gauntlets
	[40816] = class_set_bonus.warrior, -- Savage Gladiator's Plate Helm
	[40836] = class_set_bonus.warrior, -- Savage Gladiator's Plate Legguards
	[40856] = class_set_bonus.warrior, -- Savage Gladiator's Plate Shoulders
	[40783] = class_set_bonus.warrior, -- Hateful Gladiator's Plate Chestpiece
	[40801] = class_set_bonus.warrior, -- Hateful Gladiator's Plate Gauntlets
	[40819] = class_set_bonus.warrior, -- Hateful Gladiator's Plate Helm
	[40840] = class_set_bonus.warrior, -- Hateful Gladiator's Plate Legguards
	[40859] = class_set_bonus.warrior, -- Hateful Gladiator's Plate Shoulders
	[40786] = class_set_bonus.warrior, -- Deadly Gladiator's Plate Chestpiece
	[40804] = class_set_bonus.warrior, -- Deadly Gladiator's Plate Gauntlets
	[40823] = class_set_bonus.warrior, -- Deadly Gladiator's Plate Helm
	[40844] = class_set_bonus.warrior, -- Deadly Gladiator's Plate Legguards
	[40862] = class_set_bonus.warrior, -- Deadly Gladiator's Plate Shoulders
	[40789] = class_set_bonus.warrior, -- Furious Gladiator's Plate Chestpiece
	[40807] = class_set_bonus.warrior, -- Furious Gladiator's Plate Gauntlets
	[40826] = class_set_bonus.warrior, -- Furious Gladiator's Plate Helm
	[40847] = class_set_bonus.warrior, -- Furious Gladiator's Plate Legguards
	[40866] = class_set_bonus.warrior, -- Furious Gladiator's Plate Shoulders
	[40790] = class_set_bonus.warrior, -- Relentless Gladiator's Plate Chestpiece
	[40810] = class_set_bonus.warrior, -- Relentless Gladiator's Plate Gauntlets
	[40829] = class_set_bonus.warrior, -- Relentless Gladiator's Plate Helm
	[40850] = class_set_bonus.warrior, -- Relentless Gladiator's Plate Legguards
	[40870] = class_set_bonus.warrior, -- Relentless Gladiator's Plate Shoulders
	[51541] = class_set_bonus.warrior, -- Wrathful Gladiator's Plate Chestpiece
	[51542] = class_set_bonus.warrior, -- Wrathful Gladiator's Plate Gauntlets
	[51543] = class_set_bonus.warrior, -- Wrathful Gladiator's Plate Helm
	[51544] = class_set_bonus.warrior, -- Wrathful Gladiator's Plate Legguards
	[51545] = class_set_bonus.warrior, -- Wrathful Gladiator's Plate Shoulders

	[28699] = class_set_bonus.warrior, -- Grand Marshal's Plate Chestpiece
	[28700] = class_set_bonus.warrior, -- Grand Marshal's Plate Gauntlets
	[28701] = class_set_bonus.warrior, -- Grand Marshal's Plate Helm
	[28702] = class_set_bonus.warrior, -- Grand Marshal's Plate Legguards
	[28703] = class_set_bonus.warrior, -- Grand Marshal's Plate Shoulders
	[28851] = class_set_bonus.warrior, -- High Warlord's Plate Chestpiece
	[28852] = class_set_bonus.warrior, -- High Warlord's Plate Gauntlets
	[28853] = class_set_bonus.warrior, -- High Warlord's Plate Helm
	[28854] = class_set_bonus.warrior, -- High Warlord's Plate Legguards
	[28855] = class_set_bonus.warrior, -- High Warlord's Plate Shoulders
	[35407] = class_set_bonus.warrior, -- Savage Plate Chestpiece
	[35408] = class_set_bonus.warrior, -- Savage Plate Gauntlets
	[35409] = class_set_bonus.warrior, -- Savage Plate Helm
	[35410] = class_set_bonus.warrior, -- Savage Plate Legguards
	[35411] = class_set_bonus.warrior, -- Savage Plate Shoulders
	[16477] = { 22738, 3 }, -- Field Marshal's Plate Armor
	[16478] = { 22738, 3 }, -- Field Marshal's Plate Helm
	[16480] = { 22738, 3 }, -- Field Marshal's Plate Shoulderguards
	[16483] = { 22738, 3 }, -- Marshal's Plate Boots
	[16484] = { 22738, 3 }, -- Marshal's Plate Gauntlets
	[16479] = { 22738, 3 }, -- Marshal's Plate Legguards
	[16541] = { 22738, 3 }, -- Warlord's Plate Armor
	[16542] = { 22738, 3 }, -- Warlord's Plate Headpiece
	[16544] = { 22738, 3 }, -- Warlord's Plate Shoulders
	[16545] = { 22738, 3 }, -- General's Plate Boots
	[16548] = { 22738, 3 }, -- General's Plate Gauntlets
	[16543] = { 22738, 3 }, -- General's Plate Leggings
	[22868] = class_set_bonus.warrior, -- Blood Guard's Plate Gauntlets
	[22858] = class_set_bonus.warrior, -- Blood Guard's Plate Greaves
	[22872] = class_set_bonus.warrior, -- Legionnaire's Plate Hauberk
	[22873] = class_set_bonus.warrior, -- Legionnaire's Plate Leggings
	[23244] = class_set_bonus.warrior, -- Champion's Plate Helm
	[23243] = class_set_bonus.warrior, -- Champion's Plate Shoulders
	[23300] = class_set_bonus.warrior, -- Knight-Captain's Plate Hauberk
	[23301] = class_set_bonus.warrior, -- Knight-Captain's Plate Leggings
	[23286] = class_set_bonus.warrior, -- Knight-Lieutenant's Plate Gauntlets
	[23287] = class_set_bonus.warrior, -- Knight-Lieutenant's Plate Greaves
	[23314] = class_set_bonus.warrior, -- Lieutenant Commander's Plate Helmet
	[23315] = class_set_bonus.warrior, -- Lieutenant Commander's Plate Shoulders
	[16509] = class_set_bonus.warrior, -- Blood Guard's Plate Boots
	[16510] = class_set_bonus.warrior, -- Blood Guard's Plate Gloves
	[16513] = class_set_bonus.warrior, -- Legionnaire's Plate Armor
	[16515] = class_set_bonus.warrior, -- Legionnaire's Plate Legguards
	[16514] = class_set_bonus.warrior, -- Champion's Plate Headguard
	[16516] = class_set_bonus.warrior, -- Champion's Plate Pauldrons
	[16405] = class_set_bonus.warrior, -- Knight-Lieutenant's Plate Boots
	[16406] = class_set_bonus.warrior, -- Knight-Lieutenant's Plate Gauntlets
	[16430] = class_set_bonus.warrior, -- Knight-Captain's Plate Chestguard
	[16431] = class_set_bonus.warrior, -- Knight-Captain's Plate Leggings
	[16429] = class_set_bonus.warrior, -- Lieutenant Commander's Plate Helm
	[16432] = class_set_bonus.warrior, -- Lieutenant Commander's Plate Pauldrons
}
-- Cata
local cataClassSets = {
	druid = {
		64764, 64765, 64766, 64767, 64768, -- Bloodthirsty Gladiator's Refuge
		60448, 60449, 60450, 60451, 60452, -- Vicious Gladiator's Refuge 365
		65533, 65534, 65535, 65539, 65540, -- Ruthless Gladiator's Refuge 365
		70580, 70581, 70582, 70583, 70584, -- Vicious Gladiator's Refuge 371
	},
	paladin = {
		64843, 64844, 64845, 64846, 64847, -- Bloodthirsty Gladiator's Vindication
		60413, 60414, 60415, 60416, 60417, -- Vicious Gladiator's Vindication 365
		65585, 65586, 65590, 65591, 65592, -- Ruthless Gladiator's Vindication 365
		70648, 70648, 70648, 70648, 70648, -- Vicious Gladiator's Vindication 371
	},
	shaman = {
		64827, 64828, 64829, 64830, 64831, -- Bloodthirsty Gladiator's Wartide
		60428, 60429, 60430, 60431, 60432, -- Vicious Gladiator's Wartide 365
		65536, 65567, 65568, 65569, 65570, -- Ruthless Gladiator's Wartide 365
		70632, 70633, 70634, 70635, 70636, -- Vicious Gladiator's Wartide 371
	},
	warlock = {
		64745, 64746, 64747, 64748, 64749, -- Bloodthirsty Gladiator's FelShroud
		60478, 60479, 60480, 60481, 60482, -- Vicious Gladiator's FelShroud 365
		65528, 65529, 65530, 65571, 65572, -- Ruthless Gladiator's FelShroud 365
		70566, 70567, 70568, 70569, 70570, -- Vicious Gladiator's FelShroud 371
	},
}
for class, t in pairs(cataClassSets) do
	for _, id in pairs(t) do
		E.item_set_bonus[id] = class_set_bonus[class]
	end
end

E.item_unity = E.BLANK

--
-- CM\SYNC
--

E.sync_cooldowns = {
	["ALL"] = {},
	["DEATHKNIGHT"] = {
		[48982] = { 48982, {52284, 81163, 81164} }, -- Rune Tap, Will of the Necropolis (Rank 1/2/3)
		-- [When a damaging attack brings you below 30% of your maximum health,
		-- the cooldown on your Rune Tap ability is refreshed and your next Rune Tap has no cost]
		[49576] = { {59309, 49588, 49589} }, -- Death Grip, Glyph of Resilient Grip, Unholy Command (Rank 1/2)
		-- [When your Death Grip ability fails because its target is immune, its cooldown is reset.]
		-- [50/100% chance to refresh its cooldown when dealing a killing blow to a target that grants experience or honor.]
	},
	["HUNTER"] = {
		[781] = { {82898, 82899} }, -- Disengage, "Crouching Tiger, Hidden Chimera" (Rank 1/2)
		[34477] = { 56829 }, -- Misdirection, Glyph of Misdirection [Misdirection on pet incurs no cd]
	},
	["PALADIN"] = {
		[31935] = { 63646, {75806, 85043} }, -- Avenger's Shield, Grand Crusader (Rank 1/2)
		-- [10%/20% chance of refreshing the cooldown on your next Avenger's Shield]
	},
	["WARLOCK"] = {
		[47241] = { 59672, {85106, 85107, 85108} } -- Metamorphosis (talentId), Impending Doom (Rank 1/2/3)
		-- [Shadow Bolt, Hand of Gul'dan, Soul Fire, and Incinerate spells a 5/10/15% chance to reduce the
		-- cooldown of your Demon Form by 15 sec.]
	},
}

E.sync_periodic = {
	[34477] = true, -- XXX preactive periodic added to P\CD
}

E.sync_in_raid = E.BLANK

E:ProcessSpellDB()
