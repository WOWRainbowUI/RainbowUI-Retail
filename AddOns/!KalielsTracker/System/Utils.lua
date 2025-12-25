--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

-- Lua API
local floor = math.floor
local fmod = math.fmod
local format = string.format
local ipairs = ipairs
local next = next
local strfind = string.find
local strlen = string.len
local strsub = string.sub
local tonumber = tonumber

-- WoW API
local HaveQuestRewardData = HaveQuestRewardData

-- Version
function KT.IsHigherVersion(newVersion, oldVersion)
    local result = false
    if newVersion == "@project-version@" then
        result = true
    else
        local _, _, nV1, nV2, nV3, nBuild = strfind(newVersion, "(%d+)%.?(%d*)%.?(%d*)(.*)")
        local _, _, oV1, oV2, oV3, oBuild = strfind(oldVersion, "(%d+)%.?(%d*)%.?(%d*)(.*)")
        local _, _, nBuildType, nBuildNumber = strfind(nBuild or "", "%-(%w+)%.(%d+)")
        local _, _, oBuildType, oBuildNumber = strfind(oBuild or "", "%-(%w+)%.(%d+)")
        nV1, nV2, nV3, nBuildNumber = tonumber(nV1) or 0, tonumber(nV2) or 0, tonumber(nV3) or 0, tonumber(nBuildNumber)
        oV1, oV2, oV3, oBuildNumber = tonumber(oV1) or 0, tonumber(oV2) or 0, tonumber(oV3) or 0, tonumber(oBuildNumber)
        if nV1 == oV1 then
            if nV2 == oV2 then
                if nV3 == oV3 then
                    -- no support for alpha vs beta builds
                    if nBuildType == nil then
                        result = true
                    elseif nBuildType == oBuildType then
                        if nBuildNumber and nBuildNumber >= oBuildNumber then
                            result = true
                        end
                    end
                elseif nV3 > oV3 then
                    result = true
                end
            elseif nV2 > oV2 then
                result = true
            end
        elseif nV1 > oV1 then
            result = true
        end
    end
    return result
end

-- Math
function KT.round(x, precision)
    precision = precision or 1
    local n
    if precision >= 1 then
        n = floor(x / precision + 0.5) * precision
    else
        local p = floor(1 / precision + 0.5)
        n = floor(x * p + 0.5) / p
    end
    return n
end

-- Table
function KT.IsTableEmpty(table)
    return (next(table) == nil)
end

-- Tasks
function KT.GetNumTasks()
    return #GetTasksTable()
end

-- Recipes
function KT.GetNumTrackedRecipes()
    return #C_TradeSkillUI.GetRecipesTracked(true) + #C_TradeSkillUI.GetRecipesTracked(false)
end

-- Activities
function KT.GetNumTrackedActivities()
    return #C_PerksActivities.GetTrackedPerksActivities().trackedIDs
end

-- Collectibles
-- - Appearance (only this works in 10.1.5)
-- - Mount
-- - Achievement
function KT.GetNumTrackedCollectibles()
    local numCollectibles = 0
    for _, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
        numCollectibles = numCollectibles + #C_ContentTracking.GetTrackedIDs(trackableType)
    end
    return numCollectibles
end

-- Map
function KT.GetMapContinents()
    return C_Map.GetMapChildrenInfo(946, Enum.UIMapType.Continent, true)
end

function KT.GetCurrentMapAreaID()
    return C_Map.GetBestMapForUnit("player") or 0
end

function KT.GetMapContinent(mapID)
    return KT.MAP_CONTINENT_INFO[mapID]
end

function KT.GetCurrentMapContinent()
    local mapID = C_Map.GetBestMapForUnit("player") or 0
    return KT.GetMapContinent(mapID)
end

function KT.GetMapNameByID(mapID)
    if mapID then
        local mapInfo = C_Map.GetMapInfo(mapID) or {}
        return mapInfo.name
    end
    return nil
end

function KT.SetMapToCurrentZone()
    local mapID = C_Map.GetBestMapForUnit("player")
    WorldMapFrame:SetMapID(mapID)
end

function KT.GetMapID()
    return WorldMapFrame:GetMapID()
end

function KT.SetMapID(mapID)
    WorldMapFrame:SetMapID(mapID)
end

function KT.IsInBetween()  -- Shadowlands
    return (UnitOnTaxi("player") and KT.GetCurrentMapAreaID() == 1550)
