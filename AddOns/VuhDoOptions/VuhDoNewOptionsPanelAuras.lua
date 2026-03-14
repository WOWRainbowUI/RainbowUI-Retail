local _;

local tinsert = table.insert;
local twipe = table.wipe;
local tsort = table.sort;
local pairs = pairs;
local ipairs = ipairs;
local format = string.format;

VUHDO_PANEL_AURAS_SELECTED_ANCHOR = nil;
VUHDO_PANEL_AURAS_ANCHOR_COMBO_MODEL = { };

VUHDO_AURA_GROWTH_DIR_OPTIONS = {
	{ "LEFT", VUHDO_I18N_LEFT },
	{ "RIGHT", VUHDO_I18N_RIGHT },
	{ "UP", VUHDO_I18N_UP },
	{ "DOWN", VUHDO_I18N_DOWN },
};

VUHDO_AURA_SORT_RULE_OPTIONS = {
	{ 0, VUHDO_I18N_SORT_UNSORTED, nil, nil, VUHDO_I18N_TT.K653 },
	{ 1, VUHDO_I18N_SORT_DEFAULT, nil, nil, VUHDO_I18N_TT.K654 },
	{ 2, VUHDO_I18N_SORT_BIG_DEFENSIVE, nil, nil, VUHDO_I18N_TT.K655 },
	{ 3, VUHDO_I18N_SORT_EXPIRATION, nil, nil, VUHDO_I18N_TT.K656 },
	{ 4, VUHDO_I18N_SORT_EXPIRATION_ONLY, nil, nil, VUHDO_I18N_TT.K657 },
	{ 5, VUHDO_I18N_SORT_NAME, nil, nil, VUHDO_I18N_TT.K658 },
	{ 6, VUHDO_I18N_SORT_NAME_ONLY, nil, nil, VUHDO_I18N_TT.K659 },
};

VUHDO_AURA_SORT_DIR_OPTIONS = {
	{ 0, VUHDO_I18N_ASCENDING },
	{ 1, VUHDO_I18N_DESCENDING },
};

VUHDO_AURA_STYLE_OPTIONS = {
	{ "icons", VUHDO_I18N_ICONS },
	{ "bars", VUHDO_I18N_BARS },
};

VUHDO_AURA_COLOR_MODE_OPTIONS = {
	{ "default", VUHDO_I18N_DEFAULT },
	{ "class", VUHDO_I18N_BY_CLASS },
	{ "debuff", VUHDO_I18N_DEBUFF },
};

VUHDO_AURA_ICON_TYPE_OPTIONS = {
	{ 1, VUHDO_I18N_ICONS },
	{ 2, VUHDO_I18N_GLOSSY },
	{ 3, VUHDO_I18N_FLAT_TEXTURE },
	{ 4, VUHDO_I18N_TEXT_ONLY },
};

VUHDO_AURA_STACK_TYPE_OPTIONS = {
	{ 1, VUHDO_I18N_NUMBER_STACKS },
	{ 2, VUHDO_I18N_TRIANGLE_STACKS },
};

