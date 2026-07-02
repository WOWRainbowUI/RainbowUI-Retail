local _;

local C_Timer = C_Timer;


local VUHDO_MIN_MAX_CONSTRAINTS = 1;
local VUHDO_ENUMERATOR_CONSTRAINTS = 2;
local VUHDO_BOOLEAN_CONSTRAINTS = 3;
local VUHDO_TEXT_OPTIONS_CONSTRAINTS = 4;
local VUHDO_ANCHOR_CONSTRAINTS = 5;


local sAnchorPoints = { "Top", "TopLeft", "TopRight", "Bottom", "BottomLeft", "BottomRight", "Left", "Right" };

local sIndicatorTexLeft = 18 / 128;
local sIndicatorTexRight = 108 / 128;

--
local sIndicatorMetaModel = {
	{ -- Outer Border
		["name"] = VUHDO_I18N_OUTER_BORDER,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.BAR_BORDER",
		["icon"] = "Indicator_Outer",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BORDER_WIDTH,
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = 1, ["max"] = 20, ["step"] = 1, ["unit"] = " Pt.",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.BAR_BORDER.WIDTH",
				["tooltip"] = nil,
			},
			{
				["name"] = "材質",
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_BORDERS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.BAR_BORDER.FILE",
				["tooltip"] = nil,
			},
			{
				["name"] = "調整",
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = -20, ["max"] = 0, ["step"] = 1, ["unit"] = "",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.BAR_BORDER.ADJUST",
				["tooltip"] = nil,
			},
		},
	},

	{ -- Inner Border
		["name"] = VUHDO_I18N_INNER_BORDER,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.CLUSTER_BORDER",
		["icon"] = "Indicator_Inner",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BORDER_WIDTH,
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = 1, ["max"] = 20, ["step"] = 1, ["unit"] = " Pt.",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.CLUSTER_BORDER.WIDTH",
				["tooltip"] = nil,
			},
			{
				["name"] = "材質",
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_BORDERS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.CLUSTER_BORDER.FILE",
				["tooltip"] = nil,
			},
		},
	},

	{ -- Swiftmend Indicator
		["name"] = VUHDO_I18N_SWIFTMEND_INDICATOR,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.SWIFTMEND_INDICATOR",
		["icon"] = "Indicator_Swiftmend",
		["custom"] = {
--[[			{
				["name"] = VUHDO_I18N_ICON_GLOW_COLOR,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SWIFTMEND_INDICATOR.isIconGlow",
				["tooltip"] = VUHDO_I18N_TT.K576,
			},]]
			{
				["name"] = VUHDO_I18N_BAR_GLOW_COLOR,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SWIFTMEND_INDICATOR.isBarGlow",
				["tooltip"] = VUHDO_I18N_TT.K577,
			},
			{
				["name"] = VUHDO_I18N_ANCHOR,
				["type"] = VUHDO_ANCHOR_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SWIFTMEND_INDICATOR.anchor",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_X,
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = -100, ["max"] = 100, ["step"] = 0.5, ["unit"] = "%",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SWIFTMEND_INDICATOR.xAdjust",
				["tooltip"] = VUHDO_I18N_TT.K400,
			},
			{
				["name"] = VUHDO_I18N_Y,
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = -100, ["max"] = 100, ["step"] = 0.5, ["unit"] = "%",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SWIFTMEND_INDICATOR.yAdjust",
				["tooltip"] = VUHDO_I18N_TT.K401,
			},
			{
				["name"] = VUHDO_I18N_SCALE,
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = 0.1, ["max"] = 4, ["step"] = 0.05, ["unit"] = " x",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SWIFTMEND_INDICATOR.SCALE",
				["tooltip"] = nil,
			},
		},
	},

	{ -- MouseoverHiglighter
		["name"] = VUHDO_I18N_MOUSEOVER_HIGHLIGHTER,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.MOUSEOVER_HIGHLIGHT",
		["icon"] = "Indicator_BarHighlight",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.MOUSEOVER_HIGHLIGHT.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
		},
	},

	{ -- Aggro Line
		["name"] = VUHDO_I18N_AGGRO_LINE,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.AGGRO_BAR",
		["icon"] = "Indicator_Aggro",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.AGGRO_BAR.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
		},
	},

	{ -- Threat Marks
		["name"] = VUHDO_I18N_THREAT_MARKS,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.THREAT_MARK",
		["icon"] = "Indicator_AggroMark",
		["custom"] = { },
	},

	{ -- Threat Bar
		["name"] = VUHDO_I18N_THREAT_BAR,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.THREAT_BAR",
		["icon"] = "Indicator_ThreatBar",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_HEIGHT,
				["type"] = VUHDO_MIN_MAX_CONSTRAINTS,
				["min"] = 1, ["max"] = 20, ["step"] = 1, ["unit"] = "",
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.THREAT_BAR.HEIGHT",
				["tooltip"] = VUHDO_I18N_TT.K179,
			},
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.THREAT_BAR.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
			{
				["name"] = VUHDO_I18N_INV_GROWTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.THREAT_BAR.invertGrowth",
				["tooltip"] = VUHDO_I18N_TT.K307,
			},
			{
				["name"] = VUHDO_I18N_TURN_AXIS,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.THREAT_BAR.turnAxis",
				["tooltip"] = VUHDO_I18N_TT.K471,
			},
			{
				["name"] = VUHDO_I18N_SMOOTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.THREAT_BAR.smooth",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.THREAT_BAR.TEXT_PROVIDER_SOURCE",
				["pairedFormatModel"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.THREAT_BAR.TEXT_PROVIDER_FORMAT",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = nil,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.THREAT_BAR.TEXT_PROVIDER_FORMAT",
				["isFormatCombo"] = true,
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_BAR_TEXT,
				["type"] = VUHDO_TEXT_OPTIONS_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.THREAT_BAR.TEXT",
				["tooltip"] = nil,
			},
		},

	},

	{ -- Mana Bar
		["name"] = VUHDO_I18N_MANA_BAR,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.MANA_BAR",
		["icon"] = "Indicator_ManaBar",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.MANA_BAR.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
			{
				["name"] = VUHDO_I18N_INV_GROWTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.MANA_BAR.invertGrowth",
				["tooltip"] = VUHDO_I18N_TT.K307,
			},
			{
				["name"] = VUHDO_I18N_TURN_AXIS,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.MANA_BAR.turnAxis",
				["tooltip"] = VUHDO_I18N_TT.K471,
			},
			{
				["name"] = VUHDO_I18N_SMOOTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.MANA_BAR.smooth",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.MANA_BAR.TEXT_PROVIDER_SOURCE",
				["pairedFormatModel"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.MANA_BAR.TEXT_PROVIDER_FORMAT",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = nil,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.MANA_BAR.TEXT_PROVIDER_FORMAT",
				["isFormatCombo"] = true,
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_BAR_TEXT,
				["type"] = VUHDO_TEXT_OPTIONS_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.MANA_BAR.TEXT",
				["tooltip"] = nil,
			},
		},
	},

	{ -- Background Bar
		["name"] = VUHDO_I18N_BACKGROUND_BAR,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.BACKGROUND_BAR",
		["icon"] = "Indicator_BackgroundBar",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.BACKGROUND_BAR.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
		},
	},

	{ -- Health Bar
		["name"] = VUHDO_I18N_HEALTH_BAR,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.HEALTH_BAR",
		["icon"] = "Indicator_HealthBar",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_INV_GROWTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.HEALTH_BAR.invertGrowth",
				["tooltip"] = VUHDO_I18N_TT.K307,
			},
			{
				["name"] = VUHDO_I18N_VERTICAL,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.HEALTH_BAR.vertical",
				["tooltip"] = VUHDO_I18N_TT.K308,
			},
			{
				["name"] = VUHDO_I18N_TURN_AXIS,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.HEALTH_BAR.turnAxis",
				["tooltip"] = VUHDO_I18N_TT.K471,
			},
			{
				["name"] = VUHDO_I18N_SMOOTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.HEALTH_BAR.smooth",
				["tooltip"] = nil,
			},
		},
	},

	{ -- Side Bar left
		["name"] = VUHDO_I18N_SIDE_BAR_LEFT,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.SIDE_LEFT",
		["icon"] = "Indicator_LeftSide",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_LEFT.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
			{
				["name"] = VUHDO_I18N_INV_GROWTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_LEFT.invertGrowth",
				["tooltip"] = VUHDO_I18N_TT.K307,
			},
			{
				["name"] = VUHDO_I18N_VERTICAL,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_LEFT.vertical",
				["tooltip"] = VUHDO_I18N_TT.K308,
			},
			{
				["name"] = VUHDO_I18N_TURN_AXIS,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_LEFT.turnAxis",
				["tooltip"] = VUHDO_I18N_TT.K471,
			},
			{
				["name"] = VUHDO_I18N_SMOOTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_LEFT.smooth",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_LEFT.TEXT_PROVIDER_SOURCE",
				["pairedFormatModel"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_LEFT.TEXT_PROVIDER_FORMAT",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = nil,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_LEFT.TEXT_PROVIDER_FORMAT",
				["isFormatCombo"] = true,
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_BAR_TEXT,
				["type"] = VUHDO_TEXT_OPTIONS_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_LEFT.TEXT",
				["tooltip"] = nil,
			},
		},
	},

	{ -- Side Bar Right
		["name"] = VUHDO_I18N_SIDE_BAR_RIGHT,
		["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.BOUQUETS.SIDE_RIGHT",
		["icon"] = "Indicator_RightSide",
		["custom"] = {
			{
				["name"] = VUHDO_I18N_BAR_TEXTURE,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_STATUS_BARS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_RIGHT.TEXTURE",
				["tooltip"] = VUHDO_I18N_TT.K076,
			},
			{
				["name"] = VUHDO_I18N_INV_GROWTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_RIGHT.invertGrowth",
				["tooltip"] = VUHDO_I18N_TT.K307,
			},
			{
				["name"] = VUHDO_I18N_VERTICAL,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_RIGHT.vertical",
				["tooltip"] = VUHDO_I18N_TT.K308,
			},
			{
				["name"] = VUHDO_I18N_TURN_AXIS,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_RIGHT.turnAxis",
				["tooltip"] = VUHDO_I18N_TT.K471,
			},
			{
				["name"] = VUHDO_I18N_SMOOTH,
				["type"] = VUHDO_BOOLEAN_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.CUSTOM.SIDE_RIGHT.smooth",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_SOURCE_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_RIGHT.TEXT_PROVIDER_SOURCE",
				["pairedFormatModel"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_RIGHT.TEXT_PROVIDER_FORMAT",
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_TEXT_PROVIDER_FORMAT_LABEL,
				["type"] = VUHDO_ENUMERATOR_CONSTRAINTS,
				["enumerator"] = nil,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_RIGHT.TEXT_PROVIDER_FORMAT",
				["isFormatCombo"] = true,
				["tooltip"] = nil,
			},
			{
				["name"] = VUHDO_I18N_BAR_TEXT,
				["type"] = VUHDO_TEXT_OPTIONS_CONSTRAINTS,
				["model"] = "VUHDO_INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS.SIDE_RIGHT.TEXT",
				["tooltip"] = nil,
			},
		},
	},
}


VUHDO_BOUQUET_SLOTS_COMBO_MODEL = { };

function VUHDO_initBouquetSlotsComboModel()
	table.wipe(VUHDO_BOUQUET_SLOTS_COMBO_MODEL);

	for tName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
		tinsert(VUHDO_BOUQUET_SLOTS_COMBO_MODEL, { tName, tName } );
	end

	table.sort(VUHDO_BOUQUET_SLOTS_COMBO_MODEL,
		function(anInfo, anotherInfo)
			return anInfo[2] < anotherInfo[2];
		end
	);

	tinsert(VUHDO_BOUQUET_SLOTS_COMBO_MODEL, 1, {"", " -- 關閉 / 空的 --" });

	VUHDO_newOptionsIndicatorsInvalidate();

	return;

end



--
local tCombo;
local tLabelPlate;
local tSchemaPlate;
local tSchemaTexture;
local tPR;
local tPG;
local tPB;
local tPO;
local function VUHDO_setBouquetSelectorModel(aPanel, aText, aModel, aTexture)

	_G[aPanel:GetName() .. "SelectLabelLabel"]:SetText(aText);

	tSchemaTexture = _G[aPanel:GetName() .. "SchemaTexture"];
	tSchemaTexture:SetTexture(VUHDO_lnfSkinResolveOptionsImage(aTexture));
	tSchemaTexture:SetTexCoord(sIndicatorTexLeft, sIndicatorTexRight, 0, 1);

	tPR, tPG, tPB, tPO = VUHDO_lnfSkinGetIndicatorPlateColor();

	tSchemaPlate = _G[aPanel:GetName() .. "SchemaPlate"];
	tSchemaPlate:SetVertexColor(tPR or 1, tPG or 1, tPB or 1, tPR and tPO or 0);

	tLabelPlate = _G[aPanel:GetName() .. "SelectLabelTexture"];
	tLabelPlate:SetAlpha(tPR and 0 or 0.9);

	tCombo = _G[aPanel:GetName() .. "SelectComboBox"];

	VUHDO_setComboModel(tCombo, aModel, VUHDO_BOUQUET_SLOTS_COMBO_MODEL);

	tCombo["lazyItems"] = true;
	tCombo["itemsBuilt"] = false;

	VUHDO_lnfComboBoxInitFromModel(tCombo);

	return;

end



--
function VUHDO_notifyBouquetSelect()
	VUHDO_registerAllBouquets(false);
	VUHDO_initAllEventBouquets();
end



--
local tCombo;
function VUHDO_generalIndicatorsEditButtonClicked(aButton)

	tCombo = _G[aButton:GetParent():GetName() .. "SelectComboBox"];
	VUHDO_BOUQUETS["SELECTED"] = VUHDO_lnfGetValueFromModel(tCombo);

	VUHDO_MENU_RETURN_TARGET = nil;
	VUHDO_MENU_RETURN_TARGET_MAIN = VuhDoNewOptionsTabbedFrameTabsPanelPanelsRadioButton;

	VUHDO_newOptionsTabbedClickedClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);
	VUHDO_lnfRadioButtonClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);

	VUHDO_lnfTabRadioButtonClicked(VuhDoNewOptionsGeneralRadioPanelBouquetRadioButton);

