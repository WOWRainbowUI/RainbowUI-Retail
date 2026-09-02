local _;

local ipairs = ipairs;
local pairs = pairs;
local type = type;
local tonumber = tonumber;
local strsplit = strsplit;
local strupper = string.upper;
local strfind = string.find;
local strsub = string.sub;
local twipe = table.wipe;
local tinsert = table.insert;
local floor = math.floor;

local GetSpellName = C_Spell.GetSpellName;
local GetSpellIDForSpellIdentifier = C_Spell.GetSpellIDForSpellIdentifier;

VUHDO_AURA_NAME_TO_SPELL_IDS = { };
local VUHDO_AURA_NAME_TO_SPELL_IDS = VUHDO_AURA_NAME_TO_SPELL_IDS;

VUHDO_AURA_NAME_PREFERRED_SPELL_ID = { };
local VUHDO_AURA_NAME_PREFERRED_SPELL_ID = VUHDO_AURA_NAME_PREFERRED_SPELL_ID;

VUHDO_AURA_CONTAINER_MAPPED_SPELL_IDS = {
	-- [200025] = { 53563 }, -- Beacon of Virtue to Beacon of Light
};
local VUHDO_AURA_CONTAINER_MAPPED_SPELL_IDS = VUHDO_AURA_CONTAINER_MAPPED_SPELL_IDS;

local VUHDO_AURA_NATIVE_FILTER_TOKENS = {
	["HELPFUL"] = true,
	["HARMFUL"] = true,
	["PLAYER"] = true,
	["RAID"] = true,
	["CANCELABLE"] = true,
	["INCLUDE_NAME_PLATE_ONLY"] = true,
	["MAW"] = true,
	["EXTERNAL_DEFENSIVE"] = true,
	["CROWD_CONTROL"] = true,
	["RAID_IN_COMBAT"] = true,
	["RAID_PLAYER_DISPELLABLE"] = true,
	["BIG_DEFENSIVE"] = true,
	["IMPORTANT"] = true,
	["DISPELLABLE"] = true,
};

local VUHDO_AURA_IGNORE_LIST;
local VUHDO_AURA_GROUP_TYPE_FILTER;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_SPELL;
local VUHDO_AURA_LIST_ENTRY_BOUQUET;
local VUHDO_AURA_LIST_ENTRY_EMPTY;
local VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER;
local VUHDO_BOUQUET_RESTRICTED_NON_AURA;
local VUHDO_BOUQUET_RESTRICTED_MIXED;
local VUHDO_SPELL_DURATION_MODE_THRESHOLD;
local VUHDO_SPELL_NAME_TO_ID;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_RADIOVALUE_POSITIONS;
local VUHDO_AURA_FIXED_STRAIGHT_POSITIONS;
local VUHDO_AURA_FIXED_DIAGONAL_POSITIONS;
local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local VUHDO_AURA_CONTAINER_TEMPLATE_CACHE;
local VUHDO_AURA_GROWTH_OFFSETS;
local VUHDO_AURA_BUTTON_ICON_TEMPLATE;
local VUHDO_AURA_BUTTON_BAR_TEMPLATE;
local VUHDO_DEBUFF_TYPES;
local VUHDO_PLAYER_DISPEL_ABILITIES;
local VUHDO_PLAYER_PURGE_ABILITIES;
local VUHDO_DEFAULT_AURA_GLOW_STYLE;

local VUHDO_getAuraGroup;
local VUHDO_classifyBouquetRestrictedMode;
local VUHDO_buildListEntryContainerGroupTemplate;
local VUHDO_buildMixedBouquetListSlotTemplates;
local VUHDO_applyBarButtonSetupFields;
local VUHDO_getAuraTimerFormatter;
local VUHDO_getAuraTimerColorCurve;
local VUHDO_getTriStateBool;
local VUHDO_buildAnchorButtonSetup;
local VUHDO_getHealthBarWidth;
local VUHDO_getHealthBarHeight;
local VUHDO_getAuraIconSizePixels;
local VUHDO_getAuraBarWidthPixels;
local VUHDO_getAuraBarHeightPixels;
local VUHDO_getAuraBarWidthPixelsVertical;
local VUHDO_getAuraBarHeightPixelsVertical;
local VUHDO_deepCopyTable;

local sEmpty = { };

local sAllDispelTypeNames = { };
local sPlayerDispelTypeNames = { };
local sPlayerPurgeDispelTypeNames = { };
local sAllDispelBarColorTypeNames = { };
local sPlayerDispelBarColorTypeNames = { };
local sPlayerPurgeBarColorTypeNames = { };
local sAllDispelGlowTypeNames = { };
local sPlayerDispelGlowTypeNames = { };
local sPlayerPurgeGlowTypeNames = { };
local sGroupResolvedFilterCache = { };
local sGlobalIgnoreSpellIds;

local sNonNegatableFilterTokens = {
	["INCLUDE_NAME_PLATE_ONLY"] = true,
	["MAW"] = true,
};

local sCandidateBooleanKeys = {
	"isStealable",
	"isFromPlayerOrPlayerPet",
	"isRoleAura",
	"isPriorityAura",
	"isBossAura",
	"isBossOrRoleAura",
	"canApplyAura",
	"nameplateShowAll",
	"nameplateShowPersonal",
};

local sAuraBarFallbackColor = {
	["R"] = 0.2,
	["G"] = 0.6,
	["B"] = 0.2,
	["O"] = 1,
};

local sSortRuleToMethod = {
	[0] = AuraContainerSortMethod.Default,
	[1] = AuraContainerSortMethod.Default,
	[2] = AuraContainerSortMethod.BigDefensive,
	[3] = AuraContainerSortMethod.Expiration,
	[4] = AuraContainerSortMethod.ExpirationOnly,
	[5] = AuraContainerSortMethod.Name,
	[6] = AuraContainerSortMethod.NameOnly,
};

local sFlowHorizontal = {
	["LEFT"] = AnchorUtil.FlowDirection.Left,
	["RIGHT"] = AnchorUtil.FlowDirection.Right,
};

local sFlowVertical = {
	["UP"] = AnchorUtil.FlowDirection.Up,
	["DOWN"] = AnchorUtil.FlowDirection.Down,
};

local sGrowthAxis = {
	["LEFT"] = AnchorUtil.FlowLayoutAxis.Horizontal,
	["RIGHT"] = AnchorUtil.FlowLayoutAxis.Horizontal,
	["UP"] = AnchorUtil.FlowLayoutAxis.Vertical,
	["DOWN"] = AnchorUtil.FlowLayoutAxis.Vertical,
};



--
local tLayoutAxis;
local tHorizontalDir;
local tVerticalDir;
local tGrowthAxis;
local tWrapAxis;
local function VUHDO_resolveAnchorFlowDirections(aGrowthDir, aWrapDir, aMaxColumns)

	if (aMaxColumns or 5) <= 1 then
		tWrapAxis = sGrowthAxis[aWrapDir] or AnchorUtil.FlowLayoutAxis.Horizontal;

		if AnchorUtil.FlowLayoutAxis.Vertical == tWrapAxis then
			tLayoutAxis = AnchorUtil.FlowLayoutAxis.Vertical;
			tVerticalDir = sFlowVertical[aWrapDir] or AnchorUtil.FlowDirection.Down;
			tHorizontalDir = AnchorUtil.FlowDirection.Right;
		else
			tLayoutAxis = AnchorUtil.FlowLayoutAxis.Horizontal;
			tHorizontalDir = sFlowHorizontal[aWrapDir] or AnchorUtil.FlowDirection.Right;
			tVerticalDir = AnchorUtil.FlowDirection.Down;
		end

		return tLayoutAxis, tHorizontalDir, tVerticalDir;
	end

	tGrowthAxis = sGrowthAxis[aGrowthDir] or AnchorUtil.FlowLayoutAxis.Horizontal;

	if AnchorUtil.FlowLayoutAxis.Horizontal == tGrowthAxis then
		tLayoutAxis = AnchorUtil.FlowLayoutAxis.Horizontal;
		tHorizontalDir = sFlowHorizontal[aGrowthDir] or AnchorUtil.FlowDirection.Right;
		tVerticalDir = sFlowVertical[aWrapDir] or AnchorUtil.FlowDirection.Down;

		if AnchorUtil.FlowLayoutAxis.Horizontal == sGrowthAxis[aWrapDir] then
			tVerticalDir = AnchorUtil.FlowDirection.Down;
		end
	else
		tLayoutAxis = AnchorUtil.FlowLayoutAxis.Vertical;
		tVerticalDir = sFlowVertical[aGrowthDir] or AnchorUtil.FlowDirection.Down;
		tHorizontalDir = sFlowHorizontal[aWrapDir] or AnchorUtil.FlowDirection.Right;

		if AnchorUtil.FlowLayoutAxis.Vertical == sGrowthAxis[aWrapDir] then
			tHorizontalDir = AnchorUtil.FlowDirection.Right;
		end
	end

	return tLayoutAxis, tHorizontalDir, tVerticalDir;

end



