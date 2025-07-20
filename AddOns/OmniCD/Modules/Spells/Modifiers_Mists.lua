local E = select(2,	...):unpack()

-- TODO: druid dymbiosis aura

E.spell_cdmod_talents = {
	-- DK
	[55233]	= { 123079,	20	},	-- Vampiric Blood, Item - Death Knight T14 Blood 2P Bonus
	-- Druid
	[102342]	= { 131739,	30	},	-- Ironbark, Reduced Ironbark Cooldown (set bonus)
	[1850]	= { 59219,	60	},	-- Glyph of Dash
	[106922]	= { 116238,	-120,	123086,	60	},	-- Glyph of Might of Ursoc, Item - Druid T14 Guardian 2P Bonus
	[16689]	= { 116203,	45	},	-- Glyph of Nature's Grasp
	[80964]	= { 116216,	-5	},	-- Glyph of Skull Bash
	[61336]	= { 114223,	60	},	-- Glyph of Survival Instinct
	-- Hunter
	[781]	= { 118675,	10	},	-- Disengage, [Crouching Tiger, Hidden Chimera]
	[19263]	= { 118675,	60	},	-- Deterrence
	[1499]	= { 61255,	2	},	-- Freezing Trap, Trap Cooldown Reduction
	[13813]	= { 61255,	2	},	-- Explosive Trap
	[34600]	= { 61255,	2	},	-- snake Trap
	[13809]	= { 61255,	2	},	-- Ice Trap
	-- Mage
	[12042]	= { 62210,	-90	},	-- Glyph of Arcane Power
	[11129]	= { 56368,	-45	},	-- Glyph of Combustion
	[2139]	= { 115703,	-4	},	-- Glyph of Counterspell
	[122]	= { 56376,	5	},	-- Glyph of Frost Nova
	[108978]	= { 131619,	90	},	-- Alter Time, Item - Mage PvP Set 2P Bonus
	-- Monk
	[109132]	= { 115173,	5	},	-- Roll, Celerity
	[115008]	= { 115173,	5	},	-- Chi Torpedo, Celerity
	[115080]	= { 123391,	-120	},	-- Glyph of Touch of Death
	[119996]	= { 123023,	5	},	-- Glyph of Transcendence
	[113656]	= { 123149,	5	},	-- [Item - Monk T14 Windwalker 2P Bonus]
	-- Paladin
	[31821]	= { 146955,	60	},	-- Glyph of Devotion Aura
	[633]	= { 54939,	-120	},	-- Glyph of Divinity
	[31850]	= { 123104,	60	},	-- [Item - Monk T14 Windwalker 2P Bonus]
	-- Priest
	[47585]	= { 63229,	15	},	-- Glyph of Dispersion
	[6346]	= { 55678,	60	},	-- Glyph of Fear Ward
	[64044]	= { 55688,	10	},	-- Glyph of Psychic Horror
	[8122]	= { 44297,	3	},	-- Improved Psychic Scream (hand equip bonus)
	-- rogue
	[1766]	= { 56805,	-4	},	-- Glyph of Kick --> CDR in CLEU
	[73981]	= { 146629,	50	},	-- Glyph of Redirect
	[1784]	= { 63253,	4	},	-- Glyph of Stealth
	-- Shaman
	[8177]	= { 55441,	-20,	44299,	3	},	-- Glyph of Grounding Totem, Improved Grounding Totem
	[51514]	= { 63291,	10	},	-- Glyph of Hex
	[51490]	= { 62132,	10,	},	-- Thunderstorm, Glyph of Thunder
	[57994]	= { 55451,	-3	},	-- Glyph of Wind Shear
	-- Warlock
	[48020]	= { 63309,	4,	33063,	5	},	-- Glyph of Demonic Circle, Demonic Circle Cooldown Reduction (equip bonus)
	[80240]	= { 146962,	-35	},	-- Glyph of Havoc
	[104773]	= { 146964,	60	},	-- Glyph of Unending Resolve
	-- Warrior
	[1250619]	= { 103826,	8	},	-- Charge, Juggernaut
	[6544]	= { 63325,	15	},	-- Heroic Leap, Glyph of Death From Above
	[871]	= { 63329,	-120	},	-- Glyph of Shield Wall
	[23920]	= { 63328,	5	},	-- Glyph of Spell Reflection
	[12975]	= { 123146,	60	},	-- Last Stand, Item - Warrior T14 Protection 2P Bonus
}

