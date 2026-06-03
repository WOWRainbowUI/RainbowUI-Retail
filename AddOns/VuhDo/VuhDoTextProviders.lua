local _;

local floor = floor;
local format = string.format;

local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local AbbreviateNumbers = AbbreviateNumbers;
local UnitHealthPercent = UnitHealthPercent;
local UnitPowerPercent = UnitPowerPercent;
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction;
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator;
local CurveConstants = CurveConstants;
local CreateCurve = C_CurveUtil and C_CurveUtil.CreateCurve;
local TruncateWhenZero = C_StringUtil and C_StringUtil.TruncateWhenZero;
local FloorToNearestString = C_StringUtil and C_StringUtil.FloorToNearestString;
local WrapString = C_StringUtil and C_StringUtil.WrapString;
local issecretvalue = issecretvalue;

local VUHDO_getIncHealOnUnit;
local VUHDO_getUnitOverallShieldRemain;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local sHealPredictionCalculator;
local sScaleTo10Curve;
local sScaleTo100CeilCurve;



--
function VUHDO_textProvidersInitLocalOverrides()

	VUHDO_getIncHealOnUnit = _G["VUHDO_getIncHealOnUnit"];
	VUHDO_getUnitOverallShieldRemain = _G["VUHDO_getUnitOverallShieldRemain"];

	sHealPredictionCalculator = nil;

	if sSecretsEnabled then
		sHealPredictionCalculator = CreateUnitHealPredictionCalculator();

		if sHealPredictionCalculator then
			sHealPredictionCalculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MaximumHealth);
			sHealPredictionCalculator:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.MaximumHealth);
			sHealPredictionCalculator:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MaximumHealth);
			sHealPredictionCalculator:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.Total);
			sHealPredictionCalculator:SetIncomingHealOverflowPercent(1.0);
		end

		sScaleTo10Curve = CreateCurve and CreateCurve();

		if sScaleTo10Curve then
			sScaleTo10Curve:SetType(Enum.LuaCurveType.Linear);

			sScaleTo10Curve:AddPoint(0.0, 0);
			sScaleTo10Curve:AddPoint(1.0, 10);
		end

		sScaleTo100CeilCurve = CreateCurve and CreateCurve();

		if sScaleTo100CeilCurve then
			sScaleTo100CeilCurve:SetType(Enum.LuaCurveType.Linear);

			sScaleTo100CeilCurve:AddPoint(0.0, 0.99999);
			sScaleTo100CeilCurve:AddPoint(1.0, 100.99999);
		end
	end

	return;

end



--
local VUHDO_KILO_BREAKPOINTS = {
	{
		["breakpoint"] = 10000000,
		["abbreviation"] = "M",
		["significandDivisor"] = 1000000,
		["fractionDivisor"] = 1,
		["abbreviationIsGlobal"] = false,
	},
	{
		["breakpoint"] = 1000000,
		["abbreviation"] = "M",
		["significandDivisor"] = 100000,
		["fractionDivisor"] = 10,
		["abbreviationIsGlobal"] = false,
	},
	{
		["breakpoint"] = 10000,
		["abbreviation"] = "k",
		["significandDivisor"] = 1000,
		["fractionDivisor"] = 1,
		["abbreviationIsGlobal"] = false,
	},
	{
		["breakpoint"] = 1000,
		["abbreviation"] = "k",
		["significandDivisor"] = 100,
		["fractionDivisor"] = 10,
		["abbreviationIsGlobal"] = false,
	},
	{
		["breakpoint"] = 500,
		["abbreviation"] = "k",
		["significandDivisor"] = 100,
		["fractionDivisor"] = 10,
		["abbreviationIsGlobal"] = false,
	},
};

VUHDO_KILO_OPTIONS = {
	["breakpointData"] = VUHDO_KILO_BREAKPOINTS,
};
local VUHDO_KILO_OPTIONS = VUHDO_KILO_OPTIONS;



--
local tCount;
local tMax;
local function VUHDO_secondaryPowerCalculator(anInfo, aTargetPowerType)

	if not anInfo["unit"] or not anInfo["connected"] or anInfo["dead"] then
		return 0, 0;
	end

	tCount = UnitPower(anInfo["unit"], aTargetPowerType);
	tMax = UnitPowerMax(anInfo["unit"], aTargetPowerType);

	if sSecretsEnabled and (issecretvalue(tCount) or issecretvalue(tMax)) then
		return tCount, tMax;
	end

	if not tMax or tMax <= 0 then
		return 0, 0;
	end

	return tCount, tMax;

