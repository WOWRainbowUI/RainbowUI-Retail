-- Blizzard Bosses Castbars --
local function BossSpellBarTexts()
-- Name Text --
	VCBnameTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBnameTextBoss1", "OVERLAY", nil)
	VCBnameTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBnameTextBoss2", "OVERLAY", nil)
	VCBnameTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBnameTextBoss3", "OVERLAY", nil)
	VCBnameTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBnameTextBoss4", "OVERLAY", nil)
	VCBnameTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBnameTextBoss5", "OVERLAY", nil)
-- Current Time Text --
	VCBcurrentTimeTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss1", "OVERLAY", nil)
	VCBcurrentTimeTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss2", "OVERLAY", nil)
	VCBcurrentTimeTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss3", "OVERLAY", nil)
	VCBcurrentTimeTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss4", "OVERLAY", nil)
	VCBcurrentTimeTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss5", "OVERLAY", nil)
-- Total Time Text --
	VCBtotalTimeTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss1", "OVERLAY", nil)
	VCBtotalTimeTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss2", "OVERLAY", nil)
	VCBtotalTimeTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss3", "OVERLAY", nil)
	VCBtotalTimeTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss4", "OVERLAY", nil)
	VCBtotalTimeTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss5", "OVERLAY", nil)
-- Both Time Text --
	VCBbothTimeTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss1", "OVERLAY", nil)
	VCBbothTimeTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss2", "OVERLAY", nil)
	VCBbothTimeTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss3", "OVERLAY", nil)
	VCBbothTimeTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss4", "OVERLAY", nil)
	VCBbothTimeTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss5", "OVERLAY", nil)
	for i = 1, 5, 1 do
-- name --
		_G["VCBnameTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBnameTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBnameTextBoss"..i]:Hide()
-- Current Time Text --
		_G["VCBcurrentTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBcurrentTimeTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBcurrentTimeTextBoss"..i]:Hide()
-- Total Time Text --
		_G["VCBtotalTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBtotalTimeTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBtotalTimeTextBoss"..i]:Hide()
-- Both Time Text --
		_G["VCBbothTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBbothTimeTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBbothTimeTextBoss"..i]:Hide()
	end
end
-- SUF Bossses Castbar --
local function sufBossSpellBarTexts()
-- creating the castbars --
	for i = 1, 5, 1 do
		local statusbar = CreateFrame("StatusBar", "SUFHeaderbossUnitButton"..i.."vcbCastbar", _G["SUFHeaderbossUnitButton"..i], "SmallCastingBarFrameTemplate")
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetSize(150, 10)
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:ClearAllPoints()
		if i == 1 then _G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrBoss["Position"]["X"], VCBrBoss["Position"]["Y"])
		else _G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetPoint("TOP", _G["SUFHeaderbossUnitButton"..(i-1).."vcbCastbar"], "BOTTOM", 0, -32) end
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetScale(VCBrBoss["Scale"]/100)
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:OnLoad("boss"..i, true, true)
	end
-- Name Text --
	VCBnameTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBnameTextBoss1", "OVERLAY", nil)
	VCBnameTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBnameTextBoss2", "OVERLAY", nil)
	VCBnameTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBnameTextBoss3", "OVERLAY", nil)
	VCBnameTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBnameTextBoss4", "OVERLAY", nil)
	VCBnameTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBnameTextBoss5", "OVERLAY", nil)
-- Current Time Text --
	VCBcurrentTimeTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss1", "OVERLAY", nil)
	VCBcurrentTimeTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss2", "OVERLAY", nil)
	VCBcurrentTimeTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss3", "OVERLAY", nil)
	VCBcurrentTimeTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss4", "OVERLAY", nil)
	VCBcurrentTimeTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss5", "OVERLAY", nil)
