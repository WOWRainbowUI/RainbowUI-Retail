local DRS = CreateFrame( "Frame", nil, UIParent, "TooltipBorderedFrameTemplate" )
DRS.myPools = CreateFramePoolCollection()
local defDebugPrintID = false

DRS:SetShown( false )

local blacklistedCreatures = {--[[135181, ]]--[[138694,]] 202676, 202524, 202973, 202795, 202749, 202772, 200183, 200212, 200316, 200417, 200236, 200247, 198838, 199613, 199612, 189497, 194348, 192555, 193651, 193951, 194372, 193911, 191947, 192115, 193027, 192886, 191572, 192945, 191165, 191247, 190118, 191511, 196092, 186993, 186992, 191422, 190928, 191121, 190667, 190551, 190519, 190503, 190473, 190123, 190326, 190753, 151787, 152671, 152729, 152736, 153088, 172925, 174967, 174998, 174962, 174970, 175196, 176145, 158405, 176285, 176287, 176288, 164102, 181397, 180978, 198464 }

local blacklistedZonesForSounds = {
	1525,--Revendreth
	1533,--Bastion
	1536,--Maldraxxus
	1543,--The Maw
	1565,--Ardenweald
	1961,--Korthia
	2022,--The Waking Shores
	2023,--Ohn'ahran Plains
	2024,--The Azure Span
	2025,--Thaldraszus
}
local warCrateCreatures = {135181, 135238}
local warCrateGameObjects = {}
local blacklistedObjects = { 388517, 381219, 350083, 370466, 370467, 375543, 373568, 383732 }

local nestsMushroomsInKorthia = { 369327, 369329, 369330, 369331, 369332, 369333, 369334, 369335, 369336, 369337
}

for i = 1, #nestsMushroomsInKorthia do
	tinsert( blacklistedObjects, nestsMushroomsInKorthia[i])
end

local rareTable = {}
local lookupTable = {}
local _
local tempTable = {}

local sqrt2 = sqrt( 2 )
local rads45 = 0.25 * ( math.pi )
local rads135 = 0.75 * ( math.pi )
local rads225 = 1.25 * ( math.pi ) 
local cos, sin = math.cos, math.sin

local zoneTable = { --emote, yell, nameplate, health, vignette, zoneRestriction450,creatureOnlySounds = strsplit( "\a", zoneTable[uiMapID] )
	[14] = "\a\a\a\a1\a",--Arathi Highlands
	[62] = "\a\a\a\a1\a",--Darkshore
	[525] = "\a\a\a\a1\a",--Frostfire Ridge
	[534] = "\a\a\a\a1\a",--Tanaan Jungle
	[535] = "\a\a\a\a1\a",--Talador
	[539] = "\a\a\a\a1\a",--Shadowmoon Valley
	[542] = "\a\a\a\a1\a",--Spires of Arak
	[543] = "\a\a\a\a1\a",--Gorgrond
	[550] = "\a\a\a\a1\a",--Nagrand
	[630] = "\a\a\a\a1\a",--Azsuna
	[634] = "\a\a\a\a1\a",--Stormheim
	[641] = "\a\a\a\a1\a",--Val'sharah
	[646] = "\a\a\a\a1\a",--Broken Shore
	[650] = "\a\a\a\a1\a",--Highmountain
	[680] = "\a\a\a\a1\a",--Suramar
	[830] = "\a\a\a\a1\a",--Krokuun (Argus)
	[862] = "\a\a\a\a1\a",--Zuldazar
	[863] = "\a\a\a\a1\a",--Nazmir
	[864] = "\a\a\a\a1\a",--Vul'dun
	[882] = "\a\a\a\a1\a",--Mac'Aree (Argus)
	[885] = "\a\a\a\a1\a",--Antoran Wastes (Argus)
	[895] = "\a\a\a\a1\a",--Tiragarde Sound
	[896] = "\a\a\a\a1\a",--Drustvar
	[942] = "\a\a\a\a1\a",--Stormsong Valley
	[1355] = "1\a1\a1\a1\a1\a",--Nazjatar
	[1462] = "1\a1\a1\a1\a1\a",--Mechagon Island
	[1525] = "\a\a\a\a1\a1",--Revendreth
	[1527] = "\a\a1\a\a1\a",--Uldum
	[1530] = "\a\a1\a\a1\a",--Vale of Eternal Blossoms
	[1533] = "\a\a\a\a1\a1",--Bastion
	[1536] = "\a\a\a\a1\a1",--Maldraxxus
	[1543] = "\a\a\a\a1",--The Maw
	[1970] = "\a\a\a\a1\a",--Zereth Mortis
	[1565] = "\a\a\a\a1\a1",--Ardenweald
	[1961] = "\a\a\a\a1",--Korthia
	[2022] = "\a\a\a\a1",--The Waking Shores
	[2023] = "\a\a\a\a1",--Ohn'ahran Plains
	[2024] = "\a\a\a\a1",--The Azure Span
	[2025] = "\a\a\a\a1",--Thaldraszus
	[2133] = "\a\a\a\a1",--Zaralek Caverns
	[2151] = "\a\a\a\a1",--The Forbidden Reach
}


local namePlateScanMounts = {-- [npcID] = mount spellID, itemID (if required or nil if not), chat window message
	[65090] = "300150\a\a122674\aTake Selfie with Fabious for mount.", -- Fabious
	[162681] = "316493\a161128\a\aFeed Seaside Leafy Greens Mix to Elusive Quickhoof for mount.", --Elusive Quickhoof
	}
local mountIDs

local function corner(r)
	return 0.5+cos(r)/sqrt2, 0.5+sin(r)/sqrt2
end

