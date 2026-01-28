-- some variables --
local G = VDW.Local.Override
local L = VDW.VCB.Local
local C = VDW.GetAddonColors("VCB")
local prefixTip = VDW.Prefix("VCB")
local maxW = 160
local finalW = 0
local counter = 0
local textPosition = {G.OPTIONS_V_HIDE, G.OPTIONS_P_TOPLEFT, G.OPTIONS_P_LEFT, G.OPTIONS_P_BOTTOMLEFT, G.OPTIONS_P_TOP, G.OPTIONS_P_CENTER, G.OPTIONS_P_BOTTOM, G.OPTIONS_P_TOPRIGHT, G.OPTIONS_P_RIGHT, G.OPTIONS_P_BOTTOMRIGHT}
local textDecimals = {"0", "1", "2", "3"}
local textSec = {G.OPTIONS_V_HIDE, G.OPTIONS_V_SHOW}
local textDirection = {G.OPTIONS_D_ASCENDING, G.OPTIONS_D_DESCENDING, G.OPTIONS_P_BOTH}
local iconPosition = {G.OPTIONS_V_HIDE, G.OPTIONS_P_LEFT, G.OPTIONS_P_RIGHT, G.OPTIONS_P_BOTH}
local gcdStyle = {G.OPTIONS_S_CLASS_ICON, G.OPTIONS_S_HERO_ICON, G.OPTIONS_S_FACTION_ICON, G.OPTIONS_S_DEFAULT_BAR}
local gcdPosition = {G.OPTIONS_V_HIDE, G.OPTIONS_P_LEFT, G.OPTIONS_P_TOP, G.OPTIONS_P_RIGHT, G.OPTIONS_P_BOTTOM}
local barColor = {G.OPTIONS_C_DEFAULT, G.OPTIONS_C_CLASS, G.OPTIONS_C_FACTION,}
local barStyle = {G.OPTIONS_C_DEFAULT, "Jailer"}
local borderStyle = {G.OPTIONS_C_DEFAULT, "Jailer"}
local ticksStyle = {G.OPTIONS_V_HIDE, G.OPTIONS_S_MODERN, G.OPTIONS_S_CLASSIC}
-- Taking care of the option panel --
vcbOptions1:ClearAllPoints()
vcbOptions1:SetPoint("TOPLEFT", vcbOptions0, "TOPLEFT", 0, 0)
-- Background of the option panel --
vcbOptions1.BGtexture:SetTexture("Interface\\FontStyles\\FontStyleParchment.blp", "CLAMP", "CLAMP", "NEAREST")
vcbOptions1.BGtexture:SetVertexColor(C.High:GetRGB())
vcbOptions1.BGtexture:SetDesaturation(0.3)
-- Title of the option panel --
vcbOptions1.Title:SetTextColor(C.Main:GetRGB())
vcbOptions1.Title:SetText(prefixTip.."|nVersion: "..C.High:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Version")))
-- Top text of the option panel --
vcbOptions1.TopTxt:SetTextColor(C.Main:GetRGB())
vcbOptions1.TopTxt:SetText(L.P_PLAYER)
-- Bottom right text of the option panel --
vcbOptions1.BottomRightTxt:SetTextColor(C.Main:GetRGB())
vcbOptions1.BottomRightTxt:SetText(C_AddOns.GetAddOnMetadata("VCB", "X-Website"))
-- taking care of the boxes --
vcbOptions1Box1.Title:SetText(L.B_CCT)
vcbOptions1Box2.Title:SetText(L.B_BCT)
vcbOptions1Box2:SetPoint("TOPLEFT", vcbOptions1Box3, "BOTTOMLEFT", 0, 0)
vcbOptions1Box3.Title:SetText(L.B_TCT)
vcbOptions1Box3:SetPoint("TOPLEFT", vcbOptions1Box1, "BOTTOMLEFT", 0, 0)
vcbOptions1Box4.Title:SetText(L.B_SN)
vcbOptions1Box4:SetPoint("TOPLEFT", vcbOptions1Box9, "BOTTOMLEFT", 0, 0)
vcbOptions1Box11.Title:SetText(L.B_ST)
vcbOptions1Box11:SetPoint("TOPLEFT", vcbOptions1Box6, "BOTTOMLEFT", 0, 0)
vcbOptions1Box7.Title:SetText(L.B_LB)
vcbOptions1Box7:SetPoint("TOPLEFT", vcbOptions1Box5, "TOPRIGHT", 0, 0)
vcbOptions1Box8.Title:SetText(L.B_QB)
vcbOptions1Box8:SetPoint("TOPLEFT", vcbOptions1Box4, "TOPRIGHT", 0, 0)
vcbOptions1Box9.Title:SetText(L.B_SB)
vcbOptions1Box9:SetPoint("TOPLEFT", vcbOptions1Box1, "TOPRIGHT", 0, 0)
vcbOptions1Box10.Title:SetText(L.B_BB)
vcbOptions1Box10:SetPoint("TOPLEFT", vcbOptions1Box9, "TOPRIGHT", 0, 0)
vcbOptions1Box5.Title:SetText(L.B_SI)
vcbOptions1Box5:SetPoint("TOPLEFT", vcbOptions1Box4, "BOTTOMLEFT", 0, 0)
vcbOptions1Box6.Title:SetText(L.B_GC)
vcbOptions1Box6:SetPoint("TOPLEFT", vcbOptions1Box2, "TOPRIGHT", 0, 0)
for i = 1, 11, 1 do
	local tW = _G["vcbOptions1Box"..i].Title:GetStringWidth()+16
	local W = _G["vcbOptions1Box"..i]:GetWidth()
	if tW >= W then
		_G["vcbOptions1Box"..i]:SetWidth(tW)
	end
end
-- Coloring the boxes --
for i = 1, 11, 1 do
	_G["vcbOptions1Box"..i].Title:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions1Box"..i].BorderTop:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions1Box"..i].BorderBottom:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions1Box"..i].BorderLeft:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions1Box"..i].BorderRight:SetVertexColor(C.High:GetRGB())