end

function KT.CompareZones(mapID1, mapID2)
    local continent1 = KT.GetMapContinent(mapID1)
    local continent2 = KT.GetMapContinent(mapID2)
    local sameZone = (mapID1 == mapID2)
    local sameContinent = (continent1 and continent2 and continent1.KTmapID == continent2.KTmapID)
    return sameZone, sameContinent
end

local questOfferDataProvider
local function GetQuestOfferDataProvider()
    if not questOfferDataProvider and WorldMapFrame and WorldMapFrame.dataProviders then
        for provider in pairs(WorldMapFrame.dataProviders) do
            if provider.GetAllQuestOffersForMap then
                questOfferDataProvider = provider
                break
            end
        end
    end
    return questOfferDataProvider
end

function KT.GetQuestOfferInfo(mapID, id)
    local dataProvider = GetQuestOfferDataProvider()
    for questID, info in pairs(dataProvider:GetAllQuestOffersForMap(mapID)) do
        if questID == id then
            return info
        end
    end
end

function KT.GetTaxiNodeInfo(mapID, id)
    local taxiNodes = C_TaxiMap.GetTaxiNodesForMap(mapID)
    for _, info in ipairs(taxiNodes) do
        if info.nodeID == id then
            return info
        end
    end
end

function KT.GetDigSiteInfo(mapID, id)
    local digSites = C_ResearchInfo.GetDigSitesForMap(mapID)
    for _, info in ipairs(digSites) do
        if info.researchSiteID == id then
            return info
        end
    end
end

function KT.GetHousingPlotInfo(id)
    local houseMapData = C_HousingNeighborhood.GetNeighborhoodMapData()
    for _, info in ipairs(houseMapData) do
        if info.plotDataID == id then
            return info
        end
    end
end

-- Quests
function KT.GetQuestRewardSpells(questID)
    local spellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}
    return #spellRewards, spellRewards
end

-- HaveQuestRewardData always return false for reward choices
function KT.HaveQuestRewardData(questID)
    local result = true
    C_QuestLog.SetSelectedQuest(questID)
    local numQuestChoices = GetNumQuestLogChoices(questID, true)
    if numQuestChoices > 0 then
        for i = 1, numQuestChoices do
            local lootType = GetQuestLogChoiceInfoLootType(i)
            if lootType == 0 then
                local name = GetQuestLogChoiceInfo(i)
                if name == "" then
                    result = false
                    break
                end
            elseif lootType == 1 then
                local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, i, true)
                if currencyInfo.name == "" then
                    result = false
                    break
                end
            end
        end
    else
        result = HaveQuestRewardData(questID)
    end
    return result
end

-- Achievements
function KT.GetNumTrackedAchievements()
    return #C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
end

function KT.GetTrackedAchievements()
    return C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
end

function KT.AddTrackedAchievement(id)
    C_ContentTracking.StartTracking(Enum.ContentTrackingType.Achievement, id)
end

function KT.RemoveTrackedAchievement(id)
    C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, id, Enum.ContentTrackingStopType.Manual)
end

-- RGB to Hex
local function DecToHex(num)
    local b, k, hex, d = 16, "0123456789abcdef", "", 0
    while num > 0 do
        d = fmod(num, b) + 1
        hex = strsub(k, d, d)..hex
        num = floor(num/b)
    end
    hex = (hex == "") and "0" or hex
    return hex
end

function KT.RgbToHex(color)
    local r, g, b = DecToHex(color.r*255), DecToHex(color.g*255), DecToHex(color.b*255)
    r = (strlen(r) < 2) and "0"..r or r
    g = (strlen(g) < 2) and "0"..g or g
    b = (strlen(b) < 2) and "0"..b or b
    return r..g..b
end

