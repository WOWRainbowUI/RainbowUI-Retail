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
vcbOptions2:ClearAllPoints()
vcbOptions2:SetPoint("TOPLEFT", vcbOptions0, "TOPLEFT", 0, 0)
-- Background of the option panel --
vcbOptions2.BGtexture:SetTexture("Interface\\FontStyles\\FontStyleParchment.blp", "CLAMP", "CLAMP", "NEAREST")
vcbOptions2.BGtexture:SetVertexColor(C.High:GetRGB())
vcbOptions2.BGtexture:SetDesaturation(0.3)
-- Title of the option panel --
vcbOptions2.Title:SetTextColor(C.Main:GetRGB())
vcbOptions2.Title:SetText(prefixTip.."|nVersion: "..C.High:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Version")))
-- Top text of the option panel --
vcbOptions2.TopTxt:SetTextColor(C.Main:GetRGB())
vcbOptions2.TopTxt:SetText(L.P_TARGET)
-- Bottom right text of the option panel --
vcbOptions2.BottomRightTxt:SetTextColor(C.Main:GetRGB())
vcbOptions2.BottomRightTxt:SetText(C_AddOns.GetAddOnMetadata("VCB", "X-Website"))
-- taking care of the boxes --
vcbOptions2Box1.Title:SetText(L.B_CCT)
vcbOptions2Box2.Title:SetText(L.B_BCT)
vcbOptions2Box2:SetPoint("TOPLEFT", vcbOptions2Box3, "BOTTOMLEFT", 0, 0)
vcbOptions2Box3.Title:SetText(L.B_TCT)
vcbOptions2Box3:SetPoint("TOPLEFT", vcbOptions2Box1, "BOTTOMLEFT", 0, 0)
vcbOptions2Box4.Title:SetText(L.B_SN)
vcbOptions2Box4:SetPoint("TOPLEFT", vcbOptions2Box6, "BOTTOMLEFT", 0, 0)
vcbOptions2Box5.Title:SetText(L.B_SI)
vcbOptions2Box5:SetPoint("TOPLEFT", vcbOptions2Box4, "BOTTOMLEFT", 0, 0)
vcbOptions2Box6.Title:SetText(L.B_SB)
vcbOptions2Box6:SetPoint("TOPLEFT", vcbOptions2Box1, "TOPRIGHT", 0, 0)
vcbOptions2Box7.Title:SetText(L.B_BB)
vcbOptions2Box7:SetPoint("TOPLEFT", vcbOptions2Box6, "TOPRIGHT", 0, 0)
vcbOptions2Box8.Title:SetText(L.B_UCB)
vcbOptions2Box8:SetPoint("TOPLEFT", vcbOptions2Box2, "TOPRIGHT", 0, 0)
for i = 1, 8, 1 do
	local tW = _G["vcbOptions2Box"..i].Title:GetStringWidth()+16
	local W = _G["vcbOptions2Box"..i]:GetWidth()
	if tW >= W then
		_G["vcbOptions2Box"..i]:SetWidth(_G["vcbOptions2Box"..i].Title:GetStringWidth()+16)
	end
end
-- Coloring the boxes --
for i = 1, 8, 1 do
	_G["vcbOptions2Box"..i].Title:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions2Box"..i].BorderTop:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions2Box"..i].BorderBottom:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions2Box"..i].BorderLeft:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions2Box"..i].BorderRight:SetVertexColor(C.High:GetRGB())
