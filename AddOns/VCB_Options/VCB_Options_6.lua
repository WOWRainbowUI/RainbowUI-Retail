-- some variables --
local G = VDW.Local.Override
local L = VDW.VCB.Local
local C = VDW.GetAddonColors("VCB")
local prefixTip = VDW.Prefix("VCB")
local prefixChat = VDW.PrefixChat("VCB")
local NameExist = false
local maxW = 160
local finalW = 0
local  number = 0
local counterLoading = 0
local counterDeleting = 0
-- taking care of the option panel --
vcbOptions6:ClearAllPoints()
vcbOptions6:SetPoint("TOPLEFT", vcbOptions0, "TOPLEFT", 0, 0)
-- background of the option panel --
vcbOptions6.BGtexture:SetTexture("Interface\\FontStyles\\FontStyleParchment.blp", "CLAMP", "CLAMP", "NEAREST")
vcbOptions6.BGtexture:SetVertexColor(C.High:GetRGB())
vcbOptions6.BGtexture:SetDesaturation(0.3)
-- title of the option panel --
vcbOptions6.Title:SetTextColor(C.Main:GetRGB())
vcbOptions6.Title:SetText(prefixTip.."|nVersion: "..C.High:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Version")))
-- top text of the option panel --
vcbOptions6.TopTxt:SetTextColor(C.Main:GetRGB())
vcbOptions6.TopTxt:SetText(L.P_TITLE)
-- bottom right text of the option panel --
vcbOptions6.BottomRightTxt:SetTextColor(C.Main:GetRGB())
vcbOptions6.BottomRightTxt:SetText(C_AddOns.GetAddOnMetadata("VCB", "X-Website"))
-- taking care of the boxes --
vcbOptions6Box1.Title:SetText(L.P_SUB_CREATE)
vcbOptions6Box2.Title:SetText(L.P_SUB_LOAD)
vcbOptions6Box2:SetPoint("TOPLEFT", vcbOptions6Box1, "BOTTOMLEFT", 0, 0)
vcbOptions6Box3.Title:SetText(L.P_SUB_DELETE)
vcbOptions6Box3:SetPoint("TOPLEFT", vcbOptions6Box2, "BOTTOMLEFT", 0, 0)
-- coloring the boxes --
for i = 1, 3, 1 do
	_G["vcbOptions6Box"..i].Title:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions6Box"..i].BorderTop:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions6Box"..i].BorderBottom:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions6Box"..i].BorderLeft:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions6Box"..i].BorderRight:SetVertexColor(C.High:GetRGB())
end
-- coloring the pop out buttons --
local function ColoringPopOutButtons(k, var1)
	_G["vcbOptions6Box"..k.."PopOut"..var1].Text:SetTextColor(C.Main:GetRGB())
	_G["vcbOptions6Box"..k.."PopOut"..var1].Title:SetTextColor(C.High:GetRGB())
	_G["vcbOptions6Box"..k.."PopOut"..var1].NormalTexture:SetVertexColor(C.High:GetRGB())
	_G["vcbOptions6Box"..k.."PopOut"..var1].HighlightTexture:SetVertexColor(C.Main:GetRGB())
	_G["vcbOptions6Box"..k.."PopOut"..var1].PushedTexture:SetVertexColor(C.High:GetRGB())
end
-- taking care of the edit box --
-- colors --
vcbOptions6Box1EditBox1["GlowTopLeft"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowTopRight"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowBottomLeft"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowBottomRight"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowTop"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowBottom"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowLeft"]:SetVertexColor(C.Main:GetRGB())
vcbOptions6Box1EditBox1["GlowRight"]:SetVertexColor(C.Main:GetRGB())
-- width and height --
local fontFile, height, flags = vcbOptions6Box1EditBox1.WritingLine:GetFont()
vcbOptions6Box1EditBox1.WritingLine:SetHeight(height)
vcbOptions6Box1EditBox1:SetWidth(vcbOptions6Box1:GetWidth()*0.65)
vcbOptions6Box1EditBox1:SetHeight(vcbOptions6Box1EditBox1.WritingLine:GetHeight()*1.75)
vcbOptions6Box1EditBox1.WritingLine:SetWidth(vcbOptions6Box1EditBox1:GetWidth()*0.95)
-- enter --
vcbOptions6Box1EditBox1:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.P_TIP_CREATE, C.Main)
end)
-- leave --
vcbOptions6Box1EditBox1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- pressing enter --
vcbOptions6Box1EditBox1.WritingLine:SetScript("OnEnterPressed", function(self)
	if self:HasText() then
		EditBox_HighlightText(self)
		local name = self:GetText()
		for k, v in pairs(VCBprofiles) do
			if k == name then
				NameExist = true
			else
				NameExist = false
			end
			if NameExist then
				DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..L.P_WRN_EXIST))
				return
			end
		end
		number = number + 1
		VCBprofiles[name] = {settings = VCBsettings, localization = VCBspecialSettings.LastLocation}
		C_UI.Reload()
	else
		DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..L.P_WRN_NEED))
	end
end)
-- pop out 1 buttons loading profiles  --
ColoringPopOutButtons(2, 1)
-- enter --
vcbOptions6Box2PopOut1:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.P_TIP_LOAD, C.Main)
end)
-- leave --
vcbOptions6Box2PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- click --
vcbOptions6Box2PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if vcbOptions6Box2PopOut1Choice1 ~= nil then
			if not vcbOptions6Box2PopOut1Choice1:IsShown() then
				vcbOptions6Box2PopOut1Choice1:Show()
			else
				vcbOptions6Box2PopOut1Choice1:Hide()
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..L.P_WRN_LOAD))
		end
	end