--
function VUHDO_auraContainerFiltersInitLocalOverrides()

	VUHDO_AURA_IGNORE_LIST = _G["VUHDO_AURA_IGNORE_LIST"];
	VUHDO_AURA_GROUP_TYPE_FILTER = _G["VUHDO_AURA_GROUP_TYPE_FILTER"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_AURA_LIST_ENTRY_SPELL = _G["VUHDO_AURA_LIST_ENTRY_SPELL"];
	VUHDO_AURA_LIST_ENTRY_BOUQUET = _G["VUHDO_AURA_LIST_ENTRY_BOUQUET"];
	VUHDO_AURA_LIST_ENTRY_EMPTY = _G["VUHDO_AURA_LIST_ENTRY_EMPTY"];
	VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER = _G["VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER"];
	VUHDO_BOUQUET_RESTRICTED_NON_AURA = _G["VUHDO_BOUQUET_RESTRICTED_NON_AURA"];
	VUHDO_BOUQUET_RESTRICTED_MIXED = _G["VUHDO_BOUQUET_RESTRICTED_MIXED"];
	VUHDO_SPELL_DURATION_MODE_THRESHOLD = _G["VUHDO_SPELL_DURATION_MODE_THRESHOLD"];
	VUHDO_SPELL_NAME_TO_ID = _G["VUHDO_SPELL_NAME_TO_ID"];
	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_AURA_RADIOVALUE_POSITIONS = _G["VUHDO_AURA_RADIOVALUE_POSITIONS"];
	VUHDO_AURA_FIXED_STRAIGHT_POSITIONS = _G["VUHDO_AURA_FIXED_STRAIGHT_POSITIONS"];
	VUHDO_AURA_FIXED_DIAGONAL_POSITIONS = _G["VUHDO_AURA_FIXED_DIAGONAL_POSITIONS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_AURA_CONTAINER_TEMPLATE_CACHE = _G["VUHDO_AURA_CONTAINER_TEMPLATE_CACHE"];
	VUHDO_AURA_GROWTH_OFFSETS = _G["VUHDO_AURA_GROWTH_OFFSETS"];
	VUHDO_AURA_BUTTON_ICON_TEMPLATE = _G["VUHDO_AURA_BUTTON_ICON_TEMPLATE"];
	VUHDO_AURA_BUTTON_BAR_TEMPLATE = _G["VUHDO_AURA_BUTTON_BAR_TEMPLATE"];
	VUHDO_DEBUFF_TYPES = _G["VUHDO_DEBUFF_TYPES"];
	VUHDO_PLAYER_DISPEL_ABILITIES = _G["VUHDO_PLAYER_DISPEL_ABILITIES"];
	VUHDO_PLAYER_PURGE_ABILITIES = _G["VUHDO_PLAYER_PURGE_ABILITIES"];
	VUHDO_DEFAULT_AURA_GLOW_STYLE = _G["VUHDO_DEFAULT_AURA_GLOW_STYLE"];

	VUHDO_getAuraGroup = _G["VUHDO_getAuraGroup"];
	VUHDO_classifyBouquetRestrictedMode = _G["VUHDO_classifyBouquetRestrictedMode"];
	VUHDO_buildListEntryContainerGroupTemplate = _G["VUHDO_buildListEntryContainerGroupTemplate"];
	VUHDO_buildMixedBouquetListSlotTemplates = _G["VUHDO_buildMixedBouquetListSlotTemplates"];
	VUHDO_applyBarButtonSetupFields = _G["VUHDO_applyBarButtonSetupFields"];
	VUHDO_getAuraTimerFormatter = _G["VUHDO_getAuraTimerFormatter"];
	VUHDO_getAuraTimerColorCurve = _G["VUHDO_getAuraTimerColorCurve"];
	VUHDO_getTriStateBool = _G["VUHDO_getTriStateBool"];
	VUHDO_buildAnchorButtonSetup = _G["VUHDO_buildAnchorButtonSetup"];
	VUHDO_getHealthBarWidth = _G["VUHDO_getHealthBarWidth"];
	VUHDO_getHealthBarHeight = _G["VUHDO_getHealthBarHeight"];
	VUHDO_getAuraIconSizePixels = _G["VUHDO_getAuraIconSizePixels"];
	VUHDO_getAuraBarWidthPixels = _G["VUHDO_getAuraBarWidthPixels"];
	VUHDO_getAuraBarHeightPixels = _G["VUHDO_getAuraBarHeightPixels"];
	VUHDO_getAuraBarWidthPixelsVertical = _G["VUHDO_getAuraBarWidthPixelsVertical"];
	VUHDO_getAuraBarHeightPixelsVertical = _G["VUHDO_getAuraBarHeightPixelsVertical"];
	VUHDO_deepCopyTable = _G["VUHDO_deepCopyTable"];

	VUHDO_rebuildDispelTypeNameMaps();
	VUHDO_rebuildDefaultAuraNameSpellIds();

	return;

end



--
local tValue;
local tSpellId;
local tSpellName;
local tNameIds;
function VUHDO_rebuildDefaultAuraNameSpellIds()

	twipe(VUHDO_AURA_NAME_TO_SPELL_IDS);
	twipe(VUHDO_AURA_NAME_PREFERRED_SPELL_ID);

	for _, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or sEmpty) do
		if tGroup["type"] == VUHDO_AURA_GROUP_TYPE_LIST and not tGroup["isHarmful"] then
			for _, tEntry in ipairs(tGroup["entries"] or sEmpty) do
				if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
					tValue = tEntry["value"];

					if type(tValue) == "number" then
						tSpellId = tValue;
						tSpellName = GetSpellName(tSpellId);

						if tSpellName then
							tNameIds = VUHDO_AURA_NAME_TO_SPELL_IDS[tSpellName];

							if not tNameIds then
								tNameIds = { };
								VUHDO_AURA_NAME_TO_SPELL_IDS[tSpellName] = tNameIds;
							end

							tNameIds[tSpellId] = true;

							VUHDO_AURA_NAME_PREFERRED_SPELL_ID[tSpellName] = VUHDO_AURA_NAME_PREFERRED_SPELL_ID[tSpellName] or tSpellId;
						end
					end
				end
			end
		end
	end

	return;

end



do
	--
	local tType;
	local tFilter;
	local tExcludeFilter;
	local tTokens;
	local tNative;
	local tUpper;
	local tEmit;
	local tHasCategory;
	local tSeen = { };
	local tSlotIsMine;
	local tSlotIsOthers;
	local tEntryIsMine;
	local tEntryIsOthers;
	local tHasMixedSource;
	local tHasRaidPlayerDispellable;
	local tIsNegated;
	local tBase;
	function VUHDO_buildAuraGroupNativeFilterString(aGroup)

		if not aGroup then
			return "HELPFUL";
		end

		tType = aGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;
		tFilter = aGroup["resolvedFilter"] or aGroup["filter"];

		if tType == VUHDO_AURA_GROUP_TYPE_LIST then
			tNative = aGroup["isHarmful"] and "HARMFUL" or "HELPFUL";

			tSlotIsMine = nil;
			tSlotIsOthers = nil;
			tHasMixedSource = false;

			for _, tEntry in ipairs(aGroup["entries"] or sEmpty) do
				if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
					if tSlotIsMine == nil then
						tSlotIsMine = tEntry["mine"] ~= false;
						tSlotIsOthers = tEntry["others"] == true;
					else
						tEntryIsMine = tEntry["mine"] ~= false;
						tEntryIsOthers = tEntry["others"] == true;

						if tEntryIsMine ~= tSlotIsMine or tEntryIsOthers ~= tSlotIsOthers then
							tHasMixedSource = true;

							break;
						end
					end
				end
			end

			if not tHasMixedSource and tSlotIsMine ~= nil then
				if tSlotIsMine and not tSlotIsOthers then
					return tNative .. "|PLAYER";
				elseif tSlotIsOthers and not tSlotIsMine then
					return tNative .. "|!PLAYER";
				end
			end

			return tNative;
		end

		if not tFilter then
			return aGroup["isHarmful"] and "HARMFUL" or "HELPFUL";
		end

		tHasRaidPlayerDispellable = strfind(tFilter, "RAID_PLAYER_DISPELLABLE", 1, true) ~= nil;

		twipe(tSeen);
		tTokens = { strsplit("|", tFilter) };
		tNative = "";
		tHasCategory = false;

		for _, tToken in ipairs(tTokens) do
			tUpper = strupper(tToken);
			tIsNegated = strfind(tUpper, "!", 1, true) == 1;
			tBase = tIsNegated and strsub(tUpper, 2) or tUpper;

			if tBase == "NOT_CANCELABLE" then
				tEmit = "!CANCELABLE";
			elseif tHasRaidPlayerDispellable and tBase == "PLAYER" then
				tEmit = nil;
			elseif VUHDO_AURA_NATIVE_FILTER_TOKENS[tBase] then
				if tIsNegated and sNonNegatableFilterTokens[tBase] then
					tEmit = tBase;
				elseif tIsNegated then
					tEmit = "!" .. tBase;
				else
					tEmit = tBase;
				end
			else
				tEmit = nil;
			end

			if tEmit and not tSeen[tEmit] then
				tSeen[tEmit] = true;

				tNative = tNative == "" and tEmit or (tNative .. "|" .. tEmit);

				if tEmit == "HELPFUL" or tEmit == "HARMFUL" then
					tHasCategory = true;
				end
			end
		end

		if not tHasCategory then
			tNative = (aGroup["isHarmful"] and "HARMFUL" or "HELPFUL") .. (tNative == "" and "" or ("|" .. tNative));
		end

		tExcludeFilter = aGroup["excludeFilter"];

		if tExcludeFilter then
			tTokens = { strsplit("|", tExcludeFilter) };

			for _, tToken in ipairs(tTokens) do
				tUpper = strupper(tToken);
				tIsNegated = strfind(tUpper, "!", 1, true) == 1;
				tBase = tIsNegated and strsub(tUpper, 2) or tUpper;

				if tBase == "NOT_CANCELABLE" then
					tEmit = "CANCELABLE";
				elseif VUHDO_AURA_NATIVE_FILTER_TOKENS[tBase] then
					if tIsNegated then
						tEmit = tBase;
					else
						tEmit = "!" .. tBase;
					end
				else
					tEmit = nil;
				end

				if tEmit and not tSeen[tEmit] then
					tSeen[tEmit] = true;

					tNative = tNative .. "|" .. tEmit;
				end
			end
		end

		return tNative;

	end
end



--
local tType;
local tBouquetClass;
function VUHDO_isAuraGroupContainerExpressible(aGroup)

	if not aGroup or aGroup["enabled"] == false or aGroup["isInferred"] then
		return false;
	end

	tType = aGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

	if tType == VUHDO_AURA_GROUP_TYPE_FILTER then
		return (aGroup["resolvedFilter"] or aGroup["filter"]) ~= nil;
	end

	if aGroup["isHarmful"] then
		return false;
	end

	for _, tEntry in ipairs(aGroup["entries"] or sEmpty) do
		if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL and tEntry["value"] then
			if type(tEntry["value"]) == "number" then
				return true;
			end

			tSpellId = VUHDO_resolveAuraContainerSpellId(tEntry["value"]);

			if tSpellId then
				return true;
			end
		elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
			tBouquetClass = VUHDO_classifyBouquetRestrictedMode(tEntry["value"]);

			if tBouquetClass == VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER or tBouquetClass == VUHDO_BOUQUET_RESTRICTED_NON_AURA
				or tBouquetClass == VUHDO_BOUQUET_RESTRICTED_MIXED then
				return true;
			end
		end
	end

	return false;

end



--
local tCached;
local tFilterString;
local tCandidateFilters;
local tExpressible;
local tType;
local tSpellIds;
function VUHDO_getAuraGroupResolvedFilters(aGroup)

	if not aGroup then
		return nil;
	end

	tCached = sGroupResolvedFilterCache[aGroup];

	if tCached then
		return tCached;
	end

	tFilterString = VUHDO_buildAuraGroupNativeFilterString(aGroup);
	tCandidateFilters = VUHDO_resolveAuraGroupCandidateFilters(aGroup);
	tExpressible = VUHDO_isAuraGroupContainerExpressible(aGroup);

	tType = aGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

	if tType == VUHDO_AURA_GROUP_TYPE_LIST and (not tCandidateFilters or not tCandidateFilters["includeSpellIDs"]) then
		tSpellIds = nil;

		for _, tEntry in ipairs(aGroup["entries"] or sEmpty) do
			if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL and tEntry["value"] then
				tSpellIds = tSpellIds or { };

				VUHDO_addResolvedAuraContainerSpellIds(tSpellIds, tEntry["value"]);
			end
		end

		if tSpellIds and not next(tSpellIds) then
			tSpellIds = nil;
		end

		if tSpellIds then
			tCandidateFilters = tCandidateFilters or { };

			tCandidateFilters["includeSpellIDs"] = tSpellIds;
		end
	end

	tCached = {
		["filterString"] = tFilterString,
		["candidateFilters"] = tCandidateFilters,
		["expressible"] = tExpressible,
	};

	sGroupResolvedFilterCache[aGroup] = tCached;

	return tCached;

end



--
function VUHDO_invalidateAuraGroupFilterCache()

	twipe(sGroupResolvedFilterCache);

	sGlobalIgnoreSpellIds = nil;

	return;

end



--
local tCandidate;
local tFilter;
local tDispelTypes;
function VUHDO_resolveAuraGroupCandidateFilters(aGroup)

	if not aGroup then
		return nil;
	end

	tCandidate = VUHDO_resolveGroupCandidateFilters(aGroup, nil);

	if aGroup["allDispel"] then
		tCandidate = tCandidate or { };

		tCandidate["includeDispelTypes"] = {
			["Magic"] = true,
			["Curse"] = true,
			["Disease"] = true,
			["Poison"] = true,
			["Bleed"] = true,
		};
	end

	tFilter = aGroup["resolvedFilter"] or aGroup["filter"];

	if tFilter and strfind(tFilter, "RAID_PLAYER_DISPELLABLE", 1, true) then
		tCandidate = tCandidate or { };

		if aGroup["isHarmful"] then
			tDispelTypes = VUHDO_getPlayerDispelTypeNames();
		else
			tDispelTypes = VUHDO_getPlayerPurgeDispelTypeNames();
		end

		if next(tDispelTypes) ~= nil then
			tCandidate["includeDispelTypes"] = tDispelTypes;
		end
	end

	return tCandidate;

end



--
function VUHDO_rebuildDispelTypeNameMaps()

	twipe(sAllDispelTypeNames);
	twipe(sPlayerDispelTypeNames);
	twipe(sPlayerPurgeDispelTypeNames);

	for tDispelName, _ in pairs(VUHDO_DEBUFF_TYPES or sEmpty) do
		sAllDispelTypeNames[tDispelName] = true;
	end

	for tDebuffType, _ in pairs(VUHDO_PLAYER_DISPEL_ABILITIES or sEmpty) do
		for tDispelName, tTypeNum in pairs(VUHDO_DEBUFF_TYPES or sEmpty) do
			if tTypeNum == tDebuffType then
				sPlayerDispelTypeNames[tDispelName] = true;
			end
		end
	end

	for tDebuffType, _ in pairs(VUHDO_PLAYER_PURGE_ABILITIES or sEmpty) do
		for tDispelName, tTypeNum in pairs(VUHDO_DEBUFF_TYPES or sEmpty) do
			if tTypeNum == tDebuffType then
				sPlayerPurgeDispelTypeNames[tDispelName] = true;
			end
		end
	end

	VUHDO_rebuildDerivedDispelTypeNameMaps();

	return;

end



--
local tBackgroundDispelTypeNames;
local tGlowDispelTypeNames;
function VUHDO_rebuildDerivedDispelTypeNameMaps()

	twipe(sAllDispelBarColorTypeNames);
	twipe(sPlayerDispelBarColorTypeNames);
	twipe(sPlayerPurgeBarColorTypeNames);
	twipe(sAllDispelGlowTypeNames);
	twipe(sPlayerDispelGlowTypeNames);
	twipe(sPlayerPurgeGlowTypeNames);

	tBackgroundDispelTypeNames = VUHDO_getBackgroundDispelTypeNames();
	tGlowDispelTypeNames = VUHDO_getGlowDispelTypeNames();

	for tDispelName, _ in pairs(sAllDispelTypeNames) do
		if tBackgroundDispelTypeNames[tDispelName] then
			sAllDispelBarColorTypeNames[tDispelName] = true;
		end

		if tGlowDispelTypeNames[tDispelName] then
			sAllDispelGlowTypeNames[tDispelName] = true;
		end
	end

	for tDispelName, _ in pairs(sPlayerDispelTypeNames) do
		if tBackgroundDispelTypeNames[tDispelName] then
			sPlayerDispelBarColorTypeNames[tDispelName] = true;
		end

		if tGlowDispelTypeNames[tDispelName] then
			sPlayerDispelGlowTypeNames[tDispelName] = true;
		end
	end

	for tDispelName, _ in pairs(sPlayerPurgeDispelTypeNames) do
		if tBackgroundDispelTypeNames[tDispelName] then
			sPlayerPurgeBarColorTypeNames[tDispelName] = true;
		end

		if tGlowDispelTypeNames[tDispelName] then
			sPlayerPurgeGlowTypeNames[tDispelName] = true;
		end
	end

	return;

end



--
function VUHDO_getAllDispelTypeNames()

	return sAllDispelTypeNames;

end



--
function VUHDO_getPlayerPurgeDispelTypeNames()

	return sPlayerPurgeDispelTypeNames;

end



--
function VUHDO_getPlayerDispelTypeNames()

	return sPlayerDispelTypeNames;

end



--
function VUHDO_getAllDispelBarColorTypeNames()

	return sAllDispelBarColorTypeNames;

end



--
function VUHDO_getPlayerDispelBarColorTypeNames()

	return sPlayerDispelBarColorTypeNames;

end



--
function VUHDO_getPlayerPurgeBarColorTypeNames()

	return sPlayerPurgeBarColorTypeNames;

end



--
function VUHDO_getAllDispelGlowTypeNames()

	return sAllDispelGlowTypeNames;

end



--
function VUHDO_getPlayerDispelGlowTypeNames()

	return sPlayerDispelGlowTypeNames;

end



--
function VUHDO_getPlayerPurgeGlowTypeNames()

	return sPlayerPurgeGlowTypeNames;

end



--
local tResult;
function VUHDO_copyOverlayCandidateFilters(aCandidateFilters, anIncludeDispelTypes)

	tResult = nil;

	if aCandidateFilters then
		tResult = { };

		for tKey, tValue in pairs(aCandidateFilters) do
			tResult[tKey] = tValue;
		end
	end

	if anIncludeDispelTypes then
		tResult = tResult or { };

		tResult["includeDispelTypes"] = anIncludeDispelTypes;
	end

	return tResult;

end



--
local tGroup;
function VUHDO_resolveAuraContainerFilter(anAnchorConfig)

	if not anAnchorConfig then
		return nil;
	end

	tGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

	if not tGroup then
		return nil;
	end

	return VUHDO_buildAuraGroupNativeFilterString(tGroup);

end



--
local tNative;
local tSlotIsMine;
local tSlotIsOthers;
function VUHDO_resolveListEntrySlotFilter(aGroup, anEntry)

	if not aGroup then
		return "HELPFUL";
	end

	tNative = aGroup["isHarmful"] and "HARMFUL" or "HELPFUL";

	if not anEntry or anEntry["entryType"] ~= VUHDO_AURA_LIST_ENTRY_SPELL then
		return tNative;
	end

	tSlotIsMine = anEntry["mine"] ~= false;
	tSlotIsOthers = anEntry["others"] == true;

	if tSlotIsMine and not tSlotIsOthers then
		return tNative .. "|PLAYER";
	elseif tSlotIsOthers and not tSlotIsMine then
		return tNative .. "|!PLAYER";
	end

	return tNative;

end



--
local tResolvedSpellId;
function VUHDO_resolveAuraContainerSpellId(aValue)

	if type(aValue) == "number" then
		return aValue;
	end

	if type(aValue) ~= "string" then
		return nil;
	end

	tResolvedSpellId = tonumber(aValue) or VUHDO_AURA_NAME_PREFERRED_SPELL_ID[aValue] or VUHDO_SPELL_NAME_TO_ID[aValue] or GetSpellIDForSpellIdentifier(aValue);

	return tResolvedSpellId;

end



--
local tPreferredNumVal;
function VUHDO_resolveAuraContainerPreferredSpellId(aValue)

	if type(aValue) == "number" then
		return aValue;
	end

	if type(aValue) ~= "string" then
		return nil;
	end

	tPreferredNumVal = tonumber(aValue);

	if tPreferredNumVal then
		return tPreferredNumVal;
	end

	if VUHDO_AURA_NAME_PREFERRED_SPELL_ID[aValue] then
		return VUHDO_AURA_NAME_PREFERRED_SPELL_ID[aValue];
	end

	return VUHDO_resolveAuraContainerSpellId(aValue);

end



--
local tNumVal;
local tMappedIds;
local tResolvedSpellIds;
local tResolveSpellId;
function VUHDO_addResolvedAuraContainerSpellIds(aDest, aValue)

	if not aDest or aValue == nil then
		return;
	end

	if type(aValue) == "number" then
		aDest[aValue] = true;

		return;
	end

	if type(aValue) ~= "string" then
		return;
	end

	tNumVal = tonumber(aValue);

	if tNumVal then
		aDest[tNumVal] = true;

		return;
	end

	tResolvedSpellIds = nil;
	tNameIds = VUHDO_AURA_NAME_TO_SPELL_IDS[aValue];

	if tNameIds then
		for tSpellId, _ in pairs(tNameIds) do
			aDest[tSpellId] = true;
			tResolvedSpellIds = tResolvedSpellIds or { };
			tResolvedSpellIds[tSpellId] = true;
		end
	else
		tResolveSpellId = VUHDO_SPELL_NAME_TO_ID[aValue];

		if tResolveSpellId then
			aDest[tResolveSpellId] = true;
			tResolvedSpellIds = tResolvedSpellIds or { };
			tResolvedSpellIds[tResolveSpellId] = true;
		else
			tResolveSpellId = GetSpellIDForSpellIdentifier(aValue);

			if tResolveSpellId then
				aDest[tResolveSpellId] = true;
				tResolvedSpellIds = tResolvedSpellIds or { };
				tResolvedSpellIds[tResolveSpellId] = true;
			end
		end
	end

	if tResolvedSpellIds then
		for tResolvedSpellId, _ in pairs(tResolvedSpellIds) do
			tMappedIds = VUHDO_AURA_CONTAINER_MAPPED_SPELL_IDS[tResolvedSpellId];

			if tMappedIds then
				for tMappedCnt = 1, #tMappedIds do
					aDest[tMappedIds[tMappedCnt]] = true;
				end
			end
		end
	end

	return;

end



--
local tResult;
function VUHDO_resolveGroupExcludeSpellIDs(aGroup)

	if not aGroup then
		return nil;
	end

	if not sGlobalIgnoreSpellIds then
		sGlobalIgnoreSpellIds = { };

		-- FIXME: 12.1 only supports spell ID ignore list entries
		for tKey, _ in pairs(VUHDO_AURA_IGNORE_LIST or sEmpty) do
			VUHDO_addResolvedAuraContainerSpellIds(sGlobalIgnoreSpellIds, tKey);
		end
	end

	tResult = nil;

	for tNum, _ in pairs(sGlobalIgnoreSpellIds) do
		tResult = tResult or { };

		tResult[tNum] = true;
	end

	for tKey, _ in pairs(aGroup["ignoreList"] or sEmpty) do
		tResult = tResult or { };

		VUHDO_addResolvedAuraContainerSpellIds(tResult, tKey);
	end

	return tResult;

end



do
	--
	local tPositionTable;
	local tSlotPos;
	local tLayerIndex;
	local tBaseAnchor;
	local tGrowthDir;
	local tWrapDir;
	local tSpacing;
	local tMaxCols;
	local tMaxRows;
	local tAnchorCapacity;
	local tSize;
	local tCol;
	local tRow;
	local tGrowX;
	local tGrowY;
	local tWrapX;
	local tWrapY;
	local tGrowthXOff;
	local tGrowthYOff;
	local tXOff;
	local tYOff;
	local tNumBasePositions;
	function VUHDO_resolveFixedAuraSlotPlacement(aRadioValue, aSlotIndex, aBarWidth, aBarHeight, anAnchorConfig, anIconSize)

		tNumBasePositions = 9;

		tPositionTable = (30 == aRadioValue) and VUHDO_AURA_FIXED_STRAIGHT_POSITIONS or VUHDO_AURA_FIXED_DIAGONAL_POSITIONS;
		tBaseAnchor = ((aSlotIndex - 1) % tNumBasePositions) + 1;
		tLayerIndex = floor((aSlotIndex - 1) / tNumBasePositions);

		tMaxCols = anAnchorConfig["maxColumns"] or 5;
		tMaxRows = anAnchorConfig["maxRows"] or 1;
		tAnchorCapacity = tMaxCols * tMaxRows;

		if tLayerIndex >= tAnchorCapacity then
			return nil;
		end

		tSlotPos = tPositionTable[tBaseAnchor];

		if not tSlotPos then
			return nil;
		end

		tXOff = (tSlotPos["xPercent"] or 0) * aBarWidth;
		tYOff = (tSlotPos["yPercent"] or 0) * aBarHeight;

		tSize = anIconSize or aBarWidth;

		if tLayerIndex > 0 then
			tGrowthDir = VUHDO_AURA_GROWTH_OFFSETS[anAnchorConfig["growthDir"]] or VUHDO_AURA_GROWTH_OFFSETS["RIGHT"];
			tWrapDir = VUHDO_AURA_GROWTH_OFFSETS[anAnchorConfig["wrapDir"]] or VUHDO_AURA_GROWTH_OFFSETS["DOWN"];

			tSpacing = anAnchorConfig["spacing"] or 2;
			tMaxCols = anAnchorConfig["maxColumns"] or 5;

			tCol = tLayerIndex % tMaxCols;
			tRow = floor(tLayerIndex / tMaxCols);

			tGrowX = tGrowthDir[1];
			tGrowY = tGrowthDir[2];
			tWrapX = tWrapDir[1];
			tWrapY = tWrapDir[2];

			tGrowthXOff = (tCol * (tSize + tSpacing) * tGrowX) + (tRow * (tSize + tSpacing) * tWrapX);
			tGrowthYOff = (tCol * (tSize + tSpacing) * tGrowY) + (tRow * (tSize + tSpacing) * tWrapY);

			tXOff = tXOff + tGrowthXOff;
			tYOff = tYOff + tGrowthYOff;
		end

		return tSlotPos["anchor"], tSlotPos["relPoint"], tXOff, tYOff;

	end
end



--
local tBouquetMode;
function VUHDO_isListCollapseEligible(aGroup, aUseFixedSlots, anIsFixedLayout)

	if not aGroup or aUseFixedSlots or anIsFixedLayout then
		return false;
	end

	for _, tEntry in ipairs(aGroup["entries"] or sEmpty) do
		if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL or tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
		elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
			tBouquetMode = VUHDO_classifyBouquetRestrictedMode(tEntry["value"]);

			if tBouquetMode ~= VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER then
				return false;
			end
		else
			return false;
		end
	end

	return true;

end



do
	--
	local function VUHDO_applyListSlotLayoutFlags(aSlotTemplate, anEntryIndex)

		aSlotTemplate["entryIndex"] = anEntryIndex;

		return aSlotTemplate;

	end



	--
	local tIncludeSpellIds;
	local tSlotCandidateFilters;
	local tSlotButtonSetup;
	local tSlotEntryDurationMode;
	local tSlotEntryTimerThreshold;
	local tSlotEntryShowTimer;
	local tSlotEntryShowStacks;
	local tSlotEntryShowClock;
	local tAnchorDurationMode;
	local tAnchorTimerThreshold;
	local tAnchorShowTimer;
	local tNeedsSlotButtonCopy;
	local tResolvedShowTimer;
	local tResolvedShowStacks;
	local tResolvedShowClock;
	local tEffectiveDurationMode;
	local tEffectiveTimerThreshold;
	local tColorCopy;
	function VUHDO_buildListEntrySlotButtonSetup(aGroup, anEntry, aAnchorButtonSetup, anIsBar, anExcludeSpellIds)

		tIncludeSpellIds = { };

		VUHDO_addResolvedAuraContainerSpellIds(tIncludeSpellIds, anEntry["value"]);

		if not next(tIncludeSpellIds) then
			return nil, nil;
		end

		tSlotCandidateFilters = {
			["includeSpellIDs"] = tIncludeSpellIds,
		};

		if anExcludeSpellIds then
			tSlotCandidateFilters["excludeSpellIDs"] = anExcludeSpellIds;
		end

		tAnchorDurationMode = aAnchorButtonSetup["durationMode"] or VUHDO_SPELL_DURATION_MODE_THRESHOLD;
		tAnchorTimerThreshold = aAnchorButtonSetup["timerThreshold"] or 9.99;
		tAnchorShowTimer = aAnchorButtonSetup["durationText"];

		tSlotEntryDurationMode = anEntry["durationMode"] or VUHDO_SPELL_DURATION_MODE_THRESHOLD;
		tSlotEntryTimerThreshold = anEntry["timerThreshold"] or 9.99;

		tSlotEntryShowTimer = VUHDO_getTriStateBool(anEntry, "showTimer", nil);
		tSlotEntryShowStacks = VUHDO_getTriStateBool(anEntry, "showStacks", nil);
		tSlotEntryShowClock = VUHDO_getTriStateBool(anEntry, "showClock", nil);

		tNeedsSlotButtonCopy = tSlotEntryDurationMode ~= tAnchorDurationMode
			or tSlotEntryTimerThreshold ~= tAnchorTimerThreshold
			or (tSlotEntryShowTimer ~= nil and tSlotEntryShowTimer ~= tAnchorShowTimer)
			or (tSlotEntryShowStacks ~= nil and tSlotEntryShowStacks ~= aAnchorButtonSetup["applicationCount"])
			or (tSlotEntryShowClock ~= nil and tSlotEntryShowClock ~= aAnchorButtonSetup["durationCooldown"])
			or (anEntry["colorIcon"] and anEntry["colorIconColor"])
			or anEntry["glowIcon"] == true;

		if tNeedsSlotButtonCopy then
			tSlotButtonSetup = { };

			for tKey, tValue in pairs(aAnchorButtonSetup) do
				tSlotButtonSetup[tKey] = tValue;
			end

			tSlotButtonSetup["durationMode"] = tSlotEntryDurationMode;
			tSlotButtonSetup["timerThreshold"] = tSlotEntryTimerThreshold;

			if tSlotEntryShowTimer ~= nil then
				tResolvedShowTimer = tSlotEntryShowTimer;
			else
				tResolvedShowTimer = tAnchorShowTimer;
			end

			tSlotButtonSetup["durationText"] = tResolvedShowTimer;

			if tSlotEntryShowStacks ~= nil then
				tResolvedShowStacks = tSlotEntryShowStacks;
			else
				tResolvedShowStacks = aAnchorButtonSetup["applicationCount"];
			end

			tSlotButtonSetup["applicationCount"] = tResolvedShowStacks;

			if tSlotEntryShowClock ~= nil then
				tResolvedShowClock = tSlotEntryShowClock;
			else
				tResolvedShowClock = aAnchorButtonSetup["durationCooldown"];
			end

			tSlotButtonSetup["durationCooldown"] = tResolvedShowClock;

			if tResolvedShowTimer then
				tEffectiveDurationMode = tSlotEntryDurationMode;
				tEffectiveTimerThreshold = tSlotEntryTimerThreshold;

				tSlotButtonSetup["durationTextOptions"] = {
					["textFormatter"] = VUHDO_getAuraTimerFormatter(tEffectiveDurationMode, tEffectiveTimerThreshold),
					["textColor"] = {
						["curve"] = VUHDO_getAuraTimerColorCurve(tEffectiveDurationMode, tEffectiveTimerThreshold),
						["property"] = Enum.DurationTextBindingProperty.RemainingDuration,
					},
				};
			else
				tSlotButtonSetup["durationTextOptions"] = nil;
			end
		else
			tSlotButtonSetup = aAnchorButtonSetup;
		end

		if anEntry["colorIcon"] and anEntry["colorIconColor"] then
			tColorCopy = VUHDO_deepCopyTable(anEntry["colorIconColor"]);

			if anIsBar then
				tSlotButtonSetup["barColor"] = tColorCopy;

				if tSlotButtonSetup["staticIcon"] then
					tSlotButtonSetup["staticColor"] = tColorCopy;
				elseif not tSlotButtonSetup["hideIcon"] then
					tSlotButtonSetup["iconColor"] = tColorCopy;
				end
			elseif tSlotButtonSetup["staticIcon"] then
				tSlotButtonSetup["staticColor"] = tColorCopy;
			else
				tSlotButtonSetup["iconColor"] = tColorCopy;
			end
		end

		if anEntry["glowIcon"] == true then
			tSlotButtonSetup["glowIcon"] = true;

			tSlotButtonSetup["glowColor"] = anEntry["glowIconColor"];
			tSlotButtonSetup["glowStyle"] = anEntry["glowIconStyle"] or VUHDO_DEFAULT_AURA_GLOW_STYLE;
		end

		return tSlotButtonSetup, tSlotCandidateFilters;

	end



	--
	function VUHDO_applyBouquetSlotButtonSetup(aBouquetSlotTemplate, anAnchorConfig, aPixelWidth, aPixelHeight, aAnchorButtonSetup, anIsBar)

		aBouquetSlotTemplate["buttonSetup"]["width"] = aPixelWidth;
		aBouquetSlotTemplate["buttonSetup"]["height"] = aPixelHeight;
		aBouquetSlotTemplate["buttonSetup"]["textSize"] = aAnchorButtonSetup["textSize"];
		aBouquetSlotTemplate["buttonSetup"]["textConfig"] = aAnchorButtonSetup["textConfig"];
		aBouquetSlotTemplate["buttonSetup"]["durationText"] = aAnchorButtonSetup["durationText"];
		aBouquetSlotTemplate["buttonSetup"]["durationCooldown"] = aAnchorButtonSetup["durationCooldown"];
		aBouquetSlotTemplate["buttonSetup"]["applicationCount"] = aAnchorButtonSetup["applicationCount"];
		aBouquetSlotTemplate["buttonSetup"]["mouseMotion"] = aAnchorButtonSetup["mouseMotion"];
		aBouquetSlotTemplate["buttonSetup"]["disableMouse"] = aAnchorButtonSetup["disableMouse"];
		aBouquetSlotTemplate["buttonSetup"]["durationTextOptions"] = aAnchorButtonSetup["durationTextOptions"];

		if anIsBar then
			VUHDO_applyBarButtonSetupFields(aBouquetSlotTemplate["buttonSetup"], anAnchorConfig);

			aBouquetSlotTemplate["buttonSetup"]["barVertical"] = aAnchorButtonSetup["barVertical"];
			aBouquetSlotTemplate["buttonSetup"]["barTurnAxis"] = aAnchorButtonSetup["barTurnAxis"];
			aBouquetSlotTemplate["buttonSetup"]["iconType"] = aAnchorButtonSetup["iconType"];
			aBouquetSlotTemplate["buttonSetup"]["barSegmentWidth"] = aAnchorButtonSetup["barSegmentWidth"];
			aBouquetSlotTemplate["buttonSetup"]["barSegmentHeight"] = aAnchorButtonSetup["barSegmentHeight"];
			aBouquetSlotTemplate["buttonSetup"]["iconTextSize"] = aAnchorButtonSetup["iconTextSize"];
			aBouquetSlotTemplate["buttonSetup"]["barColorMode"] = aAnchorButtonSetup["barColorMode"];
			aBouquetSlotTemplate["buttonSetup"]["barTexture"] = aAnchorButtonSetup["barTexture"];

			if aBouquetSlotTemplate["buttonSetup"]["staticColor"] then
				aBouquetSlotTemplate["buttonSetup"]["barColor"] = aBouquetSlotTemplate["buttonSetup"]["staticColor"];
			else
				aBouquetSlotTemplate["buttonSetup"]["barColor"] = aAnchorButtonSetup["barColor"];
			end
		end

		return;

	end



	--
	local tGroups;
	local tGroupTemplate;
	local tGroupLayout;
	local tPendingSpacer;
	local tExcludeIds;
	local tSlotButtonSetup;
	local tSlotCandidateFilters;
	local tBouquetSlotTemplate;
	local tLayoutAxis;
	local tSpacerSize;
	function VUHDO_buildListAnchorEntryGroups(aGroup, anAnchorConfig, aPixelWidth, aPixelHeight, aSpacing, aMaxFrameCount, aTemplateName, aAnchorButtonSetup, anIsBar)

		tGroups = { };
		tPendingSpacer = 0;

		if not aGroup then
			return tGroups;
		end

		tLayoutAxis, _, _ = VUHDO_resolveAnchorFlowDirections(anAnchorConfig["growthDir"] or "RIGHT", anAnchorConfig["wrapDir"] or "DOWN", anAnchorConfig["maxColumns"] or 5);

		tExcludeIds = VUHDO_resolveGroupExcludeSpellIDs(aGroup);

		for tEntryIndex, tEntry in ipairs(aGroup["entries"] or sEmpty) do
			if tEntryIndex > aMaxFrameCount then
				break;
			end

			if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
				if AnchorUtil.FlowLayoutAxis.Vertical == tLayoutAxis then
					tSpacerSize = aPixelHeight + aSpacing;
				else
					tSpacerSize = aPixelWidth + aSpacing;
				end

				tPendingSpacer = tPendingSpacer + tSpacerSize;
			elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
				tSlotButtonSetup, tSlotCandidateFilters = VUHDO_buildListEntrySlotButtonSetup(aGroup, tEntry, aAnchorButtonSetup, anIsBar, tExcludeIds);

				if tSlotButtonSetup then
					tGroupLayout = {
						["elementWidth"] = aPixelWidth,
						["elementHeight"] = aPixelHeight,
						["elementSpacing"] = aSpacing,
						["lineSpacing"] = aSpacing,
						["layoutIndex"] = tEntryIndex,
					};

					if tPendingSpacer > 0 then
						tGroupLayout["groupSpacing"] = tPendingSpacer;

						tPendingSpacer = 0;
					end

					tGroupTemplate = {
						["key"] = "entry" .. tEntryIndex,
						["filterString"] = VUHDO_resolveListEntrySlotFilter(aGroup, tEntry),
						["candidateFilters"] = tSlotCandidateFilters,
						["isHarmful"] = aGroup["isHarmful"] == true,
						["maxFrameCount"] = 1,
						["templateName"] = aTemplateName,
						["layout"] = tGroupLayout,
						["buttonSetup"] = tSlotButtonSetup,
					};

					tinsert(tGroups, tGroupTemplate);
				end
			elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET and VUHDO_classifyBouquetRestrictedMode(tEntry["value"]) == VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER then
				tBouquetSlotTemplate = VUHDO_buildListEntryContainerGroupTemplate(tEntry["value"]);

				if tBouquetSlotTemplate then
					VUHDO_applyBouquetSlotButtonSetup(tBouquetSlotTemplate, anAnchorConfig, aPixelWidth, aPixelHeight, aAnchorButtonSetup, anIsBar);

					tGroupLayout = {
						["elementWidth"] = aPixelWidth,
						["elementHeight"] = aPixelHeight,
						["elementSpacing"] = aSpacing,
						["lineSpacing"] = aSpacing,
						["layoutIndex"] = tEntryIndex,
					};

					if tPendingSpacer > 0 then
						tGroupLayout["groupSpacing"] = tPendingSpacer;

						tPendingSpacer = 0;
					end

					tGroupTemplate = {
						["key"] = "entry" .. tEntryIndex,
						["filterString"] = tBouquetSlotTemplate["filterString"],
						["candidateFilters"] = tBouquetSlotTemplate["candidateFilters"],
						["isHarmful"] = tBouquetSlotTemplate["isHarmful"] == true,
						["maxFrameCount"] = 1,
						["templateName"] = aTemplateName,
						["layout"] = tGroupLayout,
						["buttonSetup"] = tBouquetSlotTemplate["buttonSetup"],
					};

					tinsert(tGroups, tGroupTemplate);
				end
			end
		end

		return tGroups;

	end



	--
	local tSlots;
	local tExcludeIds;
	local tSlotButtonSetup;
	local tSlotCandidateFilters;
	local tSlotX;
	local tSlotY;
	local tSlotTemplate;
	local tBouquetSlotTemplate;
	local tMixedSlotTemplates;
	local tFixedSlotAnchor;
	local tFixedSlotRelPoint;
	local tCol;
	local tRow;
	local tIsSlotDropped;
	function VUHDO_buildListAnchorSlots(aGroup, anAnchorConfig, aPixelWidth, aPixelHeight, aSpacing, aMaxCols, aMaxFrameCount, aTemplateName, aAnchorButtonSetup, anIsBar, aGrowthDir, aWrapDir, anIsFixedLayout, aFixedRadioValue, aBarWidth, aBarHeight)

		tSlots = { };

		if not aGroup then
			return tSlots;
		end

		tExcludeIds = VUHDO_resolveGroupExcludeSpellIDs(aGroup);

		for tEntryIndex, tEntry in ipairs(aGroup["entries"] or sEmpty) do
			if tEntryIndex > aMaxFrameCount then
				break;
			end

			tIsSlotDropped = false;

			if anIsFixedLayout then
				tFixedSlotAnchor, tFixedSlotRelPoint, tSlotX, tSlotY = VUHDO_resolveFixedAuraSlotPlacement(aFixedRadioValue, tEntryIndex, aBarWidth, aBarHeight, anAnchorConfig, aPixelWidth);

				if not tFixedSlotAnchor then
					tIsSlotDropped = true;
				end
			else
				tCol = (tEntryIndex - 1) % aMaxCols;
				tRow = floor((tEntryIndex - 1) / aMaxCols);
				tSlotX = tCol * (aPixelWidth + aSpacing) * aGrowthDir[1] + tRow * (aPixelWidth + aSpacing) * aWrapDir[1];
				tSlotY = tCol * (aPixelHeight + aSpacing) * aGrowthDir[2] + tRow * (aPixelHeight + aSpacing) * aWrapDir[2];
			end

			if not tIsSlotDropped then
				if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
					tSlotButtonSetup, tSlotCandidateFilters = VUHDO_buildListEntrySlotButtonSetup(aGroup, tEntry, aAnchorButtonSetup, anIsBar, tExcludeIds);

					if tSlotButtonSetup then
						tSlotTemplate = {
							["key"] = "slot" .. tEntryIndex,
							["filterString"] = VUHDO_resolveListEntrySlotFilter(aGroup, tEntry),
							["candidateFilters"] = tSlotCandidateFilters,
							["isHarmful"] = aGroup["isHarmful"] == true,
							["templateName"] = aTemplateName,
							["buttonSetup"] = tSlotButtonSetup,
							["x"] = tSlotX,
							["y"] = tSlotY,
							["width"] = aPixelWidth,
							["height"] = aPixelHeight,
						};

						if anIsFixedLayout and tFixedSlotAnchor then
							tSlotTemplate["anchor"] = tFixedSlotAnchor;
							tSlotTemplate["relPoint"] = tFixedSlotRelPoint;
						end

						VUHDO_applyListSlotLayoutFlags(tSlotTemplate, tEntryIndex);

						tinsert(tSlots, tSlotTemplate);
					end
				elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET and VUHDO_classifyBouquetRestrictedMode(tEntry["value"]) == VUHDO_BOUQUET_RESTRICTED_MIXED then
					tMixedSlotTemplates = VUHDO_buildMixedBouquetListSlotTemplates(tEntry["value"], tEntryIndex, tSlotX, tSlotY, aPixelWidth, aPixelHeight, aTemplateName, aAnchorButtonSetup);

					if anIsFixedLayout and tFixedSlotAnchor then
						for tMixedSlotCnt = 1, #tMixedSlotTemplates do
							tMixedSlotTemplates[tMixedSlotCnt]["anchor"] = tFixedSlotAnchor;
							tMixedSlotTemplates[tMixedSlotCnt]["relPoint"] = tFixedSlotRelPoint;
						end
					end

					for tMixedSlotCnt = 1, #tMixedSlotTemplates do
						VUHDO_applyListSlotLayoutFlags(tMixedSlotTemplates[tMixedSlotCnt], tEntryIndex);

						tinsert(tSlots, tMixedSlotTemplates[tMixedSlotCnt]);
					end
				elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET and VUHDO_classifyBouquetRestrictedMode(tEntry["value"]) == VUHDO_BOUQUET_RESTRICTED_NON_AURA then
					tSlotTemplate = {
						["key"] = "slot" .. tEntryIndex,
						["isStaticBouquetSlot"] = true,
						["bouquetName"] = tEntry["value"],
						["entryIndex"] = tEntryIndex,
						["x"] = tSlotX,
						["y"] = tSlotY,
						["width"] = aPixelWidth,
						["height"] = aPixelHeight,
						["buttonSetup"] = aAnchorButtonSetup,
					};

					if anIsFixedLayout and tFixedSlotAnchor then
						tSlotTemplate["anchor"] = tFixedSlotAnchor;
						tSlotTemplate["relPoint"] = tFixedSlotRelPoint;
					end

					VUHDO_applyListSlotLayoutFlags(tSlotTemplate, tEntryIndex);

					tinsert(tSlots, tSlotTemplate);
				elseif tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET and VUHDO_classifyBouquetRestrictedMode(tEntry["value"]) == VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER then
					tBouquetSlotTemplate = VUHDO_buildListEntryContainerGroupTemplate(tEntry["value"]);

					if tBouquetSlotTemplate then
						VUHDO_applyBouquetSlotButtonSetup(tBouquetSlotTemplate, anAnchorConfig, aPixelWidth, aPixelHeight, aAnchorButtonSetup, anIsBar);

						tSlotTemplate = {
							["key"] = "slot" .. tEntryIndex,
							["filterString"] = tBouquetSlotTemplate["filterString"],
							["candidateFilters"] = tBouquetSlotTemplate["candidateFilters"],
							["isHarmful"] = tBouquetSlotTemplate["isHarmful"] == true,
							["templateName"] = aTemplateName,
							["buttonSetup"] = tBouquetSlotTemplate["buttonSetup"],
							["x"] = tSlotX,
							["y"] = tSlotY,
							["width"] = aPixelWidth,
							["height"] = aPixelHeight,
						};

						if anIsFixedLayout and tFixedSlotAnchor then
							tSlotTemplate["anchor"] = tFixedSlotAnchor;
							tSlotTemplate["relPoint"] = tFixedSlotRelPoint;
						end

						VUHDO_applyListSlotLayoutFlags(tSlotTemplate, tEntryIndex);

						tinsert(tSlots, tSlotTemplate);
					end
				end
			end
		end

		return tSlots;

	end
end



--
local tBarWidth;
local tBarHeight;
local tIconSize;
local tPixelWidth;
local tPixelHeight;
local tIsBar;
local tTemplateName;
function VUHDO_resolveAnchorAuraPixelDimensions(aButton, anAnchorConfig)

	tIsBar = anAnchorConfig["style"] == "bars";
	tTemplateName = tIsBar and VUHDO_AURA_BUTTON_BAR_TEMPLATE or VUHDO_AURA_BUTTON_ICON_TEMPLATE;

	if tIsBar then
		if anAnchorConfig["barVertical"] then
			tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
			tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);
		else
			tBarWidth = VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig);
			tBarHeight = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);
		end

		if (anAnchorConfig["iconType"] or 1) ~= 5 then
			if anAnchorConfig["barVertical"] then
				tIconSize = tBarWidth;

				tPixelWidth = tBarWidth;
				tPixelHeight = tIconSize + tBarHeight;
			else
				tIconSize = tBarHeight;
				tPixelWidth = tIconSize + tBarWidth;
				tPixelHeight = tBarHeight;
			end
		else
			tPixelWidth = tBarWidth;
			tPixelHeight = tBarHeight;
		end
	else
		tPixelWidth = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);
		tPixelHeight = tPixelWidth;

		tBarWidth = nil;
		tBarHeight = nil;
	end

	return tPixelWidth, tPixelHeight, tBarWidth, tBarHeight, tIsBar, tTemplateName;