local function MakeAlertFrame( guid )
	local f = CreateFrame( "Button", nil, UIParent, "TooltipBorderedFrameTemplate" )
	f.unitguid = guid
	f:SetPoint( "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -260, 450 )
	f:SetSize(200, 60)
	f:SetShown( false )
	f:EnableMouse( true )
	f:RegisterForClicks("AnyUp", "AnyDown")
	f:HookScript( "OnClick", function( self, button, down )
		if ( button == "RightButton" ) then
			rareTable[self.unitguid].donotshow = true
			local x = self.unitguid
			C_Timer.After( 300, function()
				rareTable[x] = nil
			end )
			self:Hide()
			self.unitguid = nil
			for i = 1, 10 do
				if not DRS["AlertFrame"..i] then
					return
				elseif DRS["AlertFrame"..i] and not DRS["AlertFrame"..i]:IsShown() and DRS["AlertFrame"..( i + 1 )] and DRS["AlertFrame"..( i + 1 )].unitguid then
					local x = DRS["AlertFrame"..( i + 1 )].unitguid
					DRS["AlertFrame"..( i + 1 )]:Hide()
					DRS["AlertFrame"..( i + 1 )].unitguid = nil
					DRS["AlertFrame"..i]:Hide()
					DRS["AlertFrame"..i].unitguid = x
					DRS["AlertFrame"..i]:Show()
				end
			end
		end
	end )
	f.fs =  f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f.fs:SetPoint( "CENTER", -15, 10 )
	f.fs:SetText( rareTable[guid].unitname or "戴夫的稀有狩獵旅" )
	--f.fs2 =  f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	--f.fs2:SetPoint( "CENTER", -20, 0 )
	--f.fs3 =  f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	--f.fs3:SetPoint( "CENTER", -20, -15 )
	f.fs4 =  f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f.fs4:SetTextColor( 1, 1, 1 )
	--f.fs4:SetPoint( "BOTTOMRIGHT", -5, 5 )
	f.fs4:SetPoint( "CENTER", -15, -10 )
	f:HookScript( "OnShow", function( self )
		--self.fs3:Hide()
		if self.unitguid then
			if rareTable[self.unitguid] and rareTable[self.unitguid].unitname then
				self.fs:SetText( rareTable[self.unitguid].unitname )
			else
				self.fs:SetText( "戴夫的稀有狩獵旅" )
			end
			if ( strlenutf8( self.fs:GetText() or "?" ) > 20 ) then
				self:SetWidth( 200 + ( ( strlenutf8( self.fs:GetText() ) - 20 ) * 4 ) )
			else
				self:SetWidth( 200 )
			end
			self.uiMapID = C_Map.GetBestMapForUnit( "player" )
			if self.uiMapID then
				local position = C_Map.GetPlayerMapPosition( self.uiMapID, "player" )
				if rareTable[self.unitguid].x and rareTable[self.unitguid].y and position and position.x and position.y then
					self.Arrow:Show()
				else
					self.Arrow:Hide()
					--self.fs2:Hide()
					self.fs4:Hide()
				end
			else
				self.Arrow:Hide()
				--self.fs2:Hide()
				self.fs4:Hide()
			end
		end
	end )
	f:SetScript( "OnHide", function ( self )
		self.unitguid = nil
	end )
	f.Arrow = CreateFrame( "Frame", nil, f )
	f.Arrow:SetPoint( "RIGHT", f, "RIGHT", 0, 0 )
	f.Arrow:SetSize( 50, 50 )
	f.Arrow.texture = f.Arrow:CreateTexture( nil,"OVERLAY" )
	f.Arrow.texture:SetAllPoints( true )
	f.Arrow.texture:SetTexture( "Interface\\AddOns\\Defs-Rare-Safari\\media\\arrow.tga" )
	f:HookScript( "OnUpdate", function( self, elapsed )
		self.TimeSinceLastUpdate = ( ( self.TimeSinceLastUpdate or 0 ) + elapsed )
		if ( self.TimeSinceLastUpdate > .05 ) then
			self.TimeSinceLastUpdate = 0
			if self.unitguid and rareTable[self.unitguid] and rareTable[self.unitguid].nameplate then
				--self.fs2:Hide()
				self.fs4:Hide()
				self.Arrow:Hide()
			elseif self.unitguid and rareTable[self.unitguid] and rareTable[self.unitguid].x and rareTable[self.unitguid].y then
				local position = C_Map.GetPlayerMapPosition( self.uiMapID, "player" )
				if position and position.x and position.y then
					local player = GetPlayerFacing()
					if not player then
						return
					end
					local dy = -rareTable[self.unitguid].y + position.y
					local dx = rareTable[self.unitguid].x - position.x
					local angle = math.rad( atan2( dy, dx ) ) - ( math.pi / 2 ) - player
					local ULx,ULy = corner( angle + rads225 )
					local LLx,LLy = corner( angle + rads135 )
					local URx,URy = corner( angle - rads45 )
					local LRx,LRy = corner( angle + rads45 )
					self.Arrow.texture:SetTexCoord( ULx, ULy, LLx, LLy, URx, URy, LRx, LRy ) -- https://wow.gamepedia.com/Applying_affine_transformations_using_SetTexCoord
					local playerContinentID, playerWorldPosition = C_Map.GetWorldPosFromMapPos( self.uiMapID, CreateVector2D( position.x, position.y ) )
					local targetContinentID, targetWorldPosition = C_Map.GetWorldPosFromMapPos( self.uiMapID, CreateVector2D(rareTable[self.unitguid].x, rareTable[self.unitguid].y ) )
					local distance
					if ( playerContinentID == targetContinentID ) then
						local x = abs( playerWorldPosition.x - targetWorldPosition.x )
						local y = abs( playerWorldPosition.y - targetWorldPosition.y )
						distance = sqrt( ( x * x ) + ( y * y ) )
						distance = floor( distance )
						--if ( rareTable[defGUID].unittype == "GameObject" ) and ( distance > 300 ) then
						--end
						self.fs4:SetText( distance )
						self.fs4:Show()
					else
						self.fs4:Hide()
					end
					if ( distance <= 40 ) then
						self.Arrow.texture:SetVertexColor( 0, 1, 0 )
					elseif ( distance <= 200 ) then
						self.Arrow.texture:SetVertexColor( 1, 1, 1 )
					else
						self.Arrow.texture:SetVertexColor( 1, 0, 0 )
					end
					if rareTable[self.unitguid].lastseen then
						local timeDifference = GetServerTime() - rareTable[self.unitguid].lastseen
						--self.fs2:SetText( SecondsToTime( timeDifference ) )
						--self.fs2:Show()
					else
						--self.fs2:Hide()
					end
					self.Arrow:Show()
				else
					self:Hide()
				end
			else
				self:Hide()
			end
		end
	end )
	f:Show()
	return f
end

local soundThrottleTime = 0
local function PlaySoundAlert( creatureOnlySounds )
	--[[local uiMapID = C_Map.GetBestMapForUnit( "player" )
	if uiMapID and ( uiMapID == 1970 ) then
		for i = 1, #blacklistedZonesForSounds do
			if ( uiMapID == blacklistedZonesForSounds[i] ) then
				return
			end
		end
	end
	if UnitOnTaxi( "player" ) then
		return
	end
	local timestamp = GetServerTime()
	if ((timestamp - soundThrottleTime) >= 10) then
		soundThrottleTime = timestamp
		PlaySound(18192)
	end]]
	--[[local uiMapID = C_Map.GetBestMapForUnit( "player" )
	if uiMapID then
		for i = 1, #blacklistedZonesForSounds do
			if ( uiMapID == blacklistedZonesForSounds[i] ) then
				return
			end
		end
	end
	if UnitOnTaxi( "player" ) then
		return
	end
	local timestamp = GetServerTime()
	if ((timestamp - soundThrottleTime) >= 10) then
		soundThrottleTime = timestamp
		PlaySound(18192)
	end]]
end

local function AcquireAlertFrame( guid )
	if rareTable[guid].donotshow then
		return
	end
	for i = 1, 10 do
		if not DRS["AlertFrame"..i] then
			break
		elseif DRS["AlertFrame"..i] and DRS["AlertFrame"..i].unitguid and (DRS["AlertFrame"..i].unitguid == guid ) then
			return
		end
	end
	local maxFrames = 5
	if ( GetScreenHeight() >= 1200 ) then
		maxFrames = 10
	end
	for i = 1, maxFrames do
		if not DRS["AlertFrame"..i] then
			PlaySoundAlert()
			DRS["AlertFrame"..i] = MakeAlertFrame( guid )
			if ( i == 1 ) then
				DRS.AlertFrame1:SetClampedToScreen( true )
				DRS.AlertFrame1:SetMovable( true )
				DRS.AlertFrame1:SetScript( "OnMouseDown", function( self )
					self:StartMoving()
				end )
				DRS.AlertFrame1:SetScript( "OnMouseUp", 	function( self )
					self:StopMovingOrSizing()
					local _
					DRSa["getpoint1"], _, DRSa["getpoint2"], DRSa["getpoint3"], DRSa["getpoint4"] = DRS.AlertFrame1:GetPoint( 1 )
				end )
				if DRSa["getpoint1"] and DRSa["getpoint2"] and DRSa["getpoint3"] and DRSa["getpoint4"] then
					DRS.AlertFrame1:ClearAllPoints()
					DRS.AlertFrame1:SetPoint(DRSa["getpoint1"] or "BOTTOMRIGHT", UIParent,  DRSa["getpoint2"] or "BOTTOMRIGHT", DRSa["getpoint3"] or -260, DRSa["getpoint4"] or 450)
				end
			else
				local x = i - 1
				DRS["AlertFrame"..i]:ClearAllPoints()
				DRS["AlertFrame"..i]:SetPoint( "BOTTOM", DRS["AlertFrame"..x], "TOP", 0, 0 )
			end
			return
		elseif not DRS["AlertFrame"..i]:IsShown() then
			PlaySoundAlert()
			DRS["AlertFrame"..i].unitguid = guid
			DRS["AlertFrame"..i]:Show()
			return
		end
	end
end

local function RemoveAlertFrame(guid)
	for i = 1, 10 do
		if not DRS["AlertFrame"..i] then
			return
		elseif DRS["AlertFrame"..i] and not DRS["AlertFrame"..i]:IsShown() and DRS["AlertFrame"..(i + 1)] and DRS["AlertFrame"..(i + 1)].unitguid then
			local x = DRS["AlertFrame"..(i + 1)].unitguid
			DRS["AlertFrame"..(i + 1)]:Hide()
			DRS["AlertFrame"..(i + 1)].unitguid = nil
			DRS["AlertFrame"..i]:Hide()
			DRS["AlertFrame"..i].unitguid = x
			DRS["AlertFrame"..i]:Show()
		else
			if DRS["AlertFrame"..i].unitguid and (DRS["AlertFrame"..i].unitguid == guid) then
				if DRS["AlertFrame"..(i + 1)] and DRS["AlertFrame"..(i + 1)].unitguid then
					local x = DRS["AlertFrame"..(i + 1)].unitguid
					DRS["AlertFrame"..(i + 1)]:Hide()
					DRS["AlertFrame"..(i + 1)].unitguid = nil
					DRS["AlertFrame"..i]:Hide()
					DRS["AlertFrame"..i].unitguid = x
					DRS["AlertFrame"..i]:Show()		
				else
					DRS["AlertFrame"..i]:Hide()
					DRS["AlertFrame"..i].unitguid = nil
				end
			end
		end
	end
end

local function RemoveAllAlertFrames()
	for i = 10, 1, (-1) do
		if DRS["AlertFrame"..i] then
			DRS["AlertFrame"..i]:Hide()
			DRS["AlertFrame"..i].unitguid = nil
		end
	end
	rareTable = {}
end

local function RemoveNamePlate(unitToken)
	for k in pairs(rareTable) do
		if rareTable[k].nameplate and (rareTable[k].nameplate == unitToken) then
			--print("RemoveNamePlate")
			if rareTable[k].vignette then
				--print("RemoveNamePlate1")
				local function delayedRemoval(arg1)
					if arg1 then
						arg1.nameplate = nil
					end
				end
				C_Timer.After(6, function() delayedRemoval(rareTable[k]) end)
				break
			else
				--SendAddonMessageToPartyGuild(k, true)
				RemoveAlertFrame(k)
				--print("RemoveNamePlate2")
				rareTable[k] = nil
				break
			end
		end
	end
end

local npcIDToQuestID = {
	-- Mechagon
	[151934] = "55512\a0.52\a0.40", -- Arachnoid Harvester
	[150394] = "55546\a0.48\a0.45", -- Armored Vaultbot
	[151308] = "55539\a0.53\a0.31", -- Boggac Skullbash
	[153200] = "55857\a0.51\a0.50\aBoilburn", -- Boilburn
	[152001] = "55537\a0.65\a0.27", -- Bonepicker
	[154739] = "56368\a0.66\a0.58\aCaustic Mechaslime", -- Caustic Mechaslime
	[152570] = "55812\a0.82\a0.20", -- Crazed Trogg
	[151569] = "55514", -- Deepwater Maw
	[150342] = "55814\a0.63\a0.25\aEarthbreaker Gulroc", -- Earthbreaker Gulroc
	[154153] = "56207", -- Enforcer KX-T57
	[151202] = "55513\a0.65\a0.51", -- Foul Manifestation
	[151884] = "55367", -- Fungarian Furor
	[153228] = "55852", -- Gear Checker Cogstar (spawns randomly)
	[153205] = "55855\a0.59\a0.67\aGemicide", -- Gemicide
	[154701] = "56367\a0.72\a0.53\aGorged Gear-Cruncher", -- Gorged Gear-Cruncher
	[151684] = "55399", -- Jawbreaker
	[152007] = "55369\a0.42\a0.40", -- Killsaw
	[151933] = "55544\a0.60\a0.42", -- Malfunctioning Beastbot
	[151124] = "55207\a0.57\a0.52", -- Mechagonian Nullifier
	[151672] = "55386", -- Mecharantula
	[151627] = "55859\a0.60\a0.60", -- Mr. Fixthis
	[153206] = "55853\a0.56\a0.36\aOl' Big Tusk", -- Ol' Big Tusk
	[151296] = "55515\a0.56\a0.39", -- OOX-Avenger/MG
	[152764] = "55856\a0.57\a0.62", -- Oxidized Leachbeast
	[151702] = "55405", -- Paol Pondwader
	[150575] = "55368", -- Rumblerocks
	[152182] = "55811", -- Rustfeather
	[155583] = "56737", -- Scrapclaw
	[150937] = "55545\a0.19\a0.80", -- Seaspit
	[153000] = "55810\a0.83\a0.21", -- Sparkqueen P'Emp
	[153226] = "55854\a0.25\a0.77", -- Steel Singer Freza
	[155060] = "56419\a0.80\a0.20", -- The Doppel Gang
	[152113] = "55858\a0.68\a0.48\aThe Kleptoboss", -- The Kleptoboss
	[154225] = "56182\a0.55\a0.60", -- The Rusty Prince
	[151625] = "55364\a0.72\a0.50", -- The Scrap King
	[151940] = "55538\a0.59\a0.24", -- Uncle T'Rogg
	[150394] = "55546\a0.57\a0.48", -- Vaultbot
	-- Nazjatar
	[152323] = "55671\a0.29\a0.28", -- King Gakula
	}

local YellsToNpcID = {
	-- Mechagon
	["Arachnoid Harvester"] = 151934,
	["Boggac Skullbash"] = 151308,
	["Gear Checker Cogstar"] = 153228,
	["Mechagonian Nullifier"] = 151124,
	["OOX-Avenger/MG"] = 151296,
	["Razak Ironsides"] = 153000,
	["Seaspit"] = 150937,
	["The Rusty Prince"] = 154225,
	["The Scrap King"] = 151625,
	["Uncle T'Rogg"] = 151940,
	-- Nazjatar
	["King Gakula"] = 152323,
}
	
local EmotesToNpcID = {
	--Mechagon
	["TR28"] = 153206, -- Ol' Big Tusk
	["TR35"] = 150342, -- Earthbreaker Gulroc
	["CC61"] = 154701, -- Gorged Gear-Cruncher
	["CC73"] = 154739, -- Caustic Mechaslime
	["CC88"] = 152113, -- The Kleptoboss
	["JD41"] = 153200, -- Boilburn
	["JD99"] = 153205, -- Gemicide
}
	
--[[/run for k,v in pairs({Arachnoid=55512,Rustfeather=55811,Soundless=56298}) do print(format("%s: %s", k, C_QuestLog.IsQuestFlaggedCompleted(v) and "\124cFFFF0000Completed\124r" or "\124cFF00FF00Not Completed\124r")) end
]]--/dump C_QuestLog.IsQuestFlaggedCompleted(55811)
local function ChatEmote(...)
	local uiMapID = C_Map.GetBestMapForUnit("player")
	if uiMapID and (uiMapID == 1462) then
		local message, playerName = ...
		if playerName and (playerName == "Drill Rig") then
			for k,v in pairs(EmotesToNpcID) do
				if strfind(message, k) then
					for i in pairs(rareTable) do
						local type, npcID = strsplit("\a", i)
						if (type == "Creature") and (npcID == v) then -- exit out if npcID already in rareTable
							return
						end
					end
					local questID, x, y, name = strsplit("\a",npcIDToQuestID[v])
					if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
						local fakeGUID = strjoin("\a","Creature",v)
						if rareTable[fakeGUID] and rareTable[fakeGUID].donotshow then
							return
						elseif not rareTable[fakeGUID] or not rareTable[fakeGUID].nameplate and not rareTable[fakeGUID].vignette then
							rareTable[fakeGUID] = rareTable[fakeGUID] or {}
							rareTable[fakeGUID].unitname = name
							rareTable[fakeGUID].unittype = "Creature"
							rareTable[fakeGUID].emote = true
							rareTable[fakeGUID].lastseen = GetServerTime()
							rareTable[fakeGUID].x = x
							rareTable[fakeGUID].y = y
							AcquireAlertFrame(fakeGUID)
							--SendAddonMessageToPartyGuild(fakeGUID)
							C_Timer.After(80,
								function()
									if rareTable[fakeGUID] and rareTable[fakeGUID].emote then
										RemoveAlertFrame(fakeGUID)
										rareTable[fakeGUID] = nil
									end
								end)
							return
						end
					end
				end
			end
		end
	end
end

local function ChatYell(...)
	local uiMapID = C_Map.GetBestMapForUnit("player")
	if uiMapID and (uiMapID == 1462) then
		local _, playerName = ...
		if playerName then
			--print(playerName)
			for k,v in pairs(YellsToNpcID) do
				if (playerName == k) then
					for i in pairs(rareTable) do
						local type, npcID = strsplit("\a", i)
						if (type == "Creature") and (npcID == v) then -- exit out if npcID already in rareTable
							return
						end
					end
					local questID, x, y = strsplit("\a",npcIDToQuestID[v])
					if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
						local fakeGUID = strjoin("\a","Creature",v)
						if rareTable[fakeGUID] and rareTable[fakeGUID].donotshow then
							return
						elseif not rareTable[fakeGUID] or not rareTable[fakeGUID].nameplate and not rareTable[fakeGUID].vignette then
							rareTable[fakeGUID] = rareTable[fakeGUID] or {}
							rareTable[fakeGUID].unitname = playerName
							if (playerName == "Razak Ironsides") then
								rareTable[fakeGUID].unitname = "Sparkqueen P'Emp"
							end
							rareTable[fakeGUID].yell = true
							rareTable[fakeGUID].unittype = "Creature"
							rareTable[fakeGUID].lastseen = GetServerTime()
							rareTable[fakeGUID].x = x
							rareTable[fakeGUID].y = y
							AcquireAlertFrame(fakeGUID)
							--SendAddonMessageToPartyGuild(fakeGUID)
							C_Timer.After(65,
								function()
									if rareTable[fakeGUID] and rareTable[fakeGUID].yell then
										RemoveAlertFrame(fakeGUID)
										rareTable[fakeGUID] = nil
									end
								end)
							return
						end
					end
				end
			end
		end
	end
end

local function NamePlateHealth(unitTarget)
	for i = 1, 10 do
		if not DRS["AlertFrame"..i] then
			break
		elseif DRS["AlertFrame"..i]:IsShown() and DRS["AlertFrame"..i].unitguid and (rareTable[DRS["AlertFrame"..i].unitguid].nameplate == unitTarget) then
			rareTable[DRS["AlertFrame"..i].unitguid].health = floor((UnitHealth(unitTarget) / UnitHealthMax(unitTarget)) * 100)
			DRS["AlertFrame"..i].fs3:SetText(rareTable[DRS["AlertFrame"..i].unitguid].health.." %")
			
			DRS["AlertFrame"..i].fs3:Show()
			--SendAddonMessageToPartyGuild(DRS["AlertFrame"..i].unitguid)
			return
		end
	end
	if (unitTarget == "target") then
		local guid = UnitGUID("target")
		local type, _, _, _, _, npcID = strsplit("-", guid)
		if (type == "Vehicle") and (npcID == "151623") then -- The Scrap King
			type = "Creature"
			npcID = "151625"
		end
		if (type == "Creature") then
			local defGUID = strjoin("\a",type,npcID)
			for i = 1, 10 do
				if not DRS["AlertFrame"..i] then
					break
				elseif DRS["AlertFrame"..i]:IsShown() and DRS["AlertFrame"..i].unitguid and (DRS["AlertFrame"..i].unitguid == defGUID) then
					rareTable[DRS["AlertFrame"..i].unitguid].health = floor((UnitHealth(unitTarget) / UnitHealthMax(unitTarget)) * 100)
					DRS["AlertFrame"..i].fs3:SetText(rareTable[DRS["AlertFrame"..i].unitguid].health.." %")
					DRS["AlertFrame"..i].fs3:Show()
					--SendAddonMessageToPartyGuild(DRS["AlertFrame"..i].unitguid)
				end
			end
		end
	end
end

local function ScanNameplates(unitToken)
	local guid = UnitGUID(unitToken)
	--print(unitToken)
	local type, _, _, _, _, npcID = strsplit("-", guid)
	--[[if (npcID == "151623") then
		print("type is "..type.." npcID is "..npcID)
	end]]
	if (type == "Vehicle") and (npcID == "151623") then -- The Scrap King
		type = "Creature"
		npcID = "151625"
	end
	if (type == "Vehicle") and (npcID == "179969") then -- Drippy
		type = "Creature"
		npcID = "179985"
	end
	if type == "Creature" then
		--print(unitToken.." is "..npcID)
		local classification = UnitClassification(unitToken)
		local npcIDnumber = tonumber(npcID)
		if namePlateScanMounts[npcIDnumber] then
			--print(npcIDnumber.." SPOTTED")
			local tSpellID, tItemID, tToyItemID, tChatOutput = strsplit("\a",namePlateScanMounts[npcIDnumber])
			if (tItemID ~= "") then
				tItemID = tonumber(tItemID)
				if (GetItemCount(tItemID) <= 0) then
					return
				end
			end
			if (tToyItemID ~= "") then
				tToyItemID = tonumber(tToyItemID)
				if PlayerHasToy(tToyItemID) == false then
					return
				end
			end
			if not mountIDs then
				mountIDs = C_MountJournal.GetMountIDs()
			end
			tSpellID = tonumber(tSpellID)
			for i = 1, #mountIDs do
				local _, spellID, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountIDs[i])
				if (spellID == namePlateScanMounts[npcIDnumber]) and (isCollected == true) then
					return
				elseif (tChatOutput ~= "") then
					print(tChatOutput)
					tChatOutput = ""
					namePlateScanMounts[npcIDnumber] = strjoin("\a", tSpellID, tItemID, tToyItemID, tChatOutput)
				end
			end
		end
		if (classification == "rareelite") or (classification == "rare") or namePlateScanMounts[npcIDnumber] or (npcID == "151159") and not C_QuestLog.IsQuestFlaggedCompleted(55515) --[[OOX-Fleetfoot/MG for OOX-Avenger/MG]] then
			if (npcID == "151623") then
				--print("type is "..type.." npcID is "..npcID.." classification is "..classification)
			end
			for i = 1, #blacklistedCreatures do
				if (npcIDnumber == blacklistedCreatures[i]) then
					--print("blacklisted "..npcID)
					return
				end
			end
			
			--[[
			-- Arachnoid Harvester fix
			if (npcID and npcID == 154342) then
					npcID = 151934
				end
			]]
			local defGUID = strjoin("\a",type,npcID)
			if rareTable[defGUID] and rareTable[defGUID].donotshow then
				return
			end
			rareTable[defGUID] = rareTable[defGUID] or {}
			rareTable[defGUID].nameplate = unitToken
			rareTable[defGUID].unittype = type
			--print("type = "..type.." npcID = "..npcID.." unitToken = "..unitToken)
			if rareTable[defGUID].yell then
				rareTable[defGUID].yell = nil
			end
			if rareTable[defGUID].emote then
				rareTable[defGUID].emote = nil
			end
			local raidMarkerIndex = GetRaidTargetIndex(unitToken)
			if raidMarkerIndex then
				rareTable[defGUID].raidmarker = raidMarkerIndex
			else
				for i = 1, 8 do
					local raiderMarkerIndexUsed
					for k in pairs(rareTable) do
						if rareTable[k] and rareTable[k].raidmarker and (rareTable[k].raidmarker == i) then
							raiderMarkerIndexUsed = true
							break
						end
					end
					if not raiderMarkerIndexUsed then
						rareTable[defGUID].raidmarker = i
						SetRaidTarget(unitToken,i)
						break
					end
				end
			end
			if not rareTable[defGUID].lastseen then
				rareTable[defGUID].lastseen = GetServerTime()
			end
			local unitName = UnitName(unitToken)
			rareTable[defGUID].unitname = unitName
			lookupTable[defGUID] = unitName --===============================================
			AcquireAlertFrame(defGUID)
			--SendAddonMessageToPartyGuild(defGUID)
		end
	end
