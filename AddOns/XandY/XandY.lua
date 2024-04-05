--[[
                                ----o----(||)----oo----(||)----o----

                                               X and Y

                                       v2.37 - 4th April 2024
                                Copyright (C) Taraezor / Chris Birch
                                         All Rights Reserved

                                ----o----(||)----oo----(||)----o----
]]

local addonName, ns = ...
local addonTitle = addonName

-- Brown Theme
ns.colour = {}
ns.colour.prefix	= "\124cFFD2691E"	-- X11Chocolate
ns.colour.highlight = "\124cFFF4A460"	-- X11SandyBrown
ns.colour.plaintext = "\124cFFDEB887"	-- X11BurlyWood
ns.colour.malachite	= "\124cFF0BDA51"
ns.colour.gold		= "\124cFFFED12A"

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

local mini = {}
local world = {}

local buildVersion = GetBuildInfo()
local _, _, buildVersion = find( buildVersion, "(%d+\.%d+)" )
buildVersion = tonumber( buildVersion )

local function round( num, places )
	if num < 0.0 then
		return ceil( (num * 10^places) - .5 ) / 10^places
	end
	return floor( num * 10^places + .5 ) / 10^places
end

local function FormattedXY( rawX, rawY )
	return format( "%." ..XandYDB.miniPrecision .."f", round( rawX, XandYDB.miniPrecision ) ),
			format( "%." ..XandYDB.miniPrecision .."f", round( rawY, XandYDB.miniPrecision ) )
end

local function printPC( message )
	if message then
		DEFAULT_CHAT_FRAME:AddMessage( ns.colour.prefix.. addonTitle.. ": ".. ns.colour.plaintext.. message.. "\124r" )
	end
end

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

--=======================================================================================================
--
--		MINIMAP TOOLTIP
--		===============
--
--=======================================================================================================

local function MiniMapTooltip()

	mini.isOwned = false
	if buildVersion >= 10 then
		if ( GameTooltip:IsOwned( MinimapCluster.ZoneTextButton ) ) then mini.isOwned = true end
	else
		if ( GameTooltip:IsOwned( MinimapZoneTextButton ) ) then mini.isOwned = true end
	end
	
	if mini.isOwned == true then
		if ( mini.xPlayer > 0 ) and ( mini.yPlayer > 0 ) then
		
			local xPlayerF, yPlayerF = FormattedXY( mini.xPlayer, mini.yPlayer )
			
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
			
			if mini.found > 0 then
				if ( mini.degrees >= 0 ) then
					_G[ "GameTooltipTextLeft".. mini.found ]:SetText( mini.playerBrace
							..xPlayerF ..":" ..yPlayerF ..") @ " ..mini.degrees .."°" )
				else
					_G[ "GameTooltipTextLeft".. mini.found ]:SetText( mini.playerBrace
							..xPlayerF ..":" ..yPlayerF ..")" )
				end
			else
				if ( mini.degrees >= 0 ) then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine( mini.playerBrace ..xPlayerF ..":" ..yPlayerF  ..") @ " ..mini.degrees .."°" )
				else
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine( mini.playerBrace ..xPlayerF ..":" ..yPlayerF  ..")" )
				end
				GameTooltip:Show()
			end
		end
	end
end

--=======================================================================================================
--
--		EVENT HANDLER
--		=============
--
--=======================================================================================================

local old_MinimapZoneTextButtonOnClick;		-- Filled on VARIABLES_LOADED event. Not sure if other AddOns would have set this

local function MinimapZoneTextButtonOnClick()
	-- Can only happen pre Dragonflight 10.0
	if old_MinimapZoneTextButtonOnClick then old_MinimapZoneTextButtonOnClick() end
	XandYDB.miniPrecision = ( XandYDB.miniPrecision < 3 ) and ( XandYDB.miniPrecision + 1 ) or 1
end

