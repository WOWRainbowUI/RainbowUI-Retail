local _;

local _G = _G;
local pairs = pairs;
local ipairs = ipairs;
local type = type;
local strfind = strfind;
local format = format;
local tinsert = table.insert;
local tsort = table.sort;
local twipe = table.wipe;
local hooksecurefunc = hooksecurefunc;

local VUHDO_PixelUtil = VUHDO_PixelUtil;

local sImagesPath = "Interface\\AddOns\\VuhDoOptions\\Images\\";
local sDarkImagesPath = "Interface\\AddOns\\VuhDoOptions\\Images\\Dark\\";

VUHDO_OPTIONS_SKINS = { };
local VUHDO_OPTIONS_SKINS = VUHDO_OPTIONS_SKINS;

local sClassicSkin = {
	["displayName"] = VUHDO_I18N_SKIN_CLASSIC,
	["sliderStyle"] = "classic",
	["tabStyle"] = "pill",
	["textureTints"] = {
		["icon_tree_expand"] = { 0.30, 0.47, 0.80, 1 },
	},
};

local sDarkSkin = {
	["displayName"] = VUHDO_I18N_SKIN_DARK,
	["sliderStyle"] = "arrows",
	["tabStyle"] = "pill",
	["toggleStyle"] = "box",
	["checkFaceHidden"] = true,
	["checkLabelLeft"] = true,
	["badgeOnlyButtons"] = true,
	["font"] = "Interface\\AddOns\\VuhDo\\Fonts\\TitilliumWeb-Bold.ttf",
	["imagesPath"] = sDarkImagesPath,
	["indicatorPlate"] = { 0.278, 0.298, 0.357, 1 },
	["textures"] = {
		["icon_okay"] = sDarkImagesPath .. "icon_okay",
		["icon_cancel"] = sDarkImagesPath .. "icon_cancel",
		["icon_plus"] = sDarkImagesPath .. "icon_plus",
		["icon_share"] = sDarkImagesPath .. "icon_share",
		["icon_question"] = sDarkImagesPath .. "icon_question",
		["icon_apply_all"] = sDarkImagesPath .. "icon_apply_all",
		["icon_font"] = sDarkImagesPath .. "icon_font",
		["icon_back"] = sDarkImagesPath .. "icon_back",
		["icon_arrow_up"] = sDarkImagesPath .. "icon_arrow_up",
		["icon_arrow_down"] = sDarkImagesPath .. "icon_arrow_down",
		["icon_arrow_right"] = sDarkImagesPath .. "icon_arrow_right",
	},
	["textureTints"] = {
		["icon_red"] = { 0.85, 0.25, 0.25, 1 },
		["status_dot"] = { 0.55, 0.58, 0.63, 1 },
		["combo_select_dot"] = { 0.55, 0.58, 0.63, 1 },
		["icon_white_square"] = { 0.75, 0.78, 0.82, 1 },
		["icon_check_2"] = { 0.75, 0.78, 0.82, 1 },
		["bar_example"] = { 0.25, 0.27, 0.31, 1 },
		["icon_tree_expand"] = { 1, 1, 1, 1 },
	},
	["backdropColors"] = {
		["slider"] = {
			["bg"] = { 0.373, 0.408, 0.443, 1 },
			["border"] = { 0.373, 0.408, 0.443, 1 },
		},
		["frame"] = {
			["bg"] = { 0.082, 0.090, 0.110, 1 },
			["border"] = { 0.45, 0.48, 0.53, 1 },
		},
		["panel"] = {
			["bg"] = { 0.082, 0.090, 0.110, 1 },
			["border"] = { 0.227, 0.247, 0.290, 1 },
		},
		["scroll"] = {
			["bg"] = { 0.082, 0.090, 0.110, 1 },
			["border"] = { 0.227, 0.247, 0.290, 1 },
		},
		["footer"] = {
			["bg"] = { 0.082, 0.090, 0.110, 1 },
			["border"] = { 0.45, 0.48, 0.53, 1 },
		},
	},
	["comboItemColors"] = {
		["normal"] = { 0.082, 0.090, 0.110, 1 },
		["hover"] = { 0.25, 0.28, 0.34, 1 },
	},
	["triStateValueColors"] = {
		{ 0.45, 0.85, 0.45, 1 },
		{ 0.55, 0.70, 0.95, 1 },
		{ 0.90, 0.45, 0.45, 1 },
	},
	["fontColors"] = {
		["normal"] = {
			["TR"] = 0.91,
			["TG"] = 0.92,
			["TB"] = 0.94,
			["TO"] = 1,
		},
		["title"] = {
			["TR"] = 0.91,
			["TG"] = 0.92,
			["TB"] = 0.94,
			["TO"] = 1,
		},
		["active"] = {
			["TR"] = 0.82,
			["TG"] = 0.84,
			["TB"] = 0.87,
			["TO"] = 1,
		},
		["value"] = {
			["TR"] = 0.75,
			["TG"] = 0.78,
			["TB"] = 0.82,
			["TO"] = 1,
		},
	},
	["sliderArrowColor"] = { 1, 1, 1, 1 },
	["accentColor"] = { 0.45, 0.68, 0.95, 1 },
	["entrySelectColor"] = { 0.20, 0.30, 0.45, 1 },
	["swatchBorderColor"] = { 0.45, 0.48, 0.53, 1 },
	["glyphColor"] = { 0.55, 0.58, 0.63, 1 },
	["tabLabelColors"] = {
		["active"] = {
			["TR"] = 0.95,
			["TG"] = 0.96,
			["TB"] = 0.98,
			["TO"] = 1,
		},
		["inactive"] = {
			["TR"] = 0.55,
			["TG"] = 0.58,
			["TB"] = 0.63,
			["TO"] = 1,
		},
	},
	["radioSwatchOffsetY"] = 3,
};

VUHDO_OPTIONS_SKIN_COMBO_TABLE = { };
local VUHDO_OPTIONS_SKIN_COMBO_TABLE = VUHDO_OPTIONS_SKIN_COMBO_TABLE;

local sDefaultTextures = {
	["blue_dk_square_16_16"] = sImagesPath .. "blue_dk_square_16_16",
	["scroll_bar_bg_16_16"] = sImagesPath .. "scroll_bar_bg_16_16",
	["blue_lt_square_16_16"] = sImagesPath .. "blue_lt_square_16_16",
	["button_combo_32_32"] = sImagesPath .. "button_combo_32_32",
	["button_combo_edit_128_32"] = sImagesPath .. "button_combo_edit_128_32",
	["button_combo_pressed_32_32"] = sImagesPath .. "button_combo_pressed_32_32",
	["button_normal_128_32"] = sImagesPath .. "button_normal_128_32",
	["button_pressed_128_32"] = sImagesPath .. "button_pressed_128_32",
	["button_up_32_32"] = sImagesPath .. "button_up_32_32",
	["icon_black"] = sImagesPath .. "icon_black",
	["icon_aura"] = sImagesPath .. "icon_aura",
	["icon_blue_square"] = sImagesPath .. "icon_blue_square",
	["icon_check"] = sImagesPath .. "icon_check",
	["icon_check_tri"] = sImagesPath .. "icon_check_tri",
	["icon_tree_expand"] = sImagesPath .. "icon_tree_expand",
	["icon_white"] = sImagesPath .. "icon_white",
	["status_dot"] = sImagesPath .. "status_dot",
	["input_border_1"] = sImagesPath .. "input_border_1",
	["panel_edges_1"] = sImagesPath .. "panel_edges_1",
	["panel_edges_2"] = sImagesPath .. "panel_edges_2",
	["panel_edges_2_append_bottom"] = sImagesPath .. "panel_edges_2_append_bottom",
	["panel_edges_3"] = sImagesPath .. "panel_edges_3",
	["panel_edges_4"] = sImagesPath .. "panel_edges_4",
	["slider_thumb_h"] = sImagesPath .. "slider_thumb_h",
	["slider_thumb_v"] = sImagesPath .. "slider_thumb_v",
	["tabstop_active"] = sImagesPath .. "tabstop_active",
	["tabstop_inactive"] = sImagesPath .. "tabstop_inactive",
};

local sBackdropGlobals = {
	["BACKDROP_VUHDO_H_SLIDER_8_8_1111"] = "slider",
	["BACKDROP_VUHDO_FRAME_16_16_1111"] = "frame",
	["BACKDROP_VUHDO_PANEL_16_16_3333"] = "panel",
	["BACKDROP_VUHDO_WHITE_PANEL_16_16_3333"] = "panel",
	["BACKDROP_VUHDO_WHITE_SQUARE_16_16_0000"] = "panel",
	["BACKDROP_VUHDO_PANEL_SCROLL_BAR_8_8_1111"] = "scroll",
	["BACKDROP_VUHDO_SCROLL_PANEL_16_16_0000"] = "scroll",
	["BACKDROP_VUHDO_SCROLL_PANEL_2_16_16_0000"] = "scroll",
	["BACKDROP_VUHDO_PANEL_APPEND_BOTTOM_16_16_1111"] = "footer",
	["BACKDROP_VUHDO_COLOR_PICKER_SLIDER_8_8_1111"] = "slider",
};

local sSliderBackdropWhiteFill = "Interface\\AddOns\\VuhDo\\Images\\white_square_16_16";

local sSliderBackdropNames = {
	["BACKDROP_VUHDO_H_SLIDER_8_8_1111"] = true,
	["BACKDROP_VUHDO_COLOR_PICKER_SLIDER_8_8_1111"] = true,
};

local sBackdropFileKeys = {
	["blue_lt_square_16_16"] = "blue_lt_square_16_16",
	["blue_dk_square_16_16"] = "blue_dk_square_16_16",
	["scroll_bar_bg_16_16"] = "scroll_bar_bg_16_16",
	["panel_edges_1"] = "panel_edges_1",
	["panel_edges_2"] = "panel_edges_2",
	["panel_edges_2_append_bottom"] = "panel_edges_2_append_bottom",
	["panel_edges_3"] = "panel_edges_3",
	["panel_edges_4"] = "panel_edges_4",
};

local sSkinReady = false;
local sPatchFontHooked = false;
local sTabGlyphHooked = false;
local sTriStateHooked = false;
local sComboHooked = false;
local sSquareDemoHooked = false;
local sAuraGroupsHooked = false;
local sBackdropsSnapshotted = false;
local sComboTableInitialized = false;
local sOriginalBackdropFiles = { };
local sEmpty = { };

local sNativeTextures = { };
local sNativeBackdrops = { };
local sNativeFontStrings = { };
local sNativeTabState = { };
local sNativeSliderState = { };
local sNativeSliderArrowState = { };
local sNativeSliderLabelState = { };
local sNativeEditBoxState = { };
local sNativeTriStateState = { };
local sNativeCheckFaceState = { };

local sFrameRegionTextureKeys = {
	["blue_dk_square_16_16"] = "blue_dk_square_16_16",
	["bar15"] = "bar_example",
};

local sKnownSkinKeys = {
	["sliderStyle"] = true,
	["tabStyle"] = true,
	["toggleStyle"] = true,
	["checkFaceHidden"] = true,
	["checkLabelLeft"] = true,
	["checkGroupPlate"] = true,
	["badgeOnlyButtons"] = true,
	["displayName"] = true,
	["imagesPath"] = true,
	["indicatorPlate"] = true,
	["textures"] = true,
	["textureTints"] = true,
	["backdropColors"] = true,
	["fontColors"] = true,
	["sliderArrowColor"] = true,
	["accentColor"] = true,
	["entrySelectColor"] = true,
	["swatchBorderColor"] = true,
	["glyphColor"] = true,
	["tabIcons"] = true,
	["comboItemColors"] = true,
	["triStateValueColors"] = true,
	["tabLabelColors"] = true,
	["radioSwatchOffsetY"] = true,
	["font"] = true,
};

local sValidComboItemColorKeys = {
	["normal"] = true,
	["hover"] = true,
};

local sValidBackdropColorKeys = {
	["slider"] = true,
	["frame"] = true,
	["panel"] = true,
	["scroll"] = true,
	["footer"] = true,
};

local sValidFontColorKeys = {
	["normal"] = true,
	["title"] = true,
	["active"] = true,
	["value"] = true,
};

local tDarkTextureNames = {
	"blue_dk_square_16_16",
	"scroll_bar_bg_16_16",
	"blue_lt_square_16_16",
	"button_combo_32_32",
	"button_combo_edit_128_32",
	"button_combo_pressed_32_32",
	"button_normal_128_32",
	"button_pressed_128_32",
	"button_up_32_32",
	"icon_black",
	"icon_aura",
	"icon_blue_square",
	"icon_check",
	"icon_tree_expand",
	"icon_white",
	"status_dot",
	"combo_select_dot",
	"input_border_1",
	"panel_edges_1",
	"panel_edges_2",
	"panel_edges_2_append_bottom",
	"panel_edges_3",
	"panel_edges_4",
	"slider_thumb_h",
	"slider_thumb_v",
	"tabstop_active",
	"tabstop_inactive",
};

for tCnt = 1, #tDarkTextureNames do
	sDarkSkin["textures"][tDarkTextureNames[tCnt]] = sDarkImagesPath .. tDarkTextureNames[tCnt];
end

sDarkSkin["textures"]["icon_check_tri"] = sDarkImagesPath .. "icon_check";



--
local tName;
local tKey;
local tPath;
local tBaseName;
local tBaseIdx;
local function VUHDO_lnfSkinBasenameFromPath(aPath)

	if not aPath then
		return nil;
	end

	tBaseName = aPath;
	tBaseIdx = strfind(tBaseName, "\\[^\\]+$");

	if tBaseIdx then
		tBaseName = string.sub(tBaseName, tBaseIdx + 1);
	end

	tBaseIdx = strfind(tBaseName, "/[^/]+$");

	if tBaseIdx then
		tBaseName = string.sub(tBaseName, tBaseIdx + 1);
	end

	return tBaseName;

