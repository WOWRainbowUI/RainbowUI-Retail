-- taking care of the panel --
vcbOptions1.TopTxt:SetText("玩家施法條選項!")
-- naming the boxes --
vcbOptions1Box1.TitleTxt:SetText("法術圖示 & 法術名稱")
vcbOptions1Box2.TitleTxt:SetText("目前施法時間")
vcbOptions1Box3.TitleTxt:SetText("目前 & 總共施法時間")
vcbOptions1Box4.TitleTxt:SetText("總共施法時間")
vcbOptions1Box5.TitleTxt:SetText("延遲標示 & 排隊圖示")
vcbOptions1Box6.TitleTxt:SetText("共用冷卻 & 施法斷點")
vcbOptions1Box7.TitleTxt:SetText("施法條顏色")
-- positioning the boxes --
vcbOptions1Box2:SetPoint("TOPLEFT", vcbOptions1Box1, "TOPRIGHT", 0, 0)
vcbOptions1Box3:SetPoint("TOPLEFT", vcbOptions1Box1, "BOTTOMLEFT", 0, 0)
vcbOptions1Box4:SetPoint("TOPRIGHT", vcbOptions1Box2, "BOTTOMRIGHT", 0, 0)
vcbOptions1Box5:SetPoint("TOPLEFT", vcbOptions1Box3, "BOTTOMLEFT", 0, 0)
vcbOptions1Box6:SetPoint("TOPRIGHT", vcbOptions1Box4, "BOTTOMRIGHT", 0, 0)
vcbOptions1Box7:SetPoint("TOPLEFT", vcbOptions1Box5, "BOTTOMLEFT", 0, 0)
-- Checking the Saved Variables --
local function CheckSavedVariables()
	vcbOptions1Box1PopOut1:SetText(VCBrPlayer["Icon"])
	vcbOptions1Box1PopOut2:SetText(VCBrPlayer["NameText"])
	vcbOptions1Box2PopOut1:SetText(VCBrPlayer["CurrentTimeText"]["Position"])
	vcbOptions1Box2PopOut2:SetText(VCBrPlayer["CurrentTimeText"]["Direction"])
	vcbOptions1Box2PopOut3:SetText(VCBrPlayer["CurrentTimeText"]["Sec"])
	vcbOptions1Box2PopOut4:SetText(VCBrPlayer["CurrentTimeText"]["Decimals"])
	vcbOptions1Box3PopOut1:SetText(VCBrPlayer["BothTimeText"]["Position"])
	vcbOptions1Box3PopOut2:SetText(VCBrPlayer["BothTimeText"]["Direction"])
	vcbOptions1Box3PopOut3:SetText(VCBrPlayer["BothTimeText"]["Sec"])
	vcbOptions1Box3PopOut4:SetText(VCBrPlayer["BothTimeText"]["Decimals"])
	vcbOptions1Box4PopOut1:SetText(VCBrPlayer["TotalTimeText"]["Position"])
	vcbOptions1Box4PopOut2:SetText(VCBrPlayer["TotalTimeText"]["Sec"])
	vcbOptions1Box4PopOut3:SetText(VCBrPlayer["TotalTimeText"]["Decimals"])
	vcbOptions1Box5PopOut1:SetText(VCBrPlayer["LagBar"])
	vcbOptions1Box5PopOut2:SetText(VCBrPlayer["QueueBar"])
	vcbOptions1Box6PopOut1:SetText(VCBrPlayer["Ticks"])
	vcbOptions1Box6PopOut2:SetText(VCBrPlayer["GCD"]["ClassicTexture"])
	vcbOptions1Box7PopOut1:SetText(VCBrPlayer["Color"])
