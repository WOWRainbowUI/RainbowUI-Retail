--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local M = KT:NewModule("Filters")
KT.Filters = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local gsub = string.gsub
local ipairs = ipairs
local pairs = pairs
local strfind = string.find
local strlower = string.lower
local strsub = string.sub

-- WoW API
local _G = _G

local db, dbChar
local remixID = 15509  -- Remix: Pandaria
local OBJECTIVES_WATCH_TOO_MANY = OBJECTIVES_WATCH_TOO_MANY..".. max. %d"

local KTF = KT.frame
local OTF = KT_ObjectiveTrackerFrame
local OTFHeader = OTF.HeaderMenu

local continents = KT.GetMapContinents()
local achievCategory = GetCategoryList()
local instanceQuestDifficulty = {
	[DifficultyUtil.ID.DungeonNormal] = { Enum.QuestTag.Dungeon },
	[DifficultyUtil.ID.DungeonHeroic] = { Enum.QuestTag.Dungeon, Enum.QuestTag.Heroic },
	[DifficultyUtil.ID.DungeonMythic] = { Enum.QuestTag.Dungeon },
	[DifficultyUtil.ID.DungeonChallenge] = { Enum.QuestTag.Dungeon },
	[DifficultyUtil.ID.DungeonTimewalker] = { Enum.QuestTag.Dungeon },
	[DifficultyUtil.ID.Raid10Normal] = { Enum.QuestTag.Raid, Enum.QuestTag.Raid10 },
	[DifficultyUtil.ID.Raid25Normal] = { Enum.QuestTag.Raid, Enum.QuestTag.Raid25 },
	[DifficultyUtil.ID.Raid10Heroic] = { Enum.QuestTag.Raid, Enum.QuestTag.Raid10 },
	[DifficultyUtil.ID.Raid25Heroic] = { Enum.QuestTag.Raid, Enum.QuestTag.Raid25 },
	[DifficultyUtil.ID.Raid40] = { Enum.QuestTag.Raid },
	[DifficultyUtil.ID.RaidLFR] = { Enum.QuestTag.Raid },
	[DifficultyUtil.ID.RaidTimewalker] = { Enum.QuestTag.Raid },
	[DifficultyUtil.ID.PrimaryRaidNormal] = { Enum.QuestTag.Raid },
	[DifficultyUtil.ID.PrimaryRaidHeroic] = { Enum.QuestTag.Raid },
	[DifficultyUtil.ID.PrimaryRaidMythic] = { Enum.QuestTag.Raid },
	[DifficultyUtil.ID.PrimaryRaidLFR] = { Enum.QuestTag.Raid },
}
local zoneSlug = {
	[198] = "Hyjal",     -- Mount Hyjal
	[201] = "Vashj'ir",  -- Kelp'thar Forest
	[204] = "Vashj'ir",  -- Abyssal Depths
	[205] = "Vashj'ir",  -- Shimmering Expanse
}

local eventFrame

--------------
-- Internal --
--------------

local function IsFavorite(type, id)
	local result = false
	for k, v in ipairs(dbChar[type].favorites) do
		if v == id then
			result = k
			break
		end
	end
	return result
end

local function ToggleFavorite(self, type, id)
	local idx = IsFavorite(type, id)
	if idx then
		tremove(dbChar[type].favorites, idx)
	else
		tinsert(dbChar[type].favorites, id)
	end
end

local function RemoveFavorite(type, id)
	local idx = IsFavorite(type, id)
	if idx then
		tremove(dbChar[type].favorites, idx)
	end
end

local function SanitizeFavorites()
	local favorites = dbChar.quests.favorites
	for id = #favorites, 1, -1 do
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(favorites[id])
		if not questLogIndex or questLogIndex <= 0 then
			tremove(favorites, id)
		end
	end

	favorites = dbChar.achievements.favorites
	for id = #favorites, 1, -1 do
		local _, _, _, completed, _, _, _, _, _, _, _, isGuild, wasEarnedByMe = GetAchievementInfo(favorites[id])
		if wasEarnedByMe or (completed and isGuild) then
			tremove(favorites, id)
		end
	end
end

