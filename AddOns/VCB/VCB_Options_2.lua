-- taking care of the panel --
vcbOptions2.TopTxt:SetText("目標施法條選項!|n|n請關閉其他所有視窗|n保持打開此面板|n並且選取一個目標!")
vcbOptions2Box1.TitleTxt:SetText("目標施法條的位置 & 縮放大小!")
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
end
-- taking care of the target preview --
TargetFrame.CBpreview:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("左鍵拖曳移動!") 
end)
TargetFrame.CBpreview:SetScript("OnLeave", vcbLeavingMenus)
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
-- Box 1 --
-- check button 1 do it --
vcbOptions2Box1CheckButton1.Text:SetText("解鎖")
vcbOptions2Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("打勾解鎖目標施法條!") 
end)
vcbOptions2Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions2Box1CheckButton1:HookScript("OnClick", function (self, button)
	if button == "LeftButton" then
		if self:GetChecked() == true then
			VCBrTarget["Unlock"] = true
			vcbAvailable()
		elseif self:GetChecked() == false then
			VCBrTarget["Unlock"] = false
			vcbDisable()
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
	GameTooltip:SetText("也可以使用滑鼠滾輪或兩邊的按鈕來更改數值!") 
end)
vcbOptions2Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions2Box1Slider1.Slider:SetScript("OnMouseWheel", MouseWheelSlider)
-- On Value Changed --
vcbOptions2Box1Slider1.Slider:SetScript("OnValueChanged", function (self, value, userInput)
	vcbOptions2Box1Slider1.TopText:SetText("目標施法條縮放大小: "..(self:GetValue()/100))
	VCBrTarget["Scale"] = self:GetValue()
	TargetFrame.CBpreview:SetScale(VCBrTarget["Scale"]/100)
end)
-- Popout 1, entering, leaving, click --
vcbOptions2Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否有使用任何單位框架/頭像插件?") 
end)
vcbOptions2Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions2Box1PopOut1, vcbOptions2Box1PopOut1Choice0)
-- sort & clicking --
vcbOptions2Box1PopOut1Choice1:SetParent(vcbOptions2Box1PopOut1Choice0)
vcbOptions2Box1PopOut1Choice1:SetPoint("TOP",vcbOptions2Box1PopOut1Choice0, "BOTTOM", 0, 0)
vcbOptions2Box1PopOut1Choice0:HookScript("OnClick", function(self, button, down)
	if button == "LeftButton" and down == false then
		VCBrTarget["otherAdddon"] = self.Text:GetText()
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
		else
			local vcbTime = GameTime_GetTime(false)
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode("內建施法條增強").."] 你沒有使用 Shadow Unit Frame 插件，不需要選擇該選項!")
		end
	end
end)
-- naming --
vcbOptions2Box1PopOut1Choice0.Text:SetText("無")
vcbOptions2Box1PopOut1Choice1.Text:SetText("Shadowed Unit Frame")
-- enter choice 1 --
vcbOptions2Box1PopOut1Choice1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("使用 SUF 的玩家，請在 SUF 選項>隱藏暴雪>隱藏目標框架，取消打勾。|n然後選擇 'Shadow Unit Frame'|n完成此操作後請重新啟動遊戲!") 
end)
-- leave choice 1 --
vcbOptions2Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
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
	vcbOptions00Tab1.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbDeafultColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbDeafultColor:GetRGB())
end)
-- Hiding the panel --
vcbOptions2:SetScript("OnHide", function(self)
	if TargetFrame.CBpreview:IsShown() then TargetFrame.CBpreview:Hide() end
end)
