local _;

local VUHDO_PRIVATE_AURA_ORIENTATION_COMBO = {
	{ "HORIZONTAL", VUHDO_I18N_HORIZONTAL },
	{ "VERTICAL", VUHDO_I18N_VERTICAL },
};

local VUHDO_PRIVATE_AURA_DURATION_POSITION_COMBO = {
	{ "BOTTOM", VUHDO_I18N_PRIVATE_AURA_DURATION_BELOW },
	{ "TOP", VUHDO_I18N_PRIVATE_AURA_DURATION_ABOVE },
	{ "LEFT", VUHDO_I18N_LEFT },
	{ "RIGHT", VUHDO_I18N_RIGHT },
};

local VUHDO_PRIVATE_AURA_GROWTH_DIR_COMBO = {
	{ "LEFT", VUHDO_I18N_LEFT },
	{ "RIGHT", VUHDO_I18N_RIGHT },
	{ "UP", VUHDO_I18N_UP },
	{ "DOWN", VUHDO_I18N_DOWN },
};



--
function VUHDO_privateAuraOrientationComboOnLoad(aComboBox)

	VUHDO_setComboModel(aComboBox, "VUHDO_PANEL_SETUP.#PNUM#.PRIVATE_AURA.orientation", VUHDO_PRIVATE_AURA_ORIENTATION_COMBO);

	return;

end



--
function VUHDO_privateAuraDurationPositionComboOnLoad(aComboBox)

	VUHDO_setComboModel(aComboBox, "VUHDO_PANEL_SETUP.#PNUM#.PRIVATE_AURA.durationPosition", VUHDO_PRIVATE_AURA_DURATION_POSITION_COMBO);

	return;

end



--
function VUHDO_privateAuraGrowthDirComboOnLoad(aComboBox)

	VUHDO_setComboModel(aComboBox, "VUHDO_PANEL_SETUP.#PNUM#.PRIVATE_AURA.growthDir", VUHDO_PRIVATE_AURA_GROWTH_DIR_COMBO);

	return;

end



--
function VUHDO_privateAuraWrapDirComboOnLoad(aComboBox)

	VUHDO_setComboModel(aComboBox, "VUHDO_PANEL_SETUP.#PNUM#.PRIVATE_AURA.wrapDir", VUHDO_PRIVATE_AURA_GROWTH_DIR_COMBO);

	return;

end