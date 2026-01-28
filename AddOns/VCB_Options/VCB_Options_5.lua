-- some variables --
local G = VDW.Local.Override
local L = VDW.VCB.Local
local C = VDW.GetAddonColors("VCB")
local prefixTip = VDW.Prefix("VCB")
local prefixChat = VDW.PrefixChat("VCB")
local maxW = 160
local finalW = 0
local counter = 0
local textPosition = {G.OPTIONS_V_HIDE, G.OPTIONS_P_TOPLEFT, G.OPTIONS_P_LEFT, G.OPTIONS_P_BOTTOMLEFT, G.OPTIONS_P_TOP, G.OPTIONS_P_CENTER, G.OPTIONS_P_BOTTOM, G.OPTIONS_P_TOPRIGHT, G.OPTIONS_P_RIGHT, G.OPTIONS_P_BOTTOMRIGHT}
local textDecimals = {"0", "1", "2", "3"}
local textSec = {G.OPTIONS_V_HIDE, G.OPTIONS_V_SHOW}
local textDirection = {G.OPTIONS_D_ASCENDING, G.OPTIONS_D_DESCENDING, G.OPTIONS_P_BOTH}
local iconPosition = {G.OPTIONS_V_HIDE, G.OPTIONS_P_LEFT, G.OPTIONS_P_RIGHT, G.OPTIONS_P_BOTH}
local barColor = {G.OPTIONS_C_DEFAULT, G.OPTIONS_C_CLASS}
local barStyle = {G.OPTIONS_C_DEFAULT,}
local barLock = {G.OPTIONS_LS_LOCKED, G.OPTIONS_LS_UNLOCKED, "S.U.F"}
-- Taking care of the option panel --
vcbOptions5:ClearAllPoints()
vcbOptions5:SetPoint("TOPLEFT", vcbOptions0, "TOPLEFT", 0, 0)
-- Background of the option panel --
vcbOptions5.BGtexture:SetTexture("Interface\\FontStyles\\FontStyleParchment.blp", "CLAMP", "CLAMP", "NEAREST")
vcbOptions5.BGtexture:SetVertexColor(C.High:GetRGB())
vcbOptions5.BGtexture:SetDesaturation(0.3)
-- Title of the option panel --
vcbOptions5.Title:SetTextColor(C.Main:GetRGB())
vcbOptions5.Title:SetText(prefixTip.."|nVersion: "..C.High:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Version")))
-- Top text of the option panel --
vcbOptions5.TopTxt:SetTextColor(C.Main:GetRGB())
vcbOptions5.TopTxt:SetText(L.P_ARENA)
-- Bottom right text of the option panel --
vcbOptions5.BottomRightTxt:SetTextColor(C.Main:GetRGB())
vcbOptions5.BottomRightTxt:SetText(C_AddOns.GetAddOnMetadata("VCB", "X-Website"))
-- taking care of the boxes --
vcbOptions5Box1.Title:SetText(L.B_CCT)
vcbOptions5Box2.Title:SetText(L.B_BCT)
vcbOptions5Box2:SetPoint("TOPLEFT", vcbOptions5Box3, "BOTTOMLEFT", 0, 0)
vcbOptions5Box3.Title:SetText(L.B_TCT)
vcbOptions5Box3:SetPoint("TOPLEFT", vcbOptions5Box1, "BOTTOMLEFT", 0, 0)
vcbOptions5Box4.Title:SetText(L.B_SN)
vcbOptions5Box4:SetPoint("TOPLEFT", vcbOptions5Box6, "BOTTOMLEFT", 0, 0)
vcbOptions5Box5.Title:SetText(L.B_SI)
vcbOptions5Box5:SetPoint("TOPLEFT", vcbOptions5Box4, "BOTTOMLEFT", 0, 0)
vcbOptions5Box6.Title:SetText(L.B_SB)
vcbOptions5Box6:SetPoint("TOPLEFT", vcbOptions5Box1, "TOPRIGHT", 0, 0)
vcbOptions5Box7.Title:SetText(L.B_BB)
vcbOptions5Box7:SetPoint("TOPLEFT", vcbOptions5Box6, "TOPRIGHT", 0, 0)
vcbOptions5Box8.Title:SetText(L.B_UCB)
vcbOptions5Box8:SetPoint("TOPLEFT", vcbOptions5Box2, "TOPRIGHT", 0, 0)
for i = 1, 8, 1 do
	local tW = _G["vcbOptions5Box"..i].Title:GetStringWidth()+16
	local W = _G["vcbOptions5Box"..i]:GetWidth()
	if tW >= W then
		_G["vcbOptions5Box"..i]:SetWidth(_G["vcbOptions5Box"..i].Title:GetStringWidth()+16)
	end
end
-- Coloring the boxes --
for i = 1, 8, 1 do
	_G["vcbOptions5Box"..i].Title:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions5Box"..i].BorderTop:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions5Box"..i].BorderBottom:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions5Box"..i].BorderLeft:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions5Box"..i].BorderRight:SetVertexColor(C.High:GetRGB())
