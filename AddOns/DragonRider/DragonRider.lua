local DragonRider, DR = ...
local _, L = ...

--A purposeful global variable for other addons
DragonRider_API = DR

---@type LibAdvFlight
local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.0");

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
	showtooltip = true,
	fadeVigor = true,
	fadeSpeed = true,
	lightningRush = true,
	muteVigorSound = false,
	themeSpeed = 1, -- default
	themeVigor = 1, -- default

};

-- here, we just pass in the table containing our saved color config
function DR:ShowColorPicker(configTable)
	local r, g, b, a = configTable.r, configTable.g, configTable.b, configTable.a;

	local function OnColorChanged()
		local newR, newG, newB = ColorPickerFrame:GetColorRGB();
		local newA = ColorPickerFrame:GetColorAlpha();
		configTable.r, configTable.g, configTable.b, configTable.a = newR, newG, newB, newA;
	end

	local function OnCancel()
		configTable.r, configTable.g, configTable.b, configTable.a = r, g, b, a;
	end

	local options = {
		swatchFunc = OnColorChanged,
		opacityFunc = OnColorChanged,
		cancelFunc = OnCancel,
		hasOpacity = a ~= nil,
		opacity = a,
		r = r,
		g = g,
		b = b,
	};

	ColorPickerFrame:SetupColorPickerAndShow(options);
end

DR.WidgetFrameIDs = {
	4460, -- generic DR
	4604, -- non-DR
	5140, -- gold gryphon
	5143, -- silver gryphon
	5144, -- bronze gryphon
	5145, -- dark gryphon
};

--Blizzard has removed the ability to check for "Riding Abroad" in 11.0 while also not adding new API to compensate.
DR.DragonRidingZoneIDs = {
	2444, -- Dragon Isles
	2454, -- Zaralek Cavern
	2548, -- Emerald Dream
	2549, -- Amirdrassil Raid
	2516, -- The Nokhud Offensive
};

function DR.DragonRidingZoneCheck()
	for k, v in pairs(DR.DragonRidingZoneIDs) do
		if GetInstanceInfo() then
			local instanceID = select(8, GetInstanceInfo())
			if instanceID == v then
				return true;
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------
-- DRIVE system
---------------------------------------------------------------------------------------------------------------

local DRIVE_LAST_TIME;
local DRIVE_LAST_POS;
local DriveUtils = {};

function DriveUtils.GetPosition()
    local map = C_Map.GetBestMapForUnit("player");
    local pos = C_Map.GetPlayerMapPosition(map, "player");
    local _, worldPos = C_Map.GetWorldPosFromMapPos(map, pos);
    return worldPos;
end

function DriveUtils.GetSpeed()
	if not IsPlayerMoving() then
		return 0;
	end

	local currentPos = DriveUtils.GetPosition();
	if not currentPos then
		return 0;
	end

	if not DRIVE_LAST_POS then
		DRIVE_LAST_POS = CreateVector2D(currentPos:GetXY());
		return 0;
	end

	local currentTime = GetTime();
	if not DRIVE_LAST_TIME then
		DRIVE_LAST_TIME = currentTime;
		return 0;
	end

	local dx, dy = Vector2D_Subtract(currentPos.x, currentPos.y, DRIVE_LAST_POS.x, DRIVE_LAST_POS.y);
	local distance = sqrt(dx^2 + dy^2);
	local speed = distance / (currentTime - DRIVE_LAST_TIME);

	DRIVE_LAST_TIME = currentTime;
	DRIVE_LAST_POS:SetXY(currentPos:GetXY());

	return speed;
end

local DRIVE_MAX_SAMPLES = 3;
local SPEED_SAMPLES = CreateCircularBuffer(DRIVE_MAX_SAMPLES);

function DriveUtils.GetSmoothedSpeed()
	if not IsPlayerMoving() then
		return 0;
	end

	local currentSpeed = DriveUtils.GetSpeed();
	SPEED_SAMPLES:PushFront(currentSpeed);

	local total = 0;
	for _, speed in SPEED_SAMPLES:EnumerateIndexedEntries() do
		total = total + speed;
	end

	return total / SPEED_SAMPLES:GetNumElements();
end

local CAR_SPELL_ID = 460013;
function DriveUtils.IsDriving()
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(CAR_SPELL_ID);
    return aura and true or false;
end

---------------------------------------------------------------------------------------------------------------
-- DRIVE system
---------------------------------------------------------------------------------------------------------------


DR.statusbar = CreateFrame("StatusBar", "DRStatusBar", UIParent)
DR.statusbar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
DR.statusbar:SetWidth(305/1.25)
DR.statusbar:SetHeight(66.5/2.75)
DR.statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
DR.statusbar:GetStatusBarTexture():SetVertTile(false)
DR.statusbar:SetStatusBarColor(.98, .61, .0)
Mixin(DR.statusbar, SmoothStatusBarMixin)
DR.statusbar:SetMinMaxSmoothedValue(0,100)

DR.tick1 = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 1)
DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
DR.tick1:SetSize(17,DR.statusbar:GetHeight()*1.5)
DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 5)

DR.tick2 = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 1)
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


DR.backdropL = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 2)
DR.backdropL:SetAtlas("widgetstatusbar-borderleft") -- UI-Frame-Dragonflight-TitleLeft
DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -7, 0)
DR.backdropL:SetWidth(35)
DR.backdropL:SetHeight(40)

DR.backdropR = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 2)
DR.backdropR:SetAtlas("widgetstatusbar-borderright") -- UI-Frame-Dragonflight-TitleRight
DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 7, 0)
DR.backdropR:SetWidth(35)
DR.backdropR:SetHeight(40)

DR.backdropM = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 2)
DR.backdropM:SetAtlas("widgetstatusbar-bordercenter") -- _UI-Frame-Dragonflight-TitleMiddle
DR.backdropM:SetPoint("TOPLEFT", DR.backdropL, "TOPRIGHT", 0, 0)
DR.backdropM:SetPoint("BOTTOMRIGHT", DR.backdropR, "BOTTOMLEFT", 0, 0)

DR.backdropTopper = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 1)
DR.backdropTopper:SetAtlas("dragonflight-score-topper")
DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 38)
DR.backdropTopper:SetWidth(350)
DR.backdropTopper:SetHeight(65)

DR.backdropFooter = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 1)
DR.backdropFooter:SetAtlas("dragonflight-score-footer")
DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -32)
DR.backdropFooter:SetWidth(350)
DR.backdropFooter:SetHeight(65)

