local _;

local UnitInRange = UnitInRange;
local issecretvalue = issecretvalue;

local VUHDO_IMMEDIATE = Enum.StatusBarInterpolation.Immediate;

local VUHDO_setStatusBarVuhDoColor;
local VUHDO_applyAllLayersToBar;
local VUHDO_applyAllLayersToTexture;
local VUHDO_applyOverlayBouquetGating;
local VUHDO_getIsDirectionArrow;
local VUHDO_deferSyncAuraContainersForUnit;
local VUHDO_isUnitRangeCheckable;
local VUHDO_isUnitRangeEventDriven;
local VUHDO_getUnitButtons;
local VUHDO_deferUpdateHealthBarsFor;
local VUHDO_updateBouquetsForEvent;
local VUHDO_updateHealthBarsFor;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local sThreatInterpolation = { };



--
function VUHDO_barCustomizerThreatInitLocalOverrides()

	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];
	VUHDO_applyAllLayersToTexture = _G["VUHDO_applyAllLayersToTexture"];
	VUHDO_applyOverlayBouquetGating = _G["VUHDO_applyOverlayBouquetGating"];
	VUHDO_getIsDirectionArrow = _G["VUHDO_getIsDirectionArrow"];
	VUHDO_deferSyncAuraContainersForUnit = _G["VUHDO_deferSyncAuraContainersForUnit"];
	VUHDO_isUnitRangeCheckable = _G["VUHDO_isUnitRangeCheckable"];
	VUHDO_isUnitRangeEventDriven = _G["VUHDO_isUnitRangeEventDriven"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_deferUpdateHealthBarsFor = _G["VUHDO_deferUpdateHealthBarsFor"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];

	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		sThreatInterpolation[tCnt] = VUHDO_INDICATOR_CONFIG[tCnt]["CUSTOM"]["THREAT_BAR"]["smooth"]
			and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate;
	end

	return;

end



--
local tTexture;
function VUHDO_threatIndicatorsBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["THREAT_MARK"] == aBouquetName then
			tTexture = VUHDO_getAggroTexture(VUHDO_getHealthBar(tButton, 1));

			if anIsActive then
				if aLayerTemplate then
					VUHDO_applyAllLayersToTexture(tButton, tTexture, aLayerTemplate, "THREAT_MARK", aBouquetName);
				elseif aColor then
					tTexture:SetVertexColor(VUHDO_backColorWithFallback(aColor));
				end

				tTexture:Show();

				VUHDO_startThreatMarkTextureFlash(tTexture);
			else
				VUHDO_stopThreatMarkTextureFlash(tTexture);

				tTexture:Hide();

				if aLayerTemplate then
					VUHDO_applyOverlayBouquetGating(tButton, "THREAT_MARK", aBouquetName, aLayerTemplate, nil);
				end
			end
		end
	end

end



--
local tBar;
local tPanelNum;
local tInterpolation;
function VUHDO_threatBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate, anIsAliveTime, anEventType)

	if -1 == anEventType then -- VUHDO_UPDATE_BOUQUET_RESET
		return;
	end

	aMaxValue = aMaxValue or 1;
	aCurrValue = aCurrValue or 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["THREAT_BAR"] == aBouquetName then
			tBar = VUHDO_getHealthBar(tButton, 7);

			tInterpolation = (tBar["forceImmediate"] or 1 == anEventType) and VUHDO_IMMEDIATE or sThreatInterpolation[tPanelNum];
			tBar["forceImmediate"] = nil;

			tBar:SetMinMaxValues(0, aMaxValue);

			if tBar["isInverted"] then
				tBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue), tInterpolation);
			else
				tBar:SetValue(aCurrValue, tInterpolation);
			end

			if anIsActive then
				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tBar, aLayerTemplate, "THREAT_BAR", aBouquetName);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tBar, aColor);
				end
			end

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "THREAT_BAR", VUHDO_RAID[aUnit]);
			end
		end
	end

	return;

end



function VUHDO_threatBarTextCallback(...)
	VUHDO_indicatorTextCallback(7, ...);
end