end

local function ScanVignette( vignetteGUID )
	local VignetteInfo = C_VignetteInfo.GetVignetteInfo( vignetteGUID )
	if VignetteInfo and VignetteInfo.objectGUID then
		local type, _, _, _, _, npcID = strsplit( "-", VignetteInfo.objectGUID )
		npcID = tonumber(npcID)
		if defDebugPrintID then
			print (type.." "..npcID)
		end
		if ( type == "Creature" ) then
			for i = 1, #blacklistedCreatures do
				if ( npcID == blacklistedCreatures[i] ) then
					return
				end
			end
			if ( npcID == 151933 ) then -- Malfunctioning Beastbot
				return
			end
		elseif ( type == "GameObject" ) then
			for i = 1, #blacklistedObjects do
				if ( npcID == blacklistedObjects[i] ) then
					return
				end
			end
			if ( npcID == 325626 ) and ( GetItemCount( 174765 ) < 1 ) and ( GetItemCount( 174764 ) < 6 ) then -- Amathet Reliquary
				return
			elseif ( npcID == 341469 ) and ( GetItemCount( 174766 ) < 1 ) and ( GetItemCount( 174760 ) < 6 ) then -- Ambered Coffer
				return
			elseif ( npcID == 335703 ) and ( GetItemCount( 174768 ) < 1 ) and ( GetItemCount( 174758 ) < 6 ) then -- Black Empire Coffer
				return
			elseif ( npcID == 339243 ) and ( GetItemCount( 174761 ) < 1 ) and ( GetItemCount( 174756 ) < 6 ) then -- Infested Strongbox
				return
			elseif ( npcID == 334241 ) and ( GetItemCount( 174767 ) < 1 ) and ( GetItemCount( 174759 ) < 6 ) then -- Mogu Strongbox
				return
			end
		end
		if (type == "Vehicle") and (npcID == "179969") then -- Drippy
			type = "Creature"
			npcID = "179985"
		end
		if ( type == "Creature" ) or ( type == "GameObject" ) then
			local uiMapID = C_Map.GetBestMapForUnit( "player" )
			if uiMapID and zoneTable[uiMapID] then
				local _, _, _, _, _, zoneRestriction450 = strsplit( "\a", zoneTable[uiMapID] )
				if ( zoneRestriction450 == "1" ) then
					local vignettePosition = C_VignetteInfo.GetVignettePosition( vignetteGUID, uiMapID )
					if vignettePosition.x and vignettePosition.y then
						--print( "Vignette "..vignettePosition.x.." "..vignettePosition.y)
						local position = C_Map.GetPlayerMapPosition( uiMapID, "player" )
						if position.x and position.y then
							--print( "Player "..position.x.." "..position.y)
							local playerContinentID, playerWorldPosition = C_Map.GetWorldPosFromMapPos( uiMapID, CreateVector2D( position.x, position.y ) )
							local targetContinentID, targetWorldPosition = C_Map.GetWorldPosFromMapPos( uiMapID, CreateVector2D( vignettePosition.x, vignettePosition.y ) )
							local distance
							if ( playerContinentID == targetContinentID ) then
								local x = abs( playerWorldPosition.x - targetWorldPosition.x )
								local y = abs( playerWorldPosition.y - targetWorldPosition.y )
								distance = sqrt( ( x * x ) + ( y * y ) )
								distance = floor( distance )
							end
							--print(distance)
							if ( distance > 450 ) or UnitOnTaxi( "player" ) then
								local defGUID = strjoin("\a",type,npcID)
								RemoveAlertFrame( defGUID )
								--print("stopped")
								return
							end
						end
					end
				end
			end
			local defGUID = strjoin("\a",type,npcID)
			if not rareTable[defGUID] or not rareTable[defGUID].donotshow then
				if not lookupTable[defGUID] then
					lookupTable[defGUID] = VignetteInfo.name
				end
				rareTable[defGUID] = rareTable[defGUID] or {}
				rareTable[defGUID].unittype = type
				if ( type == "GameObject" ) and (npcID == 380571 ) then
					rareTable[defGUID].unitname = "Boomthyr Rocket"
				else
					rareTable[defGUID].unitname = VignetteInfo.name
				end
				rareTable[defGUID].vignette = VignetteInfo.objectGUID
				if rareTable[defGUID].yell then
					rareTable[defGUID].yell = nil
				end
				if rareTable[defGUID].emote then
					rareTable[defGUID].emote = nil
				end
				if not rareTable[defGUID].lastseen then
					rareTable[defGUID].lastseen = GetServerTime()
				end
				local uiMapID = C_Map.GetBestMapForUnit( "player" )
				if uiMapID then
					--rareTable[defGUID].uiMapID = uiMapID
					local vignettePosition = C_VignetteInfo.GetVignettePosition( vignetteGUID, uiMapID )
					if vignettePosition then
						if ( vignettePosition and ( vignettePosition.x ~= 0 ) and ( vignettePosition.y ~= 0 ) ) then
							rareTable[defGUID].x = vignettePosition.x
							rareTable[defGUID].y = vignettePosition.y
						end
					end
				end
				AcquireAlertFrame( defGUID )
			end
		end
	end
