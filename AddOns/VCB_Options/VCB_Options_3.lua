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
vcbOptions3:ClearAllPoints()
vcbOptions3:SetPoint("TOPLEFT", vcbOptions0, "TOPLEFT", 0, 0)
-- Background of the option panel --
vcbOptions3.BGtexture:SetTexture("Interface\\FontStyles\\FontStyleParchment.blp", "CLAMP", "CLAMP", "NEAREST")
vcbOptions3.BGtexture:SetVertexColor(C.High:GetRGB())
vcbOptions3.BGtexture:SetDesaturation(0.3)
-- Title of the option panel --
vcbOptions3.Title:SetTextColor(C.Main:GetRGB())
vcbOptions3.Title:SetText(prefixTip.."|nVersion: "..C.High:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Version")))
-- Top text of the option panel --
vcbOptions3.TopTxt:SetTextColor(C.Main:GetRGB())
vcbOptions3.TopTxt:SetText(L.P_FOCUS)
-- Bottom right text of the option panel --
vcbOptions3.BottomRightTxt:SetTextColor(C.Main:GetRGB())
vcbOptions3.BottomRightTxt:SetText(C_AddOns.GetAddOnMetadata("VCB", "X-Website"))
-- taking care of the boxes --
vcbOptions3Box1.Title:SetText(L.B_CCT)
vcbOptions3Box2.Title:SetText(L.B_BCT)
vcbOptions3Box2:SetPoint("TOPLEFT", vcbOptions3Box3, "BOTTOMLEFT", 0, 0)
vcbOptions3Box3.Title:SetText(L.B_TCT)
vcbOptions3Box3:SetPoint("TOPLEFT", vcbOptions3Box1, "BOTTOMLEFT", 0, 0)
vcbOptions3Box4.Title:SetText(L.B_SN)
vcbOptions3Box4:SetPoint("TOPLEFT", vcbOptions3Box6, "BOTTOMLEFT", 0, 0)
vcbOptions3Box5.Title:SetText(L.B_SI)
vcbOptions3Box5:SetPoint("TOPLEFT", vcbOptions3Box4, "BOTTOMLEFT", 0, 0)
vcbOptions3Box6.Title:SetText(L.B_SB)
vcbOptions3Box6:SetPoint("TOPLEFT", vcbOptions3Box1, "TOPRIGHT", 0, 0)
vcbOptions3Box7.Title:SetText(L.B_BB)
vcbOptions3Box7:SetPoint("TOPLEFT", vcbOptions3Box6, "TOPRIGHT", 0, 0)
vcbOptions3Box8.Title:SetText(L.B_UCB)
vcbOptions3Box8:SetPoint("TOPLEFT", vcbOptions3Box2, "TOPRIGHT", 0, 0)
for i = 1, 8, 1 do
	local tW = _G["vcbOptions3Box"..i].Title:GetStringWidth()+16
	local W = _G["vcbOptions3Box"..i]:GetWidth()
	if tW >= W then
		_G["vcbOptions3Box"..i]:SetWidth(_G["vcbOptions3Box"..i].Title:GetStringWidth()+16)
	end
end
-- Coloring the boxes --
for i = 1, 8, 1 do
	_G["vcbOptions3Box"..i].Title:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions3Box"..i].BorderTop:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions3Box"..i].BorderBottom:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions3Box"..i].BorderLeft:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions3Box"..i].BorderRight:SetVertexColor(C.High:GetRGB())
