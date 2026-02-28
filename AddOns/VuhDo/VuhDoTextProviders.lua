local floor = floor;
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local _;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local AbbreviateNumbers = AbbreviateNumbers;
local UnitHealthPercent = UnitHealthPercent;
local UnitPowerPercent = UnitPowerPercent;
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction;

local CurveConstants = CurveConstants;
local TruncateWhenZero = C_StringUtil and C_StringUtil.TruncateWhenZero;
local WrapString = C_StringUtil and C_StringUtil.WrapString;

local VUHDO_getIncHealOnUnit;
local VUHDO_getUnitOverallShieldRemain;
local VUHDO_getHealPredictionCalculator;
local issecretvalue;



--
function VUHDO_textProvidersInitLocalOverrides()

	VUHDO_getIncHealOnUnit = _G["VUHDO_getIncHealOnUnit"];
	VUHDO_getUnitOverallShieldRemain = _G["VUHDO_getUnitOverallShieldRemain"];
	VUHDO_getHealPredictionCalculator = _G["VUHDO_getHealPredictionCalculator"];

	issecretvalue = _G["issecretvalue"];

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
local tChiCount;
local tChiMax;
local function VUHDO_chiCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] then
		tChiCount = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_CHI);
		tChiMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_CHI);

		if sSecretsEnabled and (issecretvalue(tChiCount) or issecretvalue(tChiMax)) then
			return tChiCount, tChiMax;
		end

		return (tChiCount > 0) and tChiCount or "", (tChiMax > 0) and tChiMax or "";
	else
		return "", nil;
	end

end



--
local tHolyPowerCount;
local tHolyPowerMax;
local function VUHDO_holyPowerCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] then
		tHolyPowerCount = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_HOLY_POWER);
		tHolyPowerMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_HOLY_POWER);

		if sSecretsEnabled and (issecretvalue(tHolyPowerCount) or issecretvalue(tHolyPowerMax)) then
			return tHolyPowerCount, tHolyPowerMax;
		end

		return (tHolyPowerCount > 0) and tHolyPowerCount or "", (tHolyPowerMax > 0) and tHolyPowerMax or "";
	else
		return "", nil;
	end

end



--
local tComboPointsCount;
local tComboPointsMax;
local function VUHDO_comboPointsCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] then
		tComboPointsCount = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_COMBO_POINTS);
		tComboPointsMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_COMBO_POINTS);

		if sSecretsEnabled and (issecretvalue(tComboPointsCount) or issecretvalue(tComboPointsMax)) then
			return tComboPointsCount, tComboPointsMax;
		end

		return (tComboPointsCount > 0) and tComboPointsCount or "", (tComboPointsMax > 0) and tComboPointsMax or "";
	else
		return "", nil;
	end

end



--
local tSoulShardsCount;
local tSoulShardsMax;
local function VUHDO_soulShardsCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] then
		tSoulShardsCount = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_SOUL_SHARDS);
		tSoulShardsMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_SOUL_SHARDS);

		if sSecretsEnabled and (issecretvalue(tSoulShardsCount) or issecretvalue(tSoulShardsMax)) then
			return tSoulShardsCount, tSoulShardsMax;
		end

		return (tSoulShardsCount > 0) and tSoulShardsCount or "", (tSoulShardsMax > 0) and tSoulShardsMax or "";
	else
		return "", nil;
	end

end



--
local tReadyRuneCount;
local tReadyRuneMax;
local tIsRuneReady;
local function VUHDO_runesCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] and anInfo["unit"] == "player" then
		tReadyRuneCount = 0;

		for i = 1, 6 do
			_, _, tIsRuneReady = GetRuneCooldown(i);

			tReadyRuneCount = tReadyRuneCount + (tIsRuneReady and 1 or 0);
		end

		tReadyRuneMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_RUNES);

		return (tReadyRuneCount > 0) and tReadyRuneCount or "", (tReadyRuneMax > 0) and tReadyRuneMax or "";
	else
		return "", nil;
	end

end



--
local tArcaneChargesCount;
local tArcaneChargesMax;
local function VUHDO_arcaneChargesCalculator(anInfo)

	if anInfo["connected"] and not anInfo["dead"] then
		tArcaneChargesCount = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_ARCANE_CHARGES);
		tArcaneChargesMax = UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_ARCANE_CHARGES);

		if sSecretsEnabled and (issecretvalue(tArcaneChargesCount) or issecretvalue(tArcaneChargesMax)) then
			return tArcaneChargesCount, tArcaneChargesMax;
		end

		return (tArcaneChargesCount > 0) and tArcaneChargesCount or "", (tArcaneChargesMax > 0) and tArcaneChargesMax or "";
	else
		return "", nil;
	end

