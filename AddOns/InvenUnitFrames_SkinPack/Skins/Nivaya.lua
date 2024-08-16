InvenUnitFrames:RegisterSkin("Nivaya", nil, {
	base = {
		width = 200, height = 50, scale = 1,
		background1 = [[
			self:SetAllPoints()
			self:SetTexture(0, 0, 0, 0.75)
		]],
		topOffset = 14,
		topLeftOffset = 1, topRightOffset = -1, bottomLeftOffset = 1, bottomRightOffset = -1,
		healthBar = [[
			self:SetPoint("TOPLEFT", 1, -1)
			self:SetPoint("TOPRIGHT", -1, -1)
			self:SetHeight(height / 3.3)
		]],
		healthBarClassColor = true,
		powerBar = [[
			self:SetPoint("BOTTOMLEFT", 1, 1)
			self:SetPoint("BOTTOMRIGHT", -1, 1)
			self:SetHeight(height / 3.3)
		]],
		powerBarHeight = false,
		portrait = [[
			height = floor(height / 3.3)
			self:SetPoint("TOPLEFT", 1, -(height + 1))
			self:SetPoint("BOTTOMRIGHT", -1, height + 1)
		]],
		portrait3DModel = false,
		classIcon = [[
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, 0)
			self:SetWidth(17)
			self:SetHeight(17)
		]],
		classIconUse = true,
		levelText = [[
			self:SetPoint("BOTTOMLEFT", object.classIcon, "BOTTOMRIGHT", 0, 2)
		]],
		stateText = [[
			self:SetPoint("BOTTOMRIGHT", object.combatIcon, "BOTTOMLEFT", 0, 5)
		]],
		nameText = [[
			self:SetPoint("BOTTOMLEFT", object.levelText, "BOTTOMRIGHT", 1, 0)
			self:SetPoint("BOTTOMRIGHT", object.stateText, "BOTTOMLEFT", -1, 0)
			self:SetJustifyH("LEFT")
		]],
		levelTextFontShadow = false, levelTextFontAttribute = "OUTLINE",
		nameTextFontShadow = false, nameTextFontAttribute = "OUTLINE",
		stateTextFontShadow = false, stateTextFontAttribute = "OUTLINE",
		healthText1FontSize = 11, healthText1FontShadow = false, healthText1FontAttribute = "OUTLINE",
		healthText2FontSize = 11, healthText2FontShadow = false, healthText2FontAttribute = "OUTLINE",
		healthText3FontSize = 11, healthText3FontShadow = false, healthText3FontAttribute = "OUTLINE",
		healthText4FontSize = 11, healthText4FontShadow = false, healthText4FontAttribute = "OUTLINE",
		healthText5FontSize = 11, healthText5FontShadow = false, healthText5FontAttribute = "OUTLINE",
		powerText1FontSize = 11, powerText1FontShadow = false, powerText1FontAttribute = "OUTLINE",
		powerText2FontSize = 11, powerText2FontShadow = false, powerText2FontAttribute = "OUTLINE",
		powerText3FontSize = 11, powerText3FontShadow = false, powerText3FontAttribute = "OUTLINE",
		powerText4FontSize = 11, powerText4FontShadow = false, powerText4FontAttribute = "OUTLINE",
		powerText5FontSize = 11, powerText5FontShadow = false, powerText5FontAttribute = "OUTLINE",
		healthText1 = 2, healthText3 = 1, powerText1 = 2, powerText3 = 1,
		buffSmallSize = 18, debuffSmallSize = 18,
		raidIcon = [[
			height = floor(height / 3.3)
			self:SetPoint("RIGHT", object.portrait, "RIGHT", -2, 0)
			self:SetWidth(height)
			self:SetHeight(height)
		]],
		raidIconUse = true,
		pvpIcon = [[
			height = floor(height / 3.3)
			self:SetPoint("LEFT", object.portrait, "LEFT", 2, 0)
			self:SetWidth(height)
			self:SetHeight(height)
		]],
		pvpIconUse = true,
		leaderIcon = [[
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 4, -1)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetPoint("BOTTOMRIGHT", object.leaderIcon, "BOTTOMLEFT", 0, 2)
			self:SetWidth(16)
			self:SetHeight(16)
		]],
		lootIconUse = true,
		combatIcon = [[
			self:SetPoint("BOTTOMRIGHT", object.lootIcon, "BOTTOMLEFT", 0, -4)
			self:SetWidth(24)
			self:SetHeight(24)
		]],
		combatIconUse = true,
		aggroBorder = [[
			self:SetPoint("TOPLEFT", -2, 2)
			self:SetPoint("BOTTOMRIGHT", 2, -2)
		]],
	},
	pet = {
		width = 160, height = 40, scale = 0.8,
		healthText1FontSize = 10, healthText2FontSize = 10, healthText3FontSize = 10,
		powerText1FontSize = 10, powerText2FontSize = 10, powerText3FontSize = 10,
		healthBar = [[
			self:SetPoint("TOPLEFT", 1, -1)
			self:SetPoint("TOPRIGHT", -1, -1)
			self:SetHeight(height / 3)
		]],
		powerBar = [[
			self:SetPoint("BOTTOMLEFT", 1, 1)
			self:SetPoint("BOTTOMRIGHT", -1, 1)
			self:SetHeight(height / 3)
		]],
		portrait = [[
			height = floor(height / 3)
			self:SetPoint("TOPLEFT", 1, -(height + 1))
			self:SetPoint("BOTTOMRIGHT", -1, height + 1)
		]],
		pvpIcon = false, pvpIconUse = false,
	},
	pettarget = {
		default = "targettarget",
	},
	target = {
		classIcon = [[
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, 0)
			self:SetWidth(17)
			self:SetHeight(17)
		]],
		classIconUse = true,
		levelText = [[
			self:SetPoint("BOTTOMRIGHT", object.classIcon, "BOTTOMLEFT", 0, 2)
		]],
		stateText = [[
			self:SetPoint("BOTTOMLEFT", object.combatIcon, "BOTTOMRIGHT", 0, 5)
		]],
		nameText = [[
			self:SetPoint("BOTTOMLEFT", object.stateText, "BOTTOMRIGHT", 1, 0)
			self:SetPoint("BOTTOMRIGHT", object.levelText, "BOTTOMLEFT", -1, 0)
			self:SetJustifyH("RIGHT")
		]],
		healthText1 = 1, healthText3 = 2, powerText1 = 1, powerText3 = 2,
		raidIcon = [[
			height = floor(height / 3.3)
			self:SetPoint("LEFT", object.portrait, "LEFT", 2, 0)
			self:SetWidth(height)
			self:SetHeight(height)
		]],
		pvpIcon = [[
			height = floor(height / 3.3)
			self:SetPoint("RIGHT", object.portrait, "RIGHT", -2, 0)
			self:SetWidth(height)
			self:SetHeight(height)
		]],
		leaderIcon = [[
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", -4, -1)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		lootIcon = [[
			self:SetPoint("BOTTOMLEFT", object.leaderIcon, "BOTTOMRIGHT", 0, 2)
			self:SetWidth(16)
			self:SetHeight(16)
		]],
		combatIcon = [[
			self:SetPoint("BOTTOMLEFT", object.lootIcon, "BOTTOMRIGHT", 0, -4)
			self:SetWidth(24)
			self:SetHeight(24)
		]],
		comboOffset = 1, comboScale = 0.86,
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	targettarget = {
		width = 70, height = 18,
		portrait = false,
		healthBar = [[
			self:SetPoint("TOPLEFT", 1, -1)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 1)
		]],
		powerBar = [[
			self:SetPoint("BOTTOMLEFT", 1, 1)
			self:SetPoint("BOTTOMRIGHT", -1, 1)
			self:SetHeight(3)
		]],
		raidIcon = [[
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, 2)
			self:SetWidth(12)
			self:SetHeight(12)
		]],
		stateText = false,
		nameText = [[
			self:SetPoint("BOTTOMLEFT", object.levelText, "BOTTOMRIGHT", -3, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, 2)
			self:SetJustifyH("LEFT")
		]],
		levelText = [[
			self:SetPoint("BOTTOMLEFT", object.raidIcon, "BOTTOMRIGHT", 0, 0)
		]],
		nameTextFontSize = 9, levelTextFontSize = 9,
		healthText2FontSize = 9, powerText2FontSize = 9,
		healthText1 = false, healthText2 = 1, healthText3 = false, powerText1 = false, powerText2 = false, powerText3 = false,
		buffSmallSize = 12, buffBigSize = 18, debuffSmallSize = 12, debuffBigSize = 18,
		pvpIcon = false, pvpIconUse = false, classIcon = false, classIconUse = false,
	},
	targettargettarget = {
		default = "targettarget"
	},
	focus = {
		default = "target",
	},
	focustarget = {
		default = "targettarget"
	},
	focustargettarget = {
		default = "targettarget"
	},
	party = {
		width = 190, scale = 0.9,
		castingBarHeight = 10,
	},
	partypet = {
		default = "targettarget"
	},
	partytarget = {
		default = "targettarget"
	},
	boss = {
		default = "target", scale = 0.7, width = 160, bossOffset = 32, pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
}, {
	pet = { 0, -74 },
	pettarget = { 164, -83 },
	target = { 277, -26 },
	targettarget = { 202, 0 },
	targettargettarget = { 202, -32 },
	focustarget = { 202, 0 },
	focustargettarget = { 202, -32 },
	party = { 14, -154 },
	partytarget = { 192, 0 },
	partypet = { 192, -32 },
})