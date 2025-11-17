VUHDO_FORCE_RESET = false;

local GetTexCoordsForRole = GetTexCoordsForRole or VUHDO_getTexCoordsForRole;
local GetRaidTargetIndex = GetRaidTargetIndex;
local UnitExists = UnitExists;
local UnitIsPVP = UnitIsPVP;
local UnitFactionGroup = UnitFactionGroup;
local UnitIsFriend = UnitIsFriend;
local UnitIsEnemy = UnitIsEnemy;
local UnitIsPlayer = UnitIsPlayer;
local UnitIsTapDenied = UnitIsTapDenied;
local GetTime = GetTime;
local floor = floor;
local _;

local VUHDO_RAID = { };
local VUHDO_USER_CLASS_COLORS;
local VUHDO_PANEL_SETUP;
local VUHDO_CONFIG;

local VUHDO_UNIT_HOT_TYPE_MINE;
local VUHDO_UNIT_HOT_TYPE_OTHERS;
local VUHDO_UNIT_HOT_TYPE_BOTH;

local VUHDO_EMERGENCIES;

local VUHDO_getChosenDebuffInfo;
local VUHDO_getCurrentPlayerTarget;
local VUHDO_getCurrentPlayerFocus;
local VUHDO_getCurrentMouseOver;
local VUHDO_isUnitSwiftmendable;
local VUHDO_getDebuffColor;
local VUHDO_getIsCurrentBouquetActive;
local VUHDO_getUnitDebuffSchoolInfos;
local VUHDO_getRaidTargetIconTexture;
local VUHDO_getUnitGroupPrivileges;
local VUHDO_getLatestCustomDebuff;
local VUHDO_getUnitHot;
local VUHDO_getUnitHotInfo;

local sBarColors;
local sIsDistance;

local sCustomFlagCache = { };
local sCustomFlagErrorHandler;



--
local tHash;
local tLen;
local function VUHDO_getCustomCodeHash(aCustomCodeString)

	tHash = 0;
	tLen = #aCustomCodeString;

	for tCnt = 1, tLen do
		tHash = ((tHash * 31) + string.byte(aCustomCodeString, tCnt)) % 0x7FFFFFFF;
	end

	return tHash;

end



--
local function VUHDO_customFlagErrorHandler()

	DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_CUSTOM_FLAG_EXECUTE, 1.0, 0.0, 0.0);
	DEFAULT_CHAT_FRAME:AddMessage(debugstack(1, 2, 0), 1.0, 0.0, 0.0);
	DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_INVALID_VALIDATOR, 1.0, 0.0, 0.0);

	return false, nil, -1, -1, -1;

end



--
function VUHDO_clearCustomFlagCache()

	table.wipe(sCustomFlagCache);

	return;

end



----------------------------------------------------------