local function OnEventHandler( self, event, args )

	if ( event == "VARIABLES_LOADED" ) then
		if not XandYDB then XandYDB = {} end
		local miniPrecision = XandYDB.miniPrecision or 2
		local showMiniZoneText = XandYDB.showMiniZoneText or true
		XandYDB = {}
		XandYDB.miniPrecision = miniPrecision
		XandYDB.showMiniZoneText = showMiniZoneText

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
			-- DragonFlight repurposed the OnClick so it now can't be used
			old_MinimapZoneTextButtonOnClick = MinimapZoneTextButton:GetScript( "OnClick" )
			MinimapZoneTextButton:SetScript( "OnClick", MinimapZoneTextButtonOnClick )
		end
		GameTooltip:HookScript( "OnUpdate", MiniMapTooltip )
	end
end

local eventFrame = CreateFrame( "Frame" )
eventFrame:RegisterEvent( "VARIABLES_LOADED" )
eventFrame:SetScript( "OnEvent", OnEventHandler )

--=======================================================================================================
--
--		ONUPDATE HANDLER
--		================
--
--=======================================================================================================

local timeSinceLastUpdate, curTime = 0, 0

local function OnUpdate()

	curTime = GetTime()
	if curTime - timeSinceLastUpdate <= 0.2 then return end
	timeSinceLastUpdate = curTime

	mini.isVisible = false
	if buildVersion >= 10 then
		if MinimapCluster.ZoneTextButton:IsVisible() == true then mini.isVisible = true end
	else
		if MinimapZoneTextButton:IsVisible() == true then mini.isVisible = true end
	end
	
	if mini.isVisible == true then
		mini.zoneText = GetMinimapZoneText()
		mini.mapAreaInID = GetBestMapForUnit( "player" ) or 0
		if GetPlayerMapPosition( mini.mapAreaInID, "player" ) then
			mini.xPlayer, mini.yPlayer = GetPlayerMapPosition( mini.mapAreaInID, "player" ):GetXY()
		else
			mini.xPlayer, mini.yPlayer = 0, 0
		end
		mini.xPlayer, mini.yPlayer = ( mini.xPlayer or 0 ) * 100, ( mini.yPlayer or 0 ) * 100
		if ( mini.xPlayer == 0 ) and ( mini.yPlayer == 0 ) then
			MinimapZoneText:SetText( mini.zoneText )
		else
			mini.colourText = ""
			mini.degrees = round( ( ( GetPlayerFacing() or -1 ) * 180 / pi ), 0 )			
			if ( mini.degrees == 0 ) or ( mini.degrees == 90 ) or ( mini.degrees == 180 ) or ( mini.degrees == 270 )
									or ( mini.degrees == 360 ) then
				mini.colourText = ns.colour.prefix
			elseif ( mini.degrees == 45 ) or ( mini.degrees == 135 ) or ( mini.degrees == 225 ) or ( mini.degrees == 315 ) then
				mini.colourText = ns.colour.highlight
			end
			if XandYDB then
				if XandYDB.showMiniZoneText == true then
					mini.xPlayerF, mini.yPlayerF = FormattedXY( mini.xPlayer, mini.yPlayer )
					MinimapZoneText:SetText( mini.colourText.. "(".. mini.xPlayerF.. ":".. mini.yPlayerF.. ") ".. mini.zoneText )
				else
					MinimapZoneText:SetText( mini.zoneText )
				end
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
			world.playerCursor = L[ "Player" ] .." @ " ..ns.colour.malachite
									..format( "%.2f", world.xPlayer ) .."\124r:" ..ns.colour.malachite
									..format( "%.2f", world.yPlayer ) .."\124r"
			world.spaces = " "
		end		
		if ( world.xCursor > 0 ) and ( world.xCursor < 100 ) and ( world.yCursor > 0 ) and ( world.yCursor < 100 ) then
			world.playerCursor = world.playerCursor ..world.spaces ..L[ "Cursor" ] .." @ " ..ns.colour.malachite 
									..world.xCursor .."\124r:" ..ns.colour.malachite ..world.yCursor .."\124r"
		end

		if buildVersion >= 4 then
			if buildVersion >= 10 then
				world.currentTitle = WorldMapFrameTitleText:GetText()
			else
				world.currentTitle = WorldMapFrame.BorderFrame.TitleText:GetText()
			end
			world.currentTitle = gsub( world.currentTitle, L[ "Player" ] .." @ " ..ns.colour.malachite .."%d*%.*%d*\124r:" 
										..ns.colour.malachite .."%d*%.*%d*\124r", "" )
			world.currentTitle = gsub( world.currentTitle, L[ "Cursor" ] .." @ " ..ns.colour.malachite .."%d*%.*%d*\124r:"
										..ns.colour.malachite .."%d*%.*%d*\124r", "" )
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

