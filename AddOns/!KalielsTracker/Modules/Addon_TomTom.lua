--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local M = KT:NewModule("AddonTomTom")
KT.AddonTomTom = M

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local ipairs = ipairs

-- WoW API
local HaveQuestData = HaveQuestData

local db
local tomtomArrow
local questWaypoint
local superTrackedQuestID = 0
local stopUpdate = false
local autoQuestWatch = GetCVarBool("autoQuestWatch")

local OTF = KT_ObjectiveTrackerFrame

--------------
-- Internal --
--------------

local function SetupOptions()
	KT.options.args.tomtom = {
		name = "TomTom 導航箭頭",
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
			tomtomArrival = {
				name = "抵達距離",
				type = "range",
				min = 0,
				max = 150,
				step = 5,
				set = function(_, value)
					db.tomtomArrival = value
				end,
				order = 2,
			},
		},
	}

	KT.optionsFrame.tomtom = ACD:AddToBlizOptions(addonName, "插件 - "..KT.options.args.tomtom.name, "任務-追蹤清單", "tomtom")

	-- Reverts the option to display Quest Objectives
	if not GetCVarBool("questPOI") then
		SetCVar("questPOI", 1)
	end
end

-- Super turbo function :)
local function QuestPOIGetIconInfo(questID)
	local completed = C_QuestLog.IsComplete(questID)
	local waypointText = C_QuestLog.GetNextWaypointText(questID)
	local mapID, x, y = C_QuestLog.GetNextWaypoint(questID)
	if not x or not y then
		mapID = KT.GetCurrentMapAreaID()
		if mapID then
			x, y = C_QuestLog.GetNextWaypointForMap(questID, mapID)
			if not x or not y then
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
			end
		end
	end
	return mapID, x, y, completed, waypointText
end

local function WorldQuestPOIGetIconInfo(questID)
	local x, y, waypointText
	local mapID = C_TaskQuest.GetQuestZoneID(questID)
	if mapID then
		local currentMapID = KT.GetCurrentMapAreaID()
		if mapID == currentMapID then
			local taskInfo = GetTasksOnMapCached(mapID)
			if taskInfo then
				for _, info  in ipairs(taskInfo) do
					if HaveQuestData(info.questID) then
						if info.questID == questID then
							x = info.x
							y = info.y
							break
						end
					end
				end
			end
		else
			waypointText = "Travel to "..KT.GetMapNameByID(mapID)
			mapID, x, y = currentMapID, 0, 0
		end
	end
	return mapID, x, y, waypointText
end

local function AreaPOIGetIconInfo(poiID)
	local x, y, title
	local mapID = KT.GetCurrentMapAreaID()
	local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID)
	if info then
		title = info.name
		x, y = info.position:GetXY()
	end
	return mapID, x, y, title
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

local function TomTomArrowSetShown(show)
	if tomtomArrow then
		tomtomArrow.arrow:SetShown(show)
		tomtomArrow.status:SetShown(show)
		tomtomArrow.tta:SetShown(show)
	else
		C_Timer.After(0, function()
			TomTomArrowSetShown(show)
		end)
	end
end

local function AddWaypoint(questID, isPin)
	if C_QuestLog.IsQuestCalling(questID) then
		return false
	end

	local title, mapID, x, y, completed, waypointText
	local isWorldQuest = false
	if isPin then
		mapID, x, y, title = AreaPOIGetIconInfo(questID)
	elseif QuestUtil.IsQuestTrackableTask(questID) then
		title = C_TaskQuest.GetQuestInfoByQuestID(questID)
		mapID, x, y, waypointText = WorldQuestPOIGetIconInfo(questID)
		isWorldQuest = true
	else
		title = C_QuestLog.GetTitleForQuestID(questID)
		mapID, x, y, completed, waypointText = QuestPOIGetIconInfo(questID)
	end

	if not mapID or not x or not y or not title then
		return false
	end

	if waypointText then
		title = title.."\n|cff00ff00("..waypointText..")"
	end

	if isWorldQuest and waypointText then
		TomTomArrowSetShown(false)
	else
		TomTomArrowSetShown(true)
	end

	if completed then
		title = "|TInterface\\GossipFrame\\ActiveQuestIcon:0:0:0:0|t "..title
	else
		title = "|TInterface\\GossipFrame\\AvailableQuestIcon:0:0:0:0|t "..title
	end

	local uid = TomTom:AddWaypoint(mapID, x, y, {
		title = title,
		silent = true,
		world = false,
		minimap = false,
		crazy = true,
		persistent = false,
		arrivaldistance = db.tomtomArrival,
	})
	uid.questID = questID
	questWaypoint = uid

	return true
end

local function RemoveWaypoint(questID)
	if questID == superTrackedQuestID then
		TomTom:RemoveWaypoint(questWaypoint)
		questWaypoint = nil
		superTrackedQuestID = 0
	end
end

