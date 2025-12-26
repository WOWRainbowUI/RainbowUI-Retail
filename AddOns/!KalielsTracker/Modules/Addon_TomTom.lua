--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class AddonTomTom
local M = KT:NewModule("AddonTomTom")
KT.AddonTomTom = M

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local ipairs = ipairs
local strsplit = string.split

-- WoW API
local HaveQuestData = HaveQuestData

local db, dbChar
local tomtomArrow
local questWaypoint
local userWaypointID = 999999
local superTrackedQuestID = 0
local stopUpdate = false
local autoQuestWatch = GetCVarBool("autoQuestWatch")

local OTF = KT_ObjectiveTrackerFrame

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetupOptions()
	if KT.optionsFrame then
        local cTitle = "|cffffd200"
        local cBold = "|cff00ffe3"

		KT.options.args.tomtom = {
			name = "TomTom　導航箭頭",
			type = "group",
			args = {
				tomtomDesc1 = {
					name = "TomTom 的支援性整合了暴雪的 POI 和 TomTom 的導航箭頭。\n\n"..
							"|cffff7f00注意:|r 原本的 \"TomTom > 任務目標\" 選項會被忽略!\n\n\n"..
							"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:10:256:256:128:160:96:128|t+"..
							"|T"..KT.MEDIA_PATH.."KT-TomTomTag:32:32:-8:10:32:16:0:16:0:16|t...   當前 POI 按鈕包含 TomTom 導航。\n"..
							"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:10:256:256:128:160:96:128|t+"..
							"|T"..KT.MEDIA_PATH.."KT-TomTomTag:32:32:-8:10:32:16:16:32:0:16|t...   當前 POI 按鈕不包含 TomTom 導航 (沒有資料)。",
					type = "description",
					order = 1,
				},
                tomtomArrow = {
                    name = cTitle.."TomTom arrow",
                    type = "description",
                    fontSize = "medium",
                    order = 2,
                },
                tomtomArrowDesc = {
                    name = "- "..cBold.."左鍵|r - 打開世界地圖。\n"..
                            "- "..cBold.."右鍵|r - 移除導航並取消選取 POI。\n"..
                            "- "..cBold.."Shift + 右鍵|r - 顯示右鍵選單。\n\n",
                    type = "description",
                    order = 3,
                },
				tomtomArrival = {
					name = "抵達距離",
					type = "range",
					min = 0,
					max = 150,
					step = 5,
					set = function(_, value)
						db.tomtomArrival = value
					end,
					order = 4,
				},
			},
		}

		KT.optionsFrame.tomtom = ACD:AddToBlizOptions(addonName, "插件 - "..KT.options.args.tomtom.name, "任務-清單", "tomtom")
	end

	-- Reverts the option to display Quest Objectives
	if not GetCVarBool("questPOI") then
		SetCVar("questPOI", 1)
	end
end

local function GetCurrentMapAreaID()
	local mapID = KT.GetCurrentMapAreaID()
	local mapInfo = C_Map.GetMapInfo(mapID)
	if mapInfo and (mapInfo.mapType == Enum.UIMapType.Micro or mapInfo.mapType == Enum.UIMapType.Orphan) then
		mapID = mapInfo.parentMapID
	end
	return mapID
end

local function GetMapIDByCursor(mapID)
	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local normalizedCursorX, normalizedCursorY = WorldMapFrame:GetNormalizedCursorPosition()
		local positionMapInfo = C_Map.GetMapInfoAtPosition(mapID, normalizedCursorX, normalizedCursorY)
		if positionMapInfo and positionMapInfo.mapID ~= mapID then
			mapID = positionMapInfo.mapID
		end
	end
	return mapID
end

local function NormalizePOIData(mapID, x, y, questID)
	mapID = mapID or 0
	local currentMapID = GetCurrentMapAreaID()
	local sameZone, sameContinent = KT.CompareZones(mapID, currentMapID)
	local waypointMapID, waypointText
	local fakeData = false
	if not sameZone then
		if mapID > 0 then
			waypointText = "Travel to "..KT.GetMapNameByID(mapID)
		end
		if x and y and (not sameContinent or (questID and KT.IsInstanceQuest(questID))) then
			waypointMapID, x, y = currentMapID, 0, 0
			fakeData = true
		end
	end
	return mapID, x, y, waypointMapID, waypointText, fakeData
