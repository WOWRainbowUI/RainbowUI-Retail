[1] = nil,--Mechagon Island
[2] = nil,--Nazjatar
[3] = nil,--Uldum
[4] = nil,--Vale of Eternal Blossoms
[5] = nil,--GetPoint1
[6] = nil,--GetPoint2
[7] = nil,--GetPoint3
[8] = nil,--GetPoint4

--[[
TODOLIST:
When overriding a chest with a rare the icon doesn't change.

First return is the continentId (instanceId), so you can match if data from another map is on the same instance

local localMap = C_Map.GetBestMapForUnit("player")
local vector = CreateVector2D(x/100, y/100)
local _, temptable = C_Map.GetWorldPosFromMapPos(localMap, vector)
x, y = temptable.x, temptable.y

function GetCurrentWorldPos()
    local uiMapID = C_Map.GetBestMapForUnit("player")
    local mapVector = C_Map.GetPlayerMapPosition(uiMapID, "player")
    local mapX, mapY = mapVector:GetXY()

    local worldVector = CreateVector2D(mapX/100, mapY/100)
    local _, worldPos = C_Map.GetWorldPosFromMapPos(uiMapID, worldVector)
    print(uiMapID, format("%.3f, %.3f ; %.2f, %.2f", mapX, mapY, worldPos:GetXY()))
end
]]

-- /dump C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))

local frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
frame:SetBackdrop({ --[[ Usual backdrop parameters here ]] })

{
	{ Name = "Cosmic", Type = "UIMapType", EnumValue = 0 },
	{ Name = "World", Type = "UIMapType", EnumValue = 1 },
	{ Name = "Continent", Type = "UIMapType", EnumValue = 2 },
	{ Name = "Zone", Type = "UIMapType", EnumValue = 3 },
	{ Name = "Dungeon", Type = "UIMapType", EnumValue = 4 },
	{ Name = "Micro", Type = "UIMapType", EnumValue = 5 },
	{ Name = "Orphan", Type = "UIMapType", EnumValue = 6 },
},

local DRS = CreateFrame("Frame", "DRSMainMenuFrame", UIParent)
DRS:SetShown(false)

--[[
	string = vignetteGUID
	string = objectGUID
	string = name
	bool = isDead
	bool = onWorldMap
	bool = onMinimap
	bool = isUnique
	bool = inFogOfWar
	string = atlasName
	bool = hasTooltip
	Enum.VignetteType = type (0 = Normal, 1 = PvpBounty)
	number = rewardQuestID
	]]

--[[ data structure
rareTable[guid].nameplate = unitToken
rareTable[guid].raidmarker = raidMarkerIndex
rareTable[guid].unitname = unitName
rareTable[guid].x = vignettePosition.x
rareTable[guid].y = vignettePosition.y
rareTable[defGUID].vignette = true
rareTable[fakeGUID].yell = true
rareTable[fakeGUID].emote = true
rareTable[defGUID].unittype = type
rareTable[DRS.AlertFrame2.unitguid].donotshow = true
rareTable[fakeGUID].lastseen = GetServerTime()
rareTable[DRS.AlertFrame1.unitguid].health = floor((UnitHealth(unitTarget) / UnitHealthMax(unitTarget)) * 100)
rareTable[chatGuid].chatsender = sender
--rareTable[guid].uiMapID
]]
local blacklistedCreatures = {--[[135181, ]]138694, 151787, 152671, 152729, 152736, 153088}
local warCrateCreatures = {135181, 135238}
local warCrateGameObjects = {}
local blacklistedObjects = {}
local rareTable = {}
local lookupTable = {}
local _
local tempTable = {}

local sqrt2 = sqrt(2) -- stuff to help texcoord mumbo jumbo later
local rads45 = 0.25*(math.pi)
local rads135 = 0.75*(math.pi)
local rads225 = 1.25*(math.pi)
local cos, sin = math.cos, math.sin

local namePlateScanMounts = {-- [npcID] = mount spellID, itemID (if required or nil if not), chat window message
	[65090] = "300150\a\a122674\aTake Selfie with Fabious for mount.", -- Fabious
	[162681] = "316493\a161128\a\aFeed Seaside Leafy Greens Mix to Elusive Quickhoof for mount.", --Elusive Quickhoof
	}
local mountIDs

local function corner(r)
	return 0.5+cos(r)/sqrt2, 0.5+sin(r)/sqrt2
end

local function MakeAlertFrame(guid)
	local f = CreateFrame("Button", nil, UIParent)
	f.unitguid = guid
	f:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT",-260,450)
	f:SetSize(250, 70)
	f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", insets = {left = 3, right = 3, top = 3, bottom = 3}, tileSize = 16, tile = true, edgeFile = "Interface\\AddOns\\Defs-Rare-Safari\\media\\bor.tga", edgeSize = 16})
	f:SetBackdropBorderColor(0.5, 0.5, 0.5)
	f:SetShown(false)
	f:EnableMouse(true)
	f.MacroBtn = CreateFrame("Button", nil, f, "InsecureActionButtonTemplate")
	f.MacroBtn:SetAttribute("type", "macro")
	f.MacroBtn:SetAttribute("macrotext", [[/dance]])
	f.MacroBtn:SetSize(64, 64)
	f.MacroBtn:SetPoint("LEFT", f, "LEFT", 5, 0)
	f.MacroBtn.texture = f.MacroBtn:CreateTexture(nil,"OVERLAY")
	f.MacroBtn.texture:SetAllPoints(true)
	f:HookScript("OnClick",
		function(self)
			rareTable[self.unitguid].donotshow = true
			local x = self.unitguid
			C_Timer.After(300, function() rareTable[x] = nil end)
			self:Hide()
			self.unitguid = nil
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
				end
			end
		end)
	f.fontString = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f.fontString:SetPoint("CENTER", 10, 20)
	f.fontString:SetText(rareTable[guid].unitname or "Def's Rare Safari")
	f.fontString2 = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f.fontString2:SetPoint("CENTER", 10, 0)
	f.fontString3 = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f.fontString3:SetPoint("CENTER", 10, -20)
	f.fontString4 = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	f.fontString4:SetPoint("BOTTOMRIGHT", -5, 5)
	f:HookScript("OnShow",
		function (self)
			self.fontString3:Hide()
			if self.unitguid then
				if (rareTable[self.unitguid].unittype == "Creature") then
					self.MacroBtn.texture:SetTexture("Interface\\AddOns\\Defs-Rare-Safari\\media\\rare.tga")
					self.MacroBtn:SetAttribute("macrotext", "/target "..rareTable[self.unitguid].unitname)
				elseif (rareTable[self.unitguid].unittype == "GameObject") then
					self.MacroBtn.texture:SetTexture("Interface\\AddOns\\Defs-Rare-Safari\\media\\chest.tga")
					self.MacroBtn:SetAttribute("macrotext", "/dance")
				else
					self.MacroBtn.texture:SetTexture(134400)
					self.MacroBtn:SetAttribute("macrotext", "/dance")
				end
				self.fontString:SetText(rareTable[self.unitguid].unitname or "Def's Rare Safari")
				self.uiMapID = C_Map.GetBestMapForUnit("player")
				if self.uiMapID then
					local position = C_Map.GetPlayerMapPosition(self.uiMapID, "player")
					if rareTable[self.unitguid].x and rareTable[self.unitguid].y and position and position.x and position.y then
						self.Arrow:Show()
					else
						self.Arrow:Hide()
						self.fontString2:Hide()
						self.fontString4:Hide()
					end
				else
					self.Arrow:Hide()
					self.fontString2:Hide()
					self.fontString4:Hide()
				end
			end
		end)
	f:SetScript("OnHide",
		function (self)
			self.unitguid = nil
		end)
	f.Arrow = CreateFrame("Frame", nil, f)
	f.Arrow:SetPoint("RIGHT", f, "RIGHT", 0, 5)
	f.Arrow:SetSize(50, 50)
	f.Arrow.texture = f.Arrow:CreateTexture(nil,"OVERLAY")
	f.Arrow.texture:SetAllPoints(true)
	f.Arrow.texture:SetTexture("Interface\\AddOns\\Defs-Rare-Safari\\media\\arrow.tga")
	f:HookScript("OnUpdate",
		function(self, elapsed)
			self.TimeSinceLastUpdate = ((self.TimeSinceLastUpdate or 0) + elapsed)
			if (self.TimeSinceLastUpdate > .05) then
				self.TimeSinceLastUpdate = 0
				if self.unitguid and rareTable[self.unitguid] and rareTable[self.unitguid].nameplate then
					self.fontString2:Hide()
					self.fontString4:Hide()
					self.Arrow:Hide()
				elseif self.unitguid and rareTable[self.unitguid] and rareTable[self.unitguid].x and rareTable[self.unitguid].y then
					local position = C_Map.GetPlayerMapPosition(self.uiMapID, "player")
					if position and position.x and position.y then
						local player = GetPlayerFacing()
						if not player then
							return
						end
						local dy = -rareTable[self.unitguid].y + position.y
						local dx = rareTable[self.unitguid].x - position.x
						local angle = math.rad(atan2(dy, dx)) - (math.pi/2) - player
						local ULx,ULy = corner(angle + rads225)
						local LLx,LLy = corner(angle + rads135)
						local URx,URy = corner(angle - rads45)
						local LRx,LRy = corner(angle + rads45)
						self.Arrow.texture:SetTexCoord(ULx,ULy,LLx,LLy,URx,URy,LRx,LRy) -- https://wow.gamepedia.com/Applying_affine_transformations_using_SetTexCoord
						local playerContinentID, playerWorldPosition = C_Map.GetWorldPosFromMapPos(self.uiMapID, CreateVector2D(position.x, position.y))
						local targetContinentID, targetWorldPosition = C_Map.GetWorldPosFromMapPos(self.uiMapID, CreateVector2D(rareTable[self.unitguid].x, rareTable[self.unitguid].y))
						local distance
						if (playerContinentID == targetContinentID) then
							local x = abs(playerWorldPosition.x - targetWorldPosition.x)
							local y = abs(playerWorldPosition.y - targetWorldPosition.y)
							distance = sqrt(x*x + y*y)
							distance = floor(distance)
							self.fontString4:SetText(distance)
							self.fontString4:Show()
						else
							self.fontString4:Hide()
						end
						if (distance <= 40) then
							self.Arrow.texture:SetVertexColor(0,1,0)
						elseif (distance <= 200) then
							self.Arrow.texture:SetVertexColor(1,1,1)
						else
							self.Arrow.texture:SetVertexColor(1,0,0)
						end
						if rareTable[self.unitguid].lastseen then
							local timeDifference = GetServerTime() - rareTable[self.unitguid].lastseen
							self.fontString2:SetText(SecondsToTime(timeDifference))
							self.fontString2:Show()
						else
							self.fontString2:Hide()
						end
						self.Arrow:Show()
					else
						self:Hide()
						--self.fontString2:Hide()
						--self.Arrow:Hide()
					end
				else
					self:Hide()
					--self.Arrow:Hide()
					--self.fontString2:Hide()
					--self.fontString4:Hide()
				end
			end
		end)
	f:Show()
	return f