end
-- icon & shield --
local function IconShieldVisibility()
	PlayerCastingBarFrame.Icon:SetScale(1.3)
	if PlayerCastingBarFrame.showShield then PlayerCastingBarFrame.showShield = false end
	if VCBrPlayer["Icon"] == "左" then
		function vcbPlayerIconVisibility(self)
			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -4)
			if not self.Icon:IsShown() then self.Icon:Show() end
			if self.barType == "uninterruptable" then
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -8, -4)
				if not VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Show() end
			else
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -4)
				if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
			end
			if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
			if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
		end
	elseif VCBrPlayer["Icon"] == "右" then
		function vcbPlayerIconVisibility(self)
			VCBiconSpell:ClearAllPoints()
			VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
			VCBiconSpell:SetTexture(self.Icon:GetTextureFileID())
			if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
			if self.barType == "uninterruptable" then
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 8, -4)
				if not VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Show() end
			else
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
				if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
			end
			if self.Icon:IsShown() then self.Icon:Hide() end
			if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
		end
	elseif VCBrPlayer["Icon"] == "左和右" then
		function vcbPlayerIconVisibility(self)
			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -4)
			if not self.Icon:IsShown() then self.Icon:Show() end
			VCBiconSpell:ClearAllPoints()
			VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
			VCBiconSpell:SetTexture(self.Icon:GetTextureFileID())
			if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
			VCBiconSpell:SetTexture(self.Icon:GetTextureFileID())
			if self.barType == "uninterruptable" then
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -8, -4)
				if not VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Show() end
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 8, -4)
				if not VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Show() end
			else
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -4)
				if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
				if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
			end
		end
	elseif VCBrPlayer["Icon"] == "隱藏" then
		function vcbPlayerIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
			if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
			if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
		end
	end
end
-- Name position --
local function NamePosition()
	if VCBrPlayer["NameText"] == "左上" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "左" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "左下" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "上" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "中" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "下" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "右上" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "右" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "右下" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "隱藏" then
		function vcbPlayerNamePosition(self)
			if VCBnameText:IsShown() then VCBnameText:Hide() end
		end
	end
end
-- Current Time position --
local function CurrentTimePosition()
	if VCBrPlayer["CurrentTimeText"]["Position"] == "左上" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "左" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "左下" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "上" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "中" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "下" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "右上" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "右" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "右下" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "隱藏" then
		function vcbPlayerCurrentTimePosition(self)
			if VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Hide() end
		end
	end
end
-- Both Time position --
local function BothTimePosition()
	if VCBrPlayer["BothTimeText"]["Position"] == "左上" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "左" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "左下" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "上" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "中" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "下" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "右上" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "右" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "右下" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "隱藏" then
		function vcbPlayerBothTimePosition(self)
			if VCBbothTimeText:IsShown() then VCBbothTimeText:Hide() end
		end
	end
end
-- Total Time position --
local function TotalTimePosition()
	if VCBrPlayer["TotalTimeText"]["Position"] == "左上" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "左" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "左下" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "上" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "中" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "下" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "右上" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "右" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "右下" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "隱藏" then
		function vcbPlayerTotalTimePosition(self)
			if VCBtotalTimeText:IsShown() then VCBtotalTimeText:Hide() end
		end
	end
