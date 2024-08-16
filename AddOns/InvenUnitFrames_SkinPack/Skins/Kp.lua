InvenUnitFrames:RegisterSkin("Kp", nil, {
	base = {
		width = 220, height = 65, scale = 1,
		background1 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpBG")
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -8, 8)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 70, -8)
			self:SetTexCoord(0, 0.609375, 0, 0.6328125)
		]],
		background2 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpBG")
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 8, 8)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -22, -8)
			self:SetTexCoord(0.765625, 1, 0, 0.6328125)
		]],
		background3 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpBG")
			self:SetPoint("TOPLEFT", object.background1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.background2, "BOTTOMLEFT", 0, 0)
			self:SetTexCoord(0.609375, 0.765625, 0, 0.6328125)
		]],
		portrait = [[
			self:SetPoint("TOPLEFT", 9, -8)
			self:SetWidth(49)
			self:SetHeight(49)
		]],
		portrait3DModel = false, combatFeedback = false,
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 69, -20)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -10, -38)
		]],
		healthBarTexture = "Flat Smooth", healthBarClassColor = true,
		healthText1 = 2, healthText1FontSize = 12, healthText1FontAttribute = "OUTLINE", healthText1FontShadow = false,
		healthText3 = 1, healthText3FontSize = 12, healthText3FontAttribute = "OUTLINE", healthText3FontShadow = false,
		powerBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 69, -46)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -10, -57)
		]],
		powerBarHeight = false,
		powerBarTexture = "Flat Smooth",
		powerText1 = 2, powerText1FontSize = 12, powerText1FontAttribute = "OUTLINE", powerText1FontShadow = false,
		powerText3 = 1, powerText3FontSize = 12, powerText3FontAttribute = "OUTLINE", powerText3FontShadow = false,
		classText = [[
			self:SetPoint("BOTTOMRIGHT", object.healthBar, "TOPRIGHT", 4, 4)
		]],
		classTextFontSize = 12, classTextFontAttribute = "OUTLINE",
		stateText = [[
			self:SetPoint("BOTTOMRIGHT", object.classText, "BOTTOMLEFT", -2, 0)
		]],
		stateTextFontSize = 12, stateTextFontAttribute = "OUTLINE",
		levelText = [[
			self:SetPoint("BOTTOM", object.portrait, "TOP", -3, 3)
		]],
		levelTextFontSize = 15, levelTextFontAttribute = "OUTLINE",
		nameText = [[
			self:SetPoint("LEFT", object.levelText, "RIGHT", 0, 0)
		]],
		nameTextClassColor = true, nameTextFontSize = 14, nameTextFontAttribute = "OUTLINE",
		raidIcon = [[
			self:SetWidth(18)
			self:SetHeight(18)
			self:SetPoint("RIGHT", object.levelText, "LEFT", 0, 0)
		]],
		raidIconUse = true,
		combatIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("LEFT", object, "RIGHT", -9, 0)
		]],
		combatIconUse = true,
		pvpIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("RIGHT", object, "LEFT", 7, 0)
		]],
		pvpIconUse = true,
		leaderIcon = [[
			self:SetWidth(18)
			self:SetHeight(18)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -4)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("RIGHT", object.leaderIcon, "LEFT", 0, 0)
		]],
		lootIconUse = true,
		bottomOffset = -2, bottomLeftOffset = 8, bottomRightOffset = -8,
	},
	target = {
		background1 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpBG")
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -8, 8)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 23, -8)
			self:SetTexCoord(1, 0.765625, 0, 0.6328125)
		]],
		background2 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpBG")
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 8, 8)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -70, -8)
			self:SetTexCoord(0.609375, 0, 0, 0.6328125)
		]],
		portrait = [[
			self:SetPoint("TOPRIGHT", -9, -8)
			self:SetWidth(49)
			self:SetHeight(49)
		]],
		healthBar = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", -69, -20)
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 10, -39)
		]],
		healthText1 = 1, healthText3 = 2,
		powerBar = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", -68, -46)
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 10, -57)
		]],
		powerText1 = 1, powerText3 = 2,
		classText = [[
			self:SetPoint("BOTTOMLEFT", object.healthBar, "TOPLEFT", -3, 4)
		]],
		stateText = [[
			self:SetPoint("BOTTOMLEFT", object.classText, "BOTTOMRIGHT", 0, 0)
		]],
		levelText = [[
			self:SetPoint("BOTTOM", object.portrait, "TOP", 5, 3)
		]],
		nameText = [[
			self:SetPoint("RIGHT", object.levelText, "LEFT", 0, 0)
		]],
		raidIcon = [[
			self:SetWidth(18)
			self:SetHeight(18)
			self:SetPoint("LEFT", object.levelText, "RIGHT", 0, 0)
		]],
		combatIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("RIGHT", object, "LEFT", 12, 0)
		]],
		pvpIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("LEFT", object, "RIGHT", -8, 0)
		]],
		comboOffset = -8,
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	targettarget = {
		width = 90, height = 30, scale = 1,
		background1 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpMiniBG")
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -8, 8)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 13, -8)
			self:SetTexCoord(0, 0.3125, 0, 0.71875)
		]],
		background2 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpMiniBG")
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 8, 8)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -12, -8)
			self:SetTexCoord(0.6875, 1, 0, 0.71875)
		]],
		background3 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\KpMiniBG")
			self:SetPoint("TOPLEFT", object.background1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.background2, "BOTTOMLEFT", 0, 0)
			self:SetTexCoord(0.3125, 0.6875, 0, 0.71875)
		]],
		portrait = false,
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 6, -6)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -6, 8)
		]],
		healthText1 = false, healthText3FontSize = 10,
		powerBar = [[
			self:SetPoint("TOPLEFT", object.healthBar, "BOTTOMLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -6, 6)
		]],
		powerText1 = false, powerText3 = false,
		classText = false, stateText = false, levelText = false,
		nameText = [[
			self:SetJustifyH("LEFT")
			self:SetPoint("LEFT", object.healthText1, "LEFT", 0, 0)
			self:SetPoint("RIGHT", object.healthText3, "LEFT", 0, 0)
		]],
		nameTextClassColor = false, nameTextFontSize = 10, nameTextFontShadow = false,
		raidIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("RIGHT", object, "LEFT", 7, 0)
		]],
		raidIconUse = true, combatIcon = false, pvpIcon = false, leaderIcon = false, lootIcon = false,
		bottomAnchor = "powerBar", bottomOffset = 4, bottomLeftOffset = 0, bottomRightOffset = 0,
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
		buffBigSize = 15, buffSmallSize = 15, debuffBigSize = 15, debuffSmallSize = 15,
	},
	pet = {
		width = 230, scale = 0.62,
	},
	pettarget = {
		default = "targettarget",
		scale = 0.8,
	},
	party = {
		width = 230, scale = 0.77,
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
	partypet = {
		default = "targettarget",
	},
	partytarget = {
		default = "targettarget",
	},
	partytargettarget = {
		default = "targettarget",
	},
	boss = {
		default = "target", scale = 0.65, pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
}, {
	pet = { 0, -78 },
	pettarget = { 173, -87 },
	targettarget = { 229, 2 },
	targettargettarget = { 229, -37 },
	focustarget = { 229, 2 },
	focustargettarget = { 229, -37 },
	party = { 10, -154 },
	partypet = { 240, -37 },
	partytarget = { 240, 2 },

})