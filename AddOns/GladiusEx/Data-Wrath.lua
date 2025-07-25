GladiusEx.Data = {}

local L = LibStub("AceLocale-3.0"):GetLocale("GladiusEx")

local SPECIALIZATION_ICONS = {
    [250] = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
    [251] = "Interface\\Icons\\Spell_Deathknight_FrostPresence",
    [252] = "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
    [102] = "Interface\\Icons\\Spell_Nature_StarFall",
    [103] = "Interface\\Icons\\Ability_Druid_CatForm",
    [105] = "Interface\\Icons\\Spell_Nature_HealingTouch",
    [253] = "Interface\\Icons\\Ability_Hunter_BeastTaming",
    [254] = "Interface\\Icons\\Ability_Marksmanship",
    [255] = "Interface\\Icons\\Ability_Hunter_SwiftStrike",
    [62] = "Interface\\Icons\\Spell_Holy_MagicalSentry",
    [63] = "Interface\\Icons\\Spell_Fire_FlameBolt",
    [64] = "Interface\\Icons\\Spell_Frost_FrostBolt02",
    [65] = "Interface\\Icons\\Spell_Holy_HolyBolt",
    [66] = "Interface\\Icons\\Spell_Holy_DevotionAura",
    [70] = "Interface\\Icons\\Spell_Holy_AuraOfLight",
    [256] = "Interface\\Icons\\Spell_Holy_WordFortitude",
    [257] = "Interface\\Icons\\Spell_Holy_GuardianSpirit",
    [258] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    [259] = "Interface\\Icons\\Ability_Rogue_ShadowStrikes",
    [260] = "Interface\\Icons\\Ability_BackStab",
    [261] = "Interface\\Icons\\Ability_Stealth",
    [262] = "Interface\\Icons\\Spell_Nature_Lightning",
    [263] = "Interface\\Icons\\Spell_Nature_LightningShield",
    [264] = "Interface\\Icons\\Spell_Nature_MagicImmunity",
    [265] = "Interface\\Icons\\Spell_Shadow_DeathCoil",
    [266] = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
    [267] = "Interface\\Icons\\Spell_Shadow_RainOfFire",
    [71] = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    [72] = "Interface\\Icons\\Ability_Warrior_Bladestorm",
    [73] = "Interface\\Icons\\Ability_Warrior_InnerRage"
}

local classIDToSpecID = {
    [1] = {[1] = 71, [2] = 72, [3] = 73}, -- Warrior
    [2] = {[1] = 65, [2] = 66, [3] = 70}, -- Paladin
    [3] = {[1] = 253, [2] = 254, [3] = 255}, -- Hunter
    [4] = {[1] = 259, [2] = 260, [3] = 261}, -- Rogue
    [5] = {[1] = 256, [2] = 257, [3] = 258}, -- Priest
    [6] = {[1] = 250, [2] = 251, [3] = 252}, -- Death Knight
    [7] = {[1] = 262, [2] = 263, [3] = 264}, -- Shaman
    [8] = {[1] = 62, [2] = 63, [3] = 64}, -- Mage
    [9] = {[1] = 265, [2] = 266, [3] = 267}, -- Warlock
    [11] = {[1] = 102, [2] = 103, [3] = 105} -- Druid
}