end
-- Coloring the pop out buttons --
local function ColoringPopOutButtons(k, var1)
	_G["vcbOptions1Box"..k.."PopOut"..var1].Text:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions1Box"..k.."PopOut"..var1].Title:SetTextColor(C.High:GetRGB())
	_G["vcbOptions1Box"..k.."PopOut"..var1].NormalTexture:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions1Box"..k.."PopOut"..var1].HighlightTexture:SetVertexColor(C.Main:GetRGB())
	_G["vcbOptions1Box"..k.."PopOut"..var1].PushedTexture:SetVertexColor(C.High:GetRGB())
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
-- Pop out 1 Buttons text position  --
for k = 1, 4, 1 do
	_G["vcbOptions1Box"..k.."PopOut1"].Title:SetText(L.W_POSITION)
	ColoringPopOutButtons(k, 1)
	for i, name in ipairs(textPosition) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut1"])
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", "vcbOptions1Box"..k.."PopOut1", "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut1Choice1"])
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Player"]["CurrentTimeText"]["Position"] = self.Text:GetText()
					chkCurrentTxtPlayer()
					chkCurrentUpdPlayer()
				elseif k== 2 then
					VCBsettings["Player"]["BothTimeText"]["Position"] = self.Text:GetText()
					chkBothTxtPlayer()
					chkBothUpdPlayer()
				elseif k == 3 then
					VCBsettings["Player"]["TotalTimeText"]["Position"] = self.Text:GetText()
					chkTotalTxtPlayer()
					chkTotalUpdPlayer()
				elseif k == 4 then
					VCBsettings["Player"]["NameText"]["Position"] = self.Text:GetText()
					chkNameTxtPlayer()
				end
				_G["vcbOptions1Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 2 Buttons decimals and sec  --
for k = 1, 3, 1 do
-- decimals --
	_G["vcbOptions1Box"..k.."PopOut2"].Title:SetText(L.W_DECIMALS)
	ColoringPopOutButtons(k, 2)
	for i, name in ipairs(textDecimals) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut2"])
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions1Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut2Choice1"])
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Player"]["CurrentTimeText"]["Decimals"] = self.Text:GetText()
					chkCurrentUpdPlayer()
				elseif k== 2 then
					VCBsettings["Player"]["BothTimeText"]["Decimals"] = self.Text:GetText()
					chkBothUpdPlayer()
				elseif k == 3 then
					VCBsettings["Player"]["TotalTimeText"]["Decimals"] = self.Text:GetText()
					chkTotalUpdPlayer()
				end
				_G["vcbOptions1Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefix, L.W_DECIMALS_TIP, C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
-- sec --
	_G["vcbOptions1Box"..k.."PopOut3"].Title:SetText("'Sec'")
	ColoringPopOutButtons(k, 3)
	for i, name in ipairs(textSec) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut3Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut3"])
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", "vcbOptions1Box"..k.."PopOut3", "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut3Choice1"])
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut3Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut3Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Player"]["CurrentTimeText"]["Sec"] = self.Text:GetText()
					chkCurrentUpdPlayer()
				elseif k== 2 then
					VCBsettings["Player"]["BothTimeText"]["Sec"] = self.Text:GetText()
					chkBothUpdPlayer()
				elseif k == 3 then
					VCBsettings["Player"]["TotalTimeText"]["Sec"] = self.Text:GetText()
					chkTotalUpdPlayer()
				end
				_G["vcbOptions1Box"..k.."PopOut3"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut3Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut3Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut3Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut3"]:HookScript("OnEnter", function(self)
		local word = _G["vcbOptions1Box"..k.."PopOut3"].Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_V_TIP, word), C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut3"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut3"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut3Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut3Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut3Choice1"]:Hide()
			end
		end
	end)
end
-- Pop out 4 Buttons Direction  --
for k = 1, 2, 1 do
	_G["vcbOptions1Box"..k.."PopOut4"].Title:SetText(L.W_DIRECTION)
	ColoringPopOutButtons(k, 4)
	for i, name in ipairs(textDirection) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut4Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut4"])
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", "vcbOptions1Box"..k.."PopOut4", "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut4Choice1"])
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut4Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut4Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 1 then
					VCBsettings["Player"]["CurrentTimeText"]["Direction"] = self.Text:GetText()
					chkCurrentUpdPlayer()
				elseif k== 2 then
					VCBsettings["Player"]["BothTimeText"]["Direction"] = self.Text:GetText()
					chkBothUpdPlayer()
				end
				_G["vcbOptions1Box"..k.."PopOut4"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut4Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut4Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut4Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut4"]:HookScript("OnEnter", function(self)
		VDW.Tooltip_Show(self, prefixTip, L.W_DIRECTION_TIP, C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut4"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut4"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut4Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut4Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut4Choice1"]:Hide()
			end
		end
	end)
end
-- Icon --
ColoringPopOutButtons(5, 1)
vcbOptions1Box5PopOut1.Title:SetText(L.W_POSITION)
for i, name in ipairs(iconPosition) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions1Box5PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions1Box5PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions1Box5PopOut1Choice"..i]:SetParent(vcbOptions1Box5PopOut1)
		_G["vcbOptions1Box5PopOut1Choice"..i]:SetPoint("TOP", vcbOptions1Box5PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions1Box5PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions1Box5PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions1Box5PopOut1Choice"..i]:SetParent(vcbOptions1Box5PopOut1Choice1)
		_G["vcbOptions1Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions1Box5PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions1Box5PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions1Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBsettings["Player"]["Icon"]["Position"] = self.Text:GetText()
			vcbOptions1Box5PopOut1.Text:SetText(self.Text:GetText())
			if VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				checkButtonDisable(vcbOptions1Box5CheckButton1)
				VCBsettings["Player"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			else
				checkButtonEnable(vcbOptions1Box5CheckButton1)
			end
			chkIconPlayer()
			chkGlobalCooldownPlayer(vcbGCD1)
			vcbOptions1Box5PopOut1Choice1:Hide()
		end
	end)
	local w = _G["vcbOptions1Box5PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions1Box5PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions1Box5PopOut1:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
end)
vcbOptions1Box5PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions1Box5PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions1Box5PopOut1Choice1:IsShown() then
			vcbOptions1Box5PopOut1Choice1:Show()
		else
			vcbOptions1Box5PopOut1Choice1:Hide()
		end
	end
end)
-- check button show - hide shield icon --
vcbOptions1Box5CheckButton1.Text:SetText(L.W_SHIELD)
vcbOptions1Box5CheckButton1:SetScript("OnEnter", function(self)
	local word = self.Text:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_CHECKBOX_TIP, word), C.Main)
end)
vcbOptions1Box5CheckButton1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions1Box5CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBsettings["Player"]["Icon"]["Shield"] = G.OPTIONS_V_SHOW
			self.Text:SetTextColor(C.Main:GetRGB())
			PlaySound(858, "Master")
		elseif self:GetChecked() == false then
			VCBsettings["Player"]["Icon"]["Shield"] = G.OPTIONS_V_HIDE
			self.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
			PlaySound(858, "Master")
		end
		chkIconPlayer()
	end
end)
local bW = vcbOptions1Box5:GetWidth()
local tbW = (vcbOptions1Box5CheckButton1.Text:GetStringWidth() + vcbOptions1Box5CheckButton1:GetWidth() + 16)
if tbW >= bW then
	vcbOptions1Box5:SetWidth(tbW)
