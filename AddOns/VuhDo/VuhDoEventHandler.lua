local _;
VUHDO_INTERNAL_TOGGLES = { };
local VUHDO_INTERNAL_TOGGLES = VUHDO_INTERNAL_TOGGLES;
local VUHDO_DEBUFF_ANIMATION = 0;

--local VUHDO_EVENT_COUNT = 0;
--local VUHDO_LAST_TIME_NO_EVENT = GetTime();
local VUHDO_INSTANCE = nil;

-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
VUHDO_RELOAD_UI_IS_LNF = false;

local VUHDO_DEFERRED_UPDATES = {
	-- [VUHDO_UPDATE_<HEALTH | BOUQUETS | SHIELD_BAR | HEAL_ABSORB_BAR>] = {
	--	[<update mode e.g. VUHDO_UPDATE_SHIELD>] = {
	--		<unit token> = boolean,
	--	},
	-- },
};

local VUHDO_DEFER_HEALTH = 1;
local VUHDO_DEFER_BOUQUETS = 2;
local VUHDO_DEFER_SHIELD_BAR = 3;
local VUHDO_DEFER_HEAL_ABSORB_BAR = 4;

local VUHDO_DEFERRED_UPDATE_TYPES = {
	VUHDO_DEFER_HEALTH,
	VUHDO_DEFER_BOUQUETS,
	VUHDO_DEFER_SHIELD_BAR,
	VUHDO_DEFER_HEAL_ABSORB_BAR,
};


local VUHDO_parseAddonMessage;
local VUHDO_spellcastSent;
local VUHDO_parseCombatLogEvent;
local VUHDO_updateAllOutRaidTargetButtons;
local VUHDO_updateAllRaidTargetIndices;
local VUHDO_updateDirectionFrame;
local VUHDO_updateHealth;
local VUHDO_updateManaBars;
local VUHDO_updateTargetBars;
local VUHDO_updateAllRaidBars;
local VUHDO_updateHealthBarsFor;
local VUHDO_updateAllHoTs;
local VUHDO_updateAllCyclicBouquets;
local VUHDO_updateAllDebuffIcons;
local VUHDO_updateAllClusters;
local VUHDO_aoeUpdateAll;
local VUHDO_updateBouquetsForEvent = VUHDO_updateBouquetsForEvent;
local VUHDO_getUnitZoneName;
local VUHDO_updateClusterHighlights;
local VUHDO_updateCustomDebuffTooltip;
local VUHDO_getCurrentMouseOver;
local VUHDO_UIFrameFlash_OnUpdate = function() end;

local GetTime = GetTime;
local UnitInRange = UnitInRange;
local UnitDetailedThreatSituation = UnitDetailedThreatSituation;
local UnitIsCharmed = UnitIsCharmed;
local UnitCanAttack = UnitCanAttack;
local UnitName = UnitName;
local UnitIsEnemy = UnitIsEnemy;
local GetSpellCooldown = GetSpellCooldown or VUHDO_getSpellCooldown;
local GetSpellName = C_Spell.GetSpellName;
local HasFullControl = HasFullControl;
local pairs = pairs;
local UnitThreatSituation = UnitThreatSituation;
local InCombatLockdown = InCombatLockdown;
local type = type;

local sIsHealerMode;
local sIsDirectionArrow = false;
local VuhDoGcdStatusBar;
local sHotToggleUpdateSecs = 1;
local sAggroRefreshSecs = 1;
local sRangeRefreshSecs = 1.1;
local sClusterRefreshSecs = 1.2;
local sAoeRefreshSecs = 1.3;
local sBuffsRefreshSecs;
local sParseCombatLog;
local VuhDoDirectionFrame;
local sDeferredUpdateDelegates;


local function VUHDO_eventHandlerInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];

	VUHDO_updateHealth = _G["VUHDO_updateHealth"];
	VUHDO_updateManaBars = _G["VUHDO_updateManaBars"];
	VUHDO_updateTargetBars = _G["VUHDO_updateTargetBars"];
	VUHDO_updateAllRaidBars = _G["VUHDO_updateAllRaidBars"];
	VUHDO_updateAllOutRaidTargetButtons = _G["VUHDO_updateAllOutRaidTargetButtons"];
	VUHDO_parseAddonMessage = _G["VUHDO_parseAddonMessage"];
	VUHDO_spellcastSent = _G["VUHDO_spellcastSent"];
	VUHDO_parseCombatLogEvent = _G["VUHDO_parseCombatLogEvent"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];
	VUHDO_updateAllHoTs = _G["VUHDO_updateAllHoTs"];
	VUHDO_updateAllCyclicBouquets = _G["VUHDO_updateAllCyclicBouquets"];
	VUHDO_updateAllDebuffIcons = _G["VUHDO_updateAllDebuffIcons"];
	VUHDO_updateAllRaidTargetIndices = _G["VUHDO_updateAllRaidTargetIndices"];
	VUHDO_updateAllClusters = _G["VUHDO_updateAllClusters"];
	VUHDO_aoeUpdateAll = _G["VUHDO_aoeUpdateAll"];
	VuhDoGcdStatusBar = _G["VuhDoGcdStatusBar"];
	VuhDoDirectionFrame = _G["VuhDoDirectionFrame"];
	VUHDO_updateDirectionFrame = _G["VUHDO_updateDirectionFrame"];
	VUHDO_getUnitZoneName = _G["VUHDO_getUnitZoneName"];
	VUHDO_updateClusterHighlights = _G["VUHDO_updateClusterHighlights"];
	VUHDO_updateCustomDebuffTooltip = _G["VUHDO_updateCustomDebuffTooltip"];
	VUHDO_getCurrentMouseOver = _G["VUHDO_getCurrentMouseOver"];
	VUHDO_UIFrameFlash_OnUpdate = _G["VUHDO_UIFrameFlash_OnUpdate"];

	sIsHealerMode = not VUHDO_CONFIG["THREAT"]["IS_TANK_MODE"];

	sIsDirectionArrow = VUHDO_isShowDirectionArrow();

	sHotToggleUpdateSecs = VUHDO_CONFIG["UPDATE_HOTS_MS"] * 0.00033;
	sAggroRefreshSecs = VUHDO_CONFIG["THREAT"]["AGGRO_REFRESH_MS"] * 0.001;
	sRangeRefreshSecs = VUHDO_CONFIG["RANGE_CHECK_DELAY"] * 0.001;
	sClusterRefreshSecs = VUHDO_CONFIG["CLUSTER"]["REFRESH"] * 0.001;
	sAoeRefreshSecs = VUHDO_CONFIG["AOE_ADVISOR"]["refresh"] * 0.001;
	sBuffsRefreshSecs = VUHDO_BUFF_SETTINGS["CONFIG"]["REFRESH_SECS"];

	sParseCombatLog = VUHDO_CONFIG["PARSE_COMBAT_LOG"];

	sDeferredUpdateDelegates = {
		[VUHDO_DEFER_HEALTH] = _G["VUHDO_updateHealth"],
		[VUHDO_DEFER_BOUQUETS] = _G["VUHDO_updateBouquetsForEvent"],
		[VUHDO_DEFER_SHIELD_BAR] = _G["VUHDO_updateShieldBar"],
		[VUHDO_DEFER_HEAL_ABSORB_BAR] = _G["VUHDO_updateHealAbsorbBar"],
	};

end

----------------------------------------------------

local VUHDO_VARIABLES_LOADED = false;
local VUHDO_IS_RELOAD_BUFFS = false;
local VUHDO_LOST_CONTROL = false;
local VUHDO_RELOAD_AFTER_BATTLE = false;
local VUHDO_OPTIONS_SHOW_AFTER_BATTLE = false;
local VUHDO_GCD_UPDATE = false;

local VUHDO_RELOAD_PANEL_NUM = nil;


VUHDO_TIMERS = {
	["RELOAD_UI"] = 0,
	["RELOAD_PANEL"] = 0,
	["CUSTOMIZE"] = 0,
	["CHECK_PROFILES"] = 6.2,
	["RELOAD_ZONES"] = 3.45,
	["UPDATE_CLUSTERS"] = 0,
	["REFRESH_INSPECT"] = 2.1,
	["REFRESH_TOOLTIP"] = 2.3,
	["UPDATE_AGGRO"] = 0,
	["UPDATE_RANGE"] = 1,
	["UPDATE_HOTS"] = 0.25,
	["REFRESH_TARGETS"] = 0.51,
	["RELOAD_RAID"] = 0,
	["RELOAD_ROSTER"] = 0,
	["REFRESH_DRAG"] = 0.05,
	["MIRROR_TO_MACRO"] = 8,
	["REFRESH_CUDE_TOOLTIP"] = 1,
	["UPDATE_AOE"] = 3,
	["BUFF_WATCH"] = 1,
};
local VUHDO_TIMERS = VUHDO_TIMERS;


VUHDO_CONFIG = nil;
VUHDO_PANEL_SETUP = nil;
VUHDO_SPELL_ASSIGNMENTS = nil;
VUHDO_SPELLS_KEYBOARD = nil;
VUHDO_SPELL_CONFIG = nil;

VUHDO_IS_RELOADING = false;
VUHDO_FONTS = { };
VUHDO_STATUS_BARS = { };
VUHDO_SOUNDS = { };
VUHDO_BORDERS = { };