end



--
local function VUHDO_chiCalculator(anInfo)

	return VUHDO_secondaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_CHI);

end



--
local function VUHDO_holyPowerCalculator(anInfo)

	return VUHDO_secondaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_HOLY_POWER);

end



--
local function VUHDO_comboPointsCalculator(anInfo)

	return VUHDO_secondaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_COMBO_POINTS);

end



--
local function VUHDO_soulShardsCalculator(anInfo)

	return VUHDO_secondaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_SOUL_SHARDS);

end



--
local tReadyRuneCount;
local tReadyRuneMax;
local tIsRuneReady;
local function VUHDO_runesCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] and anInfo["unit"] == "player" then
		tReadyRuneCount = 0;

		for tRuneIndex = 1, 6 do
			_, _, tIsRuneReady = GetRuneCooldown(tRuneIndex);

			tReadyRuneCount = tReadyRuneCount + (tIsRuneReady and 1 or 0);
		end

		tReadyRuneMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_RUNES);

		if not tReadyRuneMax or tReadyRuneMax <= 0 then
			return 0, 0;
		end

		return tReadyRuneCount, tReadyRuneMax;
	else
		return 0, 0;
	end

end



--
local function VUHDO_arcaneChargesCalculator(anInfo)

	return VUHDO_secondaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_ARCANE_CHARGES);

end



--
local tAmountInc;
local function VUHDO_overhealCalculator(anInfo)

	-- FIXME: UnitHealPredictionCalculator does not return overheal amount
	if sSecretsEnabled then
		return 0, nil;
	end

	if not anInfo["unit"] then
		return 0, nil;
	end

	tAmountInc = VUHDO_getIncHealOnUnit(anInfo["unit"]);

	if tAmountInc > 0 and anInfo["connected"] and not anInfo["dead"] then
		return tAmountInc - anInfo["healthmax"] + anInfo["health"], nil;
	else
		return 0, nil;
	end

end


--
local tAmountInc;
local function VUHDO_incomingHealCalculator(anInfo)

	if not anInfo["unit"] then
		return 0, nil;
	end

	if sSecretsEnabled then
		if not anInfo["connected"] or anInfo["dead"] then
			return 0, nil;
		end

		if not sHealPredictionCalculator then
			return 0, nil;
		end

		sHealPredictionCalculator:ResetPredictedValues();
		UnitGetDetailedHealPrediction(anInfo["unit"], "player", sHealPredictionCalculator);

		return sHealPredictionCalculator:GetTotalIncomingHeals(), nil;
	end

	tAmountInc = VUHDO_getIncHealOnUnit(anInfo["unit"]);

	if tAmountInc > 0 and anInfo["connected"] and not anInfo["dead"] then
		return tAmountInc, nil;
	else
		return 0, nil;
	end

end


--
local tShieldValue;
local function VUHDO_shieldAbsorbCalculator(anInfo)

	if not anInfo["unit"] then
		return 0, nil;
	end

	if sSecretsEnabled then
		if not sHealPredictionCalculator then
			return 0, nil;
		end

		sHealPredictionCalculator:ResetPredictedValues();
		UnitGetDetailedHealPrediction(anInfo["unit"], "player", sHealPredictionCalculator);

		tShieldValue = sHealPredictionCalculator:GetTotalDamageAbsorbs();

		return tShieldValue, nil;
	end

	tShieldValue = VUHDO_getUnitOverallShieldRemain(anInfo["unit"]);

	return tShieldValue, nil;

end



--
local function VUHDO_healAbsorbCalculator(anInfo)

	if not anInfo["unit"] then
		return 0, nil;
	end

	if sSecretsEnabled then
		if not sHealPredictionCalculator then
			return 0, nil;
		end

		sHealPredictionCalculator:ResetPredictedValues();
		UnitGetDetailedHealPrediction(anInfo["unit"], "player", sHealPredictionCalculator);

		return sHealPredictionCalculator:GetTotalHealAbsorbs(), nil;
	end

	return UnitGetTotalHealAbsorbs(anInfo["unit"]) or 0, nil;

end



