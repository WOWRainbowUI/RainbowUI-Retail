VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT = 1;
VUHDO_BOUQUET_CUSTOM_TYPE_PLAYERS = 2;
VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR = 3;
VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS = 4;
VUHDO_BOUQUET_CUSTOM_TYPE_HEALTH = 5;
VUHDO_BOUQUET_CUSTOM_TYPE_HOLY_POWER = 6;
VUHDO_BOUQUET_CUSTOM_TYPE_SECONDS = 7;
VUHDO_BOUQUET_CUSTOM_TYPE_STACKS = 8;
VUHDO_BOUQUET_CUSTOM_TYPE_CUSTOM_FLAG = 9;
VUHDO_BOUQUET_CUSTOM_TYPE_SPELL_TRACE = 10;

VUHDO_FORCE_RESET = false;

local GetTexCoordsForRole = GetTexCoordsForRole or VUHDO_getTexCoordsForRole;
local _;

local VUHDO_RAID = { };
local VUHDO_USER_CLASS_COLORS;
local VUHDO_PANEL_SETUP;

local VUHDO_getChosenDebuffInfo;
local VUHDO_getCurrentPlayerTarget;
local VUHDO_getCurrentPlayerFocus;
local VUHDO_getCurrentMouseOver;
local VUHDO_isUnitSwiftmendable;
local VUHDO_getDebuffColor;
local VUHDO_getIsCurrentBouquetActive;
local VUHDO_getCurrentBouquetColor;
local VUHDO_getIncHealOnUnit;
local VUHDO_getUnitDebuffSchoolInfos;
local VUHDO_getCurrentBouquetStacks;
local VUHDO_getSpellTraceForUnit;
local VUHDO_getCurrentBouquetTimer;
local VUHDO_getRaidTargetIconTexture;
local VUHDO_getUnitGroupPrivileges;
local VUHDO_getLatestCustomDebuff;
local VUHDO_getUnitOverallShieldRemain;

local sBarColors;
local sIsDistance;

----------------------------------------------------------