-- Total Time Text --
	VCBtotalTimeTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBtotalTimeTextBoss1", "OVERLAY", nil)
	VCBtotalTimeTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBtotalTimeTextBoss2", "OVERLAY", nil)
	VCBtotalTimeTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBtotalTimeTextBoss3", "OVERLAY", nil)
	VCBtotalTimeTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBtotalTimeTextBoss4", "OVERLAY", nil)
	VCBtotalTimeTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBtotalTimeTextBoss5", "OVERLAY", nil)
-- Both Time Text --
	VCBbothTimeTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBbothTimeTextBoss1", "OVERLAY", nil)
	VCBbothTimeTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBbothTimeTextBoss2", "OVERLAY", nil)
	VCBbothTimeTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBbothTimeTextBoss3", "OVERLAY", nil)
	VCBbothTimeTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBbothTimeTextBoss4", "OVERLAY", nil)
	VCBbothTimeTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBbothTimeTextBoss5", "OVERLAY", nil)
	for i = 1, 5, 1 do
-- name --
		_G["VCBnameTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBnameTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBnameTextBoss"..i]:Hide()
-- Current Time Text --
		_G["VCBcurrentTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBcurrentTimeTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBcurrentTimeTextBoss"..i]:Hide()
-- Total Time Text --
		_G["VCBtotalTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBtotalTimeTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBtotalTimeTextBoss"..i]:Hide()
-- Both Time Text --
		_G["VCBbothTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBbothTimeTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBbothTimeTextBoss"..i]:Hide()
	end
end
-- Name position --
function chkBossNamePosition()
	if VCBrBoss["NameText"] == "左上" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			_G["VCBnameTextBoss"..i]:SetJustifyH("LEFT")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "左" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			_G["VCBnameTextBoss"..i]:SetJustifyH("LEFT")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "左下" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			_G["VCBnameTextBoss"..i]:SetJustifyH("LEFT")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "上" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			_G["VCBnameTextBoss"..i]:SetJustifyH("CENTER")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "中" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			_G["VCBnameTextBoss"..i]:SetJustifyH("CENTER")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "下" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			_G["VCBnameTextBoss"..i]:SetJustifyH("CENTER")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "右上" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			_G["VCBnameTextBoss"..i]:SetJustifyH("RIGHT")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "右" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			_G["VCBnameTextBoss"..i]:SetJustifyH("RIGHT")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "右下" then
		function vcbBossNamePosition(self, i)
			_G["VCBnameTextBoss"..i]:ClearAllPoints()
			_G["VCBnameTextBoss"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			_G["VCBnameTextBoss"..i]:SetJustifyH("RIGHT")
			if not _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["NameText"] == "隱藏" then
		function vcbBossNamePosition(self, i)
			if _G["VCBnameTextBoss"..i]:IsShown() then _G["VCBnameTextBoss"..i]:Hide() end
		end
	end
end
-- Current time position --
function chkBossCurrentTimePosition()
	if VCBrBoss["CurrentTimeText"]["Position"] == "左上" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "左" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "左下" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "上" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "中" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "下" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "右上" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "右" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "右下" then
		function vcbBossCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextBoss"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["CurrentTimeText"]["Position"] == "隱藏" then
		function vcbBossCurrentTimePosition(self, i)
			if _G["VCBcurrentTimeTextBoss"..i]:IsShown() then _G["VCBcurrentTimeTextBoss"..i]:Hide() end
		end
	end
end
-- Both time position --
function chkBossBothTimePosition()
	if VCBrBoss["BothTimeText"]["Position"] == "左上" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "左" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "左下" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "上" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "中" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "下" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "右上" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "右" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "右下" then
		function vcbBossBothTimePosition(self, i)	
			_G["VCBbothTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBbothTimeTextBoss"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["BothTimeText"]["Position"] == "隱藏" then
		function vcbBossBothTimePosition(self, i)	
			if _G["VCBbothTimeTextBoss"..i]:IsShown() then _G["VCBbothTimeTextBoss"..i]:Hide() end
		end
	end
end
-- Total Time position --
function chkBossTotalTimePosition()
	if VCBrBoss["TotalTimeText"]["Position"] == "左上" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "左" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "左下" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "上" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "中" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "下" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "右上" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "右" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "右下" then
		function vcbBossTotalTimePosition(self, i)
			_G["VCBtotalTimeTextBoss"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextBoss"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Show() end
		end
	elseif VCBrBoss["TotalTimeText"]["Position"] == "隱藏" then
		function vcbBossTotalTimePosition(self, i)
			if _G["VCBtotalTimeTextBoss"..i]:IsShown() then _G["VCBtotalTimeTextBoss"..i]:Hide() end
		end
	end
end
-- Current time update --
function chkBossCurrentTimeUpdate()
	if VCBrBoss["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrBoss["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrBoss["CurrentTimeText"]["Direction"] == "正數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f 秒", VCBdescending)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f 秒", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f 秒", self.value)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbBossCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f 秒", self.value)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrBoss["CurrentTimeText"]["Direction"] == "正數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbBossCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrBoss["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrBoss["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrBoss["CurrentTimeText"]["Direction"] == "正數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f 秒", VCBdescending)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f 秒", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f 秒", self.value)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbBossCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f 秒", self.value)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrBoss["CurrentTimeText"]["Direction"] == "正數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbBossCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrBoss["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrBoss["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrBoss["CurrentTimeText"]["Direction"] == "正數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f 秒", VCBdescending)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f 秒", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f 秒", self.value)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbBossCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f 秒", self.value)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrBoss["CurrentTimeText"]["Direction"] == "正數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbBossCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrBoss["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbBossCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextBoss"..i]:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- Both time update --