--
local function VUHDO_manaCalculator(anInfo)

	if anInfo["power"] == nil or anInfo["powermax"] == nil then
		return 0, 0;
	end

	if sSecretsEnabled and anInfo["hasSecretPower"] then
		if anInfo["powertype"] == 0 then
			return anInfo["power"], anInfo["powermax"];
		else
			return 0, 0;
		end
	end

	if anInfo["powertype"] == 0 and anInfo["powermax"] > 0 then
		return anInfo["power"], anInfo["powermax"];
	else
		return 0, 0;
	end

end



--
local function VUHDO_primaryPowerCalculator(anInfo, aTargetPowerType)

	if anInfo["powertype"] ~= aTargetPowerType then
		return 0, 0;
	end

	if anInfo["power"] == nil or anInfo["powermax"] == nil then
		return 0, 0;
	end

	if sSecretsEnabled and anInfo["hasSecretPower"] then
		return anInfo["power"], anInfo["powermax"];
	end

	if anInfo["powermax"] <= 0 then
		return 0, 0;
	end

	return anInfo["power"], anInfo["powermax"];

end



--
local function VUHDO_rageCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_RAGE);

end



--
local function VUHDO_focusCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_FOCUS);

end



--
local function VUHDO_energyCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_ENERGY);

end



--
local function VUHDO_runicPowerCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_RUNIC_POWER);

end



--
local function VUHDO_lunarPowerCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_LUNAR_POWER);

end



--
local function VUHDO_maelstromCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_MAELSTROM);

end



--
local function VUHDO_insanityCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_INSANITY);

end



--
local function VUHDO_furyCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_FURY);

end



--
local function VUHDO_painCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_PAIN);

end



--
local function VUHDO_essenceCalculator(anInfo)

	return VUHDO_primaryPowerCalculator(anInfo, VUHDO_UNIT_POWER_ESSENCE);

end



--
local function VUHDO_allPowersCalculator(anInfo)

	if anInfo["power"] == nil or anInfo["powermax"] == nil then
		return 0, 0;
	end

	if sSecretsEnabled and anInfo["hasSecretPower"] then
		return anInfo["power"], anInfo["powermax"];
	end

	if anInfo["powermax"] <= 0 then
		return 0, 0;
	end

	return anInfo["power"], anInfo["powermax"];

end



--
local function VUHDO_threatCalculator(anInfo)

	return anInfo["threatPerc"], 100;

end


------------------------------------------------------------------



--
local function VUHDO_kiloValidator(anInfo, aValue)

	if sSecretsEnabled and issecretvalue(aValue) then
		return "%s", AbbreviateNumbers(aValue, VUHDO_KILO_OPTIONS);
	end

	if aValue >= 500 then
		return "%d", VUHDO_round(aValue * 0.001);
	end

	return "%s", "";

end


local function VUHDO_plusKiloValidator(anInfo, aValue)

	if sSecretsEnabled and issecretvalue(aValue) then
		return "%s", WrapString(AbbreviateNumbers(aValue, VUHDO_KILO_OPTIONS), "+");
	end

	if aValue >= 1000000 then
		return "+%.1fM", aValue * 0.000001;
	elseif aValue >= 500 then
		return "+%dk", VUHDO_round(aValue * 0.001);
	end

	return "%s", "";

end

--
local tIsHealth;
local tPercent;
local function VUHDO_percentValidator(anInfo, aValue, aMaxValue)

	tIsHealth = (not anInfo["powertype"] or anInfo["powertype"] == -1);

	if not tIsHealth and not issecretvalue(aMaxValue) and aMaxValue == 0 then
		return "%s", "";
	end

	if sSecretsEnabled then
		if not anInfo["unit"] then
			return "%s", "";
		end

		if tIsHealth and anInfo["hasSecretHealth"] then
			tPercent = UnitHealthPercent(anInfo["unit"], true, sScaleTo100CeilCurve);

			return "%d%%", tPercent;
		elseif not tIsHealth and anInfo["hasSecretPower"] then
			tPercent = UnitPowerPercent(anInfo["unit"], anInfo["powertype"] or 0, false, CurveConstants.ScaleTo100);

			return "%d%%", tPercent;
		elseif issecretvalue(aValue) or issecretvalue(aMaxValue) then
			return "%s", "";
		end
	end

	if aMaxValue and aMaxValue > 0 then
		return "%d%%", 100 * aValue / aMaxValue;
	end

	return "%s", "";

end

