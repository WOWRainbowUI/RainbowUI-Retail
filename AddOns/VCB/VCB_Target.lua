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
	if VCBrTarget[var1] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrTarget[var1]["Position"] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
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
		if VCBrTarget["Color"] == "預設顏色" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrTarget["Color"] == "職業顏色" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorTarget:GetRGB())
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	end
end
-- Hooking Time part 1 --
TargetFrameSpellBar:HookScript("OnShow", function(self)
	NameTextPosition(self, "NameText", VCBnameText)
	CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeText)
	CastingTextPosition(self, "BothTimeText", VCBbothTimeText)
	CastingTextPosition(self, "TotalTimeText", VCBtotalTimeText)
end)
-- Hooking Time part 2 --
TargetFrameSpellBar:HookScript("OnUpdate", function(self)
	self.Text:SetAlpha(0)
	VCBnameText:SetText(self.Text:GetText())
	AscendingDescendingSec(self)
	CastBarColor(self)
	if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
		if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.2f 秒", self.maxValue)
		elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
		end
	elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
		if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.1f 秒", self.maxValue)
		elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
		end
	elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
		if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.0f 秒", self.maxValue)
		elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
			VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
		end
	end
end)
