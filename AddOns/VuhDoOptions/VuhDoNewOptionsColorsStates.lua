local _;



--
function VUHDO_dispelIndicatorTypeComboOnLoad(aComboBox)

	VUHDO_setComboModel(aComboBox, "VUHDO_PANEL_SETUP.BAR_COLORS.dispelIndicatorType", VUHDO_PRIVATE_AURA_DISPEL_COMBO_MODEL);

	VUHDO_lnfSetTooltip(aComboBox, VUHDO_I18N_TT.K825);

	VUHDO_lnfAddConstraint(aComboBox, VUHDO_LF_CONSTRAINT_DISABLE, "VUHDO_PANEL_SETUP.BAR_COLORS.showDispelOverlay", false);

	return;

end