--
local function VUHDO_tenthPercentValidator(anInfo, aValue, aMaxValue)

	if sSecretsEnabled and (issecretvalue(aValue) or issecretvalue(aMaxValue)) then
		if not anInfo["unit"] then
			return "%s", "";
		end

		tPercent = UnitPowerPercent(anInfo["unit"], anInfo["powertype"] or 0, false, sScaleTo10Curve);

		return "%d", tPercent;
	end

	if aMaxValue and aMaxValue > 0 then
		return "%d", 10 * aValue / aMaxValue;
	end

	return "%s", "";

end



--
local tValueStr;
local tMaxStr;
local function VUHDO_unitOfUnitValidator(anInfo, aValue, aMaxValue)

	if sSecretsEnabled and (issecretvalue(aValue) or issecretvalue(aMaxValue)) then
		tValueStr = FloorToNearestString(aValue);
		tMaxStr = FloorToNearestString(aMaxValue);

		return "%s/%s", tValueStr, tMaxStr;
	end

	if aMaxValue and aMaxValue > 0 then
		return "%d/%d", aValue, aMaxValue;
	end

	return "%s", "";

end



--
local function VUHDO_kiloOfKiloValidator(anInfo, aValue, aMaxValue)

	if sSecretsEnabled and (issecretvalue(aValue) or issecretvalue(aMaxValue)) then
		tValueStr = AbbreviateNumbers(aValue, VUHDO_KILO_OPTIONS);
		tMaxStr = AbbreviateNumbers(aMaxValue, VUHDO_KILO_OPTIONS);

		return "%s/%s", tValueStr, tMaxStr;
	end

	if aMaxValue and aMaxValue > 0 then
		return "%d/%d", floor(aValue * 0.001), floor(aMaxValue * 0.001);
	end

	return "%s", "";

end



--
local function VUHDO_absoluteValidator(anInfo, aValue)

	if sSecretsEnabled and issecretvalue(aValue) then
		return "%s", TruncateWhenZero(aValue);
	end

	if type(aValue) == "number" and aValue > 0 then
		return "%s", aValue;
	end

	return "%s", "";

end



--
local tKiloStr;
local tPercentStr;
local function VUHDO_kiloPercentValidator(anInfo, aValue, aMaxValue)

	tKiloStr = format(VUHDO_kiloValidator(anInfo, aValue));
	tPercentStr = format(VUHDO_percentValidator(anInfo, aValue, aMaxValue));

	return "%s (%s)", tKiloStr, tPercentStr;

end



--
local function VUHDO_kiloOfKiloPercentValidator(anInfo, aValue, aMaxValue)

	tKiloStr = format(VUHDO_kiloOfKiloValidator(anInfo, aValue, aMaxValue));
	tPercentStr = format(VUHDO_percentValidator(anInfo, aValue, aMaxValue));

	return "%s (%s)", tKiloStr, tPercentStr;

end



local VUHDO_LEGACY_TEXT_PROVIDER_MIGRATION = {
	[""] = {
		["source"] = "",
		["format"] = "",
	},
	["OVERHEAL_KILO_N_K"] = {
		["source"] = "OVERHEAL",
		["format"] = "NK",
	},
	["OVERHEAL_KILO_PLUS_N_K"] = {
		["source"] = "OVERHEAL",
		["format"] = "NK_PLUS",
	},
	["INCOMING_HEAL_NK"] = {
		["source"] = "INCOMING_HEAL",
		["format"] = "NK",
	},
	["SHIELD_ABSORB_OVERALL_N_K"] = {
		["source"] = "SHIELD_ABSORB",
		["format"] = "NK",
	},
	["HEAL_ABSORB_TOTAL_N_K"] = {
		["source"] = "HEAL_ABSORB",
		["format"] = "NK",
	},
	["THREAT_PERCENT"] = {
		["source"] = "THREAT",
		["format"] = "PERCENT",
	},
	["MANA_PERCENT"] = {
		["source"] = "MANA",
		["format"] = "PERCENT",
	},
	["MANA_PERCENT_TENTH"] = {
		["source"] = "MANA",
		["format"] = "PERCENT_TENTH",
	},
	["MANA_UNIT_OF_UNIT"] = {
		["source"] = "MANA",
		["format"] = "UNIT_OF_UNIT",
	},
	["MANA_KILO_OF_KILO"] = {
		["source"] = "MANA",
		["format"] = "KILO_OF_KILO",
	},
	["MANA_N"] = {
		["source"] = "MANA",
		["format"] = "N",
	},
	["MANA_NK"] = {
		["source"] = "MANA",
		["format"] = "NK",
	},
	["CHI_N"] = {
		["source"] = "CHI",
		["format"] = "N",
	},
	["HOLY_POWER_N"] = {
		["source"] = "HOLY_POWER",
		["format"] = "N",
	},
	["COMBO_POINTS_N"] = {
		["source"] = "COMBO_POINTS",
		["format"] = "N",
	},
	["SOUL_SHARDS_N"] = {
		["source"] = "SOUL_SHARDS",
		["format"] = "N",
	},
	["RUNES_N"] = {
		["source"] = "RUNES",
		["format"] = "N",
	},
	["ARCANE_CHARGES_N"] = {
		["source"] = "ARCANE_CHARGES",
		["format"] = "N",
	},
};