-- GameTooltip
local colorNotUsable = { r = 1, g = 0, b = 0 }
function KT.GameTooltip_AddQuestRewardsToTooltip(tooltip, questID, isBonus)
    local bckSelectedQuestID = C_QuestLog.GetSelectedQuest()  -- backup selected Quest
    C_QuestLog.SetSelectedQuest(questID)  -- for num Choices

    local xp = GetQuestLogRewardXP(questID)
    local money = GetQuestLogRewardMoney(questID)
    local artifactXP = GetQuestLogRewardArtifactXP(questID)
    local numQuestCurrencies = #C_QuestLog.GetQuestRewardCurrencies(questID)
    local numQuestRewards = GetNumQuestLogRewards(questID)
    local numQuestSpellRewards, questSpellRewards = KT.GetQuestRewardSpells(questID)
    local numQuestChoices = GetNumQuestLogChoices(questID, true)
    local honor = GetQuestLogRewardHonor(questID)
    local majorFactionRepRewards = C_QuestLog.GetQuestLogMajorFactionReputationRewards(questID)
    local playerTitle = GetQuestLogRewardTitle()
    local rewardsTitle = REWARDS..":"

    if not isBonus then
        if numQuestChoices == 1 then
            tooltip:AddLine(" ")
            tooltip:AddLine(rewardsTitle)
        elseif numQuestChoices > 1 then
            tooltip:AddLine(" ")
            tooltip:AddLine(CHOOSE_ONE_REWARD..":")
            rewardsTitle = OTHER.." "..rewardsTitle
        end

        -- choices
        for i = 1, numQuestChoices do
            local lootType = GetQuestLogChoiceInfoLootType(i)
            local text, color
            if lootType == 0 then
                -- item
                local name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i)
                if numItems > 1 then
                    text = format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(numItems), name)
                elseif name and texture then
                    text = format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name)
                end
                color = isUsable and ITEM_QUALITY_COLORS[quality] or colorNotUsable
            elseif lootType == 1 then
                -- currency
                local currencyInfo = C_QuestLog.GetQuestRewardCurrencyInfo(questID, i, true)
                local amount = FormatLargeNumber(currencyInfo.totalRewardAmount)
                text = format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, currencyInfo.texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(amount), currencyInfo.name)
                local contextIcon = KT.GetBestQuestRewardContextIcon(currencyInfo.questRewardContextFlags)
                if contextIcon then
                    text = text..CreateAtlasMarkup(contextIcon, 12, 16, 3, -1)
                end
                color = ITEM_QUALITY_COLORS[currencyInfo.quality]
            end
            if text and color then
                tooltip:AddLine(text, color.r, color.g, color.b)
            end
        end
    end

    if xp > 0 or money > 0 or artifactXP > 0 or numQuestCurrencies > 0 or numQuestRewards > 0 or numQuestSpellRewards > 0 or honor > 0 or majorFactionRepRewards or playerTitle then
        local isQuestWorldQuest = QuestUtils_IsQuestWorldQuest(questID)
        local isWarModeDesired = C_PvP.IsWarModeDesired()
        local questHasWarModeBonus = C_QuestLog.QuestCanHaveWarModeBonus(questID)

        if numQuestChoices ~= 1 then
            tooltip:AddLine(" ")
            tooltip:AddLine(rewardsTitle)
        end

        -- xp
        if xp > 0 then
            tooltip:AddLine(format(BONUS_OBJECTIVE_EXPERIENCE_FORMAT, FormatLargeNumber(xp).."|c0000ff00"), 1, 1, 1)
            if isWarModeDesired and isQuestWorldQuest and questHasWarModeBonus then
                tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_XP_FORMAT:format(C_PvP.GetWarModeRewardBonus()))
            end
        end

        -- money
        if money > 0 then
            tooltip:AddLine(C_CurrencyInfo.GetCoinTextureString(money, 12), 1, 1, 1)
            if isWarModeDesired and isQuestWorldQuest and questHasWarModeBonus then
                tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(C_PvP.GetWarModeRewardBonus()))
            end
        end

        -- title
        if playerTitle then
            local text = format(RENOWN_REWARD_TITLE_NAME_FORMAT, "|cffff7f00"..playerTitle)
            tooltip:AddLine(format(BONUS_OBJECTIVE_REWARD_FORMAT, "Interface\\Icons\\INV_Misc_Note_02", text), 1, 1, 1)
        end

        -- spells
        if numQuestSpellRewards > 0 then
            for _, spellID in ipairs(questSpellRewards) do
                local spellInfo = C_QuestInfoSystem.GetQuestRewardSpellInfo(questID, spellID)
                local knownSpell = IsSpellKnownOrOverridesKnown(spellID)
                if spellInfo and spellInfo.texture and spellInfo.name and not knownSpell and (not spellInfo.isBoostSpell or IsCharacterNewlyBoosted()) and (not spellInfo.garrFollowerID or not C_Garrison.IsFollowerCollected(spellInfo.garrFollowerID)) then
                    tooltip:AddLine(format(BONUS_OBJECTIVE_REWARD_FORMAT, spellInfo.texture, spellInfo.name), 1, 1, 1)
                end
            end
        end

        -- items
        for i = 1, numQuestRewards do
            local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i, questID)
            local text
            if numItems > 1 then
                text = format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, texture, HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(numItems), name)
            elseif texture and name then
                text = format(BONUS_OBJECTIVE_REWARD_FORMAT, texture, name)
            end
            if text then
                local color = isUsable and ITEM_QUALITY_COLORS[quality] or colorNotUsable
                tooltip:AddLine(text, color.r, color.g, color.b)
            end
        end

        -- artifact power
        if artifactXP > 0 then
            tooltip:AddLine(format(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT, FormatLargeNumber(artifactXP)), 1, 1, 1)
        end

        -- currencies
        if numQuestCurrencies > 0 then
            QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip)
        end

        -- honor
        if honor > 0 then
            tooltip:AddLine(format(BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT, "Interface\\ICONS\\Achievement_LegionPVPTier4", honor, HONOR), 1, 1, 1)
        end

        -- reputation
        if majorFactionRepRewards then
            for i, rewardInfo in ipairs(majorFactionRepRewards) do
                local majorFactionData = C_MajorFactions.GetMajorFactionData(rewardInfo.factionID)
                local text = FormatLargeNumber(rewardInfo.rewardAmount).." "..format(QUEST_REPUTATION_REWARD_TITLE, majorFactionData.name)
                tooltip:AddLine(text, 1, 1, 1)
            end
        end

        -- war mode bonus (quest only)
        if isWarModeDesired and not isQuestWorldQuest and questHasWarModeBonus then
            tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(C_PvP.GetWarModeRewardBonus()))
        end
    end

    C_QuestLog.SetSelectedQuest(bckSelectedQuestID)  -- restore selected Quest