end
-- Coloring the pop out buttons --
local function ColoringPopOutButtons(k, var1)
	_G["vcbOptions3Box"..k.."PopOut"..var1].Text:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions3Box"..k.."PopOut"..var1].Title:SetTextColor(C.High:GetRGB())
	_G["vcbOptions3Box"..k.."PopOut"..var1].NormalTexture:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions3Box"..k.."PopOut"..var1].HighlightTexture:SetVertexColor(C.Main:GetRGB())
	_G["vcbOptions3Box"..k.."PopOut"..var1].PushedTexture:SetVertexColor(C.High:GetRGB())
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
	_G["vcbOptions3Box"..k.."PopOut1"].Title:SetText(L.W_POSITION)
	ColoringPopOutButtons(k, 1)
	for i, name in ipairs(textPosition) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions3Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut1"])
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", "vcbOptions3Box"..k.."PopOut1", "BOTTOM", 0, 4)
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut1Choice1"])
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Focus"]["CurrentTimeText"]["Position"] = self.Text:GetText()
					chkCurrentTxtFocus()
					chkCurrentUpdFocus()
				elseif k== 2 then
					VCBsettings["Focus"]["BothTimeText"]["Position"] = self.Text:GetText()
					chkBothTxtFocus()
					chkBothUpdFocus()
				elseif k == 3 then
					VCBsettings["Focus"]["TotalTimeText"]["Position"] = self.Text:GetText()
					chkTotalTxtFocus()
					chkTotalUpdFocus()
				elseif k == 4 then
					VCBsettings["Focus"]["NameText"]["Position"] = self.Text:GetText()
					chkNameTxtFocus()
				end
				_G["vcbOptions3Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions3Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions3Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions3Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main) 
	end)
	_G["vcbOptions3Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions3Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions3Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions3Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions3Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 2 Buttons decimals and sec  --
for k = 1, 3, 1 do
-- decimals --
	_G["vcbOptions3Box"..k.."PopOut2"].Title:SetText(L.W_DECIMALS)
	ColoringPopOutButtons(k, 2)
	for i, name in ipairs(textDecimals) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions3Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut2"])
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions3Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut2Choice1"])
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] = self.Text:GetText()
					chkCurrentUpdFocus()
				elseif k== 2 then
					VCBsettings["Focus"]["BothTimeText"]["Decimals"] = self.Text:GetText()
					chkBothUpdFocus()
				elseif k == 3 then
					VCBsettings["Focus"]["TotalTimeText"]["Decimals"] = self.Text:GetText()
					chkTotalUpdFocus()
				end
				_G["vcbOptions3Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions3Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions3Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions3Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DECIMALS_TIP, C.Main, C.Main)
	end)
	_G["vcbOptions3Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions3Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions3Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions3Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions3Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
-- sec --
	_G["vcbOptions3Box"..k.."PopOut3"].Title:SetText("'Sec'")
	ColoringPopOutButtons(k, 3)
	for i, name in ipairs(textSec) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions3Box"..k.."PopOut3Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut3"])
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", "vcbOptions3Box"..k.."PopOut3", "BOTTOM", 0, 4)
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut3Choice1"])
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut3Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:Show()
		end
		_G["vcbOptions3Box"..k.."PopOut3Choice"..i].Text:SetText(name)
		_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Focus"]["CurrentTimeText"]["Sec"] = self.Text:GetText()
					chkCurrentUpdFocus()
				elseif k== 2 then
					VCBsettings["Focus"]["BothTimeText"]["Sec"] = self.Text:GetText()
					chkBothUpdFocus()
				elseif k == 3 then
					VCBsettings["Focus"]["TotalTimeText"]["Sec"] = self.Text:GetText()
					chkTotalUpdFocus()
				end
				_G["vcbOptions3Box"..k.."PopOut3"].Text:SetText(self.Text:GetText())
				_G["vcbOptions3Box"..k.."PopOut3Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions3Box"..k.."PopOut3Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box"..k.."PopOut3Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions3Box"..k.."PopOut3"]:HookScript("OnEnter", function(self)
		local word = _G["vcbOptions2Box"..k.."PopOut3"].Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_V_TIP, word), C.Main) 
	end)
	_G["vcbOptions3Box"..k.."PopOut3"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions3Box"..k.."PopOut3"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions3Box"..k.."PopOut3Choice1"]:IsShown() then
				_G["vcbOptions3Box"..k.."PopOut3Choice1"]:Show()
			else
				_G["vcbOptions3Box"..k.."PopOut3Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 4 Buttons Direction  --
for k = 1, 2, 1 do
	_G["vcbOptions3Box"..k.."PopOut4"].Title:SetText(L.W_DIRECTION)
	ColoringPopOutButtons(k, 4)
	for i, name in ipairs(textDirection) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions3Box"..k.."PopOut4Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut4"])
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", "vcbOptions3Box"..k.."PopOut4", "BOTTOM", 0, 4)
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut4Choice1"])
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut4Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:Show()
		end
		_G["vcbOptions3Box"..k.."PopOut4Choice"..i].Text:SetText(name)
		_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Focus"]["CurrentTimeText"]["Direction"] = self.Text:GetText()
					chkCurrentUpdFocus()
				elseif k== 2 then
					VCBsettings["Focus"]["BothTimeText"]["Direction"] = self.Text:GetText()
					chkBothUpdFocus()
				end
				_G["vcbOptions3Box"..k.."PopOut4"].Text:SetText(self.Text:GetText())
				_G["vcbOptions3Box"..k.."PopOut4Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions3Box"..k.."PopOut4Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box"..k.."PopOut4Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions3Box"..k.."PopOut4"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DIRECTION_TIP, C.Main) 
	end)
	_G["vcbOptions3Box"..k.."PopOut4"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions3Box"..k.."PopOut4"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions3Box"..k.."PopOut4Choice1"]:IsShown() then
				_G["vcbOptions3Box"..k.."PopOut4Choice1"]:Show()
			else
				_G["vcbOptions3Box"..k.."PopOut4Choice1"]:Hide()
			end
		end
	end)
