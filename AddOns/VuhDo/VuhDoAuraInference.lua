local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local twipe = table.wipe;
local issecretvalue = issecretvalue;
local GetTime = GetTime;

local UnitIsUnit = UnitIsUnit;
local GetSpecialization = GetSpecialization;
local GetSpellTexture = GetSpellTexture or C_Spell.GetSpellTexture;
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras;
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID;
local IsAuraFilteredOutByInstanceID = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID;

local VUHDO_CONFIG;
local VUHDO_PLAYER_CLASS;
local VUHDO_AURA_GROUPS;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_UNIT_AURA_CACHE;
local VUHDO_SPELL_ID;

local sEmpty = { };
local sDisabled = true;
local sBuffFilter = "PLAYER|HELPFUL|RAID_IN_COMBAT";
local sTimestampTolerance = 0.25;

local sSyntheticAuraPool;



--
local function VUHDO_cleanupSyntheticAura(aTable)

	aTable["auraInstanceID"] = nil;
	aTable["icon"] = nil;
	aTable["name"] = nil;
	aTable["spellId"] = nil;
	aTable["applications"] = nil;
	aTable["duration"] = nil;
	aTable["expirationTime"] = nil;
	aTable["sourceUnit"] = nil;
	aTable["isHarmful"] = nil;
	aTable["dispelName"] = nil;

	return;

end



VUHDO_INFERRED_AURA_SYNTHETIC_IDS = {
	["SHAMAN_RIPTIDE"] = -1001,
	["EVOKER_ECHO"] = -1002,
	["PRIEST_ATONEMENT"] = -1003,
};

local sSyntheticIdByType = VUHDO_INFERRED_AURA_SYNTHETIC_IDS;

VUHDO_AURA_INFERENCE_CONFIG = {
	["SHAMAN_RIPTIDE"] = {
		["spellId"] = 61295,
		["maxAuras"] = 2,
		["sortRule"] = Enum.UnitAuraSortRule.ExpirationOnly,
		["includeSpellIds"] = { },
		["excludeSpellIds"] = { },
		["empoweredSpellIds"] = { },
		["hasExcludeUnit"] = true,
		["specRequired"] = nil,
	},
	["EVOKER_ECHO"] = {
		["spellId"] = 364343,
		["maxAuras"] = 3,
		["sortRule"] = Enum.UnitAuraSortRule.NameOnly,
		["includeSpellIds"] = {
			[366155] = true,
			[357170] = true,
			[360995] = true,
		},
		["excludeSpellIds"] = {
			[366155] = true,
			[357170] = true,
			[360995] = true,
		},
		["empoweredSpellIds"] = {
			[355936] = true,
			[382614] = true,
		},
		["hasExcludeUnit"] = false,
		["specRequired"] = nil,
	},
	["PRIEST_ATONEMENT"] = {
		["spellId"] = 194384,
		["maxAuras"] = 1,
		["sortRule"] = Enum.UnitAuraSortRule.NameOnly,
		["includeSpellIds"] = {
			[17] = true,
			[2061] = true,
			[47540] = true,
			[194509] = true,
			[200829] = true,
		},
		["excludeSpellIds"] = { },
		["empoweredSpellIds"] = { },
		["hasExcludeUnit"] = false,
		["specRequired"] = 1,
	},
};

VUHDO_AURA_INFERENCE_STATE = {
	["SHAMAN_RIPTIDE"] = {
		["activeAuras"] = { },
		["filteredAuras"] = { },
		["lastCastTime"] = nil,
		["excludeUnit"] = {
			["unit"] = nil,
			["auraInstanceID"] = nil,
		},
		["empoweredPending"] = false,
	},
	["EVOKER_ECHO"] = {
		["activeAuras"] = { },
		["filteredAuras"] = { },
		["lastCastTime"] = nil,
		["excludeUnit"] = {
			["unit"] = nil,
			["auraInstanceID"] = nil,
		},
		["empoweredPending"] = false,
	},
	["PRIEST_ATONEMENT"] = {
		["activeAuras"] = { },
		["filteredAuras"] = { },
		["lastCastTime"] = nil,
		["excludeUnit"] = {
			["unit"] = nil,
			["auraInstanceID"] = nil,
		},
		["empoweredPending"] = false,
	},
};