end



--
local tName;
local tSlider;
local function VUHDO_createSliderForComponent(anIndex, anElement, aParent)
	tName = "VuhDoIndicatorOptionsSlider" .. aParent:GetName() .. anIndex;
	tSlider = _G[tName];
	if (tSlider == nil) then
		tSlider = CreateFrame("Frame", tName, aParent, "VuhDoHSliderTemplate");
	end

	VUHDO_PixelUtil.SetWidth(tSlider, 150);
	VUHDO_PixelUtil.SetHeight(tSlider, 32);

	VUHDO_lnfSliderOnLoad(tSlider, anElement["name"], anElement["min"], anElement["max"], anElement["unit"], anElement["step"]);
	VUHDO_lnfSetModel(tSlider, anElement["model"]);
	VUHDO_lnfSliderInitFromModel(tSlider);
	VUHDO_lnfSetTooltip(tSlider, anElement["tooltip"]);

	return tSlider;
end



--
local tName;
local tCheckButton;
local function VUHDO_createCheckBoxForComponent(anIndex, anElement, aParent)
	tName = "VuhDoIndicatorOptions" .. aParent:GetName() .. anIndex .. "CheckButton";
	tCheckButton = _G[tName];
	if (tCheckButton == nil) then
		tCheckButton = CreateFrame("CheckButton", tName, aParent, "VuhDoCheckButtonTemplate");
	end
	tCheckButton:SetText(anElement["name"]);
	VUHDO_lnfCheckButtonOnLoad(tCheckButton);
	VUHDO_lnfSetModel(tCheckButton, anElement["model"]);
	VUHDO_lnfCheckButtonInitFromModel(tCheckButton);
	VUHDO_lnfSetTooltip(tCheckButton, anElement["tooltip"]);

	return tCheckButton;