VUHDO_MAINTANK_NAMES = { };
local VUHDO_FIRST_RELOAD_UI = false;


--
function VUHDO_isVariablesLoaded()
	return VUHDO_VARIABLES_LOADED;
end


--
function VUHDO_initBuffs()
	VUHDO_initBuffsFromSpellBook();
	VUHDO_reloadBuffPanel();
end



--
function VUHDO_initTooltipTimer()
	VUHDO_TIMERS["REFRESH_TOOLTIP"] = 2.3;
end



--
-- 3 = Tanking, all others less 100%
-- 2 = Tanking, others > 100%
-- 1 = Not Tanking, more than 100%
-- 0 = Not Tanking, less than 100%
local tInfo, tIsAggroed;
local tEmpty = {};
local function VUHDO_updateThreat(aUnit)
	tInfo = (VUHDO_RAID or tEmpty)[aUnit];
	if tInfo then
		tInfo["threat"] = UnitThreatSituation(aUnit) or 0;

		if VUHDO_INTERNAL_TOGGLES[17] then -- VUHDO_UPDATE_THREAT_LEVEL
			VUHDO_updateBouquetsForEvent(aUnit, 17); -- VUHDO_UPDATE_THREAT_LEVEL
		end

		tIsAggroed = VUHDO_INTERNAL_TOGGLES[7] and tInfo["threat"] >= 2; -- VUHDO_UPDATE_AGGRO

		if tIsAggroed ~= tInfo["aggro"] then
			tInfo["aggro"] = tIsAggroed;
			VUHDO_updateHealthBarsFor(aUnit, 7); -- VUHDO_UPDATE_AGGRO
		end
	end
end



--
function VUHDO_initAllBurstCaches()
	VUHDO_tooltipInitLocalOverrides();
	VUHDO_modelToolsInitLocalOverrides();
	VUHDO_toolboxInitLocalOverrides();
	VUHDO_guiToolboxInitLocalOverrides();
	VUHDO_vuhdoInitLocalOverrides();
	VUHDO_spellEventHandlerInitLocalOverrides();
	VUHDO_macroFactoryInitLocalOverrides();
	VUHDO_keySetupInitLocalOverrides();
	VUHDO_combatLogInitLocalOverrides();
	VUHDO_eventHandlerInitLocalOverrides();
	VUHDO_customHealthInitLocalOverrides();
	VUHDO_customManaInitLocalOverrides();
	VUHDO_customTargetInitLocalOverrides();
	VUHDO_customClustersInitLocalOverrides();
	VUHDO_panelInitLocalOverrides();
	VUHDO_panelRedrawInitLocalOverrides();
	VUHDO_panelRefreshInitLocalOverrides();
	VUHDO_roleCheckerInitLocalOverrides();
	VUHDO_sizeCalculatorInitLocalOverrides();
	VUHDO_customHotsInitLocalOverrides();
	VUHDO_customDebuffIconsInitLocalOverrides();
	VUHDO_debuffsInitLocalOverrides();
	VUHDO_healCommAdapterInitLocalOverrides();
	VUHDO_buffWatchInitLocalOverrides();
	VUHDO_clusterBuilderInitLocalOverrides();
	VUHDO_aoeAdvisorInitLocalOverrides();
	VUHDO_bouquetValidatorsInitLocalOverrides();
	VUHDO_bouquetsInitLocalOverrides();
	VUHDO_textProvidersInitLocalOverrides();
	VUHDO_textProviderHandlersInitLocalOverrides();
	VUHDO_actionEventHandlerInitLocalOverrides();
	VUHDO_directionsInitLocalOverrides();
	VUHDO_dcShieldInitLocalOverrides();
	VUHDO_shieldAbsorbInitLocalOverrides();
	VUHDO_spellTraceInitLocalOverrides();
	VUHDO_playerTargetEventHandlerInitLocalOverrides();
end



--
local function VUHDO_initOptions()
	if VuhDoNewOptionsTabbedFrame then
		VUHDO_initHotComboModels();
		VUHDO_initHotBarComboModels();
		VUHDO_initDebuffIgnoreComboModel();
		VUHDO_initBouquetComboModel();
		VUHDO_initBouquetSlotsComboModel();
		VUHDO_bouquetsUpdateDefaultColors();
	end
end



