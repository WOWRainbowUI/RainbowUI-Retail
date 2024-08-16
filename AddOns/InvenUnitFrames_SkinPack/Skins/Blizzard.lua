InvenUnitFrames:RegisterSkin("Blizzard", "經典版", {
	base = {
		width = 187, height = 44, scale = 1,
		overlay1 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -41, 21)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 79, -35)
			self:SetTexCoord(1, 0.53125, 0, 0.78125)
		]],
		overlay2 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 28, 21)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -12, -35)
			self:SetTexCoord(0.15625, 0, 0, 0.78125)
		]],
		overlay3 = [[
			self:SetPoint("TOPLEFT", object.overlay1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.overlay2, "BOTTOMLEFT", 0, 0)
			self:SetTexCoord(0.15625, 0.53125, 0, 0.78125)
		]],
		highlight = [[
			self:SetPoint("TOPLEFT", object.textFrame, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "BOTTOMRIGHT", 0, 0)
		]],
		aggroBorder = [[
			self:SetPoint("TOPLEFT", object.textFrame, "TOPLEFT", -5, 5)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "BOTTOMRIGHT", 5, -5)
		]],
		portrait = [[
			self:SetPoint("CENTER", object, "TOPLEFT", 34, -23)
			self:SetWidth(58)
			self:SetHeight(58)
			self.isCircle = true
		]],
		raidIcon = [[
			self:SetWidth(22)
			self:SetHeight(22)
			self:SetPoint("CENTER", object.portrait, "TOP", 0, 0)
		]],
		raidIconUse = true,
		textFrame = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", -2, -2)
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 66, -20)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.textFrame, "LEFT", 3, 1)
			self:SetPoint("RIGHT", object.stateText, "LEFT", 0, 0)
			self:SetJustifyH("CENTER")
		]],
		nameTextFontSize = 11,
		stateText = [[
			self:SetPoint("RIGHT", object.textFrame, "RIGHT", -3, 1)
			self:SetJustifyH("RIGHT")
		]],
		stateTextFontSize = 11,
		healthBar = [[
			self:SetPoint("TOPLEFT", object.textFrame, "BOTTOMLEFT", 2, -1)
			self:SetPoint("BOTTOMRIGHT", object.textFrame, "BOTTOMRIGHT", 0, -11)
		]],
		healthBarTexture = "Blizzard",
		healthText2 = 2, healthText2FontSize = 10, healthText2FontAttribute = "OUTLINE", healthText2FontShadow = false,
		healthText5 = 1, healthText5FontSize = 10, healthText5FontAttribute = "OUTLINE", healthText5FontShadow = false,
		powerBar = [[
			self:SetPoint("TOPLEFT", object.healthBar, "BOTTOMLEFT", 0, -1)
			self:SetPoint("BOTTOMRIGHT", object.healthBar, "BOTTOMRIGHT", 0, -11)
		]],
		powerBarHeight = false,
		powerBarTexture = "Blizzard",
		powerText2 = 2, powerText2FontSize = 10, powerText2FontAttribute = "OUTLINE", powerText2FontShadow = false,
		powerText5 = 1, powerText5FontSize = 10, powerText5FontAttribute = "OUTLINE", powerText5FontShadow = false,
		background1 = [[
			self:SetTexture(0, 0, 0, 0.35)
			self:SetPoint("TOPLEFT", object.textFrame, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "BOTTOMRIGHT", 0, 0)
		]],
		levelText = [[
			self:SetPoint("CENTER", object, "BOTTOMLEFT", 12, -1)
		]],
		levelTextFontSize = 11,
		topAnchor = "textFrame", topOffset = 3,
		bottomAnchor = "powerBar", bottomOffset = 3,
		texture1 = [[
			self:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
			self:SetTexCoord(0, 0.578125, 0, 0.578125)
			self:SetPoint("CENTER", object.textFrame, "TOPLEFT", -4, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		classIcon = [[
			self.isCircle = true
			self:SetPoint("CENTER", object.texture1, "CENTER", 1, 0)
			self:SetWidth(18)
			self:SetHeight(18)
		]],
		classIconUse = true,
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait, "LEFT", -6, 4)
			self:SetWidth(39)
			self:SetHeight(39)
		]],
		pvpIconUse = true,
		combatIcon = [[
			self:SetPoint("CENTER", object.portrait, "BOTTOM", 0, 0)
			self:SetWidth(24)
			self:SetHeight(24)
		]],
		combatIconUse = true,
		eliteFrame = [[
			self:Hide()
		]],
	},
	target = {
		overlay1 = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -28, 21)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 12, -35)
			self:SetTexCoord(0, 0.15625, 0, 0.78125)
		]],
		overlay2 = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 41, 21)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -79, -35)
			self:SetTexCoord(0.53125, 1, 0, 0.78125)
		]],
		portrait = [[
			self.setting = "RIGHT"
			self:SetPoint("CENTER", object, "TOPRIGHT", -34, -23)
			self:SetWidth(58)
			self:SetHeight(58)
			self.isCircle = true
		]],
		textFrame = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 2, -2)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -66, -20)
		]],
		nameText = [[
			self:SetPoint("LEFT", object.stateText, "RIGHT", 0, 0)
			self:SetPoint("RIGHT", object.textFrame, "RIGHT", -3, 1)
			self:SetJustifyH("CENTER")
		]],
		stateText = [[
			self:SetPoint("LEFT", object.textFrame, "LEFT", 3, 1)
			self:SetJustifyH("LEFT")
		]],
		background2 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
			self:SetAllPoints(object.textFrame)
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object.textFrame, "BOTTOMLEFT", 0, -1)
			self:SetPoint("BOTTOMRIGHT", object.textFrame, "BOTTOMRIGHT", -2, -11)
		]],
		healthText2 = 2, healthText5 = false,
		healthText4 = 1, healthText4FontSize = 10, healthText4FontAttribute = "OUTLINE", healthText4FontShadow = false,
		powerText2 = 2, powerText5 = false,
		powerText4 = 1, powerText4FontSize = 10, powerText4FontAttribute = "OUTLINE", powerText4FontShadow = false,
		levelText = [[
			self:SetPoint("CENTER", object, "BOTTOMRIGHT", -11, -1)
		]],
		texture1 = [[
			self:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
			self:SetTexCoord(0, 0.578125, 0, 0.578125)
			self:SetPoint("CENTER", object.textFrame, "TOPRIGHT", 4, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		pvpIcon = [[
			self:SetPoint("CENTER", object.portrait, "RIGHT", 6, 4)
			self:SetWidth(39)
			self:SetHeight(39)
		]],
		comboFrame = [[
			self[5]:SetPoint("BOTTOM", object, "BOTTOMRIGHT", 2, 5)
			self[4]:SetPoint("BOTTOM", self[5], "TOP", 1, -1)
			self[3]:SetPoint("BOTTOM", self[4], "TOP", -2, -1)
			self[2]:SetPoint("BOTTOM", self[3], "TOP", -5, -3)
			self[1]:SetPoint("BOTTOM", self[2], "TOP", -8, -4)
		]],
		eliteFrameUse = true,
		comboFrameIsLeftPos = false, eliteFrameIsLeft = false,
	},
	pet = {
		width = 106, height = 31, scale = 0.9,
		overlay1 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame")
			self:SetTexCoord(0.015625, 0.3984375, 0.015625, 0.765625)
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -9, 8)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 40, -11)
		]],
		overlay2 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame")
			self:SetTexCoord(0.8671875, 0.921875, 0.015625, 0.765625)
			self:SetPoint("TOPLEFT", object, "TOPRIGHT", -6, 8)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 1, -11)
		]],
		overlay3 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-SmallTargetingFrame")
			self:SetTexCoord(0.3984375, 0.8671875, 0.015625, 0.765625)
			self:SetPoint("TOPLEFT", object.overlay1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.overlay2, "BOTTOMLEFT", 0, 0)
		]],
		portrait = [[
			self:SetPoint("CENTER", object, "TOPLEFT", 13, -15)
			self:SetWidth(33)
			self:SetHeight(33)
			self.isCircle = true
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 35, -13)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -3, 12)
		]],
		background1 = [[
			self:SetTexture(0, 0, 0, 0.35)
			self:SetPoint("TOPLEFT", object.healthBar, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "BOTTOMRIGHT", 0, 0)
		]],
		highlight = [[
			self:SetAllPoints(object.background1)
		]],
		levelText = [[
			self:SetPoint("CENTER", object, "BOTTOMLEFT", 3, 3)
		]],
		levelTextFontSize = 13,
		nameText = [[
			self:SetPoint("BOTTOMLEFT", object.healthBar, "TOPLEFT", -1, 3)
		]],
		nameTextFontSize = 13,
		stateText = [[
			self:SetPoint("LEFT", object.nameText, "RIGHT", 2, 0)
		]],
		stateTextFontSize = 13,
		healthText2 = 1, healthText5FontSize = 11, healthText5FontAttribute = "OUTLINE", healthText5FontShadow = false,
		healthText5 = false, healthText3 = false, healthText4 = false, powerText2 = false, powerText3 = false, powerText5 = false,
		bottomLeftOffset = -8,
		bottomOffset = 2,
		sideHeight = 18, buffPos = "BOTTOM", debuffPos = "BOTTOM",
		classIcon = [[
			self:SetPoint("LEFT", object.nameText, "RIGHT", 2, 0)
			self:SetWidth(18)
			self:SetHeight(18)
		]],
		classIconUse = true,
		raidIcon = [[
			self:SetWidth(16)
			self:SetHeight(16)
			self:SetPoint("CENTER", object.portrait, "TOP", 0, 0)
		]],
	},
	pettarget = {
		default = "targettarget", scale = 0.55,
	},
	targettarget = {
		width = 150, height = 48, scale = 0.6,
		overlay1 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoMana")
			self:SetTexCoord(1, 0.703125, 0, 0.59375)
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -13, 13)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 63, -15)
		]],
		overlay2 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoMana")
			self:SetTexCoord(0.28125, 0.2421875, 0, 0.4765625)
			self:SetPoint("TOPLEFT", object, "TOPRIGHT", -7, 13)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 3, 0)
		]],
		overlay3 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoMana")
			self:SetTexCoord(0.703125, 0.28125, 0, 0.4765625)
			self:SetPoint("TOPLEFT", object.overlay1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.overlay2, "BOTTOMLEFT", 0, 0)
		]],
		portrait = [[
			self:SetPoint("CENTER", object, "TOPLEFT", 23, -23)
			self:SetWidth(58)
			self:SetHeight(58)
			self.isCircle = true
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 58, -3)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -3, -20)
		]],
		background1 = [[
			self:SetTexture(0, 0, 0, 0.35)
			self:SetPoint("TOPLEFT", object.healthBar, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "BOTTOMRIGHT", 0, 0)
		]],
		highlight = [[
			self:SetAllPoints(object.background1)
		]],
		texture1 = [[
			self:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
			self:SetTexCoord(0, 0.578125, 0, 0.578125)
			self:SetPoint("CENTER", object.healthBar, "TOPLEFT", -7, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		levelText = [[
			self:SetPoint("CENTER", object, "BOTTOMLEFT", 3, 3)
		]],
		levelTextFontSize = 15,
		nameText = [[
			self:SetPoint("TOPLEFT", object.powerBar, "BOTTOMLEFT", -1, -3)
		]],
		nameTextFontSize = 17,
		pvpIcon = false, stateText = false,
		healthText2 = 1, healthText2FontSize = 17, healthText2FontAttribute = "OUTLINE", healthText2FontShadow = false,
		healthText3 = false, healthText4 = false, healthText5 = false, powerText2 = false, powerText5 = false,
		bottomOffset = 24,
		castingBarHeight = 7, castingBarPos = "TOP", castingBarTextUse = false, castingBarTimeUse = false,
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
		width = 178, height = 48, scale = 0.8,
		overlay1 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoMana")
			self:SetTexCoord(1, 0.703125, 0, 0.59375)
			self:SetPoint("TOPLEFT", object, "TOPLEFT", -13, 13)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 63, -15)
		]],
		overlay2 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoMana")
			self:SetTexCoord(0.28125, 0.2421875, 0, 0.4765625)
			self:SetPoint("TOPLEFT", object, "TOPRIGHT", -7, 13)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 3, 0)
		]],
		overlay3 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoMana")
			self:SetTexCoord(0.703125, 0.28125, 0, 0.4765625)
			self:SetPoint("TOPLEFT", object.overlay1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.overlay2, "BOTTOMLEFT", 0, 0)
		]],
		portrait = [[
			self:SetPoint("CENTER", object, "TOPLEFT", 23, -23)
			self:SetWidth(58)
			self:SetHeight(58)
			self.isCircle = true
		]],
		healthBar = [[
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 58, -3)
			self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", -3, -20)
		]],
		background1 = [[
			self:SetTexture(0, 0, 0, 0.35)
			self:SetPoint("TOPLEFT", object.healthBar, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.powerBar, "BOTTOMRIGHT", 0, 0)
		]],
		highlight = [[
			self:SetAllPoints(object.background1)
		]],
		texture1 = [[
			self:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
			self:SetTexCoord(0, 0.578125, 0, 0.578125)
			self:SetPoint("CENTER", object.healthBar, "TOPLEFT", -7, 0)
			self:SetWidth(30)
			self:SetHeight(30)
		]],
		levelText = [[
			self:SetPoint("CENTER", object, "BOTTOMLEFT", 3, 3)
		]],
		levelTextFontSize = 13,
		nameText = [[
			self:SetPoint("TOPLEFT", object.powerBar, "BOTTOMLEFT", -1, -3)
		]],
		nameTextFontSize = 14,
		stateText = [[
			self:SetPoint("LEFT", object.nameText, "RIGHT", 2, 0)
		]],
		stateTextFontSize = 14,
		healthText5 = 1, healthText5FontSize = 12,
		powerText5 = 1, powerText5FontSize = 11,
		healthText2 = 2, healthText2FontSize = 13, healthText2FontAttribute = "OUTLINE", healthText2FontShadow = false,
		powerText2 = 2, powerText2FontSize = 11, powerText2FontAttribute = "OUTLINE", powerText2FontShadow = false,
		healthText3 = false, healthText4 = false,
		bottomOffset = 18,
		castingBarHeight = 11, castingBarPos = "TOP",

	},
	partypet = {
		default = "pet", width = 80,
		scale = 0.75, nameText = false, debuffNum = 3, debuffBigSize = 15, debuffSmallSize = 15, castingBarUse = false,
		classIcon = false,
	},
	partytarget = {
		default = "targettarget",
		scale = 0.55, width = 130, nameTextFontSize = 18, nameTextFontAttribute = "OUTLINE", nameTextFontShadow = false,
	},
	boss = {
		default = "target",
		width = 123, height = 45, scale = 1, bossOffset = 30,
		portrait = false, eliteFrame = false, eliteFrameUse = false,
		background2 = false, combatIcon = false, combatIconUse = false,
		overlay1 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss")
			self:SetTexCoord(0.10546875, 0.140625, 0.1640625, 0.515625)
			self:SetPoint("TOPLEFT", object, "TOPLEFT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMLEFT", 9, 0)
		]],
		overlay2 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss")
			self:SetTexCoord(0.3046875, 0.5859375, 0.1640625, 0.515625)
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -72, 0)
		]],
		overlay3 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss")
			self:SetTexCoord(0.140625, 0.3046875, 0.1640625, 0.515625)
			self:SetPoint("TOPLEFT", object.overlay1, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object.overlay2, "BOTTOMLEFT", 0, 0)
		]],
		background3 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss")
			self:SetTexCoord(0.3046875, 0.71484375, 0, 0.1640625)
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 33, 21)
			self:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -72, 0)
		]],
		texture2 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss")
			self:SetTexCoord(0.5859375, 0.72265625, 0.1640625, 0.65625)
			self:SetPoint("TOPLEFT", object, "TOPRIGHT", 0, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 35, -18)
		]],
		texture3 = [[
			self:SetTexture("Interface\\TargetingFrame\\UI-UnitFrame-Boss")
			self:SetTexCoord(0.5390625, 0.5859375, 0.515625, 0.65625)
			self:SetPoint("TOPLEFT", object, "BOTTOMRIGHT", -12, 0)
			self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", 0, -18)
		]],
		textFrame = [[
			self:SetPoint("TOPRIGHT", object, "TOPRIGHT", -2, -2)
			self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 2, -20)
		]],
		levelText = [[
			self:SetPoint("CENTER", object, "BOTTOMRIGHT", 1, 1)
		]],
		raidIcon = [[
			self:SetPoint("RIGHT", object.textFrame, "LEFT", -1, 0)
			self:SetWidth(18)
			self:SetHeight(18)
		]],
		pvpIcon = false, pvpIconUse = false,
		bottomRightOffset = -10, castingBarHeight = 10,
		eliteFrameUse = true,
	},
}, {
	pet = { 55, -51 },
	pettarget = { 158, -55 },
	target = { 270, -26 },
	targettarget = { 130, -62 },
	targettargettarget = { 130, -101 },
	focustarget = { 130, -62 },
	focustargettarget = { 130, -101 },
	party = { 22, -154 },
	partypet = { -6, -61 },
	partytarget = { 216, -6 },
})
