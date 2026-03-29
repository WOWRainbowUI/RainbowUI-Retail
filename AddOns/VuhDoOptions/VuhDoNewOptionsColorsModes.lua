local _;

local VUHDO_MAX_PANELS = VUHDO_MAX_PANELS;



--
function VUHDO_colorsModesApplyTurnAxisOvershieldToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["turnAxisOvershield"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end



--
function VUHDO_colorsModesApplyTurnAxisHealAbsorbToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["turnAxisHealAbsorb"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end
