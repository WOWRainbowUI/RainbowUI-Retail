local _;

local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local GetRuneCooldown = GetRuneCooldown;
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs;
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs;
local floor = floor;

local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX;
local VUHDO_UNIT_POWER_HOLY_POWER = VUHDO_UNIT_POWER_HOLY_POWER;
local VUHDO_UNIT_POWER_CHI = VUHDO_UNIT_POWER_CHI;
local VUHDO_UNIT_POWER_COMBO_POINTS = VUHDO_UNIT_POWER_COMBO_POINTS;
local VUHDO_UNIT_POWER_SOUL_SHARDS = VUHDO_UNIT_POWER_SOUL_SHARDS;
local VUHDO_UNIT_POWER_RUNES = VUHDO_UNIT_POWER_RUNES;
local VUHDO_UNIT_POWER_ARCANE_CHARGES = VUHDO_UNIT_POWER_ARCANE_CHARGES;

local VUHDO_PANEL_SETUP;
local VUHDO_POWER_TYPE_COLORS;
local VUHDO_copyColor;
local VUHDO_ID_RANGED_HEAL;
local VUHDO_ID_MELEE_TANK;

local VUHDO_getCurrentBouquetColor;
local VUHDO_getIncHealOnUnit;
local VUHDO_getCurrentBouquetStacks;
local VUHDO_getIsCurrentBouquetActive;
local VUHDO_getCurrentBouquetTimer;
local VUHDO_getUnitOverallShieldRemain;
local VUHDO_unitDebuff;
local VUHDO_SPELL_ID;

local sBarColors;

----------------------------------------------------------



function VUHDO_bouquetValidatorsStatusInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_POWER_TYPE_COLORS = _G["VUHDO_POWER_TYPE_COLORS"];
	VUHDO_copyColor = _G["VUHDO_copyColor"];
	VUHDO_ID_RANGED_HEAL = _G["VUHDO_ID_RANGED_HEAL"];
	VUHDO_ID_MELEE_TANK = _G["VUHDO_ID_MELEE_TANK"];

	VUHDO_getCurrentBouquetColor = _G["VUHDO_getCurrentBouquetColor"];
	VUHDO_getIncHealOnUnit = _G["VUHDO_getIncHealOnUnit"];
	VUHDO_getCurrentBouquetStacks = _G["VUHDO_getCurrentBouquetStacks"];
	VUHDO_getIsCurrentBouquetActive = _G["VUHDO_getIsCurrentBouquetActive"];
	VUHDO_getCurrentBouquetTimer = _G["VUHDO_getCurrentBouquetTimer"];
	VUHDO_getUnitOverallShieldRemain = _G["VUHDO_getUnitOverallShieldRemain"];
	VUHDO_unitDebuff = _G["VUHDO_unitDebuff"];
	VUHDO_SPELL_ID = _G["VUHDO_SPELL_ID"];

	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];

end



----------------------------------------------------------



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom



--
local function VUHDO_healthBelowValidator(anInfo, aSomeCustom)
	if anInfo["healthmax"] > 0 then
		return 100 * anInfo["health"] / anInfo["healthmax"] < aSomeCustom["custom"][1],
			nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_healthAboveValidator(anInfo, aSomeCustom)
	if anInfo["healthmax"] > 0 then
		return 100 * anInfo["health"] / anInfo["healthmax"] >= aSomeCustom["custom"][1],
			nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_healthBelowAbsValidator(anInfo, aSomeCustom)
	return anInfo["health"] * 0.001 < aSomeCustom["custom"][1], nil, -1, -1, -1;
end



--
local function VUHDO_healthAboveAbsValidator(anInfo, aSomeCustom)
	return anInfo["health"] * 0.001 >= aSomeCustom["custom"][1], nil, -1, -1, -1;
end



--
local function VUHDO_manaBelowValidator(anInfo, aSomeCustom)
	if anInfo["powermax"] > 0 then
		return anInfo["powertype"] == 0 and 100 * anInfo["power"] / anInfo["powermax"] < aSomeCustom["custom"][1],
			nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_threatAboveValidator(anInfo, aSomeCustom)
	return anInfo["threatPerc"] > aSomeCustom["custom"][1], nil, -1, -1, -1;
end