--
local tUnitInfo;
local tOldAggro;
local tOldThreatPerc;
local tOldHasSecretThreat;
local tUnitTarget;
local tThreatPerc;
function VUHDO_updateUnitAggro(aUnit, aMode)

	if not VUHDO_RAID or not VUHDO_INTERNAL_TOGGLES then
		return;
	end

	tUnitInfo = VUHDO_RAID[aUnit];

	if tUnitInfo and tUnitInfo["connected"] and not tUnitInfo["dead"] then
		tOldAggro = tUnitInfo["aggro"];
		tOldThreatPerc = tUnitInfo["threatPerc"];
		tOldHasSecretThreat = tUnitInfo["hasSecretThreat"];

		-- 3 = tanking, others less than 100%
		-- 2 = tanking, others more than 100%
		-- 1 = not tanking, more than 100%
		-- 0 = not tanking, less than 100%
		tUnitInfo["threat"] = UnitThreatSituation(aUnit) or 0;
		tUnitInfo["aggro"] = false;

		if VUHDO_INTERNAL_TOGGLES[7] and (tUnitInfo["threat"] or 0) >= 2 then
			tUnitInfo["aggro"] = true;
		end

		tUnitTarget = tUnitInfo["targetUnit"];
		tUnitInfo["threatPerc"] = 0;
		tUnitInfo["hasSecretThreat"] = false;

		if tUnitTarget and UnitIsEnemy(aUnit, tUnitTarget) then
			if VUHDO_INTERNAL_TOGGLES[14] then
				_, _, tThreatPerc = UnitDetailedThreatSituation(aUnit, tUnitTarget);

				tUnitInfo["threatPerc"] = tThreatPerc or 0;
				tUnitInfo["hasSecretThreat"] = sSecretsEnabled and tThreatPerc and issecretvalue(tThreatPerc);
			end
		end

		if tUnitInfo["aggro"] ~= tOldAggro then
			VUHDO_updateHealthBarsFor(aUnit, 7);
		end

		if tUnitInfo["hasSecretThreat"] or tOldHasSecretThreat or tUnitInfo["threatPerc"] ~= tOldThreatPerc then
			VUHDO_updateBouquetsForEvent(aUnit, 14);
		end
	end

	return;

end



--
local function VUHDO_queueRangeBarUpdate(aUnit)

	if VUHDO_getUnitButtons(aUnit) then
		VUHDO_deferUpdateHealthBarsFor(aUnit, 5);
	else
		VUHDO_updateBouquetsForEvent(aUnit, 5);
	end

	return;

end



--
local function VUHDO_queueCharmBarUpdate(aUnit)

	if VUHDO_getUnitButtons(aUnit) then
		VUHDO_deferUpdateHealthBarsFor(aUnit, 4);
	else
		VUHDO_updateBouquetsForEvent(aUnit, 4);
	end

	return;

end



--
local tUnitInfo;
local tIsInRange;
function VUHDO_updateUnitRange(aUnit, aMode)

	if not VUHDO_RAID then
		return;
	end

	tUnitInfo = VUHDO_RAID[aUnit];

	if tUnitInfo then
		tUnitInfo["isEventRange"] = VUHDO_isUnitRangeEventDriven(aUnit);

		tIsInRange = VUHDO_isInRange(aUnit, true);

		if sSecretsEnabled then
			tUnitInfo["hasSecretRange"] = issecretvalue(tIsInRange);
		end

		if sSecretsEnabled and tUnitInfo["hasSecretRange"] then
			tUnitInfo["range"] = tIsInRange;

			VUHDO_queueRangeBarUpdate(aUnit);

			if VUHDO_getIsDirectionArrow() and VUHDO_getCurrentMouseOver() == aUnit
				and (VuhDoDirectionFrame["shown"] or VUHDO_CONFIG["DIRECTION"]["isAlways"]) then
				VUHDO_updateDirectionFrame();
			end
		else
			if issecretvalue(tUnitInfo["range"]) or tUnitInfo["range"] ~= tIsInRange then
				tUnitInfo["range"] = tIsInRange;

				VUHDO_queueRangeBarUpdate(aUnit);

				if VUHDO_getIsDirectionArrow() and VUHDO_getCurrentMouseOver() == aUnit
					and (VuhDoDirectionFrame["shown"] or (not tIsInRange or VUHDO_CONFIG["DIRECTION"]["isAlways"])) then
					VUHDO_updateDirectionFrame();
				end
			end
		end
	end

	return;

end



--
local tUnitInfo;
local tPolledRange;
function VUHDO_onUnitInRangeUpdate(aUnit, anIsInRange)

	if not VUHDO_RAID then
		return;
	end

	tUnitInfo = VUHDO_RAID[aUnit];

	if not tUnitInfo then
		return;
	end

	if not VUHDO_isUnitRangeCheckable(aUnit) then
		tUnitInfo["isEventRange"] = VUHDO_isUnitRangeEventDriven(aUnit);

		VUHDO_updateUnitRange(aUnit);

		return;
	end

	tUnitInfo["baseRange"] = anIsInRange;
	tUnitInfo["isEventRange"] = VUHDO_isUnitRangeEventDriven(aUnit);

	if sSecretsEnabled then
		tUnitInfo["hasSecretRange"] = issecretvalue(anIsInRange);
	end

	if sSecretsEnabled and tUnitInfo["hasSecretRange"] then
		tPolledRange = VUHDO_isInRange(aUnit, true);

		if not issecretvalue(tPolledRange) then
			anIsInRange = tPolledRange;
			tUnitInfo["baseRange"] = anIsInRange;

			tUnitInfo["hasSecretRange"] = false;
		end
	end

	if sSecretsEnabled and tUnitInfo["hasSecretRange"] then
		tUnitInfo["range"] = anIsInRange;

		VUHDO_queueRangeBarUpdate(aUnit);

		if VUHDO_getIsDirectionArrow() and VUHDO_getCurrentMouseOver() == aUnit
			and (VuhDoDirectionFrame["shown"] or VUHDO_CONFIG["DIRECTION"]["isAlways"]) then
			VUHDO_updateDirectionFrame();
		end
	else
		if issecretvalue(tUnitInfo["range"]) or tUnitInfo["range"] ~= anIsInRange then
			tUnitInfo["range"] = anIsInRange;

			VUHDO_queueRangeBarUpdate(aUnit);

			if VUHDO_getIsDirectionArrow() and VUHDO_getCurrentMouseOver() == aUnit
				and (VuhDoDirectionFrame["shown"] or (not anIsInRange or VUHDO_CONFIG["DIRECTION"]["isAlways"])) then
				VUHDO_updateDirectionFrame();
			end
		end
	end

	return;

