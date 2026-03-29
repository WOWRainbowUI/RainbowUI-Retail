local _;

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;
local pairs = pairs;
local debugprofilestop = debugprofilestop;
local format = string.format;

local VUHDO_isBossUnit;
local VUHDO_isAltPowerActive;
local VUHDO_onUnitAura;
local VUHDO_onUnitAuraInference;
local VUHDO_determineAura;
local VUHDO_updateInferredAuraDisplaysForUnit;
local VUHDO_updateHealth;
local VUHDO_updateManaBars;
local VUHDO_updateBouquetsForEvent;
local VUHDO_updateShieldBar;
local VUHDO_updateHealAbsorbBar;
local VUHDO_updateUnitAggro;
local VUHDO_updateTargetBars;
local VUHDO_updatePanelVisibility;
local VUHDO_resetNameTextCache;
local VUHDO_updateHealthBarsFor;
local VUHDO_quickRaidReload;
local VUHDO_normalRaidReload;
local VUHDO_isAnyoneInterestedIn;
local VUHDO_updateHandlerOnEventMetrics;

local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_PANEL_SETUP;
local VUHDO_INTERNAL_TOGGLES;
local VUHDO_VARIABLES_LOADED;

local sUnitEventFrames = { };

local sAllUnitEventNames = {
	"UNIT_AURA",
	"UNIT_HEALTH",
	"UNIT_MAXHEALTH",
	"UNIT_CONNECTION",
	"UNIT_NAME_UPDATE",
	"UNIT_FACTION",
	"INCOMING_RESURRECT_CHANGED",
	"INCOMING_SUMMON_CHANGED",
	"UNIT_PHASE",
	"PLAYER_FLAGS_CHANGED",
	"UNIT_PET",
	"UNIT_ENTERED_VEHICLE",
	"UNIT_EXITED_VEHICLE",
	"UNIT_EXITING_VEHICLE",
	"UNIT_THREAT_SITUATION_UPDATE",
	"UNIT_DISPLAYPOWER",
	"UNIT_MAXPOWER",
	"UNIT_POWER_UPDATE",
	"UNIT_TARGET",
	"UNIT_POWER_BAR_SHOW",
	"UNIT_POWER_BAR_HIDE",
	"UNIT_HEAL_PREDICTION",
	"UNIT_ABSORB_AMOUNT_CHANGED",
	"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
};

local sPlayerPowerResourceBouquetModes = {
	["CHI"] = 35,
	["HOLY_POWER"] = 31,
	["COMBO_POINTS"] = 40,
	["SOUL_SHARDS"] = 41,
	["RUNES"] = 42,
	["ARCANE_CHARGES"] = 43,
};



