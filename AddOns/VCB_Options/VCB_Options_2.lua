-- taking care of the panel --
vcbOptions2.TopTxt:SetText("目標施法條選項!")
-- naming the boxes --
vcbOptions2Box0.TitleTxt:SetText("請讀我!")
vcbOptions2Box1.TitleTxt:SetText("位置 & 縮放大小")
vcbOptions2Box2.TitleTxt:SetText("目前施法時間")
vcbOptions2Box3.TitleTxt:SetText("目前 & 總共施法時間")
vcbOptions2Box4.TitleTxt:SetText("總共施法時間")
vcbOptions2Box5.TitleTxt:SetText("法術名稱 & 施法條顏色")
vcbOptions2Box6.TitleTxt:SetText("法術圖示")
-- positioning the boxes --
vcbOptions2Box1:SetPoint("TOPLEFT", vcbOptions2Box0, "BOTTOMLEFT", 0, 0)
vcbOptions2Box2:SetPoint("TOPRIGHT", vcbOptions2Box0, "BOTTOMRIGHT", 0, 0)
vcbOptions2Box3:SetPoint("TOPLEFT", vcbOptions2Box1, "BOTTOMLEFT", 0, 0)
vcbOptions2Box4:SetPoint("TOPRIGHT", vcbOptions2Box2, "BOTTOMRIGHT", 0, 0)
vcbOptions2Box5:SetPoint("TOPLEFT", vcbOptions2Box3, "BOTTOMLEFT", 0, 0)
vcbOptions2Box6:SetPoint("TOPRIGHT", vcbOptions2Box4, "BOTTOMRIGHT", 0, 0)
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
	vcbOptions2Box6PopOut1:SetText(VCBrTarget["Icon"])
end
-- taking care of the target preview --
TargetFrame.CBpreview:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("左鍵拖曳移動!") 
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
-- icon and shield visibility --
local function IconShieldVisibility()
	if VCBrTarget["Icon"] == "顯示圖示 & 盾牌" then
		if not TargetFrameSpellBar.Icon:IsShown() then TargetFrameSpellBar.Icon:Show() end
		if not TargetFrameSpellBar.showShield then TargetFrameSpellBar.showShield = true end
	elseif VCBrTarget["Icon"] == "隱藏圖示 & 盾牌" then
		if TargetFrameSpellBar.Icon:IsShown() then TargetFrameSpellBar.Icon:Hide() end
		if TargetFrameSpellBar.showShield then TargetFrameSpellBar.showShield = false end
	elseif VCBrTarget["Icon"] == "只隱藏圖示" then
		if TargetFrameSpellBar.Icon:IsShown() then TargetFrameSpellBar.Icon:Hide() end
		if not TargetFrameSpellBar.showShield then TargetFrameSpellBar.showShield = true end
	end
end
-- Box 0 Read me! --
vcbOptions2Box0.CenterText:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("注意 1: ").."請選擇一個目標，並關閉其他所有視窗，保持這個面板開啟!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("注意 2: ").."鎖定或解鎖施法條時，將會重新載入介面!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("注意 3: ").."從下拉選單中選擇 Shadowed Unit Frame (SUF) 時，將會重新載入介面!|n|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbHighColor:WrapTextInColorCode("注意 4: ").."使用 SUF 的玩家，如果你是舊使用者並且沒有勾選 '隱藏目標框架'，請到 SUF 的選項再次勾選隱藏目標框架。如果你是新使用者則無需做任何事!")
-- Box 1 --
-- check button 1 do it --
vcbOptions2Box1CheckButton1.Text:SetText("解鎖")
vcbOptions2Box1CheckButton1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("打勾解鎖目標施法條!")
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
			if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then VCBrTarget["otherAdddon"] = "無" end
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
	GameTooltip:SetText("也可以使用滑鼠滾輪或兩邊的按鈕來更改數值!") 
end)
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
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions2Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("當前施法時間要顯示在哪裡?") 
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
	GameTooltip:SetText("如何顯示時間?|n都有表示時間在施法時為正數，在引導時為倒數!") 
end)
-- naming --
vcbOptions2Box2PopOut2Choice0.Text:SetText("正數")
vcbOptions2Box2PopOut2Choice1.Text:SetText("倒數")
vcbOptions2Box2PopOut2Choice2.Text:SetText("兩者")
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
	GameTooltip:SetText("是否要顯示 '秒' 這個字?") 
end)
-- naming --
vcbOptions2Box2PopOut3Choice0.Text:SetText("顯示")
vcbOptions2Box2PopOut3Choice1.Text:SetText("隱藏")
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
	GameTooltip:SetText("時間要顯示幾位小數") 
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
	GameTooltip:SetText("目前/總共時間要顯示在哪裡?") 
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
	GameTooltip:SetText("如何顯示時間?|n兩者表示時間在施法時為正數，在引導時為倒數!") 
