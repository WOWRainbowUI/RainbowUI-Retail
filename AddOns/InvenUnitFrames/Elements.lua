local IUF = InvenUnitFrames
local SM = LibStub("LibSharedMedia-3.0")

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local loadstring = _G.loadstring
local GetTime = _G.GetTime
local CreateFrame = _G.CreateFrame
local UnitExists = _G.UnitExists
local UnitIsUnit = _G.UnitIsUnit
local UnitIsConnected = _G.UnitIsConnected
local UnitIsVisible = _G.UnitIsVisible
local InCombatLockdown = _G.InCombatLockdown

local tempModelFrame = CreateFrame("PlayerModel")

local function portraitOnShow(model3d)
	IUF:RefreshCamera(model3d)

end

local function portraitOnSizeChanged(portrait)
	local w, h = portrait:GetWidth(), portrait:GetHeight()
	if portrait.isCircle then
		portrait.model3d:SetWidth(w * 0.74)
		portrait.model3d:SetHeight(h * 0.74)
		if w == h then
			portrait.model2d:SetTexCoord(0, 1, 0, 1)
		elseif w > h then
			h = (w - h) / w / 2
			portrait.model2d:SetTexCoord(0, 1, h, 1 - h)
		else
			w = (h - w) / h / 2
			portrait.model2d:SetTexCoord(w, 1 - w, 0, 1)
		end
	else
		portrait.model3d:SetWidth(w)
		portrait.model3d:SetHeight(h)
		if w == h then
			portrait.model2d:SetTexCoord(0.143, 0.857, 0.143, 0.857)
		elseif w > h then
			h = (w - h) / w / 2 * 0.714 + 0.143
			portrait.model2d:SetTexCoord(0.143, 0.857, h, 1 - h)
		else
			w = (h - w) / h / 2 * 0.714 + 0.143
			portrait.model2d:SetTexCoord(w, 1 - w, 0.143, 0.857)
		end
	end
end

local fadeInHoldTime = COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME
local fadeInHoldFadeOutTime = COMBATFEEDBACK_FADEINTIME + COMBATFEEDBACK_HOLDTIME + COMBATFEEDBACK_FADEOUTTIME

local function combatFeedbackOnUpdate(self, timer)
	if self.feedbackStartTime then
		self.elapsedTime = GetTime() - self.feedbackStartTime
		if self.elapsedTime < COMBATFEEDBACK_FADEINTIME then
			self.feedbackText:SetAlpha(self.elapsedTime / COMBATFEEDBACK_FADEINTIME)
		elseif self.elapsedTime < fadeInHoldTime then
			self.feedbackText:SetAlpha(1)
		elseif self.elapsedTime < fadeInHoldFadeOutTime then
			self.feedbackText:SetAlpha(1 - (self.elapsedTime - fadeInHoldTime) / COMBATFEEDBACK_FADEOUTTIME)
		else
			self.feedbackStartTime = nil
			self.feedbackText:SetText(nil)
			self:Hide()
		end
	else
		self.feedbackText:SetText(nil)
		self:Hide()
	end
end

local defaultElements = {
	"border1", "border2", "border3", "border4", "border5", "border6", "border7",
	"background1", "background2", "background3", "overlay1", "overlay2", "overlay3", "texture1", "texture2", "texture3",
	"eliteFrame", "textFrame", "portrait", "nameText", "levelText", "stateText", "classText", "raceText",
	"pvpIcon", "raidIcon", "combatIcon", "leaderIcon", "lootIcon", "classIcon",
	"healthBar", "healthText1", "healthText2", "healthText3", "healthText4", "healthText5",
	"powerBar", "powerText1", "powerText2", "powerText3", "powerText4", "powerText5",
	"classBar", "castingBar", "topAnchorFrame", "bottomAnchorFrame", "leftAnchorFrame", "rightAnchorFrame"
}

local function objectAllShownCheck(object)
	object = object:GetParent()
	if object.topAnchorFrame:GetWidth() > 0 and object.bottomAnchorFrame:GetWidth() > 0 and object.leftAnchorFrame:GetHeight() > 0 and object.rightAnchorFrame:GetHeight() > 0 then
		object.checkAllShown = true
		object.allShownCheck:Hide()
		if object.isPreview then
			IUF:SetPreviewAura(object)
		else
			IUF.callbacks.Aura(object)
		end
	end
end

