local E = select(2,	...):unpack()

E.spell_db = {
	["DEATHKNIGHT"] = {
		{ spellID = 47528,	duration = 15,	type = "interrupt",	},	-- Mind Freeze
		{ spellID = 108194,	duration = 30,	type = "cc",	spec = true	},	-- Asphyxiate
		{ spellID = 108200,	duration = 60,	type = "cc",	spec = true	},	-- Remorseless Winter
		{ spellID = 108199,	duration = 60,	type = "aoeCC",	spec = true	},	-- Gorefiend's Grasp
		{ spellID = 49576,	duration = 25,	type = "disarm",	},	-- Death Grip
		{ spellID = 47476,	duration = 60,	type = "disarm",	talent = 108194	},	-- Strangulate
		{ spellID = 48707,	duration = 45,	type = "defensive",	},	-- Anti-Magic Shell
		{ spellID = 49222,	duration = 60,	type = "defensive",	spec = {250}	},	-- Bone Shield
		{ spellID = 49028,	duration = 90,	type = "defensive",	spec = {250}	},	-- Dancing Rune Weapon
		{ spellID = 48792,	duration = 180,	type = "defensive",	},	-- Icebound Fortitude
		{ spellID = 114556,	duration = 180,	type = "defensive",	spec = true	},	-- Purgatory
		{ spellID = 48982,	duration = 30,	type = "defensive",	spec = {250}	},	-- Rune Tap
		{ spellID = 55233,	duration = 60,	type = "defensive",	spec = {250}	},	-- Vampiric Blood
		{ spellID = 51052,	duration = 120,	type = "raidDefensive",	spec = true	},	-- Anti-Magic Zone
		{ spellID = 48743,	duration = 120,	type = "heal",	spec = true	},	-- Death Pact
		{ spellID = 42650,	duration = 600,	type = "offensive",	},	-- Army of the Dead
		{ spellID = 43265,	duration = 30,	type = "offensive",	},	-- Death and Decay
		{ spellID = 47568,	duration = 300,	type = "offensive",	},	-- Empower Rune Weapon
		{ spellID = 57330,	duration = 20,	type = "offensive",	},	-- Horn of Winter
		{ spellID = 77575,	duration = {[250]=30,default=60},	type = "offensive",	},	-- Outbreak
		{ spellID = 51271,	duration = 60,	type = "offensive",	spec = {251}	},	-- Pillar of Frost
		{ spellID = 49206,	duration = 180,	type = "offensive",	spec = {252}	},	-- Summon Gargoyle
		{ spellID = 115989,	duration = 90,	type = "offensive",	spec = true	},	-- Unholy Blight
		{ spellID = 49016,	duration = 180,	type = "offensive",	spec = {252}	},	-- Unholy Frenzy
		{ spellID = 108201,	duration = 120,	type = "counterCC",	spec = true	},	-- Desecreated Ground
		{ spellID = 49039,	duration = 120,	type = "counterCC",	spec = true	},	-- Lichborne
		{ spellID = 96268,	duration = 30,	type = "movement",	spec = true	},	-- Death's Advance
		{ spellID = 77606,	duration = {[250]=30,default=60},	type = "other",	},	-- Dark Simulacrum
		{ spellID = 123693,	duration = 25,	type = "other",	spec = true	},	-- Plague Leech
		{ spellID = 61999,	duration = 600,	type = "other",	},	-- Raise Ally
		{ spellID = 46584,	duration = {[252]=60,default=120},	type = "other",	},	-- Raise Dead
		{ spellID = 56222,	duration = 8,	type = "taunt",	spec = {250}	},	-- Dark Command
		-- symbiosis
		{ spellID = 113072,	duration = 180,	type = "defensive",	spec = true	},	-- Might of Ursoc (Tank)
		{ spellID = 113516,	duration = 180,	type = "defensive",	spec = true	},	-- Wild Mushroom: Plague
	},
	["DRUID"] = {
		{ spellID = 80964,	duration = 15,	type = "interrupt",	spec = {103,104}	},	-- Skull Bash (Bear Form)
		{ spellID = 78675,	duration = 60,	type = "interrupt",	spec = {102}	},	-- Solar Beam
		{ spellID = 88423,	duration = 8,	type = "dispel",	spec = {105}	},	-- Nature's Cure
		{ spellID = 2782,	duration = 8,	type = "dispel",	spec = {102,103,104}	},	-- Remove Corruption
		{ spellID = 102795,	duration = 60,	type = "cc",	spec = {104}	},	-- Bear Hug
		{ spellID = 99,	duration = 30,	type = "aoeCC",	spec = true	},	-- Disorienting Roar
		{ spellID = 22570,	duration = 10,	type = "cc",	},	-- Maim
		{ spellID = 5211,	duration = 50,	type = "cc",	spec = true	},	-- Mighty Bash
		{ spellID = 132469,	duration = 30,	type = "aoeCC",	spec = true	},	-- Typhoon
		{ spellID = 770,	duration = 0,	type = "disarm",	spec = 114237	},	-- Faerie Fire (w/ Glyph of Fae Silence) --> see CLEU
		{ spellID = 106737,	duration = 20,	type = "disarm",	spec = true,	charges = 3	},	-- Force of Nature
		{ spellID = 102359,	duration = 30,	type = "disarm",	spec = true	},	-- Mass Entanglement
		{ spellID = 16689,	duration = 60,	type = "disarm",	},	-- Nature's Grasp
		{ spellID = 102793,	duration = 60,	type = "disarm",	spec = true	},	-- Ursol's Vortex
		{ spellID = 22812,	duration = {[105]=45,[104]=30,default=60},	type = "defensive",	},	-- Barkskin
		{ spellID = 106922,	duration = 180,	type = "defensive",	},	-- Might of Ursoc
		{ spellID = 108238,	duration = 120,	type = "defensive",	spec = true	},	-- Renewal
		{ spellID = 62606,	duration = 9,	type = "defensive",	spec = {104},	charges = 3	},	-- Savage Defense
		{ spellID = 61336,	duration = 180,	type = "defensive",	spec = {103,104}	},	-- Survival Instincts
		{ spellID = 102342,	duration = 60,	type = "externalDefensive",	spec = {105}	},	-- Ironbark
		{ spellID = 124974,	duration = 90,	type = "raidDefensive",	spec = true	},	-- Nature's Vigil
		{ spellID = 740,	duration = {[105]=180,default=480},	type = "raidDefensive",	buff = 44203	},	-- Tranquility (buff delayed = no hl)
		{ spellID = 102351,	duration = 30,	type = "heal",	spec = true	},	-- Cenarion Ward
		{ spellID = 18562,	duration = 15,	type = "heal",	spec = {105}	},	-- Swiftmend
		{ spellID = 50334,	duration = 180,	type = "offensive",	spec = {104}	},	-- Berserk (G)
		{ spellID = 106951,	duration = 180,	type = "offensive",	spec = {103}	},	-- Berserk (F)
		{ spellID = 112071,	duration = 180,	type = "offensive",	spec = {102}	},	-- Celestial Alignment
		{ spellID = 108291,	duration = {[104]=180,default=360},	type = "offensive",	spec = 108288	},	-- Heart of the Wild (B)
		{ spellID = 102558,	duration = 180,	type = "offensive",	spec = 106731	},	-- Incarnation -- no hl -- TODO: set buff as return func
		{ spellID = 48505,	duration = 90,	type = "offensive",	spec = {102}	},	-- Starfall
		{ spellID = 78674,	duration = 15,	type = "offensive",	spec = {102}	},	-- Starsurge
		{ spellID = 5217,	duration = 30,	type = "offensive",	spec = {103}	},	-- Tiger's Fury
		{ spellID = 1850,	duration = 180,	type = "movement",	},	-- Dash
		{ spellID = 102280,	duration = 30,	type = "movement",	spec = true	},	-- Displacer Beast
		{ spellID = 102417,	duration = 15,	type = "movement",	spec = 102401	},	-- Wild Charge (no form)
		{ spellID = 106898,	duration = 120,	type = "raidMovement",	},	-- Stampeding roar (no form)
		{ spellID = 5229,	duration = 60,	type = "other",	spec = {104}	},	-- Enrage
		{ spellID = 29166,	duration = 180,	type = "other",	},	-- Innervate
		{ spellID = 132158,	duration = 60,	type = "other",	spec = {102,103,105}	},	-- Nature's Swiftness
		{ spellID = 5215,	duration = 10,	type = "other",	},	-- Prowl
		{ spellID = 20484,	duration = 600,	type = "other",	},	-- Rebirth
		{ spellID = 6795,	duration = 8,	type = "taunt",	},	-- Growl
		-- symbiosis
		{ spellID = 110570,	duration = 45,	type = "defensive",	spec = true	},	-- Anti-Magic Shell
		{ spellID = 122282,	duration = 0,	type = "offensive",	spec = true	},	-- Death Coil
		{ spellID = 122285,	duration = 60,	type = "defensive",	spec = true	},	-- Bone Shield
		{ spellID = 110575,	duration = 180,	type = "defensive",	spec = true	},	-- Icebound Fortitude
		{ spellID = 110588,	duration = 30,	type = "other",	spec = true	},	-- Misdirection
		{ spellID = 110597,	duration = 30,	type = "other",	spec = true	},	-- Play Dead
		{ spellID = 110600,	duration = 30,	type = "other",	spec = true	},	-- Ice Trap
		{ spellID = 110617,	duration = 120,	type = "immunity",	spec = true	},	-- Deterrence
		{ spellID = 110621,	duration = 180,	type = "offensive",	spec = true	},	-- Mirror Image
		{ spellID = 110693,	duration = 25,	type = "disarm",	spec = true	},	-- Frost Nova
		{ spellID = 110694,	duration = 0,	type = "defensive",	spec = true	},	-- Frost Armor
		{ spellID = 110696,	duration = 300,	type = "immunity",	spec = true	},	-- Ice Block
		{ spellID = 126458,	duration = 60,	type = "disarm",	spec = true	},	-- Grapple Weapon
		{ spellID = 126449,	duration = 35,	type = "cc",	spec = true	},	-- Clash
		{ spellID = 126453,	duration = 60,	type = "defensive",	spec = true	},	-- Elusive Brew
		{ spellID = 126456,	duration = 180,	type = "defensive",	spec = true	},	-- Fortifying Brew
		{ spellID = 110698,	duration = 60,	type = "cc",	spec = true	},	-- Hammer of Justice
		{ spellID = 110700,	duration = 300,	type = "immunity",	spec = true	},	-- Divine Shield
		{ spellID = 110701,	duration = 30,	type = "offensive",	spec = true	},	-- Consecration
		{ spellID = 122288,	duration = 8,	type = "dispel",	spec = true	},	-- Cleanse
		{ spellID = 110707,	duration = 60,	type = "dispel",	spec = true	},	-- Mass Dispel
		{ spellID = 110715,	duration = 180,	type = "defensive",	spec = true	},	-- Dispersion
		{ spellID = 110717,	duration = 180,	type = "counterCC",	spec = true	},	-- Fear Ward
		{ spellID = 110718,	duration = 90,	type = "movement",	spec = true	},	-- Leap of Faith
		{ spellID = 110788,	duration = 120,	type = "defensive",	spec = true	},	-- Cloak of Shadows
		{ spellID = 110730,	duration = 60,	type = "other",	spec = true	},	-- Redirect
		{ spellID = 122289,	duration = 0,	type = "defensive",	spec = true	},	-- Feint
		{ spellID = 110791,	duration = 180,	type = "defensive",	spec = true	},	-- Evasion
		{ spellID = 110802,	duration = 0,	type = "dispel",	spec = true	},	-- Purge
		{ spellID = 110807,	duration = 120,	type = "offensive",	spec = true	},	-- Feral Spirit
		{ spellID = 110803,	duration = 0,	type = "other",	spec = true	},	-- Lightning Shield
		{ spellID = 110806,	duration = 120,	type = "other",	spec = true	},	-- Spiritwalker's Grace
		{ spellID = 122291,	duration = 180,	type = "defensive",	spec = true	},	-- Unending Resolve
		{ spellID = 110810,	duration = 30,	type = "other",	spec = true	},	-- Soul Swap
		{ spellID = 122290,	duration = 15,	type = "other",	spec = true	},	-- Life Tap
		{ spellID = 112970,	duration = 30,	type = "movement",	spec = true	},	-- Demonic Circle: Teleport
		{ spellID = 122292,	duration = 60,	type = "counterCC",	spec = true	},	-- Intervene
		{ spellID = 112997,	duration = 300,	type = "other",	spec = true	},	-- Shattering Blow
		{ spellID = 113002,	duration = 120,	type = "counterCC",	spec = true	},	-- Spell Reflection
		{ spellID = 113004,	duration = 90,	type = "cc",	spec = true	},	-- Intimidating Roar
	},
	["HUNTER"] = {
		{ spellID = 147362,	duration = 24,	type = "interrupt",	spec = {253,255}	},	-- Counter Shot
		{ spellID = 34490,	duration = 24,	type = "interrupt",	spec = {254}	},	-- Silencing Shot
		{ spellID = 19801,	duration = 10,	type = "dispel",	spec = 119384	},	-- Tranquilizing Shot (w/ Glpyh of Tranquilizing Shot)
		{ spellID = 1499,	duration = {[255]=24,default=30},	type = "cc",	},	-- Freezing Trap
		{ spellID = 19577,	duration = 60,	type = "cc",	spec = true	},	-- Intimidation
		{ spellID = 19503,	duration = 30,	type = "cc",	},	-- Scatter Shot
		{ spellID = 19386,	duration = 45,	type = "cc",	spec = true	},	-- Wyvern Sting
		{ spellID = 109248,	duration = 45,	type = "aoeCC",	spec = true	},	-- Binding Shot
		{ spellID = 19263,	duration = 180,	type = "immunity",	charges = 2	},	-- Deterrence
		{ spellID = 51753,	duration = 60,	type = "defensive",	buff = 51755	},	-- Camouflage
		{ spellID = 53480,	duration = 60,	type = "externalDefensive",	},	-- Roar of Sacrifice (Cunning Pet)
		{ spellID = 109304,	duration = 120,	type = "heal",	spec = true	},	-- Exhilaration
		{ spellID = 131894,	duration = 120,	type = "offensive",	spec = true	},	-- A Murder of Crows
		{ spellID = 120360,	duration = 30,	type = "offensive",	spec = true	},	-- Barrage
		{ spellID = 19574,	duration = 60,	type = "offensive",	spec = {253}	},	-- Bestial Wrath
		{ spellID = 3674,	duration = 24,	type = "offensive",	spec = {255}	},	-- Black Arrow
		{ spellID = 120679,	duration = 30,	type = "offensive",	spec = true},	-- Dire Beast
		{ spellID = 13813,	duration = {[255]=24,default=30},	type = "offensive",	},	-- Explosive Trap
		{ spellID = 117050,	duration = 15,	type = "offensive",	spec = true	},	-- Glaive Toss
		{ spellID = 120697,	duration = 90,	type = "offensive",	spec = true	},	-- Lynx Rush
		{ spellID = 109259,	duration = 45,	type = "offensive",	spec = true	},	-- Power Shot
		{ spellID = 3045,	duration = 180,	type = "offensive",	},	-- Rapid Fire
		{ spellID = 34600,	duration = {[255]=24,default=30},	type = "offensive",	},	-- Snake Trap
		{ spellID = 121818,	duration = 300,	type = "offensive",	},	-- Stampede
		{ spellID = 53271,	duration = 45,	type = "freedom",	buff = 54216	},	-- Master's Call (src is pet = no hl)
		{ spellID = 781,	duration = 20,	type = "movement",	},	-- Disengage
		{ spellID = 5384,	duration = 30,	type = "other",	},	-- Feign Death
		{ spellID = 82726,	duration = 30,	type = "other",	spec = true	},	-- Fervor
		{ spellID = 1543,	duration = 20,	type = "other",	},	-- Flare
		{ spellID = 13809,	duration = {[255]=24,default=30},	type = "other",	},	-- Ice Trap
		{ spellID = 34477,	duration = 30,	type = "other",	},	-- Misdirection
		{ spellID = 20736,	duration = 8,	type = "taunt",	},	-- Distracting Shot
		-- symbiosis
		{ spellID = 113073,	duration = 180,	type = "movement",	spec = true	},	-- Dash
	},
	["MAGE"] = {
		{ spellID = 2139,	duration = 24,	type = "interrupt",	},	-- Counterspell
		{ spellID = 475,	duration = 8,	type = "dispel",	},	-- Remove Curse
		{ spellID = 44572,	duration = 30,	type = "cc",	},	-- Deep Freeze
		{ spellID = 31661,	duration = 20,	type = "aoeCC",	spec = {63}	},	-- Dragon's Breath
		{ spellID = 113724,	duration = 45,	type = "aoeCC",	spec = true	},	-- Ring of Frost
		{ spellID = 33395,	duration = 25,	type = "disarm",	spec = {64}	},	-- Freeze (Water Elemental spell)
		{ spellID = 122,	duration = 25,	type = "disarm",	},	-- Frost Nova
		{ spellID = 102051,	duration = 20,	type = "disarm",	spec = true	},	-- Frostjaw
		{ spellID = 111264,	duration = 20,	type = "disarm",	spec = true	},	-- Ice Ward
		{ spellID = 45438,	duration = 300,	type = "immunity",	},	-- Ice Block
		{ spellID = 108978,	duration = 180,	type = "defensive",	},	-- Alter Time (spellID:108978,castID:127140,auraID:110909)
		{ spellID = 86949,	duration = 120,	type = "defensive",	spec = true	},	-- Cauterize
		{ spellID = 11958,	duration = 180,	type = "defensive",	spec = true	},	-- Cold Snap
		{ spellID = 110959,	duration = 90,	type = "defensive",	spec = true	},	-- Greater Invisibility
		{ spellID = 11426,	duration = 25,	type = "defensive",	spec = true	},	-- Ice Barrier
		{ spellID = 115610,	duration = 25,	type = "defensive",	spec = true	},	-- Temporal Shield
		{ spellID = 12042,	duration = 90,	type = "offensive",	spec = {62}	},	-- Arcane Power
		{ spellID = 11129,	duration = 45,	type = "offensive",	spec = {63}	},	-- Combustion (stun)
		{ spellID = 84714,	duration = 60,	type = "offensive",	spec = {64}	},	-- Frozen Orb
		{ spellID = 12472,	duration = 180,	type = "offensive",	spec = {64}	},	-- Icy Veins
		{ spellID = 1463,	duration = 25,	type = "offensive",	spec = true	},	-- Incanter's Ward
		{ spellID = 55342,	duration = 180,	type = "offensive",	},	-- Mirror Image
		{ spellID = 80353,	duration = 300,	type = "offensive",	},	-- Time Warp
		{ spellID = 108843,	duration = 25,	type = "movement",	spec = true	},	-- Blazing Speed
		{ spellID = 1953,	duration = 15,	type = "movement",	},	-- Blink
		{ spellID = 12051,	duration = 120,	type = "other",	talent = {114003,116011}	},	-- Evocation
		{ spellID = 108839,	duration = 20,	type = "other",	spec = true,	charges = 3	},	-- Ice Floes
		{ spellID = 66,	duration = 300,	type = "other",	talent = 110959	},	-- Invisibility
		{ spellID = 12043,	duration = 90,	type = "other",	spec = true	},	-- Presence of Mind
		{ spellID = 31687,	duration = 60,	type = "other",	spec = {64}	},	-- Summon Water Elemental
		-- symbiosis
		{ spellID = 113074,	duration = 10,	type = "heal",	spec = true	},	-- Healing Touch
	},
	["MONK"] = {
		{ spellID = 137562,	duration = 120,	type = "pvptrinket",	},	-- Nimble Brew
		{ spellID = 116705,	duration = 15,	type = "interrupt",	},	-- Spear Hand Strike
		{ spellID = 115450,	duration = 8,	type = "dispel",	},	-- Detox
		{ spellID = 119392,	duration = 30,	type = "cc",	spec = true	},	-- Charging Ox Wave
		{ spellID = 122057,	duration = 35,	type = "cc",	spec = {268}	},	-- Clash
		{ spellID = 115078,	duration = 15,	type = "cc",	},	-- Paralysis
		{ spellID = 119381,	duration = 45,	type = "aoeCC",	spec = true	},	-- Leg Sweep
		{ spellID = 116844,	duration = 45,	type = "aoeCC",	spec = true	},	-- Ring of Peace
		{ spellID = 117368,	duration = 60,	type = "disarm",	},	-- Grapple Weapon
		{ spellID = 122278,	duration = 90,	type = "defensive",	spec = true	},	-- Dampen Harm
		{ spellID = 122783,	duration = 90,	type = "defensive",	spec = true	},	-- Diffuse Magic
		{ spellID = 115203,	duration = 180,	type = "defensive",	buff = 120954	},	-- Fortifying Brew
		{ spellID = 122470,	duration = 90,	type = "defensive",	spec = {269},	buff = 125174	},	-- Touch of Karma
		{ spellID = 115176,	duration = 180,	type = "defensive",	},	-- Zen Meditation
		{ spellID = 115213,	duration = 180,	type = "externalDefensive",	spec = {268}	},	-- Avert Harm
		{ spellID = 116849,	duration = 120,	type = "externalDefensive",	spec = {270}	},	-- Life Cocoon
		{ spellID = 115310,	duration = 180,	type = "raidDefensive",	spec = {270}	},	-- Revival
		{ spellID = 123986,	duration = 30,	type = "offensive",	spec = true	},	-- Chi Burst
		{ spellID = 115098,	duration = 15,	type = "offensive",	spec = true	},	-- Chi Wave
		{ spellID = 115072,	duration = 15,	type = "offensive",	},	-- Expel Harm
		{ spellID = 113656,	duration = 25,	type = "offensive",	spec = {269}	},	-- Fists of Fury
		{ spellID = 123995,	duration = 180,	type = "offensive",	spec = 123904,	icon = 620832	},	-- Invoke Xuen, the White Tiger
		{ spellID = 115080,	duration = 90,	type = "offensive",	},	-- Touch of Death
		{ spellID = 116841,	duration = 30,	type = "freedom",	spec = true	},	-- Tiger's Lust
		{ spellID = 115008,	duration = 20,	type = "movement",	spec = true,	charges = 2	},	-- Chi Torpedo
		{ spellID = 101545,	duration = 25,	type = "movement",	spec = {269},	},	-- Flying Serpent Kick
		{ spellID = 109132,	duration = 20,	type = "movement",	charges = 2, talent = 115008	},	-- Roll
		{ spellID = 119996,	duration = 25,	type = "movement",	},	-- Transcendence: Transfer
		{ spellID = 115399,	duration = 45,	type = "other",	spec = true,	charges = 2	},	-- Chi Brew
		{ spellID = 115288,	duration = 60,	type = "other",	spec = {269},	},	-- Energizing Brew
		{ spellID = 115315,	duration = 30,	type = "other",	spec = {268}	},	-- Summon Black Ox Statue
		{ spellID = 115313,	duration = 30,	type = "other",	spec = {270}	},	-- Summon Jade Serpent Statue
		{ spellID = 116680,	duration = 45,	type = "other",	spec = {270}	},	-- Thunder Focus Tea
		{ spellID = 115546,	duration = 8,	type = "taunt",	},	-- Provoke
		-- symbiosis
		{ spellID = 113306,	duration = 180,	type = "defensive",	spec = true	},	-- Survival Instinct (Tank)
		{ spellID = 127361,	duration = 60,	type = "cc",	spec = true	},	-- Bear Hug (DPS)
		{ spellID = 113275,	duration = 0,	type = "disarm",	spec = true	},	-- Entangling Roots (Healer)
	},
	["PALADIN"] = {
		{ spellID = 31935,	duration = 15,	type = "interrupt",	spec = {66}	},	-- Avenger's Shield
		{ spellID = 96231,	duration = 15,	type = "interrupt",	},	-- Rebuke
		{ spellID = 4987,	duration = 8,	type = "dispel",	},	-- Cleanse
		{ spellID = 105593,	duration = 30,	type = "cc",	spec = true	},	-- Fist of Justice
		{ spellID = 853,	duration = 60,	type = "cc",	talent = 105593	},	-- Hammer of Justice
		{ spellID = 20066,	duration = 15,	type = "cc",	spec = true	},	-- Repentance
		{ spellID = 10326,	duration = 15,	type = "cc",	},	-- Turn Evil
		{ spellID = 115750,	duration = 120,	type = "aoeCC",	},	-- Blinding Light
		{ spellID = 642,	duration = 300,	type = "immunity",	},	-- Divine Shield
		{ spellID = 31850,	duration = 180,	type = "defensive",	spec = {66}	},	-- Ardent Defender
		{ spellID = 498,	duration = 60,	type = "defensive",	},	-- Divine Protection
		{ spellID = 86659,	duration = 180,	type = "defensive",	spec = {66}	},	-- Guardian of Ancient Kings (P)
		{ spellID = 1022,	duration = 300,	type = "externalDefensive",	},	-- Hand of Protection
		{ spellID = 114039,	duration = 30,	type = "externalDefensive",	spec = true	},	-- Hand of Purity
		{ spellID = 6940,	duration = 120,	type = "externalDefensive",	},	-- Hand of Sacrifice
		{ spellID = 633,	duration = 600,	type = "externalDefensive",	},	-- Lay on Hands
		{ spellID = 31821,	duration = 180,	type = "raidDefensive",	},	-- Devotion Aura
		{ spellID = 86669,	duration = 180,	type = "heal",	spec = {65}	},	-- Guardian of Ancient Kings (H)
		{ spellID = 31884,	duration = 180,	type = "offensive",	},	-- Avenging Wrath
		{ spellID = 31842,	duration = 180,	type = "offensive",	spec = {65}	},	-- Divine Favor
		{ spellID = 114157,	duration = 60,	type = "offensive",	spec = true	},	-- Execution Sentence
		{ spellID = 879,	duration = 15,	type = "offensive",	spec = {70}	},	-- Exorcism
		{ spellID = 86698,	duration = 180,	type = "offensive",	spec = {70}	},	-- Guardian of Ancient Kings (R)
		{ spellID = 105809,	duration = 120,	type = "offensive",	spec = true	},	-- Holy Avenger
		{ spellID = 114165,	duration = 20,	type = "offensive",	spec = true	},	-- Holy Prism
		{ spellID = 114158,	duration = 60,	type = "offensive",	spec = true	},	-- Light's Hammer
		{ spellID = 1044,	duration = 25,	type = "freedom",	},	-- Hand of Freedom
		{ spellID = 85499,	duration = 45,	type = "movement",	spec = true	},	-- Speed of Light
		{ spellID = 54428,	duration = 120,	type = "other",	spec = {65}	},	-- Divine Plea
		{ spellID = 1038,	duration = 120,	type = "other",	},	-- Hand of Salvation
		{ spellID = 62124,	duration = 8,	type = "taunt",	},	-- Hand of Reckoning
		-- symbiosis
		{ spellID = 113269,	duration = 600,	type = "other",	spec = true	},	-- Rebirth (Healer)
		{ spellID = 113075,	duration = 60,	type = "defensive",	spec = true	},	-- Barkskin (Tank)
		{ spellID = 122287,	duration = 0,	type = "offensive",	spec = true	},	-- Wrath (DPS)
	},
	-- race specific spells use spec = { race1,	race2... }	-- removed in WOTLKC
	["PRIEST"] = {
		{ spellID = 15487,	duration = 45,	type = "interrupt",	spec = {258}	},	-- Silence (PvE interrupt)
		{ spellID = 32375,	duration = 15,	type = "dispel",	},	-- Mass Dispel
		{ spellID = 527,	duration = 15,	type = "dispel",	spec = {256,257}	},	-- Purify
		{ spellID = 88625,	duration = 30,	type = "cc",	spec = {257}	},	-- Holy Word: Chastise (Chakra: Chastise 81209)
		{ spellID = 64044,	duration = 45,	type = "cc",	spec = {258}	},	-- Psychic Horror
		{ spellID = 108921,	duration = 45,	type = "cc",	spec = true	},	-- Psyfiend
		{ spellID = 8122,	duration = 30,	type = "aoeCC",	},	-- Psychic Scream
		{ spellID = 108920,	duration = 30,	type = "disarm",	spec = true	},	-- Void Tendrils
		{ spellID = 19236,	duration = 120,	type = "defensive",	spec = true	},	-- Desperate Prayer
		{ spellID = 47585,	duration = 120,	type = "defensive",	spec = {258}	},	-- Dispersion
		{ spellID = 109964,	duration = 60,	type = "defensive",	spec = {256}	},	-- Spirit Shell
		{ spellID = 108968,	duration = 300,	type = "defensive",	spec = {256,257}	},	-- Void Shift
		{ spellID = 142723,	duration = 600,	type = "defensive",	spec = {258}	},	-- Void Shift
		{ spellID = 47788,	duration = 180,	type = "externalDefensive",	spec = {257}	},	-- Guardian Spirit
		{ spellID = 33206,	duration = 180,	type = "externalDefensive",	spec = {256}	},	-- Pain Suppression
		{ spellID = 64843,	duration = 180,	type = "raidDefensive",	spec = {257}	},	-- Divine Hymn
		{ spellID = 126135,	duration = 180,	type = "raidDefensive",	spec = {257}	},	-- Lightwell
		{ spellID = 62618,	duration = 180,	type = "raidDefensive",	spec = {256}	},	-- Power Word: Barrier
		{ spellID = 15286,	duration = 180,	type = "raidDefensive",	spec = {258}	},	-- Vampiric Embrace
		{ spellID = 81700,	duration = 30,	type = "heal",	spec = {256}	},	-- Archangel
		{ spellID = 121135,	duration = 25,	type = "heal",	spec = true	},	-- Cascade
		{ spellID = 110744,	duration = 15,	type = "heal",	spec = true	},	-- Divine Star
		{ spellID = 120517,	duration = 40,	type = "heal",	spec = true	},	-- Halo
		{ spellID = 123040,	duration = 60,	type = "offensive",	spec = true 	},	-- Mindbender
		{ spellID = 10060,	duration = 120,	type = "offensive",	spec = true	},	-- Power Infusion
		{ spellID = 34433,	duration = 180,	type = "offensive",	talent = 123040	},	-- Shadowfiend
		{ spellID = 6346,	duration = 180,	type = "counterCC",	},	-- Fear Ward
		{ spellID = 89485,	duration = 45,	type = "counterCC",	spec = {256}	},	-- Inner Focus
		{ spellID = 32379,	duration = 8,	type = "counterCC",	spec = {256,257}	},	-- Shadow Word: Death
		{ spellID = 129176,	duration = 8,	type = "counterCC",	spec = {258}	},	-- Shadow Word: Death (Shadow)
		{ spellID = 121536,	duration = 10,	type = "movement",	spec = true,	charges = 3	},	-- Angelic Feather
		{ spellID = 73325,	duration = 90,	type = "movement",	},	-- Leap of Faith
		{ spellID = 586,	duration = 30,	type = "other",	},	-- Fade
		{ spellID = 64901,	duration = 360,	type = "other",	},	-- Hymn of Hope
		{ spellID = 112833,	duration = 30,	type = "other",	spec = true	},	-- Spectral Guise
		-- symbiosis
		{ spellID = 113506,	duration = 0,	type = "cc",	spec = true	},	-- Cyclone (Healer)
		{ spellID = 113277,	duration = 480,	type = "raidDefensive",	spec = true	},	-- Tranquility (DPS)
	},
	["ROGUE"] = {
		{ spellID = 1766,	duration = 15,	type = "interrupt",	},	-- Kick
		{ spellID = 2094,	duration = 120,	type = "cc",	},	-- Blind
		{ spellID = 1776,	duration = 10,	type = "cc",	},	-- Gouge
		{ spellID = 408,	duration = 20,	type = "cc",	},	-- Kidney Shot
		{ spellID = 76577,	duration = 180,	type = "cc",	},	-- Smoke Bomb
		{ spellID = 51722,	duration = 60,	type = "disarm",	},	-- Dismantle
		{ spellID = 31230,	duration = 90,	type = "defensive",	spec = true	},	-- Cheat Death
		{ spellID = 31224,	duration = 60,	type = "defensive",	},	-- Cloak of Shadows
		{ spellID = 74001,	duration = 120,	type = "defensive",	spec = true	},	-- Combat Readiness
		{ spellID = 5277,	duration = 120,	type = "defensive",	},	-- Evasion
		{ spellID = 14185,	duration = 300,	type = "defensive",	},	-- Preparation
		{ spellID = 1856,	duration = 120,	type = "defensive",	},	-- Vanish
		{ spellID = 13750,	duration = 180,	type = "offensive",	spec = {260}	},	-- Adrenaline Rush
		{ spellID = 51690,	duration = 120,	type = "offensive",	spec = {260}	},	-- Killing Spree
		{ spellID = 121471,	duration = 180,	type = "offensive",	},	-- Shadow Blades
		{ spellID = 51713,	duration = 60,	type = "offensive",	spec = {261}	},	-- Shadow Dance
		{ spellID = 79140,	duration = 120,	type = "offensive",	spec = {259}	},	-- Vendetta
		{ spellID = 36554,	duration = 20,	type = "movement",	spec = true	},	-- Shadowstep
		{ spellID = 2983,	duration = 60,	type = "movement",	},	-- Sprint
		{ spellID = 1725,	duration = 30,	type = "other",	},	-- Distract
		{ spellID = 137619,	duration = 60,	type = "other",	spec = true	},	-- Marked for Death
		{ spellID = 14183,	duration = 20,	type = "other",	spec = {261}	},	-- Premeditation
		{ spellID = 73981,	duration = 60,	type = "other",	},	-- Redirect
		{ spellID = 114842,	duration = 60,	type = "other",	},	-- Shadow Walk
		{ spellID = 114018,	duration = 300,	type = "other",	},	-- Shroud of concealment
		{ spellID = 1784,	duration = 6,	type = "other",		},	-- Stealth
		{ spellID = 57934,	duration = 30,	type = "other",	},	-- Tricks of the Trade
		-- symbiosis
		{ spellID = 113613,	duration = 180,	type = "defensive",	spec = true	},	-- Growl
	},
	["SHAMAN"] = {
		{ spellID = 57994,	duration = 12,	type = "interrupt",	},	-- Wind Shear
		{ spellID = 51886,	duration = 8,	type = "dispel",	spec = {262,263}	},	-- Cleanse Spirit
		{ spellID = 77130,	duration = 8,	type = "dispel",	spec = {264}	},	-- Purify Spirit
		{ spellID = 51514,	duration = 45,	type = "cc",	},	-- Hex
		{ spellID = 108269,	duration = 45,	type = "aoeCC",	},	-- Capacitor Totem
		{ spellID = 51490,	duration = 45,	type = "aoeCC",	spec = {262}	},	-- Thunderstorm
		{ spellID = 51485,	duration = 30,	type = "disarm",	spec = true	},	-- Earthgrab Totem
		{ spellID = 108271,	duration = 90,	type = "defensive",	spec = true	},	-- Astral Shift
		{ spellID = 108285,	duration = 180,	type = "defensive",	spec = true	},	-- Call of the Elements
		{ spellID = 2062,	duration = 300,	type = "defensive",	},	-- Earth Elemental Totem (aoe taunt)
		{ spellID = 30884,	duration = 30,	type = "defensive",	spec = 30884	},	-- Nature's Guardian (passive)
		{ spellID = 30823,	duration = 60,	type = "defensive",	spec = {262,263}	},	-- Shamanistic Rage
		{ spellID = 108270,	duration = 60,	type = "defensive",	spec = true	},	-- Stone Bulwark Totem
		{ spellID = 108281,	duration = 120,	type = "raidDefensive",	spec = true	},	-- Ancetral Guidance
		{ spellID = 108280,	duration = 180,	type = "raidDefensive",	},	-- Healing Tide Totem
		{ spellID = 98008,	duration = 180,	type = "raidDefensive",	spec = {264}	},	-- Spirit Link Totem
		{ spellID = 5394,	duration = 30,	type = "heal",	},	-- Healing Stream Totem
		{ spellID = 114049,	duration = 180,	type = "offensive",	},	-- Ascendance
		{ spellID = 2825,	duration = 300,	type = "offensive",	},	-- Bloodlust
--		{ spellID = 32182,	duration = 300,	type = "offensive",	},	-- Heroism	-- Merged
		{ spellID = 16166,	duration = 90,	type = "offensive",	spec = true	},	-- Elemental Mastery
		{ spellID = 51533,	duration = 120,	type = "offensive",	spec = true	},	-- Feral Spirit
		{ spellID = 2894,	duration = 300,	type = "offensive",	},	-- Fire Elemental Totem
		{ spellID = 120668,	duration = 300,	type = "offensive",	},	-- Stormlash Totem
		{ spellID = 8177,	duration = 25,	type = "counterCC",	},	-- Grounding Totem
		{ spellID = 8143,	duration = 60,	type = "counterCC",	},	-- Tremor Totem
		{ spellID = 58875,	duration = 60,	type = "freedom",	spec = {263}	},	-- Spirit Walk
		{ spellID = 108273,	duration = 60,	type = "raidMovement",	spec = true	},	-- Windwalk Totem
		{ spellID = 16188,	duration = 90,	type = "other",	spec = true	},	-- Ancetral Swiftness
		{ spellID = 2484,	duration = 30,	type = "other",	talent = 51485	},	-- Earthbind Totem
		{ spellID = 16190,	duration = 180,	type = "other",	spec = {264}	},	-- Mana Tide Totem
		{ spellID = 20608,	duration = 1800,	type = "other",	},	-- Reincarnation (passive)
		{ spellID = 79206,	duration = 120,	type = "other",	},	-- Spiritwalker's Grace
--		{ spellID = 108287,	duration = 10,	type = "other",	spec = true	},	-- Totemic Projection
		{ spellID = 73680,	duration = 15,	type = "other",	},	-- Unleash Elements
		-- symbiosis
		{ spellID = 113286,	duration = 60,	type = "interrupt",	spec = true	},	-- Solar Beam (DPS)
		{ spellID = 113289,	duration = 8,	type = "other",	spec = true	},	-- Prowl (Healer)
	},
	["WARLOCK"] = {
		{ spellID = 108482,	duration = 60,	type = "pvptrinket",	spec = true	},	-- Unbound Will
--		{ spellID = 119898,	duration = 24,	type = "interrupt",	},	-- Command Demon
		-- Use Felhunter spells as default, instead of Command Demon
		{ spellID = 108501,	duration = 120,	type = "interrupt",	spec = true	},	-- Grimoire of Service (dummy)
		{ spellID = 19647,	duration = 24,	type = "interrupt",	},	-- Spell Lock (Felhunter)
		{ spellID = 19505,	duration = 15,	type = "dispel",	},	-- Devour Magic (Felhunter)
		{ spellID = 6789,	duration = 45,	type = "cc",	spec = true	},	-- Mortal Coil
		{ spellID = 5484,	duration = 40,	type = "aoeCC",	},	-- Howl of Terror
		{ spellID = 30283,	duration = 30,	type = "aoeCC",	spec = true	},	-- Shadowfury
		{ spellID = 111397,	duration = 30,	type = "defensive",	spec = true	},	-- Blood Horror
		{ spellID = 110913,	duration = 180,	type = "defensive",	spec = true	},	-- Dark Bargain
		{ spellID = 108416,	duration = 60,	type = "defensive",	spec = true	},	-- Sacrificial Pact
		{ spellID = 6229,	duration = 30,	type = "defensive",	},	-- Twilight Ward
		{ spellID = 104773,	duration = 180,	type = "defensive",	talent = 148683	},	-- Unending Resolve
		{ spellID = 148683,	duration = 180,	type = "defensive",	spec = 148683,	-- Unending Resolve w/ Glyph of Eternal Resolve (dummy)
			disabledSpec={
				[265]={arena=false,pvp=false,party=true,raid=true,scenario=true,none=true},
				[266]={arena=false,pvp=false,party=true,raid=true,scenario=true,none=true},
				[267]={arena=false,pvp=false,party=true,raid=true,scenario=true,none=true},
			},
		},
		{ spellID = 108359,	duration = 120,	type = "heal",	spec = true	},	-- Dark Regeneration
		{ spellID = 113858,	duration = 120,	type = "offensive",	spec = {267}	},	-- Dark Soul: Instability
		{ spellID = 113861,	duration = 120,	type = "offensive",	spec = {266}	},	-- Dark Soul: Knowledge
		{ spellID = 113860,	duration = 120,	type = "offensive",	spec = {265}	},	-- Dark Soul: Misery
		{ spellID = 105174,	duration = 15,	type = "offensive",	spec = {266},	charges = 2	},	-- Hand of Gul'dan
		{ spellID = 104316,	duration = 120,	type = "offensive",	spec = 56242	},	-- Imp Swarm (by Glyph of Imp Swarm)
		{ spellID = 108508,	duration = 60,	type = "offensive",	spec = true	},	-- Mannoroth's Fury
		{ spellID = 18540,	duration = 600,	type = "offensive",	},	-- Summon Doomguard
		{ spellID = 1122,	duration = 600,	type = "offensive",	},	-- Summon Infernal
		{ spellID = 48020,	duration = 30,	type = "movement",	},	-- Demonic Circle: Teleport
		{ spellID = 47897,	duration = 20,	type = "other",	spec = true	},	-- Demonic Breath
		{ spellID = 109151,	duration = 10,	type = "other",	spec = {266}	},	-- Demonic Leap
		{ spellID = 120451,	duration = 60,	type = "other",	spec = {267}	},	-- Flame of Xoroth
		{ spellID = 108503,	duration = 30,	type = "other",	spec = true	},	-- Grimoire of Sacrifice
		{ spellID = 80240,	duration = 25,	type = "other",	spec = {267}	},	-- Havoc
		{ spellID = 29858,	duration = 120,	type = "other",	},	-- Soulshatter
		{ spellID = 20707,	duration = 600,	type = "other",	buff = 0	},	-- Soulstone
		-- symbiosis
		{ spellID = 113295,	duration = 10,	type = "heal",	spec = true	},	-- Rejuvenation
	},
	["WARRIOR"] = {
		{ spellID = 102060,	duration = 40,	type = "interrupt",	spec = true	},	-- Disrupting Shout
		{ spellID = 6552,	duration = 15,	type = "interrupt",	},	-- Pummel
		{ spellID = 5246,	duration = 90,	type = "cc",	},	-- Intimidating Shout
		{ spellID = 46968,	duration = 40,	type = "cc",	spec = true	},	-- Shockwave
		{ spellID = 107570,	duration = 30,	type = "cc",	spec = true	},	-- Storm Bolt
		{ spellID = 118000,	duration = 60,	type = "aoeCC",	spec = true	},	-- Dragon Roar
		{ spellID = 676,	duration = 60,	type = "disarm",	},	-- Disarm
		{ spellID = 57755,	duration = 30,	type = "disarm",	spec = 58357,	-- Heroic throw (Glyph of Gag Order - pve only)
			disabledSpec={
				[71]={arena=true,pvp=true,party=false,raid=false,scenario=false,none=false},
				[72]={arena=true,pvp=true,party=false,raid=false,scenario=false,none=false},
				[73]={arena=true,pvp=true,party=false,raid=false,scenario=false,none=false},
			},
		},
		{ spellID = 107566,	duration = 40,	type = "disarm",	spec = true	},	-- Staggering Shout
		{ spellID = 114203,	duration = 180,	type = "defensive",	},	-- Demoralizing Banner
		{ spellID = 118038,	duration = 120,	type = "defensive",	spec = {71,72}	},	-- Die by the Sword
		{ spellID = 12975,	duration = 180,	type = "defensive",	spec = {73}	},	-- Last Stand
		{ spellID = 2565,	duration = 9,	type = "defensive",	spec = {73},	charges = 2	},	-- Shield Block
		{ spellID = 871,	duration = 180,	type = "defensive",	},	-- Shield Wall
		{ spellID = 114030,	duration = 120,	type = "externalDefensive",	spec = true	},	-- Vigilance
		{ spellID = 97462,	duration = 180,	type = "raidDefensive",	buff = 97463	},	-- Rallying Cry
		{ spellID = 55694,	duration = 60,	type = "heal",	spec = true	},	-- Frenzied Regeneration
		{ spellID = 103840,	duration = 30,	type = "heal",	spec = true	},	-- Impending Victory
		{ spellID = 107574,	duration = 180,	type = "offensive",	spec = true	},	-- Avatar
		{ spellID = 46924,	duration = 60,	type = "offensive",	spec = true	},	-- Bladestorm
		{ spellID = 12292,	duration = 60,	type = "offensive",	spec = true	},	-- Bloodbath
		{ spellID = 86346,	duration = 20,	type = "offensive",	spec = {71,72}	},	-- Colossus Smash
		{ spellID = 1719,	duration = 180,	type = "offensive",	},	-- Recklessness
		{ spellID = 114207,	duration = 180,	type = "offensive",	buff = 114206	},	-- Skull Banner
--		{ spellID = 12328,	duration = 10,	type = "offensive",	spec = {71}	},	-- Sweeping Strikes
		{ spellID = 18499,	duration = 30,	type = "counterCC",	},	-- Berserker Rage
		{ spellID = 3411,	duration = 30,	type = "counterCC",	talent = 114029	},	-- Intervene
		{ spellID = 114028,	duration = 60,	type = "counterCC",	spec = true	},	-- Mass Spell Reflection
		{ spellID = 114029,	duration = 30,	type = "counterCC",	spec = true	},	-- Safeguard
		{ spellID = 23920,	duration = 25,	type = "counterCC",	},	-- Spell Reflection
		{ spellID = 1250619,	duration = 20,	type = "movement",	},	-- Charge (A/F) - P id 100
		{ spellID = 6544,	duration = 45,	type = "movement",	},	-- Heroic Leap
		{ spellID = 114192,	duration = 180,	type = "other",	},	-- Mocking Banner
		{ spellID = 64382,	duration = 300,	type = "other",	},	-- Shattering Throw
		{ spellID = 355,	duration = 8,	type = "taunt",		},	-- Taunt
		-- symbiosis
		{ spellID = 122294,	duration = 300,	type = "raidMovement",	spec = true	},	-- Stampeding Shout (DPS)
		{ spellID = 122286,	duration = 60,	type = "defensive",	spec = true	},	-- Savage Defense (Tank)
	},
	["PVPTRINKET"] = { -- merged to Classic itemId's
		{ spellID = 42292,	duration = 120,	type = "pvptrinket",	item = 37864	},	-- -- PvP Trinket (Medallion of the Alliance)
		{ spellID = 126697,	duration = 120,	type = "trinket",	item = 64740,	icon = 132344	},	-- Tremendous Fortitude (Malevolent Gladiator's Emblem of Curelty)
		{ spellID = 126690,	duration = 60,	type = "trinket",	item = 64687,	icon = 135884	},	-- Call of Conquest (Malevolent Gladiator's Badge of Conquest)
	},
	["RACIAL"] = {
		{ spellID = 28730,	duration = 120,	type = "racial",	race = 10	},	-- Arcane Torrent (Paladin, Priest, Mage, Warlock)
		{ spellID = 26297,	duration = 180,	type = "racial",	race = 8	},	-- Berserking
		{ spellID = 20572,	duration = 120,	type = "racial",	race = 2	},	-- Blood Fury (Warrior, Hunter, Rogue, DK)
		{ spellID = 68992,	duration = 120,	type = "racial",	race = 22	},	-- Darkflight
		{ spellID = 20589,	duration = 90,	type = "racial",	race = 7	},	-- Escape Artist
		{ spellID = 28880,	duration = 180,	type = "racial",	race = 11	},	-- Gift of the Naaru (Warrior)
		{ spellID = 69070,	duration = 120,	type = "racial",	race = 9	},	-- Rocket Jump
		{ spellID = 107079,	duration = 120,	type = "racial",	race = {25,26}	},	-- Quaking Palm
		{ spellID = 58984,	duration = 120,	type = "racial",	race = 4	},	-- Shadowmeld
		{ spellID = 20594,	duration = 120,	type = "racial",	race = 3	},	-- Stoneform
		{ spellID = 20549,	duration = 120,	type = "racial",	race = 6	},	-- War Stomp
		{ spellID = 7744,	duration = 120,	type = "racial",	race = 5	},	-- Will of the Forsaken
		{ spellID = 59752,	duration = 120,	type = "racial",	race = 1	},	-- Will to Survive
	},
	["TRINKET"] = {
		{ spellID = 113942,	duration = 60,	type = "consumable",	item = 0,	icon = 607512	},	-- Demonic Gateway (CD self adjusting CLEU)
		{ spellID = 6262,	duration = 120,	type = "consumable",	item = 5512	},	-- Healthstone
		{ spellID = 105708,	duration = 60,	type = "consumable",	item = nil,	icon = 609894	},	-- Master Healing Potion
		{ spellID = 105709,	duration = 60,	type = "consumable",	item = nil,	icon = 650641	},	-- Master Mana Potion
		{ spellID = 105701,	duration = 60,	type = "consumable",	item = nil,	icon = 609893	},	-- Potion of Focus
		{ spellID = 105702,	duration = 60,	type = "consumable",	item = nil,	icon = 609895	},	-- Potion of the Jade Serpent
		{ spellID = 105706,	duration = 60,	type = "consumable",	item = nil,	icon = 609896	},	-- Potion of Mogu Power
		{ spellID = 105697,	duration = 60,	type = "consumable",	item = nil,	icon = 609897	},	-- Virement's Bite
		{ spellID = 11392,	duration = 600,	type = "consumable",	item = nil,	icon = 650637	},	-- Venerable Potion of Invisibility

	},
}

E.buffFix = E.BLANK

E.buffFixNoCLEU = {
	[125174]	= 10, -- Touch of Karma (immunity)
}

E.summonedBuffDuration = E.BLANK

E.spellDefaults = {
	42292,	-- PvP Trinket
	59752,	-- Will to Survive
	20589,	-- Escape Artist
	58984,	-- Shadowmeld
	20594,	-- Stoneform
	20549,	-- War Stomp
	7744,	-- Will of the Forsaken
	-- DK
	47528,	-- Mind Freeze
	108194,	-- Asphyxiate
	108200,	-- Remorseless Winter
	47476,	-- Strangulate
	49576,	-- Death Grip
	108199,	-- Gorefiend's Grasp
	48707,	-- Anti-Magic Shell
	48792,	-- Icebound Foritude
	114556,	-- Purgatory
	51052,	-- Anti-Magic Zone
	48743,	-- Death Pact
	42650,	-- Army of the Dead
	49028,	-- Dancing Rune Weapon
	47568,	-- Empower Rune Weapon
	49206,	-- Summon Gargoyle
	49016,	-- Unholy Frenzy
	51271,	-- Pillar of Frost
	108201,	-- Desecreated Ground
	49039,	-- Lichborne
		113072,	-- Might of Ursoc
--		113516,	-- Wild Mushroom: Plague
	-- Druid
	80964,	-- Skull Bash
	78675,	-- Solar Beam
	88423,	-- Nature's Cure
	2782,	-- Remove Corruption
	99,	-- Disorienting Roar
	5211,	-- Mighty Bash
	132469,	-- Typhoon
	102342,	-- Ironbark
	22812,	-- Barkskin
	106922,	-- Might of Ursoc
	108238,	-- Renewal
	61336,	-- Survival Instincts
	124974,	-- Nature's Vigil
	740,	-- Tranquility
	50334,	-- Berserk (G)
	106951,	-- Berserk (F)
	112071,	-- Celestial Alignment
	102558,	-- Incarnation
	132158,	-- Nature's Swiftness
	29166,	-- Innervate
		110570,	-- Anti-Magic Shell
		110575,	-- Icebound Fortitude
		110617,	-- Deterrence
		110696,	-- Ice Block
		126458,	-- Grapple Weapon
		126449,	-- Clash
		126456,	-- Fortifying Brew
		110698,	-- Hammer of Justice
		110700,	-- Divine Shield
		122288,	-- Cleanse
		110707,	-- Mass Dispel
		110715,	-- Dispersion
		110718,	-- Leap of Faith
		110788,	-- Cloak of Shadows
		110791,	-- Evasion
		122291,	-- Unending Resolve
		112970,	-- Demonic Circle: Teleport
		113004,	-- Intimidating Roar
	-- Hunter
	147362,	-- Counter Shot
	34490,	-- Silencing Shot
	109248,	-- Binding Shot
	1499,	-- Freezing Trap
	19577,	-- Intimidation
	19503,	-- Scatter Shot
	19386,	-- Wyvern Sting
	19263,	-- Deterrence
	53480,	-- Roar of Sacrifice (Cunning Pet)
	51753,	-- Camouflage
	109304,	-- Exhilaration
	19574,	-- Bestial Wrath
	131894,	-- A Murder of Crows
	121818,	-- Stampede
	3045,	-- Rapid Fire
	53271,	-- Master's Call
--		113073,	-- Dash
	-- Mage
	2139,	-- Counterspell
	475,	-- Remove Curse
	44572,	-- Deep Freeze
	31661,	-- Dragon's Breath
	113724,	-- Ring of Frost
	45438,	-- Ice Block
	108978,	-- Alter Time
	11958,	-- Cold Snap
	86949,	-- Cauterize
	110959,	-- Greater Invisibility
	115610,	-- Temporal Shield
	12042,	-- Arcane Power
	11129,	-- Combustion
	12472,	-- Icy Veins
	55342,	-- Mirror Image
	12043,	-- Presence of Mind
	-- Monk
	137562,	-- Nimble Brew
	116705,	-- Spear Hand Strike
	115450,	-- Detox
	119381,	-- Leg Sweep
	116844,	-- Ring of Peace
	115078,	-- Paralysis
	117368,	-- Grapple Weapon
	115213,	-- Avert Harm
	116849,	-- Life Cocoon
	122278,	-- Dampen Harm
	122783,	-- Diffuse Magic
	115203,	-- Fortifying Brew
	122470,	-- Touch of Karma
	115176,	-- Zen Meditation
	115310,	-- Revival
	123995,	-- Invoke Xuen, the White Tiger
	119996,	-- Transcendence: Transfer
	116841,	-- Tiger's Lust
		113306,	-- Survival Instinct (Tank)
		127361,	-- Bear Hug (DPS)	-- Paladin
	96231,	-- Rebuke
	4987,	-- Cleanse
	115750,	-- Blinding Light
	853,	-- Hammer of Justice
	105593,	-- Fist of Justice
	20066,	-- Repentance
	642,	-- Divine Shield
	1022,	-- Hand of Protection
	114039,	-- Hand of Purity
	6940,	-- Hand of Sacrifice
	633,	-- Lay on Hands
	31850,	-- Ardent Defender
	498,	-- Divine Protection
	86659,	-- Guardian of Ancient Kings (P)
	31821,	-- Aura Mastery
	86669,	-- Guardian of Ancient Kings (H)
	31884,	-- Avenging Wrath
	31842,	-- Divine Favor
	114157,	-- Execution Sentence
	86698,	-- Guardian of Ancient Kings (R)
	1044,	-- Hand of Freedom
--		113269,	-- Rebirth (Healer)
		113075,	-- Barkskin (Tank)
	-- Priest
	527,	-- Purify
	32375,	-- Mass Dispel
	88625,	-- Holy Word: Chastise
	64044,	-- Psychic Horror
	8122,	-- Psychic Scream
	108921,	-- Psyfiend
	15487,	-- Silence
	47788,	-- Guardian Spirit
	33206,	-- Pain Suppression
	19236,	-- Desperate Prayer
	47585,	-- Dispersion
	108968,	-- Void Shift (D/H)
	142723,	-- Void Shift (S)
	64843,	-- Divine Hymn
	126135,	-- Lightwell
	62618,	-- Power Word: Barrier
	15286,	-- Vampiric Embrace
	10060,	-- Power Infusion
	34433,	-- Shadowfiend
	6346,	-- Fear Ward
	89485,	-- Inner Focus
	32379,	-- Shadow Word: Death
	129176,	-- Shadow Word: Death (S)
	64901,	-- Hymn of Hope
	73325,	-- Leap of Faith
		113277,	-- Tranquility (DPS)
	-- Rogue
	1766,	-- Kick
	2094,	-- Blind
	408,	-- Kidney Shot
	76577,	-- Smoke Bomb
	51722,	-- Dismantle
	31230,	-- Cheat Death
	31224,	-- Cloak of Shadows
	74001,	-- Combat Readiness
	5277,	-- Evasion
	14185,	-- Preparation
	1856,	-- Vanish
	13750,	-- Adrenaline Rush
	51690,	-- Killing Spree
	121471,	-- Shadow Blades
	51713,	-- Shadow Dance
	79140,	-- Vendetta
	-- Shaman
	57994,	-- Wind Shear
	77130,	-- Purify Spirit
	51886,	-- Cleanse Spirit
	108269,	-- Capacitor Totem
	51514,	-- Hex
	51490,	-- Thunderstorm
	108271,	-- Astral Shift
	108285,	-- Call of the Elements
	2062,	-- Earth Elemental Totem
	30884,	-- Nature's Guardian
	30823,	-- Shamanistic Rage
	108270,	-- Stone Bulwark Totem
	108281,	-- Ancetral Guidance
	108280,	-- Healing Tide Totem
	98008,	-- Spirit Link Totem
	114049,	-- Ascendance
	16166,	-- Elemental Mastery
	51533,	-- Feral Spirit
	2894,	-- Fire Elemental Totem
	120668,	-- Stormlash Totem
	8177,	-- Grounding Totem
	8143,	-- Tremor Totem
	16190,	-- Mana Tide Totem
	16188,	-- Ancetral's Swiftness
	58875,	-- Spirit Walk
		113286,	-- Solar Beam (DPS)
	-- Warlock
	108482,	-- Unbound Will
	19647,	-- Spell Lock (Felhunter)
	108501,	-- Grimoire of Service (dummy)
	19505,	-- Devour Magic (Felhunter)
	6789,	-- Mortal Coil
	5484,	-- Howl of Terror
	30283,	-- Shadowfury
	110913,	-- Dark Bargain
	108359,	-- Dark Regeneration
	108416,	-- Sacrificial Pact
	104773,	-- Unending Resolve
	113860,	-- Dark Soul: Misery
	113861,	-- Dark Soul: Knowledge
	113858,	-- Dark Soul: Instability
	18540,	-- Summon Doomguard
	1122,	-- Summon Infernal
	48020,	-- Demonic Circle: Teleport
	-- Warrior
	6552,	-- Pummel
	102060,	-- Disrupting Shout
	5246,	-- Intimidating Shout
	46968,	-- Shockwave
	107570,	-- Storm Bolt
	676,	-- Disarm
	118000,	-- Dragon Roar
	57755,	-- Heroic Throw (Glyph of Gag Order - pve only)
	114030,	-- Vigilance
	114203,	-- Demoralizing Banner
	118038,	-- Die by the Sword
	55694,	-- Frenzied Regeneration
	12975,	-- Last Stand
	871,	-- Shield Wall
	97462,	-- Rallying Cry
	107574,	-- Avatar
	86346,	-- Colossus Smash
	1719,	-- Recklessness
	114207,	-- Skull Banner
	18499,	-- Berserker Rage
	3411,	-- Intervene
	114029,	-- Safeguard
	114028,	-- Mass Spell Reflection
	23920,	-- Spell Reflection
	64382,	-- Shattering Throw
--		122294,	-- Stampeding Shout (DPS)
		122286,	-- Savage Defense (Tank)
}