end



--
local tGroup;
local tType;
local tFilterString;
local tCandidateFilters;
local tSortMethod;
local tSortDir;
local tContainerLayout;
local tGroupLayout;
local tAnchorPoint;
local tGroupTemplate;
local tGroups;
local tSlots;
local tMaxFrameCount;
local tPanelNum;
local tHealthBarWidthPx;
local tHealthBarHeightPx;
local tOffsetX;
local tOffsetY;
local tCachedEntry;
local tCachedTemplate;
local tAnchorButtonSetup;
local tRelativePoint;
local tStaticOffsetX;
local tStaticOffsetY;
local tSpacing;
local tMaxCols;
local tGrowthDir;
local tWrapDir;
local tColorMode;
local tBarColors;
local tPixelWidth;
local tPixelHeight;
local tBarWidth;
local tBarHeight;
local tIsBar;
local tTemplateName;
local tIsFixedLayout;
local tFixedRadioValue;
local tUseFixedSlots;
function VUHDO_buildAnchorContainerTemplate(aButton, anAnchorIndex, anAnchorConfig)

	tGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

	if not tGroup then
		return nil;
	end

	tPanelNum = VUHDO_BUTTON_CACHE[aButton];

	if tPanelNum then
		tCachedEntry = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE[tPanelNum] and VUHDO_AURA_CONTAINER_TEMPLATE_CACHE[tPanelNum][anAnchorIndex];

		if tCachedEntry and tCachedEntry["version"] == VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION then
			tCachedTemplate = tCachedEntry["template"];

			if not tCachedEntry["instanceTemplate"] then
				tCachedEntry["instanceTemplate"] = {
					["parent"] = aButton,
					["anchor"] = tCachedTemplate["anchor"],
					["containerLayout"] = tCachedTemplate["containerLayout"],
					["groups"] = tCachedTemplate["groups"],
					["slots"] = tCachedTemplate["slots"],
					["buildSignature"] = tCachedTemplate["buildSignature"],
					["staticSlots"] = tCachedTemplate["staticSlots"],
					["usesDispelTextures"] = tCachedTemplate["usesDispelTextures"],
					["panelNum"] = tPanelNum,
					["anchorIndex"] = anAnchorIndex,
				};
			end

			tCachedEntry["instanceTemplate"]["parent"] = aButton;

			return tCachedEntry["instanceTemplate"];
		end
	end

	tFilterString = VUHDO_resolveAuraContainerFilter(anAnchorConfig);
	tCandidateFilters = VUHDO_resolveGroupCandidateFilters(tGroup, anAnchorConfig);

	tType = tGroup and tGroup["type"];

	tPixelWidth, tPixelHeight, tBarWidth, tBarHeight, tIsBar, tTemplateName = VUHDO_resolveAnchorAuraPixelDimensions(aButton, anAnchorConfig);

	tSortMethod, tSortDir = VUHDO_resolveAnchorSort(anAnchorConfig);
	tContainerLayout, tGroupLayout = VUHDO_resolveAnchorLayout(anAnchorConfig);

	tContainerLayout = tContainerLayout or { };
	tContainerLayout["elementWidth"] = tPixelWidth;
	tContainerLayout["elementHeight"] = tPixelHeight;

	tIsFixedLayout = tContainerLayout["isFixedLayout"];
	tFixedRadioValue = tContainerLayout["fixedRadioValue"];
	tUseFixedSlots = anAnchorConfig["fixedSlots"] == true;

	tContainerLayout["useFixedSlots"] = tUseFixedSlots;

	tMaxFrameCount = anAnchorConfig["maxDisplay"] or 5;

	tHealthBarWidthPx = tPanelNum and VUHDO_getHealthBarWidth(tPanelNum) or 80;
	tHealthBarHeightPx = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;

	tOffsetX = (anAnchorConfig["offsetX"] or 0) * tHealthBarWidthPx * 0.01;
	tOffsetY = -(anAnchorConfig["offsetY"] or 0) * tHealthBarHeightPx * 0.01;

	if tIsFixedLayout then
		tOffsetX = 0;
		tOffsetY = 0;
	end

	tAnchorPoint = tContainerLayout["anchorPoint"] or "TOPLEFT";
	tRelativePoint = tContainerLayout["relativePoint"] or tAnchorPoint;
	tStaticOffsetX = tContainerLayout["staticOffsetX"] or 0;
	tStaticOffsetY = tContainerLayout["staticOffsetY"] or 0;

	tAnchorButtonSetup = VUHDO_buildAnchorButtonSetup(anAnchorConfig, tPixelWidth, tPixelHeight, tIsBar, tGroup, tBarWidth, tBarHeight);

	if tIsBar and tPanelNum and ((VUHDO_PANEL_SETUP[tPanelNum] or sEmpty)["PANEL_COLOR"] or sEmpty)["barTexture"] then
		tAnchorButtonSetup["barTexture"] = VUHDO_PANEL_SETUP[tPanelNum]["PANEL_COLOR"]["barTexture"];
	end

	if tIsBar then
		tColorMode = anAnchorConfig["colorMode"] or "default";
		tAnchorButtonSetup["barColorMode"] = tColorMode;

		if "default" == tColorMode then
			tBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

			tAnchorButtonSetup["barColor"] = (tBarColors and tBarColors["AURA_BAR_DEFAULT"]) or sAuraBarFallbackColor;
		else
			tAnchorButtonSetup["barColor"] = sAuraBarFallbackColor;
		end
	end

	tGroups = { };
	tSlots = { };
	tSpacing = (tGroupLayout or sEmpty)["spacing"] or 2;
	tMaxCols = tContainerLayout["maxColumns"] or 5;
	tGrowthDir = VUHDO_AURA_GROWTH_OFFSETS[anAnchorConfig["growthDir"]] or VUHDO_AURA_GROWTH_OFFSETS["RIGHT"];
	tWrapDir = VUHDO_AURA_GROWTH_OFFSETS[anAnchorConfig["wrapDir"]] or VUHDO_AURA_GROWTH_OFFSETS["DOWN"];

	if tType ~= VUHDO_AURA_GROUP_TYPE_LIST then
		if tGroup["resolvedFilter"] or tGroup["filter"] then
			tGroupTemplate = {
				["key"] = "aura",
				["filterString"] = tFilterString,
				["candidateFilters"] = tCandidateFilters,
				["isHarmful"] = tGroup["isHarmful"] == true,
				["maxFrameCount"] = tMaxFrameCount,
				["sortMethod"] = tSortMethod,
				["sortDir"] = tSortDir,
				["templateName"] = tTemplateName,
				["layout"] = {
					["elementWidth"] = tPixelWidth,
					["elementHeight"] = tPixelHeight,
					["elementSpacing"] = tSpacing,
					["lineSpacing"] = tSpacing,
				},
				["buttonSetup"] = tAnchorButtonSetup,
			};

			tinsert(tGroups, tGroupTemplate);
		end
	elseif tGroup then
		if VUHDO_isListCollapseEligible(tGroup, tUseFixedSlots, tIsFixedLayout) then
			tGroups = VUHDO_buildListAnchorEntryGroups(tGroup, anAnchorConfig, tPixelWidth, tPixelHeight, tSpacing, tMaxFrameCount, tTemplateName, tAnchorButtonSetup, tIsBar);
		else
			tSlots = VUHDO_buildListAnchorSlots(tGroup, anAnchorConfig, tPixelWidth, tPixelHeight, tSpacing, tMaxCols, tMaxFrameCount, tTemplateName, tAnchorButtonSetup, tIsBar, tGrowthDir, tWrapDir, tIsFixedLayout, tFixedRadioValue, tHealthBarWidthPx, tHealthBarHeightPx);
		end
	end

	if #tGroups == 0 and #tSlots == 0 then
		return nil;
	end

	tCachedTemplate = {
		["anchor"] = tIsFixedLayout and {
			["mode"] = "healthBarCover",
			["frameLevelOffset"] = 10,
			["offsetX"] = tStaticOffsetX + tOffsetX,
			["offsetY"] = tStaticOffsetY + tOffsetY,
		} or {
			["mode"] = "anchorpos",
			["frameLevelOffset"] = 10,
			["points"] = {
				{
					["point"] = tAnchorPoint,
					["relativePoint"] = tRelativePoint,
					["relFrame"] = tContainerLayout["relFrame"],
					["x"] = tStaticOffsetX + tOffsetX,
					["y"] = tStaticOffsetY + tOffsetY,
				},
			},
		},
		["containerLayout"] = tContainerLayout,
		["groups"] = tGroups,
		["slots"] = tSlots,
	};

	VUHDO_finalizeCachedAuraContainerTemplate(tCachedTemplate);

	if tPanelNum then
		if not VUHDO_AURA_CONTAINER_TEMPLATE_CACHE[tPanelNum] then
			VUHDO_AURA_CONTAINER_TEMPLATE_CACHE[tPanelNum] = { };
		end

		VUHDO_AURA_CONTAINER_TEMPLATE_CACHE[tPanelNum][anAnchorIndex] = {
			["version"] = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION,
			["template"] = tCachedTemplate,
			["instanceTemplate"] = {
				["parent"] = aButton,
				["anchor"] = tCachedTemplate["anchor"],
				["containerLayout"] = tContainerLayout,
				["groups"] = tGroups,
				["slots"] = tSlots,
				["buildSignature"] = tCachedTemplate["buildSignature"],
				["staticSlots"] = tCachedTemplate["staticSlots"],
				["usesDispelTextures"] = tCachedTemplate["usesDispelTextures"],
				["panelNum"] = tPanelNum,
				["anchorIndex"] = anAnchorIndex,
			},
		};
	end

	return {
		["parent"] = aButton,
		["anchor"] = tCachedTemplate["anchor"],
		["containerLayout"] = tContainerLayout,
		["groups"] = tGroups,
		["slots"] = tSlots,
		["buildSignature"] = tCachedTemplate["buildSignature"],
		["staticSlots"] = tCachedTemplate["staticSlots"],
		["usesDispelTextures"] = tCachedTemplate["usesDispelTextures"],
		["panelNum"] = tPanelNum,
		["anchorIndex"] = anAnchorIndex,
	};

