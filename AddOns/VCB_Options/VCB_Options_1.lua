-- taking care of the panel --
vcbOptions1.TopTxt:SetText("Player's Castbar Options!")
-- naming the boxes --
vcbOptions1Box1.TitleTxt:SetText("Spell's Icon & Spell's Name")
vcbOptions1Box2.TitleTxt:SetText("Current Cast Time")
vcbOptions1Box3.TitleTxt:SetText("Current & Total Cast Time")
vcbOptions1Box4.TitleTxt:SetText("Total Cast Time")
vcbOptions1Box5.TitleTxt:SetText("Latency Bar & Queue Bar")
vcbOptions1Box6.TitleTxt:SetText("Global Cooldown & Spell's Tick")
vcbOptions1Box7.TitleTxt:SetText("Cast Bar's Color")
-- positioning the boxes --
vcbOptions1Box2:SetPoint("TOPLEFT", vcbOptions1Box1, "TOPRIGHT", 0, 0)
vcbOptions1Box3:SetPoint("TOPLEFT", vcbOptions1Box1, "BOTTOMLEFT", 0, 0)
vcbOptions1Box4:SetPoint("TOPRIGHT", vcbOptions1Box2, "BOTTOMRIGHT", 0, 0)
vcbOptions1Box5:SetPoint("TOPLEFT", vcbOptions1Box3, "BOTTOMLEFT", 0, 0)
vcbOptions1Box6:SetPoint("TOPRIGHT", vcbOptions1Box4, "BOTTOMRIGHT", 0, 0)
vcbOptions1Box7:SetPoint("TOPLEFT", vcbOptions1Box5, "BOTTOMLEFT", 0, 0)
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions1Box1PopOut1:SetText(VCBrPlayer["Icon"])
	vcbOptions1Box1PopOut2:SetText(VCBrPlayer["NameText"])
	vcbOptions1Box2PopOut1:SetText(VCBrPlayer["CurrentTimeText"]["Position"])
	vcbOptions1Box2PopOut2:SetText(VCBrPlayer["CurrentTimeText"]["Direction"])
	vcbOptions1Box2PopOut3:SetText(VCBrPlayer["CurrentTimeText"]["Sec"])
	vcbOptions1Box2PopOut4:SetText(VCBrPlayer["CurrentTimeText"]["Decimals"])
	vcbOptions1Box3PopOut1:SetText(VCBrPlayer["BothTimeText"]["Position"])
	vcbOptions1Box3PopOut2:SetText(VCBrPlayer["BothTimeText"]["Direction"])
	vcbOptions1Box3PopOut3:SetText(VCBrPlayer["BothTimeText"]["Sec"])
	vcbOptions1Box3PopOut4:SetText(VCBrPlayer["BothTimeText"]["Decimals"])
	vcbOptions1Box4PopOut1:SetText(VCBrPlayer["TotalTimeText"]["Position"])
	vcbOptions1Box4PopOut2:SetText(VCBrPlayer["TotalTimeText"]["Sec"])
	vcbOptions1Box4PopOut3:SetText(VCBrPlayer["TotalTimeText"]["Decimals"])
	vcbOptions1Box5PopOut1:SetText(VCBrPlayer["LagBar"])
	vcbOptions1Box5PopOut2:SetText(VCBrPlayer["QueueBar"])
	vcbOptions1Box6PopOut1:SetText(VCBrPlayer["Ticks"])
	vcbOptions1Box6PopOut2:SetText(VCBrPlayer["GCD"]["ClassicTexture"])
	vcbOptions1Box7PopOut1:SetText(VCBrPlayer["Color"])
