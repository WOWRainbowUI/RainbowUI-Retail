local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

---@type LibAdvFlight
local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.1");

---------------------------------------------------------------------------------------------------------------
-- DRIVE system
---------------------------------------------------------------------------------------------------------------

local DRIVE_LAST_TIME;
local DRIVE_LAST_POS;
DR.DriveUtils = {};

function DR.DriveUtils.GetPosition()
	local map = C_Map.GetBestMapForUnit("player");
	local pos = C_Map.GetPlayerMapPosition(map, "player");
	local _, worldPos = C_Map.GetWorldPosFromMapPos(map, pos);
	return worldPos;
end

function DR.DriveUtils.GetSpeed()
	if not IsPlayerMoving() then
		return 0;
	end

	local currentPos = DR.DriveUtils.GetPosition();
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

function DR.DriveUtils.GetSmoothedSpeed()
	if not IsPlayerMoving() then
		return 0;
	end

	local currentSpeed = DR.DriveUtils.GetSpeed();
	SPEED_SAMPLES:PushFront(currentSpeed);

	local total = 0;
	for _, speed in SPEED_SAMPLES:EnumerateIndexedEntries() do
		total = total + speed;
	end

	return total / SPEED_SAMPLES:GetNumElements();
end

local CAR_SPELL_ID = 460013;
function DR.DriveUtils.IsDriving()
	if C_Secrets and C_Secrets.ShouldSpellCooldownBeSecret(CAR_SPELL_ID) then return end
	local aura = C_UnitAuras.GetPlayerAuraBySpellID(CAR_SPELL_ID);
	return aura and true or false;
end

---------------------------------------------------------------------------------------------------------------
-- Speedometer Rework
---------------------------------------------------------------------------------------------------------------

DR.SpeedometerOptions = {}

function DR.RegisterSpeedometerTheme(themeKey, themeName, themeData)
	if type(themeData) ~= "table" then return end
	
	for _, theme in ipairs(DR.SpeedometerOptions) do
		if theme.key == themeKey then
			return
		end
	end

	themeData.key = themeKey
	themeData.name = themeName
	if not themeData.Cover then themeData.Cover = {} end
	if not themeData.Bar then themeData.Bar = {} end

	table.insert(DR.SpeedometerOptions, themeData)
end