DR.statusbar.bg = DR.statusbar:CreateTexture(nil, "BACKGROUND", nil, 0)
DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
DR.statusbar.bg:SetAllPoints(true)
DR.statusbar.bg:SetVertexColor(.0, .0, .0, .8)

local frameborder = CreateFrame("frame",nil,DR.statusbar)
frameborder:SetAllPoints(DR.statusbar)
frameborder:SetFrameStrata("BACKGROUND")
frameborder:SetFrameLevel(1)
frameborder.left = frameborder:CreateTexture(nil,"BORDER")
frameborder.left:SetPoint("BOTTOMLEFT",frameborder,"BOTTOMLEFT",-2,-2)
frameborder.left:SetPoint("TOPRIGHT",frameborder,"TOPLEFT",0,0)
frameborder.left:SetColorTexture(0,0,0,1)
frameborder.right = frameborder:CreateTexture(nil,"BORDER")
frameborder.right:SetPoint("BOTTOMLEFT",frameborder,"BOTTOMRIGHT",0,0)
frameborder.right:SetPoint("TOPRIGHT",frameborder,"TOPRIGHT",2,0)
frameborder.right:SetColorTexture(0,0,0,1)
frameborder.top = frameborder:CreateTexture(nil,"BORDER")
frameborder.top:SetPoint("BOTTOMLEFT",frameborder,"TOPLEFT",-2,0)
frameborder.top:SetPoint("TOPRIGHT",frameborder,"TOPRIGHT",2,2)
frameborder.top:SetColorTexture(0,0,0,1)
frameborder.bottom = frameborder:CreateTexture(nil,"BORDER")
frameborder.bottom:SetPoint("BOTTOMLEFT",frameborder,"BOTTOMLEFT",-2,-2)
frameborder.bottom:SetPoint("TOPRIGHT",frameborder,"BOTTOMRIGHT",2,0)
frameborder.bottom:SetColorTexture(0,0,0,1)

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

DR.charge = CreateFrame("Frame")
DR.charge:RegisterEvent("UNIT_AURA")
DR.charge:RegisterEvent("SPELL_UPDATE_COOLDOWN")

function DR:chargeSetup(number)
	if UIWidgetPowerBarContainerFrame then
		DR.SetUpChargePos(number)
		if UIWidgetPowerBarContainerFrame.widgetFrames[5140] then -- gold tex
			DR.charge[number].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Empty.blp")
			DR.charge[number].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Cover.blp")
		elseif UIWidgetPowerBarContainerFrame.widgetFrames[5143] then -- silver tex
			DR.charge[number].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Silver_Empty.blp")
			DR.charge[number].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Silver_Cover.blp")
		elseif UIWidgetPowerBarContainerFrame.widgetFrames[5144] then -- bronze tex
			DR.charge[number].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Bronze_Empty.blp")
			DR.charge[number].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Bronze_Cover.blp")
		elseif UIWidgetPowerBarContainerFrame.widgetFrames[5145] then -- dark tex
			DR.charge[number].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Dark_Empty.blp")
			DR.charge[number].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Dark_Cover.blp")
		elseif C_UnitAuras.GetPlayerAuraBySpellID(418590) then -- default fallback, buff exists, not stormrider
			DR.charge[number].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Empty.blp")
			DR.charge[number].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Cover.blp")
		else
			DR.charge[number].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Empty.blp")
			DR.charge[number].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Cover.blp")
			DR.charge[number]:Hide();
		end
	end
end

function DR.SetUpChargePos(i)
	DR.charge[1]:SetPoint("CENTER", UIWidgetPowerBarContainerFrame, -61,15)
	if i ~= 1 then
		if C_UnitAuras.GetPlayerAuraBySpellID(417888) then
			DR.charge[i]:SetPoint("CENTER", DR.charge[i-1], 30.5, 0)
		else
			DR.charge[i]:SetPoint("CENTER", DR.charge[i-1], 26.75, 0)
		end
		DR.charge[i]:SetParent(DR.charge[i-1])
	end
	if DR.charge[6] then
		if C_UnitAuras.GetPlayerAuraBySpellID(417888) then
			DR.charge[6]:SetPoint("CENTER", DR.charge[1], 0, -30)
		else
			DR.charge[6]:SetPoint("CENTER", DR.charge[1], 0, -33)
		end
	end
end

for i = 1, 10 do
	DR.charge[i] = CreateFrame("Frame")
	DR.charge[i]:SetSize(25,25)

	DR.SetUpChargePos(i)

	DR.charge[i].texBase = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 0)
	DR.charge[i].texBase:SetAllPoints(DR.charge[i])
	DR.charge[i].texBase:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Empty.blp")
	DR.charge[i].texFill = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 1)
	DR.charge[i].texFill:SetAllPoints(DR.charge[i])
	DR.charge[i].texFill:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Fill.blp")
	DR.charge[i].texCover = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 2)
	DR.charge[i].texCover:SetAllPoints(DR.charge[i])
	DR.charge[i].texCover:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Gold_Cover.blp")

	DR.charge[i].texFill:Hide();

end


function DR.toggleCharges(self, event, arg1)
	if event == "UNIT_AURA" and arg1 == "player" then
		if C_UnitAuras.GetPlayerAuraBySpellID(418590) then
			local chargeCount = C_UnitAuras.GetPlayerAuraBySpellID(418590).applications
			for i = 1,10 do
				DR:chargeSetup(i)
				if i <= chargeCount then
					DR.charge[i].texFill:Show();
				else
					DR.charge[i].texFill:Hide();
				end
			end
			DR.setPositions();
		else
			for i = 1,10 do
				DR.charge[i].texFill:Hide();
			end
			DR.setPositions();
		end
	end
	if event == "SPELL_UPDATE_COOLDOWN" then
		local isEnabled, startTime, modRate, duration
		if C_Spell.GetSpellCooldown then
			isEnabled, startTime, modRate, duration = C_Spell.GetSpellCooldown(418592).isEnabled, C_Spell.GetSpellCooldown(418592).startTime, C_Spell.GetSpellCooldown(418592).modRate, C_Spell.GetSpellCooldown(418592).duration
		else
			isEnabled, startTime, modRate, duration = GetSpellCooldown(418592)
		end
		if ( startTime > 0 and duration > 0) then
			local cdLeft = startTime + duration - GetTime()
			for i = 1,10 do
				DR.charge[i].texFill:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Fill_CD.blp");
			end
		else
			for i = 1,10 do
				DR.charge[i].texFill:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Points_Fill.blp");
			end
		end
	end
end

DR.charge:SetScript("OnEvent", DR.toggleCharges)

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
		return "%" --.. L["UnitPercent"]
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

local DRAGON_RACE_AURA_ID = 369968;

