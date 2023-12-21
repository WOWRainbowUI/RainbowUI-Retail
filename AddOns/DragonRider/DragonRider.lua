local _, L = ...

local defaultsTable = {
	toggleModels = true,
	speedometerPosPoint = 1,
	speedometerPosX = 0,
	speedometerPosY = 5,
	speedometerScale = 1,
	speedValUnits = 1,
	speedBarColor = {
		slow = {
			r=196/255,
			g=97/255,
			b=0/255,
			a=1,
		},
		vigor = {
			r=0/255,
			g=144/255,
			b=155/255,
			a=1,
		},
		over = {
			r=168/255,
			g=77/255,
			b=195/255,
			a=1,
		},
	},
	speedTextColor = {
		slow = {
			r=1,
			g=1,
			b=1,
		},
		vigor = {
			r=1,
			g=1,
			b=1,
		},
		over = {
			r=1,
			g=1,
			b=1,
		},
	},
	speedTextScale = 12,
	glyphDetector = true,
	vigorProgressStyle = 1, -- 1 = vertical, 2 = horizontal, 3 = cooldown
	cooldownTimer = {
		whirlingSurge = true,
		bronzeTimelock = true,
		aerialHalt = true,
	},
	barStyle = 1, -- 1 = standard
	statistics = {},
	multiplayer = true,
	sideArt = true,
	sideArtStyle = 1,
	tempFixes = {
		hideVigor = true, -- this is now deprecated
	},

};

local function ShowColorPicker(r, g, b, a, changedCallback)
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
	ColorPickerFrame.previousValues = {r,g,b,a};
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
end

local function ProgBarLowColor(restore)
	local newR, newG, newB, newA; -- I forgot what to do with the alpha value but it's needed to not swap RGB values
	if restore then
	 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
	 -- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 -- Update our internal storage.
	r, g, b, a = newR, newG, newB, newA
	 -- And update any UI elements that use this color...
	DragonRider_DB.speedBarColor.slow.r, DragonRider_DB.speedBarColor.slow.g, DragonRider_DB.speedBarColor.slow.b, DragonRider_DB.speedBarColor.slow.a = newR, newG, newB, newA;
end

local function ProgBarMidColor(restore)
	local newR, newG, newB, newA; -- I forgot what to do with the alpha value but it's needed to not swap RGB values
	if restore then
	 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
	 -- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 -- Update our internal storage.
	r, g, b, a = newR, newG, newB, newA
	 -- And update any UI elements that use this color...
	DragonRider_DB.speedBarColor.vigor.r, DragonRider_DB.speedBarColor.vigor.g, DragonRider_DB.speedBarColor.vigor.b, DragonRider_DB.speedBarColor.vigor.a = newR, newG, newB, newA;
end

local function ProgBarHighColor(restore)
	local newR, newG, newB, newA; -- I forgot what to do with the alpha value but it's needed to not swap RGB values
	if restore then
	 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
	 -- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 -- Update our internal storage.
	r, g, b, a = newR, newG, newB, newA
	 -- And update any UI elements that use this color...
	DragonRider_DB.speedBarColor.over.r, DragonRider_DB.speedBarColor.over.g, DragonRider_DB.speedBarColor.over.b, DragonRider_DB.speedBarColor.over.a = newR, newG, newB, newA;
end

local function TextLowColor(restore)
	local newR, newG, newB, newA; -- I forgot what to do with the alpha value but it's needed to not swap RGB values
	if restore then
	 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
	 -- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 -- Update our internal storage.
	r, g, b, a = newR, newG, newB, newA
	 -- And update any UI elements that use this color...
	DragonRider_DB.speedTextColor.slow.r, DragonRider_DB.speedTextColor.slow.g, DragonRider_DB.speedTextColor.slow.b, DragonRider_DB.speedTextColor.slow.a = newR, newG, newB, newA;
end