end



--
local sPendingSourceCombo;



--
local tFormatCombo;
local tSourceEntry;
local tFormatCnt;
local tCurrentFormat;
local tIsFormatSupported;
function VUHDO_textProviderSourceChanged(aSourceCombo, aNewSourceValue)

	tFormatCombo = aSourceCombo:GetAttribute("pairedFormatCombo");

	if not tFormatCombo then
		return;
	end

	tFormatCombo:SetAttribute("combo_table", VUHDO_getFormatComboModelForSource(aNewSourceValue));

	tCurrentFormat = VUHDO_lnfGetValueFromModel(tFormatCombo);
	tSourceEntry = VUHDO_TEXT_PROVIDER_SOURCES[aNewSourceValue];

	if tSourceEntry and tCurrentFormat then
		tIsFormatSupported = false;

		for tFormatCnt = 1, #tSourceEntry["supportedFormats"] do
			if tSourceEntry["supportedFormats"][tFormatCnt] == tCurrentFormat then
				tIsFormatSupported = true;

				break;
			end
		end

		if not tIsFormatSupported then
			VUHDO_lnfUpdateVar(tFormatCombo:GetAttribute("model"), tSourceEntry["defaultFormat"]);
		end
	end

	VUHDO_lnfComboBoxInitFromModel(tFormatCombo);

	VUHDO_initAllEventBouquets();

	return;