--
local tPerc;
local function VUHDO_alternatePowersAboveValidator(anInfo, aSomeCustom)
	if anInfo["connected"] and anInfo["isAltPower"] and not anInfo["dead"] then
		tPerc = 100 * (UnitPower(anInfo["unit"], ALTERNATE_POWER_INDEX) or 0) / (UnitPowerMax(anInfo["unit"], ALTERNATE_POWER_INDEX) or 100);
		return tPerc > aSomeCustom["custom"][1], nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tPower;
local function VUHDO_holyPowersEqualsValidator(anInfo, aSomeCustom)
	if anInfo["connected"] and not anInfo["dead"] then
		tPower = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_HOLY_POWER);
		if tPower == aSomeCustom["custom"][1] then
			return true, nil, tPower, -1, UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_HOLY_POWER);
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, tPower, -1, -1;
	end
end



--
local function VUHDO_chiEqualsValidator(anInfo, aSomeCustom)
	if anInfo["connected"] and not anInfo["dead"] then
		tPower = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_CHI);
		if tPower == aSomeCustom["custom"][1] then
			return true, nil, tPower, -1, UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_CHI);
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, tPower, -1, -1;
	end
end



--
local function VUHDO_comboPointsEqualsValidator(anInfo, aSomeCustom)
	if anInfo["connected"] and not anInfo["dead"] then
		tPower = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_COMBO_POINTS);
		if tPower == aSomeCustom["custom"][1] then
			return true, nil, tPower, -1, UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_COMBO_POINTS);
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, tPower, -1, -1;
	end
end



--
local function VUHDO_soulShardsEqualsValidator(anInfo, aSomeCustom)
	if anInfo["connected"] and not anInfo["dead"] then
		tPower = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_SOUL_SHARDS);
		if tPower == aSomeCustom["custom"][1] then
			return true, nil, tPower, -1, UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_SOUL_SHARDS);
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, tPower, -1, -1;
	end
end



--
local tIsRuneReady;
local function VUHDO_runesEqualsValidator(anInfo, aSomeCustom)
	if anInfo["unit"] ~= "player" then
		return false, nil, -1, -1, -1;
	elseif anInfo["connected"] and not anInfo["dead"] then
		tPower = 0;

		for i = 1, 6 do
			_, _, tIsRuneReady = GetRuneCooldown(i);

			tPower = tPower + (tIsRuneReady and 1 or 0);
		end

		if tPower == aSomeCustom["custom"][1] then
			return true, nil, tPower, -1, UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_RUNES);
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, tPower, -1, -1;
	end
end



--
local function VUHDO_arcaneChargesEqualsValidator(anInfo, aSomeCustom)
	if anInfo["connected"] and not anInfo["dead"] then
		tPower = UnitPower(anInfo["unit"], VUHDO_UNIT_POWER_ARCANE_CHARGES);
		if tPower == aSomeCustom["custom"][1] then
			return true, nil, tPower, -1, UnitPowerMax(anInfo["unit"], VUHDO_UNIT_POWER_ARCANE_CHARGES);
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, tPower, -1, -1;
	end
end



--
local function VUHDO_durationAboveValidator(anInfo, aSomeCustom)
	if VUHDO_getIsCurrentBouquetActive() then
		return VUHDO_getCurrentBouquetTimer() > aSomeCustom["custom"][1], nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_durationBelowValidator(anInfo, aSomeCustom)
	if VUHDO_getIsCurrentBouquetActive() then
		return VUHDO_getCurrentBouquetTimer() < aSomeCustom["custom"][1], nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tOverheal;
local function VUHDO_overhealHighlightValidator(anInfo, _)
	tOverheal = VUHDO_getIncHealOnUnit(anInfo["unit"]) + anInfo["health"];
	if tOverheal > anInfo["healthmax"] and anInfo["healthmax"] > 0 then
		VUHDO_brightenColor(VUHDO_getCurrentBouquetColor(), tOverheal / anInfo["healthmax"]);
	end
	return false, nil, -1, -1, -1;
end



--
local tStacks;
local function VUHDO_stacksColorValidator(anInfo, _)
	tStacks = VUHDO_getCurrentBouquetStacks() or 0;
	if tStacks > 4 then	tStacks = 4; end

	if tStacks > 1 then
		return true, nil, -1, -1, -1, VUHDO_copyColor(sBarColors[VUHDO_CHARGE_COLORS[tStacks]]);
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tStacks;
local function VUHDO_stacksValidator(anInfo, aSomeCustom)
	tStacks = VUHDO_getCurrentBouquetStacks() or 0;

	if tStacks > aSomeCustom["custom"][1] then
		return true, nil, -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_statusHealthValidator(anInfo, _)

	return true, nil, anInfo["health"], -1, anInfo["healthmax"], nil, anInfo["health"];