end
-- Coloring the pop out buttons --
local function ColoringPopOutButtons(k, var1)
	_G["vcbOptions5Box"..k.."PopOut"..var1].Text:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions5Box"..k.."PopOut"..var1].Title:SetTextColor(C.High:GetRGB())
	_G["vcbOptions5Box"..k.."PopOut"..var1].NormalTexture:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions5Box"..k.."PopOut"..var1].HighlightTexture:SetVertexColor(C.Main:GetRGB())
	_G["vcbOptions5Box"..k.."PopOut"..var1].PushedTexture:SetVertexColor(C.High:GetRGB())
end
-- check button enable - disable --
local function checkButtonEnable(self)
	self:EnableMouse(true)
	self.Text:SetTextColor(C.Main:GetRGB())
end
local function checkButtonDisable(self)
	self:SetChecked(false)
	self:EnableMouse(false)
	self.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
end
-- pop out button enable - disable --
local function popEnable(self)
	self:EnableMouse(true)
	self:SetAlpha(1)
end
local function popDisable(self)
	self:EnableMouse(false)
	self:SetAlpha(0.35)
end
-- slider enable - disable --
local function sliderEnable(self)
	self.Slider:EnableMouse(true)
	self.Back:EnableMouse(true)
	self.Forward:EnableMouse(true)
	self:SetAlpha(1)
end
local function sliderDisable(self)
	self.Slider:EnableMouse(false)
	self.Back:EnableMouse(false)
	self.Forward:EnableMouse(false)
	self:SetAlpha(0.35)
end
-- Mouse Wheel on Sliders --
local function MouseWheelSlider(self, delta)
	if delta == 1 then
		self:SetValue(self:GetValue() + 1)
	elseif delta == -1 then
		self:SetValue(self:GetValue() - 1)
	end