end



--
function VUHDO_textProviderFormatChanged(aFormatCombo, aNewFormatValue)

	VUHDO_initAllEventBouquets();

	return;

end



--
local tSourceModel;
local tSourceKey;
function VUHDO_initTextProviderFormatCombo(aFormatCombo, aFormatModel)

	tSourceModel = (aFormatModel):gsub("TEXT_PROVIDER_FORMAT", "TEXT_PROVIDER_SOURCE", 1);
	tSourceKey = VUHDO_lnfGetValueFrom(tSourceModel) or "";

	aFormatCombo:SetAttribute("combo_table", VUHDO_getFormatComboModelForSource(tSourceKey));
	VUHDO_lnfComboBoxInitFromModel(aFormatCombo);

	return;

end



--
local tName;
local tPanel;
local tCombo;
local tTexture;
local function VUHDO_createComboBoxForComponent(anIndex, anElement, aParent)
	tName = "VuhDoIndicatorOptionsComboPanel" .. aParent:GetName() .. anIndex;
	tPanel = _G[tName];
	if (tPanel == nil) then
		tPanel = CreateFrame("Frame", tName, aParent, "VuhDoMoreButtonsTexturePanel");
	end

	VUHDO_PixelUtil.SetWidth(tPanel, 150);

	tCombo = _G[tName .. "Combo"];

	if anElement["isFormatCombo"] then
		VUHDO_setComboModel(tCombo, anElement["model"], nil);
		VUHDO_initTextProviderFormatCombo(tCombo, anElement["model"]);

		tCombo:SetAttribute("custom_function", VUHDO_textProviderFormatChanged);

		if sPendingSourceCombo then
			sPendingSourceCombo:SetAttribute("pairedFormatCombo", tCombo);
			sPendingSourceCombo = nil;
		end
	elseif anElement["pairedFormatModel"] then
		VUHDO_setComboModel(tCombo, anElement["model"], anElement["enumerator"]);

		tCombo:SetAttribute("pairedFormatModel", anElement["pairedFormatModel"]);
		tCombo:SetAttribute("custom_function", VUHDO_textProviderSourceChanged);

		sPendingSourceCombo = tCombo;

		VUHDO_lnfComboBoxInitFromModel(tCombo);
	else
		VUHDO_setComboModel(tCombo, anElement["model"], anElement["enumerator"]);
		VUHDO_lnfComboBoxInitFromModel(tCombo);
	end

	VUHDO_lnfSetTooltip(tCombo, anElement["tooltip"]);

	tTexture = _G[tName .. "Texture"];
	if (strfind(anElement["model"], "TEXTURE")) then
		VUHDO_lnfSetModel(tTexture, anElement["model"]);
		VUHDO_lnfTextureSwatchInitFromModel(tTexture);
		_G[tTexture:GetName() .. "TitleString"]:SetText(anElement["name"]);
		tTexture:Show();
		VUHDO_PixelUtil.SetHeight(tPanel, 70);
	else
		tTexture:Hide();
		VUHDO_PixelUtil.SetHeight(tPanel, 38);
	end

	_G[tName .. "TitleLabelLabel"]:SetText(anElement["name"]);

	return tPanel;