local function TextMidColor(restore)
	local newR, newG, newB, newA; -- I forgot what to do with the alpha value but it's needed to not swap RGB values
	if restore then
	 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
	 -- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 -- Update our internal storage.
	r, g, b, a = newR, newG, newB, newA
	 -- And update any UI elements that use this color...
	DragonRider_DB.speedTextColor.vigor.r, DragonRider_DB.speedTextColor.vigor.g, DragonRider_DB.speedTextColor.vigor.b, DragonRider_DB.speedTextColor.vigor.a = newR, newG, newB, newA;
end

local function TextHighColor(restore)
	local newR, newG, newB, newA; -- I forgot what to do with the alpha value but it's needed to not swap RGB values
	if restore then
	 -- The user bailed, we extract the old color from the table created by ShowColorPicker.
		newR, newG, newB, newA = unpack(restore);
	else
	 -- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	 -- Update our internal storage.
	r, g, b, a = newR, newG, newB, newA
	 -- And update any UI elements that use this color...
	DragonRider_DB.speedTextColor.over.r, DragonRider_DB.speedTextColor.over.g, DragonRider_DB.speedTextColor.over.b, DragonRider_DB.speedTextColor.over.a = newR, newG, newB, newA;
end




local DR = CreateFrame("Frame", nil, UIParent)

DR.statusbar = CreateFrame("StatusBar", nil, UIParent)
DR.statusbar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
DR.statusbar:SetWidth(305/1.25)
DR.statusbar:SetHeight(66.5/2.75)
DR.statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
DR.statusbar:GetStatusBarTexture():SetVertTile(false)
DR.statusbar:SetStatusBarColor(.98, .61, .0)
DR.statusbar:SetMinMaxValues(0, 100)
Mixin(DR.statusbar, SmoothStatusBarMixin)
DR.statusbar:SetMinMaxSmoothedValue(0,100)

DR.tick1 = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
DR.tick1:SetSize(17,DR.statusbar:GetHeight()*1.5)
DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 5)

DR.tick2 = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.tick2:SetAtlas("UI-Frame-Bar-BorderTick")
DR.tick2:SetSize(17,DR.statusbar:GetHeight()*1.5)
DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), 5)

--[[
DR.tick25 = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.tick25:SetAtlas("UI-Frame-Bar-BorderTick")
DR.tick25:SetSize(17,DR.statusbar:GetHeight()*1)
DR.tick25:SetPoint("TOP", DR.statusbar, "TOPLEFT", (25 / 100) * DR.statusbar:GetWidth(), 5)

DR.tick50 = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.tick50:SetAtlas("UI-Frame-Bar-BorderTick")
DR.tick50:SetSize(17,DR.statusbar:GetHeight()*1)
DR.tick50:SetPoint("TOP", DR.statusbar, "TOPLEFT", (50 / 100) * DR.statusbar:GetWidth(), 5)

DR.tick75 = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.tick75:SetAtlas("UI-Frame-Bar-BorderTick")
DR.tick75:SetSize(17,DR.statusbar:GetHeight()*1)
DR.tick75:SetPoint("TOP", DR.statusbar, "TOPLEFT", (75 / 100) * DR.statusbar:GetWidth(), 5)
]]


DR.backdropL = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.backdropL:SetAtlas("widgetstatusbar-borderleft") -- UI-Frame-Dragonflight-TitleLeft
DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -7, 0)
DR.backdropL:SetWidth(35)
DR.backdropL:SetHeight(40)

DR.backdropR = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.backdropR:SetAtlas("widgetstatusbar-borderright") -- UI-Frame-Dragonflight-TitleRight
DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 7, 0)
DR.backdropR:SetWidth(35)
DR.backdropR:SetHeight(40)

DR.backdropM = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.backdropM:SetAtlas("widgetstatusbar-bordercenter") -- _UI-Frame-Dragonflight-TitleMiddle
DR.backdropM:SetPoint("TOPLEFT", DR.backdropL, "TOPRIGHT", 0, 0)
DR.backdropM:SetPoint("BOTTOMRIGHT", DR.backdropR, "BOTTOMLEFT", 0, 0)

DR.backdropTopper = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.backdropTopper:SetAtlas("dragonflight-score-topper")
DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 38)
DR.backdropTopper:SetWidth(350)
DR.backdropTopper:SetHeight(65)