end



--
local function VUHDO_statusManaValidator(anInfo, _)
	return anInfo["powertype"] == 0, nil, anInfo["power"], -1,
		anInfo["powermax"], VUHDO_copyColor(VUHDO_POWER_TYPE_COLORS[0]);
end



--
local function VUHDO_statusManaHealerOnlyValidator(anInfo, _)
	return (anInfo["powertype"] == 0 and anInfo["role"] == VUHDO_ID_RANGED_HEAL), nil, anInfo["power"], -1,
		anInfo["powermax"], VUHDO_copyColor(VUHDO_POWER_TYPE_COLORS[0]);
end



--
local function VUHDO_statusPowerTankOnlyValidator(anInfo, _)
	return (anInfo["powertype"] ~= 0 and anInfo["role"] == VUHDO_ID_MELEE_TANK), nil, anInfo["power"], -1,
		anInfo["powermax"], VUHDO_copyColor(VUHDO_POWER_TYPE_COLORS[anInfo["powertype"] or 0]);
end



--
local function VUHDO_statusOtherPowersValidator(anInfo, _)
	return anInfo["powertype"] ~= 0, nil, anInfo["power"], -1,
		anInfo["powermax"], VUHDO_copyColor(VUHDO_POWER_TYPE_COLORS[anInfo["powertype"] or 0]);
end



--
local function VUHDO_statusAlternatePowersValidator(anInfo, _)
	if anInfo["connected"] and anInfo["isAltPower"] and not anInfo["dead"] then
		return true, nil, UnitPower(anInfo["unit"], ALTERNATE_POWER_INDEX) or 0, -1,
			UnitPowerMax(anInfo["unit"], ALTERNATE_POWER_INDEX) or 100;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_statusIncomingValidator(anInfo, _)
	return true, nil, VUHDO_getIncHealOnUnit(anInfo["unit"]), -1, anInfo["healthmax"];
end



--
local function VUHDO_statusExcessAbsorbValidator(anInfo, _)
	local healthmax = anInfo["healthmax"];

	local excessAbsorb = (UnitGetTotalAbsorbs(anInfo["unit"]) or 0) + anInfo["health"] - healthmax;

	if excessAbsorb < 0 then
		return true, nil, 0, -1, healthmax;
	end

	return true, nil, excessAbsorb, -1, healthmax;
end



--
local function VUHDO_statusTotalAbsorbValidator(anInfo, _)
	return true, nil, UnitGetTotalAbsorbs(anInfo["unit"]) or 0, -1, anInfo["healthmax"];
end



--
local function VUHDO_statusThreatValidator(anInfo, _)
	return true, nil, anInfo["threatPerc"], -1, 100;
end



--
local function VUHDO_statusAlwaysFullValidator(_, _)
	return true, nil, 100, -1, 100, nil, 100;
end



--
local function VUHDO_statusFullIfActiveValidator(_, _)
	if VUHDO_getIsCurrentBouquetActive() then
		return true, nil, 100, -1, 100, VUHDO_getCurrentBouquetColor(), 100;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_statusHealthIfActiveValidator(anInfo, _)

	if VUHDO_getIsCurrentBouquetActive() then
		return true, nil, anInfo["health"], -1, anInfo["healthmax"], VUHDO_getCurrentBouquetColor(), anInfo["health"];
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tShieldLeft;
local function VUHDO_overflowCountValidator(anInfo, _)
	tShieldLeft = select(16, VUHDO_unitDebuff(anInfo["unit"], VUHDO_SPELL_ID.DEBUFF_OVERFLOW)) or 0;
	return tShieldLeft >= 1000, nil, -1, floor(tShieldLeft * 0.001 + 0.5), -1;
end



--
local tShieldLeft;
local function VUHDO_shieldCountValidator(anInfo, _)
	tShieldLeft = VUHDO_getUnitOverallShieldRemain(anInfo["unit"]);
	return tShieldLeft >= 1000, nil, -1, floor(tShieldLeft * 0.001 + 0.5), -1;
end



--
local tActiveAuras;
local function VUHDO_activeAurasCountValidator(anInfo, _)

	tActiveAuras = VUHDO_getCurrentBouquetActiveAuras(anInfo["unit"]) or 0;
	return tActiveAuras > 0, nil, -1, tActiveAuras, -1;

end