--=======================================================================================================
--
--		MINIMAP ADDON COMPARTMENT  -- Blizzard only allow for Retail
--		=========================
--
--=======================================================================================================

function XandY_OnAddonCompartmentClick( addonName, buttonName )

	if buttonName == nil then return end
	
	if buttonName == "LeftButton" then
		XandYDB.miniPrecision = ( XandYDB.miniPrecision < 3 ) and ( XandYDB.miniPrecision + 1 ) or 1
		printPC( printPC( "Decimal places = " ..XandYDB.miniPrecision )	)
	elseif buttonName == "RightButton" then
		XandYDB.miniPrecision = ( XandYDB.miniPrecision > 1 ) and ( XandYDB.miniPrecision - 1 ) or 3
		printPC( printPC( "Decimal places = " ..XandYDB.miniPrecision )	)
	elseif buttonName == "MiddleButton" then
		XandYDB.showMiniZoneText = not XandYDB.showMiniZoneText
		printPC( "Coords in Minimap Zone Text = " ..( XandYDB.showMiniZoneText == true and "On" or "Off" ) )
	end
	
end

function XandY_OnAddonCompartmentEnter( ... )
	GameTooltip:SetOwner( DropDownList1, "ANCHOR_LEFT" )	
	GameTooltip:AddLine( ns.colour.prefix .."X and Y" )
	GameTooltip:AddLine( ns.colour.highlight .." " )
	GameTooltip:AddLine( ns.colour.highlight .."Mouse Left/Right: " ..ns.colour.plaintext .."Toggle precision" )
	GameTooltip:AddLine( ns.colour.highlight .."Mouse Middle: " ..ns.colour.plaintext .."Toggle Zone Text" )

	if ( mini.xPlayer > 0 ) and ( mini.yPlayer > 0 ) then
		mini.degrees = round( ( ( GetPlayerFacing() or -1 ) * 180 / pi ), 0 )	
		mini.xPlayerF, mini.yPlayerF = FormattedXY( mini.xPlayer, mini.yPlayer )
		mini.degrees = ( mini.degrees >= 0 ) and ( " @ " ..mini.degrees .."°" ) or ""		
		GameTooltip:AddLine( mini.colourText.. "(".. mini.xPlayerF.. ":".. mini.yPlayerF.. ")" ..mini.degrees )
	end
	
	GameTooltip:Show()
end

function XandY_OnAddonCompartmentLeave( ... )
	GameTooltip:Hide()
end

--=======================================================================================================
--
--		SLASH CHAT COMMANDS  -- All game versions
--		===================
--
--=======================================================================================================

SLASH_XandY1, SLASH_XandY2 = "/xandy", "/xy"

local function Slash( options )
	if (options == "?") or (options == "") then
		printPC( "Minimap Options: " )
		printPC( ns.colour.highlight .."/xy t" ..ns.colour.plaintext .." Toggle show/hide coords on zone text" )
		printPC( ns.colour.highlight .."/xy 1" ..ns.colour.plaintext .." Coords to one decimal place" )
		printPC( ns.colour.highlight .."/xy 2" ..ns.colour.plaintext .." Coords to two decimal places" )
		printPC( ns.colour.highlight .."/xy 3" ..ns.colour.plaintext .." Coords to three decimal places" )
		if buildVersion >= 10 then
			printPC( ns.colour.highlight .."Tip: Try the Minimap AddOn Menu (below the Calendar)" )
		end
	elseif options == "t" then
		XandYDB.showMiniZoneText = not XandYDB.showMiniZoneText
		printPC( "Coords in Minimap Zone Text = " ..( XandYDB.showMiniZoneText == true and "On" or "Off" ) )
	else
		if options == "1" then
			XandYDB.miniPrecision = 1
		elseif options == "2" then
			XandYDB.miniPrecision = 2
		elseif options == "3" then
			XandYDB.miniPrecision = 3
		end
		printPC( "Decimal places = " ..XandYDB.miniPrecision )
	end
end

SlashCmdList[ "XandY" ] = function( options ) Slash( options ) end