DR.backdropFooter = DR.statusbar:CreateTexture(nil, "OVERLAY")
DR.backdropFooter:SetAtlas("dragonflight-score-footer")
DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -32)
DR.backdropFooter:SetWidth(350)
DR.backdropFooter:SetHeight(65)

DR.statusbar.bg = DR.statusbar:CreateTexture(nil, "BACKGROUND")
DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
DR.statusbar.bg:SetAllPoints(true)
DR.statusbar.bg:SetVertexColor(.0, .0, .0, .8)

DR.glide = DR.statusbar:CreateFontString(nil, nil, "GameTooltipText")
DR.glide:SetPoint("LEFT", DR.statusbar, "LEFT", 10, 0)

DR.model = {};
DR.modelScene = {};

function DR:modelSetup(number)
	if C_UnitAuras.GetPlayerAuraBySpellID(417888) then -- algarian stormrider
		DR.model[number]:SetModelByFileID(3009394)
		DR.model[number]:SetPosition(5,0,-1.5)
		--DR.model1:SetPitch(.3)
		DR.model[number]:SetYaw(0)
	else
		DR.model[number]:SetModelByFileID(1100194)
		DR.model[number]:SetPosition(5,0,-1.5)
		--DR.model1:SetPitch(.3)
		DR.model[number]:SetYaw(0)
	end
end

for i = 1,6 do
	DR.modelScene[i] = CreateFrame("ModelScene", nil, UIParent)
	DR.modelScene[i]:SetPoint("CENTER", DR.statusbar, "CENTER", -145+(i*40), -36)
	DR.modelScene[i]:SetWidth(43)
	DR.modelScene[i]:SetHeight(43)
	DR.modelScene[i]:SetFrameStrata("MEDIUM")
	DR.modelScene[i]:SetFrameLevel(500)

	DR.model[i] = DR.modelScene[i]:CreateActor()

	DR:modelSetup(i)
end


function DR.toggleModels()
	for i = 1,6 do
		DR.modelScene[i]:Hide()
	end
end

DR.toggleModels()

function DR.useUnits()
	if DragonRider_DB.speedValUnits == 1 then
		return " " .. L["UnitYards"]
	elseif DragonRider_DB.speedValUnits == 2 then
		return " " .. L["UnitMiles"]
	elseif DragonRider_DB.speedValUnits == 3 then
		return " " .. L["UnitMeters"]
	elseif DragonRider_DB.speedValUnits == 4 then
		return " " .. L["UnitKilometers"]
	elseif DragonRider_DB.speedValUnits == 5 then
		return "%" .. L["UnitPercent"]
	elseif DragonRider_DB.speedValUnits == 6 then
		return ""
	else
		return L["UnitYards"]
	end
end

function DR:convertUnits(forwardSpeed)
	if DragonRider_DB.speedValUnits == 1 then
		return forwardSpeed
	elseif DragonRider_DB.speedValUnits == 2 then
		return forwardSpeed*2.045
	elseif DragonRider_DB.speedValUnits == 3 then
		return forwardSpeed
	elseif DragonRider_DB.speedValUnits == 4 then
		return forwardSpeed*3.6
	elseif DragonRider_DB.speedValUnits == 5 then
		return forwardSpeed/7*100
	elseif DragonRider_DB.speedValUnits == 6 then
		return forwardSpeed
	else
		return forwardSpeed
	end
end

