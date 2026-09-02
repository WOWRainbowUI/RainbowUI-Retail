local _;

local pairs = pairs;
local ipairs = ipairs;
local next = next;
local format = string.format;
local tinsert = table.insert;
local tconcat = table.concat;
local twipe = table.wipe;

local InCombatLockdown = InCombatLockdown;
local issecretvalue = issecretvalue;
local UnitExists = UnitExists;
local UnitCanAssist = UnitCanAssist;
local UnitCanAttack = UnitCanAttack;
local UnitIsPlayerControlledOrGroupMember = UnitIsPlayerControlledOrGroupMember;
local gsub = string.gsub;

local sAuraDiagVerbose = false;
local sAuraDiagIndicator = nil;
local sAuraDiagUnit = nil;
local sAuraDiagCanApplyHelpfulIdentity = false;
local sAuraDiagCanApplyHarmfulIdentity = false;
local sAuraDiagAuraFilterRestricted = false;
local sAuraDiagDisconnected = false;

local sAuraDiagNilAllowlist = {
	["ownsBackgroundFill"] = true,
	["backgroundFillHidden"] = true,
	["lastSyncedEnabled"] = true,
};



do
	--
	local tCompactVal;
	function VUHDO_auraDiagCompactVal(aValue, aKey)

		if aValue == nil then
			if aKey and sAuraDiagNilAllowlist[aKey] then
				return "-";
			end

			return nil;
		end

		if issecretvalue(aValue) then
			return "?";
		end

		if aValue == true then
			return "1";
		end

		if aValue == false then
			return "0";
		end

		if type(aValue) == "number" then
			tCompactVal = format("%.3g", aValue);

			return tCompactVal;
		end

		return tostring(aValue);

	end
end



--
function VUHDO_auraDiagCompactRgba(aR, aG, aB, aA)

	if aR == nil and aG == nil and aB == nil and aA == nil then
		return nil;
	end

	if issecretvalue(aR) or issecretvalue(aG) or issecretvalue(aB) or issecretvalue(aA) then
		return "?";
	end

	return format("%.3g/%.3g/%.3g/%.3g", aR or 0, aG or 0, aB or 0, aA or 1);

end



--
function VUHDO_auraDiagCompactColorTable(aColor)

	if not aColor then
		return nil;
	end

	return VUHDO_auraDiagCompactRgba(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);

end



do
	--
	local tDiagR;
	local tDiagG;
	local tDiagB;
	local tDiagA;
	function VUHDO_auraDiagCompactTextureRgba(aTexture)

		if not aTexture then
			return nil;
		end

		tDiagR, tDiagG, tDiagB, tDiagA = aTexture:GetVertexColor();

		return VUHDO_auraDiagCompactRgba(tDiagR, tDiagG, tDiagB, tDiagA);

	end
end



--
function VUHDO_auraDiagCompactSize(aWidth, aHeight)

	if aWidth == nil and aHeight == nil then
		return nil;
	end

	if issecretvalue(aWidth) or issecretvalue(aHeight) then
		return "?";
	end

	return format("%.3gx%.3g", aWidth or 0, aHeight or 0);

end



do
	--
	local tAuraDiagParts;
	local tArgCount;
	local tKey;
	local tVal;
	local tCompactVal;
	function VUHDO_auraDiagLine(aPrefix, ...)

		tAuraDiagParts = { aPrefix };
		tArgCount = select("#", ...);

		for tIdx = 1, tArgCount, 2 do
			tKey = select(tIdx, ...);
			tVal = select(tIdx + 1, ...);

			if tKey then
				tCompactVal = VUHDO_auraDiagCompactVal(tVal, tKey);

				if tCompactVal ~= nil then
					tinsert(tAuraDiagParts, tKey .. "=" .. tCompactVal);
				elseif type(tVal) == "string" then
					tinsert(tAuraDiagParts, tKey .. "=" .. tVal);
				end
			end
		end

		VUHDO_MsgC(tconcat(tAuraDiagParts, " "));

		return;

	end
end



--
function VUHDO_escapeAuraDiagFilterString(aFilterString)

	if not aFilterString then
		return aFilterString;
	end

	return gsub(aFilterString, "|", "||");

end



--
function VUHDO_formatAuraDiagValue(aValue)

	if aValue == nil then
		return "-";
	end

	if issecretvalue(aValue) then
		return "?";
	end

	if aValue == true then
		return "1";
	end

	if aValue == false then
		return "0";
	end

	return tostring(aValue);

end



do
	--
	local tCandidateSpellIds;
	local tCandidateSpellIdList;
	local tCandidateDispelNames;
	local tSpellIdSummary;
	function VUHDO_auraDiagFormatCandidateSummary(aCandidateFilters, aGroupButtonSetup)

		if aGroupButtonSetup and (aGroupButtonSetup["dispelFill"] or aGroupButtonSetup["dispelIcon"]) then
			return "dispel", nil;
		end

		if not aCandidateFilters then
			return "-", nil;
		end

		tCandidateSpellIds = aCandidateFilters["includeSpellIDs"];

		if tCandidateSpellIds then
			tCandidateSpellIdList = { };

			for tSpellId, _ in pairs(tCandidateSpellIds) do
				tinsert(tCandidateSpellIdList, tSpellId);
			end

			table.sort(tCandidateSpellIdList);

			if #tCandidateSpellIdList <= 5 then
				tSpellIdSummary = { };

				for tCnt = 1, #tCandidateSpellIdList do
					tinsert(tSpellIdSummary, tostring(tCandidateSpellIdList[tCnt]));
				end

				return "spellIDs=" .. tconcat(tSpellIdSummary, ","), #tCandidateSpellIdList;
			end

			return "spellIDs=" .. #tCandidateSpellIdList, #tCandidateSpellIdList;
		end

		tCandidateDispelNames = aCandidateFilters["includeDispelTypes"];

		if tCandidateDispelNames then
			tCandidateSpellIdList = { };

			for tDispelName, _ in pairs(tCandidateDispelNames) do
				tinsert(tCandidateSpellIdList, tDispelName);
			end

			table.sort(tCandidateSpellIdList);

			return "dispel=" .. tconcat(tCandidateSpellIdList, ","), nil;
		end

		return "-", nil;

	end
end



--
function VUHDO_auraDiagMatchesIndicator(aIndicatorKey)

	if not sAuraDiagIndicator or sAuraDiagIndicator == "" then
		return true;
	end

	return string.upper(aIndicatorKey) == string.upper(sAuraDiagIndicator);

end