end



--
local tName;
local tButton;
local function VUHDO_createTextOptionsButtonForComponent(anIndex, anElement, aParent)
	tName = "VuhDoIndicatorOptions" .. aParent:GetName() .. anIndex .. "TextOptionsButton";
	tButton = _G[tName];
	if (tButton == nil) then
		tButton = CreateFrame("CheckButton", tName, aParent, "VuhDoFontButtonTemplate");
	end
	tButton:SetText(anElement["name"]);
	VUHDO_lnfSetModel(tButton, anElement["model"]);

	return tButton;
end



--
local tName;
local tPanel, tCheckButton;
local function VUHDO_createAnchorRadioForComponent(anIndex, anElement, aParent)

	tName = "VuhDoIndicatorOptions" .. aParent:GetName() .. anIndex .. "AnchorTexture";
	tPanel = _G[tName];

	if tPanel == nil then
		tPanel = CreateFrame("Frame", tName, aParent, "VuhDoMoreButtonsAnchorPanel");
	end

	for _, tPoint in pairs(sAnchorPoints) do
		tCheckButton = _G[tName .. tPoint .. "RadioButton"];

		if tCheckButton then
			VUHDO_lnfSetRadioModel(tCheckButton, anElement["model"], string.upper(tPoint));
		end
	end

	return tPanel;

