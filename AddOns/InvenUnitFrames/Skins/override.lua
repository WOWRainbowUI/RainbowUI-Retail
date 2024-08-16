local defaultFont = LibStub("LibSharedMedia-3.0").DefaultMedia.font

InvenUnitFrames.overrideSkin = {
	scale = 1, combatFeedbackFontSize = 22,
	nameTextFontFile = defaultFont, nameTextFontSize = 13, nameTextFontShadow = true,
	levelTextFontFile = defaultFont, levelTextFontSize = 13, levelTextFontShadow = true,
	stateTextFontFile = defaultFont, stateTextFontSize = 13, stateTextFontShadow = true,
	classTextFontFile = defaultFont, classTextFontSize = 13, classTextFontShadow = true,
	raceTextFontFile = defaultFont, raceTextFontSize = 13, raceTextFontShadow = true,
	healthText1FontFile = defaultFont, healthText1FontSize = 13, healthText1FontShadow = true,
	healthText2FontFile = defaultFont, healthText2FontSize = 13, healthText2FontShadow = true,
	healthText3FontFile = defaultFont, healthText3FontSize = 13, healthText3FontShadow = true,
	healthText4FontFile = defaultFont, healthText4FontSize = 13, healthText4FontShadow = true,
	healthText5FontFile = defaultFont, healthText5FontSize = 13, healthText5FontShadow = true,
	powerText1FontFile = defaultFont, powerText1FontSize = 13, powerText1FontShadow = true,
	powerText2FontFile = defaultFont, powerText2FontSize = 13, powerText2FontShadow = true,
	powerText3FontFile = defaultFont, powerText3FontSize = 13, powerText3FontShadow = true,
	powerText4FontFile = defaultFont, powerText4FontSize = 13, powerText4FontShadow = true,
	powerText5FontFile = defaultFont, powerText5FontSize = 13, powerText5FontShadow = true,
	topAnchor = true, topOffset = 1, topLeftOffset = 0, topRightOffset = 0,
	bottomAnchor = true, bottomOffset = 1, bottomLeftOffset = 0, bottomRightOffset = 0,
	classBar = [[return function(self, object, width, height, IUF)
		if IUF.db.classBar.pos == "TOP" then
			self:SetPoint("LEFT", object.topAnchorFrame, "LEFT")
			self:SetPoint("RIGHT", object.topAnchorFrame, "RIGHT")
			self:SetPoint("BOTTOM", object.topAnchorFrame, "BOTTOM")
		else
			self:SetPoint("LEFT", object.bottomAnchorFrame, "LEFT")
			self:SetPoint("RIGHT", object.bottomAnchorFrame, "RIGHT")
			self:SetPoint("TOP", object.bottomAnchorFrame, "TOP")
		end
		self.setting = IUF.db.classBar.pos
	end]],
	castingBar = [[return function(self, object, width, height, IUF)
		self.use = object.db.castingBarUse
		self.height = object.db.castingBarHeight
		self.setting = object.db.castingBarPos
	end]],
	castingBarUse = true, castingBarPos = "BOTTOM", castingBarHeight = 15, castingBarTexture = "Smooth v2",
	castingBarTextUse = true, castingBarTextFontFile = defaultFont, castingBarTextFontSize = 10, castingBarTextFontShadow = true,
	castingBarTimeUse = true, castingBarTimeFontFile = defaultFont, castingBarTimeFontSize = 10, castingBarTimeFontShadow = true,
	topAnchorFrame = [[return function(self, object, width, height, IUF)
		width = object.db.topAnchor
		width = (width and object[width] and type(object[width]) == "table" and object[width].GetObjectType) and object[width] or object
		self:SetPoint("BOTTOMLEFT", width, "TOPLEFT", object.db.topLeftOffset, object.db.topOffset)
		self:SetPoint("BOTTOMRIGHT", width, "TOPRIGHT", object.db.topRightOffset, object.db.topOffset)
		self:SetHeight(1)
	end]],
	bottomAnchorFrame = [[return function(self, object, width, height, IUF)
		width = object.db.bottomAnchor
		width = (width and object[width] and type(object[width]) == "table" and object[width].GetObjectType) and object[width] or object
		self:SetPoint("TOPLEFT", width, "BOTTOMLEFT", object.db.bottomLeftOffset, -object.db.bottomOffset)
		self:SetPoint("TOPRIGHT", width, "BOTTOMRIGHT", object.db.bottomRightOffset, -object.db.bottomOffset)
		self:SetHeight(1)
	end]],
	leftAnchorFrame = [[return function(self, object, width, height, IUF)
		self:SetPoint("RIGHT", object, "LEFT", object.db.leftOffset, 0)
		self:SetWidth(1)
		self:SetHeight(object.db.sideHeight or height)
	end]],
	rightAnchorFrame = [[return function(self, object, width, height, IUF)
		self:SetPoint("LEFT", object, "RIGHT", object.db.rightOffset, 0)
		self:SetWidth(1)
		self:SetHeight(object.db.sideHeight or height)
	end]],
	leftOffset = 0, rightOffset = 0,
	buffUse = false, buffNum = 0, buffOffset = 2, buffPos = "BOTTOM", buffNum = 0, buffSmallSize = 19, buffBigScale = 1,
	buffCooldownTextUse = false, buffCooldownTextFontSize = 8, buffCooldownTextFontAttribute = "THICKOUTLINE",
	buffCountTextFontSize = 11,
	buffFilterHelpMine = true, buffFilterHelpMineBig = true,
	buffFilterHelpCast = true, buffFilterHelpCastBig = false,
	buffFilterHelpOhter = true, buffFilterHelpOtherBig = false,
	buffFilterHarmDispel = true, buffFilterHarmDispelBig = true,
	buffFilterHarmOhter = true, buffFilterHarmOtherBig = false,
	debuffUse = false, debuffNum = 0, debuffOffset = 2, debuffPos = "BOTTOM", debuffNum = 0, debuffSmallSize = 19, debuffBigScale = 1,
	debuffCooldownTextUse = false, debuffCooldownTextFontSize = 8, debuffCooldownTextFontAttribute = "THICKOUTLINE",
	debuffCountTextFontSize = 11,
	debuffFilterHelpDispel = true, debuffFilterHelpDispelBig = true,
	debuffFilterHelpOhter = true, debuffFilterHelpOhterBig = false,
	debuffFilterHarmMine = true, debuffFilterHarmMineBig = true,
	debuffFilterHarmCast = true, debuffFilterHarmCastBig = false,
	debuffFilterHarmOhter = true, debuffFilterHarmOtherBig = false,
	comboFrameIsLeftPos = true, comboFrameOffset = 3,
	comboFrame = [[return function(self, object, width, height)
		self:SetScale(object.db.comboFrameScale or min(height / 50, 1))
		if object.db.comboFrameIsLeftPos then
			self[3]:SetPoint("RIGHT", object, "LEFT", -object.db.comboFrameOffset, 0)
		else
			self[3]:SetPoint("LEFT", object, "RIGHT", object.db.comboFrameOffset, 0)
		end
		self[1]:SetPoint("BOTTOM", self[2], "TOP", 0, 0)
		self[2]:SetPoint("BOTTOM", self[3], "TOP", 0, 0)
		self[4]:SetPoint("TOP", self[3], "BOTTOM", 0, 0)
		self[5]:SetPoint("TOP", self[4], "BOTTOM", 0, 0)
	end]],
	combatFeedback = false,
	powerBarHeight = 0.5,
	eliteFrameIsLeft = true,
}

