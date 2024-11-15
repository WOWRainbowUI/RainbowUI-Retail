-- taking care of the panel --
vcbOptions4.TopTxt:SetText("Boss' Castbar Options!")
-- naming the boxes --
vcbOptions4Box0.TitleTxt:SetText("Read me please!")
vcbOptions4Box1.TitleTxt:SetText("Position & Scale")
vcbOptions4Box2.TitleTxt:SetText("Current Cast Time")
vcbOptions4Box3.TitleTxt:SetText("Current & Total Cast Time")
vcbOptions4Box4.TitleTxt:SetText("Total Cast Time")
vcbOptions4Box5.TitleTxt:SetText("Spell's Name & Cast Bar's Color")
-- positioning the boxes --
vcbOptions4Box1:SetPoint("TOPLEFT", vcbOptions4Box0, "BOTTOMLEFT", 0, 0)
vcbOptions4Box2:SetPoint("TOPRIGHT", vcbOptions4Box0, "BOTTOMRIGHT", 0, 0)
vcbOptions4Box3:SetPoint("TOPLEFT", vcbOptions4Box1, "BOTTOMLEFT", 0, 0)
vcbOptions4Box4:SetPoint("TOPRIGHT", vcbOptions4Box2, "BOTTOMRIGHT", 0, 0)
vcbOptions4Box5:SetPoint("TOP", vcbOptions4Box4, "BOTTOM", 0, 0)
-- fuction for Available --
local function vcbAvailable()
	vcbOptions4Box1CheckButton1:SetChecked(true)
	vcbOptions4Box1CheckButton1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions4Box1Slider1.Slider:EnableMouse(true)
	vcbOptions4Box1Slider1.Back:EnableMouse(true)
	vcbOptions4Box1Slider1.Forward:EnableMouse(true)
	vcbOptions4Box1Slider1:SetAlpha(1)
	vcbOptions4Box1PopOut1:EnableMouse(true)
	vcbOptions4Box1PopOut1:SetAlpha(1)
end
-- function for Disable --
local function vcbDisable()
	vcbOptions4Box1CheckButton1:SetChecked(false)
	vcbOptions4Box1CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
	vcbOptions4Box1Slider1.Slider:EnableMouse(false)
	vcbOptions4Box1Slider1.Back:EnableMouse(false)
	vcbOptions4Box1Slider1.Forward:EnableMouse(false)
	vcbOptions4Box1Slider1:SetAlpha(0.35)
	vcbOptions4Box1PopOut1:EnableMouse(false)
	vcbOptions4Box1PopOut1:SetAlpha(0.35)
	for i = 1, 5, 1 do
		_G["Boss"..i.."TargetFrame"]:Hide()
		_G["vcbPreviewBoss"..i]:Hide()
	end
end
-- Checking the Saved Variables --
local function CheckSavedVariables()
	if not VCBrBoss["Unlock"] and VCBrBoss["otherAdddon"] == "None" then
		vcbDisable()
	elseif VCBrBoss["Unlock"] and VCBrBoss["otherAdddon"] == "None" then
		vcbAvailable()
		for i = 1, 5, 1 do
			_G["Boss"..i.."TargetFrame"]:Show()
			_G["vcbPreviewBoss"..i]:Show()
		end
	elseif VCBrBoss["Unlock"] and VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then
		vcbAvailable()
		for i = 1, 5, 1 do
			_G["SUFHeaderbossUnitButton"..i]:Show()
			_G["vcbPreviewBoss"..i]:Show()
		end
	end
	vcbOptions4Box1Slider1:SetValue(VCBrBoss["Scale"])
	for i = 1, 5, 1 do
		_G["vcbPreviewBoss"..i]:SetScale(VCBrBoss["Scale"]/100)
	end
	vcbOptions4Box1PopOut1.Text:SetText(VCBrBoss["otherAdddon"])
	vcbOptions4Box2PopOut1:SetText(VCBrBoss["CurrentTimeText"]["Position"])
	vcbOptions4Box2PopOut2:SetText(VCBrBoss["CurrentTimeText"]["Direction"])
	vcbOptions4Box2PopOut3:SetText(VCBrBoss["CurrentTimeText"]["Sec"])
	vcbOptions4Box2PopOut4:SetText(VCBrBoss["CurrentTimeText"]["Decimals"])
	vcbOptions4Box3PopOut1:SetText(VCBrBoss["BothTimeText"]["Position"])
	vcbOptions4Box3PopOut2:SetText(VCBrBoss["BothTimeText"]["Direction"])
	vcbOptions4Box3PopOut3:SetText(VCBrBoss["BothTimeText"]["Sec"])
	vcbOptions4Box3PopOut4:SetText(VCBrBoss["BothTimeText"]["Decimals"])
	vcbOptions4Box4PopOut1:SetText(VCBrBoss["TotalTimeText"]["Position"])
	vcbOptions4Box4PopOut2:SetText(VCBrBoss["TotalTimeText"]["Sec"])
	vcbOptions4Box4PopOut3:SetText(VCBrBoss["TotalTimeText"]["Decimals"])
	vcbOptions4Box5PopOut1:SetText(VCBrBoss["NameText"])
	vcbOptions4Box5PopOut2:SetText(VCBrBoss["Color"])