--
function VUHDO_unitEventHandlerInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_INTERNAL_TOGGLES = _G["VUHDO_INTERNAL_TOGGLES"];
	VUHDO_VARIABLES_LOADED = _G["VUHDO_VARIABLES_LOADED"];

	VUHDO_isBossUnit = _G["VUHDO_isBossUnit"];
	VUHDO_isAltPowerActive = _G["VUHDO_isAltPowerActive"];
	VUHDO_onUnitAura = _G["VUHDO_onUnitAura"];
	VUHDO_onUnitAuraInference = _G["VUHDO_onUnitAuraInference"];
	VUHDO_determineAura = _G["VUHDO_determineAura"];
	VUHDO_updateInferredAuraDisplaysForUnit = _G["VUHDO_updateInferredAuraDisplaysForUnit"];
	VUHDO_updateHealth = _G["VUHDO_updateHealth"];
	VUHDO_updateManaBars = _G["VUHDO_updateManaBars"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_updateShieldBar = _G["VUHDO_updateShieldBar"];
	VUHDO_updateHealAbsorbBar = _G["VUHDO_updateHealAbsorbBar"];
	VUHDO_updateUnitAggro = _G["VUHDO_updateUnitAggro"];
	VUHDO_updateTargetBars = _G["VUHDO_updateTargetBars"];
	VUHDO_updatePanelVisibility = _G["VUHDO_updatePanelVisibility"];
	VUHDO_resetNameTextCache = _G["VUHDO_resetNameTextCache"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];
	VUHDO_quickRaidReload = _G["VUHDO_quickRaidReload"];
	VUHDO_normalRaidReload = _G["VUHDO_normalRaidReload"];
	VUHDO_isAnyoneInterestedIn = _G["VUHDO_isAnyoneInterestedIn"];
	VUHDO_updateHandlerOnEventMetrics = _G["VUHDO_updateHandlerOnEventMetrics"];

	VUHDO_updateHealth = _G["VUHDO_deferUpdateHealth"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_deferUpdateBouquetsForEvent"];
	VUHDO_updateShieldBar = _G["VUHDO_deferUpdateShieldBar"];
	VUHDO_updateHealAbsorbBar = _G["VUHDO_deferUpdateHealAbsorbBar"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_deferUpdateHealthBarsFor"];
	VUHDO_updateManaBars = _G["VUHDO_deferUpdateManaBars"];
	VUHDO_updateUnitAggro = _G["VUHDO_deferUpdateUnitAggro"];

	return;

end



--
local tUnitInfo;
local tPowerBouquetMode;
function VUHDO_dispatchUnitEvent(anEvent, anArg1, anArg2, anArg3, anArg4, anArg5)

	if "UNIT_AURA" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		tUnitInfo = VUHDO_RAID[anArg1];

		if tUnitInfo then
			VUHDO_onUnitAura(anArg1, anArg2);
			VUHDO_updateBouquetsForEvent(anArg1, 4);

			if VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AURA_INFERENCE] then
				if VUHDO_onUnitAuraInference(anArg1, anArg2) then
					VUHDO_determineAura(anArg1);

					VUHDO_updateBouquetsForEvent(anArg1, 4);

					VUHDO_updateInferredAuraDisplaysForUnit(anArg1);
				end
			end
		end

	elseif "UNIT_HEALTH" == anEvent then
		if anArg1 and ((VUHDO_RAID and VUHDO_RAID[anArg1]) or VUHDO_isBossUnit(anArg1)) then
			VUHDO_updateHealth(anArg1, 2);
		end

	elseif "UNIT_HEAL_PREDICTION" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateHealth(anArg1, 9);
			VUHDO_updateBouquetsForEvent(anArg1, 9);
		end

	elseif "UNIT_POWER_UPDATE" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			if "ALTERNATE" == anArg2 then
				VUHDO_updateBouquetsForEvent(anArg1, 30);
			else
				tPowerBouquetMode = sPlayerPowerResourceBouquetModes[anArg2];

				if tPowerBouquetMode then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", tPowerBouquetMode);
					end
				else
					VUHDO_updateManaBars(anArg1, 1);
				end
			end
		end

	elseif "UNIT_ABSORB_AMOUNT_CHANGED" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateBouquetsForEvent(anArg1, 36);

			VUHDO_updateShieldBar(anArg1);
		end

	elseif "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateBouquetsForEvent(anArg1, 36);

			VUHDO_updateHealAbsorbBar(anArg1);
		end

	elseif "UNIT_THREAT_SITUATION_UPDATE" == anEvent then
		if VUHDO_VARIABLES_LOADED then
			VUHDO_updateUnitAggro(anArg1);
		end

	elseif "UNIT_MAXHEALTH" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if anArg1 and VUHDO_RAID[anArg1] then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_HEALTH_MAX);
		end

	elseif "UNIT_TARGET" == anEvent then
		if VUHDO_VARIABLES_LOADED and "player" ~= anArg1 then
			VUHDO_updateTargetBars(anArg1);
			VUHDO_updateBouquetsForEvent(anArg1, 22);
			VUHDO_updatePanelVisibility();
		end

	elseif "UNIT_DISPLAYPOWER" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateManaBars(anArg1, 3);
		end

	elseif "UNIT_MAXPOWER" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			if "ALTERNATE" == anArg2 then
				VUHDO_updateBouquetsForEvent(anArg1, 30);
			else
				VUHDO_updateManaBars(anArg1, 2);
			end
		end

	elseif "UNIT_PET" == anEvent then
		if VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] or not InCombatLockdown() then
			VUHDO_REMOVE_HOTS = false;

			if "player" == anArg1 then
				VUHDO_quickRaidReload();
			else
				VUHDO_normalRaidReload();
			end
		end

	elseif "UNIT_ENTERED_VEHICLE" == anEvent or "UNIT_EXITED_VEHICLE" == anEvent or "UNIT_EXITING_VEHICLE" == anEvent then
		VUHDO_REMOVE_HOTS = false;

		VUHDO_normalRaidReload();

	elseif "PLAYER_FLAGS_CHANGED" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateHealth(anArg1, 6);
			VUHDO_updateBouquetsForEvent(anArg1, 6);
		end

	elseif "UNIT_POWER_BAR_SHOW" == anEvent or "UNIT_POWER_BAR_HIDE" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_RAID[anArg1]["isAltPower"] = VUHDO_isAltPowerActive(anArg1);
			VUHDO_updateBouquetsForEvent(anArg1, 30);
		end

	elseif "UNIT_CONNECTION" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_DC);
		end

	elseif "UNIT_NAME_UPDATE" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] ~= nil then
			VUHDO_resetNameTextCache();

			VUHDO_updateHealthBarsFor(anArg1, 7);
		end

	elseif "UNIT_FACTION" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] then
			VUHDO_updateBouquetsForEvent(anArg1, 34);
		end

	elseif "INCOMING_RESURRECT_CHANGED" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] ~= nil then
			VUHDO_updateBouquetsForEvent(anArg1, 25);
		end

	elseif "INCOMING_SUMMON_CHANGED" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] ~= nil then
			VUHDO_updateBouquetsForEvent(anArg1, 38);
		end

	elseif "UNIT_PHASE" == anEvent then
		if not VUHDO_RAID then
			return;
		end

		if VUHDO_RAID[anArg1] ~= nil then
			VUHDO_updateBouquetsForEvent(anArg1, 39);
		end

	end

	return;

