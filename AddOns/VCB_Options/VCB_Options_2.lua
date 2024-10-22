-- taking care of the panel --
vcbOptions2.TopTxt:SetText("Target's Castbar Options!")
-- naming the boxes --
vcbOptions2Box0.TitleTxt:SetText("Read me please!")
vcbOptions2Box1.TitleTxt:SetText("Position & Scale of the Target's Castbar!")
vcbOptions2Box2.TitleTxt:SetText("Current Cast Time")
vcbOptions2Box3.TitleTxt:SetText("Current & Total Cast Time")
vcbOptions2Box4.TitleTxt:SetText("Total Cast Time")
vcbOptions2Box5.TitleTxt:SetText("Spell's Name & Cast Bar's Color")
-- positioning the boxes --
vcbOptions2Box1:SetPoint("TOPLEFT", vcbOptions2Box0, "BOTTOMLEFT", 0, 0)
vcbOptions2Box2:SetPoint("TOPRIGHT", vcbOptions2Box0, "BOTTOMRIGHT", 0, 0)
vcbOptions2Box3:SetPoint("TOPLEFT", vcbOptions2Box1, "BOTTOMLEFT", 0, 0)
vcbOptions2Box4:SetPoint("TOPRIGHT", vcbOptions2Box2, "BOTTOMRIGHT", 0, 0)
vcbOptions2Box5:SetPoint("TOP", vcbOptions2Box4, "BOTTOM", 0, 0)
-- fuction for Available --
local function vcbAvailable()
	vcbOptions2Box1CheckButton1:SetChecked(true)
	vcbOptions2Box1CheckButton1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions2Box1Slider1.Slider:EnableMouse(true)
	vcbOptions2Box1Slider1.Back:EnableMouse(true)
	vcbOptions2Box1Slider1.Forward:EnableMouse(true)
	vcbOptions2Box1Slider1:SetAlpha(1)
	vcbOptions2Box1PopOut1:EnableMouse(true)
	vcbOptions2Box1PopOut1:SetAlpha(1)
	TargetFrame.CBpreview:Show()
end
-- function for Disable --
local function vcbDisable()
	vcbOptions2Box1CheckButton1:SetChecked(false)
	vcbOptions2Box1CheckButton1.Text:SetTextColor(0.35, 0.35, 0.35, 0.8)
	vcbOptions2Box1Slider1.Slider:EnableMouse(false)
	vcbOptions2Box1Slider1.Back:EnableMouse(false)
	vcbOptions2Box1Slider1.Forward:EnableMouse(false)
	vcbOptions2Box1Slider1:SetAlpha(0.35)
	vcbOptions2Box1PopOut1:EnableMouse(false)
	vcbOptions2Box1PopOut1:SetAlpha(0.35)
	TargetFrame.CBpreview:Hide()
end
-- Checking the Saved Variables --
local function CheckSavedVariables()
	if not VCBrTarget["Unlock"] then
		vcbDisable()
	elseif VCBrTarget["Unlock"] then
		vcbAvailable()
	end
	vcbOptions2Box1Slider1:SetValue(VCBrTarget["Scale"])
	TargetFrame.CBpreview:SetScale(VCBrTarget["Scale"]/100)
	vcbOptions2Box1PopOut1.Text:SetText(VCBrTarget["otherAdddon"])
	if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then TargetFrame.CBpreview:SetParent(SUFUnittarget) end
	vcbOptions2Box2PopOut1:SetText(VCBrTarget["CurrentTimeText"]["Position"])
	vcbOptions2Box2PopOut2:SetText(VCBrTarget["CurrentTimeText"]["Direction"])
	vcbOptions2Box2PopOut3:SetText(VCBrTarget["CurrentTimeText"]["Sec"])
	vcbOptions2Box2PopOut4:SetText(VCBrTarget["CurrentTimeText"]["Decimals"])
	vcbOptions2Box3PopOut1:SetText(VCBrTarget["BothTimeText"]["Position"])
	vcbOptions2Box3PopOut2:SetText(VCBrTarget["BothTimeText"]["Direction"])
	vcbOptions2Box3PopOut3:SetText(VCBrTarget["BothTimeText"]["Sec"])
	vcbOptions2Box3PopOut4:SetText(VCBrTarget["BothTimeText"]["Decimals"])
	vcbOptions2Box4PopOut1:SetText(VCBrTarget["TotalTimeText"]["Position"])
	vcbOptions2Box4PopOut2:SetText(VCBrTarget["TotalTimeText"]["Sec"])
	vcbOptions2Box4PopOut3:SetText(VCBrTarget["TotalTimeText"]["Decimals"])
	vcbOptions2Box5PopOut1:SetText(VCBrTarget["NameText"])
	vcbOptions2Box5PopOut2:SetText(VCBrTarget["Color"])