local function AddBuiltInThemes()
	 -- default speedometer
	DR.RegisterSpeedometerTheme("Default", L["Default"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78}, -- used for the Tick texture to custom match up to the edges
			LeftAtlas = "widgetstatusbar-borderleft",
			RightAtlas = "widgetstatusbar-borderright",
			MiddleAtlas = "widgetstatusbar-bordercenter",
			CoverLWidth = 35,
			CoverRWidth = 35,
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -7,
			CoverLYMult = 0.3,
			CoverRX = 7,
			CoverRYMult = 0.3,
			TopperAtlas = "dragonflight-score-topper",
			FooterAtlas = "dragonflight-score-footer",
			TopperXY = {0, 38},
			FooterXY = {0, -32},
			TopperSize = {350,65},
			FooterSize = {350,65},
			BackgroundLeftAtlas = "widgetstatusbar-bgleft",
			BackgroundRightAtlas = "widgetstatusbar-bgright",
			BackgroundMiddleAtlas = "widgetstatusbar-bgcenter",
			BackgroundLWidth = 35,
			BackgroundRWidth = 35,
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = -2,
			BackgroundLYMult = 0,
			BackgroundRX = 2,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
		}
	})

	-- algari
	DR.RegisterSpeedometerTheme("Algari_Gold", L["ThemeAlgari_Gold"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78}, -- used for the Tick texture to custom match up to the edges
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_G.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_G.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_G.blp",
			CoverLWidth = 70, 
			CoverRWidth = 70, 
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37, 
			CoverLYMult = 1.0, 
			CoverRX = 37, 
			CoverRYMult = 1.0, 
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_G.blp",
			FooterTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_G.blp",
			TopperXY = {0, 39}, 
			FooterXY = {0, -28}, 
			TopperSize = {150,65}, 
			FooterSize = {115,50}, 
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGM.blp",
			BackgroundLWidth = 0, 
			BackgroundRWidth = 0, 
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
		}
	})

	-- minimalist
	DR.RegisterSpeedometerTheme("Minimalist", L["Minimalist"], {
		Cover = {
			TickAtlas = nil,
			Width = 1,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,0,1}, 
			LeftAtlas = nil,
			RightAtlas = nil,
			MiddleAtlas = nil,
			CoverLWidth = 0,
			CoverRWidth = 0,
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = 0,
			CoverLYMult = 0,
			CoverRX = 0,
			CoverRYMult = 0,
			TopperAtlas = nil,
			FooterAtlas = nil,
			TopperXY = {0, 0},
			FooterXY = {0, 0},
			TopperSize = {0,0},
			FooterSize = {0,0},
			BackgroundLeftAtlas = nil,
			BackgroundRightAtlas = nil,
			BackgroundMiddleAtlas = nil,
			BackgroundLWidth = 0,
			BackgroundRWidth = 0,
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = true,
			TickDesat = true,
			TopperDesat = true,
			FooterDesat = true,
			BackgroundDesat = true,
		},
		Bar = {
			BarTexture = "Interface\\buttons\\white8x8",
		}
	})

	-- alliance
	DR.RegisterSpeedometerTheme("Alliance", L["Alliance"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_L.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_R.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_M.blp",
			CoverLWidth = 70,
			CoverRWidth = 70,
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37,
			CoverLYMult = 1.0,
			CoverRX = 37,
			CoverRYMult = 1.0,
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_Topper.blp",
			FooterTexture = nil, -- will not be implemented
			TopperXY = {0, 39.5},
			FooterXY = {0, 0},
			TopperSize = {350,65},
			FooterSize = {0,0},
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_BGM.blp",
			BackgroundLWidth = 0,
			BackgroundRWidth = 0,
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_Progress.blp",
		}
	})

	-- horde
	DR.RegisterSpeedometerTheme("Horde", L["Horde"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_L.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_R.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_M.blp",
			CoverLWidth = 70,
			CoverRWidth = 70,
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37,
			CoverLYMult = 1.0,
			CoverRX = 37,
			CoverRYMult = 1.0,
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_Topper.blp",
			FooterTexture = nil, -- will not be implemented
			TopperXY = {0, 39.5},
			FooterXY = {0, 0},
			TopperSize = {350,65},
			FooterSize = {0,0},
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_BGM.blp",
			BackgroundLWidth = 0,
			BackgroundRWidth = 0,
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_Progress.blp",
		}
	})

	-- algari bronze
	DR.RegisterSpeedometerTheme("Algari_Bronze", L["ThemeAlgari_Bronze"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_B.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_B.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_B.blp",
			CoverLWidth = 70, 
			CoverRWidth = 70, 
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37, 
			CoverLYMult = 1.0, 
			CoverRX = 37, 
			CoverRYMult = 1.0, 
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_B.blp",
			FooterTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_B.blp",
			TopperXY = {0, 39}, 
			FooterXY = {0, -28}, 
			TopperSize = {150,65}, 
			FooterSize = {115,50}, 
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGM.blp",
			BackgroundLWidth = 0, 
			BackgroundRWidth = 0, 
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
		}
	})

	-- algari dark
	DR.RegisterSpeedometerTheme("Algari_Dark", L["ThemeAlgari_Dark"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_D.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_D.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_D.blp",
			CoverLWidth = 70, 
			CoverRWidth = 70, 
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37, 
			CoverLYMult = 1.0, 
			CoverRX = 37, 
			CoverRYMult = 1.0, 
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_D.blp",
			FooterTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_D.blp",
			TopperXY = {0, 39}, 
			FooterXY = {0, -28}, 
			TopperSize = {150,65}, 
			FooterSize = {115,50}, 
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGM.blp",
			BackgroundLWidth = 0, 
			BackgroundRWidth = 0, 
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
		}
	})

	-- algari silver
	DR.RegisterSpeedometerTheme("Algari_Silver", L["ThemeAlgari_Silver"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_S.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_S.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_S.blp",
			CoverLWidth = 70, 
			CoverRWidth = 70, 
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37, 
			CoverLYMult = 1.0, 
			CoverRX = 37, 
			CoverRYMult = 1.0, 
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_S.blp",
			FooterTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_S.blp",
			TopperXY = {0, 39}, 
			FooterXY = {0, -28}, 
			TopperSize = {150,65}, 
			FooterSize = {115,50}, 
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGM.blp",
			BackgroundLWidth = 0, 
			BackgroundRWidth = 0, 
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = false,
			TickDesat = false,
			TopperDesat = false,
			FooterDesat = false,
			BackgroundDesat = false,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
		}
	})

	--default desaturated
	DR.RegisterSpeedometerTheme("Default_Desaturated", L["ThemeDefault_Desaturated"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftAtlas = "widgetstatusbar-borderleft",
			RightAtlas = "widgetstatusbar-borderright",
			MiddleAtlas = "widgetstatusbar-bordercenter",
			CoverLWidth = 35,
			CoverRWidth = 35,
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -7,
			CoverLYMult = 0.3,
			CoverRX = 7,
			CoverRYMult = 0.3,
			TopperAtlas = "dragonflight-score-topper",
			FooterAtlas = "dragonflight-score-footer",
			TopperXY = {0, 38},
			FooterXY = {0, -32},
			TopperSize = {350,65},
			FooterSize = {350,65},
			BackgroundLeftAtlas = "widgetstatusbar-bgleft",
			BackgroundRightAtlas = "widgetstatusbar-bgright",
			BackgroundMiddleAtlas = "widgetstatusbar-bgcenter",
			BackgroundLWidth = 35,
			BackgroundRWidth = 35,
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = -2,
			BackgroundLYMult = 0,
			BackgroundRX = 2,
			BackgroundRYMult = 0,
			CoverDesat = true,
			TickDesat = true,
			TopperDesat = true,
			FooterDesat = true,
			BackgroundDesat = true,
		},
		Bar = {
			BarTexture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
		}
	})

	-- algari desaturated
	DR.RegisterSpeedometerTheme("Algari_Desaturated", L["ThemeAlgari_Desaturated"], {
		Cover = {
			TickAtlas = "UI-Frame-Bar-BorderTick",
			Width = 17,
			TickHeightMult = 1.0,
			TickYOffset = 0,
			TickTexCoords = {0,1,.19,.78},
			LeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_L_S.blp",
			RightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_R_S.blp",
			MiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_M_S.blp",
			CoverLWidth = 70, 
			CoverRWidth = 70, 
			CoverLTexCoords = {0,1,0,1},
			CoverRTexCoords = {0,1,0,1},
			CoverMTexCoords = {0,1,0,1},
			CoverLX = -37, 
			CoverLYMult = 1.0, 
			CoverRX = 37, 
			CoverRYMult = 1.0, 
			TopperTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Topper_S.blp",
			FooterTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Footer_S.blp",
			TopperXY = {0, 39}, 
			FooterXY = {0, -28}, 
			TopperSize = {150,65}, 
			FooterSize = {115,50}, 
			BackgroundLeftTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGL.blp",
			BackgroundRightTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGR.blp",
			BackgroundMiddleTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_BGM.blp",
			BackgroundLWidth = 0, 
			BackgroundRWidth = 0, 
			BackgroundLTexCoords = {0,1,0,1},
			BackgroundRTexCoords = {0,1,0,1},
			BackgroundMTexCoords = {0,1,0,1},
			BackgroundLX = 0,
			BackgroundLYMult = 0,
			BackgroundRX = 0,
			BackgroundRYMult = 0,
			CoverDesat = true,
			TickDesat = true,
			TopperDesat = true,
			FooterDesat = true,
			BackgroundDesat = true,
		},
		Bar = {
			BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
		}
	})
