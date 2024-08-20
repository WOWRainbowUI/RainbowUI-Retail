-- taking care of the panel --
vcbOptions1:ClearAllPoints()
vcbOptions1:SetPoint("TOPLEFT", vcbOptions00, "TOPLEFT", 0, 0)
vcbOptions1.BGtexture:SetAlpha(1)
vcbOptions1.TopTxt:SetText("Player's Castbar Options!")
vcbOptions1.CenterTxt:Hide()
vcbOptions1.BottomLeftTxt:Hide()
vcbOptions1Box1.TitleTxt:SetText("Spell's Icon & Spell's Name")
vcbOptions1Box2:SetPoint("TOP", vcbOptions1Box1, "BOTTOM", 0, 0)
vcbOptions1Box2.TitleTxt:SetText("Current Cast Time")
vcbOptions1Box3:SetPoint("TOP", vcbOptions1Box2, "BOTTOM", 0, 0)
vcbOptions1Box3.TitleTxt:SetText("Current & Total Cast Time")
vcbOptions1Box4:SetPoint("TOP", vcbOptions1Box3, "BOTTOM", 0, 0)
vcbOptions1Box4.TitleTxt:SetText("Total Cast Time")
vcbOptions1Box5:SetPoint("TOP", vcbOptions1Box4, "BOTTOM", 0, 0)
vcbOptions1Box5.TitleTxt:SetText("Latency Bar & Castingbar's Color")
vcbOptions1Box6:SetPoint("TOP", vcbOptions1Box5, "BOTTOM", 0, 0)
vcbOptions1Box6.TitleTxt:SetText("Ticks of the Spells")
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions1Box1PopOut1:SetText(VCBrPlayer["Icon"])
	vcbOptions1Box1PopOut2:SetText(VCBrPlayer["NameText"])
	vcbOptions1Box2PopOut1:SetText(VCBrPlayer["CurrentTimeText"]["Position"])
	vcbOptions1Box2PopOut2:SetText(VCBrPlayer["CurrentTimeText"]["Direction"])
	vcbOptions1Box2PopOut3:SetText(VCBrPlayer["CurrentTimeText"]["Sec"])
	vcbOptions1Box3PopOut1:SetText(VCBrPlayer["BothTimeText"]["Position"])
	vcbOptions1Box3PopOut2:SetText(VCBrPlayer["BothTimeText"]["Direction"])
	vcbOptions1Box3PopOut3:SetText(VCBrPlayer["BothTimeText"]["Sec"])
	vcbOptions1Box4PopOut1:SetText(VCBrPlayer["TotalTimeText"]["Position"])
	vcbOptions1Box4PopOut2:SetText(VCBrPlayer["TotalTimeText"]["Sec"])
	vcbOptions1Box5PopOut1:SetText(VCBrPlayer["LagBar"])
	vcbOptions1Box5PopOut2:SetText(VCBrPlayer["Color"])
	vcbOptions1Box6PopOut1:SetText(VCBrPlayer["Ticks"])
end
-- Box 1, pop out 1, Spell's Icon --
-- Entering, leaving, click --
vcbOptions1Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nSpell's Icon to be shown?") 
end)
vcbOptions1Box1PopOut1:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box1PopOut1, vcbOptions1Box1PopOut1Choice0)
-- sort & clicking --
for i = 1, 3, 1 do
	local k = i - 1
	_G["vcbOptions1Box1PopOut1Choice"..i]:SetParent(vcbOptions1Box1PopOut1Choice0)
	_G["vcbOptions1Box1PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box1PopOut1Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box1PopOut1Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Icon"] = self.Text:GetText()
			vcbOptions1Box1PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box1PopOut1Choice0:Hide()
		end
	end)
end
vcbOptions1Box1PopOut1Choice3:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["Icon"] = self.Text:GetText()
		vcbOptions1Box1PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box1PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box1PopOut1Choice0.Text:SetText("Left")