end
-- taking care of the target preview --
vcbPreviewBoss1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nLeft click and drag to move me!") 
end)
vcbPreviewBoss1:SetScript("OnLeave", vcbLeavingMenus)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBrBoss["Position"]["X"] = Round(self:GetLeft())
	VCBrBoss["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the target preview --
vcbPreviewBoss1:RegisterForDrag("LeftButton")
vcbPreviewBoss1:SetScript("OnDragStart", vcbPreviewBoss1.StartMoving)
vcbPreviewBoss1:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the target preview --
vcbPreviewBoss1:SetScript("OnHide", function(self)
	VCBrBoss["Position"]["X"] = Round(self:GetLeft())
	VCBrBoss["Position"]["Y"] = Round(self:GetBottom())
end)
-- Mouse Wheel on Sliders --
local function MouseWheelSlider(self, delta)
	if delta == 1 then
		PlaySound(858, "Master")
		self:SetValue(self:GetValue() + 1)
	elseif delta == -1 then
		PlaySound(858, "Master")
		self:SetValue(self:GetValue() - 1)
	end
end
-- Box 0 Read me! --
vcbOptions4Box0.CenterText:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 1: ").."Please close all other panels and keep this panel open!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 2: ").."When you dock or undock the cast bars, the game will be reloaded!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 3: ").."When you choose from the pop out the Shadowed Unit Frame (SUF), the game will be reloaded!")
-- Box 1 --
-- check button 1 do it --
vcbOptions4Box1CheckButton1.Text:SetText("Undock")
vcbOptions4Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nCheck me! if you want to undock|nthe focus' cast bar!") 
end)
vcbOptions4Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions4Box1CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBrBoss["Unlock"] = true
			vcbAvailable()
			C_UI.Reload()
		elseif self:GetChecked() == false then
			VCBrBoss["Unlock"] = false
			vcbDisable()
			if VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then VCBrBoss["otherAdddon"] = "None" end
			C_UI.Reload()
		end
	end
end)
-- slider 1 --
vcbOptions4Box1Slider1.MinText:SetText(0.10)
vcbOptions4Box1Slider1.MaxText:SetText(2)
vcbOptions4Box1Slider1.Slider:SetMinMaxValues(10, 200)
-- slider 1 do it --
vcbOptions4Box1Slider1.Slider:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nYou can also use your mousewheel|nor the buttons to the edge|nto change the value!") 
end)
vcbOptions4Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions4Box1Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- On Value Changed --
vcbOptions4Box1Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions4Box1Slider1.TopText:SetText("Boss' Castbar Scale: "..(self:GetValue()/100))
	VCBrBoss["Scale"] = self:GetValue()
	for i = 1, 5, 1 do
		_G["vcbPreviewBoss"..i]:SetScale(VCBrBoss["Scale"]/100)
	end