end
-- Coloring the pop out buttons --
local function ColoringPopOutButtons(k, var1)
	_G["vcbOptions2Box"..k.."PopOut"..var1].Text:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions2Box"..k.."PopOut"..var1].Title:SetTextColor(C.High:GetRGB())
	_G["vcbOptions2Box"..k.."PopOut"..var1].NormalTexture:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions2Box"..k.."PopOut"..var1].HighlightTexture:SetVertexColor(C.Main:GetRGB())
	_G["vcbOptions2Box"..k.."PopOut"..var1].PushedTexture:SetVertexColor(C.High:GetRGB())
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
	_G["vcbOptions2Box"..k.."PopOut1"].Title:SetText(L.W_POSITION)
	ColoringPopOutButtons(k, 1)
	for i, name in ipairs(textPosition) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions2Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut1"])
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", "vcbOptions2Box"..k.."PopOut1", "BOTTOM", 0, 4)
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut1Choice1"])
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Target"]["CurrentTimeText"]["Position"] = self.Text:GetText()
					chkCurrentTxtTarget()
					chkCurrentUpdTarget()
				elseif k== 2 then
					VCBsettings["Target"]["BothTimeText"]["Position"] = self.Text:GetText()
					chkBothTxtTarget()
					chkBothUpdTarget()
				elseif k == 3 then
					VCBsettings["Target"]["TotalTimeText"]["Position"] = self.Text:GetText()
					chkTotalTxtTarget()
					chkTotalUpdTarget()
				elseif k == 4 then
					VCBsettings["Target"]["NameText"]["Position"] = self.Text:GetText()
					chkNameTxtTarget()
				end
				_G["vcbOptions2Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions2Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions2Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions2Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
	end)
	_G["vcbOptions2Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions2Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions2Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions2Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions2Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 2 Buttons decimals and sec  --
for k = 1, 3, 1 do
-- decimals --
	_G["vcbOptions2Box"..k.."PopOut2"].Title:SetText(L.W_DECIMALS)
	ColoringPopOutButtons(k, 2)
	for i, name in ipairs(textDecimals) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions2Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut2"])
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions2Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut2Choice1"])
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Target"]["CurrentTimeText"]["Decimals"] = self.Text:GetText()
					chkCurrentUpdTarget()
				elseif k== 2 then
					VCBsettings["Target"]["BothTimeText"]["Decimals"] = self.Text:GetText()
					chkBothUpdTarget()
				elseif k == 3 then
					VCBsettings["Target"]["TotalTimeText"]["Decimals"] = self.Text:GetText()
					chkTotalUpdTarget()
				end
				_G["vcbOptions2Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions2Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions2Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions2Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DECIMALS_TIP, C.Main) 
	end)
	_G["vcbOptions2Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions2Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions2Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions2Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions2Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
-- sec --
	_G["vcbOptions2Box"..k.."PopOut3"].Title:SetText("'Sec'")
	ColoringPopOutButtons(k, 3)
	for i, name in ipairs(textSec) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions2Box"..k.."PopOut3Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut3"])
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", "vcbOptions2Box"..k.."PopOut3", "BOTTOM", 0, 4)
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut3Choice1"])
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut3Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:Show()
		end
		_G["vcbOptions2Box"..k.."PopOut3Choice"..i].Text:SetText(name)
		_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Target"]["CurrentTimeText"]["Sec"] = self.Text:GetText()
					chkCurrentUpdTarget()
				elseif k== 2 then
					VCBsettings["Target"]["BothTimeText"]["Sec"] = self.Text:GetText()
					chkBothUpdTarget()
				elseif k == 3 then
					VCBsettings["Target"]["TotalTimeText"]["Sec"] = self.Text:GetText()
					chkTotalUpdTarget()
				end
				_G["vcbOptions2Box"..k.."PopOut3"].Text:SetText(self.Text:GetText())
				_G["vcbOptions2Box"..k.."PopOut3Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions2Box"..k.."PopOut3Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions2Box"..k.."PopOut3Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions2Box"..k.."PopOut3"]:HookScript("OnEnter", function(self)
		local word = _G["vcbOptions2Box"..k.."PopOut3"].Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_V_TIP, word), C.Main) 
	end)
	_G["vcbOptions2Box"..k.."PopOut3"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions2Box"..k.."PopOut3"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions2Box"..k.."PopOut3Choice1"]:IsShown() then
				_G["vcbOptions2Box"..k.."PopOut3Choice1"]:Show()
			else
				_G["vcbOptions2Box"..k.."PopOut3Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 4 Buttons Direction  --
for k = 1, 2, 1 do
	_G["vcbOptions2Box"..k.."PopOut4"].Title:SetText(L.W_DIRECTION)
	ColoringPopOutButtons(k, 4)
	for i, name in ipairs(textDirection) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions2Box"..k.."PopOut4Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut4"])
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", "vcbOptions2Box"..k.."PopOut4", "BOTTOM", 0, 4)
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut4Choice1"])
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut4Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:Show()
		end
		_G["vcbOptions2Box"..k.."PopOut4Choice"..i].Text:SetText(name)
		_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Target"]["CurrentTimeText"]["Direction"] = self.Text:GetText()
					chkCurrentUpdTarget()
				elseif k== 2 then
					VCBsettings["Target"]["BothTimeText"]["Direction"] = self.Text:GetText()
					chkBothUpdTarget()
				end
				_G["vcbOptions2Box"..k.."PopOut4"].Text:SetText(self.Text:GetText())
				_G["vcbOptions2Box"..k.."PopOut4Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions2Box"..k.."PopOut4Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions2Box"..k.."PopOut4Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions2Box"..k.."PopOut4"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DIRECTION_TIP, C.Main)
	end)
	_G["vcbOptions2Box"..k.."PopOut4"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions2Box"..k.."PopOut4"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions2Box"..k.."PopOut4Choice1"]:IsShown() then
				_G["vcbOptions2Box"..k.."PopOut4Choice1"]:Show()
			else
				_G["vcbOptions2Box"..k.."PopOut4Choice1"]:Hide()
			end
		end
	end)