end
-- Global Cooldown --
--position --
ColoringPopOutButtons(6, 2)
vcbOptions1Box6PopOut2.Title:SetText(L.W_POSITION)
for i, name in ipairs(gcdPosition) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions1Box6PopOut2Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions1Box6PopOut2Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions1Box6PopOut2Choice"..i]:SetParent(vcbOptions1Box6PopOut2)
		_G["vcbOptions1Box6PopOut2Choice"..i]:SetPoint("TOP", vcbOptions1Box6PopOut2, "BOTTOM", 0, 4)
		_G["vcbOptions1Box6PopOut2Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions1Box6PopOut2Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions1Box6PopOut2Choice"..i]:SetParent(vcbOptions1Box6PopOut2Choice1)
		_G["vcbOptions1Box6PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box6PopOut2Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions1Box6PopOut2Choice"..i]:Show()
	end
	_G["vcbOptions1Box6PopOut2Choice"..i].Text:SetText(name)
	_G["vcbOptions1Box6PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBsettings["Player"]["GCD"]["Position"] = self.Text:GetText()
			vcbOptions1Box6PopOut2.Text:SetText(self.Text:GetText())
			if VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_V_HIDE then
				popDisable(vcbOptions1Box6PopOut1)
			else
				popEnable(vcbOptions1Box6PopOut1)
			end
			chkGlobalCooldownPlayer(vcbGCD1)
			vcbOptions1Box6PopOut2Choice1:Hide()
		end
	end)
	local w = _G["vcbOptions1Box6PopOut2Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions1Box6PopOut2Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions1Box6PopOut2:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_P_TIP, word), C.Main)
end)
vcbOptions1Box6PopOut2:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions1Box6PopOut2:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions1Box6PopOut2Choice1:IsShown() then
			vcbOptions1Box6PopOut2Choice1:Show()
		else
			vcbOptions1Box6PopOut2Choice1:Hide()
		end
	end