function IUF:CreateObjectElements(object)
	-- 체력바 등 유니트 구성 요소 생성
	object.fadeBars = {}
	object.healthBar = self:CreateStatusBar(object)
	object.healthBar.extra.healBar = CreateFrame("StatusBar", nil, object.healthBar)
	object.healthBar.extra.healBar:SetFrameLevel(object.healthBar:GetFrameLevel())
	object.healthBar.extra.healBar:SetAllPoints()
	object.powerBar = self:CreateStatusBar(object)
	object.textFrame = CreateFrame("Frame", nil, object)
	object.textFrame:SetFrameLevel(object:GetFrameLevel() + 5)
	object.nameText = object.textFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	object.levelText = object.textFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	object.stateText = object.textFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	object.classText = object.textFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	object.raceText = object.textFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	object.portrait = CreateFrame("Frame", nil, object)
	object.portrait:SetScript("OnSizeChanged", portraitOnSizeChanged)
	object.portrait:SetFrameLevel(object:GetFrameLevel() + 4)
	object.portrait.model3d = CreateFrame("PlayerModel", nil, object.portrait)
	object.portrait.model3d:Hide()
	object.portrait.model3d:SetScript("OnShow", portraitOnShow)
	object.portrait.model3d:SetFrameLevel(object:GetFrameLevel() + 2)
	object.portrait.model3d:SetPoint("CENTER")
	object.portrait.model3d.bg = object.portrait.model3d:CreateTexture(nil, "BACKGROUND")
	object.portrait.model3d.bg:SetAllPoints(object.portrait)
	object.portrait.model2d = object.portrait:CreateTexture(nil, "BACKGROUND")
	object.portrait.model2d:SetAllPoints()
	object.portrait.border = object.portrait:CreateTexture(nil, "ARTWORK")
	object.portrait.border:SetPoint("CENTER")
	object.portrait.aggro = object.portrait:CreateTexture(nil, "BORDER")
	object.portrait.aggro:SetBlendMode("ADD")
	object.portrait.aggro:SetVertexColor(1, 0, 0)
	if object.objectType == "player" or object.objectType == "target" then
		object.feedbackFrame = CreateFrame("Frame", nil, object)
		object.feedbackFrame:SetFrameLevel(object:GetFrameLevel() + 6)
		object.feedbackFrame:Hide()
		object.feedbackFrame:SetScript("OnUpdate", combatFeedbackOnUpdate)
		object.feedbackFrame.feedbackText = object.textFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
		object.feedbackFrame.feedbackText:SetPoint("CENTER", object.portrait, "CENTER", 0, 0)
	end
	object.offlineIcon = object.portrait:CreateTexture(nil, "ARTWORK")
	object.offlineIcon:SetTexture("Interface\\CharacterFrame\\Disconnect-Icon")
	object.offlineIcon:SetTexCoord(0.18, 0.82, 0.18, 0.82)
	object.offlineIcon:SetAllPoints(object.portrait.model3d)
	object.pvpIcon = object.textFrame:CreateTexture(nil ,"ARTWORK")
	object.raidIcon = object.textFrame:CreateTexture(nil ,"ARTWORK")
	object.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	object.combatIcon = object.textFrame:CreateTexture(nil, "ARTWORK")
	object.combatIcon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	object.leaderIcon = object.textFrame:CreateTexture(nil, "ARTWORK")
	object.lootIcon = object.textFrame:CreateTexture(nil, "ARTWORK")
	object.lootIcon:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	object.classIcon = object.textFrame:CreateTexture(nil, "ARTWORK")
	object.creatureIcon = object.textFrame:CreateTexture(nil, "ARTWORK")
	object.creatureIcon:SetPoint("TOPLEFT", object.classIcon, "TOPLEFT", 2, -2)
	object.creatureIcon:SetPoint("BOTTOMRIGHT", object.classIcon, "BOTTOMRIGHT", -2, 2)
	object.roleIcon = object.textFrame:CreateTexture(nil, "ARTWORK")
	object.roleIcon:SetTexture("Interface\\LFGFrame\\LFGRole")
	object.roleIcon:SetPoint("CENTER", object.levelText, "CENTER", -1, -1)
	object.roleIcon:SetWidth(16)
	object.roleIcon:SetHeight(16)
	object.dispelFrame = object.textFrame:CreateTexture(nil, "BACKGROUND")
	object.dispelFrame:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\Highlight")
	object.dispelFrame:SetBlendMode("ADD")
	object.dispelFrame:SetAlpha(self.db.dispel.alpha)

	object.highlight = object.textFrame:CreateTexture(nil, "OVERLAY")
	object.highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	object.highlight:SetBlendMode("ADD")
	object.highlight:Hide()

	for i = 1, 7 do
		object["border"..i] = CreateFrame("Frame", nil, object, BackdropTemplateMixin and "BackdropTemplate")
		object["border"..i].gradient = object["border"..i]:CreateTexture(nil, "BORDER")
		object["border"..i].gradient:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
		object["border"..i].gradient:SetBlendMode("ADD")
		if i <= 5 then
			object["healthText"..i] = object.textFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			object["powerText"..i] = object.textFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		end
		if i <= 3 then
			object["background"..i] = object:CreateTexture(nil, "BACKGROUND")
			object["overlay"..i] = object.textFrame:CreateTexture(nil, "BORDER")
			object["texture"..i] = object.textFrame:CreateTexture(nil, "OVERLAY")
		end
	end
	object.healthText1:SetPoint("LEFT", object.healthBar, "LEFT", 2, 1)
	object.healthText2:SetPoint("CENTER", object.healthBar, "CENTER", 0, 1)
	object.healthText3:SetPoint("RIGHT", object.healthBar, "RIGHT", -2, 1)
	object.healthText4:SetPoint("RIGHT", object.healthBar, "LEFT", -1, 1)
	object.healthText5:SetPoint("LEFT", object.healthBar, "RIGHT", 1, 1)
	object.powerText1:SetPoint("LEFT", object.powerBar, "LEFT", 2, 1)
	object.powerText2:SetPoint("CENTER", object.powerBar, "CENTER", 0, 1)
	object.powerText3:SetPoint("RIGHT", object.powerBar, "RIGHT", -2, 1)
	object.powerText4:SetPoint("RIGHT", object.powerBar, "LEFT", -1, 1)
	object.powerText5:SetPoint("LEFT", object.powerBar, "RIGHT", 1, 1)
	if object.objectType == "player" or object.objectType == "focus" or object.objectType == "boss" or object.objectType:find("target") then
		object.eliteFrame = CreateFrame("Frame", nil, object)
		object.eliteFrame.tex = object.eliteFrame:CreateTexture(nil, "OVERLAY")
		object.eliteFrame.tex:SetAllPoints()
	end
	object.topAnchorFrame = CreateFrame("Frame", nil, object)
	object.topAnchorFrame:SetFrameLevel(object:GetFrameLevel() + 1)
	object.bottomAnchorFrame = CreateFrame("Frame", nil, object)
	object.bottomAnchorFrame:SetFrameLevel(object:GetFrameLevel() + 1)
	object.bottomAnchorFrame:SetScript("OnShow", objectAnchorOnShow)
	object.leftAnchorFrame = CreateFrame("Frame", nil, object)
	object.leftAnchorFrame:SetFrameLevel(object:GetFrameLevel() + 1)
	object.leftAnchorFrame:SetScript("OnShow", objectAnchorOnShow)
	object.rightAnchorFrame = CreateFrame("Frame", nil, object)
	object.rightAnchorFrame:SetFrameLevel(object:GetFrameLevel() + 1)
	object.rightAnchorFrame:SetScript("OnShow", objectAnchorOnShow)
	object.allShownCheck = CreateFrame("Frame", nil, object)
	object.allShownCheck:Hide()
	object.allShownCheck:SetScript("OnUpdate", objectAllShownCheck)
	if self.CreateClassBar and object.objectType == "player" then
		self:CreateClassBar(object)
		self.CreateClassBar = nil
		if object.classBar then
			object.classBar:Show()
			object.classBar:SetHeight(0.001)
			object.classBar:SetAlpha(0)
		end
	end
	if not(object.needAutoUpdate or object.objectType == "partypet") then
		object.comboFrame = CreateFrame("Frame", nil, object)
		object.comboFrame:SetAllPoints()
		object.comboFrame:SetFrameLevel(object:GetFrameLevel() + 6)
		for i = 1, 5 do
			object.comboFrame[i] = CreateFrame("Frame", object:GetName().."_Combo"..i, object.comboFrame)
			object.comboFrame[i]:SetWidth(12)
			object.comboFrame[i]:SetHeight(12)
			object.comboFrame[i]:Hide()
			object.comboFrame[i].fadeInfo = {}
			object.comboFrame[i].bg = object.comboFrame[i]:CreateTexture(nil, "BACKGROUND")
			object.comboFrame[i].bg:SetTexture("Interface\\ComboFrame\\ComboPoint")
			object.comboFrame[i].bg:SetTexCoord(0, 0.375, 0, 1)
			object.comboFrame[i].bg:SetPoint("TOPLEFT")
			object.comboFrame[i].bg:SetWidth(12)
			object.comboFrame[i].bg:SetHeight(16)
			object.comboFrame[i].highlight = object.comboFrame[i]:CreateTexture(nil, "ARTWORK")
			object.comboFrame[i].highlight:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\Combo")
			object.comboFrame[i].highlight:SetVertexColor(1, 1, 0)
			object.comboFrame[i].highlight:SetPoint("CENTER", 0, 2)
			object.comboFrame[i].highlight:SetWidth(15)
			object.comboFrame[i].highlight:SetHeight(15)
			object.comboFrame[i].shine = object.comboFrame[i]:CreateTexture(nil, "OVERLAY")
			object.comboFrame[i].shine:SetTexture("Interface\\Cooldown\\star4")
			object.comboFrame[i].shine:SetBlendMode("ADD")
			object.comboFrame[i].shine:SetAlpha(0)
			object.comboFrame[i].shine:SetPoint("CENTER", 0, 0)
			object.comboFrame[i].shine:SetWidth(20)
			object.comboFrame[i].shine:SetHeight(20)
		end
	end
	self:CreateCastingBar(object)
	self:CreateAggroBorder(object)
	if object.objectType == "player" then
		object.pvpTimer = CreateFrame("Frame", nil, object)
		object.pvpTimer:SetAllPoints(object.pvpIcon)
		object.pvpTimer:Hide()
		object.pvpTimer:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.pvpTimer:RegisterEvent("PLAYER_FLAGS_CHANGED")
		object.pvpTimer.OnUpdate = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			if GetLocale()=="koKR" then
				GameTooltip:AddLine("남은 시간")
			else
				GameTooltip:AddLine("Remain ")
			end
			GameTooltip:AddLine(SecondsToTime(floor(GetPVPTimer() / 1000)), 1, 1, 1)
			GameTooltip:Show()
		end
		object.pvpTimer.OnHide = function(self)
			self:SetScript("OnUpdate", nil)
			--GameTooltip:Hide()	-- pvp map bug
		end
		object.pvpTimer:SetScript("OnEvent", function(self)
			self.running = IsPVPTimerRunning()
			self:EnableMouse(self.running)
			if not self.running then
				self:OnHide()
			end
		end)
		object.pvpTimer:SetScript("OnEnter", function(self)
			if self.running then
				self:OnUpdate()
				self:SetScript("OnUpdate", self.OnUpdate)
			else
				self:OnHide()
			end
		end)
		object.pvpTimer:SetScript("OnLeave", object.pvpTimer.OnHide)
		object.pvpTimer:SetScript("OnHide", object.pvpTimer.OnHide)
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
	object.readyCheckIcon = object.portrait:CreateTexture(nil, "ARTWORK")
	object.readyCheckIcon:SetParent(object.portrait)
	object.readyCheckIcon:SetDrawLayer("OVERLAY", 7)
	object.readyCheckIcon:ClearAllPoints()
	object.readyCheckIcon:SetPoint("CENTER", 0, 0)
	object.readyCheckIcon:SetSize(50, 50)	
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------
	