end

local function ScanAllVignettes()
	local vignetteGUIDs = C_VignetteInfo.GetVignettes()
	if vignetteGUIDs then
		for i in pairs( vignetteGUIDs ) do
			local VignetteInfo = C_VignetteInfo.GetVignetteInfo( vignetteGUIDs[i] )
			if VignetteInfo and VignetteInfo.objectGUID then
				ScanVignette( vignetteGUIDs[i] )
			end
		end
		for k in pairs( rareTable ) do
			if rareTable[k].vignette then
				local x
				for i in pairs( vignetteGUIDs ) do
					local VignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUIDs[i])
					if VignetteInfo and VignetteInfo.objectGUID then
						if ( rareTable[k].vignette == VignetteInfo.objectGUID ) then
							x = true
							break
						else
							local type, _, _, _, _, npcID = strsplit( "-", VignetteInfo.objectGUID )
							if ( type == "Creature" ) or ( type == "GameObject" ) then
								local defGUID = strjoin( "\a", type, npcID )
								if ( k == defGUID ) then
									x = true
									break
								end
							end
						end
					end
				end
				if not x or UnitOnTaxi( "player" ) then
					if not rareTable[k].donotshow then
						if rareTable[k].nameplate then
							rareTable[k].vignette = nil
						else
							RemoveAlertFrame( k )
							rareTable[k] = nil
						end
					end
				end
			end
		end
	else
		for k in pairs( rareTable ) do
			if not rareTable[k].donotshow and rareTable[k].vignette then
				RemoveAlertFrame( k )
				rareTable[k] = nil
			end
		end
	end