local sDefaultAnchorEntry = {
	["groupId"] = "MY_HOTS",
	["enabled"] = true,
	["radioValue"] = 13,
	["position"] = "BOTTOMRIGHT",
	["offsetX"] = -2,
	["offsetY"] = -2,
	["maxDisplay"] = 5,
	["maxColumns"] = 5,
	["maxRows"] = 1,
	["sortRule"] = 3,
	["sortDir"] = 0,
	["size"] = 20,
	["barWidth"] = 100,
	["barHeight"] = 12,
	["spacing"] = 2,
	["barVertical"] = false,
	["barTurnAxis"] = false,
	["barInvertGrowth"] = false,
	["style"] = "icons",
	["growthDir"] = "LEFT",
	["wrapDir"] = "UP",
	["showTimer"] = 2,
	["showStacks"] = 2,
	["showClock"] = 2,
	["showTooltip"] = 2,
	["fadeOnLow"] = 2,
	["flashOnLow"] = 2,
	["dispelBorder"] = 2,
	["colorMode"] = "default",
	["iconType"] = 1,
	["stackType"] = 1,
	["fixedSlots"] = false,
	["TIMER_TEXT"] = {
		["ANCHOR"] = "BOTTOMRIGHT",
		["X_ADJUST"] = 20,
		["Y_ADJUST"] = 26,
		["SCALE"] = 85,
		["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
		["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1, 1, 1, 1, 1),
		["USE_SHADOW"] = true,
		["USE_OUTLINE"] = false,
		["USE_MONO"] = false,
	},
	["COUNTER_TEXT"] = {
		["ANCHOR"] = "TOPLEFT",
		["X_ADJUST"] = -10,
		["Y_ADJUST"] = -15,
		["SCALE"] = 70,
		["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
		["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1, 0, 1, 0, 1),
		["USE_SHADOW"] = true,
		["USE_OUTLINE"] = false,
		["USE_MONO"] = false,
	},
};

local sLastAuraAnchorStyle = nil;



--
local tAnchors;
function VUHDO_initPanelAurasAnchorComboModel()

	twipe(VUHDO_PANEL_AURAS_ANCHOR_COMBO_MODEL);

	if not VUHDO_PANEL_SETUP or not DESIGN_MISC_PANEL_NUM then
		return;
	end

	tAnchors = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] or {};

	for tKey, _ in pairs(tAnchors) do
		tinsert(VUHDO_PANEL_AURAS_ANCHOR_COMBO_MODEL,
			{ tonumber(tKey), format("%s %s", VUHDO_I18N_ANCHOR, tKey) });
	end

	tsort(VUHDO_PANEL_AURAS_ANCHOR_COMBO_MODEL, function(anA, anotherA) return anA[1] < anotherA[1]; end);

	return;

end



--
local tAnchors;
local tIndex;
function VUHDO_panelAurasGetNextAnchorKey()

	if not VUHDO_PANEL_SETUP or not DESIGN_MISC_PANEL_NUM then
		return "1";
	end

	tAnchors = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] or {};
	tIndex = 1;

	while tAnchors[tostring(tIndex)] do
		tIndex = tIndex + 1;
	end

	return tostring(tIndex);

end



--
local tModel;
local tAnchorKey;
function VUHDO_panelAurasAnchorControlSetModel(aControl, aField)

	tAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR or 1);
	tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.%s", tAnchorKey, aField);

	VUHDO_lnfSetModel(aControl, tModel);

	return;

end



--
function VUHDO_panelAurasEnabledCheckButtonOnLoad(aCheckButton)

	VUHDO_lnfCheckButtonOnLoad(aCheckButton);

	return;

end



--
function VUHDO_panelAurasEnabledChanged(aCheckButton)

	VUHDO_reloadUI(false);

	return;

end



--
local tAnchorKey;
local tGroupId;
function VUHDO_panelAurasAnchorGroupButtonClicked(aButton)

	if not DESIGN_MISC_PANEL_NUM or not VUHDO_PANEL_SETUP or not VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM] then
		return;
	end

	tAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR or 1);
	tGroupId = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tAnchorKey] and VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tAnchorKey]["groupId"];

	if not tGroupId or tGroupId == "" then
		return;
	end

	VUHDO_AURA_GROUPS_PENDING_SELECTION = tGroupId;

	VUHDO_MENU_RETURN_TARGET_MAIN = VuhDoNewOptionsTabbedFrameTabsPanelPanelsRadioButton;
	VUHDO_MENU_RETURN_TARGET = VuhDoNewOptionsPanelPanelRadioPanelAurasRadioButton;

	VUHDO_newOptionsTabbedClickedClicked(VuhDoNewOptionsTabbedFrameTabsPanelAurasRadioButton);
	VUHDO_lnfRadioButtonClicked(VuhDoNewOptionsTabbedFrameTabsPanelAurasRadioButton);
	VUHDO_lnfTabRadioButtonClicked(VuhDoNewOptionsAuraRadioPanelGroupsRadioButton);

	return;

end



--
local tModel;
local tAnchorKey;
function VUHDO_panelAurasAnchorGroupComboOnLoad(aCombo)

	tAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR or 1);
	tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.groupId", tAnchorKey);

	VUHDO_setComboModel(aCombo, tModel, VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL, VUHDO_I18N_SELECT);

	return;

end



--
local tModel;
local tAnchorKey;
function VUHDO_panelAurasAnchorFieldComboOnLoad(aCombo, aField, anOptionsArray, aTitle)

	if not VUHDO_PANEL_AURAS_SELECTED_ANCHOR then
		return;
	end

	tAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
	tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.%s", tAnchorKey, aField);

	VUHDO_setComboModel(aCombo, tModel, anOptionsArray, aTitle or VUHDO_I18N_SELECT);

	return;

end



--
local tControl;
function VUHDO_setControlVisibility(aContentPanel, aControlName, anIsVisible)

	if not aContentPanel or not aControlName then
		return;
	end

	tControl = _G[aContentPanel:GetName() .. aControlName];

	if tControl then
		if anIsVisible then
			tControl:Show();
		else
			tControl:Hide();
		end
	end

	return;

end



--
local tControl;
local tInnerSlider;
function VUHDO_setControlEnabled(aContentPanel, aControlName, anIsEnabled)

	if not aContentPanel or not aControlName then
		return;
	end

	tControl = _G[aContentPanel:GetName() .. aControlName];

	if not tControl then
		return;
	end

	tInnerSlider = _G[tControl:GetName() .. "Slider"];

	if tInnerSlider then
		if anIsEnabled then
			tInnerSlider:Enable();
		else
			tInnerSlider:Disable();
		end
	end

	if anIsEnabled then
		tControl:SetAlpha(1);
	else
		tControl:SetAlpha(0.5);
	end

	return;

