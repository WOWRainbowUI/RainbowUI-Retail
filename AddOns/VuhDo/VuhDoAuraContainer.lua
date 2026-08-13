local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local tconcat = table.concat;
local tsort = table.sort;
local twipe = table.wipe;
local format = string.format;

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;
local UnitExists = UnitExists;
local UnitCanAttack = UnitCanAttack;
local UnitCanAssist = UnitCanAssist;
local issecretvalue = issecretvalue;
local CreateNumericRuleFormatter = C_StringUtil and C_StringUtil.CreateNumericRuleFormatter;
local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve;
local CreateColor = CreateColor;

local VUHDO_ON_UPDATE_MODE_RUN_ONCE = Enum.OnUpdateMode.RunWhenVisibleOnce;

VUHDO_AURA_CONTAINERS = VUHDO_AURA_CONTAINERS or { };
local VUHDO_AURA_CONTAINERS = VUHDO_AURA_CONTAINERS;

VUHDO_OVERLAY_CONTAINERS = VUHDO_OVERLAY_CONTAINERS or { };
local VUHDO_OVERLAY_CONTAINERS = VUHDO_OVERLAY_CONTAINERS;

local VUHDO_AURA_CONTAINER_TEMPLATE = "VuhDoAuraContainerTemplate";
local VUHDO_FILL_CHAIN_CONTAINER_TEMPLATE = "VuhDoFillChainAuraContainerTemplate";
VUHDO_AURA_BUTTON_ICON_TEMPLATE = "VuhDoAuraButtonIconTemplate";
VUHDO_AURA_BUTTON_BAR_TEMPLATE = "VuhDoAuraButtonBarTemplate";
VUHDO_AURA_BUTTON_DISPEL_OVERLAY_TEMPLATE = "VuhDoAuraButtonDispelOverlayTemplate";

VUHDO_AURA_CONTAINER_TEMPLATE_CACHE = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE or { };
local VUHDO_AURA_CONTAINER_TEMPLATE_CACHE = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE;
VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_GENERATION = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_GENERATION or 0;

VUHDO_AURA_CONTAINER_METRICS = VUHDO_AURA_CONTAINER_METRICS or {
	["builds"] = { },
	["releases"] = { },
	["poolHits"] = { },
};
local VUHDO_AURA_CONTAINER_METRICS = VUHDO_AURA_CONTAINER_METRICS;

VUHDO_AURA_GROWTH_OFFSETS = VUHDO_AURA_GROWTH_OFFSETS or {
	["LEFT"] = { -1, 0 },
	["RIGHT"] = { 1, 0 },
	["UP"] = { 0, 1 },
	["DOWN"] = { 0, -1 },
};

VUHDO_INDICATOR_OVERLAY_TARGETS = {
	["HEALTH_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 1,
		["barValue"] = "bouquet",
	},
	["MANA_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 2,
		["barValue"] = "bouquet",
	},
	["BACKGROUND_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 3,
		["barValue"] = "binary",
	},
	["AGGRO_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 4,
		["barValue"] = "binary",
	},
	["THREAT_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 7,
		["barValue"] = "bouquet",
	},
	["MOUSEOVER_HIGHLIGHT"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 8,
		["barValue"] = "binary",
	},
	["SIDE_LEFT"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 17,
		["barValue"] = "bouquet",
	},
	["SIDE_RIGHT"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 18,
		["barValue"] = "bouquet",
	},
	["BAR_BORDER"] = {
		["shape"] = "border",
		["getter"] = "VUHDO_getPlayerTargetFrame",
	},
	["CLUSTER_BORDER"] = {
		["shape"] = "border",
		["getter"] = "VUHDO_getClusterBorderFrame",
	},
	["SWIFTMEND_INDICATOR"] = {
		["shape"] = "dot",
		["getter"] = "VUHDO_getBarRoleIcon",
		["iconIndex"] = 51,
	},
	["THREAT_MARK"] = {
		["shape"] = "dot",
		["getter"] = "VUHDO_getAggroTexture",
		["barIndex"] = 1,
		["ofBar"] = true,
	},
};

local VUHDO_PANEL_SETUP;
local VUHDO_RAID;
local VUHDO_STATUSBAR_LEFT_TO_RIGHT;
local VUHDO_STATUSBAR_RIGHT_TO_LEFT;
local VUHDO_STATUSBAR_BOTTOM_TO_TOP;
local VUHDO_STATUSBAR_TOP_TO_BOTTOM;
local VUHDO_SPELL_DURATION_MODE_FULL;
local VUHDO_SPELL_DURATION_MODE_ALIVE;
local VUHDO_ATLAS_TEXTURES;

local VUHDO_PixelUtil;
local VUHDO_LibSharedMedia;

local VUHDO_getUnitButtonsSafe;
local VUHDO_getHealthBar;
local VUHDO_setStatusBarOrientation;
local VUHDO_setLlcStatusBarTexture;
local VUHDO_copyStatusBarFillTexture;
local VUHDO_getClassColor;
local VUHDO_backColorWithFallback;
local VUHDO_customizeIconText;
local VUHDO_resolveAuraTriState;
local VUHDO_isAuraDataRestricted;
local VUHDO_isAuraModeContainers;
local VUHDO_resolveGroupTimerSettings;
local VUHDO_resolveFixedAuraSlotPlacement;
local VUHDO_startAuraButtonGlow;
local VUHDO_getDispelTypeColorMap;
local VUHDO_getDispelTypeColorMapOpaque;
local VUHDO_getDispelColorGeneration;
local VUHDO_applyAuraGroupBarGlowFromAuraButton;
local VUHDO_getManaAdjustedYOffset;
local VUHDO_releaseAuraButtonGlowState;

local sAuraBorderOptions = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sAuraSymbolOptions = {
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sDispelOverlayIconOptions = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = false,
};

local sAuraOpaqueBorderOptions = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sAuraDurationBarOptions = { };

local sEmpty = { };

local sSuppressCandidateFilters = {
	["maxDuration"] = 0,
};
VUHDO_SUPPRESS_CANDIDATE_FILTERS = sSuppressCandidateFilters;

local sPendingContainerBuilds = { };
local sPendingButtonLayouts = { };
local sPendingClassColors = { };
local sHasPendingBuilds = false;
local sContainerClassColorBars = { };

local sAuraBarIconLayouts = {
	[0] = {
		["iconPoint"] = "LEFT",
		["barPoint"] = "LEFT",
		["barRelPoint"] = "RIGHT",
		["useBarWidth"] = true,
	},
	[1] = {
		["iconPoint"] = "RIGHT",
		["barPoint"] = "RIGHT",
		["barRelPoint"] = "LEFT",
		["useBarWidth"] = true,
	},
	[2] = {
		["iconPoint"] = "BOTTOM",
		["barPoint"] = "BOTTOM",
		["barRelPoint"] = "TOP",
		["useBarWidth"] = false,
	},
	[3] = {
		["iconPoint"] = "TOP",
		["barPoint"] = "TOP",
		["barRelPoint"] = "BOTTOM",
		["useBarWidth"] = false,
	},
};

local sAuraTimerFormatterFull;
local sAuraTimerFormattersByThreshold = { };
local sAuraTimerColorCurveFull;
local sAuraTimerColorCurvesByThreshold = { };
local sChainBaselineColors = { };
local sAuraContainerPool = { };
local sPoolKeyScratch = { };

local sBorderTexture;
local sBorderEdgeTop;
local sBorderEdgeBottom;
local sBorderEdgeLeft;
local sBorderEdgeRight;
local sBorderColorR;
local sBorderColorG;
local sBorderColorB;
local sBorderColorO;
local sBorderWidth;
local sBorderFile;



--
local tBreakpoints;
local function VUHDO_copyAuraTimerBaseBreakpoints()

	tBreakpoints = {
		{
			["threshold"] = 3600,
			["format"] = "%.1f",
			["components"] = {
				{
					["div"] = 3600,
					["step"] = 0.1,
					["rounding"] = Enum.NumericRuleFormatRounding.Down,
				},
			},
		},
		{
			["threshold"] = 60,
			["format"] = "%d",
			["components"] = {
				{
					["div"] = 60,
					["step"] = 1,
					["rounding"] = Enum.NumericRuleFormatRounding.Down,
				},
			},
		},
		{
			["threshold"] = 0,
			["step"] = 1,
			["rounding"] = Enum.NumericRuleFormatRounding.Down,
			["format"] = "%d",
		},
	};

	return tBreakpoints;

end



--
local tFormatter;
local tTimerThreshold;
local tHideThreshold;
local tBreakpoints;
function VUHDO_getAuraTimerFormatter(aDurationMode, aTimerThreshold)

	if aDurationMode == VUHDO_SPELL_DURATION_MODE_FULL or aDurationMode == VUHDO_SPELL_DURATION_MODE_ALIVE then
		-- FIXME: alive mode elapsed time is not supported by CustomAuraButton DurationTextBinding
		if not sAuraTimerFormatterFull then
			sAuraTimerFormatterFull = CreateNumericRuleFormatter();
			sAuraTimerFormatterFull:SetBreakpoints(VUHDO_copyAuraTimerBaseBreakpoints());
		end

		return sAuraTimerFormatterFull;
	end

	tTimerThreshold = aTimerThreshold or 9.99;
	tFormatter = sAuraTimerFormattersByThreshold[tTimerThreshold];

	if not tFormatter then
		tFormatter = CreateNumericRuleFormatter();
		tBreakpoints = VUHDO_copyAuraTimerBaseBreakpoints();

		tHideThreshold = tTimerThreshold + 0.01;

		tBreakpoints[#tBreakpoints + 1] = {
			["threshold"] = tHideThreshold,
			["format"] = "",
		};

		tsort(tBreakpoints, function(aLeft, aRight)
			return aLeft["threshold"] > aRight["threshold"];
		end);

		tFormatter:SetBreakpoints(tBreakpoints);
		sAuraTimerFormattersByThreshold[tTimerThreshold] = tFormatter;
	end

	return tFormatter;

end



--
function VUHDO_auraContainerInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_STATUSBAR_LEFT_TO_RIGHT = _G["VUHDO_STATUSBAR_LEFT_TO_RIGHT"];
	VUHDO_STATUSBAR_RIGHT_TO_LEFT = _G["VUHDO_STATUSBAR_RIGHT_TO_LEFT"];
	VUHDO_STATUSBAR_BOTTOM_TO_TOP = _G["VUHDO_STATUSBAR_BOTTOM_TO_TOP"];
	VUHDO_STATUSBAR_TOP_TO_BOTTOM = _G["VUHDO_STATUSBAR_TOP_TO_BOTTOM"];
	VUHDO_SPELL_DURATION_MODE_FULL = _G["VUHDO_SPELL_DURATION_MODE_FULL"];
	VUHDO_SPELL_DURATION_MODE_ALIVE = _G["VUHDO_SPELL_DURATION_MODE_ALIVE"];
	VUHDO_ATLAS_TEXTURES = _G["VUHDO_ATLAS_TEXTURES"];

	VUHDO_PixelUtil = _G["VUHDO_PixelUtil"];
	VUHDO_LibSharedMedia = _G["VUHDO_LibSharedMedia"];

	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_setStatusBarOrientation = _G["VUHDO_setStatusBarOrientation"];
	VUHDO_setLlcStatusBarTexture = _G["VUHDO_setLlcStatusBarTexture"];
	VUHDO_copyStatusBarFillTexture = _G["VUHDO_copyStatusBarFillTexture"];
	VUHDO_getClassColor = _G["VUHDO_getClassColor"];
	VUHDO_backColorWithFallback = _G["VUHDO_backColorWithFallback"];
	VUHDO_customizeIconText = _G["VUHDO_customizeIconText"];
	VUHDO_resolveAuraTriState = _G["VUHDO_resolveAuraTriState"];
	VUHDO_isAuraDataRestricted = _G["VUHDO_isAuraDataRestricted"];
	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];
	VUHDO_resolveGroupTimerSettings = _G["VUHDO_resolveGroupTimerSettings"];
	VUHDO_resolveFixedAuraSlotPlacement = _G["VUHDO_resolveFixedAuraSlotPlacement"];
	VUHDO_startAuraButtonGlow = _G["VUHDO_startAuraButtonGlow"];
	VUHDO_getDispelTypeColorMap = _G["VUHDO_getDispelTypeColorMap"];
	VUHDO_getDispelTypeColorMapOpaque = _G["VUHDO_getDispelTypeColorMapOpaque"];
	VUHDO_getDispelColorGeneration = _G["VUHDO_getDispelColorGeneration"];
	VUHDO_applyAuraGroupBarGlowFromAuraButton = _G["VUHDO_applyAuraGroupBarGlowFromAuraButton"];
	VUHDO_getManaAdjustedYOffset = _G["VUHDO_getManaAdjustedYOffset"];
	VUHDO_releaseAuraButtonGlowState = _G["VUHDO_releaseAuraButtonGlowState"];

	sAuraOpaqueBorderOptions["backingCurveFn"] = _G["VUHDO_getDispelTypeBackgroundBackingCurve"];
	sAuraOpaqueBorderOptions["fillCurveFn"] = _G["VUHDO_getDispelTypeBackgroundFillCurve"];

	if not sAuraTimerColorCurveFull then
		sAuraTimerColorCurveFull = CreateColorCurve();

		sAuraTimerColorCurveFull:SetType(Enum.LuaCurveType.Step);
		sAuraTimerColorCurveFull:AddPoint(0, CreateColor(1, 1, 1, 1));
		sAuraTimerColorCurveFull:AddPoint(0.1, CreateColor(1, 0.2, 0.2, 1));
		sAuraTimerColorCurveFull:AddPoint(4.9, CreateColor(1, 1, 1, 1));
	end

	VUHDO_auraContainerOverlaysInitLocalOverrides();

	return;

end



--
local tColorCurve;
function VUHDO_getAuraTimerColorCurve(aDurationMode, aTimerThreshold)

	if aDurationMode == VUHDO_SPELL_DURATION_MODE_FULL then
		return sAuraTimerColorCurveFull;
	end

	tColorCurve = sAuraTimerColorCurvesByThreshold[aTimerThreshold];

	if not tColorCurve then
		tColorCurve = CreateColorCurve();
		tColorCurve:SetType(Enum.LuaCurveType.Step);

		tColorCurve:AddPoint(0, CreateColor(1, 1, 1, 0));
		tColorCurve:AddPoint(0.1, CreateColor(1, 0.2, 0.2, 1));
		tColorCurve:AddPoint(4.9, CreateColor(1, 1, 1, 1));
		tColorCurve:AddPoint((aTimerThreshold or 9.99) + 0.01, CreateColor(1, 1, 1, 0));

		sAuraTimerColorCurvesByThreshold[aTimerThreshold] = tColorCurve;
	end

	return tColorCurve;

