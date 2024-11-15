-- Move the Tabs --
vcbOptions00:RegisterForDrag("LeftButton")
vcbOptions00:SetScript("OnDragStart", vcbOptions00.StartMoving)
vcbOptions00:SetScript("OnDragStop", vcbOptions00.StopMovingOrSizing)
-- taking care of the Tabs --
-- position --
for i = 2, 6, 1 do
	_G["vcbOptions00Tab"..i]:SetPoint("TOP", _G["vcbOptions00Tab"..i-1], "BOTTOM", 0, 0)
end
-- naming --
vcbOptions00Tab1.Text:SetText("Player's Castbar")
vcbOptions00Tab2.Text:SetText("Target's Castbar")
vcbOptions00Tab3.Text:SetText("Focus' Castbar")
vcbOptions00Tab4.Text:SetText("Boss' Castbar")
vcbOptions00Tab5.Text:SetText("Arena's Castbar")
vcbOptions00Tab5:Hide()
vcbOptions00Tab6.Text:SetText("Profiles")
-- hiding the center text --
for i = 1, 5, 1 do
	_G["vcbOptions00Tab"..i].CenterTxt:Hide()
end
vcbOptions00Tab6.CenterTxt:SetText("Thank you for using this amazing add-on!|nYou are a |cff00CED1Funky|r and a |cffFF0055Groovy|r person!|nMay the good |cff9400D3Mojo|r be with you!")
vcbOptions00.BGtexture:SetGradient("VERTICAL", vcbNoMainColor, vcbMainColor)
vcbOptions00.BGtexture:ClearAllPoints()
vcbOptions00.BGtexture:SetPoint("TOPRIGHT", vcbOptions00, "TOPRIGHT", 0, 0)
vcbOptions00.BGtexture:SetPoint("BOTTOMLEFT", vcbOptions00Tab6, "BOTTOMLEFT", 0, -128)
-- clicking on the tabs --
for i = 1, 6, 1 do
	_G["vcbOptions00Tab"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Show() end
		end
	end)
end
-- showing the tabs --
vcbOptions00:SetScript("OnShow", function(self)
	if not vcbOptions1:IsShown() then vcbOptions1:Show() end
end)
-- hiding the tabs --
vcbOptions00:HookScript("OnHide", function(self)
	for i = 1, 6, 1 do
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
end)