end
-- current time update --
local function CurrentTimeUpdate()
	if VCBrPlayer["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- both time update --
local function BothTimeUpdate()
	if VCBrPlayer["BothTimeText"]["Decimals"] == 2 then
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrPlayer["BothTimeText"]["Decimals"] == 1 then
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrPlayer["BothTimeText"]["Decimals"] == 0 then
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- total time update --
local function TotalTimeUpdate()
	if VCBrPlayer["TotalTimeText"]["Sec"] == "顯示" then
		if VCBrPlayer["TotalTimeText"]["Decimals"] == 2 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.2f 秒", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 1 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.1f 秒", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 0 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.0f 秒", self.maxValue)
			end
		end
	elseif VCBrPlayer["TotalTimeText"]["Sec"] == "隱藏" then
		if VCBrPlayer["TotalTimeText"]["Decimals"] == 2 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 1 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 0 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- Box 1 Spell's Icon and Spell's Name --
-- pop out 1 Spell's Icon --
-- drop down --
vcbClickPopOut(vcbOptions1Box1PopOut1, vcbOptions1Box1PopOut1Choice0)
-- enter --
vcbOptions1Box1PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("法術圖示要顯示在哪裡?") 
end)
-- leave --
vcbOptions1Box1PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- naming --
vcbOptions1Box1PopOut1Choice0.Text:SetText("隱藏")
vcbOptions1Box1PopOut1Choice1.Text:SetText("左")
vcbOptions1Box1PopOut1Choice2.Text:SetText("右")
vcbOptions1Box1PopOut1Choice3.Text:SetText("左和右")
-- parent & sort --
for i = 1, 3, 1 do
	_G["vcbOptions1Box1PopOut1Choice"..i]:SetParent(vcbOptions1Box1PopOut1Choice0)
	_G["vcbOptions1Box1PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box1PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 3, 1 do
	_G["vcbOptions1Box1PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Icon"] = self.Text:GetText()
			vcbOptions1Box1PopOut1.Text:SetText(self.Text:GetText())
			IconShieldVisibility()
			vcbOptions1Box1PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Spell's Name --
-- enter --
vcbOptions1Box1PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("法術名稱要顯示在哪裡?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box1PopOut2Choice"..i]:SetParent(vcbOptions1Box1PopOut2Choice0)
	_G["vcbOptions1Box1PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box1PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box1PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["NameText"] = self.Text:GetText()
			vcbOptions1Box1PopOut2.Text:SetText(self.Text:GetText())
			NamePosition()
			vcbOptions1Box1PopOut2Choice0:Hide()
		end
	end)
end
-- Box 2 Current Cast Time --
-- pop out 1 Current Cast Time --
-- enter --
vcbOptions1Box2PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("當前施法時間要顯示在哪裡?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box2PopOut1Choice"..i]:SetParent(vcbOptions1Box2PopOut1Choice0)
	_G["vcbOptions1Box2PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box2PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box2PopOut1.Text:SetText(self.Text:GetText())
			CurrentTimePosition()
			vcbOptions1Box2PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current Cast Time Direction --
-- enter --
vcbOptions1Box2PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("如何顯示時間?|n兩者表示時間在施法時為正數，在引導時為倒數!") 
end)
-- naming --
vcbOptions1Box2PopOut2Choice0.Text:SetText("正數")
vcbOptions1Box2PopOut2Choice1.Text:SetText("倒數")
vcbOptions1Box2PopOut2Choice2.Text:SetText("兩者")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box2PopOut2Choice"..i]:SetParent(vcbOptions1Box2PopOut2Choice0)
	_G["vcbOptions1Box2PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box2PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions1Box2PopOut2.Text:SetText(self.Text:GetText())
			CurrentTimeUpdate()
			vcbOptions1Box2PopOut2Choice0:Hide()
		end
	end)
end
--  pop out 3 Current Cast Time Sec? --
-- enter --
vcbOptions1Box2PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示 '秒' 這個字?") 
end)
-- naming --
vcbOptions1Box2PopOut3Choice0.Text:SetText("隱藏")
vcbOptions1Box2PopOut3Choice1.Text:SetText("顯示")
-- parent & sort --
vcbOptions1Box2PopOut3Choice1:SetParent(vcbOptions1Box2PopOut3Choice0)
vcbOptions1Box2PopOut3Choice1:SetPoint("TOP",vcbOptions1Box2PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box2PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions1Box2PopOut3.Text:SetText(self.Text:GetText())
			CurrentTimeUpdate()
			vcbOptions1Box2PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Current Cast Time Decimals --
-- enter --
vcbOptions1Box2PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("時間要顯示幾位小數") 
end)
-- naming --
vcbOptions1Box2PopOut4Choice0.Text:SetText("0")
vcbOptions1Box2PopOut4Choice1.Text:SetText("1")
vcbOptions1Box2PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box2PopOut4Choice"..i]:SetParent(vcbOptions1Box2PopOut4Choice0)
	_G["vcbOptions1Box2PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box2PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box2PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["CurrentTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions1Box2PopOut4.Text:SetText(self.Text:GetText())
			CurrentTimeUpdate()
			vcbOptions1Box2PopOut4Choice0:Hide()
		end
	end)