end

AddBuiltInThemes()

local SpeedometerBarOptions = { -- eventually this will be a separate option using mask textures
	[1] = { -- default
		BarTexture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
	},
	[2] = { -- algari gold
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
	},
	[3] = { -- minimalist
		BarTexture = "Interface\\buttons\\white8x8",
	},
	[4] = { -- alliance
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Alliance\\Alliance_Progress.blp",
	},
	[5] = { -- horde
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Horde\\Horde_Progress.blp",
	},
	[6] = { -- algari bronze 
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
	},
	[7] = { -- algari dark
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
	},
	[8] = { -- algari silver
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
	},
	[9] = { -- default
		BarTexture = "Interface\\TARGETINGFRAME\\UI-StatusBar",
	},
	[10] = { -- algari silver
		BarTexture = "Interface\\AddOns\\DragonRider\\Textures\\Speed_Themes\\Ed\\Ed_Progress.blp",
	},
};

local DefOptions = DR.SpeedometerOptions[1].Cover
local DefBarOptions = DR.SpeedometerOptions[1].Bar

DR.statusbar = CreateFrame("StatusBar", "DragonRider_Speedometer", UIParent)
DR.statusbar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
DR.statusbar:SetWidth(244)
DR.statusbar:SetHeight(24)
DR.statusbar:SetStatusBarTexture(DefBarOptions.BarTexture)
DR.statusbar:GetStatusBarTexture():SetHorizTile(false)
DR.statusbar:GetStatusBarTexture():SetVertTile(false)
DR.statusbar:SetStatusBarColor(.98, .61, .0)
Mixin(DR.statusbar, SmoothStatusBarMixin)
DR.statusbar:SetMinMaxSmoothedValue(0,100)
DR.statusbar:SetValue(50)
DR.statusbar:Hide()

local borderPixel = "Interface\\buttons\\white8x8"
local borderThickness = 1

DR.statusbar.borderTop = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 5)
DR.statusbar.borderTop:SetTexture(borderPixel)
PixelUtil.SetPoint(DR.statusbar.borderTop, "TOPLEFT", DR.statusbar, "TOPLEFT", 0, 0)
PixelUtil.SetPoint(DR.statusbar.borderTop, "TOPRIGHT", DR.statusbar, "TOPRIGHT", 0, 0)
DR.statusbar.borderTop:SetHeight(borderThickness)
DR.statusbar.borderTop:SetTexelSnappingBias(0)
DR.statusbar.borderTop:SetSnapToPixelGrid(false)
DR.statusbar.borderTop:Hide()

