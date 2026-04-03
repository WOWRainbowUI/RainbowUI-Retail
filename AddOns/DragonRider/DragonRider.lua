local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

--A purposeful global variable for other addons
DragonRider_API = DR

---@type LibAdvFlight
local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.1");

-- reverse-lookup map to find race data from a currency ID quickly.
DR.CurrencyToRaceMap = {}

local defaultsTable = {
	toggleModels = true,
	speedometerPosPoint = 1, -- deprecated
	speedometerPosX = 0, -- deprecated, moved to position
	speedometerPosY = 5, -- deprecated, moved to position
	position = {
		speedometer = {
			point = "CENTER",
			relativePoint = "CENTER",
			xOfs = 0,
			yOfs = -140,
		},
		vigor = {
			point = "CENTER",
			relativePoint = "CENTER",
			xOfs = 0,
			yOfs = -200,
		},
	},
	speedometerWidth = 244,
	speedometerHeight = 24,
	speedometerScale = 1,
	speedValUnits = "Yards",
	speedBarTexture = "Default",
	speedBarColor = {
		slow = {
			r = 0.77,
			g = 0.38,
			b = 0.00,
			a = 1.00,
		},
		vigor = {
			r = 0,
			g = 0.56,
			b = 0.61,
			a = 1.00,
		},
		over = {
			r = 0.66,
			g = 0.30,
			b = 0.76,
			a = 1.00,
		},
		cover = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		tick = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		topper = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		footer = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		background = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 0.80,
		},
		spark = {
			r=1.00,
			g=1.00,
			b=1.00,
			a=0.90,
		},
	},
	speedTextColor = {
		slow = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		vigor = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		over = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
	},
	speedTextScale = 12,
	speedTextFont = "FrizQuadrata",
	speedTextJustify = "LEFT", -- "LEFT", "CENTER", or "RIGHT"
	speedTextFlagOutline = false,
	speedTextFlagThickOutline = false,
	speedTextFlagMonochrome = false,
	speedTextFlagSlug = false,
	speedTextDecimals = 1,
	glyphDetector = true, -- unused
	vigorProgressStyle = "Vertical", -- "Vertical", "Horizontal", or "Cooldown"
	cooldownTimer = { -- unused
		whirlingSurge = true,
		bronzeTimelock = true,
		aerialHalt = true,
	},
	barStyle = 1, -- this is now deprecated
	statistics = {},
	multiplayer = true,
	sideArt = true,
	sideArtStyle = "Default",
	sideArtPosX = -15,
	sideArtPosY = -10,
	sideArtRot = 0,
	sideArtSize = 1,
	tempFixes = {
		hideVigor = true, -- this is now deprecated
	},
	showtooltip = true,  -- this is now deprecated
	fadeVigor = false, -- NO LONGER DEPRECATED BABY YEAAAAAAAAH
	fadeSpeed = true,  -- this is now deprecated
	lightningRush = true,
	staticChargeOffset = -10,
	staticChargeSpacing = 5.5,
	staticChargeWidth = 36,
	staticChargeHeight = 36,
	muteVigorSound = false,
	themeSpeed = "Default", -- default
	themeVigor = "Default", -- default
	vigorPosX = 0, -- deprecated, moved to position
	vigorPosY = -200, -- deprecated, moved to position
	vigorBarWidth = 32,
	vigorBarHeight = 32,
	vigorBarSpacing = 10,
	vigorBarOrientation = "Horizontal",	-- "Vertical" or "Horizontal"
	vigorBarDirection = "DownRight",	-- "DownRight" or "UpLeft"
	vigorWrap = 6,					-- How many bubbles before wrapping to a new row/column
	vigorBarFillDirection = "Vertical",	-- "Vertical" or "Horizontal"
	vigorSparkThickness = 12,
	toggleFlashFull = true,
	toggleFlashProgress = true,
	modelTheme = "Wind",
	toggleSpeedometer = true,
	toggleVigor = true,
	toggleTopper = true,
	toggleFooter = true,
	vigorBarColor = {
		full = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		empty = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 0.00,
		},
		background = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		progress = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		spark = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 0.90,
		},
		cover = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		flash = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
		decor = {
			r = 1.00,
			g = 1.00,
			b = 1.00,
			a = 1.00,
		},
	},
};

DR.defaultsTable = defaultsTable

function DR.MergeDefaults(saved, defaults)
	for key, defaultValue in pairs(defaults) do
		local savedValue = saved[key]

		if savedValue == nil then
			if type(defaultValue) == "table" then
				saved[key] = CopyTable(defaultValue) 
			else
				saved[key] = defaultValue
			end
		elseif type(savedValue) == "table" and type(defaultValue) == "table" then
			DR.MergeDefaults(savedValue, defaultValue)
		end
	end
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

DR.EditFrames = {}
DR.IsEditMode = false

local function SaveFramePosition(frameName)
	if not DragonRider_DB then DragonRider_DB = {} end
	if not DragonRider_DB.position then DragonRider_DB.position = {} end
	
	if frameName == "Speedometer" then
		local point, relativeTo, relativePoint, xOfs, yOfs = DR.statusbar:GetPoint()
		DragonRider_DB.position.speedometer = {
			point = point,
			relativePoint = relativePoint,
			xOfs = xOfs,
			yOfs = yOfs
		}
	elseif frameName == "Vigor" then
		local point, relativeTo, relativePoint, xOfs, yOfs = DR.vigorBar:GetPoint()
		DragonRider_DB.position.vigor = {
			point = point,
			relativePoint = relativePoint,
			xOfs = xOfs,
			yOfs = yOfs
		}
	end
end

local function LoadFramePosition(frameName)
	if not DragonRider_DB or not DragonRider_DB.position then return end
	
	if frameName == "Speedometer" and DragonRider_DB.position.speedometer then
		local pos = DragonRider_DB.position.speedometer
		DR.statusbar:ClearAllPoints()
		DR.statusbar:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
	elseif frameName == "Vigor" and DragonRider_DB.position.vigor then
		local pos = DragonRider_DB.position.vigor
		DR.vigorBar:ClearAllPoints()
		DR.vigorBar:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
	end
end

