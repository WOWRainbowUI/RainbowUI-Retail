-- some variables --
local L = VDW.VCB.Local
local C = VDW.GetAddonColors("VCB")
local prefixTip = VDW.Prefix("VCB")
local maxW = 128
local finalW = 0
-- entering exit button --
vcbOptions0.ExitButton:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.TIP_CLOSE_PANEL, C.Main)
end)
-- Move the tabs frame --
vcbOptions0:RegisterForDrag("LeftButton")
vcbOptions0:SetScript("OnDragStart", vcbOptions0.StartMoving)
vcbOptions0:SetScript("OnDragStop", vcbOptions0.StopMovingOrSizing)
-- Taking care of the Tabs --
-- Naming the tab --
vcbOptions0Tab1.Text:SetText(L.T_PLAYER)
vcbOptions0Tab2.Text:SetText(L.T_TARGET)
vcbOptions0Tab3.Text:SetText(L.T_FOCUS)
vcbOptions0Tab4.Text:SetText(L.T_BOSS)
vcbOptions0Tab5.Text:SetText(L.T_ARENA)
vcbOptions0Tab6.Text:SetText(L.P_TAB)
-- Position & center text color --
for i = 1, 6, 1 do
	local w = _G["vcbOptions0Tab"..i].Text:GetStringWidth()
	if w > maxW then maxW = w end
end
finalW = math.ceil(maxW + 16)
for i = 1, 6, 1 do
	if i == 1 then
		_G["vcbOptions0Tab"..i]:SetWidth(finalW)
	else
		_G["vcbOptions0Tab"..i]:SetWidth(finalW)
		_G["vcbOptions0Tab"..i]:SetPoint("TOP", _G["vcbOptions0Tab"..i-1], "BOTTOM", 0, 0)
	end
end
-- Entering the tabs --
for i = 1, 5, 1 do
	_G["vcbOptions0Tab"..i]:HookScript("OnEnter", function(self)
		local word = self.Text:GetText()
		VDW.Tooltip_Show(self, prefixTip, string.format(L.T_TIP, word), C.Main)
	end)
end
vcbOptions0Tab6:HookScript("OnEnter", function(self)
	VDW.Tooltip_Show(self, prefixTip, L.P_TITLE, C.Main)
end)
-- Leaving the tabs --
for i = 1, 6, 1 do
	_G["vcbOptions0Tab"..i]:HookScript("OnLeave", function(self)
		VDW.Tooltip_Hide()
	end)
end
-- clickingthe tabs --
for i = 1, 6, 1 do
	_G["vcbOptions0Tab"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Show() end
		end
	end)
end
-- Background of the tabs frame --
vcbOptions0.BGtexture:ClearAllPoints()
vcbOptions0.BGtexture:SetPoint("TOPRIGHT", vcbOptions0, "TOPRIGHT", 0, 0)
vcbOptions0.BGtexture:SetPoint("BOTTOMLEFT", vcbOptions0, "BOTTOMLEFT", 528, 0)
vcbOptions0.BGtexture:SetTexture("Interface\\FontStyles\\FontStyleParchment.blp", "CLAMP", "CLAMP", "NEAREST")
vcbOptions0.BGtexture:SetDesaturation(0.3)
vcbOptions0.BGtexture:SetGradient("VERTICAL", C.NoHigh, C.High)

-- show the tabs frame --
vcbOptions0:SetScript("OnShow", function(self)
	self:SetWidth(vcbOptions0Tab1:GetWidth() + vcbOptions1:GetWidth())
	if not vcbOptions1:IsShown() then vcbOptions1:Show() end
end)
-- Hide the tabs frame --
vcbOptions0:HookScript("OnHide", function(self)
	for i = 1, 6, 1 do
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
end)
