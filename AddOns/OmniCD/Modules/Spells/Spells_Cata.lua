local E = select(2, ...):unpack()

E.spell_db = {
	["DEATHKNIGHT"] = {
		{ spellID = 47528, duration = 10, type = "interrupt", rlvl = 57 }, -- Mind Freeze
		{ spellID = 49203, duration = 60, type = "cc", spec = true }, -- Hungering Cold
		{ spellID = 47476, duration = 120, type = "disarm", rlvl = 59 }, -- Strangulate
		{ spellID = 49576, duration = 35, type = "disarm", rlvl = 55 }, -- Death Grip
		{ spellID = 48707, duration = 45, type = "defensive", rlvl = 68 }, -- Anti-Magic Shell
		{ spellID = 49222, duration = 60, type = "defensive", spec = true }, -- Bone Shield
		{ spellID = 49028, duration = 90, type = "defensive", spec = true }, -- Dancing Rune Weapon
		{ spellID = 48743, duration = 120, type = "defensive", rlvl = 66 }, -- Death Pact
		{ spellID = 48792, duration = 180, type = "defensive", rlvl = 62 }, -- Icebound Fortitude
		{ spellID = 48982, duration = 30, type = "defensive", spec = true }, -- Rune Tap
		{ spellID = 55233, duration = 60, type = "defensive", spec = true }, -- Vampiric Blood
		{ spellID = 51052, duration = 120, type = "raidDefensive", spec = true }, -- Anti-Magic Zone
		{ spellID = 42650, duration = 600, type = "offensive", rlvl = 80 }, -- Army of the Dead
--		{ spellID = 63560, duration = 0, type = "offensive", spec = true }, -- Dark Transformation
		{ spellID = 43265, duration = 30, type = "offensive", rlvl = 60 }, -- Death and Decay
		{ spellID = 47568, duration = 300, type = "offensive", rlvl = 75 }, -- Empower Rune Weapon
		{ spellID = 57330, duration = 20, type = "offensive", rlvl = 65 }, -- Horn of Winter
--		{ spellID = 49184, duration = 0, type = "offensive", spec = true }, -- Howling Blast
		{ spellID = 77575, duration = 60, type = "offensive", rlvl = 81 }, -- Outbreak
		{ spellID = 51271, duration = 60, type = "offensive", spec = true }, -- Pillar of Frost
		{ spellID = 61999, duration = 600, type = "offensive", rlvl = 72 }, -- Raise Ally
		{ spellID = 46584, duration = 180, type = "offensive", rlvl = 56 }, -- Raise Dead
		{ spellID = 49016, duration = 180, type = "offensive", spec = true }, -- Unholy Frenzy
		{ spellID = 49206, duration = 180, type = "offensive", spec = true }, -- Summon Gargoyle
		{ spellID = 49039, duration = 120, type = "counterCC", spec = true }, -- Lichborne
		{ spellID = 45529, duration = 60, type = "other", rlvl = 64 }, -- Blood Tap
		{ spellID = 56222, duration = 8, type = "other", rlvl = 65 }, -- Dark Command (taunt)
		{ spellID = 77606, duration = 60, type = "other", rlvl = 85 }, -- Dark Simulacrum
	},
	["DRUID"] = {
		{ spellID = 80964, duration = 60, type = "interrupt", rlvl = 22 }, -- Skull Bash (Bear Form)
		{ spellID = 78675, duration = 60, type = "interrupt", spec = true }, -- Solar Beam
		{ spellID = 5211, duration = 60, type = "cc", rlvl = 32 }, -- Bash
		{ spellID = 22570, duration = 10, type = "cc", rlvl = 62 }, -- Maim
		{ spellID = 16979, duration = 15, type = "disarm", spec = 49377 }, -- Feral Charge (Bear Form - root)
		{ spellID = 49376, duration = 30, type = "disarm", spec = 49377 }, -- Feral Charge (Cat Form - daze = snare)
		{ spellID = 50516, duration = 20, type = "disarm", spec = true }, -- Typhoon
		{ spellID = 22812, duration = 60, type = "defensive", rlvl = 58 }, -- Barkskin
		{ spellID = 22842, duration = 180, type = "defensive", rlvl = 52 }, -- Frenzied Regeneration
		{ spellID = 16689, duration = 60, type = "defensive", rlvl = 52 }, -- Nature's Grasp
		{ spellID = 61336, duration = 180, type = "defensive", spec = true }, -- Survival Instincts
		{ spellID = 18562, duration = 15, type = "defensive", spec = 3 }, -- Swiftmend
		{ spellID = 467, duration = 45, type = "defensive", rlvl = 5 }, -- Thorns
		{ spellID = 33891, duration = 180, type = "defensive", spec = true }, -- Tree of Life
--		{ spellID = 48438, duration = 8, type = "defensive", spec = true }, -- Wild Growth
		{ spellID = 740, duration = 480, type = "raidDefensive", rlvl = 68 }, -- Tranquility
		{ spellID = 50334, duration = 180, type = "offensive", spec = true }, -- Berserk
		{ spellID = 33831, duration = 180, type = "offensive", spec = true }, -- Force of Nature
--		{ spellID = 33878, duration = 6, type = "offensive", spec = 2 }, -- Mangle (Bear), 33876 Mangle (Cat) - no cd
		{ spellID = 48505, duration = 90, type = "offensive", spec = true }, -- Starfall
		{ spellID = 78674, duration = 15, type = "offensive", spec = 1 }, -- Starsurge
		{ spellID = 5217, duration = 30, type = "offensive", rlvl = 24 }, -- Tiger's Fury
		{ spellID = 5209, duration = 180, type = "other", rlvl = 28 }, -- Challenging Roar (aoe taunt)
		{ spellID = 1850, duration = 180, type = "other", rlvl = 26 }, -- Dash
		{ spellID = 5229, duration = 60, type = "other", rlvl = 22 }, -- Enrage
--		{ spellID = 16857, duration = 6, type = "other", rlvl = 24 }, -- Faerie Fire (Feral)
		{ spellID = 6795, duration = 8, type = "other", rlvl = 15 }, -- Growl (taunt)
		{ spellID = 29166, duration = 180, type = "other", rlvl = 28 }, -- Innervate
		{ spellID = 17116, duration = 180, type = "other", spec = true }, -- Nature's Swiftness
		{ spellID = 5215, duration = 10, type = "other", rlvl = 10 }, -- Prowl
		{ spellID = 20484, duration = 600, type = "other", rlvl = 20 }, -- Rebirth
		{ spellID = 77761, duration = 120, type = "other", rlvl = 83 }, -- Stampeding roar (Bear Form)
	},
	["HUNTER"] = {
		{ spellID = 26090, duration = 30, type = "interrupt", rlvl = 1 }, -- Pummel (Pet ability used ad Command Pet)
--		{ spellID = 19801, duration = 0, type = "dispel", rlvl = 35 }, -- Tranquilizing Shot
		{ spellID = 1499, duration = 30, type = "cc", rlvl = 28 }, -- Freezing Trap
		{ spellID = 19577, duration = 60, type = "cc", spec = 1 }, -- Intimidation
--		{ spellID = 1513, duration = 0, type = "cc", rlvl = 36 }, -- Scare Beast
		{ spellID = 19503, duration = 30, type = "cc", spec = true }, -- Scatter Shot
		{ spellID = 19386, duration = 60, type = "cc", spec = true }, -- Wyvern Sting
		{ spellID = 34490, duration = 20, type = "disarm", spec = true }, -- Silencing Shot
		{ spellID = 19263, duration = 120, type = "defensive", rlvl = 78 }, -- Deterrence
		{ spellID = 5384, duration = 30, type = "defensive", rlvl = 32 }, -- Feign Death
		{ spellID = 23989, duration = 180, type = "defensive", spec = true }, -- Readiness
--		{ spellID = 19434, duration = 0, type = "offensive", spec = 2 }, -- Aimed Shot
		{ spellID = 19574, duration = 120, type = "offensive", spec = true }, -- Bestial Wrath
		{ spellID = 3674, duration = 30, type = "offensive", spec = true }, -- Black Arrow
--		{ spellID = 53209, duration = 10, type = "offensive", spec = true }, -- Chimera Shot
--		{ spellID = 19306, duration = 5, type = "offensive", spec = true }, -- Counterattack (active after parrying)
--		{ spellID = 53301, duration = 6, type = "offensive", spec = 3 }, -- Explosive Shot (Rank 1)
		{ spellID = 13813, duration = 30, type = "offensive", rlvl = 38 }, -- Explosive Trap
--		{ spellID = 82692, duration = 15, type = "offensive", spec = true }, -- Focus Fire
		{ spellID = 13795, duration = 30, type = "offensive", rlvl = 22 }, -- Immolation Trap
--		{ spellID = 34026, duration = 6, type = "offensive", rlvl = 10 }, -- Kill Command
--		{ spellID = 53351, duration = 10, type = "offensive", rlvl = 35 }, -- Kill Shot
--		{ spellID = 2643, duration = 0, type = "offensive", rlvl = 24 }, -- Multi-Shot
		{ spellID = 3045, duration = 300, type = "offensive", rlvl = 54 }, -- Rapid Fire
--		{ spellID = 2973, duration = 6, type = "offensive", rlvl = 6 }, -- Raptor Strike
		{ spellID = 34600, duration = 30, type = "offensive", rlvl = 66 }, -- Snake Trap
		{ spellID = 51753, duration = 60, type = "other", rlvl = 85 }, -- Camouflage
--		{ spellID = 5116, duration = 6, type = "other", rlvl = 8 }, -- Concussive Shot
		{ spellID = 781, duration = 25, type = "other", rlvl = 14 }, -- Disengage
--		{ spellID = 20736, duration = 8, type = "other", rlvl = 52 }, -- Distracting Shot
--		{ spellID = 6991, duration = 10, type = "other", rlvl = 10 }, -- Feed Pet
		{ spellID = 1543, duration = 20, type = "other", rlvl = 38 }, -- Flare
		{ spellID = 82726, duration = 120, type = "other", spec = true }, -- Fervor
		{ spellID = 13809, duration = 30, type = "other", rlvl = 46 }, -- Ice Trap
		{ spellID = 53271, duration = 45, type = "other", rlvl = 74 }, -- Master's Call
		{ spellID = 34477, duration = 30, type = "other", rlvl = 76 }, -- Misdirection
		-- Pet talent tree
		{ spellID = 53480, duration = 60, type = "other", rlvl = 1 }, -- Roar of Sacrifice
	},
	["MAGE"] = {
		{ spellID = 2139, duration = 24, type = "interrupt", rlvl = 9 }, -- Counterspell
		{ spellID = 44572, duration = 30, type = "cc", spec = true }, -- Deep Freeze
		{ spellID = 31661, duration = 20, type = "cc", spec = true }, -- Dragon's Breath
		{ spellID = 82676, duration = 120, type = "cc", rlvl = 83 }, -- Ring of Frost
		{ spellID = 11113, duration = 15, type = "disarm", spec = true }, -- Blast Wave
		{ spellID = 122, duration = 25, type = "disarm", rlvl = 8 }, -- Frost Nova
		{ spellID = 33395, duration = 25, type = "disarm", rlvl = 10, spec = 3 }, -- Freeze (Water Elemental spell)
		{ spellID = 45438, duration = 300, type = "immunity", rlvl = 30 }, -- Ice Block
		{ spellID = 86948, duration = 60, type = "defensive", spec = {86948,86949} }, -- Cauterize (Rank 1)
		{ spellID = 11958, duration = 480, type = "defensive", spec = true }, -- Cold Snap
		{ spellID = 543, duration = 30, type = "defensive", rlvl = 36 }, -- Mage Ward
		{ spellID = 11426, duration = 30, type = "defensive", spec = true }, -- Ice Barrier
		{ spellID = 66, duration = 180, type = "defensive", rlvl = 78 }, -- Invisibility
--		{ spellID = 44425, duration = 4, type = "offensive", spec = 1 }, -- Arcane Barrage
		{ spellID = 12042, duration = 120, type = "offensive", spec = true }, -- Arcane Power
		{ spellID = 11129, duration = 120, type = "offensive", spec = true }, -- Combustion (no buff, 83853 debuff on target)
--		{ spellID = 2136, duration = 8, type = "offensive", rlvl = 5 }, -- Fire Blast
		{ spellID = 82731, duration = 60, type = "offensive", rlvl = 81 }, -- Flame Orb
		{ spellID = 12472, duration = 180, type = "offensive", spec = true }, -- Icy Veins
		{ spellID = 55342, duration = 180, type = "offensive", rlvl = 50 }, -- Mirror Image
		{ spellID = 12043, duration = 120, type = "offensive", spec = true }, -- Presence of Mind
		{ spellID = 31687, duration = 180, type = "offensive", spec = 3 }, -- Summon Water Elemental
		{ spellID = 80353, duration = 300, type = "offensive", rlvl = 85 }, -- Time Warp
		{ spellID = 1953, duration = 15, type = "other", rlvl = 16 }, -- Blink
--		{ spellID = 120, duration = 10, type = "other", rlvl = 18 }, -- Cone of Cold
		{ spellID = 12051, duration = 240, type = "other", rlvl = 12 }, -- Evocation
--		{ spellID = 43987, duration = 300, type = "other", rlvl = 76 }, -- Ritual of Refreshment (Rank 1) -- TODO: make preactive til the ritual is completed
	},
	["PALADIN"] = {
		{ spellID = 96231, duration = 10, type = "interrupt", rlvl = 54 }, -- Rebuke
		{ spellID = 853, duration = 60, type = "cc", rlvl = 14 }, -- Hammer of Justice
		{ spellID = 2812, duration = 15, type = "cc", rlvl = 28 }, -- Holy Wrath
		{ spellID = 20066, duration = 60, type = "cc", spec = true }, -- Repentance
		{ spellID = 10326, duration = 8, type = "cc", spec = 54931 }, -- Turn Evil (Glyph of Turn Evil as talent - no cd w/o it)
		{ spellID = 31935, duration = 15, type = "disarm", spec = 2 }, -- Avenger's Shield
		{ spellID = 642, duration = 300, type = "immunity", rlvl = 48 }, -- Divine Shield
		{ spellID = 1022, duration = 300, type = "externalDefensive", rlvl = 18 }, -- Hand of Protection
		{ spellID = 6940, duration = 120, type = "externalDefensive", rlvl = 80 }, -- Hand of Sacrifice
		{ spellID = 64205, duration = 120, type = "externalDefensive", spec = true }, -- Divine Sacrifice
		{ spellID = 633, duration = 600, type = "externalDefensive", rlvl = 16 }, -- Lay on Hands
		{ spellID = 31850, duration = 180, type = "defensive", spec = true }, -- Ardent Defender
		{ spellID = 70940, duration = 180, type = "defensive", spec = true }, -- Divine Guardian
		{ spellID = 498, duration = 60, type = "defensive", rlvl = 30 }, -- Divine Protection
		{ spellID = 86150, duration = 300, type = "defensive", rlvl = 85 }, -- Guardian of Ancient Kings
		{ spellID = 20925, duration = 30, type = "defensive", spec = true }, -- Holy Shield
		{ spellID = 31821, duration = 120, type = "raidDefensive", spec = true }, -- Aura Mastery
		{ spellID = 31884, duration = 180, type = "offensive", rlvl = 72 }, -- Avenging Wrath
		{ spellID = 26573, duration = 30, type = "offensive", rlvl = 24 }, -- Consecration
--		{ spellID = 35395, duration = 4.5, type = "offensive", rlvl = 1 }, -- Crusader Strike
		{ spellID = 31842, duration = 180, type = "offensive", spec = true }, -- Divine Favor
--		{ spellID = 53385, duration = 4.5, type = "offensive", spec = true }, -- Divine Storm
--		{ spellID = 53595, duration = 4.5, type = "offensive", spec = true }, -- Hammer of the Righteous
--		{ spellID = 879, duration = 0, type = "offensive", rlvl = 18 }, -- Exorcism
--		{ spellID = 24275, duration = 6, type = "offensive", rlvl = 46 }, -- Hammer of Wrath
--		{ spellID = 20473, duration = 6, type = "offensive", spec = 1 }, -- Holy Shock
--		{ spellID = 20271, duration = 8, type = "offensive", rlvl = 3 }, -- Judgement
		{ spellID = 85673, duration = 20, type = "offensive", rlvl = 9 }, -- Word of Glory
		{ spellID = 85696, duration = 120, type = "offensive", spec = true }, -- Zealotry
		{ spellID = 54428, duration = 120, type = "other", rlvl = 44 }, -- Divine Plea
		{ spellID = 1044, duration = 25, type = "other", rlvl = 52 }, -- Hand of Freedom
		{ spellID = 62124, duration = 8, type = "other", rlvl = 14 }, -- Hand of Reckoning (taunt)
		{ spellID = 1038, duration = 120, type = "other", rlvl = 66 }, -- Hand of Salvation
--		{ spellID = 31789, duration = 8, type = "other", rlvl = 36 }, -- Righteous Defense (taunts 3)
	},
	-- race specific spells use spec = { race1, race2... }	-- removed in WOTLKC
	["PRIEST"] = {
		{ spellID = 64044, duration = 120, type = "cc", spec = true }, -- Psychic Horror
		{ spellID = 8122, duration = 30, type = "cc", rlvl = 12 }, -- Psychic Scream
		{ spellID = 88625, duration = 30, type = "cc", spec = 2 }, -- Holy Word: Chastise
		{ spellID = 15487, duration = 45, type = "disarm", spec = true }, -- Silence
		{ spellID = 47788, duration = 180, type = "externalDefensive", spec = true }, -- Guardian Spirit
		{ spellID = 33206, duration = 180, type = "externalDefensive", spec = true }, -- Pain Suppression
		{ spellID = 19236, duration = 120, type = "defensive", spec = true }, -- Desperate Prayer
		{ spellID = 47585, duration = 120, type = "defensive", spec = true }, -- Dispersion
--		{ spellID = 17, duration = 3, type = "defensive", rlvl = 5 }, -- Power Word: Shield
--		{ spellID = 33076, duration = 10, type = "defensive", rlvl = 68 }, -- Prayer of Mending
		{ spellID = 64843, duration = 480, type = "raidDefensive", rlvl = 78 }, -- Divine Hymn
		{ spellID = 724, duration = 180, type = "raidDefensive", spec = true }, -- Lightwell
		{ spellID = 62618, duration = 180, type = "raidDefensive", spec = true }, -- Power Word: Barrier
		{ spellID = 14751, duration = 30, type = "offensive", spec = true }, -- Chakra
--		{ spellID = 34861, duration = 10, type = "offensive", spec = true }, -- Circle of Healing
--		{ spellID = 14914, duration = 10, type = "offensive", rlvl = 18 }, -- Holy Fire
		{ spellID = 89485, duration = 45, type = "offensive", spec = true }, -- Inner Focus
--		{ spellID = 8092, duration = 8, type = "offensive", rlvl = 9 }, -- Mind Blast
--		{ spellID = 47540, duration = 12, type = "offensive", spec = 1 }, -- Penance
		{ spellID = 10060, duration = 120, type = "offensive", spec = true }, -- Power Infusion
		{ spellID = 34433, duration = 300, type = "offensive", rlvl = 66 }, -- Shadowfiend
		{ spellID = 6346, duration = 180, type = "counterCC", rlvl = 54 }, -- Fear Ward
		{ spellID = 32379, duration = 10, type = "counterCC", rlvl = 32 }, -- Shadow Word: Death
		{ spellID = 586, duration = 30, type = "other", rlvl = 24 }, -- Fade
		{ spellID = 64901, duration = 360, type = "other", rlvl = 64 }, -- Hymn of Hope
		{ spellID = 73325, duration = 90, type = "other", rlvl = 85 }, -- Leap of Faith
	},
	["ROGUE"] = {
		{ spellID = 1766, duration = 10, type = "interrupt", rlvl = 14 }, -- Kick
		{ spellID = 2094, duration = 180, type = "cc", rlvl = 34 }, -- Blind
		{ spellID = 1776, duration = 10, type = "cc", rlvl = 16 }, -- Gouge
		{ spellID = 408, duration = 20, type = "cc", rlvl = 30 }, -- Kidney Shot
		{ spellID = 76577, duration = 180, type = "cc", rlvl = 85 }, -- Smoke Bomb
		{ spellID = 51722, duration = 60, type = "disarm", rlvl = 38 }, -- Dismantle
		{ spellID = 31228, duration = 90, type = "defensive", spec = {31228,31229,31230} }, -- Cheat Death (passive, talentid as dummy spellid)
		{ spellID = 31224, duration = 120, type = "defensive", rlvl = 58 }, -- Cloak of Shadows
		{ spellID = 74001, duration = 120, type = "defensive", rlvl = 81 }, -- Combat Readiness
		{ spellID = 5277, duration = 180, type = "defensive", rlvl = 9 }, -- Evasion
--		{ spellID = 1966, duration = 10, type = "defensive", rlvl = 42 }, -- Feint
		{ spellID = 14185, duration = 300, type = "defensive", spec = true }, -- Preparation
--		{ spellID = 14251, duration = 6, type = "defensive", spec = true }, -- Riposte (active only after parrying)
		{ spellID = 1856, duration = 180, type = "defensive", rlvl = 24 }, -- Vanish
		{ spellID = 13750, duration = 180, type = "offensive", spec = true }, -- Adrenaline Rush
--		{ spellID = 13877, duration = 10, type = "offensive", spec = 2 }, -- Blade Flurry
		{ spellID = 14177, duration = 120, type = "offensive", spec = true }, -- Cold Blood
		{ spellID = 51690, duration = 120, type = "offensive", spec = true }, -- Killing Spree
		{ spellID = 14183, duration = 20, type = "offensive", spec = true }, -- Premeditation
		{ spellID = 51713, duration = 60, type = "offensive", spec = true }, -- Shadow Dance
		{ spellID = 79140, duration = 120, type = "offensive", spec = true }, -- Vendetta
		{ spellID = 1725, duration = 30, type = "other", rlvl = 28 }, -- Distract
		{ spellID = 73981, duration = 60, type = "other", rlvl = 83 }, -- Redirect
		{ spellID = 36554, duration = 24, type = "other", spec = 3 }, -- Shadowstep
		{ spellID = 2983, duration = 60, type = "other", rlvl = 16 }, -- Sprint
		{ spellID = 1784, duration = 6, type = "other", rlvl = 5 }, -- Stealth
		{ spellID = 57934, duration = 30, type = "other", rlvl = 75 }, -- Tricks of the Trade
	},
	["SHAMAN"] = {
		{ spellID = 57994, duration = 15, type = "interrupt", rlvl = 16 }, -- Wind Shear
		{ spellID = 51514, duration = 45, type = "cc", rlvl = 80 }, -- Hex
		{ spellID = 51490, duration = 45, type = "disarm", spec = 1 }, -- Thunderstorm
		{ spellID = 30881, duration = 30, type = "defensive", spec = {30881,30883,30884} }, -- Nature's Guardian (Rank 1)
		{ spellID = 30823, duration = 60, type = "defensive", spec = true }, -- Shamanistic Rage
		{ spellID = 98008, duration = 180, type = "raidDefensive", spec = true }, -- Spirit Link Totem
		{ spellID = 2825, duration = 300, type = "offensive", rlvl = 70 }, -- Bloodlust
--		{ spellID = 32182, duration = 300, type = "offensive", rlvl = 70 }, -- Heroism	-- Merged
--		{ spellID = 421, duration = 3, type = "offensive", rlvl = 28 }, -- Chain Lightning
--		{ spellID = 8042, duration = 6, type = "offensive", rlvl = 5 }, -- Earth Shock
		{ spellID = 16166, duration = 180, type = "offensive", spec = true }, -- Elemental Mastery
		{ spellID = 51533, duration = 120, type = "offensive", spec = true }, -- Feral Spirit
--		{ spellID = 1535, duration = 4, type = "offensive", rlvl = 28 }, -- Fire Nova
		{ spellID = 2894, duration = 600, type = "offensive", rlvl = 66 }, -- Fire Elemental Totem
--		{ spellID = 8050, duration = 6, type = "offensive", rlvl = 14 }, -- Flame Shock
--		{ spellID = 51505, duration = 8, type = "offensive", rlvl = 34 }, -- Lava Burst
--		{ spellID = 60103, duration = 6, type = "offensive", spec = true }, -- Lava Lash
--		{ spellID = 61295, duration = 6, type = "offensive", spec = true }, -- Riptide
--		{ spellID = 17364, duration = 8, type = "offensive", spec = true }, -- Stormstrike
		{ spellID = 55198, duration = 180, type = "offensive", spec = true }, -- Tidal Force
		{ spellID = 73680, duration = 15, type = "offensive", rlvl = 81 }, -- Unleash Elements
		{ spellID = 8177, duration = 25, type = "counterCC", rlvl = 38 }, -- Grounding Totem
		{ spellID = 8143, duration = 60, type = "counterCC", rlvl = 52 }, -- Tremor Totem
		{ spellID = 2062, duration = 600, type = "other", rlvl = 56 }, -- Earth Elemental Totem (aoe taunt)
		{ spellID = 2484, duration = 15, type = "other", rlvl = 18 }, -- Earthbind Totem
--		{ spellID = 8056, duration = 6, type = "other", rlvl = 22 }, -- Frost Shock
		{ spellID = 16190, duration = 180, type = "other", spec = true }, -- Mana Tide Totem
		{ spellID = 16188, duration = 120, type = "other", spec = true }, -- Nature's Swiftness
		{ spellID = 20608, duration = 1800, type = "other", rlvl = 30 }, -- Reincarnation (passive)
		{ spellID = 79206, duration = 120, type = "other", rlvl = 85 }, -- Spiritwalker's Grace
		{ spellID = 5730, duration = 20, type = "other", rlvl = 58 }, -- Stoneclaw Totem -- (aoe taunt, 50% stun)
	},
	["WARLOCK"] = {
		{ spellID = 19647, duration = 24, type = "interrupt", rlvl = 52 }, -- Spell Lock
		{ spellID = 19505, duration = 15, type = "dispel", rlvl = 38 }, -- Devour Magic
		{ spellID = 6789, duration = 120, type = "cc", rlvl = 42 }, -- Death Coil
		{ spellID = 5484, duration = 40, type = "cc", rlvl = 44 }, -- Howl of Terror
		{ spellID = 30283, duration = 20, type = "cc", spec = true }, -- Shadowfury
		{ spellID = 54785, duration = 45, type = "cc", spec = 59672 }, -- Demon Leap (available with Metamorphosis)
		{ spellID = 48020, duration = 30, type = "defensive", rlvl = 78 }, -- Demonic Circle: Teleport
		{ spellID = 91713, duration = 30, type = "defensive", spec = true }, -- Nether Ward
		{ spellID = 6229, duration = 30, type = "defensive", rlvl = 34 }, -- Shadow Ward
		{ spellID = 79268, duration = 30, type = "defensive", rlvl = 12 }, -- Soul Harvest
		{ spellID = 50796, duration = 12, type = "offensive", spec = true }, -- Chaos Bolt
--		{ spellID = 17962, duration = 10, type = "offensive", spec = true }, -- Conflagrate
	--	{ spellID = 603, duration = 0, type = "offensive", rlvl = 20 }, -- Bane of Doom
		{ spellID = 47193, duration = 60, type = "offensive", spec = true }, -- Demonic Empowerment
		{ spellID = 77801, duration = 120, type = "offensive", rlvl = 85 }, -- Demon Soul
--		{ spellID = 48181, duration = 8, type = "offensive", spec = true }, -- Haunt
		{ spellID = 50589, duration = 30, type = "offensive", spec = 59672 }, -- Immolation Aura (available with Metamorphosis)
		{ spellID = 47241, duration = 180, type = "offensive", spec = 59672 }, -- Metamorphosis
--		{ spellID = 17877, duration = 15, type = "offensive", spec = true }, -- Shadowburn
--		{ spellID = 47897, duration = 12, type = "offensive", rlvl = 76 }, -- Shadowflame
		{ spellID = 86121, duration = 30, type = "offensive", spec = 56226 }, -- Soul Swap w/ Glyph of Soul Swap (no CD w/o Glyph)
		{ spellID = 18540, duration = 600, type = "offensive", rlvl = 58 }, -- Summon Doomguard
		{ spellID = 1122, duration = 600, type = "offensive", rlvl = 50 }, -- Summon Infernal
		{ spellID = 18708, duration = 180, type = "other", spec = true }, -- Fel Domination
--		{ spellID = 698, duration = 120, type = "other", rlvl = 42 }, -- Ritual of Summoning	-- TODO: req party members to cast (preactive)
--		{ spellID = 29893, duration = 300, type = "other", rlvl = 68 }, -- Ritual of Souls (Rank 1)	-- TODO: req party members to cast (preactive)
		{ spellID = 74434, duration = 45, type = "other", rlvl = 10 }, -- Soulburn
		{ spellID = 29858, duration = 120, type = "other", rlvl = 66 }, -- Soulshatter
		{ spellID = 20707, duration = 900, type = "other", rlvl = 18, buff = 0 }, -- Soulstone Resurrection (Rank 1) - dummy spell triggered on consuming/using Master Soulstone
},
	["WARRIOR"] = {
		{ spellID = 6552, duration = 10, type = "interrupt", rlvl = 38 }, -- Pummel
		{ spellID = 100, duration = 15, type = "cc", rlvl = 3 }, -- Charge (Rank 1)
		{ spellID = 12809, duration = 30, type = "cc", spec = true }, -- Concussion Blow
		{ spellID = 20252, duration = 30, type = "cc", rlvl = 50 }, -- Intercept
		{ spellID = 5246, duration = 120, type = "cc", rlvl = 42 }, -- Intimidating Shout
		{ spellID = 46968, duration = 20, type = "cc", spec = true }, -- Shockwave
		{ spellID = 85388, duration = 45, type = "cc", spec = true }, -- Throwdown
		{ spellID = 676, duration = 60, type = "disarm", rlvl = 34 }, -- Disarm
		{ spellID = 57755, duration = 60, type = "disarm", spec = {12311,12958} }, -- Heroic throw (Gag order talent 50/100% silence)
		{ spellID = 469, duration = 60, type = "defensive", rlvl = 68 }, -- Commanding Shout
		{ spellID = 55694, duration = 180, type = "defensive", rlvl = 76 }, -- Enraged Regeneration
		{ spellID = 12975, duration = 180, type = "defensive", spec = true }, -- Last Stand
		{ spellID = 97462, duration = 180, type = "raidDefensive", rlvl = 83 }, -- Rallying Cry
		{ spellID = 2565, duration = 60, type = "defensive", rlvl = 28 }, -- Shield Block
		{ spellID = 871, duration = 300, type = "defensive", rlvl = 48 }, -- Shield Wall
		{ spellID = 46924, duration = 90, type = "offensive", spec = true }, -- Bladestorm
--		{ spellID = 23881, duration = 3, type = "offensive", spec = true }, -- Bloodthirst
		{ spellID = 86346, duration = 20, type = "offensive", rlvl = 81 }, -- Colossus Smash
		{ spellID = 85730, duration = 120, type = "offensive", spec = true }, -- Deadly Calm
		{ spellID = 12292, duration = 180, type = "offensive", spec = true }, -- Death Wish
--		{ spellID = 12294, duration = 4.5, type = "offensive", spec = 1 }, -- Mortal Strike
--		{ spellID = 7384, duration = 0, type = "offensive", rlvl = 22 }, -- Overpower (active after dodge)
		{ spellID = 1719, duration = 300, type = "offensive", rlvl = 64 }, -- Recklessness
		{ spellID = 20230, duration = 300, type = "offensive", rlvl = 62 }, -- Retaliation
--		{ spellID = 6572, duration = 5, type = "offensive", rlvl = 40 }, -- Revenge (Rank 1) (active after block, dodge, parry)
--		{ spellID = 23922, duration = 6, type = "offensive", spec = 3 }, -- Shield Slam
		{ spellID = 12328, duration = 60, type = "offensive", spec = true }, -- Sweeping Strikes
--		{ spellID = 6343, duration = 6, type = "offensive", rlvl = 9 }, -- Thunder Clap (Rank 1)
--		{ spellID = 1680, duration = 10, type = "offensive", rlvl = 36 }, -- Whirlwind
		{ spellID = 18499, duration = 30, type = "counterCC", rlvl = 54 }, -- Berserker Rage
		{ spellID = 3411, duration = 30, type = "counterCC", rlvl = 72 }, -- Intervene
		{ spellID = 23920, duration = 25, type = "counterCC", rlvl = 66 }, -- Spell Reflection
		{ spellID = 1161, duration = 180, type = "other", rlvl = 46 }, -- Challenging Shout (aoe taunt)
		{ spellID = 60970, duration = 30, type = "other", spec = true }, -- Heroic Fury
		{ spellID = 6544, duration = 60, type = "other", rlvl = 85 }, -- Heroic Leap
		{ spellID = 1134, duration = 30, type = "other", rlvl = 56 }, -- Inner Rage
		{ spellID = 64382, duration = 300, type = "other", rlvl = 74 }, -- Shattering Throw
		{ spellID = 355, duration = 8, type = "other", rlvl = 12 }, -- Taunt
	},
	["PVPTRINKET"] = {
		{ spellID = 42292, duration = {[18859]=300,default=120}, type = "pvptrinket", item = 37864, item2 = 18859 }, -- -- PvP Trinket (Medallion of the Alliance, Insignia of the Alliance(Mage))
		{ spellID = 44055, duration = 180, type = "trinket", item = 34050, icon = 132344 }, -- Tremendous Fortitude <BM trinket> -- preCata
		{ spellID = 92223, duration = 120, type = "trinket", item = 64740, icon = 132344 }, -- Bloodthirsty Gladiator's Emblem of Cruelty -- Cata
		{ spellID = 92226, duration = 120, type = "trinket", item = 64687, icon = 135884 }, -- Bloodthirsty Gladiator's Badge of Conquest -- Cata
	},
	["RACIAL"] = {
		{ spellID = 28730, duration = 120, type = "racial", race = 10 }, -- Arcane Torrent (Paladin, Hunter, Priest, Mage, Warlock)
		{ spellID = 26297, duration = 180, type = "racial", race = 8 }, -- Berserking
		{ spellID = 20572, duration = 120, type = "racial", race = 2 }, -- Blood Fury (Warrior, Hunter, Rogue)
		{ spellID = 20589, duration = 105, type = "racial", race = 7 }, -- Escape Artist
		{ spellID = 28880, duration = 180, type = "racial", race = 11 }, -- Gift of the Naaru (Warrior)
		{ spellID = 59752, duration = 120, type = "racial", race = 1 }, -- Will to Survive
		{ spellID = 58984, duration = 120, type = "racial", race = 4 }, -- Shadowmeld
		{ spellID = 20594, duration = 120, type = "racial", race = 3 }, -- Stoneform
		{ spellID = 20549, duration = 120, type = "racial", race = 6 }, -- War Stomp
		{ spellID = 7744, duration = 120, type = "racial", race = 5 }, -- Will of the Forsaken
		{ spellID = 68992, duration = 120, type = "racial", race = 22 }, -- Darkflight
		{ spellID = 69070, duration = 120, type = "racial", race = 9 }, -- Will of the Forsaken
	},
	["TRINKET"] = {

	},
}

