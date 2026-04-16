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



--
function VUHDO_colorsModesApplySmoothShieldToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["smoothShield"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end



--
function VUHDO_colorsModesApplySmoothOvershieldToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["smoothOvershield"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end



--
function VUHDO_colorsModesApplySmoothHealAbsorbToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["smoothHealAbsorb"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end



--
function VUHDO_colorsModesApplySmoothHealthLossToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["smoothHealthLoss"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end



--
function VUHDO_colorsModesApplyTurnAxisHealthLossToAllPanels(_, aValue)

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["turnAxisHealthLoss"] = aValue;
	end

	VUHDO_timeReloadUI(0.3, true);

	return;

end