end
-- Pop out 1 Buttons text position  --
for k = 1, 4, 1 do
	_G["vcbOptions5Box"..k.."PopOut1"].Title:SetText(L.W_POSITION)
	ColoringPopOutButtons(k, 1)
	for i, name in ipairs(textPosition) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions5Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut1"])
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", "vcbOptions5Box"..k.."PopOut1", "BOTTOM", 0, 4)
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut1Choice1"])
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Arena"]["CurrentTimeText"]["Position"] = self.Text:GetText()
					chkCurrentTxtArena()
					chkCurrentUpdArena()
				elseif k== 2 then
					VCBsettings["Arena"]["BothTimeText"]["Position"] = self.Text:GetText()
					chkBothTxtArena()
					chkBothUpdArena()
				elseif k == 3 then
					VCBsettings["Arena"]["TotalTimeText"]["Position"] = self.Text:GetText()
					chkTotalTxtArena()
					chkTotalUpdArena()
				elseif k == 4 then
					VCBsettings["Arena"]["NameText"]["Position"] = self.Text:GetText()
					chkNameTxtArena()
				end
				_G["vcbOptions5Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions5Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions5Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions5Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
	end)
	_G["vcbOptions5Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions5Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions5Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions5Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions5Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 2 Buttons decimals and sec  --
for k = 1, 3, 1 do
-- decimals --
	_G["vcbOptions5Box"..k.."PopOut2"].Title:SetText(L.W_DECIMALS)
	ColoringPopOutButtons(k, 2)
	for i, name in ipairs(textDecimals) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions5Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut2"])
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions5Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut2Choice1"])
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetWidth(128)
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] = self.Text:GetText()
					chkCurrentUpdArena()
				elseif k== 2 then
					VCBsettings["Arena"]["BothTimeText"]["Decimals"] = self.Text:GetText()
					chkBothUpdArena()
				elseif k == 3 then
					VCBsettings["Arena"]["TotalTimeText"]["Decimals"] = self.Text:GetText()
					chkTotalUpdArena()
				end
				_G["vcbOptions5Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions5Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions5Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions5Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DECIMALS_TIP, C.Main)
	end)
	_G["vcbOptions5Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions5Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions5Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions5Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions5Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
-- sec --
	_G["vcbOptions5Box"..k.."PopOut3"].Title:SetText("'Sec'")
	ColoringPopOutButtons(k, 3)
	for i, name in ipairs(textSec) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions5Box"..k.."PopOut3Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut3"])
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", "vcbOptions5Box"..k.."PopOut3", "BOTTOM", 0, 4)
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut3Choice1"])
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut3Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:Show()
		end
		_G["vcbOptions5Box"..k.."PopOut3Choice"..i].Text:SetText(name)
		_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetWidth(128)
		_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Arena"]["CurrentTimeText"]["Sec"] = self.Text:GetText()
					chkCurrentUpdArena()
				elseif k== 2 then
					VCBsettings["Arena"]["BothTimeText"]["Sec"] = self.Text:GetText()
					chkBothUpdArena()
				elseif k == 3 then
					VCBsettings["Arena"]["TotalTimeText"]["Sec"] = self.Text:GetText()
					chkTotalUpdArena()
				end
				_G["vcbOptions5Box"..k.."PopOut3"].Text:SetText(self.Text:GetText())
				_G["vcbOptions5Box"..k.."PopOut3Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions5Box"..k.."PopOut3Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions5Box"..k.."PopOut3Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions5Box"..k.."PopOut3"]:HookScript("OnEnter", function(self)
		local word = _G["vcbOptions2Box"..k.."PopOut3"].Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_V_TIP, word), C.Main)
	end)
	_G["vcbOptions5Box"..k.."PopOut3"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions5Box"..k.."PopOut3"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions5Box"..k.."PopOut3Choice1"]:IsShown() then
				_G["vcbOptions5Box"..k.."PopOut3Choice1"]:Show()
			else
				_G["vcbOptions5Box"..k.."PopOut3Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 4 Buttons Direction  --
for k = 1, 2, 1 do
	_G["vcbOptions5Box"..k.."PopOut4"].Title:SetText(L.W_DIRECTION)
	ColoringPopOutButtons(k, 4)
	for i, name in ipairs(textDirection) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions5Box"..k.."PopOut4Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut4"])
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", "vcbOptions5Box"..k.."PopOut4", "BOTTOM", 0, 4)
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut4Choice1"])
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut4Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:Show()
		end
		_G["vcbOptions5Box"..k.."PopOut4Choice"..i].Text:SetText(name)
		_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Arena"]["CurrentTimeText"]["Direction"] = self.Text:GetText()
					chkCurrentUpdArena()
				elseif k== 2 then
					VCBsettings["Arena"]["BothTimeText"]["Direction"] = self.Text:GetText()
					chkBothUpdArena()
				end
				_G["vcbOptions5Box"..k.."PopOut4"].Text:SetText(self.Text:GetText())
				_G["vcbOptions5Box"..k.."PopOut4Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions5Box"..k.."PopOut4Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions5Box"..k.."PopOut4Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions5Box"..k.."PopOut4"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DIRECTION_TIP, C.Main)
	end)
	_G["vcbOptions5Box"..k.."PopOut4"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions5Box"..k.."PopOut4"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions5Box"..k.."PopOut4Choice1"]:IsShown() then
				_G["vcbOptions5Box"..k.."PopOut4Choice1"]:Show()
			else
				_G["vcbOptions5Box"..k.."PopOut4Choice1"]:Hide()
			end
		end
	end)