--~ 	if UnitIsUnit(object.unit, "player") or UnitIsUnit(object.unit, "pet") or UnitIsUnit(object.unit, "target") or UnitIsUnit(object.unit, "focus") then
   	if unit == "player" or unit == "pet" or unit == "target" or unit == "focus" then
	
	else
		object.layoutIndex = 1
		object.DropDown = CreateFrame("Frame", nil, object, "UIDropDownMenuTemplate")
		object.DropDown:SetAllPoints()
		object.DropDown:SetPoint("TOP", -20, -10)
		object.DropDown:SetSize(10, 10)
		object.DropDown:SetFrameLevel(object:GetFrameLevel())
		object.DropDown.id = nil
			
		local function InitializeDropDown(self)
			
			local unit = self:GetParent().unit;
			if ( not unit ) then
				return;
			end
			local menu;
			local name;
			local id = nil;
			if ( UnitIsUnit(unit, "player") ) then
				menu = "SELF";
			elseif ( UnitIsUnit(unit, "vehicle") ) then
				-- NOTE: vehicle check must come before pet check for accuracy's sake because
				-- a vehicle may also be considered your pet
				menu = "VEHICLE";
			elseif ( UnitIsUnit(unit, "pet") ) then
				menu = "PET";
			elseif ( UnitIsPlayer(unit) ) then
				id = UnitInRaid(unit);
				if ( id ) then
					menu = "RAID_PLAYER";
				elseif ( UnitInParty(unit) ) then
					menu = "PARTY";
				else
					menu = "PLAYER";
				end
			else
				menu = "TARGET";
				name = RAID_TARGET_ICON;
			end
			if ( menu ) then
