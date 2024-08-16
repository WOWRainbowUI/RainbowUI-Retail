function InvenUnitFrames:CreateDefaultSquareSkin(loadedSkins)
	loadedSkins.DefaultSquare = true
	self.skinDB.name["預設 (方形頭像)"] = "DefaultSquare"
	self.skinDB.idx.DefaultSquare = "預設 (方形頭像)"
	tinsert(self.skinDB.list, "預設 (方形頭像)")
	self.skins.DefaultSquare = {}
	self.skinPos.DefaultSquare = {
		targettarget = { 166, -66 },
		targettargettarget = { 166, -96 },
		focustarget = { 166, -66 },
		focustargettarget = { 166, -96 },
		partypet = { 238, -32 },
	}
end

local swapValues = {
	["70"] = "64", ["76"] = "84", ["40"] = "36", ["43"] = "47",
	["CircleBorder"] = "SquareBorder",
	["self.isCircle = true"] = "self.isCircle = nil",
	["SetPortraitToTexture%(self.model3d.bg, "] = "self.model3d.bg:SetTexture%(",
}

function InvenUnitFrames:SetDefaultSkinSquare(square)
	if square then
		for unit, values in pairs(self.skins.Default) do
			if type(values.portrait) == "string" and values.portrait:find("^return") then
				for p, v in pairs(swapValues) do
					values.portrait = values.portrait:gsub(p, v)
				end
			end
			if values.comboFrame then
				values.comboFrameBackup = values.comboFrame
				values.comboFrame = nil
			end
		end
	else
		for unit, values in pairs(self.skins.Default) do
			if type(values.portrait) == "string" and values.portrait:find("^return") then
				for p, v in pairs(swapValues) do
					values.portrait = values.portrait:gsub(v, p)
				end
			end
			if values.comboFrameBackup then
				values.comboFrame = values.comboFrameBackup
				values.comboFrameBackup = nil
			end
		end
	end
end

