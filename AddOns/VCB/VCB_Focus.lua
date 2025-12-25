-- Blizzard Focus Castbar --
local function FocusSpellBarTexts()
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(FocusFrameSpellBar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	VCBnameTextFocus = FocusFrameSpellBar:CreateFontString("VCBnameTextFocus", "OVERLAY", nil)
	VCBtexts(VCBnameTextFocus)
-- Current Time Text --
	VCBcurrentTimeTextFocus = FocusFrameSpellBar:CreateFontString("VCBcurrentTimeTextFocus", "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeTextFocus)
-- Total Time Text --
	VCBtotalTimeTextFocus = FocusFrameSpellBar:CreateFontString("VCBtotalTimeTextFocus", "OVERLAY", nil)
	VCBtexts(VCBtotalTimeTextFocus)
-- Both Time Text --
	VCBbothTimeTextFocus = FocusFrameSpellBar:CreateFontString("VCBbothTimeTextFocus", "OVERLAY", nil)
	VCBtexts(VCBbothTimeTextFocus)
end
-- SUF Target Castbar --
local function sufFocusSpellBarTexts()
-- castbar --
	SUFUnitfocusvcbCastbar = CreateFrame("StatusBar", "SUFUnitfocusvcbCastbar", SUFUnitfocus, "SmallCastingBarFrameTemplate")
	SUFUnitfocusvcbCastbar:SetSize(150, 10)
	SUFUnitfocusvcbCastbar:ClearAllPoints()
	SUFUnitfocusvcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
	SUFUnitfocusvcbCastbar:SetScale(VCBrFocus["Scale"]/100)
	SUFUnitfocusvcbCastbar:OnLoad("focus", true, true)
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFUnitfocusvcbCastbar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	VCBnameTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBnameTextFocus", "OVERLAY", nil)
	VCBtexts(VCBnameTextFocus)
-- Current Time Text --
	VCBcurrentTimeTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBcurrentTimeTextFocus", "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeTextFocus)
-- Total Time Text --
	VCBtotalTimeTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBtotalTimeTextFocus", "OVERLAY", nil)
	VCBtexts(VCBtotalTimeTextFocus)
-- Both Time Text --
	VCBbothTimeTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBbothTimeTextFocus", "OVERLAY", nil)
	VCBtexts(VCBbothTimeTextFocus)
end
-- Icon --
function chkFocusIconVisibility()
	if VCBrFocus["Icon"] == "顯示圖示 & 盾牌" then
		function vcbFocusIconVisibility(self)
			if not self.Icon:IsShown() then self.Icon:Show() end
			if not self.showShield then self.showShield = true end
		end
	elseif VCBrFocus["Icon"] == "隱藏圖示 & 盾牌" then
		function vcbFocusIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if self.showShield then self.showShield = false end
		end
	elseif VCBrFocus["Icon"] == "只隱藏圖示" then
		function vcbFocusIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if not self.showShield then self.showShield = true end
		end
	end
end
-- Name position --
function chkFocusNamePosition()
	if VCBrFocus["NameText"] == "左上" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			VCBnameTextFocus:SetJustifyH("LEFT")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "左" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("LEFT", self, "LEFT", 4, 0)
			VCBnameTextFocus:SetJustifyH("LEFT")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "左下" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			VCBnameTextFocus:SetJustifyH("LEFT")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "上" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("BOTTOM", self, "TOP", 0, -2)
			VCBnameTextFocus:SetJustifyH("CENTER")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "中" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("CENTER", self, "CENTER", 0, 0)
			VCBnameTextFocus:SetJustifyH("CENTER")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "下" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("TOP", self, "BOTTOM", 0, 1)
			VCBnameTextFocus:SetJustifyH("CENTER")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "右上" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			VCBnameTextFocus:SetJustifyH("RIGHT")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "右" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			VCBnameTextFocus:SetJustifyH("RIGHT")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "右下" then
		function vcbFocusNamePosition(self)
			VCBnameTextFocus:ClearAllPoints()
			VCBnameTextFocus:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			VCBnameTextFocus:SetJustifyH("RIGHT")
			if not VCBnameTextFocus:IsShown() then VCBnameTextFocus:Show() end
		end
	elseif VCBrFocus["NameText"] == "隱藏" then
		function vcbFocusNamePosition(self)
			if VCBnameTextFocus:IsShown() then VCBnameTextFocus:Hide() end
		end
	end
end
-- Current time position --
function chkFocusCurrentTimePosition()
	if VCBrFocus["CurrentTimeText"]["Position"] == "左上" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "左" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "左下" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "上" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "中" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "下" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "右上" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "右" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "右下" then
		function vcbFocusCurrentTimePosition(self)
			VCBcurrentTimeTextFocus:ClearAllPoints()
			VCBcurrentTimeTextFocus:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Show() end
		end
	elseif VCBrFocus["CurrentTimeText"]["Position"] == "隱藏" then
		function vcbFocusCurrentTimePosition(self)
			if VCBcurrentTimeTextFocus:IsShown() then VCBcurrentTimeTextFocus:Hide() end
		end
	end
end
-- Both time position --
function chkFocusBothTimePosition()
	if VCBrFocus["BothTimeText"]["Position"] == "左上" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "左" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "左下" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "上" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "中" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "下" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "右上" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "右" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "右下" then
		function vcbFocusBothTimePosition(self)	
			VCBbothTimeTextFocus:ClearAllPoints()
			VCBbothTimeTextFocus:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Show() end
		end
	elseif VCBrFocus["BothTimeText"]["Position"] == "隱藏" then
		function vcbFocusBothTimePosition(self)	
			if VCBbothTimeTextFocus:IsShown() then VCBbothTimeTextFocus:Hide() end
		end
	end
end
-- Total Time position --
function chkFocusTotalTimePosition()
	if VCBrFocus["TotalTimeText"]["Position"] == "左上" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "左" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "左下" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "上" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "中" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "下" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "右上" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "右" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "右下" then
		function vcbFocusTotalTimePosition(self)
			VCBtotalTimeTextFocus:ClearAllPoints()
			VCBtotalTimeTextFocus:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Show() end
		end
	elseif VCBrFocus["TotalTimeText"]["Position"] == "隱藏" then
		function vcbFocusTotalTimePosition(self)
			if VCBtotalTimeTextFocus:IsShown() then VCBtotalTimeTextFocus:Hide() end
		end
	end
end
-- Current time update --
function chkFocusCurrentTimeUpdate()
	if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", self.value)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbFocusCurrentTimeUpdate(self)
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", self.value)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextFocus:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbFocusCurrentTimeUpdate(self)
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", self.value)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbFocusCurrentTimeUpdate(self)
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", self.value)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextFocus:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbFocusCurrentTimeUpdate(self)
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", self.value)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbFocusCurrentTimeUpdate(self)
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", self.value)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbFocusCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextFocus:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbFocusCurrentTimeUpdate(self)
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- Both time update --
function chkFocusBothTimeUpdate()
	if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
		if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				function vcbFocusBothTimeUpdate(self)
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				function vcbFocusBothTimeUpdate(self)
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
		if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				function vcbFocusBothTimeUpdate(self)
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				function vcbFocusBothTimeUpdate(self)
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
		if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				function vcbFocusBothTimeUpdate(self)
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrFocus["BothTimeText"]["Direction"] == "正數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
				function vcbFocusBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
				function vcbFocusBothTimeUpdate(self)
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- Total time update --
function chkFocusTotalTimeUpdate()
	if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" then
		if VCBrFocus["TotalTimeText"]["Decimals"] == 2 then
			function vcbFocusTotalTimeUpdate(self)
				VCBtotalTimeTextFocus:SetFormattedText("%.2f 秒", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 1 then
			function vcbFocusTotalTimeUpdate(self)
				VCBtotalTimeTextFocus:SetFormattedText("%.1f 秒", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 0 then
			function vcbFocusTotalTimeUpdate(self)
				VCBtotalTimeTextFocus:SetFormattedText("%.0f 秒", self.maxValue)
			end
		end
	elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" then
		if VCBrFocus["TotalTimeText"]["Decimals"] == 2 then
			function vcbFocusTotalTimeUpdate(self)
				VCBtotalTimeTextFocus:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 1 then
			function vcbFocusTotalTimeUpdate(self)
				VCBtotalTimeTextFocus:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 0 then
			function vcbFocusTotalTimeUpdate(self)
				VCBtotalTimeTextFocus:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- Coloring the bar --
function chkFocusCastbarColor()
	if VCBrFocus["Color"] == "預設顏色" then
		function vcbFocusCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	elseif VCBrFocus["Color"] == "職業顏色" then
		function vcbFocusCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(vcbClassColorFocus:GetRGB())
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	end
end
-- Position of  the bar --
function vcbFocusCastbarPosition(self)
	self:SetScale(VCBrFocus["Scale"]/100)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		if VCBrFocus["otherAdddon"] == "無" then
			FocusSpellBarTexts()
			if VCBrFocus["Unlock"] then
				FocusFrameSpellBar:HookScript("OnUpdate", function(self)
					vcbFocusCastbarPosition(self)
				end)
			end
		elseif VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" then
			sufFocusSpellBarTexts()
			SUFUnitfocusvcbCastbar:HookScript("OnUpdate", function(self)
				vcbFocusCastbarPosition(self)
			end)
		end
		chkFocusIconVisibility()
		chkFocusNamePosition()
		chkFocusCurrentTimePosition()
		chkFocusBothTimePosition()
		chkFocusTotalTimePosition()
		chkFocusCurrentTimeUpdate()
		chkFocusBothTimeUpdate()
		chkFocusTotalTimeUpdate()
		chkFocusCastbarColor()
		if VCBrFocus["otherAdddon"] == "無" then
			FocusFrameSpellBar:HookScript("OnShow", function(self)
				VCBnameTextFocus:SetWidth(self:GetWidth())
				vcbFocusIconVisibility(self)
				vcbFocusNamePosition(self)
				vcbFocusCurrentTimePosition(self)
				vcbFocusBothTimePosition(self)
				vcbFocusTotalTimePosition(self)
			end)
			FocusFrameSpellBar:HookScript("OnUpdate", function(self)
				self.Text:SetAlpha(0)
				VCBnameTextFocus:SetText(self.Text:GetText())
				if self.value ~= nil and self.maxValue ~= nil then
					vcbFocusCurrentTimeUpdate(self)
					vcbFocusBothTimeUpdate(self)
					vcbFocusTotalTimeUpdate(self)
					vcbFocusCastbarColor(self)
				end
			end)
		elseif VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" then
			SUFUnitfocusvcbCastbar:HookScript("OnShow", function(self)
				VCBnameTextFocus:SetWidth(self:GetWidth())
				vcbFocusIconVisibility(self)
				vcbFocusNamePosition(self)
				vcbFocusCurrentTimePosition(self)
				vcbFocusBothTimePosition(self)
				vcbFocusTotalTimePosition(self)
			end)
			SUFUnitfocusvcbCastbar:HookScript("OnUpdate", function(self)
				self.Text:SetAlpha(0)
				VCBnameTextFocus:SetText(self.Text:GetText())
				if self.value ~= nil and self.maxValue ~= nil then
					vcbFocusCurrentTimeUpdate(self)
					vcbFocusBothTimeUpdate(self)
					vcbFocusTotalTimeUpdate(self)
					vcbFocusCastbarColor(self)
				end
			end)
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if FocusFrame:IsShown() then
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnitfocus ~= nil and VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" and SUFUnitfocus:IsShown() then
			SUFUnitfocusvcbCastbar:SetUnit(nil, true, true)
			SUFUnitfocusvcbCastbar:PlayFinishAnim()
			SUFUnitfocusvcbCastbar:SetUnit("focus", true, true)
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
