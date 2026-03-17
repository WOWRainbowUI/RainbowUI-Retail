local _;

local table = table;
local tinsert = table.insert;
local tsort = table.sort;
local twipe = table.wipe;
local pairs = pairs;
local ipairs = ipairs;
local strfind = string.find;

local UnitCanAttack = UnitCanAttack;
local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras;
local issecretvalue = issecretvalue;
local GetAuraDispelTypeColor = C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor;
local IsAuraFilteredOutByInstanceID = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID;

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
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

local VUHDO_getDispelCurveForUnit;
local VUHDO_hasInferredAura;
local VUHDO_createTablePool;

local sUnitDispellableAuraId = { };
local sUnitAuraCanColorBar = { };
local sUnitAuraColorType = { };
local sUnitAuraCustomColor = { };
local sCanColorBarGroups = { };
local sUnitAuraBarWinner = { };
local sUnitAuraTextWinner = { };
local sUnitAuraGlowWinner = { };

local sGlowWinnerSet;

local sAuraColorWinnerPool;
local sCanColorBarGroupPool;

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
	aGroup["dispelCheckFilter"] = nil;
	aGroup["isHelpful"] = nil;

	return;

end



--
function VUHDO_auraColorsInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
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

	VUHDO_getDispelCurveForUnit = _G["VUHDO_getDispelCurveForUnit"];
	VUHDO_hasInferredAura = _G["VUHDO_hasInferredAura"];
	VUHDO_createTablePool = _G["VUHDO_createTablePool"];

	sAuraColorWinnerPool = VUHDO_createTablePool("AuraColorWinner", 100, VUHDO_createAuraColorWinnerDelegate, VUHDO_cleanupAuraColorWinnerDelegate);
	sCanColorBarGroupPool = VUHDO_createTablePool("CanColorBarGroup", 50, VUHDO_createCanColorBarGroupDelegate, VUHDO_cleanupCanColorBarGroupDelegate);

	return;

end



