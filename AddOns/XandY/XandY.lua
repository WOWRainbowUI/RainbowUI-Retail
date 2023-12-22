--[[
                                ----o----(||)----oo----(||)----o----

                                               X and Y

                                     v2.32 - 27th November 2023
                                Copyright (C) Taraezor / Chris Birch

                                ----o----(||)----oo----(||)----o----
]]

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Localisations and Local Data
--		============================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local addonName, L = ...
local addonTitle = addonName

local date = date
local ceil = math.ceil
local floor = math.floor
local find = string.find
local format = string.format
local gsub = string.gsub
local len = string.len
local pi = math.pi
local sub = string.sub

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetMinimapZoneText = GetMinimapZoneText
local GetPlayerFacing = GetPlayerFacing
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition

local mini = { xPlayer = 0, yPlayer = 0 }
local world = { xPlayer = 0, yPlayer = 0, xCursor = 0, yCursor = 0 }

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Local Functions
--		===============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local function round( num, places )
	if num < 0.0 then
		return ceil( (num * 10^places) - .5 ) / 10^places
	end
	return floor( num * 10^places + .5 ) / 10^places
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Build / Version Setup
--		=====================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local buildVersion = GetBuildInfo()
local _, _, buildVersion = find( buildVersion, "(%d+\.%d+)" )
buildVersion = tonumber( buildVersion )

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Colour Printing - Brown Theme + Map Colours
--		===============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local pc_colour_Prefix		= "\124cFFD2691E"	-- X11Chocolate
local pc_colour_Highlight	= "\124cFFF4A460"	-- X11SandyBrown
local pc_colour_PlainText	= "\124cFFDEB887"	-- X11BurlyWood
local pc_colour_Malachite	= "\124cFF0BDA51"
local pc_colour_Gold		= "\124cFFFED12A"

local function printPC( message )
	if message then
		DEFAULT_CHAT_FRAME:AddMessage( pc_colour_Prefix.. addonTitle.. ": ".. pc_colour_PlainText.. message.. "\124r" )
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Language Localisation
--		=====================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local locale = GetLocale()

local L = {}
setmetatable( L, { __index = function( L, key) return key end } )

if locale == "deDE" then
	L["Player"] = "Spieler"
	L["Cursor"] = "Mauszeiger"
elseif locale == "esES" or locale == "esMX" then
	L["Player"] = "Jugador"
	L["Cursor"] = "Cursor"
elseif locale == "frFR" then
	L["Player"] = "Joueur"
	L["Cursor"] = "Le curseur"
elseif locale == "itIT" then
	L["Player"] = "Giocatore"
	L["Cursor"] = "Cursore"
elseif locale == "koKR" then
	L["Player"] = "플레이어"
	L["Cursor"] = "커서"
elseif locale == "ptBR" or locale == "ptPT" then
	L["Player"] = "Jogador"
	L["Cursor"] = "Cursor"
elseif locale == "ruRU" then
	L["Player"] = "игрок"
	L["Cursor"] = "Курсор"
elseif locale == "zhCN" then
	L["Player"] = "玩家"
	L["Cursor"] = "鼠标"
elseif locale == "zhTW" then
	L["Player"] = "玩家"
	L["Cursor"] = "滑鼠游標"