function VUHDO_bouquetValidatorsInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_USER_CLASS_COLORS = _G["VUHDO_USER_CLASS_COLORS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];

	VUHDO_getChosenDebuffInfo = _G["VUHDO_getChosenDebuffInfo"];
	VUHDO_getCurrentPlayerTarget = _G["VUHDO_getCurrentPlayerTarget"];
	VUHDO_getCurrentPlayerFocus = _G["VUHDO_getCurrentPlayerFocus"];
	VUHDO_getCurrentMouseOver = _G["VUHDO_getCurrentMouseOver"];
	VUHDO_isUnitSwiftmendable = _G["VUHDO_isUnitSwiftmendable"];
	VUHDO_getDebuffColor = _G["VUHDO_getDebuffColor"];
	VUHDO_getCurrentBouquetColor = _G["VUHDO_getCurrentBouquetColor"];
	VUHDO_getIncHealOnUnit = _G["VUHDO_getIncHealOnUnit"];
	VUHDO_getUnitDebuffSchoolInfos = _G["VUHDO_getUnitDebuffSchoolInfos"];
	VUHDO_getCurrentBouquetStacks = _G["VUHDO_getCurrentBouquetStacks"];
	VUHDO_getIsCurrentBouquetActive = _G["VUHDO_getIsCurrentBouquetActive"];
	VUHDO_getSpellTraceForUnit = _G["VUHDO_getSpellTraceForUnit"];
	VUHDO_getCurrentBouquetTimer = _G["VUHDO_getCurrentBouquetTimer"];
	VUHDO_getRaidTargetIconTexture = _G["VUHDO_getRaidTargetIconTexture"];
	VUHDO_getUnitGroupPrivileges = _G["VUHDO_getUnitGroupPrivileges"];
	VUHDO_getLatestCustomDebuff = _G["VUHDO_getLatestCustomDebuff"];
	VUHDO_getUnitOverallShieldRemain = _G["VUHDO_getUnitOverallShieldRemain"];

	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	sIsDistance = VUHDO_CONFIG["DIRECTION"]["isDistanceText"];

end



local tEmptyInfo = { };
local VUHDO_CHARGE_COLORS = {
	"HOT_CHARGE_1",
	"HOT_CHARGE_2",
	"HOT_CHARGE_3",
	"HOT_CHARGE_4",
};



----------------------------------------------------------



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom



--
local tInfo;
local function VUHDO_spellTraceValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tInfo;
local function VUHDO_spellTraceIncomingValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceIncomingForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tInfo;
local function VUHDO_spellTraceHealValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceHealForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tInfo;
local function VUHDO_spellTraceSingleValidator(anInfo, aCustom)

	if aCustom and aCustom["custom"] and aCustom["custom"]["spellTrace"] and aCustom["custom"]["spellTrace"] ~= "" then
		tInfo = VUHDO_getSpellTraceForUnit(anInfo["unit"], aCustom["custom"]["spellTrace"]);

		if tInfo then
			return true, tInfo["icon"], -1, -1, -1;
		end
	end

	return false, nil, -1, -1, -1;

end



--
local tInfo;
local function VUHDO_trailOfLightValidator(anInfo, _)

	tInfo = VUHDO_getSpellTraceTrailOfLightForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local function VUHDO_trailOfLightNextValidator(anInfo, _)

	return VUHDO_isSpellTraceTrailOfLightNextUnit(anInfo["unit"]), nil, -1, -1, -1;

end



--
local tInfo;
local function VUHDO_aoeAdviceValidator(anInfo, _)
	tInfo = VUHDO_getAoeAdviceForUnit(anInfo["unit"]);

	if tInfo then
		return true, tInfo["icon"], -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_aggroValidator(anInfo, _)
	return anInfo["aggro"], nil, -1, -1, -1;
end



--
local function VUHDO_outsideZoneValidator(anInfo, _)
	return not VUHDO_isInSameZone(anInfo["unit"]), nil, -1, -1, -1;
end



--
local function VUHDO_insideZoneValidator(anInfo, _)
	return VUHDO_isInSameZone(anInfo["unit"]), nil, -1, -1, -1;
end



--
local function VUHDO_outOfRangeValidator(anInfo, _)
	return not anInfo["range"], nil, -1, -1, -1;
end



--
local function VUHDO_inRangeValidator(anInfo, _)
	return anInfo["range"], nil, -1, -1, -1;
end



--
local function VUHDO_isPhasedValidator(anInfo, _)
	if VUHDO_unitPhaseReason(anInfo["unit"]) then
		return true, "Interface\\TargetingFrame\\UI-PhasingIcon", 
			-1, -1, -1, nil, nil, 0.15625, 0.84375, 0.15625, 0.84375;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_isWarModePhasedValidator(anInfo, _)

	local tPhaseReason = VUHDO_unitPhaseReason(anInfo["unit"]);

	if tPhaseReason and tPhaseReason == Enum.PhaseReason.WarMode then
		return true, "Interface\\TargetingFrame\\UI-PhasingIcon", 
			-1, -1, -1, nil, nil, 0.15625, 0.84375, 0.15625, 0.84375;
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tDistance;
local function VUHDO_inYardsRangeValidator(anInfo, aSomeCustom)
	tDistance = VUHDO_getDistanceBetween("player", anInfo["unit"]);
	return tDistance and (tDistance <= aSomeCustom["custom"][1]), nil, -1, -1, -1;
end



--
local function VUHDO_swiftmendValidator(anInfo, _)
	return VUHDO_isUnitSwiftmendable(anInfo["unit"]), nil, -1, -1, -1;
end



--
local tOPHotInfo;
local function VUHDO_otherPlayersHotsValidator(anInfo, _)
	tOPHotInfo = VUHDO_getOtherPlayersHotInfo(anInfo["unit"]);
	return tOPHotInfo[1] ~= nil, tOPHotInfo[1], -1, tOPHotInfo[2], -1;
end



--
local tDebuffInfo;
local function VUHDO_debuffMagicValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_MAGIC);
	if tDebuffInfo[2] then
		return true, tDebuffInfo[1], floor(tDebuffInfo[2] - GetTime()), tDebuffInfo[3], tDebuffInfo[4];
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffDiseaseValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_DISEASE);
	if tDebuffInfo[2] then
		return true, tDebuffInfo[1], floor(tDebuffInfo[2] - GetTime()), tDebuffInfo[3], tDebuffInfo[4];
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffPoisonValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_POISON);
	if tDebuffInfo[2] then
		return true, tDebuffInfo[1], floor(tDebuffInfo[2] - GetTime()), tDebuffInfo[3], tDebuffInfo[4];
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffCurseValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_CURSE);
	if tDebuffInfo[2] then
		return true, tDebuffInfo[1], floor(tDebuffInfo[2] - GetTime()), tDebuffInfo[3], tDebuffInfo[4];
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffBleedValidator(anInfo, _)

	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_BLEED);

	if tDebuffInfo[2] then
		return true, tDebuffInfo[1], floor(tDebuffInfo[2] - GetTime()), tDebuffInfo[3], tDebuffInfo[4];
	else
		return false, nil, -1, -1, -1;
	end

end



--
local tDebuffInfo;
local function VUHDO_debuffEnrageValidator(anInfo, _)

	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_ENRAGE);

	if tDebuffInfo[2] then
		return true, tDebuffInfo[1], floor(tDebuffInfo[2] - GetTime()), tDebuffInfo[3], tDebuffInfo[4];
	else
		return false, nil, -1, -1, -1;
	end

end



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom
local tDebuffInfo;
local function VUHDO_debuffBarColorValidator(anInfo, _)
	if anInfo["charmed"] then
		return true, nil, -1, -1, -1, VUHDO_getDebuffColor(anInfo);
	elseif anInfo["debuff"] and anInfo["debuff"] > 0 then -- VUHDO_DEBUFF_TYPE_NONE
		tDebuffInfo = VUHDO_getChosenDebuffInfo(anInfo["unit"]);
		return true, tDebuffInfo[1], -1, tDebuffInfo[3], -1, VUHDO_getDebuffColor(anInfo);
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_debuffCharmedValidator(anInfo, _)
	return anInfo["charmed"], nil, -1, -1, -1;
end



--
local function VUHDO_deadValidator(anInfo, _)
	return anInfo["dead"], nil, 100, -1, 100;
end



--
local function VUHDO_disconnectedValidator(anInfo, _)
	return not anInfo or not anInfo["connected"], nil, 100, -1, 100;
end



--
local function VUHDO_afkValidator(anInfo, _)
	return anInfo["afk"], nil, -1, -1, -1;
end