E.spell_cdmod_talents_mult = {
	[12472]	= { 123101,	0.5	},	-- Icy Veins, Item - Mage T14 4P Bonus
	[11129]	= { 123101,	0.8	},	-- Combustion, Item - Mage T14 4P Bonus
	[633]	= { 114154,	0.5	},	-- Lay on Hands, Unbreakable Spirit
	[642]	= { 114154,	0.5	},	-- Divine Shield,
	[498]	= { 114154,	0.5	},	-- Divine Protection,
	[54428]	= { 63223,	0.5	},	-- Glyph of Divine Plea
	[2894]	= { 55455,	0.5	},	-- Glyph of Fire Elemental Totem
	[58875]	= { 55454,	0.75	},	-- Glyph of Spirit Walk
	[51490]	= { 131549,	0.5	},	-- Improved Thunderstorm (set bonus)
}

E.spell_chmod_talents = {
	[1953]	= { 146659,	1	},	-- Glyph of Rapid Displacement
	[109132]	= { 115173,	1	},	-- Roll, Celerity
	[115008]	= { 115173,	1	},	-- Chi Torpedo, Celerity
	[1044]	= { 105622,	1	},	-- Hand of Freedom, Clemecy
	[1022]	= { 105622,	1	},	-- Hand of Protection
	[6940]	= { 105622,	1	},	-- Hand of Sacrifice
	[1038]	= { 105622,	1	},	-- Hand of Salvation
	[113860]	= { 108505,	1	},	-- Dark Soul: Misery, Archimonde's Darkness
	[113861]	= { 108505,	1	},	-- Dark Soul: Knowledge
	[113858]	= { 108505,	1	},	-- Dark Soul: Instability
	[1250619]	= { 103827,	1	},	-- Charge, Double Time
}

E.spell_cdmod_by_haste = {
	[31935] = true,	-- Avenger's Shield
	[879]	= true,	-- Exorcism
	[104316]	= true,	-- Imp Swarm
}

--
-- P\CD
--

E.spell_cdmod_by_aura_mult = E.BLANK

E.spell_noreset_onencounterend = {	-- they added raid CD resets on ENCOUNTER_END to WOTLKC
	[20608]	= true,	-- Reincarnation
	[633]	= true,	-- Lay on Hands
}

--
-- CD\CD
--

E.spellcast_linked = {	-- Abilities that shared the full cd duration
	[1499]	= { 1499,	13809	},	-- Freezing Trap
	[13809]	= { 1499,	13809	},	-- Ice Trap
	[13813]	= { 13813,	13795	},	-- Explosive Trap
	[1122]	= { 1122,	18540	},	-- Summon Infernal
	[18540]	= { 1122,	18540	},	-- Summon Doomguard
}