end
-- Icon --
ColoringPopOutButtons(5, 1)
vcbOptions2Box5PopOut1.Title:SetText(L.W_POSITION)
for i, name in ipairs(iconPosition) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions2Box5PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions2Box5PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions2Box5PopOut1Choice"..i]:SetParent(vcbOptions2Box5PopOut1)
		_G["vcbOptions2Box5PopOut1Choice"..i]:SetPoint("TOP", vcbOptions2Box5PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions2Box5PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions2Box5PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions2Box5PopOut1Choice"..i]:SetParent(vcbOptions2Box5PopOut1Choice1)
		_G["vcbOptions2Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions2Box5PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions2Box5PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions2Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBsettings["Target"]["Icon"]["Position"] = self.Text:GetText()
			vcbOptions2Box5PopOut1.Text:SetText(self.Text:GetText())
			if VCBsettings["Target"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				checkButtonDisable(vcbOptions2Box5CheckButton1)
				VCBsettings["Target"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			else
				checkButtonEnable(vcbOptions2Box5CheckButton1)
			end
			chkIconTarget()
			vcbOptions2Box5PopOut1Choice1:Hide()
		end
	end)
	local w = _G["vcbOptions2Box5PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions2Box5PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions2Box5PopOut1:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
end)
vcbOptions2Box5PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions2Box5PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions2Box5PopOut1Choice1:IsShown() then
			vcbOptions2Box5PopOut1Choice1:Show()
		else
			vcbOptions2Box5PopOut1Choice1:Hide()
		end
	end
end)
-- check button show - hide shield icon --
vcbOptions2Box5CheckButton1.Text:SetText(L.W_SHIELD)
vcbOptions2Box5CheckButton1:SetScript("OnEnter", function(self)
	local word = self.Text:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_CHECKBOX_TIP, word), C.Main)
end)
vcbOptions2Box5CheckButton1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions2Box5CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBsettings["Target"]["Icon"]["Shield"] = G.OPTIONS_V_SHOW
			self.Text:SetTextColor(C.Main:GetRGB())
			PlaySound(858, "Master")
		elseif self:GetChecked() == false then
			VCBsettings["Target"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			self.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
			PlaySound(858, "Master")
		end
		chkIconTarget()
	end
end)
local bW = vcbOptions2Box5:GetWidth()
local tbW = (vcbOptions2Box5CheckButton1.Text:GetStringWidth() + vcbOptions2Box5CheckButton1:GetWidth() + 16)
if tbW >= bW then
	vcbOptions2Box5:SetWidth(tbW)