DR.statusbar.borderBottom = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 5)
DR.statusbar.borderBottom:SetTexture(borderPixel)
PixelUtil.SetPoint(DR.statusbar.borderBottom, "BOTTOMLEFT", DR.statusbar, "BOTTOMLEFT", 0, 0)
PixelUtil.SetPoint(DR.statusbar.borderBottom, "BOTTOMRIGHT", DR.statusbar, "BOTTOMRIGHT", 0, 0)
DR.statusbar.borderBottom:SetHeight(borderThickness)
DR.statusbar.borderBottom:SetTexelSnappingBias(0)
DR.statusbar.borderBottom:SetSnapToPixelGrid(false)
DR.statusbar.borderBottom:Hide()

DR.statusbar.borderLeft = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 5)
DR.statusbar.borderLeft:SetTexture(borderPixel)
PixelUtil.SetPoint(DR.statusbar.borderLeft, "TOPLEFT", DR.statusbar, "TOPLEFT", 0, -borderThickness)
PixelUtil.SetPoint(DR.statusbar.borderLeft, "BOTTOMLEFT", DR.statusbar, "BOTTOMLEFT", 0, borderThickness)
DR.statusbar.borderLeft:SetWidth(borderThickness)
DR.statusbar.borderLeft:SetTexelSnappingBias(0)
DR.statusbar.borderLeft:SetSnapToPixelGrid(false)
DR.statusbar.borderLeft:Hide()

DR.statusbar.borderRight = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 5)
DR.statusbar.borderRight:SetTexture(borderPixel)
PixelUtil.SetPoint(DR.statusbar.borderRight, "TOPRIGHT", DR.statusbar, "TOPRIGHT", 0, -borderThickness)
PixelUtil.SetPoint(DR.statusbar.borderRight, "BOTTOMRIGHT", DR.statusbar, "BOTTOMRIGHT", 0, borderThickness)
DR.statusbar.borderRight:SetWidth(borderThickness)
DR.statusbar.borderRight:SetTexelSnappingBias(0)
DR.statusbar.borderRight:SetSnapToPixelGrid(false)
DR.statusbar.borderRight:Hide()

local tick_1 = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 1) -- start gaining accelerated vigor
tick_1:SetAtlas(DefOptions.TickAtlas)
tick_1:SetWidth(DefOptions.Width)
tick_1:SetHeight(DR.statusbar:GetHeight() * DefOptions.TickHeightMult)
tick_1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (65 / 100) * DR.statusbar:GetWidth(), DefOptions.TickYOffset)
tick_1:SetTexCoord(unpack(DefOptions.TickTexCoords))

local tick_2 = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 1) -- above the "natural" glide speed
tick_2:SetAtlas(DefOptions.TickAtlas)
tick_2:SetWidth(DefOptions.Width)
tick_2:SetHeight(DR.statusbar:GetHeight() * DefOptions.TickHeightMult)
tick_2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (60 / 100) * DR.statusbar:GetWidth(), DefOptions.TickYOffset)
tick_2:SetTexCoord(unpack(DefOptions.TickTexCoords))

DR.statusbar.tick_1 = tick_1
DR.statusbar.tick_2 = tick_2

local CoverL = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 2)
CoverL:SetAtlas(DefOptions.LeftAtlas)
CoverL:SetPoint("TOPLEFT", DR.statusbar, "TOPLEFT", DefOptions.CoverLX, DR.statusbar:GetHeight()*DefOptions.CoverLYMult)
CoverL:SetPoint("BOTTOMLEFT", DR.statusbar, "BOTTOMLEFT", DefOptions.CoverLX, -(DR.statusbar:GetHeight()*DefOptions.CoverLYMult))
CoverL:SetWidth(DefOptions.CoverLWidth)
CoverL:SetTexCoord(unpack(DefOptions.CoverLTexCoords))

local CoverR = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 2)
CoverR:SetAtlas(DefOptions.RightAtlas)
CoverR:SetPoint("TOPRIGHT", DR.statusbar, "TOPRIGHT", DefOptions.CoverRX, DR.statusbar:GetHeight()*DefOptions.CoverRYMult)
CoverR:SetPoint("BOTTOMRIGHT", DR.statusbar, "BOTTOMRIGHT", DefOptions.CoverRX, -(DR.statusbar:GetHeight()*DefOptions.CoverRYMult))
CoverR:SetWidth(DefOptions.CoverRWidth)
CoverR:SetTexCoord(unpack(DefOptions.CoverRTexCoords))

local CoverM = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 2)
CoverM:SetAtlas(DefOptions.MiddleAtlas)
CoverM:SetPoint("TOPLEFT", CoverL, "TOPRIGHT", 0, 0)
CoverM:SetPoint("BOTTOMRIGHT", CoverR, "BOTTOMLEFT", 0, 0)

DR.statusbar.CoverL = CoverL
DR.statusbar.CoverR = CoverR
DR.statusbar.CoverM = CoverM

-- utilize interface/framegeneral/uiframedragonflight texture sometime

