local _;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local issecretvalue = issecretvalue;

local VUHDO_setStatusBarVuhDoColor;
local VUHDO_applyAllLayersToBar;
local VUHDO_applyAllLayersToTexture;
local VUHDO_getIsDirectionArrow;



--
function VUHDO_barCustomizerThreatInitLocalOverrides()

	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];
	VUHDO_applyAllLayersToTexture = _G["VUHDO_applyAllLayersToTexture"];
	VUHDO_getIsDirectionArrow = _G["VUHDO_getIsDirectionArrow"];

	return;

end



--
local tTexture;
function VUHDO_threatIndicatorsBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["THREAT_MARK"] == aBouquetName then
			tTexture = VUHDO_getAggroTexture(VUHDO_getHealthBar(tButton, 1));

			if anIsActive then
				tTexture:ClearAllPoints();
				VUHDO_PixelUtil.SetPoint(tTexture, "TOPLEFT", tButton, "TOPLEFT", 0, 0);
				VUHDO_PixelUtil.SetPoint(tTexture, "TOPRIGHT", tButton, "TOPRIGHT", 0, 0);
				VUHDO_PixelUtil.SetPoint(tTexture, "BOTTOMLEFT", tButton, "BOTTOMLEFT", 0, 0);
				VUHDO_PixelUtil.SetPoint(tTexture, "BOTTOMRIGHT", tButton, "BOTTOMRIGHT", 0, 0);

				if aLayerTemplate then
					VUHDO_applyAllLayersToTexture(tButton, tTexture, aLayerTemplate);
				elseif aColor then
					tTexture:SetVertexColor(VUHDO_backColorWithFallback(aColor));
				end

				tTexture:Show();

				VUHDO_UIFrameFlash(tTexture, 0.2, 0.5, 3.2, true, 0, 0);
			else
				VUHDO_UIFrameFlashStop(tTexture);

				tTexture:Hide();
			end
		end
	end

end



--
local tBar;
local tQuota;
function VUHDO_threatBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	aMaxValue = aMaxValue or 1;
	aCurrValue = aCurrValue or 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["THREAT_BAR"] == aBouquetName then
			tBar = VUHDO_getHealthBar(tButton, 7);

			tBar:SetMinMaxValues(0, aMaxValue);

			if tBar["isInverted"] then
				tBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue));
			else
				tBar:SetValue(aCurrValue);
			end

			if anIsActive then
				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tBar, aLayerTemplate);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tBar, aColor);
				end
			end

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "THREAT_BAR", VUHDO_RAID[aUnit]);
			end
		end
	end

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

		if UnitIsEnemy(aUnit, tUnitTarget) then
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
local tUnitInfo;
local tIsCharmed;
local tIsInRange;
function VUHDO_updateUnitRange(aUnit, aMode)

	if not VUHDO_RAID then
		return;
	end

	tUnitInfo = VUHDO_RAID[aUnit];

	if tUnitInfo then
		tIsCharmed = UnitIsCharmed(aUnit) and UnitCanAttack("player", aUnit) and not tUnitInfo["dead"];

		tUnitInfo["baseRange"] = "player" == aUnit or "pet" == aUnit or UnitInRange(aUnit);
		tUnitInfo["visible"] = UnitIsVisible(aUnit);

		if tUnitInfo["charmed"] ~= tIsCharmed then
			tUnitInfo["charmed"] = tIsCharmed;

			VUHDO_updateHealthBarsFor(aUnit, 4);
		end

		tIsInRange = VUHDO_isInRange(aUnit);

		if sSecretsEnabled then
			tUnitInfo["hasSecretRange"] = issecretvalue(tIsInRange);
		end

		if sSecretsEnabled and tUnitInfo["hasSecretRange"] then
			tUnitInfo["range"] = tIsInRange;

			VUHDO_updateHealthBarsFor(aUnit, 5);

			if VUHDO_getIsDirectionArrow() and VUHDO_getCurrentMouseOver() == aUnit
				and (VuhDoDirectionFrame["shown"] or VUHDO_CONFIG["DIRECTION"]["isAlways"]) then
				VUHDO_updateDirectionFrame();
			end
		else
			if issecretvalue(tUnitInfo["range"]) or tUnitInfo["range"] ~= tIsInRange then
				tUnitInfo["range"] = tIsInRange;

				VUHDO_updateHealthBarsFor(aUnit, 5);

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
		VUHDO_updateUnitRange(tUnit);
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
function VUHDO_deferUpdateUnitAggro(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_AGGRO, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit);

	return;

end



--
function VUHDO_deferUpdateUnitRange(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_RANGE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit);

	return;

end
