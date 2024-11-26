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
vcbOptions00Tab1.Text:SetText("玩家施法條")
vcbOptions00Tab2.Text:SetText("目標施法條")
vcbOptions00Tab3.Text:SetText("專注目標施法條")
vcbOptions00Tab4.Text:SetText("首領施法條")
vcbOptions00Tab5.Text:SetText("競技場施法條")
vcbOptions00Tab5:Hide()
vcbOptions00Tab6.Text:SetText("設定檔")
-- hiding the center text --
for i = 1, 5, 1 do
	_G["vcbOptions00Tab"..i].CenterTxt:Hide()
end
vcbOptions00Tab6.CenterTxt:SetText("感謝使用這個超棒der插件!|n你是個|cff00CED1時髦|r又|cffFF0055帥氣|r的人!|n願美好的|cff9400D3魔力|r與你同在!")
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
	if C_AddOns.IsAddOnLoaded("Stuf") or C_AddOns.IsAddOnLoaded("InvenUnitFrames") then
		vcbOptions00Tab2:Hide()
		vcbOptions00Tab3:Hide()
		vcbOptions00Tab4:Hide()
	end
end)
-- hiding the tabs --
vcbOptions00:HookScript("OnHide", function(self)
	for i = 1, 6, 1 do
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
end)