end



--
local tComponent, tYCompOfs;
local function VUHDO_buildCustomComponents(aPanel, someCustomElements)
	tYCompOfs = -10;
	for tIndex, tElement in ipairs(someCustomElements) do
		if (VUHDO_MIN_MAX_CONSTRAINTS == tElement["type"]) then
			tComponent = VUHDO_createSliderForComponent(tIndex, tElement, aPanel);
		elseif(VUHDO_ENUMERATOR_CONSTRAINTS == tElement["type"]) then
			tComponent = VUHDO_createComboBoxForComponent(tIndex, tElement, aPanel);
		elseif(VUHDO_BOOLEAN_CONSTRAINTS == tElement["type"]) then
			tComponent = VUHDO_createCheckBoxForComponent(tIndex, tElement, aPanel);
		elseif(VUHDO_TEXT_OPTIONS_CONSTRAINTS == tElement["type"]) then
			tComponent = VUHDO_createTextOptionsButtonForComponent(tIndex, tElement, aPanel);
		elseif(VUHDO_ANCHOR_CONSTRAINTS == tElement["type"]) then
			tComponent = VUHDO_createAnchorRadioForComponent(tIndex, tElement, aPanel);
		end

		if (tComponent ~= nil) then
			tComponent:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(tComponent, "TOP", aPanel:GetName(), "TOP", 0, tYCompOfs);
			tYCompOfs = tYCompOfs - (tComponent:GetHeight() + 10);
		end
	end

	return -tYCompOfs;
end


local sAllMorePanels = { };
local sCustomBuilt = { };
local sIndicatorsBuilt = false;
local sIndicatorsBuilding = false;
local sIndicatorsDirty = false;
local sBuildScrollChild = nil;
local sBuildIndex = 1;
local sBuildXOfs = 10;
local sBuildYIndex = 0;
local sLastPanelNum = nil;
local sSlotsPerChunk = 1;


--
function VUHDO_newOptionsIndicatorsInvalidate()

	sIndicatorsDirty = true;

	return;

end



--
local tFunc;
local function VUHDO_lnfComboRefreshFromModelSilent(aComboBox)

	tFunc = aComboBox:GetAttribute("custom_function");
	aComboBox:SetAttribute("custom_function", nil);
	VUHDO_lnfComboBoxInitFromModel(aComboBox);

	if tFunc then
		aComboBox:SetAttribute("custom_function", tFunc);
	end

	return;

end



