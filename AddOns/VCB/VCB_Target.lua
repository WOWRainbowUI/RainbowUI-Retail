-- Blizzard Target Castbar --
local function TargetSpellBarTexts()
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(TargetFrameSpellBar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	VCBnameTextTarget = TargetFrameSpellBar:CreateFontString("VCBnameTextTarget", "OVERLAY", nil)
	VCBtexts(VCBnameTextTarget)
-- Current Time Text --
	VCBcurrentTimeTextTarget = TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeTextTarget)
-- Total Time Text --
	VCBtotalTimeTextTarget = TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBtotalTimeTextTarget)
-- Both Time Text --
	VCBbothTimeTextTarget = TargetFrameSpellBar:CreateFontString("VCBbothTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBbothTimeTextTarget)
end
-- SUF Target Castbar --
local function sufTargetSpellBarTexts()
-- castbar --
	SUFUnittargetvcbCastbar = CreateFrame("StatusBar", "SUFUnittargetvcbCastbar", SUFUnittarget, "SmallCastingBarFrameTemplate")
	SUFUnittargetvcbCastbar:SetSize(150, 10)
	SUFUnittargetvcbCastbar:ClearAllPoints()
	SUFUnittargetvcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	SUFUnittargetvcbCastbar:SetScale(VCBrTarget["Scale"]/100)
	SUFUnittargetvcbCastbar:OnLoad("target", true, true)
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFUnittargetvcbCastbar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	VCBnameTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBnameTextTarget", "OVERLAY", nil)
	VCBtexts(VCBnameTextTarget)
-- Current Time Text --
	VCBcurrentTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBcurrentTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeTextTarget)
-- Total Time Text --
	VCBtotalTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBtotalTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBtotalTimeTextTarget)
-- Both Time Text --
	VCBbothTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBbothTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBbothTimeTextTarget)
end
-- Icon --
function chkTargetIconVisibility()
	if VCBrTarget["Icon"] == "顯示圖示 & 盾牌" then
		function vcbTargetIconVisibility(self)
			if not self.Icon:IsShown() then self.Icon:Show() end
			if not self.showShield then self.showShield = true end
		end
	elseif VCBrTarget["Icon"] == "隱藏圖示 & 盾牌" then
		function vcbTargetIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if self.showShield then self.showShield = false end
		end
	elseif VCBrTarget["Icon"] == "只顯示圖示" then
		function vcbTargetIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if not self.showShield then self.showShield = true end
		end
	end
