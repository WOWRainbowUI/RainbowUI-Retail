local _;

local pairs = pairs;
local ipairs = ipairs;
local next = next;
local tinsert = table.insert;
local tsort = table.sort;
local twipe = table.wipe;

local InCombatLockdown = InCombatLockdown;
local UnitExists = UnitExists;
local issecretvalue = issecretvalue;

local VUHDO_BUFF_SETTINGS;
local VUHDO_BUFF_ORDER;
local VUHDO_BUFFS;
local VUHDO_RAID;
local VUHDO_MISSING_BUFF_CONTAINERS;
local VUHDO_AURA_CONTAINER_GATE_STATE;
local VUHDO_BUTTON_CACHE;
local VUHDO_PANEL_SETUP;

local VUHDO_isAuraModeContainers;
local VUHDO_getHealthBar;
local VUHDO_getHealthBarWidth;
local VUHDO_getPlayerClassBuffs;
local VUHDO_isMissingBuffCategoryContainerable;
local VUHDO_isMissingBuffWatchUnit;
local VUHDO_getUnitButtonsSafe;
local VUHDO_addResolvedAuraContainerSpellIds;
local VUHDO_buildMissingBuffContainerTemplate;
local VUHDO_acquireAuraContainer;
local VUHDO_retireAuraContainer;
local VUHDO_getAuraContainerBuildSignature;
local VUHDO_setMissingBuffBarColor;
local VUHDO_applyStoredMissingBuffBarColor;
local VUHDO_setMissingBuffBarShown;
local VUHDO_refreshMissingBuffBarFill;
local VUHDO_clearAuraContainerUnit;
local VUHDO_refreshAuraContainer;
local VUHDO_rewriteAuraContainerGateState;
local VUHDO_timeRefreshMissingBuffContainers;
local VUHDO_isDeferredRedrawActiveForPanel;

local sEmpty = { };
local sMissingBuffPlanGeneration = 0;
local sMissingBuffLastGeneration = { };
local sMissingBuffLastBarWidth = { };
local sMissingBuffLastBarHeight = { };
local sMissingBuffPlannedCategs = { };
local sMissingBuffKnownKeys = { };
local sMissingBuffCurrentKeys = { };