end
-- Box 1 Spell's Icon and Spell's Name --
-- pop out 1 Spell's Icon --
-- enter --
vcbOptions1Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nSpell's Icon to be shown?") 
end)
-- naming --
vcbOptions1Box1PopOut1Choice0.Text:SetText("Left")
vcbOptions1Box1PopOut1Choice1.Text:SetText("Right")
vcbOptions1Box1PopOut1Choice2.Text:SetText("Left and Right")
vcbOptions1Box1PopOut1Choice3.Text:SetText("Hide")
-- parent & sort --
for i = 1, 3, 1 do
	_G["vcbOptions1Box1PopOut1Choice"..i]:SetParent(vcbOptions1Box1PopOut1Choice0)
	_G["vcbOptions1Box1PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box1PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 3, 1 do
	_G["vcbOptions1Box1PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Icon"] = self.Text:GetText()
			vcbOptions1Box1PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box1PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Spell's Name --
-- enter --
vcbOptions1Box1PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nSpell's Name to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box1PopOut2Choice"..i]:SetParent(vcbOptions1Box1PopOut2Choice0)
	_G["vcbOptions1Box1PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box1PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box1PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["NameText"] = self.Text:GetText()
			vcbOptions1Box1PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box1PopOut2Choice0:Hide()
		end
	end)
end
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions1Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent Cast Time to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box2PopOut1Choice"..i]:SetParent(vcbOptions1Box2PopOut1Choice0)
	_G["vcbOptions1Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box2PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box2PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box2PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current Cast Time Direction --
-- enter --
vcbOptions1Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- naming --
vcbOptions1Box2PopOut2Choice0.Text:SetText("Ascending")
vcbOptions1Box2PopOut2Choice1.Text:SetText("Descending")
vcbOptions1Box2PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box2PopOut2Choice"..i]:SetParent(vcbOptions1Box2PopOut2Choice0)
	_G["vcbOptions1Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box2PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions1Box2PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box2PopOut2Choice0:Hide()
		end
	end)
end
--  pop out 3 Current Cast Time Sec? --
-- enter --
vcbOptions1Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- naming --
vcbOptions1Box2PopOut3Choice0.Text:SetText("Show")
vcbOptions1Box2PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions1Box2PopOut3Choice1:SetParent(vcbOptions1Box2PopOut3Choice0)
vcbOptions1Box2PopOut3Choice1:SetPoint("TOP",vcbOptions1Box2PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box2PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions1Box2PopOut3.Text:SetText(self:GetText())
			vcbOptions1Box2PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Current Cast Time Decimals --
-- enter --
vcbOptions1Box2PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- naming --
vcbOptions1Box2PopOut4Choice0.Text:SetText("0")
vcbOptions1Box2PopOut4Choice1.Text:SetText("1")
vcbOptions1Box2PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box2PopOut4Choice"..i]:SetParent(vcbOptions1Box2PopOut4Choice0)
	_G["vcbOptions1Box2PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box2PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions1Box2PopOut4.Text:SetText(self:GetText())
			vcbOptions1Box2PopOut4Choice0:Hide()
		end
	end)
end
-- Box 3 Current & Total Cast Time --
-- pop out 1 Current & Total Cast Time --
-- enter --
vcbOptions1Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent/Total Cast Time to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box3PopOut1Choice"..i]:SetParent(vcbOptions1Box3PopOut1Choice0)
	_G["vcbOptions1Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box3PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box3PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box3PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current & Total Cast Time Direction --
-- enter --
vcbOptions1Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- naming --
vcbOptions1Box3PopOut2Choice0.Text:SetText("Ascending")
vcbOptions1Box3PopOut2Choice1.Text:SetText("Descending")
vcbOptions1Box3PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box3PopOut2Choice"..i]:SetParent(vcbOptions1Box3PopOut2Choice0)
	_G["vcbOptions1Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box3PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions1Box3PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box3PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Current & Total Cast Time Sec? --
-- enter --
vcbOptions1Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- naming --
vcbOptions1Box3PopOut3Choice0.Text:SetText("Show")
vcbOptions1Box3PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions1Box3PopOut3Choice1:SetParent(vcbOptions1Box3PopOut3Choice0)
vcbOptions1Box3PopOut3Choice1:SetPoint("TOP",vcbOptions1Box3PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box3PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions1Box3PopOut3.Text:SetText(self:GetText())
			vcbOptions1Box3PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Both Time Decimals --
-- enter --
vcbOptions1Box3PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- naming --
vcbOptions1Box3PopOut4Choice0.Text:SetText("0")
vcbOptions1Box3PopOut4Choice1.Text:SetText("1")
vcbOptions1Box3PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box3PopOut4Choice"..i]:SetParent(vcbOptions1Box3PopOut4Choice0)
	_G["vcbOptions1Box3PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box3PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions1Box3PopOut4.Text:SetText(self:GetText())
			vcbOptions1Box3PopOut4Choice0:Hide()
		end
	end)
end
-- Box 4 Total Cast Time --
-- pop out 1 Total Cast Time --
-- enter --
vcbOptions1Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nTotal Cast Time to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box4PopOut1Choice"..i]:SetParent(vcbOptions1Box4PopOut1Choice0)
	_G["vcbOptions1Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box4PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- sort & clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box4PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box4PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box4PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Total Cast Time Sec? --
-- enter --
vcbOptions1Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- naming --
vcbOptions1Box4PopOut2Choice0.Text:SetText("Show")
vcbOptions1Box4PopOut2Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions1Box4PopOut2Choice1:SetParent(vcbOptions1Box4PopOut2Choice0)
vcbOptions1Box4PopOut2Choice1:SetPoint("TOP",vcbOptions1Box4PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box4PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions1Box4PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box4PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Total Time Decimals --
-- enter --
vcbOptions1Box4PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- naming --
vcbOptions1Box4PopOut3Choice0.Text:SetText("0")
vcbOptions1Box4PopOut3Choice1.Text:SetText("1")
vcbOptions1Box4PopOut3Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box4PopOut3Choice"..i]:SetParent(vcbOptions1Box4PopOut3Choice0)
	_G["vcbOptions1Box4PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box4PopOut3Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box4PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions1Box4PopOut3.Text:SetText(self:GetText())
			vcbOptions1Box4PopOut3Choice0:Hide()
		end
	end)
end
-- Box 5 Lag Bar & Castbar's Color --
-- pop out 1 Lag Bar --
-- enter --
vcbOptions1Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nLatency's Bar to be shown?") 
end)
-- naming --
vcbOptions1Box5PopOut1Choice0.Text:SetText("Show")
vcbOptions1Box5PopOut1Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions1Box5PopOut1Choice1:SetParent(vcbOptions1Box5PopOut1Choice0)
vcbOptions1Box5PopOut1Choice1:SetPoint("TOP",vcbOptions1Box5PopOut1Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["LagBar"] = self.Text:GetText()
			vcbOptions1Box5PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box5PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Queue Bar --
-- enter --
vcbOptions1Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nQueue Window Bar to be shown?") 
end)
-- naming --
vcbOptions1Box5PopOut2Choice0.Text:SetText("Show")
vcbOptions1Box5PopOut2Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions1Box5PopOut2Choice1:SetParent(vcbOptions1Box5PopOut2Choice0)
vcbOptions1Box5PopOut2Choice1:SetPoint("TOP",vcbOptions1Box5PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box5PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["QueueBar"] = self.Text:GetText()
			vcbOptions1Box5PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box5PopOut2Choice0:Hide()
		end
	end)
end
-- Options Box 6 Ticks of the Spells & GCD --
-- pop out 1 Ticks of the Spells --
-- enter --
vcbOptions1Box6PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nTicks of the Spell to be shown?") 
end)
-- naming --
vcbOptions1Box6PopOut1Choice0.Text:SetText("Show")
vcbOptions1Box6PopOut1Choice1.Text:SetText("Hide")
-- parent & sort --
for i = 1, 1, 1 do
	_G["vcbOptions1Box6PopOut1Choice"..i]:SetParent(vcbOptions1Box6PopOut1Choice0)
	_G["vcbOptions1Box6PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box6PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box6PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Ticks"] = self.Text:GetText()
			vcbOptions1Box6PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box6PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Global Cooldown --
-- enter --
vcbOptions1Box6PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nGlobal Cooldown to be shown?") 
end)
-- naming --
vcbOptions1Box6PopOut2Choice0.Text:SetText("Hide")
vcbOptions1Box6PopOut2Choice1.Text:SetText("Class Icon")
vcbOptions1Box6PopOut2Choice2.Text:SetText("Hero Icon")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box6PopOut2Choice"..i]:SetParent(vcbOptions1Box6PopOut2Choice0)
	_G["vcbOptions1Box6PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box6PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box6PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["GCD"]["ClassicTexture"] = self.Text:GetText()
			vcbOptions1Box6PopOut2.Text:SetText(self:GetText())
			vcbOptions1Box6PopOut2Choice0:Hide()
			vcbCreatingTheGCD()
		end
	end)
end
-- Box 7 Castbar's Color --
-- pop out 1 Castbar's Color --
-- enter --
vcbOptions1Box7PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhat color do you want the|nCastbar to be?") 
end)
-- naming --
vcbOptions1Box7PopOut1Choice0.Text:SetText("Default Color")
vcbOptions1Box7PopOut1Choice1.Text:SetText("Class' Color")
vcbOptions1Box7PopOut1Choice2.Text:SetText("Spell School Color")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box7PopOut1Choice"..i]:SetParent(vcbOptions1Box7PopOut1Choice0)
	_G["vcbOptions1Box7PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box7PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box7PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Color"] = self.Text:GetText()
			vcbOptions1Box7PopOut1.Text:SetText(self:GetText())
			vcbOptions1Box7PopOut1Choice0:Hide()
		end
	end)
end
-- naming button choices for spell's name, current cast time, current & total time, and total time --
for i = 1, 4, 1 do
	if i == 1 then
		_G["vcbOptions1Box"..i.."PopOut2Choice0"].Text:SetText("Hide")
		_G["vcbOptions1Box"..i.."PopOut2Choice1"].Text:SetText("Top Left")
		_G["vcbOptions1Box"..i.."PopOut2Choice2"].Text:SetText("Left")
		_G["vcbOptions1Box"..i.."PopOut2Choice3"].Text:SetText("Bottom Left")
		_G["vcbOptions1Box"..i.."PopOut2Choice4"].Text:SetText("Top")
		_G["vcbOptions1Box"..i.."PopOut2Choice5"].Text:SetText("Center")
		_G["vcbOptions1Box"..i.."PopOut2Choice6"].Text:SetText("Bottom")
		_G["vcbOptions1Box"..i.."PopOut2Choice7"].Text:SetText("Top Right")
		_G["vcbOptions1Box"..i.."PopOut2Choice8"].Text:SetText("Right")
		_G["vcbOptions1Box"..i.."PopOut2Choice9"].Text:SetText("Bottom Right")
	else
		_G["vcbOptions1Box"..i.."PopOut1Choice0"].Text:SetText("Hide")
		_G["vcbOptions1Box"..i.."PopOut1Choice1"].Text:SetText("Top Left")
		_G["vcbOptions1Box"..i.."PopOut1Choice2"].Text:SetText("Left")
		_G["vcbOptions1Box"..i.."PopOut1Choice3"].Text:SetText("Bottom Left")
		_G["vcbOptions1Box"..i.."PopOut1Choice4"].Text:SetText("Top")
		_G["vcbOptions1Box"..i.."PopOut1Choice5"].Text:SetText("Center")
		_G["vcbOptions1Box"..i.."PopOut1Choice6"].Text:SetText("Bottom")
		_G["vcbOptions1Box"..i.."PopOut1Choice7"].Text:SetText("Top Right")
		_G["vcbOptions1Box"..i.."PopOut1Choice8"].Text:SetText("Right")
		_G["vcbOptions1Box"..i.."PopOut1Choice9"].Text:SetText("Bottom Right")
	end
end
-- Showing the panel --
vcbOptions1:HookScript("OnShow", function(self)
	CheckSavedVariables()
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbMainColor:GetRGB())
end)