local specData = {
    -- id, name, description, icon, role, locale-ind. class name, localized class name
    [250] = {250, "Blood", "", SPECIALIZATION_ICONS[250], "TANK", "DEATHKNIGHT", L["Death Knight"]},
    [251] = {251, "Frost", "", SPECIALIZATION_ICONS[251], "DAMAGER", "DEATHKNIGHT", L["Death Knight"]},
    [252] = {252, "Unholy", "", SPECIALIZATION_ICONS[252], "DAMAGER", "DEATHKNIGHT", L["Death Knight"]},
    [102] = {102, "Balance", "", SPECIALIZATION_ICONS[102], "DAMAGER", "DRUID", L["Druid"]},
    [103] = {103, "Feral", "", SPECIALIZATION_ICONS[103], "DAMAGER", "DRUID", L["Druid"]},
    [105] = {105, "Restoration", "", SPECIALIZATION_ICONS[105], "HEALER", "DRUID", L["Druid"]},
    [253] = {253, "Beast Mastery", "", SPECIALIZATION_ICONS[253], "DAMAGER", "HUNTER", L["Hunter"]},
    [254] = {254, "Marksmanship", "", SPECIALIZATION_ICONS[254], "DAMAGER", "HUNTER", L["Hunter"]},
    [255] = {255, "Survival", "", SPECIALIZATION_ICONS[255], "DAMAGER", "HUNTER", L["Hunter"]},
    [62] = {62, "Arcane", "", SPECIALIZATION_ICONS[62], "DAMAGER", "MAGE", L["Mage"]},
    [63] = {63, "Fire", "", SPECIALIZATION_ICONS[63], "DAMAGER", "MAGE", L["Mage"]},
    [64] = {64, "Frost", "", SPECIALIZATION_ICONS[64], "DAMAGER", "MAGE", L["Mage"]},
    [65] = {65, "Holy", "", SPECIALIZATION_ICONS[65], "HEALER", "PALADIN", L["Paladin"]},
    [66] = {66, "Protection", "", SPECIALIZATION_ICONS[66], "TANK", "PALADIN", L["Paladin"]},
    [70] = {70, "Retribution", "", SPECIALIZATION_ICONS[70], "DAMAGER", "PALADIN", L["Paladin"]},
    [256] = {256, "Discipline", "", SPECIALIZATION_ICONS[256], "HEALER", "PRIEST", L["Priest"]},
    [257] = {257, "Holy", "", SPECIALIZATION_ICONS[257], "HEALER", "PRIEST", L["Priest"]},
    [258] = {258, "Shadow", "", SPECIALIZATION_ICONS[258], "DAMAGER", "PRIEST", L["Priest"]},
    [259] = {259, "Assassination", "", SPECIALIZATION_ICONS[259], "DAMAGER", "ROGUE", L["Rogue"]},
    [260] = {260, "Combat", "", SPECIALIZATION_ICONS[260], "DAMAGER", "ROGUE", L["Rogue"]},
    [261] = {261, "Subtlety", "", SPECIALIZATION_ICONS[261], "DAMAGER", "ROGUE", L["Rogue"]},
    [262] = {262, "Elemental", "", SPECIALIZATION_ICONS[262], "DAMAGER", "SHAMAN", L["Shaman"]},
    [263] = {263, "Enhancement", "", SPECIALIZATION_ICONS[263], "DAMAGER", "SHAMAN", L["Shaman"]},
    [264] = {264, "Restoration", "", SPECIALIZATION_ICONS[264], "HEALER", "SHAMAN", L["Shaman"]},
    [265] = {265, "Affliction", "", SPECIALIZATION_ICONS[265], "DAMAGER", "WARLOCK", L["Warlock"]},
    [266] = {266, "Demonology", "", SPECIALIZATION_ICONS[266], "DAMAGER", "WARLOCK", L["Warlock"]},
    [267] = {267, "Destruction", "", SPECIALIZATION_ICONS[267], "DAMAGER", "WARLOCK", L["Warlock"]},
    [71] = {71, "Arms", "", SPECIALIZATION_ICONS[71], "DAMAGER", "WARRIOR", L["Warrior"]},
    [72] = {72, "Fury", "", SPECIALIZATION_ICONS[72], "DAMAGER", "WARRIOR", L["Warrior"]},
    [73] = {73, "Protection", "", SPECIALIZATION_ICONS[73], "TANK", "WARRIOR", L["Warrior"]}
}

function GladiusEx.Data.DefaultAlertSpells()
    return {}
end

function GladiusEx.Data.DefaultAuras()
    return {
        [GladiusEx:SafeGetSpellName(57940)] = true -- Essence of Wintergrasp
    }
end