--				UnitPopup_ShowMenu(self, menu, unit, name, id);
			end
		end
		
		UIDropDownMenu_SetInitializeFunction(object.DropDown, InitializeDropDown);
		UIDropDownMenu_SetDisplayMode(object.DropDown, "MENU");
			
		local function buttonOnClick(self, button)
			if button == "RightButton" then
				ToggleDropDownMenu(1, nil, self.DropDown, "cursor");
			end
		end
		object:SetScript("OnMouseUp", buttonOnClick)
	end
end


function IUF:SetFontString(fontString, file, size, attribute, shadow)
	fontString:SetFont(SM:Fetch("font", file or "기본 폰트") or STANDARD_TEXT_FONT, size or 13, attribute or "")
	if shadow then
		fontString:SetShadowColor(0, 0, 0)
		fontString:SetShadowOffset(1, -1)
	else
		fontString:SetShadowOffset(0, 0)
	end
end

local skinvalue, objectType, backdrop, isfuncvalue

local function setupAura(object, aura)

	if object.db[aura.."Use"] and object.db[aura.."Num"] > 0 then
		object[aura].num = object.db[aura.."Num"]
		object[aura].pos = object.db[aura.."Pos"]
		object[aura].offset = object.db[aura.."Offset"]
		object[aura].skipline = object.db[aura.."SkipLine"]
		object[aura].cdbigtexture = not object.db[aura.."HiddenBigCooldownTexture"]
		object[aura].cdsmalltexture = not object.db[aura.."HiddenSmallCooldownTexture"]
		object[aura].small = object.db[aura.."SmallSize"]
		wipe(object[aura].filters)
		object[aura].filters.helpMine = object.db[aura.."FilterHelpMine"]
		object[aura].filters.helpCast = object.db[aura.."FilterHelpCast"]
		object[aura].filters.helpDispel = object.db[aura.."FilterHelpDispel"]
		object[aura].filters.helpOhter = object.db[aura.."FilterHelpOhter"]
		object[aura].filters.harmMine = object.db[aura.."FilterHarmMine"]
		object[aura].filters.harmCast = object.db[aura.."FilterHarmCast"]
		object[aura].filters.harmDispel = object.db[aura.."FilterHarmDispel"]
		object[aura].filters.harmOhter = object.db[aura.."FilterHarmOhter"]
		if object.objectType == "player" or object.objectType == "target" or object.objectType == "focus" or object.objectType == "boss" or object.objectType == "party" then
			object[aura].filters.helpMineBig = object.db[aura.."FilterHelpMineBig"]
			object[aura].filters.helpCastBig = object.db[aura.."FilterHelpCastBig"]
			object[aura].filters.helpDispelBig = object.db[aura.."FilterHelpDispelBig"]
			object[aura].filters.helpOhterBig = object.db[aura.."FilterHelpOhterBig"]
			object[aura].filters.harmMineBig = object.db[aura.."FilterHarmMineBig"]
			object[aura].filters.harmCastBig = object.db[aura.."FilterHarmCastBig"]
			object[aura].filters.harmDispelBig = object.db[aura.."FilterHarmDispelBig"]
			object[aura].filters.harmOhterBig = object.db[aura.."FilterHarmOhterBig"]
			object[aura].cduse = object.db[aura.."CooldownTextUse"]
			object[aura].big = object[aura].small * object.db[aura.."BigScale"]

		else
			object[aura].cduse = nil
			object[aura].big = object[aura].small

		end
		object[aura].lp2, object[aura].np2 = nil
		if object[aura].pos == "LEFT" then
			object[aura].anchor = object.leftAnchorFrame
			object[aura].lp, object[aura].lx, object[aura].ly = "TOPRIGHT", -object[aura].offset, 0
			object[aura].np, object[aura].nx, object[aura].ny = "TOP", 0, -object[aura].offset
		elseif object[aura].pos == "RIGHT" then
			object[aura].anchor = object.rightAnchorFrame
			object[aura].lp, object[aura].lx, object[aura].ly = "TOPLEFT", object[aura].offset, 0
			object[aura].np, object[aura].nx, object[aura].ny = "TOP", 0, -object[aura].offset
			object[aura].lp2 = "TOPRIGHT"
		elseif object[aura].pos == "TOP" then
			if object.db.castingBarUse and object.db.castingBarPos == "TOP" then
				object[aura].anchor = object.castingBar
			elseif object.classBar and IUF.db.classBar.pos == "TOP" then
				object[aura].anchor = object.classBar
			else
				object[aura].anchor = object.topAnchorFrame
			end
			object[aura].lp, object[aura].lx, object[aura].ly = "BOTTOMLEFT", 0, object[aura].offset
			object[aura].np, object[aura].nx, object[aura].ny = "LEFT", object[aura].offset, 0
		else
			if object.db.castingBarUse and object.db.castingBarPos == "BOTTOM" then
				object[aura].anchor = object.castingBar
			elseif object.classBar and IUF.db.classBar.pos == "BOTTOM" then
				object[aura].anchor = object.classBar
			else
				object[aura].anchor = object.bottomAnchorFrame
			end
			object[aura].lp, object[aura].lx, object[aura].ly = "TOPLEFT", 0, -object[aura].offset
			object[aura].np, object[aura].nx, object[aura].ny = "LEFT", object[aura].offset, 0
		end
		for i = 1, #object[aura] do
			IUF:SetFontString(
				object[aura][i].cooldown.timer,
				object.db[aura.."CooldownTextFontFile"],
				object.db[aura.."CooldownTextFontSize"],
				object.db[aura.."CooldownTextFontAttribute"],
				object.db[aura.."CooldownTextFontShadow"]
			)
			IUF:SetFontString(object[aura][i].count, STANDARD_TEXT_FONT, object.db[aura.."CountTextFontSize"], "THICKOUTLINE,MONOCHROME", nil)
			if i > object[aura].num then
				object[aura][i]:Hide()
			end
		end
	else
		object[aura].num = 0
		for i = 1, #object[aura] do
			object[aura][i]:Hide()
		end
	end
	for i = object[aura].num + 1, #object[aura] do
		object[aura][i]:Hide()
	end