end
-- Icon --
ColoringPopOutButtons(5, 1)
vcbOptions5Box5PopOut1.Title:SetText(L.W_POSITION)
for i, name in ipairs(iconPosition) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions5Box5PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions5Box5PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions5Box5PopOut1Choice"..i]:SetParent(vcbOptions5Box5PopOut1)
		_G["vcbOptions5Box5PopOut1Choice"..i]:SetPoint("TOP", vcbOptions5Box5PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions5Box5PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions5Box5PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions5Box5PopOut1Choice"..i]:SetParent(vcbOptions5Box5PopOut1Choice1)
		_G["vcbOptions5Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions5Box5PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions5Box5PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions5Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBsettings["Arena"]["Icon"]["Position"] = self.Text:GetText()
			vcbOptions5Box5PopOut1.Text:SetText(self.Text:GetText())
			if VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				checkButtonDisable(vcbOptions5Box5CheckButton1)
				VCBsettings["Arena"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			else
				checkButtonEnable(vcbOptions5Box5CheckButton1)
			end
			chkIconArena()
			vcbOptions5Box5PopOut1Choice1:Hide()
		end
	end)
	local w = _G["vcbOptions5Box5PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions5Box5PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions5Box5PopOut1:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
end)
vcbOptions5Box5PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions5Box5PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions5Box5PopOut1Choice1:IsShown() then
			vcbOptions5Box5PopOut1Choice1:Show()
		else
			vcbOptions5Box5PopOut1Choice1:Hide()
		end
	end
end)
-- check button show - hide shield icon --
vcbOptions5Box5CheckButton1.Text:SetText(L.W_SHIELD)
vcbOptions5Box5CheckButton1:SetScript("OnEnter", function(self)
	local word = self.Text:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_CHECKBOX_TIP, word), C.Main)
end)
vcbOptions5Box5CheckButton1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions5Box5CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBsettings["Arena"]["Icon"]["Shield"] = G.OPTIONS_V_SHOW
			self.Text:SetTextColor(C.Main:GetRGB())
			PlaySound(858, "Master")
		elseif self:GetChecked() == false then
			VCBsettings["Arena"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			self.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
			PlaySound(858, "Master")
		end
		chkIconArena()
	end
end)
local bW = vcbOptions5Box5:GetWidth()
local tbW = (vcbOptions5Box5CheckButton1.Text:GetStringWidth() + vcbOptions5Box5CheckButton1:GetWidth() + 16)
if tbW >= bW then
	vcbOptions5Box5:SetWidth(tbW)