end



--
local tTextConfig;
local tTextParent;
local tTextSize;
local function VUHDO_applyAuraButtonText(anButtonSetup, aAuraButton, aTextRegion, aFieldName)

	tTextConfig = anButtonSetup["textConfig"];

	if tTextConfig and tTextConfig[aFieldName] then
		if anButtonSetup["durationBar"] and aAuraButton["IconFrame"] and anButtonSetup["iconTextSize"] then
			tTextParent = aAuraButton["IconFrame"];
			tTextSize = anButtonSetup["iconTextSize"];
		else
			tTextParent = aAuraButton;
			tTextSize = anButtonSetup["textSize"] or 20;
		end

		VUHDO_customizeIconText(tTextParent, tTextSize, aTextRegion, tTextConfig[aFieldName]);

		aTextRegion:SetDrawLayer("OVERLAY", 3);
	end

	return;

end



--
local tIconSize;
local tBarWidth;
local tBarHeight;
local tBarVertical;
local tBarTurnAxis;
local tIconFrame;
local tDurationBar;
local tIconTexture;
local tIconColorOverlay;
local tDurationCooldown;
local tLayoutSpec;
local tDurationBarWidth;
local function VUHDO_layoutBarAuraButtonFrames(anButtonSetup, aAuraButton)

	if not anButtonSetup["durationBar"] or not aAuraButton["IconFrame"] then
		return;
	end

	if not aAuraButton:CanBeAccessedInContext() then
		sPendingButtonLayouts[aAuraButton] = anButtonSetup;

		sHasPendingBuilds = true;

		return;
	end

	tIconSize = anButtonSetup["iconTextSize"];
	tBarWidth = anButtonSetup["barSegmentWidth"];
	tBarHeight = anButtonSetup["barSegmentHeight"];
	tBarVertical = anButtonSetup["barVertical"];
	tBarTurnAxis = anButtonSetup["barTurnAxis"];
	tIconFrame = aAuraButton["IconFrame"];
	tDurationBar = aAuraButton["DurationBar"];
	tIconTexture = aAuraButton["IconTexture"];
	tIconColorOverlay = aAuraButton["IconColorOverlay"];
	tDurationCooldown = aAuraButton["DurationCooldown"];

	if (anButtonSetup["iconType"] or 1) == 5 or not tIconSize or tIconSize <= 0 then
		tIconFrame:Hide();

		if tDurationCooldown then
			tDurationCooldown:Hide();
		end

		if tDurationBar then
			tDurationBar:ClearAllPoints();
			tDurationBar:SetAllPoints(aAuraButton);
		end

		if tIconTexture then
			tIconTexture:ClearAllPoints();
			tIconTexture:SetAllPoints(aAuraButton);
		end

		if tIconColorOverlay then
			tIconColorOverlay:ClearAllPoints();
			tIconColorOverlay:SetAllPoints(aAuraButton);
		end

		return;
	end

	tIconFrame:ClearAllPoints();
	tIconFrame:Show();

	tLayoutSpec = sAuraBarIconLayouts[(tBarVertical and 2 or 0) + (tBarTurnAxis and 1 or 0)];

	VUHDO_PixelUtil.SetPoint(tIconFrame, tLayoutSpec["iconPoint"], aAuraButton, tLayoutSpec["iconPoint"], 0, 0);
	VUHDO_PixelUtil.SetSize(tIconFrame, tIconSize, tIconSize);

	if tDurationBar then
		tDurationBarWidth = tLayoutSpec["useBarWidth"] and tBarWidth or tIconSize;

		tDurationBar:ClearAllPoints();

		VUHDO_PixelUtil.SetPoint(tDurationBar, tLayoutSpec["barPoint"], tIconFrame, tLayoutSpec["barRelPoint"], 0, 0);
		VUHDO_PixelUtil.SetSize(tDurationBar, tDurationBarWidth, tBarHeight);
	end

	if tIconTexture then
		tIconTexture:ClearAllPoints();
		tIconTexture:SetAllPoints(tIconFrame);
	end

	if tIconColorOverlay then
		tIconColorOverlay:ClearAllPoints();
		tIconColorOverlay:SetAllPoints(tIconFrame);
	end

	if tDurationCooldown then
		tDurationCooldown:ClearAllPoints();
		tDurationCooldown:SetAllPoints(tIconFrame);
		tDurationCooldown:Show();
	end

	if (anButtonSetup["iconType"] or 1) == 4 and tDurationBar then
		tDurationBar:ClearAllPoints();
		tDurationBar:SetAllPoints(aAuraButton);
	end

	if anButtonSetup["dispelBorder"] then
		VUHDO_bindAuraButtonDispelBorder(aAuraButton);
	elseif not anButtonSetup["dispelOverlayChrome"] then
		VUHDO_unbindAuraButtonDispelBorder(aAuraButton);
	end

	return;

end



do
	--
	local tSlot;
	function VUHDO_applyAuraButtonSublevelSlot(aTexture, anButtonSetup, anIndex, aFallbackLayer, aFallbackSublevel)

		if not aTexture then
			return;
		end

		tSlot = anButtonSetup["sublevelSlots"] and anButtonSetup["sublevelSlots"][anIndex];

		if tSlot then
			aTexture:SetDrawLayer(tSlot["layer"], tSlot["sublevel"]);
		else
			aTexture:SetDrawLayer(aFallbackLayer, aFallbackSublevel);
		end

		return;

	end
end



--
local tOverlayBarTextureFile;
local function VUHDO_applyOverlayBarTextureToFill(aFillTexture, aBarTextureName)

	tOverlayBarTextureFile = VUHDO_LibSharedMedia:Fetch('statusbar', aBarTextureName);

	if tOverlayBarTextureFile then
		aFillTexture:SetTexture(tOverlayBarTextureFile);

		VUHDO_PixelUtil.ApplySettings(aFillTexture);
	end

	return;

end



--
local tVolatileShadowBar;
local tVolatileShadowBackground;
local tVolatileShadowTexture;
local tVolatileFillTexture;
local tVolatileFillBackground;
local tVolatileFillMask;
local tVolatileOcclusionColor;
local tVolatileStaticColor;
local tVolatileStaticAlpha;
function VUHDO_applyAuraButtonVolatileSetup(anButtonSetup, aAuraButton)

	if not anButtonSetup or not aAuraButton or not aAuraButton["ShadowBar"] then
		return;
	end

	tVolatileShadowBar = aAuraButton["ShadowBar"];

	if anButtonSetup["shadowValueMode"] == "duration" then
		tVolatileShadowBackground = tVolatileShadowBar["ShadowBackground"];

		if anButtonSetup["barOrientation"] then
			VUHDO_setStatusBarOrientation(tVolatileShadowBar, anButtonSetup["barOrientation"]);
		end

		if anButtonSetup["barTexture"] then
			VUHDO_setLlcStatusBarTexture(tVolatileShadowBar, anButtonSetup["barTexture"]);
		end

		if anButtonSetup["barInverted"] ~= nil then
			tVolatileShadowBar["isInverted"] = anButtonSetup["barInverted"];
		end

		if tVolatileShadowBackground and anButtonSetup["occlusionColor"] then
			tVolatileOcclusionColor = anButtonSetup["occlusionColor"];
			tVolatileShadowBackground:SetColorTexture(tVolatileOcclusionColor["R"] or 0, tVolatileOcclusionColor["G"] or 0, tVolatileOcclusionColor["B"] or 0, 1);

			VUHDO_applyAuraButtonSublevelSlot(tVolatileShadowBackground, anButtonSetup, 1, "ARTWORK", 1);

			tVolatileShadowBackground:Show();
		end

		tVolatileShadowTexture = tVolatileShadowBar:GetStatusBarTexture();

		if tVolatileShadowTexture then
			if anButtonSetup["dispelFill"] then
				tVolatileShadowTexture:SetVertexColor(1, 1, 1, 1);
			elseif anButtonSetup["staticColor"] then
				tVolatileStaticColor = anButtonSetup["staticColor"];
				tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

				tVolatileShadowTexture:SetVertexColor(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, tVolatileStaticAlpha);
			end

			VUHDO_applyAuraButtonSublevelSlot(tVolatileShadowTexture, anButtonSetup, 2, "ARTWORK", 1);
		end
	else
		tVolatileFillTexture = aAuraButton["FillTexture"];

		if tVolatileFillTexture and anButtonSetup["targetBar"] then
			if not anButtonSetup["dispelFill"] then
				tVolatileFillMask = aAuraButton["VuhDoFillMask"];

				if tVolatileFillMask then
					tVolatileFillMask:ClearAllPoints();

					if anButtonSetup["shadowValueMode"] == "cover" then
						tVolatileFillMask:SetAllPoints(anButtonSetup["targetBar"]);
					else
						tVolatileFillMask:SetAllPoints(anButtonSetup["targetBar"]:GetStatusBarTexture());
					end
				end
			end

			if anButtonSetup["dispelFill"] then
				tVolatileFillBackground = aAuraButton["VuhDoFillBackground"];

				if tVolatileFillBackground then
					if anButtonSetup["dispelOpacity"] and "cover" ~= anButtonSetup["shadowValueMode"] then
						tVolatileFillBackground:Hide();
					else
						VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);
						tVolatileFillBackground:Show();
					end
				end

				VUHDO_copyStatusBarFillTexture(tVolatileFillTexture, anButtonSetup["targetBar"]);

				if anButtonSetup["barTexture"] then
					VUHDO_applyOverlayBarTextureToFill(tVolatileFillTexture, anButtonSetup["barTexture"]);
				end

				tVolatileFillTexture:SetVertexColor(1, 1, 1, 1);

				VUHDO_applyAuraButtonSublevelSlot(tVolatileFillTexture, anButtonSetup, 2, "ARTWORK", 1);
			else
				tVolatileFillBackground = aAuraButton["VuhDoFillBackground"];

				if tVolatileFillBackground then
					if anButtonSetup["staticColor"] then
						tVolatileStaticColor = anButtonSetup["staticColor"];
						tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

						if tVolatileStaticAlpha < 1 then
							tVolatileFillBackground:Hide();
						else
							tVolatileFillBackground:SetColorTexture(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, 1);

							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);

							tVolatileFillBackground:Show();
						end
					elseif anButtonSetup["occlusionColor"] then
						tVolatileOcclusionColor = anButtonSetup["occlusionColor"];
						tVolatileFillBackground:SetColorTexture(tVolatileOcclusionColor["R"] or 0, tVolatileOcclusionColor["G"] or 0, tVolatileOcclusionColor["B"] or 0, 1);

						VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);

						tVolatileFillBackground:Show();
					else
						tVolatileFillBackground:SetColorTexture(0, 0, 0, 1);

						VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);

						tVolatileFillBackground:Show();
					end
				end

				VUHDO_copyStatusBarFillTexture(tVolatileFillTexture, anButtonSetup["targetBar"]);

				if anButtonSetup["barTexture"] then
					VUHDO_applyOverlayBarTextureToFill(tVolatileFillTexture, anButtonSetup["barTexture"]);
				end

				if anButtonSetup["staticColor"] then
					tVolatileStaticColor = anButtonSetup["staticColor"];
					tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

					tVolatileFillTexture:SetVertexColor(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, tVolatileStaticAlpha);
				end

				VUHDO_applyAuraButtonSublevelSlot(tVolatileFillTexture, anButtonSetup, 2, "ARTWORK", 1);
			end
		end
	end

	if anButtonSetup["targetFrame"] then
		if anButtonSetup["shadowValueMode"] == "duration" then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrame"]:GetFrameLevel() + 1);
			VUHDO_PixelUtil.SetFrameLevel(tVolatileShadowBar, anButtonSetup["targetFrame"]:GetFrameLevel());
		else
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrame"]:GetFrameLevel());
		end
	end

	return;

end