else
	local dm = date( "%d%m" )
	if sub( dm, 1, 2 ) == "19" and sub( dm, 3, 4 ) == "09" then
		L["Player"] = "Cap'n"
		L["Cursor"] = "Bilge Rats"
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		MiniMapTooltip
--		==============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local function MiniMapTooltip()

	mini.isOwned = false
	if buildVersion >= 10 then
		if ( GameTooltip:IsOwned( MinimapCluster.ZoneTextButton ) ) then mini.isOwned = true end
	else
		if ( GameTooltip:IsOwned( MinimapZoneTextButton ) ) then mini.isOwned = true end
	end
	
	if mini.isOwned == true then
		if ( mini.xPlayer > 0 ) and ( mini.yPlayer > 0 ) then
			mini.playerBrace = L["Player"].. " ("
			mini.length, mini.found = len( mini.playerBrace ), 0
			for i = GameTooltip:NumLines(), 2, -1 do
				mini.line = _G[ "GameTooltipTextLeft".. i ]:GetText()
				if mini.line ~= nil then
					if sub( mini.line, 1, mini.length ) == mini.playerBrace then
						mini.found = i
						break
					end
				end
			end
			
			mini.degrees = round( ( ( GetPlayerFacing() or -1 ) * 180 / pi ), 0 )	
			mini.coordsF = "%." ..( (XandYDB.miniDetail == 4) and 2 or XandYDB.miniDetail ) .."f"
			
			if mini.found > 0 then
				if ( mini.degrees >= 0 ) then
					_G[ "GameTooltipTextLeft".. mini.found ]:SetText( mini.playerBrace
							..format( mini.coordsF, round( mini.xPlayer, 2 ) ) ..":" 
							..format( mini.coordsF, round( mini.yPlayer, 2 ) ) ..") @ " ..mini.degrees .."°" )
				else
					_G[ "GameTooltipTextLeft".. mini.found ]:SetText( mini.playerBrace
							..format( mini.coordsF, round( mini.xPlayer, 2 ) ) ..":" 
							..format( mini.coordsF, round( mini.yPlayer, 2 ) ) ..")" )
				end
			else
				if ( mini.degrees >= 0 ) then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine( mini.playerBrace
							..format( mini.coordsF, round( mini.xPlayer, 2 ) ) ..":" 
							..format( mini.coordsF, round( mini.yPlayer, 2 ) ) ..") @ " ..mini.degrees .."°" )
				else
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine( mini.playerBrace
							..format( mini.coordsF, round( mini.xPlayer, 2 ) ) ..":" 
							..format( mini.coordsF, round( mini.yPlayer, 2 ) ) ..")" )
				end
				GameTooltip:Show()
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Event Handler
--		=============
--
--------------------------------------------------------------------------------------------------------------------------------------------

local old_MinimapZoneTextButtonOnClick;		-- Filled on VARIABLES_LOADED event. Not sure if other AddOns would have set this

local function MinimapZoneTextButtonOnClick()

	if old_MinimapZoneTextButtonOnClick then old_MinimapZoneTextButtonOnClick() end
	XandYDB.miniDetail = ( XandYDB.miniDetail < 4 ) and ( XandYDB.miniDetail + 1 ) or 1
end

local function OnEventHandler( self, event, args )

	if ( event == "VARIABLES_LOADED" ) then
		if not XandYDB then XandYDB = {} end
		local miniDetail = XandYDB.miniDetail or 1
		XandYDB = {}
		XandYDB.miniDetail = miniDetail

		if locale == "deDE" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-deDE" )
		elseif locale == "esES" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-esES" )
		elseif locale == "esMX" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-esMX" )
		elseif locale == "frFR" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-frFR" )
		elseif locale == "itIT" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-itIT" )
		elseif locale == "koKR" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-koKR" )
		elseif locale == "ptBR" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-ptBR" )
		elseif locale == "ptPT" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-ptPT" )
		elseif locale == "ruRU" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-ruRU" )
		elseif locale == "zhCN" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-zhCN" )
		elseif locale == "zhTW" then
			addonTitle = GetAddOnMetadata( "XandY", "Title-zhTW" )
		else
			addonTitle = GetAddOnMetadata( "XandY", "Title" )
		end

		if buildVersion < 10 then
			old_MinimapZoneTextButtonOnClick = MinimapZoneTextButton:GetScript( "OnClick" )
			MinimapZoneTextButton:SetScript( "OnClick", MinimapZoneTextButtonOnClick )
			-- Dragonflight - works but Blizzard now also trigger the World Map through here so...
			-- changing the precision with a simple click here now has annoying consequences