--
local function VUHDO_loadCurrentProfile()
	if not VUHDO_CONFIG then 
		return;
	end

	local tName = VUHDO_CONFIG["CURRENT_PROFILE"];

	if (tName or "") ~= "" then
		local _, tProfile = VUHDO_getProfileNamedCompressed(tName);

		if tProfile then
			if tProfile["LOCKED"] then -- Nicht laden, Einstellungen wurden ja auch nicht automat. gespeichert
				VUHDO_Msg("Profile " .. tProfile["NAME"] .. " is currently locked and has NOT been loaded.");
				return;
			end

			VUHDO_loadProfileNoInit(tName);
		else
			VUHDO_Msg("Error: Currently selected profile \"" .. tName .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	end
end



--
local function VUHDO_loadCurrentKeyLayout()

	if not VUHDO_CONFIG or not VUHDO_SPEC_LAYOUTS then
		return;
	end

	local tName = VUHDO_SPEC_LAYOUTS["selected"];

	if (tName or "") ~= "" then
		if VUHDO_SPELL_LAYOUTS and VUHDO_SPELL_LAYOUTS[tName] then
			VUHDO_activateLayoutNoInit(tName);
		else
			VUHDO_Msg("Error: Currently selected key layout \"" .. tName .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	end

end



--
local function VUHDO_loadDefaultProfile()
	if not VUHDO_CONFIG then 
		return;
	elseif ((VUHDO_CONFIG["CURRENT_PROFILE"] or "") == "") and
		((VUHDO_DEFAULT_PROFILE or "") ~= "") then
		local _, tProfile = VUHDO_getProfileNamedCompressed(VUHDO_DEFAULT_PROFILE);

		if tProfile then
			if tProfile["LOCKED"] then -- Nicht laden, Einstellungen wurden ja auch nicht automat. gespeichert
				VUHDO_Msg("Profile " .. tProfile["NAME"] .. " is currently locked and has NOT been loaded.");
				return;
			end

			VUHDO_loadProfile(VUHDO_DEFAULT_PROFILE);
		else
			VUHDO_Msg("Error: Default profile \"" .. VUHDO_DEFAULT_PROFILE .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	else
		return;
	end
end



--
local function VUHDO_loadDefaultLayout()
	if not VUHDO_SPEC_LAYOUTS then 
		return;
	elseif ((VUHDO_SPEC_LAYOUTS["selected"] or "") == "") and
		((VUHDO_DEFAULT_LAYOUT or "") ~= "") then
		if VUHDO_SPELL_LAYOUTS and VUHDO_SPELL_LAYOUTS[VUHDO_DEFAULT_LAYOUT] ~= nil then
			VUHDO_activateLayout(VUHDO_DEFAULT_LAYOUT);
		else
			VUHDO_Msg(VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 .. VUHDO_DEFAULT_LAYOUT .. VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2, 1, 0.4, 0.4);
		end
	else
		return;
	end
end



--
local tLevel = 0;
local function VUHDO_init()
	if tLevel == 0 or VUHDO_VARIABLES_LOADED then
		tLevel = 1;
		return;
	end

	VUHDO_COMBAT_LOG_TRACE = {};

	if not VUHDO_RAID then VUHDO_RAID = { }; end

	local tHasPerCharacterConfig = _G["VUHDO_CONFIG"] and true or false;

	VUHDO_loadCurrentProfile(); -- 1. Diese Reihenfolge scheint wichtig zu sein, erzeugt
	VUHDO_loadCurrentKeyLayout();

	VUHDO_loadVariables(); -- 2. umgekehrt undefiniertes Verhalten (VUHDO_CONFIG ist nil etc.)
	VUHDO_initAllBurstCaches();
	VUHDO_initDefaultProfiles();
	VUHDO_VARIABLES_LOADED = true;

	VUHDO_initPanelModels();
	VUHDO_initFromSpellbook();

	VUHDO_initBuffs();

	if not InCombatLockdown() then
		VUHDO_setIsOutOfCombat(true);
	end

	VUHDO_initDebuffs(); -- Too soon obviously => ReloadUI
	VUHDO_clearUndefinedModelEntries();
	VUHDO_registerAllBouquets(true);
	VUHDO_reloadUI(false);
	VUHDO_getAutoProfile();
	VUHDO_initCliqueSupport();

	if VuhDoNewOptionsTabbedFrame then
		VuhDoNewOptionsTabbedFrame:ClearAllPoints();
		VuhDoNewOptionsTabbedFrame:SetPoint("CENTER",  "UIParent", "CENTER",  0,  0);
	end

	VUHDO_initSharedMedia();
	VUHDO_initFuBar();
	VUHDO_initButtonFacade(VUHDO_INSTANCE);
	VUHDO_initLibSpecialization();
	--VUHDO_checkForTroublesomeAddons();
	VUHDO_initHideBlizzFrames();
	if not InCombatLockdown() then
		VUHDO_initKeyboardMacros();
	end

	VUHDO_timeReloadUI(3);
	VUHDO_aoeUpdateTalents();

	if not tHasPerCharacterConfig then
		VUHDO_loadDefaultProfile();
		VUHDO_loadDefaultLayout();
	end
end



--
local tEmptyRaid = { };
local tInfo;
function VUHDO_OnEvent(_, anEvent, anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10, anArg11, anArg12, anArg13, anArg14, anArg15, anArg16, anArg17, anArg18, anArg19)

	--VUHDO_Msg(anEvent);
	if "COMBAT_LOG_EVENT_UNFILTERED" == anEvent then
		if VUHDO_VARIABLES_LOADED then
			-- As of 8.x COMBAT_LOG_EVENT_UNFILTERED is now just an event with no arguments
			anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10, anArg11, anArg12, anArg13, anArg14, anArg15, anArg16, anArg17, anArg18, anArg19 = CombatLogGetCurrentEventInfo();

			if sParseCombatLog then
				-- SWING_DAMAGE - the amount of damage is the 12th arg
				-- ENVIRONMENTAL_DAMAGE - the amount of damage is the 13th arg
				-- for all other events with the _DAMAGE suffix the amount of damage is the 15th arg
				VUHDO_parseCombatLogEvent(anArg2, anArg8, anArg12, anArg13, anArg15);
			end

			if VUHDO_INTERNAL_TOGGLES[36] then -- VUHDO_UPDATE_SHIELD
				-- for SPELL events with _AURA suffixes the amount healed is the 16th arg
				-- for SPELL_HEAL/SPELL_PERIODIC_HEAL the amount absorbed is the 17th arg
				-- for SPELL_ABSORBED the absorb spell ID is either the 16th or 19th arg
				VUHDO_parseCombatLogShieldAbsorb(anArg2, anArg4, anArg8, anArg13, anArg16, anArg12, anArg17, anArg19);
			end

			if VUHDO_INTERNAL_TOGGLES[37] then -- VUHDO_UPDATE_SPELL_TRACE
				VUHDO_parseCombatLogSpellTrace(
					anArg2,  -- message/event
					anArg4,  -- source GUID
					anArg8,  -- dest GUID
					anArg13, -- spell name
					anArg12, -- spell ID
					anArg16  -- amount
				);
			end
		end

	elseif "UNIT_AURA" == anEvent then
		tInfo = (VUHDO_RAID or tEmptyRaid)[anArg1];
		if tInfo then
			tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(anArg1, anArg2);
			VUHDO_updateBouquetsForEvent(anArg1, 4); -- VUHDO_UPDATE_DEBUFF
		end

	elseif "UNIT_HEALTH" == anEvent then
		-- as of patch 7.1 we are seeing empty units on health related events
		if anArg1 and ((VUHDO_RAID or tEmptyRaid)[anArg1] or VUHDO_isBossUnit(anArg1)) then
 			VUHDO_updateHealth(anArg1, 2);
 		end

	elseif "UNIT_HEAL_PREDICTION" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then -- auch target, focus
			VUHDO_updateHealth(anArg1, 9); -- VUHDO_UPDATE_INC
			VUHDO_updateBouquetsForEvent(anArg1, 9); -- VUHDO_UPDATE_ALT_POWER
		end

	elseif "UNIT_POWER_UPDATE" == anEvent or "UNIT_POWER_FREQUENT" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then
			if "CHI" == anArg2 then
				if "player" == anArg1 then VUHDO_updateBouquetsForEvent("player", 35); end -- VUHDO_UPDATE_CHI
			elseif "HOLY_POWER" == anArg2 then
				if "player" == anArg1 then VUHDO_updateBouquetsForEvent("player", 31); end -- VUHDO_UPDATE_OWN_HOLY_POWER
			elseif "COMBO_POINTS" == anArg2 then
				if "player" == anArg1 then VUHDO_updateBouquetsForEvent("player", 40); end -- VUHDO_UPDATE_COMBO_POINTS
			elseif "SOUL_SHARDS" == anArg2 then
				if "player" == anArg1 then VUHDO_updateBouquetsForEvent("player", 41); end -- VUHDO_UPDATE_SOUL_SHARDS
			elseif "RUNES" == anArg2 then
				if "player" == anArg1 then VUHDO_updateBouquetsForEvent("player", 42); end -- VUHDO_UPDATE_RUNES
			elseif "ARCANE_CHARGES" == anArg2 then
				if "player" == anArg1 then VUHDO_updateBouquetsForEvent("player", 43); end -- VUHDO_UPDATE_ARCANE_CHARGES
			elseif "ALTERNATE" == anArg2 then
				VUHDO_updateBouquetsForEvent(anArg1, 30); -- VUHDO_UPDATE_ALT_POWER
			else
				VUHDO_updateManaBars(anArg1, 1);
			end
		end

	elseif "UNIT_ABSORB_AMOUNT_CHANGED" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then -- auch target, focus
			VUHDO_updateBouquetsForEvent(anArg1, 36); -- VUHDO_UPDATE_SHIELD
			VUHDO_updateShieldBar(anArg1);
		end

	elseif "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then 
			VUHDO_updateBouquetsForEvent(anArg1, 36); -- VUHDO_UPDATE_SHIELD
			VUHDO_updateHealAbsorbBar(anArg1);
		end

	elseif "UNIT_SPELLCAST_SENT" == anEvent then
		if VUHDO_VARIABLES_LOADED then VUHDO_spellcastSent(anArg1, anArg2, anArg4); end

	elseif "UNIT_SPELLCAST_START" == anEvent or "UNIT_SPELLCAST_DELAYED" == anEvent or "UNIT_SPELLCAST_CHANNEL_START" == anEvent or 
		"UNIT_SPELLCAST_CHANNEL_UPDATE" == anEvent then
		if VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] and anArg1 and 
			((VUHDO_CONFIG["SPELL_TRACE"]["showIncomingEnemy"] and UnitIsEnemy(anArg1, "player")) or 
				(VUHDO_CONFIG["SPELL_TRACE"]["showIncomingFriendly"] and UnitIsFriend(anArg1, "player"))) then
			VUHDO_addIncomingSpellTrace(anArg1, anArg2, anArg3);
		end

	elseif "UNIT_SPELLCAST_STOP" == anEvent or "UNIT_SPELLCAST_INTERRUPTED" == anEvent or "UNIT_SPELLCAST_FAILED" == anEvent or 
		"UNIT_SPELLCAST_FAILED_QUIET" == anEvent or "UNIT_SPELLCAST_CHANNEL_STOP" == anEvent then
		if VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] and anArg1 and 
			((VUHDO_CONFIG["SPELL_TRACE"]["showIncomingEnemy"] and UnitIsEnemy(anArg1, "player")) or 
				(VUHDO_CONFIG["SPELL_TRACE"]["showIncomingFriendly"] and UnitIsFriend(anArg1, "player"))) then
			VUHDO_removeIncomingSpellTrace(anArg1, anArg2, anArg3);
		end

	elseif "UNIT_THREAT_SITUATION_UPDATE" == anEvent then
		if VUHDO_VARIABLES_LOADED then VUHDO_updateThreat(anArg1); end

	elseif "PLAYER_REGEN_ENABLED" == anEvent then
		if VUHDO_VARIABLES_LOADED then
			for tUnit, _ in pairs(VUHDO_RAID) do
				VUHDO_updateThreat(tUnit);
			end
		end

		if VUHDO_OPTIONS_SHOW_AFTER_BATTLE and VuhDoNewOptionsTabbedFrame and not VuhDoNewOptionsTabbedFrame:IsShown() then
			VuhDoNewOptionsTabbedFrame:SetShown(true);

			VUHDO_OPTIONS_SHOW_AFTER_BATTLE = false;
		end

		VUHDO_setIsOutOfCombat(true);

	elseif "PLAYER_REGEN_DISABLED" == anEvent then
		if VuhDoNewOptionsTabbedFrame and VuhDoNewOptionsTabbedFrame:IsShown() then
			VuhDoNewOptionsTabbedFrame:SetShown(false);

			VUHDO_OPTIONS_SHOW_AFTER_BATTLE = true;
		end

		VUHDO_setIsOutOfCombat(false);

	elseif "UNIT_MAXHEALTH" == anEvent then
		-- as of patch 7.1 we are seeing empty units on health related events
		if anArg1 and (VUHDO_RAID or tEmptyRaid)[anArg1] then 
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_HEALTH_MAX);
		end

	elseif "UNIT_TARGET" == anEvent then
		if VUHDO_VARIABLES_LOADED and "player" ~= anArg1 then
			VUHDO_updateTargetBars(anArg1);
			VUHDO_updateBouquetsForEvent(anArg1, 22); -- VUHDO_UPDATE_UNIT_TARGET
			VUHDO_updatePanelVisibility();
		end

	elseif "UNIT_DISPLAYPOWER" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then
			VUHDO_updateManaBars(anArg1, 3);
		end

	elseif "UNIT_MAXPOWER" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then
			if "ALTERNATE" == anArg2 then VUHDO_updateBouquetsForEvent(anArg1, 30); -- VUHDO_UPDATE_ALT_POWER
			else VUHDO_updateManaBars(anArg1, 2); end
		end

	elseif "UNIT_PET" == anEvent then
		if VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] or not InCombatLockdown() then
			VUHDO_REMOVE_HOTS = false;
			if "player" == anArg1 then VUHDO_quickRaidReload();
			else VUHDO_normalRaidReload(); end
		end

	elseif "UNIT_ENTERED_VEHICLE" == anEvent or "UNIT_EXITED_VEHICLE" == anEvent or "UNIT_EXITING_VEHICLE" == anEvent then
		VUHDO_REMOVE_HOTS = false;
		VUHDO_normalRaidReload();

	elseif "RAID_TARGET_UPDATE" == anEvent then
		VUHDO_TIMERS["CUSTOMIZE"] = 0.1;

 	-- INSTANCE_ENCOUNTER_ENGAGE_UNIT fires when a boss unit is added to the UI
 	-- this is essentially the equivalent of GROUP_ROSTER_UPDATE for bosses/NPCs
 	elseif "GROUP_ROSTER_UPDATE" == anEvent or "INSTANCE_ENCOUNTER_ENGAGE_UNIT" == anEvent or "UPDATE_ACTIVE_BATTLEFIELD" == anEvent then	
		--VUHDO_CURR_LAYOUT = VUHDO_SPEC_LAYOUTS["selected"];
		--VUHDO_CURRENT_PROFILE = VUHDO_CONFIG["CURRENT_PROFILE"];

		if VUHDO_FIRST_RELOAD_UI then
			VUHDO_normalRaidReload(true);
			if VUHDO_TIMERS["RELOAD_ROSTER"] < 0.4 then VUHDO_TIMERS["RELOAD_ROSTER"] = 0.6; end
		end

	elseif "PLAYER_FOCUS_CHANGED" == anEvent then
		if VUHDO_VARIABLES_LOADED then
			if VUHDO_RAID["focus"] then
				VUHDO_determineIncHeal("focus");
				VUHDO_updateHealth("focus", 9); -- VUHDO_UPDATE_INC
			end

			VUHDO_clParserSetCurrentFocus();

			if VUHDO_isModelConfigured(VUHDO_ID_FOCUS) or
				(VUHDO_isModelConfigured(VUHDO_ID_PRIVATE_TANKS) and not VUHDO_CONFIG["OMIT_FOCUS"]) then
				if UnitExists("focus") then
					VUHDO_setHealth("focus", 1); -- VUHDO_UPDATE_ALL
				else
					VUHDO_removeHots("focus");
					VUHDO_removeAllDebuffIcons("focus");
					VUHDO_resetDebuffsFor("focus");

					if VUHDO_RAID["focus"] then
						table.wipe(VUHDO_RAID["focus"]);
					end

					VUHDO_RAID["focus"] = nil;
				end

				VUHDO_updateHealthBarsFor("focus", 1); -- VUHDO_UPDATE_ALL
				VUHDO_initEventBouquetsFor("focus");
			end

			VUHDO_updateBouquetsForEvent("player", 23); -- VUHDO_UPDATE_PLAYER_FOCUS
			VUHDO_updateBouquetsForEvent("focus", 23); -- VUHDO_UPDATE_PLAYER_FOCUS

			VUHDO_updatePanelVisibility();
		end

	elseif "PARTY_MEMBER_ENABLE" == anEvent or "PARTY_MEMBER_DISABLE" == anEvent then
		VUHDO_TIMERS["CUSTOMIZE"] = 0.2;

	elseif "PLAYER_FLAGS_CHANGED" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_AFK);
			VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_AFK);
		end

	elseif "PLAYER_ENTERING_WORLD" == anEvent then
		VUHDO_init();
		VUHDO_initAddonMessages();

	elseif"UNIT_POWER_BAR_SHOW" == anEvent
	    or "UNIT_POWER_BAR_HIDE" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then
			VUHDO_RAID[anArg1]["isAltPower"] = VUHDO_isAltPowerActive(anArg1);
			VUHDO_updateBouquetsForEvent(anArg1, 30); -- VUHDO_UPDATE_ALT_POWER
		end

	elseif "LEARNED_SPELL_IN_SKILL_LINE" == anEvent or "TRAIT_CONFIG_UPDATED" == anEvent or "SPELLS_CHANGED" == anEvent then
		if VUHDO_VARIABLES_LOADED then
			VUHDO_initFromSpellbook();
			VUHDO_registerAllBouquets(false);
			VUHDO_initBuffs();
			VUHDO_initDebuffs();

			if not InCombatLockdown() then
				VUHDO_initKeyboardMacros();
				VUHDO_timeReloadUI(1);
			end

			if "SPELLS_CHANGED" == anEvent then
				-- workaround slow clients where partial spellbook is available on SPELLS_CHANGED
				C_Timer.After(3, VUHDO_initBuffs);
			end
		end

	elseif "VARIABLES_LOADED" == anEvent then
		VUHDO_init();

	elseif "UPDATE_BINDINGS" == anEvent then
		if not InCombatLockdown() and VUHDO_VARIABLES_LOADED then VUHDO_initKeyboardMacros(); end

	elseif "PLAYER_TARGET_CHANGED" == anEvent then
		if VUHDO_VARIABLES_LOADED then
			VUHDO_updatePlayerTarget();
			VUHDO_updateTargetBars("player");
			VUHDO_updateBouquetsForEvent("player", 22); -- VUHDO_UPDATE_UNIT_TARGET
			VUHDO_updateTargetBars("target");
			VUHDO_updateBouquetsForEvent("target", 22); -- VUHDO_UPDATE_UNIT_TARGET
			VUHDO_updatePanelVisibility();
		end

	elseif "CHAT_MSG_ADDON" == anEvent then
		if VUHDO_VARIABLES_LOADED then VUHDO_parseAddonMessage(anArg1, anArg2, anArg4); end

	elseif "READY_CHECK" == anEvent then
		if VUHDO_RAID then VUHDO_readyStartCheck(anArg1, anArg2); end

	elseif "READY_CHECK_CONFIRM" == anEvent then
		if VUHDO_RAID then VUHDO_readyCheckConfirm(anArg1, anArg2); end

	elseif "READY_CHECK_FINISHED" == anEvent then
		if VUHDO_RAID then VUHDO_readyCheckEnds(); end

	elseif "CVAR_UPDATE" == anEvent then
		-- Patch 10.0.0 makes setting CVars freeze the game client
		-- FIXME: also there is some issue where this event fires before bouquets have been properly decompressed
		VUHDO_IS_SFX_ENABLED = false; --tonumber(GetCVar("Sound_EnableSFX")) == 1;
		VUHDO_IS_SOUND_ERRORSPEECH_ENABLED = false; --tonumber(GetCVar("Sound_EnableErrorSpeech")) == 1;
		--if VUHDO_VARIABLES_LOADED then VUHDO_reloadUI(false); end

	elseif "INSPECT_READY" == anEvent then
		VUHDO_inspectLockRole();

	elseif "UNIT_CONNECTION" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then VUHDO_updateHealth(anArg1, VUHDO_UPDATE_DC); end

	elseif "ROLE_CHANGED_INFORM" == anEvent then
		if VUHDO_RAID_NAMES[anArg1] then VUHDO_resetTalentScan(VUHDO_RAID_NAMES[anArg1]); end

	elseif "MODIFIER_STATE_CHANGED" == anEvent then
		if VuhDoTooltip:IsShown() then VUHDO_updateTooltip(); end

	elseif "PLAYER_LOGOUT" == anEvent then
		VUHDO_compressAllBouquets();

	elseif "UNIT_NAME_UPDATE" == anEvent then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_resetNameTextCache();
			VUHDO_updateHealthBarsFor(anArg1, 7); -- VUHDO_UPDATE_AGGRO
		end

	elseif "PLAYER_EQUIPMENT_CHANGED" == anEvent then
		VUHDO_aoeUpdateSpellAverages();

	elseif "LFG_PROPOSAL_SHOW" == anEvent then
		VUHDO_buildSafeParty();

	elseif "LFG_PROPOSAL_FAILED" == anEvent then
		VUHDO_quickRaidReload();

	elseif "LFG_PROPOSAL_SUCCEEDED" == anEvent then
		VUHDO_lateRaidReload();
	--elseif("UPDATE_MACROS" == anEvent) then
		--VUHDO_timeReloadUI(0.1); -- @WARNING L�dt wg. shield macro alle 8 sec.

	elseif "UNIT_FACTION" == anEvent then
		if (VUHDO_RAID or tEmptyRaid)[anArg1] then VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_MINOR_FLAGS); end

	elseif "INCOMING_RESURRECT_CHANGED" == anEvent then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_RESURRECTION); end

	elseif "PET_BATTLE_OPENING_START" == anEvent then
		VUHDO_setPetBattle(true);

	elseif "PET_BATTLE_CLOSE" == anEvent then
		VUHDO_setPetBattle(false);

	elseif "INCOMING_SUMMON_CHANGED" == anEvent then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then 
			VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_SUMMON); 
		end
		
	elseif "UNIT_PHASE" == anEvent then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then 
			VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_PHASE); 
		end
		
	elseif "RUNE_POWER_UPDATE" == anEvent then
		VUHDO_updateBouquetsForEvent("player", 42); -- VUHDO_UPDATE_RUNES

	elseif "PLAYER_SPECIALIZATION_CHANGED" == anEvent or "ACTIVE_TALENT_GROUP_CHANGED" == anEvent then
		if VUHDO_VARIABLES_LOADED and not InCombatLockdown() then
			if "ACTIVE_TALENT_GROUP_CHANGED" == anEvent then
				anArg1 = "player";
			end

			if "player" == anArg1 then
				local tSpecNum = tostring(GetSpecialization()) or "1";
				local tBestProfile = VUHDO_getBestProfileAfterSpecChange();

				-- event sometimes fires multiple times so we must de-dupe
				if (not VUHDO_strempty(VUHDO_SPEC_LAYOUTS[tSpecNum]) and (VUHDO_SPEC_LAYOUTS["selected"] ~= VUHDO_SPEC_LAYOUTS[tSpecNum])) or 
					(not VUHDO_strempty(tBestProfile) and (VUHDO_CONFIG["CURRENT_PROFILE"] ~= tBestProfile)) then
					VUHDO_activateSpecc(tSpecNum);
				end
			end

			if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
				VUHDO_resetTalentScan(anArg1);
				VUHDO_initDebuffs(); -- Talentabh�ngige Debuff-F�higkeiten neu initialisieren.
				VUHDO_timeReloadUI(1);
			end
		end

	else
		VUHDO_Msg("Error: Unexpected event: " .. anEvent);
	end