function DR.updateSpeed()
	local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
	local base = isGliding and forwardSpeed or GetUnitSpeed("player")
	local movespeed = Round(base / BASE_MOVEMENT_SPEED * 100)
	local roundedSpeed = Round(forwardSpeed, 3)
	local NotDragonIsles = C_UnitAuras.GetPlayerAuraBySpellID(432503)
	if UIWidgetPowerBarContainerFrame:HasAnyWidgetsShowing() == true then
		DR:Show()
	end
	if NotDragonIsles then
		DR.statusbar:SetMinMaxValues(0, 85)
		if forwardSpeed > 52 then
			local textColor = CreateColor(DragonRider_DB.speedTextColor.over.r, DragonRider_DB.speedTextColor.over.g, DragonRider_DB.speedTextColor.over.b):GenerateHexColor()
			DR.glide:SetText(format("|c" .. textColor .. "%.1f" .. DR.useUnits() .. "|r", DR:convertUnits(forwardSpeed))) -- ff71d5ff (nice purple?) -
			DR.statusbar:SetStatusBarColor(DragonRider_DB.speedBarColor.over.r, DragonRider_DB.speedBarColor.over.g, DragonRider_DB.speedBarColor.over.b, DragonRider_DB.speedBarColor.over.a)
		elseif forwardSpeed >= 47.8 and forwardSpeed <= 52 then
			local textColor = CreateColor(DragonRider_DB.speedTextColor.vigor.r, DragonRider_DB.speedTextColor.vigor.g, DragonRider_DB.speedTextColor.vigor.b):GenerateHexColor()
			DR.glide:SetText(format("|c" .. textColor .. "%.1f" .. DR.useUnits() .. "|r", DR:convertUnits(forwardSpeed))) -- ff71d5ff (nice blue?) - 
			DR.statusbar:SetStatusBarColor(DragonRider_DB.speedBarColor.vigor.r, DragonRider_DB.speedBarColor.vigor.g, DragonRider_DB.speedBarColor.vigor.b, DragonRider_DB.speedBarColor.vigor.a)
		else
			local textColor = CreateColor(DragonRider_DB.speedTextColor.slow.r, DragonRider_DB.speedTextColor.slow.g, DragonRider_DB.speedTextColor.slow.b):GenerateHexColor()
			DR.glide:SetText(format("|c" .. textColor .. "%.1f" .. DR.useUnits() .. "|r", DR:convertUnits(forwardSpeed))) -- fff2a305 (nice yellow?) - 
			DR.statusbar:SetStatusBarColor(DragonRider_DB.speedBarColor.slow.r, DragonRider_DB.speedBarColor.slow.g, DragonRider_DB.speedBarColor.slow.b, DragonRider_DB.speedBarColor.slow.a)
		end
	else
		DR.statusbar:SetMinMaxValues(0, 100)
		if forwardSpeed > 65 then
			local textColor = CreateColor(DragonRider_DB.speedTextColor.over.r, DragonRider_DB.speedTextColor.over.g, DragonRider_DB.speedTextColor.over.b):GenerateHexColor()
			DR.glide:SetText(format("|c" .. textColor .. "%.1f" .. DR.useUnits() .. "|r", DR:convertUnits(forwardSpeed))) -- ff71d5ff (nice purple?) -
			DR.statusbar:SetStatusBarColor(DragonRider_DB.speedBarColor.over.r, DragonRider_DB.speedBarColor.over.g, DragonRider_DB.speedBarColor.over.b, DragonRider_DB.speedBarColor.over.a)
		elseif forwardSpeed >= 60 and forwardSpeed <= 65 then
			local textColor = CreateColor(DragonRider_DB.speedTextColor.vigor.r, DragonRider_DB.speedTextColor.vigor.g, DragonRider_DB.speedTextColor.vigor.b):GenerateHexColor()
			DR.glide:SetText(format("|c" .. textColor .. "%.1f" .. DR.useUnits() .. "|r", DR:convertUnits(forwardSpeed))) -- ff71d5ff (nice blue?) - 
			DR.statusbar:SetStatusBarColor(DragonRider_DB.speedBarColor.vigor.r, DragonRider_DB.speedBarColor.vigor.g, DragonRider_DB.speedBarColor.vigor.b, DragonRider_DB.speedBarColor.vigor.a)
		else
			local textColor = CreateColor(DragonRider_DB.speedTextColor.slow.r, DragonRider_DB.speedTextColor.slow.g, DragonRider_DB.speedTextColor.slow.b):GenerateHexColor()
			DR.glide:SetText(format("|c" .. textColor .. "%.1f" .. DR.useUnits() .. "|r", DR:convertUnits(forwardSpeed))) -- fff2a305 (nice yellow?) - 
			DR.statusbar:SetStatusBarColor(DragonRider_DB.speedBarColor.slow.r, DragonRider_DB.speedBarColor.slow.g, DragonRider_DB.speedBarColor.slow.b, DragonRider_DB.speedBarColor.slow.a)
		end
	end
	if DragonRider_DB.speedValUnits == 6 then
		DR.glide:SetText("")
	end
	DR.statusbar:SetSmoothedValue(forwardSpeed)
