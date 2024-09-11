-- taking care of the panel --
vcbOptions3.TopTxt:SetText("Focus' Castbar Options!|n|nPLEASE CLOSE ALL OTHER PANELS|nKEEP THIS PANEL OPEN|nAND TAKE A FOCUS!")
-- naming the boxes --
vcbOptions3Box1.TitleTxt:SetText("Position & Scale of the Focus' Castbar!")
vcbOptions3Box2.TitleTxt:SetText("Current Cast Time")
vcbOptions3Box3.TitleTxt:SetText("Current & Total Cast Time")
vcbOptions3Box4.TitleTxt:SetText("Total Cast Time")
vcbOptions3Box5.TitleTxt:SetText("Spell's Name & Cast Bar's Color")
-- positioning the boxes --
for i = 2, 5, 1 do
	_G["vcbOptions3Box"..i]:SetPoint("TOP", _G["vcbOptions3Box"..i-1], "BOTTOM", 0, 0)
end
-- fuction for Available --
local function vcbAvailable()
	vcbOptions3Box1CheckButton1:SetChecked(true)
	vcbOptions3Box1CheckButton1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions3Box1Slider1.Slider:EnableMouse(true)
	vcbOptions3Box1Slider1.Back:EnableMouse(true)
	vcbOptions3Box1Slider1.Forward:EnableMouse(true)
	vcbOptions3Box1Slider1:SetAlpha(1)
	vcbOptions3Box1PopOut1:EnableMouse(true)
	vcbOptions3Box1PopOut1:SetAlpha(1)
	FocusFrame.CBpreview:Show()
end
-- function for Disable --
local function vcbDisable()
	vcbOptions3Box1CheckButton1:SetChecked(false)
	vcbOptions3Box1CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
	vcbOptions3Box1Slider1.Slider:EnableMouse(false)
	vcbOptions3Box1Slider1.Back:EnableMouse(false)
	vcbOptions3Box1Slider1.Forward:EnableMouse(false)
	vcbOptions3Box1Slider1:SetAlpha(0.35)
	vcbOptions3Box1PopOut1:EnableMouse(false)
	vcbOptions3Box1PopOut1:SetAlpha(0.35)
	FocusFrame.CBpreview:Hide()
end
-- Checking the Saved Variables --
local function CheckSavedVariables()
	if not VCBrFocus["Unlock"] then
		vcbDisable()
	elseif VCBrFocus["Unlock"] then
		vcbAvailable()
	end
	vcbOptions3Box1Slider1:SetValue(VCBrFocus["Scale"])
	FocusFrame.CBpreview:SetScale(VCBrFocus["Scale"]/100)
	vcbOptions3Box1PopOut1.Text:SetText(VCBrFocus["otherAdddon"])
	vcbOptions3Box1PopOut1.Text:SetText(VCBrFocus["otherAdddon"])
	vcbOptions3Box2PopOut1:SetText(VCBrFocus["CurrentTimeText"]["Position"])
	vcbOptions3Box2PopOut2:SetText(VCBrFocus["CurrentTimeText"]["Direction"])
	vcbOptions3Box2PopOut3:SetText(VCBrFocus["CurrentTimeText"]["Sec"])
	vcbOptions3Box3PopOut1:SetText(VCBrFocus["BothTimeText"]["Position"])
	vcbOptions3Box3PopOut2:SetText(VCBrFocus["BothTimeText"]["Direction"])
	vcbOptions3Box3PopOut3:SetText(VCBrFocus["BothTimeText"]["Sec"])
	vcbOptions3Box4PopOut1:SetText(VCBrFocus["TotalTimeText"]["Position"])
	vcbOptions3Box4PopOut2:SetText(VCBrFocus["TotalTimeText"]["Sec"])
	vcbOptions3Box5PopOut1:SetText(VCBrFocus["NameText"])
	vcbOptions3Box5PopOut2:SetText(VCBrFocus["Color"])
