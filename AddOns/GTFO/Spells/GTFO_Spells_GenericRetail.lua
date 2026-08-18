--------------------------------------------------------------------------
-- GTFO_Spells_GenericRetail.lua 
--------------------------------------------------------------------------
--[[
GTFO Spell List - Generic List (Retail version)

Sample:
	GTFO.SpellID["12345"] = {
		--desc = "Spell of Awesomeness (PvP)"; -- Human-readable description for maintainers

		-- Retail functionality
		sound = 1; -- Default alert sound: 0 = none, 1 = high, 2 = low, 3 = fail, 4 = friendly fire
		tankSound = 2; -- Overrides sound while the player is in tank mode
		soundLFR = 2; -- Overrides sound in Looking for Raid
		tankSoundLFR = 2; -- Overrides sound in Looking for Raid while in tank mode
		soundHeroic = 1; -- Overrides sound on Heroic difficulty
		tankSoundHeroic = 2; -- Overrides sound on Heroic difficulty while in tank mode
		soundMythic = 1; -- Overrides sound on Mythic difficulty, falling back to soundHeroic
		tankSoundMythic = 1; -- Overrides sound on Mythic difficulty while in tank mode
		soundChallenge = 1; -- Overrides sound in Mythic+/Challenge Mode
		tankSoundChallenge = 2; -- Overrides sound in Mythic+/Challenge Mode while in tank mode
		soundChallengeMinimumKeyLevel = 10; -- Current code uses the Mythic+/Challenge override at or above this keystone level
		trivialLevel = 80; -- Suppresses registration at or above this level unless Trivial Mode is enabled (ignored during Timewalking)
		excludeTimewalking = true; -- Prevents the spell from being registered during Timewalking
		test = true; -- Registers only while Test Mode is enabled
		instance = 123; -- Registers the spell while the player is in this instance ID
		instances = { 123, 234 }; -- Registers the spell in any of these instance IDs
		map = 12345; -- Registers the spell while the player is in this UiMapID or any child map/subzone (0 = registers globally, any map)
		maps = { 12345, 23456 }; -- Registers the spell in any of these UiMapIDs or their child maps/subzones (0 = registers globally, any map)
		encounter = 12; -- Registers the spell during this encounter ID
		encounters = { 12, 34 }; -- Registers the spell during any of these encounter IDs
		stackSound = 1; -- Sound played whenever the aura's application count increases
		tankStackSound = 2; -- Overrides stackSound while the player is in tank mode
		stackSoundLFR = 2; -- Overrides stackSound in Looking for Raid
		tankStackSoundLFR = 2; -- Overrides stackSound in Looking for Raid while in tank mode
		stackSoundHeroic = 1; -- Overrides stackSound on Heroic difficulty
		tankStackSoundHeroic = 2; -- Overrides stackSound on Heroic difficulty while in tank mode
		stackSoundMythic = 1; -- Overrides stackSound on Mythic difficulty, falling back to stackSoundHeroic
		tankStackSoundMythic = 1; -- Overrides stackSound on Mythic difficulty while in tank mode
		stackSoundChallenge = 1; -- Overrides stackSound in Mythic+/Challenge Mode
		tankStackSoundChallenge = 2; -- Overrides stackSound in Mythic+/Challenge Mode while in tank mode
		stackSoundChallengeMinimumKeyLevel = 10; -- Current code uses the Mythic+/Challenge stackSound override at or above this keystone level

		-- Legacy Retail fields disabled in 12.0 because they depended on the combat log and other removed methods
		ignoreSelfInflicted = true; -- Ignored events caused by the player
		trivialLevelApplication = 80; -- Suppressed aura-application alerts at or above this level
		trivialPercent = 0; -- Suppressed damage below this percentage of maximum health; 0 used the global threshold
		alwaysAlert = true; -- Bypassed trivial-damage suppression
		applicationOnly = true; -- Alerted only when the aura was applied
		ignoreApplication = true; -- Ignored aura-application events
		ignorePeriodic = true; -- Ignored periodic damage and periodic missed events
		ignoreRefresh = true; -- Ignored SPELL_AURA_REFRESH events
		minimumStacks = 1; -- Suppressed alerts at or below this number of stacks
		maximumStacks = 5; -- Suppressed alerts at or above this number of stacks
		specificMobs = { 123, 234, 345 }; -- Limited the alert to these source mob IDs
		vehicle = true; -- Applied the alert to damage received by the player's vehicle
		affirmingDebuffSpellID = 12345; -- Required this debuff to be present before alerting
		negatingBuffSpellID = 12345; -- Suppressed the alert while this buff was present
		negatingDebuffSpellID = 12345; -- Suppressed the alert while this debuff was present
		negatingIgnoreTime = 1; -- Temporarily suppressed alerts after a negating aura was detected
		damageMinimum = 50000; -- Suppressed damage events below this amount
		ignoreEvent = "IgnoreSpell"; -- Suppressed the alert while this named GTFO event was active
		category = "TestSpell"; -- Associated the spell with a player-configurable ignore category
		casterOnly = true; -- Alerted only while the player was considered a caster
		meleeOnly = true; -- Alerted only while the player was considered melee
		spellType = "SPELL_AURA_REFRESH"; -- Limited processing to this combat-log event type
		soundFunction = function() -- Dynamically selected the alert sound via conditional code logic
			return 1;
		end;
	};
		
]]--