end

DR.TimerNamed = C_Timer.NewTicker(.1, function()
	DR.updateSpeed()
end)
DR.TimerNamed:Cancel();


DR.MountEvents = {
	["PLAYER_MOUNT_DISPLAY_CHANGED"] = true,
	["MOUNT_JOURNAL_USABILITY_CHANGED"] = true,
	["LEARNED_SPELL_IN_TAB"] = true,
	["PLAYER_CAN_GLIDE_CHANGED"] = true,
	["COMPANION_UPDATE"] = true,
	["PLAYER_LOGIN"] = true,
};

DR.Mounts = {
	-- Cup Race Buffs (fake)
	413409, -- highland drake [OLD]
	417548, -- proto-drake [OLD]
	417554, -- wylderdrake [OLD]
	417552, -- velocidrake [OLD]
	417556, -- slitherdrake [OLD]
	412088, -- grotto netherwing drake
	425338, -- flourishing whimsydrake
	-- Non-mounts
	369536, -- soar
	-- Real Mounts
	360954, -- highland drake
	368896, -- proto-drake
	368901, -- wylderdrake
	368899, -- velocidrake
	368893, -- slitherdrake
	412088, -- grotto netherwing drake
	417888, -- algarian stormrider
	425338, -- flourishing whimsydrake
};

--other buffs
--418590, -- Static Charge (stacks on algarian stormrider, 10 = 418592 (Lightning Rush) is usable)

DR.vigorEvent = CreateFrame("Frame")
DR.vigorEvent:RegisterEvent("UNIT_POWER_UPDATE")


function DR.vigorCounter()
	local vigorCurrent = UnitPower("player", Enum.PowerType.AlternateMount)
	local vigorMax = UnitPowerMax("player", Enum.PowerType.AlternateMount)

	if DragonRider_DB.toggleModels == false then
		DR.toggleModels()
		return
	end

	if vigorCurrent == 0 then
		DR.toggleModels()
	end

	local frameLevelThing = UIWidgetPowerBarContainerFrame:GetFrameLevel()+15
	for i = 1,6 do
		if vigorCurrent >= i then
			DR.modelScene[i]:Show()
		else
			DR.modelScene[i]:Hide()
		end
		DR.modelScene[i]:SetFrameLevel(frameLevelThing)
	end
	DR.setPositions()
end

DR.vigorEvent:SetScript("OnEvent", DR.vigorCounter)

DR:RegisterEvent("ADDON_LOADED")
DR:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
DR:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
DR:RegisterEvent("LEARNED_SPELL_IN_TAB")
DR:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
DR:RegisterEvent("COMPANION_UPDATE")
DR:RegisterEvent("PLAYER_LOGIN")


