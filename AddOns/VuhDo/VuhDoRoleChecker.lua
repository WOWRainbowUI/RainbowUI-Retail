VUHDO_MANUAL_ROLES = { };

local VUHDO_FIX_ROLES = { };
local VUHDO_INSPECTED_ROLES = { };
local VUHDO_DF_TOOL_ROLES = { };
local VUHDO_ROLE_BY_SPEC = {
	-- [<unit name>] = <VUHDO_ID_MELEE_TANK|VUHDO_ID_MELEE_DAMAGE|VUHDO_ID_RANGED_DAMAGE|VUHDO_ID_RANGED_HEAL>,
};

local VUHDO_INSPECT_TIMEOUT = 5;

--local tPoints1, tPoints2, tPoints3, tRank;
VUHDO_NEXT_INSPECT_UNIT = nil;
VUHDO_NEXT_INSPECT_TIME_OUT = nil;


--------------------------------------------------------------
local NotifyInspect = NotifyInspect;
local GetSpecializationInfo = GetSpecializationInfo;
local ClearInspectPlayer = ClearInspectPlayer;
local UnitStat = UnitStat;
local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
local UnitPowerType = UnitPowerType;
local VUHDO_isUnitInModel;
local VUHDO_checkInteractDistance;
local pairs = pairs;
local Ambiguate = Ambiguate;
local _;

local VUHDO_MANUAL_ROLES;
local VUHDO_RAID_NAMES;
local VUHDO_RAID;