function DR.updateSpeed()
	if not LibAdvFlight.IsAdvFlyEnabled() and not DriveUtils.IsDriving() then
		return;
	end

	local forwardSpeed = LibAdvFlight.GetForwardSpeed();
	if not LibAdvFlight.IsAdvFlyEnabled() then
		forwardSpeed = DriveUtils.GetSmoothedSpeed()
	end
	local racing = C_UnitAuras.GetPlayerAuraBySpellID(DRAGON_RACE_AURA_ID)

	local THRESHOLD_HIGH;
	local THRESHOLD_LOW;
	local MIN_BAR_VALUE;
	local MAX_BAR_VALUE;

	if DR.DragonRidingZoneCheck() == true or racing then
		THRESHOLD_HIGH = 65;
		THRESHOLD_LOW = 60;
		MIN_BAR_VALUE = 0;
		MAX_BAR_VALUE = 100;
	elseif DriveUtils.IsDriving() then
		THRESHOLD_HIGH = 100 * .55;
		THRESHOLD_LOW = 100 * .40;
		MIN_BAR_VALUE = 0;
		MAX_BAR_VALUE = 100;
	else
		THRESHOLD_HIGH = 85 * .65;
		THRESHOLD_LOW = 85 * .60;
		MIN_BAR_VALUE = 0;
		MAX_BAR_VALUE = 85;
	end

	DR.statusbar:SetMinMaxValues(MIN_BAR_VALUE, MAX_BAR_VALUE);
	local textColor;
	local barColor;

	if forwardSpeed > THRESHOLD_HIGH then
		textColor = DragonRider_DB.speedTextColor.over;
		barColor = DragonRider_DB.speedBarColor.over;
	elseif forwardSpeed >= THRESHOLD_LOW and forwardSpeed <= THRESHOLD_HIGH then
		textColor = DragonRider_DB.speedTextColor.vigor;
		barColor = DragonRider_DB.speedBarColor.vigor;
	else
		textColor = DragonRider_DB.speedTextColor.slow;
		barColor = DragonRider_DB.speedBarColor.slow;
	end

	textColor = CreateColor(textColor.r, textColor.g, textColor.b, textColor.a);
	local text = format("|c%s%.1f%s|r", textColor:GenerateHexColor(), DR:convertUnits(forwardSpeed), DR.useUnits());
	if DriveUtils.IsDriving() then
		text = format("|c%s%.0f%s|r", textColor:GenerateHexColor(), DR:convertUnits(forwardSpeed), DR.useUnits());
	end
	DR.glide:SetText(text);
	DR.statusbar:SetStatusBarColor(barColor.r, barColor.g, barColor.b, barColor.a);

	if DragonRider_DB.speedValUnits == 6 then
		DR.glide:SetText("")
	end
	DR.statusbar:SetSmoothedValue(forwardSpeed)
end

function DR.vigorCounter(vigorCurrent)
	if not vigorCurrent then
		-- vigorCurrent will be nil during login I think
		return;
	end

	if not LibAdvFlight.IsAdvFlyEnabled() or DriveUtils.IsDriving() then
		DR.toggleModels()
		return
	end

	if not DragonRider_DB.toggleModels then
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

LibAdvFlight.RegisterCallback(LibAdvFlight.Events.VIGOR_CHANGED, DR.vigorCounter);

DR.EventsList = CreateFrame("Frame")

DR.EventsList:RegisterEvent("ADDON_LOADED")
DR.EventsList:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
DR.EventsList:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
DR.EventsList:RegisterEvent("LEARNED_SPELL_IN_TAB")
DR.EventsList:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
DR.EventsList:RegisterEvent("COMPANION_UPDATE")
DR.EventsList:RegisterEvent("PLAYER_LOGIN")
DR.EventsList:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
DR.EventsList:RegisterEvent("UPDATE_UI_WIDGET")
DR.EventsList:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...);
	end
end);


function DR.GetWidgetAlpha()
	if UIWidgetPowerBarContainerFrame then
		return UIWidgetPowerBarContainerFrame:GetAlpha()
	end
end

function DR.GetVigorValueExact()
	if UnitPower("player", Enum.PowerType.AlternateMount) and C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460) then
		local fillCurrent = (UnitPower("player", Enum.PowerType.AlternateMount) + (C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460).fillValue*.01) )
		--local fillMin = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460).fillMax
		local fillMax = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460).numTotalFrames
		return fillCurrent, fillMax
	end
end

-- ugly hack fix for the vigor widget not disappearing when it should
LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_DISABLED, function()
	for _, v in ipairs(DR.WidgetFrameIDs) do
		C_Timer.After(1, function()
			local f = UIWidgetPowerBarContainerFrame.widgetFrames[v];
			if f and f:IsShown() then
				f:Hide();
			end
		end);
	end
end);

function DR.SetupVigorToolip()
	EmbeddedItemTooltip:HookScript("OnShow", function(self)
		if not DragonRider_DB.showtooltip then
			for _, v in pairs(DR.WidgetFrameIDs) do
				local f = UIWidgetPowerBarContainerFrame.widgetFrames[v];
				if f then
					if self:GetOwner() == f then
						self:Hide();
					end
				end
			end
		end
	end);
end