do
	--
	local function VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup)

		sBorderEdgeTop = aAuraButton["BorderEdgeTop"];
		sBorderEdgeBottom = aAuraButton["BorderEdgeBottom"];
		sBorderEdgeLeft = aAuraButton["BorderEdgeLeft"];
		sBorderEdgeRight = aAuraButton["BorderEdgeRight"];

		if not sBorderEdgeTop or not sBorderEdgeBottom or not sBorderEdgeLeft or not sBorderEdgeRight then
			return false;
		end

		sBorderWidth = (anButtonSetup and anButtonSetup["borderWidth"]) or 1;
		sBorderFile = (anButtonSetup and anButtonSetup["borderFile"]) or "Interface\\AddOns\\VuhDo\\Images\\white_square_16_16";

		sBorderEdgeTop:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeTop, "TOPLEFT", aAuraButton, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeTop, "TOPRIGHT", aAuraButton, "TOPRIGHT", 0, 0);
		sBorderEdgeTop:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetHeight(sBorderEdgeTop, sBorderWidth, 1);

		sBorderEdgeBottom:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeBottom, "BOTTOMLEFT", aAuraButton, "BOTTOMLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeBottom, "BOTTOMRIGHT", aAuraButton, "BOTTOMRIGHT", 0, 0);
		sBorderEdgeBottom:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetHeight(sBorderEdgeBottom, sBorderWidth, 1);

		sBorderEdgeLeft:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeLeft, "TOPLEFT", aAuraButton, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeLeft, "BOTTOMLEFT", aAuraButton, "BOTTOMLEFT", 0, 0);
		sBorderEdgeLeft:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetWidth(sBorderEdgeLeft, sBorderWidth, 1);

		sBorderEdgeRight:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeRight, "TOPRIGHT", aAuraButton, "TOPRIGHT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeRight, "BOTTOMRIGHT", aAuraButton, "BOTTOMRIGHT", 0, 0);
		sBorderEdgeRight:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetWidth(sBorderEdgeRight, sBorderWidth, 1);

		sBorderEdgeTop:SetDrawLayer("OVERLAY", 7);
		sBorderEdgeBottom:SetDrawLayer("OVERLAY", 7);
		sBorderEdgeLeft:SetDrawLayer("OVERLAY", 7);
		sBorderEdgeRight:SetDrawLayer("OVERLAY", 7);

		sBorderEdgeTop:Show();
		sBorderEdgeBottom:Show();
		sBorderEdgeLeft:Show();
		sBorderEdgeRight:Show();

		return true;

	end



	--
	function VUHDO_applyAuraButtonDispelBorder(aAuraButton, anButtonSetup)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup) then
			return;
		end

		sAuraBorderOptions["customDispelColorCurve"] = nil;
		sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

		aAuraButton:AddDispelTypeTexture(sBorderEdgeTop, sAuraBorderOptions);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeBottom, sAuraBorderOptions);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeLeft, sAuraBorderOptions);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeRight, sAuraBorderOptions);

		if anButtonSetup["targetFrame"] then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrame"]:GetFrameLevel());
		end

		return;

	end



	--
	function VUHDO_applyAuraButtonStaticBorder(aAuraButton, anButtonSetup)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
			aAuraButton:ClearDispelTypeTextures();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup) then
			return;
		end

		sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO = VUHDO_backColorWithFallback(anButtonSetup["staticColor"]);

		sBorderEdgeTop:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		sBorderEdgeBottom:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		sBorderEdgeLeft:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		sBorderEdgeRight:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);

		if anButtonSetup["targetFrame"] then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrame"]:GetFrameLevel());
		end

		return;

	end



	--
	function VUHDO_hideAuraButtonBorder(aAuraButton)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		sBorderEdgeTop = aAuraButton["BorderEdgeTop"];

		if sBorderEdgeTop then
			sBorderEdgeTop:Hide();
		end

		sBorderEdgeBottom = aAuraButton["BorderEdgeBottom"];

		if sBorderEdgeBottom then
			sBorderEdgeBottom:Hide();
		end

		sBorderEdgeLeft = aAuraButton["BorderEdgeLeft"];

		if sBorderEdgeLeft then
			sBorderEdgeLeft:Hide();
		end

		sBorderEdgeRight = aAuraButton["BorderEdgeRight"];

		if sBorderEdgeRight then
			sBorderEdgeRight:Hide();
		end

		return;

	end



	--
	local tGradientTexture;
	function VUHDO_applyDispelOverlayGradientTexture(aAuraButton, anButtonSetup, aBorderOptions)

		tGradientTexture = aAuraButton["GradientTexture"];

		if not tGradientTexture then
			return;
		end

		SetTextureWithAddressModeOptions(tGradientTexture, "_RaidFrame-Dispel-Highlight-Horizontal", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeClamp);

		tGradientTexture:SetTexCoord(0, 1, 0, 1);

		aBorderOptions["customDispelColorCurve"] = nil;
		aBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"]);

		aAuraButton:AddDispelTypeTexture(tGradientTexture, aBorderOptions);

		return;

	end
end



do
	--
	local tMainTexture;
	local tStaticColor;
	local tBarColor;
	local tIconColor;
	local tShadowBar;
	local tShadowTexture;
	local tFillTexture;
	local tFillMask;
	local tFillBackground;
	local tTexCoords;
	local tDispelIconTexture;
	local tTextOverlayFrame;
	local tBarNoIconTexts;
	function VUHDO_applyAuraButtonSetup(anButtonSetup, aAuraButton)

	if not anButtonSetup then
		return;
	end

	tTextOverlayFrame = aAuraButton["TextOverlayFrame"];

	if tTextOverlayFrame then
		aAuraButton["SymbolText"] = tTextOverlayFrame["SymbolText"];
		aAuraButton["TimerText"] = tTextOverlayFrame["TimerText"];
		aAuraButton["CountText"] = tTextOverlayFrame["CountText"];
	end

	tBarNoIconTexts = anButtonSetup["durationBar"] and (anButtonSetup["iconType"] or 1) == 5;

	tMainTexture = aAuraButton["IconTexture"] or aAuraButton["FillTexture"];

	if anButtonSetup["hideIcon"] then
		if tMainTexture then
			tMainTexture:Hide();
		end
	elseif anButtonSetup["staticIcon"] then
		if tMainTexture then
			if VUHDO_ATLAS_TEXTURES[anButtonSetup["staticIcon"]] then
				tMainTexture:SetAtlas(anButtonSetup["staticIcon"]);
			else
				tMainTexture:SetTexture(anButtonSetup["staticIcon"]);
			end

			if anButtonSetup["iconTexCoords"] then
				tTexCoords = anButtonSetup["iconTexCoords"];

				tMainTexture:SetTexCoord(tTexCoords[1] or 0, tTexCoords[2] or 1, tTexCoords[3] or 0, tTexCoords[4] or 1);
			elseif not VUHDO_ATLAS_TEXTURES[anButtonSetup["staticIcon"]] then
				tMainTexture:SetTexCoord(0, 1, 0, 1);
			end

			tMainTexture:Show();

			tMainTexture:SetVertexColor(1, 1, 1, 1);
		end
	elseif aAuraButton["IconTexture"] then
		aAuraButton:SetIcon(aAuraButton["IconTexture"]);
	end

	if anButtonSetup["staticColor"] and tMainTexture and not anButtonSetup["shadowBar"] and not anButtonSetup["border"] then
		tStaticColor = anButtonSetup["staticColor"];

		if anButtonSetup["staticIcon"] then
			tMainTexture:SetVertexColor(tStaticColor["R"] or 1, tStaticColor["G"] or 1, tStaticColor["B"] or 1, tStaticColor["O"] or 1);
		else
			tMainTexture:SetColorTexture(tStaticColor["R"] or 1, tStaticColor["G"] or 1, tStaticColor["B"] or 1, tStaticColor["O"] or 1);
		end

		tMainTexture:Show();
	end

	if aAuraButton["IconTexture"] then
		if anButtonSetup["iconColor"] then
			tIconColor = anButtonSetup["iconColor"];

			aAuraButton["IconColorOverlay"]:SetColorTexture(tIconColor["R"] or 1, tIconColor["G"] or 1, tIconColor["B"] or 1, 1);
			aAuraButton["IconColorOverlay"]:Show();
		else
			aAuraButton["IconColorOverlay"]:Hide();
		end
	end

	if anButtonSetup["shadowBar"] and aAuraButton["ShadowBar"] then
		tShadowBar = aAuraButton["ShadowBar"];

		if anButtonSetup["shadowValueMode"] == "duration" then
			if aAuraButton["FillTexture"] then
				aAuraButton["FillTexture"]:Hide();
			end

			VUHDO_applyAuraButtonVolatileSetup(anButtonSetup, aAuraButton);

			if anButtonSetup["dispelFill"] then
				tShadowTexture = tShadowBar:GetStatusBarTexture();

				if tShadowTexture then
					tShadowTexture:SetVertexColor(1, 1, 1, 1);

					sAuraOpaqueBorderOptions["customDispelColorCurve"] = nil;

					if anButtonSetup["dispelOpacity"] then
						sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);
					else
						sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(anButtonSetup["dispelBright"]);
					end

					aAuraButton:ClearDispelTypeTextures();

					aAuraButton:AddDispelTypeTexture(tShadowTexture, sAuraOpaqueBorderOptions);
				end
			end

			if anButtonSetup["barInverted"] then
				sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.ElapsedTime;
			else
				sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.RemainingTime;
			end

			aAuraButton:SetDurationBar(tShadowBar, sAuraDurationBarOptions);

			tShadowBar["isDuration"] = true;

			tShadowBar:Show();
		else
			tShadowBar:Hide();

			tFillTexture = aAuraButton["FillTexture"];

			if tFillTexture and anButtonSetup["targetBar"] then
				tFillTexture:ClearAllPoints();
				tFillTexture:SetAllPoints(aAuraButton);

				tFillMask = aAuraButton["VuhDoFillMask"];

				if not tFillMask then
					tFillMask = aAuraButton:CreateMaskTexture();
					aAuraButton["VuhDoFillMask"] = tFillMask;

					tFillTexture:AddMaskTexture(tFillMask);
					tFillMask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");

					if anButtonSetup["shadowValueMode"] == "cover" then
						tFillMask:SetAllPoints(anButtonSetup["targetBar"]);
					else
						tFillMask:SetAllPoints(anButtonSetup["targetBar"]:GetStatusBarTexture());
					end
				end

				if anButtonSetup["dispelFill"] then
					tFillBackground = aAuraButton["VuhDoFillBackground"];

					if not tFillBackground then
						tFillBackground = aAuraButton:CreateTexture(nil, "ARTWORK");
						aAuraButton["VuhDoFillBackground"] = tFillBackground;

						tFillBackground:AddMaskTexture(tFillMask);
					end

					tFillBackground:ClearAllPoints();
					tFillBackground:SetAllPoints(aAuraButton);

					tFillBackground:SetTexture("Interface\\Buttons\\WHITE8X8");
				elseif anButtonSetup["staticColor"] then
					tFillBackground = aAuraButton["VuhDoFillBackground"];

					if not tFillBackground then
						tFillBackground = aAuraButton:CreateTexture(nil, "ARTWORK");
						aAuraButton["VuhDoFillBackground"] = tFillBackground;

						tFillBackground:AddMaskTexture(tFillMask);
					end

					tFillBackground:ClearAllPoints();
					tFillBackground:SetAllPoints(aAuraButton);
				end

				VUHDO_applyAuraButtonVolatileSetup(anButtonSetup, aAuraButton);

				if anButtonSetup["dispelFill"] then
					tFillBackground = aAuraButton["VuhDoFillBackground"];

					aAuraButton:ClearDispelTypeTextures();

					if "cover" == anButtonSetup["shadowValueMode"] then
						sAuraOpaqueBorderOptions["customDispelColorMap"] = nil;
						sAuraOpaqueBorderOptions["customDispelColorCurve"] = sAuraOpaqueBorderOptions["backingCurveFn"](anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

						if tFillBackground then
							aAuraButton:AddDispelTypeTexture(tFillBackground, sAuraOpaqueBorderOptions);
						end

						sAuraOpaqueBorderOptions["customDispelColorCurve"] = sAuraOpaqueBorderOptions["fillCurveFn"](anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

						aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraOpaqueBorderOptions);
					elseif anButtonSetup["dispelOpacity"] then
						sAuraBorderOptions["customDispelColorCurve"] = nil;
						sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

						aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraBorderOptions);
					else
						sAuraOpaqueBorderOptions["customDispelColorCurve"] = nil;
						sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(anButtonSetup["dispelBright"]);

						if tFillBackground then
							aAuraButton:AddDispelTypeTexture(tFillBackground, sAuraOpaqueBorderOptions);
						end

						aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraOpaqueBorderOptions);
					end
				end

				tFillTexture:Show();
			end
		end
	end

	if not anButtonSetup["dispelOverlayChrome"] then
		if anButtonSetup["dispelBorder"] then
			if aAuraButton["IconTexture"] then
				VUHDO_bindAuraButtonDispelBorder(aAuraButton);
			else
				if not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
					aAuraButton:ClearDispelTypeTextures();
				end

				VUHDO_applyAuraButtonDispelBorder(aAuraButton, anButtonSetup);
			end
		elseif anButtonSetup["border"] then
			VUHDO_applyAuraButtonStaticBorder(aAuraButton, anButtonSetup);
		elseif aAuraButton["IconTexture"] then
			VUHDO_unbindAuraButtonDispelBorder(aAuraButton);
		elseif not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
			aAuraButton:ClearDispelTypeTextures();

			VUHDO_hideAuraButtonBorder(aAuraButton);
		end
	end

	if anButtonSetup["dispelOverlayChrome"] then
		if not anButtonSetup["auraGroupBarGlow"] then
			aAuraButton:ClearDispelTypeTextures();
		end

		tFillTexture = aAuraButton["FillTexture"];

		if tFillTexture then
			tFillTexture:SetVertexColor(1, 1, 1, 1);
			tFillTexture:SetAlpha(0.2);
		end

		VUHDO_applyDispelOverlayGradientTexture(aAuraButton, anButtonSetup, sAuraBorderOptions);

		if aAuraButton["BorderTexture"] then
			sAuraBorderOptions["customDispelColorCurve"] = nil;
			sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"]);

			aAuraButton:AddDispelTypeTexture(aAuraButton["BorderTexture"], sAuraBorderOptions);
		end

		tDispelIconTexture = aAuraButton["DispelIconTexture"];

		if tDispelIconTexture then
			aAuraButton:AddDispelTypeTexture(tDispelIconTexture, sDispelOverlayIconOptions);
		end
	end

	if anButtonSetup["auraSymbol"] and aAuraButton["SymbolText"] then
		aAuraButton:SetDispelTypeText(aAuraButton["SymbolText"], sAuraSymbolOptions);
	end

	if anButtonSetup["durationBar"] and (anButtonSetup["iconType"] or 1) == 5 then
		aAuraButton:ClearDurationCooldown();

		if aAuraButton["DurationCooldown"] then
			aAuraButton["DurationCooldown"]:Hide();
		end
	elseif anButtonSetup["durationCooldown"] and aAuraButton["DurationCooldown"] then
		aAuraButton["DurationCooldown"]:SetHideCountdownNumbers(true);

		aAuraButton:SetDurationCooldown(aAuraButton["DurationCooldown"]);
	elseif not anButtonSetup["durationCooldown"] then
		aAuraButton:ClearDurationCooldown();
	end

	if anButtonSetup["durationBar"] and aAuraButton["DurationBar"] then
		if anButtonSetup["durationBarOrientation"] then
			VUHDO_setStatusBarOrientation(aAuraButton["DurationBar"], anButtonSetup["durationBarOrientation"]);
		end

		if anButtonSetup["barTexture"] then
			VUHDO_setLlcStatusBarTexture(aAuraButton["DurationBar"], anButtonSetup["barTexture"]);
		end

		if anButtonSetup["barColor"] then
			tBarColor = anButtonSetup["barColor"];

			aAuraButton["DurationBar"]:GetStatusBarTexture():SetVertexColor(tBarColor["R"] or 0.2, tBarColor["G"] or 0.6, tBarColor["B"] or 0.2, tBarColor["O"] or 1);
		end

		aAuraButton:SetDurationBar(aAuraButton["DurationBar"], anButtonSetup["durationBarOptions"] or sEmpty);

		if tTextOverlayFrame then
			tTextOverlayFrame:SetFrameLevel(aAuraButton["DurationBar"]:GetFrameLevel() + 1);
		end

		VUHDO_layoutBarAuraButtonFrames(anButtonSetup, aAuraButton);
	end

	if not tBarNoIconTexts and anButtonSetup["durationText"] and aAuraButton["TimerText"] then
		VUHDO_applyAuraButtonText(anButtonSetup, aAuraButton, aAuraButton["TimerText"], "TIMER_TEXT");

		aAuraButton:SetDurationText(aAuraButton["TimerText"], anButtonSetup["durationTextOptions"] or sEmpty);
	elseif tBarNoIconTexts or not anButtonSetup["durationText"] then
		aAuraButton:ClearDurationText();
	end

	if not tBarNoIconTexts and anButtonSetup["applicationCount"] and aAuraButton["CountText"] then
		VUHDO_applyAuraButtonText(anButtonSetup, aAuraButton, aAuraButton["CountText"], "COUNTER_TEXT");

		aAuraButton:SetApplicationCount(aAuraButton["CountText"], sEmpty);
	elseif tBarNoIconTexts or not anButtonSetup["applicationCount"] then
		aAuraButton:ClearApplicationCount();
	end

	if anButtonSetup["width"] and anButtonSetup["height"] then
		VUHDO_PixelUtil.SetSize(aAuraButton, anButtonSetup["width"], anButtonSetup["height"]);
	end

	aAuraButton:SetMouseClickEnabled(false);

	if anButtonSetup["disableMouse"] then
		aAuraButton:EnableMouse(false);
		aAuraButton:SetMouseClickEnabled(false);
		aAuraButton:SetMouseMotionEnabled(false);
	elseif anButtonSetup["mouseMotion"] == false then
		aAuraButton:SetMouseMotionEnabled(false);
	else
		aAuraButton:EnableMouse(true);
		aAuraButton:SetMouseMotionEnabled(true);
		aAuraButton:SetMouseClickEnabled(false);
	end

	if anButtonSetup["glowIcon"] then
		VUHDO_startAuraButtonGlow(aAuraButton, anButtonSetup);
	else
		VUHDO_stopAuraButtonGlow(aAuraButton);
	end

	if anButtonSetup["auraGroupBarGlow"] then
		VUHDO_applyAuraGroupBarGlowFromAuraButton(aAuraButton, anButtonSetup);
	else
		VUHDO_stopAuraButtonAuraGroupBarGlow(aAuraButton);

		aAuraButton["vuhdoAuraGroupBarGlowActive"] = nil;
	end

	return;