end)
-- Popout 1, entering, leaving, click --
vcbOptions4Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you have any add on|nfor the Unit Frames?") 
end)
vcbOptions4Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions4Box1PopOut1, vcbOptions4Box1PopOut1Choice0)
-- sort & clicking --
vcbOptions4Box1PopOut1Choice1:SetParent(vcbOptions4Box1PopOut1Choice0)
vcbOptions4Box1PopOut1Choice1:SetPoint("TOP",vcbOptions4Box1PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions4Box1PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then
			VCBrBoss["otherAdddon"] = self.Text:GetText()
			C_UI.Reload()
		else
			VCBrBoss["otherAdddon"] = self.Text:GetText()
		end
		vcbOptions4Box1PopOut1.Text:SetText(self:GetText())
		vcbOptions4Box1PopOut1Choice0:Hide()
	end
end)
vcbOptions4Box1PopOut1Choice1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
		if finished then
			VCBrBoss["otherAdddon"] = self.Text:GetText()
			vcbOptions4Box1PopOut1.Text:SetText(self:GetText())
			vcbOptions4Box1PopOut1Choice0:Hide()
			C_UI.Reload()
		else
			local vcbTime = GameTime_GetTime(false)
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] You don't use the Shadowed Unit Frame add on, you don't need to choose that option!")
		end
	end
end)
-- naming --
vcbOptions4Box1PopOut1Choice0.Text:SetText("None")
vcbOptions4Box1PopOut1Choice1.Text:SetText("Shadowed Unit Frame")
-- enter choice 1 --
vcbOptions4Box1PopOut1Choice1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nFor people who uses SUF!|nFrom SUF options UNCHECK the option|nHide Blizzard - Hide focus frames!|nPlease restart your game client after this action!|nAnd then choose the 'Shadow Unit Frame'!") 
end)
-- leave choice 1 --
vcbOptions4Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions4Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent Cast Time to be shown?") 
end)
-- leave --
vcbOptions4Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box2PopOut1, vcbOptions4Box2PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions4Box2PopOut1Choice"..i]:SetParent(vcbOptions4Box2PopOut1Choice0)
	_G["vcbOptions4Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box2PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions4Box2PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions4Box2PopOut1.Text:SetText(self:GetText())
			vcbOptions4Box2PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current Cast Time Direction --
-- enter --
vcbOptions4Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- leave --
vcbOptions4Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box2PopOut2, vcbOptions4Box2PopOut2Choice0)
-- naming --
vcbOptions4Box2PopOut2Choice0.Text:SetText("Ascending")
vcbOptions4Box2PopOut2Choice1.Text:SetText("Descending")
vcbOptions4Box2PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions4Box2PopOut2Choice"..i]:SetParent(vcbOptions4Box2PopOut2Choice0)
	_G["vcbOptions4Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box2PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions4Box2PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions4Box2PopOut2.Text:SetText(self:GetText())
			vcbOptions4Box2PopOut2Choice0:Hide()
		end
	end)