--
function VUHDO_buffWatchContainersInitLocalOverrides()

	VUHDO_BUFF_SETTINGS = _G["VUHDO_BUFF_SETTINGS"];
	VUHDO_BUFF_ORDER = _G["VUHDO_BUFF_ORDER"];
	VUHDO_BUFFS = _G["VUHDO_BUFFS"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_MISSING_BUFF_CONTAINERS = _G["VUHDO_MISSING_BUFF_CONTAINERS"];
	VUHDO_AURA_CONTAINER_GATE_STATE = _G["VUHDO_AURA_CONTAINER_GATE_STATE"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];

	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getHealthBarWidth = _G["VUHDO_getHealthBarWidth"];
	VUHDO_getPlayerClassBuffs = _G["VUHDO_getPlayerClassBuffs"];
	VUHDO_isMissingBuffCategoryContainerable = _G["VUHDO_isMissingBuffCategoryContainerable"];
	VUHDO_isMissingBuffWatchUnit = _G["VUHDO_isMissingBuffWatchUnit"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_addResolvedAuraContainerSpellIds = _G["VUHDO_addResolvedAuraContainerSpellIds"];
	VUHDO_buildMissingBuffContainerTemplate = _G["VUHDO_buildMissingBuffContainerTemplate"];
	VUHDO_acquireAuraContainer = _G["VUHDO_acquireAuraContainer"];
	VUHDO_retireAuraContainer = _G["VUHDO_retireAuraContainer"];
	VUHDO_getAuraContainerBuildSignature = _G["VUHDO_getAuraContainerBuildSignature"];
	VUHDO_setMissingBuffBarColor = _G["VUHDO_setMissingBuffBarColor"];
	VUHDO_applyStoredMissingBuffBarColor = _G["VUHDO_applyStoredMissingBuffBarColor"];
	VUHDO_setMissingBuffBarShown = _G["VUHDO_setMissingBuffBarShown"];
	VUHDO_refreshMissingBuffBarFill = _G["VUHDO_refreshMissingBuffBarFill"];
	VUHDO_clearAuraContainerUnit = _G["VUHDO_clearAuraContainerUnit"];
	VUHDO_refreshAuraContainer = _G["VUHDO_refreshAuraContainer"];
	VUHDO_rewriteAuraContainerGateState = _G["VUHDO_rewriteAuraContainerGateState"];
	VUHDO_timeRefreshMissingBuffContainers = _G["VUHDO_timeRefreshMissingBuffContainers"];
	VUHDO_isDeferredRedrawActiveForPanel = _G["VUHDO_isDeferredRedrawActiveForPanel"];

	return;

end



do
	--
	local tSettings;
	function VUHDO_isMissingBuffCategoryEnabled(aCategName)

		tSettings = VUHDO_BUFF_SETTINGS[aCategName];

		if not tSettings or not (tSettings["missingColor"] or sEmpty)["show"] then
			return false;
		end

		for _, tCategSpells in pairs(VUHDO_getPlayerClassBuffs()[aCategName] or sEmpty) do
			if VUHDO_BUFFS[tCategSpells[1]] then
				return VUHDO_isMissingBuffCategoryContainerable(aCategName);
			end
		end

		return false;

	end
end



--
local function VUHDO_compareMissingBuffPlanOrder(aLeftCategName, aRightCategName)

	return VUHDO_BUFF_ORDER[aLeftCategName] < VUHDO_BUFF_ORDER[aRightCategName];

end



do
	--
	local tSpellName;
	function VUHDO_collectMissingBuffSpellIds(aCategName, aDest)

		for _, tCategSpells in pairs(VUHDO_getPlayerClassBuffs()[aCategName] or sEmpty) do
			tSpellName = tCategSpells[1];

			if VUHDO_BUFFS[tSpellName] then
				VUHDO_addResolvedAuraContainerSpellIds(aDest, tSpellName);
			end
		end

		return;

	end
end



do
	--
	local tTargetBar;
	local tBarWidth;
	local tBarHeight;
	local tExisting;
	local tCategName;
	local tStillPlanned;
	local tSpellIds;
	local tMissingColor;
	local tSublevel;
	local tContainerTemplate;
	local tBuildSignature;
	local tExistingData;
	local tBarTexture;
	local tAllAcquired;
	local tBuffOrderKey;
	function VUHDO_reconcileMissingBuffContainersForButton(aButton, aButtonName, aPanelNum)

		if not aButton or not aButtonName then
			return;
		end

		tExisting = VUHDO_MISSING_BUFF_CONTAINERS[aButtonName];

		if not VUHDO_isAuraModeContainers() then
			if tExisting then
				for tCategName, tExistingData in pairs(tExisting) do
					VUHDO_retireAuraContainer(aButton, tExistingData);

					tExisting[tCategName] = nil;
				end

				VUHDO_MISSING_BUFF_CONTAINERS[aButtonName] = nil;
			end

			return;
		end

		if InCombatLockdown() then
			VUHDO_timeRefreshMissingBuffContainers(0.1);

			return;
		end

		tTargetBar = VUHDO_getHealthBar(aButton, 1);

		if not tTargetBar or not aPanelNum then
			return;
		end

		tBarWidth = VUHDO_getHealthBarWidth(aPanelNum);
		tBarHeight = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barHeight"];

		if VUHDO_MISSING_BUFF_CONTAINERS[aButtonName]
			and sMissingBuffLastGeneration[aButtonName] == sMissingBuffPlanGeneration
			and sMissingBuffLastBarWidth[aButtonName] == tBarWidth
			and sMissingBuffLastBarHeight[aButtonName] == tBarHeight then
			return;
		end

		tBuffOrderKey = next(VUHDO_BUFF_ORDER);

		if not tBuffOrderKey or not next(VUHDO_BUFFS) then
			VUHDO_timeRefreshMissingBuffContainers(0.1);

			return;
		end

		tAllAcquired = true;

		twipe(sMissingBuffPlannedCategs);

		for tCategName, _ in pairs(VUHDO_BUFF_ORDER) do
			if VUHDO_isMissingBuffCategoryEnabled(tCategName) then
				tinsert(sMissingBuffPlannedCategs, tCategName);
			end
		end

		tsort(sMissingBuffPlannedCategs, VUHDO_compareMissingBuffPlanOrder);

		if not VUHDO_MISSING_BUFF_CONTAINERS[aButtonName] then
			VUHDO_MISSING_BUFF_CONTAINERS[aButtonName] = { };
		end

		tExisting = VUHDO_MISSING_BUFF_CONTAINERS[aButtonName];

		for tCategName, tExistingData in pairs(tExisting) do
			tStillPlanned = false;

			for tCnt = 1, #sMissingBuffPlannedCategs do
				if sMissingBuffPlannedCategs[tCnt] == tCategName then
					tStillPlanned = true;

					break;
				end
			end

			if not tStillPlanned then
				VUHDO_retireAuraContainer(aButton, tExistingData);

				tExisting[tCategName] = nil;
			end
		end

		for tCnt = 1, #sMissingBuffPlannedCategs do
			tCategName = sMissingBuffPlannedCategs[tCnt];

			tSpellIds = { };

			VUHDO_collectMissingBuffSpellIds(tCategName, tSpellIds);

			tMissingColor = VUHDO_BUFF_SETTINGS[tCategName]["missingColor"];
			tSublevel = 7 - (tCnt - 1);

			if tSublevel < 1 then
				tSublevel = 1;
			end

			tContainerTemplate = VUHDO_buildMissingBuffContainerTemplate(aButton, tTargetBar, tCategName,
				tSpellIds, tBarWidth, tBarHeight, 1, tSublevel, tCnt);

			tBuildSignature = VUHDO_getAuraContainerBuildSignature(tContainerTemplate);

			tExistingData = tExisting[tCategName];

			if tExistingData and tExistingData["buildSignature"] == tBuildSignature then
				VUHDO_refreshMissingBuffBarFill(tExistingData, true);
				VUHDO_setMissingBuffBarColor(aButtonName, tCategName, tMissingColor);
				VUHDO_applyStoredMissingBuffBarColor(aButtonName, tCategName, tExistingData);

				tBarTexture = tExistingData["missingBuffBarTexture"];

				if tBarTexture then
					tBarTexture:SetDrawLayer("ARTWORK", tSublevel);
				end
			else
				if tExistingData then
					VUHDO_retireAuraContainer(aButton, tExistingData);
				end

				tExistingData = VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

				if tExistingData then
					VUHDO_setMissingBuffBarColor(aButtonName, tCategName, tMissingColor);
					VUHDO_applyStoredMissingBuffBarColor(aButtonName, tCategName, tExistingData);
					VUHDO_setMissingBuffBarShown(tExistingData, true);

					tExisting[tCategName] = tExistingData;
				else
					tAllAcquired = false;
				end
			end
		end

		if tAllAcquired then
			sMissingBuffLastGeneration[aButtonName] = sMissingBuffPlanGeneration;
			sMissingBuffLastBarWidth[aButtonName] = tBarWidth;
			sMissingBuffLastBarHeight[aButtonName] = tBarHeight;
		else
			VUHDO_timeRefreshMissingBuffContainers(0.1);
		end

		return;

	end
end



--
function VUHDO_clearMissingBuffBuildKey(aButtonName)

	if not aButtonName then
		return;
	end

	sMissingBuffLastGeneration[aButtonName] = nil;
	sMissingBuffLastBarWidth[aButtonName] = nil;
	sMissingBuffLastBarHeight[aButtonName] = nil;

	return;

end



do
	--
	local tButtonName;
	local tContainer;
	local tIsDisconnected;
	local tIsEnabled;
	local tIsWatched;
	local tUnitRebound;
	local tOccupantGuid;
	local tLastSyncedGuid;
	local tEnabledChanged;
	local tWatchedChanged;
	local tIsVisible;
	local tVisibleChanged;
	local tShowTint;
	local tBuffConfig;
	local tShowBar;
	local tBarGateChanged;
	function VUHDO_syncMissingBuffContainersForButton(aButton, aUnit)

		if not aButton or not aUnit then
			return;
		end

		tButtonName = aButton:GetName();

		if not tButtonName or not VUHDO_MISSING_BUFF_CONTAINERS[tButtonName] then
			return;
		end

		if not UnitExists(aUnit) then
			for tCategName, tContainerData in pairs(VUHDO_MISSING_BUFF_CONTAINERS[tButtonName]) do
				tContainer = tContainerData and tContainerData["container"];

				if tContainer then
					VUHDO_clearAuraContainerUnit(tContainer, tContainerData);
				end

				VUHDO_setMissingBuffBarShown(tContainerData, false);

				tContainerData["lastSyncedEnabled"] = false;
				tContainerData["lastSyncedWatched"] = false;
				tContainerData["lastSyncedBarGate"] = false;
				tContainerData["lastSyncedVisible"] = false;
				tContainerData["aurasRefreshed"] = nil;
			end

			return;
		end

		VUHDO_rewriteAuraContainerGateState(aUnit);

		tIsDisconnected = VUHDO_AURA_CONTAINER_GATE_STATE["isDisconnected"];

		for tCategName, tContainerData in pairs(VUHDO_MISSING_BUFF_CONTAINERS[tButtonName]) do
			tContainer = tContainerData and tContainerData["container"];

			if tContainer then
				tUnitRebound = false;

				tIsEnabled = not tIsDisconnected;
				tIsWatched = VUHDO_isMissingBuffWatchUnit(tCategName, aUnit);

				if tIsEnabled then
					tUnitRebound = tContainerData["lastSyncedUnit"] ~= aUnit;

					if not tUnitRebound then
						tOccupantGuid = VUHDO_RAID[aUnit] and VUHDO_RAID[aUnit]["guid"];
						tLastSyncedGuid = tContainerData["lastSyncedGuid"];

						if not tOccupantGuid or issecretvalue(tOccupantGuid) then
							tUnitRebound = true;
						elseif not tLastSyncedGuid or issecretvalue(tLastSyncedGuid) then
							tUnitRebound = true;
						elseif tLastSyncedGuid ~= tOccupantGuid then
							tUnitRebound = true;
						end
					end

					if tUnitRebound then
						tContainer:SetUnit(aUnit);

						tOccupantGuid = VUHDO_RAID[aUnit] and VUHDO_RAID[aUnit]["guid"];

						if tOccupantGuid and issecretvalue(tOccupantGuid) then
							tOccupantGuid = nil;
						end

						tContainerData["lastSyncedUnit"] = aUnit;
						tContainerData["lastSyncedGuid"] = tOccupantGuid;
						tContainerData["aurasRefreshed"] = nil;
					end
				end

				if tContainer:IsEnabled() ~= tIsEnabled then
					tContainer:SetEnabled(tIsEnabled);
				end

				if tContainer:IsShown() ~= tIsEnabled then
					tContainer:SetShown(tIsEnabled);
				end

				tEnabledChanged = tIsEnabled ~= tContainerData["lastSyncedEnabled"];
				tWatchedChanged = tIsWatched ~= tContainerData["lastSyncedWatched"];

				tBuffConfig = VUHDO_BUFF_SETTINGS["CONFIG"] or sEmpty;
				tShowBar = tBuffConfig["BAR_COLORS_BACKGROUND"] and (tBuffConfig["BAR_COLORS_IN_FIGHT"] or not InCombatLockdown());
				tShowTint = tIsEnabled and tIsWatched and tShowBar;

				tBarGateChanged = tShowBar ~= tContainerData["lastSyncedBarGate"];

				if tEnabledChanged or tWatchedChanged or tBarGateChanged or (tIsEnabled and tUnitRebound) then
					VUHDO_setMissingBuffBarShown(tContainerData, tShowTint);

					tContainerData["lastSyncedEnabled"] = tIsEnabled;
					tContainerData["lastSyncedWatched"] = tIsWatched;
					tContainerData["lastSyncedBarGate"] = tShowBar;
				end

				tIsVisible = aButton:IsVisible();
				tVisibleChanged = tIsVisible ~= tContainerData["lastSyncedVisible"];

				if tVisibleChanged then
					tContainerData["lastSyncedVisible"] = tIsVisible;
				end

				if tIsEnabled then
					VUHDO_refreshMissingBuffBarFill(tContainerData);

					if tUnitRebound or tEnabledChanged or tVisibleChanged
						or not tContainerData["aurasRefreshed"] then

						if VUHDO_refreshAuraContainer(tContainer) then
							tContainerData["aurasRefreshed"] = true;
						end
					end
				end
			end
		end

		return;

	end
end



do
	--
	local tButtonName;
	local tPanelNum;
	local tHasDeferredPanels;
	function VUHDO_refreshAllMissingBuffContainers()

		if not VUHDO_isAuraModeContainers() or not VUHDO_RAID then
			return false;
		end

		tHasDeferredPanels = false;

		for tUnit, _ in pairs(VUHDO_RAID) do
			for _, tButton in pairs(VUHDO_getUnitButtonsSafe(tUnit)) do
				tButtonName = tButton:GetName();
				tPanelNum = VUHDO_BUTTON_CACHE[tButton];

				if tPanelNum and VUHDO_isDeferredRedrawActiveForPanel(tPanelNum) then
					tHasDeferredPanels = true;
				elseif tButtonName and tPanelNum then
					VUHDO_reconcileMissingBuffContainersForButton(tButton, tButtonName, tPanelNum);

					VUHDO_syncMissingBuffContainersForButton(tButton, tUnit);
				else
					VUHDO_syncMissingBuffContainersForButton(tButton, tUnit);
				end
			end
		end

		return tHasDeferredPanels;

	end
end



do
	--
	local tMissingColor;
	function VUHDO_applyMissingBuffContainerColors()

		for tButtonName, tCategEntry in pairs(VUHDO_MISSING_BUFF_CONTAINERS) do
			for tCategName, tContainerData in pairs(tCategEntry) do
				tMissingColor = (VUHDO_BUFF_SETTINGS[tCategName] or sEmpty)["missingColor"];

				if tMissingColor then
					VUHDO_refreshMissingBuffBarFill(tContainerData, true);
					VUHDO_setMissingBuffBarColor(tButtonName, tCategName, tMissingColor);
					VUHDO_applyStoredMissingBuffBarColor(tButtonName, tCategName, tContainerData);
				end
			end
		end

		return;

	end
end



do
	--
	local tCategName;
	local tKeyCount;
	local tIsChanged;
	function VUHDO_invalidateMissingBuffContainerPlansIfNeeded()

		twipe(sMissingBuffPlannedCategs);

		for tCategName, _ in pairs(VUHDO_BUFF_ORDER) do
			if VUHDO_isMissingBuffCategoryEnabled(tCategName) then
				tinsert(sMissingBuffPlannedCategs, tCategName);
			end
		end

		tsort(sMissingBuffPlannedCategs, VUHDO_compareMissingBuffPlanOrder);

		twipe(sMissingBuffCurrentKeys);

		for tCnt = 1, #sMissingBuffPlannedCategs do
			tCategName = sMissingBuffPlannedCategs[tCnt];

			tinsert(sMissingBuffCurrentKeys, tCategName);

			for _, tCategSpells in ipairs(VUHDO_getPlayerClassBuffs()[tCategName] or sEmpty) do
				if VUHDO_BUFFS[tCategSpells[1]] then
					tinsert(sMissingBuffCurrentKeys, tCategSpells[1]);
				end
			end
		end

		tKeyCount = #sMissingBuffCurrentKeys;
		tIsChanged = tKeyCount ~= #sMissingBuffKnownKeys;

		if not tIsChanged then
			for tCnt = 1, tKeyCount do
				if sMissingBuffCurrentKeys[tCnt] ~= sMissingBuffKnownKeys[tCnt] then
					tIsChanged = true;

					break;
				end
			end
		end

		if not tIsChanged then
			return;
		end

		twipe(sMissingBuffKnownKeys);

		for tCnt = 1, tKeyCount do
			sMissingBuffKnownKeys[tCnt] = sMissingBuffCurrentKeys[tCnt];
		end

		sMissingBuffPlanGeneration = sMissingBuffPlanGeneration + 1;

		VUHDO_timeRefreshMissingBuffContainers(0.1);

		return;

	end
end



--
function VUHDO_invalidateMissingBuffContainerPlans()

	sMissingBuffPlanGeneration = sMissingBuffPlanGeneration + 1;

	VUHDO_refreshAllMissingBuffContainers();

	return;

end