end

end



--
local function VUHDO_registerContainerClassColorBar(aContainer, aDurationBar)

	if not aContainer or not aDurationBar then
		return;
	end

	if not sContainerClassColorBars[aContainer] then
		sContainerClassColorBars[aContainer] = { };
	end

	for tCnt = 1, #sContainerClassColorBars[aContainer] do
		if sContainerClassColorBars[aContainer][tCnt] == aDurationBar then
			return;
		end
	end

	tinsert(sContainerClassColorBars[aContainer], aDurationBar);

	return;

end



--
local tClassColorBars;
local tClassColor;
local tClassColorBar;
local function VUHDO_applyContainerClassColorBars(aContainer, aUnit)

	tClassColorBars = sContainerClassColorBars[aContainer];

	if not tClassColorBars or not aUnit or not VUHDO_RAID[aUnit] then
		return;
	end

	tClassColor = VUHDO_getClassColor(VUHDO_RAID[aUnit]);

	if not tClassColor then
		return;
	end

	for tCnt = 1, #tClassColorBars do
		tClassColorBar = tClassColorBars[tCnt];

		if tClassColorBar:CanBeAccessedInContext() then
			tClassColorBar:GetStatusBarTexture():SetVertexColor(tClassColor["R"], tClassColor["G"], tClassColor["B"], 1);
		else
			sPendingClassColors[aContainer] = aUnit;

			sHasPendingBuilds = true;
		end
	end

	return;

end



--
local tButtonSetup;
function VUHDO_buildAuraButtonInitializer(aTemplateRef, aContainer)

	return function(aAuraButton)

		tButtonSetup = aTemplateRef["template"]["buttonSetup"];

		VUHDO_applyAuraButtonSetup(tButtonSetup, aAuraButton);

		if "class" == tButtonSetup["barColorMode"] and aAuraButton["DurationBar"] then
			VUHDO_registerContainerClassColorBar(aContainer, aAuraButton["DurationBar"]);
		end

		return;

	end;

end



do
	--
	local tGroupTemplate;
	local tFrameIndex;
	local tParentButton;
	local tFixedAnchorConfig;
	local tFixedAnchor;
	local tFixedRelPoint;
	local tFixedX;
	local tFixedY;
	local tSlotTemplate;
	local tSlotButtonSetup;
	local tSlotContainerLevel;
	local tSlotFrameLevelOffset;
	local tSlotAnchor;
	local tSlotRelPoint;
	function VUHDO_buildAuraFixedGroupButtonInitializer(aTemplateRef, aContainer)

		return function(aAuraButton)

			tGroupTemplate = aTemplateRef["template"];
			tButtonSetup = tGroupTemplate["buttonSetup"];

			VUHDO_applyAuraButtonSetup(tButtonSetup, aAuraButton);

			if "class" == tButtonSetup["barColorMode"] and aAuraButton["DurationBar"] then
				VUHDO_registerContainerClassColorBar(aContainer, aAuraButton["DurationBar"]);
			end

			tFrameIndex = (aTemplateRef["nextFixedFrameIndex"] or 0) + 1;
			aTemplateRef["nextFixedFrameIndex"] = tFrameIndex;

			tParentButton = aContainer:GetParent();

			tFixedAnchorConfig = tGroupTemplate["fixedAnchorConfig"];

			tFixedAnchor, tFixedRelPoint, tFixedX, tFixedY = VUHDO_resolveFixedAuraSlotPlacement(
				tGroupTemplate["fixedRadioValue"],
				tFrameIndex,
				tGroupTemplate["fixedBarWidth"],
				tGroupTemplate["fixedBarHeight"],
				tFixedAnchorConfig,
				tParentButton,
				tGroupTemplate["fixedIconSize"]
			);

			if tFixedAnchor then
				aAuraButton:ClearAllPoints();

				VUHDO_PixelUtil.SetPoint(aAuraButton, tFixedAnchor, aContainer, tFixedRelPoint, tFixedX or 0, tFixedY or 0);
				VUHDO_PixelUtil.SetSize(aAuraButton, tGroupTemplate["layout"] and tGroupTemplate["layout"]["elementWidth"] or 20, tGroupTemplate["layout"] and tGroupTemplate["layout"]["elementHeight"] or 20);
			end

			return;

		end;

	end



	--
	function VUHDO_buildAuraSlotButtonInitializer(aTemplateRef, aContainer, anAnchorPoint)

		return function(aAuraButton)

			tSlotTemplate = aTemplateRef["template"];
			tSlotButtonSetup = tSlotTemplate["buttonSetup"];

			VUHDO_applyAuraButtonSetup(tSlotButtonSetup, aAuraButton);

			if "class" == tSlotButtonSetup["barColorMode"] and aAuraButton["DurationBar"] then
				VUHDO_registerContainerClassColorBar(aContainer, aAuraButton["DurationBar"]);
			end

			tSlotAnchor = tSlotTemplate["anchor"] or anAnchorPoint;
			tSlotRelPoint = tSlotTemplate["relPoint"] or tSlotAnchor;

			aAuraButton:ClearAllPoints();

			VUHDO_PixelUtil.SetPoint(aAuraButton, tSlotAnchor, aContainer, tSlotRelPoint, tSlotTemplate["x"] or 0, tSlotTemplate["y"] or 0);
			VUHDO_PixelUtil.SetSize(aAuraButton, tSlotTemplate["width"] or 20, tSlotTemplate["height"] or 20);

			tSlotContainerLevel = aTemplateRef["containerLevel"];
			tSlotFrameLevelOffset = tSlotButtonSetup["frameLevelOffset"];

			if tSlotFrameLevelOffset and tSlotContainerLevel then
				VUHDO_PixelUtil.SetFrameLevel(aAuraButton, tSlotContainerLevel + tSlotFrameLevelOffset);
			end

			return;

		end;

	end
end



--
local function VUHDO_pixelSnapCoverFrame(aFrame, aTargetFrame)

	VUHDO_PixelUtil.ClearAllPoints(aFrame);
	VUHDO_PixelUtil.SetPoint(aFrame, "TOPLEFT", aTargetFrame, "TOPLEFT", 0, 0);
	VUHDO_PixelUtil.SetPoint(aFrame, "TOPRIGHT", aTargetFrame, "TOPRIGHT", 0, 0);
	VUHDO_PixelUtil.SetPoint(aFrame, "BOTTOMLEFT", aTargetFrame, "BOTTOMLEFT", 0, 0);
	VUHDO_PixelUtil.SetPoint(aFrame, "BOTTOMRIGHT", aTargetFrame, "BOTTOMRIGHT", 0, 0);

	return;

end



--
local tMode;
local tRelFrame;
local tRelPoint;
local tYOff;
local tLevelBase;
local tOffsetX;
local tOffsetY;
local function VUHDO_applyAuraContainerAnchor(aContainer, anAnchor, aParent)

	aContainer:ClearAllPoints();

	if not anAnchor then
		aContainer:SetAllPoints(aParent);

		return;
	end

	tMode = anAnchor["mode"];

	if tMode == "healthBarCover" then
		tRelFrame = VUHDO_getHealthBar(aParent, 3) or aParent;
		tOffsetX = anAnchor["offsetX"] or 0;
		tOffsetY = anAnchor["offsetY"] or 0;

		VUHDO_PixelUtil.SetPoint(aContainer, "TOPLEFT", tRelFrame, "TOPLEFT", tOffsetX, tOffsetY);
		VUHDO_PixelUtil.SetPoint(aContainer, "BOTTOMRIGHT", tRelFrame, "BOTTOMRIGHT", tOffsetX, tOffsetY);
	elseif tMode == "anchorpos" and anAnchor["points"] then
		for _, tPoint in ipairs(anAnchor["points"]) do
			if tPoint["relFrame"] == "HealthBar" then
				tRelFrame = VUHDO_getHealthBar(aParent, 3);
			else
				tRelFrame = aParent;
			end

			if not tRelFrame then
				tRelFrame = aParent;
			end

			tYOff = tPoint["y"] or 0;

			if tPoint["relFrame"] == "HealthBar" then
				tRelPoint = tPoint["relativePoint"] or tPoint["point"] or "TOPLEFT";

				tYOff = VUHDO_getManaAdjustedYOffset(aParent, tRelPoint, tYOff);
			end

			VUHDO_PixelUtil.SetPoint(aContainer, tPoint["point"] or "TOPLEFT", tRelFrame, tPoint["relativePoint"] or tPoint["point"] or "TOPLEFT", tPoint["x"] or 0, tYOff);
		end
	elseif tMode == "topEdge" then
		VUHDO_PixelUtil.SetPoint(aContainer, "TOPLEFT", anAnchor["target"] or aParent, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(aContainer, "TOPRIGHT", anAnchor["target"] or aParent, "TOPRIGHT", 0, 0);
	else
		if not InCombatLockdown() then
			VUHDO_pixelSnapCoverFrame(aContainer, anAnchor["target"] or aParent);
		end
	end

	if anAnchor["frameLevelOffset"] then
		tLevelBase = anAnchor["levelBase"] or aParent;

		aContainer:SetFrameLevel(tLevelBase:GetFrameLevel() + anAnchor["frameLevelOffset"]);
	end

	return;

end



do
	--
	local tStaticSlots;
	local tStaticSlotEntry;
	local tStaticSlotKey;
	function VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate)

		tStaticSlots = { };

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			if tSlot["isStaticBouquetSlot"] then
				tStaticSlotEntry = {
					["bouquetName"] = tSlot["bouquetName"],
					["entryIndex"] = tSlot["entryIndex"],
					["slotIndex"] = tSlot["entryIndex"],
					["itemIndex"] = tSlot["itemIndex"],
					["isMixedBouquetItem"] = tSlot["isMixedBouquetItem"],
					["frameLevelOffset"] = tSlot["frameLevelOffset"] or (tSlot["buttonSetup"] and tSlot["buttonSetup"]["frameLevelOffset"]),
					["anchor"] = tSlot["anchor"],
					["relPoint"] = tSlot["relPoint"],
					["x"] = tSlot["x"],
					["y"] = tSlot["y"],
					["width"] = tSlot["width"],
					["height"] = tSlot["height"],
				};

				if tSlot["isMixedBouquetItem"] and tSlot["itemIndex"] then
					tStaticSlotKey = format("%d:%d", tSlot["entryIndex"], tSlot["itemIndex"]);
					tStaticSlotEntry["slotIndex"] = tStaticSlotKey;
				else
					tStaticSlotKey = tSlot["entryIndex"];
				end

				tStaticSlots[tStaticSlotKey] = tStaticSlotEntry;
			end
		end

		return tStaticSlots;

	end



	--
	function VUHDO_finalizeCachedAuraContainerTemplate(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		if not aContainerTemplate["poolKeyBase"] then
			VUHDO_computeAuraContainerPoolKeyBase(aContainerTemplate);
		end

		if not aContainerTemplate["staticSlots"] then
			aContainerTemplate["staticSlots"] = VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate);
		end

		if aContainerTemplate["usesDispelTextures"] == nil then
			aContainerTemplate["usesDispelTextures"] = VUHDO_containerTemplateUsesDispelTextures(aContainerTemplate);
		end

		return aContainerTemplate;

	end

end