--
local function VUHDO_playerTargetValidator(anInfo, _)
	if anInfo["isPet"] and (VUHDO_RAID[anInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"] then
		return anInfo["ownerUnit"] == VUHDO_getCurrentPlayerTarget(), nil, -1, -1, -1;
	else
		return anInfo["unit"] == VUHDO_getCurrentPlayerTarget(), nil, -1, -1, -1;
	end
end



--
local function VUHDO_playerFocusValidator(anInfo, _)
	if anInfo["isPet"] and (VUHDO_RAID[anInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"] then
		return anInfo["ownerUnit"] == VUHDO_getCurrentPlayerFocus(), nil, -1, -1, -1;
	else
		return anInfo["unit"] == VUHDO_getCurrentPlayerFocus(), nil, -1, -1, -1;
	end
end


-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom

--
local function VUHDO_mouseOverTargetValidator(anInfo, _)
	if anInfo["isPet"] and (VUHDO_RAID[anInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"] then
		return anInfo["ownerUnit"] == VUHDO_getCurrentMouseOver(), nil, -1, -1, -1;
	else
		return anInfo["unit"] == VUHDO_getCurrentMouseOver(), nil, -1, -1, -1;
	end
end



--
local tMouseOverUnit;
local function VUHDO_mouseOverGroupValidator(anInfo, _)
	tMouseOverUnit = VUHDO_getCurrentMouseOver();
	return VUHDO_RAID[tMouseOverUnit] and anInfo["group"] == VUHDO_RAID[tMouseOverUnit]["group"],
		nil, -1, -1, -1;
end



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
local tNumInCluster;
local function VUHDO_numInClusterValidator(anInfo, aSomeCustom)
	tNumInCluster = VUHDO_getNumInUnitCluster(anInfo["unit"]);
	return tNumInCluster >= aSomeCustom["custom"][1], nil, -1, tNumInCluster, -1;
end



--
local function VUHDO_mouseClusterValidator(anInfo, _)
	return VUHDO_getIsInHiglightCluster(anInfo["unit"]), nil, -1, -1, -1;
end



--
local function VUHDO_threatMediumValidator(anInfo, _)
	return anInfo["threat"] == 2, nil, -1, -1, -1;
end



--
local function VUHDO_threatHighValidator(anInfo, _)
	return anInfo["threat"] == 3, nil, -1, -1, -1;
end


--
local tIsRaidIconColor;
local tColor, tIcon;
local function VUHDO_raidTargetValidator(anInfo, _)
	if anInfo["raidIcon"] then
		tIcon = tostring(anInfo["raidIcon"]);
		tIsRaidIconColor = not sBarColors["RAID_ICONS"]["filterOnly"] or VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon];

		if tIsRaidIconColor then
			tColor = sBarColors["RAID_ICONS"][tIcon];
		else
			tColor = nil;
		end
		return tIsRaidIconColor, nil, -1, -1, -1, tColor;
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
local tIndex, tFactor, tColor, tUnit;
local function VUHDO_emergencyColorValidator(anInfo, aSomeCustom)
	if not VUHDO_FORCE_RESET then
		tUnit = anInfo["unit"];

		if tUnit == "target" then
			tUnit = VUHDO_getCurrentPlayerTarget();
		elseif tUnit == "focus" then
			tUnit = VUHDO_getCurrentPlayerFocus();
		end

		tIndex = VUHDO_EMERGENCIES[tUnit];
		if tIndex then
			tFactor = 1 / tIndex;

			tColor = VUHDO_copyColor(aSomeCustom["color"]);
			tColor["R"], tColor["G"], tColor["B"] = (tColor["R"] or 0) * tFactor, (tColor["G"] or 0) * tFactor, (tColor["B"] or 0) * tFactor;
			return true, nil, -1, -1, -1, tColor;
		end
	end

	return false, nil, -1, -1, -1;
end



--
local function VUHDO_resurrectionValidator(anInfo, aSomeCustom)
	return anInfo["dead"] and UnitHasIncomingResurrection(anInfo["unit"]), "Interface\\RaidFrame\\Raid-Icon-Rez", -1, -1, -1;
end



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom

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

-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom

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
local function VUHDO_hasSummonIconValidator(anInfo, _)
	if C_IncomingSummon.HasIncomingSummon(anInfo["unit"]) then
		local status = C_IncomingSummon.IncomingSummonStatus(anInfo["unit"]);

		if (status == Enum.SummonStatus.Pending) then
			return true, "Raid-Icon-SummonPending", -1, -1, -1, nil, nil, 0, 1, 0, 1;
		elseif (status == Enum.SummonStatus.Accepted) then
			return true, "Raid-Icon-SummonAccepted", -1, -1, -1, nil, nil, 0, 1, 0, 1;
		elseif (status == Enum.SummonStatus.Declined) then
			return true, "Raid-Icon-SummonDeclined", -1, -1, -1, nil, nil, 0, 1, 0, 1;
		else
			return false, nil, -1, -1, -1;
		end
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_classIconValidator(anInfo, _)
	if CLASS_ICON_TCOORDS[anInfo["class"]] then
		return true, "Interface\\TargetingFrame\\UI-Classes-Circles", -1, -1, -1, nil, nil, unpack(CLASS_ICON_TCOORDS[anInfo["class"]]);
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tIndex;
local function VUHDO_raidIconValidator(anInfo, _)
	tIndex = GetRaidTargetIndex(anInfo["unit"]);

	if tIndex then
		return true, "interface\\targetingframe\\ui-raidtargetingicons", -1, -1, -1, nil, nil, VUHDO_getRaidTargetIconTexture(tIndex);
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tIndex;
local function VUHDO_raidIconTargetValidator(anInfo, _)
	tIndex = UnitExists(anInfo["targetUnit"] or "foo") and GetRaidTargetIndex(anInfo["targetUnit"]);

	if tIndex then
		return true, "interface\\targetingframe\\ui-raidtargetingicons", -1, -1, -1, nil, nil, VUHDO_getRaidTargetIconTexture(tIndex);
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_roleIconValidator(anInfo, _)
	if VUHDO_ID_MELEE_TANK == anInfo["role"] then
		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
	elseif VUHDO_ID_RANGED_HEAL == anInfo["role"] then
		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("HEALER");
	elseif VUHDO_ID_MELEE_DAMAGE == anInfo["role"] or VUHDO_ID_RANGED_DAMAGE == anInfo["role"] then
		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("DAMAGER");
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_roleTankValidator(anInfo, _)
	if VUHDO_ID_MELEE_TANK == anInfo["role"] then
		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_roleDamageValidator(anInfo, _)
	if VUHDO_ID_MELEE_DAMAGE == anInfo["role"] or VUHDO_ID_RANGED_DAMAGE == anInfo["role"] then
		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("DAMAGER");
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_roleHealerValidator(anInfo, _)
	if VUHDO_ID_RANGED_HEAL == anInfo["role"] then
		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("HEALER");
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_warriorTankValidator(anInfo, _)
	if (VUHDO_ID_MELEE_TANK == anInfo["role"]) then
                if(VUHDO_ID_WARRIORS == anInfo["classId"]) then
               		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
                end
	else
		return false, nil, -1, -1, -1, nil, nil, nil, nil, nil, nil;
	end
end



--
local function VUHDO_paladinTankValidator(anInfo, _)
	if (VUHDO_ID_MELEE_TANK == anInfo["role"]) then
                if(VUHDO_ID_PALADINS == anInfo["classId"]) then
               		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
                end
	else
		return false, nil, -1, -1, -1, nil, nil, nil, nil, nil, nil;
	end
end



--
local function VUHDO_dkTankValidator(anInfo, _)
	if (VUHDO_ID_MELEE_TANK == anInfo["role"]) then
                if(VUHDO_ID_DEATH_KNIGHT == anInfo["classId"]) then
               		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
                end
	else
		return false, nil, -1, -1, -1, nil, nil, nil, nil, nil, nil;
	end
end



--
local function VUHDO_monkTankValidator(anInfo, _)
	if (VUHDO_ID_MELEE_TANK == anInfo["role"]) then
                if(VUHDO_ID_MONKS == anInfo["classId"]) then
               		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
                end
	else
		return false, nil, -1, -1, -1, nil, nil, nil, nil, nil, nil;
	end
end



--
local function VUHDO_druidTankValidator(anInfo, _)
	if (VUHDO_ID_MELEE_TANK == anInfo["role"]) then
                if(VUHDO_ID_DRUIDS == anInfo["classId"]) then
               		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
                end
	else
		return false, nil, -1, -1, -1, nil, nil, nil, nil, nil, nil;
	end
end



--
local function VUHDO_demonHunterTankValidator(anInfo, _)
	if (VUHDO_ID_MELEE_TANK == anInfo["role"]) then
                if(VUHDO_ID_DEMON_HUNTERS == anInfo["classId"]) then
               		return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("TANK");
                end
	else
		return false, nil, -1, -1, -1, nil, nil, nil, nil, nil, nil;
	end
end



--
local tIcon, tExpiry, tStacks, tDuration;
local function VUHDO_customDebuffIconValidator(anInfo, _)
	tIcon, tExpiry, tStacks, tDuration = VUHDO_getLatestCustomDebuff(anInfo["unit"]);
	if tIcon then
		return true, tIcon, tExpiry - GetTime(), tStacks, tDuration;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tIsLeader;
local function VUHDO_leaderIconValidator(anInfo, _)
	tIsLeader = VUHDO_getUnitGroupPrivileges(anInfo["unit"]);
	if tIsLeader then
		return true, "Interface\\groupframe\\ui-group-leadericon", -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tIsAssistant;
local function VUHDO_assistantIconValidator(anInfo, _)
	_, tIsAssistant = VUHDO_getUnitGroupPrivileges(anInfo["unit"]);
	if tIsAssistant then
		return true, "Interface\\groupframe\\ui-group-assistanticon", -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tIsMasterLooter
local function VUHDO_masterLooterIconValidator(anInfo, _)
	_, _, tIsMasterLooter = VUHDO_getUnitGroupPrivileges(anInfo["unit"]);
	if tIsMasterLooter then
		return true, "Interface\\groupframe\\ui-group-masterlooter", -1, -1, -1;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_pvpIconValidator(anInfo, _)
	if UnitIsPVP(anInfo["unit"]) then
		if "Alliance" == (UnitFactionGroup(anInfo["unit"])) then
			return true, "Interface\\groupframe\\ui-group-pvp-alliance", -1, -1, -1;
		else
			return true, "Interface\\groupframe\\ui-group-pvp-horde", -1, -1, -1;
		end
	else
		return false, nil, -1, -1, -1;
	end
end

--
local function VUHDO_friendValidator(anInfo, _)
  return UnitIsFriend("player", anInfo["unit"]), nil, -1, -1, -1;
end

--
local function VUHDO_foeValidator(anInfo, _)
  return not UnitIsFriend("player", anInfo["unit"]), nil, -1, -1, -1;
end



--
local tUnit;
local tDirection;
local tColor = { ["useBackground"] = true, ["noStacksColor"] = true };
local tDefaultColor = { ["R"] = 1, ["G"] = 0.4, ["B"] = 0.4, ["O"] = 1, ["useBackground"] = true, ["useSlotColor"] = true }
local tDistance;
local function VUHDO_directionArrowValidator(anInfo, _)
	tUnit = anInfo["unit"];

	if not VUHDO_shouldDisplayArrow(tUnit) then
		return false, nil, -1, -1, -1;
	end

	tDirection = VUHDO_getUnitDirection(tUnit);
	if not tDirection then
		return false, nil, -1, -1, -1;
	end

	if sIsDistance then
		tDistance = VUHDO_getDistanceBetween("player", tUnit);
		if tDistance then
			tColor["R"], tColor["G"] = VUHDO_getRedGreenForDistance(tDistance);
			tDistance = (tDistance > 0 and tDistance < 100) and floor(tDistance * 0.1) or nil;
			if tDistance then
				tColor["B"], tColor["useText"] = 0.2, true;
				tColor["TR"], tColor["TG"], tColor["TB"] = tColor["R"], tColor["G"], 0.2;
			end
		else
			tDistance = nil;
		end
	else
		tDistance = nil;
	end

	return true, "Interface\\AddOns\\VuhDo\\Images\\Arrow.blp", -1,
		tDistance or -1, -1, tDistance ~= nil and tColor or tDefaultColor, nil, VUHDO_getTexCoordsForCell(VUHDO_getCellForDirection(tDirection));
end



--
local function VUHDO_classColorIfActiveValidator(anInfo, _)
	if VUHDO_getIsCurrentBouquetActive() then
		return true, nil, -1, -1, -1,
			VUHDO_copyColor(VUHDO_USER_CLASS_COLORS[anInfo["classId"]]);
	else
		return false, nil, -1, -1, -1;
	end
end



--
local function VUHDO_classColorValidator(anInfo, _)
	return true, nil, -1, -1, -1,
		VUHDO_copyColor(VUHDO_USER_CLASS_COLORS[anInfo["classId"]]);
end



--
local tUnit;
local function VUHDO_tappedValidator(anInfo, _)
	tUnit = anInfo["unit"];

	if not UnitIsPlayer(tUnit) and UnitIsTapDenied(tUnit) then
		return true, nil, -1, -1, -1,
			VUHDO_copyColor(sBarColors["TAPPED"]);
	else
		return false, nil, -1, -1, -1;
	end
end



-- WA2 sandbox for execution - warning best effort!
-- no overrides for now
local VUHDO_OVERRIDE_FUNCTIONS = { };

local VUHDO_BLOCKED_FUNCTIONS = {
	-- Lua functions that may allow breaking out of the environment
	getfenv = true,
	setfenv = true,
	loadstring = true,
	pcall = true,
	xpcall = true,
	-- blocked WoW API
	SendMail = true,
	SetTradeMoney = true,
	AddTradeMoney = true,
	PickupTradeMoney = true,
	PickupPlayerMoney = true,
	TradeFrame = true,
	MailFrame = true,
	EnumerateFrames = true,
	RunScript = true,
	AcceptTrade = true,
	SetSendMailMoney = true,
	EditMacro = true,
	DevTools_DumpCommand = true,
	hash_SlashCmdList = true,
	RegisterNewSlashCommand = true,
	CreateMacro = true,
	SetBindingMacro = true,
	GuildDisband = true,
	GuildUninvite = true,
	securecall = true,
	DeleteCursorItem = true,
	ChatEdit_SendText = true,
	ChatEdit_ActivateChat = true,
	ChatEdit_ParseText = true,
	ChatEdit_OnEnterPressed = true,
	GetButtonMetatable = true,
	GetEditBoxMetatable = true,
	GetFontStringMetatable = true,
	GetFrameMetatable = true
};

local VUHDO_BLOCKED_TABLES = {
	SlashCmdList = true,
	SendMailMailButton = true,
	SendMailMoneyGold = true,
	MailFrameTab2 = true,
	BankFrame = true,
	TradeFrame = true,
	GuildBankFrame = true,
	MailFrame = true,
	C_GMTicketInfo = true,
	WeakAurasSaved = true,
	WeakAurasOptions = true,
	WeakAurasOptionsSaved = true,
	PlaterDB = true,
	_detalhes_global = true,
	_detalhes = true,
	DEFAULT_CHAT_FRAME = true,
	ChatFrame1 = true
};



--
local function VUHDO_blockedFunction()
	DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_CUSTOM_FLAG_BLOCKED, 1.0, 0.0, 0.0);
end



local env_getglobal;
local exec_env = setmetatable({}, { 
	__index =
		function(t, k)
			if k == "_G" then
				return t
			elseif k == "getglobal" then
				return env_getglobal
			elseif VUHDO_BLOCKED_FUNCTIONS[k] then
				VUHDO_blockedFunction()

				return function() end
			elseif VUHDO_BLOCKED_TABLES[k] then 
				VUHDO_blockedFunction()

				return {}
			elseif VUHDO_OVERRIDE_FUNCTIONS[k] then
				return VUHDO_OVERRIDE_FUNCTIONS[k]
			else
				return _G[k]
			end
		end, 
	__newindex = 
		function(t, k, v) 
			VUHDO_blockedFunction()
		end,
	__metatable = false
});



--
function env_getglobal(k)
	return exec_env[k];
end



--
local function VUHDO_customFlagValidator(anInfo, aCustom)
	if aCustom and aCustom["custom"] and aCustom["custom"]["function"] then
		local customCodeString = "return true;";

		-- compatibility with prior alphas where default code string was '1'
		if aCustom["custom"]["function"] ~= "1" then
			customCodeString = aCustom["custom"]["function"];
		end

		local loadedFunction, errorString = loadstring("local VUHDO_unitInfo = _G[\"VUHDO_anInfo\"]; " .. customCodeString);

		if loadedFunction then
			_G["VUHDO_anInfo"] = anInfo;
			setfenv(loadedFunction, exec_env);
			local _, ret, ret2, ret3, ret4, ret5 = xpcall(loadedFunction, 
				function() 
					DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_CUSTOM_FLAG_EXECUTE, 1.0, 0.0, 0.0);
					DEFAULT_CHAT_FRAME:AddMessage(debugstack(1, 2, 0), 1.0, 0.0, 0.0);
					DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_INVALID_VALIDATOR, 1.0, 0.0, 0.0);
					DEFAULT_CHAT_FRAME:AddMessage(aCustom["custom"]["function"], 1.0, 0.0, 0.0);

					return false, nil, -1, -1, -1; 
				end
			);

			if ret and ret == true then
				return true, nil, -1, -1, -1;
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_CUSTOM_FLAG_LOAD, 1.0, 0.0, 0.0);
			DEFAULT_CHAT_FRAME:AddMessage(errorString, 1.0, 0.0, 0.0);
			DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_INVALID_VALIDATOR, 1.0, 0.0, 0.0);
			DEFAULT_CHAT_FRAME:AddMessage(aCustom["custom"]["function"], 1.0, 0.0, 0.0);
		end
	end

	return false, nil, -1, -1, -1;