VUHDO_INFERRED_AURAS = { };



--
function VUHDO_auraInferenceInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_PLAYER_CLASS = _G["VUHDO_PLAYER_CLASS"];
	VUHDO_AURA_GROUPS = VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUPS"];
	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_UNIT_AURA_CACHE = _G["VUHDO_UNIT_AURA_CACHE"];
	VUHDO_SPELL_ID = _G["VUHDO_SPELL_ID"];

	sSyntheticAuraPool = VUHDO_createTablePool("SyntheticAura", 50, nil, VUHDO_cleanupSyntheticAura);

	return;

end



--
local tConfig;
function VUHDO_getCurrentInferredType()

	if not VUHDO_PLAYER_CLASS then
		return nil;
	end

	if "SHAMAN" == VUHDO_PLAYER_CLASS then
		return "SHAMAN_RIPTIDE";
	end

	if "EVOKER" == VUHDO_PLAYER_CLASS then
		return "EVOKER_ECHO";
	end

	if "PRIEST" == VUHDO_PLAYER_CLASS then
		tConfig = VUHDO_AURA_INFERENCE_CONFIG["PRIEST_ATONEMENT"];

		if tConfig and tConfig["specRequired"] then
			if GetSpecialization() == tConfig["specRequired"] then
				return "PRIEST_ATONEMENT";
			end

			return nil;
		end

		return "PRIEST_ATONEMENT";
	end

	return nil;

end