local BGL = DR.statusbar:CreateTexture(nil, "BACKGROUND", nil, 0)
BGL:SetAtlas(DefOptions.BackgroundLeftAtlas)
BGL:SetPoint("TOPLEFT", DR.statusbar, "TOPLEFT", DefOptions.BackgroundLX, DR.statusbar:GetHeight()*DefOptions.BackgroundLYMult)
BGL:SetPoint("BOTTOMLEFT", DR.statusbar, "BOTTOMLEFT", DefOptions.BackgroundLX, -(DR.statusbar:GetHeight()*DefOptions.BackgroundLYMult))
BGL:SetWidth(DefOptions.BackgroundLWidth)
BGL:SetTexCoord(unpack(DefOptions.BackgroundLTexCoords))

local BGR = DR.statusbar:CreateTexture(nil, "BACKGROUND", nil, 0)
BGR:SetAtlas(DefOptions.BackgroundRightAtlas)
BGR:SetPoint("TOPRIGHT", DR.statusbar, "TOPRIGHT", DefOptions.BackgroundRX, DR.statusbar:GetHeight()*DefOptions.BackgroundRYMult)
BGR:SetPoint("BOTTOMRIGHT", DR.statusbar, "BOTTOMRIGHT", DefOptions.BackgroundRX, -(DR.statusbar:GetHeight()*DefOptions.BackgroundRYMult))
BGR:SetWidth(DefOptions.BackgroundRWidth)
BGR:SetTexCoord(unpack(DefOptions.BackgroundRTexCoords))

local BGM = DR.statusbar:CreateTexture(nil, "BACKGROUND", nil, 0)
BGM:SetAtlas(DefOptions.BackgroundMiddleAtlas)
BGM:SetPoint("TOPLEFT", BGL, "TOPRIGHT", 0, 0)
BGM:SetPoint("BOTTOMRIGHT", BGR, "BOTTOMLEFT", 0, 0)

DR.statusbar.BGL = BGL
DR.statusbar.BGR = BGR
DR.statusbar.BGM = BGM

local Topper = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 3)
Topper:SetAtlas(DefOptions.TopperAtlas)
Topper:SetPoint("TOP", DR.statusbar, "TOP", unpack(DefOptions.TopperXY))
Topper:SetSize(unpack(DefOptions.TopperSize))

local Footer = DR.statusbar:CreateTexture(nil, "OVERLAY", nil, 3)
Footer:SetAtlas(DefOptions.FooterAtlas)
Footer:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", unpack(DefOptions.FooterXY))
Footer:SetSize(unpack(DefOptions.FooterSize))

DR.statusbar.Topper = Topper
DR.statusbar.Footer = Footer

DR.glide = DR.statusbar:CreateFontString(nil, nil, "GameTooltipText")
DR.glide:SetPoint("LEFT", DR.statusbar, "LEFT", 10, 0)

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
	if not LibAdvFlight.IsAdvFlyEnabled() and not DR.DriveUtils.IsDriving() then
		return;
	end

	local forwardSpeed = LibAdvFlight.GetForwardSpeed();
	if not LibAdvFlight.IsAdvFlyEnabled() then
		forwardSpeed = DR.DriveUtils.GetSmoothedSpeed()
	end
	local racing
	if C_Secrets and not C_Secrets.ShouldSpellCooldownBeSecret(DRAGON_RACE_AURA_ID) then
		racing = C_UnitAuras.GetPlayerAuraBySpellID(DRAGON_RACE_AURA_ID)
	end

	local THRESHOLD_HIGH;
	local THRESHOLD_LOW;
	local MIN_BAR_VALUE;
	local MAX_BAR_VALUE;

	if DR.DragonRidingZoneCheck() == true or racing then
		THRESHOLD_HIGH = 65;
		THRESHOLD_LOW = 60;
		MIN_BAR_VALUE = 0;
		MAX_BAR_VALUE = 100;
	elseif DR.DriveUtils.IsDriving() then
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
	
	local themeIndex = (DragonRider_DB and DragonRider_DB.themeSpeed) or 1
	local options = DR.SpeedometerOptions[themeIndex] and DR.SpeedometerOptions[themeIndex].Cover or DR.SpeedometerOptions[1].Cover
	local yOffset = options.TickYOffset or 0

	DR.statusbar.tick_1:ClearAllPoints()
	DR.statusbar.tick_2:ClearAllPoints()
	DR.statusbar.tick_1:SetPoint("TOP", DR.statusbar, "TOPLEFT", (THRESHOLD_HIGH / MAX_BAR_VALUE) * DR.statusbar:GetWidth(), yOffset)
	DR.statusbar.tick_2:SetPoint("TOP", DR.statusbar, "TOPLEFT", (THRESHOLD_LOW / MAX_BAR_VALUE) * DR.statusbar:GetWidth(), yOffset)

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
	if DR.DriveUtils.IsDriving() then
		text = format("|c%s%.0f%s|r", textColor:GenerateHexColor(), DR:convertUnits(forwardSpeed), DR.useUnits());
	end
	DR.glide:SetText(text);
	DR.statusbar:SetStatusBarColor(barColor.r, barColor.g, barColor.b, barColor.a);

	if DragonRider_DB.speedValUnits == 6 then
		DR.glide:SetText("")
	end
	DR.statusbar:SetSmoothedValue(forwardSpeed)