function DR.SetTheme()
	if DragonRider_DB.themeSpeed == 1 then --Default
		DR.statusbar:SetWidth(305/1.25)
		DR.statusbar:SetHeight(66.5/2.75)
		DR.statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
		DR.statusbar:GetStatusBarTexture():SetVertTile(false)
		DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")

		DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick2:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick1:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 5)
		DR.tick2:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), 5)
		if DriveUtils.IsDriving() then
			DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (40 / 100) * DR.statusbar:GetWidth(), 5)
			DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (55 / 100) * DR.statusbar:GetWidth(), 5)
		end

		DR.backdropL:SetAtlas("widgetstatusbar-borderleft")
		DR.backdropR:SetAtlas("widgetstatusbar-borderright")
		DR.backdropM:SetAtlas("widgetstatusbar-bordercenter")
		DR.backdropL:SetWidth(35)
		DR.backdropL:SetHeight(40)
		DR.backdropR:SetWidth(35)
		DR.backdropR:SetHeight(40)
		DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -7, 0)
		DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 7, 0)

		DR.backdropTopper:SetAtlas("dragonflight-score-topper")
		DR.backdropFooter:SetAtlas("dragonflight-score-footer")
		DR.backdropTopper:SetSize(350,65)
		DR.backdropFooter:SetSize(350,65)
		DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 38)
		DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -32)
		DR.backdropTopper:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)

		frameborder.left:SetColorTexture(0,0,0,0)
		frameborder.right:SetColorTexture(0,0,0,0)
		frameborder.top:SetColorTexture(0,0,0,0)
		frameborder.bottom:SetColorTexture(0,0,0,0)


	elseif DragonRider_DB.themeSpeed == 2 then --Algari
		DR.statusbar:SetWidth(305/1.25)
		DR.statusbar:SetHeight(66.5/2.75)

		--change for algarian stormrider colors
		if UIWidgetPowerBarContainerFrame then
			if UIWidgetPowerBarContainerFrame.widgetFrames then
				if UIWidgetPowerBarContainerFrame.widgetFrames[5140] then -- gold tex
					DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_G.blp")
					DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_G.blp")
					DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_G.blp")

					DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_G.blp")
					DR.backdropFooter:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_G.blp")

				elseif UIWidgetPowerBarContainerFrame.widgetFrames[5143] then -- silver tex
					DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_S.blp")
					DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_S.blp")
					DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_S.blp")

					DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_S.blp")
					DR.backdropFooter:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_S.blp")

				elseif UIWidgetPowerBarContainerFrame.widgetFrames[5144] then -- bronze tex
					DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_B.blp")
					DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_B.blp")
					DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_B.blp")

					DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_B.blp")
					DR.backdropFooter:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_B.blp")

				elseif UIWidgetPowerBarContainerFrame.widgetFrames[5145] then -- dark tex
					DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_D.blp")
					DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_D.blp")
					DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_D.blp")

					DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_D.blp")
					DR.backdropFooter:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_D.blp")

				else --default, should be gold tex
					DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_G.blp")
					DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_G.blp")
					DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_G.blp")

					DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_G.blp")
					DR.backdropFooter:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_G.blp")

				end
			end
		end

		DR.statusbar:SetStatusBarTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp")
		DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
		DR.statusbar:GetStatusBarTexture():SetVertTile(false)
		DR.statusbar.bg:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BG.blp")

		DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick2:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick1:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 5)
		DR.tick2:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), 5)
		if DriveUtils.IsDriving() then
			DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (40 / 100) * DR.statusbar:GetWidth(), 5)
			DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (55 / 100) * DR.statusbar:GetWidth(), 5)
		end

		DR.backdropL:SetWidth(70)
		DR.backdropL:SetHeight(75)
		DR.backdropR:SetWidth(70)
		DR.backdropR:SetHeight(75)
		DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -37, 0)
		DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 37, 0)

		DR.backdropTopper:SetSize(150,65)
		DR.backdropFooter:SetSize(115,50)
		DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 39)
		DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -28)
		DR.backdropTopper:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)

		frameborder.left:SetColorTexture(0,0,0,0)
		frameborder.right:SetColorTexture(0,0,0,0)
		frameborder.top:SetColorTexture(0,0,0,0)
		frameborder.bottom:SetColorTexture(0,0,0,0)


	elseif DragonRider_DB.themeSpeed == 3 then -- Minimalist
		DR.statusbar:SetWidth(305/1.25)
		DR.statusbar:SetHeight(66.5/2.75)
		DR.statusbar:SetStatusBarTexture("Interface\\buttons\\white8x8")
		DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
		DR.statusbar:GetStatusBarTexture():SetVertTile(false)
		DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")

		DR.tick1:SetTexture("Interface\\buttons\\white8x8")
		DR.tick2:SetTexture("Interface\\buttons\\white8x8")
		DR.tick1:SetSize(1,DR.statusbar:GetHeight())
		DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 0)
		DR.tick2:SetSize(1,DR.statusbar:GetHeight())
		DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), 0)
		if DriveUtils.IsDriving() then
			DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (40 / 100) * DR.statusbar:GetWidth(), 5)
			DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (55 / 100) * DR.statusbar:GetWidth(), 5)
		end
		DR.tick1:SetColorTexture(1, 1, 1, 1)
		DR.tick2:SetColorTexture(1, 1, 1, 1)

		DR.backdropL:SetAtlas(nil)
		DR.backdropR:SetAtlas(nil)
		DR.backdropM:SetAtlas(nil)
		DR.backdropL:SetWidth(35)
		DR.backdropL:SetHeight(40)
		DR.backdropR:SetWidth(35)
		DR.backdropR:SetHeight(40)
		DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -7, 0)
		DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 7, 0)

		DR.backdropTopper:SetAtlas(nil)
		DR.backdropFooter:SetAtlas(nil)
		DR.backdropTopper:SetSize(350,65)
		DR.backdropFooter:SetSize(350,65)
		DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 38)
		DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -32)
		DR.backdropTopper:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)

		frameborder.left:SetColorTexture(0,0,0,1)
		frameborder.right:SetColorTexture(0,0,0,1)
		frameborder.top:SetColorTexture(0,0,0,1)
		frameborder.bottom:SetColorTexture(0,0,0,1)

	elseif DragonRider_DB.themeSpeed == 4 then -- Alliance

		DR.statusbar:SetWidth(305/1.25)
		DR.statusbar:SetHeight(66.5/2.75)
		DR.statusbar:SetStatusBarTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_Progress.blp")
		DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
		DR.statusbar:GetStatusBarTexture():SetVertTile(false)
		DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")

		DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick2:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick1:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 5)
		DR.tick2:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), 5)
		if DriveUtils.IsDriving() then
			DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (40 / 100) * DR.statusbar:GetWidth(), 5)
			DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (55 / 100) * DR.statusbar:GetWidth(), 5)
		end

		DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_L.blp")
		DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_R.blp")
		DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_M.blp")
		DR.backdropL:SetWidth(70)
		DR.backdropL:SetHeight(75)
		DR.backdropR:SetWidth(70)
		DR.backdropR:SetHeight(75)
		DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -37, 0)
		DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 37, 0)

		DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_Topper.blp")
		DR.backdropFooter:SetTexture(nil)

		DR.backdropTopper:SetSize(350,65)
		DR.backdropFooter:SetSize(350,65)
		DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 39.5)
		DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -28)
		DR.backdropTopper:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)

		frameborder.left:SetColorTexture(0,0,0,0)
		frameborder.right:SetColorTexture(0,0,0,0)
		frameborder.top:SetColorTexture(0,0,0,0)
		frameborder.bottom:SetColorTexture(0,0,0,0)

	elseif DragonRider_DB.themeSpeed == 5 then -- Horde

		DR.statusbar:SetWidth(305/1.25)
		DR.statusbar:SetHeight(66.5/2.75)
		DR.statusbar:SetStatusBarTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_Progress.blp")
		DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
		DR.statusbar:GetStatusBarTexture():SetVertTile(false)
		DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")

		DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick2:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick1:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), 5)
		DR.tick2:SetSize(17,DR.statusbar:GetHeight()*1.5)
		DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), 5)
		if DriveUtils.IsDriving() then
			DR.tick1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (40 / 100) * DR.statusbar:GetWidth(), 5)
			DR.tick2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (55 / 100) * DR.statusbar:GetWidth(), 5)
		end

		DR.backdropL:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_L.blp")
		DR.backdropR:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_R.blp")
		DR.backdropM:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_M.blp")
		DR.backdropL:SetWidth(70)
		DR.backdropL:SetHeight(75)
		DR.backdropR:SetWidth(70)
		DR.backdropR:SetHeight(75)
		DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -37, 0)
		DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 37, 0)

		DR.backdropTopper:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_Topper.blp")
		DR.backdropFooter:SetTexture(nil)

		DR.backdropTopper:SetSize(350,65)
		DR.backdropFooter:SetSize(350,65)
		DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 39.5)
		DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -28)
		DR.backdropTopper:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)

		frameborder.left:SetColorTexture(0,0,0,0)
		frameborder.right:SetColorTexture(0,0,0,0)
		frameborder.top:SetColorTexture(0,0,0,0)
		frameborder.bottom:SetColorTexture(0,0,0,0)

	else -- Revert to default
		DR.statusbar:SetWidth(305/1.25)
		DR.statusbar:SetHeight(66.5/2.75)
		DR.statusbar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
		DR.statusbar:GetStatusBarTexture():SetVertTile(false)
		DR.statusbar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")

		DR.tick1:SetAtlas("UI-Frame-Bar-BorderTick")
		DR.tick2:SetAtlas("UI-Frame-Bar-BorderTick")

		DR.backdropL:SetAtlas("widgetstatusbar-borderleft")
		DR.backdropR:SetAtlas("widgetstatusbar-borderright")
		DR.backdropM:SetAtlas("widgetstatusbar-bordercenter")
		DR.backdropL:SetWidth(35)
		DR.backdropL:SetHeight(40)
		DR.backdropR:SetWidth(35)
		DR.backdropR:SetHeight(40)
		DR.backdropL:SetPoint("LEFT", DR.statusbar, "LEFT", -7, 0)
		DR.backdropR:SetPoint("RIGHT", DR.statusbar, "RIGHT", 7, 0)

		DR.backdropTopper:SetAtlas("dragonflight-score-topper")
		DR.backdropFooter:SetAtlas("dragonflight-score-footer")
		DR.backdropTopper:SetSize(350,65)
		DR.backdropFooter:SetSize(350,65)
		DR.backdropTopper:SetPoint("TOP", DR.statusbar, "TOP", 0, 38)
		DR.backdropFooter:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", 0, -32)
		DR.backdropTopper:SetDrawLayer("OVERLAY", 3)
		DR.backdropFooter:SetDrawLayer("OVERLAY", 3)

		frameborder.left:SetColorTexture(0,0,0,0)
		frameborder.right:SetColorTexture(0,0,0,0)
		frameborder.top:SetColorTexture(0,0,0,0)
		frameborder.bottom:SetColorTexture(0,0,0,0)
	end