local function SetSuperTrackedQuestWaypoint(questID, force)
	if questID ~= superTrackedQuestID or force then
		RemoveWaypoint(superTrackedQuestID)
		if questID > 0 then
			AddWaypoint(questID)
			superTrackedQuestID = questID
		end
	end
end

local function SetSuperTrackedMapPinWaypoint(poiID, force)
	if poiID ~= superTrackedQuestID or force then
		RemoveWaypoint(superTrackedQuestID)
		if poiID > 0 then
			AddWaypoint(poiID, true)
			superTrackedQuestID = poiID
		end
	end
end

local function SetHooks()
	-- TomTom
	if TomTom.EnableDisablePOIIntegration then
		local bck_TomTom_EnableDisablePOIIntegration = TomTom.EnableDisablePOIIntegration
		function TomTom:EnableDisablePOIIntegration()
			TomTom.profile.poi.enable = false
			TomTom.profile.poi.modifier = "A"
			TomTom.profile.poi.setClosest = false
			TomTom.profile.poi.arrival = 0
			bck_TomTom_EnableDisablePOIIntegration(self)
		end
		TomTom:EnableDisablePOIIntegration()
	end

	hooksecurefunc(TomTom, "ClearWaypoint", function(self, uid)
		if uid.questID == superTrackedQuestID then
			questWaypoint = nil
			superTrackedQuestID = 0
			OTF:Update()
			if QuestMapFrame:IsShown() then
				QuestMapFrame:Refresh()
			end
		end
	end)

	hooksecurefunc(TomTom, "SetCrazyArrow", function(self, uid, dist, title)
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
	end)

	TomTom:HijackCrazyArrow(function(self)
		tomtomArrow = self
		TomTom:ReleaseCrazyArrow()
	end)

	-- Blizzard
	hooksecurefunc(C_SuperTrack, "SetSuperTrackedQuestID", function(questID)
		stopUpdate = questID > 0 and not QuestUtils_IsQuestWatched(questID) and not QuestUtil.IsQuestTrackableTask(questID)
		if stopUpdate then
			-- after focus on Unwatched Quests or Bonus Objectives
			RemoveWaypoint(superTrackedQuestID)
		else
			SetSuperTrackedQuestWaypoint(questID)
		end
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
		SetSuperTrackedMapPinWaypoint(typeID)
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
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
		if superTracked then
			superTrackedQuestID = 100000  -- fake ID
		end
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
		C_SuperTrack.ClearSuperTrackedMapPin()
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
		KT_CampaignQuestObjectiveTracker:MarkDirty()
		-- Quest and World Quest modules are automatically marked as dirty
	end)
end

local function SetEvents()
	-- Update waypoint after reload with supertracking
	KT:RegEvent("QUEST_LOG_UPDATE", function(eventID)
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID and (QuestUtils_IsQuestWatched(questID) or QuestUtil.IsQuestTrackableTask(questID)) then
			SetSuperTrackedQuestWaypoint(questID)
		else
			local _, superTrackedPoiID = C_SuperTrack.GetSuperTrackedMapPin()
			if superTrackedPoiID then
				SetSuperTrackedMapPinWaypoint(superTrackedPoiID)
			end
		end
		KT:UnregEvent(eventID)
	end)

	-- Disable stop update after quest is accepted
	KT:RegEvent("QUEST_ACCEPTED", function()
		stopUpdate = not autoQuestWatch
	end)

	-- Enable stop update after quest is removed
	KT:RegEvent("QUEST_REMOVED", function()
		stopUpdate = true
	end)

	-- Enable stop update after quest is turned in
	KT:RegEvent("QUEST_TURNED_IN", function()
		stopUpdate = true
	end)

	-- Update waypoint after quest objectives changed
	KT:RegEvent("QUEST_WATCH_UPDATE", function(_, questID)
		if questID == C_SuperTrack.GetSuperTrackedQuestID() then
			C_Timer.After(0.3, function()
				if not stopUpdate then
					SetSuperTrackedQuestWaypoint(questID, true)
				end
			end)
		end
	end)

	-- Updates waypoint while moving
	KT:RegEvent("WAYPOINT_UPDATE", function()
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID then
			SetSuperTrackedQuestWaypoint(questID, true)
			OTF:Update()
		end
	end)

	-- Updates waypint while change zone
	KT:RegEvent("ZONE_CHANGED_NEW_AREA", function()
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID then
			SetSuperTrackedQuestWaypoint(questID, true)
		end
	end)

	-- Update waypoint after accept quest
	KT:RegEvent("QUEST_POI_UPDATE", function()
		local questID = C_SuperTrack.GetSuperTrackedQuestID()
		if questID and QuestUtils_IsQuestWatched(questID) then
			C_Timer.After(0, function()
				SetSuperTrackedQuestWaypoint(questID)
				OTF:Update()
			end)
		end
	end)
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	self.isLoaded = (KT:CheckAddOn("TomTom", "v4.0.7-release") and db.addonTomTom)

	if self.isLoaded then
		KT:Alert_IncompatibleAddon("TomTom", "v4.0.1-release")

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
end