end

function DR.UpdateSpeedometerTheme()
	local themeIndex = (DragonRider_DB and DragonRider_DB.themeSpeed) or 1
	local themeData = DR.SpeedometerOptions[themeIndex] or DR.SpeedometerOptions[1]
	local options = themeData.Cover
	local barOptions = themeData.Bar
	local isMinimalist = (themeData.key == "Minimalist")

	DR.statusbar:SetWidth(DragonRider_DB.speedometerWidth or 244)
	DR.statusbar:SetHeight(DragonRider_DB.speedometerHeight or 24)

	if barOptions.BarTexture then
		DR.statusbar:SetStatusBarTexture(barOptions.BarTexture)
	else
		DR.statusbar:SetStatusBarTexture("Interface\\buttons\\white8x8")
	end
	
	local tickHeight = DR.statusbar:GetHeight() * (options.TickHeightMult or 1.0)
	local tickC = DragonRider_DB.speedBarColor.tick
	if options.TickAtlas then
		DR.statusbar.tick_1:SetTexture(nil)
		DR.statusbar.tick_2:SetTexture(nil)
		DR.statusbar.tick_1:SetAtlas(options.TickAtlas)
		DR.statusbar.tick_2:SetAtlas(options.TickAtlas)
		DR.statusbar.tick_1:SetWidth(options.Width or 17)
		DR.statusbar.tick_2:SetWidth(options.Width or 17)
		DR.statusbar.tick_1:SetHeight(tickHeight)
		DR.statusbar.tick_2:SetHeight(tickHeight)
		DR.statusbar.tick_1:SetTexCoord(unpack(options.TickTexCoords or {0,1,.19,.78}))
		DR.statusbar.tick_2:SetTexCoord(unpack(options.TickTexCoords or {0,1,.19,.78}))
		DR.statusbar.tick_1:SetVertexColor(tickC.r, tickC.g, tickC.b, tickC.a)
		DR.statusbar.tick_2:SetVertexColor(tickC.r, tickC.g, tickC.b, tickC.a)
		DR.statusbar.tick_1:SetDesaturated(options.TickDesat or false)
		DR.statusbar.tick_2:SetDesaturated(options.TickDesat or false)
	else
		DR.statusbar.tick_1:SetAtlas(nil)
		DR.statusbar.tick_2:SetAtlas(nil)
		DR.statusbar.tick_1:SetTexture("Interface\\buttons\\white8x8")
		DR.statusbar.tick_2:SetTexture("Interface\\buttons\\white8x8")
		DR.statusbar.tick_1:SetWidth(options.Width or 1)
		DR.statusbar.tick_2:SetWidth(options.Width or 1)
		DR.statusbar.tick_1:SetHeight(tickHeight)
		DR.statusbar.tick_2:SetHeight(tickHeight)
		DR.statusbar.tick_1:SetTexCoord(0, 1, 0, 1)
		DR.statusbar.tick_2:SetTexCoord(0, 1, 0, 1)
		DR.statusbar.tick_1:SetVertexColor(tickC.r, tickC.g, tickC.b, tickC.a)
		DR.statusbar.tick_2:SetVertexColor(tickC.r, tickC.g, tickC.b, tickC.a)
		DR.statusbar.tick_1:SetDesaturated(options.TickDesat or false)
		DR.statusbar.tick_2:SetDesaturated(options.TickDesat or false)
	end
	
	DR.statusbar.CoverL:ClearAllPoints()
	DR.statusbar.CoverR:ClearAllPoints()
	DR.statusbar.CoverM:ClearAllPoints()

	local coverLWidth = options.CoverLWidth or 0
	local coverRWidth = options.CoverRWidth or 0
	local coverLX = options.CoverLX or 0
	local coverLYMult = options.CoverLYMult or 0
	local coverRX = options.CoverRX or 0
	local coverRYMult = options.CoverRYMult or 0

	DR.statusbar.CoverL:SetPoint("TOPLEFT", DR.statusbar, "TOPLEFT", coverLX, DR.statusbar:GetHeight()*coverLYMult)
	DR.statusbar.CoverL:SetPoint("BOTTOMLEFT", DR.statusbar, "BOTTOMLEFT", coverLX, -(DR.statusbar:GetHeight()*coverLYMult))
	DR.statusbar.CoverL:SetWidth(coverLWidth)
	DR.statusbar.CoverL:SetTexCoord(unpack(options.CoverLTexCoords or {0,1,0,1}))

	DR.statusbar.CoverR:SetPoint("TOPRIGHT", DR.statusbar, "TOPRIGHT", coverRX, DR.statusbar:GetHeight()*coverRYMult)
	DR.statusbar.CoverR:SetPoint("BOTTOMRIGHT", DR.statusbar, "BOTTOMRIGHT", coverRX, -(DR.statusbar:GetHeight()*coverRYMult))
	DR.statusbar.CoverR:SetWidth(coverRWidth)
	DR.statusbar.CoverR:SetTexCoord(unpack(options.CoverRTexCoords or {0,1,0,1}))

	DR.statusbar.CoverM:SetPoint("TOPLEFT", DR.statusbar.CoverL, "TOPRIGHT", 0, 0)
	DR.statusbar.CoverM:SetPoint("BOTTOMRIGHT", DR.statusbar.CoverR, "BOTTOMLEFT", 0, 0)
	DR.statusbar.CoverM:SetTexCoord(unpack(options.CoverMTexCoords or {0,1,0,1}))

	DR.statusbar.CoverL:SetDesaturated(options.CoverDesat or false)
	DR.statusbar.CoverR:SetDesaturated(options.CoverDesat or false)
	DR.statusbar.CoverM:SetDesaturated(options.CoverDesat or false)

	local coverC = DragonRider_DB.speedBarColor.cover
	DR.statusbar.CoverL:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)
	DR.statusbar.CoverR:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)
	DR.statusbar.CoverM:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)

	DR.statusbar.borderTop:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)
	DR.statusbar.borderBottom:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)
	DR.statusbar.borderLeft:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)
	DR.statusbar.borderRight:SetVertexColor(coverC.r, coverC.g, coverC.b, coverC.a)

	if isMinimalist then
		DR.statusbar.borderTop:Show()
		DR.statusbar.borderBottom:Show()
		DR.statusbar.borderLeft:Show()
		DR.statusbar.borderRight:Show()
	else
		DR.statusbar.borderTop:Hide()
		DR.statusbar.borderBottom:Hide()
		DR.statusbar.borderLeft:Hide()
		DR.statusbar.borderRight:Hide()
	end

	if options.LeftAtlas then
		DR.statusbar.CoverL:SetAtlas(options.LeftAtlas)
	elseif options.LeftTexture then
		DR.statusbar.CoverL:SetTexture(options.LeftTexture)
	else
		DR.statusbar.CoverL:SetTexture(nil)
	end
	
	if options.RightAtlas then
		DR.statusbar.CoverR:SetAtlas(options.RightAtlas)
	elseif options.RightTexture then
		DR.statusbar.CoverR:SetTexture(options.RightTexture)
	else
		DR.statusbar.CoverR:SetTexture(nil)
	end

	if options.MiddleAtlas then
		DR.statusbar.CoverM:SetAtlas(options.MiddleAtlas)
	elseif options.MiddleTexture then
		DR.statusbar.CoverM:SetTexture(options.MiddleTexture)
	else
		DR.statusbar.CoverM:SetTexture(nil)
	end
	
	DR.statusbar.BGL:ClearAllPoints()
	DR.statusbar.BGR:ClearAllPoints()
	DR.statusbar.BGM:ClearAllPoints()
	
	local bgC = DragonRider_DB.speedBarColor.background
	DR.statusbar.BGL:SetVertexColor(bgC.r, bgC.g, bgC.b, bgC.a)
	DR.statusbar.BGR:SetVertexColor(bgC.r, bgC.g, bgC.b, bgC.a)
	DR.statusbar.BGM:SetVertexColor(bgC.r, bgC.g, bgC.b, bgC.a)

	local bgLWidth = options.BackgroundLWidth or 0
	local bgRWidth = options.BackgroundRWidth or 0
	local bgLX = options.BackgroundLX or 0
	local bgLYMult = options.BackgroundLYMult or 0
	local bgRX = options.BackgroundRX or 0
	local bgRYMult = options.BackgroundRYMult or 0

	DR.statusbar.BGL:SetPoint("TOPLEFT", DR.statusbar, "TOPLEFT", bgLX, DR.statusbar:GetHeight()*bgLYMult)
	DR.statusbar.BGL:SetPoint("BOTTOMLEFT", DR.statusbar, "BOTTOMLEFT", bgLX, -(DR.statusbar:GetHeight()*bgLYMult))
	DR.statusbar.BGL:SetWidth(bgLWidth)
	DR.statusbar.BGL:SetTexCoord(unpack(options.BackgroundLTexCoords or {0,1,0,1}))

	DR.statusbar.BGR:SetPoint("TOPRIGHT", DR.statusbar, "TOPRIGHT", bgRX, DR.statusbar:GetHeight()*bgRYMult)
	DR.statusbar.BGR:SetPoint("BOTTOMRIGHT", DR.statusbar, "BOTTOMRIGHT", bgRX, -(DR.statusbar:GetHeight()*bgRYMult))
	DR.statusbar.BGR:SetWidth(bgRWidth)
	DR.statusbar.BGR:SetTexCoord(unpack(options.BackgroundRTexCoords or {0,1,0,1}))

	DR.statusbar.BGM:SetPoint("TOPLEFT", DR.statusbar.BGL, "TOPRIGHT", 0, 0)
	DR.statusbar.BGM:SetPoint("BOTTOMRIGHT", DR.statusbar.BGR, "BOTTOMLEFT", 0, 0)
	DR.statusbar.BGM:SetTexCoord(unpack(options.BackgroundMTexCoords or {0,1,0,1}))

	DR.statusbar.BGL:SetDesaturated(options.BackgroundDesat or false)
	DR.statusbar.BGR:SetDesaturated(options.BackgroundDesat or false)
	DR.statusbar.BGM:SetDesaturated(options.BackgroundDesat or false)

	if options.BackgroundLeftAtlas then
		DR.statusbar.BGL:SetAtlas(options.BackgroundLeftAtlas)
	elseif options.BackgroundLeftTexture then
		DR.statusbar.BGL:SetTexture(options.BackgroundLeftTexture)
	else
		DR.statusbar.BGL:SetTexture("Interface\\buttons\\white8x8")
	end
	
	if options.BackgroundRightAtlas then
		DR.statusbar.BGR:SetAtlas(options.BackgroundRightAtlas)
	elseif options.BackgroundRightTexture then
		DR.statusbar.BGR:SetTexture(options.BackgroundRightTexture)
	else
		DR.statusbar.BGR:SetTexture("Interface\\buttons\\white8x8")
	end

	if options.BackgroundMiddleAtlas then
		DR.statusbar.BGM:SetAtlas(options.BackgroundMiddleAtlas)
	elseif options.BackgroundMiddleTexture then
		DR.statusbar.BGM:SetTexture(options.BackgroundMiddleTexture)
	else
		DR.statusbar.BGM:SetTexture("Interface\\buttons\\white8x8")
	end
	
	if not options.BackgroundLeftAtlas and not options.BackgroundLeftTexture then
		DR.statusbar.BGL:SetWidth(0)
		DR.statusbar.BGR:SetWidth(0)
		--DR.statusbar.BGM:SetAllPoints(DR.statusbar)
	end
	
	DR.statusbar.Topper:ClearAllPoints()
	DR.statusbar.Footer:ClearAllPoints()
	
	local topperXY = options.TopperXY or {0, 0}
	local topperSize = options.TopperSize or {0, 0}
	local footerXY = options.FooterXY or {0, 0}
	local footerSize = options.FooterSize or {0, 0}

	DR.statusbar.Topper:SetPoint("TOP", DR.statusbar, "TOP", unpack(topperXY))
	DR.statusbar.Topper:SetSize(unpack(topperSize))
	
	DR.statusbar.Footer:SetPoint("BOTTOM", DR.statusbar, "BOTTOM", unpack(footerXY))
	DR.statusbar.Footer:SetSize(unpack(footerSize))

	if options.TopperAtlas then
		DR.statusbar.Topper:SetAtlas(options.TopperAtlas)
	elseif options.TopperTexture then
		DR.statusbar.Topper:SetTexture(options.TopperTexture)
	else
		DR.statusbar.Topper:SetTexture(nil)
	end
	DR.statusbar.Topper:SetDesaturated(options.TopperDesat or false)
	local topperC = DragonRider_DB.speedBarColor.topper
	DR.statusbar.Topper:SetVertexColor(topperC.r, topperC.g, topperC.b, topperC.a)

	if not DragonRider_DB.toggleTopper then
		DR.statusbar.Topper:Hide()
	else
		DR.statusbar.Topper:Show()
	end

	if options.FooterAtlas then
		DR.statusbar.Footer:SetAtlas(options.FooterAtlas)
	elseif options.FooterTexture then
		DR.statusbar.Footer:SetTexture(options.FooterTexture)
	else
		DR.statusbar.Footer:SetTexture(nil)
	end
	DR.statusbar.Footer:SetDesaturated(options.FooterDesat or false)
	local footerC = DragonRider_DB.speedBarColor.footer
	DR.statusbar.Footer:SetVertexColor(footerC.r, footerC.g, footerC.b, footerC.a)
	
	if not DragonRider_DB.toggleFooter then
		DR.statusbar.Footer:Hide()
	else
		DR.statusbar.Footer:Show()
	end
end

---------------------------------------------------------------------------------------------------------------
-- Fade Animations
---------------------------------------------------------------------------------------------------------------

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
	if DR.IsEditMode or LibAdvFlight.IsAdvFlying() or DR.DriveUtils.IsDriving() then
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
	if not DragonRider_DB.toggleSpeedometer then 
		DR.statusbar:Hide()
		return 
	end
	DR.fadeInBarGroup:Stop(); -- Stop any ongoing animations
	DR.fadeInBarGroup:Play(); -- Play the fade in animation
end

-- Function to hide the frame with a fade out animation
function DR.HideWithFadeBar()
	if DR.IsEditMode then return end
	
	if SettingsPanel:IsShown() then return end
	DR.fadeOutBarGroup:Stop(); -- Stop any ongoing animations
	DR.fadeOutBarGroup:Play(); -- Play the fade out animation
end