end

-- Super turbo function :)
local function QuestPOIGetIconInfo(questID)
	local fakeData = false
	local waypointMapID
	local waypointText = C_QuestLog.GetNextWaypointText(questID)
	local mapID, x, y = C_QuestLog.GetNextWaypoint(questID)
	if not x or not y then
		mapID = GetQuestUiMapID(questID)
		if mapID and mapID > 0 then
			local quests = C_QuestLog.GetQuestsOnMap(mapID)
			if quests then
				for _, info in ipairs(quests) do
					if info.questID == questID then
						x = info.x
						y = info.y
						break
					end
				end
			end

			if not waypointText then
				mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y, questID)
			end
		end
	end
	return mapID, x, y, waypointMapID, waypointText, fakeData
end

local function TaskQuestPOIGetIconInfo(questID)
	local fakeData = false
	local x, y, waypointMapID, waypointText
	local mapID = C_TaskQuest.GetQuestZoneID(questID)
	if mapID then
		local tasks = GetTasksOnMapCached(mapID)
		if tasks then
			for _, info  in ipairs(tasks) do
				if HaveQuestData(info.questID) then
					if info.questID == questID then
						x = info.x
						y = info.y
						break
					end
				end
			end
		end

		mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
	end
	return mapID, x, y, waypointMapID, waypointText, fakeData
end

local function UserWaypointGetIconInfo()
	local x, y, waypointMapID, waypointText, fakeData
	local mapID = dbChar.waypoint.mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
		mapID = GetMapIDByCursor(mapID)
	end

	local posVector = C_Map.GetUserWaypointPositionForMap(mapID)
	if posVector then
		x, y = posVector:GetXY()
	end

	mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
	return mapID, x, y, waypointMapID, waypointText, fakeData
end

local function AreaPOIGetIconInfo(id)
	local title, x, y, waypointMapID, waypointText, fakeData
	local mapID = dbChar.waypoint.mapID > 0 and dbChar.waypoint.mapID or C_EventScheduler.GetEventUiMapID(id)
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
		mapID = GetMapIDByCursor(mapID)
	end

	local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, id)
	if info then
		if info.atlasName then
			local width, height, offsetX, offsetY = 18, 18, -3, 0
			local atlas = KT.GetPoiIcon(info.atlasName, "atlas") or info.atlasName
			title = CreateAtlasMarkup(atlas, width, height, offsetX, offsetY)..info.name
		else
			title = info.name
		end
		x, y = info.position:GetXY()
	end

	mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
	return title, mapID, x, y, waypointMapID, waypointText, fakeData
end

local function QuestOfferGetIconInfo(id)
	local title, x, y, waypointMapID, waypointText, fakeData
	local mapID = dbChar.waypoint.mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
		mapID = GetMapIDByCursor(mapID)
	end

	local info = KT.GetQuestOfferInfo(mapID, id)
	if info then
		local iconMarkup = KT.GetPoiIcon("Quest"..info.questClassification, "markup")
		if iconMarkup then
			title = iconMarkup..info.questName
		else
			title = info.questName
		end
		x, y = info.x, info.y
	end

	mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
	return title, mapID, x, y, waypointMapID, waypointText, fakeData
end

local function TaxiNodeGetIconInfo(id)
	local title, x, y, waypointMapID, waypointText, fakeData
	local mapID = dbChar.waypoint.mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
		mapID = GetMapIDByCursor(mapID)
	end

	local info = KT.GetTaxiNodeInfo(mapID, id)
	if info then
		title = KT.GetPoiIcon("TaxiNode", "markup")..strsplit(",", info.name)
		x, y = info.position:GetXY()
	end

	mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
	return title, mapID, x, y, waypointMapID, waypointText, fakeData
end

local function DigSiteGetIconInfo(id)
	local title, x, y, waypointMapID, waypointText, fakeData
	local mapID = dbChar.waypoint.mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
		mapID = GetMapIDByCursor(mapID)
	end

	local info = KT.GetDigSiteInfo(mapID, id)
	if info then
		title = KT.GetPoiIcon("DigSite", "markup")..info.name
		x, y = info.position:GetXY()
	end

	mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
	return title, mapID, x, y, waypointMapID, waypointText, fakeData
