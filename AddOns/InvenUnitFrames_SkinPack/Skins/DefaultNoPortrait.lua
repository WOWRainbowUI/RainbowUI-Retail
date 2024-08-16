InvenUnitFrames:RegisterSkin("DefaultNoPortrait", "預設 (無頭像)", {
	base = {
		width = 185, height = 50, scale = 0.95,
		eliteFrame = [[
			self:SetWidth(130)
			self:SetHeight(130)
			self:SetPoint("LEFT", object, "LEFT", -48, -2)
		]],
		eliteFrameIsLeft = true,
		background1 = [[
			self:SetAllPoints()
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
		classIcon = [[
			self:SetPoint("LEFT", object.textFrame, "LEFT", 0, 1)
			self:SetWidth(21)
			self:SetHeight(21)
		]],
		classIconUse = true,
		stateText = [[
			self:SetPoint("RIGHT", object.textFrame, "RIGHT", -2, 1)
		]],
		levelText = [[
			self:SetPoint("LEFT", object.classIcon, "RIGHT", 2, 1)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.levelText, "RIGHT", 0, 0)
			self:SetPoint("RIGHT", object.stateText, "LEFT", 0, 0)
			self:SetJustifyH("LEFT")
		]],
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait.border, "LEFT", 5, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		pvpIconUse = true,
		combatIcon = [[
			self:SetWidth(22)
			self:SetHeight(22)
			self:SetPoint("BOTTOMRIGHT", object.textFrame, "TOPRIGHT", 0, -5)
		]],
		combatIconUse = true,
		raidIcon = [[
			self:SetWidth(20)
			self:SetHeight(20)
			self:SetPoint("BOTTOMLEFT", object.textFrame, "TOPLEFT", 0, -5)
		]],
		raidIconUse = true,
		leaderIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("LEFT", object.raidIcon, "RIGHT", 0, 0)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("LEFT", object.leaderIcon, "RIGHT", -2, 0)
		]],
		lootIconUse = true,
		comboFrameOffset = 3, pvpIcon = false, pvpIconUse = false,
		topAnchor = "background1", topOffset = 3, topLeftOffset = -2, topRightOffset = 2,
		bottomAnchor = "background1", bottomOffset = 3, bottomLeftOffset = -2, bottomRightOffset = 2,
		rightOffset = 3, leftOffset = -3,
		sideHeight = 56,
	},
	pet = {
		scale = 0.7, debuffNum = 6,
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
	},
	pettarget = {
		default = "targettarget",
		width = 110, scale = 0.65,
	},
	target = {
		eliteFrame = [[
			self:SetWidth(130)
			self:SetHeight(130)
			self:SetPoint("RIGHT", object, "RIGHT", 48, -2)
		]],
		eliteFrameUse = true, eliteFrameIsLeft = false,
		background1 = [[
			self:SetAllPoints()
		]],
		classIcon = [[
			self:SetPoint("RIGHT", object.textFrame, "RIGHT", 0, 1)
			self:SetWidth(21)
			self:SetHeight(21)
		]],
		classIconUse = true,
		levelText = [[
			self:SetPoint("RIGHT", object.classIcon, "LEFT", 0, 1)
		]],
		stateText = [[
			self:SetPoint("LEFT", object.textFrame, "LEFT", 1, 1)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.stateText, "RIGHT", 0, 1)
			self:SetPoint("RIGHT", object.levelText, "LEFT", 0, 0)
			self:SetJustifyH("RIGHT")
		]],
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait.border, "RIGHT", -5, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		combatIcon = [[
			self:SetWidth(22)
			self:SetHeight(22)
			self:SetPoint("BOTTOMLEFT", object.textFrame, "TOPLEFT", 0, -5)
		]],
		combatIconUse = true,
		raidIcon = [[
			self:SetWidth(20)
			self:SetHeight(20)
			self:SetPoint("BOTTOMRIGHT", object.textFrame, "TOPRIGHT", 0, -5)
		]],
		raidIconUse = true,
		leaderIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("RIGHT", object.raidIcon, "LEFT", 0, 0)
		]],
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("RIGHT", object.leaderIcon, "LEFT", 2, 0)
		]],
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	targettarget = {
		width = 115, height = 30, scale = 0.7,
		eliteFrame = [[
			self:SetWidth(78)
			self:SetHeight(78)
			self:SetPoint("LEFT", object, "LEFT", -24, -1)
		]],
		eliteFrameUse = true,
		background1 = [[
			self:SetAllPoints()
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object.background1, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 0)
		]],
		healthText1 = false, healthText3 = 1, healthText3FontSize = 13,
		powerBarHeight = 0.1,
		powerText1 = false, powerText1InCombat = false, powerText3 = false,
		nameText = [[
			self:SetPoint("LEFT", object.raidIcon, "RIGHT", 0, 1)
			self:SetPoint("RIGHT", object.healthText3, "LEFT", 0, 0)
			self:SetJustifyH("LEFT")
		]],
		nameTextFontSize = 13,
		raidIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("LEFT", object.healthBar, "LEFT", 0, 0)
		]],
		levelText = false, stateText = false, classIcon = false, pvpIcon = false,
		combatIcon = false, leaderIcon = false, lootIcon = false,
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
		buffBigSize = 15, buffSmallSize = 15, debuffBigSize = 15, debuffSmallSize = 15,
		sideHeight = 35,
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
		default = "target", scale = 0.65, pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
}, {
	targettarget = { 205, 0 },
	targettargettarget = { 205, -30 },
	focustarget = { 205, 0 },
	focustargettarget = { 205, -30 },
	party = { 14, -154 },
	partytarget = { 195, 0 },
	partypet = { 195, -30 },

})