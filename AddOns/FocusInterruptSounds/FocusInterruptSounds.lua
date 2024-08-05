----------------------------
--      Constants         --
----------------------------

local _

local CASTING_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\casting-lv.ogg";
local CASTING_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\casting.ogg";

local LOWPRI_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\lowpri.ogg";

local CC_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\cc-lv.ogg";
local CC_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\cc.ogg";

local INTERRUPTED_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\interrupted-lv.ogg";
local INTERRUPTED_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\interrupted.ogg";

local POLYMORPH_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\sheep-lv.ogg";
local POLYMORPH_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\sheep.ogg";

local INNERVATE_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\innervate-lv.ogg";
local INNERVATE_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\innervate.ogg";

-- Don't play the same sound more than once per second
local MINIMUM_SOUND_COOLDOWN = 1.0;

local SETTING_MODE_ON = "on";
local SETTING_MODE_OFF = "off";
local SETTING_MODE_IF_FOCUS_MISSING = "iffocusmissing";

local SCHOOL_PHYSICAL	= 0x01;
local SCHOOL_HOLY	= 0x02;
local SCHOOL_FIRE	= 0x04;
local SCHOOL_NATURE	= 0x08;
local SCHOOL_FROST	= 0x10;
local SCHOOL_SHADOW	= 0x20;
local SCHOOL_ARCANE	= 0x40;
local SCHOOL_ALL	= 0x7F;

local DEFAULT_GLOBAL_OVERRIDES =
[[Mistcaller->Patty Cake
]];

local DEFAULT_BLACKLIST =
[[Constellar Designate->Starblast
Irontide Ravager->Painful Motivation
Gaze of Madness->Breed Madness
]];

local DEFAULT_LOW_PRIORITY_SPELLS =
[[; Shadowlands
323538; HoA Bolt of Power
322767; MoTS Spirit Bolt
330784; ToP Necrotic Bolt
; Dragonflight S1
152814; SBG Shadow Bolt
397888; TotJS Hydrolance
388862; AA Surge
371306; AV Arcane Bolt
377503; AV Condensed Frost
381530; NO Storm Shock
; Dragonflight S2
281420; FH Water Bolt
259092; FH Lightning Bolt
257899; FH Painful Motivation
378155; BH Earth Bolt
382474; BH Decay Surge
374706; HoI Pyretic Burst
410760; VP Wind Bolt
88959; VP Holy Smite
369674; Uld Stone Spike
272180; Undr Void Spit
; Dragonflight S3
426731; ToT Water Bolt
264024; WCM Soul Bolt
164973; EVB Dancing Thorns
168040; EVB Nature's Wrath
168092; EVB Water Bolt
400165; DIMR Epoch Bolt
418202; DIMR Temporal Blast
]];
-- 376399; ignore test
-- 392279; ignore test

local DEFAULT_PLAYER_INTERRUPT_SPELLS =
[[p89766; (pet) Axe Toss
p19647; (pet) Spell Lock
31935;  Avenger's Shield
147362; Counter Shot
2139;   Counterspell
183752; Disrupt
1766;   Kick
47528;  Mind Freeze
187707; Muzzle
6552;   Pummel
351338; Quell
96231;  Rebuke
15487;  Silence
106839; Skull Bash
78675;  Solar Beam
116705; Spear Hand Strike
57994;  Wind Shear
]];

local DEFAULT_AURA_BLACKLIST =
[[Divine Shield -> *
]];

local DEFAULT_INCOMING_CC =
[[Cyclone
Fear
Polymorph
Seduction
Hex
]];

local DEFAULT_PARTNER_CC_MAGIC =
[[Polymorph
Repentance
Seduction
]];

local DEFAULT_PARTNER_CC_POISON =
[[
]];


local DEFAULT_ARENA_PURGE =
[[Innervate
]];

local DEFAULT_PVE_PURGE =
[[; Shadowlands
317936; SoA Forsworn Doctrine
320272; ToP Spectral Transference
322433; SD Stoneskin
324776; MoTS Bramblethorn Coat
324914; MoTS Nourish the Forest
326046; MoTS Stimulate Resistance
326607; HoA Turn to Stone
327332; SoA Imbue Weapon
327655; SoA Infuse Weapon
328015; PF Wonder Grow
328288; SoA Bless Weapon
333875; DoS Death's Embrace
335141; NW Dark Shroud
341902; ToP Unholy Fervor
344739; DoS Spectral
355980; T:SoW Refraction Shield
355934; T:SoW Hard Light Barrier
349933; T:SoW Flagellation Protocol
347775; T:SoW Spam Filter
357284; T:GMBT Reinvigorate
300514; M:JY Stoneskin
301629; M:JY Enlarge
299588; M:JY Overclock
303941; M:JY Defensive Countermeasure
293930; M:WKSP Overclock
297133; M:WKSP Defensive Countermeasure
164426; ID Reckless Provocation
166335; GRD Storm Shield
227987; KZN:L Dinner Bell
228280; KZN:L Oath of Fealty
228225; KZN:L Sultry Heat
; Dragonflight
395820; VoI Frost Barrier
385063; RS Burning Ambition
373972; RS Blaze of Glory
392454; RS Burning Veins
391031; RS Tempest Barrier
198745; HoV Protective Light
386223; NO Stormshield
384686; NO Energy Surge
387596; NO Swift Wind
398151; SBG Sinister Focus
398205; SBG Incorporeal
209033; CoS Fortification
396020; TotJS Golden Barrier
389686; AV Arcane Fury
374778; AV Brilliant Scales
; Dragonflight S3
255579; AD Gilded Claws
]];