do
	--
	local tMixedPriorityCutoffs;
	local tSlotTemplateRefs;
	local tSlotKeys;
	local tEngineSlotCnt;
	local tTemplateRef;
	local tRecordedKey;
	local tSlotTemplate;
	local tShouldSuppress;
	local tCanAttack;
	local tSlotShouldShow;
	local tMixedEntryIndex;
	local tMixedItemIndex;
	local tPriorityCutoff;
	local tPrioritySuppress;
	local tCandidateFilters;
	local tTemplateKey;
	local tSlotFrames;
	local tSlotFrame;
	local tHasFrame;
	local tAppliedCandidateSuppress;
	local tStaticSlots;
	local tStaticSlot;
	local tStaticSlotIndex;
	local tStaticEntryIndex;
	local tStaticItemIndex;
	local tStaticFrame;
	local tStaticAlpha;
	local tStaticShown;
	local tListSlots;
	local tListSlotData;
	local tPanelNum;
	function VUHDO_dumpAuraContainerSlotDiagnostics(aButtonName, anAnchorIndex, aContainerData, aSlots, aUnit)

		tMixedPriorityCutoffs = aContainerData["mixedPriorityCutoffs"];

		if tMixedPriorityCutoffs and next(tMixedPriorityCutoffs) then
			for tCutoffEntryIndex, tCutoffItemIndex in pairs(tMixedPriorityCutoffs) do
				VUHDO_auraDiagLine("mixedPriorityCutoff",
					"button", aButtonName,
					"anchor", anAnchorIndex,
					"entry", tCutoffEntryIndex,
					"item", tCutoffItemIndex);
			end
		end

		tSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tSlotKeys = aContainerData["slotKeys"];
		tSlotFrames = aContainerData["slotFrames"];

		if tSlotTemplateRefs and aSlots then
			tEngineSlotCnt = 0;

			for tSlotIndex, tSlot in ipairs(aSlots) do
				if tSlot and not tSlot["isStaticBouquetSlot"] then
					tEngineSlotCnt = tEngineSlotCnt + 1;
					tTemplateRef = tSlotTemplateRefs[tEngineSlotCnt];
					tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

					if tTemplateRef and tRecordedKey then
						tSlotTemplate = tTemplateRef["template"];
						tTemplateKey = tSlotTemplate and tSlotTemplate["key"];
						tShouldSuppress = VUHDO_isAuraDisplaySuppressed(tTemplateRef);
						tCanAttack = VUHDO_AURA_CONTAINER_GATE_STATE["canAttack"];
						tSlotShouldShow = not tShouldSuppress;

						if tSlotTemplate and tSlotTemplate["friendlyOnly"] and tCanAttack then
							tSlotShouldShow = false;
						end

						tMixedEntryIndex = tSlotTemplate and tSlotTemplate["mixedEntryIndex"];
						tMixedItemIndex = tSlotTemplate and tSlotTemplate["mixedItemIndex"];
						tPriorityCutoff = tMixedPriorityCutoffs and tMixedEntryIndex and tMixedPriorityCutoffs[tMixedEntryIndex];
						tPrioritySuppress = tMixedItemIndex and tPriorityCutoff and tMixedItemIndex > tPriorityCutoff;

						if tPrioritySuppress then
							tSlotShouldShow = false;
						end

						tSlotFrame = tSlotFrames and tRecordedKey and tSlotFrames[tRecordedKey];
						tHasFrame = tSlotFrame ~= nil;
						tAppliedCandidateSuppress = aContainerData["appliedSlotCandidateSuppress"] and aContainerData["appliedSlotCandidateSuppress"][tRecordedKey];

						VUHDO_auraDiagLine("containerSlot",
							"i", tEngineSlotCnt,
							"engineKey", tRecordedKey,
							"templateKey", tTemplateKey,
							"drift", (tTemplateKey and tTemplateKey ~= tRecordedKey) and 1 or 0,
							"hasFrame", tHasFrame and 1 or 0,
							"filter", VUHDO_escapeAuraDiagFilterString(tSlotTemplate and tSlotTemplate["filterString"]),
							"candidates", VUHDO_auraDiagFormatCandidateSummary(tSlotTemplate and tSlotTemplate["candidateFilters"], nil),
							"identityGate", tTemplateRef["identityGate"],
							"compound", tTemplateRef["isCompoundFilterString"],
							"suppress", tShouldSuppress,
							"slotSuppress", aContainerData["lastSlotSuppress"] and aContainerData["lastSlotSuppress"][tRecordedKey],
							"appliedCandidateSuppress", tAppliedCandidateSuppress and 1 or 0,
							"mixedEntry", tMixedEntryIndex,
							"mixedItem", tMixedItemIndex,
							"priorityCutoff", tPriorityCutoff,
							"prioritySuppress", tPrioritySuppress and 1 or 0,
							"effectiveSuppress", tSlotShouldShow and 0 or 1);
					end
				end
			end
		elseif aSlots then
			for tSlotIndex, tSlot in ipairs(aSlots) do
				tCandidateFilters = tSlot["candidateFilters"];

				VUHDO_auraDiagLine("containerSlot",
					"i", tSlotIndex,
					"filter", VUHDO_escapeAuraDiagFilterString(tSlot["filterString"]),
					"candidates", VUHDO_auraDiagFormatCandidateSummary(tCandidateFilters, nil));
			end
		end

		tStaticSlots = aContainerData["staticSlots"];
		tPanelNum = aContainerData["panelNum"];

		if tStaticSlots and next(tStaticSlots) and tPanelNum and aUnit then
			tListSlots = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit]
				and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tPanelNum]
				and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tPanelNum][anAnchorIndex];

			for tStaticSlotKey, tStaticSlot in pairs(tStaticSlots) do
				tStaticSlotIndex = tStaticSlot["slotIndex"];
				tStaticEntryIndex = tStaticSlot["entryIndex"];
				tStaticItemIndex = tStaticSlot["itemIndex"];
				tListSlotData = tListSlots and tStaticEntryIndex and tListSlots[tStaticEntryIndex];
				tStaticFrame = tStaticSlotIndex
					and VUHDO_AURA_FRAMES[aButtonName]
					and VUHDO_AURA_FRAMES[aButtonName][anAnchorIndex]
					and VUHDO_AURA_FRAMES[aButtonName][anAnchorIndex][tStaticSlotIndex];
				tStaticShown = nil;
				tStaticAlpha = nil;

				if tStaticFrame then
					tStaticShown = tStaticFrame:IsShown();
					tStaticAlpha = tStaticFrame:GetAlpha();
				end

				VUHDO_auraDiagLine("staticSlot",
					"button", aButtonName,
					"anchor", anAnchorIndex,
					"key", tStaticSlotKey,
					"slotIndex", tStaticSlotIndex,
					"entryIndex", tStaticEntryIndex,
					"itemIndex", tStaticItemIndex,
					"bouquet", tStaticSlot["bouquetName"],
					"mixed", tStaticSlot["isMixedBouquetItem"] and 1 or 0,
					"listActive", tListSlotData and tListSlotData["isActive"] and 1 or 0,
					"shown", tStaticShown,
					"alpha", tStaticAlpha);
			end
		end

		return;

	end
end