E.spellcast_merged = {
	-- Druid
	[80965]	= 80964,	-- Skull Bash (Cat Form) -> Bear Form
	[77761]	= 106898,	-- Stampeding Roar (Bear Form) -> no form
	[77764]	= 106898,	-- Stampeding Roar (Cat Form)
	[16979]	= 102417,	-- Wild Charge (Bear Form) -> no form
	[49376]	= 102417,	-- Wild Charge (Cat Form) -> no form
	[102383]	= 102417,	-- Wild Charge (Moonkin Form) -> no form
	-- TODO: separate spec/talent in db
	[102560]	= 102558,	-- Incarnation (B) -> G
	[102543]	= 102558,	-- Incarnation (F) -> G
	--[33891]	= 102558,	-- Incarnation (R) -> G -- done in CLEU to fix shape shifting in and out of tree form
	[108292]	= 108291,	-- Heart of the Wild (F) -> (B)
	[108293]	= 108291,	-- Heart of the Wild (G) -> (B)
	[108294]	= 108291,	-- Heart of the Wild (R) -> (B)
	-- Hunter
	[60192]	= 1499,	-- Freezing Trap (Trap Launcher)
	[82941]	= 13809,	-- Ice Trap (Trap Launcher)
	[82939]	= 13813,	-- Explosive Trap (Trap Launcher)
	[82948]	= 34600,	-- Snake Trap (Trap Launcher)
	[148467]	= 19263,	-- Deterrence (Crouching Tiger, Hidden Chimera)
	--Monk
	[121827]	= 109132,	-- Roll w/ Celerity
	[121828]	= 115008,	-- Chi Torpedo w/ Celerity
	-- Priest
	[724]	= 126135,	--	Lightwell (w/ Glyph oif Lightwell)
	-- Shaman
	[32182]	= 2825,	-- Heroism
	-- Warlock
	[124916]	= 105174,	-- Chaos Wave
	[104773]	= 148683,	-- Unending Resolve w/ Glyph of Eternal Resolve (dummy)
	-- [1] Command Demon
	[119899]	= 19647,	-- Cauterize Master (Imp Pet) - 30s
	[119905]	= 19647,	-- Cauterize Master (Command Demon)
	[132411]	= 19647,	-- Singe Magic (Grimoire of Sacrifice) - 10s
	[118093]	= 19647,	-- Disarm (Voidwalker Pet) - 60s
	[119907]	= 19647,	-- Disarm (Command Demon)
	[132413]	= 19647,	-- Shadow Bulwark (Grimoire of Sacrifice) - 120s
--	[19647]	= 119898,	-- Spell Lock (Felhunter Pet) - 24s
	[119910]	= 19647,	-- Spell Lock (Command Demon)
	[132409]	= 19647,	-- Spell Lock (Grimoire of Sacrifice)
	[6360]	= 19647,	-- Whiplash (Succubus Pet) - 25s
	[119909]	= 19647,	-- Whiplash (Command Demon)
	[137706]	= 19647,	-- Whiplash (Grimoire of Sacrifice)
	[89751]	= 19647,	-- Felstorm (Felguard Pet) - 45s
	[119914]	= 19647,	-- Felstorm (Command Demon)
	[132410]	= 19647,	-- Pursuit (Grimoire of Sacrifice) - 15s
	-- [1]-1 Command Demon w/ Grimoire of Supremacy
	[115781]	= 19647,	-- Optical Blast (Observer Pet)
	[119911]	= 19647,	-- Optical Blast (Command Demon)
	[115770]	= 19647,	-- Fellash (Shivarra Pet)
	[119913]	= 19647,	-- Fellash (Command Demon)
	[115831]	= 19647,	-- Wrathstorm (Wrathguard Pet)
	[119915]	= 19647,	-- Wrathstorm (Command Demon)
	-- [2] Pet Special Ability (not Command Demon)
	[89808]	= 19505,	-- Singe Magic - 10s
	[17767]	= 19505,	-- Shadow Bulwark - 120s
	--[19505]	= 19505,	-- Devour Magic - 15s
	[6358]	= 19505,	-- Seduction - no cd
	[89766]	= 19505,	-- Axe Toss - 30s
	-- [2]-1 Pet Special Ability w/ Grimoire of Supremacy
	[115276]	= 19505,	-- Sear Magic (Fel Imp)
	[115284]	= 19505,	-- Clone Magic (Observer)
	[115268]	= 19505,	-- Mesmerize (Shivarra)
	-- [2]-2 Guardian w/ Grimoire of Supremacy
	[112927]	= 18540,	-- Summon Terrorguard
	[112921]	= 1122,	-- Summon Abyssal
	-- Warlock Grimoire of Service
	[111859]	= 108501,	-- Grimoire: Imp
	[111895]	= 108501,	-- Grimoire: Voidwalker
	[111896]	= 108501,	-- Grimoire: Succubus
	[111897]	= 108501,	-- Grimoire: Felhunter
	[111898]	= 108501,	-- Grimoire: Felguard
	-- Warrior
	[100]	= 1250619,	-- Charge (P)
	-- Racial
	[33697]	= 20572,	-- Blood Fury (Shaman, Monk)
	[33702]	= 20572,	-- Blood Fury (Mage, Warlock)
	[25046]	= 28730,	-- Arcane Torrent (Rogue)
	[50613]	= 28730,	-- Arcane Torrent (DK)
	[129597]	= 28730,	-- Arcane Torrent (Monk)
	[69179]	= 28730,	-- Arcane Torrent (Warrior)
	[80483]	= 28730,	-- Arcane Torrent (Hunter)
	[59547]	= 28880,	-- Gift of the Naaru (Shaman)
	[59545]	= 28880,	-- Gift of the Naaru (DK)
	[59548]	= 28880,	-- Gift of the Naaru (Mage)
	[59544]	= 28880,	-- Gift of the Naaru (Priest)
	[59543]	= 28880,	-- Gift of the Naaru (Hunter)
	[59542]	= 28880,	-- Gift of the Naaru (Paladin)
	[121093]	= 28880,	-- Gift of the Naaru (Monk)
	-- SPELL_INTERRUPT Id for raid target marker display on interrupt bar (interrupt spellID = casted spellID)
	[93985]	= 80964,	-- Skull Bash = castID (Bear Form)
	[97547]	= 78675,	-- Solar Beam = castID (Silence debuffID 81261)
	[113288]	= 113286,	-- Solar Beam = castID (both MoP: Symbiosis)
	[32747]	= 15487,	-- Silence (PVE only) = castID (Silence debuffID 15487)
--	[91807]	= 47482,	-- Shambling Rush = Leap 47482
	-- Trinket
	[126683]	= 126690,	-- Call of Dominance
	[126679]	= 126690,	-- Call of Victory
}