local function SetHooks()
	local bck_KT_ObjectiveTracker_OnEvent = OTF:GetScript("OnEvent")
	OTF:SetScript("OnEvent", function(self, event, ...)
		if event == "QUEST_ACCEPTED" then
			local questID = ...
			if not C_QuestLog.IsQuestBounty(questID) and not C_QuestLog.IsQuestTask(questID) and db.filterAuto[1] then
				return
			end
		end
		bck_KT_ObjectiveTracker_OnEvent(self, event, ...)
	end)

	-- Quests
	local bck_KT_QuestObjectiveTracker_UntrackQuest = KT_QuestObjectiveTracker.UntrackQuest
	function KT_QuestObjectiveTracker:UntrackQuest(questID)
		if not db.filterAuto[1] then
			bck_KT_QuestObjectiveTracker_UntrackQuest(self, questID)
		end
	end
	KT_CampaignQuestObjectiveTracker.UntrackQuest = KT_QuestObjectiveTracker.UntrackQuest
	
	hooksecurefunc("KT_QuestObjectiveTracker_OnOpenDropDown", function(self)
		local block = self.activeFrame

		local info = MSA_DropDownMenu_CreateInfo()
		info.isNotRadio = true

		MSA_DropDownMenu_AddSeparator(info)

		info.text = "最愛"
		info.colorCode = "|cff009bff"
		info.notCheckable = false
		info.func = ToggleFavorite
		info.arg1 = "quests"
		info.arg2 = block.id
		info.checked = (IsFavorite(info.arg1, info.arg2))
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)
	end)
	
	-- Achievements
	local bck_KT_AchievementObjectiveTracker_UntrackAchievement = KT_AchievementObjectiveTracker.UntrackAchievement
	function KT_AchievementObjectiveTracker:UntrackAchievement(achievementID)
		if not db.filterAuto[2] then
			bck_KT_AchievementObjectiveTracker_UntrackAchievement(self, achievementID)
		end
	end

	hooksecurefunc("KT_AchievementObjectiveTracker_OnOpenDropDown", function(self)
		local block = self.activeFrame

		local info = MSA_DropDownMenu_CreateInfo()
		info.isNotRadio = true

		MSA_DropDownMenu_AddSeparator(info)

		info.text = "最愛"
		info.colorCode = "|cff009bff"
		info.notCheckable = false
		info.func = ToggleFavorite
		info.arg1 = "achievements"
		info.arg2 = block.id
		info.checked = (IsFavorite(info.arg1, info.arg2))
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)
	end)

	-- Quest Log - QuestMapFrame.lua
	local bck_QuestMapQuestOptions_TrackQuest = QuestMapQuestOptions_TrackQuest
	QuestMapQuestOptions_TrackQuest = function(questID)
		if not db.filterAuto[1] then
			bck_QuestMapQuestOptions_TrackQuest(questID)
		end
	end

	hooksecurefunc("QuestMapFrame_UpdateQuestDetailsButtons", function()
		if db.filterAuto[1] then
			QuestMapFrame.DetailsFrame.TrackButton:Disable()
			QuestLogPopupDetailFrame.TrackButton:Disable()
		else
			QuestMapFrame.DetailsFrame.TrackButton:Enable()
			QuestLogPopupDetailFrame.TrackButton:Enable()
		end
	end)
end

local function SetHooks_Init()
	-- POI - POIButton.lua
	local bck_POIButtonMixin_OnClick = POIButtonMixin.OnClick
	function POIButtonMixin:OnClick(button)
		if button ~= "LeftButton" then
			return
		end

		if self:IsSelected() then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			C_SuperTrack.ClearAllSuperTracked()
			return
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		local questID = self:GetQuestID()
		if questID and db.filterAuto[1] then
			if ChatEdit_TryInsertQuestLinkForQuestID(questID) then
				return
			end

			C_SuperTrack.SetSuperTrackedQuestID(questID)
			if self:GetPingWorldMap() then
				WorldMapPing_StartPingQuest(questID)
			end
			return
		end
		bck_POIButtonMixin_OnClick(self, button)
	end
end

-- Blizzard_AchievementUI
local function SetHooks_AchievementUI()
	local bck_AchievementTemplateMixin_ToggleTracking = AchievementTemplateMixin.ToggleTracking
	function AchievementTemplateMixin:ToggleTracking()
		if not db.filterAuto[2] then
			return bck_AchievementTemplateMixin_ToggleTracking(self)
		end
	end
	
	hooksecurefunc(AchievementTemplateMixin, "Init", function(self, elementData)
		if not self.completed then
			if db.filterAuto[2] then
				self.Tracked:Disable()
			else
				self.Tracked:Enable()
			end
		end
	end)
end

local function GetActiveWorldEvents()
	local eventsText = ""
	local date = C_DateAndTime.GetCurrentCalendarTime()
	C_Calendar.SetAbsMonth(date.month, date.year)
	local numEvents = C_Calendar.GetNumDayEvents(0, date.monthDay)
	for i=1, numEvents do
		local event = C_Calendar.GetDayEvent(0, date.monthDay, i)
		if event.calendarType == "HOLIDAY" then
			local gameHour, gameMinute = GetGameTime()
			if event.sequenceType == "START" then
				if gameHour >= event.startTime.hour and gameMinute >= event.startTime.minute then
					eventsText = eventsText..event.title.." "
				end
			elseif event.sequenceType == "END" then
				if gameHour <= event.endTime.hour and gameMinute <= event.endTime.minute then
					eventsText = eventsText..event.title.." "
				end
			else
				eventsText = eventsText..event.title.." "
			end
		end
	end
	return eventsText
end

local function FilterSkipMap(mapID)
	return not mapID or    -- Same as 947
			mapID == 2274  -- 10 - The War Within - Khaz Algar (continent)
end

local function IsInstanceQuest(questID)
	local _, _, difficulty, _ = GetInstanceInfo()
	local difficultyTags = instanceQuestDifficulty[difficulty]
	if difficultyTags then
		local tagInfo = KT.GetQuestTagInfo(questID)
		for _, tag in ipairs(difficultyTags) do
			_DBG(difficulty.." ... "..tag, true)
			if tag == tagInfo.tagID then
				return true
			end
		end
	end
	return false
end

local function IsFilterableQuest(info)
	return not info.isHidden and not info.isHeader and not info.isTask and (not info.isBounty or C_QuestLog.IsComplete(info.questID))
end