end)
-- style --
ColoringPopOutButtons(6, 1)
vcbOptions1Box6PopOut1.Title:SetText(L.W_STYLE)
for i, name in ipairs(gcdStyle) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions1Box6PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions1Box6PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions1Box6PopOut1Choice"..i]:SetParent(vcbOptions1Box6PopOut1)
		_G["vcbOptions1Box6PopOut1Choice"..i]:SetPoint("TOP", vcbOptions1Box6PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions1Box6PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions1Box6PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions1Box6PopOut1Choice"..i]:SetParent(vcbOptions1Box6PopOut1Choice1)
		_G["vcbOptions1Box6PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box6PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions1Box6PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions1Box6PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions1Box6PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if self.Text:GetText() == G.OPTIONS_S_HERO_ICON then
				if UnitLevel("player") >= 10 and C_SpecializationInfo.GetSpecialization() ~= 5 then
					VCBsettings["Player"]["GCD"]["Style"] = self.Text:GetText()
					vcbOptions1Box6PopOut1.Text:SetText(self.Text:GetText())
				else
					print("You need to be level 10 and choose a specialization!")
				end
			else
				VCBsettings["Player"]["GCD"]["Style"] = self.Text:GetText()
				vcbOptions1Box6PopOut1.Text:SetText(self.Text:GetText())
			end
			chkGlobalCooldownPlayer(vcbGCD1)
			vcbOptions1Box6PopOut1Choice1:Hide()
		end
	end)
	local w = _G["vcbOptions1Box6PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions1Box6PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions1Box6PopOut1:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_S_TIP, word), C.Main)
end)
vcbOptions1Box6PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions1Box6PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions1Box6PopOut1Choice1:IsShown() then
			vcbOptions1Box6PopOut1Choice1:Show()
		else
			vcbOptions1Box6PopOut1Choice1:Hide()
		end
	end
end)
-- lag bar, queue bar --
for k = 7, 8, 1 do
	ColoringPopOutButtons(k, 1)
	_G["vcbOptions1Box"..k.."PopOut1"].Title:SetText(L.W_VISIBILITY)
	for i, name in ipairs(textSec) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut1"])
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut1"], "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut1Choice1"])
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 7 then
					VCBsettings["Player"]["LagBar"]["Visibility"] = self.Text:GetText()
				elseif k == 8 then
					VCBsettings["Player"]["QueueBar"]["Visibility"] = self.Text:GetText()
				end
				_G["vcbOptions1Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_V_TIP, word), C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
end
-- color & style of bar & border --
for k = 9, 10, 1 do
-- color --
	ColoringPopOutButtons(k, 1)
	_G["vcbOptions1Box"..k.."PopOut1"].Title:SetText(L.W_COLOR)
	for i, name in ipairs(barColor) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut1Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut1"])
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut1"], "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut1Choice1"])
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut1Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 9 then
					VCBsettings["Player"]["StatusBar"]["Color"] = self.Text:GetText()
					chkCastbarColorPlayer()
				elseif k == 10 then
					VCBsettings["Player"]["Border"]["Color"] = self.Text:GetText()
					chkCastbarBorderColorPlayer()
				end
				_G["vcbOptions1Box"..k.."PopOut1"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut1Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut1Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_C_TIP, word), C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut1"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut1Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut1Choice1"]:Hide()
			end
		end
	end)