do
	--
	local tOptions;
	local tTemplateRef;
	local tGroupKey;
	local function VUHDO_addAuraContainerGroup(aContainer, aGroup, aGroupKeys, aGroupRefs)

		tTemplateRef = {
			["template"] = aGroup,
		};

		if aGroupRefs then
			tinsert(aGroupRefs, tTemplateRef);
		end

		tTemplateRef["isAssistOnly"] = VUHDO_isAssistOnlyTemplate(aGroup);

		tOptions = {
			["maxFrameCount"] = aGroup["maxFrameCount"] or 5,
			["sortMethod"] = aGroup["sortMethod"] or AuraContainerSortMethod.Default,
			["sortDirection"] = aGroup["sortDir"] or AuraContainerSortDirection.Normal,
			["templateNames"] = { aGroup["templateName"] },
			["candidateFilters"] = aGroup["candidateFilters"],
			["layout"] = aGroup["layout"],
			["initializeFrame"] = aGroup["isFixedLayout"] and VUHDO_buildAuraFixedGroupButtonInitializer(tTemplateRef, aContainer) or VUHDO_buildAuraButtonInitializer(tTemplateRef, aContainer),
		};

		if aGroup["isFixedLayout"] then
			tTemplateRef["nextFixedFrameIndex"] = 0;
		end

		tGroupKey = aGroup["key"] or "aura";

		aContainer:AddAuraGroup(tGroupKey, aGroup["filterString"] or "HELPFUL", tOptions);

		if aGroupKeys then
			tinsert(aGroupKeys, tGroupKey);
		end

		return;

	end



	--
	local tTemplateRef;
	local tSlotOptions;
	local tSlotKey;
	local tAuraFrame;
	local function VUHDO_addAuraContainerSlot(aContainer, aSlot, anAnchorPoint, aSlotKeys, aSlotFrames, aSlotRefs)

		tTemplateRef = {
			["template"] = aSlot,
		};

		tTemplateRef["containerLevel"] = aContainer:GetFrameLevel();

		if aSlotRefs then
			tinsert(aSlotRefs, tTemplateRef);
		end

		tTemplateRef["isAssistOnly"] = VUHDO_isAssistOnlyTemplate(aSlot);

		tSlotOptions = {
			["templateNames"] = { aSlot["templateName"] },
			["candidateFilters"] = aSlot["candidateFilters"],
			["initializeFrame"] = VUHDO_buildAuraSlotButtonInitializer(tTemplateRef, aContainer, anAnchorPoint),
		};

		tSlotKey = aSlot["key"];

		tAuraFrame = aContainer:AddAuraSlot(tSlotKey, aSlot["filterString"] or "HELPFUL", tSlotOptions);

		if aSlotKeys then
			tinsert(aSlotKeys, tSlotKey);
		end

		if aSlotFrames and tSlotKey and tAuraFrame then
			aSlotFrames[tSlotKey] = tAuraFrame;
		end

		return tAuraFrame;

	end



	--
	local tChainTargetBar;
	local tChainBaselineFrame;
	local tChainBaselineMask;
	local tChainBaselineTexture;
	local tChainTargetTexture;
	local tChainButtonName;
	local tChainStoredBaselineColor;
	function VUHDO_setupOverlayFillChain(aContainer, aContainerTemplate, aContainerData)

		if not aContainer or not aContainerTemplate or not aContainerTemplate["isFillChain"] then
			return;
		end

		tChainTargetBar = aContainerTemplate["overlayTargetBar"];

		if not tChainTargetBar then
			return;
		end

		if aContainerTemplate["chainHasBaseline"] then
			tChainBaselineFrame = aContainer["ChainBaselineFrame"];
			tChainBaselineTexture = tChainBaselineFrame and tChainBaselineFrame["ChainBaselineTexture"];
			tChainBaselineMask = tChainBaselineFrame and tChainBaselineFrame["ChainBaselineMask"];

			if tChainBaselineFrame and tChainBaselineTexture and tChainBaselineMask then
				tChainBaselineFrame:SetParent(tChainTargetBar);
				tChainBaselineFrame:SetFrameLevel(aContainer:GetFrameLevel());

				tChainBaselineFrame:ClearAllPoints();
				tChainBaselineFrame:SetAllPoints(tChainTargetBar);

				tChainBaselineFrame:Show();
				tChainBaselineTexture:Show();

				tChainBaselineMask:ClearAllPoints();

				VUHDO_PixelUtil.SetPoint(tChainBaselineMask, "TOPLEFT", aContainer, "BOTTOMLEFT", 0, 0);
				VUHDO_PixelUtil.SetPoint(tChainBaselineMask, "BOTTOMRIGHT", tChainTargetBar, "BOTTOMRIGHT", 0, 0);

				tChainTargetTexture = tChainTargetBar:GetStatusBarTexture();

				if tChainTargetTexture then
					tChainTargetTexture:SetAlpha(0);

					aContainerData["backgroundFillHidden"] = true;
				end

				aContainerData["chainBaselineFrame"] = tChainBaselineFrame;
				aContainerData["chainBaselineTexture"] = tChainBaselineTexture;

				tChainButtonName = tChainTargetBar:GetParent() and tChainTargetBar:GetParent():GetName();

				if tChainButtonName then
					tChainStoredBaselineColor = sChainBaselineColors[tChainButtonName];

					if not tChainStoredBaselineColor and not tChainBaselineTexture:IsForbidden() then
						tChainBaselineTexture:SetColorTexture(0, 0, 0, 0);
					end
				end
			end
		end

		return;

	end



	--
	local tParent;
	local tContainer;
	local tContainerLayout;
	local tRowWidth;
	local tSlotTemplateRefs;
	local tGroupTemplateRefs;
	local tContainerData;
	local tSlotKeys;
	local tSlotFrames;
	local tGroupKeys;
	function VUHDO_buildManagedAuraContainer(aContainerTemplate)

		tParent = aContainerTemplate["parent"];
		tContainer = CreateFrame("AuraContainer", nil, tParent, aContainerTemplate["chainHasBaseline"] and VUHDO_FILL_CHAIN_CONTAINER_TEMPLATE or VUHDO_AURA_CONTAINER_TEMPLATE);

		tContainerLayout = aContainerTemplate["containerLayout"];

		if tContainerLayout and not tContainerLayout["isFixedLayout"] then
			tContainer:SetFlowLayoutAnchorPoint(tContainerLayout["anchorPoint"] or "TOPLEFT");

			tContainer:SetFlowLayoutGrowthDirection(tContainerLayout["horizontalDir"] or AnchorUtil.FlowDirection.Right, tContainerLayout["verticalDir"] or AnchorUtil.FlowDirection.Down);

			tContainer:SetFlowLayoutPadding(tContainerLayout["paddingLeft"] or 0, tContainerLayout["paddingRight"] or 0, tContainerLayout["paddingTop"] or 0, tContainerLayout["paddingBottom"] or 0);

			if tContainerLayout["elementWidth"] then
				tRowWidth = (tContainerLayout["maxColumns"] or 1) * (tContainerLayout["elementWidth"] + (tContainerLayout["spacing"] or 0));

				tContainer:SetFlowLayoutMaximumLineSize(tRowWidth);
			end
		end

		VUHDO_applyAuraContainerAnchor(tContainer, aContainerTemplate["anchor"], tParent);

		tContainer:SetMouseClickEnabled(false);

		if aContainerTemplate["isOverlay"] then
			tContainer:EnableMouse(false);
			tContainer:SetMouseMotionEnabled(false);
		end

		tSlotKeys = { };
		tSlotFrames = { };
		tGroupKeys = { };
		tSlotTemplateRefs = { };
		tGroupTemplateRefs = { };

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			VUHDO_addAuraContainerGroup(tContainer, tGroup, tGroupKeys, tGroupTemplateRefs);
		end

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			if not tSlot["isStaticBouquetSlot"] then
				VUHDO_addAuraContainerSlot(tContainer, tSlot, tContainerLayout and tContainerLayout["anchorPoint"] or "TOPLEFT", tSlotKeys, tSlotFrames, tSlotTemplateRefs);
			end
		end

		tContainer:SetEnabled(false);
		tContainer:SetShown(false);

		tContainerData = {
			["container"] = tContainer,
			["containerTemplate"] = aContainerTemplate,
			["overlayTargetBar"] = aContainerTemplate["overlayTargetBar"],
			["overlayHostFrame"] = aContainerTemplate["overlayHostFrame"],
			["slotKeys"] = tSlotKeys,
			["slotFrames"] = tSlotFrames,
			["groupKeys"] = tGroupKeys,
			["slotTemplateRefs"] = tSlotTemplateRefs,
			["groupTemplateRefs"] = tGroupTemplateRefs,
			["staticSlots"] = aContainerTemplate["staticSlots"] or VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate),
			["panelNum"] = aContainerTemplate["panelNum"],
			["anchorIndex"] = aContainerTemplate["anchorIndex"],
			["fromPool"] = false,
		};

		if VUHDO_containerTemplateUsesDispelTextures(aContainerTemplate) then
			tContainerData["dispelColorGen"] = VUHDO_getDispelColorGeneration();
		end

		if aContainerTemplate["isFillChain"] then
			VUHDO_setupOverlayFillChain(tContainer, aContainerTemplate, tContainerData);
		end

		return tContainerData;

	end

end



--
local tOverlayHostTargetBarName;
local tOverlayHostFrameName;
local tOverlayHostFrame;
function VUHDO_getOrCreateOverlayHostFrame(aButton, aTargetBar)

	if not aButton or not aTargetBar then
		return nil;
	end

	tOverlayHostTargetBarName = aTargetBar:GetName();

	if not tOverlayHostTargetBarName then
		return nil;
	end

	tOverlayHostFrameName = tOverlayHostTargetBarName .. "OlHost";
	tOverlayHostFrame = aTargetBar["VuhDoOverlayHostFrame"];

	if not tOverlayHostFrame then
		tOverlayHostFrame = _G[tOverlayHostFrameName];

		if not tOverlayHostFrame then
			tOverlayHostFrame = CreateFrame("Frame", tOverlayHostFrameName, aButton);

			tOverlayHostFrame["addLevel"] = aTargetBar["addLevel"];
		end

		aTargetBar["VuhDoOverlayHostFrame"] = tOverlayHostFrame;
	end

	if not InCombatLockdown() then
		VUHDO_pixelSnapCoverFrame(tOverlayHostFrame, aTargetBar);
	end

	return tOverlayHostFrame;

end



--
local tButtonSetup;
function VUHDO_containerTemplateUsesDispelTextures(aContainerTemplate)

	if not aContainerTemplate then
		return false;
	end

	for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
		tButtonSetup = tSlot["buttonSetup"];

		if tButtonSetup and (tButtonSetup["dispelFill"] or tButtonSetup["dispelBorder"] or tButtonSetup["dispelOverlayChrome"]) then
			return true;
		end

		if tButtonSetup and tButtonSetup["auraGroupBarGlow"] then
			if tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_DISPEL"] or tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_ALL_DISPEL"] then
				return true;
			end
		end
	end

	for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
		tButtonSetup = tGroup["buttonSetup"];

		if tButtonSetup and (tButtonSetup["dispelFill"] or tButtonSetup["dispelBorder"] or tButtonSetup["dispelOverlayChrome"]) then
			return true;
		end

		if tButtonSetup and tButtonSetup["auraGroupBarGlow"] then
			if tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_DISPEL"] or tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_ALL_DISPEL"] then
				return true;
			end
		end
	end

	return false;

end