end
-- color & style of bar & border --
for k = 6, 7, 1 do
-- color --
	ColoringPopOutButtons(k, 1)
	_G["vcbOptions2Box"..k.."PopOut1"].Title:SetText(L.W_COLOR)
	for i, name in ipairs(barColor) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions2Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut1"])
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut1"], "BOTTOM", 0, 4)
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut1Choice1"])
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 6 then
					VCBsettings["Target"]["StatusBar"]["Color"] = self.Text:GetText()
					chkCastbarColorTarget()
				elseif k == 7 then
					VCBsettings["Target"]["Border"]["Color"] = self.Text:GetText()
					chkBorderColorTarget()
				end
				_G["vcbOptions2Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions2Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions2Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions2Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions2Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_C_TIP, word), C.Main) 
	end)
	_G["vcbOptions2Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions2Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions2Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions2Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions2Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
-- style --
	ColoringPopOutButtons(k, 2)
	_G["vcbOptions2Box"..k.."PopOut2"].Title:SetText(L.W_STYLE)
	for i, name in ipairs(barStyle) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions2Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut2"])
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions2Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions2Box"..k.."PopOut2Choice1"])
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 6 then
					VCBsettings["Target"]["StatusBar"]["Style"] = self.Text:GetText()
				elseif k== 7 then
					VCBsettings["Target"]["Border"]["Style"] = self.Text:GetText()
				end
				_G["vcbOptions2Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions2Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions2Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions2Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions2Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_S_TIP, word), C.Main)
	end)
	_G["vcbOptions2Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions2Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions2Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions2Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions2Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
end
-- pop out button Unlock the Castbar --
ColoringPopOutButtons(8, 1)
vcbOptions2Box8PopOut1.Title:SetText(L.W_LOCK)
for i, name in ipairs(barLock) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions2Box8PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions2Box8PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions2Box8PopOut1Choice"..i]:SetParent(vcbOptions2Box8PopOut1)
		_G["vcbOptions2Box8PopOut1Choice"..i]:SetPoint("TOP", vcbOptions2Box8PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions2Box8PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions2Box8PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions2Box8PopOut1Choice"..i]:SetParent(vcbOptions2Box8PopOut1Choice1)
		_G["vcbOptions2Box8PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box8PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions2Box8PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions2Box8PopOut1Choice"..i].Text:SetText(name)
	if i ==3 then
		_G["vcbOptions2Box8PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
				if finished then
					VCBsettings["Target"]["Lock"] = self.Text:GetText()
					vcbOptions2Box8PopOut1.Text:SetText(self.Text:GetText())
					sliderEnable(vcbOptions2Box8Slider1)
					vcbOptions2Box8PopOut1Choice1:Hide()
					C_UI.Reload()
				else
					C_Sound.PlayVocalErrorSound(48)
					DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat..L.WRN_NO_SUF))
				end
			end
		end)
	else
		_G["vcbOptions2Box8PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				VCBsettings["Target"]["Lock"] = self.Text:GetText()
				vcbOptions2Box8PopOut1.Text:SetText(self.Text:GetText())
				if VCBsettings["Target"]["Lock"] == G.OPTIONS_LS_LOCKED then
					sliderDisable(vcbOptions2Box8Slider1)
					vcbOptions2Box8Slider1.Slider:SetValue(100)
				elseif VCBsettings["Target"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
					sliderEnable(vcbOptions2Box8Slider1)
				end
				vcbOptions2Box8PopOut1Choice1:Hide()
				C_UI.Reload()
			end
		end)
	end
	local w = _G["vcbOptions2Box8PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions2Box8PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions2Box8PopOut1:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.W_LOCK_TIP_T, C.Main)
end)
vcbOptions2Box8PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions2Box8PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions2Box8PopOut1Choice1:IsShown() then
			vcbOptions2Box8PopOut1Choice1:Show()
		else
			vcbOptions2Box8PopOut1Choice1:Hide()
		end
	end
end)
-- slide bar 1 scale of the bar --
vcbOptions2Box8Slider1.Slider.Thumb:SetVertexColor(C.Main:GetRGB())
vcbOptions2Box8Slider1.Back:GetRegions():SetVertexColor(C.Main:GetRGB())
vcbOptions2Box8Slider1.Forward:GetRegions():SetVertexColor(C.Main:GetRGB())
vcbOptions2Box8Slider1.TopText:SetTextColor(C.High:GetRGB())
vcbOptions2Box8Slider1.MinText:SetTextColor(C.High:GetRGB())
vcbOptions2Box8Slider1.MaxText:SetTextColor(C.High:GetRGB())
vcbOptions2Box8Slider1.MinText:SetText(0.10)
vcbOptions2Box8Slider1.MaxText:SetText(2)
vcbOptions2Box8Slider1.Slider:SetMinMaxValues(10, 200)
-- enter --
vcbOptions2Box8Slider1.Slider:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.W_SLIDER_TIP, C.Main)
end)
-- leave --
vcbOptions2Box8Slider1.Slider:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- mouse wheel --
vcbOptions2Box8Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- value change --
vcbOptions2Box8Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions2Box8Slider1.TopText:SetText("Scale: "..(self:GetValue()/100))
	VCBsettings["Target"]["Scale"] = self:GetValue()
	TargetVCBpreview:SetScale(VCBsettings["Target"]["Scale"]/100)
	PlaySound(858, "Master")