end



--
local tSkin;
local function VUHDO_lnfSkinGetActiveEntry()

	if not VUHDO_OPTIONS_SETTINGS then
		return VUHDO_OPTIONS_SKINS["Classic"];
	end

	tSkin = VUHDO_OPTIONS_SETTINGS["SKIN"] or "Classic";

	if tSkin == "Default" then
		tSkin = "Classic";
	end

	return VUHDO_OPTIONS_SKINS[tSkin] or VUHDO_OPTIONS_SKINS["Classic"];

end



--
function VUHDO_lnfSkinGetActive()

	tSkin = VUHDO_OPTIONS_SETTINGS and VUHDO_OPTIONS_SETTINGS["SKIN"] or "Classic";

	if tSkin == "Default" then
		tSkin = "Classic";
	end

	return tSkin;

end



--
function VUHDO_lnfSkinResolveOptionsImage(aBasename)

	return (VUHDO_lnfSkinGetActiveEntry()["imagesPath"] or sImagesPath) .. aBasename;

end



--
function VUHDO_lnfSkinGetIndicatorPlateColor()

	if VUHDO_lnfSkinGetActiveEntry()["indicatorPlate"] then
		return VUHDO_lnfSkinGetActiveEntry()["indicatorPlate"][1], VUHDO_lnfSkinGetActiveEntry()["indicatorPlate"][2], VUHDO_lnfSkinGetActiveEntry()["indicatorPlate"][3], VUHDO_lnfSkinGetActiveEntry()["indicatorPlate"][4] or 1;
	end

	return;

end



--
function VUHDO_lnfSkinStyleListEntry(aPanel, anIsSelected)

	if not aPanel or not aPanel.SetBackdropColor then
		return;
	end

	aPanel["skinListEntry"] = true;
	aPanel["skinListEntrySelected"] = anIsSelected;

	tEntry = sNativeBackdrops[aPanel];

	if not tEntry and aPanel.GetBackdropColor then
		tNativeR, tNativeG, tNativeB, tNativeA = aPanel:GetBackdropColor();
		tBorder = { tNativeR, tNativeG, tNativeB, tNativeA };
		tNativeR, tNativeG, tNativeB, tNativeA = aPanel:GetBackdropBorderColor();
		tEntry = {
			["bg"] = tBorder,
			["border"] = { tNativeR, tNativeG, tNativeB, tNativeA },
		};
		sNativeBackdrops[aPanel] = tEntry;
	end

	if aPanel["backdropInfo"] and aPanel.ApplyBackdrop then
		aPanel:ApplyBackdrop(aPanel["backdropInfo"]);
	end

	tColors = VUHDO_lnfSkinGetActiveEntry()["backdropColors"];

	if tColors and tColors["panel"] then
		tBg = tColors["panel"]["bg"];
		tBorder = tColors["panel"]["border"];

		if anIsSelected then
			tBg = VUHDO_lnfSkinGetActiveEntry()["entrySelectColor"] or VUHDO_lnfSkinGetActiveEntry()["accentColor"] or tBg;
		end

		if tBg then
			aPanel:SetBackdropColor(tBg[1], tBg[2], tBg[3], tBg[4] or 1);
		end

		if tBorder then
			aPanel:SetBackdropBorderColor(tBorder[1], tBorder[2], tBorder[3], tBorder[4] or 1);
		end
	else
		if anIsSelected then
			aPanel:SetBackdropColor(0.8, 0.8, 1, 1);
		else
			aPanel:SetBackdropColor(1, 1, 1, 1);
		end

		if tEntry and tEntry["border"] then
			tBorder = tEntry["border"];
			aPanel:SetBackdropBorderColor(tBorder[1], tBorder[2], tBorder[3], tBorder[4] or 1);
		end
	end

	return;

end



--
function VUHDO_lnfSkinGetFontColor(aRole)

	if VUHDO_lnfSkinGetActiveEntry()["fontColors"] and VUHDO_lnfSkinGetActiveEntry()["fontColors"][aRole] then
		return VUHDO_lnfSkinGetActiveEntry()["fontColors"][aRole]["TR"], VUHDO_lnfSkinGetActiveEntry()["fontColors"][aRole]["TG"], VUHDO_lnfSkinGetActiveEntry()["fontColors"][aRole]["TB"], VUHDO_lnfSkinGetActiveEntry()["fontColors"][aRole]["TO"] or 1;
	end

	return;

end



--
local tTextures;
function VUHDO_lnfSkinResolveTexture(aKey)

	tTextures = VUHDO_lnfSkinGetActiveEntry()["textures"];

	if tTextures and tTextures[aKey] then
		return tTextures[aKey];
	end

	return sDefaultTextures[aKey];

end



do

	--
	local tTints;
	function VUHDO_lnfSkinResolveTint(aKey)

		tTints = VUHDO_lnfSkinGetActiveEntry()["textureTints"];

		if tTints and tTints[aKey] then
			return tTints[aKey];
		end

		return nil;

	end

end



--
local tEntry;
local tNativeR;
local tNativeG;
local tNativeB;
local tNativeA;
local function VUHDO_lnfSkinSnapshotTexture(aTexture)

	if not aTexture then
		return nil;
	end

	tEntry = sNativeTextures[aTexture];

	if tEntry then
		return tEntry;
	end

	tNativeR, tNativeG, tNativeB, tNativeA = aTexture:GetVertexColor();

	tEntry = {
		["path"] = aTexture:GetTexture(),
		["r"] = tNativeR,
		["g"] = tNativeG,
		["b"] = tNativeB,
		["a"] = tNativeA,
	};

	sNativeTextures[aTexture] = tEntry;

	return tEntry;

end



--
local tSkinTextures;
local tSkinTints;
local function VUHDO_lnfSkinResolveTextureOrNative(aKey, aNativePath)

	tSkinTextures = VUHDO_lnfSkinGetActiveEntry()["textures"];

	if tSkinTextures and tSkinTextures[aKey] then
		return tSkinTextures[aKey];
	end

	return aNativePath;

end



--
local function VUHDO_lnfSkinStyleTexture(aTexture)

	if not aTexture then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotTexture(aTexture);

	if not tEntry then
		return;
	end

	tKey = VUHDO_lnfSkinBasenameFromPath(tEntry["path"]);
	tPath = VUHDO_lnfSkinResolveTextureOrNative(tKey, tEntry["path"]);

	if tPath then
		aTexture:SetTexture(tPath);
	end

	tSkinTints = VUHDO_lnfSkinGetActiveEntry()["textureTints"];

	if tSkinTints and tKey and tSkinTints[tKey] then
		aTexture:SetVertexColor(tSkinTints[tKey][1], tSkinTints[tKey][2], tSkinTints[tKey][3], tSkinTints[tKey][4] or 1);
	else
		aTexture:SetVertexColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
	end

	return;

end



--
local function VUHDO_lnfSkinStyleTextureKeyed(aTexture, aKey)

	if not aTexture then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotTexture(aTexture);

	if not tEntry then
		return;
	end

	tSkinTextures = VUHDO_lnfSkinGetActiveEntry()["textures"];

	if tSkinTextures and aKey and tSkinTextures[aKey] then
		aTexture:SetTexture(tSkinTextures[aKey]);
	else
		aTexture:SetTexture(tEntry["path"]);
	end

	tSkinTints = VUHDO_lnfSkinGetActiveEntry()["textureTints"];

	if tSkinTints and aKey and tSkinTints[aKey] then
		aTexture:SetVertexColor(tSkinTints[aKey][1], tSkinTints[aKey][2], tSkinTints[aKey][3], tSkinTints[aKey][4] or 1);
	else
		aTexture:SetVertexColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
	end

	return;

end



--
local function VUHDO_lnfSkinStyleTexturePathKeyed(aTexture, aKey)

	if not aTexture then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotTexture(aTexture);

	if not tEntry then
		return;
	end

	tSkinTextures = VUHDO_lnfSkinGetActiveEntry()["textures"];

	if tSkinTextures and aKey and tSkinTextures[aKey] then
		aTexture:SetTexture(tSkinTextures[aKey]);
	else
		aTexture:SetTexture(tEntry["path"]);
	end

	return;

end



--
local tTint;
local function VUHDO_lnfSkinApplyTint(aTexture, aKey)

	if not aTexture then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotTexture(aTexture);

	if not tEntry then
		return;
	end

	tTint = VUHDO_lnfSkinGetActiveEntry()["textureTints"];

	if tTint and aKey and tTint[aKey] then
		aTexture:SetVertexColor(tTint[aKey][1], tTint[aKey][2], tTint[aKey][3], tTint[aKey][4]);
	else
		aTexture:SetVertexColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
	end

	return;

end



--
local function VUHDO_lnfSkinSetTextureByKey(aTexture, aKey)

	if not aTexture or not aKey then
		return;
	end

	tPath = VUHDO_lnfSkinResolveTexture(aKey);

	if tPath then
		aTexture:SetTexture(tPath);
	end

	VUHDO_lnfSkinApplyTint(aTexture, aKey);

	return;

end



--
local tResolved;
local function VUHDO_lnfSkinSetTextureFromPath(aTexture, aPath)

	if not aTexture or not aPath then
		return;
	end

	VUHDO_lnfSkinStyleTexture(aTexture);

	return;

end



--
local tNative;
local function VUHDO_lnfSkinSnapshotBackdrop(aFrame)

	if not aFrame or not aFrame.GetBackdropColor then
		return nil;
	end

	tEntry = sNativeBackdrops[aFrame];

	if tEntry then
		return tEntry;
	end

	tNativeR, tNativeG, tNativeB, tNativeA = aFrame:GetBackdropColor();
	tNative = { tNativeR, tNativeG, tNativeB, tNativeA };

	tEntry = {
		["bg"] = tNative,
	};

	tNativeR, tNativeG, tNativeB, tNativeA = aFrame:GetBackdropBorderColor();
	tNative = { tNativeR, tNativeG, tNativeB, tNativeA };

	tEntry["border"] = tNative;

	sNativeBackdrops[aFrame] = tEntry;

	return tEntry;

end



--
local tSkinFontColor;
local function VUHDO_lnfSkinSnapshotFontString(aRegion)

	if not aRegion or not aRegion.GetTextColor then
		return nil;
	end

	tEntry = sNativeFontStrings[aRegion];

	if tEntry then
		return tEntry;
	end

	tNativeR, tNativeG, tNativeB, tNativeA = aRegion:GetTextColor();

	tEntry = {
		["r"] = tNativeR,
		["g"] = tNativeG,
		["b"] = tNativeB,
		["a"] = tNativeA,
	};

	if aRegion.GetFont then
		tEntry["fontPath"], tEntry["fontSize"], tEntry["fontFlags"] = aRegion:GetFont();
	end

	sNativeFontStrings[aRegion] = tEntry;

	return tEntry;

end



--
local function VUHDO_lnfSkinStyleFontFace(aRegion)

	if not aRegion or not aRegion.SetFont then
		return;
	end

	if GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR" then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotFontString(aRegion);

	if not tEntry or not tEntry["fontSize"] then
		return;
	end

	tPath = VUHDO_lnfSkinGetActiveEntry()["font"];

	if tPath then
		aRegion:SetFont(tPath, tEntry["fontSize"], tEntry["fontFlags"] or "");
	else
		aRegion:SetFont(tEntry["fontPath"], tEntry["fontSize"], tEntry["fontFlags"] or "");
	end

	return;

end



--
local function VUHDO_lnfSkinStyleFontString(aRegion, aRole)

	if not aRegion or not aRegion.SetTextColor then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotFontString(aRegion);

	if not tEntry then
		return;
	end

	tSkinFontColor = VUHDO_lnfSkinGetActiveEntry()["fontColors"];

	if tSkinFontColor and tSkinFontColor[aRole] then
		aRegion:SetTextColor(
			tSkinFontColor[aRole]["TR"] or tEntry["r"],
			tSkinFontColor[aRole]["TG"] or tEntry["g"],
			tSkinFontColor[aRole]["TB"] or tEntry["b"],
			tSkinFontColor[aRole]["TO"] or tEntry["a"]
		);
	else
		aRegion:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
	end

	VUHDO_lnfSkinStyleFontFace(aRegion);

	return;

end



--
local tTabNative;
local tGlyph;
local function VUHDO_lnfSkinSnapshotTab(aButton)

	if not aButton then
		return nil;
	end

	tEntry = sNativeTabState[aButton];

	if tEntry then
		return tEntry;
	end

	tName = aButton:GetName();
	tEntry = { };

	tNormal = aButton:GetNormalTexture();

	if tNormal then
		tEntry["normalAlpha"] = tNormal:GetAlpha();
	end

	tPushed = aButton:GetPushedTexture();

	if tPushed then
		tEntry["pushedAlpha"] = tPushed:GetAlpha();
	end

	if tName then
		tTabNative = _G[tName .. "TextureSwatch"];

		if tTabNative then
			tEntry["swatchAlpha"] = tTabNative:GetAlpha();
		end

		tTabNative = _G[tName .. "TextureActiveSwatch"];

		if tTabNative then
			tEntry["activeSwatchAlpha"] = tTabNative:GetAlpha();
		end

		tGlyph = _G[tName .. "Glyph"];

		if tGlyph then
			tEntry["glyphShown"] = tGlyph:IsShown();
			tEntry["glyphR"], tEntry["glyphG"], tEntry["glyphB"], tEntry["glyphA"] = tGlyph:GetVertexColor();
		end

		tTabNative = _G[tName .. "TextureCheckMarkTexture"];

		if tTabNative then
			tEntry["checkMarkTexAlpha"] = tTabNative:GetAlpha();
		end
	end

	sNativeTabState[aButton] = tEntry;

	return tEntry;

end