--
do
	--
	local function VUHDO_appendPoolKeyColorComponent(aScratch, aComponent, aPrefix)

		if aComponent == nil then
			return;
		end

		if issecretvalue(aComponent) then
			tinsert(aScratch, aPrefix and (aPrefix .. "?") or "?");
		else
			tinsert(aScratch, format(aPrefix and (aPrefix .. "%.3f") or "%.3f", aComponent));
		end

		return;

	end



	--
	local tStaticColor;
	local tGlowColor;
	local tIconColor;
	local tBarColor;
	local tIconTexCoords;
	local tSublevelSlots;
	local tSublevelSlot;
	local tDurationBarOptions;
	local function VUHDO_appendAuraContainerPoolKeyExtras(aScratch, aButtonSetup)

		tinsert(aScratch, aButtonSetup["shadowValueMode"] or "");
		tinsert(aScratch, aButtonSetup["hideIcon"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["staticIcon"] or "");

		tStaticColor = aButtonSetup["staticColor"];

		if tStaticColor then
			VUHDO_appendPoolKeyColorComponent(aScratch, tStaticColor["R"], "c");
			VUHDO_appendPoolKeyColorComponent(aScratch, tStaticColor["G"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tStaticColor["B"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tStaticColor["O"], nil);
		end

		tIconColor = aButtonSetup["iconColor"];

		if tIconColor then
			VUHDO_appendPoolKeyColorComponent(aScratch, tIconColor["R"], "i");
			VUHDO_appendPoolKeyColorComponent(aScratch, tIconColor["G"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tIconColor["B"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tIconColor["O"], nil);
		end

		tBarColor = aButtonSetup["barColor"];

		if tBarColor then
			VUHDO_appendPoolKeyColorComponent(aScratch, tBarColor["R"], "bc");
			VUHDO_appendPoolKeyColorComponent(aScratch, tBarColor["G"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tBarColor["B"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tBarColor["O"], nil);
		end

		if aButtonSetup["dispelBright"] then
			tinsert(aScratch, format("b%.3f", aButtonSetup["dispelBright"]));
		end

		if aButtonSetup["dispelOpacity"] then
			tinsert(aScratch, format("o%.3f", aButtonSetup["dispelOpacity"]));
		end

		tIconTexCoords = aButtonSetup["iconTexCoords"];

		if tIconTexCoords then
			for tTexCoordCnt = 1, #tIconTexCoords do
				VUHDO_appendPoolKeyColorComponent(aScratch, tIconTexCoords[tTexCoordCnt], nil);
			end
		end

		tGlowColor = aButtonSetup["glowColor"];

		if tGlowColor then
			VUHDO_appendPoolKeyColorComponent(aScratch, tGlowColor["R"], "g");
			VUHDO_appendPoolKeyColorComponent(aScratch, tGlowColor["G"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tGlowColor["B"], nil);
			VUHDO_appendPoolKeyColorComponent(aScratch, tGlowColor["O"], nil);
		end

		if aButtonSetup["glowIcon"] then
			tinsert(aScratch, "gs" .. (aButtonSetup["glowStyle"] or ""));
		end

		if aButtonSetup["shadowBar"] and aButtonSetup["barTexture"] then
			tinsert(aScratch, aButtonSetup["barTexture"]);
			tinsert(aScratch, format("%d", aButtonSetup["barOrientation"] or 0));
			tinsert(aScratch, aButtonSetup["barInverted"] and "1" or "0");
		end

		tSublevelSlots = aButtonSetup["sublevelSlots"];

		if tSublevelSlots then
			for tSublevelCnt = 1, #tSublevelSlots do
				tSublevelSlot = tSublevelSlots[tSublevelCnt];

				if tSublevelSlot then
					tinsert(aScratch, tSublevelSlot["layer"] or "");
					tinsert(aScratch, format("%d", tSublevelSlot["sublevel"] or 0));
				end
			end
		end

		tinsert(aScratch, aButtonSetup["durationText"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["durationCooldown"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["applicationCount"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["mouseMotion"] and "1" or "0");
		tinsert(aScratch, format("%d", aButtonSetup["durationMode"] or 0));
		tinsert(aScratch, format("%d", aButtonSetup["timerThreshold"] or 0));

		tinsert(aScratch, format("%d", aButtonSetup["iconType"] or 0));
		tinsert(aScratch, aButtonSetup["barVertical"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["barTurnAxis"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["durationBar"] and "1" or "0");
		tinsert(aScratch, format("%d", aButtonSetup["durationBarOrientation"] or 0));

		tDurationBarOptions = aButtonSetup["durationBarOptions"];

		if tDurationBarOptions then
			tinsert(aScratch, format("%d", tDurationBarOptions["direction"] or 0));
		else
			tinsert(aScratch, "0");
		end

		tinsert(aScratch, format("%d", aButtonSetup["barSegmentWidth"] or 0));
		tinsert(aScratch, format("%d", aButtonSetup["barSegmentHeight"] or 0));
		tinsert(aScratch, format("%d", aButtonSetup["iconTextSize"] or 0));

		return;

	end



	local function VUHDO_appendAuraContainerPoolKeyButtonSetupCore(aScratch, aButtonSetup)

		tinsert(aScratch, aButtonSetup["shadowBar"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["dispelFill"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["dispelBorder"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["border"] and "1" or "0");
		tinsert(aScratch, format("%d", aButtonSetup["borderWidth"] or 0));
		tinsert(aScratch, aButtonSetup["borderFile"] or "");
		tinsert(aScratch, aButtonSetup["glowIcon"] and "1" or "0");
		tinsert(aScratch, aButtonSetup["dispelOverlayChrome"] and "1" or "0");

		VUHDO_appendAuraContainerPoolKeyExtras(aScratch, aButtonSetup);

	end



	--
	local tContainerLayout;
	local tParentName;
	local tButtonSetup;
	local tPoolKeyBase;
	local function VUHDO_appendAuraContainerPoolKeyToScratch(aScratch, aContainerTemplate)

		tinsert(aScratch, aContainerTemplate["isOverlay"] and "1" or "0");
		tinsert(aScratch, aContainerTemplate["isFillChain"] and "1" or "0");
		tinsert(aScratch, aContainerTemplate["chainHasBaseline"] and "1" or "0");

		if aContainerTemplate["anchor"] then
			tinsert(aScratch, aContainerTemplate["anchor"]["mode"] or "");
			tinsert(aScratch, format("%d", aContainerTemplate["anchor"]["frameLevelOffset"] or 0));
			tinsert(aScratch, format("%d", aContainerTemplate["anchor"]["offsetX"] or 0));
			tinsert(aScratch, format("%d", aContainerTemplate["anchor"]["offsetY"] or 0));
		end

		tContainerLayout = aContainerTemplate["containerLayout"];

		if tContainerLayout then
			tinsert(aScratch, tContainerLayout["isFixedLayout"] and "1" or "0");
			tinsert(aScratch, format("%d", tContainerLayout["fixedRadioValue"] or 0));
			tinsert(aScratch, tContainerLayout["useFixedSlots"] and "1" or "0");
			tinsert(aScratch, tContainerLayout["anchorPoint"] or "");
			tinsert(aScratch, format("%d", tContainerLayout["elementWidth"] or 0));
			tinsert(aScratch, format("%d", tContainerLayout["maxColumns"] or 0));
			tinsert(aScratch, format("%d", tContainerLayout["maxRows"] or 0));
			tinsert(aScratch, format("%d", tContainerLayout["spacing"] or 0));
		end

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			tinsert(aScratch, "s");
			tinsert(aScratch, tSlot["key"] or "");

			if tSlot["isStaticBouquetSlot"] then
				tinsert(aScratch, "static");
				tinsert(aScratch, tSlot["bouquetName"] or "");
				tinsert(aScratch, format("%d", tSlot["entryIndex"] or 0));
				tinsert(aScratch, format("%d", tSlot["itemIndex"] or 0));
				tinsert(aScratch, format("%d", tSlot["frameLevelOffset"] or 0));
				tinsert(aScratch, tSlot["isMixedBouquetItem"] and "1" or "0");
				tinsert(aScratch, format("%d", tSlot["x"] or 0));
				tinsert(aScratch, format("%d", tSlot["y"] or 0));

				tButtonSetup = tSlot["buttonSetup"];

				if tButtonSetup then
					tinsert(aScratch, format("%d", tButtonSetup["frameLevelOffset"] or 0));
				end
			else
				tinsert(aScratch, tSlot["templateName"] or "");
				tinsert(aScratch, tSlot["filterString"] or "");
			end

			tinsert(aScratch, format("%d", tSlot["width"] or 0));
			tinsert(aScratch, format("%d", tSlot["height"] or 0));
			tinsert(aScratch, tSlot["anchor"] or "");
			tinsert(aScratch, tSlot["relPoint"] or "");
			tinsert(aScratch, format("%d", tSlot["x"] or 0));
			tinsert(aScratch, format("%d", tSlot["y"] or 0));

			tButtonSetup = tSlot["buttonSetup"];

			if tButtonSetup and not tSlot["isStaticBouquetSlot"] then
				tinsert(aScratch, format("%d", tButtonSetup["frameLevelOffset"] or 0));

				VUHDO_appendAuraContainerPoolKeyButtonSetupCore(aScratch, tButtonSetup);
			end
		end

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			tinsert(aScratch, "g");
			tinsert(aScratch, tGroup["key"] or "");
			tinsert(aScratch, tGroup["templateName"] or "");
			tinsert(aScratch, tGroup["filterString"] or "");
			tinsert(aScratch, format("%d", tGroup["maxFrameCount"] or 0));
			tinsert(aScratch, format("%d", tGroup["sortMethod"] or 0));
			tinsert(aScratch, format("%d", tGroup["sortDir"] or 0));

			if tGroup["layout"] then
				tinsert(aScratch, format("%d", tGroup["layout"]["elementWidth"] or 0));
				tinsert(aScratch, format("%d", tGroup["layout"]["elementHeight"] or 0));
				tinsert(aScratch, tGroup["layout"]["forceNewLine"] and "1" or "0");
				tinsert(aScratch, format("%d", tGroup["layout"]["layoutIndex"] or 0));
				tinsert(aScratch, format("%d", tGroup["layout"]["groupSpacing"] or 0));
			end

			tButtonSetup = tGroup["buttonSetup"];

			if tButtonSetup then
				tinsert(aScratch, format("%d", tButtonSetup["frameLevelOffset"] or 0));
				tinsert(aScratch, tGroup["isFixedLayout"] and "1" or "0");
				tinsert(aScratch, format("%d", tGroup["fixedRadioValue"] or 0));
				tinsert(aScratch, format("%d", tGroup["fixedBarWidth"] or 0));
				tinsert(aScratch, format("%d", tGroup["fixedBarHeight"] or 0));
				tinsert(aScratch, format("%d", tGroup["fixedIconSize"] or 0));
				tinsert(aScratch, tButtonSetup["auraSymbol"] and "1" or "0");

				VUHDO_appendAuraContainerPoolKeyButtonSetupCore(aScratch, tButtonSetup);
			end
		end

		return;

	end



	--
	function VUHDO_computeAuraContainerPoolKeyBase(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		if aContainerTemplate["poolKeyBase"] then
			return aContainerTemplate["poolKeyBase"];
		end

		twipe(sPoolKeyScratch);

		VUHDO_appendAuraContainerPoolKeyToScratch(sPoolKeyScratch, aContainerTemplate);

		aContainerTemplate["poolKeyBase"] = tconcat(sPoolKeyScratch, "|");

		return aContainerTemplate["poolKeyBase"];

	end



	--
	local function VUHDO_getAuraContainerPoolKey(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		tPoolKeyBase = aContainerTemplate["poolKeyBase"] or VUHDO_computeAuraContainerPoolKeyBase(aContainerTemplate);

		if not tPoolKeyBase then
			return nil;
		end

		if aContainerTemplate["isFillChain"] and aContainerTemplate["parent"] then
			tParentName = aContainerTemplate["parent"]:GetName();

			if tParentName and _G[tParentName] then
				return tPoolKeyBase .. "|" .. tParentName;
			end
		end

		return tPoolKeyBase;

	end



	--
	local tSlotKeys;
	local tGroupKeys;
	local function VUHDO_suppressAuraContainer(aContainer, aContainerData)

		if not aContainer or not aContainerData then
			return;
		end

		tSlotKeys = aContainerData["slotKeys"];

		if tSlotKeys then
			for tSlotKeyCnt = 1, #tSlotKeys do
				aContainer:SetAuraSlotCandidateFilters(tSlotKeys[tSlotKeyCnt], sSuppressCandidateFilters);
			end
		end

		tGroupKeys = aContainerData["groupKeys"];

		if tGroupKeys then
			for tGroupKeyCnt = 1, #tGroupKeys do
				aContainer:SetAuraGroupCandidateFilters(tGroupKeys[tGroupKeyCnt], sSuppressCandidateFilters);
			end
		end

		return;

	end



	--
	local tSlotKeys;
	local tSlotTemplateRefs;
	local tSlot;
	local tRecordedKey;
	local tTemplateRef;
	local tGroupKeys;
	local tGroupTemplateRefs;
	local tGroup;
	local tEngineSlotCnt;
	local function VUHDO_restorePooledAuraContainer(aContainer, aContainerData, aContainerTemplate)

		if not aContainer or not aContainerData or not aContainerTemplate then
			return;
		end

		tSlotKeys = aContainerData["slotKeys"];
		tSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(aContainerTemplate["slots"] or sEmpty) do
			tSlot = aContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

				if tRecordedKey then
					aContainer:SetAuraSlotFilterString(tRecordedKey, tSlot["filterString"] or "HELPFUL");
					aContainer:SetAuraSlotCandidateFilters(tRecordedKey, tSlot["candidateFilters"]);

					tTemplateRef = tSlotTemplateRefs and tSlotTemplateRefs[tEngineSlotCnt];

					if tTemplateRef then
						tTemplateRef["template"] = tSlot;
						tTemplateRef["isAssistOnly"] = VUHDO_isAssistOnlyTemplate(tSlot);
					end
				end
			end
		end

		tGroupKeys = aContainerData["groupKeys"];
		tGroupTemplateRefs = aContainerData["groupTemplateRefs"];

		for tGroupCnt = 1, #(aContainerTemplate["groups"] or sEmpty) do
			tGroup = aContainerTemplate["groups"][tGroupCnt];
			tRecordedKey = tGroupKeys and tGroupKeys[tGroupCnt];

			if tGroup and tRecordedKey then
				aContainer:SetAuraGroupFilterString(tRecordedKey, tGroup["filterString"] or "HELPFUL");
				aContainer:SetAuraGroupCandidateFilters(tRecordedKey, tGroup["candidateFilters"]);

				tTemplateRef = tGroupTemplateRefs and tGroupTemplateRefs[tGroupCnt];

				if tTemplateRef then
					tTemplateRef["template"] = tGroup;
					tTemplateRef["isAssistOnly"] = VUHDO_isAssistOnlyTemplate(tGroup);
				end
			end
		end

		return;

	end



	--
	local tReleaseGroupKeys;
	local tReleaseGroupKey;
	local tReleaseGroupFrameCount;
	local tReleaseAuraFrame;
	local tReleaseSlotFrames;
	local function VUHDO_releaseAuraContainerGlowState(aContainer, aContainerData)

		if not aContainer or not aContainerData then
			return;
		end

		tReleaseGroupKeys = aContainerData["groupKeys"];

		if tReleaseGroupKeys then
			for tReleaseGroupKeyCnt = 1, #tReleaseGroupKeys do
				tReleaseGroupKey = tReleaseGroupKeys[tReleaseGroupKeyCnt];

				tReleaseGroupFrameCount = aContainer:GetAuraGroupFrameCount(tReleaseGroupKey);

				for tReleaseGroupFrameIndex = 1, tReleaseGroupFrameCount do
					tReleaseAuraFrame = aContainer:GetAuraGroupFrame(tReleaseGroupKey, tReleaseGroupFrameIndex);

					if tReleaseAuraFrame then
						VUHDO_releaseAuraButtonGlowState(tReleaseAuraFrame);
					end
				end
			end
		end

		tReleaseSlotFrames = aContainerData["slotFrames"];

		if tReleaseSlotFrames then
			for _, tReleaseAuraFrame in pairs(tReleaseSlotFrames) do
				if tReleaseAuraFrame then
					VUHDO_releaseAuraButtonGlowState(tReleaseAuraFrame);
				end
			end
		end

		return;

	end



	--
	local tWipeContainer;
	function VUHDO_wipeAuraContainerPool()

		for _, tPool in pairs(sAuraContainerPool) do
			for tPoolCnt = 1, #tPool do
				tWipeContainer = tPool[tPoolCnt] and tPool[tPoolCnt]["container"];

				if tWipeContainer then
					sContainerClassColorBars[tWipeContainer] = nil;
					sPendingClassColors[tWipeContainer] = nil;
				end
			end
		end

		twipe(sAuraContainerPool);

		return;

	end



	--
	local tPoolKey;
	local tPool;
	local tContainerData;
	local tContainer;
	local tOverlayTargetBar;
	local tContainerParent;
	local tUsesDispelTextures;
	local tDispelColorGen;
	function VUHDO_acquireAuraContainer(aButton, aContainerTemplate)

		if not aButton or not aContainerTemplate then
			return nil;
		end

		if aContainerTemplate["isOverlay"] then
			tOverlayTargetBar = aContainerTemplate["overlayTargetBar"];

			if tOverlayTargetBar then
				tContainerParent = tOverlayTargetBar["VuhDoOverlayHostFrame"] or aContainerTemplate["overlayHostFrame"];

				if tContainerParent and tContainerParent:GetName() then
				elseif tOverlayTargetBar:GetName() then
					tContainerParent = tOverlayTargetBar;
				else
					tContainerParent = aButton;
				end
			else
				tContainerParent = aButton;
			end
		else
			tContainerParent = aButton;
		end

		aContainerTemplate["parent"] = tContainerParent;

		tPoolKey = VUHDO_getAuraContainerPoolKey(aContainerTemplate);
		tUsesDispelTextures = aContainerTemplate["usesDispelTextures"];

		if tUsesDispelTextures == nil then
			tUsesDispelTextures = VUHDO_containerTemplateUsesDispelTextures(aContainerTemplate);
		end

		tDispelColorGen = tUsesDispelTextures and VUHDO_getDispelColorGeneration() or nil;
		tPool = tPoolKey and sAuraContainerPool[tPoolKey];

		if tPool and #tPool > 0 then
			tContainerData = nil;

			while #tPool > 0 do
				tContainerData = tremove(tPool);

				if tUsesDispelTextures then
					if not tContainerData["dispelColorGen"] or tContainerData["dispelColorGen"] ~= tDispelColorGen then
						tContainerData = nil;
					else
						break;
					end
				else
					break;
				end
			end

			if tContainerData and tContainerData["container"] then
				tContainer = tContainerData["container"];

				tContainer:SetParent(tContainerParent);

				if sContainerClassColorBars[tContainer] then
					twipe(sContainerClassColorBars[tContainer]);
				end

				sPendingClassColors[tContainer] = nil;

				VUHDO_applyAuraContainerAnchor(tContainer, aContainerTemplate["anchor"], tContainerParent);

				if aContainerTemplate["isOverlay"] then
					tContainer:EnableMouse(false);
					tContainer:SetMouseMotionEnabled(false);
				end

				tContainer:SetEnabled(false);
				tContainer:SetShown(false);

				tContainerData["containerTemplate"] = aContainerTemplate;
				tContainerData["overlayTargetBar"] = aContainerTemplate["overlayTargetBar"];
				tContainerData["overlayHostFrame"] = aContainerTemplate["overlayHostFrame"];
				tContainerData["staticSlots"] = aContainerTemplate["staticSlots"] or VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate);
				tContainerData["panelNum"] = aContainerTemplate["panelNum"];
				tContainerData["anchorIndex"] = aContainerTemplate["anchorIndex"];
				tContainerData["lastSyncedUnit"] = nil;
				tContainerData["lastSyncedRestricted"] = nil;
				tContainerData["lastSyncedEnabled"] = nil;
				tContainerData["lastSyncedAssistOnly"] = nil;
				tContainerData["lastSlotSuppress"] = nil;
				tContainerData["mixedPriorityCutoffs"] = nil;
				tContainerData["friendlyOnly"] = nil;
				tContainerData["hostileOnly"] = nil;
				tContainerData["alwaysEnabled"] = nil;
				tContainerData["fromPool"] = true;

				VUHDO_restorePooledAuraContainer(tContainer, tContainerData, aContainerTemplate);

				if aContainerTemplate["isFillChain"] then
					VUHDO_setupOverlayFillChain(tContainer, aContainerTemplate, tContainerData);
				end

				tContainerData["lastSyncedGroupEnabled"] = nil;
				tContainerData["poolKey"] = tPoolKey;
			end

			if tContainerData and tContainerData["container"] then
				VUHDO_AURA_CONTAINER_METRICS["poolHits"]["container"] = (VUHDO_AURA_CONTAINER_METRICS["poolHits"]["container"] or 0) + 1;

				return tContainerData;
			end
		end

		VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] = (VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] or 0) + 1;

		tContainerData = VUHDO_buildManagedAuraContainer(aContainerTemplate);

		if tContainerData then
			tContainerData["fromPool"] = false;
			tContainerData["poolKey"] = tPoolKey;
		end

		return tContainerData;

	end



	--
	local tRestoreTargetBar;
	local tRestoreButtonName;
	local tRestoreStoredColor;
	local tRestoreOpacity;
	local tChainBaselineFrame;
	local tRestoreTargetBarTexture;
	local function VUHDO_restoreOverlayFillChainBackground(aContainerData)

		if not aContainerData or not aContainerData["backgroundFillHidden"] then
			return;
		end

		tRestoreTargetBar = aContainerData["overlayTargetBar"];

		if tRestoreTargetBar then
			tRestoreTargetBarTexture = tRestoreTargetBar:GetStatusBarTexture();
			tRestoreButtonName = tRestoreTargetBar:GetParent() and tRestoreTargetBar:GetParent():GetName();
			tRestoreStoredColor = tRestoreButtonName and sChainBaselineColors[tRestoreButtonName];

			if tRestoreStoredColor then
				tRestoreOpacity = tRestoreStoredColor["O"];

				if tRestoreOpacity == nil then
					tRestoreOpacity = 1;
				end

				tRestoreTargetBar:SetStatusBarColor(tRestoreStoredColor["R"] or 0, tRestoreStoredColor["G"] or 0, tRestoreStoredColor["B"] or 0, tRestoreOpacity);
			else
				tRestoreTargetBar:SetStatusBarColor(0, 0, 0, 0);
			end

			if tRestoreTargetBarTexture then
				tRestoreTargetBarTexture:SetAlpha(1);
			end
		end

		tChainBaselineFrame = aContainerData["chainBaselineFrame"];

		if tChainBaselineFrame then
			tChainBaselineFrame:Hide();
		end

		aContainerData["backgroundFillHidden"] = nil;
		aContainerData["chainBaselineFrame"] = nil;
		aContainerData["chainBaselineTexture"] = nil;

		return;

	end



	--
	local tPoolKey;
	local tContainer;
	function VUHDO_releaseAuraContainer(aButton, aContainerData)

		if not aContainerData or not aContainerData["container"] then
			return;
		end

		VUHDO_restoreOverlayFillChainBackground(aContainerData);

		VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] = (VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] or 0) + 1;

		tContainer = aContainerData["container"];

		VUHDO_releaseAuraContainerGlowState(tContainer, aContainerData);

		VUHDO_suppressAuraContainer(tContainer, aContainerData);

		VUHDO_clearAuraContainerUnit(tContainer, aContainerData);

		sContainerClassColorBars[tContainer] = nil;
		sPendingClassColors[tContainer] = nil;

		tContainer:SetParent(nil);

		tPoolKey = aContainerData["poolKey"] or VUHDO_getAuraContainerPoolKey(aContainerData["containerTemplate"]);

		if tPoolKey then
			tUsesDispelTextures = aContainerData["containerTemplate"] and aContainerData["containerTemplate"]["usesDispelTextures"];

			if tUsesDispelTextures == nil then
				tUsesDispelTextures = VUHDO_containerTemplateUsesDispelTextures(aContainerData["containerTemplate"]);
			end

			if tUsesDispelTextures then
				if not aContainerData["dispelColorGen"] or aContainerData["dispelColorGen"] ~= VUHDO_getDispelColorGeneration() then
					return;
				end
			end

			if not sAuraContainerPool[tPoolKey] then
				sAuraContainerPool[tPoolKey] = { };
			end

			tinsert(sAuraContainerPool[tPoolKey], aContainerData);
		end

		return;

	end

end



--
function VUHDO_getOverlayChainBaselineStoredColor(aButtonName)

	if not aButtonName then
		return nil;
	end

	return sChainBaselineColors[aButtonName];

end



--
local tBaselineButtonName;
local tBaselineStoredColor;
local tBaselineIndicatorEntry;
local tBaselineContainerData;
local tBaselineTexture;
function VUHDO_setOverlayChainBaselineColor(aButton, aColor)

	if not aButton or not aColor then
		return;
	end

	tBaselineButtonName = aButton:GetName();

	if not tBaselineButtonName then
		return;
	end

	tBaselineStoredColor = sChainBaselineColors[tBaselineButtonName];

	if tBaselineStoredColor
		and tBaselineStoredColor["R"] == (aColor["R"] or 0)
		and tBaselineStoredColor["G"] == (aColor["G"] or 0)
		and tBaselineStoredColor["B"] == (aColor["B"] or 0)
		and tBaselineStoredColor["O"] == (aColor["O"] == nil and 1 or aColor["O"]) then
		return;
	end

	if not tBaselineStoredColor then
		tBaselineStoredColor = { };

		sChainBaselineColors[tBaselineButtonName] = tBaselineStoredColor;
	end

	tBaselineStoredColor["R"] = aColor["R"] or 0;
	tBaselineStoredColor["G"] = aColor["G"] or 0;
	tBaselineStoredColor["B"] = aColor["B"] or 0;
	tBaselineStoredColor["O"] = aColor["O"];

	if tBaselineStoredColor["O"] == nil then
		tBaselineStoredColor["O"] = 1;
	end

	tBaselineIndicatorEntry = VUHDO_OVERLAY_CONTAINERS[tBaselineButtonName] and VUHDO_OVERLAY_CONTAINERS[tBaselineButtonName]["BACKGROUND_BAR"];
	tBaselineContainerData = tBaselineIndicatorEntry and tBaselineIndicatorEntry["fillChain"];
	tBaselineTexture = tBaselineContainerData and tBaselineContainerData["chainBaselineTexture"];

	if tBaselineTexture and not tBaselineTexture:IsForbidden() then
		tBaselineTexture:SetColorTexture(tBaselineStoredColor["R"], tBaselineStoredColor["G"], tBaselineStoredColor["B"], tBaselineStoredColor["O"]);
	end

	return;

end



--
local tBaselineStoredColor;
local tBaselineTexture;
local tBaselineOpacity;
function VUHDO_applyStoredChainBaselineColor(aButtonName, aContainerData)

	if not aButtonName or not aContainerData then
		return;
	end

	tBaselineStoredColor = sChainBaselineColors[aButtonName];
	tBaselineTexture = aContainerData["chainBaselineTexture"];

	if tBaselineStoredColor and tBaselineTexture and not tBaselineTexture:IsForbidden() then
		tBaselineOpacity = tBaselineStoredColor["O"];

		if tBaselineOpacity == nil then
			tBaselineOpacity = 1;
		end

		tBaselineTexture:SetColorTexture(tBaselineStoredColor["R"] or 0, tBaselineStoredColor["G"] or 0, tBaselineStoredColor["B"] or 0, tBaselineOpacity);
	end

	return;

end



--
function VUHDO_invalidateAuraContainerTemplateCache()

	VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_GENERATION = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_GENERATION + 1;

	twipe(VUHDO_AURA_CONTAINER_TEMPLATE_CACHE);

	VUHDO_wipeAuraContainerPool();

	VUHDO_invalidateAuraGroupFilterCache();

	VUHDO_incrementAuraAnchorConfigVersion();

	return;

end



--
function VUHDO_applyBarButtonSetupFields(anButtonSetup, anAnchorConfig)

	anButtonSetup["durationBar"] = true;
	anButtonSetup["durationBarOptions"] = {
		["direction"] = anAnchorConfig["barInvertGrowth"] and Enum.StatusBarTimerDirection.ElapsedTime
			or Enum.StatusBarTimerDirection.RemainingTime,
	};

	if anAnchorConfig["barVertical"] then
		anButtonSetup["durationBarOrientation"] = anAnchorConfig["barTurnAxis"] and VUHDO_STATUSBAR_TOP_TO_BOTTOM or VUHDO_STATUSBAR_BOTTOM_TO_TOP;
	else
		anButtonSetup["durationBarOrientation"] = anAnchorConfig["barTurnAxis"] and VUHDO_STATUSBAR_RIGHT_TO_LEFT or VUHDO_STATUSBAR_LEFT_TO_RIGHT;
	end

	return;

end



--
local tDispelBorder;
local tShowTooltip;
local tButtonSetup;
local tDurationMode;
local tTimerThreshold;
local tIconTextSize;
local tIconType;
function VUHDO_buildAnchorButtonSetup(anAnchorConfig, aPixelWidth, aPixelHeight, anIsBar, aGroup, aBarWidth, aBarHeight)

	tDispelBorder = VUHDO_resolveAuraTriState(anAnchorConfig["dispelBorder"], "dispelBorder");
	tShowTooltip = VUHDO_resolveAuraTriState(anAnchorConfig["showTooltip"], "showTooltip");

	tDurationMode, tTimerThreshold = VUHDO_resolveGroupTimerSettings(aGroup);

	tIconType = anAnchorConfig["iconType"] or 1;

	tButtonSetup = {
		["dispelBorder"] = tDispelBorder,
		["auraSymbol"] = tDispelBorder,
		["durationText"] = VUHDO_resolveAuraTriState(anAnchorConfig["showTimer"], "showTimer"),
		["durationCooldown"] = VUHDO_resolveAuraTriState(anAnchorConfig["showClock"], "showClock"),
		["durationBar"] = false,
		["hideIcon"] = tIconType >= 4,
		["applicationCount"] = VUHDO_resolveAuraTriState(anAnchorConfig["showStacks"], "showStacks"),
		["mouseMotion"] = tShowTooltip,
		["disableMouse"] = false,
		["width"] = aPixelWidth,
		["height"] = aPixelHeight,
		["textSize"] = aPixelHeight or 20,
		["textConfig"] = {
			["TIMER_TEXT"] = anAnchorConfig["TIMER_TEXT"],
			["COUNTER_TEXT"] = anAnchorConfig["COUNTER_TEXT"],
		},
	};

	tButtonSetup["durationMode"] = tDurationMode;
	tButtonSetup["timerThreshold"] = tTimerThreshold;

	if tButtonSetup["durationText"] then
		tButtonSetup["durationTextOptions"] = {
			["textFormatter"] = VUHDO_getAuraTimerFormatter(tDurationMode, tTimerThreshold),
			["textColor"] = {
				["curve"] = VUHDO_getAuraTimerColorCurve(tDurationMode, tTimerThreshold),
				["property"] = Enum.DurationTextBindingProperty.RemainingDuration,
			},
		};
	end

	if tIconType == 2 then
		tButtonSetup["staticIcon"] = "Interface\\AddOns\\VuhDo\\Images\\icon_white_square";
	elseif tIconType == 3 then
		tButtonSetup["staticIcon"] = "Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16";
	end

	if anIsBar then
		VUHDO_applyBarButtonSetupFields(tButtonSetup, anAnchorConfig);

		tButtonSetup["barVertical"] = anAnchorConfig["barVertical"] or false;
		tButtonSetup["barTurnAxis"] = anAnchorConfig["barTurnAxis"] or false;
		tButtonSetup["iconType"] = tIconType;
		tButtonSetup["barSegmentWidth"] = aBarWidth;
		tButtonSetup["barSegmentHeight"] = aBarHeight;

		if tButtonSetup["iconType"] ~= 5 and aBarWidth and aBarHeight then
			if tButtonSetup["barVertical"] then
				tIconTextSize = aBarWidth;
			else
				tIconTextSize = aBarHeight;
			end

			tButtonSetup["iconTextSize"] = tIconTextSize;
			tButtonSetup["textSize"] = tIconTextSize;
		end
	end

	return tButtonSetup;

end



--
local tContainerTemplate;
function VUHDO_createAuraContainer(aButton, anAnchorIndex, anAnchorConfig)

	tContainerTemplate = VUHDO_buildAnchorContainerTemplate(aButton, anAnchorIndex, anAnchorConfig);

	if not tContainerTemplate then
		return nil;
	end

	return VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

end



--
local tButtonName;
local tUnit;
local tPanelAnchors;
local tContainerData;
function VUHDO_initAuraContainersForButton(aButton, aPanelNum)

	if not aButton or not aPanelNum then
		return;
	end

	if not aButton:CanBeAccessedInContext() then
		sPendingContainerBuilds[aButton] = aPanelNum;

		sHasPendingBuilds = true;

		return;
	end

	sPendingContainerBuilds[aButton] = nil;

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName then
		return;
	end

	VUHDO_releaseAuraContainersForButton(aButton);

	VUHDO_AURA_CONTAINERS[tButtonName] = { };

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
			tContainerData = VUHDO_createAuraContainer(aButton, tAnchorIndex, tAnchorConfig);

			if tContainerData then
				VUHDO_AURA_CONTAINERS[tButtonName][tAnchorIndex] = tContainerData;
			end
		end
	end

	tUnit = aButton["raidid"] or aButton:GetAttribute("unit");

	if tUnit then
		VUHDO_syncAuraContainersForButton(aButton, tUnit);
	end

	return;

end



do
	--
	local tCandidateFilters;
	function VUHDO_isAssistOnlyTemplate(aTemplate)

		if not aTemplate then
			return false;
		end

		if aTemplate["isHarmful"] then
			return false;
		end

		tCandidateFilters = aTemplate["candidateFilters"];

		if not tCandidateFilters or (not tCandidateFilters["includeSpellIDs"] and not tCandidateFilters["excludeSpellIDs"]) then
			return false;
		end

		return true;

	end
end



do
	--
	local tCanAssist;
	function VUHDO_isUnitAssistRestricted(aUnit)

		if not aUnit then
			return true;
		end

		tCanAssist = UnitCanAssist("player", aUnit);

		if issecretvalue(tCanAssist) or not tCanAssist then
			return true;
		end

		return false;

	end
end



do
	--
	local tContainerTemplate;
	local tGroupKeys;
	local tGroupTemplateRefs;
	local tGroupKey;
	local tGroup;
	local tTemplateRef;
	local tSlotKeys;
	local tSlotTemplateRefs;
	local tEngineSlotCnt;
	local tSlot;
	local tRecordedKey;
	function VUHDO_applyAuraContainerAssistOnly(aContainer, aContainerData, anIsAssistRestricted)

		if not aContainer or not aContainerData then
			return false;
		end

		if aContainerData["lastSyncedAssistOnly"] == anIsAssistRestricted then
			return false;
		end

		tContainerTemplate = aContainerData["containerTemplate"];

		if not tContainerTemplate then
			return false;
		end

		tGroupKeys = aContainerData["groupKeys"];
		tGroupTemplateRefs = aContainerData["groupTemplateRefs"];

		if tGroupKeys and tGroupTemplateRefs then
			for tGroupCnt = 1, #tGroupKeys do
				tTemplateRef = tGroupTemplateRefs[tGroupCnt];

				if tTemplateRef and tTemplateRef["isAssistOnly"] then
					tGroupKey = tGroupKeys[tGroupCnt];
					tGroup = tTemplateRef["template"];

					if anIsAssistRestricted then
						aContainer:SetAuraGroupMaxFrameCount(tGroupKey, 0);
					else
						aContainer:SetAuraGroupMaxFrameCount(tGroupKey, tGroup["maxFrameCount"] or 5);
						aContainer:SetAuraGroupFilterString(tGroupKey, tGroup["filterString"] or "HELPFUL");
					end
				end
			end
		end

		tSlotKeys = aContainerData["slotKeys"];
		tSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(tContainerTemplate["slots"] or sEmpty) do
			tSlot = tContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tTemplateRef = tSlotTemplateRefs and tSlotTemplateRefs[tEngineSlotCnt];

				if tTemplateRef and tTemplateRef["isAssistOnly"] then
					tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];
					tSlot = tTemplateRef["template"];

					if tRecordedKey then
						if anIsAssistRestricted then
							aContainer:SetAuraSlotFilterString(tRecordedKey, "");
						else
							aContainer:SetAuraSlotFilterString(tRecordedKey, tSlot["filterString"] or "HELPFUL");
						end
					end
				end
			end
		end

		aContainerData["lastSyncedAssistOnly"] = anIsAssistRestricted;

		return true;

	end
end



--
local tButton;
function VUHDO_clearAuraContainerUnit(aContainer, aContainerData)

	if not aContainer then
		return;
	end

	if aContainerData and aContainerData["staticSlots"] and next(aContainerData["staticSlots"]) then
		tButton = aContainer:GetParent();

		if tButton then
			VUHDO_hideStaticBouquetSlotsForButton(tButton, aContainerData);
		end
	end

	aContainer:SetUnit("none");
	aContainer:SetEnabled(false);
	aContainer:SetShown(false);

	if aContainerData then
		aContainerData["lastSyncedUnit"] = nil;
		aContainerData["lastSyncedRestricted"] = nil;
		aContainerData["lastSyncedEnabled"] = nil;
		aContainerData["lastSyncedGroupEnabled"] = nil;
		aContainerData["lastSlotSuppress"] = nil;
		aContainerData["lastSyncedAssistOnly"] = nil;
		aContainerData["mixedPriorityCutoffs"] = nil;
	end

	return;

end



--
function VUHDO_refreshAuraContainer(aContainer)

	if not aContainer or not aContainer:IsShown() then
		return;
	end

	if InCombatLockdown() then
		aContainer:UpdateAllAuras();

		aContainer:SetOnUpdateMode(VUHDO_ON_UPDATE_MODE_RUN_ONCE);
	else
		aContainer:Hide();
		aContainer:Show();
	end

	return;

end



--
local tIsAuraDataRestricted;
local tCanAttack;
function VUHDO_bindAuraContainerUnit(aContainer, aContainerData, aUnit, aButton)

	if not aContainer or not aContainerData or not aUnit then
		return;
	end

	aContainer:SetUnit(aUnit);

	tIsAuraDataRestricted = VUHDO_isAuraDataRestricted();

	if VUHDO_isAuraModeContainers() then
		aContainer:SetEnabled(true);
		aContainer:SetShown(true);
	else
		aContainer:SetEnabled(tIsAuraDataRestricted);
		aContainer:SetShown(tIsAuraDataRestricted);
	end

	aContainerData["lastSyncedRestricted"] = tIsAuraDataRestricted;

	VUHDO_applyContainerClassColorBars(aContainer, aUnit);

	aContainerData["lastSyncedUnit"] = aUnit;

	if aContainerData["staticSlots"] and next(aContainerData["staticSlots"]) then
		if not aButton then
			aButton = aContainer:GetParent();
		end

		if aButton then
			tCanAttack = UnitCanAttack("player", aUnit);
			VUHDO_updateStaticBouquetSlotsForButton(aButton, aUnit, aContainerData, tCanAttack);
		end
	end

	VUHDO_refreshAuraContainer(aContainer);

	return;

end



--
local tContainerTemplate;
local tMixedPriorityCutoffs;
local tMixedEntryIndex;
local tMixedItemIndex;
local tPriorityCutoff;
local tShouldSuppress;
local tLastSlotSuppress;
local tSlotKey;
local tIsDirty;
function VUHDO_applyAuraContainerSlotFilters(aContainer, aContainerData, anIsHostile)

	if not aContainer or not aContainerData then
		return false;
	end

	tContainerTemplate = aContainerData["containerTemplate"];

	if not tContainerTemplate then
		return false;
	end

	tMixedPriorityCutoffs = aContainerData["mixedPriorityCutoffs"];
	tLastSlotSuppress = aContainerData["lastSlotSuppress"];
	tIsDirty = false;

	for _, tSlot in ipairs(tContainerTemplate["slots"] or sEmpty) do
		if not tSlot["isStaticBouquetSlot"] and tSlot["key"] then
			tShouldSuppress = false;

			if tSlot["friendlyOnly"] and anIsHostile then
				tShouldSuppress = true;
			end

			tMixedEntryIndex = tSlot["mixedEntryIndex"];
			tMixedItemIndex = tSlot["mixedItemIndex"];
			tPriorityCutoff = tMixedPriorityCutoffs and tMixedEntryIndex and tMixedPriorityCutoffs[tMixedEntryIndex];

			if tMixedItemIndex and tPriorityCutoff and tMixedItemIndex > tPriorityCutoff then
				tShouldSuppress = true;
			end

			tSlotKey = tSlot["key"];

			if not tLastSlotSuppress or tLastSlotSuppress[tSlotKey] ~= tShouldSuppress then
				if tShouldSuppress then
					aContainer:SetAuraSlotCandidateFilters(tSlotKey, sSuppressCandidateFilters);
				else
					aContainer:SetAuraSlotCandidateFilters(tSlotKey, tSlot["candidateFilters"]);
				end

				if not tLastSlotSuppress then
					tLastSlotSuppress = { };
					aContainerData["lastSlotSuppress"] = tLastSlotSuppress;
				end

				tLastSlotSuppress[tSlotKey] = tShouldSuppress;
				tIsDirty = true;
			end
		end
	end

	return tIsDirty;

end



--
local tButtonName;
local tContainer;
local tNeedsSync;
local tIsAuraDataRestricted;
local tCanAttack;
local tIsAssistRestricted;
local tSlotFiltersDirty;
local tAssistOnlyDirty;
function VUHDO_syncAuraContainersForButton(aButton, aUnit)

	if not aButton or not aUnit then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_AURA_CONTAINERS[tButtonName] then
		return;
	end

	tIsAuraDataRestricted = VUHDO_isAuraDataRestricted();
	tCanAttack = UnitCanAttack("player", aUnit);
	tIsAssistRestricted = VUHDO_isUnitAssistRestricted(aUnit);

	if not UnitExists(aUnit) then
		for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
			tContainer = tContainerData and tContainerData["container"];

			if tContainer then
				VUHDO_clearAuraContainerUnit(tContainer, tContainerData);
			end
		end

		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		tContainer = tContainerData and tContainerData["container"];

		if tContainer then
			tSlotFiltersDirty = VUHDO_applyAuraContainerSlotFilters(tContainer, tContainerData, tCanAttack);

			tAssistOnlyDirty = VUHDO_applyAuraContainerAssistOnly(tContainer, tContainerData, tIsAssistRestricted);

			if VUHDO_isAuraModeContainers() then
				tContainerData["lastSyncedRestricted"] = tIsAuraDataRestricted;

				tNeedsSync = tContainerData["lastSyncedUnit"] ~= aUnit or not tContainer:IsEnabled() or not tContainer:IsShown();
			else
				tNeedsSync = tContainerData["lastSyncedUnit"] ~= aUnit or tContainerData["lastSyncedRestricted"] ~= tIsAuraDataRestricted or not tContainer:IsEnabled() or not tContainer:IsShown();
			end

			if tNeedsSync then
				VUHDO_bindAuraContainerUnit(tContainer, tContainerData, aUnit, aButton);
			else
				if tSlotFiltersDirty or tAssistOnlyDirty then
					VUHDO_refreshAuraContainer(tContainer);
				end

				if tContainerData["staticSlots"] and next(tContainerData["staticSlots"]) then
					VUHDO_updateStaticBouquetSlotsForButton(aButton, aUnit, tContainerData, tCanAttack, true);
				end
			end
		end
	end

	return;

end



--
function VUHDO_syncAuraContainersForUnit(aUnit)

	if not aUnit then
		return;
	end

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		VUHDO_syncAuraContainersForButton(tButton, aUnit);
	end

	return;

end



--
local tButtonName;
local tContainer;
function VUHDO_clearAuraContainersForButton(aButton)

	if not aButton then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_AURA_CONTAINERS[tButtonName] then
		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		tContainer = tContainerData and tContainerData["container"];

		if tContainer then
			VUHDO_clearAuraContainerUnit(tContainer, tContainerData);
		end
	end

	return;

end



--
local tButtonName;
function VUHDO_releaseAuraContainersForButton(aButton)

	if not aButton then
		return;
	end

	sPendingContainerBuilds[aButton] = nil;

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_AURA_CONTAINERS[tButtonName] then
		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		VUHDO_releaseAuraContainer(aButton, tContainerData);
	end

	VUHDO_AURA_CONTAINERS[tButtonName] = nil;

	return;

end



--
function VUHDO_processPendingAuraContainerBuilds()

	if not sHasPendingBuilds then
		return;
	end

	sHasPendingBuilds = false;

	for tButton, tPanelNum in pairs(sPendingContainerBuilds) do
		VUHDO_deferInitAuraContainersForButton(tButton, tPanelNum);
	end

	twipe(sPendingContainerBuilds);

	for tButton, tButtonSetup in pairs(sPendingButtonLayouts) do
		VUHDO_layoutBarAuraButtonFrames(tButtonSetup, tButton);
	end

	twipe(sPendingButtonLayouts);

	for tContainer, tUnit in pairs(sPendingClassColors) do
		VUHDO_applyContainerClassColorBars(tContainer, tUnit);
	end

	twipe(sPendingClassColors);

	return;

end



--
local tPendingBuildCount;
function VUHDO_getPendingContainerBuildCount()

	tPendingBuildCount = 0;

	for _ in pairs(sPendingContainerBuilds) do
		tPendingBuildCount = tPendingBuildCount + 1;
	end

	return tPendingBuildCount;

end