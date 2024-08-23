-- taking care of the panel --
vcbOptions3:ClearAllPoints()
vcbOptions3:SetPoint("TOPLEFT", vcbOptions00, "TOPLEFT", 0, 0)
vcbOptions3.BGtexture:SetAlpha(1)
vcbOptions3.TopTxt:SetText("專注目標施法條選項!|n|n請關閉其他所有視窗|n保持打開此面板|n並且設定專注目標!")
vcbOptions3.CenterTxt:Hide()
vcbOptions3.BottomLeftTxt:Hide()
vcbOptions3Box1.TitleTxt:SetText("專注目標施法條的位置 & 縮放大小!")
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
end
-- taking care of the target preview --
FocusFrame.CBpreview:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("左鍵拖曳移動!") 
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
vcbOptions3Box1CheckButton1.Text:SetText("解鎖")
vcbOptions3Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("打勾解鎖目標施法條!") 
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
	GameTooltip:SetText("也可以使用滑鼠滾輪或兩邊的按鈕來更改數值!") 
end)
vcbOptions3Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions3Box1Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- On Value Changed --
vcbOptions3Box1Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions3Box1Slider1.TopText:SetText("專注目標施法條縮放大小: "..(self:GetValue()/100))
	VCBrFocus["Scale"] = self:GetValue()
	FocusFrame.CBpreview:SetScale(VCBrFocus["Scale"]/100)
end)
-- Popout 1, entering, leaving, click --
vcbOptions3Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否有使用任何單位框架/頭像插件?") 
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
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." ["..vcbMainColor:WrapTextInColorCode("內建施法條增強").."] 你沒有使用 Shadow Unit Frame 插件，不需要選擇該選項!")
		end
	end
end)
-- naming --
vcbOptions3Box1PopOut1Choice0.Text:SetText("無")
vcbOptions3Box1PopOut1Choice1.Text:SetText("Shadowed Unit Frame")
vcbOptions3Box1PopOut1Choice1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("使用 SUF 的玩家，請在 SUF 選項>隱藏暴雪>隱藏目標框架，取消打勾。|n然後選擇 'Shadow Unit Frame'|n完成此操作後請重新啟動遊戲!") 
end)
vcbOptions3Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
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
