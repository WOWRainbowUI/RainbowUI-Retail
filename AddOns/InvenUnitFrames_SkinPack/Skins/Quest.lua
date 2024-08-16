InvenUnitFrames:RegisterSkin("Quest", "任務", {
	base = {
		width = 230, height = 60, scale = 1,
		background1 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestBG")
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -1, 2)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 68, -2)
			self:SetTexCoord(0, 0.5390625, 0, 1)
		]],
		background2 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestBG")
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 1, 2)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -11, -2)
			self:SetTexCoord(0.90625, 1, 0, 1)
		]],
		background3 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestBG")
			self:SetPoint("TOPLEFT", object.background1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.background2, "BOTTOMLEFT", 0, 0)
			self:SetTexCoord(0.5390625, 0.90625, 0, 1)
		]],
		portrait = [[
			self:SetPoint("TOPLEFT", 5, -5)
			self:SetWidth(50)
			self:SetHeight(50)
		]],
		portrait3DModel = false, combatFeedback = false,
		eliteFrame = [[
			self:SetFrameLevel(object:GetFrameLevel() + 1)
			self:SetWidth(142)
			self:SetHeight(142)
			self:SetPoint("CENTER", object.portrait, "CENTER", -12, -4)
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 62, -22)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -5, 15)
		]],
		healthBarTexture = "Flat Smooth", healthBarClassColor = true,
		healthText1 = 2, healthText1FontAttribute = "OUTLINE", healthText1FontShadow = false,
		healthText3 = 1, healthText3FontAttribute = "OUTLINE", healthText3FontShadow = false,
		powerBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 66, -50)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -9, 4)
		]],
		powerBarHeight = false,
		powerBarTexture = "Flat Smooth",
		powerText1 = 2, powerText1FontSize = 10, powerText1FontAttribute = "OUTLINE", powerText1FontShadow = false,
		powerText3 = 1, powerText3FontSize = 10, powerText3FontAttribute = "OUTLINE", powerText3FontShadow = false,
		textFrame = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", 66, -20)
		]],
		overlay1 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -9, -20)
		]],
		classIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("LEFT", object.textFrame, "RIGHT", 0, 0)
		]],
		classIconUse = true,
		levelText = [[
			self:SetPoint("LEFT", object.classIcon, "RIGHT", 0, 1)
		]],
		levelTextFontAttribute = "OUTLINE", levelTextFontShadow = false,
		stateText = [[
			self:SetPoint("RIGHT", object.overlay1, "LEFT", 0, 1)
		]],
		stateTextFontSize = 12, stateTextFontAttribute = "OUTLINE", stateTextFontShadow = false,
		nameText = [[
			self:SetJustifyH("LEFT")
			self:SetPoint("LEFT", object.levelText, "RIGHT", 0, 0)
			self:SetPoint("RIGHT", object.stateText, "LEFT", 0, 0)
		]],
		nameTextFontAttribute = "OUTLINE", nameTextFontShadow = false,
		combatIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object.portrait, "BOTTOMRIGHT", 3, -3)
		]],
		combatIconUse = true,
		raidIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("CENTER", object.portrait, "TOPRIGHT", 3, 3)
		]],
		raidIconUse = true,
		pvpIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object, "LEFT", 0, 0)
		]],
		pvpIconUse = true,
		leaderIcon = [[
			self:SetWidth(18)
			self:SetHeight(18)
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, -6)
		]],
		leaderIconUse = true,
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("LEFT", object.leaderIcon, "RIGHT", -3, 0)
		]],
		lootIconUse = true,
		topOffset = 3, topLeftOffset = 62, topRightOffset = -5,
		bottomOffset = 3, bottomLeftOffset = 62, bottomRightOffset = -5,
		aggroBorder = [[
			self:SetPoint("TOPLEFT", object.textFrame, "TOPRIGHT", -4, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -4, -20)
		]],
	},
	pet = {
		scale = 0.78,
	},
	pettarget = {
		default = "targettarget",
	},
	target = {
		background1 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestBG")
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -1, 2)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 11, -2)
			self:SetTexCoord(1, 0.90625, 0, 1)
		]],
		background2 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestBG")
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 1, 2)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -68, -2)
			self:SetTexCoord(0.5390625, 0, 0, 1)

		]],
		portrait = [[
			self:SetPoint("TOPRIGHT", -5, -5)
			self:SetWidth(50)
			self:SetHeight(50)
		]],
		eliteFrame = [[
			self:SetWidth(142)
			self:SetHeight(142)
			self:SetPoint("CENTER", object.portrait, "CENTER", 12, -4)
		]],
		eliteFrameUse = true,
		healthBar = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", -62, -22)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMLEFT", 5, 15)
		]],
		healthText1 = 1, healthText3 = 2,
		powerBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 9, -50)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -66, 4)
		]],
		powerText1 = 1, powerText3 = 2,
		textFrame = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", 9, -20)
		]],
		overlay1 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -66, -20)
		]],
		classIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("RIGHT", object.overlay1, "LEFT", 0, 0)
		]],
		classIconUse = true,
		levelText = [[
			self:SetPoint("RIGHT", object.classIcon, "LEFT", 0, 1)
		]],
		stateText = [[
			self:SetPoint("LEFT", object.textFrame, "RIGHT", 0, 1)
		]],
		nameText = [[
			self:SetJustifyH("RIGHT")
			self:SetPoint("LEFT", object.stateText, "RIGHT", 0, 0)
			self:SetPoint("RIGHT", object.levelText, "LEFT", 0, 0)
		]],
		combatIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object.portrait, "BOTTOMLEFT", -3, -3)
		]],
		raidIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("CENTER", object.portrait, "TOPLEFT", -3, 3)
		]],
		pvpIcon = [[
			self:SetWidth(24)
			self:SetHeight(24)
			self:SetPoint("CENTER", object, "RIGHT", 0, 0)
		]],
		leaderIcon = [[
			self:SetWidth(18)
			self:SetHeight(18)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -6)
		]],
		lootIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("RIGHT", object.leaderIcon, "LEFT", 3, 0)
		]],
		comboOffset = -5,
		topLeftOffset = 5, topRightOffset = -62,
		bottomLeftOffset = 5, bottomRightOffset = -62,
		aggroBorder = [[
			self:SetPoint("TOPLEFT", object.textFrame, "TOPRIGHT", -6, 0)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -62, -20)
		]],
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	targettarget = {
		width = 74, height = 30, scale = 0.8,
		background1 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestMiniBG")
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -1, 1)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 14, -1)
			self:SetTexCoord(0, 0.5, 0, 1)
		]],
		background2 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestMiniBG")
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 1, 1)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -14, -1)
			self:SetTexCoord(0.5, 1, 0, 1)
		]],
		background3 = [[
			self:SetTexture("Interface\\AddOns\\InvenUnitFrames_SkinPack\\Texture\\QuestMiniBG")
			self:SetPoint("TOPLEFT", object.background1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.background2, "BOTTOMLEFT", 0, 0)
			self:SetTexCoord(0.48, 0.52, 0, 1)
		]],
		portrait = false, combatFeedback = false,
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 4, -4)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -4, 6)
		]],
		healthText1 = false, healthText3FontSize = 11, healthText3FontAttribute = false, healthText3FontShadow = true,
		powerBar = [[
			self:SetPoint("TOPLEFT", object.healthBar, "BOTTOMLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -4, 4)
		]],
		powerText1 = false, powerText3 = false,
		classText = false, stateText = false, levelText = false,
		nameText = [[
			self:SetJustifyH("LEFT")
			self:SetPoint("LEFT", object.healthText1, "LEFT", 0, 0)
			self:SetPoint("RIGHT", object.healthText3, "LEFT", 0, 0)
		]],
		nameTextClassColor = false, nameTextFontSize = 11, nameTextFontAttribute = false, nameTextFontShadow = true,
		raidIcon = [[
			self:SetWidth(14)
			self:SetHeight(14)
			self:SetPoint("RIGHT", object, "LEFT", 7, 0)
		]],
		combatIcon = false, pvpIcon = false, leaderIcon = false, lootIcon = false, classIcon = false,
		nameFrame = false, overlay1 = false,
		eliteFrame = [[
			self:SetWidth(70)
			self:SetHeight(70)
			self:SetPoint("CENTER", object, "LEFT", 9, -2)
		]],
		eliteFrameUse = true,
		topOffset = 1, topLeftOffset = 2, topRightOffset = -2,
		bottomOffset = 1, bottomLeftOffset = 2, bottomRightOffset = -2,
		buffBigSize = 15, buffSmallSize = 15, debuffBigSize = 15, debuffSmallSize = 15, aggroBorder = false,
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
		scale = 0.8,
	},
	partypet = {
		scale = 0.9,
		default = "targettarget",
	},
	partytarget = {
		scale = 0.9,
		default = "targettarget",
	},
	boss = {
		default = "target", scale = 0.65, bossOffset = 32, pvpIcon = false, pvpIconUse = false,
		eliteFrameUse = true,
	},
}, {
	targettarget = { 171, -64 },
	targettargettarget = { 171, -94 },
	pet = { 0, -64 },
	pettarget = { 116, -118 },
	focustarget = { 171, -64 },
	focustargettarget = { 171, -94 },
	party = { 6, -170 },
	partytarget = { 240, 0 },
	partypet = { 240, -33 },

})