--
local tMorePanelName;
local tCombo;
local tSlider;
local tCheckButton;
local tButton;
local tAnchorPanel;
local function VUHDO_newOptionsIndicatorsRefreshCustomComponent(anIndex, anElement, aMorePanelName)

	if (VUHDO_MIN_MAX_CONSTRAINTS == anElement["type"]) then
		tSlider = _G["VuhDoIndicatorOptionsSlider" .. aMorePanelName .. anIndex];

		if tSlider then
			VUHDO_lnfSliderInitFromModel(tSlider);
		end
	elseif (VUHDO_ENUMERATOR_CONSTRAINTS == anElement["type"]) then
		tCombo = _G["VuhDoIndicatorOptionsComboPanel" .. aMorePanelName .. anIndex .. "Combo"];

		if tCombo then
			if anElement["isFormatCombo"] then
				VUHDO_initTextProviderFormatCombo(tCombo, anElement["model"]);
			else
				VUHDO_lnfComboRefreshFromModelSilent(tCombo);
			end
		end
	elseif (VUHDO_BOOLEAN_CONSTRAINTS == anElement["type"]) then
		tCheckButton = _G["VuhDoIndicatorOptions" .. aMorePanelName .. anIndex .. "CheckButton"];

		if tCheckButton then
			VUHDO_lnfCheckButtonInitFromModel(tCheckButton);
		end
	elseif (VUHDO_TEXT_OPTIONS_CONSTRAINTS == anElement["type"]) then
		tButton = _G["VuhDoIndicatorOptions" .. aMorePanelName .. anIndex .. "TextOptionsButton"];

		if tButton then
			VUHDO_lnfSetModel(tButton, anElement["model"]);
		end
	elseif (VUHDO_ANCHOR_CONSTRAINTS == anElement["type"]) then
		tAnchorPanel = _G["VuhDoIndicatorOptions" .. aMorePanelName .. anIndex .. "AnchorTexture"];

		if tAnchorPanel then
			for _, tPoint in pairs(sAnchorPoints) do
				tCheckButton = _G[tAnchorPanel:GetName() .. tPoint .. "RadioButton"];

				if tCheckButton then
					VUHDO_lnfRadioButtonInitFromModel(tCheckButton);
				end
			end
		end
	end

	return;

end