end

-- Quest
function KT.IsInstanceQuest(questID)
    local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
    return tagInfo and KT.INSTANCE_TAGS[tagInfo.tagID] or false
end

function KT.GetQuestTagInfo(questID)
    return C_QuestLog.GetQuestTagInfo(questID) or {}
end

function KT.GetNumQuests()
    local numQuests = 0
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if not info.isHidden and not info.isHeader and not C_QuestLog.IsQuestCalling(info.questID) then
            numQuests = numQuests + 1
        end
    end
    return numQuests
end

function KT.GetNumQuestWatches()
    local numWatches = C_QuestLog.GetNumQuestWatches()
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if questID then
            local quest = QuestCache:Get(questID)
            if quest:IsDisabledForSession() then
                numWatches = numWatches - 1
            end
        end
    end
    return numWatches
end

function KT.QuestSuperTracking_ChooseClosestQuest()
    local closestQuestID = 0
    local minDistSqr = math.huge

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questInfo = C_QuestLog.GetInfo(i)
        if not questInfo.isHeader and questInfo.isHidden and C_QuestLog.IsWorldQuest(questInfo.questID) then
            local distanceSq = C_QuestLog.GetDistanceSqToQuest(questInfo.questID)
            if distanceSq and distanceSq <= minDistSqr then
                minDistSqr = distanceSq
                closestQuestID = questInfo.questID
            end
        end
    end

    if closestQuestID == 0 then
        for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
            local watchedWorldQuestID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
            if watchedWorldQuestID then
                local distanceSq = C_QuestLog.GetDistanceSqToQuest(watchedWorldQuestID)
                if distanceSq and distanceSq <= minDistSqr then
                    minDistSqr = distanceSq
                    closestQuestID = watchedWorldQuestID
                end
            end
        end
    end

    if closestQuestID == 0 then
        for i = 1, C_QuestLog.GetNumQuestWatches() do
            local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
            if questID and QuestHasPOIInfo(questID) then
                local distSqr, onContinent = C_QuestLog.GetDistanceSqToQuest(questID)
                if onContinent and distSqr <= minDistSqr then
                    minDistSqr = distSqr
                    closestQuestID = questID
                end
            end
        end
    end

    if closestQuestID > 0 then
        C_SuperTrack.SetSuperTrackedQuestID(closestQuestID)
    else
        C_SuperTrack.ClearAllSuperTracked()
    end