local function CreateEditOverlay(targetFrame, frameName)
	if not targetFrame then return end
	
	local editFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	editFrame:SetFrameStrata("DIALOG")
	editFrame:SetFrameLevel(600)
	local edgeOffSet = 20
	editFrame:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", -edgeOffSet, edgeOffSet)
	editFrame:SetPoint("BOTTOMRIGHT", targetFrame, "BOTTOMRIGHT", edgeOffSet, -edgeOffSet)
	editFrame:Hide()
	
	local backdropInfo = {
		bgFile = "interface\\editmode\\editmodeuihighlightbackground",
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 2,
		insets = { left = 1, right = 1, top = 1, bottom = 1, },
	}
	editFrame:SetBackdrop(backdropInfo)
	editFrame:SetBackdropColor(1, 1, 1, 1)
	editFrame:SetBackdropBorderColor(0.227, 0.773, 1.00, 1)

	editFrame.Label = editFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	editFrame.Label:SetPoint("CENTER", 0, 0)
	editFrame.Label:SetText(frameName)
	editFrame.Label:SetFontHeight(17.5)

	editFrame:EnableMouse(true)
	editFrame:SetMovable(true)
	editFrame:SetClampedToScreen(true)
	editFrame:RegisterForDrag("LeftButton")
	
	editFrame:SetScript("OnDragStart", function(self)
		targetFrame:StartMoving()
	end)
	
	editFrame:SetScript("OnDragStop", function(self)
		targetFrame:StopMovingOrSizing()
		SaveFramePosition(frameName)
	end)

	local function CreateNudgeButton(ANCHORPOINT, RELATIVETO, ANCHORRELATIVE, xOffset, yOffset, rotation, dirX, dirY)
		local btn = CreateFrame("Button", nil, editFrame)
		btn:SetSize(24, 33)
		btn:SetPoint(ANCHORPOINT, RELATIVETO, ANCHORRELATIVE, xOffset, yOffset) 
		
		btn:SetNormalAtlas("shop-header-arrow")
		btn:GetNormalTexture():SetRotation(rotation)
		btn:SetHighlightAtlas("shop-header-arrow-hover")
		btn:GetHighlightTexture():SetRotation(rotation)
		btn:SetPushedAtlas("shop-header-arrow-pressed")
		btn:GetPushedTexture():SetRotation(rotation)
		
		btn:SetScript("OnClick", function()
			local point, relativeTo, relativePoint, xOfs, yOfs = targetFrame:GetPoint()
			if not xOfs then xOfs = 0 end
			if not yOfs then yOfs = 0 end
			
			targetFrame:ClearAllPoints()
			targetFrame:SetPoint(point, UIParent, relativePoint, xOfs + dirX, yOfs + dirY)
			SaveFramePosition(frameName)
		end)
	end

	local Dropdown = CreateFrame("DropdownButton", nil, editFrame, "WowStyle1DropdownTemplate")
	Dropdown:SetDefaultText(Settings.GetCategory(DR.SettingsCategoryID).name or "DragonRider")
	if frameName == "Speedometer" then
		Dropdown:SetPoint("BOTTOM", editFrame, "TOP", 0, -2)
		CreateNudgeButton("BOTTOM",	Dropdown,	"TOP",		0,		0,		-math.pi / 2,		0,		1)	-- UP 90 - math.pi / 2
		CreateNudgeButton("TOP",	editFrame,	"BOTTOM",	0,		0,		math.pi / 2,		0,		-1)	-- DOWN -90 - -math.pi / 2
	elseif frameName == "Vigor" then
		Dropdown:SetPoint("TOP", editFrame, "BOTTOM", 0, -2)
		CreateNudgeButton("BOTTOM",	editFrame,	"TOP",		0,		0,		-math.pi / 2,		0,		1)	-- UP 90 - math.pi / 2
		CreateNudgeButton("TOP",	Dropdown,	"BOTTOM",	0,		0,		math.pi / 2,		0,		-1)	-- DOWN -90 - -math.pi / 2
	end
	Dropdown:SetSize(150, 30)
	
	CreateNudgeButton("RIGHT",	editFrame,	"LEFT",		0,		0,		0,					-1,		0)	-- LEFT  0 - 0
	CreateNudgeButton("LEFT",	editFrame,	"RIGHT",	0,		0,		math.pi,			1,		0)	-- RIGHT 180 - math.pi
	
	Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateButton(L["LockFrame"], function()
			DR.ToggleEditMode(false)
			if not UnitAffectingCombat("player") then
				Settings.OpenToCategory(DR.SettingsCategoryID);
			end
		end)
		
		rootDescription:CreateButton(RESET_TO_DEFAULT, function()
			if frameName == "Speedometer" then
				if DragonRider_DB.position and DragonRider_DB.position.speedometer then
					DragonRider_DB.position.speedometer = CopyTable(defaultsTable.position.speedometer)
				end
			elseif frameName == "Vigor" then
				if DragonRider_DB.position and DragonRider_DB.position.vigor then
					DragonRider_DB.position.vigor = CopyTable(defaultsTable.position.vigor)
				end
			end
			DR.setPositions()
		end)
	end)

	DR.EditFrames[frameName] = editFrame
end

function DR.ToggleEditMode(enable)
	DR.IsEditMode = enable 

	if not DR.EditFrames["Speedometer"] and DR.statusbar then
		CreateEditOverlay(DR.statusbar, "Speedometer")
	end
	if not DR.EditFrames["Vigor"] and DR.vigorBar then
		CreateEditOverlay(DR.vigorBar, "Vigor")
	end

	if enable then
		DR.statusbar:Show();
		DR.statusbar:SetAlpha(1);
		DR.vigorBar:Show();
		DR.vigorBar:SetAlpha(1);
		
		if DR.EditFrames["Speedometer"] then DR.EditFrames["Speedometer"]:Show(); end
		if DR.EditFrames["Vigor"] then DR.EditFrames["Vigor"]:Show(); end
		
		DR.statusbar:SetMovable(true);
		DR.vigorBar:SetMovable(true);
	else
		if DR.EditFrames["Speedometer"] then DR.EditFrames["Speedometer"]:Hide(); end
		if DR.EditFrames["Vigor"] then DR.EditFrames["Vigor"]:Hide(); end
		
		DR.statusbar:SetMovable(false);
		DR.vigorBar:SetMovable(false);
		DR.HideWithFadeBar();
	end
end

LibAdvFlight.RegisterCallback(LibAdvFlight.Events.VIGOR_CHANGED, DR.vigorCounter);

DR.EventsList = CreateFrame("Frame")

DR.EventsList:RegisterEvent("ADDON_LOADED")
DR.EventsList:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
DR.EventsList:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
if LE_EXPANSION_LEVEL_CURRENT <= LE_EXPANSION_WAR_WITHIN then
	DR.EventsList:RegisterEvent("LEARNED_SPELL_IN_TAB")
end
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