end

local function clearSkinElement(object, element)
	if object[element] then
		if element == "portrait" then
			object.portrait.aggro.use = nil
			object.portrait.aggro:Hide()
			object.showCombatFeedback = nil
		elseif element == "eliteFrame" then
			object[element]:SetFrameLevel(1)
		elseif element:find("^background(%d+)$") then
			object[element]:SetTexture("")
			object[element]:SetAlpha(1)
			object[element]:SetTexCoord(0, 1, 0, 1)
			object[element]:SetVertexColor(1, 1, 1)
		elseif element:find("^texture(%d+)$") then
			object[element]:SetDrawLayer("OVERLAY")
			object[element]:SetTexture("")
			object[element]:SetAlpha(1)
			object[element]:SetTexCoord(0, 1, 0, 1)
			object[element]:SetVertexColor(1, 1, 1)
		elseif element:find("^overlay(%d+)$") then
			object[element]:SetDrawLayer("BORDER")
			object[element]:SetTexture("")
			object[element]:SetAlpha(1)
			object[element]:SetTexCoord(0, 1, 0, 1)
			object[element]:SetVertexColor(1, 1, 1)
		elseif element:find("^border(%d+)$") then
			object[element]:SetFrameLevel(object:GetFrameLevel() + 1)
			object[element]:SetAlpha(1)
			object[element]:SetBackdrop(nil)
			object[element].gradient:Hide()
		end
		if not (element:find("^healthText(%d+)$") or element:find("^powerText(%d+)$")) then
			object[element]:ClearAllPoints()
			object[element]:SetWidth(0)
			object[element]:SetHeight(0)
		end
		if object[element].SetScale then
			object[element]:SetScale(1)
		end
		object[element].setting, object[element].use, object[element].isCircle = nil
		object[element]:Hide()
	end