end

local function HousingPlotGetIconInfo(id)
    local title, x, y, waypointMapID, waypointText, fakeData
    local mapID = dbChar.waypoint.mapID
    if WorldMapFrame:IsShown() then
        mapID = WorldMapFrame:GetMapID()
        mapID = GetMapIDByCursor(mapID)
    end

    local info = KT.GetHousingPlotInfo(id)
    if info then
        title = format(HOUSING_PLOT_NUMBER.." (%s)", info.plotID, info.ownerName or HOUSING_CORNERSTONE_FORSALE)
        local iconMarkup = KT.GetPoiIcon("Housing"..info.ownerType, "markup")
        if iconMarkup then
            title = iconMarkup..title
        end
        x, y = info.mapPosition:GetXY()
    end

    mapID, x, y, waypointMapID, waypointText, fakeData = NormalizePOIData(mapID, x, y)
    return title, mapID, x, y, waypointMapID, waypointText, fakeData
end

local function SetWaypointTag(button, show)
	local tag = button.Display.KTtomtom
	if show then
		if tag then
			tag:Show()
		else
			-- Only for new POI button tags on World Map!
			-- The tracker has tag inside KT2_ObjectiveTrackerPOIButtonTemplate (animation bug prevention)
			tag = button.Display:CreateTexture(nil, "OVERLAY")
			tag:SetTexture(KT.MEDIA_PATH.."KT-TomTomTag")
			tag:SetSize(32, 32)
			tag:SetPoint("CENTER")
			button.Display.KTtomtom = tag
		end

		if questWaypoint then
			tag:SetTexCoord(0, 0.5, 0, 1)
		else
			tag:SetTexCoord(0.5, 1, 0, 1)
		end
	else
		if tag then
			tag:Hide()
		end
	end
end

local function TomTomArrow_Init()
	local theme = TomTom.CrazyArrowThemeHandler.active
	tomtomArrow = TomTomCrazyArrow
	tomtomArrow.KTarrow = theme.tbl.arrowTexture
	tomtomArrow.KTshown = true

    local travel = tomtomArrow:CreateTexture(nil, "OVERLAY")
    travel:SetAtlas("poi-traveldirections-arrow2", true)
    travel:SetScale(0.9)
    travel:SetPoint("BOTTOM")
    travel:Hide()
    tomtomArrow.KTtravel = travel
end

local function TomTomArrow_SetShown(show)
	if tomtomArrow then
		tomtomArrow.KTarrow:SetShown(show)
		tomtomArrow.KTtravel:SetShown(not show)
		tomtomArrow.status:SetShown(show and TomTom.profile.arrow.showdistance)
		C_Timer.After(0, function()
			tomtomArrow.tta:SetShown(show and TomTom.profile.arrow.showtta)
		end)
		tomtomArrow.KTshown = show
	end
end

local function SetCharWaypointData(id, type, mapID)
	dbChar.waypoint.id = id or 0
	dbChar.waypoint.type = type
	dbChar.waypoint.mapID = mapID or 0
end