E.spellcast_merged_updateoncast = {
	-- [1] Command Demon
	[19647]	= { 24,	136174},	-- Spell Lock (Felhunter) - 24s
	[119910]	= { 24,	136174},	-- Spell Lock (Command Demon)
	[132409]	= { 24,	136174},	-- Spell Lock (Grimoire of Sacrifice)
	[119899]	= { 30,	463567},	-- Cauterize Master (Pet) - 30s
	[119905]	= { 30,	463567},	-- Cauterize Master (Command Demon)
	[132411]	= { 10,	135791},	-- Singe Magic (Grimoire of Sacrifice) - 10s
	[118093]	= { 60,	132343},	-- Disarm (Pet) - 60s
	[119907]	= { 60,	132343},	-- Disarm (Command Demon)
	[132413]	= { 120,	136121},	-- Shadow Bulwark - 120s
	[6360]	= { 25,	460858},	-- Whiplash (Pet) - 25s
	[119909]	= { 25,	460858},	-- Whiplash (Command Demon)
	[137706]	= { 25,	460858},	-- Whiplash (Grimoire of Sacrifice)
	[89751]	= { 45,	236303},	-- Felstorm (Pet) - 45s
	[119914]	= { 45,	236303},	-- Felstorm (Command Demon)
	[132410]	= { 15,	236303},	-- Pursuit (Grimoire of Sacrifice) - 15s
	-- [1]-1 Command Demon w/ Grimoire of Supremacy
	[115781]	= { 24,	136028},	-- Optical Blast (Pet)
	[119911]	= { 24,	136028},	-- Optical Blast (Command Demon)
	[115770]	= { 25,	468265},	-- Fellash (Command Demon)
	[119913]	= { 25,	468265},	-- Fellash (Grimoire of Sacrifice)
	[115831]	= { 45,	236303},	-- Wrathstorm (Pet) - 45s
	[119915]	= { 45,	236303},	-- Wrathstorm (Command Demon)
	-- [2] Pet Special Ability (not Command Demon)
	[89808]	= { 10,	135791 },	-- Singe Magic - 10s
	[17767]	= { 120,	136121 },	-- Shadow Bulwark - 120s
	[19505]	= { 15,	136075 },	-- Devour Magic - 15s
	[6358]	= { 1,	136175 },	-- Seduction - no cd
	[89766]	= { 30,	236316 },	-- Axe Toss - 30s
	-- [2]-1 Pet Special Ability w/ Grimoire of Supremacy
	[115276]	= { 20,	135791 },	-- Sear Magic (Fel Imp)
	[115284]	= { 15,	236407 },	-- Clone Magic (Observer)
	[115268]	= { 1,	237185 },	-- Mesmerize (Shivara)
	-- [2]-2 Guardian w/ Grimoire of Supremacy
	[112927]	= { 600,	615098 },	-- Summon Terrorguard
	[112921]	= { 600,	524350 },	-- Summon Abyssal
	-- Warlock Grimoire of Service
	[111859]	= { 120,	136218 },	-- Grimoire: Imp
	[111895]	= { 120,	136221 },	-- Grimoire: Voidwalker
	[111896]	= { 120,	136220 },	-- Grimoire: Succubus
	[111897]	= { 120,	136217 },	-- Grimoire: Felhunter
	[111898]	= { 120,	136216 },	-- Grimoire: Felguard
}

