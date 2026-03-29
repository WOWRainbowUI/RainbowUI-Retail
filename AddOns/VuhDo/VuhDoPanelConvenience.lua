local _G = _G;
local pairs = pairs;
local format = format;
local CreateFrame = CreateFrame;
local _;

-- Fast caches
local VUHDO_BARS_PER_BUTTON = { };
local VUHDO_BUTTON_BY_HEALTH_BAR = { };
local VUHDO_BUTTONS_PER_PANEL = { };
setmetatable(VUHDO_BUTTONS_PER_PANEL, VUHDO_META_NEW_ARRAY);
local VUHDO_BUFF_SWATCHES = { };
local VUHDO_BUFF_PANELS = { };
local VUHDO_HEALTH_BAR_TEXT = { };
local VUHDO_ACTION_PANELS = { };

local VUHDO_BAR_ICON_FRAMES = { };
local VUHDO_BAR_ICON_FRAME_BACKGROUNDS = { };
local VUHDO_BAR_ICONS = { };
local VUHDO_BAR_ICON_TIMERS = { };
local VUHDO_BAR_ICON_COUNTERS = { };
local VUHDO_BAR_ICON_CLOCKS = { };
local VUHDO_BAR_ICON_CHARGES = { };
local VUHDO_BAR_ICON_NAMES = { };
local VUHDO_BAR_ICON_BUTTONS = { };


local VUHDO_STUB_COMPONENT = {
	["GetName"] = function() return "VuhDoDummyStub" end,
	["GetAttribute"] = function() return nil end,
	["SetAttribute"] = function() end,
	-- General
	["SetAllPoints"] = function() end,
	["SetAlpha"] = function(self, anAlpha) end,
	["GetAlpha"] = function() return 1 end,
	["Hide"] = function() end,
	["IsVisible"] = function() return false end,
	-- Clock
	["SetReverse"] = function() end,
	["SetCooldown"] = function() end,
	["GetCooldownDuration"] = function() return 0 end
};



VUHDO_BUTTON_CACHE = { };
local VUHDO_BUTTON_CACHE = VUHDO_BUTTON_CACHE;


--
function VUHDO_getBarRoleIcon(aButton, anIconNumber)
	return _G[format("%sBgBarHlBarIc%d", aButton:GetName(), anIconNumber)];
end



--
function VUHDO_getTargetBarRoleIcon(aButton, anIconNumber)
	return _G[format("%sBgBarHlBarIc%d", aButton:GetName(), anIconNumber)];
end



--
function VUHDO_getBarIconFrame(aButton, anIconNumber)
	return VUHDO_BAR_ICON_FRAMES[aButton][anIconNumber];
end



--
function VUHDO_getBarIconFrameBackground(aButton, anIconNumber)

	return VUHDO_BAR_ICON_FRAME_BACKGROUNDS[aButton][anIconNumber];

end



--
function VUHDO_getBarIcon(aButton, anIconNumber)
	return VUHDO_BAR_ICONS[aButton][anIconNumber];
end



--
function VUHDO_getOrCreateHotIcon(aButton, anIconNumber)
	if not VUHDO_BAR_ICONS[aButton][anIconNumber] then
		local tParentName = aButton:GetName() .. "BgBarHlBar";
		local tFrameName = tParentName .. "Ic" .. anIconNumber;
		VUHDO_BAR_ICON_FRAMES[aButton][anIconNumber] = CreateFrame("Frame", tFrameName, _G[tParentName], "VuhDoAuraIconTemplate");
		VUHDO_BAR_ICONS[aButton][anIconNumber] = _G[tFrameName .. "I"];
		VUHDO_BAR_ICON_TIMERS[aButton][anIconNumber] = _G[tFrameName .. "T"];
		VUHDO_BAR_ICON_COUNTERS[aButton][anIconNumber] = _G[tFrameName .. "C"];
		VUHDO_BAR_ICON_CHARGES[aButton][anIconNumber] = _G[tFrameName .. "A"];
	end

	return VUHDO_BAR_ICONS[aButton][anIconNumber];
end