end
-- color & style of bar & border --
for k = 6, 7, 1 do
-- color --
	ColoringPopOutButtons(k, 1)
	_G["vcbOptions5Box"..k.."PopOut1"].Title:SetText(L.W_COLOR)
	for i, name in ipairs(barColor) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions5Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut1"])
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut1"], "BOTTOM", 0, 4)
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut1Choice1"])
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetWidth(128)
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 6 then
					VCBsettings["Arena"]["StatusBar"]["Color"] = self.Text:GetText()
					chkCastbarColorArena()
				elseif k == 7 then
					VCBsettings["Arena"]["Border"]["Color"] = self.Text:GetText()
					chkBorderColorArena()
				end
				_G["vcbOptions5Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions5Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions5Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions5Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions5Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_C_TIP, word), C.Main)
	end)
	_G["vcbOptions5Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions5Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions5Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions5Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions5Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
-- style --
	ColoringPopOutButtons(k, 2)
	_G["vcbOptions5Box"..k.."PopOut2"].Title:SetText(L.W_STYLE)
	for i, name in ipairs(barStyle) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions5Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut2"])
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions5Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions5Box"..k.."PopOut2Choice1"])
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 6 then
					VCBsettings["Arena"]["StatusBar"]["Style"] = self.Text:GetText()
				elseif k== 7 then
					VCBsettings["Arena"]["Border"]["Style"] = self.Text:GetText()
				end
				_G["vcbOptions5Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions5Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions5Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions5Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions5Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_S_TIP, word), C.Main)
	end)
	_G["vcbOptions5Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions5Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions5Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions5Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions5Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
end
-- pop out button Unlock the Castbar --
ColoringPopOutButtons(8, 1)
vcbOptions5Box8PopOut1.Title:SetText(L.W_LOCK)
for i, name in ipairs(barLock) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions5Box8PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions5Box8PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions5Box8PopOut1Choice"..i]:SetParent(vcbOptions5Box8PopOut1)
		_G["vcbOptions5Box8PopOut1Choice"..i]:SetPoint("TOP", vcbOptions5Box8PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions5Box8PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions5Box8PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions5Box8PopOut1Choice"..i]:SetParent(vcbOptions5Box8PopOut1Choice1)
		_G["vcbOptions5Box8PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box8PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions5Box8PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions5Box8PopOut1Choice"..i].Text:SetText(name)
	if i ==3 then
		_G["vcbOptions5Box8PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
				if finished then
					VCBsettings["Arena"]["Lock"] = self.Text:GetText()
					vcbOptions5Box8PopOut1.Text:SetText(self.Text:GetText())
					sliderEnable(vcbOptions5Box8Slider1)
					vcbOptions5Box8PopOut1Choice1:Hide()
					C_UI.Reload()
				else
					C_Sound.PlayVocalErrorSound(48)
					DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat..L.WRN_NO_SUF))
				end
			end
		end)
	else
		_G["vcbOptions5Box8PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				VCBsettings["Arena"]["Lock"] = self.Text:GetText()
				vcbOptions5Box8PopOut1.Text:SetText(self.Text:GetText())
				if VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_LOCKED then
					sliderDisable(vcbOptions5Box8Slider1)
					vcbOptions5Box8Slider1.Slider:SetValue(100)
				elseif VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
					sliderEnable(vcbOptions5Box8Slider1)
				end
				vcbOptions5Box8PopOut1Choice1:Hide()
				C_UI.Reload()
			end
		end)
	end
	local w = _G["vcbOptions5Box8PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions5Box8PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions5Box8PopOut1:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.W_LOCK_TIP_A, C.Main)
end)
vcbOptions5Box8PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions5Box8PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions5Box8PopOut1Choice1:IsShown() then
			vcbOptions5Box8PopOut1Choice1:Show()
		else
			vcbOptions5Box8PopOut1Choice1:Hide()
		end
	end
end)
-- slide bar 1 scale of the bar --
vcbOptions5Box8Slider1.Slider.Thumb:SetVertexColor(C.Main:GetRGB())
vcbOptions5Box8Slider1.Back:GetRegions():SetVertexColor(C.Main:GetRGB())
vcbOptions5Box8Slider1.Forward:GetRegions():SetVertexColor(C.Main:GetRGB())
vcbOptions5Box8Slider1.TopText:SetTextColor(C.High:GetRGB())
vcbOptions5Box8Slider1.MinText:SetTextColor(C.High:GetRGB())
vcbOptions5Box8Slider1.MaxText:SetTextColor(C.High:GetRGB())
vcbOptions5Box8Slider1.MinText:SetText(0.10)
vcbOptions5Box8Slider1.MaxText:SetText(2)
vcbOptions5Box8Slider1.Slider:SetMinMaxValues(10, 200)
-- enter --
vcbOptions5Box8Slider1.Slider:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.W_SLIDER_TIP, C.Main)
end)
-- leave --
vcbOptions5Box8Slider1.Slider:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- mouse wheel --
vcbOptions5Box8Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- value change --
vcbOptions5Box8Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions5Box8Slider1.TopText:SetText("Scale: "..(self:GetValue()/100))
	VCBsettings["Arena"]["Scale"] = self:GetValue()
	for i = 1, 3, 1 do
		_G["ArenaVCBpreview"..i]:SetScale(VCBsettings["Arena"]["Scale"]/100)
	end
	PlaySound(858, "Master")