end)
-- taking care of the cast bar preview --
TargetVCBpreview.Text:SetText(L.W_TARGET)
-- enter --
TargetVCBpreview:SetScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, G.BUTTON_L_CLICK..G.TIP_DRAG_ME, C.Main)
end)
-- leave --
TargetVCBpreview:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBsettings["Target"]["Position"]["X"] = Round(self:GetLeft())
	VCBsettings["Target"]["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the target preview --
TargetVCBpreview:RegisterForDrag("LeftButton")
TargetVCBpreview:SetScript("OnDragStart", TargetVCBpreview.StartMoving)
TargetVCBpreview:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the target preview --
TargetVCBpreview:SetScript("OnHide", function(self)
	VCBsettings["Target"]["Position"]["X"] = Round(self:GetLeft())
	VCBsettings["Target"]["Position"]["Y"] = Round(self:GetBottom())
end)
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions2Box1PopOut1.Text:SetText(VCBsettings["Target"]["CurrentTimeText"]["Position"])
	vcbOptions2Box2PopOut1.Text:SetText(VCBsettings["Target"]["BothTimeText"]["Position"])
	vcbOptions2Box3PopOut1.Text:SetText(VCBsettings["Target"]["TotalTimeText"]["Position"])
	vcbOptions2Box1PopOut2.Text:SetText(VCBsettings["Target"]["CurrentTimeText"]["Decimals"])
	vcbOptions2Box2PopOut2.Text:SetText(VCBsettings["Target"]["BothTimeText"]["Decimals"])
	vcbOptions2Box3PopOut2.Text:SetText(VCBsettings["Target"]["TotalTimeText"]["Decimals"])
	vcbOptions2Box1PopOut3.Text:SetText(VCBsettings["Target"]["CurrentTimeText"]["Sec"])
	vcbOptions2Box2PopOut3.Text:SetText(VCBsettings["Target"]["BothTimeText"]["Sec"])
	vcbOptions2Box3PopOut3.Text:SetText(VCBsettings["Target"]["TotalTimeText"]["Sec"])
	vcbOptions2Box1PopOut4.Text:SetText(VCBsettings["Target"]["CurrentTimeText"]["Direction"])
	vcbOptions2Box2PopOut4.Text:SetText(VCBsettings["Target"]["BothTimeText"]["Direction"])
	vcbOptions2Box4PopOut1.Text:SetText(VCBsettings["Target"]["NameText"]["Position"])
	vcbOptions2Box5PopOut1.Text:SetText(VCBsettings["Target"]["Icon"]["Position"])
	if VCBsettings["Target"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
		checkButtonDisable(vcbOptions2Box5CheckButton1)
	else
		checkButtonEnable(vcbOptions2Box5CheckButton1)
		if VCBsettings["Target"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			vcbOptions2Box5CheckButton1:SetChecked(true)
			vcbOptions2Box5CheckButton1.Text:SetTextColor(C.Main:GetRGB())
		elseif VCBsettings["Target"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			vcbOptions2Box5CheckButton1:SetChecked(false)
			vcbOptions2Box5CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
		end
	end
	vcbOptions2Box6PopOut1.Text:SetText(VCBsettings["Target"]["StatusBar"]["Color"])
	vcbOptions2Box6PopOut2.Text:SetText(VCBsettings["Target"]["StatusBar"]["Style"])
	vcbOptions2Box7PopOut1.Text:SetText(VCBsettings["Target"]["Border"]["Color"])
	vcbOptions2Box7PopOut2.Text:SetText(VCBsettings["Target"]["Border"]["Style"])
	vcbOptions2Box8PopOut1.Text:SetText(VCBsettings["Target"]["Lock"])
	if VCBsettings["Target"]["Lock"] == G.OPTIONS_LS_LOCKED then
		sliderDisable(vcbOptions2Box8Slider1)
	else
		sliderEnable(vcbOptions2Box8Slider1)
	end
	vcbOptions2Box8Slider1.Slider:SetValue(VCBsettings["Target"]["Scale"])
	if VCBsettings["Target"]["Lock"] == G.OPTIONS_LS_UNLOCKED or VCBsettings["Target"]["Lock"] == "S.U.F" then
		TargetVCBpreview:ClearAllPoints()
		TargetVCBpreview:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Target"]["Position"]["X"], VCBsettings["Target"]["Position"]["Y"])
		if not TargetVCBpreview:IsShown() then TargetVCBpreview:Show() end
	else
		if TargetVCBpreview:IsShown() then TargetVCBpreview:Hide() end
	end
end
-- Show the option panel --
vcbOptions2:HookScript("OnShow", function(self)
	vcbOptions0Tab1.Text:SetTextColor(0.4, 0.4, 0.4, 1)
	vcbOptions0Tab2.Text:SetTextColor(C.High:GetRGB())
	for i = 3, 6, 1 do
		_G["vcbOptions0Tab"..i].Text:SetTextColor(0.4, 0.4, 0.4, 1)
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	CheckSavedVariables()
end)
-- Hide the option panel --
vcbOptions2:HookScript("OnHide", function(self)
	if TargetVCBpreview:IsShown() then TargetVCBpreview:Hide() end
end)