end
-- Icon --
ColoringPopOutButtons(5, 1)
vcbOptions3Box5PopOut1.Title:SetText(L.W_POSITION)
for i, name in ipairs(iconPosition) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions3Box5PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions3Box5PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetParent(vcbOptions3Box5PopOut1)
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetPoint("TOP", vcbOptions3Box5PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetParent(vcbOptions3Box5PopOut1Choice1)
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions3Box5PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions3Box5PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions3Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBsettings["Focus"]["Icon"]["Position"] = self.Text:GetText()
			vcbOptions3Box5PopOut1.Text:SetText(self.Text:GetText())
			if VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				checkButtonDisable(vcbOptions3Box5CheckButton1)
				VCBsettings["Focus"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			else
				checkButtonEnable(vcbOptions3Box5CheckButton1)
			end
			chkIconFocus()
			vcbOptions3Box5PopOut1Choice1:Hide()
		end
	end)
	local w = _G["vcbOptions3Box5PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box5PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
maxW = 160
vcbOptions3Box5PopOut1:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
end)
vcbOptions3Box5PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions3Box5PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions3Box5PopOut1Choice1:IsShown() then
			vcbOptions3Box5PopOut1Choice1:Show()
		else
			vcbOptions3Box5PopOut1Choice1:Hide()
		end
	end
end)
-- check button show - hide shield icon --
vcbOptions3Box5CheckButton1.Text:SetText(L.W_SHIELD)
vcbOptions3Box5CheckButton1:SetScript("OnEnter", function(self)
	local word = self.Text:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_CHECKBOX_TIP, word), C.Main)
end)
vcbOptions3Box5CheckButton1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions3Box5CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBsettings["Focus"]["Icon"]["Shield"] = G.OPTIONS_V_SHOW
			self.Text:SetTextColor(C.Main:GetRGB())
			PlaySound(858, "Master")
		elseif self:GetChecked() == false then
			VCBsettings["Focus"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			self.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
			PlaySound(858, "Master")
		end
		chkIconFocus()
	end
end)
local bW = vcbOptions3Box5:GetWidth()
local tbW = (vcbOptions3Box5CheckButton1.Text:GetStringWidth() + vcbOptions3Box5CheckButton1:GetWidth() + 16)
if tbW >= bW then
	vcbOptions3Box5:SetWidth(tbW)