--
local tShieldLeft, tHealthMax;
local function VUHDO_statusShieldFromHealthValidator(anInfo, _)
	tHealthMax = anInfo["healthmax"];
	tShieldLeft = VUHDO_getUnitOverallShieldRemain(anInfo["unit"]);
	return true, nil, tShieldLeft < tHealthMax and tShieldLeft or tHealthMax, -1, tHealthMax;
end



--
local tShieldLeft;
local function VUHDO_healAbsorbCountValidator(anInfo, _)
	tShieldLeft = UnitGetTotalHealAbsorbs(anInfo["unit"]) or 0;
	return tShieldLeft >= 1000, nil, -1, floor(tShieldLeft * 0.001 + 0.5), -1;
end



--
local tShieldLeft, tHealthMax;
local function VUHDO_statusHealAbsorbFromHealthValidator(anInfo, _)
	tHealthMax = anInfo["healthmax"];
	tShieldLeft = UnitGetTotalHealAbsorbs(anInfo["unit"]) or 0;
	return true, nil, tShieldLeft < tHealthMax and tShieldLeft or tHealthMax, -1, tHealthMax;
end



--
local tShieldLeft, tHealthMax, tHealth;
local function VUHDO_statusShieldOvershieldValidator(anInfo, _)
	tHealthMax = anInfo["healthmax"];
	tHealth = anInfo["health"];
	tShieldLeft = VUHDO_getUnitOverallShieldRemain(anInfo["unit"]);
	return tHealth + tShieldLeft > tHealthMax, nil, tShieldLeft - tHealthMax + tHealth, -1, tHealthMax;
end



