--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("OpenService")

local db
local defaults = {}
local overrides = {}

function KT.OpenService_Default(name, func)
    defaults[name] = func
end

function KT.OpenService_Override(name, func)
    overrides[name] = func
end

function KT.OpenService_Reset(name)
    overrides[name] = nil
end

function KT.OpenService_Open(name, ...)
    local func = overrides[name] or defaults[name]
    if not func then
        error("|cffff0000OpenService|r - handler '"..tostring(name).."' is not defined.")
    end
    func(...)
end

-- ---------------------------------------------------------------------------------------------------------------------

local function ToggleQuestLog()
    if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
        return
    end
    if WorldMapFrame:IsShown() then
        HideUIPanel(WorldMapFrame)
    else
        QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Quests)
        C_Map.OpenWorldMap()
    end
end

local function OpenMapToQuest(questID)
    QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Quests)
    C_Map.OpenWorldMap()
    if db.questLogShowDetails and GetCVarBool("questLogOpen") then
        KT_QuestMapFrame_ShowQuestDetails(questID)
    else
        local ignoreWaypoints = true
        local mapID = GetQuestUiMapID(questID, ignoreWaypoints)
        if mapID and mapID > 0 then
            EventRegistry:TriggerEvent("QuestLog.HideCampaignOverview")
            C_Map.OpenWorldMap(mapID)
            EventRegistry:TriggerEvent("MapCanvas.PingQuestID", questID)
            StaticPopup_Hide("ABANDON_QUEST")
            StaticPopup_Hide("ABANDON_QUEST_WITH_ITEMS")
        end
    end
end

local function OpenMapToAchievement(achievementID)
    if not AchievementFrame:IsShown() then
        AchievementFrame_ToggleAchievementFrame()
        AchievementFrame_SelectAchievement(achievementID)
    else
        if AchievementFrameAchievements.selection ~= achievementID then
            AchievementFrame_SelectAchievement(achievementID)
        else
            AchievementFrame_ToggleAchievementFrame()
        end
    end
end

local function OpenMapToBonusQuest(questID, areaPoiID)
    local mapID = C_TaskQuest.GetQuestZoneID(questID) or GetQuestUiMapID(questID)
    if mapID and mapID > 0 then
        QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Quests)
        C_Map.OpenWorldMap(mapID)
        if areaPoiID then
            EventRegistry:TriggerEvent("PingAreaPOIEvent", areaPoiID)
        else
            EventRegistry:TriggerEvent("MapCanvas.PingQuestID", questID)
        end
    end
end

local function OpenMapToEventPoi(areaPoiID)
    if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
        return
    end
    local mapID = C_EventScheduler.GetEventUiMapID(areaPoiID)
    if mapID then
        QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Events)
        C_Map.OpenWorldMap(mapID)
        EventRegistry:TriggerEvent("PingAreaPOIEvent", areaPoiID)
    end
end

local function OpenMapToTrackable(trackableType, trackableID)
    QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Quests)
    --First check if we are in the target encounter instance. If so, open the encounter map rather than world map
    local unused_targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID)
    local encounterTrackingInfo = targetID and C_ContentTracking.GetEncounterTrackingInfo(targetID) or nil
    if encounterTrackingInfo and AdventureGuideUtil.IsInInstance(encounterTrackingInfo.journalInstanceID) then
        --This already opens to the map the player is on, if in the future we want to open to the floor the target is on, we can feed this function a mapID
        --EJ_SelectInstance(encounterTrackingInfo.journalInstanceID)
        --local _, _, _, _, _, _, targetMapID = EJ_GetInstanceInfo()
        if not WorldMapFrame:IsShown() then
            C_Map.OpenWorldMap()
        else
            C_Map.OpenWorldMap(MapUtil.GetDisplayableMapForPlayer())
        end
        return;
    end

    local unused_trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID)
    if uiMapID then
        C_Map.OpenWorldMap(uiMapID)
    end
end

-- ---------------------------------------------------------------------------------------------------------------------

local function RegisterDefaults()
    KT.OpenService_Default("questlog", function()
        if KT.InCombatBlocked() then return end
        ToggleQuestLog()
    end)

    KT.OpenService_Default("achievements", function()
        if KT.InCombatBlocked() then return end
        ToggleAchievementFrame()
    end)

    KT.OpenService_Default("quest", function(id)
        if KT.InCombatBlocked() then return end
        OpenMapToQuest(id)
    end)

    KT.OpenService_Default("achievement", function(id)
        if KT.InCombatBlocked() then return end
        OpenMapToAchievement(id)
	end)

    KT.OpenService_Default("bonusquest", function(id, areaPoiID)
        if KT.InCombatBlocked() then return end
        OpenMapToBonusQuest(id, areaPoiID)
    end)

    KT.OpenService_Default("event", function(id)
        if KT.InCombatBlocked() then return end
        OpenMapToEventPoi(id)
    end)

    KT.OpenService_Default("profession", function(id)
        if KT.InCombatBlocked() then return end
        if C_TradeSkillUI.IsRecipeProfessionLearned(id) then
            C_TradeSkillUI.OpenRecipe(id)
        else
            Professions.InspectRecipe(id)
        end
    end)

    KT.OpenService_Default("travelerslog", function(id)
        if KT.InCombatBlocked() then return end
        MonthlyActivitiesFrame_OpenFrameToActivity(id)
    end)

    KT.OpenService_Default("endeavortask", function(id)
        if KT.InCombatBlocked() then return end
        HousingFramesUtil.OpenFrameToTaskID(id)
        HousingFramesUtil.OpenFrameToTaskID(id)
    end)

    KT.OpenService_Default("collectionitem", function(type, id)
        if KT.InCombatBlocked() then return end
        OpenMapToTrackable(type, id)
    end)
end

function SS:Init()
    db = KT.db.profile

    RegisterDefaults()
end