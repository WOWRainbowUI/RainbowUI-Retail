-- taking care of the panel --
vcbOptions5.TopTxt:SetText("Arena's Castbar Options!")
-- naming the boxes --
vcbOptions5Box0.TitleTxt:SetText("Read me please!")
vcbOptions5Box1.TitleTxt:SetText("Unit Frame add-on")
vcbOptions5Box2.TitleTxt:SetText("Current Cast Time")
vcbOptions5Box3.TitleTxt:SetText("Current & Total Cast Time")
vcbOptions5Box4.TitleTxt:SetText("Total Cast Time")
vcbOptions5Box5.TitleTxt:SetText("Spell's Name & Cast Bar's Color")
-- positioning the boxes --
vcbOptions5Box1:SetPoint("TOPLEFT", vcbOptions5Box0, "BOTTOMLEFT", 0, 0)
vcbOptions5Box2:SetPoint("TOPRIGHT", vcbOptions5Box0, "BOTTOMRIGHT", 0, 0)
vcbOptions5Box3:SetPoint("TOPLEFT", vcbOptions5Box1, "BOTTOMLEFT", 0, 0)
vcbOptions5Box4:SetPoint("TOPRIGHT", vcbOptions5Box2, "BOTTOMRIGHT", 0, 0)
vcbOptions5Box5:SetPoint("TOP", vcbOptions5Box4, "BOTTOM", 0, 0)
-- fuction for Available --
local function vcbAvailable()
	vcbOptions5Box1CheckButton1:SetChecked(true)
	vcbOptions5Box1CheckButton1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions5Box1Slider1.Slider:EnableMouse(true)
	vcbOptions5Box1Slider1.Back:EnableMouse(true)
	vcbOptions5Box1Slider1.Forward:EnableMouse(true)
	vcbOptions5Box1Slider1:SetAlpha(1)
	vcbOptions5Box1PopOut1:EnableMouse(true)
	vcbOptions5Box1PopOut1:SetAlpha(1)
	for i = 1, 3, 1 do
		_G["vcbPreviewArena"..i]:Show()
	end
end
-- function for Disable --
local function vcbDisable()
	vcbOptions5Box1CheckButton1:SetChecked(false)
	vcbOptions5Box1CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
	vcbOptions5Box1Slider1.Slider:EnableMouse(false)
	vcbOptions5Box1Slider1.Back:EnableMouse(false)
	vcbOptions5Box1Slider1.Forward:EnableMouse(false)
	vcbOptions5Box1Slider1:SetAlpha(0.35)
	vcbOptions5Box1PopOut1:EnableMouse(false)
	vcbOptions5Box1PopOut1:SetAlpha(0.35)
	for i = 1, 3, 1 do
		_G["vcbPreviewArena"..i]:Hide()
	end
end
-- Checking the Saved Variables --
local function CheckSavedVariables()
	if not VCBrArena["Unlock"] then
		vcbDisable()
	elseif VCBrArena["Unlock"] then
		vcbAvailable()
	end
	vcbOptions5Box1Slider1:SetValue(VCBrArena["Scale"])
	for i = 1, 3, 1 do
		_G["vcbPreviewArena"..i]:SetScale(VCBrArena["Scale"]/100)
	end
	vcbOptions5Box1PopOut1.Text:SetText(VCBrArena["otherAdddon"])
	vcbOptions5Box2PopOut1:SetText(VCBrArena["CurrentTimeText"]["Position"])
	vcbOptions5Box2PopOut2:SetText(VCBrArena["CurrentTimeText"]["Direction"])
	vcbOptions5Box2PopOut3:SetText(VCBrArena["CurrentTimeText"]["Sec"])
	vcbOptions5Box2PopOut4:SetText(VCBrArena["CurrentTimeText"]["Decimals"])
	vcbOptions5Box3PopOut1:SetText(VCBrArena["BothTimeText"]["Position"])
	vcbOptions5Box3PopOut2:SetText(VCBrArena["BothTimeText"]["Direction"])
	vcbOptions5Box3PopOut3:SetText(VCBrArena["BothTimeText"]["Sec"])
	vcbOptions5Box3PopOut4:SetText(VCBrArena["BothTimeText"]["Decimals"])
	vcbOptions5Box4PopOut1:SetText(VCBrArena["TotalTimeText"]["Position"])
	vcbOptions5Box4PopOut2:SetText(VCBrArena["TotalTimeText"]["Sec"])
	vcbOptions5Box4PopOut3:SetText(VCBrArena["TotalTimeText"]["Decimals"])
	vcbOptions5Box5PopOut1:SetText(VCBrArena["NameText"])
	vcbOptions5Box5PopOut2:SetText(VCBrArena["Color"])