end



--
local tUnit;
local function VUHDO_enemyStateValidator(anInfo, _)
	tUnit = anInfo["unit"];
	if UnitIsFriend("player", tUnit) then
		return true, nil, -1, -1, -1,
			VUHDO_copyColor(sBarColors["TARGET_FRIEND"]);
	elseif UnitIsEnemy("player", tUnit) then
		return true, nil, -1, -1, -1,
			VUHDO_copyColor(sBarColors["TARGET_ENEMY"]);
	else
		return true, nil, -1, -1, -1,
			VUHDO_copyColor(sBarColors["TARGET_NEUTRAL"]);
	end
end

-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom



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
local function VUHDO_alwaysTrueValidator(_, _)
	return true, nil, -1, -1, -1;
end



--
local VUHDO_chiHarmonyIconValidator;
do
	local tUnitHotList;
	local tUnitHotCount;
	local tUnitHotInfo;
	local tTimer;
	local tDuration;
	VUHDO_chiHarmonyIconValidator = function(anInfo, aSourceType)

		tUnitHotList, tUnitHotCount = VUHDO_getUnitHot(anInfo["unit"], "Renewing Mist", aSourceType);

		if tUnitHotList and tUnitHotCount and tUnitHotCount > 0 then
			-- tUnitHotInfo: aura icon, expiration, stacks, duration, isMine, name, spell ID
			tUnitHotInfo = VUHDO_getUnitHotInfo(anInfo["unit"], tUnitHotList["auraInstanceId"]);

			-- Renewing Mist icon when empowered with Chi Harmony is 5901829
			if tUnitHotInfo and tUnitHotInfo[1] == 5901829 then
				tTimer = floor((GetTime() - tUnitHotInfo[2] + tUnitHotInfo[4]) * 10) * 0.1;

				-- 6 sec duration Renewing Mist from Rapid Diffusion extended up to 8 sec via Rising Mist   
				if tUnitHotInfo[4] >= 8 then
					tDuration = 8;
				else
					tDuration = tUnitHotInfo[4];
				end

				if tTimer <= tDuration then
					-- Chi Harmony icon is 1381294
					return true, 1381294, tDuration - tTimer, 1, tDuration;
				end
			end
		end

		return false, nil, -1, -1, -1;

	end