end
--  pop out 3 Current Cast Time Sec? --
-- enter --
vcbOptions4Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions4Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box2PopOut3, vcbOptions4Box2PopOut3Choice0)
-- naming --
vcbOptions4Box2PopOut3Choice0.Text:SetText("Show")
vcbOptions4Box2PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions4Box2PopOut3Choice1:SetParent(vcbOptions4Box2PopOut3Choice0)
vcbOptions4Box2PopOut3Choice1:SetPoint("TOP",vcbOptions4Box2PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions4Box2PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["CurrentTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions4Box2PopOut3.Text:SetText(self:GetText())
			vcbOptions4Box2PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Current Cast Time Decimals --
-- enter --
vcbOptions4Box2PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- leave --
vcbOptions4Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box2PopOut4, vcbOptions4Box2PopOut4Choice0)
-- naming --
vcbOptions4Box2PopOut4Choice0.Text:SetText("0")
vcbOptions4Box2PopOut4Choice1.Text:SetText("1")
vcbOptions4Box2PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions4Box2PopOut4Choice"..i]:SetParent(vcbOptions4Box2PopOut4Choice0)
	_G["vcbOptions4Box2PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box2PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions4Box2PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["CurrentTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions4Box2PopOut4.Text:SetText(self:GetText())
			vcbOptions4Box2PopOut4Choice0:Hide()
		end
	end)
end
-- Box 3 Current & Total Cast Time --
-- pop out 1 Current & Total Cast Time --
-- enter --
vcbOptions4Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent/Total Cast Time to be shown?") 
end)
-- leave --
vcbOptions4Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box3PopOut1, vcbOptions4Box3PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions4Box3PopOut1Choice"..i]:SetParent(vcbOptions4Box3PopOut1Choice0)
	_G["vcbOptions4Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box3PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions4Box3PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions4Box3PopOut1.Text:SetText(self:GetText())
			vcbOptions4Box3PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current & Total Cast Time Direction --
-- enter --
vcbOptions4Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- leave --
vcbOptions4Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box3PopOut2, vcbOptions4Box3PopOut2Choice0)
-- naming --
vcbOptions4Box3PopOut2Choice0.Text:SetText("Ascending")
vcbOptions4Box3PopOut2Choice1.Text:SetText("Descending")
vcbOptions4Box3PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions4Box3PopOut2Choice"..i]:SetParent(vcbOptions4Box3PopOut2Choice0)
	_G["vcbOptions4Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box3PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions4Box3PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions4Box3PopOut2.Text:SetText(self:GetText())
			vcbOptions4Box3PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Current & Total Cast Time Sec? --
-- enter --
vcbOptions4Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions4Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box3PopOut3, vcbOptions4Box3PopOut3Choice0)
-- naming --
vcbOptions4Box3PopOut3Choice0.Text:SetText("Show")
vcbOptions4Box3PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions4Box3PopOut3Choice1:SetParent(vcbOptions4Box3PopOut3Choice0)
vcbOptions4Box3PopOut3Choice1:SetPoint("TOP",vcbOptions4Box3PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions4Box3PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["BothTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions4Box3PopOut3.Text:SetText(self:GetText())
			vcbOptions4Box3PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Both Time Decimals --
-- enter --
vcbOptions4Box3PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- leave --
vcbOptions4Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box3PopOut4, vcbOptions4Box3PopOut4Choice0)
-- naming --
vcbOptions4Box3PopOut4Choice0.Text:SetText("0")
vcbOptions4Box3PopOut4Choice1.Text:SetText("1")
vcbOptions4Box3PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions4Box3PopOut4Choice"..i]:SetParent(vcbOptions4Box3PopOut4Choice0)
	_G["vcbOptions4Box3PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box3PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions4Box3PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["BothTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions4Box3PopOut4.Text:SetText(self:GetText())
			vcbOptions4Box3PopOut4Choice0:Hide()
		end
	end)
end
-- Box 4 Total Cast Time --
-- pop out 1 Total Cast Time --
-- enter --
vcbOptions4Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nTotal Cast Time to be shown?") 
end)
-- leave --
vcbOptions4Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box4PopOut1, vcbOptions4Box4PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions4Box4PopOut1Choice"..i]:SetParent(vcbOptions4Box4PopOut1Choice0)
	_G["vcbOptions4Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box4PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- sort & clicking --
for i = 0, 9, 1 do
	_G["vcbOptions4Box4PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions4Box4PopOut1.Text:SetText(self:GetText())
			vcbOptions4Box4PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Total Cast Time Sec? --
-- enter --
vcbOptions4Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions4Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box4PopOut2, vcbOptions4Box4PopOut2Choice0)
-- naming --
vcbOptions4Box4PopOut2Choice0.Text:SetText("Show")
vcbOptions4Box4PopOut2Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions4Box4PopOut2Choice1:SetParent(vcbOptions4Box4PopOut2Choice0)
vcbOptions4Box4PopOut2Choice1:SetPoint("TOP",vcbOptions4Box4PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions4Box4PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["TotalTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions4Box4PopOut2.Text:SetText(self:GetText())
			vcbOptions4Box4PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Total Time Decimals --
-- enter --
vcbOptions4Box4PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- leave --
vcbOptions4Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box4PopOut3, vcbOptions4Box4PopOut3Choice0)
-- naming --
vcbOptions4Box4PopOut3Choice0.Text:SetText("0")
vcbOptions4Box4PopOut3Choice1.Text:SetText("1")
vcbOptions4Box4PopOut3Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions4Box4PopOut3Choice"..i]:SetParent(vcbOptions4Box4PopOut3Choice0)
	_G["vcbOptions4Box4PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box4PopOut3Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions4Box4PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["TotalTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions4Box4PopOut3.Text:SetText(self:GetText())
			vcbOptions4Box4PopOut3Choice0:Hide()
		end
	end)
end
-- Box 5 Spell's Name & Castbar's Color --
-- pop out 1 Spell's Name --
-- enter --
vcbOptions4Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nLatency's Bar to be shown?") 
end)
-- leave --
vcbOptions4Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box5PopOut1, vcbOptions4Box5PopOut1Choice0)
-- parent & sort --
vcbOptions4Box5PopOut1Choice1:SetParent(vcbOptions4Box5PopOut1Choice0)
vcbOptions4Box5PopOut1Choice1:SetPoint("TOP",vcbOptions4Box5PopOut1Choice0, "BOTTOM", 0, 0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions4Box5PopOut1Choice"..i]:SetParent(vcbOptions4Box5PopOut1Choice0)
	_G["vcbOptions4Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions4Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["NameText"] = self.Text:GetText()
			vcbOptions4Box5PopOut1.Text:SetText(self:GetText())
			vcbOptions4Box5PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Castbar's Color --
-- enter --
vcbOptions4Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhat color do you want the|nCastbar to be?") 
end)
-- leave --
vcbOptions4Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions4Box5PopOut2, vcbOptions4Box5PopOut2Choice0)
-- naming --
vcbOptions4Box5PopOut2Choice0.Text:SetText("Default Color")
vcbOptions4Box5PopOut2Choice1.Text:SetText("Class' Color")
-- parent & sort --
for i = 1, 1, 1 do
	_G["vcbOptions4Box5PopOut2Choice"..i]:SetParent(vcbOptions4Box5PopOut2Choice0)
	_G["vcbOptions4Box5PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions4Box5PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions4Box5PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrBoss["Color"] = self.Text:GetText()
			vcbOptions4Box5PopOut2.Text:SetText(self:GetText())
			vcbOptions4Box5PopOut2Choice0:Hide()
		end
	end)