--			old_MinimapZoneTextButtonOnClick = MinimapCluster.ZoneTextButton:GetScript( "OnClick" )
--			MinimapCluster.ZoneTextButton:SetScript( "OnClick", MinimapZoneTextButtonOnClick )
		end
		GameTooltip:HookScript( "OnUpdate", MiniMapTooltip )
	end
end

local eventFrame = CreateFrame( "Frame" )
eventFrame:RegisterEvent( "VARIABLES_LOADED" )
eventFrame:SetScript( "OnEvent", OnEventHandler )

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		OnUpdate Handler
--		================
--
--------------------------------------------------------------------------------------------------------------------------------------------

local timeSinceLastUpdate, curTime, isVisible, minimapZoneText = 0, 0, false, ""

local function OnUpdate()

	curTime = GetTime()
	if curTime - timeSinceLastUpdate <= 0.2 then return end
	timeSinceLastUpdate = curTime

	isVisible = false
	if buildVersion >= 10 then
		if MinimapCluster.ZoneTextButton:IsVisible() == true then isVisible = true end
	else
		if MinimapZoneTextButton:IsVisible() == true then isVisible = true end
	end
	
	if isVisible == true then
		minimapZoneText = GetMinimapZoneText()
		mini.mapAreaInID = GetBestMapForUnit( "player" ) or 0
		if GetPlayerMapPosition( mini.mapAreaInID, "player" ) then
			mini.xPlayer, mini.yPlayer = GetPlayerMapPosition( mini.mapAreaInID, "player" ):GetXY()
		else
			mini.xPlayer, mini.yPlayer = 0, 0
		end
		mini.xPlayer, mini.yPlayer = ( mini.xPlayer or 0 ) * 100, ( mini.yPlayer or 0 ) * 100
		if ( mini.xPlayer == 0 ) and ( mini.yPlayer == 0 ) then
			MinimapZoneText:SetText( minimapZoneText )
		else
			mini.colourText = ""
			mini.degrees = round( ( ( GetPlayerFacing() or -1 ) * 180 / pi ), 0 )			
			if ( mini.degrees == 0 ) or ( mini.degrees == 90 ) or ( mini.degrees == 180 ) or ( mini.degrees == 270 )
									or ( mini.degrees == 360 ) then
				mini.colourText = pc_colour_Prefix
			elseif ( mini.degrees == 45 ) or ( mini.degrees == 135 ) or ( mini.degrees == 225 ) or ( mini.degrees == 315 ) then
				mini.colourText = pc_colour_Highlight
			end
			if ( XandYDB.miniDetail == 1 ) then
				MinimapZoneText:SetText( mini.colourText.. "(".. format( "%.1f", round( mini.xPlayer, 1 ) ).. ":".. 
							format( "%.1f", round( mini.yPlayer, 1 ) ).. ") ".. minimapZoneText )
			elseif ( XandYDB.miniDetail == 2 ) then
				MinimapZoneText:SetText( mini.colourText.. "(".. format( "%.2f", round( mini.xPlayer, 2 ) ).. ":".. 
							format( "%.2f", round( mini.yPlayer, 2 ) ).. ") ".. minimapZoneText )
			elseif ( XandYDB.miniDetail == 3 ) then
				MinimapZoneText:SetText( mini.colourText.. "(".. format( "%.3f", round( mini.xPlayer, 3 ) ).. ":".. 
							format( "%.3f", round( mini.yPlayer, 3 ) ).. ") ".. minimapZoneText )
			else
				MinimapZoneText:SetText( minimapZoneText )
			end
		end
	end

	if WorldMapFrame:IsVisible() == true then
		world.mapAreaLookID = WorldMapFrame:GetMapID() or 0
		if GetPlayerMapPosition( world.mapAreaLookID, "player" ) then
			world.xPlayer, world.yPlayer = GetPlayerMapPosition( world.mapAreaLookID, "player" ):GetXY()
		else
			world.xPlayer, world.yPlayer = 0, 0
		end
		world.xPlayer, world.yPlayer = round( ( world.xPlayer or 0 ) * 100, 2 ), round( ( world.yPlayer or 0 ) * 100, 2 )		
		world.xCursor, world.yCursor = WorldMapFrame:GetNormalizedCursorPosition()	
		world.xCursor, world.yCursor = round( world.xCursor * 100, 2 ), round( world.yCursor * 100, 2 )

		world.playerCursor, world.spaces = "", ""
		if ( world.xPlayer ~= 0 ) or ( world.yPlayer ~= 0 ) then
			world.playerCursor = L[ "Player" ] .." @ " ..pc_colour_Malachite
									..format( "%.2f", world.xPlayer ) .."\124r:" ..pc_colour_Malachite
									..format( "%.2f", world.yPlayer ) .."\124r"
			world.spaces = " "
		end		
		if ( world.xCursor > 0 ) and ( world.xCursor < 100 ) and ( world.yCursor > 0 ) and ( world.yCursor < 100 ) then
			world.playerCursor = world.playerCursor ..world.spaces ..L[ "Cursor" ] .." @ " ..pc_colour_Malachite 
									..world.xCursor .."\124r:" ..pc_colour_Malachite ..world.yCursor .."\124r"
		end

		if buildVersion >= 4 then
			if buildVersion >= 10 then
				world.currentTitle = WorldMapFrameTitleText:GetText()
			else
				world.currentTitle = WorldMapFrame.BorderFrame.TitleText:GetText()
			end
			world.currentTitle = gsub( world.currentTitle, L[ "Player" ] .." @ " ..pc_colour_Malachite .."%d*%.*%d*\124r:" 
										..pc_colour_Malachite .."%d*%.*%d*\124r", "" )
			world.currentTitle = gsub( world.currentTitle, L[ "Cursor" ] .." @ " ..pc_colour_Malachite .."%d*%.*%d*\124r:"
										..pc_colour_Malachite .."%d*%.*%d*\124r", "" )
			world.currentTitle = strtrim( world.currentTitle )
			world.currentTitle = world.currentTitle .."                " ..world.playerCursor
			if buildVersion < 10 then
				WorldMapFrame.BorderFrame.TitleText:SetText( world.currentTitle )
			else
				WorldMapFrameTitleText:SetText( world.currentTitle )
			end
			
		else			
			XandYCoords:SetText( world.playerCursor )
			world.offset = ( ( WorldMapFrame:GetHeight() / 2 ) - 16 ) * -1				
			XandYCoords:SetPoint( "CENTER", WorldMapFrame, "CENTER", 0, world.offset ) -- Used to be -216 always
		end
	end
end

eventFrame:SetScript( "OnUpdate", OnUpdate )

--------------------------------------------------------------------------------------------------------------------------------------------
--
--		Slash Chat Commands
--		===================
--
--------------------------------------------------------------------------------------------------------------------------------------------

SLASH_XandY1, SLASH_XandY2 = "/xandy", "/xy"

local function Slash( options )
	if (options == "?") or (options == "") then
		printPC( "Options: " )
		printPC( pc_colour_Highlight .."/xy 0" ..pc_colour_PlainText .." NO minimap zone text" )
		printPC( pc_colour_Highlight .."/xy 1" ..pc_colour_PlainText .." Coords to one decimal place" )
		printPC( pc_colour_Highlight .."/xy 2" ..pc_colour_PlainText .." Coords to two decimal places" )
		printPC( pc_colour_Highlight .."/xy 3" ..pc_colour_PlainText .." Coords to three decimal places" )
	elseif options == "0" then
		XandYDB.miniDetail = 4
	elseif options == "1" then
		XandYDB.miniDetail = 1
	elseif options == "2" then
		XandYDB.miniDetail = 2
	elseif options == "3" then
		XandYDB.miniDetail = 3
	end
end

SlashCmdList[ "XandY" ] = function( options ) Slash( options ) end