end



--
local function VUHDO_setPanelsVisible(anIsVisible)
	if not InCombatLockdown() then
		VUHDO_CONFIG["SHOW_PANELS"] = anIsVisible;
		VUHDO_Msg(anIsVisible and VUHDO_I18N_PANELS_SHOWN or VUHDO_I18N_PANELS_HIDDEN);
		VUHDO_redrawAllPanels(false);
		VUHDO_saveCurrentProfile();
	else
		VUHDO_Msg("Not possible during combat!");
	end
end



--
local function VUHDO_printAbout()

	VUHDO_Msg("VuhDo |cffffe566['vu:du:]|r v" .. VUHDO_VERSION .. " (use /vd). Currently maintained by Ivaria@US-Hyjal in honor of Anny and our two daughters.");

end



--
local tHelpText;
function VUHDO_slashCmd(aCommand)
	local tParsedTexts = VUHDO_textParse(aCommand);
	local tCommandWord = strlower(tParsedTexts[1]);

	if strfind(tCommandWord, "opt") then
		if VuhDoNewOptionsTabbedFrame then
			if InCombatLockdown() and not VuhDoNewOptionsTabbedFrame:IsShown() then
				VUHDO_Msg("Options not available in combat!", 1, 0.4, 0.4);
			else
				VUHDO_CURR_LAYOUT = VUHDO_SPEC_LAYOUTS["selected"];
				VUHDO_CURRENT_PROFILE = VUHDO_CONFIG["CURRENT_PROFILE"];
				VUHDO_toggleMenu(VuhDoNewOptionsTabbedFrame);
			end
		else
			VUHDO_Msg(VUHDO_I18N_OPTIONS_NOT_LOADED, 1, 0.4, 0.4);
		end
	elseif tCommandWord == "pt" then
		if tParsedTexts[2] then
			local tTokens = VUHDO_splitString(tParsedTexts[2], ",");
			if "clear" == tTokens[1] then
				table.wipe(VUHDO_PLAYER_TARGETS);
				VUHDO_quickRaidReload();
			else
				for _, tName in ipairs(tTokens) do
					tName = strtrim(tName);
					if VUHDO_RAID_NAMES[tName] ~= nil and not InCombatLockdown() then
						VUHDO_PLAYER_TARGETS[tName] = true;
					end
				end
				VUHDO_quickRaidReload();
			end
		else
			local tUnit = VUHDO_RAID_NAMES[UnitName("target")];
			local tName = (VUHDO_RAID[tUnit] or {})["name"];
			if not InCombatLockdown() and tName then
				if VUHDO_PLAYER_TARGETS[tName] then VUHDO_PLAYER_TARGETS[tName] = nil;
				else VUHDO_PLAYER_TARGETS[tName] = true; end
				VUHDO_quickRaidReload();
			end
		end

	elseif tCommandWord == "load" and tParsedTexts[2] then
		local tTokens = VUHDO_splitString(tParsedTexts[2] .. (tParsedTexts[3] or ""), ",");
		if #tTokens >= 2 and not VUHDO_strempty(tTokens[2]) then
			local tName = strtrim(tTokens[2]);
			if (VUHDO_SPELL_LAYOUTS[tName] ~= nil) then
				VUHDO_activateLayout(tName);
			else
				VUHDO_Msg(VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 .. tName .. VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2, 1, 0.4, 0.4);
			end
		end
		if #tTokens >= 1 and not VUHDO_strempty(tTokens[1]) then
			VUHDO_loadProfile(strtrim(tTokens[1]));
		end
	elseif strfind(tCommandWord, "res") then
		for tPanelNum = 1, VUHDO_MAX_PANELS do
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = nil;
		end
		VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"] = {
			["x"] = 100, ["y"] = -100, ["point"] = "TOPLEFT", ["relativePoint"] = "TOPLEFT",
		};
		VUHDO_loadDefaultPanelSetup();
		VUHDO_reloadUI(false);
		VUHDO_Msg(VUHDO_I18N_PANELS_RESET);

	elseif tCommandWord == "lock" then
		VUHDO_CONFIG["LOCK_PANELS"] = not VUHDO_CONFIG["LOCK_PANELS"];
		if (VUHDO_CONFIG["LOCK_PANELS"]) then
			VUHDO_Msg(VUHDO_I18N_LOCK_PANELS_PRE .. VUHDO_I18N_LOCK_PANELS_LOCKED);
		else
			VUHDO_Msg(VUHDO_I18N_LOCK_PANELS_PRE .. VUHDO_I18N_LOCK_PANELS_UNLOCKED);
		end
		VUHDO_saveCurrentProfile();

	elseif tCommandWord == "show" then
		VUHDO_setPanelsVisible(true);

	elseif tCommandWord == "hide" then
		VUHDO_setPanelsVisible(false);

	elseif tCommandWord == "toggle" then
		VUHDO_setPanelsVisible(not VUHDO_CONFIG["SHOW_PANELS"]);

	elseif strfind(tCommandWord, "cast") or tCommandWord == "mt" then
		VUHDO_ctraBroadCastMaintanks();
		VUHDO_Msg(VUHDO_I18N_MTS_BROADCASTED);

	elseif (tCommandWord == "pron") then
		SetCVar("scriptProfile", "1");
		ReloadUI();
	elseif tCommandWord == "proff" then
		SetCVar("scriptProfile", "0");
		ReloadUI();
	elseif (strfind(tCommandWord, "chkvars")) then
		table.wipe(VUHDO_DEBUG);
		for tFName, _ in pairs(_G) do
			if(strsub(tFName, 1, 1) == "t" or strsub(tFName, 1, 1) == "s") then
				VUHDO_Msg("Emerging local variable " .. tFName);
			end
		end
	elseif strfind(tCommandWord, "mm")
		or strfind(tCommandWord, "map") then
		VUHDO_MM_SETTINGS["hide"] = VUHDO_forceBooleanValue(VUHDO_MM_SETTINGS["hide"]);
		VUHDO_MM_SETTINGS["hide"] = not VUHDO_MM_SETTINGS["hide"];

		VUHDO_initShowMinimap();

		VUHDO_Msg(VUHDO_I18N_MM_ICON .. (VUHDO_MM_SETTINGS["hide"] and VUHDO_I18N_CHAT_HIDDEN or VUHDO_I18N_CHAT_SHOWN));
	elseif strfind(tCommandWord, "compart") then
		VUHDO_MM_SETTINGS["addon_compartment_hide"] = VUHDO_forceBooleanValue(VUHDO_MM_SETTINGS["addon_compartment_hide"]);
		VUHDO_MM_SETTINGS["addon_compartment_hide"] = not VUHDO_MM_SETTINGS["addon_compartment_hide"];

		VUHDO_initShowAddOnCompartment();

		VUHDO_Msg(VUHDO_I18N_ADDON_COMPARTMENT_ICON .. 
			(VUHDO_MM_SETTINGS["addon_compartment_hide"] and VUHDO_I18N_CHAT_HIDDEN or VUHDO_I18N_CHAT_SHOWN));
	elseif tCommandWord == "ui" then
		VUHDO_reloadUI(false);
	elseif strfind(tCommandWord, "role") then
		VUHDO_Msg("Roles have been reset.");
		table.wipe(VUHDO_MANUAL_ROLES);
		VUHDO_reloadUI(false);
	--[[elseif tCommandWord == "delcude" then
		table.wipe(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]);
		table.wipe(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"]);
		collectgarbage("collect");]]

	elseif tCommandWord == "test" then
		table.wipe(VUHDO_DEBUG);
		collectgarbage("collect");

		--[[local _, tProfile = VUHDO_getProfileNamedCompressed("Buh!");
		tProfile = VUHDO_compressTable(tProfile);
		local tCompressed = VUHDO_compressStringHuffman(tProfile);
		local tUnCompressed = VUHDO_decompressIfCompressed(VUHDO_decompressStringHuffman(tCompressed));

		VUHDO_xMsg(#tProfile, #tCompressed, #tUnCompressed);]]

	elseif tCommandWord == "pool" then
		if tParsedTexts[2] then
			if tParsedTexts[2] == "on" then
				VUHDO_TABLE_POOL_PROFILE = true;

				VUHDO_Msg("Table pool profiling enabled.");
			elseif tParsedTexts[2] == "off" then
				VUHDO_TABLE_POOL_PROFILE = false;

				VUHDO_Msg("Table pool profiling disabled.");
			elseif strfind(tParsedTexts[2], "res") then
				VUHDO_resetPoolStats();

				VUHDO_Msg("Table pool statistics reset.");
			else
				VUHDO_printPoolStats();
			end
		else
			VUHDO_printPoolStats();
		end

	elseif tCommandWord == "ab" or tCommandWord == "about" then
		VUHDO_printAbout();

	elseif aCommand == "?" or strfind(tCommandWord, "help")	or aCommand == "" then
		tHelpText = (VUHDO_I18N_COMMAND_LIST or ""):gsub("\n", "|n");
		VUHDO_MsgC(tHelpText);
	else
		VUHDO_Msg(VUHDO_I18N_BAD_COMMAND, 1, 0.4, 0.4);
	end
end



--
local function VUHDO_UnRegisterEvent(aCondition, ...)
	local tEvent;
	for tCnt = 1, select("#", ...) do
		tEvent = select(tCnt, ...);

		if "UNIT_POWER_FREQUENT" == tEvent and aCondition then
			VUHDO_INSTANCE:RegisterUnitEvent(tEvent, "player");
		else
			if aCondition then
				VUHDO_INSTANCE:RegisterEvent(tEvent);
			else
				VUHDO_INSTANCE:UnregisterEvent(tEvent);
			end
		end
	end
end



--
function VUHDO_updateGlobalToggles()
	if not VUHDO_INSTANCE then return; end

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_LEVEL] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_THREAT_LEVEL);

	VUHDO_UnRegisterEvent(VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_LEVEL]
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AGGRO),
		"UNIT_THREAT_SITUATION_UPDATE"
	);

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_THREAT_PERC);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AGGRO);

	VUHDO_TIMERS["UPDATE_AGGRO"] =
		 (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO])
		 and 1 or -1;

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_NUM_CLUSTER);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MOUSEOVER_CLUSTER);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AOE_ADVICE] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AOE_ADVICE);

	if VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER]
	 or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER]
	 or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AOE_ADVICE]
	 or (VUHDO_isShowDirectionArrow() and VUHDO_CONFIG["DIRECTION"]["isDistanceText"]) then
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = 1;
		VUHDO_TIMERS["UPDATE_AOE"] = VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AOE_ADVICE] and 1 or -1;
	else
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = -1;
		VUHDO_TIMERS["UPDATE_AOE"] = -1;
	end

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MOUSEOVER);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_GROUP] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MOUSEOVER_GROUP);

	VUHDO_UnRegisterEvent(
		VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MANA)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_OTHER_POWERS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ALT_POWER)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_OWN_HOLY_POWER)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_CHI)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_COMBO_POINTS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SOUL_SHARDS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_RUNES)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ARCANE_CHARGES),
		"UNIT_DISPLAYPOWER", "UNIT_MAXPOWER", "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT"
	);

	if VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_UNIT_TARGET) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = true;
		VUHDO_TIMERS["REFRESH_TARGETS"] = 1;
	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = false;
		VUHDO_TIMERS["REFRESH_TARGETS"] = -1;
	end

	VUHDO_UnRegisterEvent(VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ALT_POWER),
		"UNIT_POWER_BAR_SHOW", "UNIT_POWER_BAR_HIDE");

	VUHDO_TIMERS["REFRESH_INSPECT"] = VUHDO_CONFIG["IS_SCAN_TALENTS"] and 1 or -1

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS]
		= VUHDO_isModelConfigured(VUHDO_ID_PETS)
		or VUHDO_isModelConfigured(VUHDO_ID_SELF_PET); -- Event nicht deregistrieren => Problem mit manchen Vehikeln

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]
		= (VUHDO_isModelConfigured(VUHDO_ID_PRIVATE_TANKS) and not VUHDO_CONFIG["OMIT_TARGET"])
		or VUHDO_isModelConfigured(VUHDO_ID_TARGET);

	VUHDO_UnRegisterEvent(VUHDO_CONFIG["SHOW_INCOMING"] or VUHDO_CONFIG["SHOW_OWN_INCOMING"],
		"UNIT_HEAL_PREDICTION");

	VUHDO_UnRegisterEvent(not VUHDO_CONFIG["IS_READY_CHECK_DISABLED"],
		"READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED");

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SHIELD] =
		VUHDO_PANEL_SETUP["BAR_COLORS"]["HOTS"]["showShieldAbsorb"]
			or VUHDO_CONFIG["SHOW_SHIELD_BAR"] 
			or VUHDO_CONFIG["SHOW_HEAL_ABSORB_BAR"]
			or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SHIELD);

	VUHDO_UnRegisterEvent(VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SHIELD], "UNIT_ABSORB_AMOUNT_CHANGED");
	VUHDO_UnRegisterEvent(VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SHIELD], "UNIT_HEAL_ABSORB_AMOUNT_CHANGED");

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SPELL_TRACE] = VUHDO_CONFIG["SHOW_SPELL_TRACE"] 
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SPELL_TRACE);

	VUHDO_UnRegisterEvent(sParseCombatLog or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SPELL_TRACE], 
		"COMBAT_LOG_EVENT_UNFILTERED");