InvenUnitFrames.overrideUnitSkin = {
	player = {
		castingBarUse = false,
	},
	pet = {
		buffNum = 2, buffPos = "RIGHT",
		debuffUse = true, debuffNum = 4, debuffPos = "RIGHT",
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
	},
	pettarget = {
		buffNum = 2, buffPos = "RIGHT",
		debuffNum = 4, debuffPos = "RIGHT",
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
	},
	target = {
		buffUse = true, buffNum = 40,
		debuffUse = true, debuffNum = 40, debuffBigScale = 1.32,
		debuffCooldownTextUse = true, debuffCooldownTextFontSize = 10,
	},
	party = {
		buffUse = true, buffNum = 10, buffSkipLine = true,
		debuffUse = true, debuffNum = 10, debuffSkipLine = true,
		partyOffset = 68,
	},
	targettarget = {
		buffNum = 2, buffPos = "RIGHT",
		debuffUse = true, debuffNum = 4, debuffPos = "RIGHT",
		castingBarHeight = 4, castingBarTextUse = false, castingBarTimeUse = false,
	},
	boss = {
		bossOffset = 25,
	},
}
InvenUnitFrames.overrideUnitSkin.targettargettarget = InvenUnitFrames.overrideUnitSkin.targettarget
InvenUnitFrames.overrideUnitSkin.focus = InvenUnitFrames.overrideUnitSkin.target
InvenUnitFrames.overrideUnitSkin.focustarget = InvenUnitFrames.overrideUnitSkin.targettarget
InvenUnitFrames.overrideUnitSkin.focustargettarget = InvenUnitFrames.overrideUnitSkin.targettarget
InvenUnitFrames.overrideUnitSkin.partypet = InvenUnitFrames.overrideUnitSkin.targettarget
InvenUnitFrames.overrideUnitSkin.partytarget = InvenUnitFrames.overrideUnitSkin.targettarget

InvenUnitFrames.overrideUnitPos = {
	player = { 14, -26 },
	pet = { 16, -68 },
	pettarget = { 192, -78 },
	target = { 285, -26 },
	targettarget = { 166, -64 },
	targettargettarget = { 166, -92 },
	focus = { 800, -300 },
	focustarget = { 166, -64 },
	focustargettarget = { 166, -92 },
	party = { 6, -154 },
	partypet = { 238, -30 },
	partytarget = { 238, 0 },
	boss = { 1105, -256 },
}