end

local ParentFrame = CreateFrame("Frame", nil, UIParent)
ParentFrame:SetPoint("TOPLEFT", UIWidgetPowerBarContainerFrame, "TOPLEFT")
ParentFrame:SetPoint("BOTTOMRIGHT", UIWidgetPowerBarContainerFrame, "BOTTOMRIGHT")
-- this should solve that weird "moving" thing, the widget adjusts its size based on children


function DR.setPositions()
	DR.SetTheme()
	if DragonRider_DB.DynamicFOV == true then
		C_CVar.SetCVar("AdvFlyingDynamicFOVEnabled", 1)
	elseif DragonRider_DB.DynamicFOV == false then
		C_CVar.SetCVar("AdvFlyingDynamicFOVEnabled", 0)
	end

	ParentFrame:ClearAllPoints()
	ParentFrame:SetScale(UIWidgetPowerBarContainerFrame:GetScale()) -- because some of you are rescaling this thing...... the "moving vigor bar" was your fault.
	ParentFrame:SetPoint("TOPLEFT", UIWidgetPowerBarContainerFrame, "TOPLEFT")
	ParentFrame:SetPoint("BOTTOMRIGHT", UIWidgetPowerBarContainerFrame, "BOTTOMRIGHT")
	for k, v in pairs(DR.WidgetFrameIDs) do
		if UIWidgetPowerBarContainerFrame.widgetFrames[v] then
			ParentFrame:ClearAllPoints()
			ParentFrame:SetPoint("TOPLEFT", UIWidgetPowerBarContainerFrame.widgetFrames[v], "TOPLEFT")
			ParentFrame:SetPoint("BOTTOMRIGHT", UIWidgetPowerBarContainerFrame.widgetFrames[v], "BOTTOMRIGHT")
		end
	end
	DR.statusbar:ClearAllPoints();
	DR.statusbar:SetPoint("BOTTOM", ParentFrame, "TOP", 0, 5);
	if DragonRider_DB.speedometerPosPoint == 1 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("BOTTOM", ParentFrame, "TOP", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	elseif DragonRider_DB.speedometerPosPoint == 2 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("TOP", ParentFrame, "BOTTOM", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	elseif DragonRider_DB.speedometerPosPoint == 3 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("RIGHT", ParentFrame, "LEFT", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	elseif DragonRider_DB.speedometerPosPoint == 4 then
		DR.statusbar:ClearAllPoints();
		DR.statusbar:SetPoint("LEFT", ParentFrame, "RIGHT", DragonRider_DB.speedometerPosX, DragonRider_DB.speedometerPosY);
	end

	if C_UnitAuras.GetPlayerAuraBySpellID(417888) then
		DR.charge[1]:SetPoint("TOPLEFT", ParentFrame, "TOPLEFT", 45,8)
	else
		DR.charge[1]:SetPoint("TOPLEFT", ParentFrame, "TOPLEFT", 31,14)
	end
	DR.charge[1]:SetParent(ParentFrame)
	DR.charge[1]:SetScale(1.5625)

	for i = 1, 10 do
		if C_UnitAuras.GetPlayerAuraBySpellID(418590) and DragonRider_DB.lightningRush == true then
			DR.charge[i]:Show();
			DR:chargeSetup(i)
		else
			DR.charge[i]:Hide();
		end
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
		DR.modelScene[i]:SetParent(ParentFrame)
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
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -175+(i*spacing), 14);
			end
		elseif IsPlayerSpell(377921) == true then -- 5 vigor
			for i = 1,5 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -150+(i*spacing), 14);
			end
			for i = 6,6,-1 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:Hide()
			end
		elseif IsPlayerSpell(377920) == true then -- 4 vigor
			for i = 1,4 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -125+(i*spacing), 14);
			end
			for i = 6,5,-1 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:Hide()
			end
		else
			for i = 1,3 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -100+(i*spacing), 14);
			end
			for i = 6,4,-1 do
				DR.modelScene[i]:SetParent(ParentFrame)
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
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -147+(i*spacing), 14);
			end
		elseif IsPlayerSpell(377921) == true then -- 5 vigor
			for i = 1,5 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -126+(i*spacing), 14);
			end
			for i = 6,6,-1 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:Hide()
			end
		elseif IsPlayerSpell(377920) == true then -- 4 vigor
			for i = 1,4 do 
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -105+(i*spacing), 14);
			end
			for i = 6,5,-1 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:Hide()
			end
		else
			for i = 1,3 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:SetPoint("CENTER", ParentFrame, "CENTER", -84+(i*spacing), 14);
			end
			for i = 6,4,-1 do
				DR.modelScene[i]:SetParent(ParentFrame)
				DR.modelScene[i]:Hide()
			end
		end
	end

	DR.glide:SetFont(STANDARD_TEXT_FONT, DragonRider_DB.speedTextScale)
