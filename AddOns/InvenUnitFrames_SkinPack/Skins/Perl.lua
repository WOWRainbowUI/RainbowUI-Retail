InvenUnitFrames:RegisterSkin("Perl", nil, {
	base = {
		width = 224, height = 56, scale = 1,
		backdrop = {
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 32, edgeSize = 12,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		},
		backdropColor = { 0, 0, 0, 1 },
		backdropBorderColor = { 1, 1, 1 },
		backdropGradient = { "VERTICAL", 0.1, 0.1, 0.1, 0, 0.25, 0.25, 0.25, 1 },
		border1 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -2, 2)
			self:SetWidth(height + 4)
			self:SetHeight(height + 4)
		]],
		border2 = [[
			self:SetPoint("TOPLEFT", object.border1, "TOPRIGHT", -2, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 2, -22)
		]],
		border3 = [[
			self:SetPoint("TOPLEFT", object.border2, "BOTTOMLEFT", 0, 2)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 2, -2)
		]],
		portrait = [[
			self:SetPoint("TOPLEFT", object.border1, "TOPLEFT", 3, -3)
			self:SetPoint("BOTTOMRIGHT", object.border1, "BOTTOMRIGHT", -3, 3)
		]],
		portrait3DModel = false,
		eliteFrame = [[
			self:SetWidth(144)
			self:SetHeight(144)
			self:SetPoint("CENTER", object.portrait, "CENTER", -11, -3)
		]],
		levelText = [[
			self:SetPoint("LEFT", object.border2, "LEFT", 4, 1)
		]],
		levelTextFontSize = 12,
		classIcon = [[
			self:SetPoint("LEFT", object.levelText, "RIGHT", 1, -1)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		classIconUse = true,
		nameText = [[
			self:SetPoint("LEFT", object.classIcon, "RIGHT", 1, 1)
			self:SetPoint("RIGHT", object.stateText, "LEFT", 0, 0)
			self:SetJustifyH("LEFT")
		]],
		nameTextClassColor = true, nameTextFontSize = 12,
		raidIcon = [[
			self:SetPoint("RIGHT", object.border2, "RIGHT", -5, 0)
			self:SetWidth(16)
			self:SetHeight(16)
		]],
		raidIconUse = true,
		stateText = [[
			self:SetPoint("RIGHT", object.raidIcon, "LEFT", -1, 1)
		]],
		stateTextFontSize = 12,
		healthBar = [[
			self:SetPoint("TOPLEFT", object.border3, "TOPLEFT", 3, -3)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 0)
		]],
		healthBarTexture = "BantoBar",
		healthText2 = 2, healthText5 = 1,
		healthText2FontSize = 12, healthText4FontSize = 11, healthText5FontSize = 11,
		powerBar = [[
			self:SetHeight(max(31 * object.db.powerBarHeight, 0.001))
			self:SetPoint("BOTTOMLEFT", object.border3, "BOTTOMLEFT", 3, 4)
			self:SetPoint("BOTTOMRIGHT", object.border3, "BOTTOMRIGHT", -40, 4)
		]],
		powerBarHeight = 0.4,
		powerBarTexture = "BantoBar",
		powerText2 = 2, powerText5 = 1,
		powerText2FontSize = 12, powerText4FontSize = 11, powerText5FontSize = 11,
		classBarTopOffset = 0, classBarBottomOffset = 4, bottomOffset = -1, topOffset = 1,
		topAnchor = "border2", topLeftOffset = 4, topRightOffset = -4,
		bottomAnchor = "border3", bottomLeftOffset = 4, bottomRightOffset = -4,
		leaderIcon = [[
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, -3)
			self:SetWidth(16)
			self:SetHeight(16)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetPoint("LEFT", object.leaderIcon, "RIGHT", 0, 0)
			self:SetWidth(14)
			self:SetHeight(14)
		]],
		lootIconUse = true,
		combatIcon = [[
			self:SetPoint("CENTER", object.border3, "RIGHT", 0, 0)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		combatIconUse = true,
		aggroBorder = [[
			self:SetPoint("TOPLEFT", object.border2, "TOPLEFT", 3, -3)
			self:SetPoint("BOTTOMRIGHT", object.border3, "BOTTOMRIGHT", -3, 3)
		]],
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait, "LEFT", -2, 0)
			self:SetWidth(24)
			self:SetHeight(24)
		]],
		pvpIconUse = true,
	},
	pet = {
		width = 180, height = 50, scale = 0.9,
		border1 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -2, -15)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 22, -2)
		]],
		border2 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -2, 2)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 2, -17)
		]],
		border3 = [[
			self:SetPoint("TOPLEFT", object.border1, "TOPRIGHT", -2, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 2, -2)
		]],
		portrait = false, eliteFrame = false, eliteFrameUse = false,
		healthBar = [[
			self:SetPoint("TOPLEFT", object.border3, "TOPLEFT", 3, -4)
			self:SetPoint("BOTTOMRIGHT", object.border3, "BOTTOMRIGHT", -40, 14)
		]],
		healthText2FontSize = 11, powerText2FontSize = 11,
		levelText = [[
			self:SetPoint("BOTTOM", object.border1, "BOTTOM", 0, 4)
		]],
		classIcon = [[
			self:SetPoint("TOP", object.border1, "TOP", 0, -2)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.border2, "LEFT", 5, 1)
			self:SetPoint("RIGHT", object.stateText, "LEFT", 0, 0)
			self:SetJustifyH("LEFT")
		]],
		buffSmallSize = 16, buffBigSize = 16, debuffSmallSize = 16, debuffBigSize = 16,
		aggroBorder = false, pvpIcon = false, pvpIconUse = false,
	},
	pettarget = {
		default = "targettarget",
	},
	target = {
		border1 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 2, 2)
			self:SetWidth(height + 4)
			self:SetHeight(height + 4)
		]],
		border2 = [[
			self:SetPoint("TOPRIGHT", object.border1, "TOPLEFT", 2, 0)
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", -2, -22)
		]],
		border3 = [[
			self:SetPoint("TOPLEFT", object.border2, "BOTTOMLEFT", 0, 2)
			self:SetPoint("BOTTOMRIGHT", object.border1, "BOTTOMLEFT", 2, 0)
		]],
		portrait = [[
			self:SetPoint("TOPRIGHT", object.border1, "TOPRIGHT", -3, -3)
			self:SetPoint("BOTTOMLEFT", object.border1, "BOTTOMLEFT", 3, 3)
		]],
		eliteFrame = [[
			self:SetWidth(144)
			self:SetHeight(144)
			self:SetPoint("CENTER", object.portrait, "CENTER", 11, -3)
		]],
		eliteFrameUse = true,
		levelText = [[
			self:SetPoint("RIGHT", object.border2, "RIGHT", -4, 1)
		]],
		classIcon = [[
			self:SetPoint("RIGHT", object.levelText, "LEFT", -1, -1)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		nameText = [[
			self:SetPoint("RIGHT", object.classIcon, "LEFT", -1, 1)
			self:SetPoint("LEFT", object.stateText, "RIGHT", 0, 0)
			self:SetJustifyH("RIGHT")
		]],
		raidIcon = [[
			self:SetPoint("LEFT", object.border2, "LEFT", 5, 0)
			self:SetWidth(16)
			self:SetHeight(16)
		]],
		stateText = [[
			self:SetPoint("LEFT", object.raidIcon, "RIGHT", 1, 1)
		]],
		healthBar = [[
			self:SetPoint("TOPRIGHT", object.border3, "TOPRIGHT", -3, -3)
			self:SetPoint("BOTTOMLEFT", object.powerBar, "TOPLEFT", 0, 0)
		]],
		healthText4 = 1, healthText5 = false,
		powerBar = [[
			self:SetHeight(max(31 * object.db.powerBarHeight, 0.001))
			self:SetPoint("BOTTOMLEFT", object.border3, "BOTTOMLEFT", 40, 4)
			self:SetPoint("BOTTOMRIGHT", object.border3, "BOTTOMRIGHT", -3, 4)
		]],
		powerText4 = 1, powerText5 = false,
		leaderIcon = [[
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -3)
			self:SetWidth(16)
			self:SetHeight(16)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetPoint("RIGHT", object.leaderIcon, "LEFT", 0, 0)
			self:SetWidth(14)
			self:SetHeight(14)
		]],
		lootIconUse = true,
		combatIcon = [[
			self:SetPoint("CENTER", object.border3, "LEFT", 0, 0)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait, "RIGHT", 2, 0)
			self:SetWidth(24)
			self:SetHeight(24)
		]],
	},
	targettarget = {
		width = 68, height = 32, scale = 0.8,
		border1 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -4, 4)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 4, -4)
		]],
		border2 = false, border3 = false,
		textFrame = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -15)
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object.textFrame, "BOTTOMLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 0)
		]],
		healthText2 = 1, healthText5 = false,
		powerBar = [[
			self:SetHeight(max((object.db.height - 15) * object.db.powerBarHeight, 0.001))
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 0, 0)
		]],
		powerBarHeight = 0.2,
		powerText2 = false, powerText5 = false,
		portrait = false, combatFeedback = false,
		levelText = false, stateText = false, classIcon = false,
		nameText = [[
			self:SetPoint("TOPLEFT", object.textFrame, "TOPLEFT", 0, 2)
			self:SetPoint("BOTTOMRIGHT", object.textFrame, "BOTTOMRIGHT", 0, 2)

			self:SetJustifyH("CENTER")
		]],
		raidIcon = [[
			self:SetPoint("CENTER", object, "TOP", 0, 0)
			self:SetWidth(18)
			self:SetHeight(18)
		]],
		eliteFrame = [[
			self:SetWidth(85)
			self:SetHeight(85)
			self:SetPoint("CENTER", object, "LEFT", 11, -2)
		]],
		eliteFrameUse = true,
		topAnchor = false, topLeftOffset = 0, topRightOffset = 0,
		bottomAnchor = false, bottomLeftOffset = 0, bottomRightOffset = 0,
		leftOffset = -3, rightOffset = 3, bottomOffset = 3, topOffset = 3, pvpIcon = false, pvpIconUse = false,
		leaderIcon = false, leaderIconUse = false, lootIcon = false, lootIconUse = false, combatIcon = false, combatIconUse = false,
		buffSmallSize = 17, buffBigSize = 17, debuffSmallSize = 17, debuffBigSize = 17, aggroBorder = false,
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
		default = "pet",
		scale = 1, castingBarHeight = 11, partyOffset = 56,
	},
	partypet = {
		default = "targettarget",
		height = 25,
		buffSmallSize = 14, buffBigSize = 14, debuffSmallSize = 14, debuffBigSize = 14,
	},
	partytarget = {
		default = "targettarget",
		height = 25,
		buffSmallSize = 14, buffBigSize = 14, debuffSmallSize = 14, debuffBigSize = 14,
	},
	boss = {
		default = "target", scale = 0.65, bossOffset = 22, pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
}, {
	pet = { 0, -67 },
	pettarget = { 202, -80 },
	targettarget = { 169, -62 },
	targettargettarget = { 169, -96 },
	focustarget = { 169, -62 },
	focustargettarget = { 169, -96 },
	party = { 6, -160 },
	partytarget = { 186, -1 },
	partypet = { 186, -29 },


})