--
local tDebuffOnEnterSnippet = [[
	if sHealButton then
		sHealButton:ClearBindings();
	end

	tFrame = self:GetAttribute("vuhdo_button");

	if not tFrame then
		tFrame = self:GetParent():GetParent():GetParent():GetParent();
	end

	if tFrame then
		sHealButton = tFrame;
		tBody = tFrame:GetAttribute("vuhdo_onenter");

		if tBody then
			owner:RunFor(tFrame, tBody);
		end

		sCliqueHeader = owner:GetFrameRef("sCliqueHeader");

		if sCliqueHeader then
			tCliqueEnter = sCliqueHeader:GetAttribute("setup_onenter");

			if tCliqueEnter then
				sCliqueHeader:RunFor(tFrame, tCliqueEnter);
			end
		end
	else
		sHealButton = nil;
	end
]]
local tDebuffOnLeaveSnippet = [[
	tFrame = self:GetAttribute("vuhdo_button");

	if not tFrame then
		tFrame = self:GetParent():GetParent():GetParent():GetParent();
	end

	if tFrame then
		tFrame:ClearBindings();
		sHealButton = nil;
		tBody = tFrame:GetAttribute("vuhdo_onleave");

		if tBody then
			owner:RunFor(tFrame, tBody);
		end

		sCliqueHeader = owner:GetFrameRef("sCliqueHeader");

		if sCliqueHeader then
			tCliqueLeave = sCliqueHeader:GetAttribute("setup_onleave");

			if tCliqueLeave then
				sCliqueHeader:RunFor(tFrame, tCliqueLeave);
			end
		end
	else
		if sHealButton then
			sHealButton:ClearBindings();
			sHealButton = nil;
		end
	end
]]
function VUHDO_getOrCreateCuDeButton(aButton, anIconNumber)

	if not VUHDO_BAR_ICON_BUTTONS[aButton][anIconNumber] then
		local tParentName = aButton:GetName() .. "BgBarHlBar";
		local tFrameName = tParentName .. "Ic" .. anIconNumber;

		local tBarIconFrame = CreateFrame("Frame", tFrameName, _G[tParentName], "VuhDoDebuffIconTemplate");
		VUHDO_BAR_ICON_FRAMES[aButton][anIconNumber] = tBarIconFrame;

		VUHDO_safeSetAttribute(tBarIconFrame, "vuhdo_button", aButton);

		VUHDO_BAR_ICON_BUTTONS[aButton][anIconNumber] = _G[tFrameName .. "B"];
		VUHDO_BAR_ICON_FRAME_BACKGROUNDS[aButton][anIconNumber] = _G[tFrameName .. "B"];

		local tBackdropFrame = VUHDO_BAR_ICON_FRAME_BACKGROUNDS[aButton][anIconNumber];

		if tBackdropFrame then
			VUHDO_PixelUtil.ClearAllPoints(tBackdropFrame);
			VUHDO_PixelUtil.SetPoint(tBackdropFrame, "TOPLEFT", tBarIconFrame, "TOPLEFT", 0, 0);
			VUHDO_PixelUtil.SetPoint(tBackdropFrame, "BOTTOMRIGHT", tBarIconFrame, "BOTTOMRIGHT", 0, 0);
		end

		VUHDO_BAR_ICONS[aButton][anIconNumber] = _G[tFrameName .. "BI"];
		VUHDO_BAR_ICON_TIMERS[aButton][anIconNumber] = _G[tFrameName .. "BT"];
		VUHDO_BAR_ICON_COUNTERS[aButton][anIconNumber] = _G[tFrameName .. "BC"];
		VUHDO_BAR_ICON_NAMES[aButton][anIconNumber] = _G[tFrameName .. "BN"];

		if not tBarIconFrame:GetAttribute("vd_tt_hook") then
			tBarIconFrame:SetScript("OnEnter", function(self)
				VUHDO_showDebuffTooltip(self);
				VuhDoActionOnEnter(VUHDO_findButtonFromChild(self));
			end);

			tBarIconFrame:SetScript("OnLeave", function(self)
				VUHDO_hideDebuffTooltip();
				VuhDoActionOnLeave(VUHDO_findButtonFromChild(self));
			end);

			VUHDO_safeSetAttribute(tBarIconFrame, "vd_tt_hook", true);
		end

		if not tBarIconFrame:GetAttribute("vuhdo_secureheader_wrap") then
			local tHeaderFrame = _G["VuhDoHealButtonSecureHeaderFrame"];

			if tHeaderFrame then
				VUHDO_safeWrapScript(tHeaderFrame, tBarIconFrame, "OnEnter", tDebuffOnEnterSnippet);
				VUHDO_safeWrapScript(tHeaderFrame, tBarIconFrame, "OnLeave", tDebuffOnLeaveSnippet);

				VUHDO_safeSetAttribute(tBarIconFrame, "vuhdo_secureheader_wrap", true);
			end
		end

		tBarIconFrame:EnableMouse(false);
		tBarIconFrame:SetMouseMotionEnabled(true);
		tBarIconFrame:EnableKeyboard(false);
		tBarIconFrame:SetPropagateKeyboardInput(true);
	end

	return VUHDO_BAR_ICON_BUTTONS[aButton][anIconNumber];