end



--
local tContentPanel;
local tEnabled;
function VUHDO_panelAurasUpdateOffsetSlidersEnabled(aParent, aRadioValue)

	tContentPanel = _G["VuhDoNewOptionsPanelAurasMainPanelAnchorContentPanel"];

	if not tContentPanel then
		return;
	end

	tEnabled = not aRadioValue or aRadioValue < 30;

	VUHDO_setControlEnabled(tContentPanel, "OffsetXSlider", tEnabled);
	VUHDO_setControlEnabled(tContentPanel, "OffsetYSlider", tEnabled);

	return;

end



--
local tStyleContentPanel;
local tStyleIsBars;
local tStyleBarVerticalCheck;
local tStyleBarTurnAxisCheck;
local tStyleBarInvertCheck;
local tSyncAnchorKey;
local tSyncAnchorData;
local tSize;
local tBarWidthSlider;
local tBarHeightSlider;
local tSyncSizeSlider;
function VUHDO_panelAurasUpdateStyleControlsEnabled(aParent, aStyleValue)

	tStyleContentPanel = _G["VuhDoNewOptionsPanelAurasMainPanelAnchorContentPanel"];

	if not tStyleContentPanel then
		return;
	end

	tStyleIsBars = "bars" == aStyleValue;

	if VUHDO_PANEL_AURAS_SELECTED_ANCHOR and DESIGN_MISC_PANEL_NUM then
		tSyncAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
		tSyncAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"];
		tSyncAnchorData = tSyncAnchorData and tSyncAnchorData[tSyncAnchorKey];

		if tSyncAnchorData then
			if tStyleIsBars then
				tSize = tSyncAnchorData["size"] or 20;

				if tSyncAnchorData["barVertical"] then
					VUHDO_lnfUpdateVar(format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barWidth", tSyncAnchorKey), tSize, DESIGN_MISC_PANEL_NUM);
				else
					VUHDO_lnfUpdateVar(format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barHeight", tSyncAnchorKey), tSize, DESIGN_MISC_PANEL_NUM);
				end
			else
				if "bars" == sLastAuraAnchorStyle then
					tSize = tSyncAnchorData["barVertical"] and (tSyncAnchorData["barWidth"] or 100) or (tSyncAnchorData["barHeight"] or 12);

					VUHDO_lnfUpdateVar(format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.size", tSyncAnchorKey), tSize, DESIGN_MISC_PANEL_NUM);
				end
			end
		end
	end

	VUHDO_setControlEnabled(tStyleContentPanel, "BarWidthSlider", tStyleIsBars);
	VUHDO_setControlEnabled(tStyleContentPanel, "BarHeightSlider", tStyleIsBars);
	VUHDO_setControlEnabled(tStyleContentPanel, "SizeSlider", not tStyleIsBars);

	tStyleBarVerticalCheck = _G[tStyleContentPanel:GetName() .. "TriStateRow1BarVerticalCheck"];
	tStyleBarTurnAxisCheck = _G[tStyleContentPanel:GetName() .. "TriStateRow2BarTurnAxisCheck"];
	tStyleBarInvertCheck = _G[tStyleContentPanel:GetName() .. "TriStateRow3BarInvertCheck"];

	if tStyleBarVerticalCheck then
		VUHDO_setControlEnabled(tStyleBarVerticalCheck:GetParent(), "BarVerticalCheck", tStyleIsBars);
	end

	if tStyleBarTurnAxisCheck then
		VUHDO_setControlEnabled(tStyleBarTurnAxisCheck:GetParent(), "BarTurnAxisCheck", tStyleIsBars);
	end

	if tStyleBarInvertCheck then
		VUHDO_setControlEnabled(tStyleBarInvertCheck:GetParent(), "BarInvertCheck", tStyleIsBars);
	end

	if VUHDO_PANEL_AURAS_SELECTED_ANCHOR and DESIGN_MISC_PANEL_NUM then
		tBarWidthSlider = _G[tStyleContentPanel:GetName() .. "BarWidthSlider"];
		tBarHeightSlider = _G[tStyleContentPanel:GetName() .. "BarHeightSlider"];

		if tStyleIsBars then
			if tBarWidthSlider then
				VUHDO_lnfSliderInitFromModel(_G[tBarWidthSlider:GetName() .. "Slider"]);
			end

			if tBarHeightSlider then
				VUHDO_lnfSliderInitFromModel(_G[tBarHeightSlider:GetName() .. "Slider"]);
			end
		else
			tSyncSizeSlider = _G[tStyleContentPanel:GetName() .. "SizeSlider"];

			if tSyncSizeSlider then
				VUHDO_lnfSliderInitFromModel(_G[tSyncSizeSlider:GetName() .. "Slider"]);
			end
		end
	end

	sLastAuraAnchorStyle = aStyleValue;

	return;

end



--
local tSyncAnchorKey;
local tSyncAnchorData;
local tSyncSizeModel;
local tSyncSizeSlider;
function VUHDO_panelAurasSyncSizeWithBarHeight(aParent, aValue)

	tSyncAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
	tSyncAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"];
	tSyncAnchorData = tSyncAnchorData and tSyncAnchorData[tSyncAnchorKey];

	if tSyncAnchorData and "bars" == tSyncAnchorData["style"] and not tSyncAnchorData["barVertical"] then
		tSyncSizeModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.size", tSyncAnchorKey);

		VUHDO_lnfUpdateVar(tSyncSizeModel, aValue, DESIGN_MISC_PANEL_NUM);

		tSyncSizeSlider = _G["VuhDoNewOptionsPanelAurasMainPanelAnchorContentPanelSizeSlider"];

		if tSyncSizeSlider then
			VUHDO_lnfSliderInitFromModel(_G[tSyncSizeSlider:GetName() .. "Slider"]);
		end
	end

	return;

end



--
local tSyncAnchorKey;
local tSyncAnchorData;
local tSyncSizeModel;
local tSyncSizeSlider;
function VUHDO_panelAurasSyncSizeWithBarWidth(aParent, aValue)

	tSyncAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
	tSyncAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"];
	tSyncAnchorData = tSyncAnchorData and tSyncAnchorData[tSyncAnchorKey];

	if tSyncAnchorData and "bars" == tSyncAnchorData["style"] and tSyncAnchorData["barVertical"] then
		tSyncSizeModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.size", tSyncAnchorKey);

		VUHDO_lnfUpdateVar(tSyncSizeModel, aValue, DESIGN_MISC_PANEL_NUM);

		tSyncSizeSlider = _G["VuhDoNewOptionsPanelAurasMainPanelAnchorContentPanelSizeSlider"];

		if tSyncSizeSlider then
			VUHDO_lnfSliderInitFromModel(_G[tSyncSizeSlider:GetName() .. "Slider"]);
		end
	end

	return;

end



--
local tSyncAnchorKey;
local tSyncAnchorData;
local tSyncSizeModel;
local tOldBarWidth;
local tOldBarHeight;
local tNewSize;
local tContentPanel;
local tBarWidthSlider;
local tBarHeightSlider;
local tSizeSlider;
local tInnerSlider;
function VUHDO_panelAurasBarVerticalChanged(aParent, aValue)

	tSyncAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
	tSyncAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"];
	tSyncAnchorData = tSyncAnchorData and tSyncAnchorData[tSyncAnchorKey];

	if tSyncAnchorData and "bars" == tSyncAnchorData["style"] then
		tOldBarWidth = tSyncAnchorData["barWidth"] or 100;
		tOldBarHeight = tSyncAnchorData["barHeight"] or 12;

		VUHDO_lnfUpdateVar(format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barWidth", tSyncAnchorKey), tOldBarHeight, DESIGN_MISC_PANEL_NUM);
		VUHDO_lnfUpdateVar(format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barHeight", tSyncAnchorKey), tOldBarWidth, DESIGN_MISC_PANEL_NUM);

		tSyncSizeModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.size", tSyncAnchorKey);
		tNewSize = aValue and tOldBarHeight or tOldBarWidth;
		VUHDO_lnfUpdateVar(tSyncSizeModel, tNewSize, DESIGN_MISC_PANEL_NUM);

		tContentPanel = _G["VuhDoNewOptionsPanelAurasMainPanelAnchorContentPanel"];

		if tContentPanel then
			tBarWidthSlider = _G[tContentPanel:GetName() .. "BarWidthSlider"];
			tBarHeightSlider = _G[tContentPanel:GetName() .. "BarHeightSlider"];
			tSizeSlider = _G[tContentPanel:GetName() .. "SizeSlider"];

			if tBarWidthSlider then
				tInnerSlider = _G[tBarWidthSlider:GetName() .. "Slider"];

				if tInnerSlider then
					tInnerSlider:SetValue(tOldBarHeight);
				end
			end

			if tBarHeightSlider then
				tInnerSlider = _G[tBarHeightSlider:GetName() .. "Slider"];

				if tInnerSlider then
					tInnerSlider:SetValue(tOldBarWidth);
				end
			end

			if tSizeSlider then
				tInnerSlider = _G[tSizeSlider:GetName() .. "Slider"];

				if tInnerSlider then
					tInnerSlider:SetValue(tNewSize);
				end
			end
		end
	end

	return;

end



--
function VUHDO_panelAurasAnchorRadioOnLoad(aButton, aRadioValue)

	aButton:SetAttribute("radio_value", aRadioValue);
	VUHDO_lnfSetTooltip(aButton, VUHDO_I18N_TT.K619);

	return;

end



--
function VUHDO_panelAurasAnchorPositionRadioOnLoad(aButton, aPosition)

	aButton:SetAttribute("radio_value", aPosition);

	return;

end



--
local tMainPanel;
local tAnchorCombo;
local tAnchors;
function VUHDO_panelAurasOnShow()

	if not VUHDO_PANEL_SETUP or not DESIGN_MISC_PANEL_NUM then
		return;
	end

	tAnchors = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] or { };

	if VUHDO_PANEL_AURAS_SELECTED_ANCHOR and not tAnchors[tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR)] then
		VUHDO_PANEL_AURAS_SELECTED_ANCHOR = nil;
	end

	if not VUHDO_PANEL_AURAS_SELECTED_ANCHOR then
		for tKey, _ in pairs(tAnchors) do
			VUHDO_PANEL_AURAS_SELECTED_ANCHOR = tonumber(tKey);
			break;
		end
	end

	VUHDO_initPanelAurasAnchorComboModel();

	tMainPanel = _G["VuhDoNewOptionsPanelAurasMainPanel"];

	if tMainPanel then
		tAnchorCombo = _G[tMainPanel:GetName() .. "AnchorCombo"];

		if tAnchorCombo then
			VUHDO_lnfComboBoxInitFromModel(tAnchorCombo);
		end
	end

	VUHDO_panelAurasAnchorSelectionChanged();

	return;

end



--
local tMainPanel;
local tContentPanel;
local tCopyButton;
local tDeleteButton;
function VUHDO_panelAurasAnchorSelectionChanged(aCombo, aNewValue)

	if aNewValue then
		VUHDO_PANEL_AURAS_SELECTED_ANCHOR = aNewValue;
	end

	tMainPanel = _G["VuhDoNewOptionsPanelAurasMainPanel"];

	if not tMainPanel then
		return;
	end

	tContentPanel = _G[tMainPanel:GetName() .. "AnchorContentPanel"];
	tCopyButton = _G[tMainPanel:GetName() .. "CopyButton"];
	tDeleteButton = _G[tMainPanel:GetName() .. "DeleteButton"];

	if VUHDO_PANEL_AURAS_SELECTED_ANCHOR then
		if tContentPanel then
			tContentPanel:Show();
			VUHDO_panelAurasRebindContentPanel();
		end

		if tCopyButton then
			tCopyButton:Enable();
			tCopyButton:SetAlpha(1);
		end

		if tDeleteButton then
			tDeleteButton:Enable();
			tDeleteButton:SetAlpha(1);
		end
	else
		if tContentPanel then
			tContentPanel:Hide();
		end

		if tCopyButton then
			tCopyButton:Disable();
			tCopyButton:SetAlpha(0.5);
		end

		if tDeleteButton then
			tDeleteButton:Disable();
			tDeleteButton:SetAlpha(0.5);
		end
	end

	return;

end



--
local tContentPanel;
local tTexture;
local tRadioNames;
local tRadio;
local tModel;
local tAnchorKey;
local tSliderNames;
local tSlider;
local tComboNames;
local tCombo;
local tTriStateNames;
local tTriState;
local tAnchorData;
local tDefaultVal;
local tTimerBtn;
local tStacksBtn;
local tDeleteButton;
local tBarVerticalCheck;
local tBarTurnAxisCheck;
local tBarInvertCheck;
local tFixedSlotsCheck;
local tRadioValue;
local tEnabled;
local tEnabledCheck;
local tBarWidthSlider;
local tBarHeightSlider;
local tStyle;
local tSizeSlider;
local tBarHeight;
local tBarWidth;
local tBarVertical;
local tSizeModel;
function VUHDO_panelAurasRebindContentPanel()

	sLastAuraAnchorStyle = nil;

	if not VUHDO_PANEL_AURAS_SELECTED_ANCHOR then
		return;
	end

	tContentPanel = _G["VuhDoNewOptionsPanelAurasMainPanelAnchorContentPanel"];

	if not tContentPanel then
		return;
	end

	tSlider = _G[tContentPanel:GetName() .. "OffsetXSlider"];
	tDeleteButton = _G[tContentPanel:GetParent():GetName() .. "DeleteButton"];

	if tSlider and tDeleteButton then
		tSlider:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tSlider, "TOPRIGHT", tDeleteButton, "BOTTOMRIGHT", 0, -8);
	end

	tAnchorKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
	tTexture = _G[tContentPanel:GetName() .. "PositionTexture"];
	tAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tAnchorKey];

	if tAnchorData and tAnchorData["enabled"] == nil then
		tAnchorData["enabled"] = true;
	end

	if tTexture then
		tRadioNames = {
			"Radio1", "Radio2", "Radio3", "Radio4", "Radio5", "Radio6", "Radio7", "Radio8", "Radio9", "Radio10",
			"Radio11", "Radio12", "Radio13", "Radio14", "Radio15", "Radio16", "Radio17",
		};

		for _, tName in ipairs(tRadioNames) do
			tRadio = _G[tTexture:GetName() .. tName];

			if tRadio then
				tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.radioValue", tAnchorKey);

				VUHDO_lnfSetRadioModel(tRadio, tModel, tRadio:GetAttribute("radio_value"));
				VUHDO_lnfRadioButtonInitFromModel(tRadio);

				tRadio:SetAttribute("custom_function_post", VUHDO_panelAurasUpdateOffsetSlidersEnabled);
			end
		end
	end

	if tTexture then
		tRadio = _G[tTexture:GetName() .. "StraightRadioButton"];

		if tRadio then
			tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.radioValue", tAnchorKey);

			VUHDO_lnfSetRadioModel(tRadio, tModel, 30);
			VUHDO_lnfRadioButtonInitFromModel(tRadio);

			tRadio:SetAttribute("custom_function_post", VUHDO_panelAurasUpdateOffsetSlidersEnabled);
		end

		tRadio = _G[tTexture:GetName() .. "DiagonalRadioButton"];

		if tRadio then
			tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.radioValue", tAnchorKey);

			VUHDO_lnfSetRadioModel(tRadio, tModel, 31);
			VUHDO_lnfRadioButtonInitFromModel(tRadio);

			tRadio:SetAttribute("custom_function_post", VUHDO_panelAurasUpdateOffsetSlidersEnabled);
		end
	end

	if tAnchorData then
		tRadioValue = tAnchorData["radioValue"];
		tEnabled = not tRadioValue or tRadioValue < 30;

		VUHDO_setControlEnabled(tContentPanel, "OffsetXSlider", tEnabled);
		VUHDO_setControlEnabled(tContentPanel, "OffsetYSlider", tEnabled);
	end

	tSliderNames = {
		{ "OffsetXSlider", "offsetX" },
		{ "OffsetYSlider", "offsetY" },
		{ "MaxDisplaySlider", "maxDisplay" },
		{ "MaxColumnsSlider", "maxColumns" },
		{ "MaxRowsSlider", "maxRows" },
		{ "SizeSlider", "size" },
		{ "SpacingSlider", "spacing" },
	};

	for _, tEntry in ipairs(tSliderNames) do
		tSlider = _G[tContentPanel:GetName() .. tEntry[1]];

		if tSlider then
			tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.%s", tAnchorKey, tEntry[2]);
			VUHDO_lnfSetModel(tSlider, tModel);

			VUHDO_lnfSliderInitFromModel(_G[tSlider:GetName() .. "Slider"]);

			if tEntry[2] == "size" or tEntry[2] == "spacing" then
				tAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tAnchorKey];

				if tAnchorData and tAnchorData[tEntry[2]] == nil then
					tDefaultVal = VUHDO_PANEL_SETUP["AURA_DEFAULTS"];

					if tDefaultVal then
						if tEntry[2] == "size" then
							tDefaultVal = tDefaultVal["iconSize"];
						else
							tDefaultVal = tDefaultVal["iconSpacing"];
						end

						_G[tSlider:GetName() .. "Slider"]:SetValue(tDefaultVal);
					end
				end
			end
		end
	end

	tComboNames = {
		{ "GrowthDirCombo", "growthDir", VUHDO_AURA_GROWTH_DIR_OPTIONS, VUHDO_I18N_GROWTH_DIRECTION },
		{ "WrapDirCombo", "wrapDir", VUHDO_AURA_GROWTH_DIR_OPTIONS, VUHDO_I18N_WRAP_DIRECTION },
		{ "SortRuleCombo", "sortRule", VUHDO_AURA_SORT_RULE_OPTIONS, VUHDO_I18N_SORT_BY },
		{ "SortDirCombo", "sortDir", VUHDO_AURA_SORT_DIR_OPTIONS, VUHDO_I18N_ORDER },
		{ "StyleCombo", "style", VUHDO_AURA_STYLE_OPTIONS, VUHDO_I18N_DISPLAY_STYLE, VUHDO_panelAurasUpdateStyleControlsEnabled },
		{ "ColorModeCombo", "colorMode", VUHDO_AURA_COLOR_MODE_OPTIONS, VUHDO_I18N_COLOR },
		{ "IconTypeCombo", "iconType", VUHDO_AURA_ICON_TYPE_OPTIONS, VUHDO_I18N_ICON_TYPE },
		{ "StackTypeCombo", "stackType", VUHDO_AURA_STACK_TYPE_OPTIONS, VUHDO_I18N_STACK_TYPE },
	};

	for _, tEntry in ipairs(tComboNames) do
		tCombo = _G[tContentPanel:GetName() .. tEntry[1]];

		if tCombo then
			VUHDO_panelAurasAnchorFieldComboOnLoad(tCombo, tEntry[2], tEntry[3], tEntry[4]);
			VUHDO_lnfComboBoxInitFromModel(tCombo);

			if tEntry[5] then
				tCombo:SetAttribute("custom_function_post", tEntry[5]);
			end
		end
	end

	tBarWidthSlider = _G[tContentPanel:GetName() .. "BarWidthSlider"];
	tBarHeightSlider = _G[tContentPanel:GetName() .. "BarHeightSlider"];

	tAnchorData = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tAnchorKey];
	tStyle = tAnchorData and tAnchorData["style"];

	if tBarWidthSlider then
		tBarWidthSlider:Show();

		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barWidth", tAnchorKey);
		VUHDO_lnfSetModel(tBarWidthSlider, tModel);

		VUHDO_lnfSliderInitFromModel(_G[tBarWidthSlider:GetName() .. "Slider"]);
		VUHDO_setControlEnabled(tContentPanel, "BarWidthSlider", tStyle == "bars");

		tBarWidthSlider:SetAttribute("custom_function_post", VUHDO_panelAurasSyncSizeWithBarWidth);
	end

	if tBarHeightSlider then
		tBarHeightSlider:Show();

		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barHeight", tAnchorKey);
		VUHDO_lnfSetModel(tBarHeightSlider, tModel);

		VUHDO_lnfSliderInitFromModel(_G[tBarHeightSlider:GetName() .. "Slider"]);
		VUHDO_setControlEnabled(tContentPanel, "BarHeightSlider", tStyle == "bars");

		tBarHeightSlider:SetAttribute("custom_function_post", VUHDO_panelAurasSyncSizeWithBarHeight);
	end

	tSizeSlider = _G[tContentPanel:GetName() .. "SizeSlider"];

	if tSizeSlider then
		VUHDO_setControlEnabled(tContentPanel, "SizeSlider", tStyle ~= "bars");
	end

	if tSizeSlider and "bars" == tStyle then
		tBarVertical = tAnchorData and tAnchorData["barVertical"];

		if tBarVertical then
			tBarWidth = tAnchorData and tAnchorData["barWidth"];

			if tBarWidth then
				tSizeModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.size", tAnchorKey);

				VUHDO_lnfUpdateVar(tSizeModel, tBarWidth, DESIGN_MISC_PANEL_NUM);
			end
		else
			tBarHeight = tAnchorData and tAnchorData["barHeight"];

			if tBarHeight then
				tSizeModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.size", tAnchorKey);

				VUHDO_lnfUpdateVar(tSizeModel, tBarHeight, DESIGN_MISC_PANEL_NUM);
			end
		end
	end

	tBarVerticalCheck = _G[tContentPanel:GetName() .. "TriStateRow1BarVerticalCheck"];
	tBarTurnAxisCheck = _G[tContentPanel:GetName() .. "TriStateRow2BarTurnAxisCheck"];
	tBarInvertCheck = _G[tContentPanel:GetName() .. "TriStateRow3BarInvertCheck"];

	if tBarVerticalCheck then
		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barVertical", tAnchorKey);
		VUHDO_lnfSetModel(tBarVerticalCheck, tModel);
		VUHDO_lnfCheckButtonInitFromModel(tBarVerticalCheck);
		VUHDO_setControlEnabled(tBarVerticalCheck:GetParent(), "BarVerticalCheck", tStyle == "bars");

		tBarVerticalCheck:SetAttribute("custom_function_post", VUHDO_panelAurasBarVerticalChanged);
	end

	if tBarTurnAxisCheck then
		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barTurnAxis", tAnchorKey);
		VUHDO_lnfSetModel(tBarTurnAxisCheck, tModel);
		VUHDO_lnfCheckButtonInitFromModel(tBarTurnAxisCheck);
		VUHDO_setControlEnabled(tBarTurnAxisCheck:GetParent(), "BarTurnAxisCheck", tStyle == "bars");
	end

	if tBarInvertCheck then
		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.barInvertGrowth", tAnchorKey);
		VUHDO_lnfSetModel(tBarInvertCheck, tModel);
		VUHDO_lnfCheckButtonInitFromModel(tBarInvertCheck);
		VUHDO_setControlEnabled(tBarInvertCheck:GetParent(), "BarInvertCheck", tStyle == "bars");
	end

	tFixedSlotsCheck = _G[tContentPanel:GetName() .. "TriStateRow4FixedSlotsCheck"];

	if tFixedSlotsCheck then
		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.fixedSlots", tAnchorKey);
		VUHDO_lnfSetModel(tFixedSlotsCheck, tModel);
		VUHDO_lnfCheckButtonInitFromModel(tFixedSlotsCheck);
	end

	tTriStateNames = {
		{ "TriStateRow1ShowTimerTriState", "showTimer" },
		{ "TriStateRow1ShowStacksTriState", "showStacks" },
		{ "TriStateRow2ShowClockTriState", "showClock" },
		{ "TriStateRow2DispelBorderTriState", "dispelBorder" },
		{ "TriStateRow3FadeOnLowTriState", "fadeOnLow" },
		{ "TriStateRow3FlashOnLowTriState", "flashOnLow" },
		{ "TriStateRow4ShowTooltipTriState", "showTooltip" },
	};

	for _, tEntry in ipairs(tTriStateNames) do
		tTriState = _G[tContentPanel:GetName() .. tEntry[1]];

		if tTriState then
			tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.%s", tAnchorKey, tEntry[2]);
			VUHDO_lnfSetRadioModel(tTriState, tModel, { VUHDO_I18N_ON, VUHDO_I18N_GLOBAL, VUHDO_I18N_OFF });
			VUHDO_lnfTriStateCheckButtonInitFromModel(tTriState);
		end
	end

	VUHDO_panelAurasAnchorGroupComboOnLoad(_G[tContentPanel:GetName() .. "GroupCombo"]);

	VUHDO_initPanelAuraGroupsComboModel();

	VUHDO_lnfComboBoxInitFromModel(_G[tContentPanel:GetName() .. "GroupCombo"]);

	tEnabledCheck = _G[tContentPanel:GetName() .. "EnabledCheckButton"];

	if tEnabledCheck then
		tModel = format("VUHDO_PANEL_SETUP.#PNUM#.AURA_ANCHORS.%s.enabled", tAnchorKey);

		VUHDO_lnfSetModel(tEnabledCheck, tModel);
		VUHDO_lnfCheckButtonInitFromModel(tEnabledCheck);

		tEnabledCheck:SetAttribute("custom_function_post", VUHDO_panelAurasEnabledChanged);
	end

	tTimerBtn = _G[tContentPanel:GetName() .. "TimerTextButton"];
	tStacksBtn = _G[tContentPanel:GetName() .. "StacksTextButton"];

	if tTimerBtn then
		VUHDO_panelAurasAnchorControlSetModel(tTimerBtn, "TIMER_TEXT");
	end

	if tStacksBtn then
		VUHDO_panelAurasAnchorControlSetModel(tStacksBtn, "COUNTER_TEXT");
	end

	return;