vcbOptions1Box1PopOut1Choice1.Text:SetText("Right")
vcbOptions1Box1PopOut1Choice2.Text:SetText("Left and Right")
vcbOptions1Box1PopOut1Choice3.Text:SetText("Hide")
-- Box 1 pop out 2 Spell's Name --
-- Entering, leaving, click --
vcbOptions1Box1PopOut2:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nSpell's Name to be shown?") 
end)
vcbOptions1Box1PopOut2:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box1PopOut2, vcbOptions1Box1PopOut2Choice0)
-- sort & clicking --
for i = 1, 9, 1 do
	local k = i - 1
	_G["vcbOptions1Box1PopOut2Choice"..i]:SetParent(vcbOptions1Box1PopOut2Choice0)
	_G["vcbOptions1Box1PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box1PopOut2Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box1PopOut2Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["NameText"] = self.Text:GetText()
			vcbOptions1Box1PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box1PopOut2Choice0:Hide()
		end
	end)
end
vcbOptions1Box1PopOut2Choice9:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["NameText"] = self.Text:GetText()
		vcbOptions1Box1PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box1PopOut2Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box1PopOut2Choice0.Text:SetText("Top Left")
vcbOptions1Box1PopOut2Choice1.Text:SetText("Left")
vcbOptions1Box1PopOut2Choice2.Text:SetText("Bottom Left")
vcbOptions1Box1PopOut2Choice3.Text:SetText("Top")
vcbOptions1Box1PopOut2Choice4.Text:SetText("Center")
vcbOptions1Box1PopOut2Choice5.Text:SetText("Bottom")
vcbOptions1Box1PopOut2Choice6.Text:SetText("Top Right")
vcbOptions1Box1PopOut2Choice7.Text:SetText("Right")
vcbOptions1Box1PopOut2Choice8.Text:SetText("Bottom Right")
vcbOptions1Box1PopOut2Choice9.Text:SetText("Hide")
-- Box 2, pop out 1, Current Cast Time --
-- Entering, leaving, click --
vcbOptions1Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent Cast Time to be shown?") 
end)
vcbOptions1Box2PopOut1:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box2PopOut1, vcbOptions1Box2PopOut1Choice0)
-- sort & clicking --
for i = 1, 9, 1 do
	local k = i - 1
	_G["vcbOptions1Box2PopOut1Choice"..i]:SetParent(vcbOptions1Box2PopOut1Choice0)
	_G["vcbOptions1Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut1Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box2PopOut1Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box2PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box2PopOut1Choice0:Hide()
		end
	end)
end
vcbOptions1Box2PopOut1Choice9:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["CurrentTimeText"]["Position"] = self.Text:GetText()
		vcbOptions1Box2PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box2PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box2PopOut1Choice0.Text:SetText("Top Left")
vcbOptions1Box2PopOut1Choice1.Text:SetText("Left")
vcbOptions1Box2PopOut1Choice2.Text:SetText("Bottom Left")
vcbOptions1Box2PopOut1Choice3.Text:SetText("Top")
vcbOptions1Box2PopOut1Choice4.Text:SetText("Center")
vcbOptions1Box2PopOut1Choice5.Text:SetText("Bottom")
vcbOptions1Box2PopOut1Choice6.Text:SetText("Top Right")
vcbOptions1Box2PopOut1Choice7.Text:SetText("Right")
vcbOptions1Box2PopOut1Choice8.Text:SetText("Bottom Right")
vcbOptions1Box2PopOut1Choice9.Text:SetText("Hide")
-- Box 2, pop out 2, Ascending or Descending --
-- Entering, leaving, click --
vcbOptions1Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
vcbOptions1Box2PopOut2:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box2PopOut2, vcbOptions1Box2PopOut2Choice0)
-- sort --
for i = 1, 2, 1 do
	local k = i - 1
	_G["vcbOptions1Box2PopOut2Choice"..i]:SetParent(vcbOptions1Box2PopOut2Choice0)
	_G["vcbOptions1Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut2Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box2PopOut2Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions1Box2PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box2PopOut2Choice0:Hide()
		end
	end)
