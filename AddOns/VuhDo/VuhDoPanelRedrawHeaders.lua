local _;

local tonumber = tonumber;
local huge = math.huge;

local VUHDO_getHeader;
local VUHDO_isTableHeaderOrFooter;
local VUHDO_LibSharedMedia;
local VUHDO_getFont;
local VUHDO_getHeaderTextId;
local VUHDO_getHeaderWidth;
local VUHDO_getHeaderHeight;
local VUHDO_getHeaderPos;
local VUHDO_customizeHeader;
local VUHDO_isPanelHorizontal;

local sHeaderTextRotation = math.pi * 0.5;



--
function VUHDO_panelRedrawHeadersInitLocalOverrides()

	VUHDO_getHeader = _G["VUHDO_getHeader"];
	VUHDO_isTableHeaderOrFooter = _G["VUHDO_isTableHeaderOrFooter"];
	VUHDO_LibSharedMedia = _G["VUHDO_LibSharedMedia"];
	VUHDO_getFont = _G["VUHDO_getFont"];
	VUHDO_getHeaderTextId = _G["VUHDO_getHeaderTextId"];
	VUHDO_getHeaderWidth = _G["VUHDO_getHeaderWidth"];
	VUHDO_getHeaderHeight = _G["VUHDO_getHeaderHeight"];
	VUHDO_getHeaderPos = _G["VUHDO_getHeaderPos"];
	VUHDO_customizeHeader = _G["VUHDO_customizeHeader"];
	VUHDO_isPanelHorizontal = _G["VUHDO_isPanelHorizontal"];

	return;

end



--
local tModel;
local tWidth;
local tHeight;
local tAnzCols;
local tStatusFile;
local tFont;
local tTextSize;
local tBarWidth;
local tHeaderWidth;
local tHasHeaders;
local tHeaderColSetup;
local tHeader;
local tX, tY
local tHealthBar;
local tHeaderText;
local tIsHorizontal;
local tEmpty = { };
function VUHDO_positionTableHeaders(aPanel, aPanelNum)

	tModel  = VUHDO_PANEL_DYN_MODELS[aPanelNum];
	tWidth  = VUHDO_getHeaderWidth(aPanelNum);
	tHeight = VUHDO_getHeaderHeight(aPanelNum);

	tHasHeaders = VUHDO_isTableHeaderOrFooter(aPanelNum);
	tBarWidth = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["headerWidth"] * 0.01;

	if tHasHeaders then
		tAnzCols = #(tModel or tEmpty);

		tHeaderColSetup = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["HEADER"];
		tStatusFile = VUHDO_LibSharedMedia:Fetch('statusbar', tHeaderColSetup["barTexture"]);
		tFont = VUHDO_getFont(tHeaderColSetup["font"]);
		tTextSize = tonumber(tHeaderColSetup["textSize"]);

		tHeaderWidth = tWidth * tBarWidth + 0.01;

		tIsHorizontal = VUHDO_isPanelHorizontal(aPanelNum);
	else
		tAnzCols = 0;
	end

	for tCnt  = 1, tAnzCols do
		tHeader = VUHDO_getOrCreateHeader(tCnt, aPanelNum);

		VUHDO_PixelUtil.SetWidth(tHeader, tHeaderWidth);
		VUHDO_PixelUtil.SetHeight(tHeader, tHeight);

		tHealthBar = VUHDO_getHeaderBar(tHeader);
		tHealthBar:SetMinMaxValues(0, 1);
		tHealthBar:SetValue(1);
		VUHDO_PixelUtil.SetHeight(tHealthBar, tHeight);

		if tStatusFile then
			tHealthBar:SetStatusBarTexture(tStatusFile);

			VUHDO_PixelUtil.ApplySettings(tHealthBar:GetStatusBarTexture());
		end

		tHeaderText = VUHDO_getHeaderTextId(tHeader);
		tHeaderText:SetFont(tFont, tTextSize, "OUTLINE");

		VUHDO_PixelUtil.ClearAllPoints(tHeaderText);
		tHeaderText:SetJustifyH("CENTER");
		tHeaderText:SetJustifyV("MIDDLE");

		if tIsHorizontal then
			VUHDO_PixelUtil.SetSize(tHeaderText, tHeight, 0);
			VUHDO_PixelUtil.SetPoint(tHeaderText, "CENTER", tHealthBar, "CENTER", -tTextSize * 0.5, 0);

			tHeaderText:SetRotation(sHeaderTextRotation);
		else
			VUHDO_PixelUtil.SetSize(tHeaderText, tHeaderWidth, tHeight);
			VUHDO_PixelUtil.SetPoint(tHeaderText, "CENTER", tHealthBar, "CENTER", 0, 0);

			tHeaderText:SetRotation(0);
		end

		tX, tY = VUHDO_getHeaderPos(tCnt, aPanelNum);
		VUHDO_PixelUtil.SetPoint(tHeader, "TOPLEFT", aPanel:GetName(), "TOPLEFT",  tX + tWidth * 0.5 * (1 - tBarWidth), -tY);

		VUHDO_customizeHeader(tHeader, aPanelNum, tModel[tCnt]);

		tHeader:Show();
	end

	for tCnt = tAnzCols + 1, huge do
		tHeader = VUHDO_getHeader(tCnt, aPanelNum);

		if tHeader then
			tHeader:Hide();
		else
			break;
		end

		tCnt = tCnt + 1;
	end

	return;

end