end



--
function VUHDO_getBarIconTimer(aButton, anIconNumber)
	return VUHDO_BAR_ICON_TIMERS[aButton][anIconNumber];
end



--
function VUHDO_getBarIconCounter(aButton, anIconNumber)
	return VUHDO_BAR_ICON_COUNTERS[aButton][anIconNumber];
end



--
function VUHDO_getBarIconClockOrStub(aButton, anIconNumber, aCondition)
	return aCondition and VUHDO_BAR_ICON_CLOCKS[aButton][anIconNumber] or VUHDO_STUB_COMPONENT;
end


--
function VUHDO_getBarIconCharge(aButton, anIconNumber)
	return VUHDO_BAR_ICON_CHARGES[aButton][anIconNumber];
end



--
function VUHDO_getBarIconName(aButton, anIconNumber)
	return VUHDO_BAR_ICON_NAMES[aButton][anIconNumber];
end



--
function VUHDO_getBarIconButton(aButton, anIconNumber)
	return VUHDO_BAR_ICON_BUTTONS[aButton][anIconNumber];
end



--
function VUHDO_getRaidTargetTexture(aTargetBar)
	return _G[aTargetBar:GetName() .. "TgTxu"];
end



--
function VUHDO_getRaidTargetTextureFrame(aTargetBar)
	return _G[aTargetBar:GetName() .. "Tg"];
end



--
function VUHDO_getGroupOrderLabel2(aGroupOrderPanel)
	return _G[aGroupOrderPanel:GetName() .. "DrgLbl2Lbl"];
end



--
function VUHDO_getPanelNumLabel(aPanel)
	return _G[aPanel:GetName() .. "GrpLblLbl"];
end



--
function VUHDO_getGroupOrderPanel(aParentPanelNum, aPanelNum)
	return _G[format("Vd%dGrpOrd%d", aParentPanelNum, aPanelNum)];
end



--
function VUHDO_getGroupSelectPanel(aParentPanelNum, aPanelNum)
	return _G[format("Vd%dGrpSel%d", aParentPanelNum, aPanelNum)];
end



--
function VUHDO_getActionPanelOrStub(aPanelNum)
	return _G["Vd" .. aPanelNum] or VUHDO_STUB_COMPONENT;
end



--
function VUHDO_getActionPanel(aPanelNum)
	return _G["Vd" .. aPanelNum];
end



--
function VUHDO_getOrCreateActionPanel(aPanelNum)
	if not VUHDO_ACTION_PANELS[aPanelNum] then
		VUHDO_ACTION_PANELS[aPanelNum] = CreateFrame("Frame", format("Vd%d", aPanelNum), UIParent, "VuhDoHealPanelTemplate")
	end

	return VUHDO_ACTION_PANELS[aPanelNum];
end


function VUHDO_getAllActionPanels()
	return VUHDO_ACTION_PANELS;