end
-- taking care of the target preview --
FocusFrame.CBpreview:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nLeft click and drag to move me!") 
end)
FocusFrame.CBpreview:SetScript("OnLeave", vcbLeavingMenus)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBrFocus["Position"]["X"] = Round(self:GetLeft())
	VCBrFocus["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the target preview --
FocusFrame.CBpreview:RegisterForDrag("LeftButton")
FocusFrame.CBpreview:SetScript("OnDragStart", FocusFrame.CBpreview.StartMoving)
FocusFrame.CBpreview:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the target preview --
FocusFrame.CBpreview:SetScript("OnHide", function(self)
	VCBrFocus["Position"]["X"] = Round(self:GetLeft())
	VCBrFocus["Position"]["Y"] = Round(self:GetBottom())
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
-- Box 1 --
-- check button 1 do it --
vcbOptions3Box1CheckButton1.Text:SetText("Unlock")
vcbOptions3Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nCheck me! if you want to unlock|nthe focus' cast bar!") 
end)
vcbOptions3Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions3Box1CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBrFocus["Unlock"] = true
			vcbAvailable()
		elseif self:GetChecked() == false then
			VCBrFocus["Unlock"] = false
			vcbDisable()
		end
	end
end)
-- slider 1 --
vcbOptions3Box1Slider1.MinText:SetText(0.10)
vcbOptions3Box1Slider1.MaxText:SetText(2)
vcbOptions3Box1Slider1.Slider:SetMinMaxValues(10, 200)
-- slider 1 do it --
vcbOptions3Box1Slider1.Slider:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nYou can also use your mousewheel|nor the buttons to the edge|nto change the value!") 
end)
vcbOptions3Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions3Box1Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- On Value Changed --
vcbOptions3Box1Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions3Box1Slider1.TopText:SetText("Focus' Castbar Scale: "..(self:GetValue()/100))
	VCBrFocus["Scale"] = self:GetValue()
	FocusFrame.CBpreview:SetScale(VCBrFocus["Scale"]/100)
end)
-- Popout 1, entering, leaving, click --
vcbOptions3Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you have any add on|nfor the Unit Frames?") 
end)
vcbOptions3Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions3Box1PopOut1, vcbOptions3Box1PopOut1Choice0)
-- sort & clicking --
vcbOptions3Box1PopOut1Choice1:SetParent(vcbOptions3Box1PopOut1Choice0)
vcbOptions3Box1PopOut1Choice1:SetPoint("TOP",vcbOptions3Box1PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions3Box1PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrFocus["otherAdddon"] = self.Text:GetText()
		vcbOptions3Box1PopOut1.Text:SetText(self:GetText())
		vcbOptions3Box1PopOut1Choice0:Hide()
	end
end)
vcbOptions3Box1PopOut1Choice1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
		if finished then
			VCBrFocus["otherAdddon"] = self.Text:GetText()
			vcbOptions3Box1PopOut1.Text:SetText(self:GetText())
			vcbOptions3Box1PopOut1Choice0:Hide()
		else
			local vcbTime = GameTime_GetTime(false)
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] You don't use the Shadowed Unit Frame add on, you don't need to choose that option!")
		end
	end
end)
-- naming --
vcbOptions3Box1PopOut1Choice0.Text:SetText("None")
vcbOptions3Box1PopOut1Choice1.Text:SetText("Shadowed Unit Frame")
-- enter choice 1 --
vcbOptions3Box1PopOut1Choice1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nFor people who uses SUF!|nFrom SUF options UNCHECK the option|nHide Blizzard - Hide focus frames!|nPlease restart your game client after this action!|nAnd then choose the 'Shadow Unit Frame'!") 
end)
-- leave choice 1 --
vcbOptions3Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions3Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent Cast Time to be shown?") 
end)
-- leave --
vcbOptions3Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box2PopOut1, vcbOptions3Box2PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions3Box2PopOut1Choice"..i]:SetParent(vcbOptions3Box2PopOut1Choice0)
	_G["vcbOptions3Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box2PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions3Box2PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions3Box2PopOut1.Text:SetText(self:GetText())
			vcbOptions3Box2PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current Cast Time Direction --
-- enter --
vcbOptions3Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- leave --
vcbOptions3Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box2PopOut2, vcbOptions3Box2PopOut2Choice0)
-- naming --
vcbOptions3Box2PopOut2Choice0.Text:SetText("Ascending")
vcbOptions3Box2PopOut2Choice1.Text:SetText("Descending")
vcbOptions3Box2PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions3Box2PopOut2Choice"..i]:SetParent(vcbOptions3Box2PopOut2Choice0)
	_G["vcbOptions3Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box2PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions3Box2PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions3Box2PopOut2.Text:SetText(self:GetText())
			vcbOptions3Box2PopOut2Choice0:Hide()
		end
	end)