end

local function RareSafariZoneControl()
	local _, instanceType = GetInstanceInfo()
	local uiMapID = C_Map.GetBestMapForUnit( "player" )
	local emote, yell, nameplate, health, vignette
	if ( instanceType == "none" ) and uiMapID then
		if zoneTable[uiMapID] then
			emote, yell, nameplate, health, vignette = strsplit( "\a", zoneTable[uiMapID] )
			if not DRSa[uiMapID] and not DRSc[uiMapID] then
				emote, yell, nameplate, health, vignette = nil, nil, nil, nil, nil
			end
		else
			local UiMapDetails = C_Map.GetMapInfo( uiMapID )
			if UiMapDetails and ( UiMapDetails.mapType ~= Enum.UIMapType.Orphan ) then
				if ( UiMapDetails.mapType >= Enum.UIMapType.Zone ) then
					for i = 1, 10 do
						UiMapDetails = C_Map.GetMapInfo( uiMapID )
						local x = C_Map.GetMapInfo( UiMapDetails.parentMapID )
						if x and x.mapType and ( x.mapType == Enum.UIMapType.Zone ) and UiMapDetails.parentMapID then
							uiMapID = UiMapDetails.parentMapID
							break
						end
					end
				end
			end
			if zoneTable[uiMapID] then
				emote, yell, nameplate, health, vignette = strsplit( "\a", zoneTable[uiMapID] )
				if not DRSa[uiMapID] and not DRSc[uiMapID] then
					emote, yell, nameplate, health, vignette = nil, nil, nil, nil, nil
				end
			end
		end
	else
		C_Timer.After( 0.5, RareSafariZoneControl )
	end
	if ( emote == "1" ) then
		DRS:RegisterEvent( "CHAT_MSG_MONSTER_EMOTE" )
	else
		DRS:UnregisterEvent( "CHAT_MSG_MONSTER_EMOTE" )
	end
	if ( yell == "1" ) then
		DRS:RegisterEvent( "CHAT_MSG_MONSTER_YELL" )
	else
		DRS:UnregisterEvent( "CHAT_MSG_MONSTER_YELL" )
	end
	if ( nameplate == "1" ) then
		DRS:RegisterEvent( "NAME_PLATE_UNIT_ADDED" )
		DRS:RegisterEvent( "NAME_PLATE_UNIT_REMOVED" )
	else
		DRS:UnregisterEvent( "NAME_PLATE_UNIT_ADDED" )
		DRS:UnregisterEvent( "NAME_PLATE_UNIT_REMOVED" )
	end
	if ( health == "1" ) then
		DRS:RegisterEvent( "UNIT_HEALTH" )
	else
		DRS:UnregisterEvent( "UNIT_HEALTH" )
	end
	if ( vignette == "1" ) then
		DRS:RegisterEvent( "VIGNETTE_MINIMAP_UPDATED" )
		DRS:RegisterEvent( "VIGNETTES_UPDATED" )
		ScanAllVignettes()
	else
		DRS:UnregisterEvent( "VIGNETTE_MINIMAP_UPDATED" )
		DRS:UnregisterEvent( "VIGNETTES_UPDATED" )
		RemoveAllAlertFrames()
	end
end

DRS:SetScript( "OnEvent", function( self, event, ... )
	if (event=="ADDON_LOADED") then
	--[[elseif event=="CHAT_MSG_BN_WHISPER" or event=="CHAT_MSG_COMMUNITIES_CHANNEL" or event=="CHAT_MSG_GUILD" or event=="CHAT_MSG_INSTANCE_CHAT" or event=="CHAT_MSG_INSTANCE_CHAT_LEADER" or event=="CHAT_MSG_OFFICER"or event=="CHAT_MSG_PARTY" or event=="CHAT_MSG_PARTY_LEADER" or event=="CHAT_MSG_RAID" or event=="CHAT_MSG_RAID_LEADER" or event=="CHAT_MSG_WHISPER" then
		local _,_,_,_,_,_,_,_,_,_,_,guid,bnSenderID=...
		ChatMessageSounds(event,guid,bnSenderID)
	elseif event=="COMBAT_LOG_EVENT_UNFILTERED" then
		local pGUID = UnitGUID("player")
		local _,event,_,_,sourceName,_,_,destGUID,_,_,_,spellID=CombatLogGetCurrentEventInfo()
		if spellID==6770 and destGUID==pGUID and (event=="SPELL_AURA_APPLIED" or event=="SPELL_AURA_REFRESH") then
			SendChatMessage("{rt8} "..(GetSpellLink(6770) or "Sapped").." {rt8}","SAY")
			if sourceName then print((GetSpellLink(6770) or "Sapped").." -- "..sourceName) end
		end]]
	--[[elseif (event == "CHAT_MSG_ADDON") then
		local prefix, text, channel, sender = ...
		if (prefix == "Def's RS") then
			--ChatMessageAddon(text,channel,sender)
		end]]
		--"prefix", "text", "channel", "sender", "target", zoneChannelID, localID, "name", instanceID
	elseif (event == "CHAT_MSG_MONSTER_EMOTE") then
		--ChatEmote(...)
	elseif (event == "CHAT_MSG_MONSTER_YELL") then
		--ChatYell(...)
	elseif (event == "NAME_PLATE_UNIT_ADDED") then
		--local unitToken = ...
		--tinsert(nameplatesInUse,unitToken)
		--print("NAME_PLATE_UNIT_ADDED "..unitToken)
		--ScanNameplates(unitToken)
	elseif (event == "NAME_PLATE_UNIT_REMOVED") then
		--local unitToken = ...
	--	RemoveNamePlate(unitToken)
		--print("NAME_PLATE_UNIT_REMOVED "..unitToken)
	elseif (event == "VIGNETTE_MINIMAP_UPDATED") then
		local vignetteGUID = ...
		ScanVignette( vignetteGUID )
		ScanAllVignettes()
	elseif ( event == "VIGNETTES_UPDATED" ) then
		ScanAllVignettes()
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local isInitialLogin, isReloadingUi = ...
		if isInitialLogin or isReloadingUi then
			DRSa = DRSa or {}
			DRSc = DRSc or {}
		end
		local testBuild = false
		if testBuild then
			DRSa = {}
			DRSc = {}
		end
		self:UnregisterEvent( event )
		self:RegisterEvent( "ZONE_CHANGED_NEW_AREA" )
		C_Timer.After( 1, RareSafariZoneControl )
	elseif ( event == "SAVED_VARIABLES_TOO_LARGE" ) then
		local x = ...
		if ( x == "Defs-Rare-Safari" ) then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
	elseif (event == "UNIT_HEALTH") then
		--local unitTarget = ...
		--NamePlateHealth(unitTarget)
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		C_Timer.After( 1, RareSafariZoneControl )
	end end)
DRS:RegisterEvent("PLAYER_ENTERING_WORLD")
DRS:RegisterEvent("SAVED_VARIABLES_TOO_LARGE")

local menuWidth = 300
local menuHeighth = 390
DRS:SetSize( menuWidth, menuHeighth )
DRS:SetPoint( "CENTER", 0, 100 )
DRS:SetShown( false )
DRS:SetClampedToScreen( true )
DRS:SetMovable( true )
DRS:SetScript( "OnMouseDown", function( self )
	self:StartMoving()
end )
DRS:SetScript( "OnMouseUp", function( self )
	self:StopMovingOrSizing()
end )

local function GameFontNormalResetFunction( _, f )
	f:SetText(nil)
	f:SetTextColor( 1, .82, 0 )
	f:ClearAllPoints()
	f:Hide()
end

local function InputBoxTemplateResetFunction( _, f )
	f:SetSize( 40, 32 )
	f:SetAutoFocus( false )
	f:SetMaxLetters( 4 )
	f:SetText( "" )
	f:Enable()
	f:SetNumeric( false )
	f:ClearAllPoints()
	local t = { "OnEditFocusLost", "OnEnter", "OnEnterPressed", "OnEscapePressed", "OnHide", "OnLeave", "OnShow", "OnUpdate" }
	for i = 1, #t do
		f:SetScript( t[i], nil )
	end
	f:Hide()
end

local function TooltipBorderedFrameTemplateResetFunction( _, f )
	f:SetParent( DRS )
	f:ClearAllPoints()
	f:SetParent( UIParent )
	f:Hide()
end

local function UICheckButtonTemplateResetFunction( _, f )
	f:ClearAllPoints()
	f:SetSize( 25, 25 )
	f.text:SetText( nil )
	f.text:SetTextColor( 1, 1, 1 )
	f:SetChecked( false )
	local t = { "OnClick", "OnEnter", "OnHide", "OnLeave", "OnShow", "OnUpdate" }
	for i = 1, #t do
		f:SetScript( t[i], nil )
	end
	f:Enable()
	f:Hide()