end


--
function VUHDO_getHealthBar(aButton, aBarNumber)
	return VUHDO_BARS_PER_BUTTON[aButton][aBarNumber];
end



--
function VUHDO_getRealParent(aFrame)

	return aFrame["vuhdo_parent"] or aFrame:GetParent();

end



--
local tFrame;
local tParent;
function VUHDO_findButtonFromChild(aChildFrame)

	if not aChildFrame or (aChildFrame["IsForbidden"] and aChildFrame:IsForbidden()) then
		return nil;
	end

	tFrame = aChildFrame;

	while tFrame do
		if VUHDO_BUTTON_CACHE[tFrame] then
			return tFrame;
		end

		tParent = tFrame["vuhdo_parent"];

		if tParent then
			tFrame = tParent;
		elseif tFrame["IsForbidden"] and tFrame:IsForbidden() then
			return nil;
		elseif tFrame["GetParent"] then
			tFrame = tFrame:GetParent();
		else
			return nil;
		end
	end

	return nil;

end



--
function VUHDO_getHealthBarText(aButton, aBarNumber)
	return VUHDO_HEALTH_BAR_TEXT[aButton][aBarNumber];
end



--
function VUHDO_getHeaderBar(aButton)
	return _G[aButton:GetName() .. "Bar"];
end



--
local tBars;
function VUHDO_getPlayerTargetFrame(aButton)

	tBars = VUHDO_BARS_PER_BUTTON[aButton];

	if not tBars or not tBars[1] or not tBars[1].GetName then
		return nil;
	end

	return _G[tBars[1]:GetName() .. "PlTg"];

end


--
function VUHDO_getPlayerTargetFrameTarget(aButton)
	return _G[aButton:GetName() .. "TgPlTg"];
end



--
function VUHDO_getPlayerTargetFrameToT(aButton)
	return _G[aButton:GetName() .. "TotPlTg"];
end



--
function VUHDO_getClusterBorderFrame(aButton)
	return _G[VUHDO_BARS_PER_BUTTON[aButton][1]:GetName() .. "Clu"];
end



--
function VUHDO_getTargetButton(aButton)
	return _G[aButton:GetName() .. "Tg"];
end



--
function VUHDO_getTotButton(aButton)
	return _G[aButton:GetName() .. "Tot"];
end



--
function VUHDO_getHealButton(aButtonNum, aPanelNum)
	return VUHDO_BUTTONS_PER_PANEL[aPanelNum][aButtonNum];
end



--
function VUHDO_getTextPanel(aBar)
	return _G[aBar:GetName() .. "TxPnl"];
end



--
function VUHDO_getBarText(aBar)
	return _G[aBar:GetName() .. "TxPnlUnN"];
end



--
function VUHDO_getBarTextSolo(aBar)
	return _G[aBar:GetName() .. "TxPnlUnNSolo"];
end



--
function VUHDO_getHeaderTextId(aHeader)
	return _G[aHeader:GetName() .. "BarUnN"];
end



--
function VUHDO_getLifeText(aBar)
	return _G[aBar:GetName() .. "TxPnlLife"];
end



--
function VUHDO_getOverhealPanel(aBar)
	return _G[aBar:GetName() .. "OvhPnl"];
end



--
function VUHDO_getOverhealText(aBar)
	return _G[aBar:GetName() .. "OvhPnlT"];
end



--
function VUHDO_getHeader(aHeaderNo, aPanelNum)
	return _G[format("Vd%dHd%d", aPanelNum, aHeaderNo)];
end



--
local tHeaderName;
function VUHDO_getOrCreateHeader(aHeaderNo, aPanelNum)
	tHeaderName = format("Vd%dHd%d", aPanelNum, aHeaderNo);

	if not _G[tHeaderName] then
		CreateFrame("Button", tHeaderName, _G["Vd" .. aPanelNum], "VuhDoGroupHeaderTemplate");
	end
	return _G[tHeaderName];
end