end
vcbOptions1Box2PopOut2Choice2:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["CurrentTimeText"]["Direction"] = self.Text:GetText()
		vcbOptions1Box2PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box2PopOut2Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box2PopOut2Choice0.Text:SetText("Ascending")
vcbOptions1Box2PopOut2Choice1.Text:SetText("Descending")
vcbOptions1Box2PopOut2Choice2.Text:SetText("Both")
-- Box 2, pop out 3, Sec Show or Hide --
-- Entering, leaving, click --
vcbOptions1Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
vcbOptions1Box2PopOut3:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box2PopOut3, vcbOptions1Box2PopOut3Choice0)
-- sort & clicking --
vcbOptions1Box2PopOut3Choice1:SetParent(vcbOptions1Box2PopOut3Choice0)
vcbOptions1Box2PopOut3Choice1:SetPoint("TOP",vcbOptions1Box2PopOut3Choice0, "BOTTOM", 0, 0)
vcbOptions1Box2PopOut3Choice0:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["CurrentTimeText"]["Sec"] = self.Text:GetText()
		vcbOptions1Box2PopOut3.Text:SetText(self:GetText())
		vcbOptions1Box2PopOut3Choice0:Hide()
	end
end)
vcbOptions1Box2PopOut3Choice1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["CurrentTimeText"]["Sec"] = self.Text:GetText()
		vcbOptions1Box2PopOut3.Text:SetText(self:GetText())
		vcbOptions1Box2PopOut3Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box2PopOut3Choice0.Text:SetText("Show")
vcbOptions1Box2PopOut3Choice1.Text:SetText("Hide")
-- Box 3, pop out 1, Current & Total Cast Time --
-- Entering, leaving, click --
vcbOptions1Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent/Total Cast Time to be shown?") 
end)
vcbOptions1Box3PopOut1:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box3PopOut1, vcbOptions1Box3PopOut1Choice0)
-- sort & clicking --
for i = 1, 9, 1 do
	local k = i - 1
	_G["vcbOptions1Box3PopOut1Choice"..i]:SetParent(vcbOptions1Box3PopOut1Choice0)
	_G["vcbOptions1Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut1Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box3PopOut1Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box3PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box3PopOut1Choice0:Hide()
		end
	end)
end
vcbOptions1Box3PopOut1Choice9:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["BothTimeText"]["Position"] = self.Text:GetText()
		vcbOptions1Box3PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box3PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box3PopOut1Choice0.Text:SetText("Top Left")
vcbOptions1Box3PopOut1Choice1.Text:SetText("Left")
vcbOptions1Box3PopOut1Choice2.Text:SetText("Bottom Left")
vcbOptions1Box3PopOut1Choice3.Text:SetText("Top")
vcbOptions1Box3PopOut1Choice4.Text:SetText("Center")
vcbOptions1Box3PopOut1Choice5.Text:SetText("Bottom")
vcbOptions1Box3PopOut1Choice6.Text:SetText("Top Right")
vcbOptions1Box3PopOut1Choice7.Text:SetText("Right")
vcbOptions1Box3PopOut1Choice8.Text:SetText("Bottom Right")
vcbOptions1Box3PopOut1Choice9.Text:SetText("Hide")
-- Box 3, pop out 2, Ascending or Descending --
-- Entering, leaving, click --
vcbOptions1Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
vcbOptions1Box3PopOut2:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box3PopOut2, vcbOptions1Box3PopOut2Choice0)
-- sort & clicking --
for i = 1, 2, 1 do
	local k = i - 1
	_G["vcbOptions1Box3PopOut2Choice"..i]:SetParent(vcbOptions1Box3PopOut2Choice0)
	_G["vcbOptions1Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut2Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box3PopOut2Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions1Box3PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box3PopOut2Choice0:Hide()
		end
	end)