end



--
local tNewKey;
function VUHDO_panelAurasOnNewAnchor()

	if not VUHDO_PANEL_SETUP or not DESIGN_MISC_PANEL_NUM then
		return;
	end

	if not VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] then
		VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"] = {};
	end

	tNewKey = VUHDO_panelAurasGetNextAnchorKey();
	VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tNewKey] = VUHDO_deepCopyTable(sDefaultAnchorEntry);
	VUHDO_PANEL_AURAS_SELECTED_ANCHOR = tonumber(tNewKey);

	VUHDO_panelAurasRefreshUI();

	return;

end



--
local tSourceKey;
local tSource;
local tNewKey;
function VUHDO_panelAurasOnCopyAnchor()

	if not VUHDO_PANEL_SETUP or not DESIGN_MISC_PANEL_NUM or not VUHDO_PANEL_AURAS_SELECTED_ANCHOR then
		return;
	end

	tSourceKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);
	tSource = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tSourceKey];

	if not tSource then
		return;
	end

	tNewKey = VUHDO_panelAurasGetNextAnchorKey();
	VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"][tNewKey] = VUHDO_deepCopyTable(tSource);
	VUHDO_PANEL_AURAS_SELECTED_ANCHOR = tonumber(tNewKey);

	VUHDO_panelAurasRefreshUI();

	return;