--
local VUHDO_BOUQUET_BUFFS_SPECIAL_STATUS = {
	["HEALTH_BELOW"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_HEALTH_BELOW,
		["validator"] = VUHDO_healthBelowValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["HEALTH_ABOVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_HEALTH_ABOVE,
		["validator"] = VUHDO_healthAboveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["HEALTH_BELOW_ABS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_HEALTH_BELOW_ABS,
		["validator"] = VUHDO_healthBelowAbsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HEALTH,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["HEALTH_ABOVE_ABS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_HEALTH_ABOVE_ABS,
		["validator"] = VUHDO_healthAboveAbsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HEALTH,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["MANA_BELOW"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MANA_BELOW,
		["validator"] = VUHDO_manaBelowValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_MANA },
	},

	["THREAT_ABOVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_THREAT_ABOVE,
		["validator"] = VUHDO_threatAboveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_THREAT_PERC },
	},

	["ALTERNATE_POWERS_ABOVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ALTERNATE_POWERS_ABOVE,
		["validator"] = VUHDO_alternatePowersAboveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_ALT_POWER, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["OWN_HOLY_POWER_EQUALS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_HOLY_POWER_EQUALS,
		["validator"] = VUHDO_holyPowersEqualsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER,
		["interests"] = { VUHDO_UPDATE_OWN_HOLY_POWER, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["OWN_CHI_EQUALS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OWN_CHI_EQUALS,
		["validator"] = VUHDO_chiEqualsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER,
		["interests"] = { VUHDO_UPDATE_CHI, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["OWN_COMBO_POINTS_EQUALS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OWN_COMBO_POINTS_EQUALS,
		["validator"] = VUHDO_comboPointsEqualsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER,
		["interests"] = { VUHDO_UPDATE_COMBO_POINTS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["OWN_SOUL_SHARDS_EQUALS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OWN_SOUL_SHARDS_EQUALS,
		["validator"] = VUHDO_soulShardsEqualsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER,
		["interests"] = { VUHDO_UPDATE_SOUL_SHARDS, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["OWN_RUNES_EQUALS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OWN_RUNES_EQUALS,
		["validator"] = VUHDO_runesEqualsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER,
		["interests"] = { VUHDO_UPDATE_RUNES, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["OWN_ARCANE_CHARGES_EQUALS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OWN_ARCANE_CHARGES_EQUALS,
		["validator"] = VUHDO_arcaneChargesEqualsValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER,
		["interests"] = { VUHDO_UPDATE_ARCANE_CHARGES, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["DURATION_ABOVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DURATION_ABOVE,
		["validator"] = VUHDO_durationAboveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_SECONDS,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["DURATION_BELOW"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DURATION_BELOW,
		["validator"] = VUHDO_durationBelowValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_SECONDS,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["OVERHEAL_HIGHLIGHT"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT,
		["validator"] = VUHDO_overhealHighlightValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_INC },
	},

	["STACKS_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STACKS_COLOR,
		["validator"] = VUHDO_stacksColorValidator,
		["updateCyclic"] = true,
		["no_color"] = true,
		["interests"] = { },
	},

	["STACKS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STACKS,
		["validator"] = VUHDO_stacksValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STACKS,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["STATUS_HEALTH"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_HEALTH,
		["validator"] = VUHDO_statusHealthValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_INC, VUHDO_UPDATE_SHIELD },
	},

	["STATUS_MANA"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_MANA,
		["validator"] = VUHDO_statusManaValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},

	["STATUS_MANA_HEALER_ONLY"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_MANA_HEALER_ONLY,
		["validator"] = VUHDO_statusManaHealerOnlyValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},

	["STATUS_POWER_TANK_ONLY"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_POWER_TANK_ONLY,
		["validator"] = VUHDO_statusPowerTankOnlyValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC },
	},

	["STATUS_OTHER_POWERS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS,
		["validator"] = VUHDO_statusOtherPowersValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC },
	},

	["STATUS_ALTERNATE_POWERS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_ALTERNATE_POWERS,
		["validator"] = VUHDO_statusAlternatePowersValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_ALT_POWER, VUHDO_UPDATE_DC, VUHDO_UPDATE_ALIVE },
	},

	["STATUS_INCOMING"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_INCOMING,
		["validator"] = VUHDO_statusIncomingValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_INC },
	},

	["STATUS_EXCESS_ABSORB"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_EXCESS_ABSORB,
		["validator"] = VUHDO_statusExcessAbsorbValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_SHIELD },
	},

	["STATUS_TOTAL_ABSORB"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_TOTAL_ABSORB,
		["validator"] = VUHDO_statusTotalAbsorbValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_SHIELD },
	},

	["STATUS_THREAT"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_THREAT,
		["validator"] = VUHDO_statusThreatValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_THREAT_PERC },
	},

	["STATUS_FULL"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_ALWAYS_FULL,
		["validator"] = VUHDO_statusAlwaysFullValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { },
	},

	["STATUS_ACTIVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_FULL_IF_ACTIVE,
		["validator"] = VUHDO_statusFullIfActiveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { },
	},

	["STATUS_HEALTH_ACTIVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_HEALTH_IF_ACTIVE,
		["validator"] = VUHDO_statusHealthIfActiveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_INC, VUHDO_UPDATE_SHIELD },
	},

	["OVERFLOW_COUNTER"] = {
		["displayName"] = VUHDO_I18N_DEF_COUNTER_OVERFLOW_ABSORB,
		["validator"] = VUHDO_overflowCountValidator,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},

	["SHIELDS_COUNTER"] = {
		["displayName"] = VUHDO_I18N_DEF_COUNTER_SHIELD_ABSORB,
		["validator"] = VUHDO_shieldCountValidator,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},

	["ACTIVE_AURAS_COUNTER"] = {
		["displayName"] = VUHDO_I18N_DEF_COUNTER_ACTIVE_AURAS,
		["validator"] = VUHDO_activeAurasCountValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["SHIELD_STATUS"] = {
		["displayName"] = VUHDO_I18N_DEF_STATUS_SHIELD,
		["validator"] = VUHDO_statusShieldFromHealthValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},

	["SHIELD_OVERSHIELD"] = {
		["displayName"] = VUHDO_I18N_DEF_STATUS_OVERSHIELDED,
		["validator"] = VUHDO_statusShieldOvershieldValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},

	["HEAL_ABSORB_COUNTER"] = {
		["displayName"] = VUHDO_I18N_DEF_COUNTER_HEAL_ABSORB,
		["validator"] = VUHDO_healAbsorbCountValidator,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},

	["HEAL_ABSORB_STATUS"] = {
		["displayName"] = VUHDO_I18N_DEF_STATUS_HEAL_ABSORB,
		["validator"] = VUHDO_statusHealAbsorbFromHealthValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_SHIELD },
	},
};



--
function VUHDO_mergeStatusValidators()

	if VUHDO_BOUQUET_BUFFS_SPECIAL then
		for tKey, tValue in pairs(VUHDO_BOUQUET_BUFFS_SPECIAL_STATUS) do
			VUHDO_BOUQUET_BUFFS_SPECIAL[tKey] = tValue;
		end
	end

	return;

end