-- function for the texts --
local function VCBtexts(var1)
	var1:SetFontObject("SystemFont_Shadow_Small")
	var1:SetHeight(FocusFrameSpellBar.Text:GetHeight())
	var1:Hide()
end
-- Name Text --
local VCBnameText = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBnameText)
-- Current Time Text --
local VCBcurrentTimeText = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBcurrentTimeText)
-- Total Time Text --
local VCBtotalTimeText = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBtotalTimeText)
-- Both Time Text --
local VCBbothTimeText = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
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
	if self.casting then
		if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
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
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
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
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
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
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
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
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	end
end
-- coloring the bar --
local function CastBarColor(self)
	if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
		if VCBrFocus["Color"] == "預設顏色" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrFocus["Color"] == "職業顏色" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorFocus:GetRGB())
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
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
	if VCBrFocus["TotalTimeText"]["Decimals"] == 2 then
		if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.2f 秒", self.maxValue)
		elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
		end
	elseif VCBrFocus["TotalTimeText"]["Decimals"] == 1 then
		if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.1f 秒", self.maxValue)
		elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
		end
	elseif VCBrFocus["TotalTimeText"]["Decimals"] == 0 then
		if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.0f 秒", self.maxValue)
		elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
		end
	end
end)