local function Filter_Quests(spec, idx)
	if not spec then return end
	local numEntries, _ = C_QuestLog.GetNumQuestLogEntries()
	local lastSuperTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0

	KT.stopUpdate = true
	if not IsModifiedClick("SHIFT") and C_QuestLog.GetNumQuestWatches() > 0 then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if not questInfo.isHeader and not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
				C_QuestLog.RemoveQuestWatch(questInfo.questID)
			end
		end
	end

	if spec == "all" then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if IsFilterableQuest(questInfo) then
				if C_QuestLog.GetNumQuestWatches() >= Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
					UIErrorsFrame:AddMessage(format(OBJECTIVES_WATCH_TOO_MANY, Constants.QuestWatchConsts.MAX_QUEST_WATCHES), 1.0, 0.1, 0.1, 1.0)
					break
				else
					C_QuestLog.AddQuestWatch(questInfo.questID)
				end
			end
		end
	elseif spec == "group" then
		for i = idx, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if not questInfo.isHidden then
				if not questInfo.isHeader and not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
					C_QuestLog.AddQuestWatch(questInfo.questID)
				elseif questInfo.isHeader then
					break
				end
			end
		end
		MSA_CloseDropDownMenus()
	elseif spec == "favorites" then
		for _, id in ipairs(dbChar.quests.favorites) do
			C_QuestLog.AddQuestWatch(id)
		end
	elseif spec == "zone" then
		local mapID = KT.GetCurrentMapAreaID()
		local zoneName = GetRealZoneText() or ""
		local zoneNamePattern = strlower(gsub(zoneName, "-", "%%-"))
		local isOnMap = false
		local isInZone = false
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if not questInfo.isHidden then
				if FilterSkipMap(mapID) then
					questInfo.isOnMap = false
				end
				if questInfo.isHeader then
					isInZone = (questInfo.title == zoneName or
							(dbChar.filter.quests.showCampaign and questInfo.campaignID))
					if mapID == 1473 then  -- 7 - Battle for Azeroth - Chamber of Heart
						isInZone = (isInZone or
								questInfo.title == "Heart of Azeroth" or  -- TODO: other languages
								questInfo.title == "Visions of N'Zoth")   -- TODO: other languages
					end
				else
					local _, objectives = GetQuestLogQuestText(i)
					local qText = strlower(questInfo.title.." - "..objectives)
					isOnMap = (questInfo.isOnMap or
							KT.QuestsCache_GetProperty(questInfo.questID, "startMapID") == mapID or
							strfind(qText, zoneNamePattern))
					if not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) and (KT.QuestsCache_GetProperty(questInfo.questID, "isCalling") or isOnMap or isInZone) then
						if KT.inInstance then
							if IsInstanceQuest(questInfo.questID) or isOnMap then
								C_QuestLog.AddQuestWatch(questInfo.questID)
							end
						else
							C_QuestLog.AddQuestWatch(questInfo.questID)
						end
					end
				end
			end
		end
	elseif spec == "campaign" then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if IsFilterableQuest(questInfo) and questInfo.campaignID then
				C_QuestLog.AddQuestWatch(questInfo.questID)
			end
		end
	elseif spec == "daily" then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if IsFilterableQuest(questInfo) and questInfo.frequency >= Enum.QuestFrequency.Daily then
				C_QuestLog.AddQuestWatch(questInfo.questID)
			end
		end
	elseif spec == "instance" then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if IsFilterableQuest(questInfo) then
				local tagInfo = KT.GetQuestTagInfo(questInfo.questID)
				if tagInfo.tagID == Enum.QuestTag.Dungeon or
						tagInfo.tagID == Enum.QuestTag.Heroic or
						tagInfo.tagID == Enum.QuestTag.Raid or
						tagInfo.tagID == Enum.QuestTag.Raid10 or
						tagInfo.tagID == Enum.QuestTag.Raid25 or
						tagInfo.tagID == Enum.QuestTag.Delve then
					C_QuestLog.AddQuestWatch(questInfo.questID)
				end
			end
		end
	elseif spec == "unfinished" then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if IsFilterableQuest(questInfo) and not C_QuestLog.IsComplete(questInfo.questID) then
				if C_QuestLog.GetNumQuestWatches() >= Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
					UIErrorsFrame:AddMessage(format(OBJECTIVES_WATCH_TOO_MANY, Constants.QuestWatchConsts.MAX_QUEST_WATCHES), 1.0, 0.1, 0.1, 1.0)
					break
				else
					C_QuestLog.AddQuestWatch(questInfo.questID)
				end
			end
		end
	elseif spec == "complete" then
		for i = 1, numEntries do
			local questInfo = C_QuestLog.GetInfo(i)
			if IsFilterableQuest(questInfo) and C_QuestLog.IsComplete(questInfo.questID) then
				C_QuestLog.AddQuestWatch(questInfo.questID)
			end
		end
	end
	KT.stopUpdate = false

	C_QuestLog.SortQuestWatches()
	KT_CampaignQuestObjectiveTracker:MarkDirty()
	KT_QuestObjectiveTracker:MarkDirty()
	if lastSuperTrackedQuestID > 0 and QuestUtils_IsQuestWatched(lastSuperTrackedQuestID) then
		C_SuperTrack.SetSuperTrackedQuestID(lastSuperTrackedQuestID)
	elseif db.questAutoFocusClosest and not C_SuperTrack.IsSuperTrackingAnything() then
		KT.QuestSuperTracking_ChooseClosestQuest()
	end
end