--
local tBouqetSlotName;
function VUHDO_newOptionsIndicatorsRefreshValues(aScrollChild)

	if not sIndicatorsDirty then
		return;
	end

	for tIndex, tIndicator in ipairs(sIndicatorMetaModel) do
		tBouqetSlotName = "VuhDoBouqetSlotItem" .. tIndex;
		tCombo = _G[tBouqetSlotName .. "SelectComboBox"];

		if tCombo then
			VUHDO_setComboModel(tCombo, tIndicator["model"], VUHDO_BOUQUET_SLOTS_COMBO_MODEL);

			tCombo["lazyItems"] = true;
			tCombo["itemsBuilt"] = false;

			VUHDO_lnfComboBoxInitFromModel(tCombo);
		end

		if (#tIndicator["custom"] > 0) and sCustomBuilt[tBouqetSlotName] then
			tMorePanelName = tBouqetSlotName .. "MorePanel";

			for tCustomIndex, tElement in ipairs(tIndicator["custom"]) do
				VUHDO_newOptionsIndicatorsRefreshCustomComponent(tCustomIndex, tElement, tMorePanelName);
			end
		end
	end

	sIndicatorsDirty = false;
	sLastPanelNum = DESIGN_MISC_PANEL_NUM;

	return;

end



--
local tBouquetSlot;
local tMorePanel;
local tHeight;
local tIndicator;
local function VUHDO_newOptionsIndicatorsBuildOneSlot(aScrollChild, tIndex)

	tIndicator = sIndicatorMetaModel[tIndex];
	tBouqetSlotName = "VuhDoBouqetSlotItem" .. tIndex;

	if (_G[tBouqetSlotName] == nil) then
		tBouquetSlot = CreateFrame("ScrollFrame", tBouqetSlotName, aScrollChild, "VuhDoBouquetSlotTemplate");
	else
		tBouquetSlot = _G[tBouqetSlotName];
	end

	tBouquetSlot["indicatorIndex"] = tIndex;

	tBouquetSlot:ClearAllPoints();
	VUHDO_PixelUtil.SetPoint(tBouquetSlot, "TOPLEFT", aScrollChild:GetName(), "TOPLEFT", sBuildXOfs, - sBuildYIndex * tBouquetSlot:GetHeight() - 3);

	VUHDO_setBouquetSelectorModel(tBouquetSlot, tIndicator["name"], tIndicator["model"], tIndicator["icon"]);

	if (#tIndicator["custom"] == 0) then
		_G[tBouqetSlotName .. "MoreButton"]:Hide();
	end

	sBuildYIndex = sBuildYIndex + 1;

	if (sBuildYIndex >= 6) then
		sBuildXOfs = 10 + 10 + tBouquetSlot:GetWidth() + 100;
		sBuildYIndex = 0;
	end

	VUHDO_lnfSkinApplyToFrameTree(tBouquetSlot);

	return;

end



--
function VUHDO_newOptionsIndicatorsBuildSlotCustom(aSlotName, anIndex)

	if sCustomBuilt[aSlotName] then
		return;
	end

	tIndicator = sIndicatorMetaModel[anIndex];

	if not tIndicator or #tIndicator["custom"] == 0 then
		return;
	end

	tMorePanel = _G[aSlotName .. "MorePanel"];

	tHeight = VUHDO_buildCustomComponents(tMorePanel, tIndicator["custom"]);

	VUHDO_PixelUtil.SetHeight(tMorePanel, tHeight + 30);
	sAllMorePanels[tMorePanel] = true;
	sCustomBuilt[aSlotName] = true;

	VUHDO_lnfSkinApplyToFrameTree(tMorePanel);

	return;

end



--
local tSlot;
function VUHDO_newOptionsIndicatorsShowMore(aMoreButton)

	tSlot = aMoreButton:GetParent();
	VUHDO_newOptionsIndicatorsBuildSlotCustom(tSlot:GetName(), tSlot["indicatorIndex"]);

	tMorePanel = _G[tSlot:GetName() .. "MorePanel"];

	if tMorePanel:IsShown() then
		tMorePanel:Hide();
	else
		VUHDO_hideAllMorePanels();
		tMorePanel:Show();
	end

	return;

end



--
local tSlotsBuilt;
function VUHDO_newOptionsIndicatorsBuildNextChunk()

	if not sBuildScrollChild then
		sIndicatorsBuilding = false;

		return;
	end

	tSlotsBuilt = 0;

	while sBuildIndex <= #sIndicatorMetaModel and tSlotsBuilt < sSlotsPerChunk do
		VUHDO_newOptionsIndicatorsBuildOneSlot(sBuildScrollChild, sBuildIndex);
		sBuildIndex = sBuildIndex + 1;
		tSlotsBuilt = tSlotsBuilt + 1;
	end

	if sBuildIndex > #sIndicatorMetaModel then
		sIndicatorsBuilt = true;
		sIndicatorsBuilding = false;
		sIndicatorsDirty = false;
		sLastPanelNum = DESIGN_MISC_PANEL_NUM;
		sBuildScrollChild = nil;

		return;
	end

	C_Timer.After(0, VUHDO_newOptionsIndicatorsBuildNextChunk);

	return;

end



--
function VUHDO_newOptionsIndicatorsStartBuild(aScrollChild)

	sBuildScrollChild = aScrollChild;
	sBuildIndex = 1;
	sBuildXOfs = 10;
	sBuildYIndex = 0;
	sIndicatorsBuilding = true;

	C_Timer.After(0, VUHDO_newOptionsIndicatorsBuildNextChunk);

	return;

end



--
function VUHDO_newOptionsIndicatorsEnsureBuilt()

	if sIndicatorsBuilt or sIndicatorsBuilding then
		return;
	end

	VUHDO_newOptionsIndicatorsStartBuild(_G["VuhDoNewOptionsPanelIndicatorsSlotsPanel"]);

	return;

end



--
function VUHDO_newOptionsIndicatorsFinishBuild()

	if not sBuildScrollChild then
		return;
	end

	while sBuildIndex <= #sIndicatorMetaModel do
		VUHDO_newOptionsIndicatorsBuildOneSlot(sBuildScrollChild, sBuildIndex);
		sBuildIndex = sBuildIndex + 1;
	end

	sIndicatorsBuilt = true;
	sIndicatorsBuilding = false;
	sIndicatorsDirty = false;
	sLastPanelNum = DESIGN_MISC_PANEL_NUM;
	sBuildScrollChild = nil;

	return;

end



--
function VUHDO_newOptionsIndicatorsOnShow(aScrollChild)

	if not sIndicatorsBuilt then
		if not sIndicatorsBuilding then
			VUHDO_newOptionsIndicatorsStartBuild(aScrollChild);
		end

		VUHDO_newOptionsIndicatorsFinishBuild();

		return;
	end

	if sLastPanelNum ~= DESIGN_MISC_PANEL_NUM then
		sIndicatorsDirty = true;
	end

	VUHDO_newOptionsIndicatorsRefreshValues(aScrollChild);

	return;

end



function VUHDO_hideAllMorePanels()
	--VUHDO_Msg("Hide")
	for tPanel, _ in pairs(sAllMorePanels) do
		--VUHDO_Msg(tPanel:GetName());
		tPanel:Hide();
	end
end
