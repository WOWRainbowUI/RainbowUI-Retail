local _;

local pairs = pairs;
local UnitExists = UnitExists;
local UnitIsUnit = UnitIsUnit;

local VUHDO_RAID = { };
local VUHDO_INTERNAL_TOGGLES = { };

local VUHDO_updateBouquetsForEvent;
local VUHDO_clParserSetCurrentTarget;
local VUHDO_setHealth;
local VUHDO_removeHots;
local VUHDO_removeAllDebuffIcons;
local VUHDO_updateTargetBars;
local VUHDO_updateHealthBarsFor;
local VUHDO_getUnitButtonsSafe;
local VUHDO_getPlayerTargetFrame;
local VUHDO_cleanupSpellTraceForUnit;
local VUHDO_applyAllLayersToBorder;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;



--
function VUHDO_playerTargetEventHandlerInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_INTERNAL_TOGGLES = _G["VUHDO_INTERNAL_TOGGLES"];

	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_clParserSetCurrentTarget = _G["VUHDO_clParserSetCurrentTarget"];
	VUHDO_setHealth = _G["VUHDO_setHealth"];
	VUHDO_removeHots = _G["VUHDO_removeHots"];
	VUHDO_removeAllDebuffIcons = _G["VUHDO_removeAllDebuffIcons"];
	VUHDO_updateTargetBars = _G["VUHDO_updateTargetBars"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_getPlayerTargetFrame = _G["VUHDO_getPlayerTargetFrame"];
	VUHDO_cleanupSpellTraceForUnit = _G["VUHDO_cleanupSpellTraceForUnit"];
	VUHDO_applyAllLayersToBorder = _G["VUHDO_applyAllLayersToBorder"];

	return;

end



--
local VUHDO_CURR_PLAYER_TARGET = nil;
local tTargetUnit;
local tOldTarget;
local tEmptyInfo = { };
function VUHDO_updatePlayerTarget()

	tTargetUnit = nil;

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if UnitIsUnit("target", tUnit) and tUnit ~= "focus" and tUnit ~= "target" and not VUHDO_isBossUnit(tUnit) then 
			if tInfo["isPet"] and (VUHDO_RAID[tInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"] then
				tTargetUnit = tInfo["ownerUnit"];
			else
				tTargetUnit = tUnit;
			end

			break;
		end
	end

	if VUHDO_RAID["target"] then
		VUHDO_determineIncHeal("target");
		VUHDO_updateHealth("target", 9); -- VUHDO_UPDATE_INC
	end

	tOldTarget = VUHDO_CURR_PLAYER_TARGET;
	VUHDO_CURR_PLAYER_TARGET = tTargetUnit; -- Wg. callback erst umkopieren
	VUHDO_updateBouquetsForEvent(tOldTarget, 8); -- VUHDO_UPDATE_TARGET
	VUHDO_updateBouquetsForEvent(tTargetUnit, 8); -- VUHDO_UPDATE_TARGET
	VUHDO_clParserSetCurrentTarget(tTargetUnit);

	if VUHDO_INTERNAL_TOGGLES[27] then -- VUHDO_UPDATE_PLAYER_TARGET
		if VUHDO_INTERNAL_TOGGLES and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG and VUHDO_CONFIG["SHOW_SPELL_TRACE"] then
			VUHDO_cleanupSpellTraceForUnit("target");

			VUHDO_cleanupStaleSpellTracesForTargetFocus();
		end

		if UnitExists("target") then
			VUHDO_fullAuraRefresh("target");

			VUHDO_setHealth("target", 1); -- VUHDO_UPDATE_ALL
		else
			VUHDO_clearUnitAuraCache("target");

			if sSecretsEnabled then
				VUHDO_hideAurasForUnit("target");
			else
				VUHDO_removeHots("target");
				VUHDO_removeAllDebuffIcons("target");
				VUHDO_resetDebuffsFor("target");
			end

			VUHDO_updateTargetBars("target");

			table.wipe(VUHDO_RAID["target"] or tEmptyInfo);
			VUHDO_RAID["target"] = nil;
		end

		VUHDO_updateHealthBarsFor("target", 1); -- VUHDO_UPDATE_ALL
		VUHDO_initEventBouquetsFor("target");
	end

	return;

end



--
local tBorder;
function VUHDO_barBorderBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["BAR_BORDER"] == aBouquetName then
			tBorder = VUHDO_getPlayerTargetFrame(tButton);

			if tBorder then
				if anIsActive then
					if aLayerTemplate then
						VUHDO_PixelUtil.SetFrameLevel(tBorder, tButton:GetFrameLevel() + (anImpact or 0) + 2);
						VUHDO_applyAllLayersToBorder(tButton, tBorder, aLayerTemplate);
					elseif aColor then
						VUHDO_PixelUtil.SetFrameLevel(tBorder, tButton:GetFrameLevel() + (anImpact or 0) + 2);
						tBorder:SetBackdropBorderColor(VUHDO_backColorWithFallback(aColor));
					end

					tBorder:Show();
				else
					tBorder:Hide();
				end
			end

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "BAR_BORDER", VUHDO_RAID[aUnit]);
			end
		end
	end

end



--
function VUHDO_getCurrentPlayerTarget()
	return VUHDO_CURR_PLAYER_TARGET;
end