local function GetCategoryByZone()
	-- 0 - Kalimdor, Eastern Kingdoms
	-- 1 - Outland
	-- 2 - Northrend
	-- 4 - Pandaria
	-- 5 - Draenor
	-- 9 - Dragon Isles
	local continent = KT.GetCurrentMapContinent()
	local category = continent.name or ""
	local categoryAlt = ""
	local mapID = KT.GetCurrentMapAreaID()
	-- 10 - The War Within
	if continent.mapID == 2274 or         -- Khaz Algar
			continent.mapID == 2369 then  -- Siren Isle
		category = strsub(EXPANSION_NAME10, 5)
		categoryAlt = EXPANSION_NAME10
	-- 9 - Dragonflight
	elseif continent.mapID == 1978 then
		categoryAlt = EXPANSION_NAME9
	-- 8 - Shadowlands
	elseif continent.mapID == 1550 then
		category = EXPANSION_NAME8
	-- 7 - Battle for Azeroth
	elseif continent.mapID == 875 or     -- Zandalar
			continent.mapID == 876 or    -- Kul Tiras
			continent.mapID == 1355 or   -- Nazjatar
			continent.mapID == 948 then  -- The Maelstorm
		category = EXPANSION_NAME7
		categoryAlt = "Battle"
	-- 6 - Legion
	elseif continent.mapID == 619 then
		category = EXPANSION_NAME6
	-- 3 - Cataclysm
	elseif mapID == 198 or     -- Mount Hyjal
			mapID == 201 or    -- Vashj'ir - Kelp'thar Forest
			mapID == 204 or    -- Vashj'ir - Abyssal Depths
			mapID == 205 or    -- Vashj'ir - Shimmering Expanse
			mapID == 207 or    -- Deepholm
			mapID == 241 or    -- Twilight Highlands
			mapID == 245 or    -- Tol Barad
			mapID == 249 then  -- Uldum
		category = EXPANSION_NAME3
	end
	return category, categoryAlt
end