--
local tLegacy;
local tMapped;
function VUHDO_migrateLegacyTextProvider(aTextIndicatorConfig)

	if aTextIndicatorConfig["TEXT_PROVIDER"] == nil then
		return;
	end

	tLegacy = aTextIndicatorConfig["TEXT_PROVIDER"] or "";
	tMapped = VUHDO_LEGACY_TEXT_PROVIDER_MIGRATION[tLegacy];

	if tMapped then
		aTextIndicatorConfig["TEXT_PROVIDER_SOURCE"] = tMapped["source"];
		aTextIndicatorConfig["TEXT_PROVIDER_FORMAT"] = tMapped["format"];
	else
		aTextIndicatorConfig["TEXT_PROVIDER_SOURCE"] = "";
		aTextIndicatorConfig["TEXT_PROVIDER_FORMAT"] = "";
	end

	aTextIndicatorConfig["TEXT_PROVIDER"] = nil;

	return;

end



--
local tSourceKey;
local tFormatKey;
local tSourceEntry;
local tIsFormatSupported;
local function VUHDO_validateTextIndicatorProvider(aTextIndicatorConfig)

	tSourceKey = aTextIndicatorConfig["TEXT_PROVIDER_SOURCE"] or "";
	tFormatKey = aTextIndicatorConfig["TEXT_PROVIDER_FORMAT"] or "";

	if tSourceKey == "" then
		aTextIndicatorConfig["TEXT_PROVIDER_FORMAT"] = "";

		return;
	end

	tSourceEntry = VUHDO_TEXT_PROVIDER_SOURCES[tSourceKey];

	if not tSourceEntry then
		aTextIndicatorConfig["TEXT_PROVIDER_SOURCE"] = "";
		aTextIndicatorConfig["TEXT_PROVIDER_FORMAT"] = "";

		return;
	end

	tIsFormatSupported = false;

	for tFormatCnt = 1, #tSourceEntry["supportedFormats"] do
		if tSourceEntry["supportedFormats"][tFormatCnt] == tFormatKey then
			tIsFormatSupported = true;

			break;
		end
	end

	if not tIsFormatSupported then
		aTextIndicatorConfig["TEXT_PROVIDER_FORMAT"] = tSourceEntry["defaultFormat"];
	end

	return;

end



--
function VUHDO_initTextProviderConfig()

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for _, tIndicatorConfig in pairs(VUHDO_INDICATOR_CONFIG[tPanelNum]["TEXT_INDICATORS"]) do
			VUHDO_validateTextIndicatorProvider(tIndicatorConfig);
		end
	end

	return;

end