-- style --
	ColoringPopOutButtons(k, 2)
	_G["vcbOptions1Box"..k.."PopOut2"].Title:SetText(L.W_STYLE)
	for i, name in ipairs(barStyle) do
		counter = counter + 1
		local btn = CreateFrame("Button", "vcbOptions1Box"..k.."PopOut2Choice"..i, nil, "vdwPopOutButton")
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:ClearAllPoints()
		if i == 1 then
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut2"])
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", "vcbOptions1Box"..k.."PopOut2", "BOTTOM", 0, 4)
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetScript("OnShow", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
				PlaySound(855, "Master")
			end)
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetScript("OnHide", function(self)
				self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
				PlaySound(855, "Master")
			end)
		else
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetParent(_G["vcbOptions1Box"..k.."PopOut2Choice1"])
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box"..k.."PopOut2Choice"..i-1], "BOTTOM", 0, 0)
			_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:Show()
		end
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i].Text:SetText(name)
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
			if button == "LeftButton" and down == false then
				if k == 9 then
					VCBsettings["Player"]["StatusBar"]["Style"] = self.Text:GetText()
				elseif k == 10 then
					VCBsettings["Player"]["Border"]["Style"] = self.Text:GetText()
					C_UI.Reload()
				end
				_G["vcbOptions1Box"..k.."PopOut2"].Text:SetText(self.Text:GetText())
				_G["vcbOptions1Box"..k.."PopOut2Choice1"]:Hide()
			end
		end)
		local w = _G["vcbOptions1Box"..k.."PopOut2Choice"..i].Text:GetStringWidth()
		if w > maxW then maxW = w end
	end
	finalW = math.ceil(maxW + 24)
	for i = 1, counter, 1 do
		_G["vcbOptions1Box"..k.."PopOut2Choice"..i]:SetWidth(finalW)
	end
	counter = 0
	maxW = 160
	_G["vcbOptions1Box"..k.."PopOut2"]:HookScript("OnEnter", function(self)
		local parent = self:GetParent()
		local word = parent.Title:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.W_S_TIP, word), C.Main)
	end)
	_G["vcbOptions1Box"..k.."PopOut2"]:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
	_G["vcbOptions1Box"..k.."PopOut2"]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions1Box"..k.."PopOut2Choice1"]:IsShown() then
				_G["vcbOptions1Box"..k.."PopOut2Choice1"]:Show()
			else
				_G["vcbOptions1Box"..k.."PopOut2Choice1"]:Hide()
			end
		end
	end)
