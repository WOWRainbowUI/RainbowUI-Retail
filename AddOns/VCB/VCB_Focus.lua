-- function for the texts --
local function VCBtexts(var1)
	var1:SetFontObject("SystemFont_Shadow_Small")
	var1:SetHeight(TargetFrameSpellBar.Text:GetHeight())
	var1:Hide()
end
-- Name Text --
local VCBnameText = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBnameText)
-- Current Time Text --
local VCBcurrentTimeText = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBcurrentTimeText)
-- Total Time Text --
local VCBtotalTimeText = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBtotalTimeText)
-- Both Time Text --
local VCBbothTimeText = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBbothTimeText)
-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrFocus[var1] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrFocus[var1]["Position"] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.barType == "standard" then
		if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
			end
		elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
			end
		end
		if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
			end
		elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
			end
		end
	elseif self.barType == "channel" then
		if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
			end
		elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
			end
		end
		if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
			elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
			end
		elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
			elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				local VCBdescending = self.maxValue - self.value
				VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
			end
		end
	end
end
-- coloring the bar --
local function CastBarColor(self)
	if VCBrFocus["Color"] == "預設顏色" then
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	elseif VCBrFocus["Color"] == "職業顏色" then
		self:SetStatusBarDesaturated(true)
		self:SetStatusBarColor(vcbClassColorFocus:GetRGB())
	end
end
-- Hooking Time part 1 --
FocusFrameSpellBar:HookScript("OnShow", function(self)
	NameTextPosition(self, "NameText", VCBnameText)
	CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeText)
	CastingTextPosition(self, "BothTimeText", VCBbothTimeText)
	CastingTextPosition(self, "TotalTimeText", VCBtotalTimeText)
end)
-- Hooking Time part 2 --
FocusFrameSpellBar:HookScript("OnUpdate", function(self)
	self.Text:SetAlpha(0)
	VCBnameText:SetText(self.Text:GetText())
	AscendingDescendingSec(self)
	CastBarColor(self)
	if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
		VCBtotalTimeText:SetFormattedText("%.1f 秒", self.maxValue)
	elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
		VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
	end
	if VCBrFocus["Unlock"] then
		self:SetIgnoreParentAlpha(true)
		self:SetAlpha(1)
		self:SetScale(VCBrFocus["Scale"]/100)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
	elseif not VCBrFocus["Unlock"] then
		self:SetIgnoreParentAlpha(false)
		self:SetScale(1)
		self:ClearAllPoints()
		if self:IsUserPlaced() then self:SetUserPlaced(false) end
	end
end)