local function AddWaypoint(id, type)
	if C_QuestLog.IsQuestCalling(id) then
		return false
	end

	local title, mapID, x, y, waypointMapID, waypointText, fakeData
	if type then
		if type == Enum.SuperTrackingMapPinType.AreaPOI then
			title, mapID, x, y, waypointMapID, waypointText, fakeData = AreaPOIGetIconInfo(id)
		elseif type == Enum.SuperTrackingMapPinType.QuestOffer then
			title, mapID, x, y, waypointMapID, waypointText, fakeData = QuestOfferGetIconInfo(id)
		elseif type == Enum.SuperTrackingMapPinType.TaxiNode then
			title, mapID, x, y, waypointMapID, waypointText, fakeData = TaxiNodeGetIconInfo(id)
		elseif type == Enum.SuperTrackingMapPinType.DigSite then
			title, mapID, x, y, waypointMapID, waypointText, fakeData = DigSiteGetIconInfo(id)
        elseif type == Enum.SuperTrackingMapPinType.HousingPlot then
            title, mapID, x, y, waypointMapID, waypointText, fakeData = HousingPlotGetIconInfo(id)
		end
	elseif id == userWaypointID then
		title = KT.GetPoiIcon("MapPin", "markup").."My waypoint"
		mapID, x, y, waypointMapID, waypointText, fakeData = UserWaypointGetIconInfo()
	elseif C_QuestLog.IsQuestTask(id) then
		local iconName = QuestUtils_IsQuestWorldQuest(id) and "WorldQuest" or "BonusObjective"
		title = KT.GetPoiIcon(iconName, "markup")..C_TaskQuest.GetQuestInfoByQuestID(id)
		mapID, x, y, waypointMapID, waypointText, fakeData = TaskQuestPOIGetIconInfo(id)
	else
		local iconName = C_QuestLog.IsComplete(id) and "QuestTurnin" or "Quest"
		title = KT.GetPoiIcon(iconName, "markup")..C_QuestLog.GetTitleForQuestID(id)
		mapID, x, y, waypointMapID, waypointText, fakeData = QuestPOIGetIconInfo(id)
	end

	if not mapID or not x or not y or not title then
		return false
	end

	if waypointText then
		title = title.."\n|cff00ff00("..waypointText..")"
	end

	local uid = TomTom:AddWaypoint(waypointMapID or mapID, x, y, {
		title = title,
		silent = true,
		world = false,
		minimap = false,
		crazy = true,
		persistent = false,
		arrivaldistance = db.tomtomArrival,
        from = KT.TITLE,
        KTfakeData = fakeData,
	})
	uid.KTid = id
	questWaypoint = uid
    SetCharWaypointData(id, type, mapID)

	return true
end

local function RemoveWaypoint(questID)
	if questID == superTrackedQuestID then
		TomTom:RemoveWaypoint(questWaypoint)
		questWaypoint = nil
		superTrackedQuestID = 0
		SetCharWaypointData()
	end
end

local function SetSuperTrackedQuestWaypoint(questID, force)
	if questID ~= superTrackedQuestID or force then
		if not force and superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
		if questID > 0 then
			AddWaypoint(questID)
			superTrackedQuestID = questID
		end
	end
end

local function SetSuperTrackedMapPinWaypoint(type, poiID, force)
	if poiID ~= superTrackedQuestID or force then
		if not force and superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
		if poiID > 0 then
			AddWaypoint(poiID, type)
			superTrackedQuestID = poiID
		end
	end
end

local function SetSuperTrackedUserWaypoint(superTracked, force)
	if not force and superTrackedQuestID > 0 then
		RemoveWaypoint(superTrackedQuestID)
	end
	if superTracked then
		AddWaypoint(userWaypointID)
		superTrackedQuestID = userWaypointID
	end
end