end



--
local tAmountInc;
local tCalculator;
local function VUHDO_overhealCalculator(anInfo)

	if sSecretsEnabled then
		if not anInfo["connected"] or anInfo["dead"] then
			return 0, nil;
		end

		tCalculator = VUHDO_getHealPredictionCalculator();

		if tCalculator then
			UnitGetDetailedHealPrediction(anInfo["unit"], "player", tCalculator);

			return tCalculator:GetTotalIncomingHeals(), nil;
		else
			return 0, nil;
		end
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

	if sSecretsEnabled then
		if not anInfo["connected"] or anInfo["dead"] then
			return 0, nil;
		end

		tCalculator = VUHDO_getHealPredictionCalculator();

		if tCalculator then
			UnitGetDetailedHealPrediction(anInfo["unit"], "player", tCalculator);

			return tCalculator:GetTotalIncomingHeals(), nil;
		else
			return 0, nil;
		end
	end

	tAmountInc = VUHDO_getIncHealOnUnit(anInfo["unit"]);

	if tAmountInc > 0 and anInfo["connected"] and not anInfo["dead"] then
		return tAmountInc, nil;
	else
		return 0, nil;
	end

end


--
local tCalculator;
local function VUHDO_shieldAbsorbCalculator(anInfo)

	if sSecretsEnabled then
		tCalculator = VUHDO_getHealPredictionCalculator();

		if tCalculator then
			UnitGetDetailedHealPrediction(anInfo["unit"], "player", tCalculator);

			return tCalculator:GetTotalDamageAbsorbs(), nil;
		end

		return 0, nil;
	end

	return VUHDO_getUnitOverallShieldRemain(anInfo["unit"]), nil;

end



--
local function VUHDO_healAbsorbCalculator(anInfo)

	if sSecretsEnabled then
		tCalculator = VUHDO_getHealPredictionCalculator();

		if tCalculator then
			UnitGetDetailedHealPrediction(anInfo["unit"], "player", tCalculator);

			return tCalculator:GetTotalHealAbsorbs(), nil;
		end

		return 0, nil;
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
local function VUHDO_threatCalculator(anInfo)

	return anInfo["threatPerc"], 100;

end


------------------------------------------------------------------



--
local function VUHDO_kiloValidator(anInfo, aValue)

	if sSecretsEnabled and issecretvalue(aValue) then
		return "%s", TruncateWhenZero(aValue);
	end

	if aValue >= 500 then
		return "%d", VUHDO_round(aValue * 0.001);
	end

	return "%s", "";

end


local function VUHDO_plusKiloValidator(anInfo, aValue)

	if sSecretsEnabled and issecretvalue(aValue) then
		return "%s", WrapString(TruncateWhenZero(aValue), "+");
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

	if sSecretsEnabled then
		if tIsHealth and anInfo["hasSecretHealth"] then
			tPercent = UnitHealthPercent(anInfo["unit"], true, CurveConstants.ScaleTo100);

			return "%.0f%%", tPercent;
		elseif not tIsHealth and anInfo["hasSecretPower"] then
			tPercent = UnitPowerPercent(anInfo["unit"], anInfo["powertype"] or 0, false, CurveConstants.ScaleTo100);

			return "%.0f%%", tPercent;
		end
	end

	if anInfo["powertype"] == 0 and anInfo["powermax"] > 0 then
		return "%d%%", 100 * aValue / aMaxValue;
	end

	return "%s", "";

end

--
local function VUHDO_tenthPercentValidator(anInfo, aValue, aMaxValue)

	if sSecretsEnabled and (issecretvalue(aValue) or issecretvalue(aMaxValue)) then
		tPercent = UnitPowerPercent(anInfo["unit"], anInfo["powertype"] or 0, false, CurveConstants.ScaleTo100);

		return "%.0f", tPercent;
	end

	if anInfo["powertype"] == 0 and anInfo["powermax"] > 0 then
		return "%d", 10 * aValue / aMaxValue;
	end

	return "%s", "";

end


local tValueStr;
local tMaxStr;
local function VUHDO_unitOfUnitValidator(anInfo, aValue, aMaxValue)

	if sSecretsEnabled and (issecretvalue(aValue) or issecretvalue(aMaxValue)) then
		tValueStr = AbbreviateNumbers(aValue);
		tMaxStr = AbbreviateNumbers(aMaxValue);

		return "%s/%s", tValueStr, tMaxStr;
	end

	if anInfo["powertype"] == 0 then
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

	if anInfo["powertype"] == 0 then
		return "%d/%d", floor(aValue * 0.001), floor(aMaxValue * 0.001);
	end

	return "%s", "";

