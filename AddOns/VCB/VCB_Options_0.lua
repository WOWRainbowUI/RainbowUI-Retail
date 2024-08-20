-- taking care of the panel --
vcbOptions0.BGtexture:SetAlpha(0.70)
vcbOptions0.TopTxt:SetText("打開|cffFF0055設定選項|r時建議關閉其他視窗，這樣才能看到你所做的變更!")
vcbOptions0.CenterTxt:SetText(vcbHighColor:WrapTextInColorCode("巫毒").."施法"..vcbHighColor:WrapTextInColorCode("條").."是個增強內建施法條的插件!|n|n請按下方的按鈕打開設定選項!")
vcbOptions0.BottomTxt:SetText("感謝您使用這個超棒der插件!|n你是個|cff00CED1時髦|r又|cffFF0055先進|r的人!|n願美好的|cff9400D3魔力|r與你同在!")
-- button 1 do it --
vcbOptions0Button1.Text:SetText("設定選項")
vcbOptions0Button1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText("打開主要設定視窗!") 
end)
vcbOptions0Button1:SetScript("OnLeave", vcbLeaving)
vcbOptions0Button1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions00:IsShown() then
			vcbOptions00:Show()
			PlaySound(855, "Master")
		else
			vcbOptions00:Hide()
			PlaySound(858, "Master")
		end
	end
end)
-- Move the Tabs --
vcbOptions00:RegisterForDrag("LeftButton")
vcbOptions00:SetScript("OnDragStart", vcbOptions00.StartMoving)
vcbOptions00:SetScript("OnDragStop", vcbOptions00.StopMovingOrSizing)
-- taking care of the Tabs --
vcbOptions00Tab2:SetPoint("TOP", vcbOptions00Tab1, "BOTTOM", 0, 0)
vcbOptions00Tab3:SetPoint("TOP", vcbOptions00Tab2, "BOTTOM", 0, 0)
vcbOptions00Tab4:SetPoint("TOP", vcbOptions00Tab3, "BOTTOM", 0, 0)
vcbOptions00Tab1.Text:SetText("玩家施法條")
vcbOptions00Tab2.Text:SetText("目標施法條")
vcbOptions00Tab3.Text:SetText("專注目標施法條")
vcbOptions00Tab4.Text:SetText("設定檔")
vcbOptions00Tab1.CenterTxt:Hide()
vcbOptions00Tab2.CenterTxt:Hide()
vcbOptions00Tab3.CenterTxt:Hide()
vcbOptions00Tab4.CenterTxt:SetText("感謝您使用這個超棒der插件!|n你是個|cff00CED1時髦|r又|cffFF0055先進|r的人!|n願美好的|cff9400D3魔力|r與你同在!")
vcbOptions00.BGtexture:SetGradient("VERTICAL", vcbNoColor, vcbMainColor)
vcbOptions00.BGtexture:ClearAllPoints()
vcbOptions00.BGtexture:SetPoint("TOPRIGHT", vcbOptions00, "TOPRIGHT", 0, 0)
vcbOptions00.BGtexture:SetPoint("BOTTOMLEFT", vcbOptions00Tab4, "BOTTOMLEFT", 0, -128)
-- clicking on the tabs --
vcbOptions00Tab1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions1:IsShown() then vcbOptions1:Show() end
	end
end)
vcbOptions00Tab2:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions2:IsShown() then vcbOptions2:Show() end
	end
end)
vcbOptions00Tab3:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions3:IsShown() then vcbOptions3:Show() end
	end
end)
vcbOptions00Tab4:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if not vcbOptions4:IsShown() then vcbOptions4:Show() end
	end
end)
-- showing the tabs --
vcbOptions00:SetScript("OnShow", function(self)
	if not vcbOptions1:IsShown() then vcbOptions1:Show() end
end)
-- hiding the tabs --
vcbOptions00:SetScript("OnHide", function(self)
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
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