do
	--
	local tEffectiveColorType;
	local tColorBarGroup;
	function VUHDO_rebuildCanColorBarGroupsCache()

		for tIdx = 1, #sCanColorBarGroups do
			sCanColorBarGroupPool:release(sCanColorBarGroups[tIdx]);
		end

		twipe(sCanColorBarGroups);

		for tGroupId, tGroup in pairs(VUHDO_CONFIG["AURA_GROUPS"] or sEmpty) do
			tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

			if (tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL or tGroup["canGlowBar"]) and tGroup["enabled"] ~= false then
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

						tinsert(sCanColorBarGroups, tColorBarGroup);
					else
						tColorBarGroup["filter"] = tGroup["filter"];

						if tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
							if strfind(tGroup["filter"], "HARMFUL", 1, true) then
								tColorBarGroup["dispelCheckFilter"] = "HARMFUL|RAID_PLAYER_DISPELLABLE";
							else
								tColorBarGroup["dispelCheckFilter"] = "HELPFUL|RAID_PLAYER_DISPELLABLE";
							end

							tColorBarGroup["isHelpful"] = not strfind(tGroup["filter"], "HARMFUL", 1, true);
						end

						tinsert(sCanColorBarGroups, tColorBarGroup);
					end
				end
			end
		end

		for tGroupId, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or sEmpty) do
			if not tGroup["playerClassRequired"] or tGroup["playerClassRequired"] == VUHDO_PLAYER_CLASS then
				tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

				if not (VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][tGroupId]) and (tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL or tGroup["canGlowBar"]) and
					tGroup["enabled"] ~= false and not (VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][tGroupId]) and
					not (VUHDO_DEFAULT_AURA_GROUPS[tGroupId] and VUHDO_DEFAULT_AURA_GROUPS[tGroupId]["enabled"] == false) then
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

							tinsert(sCanColorBarGroups, tColorBarGroup);
						else
							tColorBarGroup["filter"] = tGroup["filter"];

							if tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
								if strfind(tGroup["filter"], "HARMFUL", 1, true) then
									tColorBarGroup["dispelCheckFilter"] = "HARMFUL|RAID_PLAYER_DISPELLABLE";
								else
									tColorBarGroup["dispelCheckFilter"] = "HELPFUL|RAID_PLAYER_DISPELLABLE";
								end

								tColorBarGroup["isHelpful"] = not strfind(tGroup["filter"], "HARMFUL", 1, true);
							end

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



	--
	local tEntryValue;
	local tAuraInstances;
	local tBouquetActive;
	local function VUHDO_isListGroupActiveForUnit(aUnit, aEntries)

		if not aEntries then
			return false;
		end

		for _, tEntry in ipairs(aEntries) do
			if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
				tEntryValue = tEntry["value"];

				if tEntryValue and VUHDO_UNIT_AURA_BY_SPELL[aUnit] then
					tAuraInstances = VUHDO_UNIT_AURA_BY_SPELL[aUnit][tEntryValue];

					if tAuraInstances and #tAuraInstances > 0 then
						return true;
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
	local tAuras;
	local tAura;
	local tAuraInstanceId;
	local tCanColorGroup;
	local tPanelAnchors;
	local tListSlots;
	local tAuraCache;
	local tAppTime;
	local tWinnerId;
	local tWinnerIdSecret;
	local tWinnerAppTime;
	local tWinnerAuraInstanceId;
	local tDispelType;
	local tIsHostile;
	local tBarWinnerSet;
	local tTextWinnerSet;
	local tFoundDispelAuraId;
	local tGroupActive;
	local tNewWinner;
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

		for tCnt = 1, #sCanColorBarGroups do
			tCanColorGroup = sCanColorBarGroups[tCnt];

			if tCanColorGroup["isListGroup"] and tCanColorGroup["groupId"] then
				tWinnerId = nil;
				tWinnerIdSecret = nil;
				tWinnerAppTime = -1;
				tWinnerAuraInstanceId = -1;

				tIsHostile = UnitCanAttack("player", aUnit);

				tGroupActive = false;

				for tPanelNum = 1, VUHDO_MAX_PANELS do
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

					if tGroupActive then
						break;
					end
				end

				if tGroupActive then
					if tBarWinnerSet and tTextWinnerSet then
						return;
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

					if tBarWinnerSet and tTextWinnerSet then
						return;
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

						if tBarWinnerSet and tTextWinnerSet then
							return;
						end
					end
				end
			elseif tCanColorGroup["isInferred"] and VUHDO_hasInferredAura(aUnit) and
				VUHDO_INFERRED_AURAS[aUnit] and VUHDO_INFERRED_AURAS[aUnit][tCanColorGroup["inferredType"]] then
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

				if tBarWinnerSet and tTextWinnerSet then
					return;
				end
			elseif tCanColorGroup["dispelCheckFilter"] and ((tCanColorGroup["isHelpful"] and VUHDO_PLAYER_HAS_PURGE and UnitCanAttack("player", aUnit)) or
				(not tCanColorGroup["isHelpful"] and VUHDO_PLAYER_HAS_DISPEL and not UnitCanAttack("player", aUnit))) then
				tAuras = GetUnitAuras(aUnit, tCanColorGroup["filter"], 40, Enum.UnitAuraSortRule.Default, 1);

				if tAuras then
					for tIdx = 1, #tAuras do
						tAura = tAuras[tIdx];
						tAuraInstanceId = tAura["auraInstanceID"];

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

							if tBarWinnerSet and tTextWinnerSet then
								return;
							end
						end
					end
				end
			elseif not tCanColorGroup["isInferred"] and not tCanColorGroup["dispelCheckFilter"] and tCanColorGroup["filter"] then
				tAuras = GetUnitAuras(aUnit, tCanColorGroup["filter"], 1, Enum.UnitAuraSortRule.Default, 1);

				if tAuras and #tAuras > 0 then
					tAura = tAuras[1];
					tAuraInstanceId = tAura["auraInstanceID"];

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

					if tBarWinnerSet and tTextWinnerSet then
						return;
					end
				end
			end
		end

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
	function VUHDO_getAuraTextColor(aUnit, aDispelCurve)

		tTextWinner = sUnitAuraTextWinner[aUnit];

		if not tTextWinner then
			return nil;
		end

		if tTextWinner["colorType"] == VUHDO_AURA_GROUP_COLOR_CUSTOM then
			return tTextWinner["customColor"];
		end

		if tTextWinner["colorType"] == VUHDO_AURA_GROUP_COLOR_DISPEL and tTextWinner["dispelAuraId"] then
			tDispelCurve = aDispelCurve or VUHDO_getDispelCurveForUnit(aUnit, true);

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
	function VUHDO_clearDispellableAuraCache(aUnit)

		if aUnit then
			if sUnitAuraBarWinner[aUnit] then
				sAuraColorWinnerPool:release(sUnitAuraBarWinner[aUnit]);
			end

			if sUnitAuraTextWinner[aUnit] then
				sAuraColorWinnerPool:release(sUnitAuraTextWinner[aUnit]);
			end

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

		return nil, nil;

	end
end