end
-- taking care of the Arena preview --
vcbPreviewArena1.Text:SetText("Arena CB preview")
vcbPreviewArena1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nLeft click and drag to move me!") 
end)
vcbPreviewArena1:SetScript("OnLeave", vcbLeavingMenus)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBrArena["Position"]["X"] = Round(self:GetLeft())
	VCBrArena["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the Arena preview --
vcbPreviewArena1:RegisterForDrag("LeftButton")
vcbPreviewArena1:SetScript("OnDragStart", vcbPreviewArena1.StartMoving)
vcbPreviewArena1:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the Arena preview --
vcbPreviewArena1:SetScript("OnHide", function(self)
	VCBrArena["Position"]["X"] = Round(self:GetLeft())
	VCBrArena["Position"]["Y"] = Round(self:GetBottom())
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
vcbOptions5Box0.CenterText:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 1: ").."The Unlock function works ONLY for the Unit Frame addons like SUF!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 2: ").."When you lock or unlock the cast bar, the game will be reloaded!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 3: ").."When you choose from the pop out button, the game will be reloaded!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 4: ").."Please try to keep this panel open!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 5: ").."If you use SUF then you should go to SUF options in General and Unlock!")
-- Box 1 --
-- check button 1 do it --
vcbOptions5Box1CheckButton1.Text:SetText("Unlock")
vcbOptions5Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nCheck me! if you want to Unlock|nthe focus' cast bar!") 
end)
vcbOptions5Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions5Box1CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBrArena["Unlock"] = true
			vcbAvailable()
			C_UI.Reload()
		elseif self:GetChecked() == false then
			VCBrArena["Unlock"] = false
			vcbDisable()
			if VCBrArena["otherAdddon"] == "Shadowed Unit Frame" then VCBrArena["otherAdddon"] = "None" end
			C_UI.Reload()
		end
	end
end)
-- slider 1 --
vcbOptions5Box1Slider1.MinText:SetText(0.10)
vcbOptions5Box1Slider1.MaxText:SetText(2)
vcbOptions5Box1Slider1.Slider:SetMinMaxValues(10, 200)
-- slider 1 do it --
vcbOptions5Box1Slider1.Slider:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nYou can also use your mousewheel|nor the buttons to the edge|nto change the value!") 
end)
vcbOptions5Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions5Box1Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- On Value Changed --
vcbOptions5Box1Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions5Box1Slider1.TopText:SetText("Arena' Castbar Scale: "..(self:GetValue()/100))
	VCBrArena["Scale"] = self:GetValue()
	for i = 1, 3, 1 do
		_G["vcbPreviewArena"..i]:SetScale(VCBrArena["Scale"]/100)
	end
end)
-- Popout 1, entering, leaving, click --
vcbOptions5Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you have any add on|nfor the Unit Frames?") 
end)
vcbOptions5Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions5Box1PopOut1, vcbOptions5Box1PopOut1Choice0)
-- sort & clicking --
vcbOptions5Box1PopOut1Choice1:SetParent(vcbOptions5Box1PopOut1Choice0)
vcbOptions5Box1PopOut1Choice1:SetPoint("TOP",vcbOptions5Box1PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions5Box1PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if VCBrArena["otherAdddon"] == "Shadowed Unit Frame" then
			VCBrArena["otherAdddon"] = self.Text:GetText()
			C_UI.Reload()
		else
			VCBrArena["otherAdddon"] = self.Text:GetText()
		end
		vcbOptions5Box1PopOut1.Text:SetText(self:GetText())
		vcbOptions5Box1PopOut1Choice0:Hide()
	end
end)
vcbOptions5Box1PopOut1Choice1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
		if finished then
			VCBrArena["otherAdddon"] = self.Text:GetText()
			vcbOptions5Box1PopOut1.Text:SetText(self:GetText())
			vcbOptions5Box1PopOut1Choice0:Hide()
			C_UI.Reload()
		else
			local vcbTime = GameTime_GetTime(false)
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] You don't use the Shadowed Unit Frame add on, you don't need to choose that option!")
		end
	end