function DR.setPositions()
	DR.statusbar:ClearAllPoints();
	DR.statusbar:SetPoint("BOTTOM", UIWidgetPowerBarContainerFrame, "TOP", 0, 5);
	if DragonRider_DB.speedometerPosPoint == 1 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("BOTTOM", UIWidgetPowerBarContainerFrame, "TOP", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	elseif DragonRider_DB.speedometerPosPoint == 2 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("TOP", UIWidgetPowerBarContainerFrame, "BOTTOM", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	elseif DragonRider_DB.speedometerPosPoint == 3 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("RIGHT", UIWidgetPowerBarContainerFrame, "LEFT", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	elseif DragonRider_DB.speedometerPosPoint == 4 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("LEFT", UIWidgetPowerBarContainerFrame, "RIGHT", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	end
	local PowerBarChildren = {UIWidgetPowerBarContainerFrame:GetChildren()}
	if PowerBarChildren[3] ~= nil then
		for _, child in ipairs({PowerBarChildren[3]:GetRegions()}) do
			if DragonRider_DB.sideArt == false then
				child:SetAlpha(0)
			else
				child:SetAlpha(1)
			end
		end
	end
	DR.statusbar:SetScale(DragonRider_DB.speedometerScale)
	for i = 1,6 do
		DR.modelScene[i]:ClearAllPoints();
	end
	
	if C_UnitAuras.GetPlayerAuraBySpellID(417888) then 
		local spacing = 50
		if DR.model[1]:GetModelFileID() == 1100194 then
			for i = 1,6 do
				DR:modelSetup(i)
			end
		end
		-- algarian stormrider uses gems for the vigor bar, spacing is ~50
		if IsPlayerSpell(377922) == true then -- 6 vigor
			for i = 1,6 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -175+(i*spacing), 14);
			end
		elseif IsPlayerSpell(377921) == true then -- 5 vigor
			for i = 1,5 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -150+(i*spacing), 14);
			end
			for i = 6,6,-1 do
				DR.modelScene[i]:Hide()
			end
		elseif IsPlayerSpell(377920) == true then -- 4 vigor
			for i = 1,4 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -125+(i*spacing), 14);
			end
			for i = 6,5,-1 do
				DR.modelScene[i]:Hide()
			end
		else
			for i = 1,3 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -100+(i*spacing), 14);
			end
			for i = 6,4,-1 do
				DR.modelScene[i]:Hide()
			end
		end
	else
		local spacing = 42
		if DR.model[1]:GetModelFileID() == 3009394 then
			for i = 1,6 do
				DR:modelSetup(i)
			end
		end
		--dragonriding is a spacing diff of 42
		if IsPlayerSpell(377922) == true then -- 6 vigor
			for i = 1,6 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -147+(i*spacing), 14);
			end
		elseif IsPlayerSpell(377921) == true then -- 5 vigor
			for i = 1,5 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -126+(i*spacing), 14);
			end
			for i = 6,6,-1 do
				DR.modelScene[i]:Hide()
			end
		elseif IsPlayerSpell(377920) == true then -- 4 vigor
			for i = 1,4 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -105+(i*spacing), 14);
			end
			for i = 6,5,-1 do
				DR.modelScene[i]:Hide()
			end
		else
			for i = 1,3 do 
				DR.modelScene[i]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, "CENTER", -84+(i*spacing), 14);
			end
			for i = 6,4,-1 do
				DR.modelScene[i]:Hide()
			end
		end
	end

	DR.glide:SetFont(STANDARD_TEXT_FONT, DragonRider_DB.speedTextScale)    
end

function DR.clearPositions()
	DR.statusbar:ClearAllPoints();
	DR.statusbar:Hide();
end

DR.clearPositions()