end

-- Bonus Objective
local bonusPoiInfoCache = {}
function KT.GetBonusPoiInfoCached(questID)
    local poiInfo = bonusPoiInfoCache[questID]
    if not poiInfo then
        local mapID = GetQuestUiMapID(questID)
        if mapID then
            -- Tasks
            local tasks = GetTasksOnMapCached(mapID)
            if tasks then
                for _, info in ipairs(tasks) do
                    if questID == info.questID then
                        poiInfo = info
                        bonusPoiInfoCache[questID] = poiInfo
                        break
                    end
                end
            end
            if not poiInfo then
                -- Events
                local taskName = C_TaskQuest.GetQuestInfoByQuestID(questID)
                local events = C_AreaPoiInfo.GetEventsForMap(mapID)
                for _, poiID in ipairs(events) do
                    local info = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID)
                    if info then
                        if taskName == info.name then
                            poiInfo = info
                            -- AreaPOI is not cached
                            -- TODO: compare the needs of Siren Isle and other AreaPOIs
                            break
                        end
                    end
                end
            end
        end
    end
    return poiInfo
end

function KT.GetAreaPoiID(info)
    return info and info.areaPoiID
end

-- Scenario
function KT.IsScenarioHidden()
    local _, _, numStages = C_Scenario.GetInfo()
    return numStages == 0 or IsOnGroundFloorInJailersTower()
end

-- POI
function KT.POIButton_IsCampaign(button)
    return button.questID and C_QuestInfoSystem.GetQuestClassification(button.questID) == Enum.QuestClassification.Campaign
end

function KT.POIButton_IsEvent(button)
    return button.areaPOIID ~= nil
end

-- Time
function KT.SecondsToTime(seconds, noSeconds, maxCount, roundUp)
    local time = "";
    local count = 0;
    local tempTime;
    seconds = roundUp and ceil(seconds) or floor(seconds);
    maxCount = maxCount or 2;
    if ( seconds >= 86400  ) then
        count = count + 1;
        if ( count == maxCount and roundUp ) then
            tempTime = ceil(seconds / 86400);
        else
            tempTime = floor(seconds / 86400);
        end
        time = tempTime.." Day";
        seconds = mod(seconds, 86400);
    end
    if ( count < maxCount and seconds >= 3600  ) then
        count = count + 1;
        if ( time ~= "" ) then
            time = time..TIME_UNIT_DELIMITER;
        end
        if ( count == maxCount and roundUp ) then
            tempTime = ceil(seconds / 3600);
        else
            tempTime = floor(seconds / 3600);
        end
        time = time..tempTime.." Hr";
        seconds = mod(seconds, 3600);
    end
    if ( count < maxCount and seconds >= 60  ) then
        count = count + 1;
        if ( time ~= "" ) then
            time = time..TIME_UNIT_DELIMITER;
        end
        if ( count == maxCount and roundUp ) then
            tempTime = ceil(seconds / 60);
        else
            tempTime = floor(seconds / 60);
        end
        time = time..tempTime.." Min";
        seconds = mod(seconds, 60);
    end
    if ( count < maxCount and seconds > 0 and not noSeconds ) then
        if ( time ~= "" ) then
            time = time..TIME_UNIT_DELIMITER;
        end
        time = time..seconds.." Sec";
    end
    return time;
end

-- Combat test
function KT.InCombatBlocked()
    local blocked = InCombatLockdown()
    if blocked then
        UIErrorsFrame:AddExternalErrorMessage("戰鬥中無法完成此操作。")
    end
    return blocked
end

-- Icons
local QUEST_REWARD_CONTEXT_ICONS = {
    [Enum.QuestRewardContextFlags.FirstCompletionBonus] = "warbands-icon",
    [Enum.QuestRewardContextFlags.RepeatCompletionBonus] = "warbands-icon",
}

function KT.GetBestQuestRewardContextIcon(questRewardContextFlags)
    local contextIcon
    if questRewardContextFlags then
        if (FlagsUtil.IsSet(questRewardContextFlags, Enum.QuestRewardContextFlags.FirstCompletionBonus)) then
            contextIcon = QUEST_REWARD_CONTEXT_ICONS[Enum.QuestRewardContextFlags.FirstCompletionBonus]
        elseif (FlagsUtil.IsSet(questRewardContextFlags, Enum.QuestRewardContextFlags.RepeatCompletionBonus)) then
            contextIcon = QUEST_REWARD_CONTEXT_ICONS[Enum.QuestRewardContextFlags.RepeatCompletionBonus]
        end
    end
    return contextIcon