end
-- Box 3 Current & Total Cast Time --
-- pop out 1 Current & Total Cast Time --
-- enter --
vcbOptions1Box3PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("目前/總共時間要顯示在哪裡?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box3PopOut1Choice"..i]:SetParent(vcbOptions1Box3PopOut1Choice0)
	_G["vcbOptions1Box3PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box3PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box3PopOut1.Text:SetText(self.Text:GetText())
			BothTimePosition()
			vcbOptions1Box3PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Current & Total Cast Time Direction --
-- enter --
vcbOptions1Box3PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("如何顯示時間?|n兩者表示時間在施法時為正數，在引導時為倒數!") 
end)
-- naming --
vcbOptions1Box3PopOut2Choice0.Text:SetText("正數")
vcbOptions1Box3PopOut2Choice1.Text:SetText("倒數")
vcbOptions1Box3PopOut2Choice2.Text:SetText("兩者")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box3PopOut2Choice"..i]:SetParent(vcbOptions1Box3PopOut2Choice0)
	_G["vcbOptions1Box3PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box3PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Direction"] = self.Text:GetText()
			vcbOptions1Box3PopOut2.Text:SetText(self.Text:GetText())
			BothTimeUpdate()
			vcbOptions1Box3PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Current & Total Cast Time Sec? --
-- enter --
vcbOptions1Box3PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示 '秒' 這個字?") 
end)
-- naming --
vcbOptions1Box3PopOut3Choice0.Text:SetText("隱藏")
vcbOptions1Box3PopOut3Choice1.Text:SetText("顯示")
-- parent & sort --
vcbOptions1Box3PopOut3Choice1:SetParent(vcbOptions1Box3PopOut3Choice0)
vcbOptions1Box3PopOut3Choice1:SetPoint("TOP",vcbOptions1Box3PopOut3Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box3PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions1Box3PopOut3.Text:SetText(self.Text:GetText())
			BothTimeUpdate()
			vcbOptions1Box3PopOut3Choice0:Hide()
		end
	end)
end
-- pop out 4 Both Time Decimals --
-- enter --
vcbOptions1Box3PopOut4:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("時間要顯示幾位小數") 
end)
-- naming --
vcbOptions1Box3PopOut4Choice0.Text:SetText("0")
vcbOptions1Box3PopOut4Choice1.Text:SetText("1")
vcbOptions1Box3PopOut4Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box3PopOut4Choice"..i]:SetParent(vcbOptions1Box3PopOut4Choice0)
	_G["vcbOptions1Box3PopOut4Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box3PopOut4Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box3PopOut4Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["BothTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions1Box3PopOut4.Text:SetText(self.Text:GetText())
			BothTimeUpdate()
			vcbOptions1Box3PopOut4Choice0:Hide()
		end
	end)