end



--
local function VUHDO_chiHarmonyIconMineValidator(anInfo, _)

	return VUHDO_chiHarmonyIconValidator(anInfo, VUHDO_UNIT_HOT_TYPE_MINE);

end



--
local function VUHDO_chiHarmonyIconOthersValidator(anInfo, _)

	return VUHDO_chiHarmonyIconValidator(anInfo, VUHDO_UNIT_HOT_TYPE_OTHERS);

end



--
local function VUHDO_chiHarmonyIconBothValidator(anInfo, _)

	return VUHDO_chiHarmonyIconValidator(anInfo, VUHDO_UNIT_HOT_TYPE_BOTH);

end



--
VUHDO_BOUQUET_BUFFS_SPECIAL = {
	["AGGRO"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_AGGRO,
		["validator"] = VUHDO_aggroValidator,
		["interests"] = { VUHDO_UPDATE_AGGRO },
	},

	["OUTSIDE_ZONE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OUTSIDE_ZONE,
		["validator"] = VUHDO_outsideZoneValidator,
		["interests"] = { },
	},

	["INSIDE_ZONE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_INSIDE_ZONE,
		["validator"] = VUHDO_insideZoneValidator,
		["interests"] = { },
	},

	["NO_RANGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OUT_OF_RANGE,
		["validator"] = VUHDO_outOfRangeValidator,
		["interests"] = { VUHDO_UPDATE_RANGE },
	},

	["IN_RANGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_IN_RANGE,
		["validator"] = VUHDO_inRangeValidator,
		["interests"] = { VUHDO_UPDATE_RANGE },
	},

	["IS_PHASED_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_IS_PHASED,
		["validator"] = VUHDO_isPhasedValidator,
		["interests"] = { VUHDO_UPDATE_RANGE, VUHDO_UPDATE_PHASE },
	},

	["IS_WAR_MODE_PHASED_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_IS_WAR_MODE_PHASED,
		["validator"] = VUHDO_isWarModePhasedValidator,
		["interests"] = { VUHDO_UPDATE_RANGE, VUHDO_UPDATE_PHASE },
	},

	["YARDS_RANGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_IN_YARDS,
		["validator"] = VUHDO_inYardsRangeValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["OTHER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OTHER_HOTS,
		["validator"] = VUHDO_otherPlayersHotsValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["SWIFTMEND"] = {
		["displayName"] = VUHDO_I18N_SWIFTMEND_POSSIBLE,
		["validator"] = VUHDO_swiftmendValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["DEBUFF_MAGIC"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_MAGIC,
		["validator"] = VUHDO_debuffMagicValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_DISEASE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_DISEASE,
		["validator"] = VUHDO_debuffDiseaseValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_POISON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_POISON,
		["validator"] = VUHDO_debuffPoisonValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_CURSE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_CURSE,
		["validator"] = VUHDO_debuffCurseValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_BLEED"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_BLEED,
		["validator"] = VUHDO_debuffBleedValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_ENRAGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_ENRAGE,
		["validator"] = VUHDO_debuffEnrageValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_CHARMED"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CHARMED,
		["validator"] = VUHDO_debuffCharmedValidator,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_BAR_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR,
		["validator"] = VUHDO_debuffBarColorValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEAD"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEAD,
		["validator"] = VUHDO_deadValidator,
		["interests"] = { VUHDO_UPDATE_ALIVE },
	},

	["DISCONNECTED"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DISCONNECTED,
		["validator"] = VUHDO_disconnectedValidator,
		["interests"] = { VUHDO_UPDATE_DC },
	},

	["AFK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_AFK,
		["validator"] = VUHDO_afkValidator,
		["interests"] = { VUHDO_UPDATE_AFK },
	},

	["PLAYER_TARGET"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_PLAYER_TARGET,
		["validator"] = VUHDO_playerTargetValidator,
		["interests"] = { VUHDO_UPDATE_TARGET },
	},

	["PLAYER_FOCUS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_PLAYER_FOCUS,
		["validator"] = VUHDO_playerFocusValidator,
		["interests"] = { VUHDO_UPDATE_PLAYER_FOCUS },
	},

	["MOUSE_TARGET"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET,
		["validator"] = VUHDO_mouseOverTargetValidator,
		["interests"] = { VUHDO_UPDATE_MOUSEOVER },
	},

	["MOUSE_GROUP"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP,
		["validator"] = VUHDO_mouseOverGroupValidator,
		["interests"] = { VUHDO_UPDATE_MOUSEOVER_GROUP },
	},

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

	["NUM_CLUSTER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER,
		["validator"] = VUHDO_numInClusterValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PLAYERS,
		["interests"] = { VUHDO_UPDATE_NUM_CLUSTER },
	},

	["MOUSE_CLUSTER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER,
		["validator"] = VUHDO_mouseClusterValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_MOUSEOVER_CLUSTER },
	},

	["THREAT_LEVEL_MEDIUM"] = {
		["displayName"] = VUHDO_I18N_THREAT_LEVEL_MEDIUM,
		["validator"] = VUHDO_threatMediumValidator,
		["interests"] = { VUHDO_UPDATE_THREAT_LEVEL },
	},

	["THREAT_LEVEL_HIGH"] = {
		["displayName"] = VUHDO_I18N_THREAT_LEVEL_HIGH,
		["validator"] = VUHDO_threatHighValidator,
		["interests"] = { VUHDO_UPDATE_THREAT_LEVEL },
	},

	["RAID_ICON_COLOR"] = {
		["displayName"] = VUHDO_I18N_UPDATE_RAID_TARGET,
		["validator"] = VUHDO_raidTargetValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_RAID_TARGET },
	},

	["OVERHEAL_HIGHLIGHT"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT,
		["validator"] = VUHDO_overhealHighlightValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_INC },
	},

	["EMERGENCY_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_EMERGENCY_COLOR,
		["validator"] = VUHDO_emergencyColorValidator,
		["interests"] = { VUHDO_UPDATE_EMERGENCY },
	},

	["RESURRECTION"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_RESURRECTION,
		["validator"] = VUHDO_resurrectionValidator,
		["interests"] = { VUHDO_UPDATE_RESURRECTION },
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

	["STATUS_CC_ACTIVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_CLASS_COLOR_IF_ACTIVE,
		["validator"] = VUHDO_classColorIfActiveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS,
		["no_color"] = true,
		["interests"] = { },
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

	["HAS_SUMMON_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_HAS_SUMMON_ICON,
		["validator"] = VUHDO_hasSummonIconValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_SUMMON },
	},

	["CLASS_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CLASS_ICON,
		["validator"] = VUHDO_classIconValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["RAID_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_RAID_ICON,
		["validator"] = VUHDO_raidIconValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["RAID_ICON_TARGET"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_TARGET_RAID_ICON,
		["validator"] = VUHDO_raidIconTargetValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["ROLE_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ROLE_ICON,
		["validator"] = VUHDO_roleIconValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["ROLE_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ROLE_TANK,
		["validator"] = VUHDO_roleTankValidator,
		["interests"] = { },
	},

	["ROLE_DAMAGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ROLE_DAMAGE,
		["validator"] = VUHDO_roleDamageValidator,
		["interests"] = { },
	},

	["ROLE_HEALER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ROLE_HEALER,
		["validator"] = VUHDO_roleHealerValidator,
		["interests"] = { },
	},

        ["WARRIOR_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_WARRIOR_TANK,
		["validator"] = VUHDO_warriorTankValidator,
		["interests"] = { },
	},

        ["PALADIN_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_PALADIN_TANK,
		["validator"] = VUHDO_paladinTankValidator,
		["interests"] = { },
	},

        ["DK_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DK_TANK,
		["validator"] = VUHDO_dkTankValidator,
		["interests"] = { },
	},

        ["MONK_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MONK_TANK,
		["validator"] = VUHDO_monkTankValidator,
		["interests"] = { },
	},

        ["DRUID_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DRUID_TANK,
		["validator"] = VUHDO_druidTankValidator,
		["interests"] = { },
	},

        ["DEMON_HUNTER_TANK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEMON_HUNTER_TANK,
		["validator"] = VUHDO_demonHunterTankValidator,
		["interests"] = { },
	},

	["DIRECTION"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DIRECTION_ARROW,
		["validator"] = VUHDO_directionArrowValidator,
		--["no_color"] = true,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_RANGE, VUHDO_UPDATE_ALIVE },
	},

	["CUSTOM_DEBUFF"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CUSTOM_DEBUFF,
		["validator"] = VUHDO_customDebuffIconValidator,
		["updateCyclic"] = true,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_CUSTOM_DEBUFF },
	},

	["TAPPED"] = {
		["displayName"] = VUHDO_I18N_TAPPED_COLOR,
		["validator"] = VUHDO_tappedValidator,
		["no_color"] = true,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["ENEMY_STATE"] = {
		["displayName"] = VUHDO_I18N_ENEMY_STATE_COLOR,
		["validator"] = VUHDO_enemyStateValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_UNIT_TARGET },
	},

	["SPELL_TRACE"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE,
		["validator"] = VUHDO_spellTraceValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["SPELL_TRACE_INCOMING"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE_INCOMING,
		["validator"] = VUHDO_spellTraceIncomingValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["SPELL_TRACE_HEAL"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE_HEAL,
		["validator"] = VUHDO_spellTraceHealValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["SPELL_TRACE_SINGLE"] = {
		["displayName"] = VUHDO_I18N_SPELL_TRACE_SINGLE,
		["validator"] = VUHDO_spellTraceSingleValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_SPELL_TRACE,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["TRAIL_OF_LIGHT"] = {
		["displayName"] = VUHDO_I18N_TRAIL_OF_LIGHT,
		["validator"] = VUHDO_trailOfLightValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["TRAIL_OF_LIGHT_NEXT"] = {
		["displayName"] = VUHDO_I18N_TRAIL_OF_LIGHT_NEXT,
		["validator"] = VUHDO_trailOfLightNextValidator,
		["interests"] = { VUHDO_UPDATE_SPELL_TRACE },
	},

	["AOE_ADVICE"] = {
		["displayName"] = VUHDO_I18N_AOE_ADVICE,
		["validator"] = VUHDO_aoeAdviceValidator,
		["interests"] = { VUHDO_UPDATE_AOE_ADVICE },
	},

	["LEADER"] = {
		["displayName"] = VUHDO_I18N_DEF_RAID_LEADER,
		["validator"] = VUHDO_leaderIconValidator,
		["interests"] = { VUHDO_UPDATE_MINOR_FLAGS },
	},

	["ASSISTANT"] = {
		["displayName"] = VUHDO_I18N_DEF_RAID_ASSIST,
		["validator"] = VUHDO_assistantIconValidator,
		["interests"] = { VUHDO_UPDATE_MINOR_FLAGS },
	},

	["LOOT_MASTER"] = {
		["displayName"] = VUHDO_I18N_DEF_MASTER_LOOTER,
		["validator"] = VUHDO_masterLooterIconValidator,
		["interests"] = { VUHDO_UPDATE_MINOR_FLAGS },
	},

	["PVP_FLAG"] = {
		["displayName"] = VUHDO_I18N_DEF_PVP_STATUS,
		["validator"] = VUHDO_pvpIconValidator,
		["interests"] = { VUHDO_UPDATE_MINOR_FLAGS },
	},

	["FRIEND"] = {
		["displayName"] = VUHDO_I18N_FRIEND_STATUS,
		["validator"] = VUHDO_friendValidator,
		["interests"] = { },
	},

	["FOE"] = {
		["displayName"] = VUHDO_I18N_FOE_STATUS,
		["validator"] = VUHDO_foeValidator,
		["interests"] = { },
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

	["CLASS_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CLASS_COLOR,
		["validator"] = VUHDO_classColorValidator,
		["no_color"] = true,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS,
		["interests"] = { },
	},

	["ALWAYS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ALWAYS,
		["validator"] = VUHDO_alwaysTrueValidator,
		["interests"] = { },
	},

	["CHI_HARMONY_ICON_MINE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_MINE,
		["validator"] = VUHDO_chiHarmonyIconMineValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["CHI_HARMONY_ICON_OTHERS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_OTHERS,
		["validator"] = VUHDO_chiHarmonyIconOthersValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["CHI_HARMONY_ICON_BOTH"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_BOTH,
		["validator"] = VUHDO_chiHarmonyIconBothValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["CUSTOM_FLAG"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CUSTOM_FLAG,
		["validator"] = VUHDO_customFlagValidator, 
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_CUSTOM_FLAG,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_ALIVE }, --ignoring some for now (eg. VUHDO_UPDATE_INC, VUHDO_UPDATE_NUM_CLUSTER, VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC, etc.)
	},

};