end
--  pop out 3 Current Cast Time Sec? --
-- enter --
vcbOptions3Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions3Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box2PopOut3, vcbOptions3Box2PopOut3Choice0)
-- naming --
vcbOptions3Box2PopOut3Choice0.Text:SetText("Show")
vcbOptions3Box2PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions3Box2PopOut3Choice1:SetParent(vcbOptions3Box2PopOut3Choice0)
vcbOptions3Box2PopOut3Choice1:SetPoint("TOP",vcbOptions3Box2PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions3Box2PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["CurrentTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions3Box2PopOut3.Text:SetText(self:GetText())
			vcbOptions3Box2PopOut3Choice0:Hide()
		end
	end)
end
-- Box 3 Current & Total Cast Time --
-- pop out 1 Current & Total Cast Time --
-- enter --
vcbOptions3Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent/Total Cast Time to be shown?") 
end)
-- leave --
vcbOptions3Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box3PopOut1, vcbOptions3Box3PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions3Box3PopOut1Choice"..i]:SetParent(vcbOptions3Box3PopOut1Choice0)
	_G["vcbOptions3Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box3PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions3Box3PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions3Box3PopOut1.Text:SetText(self:GetText())
			vcbOptions3Box3PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current & Total Cast Time Direction --
-- enter --
vcbOptions3Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- leave --
vcbOptions3Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box3PopOut2, vcbOptions3Box3PopOut2Choice0)
-- naming --
vcbOptions3Box3PopOut2Choice0.Text:SetText("Ascending")
vcbOptions3Box3PopOut2Choice1.Text:SetText("Descending")
vcbOptions3Box3PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions3Box3PopOut2Choice"..i]:SetParent(vcbOptions3Box3PopOut2Choice0)
	_G["vcbOptions3Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box3PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions3Box3PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions3Box3PopOut2.Text:SetText(self:GetText())
			vcbOptions3Box3PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Current & Total Cast Time Sec? --
-- enter --
vcbOptions3Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions3Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box3PopOut3, vcbOptions3Box3PopOut3Choice0)
-- naming --
vcbOptions3Box3PopOut3Choice0.Text:SetText("Show")
vcbOptions3Box3PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions3Box3PopOut3Choice1:SetParent(vcbOptions3Box3PopOut3Choice0)
vcbOptions3Box3PopOut3Choice1:SetPoint("TOP",vcbOptions3Box3PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions3Box3PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["BothTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions3Box3PopOut3.Text:SetText(self:GetText())
			vcbOptions3Box3PopOut3Choice0:Hide()
		end
	end)
end
-- Box 4 Total Cast Time --
-- pop out 1 Total Cast Time --
-- enter --
vcbOptions3Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nTotal Cast Time to be shown?") 
end)
-- leave --
vcbOptions3Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box4PopOut1, vcbOptions3Box4PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions3Box4PopOut1Choice"..i]:SetParent(vcbOptions3Box4PopOut1Choice0)
	_G["vcbOptions3Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box4PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- sort & clicking --
for i = 0, 9, 1 do
	_G["vcbOptions3Box4PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions3Box4PopOut1.Text:SetText(self:GetText())
			vcbOptions3Box4PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Total Cast Time Sec? --
-- enter --
vcbOptions3Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions3Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box4PopOut2, vcbOptions3Box4PopOut2Choice0)
-- naming --
vcbOptions3Box4PopOut2Choice0.Text:SetText("Show")
vcbOptions3Box4PopOut2Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions3Box4PopOut2Choice1:SetParent(vcbOptions3Box4PopOut2Choice0)
vcbOptions3Box4PopOut2Choice1:SetPoint("TOP",vcbOptions3Box4PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions3Box4PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["TotalTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions3Box4PopOut2.Text:SetText(self:GetText())
			vcbOptions3Box4PopOut2Choice0:Hide()
		end
	end)
end
-- Box 5 Spell's Name & Castbar's Color --
-- pop out 1 Spell's Name --
-- enter --
vcbOptions3Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nLatency's Bar to be shown?") 
end)
-- leave --
vcbOptions3Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box5PopOut1, vcbOptions3Box5PopOut1Choice0)
-- parent & sort --
vcbOptions3Box5PopOut1Choice1:SetParent(vcbOptions3Box5PopOut1Choice0)
vcbOptions3Box5PopOut1Choice1:SetPoint("TOP",vcbOptions3Box5PopOut1Choice0, "BOTTOM", 0, 0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions3Box5PopOut1Choice"..i]:SetParent(vcbOptions3Box5PopOut1Choice0)
	_G["vcbOptions3Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions3Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["NameText"] = self.Text:GetText()
			vcbOptions3Box5PopOut1.Text:SetText(self:GetText())
			vcbOptions3Box5PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Castbar's Color --
-- enter --
vcbOptions3Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhat color do you want the|nCastbar to be?") 
end)
-- leave --
vcbOptions3Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions3Box5PopOut2, vcbOptions3Box5PopOut2Choice0)
-- naming --
vcbOptions3Box5PopOut2Choice0.Text:SetText("Default Color")
vcbOptions3Box5PopOut2Choice1.Text:SetText("Class' Color")
-- parent & sort --
for i = 1, 1, 1 do
	_G["vcbOptions3Box5PopOut2Choice"..i]:SetParent(vcbOptions3Box5PopOut2Choice0)
	_G["vcbOptions3Box5PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions3Box5PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions3Box5PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrFocus["Color"] = self.Text:GetText()
			vcbOptions3Box5PopOut2.Text:SetText(self:GetText())
			vcbOptions3Box5PopOut2Choice0:Hide()
		end
	end)