end
-- color & style of bar & border --
for k = 6, 7, 1 do
-- color --
	ColoringPopOutButtons(k, 1)
	_G["vcbOptions3Box"..k.."PopOut1"].Title:SetText(L.W_COLOR)
	for i, name in ipairs(barColor) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions3Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut1"])
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut1"], "BOTTOM", 0, 4)
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut1Choice1"])
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 6 then
					VCBsettings["Focus"]["StatusBar"]["Color"] = self.Text:GetText()
					chkCastbarColorFocus()
				elseif k == 7 then
					VCBsettings["Focus"]["Border"]["Color"] = self.Text:GetText()
					chkBorderColorFocus()
				end
				_G["vcbOptions3Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions3Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions3Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions3Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_C_TIP, word), C.Main)
	end)
	_G["vcbOptions3Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions3Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions3Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions3Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions3Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
-- style --
	ColoringPopOutButtons(k, 2)
	_G["vcbOptions3Box"..k.."PopOut2"].Title:SetText(L.W_STYLE)
	for i, name in ipairs(barStyle) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions3Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut2"])
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions3Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions3Box"..k.."PopOut2Choice1"])
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 6 then
					VCBsettings["Focus"]["StatusBar"]["Style"] = self.Text:GetText()
				elseif k== 7 then
					VCBsettings["Focus"]["Border"]["Style"] = self.Text:GetText()
				end
				_G["vcbOptions3Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions3Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions3Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions3Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions3Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_S_TIP, word), C.Main)
	end)
	_G["vcbOptions3Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions3Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions3Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions3Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions3Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
end
-- pop out button Unlock the Castbar --
ColoringPopOutButtons(8, 1)
vcbOptions3Box8PopOut1.Title:SetText(L.W_LOCK)
for i, name in ipairs(barLock) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions3Box8PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions3Box8PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions3Box8PopOut1Choice"..i]:SetParent(vcbOptions3Box8PopOut1)
		_G["vcbOptions3Box8PopOut1Choice"..i]:SetPoint("TOP", vcbOptions3Box8PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions3Box8PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions3Box8PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions3Box8PopOut1Choice"..i]:SetParent(vcbOptions3Box8PopOut1Choice1)
		_G["vcbOptions3Box8PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box8PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions3Box8PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions3Box8PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions3Box8PopOut1Choice"..i]:SetWidth(128)
	if i ==3 then
		_G["vcbOptions3Box8PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
				if finished then
					VCBsettings["Focus"]["Lock"] = self.Text:GetText()
					vcbOptions3Box8PopOut1.Text:SetText(self.Text:GetText())
					sliderEnable(vcbOptions3Box8Slider1)
					vcbOptions3Box8PopOut1Choice1:Hide()
					C_UI.Reload()
				else
					C_Sound.PlayVocalErrorSound(48)
					DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat..L.WRN_NO_SUF))
				end
			end
		end)
	else
		_G["vcbOptions3Box8PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				VCBsettings["Focus"]["Lock"] = self.Text:GetText()
				vcbOptions3Box8PopOut1.Text:SetText(self.Text:GetText())
				if VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_LOCKED then
					sliderDisable(vcbOptions3Box8Slider1)
					vcbOptions3Box8Slider1.Slider:SetValue(100)
				elseif VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
					sliderEnable(vcbOptions3Box8Slider1)
				end
				vcbOptions3Box8PopOut1Choice1:Hide()
				C_UI.Reload()
			end
		end)
	end
	local w = _G["vcbOptions3Box8PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions3Box8PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions3Box8PopOut1:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.W_LOCK_TIP_F, C.Main)
end)
vcbOptions3Box8PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions3Box8PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions3Box8PopOut1Choice1:IsShown() then
			vcbOptions3Box8PopOut1Choice1:Show()
		else
			vcbOptions3Box8PopOut1Choice1:Hide()
		end
	end
end)
-- slide bar 1 scale of the bar --
vcbOptions3Box8Slider1.Slider.Thumb:SetVertexColor(C.Main:GetRGB())
vcbOptions3Box8Slider1.Back:GetRegions():SetVertexColor(C.Main:GetRGB())
vcbOptions3Box8Slider1.Forward:GetRegions():SetVertexColor(C.Main:GetRGB())
vcbOptions3Box8Slider1.TopText:SetTextColor(C.High:GetRGB())
vcbOptions3Box8Slider1.MinText:SetTextColor(C.High:GetRGB())
vcbOptions3Box8Slider1.MaxText:SetTextColor(C.High:GetRGB())
vcbOptions3Box8Slider1.MinText:SetText(0.10)
vcbOptions3Box8Slider1.MaxText:SetText(2)
vcbOptions3Box8Slider1.Slider:SetMinMaxValues(10, 200)
-- enter --
vcbOptions3Box8Slider1.Slider:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.W_SLIDER_TIP, C.Main)
end)
-- leave --
vcbOptions3Box8Slider1.Slider:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- mouse wheel --
vcbOptions3Box8Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- value change --
vcbOptions3Box8Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions3Box8Slider1.TopText:SetText("Scale: "..(self:GetValue()/100))
	VCBsettings["Focus"]["Scale"] = self:GetValue()
	FocusVCBpreview:SetScale(VCBsettings["Focus"]["Scale"]/100)
	PlaySound(858, "Master")