end)
-- naming --
vcbOptions5Box1PopOut1Choice0.Text:SetText("None")
vcbOptions5Box1PopOut1Choice1.Text:SetText("Shadowed Unit Frame")
-- enter choice 1 --
vcbOptions5Box1PopOut1Choice1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nFor people who uses SUF!|nFrom SUF options UNCHECK the option|nHide Blizzard - Hide focus frames!|nPlease restart your game client after this action!|nAnd then choose the 'Shadow Unit Frame'!") 
end)
-- leave choice 1 --
vcbOptions5Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions5Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent Cast Time to be shown?") 
end)
-- leave --
vcbOptions5Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box2PopOut1, vcbOptions5Box2PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions5Box2PopOut1Choice"..i]:SetParent(vcbOptions5Box2PopOut1Choice0)
	_G["vcbOptions5Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box2PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions5Box2PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions5Box2PopOut1.Text:SetText(self:GetText())
			vcbOptions5Box2PopOut1Choice0:Hide()
			chkArenaCurrentTimePosition()
		end
	end)
end
-- pop out 2 Current Cast Time Direction --
-- enter --
vcbOptions5Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- leave --
vcbOptions5Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box2PopOut2, vcbOptions5Box2PopOut2Choice0)
-- naming --
vcbOptions5Box2PopOut2Choice0.Text:SetText("Ascending")
vcbOptions5Box2PopOut2Choice1.Text:SetText("Descending")
vcbOptions5Box2PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions5Box2PopOut2Choice"..i]:SetParent(vcbOptions5Box2PopOut2Choice0)
	_G["vcbOptions5Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box2PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions5Box2PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions5Box2PopOut2.Text:SetText(self:GetText())
			vcbOptions5Box2PopOut2Choice0:Hide()
			chkArenaCurrentTimeUpdate()
		end
	end)
end
--  pop out 3 Current Cast Time Sec? --
-- enter --
vcbOptions5Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions5Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box2PopOut3, vcbOptions5Box2PopOut3Choice0)
-- naming --
vcbOptions5Box2PopOut3Choice0.Text:SetText("Show")
vcbOptions5Box2PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions5Box2PopOut3Choice1:SetParent(vcbOptions5Box2PopOut3Choice0)
vcbOptions5Box2PopOut3Choice1:SetPoint("TOP",vcbOptions5Box2PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions5Box2PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["CurrentTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions5Box2PopOut3.Text:SetText(self:GetText())
			vcbOptions5Box2PopOut3Choice0:Hide()
			chkArenaCurrentTimeUpdate()
		end
	end)
end
-- pop out 4 Current Cast Time Decimals --
-- enter --
vcbOptions5Box2PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- leave --
vcbOptions5Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box2PopOut4, vcbOptions5Box2PopOut4Choice0)
-- naming --
vcbOptions5Box2PopOut4Choice0.Text:SetText("0")
vcbOptions5Box2PopOut4Choice1.Text:SetText("1")
vcbOptions5Box2PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions5Box2PopOut4Choice"..i]:SetParent(vcbOptions5Box2PopOut4Choice0)
	_G["vcbOptions5Box2PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box2PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions5Box2PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["CurrentTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions5Box2PopOut4.Text:SetText(self:GetText())
			vcbOptions5Box2PopOut4Choice0:Hide()
			chkArenaCurrentTimeUpdate()
		end
	end)
end
-- Box 3 Current & Total Cast Time --
-- pop out 1 Current & Total Cast Time --
-- enter --
vcbOptions5Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent/Total Cast Time to be shown?") 
end)
-- leave --
vcbOptions5Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box3PopOut1, vcbOptions5Box3PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions5Box3PopOut1Choice"..i]:SetParent(vcbOptions5Box3PopOut1Choice0)
	_G["vcbOptions5Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box3PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions5Box3PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions5Box3PopOut1.Text:SetText(self:GetText())
			vcbOptions5Box3PopOut1Choice0:Hide()
			chkArenaBothTimePosition()
		end
	end)