end

local function UIMenuButtonStretchTemplateResetFunction( _, f )
	f:ClearAllPoints()
	f:SetText( nil )
	f:Enable()
	f:SetParent( DRS )
	local t = { "OnClick", "OnShow", "OnUpdate" }
	for i = 1, #t do
		f:SetScript( t[i], nil )
	end
	f:Hide()
end

local function CloseMenuSystem()
	DRS.myPools:ReleaseAll()
	DRS.myFontStringPools:ReleaseAll()
	DRS:Hide()
end

GameMenuFrame:HookScript( "OnShow", function()
	if DRS:IsShown() then
		CloseMenuSystem()
	end
end )

local function MenuSystem( ... )
	local selectedBox = ... or "9"
	DRS.myFontStringPools:ReleaseAll()
	DRS.myPools:ReleaseAll()
	DRS.closeButton = DRS.myPools:Acquire( "UIMenuButtonStretchTemplate" )
	DRS.closeButton:SetPoint( "TOPRIGHT", DRS, "TOPRIGHT", -6, -6 )
	DRS.closeButton:SetSize( 20, 20 )
	DRS.closeButton:SetText( "X" )
	DRS.closeButton:SetShown( true )
	DRS.closeButton:SetScript( "OnClick", function() CloseMenuSystem() end )
	local resetBtn = DRS.myPools:Acquire( "UIMenuButtonStretchTemplate" )
	local chkBtn5 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
	local chkBtn6 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
	local chkBtn7 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
	local chkBtn8 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
	local chkBtn9 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
	local _, class = UnitClass( "player" )
	if ( class == "PRIEST" ) then
		class = "MONK"
	end
	local classR, classG, classB, classHex = GetClassColor( class )
	resetBtn:SetPoint( "BOTTOMRIGHT", DRS, "BOTTOMRIGHT", -5, 5 )
	resetBtn:SetScript( "OnShow", 	function( self )
		self:SetSize ( 120, 24)
		self:SetText( "重置設定" )
		for k in pairs( DRSa ) do
			if DRSa[k] then
				return
			end
		end
		for k in pairs( DRSc ) do
			if DRSc[k] then
				return
			end
		end
		self:Hide()
	end )
	resetBtn:SetScript( "OnUpdate", function( self, elapsed )
		self.TimeSinceLastUpdate = ( ( self.TimeSinceLastUpdate or 0 ) + elapsed )
		if ( self.TimeSinceLastUpdate > 1 ) then
			self.TimeSinceLastUpdate = 0
			for k in pairs( DRSa ) do
				if DRSa[k] then
					return
				end
			end
			for k in pairs( DRSc ) do
				if DRSc[k] then
					return
				end
			end
			self:Hide()
		end
	end )
	resetBtn:SetScript( "OnClick", function()
		DRSa = {}
		DRSc = {}
		MenuSystem()
	end )
	resetBtn:Show()
	local function CheckButtonOnShow( f, mapID, zoneName )
		local UiMapDetails = C_Map.GetMapInfo( mapID )
		local text = UiMapDetails.name or zoneName
		if DRSa[ mapID ] then
			f.text:SetText( text.." (帳號通用)" )
			f:SetChecked( true )
			f.text:SetTextColor( 0.51, 0.773, 1 )
		elseif DRSc[ mapID ] then
			f.text:SetText( text.." (只有這個角色)" )
			f:SetChecked( true )
			f.text:SetTextColor( classR, classG, classB )
		else
			f.text:SetText( text )
		end
	end
	local function CheckButtonOnClick( mapID, category )
		if DRSa[ mapID ] then
			DRSa[ mapID ] = nil
			DRSc[ mapID ] = nil
			RemoveAllAlertFrames()
		elseif DRSc[ mapID ] then
			DRSa[ mapID ] = 1
			DRSc[ mapID ] = nil
		else
			DRSc[ mapID ] = 1
		end
		MenuSystem( category )
		RareSafariZoneControl()
	end
	do
		local t = { 2022, 2023, 2024, 2025, 2133, 2151 }
		chkBtn9:SetPoint( "CENTER", DRS, "TOPLEFT", 30, -28 )
		chkBtn9:SetScript( "OnShow", function( self )
			local text = EXPANSION_NAME9 or "Dragonflight"
			for i = 1, #t do
				if  DRSa[ t [ i ] ] then
					self.text:SetText( text.." (帳號通用)" )
					self:SetChecked( true )
					self.text:SetTextColor( 0.51, 0.773, 1 )
				elseif DRSc[ t [ i ] ] then
					self.text:SetText( text.." (只有這個角色)" )
					self:SetChecked( true )
					self.text:SetTextColor( classR, classG, classB )
				elseif ( i == #t ) then
					self.text:SetText( text )
				end
			end
			if not selectedBox or ( selectedBox == "9" ) then
				local chkBtn2022 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn2023 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn2024 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn2025 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn2133 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn2151 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				chkBtn2024:SetPoint( "CENTER", chkBtn9, "CENTER", 20, -20 )
				chkBtn2024:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn2024, 2024, "The Azure Span" )
				end )
				chkBtn2024:SetScript( "OnClick", function()
					CheckButtonOnClick( 2024, "9" )
				end )
				chkBtn2024:Show()
				chkBtn2151:SetPoint( "CENTER", chkBtn2024, "CENTER", 0, -20 )
				chkBtn2151:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn2151, 2151, "The Forbidden Reach" )
				end )
				chkBtn2151:SetScript( "OnClick", function()
					CheckButtonOnClick( 2151, "9" )
				end )
				chkBtn2151:Show()
				chkBtn2023:SetPoint( "CENTER", chkBtn2151, "CENTER", 0, -20 )
				chkBtn2023:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn2023, 2023, "Ohn'ahran Plains" )
				end )
				chkBtn2023:SetScript( "OnClick", function()
					CheckButtonOnClick( 2023, "9" )
				end )
				chkBtn2023:Show()
				chkBtn2025:SetPoint( "CENTER", chkBtn2023, "CENTER", 0, -20 )
				chkBtn2025:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn2025, 2025, "Thaldraszus" )
				end )
				chkBtn2025:SetScript( "OnClick", function()
					CheckButtonOnClick( 2025, "9" )
				end )
				chkBtn2025:Show()
				chkBtn2022:SetPoint( "CENTER", chkBtn2025, "CENTER", 0, -20 )
				chkBtn2022:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn2022, 2022, "The Waking Shores" )
				end )
				chkBtn2022:SetScript( "OnClick", function()
					CheckButtonOnClick( 2022, "9" )
				end )
				chkBtn2022:Show()
				chkBtn2133:SetPoint( "CENTER", chkBtn2022, "CENTER", 0, -20 )
				chkBtn2133:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn2133, 2133, "Zaralek Cavern" )
				end )
				chkBtn2133:SetScript( "OnClick", function()
					CheckButtonOnClick( 2133, "9" )
				end )
				chkBtn2133:Show()
			end
		end )
		chkBtn9:SetScript( "OnClick", function()
			if ( selectedBox == "9") and not chkBtn9:GetChecked() then
				for i = 1, #t do
					DRSa[ t [ i ] ] = nil
					DRSc[ t [ i ] ] = nil
				end
				RareSafariZoneControl()
			end
			MenuSystem( "9" )
		end )
		chkBtn9:Show()
	end
	do
		local t = { 1525, 1533, 1536, 1543, 1565, 1961, 1970 }
		chkBtn8:SetScript( "OnShow", function( self )
			local text = EXPANSION_NAME8 or "Shadowlands"
			for i = 1, #t do
				if  DRSa[ t [ i ] ] then
					self.text:SetText( text.." (帳號通用)" )
					self:SetChecked( true )
					self.text:SetTextColor( 0.51, 0.773, 1 )
				elseif DRSc[ t [ i ] ] then
					self.text:SetText( text.." (只有這個角色)" )
					self:SetChecked( true )
					self.text:SetTextColor( classR, classG, classB )
				elseif ( i == #t ) then
					self.text:SetText( text )
				end
			end
			if ( selectedBox == "8" ) then
				self:SetPoint( "CENTER", chkBtn9, "CENTER", 0, -20 )
				local chkBtn1525 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1533 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1536 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1543 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1565 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1961 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1970 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				chkBtn1565:SetPoint( "CENTER", chkBtn8, "CENTER", 20, -20 )
				chkBtn1565:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1565, 1565, "Ardenweald" )
				end )
				chkBtn1565:SetScript( "OnClick", function()
					CheckButtonOnClick( 1565, "8" )
				end )
				chkBtn1565:Show()
				chkBtn1533:SetPoint( "CENTER", chkBtn1565, "CENTER", 0, -20 )
				chkBtn1533:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1533, 1533, "Bastion" )
				end )
				chkBtn1533:SetScript( "OnClick", function()
					CheckButtonOnClick( 1533, "8" )
				end )
				chkBtn1533:Show()
				chkBtn1961:SetPoint( "CENTER", chkBtn1533, "CENTER", 0, -20 )
				chkBtn1961:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1961, 1961, "Korthia" )
				end )
				chkBtn1961:SetScript( "OnClick", function()
					CheckButtonOnClick( 1961, "8" )
				end )
				chkBtn1961:Show()
				chkBtn1536:SetPoint( "CENTER", chkBtn1961, "CENTER", 0, -20 )
				chkBtn1536:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1536, 1536, "Maldraxxus" )
				end )
				chkBtn1536:SetScript( "OnClick", function()
					CheckButtonOnClick( 1536, "8" )
				end )
				chkBtn1536:Show()
				chkBtn1543:SetPoint( "CENTER", chkBtn1536, "CENTER", 0, -20 )
				chkBtn1543:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1543, 1543, "The Maw" )
				end )
				chkBtn1543:SetScript( "OnClick", function()
					CheckButtonOnClick( 1543, "8" )
				end )
				chkBtn1543:Show()
				chkBtn1525:SetPoint( "CENTER", chkBtn1543, "CENTER", 0, -20 )
				chkBtn1525:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1525, 1525, "Revendreth" )
				end )
				chkBtn1525:SetScript( "OnClick", function()
					CheckButtonOnClick( 1525, "8" )
				end )
				chkBtn1525:Show()
				chkBtn1970:SetPoint( "CENTER", chkBtn1525, "CENTER", 0, -20 )
				chkBtn1970:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1970, 1970, "Zereth Mortis" )
				end )
				chkBtn1970:SetScript( "OnClick", function()
					CheckButtonOnClick( 1970, "8" )
				end )
				chkBtn1970:Show()
			elseif not selectedBox or ( selectedBox == "9" ) then
				self:SetPoint( "CENTER", chkBtn9, "CENTER", 0, -140 )
			else
				self:SetPoint( "CENTER", chkBtn9, "CENTER", 0, -20 )
			end
		end )
		chkBtn8:SetScript( "OnClick", function()
			if ( selectedBox == "8") and not chkBtn8:GetChecked() then
				for i = 1, #t do
					DRSa[ t [ i ] ] = nil
					DRSc[ t [ i ] ] = nil
				end
				RareSafariZoneControl()
			end
			MenuSystem( "8" )
		end )
		chkBtn8:Show()
	end
	do
		local t = { 14, 62, 862, 863, 864, 895, 896, 942, 1462, 1355, 1527, 1530 }
		chkBtn7:SetScript( "OnShow", function( self )
			local text = EXPANSION_NAME7 or "Battle for Azeroth"
			for i = 1, #t do
				if  DRSa[ t [ i ] ] then
					self.text:SetText( text.." (帳號通用)" )
					self:SetChecked( true )
					self.text:SetTextColor( 0.51, 0.773, 1 )
				elseif DRSc[ t [ i ] ] then
					self.text:SetText( text.." (只有這個角色)" )
					self:SetChecked( true )
					self.text:SetTextColor( classR, classG, classB )
				elseif ( i == #t ) then
					self.text:SetText( text )
				end
			end
			if ( selectedBox == "7" ) then
				self:SetPoint( "CENTER", chkBtn8, "CENTER", 0, -20 )
				local chkBtn14 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn62 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn862 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn863 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn864 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn895 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn896 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn942 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1462 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1355 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1527 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn1530 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				chkBtn14:SetPoint( "CENTER", chkBtn7, "CENTER", 20, -20 )
				chkBtn14:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn14, 14, "Arathi Highlands" )
				end )
				chkBtn14:SetScript( "OnClick", function()
					CheckButtonOnClick( 14, "7" )
				end )
				chkBtn14:Show()
				chkBtn62:SetPoint( "CENTER", chkBtn14, "CENTER", 0, -20 )
				chkBtn62:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn62, 62, "Darkshore" )
				end )
				chkBtn62:SetScript( "OnClick", function()
					CheckButtonOnClick( 62, "7" )
				end )
				chkBtn62:Show()
				chkBtn896:SetPoint( "CENTER", chkBtn62, "CENTER", 0, -20 )
				chkBtn896:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn896, 896, "Drustvar" )
				end )
				chkBtn896:SetScript( "OnClick", function()
					CheckButtonOnClick( 896, "7" )
				end )
				chkBtn896:Show()
				chkBtn1462:SetPoint( "CENTER", chkBtn896, "CENTER", 0, -20 )
				chkBtn1462:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1462, 1462, "Mechagon Island" )
				end )
				chkBtn1462:SetScript( "OnClick", function()
					CheckButtonOnClick( 1462, "7" )
				end )
				chkBtn1462:Show()
				chkBtn1355:SetPoint( "CENTER", chkBtn1462, "CENTER", 0, -20 )
				chkBtn1355:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1355, 1355, "Nazjatar" )
				end )
				chkBtn1355:SetScript( "OnClick", function()
					CheckButtonOnClick( 1355, "7" )
				end )
				chkBtn1355:Show()
				chkBtn863:SetPoint( "CENTER", chkBtn1355, "CENTER", 0, -20 )
				chkBtn863:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn863, 863, "Nazmir" )
				end )
				chkBtn863:SetScript( "OnClick", function()
					CheckButtonOnClick( 863, "7" )
				end )
				chkBtn863:Show()
				chkBtn942:SetPoint( "CENTER", chkBtn863, "CENTER", 0, -20 )
				chkBtn942:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn942, 942, "Stormsong Valley" )
				end )
				chkBtn942:SetScript( "OnClick", function()
					CheckButtonOnClick( 942, "7" )
				end )
				chkBtn942:Show()
				chkBtn895:SetPoint( "CENTER", chkBtn942, "CENTER", 0, -20 )
				chkBtn895:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn895, 895, "Tiragarde Sound" )
				end )
				chkBtn895:SetScript( "OnClick", function()
					CheckButtonOnClick( 895, "7" )
				end )
				chkBtn895:Show()
				chkBtn1527:SetPoint( "CENTER", chkBtn895, "CENTER", 0, -20 )
				chkBtn1527:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1527, 1527, "Uldum" )
				end )
				chkBtn1527:SetScript( "OnClick", function()
					CheckButtonOnClick( 1527, "7" )
				end )
				chkBtn1527:Show()
				chkBtn1530:SetPoint( "CENTER", chkBtn1527, "CENTER", 0, -20 )
				
				chkBtn1530:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn1530, 1530, "Vale of Eternal Blossoms" )
				end )
				chkBtn1530:SetScript( "OnClick", function()
					CheckButtonOnClick( 1530, "7" )
				end )
				chkBtn1530:Show()
				chkBtn864:SetPoint( "CENTER", chkBtn1530, "CENTER", 0, -20 )
				chkBtn864:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn864, 864, "Vul'dun" )
				end )
				chkBtn864:SetScript( "OnClick", function()
					CheckButtonOnClick( 864, "7" )
				end )
				chkBtn864:Show()
				chkBtn862:SetPoint( "CENTER", chkBtn864, "CENTER", 0, -20 )
				
				chkBtn862:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn862, 862, "Zuldazar" )
				end )
				chkBtn862:SetScript( "OnClick", function()
					CheckButtonOnClick( 862, "7" )
				end )
				chkBtn862:Show()
			elseif not selectedBox or ( selectedBox == "8" ) then
				self:SetPoint( "CENTER", chkBtn8, "CENTER", 0, -160 )
			else
				self:SetPoint( "CENTER", chkBtn8, "CENTER", 0, -20 )
			end
		end )
		chkBtn7:SetScript( "OnClick", function()
			if ( selectedBox == "7") and not chkBtn7:GetChecked() then
				for i = 1, #t do
					DRSa[ t [ i ] ] = nil
					DRSc[ t [ i ] ] = nil
				end
				RareSafariZoneControl()
			end
			MenuSystem( "7" )
		end )
		chkBtn7:Show()
	end
	do
		local t = { 630, 634, 641, 646, 650, 680, 830 }
		chkBtn6:SetScript( "OnShow", function( self )
			local text = EXPANSION_NAME6 or "Legion"
			for i = 1, #t do
				if  DRSa[ t [ i ] ] then
					self.text:SetText( text.." (帳號通用)" )
					self:SetChecked( true )
					self.text:SetTextColor( 0.51, 0.773, 1 )
				elseif DRSc[ t [ i ] ] then
					self.text:SetText( text.." (只有這個角色)" )
					self:SetChecked( true )
					self.text:SetTextColor( classR, classG, classB )
				elseif ( i == #t ) then
					self.text:SetText( text )
				end
			end
			if ( selectedBox == "6" ) then
				self:SetPoint( "CENTER", chkBtn7, "CENTER", 0, -20 )
				local chkBtn630 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn634 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn641 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn646 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn650 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn680 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn830 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				chkBtn830:SetPoint( "CENTER", chkBtn6, "CENTER", 20, -20 )
				chkBtn830:SetScript( "OnShow", function( self )
					local UiMapDetails = C_Map.GetMapInfo( 994 )
					local text = UiMapDetails.name or "Argus"
					if DRSa[830] then
						self.text:SetText( text.." (帳號通用)" )
						self:SetChecked( true )
						self.text:SetTextColor( 0.51, 0.773, 1 )
					elseif DRSc[830] then
						self.text:SetText( text.." (只有這個角色)" )
						self:SetChecked( true )
						self.text:SetTextColor( classR, classG, classB )
					else
						self.text:SetText( text )
					end
				end )
				chkBtn830:SetScript( "OnClick", function()
					if DRSa[830] then
						DRSa[830] = nil
						DRSc[830] = nil
						DRSa[882] = nil
						DRSc[882] = nil
						DRSa[885] = nil
						DRSc[885] = nil
						RemoveAllAlertFrames()
					elseif DRSc[830] then
						DRSa[830] = 1
						DRSc[830] = nil
						DRSa[882] = 1
						DRSc[882] = nil
						DRSa[885] = 1
						DRSc[885] = nil
					else
						DRSc[830] = 1
						DRSc[882] = 1
						DRSc[885] = 1
					end
					MenuSystem( "6" )
					RareSafariZoneControl()
				end )
				chkBtn830:Show()
				chkBtn630:SetPoint( "CENTER", chkBtn830, "CENTER", 0, -20 )
				chkBtn630:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn630, 630, "Azsuna" )
				end )
				chkBtn630:SetScript( "OnClick", function()
					CheckButtonOnClick( 630, "6" )
				end )
				chkBtn630:Show()
				chkBtn646:SetPoint( "CENTER", chkBtn630, "CENTER", 0, -20 )
				chkBtn646:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn646, 646, "Broken Shore" )
				end )
				chkBtn646:SetScript( "OnClick", function()
					CheckButtonOnClick( 646, "6" )
				end )
				chkBtn646:Show()
				chkBtn650:SetPoint( "CENTER", chkBtn646, "CENTER", 0, -20 )
				chkBtn650:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn650, 650, "Highmountain" )
				end )
				chkBtn650:SetScript( "OnClick", function()
					CheckButtonOnClick( 650, "6" )
				end )
				chkBtn650:Show()
				chkBtn634:SetPoint( "CENTER", chkBtn650, "CENTER", 0, -20 )
				chkBtn634:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn634, 634, "Stormheim" )
				end )
				chkBtn634:SetScript( "OnClick", function()
					CheckButtonOnClick( 634, "6" )
				end )
				chkBtn634:Show()
				chkBtn680:SetPoint( "CENTER", chkBtn634, "CENTER", 0, -20 )
				chkBtn680:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn680, 680, "Suramar" )
				end )
				chkBtn680:SetScript( "OnClick", function()
					CheckButtonOnClick( 680, "6" )
				end )
				chkBtn680:Show()
				chkBtn641:SetPoint( "CENTER", chkBtn680, "CENTER", 0, -20 )
				chkBtn641:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn641, 641, "Val'sharah" )
				end )
				chkBtn641:SetScript( "OnClick", function()
					CheckButtonOnClick( 641, "6" )
				end )
				chkBtn641:Show()
			elseif ( selectedBox == "7" ) then
				self:SetPoint( "CENTER", chkBtn7, "CENTER", 0, -260 )
			else
				self:SetPoint( "CENTER", chkBtn7, "CENTER", 0, -20 )
			end
		end )
		chkBtn6:SetScript( "OnClick", function()
			if ( selectedBox == "6") and not chkBtn6:GetChecked() then
				for i = 1, #t do
					DRSa[ t [ i ] ] = nil
					DRSc[ t [ i ] ] = nil
				end
				RareSafariZoneControl()
			end
			MenuSystem( "6" )
		end )
		chkBtn6:Show()
	end
	do
		local t = { 525, 534, 535, 539, 542, 543, 550 }
		chkBtn5:SetScript( "OnShow", function( self )
			local text = EXPANSION_NAME5 or "Warlords of Draenor"
			for i = 1, #t do
				if  DRSa[ t [ i ] ] then
					self.text:SetText( text.." (帳號通用)" )
					self:SetChecked( true )
					self.text:SetTextColor( 0.51, 0.773, 1 )
				elseif DRSc[ t [ i ] ] then
					self.text:SetText( text.." (只有這個角色)" )
					self:SetChecked( true )
					self.text:SetTextColor( classR, classG, classB )
				elseif ( i == #t ) then
					self.text:SetText( text )
				end
			end
			if ( selectedBox == "5" ) then
				self:SetPoint( "CENTER", chkBtn6, "CENTER", 0, -20 )
				local chkBtn525 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn534 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn535 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn539 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn542 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn543 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				local chkBtn550 = DRS.myPools:Acquire( "UICheckButtonTemplate" )
				chkBtn525:SetPoint( "CENTER", chkBtn5, "CENTER", 20, -20 )
				chkBtn525:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn525, 525, "Frostfire Ridge" )
				end )
				chkBtn525:SetScript( "OnClick", function()
					CheckButtonOnClick( 525, "5" )
				end )
				chkBtn525:Show()
				chkBtn543:SetPoint( "CENTER", chkBtn525, "CENTER", 0, -20 )
				chkBtn543:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn543, 543, "Gorgrond" )
				end )
				chkBtn543:SetScript( "OnClick", function()
					CheckButtonOnClick( 543, "5" )
				end )
				chkBtn543:Show()
				chkBtn550:SetPoint( "CENTER", chkBtn543, "CENTER", 0, -20 )
				chkBtn550:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn550, 550, "Nagrand" )
				end )
				chkBtn550:SetScript( "OnClick", function()
					CheckButtonOnClick( 550, "5" )
				end )
				chkBtn550:Show()
				chkBtn539:SetPoint( "CENTER", chkBtn550, "CENTER", 0, -20 )
				chkBtn539:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn539, 539, "Shadowmoon Valley" )
				end )
				chkBtn539:SetScript( "OnClick", function()
					CheckButtonOnClick( 539, "5" )
				end )
				chkBtn539:Show()
				chkBtn542:SetPoint( "CENTER", chkBtn539, "CENTER", 0, -20 )
				chkBtn542:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn542, 542, "Spires of Arak" )
				end )
				chkBtn542:SetScript( "OnClick", function()
					CheckButtonOnClick( 542, "5" )
				end )
				chkBtn542:Show()
				chkBtn535:SetPoint( "CENTER", chkBtn542, "CENTER", 0, -20 )
				chkBtn535:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn535, 535, "Talador" )
				end )
				chkBtn535:SetScript( "OnClick", function()
					CheckButtonOnClick( 535, "5" )
				end )
				chkBtn535:Show()
				chkBtn534:SetPoint( "CENTER", chkBtn535, "CENTER", 0, -20 )
				chkBtn534:SetScript( "OnShow", function()
					CheckButtonOnShow( chkBtn534, 534, "Tanaan Jungle" )
				end )
				chkBtn534:SetScript( "OnClick", function()
					CheckButtonOnClick( 534, "5" )
				end )
				chkBtn534:Show()
			elseif ( selectedBox == "6" ) then
				self:SetPoint( "CENTER", chkBtn6, "CENTER", 0, -160 )
			else
				self:SetPoint( "CENTER", chkBtn6, "CENTER", 0, -20 )
			end
		end )
		chkBtn5:SetScript( "OnClick", function()
			if ( selectedBox == "5") and not chkBtn5:GetChecked() then
				for i = 1, #t do
					DRSa[ t [ i ] ] = nil
					DRSc[ t [ i ] ] = nil
				end
				RareSafariZoneControl()
			end
			MenuSystem( "5" )
		end )
		chkBtn5:Show()
	end
	DRS:Show()