function GladiusEx.Data.DefaultClassicon()
	return {
		-- Higher Number is More Priority
		-- Priority List by Bibimapi
		-- Immunes I and Stealth (10)

		[GladiusEx:SafeGetSpellName(33786)]	= 10,	-- Cyclone
		[GladiusEx:SafeGetSpellName(605)]	  = 10,	-- Mind Control
		[GladiusEx:SafeGetSpellName(45438)]	= 10,	-- Ice Block 
		[GladiusEx:SafeGetSpellName(642)]	  = 10,	-- Divine Shield
		[GladiusEx:SafeGetSpellName(27827)]	= 10,	-- Spirit of Redemption
		[GladiusEx:SafeGetSpellName(34692)] = 10, -- The Beast Within

		[GladiusEx:SafeGetSpellName(5215)]	= 10,	-- Prowl
		[GladiusEx:SafeGetSpellName(32612)]	= 10,	-- Invisibility (main)
		[GladiusEx:SafeGetSpellName(1784)]	= 10,	-- Stealth 
		[GladiusEx:SafeGetSpellName(11327)]	= 10,	-- Vanish
		[GladiusEx:SafeGetSpellName(5384)]	= 10,	-- Feign Death

		[GladiusEx:SafeGetSpellName(44166)]	= 10,	-- Refreshment
		[GladiusEx:SafeGetSpellName(27089)]	= 10,	-- Drink1
		[GladiusEx:SafeGetSpellName(46755)]	= 10,	-- Drink2
		[GladiusEx:SafeGetSpellName(23920)] = 10,	-- Spell Reflection
		[GladiusEx:SafeGetSpellName(31224)]	= 10,	-- Cloak of Shadows


		-- Breakable CC (9)

		[GladiusEx:SafeGetSpellName(2637)]  	= 9,	-- Hibernate 
		[GladiusEx:SafeGetSpellName(3355)]  	= 9,	-- Freezing Trap 
		[GladiusEx:SafeGetSpellName(37506)]  	= 9,	-- Scatter Shot
		[GladiusEx:SafeGetSpellName(118)]  	  = 9.1,	-- Polymorph
		[GladiusEx:SafeGetSpellName(28272)]  	= 9.1,	-- Polymorph (pig)
		[GladiusEx:SafeGetSpellName(28271)]  	= 9.1,	-- Polymorph (turtle
		[GladiusEx:SafeGetSpellName(20066)]  	= 9,	-- Repentance
		[GladiusEx:SafeGetSpellName(1776)]  	= 9,	-- Gouge
		[GladiusEx:SafeGetSpellName(6770)]  	= 9.1,	-- Sap
		[GladiusEx:SafeGetSpellName(1513)]  	= 9,	-- Scare Beast
		[GladiusEx:SafeGetSpellName(31661)]  	= 9,	-- Dragon's Breath 
		[GladiusEx:SafeGetSpellName(8122)]  	= 9,	-- Psychic Scream 
		[GladiusEx:SafeGetSpellName(2094)]  	= 9,	-- Blind 
		[GladiusEx:SafeGetSpellName(5782)]  	= 9,	-- Fear
		[GladiusEx:SafeGetSpellName(5484)]  	= 9,	-- Howl of Terror
		[GladiusEx:SafeGetSpellName(6358)]  	= 9,	-- Seduction
		[GladiusEx:SafeGetSpellName(5246)]  	= 9,	-- Intimidating Shout 
		[GladiusEx:SafeGetSpellName(22570)]  	= 9,	-- Maim
		[GladiusEx:SafeGetSpellName(19386)]   = 9,  -- Wyvern Sting


		-- Stuns (8)

		[GladiusEx:SafeGetSpellName(5211)]  = 8,	-- Bash 
		[GladiusEx:SafeGetSpellName(24394)] = 8,	-- Intimidation 
		[GladiusEx:SafeGetSpellName(853)]  	= 8,	-- Hammer of Justice
		[GladiusEx:SafeGetSpellName(1833)] 	= 8,	-- Cheap Shot 
		[GladiusEx:SafeGetSpellName(408)]  	= 8,	-- Kidney Shot 
		[GladiusEx:SafeGetSpellName(30283)] = 8,	-- Shadowfury 
		[GladiusEx:SafeGetSpellName(20549)] = 8,	-- War Stomp
		[GladiusEx:SafeGetSpellName(835)]   = 8,     -- Tidal Charm
		[GladiusEx:SafeGetSpellName(12809)] = 8,   -- Concussion Blow
		[GladiusEx:SafeGetSpellName(100)]   = 8,   -- Charge
		[GladiusEx:SafeGetSpellName(25275)] = 8,   -- Intercept
		[GladiusEx:SafeGetSpellName(28445)] = 8,  -- Concussive Shot

		-- Immunes II (7)

		[GladiusEx:SafeGetSpellName(1022)]  	= 7,	-- Blessing of Protection
		[GladiusEx:SafeGetSpellName(33206)]   = 7, -- Pain Suppression
		[GladiusEx:SafeGetSpellName(5277)]  	= 7,	-- Evasion


		-- Defensives I (6.5)
		[GladiusEx:SafeGetSpellName(3411)]    = 6.5,   -- Intervene
		[GladiusEx:SafeGetSpellName(45182)]	 	= 6.5,	 -- Cheat Death
		[GladiusEx:SafeGetSpellName(19263)]   = 6.5,   -- Deterrence

		-- Immunes III (6)

		[GladiusEx:SafeGetSpellName(18499)]  	= 6,	-- Berserker Rage

		-- Unbreakable CC and Roots (5)

		[GladiusEx:SafeGetSpellName(6789)]  	= 5,	-- Death Coil 
		[GladiusEx:SafeGetSpellName(15487)]  	= 5,	-- Silence
		[GladiusEx:SafeGetSpellName(27559)]  	= 3,	-- Silencing shot (3 second silence)
		[GladiusEx:SafeGetSpellName(1330)]  	= 5,	-- Garrote
		[GladiusEx:SafeGetSpellName(339)]  	  = 5,	-- Entangling Roots
		[GladiusEx:SafeGetSpellName(122)]   	= 5,	-- Frost Nova
		[GladiusEx:SafeGetSpellName(33395)]  	= 5,	-- Freeze (Water Elemental)
		[GladiusEx:SafeGetSpellName(676)]   	= 5,	-- Disarm 
		[GladiusEx:SafeGetSpellName(16979)]  	= 5,	-- Feral Charge

		-- Defensives II (4.5)

		[GladiusEx:SafeGetSpellName(6940)] 	= 4.5,	-- Blessing of Sacrifice
		[GladiusEx:SafeGetSpellName(871)]  	= 4.5,	-- Shield Wall



		-- Important II (4)

		[GladiusEx:SafeGetSpellName(29166)]  	= 4,	-- Innervate
		[GladiusEx:SafeGetSpellName(31842)]  	= 4,	-- Divine Illumination
		[GladiusEx:SafeGetSpellName(17116)]  	= 4,	-- Nature's Swiftness (Druid)
		[GladiusEx:SafeGetSpellName(16188)]  	= 4,	-- Nature's Swiftness (Shaman)
		[GladiusEx:SafeGetSpellName(16166)]  	= 4,	-- Elemental Mastery
		[GladiusEx:SafeGetSpellName(1044)]		= 4,	-- Blessing of Freedom
		[GladiusEx:SafeGetSpellName(34709)]  	= 4,	-- Shadow Sight (eye in arena)
		[GladiusEx:SafeGetSpellName(14751)]  	= 4,	-- Inner Focus

		-- Offensives I (3)

		[GladiusEx:SafeGetSpellName(19574)]  	= 3,	-- Bestial Wrath
		[GladiusEx:SafeGetSpellName(12042)]  	= 3,	-- Arcane Power
		[GladiusEx:SafeGetSpellName(12472)]  	= 3,	-- Icy Veins 
		[GladiusEx:SafeGetSpellName(29977)]  	= 3,	-- Combustion
		[GladiusEx:SafeGetSpellName(31884)]  	= 3,	-- Avenging Wrath
		[GladiusEx:SafeGetSpellName(13750)]  	= 3,	-- Adrenaline Rush 
		[GladiusEx:SafeGetSpellName(32182)]  	= 3,	-- Heroism  
		[GladiusEx:SafeGetSpellName(2825)]  	= 3,	-- Bloodlust
		[GladiusEx:SafeGetSpellName(13877)]  	= 3,	-- Blade Flurry 
		[GladiusEx:SafeGetSpellName(1719)]  	= 3,	-- Recklessness
		[GladiusEx:SafeGetSpellName(12292)]  	= 3,	-- Death Wish
		[GladiusEx:SafeGetSpellName(3045)]  	= 3,	-- Rapid Fire

		-- Defensives III (2.5)

		[GladiusEx:SafeGetSpellName(22812)]  	= 2.5,	-- Barkskin
		[GladiusEx:SafeGetSpellName(16689)]   = 2.5,   -- Nature's Grasp
		[GladiusEx:SafeGetSpellName(22842)]  	= 2.5,	-- Frenzied Regen
		[GladiusEx:SafeGetSpellName(498)]  	  = 2.5,	-- Divine Protection
		[GladiusEx:SafeGetSpellName(12975)]  	= 2.5,	-- Last Stand
		[GladiusEx:SafeGetSpellName(38031)]  	= 2.5,	-- Shield Block
		[GladiusEx:SafeGetSpellName(66)]	   	= 2.5,	-- Invisibility (initial)
		[GladiusEx:SafeGetSpellName(20578)]  	= 2.5,	-- Cannibalize
		[GladiusEx:SafeGetSpellName(8178)]  	= 2.5,	-- Grounding Totem Effect
		[GladiusEx:SafeGetSpellName(8145)]    = 2.5,   -- Tremor Totem Passive
		[GladiusEx:SafeGetSpellName(6346)]    = 2.5,   -- Fear Ward
		[GladiusEx:SafeGetSpellName(30823)]   = 2.5,   -- Shamanistic Rage
		[GladiusEx:SafeGetSpellName(27273)]   = 2.5,     -- Sacrifice

		-- Offensives II (2)

		[GladiusEx:SafeGetSpellName(5217)]  	= 2,	-- Tiger's Fury
		[GladiusEx:SafeGetSpellName(12043)]  	= 2,	-- Presence of Mind
		[GladiusEx:SafeGetSpellName(10060)]  	= 2,	-- Power Infusion
		[GladiusEx:SafeGetSpellName(14177)]  	= 2,	-- Cold Blood
		[GladiusEx:SafeGetSpellName(12328)]  	= 2,	-- Sweeping Strikes

		-- Misc (1)

		[GladiusEx:SafeGetSpellName(2645)]		= 1,	-- Ghost Wolf
		[GladiusEx:SafeGetSpellName(12051)]   = 1,  -- Evocation
		[GladiusEx:SafeGetSpellName(16190)]  	= 1,	-- Mana Tide Totem
		[GladiusEx:SafeGetSpellName(18708)]  	= 1,	-- Fel Domination
		[GladiusEx:SafeGetSpellName(1850)]  	= 1,	-- Dash
		[GladiusEx:SafeGetSpellName(5118)]  	= 1,	-- Aspect of the Cheetah
		[GladiusEx:SafeGetSpellName(2983)]  	= 1,	-- Sprint
		[GladiusEx:SafeGetSpellName(36554)]  	= 1,	-- Shadowstep
		[GladiusEx:SafeGetSpellName(41425)]  	= 1,	-- Hypothermia
		[GladiusEx:SafeGetSpellName(25771)]  	= 1,	-- Forbearance
		[GladiusEx:SafeGetSpellName(3034)]  	= 1,	-- Viper Sting
		[GladiusEx:SafeGetSpellName(3043)]  	= 1,	-- Scorpid Sting
		[GladiusEx:SafeGetSpellName(25467)]  	= 1,	-- Devouring Plague
		[GladiusEx:SafeGetSpellName(2687)]  	= 1,	-- Bloodrage
		[GladiusEx:SafeGetSpellName(11426)]   = 1,  -- Ice Barrier
		[GladiusEx:SafeGetSpellName(1543)]    = 1,  -- Flare
  }
end

function GladiusEx.Data.DefaultCooldowns()
    return {
        {
            -- group 1
            [22812] = true, -- Druid/Barkskin
            [33786] = true, -- Druid/Cyclone (feral)
            [99] = true, -- Druid/Disorienting Roar
            [16689] = true, -- Druid/Nature's Grasp
            [5211] = true, -- Druid/Bash
            [16979] = true, -- Druid/Feral Charge
            [17116] = true, -- Druid/Nature's Swiftness
            [29166] = true, -- Druid/Nature's Swiftness
            [19574] = true, -- Hunter/Bestial Wrath
            [19263] = true, -- Hunter/Deterrence
            [781] = true, -- Hunter/Disengage
            [1499] = true, -- Hunter/Freezing Trap
            [19577] = true, -- Hunter/Intimidation
            [23989] = true, -- Hunter/Readiness
            [19386] = true, -- Hunter/Wyvern Sting
            [19503] = true, -- Hunter/Scatter Shot
            [34490] = true, -- Hunter/Silencing Shot
            [26064] = true, -- Hunter/Shell Shield
            [3045] = true, -- Hunter/Rapid Fire
            [1953] = true, -- Mage/Blink
            [11958] = true, -- Mage/Cold Snap. V: changed ID in legion
            [2139] = true, -- Mage/Counterspell
            [122] = true, -- Mage/Frost Nova
            [45438] = true, -- Mage/Ice Block
            [12043] = true, -- Mage/Presence of Mind
            [12051] = true, -- Mage/Evocation
            [31661] = true, -- Mage/Dragon's Breath
            [11129] = true, -- Mage/Combustion
            [12472] = true, -- Mage/Icy Veins
            [4987] = true, -- Paladin/Cleanse
            [31821] = true, -- Paladin/Devotion Aura
            [642] = true, -- Paladin/Divine Shield
            [853] = true, -- Paladin/Hammer of Justice
            [20066] = true, -- Paladin/Repentance
            [1044] = true, -- Paladin/Blessing of Freedom
            [6940] = true, -- Paladin/Blessing of Sacrifice
            [31884] = true, -- Paladin/Avenging Wrath
            [31842] = true, -- Paladin/Divine Illumination
            [20925] = true, -- Paladin/Holy Shield
            [20216] = true, -- Paladin/Divine Favor
            [498] = true, -- Paladin/Divine Protection
            [1022] = true, -- Paladin/Blessing of Protection
            [48173] = true, -- Priest/Desperate Prayer
            [33206] = true, -- Priest/Pain Suppression
            [8122] = true, -- Priest/Psychic Scream
            [527] = true, -- Priest/Purify
            [15487] = true, -- Priest/Silence
            [10060] = true, -- Priest/Power Infusion
            [34433] = true, -- Priest/Shadowfiend
            [14751] = true, -- Priest/Inner Focus
            [6346] = true, -- Priest/Fear Ward
            [47585] = true, -- Priest/Dispersion
            [13750] = true, -- Rogue/Adrenaline Rush
            [13877] = true, -- Rogue/Blade Furry
            [2094] = true, -- Rogue/Blind
            [31224] = true, -- Rogue/Cloak of Shadows
            [1766] = true, -- Rogue/Kick
            [1856] = true, -- Rogue/Vanish
            [14177] = true, -- Rogue/Cold Blood
            [36554] = true, -- Rogue/Shadowstep
            [5277] = true, -- Rogue/Evasion
            [2983] = true, -- Rogue/Sprint
            [14185] = true, -- Rogue/Preparation
            [5484] = true, -- Warlock/Howl of Terror
            [6789] = true, -- Warlock/Death Coil
            [30283] = true, -- Warlock/Shadowfury
            [19647] = true, -- Warlock/Spell Lock
            [19505] = true, -- Warlock/Devour Magic
            [5246] = true, -- Warrior/Intimidating Shout
            [6552] = true, -- Warrior/Pummel
            [1719] = true, -- Warrior/Recklessness
            [871] = true, -- Warrior/Shield Wall
            [23920] = true, -- Warrior/Spell Reflection
            [12292] = true, -- Warrior/Death Wish
            [3411] = true, -- Warrior/Intervene
            [100] = true, -- Warrior/Charge
            [20252] = true, -- Warrior/Intercept
            [12809] = true, -- Warrior/Concussion Blow
            [18499] = true, -- Warrior/Berserker Rage
            [676] = true, -- Warrior/Disarm
            [12975] = true, -- Warrior/Last Stand
            [57994] = true, -- Shaman/Wind Shear
            [16188] = true, -- Shaman/Nature's Swiftness
            [8177] = true, -- Shaman/Grounding Totem
            [30823] = true, -- Shaman/Shamanistic Rage
            [49039] = true, -- Death Knight/Lichborne
            [47476] = true, -- Death Knight/Strangulate
            [48792] = true, -- Death Knight/Icebound Fortitude
            [47528] = true, -- Death Knight/Mind Freeze
            [51052] = true, -- Death Knight/Anti-Magic Zone
            [48707] = true -- Death Knight/Anti-Magic Shell
        },
        {
            -- group 2
            [42292] = true, -- PvP Trinket
            [59752] = true -- Will to Survive (Human EMFH) K: This is not needed since EMFH shares CD with PvP Trinket
        }
    }
end

function GladiusEx.Data.InterruptModifiers()
    return {}
end

function GladiusEx.Data.Interrupts()
    return {
        [19675] = {duration = 4}, -- Feral Charge Effect (Druid)
        [2139] = {duration = 8}, -- Counterspell (Mage)
        [1766] = {duration = 5}, -- Kick (Rogue)
        [6552] = {duration = 4}, -- Pummel (Warrior)
        [72] = {duration = 6}, -- Shield Bash (Warrior)
        [57994] = {duration = 2}, -- Wind Shear (Shaman)
        [19244] = {duration = 5}, -- Spell Lock (Warlock
        [47528] = {duration = 5} -- Mind Freeze (Deathknight)
    }
end

GladiusEx.Data.SpecBuffs = {
    -- WARRIOR
    [56638] = 71, -- Taste for Blood
    [64976] = 71, -- Juggernaut
    [57522] = 71, -- Enrage
    [52437] = 71, -- Sudden Death
    [46857] = 71, -- Trauma
    [56112] = 72, -- Furious Attacks
    [29801] = 72, -- Rampage
    [46916] = 72, -- Slam!
    [50227] = 73, -- Sword and Board
    [50720] = 73, -- Vigilance
    [74347] = 73, -- Silenced - Gag Order
    -- PALADIN
    [20375] = 70, -- Seal of Command
    [59578] = 70, -- The Art of War
    [31836] = 65, -- Light's Grace
    [53563] = 65, -- Beacon of Light
    [54149] = 65, -- Infusion of Light
    [63529] = 66, -- Silenced - Shield of the Templar
    -- ROGUE
    [36554] = 261, -- Shadowstep
    [44373] = 261, -- Shadowstep Speed
    [36563] = 261, -- Shadowstep DMG
    [51713] = 261, -- Shadow Dance
    [31665] = 261, -- Master of Subtlety
    [14278] = 261, -- Ghostly Strike
    [51690] = 260, -- Killing Spree
    [13877] = 260, -- Blade Flurry
    [13750] = 260, -- Adrenaline Rush
    [14177] = 259, -- Cold Blood
    -- PRIEST
    [47788] = 257, -- Guardian Spirit
    [52800] = 256, -- Borrowed Time
    [63944] = 256, -- Renewed Hope
    [15473] = 258, -- Shadowform
    [15286] = 258, -- Vampiric Embrace
    -- DEATHKNIGHT
    [49222] = 252, -- Bone Shield
    [49016] = 250, -- Hysteria
    [53138] = 250, -- Abomination's Might
    [55610] = 251, -- Imp. Icy Talons
    -- MAGE
    [43039] = 64, -- Ice Barrier
    [74396] = 64, -- Fingers of Frost
    [57761] = 64, -- Fireball!
    [11129] = 63, -- Combustion
    [64346] = 63, -- Fiery Payback
    [48108] = 63, -- Hot Streak
    [54741] = 63, -- Firestarter
    [55360] = 63, -- Living Bomb
    [31583] = 62, -- Arcane Empowerment
    [44413] = 62, -- Incanter's Absorption
    -- WARLOCK
    [30302] = 267, -- Nether Protection
    [63244] = 267, -- Pyroclasm
    [54277] = 267, -- Backdraft
    [47283] = 267, -- Empowered Imp
    [34936] = 267, -- Backlash
    [47193] = 266, -- Demonic Empowerment
    [64371] = 265, -- Eradication
    -- SHAMAN
    [57663] = 262, -- Totem of Wrath
    [65264] = 262, -- Lava Flows
    [51470] = 262, -- Elemental Oath
    [52179] = 262, -- Astral Shift
    [49284] = 264, -- Earth Shield
    [53390] = 264, -- Tidal Waves
    [30809] = 263, -- Unleashed Rage
    [53817] = 263, -- Maelstrom Weapon
    [63685] = 263, -- Freeze (Frozen Power)
    -- HUNTER
    [20895] = 253, -- Spirit Bond
    [34471] = 253, -- The Beast Within
    [75447] = 253, -- Ferocious Inspiration
    [19506] = 254, -- Trueshot Aura
    [64420] = 255, -- Sniper Training
    -- DRUID
    [24932] = 103, -- Leader of the Pack
    [16975] = 103, -- Predatory Strikes
    [50334] = 103, -- Berserk
    [24907] = 102, -- Moonkin Aura
    [24858] = 102, -- Moonkin Form
    [48504] = 105, -- Living Seed
    [45283] = 105, -- Natural Perfection
    [53251] = 105, -- Wild Growth
    [16188] = 105, -- Nature's Swiftness
    [33891] = 105 -- Tree of Life
}

GladiusEx.Data.SpecSpells = {
    -- WARRIOR
    [47486] = 71, -- Mortal Strike
    [46924] = 71, -- Bladestorm
    [23881] = 72, -- Bloodthirst
    [12809] = 73, -- Concussion Blow
    [47498] = 73, -- Devastate
    [46968] = 73, -- Shockwave
    [50720] = 73, -- Vigilance
    -- PALADIN
    [48827] = 66, -- Avenger's Shield
    [48825] = 65, -- Holy Shock
    [53563] = 65, -- Beacon of Light
    [35395] = 70, -- Crusader Strike
    [66006] = 70, -- Divine Storm
    [20066] = 70, -- Repentance
    -- ROGUE
    [48666] = 259, -- Mutilate
    [14177] = 259, -- Cold Blood
    [51690] = 260, -- Killing Spree
    [13877] = 260, -- Blade Flurry
    [13750] = 260, -- Adrenaline Rush
    [36554] = 261, -- Shadowstep
    [48660] = 261, -- Hemorrhage
    [51713] = 261, -- Shadow Dance
    -- PRIEST
    [53007] = 256, -- Penance
    [10060] = 256, -- Power Infusion
    [33206] = 256, -- Pain Suppression
    [34861] = 257, -- Circle of Healing
    [15487] = 258, -- Silence
    [48160] = 258, -- Vampiric Touch
    -- DEATHKNIGHT
    [55262] = 250, -- Heart Strike
    [49203] = 251, -- Hungering Cold
    [55268] = 251, -- Frost Strike
    [51411] = 251, -- Howling Blast
    [55271] = 252, -- Scourge Strike
    -- MAGE
    [44781] = 62, -- Arcane Barrage
    [55360] = 63, -- Living Bomb
    [42950] = 63, -- Dragon's Breath
    [42945] = 63, -- Blast Wave
    [44572] = 64, -- Deep Freeze
    -- WARLOCK
    [59164] = 265, -- Haunt
    [47843] = 265, -- Unstable Affliction
    [59672] = 266, -- Metamorphosis
    [47193] = 266, -- Demonic Empowerment
    [47996] = 266, -- Intercept Felguard
    [59172] = 267, -- Chaos Bolt
    [47847] = 267, -- Shadowfury
    -- SHAMAN
    [59159] = 262, -- Thunderstorm
    [16166] = 262, -- Elemental Mastery
    [51533] = 263, -- Feral Spirit
    [30823] = 263, -- Shamanistic Rage
    [17364] = 263, -- Stormstrike
    [61301] = 264, -- Riptide
    [51886] = 264, -- Cleanse Spirit
    -- HUNTER
    [19577] = 253, -- Intimidation
    [34490] = 254, -- Silencing Shot
    [53209] = 254, -- Chimera Shot
    [60053] = 255, -- Explosive Shot
    [49012] = 255, -- Wyvern Sting
    -- DRUID
    [53201] = 102, -- Starfall
    [61384] = 102, -- Typhoon
    [24858] = 102, -- Moonkin Form
    [48566] = 103, -- Mangle (Cat)
    [48564] = 103, -- Mangle (Bear)
    [50334] = 103, -- Berserk
    [18562] = 105, -- Swiftmend
    [17116] = 105, -- Nature's Swiftness
    [33891] = 105, -- Tree of Life
    [53251] = 105, -- Wild Growth
}

GladiusEx.Data.SpecManaLimit = 11000

function GladiusEx.Data.GetSpecializationInfoByID(id)
    if specData[id] == nil then
        return
    end
    return unpack(specData[id])
end

function GladiusEx.Data.GetNumSpecializationsForClassID(classID)
    return 3
end

function GladiusEx.Data.GetSpecializationInfoForClassID(classID, specIndex)
    local specID = classIDToSpecID[classID][specIndex]
    local _, name, desc, icon, role, classFile, className = GladiusEx.Data.GetSpecializationInfoByID(specID)
    return specID, name, desc, icon, role, classFile, className
end

function GladiusEx.Data.GetArenaOpponentSpec(id)
    local unit = "arena" .. id
    return GladiusEx.buttons[unit] and GladiusEx.buttons[unit].specID
end

function GladiusEx.Data.CountArenaOpponents()
    return GladiusEx:GetArenaSize(2)
end

function GladiusEx.Data.GetNumArenaOpponentSpecs()
    return nil
end