end

--DRS.AlertFrame1.Portrait = CreateFrame("PlayerModel", nil, DRS.AlertFrame1)
--DRS.AlertFrame1.Portrait:SetFrameStrata("FULLSCREEN")
--DRS.AlertFrame1.Portrait:SetPoint("CENTER", DRS.AlertFrame1, "CENTER", -70, 0)
--DRS.AlertFrame1.Portrait:SetSize(50, 50)
--DRS.AlertFrame1.Portrait.texture = DRS.AlertFrame1.Portrait:CreateTexture(nil,"OVERLAY")
--DRS.AlertFrame1.Portrait.texture:SetAllPoints(true)

local soundThrottleTime = 0
local function PlaySoundAlert()
	local timestamp = GetServerTime()
	if ((timestamp - soundThrottleTime) >= 10) then
		soundThrottleTime = timestamp
		PlaySound(18192)
	end
end

local function AcquireAlertFrame(guid)
	if rareTable[guid].donotshow then
		return
	end
	for i = 1, 10 do
		if not DRS["AlertFrame"..i] then
			break
		elseif DRS["AlertFrame"..i] and DRS["AlertFrame"..i].unitguid and (DRS["AlertFrame"..i].unitguid == guid) then
			return
		end
	end
	local maxFrames = 5
	if GetScreenHeight() >= 1200 then
		maxFrames = 10
	end
	for i = 1, maxFrames do
		if not DRS["AlertFrame"..i] then
			PlaySoundAlert()
			DRS["AlertFrame"..i] = MakeAlertFrame(guid)
			if (i == 1) then
				DRS.AlertFrame1:SetMovable(true)
				DRS.AlertFrame1:SetClampedToScreen(true)
				DRS.AlertFrame1:RegisterForDrag("LeftButton")
				DRS.AlertFrame1:SetScript("OnDragStart",
					function(self)
						if not self.isLocked then
							self:StartMoving()
						end
					end)
				DRS.AlertFrame1:SetScript("OnDragStop",
					function(self)
						self:StopMovingOrSizing()
						local _
						DRSa[500], _, DRSa[501], DRSa[502], DRSa[503] = DRS.AlertFrame1:GetPoint(1)
					end)
				--[[DRS.AlertFrame1:HookScript("OnUpdate", function(self, elapsed)
					self.TimeSinceLastUpdate = ((self.TimeSinceLastUpdate or 0) + elapsed)
					if (self.TimeSinceLastUpdate > .05) then
						self.TimeSinceLastUpdate = 0
						local function frameAlgorithm()
							for i = 1, 10 do
								
							end
						end
						frameAlgorithm()
					end
				end]]
				if DRSa[500] and DRSa[501] and DRSa[502] and DRSa[503] then
					DRS.AlertFrame1:ClearAllPoints()
					DRS.AlertFrame1:SetPoint(DRSa[500] or "BOTTOMRIGHT", UIParent,  DRSa[501] or "BOTTOMRIGHT", DRSa[502] or -260, DRSa[503] or 450)
				end
			else
				local x = i - 1
				DRS["AlertFrame"..i]:ClearAllPoints()
				DRS["AlertFrame"..i]:SetPoint("BOTTOM", DRS["AlertFrame"..x], "TOP", 0, 0)
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

--local function SendAddonMessageToPartyGuild(guid, remove)
	-- local chatUiMapID, chatGuid, chatRaidmarker, chatUnitname, chatX, chatY, chatHealth, chatLastseen = strsplit("\a",text)
	--[[local uiMapID = C_Map.GetBestMapForUnit("player")
	local chatString = strjoin("\a", uiMapID, defGUID, (rareTable[defGUID].raidmarker or nil), rareTable[defGUID].unitName, (rareTable[defGUID].x or nil), (rareTable[defGUID].y or nil), (rareTable[defGUID].health or nil), rareTable[defGUID].lastseen, remove)
	C_ChatInfo.SendAddonMessage("Def's RS", chatString, "PARTY")]]
	--C_ChatInfo.SendAddonMessage("Def's RS", chatString, "GUILD")
--end

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

--[[local function ChatMessageAddon(text,channel,sender)
	local chatUiMapID, chatGuid, chatRaidmarker, chatUnitname, chatX, chatY, chatHealth, chatLastseen, remove = strsplit("\a",text)
	local uiMapID = C_Map.GetBestMapForUnit("player")
	if (uiMapID == chatUiMapID) then
		rareTable[chatGuid] = rareTable[chatGuid] or {}
		rareTable[chatGuid].raidmarker = chatRaidmarker
		rareTable[chatGuid].unitname = chatUnitname
		rareTable[chatGuid].x = chatX
		rareTable[chatGuid].y = chatY
		rareTable[chatGuid].health = chatHealth
		rareTable[chatGuid].lastseen = chatLastseen
		rareTable[chatGuid].chatsender = sender
	end]]
	--[[
	rareTable[guid].nameplate = unitToken
	rareTable[guid].raidmarker = raidMarkerIndex
	rareTable[guid].unitname = unitName
	rareTable[guid].x = vignettePosition.x
	rareTable[guid].y = vignettePosition.y
	rareTable[defGUID].vignette = true
	rareTable[fakeGUID].yell = true
	rareTable[fakeGUID].emote = true
	rareTable[defGUID].unittype = type
	rareTable[DRS.AlertFrame2.unitguid].donotshow = true
	rareTable[fakeGUID].lastseen = GetServerTime()
	rareTable[DRS.AlertFrame1.unitguid].health = floor((UnitHealth(unitTarget) / UnitHealthMax(unitTarget)) * 100)
	rareTable[chatGuid].chatsender = sender
	]]
--end

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
			DRS["AlertFrame"..i].fontString3:SetText(rareTable[DRS["AlertFrame"..i].unitguid].health.." %")
			
			DRS["AlertFrame"..i].fontString3:Show()
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
					DRS["AlertFrame"..i].fontString3:SetText(rareTable[DRS["AlertFrame"..i].unitguid].health.." %")
					DRS["AlertFrame"..i].fontString3:Show()
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

local function ScanVignette(vignetteGUID, warCrateScanningOnly)
	local VignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
	if VignetteInfo and VignetteInfo.objectGUID then
		local type, _, _, _, _, npcID = strsplit("-", VignetteInfo.objectGUID)
		--print("type "..type.." npcID "..npcID)
		if (type == "Creature") then
			if warCrateScanningOnly then
				--============================
				local x = "type "..type.." npcID "..npcID
				if (#tempTable == 0) then
					tinsert(tempTable,x)
					print(x)
				else
					for i = #tempTable, 1, (-1) do
						if (tempTable[i] == x) then
							break
						elseif (i == 1) then
							tinsert(tempTable,x)
							print(x)
						end
					end
				end
				--============================
				for i = #warCrateCreatures, 1, (-1) do
					if (tonumber(npcID) == warCrateCreatures[i]) then
						break
					elseif (i == 1) then
						return
					end
				end
			else
				for i = 1, #blacklistedCreatures do
					if (tonumber(npcID) == blacklistedCreatures[i]) then
						--print("blacklisted "..npcID)
						return
					end
				end
				if (tonumber(npcID) == 151933) then -- Malfunctioning Beastbot
					return
				end
			end
		elseif (type == "GameObject") then
			if warCrateScanningOnly then
				--============================
				local x = "type "..type.." npcID "..npcID
				if (#tempTable == 0) then
					tinsert(tempTable,x)
					print(x)
				else
					for i = #tempTable, 1, (-1) do
						if (tempTable[i] == x) then
							break
						elseif (i == 1) then
							tinsert(tempTable,x)
							print(x)
						end
					end
				end
				--============================
				if (#warCrateGameObjects == 0) then
					return
				end
				for i = #warCrateGameObjects, 1, (-1) do
					if (tonumber(npcID) == warCrateGameObjects[i]) then
						break
					elseif (i == 1) then
						return
					end
				end
			else
				for i = 1, #blacklistedObjects do
					if (tonumber(npcID) == blacklistedObjects[i]) then
						--print("blacklisted "..npcID)
						return
					end
				end
				--print(npcID)
				if (tonumber(npcID) == 325626) and (GetItemCount(174765) < 1) and (GetItemCount(174764) < 6) then -- Amathet Reliquary
					return
				elseif (tonumber(npcID) == 341469) and (GetItemCount(174766) < 1) and (GetItemCount(174760) < 6) then -- Ambered Coffer
					return
				elseif (tonumber(npcID) == 335703) and (GetItemCount(174768) < 1) and (GetItemCount(174758) < 6) then -- Black Empire Coffer
					return
				elseif (tonumber(npcID) == 339243) and (GetItemCount(174761) < 1) and (GetItemCount(174756) < 6) then -- Infested Strongbox
					return
				elseif (tonumber(npcID) == 334241) and (GetItemCount(174767) < 1) and (GetItemCount(174759) < 6) then -- Mogu Strongbox
					return
				end
			end
		elseif (type == "Vehicle") and (npcID == "151623") then -- The Scrap King
			type = "Creature"
			npcID = "151625"
		end
		if (type == "Creature") or (type == "GameObject") then
			local defGUID = strjoin("\a",type,npcID)
			--print("1")
			if not rareTable[defGUID] or not rareTable[defGUID].donotshow then
				--print("2")
				if not lookupTable[defGUID] then
					--local uiMapID = C_Map.GetBestMapForUnit("player")
					--if uiMapID == 1355 then
						--print("type is "..(type or "unknown").." -- "..(VignetteInfo.name or "unknown").." is "..(npcID or "unknown"))--======================================
					--end
					lookupTable[defGUID] = VignetteInfo.name --===============================================
				end
				rareTable[defGUID] = rareTable[defGUID] or {}
				rareTable[defGUID].unittype = type
				rareTable[defGUID].unitname = VignetteInfo.name
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
				local uiMapID = C_Map.GetBestMapForUnit("player")
				if uiMapID then
					--rareTable[defGUID].uiMapID = uiMapID
					local vignettePosition = C_VignetteInfo.GetVignettePosition(vignetteGUID, uiMapID)
					if vignettePosition then
						if (vignettePosition and (vignettePosition.x ~= 0) and (vignettePosition.y ~= 0)) then
							rareTable[defGUID].x = vignettePosition.x
							rareTable[defGUID].y = vignettePosition.y
						end
					end
				end
				AcquireAlertFrame(defGUID)
				--if (type == "Creature") then
					--SendAddonMessageToPartyGuild(defGUID)
				--end
			end
		end
	end
	--[[
	string = vignetteGUID
	string = objectGUID
	string = name
	bool = isDead
	bool = onWorldMap
	bool = onMinimap
	bool = isUnique
	bool = inFogOfWar
	string = atlasName
	bool = hasTooltip
	Enum.VignetteType = type (0 = Normal, 1 = PvpBounty)
	number = rewardQuestID
	]]
end

local function ScanAllVignettes(warCrateScanning)
	--print("007")
	local vignetteGUIDs = C_VignetteInfo.GetVignettes()
	if vignetteGUIDs then
		for i in pairs(vignetteGUIDs) do
			local VignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUIDs[i])
			if VignetteInfo and VignetteInfo.objectGUID then
				--print(VignetteInfo.objectGUID)
				ScanVignette(vignetteGUIDs[i], warCrateScanning)
			end
		end
		for k in pairs(rareTable) do
			if rareTable[k].vignette then
				local x
				for i in pairs(vignetteGUIDs) do
					local VignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUIDs[i])
					if VignetteInfo and VignetteInfo.objectGUID then
						if (rareTable[k].vignette == VignetteInfo.objectGUID) then
							x = true
							break
						else
							local type, _, _, _, _, npcID = strsplit("-", VignetteInfo.objectGUID)
							if (type == "Vehicle") and (npcID == "151623") then -- The Scrap King
								type = "Creature"
								npcID = "151625"
								x = true
								break
							elseif (type == "Creature") or (type == "GameObject") then
								local defGUID = strjoin("\a",type,npcID)
								if (k == defGUID) then
									x = true
									break
								end
							end
						end
					end
				end
				if not x then
					if not rareTable[k].donotshow then
						if rareTable[k].nameplate then
							--print("removeVignette1")
							rareTable[k].vignette = nil
						else
							--SendAddonMessageToPartyGuild(k, true)
							--print("removeVignette2")
							RemoveAlertFrame(k)
							rareTable[k] = nil
						end
					end
				end
			end
		end
	else
		for k in pairs(rareTable) do
			if not rareTable[k].donotshow then
				if rareTable[k].vignette then
					--SendAddonMessageToPartyGuild(k, true)
					--print("removeVignette3")
					RemoveAlertFrame(k)
					rareTable[k] = nil
				end
			end
		end
	end
end

local function RareSafariZoneControl()
	local uiMapID = C_Map.GetBestMapForUnit("player")
	if uiMapID then
		local _, instanceType = GetInstanceInfo()
		if (instanceType == "none") then
			local UiMapDetails = C_Map.GetMapInfo(uiMapID) -- /dump C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
			if UiMapDetails and (UiMapDetails.mapType ~= 6) then
				if (UiMapDetails.mapType >= 3) then
					 for i = 1, (UiMapDetails.mapType - 2) do
						UiMapDetails = C_Map.GetMapInfo(uiMapID)
						if (UiMapDetails.mapType == 3) then
							local x = C_Map.GetMapInfo(UiMapDetails.parentMapID)
							if x and x.mapType and (x.mapType == 3) then
								uiMapID = UiMapDetails.parentMapID
								break
							end
						end
						if UiMapDetails and UiMapDetails.mapType and (UiMapDetails.mapType <= 3) then
							break
						elseif UiMapDetails and UiMapDetails.parentMapID then
							uiMapID = UiMapDetails.parentMapID
						else
							break
						end
					 end
				end
			end
			local t = {862, 863, 864, 895, 896, 942} -- War crate only scanning
			for i = #t, 1, (-1) do
				if (uiMapID == t[i]) then
					DRS:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
					DRS:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
					DRS:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
					DRS:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
					DRS:UnregisterEvent("UNIT_HEALTH_FREQUENT")
					DRS:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
					DRS:RegisterEvent("VIGNETTES_UPDATED")
					ScanAllVignettes(true)
					return
				end
			end
			t = {1527,1530} -- Zones without Emotes or Yells
			for i = #t, 1, (-1) do
				if (uiMapID == t[i]) then
					DRS:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
					DRS:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
					DRS:RegisterEvent("NAME_PLATE_UNIT_ADDED")
					DRS:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
					DRS:RegisterEvent("UNIT_HEALTH_FREQUENT")
					DRS:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
					DRS:RegisterEvent("VIGNETTES_UPDATED")
					ScanAllVignettes(false)
					return
				end
			end
			t = {1462} -- Zones with Emotes and Yells
			for i = #t, 1, (-1) do
				if (uiMapID == t[i]) then
					DRS:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
					DRS:RegisterEvent("CHAT_MSG_MONSTER_YELL")
					DRS:RegisterEvent("NAME_PLATE_UNIT_ADDED")
					DRS:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
					DRS:RegisterEvent("UNIT_HEALTH_FREQUENT")
					DRS:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
					DRS:RegisterEvent("VIGNETTES_UPDATED")
					ScanAllVignettes(false)
					return
				end
			end
			t = {1355} -- Zones with Yells
			for i = #t, 1, (-1) do
				if (uiMapID == t[i]) then
					DRS:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
					DRS:RegisterEvent("CHAT_MSG_MONSTER_YELL")
					DRS:RegisterEvent("NAME_PLATE_UNIT_ADDED")
					DRS:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
					DRS:RegisterEvent("UNIT_HEALTH_FREQUENT")
					DRS:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
					DRS:RegisterEvent("VIGNETTES_UPDATED")
					ScanAllVignettes(false)
					return
				end
			end
			DRS:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
			DRS:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
			DRS:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
			DRS:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
			DRS:UnregisterEvent("QUEST_COMPLETE")
			DRS:UnregisterEvent("UNIT_HEALTH_FREQUENT")
			DRS:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED")
			DRS:UnregisterEvent("VIGNETTES_UPDATED")
		else
			DRS:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
			DRS:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
			DRS:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
			DRS:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
			DRS:UnregisterEvent("QUEST_COMPLETE")
			DRS:UnregisterEvent("UNIT_HEALTH_FREQUENT")
			DRS:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED")
			DRS:UnregisterEvent("VIGNETTES_UPDATED")
		end
	else
		DRS:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
		DRS:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
		DRS:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
		DRS:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
		DRS:UnregisterEvent("QUEST_COMPLETE")
		DRS:UnregisterEvent("UNIT_HEALTH_FREQUENT")
		DRS:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED")
		DRS:UnregisterEvent("VIGNETTES_UPDATED")
		C_Timer.After(0.5, RareSafariZoneControl)
	end
end

--[[
For players: Player-[server ID]-[player UID] (Example: "Player-976-0002FD64")
For creatures, pets, objects, and vehicles: [Unit type]-0-[server ID]-[instance ID]-[zone UID]-[ID]-[Spawn UID] (Example: "Creature-0-976-0-11-31146-000136DF91")
Unit Type Names: "Creature", "Pet", "GameObject", and "Vehicle"
For vignettes: Vignette-0-[server ID]-[instance ID]-[zone UID]-0-[spawn UID] (Example: "Vignette-0-970-1116-7-0-0017CAE465" for rare mob Sulfurious) 
]]

DRS:SetScript("OnEvent",function(self,event,...)
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
		ChatEmote(...)
	elseif (event == "CHAT_MSG_MONSTER_YELL") then
		ChatYell(...)
	elseif (event == "NAME_PLATE_UNIT_ADDED") then
		local unitToken = ...
		--tinsert(nameplatesInUse,unitToken)
		--print("NAME_PLATE_UNIT_ADDED "..unitToken)
		ScanNameplates(unitToken)
	elseif (event == "NAME_PLATE_UNIT_REMOVED") then
		local unitToken = ...
		RemoveNamePlate(unitToken)
		--print("NAME_PLATE_UNIT_REMOVED "..unitToken)
	elseif (event == "VIGNETTE_MINIMAP_UPDATED") then
		local vignetteGUID--[[, onMinimap]] = ...
		--print("VIGNETTE_MINIMAP_UPDATED")
		--ScanVignette(vignetteGUID)
		--ScanAllVignettes()
		RareSafariZoneControl()
		--print(vignetteGUID)
		--print(onMinimap)
	elseif (event == "VIGNETTES_UPDATED") then
		--print("VIGNETTES_UPDATED")
		--ScanAllVignettes()
		--C_Timer.After(1,ScanAllVignettes)
		RareSafariZoneControl()
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin, isReloadingUi = ...
		if isInitialLogin or isReloadingUi then
			--[[_, _, _, tocversion = GetBuildInfo()
			if (tocversion >= 80100) then
				retail = true
				GetCVar, SetCVar = C_CVar.GetCVar, C_CVar.SetCVar
			end]]
			--C_ChatInfo.RegisterAddonMessagePrefix("Def's RS")
		end -- END isInitialLogin or isReloadingUi
		if isInitialLogin then
			DRSa = DRSa or {-->1 to 499 for settings, 500-1000 for data
				[500] = nil, -- point
				[501] = nil, -- relativePoint
				[502] = nil, -- offsetX
				[503] = nil, -- offsetY
				}
			DRSc = DRSc or {-->1 to 499 for settings, 500-1000 for data
				[1] = nil,
				[2] = nil,
				}
		end -- END isInitialLogin
		RareSafariZoneControl()
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		--if isInitialLogin or isReloadingUi then
		--end -- END isInitialLogin or isReloadingUi
	elseif event=="SAVED_VARIABLES_TOO_LARGE" then
		local addOnName=...
		if addOnName=="Defs-Rare-Safari" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
	elseif (event == "UNIT_HEALTH_FREQUENT") then
		local unitTarget = ...
		NamePlateHealth(unitTarget)
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		RareSafariZoneControl()
	end end)
--DRS:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")--======================================
DRS:RegisterEvent("PLAYER_ENTERING_WORLD")
DRS:RegisterEvent("SAVED_VARIABLES_TOO_LARGE")

--> Menu System
--[[
local function CloseMenuSystem()
	DRS:Hide()
	DRS.sideFrame.myPools:ReleaseAll()
	DRS.myPools:ReleaseAll()
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:Hide()
end

local function MenuSetup(tab,tabPage,utilityTab1Page4ItemID,utilityTab1Page4ItemLink,utilityTab1Page4ButtonTexture,bindOnAccountItem)
	local _, _, playerClassID = UnitClass("player")
	local playerFaction = UnitFactionGroup("player")
	DRS.sideFrame.myPools:ReleaseAll()
	DRS.myPools:ReleaseAll()
	tempMenuUsage1,tempMenuUsage2,tempMenuUsage3,tempMenuUsage4,tempMenuUsage5,tempMenuUsage6,tempMenuUsage7=nil,nil,nil,nil,nil,nil,nil
	local function DefsRSCreateMainMenuOptionsButton(point,relativeTo,relativePoint,offsetX,offsetY,displayName,sizeWide,sizeHeight)
		local f=DRS.myPools:Acquire("OptionsButtonTemplate")--local f=DRS.myPools:Acquire("UIExpandingButtonTemplate")--"UIExpandingButtonTemplate"
		f:Enable()
		f:SetScript("OnShow",nil)
		f:SetScript("OnUpdate",nil)
		f:SetScript("OnClick",nil)
		f:SetScript("OnHide",nil)
		f:SetScript("OnEnter",nil)
		f:SetScript("OnLeave",nil)
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER",relativeTo or DRS,relativePoint or "CENTER",offsetX,offsetY)
		f:SetText(displayName or nil)
		if sizeWide and sizeHeight then f:SetSize(sizeWide,sizeHeight) end
		return f
	end
	local function DefsRSCreateMainMenuUICheckButton(point,relativeTo,relativePoint,offsetX,offsetY,displayName,tooltipInfo,onShow,onClick,onHide,onUpdate)
		local f=DRS.myPools:Acquire("UICheckButtonTemplate")
		f:SetSize(25,25)
		f.text:SetText(nil)
		f.text:SetTextColor(1,1,1)
		f:Enable()
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER",relativeTo or DRS,relativePoint or "CENTER",offsetX,offsetY)
		f.text:SetText(displayName or "")
		if tooltipInfo then
			f:SetScript("OnEnter",function()
				GameTooltip:SetOwner(f,"ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOM",f,"TOP",0,10)
				GameTooltip:SetText(tooltipInfo or "")
				GameTooltip:Show() end)
			f:SetScript("OnLeave",function()
				GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
				GameTooltip:Hide() end)
		else
			f:SetScript("OnEnter",nil)
			f:SetScript("OnLeave",nil)
		end
		f:SetScript("OnShow",onShow or nil)
		f:SetScript("OnClick",onClick or nil)
		f:SetScript("OnHide",onHide or nil)
		if onUpdate then
			f:SetScript("OnUpdate",function(self,elapsed) self.TimeSinceLastUpdate=(self.TimeSinceLastUpdate or 0)+elapsed if self.TimeSinceLastUpdate>0.1 then self.TimeSinceLastUpdate=0 if InCombatLockdown() then self:Disable() else self:Enable() end end end)
		else
			f:SetScript("OnUpdate",nil)
		end
		f:Show()
		return f
	end
	local function DefsRSCreateSideFrameUICheckButton(point,relativeTo,relativePoint,offsetX,offsetY,displayName,tooltipInfo,onShow,onClick,onHide,onUpdate)
		local f=DRS.sideFrame.myPools:Acquire("UICheckButtonTemplate")
		f:SetSize(25,25)
		f.text:SetText(nil)
		f.text:SetTextColor(1,1,1)
		f:Enable()
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER",relativeTo or DRS.sideFrame,relativePoint or "CENTER",offsetX,offsetY)
		f.text:SetText(displayName or "")
		if tooltipInfo then
			f:SetScript("OnEnter",function()
				GameTooltip:SetOwner(f,"ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOM",f,"TOP",0,10)
				GameTooltip:SetText(tooltipInfo or "")
				GameTooltip:Show() end)
			f:SetScript("OnLeave",function()
				GameTooltip_SetDefaultAnchor(GameTooltip,UIParent)
				GameTooltip:Hide() end)
		else
			f:SetScript("OnEnter",nil)
			f:SetScript("OnLeave",nil)
		end
		f:SetScript("OnShow",onShow or nil)
		f:SetScript("OnClick",onClick or nil)
		f:SetScript("OnHide",onHide or nil)
		if onUpdate then
			f:SetScript("OnUpdate",function(self,elapsed) self.TimeSinceLastUpdate=(self.TimeSinceLastUpdate or 0)+elapsed if self.TimeSinceLastUpdate>0.1 then self.TimeSinceLastUpdate=0 if InCombatLockdown() then self:Disable() else self:Enable() end end end)
		else
			f:SetScript("OnUpdate",nil)
		end
		f:Show()
		return f
	end
	local function DefsRSCreateMainMenuItemButton(point, relativeTo, relativePoint, offsetX, offsetY, textureNumber)
		local f
		if retail then
			f = DRS.myPools:Acquire("ContainerFrameItemButtonTemplate")
		else
			f = DRS.myPools:Acquire("ItemButtonTemplate")
		end
		f:SetSize(64, 64)
		f:Enable()
		f:SetScript("OnShow", nil)
		f:SetScript("OnClick", nil)
		f:SetScript("OnHide", nil)
		f:SetScript("OnEnter", nil)
		f:SetScript("OnLeave", nil)
		f:SetAlpha(1)
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER", relativeTo or DRS, relativePoint or "CENTER", offsetX, offsetY)
		f:SetNormalTexture(textureNumber or nil)
		if retail then
			f.BattlepayItemTexture:Hide()
		end
		if not f.fontString then
			f.fontString = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		else
			f.fontString:SetText(nil)
		end
		f.fontString:SetPoint("CENTER", -32, 0)
		return f
	end
	local function DefsRSCreateSideFrameItemButton(point, relativeTo, relativePoint, offsetX, offsetY, textureNumber)
		local f
		if retail then
			f = DRS.sideFrame.myPools:Acquire("ContainerFrameItemButtonTemplate")
		else
			f = DRS.sideFrame.myPools:Acquire("ItemButtonTemplate")
		end
		f:SetSize(64, 64)
		f:Enable()
		f:SetScript("OnShow", nil)
		f:SetScript("OnClick", nil)
		f:SetScript("OnHide", nil)
		f:SetScript("OnEnter", nil)
		f:SetScript("OnLeave", nil)
		f:SetAlpha(1)
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER", relativeTo or DRS.sideFrame, relativePoint or "CENTER", offsetX, offsetY or 50)
		f:SetNormalTexture(textureNumber or nil)
		if retail then
			f.BattlepayItemTexture:Hide()
		end
		if not f.fontString then
			f.fontString = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		else
			f.fontString:SetText(nil)
		end
		f.fontString:SetPoint("CENTER", 0, -100)
		return f
	end
	local function DefsRSCreateMainMenuInputBox(point, relativeTo, relativePoint, offsetX, offsetY)
		local f = DRS.myPools:Acquire("InputBoxTemplate")
		f:SetSize(40, 32)
		f:SetAutoFocus(false)
		f:SetMaxLetters(4)
		f:Enable()
		f:SetText("")
		f:SetScript("OnShow", nil)
		f:SetScript("OnEnterPressed", nil)
		f:SetScript("OnEscapePressed", function()
			CloseMenuSystem()
		end)
		f:SetScript("OnEditFocusLost", nil)
		f:SetScript("OnHide", nil)
		f:SetScript("OnEnter", nil)
		f:SetScript("OnLeave", nil)
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER", relativeTo or DRS, relativePoint or "CENTER", offsetX, offsetY)
		return f
	end
	local function DefsRSCreateSideFrameInputBox(point, relativeTo, relativePoint, offsetX, offsetY)
		local f = DRS.sideFrame.myPools:Acquire("InputBoxTemplate")
		f:SetSize(40, 32)
		f:SetAutoFocus(false)
		f:SetMaxLetters(4)
		f:Enable()
		f:SetText("")
		f:SetScript("OnShow", nil)
		f:SetScript("OnEnterPressed", nil)
		f:SetScript("OnEscapePressed", function()
			CloseMenuSystem()
		end)
		f:SetScript("OnEditFocusLost", nil)
		f:SetScript("OnHide", nil)
		f:SetScript("OnEnter", nil)
		f:SetScript("OnLeave", nil)
		f:ClearAllPoints()
		f:SetPoint(point or "CENTER", relativeTo or DRS.sideFrame, relativePoint or "CENTER", offsetX, offsetY)
		return f
	end
	local function MainMenuFontStrings(fontStrings)
		for i=1,10 do
			if not DRS["fontString"..i] then
				DRS["fontString"..i] = DRS:CreateFontString(nil,"ARTWORK","GameFontNormal")
				DRS["fontString"..i]:Show()
				DRS["fontString"..i]:SetTextColor(1,.82,0)
			else
				DRS["fontString"..i]:SetText(nil)
				DRS["fontString"..i]:ClearAllPoints()
				if i<=fontStrings then
					DRS["fontString"..i]:SetTextColor(1,.82,0)
				else
					DRS["fontString"..i]:Hide()
				end
			end
		end
	end
	local function DefsRSSideFrameFontStrings(fontStrings)
		for i=1,6 do
			if not DRS.sideFrame["fontString"..i] then
				DRS.sideFrame["fontString"..i] = DRS.sideFrame:CreateFontString(nil,"ARTWORK","GameFontNormal")
				DRS.sideFrame["fontString"..i]:Show()
				DRS.sideFrame["fontString"..i]:SetTextColor(1,.82,0)
			else
				DRS.sideFrame["fontString"..i]:SetText(nil)
				DRS.sideFrame["fontString"..i]:ClearAllPoints()
				if i<=fontStrings then
					DRS.sideFrame["fontString"..i]:SetTextColor(1,.82,0)
				else
					DRS.sideFrame["fontString"..i]:Hide()
				end
			end
		end
	end
	if tab=="Account" then
		DRS.sideFrame:Hide()
		tab=1
	elseif tab=="Character" then
		DRS.sideFrame:Hide()
		tab=1
	elseif tab=="Utility" then
		DRS.sideFrame:Hide()
		tab=1
	end
	if (tab == 1) then
		if (menuSelection == "Account") then
			MainMenuFontStrings(0)
			DefsRSSideFrameFontStrings(5)
			local sideFrameFontString1 = DRS.sideFrame.fontString1
			sideFrameFontString1:SetPoint("TOP", 0, -20)
			sideFrameFontString1:SetText("Alert System")
			sideFrameFontString1:Show()
			local BfA = (-40)
			local sideFrameFontString2 = DRS.sideFrame.fontString2
			sideFrameFontString2:SetPoint("TOP", 0, BfA)
			sideFrameFontString2:SetText((EXPANSION_NAME7 or "Battle for Azeroth").." +")
			sideFrameFontString2:Show()
			local Legion = (-120)
			local sideFrameFontString3 = DRS.sideFrame.fontString3
			sideFrameFontString3:SetPoint("TOP", 0, (Legion))
			sideFrameFontString3:SetText((EXPANSION_NAME6 or "Legion").." +")
			sideFrameFontString3:Show()
			local WoD = (-180)
			local sideFrameFontString4 = DRS.sideFrame.fontString4
			sideFrameFontString4:SetPoint("TOP", 0, WoD)
			sideFrameFontString4:SetText(EXPANSION_NAME5.." +")
			sideFrameFontString4:Show()
			local chkBtn1 = DefsRSCreateMainMenuUICheckButton(nil, nil, "TOPLEFT", 30, -28, "Max camera zooming beyond the default slider", "Camera can be set to a max zoom distance farther than the default slider allows. (2.6 vs 1.8)",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[1])
				end,
				function(self) -- "OnClick"
					DRSa[1] = self:GetChecked()
					if DRSa[1] then
						SetCVar("cameraDistanceMaxZoomFactor",2.6)
					else
						SetCVar("cameraDistanceMaxZoomFactor",1.8)
					end
				end)
			local chkBtn2 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn1, "CENTER", 0, -20, "\"Thank\" emote 2 seconds after random dungeon completion.", nil,
				function(self) -- "OnShow"
					if not retail then
						self:Hide()
					else
						self:SetChecked(DRSa[3])
					end
				end,
				function(self) -- "OnClick"
					DRSa[3] = self:GetChecked()
				end)
			local btn1 = DefsRSCreateMainMenuOptionsButton("CENTER", chkBtn2, "CENTER", 350, -20, "move default tooltip location", 190, 26)
			if not retail then
				btn1:SetPoint("CENTER", chkBtn2, "CENTER", 350, 0)
			end
			if DRSa[519] then
				btn1:Show()
				btn1:SetText("reset default tooltip location")
			elseif not DRSa[4] then
				btn1:Show()
			end
			btn1:SetScript("OnClick",
				function(self)
					if DRSa[519] then
						DRSa[519] = nil
						DRSa[40] = nil
						self:SetText("move default tooltip location")
					else
						DRSa[40] = true
						FrameCreation("GameTooltipLocationMover")
						CloseMenuSystem()
					end
				end)
			local chkBtn3 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn2, "CENTER", 0, -20, "Tooltips appear at mouse rather than in corner.", "The Auction House window disables this to prevent viewing issues with auction house addons.",
				function(self)
					self:SetChecked(DRSa[4])
					if not retail then
						self:SetPoint("CENTER", chkBtn2, "CENTER", 0, 0)
					end
				end,
				function(self)
					DRSa[4] = self:GetChecked()
					if DRSa[4] then
						FrameHook("GameTooltip")
						btn1:Hide()
						DRSa[40] = nil
						DRSa[519] = nil
						if DRS.GameTooltipLocationMover then
							DRS.GameTooltipLocationMover:Hide()
						end
					else
						btn1:Show()
					end
				end)
			local chkBtn4=DefsRSCreateMainMenuUICheckButton("CENTER",chkBtn3,"CENTER",0,-20,"Hide Tooltips during combat.","Mousing over buffs/debuffs still show tooltips, but mousing over players and other frames won't.",function(self) self:SetChecked(DRSa[5]) end,function(self) DRSa[5] = self:GetChecked() FrameHook("GameTooltip") end)
			local chkBtn5=DefsRSCreateMainMenuUICheckButton("CENTER",chkBtn4,"CENTER",0,-20,"Show \"Casted by:\" on tooltips when hovering over a buff/debuff.",nil,function(self) self:SetChecked(DRSa[6]) end,function(self) DRSa[6] = self:GetChecked() FrameHook("GameTooltip") end)
			local chkBtn6 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn5, "CENTER", 0, -20, "Hide Quests during combat and inside instances.", "This should leave quests displayed when you're near their objectives.",
				function(self)
					self:SetChecked(DRSa[7])
				end,
				function(self)
					DRSa[7] = self:GetChecked()
					if DRSa[7] then
						SetCVar("autoquestwatch", "1")
					end
				end)
			--local chkBtn7 removed
			local chkBtn8 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn6, "CENTER", 0, -20, "Say \"Sapped\" when sapped by a rogue.", "This only reports in open world and pvp instances.",
				function(self)
					self:SetChecked(DRSa[17])
				end,
				function(self)
					DRSa[17] = self:GetChecked()
				end)
			local chkBtn9 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn8, "CENTER",0,-20,"Hide the player hit indicator numbers.", "These are the numbers over the portrait in the player frame.",
				function(self)
					self:SetChecked(DRSa[18])
				end,
				function(self)
					DRSa[18] = self:GetChecked()
				end)
			--local chkBtn10 removed
			local chkBtn11 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn9, "CENTER", 0, -20, "Alerts for Missions, Professions, and World Quests being active.", nil,
				function(self) -- "OnShow"
					if not retail then
						self:Hide()
					else
						local t = {9, 10, 11, 12, 13, 14, 15, 19, 25, 31, 33, 34, 36, 41, 517} -- update menu system chkBtn11 OnShow, chkBtn11 OnClick, and  "PLAYER_ENTERING_WORLD" event x2
						for i = 1, #t do
							if DRSa[t[i] ] then
								self:SetChecked(true)
								DRS.sideFrame:Show()
								DRS.sideFrame:SetSize(460, 350)
								return
							elseif (i == #t) then
								self:SetChecked(false)
								DRS.sideFrame:Hide()
								return
							end
						end
						DRS.sideFrame:Hide()
					end
				end)
			local x
			if retail then
				x = C_TradeSkillUI.GetTradeSkillDisplayName(2549) or "BfA Herbalism"
			else
				x = "BfA Herbalism"
			end
			local chkBtn12 = DefsRSCreateSideFrameUICheckButton(nil, nil, "TOPLEFT", 30, (BfA - 28), (x), "Herbalists only.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[9])
				end,
				function(self) -- "OnClick"
					DRSa[9] = self:GetChecked()
				end)
			if retail then
				x = C_TradeSkillUI.GetTradeSkillDisplayName(2565) or "BfA Mining"
			else
				x = "BfA Mining"
			end
			--[ [local chkBtn13 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn12, "CENTER", 230, 0, (x), "Miners only.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[13])
				end,
				function(self) -- "OnClick"
					DRSa[13] = self:GetChecked()
				end)
			local chkBtn14 = DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn12, "CENTER", 0, -20, (C_Item.GetItemNameByID(163036) or "Polished Pet Charms"), nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[14])
				end,
				function(self) -- "OnClick"
					DRSa[14] = self:GetChecked()
				end)
			--[ [local chkBtn20 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn14, "CENTER", 230, 0, "Pet Battle-Training Stones", nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[34])
				end,
				function(self) -- "OnClick"
					DRSa[34] = self:GetChecked()
				end)
			local chkBtn15 = DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn14, "CENTER", 0, -20, (C_Item.GetItemNameByID(160053) or "Battle-Scarred Augment Runes"), nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[12])
				end,
				function(self) -- "OnClick"
					DRSa[12] = self:GetChecked()
				end)
			local chkBtn17 = DefsRSCreateSideFrameUICheckButton(nil, nil, "TOPLEFT", 30, (Legion - 28), (C_Item.GetItemNameByID(124124) or "Blood of Sargeras"), "WQ with 5+ only.  Alchemists only.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[11])
				end,
				function(self) -- "OnClick"
					DRSa[11] = self:GetChecked()
				end)
			if retail then
				x = C_TradeSkillUI.GetTradeSkillDisplayName(2550) or "Legion Herbalism"
			else
				x = "Legion Herbalism"
			end
			--[ [local chkBtn24 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn17, "CENTER", 230, 0, (x), "Herbalists only.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[19])
				end,
				function(self) -- "OnClick"
					DRSa[19] = self:GetChecked()
				end)
			if retail then
				x = C_TradeSkillUI.GetTradeSkillDisplayName(2566) or "Legion Mining"
			else
				x = "Legion Mining"
			end
			--[ [local chkBtn25 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn17, "CENTER", 0, -20, (x), "Miners only.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[25])
				end,
				function(self) -- "OnClick"
					DRSa[25] = self:GetChecked()
				end)
			--[ [local chkBtn18 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn15, "CENTER", 230, 0, (C_Item.GetItemNameByID(152668) or "Expulsom"), nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[15])
				end,
				function(self) -- "OnClick"
					DRSa[15] = self:GetChecked()
				end)
			local chkBtn19 = DefsRSCreateSideFrameUICheckButton(nil, nil, "TOPLEFT", 30, (WoD - 28), (C_Item.GetItemNameByID(1283150) or "Medallion of the Legion"), nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[33])
				end,
				function(self) -- "OnClick"
					DRSa[33] = self:GetChecked()
				end)
			--[ [local chkBtn21 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn19, "CENTER", 230, 0, "Full Garrison cache", "Based off last time since visiting Draenor.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[36])
				end,
				function(self) -- "OnClick"
					DRSa[36] = self:GetChecked()
				end)
			local chkBtn16 = DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn19, "CENTER", 0, -20, "Unobtained mounts & toys", "These can be rare Argus world quest mount drops,\nreputation missions for Legion paragon mounts and toys, Halaa tokens, etc.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[10])
				end,
				function(self) -- "OnClick"
					DRSa[10] = self:GetChecked()
				end)
			--[ [local chkBtn28 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn16, "CENTER", 230, 0, (C_Item.GetItemNameByID(117492) or "Relic of Ruhkmar"), nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[31])
				end,
				function(self) -- "OnClick"
					DRSa[31] = self:GetChecked()
				end)
			--[ [local chkBtn29 =] ] DefsRSCreateSideFrameUICheckButton("CENTER", chkBtn16, "CENTER", 0, -20, ("Unobtained transmog source IDs"), "These are unlearned source IDs even though you might have the transmog.\nHolding down \''shift\" while clicking this will turn it on/off for this character only and\nand remove the account-wide setting.",
				function(self) -- "OnShow"
					if DRSa[41] then
						self:SetChecked(DRSa[41])
					else
						self:SetChecked(DRSc[29])
					end
				end,
				function(self) -- "OnClick"
					if IsShiftKeyDown() then
						DRSc[29] = self:GetChecked()
						DRSa[41] = nil
					else
						DRSa[41] = self:GetChecked()
					end
				end)
			local chkBtn22 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn11, "CENTER", 0, -20, "World Map coordinates", nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[38])
					if not retail then
						self:SetPoint("CENTER", chkBtn11, "CENTER", 0, 0)
					end
				end)
			local chkBtn23 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn22, "CENTER", 20, -20, "Minimap coordinates", nil,
				function(self) -- "OnShow"
					self:SetChecked(DRSa[37])
				end,
				function(self) -- "OnClick"
					DRSa[37] = self:GetChecked()
					if DRSa[37] then
						FrameHook("Minimap")
						MiniMapCoordinates("PLAYER_ENTERING_WORLD")
						DRS.MinimapCoordinates.fontString:Show()
					else
						MiniMapCoordinates()
						DRS.MinimapCoordinates.fontString:Hide()
					end
				end)
			local chkBtn26 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn22, "CENTER", 0, -20, "Swap hearthstones on action bars for holidays.", "Some restrictions apply.",
				function(self) -- "OnShow"
					if not retail then
						self:Hide()
					else
						self:SetChecked(DRSa[26])
					end
				end)
			if DRSa[38] then
				chkBtn23:Show()
				chkBtn26:SetPoint("CENTER", chkBtn22, "CENTER", 0, -40)
			else
				chkBtn23:Hide()
			end
			chkBtn22:SetScript("OnClick", function(self)
				DRSa[38] = self:GetChecked()
				if DRSa[38] then
					chkBtn23:Show()
					chkBtn26:SetPoint("CENTER", chkBtn22, "CENTER", 0, -40)
					FrameHook("WorldMapFrame")
				else
					chkBtn23:Hide()
					DRSa[37] = nil
					chkBtn26:SetPoint("CENTER", chkBtn22, "CENTER", 0, -20)
					if retail then
						WorldMapFrame.BorderFrame.TitleText:SetText(MAP_AND_QUEST_LOG)
					end
				end
			end)
			local chkBtn27 = DefsRSCreateMainMenuUICheckButton("CENTER", chkBtn26, "CENTER", 20, -20, "Cycle after usage.", "Swaps to next hearthstone after zoning when hearthstone is on cooldown.",
				function(self) -- "OnShow"
					self:SetChecked(DRSa[30])
				end,
				function(self) -- "OnClick"
					DRSa[30] = self:GetChecked()
				end)
			chkBtn26:SetScript("OnClick", function(self)
				DRSa[26] = self:GetChecked()
				if DRSa[26] then
					chkBtn27:Show()
				else
					chkBtn27:Hide()
					DRSa[30] = nil
				end
			end)
			if DRSa[26] then
				chkBtn27:Show()
			else
				chkBtn27:Hide()
			end
			local eb1 = DefsRSCreateSideFrameInputBox("BOTTOM", DRS.sideFrame, "BOTTOM", 55, 20)
			eb1:SetScript("OnShow", function(self)
				self:SetCursorPosition(0)
				self:SetText("")
			end)
			eb1:SetScript("OnEnter",function(self)
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
				GameTooltip:SetText("Obtain Quest IDs using an addon like idTip or\nthe url for wowhead.com on the quest page.")
				GameTooltip:Show()
			end)
			eb1:SetScript("OnEnterPressed", function(self)
				local a = self:GetNumber()
				local b = self:GetText()
				if (tostring(a) == b) and (a > 0) then
					if DRSa[517] and (type(DRSa[517]) == "table") then
						if DRSa[517][a] then
							if (DRSa[517][a] == 0) then
								DRSa[517][a] = 1
								self:SetText("")
								self:SetCursorPosition(0)
								self:ClearFocus()
								GameTooltip:SetOwner(self, "ANCHOR_NONE")
								GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
								GameTooltip:SetText("Now whitelisting "..a.."\nEnter again to reset.")
								GameTooltip:Show()
							elseif (DRSa[517][a] == 1) then
								DRSa[517][a] = nil
								self:SetText("")
								self:SetCursorPosition(0)
								self:ClearFocus()
								GameTooltip:SetOwner(self, "ANCHOR_NONE")
								GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
								GameTooltip:SetText("Removed "..a.." from both\nwhitelist and blacklist.")
								GameTooltip:Show()
							end
						else
							DRSa[517][a] = 0
							self:SetText("")
							self:SetCursorPosition(0)
							self:ClearFocus()
							GameTooltip:SetOwner(self, "ANCHOR_NONE")
							GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
							GameTooltip:SetText("Now blacklisting "..a.."\nEnter again to whitelist.")
							GameTooltip:Show()
						end
						local x
						for i in pairs(DRSa[517]) do
							if (DRSa[517][i] == 0) or (DRSa[517][i] == 1) then
								x = true
								break
							end
						end
						if not x then
							DRSa[517] = nil
						end
					else
						DRSa[517] = {}
						DRSa[517][a] = 0
						self:SetText(a)
						self:SetCursorPosition(0)
						self:ClearFocus()
						GameTooltip:SetOwner(self, "ANCHOR_NONE")
						GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
						GameTooltip:SetText("Now blacklisting "..a.."\nEnter again to whitelist.")
						GameTooltip:Show()
					end
				else
					self:SetText("")
					self:SetCursorPosition(0)
					GameTooltip:SetOwner(self, "ANCHOR_NONE")
					GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
					GameTooltip:SetText("Only numbers greater than 0 will be accepted.")
					GameTooltip:Show()
				end
			end)
			eb1:SetScript("OnLeave", function()
				GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
				GameTooltip:Hide()
			end)
			eb1:SetScript("OnEditFocusLost", function(self)
				self:SetText("")
			end)
			eb1:SetSize(80, 32)
			eb1:SetMaxLetters(6)
			if chkBtn11:GetChecked() then
				eb1:Show()
			end
			local sideFrameFontString5 = DRS.sideFrame.fontString5
			sideFrameFontString5:SetPoint("RIGHT", eb1, "LEFT", -10, 0)
			sideFrameFontString5:SetText("Toggle Quest ID:")
			sideFrameFontString5:Show()
			local sideFrameFontString6 = DRS.sideFrame.fontString6
			sideFrameFontString6:SetPoint("BOTTOM", DRS.sideFrame, "BOTTOM", 0, 50)
			sideFrameFontString6:SetText("World Quest Filtering")
			sideFrameFontString6:Show()
			chkBtn11:SetScript("OnClick",function(self)
				local t = {9, 10, 11, 12, 13, 14, 15, 19, 25, 31, 33, 34, 36, 41, 517} -- update menu system chkBtn11 OnShow, chkBtn11 OnClick, and  "PLAYER_ENTERING_WORLD" event x2
				for i=1,#t do
					DRSa[t[i] ] = nil
				end
				if self:GetChecked() then
					DRS.sideFrame:Show()
					eb1:Show()
					DRS.sideFrame:SetSize(460, 350)
				else
					DRS.sideFrame:Hide()
				end end)
	end