end



--
function VUHDO_loadVariables()
	_, VUHDO_PLAYER_CLASS = UnitClass("player");
	VUHDO_PLAYER_NAME = UnitName("player");

	VUHDO_loadDefaultConfig();
	VUHDO_loadSpellArray();
	VUHDO_loadDefaultPanelSetup();
	VUHDO_initBuffSettings();
	VUHDO_loadDefaultBouquets();
	VUHDO_initClassColors();
	VUHDO_initTextProviderConfig();

	VUHDO_lnfPatchFont(VuhDoOptionsTooltipText, "Text");
end



--
local tOldAggro = { };
local tOldThreat = { };
local tTarget;
local tAggroUnit;
local tThreatPerc;
local function VUHDO_updateAllAggro()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tOldAggro[tUnit] = tInfo["aggro"];
		tOldThreat[tUnit] = tInfo["threatPerc"];
		tInfo["aggro"] = false;
		tInfo["threatPerc"] = 0;
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if tInfo["connected"] and not tInfo["dead"] then
			if VUHDO_INTERNAL_TOGGLES[7] and (tInfo["threat"] or 0) >= 2 then -- VUHDO_UPDATE_AGGRO
				tInfo["aggro"] = true;
			end
			tTarget = tInfo["targetUnit"];
			if UnitIsEnemy(tUnit, tTarget) then
				if VUHDO_INTERNAL_TOGGLES[14] then -- VUHDO_UPDATE_AGGRO
					_, _, tThreatPerc = UnitDetailedThreatSituation(tUnit, tTarget);
					tInfo["threatPerc"] = tThreatPerc or 0;
				end

				tAggroUnit = VUHDO_RAID_NAMES[UnitName(tTarget .. "target")];

				if tAggroUnit then
					if VUHDO_INTERNAL_TOGGLES[14] then -- VUHDO_UPDATE_AGGRO
						_, _, tThreatPerc = UnitDetailedThreatSituation(tAggroUnit, tTarget);
						VUHDO_RAID[tAggroUnit]["threatPerc"] = tThreatPerc or 0;
					end

					if sIsHealerMode and VUHDO_INTERNAL_TOGGLES[7] then -- VUHDO_UPDATE_AGGRO
						VUHDO_RAID[tAggroUnit]["aggro"] = true;
					end
				end
			end
		else
			tInfo["aggro"] = false;
		end
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if tInfo["aggro"] ~= tOldAggro[tUnit] then
			VUHDO_updateHealthBarsFor(tUnit, 7); -- VUHDO_UPDATE_AGGRO
		end

		if tInfo["threatPerc"] ~= tOldThreat[tUnit] then
			VUHDO_updateBouquetsForEvent(tUnit, 14); -- VUHDO_UPDATE_THREAT_PERC
		end
	end