do
	--
	local tFrameRunStates;
	local tFrameRunState;
	local tFrameRunStart;
	local tFrameRunEnd;
	local tFrameRunSig;
	local tFrameRunNextSig;
	local tFrameRunRange;
	local tGroupFrameCount;
	local tAuraFrame;
	local tCanAccess;
	local tAuraFrameWidth;
	local tAuraFrameHeight;
	local tFillTexture;
	local tFillMask;
	local tFillLayer;
	local tFillSublevel;
	local tFrameRunSigFields;
	local function VUHDO_auraDiagChainFrameRunSig(aFrameRunState)

		tFrameRunSigFields = {
			aFrameRunState["shown"],
			aFrameRunState["size"],
			aFrameRunState["pts"],
			aFrameRunState["rgba"],
			aFrameRunState["fillShown"],
			aFrameRunState["fillAlpha"],
			aFrameRunState["fillLayer"],
			aFrameRunState["maskPts"],
			aFrameRunState["alpha"],
		};

		return table.concat(tFrameRunSigFields, "|");

	end



	--
	function VUHDO_auraDiagEmitChainFrameRuns(aGroupIndex, aGroupKey, aContainer)

		tGroupFrameCount = aContainer:GetAuraGroupFrameCount(aGroupKey);

		if tGroupFrameCount <= 0 then
			return;
		end

		tFrameRunStates = { };

		for tGroupFrameIndex = 1, tGroupFrameCount do
			tAuraFrame = aContainer:GetAuraGroupFrame(aGroupKey, tGroupFrameIndex);
			tFrameRunState = { };

			if tAuraFrame then
				tCanAccess = tAuraFrame:CanBeAccessedInContext();

				if tCanAccess then
					tAuraFrameWidth, tAuraFrameHeight = tAuraFrame:GetSize();
					tFillTexture = tAuraFrame["FillTexture"];
					tFillMask = tAuraFrame["VuhDoFillMask"];

					tFrameRunState["shown"] = VUHDO_auraDiagCompactVal(tAuraFrame:IsShown()) or "?";
					tFrameRunState["size"] = VUHDO_auraDiagCompactSize(tAuraFrameWidth, tAuraFrameHeight) or "?";
					tFrameRunState["pts"] = VUHDO_auraDiagCompactVal(tAuraFrame:GetNumPoints()) or "?";
					tFrameRunState["rgba"] = VUHDO_auraDiagCompactTextureRgba(tFillTexture) or "-";
					tFrameRunState["alpha"] = VUHDO_auraDiagCompactVal(tAuraFrame:GetAlpha()) or "?";

					if tFillTexture then
						tFillLayer, tFillSublevel = tFillTexture:GetDrawLayer();
						tFrameRunState["fillShown"] = VUHDO_auraDiagCompactVal(tFillTexture:IsShown()) or "?";
						tFrameRunState["fillAlpha"] = VUHDO_auraDiagCompactVal(tFillTexture:GetAlpha()) or "?";
						tFrameRunState["fillLayer"] = format("%s/%s", VUHDO_auraDiagCompactVal(tFillLayer) or "?", VUHDO_auraDiagCompactVal(tFillSublevel) or "?");
					else
						tFrameRunState["fillShown"] = "-";
						tFrameRunState["fillAlpha"] = "-";
						tFrameRunState["fillLayer"] = "-";
					end

					if tFillMask then
						tFrameRunState["maskPts"] = VUHDO_auraDiagCompactVal(tFillMask:GetNumPoints()) or "?";
					else
						tFrameRunState["maskPts"] = "-";
					end
				else
					tFrameRunState["shown"] = "?";
					tFrameRunState["size"] = "?";
					tFrameRunState["pts"] = "?";
					tFrameRunState["rgba"] = "-";
					tFrameRunState["alpha"] = "?";
					tFrameRunState["fillShown"] = "?";
					tFrameRunState["fillAlpha"] = "?";
					tFrameRunState["fillLayer"] = "?";
					tFrameRunState["maskPts"] = "?";
				end
			else
				tFrameRunState["shown"] = "-";
				tFrameRunState["size"] = "-";
				tFrameRunState["pts"] = "-";
				tFrameRunState["rgba"] = "-";
				tFrameRunState["alpha"] = "-";
				tFrameRunState["fillShown"] = "-";
				tFrameRunState["fillAlpha"] = "-";
				tFrameRunState["fillLayer"] = "-";
				tFrameRunState["maskPts"] = "-";
			end

			tFrameRunStates[tGroupFrameIndex] = tFrameRunState;

			if sAuraDiagVerbose then
				VUHDO_auraDiagLine("chainFrame", "g", aGroupIndex, "i", tGroupFrameIndex,
					"shown", tFrameRunState["shown"],
					"size", tFrameRunState["size"],
					"pts", tFrameRunState["pts"],
					"rgba", tFrameRunState["rgba"],
					"alpha", tFrameRunState["alpha"],
					"fillShown", tFrameRunState["fillShown"],
					"fillAlpha", tFrameRunState["fillAlpha"],
					"fillLayer", tFrameRunState["fillLayer"],
					"maskPts", tFrameRunState["maskPts"]);
			end
		end

		if sAuraDiagVerbose then
			return;
		end

		tFrameRunStart = 1;
		tFrameRunState = tFrameRunStates[1];
		tFrameRunSig = VUHDO_auraDiagChainFrameRunSig(tFrameRunState);

		for tGroupFrameIndex = 2, tGroupFrameCount + 1 do
			if tGroupFrameIndex <= tGroupFrameCount then
				tFrameRunState = tFrameRunStates[tGroupFrameIndex];
				tFrameRunNextSig = VUHDO_auraDiagChainFrameRunSig(tFrameRunState);
			else
				tFrameRunNextSig = nil;
			end

			if tFrameRunNextSig ~= tFrameRunSig then
				tFrameRunEnd = tGroupFrameIndex - 1;
				tFrameRunState = tFrameRunStates[tFrameRunStart];

				if tFrameRunStart == tFrameRunEnd then
					tFrameRunRange = tostring(tFrameRunStart);
				else
					tFrameRunRange = format("%d-%d", tFrameRunStart, tFrameRunEnd);
				end

				VUHDO_auraDiagLine("chainFrames", "g", aGroupIndex, "range", tFrameRunRange,
					"shown", tFrameRunState["shown"],
					"size", tFrameRunState["size"],
					"pts", tFrameRunState["pts"],
					"rgba", tFrameRunState["rgba"],
					"alpha", tFrameRunState["alpha"],
					"fillShown", tFrameRunState["fillShown"],
					"fillAlpha", tFrameRunState["fillAlpha"],
					"fillLayer", tFrameRunState["fillLayer"],
					"maskPts", tFrameRunState["maskPts"]);

				tFrameRunStart = tGroupFrameIndex;
				tFrameRunSig = tFrameRunNextSig;
			end
		end

		return;

	end
end