if (not GTFO.ClassicMode) then

GTFO.SpellID["46264"] = {
	--desc = "Void Zone Effect (Generic - Unknown)";
	trivialPercent = 0;
	sound = 1;
};

GTFO.SpellID["49699"] = {
	--desc = "Consumption (Generic)";
	sound = 1;
	trivialPercent = 0;
};

GTFO.SpellID["39004"] = {
	--desc = "Consumption (Generic)";
	sound = 1;
	trivialPercent = 0;
};

GTFO.SpellID["30538"] = {
	--desc = "Consumption (Generic)";
	sound = 1;
	trivialPercent = 0;
};

GTFO.SpellID["30498"] = {
	--desc = "Consumption (Generic)";
	sound = 1;
	trivialPercent = 0;
};

GTFO.SpellID["35951"] = {
	--desc = "Consumption (Generic)";
	sound = 1;
	trivialPercent = 0;
};

-- Paladin
GTFO.SpellID["81297"] = {
	--desc = "Consecration (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["204242"] = {
	--desc = "Consecration (PvP)";
	sound = 2;
};

-- Mage
GTFO.SpellID["2120"] = {
	--desc = "Flamestrike (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["10"] = {
	--desc = "Blizzard (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["42208"] = {
	--desc = "Blizzard (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["82739"] = {
	--desc = "Flame Orb (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["84721"] = {
	--desc = "Frostfire Orb (PvP)";
	trivialPercent = 0;
	sound = 2;
};

-- Warlock
GTFO.SpellID["5740"] = {
	--desc = "Rain of Fire (PvP)";
	trivialPercent = 0;
	sound = 2;
	ignoreSelfInflicted = true;
};

GTFO.SpellID["42223"] = {
	--desc = "Rain of Fire (PvP)";
	trivialPercent = 0;
	sound = 2;
	ignoreSelfInflicted = true;
};

GTFO.SpellID["5857"] = {
	--desc = "Hellfire Effect (PvP)";
	sound = 2;
	trivialPercent = 0;
	ignoreSelfInflicted = true;
};

-- Druid
GTFO.SpellID["50288"] = {
	--desc = "Starfall (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["16914"] = {
	--desc = "Hurricane (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["42231"] = {
	--desc = "Hurricane (PvP)";
	trivialPercent = 0;
	sound = 2;
};

-- Death Knight
GTFO.SpellID["43265"] = {
	--desc = "Death and Decay (PvP)";
	ignoreSelfInflicted = true;
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["52212"] = {
	--desc = "Death and Decay (PvP)";
	ignoreSelfInflicted = true;
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["68766"] = {
	--desc = "Desecration (PvP)";
	trivialPercent = 0;
	sound = 2;
};

-- Shaman
GTFO.SpellID["8187"] = {
	--desc = "Magma Totem (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["8349"] = {
	--desc = "Fire Nova (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["77478"] = {
	--desc = "Earthquake (PvP)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["20754"] = {
	--desc = "Rain of Fire (Generic)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["36808"] = {
	--desc = "Rain of Fire (Generic)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["76055"] = {
	--desc = "Flame Patch (Generic)";
	trivialPercent = 0;
	sound = 2;
};

GTFO.SpellID["13812"] = {
	--desc = "Explosive Trap (PvP)";
	sound = 2;
	trivialPercent = 0;
};

GTFO.SpellID["33239"] = {
	--desc = "Whirlwind (Generic)";
	sound = 1;
	trivialPercent = 0;
	specificMobs = { 
		18831, -- High King Maulgar - Gruul's Lair
		46944, -- Hurp'Derp, Twilight Highlands
	};
};

GTFO.SpellID["15578"] = {
	--desc = "Whirlwind";
	sound = 1;
	tankSound = 2;
	trivialPercent = 0;
	specificMobs = { 
		3975,	-- Herod - Scarlet Monastery
		24239, -- Hex Lord Malacrass - ZA
	};
};

GTFO.SpellID["114919"] = {
	--desc = "Arcing Light (PvP)";
	sound = 2;
};

end