function VUHDO_bouquetValidatorsInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_USER_CLASS_COLORS = _G["VUHDO_USER_CLASS_COLORS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];

	VUHDO_UNIT_HOT_TYPE_MINE = _G["VUHDO_UNIT_HOT_TYPE_MINE"];
	VUHDO_UNIT_HOT_TYPE_OTHERS = _G["VUHDO_UNIT_HOT_TYPE_OTHERS"];
	VUHDO_UNIT_HOT_TYPE_BOTH = _G["VUHDO_UNIT_HOT_TYPE_BOTH"];

	VUHDO_EMERGENCIES = _G["VUHDO_EMERGENCIES"];

	VUHDO_getChosenDebuffInfo = _G["VUHDO_getChosenDebuffInfo"];
	VUHDO_getCurrentPlayerTarget = _G["VUHDO_getCurrentPlayerTarget"];
	VUHDO_getCurrentPlayerFocus = _G["VUHDO_getCurrentPlayerFocus"];
	VUHDO_getCurrentMouseOver = _G["VUHDO_getCurrentMouseOver"];
	VUHDO_isUnitSwiftmendable = _G["VUHDO_isUnitSwiftmendable"];
	VUHDO_getDebuffColor = _G["VUHDO_getDebuffColor"];
	VUHDO_getUnitDebuffSchoolInfos = _G["VUHDO_getUnitDebuffSchoolInfos"];
	VUHDO_getIsCurrentBouquetActive = _G["VUHDO_getIsCurrentBouquetActive"];

	VUHDO_getRaidTargetIconTexture = _G["VUHDO_getRaidTargetIconTexture"];
	VUHDO_getUnitGroupPrivileges = _G["VUHDO_getUnitGroupPrivileges"];
	VUHDO_getLatestCustomDebuff = _G["VUHDO_getLatestCustomDebuff"];
	VUHDO_getUnitHot = _G["VUHDO_getUnitHot"];
	VUHDO_getUnitHotInfo = _G["VUHDO_getUnitHotInfo"];

	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	sIsDistance = VUHDO_CONFIG["DIRECTION"]["isDistanceText"];

	sCustomFlagErrorHandler = VUHDO_customFlagErrorHandler;

	if VUHDO_mergeSpellTraceValidators then
		VUHDO_mergeSpellTraceValidators();
	end

	if VUHDO_mergeStatusValidators then
		VUHDO_mergeStatusValidators();
	end

	return;

end



local tEmptyInfo = { };



----------------------------------------------------------



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, clipLeft, clipRight, clipTop, clipBottom































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
	-- 隱藏傷害輸出角色圖示
	-- elseif VUHDO_ID_MELEE_DAMAGE == anInfo["role"] or VUHDO_ID_RANGED_DAMAGE == anInfo["role"] then
	--	return true, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES", -1, -1, -1, nil, nil, GetTexCoordsForRole("DAMAGER");
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

	if not VUHDO_USER_CLASS_COLORS then
		VUHDO_initClassColors();
	end

	if VUHDO_getIsCurrentBouquetActive() then
		if VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[anInfo["classId"]] then
			return true, nil, -1, -1, -1,
				VUHDO_copyColor(VUHDO_USER_CLASS_COLORS[anInfo["classId"]]);
		else
			return true, nil, -1, -1, -1, nil;
		end
	else
		return false, nil, -1, -1, -1;
	end

end



--
local function VUHDO_classColorValidator(anInfo, _)

	if not VUHDO_USER_CLASS_COLORS then
		VUHDO_initClassColors();
	end

	if VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[anInfo["classId"]] then
		return true, nil, -1, -1, -1,
			VUHDO_copyColor(VUHDO_USER_CLASS_COLORS[anInfo["classId"]]);
	else
		return true, nil, -1, -1, -1, nil;
	end

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
local tCustomCodeString;
local tCodeHash;
local tCachedFunction;
local tLoadedFunction
local tErrorString;
local function VUHDO_customFlagValidator(anInfo, aCustom)

	if aCustom and aCustom["custom"] and aCustom["custom"]["function"] then
		tCustomCodeString = "return true;";

		-- compatibility with prior alphas where default code string was '1'
		if aCustom["custom"]["function"] ~= "1" then
			tCustomCodeString = aCustom["custom"]["function"];
		end

		tCodeHash = VUHDO_getCustomCodeHash(tCustomCodeString);
		tCachedFunction = sCustomFlagCache[tCodeHash];

		if not tCachedFunction then
			tLoadedFunction, tErrorString = loadstring("local VUHDO_unitInfo = _G[\"VUHDO_anInfo\"]; " .. tCustomCodeString);

			if tLoadedFunction then
				setfenv(tLoadedFunction, exec_env);

				sCustomFlagCache[tCodeHash] = tLoadedFunction;
				tCachedFunction = tLoadedFunction;
			else
				DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_CUSTOM_FLAG_LOAD, 1.0, 0.0, 0.0);
				DEFAULT_CHAT_FRAME:AddMessage(tErrorString, 1.0, 0.0, 0.0);
				DEFAULT_CHAT_FRAME:AddMessage(VUHDO_I18N_ERROR_INVALID_VALIDATOR, 1.0, 0.0, 0.0);
				DEFAULT_CHAT_FRAME:AddMessage(aCustom["custom"]["function"], 1.0, 0.0, 0.0);

				return false, nil, -1, -1, -1;
			end
		end

		if tCachedFunction then
			_G["VUHDO_anInfo"] = anInfo;

			local _, ret, ret2, ret3, ret4, ret5 = xpcall(tCachedFunction, sCustomFlagErrorHandler);

			if ret and ret == true then
				return true, nil, -1, -1, -1;
			end
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



	["STATUS_CC_ACTIVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_CLASS_COLOR_IF_ACTIVE,
		["validator"] = VUHDO_classColorIfActiveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS,
		["no_color"] = true,
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
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_RANGE, VUHDO_UPDATE_ALIVE, VUHDO_UPDATE_DC, VUHDO_UPDATE_SPELL_TRACE }, -- ignoring some for now (eg. VUHDO_UPDATE_INC, VUHDO_UPDATE_NUM_CLUSTER, VUHDO_UPDATE_MANA, etc.)
	},

};