--
local tButton;
function VUHDO_getOrCreateBuffSwatch(aName, aParent)

	if not VUHDO_BUFF_SWATCHES[aName] then
		VUHDO_BUFF_SWATCHES[aName] = CreateFrame("Frame", aName, aParent, "VuhDoBuffSwatchPanelTemplate");
		tButton = _G[aName .. "GlassButton"];
		VUHDO_safeSetAttribute(tButton, "_onleave", "self:ClearBindings();");
		VUHDO_safeSetAttribute(tButton, "_onshow", "self:ClearBindings();");
		VUHDO_safeSetAttribute(tButton, "_onhide", "self:ClearBindings();");
		VUHDO_safeSetAttribute(tButton, "_onmousedown", [[
			local tX, tY = self:GetMousePosition();
			local tXInBounds;
			local tYInBounds;

			if not tX or type(tX) ~= "number" then
				tXInBounds = false;
			else
				tXInBounds = tX >= 0 and tX <= 1;
			end

			if not tY or type(tY) ~= "number" then
				tYInBounds = false;
			else
				tYInBounds = tY >= 0 and tY <= 1;
			end

			if not self:IsVisible() or not tXInBounds or not tYInBounds then
				self:ClearBindings();
			end
		]]);
	else
		tButton = _G[aName .. "GlassButton"];
	end

	if (VUHDO_BUFF_SETTINGS["CONFIG"]["WHEEL_SMART_BUFF"]) then
		VUHDO_safeSetAttribute(tButton, "_onenter", [=[
				self:ClearBindings();
				self:SetBindingClick(0, "MOUSEWHEELUP" , "VuhDoSmartCastGlassButton", "LeftButton");
				self:SetBindingClick(0, "MOUSEWHEELDOWN" , "VuhDoSmartCastGlassButton", "LeftButton");
		]=]);
	else
		VUHDO_safeSetAttribute(tButton, "_onenter", "self:ClearBindings();");
	end

	return VUHDO_BUFF_SWATCHES[aName];
end



--
function VUHDO_getOrCreateBuffPanel(aName)
	if not VUHDO_BUFF_PANELS[aName] then
		VUHDO_BUFF_PANELS[aName] = CreateFrame("Frame", aName, VuhDoBuffWatchMainFrame, "VuhDoBuffWatchBuffTemplate");
	end

	return VUHDO_BUFF_PANELS[aName];
end



--
function VUHDO_getOrCreateCooldown(aFrame, aButton, anIndex)
	if not VUHDO_BAR_ICON_CLOCKS[aButton][anIndex] then
		VUHDO_BAR_ICON_CLOCKS[aButton][anIndex] = CreateFrame("Cooldown", aFrame:GetName() .. "O", aFrame, "VuhDoHotCooldown");
	end

	return VUHDO_BAR_ICON_CLOCKS[aButton][anIndex];
end



--
function VUHDO_resetAllBuffPanels()
	for _, tPanel in pairs(VUHDO_BUFF_SWATCHES) do
		tPanel:Hide();
	end

	for _, tPanel in pairs(VUHDO_BUFF_PANELS) do
		tPanel:Hide();
	end
end



--
function VUHDO_getAllBuffSwatches()
	return VUHDO_BUFF_SWATCHES;
end



--
local function VUHDO_buffWatchSorter(aSwatch, anotherSwatch)
	return VUHDO_BUFF_ORDER[aSwatch:GetAttribute("buffname")]
		< VUHDO_BUFF_ORDER[anotherSwatch:GetAttribute("buffname")];
end



--
local tOrderedSwatches = { };
function VUHDO_getAllBuffSwatchesOrdered()
	table.wipe(tOrderedSwatches);

	for _, tSwatch in pairs(VUHDO_BUFF_SWATCHES) do
		tinsert(tOrderedSwatches, tSwatch);
	end

	table.sort(tOrderedSwatches, VUHDO_buffWatchSorter);
	return tOrderedSwatches;
end



--
function VUHDO_getAggroTexture(aHealthBar)
	return _G[aHealthBar:GetName() .. "Aggro"];
end