end
vcbOptions1Box3PopOut2Choice2:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["BothTimeText"]["Direction"] = self.Text:GetText()
		vcbOptions1Box3PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box3PopOut2Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box3PopOut2Choice0.Text:SetText("Ascending")
vcbOptions1Box3PopOut2Choice1.Text:SetText("Descending")
vcbOptions1Box3PopOut2Choice2.Text:SetText("Both")
-- Box 3, pop out 3, Sec Show or Hide --
-- Entering, leaving, click --
vcbOptions1Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
vcbOptions1Box3PopOut3:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box3PopOut3, vcbOptions1Box3PopOut3Choice0)
-- sort & clicking --
vcbOptions1Box3PopOut3Choice1:SetParent(vcbOptions1Box3PopOut3Choice0)
vcbOptions1Box3PopOut3Choice1:SetPoint("TOP",vcbOptions1Box3PopOut3Choice0, "BOTTOM", 0, 0)
vcbOptions1Box3PopOut3Choice0:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["BothTimeText"]["Sec"] = self.Text:GetText()
		vcbOptions1Box3PopOut3.Text:SetText(self:GetText())
		vcbOptions1Box3PopOut3Choice0:Hide()
	end
end)
vcbOptions1Box3PopOut3Choice1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["BothTimeText"]["Sec"] = self.Text:GetText()
		vcbOptions1Box3PopOut3.Text:SetText(self:GetText())
		vcbOptions1Box3PopOut3Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box3PopOut3Choice0.Text:SetText("Show")
vcbOptions1Box3PopOut3Choice1.Text:SetText("Hide")
-- Box 4, pop out 1, Total Cast Time --
-- Entering, leaving, click --
vcbOptions1Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nTotal Cast Time to be shown?") 
end)
vcbOptions1Box4PopOut1:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box4PopOut1, vcbOptions1Box4PopOut1Choice0)
-- sort & clicking --
for i = 1, 9, 1 do
	local k = i - 1
	_G["vcbOptions1Box4PopOut1Choice"..i]:SetParent(vcbOptions1Box4PopOut1Choice0)
	_G["vcbOptions1Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box4PopOut1Choice"..k], "BOTTOM", 0, 0)
	_G["vcbOptions1Box4PopOut1Choice"..k]:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box4PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box4PopOut1Choice0:Hide()
		end
	end)
end
vcbOptions1Box4PopOut1Choice9:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["TotalTimeText"]["Position"] = self.Text:GetText()
		vcbOptions1Box4PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box4PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box4PopOut1Choice0.Text:SetText("Top Left")
vcbOptions1Box4PopOut1Choice1.Text:SetText("Left")
vcbOptions1Box4PopOut1Choice2.Text:SetText("Bottom Left")
vcbOptions1Box4PopOut1Choice3.Text:SetText("Top")
vcbOptions1Box4PopOut1Choice4.Text:SetText("Center")
vcbOptions1Box4PopOut1Choice5.Text:SetText("Bottom")
vcbOptions1Box4PopOut1Choice6.Text:SetText("Top Right")
vcbOptions1Box4PopOut1Choice7.Text:SetText("Right")
vcbOptions1Box4PopOut1Choice8.Text:SetText("Bottom Right")
vcbOptions1Box4PopOut1Choice9.Text:SetText("Hide")
-- Box 4, pop out 2, Sec Show or Hide --
-- Entering, leaving, click --
vcbOptions1Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
vcbOptions1Box4PopOut2:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box4PopOut2, vcbOptions1Box4PopOut2Choice0)
-- sort & clicking --
vcbOptions1Box4PopOut2Choice1:SetParent(vcbOptions1Box4PopOut2Choice0)
vcbOptions1Box4PopOut2Choice1:SetPoint("TOP",vcbOptions1Box4PopOut2Choice0, "BOTTOM", 0, 0)
vcbOptions1Box4PopOut2Choice0:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["TotalTimeText"]["Sec"] = self.Text:GetText()
		vcbOptions1Box4PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box4PopOut2Choice0:Hide()
	end