local function SetHooks()
	-- TomTom
	if TomTom.EnableDisablePOIIntegration then
		local bck_TomTom_EnableDisablePOIIntegration = TomTom.EnableDisablePOIIntegration
		function TomTom:EnableDisablePOIIntegration()
			self.profile.poi.enable = false
			self.profile.poi.modifier = "A"
			self.profile.poi.setClosest = false
			self.profile.poi.arrival = 0
			bck_TomTom_EnableDisablePOIIntegration(self)
		end
		TomTom:EnableDisablePOIIntegration()
	end

    if TomTom.ShowHideCrazyArrow then
        local bck_TomTom_ShowHideCrazyArrow = TomTom.ShowHideCrazyArrow
        function TomTom:ShowHideCrazyArrow()
            self.profile.arrow.setclosest = false
            bck_TomTom_ShowHideCrazyArrow(self)
        end
        TomTom:ShowHideCrazyArrow()
    end

	hooksecurefunc(TomTom.CrazyArrowThemeHandler, "SetActiveTheme", function(self, button, key, arrival)
		tomtomArrow.KTarrow = self.active.tbl.arrowTexture
		if questWaypoint then
			TomTomArrow_SetShown(tomtomArrow.KTshown)
		end
	end)

	hooksecurefunc(TomTom, "ClearWaypoint", function(self, uid)
		if uid.KTid == superTrackedQuestID then
			questWaypoint = nil
			superTrackedQuestID = 0
			OTF:Update()
			if WorldMapFrame:IsShown() then
				WorldMapFrame:RefreshQuestLog()
				WorldMapFrame:RefreshOverlayFrames()  -- fix Blizz bug (Area POI)
			end
		end
	end)

	hooksecurefunc(TomTom, "SetCrazyArrow", function(self, uid, dist, title)
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end

        local fakeData = uid.KTfakeData ~= nil and uid.KTfakeData or false
        TomTomArrow_SetShown(not fakeData)
	end)

	TomTomCrazyArrow:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local bck_TomTomCrazyArrow_OnClick = TomTomCrazyArrow:GetScript("OnClick")
	TomTomCrazyArrow:SetScript("OnClick", function(self, btn, down)
		if btn == "LeftButton" then
            if dbChar.waypoint.id > 0 then
                OpenQuestLog(dbChar.waypoint.mapID)
            end
		else
			if IsShiftKeyDown() then
				bck_TomTomCrazyArrow_OnClick(self, btn, down)
			else
				C_SuperTrack.ClearAllSuperTracked()
			end
		end
	end)

	-- Blizzard
	hooksecurefunc(C_SuperTrack, "SetSuperTrackedQuestID", function(questID)
		SetSuperTrackedQuestWaypoint(questID)
	end)

	hooksecurefunc(C_SuperTrack, "ClearAllSuperTracked", function()
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
	end)

	hooksecurefunc(C_SuperTrack, "SetSuperTrackedContent", function(trackableType, trackableID)
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
		superTrackedQuestID = trackableID
	end)

	hooksecurefunc(C_SuperTrack, "SetSuperTrackedMapPin", function(type, typeID)
		SetSuperTrackedMapPinWaypoint(type, typeID)
	end)

	hooksecurefunc(C_SuperTrack, "ClearSuperTrackedMapPin", function()
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
	end)

	hooksecurefunc(C_SuperTrack, "SetSuperTrackedVignette", function(vignetteGUID)
		-- Do not set superTrackedQuestID, because vignetteGUID is a string
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
	end)

	hooksecurefunc(C_SuperTrack, "SetSuperTrackedUserWaypoint", function(superTracked)
		SetSuperTrackedUserWaypoint(superTracked)
	end)

	hooksecurefunc(C_QuestLog, "AbandonQuest", function()
		local questID = QuestMapFrame.DetailsFrame.questID or QuestLogPopupDetailFrame.questID
		RemoveWaypoint(questID)
	end)

	hooksecurefunc("QuestMapQuestOptions_TrackQuest", function(questID)
		if questID == C_SuperTrack.GetSuperTrackedQuestID() then
			SetSuperTrackedQuestWaypoint(questID, true)
			QuestMapFrame:Refresh()
		end
	end)

	-- Only for Events
	hooksecurefunc(KT_BonusObjectiveTracker, "OnQuestRemoved", function(self, questID)
		if questID == superTrackedQuestID then
			C_SuperTrack.ClearSuperTrackedMapPin()
		end
	end)

	-- Only for World Quests
	hooksecurefunc(KT_WorldQuestObjectiveTracker, "OnQuestTurnedIn", function(self, questID)
		RemoveWaypoint(questID)
	end)
end

local function SetHooks_Init()
	-- Blizzard
	hooksecurefunc(POIButtonMixin, "UpdateButtonStyle", function(self)
		local show = (superTrackedQuestID == self.questID or superTrackedQuestID == self.areaPOIID)
		SetWaypointTag(self, show)
	end)

	hooksecurefunc(POIButtonMixin, "OnClick", function(self)
		-- Quest and World Quest modules are automatically marked as dirty
		if KT.POIButton_IsCampaign(self) then
			KT_CampaignQuestObjectiveTracker:MarkDirty()
		elseif KT.POIButton_IsEvent(self) then
			KT_EventObjectiveTracker:MarkDirty()
		end
	end)
end