end
-- naming button choices for spell's name, current cast time, current & total time, and total time --
for i = 2, 5, 1 do
	_G["vcbOptions3Box"..i.."PopOut1Choice0"].Text:SetText("Hide")
	_G["vcbOptions3Box"..i.."PopOut1Choice1"].Text:SetText("Top Left")
	_G["vcbOptions3Box"..i.."PopOut1Choice2"].Text:SetText("Left")
	_G["vcbOptions3Box"..i.."PopOut1Choice3"].Text:SetText("Bottom Left")
	_G["vcbOptions3Box"..i.."PopOut1Choice4"].Text:SetText("Top")
	_G["vcbOptions3Box"..i.."PopOut1Choice5"].Text:SetText("Center")
	_G["vcbOptions3Box"..i.."PopOut1Choice6"].Text:SetText("Bottom")
	_G["vcbOptions3Box"..i.."PopOut1Choice7"].Text:SetText("Top Right")
	_G["vcbOptions3Box"..i.."PopOut1Choice8"].Text:SetText("Right")
	_G["vcbOptions3Box"..i.."PopOut1Choice9"].Text:SetText("Bottom Right")
end
-- Showing the panel --
vcbOptions3:HookScript("OnShow", function(self)
	CheckSavedVariables()
	FocusFrame.CBpreview:SetIgnoreParentAlpha(true)
	FocusFrame.CBpreview:SetAlpha(1)
	FocusFrame.CBpreview:ClearAllPoints()
	if VCBrFocus["Position"]["X"] == 0 and VCBrFocus["Position"]["Y"] == 0 then
		FocusFrame.CBpreview:SetPoint("TOPRIGHT", self, "TOPLEFT", -32, -32)
	else FocusFrame.CBpreview:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
	end
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbDeafultColor:GetRGB())
end)
-- Hiding the panel --
vcbOptions3:SetScript("OnHide", function(self)
	if FocusFrame.CBpreview:IsShown() then FocusFrame.CBpreview:Hide() end
end)