end
--vcbOptions1Box10PopOut2:Hide()
-- Ticks of the spells --
ColoringPopOutButtons(11, 1)
vcbOptions1Box11PopOut1.Title:SetText(L.W_STYLE)
for i, name in ipairs(ticksStyle) do
	counter = counter + 1
	local btn = CreateFrame("Button", "vcbOptions1Box11PopOut1Choice"..i, nil, "vdwPopOutButton")
	_G["vcbOptions1Box11PopOut1Choice"..i]:ClearAllPoints()
	if i == 1 then
		_G["vcbOptions1Box11PopOut1Choice"..i]:SetParent(vcbOptions1Box11PopOut1)
		_G["vcbOptions1Box11PopOut1Choice"..i]:SetPoint("TOP", vcbOptions1Box11PopOut1, "BOTTOM", 0, 4)
		_G["vcbOptions1Box11PopOut1Choice"..i]:SetScript("OnShow", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
			PlaySound(855, "Master")
		end)
		_G["vcbOptions1Box11PopOut1Choice"..i]:SetScript("OnHide", function(self)
			self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
			PlaySound(855, "Master")
		end)
	else
		_G["vcbOptions1Box11PopOut1Choice"..i]:SetParent(vcbOptions1Box11PopOut1Choice1)
		_G["vcbOptions1Box11PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box11PopOut1Choice"..i-1], "BOTTOM", 0, 0)
		_G["vcbOptions1Box11PopOut1Choice"..i]:Show()
	end
	_G["vcbOptions1Box11PopOut1Choice"..i].Text:SetText(name)
	_G["vcbOptions1Box11PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBspecialSettings["Player"]["Ticks"]["Style"] = self.Text:GetText()
			vcbOptions1Box11PopOut1.Text:SetText(self.Text:GetText())
			vcbOptions1Box11PopOut1Choice1:Hide()
			C_UI.Reload()
		end
end)
	local w = _G["vcbOptions1Box11PopOut1Choice"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 24)
for i = 1, counter, 1 do
	_G["vcbOptions1Box11PopOut1Choice"..i]:SetWidth(finalW)
end
counter = 0
maxW = 160
vcbOptions1Box11PopOut1:HookScript("OnEnter", function(self)
	local parent = self:GetParent()
	local word = parent.Title:GetText()
	VDW.Tooltip_Show(self, prefixTip, string.format(L.W_ST_TIP, word), C.Main)
end)
vcbOptions1Box11PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
vcbOptions1Box11PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions1Box11PopOut1Choice1:IsShown() then
			vcbOptions1Box11PopOut1Choice1:Show()
		else
			vcbOptions1Box11PopOut1Choice1:Hide()
		end
	end