--
local tPoint;
local tRelativeTo;
local tRelativePoint;
local tOffsetX;
local tOffsetY;
local tNumPoints;
local function VUHDO_lnfSkinSnapshotSlider(aSlider)

	if not aSlider then
		return nil;
	end

	tEntry = sNativeSliderState[aSlider];

	if tEntry then
		return tEntry;
	end

	tEntry = {
		["points"] = { },
		["width"] = aSlider:GetWidth(),
		["height"] = aSlider:GetHeight(),
	};

	tNumPoints = aSlider:GetNumPoints();

	for tIdx = 1, tNumPoints do
		tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY = aSlider:GetPoint(tIdx);
		tinsert(tEntry["points"], { tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY });
	end

	sNativeSliderState[aSlider] = tEntry;

	return tEntry;

end



--
local tSliderPoints;
local function VUHDO_lnfSkinRestoreSliderAnchors(aSlider)

	tSliderPoints = VUHDO_lnfSkinSnapshotSlider(aSlider);

	if not tSliderPoints or not tSliderPoints["points"] then
		return;
	end

	if #tSliderPoints["points"] == 0 then
		tParent = aSlider:GetParent();

		if tParent then
			aSlider:SetAllPoints(tParent);
		end

		if tSliderPoints["width"] and tSliderPoints["height"] then
			VUHDO_PixelUtil.SetWidth(aSlider, tSliderPoints["width"]);
			VUHDO_PixelUtil.SetHeight(aSlider, tSliderPoints["height"]);
		end

		return;
	end

	aSlider:ClearAllPoints();

	for tIdx = 1, #tSliderPoints["points"] do
		tPoint = tSliderPoints["points"][tIdx][1];
		tRelativeTo = tSliderPoints["points"][tIdx][2];
		tRelativePoint = tSliderPoints["points"][tIdx][3];
		tOffsetX = tSliderPoints["points"][tIdx][4];
		tOffsetY = tSliderPoints["points"][tIdx][5];

		VUHDO_PixelUtil.SetPoint(aSlider, tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY);
	end

	if tSliderPoints["width"] and tSliderPoints["height"] then
		VUHDO_PixelUtil.SetWidth(aSlider, tSliderPoints["width"]);
		VUHDO_PixelUtil.SetHeight(aSlider, tSliderPoints["height"]);
	end

	return;

end



--
local function VUHDO_lnfSkinSnapshotSliderLabel(aLabel)

	if not aLabel then
		return nil;
	end

	tEntry = sNativeSliderLabelState[aLabel];

	if tEntry then
		return tEntry;
	end

	tEntry = {
		["points"] = { },
	};

	tNumPoints = aLabel:GetNumPoints();

	for tIdx = 1, tNumPoints do
		tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY = aLabel:GetPoint(tIdx);
		tinsert(tEntry["points"], { tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY });
	end

	sNativeSliderLabelState[aLabel] = tEntry;

	return tEntry;

end



--
local function VUHDO_lnfSkinRestoreSliderLabelAnchors(aLabel)

	tSliderPoints = VUHDO_lnfSkinSnapshotSliderLabel(aLabel);

	if not tSliderPoints or not tSliderPoints["points"] then
		return;
	end

	aLabel:ClearAllPoints();

	for tIdx = 1, #tSliderPoints["points"] do
		tPoint = tSliderPoints["points"][tIdx][1];
		tRelativeTo = tSliderPoints["points"][tIdx][2];
		tRelativePoint = tSliderPoints["points"][tIdx][3];
		tOffsetX = tSliderPoints["points"][tIdx][4];
		tOffsetY = tSliderPoints["points"][tIdx][5];

		VUHDO_PixelUtil.SetPoint(aLabel, tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY);
	end

	return;

end



--
local tArrowEntry;
local tArrowNormal;
local tCoords;
local function VUHDO_lnfSkinSnapshotSliderArrow(aButton)

	if not aButton then
		return nil;
	end

	tArrowEntry = sNativeSliderArrowState[aButton];

	if tArrowEntry then
		return tArrowEntry;
	end

	tArrowNormal = aButton:GetNormalTexture();

	if not tArrowNormal then
		return nil;
	end

	tCoords = { tArrowNormal:GetTexCoord() };

	tArrowEntry = {
		["coords"] = tCoords,
	};

	sNativeSliderArrowState[aButton] = tArrowEntry;

	return tArrowEntry;

end



--
local function VUHDO_lnfSkinRestoreSliderArrowTexCoord(aButton)

	tArrowEntry = VUHDO_lnfSkinSnapshotSliderArrow(aButton);

	if not tArrowEntry or not tArrowEntry["coords"] then
		return;
	end

	tArrowNormal = aButton:GetNormalTexture();

	if not tArrowNormal then
		return;
	end

	tArrowNormal:SetTexCoord(unpack(tArrowEntry["coords"]));

	return;

end



--
local function VUHDO_lnfSkinApplySliderArrowTexCoord(aButton, anIsVertical, anIsIncrease)

	tArrowNormal = aButton:GetNormalTexture();

	if not tArrowNormal then
		return;
	end

	if anIsVertical then
		if anIsIncrease then
			tArrowNormal:SetTexCoord(0.25, 0.75, 0.75, 0.75, 0.25, 0.25, 0.75, 0.25);
		else
			tArrowNormal:SetTexCoord(0.75, 0.25, 0.25, 0.25, 0.75, 0.75, 0.25, 0.75);
		end
	else
		if anIsIncrease then
			tArrowNormal:SetTexCoord(0.75, 0.25, 0.25, 0.75);
		else
			tArrowNormal:SetTexCoord(0.25, 0.75, 0.25, 0.75);
		end
	end

	return;

end



--
local tBackdrop;
local tOriginal;
local tColors;
function VUHDO_lnfSkinSnapshotBackdrops()

	if sBackdropsSnapshotted then
		return;
	end

	for tBackdropName, _ in pairs(sBackdropGlobals) do
		tBackdrop = _G[tBackdropName];

		if tBackdrop then
			sOriginalBackdropFiles[tBackdropName] = {
				["bgFile"] = tBackdrop["bgFile"],
				["edgeFile"] = tBackdrop["edgeFile"],
			};
		end
	end

	sBackdropsSnapshotted = true;

	return;

end



--
local tBgKey;
local tEdgeKey;
function VUHDO_lnfSkinRewriteBackdrops()

	VUHDO_lnfSkinSnapshotBackdrops();

	for tBackdropName, tColorKey in pairs(sBackdropGlobals) do
		tBackdrop = _G[tBackdropName];
		tOriginal = sOriginalBackdropFiles[tBackdropName];

		if tBackdrop and tOriginal then
			tBgKey = VUHDO_lnfSkinBasenameFromPath(tOriginal["bgFile"]);
			tEdgeKey = VUHDO_lnfSkinBasenameFromPath(tOriginal["edgeFile"]);

			if sSliderBackdropNames[tBackdropName] and (VUHDO_lnfSkinGetActiveEntry()["sliderStyle"] or "classic") == "arrows" then
				tBackdrop["bgFile"] = sSliderBackdropWhiteFill;
			elseif tBgKey and sBackdropFileKeys[tBgKey] then
				tPath = VUHDO_lnfSkinResolveTexture(tBgKey);

				if tPath then
					tBackdrop["bgFile"] = tPath;
				else
					tBackdrop["bgFile"] = tOriginal["bgFile"];
				end
			end

			if tEdgeKey and sBackdropFileKeys[tEdgeKey] then
				tPath = VUHDO_lnfSkinResolveTexture(tEdgeKey);

				if tPath then
					tBackdrop["edgeFile"] = tPath;
				else
					tBackdrop["edgeFile"] = tOriginal["edgeFile"];
				end
			end
		end
	end

	return;

end



--
local tBg;
local tBorder;
local function VUHDO_lnfSkinApplyBackdropColors(aFrame, aColorKey)

	if not aFrame or not aFrame.SetBackdropColor then
		return;
	end

	tEntry = VUHDO_lnfSkinSnapshotBackdrop(aFrame);

	if not tEntry then
		return;
	end

	tBg = tEntry["bg"];
	tBorder = tEntry["border"];

	tColors = VUHDO_lnfSkinGetActiveEntry()["backdropColors"];

	if tColors and tColors[aColorKey] then
		if tColors[aColorKey]["bg"] then
			tBg = tColors[aColorKey]["bg"];
		end

		if tColors[aColorKey]["border"] then
			tBorder = tColors[aColorKey]["border"];
		end
	end

	if tBg then
		aFrame:SetBackdropColor(tBg[1], tBg[2], tBg[3], tBg[4] or 1);
	end

	if tBorder then
		aFrame:SetBackdropBorderColor(tBorder[1], tBorder[2], tBorder[3], tBorder[4] or 1);
	end

	return;

end



--
local tBackdropInfo;
local function VUHDO_lnfSkinApplyFrameBackdrop(aFrame)

	if not aFrame or not aFrame.ApplyBackdrop then
		return;
	end

	tBackdropInfo = aFrame["backdropInfo"];

	if not tBackdropInfo then
		return;
	end

	for tBackdropName, tColorKey in pairs(sBackdropGlobals) do
		if tBackdropInfo == _G[tBackdropName] then
			aFrame:ApplyBackdrop(tBackdropInfo);
			VUHDO_lnfSkinApplyBackdropColors(aFrame, tColorKey);

			return;
		end
	end

	for tBackdropName, tColorKey in pairs(sBackdropGlobals) do
		tBackdrop = _G[tBackdropName];
		tOriginal = sOriginalBackdropFiles[tBackdropName];

		if tBackdrop and (
			(tOriginal and tBackdropInfo["bgFile"] == tOriginal["bgFile"] and tBackdropInfo["edgeFile"] == tOriginal["edgeFile"])
			or (tBackdropInfo["bgFile"] == tBackdrop["bgFile"] and tBackdropInfo["edgeFile"] == tBackdrop["edgeFile"])
		) then
			aFrame["backdropInfo"] = tBackdrop;
			aFrame:ApplyBackdrop(tBackdrop);
			VUHDO_lnfSkinApplyBackdropColors(aFrame, tColorKey);

			return;
		end
	end

	return;

end



--
local function VUHDO_lnfSkinApplyComponentIcon(aButton)

	tName = aButton:GetName();

	tKey = aButton["skinIconKey"];

	if not tKey and tName then
		if strfind(tName, "OkayButton", 1, true) then
			tKey = "icon_okay";
		elseif strfind(tName, "CancelButton", 1, true) then
			tKey = "icon_cancel";
		elseif strfind(tName, "ApplyToAllButton", 1, true) or strfind(tName, "ApplyButton", 1, true) then
			tKey = "icon_apply_all";
		elseif strfind(tName, "BackButton", 1, true) then
			tKey = "icon_back";
		end
	end

	if tKey and tName and _G[tName .. "Icon"] then
		VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "Icon"], tKey);

		return;
	end

	for _, tRegion in ipairs({ aButton:GetRegions() }) do
		if tRegion:GetObjectType() == "Texture" then
			tEntry = VUHDO_lnfSkinSnapshotTexture(tRegion);

			if tEntry and string.lower(tostring(VUHDO_lnfSkinBasenameFromPath(tEntry["path"]))) == "font" then
				VUHDO_lnfSkinStyleTextureKeyed(tRegion, "icon_font");
			end
		end
	end

	return;

end



--
local tNormal;
local tPushed;
local tDisabled;
local function VUHDO_lnfSkinApplyButtonTextures(aButton)

	if not aButton then
		return;
	end

	tNormal = aButton:GetNormalTexture();

	if tNormal then
		VUHDO_lnfSkinStyleTextureKeyed(tNormal, aButton["skinNormalKey"] or "button_normal_128_32");
		tNormal:SetAlpha((aButton["skinBadgeOnly"] and VUHDO_lnfSkinGetActiveEntry()["badgeOnlyButtons"]) and 0 or 1);
	end

	tPushed = aButton:GetPushedTexture();

	if tPushed then
		VUHDO_lnfSkinStyleTextureKeyed(tPushed, "button_pressed_128_32");
		tPushed:SetAlpha((aButton["skinBadgeOnly"] and VUHDO_lnfSkinGetActiveEntry()["badgeOnlyButtons"]) and 0 or 1);
	end

	tDisabled = aButton:GetDisabledTexture();

	if tDisabled then
		VUHDO_lnfSkinStyleTextureKeyed(tDisabled, "button_pressed_128_32");
		tDisabled:SetAlpha((aButton["skinBadgeOnly"] and VUHDO_lnfSkinGetActiveEntry()["badgeOnlyButtons"]) and 0 or 1);
	end

	VUHDO_lnfSkinApplyComponentIcon(aButton);

	return;

end



--
local function VUHDO_lnfSkinIsTriState(aButton)

	if not aButton or not aButton:GetName() then
		return false;
	end

	return _G[aButton:GetName() .. "TextureSwatch1"] ~= nil;

end



--
local function VUHDO_lnfSkinIsRadio(aButton)

	if not aButton or not aButton:GetName() then
		return false;
	end

	tName = aButton:GetName();

	return strfind(tName, "Radio", 1, true) ~= nil;

end