end)
-- naming --
vcbOptions2Box3PopOut2Choice0.Text:SetText("正數")
vcbOptions2Box3PopOut2Choice1.Text:SetText("倒數")
vcbOptions2Box3PopOut2Choice2.Text:SetText("兩者")
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
	GameTooltip:SetText("是否要顯示 '秒' 這個字?") 
end)
-- naming --
vcbOptions2Box3PopOut3Choice0.Text:SetText("顯示")
vcbOptions2Box3PopOut3Choice1.Text:SetText("隱藏")
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
	GameTooltip:SetText("時間要顯示幾位小數") 
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
	GameTooltip:SetText("總共施法時間要顯示在哪裡?") 
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
	GameTooltip:SetText("是否要顯示 '秒' 這個字?") 
end)
-- naming --
vcbOptions2Box4PopOut2Choice0.Text:SetText("顯示")
vcbOptions2Box4PopOut2Choice1.Text:SetText("隱藏")
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
	GameTooltip:SetText("時間要顯示幾位小數") 
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
	GameTooltip:SetText("法術名稱要顯示在哪裡?") 
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
	GameTooltip:SetText("施法條要顯示什麼顏色?") 
end)
-- naming --
vcbOptions2Box5PopOut2Choice0.Text:SetText("預設顏色")
vcbOptions2Box5PopOut2Choice1.Text:SetText("職業顏色")
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
-- Box 6, Icon --
-- Pop Out Button 1, Icon, visibility --
-- drop down --
vcbClickPopOut(vcbOptions2Box6PopOut1, vcbOptions2Box6PopOut1Choice0)
-- enter --
vcbOptions2Box6PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示法術圖示?") 
end)
-- leave --
vcbOptions2Box6PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions2Box6PopOut1Choice"..i]:SetParent(vcbOptions2Box6PopOut1Choice0)
	_G["vcbOptions2Box6PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions2Box6PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- naming --
vcbOptions2Box6PopOut1Choice0.Text:SetText("顯示圖示 & 盾牌")
vcbOptions2Box6PopOut1Choice1.Text:SetText("隱藏圖示 & 盾牌")
vcbOptions2Box6PopOut1Choice2.Text:SetText("只隱藏圖示")
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions2Box6PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrTarget["Icon"] = self.Text:GetText()
			vcbOptions2Box6PopOut1.Text:SetText(self:GetText())
			vcbOptions2Box6PopOut1Choice0:Hide()
			IconShieldVisibility()
		end
	end)
end
TargetFrame.CBpreview:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions2Box1CheckButton1:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions2Box1Slider1.Slider:SetScript("OnLeave", vcbLeavingMenus)
vcbOptions2Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
vcbClickPopOut(vcbOptions2Box1PopOut1, vcbOptions2Box1PopOut1Choice0)
-- leave choice 1 --
vcbOptions2Box1PopOut1Choice1:SetScript("OnLeave", vcbLeavingMenus)
-- leave --
vcbOptions2Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box2PopOut1, vcbOptions2Box2PopOut1Choice0)
-- leave --
vcbOptions2Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box2PopOut2, vcbOptions2Box2PopOut2Choice0)
-- leave --
vcbOptions2Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box2PopOut3, vcbOptions2Box2PopOut3Choice0)
-- leave --
vcbOptions2Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box2PopOut4, vcbOptions2Box2PopOut4Choice0)
-- leave --
vcbOptions2Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box3PopOut1, vcbOptions2Box3PopOut1Choice0)
-- leave --
vcbOptions2Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box3PopOut2, vcbOptions2Box3PopOut2Choice0)
-- leave --
vcbOptions2Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box3PopOut3, vcbOptions2Box3PopOut3Choice0)
-- leave --
vcbOptions2Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box3PopOut4, vcbOptions2Box3PopOut4Choice0)
-- leave --
vcbOptions2Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box4PopOut1, vcbOptions2Box4PopOut1Choice0)
-- leave --
vcbOptions2Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box4PopOut2, vcbOptions2Box4PopOut2Choice0)
-- leave --
vcbOptions2Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box4PopOut3, vcbOptions2Box4PopOut3Choice0)
-- leave --
vcbOptions2Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box5PopOut1, vcbOptions2Box5PopOut1Choice0)
-- leave --
vcbOptions2Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions2Box5PopOut2, vcbOptions2Box5PopOut2Choice0)
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
	if vcbOptions5:IsShown() then vcbOptions5:Hide() end
	if vcbOptions6:IsShown() then vcbOptions6:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab5.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab6.Text:SetTextColor(vcbMainColor:GetRGB())
end)
-- Hiding the panel --
vcbOptions2:SetScript("OnHide", function(self)
	if TargetFrame.CBpreview:IsShown() then TargetFrame.CBpreview:Hide() end
end)