function chkBossBothTimeUpdate()
	if VCBrBoss["BothTimeText"]["Decimals"] == 2 then
		if VCBrBoss["BothTimeText"]["Sec"] == "顯示" then
			if VCBrBoss["BothTimeText"]["Direction"] == "正數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "倒數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "兩者" then
				function vcbBossBothTimeUpdate(self, i)
					_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrBoss["BothTimeText"]["Direction"] == "正數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "倒數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "兩者" then
				function vcbBossBothTimeUpdate(self, i)
					_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrBoss["BothTimeText"]["Decimals"] == 1 then
		if VCBrBoss["BothTimeText"]["Sec"] == "顯示" then
			if VCBrBoss["BothTimeText"]["Direction"] == "正數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "倒數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "兩者" then
				function vcbBossBothTimeUpdate(self, i)
					_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrBoss["BothTimeText"]["Direction"] == "正數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "倒數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "兩者" then
				function vcbBossBothTimeUpdate(self, i)
					_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrBoss["BothTimeText"]["Decimals"] == 0 then
		if VCBrBoss["BothTimeText"]["Sec"] == "顯示" then
			if VCBrBoss["BothTimeText"]["Direction"] == "正數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "倒數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "兩者" then
				function vcbBossBothTimeUpdate(self, i)
					_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrBoss["BothTimeText"]["Direction"] == "正數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "倒數" then
				function vcbBossBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrBoss["BothTimeText"]["Direction"] == "兩者" then
				function vcbBossBothTimeUpdate(self, i)
					_G["VCBbothTimeTextBoss"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- Total time update --
function chkBossTotalTimeUpdate()
	if VCBrBoss["TotalTimeText"]["Sec"] == "顯示" then
		if VCBrBoss["TotalTimeText"]["Decimals"] == 2 then
			function vcbBossTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.2f 秒", self.maxValue)
			end
		elseif VCBrBoss["TotalTimeText"]["Decimals"] == 1 then
			function vcbBossTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.1f 秒", self.maxValue)
			end
		elseif VCBrBoss["TotalTimeText"]["Decimals"] == 0 then
			function vcbBossTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.0f 秒", self.maxValue)
			end
		end
	elseif VCBrBoss["TotalTimeText"]["Sec"] == "隱藏" then
		if VCBrBoss["TotalTimeText"]["Decimals"] == 2 then
			function vcbBossTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrBoss["TotalTimeText"]["Decimals"] == 1 then
			function vcbBossTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrBoss["TotalTimeText"]["Decimals"] == 0 then
			function vcbBossTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- Coloring the bar --
function chkBossCastbarColor()
	if VCBrBoss["Color"] == "預設顏色" then
		function vcbBossCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	elseif VCBrBoss["Color"] == "職業顏色" then
		function vcbBossCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(vcbClassColorBoss:GetRGB())
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	end
end
-- Position of  the bar --
function vcbBossCastbarPosition(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrBoss["Position"]["X"], VCBrBoss["Position"]["Y"])
end
-- Scale of the bar --
function vcbBossCastbarScale(self)
	self:SetScale(VCBrBoss["Scale"]/100)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		if VCBrBoss["otherAdddon"] == "無" then
			BossSpellBarTexts()
			if VCBrBoss["Unlock"] then
				Boss1TargetFrameSpellBar:HookScript("OnUpdate", function(self)
					vcbBossCastbarPosition(self)
					vcbBossCastbarScale(self)
				end)
				for i=2,5,1 do
					_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnUpdate", function(self)
						self:SetScale(VCBrBoss["Scale"]/100)
						self:ClearAllPoints()
						self:SetPoint("TOP", _G["Boss"..(i-1).."TargetFrameSpellBar"], "BOTTOM", 0, -32)
					end)
				end
			end
		elseif VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then
			sufBossSpellBarTexts()
			SUFHeaderbossUnitButton1vcbCastbar:HookScript("OnUpdate", function(self)
				vcbBossCastbarPosition(self)
			end)
		end
		chkBossNamePosition()
		chkBossCurrentTimePosition()
		chkBossBothTimePosition()
		chkBossTotalTimePosition()
		chkBossCurrentTimeUpdate()
		chkBossBothTimeUpdate()
		chkBossTotalTimeUpdate()
		chkBossCastbarColor()
		if VCBrBoss["otherAdddon"] == "無" then
			for i = 1, 5, 1 do
				_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnShow", function(self)
					local classFilename = UnitClassBase("boss"..i)
					if classFilename ~= nil then vcbClassColorBoss = C_ClassColor.GetClassColor(classFilename) end
					_G["VCBnameTextBoss"..i]:SetWidth(self:GetWidth())
					vcbBossNamePosition(self, i)
					vcbBossCurrentTimePosition(self, i)
					vcbBossBothTimePosition(self, i)
					vcbBossTotalTimePosition(self, i)
				end)
				_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnUpdate", function(self)
					vcbBossCastbarColor(self)
					self.Text:SetAlpha(0)
					_G["VCBnameTextBoss"..i]:SetText(self.Text:GetText())
					if self.value ~= nil and self.maxValue ~= nil then
						vcbBossCurrentTimeUpdate(self, i)
						vcbBossBothTimeUpdate(self, i)
						vcbBossTotalTimeUpdate(self, i)
					end
				end)
			end
		elseif VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then
			for i = 1, 5, 1 do
				_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:HookScript("OnShow", function(self)
					self:SetScale(VCBrBoss["Scale"]/100)
					local classFilename = UnitClassBase("boss"..i)
					if classFilename ~= nil then vcbClassColorBoss = C_ClassColor.GetClassColor(classFilename) end
					_G["VCBnameTextBoss"..i]:SetWidth(self:GetWidth())
					vcbBossNamePosition(self, i)
					vcbBossCurrentTimePosition(self, i)
					vcbBossBothTimePosition(self, i)
					vcbBossTotalTimePosition(self, i)
				end)
				_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:HookScript("OnUpdate", function(self)
					vcbBossCastbarColor(self)
					self.Text:SetAlpha(0)
					_G["VCBnameTextBoss"..i]:SetText(self.Text:GetText())
					if self.value ~= nil and self.maxValue ~= nil then
						vcbBossCurrentTimeUpdate(self, i)
						vcbBossBothTimeUpdate(self, i)
						vcbBossTotalTimeUpdate(self, i)
					end
				end)
			end
		end		
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