end



--
local tIsInRange, tIsCharmed;
local tIsRangeKnown, tRangeSpell, tUnitReaction;
local function VUHDO_updateAllRange()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tInfo["baseRange"] = "player" == tUnit or "pet" == tUnit or UnitInRange(tUnit);
		tInfo["visible"] = UnitIsVisible(tUnit);

		-- Check if unit is charmed
		tIsCharmed = UnitIsCharmed(tUnit) and UnitCanAttack("player", tUnit) and not tInfo["dead"];
		if tInfo["charmed"] ~= tIsCharmed then
			tInfo["charmed"] = tIsCharmed;
			VUHDO_updateHealthBarsFor(tUnit, 4); -- VUHDO_UPDATE_DEBUFF
		end

		tIsInRange = VUHDO_isInRange(tUnit);

		if tInfo["range"] ~= tIsInRange then
			tInfo["range"] = tIsInRange;
			VUHDO_updateHealthBarsFor(tUnit, 5); -- VUHDO_UPDATE_RANGE
			if sIsDirectionArrow and VUHDO_getCurrentMouseOver() == tUnit
				and (VuhDoDirectionFrame["shown"] or (not tIsInRange or VUHDO_CONFIG["DIRECTION"]["isAlways"])) then

				VUHDO_updateDirectionFrame();
			end
		end
	end

end



--
function VUHDO_normalRaidReload(anIsReloadBuffs)
	if VUHDO_isConfigPanelShowing() then return; end
	VUHDO_TIMERS["RELOAD_RAID"] = 2.3;
	if anIsReloadBuffs then VUHDO_IS_RELOAD_BUFFS = true; end
end



--
function VUHDO_quickRaidReload()
	VUHDO_TIMERS["RELOAD_RAID"] = 0.3;
end