end



--
local tResolvedProcessedType;
function VUHDO_resolveProcessedAuraType(aTypeName)

	if not aTypeName then
		return nil;
	end

	tResolvedProcessedType = AuraUtil.AuraUpdateChangedType[aTypeName];

	if not tResolvedProcessedType or tResolvedProcessedType == AuraUtil.AuraUpdateChangedType.None then
		return nil;
	end

	return tResolvedProcessedType;

end



do
	--
	local tType;
	local tCandidate;
	local tSpellIds;
	local tExcludeIds;
	local tValue;
	local tCandidateBooleans;
	local tTriState;
	local tBoolKey;
	local tResolvedBool;
	function VUHDO_resolveGroupCandidateFilters(aGroup, anAnchorConfig)

		if not aGroup then
			return nil;
		end

		tCandidate = nil;
		tType = aGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

		if tType == VUHDO_AURA_GROUP_TYPE_LIST and aGroup["entries"] then
			tSpellIds = nil;

			for _, tEntry in ipairs(aGroup["entries"]) do
				if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
					tValue = tEntry["value"];

					tSpellIds = tSpellIds or { };

					VUHDO_addResolvedAuraContainerSpellIds(tSpellIds, tValue);
				end
			end

			if tSpellIds and next(tSpellIds) then
				tCandidate = tCandidate or { };

				tCandidate["includeSpellIDs"] = tSpellIds;
			end
		end

		tExcludeIds = VUHDO_resolveGroupExcludeSpellIDs(aGroup);

		if tExcludeIds then
			tCandidate = tCandidate or { };

			tCandidate["excludeSpellIDs"] = tExcludeIds;
		end

		tCandidateBooleans = aGroup["candidateBooleans"];

		if tCandidateBooleans then
			for tCnt = 1, #sCandidateBooleanKeys do
				tBoolKey = sCandidateBooleanKeys[tCnt];
				tTriState = tCandidateBooleans[tBoolKey];
				tResolvedBool = VUHDO_getTriStateBool({ [tBoolKey] = tTriState }, tBoolKey, nil);

				if tResolvedBool ~= nil then
					tCandidate = tCandidate or { };

					tCandidate[tBoolKey] = tResolvedBool;
				end
			end
		end

		if aGroup["processedAuraType"] then
			tResolvedProcessedType = VUHDO_resolveProcessedAuraType(aGroup["processedAuraType"]);

			if tResolvedProcessedType then
				tCandidate = tCandidate or { };

				tCandidate["processedAuraType"] = tResolvedProcessedType;
			end
		end

		if aGroup["hasDuration"] then
			tCandidate = tCandidate or { };

			tCandidate["maxDuration"] = math.huge;
		end

		return tCandidate;

	end