end



--
local tUnitEventStartTime;
local tUnitEventDuration;
local function VUHDO_runProfiledUnitDispatch(anEvent, anArg1, anArg2, anArg3, anArg4, anArg5)

	if VUHDO_HANDLER_PROFILING_ENABLED then
		tUnitEventStartTime = debugprofilestop();
	end

	VUHDO_dispatchUnitEvent(anEvent, anArg1, anArg2, anArg3, anArg4, anArg5);

	if VUHDO_HANDLER_PROFILING_ENABLED then
		tUnitEventDuration = (debugprofilestop() - tUnitEventStartTime) * 1000;

		VUHDO_updateHandlerOnEventMetrics(anEvent, tUnitEventDuration, anArg1, anArg2, anArg3, anArg4, anArg5);
	end

	return;

end



--
function VUHDO_onUnitEvent(aFrame, anEvent, anArg1, anArg2, anArg3, anArg4, anArg5)

	VUHDO_runProfiledUnitDispatch(anEvent, anArg1, anArg2, anArg3, anArg4, anArg5);

	return;

end



--
local function VUHDO_getPowerEventsInterest()

	return VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MANA)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_OTHER_POWERS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ALT_POWER)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_OWN_HOLY_POWER)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_CHI)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_COMBO_POINTS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SOUL_SHARDS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_RUNES)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ARCANE_CHARGES);

end



--
local function VUHDO_getThreatEventsInterest()

	return VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_LEVEL]
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AGGRO);

end



--
local function VUHDO_getShieldInterest()

	return VUHDO_PANEL_SETUP["BAR_COLORS"]["HOTS"]["showShieldAbsorb"]
		or VUHDO_CONFIG["SHOW_SHIELD_BAR"]
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SHIELD);

end



--
local function VUHDO_getHealAbsorbInterest()

	return VUHDO_CONFIG["SHOW_HEAL_ABSORB_BAR"]
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SHIELD);

end



--
local tEvent;
local function VUHDO_unregisterKnownUnitEventsFromFrame(aFrame)

	for tCnt = 1, #sAllUnitEventNames do
		tEvent = sAllUnitEventNames[tCnt];

		aFrame:UnregisterEvent(tEvent);
	end

	return;