end
-- pop out 2 Current & Total Cast Time Direction --
-- enter --
vcbOptions5Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- leave --
vcbOptions5Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box3PopOut2, vcbOptions5Box3PopOut2Choice0)
-- naming --
vcbOptions5Box3PopOut2Choice0.Text:SetText("Ascending")
vcbOptions5Box3PopOut2Choice1.Text:SetText("Descending")
vcbOptions5Box3PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions5Box3PopOut2Choice"..i]:SetParent(vcbOptions5Box3PopOut2Choice0)
	_G["vcbOptions5Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box3PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions5Box3PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions5Box3PopOut2.Text:SetText(self:GetText())
			vcbOptions5Box3PopOut2Choice0:Hide()
			chkArenaBothTimeUpdate()
		end
	end)
end
-- pop out 3 Current & Total Cast Time Sec? --
-- enter --
vcbOptions5Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions5Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box3PopOut3, vcbOptions5Box3PopOut3Choice0)
-- naming --
vcbOptions5Box3PopOut3Choice0.Text:SetText("Show")
vcbOptions5Box3PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions5Box3PopOut3Choice1:SetParent(vcbOptions5Box3PopOut3Choice0)
vcbOptions5Box3PopOut3Choice1:SetPoint("TOP",vcbOptions5Box3PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions5Box3PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["BothTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions5Box3PopOut3.Text:SetText(self:GetText())
			vcbOptions5Box3PopOut3Choice0:Hide()
			chkArenaBothTimeUpdate()
		end
	end)
end
-- pop out 4 Both Time Decimals --
-- enter --
vcbOptions5Box3PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- leave --
vcbOptions5Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box3PopOut4, vcbOptions5Box3PopOut4Choice0)
-- naming --
vcbOptions5Box3PopOut4Choice0.Text:SetText("0")
vcbOptions5Box3PopOut4Choice1.Text:SetText("1")
vcbOptions5Box3PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions5Box3PopOut4Choice"..i]:SetParent(vcbOptions5Box3PopOut4Choice0)
	_G["vcbOptions5Box3PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box3PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions5Box3PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["BothTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions5Box3PopOut4.Text:SetText(self:GetText())
			vcbOptions5Box3PopOut4Choice0:Hide()
			chkArenaBothTimeUpdate()
		end
	end)
end
-- Box 4 Total Cast Time --
-- pop out 1 Total Cast Time --
-- enter --
vcbOptions5Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nTotal Cast Time to be shown?") 
end)
-- leave --
vcbOptions5Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box4PopOut1, vcbOptions5Box4PopOut1Choice0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions5Box4PopOut1Choice"..i]:SetParent(vcbOptions5Box4PopOut1Choice0)
	_G["vcbOptions5Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box4PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- sort & clicking --
for i = 0, 9, 1 do
	_G["vcbOptions5Box4PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions5Box4PopOut1.Text:SetText(self:GetText())
			vcbOptions5Box4PopOut1Choice0:Hide()
			chkArenaTotalTimePosition()
		end
	end)
end
-- pop out 2 Total Cast Time Sec? --
-- enter --
vcbOptions5Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- leave --
vcbOptions5Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box4PopOut2, vcbOptions5Box4PopOut2Choice0)
-- naming --
vcbOptions5Box4PopOut2Choice0.Text:SetText("Show")
vcbOptions5Box4PopOut2Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions5Box4PopOut2Choice1:SetParent(vcbOptions5Box4PopOut2Choice0)
vcbOptions5Box4PopOut2Choice1:SetPoint("TOP",vcbOptions5Box4PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions5Box4PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["TotalTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions5Box4PopOut2.Text:SetText(self:GetText())
			vcbOptions5Box4PopOut2Choice0:Hide()
			chkArenaTotalTimeUpdate()
		end
	end)
end
-- pop out 3 Total Time Decimals --
-- enter --
vcbOptions5Box4PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- leave --
vcbOptions5Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box4PopOut3, vcbOptions5Box4PopOut3Choice0)
-- naming --
vcbOptions5Box4PopOut3Choice0.Text:SetText("0")
vcbOptions5Box4PopOut3Choice1.Text:SetText("1")
vcbOptions5Box4PopOut3Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions5Box4PopOut3Choice"..i]:SetParent(vcbOptions5Box4PopOut3Choice0)
	_G["vcbOptions5Box4PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box4PopOut3Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions5Box4PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["TotalTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions5Box4PopOut3.Text:SetText(self:GetText())
			vcbOptions5Box4PopOut3Choice0:Hide()
			chkArenaTotalTimeUpdate()
		end
	end)