end



--
local tAnchors;
local tKey;
function VUHDO_panelAurasOnDeleteAnchor()

	if not VUHDO_PANEL_SETUP or not DESIGN_MISC_PANEL_NUM or not VUHDO_PANEL_AURAS_SELECTED_ANCHOR then
		return;
	end

	tAnchors = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["AURA_ANCHORS"];
	tKey = tostring(VUHDO_PANEL_AURAS_SELECTED_ANCHOR);

	if not tAnchors[tKey] then
		return;
	end

	tAnchors[tKey] = nil;
	VUHDO_PANEL_AURAS_SELECTED_ANCHOR = nil;

	for tRemaining, _ in pairs(tAnchors) do
		VUHDO_PANEL_AURAS_SELECTED_ANCHOR = tonumber(tRemaining);

		break;
	end

	VUHDO_panelAurasRefreshUI();

	return;

end



--
local tMainPanel;
local tAnchorCombo;
function VUHDO_panelAurasRefreshUI()

	VUHDO_incrementAuraAnchorConfigVersion();

	VUHDO_initPanelAurasAnchorComboModel();

	tMainPanel = _G["VuhDoNewOptionsPanelAurasMainPanel"];

	if tMainPanel then
		tAnchorCombo = _G[tMainPanel:GetName() .. "AnchorCombo"];

		if tAnchorCombo then
			VUHDO_lnfComboBoxInitFromModel(tAnchorCombo);
		end
	end

	VUHDO_panelAurasAnchorSelectionChanged();

	return;

end