end)
vcbOptions1Box4PopOut2Choice1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["TotalTimeText"]["Sec"] = self.Text:GetText()
		vcbOptions1Box4PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box4PopOut2Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box4PopOut2Choice0.Text:SetText("Show")
vcbOptions1Box4PopOut2Choice1.Text:SetText("Hide")
-- Box 5, pop out 1, Lag Bar --
-- Entering, leaving, click --
vcbOptions1Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nLatency's Bar to be shown?") 
end)
vcbOptions1Box5PopOut1:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box5PopOut1, vcbOptions1Box5PopOut1Choice0)
-- sort & clicking --
vcbOptions1Box5PopOut1Choice1:SetParent(vcbOptions1Box5PopOut1Choice0)
vcbOptions1Box5PopOut1Choice1:SetPoint("TOP",vcbOptions1Box5PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions1Box5PopOut1Choice0:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["LagBar"] = self.Text:GetText()
		vcbOptions1Box5PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box5PopOut1Choice0:Hide()
	end
end)
vcbOptions1Box5PopOut1Choice1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["LagBar"] = self.Text:GetText()
		vcbOptions1Box5PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box5PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box5PopOut1Choice0.Text:SetText("Show")
vcbOptions1Box5PopOut1Choice1.Text:SetText("Hide")
-- Box 5, pop out 2, Castbar's Color --
-- Entering, leaving, click --
vcbOptions1Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhat color do you want the|nCastbar to be?") 
end)
vcbOptions1Box5PopOut2:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box5PopOut2, vcbOptions1Box5PopOut2Choice0)
-- sort & clicking --
vcbOptions1Box5PopOut2Choice1:SetParent(vcbOptions1Box5PopOut2Choice0)
vcbOptions1Box5PopOut2Choice1:SetPoint("TOP",vcbOptions1Box5PopOut2Choice0, "BOTTOM", 0, 0)
vcbOptions1Box5PopOut2Choice0:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["Color"] = self.Text:GetText()
		vcbOptions1Box5PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box5PopOut2Choice0:Hide()
	end
end)
vcbOptions1Box5PopOut2Choice1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["Color"] = self.Text:GetText()
		vcbOptions1Box5PopOut2.Text:SetText(self:GetText())
		vcbOptions1Box5PopOut2Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box5PopOut2Choice0.Text:SetText("Default Color")
vcbOptions1Box5PopOut2Choice1.Text:SetText("Class' Color")
-- Box 6, pop out 1, Ticks of the Spells --
-- Entering, leaving, click --
vcbOptions1Box6PopOut1:SetScript("OnEnter", function(self)
	vcbEntering(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nTicks of the Spells to be shown?") 
end)
vcbOptions1Box6PopOut1:SetScript("OnLeave", vcbLeaving)
vcbClickPopOut(vcbOptions1Box6PopOut1, vcbOptions1Box6PopOut1Choice0)
-- sort & clicking --
vcbOptions1Box6PopOut1Choice1:SetParent(vcbOptions1Box6PopOut1Choice0)
vcbOptions1Box6PopOut1Choice1:SetPoint("TOP",vcbOptions1Box6PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions1Box6PopOut1Choice0:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["Ticks"] = self.Text:GetText()
		vcbOptions1Box6PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box6PopOut1Choice0:Hide()
	end
end)
vcbOptions1Box6PopOut1Choice1:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrPlayer["Ticks"] = self.Text:GetText()
		vcbOptions1Box6PopOut1.Text:SetText(self:GetText())
		vcbOptions1Box6PopOut1Choice0:Hide()
	end
end)
-- naming --
vcbOptions1Box6PopOut1Choice0.Text:SetText("Show")
vcbOptions1Box6PopOut1Choice1.Text:SetText("Hide")
-- Showing the panel --
vcbOptions1:SetScript("OnShow", function(self)
	CheckSavedVariables()
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbDeafultColor:GetRGB())
end)