end
-- Box 5 Spell's Name & Castbar's Color --
-- pop out 1 Spell's Name --
-- enter --
vcbOptions5Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nSpell's Name to be shown?") 
end)
-- leave --
vcbOptions5Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box5PopOut1, vcbOptions5Box5PopOut1Choice0)
-- parent & sort --
vcbOptions5Box5PopOut1Choice1:SetParent(vcbOptions5Box5PopOut1Choice0)
vcbOptions5Box5PopOut1Choice1:SetPoint("TOP",vcbOptions5Box5PopOut1Choice0, "BOTTOM", 0, 0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions5Box5PopOut1Choice"..i]:SetParent(vcbOptions5Box5PopOut1Choice0)
	_G["vcbOptions5Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions5Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["NameText"] = self.Text:GetText()
			vcbOptions5Box5PopOut1.Text:SetText(self:GetText())
			vcbOptions5Box5PopOut1Choice0:Hide()
			chkArenaNamePosition()
		end
	end)
end
-- pop out 2 Castbar's Color --
-- enter --
vcbOptions5Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhat color do you want the|nCastbar to be?") 
end)
-- leave --
vcbOptions5Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions5Box5PopOut2, vcbOptions5Box5PopOut2Choice0)
-- naming --
vcbOptions5Box5PopOut2Choice0.Text:SetText("Default Color")
vcbOptions5Box5PopOut2Choice1.Text:SetText("Class' Color")
-- parent & sort --
for i = 1, 1, 1 do
	_G["vcbOptions5Box5PopOut2Choice"..i]:SetParent(vcbOptions5Box5PopOut2Choice0)
	_G["vcbOptions5Box5PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions5Box5PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions5Box5PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrArena["Color"] = self.Text:GetText()
			vcbOptions5Box5PopOut2.Text:SetText(self:GetText())
			vcbOptions5Box5PopOut2Choice0:Hide()
			chkArenaCastbarColor()
		end
	end)
end
-- naming button choices for spell's name, current cast time, current & total time, and total time --
for i = 2, 5, 1 do
	_G["vcbOptions5Box"..i.."PopOut1Choice0"].Text:SetText("Hide")
	_G["vcbOptions5Box"..i.."PopOut1Choice1"].Text:SetText("Top Left")
	_G["vcbOptions5Box"..i.."PopOut1Choice2"].Text:SetText("Left")
	_G["vcbOptions5Box"..i.."PopOut1Choice3"].Text:SetText("Bottom Left")
	_G["vcbOptions5Box"..i.."PopOut1Choice4"].Text:SetText("Top")
	_G["vcbOptions5Box"..i.."PopOut1Choice5"].Text:SetText("Center")
	_G["vcbOptions5Box"..i.."PopOut1Choice6"].Text:SetText("Bottom")
	_G["vcbOptions5Box"..i.."PopOut1Choice7"].Text:SetText("Top Right")
	_G["vcbOptions5Box"..i.."PopOut1Choice8"].Text:SetText("Right")
	_G["vcbOptions5Box"..i.."PopOut1Choice9"].Text:SetText("Bottom Right")
end
-- Showing the panel --
vcbOptions5:HookScript("OnShow", function(self)
	CheckSavedVariables()
	vcbPreviewArena1:SetIgnoreParentAlpha(true)
	vcbPreviewArena1:SetAlpha(1)
	vcbPreviewArena1:ClearAllPoints()
	if VCBrArena["Position"]["X"] == 0 and VCBrArena["Position"]["Y"] == 0 then
		vcbPreviewArena1:SetPoint("TOPRIGHT", self, "TOPLEFT", -32, -32)
	else vcbPreviewArena1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrArena["Position"]["X"], VCBrArena["Position"]["Y"])
	end
	for i = 2, 3, 1 do
		_G["vcbPreviewArena"..i]:ClearAllPoints()
		_G["vcbPreviewArena"..i]:SetPoint("TOP", _G["vcbPreviewArena"..(i-1)], "BOTTOM", 0, -32)
	end
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	if vcbOptions6:IsShown() then vcbOptions6:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab5.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab6.Text:SetTextColor(vcbMainColor:GetRGB())
end)
-- Hiding the panel --
vcbOptions5:SetScript("OnHide", function(self)
	for i = 1, 3, 1 do
		_G["vcbPreviewArena"..i]:Hide()
	end
end)