end



--
local tUnitInfo;
local tIsCharmed;
local tUnitCharmed;
local tUnitCanAttack;
local tWasVisible;
local tOldHasSecretCharmed;
local tOldCanAttack;
local tOldDead;
function VUHDO_updateUnitVisibilityCharmRange(aUnit, anIsFromEvent)

	if not VUHDO_RAID then
		return;
	end

	tUnitInfo = VUHDO_RAID[aUnit];

	if not tUnitInfo then
		return;
	end

	tWasVisible = tUnitInfo["visible"];

	tUnitInfo["visible"] = UnitIsVisible(aUnit);

	if tWasVisible ~= tUnitInfo["visible"] then
		VUHDO_deferSyncAuraContainersForUnit(aUnit, VUHDO_DEFERRED_TASK_PRIORITY_HIGH);
	end

	if not tUnitInfo["isEventRange"] then
		if "player" == aUnit or "pet" == aUnit or not VUHDO_isUnitRangeCheckable(aUnit) then
			tUnitInfo["baseRange"] = true;
		else
			tUnitInfo["baseRange"] = UnitInRange(aUnit);
		end
	end

	tUnitCharmed = UnitIsCharmed(aUnit);

	if sSecretsEnabled and issecretvalue(tUnitCharmed) then
		tOldHasSecretCharmed = tUnitInfo["hasSecretCharmed"];
		tOldCanAttack = tUnitInfo["canAttack"];
		tOldDead = tUnitInfo["dead"];

		tUnitCanAttack = UnitCanAttack("player", aUnit);

		if not tUnitInfo["dead"] and tUnitCanAttack then
			tUnitInfo["hasSecretCharmed"] = true;
			tUnitInfo["secretCharmed"] = tUnitCharmed;
		else
			tUnitInfo["hasSecretCharmed"] = false;
			tUnitInfo["secretCharmed"] = nil;
		end

		tUnitInfo["canAttack"] = tUnitCanAttack;

		if anIsFromEvent or tOldHasSecretCharmed ~= tUnitInfo["hasSecretCharmed"] or tOldDead ~= tUnitInfo["dead"] or tOldCanAttack ~= tUnitCanAttack then
			VUHDO_queueCharmBarUpdate(aUnit);
		end

		return;
	end

	tUnitInfo["hasSecretCharmed"] = false;
	tUnitInfo["secretCharmed"] = nil;

	tUnitCanAttack = UnitCanAttack("player", aUnit);
	tIsCharmed = tUnitCharmed and tUnitCanAttack and not tUnitInfo["dead"];

	if tUnitInfo["charmed"] ~= tIsCharmed then
		tUnitInfo["charmed"] = tIsCharmed;
		tUnitInfo["canAttack"] = tUnitCanAttack;

		VUHDO_queueCharmBarUpdate(aUnit);
	end

	return;

end



--
function VUHDO_updateAllAggro()

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateUnitAggro(tUnit);
	end

	return;

end



--
function VUHDO_updateAllRange()

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		if not VUHDO_RAID[tUnit]["isEventRange"] then
			VUHDO_updateUnitRange(tUnit);
		end
	end

	return;

end



--
function VUHDO_updateAllVisibilityCharmRange()

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateUnitVisibilityCharmRange(tUnit);
	end

	return;

end



--
function VUHDO_deferUpdateAllAggro(aPriority)

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_AGGRO, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, tUnit);
	end

	return;

end



--
function VUHDO_deferUpdateAllRange(aPriority)

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_RANGE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, tUnit);
	end

	return;

end



--
function VUHDO_deferUpdateAllVisibilityCharmRange(aPriority)

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_VISIBILITY_CHARM_RANGE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, tUnit);
	end

	return;

end



--
function VUHDO_deferUpdateUnitAggro(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_AGGRO, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit);

	return;

end



--
function VUHDO_deferUpdateUnitRange(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_RANGE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit);

	return;

end



--
function VUHDO_deferUpdateUnitVisibilityCharmRange(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_VISIBILITY_CHARM_RANGE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit);

	return;

end