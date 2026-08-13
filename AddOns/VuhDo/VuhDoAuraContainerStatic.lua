local _;

local format = string.format;
local pairs = pairs;
local twipe = table.wipe;
local InCombatLockdown = InCombatLockdown;
local GetTime = GetTime;
local issecretvalue = issecretvalue;
local UnitCanAttack = UnitCanAttack;

local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
local VUHDO_UNIT_AURA_LIST_SLOTS;
local VUHDO_AURA_FRAMES;
local VUHDO_AURA_CONTAINERS;

local VUHDO_PixelUtil;
local VUHDO_getHealthBar;
local VUHDO_getUnitButtonsPanel;
local VUHDO_displayAuraInSlot;
local VUHDO_hideAuraSlot;
local VUHDO_copyColorTo;
local VUHDO_evaluateBouquetItemForStaticSlot;
local VUHDO_applyAuraContainerSlotFilters;
local VUHDO_getManaAdjustedYOffset;

local sOwnedScratchColor = { };

local sStaticSlotAuraScratch = {
	["color"] = sOwnedScratchColor,
};

local sMixedSlotEvalCache = { };



--
function VUHDO_auraContainerStaticInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_UNIT_AURA_LIST_SLOTS = _G["VUHDO_UNIT_AURA_LIST_SLOTS"];
	VUHDO_AURA_FRAMES = _G["VUHDO_AURA_FRAMES"];
	VUHDO_AURA_CONTAINERS = _G["VUHDO_AURA_CONTAINERS"];

	VUHDO_PixelUtil = _G["VUHDO_PixelUtil"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getUnitButtonsPanel = _G["VUHDO_getUnitButtonsPanel"];
	VUHDO_displayAuraInSlot = _G["VUHDO_displayAuraInSlot"];
	VUHDO_hideAuraSlot = _G["VUHDO_hideAuraSlot"];
	VUHDO_copyColorTo = _G["VUHDO_copyColorTo"];
	VUHDO_evaluateBouquetItemForStaticSlot = _G["VUHDO_evaluateBouquetItemForStaticSlot"];
	VUHDO_applyAuraContainerSlotFilters = _G["VUHDO_applyAuraContainerSlotFilters"];
	VUHDO_getManaAdjustedYOffset = _G["VUHDO_getManaAdjustedYOffset"];

	return;

end



do
	--
	local tContainerLayout;
	local tAnchorPoint;
	local tAnchor;
	local tPoint;
	local tRelFrame;
	local tRelPoint;
	local tXOff;
	local tYOff;
	local tSlotAnchor;
	local tSlotRelPoint;
	local function VUHDO_resolveStaticSlotAnchor(aButton, aContainerTemplate, aStaticSlot)

		tContainerLayout = aContainerTemplate and aContainerTemplate["containerLayout"];
		tAnchorPoint = (tContainerLayout and tContainerLayout["anchorPoint"]) or "TOPLEFT";
		tAnchor = aContainerTemplate and aContainerTemplate["anchor"];
		tPoint = tAnchor and tAnchor["points"] and tAnchor["points"][1];

		tSlotAnchor = aStaticSlot["anchor"];

		if tSlotAnchor then
			tRelFrame = VUHDO_getHealthBar(aButton, 3);

			if not tRelFrame then
				tRelFrame = aButton;
			end

			tSlotRelPoint = aStaticSlot["relPoint"] or tSlotAnchor;

			return tSlotAnchor, tRelFrame, tSlotRelPoint, aStaticSlot["x"] or 0, aStaticSlot["y"] or 0;
		end

		if tPoint then
			if tPoint["relFrame"] == "HealthBar" then
				tRelFrame = VUHDO_getHealthBar(aButton, 3);
			else
				tRelFrame = aButton;
			end

			if not tRelFrame then
				tRelFrame = aButton;
			end

			tRelPoint = tPoint["relativePoint"] or tPoint["point"] or tAnchorPoint;
			tXOff = (tPoint["x"] or 0) + (aStaticSlot["x"] or 0);
			tYOff = (tPoint["y"] or 0) + (aStaticSlot["y"] or 0);

			if tPoint["relFrame"] == "HealthBar" then
				tYOff = VUHDO_getManaAdjustedYOffset(aButton, tRelPoint, tYOff);
			end

			return tPoint["point"] or tAnchorPoint, tRelFrame, tRelPoint, tXOff, tYOff;
		end

		return tAnchorPoint, aButton, tAnchorPoint, aStaticSlot["x"] or 0, aStaticSlot["y"] or 0;

	end



	--
	local tAnchorPoint;
	local tRelFrame;
	local tRelPoint;
	local tXOff;
	local tYOff;
	local tFrameLevelOffset;
	local tRelFrameKey;
	local tChild;
	local tTexture;
	local tButtonFrameLevel;
	local function VUHDO_applyStaticBouquetSlotGeometry(aFrame, aButton, aContainerTemplate, aStaticSlot)

		if not aFrame or not aButton or not aContainerTemplate or not aStaticSlot then
			return;
		end

		aFrame["isStaticSlotFrame"] = true;

		tAnchorPoint, tRelFrame, tRelPoint, tXOff, tYOff = VUHDO_resolveStaticSlotAnchor(aButton, aContainerTemplate, aStaticSlot);
		tFrameLevelOffset = ((aContainerTemplate["anchor"] and aContainerTemplate["anchor"]["frameLevelOffset"]) or aFrame["addLevel"] or 10) + (aStaticSlot["frameLevelOffset"] or 0);

		tRelFrameKey = (tRelFrame == aButton) and "button" or "healthBar";

		if aFrame["staticSlotAnchorPoint"] == tAnchorPoint
			and aFrame["staticSlotRelPoint"] == tRelPoint
			and aFrame["staticSlotRelFrameKey"] == tRelFrameKey
			and aFrame["staticSlotXOff"] == (tXOff or 0)
			and aFrame["staticSlotYOff"] == (tYOff or 0)
			and aFrame["staticSlotWidth"] == (aStaticSlot["width"] or 0)
			and aFrame["staticSlotHeight"] == (aStaticSlot["height"] or 0)
			and aFrame["staticSlotFrameLevelOffset"] == (tFrameLevelOffset or 0)
			and aFrame:GetParent() == aButton then
			return;
		end

		if not InCombatLockdown() then
			if aFrame:GetParent() ~= aButton then
				aFrame:SetParent(aButton);
			end

			aFrame:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(aFrame, tAnchorPoint, tRelFrame, tRelPoint, tXOff, tYOff);
			VUHDO_PixelUtil.SetSize(aFrame, aStaticSlot["width"] or 20, aStaticSlot["height"] or 20);

			tButtonFrameLevel = aButton:GetFrameLevel();

			VUHDO_PixelUtil.SetFrameStrata(aFrame, aButton:GetFrameStrata());
			VUHDO_PixelUtil.SetFrameLevel(aFrame, tButtonFrameLevel + tFrameLevelOffset);

			tChild = aFrame["childB"];

			if tChild then
				tChild:ClearAllPoints();
				tChild:SetAllPoints(aFrame);

				tTexture = tChild["textureI"];

				if tTexture then
					tTexture:SetAllPoints(tChild);
				end

				tChild:SetAlpha(1);
			end

			aFrame["staticSlotAnchorPoint"] = tAnchorPoint;
			aFrame["staticSlotRelPoint"] = tRelPoint;
			aFrame["staticSlotRelFrameKey"] = tRelFrameKey;
			aFrame["staticSlotXOff"] = tXOff or 0;
			aFrame["staticSlotYOff"] = tYOff or 0;
			aFrame["staticSlotWidth"] = aStaticSlot["width"] or 0;
			aFrame["staticSlotHeight"] = aStaticSlot["height"] or 0;
			aFrame["staticSlotFrameLevelOffset"] = tFrameLevelOffset or 0;
		end

		return;

	end



	--
	local tSlotDataAsAura;
	local function VUHDO_fillStaticSlotScratch(anIcon, anExpirationTime, aDuration, anApplications, aName, anAuraInstanceId, aClipL, aClipR, aClipT, aClipB, aColor, aGroupId, anEntryIndex, anIsAliveTime, anIsColorReference)

		tSlotDataAsAura = sStaticSlotAuraScratch;

		tSlotDataAsAura["icon"] = anIcon;
		tSlotDataAsAura["expirationTime"] = anExpirationTime or 0;
		tSlotDataAsAura["duration"] = aDuration or 0;
		tSlotDataAsAura["applications"] = anApplications or 0;
		tSlotDataAsAura["name"] = aName;
		tSlotDataAsAura["auraInstanceID"] = anAuraInstanceId or -1;
		tSlotDataAsAura["clipL"] = aClipL;
		tSlotDataAsAura["clipR"] = aClipR;
		tSlotDataAsAura["clipT"] = aClipT;
		tSlotDataAsAura["clipB"] = aClipB;
		tSlotDataAsAura["groupId"] = aGroupId;
		tSlotDataAsAura["entryIndex"] = anEntryIndex;
		tSlotDataAsAura["isAliveTime"] = anIsAliveTime;

		if anIsColorReference then
			tSlotDataAsAura["color"] = aColor;
		elseif aColor then
			VUHDO_copyColorTo(aColor, sOwnedScratchColor);
			tSlotDataAsAura["color"] = sOwnedScratchColor;
		else
			twipe(sOwnedScratchColor);
			tSlotDataAsAura["color"] = sOwnedScratchColor;
		end

		return tSlotDataAsAura;

	end



	--
	local tInfo;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tSecretBool;
	local tSlotDataAsAura;
	local tButtonName;
	local tAuraFrame;
	local tEvalCacheEntry;
	local function VUHDO_updateMixedStaticBouquetItem(aButton, aUnit, aPanelNum, anAnchorIndex, aContainerData, anAnchorConfig, aStaticSlot, aSlotIndex, aSlotEntryIndex)

		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			VUHDO_hideAuraSlot(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig["style"] == "bars");

			return;
		end

		tEvalCacheEntry = sMixedSlotEvalCache[aSlotEntryIndex];

		if tEvalCacheEntry then
			tIsActive = tEvalCacheEntry[1];
			tIcon = tEvalCacheEntry[2];
			tTimer = tEvalCacheEntry[3];
			tCounter = tEvalCacheEntry[4];
			tDuration = tEvalCacheEntry[5];
			tColor = tEvalCacheEntry[6];
			tBuffName = tEvalCacheEntry[7];
			tClipL = tEvalCacheEntry[8];
			tClipR = tEvalCacheEntry[9];
			tClipT = tEvalCacheEntry[10];
			tClipB = tEvalCacheEntry[11];
			tSecretBool = tEvalCacheEntry[12];
		else
			tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, tClipL, tClipR, tClipT, tClipB, tSecretBool
				= VUHDO_evaluateBouquetItemForStaticSlot(aStaticSlot["bouquetName"], aStaticSlot["itemIndex"], tInfo);
		end

		if issecretvalue(tSecretBool) then
			tSlotDataAsAura = VUHDO_fillStaticSlotScratch(tIcon or "Interface\\Icons\\INV_Misc_QuestionMark", 0, 0, 0, tBuffName, -1, tClipL, tClipR, tClipT, tClipB, tColor, anAnchorConfig["groupId"], aStaticSlot["entryIndex"]);

			VUHDO_displayAuraInSlot(aButton, aPanelNum, anAnchorIndex, aSlotIndex, tSlotDataAsAura, anAnchorConfig);

			tButtonName = aButton:GetName();
			tAuraFrame = tButtonName and VUHDO_AURA_FRAMES[tButtonName] and VUHDO_AURA_FRAMES[tButtonName][anAnchorIndex] and VUHDO_AURA_FRAMES[tButtonName][anAnchorIndex][aSlotIndex];

			if tAuraFrame then
				VUHDO_applyStaticBouquetSlotGeometry(tAuraFrame, aButton, aContainerData["containerTemplate"], aStaticSlot);

				tAuraFrame:SetAlphaFromBoolean(tSecretBool, 1, 0);
			end

			return;
		end

		if tIsActive and tInfo["connected"] and not tInfo["dead"] then
			if tDuration then
				if issecretvalue(tDuration) or issecretvalue(tTimer) then
					tSlotDataAsAura = VUHDO_fillStaticSlotScratch(tIcon, tTimer, tDuration, tCounter or 0, tBuffName, -1, tClipL, tClipR, tClipT, tClipB, tColor, anAnchorConfig["groupId"], aStaticSlot["entryIndex"]);
				elseif tDuration > 0 and tTimer then
					tSlotDataAsAura = VUHDO_fillStaticSlotScratch(tIcon, GetTime() + tTimer, tDuration, tCounter or 0, tBuffName, -1, tClipL, tClipR, tClipT, tClipB, tColor, anAnchorConfig["groupId"], aStaticSlot["entryIndex"]);
				else
					tSlotDataAsAura = VUHDO_fillStaticSlotScratch(tIcon, 0, tDuration, tCounter or 0, tBuffName, -1, tClipL, tClipR, tClipT, tClipB, tColor, anAnchorConfig["groupId"], aStaticSlot["entryIndex"]);
				end
			else
				tSlotDataAsAura = VUHDO_fillStaticSlotScratch(tIcon, 0, 0, tCounter or 0, tBuffName, -1, tClipL, tClipR, tClipT, tClipB, tColor, anAnchorConfig["groupId"], aStaticSlot["entryIndex"]);
			end

			VUHDO_displayAuraInSlot(aButton, aPanelNum, anAnchorIndex, aSlotIndex, tSlotDataAsAura, anAnchorConfig);

			tButtonName = aButton:GetName();
			tAuraFrame = tButtonName and VUHDO_AURA_FRAMES[tButtonName] and VUHDO_AURA_FRAMES[tButtonName][anAnchorIndex] and VUHDO_AURA_FRAMES[tButtonName][anAnchorIndex][aSlotIndex];

			if tAuraFrame then
				VUHDO_applyStaticBouquetSlotGeometry(tAuraFrame, aButton, aContainerData["containerTemplate"], aStaticSlot);

				tAuraFrame:SetAlpha(1);
				tAuraFrame:Show();
			end
		else
			VUHDO_hideAuraSlot(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig["style"] == "bars");
		end

		return;

	end



	--
	local tStaticSlots;
	local tPanelNum;
	local tAnchorIndex;
	local tAnchorConfig;
	local tContainerTemplate;
	local tIsBar;
	local tListSlots;
	local tButtonName;
	local tSlotIndex;
	local tSlotData;
	local tSlotDataAsAura;
	local tAuraFrame;
	local tInfo;
	local tMixedPriorityCutoffs;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tSecretBool;
	local tEntryIndex;
	local tItemIndex;
	local tPriorityCutoff;
	local tContainer;
	local tCanAttack;
	local tEvalCacheEntry;
	local tSlotEntryIndex;
	function VUHDO_updateStaticBouquetSlotsForButton(aButton, aUnit, aContainerData, aCanAttack, anIsSlotFiltersApplied)

		if not aButton or not aUnit or not aContainerData then
			return;
		end

		tStaticSlots = aContainerData["staticSlots"];

		if not tStaticSlots or not next(tStaticSlots) then
			return;
		end

		tPanelNum = aContainerData["panelNum"];
		tAnchorIndex = aContainerData["anchorIndex"];

		if not tPanelNum or not tAnchorIndex then
			return;
		end

		tAnchorConfig = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"][tAnchorIndex];

		if not tAnchorConfig or tAnchorConfig["enabled"] == false then
			return;
		end

		tContainerTemplate = aContainerData["containerTemplate"];
		tIsBar = tAnchorConfig["style"] == "bars";
		tListSlots = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit] and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tPanelNum] and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tPanelNum][tAnchorIndex];
		tButtonName = aButton:GetName();

		tMixedPriorityCutoffs = aContainerData["mixedPriorityCutoffs"];

		if not tMixedPriorityCutoffs then
			tMixedPriorityCutoffs = { };
			aContainerData["mixedPriorityCutoffs"] = tMixedPriorityCutoffs;
		else
			twipe(tMixedPriorityCutoffs);
		end

		twipe(sMixedSlotEvalCache);

		tInfo = VUHDO_RAID[aUnit];

		if tInfo and tInfo["connected"] and not tInfo["dead"] then
			for tSlotEntryIndex, tStaticSlot in pairs(tStaticSlots) do
				if tStaticSlot["isMixedBouquetItem"] then
					tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, tClipL, tClipR, tClipT, tClipB, tSecretBool
						= VUHDO_evaluateBouquetItemForStaticSlot(tStaticSlot["bouquetName"], tStaticSlot["itemIndex"], tInfo);

					tEvalCacheEntry = sMixedSlotEvalCache[tSlotEntryIndex];

					if not tEvalCacheEntry then
						tEvalCacheEntry = { };
						sMixedSlotEvalCache[tSlotEntryIndex] = tEvalCacheEntry;
					end

					tEvalCacheEntry[1] = tIsActive;
					tEvalCacheEntry[2] = tIcon;
					tEvalCacheEntry[3] = tTimer;
					tEvalCacheEntry[4] = tCounter;
					tEvalCacheEntry[5] = tDuration;
					tEvalCacheEntry[6] = tColor;
					tEvalCacheEntry[7] = tBuffName;
					tEvalCacheEntry[8] = tClipL;
					tEvalCacheEntry[9] = tClipR;
					tEvalCacheEntry[10] = tClipT;
					tEvalCacheEntry[11] = tClipB;
					tEvalCacheEntry[12] = tSecretBool;

					if tIsActive and not issecretvalue(tSecretBool) then
						tEntryIndex = tStaticSlot["entryIndex"];
						tItemIndex = tStaticSlot["itemIndex"];

						if tEntryIndex and tItemIndex then
							if not tMixedPriorityCutoffs[tEntryIndex] or tItemIndex < tMixedPriorityCutoffs[tEntryIndex] then
								tMixedPriorityCutoffs[tEntryIndex] = tItemIndex;
							end
						end
					end
				end
			end
		end

		for tSlotEntryIndex, tStaticSlot in pairs(tStaticSlots) do
			tSlotIndex = tStaticSlot["slotIndex"] or tSlotEntryIndex;

			if tStaticSlot["isMixedBouquetItem"] then
				tEntryIndex = tStaticSlot["entryIndex"];
				tItemIndex = tStaticSlot["itemIndex"];
				tPriorityCutoff = tEntryIndex and tMixedPriorityCutoffs[tEntryIndex];

				if tPriorityCutoff and tItemIndex and tItemIndex > tPriorityCutoff then
					VUHDO_hideAuraSlot(aButton, tAnchorIndex, tSlotIndex, tIsBar);
				else
					VUHDO_updateMixedStaticBouquetItem(aButton, aUnit, tPanelNum, tAnchorIndex, aContainerData, tAnchorConfig, tStaticSlot, tSlotIndex, tSlotEntryIndex);
				end
			else
				tSlotData = tListSlots and tListSlots[tStaticSlot["entryIndex"]];

				if tSlotData and tSlotData["isActive"] then
					tSlotDataAsAura = VUHDO_fillStaticSlotScratch(tSlotData["icon"], tSlotData["expirationTime"] or 0, tSlotData["duration"] or 0, tSlotData["stacks"] or 0, tSlotData["name"], tSlotData["auraInstanceID"] or -1, tSlotData["clipL"], tSlotData["clipR"], tSlotData["clipT"], tSlotData["clipB"], tSlotData["color"], tSlotData["groupId"], tSlotData["entryIndex"], tSlotData["isAliveTime"], true);

					VUHDO_displayAuraInSlot(aButton, tPanelNum, tAnchorIndex, tSlotIndex, tSlotDataAsAura, tAnchorConfig);

					tAuraFrame = tButtonName and VUHDO_AURA_FRAMES[tButtonName] and VUHDO_AURA_FRAMES[tButtonName][tAnchorIndex] and VUHDO_AURA_FRAMES[tButtonName][tAnchorIndex][tSlotIndex];

					if tAuraFrame and tContainerTemplate then
						VUHDO_applyStaticBouquetSlotGeometry(tAuraFrame, aButton, tContainerTemplate, tStaticSlot);

						tAuraFrame:SetAlpha(1);
						tAuraFrame:Show();
					end
				else
					VUHDO_hideAuraSlot(aButton, tAnchorIndex, tSlotIndex, tIsBar);
				end
			end
		end

		tContainer = aContainerData["container"];

		if tContainer and not anIsSlotFiltersApplied then
			if aCanAttack == nil then
				tCanAttack = UnitCanAttack("player", aUnit);
			else
				tCanAttack = aCanAttack;
			end

			VUHDO_applyAuraContainerSlotFilters(tContainer, aContainerData, tCanAttack);
		end

		return;

	end



	--
	local tStaticSlots;
	local tAnchorIndex;
	local tPanelNum;
	local tAnchorConfig;
	local tIsBar;
	local tSlotIndex;
	function VUHDO_hideStaticBouquetSlotsForButton(aButton, aContainerData)

		if not aButton or not aContainerData then
			return;
		end

		tStaticSlots = aContainerData["staticSlots"];

		if not tStaticSlots or not next(tStaticSlots) then
			return;
		end

		tAnchorIndex = aContainerData["anchorIndex"];
		tPanelNum = aContainerData["panelNum"];

		if not tAnchorIndex or not tPanelNum then
			return;
		end

		tAnchorConfig = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"][tAnchorIndex];
		tIsBar = tAnchorConfig and tAnchorConfig["style"] == "bars";

		for tSlotEntryIndex, tStaticSlot in pairs(tStaticSlots) do
			tSlotIndex = tStaticSlot["slotIndex"] or tSlotEntryIndex;

			VUHDO_hideAuraSlot(aButton, tAnchorIndex, tSlotIndex, tIsBar);
		end

		return;

	end



	--
	local tAnchorConfig;
	local tPanelUnitButtons;
	local tButtonName;
	local tContainerData;
	function VUHDO_updateStaticBouquetSlotsForUnit(aUnit, aPanelNum, anAnchorIndex)

		if not aUnit or not aPanelNum or not anAnchorIndex then
			return;
		end

		tAnchorConfig = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"][anAnchorIndex];

		if not tAnchorConfig or tAnchorConfig["enabled"] == false then
			return;
		end

		tPanelUnitButtons = VUHDO_getUnitButtonsPanel(aUnit, aPanelNum);

		if not tPanelUnitButtons or next(tPanelUnitButtons) == nil then
			return;
		end

		for _, tButton in pairs(tPanelUnitButtons) do
			tButtonName = tButton:GetName();

			if tButtonName and VUHDO_AURA_CONTAINERS[tButtonName] then
				tContainerData = VUHDO_AURA_CONTAINERS[tButtonName][anAnchorIndex];

				if tContainerData and tContainerData["staticSlots"] and next(tContainerData["staticSlots"]) then
					VUHDO_updateStaticBouquetSlotsForButton(tButton, aUnit, tContainerData);
				end
			end
		end

		return;

	end

end