end
-- taking care of the target preview --
TargetFrame.CBpreview:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nLeft click and drag to move me!") 
end)
-- Function for stoping the movement --
local function StopMoving(self)
	VCBrTarget["Position"]["X"] = Round(self:GetLeft())
	VCBrTarget["Position"]["Y"] = Round(self:GetBottom())
	self:StopMovingOrSizing()
end
-- Moving the target preview --
TargetFrame.CBpreview:RegisterForDrag("LeftButton")
TargetFrame.CBpreview:SetScript("OnDragStart", TargetFrame.CBpreview.StartMoving)
TargetFrame.CBpreview:SetScript("OnDragStop", function(self) StopMoving(self) end)
-- Hiding the target preview --
TargetFrame.CBpreview:SetScript("OnHide", function(self)
	VCBrTarget["Position"]["X"] = Round(self:GetLeft())
	VCBrTarget["Position"]["Y"] = Round(self:GetBottom())
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
vcbOptions2Box0.CenterText:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 1: ").."Please close all other panels and keep this panel open, then take a target!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 2: ").."When you dock or undock the cast bar, the game will be reloaded!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 3: ").."When you choose from the pop out the Shadowed Unit Frame (SUF), the game will be reloaded!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("Note 4: ").."For the people who uses SUF. If you are an old user and you unticked the option 'Hide target frame' undo it. Go to the SUF option and Hide target frame again. If you are a new user you have to do nothing!")
-- Box 1 --
-- check button 1 do it --
vcbOptions2Box1CheckButton1.Text:SetText("Undock")
vcbOptions2Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nCheck me! if you want to undock|nthe target's cast bar!") 
end)
vcbOptions2Box1CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBrTarget["Unlock"] = true
			vcbAvailable()
			C_UI.Reload()
		elseif self:GetChecked() == false then
			VCBrTarget["Unlock"] = false
			vcbDisable()
			if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then VCBrTarget["otherAdddon"] = "None" end
			C_UI.Reload()
		end
	end
end)
-- slider 1 --
vcbOptions2Box1Slider1.MinText:SetText(0.10)
vcbOptions2Box1Slider1.MaxText:SetText(2)
vcbOptions2Box1Slider1.Slider:SetMinMaxValues(10, 200)
-- slider 1 do it --
vcbOptions2Box1Slider1.Slider:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nYou can also use your mousewheel|nor the buttons to the edge|nto change the value!") 
end)
vcbOptions2Box1Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- On Value Changed --
vcbOptions2Box1Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions2Box1Slider1.TopText:SetText("Target's Cast Bar Scale: "..(self:GetValue()/100))
	VCBrTarget["Scale"] = self:GetValue()
	TargetFrame.CBpreview:SetScale(VCBrTarget["Scale"]/100)