end
-- Name position --
function chkTargetNamePosition()
	if VCBrTarget["NameText"] == "左上" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			VCBnameTextTarget:SetJustifyH("LEFT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "左" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			VCBnameTextTarget:SetJustifyH("LEFT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "左下" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			VCBnameTextTarget:SetJustifyH("LEFT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "上" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			VCBnameTextTarget:SetJustifyH("CENTER")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "中" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			VCBnameTextTarget:SetJustifyH("CENTER")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "下" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			VCBnameTextTarget:SetJustifyH("CENTER")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "右上" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			VCBnameTextTarget:SetJustifyH("RIGHT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "右" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			VCBnameTextTarget:SetJustifyH("RIGHT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "右下" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			VCBnameTextTarget:SetJustifyH("RIGHT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "隱藏" then
		function vcbTargetNamePosition(self)
			if VCBnameTextTarget:IsShown() then VCBnameTextTarget:Hide() end
		end
	end
end
-- Current time position --
function chkTargetCurrentTimePosition()
	if VCBrTarget["CurrentTimeText"]["Position"] == "左上" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "左" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "左下" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "上" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "中" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "下" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "右上" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "右" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "右下" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "隱藏" then
		function vcbTargetCurrentTimePosition(self)
			if VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Hide() end
		end
	end
end
-- Both time position --
function chkTargetBothTimePosition()
	if VCBrTarget["BothTimeText"]["Position"] == "左上" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "左" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "左下" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "上" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "中" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "下" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "右上" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "右" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "右下" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "隱藏" then
		function vcbTargetBothTimePosition(self)	
			if VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Hide() end
		end
	end
end
-- Total Time position --
function chkTargetTotalTimePosition()
	if VCBrTarget["TotalTimeText"]["Position"] == "左上" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "左" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "左下" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "上" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "中" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "下" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "右上" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "右" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "右下" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "隱藏" then
		function vcbTargetTotalTimePosition(self)
			if VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Hide() end
		end
	end
end
-- Current time update --
function chkTargetCurrentTimeUpdate()
	if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", self.value)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", self.value)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", self.value)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- Both time update --
function chkTargetBothTimeUpdate()
	if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
		if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
			if VCBrTarget["BothTimeText"]["Direction"] == "正數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrTarget["BothTimeText"]["Direction"] == "正數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
		if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
			if VCBrTarget["BothTimeText"]["Direction"] == "正數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrTarget["BothTimeText"]["Direction"] == "正數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
		if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
			if VCBrTarget["BothTimeText"]["Direction"] == "正數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrTarget["BothTimeText"]["Direction"] == "正數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- Total time update --
function chkTargetTotalTimeUpdate()
	if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" then
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.2f 秒", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.1f 秒", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.0f 秒", self.maxValue)
			end
		end
	elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" then
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- Coloring the bar --
function chkTargetCastbarColor()
	if VCBrTarget["Color"] == "預設顏色" then
		function vcbTargetCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	elseif VCBrTarget["Color"] == "職業顏色" then
		function vcbTargetCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(vcbClassColorTarget:GetRGB())
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	end
end
-- Position of  the bar --
function vcbTargetCastbarPosition(self)
	self:SetScale(VCBrTarget["Scale"]/100)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		if VCBrTarget["otherAdddon"] == "無" then
			TargetSpellBarTexts()
			if VCBrTarget["Unlock"] then
				TargetFrameSpellBar:HookScript("OnUpdate", function(self)
					vcbTargetCastbarPosition(self)
				end)
			end
		elseif VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			sufTargetSpellBarTexts()
			SUFUnittargetvcbCastbar:HookScript("OnUpdate", function(self)
				vcbTargetCastbarPosition(self)
			end)
		end
			chkTargetIconVisibility()
			chkTargetNamePosition()
			chkTargetCurrentTimePosition()
			chkTargetBothTimePosition()
			chkTargetTotalTimePosition()
			chkTargetCurrentTimeUpdate()
			chkTargetBothTimeUpdate()
			chkTargetTotalTimeUpdate()
			chkTargetCastbarColor()
		if VCBrTarget["otherAdddon"] == "無" then
			TargetFrameSpellBar:HookScript("OnShow", function(self)
				VCBnameTextTarget:SetWidth(self:GetWidth())
				vcbTargetNamePosition(self)
				vcbTargetCurrentTimePosition(self)
				vcbTargetBothTimePosition(self)
				vcbTargetTotalTimePosition(self)
			end)
			TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self.Text:SetAlpha(0)
				VCBnameTextTarget:SetText(self.Text:GetText())
				if self.value ~= nil and self.maxValue ~= nil then
					vcbTargetCurrentTimeUpdate(self)
					vcbTargetBothTimeUpdate(self)
					vcbTargetTotalTimeUpdate(self)
					vcbTargetCastbarColor(self)
				end
			end)
		elseif VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			SUFUnittargetvcbCastbar:HookScript("OnShow", function(self)
				VCBnameTextTarget:SetWidth(self:GetWidth())
				vcbTargetNamePosition(self)
				vcbTargetCurrentTimePosition(self)
				vcbTargetBothTimePosition(self)
				vcbTargetTotalTimePosition(self)
			end)
			SUFUnittargetvcbCastbar:HookScript("OnUpdate", function(self)
				self.Text:SetAlpha(0)
				VCBnameTextTarget:SetText(self.Text:GetText())
				if self.value ~= nil and self.maxValue ~= nil then
					vcbTargetCurrentTimeUpdate(self)
					vcbTargetBothTimeUpdate(self)
					vcbTargetTotalTimeUpdate(self)
					vcbTargetCastbarColor(self)
				end
			end)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if TargetFrame:IsShown() then
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnittarget ~= nil and VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" and SUFUnittarget:IsShown() then
			SUFUnittargetvcbCastbar:SetUnit(nil, true, true)
			SUFUnittargetvcbCastbar:PlayFinishAnim()
			SUFUnittargetvcbCastbar:SetUnit("target", true, true)
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