do
	--
	local tGroupKeys;
	local tGroups;
	local tGroupKey;
	local tGroupButtonSetup;
	local tDispelBright;
	local tDispelOpacity;
	local tFillColorMap;
	local tBackingColorMap;
	local tMagicFillColor;
	local tMagicBackingColor;
	local tMagicFillRgba;
	local tMagicBackingRgba;
	local tChainBaselineFrame;
	local tChainBaselineTexture;
	local tChainBaselineMask;
	local tTargetBar;
	local tTargetTexture;
	local tTargetAlpha;
	local tContainer;
	local tContainerWidth;
	local tContainerHeight;
	local tLastSyncedGroupEnabled;
	local tLiveBarWidth;
	local tLiveBarHeight;
	local tGroupLayout;
	local tStaticColor;
	local tStoredBaselineColor;
	local tChainGroupMeta;
	local tChainGroupMetaEntry;
	local tButtonName;
	local tOverlayHostFrame;
	local tOverlayHostWidth;
	local tOverlayHostHeight;
	local tGroupFilterString;
	local tGroupCandidateFilters;
	local tCandidateSummary;
	local tElemSize;
	local tLiveSize;
	local tMetaGroupKey;
	local tChainBaselineRgba;
	local tStoredBaselineRgba;
	local tGroupDiagTemplate;
	local tIdentityGate;
	local tCompound;
	local tShouldSuppress;
	function VUHDO_dumpFillChainDiagnostics(aContainerData, aContainerTemplate)

		tContainer = aContainerData["container"];

		if tContainer then
			tContainerWidth, tContainerHeight = tContainer:GetSize();

			VUHDO_auraDiagLine("fillChainContainer",
				"shown", tContainer:IsShown(),
				"enabled", tContainer:IsEnabled(),
				"visible", tContainer:IsVisible(),
				"alpha", VUHDO_auraDiagCompactVal(tContainer:GetAlpha()),
				"strata", tContainer:GetFrameStrata(),
				"size", VUHDO_auraDiagCompactSize(tContainerWidth, tContainerHeight),
				"frameLevel", tContainer:GetFrameLevel(),
				"suppressed", aContainerData["groupsSuppressed"] and 1 or 0);
		end

		tOverlayHostFrame = aContainerTemplate["overlayHostFrame"];

		if tOverlayHostFrame then
			tOverlayHostWidth, tOverlayHostHeight = tOverlayHostFrame:GetSize();

			VUHDO_auraDiagLine("fillChainHost",
				"clipsChildren", tOverlayHostFrame:DoesClipChildren(),
				"size", VUHDO_auraDiagCompactSize(tOverlayHostWidth, tOverlayHostHeight));
		end

		tGroupKeys = aContainerData["groupKeys"];
		tGroups = aContainerTemplate["groups"];
		tLastSyncedGroupEnabled = aContainerData["lastSyncedGroupEnabled"];
		tTargetBar = aContainerTemplate["overlayTargetBar"];
		tLiveBarWidth = tTargetBar and tTargetBar:GetWidth();
		tLiveBarHeight = tTargetBar and tTargetBar:GetHeight();
		tChainGroupMeta = aContainerData["chainGroupMeta"];

		if tGroupKeys and tGroups then
			for tGroupIndex = 1, #tGroupKeys do
				tGroupKey = tGroupKeys[tGroupIndex];
				tGroupButtonSetup = nil;
				tGroupLayout = nil;
				tGroupFilterString = nil;
				tGroupCandidateFilters = nil;

				for _, tGroupTemplate in ipairs(tGroups) do
					if tGroupTemplate["key"] == tGroupKey then
						tGroupButtonSetup = tGroupTemplate["buttonSetup"];
						tGroupLayout = tGroupTemplate["layout"];
						tGroupFilterString = tGroupTemplate["filterString"];
						tGroupCandidateFilters = tGroupTemplate["candidateFilters"];

						break;
					end
				end

				tChainGroupMetaEntry = tChainGroupMeta and tChainGroupMeta[tGroupIndex];
				tGroupFilterString = tGroupFilterString or (tChainGroupMetaEntry and tChainGroupMetaEntry["filterString"]);
				tGroupCandidateFilters = tGroupCandidateFilters or (tChainGroupMetaEntry and tChainGroupMetaEntry["candidateFilters"]);
				tMetaGroupKey = tChainGroupMetaEntry and tChainGroupMetaEntry["groupKey"];
				tCandidateSummary = VUHDO_auraDiagFormatCandidateSummary(tGroupCandidateFilters, tGroupButtonSetup);
				tStaticColor = tGroupButtonSetup and tGroupButtonSetup["staticColor"];
				tMagicFillRgba = nil;
				tMagicBackingRgba = nil;

				if tGroupButtonSetup and (tGroupButtonSetup["dispelFill"] or tGroupButtonSetup["dispelIcon"]) then
					tDispelBright = tGroupButtonSetup["dispelBright"];
					tDispelOpacity = tGroupButtonSetup["dispelOpacity"];

					tFillColorMap = VUHDO_getDispelTypeBackgroundFillColorMap(tDispelBright, tDispelOpacity);
					tBackingColorMap = VUHDO_getDispelTypeBackgroundBackingColorMap(tDispelBright, tDispelOpacity);

					tMagicFillColor = tFillColorMap and tFillColorMap["Magic"];
					tMagicBackingColor = tBackingColorMap and tBackingColorMap["Magic"];

					if tMagicFillColor then
						tDiagR, tDiagG, tDiagB, tDiagA = tMagicFillColor:GetRGBA();
						tMagicFillRgba = VUHDO_auraDiagCompactRgba(tDiagR, tDiagG, tDiagB, tDiagA);
					end

					if tMagicBackingColor then
						tDiagR, tDiagG, tDiagB, tDiagA = tMagicBackingColor:GetRGBA();
						tMagicBackingRgba = VUHDO_auraDiagCompactRgba(tDiagR, tDiagG, tDiagB, tDiagA);
					end
				end

				tElemSize = VUHDO_auraDiagCompactSize(tGroupLayout and tGroupLayout["elementWidth"], tGroupLayout and tGroupLayout["elementHeight"]);
				tLiveSize = VUHDO_auraDiagCompactSize(tLiveBarWidth, tLiveBarHeight);
				tGroupDiagTemplate = {
					["filterString"] = tGroupFilterString,
					["candidateFilters"] = tGroupCandidateFilters,
				};

				tIdentityGate = tChainGroupMetaEntry and tChainGroupMetaEntry["identityGate"] or VUHDO_getTemplateIdentityGate(tGroupDiagTemplate);
				tCompound = tChainGroupMetaEntry and tChainGroupMetaEntry["isCompoundFilterString"] or VUHDO_isCompoundFilterStringTemplate(tGroupDiagTemplate);
				tShouldSuppress = VUHDO_isAuraDisplaySuppressed(tGroupDiagTemplate, {
					["isDisconnected"] = sAuraDiagDisconnected,
					["canApplyHelpfulIdentity"] = sAuraDiagCanApplyHelpfulIdentity,
					["canApplyHarmfulIdentity"] = sAuraDiagCanApplyHarmfulIdentity,
					["isAuraFilterRestricted"] = sAuraDiagAuraFilterRestricted,
				});

				VUHDO_auraDiagLine("chainGroup",
					"g", tGroupIndex,
					"key", tGroupKey,
					"groupKey", tMetaGroupKey ~= tGroupKey and tMetaGroupKey or nil,
					"filter", VUHDO_escapeAuraDiagFilterString(tGroupFilterString),
					"candidates", tCandidateSummary,
					"identityGate", tIdentityGate,
					"compound", tCompound,
					"suppress", tShouldSuppress and 1 or 0,
					"enabled", tLastSyncedGroupEnabled and tLastSyncedGroupEnabled[tGroupKey],
					"elem", tElemSize,
					"live", tLiveSize ~= tElemSize and tLiveSize or nil,
					"dispelFill", tGroupButtonSetup and tGroupButtonSetup["dispelFill"],
					"dispelIcon", tGroupButtonSetup and tGroupButtonSetup["dispelIcon"],
					"shadowValueMode", tGroupButtonSetup and tGroupButtonSetup["shadowValueMode"],
					"rgba", VUHDO_auraDiagCompactColorTable(tStaticColor),
					"mapMagicFill", tMagicFillRgba,
					"mapMagicBacking", tMagicBackingRgba ~= tMagicFillRgba and tMagicBackingRgba or nil);

				if tContainer and tGroupKey then
					VUHDO_auraDiagEmitChainFrameRuns(tGroupIndex, tGroupKey, tContainer);
				end
			end
		end

		tChainBaselineFrame = aContainerData["chainBaselineFrame"];
		tChainBaselineTexture = aContainerData["chainBaselineTexture"];
		tChainBaselineMask = tChainBaselineFrame and tChainBaselineFrame["ChainBaselineMask"];

		if tTargetBar and tTargetBar:GetObjectType() == "StatusBar" then
			tTargetTexture = tTargetBar:GetStatusBarTexture();
			tTargetAlpha = tTargetTexture and tTargetTexture:GetAlpha();
		else
			tTargetTexture = nil;
			tTargetAlpha = nil;
		end

		tButtonName = tTargetBar and tTargetBar:GetParent() and tTargetBar:GetParent():GetName();
		tStoredBaselineColor = tButtonName and VUHDO_getOverlayChainBaselineStoredColor(tButtonName);
		tChainBaselineRgba = VUHDO_auraDiagCompactTextureRgba(tChainBaselineTexture);
		tStoredBaselineRgba = VUHDO_auraDiagCompactColorTable(tStoredBaselineColor);

		VUHDO_auraDiagLine("chainBaseline",
			"ownsBackgroundFill", aContainerData["ownsBackgroundFill"],
			"backgroundFillHidden", aContainerData["backgroundFillHidden"],
			"lastSyncedEnabled", aContainerData["lastSyncedEnabled"],
			"frameShown", tChainBaselineFrame and tChainBaselineFrame:IsShown(),
			"texShown", tChainBaselineTexture and tChainBaselineTexture:IsShown(),
			"maskPoints", tChainBaselineMask and tChainBaselineMask:GetNumPoints(),
			"targetBarTexAlpha", tTargetAlpha,
			"baselineRgba", tChainBaselineRgba,
			"storedRgba", tStoredBaselineRgba);

		return;

	end
end