end

local function MenuSelected(tab)
	local playerFaction = UnitFactionGroup("player")
	local totalNumberOfTabs=4
	local bottomTabsShown = nil
	if tab=="Account" then
		menuSelection="Account"
		DRS.TabA.fontString:SetTextColor(1,0.82,0)
		local stringText="Character Specific\nSettings"
		if strlen(playerShortName)<=10 then
			stringText=playerShortName.."'s\nSettings"
		end
		DRS.TabC.fontString:SetText(stringText)
		DRS.TabC.fontString:SetTextColor(1,1,1)
		DRS.TabU.fontString:SetTextColor(1,1,1)
		DRS.Tab1.fontString:SetText("Settings")
		DRS.Tab2.fontString:SetText("Console\nVariables")
		DRS.Tab3.fontString:SetText("Frames")
		if retail then
			DRS.Tab4.fontString:SetText("Sounds")
			bottomTabsShown = 4
		else
			bottomTabsShown = 3
		end
		tab=1
	elseif tab=="Character" then
		menuSelection="Character"
		DRS.TabC.fontString:SetTextColor(1,0.82,0)
		local stringText="Character Specific\nSettings"
		if strlen(playerShortName)<=10 then
			local 	_,class=UnitClass("player")
			local _,_,_,argbHex=GetClassColor(class)
			stringText="|c"..argbHex..playerShortName.."'s|r\nSettings"
		end
		DRS.TabC.fontString:SetText(stringText)
		DRS.TabA.fontString:SetTextColor(1,1,1)
		DRS.TabU.fontString:SetTextColor(1,1,1)
		DRS.Tab1.fontString:SetText("Merchant")
		DRS.Tab2.fontString:SetText("Refill")
		DRS.Tab3.fontString:SetText("Settings")
		DRS.Tab4.fontString:SetText("Addon\nControl")
		bottomTabsShown=4
		tab=1
	elseif tab=="Utility" then
		menuSelection="Utility"
		DRS.TabU.fontString:SetTextColor(1,0.82,0)
		DRS.TabA.fontString:SetTextColor(1,1,1)
		local stringText="Character Specific\nSettings"
		if strlen(playerShortName)<=10 then
			stringText=playerShortName.."'s\nSettings"
		end
		DRS.TabC.fontString:SetText(stringText)
		DRS.TabC.fontString:SetTextColor(1,1,1)
		DRS.Tab1.fontString:SetText("Mail")
		DRS.Tab2.fontString:SetText("Action Bars")
		DRS.Tab3.fontString:SetText("Reset Settings")
		bottomTabsShown=3
		tab=1
	end
	for i=1,totalNumberOfTabs do
		if tab==i then
			DRS["Tab"..i].fontString:SetTextColor(1,0.82,0)
		else
			DRS["Tab"..i].fontString:SetTextColor(1,1,1)
		end
	end
	if bottomTabsShown then 
		if bottomTabsShown==3 then
			for i=1,totalNumberOfTabs do
				if i<=bottomTabsShown then 
					DRS["Tab"..i]:SetSize(166,40)
					DRS["Tab"..i]:Show()
				else
					DRS["Tab"..i]:Hide()
				end
			end
			for i=2,3 do
				DRS["Tab"..i]:ClearAllPoints()
			end
			DRS.Tab2:SetPoint("TOP",DRS,"BOTTOM")
			DRS.Tab3:SetPoint("TOPRIGHT",DRS,"BOTTOMRIGHT")
		elseif bottomTabsShown==4 then
			for i=1,totalNumberOfTabs do
				if i<=bottomTabsShown then 
					DRS["Tab"..i]:SetSize(125,40)
					DRS["Tab"..i]:Show()
				else
					DRS["Tab"..i]:Hide()
				end
			end
			for i=2,4 do
				DRS["Tab"..i]:ClearAllPoints()
			end
			DRS.Tab2:SetPoint("LEFT",DRS.Tab1,"RIGHT")
			DRS.Tab3:SetPoint("LEFT",DRS.Tab2,"RIGHT")
			DRS.Tab4:SetPoint("LEFT",DRS.Tab3,"RIGHT")
		end
	end
	if menuSelection=="Utility" and playerFaction and (playerFaction=="Neutral" or playerFaction==nil) then
		DRS.Tab1:Hide()
		MenuSelected(2)
		MenuSetup(2)
	end