end

function KT.BuildIconMarkup(icons)
    for _, info in pairs(icons) do
        if info.atlas then
            local atlasInfo = C_Texture.GetAtlasInfo(info.atlas)
            if atlasInfo then
                info.markup = format("|A:%s:%d:%d:%d:%d|a", info.atlas, info.size or info.height or 0, info.size or info.width or 0, info.offsetX or 0, info.offsetY or 0)
            end
        elseif info.texture then
            info.markup = format("|T%s:%d:%d:%d:%d|t", info.texture, info.size or info.height or 0, info.size or info.width or 0, info.offsetX or 0, info.offsetY or 0)
        end
    end
end

-- Pixel Perfect
function KT.GetPixelPerfectScale(frame)
    local screenWidth = GetPhysicalScreenSize()
    local parent = frame:GetParent()
    -- TODO: Add code for frame without parent
    assert(parent, "No parent for frame "..(frame:GetName() or ""))
    local scale = parent:GetWidth() / screenWidth
    return scale
end

-- Alerts
function KT:Alert_ResetIncompatibleProfiles(version)
    if self.db.global.version and not self.IsHigherVersion(self.db.global.version, version) then
        local profile
        for _, v in ipairs(self.db:GetProfiles()) do
            profile = self.db.profiles[v]
            for k, _ in pairs(profile) do
                profile[k] = nil
            end
        end
        self.db:RegisterDefaults(self.db.defaults)
        self.StaticPopup_Show("Info", nil, "所有設定檔都已重置，因為新版本 %s 和原本儲存的設定不相容。", self.VERSION)
    end
end

function KT:Alert_IncompatibleAddon(addon, version)
    if not self.IsHigherVersion(C_AddOns.GetAddOnMetadata(addon, "Version"), version) then
        self.db.profile["addon"..addon] = false
        self.StaticPopup_Show("ReloadUI", nil, "已停用支援 |cff00ffe3%s|r，請安裝 |cff00ffe3%s|r 或更新的版本以啟用支援該插件。", C_AddOns.GetAddOnMetadata(addon, "Title"), version)
    end
end

function KT:Alert_WowheadURL(type, id)
    KT.StaticPopup_ShowURL("WowheadURL", type, id)
end

function KT:Alert_YouTubeURL(type, id)
    KT.StaticPopup_ShowURL("YouTubeURL", type, id)
end

-- Sanitize
function KT.ReconcileOrder(defaultList, savedList)
    KT.Assert(defaultList, "ReconcileOrder", "defaultList", "table")
    KT.Assert(savedList, "ReconcileOrder", "savedList", "table")

    local n = #defaultList
    local out = {}

    local allowed = {}
    for i = 1, n do
        local name = defaultList[i]
        KT.Assert(name, "ReconcileOrder", "defaultList["..i.."]", "string", type(name) == "string" and name ~= "")
        allowed[name] = true
    end

    local savedSeq, used = {}, {}
    for i = 1, n do
        local name = rawget(savedList, i)
        if type(name) == "string" and allowed[name] and not used[name] then
            savedSeq[#savedSeq + 1] = name
            used[name] = true
        end
    end

    local nextIdx = 1
    local function nextFreeDefault()
        while nextIdx <= n do
            local name = defaultList[nextIdx]
            nextIdx = nextIdx + 1
            if not used[name] then
                return name
            end
        end
        return nil
    end

    for i = 1, #savedSeq do
        local name = savedSeq[i]
        out[i] = name
    end
    for i = #savedSeq + 1, n do
        local name = nextFreeDefault()
        if name then
            out[i] = name
            used[name] = true
        end
    end

    return out
end

-- Debug
function KT.Assert(value, funcName, varName, expType, condition)
    if (condition ~= nil and not condition) or type(value) ~= expType then
        if expType == "nil" then
            local message = "[KT] %s '%s' already exists"
            error(message:format(funcName, varName), 3)
        else
            local message = "[KT] %s '%s' must be a %s ('%s')"
            error(message:format(funcName, varName, expType, tostring(value)), 3)
        end
    end
end