end)
-- Popout 1, entering, leaving, click --
vcbOptions2Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you have any add on|nfor the Unit Frames?") 
end)
-- sort & clicking --
vcbOptions2Box1PopOut1Choice1:SetParent(vcbOptions2Box1PopOut1Choice0)
vcbOptions2Box1PopOut1Choice1:SetPoint("TOP",vcbOptions2Box1PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions2Box1PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			VCBrTarget["otherAdddon"] = self.Text:GetText()
			C_UI.Reload()
		else
			VCBrTarget["otherAdddon"] = self.Text:GetText()
		end
		vcbOptions2Box1PopOut1.Text:SetText(self:GetText())
		vcbOptions2Box1PopOut1Choice0:Hide()
	end
end)
vcbOptions2Box1PopOut1Choice1:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		local _, finished = C_AddOns.IsAddOnLoaded("ShadowedUnitFrames")
		if finished then
			VCBrTarget["otherAdddon"] = self.Text:GetText()
			vcbOptions2Box1PopOut1.Text:SetText(self:GetText())
			vcbOptions2Box1PopOut1Choice0:Hide()
			C_UI.Reload()
		else
			local vcbTime = GameTime_GetTime(false)
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] You don't use the Shadow Unit Frame add on, you don't need to choose that option!")
		end
	end