--
function VUHDO_lateRaidReload()
	if not VUHDO_isReloadPending() then
		VUHDO_TIMERS["RELOAD_RAID"] = 5;
	end
end



--
function VUHDO_isReloadPending()
	return VUHDO_TIMERS["RELOAD_RAID"] > 0
		or VUHDO_TIMERS["RELOAD_UI"] > 0
		or VUHDO_IS_RELOADING;
end



--
function VUHDO_timeReloadUI(someSecs, anIsLnf)
	VUHDO_TIMERS["RELOAD_UI"] = someSecs;
	VUHDO_RELOAD_UI_IS_LNF = anIsLnf;
end



--
function VUHDO_timeRedrawPanel(aPanelNum, someSecs)
	VUHDO_RELOAD_PANEL_NUM = aPanelNum;
	VUHDO_TIMERS["RELOAD_PANEL"] = someSecs;
end



--
function VUHDO_setDebuffAnimation(aTimeSecs)
	VUHDO_DEBUFF_ANIMATION = aTimeSecs;
end



--
function VUHDO_initGcd()
	VUHDO_GCD_UPDATE = true;
end



--
local function VUHDO_doReloadRoster(anIsQuick)
	if not VUHDO_isConfigPanelShowing() then
		if VUHDO_IS_RELOADING then
			VUHDO_quickRaidReload();
		else
			VUHDO_rebuildTargets();

			if InCombatLockdown() then
				VUHDO_RELOAD_AFTER_BATTLE = true;

				VUHDO_IS_RELOADING = true;
				VUHDO_refreshRaidMembers();
				VUHDO_updateAllRaidBars();
				VUHDO_initAllEventBouquets();
				VUHDO_updatePanelVisibility();
				VUHDO_IS_RELOADING = false;
			else
				VUHDO_refreshUI();

				if VUHDO_IS_RELOAD_BUFFS and not anIsQuick then
					VUHDO_reloadBuffPanel();
					VUHDO_IS_RELOAD_BUFFS = false;
				end

				VUHDO_initHideBlizzRaid(); -- Scheint bei betreten eines Raids von aussen getriggert zu werden.
			end
		end

		VUHDO_initDebuffs(); -- Verz�gerung nach Taltentwechsel-Spell?
	end
end



--
local sTimerDelta;
local function VUHDO_setTimerDelta(aTimeDelta)
	sTimerDelta = aTimeDelta;
end



--
local function VUHDO_checkResetTimer(aTimerName, aNextTick)
	if VUHDO_TIMERS[aTimerName] > 0 then
		VUHDO_TIMERS[aTimerName] = VUHDO_TIMERS[aTimerName] - sTimerDelta;
		if VUHDO_TIMERS[aTimerName] <= 0 then
			VUHDO_TIMERS[aTimerName] = aNextTick;
			return true;
		end
	end

	return false;
end


--
local function VUHDO_checkTimer(aTimerName)
	if VUHDO_TIMERS[aTimerName] > 0 then
		VUHDO_TIMERS[aTimerName] = VUHDO_TIMERS[aTimerName] - sTimerDelta;
		return VUHDO_TIMERS[aTimerName] <= 0;
	end

	return false;
end



--
local tTimeDelta = 0;
local tSlowDelta = 0;
local tAutoProfile;
local tTrigger;
local tGcdStart, tGcdDuration;
local tHotDebuffToggle = 1;
function VUHDO_OnUpdate(_, aTimeDelta)
	-----------------------------------------------------
	-- These need to update very frequenly to not stutter
	-- --------------------------------------------------

	-- Update custom debuff animation
	if VUHDO_DEBUFF_ANIMATION > 0 then
		VUHDO_updateAllDebuffIcons(true);
		VUHDO_DEBUFF_ANIMATION = VUHDO_DEBUFF_ANIMATION - aTimeDelta;
	end

	-- Update GCD-Bar
	if VUHDO_GCD_UPDATE then
		tGcdStart, tGcdDuration = GetSpellCooldown(VUHDO_SPELL_ID.GLOBAL_COOLDOWN);

		if (tGcdDuration or 0) == 0 then
			VuhDoGcdStatusBar:SetValue(0);
			VUHDO_GCD_UPDATE = false;
		else
			VuhDoGcdStatusBar:SetValue((tGcdDuration - (GetTime() - tGcdStart)) / tGcdDuration);
		end
	end

	-- Direction Arrow
	if sIsDirectionArrow and VuhDoDirectionFrame["shown"] then
		VUHDO_updateDirectionFrame();
	end

	-- Own frame flash routines to avoid taints
	VUHDO_UIFrameFlash_OnUpdate(aTimeDelta);

	-- run deferred updates once per frame
	VUHDO_updateAllDeferred();


	---------------------------------------------------------
	-- From here 0.08 (80 msec) sec tick should be sufficient
	---------------------------------------------------------

	if tTimeDelta < 0.08 then
		tTimeDelta = tTimeDelta + aTimeDelta;
		tSlowDelta = tSlowDelta + aTimeDelta;
		return;
	else
		VUHDO_setTimerDelta(aTimeDelta + tTimeDelta);
		tTimeDelta = 0;
	end

	-- reload UI?
	if VUHDO_checkTimer("RELOAD_UI") then
		if VUHDO_IS_RELOADING or InCombatLockdown() then
			VUHDO_TIMERS["RELOAD_UI"] = 0.3;
		else
			if VUHDO_RELOAD_UI_IS_LNF then VUHDO_lnfReloadUI();
			else VUHDO_reloadUI(false); end
			VUHDO_initOptions();
			VUHDO_FIRST_RELOAD_UI = true;
		end
	end

	-- redraw single panel?
	if VUHDO_checkTimer("RELOAD_PANEL") then
		if VUHDO_IS_RELOADING or InCombatLockdown() then
			VUHDO_TIMERS["RELOAD_PANEL"] = 0.3;
		else
			VUHDO_PROHIBIT_REPOS = true;
			VUHDO_initAllBurstCaches();
			VUHDO_redrawPanel(VUHDO_RELOAD_PANEL_NUM);
			VUHDO_updateAllPanelBars(VUHDO_RELOAD_PANEL_NUM);
			VUHDO_buildGenericHealthBarBouquet();
			VUHDO_buildGenericTargetHealthBouquet();
			VUHDO_registerAllBouquets(false);
			VUHDO_initAllEventBouquets();
			VUHDO_PROHIBIT_REPOS = false;
		end
	end

	---------------------------------------------------
	------------------------- below only if vars loaded
	---------------------------------------------------

	if not VUHDO_VARIABLES_LOADED then return; end

	-- Reload raid roster?
	if VUHDO_checkTimer("RELOAD_RAID") then VUHDO_doReloadRoster(false); end
	-- Quick update after raid roster change?
	if VUHDO_checkTimer("RELOAD_ROSTER") then VUHDO_doReloadRoster(true); end

	-- refresh HoTs, cyclic bouquets and customs debuffs?
	if VUHDO_checkResetTimer("UPDATE_HOTS", sHotToggleUpdateSecs) then
		if tHotDebuffToggle == 1 then
			VUHDO_updateAllHoTs();
			
			if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
				VUHDO_updateClusterHighlights();
			end

			if VUHDO_INTERNAL_TOGGLES[37] then -- VUHDO_UPDATE_SPELL_TRACE
				VUHDO_updateSpellTrace();
			end
		elseif tHotDebuffToggle == 2 then
			VUHDO_updateAllCyclicBouquets(false);
		else
			VUHDO_updateAllDebuffIcons(false);

			-- Reload after player gained control
			if not HasFullControl() then
				VUHDO_LOST_CONTROL = true;
			else
				if VUHDO_LOST_CONTROL then
					if VUHDO_TIMERS["RELOAD_RAID"] <= 0 then
						VUHDO_TIMERS["CUSTOMIZE"] = 0.3;
					end
					VUHDO_LOST_CONTROL = false;
				end
			end
		end

		if tHotDebuffToggle > 2 then 
			tHotDebuffToggle = 1;
		else 
			tHotDebuffToggle = tHotDebuffToggle + 1;
		end
	end

	-- track dragged panel coords
	if VUHDO_DRAG_PANEL and VUHDO_checkResetTimer("REFRESH_DRAG", 0.05) then
		VUHDO_refreshDragTarget(VUHDO_DRAG_PANEL);
	end

	-- Set Button colors without repositioning
	if VUHDO_checkTimer("CUSTOMIZE") then
		VUHDO_updateAllRaidTargetIndices();
		VUHDO_updateAllRaidBars();
		VUHDO_initAllEventBouquets();
	end

	-- Refresh Tooltip
	if VUHDO_checkResetTimer("REFRESH_TOOLTIP", 2.3) and VuhDoTooltip:IsShown() then
		VUHDO_updateTooltip();
	end

	-- Refresh custom debuff Tooltip
	if VUHDO_checkResetTimer("REFRESH_CUDE_TOOLTIP", 1) then
		VUHDO_updateCustomDebuffTooltip();
	end

	-- Refresh Buff Watch
	if VUHDO_checkResetTimer("BUFF_WATCH", sBuffsRefreshSecs) then
		VUHDO_updateBuffPanel();
	end

	-- Refresh Inspect, check timeout
	if VUHDO_NEXT_INSPECT_UNIT ~= nil and GetTime() > VUHDO_NEXT_INSPECT_TIME_OUT then
		VUHDO_setRoleUndefined(VUHDO_NEXT_INSPECT_UNIT);
		VUHDO_NEXT_INSPECT_UNIT = nil;
	end

	-- Refresh targets not in raid
	if VUHDO_checkResetTimer("REFRESH_TARGETS", 0.51) then
		VUHDO_updateAllOutRaidTargetButtons();
	end

	-----------------------------------------------------------------------------------------

	if VUHDO_CONFIG_SHOW_RAID then return; end

	-- refresh aggro?
	if VUHDO_checkResetTimer("UPDATE_AGGRO", sAggroRefreshSecs) then VUHDO_updateAllAggro(); end
	-- refresh range?
	if VUHDO_checkResetTimer("UPDATE_RANGE", sRangeRefreshSecs) then VUHDO_updateAllRange(); end
	-- Refresh Clusters
	if VUHDO_checkResetTimer("UPDATE_CLUSTERS", sClusterRefreshSecs) then VUHDO_updateAllClusters(); end
	-- AoE advice
	if VUHDO_checkResetTimer("UPDATE_AOE", sAoeRefreshSecs) then VUHDO_aoeUpdateAll(); end

	----------------------------------------------------
	------------------------- below only very slow tasks
	----------------------------------------------------
	if tSlowDelta < 1.2 then
		tSlowDelta = tSlowDelta + aTimeDelta;
		return;
	else
		VUHDO_setTimerDelta(aTimeDelta + tSlowDelta);
		tSlowDelta = 0;
	end

	-- reload after battle
	if VUHDO_RELOAD_AFTER_BATTLE and not InCombatLockdown() then
		VUHDO_RELOAD_AFTER_BATTLE = false;

		if VUHDO_TIMERS["RELOAD_RAID"] <= 0 then
			VUHDO_quickRaidReload();
			if VUHDO_IS_RELOAD_BUFFS then
				VUHDO_reloadBuffPanel();
				VUHDO_IS_RELOAD_BUFFS = false;
			end
		end
	end

	-- automatic profiles, shield cleanup, hide generic blizz party
	if VUHDO_checkResetTimer("CHECK_PROFILES", 3.1) then
		if not InCombatLockdown() then
			tAutoProfile, tTrigger = VUHDO_getAutoProfile();
			if tAutoProfile and not VUHDO_IS_CONFIG then
				VUHDO_Msg(VUHDO_I18N_AUTO_ARRANG_1 .. tTrigger .. VUHDO_I18N_AUTO_ARRANG_2 .. "|cffffffff" .. tAutoProfile .. "|r\"");
				VUHDO_loadProfile(tAutoProfile);
			end
		end

		VUHDO_hideBlizzCompactPartyFrame();
		VUHDO_removeObsoleteShields();
	end

	-- Unit Zones
	if VUHDO_checkResetTimer("RELOAD_ZONES", 3.45) then
		for tUnit, tInfo in pairs(VUHDO_RAID) do
			tInfo["zone"], tInfo["map"] = VUHDO_getUnitZoneName(tUnit);
		end
	end

	if not VUHDO_NEXT_INSPECT_UNIT and not InCombatLockdown() and VUHDO_checkResetTimer("REFRESH_INSPECT", 2.1) then
		VUHDO_tryInspectNext();
	end

	-- Refresh d/c shield macros?
	if VUHDO_checkTimer("MIRROR_TO_MACRO") then
		if InCombatLockdown() then 
			VUHDO_TIMERS["MIRROR_TO_MACRO"] = 2;
		else 
			VUHDO_mirrorToMacro();
		end
	end