end
-- Box 4 Total Cast Time --
-- pop out 1 Total Cast Time --
-- enter --
vcbOptions1Box4PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("總共施法時間要顯示在哪裡?") 
end)
-- parent & sort --
for i = 1, 9, 1 do
	_G["vcbOptions1Box4PopOut1Choice"..i]:SetParent(vcbOptions1Box4PopOut1Choice0)
	_G["vcbOptions1Box4PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box4PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- sort & clicking --
for i = 0, 9, 1 do
	_G["vcbOptions1Box4PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Position"] = self.Text:GetText()
			vcbOptions1Box4PopOut1.Text:SetText(self.Text:GetText())
			TotalTimePosition()
			vcbOptions1Box4PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Total Cast Time Sec? --
-- enter --
vcbOptions1Box4PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示 '秒' 這個字?") 
end)
-- naming --
vcbOptions1Box4PopOut2Choice0.Text:SetText("隱藏")
vcbOptions1Box4PopOut2Choice1.Text:SetText("顯示")
-- parent & sort --
vcbOptions1Box4PopOut2Choice1:SetParent(vcbOptions1Box4PopOut2Choice0)
vcbOptions1Box4PopOut2Choice1:SetPoint("TOP",vcbOptions1Box4PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box4PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Sec"] = self.Text:GetText()
			vcbOptions1Box4PopOut2.Text:SetText(self.Text:GetText())
			TotalTimeUpdate()
			vcbOptions1Box4PopOut2Choice0:Hide()
		end
	end)
end
-- pop out 3 Total Time Decimals --
-- enter --
vcbOptions1Box4PopOut3:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("時間要顯示幾位小數") 
end)
-- naming --
vcbOptions1Box4PopOut3Choice0.Text:SetText("0")
vcbOptions1Box4PopOut3Choice1.Text:SetText("1")
vcbOptions1Box4PopOut3Choice2.Text:SetText("2")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box4PopOut3Choice"..i]:SetParent(vcbOptions1Box4PopOut3Choice0)
	_G["vcbOptions1Box4PopOut3Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box4PopOut3Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box4PopOut3Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["TotalTimeText"]["Decimals"] = tonumber(self.Text:GetText())
			vcbOptions1Box4PopOut3.Text:SetText(self.Text:GetText())
			TotalTimeUpdate()
			vcbOptions1Box4PopOut3Choice0:Hide()
		end
	end)
end
-- Box 5 Lag Bar & Castbar's Color --
-- pop out 1 Lag Bar --
-- enter --
vcbOptions1Box5PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示延遲標示?") 
end)
-- naming --
vcbOptions1Box5PopOut1Choice0.Text:SetText("隱藏")
vcbOptions1Box5PopOut1Choice1.Text:SetText("顯示")
-- parent & sort --
vcbOptions1Box5PopOut1Choice1:SetParent(vcbOptions1Box5PopOut1Choice0)
vcbOptions1Box5PopOut1Choice1:SetPoint("TOP",vcbOptions1Box5PopOut1Choice0, "BOTTOM", 0, 0)
-- clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box5PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["LagBar"] = self.Text:GetText()
			vcbOptions1Box5PopOut1.Text:SetText(self.Text:GetText())
			vcbOptions1Box5PopOut1Choice0:Hide()
		end
	end)
end
-- pop out 2 Queue Bar --
-- enter --
vcbOptions1Box5PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示排隊視窗列?") 
end)
-- naming --
vcbOptions1Box5PopOut2Choice0.Text:SetText("隱藏")
vcbOptions1Box5PopOut2Choice1.Text:SetText("顯示")
-- parent & sort --
vcbOptions1Box5PopOut2Choice1:SetParent(vcbOptions1Box5PopOut2Choice0)
vcbOptions1Box5PopOut2Choice1:SetPoint("TOP",vcbOptions1Box5PopOut2Choice0, "BOTTOM", 0, 0)
-- sort & clicking --
for i = 0, 1, 1 do
	_G["vcbOptions1Box5PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["QueueBar"] = self.Text:GetText()
			vcbOptions1Box5PopOut2.Text:SetText(self.Text:GetText())
			vcbOptions1Box5PopOut2Choice0:Hide()
		end
	end)