end



--
local function VUHDO_applyCoreUnitRegistrations(aFrame, aUnit)

	aFrame:RegisterUnitEvent("UNIT_AURA", aUnit);
	aFrame:RegisterUnitEvent("UNIT_HEALTH", aUnit);
	aFrame:RegisterUnitEvent("UNIT_MAXHEALTH", aUnit);
	aFrame:RegisterUnitEvent("UNIT_CONNECTION", aUnit);
	aFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", aUnit);
	aFrame:RegisterUnitEvent("UNIT_FACTION", aUnit);
	aFrame:RegisterUnitEvent("INCOMING_RESURRECT_CHANGED", aUnit);
	aFrame:RegisterUnitEvent("INCOMING_SUMMON_CHANGED", aUnit);
	aFrame:RegisterUnitEvent("UNIT_PHASE", aUnit);
	aFrame:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", aUnit);
	aFrame:RegisterUnitEvent("UNIT_PET", aUnit);
	aFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", aUnit);
	aFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", aUnit);
	aFrame:RegisterUnitEvent("UNIT_EXITING_VEHICLE", aUnit);

	if VUHDO_getThreatEventsInterest() then
		aFrame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", aUnit);
	end

	if VUHDO_getPowerEventsInterest() then
		aFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", aUnit);
		aFrame:RegisterUnitEvent("UNIT_MAXPOWER", aUnit);
		aFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", aUnit);
	end

	if VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_UNIT_TARGET) then
		aFrame:RegisterUnitEvent("UNIT_TARGET", aUnit);
	end

	if VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ALT_POWER) then
		aFrame:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", aUnit);
		aFrame:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", aUnit);
	end

	if VUHDO_CONFIG["SHOW_INCOMING"] or VUHDO_CONFIG["SHOW_OWN_INCOMING"] then
		aFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", aUnit);
	end

	if VUHDO_getShieldInterest() then
		aFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", aUnit);
	end

	if VUHDO_getHealAbsorbInterest() then
		aFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", aUnit);
	end

	return;

end



--
local tUnitEventFrame;
local function VUHDO_getOrCreateUnitEventFrame(aUnit)

	tUnitEventFrame = sUnitEventFrames[aUnit];

	if not tUnitEventFrame then
		tUnitEventFrame = CreateFrame("Frame", format("VuhDoUnitEvent_%s", aUnit), UIParent);

		tUnitEventFrame:Hide();

		sUnitEventFrames[aUnit] = tUnitEventFrame;
	end

	return tUnitEventFrame;

end



--
function VUHDO_registerUnitForEvents(aUnit)

	if not aUnit then
		return;
	end

	tUnitEventFrame = VUHDO_getOrCreateUnitEventFrame(aUnit);

	VUHDO_unregisterKnownUnitEventsFromFrame(tUnitEventFrame);
	VUHDO_applyCoreUnitRegistrations(tUnitEventFrame, aUnit);

	tUnitEventFrame:SetScript("OnEvent", VUHDO_onUnitEvent);

	return;

end



--
function VUHDO_unregisterUnitForEvents(aUnit)

	tUnitEventFrame = sUnitEventFrames[aUnit];

	if not tUnitEventFrame then
		return;
	end

	tUnitEventFrame:UnregisterAllEvents();

	tUnitEventFrame:SetScript("OnEvent", nil);

	return;

end



--
function VUHDO_unregisterAllUnitEventFrames()

	for _, tFrame in pairs(sUnitEventFrames) do
		tFrame:UnregisterAllEvents();

		tFrame:SetScript("OnEvent", nil);
	end

	return;

end



--
function VUHDO_refreshAllUnitEventRegistrations()

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_registerUnitForEvents(tUnit);
	end

	return;

end



--
function VUHDO_updateToggledUnitEvents()

	VUHDO_refreshAllUnitEventRegistrations();

	return;

end



--
function VUHDO_initUnitEventHandler()

	VUHDO_refreshAllUnitEventRegistrations();

	return;

end