do
	--
	local tOverlayContainers;
	local tSlotHostData;
	local tSlotHostContainer;
	local tSlotFrame;
	local tFillTexture;
	local tFillLayer;
	local tFillSublevel;
	local tContainer;
	local tContainerWidth;
	local tContainerHeight;
	local tGroups;
	local tTargetBar;
	local tGroupKey;
	local tGroupFrameCount;
	local tAuraFrame;
	local tShouldSuppress;
	local tBarColors;
	local sEmpty = { };
	function VUHDO_dumpAuraOverlayDiagnostics(aButtonName)

		tSlotHostData = VUHDO_OVERLAY_SLOT_HOSTS and VUHDO_OVERLAY_SLOT_HOSTS[aButtonName];
		tSlotHostContainer = tSlotHostData and tSlotHostData["container"];

		if tSlotHostContainer then
			VUHDO_auraDiagLine("overlaySlotHost",
				"button", aButtonName,
				"slotCount", tSlotHostData["slotOrder"] and #tSlotHostData["slotOrder"] or 0,
				"shown", tSlotHostContainer:IsShown(),
				"enabled", tSlotHostContainer:IsEnabled(),
				"unit", tSlotHostContainer:GetUnit(),
				"frameLevel", tSlotHostContainer:GetFrameLevel(),
				"hostGated", tSlotHostData["lastHostGated"] and 1 or 0);

			for tSlotKey, tSlotRecord in pairs(tSlotHostData["slotRecords"] or sEmpty) do
				if VUHDO_auraDiagMatchesIndicator(tSlotRecord["indicatorKey"]) then
					tSlotFrame = tSlotRecord["slotFrame"];
					tShouldSuppress = VUHDO_isAuraDisplaySuppressed(tSlotRecord, {
						["isDisconnected"] = sAuraDiagDisconnected,
						["canApplyHelpfulIdentity"] = sAuraDiagCanApplyHelpfulIdentity,
						["canApplyHarmfulIdentity"] = sAuraDiagCanApplyHarmfulIdentity,
						["isAuraFilterRestricted"] = sAuraDiagAuraFilterRestricted,
					});

					tFillLayer = nil;
					tFillSublevel = nil;

					if tSlotFrame and tSlotFrame["FillTexture"] then
						tFillTexture = tSlotFrame["FillTexture"];
						tFillLayer, tFillSublevel = tFillTexture:GetDrawLayer();
					end

					VUHDO_auraDiagLine("overlaySlot",
						"button", aButtonName,
						"indicator", tSlotRecord["indicatorKey"],
						"entry", tSlotRecord["entryKey"],
						"slotKey", tSlotKey,
						"shown", tSlotFrame and tSlotFrame:IsShown(),
						"filter", VUHDO_escapeAuraDiagFilterString(tSlotRecord["filterString"]),
						"appliedFilter", VUHDO_escapeAuraDiagFilterString(tSlotRecord["appliedFilterString"]),
						"candidates", VUHDO_auraDiagFormatCandidateSummary(tSlotRecord["candidateFilters"], nil),
						"friendlyOnly", tSlotRecord["friendlyOnly"],
						"hostileOnly", tSlotRecord["hostileOnly"],
						"identityGate", tSlotRecord["identityGate"],
						"compound", tSlotRecord["isCompoundFilterString"],
						"suppress", tShouldSuppress and 1 or 0,
						"appliedSuppress", tSlotRecord["appliedSuppress"] and 1 or 0,
						"lastSyncedEnabled", tSlotHostData["lastSyncedSlotEnabled"] and tSlotHostData["lastSyncedSlotEnabled"][tSlotKey],
						"fillLayer", tFillLayer and format("%s/%s", tostring(tFillLayer), tostring(tFillSublevel)),
						"frameLevel", tSlotFrame and tSlotFrame:GetFrameLevel(),
						"auraGroupBarGlow", tSlotRecord["auraGroupBarGlow"] and 1 or 0);

					if tSlotRecord["indicatorKey"] == "DISPEL_OVERLAY" then
						tBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

						VUHDO_auraDiagLine("dispelOverlay",
							"showDispelOverlay", tBarColors and tBarColors["showDispelOverlay"],
							"dispelIndicatorType", tBarColors and tBarColors["dispelIndicatorType"],
							"filter", VUHDO_escapeAuraDiagFilterString(tSlotRecord["filterString"]));
					end
				end
			end
		end

		tOverlayContainers = VUHDO_OVERLAY_CONTAINERS[aButtonName];

		if not tOverlayContainers and not tSlotHostContainer then
			VUHDO_auraDiagLine("overlays", "button", aButtonName, "count", 0);

			return;
		end

		if not tOverlayContainers then
			return;
		end

		for tIndicatorKey, _ in pairs(tOverlayContainers) do
			if VUHDO_auraDiagMatchesIndicator(tIndicatorKey) then
				for tEntryKey, tContainerData in pairs(tOverlayContainers[tIndicatorKey]) do
					tContainer = tContainerData and tContainerData["container"];

					if tContainer then
						tIsShown = tContainer:IsShown();
						tIsEnabled = tContainer:IsEnabled();
						tIsVisible = tContainer:IsVisible();
						tContainerAlpha = tContainer:GetAlpha();
						tEffectiveAlpha = tContainer:GetEffectiveAlpha();
						tContainerWidth, tContainerHeight = tContainer:GetSize();
						tContainerUnit = tContainer:GetUnit();

						tParentFrame = tContainer:GetParent();
						tParentName = tParentFrame and tParentFrame:GetName();
						tParentShown = tParentFrame and tParentFrame:IsShown();
						tParentAlpha = tParentFrame and tParentFrame:GetAlpha();
						tParentClips = tParentFrame and tParentFrame:DoesClipChildren();

						tContainerTemplate = tContainerData["containerTemplate"];
						tGroups = tContainerTemplate and tContainerTemplate["groups"];

						tFilterString = tGroups and tGroups[1] and tGroups[1]["filterString"];
						tFilterString = tContainerData["overlayFilterString"] or tFilterString;
						tCandidateFilters = tContainerData["overlayCandidateFilters"];
						tHasStaticColor = tContainerData["overlayStaticColor"] ~= nil;

						tSlots = tContainerTemplate and tContainerTemplate["slots"];
						tSlot = tSlots and tSlots[1] and tSlots[1]["buttonSetup"];

						tTargetBar = tContainerData["overlayTargetBar"];

						if tTargetBar and tTargetBar:GetObjectType() == "StatusBar" then
							tTargetBarTexture = tTargetBar:GetStatusBarTexture();
							tTargetBarAlpha = tTargetBarTexture and tTargetBarTexture:GetAlpha();
						else
							tTargetBarTexture = nil;
							tTargetBarAlpha = nil;
						end

						tWarnParts = { };

						if tContainerAlpha ~= nil and not issecretvalue(tContainerAlpha) and tContainerAlpha ~= 1 then
							tinsert(tWarnParts, "alpha");
						end

						if tEffectiveAlpha ~= nil and not issecretvalue(tEffectiveAlpha) and tEffectiveAlpha ~= 1 then
							tinsert(tWarnParts, "effAlpha");
						end

						if tParentShown == false then
							tinsert(tWarnParts, "parentShown");
						end

						if tParentAlpha ~= nil and not issecretvalue(tParentAlpha) and tParentAlpha ~= 1 then
							tinsert(tWarnParts, "parentAlpha");
						end

						if tParentClips then
							tinsert(tWarnParts, "parentClips");
						end

						if tContainerUnit and sAuraDiagUnit and tContainerUnit ~= sAuraDiagUnit then
							tinsert(tWarnParts, "unit");
						end

						if tIsVisible == false and tIsShown then
							tinsert(tWarnParts, "visible");
						end

						tWarnField = #tWarnParts > 0 and tconcat(tWarnParts, ",") or nil;

						tShouldSuppress = VUHDO_isAuraDisplaySuppressed(tContainerData, {
							["isDisconnected"] = sAuraDiagDisconnected,
							["canApplyHelpfulIdentity"] = sAuraDiagCanApplyHelpfulIdentity,
							["canApplyHarmfulIdentity"] = sAuraDiagCanApplyHarmfulIdentity,
							["isAuraFilterRestricted"] = sAuraDiagAuraFilterRestricted,
						});

						VUHDO_auraDiagLine("overlay",
							"button", aButtonName,
							"indicator", tIndicatorKey,
							"entry", tEntryKey,
							"shown", tIsShown,
							"enabled", tIsEnabled,
							"visible", tIsVisible,
							"alpha", VUHDO_auraDiagCompactVal(tContainerAlpha),
							"strata", tContainer:GetFrameStrata(),
							"size", VUHDO_auraDiagCompactSize(tContainerWidth, tContainerHeight),
							"parent", tParentName,
							"warn", tWarnField,
							"friendlyOnly", tContainerData["friendlyOnly"],
							"hostileOnly", tContainerData["hostileOnly"],
							"identityGate", tContainerData["identityGate"],
							"suppress", tShouldSuppress and 1 or 0,
							"lastSyncedEnabled", tContainerData["lastSyncedEnabled"],
							"ownsBackgroundFill", tContainerData["ownsBackgroundFill"],
							"backgroundFillHidden", tContainerData["backgroundFillHidden"],
							"targetBarTexAlpha", tTargetBarAlpha,
							"filter", VUHDO_escapeAuraDiagFilterString(tFilterString),
							"hasStaticColor", tHasStaticColor and 1 or 0,
							"candidates", VUHDO_auraDiagFormatCandidateSummary(tCandidateFilters, tSlot),
							"shadowValueMode", tSlot and tSlot["shadowValueMode"],
							"sublevelLayer", tSlot and tSlot["sublevelSlots"] and tSlot["sublevelSlots"][1] and tSlot["sublevelSlots"][1]["layer"],
							"sublevel", tSlot and tSlot["sublevelSlots"] and tSlot["sublevelSlots"][1] and tSlot["sublevelSlots"][1]["sublevel"],
							"buildSignature", tContainerData["buildSignature"],
							"filterSignature", tContainerData["filterSignature"],
							"frameLevel", tContainer:GetFrameLevel(),
							"suppressed", tContainerData["groupsSuppressed"] and 1 or 0);

						if tContainerTemplate and tContainerTemplate["isFillChain"] then
							VUHDO_dumpFillChainDiagnostics(tContainerData, tContainerTemplate);
						end

						if tIndicatorKey == "DISPEL_OVERLAY" then
							tBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

							VUHDO_auraDiagLine("dispelOverlay",
								"showDispelOverlay", tBarColors and tBarColors["showDispelOverlay"],
								"dispelIndicatorType", tBarColors and tBarColors["dispelIndicatorType"],
								"filter", VUHDO_escapeAuraDiagFilterString(tFilterString));

							tGroupKey = tContainerData["groupKeys"] and tContainerData["groupKeys"][1];

							if tGroupKey then
								tGroupFrameCount = tContainer:GetAuraGroupFrameCount(tGroupKey);

								VUHDO_auraDiagLine("dispelOverlayFrames",
									"groupKey", tGroupKey,
									"frameCount", tGroupFrameCount);

								if sAuraDiagVerbose then
									for tGroupFrameIndex = 1, tGroupFrameCount do
										tAuraFrame = tContainer:GetAuraGroupFrame(tGroupKey, tGroupFrameIndex);

										if tAuraFrame and tAuraFrame:CanBeAccessedInContext() then
											VUHDO_auraDiagLine("dispelFrame", "i", tGroupFrameIndex,
												"fillRgba", VUHDO_auraDiagCompactTextureRgba(tAuraFrame["FillTexture"]),
												"gradRgba", VUHDO_auraDiagCompactTextureRgba(tAuraFrame["GradientTexture"]),
												"borderRgba", VUHDO_auraDiagCompactTextureRgba(tAuraFrame["BorderTexture"]),
												"iconRgba", VUHDO_auraDiagCompactTextureRgba(tAuraFrame["DispelIconTexture"]));
										end
									end
								end
							end
						end
					else
						VUHDO_auraDiagLine("overlay",
							"button", aButtonName,
							"indicator", tIndicatorKey,
							"entry", tEntryKey,
							"container", "-");
					end
				end
			end
		end

		return;

	end
