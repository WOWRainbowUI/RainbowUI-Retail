local _;

local pairs = pairs;
local ipairs = ipairs;
local next = next;
local strfind = string.find;
local twipe = table.wipe;

local UnitCanAttack = UnitCanAttack;
local issecretvalue = issecretvalue;

VUHDO_OVERLAYS_REBUILD_PENDING = false;

local VUHDO_OVERLAY_CONTAINERS = VUHDO_OVERLAY_CONTAINERS;
local VUHDO_INDICATOR_OVERLAY_TARGETS = VUHDO_INDICATOR_OVERLAY_TARGETS;
local VUHDO_AURA_BUTTON_OVERLAY_TEMPLATE = "VuhDoAuraButtonOverlayTemplate";
local VUHDO_AURA_BUTTON_ICON_TEMPLATE = "VuhDoAuraButtonIconTemplate";

local VUHDO_PANEL_SETUP;
local VUHDO_BOUQUETS;
local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_BUTTON_CACHE;
local VUHDO_BOUQUET_BUFFS_SPECIAL;
local VUHDO_SECRET_TYPE_DISPEL;
local VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP;
local VUHDO_BOUQUET_VALUE_TYPE_NONE;
local VUHDO_BOUQUET_VALUE_TYPE_AURA;
local VUHDO_BOUQUET_VALUE_TYPE_STATUS;
local VUHDO_AURA_GROUP_COLOR_OFF;
local VUHDO_AURA_GROUP_COLOR_DISPEL;
local VUHDO_AURA_GROUP_COLOR_ALL_DISPEL;
local VUHDO_AURA_GROUP_COLOR_CUSTOM;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_SPELL;
local VUHDO_CUSTOM_ICONS;
local VUHDO_AURA_GROUP_TYPE_FILTER;
local VUHDO_SUPPRESS_CANDIDATE_FILTERS;
local VUHDO_CUSTOM_GLOW_AURA_GROUP_KEY;
local VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY;

local VUHDO_PixelUtil;

local VUHDO_getUnitButtonsSafe;
local VUHDO_getHealthBar;
local VUHDO_getAuraGroup;
local VUHDO_getAuraGroupResolvedFilters;
local VUHDO_getCanColorBarGroups;
local VUHDO_getAllDispelTypeNames;
local VUHDO_getPlayerDispelTypeNames;
local VUHDO_getBackgroundDispelTypeNames;
local VUHDO_getAllDispelBarColorTypeNames;
local VUHDO_getPlayerDispelBarColorTypeNames;
local VUHDO_getPlayerPurgeBarColorTypeNames;
local VUHDO_getAllDispelGlowTypeNames;
local VUHDO_getPlayerDispelGlowTypeNames;
local VUHDO_getPlayerPurgeGlowTypeNames;
local VUHDO_copyOverlayCandidateFilters;
local VUHDO_resolveAuraContainerSpellId;
local VUHDO_addResolvedAuraContainerSpellIds;
local VUHDO_getStatusbarOrientationNumber;
local VUHDO_decompressIfCompressed;
local VUHDO_isAuraDataRestricted;
local VUHDO_isAuraModeContainers;
local VUHDO_stopUnitButtonAuraGroupGlow;
local VUHDO_acquireAuraContainer;
local VUHDO_releaseAuraContainer;
local VUHDO_refreshAuraContainer;
local VUHDO_getOverlayHostFrame;
local VUHDO_deferAcquireOverlayContainer;
local VUHDO_deferSyncOverlaysForUnit;
local VUHDO_applyStoredChainBaselineColor;
local VUHDO_showOverlayFillChainBackgroundForData;
local VUHDO_hideOverlayFillChainBackgroundForData;

local sEmpty = { };
local sOverlayConfigKeys = { };
local sOverlayConfigGeneration = 0;
local sOverlayEntryPrototypeCache = { };
local sOverlayZeroPlanCount = 0;
local sOverlayZeroPlanLastReason = nil;
local sOverlayFilterFlagsCache = { };
local sPendingOverlayBuilds = { };
local sStagingOverlayContainers = { };
local sHasAnyOverlays = false;

local sOverlayScratch = {
	["fillEntries"] = { },
	["nonFillEntries"] = { },
	["groupOverlayEntries"] = { },
	["canColorGroupEntries"] = { },
	["auraGroupEntries"] = { },
	["overlayClaims"] = { },
	["overlayFilteredEntries"] = { },
	["barGlowFilterEntries"] = { },
	["stampedEntries"] = { },
};

local sDispelNameHostile = {
	["Enrage"] = true,
};

local sDebuffTypeDispelName = {
	[VUHDO_DEBUFF_TYPE_MAGIC] = "Magic",
	[VUHDO_DEBUFF_TYPE_CURSE] = "Curse",
	[VUHDO_DEBUFF_TYPE_DISEASE] = "Disease",
	[VUHDO_DEBUFF_TYPE_POISON] = "Poison",
	[VUHDO_DEBUFF_TYPE_BLEED] = "Bleed",
	[VUHDO_DEBUFF_TYPE_ENRAGE] = "Enrage",
};

local sOverlaySublevelAllocators = { };
local sOverlaySublevelWarned = { };
local sOverlaySublevelSlots;
local sOverlaySublevelTotal;