function VUHDO_roleCheckerInitLocalOverrides()
	VUHDO_MANUAL_ROLES = _G["VUHDO_MANUAL_ROLES"];
	VUHDO_RAID_NAMES = _G["VUHDO_RAID_NAMES"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_isUnitInModel = _G["VUHDO_isUnitInModel"];
	VUHDO_checkInteractDistance = _G["VUHDO_checkInteractDistance"];
end
--------------------------------------------------------------



-- Reset if spec changed or slash command
local tName;
function VUHDO_resetTalentScan(aUnit)

	if VUHDO_PLAYER_RAID_ID == aUnit then
		aUnit = "player";
	end

	local tInfo = VUHDO_RAID[aUnit];

	if tInfo then
		tName = tInfo["name"];

		if tName then
			VUHDO_INSPECTED_ROLES[tName] = nil;
			VUHDO_FIX_ROLES[tName] = nil;
			VUHDO_DF_TOOL_ROLES[tName] = nil;
			VUHDO_ROLE_BY_SPEC[tName] = nil;
		end
	end

end



--
function VUHDO_trimInspected()
	for tName, _ in pairs(VUHDO_INSPECTED_ROLES) do
		if not VUHDO_RAID_NAMES[tName] then
			VUHDO_INSPECTED_ROLES[tName] = nil;
			VUHDO_FIX_ROLES[tName] = nil;
		end
	end
end



-- If timeout after talent tree server request
function VUHDO_setRoleUndefined(aUnit)
	local tInfo = VUHDO_RAID[aUnit];
	if tInfo then	VUHDO_INSPECTED_ROLES[tInfo["name"]] = nil;	end
end



local VUHDO_CLASS_ROLES = {
	[VUHDO_ID_ROGUES] = VUHDO_ID_MELEE_DAMAGE,
	[VUHDO_ID_MAGES] = VUHDO_ID_RANGED_DAMAGE,
	[VUHDO_ID_WARLOCKS] = VUHDO_ID_RANGED_DAMAGE,
};



--
local tInfo;
local tName;
local function VUHDO_shouldBeInspected(aUnit)

	if "focus" == aUnit or "target" == aUnit then
		return false;
	end

	tInfo = VUHDO_RAID[aUnit];

	if tInfo["isPet"] or not tInfo["connected"] then
		return false;
	end

	-- Determined by role or can't tell by talent trees (dk)?
	if VUHDO_CLASS_ROLES[tInfo["classId"]] then -- VUHDO_ID_DEATH_KNIGHT, hat zwar keine feste Rolle, Talentb�ume bringen aber auch nichts
		return false;
	end

	-- Already inspected or manually overridden?
	-- or assigned tank or heal via dungeon finder? (in case of DPS inspect anyway)
	tName = tInfo["name"];
	if VUHDO_INSPECTED_ROLES[tName] or VUHDO_MANUAL_ROLES[tName] or VUHDO_ROLE_BY_SPEC[tName]
		or VUHDO_DF_TOOL_ROLES[tName] == 60 or VUHDO_DF_TOOL_ROLES[tName] == 63 then -- VUHDO_ID_MELEE_TANK -- VUHDO_ID_RANGED_HEAL
		return false;
	end

	-- In inspect range?
	return VUHDO_checkInteractDistance(aUnit, 1);

end



--
function VUHDO_tryInspectNext()
	for tUnit, _ in pairs(VUHDO_RAID) do
		if VUHDO_shouldBeInspected(tUnit) then
			VUHDO_NEXT_INSPECT_TIME_OUT = GetTime() + VUHDO_INSPECT_TIMEOUT;
			VUHDO_NEXT_INSPECT_UNIT = tUnit;

			if "player" == tUnit then VUHDO_inspectLockRole();
			else NotifyInspect(tUnit); end

			return;
		end
	end
end



--
local tActiveTree;
local tInfo;
local tClassId;
local tRole;
local tTreeId;
function VUHDO_inspectRole(aUnit)

	tInfo = VUHDO_RAID[aUnit];

	if not tInfo then 
		return VUHDO_ID_UNDEFINED; 
	end

	if "player" == aUnit then
		tActiveTree = GetSpecialization();

		if not tActiveTree then
			return VUHDO_ID_UNDEFINED;
		end
		
		tTreeId, _, _, _, tRole = GetSpecializationInfo(tActiveTree, false, false);
	else
		tTreeId = GetInspectSpecialization(aUnit);
		tRole = GetSpecializationRoleByID(tTreeId);
	end

	if (tTreeId or 0) == 0 then
		return VUHDO_ID_UNDEFINED;
	end

	if "HEALER" == tRole then
		return VUHDO_ID_RANGED_HEAL;
	elseif "TANK" == tRole then
		return VUHDO_ID_MELEE_TANK;
	elseif "DAMAGER" == tRole then
		tClassId = tInfo["classId"];

		if VUHDO_ID_WARRIORS == tClassId
			or VUHDO_ID_ROGUES == tClassId
			or VUHDO_ID_PALADINS == tClassId
			or VUHDO_ID_MONKS == tClassId
			or VUHDO_ID_DEATH_KNIGHT == tClassId 
			or VUHDO_ID_DEMON_HUNTERS == tClassId then
			return VUHDO_ID_MELEE_DAMAGE;
		elseif VUHDO_ID_SHAMANS == tClassId then
			if 263 == tTreeId then -- Enhancement
				return VUHDO_ID_MELEE_DAMAGE;
			else -- 2
				return VUHDO_ID_RANGED_DAMAGE;
			end
		elseif VUHDO_ID_DRUIDS == tClassId then
			if 103 == tTreeId then -- Feral
				return VUHDO_ID_MELEE_DAMAGE;
			else -- 2
				return VUHDO_ID_RANGED_DAMAGE;
			end
		elseif VUHDO_ID_HUNTERS == tClassId then
			if 255 == tTreeId then -- Survival
				return VUHDO_ID_MELEE_DAMAGE;
			else
				return VUHDO_ID_RANGED_DAMAGE;
			end
		else -- e.g. Evoker Devastation
			return VUHDO_ID_RANGED_DAMAGE;
		end
	else
		return VUHDO_ID_UNDEFINED;
	end

end



--
local tActiveTree;
local tInfo;
local tTreeId;
function VUHDO_inspectLockRole()
	tInfo = VUHDO_RAID[VUHDO_NEXT_INSPECT_UNIT];

	if not tInfo then 
		VUHDO_NEXT_INSPECT_UNIT = nil; 
		return; 
	end

	if "player" == VUHDO_NEXT_INSPECT_UNIT then
		tActiveTree = GetSpecialization();

		if not tActiveTree then
			VUHDO_INSPECTED_ROLES[tInfo["name"]] = VUHDO_ID_UNDEFINED;
			VUHDO_NEXT_INSPECT_UNIT = nil;
			return;
		end

		tTreeId = GetSpecializationInfo(tActiveTree, false, false);
	else
		tTreeId = GetInspectSpecialization(VUHDO_NEXT_INSPECT_UNIT);
	end

	if (tTreeId or 0) == 0 then
		ClearInspectPlayer();
		
		VUHDO_NEXT_INSPECT_UNIT = nil;
		VUHDO_INSPECTED_ROLES[tInfo["name"]] = VUHDO_ID_UNDEFINED;

		return;
	end

	--VUHDO_xMsg(VUHDO_NEXT_INSPECT_UNIT, tTreeId);

	VUHDO_INSPECTED_ROLES[tInfo["name"]] = VUHDO_inspectRole(VUHDO_NEXT_INSPECT_UNIT);

	ClearInspectPlayer();
	VUHDO_NEXT_INSPECT_UNIT = nil;
	VUHDO_normalRaidReload();
end



--
local tDfRole, tOldRole, tReturnRole, tName;
local function VUHDO_determineDfToolRole(anInfo)

	tName = anInfo["name"];
	tOldRole = VUHDO_DF_TOOL_ROLES[tName];
	tDfRole = UnitGroupRolesAssigned(anInfo["unit"]);

	if "NONE" == tDfRole then
		VUHDO_DF_TOOL_ROLES[tName] = nil;
		tReturnRole = nil;
	elseif "TANK" == tDfRole then
		VUHDO_DF_TOOL_ROLES[tName] = 60; -- VUHDO_ID_MELEE_TANK
		tReturnRole = 60; -- VUHDO_ID_MELEE_TANK
	elseif "HEALER" == tDfRole then
		VUHDO_DF_TOOL_ROLES[tName] = 63; -- VUHDO_ID_RANGED_HEAL
		tReturnRole = 63; -- VUHDO_ID_RANGED_HEAL
	elseif "DAMAGER" == tDfRole then
		if anInfo["classId"] == VUHDO_ID_WARRIORS
			or anInfo["classId"] == VUHDO_ID_PALADINS
			or anInfo["classId"] == VUHDO_ID_DEATH_KNIGHT
			or anInfo["classId"] == VUHDO_ID_MONKS 
			or anInfo["classId"] == VUHDO_ID_DEMON_HUNTERS 
			or anInfo["classId"] == VUHDO_ID_ROGUES 
			or (anInfo["classId"] == VUHDO_ID_DRUIDS
				and not UnitPowerType(anInfo["unit"]) == VUHDO_UNIT_POWER_LUNAR_POWER) then
			VUHDO_DF_TOOL_ROLES[tName] = VUHDO_ID_MELEE_DAMAGE;
			tReturnRole = VUHDO_ID_MELEE_DAMAGE;
		elseif anInfo["classId"] == VUHDO_ID_PRIESTS 
			or anInfo["classId"] == VUHDO_ID_WARLOCKS 
			or anInfo["classId"] == VUHDO_ID_MAGES 
			or anInfo["classId"] == VUHDO_ID_EVOKERS
			or (anInfo["classId"] == VUHDO_ID_DRUIDS
				and UnitPowerType(anInfo["unit"]) == VUHDO_UNIT_POWER_LUNAR_POWER) then
			VUHDO_DF_TOOL_ROLES[tName] = VUHDO_ID_RANGED_DAMAGE;
			tReturnRole = VUHDO_ID_RANGED_DAMAGE;
		elseif anInfo["classId"] == VUHDO_ID_DRUIDS then
			-- Feral since neither Restoration or Moonkin has previously matched
			VUHDO_DF_TOOL_ROLES[tName] = VUHDO_ID_MELEE_DAMAGE;
			tReturnRole = VUHDO_ID_MELEE_DAMAGE;
		elseif anInfo["classId"] == VUHDO_ID_HUNTERS then
			-- Hunters default to ranged but require inspect to determine spec ID so no return
			VUHDO_DF_TOOL_ROLES[tName] = VUHDO_ID_RANGED_DAMAGE;
			tReturnRole = nil;
		else
			-- Shaman default to melee but require inspect to determine spec ID so no return
			VUHDO_DF_TOOL_ROLES[tName] = VUHDO_ID_MELEE_DAMAGE;
			tReturnRole = nil;
		end
	end

	if tOldRole ~= VUHDO_DF_TOOL_ROLES[tName] then
		VUHDO_normalRaidReload();
	end

	return tReturnRole;

end



--
local tInfo;
local tPowerType;
local tBuffExist;
local tFixRole;
local tIntellect, tStrength, tAgility;
local tClassId, tClassRole, tName;
local tRole;
function VUHDO_determineRole(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	if not tInfo or tInfo["isPet"] then	return nil; end

	tName = tInfo["name"];

	-- Manual role override oder dungeon finder role?
	tFixRole = VUHDO_MANUAL_ROLES[tName] or VUHDO_determineDfToolRole(tInfo);

	if tFixRole then
		return tFixRole;
	end

	-- Assigned for MT?
	if VUHDO_isUnitInModel(aUnit, 41) then -- VUHDO_ID_MAINTANKS
		return 60; -- VUHDO_ID_MELEE_TANK
	end

	-- Role determined by non-hybrid class?
	tClassId = tInfo["classId"];
	tClassRole = VUHDO_CLASS_ROLES[tClassId];
	if tClassRole then
		return tClassRole;
	end

	tFixRole = VUHDO_ROLE_BY_SPEC[tName];

	if tFixRole then
		return tFixRole;
	end

	-- Talent tree inspected?
	if (VUHDO_INSPECTED_ROLES[tName] or VUHDO_ID_UNDEFINED) ~= VUHDO_ID_UNDEFINED then
		return VUHDO_INSPECTED_ROLES[tName];
	end

	-- Talent tree immediately inspectable?
	tRole = VUHDO_inspectRole(aUnit);

	if (tRole or VUHDO_ID_UNDEFINED) ~= VUHDO_ID_UNDEFINED then
		return tRole;
	end

	-- Estimated role fixed?
	if VUHDO_FIX_ROLES[tName] then
		return VUHDO_FIX_ROLES[tName];
	end

	if 29 == tClassId then -- VUHDO_ID_DEATH_KNIGHT
		tBuffExist = VUHDO_unitBuff(aUnit, VUHDO_SPELL_ID.BUFF_BLOOD_PRESENCE);
		if tBuffExist then
			--VUHDO_FIX_ROLES[tName] = 60; -- VUHDO_ID_MELEE_TANK
			return 60; -- VUHDO_ID_MELEE_TANK
		else
			VUHDO_FIX_ROLES[tName] = 61; -- VUHDO_ID_MELEE_DAMAGE
			return 61; -- VUHDO_ID_MELEE_DAMAGE
		end

	elseif 28 == tClassId then -- VUHDO_ID_PRIESTS
		tPowerType = UnitPowerType(aUnit);
		if VUHDO_UNIT_POWER_INSANITY == tPowerType then
			VUHDO_FIX_ROLES[tName] = 62; -- VUHDO_ID_RANGED_DAMAGE
			return 62; -- VUHDO_ID_RANGED_DAMAGE
		else
			return 63; -- VUHDO_ID_RANGED_HEAL
		end

	elseif 20 == tClassId then -- VUHDO_ID_WARRIORS
		if (0 > 2) then -- FIXME: need replacement for UnitDefense check
			return 60; -- VUHDO_ID_MELEE_TANK
		else
			return 61; -- VUHDO_ID_MELEE_DAMAGE
		end

	elseif 27 == tClassId then -- VUHDO_ID_DRUIDS
		tPowerType = UnitPowerType(aUnit);
		if VUHDO_UNIT_POWER_MANA == tPowerType then
			return 63; -- VUHDO_ID_RANGED_HEAL
		elseif VUHDO_UNIT_POWER_LUNAR_POWER == tPowerType then
			VUHDO_FIX_ROLES[tName] = 62; --	VUHDO_ID_RANGED_DAMAGE
			return 62; -- VUHDO_ID_RANGED_DAMAGE
		elseif VUHDO_UNIT_POWER_RAGE == tPowerType then
			VUHDO_FIX_ROLES[tName] = 60; -- VUHDO_ID_MELEE_TANK
			return 60; -- VUHDO_ID_MELEE_TANK
		elseif VUHDO_UNIT_POWER_ENERGY == tPowerType then
			VUHDO_FIX_ROLES[tName] = 61; -- VUHDO_ID_MELEE_DAMAGE
			return 61; -- VUHDO_ID_MELEE_DAMAGE
		end

	elseif 23 == tClassId then -- VUHDO_ID_PALADINS
		if 0 > 2 then -- FIXME: need replacement for UnitDefense check
			return 60; -- VUHDO_ID_MELEE_TANK
		else
			tIntellect = UnitStat(aUnit, 4);
			tStrength = UnitStat(aUnit, 1);

			if tIntellect > tStrength then
				return 63; -- VUHDO_ID_RANGED_HEAL
			else
				return 61; -- VUHDO_ID_MELEE_DAMAGE
			end
		end

	elseif 26 == tClassId then -- VUHDO_ID_SHAMANS
		tIntellect = UnitStat(aUnit, 4);
		tAgility = UnitStat(aUnit, 2);

		if tAgility > tIntellect then
			return 61; -- VUHDO_ID_MELEE_DAMAGE
		else
			tPowerType = UnitPowerType(aUnit);
			if VUHDO_UNIT_POWER_MAELSTROM == tPowerType then -- VUHDO_ID_RANGED_DAMAGE
				return 62; -- VUHDO_ID_RANGED_DAMAGE
			else
				return 63; -- VUHDO_ID_RANGED_HEAL
			end
		end

	elseif 31 == tClassId then -- VUHDO_ID_DEMON_HUNTERS
		tPowerType = UnitPowerType(aUnit);
		if VUHDO_UNIT_POWER_PAIN == tPowerType then
			return 60; -- VUHDO_ID_MELEE_TANK
		else
			return 61; -- VUHDO_ID_MELEE_DAMAGE
		end

	elseif 22 == tClassId then -- VUHDO_ID_HUNTERS
		if UnitPowerMax(aUnit) == 100 then -- Survival
			return 61; -- VUHDO_ID_MELEE_DAMAGE
		else
			return 62; -- VUHDO_ID_RANGED_DAMAGE
		end

	elseif 30 == tClassId then -- VUHDO_ID_MONKS
		tPowerType = UnitPowerType(aUnit);

		if VUHDO_UNIT_POWER_MANA == tPowerType then
			return 63; -- VUHDO_ID_RANGED_HEAL
		elseif VUHDO_UNIT_POWER_ENERGY == tPowerType then
			if UnitPowerMax(aUnit, VUHDO_UNIT_POWER_CHI) > 4 then -- WW Monks have 5 Chi (6 w/ Ascension)
				return 61; -- VUHDO_ID_MELEE_DAMAGE
			else
				return 60; -- VUHDO_ID_MELEE_TANK
			end
		end

	elseif 32 == tClassId then -- VUHDO_ID_EVOKERS
		-- FIXME: all Evoker specs have the same max mana and essence
		if UnitPowerMax(aUnit) == 250000 then
			return 62; -- VUHDO_ID_RANGED_DAMAGE
		else
			return 63; -- VUHDO_ID_RANGED_HEAL
		end

	end
 
	return nil;
end



--
local tName;
local tUnit;
local tInfo;
local tRole;
local tOldRole;
function VUHDO_updateRoleBySpecialization(aSpecId, aRole, aPosition, aSender, aTalentString)

	if not aRole or not aPosition or not aSender then
		return;
	end

	tName = Ambiguate(aSender, "short");

	if not tName then
		return;
	end

	tUnit = VUHDO_RAID_NAMES[tName];

	if tUnit then
		tInfo = VUHDO_RAID[tUnit];

		if tInfo and VUHDO_determineDfToolRole(tInfo) then
			return;
		end
	end

	if aRole == "TANK" then
		tRole = VUHDO_ID_MELEE_TANK;
	elseif aRole == "DAMAGER" then
		if aPosition == "RANGED" then
			tRole = VUHDO_ID_RANGED_DAMAGE;
		else
			tRole = VUHDO_ID_MELEE_DAMAGE;
		end
	else
		tRole = VUHDO_ID_RANGED_HEAL;
	end

	tOldRole = VUHDO_ROLE_BY_SPEC[tName];
	VUHDO_ROLE_BY_SPEC[tName] = tRole;

	if tUnit and tInfo and tOldRole ~= tRole then
		VUHDO_normalRaidReload();
	end

end