end)
-- taking care of the cast bar preview --
ArenaVCBpreview1.Text:SetText(L.W_ARENA)
-- enter --
ArenaVCBpreview1:SetScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, G.BUTTON_L_CLICK..G.TIP_DRAG_ME, C.Main) 
end)
-- leave --
ArenaVCBpreview1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBsettings["Arena"]["Position"]["X"] = Round(self:GetLeft())
	VCBsettings["Arena"]["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the preview --
ArenaVCBpreview1:RegisterForDrag("LeftButton")
ArenaVCBpreview1:SetScript("OnDragStart", ArenaVCBpreview1.StartMoving)
ArenaVCBpreview1:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the preview --
ArenaVCBpreview1:SetScript("OnHide", function(self)
	VCBsettings["Arena"]["Position"]["X"] = Round(self:GetLeft())
	VCBsettings["Arena"]["Position"]["Y"] = Round(self:GetBottom())
end)
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions5Box1PopOut1.Text:SetText(VCBsettings["Arena"]["CurrentTimeText"]["Position"])
	vcbOptions5Box2PopOut1.Text:SetText(VCBsettings["Arena"]["BothTimeText"]["Position"])
	vcbOptions5Box3PopOut1.Text:SetText(VCBsettings["Arena"]["TotalTimeText"]["Position"])
	vcbOptions5Box1PopOut2.Text:SetText(VCBsettings["Arena"]["CurrentTimeText"]["Decimals"])
	vcbOptions5Box2PopOut2.Text:SetText(VCBsettings["Arena"]["BothTimeText"]["Decimals"])
	vcbOptions5Box3PopOut2.Text:SetText(VCBsettings["Arena"]["TotalTimeText"]["Decimals"])
	vcbOptions5Box1PopOut3.Text:SetText(VCBsettings["Arena"]["CurrentTimeText"]["Sec"])
	vcbOptions5Box2PopOut3.Text:SetText(VCBsettings["Arena"]["BothTimeText"]["Sec"])
	vcbOptions5Box3PopOut3.Text:SetText(VCBsettings["Arena"]["TotalTimeText"]["Sec"])
	vcbOptions5Box1PopOut4.Text:SetText(VCBsettings["Arena"]["CurrentTimeText"]["Direction"])
	vcbOptions5Box2PopOut4.Text:SetText(VCBsettings["Arena"]["BothTimeText"]["Direction"])
	vcbOptions5Box4PopOut1.Text:SetText(VCBsettings["Arena"]["NameText"]["Position"])
	vcbOptions5Box5PopOut1.Text:SetText(VCBsettings["Arena"]["Icon"]["Position"])
	if VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
		checkButtonDisable(vcbOptions5Box5CheckButton1)
	else
		checkButtonEnable(vcbOptions5Box5CheckButton1)
		if VCBsettings["Arena"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			vcbOptions5Box5CheckButton1:SetChecked(true)
			vcbOptions5Box5CheckButton1.Text:SetTextColor(C.Main:GetRGB())
		elseif VCBsettings["Arena"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			vcbOptions5Box5CheckButton1:SetChecked(false)
			vcbOptions5Box5CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
		end
	end
	vcbOptions5Box6PopOut1.Text:SetText(VCBsettings["Arena"]["StatusBar"]["Color"])
	vcbOptions5Box6PopOut2.Text:SetText(VCBsettings["Arena"]["StatusBar"]["Style"])
	vcbOptions5Box7PopOut1.Text:SetText(VCBsettings["Arena"]["Border"]["Color"])
	vcbOptions5Box7PopOut2.Text:SetText(VCBsettings["Arena"]["Border"]["Style"])
	vcbOptions5Box8PopOut1.Text:SetText(VCBsettings["Arena"]["Lock"])
	if VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_LOCKED then
		sliderDisable(vcbOptions5Box8Slider1)
	else
		sliderEnable(vcbOptions5Box8Slider1)
	end
	vcbOptions5Box8Slider1.Slider:SetValue(VCBsettings["Arena"]["Scale"])
	if VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_UNLOCKED or VCBsettings["Arena"]["Lock"] == "S.U.F" then
		ArenaVCBpreview1:ClearAllPoints()
		ArenaVCBpreview1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Arena"]["Position"]["X"], VCBsettings["Arena"]["Position"]["Y"])
		ArenaVCBpreview1:Show()
		for i = 2, 3, 1 do
			_G["ArenaVCBpreview"..i]:ClearAllPoints()
			_G["ArenaVCBpreview"..i]:SetPoint("TOP", _G["ArenaVCBpreview"..i-1], "BOTTOM", 0, -32)
			if not _G["ArenaVCBpreview"..i]:IsShown() then _G["ArenaVCBpreview"..i]:Show() end
		end
	else
		for i = 1, 3, 1 do
			if _G["ArenaVCBpreview"..i]:IsShown() then _G["ArenaVCBpreview"..i]:Hide() end
		end
	end
end
-- Show the option panel --
vcbOptions5:HookScript("OnShow", function(self)
	for i = 1, 4, 1 do
		_G["vcbOptions0Tab"..i].Text:SetTextColor(0.4, 0.4, 0.4, 1)
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
	vcbOptions0Tab5.Text:SetTextColor(C.High:GetRGB())
	vcbOptions0Tab6.Text:SetTextColor(0.4, 0.4, 0.4, 1)
	if vcbOptions6:IsShown() then vcbOptions6:Hide() end
	CheckSavedVariables()
end)
-- Hide the option panel --
vcbOptions5:HookScript("OnHide", function(self)
	for i = 1, 3, 1 do
			if _G["ArenaVCBpreview"..i]:IsShown() then _G["ArenaVCBpreview"..i]:Hide() end
		end
end)