end
-- Options Box 6 Ticks of the Spells & GCD --
-- pop out 1 Ticks of the Spells --
-- enter --
vcbOptions1Box6PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示施法斷點?|n選擇後將會重新載入介面!") 
end)
-- naming --
vcbOptions1Box6PopOut1Choice0.Text:SetText("隱藏")
vcbOptions1Box6PopOut1Choice1.Text:SetText("現代")
vcbOptions1Box6PopOut1Choice2.Text:SetText("經典")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box6PopOut1Choice"..i]:SetParent(vcbOptions1Box6PopOut1Choice0)
	_G["vcbOptions1Box6PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box6PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box6PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Ticks"] = self.Text:GetText()
			vcbOptions1Box6PopOut1.Text:SetText(self.Text:GetText())
			vcbOptions1Box6PopOut1Choice0:Hide()
			C_UI.Reload()
		end
	end)
end
-- pop out 2 Global Cooldown --
-- enter --
vcbOptions1Box6PopOut2:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("是否要顯示共用冷卻時間?") 
end)
-- naming --
vcbOptions1Box6PopOut2Choice0.Text:SetText("隱藏")
vcbOptions1Box6PopOut2Choice1.Text:SetText("職業圖示")
vcbOptions1Box6PopOut2Choice2.Text:SetText("英雄圖示")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box6PopOut2Choice"..i]:SetParent(vcbOptions1Box6PopOut2Choice0)
	_G["vcbOptions1Box6PopOut2Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box6PopOut2Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box6PopOut2Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["GCD"]["ClassicTexture"] = self.Text:GetText()
			vcbOptions1Box6PopOut2.Text:SetText(self.Text:GetText())
			vcbOptions1Box6PopOut2Choice0:Hide()
			vcbCreatingTheGCD()
		end
	end)
end
-- Box 7 Castbar's Color --
-- pop out 1 Castbar's Color --
-- enter --
vcbOptions1Box7PopOut1:SetScript("OnEnter", function(self)
	vcbEnteringMenus(self)
	GameTooltip:SetText("施法條要顯示什麼顏色?") 
end)
-- naming --
vcbOptions1Box7PopOut1Choice0.Text:SetText("預設顏色")
vcbOptions1Box7PopOut1Choice1.Text:SetText("職業顏色")
vcbOptions1Box7PopOut1Choice2.Text:SetText("法術類型顏色")
-- parent & sort --
for i = 1, 2, 1 do
	_G["vcbOptions1Box7PopOut1Choice"..i]:SetParent(vcbOptions1Box7PopOut1Choice0)
	_G["vcbOptions1Box7PopOut1Choice"..i]:SetPoint("TOP", _G["vcbOptions1Box7PopOut1Choice"..i-1], "BOTTOM", 0, 0)
end
-- clicking --
for i = 0, 2, 1 do
	_G["vcbOptions1Box7PopOut1Choice"..i]:HookScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			VCBrPlayer["Color"] = self.Text:GetText()
			vcbOptions1Box7PopOut1.Text:SetText(self.Text:GetText())
			vcbOptions1Box7PopOut1Choice0:Hide()
		end
	end)
end
-- naming button choices for spell's name, current cast time, current & total time, and total time --
for i = 1, 4, 1 do
	if i == 1 then
		_G["vcbOptions1Box"..i.."PopOut2Choice0"].Text:SetText("隱藏")
		_G["vcbOptions1Box"..i.."PopOut2Choice1"].Text:SetText("左上")
		_G["vcbOptions1Box"..i.."PopOut2Choice2"].Text:SetText("左")
		_G["vcbOptions1Box"..i.."PopOut2Choice3"].Text:SetText("左下")
		_G["vcbOptions1Box"..i.."PopOut2Choice4"].Text:SetText("上")
		_G["vcbOptions1Box"..i.."PopOut2Choice5"].Text:SetText("中")
		_G["vcbOptions1Box"..i.."PopOut2Choice6"].Text:SetText("下")
		_G["vcbOptions1Box"..i.."PopOut2Choice7"].Text:SetText("右上")
		_G["vcbOptions1Box"..i.."PopOut2Choice8"].Text:SetText("右")
		_G["vcbOptions1Box"..i.."PopOut2Choice9"].Text:SetText("右下")
	else
		_G["vcbOptions1Box"..i.."PopOut1Choice0"].Text:SetText("隱藏")
		_G["vcbOptions1Box"..i.."PopOut1Choice1"].Text:SetText("左上")
		_G["vcbOptions1Box"..i.."PopOut1Choice2"].Text:SetText("左")
		_G["vcbOptions1Box"..i.."PopOut1Choice3"].Text:SetText("左上")
		_G["vcbOptions1Box"..i.."PopOut1Choice4"].Text:SetText("上")
		_G["vcbOptions1Box"..i.."PopOut1Choice5"].Text:SetText("中")
		_G["vcbOptions1Box"..i.."PopOut1Choice6"].Text:SetText("下")
		_G["vcbOptions1Box"..i.."PopOut1Choice7"].Text:SetText("右上")
		_G["vcbOptions1Box"..i.."PopOut1Choice8"].Text:SetText("右")
		_G["vcbOptions1Box"..i.."PopOut1Choice9"].Text:SetText("右下")
	end
