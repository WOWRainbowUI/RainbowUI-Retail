-- local variables --
local G = VDW.Local.Override
local textName
local textCurrent
local textBoth
local textTotal
local iconSpell
local shieldSpell
-- protect the options --
local function ProtectOptions()
	local loc = GetLocale()
	if loc ~= VCBspecialSettings["LastLocation"] then
		for k, v in pairs(VDW.Local.Translate) do
			for i, s in pairs (v) do
				if VCBsettings["Focus"]["NameText"]["Position"] == s then
					VCBsettings["Focus"]["NameText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["CurrentTimeText"]["Position"] == s then
					VCBsettings["Focus"]["CurrentTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == s then
					VCBsettings["Focus"]["CurrentTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["CurrentTimeText"]["Sec"] == s then
					VCBsettings["Focus"]["CurrentTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["BothTimeText"]["Position"] == s then
					VCBsettings["Focus"]["BothTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["BothTimeText"]["Direction"] == s then
					VCBsettings["Focus"]["BothTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["BothTimeText"]["Sec"] == s then
					VCBsettings["Focus"]["BothTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["TotalTimeText"]["Position"] == s then
					VCBsettings["Focus"]["TotalTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["TotalTimeText"]["Sec"] == s then
					VCBsettings["Focus"]["TotalTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["Icon"]["Position"] == s then
					VCBsettings["Focus"]["Icon"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["Icon"]["Shield"] == s then
					VCBsettings["Focus"]["Icon"]["Shield"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["StatusBar"]["Color"] == s then
					VCBsettings["Focus"]["StatusBar"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["StatusBar"]["Style"] == s then
					VCBsettings["Focus"]["StatusBar"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["Border"]["Color"] == s then
					VCBsettings["Focus"]["Border"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["Border"]["Style"] == s then
					VCBsettings["Focus"]["Border"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Focus"]["Lock"] == s then
					VCBsettings["Focus"]["Lock"] = VDW.Local.Translate[loc][i]
				end
			end
		end
	end
end
-- function for the default cast bar --
local function createTxtsDefault()
-- function for the texts --
	local function Texts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(FocusFrameSpellBar.Text:GetHeight())
		var1:Hide()
	end
-- creating the texts --
	textName = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textName)
	textCurrent = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textCurrent)
	textBoth = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textBoth)
	textTotal = FocusFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textTotal)
-- copy texture of spell's icon --
	iconSpell = FocusFrameSpellBar:CreateTexture(nil, "ARTWORK", nil, 0)
	iconSpell:SetWidth(FocusFrameSpellBar.Icon:GetWidth())
	iconSpell:SetHeight(FocusFrameSpellBar.Icon:GetHeight())
	iconSpell:Hide()
-- copy texture of spell's shield --
	shieldSpell = FocusFrameSpellBar:CreateTexture(nil, "BACKGROUND", nil, 0)
	shieldSpell:SetAtlas("ui-castingbar-shield", false)
	shieldSpell:SetPoint("CENTER", iconSpell, "CENTER", -1, -3)
	shieldSpell:SetSize(29, 33)
	shieldSpell:SetBlendMode("BLEND")
	shieldSpell:SetAlpha(0.75)
	shieldSpell:Hide()
end
-- function for the s.u.f cast bar --
local function createTxtsSUF()
-- creating the cast bar --
	local bar = CreateFrame("StatusBar", "$parentV2castbar", SUFUnitfocus, "SmallCastingBarFrameTemplate")
	bar:SetSize(150, 10)
	bar:ClearAllPoints()
	bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Focus"]["Position"]["X"], VCBsettings["Focus"]["Position"]["Y"])
	bar:SetScale(VCBsettings["Focus"]["Scale"]/100)
	bar:OnLoad("focus", true, true)
-- function for the texts --
	local function Texts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFUnitfocusV2castbar.Text:GetHeight())
		var1:Hide()
	end
-- creating the texts --
	textName = SUFUnitfocusV2castbar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textName)
	textCurrent = SUFUnitfocusV2castbar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textCurrent)
	textBoth = SUFUnitfocusV2castbar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textBoth)
	textTotal = SUFUnitfocusV2castbar:CreateFontString(nil, "OVERLAY", nil)
	Texts(textTotal)
-- copy texture of spell's icon --
	iconSpell = SUFUnitfocusV2castbar:CreateTexture(nil, "ARTWORK", nil, 0)
	iconSpell:SetWidth(SUFUnitfocusV2castbar.Icon:GetWidth())
	iconSpell:SetHeight(SUFUnitfocusV2castbar.Icon:GetHeight())
	iconSpell:Hide()
-- copy texture of spell's shield --
	shieldSpell = SUFUnitfocusV2castbar:CreateTexture(nil, "BACKGROUND", nil, 0)
	shieldSpell:SetAtlas("ui-castingbar-shield", false)
	shieldSpell:SetPoint("CENTER", iconSpell, "CENTER", -1, -3)
	shieldSpell:SetSize(29, 33)
	shieldSpell:SetBlendMode("BLEND")
	shieldSpell:SetAlpha(0.75)
	shieldSpell:Hide()
end
-- name position --
local function namePosition(self)
	print("namePosition is not Working!")
end
-- current time position --
local function currentPostion(self)
	print("currentPostion is not Working!")
end
-- both time position --
local function bothPostion(self)
	print("bothPostion is not Working!")
end
-- total time position--
local function totalPostion(self)
	print("totalPostion is not Working!")
end
-- icon position --
local function iconPosition(self)
	print("iconPosition is not Working!")
end
-- current time update --
local function currentUpdate(self)
	print("currentUpdate is not Working!")
end
-- both time update --
local function bothUpdate(self)
	print("bothUpdate is not Working!")
end
-- total time update--
local function totalUpdate(self)
	print("totalUpdate is not Working!")
end
-- cast bar color --
local function castbarColor(self)
	print("castbarColor is not Working!")
end
-- border color --
local function borderColor(self)
	print("borderColor is not Working!")
end
-- position functions --
local function GlobalFunctionsCHK()
-- icon --
	function chkIconFocus()
		if VCBsettings["Focus"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			if VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				function iconPosition(self)
					if self.Icon:IsShown() then self.Icon:Hide() end
					if iconSpell:IsShown() then iconSpell:Hide() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if shieldSpell:IsShown() then shieldSpell:Hide() end
				end
			elseif VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if iconSpell:IsShown() then iconSpell:Hide() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if shieldSpell:IsShown() then shieldSpell:Hide() end
				end
			elseif VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self)
					if self.Icon:IsShown() then self.Icon:Hide() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if shieldSpell:IsShown() then shieldSpell:Hide() end
				end
			elseif VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self)
					if not self.Icon:IsShown() then self.Icon:Show() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if shieldSpell:IsShown() then shieldSpell:Hide() end
				end
			end
		elseif VCBsettings["Focus"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			if VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if iconSpell:IsShown() then iconSpell:Hide() end
					if shieldSpell:IsShown() then shieldSpell:Hide() end
					if self.barType == "uninterruptable" then
						if not self.BorderShield:IsShown() then self.BorderShield:Show() end
					end
				end
			elseif VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self)
					if self.Icon:IsShown() then self.Icon:Hide() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if self.barType == "uninterruptable" then
						if not shieldSpell:IsShown() then shieldSpell:Show() end
					else
						if shieldSpell:IsShown() then shieldSpell:Hide() end
					end
				end
			elseif VCBsettings["Focus"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self)
					if not self.Icon:IsShown() then self.Icon:Show() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if self.barType == "uninterruptable" then
						if not self.BorderShield:IsShown() then self.BorderShield:Show() end
						if not shieldSpell:IsShown() then shieldSpell:Show() end
					else
						if shieldSpell:IsShown() then shieldSpell:Hide() end
					end
				end
			end
		end
	end
-- name --
	function chkNameTxtFocus()
		if VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_V_HIDE then
			function namePosition(self)
				if textName:IsShown() then textName:Hide() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_LEFT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_TOP then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_CENTER then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_RIGHT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Focus"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not textName:IsShown() then textName:Show() end
			end
		end
	end
-- total time --
	function chkTotalTxtFocus()
		if VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalPostion(self)
				if textTotal:IsShown() then textTotal:Hide() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		end
	end
-- current time --
	function chkCurrentTxtFocus()
		if VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function currentPostion(self)
				if textCurrent:IsShown() then textCurrent:Hide() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Focus"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		end
	end
-- both time --
	function chkBothTxtFocus()
		if VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function bothPostion(self)
				if textBoth:IsShown() then textBoth:Hide() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Focus"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		end
	end
end
-- update functions --
local function GlobalFunctionsUPD()
-- current time --
	function chkCurrentUpdFocus()
		if VCBsettings["Focus"]["CurrentTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Focus"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.0f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.0f", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.0f", self.value)
						end
					end
				elseif VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.1f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.1f", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.1f", self.value)
						end
					end
				elseif VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.2f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.2f", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.2f", self.value)
						end
					end
				elseif VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.3f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.3f", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.3f", self.value)
						end
					end
				end
			elseif VCBsettings["Focus"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.0f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f Sec", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.0f Sec", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.0f Sec", self.value)
						end
					end
				elseif VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.1f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f Sec", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.1f Sec", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.1f Sec", self.value)
						end
					end
				elseif VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.2f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f Sec", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.2f Sec", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.2f Sec", self.value)
						end
					end
				elseif VCBsettings["Focus"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.3f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f Sec", vcb2Value)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.3f Sec", self.value)
							end
						end
					elseif VCBsettings["Focus"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.3f Sec", self.value)
						end
					end
				end
			end
		else
			function currentUpdate(self)
				return
			end
		end
	end
-- both time --
	function chkBothUpdFocus()
		if VCBsettings["Focus"]["BothTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Focus"]["BothTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
						end
					end
				end
			elseif VCBsettings["Focus"]["BothTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Focus"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Focus"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
						end
					end
				end
			end
		else
			function bothUpdate(self)
				return
			end
		end
	end
-- total time --
	function chkTotalUpdFocus()
		if VCBsettings["Focus"]["TotalTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Focus"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.0f", self.maxValue)
					end
				elseif VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.1f", self.maxValue)
					end
				elseif VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.2f", self.maxValue)
					end
				elseif VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.3f", self.maxValue)
					end
				end
			elseif VCBsettings["Focus"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.0f sec", self.maxValue)
					end
				elseif VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.1f sec", self.maxValue)
					end
				elseif VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.2f sec", self.maxValue)
					end
				elseif VCBsettings["Focus"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.3f sec", self.maxValue)
					end
				end
			end
		elseif VCBsettings["Focus"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalUpdate(self)
				return
			end
		end
	end
end
-- color function --
local function GlobalFunctionsCLR()
	function chkCastbarColorFocus()
		if VCBsettings["Focus"]["StatusBar"]["Color"] == G.OPTIONS_C_DEFAULT then
			function castbarColor(self)
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
				self.Spark:SetDesaturated(false)
				self.Spark:SetVertexColor(1, 1, 1, 1)
				self.Flash:SetDesaturated(false)
				self.Flash:SetVertexColor(1, 1, 1, 1)
			end
		elseif VCBsettings["Focus"]["StatusBar"]["Color"] == G.OPTIONS_C_CLASS then
			function castbarColor(self)
				if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
					self:SetStatusBarDesaturated(true)
					self:SetStatusBarColor(vcbClassColorFocus:GetRGB())
					self.Spark:SetDesaturated(true)
					self.Spark:SetVertexColor(vcbClassColorFocus:GetRGB())
					self.Flash:SetDesaturated(true)
					self.Flash:SetVertexColor(vcbClassColorFocus:GetRGB())
				else
					self:SetStatusBarDesaturated(false)
					self:SetStatusBarColor(1, 1, 1, 1)
					self.Spark:SetDesaturated(false)
					self.Spark:SetVertexColor(1, 1, 1, 1)
					self.Flash:SetDesaturated(false)
					self.Flash:SetVertexColor(1, 1, 1, 1)
				end
			end
		end
	end
	function chkBorderColorFocus()
		if VCBsettings["Focus"]["Border"]["Color"] == G.OPTIONS_C_DEFAULT then
			function borderColor(self)
				self.Background:SetVertexColor(1, 1, 1, 1)
				self.Border:SetVertexColor(1, 1, 1, 1)
				self.TextBorder:SetVertexColor(1, 1, 1, 1)
			end
		elseif VCBsettings["Focus"]["Border"]["Color"] == G.OPTIONS_C_CLASS then
			function borderColor(self)
				self.Background:SetVertexColor(vcbClassColorFocus:GetRGB())
				self.Border:SetVertexColor(vcbClassColorFocus:GetRGB())
				self.TextBorder:SetVertexColor(vcbClassColorFocus:GetRGB())
			end
		end
	end
end
-- position bar --
local function positionBar(self)
	self:SetScale(VCBsettings["Focus"]["Scale"]/100)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Focus"]["Position"]["X"], VCBsettings["Focus"]["Position"]["Y"])
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		ProtectOptions()
		if VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_LOCKED then
			createTxtsDefault() 
		elseif VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
			createTxtsDefault()
			FocusFrameSpellBar:HookScript("OnUpdate", function(self)
				positionBar(self)
			end)
		elseif VCBsettings["Focus"]["Lock"] == "S.U.F" then
			createTxtsSUF()
		end
		GlobalFunctionsCHK()
		GlobalFunctionsUPD()
		GlobalFunctionsCLR()
		chkIconFocus()
		chkNameTxtFocus()
		chkCurrentTxtFocus()
		chkBothTxtFocus()
		chkTotalTxtFocus()
		chkCurrentUpdFocus()
		chkBothUpdFocus()
		chkTotalUpdFocus()
		chkCastbarColorFocus()
		chkBorderColorFocus()
		if VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_LOCKED or VCBsettings["Focus"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
-- hook part 1 --
			FocusFrameSpellBar:HookScript("OnShow", function(self)
				namePosition(self)
				currentPostion(self)
				bothPostion(self)
				totalPostion(self)
			end)
-- hook part 2 --
			FocusFrameSpellBar:HookScript("OnUpdate", function(self)
				if self.value ~= nil and self.maxValue ~= nil then
					self.Text:SetAlpha(0)
					textName:SetText(self.Text:GetText())
					iconPosition(self)
					currentUpdate(self)
					bothUpdate(self)
					totalUpdate(self)
					castbarColor(self)
					borderColor(self)
				end
			end)
		elseif VCBsettings["Focus"]["Lock"] == "S.U.F" then
-- hook part 1 --
			SUFUnitfocusV2castbar:HookScript("OnShow", function(self)
				namePosition(self)
				currentPostion(self)
				bothPostion(self)
				totalPostion(self)
			end)
-- hook part 2 --
			SUFUnitfocusV2castbar:HookScript("OnUpdate", function(self)
				if self.value ~= nil and self.maxValue ~= nil then
					positionBar(self)
					self.Text:SetAlpha(0)
					textName:SetText(self.Text:GetText())
					iconPosition(self)
					currentUpdate(self)
					bothUpdate(self)
					totalUpdate(self)
					castbarColor(self)
					borderColor(self)
				end
			end)
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if FocusFrame:IsShown() then
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnitfocus ~= nil and VCBsettings["Focus"]["Lock"] == "S.U.F" then
			SUFUnitfocusV2castbar:SetUnit(nil, true, true)
			SUFUnitfocusV2castbar:PlayFinishAnim()
			SUFUnitfocusV2castbar:SetUnit("focus", true, true)
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