--
local tLookupButton;
function VUHDO_getOvershieldBar(aHealthBar)

	tLookupButton = VUHDO_BUTTON_BY_HEALTH_BAR[aHealthBar];

	if tLookupButton then
		return VUHDO_BARS_PER_BUTTON[tLookupButton][20];
	end

	return nil;

end



--
function VUHDO_getHealAbsorbBar(aHealthBar)

	tLookupButton = VUHDO_BUTTON_BY_HEALTH_BAR[aHealthBar];

	if tLookupButton then
		return VUHDO_BARS_PER_BUTTON[tLookupButton][21];
	end

	return nil;

end



--
function VUHDO_getOvershieldBarTexture(aHealthBar)

	return VUHDO_getOvershieldBar(aHealthBar);

end



--
function VUHDO_getHealAbsorbBarTexture(aHealthBar)

	return VUHDO_getHealAbsorbBar(aHealthBar);

end



--
local VUHDO_STATUSBAR_LEFT_TO_RIGHT = VUHDO_STATUSBAR_LEFT_TO_RIGHT;
local VUHDO_STATUSBAR_RIGHT_TO_LEFT = VUHDO_STATUSBAR_RIGHT_TO_LEFT;
local VUHDO_STATUSBAR_BOTTOM_TO_TOP = VUHDO_STATUSBAR_BOTTOM_TO_TOP;
local VUHDO_STATUSBAR_TOP_TO_BOTTOM = VUHDO_STATUSBAR_TOP_TO_BOTTOM;
local tWidth;
local tHeight;
local tValue;



--
local tOrientation;
function VUHDO_setStatusBarOrientation(aBar, anOrientation)

	if VUHDO_STATUSBAR_LEFT_TO_RIGHT == anOrientation then
		tOrientation = "HORIZONTAL";
	elseif VUHDO_STATUSBAR_RIGHT_TO_LEFT == anOrientation then
		tOrientation = "HORIZONTAL";
	elseif VUHDO_STATUSBAR_BOTTOM_TO_TOP == anOrientation then
		tOrientation = "VERTICAL";
	elseif VUHDO_STATUSBAR_TOP_TO_BOTTOM == anOrientation then
		tOrientation = "VERTICAL";
	else
		tOrientation = "HORIZONTAL";
	end
	
	aBar:SetOrientation(tOrientation);
	
	if VUHDO_STATUSBAR_RIGHT_TO_LEFT == anOrientation or VUHDO_STATUSBAR_TOP_TO_BOTTOM == anOrientation then
		aBar:SetReverseFill(true);
	else
		aBar:SetReverseFill(false);
	end
	
	return;

end



--
function VUHDO_calculateDerivedOrientation(aBaseOrientation, anIsTurnAxis)

	if anIsTurnAxis then
		if aBaseOrientation == "HORIZONTAL" then
			return "HORIZONTAL_INV";
		elseif aBaseOrientation == "HORIZONTAL_INV" then
			return "HORIZONTAL";
		elseif aBaseOrientation == "VERTICAL" then
			return "VERTICAL_INV";
		else -- VERTICAL_INV
			return "VERTICAL";
		end
	else
		return aBaseOrientation;
	end

end



--
function VUHDO_setStatusBarVuhDoColor(aBar, aColor, aMaxColor)

	if not aColor then
		return;
	end

	if aColor.GetRGBA then
		aBar:GetStatusBarTexture():SetVertexColor(aColor:GetRGBA());

		return;
	end

	if aMaxColor and
		aColor["R"] and aColor["G"] and aColor["B"] and aColor["O"] and
		aMaxColor["R"] and aMaxColor["G"] and aMaxColor["B"] and aMaxColor["O"] then
		aBar:GetStatusBarTexture():SetGradient(
			"HORIZONTAL",
			VUHDO_getOrCreateCachedColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]),
			VUHDO_getOrCreateCachedColor(aMaxColor["R"], aMaxColor["G"], aMaxColor["B"], aMaxColor["O"])
		);
	elseif aColor["R"] and aColor["G"] and aColor["B"] and aColor["O"] then
		aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
	elseif aColor["R"] and aColor["G"] and aColor["B"] then
		aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"]);
	end

	return;