InvenUnitFrames:RegisterSkin("Default", "預設", {
	base = {
		width = 230, height = 50, scale = 0.95,
		portrait = [[
			self:SetPoint("LEFT", object, 0, 0)
			self:SetWidth(70)
			self:SetHeight(70)
			self.isCircle = true
			self.border:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
			self.border:SetWidth(76)
			self.border:SetHeight(76)
			self.border:Show()
			SetPortraitToTexture(self.model3d.bg, "Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
			self.model3d.bg:Show()
		]],
		eliteFrame = [[
			self:SetWidth(140)
			self:SetHeight(140)
			self:SetPoint("CENTER", object.portrait, "CENTER", -8, -3)
		]],
		portrait3DModel = false, combatFeedback = false,
		background1 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMLEFT", 70, 0)
		]],
		highlight = [[
			self:SetAllPoints(object.background1)
		]],
		backdrop = {
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = nil, tileSize = 0, edgeSize = 16,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		},
		backdropColor = { 0, 0, 0, 0.9 },
		backdropBorderColor = { 0, 0, 0 },
		backdropGradient = { "VERTICAL", 0, 0, 0, 0, 0.1, 0.1, 0.1, 1 },
		border1 = [[
			self:SetPoint("TOPLEFT", object.background1, "TOPLEFT", -5, 5)
			self:SetPoint("BOTTOMRIGHT", object.background1, "BOTTOMRIGHT", 5, -5)
		]],
		textFrame = [[
			self:SetPoint("TOPLEFT", object.background1, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.background1, "TOPRIGHT", 0, -18)
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object.textFrame, "BOTTOMLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 0)
		]],
		healthBarTexture = "Smooth v2", healthBarClassColor = true,
		healthText1 = 1, healthText1InCombat = true,
		healthText3 = 2,
		powerBar = [[
			self:SetHeight(max(32 * object.db.powerBarHeight, 0.001))
			self:SetPoint("BOTTOMLEFT", object.background1, "BOTTOMLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.background1, "BOTTOMRIGHT", 0, 0)
		]],
		powerBarHeight = 0.4,
		powerText1 = 1, powerText1InCombat = true,
		powerText3 = 2,
		powerBarTexture = "Smooth v2",
		overlay1 = [[
			self:SetPoint("CENTER", object.powerBar, "BOTTOMLEFT", -10, 2)
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
			self:SetWidth(28)
			self:SetHeight(28)
		]],
		overlay3 = [[
			self:SetDrawLayer("BACKGROUND")
			self:SetAllPoints(object.overlay1)
			SetPortraitToTexture(self, "Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
			self:SetAlpha(0.4)
		]],
		levelText = [[
			self:SetPoint("CENTER", object.overlay1, "CENTER", 1, 1)
		]],
		levelTextFontSize = 12, levelTextFontAttribute = "OUTLINE",
		classIcon = [[
			self:SetPoint("LEFT", object.textFrame, "LEFT", 0, 1)
			self:SetWidth(21)
			self:SetHeight(21)
		]],
		classIconUse = true,
		stateText = [[
			self:SetPoint("RIGHT", object.textFrame, "RIGHT", -2, 1)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.classIcon, "RIGHT", 2, 0)
			self:SetPoint("RIGHT", object.stateText, "LEFT", 0, 0)
			self:SetJustifyH("LEFT")
		]],
		raidIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object.portrait.border, "TOP", 0, -8)
		]],
		raidIconUse = true,
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait.border, "LEFT", 5, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		pvpIconUse = true,
		combatIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object.portrait.border, "BOTTOM", 0, 8)
		]],
		combatIconUse = true,
		leaderIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("BOTTOMLEFT", object.textFrame, "TOPLEFT", 0, -3)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("LEFT", object.leaderIcon, "RIGHT", -2, 0)
		]],
		lootIconUse = true,
		comboFrameOffset = 0,
		comboFrame = [[
			self[1]:SetPoint("BOTTOM", self[2], "TOP", 5, -2)
			self[2]:SetPoint("BOTTOM", self[3], "TOP", 2, 0)
			self[3]:SetPoint("CENTER", object, "LEFT", 3, -1)
			self[4]:SetPoint("TOP", self[3], "BOTTOM", 2, 0)
			self[5]:SetPoint("TOP", self[4], "BOTTOM", 5, 2)
		]],
		topAnchor = "background1", topOffset = 3, topLeftOffset = -2, topRightOffset = 2,
		bottomAnchor = "background1", bottomOffset = 3, bottomLeftOffset = -2, bottomRightOffset = 2,
		rightOffset = 3, leftOffset = -3,
		sideHeight = 56,
	},
	pet = {
		width = 210, scale = 0.7, debuffNum = 6,
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
	},
	pettarget = {
		default = "targettarget",
		width = 110, scale = 0.65,
	},
	target = {
		portrait = [[
			self:SetPoint("RIGHT", object, 0, 0)
			self:SetWidth(70)
			self:SetHeight(70)
			self.isCircle = true
			self.border:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
			self.border:SetWidth(76)
			self.border:SetHeight(76)
			self.border:Show()
			SetPortraitToTexture(self.model3d.bg, "Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
			self.model3d.bg:Show()
		]],
		eliteFrame = [[
			self:SetWidth(140)
			self:SetHeight(140)
			self:SetPoint("CENTER", object.portrait, "CENTER", 8, -3)
		]],
		eliteFrameUse = true,
		background1 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -70, 0)
		]],
		overlay1 = [[
			self:SetPoint("CENTER", object.powerBar, "BOTTOMRIGHT", 10, 2)
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
			self:SetWidth(28)
			self:SetHeight(28)
		]],
		classIcon = [[
			self:SetPoint("RIGHT", object.textFrame, "RIGHT", 0, 1)
			self:SetWidth(21)
			self:SetHeight(21)
		]],
		classIconUse = true,
		stateText = [[
			self:SetPoint("LEFT", object.textFrame, "LEFT", 1, 1)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.stateText, "RIGHT", 0, 0)
			self:SetPoint("RIGHT", object.classIcon, "LEFT", -2, 0)
			self:SetJustifyH("RIGHT")
		]],
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait.border, "RIGHT", -5, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		leaderIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("BOTTOMLEFT", object.textFrame, "TOPRIGHT", 0, -3)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("RIGHT", object.leaderIcon, "LEFT", 2, 0)
		]],
		comboFrame = [[
			self[1]:SetPoint("BOTTOM", self[2], "TOP", -5, -2)
			self[2]:SetPoint("BOTTOM", self[3], "TOP", -2, 0)
			self[3]:SetPoint("CENTER", object, "RIGHT", -3, -1)
			self[4]:SetPoint("TOP", self[3], "BOTTOM", -2, 0)
			self[5]:SetPoint("TOP", self[4], "BOTTOM", -5, 2)
		]],
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	targettarget = {
		width = 115, height = 25, scale = 0.75,
		portrait = [[
			self:SetPoint("LEFT", object, 0, 0)
			self:SetWidth(40)
			self:SetHeight(40)
			self.isCircle = true
			self.border:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
			self.border:SetWidth(43)
			self.border:SetHeight(43)
			self.border:Show()
			SetPortraitToTexture(self.model3d.bg, "Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
			self.model3d.bg:Show()
		]],
		eliteFrame = [[
			self:SetWidth(80)
			self:SetHeight(80)
			self:SetPoint("CENTER", object.portrait, "CENTER", -8, -3)
		]],
		eliteFrameUse = true,
		combatFeedback = false,
		background1 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMLEFT", 40, 0)
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object.background1, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 0)
		]],
		healthText1 = false, healthText3 = 1, healthText3FontSize = 12,
		powerBarHeight = 0.1,
		powerText1 = false, powerText1InCombat = false, powerText3 = false,
		nameText = [[
			self:SetPoint("LEFT", object.healthBar, "LEFT", 0, 1)
			self:SetPoint("RIGHT", object.healthText3, "LEFT", 0, 0)
			self:SetJustifyH("LEFT")
		]],
		nameTextFontSize = 12,
		raidIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object.portrait, "CENTER", 0, 0)
		]],
		overlay1 = false, overlay2 = false, overlay3 = false, levelText = false,
		stateText = false, classIcon = false, pvpIcon = false,
		combatIcon = false, leaderIcon = false, lootIcon = false,
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
		buffBigSize = 15, buffSmallSize = 15, debuffBigSize = 15, debuffSmallSize = 15,
		sideHeight = 30,
	},
	targettargettarget = {
		default = "targettarget",
	},
	focus = {
		default = "target",
	},
	focustarget = {
		default = "targettarget",
	},
	focustargettarget = {
		default = "targettarget",
	},
	party = {
		scale = 0.8, castingBarHeight = 12,
	},
	partypet = {
		scale = 0.7,
		default = "targettarget",
	},
	partytarget = {
		scale = 0.7,
		default = "targettarget",
	},
	boss = {
		scale = 0.65, default = "target",
		pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
})