end


function DR.GetBarAlpha()
	return DR.statusbar:GetAlpha()
end

DR.fadeInBarGroup = DR.statusbar:CreateAnimationGroup()
DR.fadeOutBarGroup = DR.statusbar:CreateAnimationGroup()

-- Create a fade in animation
DR.fadeInBar = DR.fadeInBarGroup:CreateAnimation("Alpha")
DR.fadeInBar:SetFromAlpha(DR.GetBarAlpha())
DR.fadeInBar:SetToAlpha(1)
DR.fadeInBar:SetDuration(.5) -- Duration of the fade in animation

-- Create a fade out animation
DR.fadeOutBar = DR.fadeOutBarGroup:CreateAnimation("Alpha")
DR.fadeOutBar:SetFromAlpha(DR.GetBarAlpha())
DR.fadeOutBar:SetToAlpha(0)
DR.fadeOutBar:SetDuration(.1) -- Duration of the fade out animation

-- Set scripts for when animations start and finish
DR.fadeOutBarGroup:SetScript("OnFinished", function()
	if LibAdvFlight.IsAdvFlying() or DriveUtils.IsDriving() then
		return
	end
	DR.statusbar:ClearAllPoints();
	DR.statusbar:Hide(); -- Hide the frame when the fade out animation is finished
end)
DR.fadeInBarGroup:SetScript("OnPlay", function()
	DR.setPositions();
	DR.statusbar:Show(); -- Show the frame when the fade in animation starts
end)

-- Function to show the frame with a fade in animation
function DR.ShowWithFadeBar()
	DR.fadeInBarGroup:Stop(); -- Stop any ongoing animations
	DR.fadeInBarGroup:Play(); -- Play the fade in animation
end

-- Function to hide the frame with a fade out animation
function DR.HideWithFadeBar()
	DR.fadeOutBarGroup:Stop(); -- Stop any ongoing animations
	DR.fadeOutBarGroup:Play(); -- Play the fade out animation
end

function DR.clearPositions()
	DR.HideWithFadeBar();
	for i = 1, 10 do
		DR.charge[i]:Hide();
	end
	DR.toggleModels()
end

DR.clearPositions();


local function Print(...)
	local prefix = string.format("|cFFFFF569"..L["DragonRider"] .. "|r:");
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

DR.commands = {
	[L["COMMAND_journal"]] = function()
		DR.mainFrame:Show();
	end,

	--[[
	["test"] = function()
		Print("Test.");
	end,

	["hello"] = function(subCommand)
		if not subCommand or subCommand == "" then
			Print("No Command");
		elseif subCommand == "world" then
			Print("Specified Command");
		else
			Print("Invalid Sub-Command");
		end
	end,
	]]

	[L["COMMAND_help"]] = function() --because there's not a lot of commands, don't use this yet.
		local concatenatedString
		for k, v in pairs(DR.commands) do
			if concatenatedString == nil then
				concatenatedString = "|cFF00D1FF"..k.."|r"
			else
				concatenatedString = concatenatedString .. ", ".. "|cFF00D1FF"..k.."|r"
			end
			
		end
		Print(L["COMMAND_listcommands"] .. " " .. concatenatedString)
	end
};