--
VUHDO_TEXT_PROVIDER_SOURCES = {
	["MANA"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_MANA,
		["calculator"] = VUHDO_manaCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["RAGE"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_RAGE,
		["calculator"] = VUHDO_rageCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["FOCUS"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_FOCUS,
		["calculator"] = VUHDO_focusCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["ENERGY"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_ENERGY,
		["calculator"] = VUHDO_energyCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["RUNIC_POWER"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_RUNIC_POWER,
		["calculator"] = VUHDO_runicPowerCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["LUNAR_POWER"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_LUNAR_POWER,
		["calculator"] = VUHDO_lunarPowerCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["MAELSTROM"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_MAELSTROM,
		["calculator"] = VUHDO_maelstromCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["INSANITY"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_INSANITY,
		["calculator"] = VUHDO_insanityCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["FURY"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_FURY,
		["calculator"] = VUHDO_furyCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["PAIN"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_PAIN,
		["calculator"] = VUHDO_painCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["ESSENCE"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_ESSENCE,
		["calculator"] = VUHDO_essenceCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["ALL_POWERS"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_ALL_POWERS,
		["calculator"] = VUHDO_allPowersCalculator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "PERCENT_TENTH", "UNIT_OF_UNIT", "KILO_OF_KILO", "N", "NK", "NK_PERCENT", "KILO_OF_KILO_PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["CHI"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_CHI,
		["calculator"] = VUHDO_chiCalculator,
		["interests"] = { VUHDO_UPDATE_CHI, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "UNIT_OF_UNIT", "N" },
		["defaultFormat"] = "N",
	},
	["HOLY_POWER"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_HOLY_POWER,
		["calculator"] = VUHDO_holyPowerCalculator,
		["interests"] = { VUHDO_UPDATE_OWN_HOLY_POWER, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "UNIT_OF_UNIT", "N" },
		["defaultFormat"] = "N",
	},
	["COMBO_POINTS"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_COMBO_POINTS,
		["calculator"] = VUHDO_comboPointsCalculator,
		["interests"] = { VUHDO_UPDATE_COMBO_POINTS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "UNIT_OF_UNIT", "N" },
		["defaultFormat"] = "N",
	},
	["SOUL_SHARDS"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_SOUL_SHARDS,
		["calculator"] = VUHDO_soulShardsCalculator,
		["interests"] = { VUHDO_UPDATE_SOUL_SHARDS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "UNIT_OF_UNIT", "N" },
		["defaultFormat"] = "N",
	},
	["RUNES"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_RUNES,
		["calculator"] = VUHDO_runesCalculator,
		["interests"] = { VUHDO_UPDATE_RUNES, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "UNIT_OF_UNIT", "N" },
		["defaultFormat"] = "N",
	},
	["ARCANE_CHARGES"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_ARCANE_CHARGES,
		["calculator"] = VUHDO_arcaneChargesCalculator,
		["interests"] = { VUHDO_UPDATE_ARCANE_CHARGES, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT", "UNIT_OF_UNIT", "N" },
		["defaultFormat"] = "N",
	},
	["THREAT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_THREAT,
		["calculator"] = VUHDO_threatCalculator,
		["interests"] = { VUHDO_UPDATE_THREAT_PERC, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "PERCENT" },
		["defaultFormat"] = "PERCENT",
	},
	["OVERHEAL"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_OVERHEAL,
		["calculator"] = VUHDO_overhealCalculator,
		["interests"] = { VUHDO_UPDATE_INC, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "NK", "NK_PLUS" },
		["defaultFormat"] = "NK_PLUS",
	},
	["INCOMING_HEAL"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_INCOMING_HEAL,
		["calculator"] = VUHDO_incomingHealCalculator,
		["interests"] = { VUHDO_UPDATE_INC, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "N", "NK" },
		["defaultFormat"] = "NK",
	},
	["SHIELD_ABSORB"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_SHIELD_ABSORB,
		["calculator"] = VUHDO_shieldAbsorbCalculator,
		["interests"] = { VUHDO_UPDATE_SHIELD, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "N", "NK" },
		["defaultFormat"] = "NK",
	},
	["HEAL_ABSORB"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_HEAL_ABSORB,
		["calculator"] = VUHDO_healAbsorbCalculator,
		["interests"] = { VUHDO_UPDATE_SHIELD, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
		["supportedFormats"] = { "N", "NK" },
		["defaultFormat"] = "NK",
	},
};

VUHDO_TEXT_PROVIDER_FORMATS = {
	["PERCENT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_PERCENT,
		["validator"] = VUHDO_percentValidator,
	},
	["PERCENT_TENTH"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_PERCENT_TENTH,
		["validator"] = VUHDO_tenthPercentValidator,
	},
	["UNIT_OF_UNIT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_UNIT_OF_UNIT,
		["validator"] = VUHDO_unitOfUnitValidator,
	},
	["KILO_OF_KILO"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_KILO_OF_KILO,
		["validator"] = VUHDO_kiloOfKiloValidator,
	},
	["N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_N,
		["validator"] = VUHDO_absoluteValidator,
	},
	["NK"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_NK,
		["validator"] = VUHDO_kiloValidator,
	},
	["NK_PLUS"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_NK_PLUS,
		["validator"] = VUHDO_plusKiloValidator,
	},
	["NK_PERCENT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_NK_PERCENT,
		["validator"] = VUHDO_kiloPercentValidator,
	},
	["KILO_OF_KILO_PERCENT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_KILO_OF_KILO_PERCENT,
		["validator"] = VUHDO_kiloOfKiloPercentValidator,
	},
};