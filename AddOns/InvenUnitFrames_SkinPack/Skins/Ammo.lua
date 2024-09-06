InvenUnitFrames:RegisterSkin("Ammo", nil, {
	base = {
		width = 205, height = 40, scale = 1,
		background1 = [[
			self:SetAllPoints()
			self:SetTexture(0, 0, 0, 0.75)
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", 1, -1)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "TOPRIGHT", 0, 0)
		]],
		powerBar = [[
			self:SetHeight(max((object.db.height - 2) * object.db.powerBarHeight, 0.001))
			self:SetPoint("BOTTOMLEFT", 1, 1)
			self:SetPoint("BOTTOMRIGHT", -1, 1)
		]],
		powerBarHeight = 0.5,
		healthBarClassColor = true, healthText3 = 5, powerText3 = 5,
		healthText1FontSize = 11, healthText2FontSize = 11, healthText3FontSize = 11, healthText4FontSize = 11, healthText5FontSize = 11,
		powerText1FontSize = 11, powerText2FontSize = 11, powerText3FontSize = 11, powerText4FontSize = 11, powerText5FontSize = 11,
		raidIcon = [[
			self:SetPoint("LEFT", object.healthBar, "LEFT", 0, 0)
			self:SetHeight(16)
			self:SetHeight(16)
		]],
		raidIconUse = true,
		stateText = [[
			self:SetPoint("LEFT", object.raidIcon, "RIGHT", 0, 1)
		]],
		stateTextFontSize = 11,
		nameText = [[
--			self:SetPoint("LEFT", object.stateText, "RIGHT", 2, 0)
			self:SetPoint("LEFT", object.healthBar, "LEFT", 2, 1)
			self:SetPoint("RIGHT", object.healthText3, "LEFT", -1, 0)
			self:SetJustifyH("LEFT")
		]],
		nameTextFontSize = 11,
		levelText = [[
			self:SetPoint("LEFT", object.powerBar, "LEFT", 2, 1)
		]],
		levelTextFontSize = 11,
		classText = [[
			self:SetPoint("BOTTOMLEFT", object.levelText, "BOTTOMRIGHT", 1, 0)
			self:SetPoint("RIGHT", object.powerText3, "LEFT", -1, 0)
			self:SetJustifyH("LEFT")
		]],
		classTextFontSize = 11,
		raidIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object, "TOP", 0, -8)
		]],
		raidIconUse = true,
		pvpIcon = [[
			self:SetPoint("CENTER", object, "LEFT", 5, 0)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		pvpIconUse = true,
		combatIcon = [[
			self:SetPoint("CENTER", object, "LEFT", 0, 0)
			self:SetWidth(20)
			self:SetHeight(20)
		]],
		combatIconUse = true,
		leaderIcon = [[
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, -6)
			self:SetWidth(18)
			self:SetHeight(18)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetPoint("LEFT", object.leaderIcon, "RIGHT", 0, 0)
			self:SetWidth(14)
			self:SetHeight(14)
		]],
		lootIconUse = true,
		comboFrameOffset = 0,
		aggroBorder = [[
			self:SetPoint("TOPLEFT", -2, 2)
			self:SetPoint("BOTTOMRIGHT", 2, -2)
		]],
		eliteFrame = [[
			self:SetFrameLevel(object:GetFrameLevel() + 1)
			self:SetWidth(92)
			self:SetHeight(92)
			self:SetPoint("CENTER", object, "LEFT", 14, -2)
		]],
	},
	pet = {
		width = 160, height = 36,
		buffNum = 6, buffSmallSize = 13, buffBigSize = 13,
		debuffNum = 6, debuffSmallSize = 13, debuffBigSize = 13,
		eliteFrame = false,
	},
	pettarget = {
		default = "targettarget",
	},
	target = {
		comboOffset = 1, comboScale = 0.66,
		eliteFrame = [[
			self:SetFrameLevel(object:GetFrameLevel() + 1)
			self:SetWidth(92)
			self:SetHeight(92)
			self:SetPoint("CENTER", object, "RIGHT", -14, -2)
		]], eliteFrameUse = true,
		pvpIcon = [[
			self:SetPoint("CENTER", object, "RIGHT", 0, 0)
			self:SetWidth(20)
			self:SetHeight(20)
		]],		
		pvpIconUse = true,
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	targettarget = {
		width = 80, height = 20,
		powerBarHeight = 0.1,
		raidIcon = [[
			self:SetPoint("LEFT", object.healthBar, "LEFT", 0, 0)
			self:SetHeight(12)
			self:SetHeight(12)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.raidIcon, "RIGHT", 0, 1)
			self:SetPoint("RIGHT", object.healthText3, "LEFT", -1, 0)
			self:SetJustifyH("LEFT")
		]],
		healthText3 = 1, powerText3 = false,
		levelText = false, classText = false, stateText = false,
		combatIcon = false, combatIconUse = false,
		pvpIconUse = false,
		leaderIcon = false, leaderIconUse = false,
		lootIcon = false, lootIconUse = false,
		nameTextFontSize = 9, healthText3FontSize = 9,
		buffSmallSize = 10, buffBigSize = 10,
		debuffSmallSize = 10, debuffBigSize = 10,
		eliteFrame = false, eliteFrameUse = false,
	},
	targettargettarget = {
		default = "targettarget",
	},
	focustarget = {
		default = "targettarget",
	},
	focustargettarget = {
		default = "targettarget",
	},
	party = {
		scale = 0.9,
	},
	partytarget = {
		width = 65,
		default = "targettarget",
	},
	partypet = {
		width = 65,
		default = "targettarget",
	},
	boss = {
		default = "target", width = 180, scale = 0.7, bossOffset = 17, pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
}, {
	pet = { 0, -54 },
	pettarget = { 80, -97 },
	party = { 14, -154 },
	partytarget = { 208, 0 },
	partypet = { 208, -25 },
	targettarget = { 216, 0 },
	targettargettarget = { 216, -25 },
	focustarget = { 216, 0 },
	focustargettarget = { 216, -25 },

})