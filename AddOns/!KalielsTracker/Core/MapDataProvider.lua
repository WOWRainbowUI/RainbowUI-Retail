---@type KT
local _, KT = ...

local CACHE_BUCKET_SECONDS = 3600
local cacheBucket = math.floor(GetServerTime() / CACHE_BUCKET_SECONDS)

local function UpdateCacheWindow()
    local currentBucket = math.floor(GetServerTime() / CACHE_BUCKET_SECONDS)
    if currentBucket ~= cacheBucket then
        cacheBucket = currentBucket
        KT.ClearCachedActivitiesForPlayer()
    end
end

-- SharedMapPoiTemplates.lua -------------------------------------------------------------------------------------------

-- Cache for C_QuestLog.GetQuestsOnMap
local questCache = {}

function KT.GetQuestsOnMapCached(mapID)
    UpdateCacheWindow()

    local entry = questCache[mapID]
    if entry then
        return entry
    end

    local quests = C_QuestLog.GetQuestsOnMap(mapID)
    questCache[mapID] = quests
    return quests
end

-- Cache for C_TaskQuest.GetQuestsOnMap
local taskCache = {}

local function AddIndicatorQuestsToTasks(container, mapID)
    local questsOnMap = KT.GetQuestsOnMapCached(mapID)  -- MSA
    if questsOnMap then
        for i, info in ipairs(questsOnMap) do
            if(info.isMapIndicatorQuest) then
                if (info.type ~= Enum.QuestTagType.Islands or ShouldShowIslandsWeeklyPOI()) then
                    info.inProgress = true
                    info.numObjectives = C_QuestLog.GetNumQuestObjectives(info.questID)
                    info.mapID = mapID
                    info.isQuestStart = false  -- not an offer
                    info.isDaily = false
                    info.isCombatAllyQuest = false
                    info.isMeta = false
                    -- info.childDepth avoided

                    table.insert(container, info)
                end
            end
        end
    end
end

function KT.GetTasksOnMapCached(mapID)
    UpdateCacheWindow()

    local entry = taskCache[mapID]
    if entry then
        return entry
    end

    local tasks = C_TaskQuest.GetQuestsOnMap(mapID)
    AddIndicatorQuestsToTasks(tasks, mapID)
    taskCache[mapID] = tasks
    return tasks
end

function KT.ClearCachedQuestsForPlayer()
    questCache = {}
    taskCache = {}
end

-- Cache for C_AreaPoiInfo.GetAreaPOIForMap
local areaPOICache = {}

function KT.GetAreaPOIsForPlayerByMapIDCached(mapID)
    UpdateCacheWindow()

    local entry = areaPOICache[mapID]
    if entry then
        return entry
    end

    local areaPOIs = C_AreaPoiInfo.GetAreaPOIForMap(mapID)
    areaPOICache[mapID] = areaPOIs
    return areaPOIs
end

function KT.ClearCachedAreaPOIsForPlayer()
    areaPOICache = {}
end

function KT.ClearCachedActivitiesForPlayer()
    KT.ClearCachedQuestsForPlayer()
    KT.ClearCachedAreaPOIsForPlayer()
end

-- QuestOfferDataProvider.lua ------------------------------------------------------------------------------------------

-- GetQuestOffersForMap
local questOfferPinData =
{
    [Enum.QuestClassification.Normal] = 	{ level = 1, atlas = "QuestNormal", },
    [Enum.QuestClassification.Questline] = 	{ level = 1, atlas = "QuestNormal", },
    [Enum.QuestClassification.Recurring] =	{ level = 2, atlas = "UI-QuestPoiRecurring-QuestBang", },
    [Enum.QuestClassification.Meta] = 		{ level = 3, atlas = "quest-wrapper-available", },
    [Enum.QuestClassification.Calling] = 	{ level = 4, atlas = "Quest-DailyCampaign-Available", },
    [Enum.QuestClassification.Campaign] = 	{ level = 5, atlas = "Quest-Campaign-Available", },
    [Enum.QuestClassification.Legendary] =	{ level = 6, atlas = "UI-QuestPoiLegendary-QuestBang", },
    [Enum.QuestClassification.Important] =	{ level = 7, atlas = "importantavailablequesticon", },
};