------------------------------
--      Initialization      --
------------------------------

FocusInterruptSounds = LibStub("AceAddon-3.0"):NewAddon("FocusInterruptSounds", "AceEvent-3.0", "AceConsole-3.0")

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:MapCreateOptions
--
--		Create the options file
--
function FocusInterruptSounds:MapCreateOptions()

	local soundMap = {
		[CASTING_SOUND_FILE_LOW_VOLUME] = "Pe-pew!",
		[CASTING_SOUND_FILE] = "Pe-pew! (louder)",
		[CC_SOUND_FILE_LOW_VOLUME] = "Di-di-di",
		[CC_SOUND_FILE] = "Di-di-di (louder)",
		[INNERVATE_SOUND_FILE_LOW_VOLUME] = "Bzzzt-zzt",
		[INNERVATE_SOUND_FILE] = "Bzzzt-zzt (louder)",
		[INTERRUPTED_SOUND_FILE_LOW_VOLUME] = "Ting!",
		[INTERRUPTED_SOUND_FILE] = "Ting! (louder)",
		[LOWPRI_SOUND_FILE] = "Ti.",
		[POLYMORPH_SOUND_FILE_LOW_VOLUME] = "Baaa",
		[POLYMORPH_SOUND_FILE] = "Baaa (louder)",
	};

	local onOffMap = {
		[SETTING_MODE_OFF] = "Off",
		[SETTING_MODE_ON] = "On",
	};

	local options = {
		type = "group",
		name = "FocusInterruptSounds",
		get = function(info) return FocusInterruptSounds.db.profile[ info[#info] ] end,
		set = function(info, value) FocusInterruptSounds.db.profile[ info[#info] ] = value end,
		args = {
			General = {
				order = 1,
				type = "group",
				name = "General Settings",
				desc = "General Settings",
				args = {
					intro = {
						order = 0,
						type = "description",
						name = "FocusInterruptSounds plays sounds when hostile targets cast interruptable spells. "
								.. "It also has other special sound events for PvP and PvE.  Found a bug?  Send a "
								.. "in-game mail to Corc, Horde, US-Detheroc (chances are I won't be watching "
								.. "the Ace forums).",
					},

					generalOptions = {
						order = 1,
						type = "header",
						name = "General Options",
					},

					fEnableText = {
						type = "toggle",
						name = "Enable text",
						desc = "Enable/disable chatframe text from FocusInterruptSounds.",
						order = 2,
					},
					fEnableSound = {
						type = "toggle",
						name = "Enable sound",
						desc = "Enable/disable sounds in FocusInterruptSounds.",
						order = 3,
					},
					fIgnoreMute = {
						type = "toggle",
						name = "Ignore mute",
						desc = "Ignores/respects WoW's mute setting (ctrl-n).  Only applicable if sound is enabled.",
						order = 4,
					},
					fCheckSpellAvailability = {
						type = "toggle",
						name = "Check spell availability",
						desc = "Require that the interrupt or anti-CC spell can be cast before generating a warning.",
						order = 5,
					},
					fDisableInVehicle = {
						type = "toggle",
						name = "Disable in vehicle",
						desc = "Turns off sounds while in a vehicle.",
						order = 6,
					},
					fAnnounceInterrupts = {
						type = "toggle",
						name = "Announce interrupts",
						desc = "Announce successful interrupts to Party/Raid",
						order = 7,
					},
					iMinimumCastTime = {
						type = "range",
						name = "Minimum cast time (ms)",
						desc = "Spells casting faster than this will not generate a warning.  Time interval specified in milliseconds.",
						order = 8,
						softMin = 0,
						softMax = 3000,
						min = 0,
						max = 20000,
						bigStep = 100,
					},

					---------------------------------------------------------------------------------------------------

					soundCustomization = {
						order = 100,
						type = "header",
						name = "Sound Customization",
					},

					strTargetCastingMode = {
						type = "select",
						values = {
							[SETTING_MODE_OFF] = "Off",
							[SETTING_MODE_IF_FOCUS_MISSING] = "If focus missing",
							[SETTING_MODE_ON] = "On",
						},
						name = "Trigger on target casting",
						desc = "Whether or not to play sounds when the target casts a spell",
						order = 101,
					},
					strTargetCastingSound = {
						type = "select",
						values = soundMap,
						name = "Target casting sound",
						desc = "Sound to play when the target casts a spell",
						order = 102,
					},
					strTargetLowPriSound = {
						type = "select",
						values = soundMap,
						name = "Target low-pri casting sound",
						desc = "Sound to play when the target casts a low-priority spell",
						order = 103,
					},

					strFocusCastingMode = {
						type = "select",
						values = onOffMap,
						name = "Trigger on focus casting",
						desc = "Whether or not to play sounds when the focus casts a spell",
						order = 104,
					},
					strFocusCastingSound = {
						type = "select",
						values = soundMap,
						name = "Focus casting sound",
						desc = "Sound to play when the focus casts a spell",
						order = 105,
					},
					strFocusLowPriSound = {
						type = "select",
						values = soundMap,
						name = "Focus low-pri sound",
						desc = "Sound to play when the focus casts a low-priority spell",
						order = 106,
					},

					strInterruptCelebrationMode = {
						type = "select",
						values = onOffMap,
						name = "Celebrate successful interrupts",
						desc = "Whether or not to play sounds on successful interrupt",
						order = 107,
					},
					strInterruptCelebrationSound = {
						type = "select",
						values = soundMap,
						name = "Celebration sound",
						desc = "Sound to play on successful interrupt",
						order = 108,
					},

					strPurgeMode = {
						type = "select",
						values = onOffMap,
						name = "Purge alert",
						desc = "Warn of enemy buffs that should be purged",
						order = 109,
					},
					strPurgeSound = {
						type = "select",
						values = soundMap,
						name = "Purge sound",
						desc = "Sound to play on when an enemy buff should be purged",
						order = 110,
					},

					strGlobalOverrideMode = {
						type = "select",
						values = onOffMap,
						name = "Global override warning",
						desc = "Warn if a spell in the global override list is cast",
						order = 111,
					},
					strGlobalOverrideSound = {
						type = "select",
						values = soundMap,
						name = "Global override sound",
						desc = "Sound to play when a spell in the global override list is cast",
						order = 112,
					},

					strIncomingCCMode = {
						type = "select",
						values = onOffMap,
						name = "Incoming CC warning",
						desc = "Warn of incoming CC if you have a defensive counter (e.g. Grounding Totem, Anti-Magic Shell)",
						order = 113,
					},
					strIncomingCCSound = {
						type = "select",
						values = soundMap,
						name = "Incoming CC sound",
						desc = "Sound to play on incoming CC",
						order = 114,
					},

					strPartnerCCMode = {
						type = "select",
						values = onOffMap,
						name = "Partner CC warning",
						desc = "Warn of if your partner is CC'd if you can dispel it",
						order = 115,
					},
					strPartnerCCSound = {
						type = "select",
						values = soundMap,
						name = "Partner CC sound",
						desc = "Sound to play when partner is CC'd",
						order = 116,
					},

					---------------------------------------------------------------------------------------------------

					advancedOptions = {
						order = 200,
						type = "header",
						name = "Advanced Options",
					},

					strGlobalOverrides = {
						type = "input",
						name = "Global Overrides",
						desc = "List of casters and spells should always generate a warning (even if they are not "
								.. "your target or focus), separated by a \"->\".  Use \"*\" to match any caster "
								.. "or any spell (but not both!).",
						order = 201,
						multiline = true,
						width = "double",
					},

					strBlacklist = {
						type = "input",
						name = "Caster -> Spell Blacklist",
						desc = "List of spells that should be ignored for a given caster, separated by a \"->\".  "
								.. "Use \"*\" to match any caster or any spell (but not both!).",
						order = 202,
						multiline = true,
						width = "double",
					},
					fIgnorePhysical = {
						type = "toggle",
						name = "Blacklist physical spells",
						desc = "Ignore spells classified as \"Physical.\"",
						order = 203,
					},
					fEnableBlizzardBlacklist = {
						type = "toggle",
						name = "Blizzard API blacklist",
						desc = "Ignore casts that UnitCastingInfo() classifies as uninterruptable.",
						order = 204,
					},
					strAuraBlacklist = {
						type = "input",
						name = "Aura -> Spell Blacklist",
						desc = "List of spells that should be ignored for a given aura, separated by a \"->\".  "
								.. "Use \"*\" to match any spell.",
						order = 205,
						multiline = true,
						width = "double",
					},

					strLowPrioritySpells = {
						type = "input",
						name = "Low Priority Spells",
						desc = "List of spells IDs for low priority spells. Semicolon is the comment delimeter",
						order = 206,
						multiline = true,
						width = "double",
					},

					strPlayerInterruptSpells = {
						type = "input",
						name = "Player Interrupt Spells",
						desc = "List of interrupt spells available to the player.  "
								.. "Only used if \"Check spell availability\" is enabled.",
						order = 207,
						multiline = true,
						width = "double",
					},

					strIncomingCC = {
						type = "input",
						name = "PvP Incoming CC Spells",
						desc = "List of spells that should sound a warning for incoming CC in arenas or nearby.",
						order = 208,
						multiline = true,
						width = "double",
					},
					strPartnerCC = {
						type = "input",
						name = "Arena Partner CC Debuffs",
						desc = "List of debuffs that should sound a warning if applied to your arena partner.",
						order = 209,
						multiline = true,
						width = "double",
					},

					strArenaPurge = {
						type = "input",
						name = "Arena Purge Buffs",
						desc = "List of buffs that should sound a warning when gained by an arena opponent.",
						order = 210,
						multiline = true,
						width = "double",
					},

					strPvePurgeIds = {
						type = "input",
						name = "PvE Purge Buffs",
						desc = "List of buff IDs that should be purged from NPCs.",
						order = 211,
						multiline = true,
						width = "double",
					},
				},
			},
		},
	};

	return options;
end

function FocusInterruptSounds:OnInitialize()

	local strGlobalOverrides = DEFAULT_GLOBAL_OVERRIDES;
	local strAuraBlacklist = DEFAULT_AURA_BLACKLIST;
	local strPlayerInterruptSpells = DEFAULT_PLAYER_INTERRUPT_SPELLS;
	local strIncomingCC = "";
	local strPartnerCC = "";
	local strPvePurgeIds = "";

	_, self.strClassName = UnitClass("player");

	self.fHasPurge = false;
	self.fCanDispel = false;
	self.fCanDepoison = false;
	self.tblLastSoundPlayed = {};

	if ("WARLOCK" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_SHADOW;
		self.str30YardSpellName = "Shoot";
		self.fHasPurge = true;
		self.fCanDispel = true;
	elseif ("MAGE" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_ARCANE;
		self.str30YardSpellName = "Shoot";
		self.fHasPurge = true;
	elseif ("SHAMAN" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_NATURE;
		self.strAntiCCSpellName = "Grounding Totem";
		self.str30YardSpellName = "Lightning Bolt";
		self.fHasPurge = true;
		self.fCanDepoison = true;
	elseif ("WARRIOR" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.str30YardSpellName = "Shoot";
	elseif ("ROGUE" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.strAntiCCSpellName = "Cloak of Shadows";
		self.str30YardSpellName = "Shoot";
	elseif ("PRIEST" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_SHADOW;
		self.str30YardSpellName = "Shadow Word: Pain";
		self.fHasPurge = true;
		self.fCanDispel = true;
	elseif ("HUNTER" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.strAntiCCSpellName = "Feign Death";
		self.str30YardSpellName = "Arcane Shot";
	elseif ("DRUID" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.str30YardSpellName = "Faerie Fire";
		self.fCanDepoison = true;
	elseif ("DEATHKNIGHT" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_FROST;
		self.strAntiCCSpellName = "Anti-Magic Shell";
		self.str30YardSpellName = "Strangulate";
	elseif ("PALADIN" == self.strClassName) then
		self.fCanDispel = true;
		self.fCanDepoison = true;
	elseif ("MONK" == self.strClassName) then
		self.fCanDispel = true;
		self.fCanDepoison = true;
	elseif ("DEMONHUNTER" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_SHADOW;
		self.fHasPurge = true;
	end

	-- Add additional auras for classes with physical interrupts
	if (self.iInterruptSchool == SCHOOL_PHYSICAL) then
		strAuraBlacklist = strAuraBlacklist .. "Hand of Protection -> *\n";
	end

	-- Set up incoming CC warning defaults
	if (nil ~= self.strAntiCCSpellName) then
		strIncomingCC = DEFAULT_INCOMING_CC;
	end

	-- Set up partner CC defaults
	if (self.fCanDispel) then
		strPartnerCC = strPartnerCC .. DEFAULT_PARTNER_CC_MAGIC;
	end

	if (self.fCanDepoison) then
		strPartnerCC = strPartnerCC .. DEFAULT_PARTNER_CC_POISON;
	end

	-- Set up purge defaults
	if (self.fHasPurge) then
		strPvePurgeIds = DEFAULT_PVE_PURGE;
	end

	-- Build the default settings array
	local DEFAULTS = {
		profile = {
			fEnableText = true,
			fEnableSound = true,
			fIgnoreMute = true,
			fCheckSpellAvailability = true,
			fDisableInVehicle = true,
			fAnnounceInterrupts = true,
			iMinimumCastTime = 800,

			strTargetCastingMode = SETTING_MODE_ON,
			strTargetCastingSound = CASTING_SOUND_FILE_LOW_VOLUME,
			strTargetLowPriSound = LOWPRI_SOUND_FILE,
			strFocusCastingMode = SETTING_MODE_ON,
			strFocusCastingSound = CC_SOUND_FILE_LOW_VOLUME,
			strFocusLowPriSound = LOWPRI_SOUND_FILE,

			strInterruptCelebrationMode = SETTING_MODE_ON,
			strInterruptCelebrationSound = INTERRUPTED_SOUND_FILE_LOW_VOLUME,
			strPurgeMode = SETTING_MODE_ON,
			strPurgeSound = INNERVATE_SOUND_FILE_LOW_VOLUME,
			strGlobalOverrideMode = SETTING_MODE_ON,
			strGlobalOverrideSound = CC_SOUND_FILE_LOW_VOLUME,
			strIncomingCCMode = SETTING_MODE_ON,
			strIncomingCCSound = CC_SOUND_FILE_LOW_VOLUME,
			strPartnerCCMode = SETTING_MODE_ON,
			strPartnerCCSound = POLYMORPH_SOUND_FILE_LOW_VOLUME,

			strGlobalOverrides = strGlobalOverrides,
			strBlacklist = DEFAULT_BLACKLIST,
			fIgnorePhysical = false,
			fEnableBlizzardBlacklist = true,
			strAuraBlacklist = strAuraBlacklist,
			strLowPrioritySpells = DEFAULT_LOW_PRIORITY_SPELLS,
			strPlayerInterruptSpells = strPlayerInterruptSpells,
			strIncomingCC = strIncomingCC,
			strPartnerCC = strPartnerCC,
			strArenaPurge = DEFAULT_ARENA_PURGE,
			strPvePurgeIds = strPvePurgeIds,
		}
	};
	self.db = LibStub("AceDB-3.0"):New("FocusInterruptSoundsDB", DEFAULTS, self.strClassName)

	local options = self:MapCreateOptions();
	options.args.Profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("FocusInterruptSounds", options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("FocusInterruptSounds", 640, 480)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FocusInterruptSounds", nil, nil, "General")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FocusInterruptSounds", "Profile", "FocusInterruptSounds", "Profile")
	self:RegisterChatCommand("fis", function() LibStub("AceConfigDialog-3.0"):Open("FocusInterruptSounds") end)

end


function FocusInterruptSounds:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	self:CheckAndPrintMessage("Add-on activated for the class " .. self.strClassName);
end

function FocusInterruptSounds:OnDisable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

------------------------------
--        Functions         --
------------------------------

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:CheckAndPrintMessage
--
--		Prints a message, only if the options permit it.
--
function FocusInterruptSounds:CheckAndPrintMessage(strMsg)

	if (self.db.profile.fEnableText) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7fFIS|r: " .. tostring(strMsg));
	end

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:CheckAndPlaySound
--
--		Plays a sound, only if the options permit it.
--
function FocusInterruptSounds:CheckAndPlaySound(strFile)

	if (self.db.profile.fEnableSound) then
		-- Don't play the sound if we last played it less than a second ago
		local now = GetTime();
		if (nil == self.tblLastSoundPlayed[strFile] or now - self.tblLastSoundPlayed[strFile] > MINIMUM_SOUND_COOLDOWN) then
			-- self:CheckAndPrintMessage("Last played " .. (now - (self.tblLastSoundPlayed[strFile] or 0)) .. "s");
			self.tblLastSoundPlayed[strFile] = now;

			local strChannel = "SFX";
			if (self.db.profile.fIgnoreMute) then
				strChannel = "MASTER";
			end

			PlaySoundFile(strFile, strChannel);
		else
			-- self:CheckAndPrintMessage("Sound played too recently");
		end
	end

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsSourceFocusOrTarget
--
--		Returns true if the source flags are for the target we're making sounds for.
--
function FocusInterruptSounds:FIsSourceFocusOrTarget(iSourceFlags)

	-- Filter out non-hostile sources
	if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)) then
		return false;
	end

	-- Check if the source is the target
	if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_TARGET)
			and (SETTING_MODE_ON == self.db.profile.strTargetCastingMode or
				SETTING_MODE_IF_FOCUS_MISSING == self.db.profile.strTargetCastingMode and not UnitCanAttack("player", "focus"))
	) then
		return true, true;
	end

	-- Check if the source is the focus
	if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_FOCUS) and SETTING_MODE_ON == self.db.profile.strFocusCastingMode) then
		return true, false;
	end

	return false;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:StrEscapeForRegExp
--
--		Returns the string escaped for use with LUA regular expressions.
--
function FocusInterruptSounds:StrEscapeForRegExp(str)

	-- Special characters: ^$()%.[]*+-?
	str = string.gsub(str, "%^", "%%%^");
	str = string.gsub(str, "%$", "%%%$");
	str = string.gsub(str, "%(", "%%%(");
	str = string.gsub(str, "%)", "%%%)");
	str = string.gsub(str, "%%", "%%%%");
	str = string.gsub(str, "%.", "%%%.");
	str = string.gsub(str, "%[", "%%%[");
	str = string.gsub(str, "%]", "%%%]");
	str = string.gsub(str, "%*", "%%%*");
	str = string.gsub(str, "%+", "%%%+");
	str = string.gsub(str, "%-", "%%%-");
	str = string.gsub(str, "%?", "%%%?");

	return str;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FInList
--
--		Returns true if the given element is in the given newline-delimited list.
--		Allows for ; as the line-comment delimeter in the list.
--
function FocusInterruptSounds:FInList(strElement, strList)

	--self:CheckAndPrintMessage("Looking for " .. strElement);

	return string.find("\n" .. strList .. "\n", "\n%s*" .. self:StrEscapeForRegExp(strElement) .. "%s*[\n;]");

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FInMap
--
--		Returns true if the given key and value are in the given newline-delimited list.
--
function FocusInterruptSounds:FInMap(strKey, strValue, strMap)

	local strKeyEscaped;
	local strValueEscaped;

	if (nil == strKey) then
		strKeyEscaped = ".*";
	else
		strKeyEscaped = self:StrEscapeForRegExp(strKey);
	end

	if (nil == strValue) then
		strValueEscaped = ".*";
	else
		strValueEscaped = self:StrEscapeForRegExp(strValue);
	end

	return string.find("\n" .. strMap .. "\n", "\n%s*" .. strKeyEscaped
				.. "%s*%->%s*" .. strValueEscaped .. "%s*[\n;]");

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsCasterOrSpellGlobalOverride
--
--		Returns true if the given spell (or cast+spell combo) is in the global override list.
--
function FocusInterruptSounds:FIsCasterOrSpellGlobalOverride(strMobName, iMobFlags, strSpellId, strSpellName, iSpellSchool)

	-- Is the spell in the global override?
	if (self:FInMap("*", strSpellName, self.db.profile.strGlobalOverrides)) then
		return true;
	end

	-- Only allow caster overrides for NPCs
	if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_CONTROL_NPC)) then
		-- Is the caster blacklisted?
		if (self:FInMap(strMobName, "*", self.db.profile.strGlobalOverrides)) then
			return true;
		end

		-- Is the caster+spell combo blacklisted?
		if (self:FInMap(strMobName, strSpellName, self.db.profile.strGlobalOverrides)) then
			return true;
		end
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsCasterOrSpellBlacklisted
--
--		Returns true if the given spell (or cast+spell combo) is blacklisted.
--
function FocusInterruptSounds:FIsCasterOrSpellBlacklisted(strMobName, iMobFlags, strSpellId, strSpellName, iSpellSchool)

	--- Blacklist based on UnitCastingInfo() API
	if (self.db.profile.fEnableBlizzardBlacklist or self.db.profile.iMinimumCastTime > 0) then
		local strMobId = "target";

		if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_FOCUS)) then
			strMobId = "focus";
		end

		local strSpellNameVerify, _, _, _, iEndTime, _, _, fInterruptImmune = UnitCastingInfo(strMobId);

		-- Is this a channel rather than a cast?
		if (nil == strSpellNameVerify) then
			strSpellNameVerify, _, _, _, iEndTime, _, fInterruptImmune = UnitChannelInfo(strMobId);
		end

		if (nil == strSpellNameVerify) then
			-- If the caster is no longer casting, it was probably a really fast cast (e.g. Nature's Swiftness)
			return true;
		elseif (strSpellNameVerify ~= strSpellName) then
			self:CheckAndPrintMessage("Error: UnitCastingInfo verification failed: strSpellNameVerify="
				.. strSpellNameVerify .. " strSpellName=" .. strSpellName);
		else
			if (self.db.profile.fEnableBlizzardBlacklist and fInterruptImmune) then
				return true;
			end

			if (iEndTime - GetTime() * 1000 < self.db.profile.iMinimumCastTime) then
				return true;
			end

		end
	end

	-- Blacklist physical spells
	if (self.db.profile.fIgnorePhysical and 0 ~= bit.band(iSpellSchool, SCHOOL_PHYSICAL)) then
		return true;
	end

	-- Is the spell blacklisted?
	if (self:FInMap("*", strSpellName, self.db.profile.strBlacklist)) then
		return true;
	end

	-- Only allow caster blacklists for NPCs
	if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_CONTROL_NPC)) then
		-- Is the caster blacklisted?
		if (self:FInMap(strMobName, "*", self.db.profile.strBlacklist)) then
			return true;
		end

		-- Is the caster+spell combo blacklisted?
		if (self:FInMap(strMobName, strSpellName, self.db.profile.strBlacklist)) then
			return true;
		end
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsAuraBlacklisted
--
--		Returns true if the given spell (or cast+spell combo) is blacklisted.
--
function FocusInterruptSounds:FIsAuraBlacklisted(strAura, strSpellId, strSpellName, iSpellSchool)

	-- self:CheckAndPrintMessage("id = " .. strSpellId .. "; spell name = " .. strSpellName);

	-- Is the aura blacklisted?
	if (self:FInMap(strAura, "*", self.db.profile.strAuraBlacklist)) then
		return true;
	end

	-- Is the aura+spell combo blacklisted?
	if (self:FInMap(strAura, strSpellName, self.db.profile.strAuraBlacklist)) then
		return true;
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsSpellCastStart
--
--		Returns true if the given event is the start of a spell cast.  Note that for channeled
--		spells, this is actually going to be SPELL_CAST_SUCCESS.
--
function FocusInterruptSounds:FIsSpellCastStart(strEventType, iMobFlags, strSpellId, strSpellName, iSpellSchool)

	if ("SPELL_CAST_START" == strEventType) then
		return true;
	elseif ("SPELL_CAST_SUCCESS" == strEventType) then
		local strMobId = "target";

		if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_FOCUS)) then
			strMobId = "focus";
		end

		local strSpellNameVerify, _, _, _, _, _, _, _ = UnitChannelInfo(strMobId);
		return strSpellNameVerify == strSpellName;
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsCCSpell
--
--		Returns true if the given event is the start of a CC.
--
function FocusInterruptSounds:FIsCCSpell(strSpellId, strSpellName, iSpellSchool)

	return self:FInList(strSpellName, self.db.profile.strIncomingCC);

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FHasBlacklistedAura
--
--		Returns true if the focus/target has an aura that will make the caster immune to
--		interrupts or will make the cast instant.
--
function FocusInterruptSounds:FHasBlacklistedAura(iSourceFlags, strSpellId, strSpellName, iSpellSchool)

	-- Go through recently cast buffs
	if (nil ~= self.lastInstacastSelfBuffName
		and GetTime() - self.lastInstacastSelfBuffTime < 1
		and self:FIsAuraBlacklisted(self.lastInstacastSelfBuffName, strSpellId, strSpellName, iSpellSchool)
	) then
		return true;
	end

	-- Go through the current buffs
	for i = 1, 40 do
		local strBuffName;

		if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_FOCUS)) then
			strBuffName, _, _, _, _, _ = UnitBuff("focus", i);
		elseif (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_TARGET)) then
			strBuffName, _, _, _, _, _ = UnitBuff("target", i);
		end

		if (nil ~= strBuffName and self:FIsAuraBlacklisted(strBuffName, strSpellId, strSpellName, iSpellSchool)) then
			return true;
		end
	end

	return false;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsPlayerSpellAvailable
--
--		Returns true if you can cast the given spell.
--
function FocusInterruptSounds:FIsPlayerSpellAvailable(strSpellName)

	-- Trim off any ; comments
	local iSemiColonIndex = strSpellName:find(";");
	if (nil ~= iSemiColonIndex) then
		strSpellName = strSpellName:sub(1, iSemiColonIndex - 1);
	end

	-- Is it a pet spell
	local iPetIndex = strSpellName:find("p");
	local isPetSpell = false;
	if (1 == iPetIndex) then
		isPetSpell = true;
		strSpellName = strSpellName:sub(2, #strSpellName);
	end

	-- Make sure the user wants these extra checks
	if (not self.db.profile.fCheckSpellAvailability) then
		return true;
	end
	
	-- Make sure there's a pet if this is a pet spell (for some reason, IsSpellKnown() is returning true for Felhunter spells
	-- on my rogue)
	if (isPetSpell and 0 <= C_StableInfo.GetNumActivePets()) then
		return false;
	end
	
	-- Is the spell known?
	if (nil ~= tonumber(strSpellName) and not IsSpellKnown(strSpellName, isPetSpell)) then
		return false;
	end

	-- Verify that the spell isn't on cooldown
	local tbSpellCooldown = C_Spell.GetSpellCooldown(strSpellName);
	if (nil == tbSpellCooldown or tbSpellCooldown["startTime"] ~= 0 or not tbSpellCooldown["isEnabled"]) then
		-- self:CheckAndPrintMessage(strSpellName .. " not known or on CD");
		return false;
	end

	-- self:CheckAndPrintMessage(strSpellName .. " available");
	return true;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsInterruptAvailable
--
--		Returns true if you can cast any interrupt.
--
function FocusInterruptSounds:FIsInterruptAvailable()

	-- Make sure the user wants these extra checks
	if (not self.db.profile.fCheckSpellAvailability) then
		return true;
	end

	for strSpell in string.gmatch(self.db.profile.strPlayerInterruptSpells, "[^%s][^\r\n]+[^%s]") do
		if (self:FIsPlayerSpellAvailable(strSpell)) then
			return true;
		end
	end

	return false;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:COMBAT_LOG_EVENT_UNFILTERED
--
--		Handler for combat log events.
--
function FocusInterruptSounds:COMBAT_LOG_EVENT_UNFILTERED(event)

	iTimestamp, strEventType, fHideCaster, strSourceGuid, strSourceName, iSourceFlags, iSourceFlags2, strDestGuid, strDestName, iDestFlags, iDestFlags2, varParam1, varParam2, varParam3, varParam4, varParam5, varParam6 = CombatLogGetCurrentEventInfo()

	local fHandled = false;

	-- Short circuit this processing if we're essentially disabled
	if (not self.db.profile.fEnableText and not self.db.profile.fEnableSound) then
		return
	end

	-- Track instacast buffs
	if (self:FIsSourceFocusOrTarget(iSourceFlags)
			and "SPELL_CAST_SUCCESS" == strEventType
			and self:FInMap(varParam2, nil, self.db.profile.strAuraBlacklist)
	) then
		self.lastInstacastSelfBuffName = varParam2;
		self.lastInstacastSelfBuffTime = GetTime();
	end

	-- Turn off all notifications while in a vehicle
	if (self.db.profile.fDisableInVehicle and UnitHasVehicleUI("player")) then
		return
	end

	-- Global override sounds
	if (not fHandled
			and SETTING_MODE_ON == self.db.profile.strGlobalOverrideMode
			and self:FIsSpellCastStart(strEventType, iSourceFlags, varParam1, varParam2, varParam3)
			and self:FIsCasterOrSpellGlobalOverride(strSourceName, iSourceFlags, varParam1, varParam2, varParam3)
	) then
		self:CheckAndPrintMessage(strSourceName .. " is casting |cffff4444" .. varParam2 .. "|r!");
		self:CheckAndPlaySound(self.db.profile.strGlobalOverrideSound);
		fHandled = true;
	end

	-- Your partner is sheeped, play a sound
	if (not fHandled
			and SETTING_MODE_ON == self.db.profile.strPartnerCCMode
			and 0 ~= bit.band(iDestFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY)
			and 0 ~= bit.band(iDestFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
			and "SPELL_AURA_APPLIED" == strEventType
			and self:FInList(varParam2, self.db.profile.strPartnerCC)
			and IsActiveBattlefieldArena()
	) then
		self:CheckAndPrintMessage(strDestName .. " is Sheeped!");
		self:CheckAndPlaySound(self.db.profile.strPartnerCCSound);
		fHandled = true;
	end

	-- Enemy player in an arena is innervated or PvE mob has a buff that should be purged
	if (not fHandled
			and SETTING_MODE_ON == self.db.profile.strPurgeMode
			and 0 == bit.band(iDestFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
			and "SPELL_AURA_APPLIED" == strEventType
			and ((IsActiveBattlefieldArena()
					and self:FInList(varParam2, self.db.profile.strArenaPurge))
				or 0 ~= bit.band(iDestFlags, COMBATLOG_OBJECT_CONTROL_NPC)
					and self:FInList(varParam1, self.db.profile.strPvePurgeIds))
	) then
		self:CheckAndPrintMessage(strDestName .. " has " .. varParam2 .. "!");
		self:CheckAndPlaySound(self.db.profile.strPurgeSound);
		fHandled = true;
	end

	-- Play a sound when the Target or Focus starts casting
	if (not fHandled) then
		local fIsSourceFocusOrTarget, fIsSourceTarget = self:FIsSourceFocusOrTarget(iSourceFlags);
		if (fIsSourceFocusOrTarget
			and self:FIsSpellCastStart(strEventType, iSourceFlags, varParam1, varParam2, varParam3)
			and not self:FIsCasterOrSpellBlacklisted(strSourceName, iSourceFlags, varParam1, varParam2, varParam3)
			and not self:FHasBlacklistedAura(iSourceFlags, varParam1, varParam2, varParam3)
			and self:FIsInterruptAvailable()
		) then
			self:CheckAndPrintMessage(strSourceName .. " is casting |cffff4444" .. varParam2 .. "|r!");

			local fIsLowPri = self:FInList(varParam1, self.db.profile.strLowPrioritySpells);
			local strCastingSoundFile = nil;
			if (fIsSourceTarget) then
				if (fIsLowPri) then
					strCastingSoundFile = self.db.profile.strTargetLowPriSound;
				else
					strCastingSoundFile = self.db.profile.strTargetCastingSound;
				end
			else
				if (fIsLowPri) then
					strCastingSoundFile = self.db.profile.strFocusLowPriSound;
				else
					strCastingSoundFile = self.db.profile.strFocusCastingSound;
				end
			end

			self:CheckAndPlaySound(strCastingSoundFile);
			fHandled = true;
		end
	end

	-- Play a sound when a hostile player is attempting to CC you
	if (SETTING_MODE_ON == self.db.profile.strIncomingCCMode
			and 0 == bit.band(iSourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
			and 0 == bit.band(iSourceFlags, COMBATLOG_OBJECT_CONTROL_NPC)
			and self:FIsSpellCastStart(strEventType, iSourceFlags, varParam1, varParam2, varParam3)
			and self:FIsCCSpell(varParam1, varParam2, varParam3)
	) then
		if (nil ~= self.strAntiCCSpellName
			and self:FIsPlayerSpellAvailable(self.strAntiCCSpellName)
			and (IsActiveBattlefieldArena() or 1 == IsSpellInRange(self.str30YardSpellName, strTarget))
		) then
			self:CheckAndPrintMessage(strSourceName .. " is casting CC: |cffffcc44" .. varParam2 .. "|r.");
			if (not fHandled) then
				self:CheckAndPlaySound(self.db.profile.strIncomingCCSound);
				fHandled = true;
			end
		else
			self:CheckAndPrintMessage(strSourceName .. " is casting CC: |cffffcc44" .. varParam2 .. "|r (far away/inactionable).");
		end
	end

	-- Play sound when you interrupt a hostile target
	if (not fHandled
			and "SPELL_INTERRUPT" == strEventType
			and 0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE)
			and 0 == bit.band(iDestFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
	) then
		self:CheckAndPrintMessage("Successfully interrupted |cffaaffff" .. varParam5 .. "|r.");
		if (SETTING_MODE_ON == self.db.profile.strInterruptCelebrationMode) then
			self:CheckAndPlaySound(self.db.profile.strInterruptCelebrationSound);
		end
		if (self.db.profile.fAnnounceInterrupts) then
			local strChannel = nil;
			local fInInstance, instanceType = IsInInstance();

			if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or instanceType == "pvp" or instanceType == "arena") then
				strChannel = "INSTANCE_CHAT";
			elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
				strChannel = "RAID";
			elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
				strChannel = "PARTY";
			end

			if (nil ~= strChannel) then
				SendChatMessage("[FIS] Interrupted " .. strDestName .. "'s " .. C_Spell.GetSpellLink(varParam4), strChannel);
			end
		end
		fHandled = true;
	end
end
w