end



--
local tSortRule;
local tSortDir;
function VUHDO_resolveAnchorSort(anAnchorConfig)

	if not anAnchorConfig then
		return AuraContainerSortMethod.Default, AuraContainerSortDirection.Normal;
	end

	tSortRule = anAnchorConfig["sortRule"] or 0;
	tSortDir = anAnchorConfig["sortDir"] or 0;

	return sSortRuleToMethod[tSortRule] or AuraContainerSortMethod.Default, tSortDir == 1 and AuraContainerSortDirection.Reverse or AuraContainerSortDirection.Normal;

end



--
local tFixedAnchorGroup;
local function VUHDO_isFixedAnchorLayoutSupported(anAnchorConfig)

	tFixedAnchorGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

	if not tFixedAnchorGroup then
		return false;
	end

	return VUHDO_AURA_GROUP_TYPE_LIST == tFixedAnchorGroup["type"];

end



--
local tContainerLayout;
local tGroupLayout;
local tGrowthDir;
local tWrapDir;
local tRadioValue;
local tPos;
local tPosition;
local tMaxCols;
function VUHDO_resolveAnchorLayout(anAnchorConfig)

	if not anAnchorConfig then
		return nil, nil;
	end

	tRadioValue = anAnchorConfig["radioValue"];

	if tRadioValue and tRadioValue <= 17 then
		tPos = VUHDO_AURA_RADIOVALUE_POSITIONS and VUHDO_AURA_RADIOVALUE_POSITIONS[tRadioValue];

		tGrowthDir = anAnchorConfig["growthDir"] or "RIGHT";
		tWrapDir = anAnchorConfig["wrapDir"] or "DOWN";
		tMaxCols = anAnchorConfig["maxColumns"] or 5;

		tLayoutAxis, tHorizontalDir, tVerticalDir = VUHDO_resolveAnchorFlowDirections(tGrowthDir, tWrapDir, tMaxCols);

		if tPos then
			tContainerLayout = {
				["anchorPoint"] = tPos["anchor"],
				["relativePoint"] = tPos["relPoint"],
				["relFrame"] = tPos["relFrame"],
				["staticOffsetX"] = tPos["xOffset"] or 0,
				["staticOffsetY"] = tPos["yOffset"] or 0,
				["layoutAxis"] = tLayoutAxis,
				["horizontalDir"] = tHorizontalDir,
				["verticalDir"] = tVerticalDir,
				["maxColumns"] = tMaxCols,
				["maxRows"] = anAnchorConfig["maxRows"] or 1,
				["spacing"] = anAnchorConfig["spacing"] or 2,
			};
		else
			tContainerLayout = {
				["anchorPoint"] = "TOPRIGHT",
				["relativePoint"] = "TOPRIGHT",
				["relFrame"] = "Button",
				["staticOffsetX"] = 0,
				["staticOffsetY"] = 0,
				["layoutAxis"] = tLayoutAxis,
				["horizontalDir"] = tHorizontalDir,
				["verticalDir"] = tVerticalDir,
				["maxColumns"] = tMaxCols,
				["maxRows"] = anAnchorConfig["maxRows"] or 1,
				["spacing"] = anAnchorConfig["spacing"] or 2,
			};
		end
	elseif tRadioValue and (30 == tRadioValue or 31 == tRadioValue) and VUHDO_isFixedAnchorLayoutSupported(anAnchorConfig) then
		tContainerLayout = {
			["isFixedLayout"] = true,
			["fixedRadioValue"] = tRadioValue,
			["relFrame"] = "HealthBar",
			["maxColumns"] = anAnchorConfig["maxColumns"] or 5,
			["maxRows"] = anAnchorConfig["maxRows"] or 1,
			["spacing"] = anAnchorConfig["spacing"] or 2,
		};
	else
		tGrowthDir = anAnchorConfig["growthDir"] or "LEFT";
		tWrapDir = anAnchorConfig["wrapDir"] or "DOWN";
		tPosition = anAnchorConfig["position"] or "TOPRIGHT";
		tMaxCols = anAnchorConfig["maxColumns"] or 5;

		tLayoutAxis, tHorizontalDir, tVerticalDir = VUHDO_resolveAnchorFlowDirections(tGrowthDir, tWrapDir, tMaxCols);

		tContainerLayout = {
			["anchorPoint"] = tPosition,
			["relativePoint"] = tPosition,
			["relFrame"] = "Button",
			["staticOffsetX"] = 0,
			["staticOffsetY"] = 0,
			["layoutAxis"] = tLayoutAxis,
			["horizontalDir"] = tHorizontalDir,
			["verticalDir"] = tVerticalDir,
			["maxColumns"] = tMaxCols,
			["maxRows"] = anAnchorConfig["maxRows"] or 1,
			["spacing"] = anAnchorConfig["spacing"] or 2,
		};
	end

	tGroupLayout = {
		["spacing"] = anAnchorConfig["spacing"] or 2,
	};

	return tContainerLayout, tGroupLayout;

end



--
local tDurationMode;
local tTimerThreshold;
local tEntryDurationMode;
local tEntryTimerThreshold;
function VUHDO_resolveGroupTimerSettings(aGroup)

	if not aGroup or (aGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER) ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return VUHDO_SPELL_DURATION_MODE_THRESHOLD, 9.99;
	end

	tDurationMode = nil;
	tTimerThreshold = nil;

	for _, tEntry in ipairs(aGroup["entries"] or sEmpty) do
		if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			tEntryDurationMode = tEntry["durationMode"];
			tEntryTimerThreshold = tEntry["timerThreshold"];

			if tDurationMode == nil then
				tDurationMode = tEntryDurationMode;
				tTimerThreshold = tEntryTimerThreshold;
			elseif tDurationMode ~= tEntryDurationMode or tTimerThreshold ~= tEntryTimerThreshold then
				return VUHDO_SPELL_DURATION_MODE_THRESHOLD, 9.99;
			end
		end
	end

	return tDurationMode or VUHDO_SPELL_DURATION_MODE_THRESHOLD, tTimerThreshold or 9.99;

end