--
local tState;
local tConfig;
local tAuras;
local tAura;
local tIsPlayer;
local tExcludeUnit;
local tFiltered;
local tSortRule;
local tSortDir;
local tInferredType;
local tSyntheticId;
local tSynthetic;
local tIcon;
local tName;
local tChanged;
local tOldSynthetic;
function VUHDO_onUnitAuraInference(aUnit, aUpdateInfo)

	if sDisabled then
		return false;
	end

	if not aUnit then
		return false;
	end

	tInferredType = VUHDO_getCurrentInferredType();

	if not tInferredType then
		return false;
	end

	tState = VUHDO_AURA_INFERENCE_STATE[tInferredType];
	tConfig = VUHDO_AURA_INFERENCE_CONFIG[tInferredType];

	if not tState or not tConfig then
		return false;
	end

	tChanged = false;
	tIsPlayer = UnitIsUnit(aUnit, "player");
	tSortRule = tConfig["sortRule"] or 0;
	tSortDir = 0;

	if "SHAMAN_RIPTIDE" == tInferredType then
		tExcludeUnit = tState["excludeUnit"];

		if tState["activeAuras"][aUnit] then
			if aUpdateInfo and aUpdateInfo["removedAuraInstanceIDs"] then
				for _, tAuraId in ipairs(aUpdateInfo["removedAuraInstanceIDs"]) do
					if tState["activeAuras"][aUnit] == tAuraId then
						tState["activeAuras"][aUnit] = nil;

						tOldSynthetic = VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tInferredType];

						if VUHDO_INFERRED_AURAS[aUnit] then
							VUHDO_INFERRED_AURAS[aUnit][tInferredType] = nil;
						end

						tSyntheticId = sSyntheticIdByType[tInferredType];

						if VUHDO_UNIT_AURA_CACHE[aUnit] then
							VUHDO_UNIT_AURA_CACHE[aUnit][tSyntheticId] = nil;
						end

						if tOldSynthetic then
							sSyntheticAuraPool:release(tOldSynthetic);
						end

						VUHDO_onAuraRemoved(aUnit, tSyntheticId);

						tChanged = true;

						return tChanged;
					end
				end
			end
		end

		if tExcludeUnit and tExcludeUnit["unit"] == aUnit and aUpdateInfo and aUpdateInfo["removedAuraInstanceIDs"] then
			for _, tAuraId in ipairs(aUpdateInfo["removedAuraInstanceIDs"]) do
				if tExcludeUnit["auraInstanceID"] == tAuraId then
					tState["excludeUnit"]["unit"] = nil;
					tState["excludeUnit"]["auraInstanceID"] = nil;

					break;
				end
			end
		end

		if not tState["activeAuras"][aUnit] or not tState["excludeUnit"]["unit"] then
			tAuras = GetUnitAuras(aUnit, sBuffFilter, 2, tSortRule, tSortDir);

			if tAuras and #tAuras == 2 then
				tState["activeAuras"][aUnit] = tAuras[1]["auraInstanceID"];

				if not tIsPlayer then
					tState["excludeUnit"]["unit"] = aUnit;
					tState["excludeUnit"]["auraInstanceID"] = tAuras[2]["auraInstanceID"];
				end

				tAura = tAuras[1];
			elseif tAuras and #tAuras == 1 and not tIsPlayer then
				tExcludeUnit = tState["excludeUnit"];

				if tExcludeUnit["unit"] ~= aUnit then
					tState["activeAuras"][aUnit] = tAuras[1]["auraInstanceID"];

					tAura = tAuras[1];
				end
			end
		end
	elseif "EVOKER_ECHO" == tInferredType then
		if aUpdateInfo and aUpdateInfo["addedAuras"] and tState["lastCastTime"] then
			if GetTime() - tState["lastCastTime"] <= sTimestampTolerance then
				for _, tAdded in ipairs(aUpdateInfo["addedAuras"]) do
					if not IsAuraFilteredOutByInstanceID(aUnit, tAdded["auraInstanceID"], "PLAYER") then
						if not tState["filteredAuras"][aUnit] then
							tState["filteredAuras"][aUnit] = { };
						end

						tState["filteredAuras"][aUnit][tAdded["auraInstanceID"]] = true;
					end
				end
			end
		end

		if tState["activeAuras"][aUnit] then
			if aUpdateInfo and aUpdateInfo["removedAuraInstanceIDs"] then
				for _, tAuraId in ipairs(aUpdateInfo["removedAuraInstanceIDs"]) do
					if tState["activeAuras"][aUnit] == tAuraId then
						tState["activeAuras"][aUnit] = nil;

						if tState["filteredAuras"][aUnit] then
							tState["filteredAuras"][aUnit][tAuraId] = nil;
						end

						tOldSynthetic = VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tInferredType];

						if VUHDO_INFERRED_AURAS[aUnit] then
							VUHDO_INFERRED_AURAS[aUnit][tInferredType] = nil;
						end

						tSyntheticId = sSyntheticIdByType[tInferredType];

						if VUHDO_UNIT_AURA_CACHE[aUnit] then
							VUHDO_UNIT_AURA_CACHE[aUnit][tSyntheticId] = nil;
						end

						if tOldSynthetic then
							sSyntheticAuraPool:release(tOldSynthetic);
						end

						VUHDO_onAuraRemoved(aUnit, tSyntheticId);

						tChanged = true;

						return tChanged;
					end
				end
			end
		end

		if not tState["activeAuras"][aUnit] then
			tAuras = GetUnitAuras(aUnit, sBuffFilter, 3, tSortRule, tSortDir);

			if tAuras and #tAuras > 0 then
				tFiltered = tState["filteredAuras"][aUnit] or sEmpty;

				for _, tAura in ipairs(tAuras) do
					if not tFiltered[tAura["auraInstanceID"]] then
						tState["activeAuras"][aUnit] = tAura["auraInstanceID"];

						break;
					end
				end

				if tState["activeAuras"][aUnit] then
					tAura = GetAuraDataByAuraInstanceID(aUnit, tState["activeAuras"][aUnit]);
				end
			end
		end
	elseif "PRIEST_ATONEMENT" == tInferredType then
		if tState["activeAuras"][aUnit] then
			if aUpdateInfo and aUpdateInfo["removedAuraInstanceIDs"] then
				for _, tAuraId in ipairs(aUpdateInfo["removedAuraInstanceIDs"]) do
					if tState["activeAuras"][aUnit] == tAuraId then
						tState["activeAuras"][aUnit] = nil;

						tOldSynthetic = VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tInferredType];

						if VUHDO_INFERRED_AURAS[aUnit] then
							VUHDO_INFERRED_AURAS[aUnit][tInferredType] = nil;
						end

						tSyntheticId = sSyntheticIdByType[tInferredType];

						if VUHDO_UNIT_AURA_CACHE[aUnit] then
							VUHDO_UNIT_AURA_CACHE[aUnit][tSyntheticId] = nil;
						end

						if tOldSynthetic then
							sSyntheticAuraPool:release(tOldSynthetic);
						end

						VUHDO_onAuraRemoved(aUnit, tSyntheticId);

						tChanged = true;

						return tChanged;
					end
				end
			end
		end

		if aUpdateInfo and aUpdateInfo["addedAuras"] and tState["lastCastTime"] and GetTime() - tState["lastCastTime"] <= sTimestampTolerance then
			tAuras = GetUnitAuras(aUnit, sBuffFilter, 1, tSortRule, tSortDir);

			if tAuras and #tAuras == 1 then
				for _, tAdded in ipairs(aUpdateInfo["addedAuras"]) do
					if tAdded["auraInstanceID"] == tAuras[1]["auraInstanceID"] then
						tState["activeAuras"][aUnit] = tAuras[1]["auraInstanceID"];

						tAura = tAuras[1];

						break;
					end
				end
			end
		end
	end

	if tAura and tState["activeAuras"][aUnit] then
		tSyntheticId = sSyntheticIdByType[tInferredType];
		tIcon = GetSpellTexture(tConfig["spellId"]);
		tName = VUHDO_SPELL_ID and (VUHDO_SPELL_ID.RIPTIDE or VUHDO_SPELL_ID.ECHO or VUHDO_SPELL_ID.ATONEMENT) or (tAura["name"] or "");

		if tConfig["spellId"] == 61295 and VUHDO_SPELL_ID and VUHDO_SPELL_ID.RIPTIDE then
			tName = VUHDO_SPELL_ID.RIPTIDE;
		elseif tConfig["spellId"] == 364343 and VUHDO_SPELL_ID and VUHDO_SPELL_ID.ECHO then
			tName = VUHDO_SPELL_ID.ECHO;
		elseif tConfig["spellId"] == 194384 and VUHDO_SPELL_ID and VUHDO_SPELL_ID.ATONEMENT then
			tName = VUHDO_SPELL_ID.ATONEMENT;
		else
			tName = tAura["name"] or tName;
		end

		tSynthetic = sSyntheticAuraPool:get();

		tSynthetic["auraInstanceID"] = tSyntheticId;
		tSynthetic["icon"] = tIcon or tAura["icon"];
		tSynthetic["name"] = tName;
		tSynthetic["spellId"] = tConfig["spellId"];
		tSynthetic["applications"] = tAura["applications"] or 1;
		tSynthetic["duration"] = tAura["duration"] or 0;
		tSynthetic["expirationTime"] = tAura["expirationTime"] or 0;
		tSynthetic["sourceUnit"] = tAura["sourceUnit"];
		tSynthetic["isHarmful"] = false;
		tSynthetic["dispelName"] = nil;

		if not VUHDO_INFERRED_AURAS[aUnit] then
			VUHDO_INFERRED_AURAS[aUnit] = { };
		end

		VUHDO_INFERRED_AURAS[aUnit][tInferredType] = tSynthetic;

		if not VUHDO_UNIT_AURA_CACHE[aUnit] then
			VUHDO_UNIT_AURA_CACHE[aUnit] = { };
		end

		VUHDO_UNIT_AURA_CACHE[aUnit][tSyntheticId] = tSynthetic;

		tChanged = true;
	end

	return tChanged;