end

local function setupSkinElement(object, element, width, height)
	if object[element] then
		skinvalue = object.db[element]
		if skinvalue then
			if type(skinvalue) == "string" and skinvalue:find("^return function") then
				loadstring(skinvalue)()(object[element], object, width, height, IUF)
				isfuncvalue = true
			else
				isfuncvalue = nil
			end
			objectType = object[element]:GetObjectType()
			if objectType == "StatusBar" then
				if object[element].SetBar then
					object[element]:SetTexture(SM:Fetch("statusbar", object.db[element.."Texture"] or "Smooth v2"))
					object[element].backgroundTex:SetAlpha(IUF.db.barBackgroundAlpha)
				else
					object[element]:SetStatusBarTexture(SM:Fetch("statusbar", object.db[element.."Texture"] or "Smooth v2"))
				end
				if element == "healthBar" then
					object[element].classColor = object.db.healthBarClassColor
				end
			elseif objectType == "FontString" then
				IUF:SetFontString(object[element], object.db[element.."FontFile"], object.db[element.."FontSize"], object.db[element.."FontAttribute"], object.db[element.."FontShadow"])
				if element == "nameText" then
					object.nameText.classColor = object.db.nameTextClassColor
				elseif element:find("^healthText(%d+)$") or element:find("^powerText(%d+)$") then
					object[element].combat = object.db[element.."InCombat"]
					if IUF:HasStatusBarDisplay(skinvalue) then

						object[element].display = skinvalue
						object[element]:Show()
					else
						object[element].display = nil
						object[element]:SetText(nil)
						object[element]:Hide()
					end
				end
			elseif element == "portrait" then
				object.portrait.show3dModel = object.db.portrait3DModel
				portraitOnSizeChanged(object.portrait)
				object.portrait:SetScript("OnSizeChanged", portraitOnSizeChanged)
				if object.feedbackFrame and object.db.combatFeedback then
					object.showCombatFeedback = true
					object.feedbackFrame.feedbackFontHeight = object.db.combatFeedbackFontSize
				end
				object.portrait.aggro:ClearAllPoints()
				if object.portrait.isCircle then
					if object.portrait.show3dModel then
						object.portrait.aggro:SetAllPoints(object.portrait.model3d)
					else
						object.portrait.aggro:SetAllPoints()
					end
					if IUF.db.skin == "Blizzard" then
						object.portrait.aggro:SetTexture("Interface\\TargetingFrame\\UI-Player-AttackStatus")
						if object.portrait.setting then
							object.portrait.aggro:SetTexCoord(0.21875, 0.00390625, 0.015625, 0.875)
						else
							object.portrait.aggro:SetTexCoord(0.00390625, 0.21875, 0.015625, 0.875)
						end
					else
						object.portrait.aggro:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\AggroBorder1")
						object.portrait.aggro:SetTexCoord(0, 1, 0, 1)
					end
				else
					object.portrait.aggro:ClearAllPoints()
					object.portrait.aggro:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\AggroBorder2")
					object.portrait.aggro:SetTexCoord(0, 1, 0, 1)
					if IUF.db.skin == "DefaultSquare" then
						object.portrait.aggro:SetPoint("TOPLEFT", 5, -5)
						object.portrait.aggro:SetPoint("BOTTOMRIGHT", -5, 5)
					else
						object.portrait.aggro:SetAllPoints()
					end
				end
				object.portrait.aggro.use = true
			elseif element == "castingBar" then
				object[element].bar:SetStatusBarTexture(SM:Fetch("statusbar", object.db.castingBarTexture or "Smooth v2"))
				object[element].icon:SetWidth(object[element].height - 2)
				object[element].bar.spark:SetHeight(object[element].height * 2.2)
				IUF:SetFontString(object[element].text, object.db.castingBarTextFontFile, object.db.castingBarTextFontSize, object.db.castingBarTextFontAttribute, object.db.castingBarTextFontShadow)
				IUF:SetFontString(object[element].bar.time, object.db.castingBarTimeFontFile, object.db.castingBarTimeFontSize, object.db.castingBarTimeFontAttribute, object.db.castingBarTimeFontShadow)
				if object.db.castingBarTextUse then
					object[element].text:Show()
				else
					object[element].text:Hide()
				end
				if object.db.castingBarTimeUse then
					object[element].bar.time:Show()
				else
					object[element].bar.time:Hide()
				end
				if object.buff[1] then
					object.buff[1]:ClearAllPoints()
				end
				if object.debuff[1] then
					object.debuff[1]:ClearAllPoints()
				end
				IUF:SetCastingBarPosition(object)
			elseif element == "eliteFrame" then
				object[element].use = object.db.eliteFrameUse
				if object.db.eliteFrameIsLeft then
					object.eliteFrame.tex:SetTexCoord(1, 0, 0, 1)
				else
					object.eliteFrame.tex:SetTexCoord(0, 1, 0, 1)
				end
			elseif element:find("(.+)Icon$") then
				object[element].use = object.db[element.."Use"] and true or nil
			elseif element:find("^border(%d+)$") then
				backdrop = object.db.backdrop
				if type(backdrop) == "table" then
					object[element]:SetBackdrop(backdrop)
					backdrop = object.db.backdropColor
					if type(backdrop) == "table" then
						object[element]:SetBackdropColor(unpack(backdrop))
					else
						object[element]:SetBackdropColor(0, 0, 0, 0.8)
					end
					backdrop = object.db.backdropBorderColor
					if type(backdrop) == "table" then
						object[element]:SetBackdropBorderColor(unpack(backdrop))
					else
						object[element]:SetBackdropColor(1, 1, 1)
					end
					backdrop = object[element]:GetBackdrop()
					if type(object.db.backdropGradient) == "table" then
						object[element].gradient:ClearAllPoints()
						object[element].gradient:SetPoint("TOPLEFT", backdrop.insets.left or 0, -(backdrop.insets.top or 0))
						object[element].gradient:SetPoint("BOTTOMRIGHT", -(backdrop.insets.right or 0), backdrop.insets.bottom)