end)
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions1Box1PopOut1.Text:SetText(VCBsettings["Player"]["CurrentTimeText"]["Position"])
	vcbOptions1Box2PopOut1.Text:SetText(VCBsettings["Player"]["BothTimeText"]["Position"])
	vcbOptions1Box3PopOut1.Text:SetText(VCBsettings["Player"]["TotalTimeText"]["Position"])
	vcbOptions1Box1PopOut2.Text:SetText(VCBsettings["Player"]["CurrentTimeText"]["Decimals"])
	vcbOptions1Box2PopOut2.Text:SetText(VCBsettings["Player"]["BothTimeText"]["Decimals"])
	vcbOptions1Box3PopOut2.Text:SetText(VCBsettings["Player"]["TotalTimeText"]["Decimals"])
	vcbOptions1Box1PopOut3.Text:SetText(VCBsettings["Player"]["CurrentTimeText"]["Sec"])
	vcbOptions1Box2PopOut3.Text:SetText(VCBsettings["Player"]["BothTimeText"]["Sec"])
	vcbOptions1Box3PopOut3.Text:SetText(VCBsettings["Player"]["TotalTimeText"]["Sec"])
	vcbOptions1Box1PopOut4.Text:SetText(VCBsettings["Player"]["CurrentTimeText"]["Direction"])
	vcbOptions1Box2PopOut4.Text:SetText(VCBsettings["Player"]["BothTimeText"]["Direction"])
	vcbOptions1Box4PopOut1.Text:SetText(VCBsettings["Player"]["NameText"]["Position"])
	vcbOptions1Box5PopOut1.Text:SetText(VCBsettings["Player"]["Icon"]["Position"])
	if VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
		checkButtonDisable(vcbOptions1Box5CheckButton1)
	else
		checkButtonEnable(vcbOptions1Box5CheckButton1)
		if VCBsettings["Player"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			vcbOptions1Box5CheckButton1:SetChecked(true)
			vcbOptions1Box5CheckButton1.Text:SetTextColor(C.Main:GetRGB())
		elseif VCBsettings["Player"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			vcbOptions1Box5CheckButton1:SetChecked(false)
			vcbOptions1Box5CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
		end
	end
	vcbOptions1Box6PopOut1.Text:SetText(VCBsettings["Player"]["GCD"]["Style"])
	vcbOptions1Box6PopOut2.Text:SetText(VCBsettings["Player"]["GCD"]["Position"])
	if VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_V_HIDE then
		popDisable(vcbOptions1Box6PopOut1)
	else
		popEnable(vcbOptions1Box6PopOut1)
	end
	vcbOptions1Box7PopOut1.Text:SetText(VCBsettings["Player"]["LagBar"]["Visibility"])
	vcbOptions1Box8PopOut1.Text:SetText(VCBsettings["Player"]["QueueBar"]["Visibility"])
	vcbOptions1Box9PopOut1.Text:SetText(VCBsettings["Player"]["StatusBar"]["Color"])
	vcbOptions1Box9PopOut2.Text:SetText(VCBsettings["Player"]["StatusBar"]["Style"])
	vcbOptions1Box10PopOut1.Text:SetText(VCBsettings["Player"]["Border"]["Color"])
	vcbOptions1Box10PopOut2.Text:SetText(VCBsettings["Player"]["Border"]["Style"])
	vcbOptions1Box11PopOut1.Text:SetText(VCBspecialSettings["Player"]["Ticks"]["Style"])
end
-- Show the option panel --
vcbOptions1:HookScript("OnShow", function(self)
	vcbOptions0Tab1.Text:SetTextColor(C.High:GetRGB())
	for i = 2, 6, 1 do
		_G["vcbOptions0Tab"..i].Text:SetTextColor(0.4, 0.4, 0.4, 1)
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
	CheckSavedVariables()
end)