end



do
	--
	local tBackgroundBar;
	local tBackgroundBarShown;
	local tBackgroundBarAlpha;
	local tBackgroundBarEffectiveAlpha;
	local tBackgroundBarR;
	local tBackgroundBarG;
	local tBackgroundBarB;
	local tBackgroundBarA;
	local tBackgroundBarValue;
	local tBackgroundBarTexture;
	local tBackgroundBarTextureAlpha;
	function VUHDO_dumpBackgroundBarDiagnostics(aButton, aButtonName)

		if not aButton then
			return;
		end

		tBackgroundBar = VUHDO_getHealthBar(aButton, 3);

		if not tBackgroundBar then
			VUHDO_auraDiagLine("backgroundBar", "button", aButtonName, "bar", "-");

			return;
		end

		tBackgroundBarShown = tBackgroundBar:IsShown();
		tBackgroundBarAlpha = tBackgroundBar:GetAlpha();
		tBackgroundBarEffectiveAlpha = tBackgroundBar:GetEffectiveAlpha();
		tBackgroundBarR, tBackgroundBarG, tBackgroundBarB, tBackgroundBarA = tBackgroundBar:GetStatusBarColor();
		tBackgroundBarValue = tBackgroundBar:GetValue();
		tBackgroundBarTexture = tBackgroundBar:GetStatusBarTexture();
		tBackgroundBarTextureAlpha = tBackgroundBarTexture and tBackgroundBarTexture:GetAlpha();

		if tBackgroundBarAlpha ~= nil and not issecretvalue(tBackgroundBarAlpha) and tBackgroundBarAlpha == 1 then
			tBackgroundBarAlpha = nil;
		end

		if tBackgroundBarEffectiveAlpha ~= nil and not issecretvalue(tBackgroundBarEffectiveAlpha) and tBackgroundBarEffectiveAlpha == 1 then
			tBackgroundBarEffectiveAlpha = nil;
		end

		VUHDO_auraDiagLine("backgroundBar", "button", aButtonName,
			"shown", tBackgroundBarShown,
			"rgba", VUHDO_auraDiagCompactRgba(tBackgroundBarR, tBackgroundBarG, tBackgroundBarB, tBackgroundBarA),
			"value", tBackgroundBarValue,
			"alpha", tBackgroundBarAlpha,
			"effAlpha", tBackgroundBarEffectiveAlpha,
			"texAlpha", tBackgroundBarTextureAlpha);

		return;

	end
end



