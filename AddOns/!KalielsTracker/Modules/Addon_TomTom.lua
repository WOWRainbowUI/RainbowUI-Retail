--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, KT = ...
local M = KT:NewModule(addonName.."_AddonTomTom")
KT.AddonTomTom = M

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local ipairs = ipairs

local db
local mediaPath = "Interface\\AddOns\\"..addonName.."\\Media\\"
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
		name = "TomTom",
		type = "group",
		args = {
			tomtomDesc1 = {
				name = "TomTom support combined Blizzard's POI and TomTom's Arrow.\n\n"..
						"|cffff7f00Warning:|r Original \"TomTom > Quest Objectives\" options are ignored!\n\n\n"..
						"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:10:256:256:128:160:96:128|t+"..
						"|T"..mediaPath.."KT-TomTomTag:32:32:-8:10:32:16:0:16:0:16|t...   Active POI button with TomTom Waypoint.\n"..
						"|TInterface\\WorldMap\\UI-QuestPoi-NumberIcons:32:32:-2:10:256:256:128:160:96:128|t+"..
						"|T"..mediaPath.."KT-TomTomTag:32:32:-8:10:32:16:16:32:0:16|t...   Active POI button without TomTom Waypoint (no data).",
				type = "description",
				order = 1,
			},
			tomtomArrival = {
				name = "Arrival distance",
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

	KT.optionsFrame.tomtom = ACD:AddToBlizOptions(addonName, "Addon - "..KT.options.args.tomtom.name, KT.title, "tomtom")

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

local function WorldQuestPOIGetIconInfo(mapID, questID)
	local x, y
	local taskInfo = GetQuestsForPlayerByMapIDCached(mapID)
	if taskInfo then
		for _, info  in ipairs(taskInfo) do
			if HaveQuestData(info.questId) then
				if info.questId == questID then
					x = info.x
					y = info.y
					break
				end
			end
		end
	end
	return x, y
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
			tag:SetTexture(mediaPath.."KT-TomTomTag")
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

local function AddWaypoint(questID)
	if C_QuestLog.IsQuestCalling(questID) then
		return false
	end

	local title, mapID, x, y, completed, waypointText
	if QuestUtils_IsQuestWorldQuest(questID) then
		title = C_TaskQuest.GetQuestInfoByQuestID(questID)
		mapID = C_TaskQuest.GetQuestZoneID(questID)
		if mapID then
			x, y = WorldQuestPOIGetIconInfo(mapID, questID)
		end
	else
		title = C_QuestLog.GetTitleForQuestID(questID)
		mapID, x, y, completed, waypointText = QuestPOIGetIconInfo(questID)
		if waypointText then
			title = title.."\n("..waypointText..")"
		end
	end

	if not mapID or not x or not y or not title then
		return false
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

	-- Blizzard
	hooksecurefunc(C_SuperTrack, "SetSuperTrackedQuestID", function(questID)
		stopUpdate = questID > 0 and not QuestUtils_IsQuestWatched(questID) and not C_QuestLog.IsWorldQuest(questID)
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
		if superTrackedQuestID > 0 then
			RemoveWaypoint(superTrackedQuestID)
		end
		superTrackedQuestID = typeID
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

	-- Only for World Quests
	hooksecurefunc(KT_WorldQuestObjectiveTracker, "OnQuestTurnedIn", function(self, questID)
		RemoveWaypoint(questID)
	end)

	hooksecurefunc(POIButtonMixin, "UpdateButtonStyle", function(self)
		if self.questID then
			SetWaypointTag(self, superTrackedQuestID == self.questID)
		end
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
		if questID and (QuestUtils_IsQuestWatched(questID) or C_QuestLog.IsWorldQuest(questID)) then
			SetSuperTrackedQuestWaypoint(questID)
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
	self.isLoaded = (KT:CheckAddOn("TomTom", "v4.0.3-release") and db.addonTomTom)

	if self.isLoaded then
		KT:Alert_IncompatibleAddon("TomTom", "v4.0.1-release")
	end

	local defaults = KT:MergeTables({
		profile = {
			tomtomArrival = 20,
		}
	}, KT.db.defaults)
	KT.db:RegisterDefaults(defaults)
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	SetupOptions()
	SetEvents()
	SetHooks()
end