end)
-- taking care of the cast bar preview --
FocusVCBpreview.Text:SetText(L.W_FOCUS)
-- enter --
FocusVCBpreview:SetScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, G.BUTTON_L_CLICK..G.TIP_DRAG_ME, C.Main)
end)
-- leave --
FocusVCBpreview:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBsettings["Focus"]["Position"]["X"] = Round(self:GetLeft())
	VCBsettings["Focus"]["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the preview --
FocusVCBpreview:RegisterForDrag("LeftButton")
FocusVCBpreview:SetScript("OnDragStart", FocusVCBpreview.StartMoving)
FocusVCBpreview:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the preview --
FocusVCBpreview:SetScript("OnHide", function(self)
	VCBsettings["Focus"]["Position"]["X"] = Round(self:GetLeft())
	VCBsettings["Focus"]["Position"]["Y"] = Round(self:GetBottom())
end)
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions3Box1PopOut1.Text:SetText(VCBsettings["Focus"]["CurrentTimeText"]["Position"])
	vcbOptions3Box2PopOut1.Text:SetText(VCBsettings["Focus"]["BothTimeText"]["Position"])
	vcbOptions3Box3PopOut1.Text:SetText(VCBsettings["Focus"]["TotalTimeText"]["Position"])
	vcbOptions3Box1PopOut2.Text:SetText(VCBsettings["Focus"]["CurrentTimeText"]["Decimals"])
	vcbOptions3Box2PopOut2.Text:SetText(VCBsettings["Focus"]["BothTimeText"]["Decimals"])
	vcbOptions3Box3PopOut2.Text:SetText(VCBsettings["Focus"]["TotalTimeText"]["Decimals"])
	vcbOptions3Box1PopOut3.Text:SetText(VCBsettings["Focus"]["CurrentTimeText"]["Sec"])
	vcbOptions3Box2PopOut3.Text:SetText(VCBsettings["Focus"]["BothTimeText"]["Sec"])
	vcbOptions3Box3PopOut3.Text:SetText(VCBsettings["Focus"]["TotalTimeText"]["Sec"])
	vcbOptions3Box1PopOut4.Text:SetText(VCBsettings["Focus"]["CurrentTimeText"]["Direction"])
	vcbOptions3Box2PopOut4.Text:SetText(VCBsettings["Focus"]["BothTimeText"]["Direction"])
	vcbOptions3Box4PopOut1.Text:SetText(VCBsettings["Focus"]["NameText"]["Position"])
	vcbOptions3Box5PopOut1.Text:SetText(VCBsettings["Focus"]["Icon"]["Position"])
	if VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
		checkButtonDisable(vcbOptions3Box5CheckButton1)
	else
		checkButtonEnable(vcbOptions3Box5CheckButton1)
		if VCBsettings["Focus"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			vcbOptions3Box5CheckButton1:SetChecked(true)
			vcbOptions3Box5CheckButton1.Text:SetTextColor(C.Main:GetRGB())
		elseif VCBsettings["Focus"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			vcbOptions3Box5CheckButton1:SetChecked(false)
			vcbOptions3Box5CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
		end
	end
	vcbOptions3Box6PopOut1.Text:SetText(VCBsettings["Focus"]["StatusBar"]["Color"])
	vcbOptions3Box6PopOut2.Text:SetText(VCBsettings["Focus"]["StatusBar"]["Style"])
	vcbOptions3Box7PopOut1.Text:SetText(VCBsettings["Focus"]["Border"]["Color"])
	vcbOptions3Box7PopOut2.Text:SetText(VCBsettings["Focus"]["Border"]["Style"])
	vcbOptions3Box8PopOut1.Text:SetText(VCBsettings["Focus"]["Lock"])
	if VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_LOCKED then
		sliderDisable(vcbOptions3Box8Slider1)
	else
		sliderEnable(vcbOptions3Box8Slider1)
	end
	vcbOptions3Box8Slider1.Slider:SetValue(VCBsettings["Focus"]["Scale"])
	if VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_UNLOCKED or VCBsettings["Focus"]["Lock"] == "S.U.F" then
		FocusVCBpreview:ClearAllPoints()
		FocusVCBpreview:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Focus"]["Position"]["X"], VCBsettings["Focus"]["Position"]["Y"])
		if not FocusVCBpreview:IsShown() then FocusVCBpreview:Show() end
	else
		if FocusVCBpreview:IsShown() then FocusVCBpreview:Hide() end
	end
end
-- Show the option panel --
vcbOptions3:HookScript("OnShow", function(self)
	for i = 1, 2, 1 do
		_G["vcbOptions0Tab"..i].Text:SetTextColor(0.4, 0.4, 0.4, 1)
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
	vcbOptions0Tab3.Text:SetTextColor(C.High:GetRGB())
	for i = 4, 6, 1 do
		_G["vcbOptions0Tab"..i].Text:SetTextColor(0.4, 0.4, 0.4, 1)
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
	CheckSavedVariables()
end)
-- Hide the option panel --
vcbOptions3:HookScript("OnHide", function(self)
	if FocusVCBpreview:IsShown() then FocusVCBpreview:Hide() end
end)