local function Filter_Achievements(spec)
	if not spec then return end
	local trackedAchievements = KT.GetTrackedAchievements()

	KT.stopUpdate = true
	if KT.GetNumTrackedAchievements() > 0 then
		for i=1, #trackedAchievements do
			KT.RemoveTrackedAchievement(trackedAchievements[i])
		end
	end

	if spec == "favorites" then
		for _, id in ipairs(dbChar.achievements.favorites) do
			KT.AddTrackedAchievement(id)
			if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
				break
			end
		end
	elseif spec == "zone" then
		local continentName = KT.GetCurrentMapContinent().name or ""
		local mapID = KT.GetCurrentMapAreaID()
		local zoneName = zoneSlug[mapID] or KT.GetMapNameByID(mapID) or ""
		local zoneNamePattern = gsub(zoneName, "-", "%%-")
		local categoryName, categoryNameAlt = GetCategoryByZone()
		local instance = KT.inInstance and 168 or nil
		if KT.isTimerunningPlayer and instance then
			instance = remixID
		end
		--_DBG(continentName.." / "..zoneName.." ... "..mapID.." ... "..categoryName.." / "..categoryNameAlt, true)

		-- Dungeons & Raids
		local instanceDifficulty, instanceSize
		if instance and db.filterAchievCat[instance] then
			local _, type, difficulty, difficultyName = GetInstanceInfo()
			instanceDifficulty = difficultyName
			instanceSize = ""
			if strfind(difficultyName, "^%d+.*$") then
				local _, _, size, diff = strfind(difficultyName, "^(.*) %((.*)%)$")
				instanceDifficulty = diff or "Normal"
				instanceSize = size or difficultyName
			end
			_DBG(type.." ... "..difficulty.." ... "..instanceDifficulty.." ... "..instanceSize, true)
		end
		
		-- World Events
		local events = ""
		if db.filterAchievCat[155] then
			events = GetActiveWorldEvents()
		end

		if not instance then
			-- Basic (out of Instance)
			for _, categoryID in ipairs(achievCategory) do
				local name, parentID, _ = GetCategoryInfo(categoryID)

				if db.filterAchievCat[parentID] then
					if (parentID == 92) or                                  -- Character
							(parentID == 96 and name == categoryName) or    -- Quests
							(parentID == 97 and name == categoryName) or    -- Exploration
							(parentID == 169) or                            -- Professions
							(parentID == 201) or                            -- Reputation
							(parentID == 155 and strfind(events, name)) or  -- World Events
							(categoryID == 15117 or parentID == 15117) or   -- Pet Battles
							(parentID == 15301 and categoryID == 15462) or  -- Expansion Features (only Dragonriding)
							(parentID == remixID) then                      -- Remix
						local numAchievements, _ = GetCategoryNumAchievements(categoryID)
						for i = 1, numAchievements do
							local track = false
							local aId, aName, _, aCompleted, _, _, _, aDescription = GetAchievementInfo(categoryID, i)
							if aId and not aCompleted then
								--_DBG(aId.." ... "..aName, true)
								local aText = aName.." - "..aDescription
								if parentID == 15117 and strfind(aText, continentName) then
									track = true
								elseif strfind(aText, zoneNamePattern) then
									track = true
								elseif strfind(aDescription, " capita") then  -- capital city (TODO: de, ru strings)
									local numCriteria = GetAchievementNumCriteria(aId)
									for i = 1, numCriteria do
										local cDescription, _, cCompleted = GetAchievementCriteriaInfo(aId, i)
										if not cCompleted and strfind(cDescription, zoneNamePattern) then
											track = true
											break
										end
									end
								end
								if track then
									KT.AddTrackedAchievement(aId)
								end
							end
							if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
								break
							end
						end
					end
				end
				if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
					break
				end
				if parentID == -1 then
					--_DBG(categoryID.." ... "..name, true)
				end
			end
		elseif instanceDifficulty == "Delves" then
			-- Instance - Delves
			for _, categoryID in ipairs(achievCategory) do
				local name, parentID, _ = GetCategoryInfo(categoryID)

				if db.filterAchievCat[parentID] then
					if (parentID == 15522 and (name == categoryName or name == categoryNameAlt)) then  -- Delves
						local numAchievements, _ = GetCategoryNumAchievements(categoryID)
						for i = 1, numAchievements do
							local track = false
							local aId, aName, _, aCompleted, _, _, _, aDescription = GetAchievementInfo(categoryID, i)
							if aId and not aCompleted then
								--_DBG(aId.." ... "..aName, true)
								local aText = aName.." - "..aDescription
								if strfind(aText, zoneNamePattern) then
									track = true
								end
								if track then
									KT.AddTrackedAchievement(aId)
								end
							end
							if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
								break
							end
						end
					end
				end
				if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
					break
				end
				if parentID == -1 then
					--_DBG(categoryID.." ... "..name, true)
				end
			end
		else
			-- Instance - Other
			for _, categoryID in ipairs(achievCategory) do
				local name, parentID, _ = GetCategoryInfo(categoryID)

				if db.filterAchievCat[parentID] then
					local nameMatch = strfind(name, zoneNamePattern)
					if (parentID == 95 and nameMatch) or                                                 -- Player vs. Player
							((categoryID == instance or parentID == instance) and
									(strfind(name, categoryName) or strfind(name, categoryNameAlt))) or  -- Dungeons & Raids
							(parentID == 155 and strfind(events, name)) then                             -- World Events
						local numAchievements, _ = GetCategoryNumAchievements(categoryID)
						for i = 1, numAchievements do
							local track = false
							local aId, aName, _, aCompleted, _, _, _, aDescription = GetAchievementInfo(categoryID, i)
							if aId and not aCompleted then
								--_DBG(aId.." ... "..aName, true)
								local aText = aName.." - "..aDescription
								if parentID == 95 then
									track = true
								elseif parentID == instance then
									local textMatch = strfind(aText, zoneNamePattern)
									if (name == categoryName and textMatch) or nameMatch or textMatch then
										if instanceDifficulty == "Normal" then
											if not (strfind(aText, "Heroic") or
													strfind(aText, "Mythic")) then
												track = true
											end
										elseif instanceDifficulty == "Looking For Raid" then
											if strfind(aText, "any difficulty") then  -- TODO: other languages
												track = true
											end
										else
											if strfind(aText, instanceDifficulty) or
													strfind(aText, "difficulty or higher") or  -- TODO: other languages
													strfind(aText, "any difficulty") then      -- TODO: other languages
												track = true
											end
										end
									end
								end
								if track then
									KT.AddTrackedAchievement(aId)
								end
							end
							if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
								break
							end
						end
					end
				end
				if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
					break
				end
				if parentID == -1 then
					--_DBG(categoryID.." ... "..name, true)
				end
			end
		end
	elseif spec == "wevent" then
		local events = GetActiveWorldEvents()
		local eventName = ""
		
		for _, categoryID in ipairs(achievCategory) do
			local name, parentID, _ = GetCategoryInfo(categoryID)
			
			if parentID == 155 and strfind(events, name) then  -- World Events
				eventName = eventName..(eventName ~= "" and ", " or "")..name
				local numAchievements, _ = GetCategoryNumAchievements(categoryID)
				for i = 1, numAchievements do
					local aId, aName, _, aCompleted, _, _, _, aDescription = GetAchievementInfo(categoryID, i)
					if aId and not aCompleted then
						KT.AddTrackedAchievement(aId)
					end
					if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
						break
					end
				end
			end
			if KT.GetNumTrackedAchievements() == Constants.ContentTrackingConsts.MaxTrackedAchievements then
				break
			end
			if parentID == -1 then
				--_DBG(categoryID.." ... "..name, true)
			end
		end

		if db.messageAchievement then
			local numTracked = KT.GetNumTrackedAchievements()
			if numTracked == 0 then
				KT:SetMessage("目前沒有世界事件。", 1, 1, 0)
			elseif numTracked > 0 then
				KT:SetMessage("世界事件 - "..eventName, 1, 1, 0)
			end
		end
	end
	KT.stopUpdate = false
	
	KT_AchievementObjectiveTracker:MarkDirty()
	if AchievementFrame then
		AchievementFrameAchievements_ForceUpdate()
	end
end

local DropDown_Initialize	-- function

local function DropDown_Toggle(level, button)
	local dropDown = KT.DropDown
	if dropDown.activeFrame ~= KTF.FilterButton then
		MSA_CloseDropDownMenus()
	end
	dropDown.activeFrame = KTF.FilterButton
	dropDown.initialize = DropDown_Initialize
	MSA_ToggleDropDownMenu(level or 1, button and MSA_DROPDOWNMENU_MENU_VALUE or nil, dropDown, KTF.FilterButton, -15, -1, nil, button or nil, MSA_DROPDOWNMENU_SHOW_TIME)
	if button then
		_G["MSA_DropDownList"..MSA_DROPDOWNMENU_MENU_LEVEL].showTimer = nil
	end
end

local function Filter_Menu_Quests(self, spec, idx)
	Filter_Quests(spec, idx)
	if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
		KT.QuestSuperTracking_ChooseClosestQuest()
	end
end

local function Filter_Menu_Achievements(self, spec)
	Filter_Achievements(spec)
end