E.spellcast_shared_cdstart = {
	[42292]	= { 59752,120, 7744,30	},	-- PvP Trinket	-- Cata 45>30s with Will
	[59752]	= { 42292,120	},	-- Will to Survive
	[7744]	= { 42292,30	},	-- Will of the Forsaken
	[2894]	= { 2062,60	},	-- Fire Elemetal Totem (lasts 1 min in MoP = shared CD)
	[2062]	= { 2894,60	},	-- Earth Elemental Totem
	[6552]	= { 102060,15	},	-- Pummel
	[102060]	= { 6552,15	},	-- Disrupting Shout

	[105708]	= { 105709,60, 105701,60, 105702,60, 105706,60, 105697,60, 11392,60	},
	[105709]	= { 105708,60, 105701,60, 105702,60, 105706,60, 105697,60, 11392,60	},
	[105701]	= { 105708,60, 105709,60, 105702,60, 105706,60, 105697,60, 11392,60	},
	[105702]	= { 105708,60, 105709,60, 105701,60, 105706,60, 105697,60, 11392,60	},
	[105706]	= { 105708,60, 105709,60, 105701,60, 105702,60, 105697,60, 11392,60	},
	[105697]	= { 105708,60, 105709,60, 105701,60, 105702,60, 105706,60, 11392,60	},
	[11392]	= { 105708,600, 105709,600, 105701,600, 105702,600, 105706,600, 105697,600	},
}

E.spellcast_cdreset = {
	[11958]	= { nil,	45438,120,122	},	-- Cold Snap, Ice Block , Cone of Cold, Frost Nova
	[14185]	= { nil,	2983,1856,5277,51722	},	-- Preparation, Sprint, Vanish, Evasion, Dismantle
	-- Call of the Elements, Capacitor Totem, Earthbind Totem, Earthgrab Totem, Grounding Totem, Healing Stream Totem, Stone Bulwark Totem, Tremor Totem, Windwalk Totem
	[108285]	= { 108285,	108269,2484,51485,8177,5394,108270,8143,108273	},
}

E.spellcast_cdr = E.BLANK

--
-- CD\CLEU (NOTE: incl all ranks)
--

E.spell_auraremoved_cdstart_preactive = { -- auraId = spellID (prerequisite: auraId == castId)
	-- enable in ProcessSpell and cd start by CLEU (0: enable only)
	[132158]	= 132158,	-- Nature's Swiftness
	[5215]	= 5215,	-- Prowl
	[5384]	= 0,	-- Feign Death -> own UNIT_AURA
	[34477]	= 0,	-- Misdirection
	[12043]	= 12043,	-- POM
	[108978]	= 108978,	-- Alter Time (set enabled. cd start done in CLEU)
	[116680]	= 116680,	-- Thunder focus Tea
	[89485]	= 89485,	-- Inner Focus
	[1784]	= 1784,	-- Stealth
	[16188]	= 16188,	-- Ancetral Swiftness
}

E.spell_auraapplied_processspell = {
	[123981]	= 114556,	-- Perdition, Purgatory
	[87024]	= 86949,	-- Cauterized
	[45182]	= 31230,	-- Cheating Death
	[31616]	= 30884,	-- Nature's Guardian
}

E.spell_dispel_cdstart = {
	[88423]	= true,	-- Nature's Cure
	[2782]	= true,	-- Remove Corruption
	[475]	= true,	-- Remove Curse
	[115450]	= true,	-- Detox
	[4987]	= true,	-- Cleanse
	[122288]	= true,	-- Cleanse (Symbiosis)
	[527]	= true,	-- Purify
	[77130]	= true,	-- Purify Spirit
	[51886]	= true,	-- Cleanse Spirit
}

E.selfLimitedMinMaxReducer = E.BLANK
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
	-- Season12
	[84931] = 37864,	-- Malevolent Gladiator's Medallion of Tenacity
	[84933] = 37864,	-- Malevolent Gladiator's Medallion of Meditation
	[84944] = 37864,	-- Malevolent Gladiator's Medallion of Cruelty
	[84932] = 37864,	-- Malevolent Gladiator's Medallion of Meditation (Alliance)
	[84943] = 37864,	-- Malevolent Gladiator's Medallion of Cruelty (Alliance)
	[84945] = 37864,	-- Malevolent Gladiator's Medallion of Tenacity (Alliance)
	[84936] = 64740,	-- Malevolent Gladiator's Emblem of Cruelty
	[84938] = 64740,	-- Malevolent Gladiator's Emblem of Tenacity
	[84939] = 64740,	-- Malevolent Gladiator's Emblem of Meditation
	[84934] = 64687,	-- Malevolent Gladiator's Badge of Conquest
	[84940] = 64687,	-- Malevolent Gladiator's Badge of Dominance
	[84942] = 64687,	-- Malevolent Gladiator's Badge of Victory
}