local function SetEvents()
	KT:RegEvent("PLAYER_ENTERING_WORLD", function(eventID, isInitialLogin)
		if isInitialLogin then
            if dbChar.waypoint.id == userWaypointID then
                SetCharWaypointData()
            end
            if dbChar.waypoint.mapID > 0 and dbChar.waypoint.type == 1 then
                KT.SetMapID(dbChar.waypoint.mapID)
            end
		end
		KT:UnregEvent(eventID)
	end, M)

	-- Update waypoint after reload with supertracking
	KT:RegEvent("QUEST_LOG_UPDATE", function(eventID)
		local questID = C_SuperTrack.GetSuperTrackedQuestID() or dbChar.waypoint.id
		if questID == userWaypointID and C_SuperTrack.IsSuperTrackingUserWaypoint() then
			SetSuperTrackedUserWaypoint(true)
		elseif questID and (QuestUtils_IsQuestWatched(questID) or C_QuestLog.IsComplete(questID) or QuestUtil.IsQuestTrackableTask(questID)) then
			C_SuperTrack.SetSuperTrackedQuestID(questID)
		else
			local type, superTrackedPoiID = C_SuperTrack.GetSuperTrackedMapPin()
			if not type and not	superTrackedPoiID then
				type = dbChar.waypoint.type
				superTrackedPoiID = dbChar.waypoint.id
				GetAreaPOIsForPlayerByMapIDCached(dbChar.waypoint.mapID)
			end
			if type and superTrackedPoiID then
				C_SuperTrack.SetSuperTrackedMapPin(type, superTrackedPoiID)
			end
		end
		KT:UnregEvent(eventID)
	end, M)

	-- Disable stop update after quest is accepted
	KT:RegEvent("QUEST_ACCEPTED", function()
		stopUpdate = not autoQuestWatch
	end, M)

	-- Enable stop update after quest is removed
	KT:RegEvent("QUEST_REMOVED", function()
		stopUpdate = true

		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID and QuestUtils_IsQuestWatched(questID) then
			C_Timer.After(0, function()
				SetSuperTrackedQuestWaypoint(questID)
				OTF:Update()
			end)
		end
	end, M)

	-- Enable stop update after quest is turned in
	KT:RegEvent("QUEST_TURNED_IN", function()
		stopUpdate = true
	end, M)

	-- Update waypoint after quest objectives changed
	KT:RegEvent("QUEST_WATCH_UPDATE", function(_, questID)
		if questID == C_SuperTrack.GetSuperTrackedQuestID() then
			C_Timer.After(0.5, function()
				if not stopUpdate then
					SetSuperTrackedQuestWaypoint(questID, true)
				end
			end)
		end
	end, M)

	-- Updates waypoint while moving
	KT:RegEvent("WAYPOINT_UPDATE", function()
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID then
			SetSuperTrackedQuestWaypoint(questID, true)
			OTF:Update()
		end
	end, M)

	-- Updates waypoint while change zone
	KT:RegEvent("ZONE_CHANGED_NEW_AREA", function()
		C_Timer.After(0, function()
			local questID = C_SuperTrack.GetSuperTrackedQuestID() or dbChar.waypoint.id
			if questID == userWaypointID and C_SuperTrack.IsSuperTrackingUserWaypoint() then
				SetSuperTrackedUserWaypoint(true, true)
			elseif questID and (QuestUtils_IsQuestWatched(questID) or C_QuestLog.IsComplete(questID) or QuestUtil.IsQuestTrackableTask(questID)) then
				SetSuperTrackedQuestWaypoint(questID, true)
			else
				local type, superTrackedPoiID = C_SuperTrack.GetSuperTrackedMapPin()
				if superTrackedPoiID then
					SetSuperTrackedMapPinWaypoint(type, superTrackedPoiID, true)
					OTF:Update()
				end
			end
		end)
	end, M)

	-- Update waypoint after accept quest
	KT:RegEvent("QUEST_POI_UPDATE", function()
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID and QuestUtils_IsQuestWatched(questID) then
			C_Timer.After(0, function()
				SetSuperTrackedQuestWaypoint(questID)
				OTF:Update()
			end)
		end
		if WorldMapFrame:IsShown() then
			WorldMapFrame:RefreshOverlayFrames()  -- fix Blizz bug (Area POI)
		end
	end, M)
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = (KT:CheckAddOn("TomTom", "v4.2.8-release") and db.addonTomTom)

	if self.isAvailable then
		KT:Alert_IncompatibleAddon("TomTom", "v4.1.2-release")

		local defaults = KT:MergeTables({
			profile = {
				tomtomArrival = 20,
			}
		}, KT.db.defaults)
		KT.db:RegisterDefaults(defaults)

		SetHooks_Init()
	end
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	SetupOptions()
	SetEvents()
	SetHooks()

	TomTomArrow_Init()
end