local function Filter_Menu_AutoTrack(self, id, spec)
	db.filterAuto[id] = (db.filterAuto[id] ~= spec) and spec or nil
	if db.filterAuto[id] then
		if id == 1 then
			Filter_Quests(spec)
			if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
				KT.QuestSuperTracking_ChooseClosestQuest()
			end
		elseif id == 2 then
			Filter_Achievements(spec)
		end
		KTF.FilterButton:GetNormalTexture():SetVertexColor(0, 1, 0)
	else
		if id == 1 then
			QuestMapFrame_UpdateQuestDetailsButtons()
		elseif id == 2 and AchievementFrame then
			AchievementFrameAchievements_ForceUpdate()
		end
		if not (db.filterAuto[1] or db.filterAuto[2]) then
			KTF.FilterButton:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		end
	end
	DropDown_Toggle()
end

local function Filter_AchievCat_CheckAll(self, state)
	for id, _ in pairs(db.filterAchievCat) do
		db.filterAchievCat[id] = state
	end
	if db.filterAuto[2] then
		Filter_Menu_Achievements(self, db.filterAuto[2])
		MSA_CloseDropDownMenus()
	else
		local listFrame = _G["MSA_DropDownList"..MSA_DROPDOWNMENU_MENU_LEVEL]
		DropDown_Toggle(MSA_DROPDOWNMENU_MENU_LEVEL, _G["MSA_DropDownList"..listFrame.parentLevel.."Button"..listFrame.parentID])
	end
end

local function GetInlineFactionIcon()
	local coords = QUEST_TAG_TCOORDS[strupper(KT.playerFaction)]
	return CreateTextureMarkup(QUEST_ICONS_FILE, QUEST_ICONS_FILE_WIDTH, QUEST_ICONS_FILE_HEIGHT, 22, 22
		, coords[1]
		, coords[2] - 0.02 -- Offset to stop bleeding from next image
		, coords[3]
		, coords[4])
end

