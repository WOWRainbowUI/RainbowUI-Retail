-- taking care of the panel --
vcbOptions0.BGtexture:SetAlpha(0.70)
vcbOptions0.TopTxt:SetText("打開|cffFF0055設定選項|r時建議關閉其他視窗，這樣才能看到你所做的變更!")
vcbOptions0.CenterTxt:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Voodoo").." Casting "..vcbHighColor:WrapTextInColorCode("Bar!").." 是個增強內建施法條的插件!|n|n請按下方的按鈕打開設定選項!")
vcbOptions0.BottomTxt:SetText("感謝使用這個超棒der插件!|n你是個|cff00CED1時髦|r又|cffFF0055帥氣|r的人!|n願美好的|cff9400D3魔力|r與你同在!")
-- button 1 to option's panel --
vcbOptions0Button1.Text:SetText("設定選項")
-- enter --
vcbOptions0Button1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("點一下: "..vcbMainColor:WrapTextInColorCode("打開設定選項視窗!")) 
end)
-- leave --
vcbOptions0Button1:SetScript("OnLeave", vcbLeavingMenus)
-- click --
vcbOptions0Button1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		vcbShowMenu()
	end
end)
-- Move the Tabs --
vcbOptions00:RegisterForDrag("LeftButton")
vcbOptions00:SetScript("OnDragStart", vcbOptions00.StartMoving)
vcbOptions00:SetScript("OnDragStop", vcbOptions00.StopMovingOrSizing)
-- taking care of the Tabs --
-- position --
for i = 2, 4, 1 do
	_G["vcbOptions00Tab"..i]:SetPoint("TOP", _G["vcbOptions00Tab"..i-1], "BOTTOM", 0, 0)
end
-- naming --
vcbOptions00Tab1.Text:SetText("玩家施法條")
vcbOptions00Tab2.Text:SetText("目標施法條")
vcbOptions00Tab3.Text:SetText("專注目標施法條")
vcbOptions00Tab4.Text:SetText("設定檔")
-- hiding the center text --
for i = 1, 3, 1 do
	_G["vcbOptions00Tab"..i].CenterTxt:Hide()
end
vcbOptions00Tab4.CenterTxt:SetText("感謝使用這個超棒der插件!|n你是個|cff00CED1時髦|r又|cffFF0055帥氣|r的人!|n願美好的|cff9400D3魔力|r與你同在!")
vcbOptions00.BGtexture:SetGradient("VERTICAL", vcbNoMainColor, vcbMainColor)
vcbOptions00.BGtexture:ClearAllPoints()
vcbOptions00.BGtexture:SetPoint("TOPRIGHT", vcbOptions00, "TOPRIGHT", 0, 0)
vcbOptions00.BGtexture:SetPoint("BOTTOMLEFT", vcbOptions00Tab4, "BOTTOMLEFT", 0, -128)
-- clicking on the tabs --
for i = 1, 4, 1 do
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
	end
end)
-- hiding the tabs --
vcbOptions00:HookScript("OnHide", function(self)
	for i = 1, 4, 1 do
		if _G["vcbOptions"..i]:IsShown() then _G["vcbOptions"..i]:Hide() end
	end
end)
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		local category = Settings.RegisterCanvasLayoutCategory(self, "VCB")
		category:SetName("施法條")
		Settings.RegisterAddOnCategory(category)
	end
end
vcbOptions0:SetScript("OnEvent", EventsTime)