end)
-- naming --
vcbOptions2Box1PopOut1Choice0.Text:SetText("None")
vcbOptions2Box1PopOut1Choice1.Text:SetText("Shadowed Unit Frame")
-- enter choice 1 --
vcbOptions2Box1PopOut1Choice1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nFor people who uses SUF!|nFrom SUF options UNCHECK the option|nHide Blizzard - Hide Target frames!|nPlease restart your game client after this action!|nAnd then choose the 'Shadow Unit Frame'!") 
end)
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions2Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent Cast Time to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions2Box2PopOut1Choice"..i]:SetParent(vcbOptions2Box2PopOut1Choice0)
	_G["vcbOptions2Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box2PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions2Box2PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions2Box2PopOut1.Text:SetText(self:GetText())
			vcbOptions2Box2PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current Cast Time Direction --
-- enter --
vcbOptions2Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- naming --
vcbOptions2Box2PopOut2Choice0.Text:SetText("Ascending")
vcbOptions2Box2PopOut2Choice1.Text:SetText("Descending")
vcbOptions2Box2PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions2Box2PopOut2Choice"..i]:SetParent(vcbOptions2Box2PopOut2Choice0)
	_G["vcbOptions2Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box2PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions2Box2PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions2Box2PopOut2.Text:SetText(self:GetText())
			vcbOptions2Box2PopOut2Choice0:Hide()
		end
	end)
end
--  pop out 3 Current Cast Time Sec? --
-- enter --
vcbOptions2Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- naming --
vcbOptions2Box2PopOut3Choice0.Text:SetText("Show")
vcbOptions2Box2PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions2Box2PopOut3Choice1:SetParent(vcbOptions2Box2PopOut3Choice0)
vcbOptions2Box2PopOut3Choice1:SetPoint("TOP",vcbOptions2Box2PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions2Box2PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["CurrentTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions2Box2PopOut3.Text:SetText(self:GetText())
			vcbOptions2Box2PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Current Cast Time Decimals --
-- enter --
vcbOptions2Box2PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- naming --
vcbOptions2Box2PopOut4Choice0.Text:SetText("0")
vcbOptions2Box2PopOut4Choice1.Text:SetText("1")
vcbOptions2Box2PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions2Box2PopOut4Choice"..i]:SetParent(vcbOptions2Box2PopOut4Choice0)
	_G["vcbOptions2Box2PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box2PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions2Box2PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["CurrentTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions2Box2PopOut4.Text:SetText(self:GetText())
			vcbOptions2Box2PopOut4Choice0:Hide()
		end
	end)
end
-- Box 3 Current & Total Cast Time --
-- pop out 1 Current & Total Cast Time --
-- enter --
vcbOptions2Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nCurrent/Total Cast Time to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions2Box3PopOut1Choice"..i]:SetParent(vcbOptions2Box3PopOut1Choice0)
	_G["vcbOptions2Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box3PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions2Box3PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions2Box3PopOut1.Text:SetText(self:GetText())
			vcbOptions2Box3PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current & Total Cast Time Direction --
-- enter --
vcbOptions2Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText(vcbMainColor:WrapTextInColorCode("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow do you want the|ndirection of time to be?|nBoth means that the timer,|nwhile casting would be Ascending, and|nwhile channeling would be Descending!") 
end)
-- naming --
vcbOptions2Box3PopOut2Choice0.Text:SetText("Ascending")
vcbOptions2Box3PopOut2Choice1.Text:SetText("Descending")
vcbOptions2Box3PopOut2Choice2.Text:SetText("Both")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions2Box3PopOut2Choice"..i]:SetParent(vcbOptions2Box3PopOut2Choice0)
	_G["vcbOptions2Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box3PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions2Box3PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions2Box3PopOut2.Text:SetText(self:GetText())
			vcbOptions2Box3PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Current & Total Cast Time Sec? --
-- enter --
vcbOptions2Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- naming --
vcbOptions2Box3PopOut3Choice0.Text:SetText("Show")
vcbOptions2Box3PopOut3Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions2Box3PopOut3Choice1:SetParent(vcbOptions2Box3PopOut3Choice0)
vcbOptions2Box3PopOut3Choice1:SetPoint("TOP",vcbOptions2Box3PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions2Box3PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["BothTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions2Box3PopOut3.Text:SetText(self:GetText())
			vcbOptions2Box3PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Both Time Decimals --
-- enter --
vcbOptions2Box3PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- naming --
vcbOptions2Box3PopOut4Choice0.Text:SetText("0")
vcbOptions2Box3PopOut4Choice1.Text:SetText("1")
vcbOptions2Box3PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions2Box3PopOut4Choice"..i]:SetParent(vcbOptions2Box3PopOut4Choice0)
	_G["vcbOptions2Box3PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box3PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions2Box3PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["BothTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions2Box3PopOut4.Text:SetText(self:GetText())
			vcbOptions2Box3PopOut4Choice0:Hide()
		end
	end)
end
-- Box 4 Total Cast Time --
-- pop out 1 Total Cast Time --
-- enter --
vcbOptions2Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhere do you want the|nTotal Cast Time to be shown?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions2Box4PopOut1Choice"..i]:SetParent(vcbOptions2Box4PopOut1Choice0)
	_G["vcbOptions2Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box4PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- sort & clicking --
for i = 0, 9, 1 do
	_G["vcbOptions2Box4PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions2Box4PopOut1.Text:SetText(self:GetText())
			vcbOptions2Box4PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Total Cast Time Sec? --
-- enter --
vcbOptions2Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nword 'Sec' to be shown?") 
end)
-- naming --
vcbOptions2Box4PopOut2Choice0.Text:SetText("Show")
vcbOptions2Box4PopOut2Choice1.Text:SetText("Hide")
-- parent & sort --
vcbOptions2Box4PopOut2Choice1:SetParent(vcbOptions2Box4PopOut2Choice0)
vcbOptions2Box4PopOut2Choice1:SetPoint("TOP",vcbOptions2Box4PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions2Box4PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["TotalTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions2Box4PopOut2.Text:SetText(self:GetText())
			vcbOptions2Box4PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Total Time Decimals --
-- enter --
vcbOptions2Box4PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nHow many decimals do you want to be shown!") 
end)
-- naming --
vcbOptions2Box4PopOut3Choice0.Text:SetText("0")
vcbOptions2Box4PopOut3Choice1.Text:SetText("1")
vcbOptions2Box4PopOut3Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions2Box4PopOut3Choice"..i]:SetParent(vcbOptions2Box4PopOut3Choice0)
	_G["vcbOptions2Box4PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box4PopOut3Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions2Box4PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["TotalTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions2Box4PopOut3.Text:SetText(self:GetText())
			vcbOptions2Box4PopOut3Choice0:Hide()
		end
	end)
end
-- Box 5 Spell's Name & Castbar's Color --
-- pop out 1 Spell's Name --
-- enter --
vcbOptions2Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nDo you want the|nLatency's Bar to be shown?") 
end)
-- parent & sort --
vcbOptions2Box5PopOut1Choice1:SetParent(vcbOptions2Box5PopOut1Choice0)
vcbOptions2Box5PopOut1Choice1:SetPoint("TOP",vcbOptions2Box5PopOut1Choice0, "BOTTOM", 0, 0)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions2Box5PopOut1Choice"..i]:SetParent(vcbOptions2Box5PopOut1Choice0)
	_G["vcbOptions2Box5PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box5PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions2Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["NameText"] = self.Text:GetText()
			vcbOptions2Box5PopOut1.Text:SetText(self:GetText())
			vcbOptions2Box5PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Castbar's Color --
-- enter --
vcbOptions2Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nWhat color do you want the|nCastbar to be?") 
end)
-- naming --
vcbOptions2Box5PopOut2Choice0.Text:SetText("Default Color")
vcbOptions2Box5PopOut2Choice1.Text:SetText("Class' Color")
-- parent & sort --
for i = 1, 1, 1 do
	_G["vcbOptions2Box5PopOut2Choice"..i]:SetParent(vcbOptions2Box5PopOut2Choice0)
	_G["vcbOptions2Box5PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box5PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions2Box5PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["Color"] = self.Text:GetText()
			vcbOptions2Box5PopOut2.Text:SetText(self:GetText())
			vcbOptions2Box5PopOut2Choice0:Hide()
		end
	end)
end
-- naming button choices for spell's name, current cast time, current & total time, and total time --
for i = 2, 5, 1 do
	_G["vcbOptions2Box"..i.."PopOut1Choice0"].Text:SetText("Hide")
	_G["vcbOptions2Box"..i.."PopOut1Choice1"].Text:SetText("Top Left")
	_G["vcbOptions2Box"..i.."PopOut1Choice2"].Text:SetText("Left")
	_G["vcbOptions2Box"..i.."PopOut1Choice3"].Text:SetText("Bottom Left")
	_G["vcbOptions2Box"..i.."PopOut1Choice4"].Text:SetText("Top")
	_G["vcbOptions2Box"..i.."PopOut1Choice5"].Text:SetText("Center")
	_G["vcbOptions2Box"..i.."PopOut1Choice6"].Text:SetText("Bottom")
	_G["vcbOptions2Box"..i.."PopOut1Choice7"].Text:SetText("Top Right")
	_G["vcbOptions2Box"..i.."PopOut1Choice8"].Text:SetText("Right")
	_G["vcbOptions2Box"..i.."PopOut1Choice9"].Text:SetText("Bottom Right")
end
-- Showing the panel --
vcbOptions2:HookScript("OnShow", function(self)
	CheckSavedVariables()
	TargetFrame.CBpreview:SetIgnoreParentAlpha(true)
	TargetFrame.CBpreview:SetAlpha(1)
	TargetFrame.CBpreview:ClearAllPoints()
	if VCBrTarget["Position"]["X"] == 0 and VCBrTarget["Position"]["Y"] == 0 then
		TargetFrame.CBpreview:SetPoint("TOPRIGHT", self, "TOPLEFT", -32, -32)
	else TargetFrame.CBpreview:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	end
	if vcbOptions1:IsShown() then vcbOptions1:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbMainColor:GetRGB())
end)
-- Hiding the panel --
vcbOptions2:SetScript("OnHide", function(self)
	if TargetFrame.CBpreview:IsShown() then TargetFrame.CBpreview:Hide() end
end)