function DropDown_Initialize(self, level)
	local numEntries = C_QuestLog.GetNumQuestLogEntries()
	local info = MSA_DropDownMenu_CreateInfo()
	info.isNotRadio = true

	if level == 1 then
		info.notCheckable = true

		-- Quests
		info.text = TRACKER_HEADER_QUESTS
		info.isTitle = true
		MSA_DropDownMenu_AddButton(info)

		info.isTitle = false
		info.disabled = (db.filterAuto[1])
		info.func = Filter_Menu_Quests

		info.text = "全部  ("..dbChar.quests.num..")"
		info.hasArrow = not (db.filterAuto[1])
		info.value = 1
		info.arg1 = "all"
		MSA_DropDownMenu_AddButton(info)

		info.hasArrow = false

		info.text = "最愛"
		info.colorCode = "|cff009bff"
		info.arg1 = "favorites"
		info.disabled = (db.filterAuto[1] or #dbChar.quests.favorites == 0)
		MSA_DropDownMenu_AddButton(info)

		info.colorCode = nil
		info.disabled = (db.filterAuto[1])

		info.text = "區域"
		info.arg1 = "zone"
		MSA_DropDownMenu_AddButton(info)

		info.text = "戰役"
		info.arg1 = "campaign"
		MSA_DropDownMenu_AddButton(info)

		info.text = "每日 / 每週"
		info.arg1 = "daily"
		MSA_DropDownMenu_AddButton(info)

		info.text = "副本"
		info.arg1 = "instance"
		MSA_DropDownMenu_AddButton(info)

		info.text = "未完成"
		info.arg1 = "unfinished"
		MSA_DropDownMenu_AddButton(info)

		info.text = "已完成"
		info.arg1 = "complete"
		MSA_DropDownMenu_AddButton(info)

		info.text = "全部取消追蹤"
		info.disabled = (db.filterAuto[1] or C_QuestLog.GetNumQuestWatches() == 0)
		info.arg1 = ""
		MSA_DropDownMenu_AddButton(info)

		info.notCheckable = false
		info.disabled = false

		info.text = "顯示戰役"
		info.keepShownOnClick = true
		info.checked = dbChar.filter.quests.showCampaign
		info.func = function()
			dbChar.filter.quests.showCampaign = not dbChar.filter.quests.showCampaign
			if db.filterAuto[1] == "zone" then
				Filter_Menu_Quests(_, "zone")
			end
		end
		MSA_DropDownMenu_AddButton(info)

		info.keepShownOnClick = false
		info.disabled = false

		info.text = "|cff00ff00自動|r區域"
		info.arg1 = 1
		info.arg2 = "zone"
		info.checked = (db.filterAuto[info.arg1] == info.arg2)
		info.func = Filter_Menu_AutoTrack
		MSA_DropDownMenu_AddButton(info)

		MSA_DropDownMenu_AddSeparator(info)

		-- Achievements
		info.text = TRACKER_HEADER_ACHIEVEMENTS
		info.isTitle = true
		MSA_DropDownMenu_AddButton(info)

		info.isTitle = false
		info.disabled = false

		info.text = "類別"
		info.keepShownOnClick = true
		info.hasArrow = true
		info.value = 2
		info.func = nil
		MSA_DropDownMenu_AddButton(info)

		info.keepShownOnClick = false
		info.hasArrow = false
		info.func = Filter_Menu_Achievements

		info.text = "最愛"
		info.colorCode = "|cff009bff"
		info.arg1 = "favorites"
		info.disabled = (db.filterAuto[2] or #dbChar.achievements.favorites == 0)
		MSA_DropDownMenu_AddButton(info)

		info.colorCode = nil
		info.disabled = (db.filterAuto[2])

		info.text = "區域"
		info.arg1 = "zone"
		MSA_DropDownMenu_AddButton(info)

		info.text = "世界事件"
		info.arg1 = "wevent"
		MSA_DropDownMenu_AddButton(info)

		info.text = "全部取消追蹤"
		info.disabled = (db.filterAuto[2] or KT.GetNumTrackedAchievements() == 0)
		info.arg1 = ""
		MSA_DropDownMenu_AddButton(info)

		info.text = "|cff00ff00自動|r區域"
		info.notCheckable = false
		info.disabled = false
		info.arg1 = 2
		info.arg2 = "zone"
		info.checked = (db.filterAuto[info.arg1] == info.arg2)
		info.func = Filter_Menu_AutoTrack
		MSA_DropDownMenu_AddButton(info)

		-- Addon - PetTracker
		if KT.AddonPetTracker.isLoaded then
			MSA_DropDownMenu_AddSeparator(info)

			info.text = PETS
			info.isTitle = true
			MSA_DropDownMenu_AddButton(info)

			info.isTitle = false
			info.disabled = false
			info.notCheckable = false

			info.text = KT.AddonPetTracker.Texts.TrackPets
			info.checked = (PetTracker.sets.zoneTracker)
			info.func = function()
				PetTracker.ToggleOption("zoneTracker")
				if dbChar.collapsed and PetTracker.sets.zoneTracker then
					KT:MinimizeButton_OnClick()
				end
			end
			MSA_DropDownMenu_AddButton(info)

			info.text = KT.AddonPetTracker.Texts.CapturedPets
			info.checked = (PetTracker.sets.capturedPets)
			info.func = function()
				PetTracker.ToggleOption("capturedPets")
			end
			MSA_DropDownMenu_AddButton(info)

			info.notCheckable = true

			info.text = KT.AddonPetTracker.Texts.DisplayCondition
			info.keepShownOnClick = true
			info.hasArrow = true
			info.value = 3
			info.func = nil
			MSA_DropDownMenu_AddButton(info)
		end
	elseif level == 2 then
		info.notCheckable = true

		if MSA_DROPDOWNMENU_MENU_VALUE == 1 then
			info.arg1 = "group"
			info.func = Filter_Menu_Quests

			if numEntries > 0 then
				local headerTitle, headerOnMap, headerCampaign, headerShown

				for i = 1, numEntries do
					local questInfo = C_QuestLog.GetInfo(i)
					if not questInfo.isHidden then
						if questInfo.isHeader then
							headerTitle = questInfo.title
							headerOnMap = questInfo.isOnMap
							headerCampaign = questInfo.campaignID ~= nil
							headerShown = false
						elseif not questInfo.isTask and (not questInfo.isBounty or C_QuestLog.IsComplete(questInfo.questID)) then
							if not headerShown then
								info.text = (headerOnMap and "|cff00ff00" or "")..headerTitle
								if headerCampaign then
									info.text = info.text.." ("..TRACKER_HEADER_CAMPAIGN_QUESTS..")"
								end
								info.arg2 = i
								MSA_DropDownMenu_AddButton(info, level)
								headerShown = true
							end
						end
					end
				end
			end
		elseif MSA_DROPDOWNMENU_MENU_VALUE == 2 then
			info.func = Filter_AchievCat_CheckAll

			info.text = "全選"
			info.arg1 = true
			MSA_DropDownMenu_AddButton(info, level)

			info.text = "取消全選"
			info.arg1 = false
			MSA_DropDownMenu_AddButton(info, level)

			info.keepShownOnClick = true
			info.notCheckable = false

			for _, id in ipairs(achievCategory) do
				if db.filterAchievCat[id] ~= nil then
					info.text = GetCategoryInfo(id)
					info.checked = (db.filterAchievCat[id])
					info.arg1 = id
					info.func = function(_, arg)
						db.filterAchievCat[arg] = not db.filterAchievCat[arg]
						if db.filterAuto[2] then
							Filter_Menu_Achievements(_, db.filterAuto[2])
							MSA_CloseDropDownMenus()
						end
					end
					MSA_DropDownMenu_AddButton(info, level)
				end
			end
		elseif MSA_DROPDOWNMENU_MENU_VALUE == 3 then
			-- Addon - PetTracker
			info.notCheckable = false
			info.isNotRadio = false
			info.func = function(_, arg)
				PetTracker.SetOption("targetQuality", arg)
				DropDown_Toggle()
			end

			info.text = KT.AddonPetTracker.Texts.DisplayAlways
			info.arg1 = PetTracker.MaxQuality
			info.checked = (PetTracker.sets.targetQuality == info.arg1)
			MSA_DropDownMenu_AddButton(info, level)

			info.text = KT.AddonPetTracker.Texts.DisplayMissingRares
			info.arg1 = PetTracker.MaxPlayerQuality
			info.checked = (PetTracker.sets.targetQuality == info.arg1)
			MSA_DropDownMenu_AddButton(info, level)

			info.text = KT.AddonPetTracker.Texts.DisplayMissingPets
			info.arg1 = 1
			info.checked = (PetTracker.sets.targetQuality == info.arg1)
			MSA_DropDownMenu_AddButton(info, level)
		end
	end
end

local function SetFrames()
	-- Event frame
	if not eventFrame then
		eventFrame = CreateFrame("Frame")
		eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
			_DBG("Event - "..event.." - "..tostring(arg1), true)
			if event == "ADDON_LOADED" and arg1 == "Blizzard_AchievementUI" then
				SetHooks_AchievementUI()
				self:UnregisterEvent(event)
			elseif event == "QUEST_ACCEPTED" then
				local questID = arg1
				if not C_QuestLog.IsQuestTask(questID) and (not C_QuestLog.IsQuestBounty(questID) or C_QuestLog.IsComplete(questID)) and db.filterAuto[1] then
					self:RegisterEvent("QUEST_POI_UPDATE")
				end
			elseif event == "QUEST_REMOVED" then
				RemoveFavorite("quests", arg1)
			elseif event == "QUEST_COMPLETE" then
				local questID = GetQuestID()
				RemoveFavorite("quests", questID)
			elseif event == "ACHIEVEMENT_EARNED" then
				RemoveFavorite("achievements", arg1)
			elseif event == "PLAYER_ENTERING_WORLD" then
				local isInitialLogin, isReloadingUi = arg1, ...
				if not isInitialLogin and isReloadingUi then
					if not KT.IsInBetween() then
						if db.filterAuto[1] == "zone" then
							Filter_Quests("zone")
						end
						if db.filterAuto[2] == "zone" then
							Filter_Achievements("zone")
						end
					end
					self:UnregisterEvent(event)
				end
			elseif event == "QUEST_POI_UPDATE" then
				KT.questStateStopUpdate = true
				Filter_Quests("zone")
				KT.questStateStopUpdate = false
				self:UnregisterEvent(event)
			elseif event == "ZONE_CHANGED_NEW_AREA" then
				if not KT.IsInBetween() then
					C_Timer.After(0.3, function()
						if db.filterAuto[1] == "zone" then
							Filter_Quests("zone")
						end
						if db.filterAuto[2] == "zone" then
							Filter_Achievements("zone")
						end
					end)
				end
			elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
				if not KT.IsInBetween() then
					if db.filterAuto[1] == "zone" then
						Filter_Quests("zone")
					end
				end
			end
		end)
	end
	eventFrame:RegisterEvent("ADDON_LOADED")
	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("QUEST_ACCEPTED")
	eventFrame:RegisterEvent("QUEST_REMOVED")
	eventFrame:RegisterEvent("QUEST_COMPLETE")
	eventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	eventFrame:RegisterEvent("ZONE_CHANGED")
	eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	-- Filter button
	local button = CreateFrame("Button", addonName.."FilterButton", KTF.HeaderButtons)
	button:SetSize(16, 16)
	button:SetPoint("TOPRIGHT", KTF.MinimizeButton, "TOPLEFT", -4, 0)
	button:SetNormalTexture(KT.MEDIA_PATH.."UI-KT-HeaderButtons")
	button:GetNormalTexture():SetTexCoord(0.5, 1, 0.5, 0.75)
	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", function(self, btn)
		DropDown_Toggle()
	end)
	button:SetScript("OnEnter", function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("過濾方式", 1, 1, 1)
		GameTooltip:AddLine(db.filterAuto[1] and "- 區域任務", 0, 1, 0)
		GameTooltip:AddLine(db.filterAuto[2] and "- 區域成就", 0, 1, 0)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		if db.filterAuto[1] or db.filterAuto[2] then
			self:GetNormalTexture():SetVertexColor(0, 1, 0)
		else
			self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		end
		GameTooltip:Hide()
	end)
	KTF.FilterButton = button
	KT:SetHeaderButtons(1)

	-- Move other buttons
	if db.hdrOtherButtons then
		local point, _, relativePoint, xOfs, yOfs = KTF.AchievementsButton:GetPoint()
		KTF.AchievementsButton:SetPoint(point, KTF.FilterButton, relativePoint, xOfs, yOfs)
	end