--						object[element].gradient:SetGradientAlpha(unpack(object.db.backdropGradient))
--						object[element].gradient:SetAlpha(1.0)
--						object[element].gradient:SetVertexColor(0.1, 0.1, 0.1)
						object[element].gradient:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0), CreateColor(0.1, 0.1, 0.1, 1))
						object[element].gradient:Show()
					else
						object[element].gradient:Hide()
					end
				else
					object[element].gradient:Hide()
				end
				backdrop = nil
			elseif element == "overlay1" and object[element]:GetTexture("overlay1") then
				object[element].setting = true
			end
			if element == "classBar" and IUF.ClassBarSetup then
				IUF:ClassBarSetup(object)
				IUF:SetCastingBarPosition(object)
			else
				object[element]:Show()
			end
		end
	end
end

local function refreshAnchors(object)
	if object.allShownCheck then
		object.checkAllShown = nil
		object.allShownCheck:Show()
	end
end

function IUF:SetObjectSkin(object)
	if not object.portrait then return end
	-- 레이아웃 적용
	local width, height = object.db.width, object.db.height
	object.portrait:SetScript("OnSizeChanged", nil)
	object.portrait.border:Hide()
	object.portrait.model3d.bg:Hide()
	if object.feedbackFrame then
		object.showCombatFeedback = nil
		object.feedbackFrame:Hide()
		object.feedbackFrame.feedbackText:SetText(nil)
		object.feedbackFrame.feedbackStartTime = nil
	end
	object:SetLocation()
	for _, element in ipairs(defaultElements) do
		clearSkinElement(object, element)
	end
	for _, element in ipairs(defaultElements) do
		setupSkinElement(object, element, width, height)
	end
	object.textFrame:Show()
	object.aggroBorder:ClearAllPoints()
	skinvalue = object.db.aggroBorder
	if type(skinvalue) == "string" and skinvalue:find("^return function") then
		loadstring(skinvalue)()(object.aggroBorder, object, width, height, self)
	end
	object.highlight:ClearAllPoints()
	object.highlight:SetAlpha(self.db.highlightAlpha)
	skinvalue = object.db.highlight
	if type(skinvalue) == "string" and skinvalue:find("^return function") then
		skinvalue = loadstring(skinvalue)()
		skinvalue(object.highlight, object, width, height, self)
		if not object.aggroBorder:GetPoint() then
			skinvalue(object.aggroBorder, object, width, height, self)
		end
	else
		object.highlight:SetAllPoints(object)
		if not object.aggroBorder:GetPoint() then
			object.aggroBorder:SetAllPoints()
		end
	end
	if object.comboFrame then
		skinvalue = object.db.comboFrame
		if type(skinvalue) == "string" and skinvalue:find("^return function") then
			object.comboFrame:Show()
			for i = 1, 5 do
				object.comboFrame[i]:ClearAllPoints()
				object.comboFrame[i].highlight:SetVertexColor(unpack(self.colordb.combo))
			end
			loadstring(skinvalue)()(object.comboFrame, object, width, height, self)
		else
			object.comboFrame:Hide()
		end
	end
	skinvalue, objectType, backdrop = nil
	-- 버프/디버프 설정값 세팅
	setupAura(object, "buff")
	setupAura(object, "debuff")