local function InitializeCommonQuestOfferData(info)
    if info then
        local questClassification = C_QuestInfoSystem.GetQuestClassification(info.questID);
        local pinData = questOfferPinData[questClassification];
        if pinData then
            info.questClassification = questClassification;
            info.pinLevel = pinData.level;
            info.questIcon = pinData.atlas;
            info.pinAlpha = info.isHidden and 0.5 or 1; -- TODO: Trivial quests need special icons, but kee the same atlas as normal.
            return info;
        end
    end
end

-- Because of the number of different data sources that exist, convert them all to a common data format for pin setup.
-- This API could move, but the key is being able to get all the information distilled into a homogenous source.
-- Because QuestLineInfo was how this API existed in the first place and tasks are newly integrated, use QuestLineInfo as a starting point
local function CreateQuestOfferFromQuestLineInfo(mapID, info)
    if InitializeCommonQuestOfferData(info) then
        -- These are fields that are not present on questLineInfo that are present on taskInfo
        -- They're just called out to maintain parity for the most part
        info.isQuestStart = true;
        info.numObjectives = 0;
        info.mapID = mapID;
        info.childDepth = nil; -- Called out to maintain
        return info;
    end
end

local function CreateQuestOfferFromTaskInfo(mapID, info)
    if InitializeCommonQuestOfferData(info) then
        -- These are fields that are not present on taskInfo that are present on questLineInfo
        -- Also called out to maintain parity.
        info.questLineName = nil;

        local title, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(info.questID);
        local questClassification = C_QuestInfoSystem.GetQuestClassification(info.questID);
        info.questName = title;
        info.questLineID = nil;
        info.isHidden = C_QuestLog.IsQuestTrivial(info.questID);
        info.isLegendary = questClassification == Enum.QuestClassification.Legendary;
        info.isCampaign = false; -- This cannot be a campaign for a task, it would be in a quest line
        info.isImportant = questClassification == Enum.QuestClassification.Important;
        info.isAccountCompleted = C_QuestLog.IsQuestFlaggedCompletedOnAccount(info.questID);
        info.floorLocation = Enum.QuestLineFloorLocation.Same; -- This data may not be exposed yet
        info.isLocalStory = false;
        return info;
    end
end

local function CheckAddOffer(questOffers, offer)
    if offer and not questOffers[offer.questID] then
        questOffers[offer.questID] = offer;
    end
end

local function AddQuestLinesToQuestOffers(questOffers, mapID)
    for index, questLineInfo in ipairs(C_QuestLine.GetAvailableQuestLines(mapID)) do
        CheckAddOffer(questOffers, CreateQuestOfferFromQuestLineInfo(mapID, questLineInfo));
    end

    local forceVisibleQuests = C_QuestLine.GetForceVisibleQuests(mapID);
    for _, questID in ipairs(forceVisibleQuests) do
        CheckAddOffer(questOffers, CreateQuestOfferFromQuestLineInfo(mapID, C_QuestLine.GetQuestLineInfo(questID, mapID)));
    end
end

local function AddTaskInfoToQuestOffers(questOffers, mapID)
    local taskInfo = KT.GetTasksOnMapCached(mapID);  -- MSA
    if taskInfo then
        for i, info in ipairs(taskInfo) do
            CheckAddOffer(questOffers, CreateQuestOfferFromTaskInfo(mapID, info));
        end
    end
end

local function GetAllQuestOffersForMap(mapID)
    -- NOTE: This needs to process things in priority order:
    -- 1. QuestLine
    -- 2. Force Show
    -- 3. Task Info
    -- Never add duplicates, because the priority is ranked from most info to least info.
    -- questOffers will be indexed by questID to make it easier to avoid adding duplicates
    local questOffers = {};
    AddQuestLinesToQuestOffers(questOffers, mapID);
    AddTaskInfoToQuestOffers(questOffers, mapID);

    return questOffers;
end

function KT.GetQuestOffersForMap(mapID)
    return GetAllQuestOffersForMap(mapID)
end