--
local tSwatchFrame;
local tCheckTex;
local function VUHDO_lnfSkinSnapshotTriState(aButton)

	if not aButton then
		return nil;
	end

	tEntry = sNativeTriStateState[aButton];

	if tEntry then
		return tEntry;
	end

	tName = aButton:GetName();
	tEntry = { };

	tNormal = aButton:GetNormalTexture();

	if tNormal then
		tEntry["normalAlpha"] = tNormal:GetAlpha();
	end

	tPushed = aButton:GetPushedTexture();

	if tPushed then
		tEntry["pushedAlpha"] = tPushed:GetAlpha();
	end

	if tName then
		tSwatchFrame = _G[tName .. "TextureSwatch1"];

		if tSwatchFrame then
			tEntry["swatch1Alpha"] = tSwatchFrame:GetAlpha();
		end

		tSwatchFrame = _G[tName .. "TextureSwatch2"];

		if tSwatchFrame then
			tEntry["swatch2Alpha"] = tSwatchFrame:GetAlpha();
		end

		tSwatchFrame = _G[tName .. "TextureSwatch3"];

		if tSwatchFrame then
			tEntry["swatch3Alpha"] = tSwatchFrame:GetAlpha();
		end

		tCheckTex = _G[tName .. "TextureCheckMarkTexture"];

		if tCheckTex then
			tEntry["checkTexPath"] = tCheckTex:GetTexture();
		end

		tSwatchFrame = _G[tName .. "TextureCheckMark"];

		if tSwatchFrame then
			tEntry["checkWidth"], tEntry["checkHeight"] = tSwatchFrame:GetSize();
		end
	end

	sNativeTriStateState[aButton] = tEntry;

	return tEntry;

end



--
local tTriValueColors;
local tTriValueColor;
local tTriValue;
local tTriLabel;
local function VUHDO_lnfSkinApplyTriStateValueColor(aButton)

	if not aButton or not aButton:GetName() then
		return;
	end

	tTriValueColors = VUHDO_lnfSkinGetActiveEntry()["triStateValueColors"];

	if not tTriValueColors then
		return;
	end

	tTriLabel = _G[aButton:GetName() .. "Label2"];

	if not tTriLabel then
		return;
	end

	tTriValue = VUHDO_lnfGetValueFromModel(aButton) or 2;
	tTriValueColor = tTriValueColors[tTriValue];

	if tTriValueColor then
		tTriLabel:SetTextColor(tTriValueColor[1], tTriValueColor[2], tTriValueColor[3], tTriValueColor[4] or 1);
	end

	return;

end