end






--
local function VUHDO_fastCacheInitButton(aPanelNum, aButtonNum)

	local tButtonName = format("Vd%dH%d", aPanelNum, aButtonNum);
	local tButton = _G[tButtonName];
	local tTargetButton = _G[tButtonName .. "Tg"];
	local tTotButton = _G[tButtonName .. "Tot"];

	VUHDO_BARS_PER_BUTTON[tButton] = { };
	VUHDO_BARS_PER_BUTTON[tTargetButton] = { };
	VUHDO_BARS_PER_BUTTON[tTotButton] = { };

	--Health
	VUHDO_BARS_PER_BUTTON[tButton][1] = _G[tButtonName .. "BgBarHlBar"];
	VUHDO_BUTTON_BY_HEALTH_BAR[VUHDO_BARS_PER_BUTTON[tButton][1]] = tButton;
	-- Mana
	VUHDO_BARS_PER_BUTTON[tButton][2] = _G[tButtonName .. "BgBarHlBarMaBar"];
	-- Background
	VUHDO_BARS_PER_BUTTON[tButton][3] = _G[tButtonName .. "BgBar"];
	-- Aggro
	VUHDO_BARS_PER_BUTTON[tButton][4] = _G[tButtonName .. "BgBarHlBarAgBar"];
	-- Target Health
	VUHDO_BARS_PER_BUTTON[tButton][5] = _G[tButtonName .. "TgBgBarHlBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][1] = _G[tButtonName .. "TgBgBarHlBar"];
	VUHDO_BARS_PER_BUTTON[tButton][6] = _G[tButtonName .. "BgBarClipBarIcBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][6] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tTotButton][6] = VuhDoDummyStatusBar;
	-- Threat
	VUHDO_BARS_PER_BUTTON[tButton][7] = _G[tButtonName .. "ThBar"];
	-- Group Highlight
	VUHDO_BARS_PER_BUTTON[tButton][8] = _G[tButtonName .. "BgBarHlBarHiBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][8] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tTotButton][8] = VuhDoDummyStatusBar;
	-- HoT 1
	VUHDO_BARS_PER_BUTTON[tButton][9] = _G[tButtonName .. "BgBarHlBarHotBar1"];
	-- HoT 2
	VUHDO_BARS_PER_BUTTON[tButton][10] = _G[tButtonName .. "BgBarHlBarHotBar2"];
	-- HoT 3
	VUHDO_BARS_PER_BUTTON[tButton][11] = _G[tButtonName .. "BgBarHlBarHotBar3"];

	-- Target Background
	VUHDO_BARS_PER_BUTTON[tButton][12] = _G[tButtonName .. "TgBgBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][3] = _G[tButtonName .. "TgBgBar"];
	-- Target Mana
	VUHDO_BARS_PER_BUTTON[tButton][13] = _G[tButtonName .. "TgBgBarHlBarMaBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][2] = _G[tButtonName .. "TgBgBarHlBarMaBar"];

	-- Tot Health
	VUHDO_BARS_PER_BUTTON[tButton][14] = _G[tButtonName .. "TotBgBarHlBar"];
	VUHDO_BARS_PER_BUTTON[tTotButton][1] = _G[tButtonName .. "TotBgBarHlBar"];
	-- Tot Background
	VUHDO_BARS_PER_BUTTON[tButton][15] = _G[tButtonName .. "TotBgBar"];
	VUHDO_BARS_PER_BUTTON[tTotButton][3] = _G[tButtonName .. "TotBgBar"];
	-- Tot Mana
	VUHDO_BARS_PER_BUTTON[tButton][16] = _G[tButtonName .. "TotBgBarHlBarMaBar"];
	VUHDO_BARS_PER_BUTTON[tTotButton][2] = _G[tButtonName .. "TotBgBarHlBarMaBar"];
	-- Left side bar
	VUHDO_BARS_PER_BUTTON[tButton][17] = _G[tButtonName .. "BgBarHlBarLsBar"];
	-- Right side bar
	VUHDO_BARS_PER_BUTTON[tButton][18] = _G[tButtonName .. "BgBarHlBarRsBar"];
	VUHDO_BARS_PER_BUTTON[tButton][19] = _G[tButtonName .. "BgBarClipBarShBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][19] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tTotButton][19] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tButton][20] = _G[tButtonName .. "BgBarOvsBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][20] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tTotButton][20] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tButton][21] = _G[tButtonName .. "BgBarHeAbBar"];
	VUHDO_BARS_PER_BUTTON[tTargetButton][21] = VuhDoDummyStatusBar;
	VUHDO_BARS_PER_BUTTON[tTotButton][21] = VuhDoDummyStatusBar;


	VUHDO_HEALTH_BAR_TEXT[tButton] = { };

	for tIndex, tBar in pairs(VUHDO_BARS_PER_BUTTON[tButton]) do
		VUHDO_HEALTH_BAR_TEXT[tButton][tIndex] = _G[tBar:GetName() .. "LabelLabel"];

		tBar["secretCurveColor"] = { };
	end

	for tIndex, tBar in pairs(VUHDO_BARS_PER_BUTTON[tTargetButton]) do
		tBar["secretCurveColor"] = { };
	end

	for tIndex, tBar in pairs(VUHDO_BARS_PER_BUTTON[tTotButton]) do
		tBar["secretCurveColor"] = { };
	end

	VUHDO_BUTTONS_PER_PANEL[aPanelNum][aButtonNum] = tButton;
	VUHDO_BUTTON_CACHE[tButton] = aPanelNum;
	VUHDO_BUTTON_CACHE[tTargetButton] = aPanelNum;
	VUHDO_BUTTON_CACHE[tTotButton] = aPanelNum;

	tButton:SetAttribute("vuhdo_button_marker", true);
	tTargetButton:SetAttribute("vuhdo_button_marker", true);
	tTotButton:SetAttribute("vuhdo_button_marker", true);

	VUHDO_BAR_ICON_FRAMES[tButton] = { };
	VUHDO_BAR_ICON_FRAME_BACKGROUNDS[tButton] = { };
	VUHDO_BAR_ICON_BUTTONS[tButton] = { };
	VUHDO_BAR_ICONS[tButton] = { };
	VUHDO_BAR_ICON_TIMERS[tButton] = { };
	VUHDO_BAR_ICON_COUNTERS[tButton] = { };
	VUHDO_BAR_ICON_CLOCKS[tButton] = { };
	VUHDO_BAR_ICON_CHARGES[tButton] = { };
	VUHDO_BAR_ICON_NAMES[tButton] = { };

	return;

end



--
local tNewButton;
local tFunc;
function VUHDO_getOrCreateHealButton(aButtonNum, aPanelNum)

	if not VUHDO_BUTTONS_PER_PANEL[aPanelNum][aButtonNum] then
		tNewButton = CreateFrame("Button", format("Vd%dH%d", aPanelNum, aButtonNum), _G[format("Vd%d", aPanelNum)], "VuhDoButtonSecureTemplate");

		VUHDO_fastCacheInitButton(aPanelNum, aButtonNum);
		VUHDO_initLocalVars(aPanelNum);
		VUHDO_initHealButton(tNewButton, aPanelNum);
		VUHDO_positionHealButton(tNewButton, aPanelNum);

		if not VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
			tFunc = (VUHDO_CONFIG["HIDE_EMPTY_BUTTONS"] and not VUHDO_IS_PANEL_CONFIG and not VUHDO_isConfigDemoUsers())
				and RegisterUnitWatch or UnregisterUnitWatch;

			tFunc(tNewButton);
		end
	end

	return VUHDO_BUTTONS_PER_PANEL[aPanelNum][aButtonNum];

end



--
function VUHDO_getPanelButtons(aPanelNum)
	return VUHDO_BUTTONS_PER_PANEL[aPanelNum];
end



--
function VUHDO_getBarPrivateAura(aButton, anIconNumber)

	return _G[format("%sBgBarHlBarPa%d", aButton:GetName(), anIconNumber)];

end