end



local VUHDO_ALL_EVENTS = {
	"VARIABLES_LOADED", "PLAYER_ENTERING_WORLD", "SPELLS_CHANGED",
	"UNIT_MAXHEALTH", "UNIT_HEALTH",  
	"UNIT_AURA",
	"UNIT_TARGET",
	"GROUP_ROSTER_UPDATE", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "UPDATE_ACTIVE_BATTLEFIELD",  
	"UNIT_PET",
	"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "UNIT_EXITING_VEHICLE",
	"CHAT_MSG_ADDON",
	"RAID_TARGET_UPDATE",
	"LEARNED_SPELL_IN_SKILL_LINE", "TRAIT_CONFIG_UPDATED",
	"PLAYER_FLAGS_CHANGED",
	"PLAYER_LOGOUT",
	"UNIT_DISPLAYPOWER", "UNIT_MAXPOWER", "UNIT_POWER_UPDATE", "RUNE_POWER_UPDATE", 
	"UNIT_SPELLCAST_SENT",
	"PARTY_MEMBER_ENABLE", "PARTY_MEMBER_DISABLE",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"UNIT_THREAT_SITUATION_UPDATE",
	"UPDATE_BINDINGS",
	"PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED",
	"PLAYER_EQUIPMENT_CHANGED",
	"READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED",
	"ROLE_CHANGED_INFORM",
	"CVAR_UPDATE",
	"INSPECT_READY",
	"MODIFIER_STATE_CHANGED",
	"UNIT_CONNECTION",
	"UNIT_HEAL_PREDICTION",
	"UNIT_POWER_BAR_SHOW","UNIT_POWER_BAR_HIDE",
	"UNIT_NAME_UPDATE",
	"LFG_PROPOSAL_SHOW", "LFG_PROPOSAL_FAILED", "LFG_PROPOSAL_SUCCEEDED",
	--"UPDATE_MACROS",
	"UNIT_FACTION",
	"INCOMING_RESURRECT_CHANGED",
	"PET_BATTLE_CLOSE", "PET_BATTLE_OPENING_START",
	"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
	"UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
	"INCOMING_SUMMON_CHANGED",
	"UNIT_PHASE",
	"PLAYER_SPECIALIZATION_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED",
	"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_CHANNEL_STOP",
};



--
function VUHDO_OnLoad(anInstance)

	local _, _, _, tTocVersion = GetBuildInfo();

	if tonumber(tTocVersion or 999999) < VUHDO_MIN_TOC_VERSION then
		VUHDO_Msg(format(VUHDO_I18N_DISABLE_BY_MIN_VERSION, VUHDO_VERSION, VUHDO_MIN_TOC_VERSION));
		return;
	elseif tonumber(tTocVersion or 0) > VUHDO_MAX_TOC_VERSION then
		VUHDO_Msg(format(VUHDO_I18N_DISABLE_BY_MAX_VERSION, VUHDO_VERSION, VUHDO_MAX_TOC_VERSION));
		return;
	end

	VUHDO_INSTANCE = anInstance;

	for _, tEvent in pairs(VUHDO_ALL_EVENTS) do
		anInstance:RegisterEvent(tEvent);
	end

	VUHDO_ALL_EVENTS = nil;

	SLASH_VUHDO1 = "/vuhdo";
	SLASH_VUHDO2 = "/vd";
	SlashCmdList["VUHDO"] = function(aMessage)
		VUHDO_slashCmd(aMessage);
	end

	SLASH_RELOADUI1 = "/rl";
	SlashCmdList["RELOADUI"] = ReloadUI;

	anInstance:SetScript("OnEvent", VUHDO_OnEvent);
	anInstance:SetScript("OnUpdate", VUHDO_OnUpdate);

	VUHDO_printAbout();

end



--
local function VUHDO_deferUpdate(aType, aUnit, aMode)

	if not aType or not aUnit or not aMode then
		return;
	end

	if not VUHDO_DEFERRED_UPDATES[aType] then
		VUHDO_DEFERRED_UPDATES[aType] = { };
	end

	if not VUHDO_DEFERRED_UPDATES[aType][aMode] then
		VUHDO_DEFERRED_UPDATES[aType][aMode] = { };
	end

	VUHDO_DEFERRED_UPDATES[aType][aMode][aUnit] = true;

	return;

end



--
function VUHDO_deferUpdateHealth(aUnit, aMode)

	VUHDO_deferUpdate(VUHDO_DEFER_HEALTH, aUnit, aMode);

end



--
function VUHDO_deferUpdateBouquets(aUnit, aMode)

	VUHDO_deferUpdate(VUHDO_DEFER_BOUQUETS, aUnit, aMode);

end



--
function VUHDO_deferUpdateShieldBar(aUnit)

	VUHDO_deferUpdate(VUHDO_DEFER_SHIELD_BAR, aUnit, 1);

end



--
function VUHDO_deferUpdateHealAbsorbBar(aUnit)

	VUHDO_deferUpdate(VUHDO_DEFER_HEAL_ABSORB_BAR, aUnit, 1);

end



--
local tDelegate;
function VUHDO_updateAllDeferred()

	for tType in pairs(VUHDO_DEFERRED_UPDATE_TYPES) do
		if VUHDO_DEFERRED_UPDATES[tType] then
			tDelegate = sDeferredUpdateDelegates[tType] or function() end;

			for tMode, tModeUnits in pairs(VUHDO_DEFERRED_UPDATES[tType]) do
				for tUnit, _ in pairs(tModeUnits) do
					tDelegate(tUnit, tMode);

					VUHDO_DEFERRED_UPDATES[tType][tMode][tUnit] = nil;
				end
			end
		end
	end

	return;

end



--
function VUHDO_getDeferredUpdates(aType)

	if not aType then
		return VUHDO_DEFERRED_UPDATES;
	end

	return VUHDO_DEFERRED_UPDATES[aType];

end