--
local tTriEntry;
local function VUHDO_lnfSkinApplyTriStateDot(aButton)

	if not aButton then
		return;
	end

	tName = aButton:GetName();

	if not tName then
		return;
	end

	tTriEntry = VUHDO_lnfSkinSnapshotTriState(aButton);

	if (VUHDO_lnfSkinGetActiveEntry()["toggleStyle"] or "box") == "dot" then
		tNormal = aButton:GetNormalTexture();

		if tNormal then
			tNormal:SetAlpha(0);
		end

		tPushed = aButton:GetPushedTexture();

		if tPushed then
			tPushed:SetAlpha(0);
		end

		tSwatchFrame = _G[tName .. "TextureSwatch1"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(0);
		end

		tSwatchFrame = _G[tName .. "TextureSwatch2"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(0);
		end

		tSwatchFrame = _G[tName .. "TextureSwatch3"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(0);
		end

		tCheckTex = _G[tName .. "TextureCheckMarkTexture"];

		if tCheckTex then
			VUHDO_lnfSkinStyleTexturePathKeyed(tCheckTex, "status_dot");
		end

		tSwatchFrame = _G[tName .. "TextureCheckMark"];

		if tSwatchFrame then
			VUHDO_PixelUtil.SetSize(tSwatchFrame, 16, 16);
			tSwatchFrame:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(tSwatchFrame, "LEFT", tName, "LEFT", 5, 0);
		end
	else
		tNormal = aButton:GetNormalTexture();

		if tNormal then
			tNormal:SetAlpha(tTriEntry and tTriEntry["normalAlpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_normal_128_32");
		end

		tPushed = aButton:GetPushedTexture();

		if tPushed then
			tPushed:SetAlpha(tTriEntry and tTriEntry["pushedAlpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(tPushed, "button_pressed_128_32");
		end

		tSwatchFrame = _G[tName .. "TextureSwatch1"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(tTriEntry and tTriEntry["swatch1Alpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureSwatch1Texture"], "icon_black");
		end

		tSwatchFrame = _G[tName .. "TextureSwatch2"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(tTriEntry and tTriEntry["swatch2Alpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureSwatch2Texture"], "icon_black");
		end

		tSwatchFrame = _G[tName .. "TextureSwatch3"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(tTriEntry and tTriEntry["swatch3Alpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureSwatch3Texture"], "icon_black");
		end

		tCheckTex = _G[tName .. "TextureCheckMarkTexture"];

		if tCheckTex and tTriEntry and tTriEntry["checkTexPath"] then
			tCheckTex:SetTexture(tTriEntry["checkTexPath"]);
		end

		tSwatchFrame = _G[tName .. "TextureCheckMark"];

		if tSwatchFrame and tTriEntry and tTriEntry["checkWidth"] then
			VUHDO_PixelUtil.SetSize(tSwatchFrame, tTriEntry["checkWidth"], tTriEntry["checkHeight"]);
		end

		VUHDO_lnfTriStateCheckButtonInitFromModel(aButton);
	end

	VUHDO_lnfSkinApplyTriStateValueColor(aButton);

	return;

end



--
local function VUHDO_lnfSkinOnTriStateCheckButtonUpdateModel(aCheckButton)

	if (VUHDO_lnfSkinGetActiveEntry()["toggleStyle"] or "box") == "dot" then
		VUHDO_lnfSkinApplyTriStateDot(aCheckButton);
	else
		VUHDO_lnfSkinApplyTriStateValueColor(aCheckButton);
	end

	return;

end



--
local tParent;
local tParentName;
local function VUHDO_lnfSkinIsComboBody(aFrame)

	if not aFrame then
		return false;
	end

	tName = aFrame:GetName();

	if not tName then
		return false;
	end

	return _G[tName .. "Middle"] ~= nil and _G[tName .. "Button"] ~= nil;

end



--
local function VUHDO_lnfSkinIsComboArrow(aButton)

	if not aButton then
		return false;
	end

	tName = aButton:GetName();
	tParent = aButton:GetParent();

	if not tName or not tParent then
		return false;
	end

	tParentName = tParent:GetName();

	if not tParentName then
		return false;
	end

	return tName == tParentName .. "Button" and VUHDO_lnfSkinIsComboBody(tParent);

end



--
local tLeft;
local tMiddle;
local tRight;
local tArrow;
local function VUHDO_lnfSkinApplyComboTextures(aFrame)

	if not aFrame then
		return;
	end

	tName = aFrame:GetName();

	if not tName then
		return;
	end

	tLeft = _G[tName .. "Left"];
	tMiddle = _G[tName .. "Middle"];
	tRight = _G[tName .. "Right"];
	tArrow = _G[tName .. "Button"];

	if tLeft then
		VUHDO_lnfSkinStyleTextureKeyed(tLeft, "button_normal_128_32");
	end

	if tMiddle then
		VUHDO_lnfSkinStyleTextureKeyed(tMiddle, "button_normal_128_32");
	end

	if tRight then
		VUHDO_lnfSkinStyleTextureKeyed(tRight, "button_normal_128_32");
	end

	if tArrow then
		tNormal = tArrow:GetNormalTexture();

		if tNormal then
			VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_combo_32_32");
		end

		tPushed = tArrow:GetPushedTexture();

		if tPushed then
			VUHDO_lnfSkinStyleTextureKeyed(tPushed, "button_combo_pressed_32_32");
		end
	end

	return;

end



--
function VUHDO_lnfSkinStyleComboItemCheck(aComboItem)

	if not sSkinReady or not aComboItem then
		return;
	end

	if (aComboItem["parentCombo"] or sEmpty)["isMulti"] then
		return;
	end

	tName = aComboItem:GetName();

	if not tName then
		return;
	end

	tRegion = _G[tName .. "CheckTextureTexture"];

	if tRegion then
		VUHDO_lnfSkinStyleTextureKeyed(tRegion, "combo_select_dot");
	end

	return;

end



--
local tComboParent;
local function VUHDO_lnfSkinApplyComboItemBackdrop(aComboItem)

	if not aComboItem or not aComboItem.SetBackdropColor then
		return;
	end

	tComboParent = aComboItem["parentCombo"];

	if not tComboParent then
		return;
	end

	VUHDO_lnfSkinSnapshotBackdrop(aComboItem);

	VUHDO_lnfSkinStyleComboItemCheck(aComboItem);

	if tComboParent["isScrollable"] then
		aComboItem:SetBackdropColor(0, 0, 0, 0);

		return;
	end

	tComboItemColors = VUHDO_lnfSkinGetActiveEntry()["comboItemColors"];
	tComboItemColor = tComboItemColors and tComboItemColors["normal"];

	if tComboItemColor then
		aComboItem:SetBackdropColor(tComboItemColor[1], tComboItemColor[2], tComboItemColor[3], tComboItemColor[4] or 1);
	else
		tEntry = VUHDO_lnfSkinSnapshotBackdrop(aComboItem);

		if tEntry and tEntry["bg"] then
			aComboItem:SetBackdropColor(tEntry["bg"][1], tEntry["bg"][2], tEntry["bg"][3], tEntry["bg"][4] or 1);
		end
	end

	return;

end



--
local tComboName;
local function VUHDO_lnfSkinOnComboInitItems(aComboBox)

	if not sSkinReady then
		return;
	end

	tComboName = aComboBox and aComboBox:GetName();

	if not tComboName then
		return;
	end

	if aComboBox["isScrollable"] then
		VUHDO_lnfSkinApplyToFrameTree(_G[tComboName .. "ScrollPanel"]);
	else
		VUHDO_lnfSkinApplyToFrameTree(_G[tComboName .. "SelectPanel"]);
	end

	return;

end



--
local tComboItemColors;
local tComboItemColor;
local function VUHDO_lnfSkinOnComboItemOnEnter(aComboItem)

	if not sSkinReady or not aComboItem then
		return;
	end

	tComboItemColors = VUHDO_lnfSkinGetActiveEntry()["comboItemColors"];
	tComboItemColor = tComboItemColors and tComboItemColors["hover"];

	if not tComboItemColor then
		return;
	end

	aComboItem:SetBackdropColor(tComboItemColor[1], tComboItemColor[2], tComboItemColor[3], tComboItemColor[4] or 1);

	return;

end



--
local function VUHDO_lnfSkinOnComboItemOnLeave(aComboItem)

	if not sSkinReady or not aComboItem then
		return;
	end

	tComboItemColors = VUHDO_lnfSkinGetActiveEntry()["comboItemColors"];
	tComboItemColor = tComboItemColors and tComboItemColors["normal"];

	if not tComboItemColor then
		return;
	end

	if (aComboItem["parentCombo"] or sEmpty)["isScrollable"] then
		return;
	end

	aComboItem:SetBackdropColor(tComboItemColor[1], tComboItemColor[2], tComboItemColor[3], tComboItemColor[4] or 1);

	return;

end



do

	--
	local tCheckTreeBackdrop;
	function VUHDO_lnfSkinApplyCheckTreeRowBackdrop(aRow)

		if not sSkinReady or not aRow then
			return;
		end

		tCheckTreeBackdrop = _G[aRow:GetName() .. "Backdrop"];

		if not tCheckTreeBackdrop or not tCheckTreeBackdrop.SetBackdropColor then
			return;
		end

		VUHDO_lnfSkinSnapshotBackdrop(tCheckTreeBackdrop);
		tCheckTreeBackdrop:SetBackdropColor(0, 0, 0, 0);

		return;

	end



	--
	function VUHDO_lnfSkinOnCheckTreeRowOnEnter(aRow)

		if not sSkinReady or not aRow then
			return;
		end

		tCheckTreeBackdrop = _G[aRow:GetName() .. "Backdrop"];

		if not tCheckTreeBackdrop then
			return;
		end

		tComboItemColors = VUHDO_lnfSkinGetActiveEntry()["comboItemColors"];
		tComboItemColor = tComboItemColors and tComboItemColors["hover"];

		if not tComboItemColor then
			return;
		end

		tCheckTreeBackdrop:SetBackdropColor(tComboItemColor[1], tComboItemColor[2], tComboItemColor[3], tComboItemColor[4] or 1);

		return;

	end



	--
	function VUHDO_lnfSkinOnCheckTreeRowOnLeave(aRow)

		return;

	end

end



--
function VUHDO_lnfSkinOnAuraGroupsRefresh()

	if not sSkinReady then
		return;
	end

	VUHDO_lnfSkinApplyToFrameTree(_G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelEntryScrollEntryScrollChild"]);

	return;

end



--
function VUHDO_lnfSkinOnBuffWatchRefresh()

	if not sSkinReady then
		return;
	end

	VUHDO_lnfSkinApplyToFrameTree(VuhDoNewOptionsBuffsGeneric);

	return;

end



--
function VUHDO_lnfSkinStyleMovePanelConfigIcons(aPanelNum)

	if not sSkinReady then
		return;
	end

	tName = "Vd" .. aPanelNum;

	VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "NewTxuTxu"], "icon_plus");
	VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "ClrTxuTxu"], "icon_cancel");

	tKey = 1;

	while VUHDO_getGroupOrderPanel(aPanelNum, tKey) do
		tParent = VUHDO_getGroupOrderPanel(aPanelNum, tKey);
		VUHDO_lnfSkinStyleTextureKeyed(_G[tParent:GetName() .. "RmvTxuTxu"], "icon_cancel");
		tName = tParent:GetName();
		VUHDO_lnfSkinStyleFontString(_G[tName .. "DrgLbl1Lbl"], "normal");
		VUHDO_lnfSkinStyleFontString(_G[tName .. "DrgLbl2Lbl"], "normal");
		VUHDO_lnfSkinStyleFontString(_G[tName .. "RmvLblLbl"], "normal");
		tKey = tKey + 1;
	end

	return;

end



--
local function VUHDO_lnfSkinOnSquareDemoOnShow(aFrame)

	if not aFrame then
		return;
	end

	aFrame["skinSquareDemo"] = true;

	if not sSkinReady then
		return;
	end

	tName = aFrame:GetName();

	if not tName then
		return;
	end

	VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "Texture"], "blue_dk_square_16_16");

	return;

end



--
local tComboBox;
local tSelectPanel;
local function VUHDO_lnfSkinOnComboButtonClicked(aButton)

	if not sSkinReady then
		return;
	end

	tComboBox = aButton and aButton:GetParent();

	if not tComboBox then
		return;
	end

	tComboName = tComboBox:GetName();

	if not tComboName then
		return;
	end

	tSelectPanel = _G[tComboName .. "ScrollPanel"] or _G[tComboName .. "SelectPanel"];

	if tSelectPanel and tSelectPanel:IsShown() then
		VUHDO_lnfSkinApplyToFrameTree(tSelectPanel);
	end

	return;

end



--
local tBorderKey;
local function VUHDO_lnfSkinSnapshotEditBox(aEditBox)

	if not aEditBox then
		return nil;
	end

	tEntry = sNativeEditBoxState[aEditBox];

	if tEntry then
		return tEntry;
	end

	tNativeR, tNativeG, tNativeB, tNativeA = aEditBox:GetTextColor();

	tEntry = {
		["r"] = tNativeR,
		["g"] = tNativeG,
		["b"] = tNativeB,
		["a"] = tNativeA,
	};

	sNativeEditBoxState[aEditBox] = tEntry;

	return tEntry;

end



--
local function VUHDO_lnfSkinApplyEditTextures(aEditBox)

	if not aEditBox then
		return;
	end

	tName = aEditBox:GetName();

	if not tName then
		return;
	end

	tBorderKey = _G[tName .. "Button"] and "button_combo_edit_128_32" or "input_border_1";

	tLeft = _G[tName .. "Left"];
	tMiddle = _G[tName .. "Middle"];
	tRight = _G[tName .. "Right"];
	tArrow = _G[tName .. "Button"];

	if tLeft then
		VUHDO_lnfSkinStyleTextureKeyed(tLeft, tBorderKey);
	end

	if tMiddle then
		VUHDO_lnfSkinStyleTextureKeyed(tMiddle, tBorderKey);
	end

	if tRight then
		VUHDO_lnfSkinStyleTextureKeyed(tRight, tBorderKey);
	end

	if tArrow then
		tNormal = tArrow:GetNormalTexture();

		if tNormal then
			VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_combo_32_32");
		end

		tPushed = tArrow:GetPushedTexture();

		if tPushed then
			VUHDO_lnfSkinStyleTextureKeyed(tPushed, "button_combo_pressed_32_32");
		end
	end

	tEntry = VUHDO_lnfSkinSnapshotEditBox(aEditBox);
	tSkinFontColor = VUHDO_lnfSkinGetActiveEntry()["fontColors"];

	if tSkinFontColor and tSkinFontColor["normal"] then
		aEditBox:SetTextColor(
			tSkinFontColor["normal"]["TR"] or tEntry["r"],
			tSkinFontColor["normal"]["TG"] or tEntry["g"],
			tSkinFontColor["normal"]["TB"] or tEntry["b"],
			tSkinFontColor["normal"]["TO"] or tEntry["a"]
		);
	else
		aEditBox:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
	end

	VUHDO_lnfSkinStyleFontFace(aEditBox);

	return;

end



--
local tThumb;
local function VUHDO_lnfSkinApplySliderThumb(aSlider, anIsVertical)

	if not aSlider then
		return;
	end

	tThumb = aSlider:GetThumbTexture();

	if not tThumb then
		return;
	end

	if anIsVertical then
		VUHDO_lnfSkinStyleTextureKeyed(tThumb, "slider_thumb_v");
	else
		VUHDO_lnfSkinStyleTextureKeyed(tThumb, "slider_thumb_h");
	end

	return;

end



--
local function VUHDO_lnfSkinSnapshotCheckFace(aButton)

	if not aButton then
		return nil;
	end

	tEntry = sNativeCheckFaceState[aButton];

	if tEntry then
		return tEntry;
	end

	tEntry = { };

	tNormal = aButton:GetNormalTexture();

	if tNormal then
		tEntry["normalAlpha"] = tNormal:GetAlpha();

		if not tEntry["normalAlpha"] or tEntry["normalAlpha"] <= 0 then
			tEntry["normalAlpha"] = 1;
		end
	end

	tPushed = aButton:GetPushedTexture();

	if tPushed then
		tEntry["pushedAlpha"] = tPushed:GetAlpha();

		if not tEntry["pushedAlpha"] or tEntry["pushedAlpha"] <= 0 then
			tEntry["pushedAlpha"] = 1;
		end
	end

	sNativeCheckFaceState[aButton] = tEntry;

	return tEntry;

end



--
local tSwatch;
local tActiveSwatch;
local tCheckMark;
local tRegion;
local tCheckFaceEntry;
--
function VUHDO_lnfSkinStyleColorSwatch(aFrame)

	if not sSkinReady or not aFrame then
		return;
	end

	tName = aFrame:GetName();

	if not tName or not _G[tName .. "Texture"] then
		return;
	end

	tRegion = _G[tName .. "Border"];

	if not tRegion then
		return;
	end

	if VUHDO_lnfSkinGetActiveEntry()["swatchBorderColor"] then
		VUHDO_PixelUtil.ApplyBackdrop(tRegion, { ["edgeFile"] = "Interface\\Buttons\\WHITE8X8", ["edgeSize"] = 2 }, true);
		tRegion:SetBackdropBorderColor(
			VUHDO_lnfSkinGetActiveEntry()["swatchBorderColor"][1],
			VUHDO_lnfSkinGetActiveEntry()["swatchBorderColor"][2],
			VUHDO_lnfSkinGetActiveEntry()["swatchBorderColor"][3],
			VUHDO_lnfSkinGetActiveEntry()["swatchBorderColor"][4] or 1
		);
		tRegion:Show();
	else
		tRegion:SetBackdrop(nil);
		tRegion:Hide();
	end

	return;

end



--
local function VUHDO_lnfSkinApplyCheckTextures(aButton)

	if not aButton then
		return;
	end

	tName = aButton:GetName();

	if not tName then
		return;
	end

	if aButton["tabPanel"] then
		return;
	end

	if VUHDO_lnfSkinIsRadio(aButton) then
		tNormal = aButton:GetNormalTexture();

		if tNormal then
			tCheckFaceEntry = VUHDO_lnfSkinSnapshotCheckFace(aButton);
			tPushed = aButton:GetPushedTexture();

			if VUHDO_lnfSkinGetActiveEntry()["checkFaceHidden"] then
				tBorder = VUHDO_lnfSkinGetActiveEntry()["checkGroupPlate"];

				if tBorder and tNormal then
					tNormal:SetAlpha(1);
					VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_normal_128_32");
					tNormal:SetVertexColor(tBorder[1], tBorder[2], tBorder[3], tBorder[4] or 1);

					if tPushed then
						tPushed:SetAlpha(0);
					end
				else
					tNormal:SetAlpha(0);

					if tPushed then
						tPushed:SetAlpha(0);
					end
				end
			else
				tNormal:SetAlpha(1);
				VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_normal_128_32");
				tNativeR, tNativeG, tNativeB = tNormal:GetVertexColor();
				tNormal:SetVertexColor(tNativeR, tNativeG, tNativeB, 1);

				if tPushed then
					tPushed:SetAlpha(1);
					VUHDO_lnfSkinStyleTextureKeyed(tPushed, "button_pressed_128_32");
					tNativeR, tNativeG, tNativeB = tPushed:GetVertexColor();
					tPushed:SetVertexColor(tNativeR, tNativeG, tNativeB, 1);
				end
			end
		end

		VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureSwatchTexture"], "icon_black");
		VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureActiveSwatchTexture"], "icon_aura");
		VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureCheckMarkTexture"], "icon_white");

		return;
	end

	tNormal = aButton:GetNormalTexture();

	if _G[tName .. "TextureCheckMark"] then
		tCheckFaceEntry = VUHDO_lnfSkinSnapshotCheckFace(aButton);
		tPushed = aButton:GetPushedTexture();

		if VUHDO_lnfSkinGetActiveEntry()["checkFaceHidden"] and not aButton["tabPanel"] then
			tBorder = VUHDO_lnfSkinGetActiveEntry()["checkGroupPlate"];

			if tBorder and tNormal then
				tNormal:SetAlpha(1);
				VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_normal_128_32");
				tNormal:SetVertexColor(tBorder[1], tBorder[2], tBorder[3], tBorder[4] or 1);

				if tPushed then
					tPushed:SetAlpha(0);
				end
			else
				if tNormal then
					tNormal:SetAlpha(0);
				end

				if tPushed then
					tPushed:SetAlpha(0);
				end
			end
		else
			if tNormal then
				tNormal:SetAlpha(1);
				VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_normal_128_32");
				tNativeR, tNativeG, tNativeB = tNormal:GetVertexColor();
				tNormal:SetVertexColor(tNativeR, tNativeG, tNativeB, 1);
			end

			if tPushed then
				tPushed:SetAlpha(1);
				VUHDO_lnfSkinStyleTextureKeyed(tPushed, "button_pressed_128_32");
				tNativeR, tNativeG, tNativeB = tPushed:GetVertexColor();
				tPushed:SetVertexColor(tNativeR, tNativeG, tNativeB, 1);
			end
		end

		tRegion = _G[tName .. "TextureCheckMarkTexture"];

		if tRegion then
			VUHDO_lnfSkinStyleTextureKeyed(tRegion, "icon_check");
		end
	else
		VUHDO_lnfSkinApplyButtonTextures(aButton);
	end

	tSwatch = _G[tName .. "TextureSwatchTexture"];

	if tSwatch then
		VUHDO_lnfSkinStyleTextureKeyed(tSwatch, "icon_blue_square");
	end

	tActiveSwatch = _G[tName .. "TextureActiveSwatchTexture"];

	if tActiveSwatch then
		VUHDO_lnfSkinStyleTextureKeyed(tActiveSwatch, "icon_blue_square");
	end

	tCheckMark = _G[tName .. "TextureCheckMarkTexture"];

	if tCheckMark then
		VUHDO_lnfSkinApplyTint(tCheckMark, "icon_check");
	end

	return;

end



--
local tRegions;
local tRegionName;
local function VUHDO_lnfSkinApplyFontColors(aFrame)

	if not aFrame then
		return;
	end

	tName = aFrame:GetName();

	if tName then
		tRegion = _G[tName .. "Label"];

		if tRegion then
			VUHDO_lnfSkinStyleFontString(tRegion, "normal");
		end

		tRegion = _G[tName .. "Label2"];

		if tRegion then
			VUHDO_lnfSkinStyleFontString(tRegion, "normal");
		end

		tRegion = _G[tName .. "Title"];

		if tRegion then
			VUHDO_lnfSkinStyleFontString(tRegion, "title");
		end

		tRegion = _G[tName .. "Value"];

		if tRegion then
			VUHDO_lnfSkinStyleFontString(tRegion, "value");
		end

		tRegion = _G[tName .. "Text"];

		if tRegion then
			VUHDO_lnfSkinStyleFontString(tRegion, "normal");
		end
	end

	if aFrame.GetFontString and aFrame:GetObjectType() == "Button" then
		tRegion = aFrame:GetFontString();

		if tRegion then
			VUHDO_lnfSkinStyleFontString(tRegion, "normal");
		end
	end

	tRegions = { aFrame:GetRegions() };

	for _, tRegion in ipairs(tRegions) do
		if tRegion.GetObjectType and tRegion:GetObjectType() == "FontString" then
			tRegionName = tRegion:GetName();

			if tRegionName and strfind(tRegionName, "Title", 1, true) then
				VUHDO_lnfSkinStyleFontString(tRegion, "title");
			elseif tRegionName and strfind(tRegionName, "Value", 1, true) then
				VUHDO_lnfSkinStyleFontString(tRegion, "value");
			elseif tRegionName and strfind(tRegionName, "Label", 1, true) then
				VUHDO_lnfSkinStyleFontString(tRegion, "normal");
			end
		end
	end

	return;

end



--
local tDecLeft;
local tDecRight;
local tSlider;
local tSliderStyle;
local tArrowColor;
local tIsVertical;
function VUHDO_lnfSkinDecorateSlider(aFrame)

	if not aFrame then
		return;
	end

	tName = aFrame:GetName();

	if not tName then
		return;
	end

	tDecLeft = _G[tName .. "DecLeft"];
	tDecRight = _G[tName .. "DecRight"];
	tSlider = _G[tName .. "Slider"];

	if not tSlider then
		return;
	end

	VUHDO_lnfSkinSnapshotSlider(tSlider);

	tSliderStyle = VUHDO_lnfSkinGetActiveEntry()["sliderStyle"] or "classic";
	tIsVertical = tSlider:GetOrientation() == "VERTICAL";

	if tDecLeft then
		if tSliderStyle == "arrows" then
			tDecLeft:Show();
			tArrowColor = VUHDO_lnfSkinGetActiveEntry()["sliderArrowColor"] or { 0.75, 0.77, 0.80, 1 };
			tNormal = tDecLeft:GetNormalTexture();

			if tNormal then
				VUHDO_lnfSkinSnapshotSliderArrow(tDecLeft);
				VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_up_32_32");
				tNormal:SetVertexColor(tArrowColor[1], tArrowColor[2], tArrowColor[3], tArrowColor[4] or 1);
				VUHDO_lnfSkinApplySliderArrowTexCoord(tDecLeft, tIsVertical, false);
			end
		else
			tDecLeft:Hide();
			VUHDO_lnfSkinRestoreSliderArrowTexCoord(tDecLeft);
		end
	end

	if tDecRight then
		if tSliderStyle == "arrows" then
			tDecRight:Show();
			tArrowColor = VUHDO_lnfSkinGetActiveEntry()["sliderArrowColor"] or { 0.75, 0.77, 0.80, 1 };
			tNormal = tDecRight:GetNormalTexture();

			if tNormal then
				VUHDO_lnfSkinSnapshotSliderArrow(tDecRight);
				VUHDO_lnfSkinStyleTextureKeyed(tNormal, "button_up_32_32");
				tNormal:SetVertexColor(tArrowColor[1], tArrowColor[2], tArrowColor[3], tArrowColor[4] or 1);
				VUHDO_lnfSkinApplySliderArrowTexCoord(tDecRight, tIsVertical, true);
			end
		else
			tDecRight:Hide();
			VUHDO_lnfSkinRestoreSliderArrowTexCoord(tDecRight);
		end
	end

	if tSliderStyle == "arrows" then
		tSlider:ClearAllPoints();

		if tIsVertical then
			VUHDO_PixelUtil.SetPoint(tSlider, "BOTTOM", aFrame, "BOTTOM", 0, 18);
			VUHDO_PixelUtil.SetPoint(tSlider, "TOP", aFrame, "TOP", 0, -18);
			VUHDO_PixelUtil.SetPoint(tSlider, "CENTER", aFrame, "CENTER", 0, 0);
			VUHDO_PixelUtil.SetWidth(tSlider, 6);
		else
			VUHDO_PixelUtil.SetPoint(tSlider, "LEFT", aFrame, "LEFT", 18, 0);
			VUHDO_PixelUtil.SetPoint(tSlider, "RIGHT", aFrame, "RIGHT", -18, 0);
			VUHDO_PixelUtil.SetPoint(tSlider, "CENTER", aFrame, "CENTER", 0, 0);
			VUHDO_PixelUtil.SetHeight(tSlider, 6);
		end

		VUHDO_lnfSkinApplySliderThumb(tSlider, tIsVertical);
	else
		VUHDO_lnfSkinRestoreSliderAnchors(tSlider);
		VUHDO_lnfSkinApplySliderThumb(tSlider, tIsVertical);
	end

	tLabel = _G[tName .. "SliderTitle"];
	tRegion = _G[tName .. "SliderValue"];

	if tLabel then
		VUHDO_lnfSkinSnapshotSliderLabel(tLabel);
	end

	if tRegion then
		VUHDO_lnfSkinSnapshotSliderLabel(tRegion);
	end

	if tSliderStyle == "arrows" and tIsVertical then
		if tLabel and tDecRight then
			tLabel:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(tLabel, "BOTTOM", tDecRight, "TOP", 0, 2);
		end

		if tRegion and tDecLeft then
			tRegion:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(tRegion, "TOP", tDecLeft, "BOTTOM", 0, -2);
		end
	else
		if tLabel then
			VUHDO_lnfSkinRestoreSliderLabelAnchors(tLabel);
		end

		if tRegion then
			VUHDO_lnfSkinRestoreSliderLabelAnchors(tRegion);
		end
	end

	VUHDO_lnfSkinApplyFrameBackdrop(tSlider);

	return;

end



--
local function VUHDO_lnfSkinApplyRadioSwatchAnchors(aButton)

	tName = aButton:GetName();

	if not tName or not _G[tName .. "TextureSwatchTexture"] then
		return;
	end

	tArrowEntry = VUHDO_lnfSkinGetActiveEntry()["radioSwatchOffsetY"];

	for tIdx = 1, 3 do
		if tIdx == 1 then
			tSwatchFrame = _G[tName .. "TextureSwatch"];
		elseif tIdx == 2 then
			tSwatchFrame = _G[tName .. "TextureActiveSwatch"];
		else
			tSwatchFrame = _G[tName .. "TextureCheckMark"];
		end

		if tSwatchFrame then
			VUHDO_lnfSkinSnapshotSliderLabel(tSwatchFrame);

			if not tArrowEntry or tArrowEntry == 0 then
				VUHDO_lnfSkinRestoreSliderLabelAnchors(tSwatchFrame);
			else
				tSliderPoints = sNativeSliderLabelState[tSwatchFrame];

				if tSliderPoints and tSliderPoints["points"] and tSliderPoints["points"][1] then
					tPoint = tSliderPoints["points"][1][1];
					tRelativeTo = tSliderPoints["points"][1][2];
					tRelativePoint = tSliderPoints["points"][1][3];
					tOffsetX = tSliderPoints["points"][1][4];
					tOffsetY = (tSliderPoints["points"][1][5] or 0) + tArrowEntry;

					tSwatchFrame:ClearAllPoints();
					VUHDO_PixelUtil.SetPoint(tSwatchFrame, tPoint, tRelativeTo, tRelativePoint, tOffsetX, tOffsetY);
				end
			end
		end
	end

	return;

end



--
local function VUHDO_lnfSkinApplyTabLabelColor(aButton)

	if not aButton or not aButton["tabPanel"] then
		return;
	end

	tTabPanel = aButton["tabPanel"];
	tTabStyle = VUHDO_lnfSkinGetActiveEntry()["tabStyle"] or "pill";
	tTabIcons = VUHDO_lnfSkinGetActiveEntry()["tabIcons"];

	if tTabStyle == "glyph" and tTabPanel and tTabIcons and tTabIcons[tTabPanel] then
		return;
	end

	tName = aButton:GetName();

	if not tName then
		return;
	end

	if not VUHDO_lnfSkinGetActiveEntry()["tabLabelColors"] then
		tRegion = _G[tName .. "Label"];

		if tRegion then
			tEntry = VUHDO_lnfSkinSnapshotFontString(tRegion);

			if tEntry then
				tRegion:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
			end
		end

		tRegion = _G[tName .. "Label2"];

		if tRegion then
			tEntry = VUHDO_lnfSkinSnapshotFontString(tRegion);

			if tEntry then
				tRegion:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
			end
		end

		tRegion = _G[tName .. "TextureCheckMarkLabel"];

		if tRegion then
			tEntry = VUHDO_lnfSkinSnapshotFontString(tRegion);

			if tEntry then
				tRegion:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
			end
		end

		return;
	end

	if aButton:GetChecked() then
		tEntry = VUHDO_lnfSkinGetActiveEntry()["tabLabelColors"]["active"];
	else
		tEntry = VUHDO_lnfSkinGetActiveEntry()["tabLabelColors"]["inactive"];
	end

	if not tEntry then
		return;
	end

	tNativeR = tEntry["TR"];
	tNativeG = tEntry["TG"];
	tNativeB = tEntry["TB"];
	tNativeA = tEntry["TO"] or 1;

	tRegion = _G[tName .. "Label"];

	if tRegion then
		VUHDO_lnfSkinSnapshotFontString(tRegion);
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	tRegion = _G[tName .. "Label2"];

	if tRegion then
		VUHDO_lnfSkinSnapshotFontString(tRegion);
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	tRegion = _G[tName .. "TextureCheckMarkLabel"];

	if tRegion then
		VUHDO_lnfSkinSnapshotFontString(tRegion);
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	return;

end



--
local tAccentColor;
local tGlyphColor;
local tLabel;
local tButton;
local function VUHDO_lnfSkinApplyTabGlyphAccent(aButton)

	tTabPanel = aButton["tabPanel"];
	tTabStyle = VUHDO_lnfSkinGetActiveEntry()["tabStyle"] or "pill";
	tTabIcons = VUHDO_lnfSkinGetActiveEntry()["tabIcons"];

	tName = aButton:GetName();

	if not tName then
		return;
	end

	if tTabStyle ~= "glyph" or not tTabPanel or not tTabIcons or not tTabIcons[tTabPanel] then
		tLabel = _G[tName .. "Label"];

		if tLabel then
			tEntry = VUHDO_lnfSkinSnapshotFontString(tLabel);

			if tEntry then
				tLabel:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
			end
		end

		tLabel = _G[tName .. "TextureCheckMarkLabel"];

		if tLabel then
			tEntry = VUHDO_lnfSkinSnapshotFontString(tLabel);

			if tEntry then
				tLabel:SetTextColor(tEntry["r"], tEntry["g"], tEntry["b"], tEntry["a"]);
			end
		end

		return;
	end

	tAccentColor = VUHDO_lnfSkinGetActiveEntry()["accentColor"];
	tGlyphColor = VUHDO_lnfSkinGetActiveEntry()["glyphColor"];

	if aButton:GetChecked() then
		tColor = tAccentColor or { 0.45, 0.68, 0.95, 1 };
	else
		tColor = tGlyphColor or { 0.55, 0.58, 0.63, 1 };
	end

	tGlyph = _G[tName .. "Glyph"];

	if tGlyph then
		tGlyph:SetVertexColor(tColor[1], tColor[2], tColor[3], tColor[4] or 1);
	end

	tRegion = _G[tName .. "TextureCheckMarkTexture"];

	if tRegion then
		tRegion:SetAlpha(0);
	end

	tLabel = _G[tName .. "Label"];

	if tLabel then
		VUHDO_lnfSkinSnapshotFontString(tLabel);
		tLabel:SetTextColor(tColor[1], tColor[2], tColor[3], tColor[4] or 1);
	end

	tLabel = _G[tName .. "TextureCheckMarkLabel"];

	if tLabel then
		VUHDO_lnfSkinSnapshotFontString(tLabel);
		tLabel:SetTextColor(tColor[1], tColor[2], tColor[3], tColor[4] or 1);
	end

	return;

end



--
local function VUHDO_lnfSkinRefreshTabButton(aButton)

	VUHDO_lnfSkinApplyTabGlyphAccent(aButton);
	VUHDO_lnfSkinApplyTabLabelColor(aButton);

	return;

end



--
function VUHDO_lnfSkinOnCheckButtonEnter(aButton)

	if not aButton then
		return;
	end

	if aButton["tabPanel"] then
		VUHDO_lnfSkinRefreshTabButton(aButton);

		return;
	end

	tName = aButton:GetName();

	if not tName then
		return;
	end

	tAccentColor = VUHDO_lnfSkinGetActiveEntry()["accentColor"];

	if tAccentColor then
		tNativeR, tNativeG, tNativeB, tNativeA = tAccentColor[1], tAccentColor[2], tAccentColor[3], tAccentColor[4] or 1;
	else
		tNativeR, tNativeG, tNativeB, tNativeA = VUHDO_lnfSkinGetFontColor("active");
	end

	if not tNativeR then
		return;
	end

	tRegion = _G[tName .. "Label"];

	if tRegion then
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	tRegion = _G[tName .. "Label2"];

	if tRegion then
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	return;

end



--
function VUHDO_lnfSkinOnCheckButtonLeave(aButton)

	if not aButton then
		return;
	end

	if aButton["tabPanel"] then
		VUHDO_lnfSkinRefreshTabButton(aButton);

		return;
	end

	tName = aButton:GetName();

	if not tName then
		return;
	end

	tNativeR, tNativeG, tNativeB, tNativeA = VUHDO_lnfSkinGetFontColor("normal");

	if not tNativeR then
		return;
	end

	tRegion = _G[tName .. "Label"];

	if tRegion then
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	tRegion = _G[tName .. "Label2"];

	if tRegion then
		tRegion:SetTextColor(tNativeR, tNativeG, tNativeB, tNativeA);
	end

	return;

end



--
local function VUHDO_lnfSkinRefreshTabSiblings(aCheckButton)

	if not aCheckButton or not aCheckButton["tabPanel"] then
		return;
	end

	tParent = aCheckButton:GetParent();

	if not tParent then
		return;
	end

	for tIdx = 1, select("#", tParent:GetChildren()) do
		tButton = select(tIdx, tParent:GetChildren());

		if tButton:IsObjectType("CheckButton") and tButton["tabPanel"] then
			VUHDO_lnfSkinRefreshTabButton(tButton);
		end
	end

	return;

end



--
local function VUHDO_lnfSkinOnTabCheckButtonClicked(aCheckButton)

	VUHDO_lnfSkinRefreshTabSiblings(aCheckButton);

	return;

end



--
local function VUHDO_lnfSkinOnRadioButtonClicked(aCheckButton)

	if aCheckButton["tabPanel"] then
		VUHDO_lnfSkinRefreshTabSiblings(aCheckButton);
	end

	return;

end



--
local tTabStyle;
local tTabPanel;
local tTabIcons;
local tIconPath;
function VUHDO_lnfSkinDecorateTab(aButton)

	if not aButton then
		return;
	end

	tTabPanel = aButton["tabPanel"];
	tTabStyle = VUHDO_lnfSkinGetActiveEntry()["tabStyle"] or "pill";
	tTabIcons = VUHDO_lnfSkinGetActiveEntry()["tabIcons"];
	tName = aButton:GetName();
	tTabNative = VUHDO_lnfSkinSnapshotTab(aButton);

	if not tName then
		return;
	end

	tGlyph = _G[tName .. "Glyph"];

	if tTabStyle == "glyph" and tTabPanel and tTabIcons and tTabIcons[tTabPanel] then
		tIconPath = tTabIcons[tTabPanel];

		if tGlyph then
			tGlyph:SetTexture(tIconPath);
			tGlyph:Show();
		end

		tSwatchFrame = _G[tName .. "TextureSwatch"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(0);
		end

		tSwatchFrame = _G[tName .. "TextureActiveSwatch"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(0);
		end

		tNormal = aButton:GetNormalTexture();

		if tNormal then
			tNormal:SetAlpha(0);
		end

		tPushed = aButton:GetPushedTexture();

		if tPushed then
			tPushed:SetAlpha(0);
		end

		VUHDO_lnfSkinApplyTabGlyphAccent(aButton);
	else
		if tGlyph then
			tGlyph:SetVertexColor(
				(tTabNative and tTabNative["glyphR"]) or 1,
				(tTabNative and tTabNative["glyphG"]) or 1,
				(tTabNative and tTabNative["glyphB"]) or 1,
				(tTabNative and tTabNative["glyphA"]) or 1
			);

			if tTabNative and tTabNative["glyphShown"] then
				tGlyph:Show();
			else
				tGlyph:Hide();
			end
		end

		tSwatchFrame = _G[tName .. "TextureSwatch"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(tTabNative and tTabNative["swatchAlpha"] or 1);
		end

		tSwatchFrame = _G[tName .. "TextureActiveSwatch"];

		if tSwatchFrame then
			tSwatchFrame:SetAlpha(tTabNative and tTabNative["activeSwatchAlpha"] or 1);
		end

		tNormal = aButton:GetNormalTexture();

		if tNormal then
			tNormal:SetAlpha(tTabNative and tTabNative["normalAlpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(tNormal, "tabstop_inactive");
		end

		tPushed = aButton:GetPushedTexture();

		if tPushed then
			tPushed:SetAlpha(tTabNative and tTabNative["pushedAlpha"] or 1);
			VUHDO_lnfSkinStyleTextureKeyed(tPushed, "tabstop_active");
		end

		tRegion = _G[tName .. "TextureCheckMarkTexture"];

		if _G[tName .. "TextureSwatchTexture"] then
			VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureSwatchTexture"], "icon_black");
			VUHDO_lnfSkinStyleTextureKeyed(_G[tName .. "TextureActiveSwatchTexture"], "icon_aura");

			if tRegion then
				tRegion:SetAlpha(tTabNative and tTabNative["checkMarkTexAlpha"] or 1);
				VUHDO_lnfSkinStyleTextureKeyed(tRegion, "icon_white");
			end

			VUHDO_lnfSkinApplyRadioSwatchAnchors(aButton);
		else
			if tRegion then
				tRegion:SetAlpha(tTabNative and tTabNative["checkMarkTexAlpha"] or 1);
				VUHDO_lnfSkinStyleTextureKeyed(tRegion, "tabstop_active");
			end
		end

		VUHDO_lnfSkinApplyTabLabelColor(aButton);
	end

	return;

end



--
local tRegionTexKey;
local function VUHDO_lnfSkinApplyFrameRegionTextures(aFrame)

	tName = aFrame:GetName();

	if aFrame["skinSquareDemo"] and tName then
		tRegion = _G[tName .. "Texture"];

		if tRegion then
			VUHDO_lnfSkinStyleTextureKeyed(tRegion, "blue_dk_square_16_16");
		end

		return;
	end

	for _, tRegion in ipairs({ aFrame:GetRegions() }) do
		if tRegion:GetObjectType() == "Texture" then
			tEntry = VUHDO_lnfSkinSnapshotTexture(tRegion);
			tRegionTexKey = tEntry and sFrameRegionTextureKeys[string.lower(tostring(VUHDO_lnfSkinBasenameFromPath(tEntry["path"])))];

			if tRegionTexKey then
				VUHDO_lnfSkinStyleTextureKeyed(tRegion, tRegionTexKey);
			end
		end
	end

	return;

end



--
function VUHDO_lnfSkinApplyCheckLabelAnchors(aButton)

	if not sSkinReady or not VUHDO_OPTIONS_SETTINGS or not aButton then
		return;
	end

	if VUHDO_lnfSkinIsTriState(aButton) or aButton["tabPanel"] then
		return;
	end

	tName = aButton:GetName();

	if not tName then
		return;
	end

	tRegion = _G[tName .. "Label"];
	tLabel = _G[tName .. "Label2"];

	if tRegion and tRegion.ClearAllPoints then
		VUHDO_lnfSkinSnapshotSliderLabel(tRegion);
	end

	if tLabel and tLabel.ClearAllPoints then
		VUHDO_lnfSkinSnapshotSliderLabel(tLabel);
	end

	if VUHDO_lnfSkinGetActiveEntry()["checkLabelLeft"] then
		tOffsetY = (tLabel and tLabel.GetText and (tLabel:GetText() or "") ~= "") and 1 or 0;

		if tRegion and tRegion.ClearAllPoints then
			tRegion:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(tRegion, "LEFT", aButton, "LEFT", 40, tOffsetY ~= 0 and 7 or 0);
		end

		if tLabel and tLabel.ClearAllPoints and tOffsetY ~= 0 then
			tLabel:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(tLabel, "LEFT", aButton, "LEFT", 40, -7);
		elseif tLabel and tLabel.ClearAllPoints then
			VUHDO_lnfSkinRestoreSliderLabelAnchors(tLabel);
		end
	else
		if tRegion and tRegion.ClearAllPoints then
			VUHDO_lnfSkinRestoreSliderLabelAnchors(tRegion);
		end

		if tLabel and tLabel.ClearAllPoints then
			VUHDO_lnfSkinRestoreSliderLabelAnchors(tLabel);
		end
	end

	return;

end



--
local tSliderParent;
local tObjectType;
function VUHDO_lnfSkinApplyToComponent(aComponent, aLabelName)

	if not sSkinReady or not VUHDO_OPTIONS_SETTINGS then
		return;
	end

	if not aComponent then
		return;
	end

	tName = aComponent;

	for _ = 1, 32 do
		if not tName then
			break;
		end

		if tName == VuhDoBuffWatchMainFrame then
			return;
		end

		tName = tName.GetParent and tName:GetParent() or nil;
	end

	tObjectType = aComponent:GetObjectType();

	if tObjectType == "Button" then
		tSliderParent = aComponent:GetParent();
		tName = tSliderParent and tSliderParent.GetName and tSliderParent:GetName();

		if not (tName and _G[tName .. "Slider"] and (aComponent == _G[tName .. "DecLeft"] or aComponent == _G[tName .. "DecRight"])) then
			if aComponent["skinListEntry"] then
				VUHDO_lnfSkinStyleListEntry(aComponent, aComponent["skinListEntrySelected"]);
			elseif VUHDO_lnfSkinIsTriState(aComponent) then
				VUHDO_lnfSkinApplyTriStateDot(aComponent);
			elseif VUHDO_lnfSkinIsComboBody(aComponent) then
				VUHDO_lnfSkinApplyComboTextures(aComponent);
			elseif VUHDO_lnfSkinIsComboArrow(aComponent) then
				return;
			else
				VUHDO_lnfSkinApplyButtonTextures(aComponent);
			end
		end
	elseif tObjectType == "EditBox" then
		VUHDO_lnfSkinApplyEditTextures(aComponent);
	elseif tObjectType == "CheckButton" then
		if not VUHDO_lnfSkinIsTriState(aComponent) then
			VUHDO_lnfSkinApplyCheckTextures(aComponent);
			VUHDO_lnfSkinApplyCheckLabelAnchors(aComponent);
		end

		if aComponent["tabPanel"] then
			VUHDO_lnfSkinDecorateTab(aComponent);
		end

		VUHDO_lnfSkinApplyComponentIcon(aComponent);
	elseif tObjectType == "Slider" then
		VUHDO_lnfSkinApplySliderThumb(aComponent, aComponent:GetOrientation() == "VERTICAL");
		VUHDO_lnfSkinApplyFrameBackdrop(aComponent);
		tSliderParent = aComponent:GetParent();
		tName = tSliderParent and tSliderParent:GetName();

		if tName and _G[tName .. "DecLeft"] then
			VUHDO_lnfSkinDecorateSlider(tSliderParent);
		end
	elseif tObjectType == "Frame" then
		if aComponent["parentCombo"] then
			VUHDO_lnfSkinApplyComboItemBackdrop(aComponent);
		elseif VUHDO_lnfSkinIsComboBody(aComponent) then
			VUHDO_lnfSkinApplyComboTextures(aComponent);
		else
			if aComponent["skinListEntry"] then
				VUHDO_lnfSkinStyleListEntry(aComponent, aComponent["skinListEntrySelected"]);
			else
				VUHDO_lnfSkinApplyFrameBackdrop(aComponent);
				VUHDO_lnfSkinApplyFrameRegionTextures(aComponent);

				tName = aComponent:GetName();

				if tName and _G[tName .. "DecLeft"] and _G[tName .. "Slider"] then
					VUHDO_lnfSkinDecorateSlider(aComponent);
				end

				VUHDO_lnfSkinStyleColorSwatch(aComponent);
			end
		end
	elseif tObjectType == "ScrollFrame" then
		VUHDO_lnfSkinApplyFrameBackdrop(aComponent);
	elseif tObjectType == "ColorSelect" then
		VUHDO_lnfSkinApplyFrameBackdrop(aComponent);
	end

	VUHDO_lnfSkinApplyFontColors(aComponent);

	if tObjectType == "CheckButton" and VUHDO_lnfSkinIsTriState(aComponent) then
		VUHDO_lnfSkinApplyTriStateDot(aComponent);
	end

	if tObjectType == "CheckButton" and aComponent["tabPanel"] then
		VUHDO_lnfSkinRefreshTabButton(aComponent);
	end

	return;

end



--
function VUHDO_lnfSkinApplyToFrameTree(aFrame)

	if not aFrame then
		return;
	end

	VUHDO_lnfSkinApplyToComponent(aFrame);

	for _, tChild in ipairs({ aFrame:GetChildren() }) do
		VUHDO_lnfSkinApplyToFrameTree(tChild);
	end

	return;

end



--
function VUHDO_lnfSkinApplyAll()

	if not sSkinReady then
		return;
	end

	if VuhDoNewOptionsTabbedFrame then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoNewOptionsTabbedFrame);
	end

	if VuhDoNewOptionsScaleSlider then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoNewOptionsScaleSlider);
	end

	if VuhDoOptionsTooltip then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoOptionsTooltip);
	end

	if VuhDoNewColorPicker then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoNewColorPicker);
	end

	if VuhDoLnfIconTextDialog then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoLnfIconTextDialog);
	end

	if VuhDoLnfShareDialog then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoLnfShareDialog);
	end

	if VuhDoYesNoFrame then
		VUHDO_lnfSkinApplyToFrameTree(VuhDoYesNoFrame);
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_lnfSkinStyleMovePanelConfigIcons(tPanelNum);
	end

	return;

end



--
function VUHDO_lnfSkinSetActive(aSkinName)

	if not VUHDO_OPTIONS_SETTINGS then
		return;
	end

	if not VUHDO_OPTIONS_SKINS[aSkinName] then
		aSkinName = "Classic";
	end

	VUHDO_OPTIONS_SETTINGS["SKIN"] = aSkinName;
	VUHDO_lnfSkinRewriteBackdrops();
	VUHDO_lnfSkinApplyAll();

	return;

end



--
function VUHDO_lnfSkinComboValueChanged(aComboBox, aValue)

	VUHDO_lnfSkinSetActive(aValue);

	return;

end



--
function VUHDO_lnfSkinStepSlider(aButton, aDir)

	if not aButton then
		return;
	end

	tSliderParent = aButton:GetParent();
	tName = tSliderParent:GetName();
	tSlider = _G[tName .. "Slider"];

	if tSlider then
		tSlider:SetValue(tSlider:GetValue() + (aDir * tSlider:GetValueStep()));
	end

	return;

end



--
local tColorLen;
local tFontEntry;
local function VUHDO_lnfSkinValidateColorArray(aColor, aLabel)

	if type(aColor) ~= "table" then
		VUHDO_Msg(format("Skin %s: must be a table", aLabel), 1, 0.4, 0.4);

		return false;
	end

	tColorLen = #aColor;

	if tColorLen < 3 or tColorLen > 4 then
		VUHDO_Msg(format("Skin %s: must have 3 or 4 numeric values", aLabel), 1, 0.4, 0.4);

		return false;
	end

	for tIdx = 1, tColorLen do
		if type(aColor[tIdx]) ~= "number" then
			VUHDO_Msg(format("Skin %s: values must be numeric", aLabel), 1, 0.4, 0.4);

			return false;
		end
	end

	return true;

end



--
local tBackdropEntry;
local function VUHDO_lnfSkinValidate(aName, aSkinData)

	if type(aName) ~= "string" or aName == "" then
		VUHDO_Msg("Skin name must be a non-blank string", 1, 0.4, 0.4);

		return false;
	end

	if type(aSkinData) ~= "table" then
		VUHDO_Msg(format("Skin \"%s\": data must be a table", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["sliderStyle"] and aSkinData["sliderStyle"] ~= "classic" and aSkinData["sliderStyle"] ~= "arrows" then
		VUHDO_Msg(format("Skin \"%s\": sliderStyle must be \"classic\" or \"arrows\"", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["tabStyle"] and aSkinData["tabStyle"] ~= "pill" and aSkinData["tabStyle"] ~= "glyph" then
		VUHDO_Msg(format("Skin \"%s\": tabStyle must be \"pill\" or \"glyph\"", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["toggleStyle"] and aSkinData["toggleStyle"] ~= "box" and aSkinData["toggleStyle"] ~= "dot" then
		VUHDO_Msg(format("Skin \"%s\": toggleStyle must be \"box\" or \"dot\"", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["checkFaceHidden"] ~= nil and type(aSkinData["checkFaceHidden"]) ~= "boolean" then
		VUHDO_Msg(format("Skin \"%s\": checkFaceHidden must be boolean", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["checkLabelLeft"] ~= nil and type(aSkinData["checkLabelLeft"]) ~= "boolean" then
		VUHDO_Msg(format("Skin \"%s\": checkLabelLeft must be boolean", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["badgeOnlyButtons"] ~= nil and type(aSkinData["badgeOnlyButtons"]) ~= "boolean" then
		VUHDO_Msg(format("Skin \"%s\": badgeOnlyButtons must be boolean", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["font"] and type(aSkinData["font"]) ~= "string" then
		VUHDO_Msg(format("Skin \"%s\": font must be a string", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["textures"] and type(aSkinData["textures"]) ~= "table" then
		VUHDO_Msg(format("Skin \"%s\": textures must be a table", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["textureTints"] then
		if type(aSkinData["textureTints"]) ~= "table" then
			VUHDO_Msg(format("Skin \"%s\": textureTints must be a table", aName), 1, 0.4, 0.4);

			return false;
		end

		for tKey, tValue in pairs(aSkinData["textureTints"]) do
			if not VUHDO_lnfSkinValidateColorArray(tValue, format("\"%s\".textureTints.%s", aName, tKey)) then
				return false;
			end
		end
	end

	if aSkinData["sliderArrowColor"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["sliderArrowColor"], format("\"%s\".sliderArrowColor", aName)) then
			return false;
		end
	end

	if aSkinData["accentColor"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["accentColor"], format("\"%s\".accentColor", aName)) then
			return false;
		end
	end

	if aSkinData["swatchBorderColor"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["swatchBorderColor"], format("\"%s\".swatchBorderColor", aName)) then
			return false;
		end
	end

	if aSkinData["glyphColor"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["glyphColor"], format("\"%s\".glyphColor", aName)) then
			return false;
		end
	end

	if aSkinData["indicatorPlate"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["indicatorPlate"], format("\"%s\".indicatorPlate", aName)) then
			return false;
		end
	end

	if aSkinData["checkGroupPlate"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["checkGroupPlate"], format("\"%s\".checkGroupPlate", aName)) then
			return false;
		end
	end

	if aSkinData["entrySelectColor"] then
		if not VUHDO_lnfSkinValidateColorArray(aSkinData["entrySelectColor"], format("\"%s\".entrySelectColor", aName)) then
			return false;
		end
	end

	if aSkinData["backdropColors"] then
		if type(aSkinData["backdropColors"]) ~= "table" then
			VUHDO_Msg(format("Skin \"%s\": backdropColors must be a table", aName), 1, 0.4, 0.4);

			return false;
		end

		for tKey, tValue in pairs(aSkinData["backdropColors"]) do
			if not sValidBackdropColorKeys[tKey] then
				VUHDO_Msg(format("Skin \"%s\": unknown backdropColors key \"%s\"", aName, tKey), 1, 0.4, 0.4);
			end

			if type(tValue) ~= "table" then
				VUHDO_Msg(format("Skin \"%s\": backdropColors.%s must be a table", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			tBackdropEntry = tValue;

			if tBackdropEntry["bg"] and not VUHDO_lnfSkinValidateColorArray(tBackdropEntry["bg"], format("\"%s\".backdropColors.%s.bg", aName, tKey)) then
				return false;
			end

			if tBackdropEntry["border"] and not VUHDO_lnfSkinValidateColorArray(tBackdropEntry["border"], format("\"%s\".backdropColors.%s.border", aName, tKey)) then
				return false;
			end
		end
	end

	if aSkinData["fontColors"] then
		if type(aSkinData["fontColors"]) ~= "table" then
			VUHDO_Msg(format("Skin \"%s\": fontColors must be a table", aName), 1, 0.4, 0.4);

			return false;
		end

		for tKey, tValue in pairs(aSkinData["fontColors"]) do
			if not sValidFontColorKeys[tKey] then
				VUHDO_Msg(format("Skin \"%s\": unknown fontColors key \"%s\"", aName, tKey), 1, 0.4, 0.4);
			end

			if type(tValue) ~= "table" then
				VUHDO_Msg(format("Skin \"%s\": fontColors.%s must be a table", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			tFontEntry = tValue;

			if tFontEntry["TR"] and type(tFontEntry["TR"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": fontColors.%s.TR must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			if tFontEntry["TG"] and type(tFontEntry["TG"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": fontColors.%s.TG must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			if tFontEntry["TB"] and type(tFontEntry["TB"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": fontColors.%s.TB must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			if tFontEntry["TO"] and type(tFontEntry["TO"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": fontColors.%s.TO must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end
		end
	end

	if aSkinData["tabLabelColors"] then
		if type(aSkinData["tabLabelColors"]) ~= "table" then
			VUHDO_Msg(format("Skin \"%s\": tabLabelColors must be a table", aName), 1, 0.4, 0.4);

			return false;
		end

		for tKey, tValue in pairs(aSkinData["tabLabelColors"]) do
			if tKey ~= "active" and tKey ~= "inactive" then
				VUHDO_Msg(format("Skin \"%s\": unknown tabLabelColors key \"%s\"", aName, tKey), 1, 0.4, 0.4);
			end

			if type(tValue) ~= "table" then
				VUHDO_Msg(format("Skin \"%s\": tabLabelColors.%s must be a table", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			tFontEntry = tValue;

			if tFontEntry["TR"] and type(tFontEntry["TR"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": tabLabelColors.%s.TR must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			if tFontEntry["TG"] and type(tFontEntry["TG"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": tabLabelColors.%s.TG must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			if tFontEntry["TB"] and type(tFontEntry["TB"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": tabLabelColors.%s.TB must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end

			if tFontEntry["TO"] and type(tFontEntry["TO"]) ~= "number" then
				VUHDO_Msg(format("Skin \"%s\": tabLabelColors.%s.TO must be numeric", aName, tKey), 1, 0.4, 0.4);

				return false;
			end
		end
	end

	if aSkinData["radioSwatchOffsetY"] and type(aSkinData["radioSwatchOffsetY"]) ~= "number" then
		VUHDO_Msg(format("Skin \"%s\": radioSwatchOffsetY must be numeric", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["tabIcons"] and type(aSkinData["tabIcons"]) ~= "table" then
		VUHDO_Msg(format("Skin \"%s\": tabIcons must be a table", aName), 1, 0.4, 0.4);

		return false;
	end

	if aSkinData["comboItemColors"] then
		if type(aSkinData["comboItemColors"]) ~= "table" then
			VUHDO_Msg(format("Skin \"%s\": comboItemColors must be a table", aName), 1, 0.4, 0.4);

			return false;
		end

		for tKey, tValue in pairs(aSkinData["comboItemColors"]) do
			if not sValidComboItemColorKeys[tKey] then
				VUHDO_Msg(format("Skin \"%s\": unknown comboItemColors key \"%s\"", aName, tKey), 1, 0.4, 0.4);
			end

			if not VUHDO_lnfSkinValidateColorArray(tValue, format("\"%s\".comboItemColors.%s", aName, tKey)) then
				return false;
			end
		end
	end

	if aSkinData["triStateValueColors"] then
		if type(aSkinData["triStateValueColors"]) ~= "table" then
			VUHDO_Msg(format("Skin \"%s\": triStateValueColors must be a table", aName), 1, 0.4, 0.4);

			return false;
		end

		for tCnt = 1, 3 do
			if aSkinData["triStateValueColors"][tCnt]
				and not VUHDO_lnfSkinValidateColorArray(aSkinData["triStateValueColors"][tCnt], format("\"%s\".triStateValueColors[%d]", aName, tCnt)) then
				return false;
			end
		end
	end

	for tKey, _ in pairs(aSkinData) do
		if not sKnownSkinKeys[tKey] then
			VUHDO_Msg(format("Skin \"%s\": unknown key \"%s\"", aName, tKey), 1, 0.4, 0.4);
		end
	end

	return true;

end



--
function VUHDO_registerSkin(aName, aSkinData)

	if not VUHDO_lnfSkinValidate(aName, aSkinData) then
		return;
	end

	if not aSkinData["displayName"] then
		aSkinData["displayName"] = aName;
	end

	VUHDO_OPTIONS_SKINS[aName] = aSkinData;

	if sComboTableInitialized then
		VUHDO_lnfSkinInitComboTable();
	end

	if sSkinReady and aName == VUHDO_lnfSkinGetActive() then
		VUHDO_lnfSkinRewriteBackdrops();
		VUHDO_lnfSkinApplyAll();
	end

	return;

end



--
function VUHDO_unregisterSkin(aName)

	if aName == "Classic" then
		VUHDO_Msg("Skin \"Classic\" cannot be unregistered", 1, 0.4, 0.4);

		return;
	end

	if not VUHDO_OPTIONS_SKINS[aName] then
		return;
	end

	VUHDO_OPTIONS_SKINS[aName] = nil;

	if VUHDO_OPTIONS_SETTINGS and VUHDO_OPTIONS_SETTINGS["SKIN"] == aName then
		VUHDO_OPTIONS_SETTINGS["SKIN"] = "Classic";
		VUHDO_lnfSkinRewriteBackdrops();
		VUHDO_lnfSkinApplyAll();
	end

	if sComboTableInitialized then
		VUHDO_lnfSkinInitComboTable();
	end

	return;

end



--
function VUHDO_isSkinRegistered(aName)

	return VUHDO_OPTIONS_SKINS[aName] ~= nil;

end



--
local tResult;
function VUHDO_getRegisteredSkins()

	tResult = { };

	for tName, tEntry in pairs(VUHDO_OPTIONS_SKINS) do
		tinsert(tResult, {
			["name"] = tName,
			["displayName"] = tEntry["displayName"] or tName,
		});
	end

	return tResult;

end



--
local tSkinEntry;
local function VUHDO_lnfSkinComboTableSort(anA, anotherA)

	return anA[2] < anotherA[2];

end



--
local tDisplayName;
function VUHDO_lnfSkinInitComboTable()

	twipe(VUHDO_OPTIONS_SKIN_COMBO_TABLE);

	for tName, tSkinEntry in pairs(VUHDO_OPTIONS_SKINS) do
		tDisplayName = tSkinEntry["displayName"] or tName;

		tinsert(VUHDO_OPTIONS_SKIN_COMBO_TABLE, { tName, tDisplayName });
	end

	tsort(VUHDO_OPTIONS_SKIN_COMBO_TABLE, VUHDO_lnfSkinComboTableSort);

	sComboTableInitialized = true;

	return;

end



--
function VUHDO_lnfSkinInit()

	if not VUHDO_OPTIONS_SETTINGS then
		return;
	end

	if not VUHDO_OPTIONS_SETTINGS["SKIN"] then
		VUHDO_OPTIONS_SETTINGS["SKIN"] = "Classic";
	elseif VUHDO_OPTIONS_SETTINGS["SKIN"] == "Default" then
		VUHDO_OPTIONS_SETTINGS["SKIN"] = "Classic";
	end

	if not VUHDO_OPTIONS_SETTINGS["SKIN_TINTS"] then
		VUHDO_OPTIONS_SETTINGS["SKIN_TINTS"] = { };
	end

	VUHDO_lnfSkinInitComboTable();
	VUHDO_lnfSkinRewriteBackdrops();

	if not sPatchFontHooked then
		hooksecurefunc("VUHDO_lnfPatchFont", VUHDO_lnfSkinApplyToComponent);

		sPatchFontHooked = true;
	end

	if not sTabGlyphHooked then
		hooksecurefunc("VUHDO_lnfTabCheckButtonClicked", VUHDO_lnfSkinOnTabCheckButtonClicked);
		hooksecurefunc("VUHDO_lnfRadioButtonClicked", VUHDO_lnfSkinOnRadioButtonClicked);
		hooksecurefunc("VUHDO_lnfCheckButtonOnEnter", VUHDO_lnfSkinOnCheckButtonEnter);
		hooksecurefunc("VUHDO_lnfCheckButtonOnLeave", VUHDO_lnfSkinOnCheckButtonLeave);
		hooksecurefunc("VUHDO_lnfTabCheckButtonOnEnter", VUHDO_lnfSkinRefreshTabButton);
		hooksecurefunc("VUHDO_lnfTabCheckButtonOnLeave", VUHDO_lnfSkinRefreshTabButton);
		hooksecurefunc("VUHDO_lnfCheckButtonOnLoad", VUHDO_lnfSkinApplyCheckLabelAnchors);

		sTabGlyphHooked = true;
	end

	if not sTriStateHooked then
		hooksecurefunc("VUHDO_lnfTriStateCheckButtonUpdateModel", VUHDO_lnfSkinOnTriStateCheckButtonUpdateModel);
		hooksecurefunc("VUHDO_lnfTriStateCheckButtonInitFromModel", VUHDO_lnfSkinOnTriStateCheckButtonUpdateModel);

		sTriStateHooked = true;
	end

	if not sComboHooked then
		hooksecurefunc("VUHDO_lnfComboInitItems", VUHDO_lnfSkinOnComboInitItems);
		hooksecurefunc("VUHDO_lnfComboItemOnEnter", VUHDO_lnfSkinOnComboItemOnEnter);
		hooksecurefunc("VUHDO_lnfComboItemOnLeave", VUHDO_lnfSkinOnComboItemOnLeave);
		hooksecurefunc("VUHDO_lnfComboButtonClicked", VUHDO_lnfSkinOnComboButtonClicked);
		hooksecurefunc("VUHDO_lnfCheckTreeRowOnEnter", VUHDO_lnfSkinOnCheckTreeRowOnEnter);
		hooksecurefunc("VUHDO_lnfCheckTreeRowOnLeave", VUHDO_lnfSkinOnCheckTreeRowOnLeave);

		sComboHooked = true;
	end

	if not sSquareDemoHooked then
		hooksecurefunc("VUHDO_squareDemoOnShow", VUHDO_lnfSkinOnSquareDemoOnShow);

		sSquareDemoHooked = true;
	end

	if not sAuraGroupsHooked then
		hooksecurefunc("VUHDO_auraGroupsRefreshListEntries", VUHDO_lnfSkinOnAuraGroupsRefresh);
		hooksecurefunc("VUHDO_buildAllBuffSetupGenerericPanel", VUHDO_lnfSkinOnBuffWatchRefresh);
		hooksecurefunc("VUHDO_positionAllGroupConfigPanels", VUHDO_lnfSkinStyleMovePanelConfigIcons);
		hooksecurefunc("VUHDO_lnfColorSwatchInitFromModel", VUHDO_lnfSkinStyleColorSwatch);

		sAuraGroupsHooked = true;
	end

	sSkinReady = true;
	VUHDO_lnfSkinApplyAll();

	return;

end



VUHDO_registerSkin("Classic", sClassicSkin);
VUHDO_registerSkin("Dark", sDarkSkin);