--[[Edit mode오류로 임시 제거
	--Private Aura
if object.PrivateAuraAnchor then 

	RemovePrivateAuraAnchor(object.PrivateAuraAnchor)
 	object.PrivateAuraAnchor=nil
 
end

object.privateIcon1=CreateFrame("Frame", nil, object)

object.privateIcon1:SetSize(10,10) --private aura
object.privateIcon1:ClearAllPoints()
object.privateIcon1:SetPoint("CENTER",object,"CENTER",0,0)
object.privateIcon1:EnableMouse(false)

local auraAnchor = {
    unitToken = object.unit,
    auraIndex = 1,

    -- The parent frame of an aura anchor must have a valid rect with a non-zero
    -- size. Each private aura will anchor to all points on its parent,
    -- providing a tooltip when mouseovered.
    parent = object.privateIcon1,

    -- An optional cooldown spiral can be configured to represent duration.
    showCountdownFrame = true,
    showCountdownNumbers = true,

    -- An optional icon can be created and shown for the aura. Omitting this
    -- will display no icon.
    iconInfo = {
        iconWidth = 10,
        iconHeight = 10,
        iconAnchor = {
            point = "CENTER",
            relativeTo = object.privateIcon1,
            relativePoint = "CENTER",
            offsetX = 0,
            offsetY = 0,
        },
    },

    -- An optional icon duration fontstring can also be configured.
--    durationAnchor = {
--        point = "BOTTOM",
--        relativeTo = self.privateIcon1,
--        relativePoint = "BOTTOM",
--       offsetX = 0,
--        offsetY = 0,
--    },
}

local anchorIndex = C_UnitAuras.AddPrivateAuraAnchor(auraAnchor)
object.PrivateAuraAnchor = anchorIndex
--]]

	self:UpdateAllCallbacks(object)
	refreshAnchors(object)
	if object.objectType == "player" then
		if object.db.hiddenBlizzardCastingBar then
			PlayerCastingBarFrame.showCastbar = nil
			PetCastingBarFrame.showCastbar = nil
		else
			PlayerCastingBarFrame.showCastbar = true
			PetCastingBarFrame.showCastbar = true
		end
		--CastingBarFrame_UpdateIsShown(PlayerCastingBarFrame)
		--CastingBarFrame_UpdateIsShown(PetCastingBarFrame)
		PlayerCastingBarFrame:UpdateIsShown()
		PetCastingBarFrame:UpdateIsShown()
	end
	if object.feedbackFrame then
		IUF:RegsiterCombatFeedback()
	end
end

local function updateSkinElement(object, element)
	clearSkinElement(object, element)
	setupSkinElement(object, element, object.db.width, object.db.height)
end

local function clearAuraPos(object)
	if object then
		if object.buff[1] then
			object.buff[1]:ClearAllPoints()
		end
		if object.debuff[1] then
			object.debuff[1]:ClearAllPoints()
		end
	end
end

function IUF:SetObjectElementSkin(object, element)
	if not object.needElement and object[element] then
		if element == "classBar" then
			clearAuraPos(object)
			clearAuraPos(object.preview)
			updateSkinElement(object, element)
			updateSkinElement(object, "castingBar")
			self.callbacks.CastingBar(object)
			if self.ClassBarSetup then
				self:ClassBarSetup(object)
			end
			IUF:UpdateSkinAura(object)
		elseif element == "castingBar" then
			clearAuraPos(object)
			clearAuraPos(object.preview)
			updateSkinElement(object, element)
			self.callbacks.CastingBar(object)
			IUF:UpdateSkinAura(object)
		elseif element ~= "topAnchorFrame" and object.db.topAnchor == element then
			updateSkinElement(object, element)
			updateSkinElement(object, "topAnchorFrame")
			refreshAnchors(object)
		elseif element ~= "bottomAnchorFrame" and object.db.bottomAnchor == element then
			updateSkinElement(object, element)
			updateSkinElement(object, "bottomAnchorFrame")
			refreshAnchors(object)
		else
			updateSkinElement(object, element)
		end
	end
end

function IUF:UpdateSkinAura(object, check)
	if not object.needElement then
		if check == "buff" or check == "debuff" then
			setupAura(object, check)
		else
			setupAura(object, "buff")
			setupAura(object, "debuff")
		end
		self.callbacks.Aura(object)
		refreshAnchors(object)
	end
end