function DR:toggleEvent(event, arg1)
	if event == "ADDON_LOADED" and arg1 == "DragonRider" then
		
		if DragonRider_DB == nil then
			DragonRider_DB = CopyTable(defaultsTable)
		end

		if DragonRider_DB.sideArt == nil then
			DragonRider_DB.sideArt = true
		end
		if DragonRider_DB.sideArtStyle == nil then
			DragonRider_DB.sideArtStyle = 1
		end
		if DragonRider_DB.tempFixes == nil then
			DragonRider_DB.tempFixes = {};
		end
		if DragonRider_DB.tempFixes.hideVigor == nil then -- this is now deprecated
			DragonRider_DB.tempFixes.hideVigor = true
		end


		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------

		local function OnSettingChanged(_, setting, value)
			local variable = setting:GetVariable()
			DragonRider_DB[variable] = value
			DR.vigorCounter()
			DR.setPositions()
		end

		local category, layout = Settings.RegisterVerticalLayoutCategory(L["DragonRider"])

		--layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(string.format(L["Version"], GetAddOnMetadata("DragonRider", "Version"))));

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["ProgressBar"]));

		do
			local variable = "speedometerPosPoint"
			local defaultValue = 1  -- Corresponds to "Option 1" below.
			local name = L["SpeedPosPointName"]
			local tooltip = L["SpeedPosPointTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add(1, L["Top"])
				container:Add(2, L["Bottom"])
				container:Add(3, L["Left"])
				container:Add(4, L["Right"])
				return container:GetData()
			end

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			Settings.CreateDropDown(category, setting, GetOptions, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end

		do
			local variable = "speedometerPosX"
			local name = L["SpeedPosXName"]
			local tooltip = L["SpeedPosXTT"]
			local defaultValue = 0
			local minValue = -Round(GetScreenWidth())
			local maxValue = Round(GetScreenWidth())
			local step = 1

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end

		do
			local variable = "speedometerPosY"
			local name = L["SpeedPosYName"]
			local tooltip = L["SpeedPosYTT"]
			local defaultValue = 5
			local minValue = -Round(GetScreenHeight())
			local maxValue = Round(GetScreenHeight())
			local step = 1

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end

		do
			local variable = "speedometerScale"
			local name = L["SpeedScaleName"]
			local tooltip = L["SpeedScaleTT"]
			local defaultValue = 1
			local minValue = .4
			local maxValue = 4
			local step = .1

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end

		do
			local variable = "speedValUnits"
			local defaultValue = 1  -- Corresponds to "Option 1" below.
			local name = L["Units"]
			local tooltip = L["UnitsTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add(1, L["Yards"] .. " - " .. L["UnitYards"])
				container:Add(2, L["Miles"] .. " - " .. L["UnitMiles"])
				container:Add(3, L["Meters"] .. " - " .. L["UnitMeters"])
				container:Add(4, L["Kilometers"] .. " - " .. L["UnitKilometers"])
				container:Add(5, L["Percent"] .. " - " .. L["UnitPercent"])
				container:Add(6, NONE)
				return container:GetData()
			end

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			Settings.CreateDropDown(category, setting, GetOptions, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end

		do
			local variable = "speedTextScale"
			local name = L["SpeedTextScale"]
			local tooltip = L["SpeedTextScaleTT"]
			local defaultValue = 12
			local minValue = 2
			local maxValue = 30
			local step = .5

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end


		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Vigor"]));

		do
			local variable = "toggleModels"
			local name = L["ToggleModelsName"]
			local tooltip = L["ToggleModelsTT"]
			local defaultValue = true

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			Settings.CreateCheckBox(category, setting, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end

		do
			local variable = "sideArt"
			local name = L["SideArtName"]
			local tooltip = L["SideArtTT"]
			local defaultValue = true

			local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaultValue), defaultValue)
			Settings.CreateCheckBox(category, setting, tooltip)
			Settings.SetOnValueChangedCallback(variable, OnSettingChanged)
			setting:SetValue(DragonRider_DB[variable])
		end


		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["DragonridingTalents"]));

		do -- dragonriding talents 
			local function OnButtonClick()
				CloseWindows();
				DragonridingPanelSkillsButtonMixin:OnClick();
			end

			local initializer = CreateSettingsButtonInitializer(L["OpenDragonridingTalents"], L["DragonridingTalents"], OnButtonClick, L["OpenDragonridingTalentsTT"], true);
			layout:AddInitializer(initializer);
		end


		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COLOR_PICKER));

		do -- color picker - low progress bar color
			local function OnButtonClick()
				ShowColorPicker(DragonRider_DB.speedBarColor.slow.r, DragonRider_DB.speedBarColor.slow.g, DragonRider_DB.speedBarColor.slow.b, DragonRider_DB.speedBarColor.slow.a, ProgBarLowColor);
			end

			local initializer = CreateSettingsButtonInitializer(L["ProgressBarColor"] .. " - " .. L["Low"], COLOR_PICKER, OnButtonClick, L["ColorPickerLowProgTT"], true);
			layout:AddInitializer(initializer);
		end


		do -- color picker - mid progress bar color
			local function OnButtonClick()
				ShowColorPicker(DragonRider_DB.speedBarColor.vigor.r, DragonRider_DB.speedBarColor.vigor.g, DragonRider_DB.speedBarColor.vigor.b, DragonRider_DB.speedBarColor.vigor.a, ProgBarMidColor);
			end

			local initializer = CreateSettingsButtonInitializer(L["ProgressBarColor"] .. " - " .. L["Vigor"], COLOR_PICKER, OnButtonClick, L["ColorPickerMidProgTT"], true);
			layout:AddInitializer(initializer);
		end


		do -- color picker - high progress bar color
			local function OnButtonClick()
				ShowColorPicker(DragonRider_DB.speedBarColor.over.r, DragonRider_DB.speedBarColor.over.g, DragonRider_DB.speedBarColor.over.b, DragonRider_DB.speedBarColor.over.a, ProgBarHighColor);
			end

			local initializer = CreateSettingsButtonInitializer(L["ProgressBarColor"] .. " - " .. L["High"], COLOR_PICKER, OnButtonClick, L["ColorPickerHighProgTT"], true);
			layout:AddInitializer(initializer);
		end


		do -- color picker - low speed text color
			local function OnButtonClick()
				ShowColorPicker(DragonRider_DB.speedTextColor.slow.r, DragonRider_DB.speedTextColor.slow.g, DragonRider_DB.speedTextColor.slow.b, DragonRider_DB.speedTextColor.slow.a, TextLowColor);
			end

			local initializer = CreateSettingsButtonInitializer(L["UnitsColor"] .. " - " .. L["Low"], COLOR_PICKER, OnButtonClick, L["ColorPickerLowTextTT"], true);
			layout:AddInitializer(initializer);
		end


		do -- color picker - mid speed text color
			local function OnButtonClick()
				ShowColorPicker(DragonRider_DB.speedTextColor.vigor.r, DragonRider_DB.speedTextColor.over.g, DragonRider_DB.speedTextColor.over.b, DragonRider_DB.speedTextColor.over.a, TextMidColor);
			end

			local initializer = CreateSettingsButtonInitializer(L["UnitsColor"] .. " - " .. L["Vigor"], COLOR_PICKER, OnButtonClick, L["ColorPickerMidTextTT"], true);
			layout:AddInitializer(initializer);
		end


		do -- color picker - high speed text color
			local function OnButtonClick()
				ShowColorPicker(DragonRider_DB.speedTextColor.over.r, DragonRider_DB.speedTextColor.over.g, DragonRider_DB.speedTextColor.over.b, DragonRider_DB.speedTextColor.over.a, TextHighColor);
			end

			local initializer = CreateSettingsButtonInitializer(L["UnitsColor"] .. " - " .. L["High"], COLOR_PICKER, OnButtonClick, L["ColorPickerHighTextTT"], true);
			layout:AddInitializer(initializer);
		end












		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RESET));

		StaticPopupDialogs["DRAGONRIDER_RESET_SETTINGS"] = {
			text = L["ResetAllSettingsConfirm"],
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				DragonRider_DB = nil;
				DragonRider_DB = CopyTable(defaultsTable);
				DR.vigorCounter();
				DR.setPositions();
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		};

		do -- color picker - high speed text color
			local function OnButtonClick()
				StaticPopup_Show("DRAGONRIDER_RESET_SETTINGS");
			end

			local initializer = CreateSettingsButtonInitializer(L["ResetAllSettings"], RESET, OnButtonClick, L["ResetAllSettingsTT"], true);
			layout:AddInitializer(initializer);
		end

		Settings.RegisterAddOnCategory(category)



		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------

		DR.vigorCounter()
	end

	if DR.MountEvents[event] then
		local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
		if canGlide == true then
			DR.setPositions();
			DR.TimerNamed:Cancel();
			DR.TimerNamed = C_Timer.NewTicker(.1, function()
				DR.updateSpeed();
			end)
			DR.statusbar:Show();
		else
			DR.clearPositions();
			DR.TimerNamed:Cancel();
		end
	end
end


DR:SetScript("OnEvent", DR.toggleEvent)