end

--
local function VUHDO_absoluteValidator(anInfo, aValue)

	if sSecretsEnabled and issecretvalue(aValue) then
		return "%s", TruncateWhenZero(aValue);
	end

	if aValue > 0 then
		return "%s", aValue;
	end

	return "%s", "";

end



---------------------------------------------------------------------------------

function VUHDO_initTextProviderConfig()

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for _, tIndicatorConfig in pairs(VUHDO_INDICATOR_CONFIG[tPanelNum]["TEXT_INDICATORS"]) do
			local tProviderName = tIndicatorConfig["TEXT_PROVIDER"];

			if not VUHDO_TEXT_PROVIDERS[tProviderName] then
				tIndicatorConfig["TEXT_PROVIDER"] = "";
			end
		end
	end

end

------------------------------------------------------------------------------------



VUHDO_TEXT_PROVIDERS = {
	["OVERHEAL_KILO_N_K"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_OVERHEAL,
		["calculator"] = VUHDO_overhealCalculator,
		["validator"] = VUHDO_kiloValidator,
		["interests"] = { VUHDO_UPDATE_INC, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_ALIVE },
	},
	["OVERHEAL_KILO_PLUS_N_K"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_OVERHEAL_PLUS,
		["calculator"] = VUHDO_overhealCalculator,
		["validator"] = VUHDO_plusKiloValidator,
		["interests"] = { VUHDO_UPDATE_INC, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_ALIVE },
	},
	["INCOMING_HEAL_NK"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_INCOMING_HEAL,
		["calculator"] = VUHDO_incomingHealCalculator,
		["validator"] = VUHDO_kiloValidator,
		["interests"] = { VUHDO_UPDATE_INC, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_ALIVE },
	},
	["SHIELD_ABSORB_OVERALL_N_K"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SHIELD_ABSORB,
		["calculator"] = VUHDO_shieldAbsorbCalculator,
		["validator"] = VUHDO_kiloValidator,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},
	["HEAL_ABSORB_TOTAL_N_K"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_HEAL_ABSORB,
		["calculator"] = VUHDO_healAbsorbCalculator,
		["validator"] = VUHDO_kiloValidator,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},
	["THREAT_PERCENT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_THREAT,
		["calculator"] = VUHDO_threatCalculator,
		["validator"] = VUHDO_percentValidator,
		["interests"] = { VUHDO_UPDATE_THREAT_PERC },
	},
	["CHI_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_CHI,
		["calculator"] = VUHDO_chiCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_CHI, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},
	["HOLY_POWER_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_HOLY_POWER,
		["calculator"] = VUHDO_holyPowerCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_OWN_HOLY_POWER, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},
	["COMBO_POINTS_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_COMBO_POINTS,
		["calculator"] = VUHDO_comboPointsCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_COMBO_POINTS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},
	["SOUL_SHARDS_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_SOUL_SHARDS,
		["calculator"] = VUHDO_soulShardsCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_SOUL_SHARDS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},
	["RUNES_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_RUNES,
		["calculator"] = VUHDO_runesCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_RUNES, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},
	["ARCANE_CHARGES_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_ARCANE_CHARGES,
		["calculator"] = VUHDO_arcaneChargesCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_ARCANE_CHARGES, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},
	["MANA_PERCENT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT,
		["calculator"] = VUHDO_manaCalculator,
		["validator"] = VUHDO_percentValidator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},
	["MANA_PERCENT_TENTH"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT_TENTH,
		["calculator"] = VUHDO_manaCalculator,
		["validator"] = VUHDO_tenthPercentValidator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},
	["MANA_UNIT_OF_UNIT"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_MANA_UNIT_OF,
		["calculator"] = VUHDO_manaCalculator,
		["validator"] = VUHDO_unitOfUnitValidator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},
	["MANA_KILO_OF_KILO"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_MANA_KILO_OF,
		["calculator"] = VUHDO_manaCalculator,
		["validator"] = VUHDO_kiloOfKiloValidator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},
	["MANA_N"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_MANA,
		["calculator"] = VUHDO_manaCalculator,
		["validator"] = VUHDO_absoluteValidator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},
	["MANA_NK"] = {
		["displayName"] = VUHDO_I18N_TEXT_PROVIDER_MANA_KILO,
		["calculator"] = VUHDO_manaCalculator,
		["validator"] = VUHDO_kiloValidator,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},
};