end
-- naming button choices for spell's name, current cast time, current & total time, and total time --
for i = 2, 5, 1 do
	_G["vcbOptions4Box"..i.."PopOut1Choice0"].Text:SetText("Hide")
	_G["vcbOptions4Box"..i.."PopOut1Choice1"].Text:SetText("Top Left")
	_G["vcbOptions4Box"..i.."PopOut1Choice2"].Text:SetText("Left")
	_G["vcbOptions4Box"..i.."PopOut1Choice3"].Text:SetText("Bottom Left")
	_G["vcbOptions4Box"..i.."PopOut1Choice4"].Text:SetText("Top")
	_G["vcbOptions4Box"..i.."PopOut1Choice5"].Text:SetText("Center")
	_G["vcbOptions4Box"..i.."PopOut1Choice6"].Text:SetText("Bottom")
	_G["vcbOptions4Box"..i.."PopOut1Choice7"].Text:SetText("Top Right")
	_G["vcbOptions4Box"..i.."PopOut1Choice8"].Text:SetText("Right")
	_G["vcbOptions4Box"..i.."PopOut1Choice9"].Text:SetText("Bottom Right")
end
local function PreviewShow()
	for i = 2, 5, 1 do
		_G["vcbPreviewBoss"..i]:ClearAllPoints()
		_G["vcbPreviewBoss"..i]:SetPoint("TOP", _G["vcbPreviewBoss"..i-1], "BOTTOM", 0, -32)
	end
end
local function PreviewHide()
	for i = 1, 5, 1 do
		if VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then _G["SUFHeaderbossUnitButton"..i]:Hide() end
		_G["Boss"..i.."TargetFrame"]:Hide()
		_G["vcbPreviewBoss"..i]:Hide()
	end
end
-- Showing the panel --
vcbOptions4:HookScript("OnShow", function(self)
	CheckSavedVariables()
	vcbPreviewBoss1:SetIgnoreParentAlpha(true)
	vcbPreviewBoss1:SetAlpha(1)
	vcbPreviewBoss1:ClearAllPoints()
	if VCBrBoss["Position"]["X"] == 0 and VCBrBoss["Position"]["Y"] == 0 then
		vcbPreviewBoss1:SetPoint("TOPRIGHT", self, "TOPLEFT", -32, -32)
	else vcbPreviewBoss1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrBoss["Position"]["X"], VCBrBoss["Position"]["Y"])
	end
	PreviewShow()
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions5:IsShown() then vcbOptions5:Hide() end
	if vcbOptions6:IsShown() then vcbOptions6:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab5.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab6.Text:SetTextColor(vcbMainColor:GetRGB())
end)
-- Hiding the panel --
vcbOptions4:SetScript("OnHide", function(self)
	PreviewHide()
end)