end



--
local tState;
local tConfig;
local tInferredType;
function VUHDO_onSpellcastSucceeded(aUnit, aCastGUID, aSpellId)

	if sDisabled then
		return;
	end

	if not aUnit or not aSpellId then
		return;
	end

	if issecretvalue(aSpellId) then
		return;
	end

	tInferredType = VUHDO_getCurrentInferredType();

	if not tInferredType then
		return;
	end

	tState = VUHDO_AURA_INFERENCE_STATE[tInferredType];
	tConfig = VUHDO_AURA_INFERENCE_CONFIG[tInferredType];

	if not tState or not tConfig then
		return;
	end

	if tConfig["includeSpellIds"] and tConfig["includeSpellIds"][aSpellId] then
		tState["lastCastTime"] = GetTime();

		return;
	end

	if "EVOKER_ECHO" == tInferredType and tConfig["empoweredSpellIds"] and tConfig["empoweredSpellIds"][aSpellId] then
		tState["empoweredPending"] = true;
	end

	return;

end



--
local tState;
local tConfig;
function VUHDO_onSpellcastEmpoweredStop(aUnit, aCastGUID, aSpellId, anEmpoweredSuccess)

	if sDisabled then
		return;
	end

	if not anEmpoweredSuccess or not aSpellId then
		return;
	end

	if issecretvalue(aSpellId) then
		return;
	end

	tConfig = VUHDO_AURA_INFERENCE_CONFIG["EVOKER_ECHO"];
	tState = VUHDO_AURA_INFERENCE_STATE["EVOKER_ECHO"];

	if not tConfig or not tState then
		return;
	end

	if tConfig["empoweredSpellIds"] and tConfig["empoweredSpellIds"][aSpellId] then
		tState["lastCastTime"] = GetTime();
	end

	tState["empoweredPending"] = false;

	return;