end)
-- pop out 1 buttons deleting profiles  --
ColoringPopOutButtons(3, 1)
-- enter --
vcbOptions6Box3PopOut1:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.P_TIP_DELETE, C.Main)
end)
-- leave --
vcbOptions6Box3PopOut1:HookScript("OnLeave", function(self) VDW.Tooltip_Hide() end)
-- click --
vcbOptions6Box3PopOut1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if vcbOptions6Box3PopOut1Choice1 ~= nil then
			if not vcbOptions6Box3PopOut1Choice1:IsShown() then
				vcbOptions6Box3PopOut1Choice1:Show()
			else
				vcbOptions6Box3PopOut1Choice1:Hide()
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..L.P_WRN_DELETE))
		end
	end
end)
-- finding keys --
local function FindingKeys()
	local Keys = 0
	for k, v in pairs(VCBprofiles) do
		Keys = Keys + 1
	end
	number = Keys
end
-- functions for loading the profiles --
local function LoadingProfiles()
	if counterLoading == 0 and number > 0 then
		for k, v in pairs(VCBprofiles) do
			counterLoading = counterLoading + 1
			local btn = CreateFrame("Button", "vcbOptions6Box2PopOut1Choice"..counterLoading, nil, "vdwPopOutButton")
			_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:ClearAllPoints()
			if counterLoading == 1 then
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:SetParent(vcbOptions6Box2PopOut1)
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:SetPoint("TOP", vcbOptions6Box2PopOut1, "BOTTOM", 0, 4)
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:SetScript("OnShow", function(self)
					self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
					PlaySound(855, "Master")
				end)
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:SetScript("OnHide", function(self)
					self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
					PlaySound(855, "Master")
				end)
			else
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:SetParent(vcbOptions6Box2PopOut1Choice1)
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:SetPoint("TOP", _G["vcbOptions6Box2PopOut1Choice"..counterLoading-1], "BOTTOM", 0, 0)
				_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:Show()
			end
			_G["vcbOptions6Box2PopOut1Choice"..counterLoading].Text:SetText(k)
			_G["vcbOptions6Box2PopOut1Choice"..counterLoading]:HookScript("OnClick", function(self, button, down)
				if button == "LeftButton" and down == false then
					VCBsettings = VCBprofiles[k]["settings"]
					VCBspecialSettings.LastLocation = VCBprofiles[k]["localization"]
					C_UI.Reload()
				end
			end)
			local w = _G["vcbOptions6Box2PopOut1Choice"..counterLoading].Text:GetStringWidth()
			if w > maxW then maxW = w end
		end
		finalW = math.ceil(maxW + 24)
		for i = 1, counterLoading do
			_G["vcbOptions6Box2PopOut1Choice"..i]:SetWidth(finalW)
		end
	end
end
-- functions for deleting the profiles --
local function DeletingProfiles()
	if counterDeleting == 0 and number > 0 then
		for k, v in pairs(VCBprofiles) do
			counterDeleting = counterDeleting + 1
			local btn = CreateFrame("Button", "vcbOptions6Box3PopOut1Choice"..counterDeleting, nil, "vdwPopOutButton")
			_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:ClearAllPoints()
			if counterDeleting == 1 then
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:SetParent(vcbOptions6Box3PopOut1)
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:SetPoint("TOP", vcbOptions6Box3PopOut1, "BOTTOM", 0, 4)
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:SetScript("OnShow", function(self)
					self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-hover")
					PlaySound(855, "Master")
				end)
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:SetScript("OnHide", function(self)
					self:GetParent():SetNormalAtlas("charactercreate-customize-dropdownbox-open")
					PlaySound(855, "Master")
				end)
			else
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:SetParent(vcbOptions6Box3PopOut1Choice1)
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:SetPoint("TOP", _G["vcbOptions6Box3PopOut1Choice"..counterDeleting-1], "BOTTOM", 0, 0)
				_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:Show()
			end
			_G["vcbOptions6Box3PopOut1Choice"..counterDeleting].Text:SetText(k)
			_G["vcbOptions6Box3PopOut1Choice"..counterDeleting]:HookScript("OnClick", function(self, button, down)
				if button == "LeftButton" and down == false then
					VCBprofiles[k] = nil
					C_UI.Reload()
				end
			end)
			local w = _G["vcbOptions6Box3PopOut1Choice"..counterDeleting].Text:GetStringWidth()
			if w > maxW then maxW = w end
		end
		finalW = math.ceil(maxW + 24)
		for i = 1, counterDeleting do
			_G["vcbOptions6Box3PopOut1Choice"..i]:SetWidth(finalW)
		end
	end
end
vcbOptions6Box2PopOut1.Text:SetText(G.BUTTON_L_CLICK)
vcbOptions6Box3PopOut1.Text:SetText(G.BUTTON_L_CLICK)
FindingKeys()
LoadingProfiles()
DeletingProfiles()
-- show the option panel --
vcbOptions6:HookScript("OnShow", function(self)
	for i = 1, 5, 1 do
		_G["vcbOptions0Tab"..i].Text:SetTextColor(0.4, 0.4, 0.4, 1)
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
	vcbOptions0Tab6.Text:SetTextColor(C.High:GetRGB())
end)
