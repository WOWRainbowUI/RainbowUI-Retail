local _;

local table = table;
local tinsert = table.insert;
local tsort = table.sort;
local twipe = table.wipe;
local pairs = pairs;
local ipairs = ipairs;
local strfind = string.find;

local UnitCanAttack = UnitCanAttack;
local UnitIsUnit = UnitIsUnit;
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras;
local issecretvalue = issecretvalue;
local GetAuraDispelTypeColor = C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor;
local IsAuraFilteredOutByInstanceID = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID;
local InCombatLockdown = InCombatLockdown;

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
local VUHDO_PANEL_MODELS;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_GROUP_COLOR_OFF;
local VUHDO_AURA_GROUP_COLOR_DISPEL;
local VUHDO_AURA_GROUP_COLOR_CUSTOM;
local VUHDO_UNIT_AURA_LIST_SLOTS;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_UNIT_AURA_CACHE;
local VUHDO_AURA_LIST_ENTRY_SPELL;
local VUHDO_AURA_LIST_ENTRY_BOUQUET;
local VUHDO_MAX_PANELS;
local VUHDO_UNIT_AURA_BY_SPELL;
local VUHDO_UNIT_AURA_BOUQUET_ACTIVE;
local VUHDO_DEBUFF_TYPES;
local VUHDO_PLAYER_PURGE_ABILITIES;
local VUHDO_PLAYER_DISPEL_ABILITIES;
local VUHDO_INFERRED_AURA_SYNTHETIC_IDS;
local VUHDO_INFERRED_AURAS;
local VUHDO_BUFF_SETTINGS;
local VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS;

VUHDO_AURA_GROUP_ACTIVE_NO_COLOR = { };
local VUHDO_AURA_GROUP_ACTIVE_NO_COLOR = VUHDO_AURA_GROUP_ACTIVE_NO_COLOR;

local VUHDO_getDispelCurveForUnit;
local VUHDO_getDispelTextCurveForUnit;
local VUHDO_hasInferredAura;
local VUHDO_createTablePool;
local VUHDO_auraMatchesFilter;
local VUHDO_isAuraIgnored;

local sUnitDispellableAuraId = { };
local sUnitAuraCanColorBar = { };
local sUnitAuraColorType = { };
local sUnitAuraCustomColor = { };
local sCanColorBarGroups = { };
local sUnitAuraBarWinner = { };
local sUnitAuraTextWinner = { };
local sUnitAuraGlowWinner = { };
local sUnitAuraGroupActive = { };

local sGlowWinnerSet;

local sAuraColorWinnerPool;
local sCanColorBarGroupPool;
local sAuraGroupActiveColorPool;

local sFilterResultCache = { };

local sEmpty = { };

