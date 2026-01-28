-- local variables --
local G = VDW.Local.Override
local textName1, textName2, textName3, textName4, textName5
local textCurrent1, textCurrent2, textCurrent3, textCurrent4, textCurrent5
local textBoth1, textBoth2, textBoth3, textBoth4, textBoth5
local textTotal1, textTotal2, textTotal3, textTotal4, textTotal5
local iconSpell1, iconSpell2, iconSpell3, iconSpell4, iconSpell5
local shieldSpell1, shieldSpell2, shieldSpell3, shieldSpell4, shieldSpell5
-- protect the options --
local function ProtectOptions()
	local loc = GetLocale()
	if loc ~= VCBspecialSettings["LastLocation"] then
		for k, v in pairs(VDW.Local.Translate) do
			for i, s in pairs (v) do
				if VCBsettings["Boss"]["NameText"]["Position"] == s then
					VCBsettings["Boss"]["NameText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["CurrentTimeText"]["Position"] == s then
					VCBsettings["Boss"]["CurrentTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == s then
					VCBsettings["Boss"]["CurrentTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["CurrentTimeText"]["Sec"] == s then
					VCBsettings["Boss"]["CurrentTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["BothTimeText"]["Position"] == s then
					VCBsettings["Boss"]["BothTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["BothTimeText"]["Direction"] == s then
					VCBsettings["Boss"]["BothTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["BothTimeText"]["Sec"] == s then
					VCBsettings["Boss"]["BothTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["TotalTimeText"]["Position"] == s then
					VCBsettings["Boss"]["TotalTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["TotalTimeText"]["Sec"] == s then
					VCBsettings["Boss"]["TotalTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["Icon"]["Position"] == s then
					VCBsettings["Boss"]["Icon"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["Icon"]["Shield"] == s then
					VCBsettings["Boss"]["Icon"]["Shield"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["StatusBar"]["Color"] == s then
					VCBsettings["Boss"]["StatusBar"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["StatusBar"]["Style"] == s then
					VCBsettings["Boss"]["StatusBar"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["Border"]["Color"] == s then
					VCBsettings["Boss"]["Border"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["Border"]["Style"] == s then
					VCBsettings["Boss"]["Border"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Boss"]["Lock"] == s then
					VCBsettings["Boss"]["Lock"] = VDW.Local.Translate[loc][i]
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
		var1:SetHeight(Boss1TargetFrameSpellBar.Text:GetHeight())
		var1:Hide()
	end
-- creating the texts --
	for i = 1, 5, 1 do
		_G["textName"..i] = _G["Boss"..i.."TargetFrameSpellBar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textName"..i])
		_G["textCurrent"..i] = _G["Boss"..i.."TargetFrameSpellBar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textCurrent"..i])
		_G["textBoth"..i] = _G["Boss"..i.."TargetFrameSpellBar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textBoth"..i])
		_G["textTotal"..i] = _G["Boss"..i.."TargetFrameSpellBar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textTotal"..i])
	end
-- copy texture of spell's icon --
	for i = 1, 5, 1 do
		_G["iconSpell"..i] = _G["Boss"..i.."TargetFrameSpellBar"]:CreateTexture(nil, "ARTWORK", nil, 0)
		_G["iconSpell"..i]:SetWidth(_G["Boss"..i.."TargetFrameSpellBar"].Icon:GetWidth())
		_G["iconSpell"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Icon:GetWidth())
		_G["iconSpell"..i]:Hide()
	end
	for i = 1, 5, 1 do
		_G["shieldSpell"..i] = _G["Boss"..i.."TargetFrameSpellBar"]:CreateTexture(nil, "BACKGROUND", nil, 0)
		_G["shieldSpell"..i]:SetAtlas("ui-castingbar-shield", false)
		_G["shieldSpell"..i]:SetPoint("CENTER", _G["iconSpell"..i], "CENTER", -1, -3)
		_G["shieldSpell"..i]:SetSize(29, 33)
		_G["shieldSpell"..i]:SetBlendMode("BLEND")
		_G["shieldSpell"..i]:SetAlpha(0.75)
		_G["shieldSpell"..i]:Hide()
	end
end
-- function for the s.u.f cast bar --
local function createTxtsSUF()
-- creating the castbars --
	for i = 1, 5, 1 do
		local statusbar = CreateFrame("StatusBar", "SUFHeaderbossUnitButton"..i.."vcb2Castbar", _G["SUFHeaderbossUnitButton"..i], "SmallCastingBarFrameTemplate")
		_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:SetSize(150, 10)
		_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:ClearAllPoints()
		if i == 1 then _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Boss"]["Position"]["X"], VCBsettings["Boss"]["Position"]["Y"])
		else _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:SetPoint("TOP", _G["SUFHeaderbossUnitButton"..(i-1).."vcb2Castbar"], "BOTTOM", 0, -32) end
		_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:SetScale(VCBsettings["Boss"]["Scale"]/100)
		_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:OnLoad("boss"..i, true, true)
	end
-- function for the texts --
	local function Texts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFHeaderbossUnitButton1vcb2Castbar.Text:GetHeight())
		var1:Hide()
	end
-- creating the texts --
	for i = 1, 5, 1 do
		_G["textName"..i] = _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textName"..i])
		_G["textCurrent"..i] = _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textCurrent"..i])
		_G["textBoth"..i] = _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textBoth"..i])
		_G["textTotal"..i] = _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textTotal"..i])
	end
-- copy texture of spell's icon --
	for i = 1, 5, 1 do
		_G["iconSpell"..i] = _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:CreateTexture(nil, "ARTWORK", nil, 0)
		_G["iconSpell"..i]:SetWidth(_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"].Icon:GetWidth())
		_G["iconSpell"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"].Icon:GetWidth())
		_G["iconSpell"..i]:Hide()
	end
	for i = 1, 5, 1 do
		_G["shieldSpell"..i] = _G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:CreateTexture(nil, "BACKGROUND", nil, 0)
		_G["shieldSpell"..i]:SetAtlas("ui-castingbar-shield", false)
		_G["shieldSpell"..i]:SetPoint("CENTER", _G["iconSpell"..i], "CENTER", -1, -3)
		_G["shieldSpell"..i]:SetSize(29, 33)
		_G["shieldSpell"..i]:SetBlendMode("BLEND")
		_G["shieldSpell"..i]:SetAlpha(0.75)
		_G["shieldSpell"..i]:Hide()
	end
end
-- name position --
local function namePosition(self, i)
	print("namePosition is not Working!")
end
-- current time position --
local function currentPostion(self, i)
	print("currentPostion is not Working!")
end
-- both time position --
local function bothPostion(self, i)
	print("bothPostion is not Working!")
end
-- total time position--
local function totalPostion(self, i)
	print("totalPostion is not Working!")
end
-- icon position --
local function iconPosition(self, i)
	print("iconPosition is not Working!")
end
-- current time update --
local function currentUpdate(self, i)
	print("currentUpdate is not Working!")
end
-- both time update --
local function bothUpdate(self, i)
	print("bothUpdate is not Working!")
end
-- total time update--
local function totalUpdate(self, i)
	print("totalUpdate is not Working!")
end
-- cast bar color --
local function castbarColor(self, i)
	print("castbarColor is not Working!")
end
-- border color --
local function borderColor(self, i)
	print("borderColor is not Working!")
end
-- position functions --
local function GlobalFunctionsCHK()
-- icon --
	function chkIconBoss()
		if VCBsettings["Boss"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			if VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				function iconPosition(self, i)
					if self.Icon:IsShown() then self.Icon:Hide() end
					if _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Hide() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			elseif VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Hide() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			elseif VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self, i)
					if self.Icon:IsShown() then self.Icon:Hide() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			elseif VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			end
		elseif VCBsettings["Boss"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			if VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
					if self.barType == "uninterruptable" then
						if not self.BorderShield:IsShown() then self.BorderShield:Show() end
					end
				end
			elseif VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self, i)
					if self.Icon:IsShown() then self.Icon:Hide() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if self.barType == "uninterruptable" then
						if not _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Show() end
					else
						if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
					end
				end
			elseif VCBsettings["Boss"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.barType == "uninterruptable" then
						if not self.BorderShield:IsShown() then self.BorderShield:Show() end
						if not _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Show() end
					else
						if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
					end
				end
			end
		end
	end
-- name --
	function chkNameTxtBoss()
		if VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_V_HIDE then
			function namePosition(self, i)
				if _G["textName"..i]:IsShown() then _G["textName"..i]:Hide() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_LEFT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_TOP then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_CENTER then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_RIGHT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		end
	end
-- total time --
	function chkTotalTxtBoss()
		if VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalPostion(self, i)
				if _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Hide() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		end
	end
-- current time --
	function chkCurrentTxtBoss()
		if VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function currentPostion(self, i)
				if _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Hide() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		end
	end
-- both time --
	function chkBothTxtBoss()
		if VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function bothPostion(self, i)
				if _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Hide() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Boss"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		end
	end
end
-- update functions --
local function GlobalFunctionsUPD()
-- current time --
	function chkCurrentUpdBoss()
		if VCBsettings["Boss"]["CurrentTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Boss"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.0f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.0f", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.0f", self.value)
						end
					end
				elseif VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.1f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.1f", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.1f", self.value)
						end
					end
				elseif VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.2f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.2f", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.2f", self.value)
						end
					end
				elseif VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.3f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.3f", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.3f", self.value)
						end
					end
				end
			elseif VCBsettings["Boss"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.0f Sec", self.value)
						end
					end
				elseif VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.1f Sec", self.value)
						end
					end
				elseif VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.2f Sec", self.value)
						end
					end
				elseif VCBsettings["Boss"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", self.value)
							end
						end
					elseif VCBsettings["Boss"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.3f Sec", self.value)
						end
					end
				end
			end
		else
			function currentUpdate(self, i)
				return
			end
		end
	end
-- both time --
	function chkBothUpdBoss()
		if VCBsettings["Boss"]["BothTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Boss"]["BothTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
						end
					end
				end
			elseif VCBsettings["Boss"]["BothTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Boss"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Boss"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
						end
					end
				end
			end
		else
			function bothUpdate(self, i)
				return
			end
		end
	end
-- total time --
	function chkTotalUpdBoss()
		if VCBsettings["Boss"]["TotalTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Boss"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.0f", self.maxValue)
					end
				elseif VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.1f", self.maxValue)
					end
				elseif VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.2f", self.maxValue)
					end
				elseif VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.3f", self.maxValue)
					end
				end
			elseif VCBsettings["Boss"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.0f sec", self.maxValue)
					end
				elseif VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.1f sec", self.maxValue)
					end
				elseif VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.2f sec", self.maxValue)
					end
				elseif VCBsettings["Boss"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.3f sec", self.maxValue)
					end
				end
			end
		elseif VCBsettings["Boss"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalUpdate(self, i)
				return
			end
		end
	end
end
-- color function --
local function GlobalFunctionsCLR()
	function chkCastbarColorBoss()
		if VCBsettings["Boss"]["StatusBar"]["Color"] == G.OPTIONS_C_DEFAULT then
			function castbarColor(self, i)
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
				self.Spark:SetDesaturated(false)
				self.Spark:SetVertexColor(1, 1, 1, 1)
				self.Flash:SetDesaturated(false)
				self.Flash:SetVertexColor(1, 1, 1, 1)
			end
		elseif VCBsettings["Boss"]["StatusBar"]["Color"] == G.OPTIONS_C_CLASS then
			function castbarColor(self, i)
				if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
					self:SetStatusBarDesaturated(true)
					self:SetStatusBarColor(vcbClassColorBoss:GetRGB())
					self.Spark:SetDesaturated(true)
					self.Spark:SetVertexColor(vcbClassColorBoss:GetRGB())
					self.Flash:SetDesaturated(true)
					self.Flash:SetVertexColor(vcbClassColorBoss:GetRGB())
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
	function chkBorderColorBoss()
		if VCBsettings["Boss"]["Border"]["Color"] == G.OPTIONS_C_DEFAULT then
			function borderColor(self, i)
				self.Background:SetVertexColor(1, 1, 1, 1)
				self.Border:SetVertexColor(1, 1, 1, 1)
				self.TextBorder:SetVertexColor(1, 1, 1, 1)
			end
		elseif VCBsettings["Boss"]["Border"]["Color"] == G.OPTIONS_C_CLASS then
			function borderColor(self, i)
				self.Background:SetVertexColor(vcbClassColorBoss:GetRGB())
				self.Border:SetVertexColor(vcbClassColorBoss:GetRGB())
				self.TextBorder:SetVertexColor(vcbClassColorBoss:GetRGB())
			end
		end
	end
end
-- position bar --
local function positionBar(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Boss"]["Position"]["X"], VCBsettings["Boss"]["Position"]["Y"])
end
-- scale bar --
local function scaleBar(self)
	self:SetScale(VCBsettings["Boss"]["Scale"]/100)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		ProtectOptions()
		if VCBsettings["Boss"]["Lock"] == G.OPTIONS_LS_LOCKED then
			createTxtsDefault()
		elseif VCBsettings["Boss"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
			createTxtsDefault()
			Boss1TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				positionBar(self)
				scaleBar(self)
			end)
			for i=2, 5, 1 do
				_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnUpdate", function(self)
					self:ClearAllPoints()
					self:SetPoint("TOP", _G["Boss"..(i-1).."TargetFrameSpellBar"], "BOTTOM", 0, -32)
					scaleBar(self)
				end)
			end
		elseif VCBsettings["Boss"]["Lock"] == "S.U.F" then
			createTxtsSUF()
			SUFHeaderbossUnitButton1vcb2Castbar:HookScript("OnUpdate", function(self)
				positionBar(self)
				scaleBar(self)
			end)
			for i=2, 5, 1 do
				_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:HookScript("OnUpdate", function(self)
					scaleBar(self)
				end)
			end
		end
		GlobalFunctionsCHK()
		GlobalFunctionsUPD()
		GlobalFunctionsCLR()
		chkIconBoss()
		chkNameTxtBoss()
		chkCurrentTxtBoss()
		chkBothTxtBoss()
		chkTotalTxtBoss()
		chkCurrentUpdBoss()
		chkBothUpdBoss()
		chkTotalUpdBoss()
		chkCastbarColorBoss()
		chkBorderColorBoss()
		if VCBsettings["Boss"]["Lock"] == G.OPTIONS_LS_LOCKED or VCBsettings["Boss"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
			for i = 1, 5, 1 do
				_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnShow", function(self)
					local classFilename = UnitClassBase("boss"..i)
					if classFilename ~= nil then vcbClassColorBoss = C_ClassColor.GetClassColor(classFilename) end
					namePosition(self, i)
					currentPostion(self, i)
					bothPostion(self, i)
					totalPostion(self, i)
				end)
				_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnUpdate", function(self)
					if self.value ~= nil and self.maxValue ~= nil then
						self.Text:SetAlpha(0)
						_G["textName"..i]:SetText(self.Text:GetText())
						iconPosition(self, i)
						currentUpdate(self, i)
						bothUpdate(self, i)
						totalUpdate(self, i)
						castbarColor(self, i)
						borderColor(self, i)
					end
				end)
			end
		elseif VCBsettings["Boss"]["Lock"] == "S.U.F" then
			for i = 1, 5, 1 do
				_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:HookScript("OnShow", function(self)
					local classFilename = UnitClassBase("boss"..i)
					if classFilename ~= nil then vcbClassColorBoss = C_ClassColor.GetClassColor(classFilename) end
					namePosition(self, i)
					currentPostion(self, i)
					bothPostion(self, i)
					totalPostion(self, i)
				end)
				_G["SUFHeaderbossUnitButton"..i.."vcb2Castbar"]:HookScript("OnUpdate", function(self)
					if self.value ~= nil and self.maxValue ~= nil then
						self.Text:SetAlpha(0)
						_G["textName"..i]:SetText(self.Text:GetText())
						iconPosition(self, i)
						currentUpdate(self, i)
						bothUpdate(self, i)
						totalUpdate(self, i)
						castbarColor(self, i)
						borderColor(self, i)
					end
				end)
			end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