do
	--
	local tSlot;
	sOverlaySublevelSlots = { };

	for tSublevel = 2, 7 do
		tSlot = {
			["layer"] = "ARTWORK",
			["sublevel"] = tSublevel,
		};

		sOverlaySublevelSlots[#sOverlaySublevelSlots + 1] = tSlot;
	end

	for tSublevel = -8, 5 do
		tSlot = {
			["layer"] = "OVERLAY",
			["sublevel"] = tSublevel,
		};

		sOverlaySublevelSlots[#sOverlaySublevelSlots + 1] = tSlot;
	end

	sOverlaySublevelTotal = #sOverlaySublevelSlots;
end



--
function VUHDO_auraContainerOverlaysInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BOUQUETS = _G["VUHDO_BOUQUETS"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_INDICATOR_CONFIG = _G["VUHDO_INDICATOR_CONFIG"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_BOUQUET_BUFFS_SPECIAL = _G["VUHDO_BOUQUET_BUFFS_SPECIAL"];
	VUHDO_SECRET_TYPE_DISPEL = _G["VUHDO_SECRET_TYPE_DISPEL"];
	VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP = _G["VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP"];
	VUHDO_BOUQUET_VALUE_TYPE_NONE = _G["VUHDO_BOUQUET_VALUE_TYPE_NONE"];
	VUHDO_BOUQUET_VALUE_TYPE_AURA = _G["VUHDO_BOUQUET_VALUE_TYPE_AURA"];
	VUHDO_BOUQUET_VALUE_TYPE_STATUS = _G["VUHDO_BOUQUET_VALUE_TYPE_STATUS"];
	VUHDO_AURA_GROUP_COLOR_OFF = _G["VUHDO_AURA_GROUP_COLOR_OFF"];
	VUHDO_AURA_GROUP_COLOR_DISPEL = _G["VUHDO_AURA_GROUP_COLOR_DISPEL"];
	VUHDO_AURA_GROUP_COLOR_ALL_DISPEL = _G["VUHDO_AURA_GROUP_COLOR_ALL_DISPEL"];
	VUHDO_AURA_GROUP_COLOR_CUSTOM = _G["VUHDO_AURA_GROUP_COLOR_CUSTOM"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_AURA_LIST_ENTRY_SPELL = _G["VUHDO_AURA_LIST_ENTRY_SPELL"];
	VUHDO_CUSTOM_ICONS = _G["VUHDO_CUSTOM_ICONS"];
	VUHDO_AURA_GROUP_TYPE_FILTER = _G["VUHDO_AURA_GROUP_TYPE_FILTER"];
	VUHDO_SUPPRESS_CANDIDATE_FILTERS = _G["VUHDO_SUPPRESS_CANDIDATE_FILTERS"];
	VUHDO_CUSTOM_GLOW_AURA_GROUP_KEY = _G["VUHDO_CUSTOM_GLOW_AURA_GROUP_KEY"];
	VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY = _G["VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY"];

	VUHDO_PixelUtil = _G["VUHDO_PixelUtil"];

	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getAuraGroup = _G["VUHDO_getAuraGroup"];
	VUHDO_getAuraGroupResolvedFilters = _G["VUHDO_getAuraGroupResolvedFilters"];
	VUHDO_getCanColorBarGroups = _G["VUHDO_getCanColorBarGroups"];
	VUHDO_getAllDispelTypeNames = _G["VUHDO_getAllDispelTypeNames"];
	VUHDO_getPlayerDispelTypeNames = _G["VUHDO_getPlayerDispelTypeNames"];
	VUHDO_getBackgroundDispelTypeNames = _G["VUHDO_getBackgroundDispelTypeNames"];
	VUHDO_getAllDispelBarColorTypeNames = _G["VUHDO_getAllDispelBarColorTypeNames"];
	VUHDO_getPlayerDispelBarColorTypeNames = _G["VUHDO_getPlayerDispelBarColorTypeNames"];
	VUHDO_getPlayerPurgeBarColorTypeNames = _G["VUHDO_getPlayerPurgeBarColorTypeNames"];
	VUHDO_getAllDispelGlowTypeNames = _G["VUHDO_getAllDispelGlowTypeNames"];
	VUHDO_getPlayerDispelGlowTypeNames = _G["VUHDO_getPlayerDispelGlowTypeNames"];
	VUHDO_getPlayerPurgeGlowTypeNames = _G["VUHDO_getPlayerPurgeGlowTypeNames"];
	VUHDO_copyOverlayCandidateFilters = _G["VUHDO_copyOverlayCandidateFilters"];
	VUHDO_resolveAuraContainerSpellId = _G["VUHDO_resolveAuraContainerSpellId"];
	VUHDO_addResolvedAuraContainerSpellIds = _G["VUHDO_addResolvedAuraContainerSpellIds"];
	VUHDO_getStatusbarOrientationNumber = _G["VUHDO_getStatusbarOrientationNumber"];
	VUHDO_decompressIfCompressed = _G["VUHDO_decompressIfCompressed"];
	VUHDO_isAuraDataRestricted = _G["VUHDO_isAuraDataRestricted"];
	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];
	VUHDO_stopUnitButtonAuraGroupGlow = _G["VUHDO_stopUnitButtonAuraGroupGlow"];
	VUHDO_acquireAuraContainer = _G["VUHDO_acquireAuraContainer"];
	VUHDO_releaseAuraContainer = _G["VUHDO_releaseAuraContainer"];
	VUHDO_refreshAuraContainer = _G["VUHDO_refreshAuraContainer"];
	VUHDO_getOverlayHostFrame = _G["VUHDO_getOverlayHostFrame"];
	VUHDO_deferAcquireOverlayContainer = _G["VUHDO_deferAcquireOverlayContainer"];
	VUHDO_deferSyncOverlaysForUnit = _G["VUHDO_deferSyncOverlaysForUnit"];
	VUHDO_applyStoredChainBaselineColor = _G["VUHDO_applyStoredChainBaselineColor"];
	VUHDO_showOverlayFillChainBackgroundForData = _G["VUHDO_showOverlayFillChainBackgroundForData"];
	VUHDO_hideOverlayFillChainBackgroundForData = _G["VUHDO_hideOverlayFillChainBackgroundForData"];

	return;

end



do
	--
	function VUHDO_resetOverlaySublevelAllocator(aTargetFrame)

		if not aTargetFrame then
			return;
		end

		sOverlaySublevelAllocators[aTargetFrame] = 1;

		return;

	end



	--
	local tAllocator;
	local tSlots;
	local tSlotsNeeded;
	local tRemaining;
	local tSlotIndex;
	local tSlot;
	function VUHDO_allocateOverlaySublevels(aTargetFrame, aSlotCount, anIndicatorKey)

		tSlots = { };

		if not aTargetFrame or not aSlotCount or aSlotCount <= 0 then
			return tSlots;
		end

		tAllocator = sOverlaySublevelAllocators[aTargetFrame] or 1;
		tSlotsNeeded = aSlotCount;

		if tAllocator + tSlotsNeeded - 1 > sOverlaySublevelTotal then
			tRemaining = sOverlaySublevelTotal - tAllocator + 1;

			if tRemaining < tSlotsNeeded then
				if anIndicatorKey and not sOverlaySublevelWarned[anIndicatorKey] then
					sOverlaySublevelWarned[anIndicatorKey] = true;

					VUHDO_xMsg("Overlay sublevel budget exhausted for indicator:", anIndicatorKey);
				end

				tSlotsNeeded = tRemaining;

				if tSlotsNeeded <= 0 then
					return tSlots;
				end
			end
		end

		for tCnt = 1, tSlotsNeeded do
			tSlotIndex = tAllocator + tCnt - 1;

			tSlot = sOverlaySublevelSlots[tSlotIndex];

			tSlots[#tSlots + 1] = tSlot;
		end

		sOverlaySublevelAllocators[aTargetFrame] = tAllocator + tSlotsNeeded;

		return tSlots;

	end



	--
	local tCustomSetup;
	local tBarTexture;
	local tOrientation;
	local tBgBar;
	local tOcclusionR;
	local tOcclusionG;
	local tOcclusionB;
	local tOcclusionO;
	local tThreatHeight;
	local tBarButtonSetup;
	function VUHDO_getOverlayBarButtonSetup(aPanelNum, anIndicatorKey, aTargetFrame, aButton)

		tCustomSetup = VUHDO_INDICATOR_CONFIG[aPanelNum] and VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"][anIndicatorKey];
		tBarTexture = (tCustomSetup and tCustomSetup["TEXTURE"])
			or ((VUHDO_PANEL_SETUP[aPanelNum] or sEmpty)["PANEL_COLOR"] or sEmpty)["barTexture"];
		tOrientation = VUHDO_getStatusbarOrientationNumber(anIndicatorKey, aPanelNum);

		tBgBar = VUHDO_getHealthBar(aButton, 3);
		tOcclusionR, tOcclusionG, tOcclusionB, tOcclusionO = 0, 0, 0, 1;

		if tBgBar then
			tOcclusionR, tOcclusionG, tOcclusionB, tOcclusionO = tBgBar:GetStatusBarColor();
		end

		tBarButtonSetup = {
			["barTexture"] = tBarTexture,
			["barOrientation"] = tOrientation,
			["barInverted"] = tCustomSetup and tCustomSetup["invertGrowth"],
			["occlusionColor"] = {
				["R"] = tOcclusionR,
				["G"] = tOcclusionG,
				["B"] = tOcclusionB,
				["O"] = 1,
			},
		};

		if "THREAT_BAR" == anIndicatorKey and aTargetFrame then
			tThreatHeight = (tCustomSetup and tCustomSetup["HEIGHT"]) or aTargetFrame:GetHeight();

			tBarButtonSetup["height"] = tThreatHeight;

			if not InCombatLockdown() then
				VUHDO_PixelUtil.SetHeight(aTargetFrame, tThreatHeight, 1);
			end
		end

		return tBarButtonSetup;

	end



	--
	local tBorderCustomSetup;
	local tBorderButtonSetup;
	function VUHDO_getOverlayBorderButtonSetup(aPanelNum, anIndicatorKey)

		tBorderCustomSetup = VUHDO_INDICATOR_CONFIG[aPanelNum] and VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"][anIndicatorKey];

		tBorderButtonSetup = {
			["borderWidth"] = (tBorderCustomSetup and tBorderCustomSetup["WIDTH"]) or 1,
			["borderFile"] = (tBorderCustomSetup and tBorderCustomSetup["FILE"]) or "Interface\\AddOns\\VuhDo\\Images\\white_square_16_16",
		};

		return tBorderButtonSetup;

	end
end



do
	--
	local tModeItemSpecial;
	local function VUHDO_getBouquetItemValueType(aItem)

		tModeItemSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[aItem["name"]];

		if not tModeItemSpecial then
			return VUHDO_BOUQUET_VALUE_TYPE_AURA;
		end

		return tModeItemSpecial["valueType"] or VUHDO_BOUQUET_VALUE_TYPE_NONE;

	end



	--
	local tModeItem;
	local tModeItemValueType;
	local tValueItem;
	local tValueSpecial;
	local tHasHigherStatusItem;
	local tHasCoverContributor;
	local tGateValidators;
	local tGateIdx;
	function VUHDO_resolveOverlayShadowValueMode(aBouquet, aItemIdx, anOverlayTarget)

		tModeItem = aBouquet[aItemIdx];
		tModeItemValueType = VUHDO_getBouquetItemValueType(tModeItem);

		if anOverlayTarget and anOverlayTarget["barValue"] == "binary" then

			if tModeItemValueType == VUHDO_BOUQUET_VALUE_TYPE_NONE then
				return "mirror";
			end

			return "cover";
		end

		if anOverlayTarget and anOverlayTarget["barValue"] == "bouquet" then

			if tModeItemValueType == VUHDO_BOUQUET_VALUE_TYPE_NONE then
				return "mirror";
			end

			if tModeItemValueType == VUHDO_BOUQUET_VALUE_TYPE_AURA then
				tHasHigherStatusItem = false;
				tHasCoverContributor = false;
				tGateValidators = nil;
				tGateIdx = 0;

				for tScan = 1, aItemIdx - 1 do
					tValueItem = aBouquet[tScan];
					tValueSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tValueItem["name"]];

					if tValueSpecial and tValueSpecial["valueType"] == VUHDO_BOUQUET_VALUE_TYPE_STATUS then
						if tValueSpecial["isSecretInactive"] then
						elseif tValueSpecial["isActiveOnly"] then
							tHasHigherStatusItem = true;
							tHasCoverContributor = true;
						elseif tValueSpecial["gateValidator"] then
							tHasHigherStatusItem = true;

							if not tGateValidators then
								tGateValidators = { };
							end

							tGateIdx = tGateIdx + 1;
							tGateValidators[tGateIdx] = tValueSpecial["gateValidator"];
						else
							return "mirror";
						end
					end
				end

				if not tHasHigherStatusItem then
					return "duration";
				end

				if tGateValidators then
					if tHasCoverContributor then
						return "cover", tGateValidators;
					end

					return "duration", tGateValidators;
				end

				if tHasCoverContributor then
					return "cover";
				end

				return "mirror";
			end

			return "cover";
		end

		return "cover";

	end



	--
	local tFallbackEntry;
	local function VUHDO_shallowCopyOverlayEntry(anEntry)

		tFallbackEntry = { };

		for tCopyKey, tCopyValue in pairs(anEntry) do
			tFallbackEntry[tCopyKey] = tCopyValue;
		end

		return tFallbackEntry;

	end



	--
	local tFallbackEntry;
	local tActiveEntry;
	function VUHDO_appendOverlayEntryWithVariants(aDest, anEntry, aFallbackMode, aGateValidators)

		if not aGateValidators then
			if aFallbackMode then
				anEntry["shadowValueMode"] = aFallbackMode;
			end

			aDest[#aDest + 1] = anEntry;

			return;
		end

		tFallbackEntry = VUHDO_shallowCopyOverlayEntry(anEntry);

		tFallbackEntry["shadowValueMode"] = aFallbackMode;
		tFallbackEntry["valueGates"] = aGateValidators;
		tFallbackEntry["entryKey"] = anEntry["entryKey"] .. ":gatefallback";

		tActiveEntry = VUHDO_shallowCopyOverlayEntry(anEntry);

		tActiveEntry["shadowValueMode"] = "mirror";
		tActiveEntry["valueGates"] = aGateValidators;
		tActiveEntry["isValueGateActiveVariant"] = true;
		tActiveEntry["entryKey"] = anEntry["entryKey"] .. ":gateactive";

		aDest[#aDest + 1] = tFallbackEntry;
		aDest[#aDest + 1] = tActiveEntry;

		return;

	end



	--
	local tGateDelegate;
	function VUHDO_isAnyOverlayValueGateActive(aGates, anInfo)

		if not aGates or not anInfo then
			return false;
		end

		for tCnt = 1, #aGates do
			tGateDelegate = aGates[tCnt];

			if tGateDelegate(anInfo) then
				return true;
			end
		end

		return false;

	end
end



do
	--
	local tBaseOpacityItem;
	local tBaseOpacityColor;
	local tBaseOpacityProduct;
	local function VUHDO_computeOverlayBaseOpacityProduct(aBouquet)

		tBaseOpacityProduct = nil;

		for tCnt = #aBouquet, 1, -1 do
			tBaseOpacityItem = aBouquet[tCnt];

			if tBaseOpacityItem["name"] == "ALWAYS" then
				tBaseOpacityColor = tBaseOpacityItem["color"];

				if tBaseOpacityColor then
					if tBaseOpacityColor["useOpacity"] and tBaseOpacityColor["O"] ~= nil then
						tBaseOpacityProduct = (tBaseOpacityProduct or 1) * tBaseOpacityColor["O"];
					elseif tBaseOpacityColor["useBackground"] and tBaseOpacityColor["O"] ~= nil then
						tBaseOpacityProduct = tBaseOpacityColor["O"];
					end
				end
			end
		end

		if not tBaseOpacityProduct or tBaseOpacityProduct >= 1 then
			return nil;
		end

		return tBaseOpacityProduct;

	end



	--
	local tEntryOpacity;
	local function VUHDO_getOverlayEntryOpacity(aItem, aColorO, aBaseProduct)

		if not (aItem and aItem["color"] and aItem["color"]["useOpacity"]) then
			return nil;
		end

		tEntryOpacity = aBaseProduct or 1;

		if aColorO ~= nil then
			tEntryOpacity = tEntryOpacity * aColorO;
		end

		if tEntryOpacity >= 1 then
			return nil;
		end

		return tEntryOpacity;

	end



	--
	local tBrightFactor;
	local function VUHDO_getOverlayItemDispelBright(aItem)

		tBrightFactor = aItem and aItem["custom"] and aItem["custom"]["bright"];

		if tBrightFactor and tBrightFactor < 1 then
			return tBrightFactor;
		end

		return nil;

	end



	--
	local function VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct)

		return VUHDO_getOverlayEntryOpacity(aItem, aItem and aItem["color"] and aItem["color"]["O"], aBaseProduct);

	end



	--
	local tDerivedColor;
	local tBrightFactor;
	local tEntryOpacity;
	local function VUHDO_applyOverlayStaticColorBright(aStaticColor, aItem, aBaseProduct)

		if not aStaticColor then
			return nil;
		end

		tBrightFactor = aItem and aItem["custom"] and aItem["custom"]["bright"];

		tEntryOpacity = aStaticColor["useOpacity"] and VUHDO_getOverlayEntryOpacity(aItem, aStaticColor["O"], aBaseProduct) or nil;

		if (not tBrightFactor or tBrightFactor >= 1) and not tEntryOpacity then
			return aStaticColor;
		end

		tDerivedColor = {
			["R"] = aStaticColor["R"] or 0,
			["G"] = aStaticColor["G"] or 0,
			["B"] = aStaticColor["B"] or 0,
			["O"] = tEntryOpacity or aStaticColor["O"] or 1,
			["TR"] = aStaticColor["TR"],
			["TG"] = aStaticColor["TG"],
			["TB"] = aStaticColor["TB"],
			["TO"] = aStaticColor["TO"],
			["useBackground"] = aStaticColor["useBackground"],
			["useText"] = aStaticColor["useText"],
			["useOpacity"] = aStaticColor["useOpacity"],
			["useBorder"] = aStaticColor["useBorder"],
			["isManuallySet"] = aStaticColor["isManuallySet"],
		};

		if tBrightFactor and tBrightFactor < 1 then
			tDerivedColor["R"] = tDerivedColor["R"] * tBrightFactor;
			tDerivedColor["G"] = tDerivedColor["G"] * tBrightFactor;
			tDerivedColor["B"] = tDerivedColor["B"] * tBrightFactor;
		end

		return tDerivedColor;

	end



	--
	local function VUHDO_applyOverlayShapePrototypeFields(anOverlayEntry, anOverlayTarget)

		if anOverlayTarget["shape"] == "bar" then
			anOverlayEntry["shadowBar"] = true;
		elseif anOverlayTarget["shape"] == "border" then
			if anOverlayEntry["staticColor"] and not anOverlayEntry["dispelBorder"] then
				anOverlayEntry["border"] = true;
			end
		end

		return;

	end



	--
	local function VUHDO_stampOverlayEntryShapeFields(anOverlayEntry, anOverlayTarget, aBarButtonSetup, aBorderButtonSetup)

		if anOverlayTarget["shape"] == "bar" and anOverlayEntry["shadowBar"] and aBarButtonSetup then
			for tKey, tValue in pairs(aBarButtonSetup) do
				anOverlayEntry[tKey] = tValue;
			end
		elseif anOverlayTarget["shape"] == "border" and (anOverlayEntry["border"] or anOverlayEntry["dispelBorder"]) and aBorderButtonSetup then
			for tKey, tValue in pairs(aBorderButtonSetup) do
				anOverlayEntry[tKey] = tValue;
			end
		end

		return;

	end



	--
	local function VUHDO_applyOverlayDotIconFields(anOverlayEntry, anItem, anIconColor)

		if anItem["icon"] and anItem["icon"] ~= 1 then
			anOverlayEntry["staticIcon"] = VUHDO_CUSTOM_ICONS[anItem["icon"]][2];

			if anIconColor then
				anOverlayEntry["staticColor"] = anIconColor;
			end
		else
			anOverlayEntry["staticColor"] = nil;
			anOverlayEntry["templateName"] = VUHDO_AURA_BUTTON_ICON_TEMPLATE;

			if anIconColor then
				anOverlayEntry["iconColor"] = anIconColor;
			end
		end

		return;

	end



	--
	local tHostileDispelEntry;
	function VUHDO_buildHostileDispelEntry(aDispelTypeNames, aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, anSetEntryKey, anIsGlowFilterSpec)

		if not aDispelTypeNames or next(aDispelTypeNames) == nil then
			return nil;
		end

		if anIsGlowFilterSpec then
			return {
				["filterString"] = "HELPFUL",
				["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(nil, aDispelTypeNames),
				["hostileOnly"] = true,
				["entryKeySuffix"] = ":hostile",
			};
		end

		tHostileDispelEntry = {
			["filterString"] = "HELPFUL",
			["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(nil, aDispelTypeNames),
			["shape"] = aOverlayTarget["shape"],
			["bouquetIdx"] = aBouquetIdx,
			["groupKey"] = aGroupKey,
			["shadowValueMode"] = aShadowValueMode,
			["hostileOnly"] = true,
		};

		if anSetEntryKey then
			tHostileDispelEntry["entryKey"] = aBouquetIdx .. ":hostile";
		end

		if aOverlayTarget["shape"] == "bar" then
			tHostileDispelEntry["dispelFill"] = true;
		elseif aOverlayTarget["shape"] == "border" then
			tHostileDispelEntry["dispelBorder"] = true;
		elseif aOverlayTarget["shape"] == "dot" then
			tHostileDispelEntry["dispelIcon"] = true;

			VUHDO_applyOverlayDotIconFields(tHostileDispelEntry, aItem, nil);
		end

		tHostileDispelEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
		tHostileDispelEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

		VUHDO_applyOverlayShapePrototypeFields(tHostileDispelEntry, aOverlayTarget);

		return tHostileDispelEntry;

	end



	--
	local tResolved;
	local tFilterString;
	local tCandidateFilters;
	local tOverlayEntry;
	local tItemColor;
	local tHostileEntry;
	local tDispelTypeNames;
	local function VUHDO_buildAuraGroupOverlayEntries(aGroup, aGroupKey, aEffectiveColorType, aCustomColor, aItem, aOverlayTarget, aBouquetIdx, aShadowValueMode, aBaseProduct)

		twipe(sOverlayScratch["groupOverlayEntries"]);

		tResolved = VUHDO_getAuraGroupResolvedFilters(aGroup);

		if not tResolved then
			return sOverlayScratch["groupOverlayEntries"];
		end

		tFilterString = tResolved["filterString"];
		tCandidateFilters = VUHDO_copyOverlayCandidateFilters(tResolved["candidateFilters"], nil);

		if aOverlayTarget["shape"] == "bar" then
			if aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM and aCustomColor then
				tOverlayEntry = {
					["filterString"] = tFilterString,
					["candidateFilters"] = tCandidateFilters,
					["shape"] = aOverlayTarget["shape"],
					["bouquetIdx"] = aBouquetIdx,
					["groupKey"] = aGroupKey,
					["shadowValueMode"] = aShadowValueMode,
					["staticColor"] = VUHDO_applyOverlayStaticColorBright(aCustomColor, aItem, aBaseProduct),
				};

				VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

				sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_OFF then
				tItemColor = aItem["color"];

				if tItemColor and tItemColor["useBackground"] then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = tCandidateFilters,
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["staticColor"] = VUHDO_applyOverlayStaticColorBright(tItemColor, aItem, aBaseProduct),
					};

					VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
				tDispelTypeNames = VUHDO_getPlayerDispelBarColorTypeNames();

				if next(tDispelTypeNames) ~= nil then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["dispelFill"] = true,
						["friendlyOnly"] = true,
					};

					if tFilterString and not strfind(tFilterString, "|RAID", 1, true) then
						tOverlayEntry["filterString"] = tFilterString .. "|RAID";
					end

					tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
					tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

					VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end

				tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getPlayerPurgeBarColorTypeNames(), aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, false, false);

				if tHostileEntry then
					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tHostileEntry;
				end
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_ALL_DISPEL then
				tDispelTypeNames = VUHDO_getAllDispelBarColorTypeNames();

				if next(tDispelTypeNames) ~= nil then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["dispelFill"] = true,
						["friendlyOnly"] = true,
					};

					tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
					tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

					VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end

				tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getAllDispelBarColorTypeNames(), aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, false, false);

				if tHostileEntry then
					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tHostileEntry;
				end
			end
		elseif aOverlayTarget["shape"] == "border" then
			if aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM and aCustomColor then
				tOverlayEntry = {
					["filterString"] = tFilterString,
					["candidateFilters"] = tCandidateFilters,
					["shape"] = aOverlayTarget["shape"],
					["bouquetIdx"] = aBouquetIdx,
					["groupKey"] = aGroupKey,
					["shadowValueMode"] = aShadowValueMode,
					["staticColor"] = VUHDO_applyOverlayStaticColorBright(aCustomColor, aItem, aBaseProduct),
					["border"] = true,
				};

				sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_OFF then
				tItemColor = aItem["color"];

				if tItemColor and tItemColor["useBackground"] then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = tCandidateFilters,
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["staticColor"] = VUHDO_applyOverlayStaticColorBright(tItemColor, aItem, aBaseProduct),
						["border"] = true,
					};

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
				tDispelTypeNames = VUHDO_getPlayerDispelBarColorTypeNames();

				if next(tDispelTypeNames) ~= nil then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["dispelBorder"] = true,
						["friendlyOnly"] = true,
					};

					if tFilterString and not strfind(tFilterString, "|RAID", 1, true) then
						tOverlayEntry["filterString"] = tFilterString .. "|RAID";
					end

					tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
					tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end

				tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getPlayerPurgeBarColorTypeNames(), aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, false, false);

				if tHostileEntry then
					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tHostileEntry;
				end
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_ALL_DISPEL then
				tDispelTypeNames = VUHDO_getAllDispelBarColorTypeNames();

				if next(tDispelTypeNames) ~= nil then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["dispelBorder"] = true,
						["friendlyOnly"] = true,
					};

					tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
					tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end

				tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getAllDispelBarColorTypeNames(), aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, false, false);

				if tHostileEntry then
					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tHostileEntry;
				end
			end
		elseif aOverlayTarget["shape"] == "dot" then
			tOverlayEntry = nil;
			tItemColor = aItem["color"];

			if aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM and aCustomColor then
				tOverlayEntry = {
					["filterString"] = tFilterString,
					["candidateFilters"] = tCandidateFilters,
					["shape"] = aOverlayTarget["shape"],
					["bouquetIdx"] = aBouquetIdx,
					["groupKey"] = aGroupKey,
					["shadowValueMode"] = aShadowValueMode,
					["staticColor"] = VUHDO_applyOverlayStaticColorBright(aCustomColor, aItem, aBaseProduct),
				};
			elseif tItemColor and tItemColor["useBackground"] then
				tOverlayEntry = {
					["filterString"] = tFilterString,
					["candidateFilters"] = tCandidateFilters,
					["shape"] = aOverlayTarget["shape"],
					["bouquetIdx"] = aBouquetIdx,
					["groupKey"] = aGroupKey,
					["shadowValueMode"] = aShadowValueMode,
					["staticColor"] = VUHDO_applyOverlayStaticColorBright(tItemColor, aItem, aBaseProduct),
				};
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
				tDispelTypeNames = VUHDO_getPlayerDispelBarColorTypeNames();

				if next(tDispelTypeNames) ~= nil then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["dispelIcon"] = true,
						["friendlyOnly"] = true,
					};

					if tFilterString and not strfind(tFilterString, "|RAID", 1, true) then
						tOverlayEntry["filterString"] = tFilterString .. "|RAID";
					end

					tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
					tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

					VUHDO_applyOverlayDotIconFields(tOverlayEntry, aItem, nil);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end

				tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getPlayerPurgeBarColorTypeNames(), aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, false, false);

				if tHostileEntry then
					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tHostileEntry;
				end
			elseif aEffectiveColorType == VUHDO_AURA_GROUP_COLOR_ALL_DISPEL then
				tDispelTypeNames = VUHDO_getAllDispelBarColorTypeNames();

				if next(tDispelTypeNames) ~= nil then
					tOverlayEntry = {
						["filterString"] = tFilterString,
						["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
						["shape"] = aOverlayTarget["shape"],
						["bouquetIdx"] = aBouquetIdx,
						["groupKey"] = aGroupKey,
						["shadowValueMode"] = aShadowValueMode,
						["dispelIcon"] = true,
						["friendlyOnly"] = true,
					};

					tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
					tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

					VUHDO_applyOverlayDotIconFields(tOverlayEntry, aItem, nil);

					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
				end

				tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getAllDispelBarColorTypeNames(), aOverlayTarget, aBouquetIdx, aGroupKey, aShadowValueMode, aItem, aBaseProduct, false, false);

				if tHostileEntry then
					sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tHostileEntry;
				end
			end

			if tOverlayEntry and not tOverlayEntry["dispelIcon"] then
				VUHDO_applyOverlayDotIconFields(tOverlayEntry, aItem, tOverlayEntry["staticColor"]);

				sOverlayScratch["groupOverlayEntries"][#sOverlayScratch["groupOverlayEntries"] + 1] = tOverlayEntry;
			end
		end

		return sOverlayScratch["groupOverlayEntries"];

	end



	--
	local tGroupId;
	local tGroup;
	local tEffectiveColorType;
	local tResolved;
	local tHasListSpell;
	local tFilterString;
	local tCandidateFilters;
	local tOverlayEntry;
	local tHostileEntry;
	local tDispelTypeNames;
	local function VUHDO_buildCanColorBarGroupOverlayEntries(aCanColorGroup, aItem, aOverlayTarget, aBouquetIdx, aShadowValueMode, aBaseProduct)

		twipe(sOverlayScratch["canColorGroupEntries"]);

		if not aCanColorGroup["canColorBar"] then
			return sOverlayScratch["canColorGroupEntries"];
		end

		tGroupId = aCanColorGroup["groupId"];
		tGroup = VUHDO_getAuraGroup(tGroupId);

		if not tGroup then
			return sOverlayScratch["canColorGroupEntries"];
		end

		tEffectiveColorType = aCanColorGroup["colorType"] or VUHDO_AURA_GROUP_COLOR_DISPEL;

		tResolved = VUHDO_getAuraGroupResolvedFilters(tGroup);

		if not tResolved then
			return sOverlayScratch["canColorGroupEntries"];
		end

		if not tResolved["expressible"] then
			tHasListSpell = false;

			if (tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER) == VUHDO_AURA_GROUP_TYPE_LIST and tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM and tGroup["entries"] then
				for _, tEntry in ipairs(tGroup["entries"]) do
					if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL and tEntry["value"] then
						tHasListSpell = true;

						break;
					end
				end
			end

			if not tHasListSpell then
				return sOverlayScratch["canColorGroupEntries"];
			end
		end

		tFilterString = tResolved["filterString"];

		tCandidateFilters = VUHDO_copyOverlayCandidateFilters(tResolved["candidateFilters"], nil);

		if tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM and aCanColorGroup["customColor"] then
			tOverlayEntry = {
				["filterString"] = tFilterString,
				["candidateFilters"] = tCandidateFilters,
				["shape"] = aOverlayTarget["shape"],
				["bouquetIdx"] = aBouquetIdx,
				["groupKey"] = tGroupId,
				["shadowValueMode"] = aShadowValueMode,
				["staticColor"] = VUHDO_applyOverlayStaticColorBright(aCanColorGroup["customColor"], aItem, aBaseProduct),
			};

			VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

			sOverlayScratch["canColorGroupEntries"][#sOverlayScratch["canColorGroupEntries"] + 1] = tOverlayEntry;
		elseif tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
			tDispelTypeNames = VUHDO_getPlayerDispelBarColorTypeNames();

			if next(tDispelTypeNames) ~= nil then
				tOverlayEntry = {
					["filterString"] = tFilterString,
					["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
					["shape"] = aOverlayTarget["shape"],
					["bouquetIdx"] = aBouquetIdx,
					["groupKey"] = tGroupId,
					["shadowValueMode"] = aShadowValueMode,
					["friendlyOnly"] = true,
				};

				if tFilterString and not strfind(tFilterString, "|RAID", 1, true) then
					tOverlayEntry["filterString"] = tFilterString .. "|RAID";
				end

				if aOverlayTarget["shape"] == "bar" then
					tOverlayEntry["dispelFill"] = true;
				elseif aOverlayTarget["shape"] == "border" then
					tOverlayEntry["dispelBorder"] = true;
				elseif aOverlayTarget["shape"] == "dot" then
					tOverlayEntry["dispelIcon"] = true;

					VUHDO_applyOverlayDotIconFields(tOverlayEntry, aItem, nil);
				end

				tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
				tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

				VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

				sOverlayScratch["canColorGroupEntries"][#sOverlayScratch["canColorGroupEntries"] + 1] = tOverlayEntry;
			end

			tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getPlayerPurgeBarColorTypeNames(), aOverlayTarget, aBouquetIdx, tGroupId, aShadowValueMode, aItem, aBaseProduct, true, false);

			if tHostileEntry then
				sOverlayScratch["canColorGroupEntries"][#sOverlayScratch["canColorGroupEntries"] + 1] = tHostileEntry;
			end
		elseif tEffectiveColorType == VUHDO_AURA_GROUP_COLOR_ALL_DISPEL then
			tDispelTypeNames = VUHDO_getAllDispelBarColorTypeNames();

			if next(tDispelTypeNames) ~= nil then
				tOverlayEntry = {
					["filterString"] = tFilterString,
					["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(tCandidateFilters, tDispelTypeNames),
					["shape"] = aOverlayTarget["shape"],
					["bouquetIdx"] = aBouquetIdx,
					["groupKey"] = tGroupId,
					["shadowValueMode"] = aShadowValueMode,
					["friendlyOnly"] = true,
				};

				if aOverlayTarget["shape"] == "bar" then
					tOverlayEntry["dispelFill"] = true;
				elseif aOverlayTarget["shape"] == "border" then
					tOverlayEntry["dispelBorder"] = true;
				elseif aOverlayTarget["shape"] == "dot" then
					tOverlayEntry["dispelIcon"] = true;

					VUHDO_applyOverlayDotIconFields(tOverlayEntry, aItem, nil);
				end

				tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(aItem);
				tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(aItem, aBaseProduct);

				VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, aOverlayTarget);

				sOverlayScratch["canColorGroupEntries"][#sOverlayScratch["canColorGroupEntries"] + 1] = tOverlayEntry;
			end

			tHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getAllDispelBarColorTypeNames(), aOverlayTarget, aBouquetIdx, tGroupId, aShadowValueMode, aItem, aBaseProduct, true, false);

			if tHostileEntry then
				sOverlayScratch["canColorGroupEntries"][#sOverlayScratch["canColorGroupEntries"] + 1] = tHostileEntry;
			end
		end

		return sOverlayScratch["canColorGroupEntries"];

	end



	--
	local tAuraGroupId;
	local tAuraGroup;
	local tResolved;
	local tEffectiveColorType;
	local function VUHDO_buildAuraGroupActiveOverlayEntries(aItem, aOverlayTarget, aBouquetIdx, aShadowValueMode, aBaseProduct)

		twipe(sOverlayScratch["auraGroupEntries"]);

		tAuraGroupId = aItem["custom"] and aItem["custom"]["auraGroupId"];
		tAuraGroup = VUHDO_getAuraGroup(tAuraGroupId);

		tResolved = VUHDO_getAuraGroupResolvedFilters(tAuraGroup);

		if not tAuraGroup or not tResolved or not tResolved["expressible"] then
			return sOverlayScratch["auraGroupEntries"];
		end

		tEffectiveColorType = tAuraGroup["colorType"] or VUHDO_AURA_GROUP_COLOR_OFF;

		return VUHDO_buildAuraGroupOverlayEntries(tAuraGroup, tAuraGroupId, tEffectiveColorType, tAuraGroup["customColor"], aItem, aOverlayTarget, aBouquetIdx, aShadowValueMode, aBaseProduct);

	end



	--
	local tBarColors;
	function VUHDO_isBarColorsDispelOverlayConfigured()

		tBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

		return tBarColors and tBarColors["showDispelOverlay"] and (tBarColors["dispelIndicatorType"] or 1) > 0;

	end



	--
	local tBarColors;
	local tDispelIndicatorType;
	local tFilterString;
	local tCandidateFilters;
	local tDispelTypeNames;
	function VUHDO_buildBarColorsDispelOverlayEntry()

		tBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

		if not tBarColors or not tBarColors["showDispelOverlay"] then
			return nil;
		end

		tDispelIndicatorType = tBarColors["dispelIndicatorType"] or 1;

		if tDispelIndicatorType <= 0 then
			return nil;
		end

		if tDispelIndicatorType == 2 then
			tFilterString = "HARMFUL|DISPELLABLE";
			tDispelTypeNames = VUHDO_getAllDispelTypeNames();
		else
			tFilterString = "HARMFUL|RAID_PLAYER_DISPELLABLE";
			tDispelTypeNames = VUHDO_getPlayerDispelTypeNames();
		end

		tCandidateFilters = VUHDO_copyOverlayCandidateFilters(nil, tDispelTypeNames);

		return {
			["filterString"] = tFilterString,
			["candidateFilters"] = tCandidateFilters,
			["shape"] = "bar",
			["entryKey"] = "barColorsDispelOverlay",
			["frameLevelOffset"] = 8,
			["friendlyOnly"] = true,
			["dispelOverlayChrome"] = true,
			["templateName"] = VUHDO_AURA_BUTTON_DISPEL_OVERLAY_TEMPLATE,
		};

	end



	--
	local tOverlayTarget;
	local tGetter;
	function VUHDO_resolveOverlayTarget(aButton, anIndicatorKey)

		tOverlayTarget = VUHDO_INDICATOR_OVERLAY_TARGETS[anIndicatorKey];

		if not tOverlayTarget then
			return nil;
		end

		tGetter = _G[tOverlayTarget["getter"]];

		if tOverlayTarget["ofBar"] then
			return tGetter(VUHDO_getHealthBar(aButton, tOverlayTarget["barIndex"]));
		elseif tOverlayTarget["barIndex"] then
			return tGetter(aButton, tOverlayTarget["barIndex"]);
		elseif tOverlayTarget["iconIndex"] then
			return tGetter(aButton, tOverlayTarget["iconIndex"]);
		end

		return tGetter(aButton);

	end



	--
	local tOverlayClaimFlags;
	local function VUHDO_getOverlayFilterFlags(aFilterString)

		if not aFilterString then
			return nil;
		end

		tOverlayClaimFlags = sOverlayFilterFlagsCache[aFilterString];

		if tOverlayClaimFlags then
			return tOverlayClaimFlags;
		end

		tOverlayClaimFlags = { };

		for tOverlayClaimFlag in string.gmatch(aFilterString, "[^|]+") do
			tOverlayClaimFlags[tOverlayClaimFlag] = true;
		end

		sOverlayFilterFlagsCache[aFilterString] = tOverlayClaimFlags;

		return tOverlayClaimFlags;

	end



	--
	local tOverlayClaimFlags;
	local tOverlayEntryFlags;
	local function VUHDO_isOverlayFilterSubset(aClaimFilterString, anEntryFilterString)

		tOverlayClaimFlags = VUHDO_getOverlayFilterFlags(aClaimFilterString);
		tOverlayEntryFlags = VUHDO_getOverlayFilterFlags(anEntryFilterString);

		if not tOverlayClaimFlags or not tOverlayEntryFlags then
			return false;
		end

		for tOverlayClaimFlag in pairs(tOverlayClaimFlags) do
			if not tOverlayEntryFlags[tOverlayClaimFlag] then
				return false;
			end
		end

		return true;

	end



	--
	local function VUHDO_isOverlayEntryClaimCompatible(aClaim, anEntry)

		if not VUHDO_isOverlayFilterSubset(aClaim["filterString"], anEntry["filterString"]) then
			return false;
		end

		if aClaim["hostileOnly"] and not anEntry["hostileOnly"] then
			return false;
		end

		if aClaim["friendlyOnly"] and not anEntry["friendlyOnly"] then
			return false;
		end

		return true;

	end



	--
	local tOverlayClaims;
	local tOverlayFilteredEntries;
	local tOverlayCandidateFilters;
	local tOverlayClaim;
	local tOverlayEntrySpellIds;
	local tOverlayIsFullyCovered;
	local tOverlayEntry;
	local tSuppressResult;
	local function VUHDO_suppressOverlayEntriesClaimedByHigherPriority(anOverlayEntries)

		if not anOverlayEntries or #anOverlayEntries <= 1 then
			return anOverlayEntries;
		end

		twipe(sOverlayScratch["overlayClaims"]);
		twipe(sOverlayScratch["overlayFilteredEntries"]);

		tOverlayClaims = sOverlayScratch["overlayClaims"];
		tOverlayFilteredEntries = sOverlayScratch["overlayFilteredEntries"];

		for tCnt = 1, #anOverlayEntries do
			tOverlayEntry = anOverlayEntries[tCnt];
			tOverlayCandidateFilters = tOverlayEntry["candidateFilters"];
			tOverlayEntrySpellIds = tOverlayCandidateFilters and tOverlayCandidateFilters["includeSpellIDs"];

			tOverlayIsFullyCovered = false;

			if tOverlayEntrySpellIds then
				tOverlayIsFullyCovered = true;

				for tOverlaySpellId in pairs(tOverlayEntrySpellIds) do
					tOverlayClaim = nil;

					for tOverlayClaimCnt = 1, #tOverlayClaims do
						if tOverlayClaims[tOverlayClaimCnt]["spellIds"][tOverlaySpellId] and VUHDO_isOverlayEntryClaimCompatible(tOverlayClaims[tOverlayClaimCnt], tOverlayEntry) then
							tOverlayClaim = tOverlayClaims[tOverlayClaimCnt];

							break;
						end
					end

					if not tOverlayClaim then
						tOverlayIsFullyCovered = false;

						break;
					end
				end
			end

			if not tOverlayIsFullyCovered then
				tOverlayFilteredEntries[#tOverlayFilteredEntries + 1] = tOverlayEntry;

				if tOverlayEntrySpellIds then
					tOverlayClaims[#tOverlayClaims + 1] = {
						["filterString"] = tOverlayEntry["filterString"],
						["hostileOnly"] = tOverlayEntry["hostileOnly"],
						["friendlyOnly"] = tOverlayEntry["friendlyOnly"],
						["spellIds"] = tOverlayEntrySpellIds,
					};
				end
			end
		end

		if #tOverlayFilteredEntries == 0 then
			return nil;
		end

		if #tOverlayFilteredEntries == #anOverlayEntries then
			return anOverlayEntries;
		end

		tSuppressResult = { };

		for tCnt = 1, #tOverlayFilteredEntries do
			tSuppressResult[tCnt] = tOverlayFilteredEntries[tCnt];
		end

		return tSuppressResult;

	end



	--
	local function VUHDO_getOverlaySpellFilterString(aItem)

		if aItem["mine"] ~= false and aItem["others"] ~= true then
			return "HELPFUL|PLAYER";
		end

		if aItem["others"] == true and aItem["mine"] == false then
			return "HELPFUL|!PLAYER";
		end

		return "HELPFUL";

	end



	--
	local tBouquet;
	local tGroupEntries;
	local tItem;
	local tSpecial;
	local tShadowValueMode;
	local tGateValidators;
	local tSecretType;
	local tCanColorBarGroups;
	local tDispelName;
	local tSpellId;
	local tIncludeSpellIds;
	local tColor;
	local tBaseOpacityProduct;
	local tPrototypeCacheKey;
	local tHadDebuffBarColorEmptyGroups;
	local tOverlayTarget;
	local tOverlayEntries;
	local tOverlayEntry;
	function VUHDO_buildOverlayEntryPrototypes(aPanelNum, anIndicatorKey, aBouquetName)

		if not aBouquetName or aBouquetName == "" then
			return nil;
		end

		tPrototypeCacheKey = aPanelNum .. ":" .. anIndicatorKey .. ":" .. aBouquetName;

		if sOverlayEntryPrototypeCache[tPrototypeCacheKey] and sOverlayEntryPrototypeCache[tPrototypeCacheKey]["generation"] == sOverlayConfigGeneration then
			return sOverlayEntryPrototypeCache[tPrototypeCacheKey]["prototypes"];
		end

		tOverlayTarget = VUHDO_INDICATOR_OVERLAY_TARGETS[anIndicatorKey];

		if not tOverlayTarget then
			return nil;
		end

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet then
			return nil;
		end

		tBouquet = VUHDO_decompressIfCompressed(tBouquet);
		VUHDO_BOUQUETS["STORED"][aBouquetName] = tBouquet;

		tBaseOpacityProduct = VUHDO_computeOverlayBaseOpacityProduct(tBouquet);

		tOverlayEntries = nil;
		tHadDebuffBarColorEmptyGroups = false;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];
			tOverlayEntry = nil;

			tShadowValueMode, tGateValidators = VUHDO_resolveOverlayShadowValueMode(tBouquet, tCnt, tOverlayTarget);

			if tSpecial then
				tSecretType = tSpecial["secretType"] or 0;

				if tSpecial["custom_type"] == VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP then
					tGroupEntries = VUHDO_buildAuraGroupActiveOverlayEntries(tItem, tOverlayTarget, tCnt, tShadowValueMode, tBaseOpacityProduct);

					for _, tOverlayEntry in ipairs(tGroupEntries) do
						if not tOverlayEntries then
							tOverlayEntries = { };
						end

						tOverlayEntry["entryKey"] = tCnt .. ":group:" .. (tOverlayEntry["groupKey"] or "aura");

						if tOverlayEntry["hostileOnly"] then
							tOverlayEntry["entryKey"] = tOverlayEntry["entryKey"] .. ":hostile";
						elseif tOverlayEntry["friendlyOnly"] then
							tOverlayEntry["entryKey"] = tOverlayEntry["entryKey"] .. ":friendly";
						end

						VUHDO_appendOverlayEntryWithVariants(tOverlayEntries, tOverlayEntry, tShadowValueMode, tGateValidators);
					end

					tOverlayEntry = nil;
				elseif tItem["name"] == "DEBUFF_BAR_COLOR" then
					tCanColorBarGroups = VUHDO_getCanColorBarGroups();

					if #tCanColorBarGroups == 0 then
						tHadDebuffBarColorEmptyGroups = true;
					end

					for tGroupCnt = 1, #tCanColorBarGroups do
						tGroupEntries = VUHDO_buildCanColorBarGroupOverlayEntries(tCanColorBarGroups[tGroupCnt], tItem, tOverlayTarget, tCnt, tShadowValueMode, tBaseOpacityProduct);

						for _, tOverlayEntry in ipairs(tGroupEntries) do
							if not tOverlayEntries then
								tOverlayEntries = { };
							end

							tOverlayEntry["entryKey"] = tCnt .. ":group:" .. (tOverlayEntry["groupKey"] or tGroupCnt);

							if tOverlayEntry["hostileOnly"] then
								tOverlayEntry["entryKey"] = tOverlayEntry["entryKey"] .. ":hostile";
							elseif tOverlayEntry["friendlyOnly"] then
								tOverlayEntry["entryKey"] = tOverlayEntry["entryKey"] .. ":friendly";
							end

							VUHDO_appendOverlayEntryWithVariants(tOverlayEntries, tOverlayEntry, tShadowValueMode, tGateValidators);
						end
					end

					tOverlayEntry = nil;
				elseif tSecretType == VUHDO_SECRET_TYPE_DISPEL then
					if tSpecial["debuffType"] then
						tDispelName = sDebuffTypeDispelName[tSpecial["debuffType"]];

						if tDispelName and VUHDO_getBackgroundDispelTypeNames()[tDispelName] then
							tOverlayEntry = {
								["filterString"] = sDispelNameHostile[tDispelName] and "HELPFUL" or "HARMFUL",
								["candidateFilters"] = {
									["includeDispelTypes"] = {
										[tDispelName] = true,
									},
								},
								["shape"] = tOverlayTarget["shape"],
								["bouquetIdx"] = tCnt,
								["shadowValueMode"] = tShadowValueMode,
								["entryKey"] = tCnt .. ":dispel:" .. tDispelName,
							};

							if sDispelNameHostile[tDispelName] then
								tOverlayEntry["hostileOnly"] = true;
							else
								tOverlayEntry["friendlyOnly"] = true;
							end

							if tOverlayTarget["shape"] == "bar" then
								tOverlayEntry["dispelFill"] = true;

								VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, tOverlayTarget);
							elseif tOverlayTarget["shape"] == "border" then
								tOverlayEntry["dispelBorder"] = true;
							elseif tOverlayTarget["shape"] == "dot" then
								VUHDO_applyOverlayDotIconFields(tOverlayEntry, tItem, VUHDO_applyOverlayStaticColorBright(tItem["color"], tItem, tBaseOpacityProduct));
							end

							tOverlayEntry["dispelBright"] = VUHDO_getOverlayItemDispelBright(tItem);
							tOverlayEntry["dispelOpacity"] = VUHDO_getOverlayItemDispelOpacity(tItem, tBaseOpacityProduct);
						end
					end
				end
			else
				tIncludeSpellIds = { };

				VUHDO_addResolvedAuraContainerSpellIds(tIncludeSpellIds, tItem["name"]);
				tColor = tItem["color"];

				if next(tIncludeSpellIds) and tColor and tColor["useBackground"] then
					tSpellId = VUHDO_resolveAuraContainerSpellId(tItem["name"]);

					tOverlayEntry = {
						["filterString"] = VUHDO_getOverlaySpellFilterString(tItem),
						["candidateFilters"] = {
							["includeSpellIDs"] = tIncludeSpellIds,
						},
						["staticColor"] = VUHDO_applyOverlayStaticColorBright(tColor, tItem, tBaseOpacityProduct),
						["shape"] = tOverlayTarget["shape"],
						["bouquetIdx"] = tCnt,
						["shadowValueMode"] = tShadowValueMode,
						["friendlyOnly"] = true,
						["entryKey"] = tCnt .. ":spell:" .. tSpellId .. ":friendly",
					};

					if tOverlayTarget["shape"] == "bar" then
						VUHDO_applyOverlayShapePrototypeFields(tOverlayEntry, tOverlayTarget);
					elseif tOverlayTarget["shape"] == "dot" then
						VUHDO_applyOverlayDotIconFields(tOverlayEntry, tItem, tOverlayEntry["staticColor"]);
					elseif tOverlayTarget["shape"] == "border" then
						tOverlayEntry["border"] = true;
					end
				end
			end

			if tOverlayEntry then
				if not tOverlayEntries then
					tOverlayEntries = { };
				end

				if not tOverlayEntry["entryKey"] then
					tOverlayEntry["entryKey"] = tCnt .. ":item";
				end

				VUHDO_appendOverlayEntryWithVariants(tOverlayEntries, tOverlayEntry, tShadowValueMode, tGateValidators);
			end
		end

		if not tOverlayEntries then
			if not tHadDebuffBarColorEmptyGroups then
				sOverlayEntryPrototypeCache[tPrototypeCacheKey] = {
					["generation"] = sOverlayConfigGeneration,
					["prototypes"] = nil,
				};
			end

			return nil;
		end

		tOverlayEntries = VUHDO_suppressOverlayEntriesClaimedByHigherPriority(tOverlayEntries);

		if not tOverlayEntries then
			if not tHadDebuffBarColorEmptyGroups then
				sOverlayEntryPrototypeCache[tPrototypeCacheKey] = {
					["generation"] = sOverlayConfigGeneration,
					["prototypes"] = nil,
				};
			end

			return nil;
		end

		for tCnt = #tOverlayEntries, 1, -1 do
			tOverlayEntry = tOverlayEntries[tCnt];

			if tOverlayEntry["shape"] ~= "bar" then
				tOverlayEntry["frameLevelOffset"] = 1 + (#tOverlayEntries - tCnt);
			end
		end

		sOverlayEntryPrototypeCache[tPrototypeCacheKey] = {
			["generation"] = sOverlayConfigGeneration,
			["prototypes"] = tOverlayEntries,
		};

		return tOverlayEntries;

	end



	--
	local tOverlayTarget;
	local tOverlayEntries;
	local tOverlayEntry;
	local tBarButtonSetup;
	local tBorderButtonSetup;
	local tSlotCount;
	function VUHDO_stampOverlayEntriesFromPrototypes(aPrototypes, aPanelNum, anIndicatorKey, aButton, aTargetFrame)

		if not aPrototypes or not aTargetFrame then
			return nil;
		end

		tOverlayTarget = VUHDO_INDICATOR_OVERLAY_TARGETS[anIndicatorKey];

		if not tOverlayTarget then
			return nil;
		end

		VUHDO_resetOverlaySublevelAllocator(aTargetFrame);

		tBarButtonSetup = nil;
		tBorderButtonSetup = nil;

		if tOverlayTarget["shape"] == "bar" then
			tBarButtonSetup = VUHDO_getOverlayBarButtonSetup(aPanelNum, anIndicatorKey, aTargetFrame, aButton);
		elseif tOverlayTarget["shape"] == "border" then
			tBorderButtonSetup = VUHDO_getOverlayBorderButtonSetup(aPanelNum, anIndicatorKey);
		end

		twipe(sOverlayScratch["stampedEntries"]);

		for tCnt = 1, #aPrototypes do
			tOverlayEntry = { };

			for tCopyKey, tCopyValue in pairs(aPrototypes[tCnt]) do
				tOverlayEntry[tCopyKey] = tCopyValue;
			end

			VUHDO_stampOverlayEntryShapeFields(tOverlayEntry, tOverlayTarget, tBarButtonSetup, tBorderButtonSetup);

			if tOverlayEntry["shape"] == "bar" and tOverlayEntry["shadowBar"] then
				tSlotCount = 2;
			else
				tSlotCount = 1;
			end

			tOverlayEntry["sublevelSlots"] = VUHDO_allocateOverlaySublevels(aTargetFrame, tSlotCount, anIndicatorKey);

			if tOverlayEntry["auraGroupBarGlow"] then
				tOverlayEntry["unitButton"] = aButton;
			end

			sOverlayScratch["stampedEntries"][#sOverlayScratch["stampedEntries"] + 1] = tOverlayEntry;
		end

		return sOverlayScratch["stampedEntries"];

	end



	--
	function VUHDO_buildOverlayEntries(aPanelNum, anIndicatorKey, aBouquetName, aButton, aTargetFrame)

		tOverlayEntries = VUHDO_buildOverlayEntryPrototypes(aPanelNum, anIndicatorKey, aBouquetName);

		if not tOverlayEntries then
			return nil;
		end

		return VUHDO_stampOverlayEntriesFromPrototypes(tOverlayEntries, aPanelNum, anIndicatorKey, aButton, aTargetFrame);

	end

end



do
	--
	local function VUHDO_resolveOverlayLevelFrame(aTargetFrame)

		if aTargetFrame:IsObjectType("Frame") then
			return aTargetFrame;
		end

		return aTargetFrame:GetParent();

	end



	--
	local tLevelFrame;
	local function VUHDO_buildOverlayButtonSetup(aTargetFrame, anOverlayEntry)

		tLevelFrame = VUHDO_resolveOverlayLevelFrame(aTargetFrame);

		return {
			["staticColor"] = anOverlayEntry["staticColor"],
			["iconColor"] = anOverlayEntry["iconColor"],
			["dispelBorder"] = anOverlayEntry["dispelBorder"],
			["shadowBar"] = anOverlayEntry["shadowBar"],
			["dispelFill"] = anOverlayEntry["dispelFill"],
			["dispelIcon"] = anOverlayEntry["dispelIcon"],
			["dispelBright"] = anOverlayEntry["dispelBright"],
			["dispelOpacity"] = anOverlayEntry["dispelOpacity"],
			["shadowValueMode"] = anOverlayEntry["shadowValueMode"],
			["barTexture"] = anOverlayEntry["barTexture"],
			["barOrientation"] = anOverlayEntry["barOrientation"],
			["barInverted"] = anOverlayEntry["barInverted"],
			["occlusionColor"] = anOverlayEntry["occlusionColor"],
			["sublevelSlots"] = anOverlayEntry["sublevelSlots"],
			["border"] = anOverlayEntry["border"],
			["borderWidth"] = anOverlayEntry["borderWidth"],
			["borderFile"] = anOverlayEntry["borderFile"],
			["staticIcon"] = anOverlayEntry["staticIcon"],
			["iconTexCoords"] = anOverlayEntry["iconTexCoords"],
			["targetBar"] = aTargetFrame,
			["targetFrameLevel"] = tLevelFrame:GetFrameLevel(),
			["hideIcon"] = not anOverlayEntry["dispelOverlayChrome"] and (anOverlayEntry["hideIcon"] or anOverlayEntry["glowIcon"] or anOverlayEntry["shape"] == "bar" or anOverlayEntry["shape"] == "glow"),
			["disableMouse"] = true,
			["glowIcon"] = anOverlayEntry["glowIcon"],
			["glowColor"] = anOverlayEntry["glowColor"],
			["glowStyle"] = anOverlayEntry["glowStyle"],
			["glowColorType"] = anOverlayEntry["glowColorType"],
			["auraGroupBarGlow"] = anOverlayEntry["auraGroupBarGlow"],
			["unitButton"] = anOverlayEntry["unitButton"],
			["dispelOverlayChrome"] = anOverlayEntry["dispelOverlayChrome"],
			["width"] = aTargetFrame:GetWidth(),
			["height"] = anOverlayEntry["height"] or aTargetFrame:GetHeight(),
		};

	end



	--
	local tResolveContainerParent;
	local tResolveOverlayHostFrame;
	local tResolveFrameLevelOffset;
	local tResolveLevelFrame;
	local function VUHDO_resolveOverlayContainerAnchorFields(aButton, aTargetFrame, aFrameLevelOffsetAddend)

		tResolveLevelFrame = VUHDO_resolveOverlayLevelFrame(aTargetFrame);

		tResolveOverlayHostFrame = VUHDO_getOverlayHostFrame(aTargetFrame);
		tResolveContainerParent = (tResolveOverlayHostFrame and tResolveOverlayHostFrame:GetName() and tResolveOverlayHostFrame) or (((aTargetFrame and aTargetFrame:GetName()) and aTargetFrame) or aButton);
		tResolveFrameLevelOffset = (tResolveLevelFrame["addLevel"] or 0) + (aFrameLevelOffsetAddend or 1);

		return tResolveContainerParent, tResolveOverlayHostFrame, tResolveFrameLevelOffset;

	end



	--
	local tButtonSetup;
	local tGroupTemplate;
	local tContainerParent;
	local tFrameLevelOffset;
	local tOverlayHostFrame;
	function VUHDO_buildOverlayContainerTemplate(aButton, aTargetFrame, anOverlayEntry, anOverlayKey)

		tButtonSetup = VUHDO_buildOverlayButtonSetup(aTargetFrame, anOverlayEntry);

		tGroupTemplate = {
			["key"] = anOverlayKey or "overlay",
			["filterString"] = anOverlayEntry["filterString"],
			["candidateFilters"] = anOverlayEntry["candidateFilters"],
			["templateName"] = anOverlayEntry["templateName"] or VUHDO_AURA_BUTTON_OVERLAY_TEMPLATE,
			["buttonSetup"] = tButtonSetup,
			["maxFrameCount"] = 1,
			["layout"] = {
				["elementWidth"] = tButtonSetup["width"],
				["elementHeight"] = tButtonSetup["height"],
				["elementSpacing"] = 0,
				["lineSpacing"] = 0,
			},
		};

		tContainerParent, tOverlayHostFrame, tFrameLevelOffset = VUHDO_resolveOverlayContainerAnchorFields(aButton, aTargetFrame, anOverlayEntry["frameLevelOffset"] or 1);

		return {
			["parent"] = tContainerParent,
			["anchor"] = {
				["mode"] = "cover",
				["target"] = tOverlayHostFrame or aTargetFrame,
				["levelBase"] = aButton,
				["frameLevelOffset"] = tFrameLevelOffset,
			},
			["isOverlay"] = true,
			["overlayTargetBar"] = aTargetFrame,
			["overlayHostFrame"] = tOverlayHostFrame,
			["groups"] = { tGroupTemplate },
		};

	end



	--
	local tChainGroups;
	local tChainGroupMeta;
	local tChainFillEntry;
	local tChainEntryKey;
	local tChainGroupTemplate;
	local tChainButtonSetup;
	local tChainLayoutIndex;
	local tContainerParent;
	local tFrameLevelOffset;
	local tOverlayHostFrame;
	function VUHDO_buildOverlayChainContainerTemplate(aButton, aTargetFrame, aFillEntries, anIndicatorKey)

		tChainGroups = { };
		tChainGroupMeta = { };

		for tChainIdx = 1, #aFillEntries do
			tChainFillEntry = aFillEntries[tChainIdx];
			tChainEntryKey = tChainFillEntry["entryKey"] or tChainFillEntry["bouquetIdx"] or tChainIdx;

			tChainButtonSetup = VUHDO_buildOverlayButtonSetup(aTargetFrame, tChainFillEntry);
			tChainLayoutIndex = #tChainGroups + 1;

			tChainGroupTemplate = {
				["key"] = "chain_" .. tChainEntryKey,
				["filterString"] = tChainFillEntry["filterString"],
				["candidateFilters"] = tChainFillEntry["candidateFilters"],
				["templateName"] = tChainFillEntry["templateName"] or VUHDO_AURA_BUTTON_OVERLAY_TEMPLATE,
				["buttonSetup"] = tChainButtonSetup,
				["maxFrameCount"] = 1,
				["layout"] = {
					["elementWidth"] = tChainButtonSetup["width"],
					["elementHeight"] = tChainButtonSetup["height"],
					["elementSpacing"] = 0,
					["lineSpacing"] = 0,
					["forceNewLine"] = true,
					["layoutIndex"] = tChainLayoutIndex,
				},
			};

			tChainGroups[#tChainGroups + 1] = tChainGroupTemplate;

			tChainGroupMeta[#tChainGroupMeta + 1] = {
				["entryKey"] = tChainEntryKey,
				["filterString"] = tChainFillEntry["filterString"],
				["candidateFilters"] = tChainFillEntry["candidateFilters"],
				["friendlyOnly"] = tChainFillEntry["friendlyOnly"],
				["hostileOnly"] = tChainFillEntry["hostileOnly"],
				["alwaysEnabled"] = tChainFillEntry["alwaysEnabled"],
				["staticColor"] = tChainFillEntry["staticColor"],
				["bouquetIdx"] = tChainFillEntry["bouquetIdx"],
			};
		end

		tContainerParent, tOverlayHostFrame, tFrameLevelOffset = VUHDO_resolveOverlayContainerAnchorFields(aButton, aTargetFrame, 1);

		return {
			["parent"] = tContainerParent,
			["anchor"] = {
				["mode"] = "topEdge",
				["target"] = tOverlayHostFrame or aTargetFrame,
				["levelBase"] = aButton,
				["frameLevelOffset"] = tFrameLevelOffset,
			},
			["isOverlay"] = true,
			["isFillChain"] = true,
			["chainHasBaseline"] = anIndicatorKey == "BACKGROUND_BAR",
			["overlayTargetBar"] = aTargetFrame,
			["overlayHostFrame"] = tOverlayHostFrame,
			["groups"] = tChainGroups,
		}, tChainGroupMeta;

	end



	--
	local tPendingKey;
	function VUHDO_enqueueOverlayContainerBuild(aButton, anIndicatorKey, anEntryKey, aContainerTemplate, anOverlayEntry, aChainGroupMeta)

		if not sPendingOverlayBuilds[aButton] then
			sPendingOverlayBuilds[aButton] = {
				["generation"] = sOverlayConfigGeneration,
				["pendingCount"] = 0,
				["entries"] = { },
			};
		end

		tPendingKey = anIndicatorKey .. ":" .. anEntryKey;

		if not sPendingOverlayBuilds[aButton]["entries"][tPendingKey] then
			sPendingOverlayBuilds[aButton]["pendingCount"] = sPendingOverlayBuilds[aButton]["pendingCount"] + 1;
		end

		sPendingOverlayBuilds[aButton]["entries"][tPendingKey] = {
			["indicatorKey"] = anIndicatorKey,
			["entryKey"] = anEntryKey,
			["containerTemplate"] = aContainerTemplate,
			["overlayEntry"] = anOverlayEntry,
			["chainGroupMeta"] = aChainGroupMeta,
		};

		VUHDO_deferAcquireOverlayContainer(aButton, anIndicatorKey, anEntryKey);

		return;

	end
end



do
	--
	function VUHDO_markOverlayRebuildPendingInCombat()

		if VUHDO_OVERLAYS_REBUILD_PENDING then
			return;
		end

		VUHDO_OVERLAYS_REBUILD_PENDING = true;

		sOverlayConfigGeneration = sOverlayConfigGeneration + 1;

		return;

	end



	--
	local tButtonName;
	local tPendingBuild;
	local tPendingKey;
	local tPendingEntry;
	local tContainerTemplate;
	local tOverlayEntry;
	local tContainerData;
	local tUnit;
	local tChainGroupMeta;
	local tChainGroupMetaEntry;
	function VUHDO_acquireOverlayContainerForEntry(aButton, anIndicatorKey, anEntryKey)

		if not aButton or not anIndicatorKey or not anEntryKey then
			return;
		end

		tButtonName = aButton:GetName();

		if not tButtonName then
			return;
		end

		tPendingBuild = sPendingOverlayBuilds[aButton];

		if not tPendingBuild then
			return;
		end

		tPendingKey = anIndicatorKey .. ":" .. anEntryKey;
		tPendingEntry = tPendingBuild["entries"][tPendingKey];

		if not tPendingEntry then
			return;
		end

		if InCombatLockdown() then
			VUHDO_deferAcquireOverlayContainer(aButton, anIndicatorKey, anEntryKey);

			return;
		end

		tPendingBuild["entries"][tPendingKey] = nil;
		tPendingBuild["pendingCount"] = tPendingBuild["pendingCount"] - 1;

		if tPendingBuild["generation"] ~= sOverlayConfigGeneration then
			if tPendingBuild["pendingCount"] <= 0 then
				sPendingOverlayBuilds[aButton] = nil;
			end

			return;
		end

		tContainerTemplate = tPendingEntry["containerTemplate"];
		tOverlayEntry = tPendingEntry["overlayEntry"];
		tChainGroupMeta = tPendingEntry["chainGroupMeta"];

		tContainerData = VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

		if tContainerData then
			if not sStagingOverlayContainers[tButtonName] then
				sStagingOverlayContainers[tButtonName] = { };
			end

			if not sStagingOverlayContainers[tButtonName][anIndicatorKey] then
				sStagingOverlayContainers[tButtonName][anIndicatorKey] = { };
			end

			if tChainGroupMeta then
				tContainerData["chainGroupMeta"] = tChainGroupMeta;
				tContainerData["alwaysEnabled"] = nil;

				for tChainGroupIdx = 1, #tChainGroupMeta do
					tChainGroupMetaEntry = tChainGroupMeta[tChainGroupIdx];

					if tChainGroupMetaEntry["alwaysEnabled"] then
						tContainerData["alwaysEnabled"] = true;
					end

					if tContainerData["groupKeys"] and tContainerData["groupKeys"][tChainGroupIdx] then
						tChainGroupMetaEntry["groupKey"] = tContainerData["groupKeys"][tChainGroupIdx];
					end
				end
			elseif tOverlayEntry then
				tContainerData["friendlyOnly"] = tOverlayEntry["friendlyOnly"] or nil;
				tContainerData["hostileOnly"] = tOverlayEntry["hostileOnly"] or nil;
				tContainerData["alwaysEnabled"] = tOverlayEntry["alwaysEnabled"] or nil;
				tContainerData["valueGates"] = tOverlayEntry["valueGates"] or nil;
				tContainerData["isValueGateActiveVariant"] = tOverlayEntry["isValueGateActiveVariant"] or nil;

				tContainerData["overlayFilterString"] = tOverlayEntry["filterString"];
				tContainerData["overlayCandidateFilters"] = tOverlayEntry["candidateFilters"];
				tContainerData["overlayStaticColor"] = tOverlayEntry["staticColor"];

				if anIndicatorKey == "AURA_GROUP_BAR_GLOW" then
					tContainerData["auraGroupBarGlow"] = true;
					tContainerData["glowGroupId"] = tOverlayEntry["glowGroupId"];
					tContainerData["glowStyle"] = tOverlayEntry["glowStyle"];
					tContainerData["glowColorType"] = tOverlayEntry["glowColorType"];
					tContainerData["glowColor"] = tOverlayEntry["glowColor"];
					tContainerData["unitButton"] = aButton;
					tContainerData["glowButtonSetup"] = tContainerTemplate["groups"] and tContainerTemplate["groups"][1] and tContainerTemplate["groups"][1]["buttonSetup"];
				end
			end

			sStagingOverlayContainers[tButtonName][anIndicatorKey][anEntryKey] = tContainerData;

			if tContainerData["chainBaselineTexture"] then
				VUHDO_applyStoredChainBaselineColor(tButtonName, tContainerData);
			end

			if anIndicatorKey ~= "DISPEL_OVERLAY" then
				sHasAnyOverlays = true;
			end
		end

		if tPendingBuild["pendingCount"] <= 0 then
			sPendingOverlayBuilds[aButton] = nil;

			VUHDO_finalizeOverlayStaging(aButton);

			sOverlayConfigKeys[tButtonName] = sOverlayConfigGeneration;

			tUnit = aButton["raidid"] or aButton:GetAttribute("unit");

			if tUnit then
				VUHDO_deferSyncOverlaysForUnit(tUnit);
			end
		end

		return;

	end



	--
	local tPlannedCount;
	function VUHDO_getPendingOverlayBuildCount()

		tPlannedCount = 0;

		for _, tPendingBuild in pairs(sPendingOverlayBuilds) do
			tPlannedCount = tPlannedCount + (tPendingBuild["pendingCount"] or 0);
		end

		return tPlannedCount;

	end



	--
	function VUHDO_getOverlayBuildGateState()

		return sHasAnyOverlays, VUHDO_isAuraModeContainers(), VUHDO_isAuraDataRestricted(), VUHDO_isBarColorsDispelOverlayConfigured();

	end



	--
	function VUHDO_getOverlayConfigGeneration()

		return sOverlayConfigGeneration;

	end



	--
	function VUHDO_getOverlayBuildKeyForButton(aButtonName)

		return sOverlayConfigKeys[aButtonName];

	end



	--
	function VUHDO_invalidateOverlayBuildKeys()

		twipe(sOverlayConfigKeys);
		twipe(sOverlayEntryPrototypeCache);

		return;

	end



	--
	function VUHDO_getOverlayZeroPlanDiagnostics()

		return sOverlayZeroPlanCount, sOverlayZeroPlanLastReason;

	end



	--
	local tPrototypeCacheEntry;
	function VUHDO_getOverlayPrototypeCacheDiagnostics(aPanelNum, anIndicatorKey, aBouquetName)

		if not aPanelNum or not anIndicatorKey or not aBouquetName or aBouquetName == "" then
			return nil, nil;
		end

		tPrototypeCacheEntry = sOverlayEntryPrototypeCache[aPanelNum .. ":" .. anIndicatorKey .. ":" .. aBouquetName];

		if not tPrototypeCacheEntry then
			return nil, nil;
		end

		if tPrototypeCacheEntry["prototypes"] then
			return tPrototypeCacheEntry["generation"], #tPrototypeCacheEntry["prototypes"];
		end

		return tPrototypeCacheEntry["generation"], nil;

	end



	--
	local tButtonName;
	local tOldOverlays;
	function VUHDO_releaseStagingOverlaysForButton(aButton)

		if not aButton then
			return;
		end

		tButtonName = aButton:GetName();

		if not tButtonName or not sStagingOverlayContainers[tButtonName] then
			return;
		end

		for _, tIndicatorEntry in pairs(sStagingOverlayContainers[tButtonName]) do
			for _, tContainerData in pairs(tIndicatorEntry) do
				VUHDO_releaseAuraContainer(aButton, tContainerData);
			end
		end

		sStagingOverlayContainers[tButtonName] = nil;

		return;

	end



	--
	function VUHDO_finalizeOverlayStaging(aButton)

		if not aButton then
			return;
		end

		tButtonName = aButton:GetName();

		if not tButtonName then
			return;
		end

		tOldOverlays = VUHDO_OVERLAY_CONTAINERS[tButtonName];

		if sStagingOverlayContainers[tButtonName] then
			VUHDO_OVERLAY_CONTAINERS[tButtonName] = sStagingOverlayContainers[tButtonName];
			sStagingOverlayContainers[tButtonName] = nil;
		else
			VUHDO_OVERLAY_CONTAINERS[tButtonName] = nil;
		end

		if tOldOverlays then
			for _, tIndicatorEntry in pairs(tOldOverlays) do
				for _, tContainerData in pairs(tIndicatorEntry) do
					VUHDO_releaseAuraContainer(aButton, tContainerData);
				end
			end
		end

		return;

	end



	--
	local tButtonName;
	function VUHDO_releaseOverlaysForButton(aButton)

		if not aButton then
			return;
		end

		if InCombatLockdown() then
			VUHDO_markOverlayRebuildPendingInCombat();

			return;
		end

		tButtonName = aButton:GetName();

		sPendingOverlayBuilds[aButton] = nil;

		VUHDO_releaseStagingOverlaysForButton(aButton);

		if not tButtonName or not VUHDO_OVERLAY_CONTAINERS[tButtonName] then
			if tButtonName then
				sOverlayConfigKeys[tButtonName] = nil;
			end

			return;
		end

		for _, tIndicatorEntry in pairs(VUHDO_OVERLAY_CONTAINERS[tButtonName]) do
			for _, tContainerData in pairs(tIndicatorEntry) do
				VUHDO_releaseAuraContainer(aButton, tContainerData);
			end
		end

		VUHDO_OVERLAY_CONTAINERS[tButtonName] = nil;

		sOverlayConfigKeys[tButtonName] = nil;

		return;

	end



	--
	function VUHDO_releaseAllOverlays()

		if InCombatLockdown() then
			VUHDO_markOverlayRebuildPendingInCombat();

			return;
		end

		for _, tIndicatorEntries in pairs(VUHDO_OVERLAY_CONTAINERS) do
			for _, tIndicatorEntry in pairs(tIndicatorEntries) do
				for _, tContainerData in pairs(tIndicatorEntry) do
					VUHDO_releaseAuraContainer(nil, tContainerData);
				end
			end
		end

		twipe(VUHDO_OVERLAY_CONTAINERS);
		twipe(sStagingOverlayContainers);
		twipe(sOverlayConfigKeys);
		twipe(sPendingOverlayBuilds);
		twipe(sOverlaySublevelAllocators);
		twipe(sOverlayEntryPrototypeCache);

		sOverlayConfigGeneration = sOverlayConfigGeneration + 1;
		sHasAnyOverlays = false;

		return;

	end



	--
	function VUHDO_flushPendingOverlayRebuild()

		if not VUHDO_OVERLAYS_REBUILD_PENDING then
			return;
		end

		if InCombatLockdown() then
			return;
		end

		VUHDO_OVERLAYS_REBUILD_PENDING = false;

		VUHDO_releaseAllOverlays();

		VUHDO_resyncAuraDisplayMode(false);

		return;

	end



	--
	function VUHDO_flushPendingOverlayAcquires()

		if InCombatLockdown() then
			return;
		end

		for tFlushButton, tFlushPendingBuild in pairs(sPendingOverlayBuilds) do
			for tFlushPendingKey, tFlushPendingEntry in pairs(tFlushPendingBuild["entries"] or sEmpty) do
				VUHDO_deferAcquireOverlayContainer(tFlushButton, tFlushPendingEntry["indicatorKey"], tFlushPendingEntry["entryKey"]);
			end
		end

		return;

	end



	--
	local tBarGlowFilterEntry;
	local tBarGlowFilterString;
	local tBarGlowHostileEntry;
	local tDispelTypeNames;
	local function VUHDO_buildAuraGroupBarGlowFilterEntries(aGroupId, aColorType, aFilterString, aCandidateFilters)

		twipe(sOverlayScratch["barGlowFilterEntries"]);

		if aColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM then
			tBarGlowFilterEntry = {
				["filterString"] = aFilterString,
				["candidateFilters"] = aCandidateFilters,
				["entryKeySuffix"] = "",
			};

			sOverlayScratch["barGlowFilterEntries"][1] = tBarGlowFilterEntry;
		elseif aColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
			tBarGlowFilterString = aFilterString;

			if tBarGlowFilterString and not strfind(tBarGlowFilterString, "|RAID", 1, true) then
				tBarGlowFilterString = tBarGlowFilterString .. "|RAID";
			end

			tDispelTypeNames = VUHDO_getPlayerDispelGlowTypeNames();

			if next(tDispelTypeNames) ~= nil then
				tBarGlowFilterEntry = {
					["filterString"] = tBarGlowFilterString,
					["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(aCandidateFilters, tDispelTypeNames),
					["friendlyOnly"] = true,
					["entryKeySuffix"] = ":friendly",
				};

				sOverlayScratch["barGlowFilterEntries"][#sOverlayScratch["barGlowFilterEntries"] + 1] = tBarGlowFilterEntry;
			end

			tBarGlowHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getPlayerPurgeGlowTypeNames(), nil, nil, aGroupId, nil, nil, nil, false, true);

			if tBarGlowHostileEntry then
				sOverlayScratch["barGlowFilterEntries"][#sOverlayScratch["barGlowFilterEntries"] + 1] = tBarGlowHostileEntry;
			end
		elseif aColorType == VUHDO_AURA_GROUP_COLOR_ALL_DISPEL then
			tDispelTypeNames = VUHDO_getAllDispelGlowTypeNames();

			if next(tDispelTypeNames) ~= nil then
				tBarGlowFilterEntry = {
					["filterString"] = aFilterString,
					["candidateFilters"] = VUHDO_copyOverlayCandidateFilters(aCandidateFilters, tDispelTypeNames),
					["friendlyOnly"] = true,
					["entryKeySuffix"] = ":friendly",
				};

				sOverlayScratch["barGlowFilterEntries"][#sOverlayScratch["barGlowFilterEntries"] + 1] = tBarGlowFilterEntry;
			end

			tBarGlowHostileEntry = VUHDO_buildHostileDispelEntry(VUHDO_getAllDispelGlowTypeNames(), nil, nil, aGroupId, nil, nil, nil, false, true);

			if tBarGlowHostileEntry then
				sOverlayScratch["barGlowFilterEntries"][#sOverlayScratch["barGlowFilterEntries"] + 1] = tBarGlowHostileEntry;
			end
		end

		return sOverlayScratch["barGlowFilterEntries"];

	end



	--
	local tBarGlowFilterSpecs;
	local tBarGlowFilterSpec;
	local tBarGlowColorType;
	local tBarGlowCandidateFilters;
	local tBarGlowCanColorBarGroups;
	local tBarGlowGroup;
	local tBarGlowGroupId;
	local tBarGlowGroupData;
	local tBarGlowResolved;
	local tBarGlowColor;
	local tBarGlowDefaultColor;
	local tBarGlowEntry;
	local tBarGlowContainerTemplate;
	local tBarGlowPlannedCount;
	local tBarGlowCanBuild;
	local tBarGlowHasListSpell;
	local function VUHDO_buildAuraGroupBarGlowOverlaysForButton(aButton, aPanelNum)

		tBarGlowPlannedCount = 0;

		tBarGlowCanColorBarGroups = VUHDO_getCanColorBarGroups();

		VUHDO_resetOverlaySublevelAllocator(aButton);

		for tGroupCnt = #tBarGlowCanColorBarGroups, 1, -1 do
			tBarGlowGroup = tBarGlowCanColorBarGroups[tGroupCnt];

			if tBarGlowGroup["canGlowBar"] then
				tBarGlowGroupId = tBarGlowGroup["groupId"];
				tBarGlowGroupData = VUHDO_getAuraGroup(tBarGlowGroupId);

				tBarGlowResolved = VUHDO_getAuraGroupResolvedFilters(tBarGlowGroupData);

				if tBarGlowGroupData and tBarGlowResolved then
					tBarGlowCanBuild = tBarGlowResolved["expressible"];

					if not tBarGlowCanBuild then
						tBarGlowHasListSpell = false;
						tBarGlowColorType = tBarGlowGroup["colorType"] or VUHDO_AURA_GROUP_COLOR_DISPEL;

						if (tBarGlowGroupData["type"] or VUHDO_AURA_GROUP_TYPE_FILTER) == VUHDO_AURA_GROUP_TYPE_LIST and tBarGlowColorType == VUHDO_AURA_GROUP_COLOR_CUSTOM and tBarGlowGroupData["entries"] then
							for _, tEntry in ipairs(tBarGlowGroupData["entries"]) do
								if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL and tEntry["value"] then
									tBarGlowHasListSpell = true;

									break;
								end
							end
						end

						tBarGlowCanBuild = tBarGlowHasListSpell;
					end

					if tBarGlowCanBuild then
						tBarGlowColorType = tBarGlowGroup["colorType"] or VUHDO_AURA_GROUP_COLOR_DISPEL;

						tBarGlowCandidateFilters = VUHDO_copyOverlayCandidateFilters(tBarGlowResolved["candidateFilters"], nil);

						tBarGlowFilterSpecs = VUHDO_buildAuraGroupBarGlowFilterEntries(tBarGlowGroupId, tBarGlowColorType, tBarGlowResolved["filterString"], tBarGlowCandidateFilters);

						for tBarGlowFilterIdx = 1, #tBarGlowFilterSpecs do
							tBarGlowFilterSpec = tBarGlowFilterSpecs[tBarGlowFilterIdx];

							tBarGlowEntry = {
								["filterString"] = tBarGlowFilterSpec["filterString"],
								["candidateFilters"] = tBarGlowFilterSpec["candidateFilters"],
								["friendlyOnly"] = tBarGlowFilterSpec["friendlyOnly"],
								["hostileOnly"] = tBarGlowFilterSpec["hostileOnly"],
								["shape"] = "glow",
								["glowIcon"] = false,
								["glowStyle"] = tBarGlowGroup["glowBarStyle"] or VUHDO_DEFAULT_AURA_GLOW_STYLE,
								["glowColorType"] = tBarGlowColorType,
								["auraGroupBarGlow"] = true,
								["glowGroupId"] = tBarGlowGroupId,
								["unitButton"] = aButton,
								["hideIcon"] = true,
								["entryKey"] = "glow:" .. tBarGlowGroupId .. tBarGlowFilterSpec["entryKeySuffix"],
								["frameLevelOffset"] = 8 + (#tBarGlowCanColorBarGroups - tGroupCnt),
							};

							if tBarGlowEntry["glowColorType"] == VUHDO_AURA_GROUP_COLOR_CUSTOM then
								tBarGlowColor = tBarGlowGroup["glowBarColor"];

								if not tBarGlowColor or not tBarGlowColor["R"] then
									tBarGlowDefaultColor = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"] and VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF_BAR_GLOW"];
									tBarGlowColor = tBarGlowDefaultColor;
								end

								tBarGlowEntry["glowColor"] = tBarGlowColor;
							end

							tBarGlowEntry["sublevelSlots"] = VUHDO_allocateOverlaySublevels(aButton, 1, "AURA_GROUP_BAR_GLOW");

							tBarGlowContainerTemplate = VUHDO_buildOverlayContainerTemplate(aButton, aButton, tBarGlowEntry, "glow_" .. tBarGlowGroupId .. tBarGlowFilterSpec["entryKeySuffix"]);

							tBarGlowContainerTemplate["anchor"] = {
								["mode"] = "cover",
								["target"] = tBarGlowContainerTemplate["overlayHostFrame"] or aButton,
								["frameLevelOffset"] = tBarGlowEntry["frameLevelOffset"],
							};

							VUHDO_enqueueOverlayContainerBuild(aButton, "AURA_GROUP_BAR_GLOW", tBarGlowEntry["entryKey"], tBarGlowContainerTemplate, tBarGlowEntry);

							tBarGlowPlannedCount = tBarGlowPlannedCount + 1;
						end
					end
				end
			end
		end

		return tBarGlowPlannedCount;

	end



	--
	local tGroup;
	local tExpectsCanColorBarGroups;
	local function VUHDO_areOverlayPlanInputsUsable(aPanelNum, anBuildBouquetOverlays)

		if anBuildBouquetOverlays and not VUHDO_INDICATOR_CONFIG[aPanelNum] then
			return false;
		end

		if anBuildBouquetOverlays then
			tExpectsCanColorBarGroups = false;

			for _, tGroup in pairs(VUHDO_CONFIG["AURA_GROUPS"] or sEmpty) do
				if tGroup["enabled"] ~= false and (tGroup["canColorBar"] or tGroup["canGlowBar"]) then
					tExpectsCanColorBarGroups = true;

					break;
				end
			end

			if tExpectsCanColorBarGroups and #VUHDO_getCanColorBarGroups() == 0 then
				return false;
			end
		end

		return true;

	end



	--
	local tPendingBuild;
	local tPlannedCount;
	local tPlannedBouquetCount;
	local tBarGlowPlannedCount;
	local tBouquetName;
	local tTargetFrame;
	local tOverlayEntries;
	local tEntryKey;
	local tContainerTemplate;
	local tDispelOverlayEntry;
	local tOverlayPrototypes;
	local tChainGroupMeta;
	local tBuildBouquetOverlays;
	function VUHDO_buildOverlaysForButton(aButton, aButtonName, aPanelNum, aUnit)

		if sOverlayConfigKeys[aButtonName] == sOverlayConfigGeneration then
			return;
		end

		tPendingBuild = sPendingOverlayBuilds[aButton];

		if tPendingBuild and tPendingBuild["generation"] == sOverlayConfigGeneration then
			return;
		end

		if InCombatLockdown() then
			if VUHDO_OVERLAY_CONTAINERS[aButtonName] then
				return;
			end

			VUHDO_markOverlayRebuildPendingInCombat();

			return;
		end

		tBuildBouquetOverlays = VUHDO_isAuraModeContainers() or VUHDO_isAuraDataRestricted() or sHasAnyOverlays;

		if not VUHDO_areOverlayPlanInputsUsable(aPanelNum, tBuildBouquetOverlays) then
			return;
		end

		VUHDO_releaseStagingOverlaysForButton(aButton);
		sStagingOverlayContainers[aButtonName] = { };

		tPlannedCount = 0;
		tPlannedBouquetCount = 0;

		if tBuildBouquetOverlays and VUHDO_INDICATOR_CONFIG[aPanelNum] then
			for tIndicatorKey, _ in pairs(VUHDO_INDICATOR_OVERLAY_TARGETS) do
				tBouquetName = VUHDO_INDICATOR_CONFIG[aPanelNum]["BOUQUETS"][tIndicatorKey];

				if tBouquetName and tBouquetName ~= "" then
					tTargetFrame = VUHDO_resolveOverlayTarget(aButton, tIndicatorKey);

					if tTargetFrame then
						tOverlayPrototypes = VUHDO_buildOverlayEntryPrototypes(aPanelNum, tIndicatorKey, tBouquetName);
						tOverlayEntries = VUHDO_stampOverlayEntriesFromPrototypes(tOverlayPrototypes, aPanelNum, tIndicatorKey, aButton, tTargetFrame);

						twipe(sOverlayScratch["fillEntries"]);
						twipe(sOverlayScratch["nonFillEntries"]);

						for _, tOverlayEntry in ipairs(tOverlayEntries or sEmpty) do
							if tOverlayEntry["shadowBar"] and tOverlayEntry["shadowValueMode"] ~= "duration" then
								sOverlayScratch["fillEntries"][#sOverlayScratch["fillEntries"] + 1] = tOverlayEntry;
							else
								sOverlayScratch["nonFillEntries"][#sOverlayScratch["nonFillEntries"] + 1] = tOverlayEntry;
							end
						end

						if #sOverlayScratch["fillEntries"] > 0 and (VUHDO_isAuraModeContainers() or VUHDO_isAuraDataRestricted()) then
							tContainerTemplate, tChainGroupMeta = VUHDO_buildOverlayChainContainerTemplate(aButton, tTargetFrame, sOverlayScratch["fillEntries"], tIndicatorKey);

							VUHDO_enqueueOverlayContainerBuild(aButton, tIndicatorKey, "fillChain", tContainerTemplate, nil, tChainGroupMeta);

							tPlannedCount = tPlannedCount + 1;
							tPlannedBouquetCount = tPlannedBouquetCount + 1;
						end

						for _, tOverlayEntry in ipairs(sOverlayScratch["nonFillEntries"]) do
							tEntryKey = tOverlayEntry["entryKey"] or tOverlayEntry["bouquetIdx"];
							tContainerTemplate = VUHDO_buildOverlayContainerTemplate(aButton, tTargetFrame, tOverlayEntry, "overlay_" .. tEntryKey);

							VUHDO_enqueueOverlayContainerBuild(aButton, tIndicatorKey, tEntryKey, tContainerTemplate, tOverlayEntry);

							tPlannedCount = tPlannedCount + 1;
							tPlannedBouquetCount = tPlannedBouquetCount + 1;
						end
					end
				end
			end
		end

		tDispelOverlayEntry = VUHDO_buildBarColorsDispelOverlayEntry();

		if tDispelOverlayEntry then
			tTargetFrame = VUHDO_getHealthBar(aButton, 3);

			if tTargetFrame then
				tDispelOverlayEntry["sublevelSlots"] = VUHDO_allocateOverlaySublevels(tTargetFrame,
					tDispelOverlayEntry["shadowBar"] and 2 or 1, "DISPEL_OVERLAY");

				tDispelOverlayEntry["alwaysEnabled"] = true;

				tContainerTemplate = VUHDO_buildOverlayContainerTemplate(aButton, tTargetFrame, tDispelOverlayEntry, "barColorsDispelOverlay");

				VUHDO_enqueueOverlayContainerBuild(aButton, "DISPEL_OVERLAY", "barColorsDispelOverlay", tContainerTemplate, tDispelOverlayEntry);

				tPlannedCount = tPlannedCount + 1;
			end
		end

		if tBuildBouquetOverlays and VUHDO_INDICATOR_CONFIG[aPanelNum] then
			tBarGlowPlannedCount = VUHDO_buildAuraGroupBarGlowOverlaysForButton(aButton, aPanelNum);

			tPlannedCount = tPlannedCount + tBarGlowPlannedCount;
			tPlannedBouquetCount = tPlannedBouquetCount + tBarGlowPlannedCount;
		end

		if tPlannedCount == 0 then
			sPendingOverlayBuilds[aButton] = nil;

			VUHDO_releaseStagingOverlaysForButton(aButton);
			VUHDO_releaseOverlaysForButton(aButton);

			sOverlayConfigKeys[aButtonName] = sOverlayConfigGeneration;

			sOverlayZeroPlanCount = sOverlayZeroPlanCount + 1;
			sOverlayZeroPlanLastReason = "plannedZero";
		elseif tPlannedBouquetCount > 0 then
			sHasAnyOverlays = true;
		end

		return;

	end
end



do
	--
	function VUHDO_syncAuraGroupBarGlowOverlay(aButton, aContainerData, aWantEnabled)

		if aWantEnabled then
			if aButton["hasAuraGroupBarGlow"] then
				VUHDO_stopUnitButtonAuraGroupGlow(aButton, VUHDO_CUSTOM_GLOW_AURA_GROUP_KEY);
			end

			aButton[VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY] = true;

			return true;
		end

		if aButton[VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY] then
			VUHDO_stopUnitButtonAuraGroupGlow(aButton, VUHDO_CUSTOM_GLOW_AURA_GROUP_KEY);

			aButton[VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY] = nil;
		end

		return false;

	end



	--
	local tIsAuraDataRestricted;
	local tIsAuraModeContainers;
	local tIsBarColorsDispelOverlayConfigured;
	local tCanAttack;
	local tButtonName;
	local tPanelNum;
	local tContainer;
	local tWantEnabled;
	local tChainGroupMeta;
	local tChainGroupMetaEntry;
	local tGroupWant;
	local tGroupKey;
	local tLastSyncedGroupEnabled;
	local tUnitGlowApplied;
	local tGateInfo;
	local tGateActive;
	local tEnabledChanged;
	local tUnitRebound;
	local tOccupantGuid;
	function VUHDO_resetOverlaysForUnit(aUnit)

		if not aUnit then
			return;
		end

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			tButtonName = tButton:GetName();

			for _, tIndicatorEntry in pairs(tButtonName and VUHDO_OVERLAY_CONTAINERS[tButtonName] or sEmpty) do
				for _, tContainerData in pairs(tIndicatorEntry) do
					tContainerData["lastSyncedUnit"] = nil;
					tContainerData["lastSyncedGuid"] = nil;
					tContainerData["lastSyncedEnabled"] = nil;
					tContainerData["lastSyncedGroupEnabled"] = nil;
				end
			end
		end

		return;

	end



	--
	function VUHDO_syncOverlaysForUnit(aUnit)

		if not aUnit then
			return;
		end

		tIsAuraModeContainers = VUHDO_isAuraModeContainers();
		tIsBarColorsDispelOverlayConfigured = VUHDO_isBarColorsDispelOverlayConfigured();
		tIsAuraDataRestricted = VUHDO_isAuraDataRestricted();

		if not tIsAuraModeContainers and not tIsAuraDataRestricted and not sHasAnyOverlays and not tIsBarColorsDispelOverlayConfigured then
			return;
		end

		tCanAttack = UnitCanAttack("player", aUnit);
		tGateInfo = VUHDO_RAID and VUHDO_RAID[aUnit];

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			tButtonName = tButton:GetName();

			if tButtonName then
				tPanelNum = VUHDO_BUTTON_CACHE[tButton];

				if tPanelNum and (tIsAuraModeContainers or tIsAuraDataRestricted or sHasAnyOverlays or tIsBarColorsDispelOverlayConfigured) then
					VUHDO_buildOverlaysForButton(tButton, tButtonName, tPanelNum, aUnit);
				end

				tUnitGlowApplied = false;

				for _, tIndicatorEntry in pairs(VUHDO_OVERLAY_CONTAINERS[tButtonName] or sEmpty) do
					for _, tContainerData in pairs(tIndicatorEntry) do
						tContainer = tContainerData and tContainerData["container"];

						if tContainer then
							tChainGroupMeta = tContainerData["chainGroupMeta"];

							if tChainGroupMeta then
								tWantEnabled = false;

								if not tContainerData["lastSyncedGroupEnabled"] then
									tContainerData["lastSyncedGroupEnabled"] = { };
								end

								tLastSyncedGroupEnabled = tContainerData["lastSyncedGroupEnabled"];

								for tChainGroupIdx = 1, #tChainGroupMeta do
									tChainGroupMetaEntry = tChainGroupMeta[tChainGroupIdx];
									tGroupWant = tChainGroupMetaEntry["alwaysEnabled"] or tIsAuraDataRestricted or tIsAuraModeContainers;

									if tGroupWant and tChainGroupMetaEntry["friendlyOnly"] and tCanAttack then
										tGroupWant = false;
									end

									if tGroupWant and tChainGroupMetaEntry["hostileOnly"] and not tCanAttack then
										tGroupWant = false;
									end

									if tGroupWant then
										tWantEnabled = true;
									end

									tGroupKey = tChainGroupMetaEntry["groupKey"];

									if tGroupKey and tLastSyncedGroupEnabled[tGroupKey] ~= tGroupWant then
										if tGroupWant then
											tContainer:SetAuraGroupCandidateFilters(tGroupKey, tChainGroupMetaEntry["candidateFilters"]);
										else
											tContainer:SetAuraGroupCandidateFilters(tGroupKey, VUHDO_SUPPRESS_CANDIDATE_FILTERS);
										end

										tLastSyncedGroupEnabled[tGroupKey] = tGroupWant;
									end
								end
							else
								tWantEnabled = tContainerData["alwaysEnabled"] or tIsAuraDataRestricted or tIsAuraModeContainers;

								if tWantEnabled then
									if tContainerData["friendlyOnly"] and tCanAttack then
										tWantEnabled = false;
									end

									if tContainerData["hostileOnly"] and not tCanAttack then
										tWantEnabled = false;
									end
								end
							end

							if tWantEnabled and tContainerData["valueGates"] then
								tGateActive = VUHDO_isAnyOverlayValueGateActive(tContainerData["valueGates"], tGateInfo);

								if tGateActive ~= (tContainerData["isValueGateActiveVariant"] or false) then
									tWantEnabled = false;
								end
							end

							if tWantEnabled ~= tContainerData["lastSyncedEnabled"] then
								tEnabledChanged = true;

								tContainer:SetEnabled(tWantEnabled);
								tContainer:SetShown(tWantEnabled);

								tContainerData["lastSyncedEnabled"] = tWantEnabled;

								if tContainerData["ownsBackgroundFill"] then
									if tWantEnabled then
										if tButtonName then
											VUHDO_applyStoredChainBaselineColor(tButtonName, tContainerData);
										end

										VUHDO_hideOverlayFillChainBackgroundForData(tContainerData);
									else
										VUHDO_showOverlayFillChainBackgroundForData(tContainerData);
									end
								end
							else
								tEnabledChanged = false;
							end

							if tWantEnabled then
								tOccupantGuid = tGateInfo and tGateInfo["guid"];
								tUnitRebound = tContainerData["lastSyncedUnit"] ~= aUnit;

								if not tUnitRebound then
									if not tOccupantGuid or issecretvalue(tOccupantGuid) then
										tUnitRebound = true;
									elseif tContainerData["lastSyncedGuid"] ~= tOccupantGuid then
										tUnitRebound = true;
									end
								end

								if tUnitRebound then
									tContainer:SetUnit(aUnit);

									tContainerData["lastSyncedUnit"] = aUnit;
									tContainerData["lastSyncedGuid"] = tOccupantGuid;
								end

								if tUnitRebound or tEnabledChanged then
									VUHDO_refreshAuraContainer(tContainer);
								end
							end

							if tContainerData["auraGroupBarGlow"] then
								if VUHDO_syncAuraGroupBarGlowOverlay(tContainerData["unitButton"] or tButton, tContainerData, tWantEnabled) then
									tUnitGlowApplied = true;
								end
							end
						end
					end
				end

				if tUnitGlowApplied then
					tButton[VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY] = true;
				elseif tButton[VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY] then
					VUHDO_stopUnitButtonAuraGroupGlow(tButton, VUHDO_CUSTOM_GLOW_AURA_GROUP_KEY);

					tButton[VUHDO_AURA_GROUP_GLOW_ACTIVE_KEY] = nil;
				end
			end
		end

		return;

	end
end