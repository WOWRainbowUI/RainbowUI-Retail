-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrPlayer[var1] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrPlayer[var1]["Position"] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" or VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" or VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
			end
		end
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" or VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" or VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
			end
		end
	elseif self.channeling then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" or VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" or VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
			end
		end
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "倒數" or VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "倒數" or VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
			end
		end
	end
end
-- coloring the bar --
local function PlayerColorCastBar()
	if VCBrPlayer["Color"] == "預設顏色" then
		PlayerCastingBarFrame:SetStatusBarDesaturated(false)
		PlayerCastingBarFrame:SetStatusBarColor(1, 1, 1, 1)
	elseif VCBrPlayer["Color"] == "職業顏色" then
		PlayerCastingBarFrame:SetStatusBarDesaturated(true)
		PlayerCastingBarFrame:SetStatusBarColor(vcbClassColor:GetRGB())
	end
end
-- Hooking Time part 1 --
PlayerCastingBarFrame:HookScript("OnShow", function(self)
	if VCBrPlayer["Icon"] == "左" then
		if not self.Icon:IsShown() then self.Icon:Show() end
		if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
	elseif VCBrPlayer["Icon"] == "右" then
		if self.Icon:IsShown() then self.Icon:Hide() end
		if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
		VCBiconSpell:SetTexture(PlayerCastingBarFrame.Icon:GetTextureFileID())
	elseif VCBrPlayer["Icon"] == "左和右" then
		if not self.Icon:IsShown() then self.Icon:Show() end
		if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
		VCBiconSpell:SetTexture(PlayerCastingBarFrame.Icon:GetTextureFileID())
	elseif VCBrPlayer["Icon"] == "隱藏" then
		if self.Icon:IsShown() then self.Icon:Hide() end
		if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
	end
	NameTextPosition(self, "NameText", VCBnameText)
	CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeText)
	CastingTextPosition(self, "BothTimeText", VCBbothTimeText)
	CastingTextPosition(self, "TotalTimeText", VCBtotalTimeText)
end)
-- Hooking Time part 2 --
PlayerCastingBarFrame:HookScript("OnUpdate", function(self)
	self.Text:SetAlpha(0)
	PlayerColorCastBar()
	AscendingDescendingSec(self)
	if VCBrPlayer["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
		VCBtotalTimeText:SetFormattedText("%.1f 秒", self.maxValue)
	elseif VCBrPlayer["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
		VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
	end
	VCBnameText:SetText(self.Text:GetText())
	if VCBrPlayer["Ticks"] == "顯示" then vcbShowTicks(VCBarg3)
	else vcbHideTicks()
	end
end)