end

local function DefsRSMenuSystem(gotoTab)
	if DRS:IsShown() then
		CloseMenuSystem()
	else
		if not DRS.closeButton then
			DRS:SetSize(500, 350)
			DRS:SetPoint("CENTER", -115, 100)
			DRS:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", insets = {left = 3, right = 3, top = 3, bottom = 3}, tileSize = 16, tile = true, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16})
			DRS:SetBackdropBorderColor(0.5,0.5,0.5)
			DRS:SetScript("OnHide", function()
				EventRegistration()
			end)
			DRS:EnableMouse(true)
			DRS:SetMovable(true)
			DRS:SetClampedToScreen(true)
			DRS:RegisterForDrag("LeftButton")
			DRS:SetScript("OnDragStart", function()
				if not DRS.isLocked then
					DRS:StartMoving()
				end
			end)
			DRS:SetScript("OnDragStop", function()
				DRS:StopMovingOrSizing()
			end)
			tinsert(UISpecialFrames, "DRSMainMenuFrame")
			if retail then
				DRS.myPools = CreateFramePoolCollection()
			else
				DRS.myPools = CreatePoolCollection()
			end
			--DRS.myPools:CreatePool("Button",DRS,"UIExpandingButtonTemplate")--"UIExpandingButtonTemplate"
			DRS.myPools:CreatePool("Button", DRS, "OptionsButtonTemplate")
			DRS.myPools:CreatePool("CheckButton", DRS, "UICheckButtonTemplate")
			DRS.myPools:CreatePool("EditBox", DRS, "InputBoxTemplate")
			if retail then
				DRS.myPools:CreatePool("ItemButton", DRS, "ContainerFrameItemButtonTemplate")
			else
				DRS.myPools:CreatePool("Button", DRS, "ItemButtonTemplate")
			end
			DRS.myPools:CreatePool("Button", DRS, "UIPanelCloseButton")
			--DRS.myPools:CreatePool("EditBox",DRS,"AutoCompleteEditBoxTemplate")
			DRS.closeButton=CreateFrame("Button", nil, DRS, "UIPanelCloseButton")
			DRS.closeButton:SetPoint("TOPRIGHT", DRS, "TOPRIGHT")
			DRS.closeButton:SetShown(true)
			DRS.closeButton:SetScript("OnClick", function()
				CloseMenuSystem()
			end)
			DRS.sideFrame=CreateFrame("Frame", nil, DRS)
			DRS.sideFrame:SetShown(false)
			DRS.sideFrame:SetSize(230, 350)
			DRS.sideFrame:EnableMouse(true)
			DRS.sideFrame:SetPoint("TOPLEFT", DRS, "TOPRIGHT")
			DRS.sideFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", insets = {left = 3, right = 3, top = 3, bottom = 3}, tileSize = 16, tile = true, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16})
			DRS.sideFrame:SetBackdropBorderColor(0.5, 0.5, 0.5)
			if retail then
				DRS.sideFrame.myPools = CreateFramePoolCollection()
			else
				DRS.sideFrame.myPools = CreatePoolCollection()
			end
			DRS.sideFrame.myPools:CreatePool("EditBox", DRS.sideFrame, "InputBoxTemplate")
			DRS.sideFrame.myPools:CreatePool("CheckButton", DRS.sideFrame, "UICheckButtonTemplate")
			if retail then
				DRS.sideFrame.myPools:CreatePool("ItemButton", DRS.sideFrame, "ContainerFrameItemButtonTemplate")
			else
				DRS.sideFrame.myPools:CreatePool("Button", DRS.sideFrame, "ItemButtonTemplate")
			end
			local function BuildTab(width,heighth,point,relativeTo,relativePoint,offsetX,offsetY,tab,text)
				local f = CreateFrame("Button", nil, DRS)
				f:SetSize(width, heighth)
				f:SetPoint(point or "TOPLEFT", relativeTo or DRS, relativePoint or "BOTTOMLEFT", offsetX, offsetY)
				f:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", insets = {left=3, right=3, top=3, bottom=3}, tileSize = 16, tile = true, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16})
				f:SetBackdropBorderColor(0.5, 0.5, 0.5)
				f:SetShown(true)
				f:SetScript("OnClick", function()
					MenuSelected(tab)
					MenuSetup(tab)
				end)
				f.fontString=f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				f.fontString:SetPoint("CENTER", 0, 2)
				f.fontString:SetText(text)
				if (tab == "Character") then
					f.fontString:SetTextColor(1, .82, 0)
				else
					f.fontString:SetTextColor(1, 1, 1)
				end
				return f
			end
			DRS.Tab1 = BuildTab(125, 40, nil, nil, nil, 0, 0, 1, "Merchant")
			DRS.Tab2 = BuildTab(125, 40, "LEFT", DRS.Tab1, "RIGHT", 0, 0, 2, "Refill")
			DRS.Tab3 = BuildTab(125, 40, "LEFT", DRS.Tab2, "RIGHT", 0, 0, 3, "Settings")
			DRS.Tab4 = BuildTab(125, 40, "LEFT", DRS.Tab3, "RIGHT", 0, 0, 4, "Addon\nControl")
			DRS.TabA = BuildTab(166, 40, "BOTTOMLEFT", nil, "TOPLEFT", 0, 0, "Account", "Account-Wide\nSettings")
			local stringText = "Character Specific\nSettings"
			if (strlen(playerShortName) <= 10) then
				local _, class = UnitClass("player")
				local _, _, _, argbHex = GetClassColor(class)
				stringText = "|c"..argbHex..playerShortName.."'s|r\nSettings"
			end
			DRS.TabC = BuildTab(166, 40, "BOTTOM", nil, "TOP", 0, 0, "Character", stringText)
			DRS.TabU = BuildTab(166, 40, "BOTTOMRIGHT", nil, "TOPRIGHT", 0, 0, "Utility", "Utility")
		else
			local stringText = "Character Specific\nSettings"
			if playerShortName and (strlen(playerShortName) <= 10) then
				local _, class = UnitClass("player")
				local _, _, _, argbHex = GetClassColor(class)
				stringText = "|c"..argbHex..playerShortName.."'s|r\nSettings"
			end
			DRS.TabC.fontString:SetText(stringText)
		end
		MenuSelected(gotoTab or "Character")
		MenuSetup(gotoTab or "Character")
		DRS:Show()
		if DRSc[7] then
			AddOnControl()
		end
	end
end
]]
--[[SLASH_DEFRS1="/DRS"
SlashCmdList["DEFRS"] = function() DefsRSMenuSystem() end]]

--To do list for addon:
--[[
Refill from gbank if possible.
bank sort, reagent bank sort, and deposit soulbound reagents if space
Force looting quicker from the table rather than the loot box.
]]