function DR.SetCVars()
	if LibAdvFlight.IsAdvFlying() then return end
	if DragonRider_DB.DynamicFOV == true then
		C_CVar.SetCVar("AdvFlyingDynamicFOVEnabled", 1)
		C_CVar.SetCVar("DriveDynamicFOVEnabled", 1)
	elseif DragonRider_DB.DynamicFOV == false then
		C_CVar.SetCVar("AdvFlyingDynamicFOVEnabled", 0)
		C_CVar.SetCVar("DriveDynamicFOVEnabled", 0)
		
	end
end

function DR.setPositions()
	if SettingsPanel:IsShown() and not DR.IsEditMode then return end
	
	C_Timer.After(2, DR.SetCVars)
	
	DR.statusbar:SetParent(UIParent)
	DR.statusbar:ClearAllPoints()
	
	if DragonRider_DB.position and DragonRider_DB.position.speedometer then
		LoadFramePosition("Speedometer")
	else
		local xOfs = defaultsTable.position.vigor.xOfs
		local yOfs = defaultsTable.position.vigor.yOfs
		DR.statusbar:SetPoint("CENTER", UIParent, "CENTER", xOfs, yOfs)
	end
	
	DR.UpdateSpeedTextAppearance()
	
	DR.vigorBar:SetParent(UIParent)
	DR.vigorBar:ClearAllPoints()
	
	if DragonRider_DB.position and DragonRider_DB.position.vigor then
		LoadFramePosition("Vigor")
	else
		local xOfs = defaultsTable.position.vigor.xOfs
		local yOfs = defaultsTable.position.vigor.yOfs
		DR.vigorBar:SetPoint("CENTER", UIParent, "CENTER", xOfs, yOfs)
	end
	
	DR.UpdateChargePositions()
end

function DR.clearPositions()
	DR.HideWithFadeBar();
	for i = 1, 10 do
		DR.charge[i]:Hide();
	end
	DR.hideModels()
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
					Settings.OpenToCategory(DR.SettingsCategoryID);
					-- DR.commands[L["COMMAND_journal"]]();
				return;
			end
		end
	end
end

local goldTime
local silverTime

-- event handling
function DR.EventsList:CURRENCY_DISPLAY_UPDATE(currencyID)
	-- update the temporary gold/silver time variables when their specific currencies update
	if currencyID == 2019 then
		silverTime = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity;
		return
	end
	if currencyID == 2020 then
		goldTime = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity;
		return
	end

	local raceLocation = DR.CurrencyToRaceMap and DR.CurrencyToRaceMap[currencyID]

	if raceLocation then
		local raceDataTable = DR.RaceData[raceLocation.zoneIndex].races[raceLocation.raceIndex][raceLocation.difficultyKey]

		-- if the static data is missing gold or silver time, save it
		if raceDataTable and (raceDataTable.goldTime == nil or raceDataTable.silverTime == nil) then
			if DragonRider_DB.raceDataCollector == nil then
				DragonRider_DB.raceDataCollector = {}
			end

			-- only save if we have valid gold/silver times from the last race completion
			if goldTime and silverTime and not DragonRider_DB.raceDataCollector[currencyID] then
				DragonRider_DB.raceDataCollector[currencyID] = {
					currencyID = currencyID,
					goldTime = goldTime,
					silverTime = silverTime
				}
				if DragonRider_DB.debug == true then
					Print("Saving Temp Race Data for Currency ID: " .. currencyID .. " (Gold: " .. goldTime .. ", Silver: " .. silverTime .. ")")
				end
			end
		end

		-- trigger a UI update in the journal to reflect the new score
		if DR.mainFrame and DR.mainFrame.UpdatePopulation then
			DR.mainFrame.UpdatePopulation()
		end

		if DragonRider_DB.debug == true then
			Print("Currency Update for Race: " .. currencyID .. ": " .. C_CurrencyInfo.GetCurrencyInfo(currencyID).name)
			Print("New Time: " .. C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity/1000)
			Print("Last collected times - gold: " .. (goldTime or "N/A") .. ", silver: " .. (silverTime or "N/A"))
		end
	end
end


function DR.EventsList:PLAYER_LOGIN()
	DR.mainFrame.DoPopulationStuff();
	local SeasonID = PlayerGetTimerunningSeasonID()
	if SeasonID then -- needs to fire late to register any data
		DR.mainFrame.CreateDragonRiderFlipbook()
		DR.mainFrame.CreateDragonRiderFlipbook()
		DR.mainFrame.CreateDragonRiderFlipbookRotated()
		DR.mainFrame.CreateDragonRiderFlipbookRotated()
		DR.mainFrame.CreateFadeIcon()
		-- double the frames to make it appear more vibrant, as the flipbook is fairly muted
	end
end


local function CreateColorPickerButtonForSetting(category, setting, tooltip)
	local data = Settings.CreateSettingInitializerData(setting, { hasOpacity = true }, tooltip);
	local initializer = Settings.CreateSettingInitializer("DragonRiderColorSwatchSettingTemplate", data);
	local layout = SettingsPanel:GetLayout(category);
	layout:AddInitializer(initializer);
	return initializer;
end

local function SettingsTempFunction(_, args)
	--DevTools_Dump(args) -- debug
	local bingus = args;
	if bingus and bingus.ID and (bingus.ID == DR.SettingsCategoryID or (bingus.parentCategory and bingus.parentCategory.ID == DR.SettingsCategoryID)) and SettingsPanel and SettingsPanel:IsShown() then
		if DR.IsEditMode then return end
		DR.vigorBar:SetFrameStrata("DIALOG");
		DR.statusbar:SetFrameStrata("DIALOG");
		DR.vigorBar:ClearAllPoints()
		DR.statusbar:ClearAllPoints()
		DR.vigorBar:SetPoint("TOP", SettingsPanel, "BOTTOM")
		DR.statusbar:SetPoint("BOTTOM", DR.vigorBar, "TOP", 0, 13)
		
		DR.ShowWithFadeBar()
		if DragonRider_DB.toggleVigor then
			DR.vigorBar:Show()
		else
			DR.vigorBar:Hide()
		end
	else
		DR.statusbar:SetFrameStrata("MEDIUM");
		DR.vigorBar:SetFrameStrata("MEDIUM");


		DR.HideWithFadeBar();
		DR.setPositions();
		DR.UpdateSpeedometerTheme();

		if DR.EvaluateVigorVisibility then DR.EvaluateVigorVisibility() end
	end
end

EventRegistry:RegisterCallback('Settings.CategoryChanged', SettingsTempFunction)
EventRegistry:RegisterCallback('SettingsPanel.OnHide', SettingsTempFunction)