end

DRS.myPools:CreatePool( "Frame", DRS, "TooltipBorderedFrameTemplate", TooltipBorderedFrameTemplateResetFunction )
DRS.myPools:CreatePool( "CheckButton", DRS, "UICheckButtonTemplate", UICheckButtonTemplateResetFunction )
DRS.myPools:CreatePool( "EditBox", DRS, "InputBoxTemplate", InputBoxTemplateResetFunction )
DRS.myPools:CreatePool( "Button", DRS, "UIMenuButtonStretchTemplate", UIMenuButtonStretchTemplateResetFunction )
DRS.myFontStringPools = CreateFontStringPool( DRS, "ARTWORK", nil, "GameFontNormal", GameFontNormalResetFunction )

SLASH_DEFRS1 = "/DRS"
SlashCmdList["DEFRS"] = function()
	if DRS:IsShown() then
		CloseMenuSystem()
	else
		MenuSystem()
	end
end

function DefsRareSafari_OnAddonCompartmentClick( addonName, button ) 
	if not DRS then
		return
	elseif DRS:IsShown() then
		CloseMenuSystem()
	else
		MenuSystem()
	end
end

function DefsRareSafari_AddonCompartmentFuncOnEnter() 
--[[
	local f = GetMouseFocus()
	while f and not f.dropdown do
		f = f:GetParent()
	end
	GameTooltip:SetOwner( f, "ANCHOR_NONE" )
	GameTooltip:SetPoint( "TOPRIGHT", f, "TOPLEFT", 0, 0 )
	GameTooltip:AddLine( "戴夫的稀有狩獵旅" )
	GameTooltip:Show()
--]]
end

function DefsRareSafari_AddonCompartmentFuncOnLeave() 
	-- GameTooltip:Hide()
end

local optionsPanelFrame = CreateFrame( "Frame" )
local background = optionsPanelFrame:CreateTexture()
background:SetAllPoints( optionsPanelFrame )

local optionsButton = CreateFrame( "Button", nil, optionsPanelFrame, "UIMenuButtonStretchTemplate" )
optionsButton:SetPoint("CENTER")
optionsButton:SetText( "戴夫的稀有狩獵旅設定" )
optionsButton:SetWidth( 200 )
optionsButton:SetScript( "OnClick", function()
	if not DRS then
		return
	elseif DRS:IsShown() then
		CloseMenuSystem()
	else
		MenuSystem()
		DRS:SetFrameStrata( "HIGH" )
	end
end )
 
local category = Settings.RegisterCanvasLayoutCategory( optionsPanelFrame, "稀有怪-戴夫" )
Settings.RegisterAddOnCategory( category )