E.iconFix = E.BLANK
E.buffFix = E.BLANK
E.buffFixNoCLEU = E.BLANK
E.spell_requiredLevel = {}	-- WOTLKC only (not adding to config)
E.summonedBuffDuration = E.BLANK

E.spellDefaults = {
	42292,	-- PvP Trinket
	59752,	-- Will to Survive
	20594,	-- Stoneform
	20549,	-- War Stomp
	7744,	-- Will of the Forsaken
	-- DK
	47528,	-- Mind Freeze
	49203,	-- Hungering Cold
	47476,	-- Strangulate
	49576,	-- Death Grip
	48707,	-- Anti-Magic Shell
	48743,	-- Death Pact
	48792,	-- Icebound Foritude
	49005,	-- Mark of Blood
	51052,	-- Anti-Magic Zone
	42650,	-- Army of the Dead
	49028,	-- Dancing Rune Weapon
	47568,	-- Empower Rune Weapon
	49016,	-- Unholy Frenzy
	49206,	-- Summon Gargoyle
	49039,	-- Lichborne
	51271,	-- Pillar of Frost
	-- Druid
	80964,	-- Skull Bash (Bear Form)
	78675,	-- Solar Beam
	5211,	-- Bash
	22812,	-- Barkskin
	61336,	-- Survival Instincts
	740,	-- Tranquility
	50334,	-- Berserk
	48505,	-- Starfall
	33831,	-- Force of Nature
	17116,	-- Nature's Swiftness
	33891,	-- Tree of Life
	-- Hunter
	1499,	-- Freezing Trap
	19577,	-- Intimidation
	19503,	-- Scatter Shot
	19386,	-- Wyvern Sting
	34490,	-- Silencing Shot
	19263,	-- Deterrence
	23989,	-- Readiness
	19574,	-- Bestial Wrath
	3045,	-- Rapid Fire
	-- Mage
	2139,	-- Counterspell
	44572,	-- Deep Freeze
	31661,	-- Dragon's Breath
	82676,	-- Ring of Frost
	45438,	-- Ice Block
	11958,	-- Cold Snap
	86948,	-- Cauterize
	12042,	-- Arcane Power
	11129,	-- Combustion
	12472,	-- Icy Veins
	55342,	-- Mirror Image
	12043,	-- Presence of Mind
	-- Paladin
	96231,	-- Rebuke
	853,	-- Hammer of Justice
	20066,	-- Repentance
	642,	-- Divine Shield
	1022,	-- Hand of Protection
	6940,	-- Hand of Sacrifice
	64205,	-- Divine Sacrifice
	31842,	-- Divine Favor
	498,	-- Divine Protection
	70940,	-- Divine Guardian
	86150,	-- Guardian of Ancient Kings
	633,	-- Lay on Hands
	31850,	-- Ardent Defender
	31884,	-- Avenging Wrath
	85696,	-- Zealotry
	31821,	-- Aura Mastery
	-- Priest
	64044,	-- Psychic Horror
	8122,	-- Psychic Scream
	88625,	-- Holy Word: Chastise
	15487,	-- Silence
	47788,	-- Guardian Spirit
	33206,	-- Pain Suppression
	19236,	-- Desperate Prayer
	47585,	-- Dispersion
	64843,	-- Divine Hymn
	724,	-- Lightwell
	62618,	-- Power Word: Barrier
	14751,	-- Inner Focus
	10060,	-- Power Infusion
	34433,	-- Shadowfiend
	6346,	-- Fear Ward
	32379,	-- Shadow Word: Death
	-- Rogue
	1766,	-- Kick
	2094,	-- Blind
	408,	-- Kidney Shot
	76577,	-- Smoke Bomb
	51722,	-- Dismantle
	31228,	-- Cheat Death
	31224,	-- Cloak of Shadows
	5277,	-- Evasion
	14185,	-- Preparation
	1856,	-- Vanish
	74001,	-- Combat Readiness
	13750,	-- Adrenaline Rush
	13877,	-- Blade Flurry
	14177,	-- Cold Blood
	51690,	-- Killing Spree
	51713,	-- Shadow Dance
	79140,	-- Vendetta
	36554,	-- Shadowstep
	-- Shaman
	57994,	-- Wind Shear
	51514,	-- Hex
	30881,	-- Nature's Guardian
	30823,	-- Shamanistic Rage
	98008,	-- Spirit Link Totem
	2825,	-- Bloodlust
	16166,	-- Elemental Mastery
	51533,	-- Feral Spirit
	2894,	-- Fire Elemental Totem
	55198,	-- Tidal Force
	8177,	-- Grounding Totem
	8143,	-- Tremor Totem
	16188,	-- Nature's Swiftness
	-- Warlock
	19647,	-- Spell Lock
	6789,	-- Death Coil
	5484,	-- Howl of Terror
	30283,	-- Shadowfury
	54785,	-- Demon Charge
	48020,	-- Demonic Circle: Teleport
	1122,	-- Summon Infernal
	18540,	-- Summon Doomguard
	47241,	-- Metamorphosis
	18708,	-- Fel Domination
	-- Warrior
	6552,	-- Pummel
	72,	-- Shield Bash
	12809,	-- Concussion Blow
	5246,	-- Intimidating Shout
	46968,	-- Shockwave
	85388,	-- Throwdown
	676,	-- Disarm
	57755,	-- Heroic Throw (silece with Gag Order talent)
	55694,	-- Enraged Regeneration
	12975,	-- Last Stand
	97462,	-- Rallying Cry
	871,	-- Shield Wall
	46924,	-- Bladestorm
	12292,	-- Death Wish
	1719,	-- Recklessness
	85730,	-- Deadly Calm
	20230,	-- Retaliation
	3411,	-- Intervene
	64382,	-- Shattering Throw
	18499,	-- Berserker Rage
	23920,	-- Spell Reflection
}

E.raidDefaults = {
	47528, 16979, 26090, 2139, 1766, 57994, 19244, 6552, 72,
	51052,	-- Anti-Magic Zone
	740,	-- Tranquility
	31821,	-- Aura Mastery
	64843,	-- Divine Hymn
	724,	-- Light Well
	62618,	-- Power Word: Barrier
	98008,	-- Spirit Link Totem
	97462,	-- Rallying Cry
}