function DR.OnAddonLoaded()

	do
		local realmKey = GetRealmName()
		local charKey = UnitName("player") .. " - " .. realmKey

		SLASH_DRAGONRIDER1 = "/"..L["COMMAND_dragonrider"]
		SlashCmdList.DRAGONRIDER = HandleSlashCommands;

		if not DragonRider_DB then
			DragonRider_DB = CopyTable(defaultsTable)
		else
			DR.MergeDefaults(DragonRider_DB, defaultsTable)
		end

		do
			local db = DragonRider_DB
			local speedValUnitsMap = { [1]="Yards", [2]="Miles", [3]="Meters", [4]="Kilometers", [5]="Percent", [6]="None" }
			local justifyMap = { [1]="LEFT", [2]="CENTER", [3]="RIGHT" }
			local orientationMap = { [1]="Vertical", [2]="Horizontal" }
			local directionMap = { [1]="DownRight", [2]="UpLeft" }
			local fillDirMap = { [1]="Vertical", [2]="Horizontal" }
			local sideArtMap = { [1]="Default", [2]="AlgariBronze", [3]="Algari_Dark", [4]="Algari_Gold", [5]="Algari_Silver", [6]="Default_Desat", [7]="Algari_Desat", [8]="Gryphon_Desat", [9]="Wyvern_Desat", [10]="Dragon_Desat" }
			local modelMap = { [1]="Wind", [2]="Lightning", [3]="FireForm", [4]="ArcaneForm", [5]="FrostForm", [6]="HolyForm", [7]="NatureForm", [8]="ShadowForm" }

			if type(db.speedValUnits) == "number" then db.speedValUnits = speedValUnitsMap[db.speedValUnits] or "Yards" end
			if type(db.speedTextJustify) == "number" then db.speedTextJustify = justifyMap[db.speedTextJustify] or "LEFT" end
			if type(db.vigorBarOrientation) == "number" then db.vigorBarOrientation = orientationMap[db.vigorBarOrientation] or "Horizontal" end
			if type(db.vigorBarDirection) == "number" then db.vigorBarDirection = directionMap[db.vigorBarDirection] or "DownRight" end
			if type(db.vigorBarFillDirection)== "number" then db.vigorBarFillDirection= fillDirMap[db.vigorBarFillDirection] or "Vertical" end
			if type(db.sideArtStyle) == "number" then db.sideArtStyle = sideArtMap[db.sideArtStyle] or "Default" end
			if type(db.modelTheme) == "number" then db.modelTheme = modelMap[db.modelTheme] or "Wind" end
			if type(db.themeSpeed) == "number" then db.themeSpeed = (DR.SpeedometerOptions[db.themeSpeed] and DR.SpeedometerOptions[db.themeSpeed].key) or "Default" end
			if type(db.speedBarTexture)== "number" then db.speedBarTexture= (DR.SpeedometerBarOptions[db.speedBarTexture] and DR.SpeedometerBarOptions[db.speedBarTexture].key) or "Default" end
			if type(db.speedTextFont) == "number" then db.speedTextFont = (DR.SpeedometerFontOptions[db.speedTextFont] and DR.SpeedometerFontOptions[db.speedTextFont].key) or "FrizQuadrata" end
			if type(db.themeVigor) == "number" then db.themeVigor = (DR.VigorOptions[db.themeVigor] and DR.VigorOptions[db.themeVigor].key) or "Default" end
		end

		-- build the currency-to-race lookup map on addon load.
		do
			local function buildCurrencyMap()
				DR.CurrencyToRaceMap = {} -- Clear it in case of reloads
				if not DR.RaceData then return end -- Guard against DRRaceData not being loaded yet
			
				for zoneIndex, zoneData in ipairs(DR.RaceData) do
					if zoneData.races then
						for raceIndex, raceInfo in ipairs(zoneData.races) do
							for difficultyKey, difficultyData in pairs(raceInfo) do
								-- Check if it's a difficulty table by looking for currencyID
								if type(difficultyData) == "table" and difficultyData.currencyID then
									DR.CurrencyToRaceMap[difficultyData.currencyID] = {
										zoneIndex = zoneIndex,
										raceIndex = raceIndex,
										difficultyKey = difficultyKey
									}
								end
							end
						end
					end
				end
			end
			buildCurrencyMap()
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

			DR.vigorCounter();
			DR.setPositions();
			DR.UpdateSpeedometerTheme();
			DR.UpdateSpeedTextAppearance();
			DR.UpdateVigorLayout();
			DR.UpdateVigorFillDirection();
			DR.UpdateVigorTheme();
			DR.modelSetup();
			DR.ToggleDecor();
			DR.UpdateChargePositions();
		end

		local category, layout = Settings.RegisterVerticalLayoutCategory(L["DR_Title"])
		DR.SettingsCategoryID = category.ID

		local categorySpeedometer, layoutSpeedometer = Settings.RegisterVerticalLayoutSubcategory(category, L["Speedometer"]);

		local categoryVigor, layoutVigor = Settings.RegisterVerticalLayoutSubcategory(category, L["Vigor"]);

		--local subcategory, layout2 = Settings.RegisterVerticalLayoutSubcategory(category, "my very own subcategory")

		--layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(string.format(L["Version"], GetAddOnMetadata("DragonRider", "Version"))));

		--layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Speedometer"])); -- moved to subcategory

		local CreateDropdown = Settings.CreateDropdown or Settings.CreateDropDown
		local CreateCheckbox = Settings.CreateCheckbox or Settings.CreateCheckBox

		local function RegisterSetting(key, defaultValue, name, subKey)
			local uniqueVariable
			local setting

			if subKey then
				-- This block handles nested settings like DragonRider_DB.speedBarColor.slow
				uniqueVariable = "DR_" .. key .. "_" .. subKey
				
				-- Ensure the parent table exists to avoid errors
				if DragonRider_DB[key] == nil then DragonRider_DB[key] = {} end

				-- Register the setting against the sub-table
				setting = Settings.RegisterAddOnSetting(category, uniqueVariable, subKey, DragonRider_DB[key], type(defaultValue), name, defaultValue)
				
				-- Set the initial value from the nested variable
				if DragonRider_DB[key][subKey] == nil then DragonRider_DB[key][subKey] = defaultValue end
				setting:SetValue(DragonRider_DB[key][subKey])
			else
				-- This block handles top-level settings like DragonRider_DB.toggleModels
				uniqueVariable = "DR_" .. key
				setting = Settings.RegisterAddOnSetting(category, uniqueVariable, key, DragonRider_DB, type(defaultValue), name, defaultValue)
				if DragonRider_DB[key] == nil then DragonRider_DB[key] = defaultValue end
				setting:SetValue(DragonRider_DB[key])
			end

			Settings.SetOnValueChangedCallback(uniqueVariable, OnSettingChanged)
			return setting
		end

		
		
		--[[
		do
			local variable = "fadeSpeed"
			local name = L["FadeSpeedometer"]
			local tooltip = L["FadeSpeedometerTT"]
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end
		]]

		--layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Vigor"])); -- moved to subcategory

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["MoveFrame"]));

		do
			local function OnButtonClick()
				if not UnitAffectingCombat("player") then
					HideUIPanel(SettingsPanel);
					DR.ToggleEditMode(true);
				end
			end
			local btnText = L["UnlockFrame"]
			local btnTT = L["UnlockFrame"]
			layout:AddInitializer(CreateSettingsButtonInitializer(btnText, btnText, OnButtonClick, btnTT, true));
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SPECIAL));

		do
			local variable = "lightningRush"
			local name = L["LightningRush"]
			local tooltip = L["LightningRushTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		do
			local variable = "staticChargeOffset"
			local name = L["StaticChargeOffset"]
			local tooltip = L["StaticChargeOffsetTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = -30
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
		end

		do
			local variable = "staticChargeSpacing"
			local name = L["StaticChargeSpacing"]
			local tooltip = L["StaticChargeSpacingTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = -15
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
		end

		do
			local variable = "staticChargeWidth"
			local name = L["StaticChargeWidth"]
			local tooltip = L["StaticChargeWidthTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 10
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
		end

		do
			local variable = "staticChargeHeight"
			local name = L["StaticChargeHeight"]
			local tooltip = L["StaticChargeHeightTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 10
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, tooltip)
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SETTING_GROUP_ACCESSIBILITY));

		do
			local variable = "DynamicFOV"
			local name = L["DynamicFOV"]
			local tooltip = L["DynamicFOVNewTT"] .. "\n\n\124cFFFF0000" .. L["DynamicFOV_CaveatTT"].."\124r"
			local defaultValue = true

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(category, setting, tooltip)
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["DragonridingTalents"]));

		do -- dragonriding talents 
			local function OnButtonClick()
				CloseWindows();
				GenericTraitUI_LoadUI();
				GenericTraitFrame:SetConfigIDBySystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
				GenericTraitFrame:SetTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
				ToggleFrame(GenericTraitFrame);
			end

			local initializer = CreateSettingsButtonInitializer(L["DragonridingTalents"], L["DragonridingTalents"], OnButtonClick, L["OpenDragonridingTalentsTT"], true);
			layout:AddInitializer(initializer);
		end

		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RESET));

		StaticPopupDialogs["DRAGONRIDER_RESET_SETTINGS"] = {
			text = L["ResetAllSettingsConfirm"],
			button1 = YES,
			button2 = NO,
			OnAccept = function()
				-- preserve the race data scores
				local savedRaceData = DragonRider_DB.raceData
				local savedCollector = DragonRider_DB.raceDataCollector

				DragonRider_DB = CopyTable(defaultsTable);

				DragonRider_DB.raceData = savedRaceData
				DragonRider_DB.raceDataCollector = savedCollector

				DR.vigorCounter();
				DR.setPositions();
				DR.UpdateSpeedometerTheme();
				DR.UpdateVigorLayout();
				DR.UpdateVigorFillDirection();
				DR.UpdateVigorTheme();
				DR.modelSetup();
				DR.ToggleDecor();
				DR.UpdateChargePositions();
				
				if DragonRider_DB.toggleVigor and LibAdvFlight.IsAdvFlyEnabled() then
					DR.vigorBar:Show()
				else
					DR.vigorBar:Hide()
				end
				
				if DragonRider_DB.toggleSpeedometer then
					DR.ShowWithFadeBar()
				else
					DR.statusbar:Hide()
				end
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

		-- Speedometer Subcategory

		do
			local variable = "toggleSpeedometer"
			local name = L["ToggleSpeedometer"]
			local tooltip = L["ToggleSpeedometerTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		do
			local variable = "themeSpeed"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["SpeedometerTheme"]
			local tooltip = L["SpeedometerThemeTT"].."\n\n"..L["DesaturatedOptionTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				for _, data in ipairs(DR.SpeedometerOptions) do
					container:Add(data.key, data.name or ("Theme " .. data.key))
				end
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categorySpeedometer, setting, GetOptions, tooltip)
		end

		do
			local variable = "speedBarTexture"
			local defaultValue = defaultsTable[variable]
			local name = L["SpeedometerTexture"]
			local tooltip = L["SpeedometerTextureTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				for _, data in ipairs(DR.SpeedometerBarOptions) do
					container:Add(data.key, data.name or ("Texture " .. data.key))
				end
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categorySpeedometer, setting, GetOptions, tooltip)
		end

		do
			local variable = "toggleTopper"
			local name = L["ToggleTopper"]
			local tooltip = L["ToggleTopperTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		do
			local variable = "toggleFooter"
			local name = L["ToggleFooter"]
			local tooltip = L["ToggleFooterTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		do
			local variable = "speedometerWidth"
			local name = L["SpeedometerWidthName"]
			local tooltip = L["SpeedometerWidthTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 100
			local maxValue = 500
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categorySpeedometer, setting, options, tooltip)
		end

		do
			local variable = "speedometerHeight"
			local name = L["SpeedometerHeightName"]
			local tooltip = L["SpeedometerHeightTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 10
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categorySpeedometer, setting, options, tooltip)
		end

		-- scale is essentially defunct with width/height
		--do
		--	local variable = "speedometerScale"
		--	local name = L["SpeedScaleName"]
		--	local tooltip = L["SpeedScaleTT"]
		--	local defaultValue = 1
		--	local minValue = .4
		--	local maxValue = 4
		--	local step = .1
--
		--	local setting = RegisterSetting(variable, defaultValue, name);
		--	local options = Settings.CreateSliderOptions(minValue, maxValue, step)
		--	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
		--	Settings.CreateSlider(categorySpeedometer, setting, options, tooltip)
		--end

		layoutSpeedometer:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["SpeedometerText"]));

		do
			local variable = "speedValUnits"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["Units"]
			local tooltip = L["UnitsTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("Yards",			L["Yards"] .. " - " .. L["UnitYards"])
				container:Add("Miles",			L["Miles"] .. " - " .. L["UnitMiles"])
				container:Add("Meters",			L["Meters"] .. " - " .. L["UnitMeters"])
				container:Add("Kilometers",		L["Kilometers"] .. " - " .. L["UnitKilometers"])
				container:Add("Percent",		L["Percent"] .. " - " .. L["UnitPercent"])
				container:Add("None",			NONE)
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categorySpeedometer, setting, GetOptions, tooltip)
		end

		do
			local variable = "speedTextDecimals"
			local name = L["DecimalPlaces"]
			local tooltip = L["DecimalPlacesTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 0
			local maxValue = 2
			local step = 1

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categorySpeedometer, setting, options, tooltip)
		end

		do
			local variable = "speedTextScale"
			local name = L["SpeedTextScale"]
			local tooltip = L["SpeedTextScaleTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 2
			local maxValue = 30
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step)
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categorySpeedometer, setting, options, tooltip)
		end

		do
			local variable = "speedTextFont"
			local defaultValue = defaultsTable[variable]
			local name = L["SpeedometerTextFont"]
			local tooltip = L["SpeedometerTextFontTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				for _, data in ipairs(DR.SpeedometerFontOptions) do
					container:Add(data.key, data.name)
				end
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categorySpeedometer, setting, GetOptions, tooltip)
		end

		do
			local variable = "speedTextJustify"
			local defaultValue = defaultsTable[variable]
			local name = L["SpeedometerTextPosition"]
			local tooltip = L["SpeedometerTextPositionTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("LEFT",		L["Left"])
				container:Add("CENTER",		L["Center"])
				container:Add("RIGHT",		L["Right"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categorySpeedometer, setting, GetOptions, tooltip)
		end

		layoutSpeedometer:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["SpeedometerTextFlags"]));

		do
			local variable = "speedTextFlagOutline"
			local name = L["Outline"]
			local tooltip = L["OutlineTT"]
			local defaultValue = defaultsTable[variable]
			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		do
			local variable = "speedTextFlagThickOutline"
			local name = L["ThickOutline"]
			local tooltip = L["ThickOutlineTT"]
			local defaultValue = defaultsTable[variable]
			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		do
			local variable = "speedTextFlagMonochrome"
			local name = L["Monochrome"]
			local tooltip = L["MonochromeTT"]
			local defaultValue = defaultsTable[variable]
			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		do
			local variable = "speedTextFlagSlug"
			local name = L["Slug"]
			local tooltip = L["SlugTT"]
			local defaultValue = defaultsTable[variable]
			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categorySpeedometer, setting, tooltip)
		end

		layoutSpeedometer:AddInitializer(CreateSettingsListSectionHeaderInitializer(COLOR_PICKER));

		-- Speedometer Colors
		do -- Low Speed Progress Bar Color
			local key, subKey = "speedBarColor", "slow"
			local name = L["SpeedometerBar_Slow_ColorPicker"]
			local tooltip = L["SpeedometerBar_Slow_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Vigor Speed Progress Bar Color
			local key, subKey = "speedBarColor", "vigor"
			local name = L["SpeedometerBar_Recharge_ColorPicker"]
			local tooltip = L["SpeedometerBar_Recharge_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- High Speed Progress Bar Color
			local key, subKey = "speedBarColor", "over"
			local name = L["SpeedometerBar_Over_ColorPicker"]
			local tooltip = L["SpeedometerBar_Over_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		-- Text Colors
		do -- Low Speed Text Color
			local key, subKey = "speedTextColor", "slow"
			local name = L["SpeedometerText_Slow_ColorPicker"]
			local tooltip = L["SpeedometerText_Slow_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Vigor Speed Text Color
			local key, subKey = "speedTextColor", "vigor"
			local name = L["SpeedometerText_Recharge_ColorPicker"]
			local tooltip = L["SpeedometerText_Recharge_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- High Speed Text Color
			local key, subKey = "speedTextColor", "over"
			local name = L["SpeedometerText_Over_ColorPicker"]
			local tooltip = L["SpeedometerText_Over_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Speedometer Cover Color
			local key, subKey = "speedBarColor", "cover"
			local name = L["SpeedometerCover_ColorPicker"]
			local tooltip = L["SpeedometerCover_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Speedometer Tick Color
			local key, subKey = "speedBarColor", "tick"
			local name = L["SpeedometerTick_ColorPicker"]
			local tooltip = L["SpeedometerTick_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Speedometer Topper Color
			local key, subKey = "speedBarColor", "topper"
			local name = L["SpeedometerTopper_ColorPicker"]
			local tooltip = L["SpeedometerTopper_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Speedometer Footer Color
			local key, subKey = "speedBarColor", "footer"
			local name = L["SpeedometerFooter_ColorPicker"]
			local tooltip = L["SpeedometerFooter_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Speedometer Background Color
			local key, subKey = "speedBarColor", "background"
			local name = L["SpeedometerBackground_ColorPicker"]
			local tooltip = L["SpeedometerBackground_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end

		do -- Speedometer Spark Color
			local key, subKey = "speedBarColor", "spark"
			local name = L["SpeedometerSpark_ColorPicker"]
			local tooltip = L["SpeedometerSpark_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categorySpeedometer, setting, tooltip)
		end


		Settings.RegisterAddOnCategory(categorySpeedometer)

		-- Vigor Subcategory

		do
			local variable = "toggleVigor"
			local name = L["ToggleVigor"]
			local tooltip = L["ToggleVigorTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		do
			local variable = "fadeVigor"
			local name = L["FadeVigor"]
			local tooltip = L["FadeVigorTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		do
			local variable = "themeVigor"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["VigorTheme"]
			local tooltip = L["VigorThemeTT"].."\n\n"..L["DesaturatedOptionTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				for _, data in ipairs(DR.VigorOptions) do
					container:Add(data.key, data.name or ("Theme " .. data.key))
				end
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categoryVigor, setting, GetOptions, tooltip)
		end

		do
			local variable = "vigorBarWidth"
			local name = L["VigorBarWidthName"]
			local tooltip = L["VigorBarWidthNameTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 10
			local maxValue = 200
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "vigorBarHeight"
			local name = L["VigorBarHeightName"]
			local tooltip = L["VigorBarHeightNameTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 10
			local maxValue = 200
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "vigorBarSpacing"
			local name = L["VigorBarSpacingName"]
			local tooltip = L["VigorBarSpacingNameTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 0
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "vigorBarOrientation"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["VigorBarOrientationName"]
			local tooltip = L["VigorBarOrientationNameTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("Vertical",		L["Orientation_Vertical"])
				container:Add("Horizontal",		L["Orientation_Horizontal"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categoryVigor, setting, GetOptions, tooltip)
		end

		do
			local variable = "vigorBarDirection"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["VigorBarDirectionName"]
			local tooltip = L["VigorBarDirectionNameTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("DownRight",		L["Direction_DownRight"])
				container:Add("UpLeft",			L["Direction_UpLeft"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categoryVigor, setting, GetOptions, tooltip)
		end

		do
			local variable = "vigorWrap"
			local name = L["VigorWrapName"]
			local tooltip = L["VigorWrapNameTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 1
			local maxValue = 6
			local step = 1

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "vigorBarFillDirection"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["VigorBarFillDirectionName"]
			local tooltip = L["VigorBarFillDirectionNameTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("Vertical",		L["Direction_Vertical"])
				container:Add("Horizontal",		L["Direction_Horizontal"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categoryVigor, setting, GetOptions, tooltip)
		end

		--[[
		do
			local variable = "vigorSparkThickness" -- NYI
			local name = "[PH]"..L["VigorSparkThicknessName"].." [NYI]"
			local tooltip = "[PH]"..L["VigorSparkThicknessNameTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = -Round(GetScreenWidth())
			local maxValue = Round(GetScreenWidth())
			local step = 1

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end
		]]

		do
			local variable = "toggleFlashFull"
			local name = L["ToggleFlashFullName"]
			local tooltip = L["ToggleFlashFullNameTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		do
			local variable = "toggleFlashProgress"
			local name = L["ToggleFlashProgressName"]
			local tooltip = L["ToggleFlashProgressNameTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		do
			local variable = "toggleModels"
			local name = L["ToggleModelsName"]
			local tooltip = L["ToggleModelsTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		do
			local variable = "modelTheme"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["ModelThemeName"]
			local tooltip = L["ModelThemeNameTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("Wind",			L["ModelTheme_Wind"])
				container:Add("Lightning",		L["ModelTheme_Lightning"])
				container:Add("FireForm",		L["ModelTheme_FireForm"])
				container:Add("ArcaneForm",		L["ModelTheme_ArcaneForm"])
				container:Add("FrostForm",		L["ModelTheme_FrostForm"])
				container:Add("HolyForm",		L["ModelTheme_HolyForm"])
				container:Add("NatureForm",		L["ModelTheme_NatureForm"])
				container:Add("ShadowForm",		L["ModelTheme_ShadowForm"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categoryVigor, setting, GetOptions, tooltip)
		end

		do
			local variable = "sideArt"
			local name = L["SideArtName"]
			local tooltip = L["SideArtTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		do
			local variable = "sideArtStyle"
			local defaultValue = defaultsTable[variable]  -- Corresponds to "Option 1" below.
			local name = L["SideArtStyleName"]
			local tooltip = L["SideArtStyleNameTT"].."\n\n"..L["DesaturatedOptionTT"]

			local function GetOptions()
				local container = Settings.CreateControlTextContainer()
				container:Add("Default",			L["Default"])
				container:Add("AlgariBronze",		L["ThemeAlgari_Bronze"])
				container:Add("Algari_Dark",		L["ThemeAlgari_Dark"])
				container:Add("Algari_Gold",		L["ThemeAlgari_Gold"])
				container:Add("Algari_Silver",		L["ThemeAlgari_Silver"])
				container:Add("Default_Desat",		L["ThemeDefault_Desaturated"])
				container:Add("Algari_Desat",		L["ThemeAlgari_Desaturated"])
				container:Add("Gryphon_Desat",		L["ThemeGryphon_Desaturated"])
				container:Add("Wyvern_Desat",		L["ThemeWyvern_Desaturated"])
				container:Add("Dragon_Desat",		L["ThemeDragon_Desaturated"])
				return container:GetData()
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateDropdown(categoryVigor, setting, GetOptions, tooltip)
		end

		do
			local variable = "sideArtPosX"
			local name = L["SideArtPosX"]
			local tooltip = L["SideArtPosXTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = -100
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "sideArtPosY"
			local name = L["SideArtPosY"]
			local tooltip = L["SideArtPosYTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = -100
			local maxValue = 100
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "sideArtRot"
			local name = L["SideArtRot"]
			local tooltip = L["SideArtRotTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = 0
			local maxValue = 360
			local step = .5

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		do
			local variable = "sideArtSize"
			local name = L["SideArtScale"]
			local tooltip = L["SideArtScaleTT"]
			local defaultValue = defaultsTable[variable]
			local minValue = .5
			local maxValue = 2
			local step = .1

			local function Formatter(value)
				return string.format("%.1f", value);
			end

			local setting = RegisterSetting(variable, defaultValue, name);
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, Formatter);
			Settings.CreateSlider(categoryVigor, setting, options, tooltip);
		end

		--[[
		do
			local variable = "showtooltip"
			local name = L["ShowVigorTooltip"].." [NYI]"
			local tooltip = L["ShowVigorTooltipTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end
		]]

		do
			local variable = "muteVigorSound"
			local name = L["MuteVigorSound_Settings"]
			local tooltip = L["MuteVigorSound_SettingsTT"]
			local defaultValue = defaultsTable[variable]

			local setting = RegisterSetting(variable, defaultValue, name);
			CreateCheckbox(categoryVigor, setting, tooltip)
		end

		layoutVigor:AddInitializer(CreateSettingsListSectionHeaderInitializer(COLOR_PICKER));


		-- Vigor Colors
		do -- full
			local key, subKey = "vigorBarColor", "full"
			local name = L["VigorBar_Full_ColorPicker"]
			local tooltip = L["VigorBar_Full_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- empty
			local key, subKey = "vigorBarColor", "empty"
			local name = L["VigorBar_Empty_ColorPicker"]
			local tooltip = L["VigorBar_Empty_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- progress
			local key, subKey = "vigorBarColor", "progress"
			local name = L["VigorBar_Progress_ColorPicker"]
			local tooltip = L["VigorBar_Progress_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- cover
			local key, subKey = "vigorBarColor", "cover"
			local name = L["VigorBarCover_ColorPicker"]
			local tooltip = L["VigorBarCover_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- background
			local key, subKey = "vigorBarColor", "background"
			local name = L["VigorBarBackground_ColorPicker"]
			local tooltip = L["VigorBarBackground_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- spark
			local key, subKey = "vigorBarColor", "spark"
			local name = L["VigorBarSpark_ColorPicker"]
			local tooltip = L["VigorBarSpark_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- flash
			local key, subKey = "vigorBarColor", "flash"
			local name = L["VigorBarFlash_ColorPicker"]
			local tooltip = L["VigorBarFlash_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end
		do -- decor
			local key, subKey = "vigorBarColor", "decor"
			local name = L["VigorBarDecor_ColorPicker"]
			local tooltip = L["VigorBarDecor_ColorPickerTT"]
			local setting = RegisterSetting(key, defaultsTable[key][subKey], name, subKey)
			CreateColorPickerButtonForSetting(categoryVigor, setting, tooltip)
		end

		Settings.RegisterAddOnCategory(categoryVigor)


		function DragonRider_OnAddonCompartmentClick(addonName, buttonName, menuButtonFrame)
			if buttonName == "RightButton" then
				if not UnitAffectingCombat("player") then
					Settings.OpenToCategory(category.ID);
				end
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

		local speedTicker = nil

		local function OnUpdate()
			DR.updateSpeed();
		end

		local function StartSpeedTicker()
			if not speedTicker then
				speedTicker = C_Timer.NewTicker(0.1, OnUpdate)
			end
		end

		local function StopSpeedTicker()
			if speedTicker then
				speedTicker:Cancel()
				speedTicker = nil
			end
		end


		local previewTicker = nil

		local PREVIEW_VIGOR_MIN = 3
		local PREVIEW_VIGOR_MAX = 5  -- charge 6 stays permanently empty

		local PREVIEW_SPEED_MIN = 50
		local PREVIEW_SPEED_MAX = 100

		local PREVIEW_SPEED_PERIOD  = 15
		local PREVIEW_VIGOR_PERIOD  = 24

		local function UpdatePreviewValues()
			local t = GetTime()

			local speedMid   = (PREVIEW_SPEED_MIN + PREVIEW_SPEED_MAX) / 2
			local speedRange = (PREVIEW_SPEED_MAX - PREVIEW_SPEED_MIN) / 2
			DR.previewSpeed  = speedMid + math.sin(t * (2 * math.pi / PREVIEW_SPEED_PERIOD) - math.pi / 2) * speedRange

			local vigorRange = PREVIEW_VIGOR_MAX - PREVIEW_VIGOR_MIN  -- = 2
			local vigorPhase = (t % PREVIEW_VIGOR_PERIOD) / PREVIEW_VIGOR_PERIOD
			local vigorWave
			if vigorPhase < 0.5 then
				vigorWave = vigorPhase * 2
			else
				vigorWave = (1 - vigorPhase) * 2
			end
			local vigorF       = PREVIEW_VIGOR_MIN + vigorWave * vigorRange
			local vigorCurrent = math.floor(vigorF)
			local vigorProgress = vigorF - vigorCurrent

			local chargeDuration = (PREVIEW_VIGOR_PERIOD / 2) / vigorRange

			if vigorCurrent >= PREVIEW_VIGOR_MAX then
				DR.previewVigor = { current = PREVIEW_VIGOR_MAX, max = 6, start = 0, duration = 0 }
			else
				DR.previewVigor = {
					current  = vigorCurrent,
					max      = 6,
					start    = t - vigorProgress * chargeDuration,
					duration = chargeDuration,
				}
			end
		end

		local function StartPreviewMode()
			if previewTicker then return end
			DR.IsPreviewMode = true
			previewTicker = C_Timer.NewTicker(0.05, function()
				UpdatePreviewValues()
				DR.updateSpeed()
				DR.vigorCounter()
			end)
		end

		local function StopPreviewMode()
			DR.IsPreviewMode = false
			DR.previewSpeed  = nil
			DR.previewVigor  = nil
			if previewTicker then
				previewTicker:Cancel()
				previewTicker = nil
			end
		end

		EventRegistry:RegisterCallback('Settings.CategoryChanged', function(_, args)
			if args and args.ID and
			   (args.ID == DR.SettingsCategoryID or
			   (args.parentCategory and args.parentCategory.ID == DR.SettingsCategoryID)) and
			   SettingsPanel and SettingsPanel:IsShown() then
				StartPreviewMode()
			else
				StopPreviewMode()
			end
		end)

		EventRegistry:RegisterCallback('SettingsPanel.OnHide', function()
			StopPreviewMode()
		end)

		-- when the player takes off and starts flying
		local function OnAdvFlyStart()
			DR.ShowWithFadeBar();
			DR.setPositions();
			if DR.EvaluateVigorVisibility then DR.EvaluateVigorVisibility() end
		end

		-- when the player mounts but isn't flying yet
		-- OR when the player lands after flying but is still mounted
		local function OnAdvFlyEnabled()
			DR.HideWithFadeBar();
			DR.setPositions();
			
			DR.vigorCounter();
			DR.modelSetup();
			DR.ToggleDecor();
			DR.UpdateVigorLayout();
			DR.UpdateVigorFillDirection();
			DR.UpdateVigorTheme();
			DR.UpdateSpeedometerTheme();
			DR.UpdateChargePositions();

			StartSpeedTicker();
			
			if DR.EvaluateVigorVisibility then DR.EvaluateVigorVisibility() end
		end

		local function OnAdvFlyEnd()
			DR.HideWithFadeBar();
			DR.setPositions();
			
			if DR.EvaluateVigorVisibility then DR.EvaluateVigorVisibility() end
		end

		-- when the player dismounts
		local function OnAdvFlyDisabled()
			DR.HideWithFadeBar();
			DR.clearPositions();

			StopSpeedTicker();
			
			if DR.EvaluateVigorVisibility then DR.EvaluateVigorVisibility() end
		end

		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_START, OnAdvFlyStart);
		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_END, OnAdvFlyEnd);
		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_ENABLED, OnAdvFlyEnabled);
		LibAdvFlight.RegisterCallback(LibAdvFlight.Events.ADV_FLYING_DISABLED, OnAdvFlyDisabled);

		local function OnDriveStart()
			if DR.DriveUtils.IsDriving() then
				OnAdvFlyStart();
				StartSpeedTicker();
			end
		end

		local function OnDriveEnd()
			if not DR.DriveUtils.IsDriving() then
				OnAdvFlyEnd();
				if not LibAdvFlight.IsAdvFlyEnabled() then
					StopSpeedTicker();
				end
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

		DR.UpdateSpeedometerTheme();
		DR.UpdateVigorLayout();
		DR.UpdateVigorFillDirection();
		DR.UpdateVigorTheme();
		DR.modelSetup();
		DR.ToggleDecor();
		DR.UpdateChargePositions();

		if LibAdvFlight.IsAdvFlyEnabled() then
			OnAdvFlyEnabled();
		end
	end
end

EventUtil.ContinueOnAddOnLoaded("DragonRider", DR.OnAddonLoaded);