end



--
local tInferredType;
local tGroup;
function VUHDO_hasInferredAura(aUnit, aGroupId)

	if sDisabled then
		return false;
	end

	if not aUnit then
		return false;
	end

	if aGroupId then
		tGroup = VUHDO_DEFAULT_AURA_GROUPS and VUHDO_DEFAULT_AURA_GROUPS[aGroupId];

		if not tGroup then
			tGroup = VUHDO_AURA_GROUPS and VUHDO_AURA_GROUPS[aGroupId];
		end

		if tGroup and tGroup["isInferred"] then
			tInferredType = tGroup["inferredType"];

			if tInferredType and VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tInferredType] then
				return true;
			end
		end

		return false;
	end

	tInferredType = VUHDO_getCurrentInferredType();

	if not tInferredType then
		return false;
	end

	return (VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tInferredType]) ~= nil;

end



--
local tInferredType;
local tGroup;
function VUHDO_getInferredAura(aUnit, aGroupId)

	if sDisabled then
		return nil;
	end

	if not aUnit or not aGroupId then
		return nil;
	end

	tGroup = VUHDO_DEFAULT_AURA_GROUPS and VUHDO_DEFAULT_AURA_GROUPS[aGroupId];

	if not tGroup then
		tGroup = VUHDO_AURA_GROUPS and VUHDO_AURA_GROUPS[aGroupId];
	end

	if not tGroup or not tGroup["isInferred"] then
		return nil;
	end

	tInferredType = tGroup["inferredType"];

	if not tInferredType or not VUHDO_INFERRED_AURAS[aUnit] then
		return nil;
	end

	return VUHDO_INFERRED_AURAS[aUnit][tInferredType];

end



--
local tInferredType;
local tCandidates = { };
local tBestGroup;
local tBestPriority;
local tPriority;
function VUHDO_getInferredAuraGroup(aUnit)

	if sDisabled then
		return nil;
	end

	if not aUnit then
		return nil;
	end

	tInferredType = VUHDO_getCurrentInferredType();

	if not tInferredType then
		return nil;
	end

	if not VUHDO_INFERRED_AURAS[aUnit] or not VUHDO_INFERRED_AURAS[aUnit][tInferredType] then
		return nil;
	end

	twipe(tCandidates);

	for tGroupId, tGroup in pairs(VUHDO_AURA_GROUPS or sEmpty) do
		if tGroup["isInferred"] and tGroup["inferredType"] == tInferredType then
			if tGroup["enabled"] ~= false and tGroup["canColorBar"] then
				tinsert(tCandidates, tGroup);
			end
		end
	end

	for tGroupId, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or sEmpty) do
		if tGroup["isInferred"] and tGroup["inferredType"] == tInferredType then
			if not tGroup["playerClassRequired"] or tGroup["playerClassRequired"] == VUHDO_PLAYER_CLASS then
				if tGroup["enabled"] ~= false then
					if not (VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][tGroupId]) then
						if tGroup["canColorBar"] then
							tinsert(tCandidates, tGroup);
						end
					end
				end
			end
		end
	end

	if #tCandidates == 0 then
		return nil;
	end

	tBestGroup = tCandidates[1];
	tBestPriority = tBestGroup["priority"] or 50;

	for tCnt = 2, #tCandidates do
		tPriority = tCandidates[tCnt]["priority"] or 50;

		if tPriority < tBestPriority then
			tBestGroup = tCandidates[tCnt];
			tBestPriority = tPriority;
		end
	end

	return tBestGroup;

end