do
	--
	local tPanelAnchors;
	local tPanelAnchorSignatureMap;
	local tPanelAnchorSigEntry;
	local tPanelList;
	local tPanelListStr;
	local tSignature;
	local tFilterString;
	local tResolvedLayout;
	function VUHDO_dumpAuraPanelAnchors()

		tPanelAnchorSignatureMap = { };

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			if VUHDO_isPanelVisible(tPanelNum) then
				tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

				if tPanelAnchors then
					for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
						if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
							tFilterString = VUHDO_escapeAuraDiagFilterString(VUHDO_resolveAuraContainerFilter(tAnchorConfig) or "none");
							tResolvedLayout, _ = VUHDO_resolveAnchorLayout(tAnchorConfig);

							tSignature = format("%s|%s|%s|%s|%s|%s|%s|%s",
								tostring(tAnchorIndex),
								tostring(tAnchorConfig["groupId"]),
								tFilterString,
								tostring(tAnchorConfig["maxDisplay"] or 5),
								tResolvedLayout and tResolvedLayout["isFixedLayout"] and "1" or "0",
								tostring(tResolvedLayout and tResolvedLayout["layoutAxis"] or "n/a"),
								tostring(tResolvedLayout and tResolvedLayout["horizontalDir"] or "n/a"),
								tostring(tResolvedLayout and tResolvedLayout["verticalDir"] or "n/a"));

							tPanelAnchorSigEntry = tPanelAnchorSignatureMap[tSignature];

							if not tPanelAnchorSigEntry then
								tPanelAnchorSigEntry = {
									["panels"] = { },
									["anchor"] = tAnchorIndex,
									["groupId"] = tAnchorConfig["groupId"],
									["filter"] = tFilterString,
									["maxDisplay"] = tAnchorConfig["maxDisplay"] or 5,
									["isFixedLayout"] = tResolvedLayout and tResolvedLayout["isFixedLayout"] and 1 or 0,
									["layoutAxis"] = tResolvedLayout and tResolvedLayout["layoutAxis"] or "n/a",
									["horizontalDir"] = tResolvedLayout and tResolvedLayout["horizontalDir"] or "n/a",
									["verticalDir"] = tResolvedLayout and tResolvedLayout["verticalDir"] or "n/a",
								};

								tPanelAnchorSignatureMap[tSignature] = tPanelAnchorSigEntry;
							end

							tPanelList = tPanelAnchorSigEntry["panels"];
							tPanelList[#tPanelList + 1] = tPanelNum;
						end
					end
				else
					VUHDO_auraDiagLine("panelAnchors", "panel", tPanelNum, "anchors", "-");
				end
			end
		end

		for _, tPanelAnchorSigEntry in pairs(tPanelAnchorSignatureMap) do
			table.sort(tPanelAnchorSigEntry["panels"]);
			tPanelListStr = tconcat(tPanelAnchorSigEntry["panels"], ",");

			VUHDO_auraDiagLine("panelAnchors",
				"panels", tPanelListStr,
				"anchor", tPanelAnchorSigEntry["anchor"],
				"group", tPanelAnchorSigEntry["groupId"],
				"filter", tPanelAnchorSigEntry["filter"],
				"maxDisplay", tPanelAnchorSigEntry["maxDisplay"],
				"isFixedLayout", tPanelAnchorSigEntry["isFixedLayout"],
				"layoutAxis", tPanelAnchorSigEntry["layoutAxis"],
				"horizontalDir", tPanelAnchorSigEntry["horizontalDir"],
				"verticalDir", tPanelAnchorSigEntry["verticalDir"]);
		end

		return;

	end
end



do
	--
	local tOverlayZeroPlanCount;
	local tOverlayZeroPlanLastReason;
	local tHasAnyOverlays;
	local tIsAuraModeContainers;
	local tIsAuraDataRestricted;
	local tIsBarColorsDispelOverlayConfigured;
	local tUnitInfo;
	local tIsAssistRestricted;
	local tIsAuraFilterRestricted;
	local tIsDisconnected;
	local tPhaseReason;
	local tCanColorBarGroups;
	local tCanColorGroup;
	local tGroupId;
	local tGroup;
	local tResolved;
	local tButtons;
	local tButtonName;
	local tButtonAnchors;
	local tContainer;
	local tWidth;
	local tHeight;
	local tIsShown;
	local tIsEnabled;
	local tContainerUnit;
	local tContainerTemplate;
	local tGroups;
	local tSlots;
	local tGroupTemplateRefs;
	local tGroupKeys;
	local tTemplateRef;
	local tShouldSuppress;
	local tPanelNum;
	local tBackgroundBouquetName;
	local tBouquetActiveEntry;
	local tOverlayBuildKey;
	local tOverlayConfigGeneration;
	local tIndicatorBouquetName;
	local tPrototypeGeneration;
	local tPrototypeCount;
	function VUHDO_dumpAuraDiagnostics(aUnit, anIndicatorKey, anIsVerbose)

		aUnit = aUnit or "player";
		sAuraDiagVerbose = anIsVerbose and true or false;
		sAuraDiagIndicator = anIndicatorKey;
		sAuraDiagUnit = aUnit;

		VUHDO_auraDiagLine("auraDiag", "section", "start", "unit", aUnit);
		VUHDO_auraDiagLine("auraDiag",
			"auraModeContainers", VUHDO_isAuraModeContainers(),
			"auraDataRestricted", VUHDO_isAuraDataRestricted(),
			"combatLockdown", InCombatLockdown(),
			"forceAuraMode", VUHDO_FORCE_AURA_MODE == nil and "auto" or VUHDO_FORCE_AURA_MODE,
			"forceRestricted", VUHDO_FORCE_AURA_DATA_RESTRICTED,
			"secretsEnabled", VUHDO_SECRETS_ENABLED,
			"overlayRebuildPending", VUHDO_OVERLAYS_REBUILD_PENDING,
			"overlayConfigGeneration", VUHDO_getOverlayConfigGeneration(),
			"containerBuilds", VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] or 0,
			"containerReleases", VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] or 0,
			"slotHostBuilds", VUHDO_AURA_CONTAINER_METRICS["builds"]["slotHost"] or 0,
			"overlaySlotBuilds", VUHDO_AURA_CONTAINER_METRICS["builds"]["overlaySlot"] or 0);

		tOverlayZeroPlanCount, tOverlayZeroPlanLastReason = VUHDO_getOverlayZeroPlanDiagnostics();

		VUHDO_auraDiagLine("auraDiag",
			"overlayZeroPlanCount", tOverlayZeroPlanCount or 0,
			"overlayZeroPlanLastReason", tOverlayZeroPlanLastReason,
			"pendingContainerBuilds", VUHDO_getPendingContainerBuildCount(),
			"pendingOverlayBuilds", VUHDO_getPendingOverlayBuildCount());

		tHasAnyOverlays, tIsAuraModeContainers, tIsAuraDataRestricted, tIsBarColorsDispelOverlayConfigured = VUHDO_getOverlayBuildGateState();

		VUHDO_auraDiagLine("overlayGate",
			"hasAnyOverlays", tHasAnyOverlays,
			"auraModeContainers", tIsAuraModeContainers,
			"auraDataRestricted", tIsAuraDataRestricted,
			"showDispelOverlay", tIsBarColorsDispelOverlayConfigured);

		VUHDO_rewriteAuraContainerGateState(aUnit);

		tUnitInfo = VUHDO_RAID[aUnit];
		tCanApplyHelpfulIdentity = VUHDO_AURA_CONTAINER_GATE_STATE["canApplyHelpfulIdentity"];
		tCanApplyHarmfulIdentity = VUHDO_AURA_CONTAINER_GATE_STATE["canApplyHarmfulIdentity"];
		tIsAuraFilterRestricted = VUHDO_AURA_CONTAINER_GATE_STATE["isAuraFilterRestricted"];
		tIsDisconnected = VUHDO_AURA_CONTAINER_GATE_STATE["isDisconnected"];
		tPhaseReason = VUHDO_unitPhaseReason(aUnit);

		sAuraDiagCanApplyHelpfulIdentity = tCanApplyHelpfulIdentity;
		sAuraDiagCanApplyHarmfulIdentity = tCanApplyHarmfulIdentity;
		sAuraDiagAuraFilterRestricted = tIsAuraFilterRestricted;
		sAuraDiagDisconnected = tIsDisconnected and true or false;

		VUHDO_auraDiagLine("gates",
			"exists", UnitExists(aUnit),
			"canAssist4", VUHDO_formatAuraDiagValue(UnitCanAssist("player", aUnit, true, true)),
			"groupMember", VUHDO_formatAuraDiagValue(UnitIsPlayerControlledOrGroupMember(aUnit)),
			"canAttack", VUHDO_formatAuraDiagValue(UnitCanAttack("player", aUnit)),
			"canApplyHelpfulIdentity", tCanApplyHelpfulIdentity,
			"canApplyHarmfulIdentity", tCanApplyHarmfulIdentity,
			"filterRestricted", tIsAuraFilterRestricted,
			"disconnected", tIsDisconnected and 1 or 0,
			"connected", tUnitInfo and tUnitInfo["connected"],
			"visible", tUnitInfo and VUHDO_formatAuraDiagValue(tUnitInfo["visible"]),
			"phaseReason", tPhaseReason);

		tCanColorBarGroups = VUHDO_getCanColorBarGroups();

		VUHDO_auraDiagLine("canColorBarGroups", "count", #tCanColorBarGroups);

		for tGroupCnt = 1, #tCanColorBarGroups do
			tCanColorGroup = tCanColorBarGroups[tGroupCnt];
			tGroupId = tCanColorGroup["groupId"];
			tGroup = VUHDO_getAuraGroup(tGroupId);
			tResolved = tGroup and VUHDO_getAuraGroupResolvedFilters(tGroup);

			VUHDO_auraDiagLine("canColorBarGroup",
				"i", tGroupCnt,
				"groupId", tGroupId,
				"type", tGroup and (tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER),
				"colorType", tCanColorGroup["colorType"],
				"canColorBar", tCanColorGroup["canColorBar"],
				"canGlowBar", tCanColorGroup["canGlowBar"],
				"groupResolves", tGroup ~= nil and 1 or 0,
				"expressible", tResolved and tResolved["expressible"]);
		end

		VUHDO_dumpAuraPanelAnchors();

		tButtons = VUHDO_getUnitButtonsSafe(aUnit);

		if not tButtons or not next(tButtons) then
			VUHDO_auraDiagLine("auraDiag", "section", "end", "reason", "noButtons");

			return;
		end

		for _, tButton in pairs(tButtons) do
			tButtonName = tButton:GetName();

			if tButtonName then
				tOverlayBuildKey = VUHDO_getOverlayBuildKeyForButton(tButtonName);
				tOverlayConfigGeneration = VUHDO_getOverlayConfigGeneration();

				VUHDO_auraDiagLine("button",
					"name", tButtonName,
					"overlayBuildKey", tOverlayBuildKey,
					"overlayConfigGeneration", tOverlayConfigGeneration,
					"buildKeyCurrent", tOverlayBuildKey == tOverlayConfigGeneration and 1 or 0);

				tPanelNum = VUHDO_BUTTON_CACHE[tButton];

				VUHDO_auraDiagLine("button",
					"name", tButtonName,
					"indicatorConfigPresent", tPanelNum and VUHDO_INDICATOR_CONFIG[tPanelNum] ~= nil and 1 or 0);

				if tPanelNum and VUHDO_INDICATOR_CONFIG[tPanelNum] then
					for tIndicatorKey, _ in pairs(VUHDO_INDICATOR_OVERLAY_TARGETS) do
						if VUHDO_auraDiagMatchesIndicator(tIndicatorKey) then
							tIndicatorBouquetName = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"][tIndicatorKey];

							if tIndicatorBouquetName and tIndicatorBouquetName ~= "" then
								tPrototypeGeneration, tPrototypeCount = VUHDO_getOverlayPrototypeCacheDiagnostics(tPanelNum, tIndicatorKey, tIndicatorBouquetName);

								VUHDO_auraDiagLine("overlayBouquet",
									"button", tButtonName,
									"indicator", tIndicatorKey,
									"bouquet", tIndicatorBouquetName,
									"prototypeGeneration", tPrototypeGeneration,
									"prototypeCount", tPrototypeCount);
							end
						end
					end

					tBackgroundBouquetName = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["BACKGROUND_BAR"];

					if tBackgroundBouquetName and tBackgroundBouquetName ~= "" then
						tBouquetActiveEntry = VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] and VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit][tBackgroundBouquetName];

						VUHDO_auraDiagLine("bouquetActive",
							"button", tButtonName,
							"bouquet", tBackgroundBouquetName,
							"active", tBouquetActiveEntry == true and 1 or 0);
					end
				end

				tButtonAnchors = VUHDO_AURA_CONTAINERS[tButtonName];

				if not tButtonAnchors then
					VUHDO_auraDiagLine("button", "name", tButtonName, "containers", "-");
				else
					for tAnchorIndex, tContainerData in pairs(tButtonAnchors) do
						tContainer = tContainerData and tContainerData["container"];

						if tContainer then
							tWidth, tHeight = tContainer:GetSize();
							tIsShown = tContainer:IsShown();
							tIsEnabled = tContainer:IsEnabled();
							tContainerUnit = tContainer:GetUnit();
							tContainerTemplate = tContainerData["containerTemplate"];
							tGroups = tContainerTemplate and tContainerTemplate["groups"];
							tSlots = tContainerTemplate and tContainerTemplate["slots"];

							VUHDO_auraDiagLine("buttonContainer",
								"button", tButtonName,
								"anchor", tAnchorIndex,
								"shown", tIsShown,
								"enabled", tIsEnabled,
								"unit", tContainerUnit,
								"size", VUHDO_auraDiagCompactSize(tWidth, tHeight),
								"lastSyncedUnit", tContainerData["lastSyncedUnit"],
								"lastSyncedRestricted", tContainerData["lastSyncedRestricted"],
								"containerSuppressed", tContainerData["lastContainerSuppressed"] and 1 or 0,
								"suppressed", tContainerData["groupsSuppressed"] and 1 or 0);

							tGroupTemplateRefs = tContainerData["groupTemplateRefs"];
							tGroupKeys = tContainerData["groupKeys"];

							if tGroupTemplateRefs then
								for tGroupCnt = 1, #tGroupTemplateRefs do
									tTemplateRef = tGroupTemplateRefs[tGroupCnt];

									if tTemplateRef then
										tShouldSuppress = VUHDO_isAuraDisplaySuppressed(tTemplateRef);

										VUHDO_auraDiagLine("containerGroup",
											"i", tGroupCnt,
											"key", tGroupKeys and tGroupKeys[tGroupCnt],
											"filter", VUHDO_escapeAuraDiagFilterString(tTemplateRef["template"] and tTemplateRef["template"]["filterString"]),
											"candidates", VUHDO_auraDiagFormatCandidateSummary(tTemplateRef["template"] and tTemplateRef["template"]["candidateFilters"], nil),
											"identityGate", tTemplateRef["identityGate"],
											"compound", tTemplateRef["isCompoundFilterString"],
											"suppress", tShouldSuppress);
									end
								end
							elseif tGroups then
								for tGroupIndex, tGroup in ipairs(tGroups) do
									VUHDO_auraDiagLine("containerGroup",
										"i", tGroupIndex,
										"filter", VUHDO_escapeAuraDiagFilterString(tGroup["filterString"]),
										"candidates", VUHDO_auraDiagFormatCandidateSummary(tGroup["candidateFilters"], nil),
										"maxFrames", tGroup["maxFrameCount"]);
								end
							end

							VUHDO_dumpAuraContainerSlotDiagnostics(tButtonName, tAnchorIndex, tContainerData, tSlots, aUnit);
						else
							VUHDO_auraDiagLine("buttonContainer",
								"button", tButtonName,
								"anchor", tAnchorIndex,
								"container", "-");
						end
					end
				end

				VUHDO_dumpAuraOverlayDiagnostics(tButtonName);
				VUHDO_dumpBackgroundBarDiagnostics(tButton, tButtonName);
			end
		end

		VUHDO_auraDiagLine("auraDiag", "section", "end");

		return;

	end
end