E.item_equip_bonus = {
	[84841] = 61255,	-- Malevolent Gladiator's Chain Gauntlets (Hunter)
	[84838] = 44297,	-- Malevolent Gladiator's Satin Gloves
	[84846] = 44297,	-- Malevolent Gladiator's Mooncloth Gloves
	[84842] = 33063,	-- Malevolent Gladiator's Felweave Handguards
}

E.item_set_bonus = {}

local class_set_bonus = {
	pveDea	= { 123079,	2	},	-- [Item - Death Knight T14 Blood 2P Bonus]
	pveDru	= { 123086,	2	},	-- [Item - Druid T14 Guardian 2P Bonus]
	pveMag	= { 123101,	4	},	-- [Item - Mage T14 4P Bonus]
	pveMon	= { 123149,	2	},	-- [Item - Monk T14 Windwalker 2P Bonus]
	pvePal	= { 123104,	2	},	-- [Item - Paladin T14 Protection 2P Bonus]
	pveWar	= { 123146,	2	},	-- [tem - Warrior T14 Protection 2P Bonus]
	pvpDru	= { 131739,	4	},	-- Reduced Ironbark Cooldown
	pvpMag	= { 131619,	4	},	-- [Item - Mage PvP Set 4P Bonus]
	pvpEle	= { 131549,	4	},	-- Improved Thunderstorm
	pvpEnh	= { 44299,	2	},	-- Improved Grounding Totem
}

local setItems = {
	pveDea	= { 85316, 85314, 85318, 85317, 85315, 86920, 86922, 86918, 86919, 86921 },	-- Plate of the Lost Catacomb (normal, heroic)
	pveDru	= { 85381, 85383, 85379, 85380, 85382, 86940, 86942, 86938, 86939, 86941 },	-- Armor of the Eternal Blossom
	pveMag	= { 85377, 85374, 85375, 85378, 85376, 87008, 87011, 87010, 87007, 87009 },	-- Regalia of the Burning Scroll
	pveMon	= { 85396, 85398, 85394, 85395, 85397, 87086, 87088, 87084, 87085, 87087 },	-- Battlegear of the Red Crane
	pvePal	= { 85321, 85319, 85323, 85322, 85320, 87111, 87113, 87109, 87110, 87112 },	-- White Tiger Plate
	pveWar	= { 85326, 85324, 85328, 85327, 85325, 87199, 87201, 87197, 87198, 87200 },	-- Plate of Resounding Rings
	pvpDru	= { 84850, 84927, 84907, 84833, 84882 },	-- Malevolent Gladiator's Kodohide
	pvpMag	= { 84855, 84917, 84904, 84837, 84875 },	-- Malevolent Gladiator's Silk
	pvpEle	= { 84860, 84924, 84798, 84845, 84879 },	-- Malevolent Gladiator's Mail
	pvpEnh	= { 84865, 84930, 84800, 84847, 84885 },	-- Malevolent Gladiator's Ringmail
}

for class, t in pairs(setItems) do
	for _, id in pairs(t) do
		E.item_set_bonus[id] = class_set_bonus[class]
	end
end

E.item_unity = E.BLANK

--
-- CM\SYNC
--

E.sync_cooldowns = {
	["DEATHKNIGHT"]	= {
		[48707]	= { 146648	},	-- Anti-Magic Shell, Glyph of Regenerative Magic [If Anti-Magic Shell expires after its full duration, the cooldown is reduced by up to 50%, based on the amount of damage absorbtion remaining.]
	},
	["ROGUE"]	={
		[13750]	= { 260,	},	-- Adrenaline Rush
		[51690]	= { 260,	},	-- Killing Spree
		[73981]	= { 260,	},	-- Redirect
		[121471]	= { 260,	},	-- Shadow Blades
		[2983]	= { 260,	},	-- Sprint
	},
	["ALL"]	= {
		[6262]	= { false	},	-- Healthstone (HS, Pot CD starts in combat, this is to sync remaining charges)
	},
}

E.sync_reset = E.BLANK
E.sync_in_raid = E.BLANK

E:ProcessSpellDB()