local sDispelColorBuffer = {
	["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 1,
	["TR"] = 0, ["TG"] = 0, ["TB"] = 0, ["TO"] = 1,
	["useBackground"] = true,
	["useText"] = nil,
};

local sGlowColorBuffer = { 0.95, 0.95, 0.32, 1 };



--
local function VUHDO_createAuraColorWinnerDelegate()

	return { ["colorType"] = nil, ["customColor"] = nil, ["dispelAuraId"] = nil };

end



--
local function VUHDO_cleanupAuraColorWinnerDelegate(aWinner)

	aWinner["colorType"] = nil;
	aWinner["customColor"] = nil;
	aWinner["dispelAuraId"] = nil;

	return;

end



--
local function VUHDO_createCanColorBarGroupDelegate()

	return { };

end



--
local function VUHDO_cleanupCanColorBarGroupDelegate(aGroup)

	aGroup["isInferred"] = nil;
	aGroup["inferredType"] = nil;
	aGroup["priority"] = nil;
	aGroup["colorType"] = nil;
	aGroup["customColor"] = nil;
	aGroup["canColorBar"] = nil;
	aGroup["canColorText"] = nil;
	aGroup["canGlowBar"] = nil;
	aGroup["glowBarColor"] = nil;
	aGroup["isListGroup"] = nil;
	aGroup["groupId"] = nil;
	aGroup["entries"] = nil;
	aGroup["filter"] = nil;
	aGroup["excludeFilter"] = nil;
	aGroup["dispelCheckFilter"] = nil;
	aGroup["isHelpful"] = nil;
	aGroup["bouquetTrackOnly"] = nil;

	return;

end



--
local function VUHDO_createAuraGroupBouquetColorDelegate()

	return { };

end



--
local function VUHDO_cleanupAuraGroupBouquetColorDelegate(aTable)

	aTable["isAuraGroupBouquetColorPooled"] = nil;
	aTable["R"] = nil;
	aTable["G"] = nil;
	aTable["B"] = nil;
	aTable["O"] = nil;
	aTable["TR"] = nil;
	aTable["TG"] = nil;
	aTable["TB"] = nil;
	aTable["TO"] = nil;
	aTable["useBackground"] = nil;
	aTable["useText"] = nil;

	return;

end



--
function VUHDO_auraColorsInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_PANEL_MODELS = _G["VUHDO_PANEL_MODELS"];
	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_AURA_GROUP_COLOR_OFF = _G["VUHDO_AURA_GROUP_COLOR_OFF"];
	VUHDO_AURA_GROUP_COLOR_DISPEL = _G["VUHDO_AURA_GROUP_COLOR_DISPEL"];
	VUHDO_AURA_GROUP_COLOR_CUSTOM = _G["VUHDO_AURA_GROUP_COLOR_CUSTOM"];
	VUHDO_UNIT_AURA_LIST_SLOTS = _G["VUHDO_UNIT_AURA_LIST_SLOTS"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_UNIT_AURA_CACHE = _G["VUHDO_UNIT_AURA_CACHE"];
	VUHDO_AURA_LIST_ENTRY_SPELL = _G["VUHDO_AURA_LIST_ENTRY_SPELL"];
	VUHDO_AURA_LIST_ENTRY_BOUQUET = _G["VUHDO_AURA_LIST_ENTRY_BOUQUET"];
	VUHDO_MAX_PANELS = _G["VUHDO_MAX_PANELS"];
	VUHDO_UNIT_AURA_BY_SPELL = _G["VUHDO_UNIT_AURA_BY_SPELL"];
	VUHDO_UNIT_AURA_BOUQUET_ACTIVE = _G["VUHDO_UNIT_AURA_BOUQUET_ACTIVE"];
	VUHDO_DEBUFF_TYPES = _G["VUHDO_DEBUFF_TYPES"];
	VUHDO_PLAYER_PURGE_ABILITIES = _G["VUHDO_PLAYER_PURGE_ABILITIES"];
	VUHDO_PLAYER_DISPEL_ABILITIES = _G["VUHDO_PLAYER_DISPEL_ABILITIES"];
	VUHDO_INFERRED_AURA_SYNTHETIC_IDS = _G["VUHDO_INFERRED_AURA_SYNTHETIC_IDS"];
	VUHDO_INFERRED_AURAS = _G["VUHDO_INFERRED_AURAS"];
	VUHDO_BUFF_SETTINGS = _G["VUHDO_BUFF_SETTINGS"];
	VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS = _G["VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS"];

	VUHDO_getDispelCurveForUnit = _G["VUHDO_getDispelCurveForUnit"];
	VUHDO_getDispelTextCurveForUnit = _G["VUHDO_getDispelTextCurveForUnit"];
	VUHDO_hasInferredAura = _G["VUHDO_hasInferredAura"];
	VUHDO_createTablePool = _G["VUHDO_createTablePool"];
	VUHDO_auraMatchesFilter = _G["VUHDO_auraMatchesFilter"];
	VUHDO_isAuraIgnored = _G["VUHDO_isAuraIgnored"];

	sAuraColorWinnerPool = VUHDO_createTablePool("AuraColorWinner", 100, VUHDO_createAuraColorWinnerDelegate, VUHDO_cleanupAuraColorWinnerDelegate);
	sCanColorBarGroupPool = VUHDO_createTablePool("CanColorBarGroup", 50, VUHDO_createCanColorBarGroupDelegate, VUHDO_cleanupCanColorBarGroupDelegate);
	sAuraGroupActiveColorPool = VUHDO_createTablePool("AuraGroupBouquetColor", 120, VUHDO_createAuraGroupBouquetColorDelegate, VUHDO_cleanupAuraGroupBouquetColorDelegate);

	return;

end



do
	--
	local tEffectiveColorType;
	local tColorBarGroup;
	local function VUHDO_setCanColorGroupBouquetTrackOnly(aColorBarGroup, aEffectiveColorType, aGroupId, aGroup)

		if aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_OFF and VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS[aGroupId] and not aGroup["canGlowBar"] then
			aColorBarGroup["bouquetTrackOnly"] = true;
		else
			aColorBarGroup["bouquetTrackOnly"] = nil;
		end

		return;

	end

	function VUHDO_rebuildCanColorBarGroupsCache()

		VUHDO_rebuildActiveAuraCaches();

		VUHDO_collectBouquetAuraGroupIds();

		for tIdx = 1, #sCanColorBarGroups do
			sCanColorBarGroupPool:release(sCanColorBarGroups[tIdx]);
		end

		twipe(sCanColorBarGroups);

		for tGroupId, tGroup in pairs(VUHDO_CONFIG["AURA_GROUPS"] or sEmpty) do
			tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

			if tGroup["enabled"] ~= false and (tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL or
				(tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_OFF and VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS[tGroupId])) then
				if tGroup["isInferred"] then
					tColorBarGroup = sCanColorBarGroupPool:get();

					tColorBarGroup["isInferred"] = true;
					tColorBarGroup["inferredType"] = tGroup["inferredType"];
					tColorBarGroup["priority"] = tGroup["priority"] or 50;
					tColorBarGroup["colorType"] = tGroup["colorType"] or tEffectiveColorType;
					tColorBarGroup["customColor"] = tGroup["customColor"];

					if tGroup["canColorBar"] then
						tColorBarGroup["canColorBar"] = true;
					else
						tColorBarGroup["canColorBar"] = false;
					end

					if tGroup["canColorText"] then
						tColorBarGroup["canColorText"] = true;
					else
						tColorBarGroup["canColorText"] = false;
					end

					if tGroup["canGlowBar"] then
						tColorBarGroup["canGlowBar"] = true;
						tColorBarGroup["glowBarColor"] = tGroup["glowBarColor"];
					else
						tColorBarGroup["canGlowBar"] = false;
						tColorBarGroup["glowBarColor"] = nil;
					end

					tColorBarGroup["groupId"] = tGroupId;

					VUHDO_setCanColorGroupBouquetTrackOnly(tColorBarGroup, tEffectiveColorType, tGroupId, tGroup);

					tinsert(sCanColorBarGroups, tColorBarGroup);
				else
					tColorBarGroup = sCanColorBarGroupPool:get();

					tColorBarGroup["priority"] = tGroup["priority"] or 50;
					tColorBarGroup["colorType"] = tGroup["colorType"] or tEffectiveColorType;
					tColorBarGroup["customColor"] = tGroup["customColor"];

					if tGroup["canColorBar"] then
						tColorBarGroup["canColorBar"] = true;
					else
						tColorBarGroup["canColorBar"] = false;
					end

					if tGroup["canColorText"] then
						tColorBarGroup["canColorText"] = true;
					else
						tColorBarGroup["canColorText"] = false;
					end

					if tGroup["canGlowBar"] then
						tColorBarGroup["canGlowBar"] = true;
						tColorBarGroup["glowBarColor"] = tGroup["glowBarColor"];
					else
						tColorBarGroup["canGlowBar"] = false;
						tColorBarGroup["glowBarColor"] = nil;
					end

					tColorBarGroup["groupId"] = tGroupId;

					if (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
						tColorBarGroup["isListGroup"] = true;
						tColorBarGroup["groupId"] = tGroupId;
						tColorBarGroup["entries"] = tGroup["entries"];

						VUHDO_setCanColorGroupBouquetTrackOnly(tColorBarGroup, tEffectiveColorType, tGroupId, tGroup);

						tinsert(sCanColorBarGroups, tColorBarGroup);
					else
						tColorBarGroup["filter"] = tGroup["filter"];
						tColorBarGroup["excludeFilter"] = tGroup["excludeFilter"];

						if tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
							if strfind(tGroup["filter"], "HARMFUL", 1, true) then
								tColorBarGroup["dispelCheckFilter"] = "HARMFUL|RAID_PLAYER_DISPELLABLE";
							else
								tColorBarGroup["dispelCheckFilter"] = "HELPFUL|RAID_PLAYER_DISPELLABLE";
							end

							tColorBarGroup["isHelpful"] = not strfind(tGroup["filter"], "HARMFUL", 1, true);
						end

						VUHDO_setCanColorGroupBouquetTrackOnly(tColorBarGroup, tEffectiveColorType, tGroupId, tGroup);

						tinsert(sCanColorBarGroups, tColorBarGroup);
					end
				end
			end
		end

		for tGroupId, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or sEmpty) do
			if not tGroup["playerClassRequired"] or tGroup["playerClassRequired"] == VUHDO_PLAYER_CLASS then
				tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

				if not (VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][tGroupId]) and tGroup["enabled"] ~= false and not (VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][tGroupId]) and
					not (VUHDO_DEFAULT_AURA_GROUPS[tGroupId] and VUHDO_DEFAULT_AURA_GROUPS[tGroupId]["enabled"] == false) and
					(tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL or
					(tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_OFF and VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS[tGroupId])) then
					if tGroup["isInferred"] then
						tColorBarGroup = sCanColorBarGroupPool:get();

						tColorBarGroup["isInferred"] = true;
						tColorBarGroup["inferredType"] = tGroup["inferredType"];
						tColorBarGroup["priority"] = tGroup["priority"] or 50;
						tColorBarGroup["colorType"] = tGroup["colorType"] or tEffectiveColorType;
						tColorBarGroup["customColor"] = tGroup["customColor"];

						if tGroup["canColorBar"] then
							tColorBarGroup["canColorBar"] = true;
						else
							tColorBarGroup["canColorBar"] = false;
						end

						if tGroup["canColorText"] then
							tColorBarGroup["canColorText"] = true;
						else
							tColorBarGroup["canColorText"] = false;
						end

						if tGroup["canGlowBar"] then
							tColorBarGroup["canGlowBar"] = true;

							tColorBarGroup["glowBarColor"] = tGroup["glowBarColor"];
						else
							tColorBarGroup["canGlowBar"] = false;

							tColorBarGroup["glowBarColor"] = nil;
						end

						tColorBarGroup["groupId"] = tGroupId;

						VUHDO_setCanColorGroupBouquetTrackOnly(tColorBarGroup, tEffectiveColorType, tGroupId, tGroup);

						tinsert(sCanColorBarGroups, tColorBarGroup);
					else
						tColorBarGroup = sCanColorBarGroupPool:get();

						tColorBarGroup["priority"] = tGroup["priority"] or 50;
						tColorBarGroup["colorType"] = tGroup["colorType"] or tEffectiveColorType;
						tColorBarGroup["customColor"] = tGroup["customColor"];

						if tGroup["canColorBar"] then
							tColorBarGroup["canColorBar"] = true;
						else
							tColorBarGroup["canColorBar"] = false;
						end

						if tGroup["canColorText"] then
							tColorBarGroup["canColorText"] = true;
						else
							tColorBarGroup["canColorText"] = false;
						end

						if tGroup["canGlowBar"] then
							tColorBarGroup["canGlowBar"] = true;

							tColorBarGroup["glowBarColor"] = tGroup["glowBarColor"];
						else
							tColorBarGroup["canGlowBar"] = false;

							tColorBarGroup["glowBarColor"] = nil;
						end

						if (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
							tColorBarGroup["isListGroup"] = true;

							tColorBarGroup["groupId"] = tGroupId;
							tColorBarGroup["entries"] = tGroup["entries"];

							VUHDO_setCanColorGroupBouquetTrackOnly(tColorBarGroup, tEffectiveColorType, tGroupId, tGroup);

							tinsert(sCanColorBarGroups, tColorBarGroup);
						else
							tColorBarGroup["filter"] = tGroup["filter"];
							tColorBarGroup["excludeFilter"] = tGroup["excludeFilter"];

							if tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
								if strfind(tGroup["filter"], "HARMFUL", 1, true) then
									tColorBarGroup["dispelCheckFilter"] = "HARMFUL|RAID_PLAYER_DISPELLABLE";
								else
									tColorBarGroup["dispelCheckFilter"] = "HELPFUL|RAID_PLAYER_DISPELLABLE";
								end

								tColorBarGroup["isHelpful"] = not strfind(tGroup["filter"], "HARMFUL", 1, true);
							end

							tColorBarGroup["groupId"] = tGroupId;

							VUHDO_setCanColorGroupBouquetTrackOnly(tColorBarGroup, tEffectiveColorType, tGroupId, tGroup);

							tinsert(sCanColorBarGroups, tColorBarGroup);
						end
					end
				end
			end
		end

		tsort(sCanColorBarGroups, function(tSortA, tSortB)
			return (tSortA["priority"] or 50) < (tSortB["priority"] or 50);
		end);

		VUHDO_clearDispellableAuraCache(nil);

		if VUHDO_RAID then
			for tUnit, _ in pairs(VUHDO_RAID) do
				VUHDO_updateDispellableAuraForUnit(tUnit);
			end
		end

		return;

	end
end



do
	--
	local tEntryValue;
	local tAuraInstances;
	local tBouquetActive;
	local tCachedAura;
	local tAuraInstanceId;
	local tSourceUnit;
	local tIsMine;
	local function VUHDO_isListGroupActiveForUnit(aUnit, aEntries)

		if not aEntries then
			return false;
		end

		for _, tEntry in ipairs(aEntries) do
			if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
				if tEntry["mine"] or tEntry["others"] then
					tEntryValue = tEntry["value"];

					if tEntryValue and VUHDO_UNIT_AURA_BY_SPELL[aUnit] then
						tAuraInstances = VUHDO_UNIT_AURA_BY_SPELL[aUnit][tEntryValue];

						if tAuraInstances then
							for tCnt = 1, #tAuraInstances do
								tAuraInstanceId = tAuraInstances[tCnt];
								tCachedAura = VUHDO_UNIT_AURA_CACHE[aUnit] and VUHDO_UNIT_AURA_CACHE[aUnit][tAuraInstanceId];

								if tCachedAura then
									if tEntry["mine"] and tEntry["others"] then
										return true;
									end

									tSourceUnit = tCachedAura["sourceUnit"];

									if issecretvalue(tSourceUnit) then
										if tEntry["others"] == true then
											return true;
										end
									else
										tIsMine = UnitIsUnit(tSourceUnit or "", "player");

										if tEntry["mine"] and tIsMine then
											return true;
										end

										if tEntry["others"] and not tIsMine then
											return true;
										end
									end
								end
							end
						end
					end
				end
			elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
				tEntryValue = tEntry["value"];

				if tEntryValue then
					tBouquetActive = (VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] or sEmpty)[tEntryValue];

					if tBouquetActive then
						return true;
					end
				end
			end
		end

		return false;

	end



	--
	local tGlowColor;
	local function VUHDO_setGlowWinnerIfNeeded(aUnit, aCanColorGroup)

		if not sGlowWinnerSet and aCanColorGroup["canGlowBar"] then
			tGlowColor = aCanColorGroup["glowBarColor"];

			sUnitAuraGlowWinner[aUnit] = tGlowColor;

			sGlowWinnerSet = true;
		end

		return;

	end



	--
	local tSubMapForAuraGroup;
	local tPooledAuraGroupColor;
	local tGroupIdForBouquetCache;
	local tDispelCurveForBouquetCache;
	local tDispelTextCurveForBouquetCache;
	local tDispelColorMixinForBouquet;
	local tCustomColorSrcForBouquet;
	local function VUHDO_resetUnitAuraGroupActiveSubtable(aUnit)

		tSubMapForAuraGroup = sUnitAuraGroupActive[aUnit];

		if not tSubMapForAuraGroup then
			sUnitAuraGroupActive[aUnit] = { };

			return;
		end

		for _, tPooledAuraGroupColor in pairs(tSubMapForAuraGroup) do
			if tPooledAuraGroupColor and tPooledAuraGroupColor["isAuraGroupBouquetColorPooled"] then
				sAuraGroupActiveColorPool:release(tPooledAuraGroupColor);
			end
		end

		twipe(tSubMapForAuraGroup);

		return;

	end



	--
	local function VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, aDispelAuraInstanceId)

		tGroupIdForBouquetCache = tCanColorGroup["groupId"];

		if not tGroupIdForBouquetCache then
			return;
		end

		tSubMapForAuraGroup = sUnitAuraGroupActive[aUnit];

		if tSubMapForAuraGroup[tGroupIdForBouquetCache] then
			return;
		end

		if tCanColorGroup["colorType"] == VUHDO_AURA_GROUP_COLOR_CUSTOM and tCanColorGroup["customColor"] then
			tCustomColorSrcForBouquet = tCanColorGroup["customColor"];

			tPooledAuraGroupColor = sAuraGroupActiveColorPool:get();

			tPooledAuraGroupColor["isAuraGroupBouquetColorPooled"] = true;
			tPooledAuraGroupColor["useBackground"] = tCanColorGroup["canColorBar"] or nil;
			tPooledAuraGroupColor["useText"] = tCanColorGroup["canColorText"] or nil;

			if tPooledAuraGroupColor["useBackground"] then
				tPooledAuraGroupColor["R"] = tCustomColorSrcForBouquet["R"];
				tPooledAuraGroupColor["G"] = tCustomColorSrcForBouquet["G"];
				tPooledAuraGroupColor["B"] = tCustomColorSrcForBouquet["B"];
				tPooledAuraGroupColor["O"] = tCustomColorSrcForBouquet["O"];
			end

			if tPooledAuraGroupColor["useText"] then
				tPooledAuraGroupColor["TR"] = tCustomColorSrcForBouquet["TR"];
				tPooledAuraGroupColor["TG"] = tCustomColorSrcForBouquet["TG"];
				tPooledAuraGroupColor["TB"] = tCustomColorSrcForBouquet["TB"];
				tPooledAuraGroupColor["TO"] = tCustomColorSrcForBouquet["TO"];
			end

			if not tPooledAuraGroupColor["R"] and not tPooledAuraGroupColor["TR"] then
				sAuraGroupActiveColorPool:release(tPooledAuraGroupColor);
			else
				tSubMapForAuraGroup[tGroupIdForBouquetCache] = tPooledAuraGroupColor;
			end
		elseif tCanColorGroup["colorType"] == VUHDO_AURA_GROUP_COLOR_DISPEL and aDispelAuraInstanceId then
			tPooledAuraGroupColor = sAuraGroupActiveColorPool:get();

			tPooledAuraGroupColor["isAuraGroupBouquetColorPooled"] = true;
			tPooledAuraGroupColor["useBackground"] = tCanColorGroup["canColorBar"] or nil;
			tPooledAuraGroupColor["useText"] = tCanColorGroup["canColorText"] or nil;

			if tPooledAuraGroupColor["useBackground"] then
				tDispelCurveForBouquetCache = VUHDO_getDispelCurveForUnit(aUnit, true);

				if tDispelCurveForBouquetCache then
					tDispelColorMixinForBouquet = GetAuraDispelTypeColor(aUnit, aDispelAuraInstanceId, tDispelCurveForBouquetCache);

					if tDispelColorMixinForBouquet then
						tPooledAuraGroupColor["R"] = tDispelColorMixinForBouquet.r;
						tPooledAuraGroupColor["G"] = tDispelColorMixinForBouquet.g;
						tPooledAuraGroupColor["B"] = tDispelColorMixinForBouquet.b;
						tPooledAuraGroupColor["O"] = tDispelColorMixinForBouquet.a or 1;
					end
				end
			end

			if tPooledAuraGroupColor["useText"] then
				tDispelTextCurveForBouquetCache = VUHDO_getDispelTextCurveForUnit(aUnit, true);

				if tDispelTextCurveForBouquetCache then
					tDispelColorMixinForBouquet = GetAuraDispelTypeColor(aUnit, aDispelAuraInstanceId, tDispelTextCurveForBouquetCache);

					if tDispelColorMixinForBouquet then
						tPooledAuraGroupColor["TR"] = tDispelColorMixinForBouquet.r;
						tPooledAuraGroupColor["TG"] = tDispelColorMixinForBouquet.g;
						tPooledAuraGroupColor["TB"] = tDispelColorMixinForBouquet.b;
						tPooledAuraGroupColor["TO"] = tDispelColorMixinForBouquet.a or 1;
					end
				end
			end

			if not tPooledAuraGroupColor["R"] and not tPooledAuraGroupColor["TR"] then
				sAuraGroupActiveColorPool:release(tPooledAuraGroupColor);
			else
				tSubMapForAuraGroup[tGroupIdForBouquetCache] = tPooledAuraGroupColor;
			end
		end

		return;

	end



	--
	local function VUHDO_resetFilterResultCache()

		twipe(sFilterResultCache);

		return;

	end



	--
	local tResult;
	local function VUHDO_getCachedFilteredAuras(aUnit, aFilter)

		if sFilterResultCache[aFilter] ~= nil then
			return sFilterResultCache[aFilter];
		end

		tResult = GetUnitAuras(aUnit, aFilter, 40, Enum.UnitAuraSortRule.Default, 1);
		sFilterResultCache[aFilter] = tResult or false;

		return sFilterResultCache[aFilter];

	end



	--
	local tBarWinnerSet;
	local tTextWinnerSet;
	local tCanColorGroup;
	local tIsGroupActiveForBouquet;
	local tAuras;
	local function VUHDO_tryBouquetTrackOnlyForDispellableAura(aUnit, tCanColorGroup)

		tIsGroupActiveForBouquet = false;

		if tCanColorGroup["isListGroup"] and tCanColorGroup["entries"] then
			tIsGroupActiveForBouquet = VUHDO_isListGroupActiveForUnit(aUnit, tCanColorGroup["entries"]);
		elseif tCanColorGroup["isInferred"] then
			tIsGroupActiveForBouquet = VUHDO_hasInferredAura(aUnit) and VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tCanColorGroup["inferredType"]];
		elseif tCanColorGroup["filter"] then
			tAuras = VUHDO_getCachedFilteredAuras(aUnit, tCanColorGroup["filter"]);

			if tAuras then
				for tIdx = 1, #tAuras do
					if not (tCanColorGroup["excludeFilter"] and VUHDO_auraMatchesFilter(aUnit, tAuras[tIdx]["auraInstanceID"], tCanColorGroup["excludeFilter"]))
						and not VUHDO_isAuraIgnored(tAuras[tIdx], tCanColorGroup["groupId"]) then
						tIsGroupActiveForBouquet = true;

						break;
					end
				end
			end
		end

		if tIsGroupActiveForBouquet then
			sUnitAuraGroupActive[aUnit][tCanColorGroup["groupId"]] = VUHDO_AURA_GROUP_ACTIVE_NO_COLOR;
		end

		return;

	end



	--
	local tWinnerId;
	local tWinnerIdSecret;
	local tWinnerAppTime;
	local tWinnerAuraInstanceId;
	local tIsHostile;
	local tGroupActive;
	local tPanelAnchors;
	local tListSlots;
	local tAuraCache;
	local tAura;
	local tDispelType;
	local tAppTime;
	local tFoundDispelAuraId;
	local tNewWinner;
	local function VUHDO_tryListGroupForDispellableAura(aUnit, tCanColorGroup)

		tWinnerId = nil;
		tWinnerIdSecret = nil;
		tWinnerAppTime = -1;
		tWinnerAuraInstanceId = -1;

		tIsHostile = UnitCanAttack("player", aUnit);

		tGroupActive = false;

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			if VUHDO_PANEL_MODELS[tPanelNum] then
				tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

				if tPanelAnchors then
					for tAnchorKey, tAnchorConfig in pairs(tPanelAnchors) do
						if tAnchorConfig["enabled"] ~= false and tAnchorConfig["groupId"] == tCanColorGroup["groupId"] then
							tListSlots = (VUHDO_UNIT_AURA_LIST_SLOTS or sEmpty)[aUnit] and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tPanelNum] and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tPanelNum][tAnchorKey];

							if tListSlots then
								if tCanColorGroup["colorType"] == VUHDO_AURA_GROUP_COLOR_CUSTOM then
									for tEntryIndex, tSlotData in pairs(tListSlots) do
										if tSlotData["isActive"] then
											if not sUnitDispellableAuraId[aUnit] then
												sUnitDispellableAuraId[aUnit] = -1;
											end

											tFoundDispelAuraId = nil;

											if not tBarWinnerSet and tCanColorGroup["canColorBar"] then
												tNewWinner = sAuraColorWinnerPool:get();

												tNewWinner["colorType"] = tCanColorGroup["colorType"];
												tNewWinner["customColor"] = tCanColorGroup["customColor"];
												tNewWinner["dispelAuraId"] = nil;

												sUnitAuraBarWinner[aUnit] = tNewWinner;

												tBarWinnerSet = true;
											end

											if not tTextWinnerSet and tCanColorGroup["canColorText"] then
												tNewWinner = sAuraColorWinnerPool:get();

												tNewWinner["colorType"] = tCanColorGroup["colorType"];
												tNewWinner["customColor"] = tCanColorGroup["customColor"];
												tNewWinner["dispelAuraId"] = nil;

												sUnitAuraTextWinner[aUnit] = tNewWinner;

												tTextWinnerSet = true;
											end

											VUHDO_setGlowWinnerIfNeeded(aUnit, tCanColorGroup);

											tGroupActive = true;

											break;
										end
									end

									if tGroupActive then
										break;
									end
								elseif tCanColorGroup["colorType"] == VUHDO_AURA_GROUP_COLOR_DISPEL then
									for tEntryIndex, tSlotData in pairs(tListSlots) do
										if tSlotData["isActive"] and tSlotData["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL and tSlotData["auraInstanceID"] then
											tAuraCache = VUHDO_UNIT_AURA_CACHE and VUHDO_UNIT_AURA_CACHE[aUnit];

											if tAuraCache then
												tAura = tAuraCache[tSlotData["auraInstanceID"]];

												if tAura and tAura["dispelName"] then
													tDispelType = VUHDO_DEBUFF_TYPES[tAura["dispelName"]];

													if tDispelType and ((tIsHostile and tAura["isHelpful"] and VUHDO_PLAYER_PURGE_ABILITIES[tDispelType]) or
														(not tIsHostile and tAura["isHarmful"] and VUHDO_PLAYER_DISPEL_ABILITIES[tDispelType])) then
														if issecretvalue(tAura["expirationTime"]) or issecretvalue(tAura["duration"]) then
															if tSlotData["auraInstanceID"] > tWinnerAuraInstanceId then
																tWinnerAuraInstanceId = tSlotData["auraInstanceID"];
																tWinnerIdSecret = tSlotData["auraInstanceID"];
															end
														else
															tAppTime = (tAura["expirationTime"] or 0) - (tAura["duration"] or 0);

															if tAppTime > tWinnerAppTime then
																tWinnerAppTime = tAppTime;

																tWinnerId = tSlotData["auraInstanceID"];
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end

						if tGroupActive then
							break;
						end
					end
				end
			end

			if tGroupActive then
				break;
			end
		end

		if tGroupActive then
			VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, nil);

			if tBarWinnerSet and tTextWinnerSet then
				return true;
			end
		elseif tWinnerId or tWinnerIdSecret then
			tWinnerId = tWinnerId or tWinnerIdSecret;

			if not sUnitDispellableAuraId[aUnit] then
				sUnitDispellableAuraId[aUnit] = tWinnerId;
			end

			tFoundDispelAuraId = tWinnerId;

			if not tBarWinnerSet and tCanColorGroup["canColorBar"] then
				tNewWinner = sAuraColorWinnerPool:get();

				tNewWinner["colorType"] = tCanColorGroup["colorType"];
				tNewWinner["customColor"] = tCanColorGroup["customColor"];
				tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

				sUnitAuraBarWinner[aUnit] = tNewWinner;

				tBarWinnerSet = true;
			end

			if not tTextWinnerSet and tCanColorGroup["canColorText"] then
				tNewWinner = sAuraColorWinnerPool:get();

				tNewWinner["colorType"] = tCanColorGroup["colorType"];
				tNewWinner["customColor"] = tCanColorGroup["customColor"];
				tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

				sUnitAuraTextWinner[aUnit] = tNewWinner;

				tTextWinnerSet = true;
			end

			VUHDO_setGlowWinnerIfNeeded(aUnit, tCanColorGroup);

			VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, tWinnerId);

			if tBarWinnerSet and tTextWinnerSet then
				return true;
			end
		else
			if VUHDO_isListGroupActiveForUnit(aUnit, tCanColorGroup["entries"]) then
				if not sUnitDispellableAuraId[aUnit] then
					sUnitDispellableAuraId[aUnit] = -1;
				end

				if not tBarWinnerSet and tCanColorGroup["canColorBar"] then
					tNewWinner = sAuraColorWinnerPool:get();

					tNewWinner["colorType"] = tCanColorGroup["colorType"];
					tNewWinner["customColor"] = tCanColorGroup["customColor"];
					tNewWinner["dispelAuraId"] = nil;

					sUnitAuraBarWinner[aUnit] = tNewWinner;

					tBarWinnerSet = true;
				end

				if not tTextWinnerSet and tCanColorGroup["canColorText"] then
					tNewWinner = sAuraColorWinnerPool:get();

					tNewWinner["colorType"] = tCanColorGroup["colorType"];
					tNewWinner["customColor"] = tCanColorGroup["customColor"];
					tNewWinner["dispelAuraId"] = nil;

					sUnitAuraTextWinner[aUnit] = tNewWinner;

					tTextWinnerSet = true;
				end

				VUHDO_setGlowWinnerIfNeeded(aUnit, tCanColorGroup);

				VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, nil);

				if tBarWinnerSet and tTextWinnerSet then
					return true;
				end
			end
		end

		return false;

	end



	--
	local tFoundDispelAuraId;
	local tNewWinner;
	local function VUHDO_tryInferredForDispellableAura(aUnit, tCanColorGroup)

		if not sUnitDispellableAuraId[aUnit] then
			sUnitDispellableAuraId[aUnit] = VUHDO_INFERRED_AURA_SYNTHETIC_IDS[tCanColorGroup["inferredType"]] or -1;
		end

		tFoundDispelAuraId = VUHDO_INFERRED_AURA_SYNTHETIC_IDS[tCanColorGroup["inferredType"]] or -1;

		if not tBarWinnerSet and tCanColorGroup["canColorBar"] then
			tNewWinner = sAuraColorWinnerPool:get();

			tNewWinner["colorType"] = tCanColorGroup["colorType"];
			tNewWinner["customColor"] = tCanColorGroup["customColor"];
			tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

			sUnitAuraBarWinner[aUnit] = tNewWinner;

			tBarWinnerSet = true;
		end

		if not tTextWinnerSet and tCanColorGroup["canColorText"] then
			tNewWinner = sAuraColorWinnerPool:get();

			tNewWinner["colorType"] = tCanColorGroup["colorType"];
			tNewWinner["customColor"] = tCanColorGroup["customColor"];
			tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

			sUnitAuraTextWinner[aUnit] = tNewWinner;

			tTextWinnerSet = true;
		end

		VUHDO_setGlowWinnerIfNeeded(aUnit, tCanColorGroup);

		VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, tFoundDispelAuraId);

		if tBarWinnerSet and tTextWinnerSet then
			return true;
		end

		return false;

	end



	--
	local tAuras;
	local tAura;
	local tAuraInstanceId;
	local tFoundDispelAuraId;
	local tNewWinner;
	local function VUHDO_tryDispelCheckFilterForDispellableAura(aUnit, tCanColorGroup)

		tAuras = VUHDO_getCachedFilteredAuras(aUnit, tCanColorGroup["filter"]);

		if tAuras then
			for tIdx = 1, #tAuras do
				tAura = tAuras[tIdx];
				tAuraInstanceId = tAura["auraInstanceID"];

				if not ((tCanColorGroup["excludeFilter"] and VUHDO_auraMatchesFilter(aUnit, tAuraInstanceId, tCanColorGroup["excludeFilter"]))
					or VUHDO_isAuraIgnored(tAura, tCanColorGroup["groupId"])) then
					if not IsAuraFilteredOutByInstanceID(aUnit, tAuraInstanceId, tCanColorGroup["dispelCheckFilter"]) then
						if not sUnitDispellableAuraId[aUnit] then
							sUnitDispellableAuraId[aUnit] = tAuraInstanceId;
						end

						tFoundDispelAuraId = tAuraInstanceId;

						if not tBarWinnerSet and tCanColorGroup["canColorBar"] then
							tNewWinner = sAuraColorWinnerPool:get();

							tNewWinner["colorType"] = tCanColorGroup["colorType"];
							tNewWinner["customColor"] = tCanColorGroup["customColor"];
							tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

							sUnitAuraBarWinner[aUnit] = tNewWinner;

							tBarWinnerSet = true;
						end

						if not tTextWinnerSet and tCanColorGroup["canColorText"] then
							tNewWinner = sAuraColorWinnerPool:get();

							tNewWinner["colorType"] = tCanColorGroup["colorType"];
							tNewWinner["customColor"] = tCanColorGroup["customColor"];
							tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

							sUnitAuraTextWinner[aUnit] = tNewWinner;

							tTextWinnerSet = true;
						end

						VUHDO_setGlowWinnerIfNeeded(aUnit, tCanColorGroup);

						VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, tFoundDispelAuraId);

						if tBarWinnerSet and tTextWinnerSet then
							return true;
						end
					end
				end
			end
		end

		return false;

	end



	--
	local tAuras;
	local tAura;
	local tAuraInstanceId;
	local tFoundDispelAuraId;
	local tNewWinner;
	local function VUHDO_trySimpleFilterForDispellableAura(aUnit, tCanColorGroup)

		tAuras = VUHDO_getCachedFilteredAuras(aUnit, tCanColorGroup["filter"]);

		tAura = nil;
		tAuraInstanceId = nil;

		if tAuras then
			for tIdx = 1, #tAuras do
				tAura = tAuras[tIdx];
				tAuraInstanceId = tAura["auraInstanceID"];

				if (tCanColorGroup["excludeFilter"] and VUHDO_auraMatchesFilter(aUnit, tAuraInstanceId, tCanColorGroup["excludeFilter"]))
					or VUHDO_isAuraIgnored(tAura, tCanColorGroup["groupId"]) then
					tAura = nil;
					tAuraInstanceId = nil;
				else
					break;
				end
			end
		end

		if tAura and tAuraInstanceId then
			if not sUnitDispellableAuraId[aUnit] then
				sUnitDispellableAuraId[aUnit] = tAuraInstanceId;
			end

			tFoundDispelAuraId = tAuraInstanceId;

			if not tBarWinnerSet and tCanColorGroup["canColorBar"] then
				tNewWinner = sAuraColorWinnerPool:get();

				tNewWinner["colorType"] = tCanColorGroup["colorType"];
				tNewWinner["customColor"] = tCanColorGroup["customColor"];
				tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

				sUnitAuraBarWinner[aUnit] = tNewWinner;

				tBarWinnerSet = true;
			end

			if not tTextWinnerSet and tCanColorGroup["canColorText"] then
				tNewWinner = sAuraColorWinnerPool:get();

				tNewWinner["colorType"] = tCanColorGroup["colorType"];
				tNewWinner["customColor"] = tCanColorGroup["customColor"];
				tNewWinner["dispelAuraId"] = tFoundDispelAuraId;

				sUnitAuraTextWinner[aUnit] = tNewWinner;

				tTextWinnerSet = true;
			end

			VUHDO_setGlowWinnerIfNeeded(aUnit, tCanColorGroup);

			VUHDO_cacheAuraGroupBouquetColorForUnit(aUnit, tCanColorGroup, tFoundDispelAuraId);

			if tBarWinnerSet and tTextWinnerSet then
				return true;
			end
		end

		return false;

	end



	--
	local tBuffConfig;
	local tInfo;
	local tMissingBuffCategory;
	local tMissingColor;
	local function VUHDO_applyMissingBuffColorsForDispellableAura(aUnit)

		if (not tBarWinnerSet or not tTextWinnerSet) and VUHDO_RAID and VUHDO_RAID[aUnit] and VUHDO_RAID[aUnit]["missbuff"] then
			tBuffConfig = VUHDO_BUFF_SETTINGS["CONFIG"];

			if tBuffConfig and (tBuffConfig["BAR_COLORS_IN_FIGHT"] or not InCombatLockdown()) then
				tInfo = VUHDO_RAID[aUnit];
				tMissingBuffCategory = tInfo["mibucateg"];

				tMissingColor = tMissingBuffCategory and (VUHDO_BUFF_SETTINGS[tMissingBuffCategory] or sEmpty)["missingColor"];

				if tMissingColor then
					if not tBarWinnerSet and tBuffConfig["BAR_COLORS_BACKGROUND"] then
						tNewWinner = sAuraColorWinnerPool:get();

						tNewWinner["colorType"] = VUHDO_AURA_GROUP_COLOR_CUSTOM;
						tNewWinner["customColor"] = tMissingColor;
						tNewWinner["dispelAuraId"] = nil;

						sUnitAuraBarWinner[aUnit] = tNewWinner;

						tBarWinnerSet = true;
					end

					if not tTextWinnerSet and tBuffConfig["BAR_COLORS_TEXT"] then
						tNewWinner = sAuraColorWinnerPool:get();

						tNewWinner["colorType"] = VUHDO_AURA_GROUP_COLOR_CUSTOM;
						tNewWinner["customColor"] = tMissingColor;
						tNewWinner["dispelAuraId"] = nil;

						sUnitAuraTextWinner[aUnit] = tNewWinner;

						tTextWinnerSet = true;
					end
				end
			end
		end

		return;

	end



	--
	function VUHDO_updateDispellableAuraForUnit(aUnit)

		if not aUnit then
			return;
		end

		if sUnitAuraBarWinner[aUnit] then
			sAuraColorWinnerPool:release(sUnitAuraBarWinner[aUnit]);
			sUnitAuraBarWinner[aUnit] = nil;
		end

		if sUnitAuraTextWinner[aUnit] then
			sAuraColorWinnerPool:release(sUnitAuraTextWinner[aUnit]);
			sUnitAuraTextWinner[aUnit] = nil;
		end

		sUnitDispellableAuraId[aUnit] = nil;
		sUnitAuraCanColorBar[aUnit] = nil;
		sUnitAuraColorType[aUnit] = nil;
		sUnitAuraCustomColor[aUnit] = nil;
		sUnitAuraGlowWinner[aUnit] = nil;

		tBarWinnerSet = false;
		tTextWinnerSet = false;
		sGlowWinnerSet = false;

		VUHDO_resetUnitAuraGroupActiveSubtable(aUnit);

		VUHDO_resetFilterResultCache();

		for tCnt = 1, #sCanColorBarGroups do
			tCanColorGroup = sCanColorBarGroups[tCnt];

			if tCanColorGroup["bouquetTrackOnly"] then
				VUHDO_tryBouquetTrackOnlyForDispellableAura(aUnit, tCanColorGroup);
			elseif tCanColorGroup["isListGroup"] and tCanColorGroup["groupId"] then
				if VUHDO_tryListGroupForDispellableAura(aUnit, tCanColorGroup) then
					return;
				end
			elseif tCanColorGroup["isInferred"] and VUHDO_hasInferredAura(aUnit) and
				VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tCanColorGroup["inferredType"]] then
				if VUHDO_tryInferredForDispellableAura(aUnit, tCanColorGroup) then
					return;
				end
			elseif tCanColorGroup["dispelCheckFilter"] and ((tCanColorGroup["isHelpful"] and VUHDO_PLAYER_HAS_PURGE and UnitCanAttack("player", aUnit)) or
				(not tCanColorGroup["isHelpful"] and VUHDO_PLAYER_HAS_DISPEL and not UnitCanAttack("player", aUnit))) then
				if VUHDO_tryDispelCheckFilterForDispellableAura(aUnit, tCanColorGroup) then
					return;
				end
			elseif not tCanColorGroup["isInferred"] and not tCanColorGroup["dispelCheckFilter"] and tCanColorGroup["filter"] then
				if VUHDO_trySimpleFilterForDispellableAura(aUnit, tCanColorGroup) then
					return;
				end
			end
		end

		VUHDO_applyMissingBuffColorsForDispellableAura(aUnit);

		if sUnitAuraBarWinner[aUnit] then
			sUnitAuraColorType[aUnit] = sUnitAuraBarWinner[aUnit]["colorType"];
			sUnitAuraCustomColor[aUnit] = sUnitAuraBarWinner[aUnit]["customColor"];

			sUnitAuraCanColorBar[aUnit] = true;
		elseif sUnitAuraTextWinner[aUnit] then
			sUnitAuraColorType[aUnit] = sUnitAuraTextWinner[aUnit]["colorType"];
			sUnitAuraCustomColor[aUnit] = sUnitAuraTextWinner[aUnit]["customColor"];
		end

		return;

	end



	--
	function VUHDO_getDispellableAuraId(aUnit)

		return sUnitDispellableAuraId[aUnit];

	end



	--
	function VUHDO_hasDispellableAura(aUnit)

		return sUnitDispellableAuraId[aUnit] ~= nil;

	end



	--
	function VUHDO_getAuraColorType(aUnit)

		return sUnitAuraColorType[aUnit];

	end



	--
	function VUHDO_getAuraCustomColor(aUnit)

		return sUnitAuraCustomColor[aUnit];

	end



	--
	function VUHDO_getAuraCanColorBar(aUnit)

		return sUnitAuraBarWinner[aUnit] ~= nil;

	end



	--
	function VUHDO_getAuraCanColorText(aUnit)

		return sUnitAuraTextWinner[aUnit] ~= nil;

	end



	--
	local tBarWinner;
	function VUHDO_getAuraBarColorType(aUnit)

		tBarWinner = sUnitAuraBarWinner[aUnit];

		if tBarWinner then
			return tBarWinner["colorType"];
		end

		return nil;

	end



	--
	local tTextWinner;
	function VUHDO_getAuraTextColorType(aUnit)

		tTextWinner = sUnitAuraTextWinner[aUnit];

		if tTextWinner then
			return tTextWinner["colorType"];
		end

		return nil;

	end



	--
	local tGlowWinnerColor;
	local tDefaultGlow;
	function VUHDO_getAuraGroupGlowInfo(aUnit)

		tGlowWinnerColor = sUnitAuraGlowWinner[aUnit];

		if tGlowWinnerColor == nil then
			return false, nil;
		end

		if tGlowWinnerColor and tGlowWinnerColor["R"] then
			sGlowColorBuffer[1] = tGlowWinnerColor["R"];
			sGlowColorBuffer[2] = tGlowWinnerColor["G"];
			sGlowColorBuffer[3] = tGlowWinnerColor["B"];
			sGlowColorBuffer[4] = tGlowWinnerColor["O"] or 1;
		else
			tDefaultGlow = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"] and VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF_BAR_GLOW"];

			if tDefaultGlow then
				sGlowColorBuffer[1] = tDefaultGlow["R"];
				sGlowColorBuffer[2] = tDefaultGlow["G"];
				sGlowColorBuffer[3] = tDefaultGlow["B"];
				sGlowColorBuffer[4] = tDefaultGlow["O"] or 1;
			else
				sGlowColorBuffer[1] = 0.95;
				sGlowColorBuffer[2] = 0.95;
				sGlowColorBuffer[3] = 0.32;
				sGlowColorBuffer[4] = 1;
			end
		end

		return true, sGlowColorBuffer;

	end



	--
	local tDispelCurve;
	local tDispelColorMixin;
	function VUHDO_getAuraBarColor(aUnit, aDispelCurve)

		tBarWinner = sUnitAuraBarWinner[aUnit];

		if not tBarWinner then
			return nil;
		end

		if tBarWinner["colorType"] == VUHDO_AURA_GROUP_COLOR_CUSTOM then
			return tBarWinner["customColor"];
		end

		if tBarWinner["colorType"] == VUHDO_AURA_GROUP_COLOR_DISPEL and tBarWinner["dispelAuraId"] then
			tDispelCurve = aDispelCurve or VUHDO_getDispelCurveForUnit(aUnit, true);

			if tDispelCurve then
				tDispelColorMixin = GetAuraDispelTypeColor(aUnit, tBarWinner["dispelAuraId"], tDispelCurve);

				if tDispelColorMixin then
					sDispelColorBuffer["R"] = tDispelColorMixin.r;
					sDispelColorBuffer["G"] = tDispelColorMixin.g;
					sDispelColorBuffer["B"] = tDispelColorMixin.b;
					sDispelColorBuffer["O"] = tDispelColorMixin.a or 1;

					sDispelColorBuffer["useBackground"] = true;
					sDispelColorBuffer["useText"] = nil;

					sDispelColorBuffer["TR"] = tDispelColorMixin.r;
					sDispelColorBuffer["TG"] = tDispelColorMixin.g;
					sDispelColorBuffer["TB"] = tDispelColorMixin.b;
					sDispelColorBuffer["TO"] = tDispelColorMixin.a or 1;

					return sDispelColorBuffer;
				end
			end
		end

		return nil;

	end



	--
	local tTextWinner;
	function VUHDO_getAuraTextColor(aUnit, aDispelTextCurve)

		tTextWinner = sUnitAuraTextWinner[aUnit];

		if not tTextWinner then
			return nil;
		end

		if tTextWinner["colorType"] == VUHDO_AURA_GROUP_COLOR_CUSTOM then
			return tTextWinner["customColor"];
		end

		if tTextWinner["colorType"] == VUHDO_AURA_GROUP_COLOR_DISPEL and tTextWinner["dispelAuraId"] then
			tDispelCurve = aDispelTextCurve or VUHDO_getDispelTextCurveForUnit(aUnit, true);

			if tDispelCurve then
				tDispelColorMixin = GetAuraDispelTypeColor(aUnit, tTextWinner["dispelAuraId"], tDispelCurve);

				if tDispelColorMixin then
					sDispelColorBuffer["R"] = tDispelColorMixin.r;
					sDispelColorBuffer["G"] = tDispelColorMixin.g;
					sDispelColorBuffer["B"] = tDispelColorMixin.b;
					sDispelColorBuffer["O"] = tDispelColorMixin.a or 1;

					sDispelColorBuffer["useBackground"] = nil;
					sDispelColorBuffer["useText"] = true;

					sDispelColorBuffer["TR"] = tDispelColorMixin.r;
					sDispelColorBuffer["TG"] = tDispelColorMixin.g;
					sDispelColorBuffer["TB"] = tDispelColorMixin.b;
					sDispelColorBuffer["TO"] = tDispelColorMixin.a or 1;

					return sDispelColorBuffer;
				end
			end
		end

		return nil;

	end



	--
	function VUHDO_getAuraGroupActiveColor(aUnit, aGroupId)

		if not aUnit or not aGroupId then
			return nil;
		end

		return sUnitAuraGroupActive[aUnit] and sUnitAuraGroupActive[aUnit][aGroupId];

	end



	--
	function VUHDO_clearDispellableAuraCache(aUnit)

		if aUnit then
			if sUnitAuraBarWinner[aUnit] then
				sAuraColorWinnerPool:release(sUnitAuraBarWinner[aUnit]);
			end

			if sUnitAuraTextWinner[aUnit] then
				sAuraColorWinnerPool:release(sUnitAuraTextWinner[aUnit]);
			end

			tSubMapForAuraGroup = sUnitAuraGroupActive[aUnit];

			if tSubMapForAuraGroup then
				for _, tPooledAuraGroupColor in pairs(tSubMapForAuraGroup) do
					if tPooledAuraGroupColor and tPooledAuraGroupColor["isAuraGroupBouquetColorPooled"] then
						sAuraGroupActiveColorPool:release(tPooledAuraGroupColor);
					end
				end
			end

			sUnitAuraGroupActive[aUnit] = nil;

			sUnitDispellableAuraId[aUnit] = nil;
			sUnitAuraCanColorBar[aUnit] = nil;
			sUnitAuraColorType[aUnit] = nil;
			sUnitAuraCustomColor[aUnit] = nil;
			sUnitAuraBarWinner[aUnit] = nil;
			sUnitAuraTextWinner[aUnit] = nil;
			sUnitAuraGlowWinner[aUnit] = nil;
		else
			for tUnit, _ in pairs(sUnitAuraBarWinner) do
				if sUnitAuraBarWinner[tUnit] then
					sAuraColorWinnerPool:release(sUnitAuraBarWinner[tUnit]);
				end

				if sUnitAuraTextWinner[tUnit] then
					sAuraColorWinnerPool:release(sUnitAuraTextWinner[tUnit]);
				end
			end

			for tUnit, _ in pairs(sUnitAuraTextWinner) do
				if not sUnitAuraBarWinner[tUnit] and sUnitAuraTextWinner[tUnit] then
					sAuraColorWinnerPool:release(sUnitAuraTextWinner[tUnit]);
				end
			end

			twipe(sUnitDispellableAuraId);
			twipe(sUnitAuraCanColorBar);
			twipe(sUnitAuraColorType);
			twipe(sUnitAuraCustomColor);
			twipe(sUnitAuraBarWinner);
			twipe(sUnitAuraTextWinner);
			twipe(sUnitAuraGlowWinner);

			for tU, tMap in pairs(sUnitAuraGroupActive) do
				for _, tAuraGroupBouquetColor in pairs(tMap) do
					if tAuraGroupBouquetColor and tAuraGroupBouquetColor["isAuraGroupBouquetColorPooled"] then
						sAuraGroupActiveColorPool:release(tAuraGroupBouquetColor);
					end
				end
			end

			twipe(sUnitAuraGroupActive);
		end

		return;

	end
end



do
	--
	local tInfo;
	function VUHDO_determineAura(aUnit)

		tInfo = (VUHDO_RAID or sEmpty)[aUnit];

		if not tInfo then
			return nil, nil;
		end

		VUHDO_updateDispellableAuraForUnit(aUnit);

		if VUHDO_hasDispellableAura(aUnit) then
			return VUHDO_getDispellableAuraId(aUnit), nil;
		end

		if sUnitAuraBarWinner[aUnit] or sUnitAuraTextWinner[aUnit] then
			return -1, nil;
		end

		return nil, nil;

	end
end