local function HandleSlashCommands(str)
	if (#str == 0) then
		DR.commands[L["COMMAND_journal"]]();
		return;
		end

		local args = {};
		for _dummy, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
			end
			end

			local path = DR.commands; -- required for updating found table.

			for id, arg in ipairs(args) do

			if (#arg > 0) then --if string length is greater than 0
			arg = arg:lower();          
			if (path[arg]) then
				if (type(path[arg]) == "function") then
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;                 
				elseif (type(path[arg]) == "table") then
					path = path[arg]; -- another sub-table found!
				end
				else
					DR.commands[L["COMMAND_journal"]]();
				return;
			end
		end
	end
end

local goldTime
local silverTime
local currentRace

function DR.MuteVigorSound()
	if DragonRider_DB.muteVigorSound == true then
		MuteSoundFile(1489541)
	else
		UnmuteSoundFile(1489541)
	end
end

-- event handling

function DR.EventsList:CURRENCY_DISPLAY_UPDATE(currencyID)
	if currencyID == 2019 then
		silverTime = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity;
	end
	if currencyID == 2020 then
		goldTime = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity;
	end
	for k, v in pairs(DR.DragonRaceCurrencies) do
		if currencyID == v then
			currentRace = currencyID
			if DragonRider_DB.raceDataCollector == nil then
				DragonRider_DB.raceDataCollector = {};
			end
			for a, b in pairs(DR.RaceData) do
				for c, d in pairs(b) do
					if d["currencyID"] == currentRace then
						if d["goldTime"] == nil or d["silverTime"] == nil then
							if DragonRider_DB.raceDataCollector[currentRace] == nil then
								DragonRider_DB.raceDataCollector[currentRace] = {currencyID = currentRace,goldTime=goldTime, silverTime=silverTime};
								if DragonRider_DB.debug == true then
									Print("Saving Temp Race Data")
								end
							end
						end
					end
				end
			end
			DR.mainFrame.UpdatePopulation()
			if DragonRider_DB.debug == true then
				Print(currencyID .. ": " .. C_CurrencyInfo.GetCurrencyInfo(currencyID).name)
				Print(C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity/1000)
				Print(currentRace .. ": " .. "gold: " .. goldTime .. ", silver: " .. silverTime);
			end
		end
	end
end

function DR.EventsList:PLAYER_LOGIN()
	DR.mainFrame.DoPopulationStuff();
end

function DR.OnAddonLoaded()
	--[[ -- hiding code test
	if event == "UPDATE_UI_WIDGET" then
		if UIWidgetPowerBarContainerFrame and UIWidgetPowerBarContainerFrame.widgetFrames[4460] then
			if (UIWidgetPowerBarContainerFrame.widgetFrames[4460]:IsShown()) then
				UIWidgetPowerBarContainerFrame.widgetFrames[4460]:Hide()
			end
		end
	end
	]]

	do
		local realmKey = GetRealmName()
		local charKey = UnitName("player") .. " - " .. realmKey

		SLASH_DRAGONRIDER1 = "/"..L["COMMAND_dragonrider"]
		SlashCmdList.DRAGONRIDER = HandleSlashCommands;

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
		if DragonRider_DB.showtooltip == nil then
			DragonRider_DB.showtooltip = true
		end
		if DragonRider_DB.fadeVigor == nil then
			DragonRider_DB.fadeVigor = false
		end
		if DragonRider_DB.fadeSpeed == nil then
			DragonRider_DB.fadeSpeed = true
		end
		if DragonRider_DB.lightningRush == nil then
			DragonRider_DB.lightningRush = true
		end
		if DragonRider_DB.DynamicFOV == nil then
			if C_CVar.GetCVar("AdvFlyingDynamicFOVEnabled") == "1" then
				DragonRider_DB.DynamicFOV = true
			elseif C_CVar.GetCVar("AdvFlyingDynamicFOVEnabled") == "0" then
				DragonRider_DB.DynamicFOV = false
			end
		end
		if DragonRider_DB.mainFrameSize == nil then
			DragonRider_DB.mainFrameSize = {
				width = 550,
				height = 525,
			};
		end
		if DragonRider_DB.mainFrameSize ~= nil then
			DR.mainFrame:SetSize(DragonRider_DB.mainFrameSize.width, DragonRider_DB.mainFrameSize.height);
		end
		if DragonRider_DB.useAccountData == nil then
			DragonRider_DB.useAccountData = false;
		else
			DR.mainFrame.accountAll_Checkbox:SetChecked(DragonRider_DB.useAccountData)
		end
		if DragonRider_DB.raceData == nil then
			DragonRider_DB.raceData = {};
			DragonRider_DB.raceData[charKey] = {};
		end
		if DragonRider_DB.muteVigorSound == nil then
			DragonRider_DB.muteVigorSound = false
		end
		DR.MuteVigorSound()
		if DragonRider_DB.themeSpeed == nil then
			DragonRider_DB.themeSpeed = 1
		end

		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------

		local version, bild = GetBuildInfo(); -- temp fix for beta
		--local IS_FUTURE = (version == "11.0.2") and tonumber(bild) > 55763;

		local function OnSettingChanged(_, setting, value)
			local variable = setting:GetVariable()

			if strsub(variable, 1, 3) == "DR_" then
				variable = strsub(variable, 4); -- remove our prefix so it matches existing savedvar keys
			end

			DR.vigorCounter()
			DR.setPositions()
			DR.MuteVigorSound()
		end

		local category, layout = Settings.RegisterVerticalLayoutCategory(L["DragonRider"]) -- 選單名稱
		--local subcategory, layout2 = Settings.RegisterVerticalLayoutSubcategory(category, "my very own subcategory")

		--layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(string.format(L["Version"], GetAddOnMetadata("DragonRider", "Version"))));

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["ProgressBar"]));

		local CreateDropdown = Settings.CreateDropdown or Settings.CreateDropDown
		local CreateCheckbox = Settings.CreateCheckbox or Settings.CreateCheckBox

		local function RegisterSetting(variableKey, defaultValue, name)
			local uniqueVariable = "DR_" .. variableKey; -- these have to be unique or calamity ensues, savedvars will be unaffected

			local setting;
			setting = Settings.RegisterAddOnSetting(category, uniqueVariable, variableKey, DragonRider_DB, type(defaultValue), name, defaultValue);

			setting:SetValue(DragonRider_DB[variableKey]);
			Settings.SetOnValueChangedCallback(uniqueVariable, OnSettingChanged);

			return setting;
		end

		do
			local variable = "themeSpeed"
			local defaultValue = 1  -- Corresponds to "Option 1" below.
			local name = L["SpeedometerTheme"]
			local tooltip = L["SpeedometerThemeTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add(1, L["Default"])
				container:Add(2, L["Algari"])
				container:Add(3, L["Minimalist"])
				container:Add(4, L["Alliance"])
				container:Add(5, L["Horde"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(category, setting, GetOptions, tooltip)
		end

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

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(category, setting, GetOptions, tooltip);
		end

		do
			local variable = "speedometerPosX"
			local name = L["SpeedPosXName"]
			local tooltip = L["SpeedPosXTT"]
			local defaultValue = 0
			local minValue = -Round(GetScreenWidth())
			local maxValue = Round(GetScreenWidth())
			local step = 1

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip);
		end

		do
			local variable = "speedometerPosY"
			local name = L["SpeedPosYName"]
			local tooltip = L["SpeedPosYTT"]
			local defaultValue = 5
			local minValue = -Round(GetScreenHeight())
			local maxValue = Round(GetScreenHeight())
			local step = 1

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
		end

		do
			local variable = "speedometerScale"
			local name = L["SpeedScaleName"]
			local tooltip = L["SpeedScaleTT"]
			local defaultValue = 1
			local minValue = .4
			local maxValue = 4
			local step = .1

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
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

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(category, setting, GetOptions, tooltip)
		end

		do
			local variable = "speedTextScale"
			local name = L["SpeedTextScale"]
			local tooltip = L["SpeedTextScaleTT"]
			local defaultValue = 12
			local minValue = 2
			local maxValue = 30
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
		end

		do
			local variable = "fadeSpeed"
			local name = L["FadeSpeedometer"]
			local tooltip = L["FadeSpeedometerTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Vigor"]));

		do
			local variable = "toggleModels"
			local name = L["ToggleModelsName"]
			local tooltip = L["ToggleModelsTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		do
			local variable = "sideArt"
			local name = L["SideArtName"]
			local tooltip = L["SideArtTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		do
			local variable = "showtooltip"
			local name = L["ShowVigorTooltip"]
			local tooltip = L["ShowVigorTooltipTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		do
			local variable = "muteVigorSound"
			local name = L["MuteVigorSound_Settings"]
			local tooltip = L["MuteVigorSound_SettingsTT"]
			local defaultValue = false

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SPECIAL));

		do
			local variable = "lightningRush"
			local name = L["LightningRush"]
			local tooltip = L["LightningRushTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		do
			local variable = "DynamicFOV"
			local name = L["DynamicFOV"]
			local tooltip = L["DynamicFOVTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
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
				DR:ShowColorPicker(DragonRider_DB.speedBarColor.slow);
			end

			local initializer = CreateSettingsButtonInitializer(L["ProgressBarColor"] .. " - " .. L["Low"], COLOR_PICKER, OnButtonClick, L["ColorPickerLowProgTT"], true);
			layout:AddInitializer(initializer);
		end

		do -- color picker - mid progress bar color
			local function OnButtonClick()
				DR:ShowColorPicker(DragonRider_DB.speedBarColor.vigor);
			end

			local initializer = CreateSettingsButtonInitializer(L["ProgressBarColor"] .. " - " .. L["Vigor"], COLOR_PICKER, OnButtonClick, L["ColorPickerMidProgTT"], true);
			layout:AddInitializer(initializer);
		end

		do -- color picker - high progress bar color
			local function OnButtonClick()
				DR:ShowColorPicker(DragonRider_DB.speedBarColor.over);
			end

			local initializer = CreateSettingsButtonInitializer(L["ProgressBarColor"] .. " - " .. L["High"], COLOR_PICKER, OnButtonClick, L["ColorPickerHighProgTT"], true);
			layout:AddInitializer(initializer);
		end

		do -- color picker - low speed text color
			local function OnButtonClick()
				DR:ShowColorPicker(DragonRider_DB.speedTextColor.slow);
			end

			local initializer = CreateSettingsButtonInitializer(L["UnitsColor"] .. " - " .. L["Low"], COLOR_PICKER, OnButtonClick, L["ColorPickerLowTextTT"], true);
			layout:AddInitializer(initializer);
		end

		do -- color picker - mid speed text color
			local function OnButtonClick()
				DR:ShowColorPicker(DragonRider_DB.speedTextColor.vigor);
			end

			local initializer = CreateSettingsButtonInitializer(L["UnitsColor"] .. " - " .. L["Vigor"], COLOR_PICKER, OnButtonClick, L["ColorPickerMidTextTT"], true);
			layout:AddInitializer(initializer);
		end

		do -- color picker - high speed text color
			local function OnButtonClick()
				DR:ShowColorPicker(DragonRider_DB.speedTextColor.over);
			end

			local initializer = CreateSettingsButtonInitializer(L["UnitsColor"] .. " - " .. L["High"], COLOR_PICKER, OnButtonClick, L["ColorPickerHighTextTT"], true);
			layout:AddInitializer(initializer);
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RESET));

		StaticPopupDialogs["DRAGONRIDER_RESET_SETTINGS"] = {
			text = L["ResetAllSettingsConfirm"],
			button1 = YES,
			button2 = NO,
			OnAccept = function()
				DragonRider_DB = CopyTable(defaultsTable);
				DR.vigorCounter();
				DR.setPositions();
				DR.MuteVigorSound();
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
		category.ID = "DragonRider" -- 自行加入
		Settings.RegisterAddOnCategory(category)

		function DragonRider_OnAddonCompartmentClick(addonName, buttonName, menuButtonFrame)
			if buttonName == "RightButton" then
				Settings.OpenToCategory(category.ID);
			else
				DR.mainFrame:Show();
			end
		end

		function DragonRider_OnAddonCompartmentEnter(addonName, menuButtonFrame)
			local tooltipData = {
				[1] = L["DragonRider"],
				[2] = L["RightClick_TT_Line"],
				[3] = L["LeftClick_TT_Line"],
				[4] = L["SlashCommands_TT_Line"]
			}
			local concatenatedString
			for k, v in ipairs(tooltipData) do
				if concatenatedString == nil then
					concatenatedString = v
				else
					concatenatedString = concatenatedString .. "\n".. v
				end
			end
			DR.tooltip_OnEnter(menuButtonFrame, concatenatedString);
		end

		function DragonRider_OnAddonCompartmentLeave(addonName, menuButtonFrame)
			DR.tooltip_OnLeave();
		end

		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------

		-- when the player takes off and starts flying
		local function OnAdvFlyStart()
			if DragonRider_DB.fadeSpeed then
				DR.ShowWithFadeBar();
			else
				DR.statusbar:SetAlpha(1)
				DR.statusbar:Show()
			end
			DR.setPositions();
		end

		-- when the player mounts but isn't flying yet
		-- OR when the player lands after flying but is still mounted
		local function OnAdvFlyEnabled()
			if DragonRider_DB.fadeSpeed then
				DR.HideWithFadeBar();
			else
				DR.statusbar:SetAlpha(1)
				DR.statusbar:Show()
			end
			DR.setPositions();
		end

		local function OnAdvFlyEnd()
			if DragonRider_DB.fadeSpeed then
				DR.HideWithFadeBar();
			end
			DR.setPositions();
			C_Timer.After(.5, function() DR.statusbar:Hide() end)
		end

		-- when the player dismounts
		local function OnAdvFlyDisabled()
			if DragonRider_DB.fadeSpeed then
				DR.HideWithFadeBar();
			else
				DR.statusbar:SetAlpha(1)
			end
			DR.clearPositions();
			C_Timer.After(.5, function() DR.statusbar:Hide() end)
		end

		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_START, OnAdvFlyStart);
		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_END, OnAdvFlyEnd);
		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_ENABLED, OnAdvFlyEnabled);
		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_DISABLED, OnAdvFlyDisabled);

		local function OnDriveStart()
			if DriveUtils.IsDriving() then
				OnAdvFlyStart();
			end
		end

		local function OnDriveEnd()
			if not DriveUtils.IsDriving() then
				OnAdvFlyEnd();
			end
		end

		local f = CreateFrame("Frame");
		f:SetScript("OnEvent", function(self, event, ...)
			if event == "PLAYER_GAINS_VEHICLE_DATA" then
				OnDriveStart();
			elseif event == "PLAYER_LOSES_VEHICLE_DATA" then
				OnDriveEnd();
			end
		end);
		f:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA");
		f:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA");

		-- this will run every frame, forever :)
		-- put anything that needs to run every frame in here
		local function OnUpdate()
			DR.updateSpeed();
		end

		C_Timer.NewTicker(0.1, OnUpdate);

		DR.SetupVigorToolip();
	end
end

EventUtil.ContinueOnAddOnLoaded("DragonRider", DR.OnAddonLoaded);