end
-- drop down --
vcbClickPopOut(vcbOptions1Box1PopOut2, vcbOptions1Box1PopOut2Choice0)
vcbOptions1Box1PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box2PopOut1, vcbOptions1Box2PopOut1Choice0)
vcbOptions1Box2PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box2PopOut2, vcbOptions1Box2PopOut2Choice0)
vcbOptions1Box2PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box2PopOut3, vcbOptions1Box2PopOut3Choice0)
vcbOptions1Box2PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box2PopOut4, vcbOptions1Box2PopOut4Choice0)
vcbOptions1Box2PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box3PopOut1, vcbOptions1Box3PopOut1Choice0)
vcbOptions1Box3PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box3PopOut2, vcbOptions1Box3PopOut2Choice0)
vcbOptions1Box3PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box3PopOut3, vcbOptions1Box3PopOut3Choice0)
vcbOptions1Box3PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box3PopOut4, vcbOptions1Box3PopOut4Choice0)
vcbOptions1Box3PopOut4:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box4PopOut1, vcbOptions1Box4PopOut1Choice0)
vcbOptions1Box4PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box4PopOut2, vcbOptions1Box4PopOut2Choice0)
vcbOptions1Box4PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box4PopOut3, vcbOptions1Box4PopOut3Choice0)
vcbOptions1Box4PopOut3:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box5PopOut1, vcbOptions1Box5PopOut1Choice0)
vcbOptions1Box5PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box5PopOut2, vcbOptions1Box5PopOut2Choice0)
vcbOptions1Box5PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box6PopOut1, vcbOptions1Box6PopOut1Choice0)
vcbOptions1Box6PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box6PopOut2, vcbOptions1Box6PopOut2Choice0)
vcbOptions1Box6PopOut2:SetScript("OnLeave", vcbLeavingMenus)
-- drop down --
vcbClickPopOut(vcbOptions1Box7PopOut1, vcbOptions1Box7PopOut1Choice0)
vcbOptions1Box7PopOut1:SetScript("OnLeave", vcbLeavingMenus)
-- Showing the panel --
vcbOptions1:HookScript("OnShow", function(self)
	CheckSavedVariables()
	if vcbOptions2:IsShown() then vcbOptions2:Hide() end
	if vcbOptions3:IsShown() then vcbOptions3:Hide() end
	if vcbOptions4:IsShown() then vcbOptions4:Hide() end
	if vcbOptions5:IsShown() then vcbOptions5:Hide() end
	if vcbOptions6:IsShown() then vcbOptions6:Hide() end
	vcbOptions00Tab1.Text:SetTextColor(vcbHighColor:GetRGB())
	vcbOptions00Tab2.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab3.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab4.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab5.Text:SetTextColor(vcbMainColor:GetRGB())
	vcbOptions00Tab6.Text:SetTextColor(vcbMainColor:GetRGB())
end)