end

--------------
-- External --
--------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char

    local defaults = KT:MergeTables({
        profile = {
            filterAuto = {
				nil,	-- [1] Quests
				nil,	-- [2] Achievements
			},
			filterAchievCat = {
				[92] = true,     -- Character
				[96] = true,     -- Quests
				[97] = true,     -- Exploration
				[15522] = true,  -- Delves
				[95] = true,     -- Player vs. Player
				[168] = true,    -- Dungeons & Raids
				[169] = true,    -- Professions
				[201] = true,    -- Reputation
				[155] = true,    -- World Events
				[15117] = true,  -- Pet Battles
				[15301] = true,  -- Expansion Features
			},
			filterWQTimeLeft = nil,
        },
		char = {
			filter = {
				quests = {
					showCampaign = true
				},
			}
		}
    }, KT.db.defaults)
	KT.db:RegisterDefaults(defaults)

	SetHooks_Init()
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	if KT.isTimerunningPlayer then
		if GetCategoryNumAchievements(remixID) > 0 then
			for id in pairs(db.filterAchievCat) do
				if id ~= remixID then
					db.filterAchievCat[id] = nil
				end
			end
			KT.db.defaults.profile.filterAchievCat = {
				[remixID] = true,
			}
			KT.db:RegisterDefaults(KT.db.defaults)
		end
	end

	SetHooks()
	SetFrames()

	KT:RegEvent("QUEST_LOG_UPDATE", function(eventID)
		local numEntries = C_QuestLog.GetNumQuestLogEntries()
		if numEntries > 1 then
			SanitizeFavorites()
			KT:UnregEvent(eventID)
		end
	end)
end