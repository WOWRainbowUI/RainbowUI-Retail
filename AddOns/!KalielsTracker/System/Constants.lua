--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

-- Constants
KT.TITLE = C_AddOns.GetAddOnMetadata(addonName, "Title")
KT.VERSION = C_AddOns.GetAddOnMetadata(addonName, "Version")
KT.GAME_VERSION = GetBuildInfo()
KT.LOCALE = GetLocale()

KT.MEDIA_PATH = "Interface\\AddOns\\"..addonName.."\\Media\\"

KT.MODULES = {
    "KT_ScenarioObjectiveTracker",
    "KT_UIWidgetObjectiveTracker",
    "KT_CampaignQuestObjectiveTracker",
    "KT_BonusObjectiveTracker",
    "KT_WorldQuestObjectiveTracker",
    "KT_QuestObjectiveTracker",
    "KT_AdventureObjectiveTracker",
    "KT_AchievementObjectiveTracker",
    "KT_MonthlyActivitiesObjectiveTracker",
    "KT_ProfessionsRecipeTracker"
}

KT.EXPANSION = EXPANSION_NAME10

KT.QUEST_DASH = "- "
KT_QUEST_DASH = KT.QUEST_DASH
KT.RETRIEVING_DATA = RETRIEVING_DATA.."..."

KT.TRACKER_DEFAULT_COLOR = { r = 0.93, g = 0.76, b = 0 }

KT.PLAYER_FACTION_COLORS = {
    Horde = "ff0000",
    Alliance = "007fff"
}

KT.QUALITY_COLORS = {
    Poor = "9d9d9d",
    Common = "ffffff",
    Uncommon = "1eff00",
    Rare = "0070dd",
    Epic = "a335ee",
    Legendary = "ff8000",
    Artifact = "e6cc80"
}

KT.AZERITE_CURRENCY_ID = C_CurrencyInfo.GetAzeriteCurrencyID()
KT.WAR_RESOURCES_CURRENCY_ID = C_CurrencyInfo.GetWarResourcesCurrencyID()
KT.ORDER_RESOURCES_CURRENCY_ID = 1220

KT.WORLD_QUEST_REWARD_TYPE_FLAG_MONEY = 0x0001
KT.WORLD_QUEST_REWARD_TYPE_FLAG_RESOURCES = 0x0002
KT.WORLD_QUEST_REWARD_TYPE_FLAG_ARTIFACT_POWER = 0x0004
KT.WORLD_QUEST_REWARD_TYPE_FLAG_MATERIALS = 0x0008
KT.WORLD_QUEST_REWARD_TYPE_FLAG_EQUIPMENT = 0x0010
KT.WORLD_QUEST_REWARD_TYPE_FLAG_REPUTATION = 0x0020
KT.WORLD_QUEST_REWARD_TYPE_FLAG_OTHERS = 0x10000

KT.ICON_ALERT = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew"
KT.ICONS = {
    MouseLeft = { atlas = "newplayertutorial-icon-mouse-leftbutton", width = 24, height = 28, offsetX = -1, offsetY = 6 },
    MouseRight = { atlas = "newplayertutorial-icon-mouse-rightbutton", width = 24, height = 28, offsetX = -1, offsetY = 6 }
}
do
    for _, info in pairs(KT.ICONS) do
        if info.atlas then
            local atlasInfo = C_Texture.GetAtlasInfo(info.atlas)
            if atlasInfo then
                info.markup = format("|A:%s:%d:%d:%d:%d|a", info.atlas, info.height, info.width, info.offsetX, info.offsetY)
            end
        end
    end
end

-- Excluded Quest Items
KT.EXCLUDED_QUEST_ITEMS = {
    [85113] = true  -- Special Assignment: Storm's a Brewin
}

-- Major Cities
KT.MAJOR_CITY_MAPS = {
    -- Kalimdor
    [85]   = "Orgrimmar",
    [88]   = "Thunder Bluff",
    [89]   = "Darnassus",
    [381]  = "Darnassus",
    [103]  = "The Exodar",
    -- Eastern Kingdoms
    [84]   = "Stormwind City",
    [87]   = "Ironforge",
    [90]   = "Undercity",
    [382]  = "Undercity",
    [110]  = "Silvermoon City",
    -- Outland
    [111]  = "Shattrath City",
    [301]  = "Shattrath City",
    [481]  = "Shattrath City",
    -- Northrend
    [125]  = "Dalaran (Northrend)",
    [126]  = "Dalaran (Northrend)",
    -- Pandaria
    [321]  = "Shrine of Two Moons",
    [322]  = "Shrine of Seven Stars",
    [393]  = "Shrine of Two Moons",
    [394]  = "Shrine of Seven Stars",
    -- Broken Isles
    [627]  = "Dalaran (Broken Isles)",
    [628]  = "Dalaran (Broken Isles)",
    -- Zandalar
    [1165] = "Dazar'alor",
    -- Kul Tiras
    [1161] = "Boralus",
    -- Shadowlands
    [1670] = "Oribos",
    [1671] = "Oribos",
    [1672] = "Oribos",
    [1673] = "Oribos",
    -- Dragon Isles
    [2112] = "Valdrakken",
    -- Khaz Algar
    [2339] = "Dornogal",
}

-- Blizzard Constants
KT_OBJECTIVE_TRACKER_COLOR["Header"] = { r = 1, g = 0.5, b = 0 }                 -- orange
KT_OBJECTIVE_TRACKER_COLOR["Complete"] = { r = 0.1, g = 0.85, b = 0.1 }          -- green
KT_OBJECTIVE_TRACKER_COLOR["CompleteHighlight"] = { r = 0, g = 1, b = 0 }        -- green
KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2"] = { r = 0, g = 0.5, b = 1 }              -- blue
KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2Highlight"] = { r = 0.3, g = 0.65, b = 1 }  -- blue
KT_OBJECTIVE_TRACKER_COLOR["Label"] = { r = 0.5, g = 0.5, b = 0.5 }              -- gray
KT_OBJECTIVE_TRACKER_COLOR["LabelHighlight"] = { r = 0.6, g = 0.6, b = 0.6 }     -- gray
KT_OBJECTIVE_TRACKER_COLOR["Zone"] = { r = 0.1, g = 0.65, b = 1 }                -- blue
KT_OBJECTIVE_TRACKER_COLOR["ZoneHighlight"] = { r = 0.3, g = 0.8, b = 1 }        -- blue
KT_OBJECTIVE_TRACKER_COLOR["Inactive"] = GRAY_FONT_COLOR                         -- gray
KT_OBJECTIVE_TRACKER_COLOR["InactiveHighlight"] = LIGHTGRAY_FONT_COLOR           -- gray
KT_OBJECTIVE_TRACKER_COLOR["Header"].reverse = KT_OBJECTIVE_TRACKER_COLOR["HeaderHighlight"]
KT_OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Header"]
KT_OBJECTIVE_TRACKER_COLOR["Complete"].reverse = KT_OBJECTIVE_TRACKER_COLOR["CompleteHighlight"]
KT_OBJECTIVE_TRACKER_COLOR["CompleteHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2"].reverse = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2Highlight"]
KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2Highlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2"]
KT_OBJECTIVE_TRACKER_COLOR["Label"].reverse = KT_OBJECTIVE_TRACKER_COLOR["LabelHighlight"]
KT_OBJECTIVE_TRACKER_COLOR["LabelHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Label"]
KT_OBJECTIVE_TRACKER_COLOR["Zone"].reverse = KT_OBJECTIVE_TRACKER_COLOR["ZoneHighlight"]
KT_OBJECTIVE_TRACKER_COLOR["ZoneHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Zone"]
KT_OBJECTIVE_TRACKER_COLOR["Inactive"].reverse = KT_OBJECTIVE_TRACKER_COLOR["InactiveHighlight"]
KT_OBJECTIVE_TRACKER_COLOR["InactiveHighlight"].reverse = KT_OBJECTIVE_TRACKER_COLOR["Inactive"]

-- Max Quests - fix Blizz bug
MAX_QUESTS = C_QuestLog.GetMaxNumQuestsCanAccept()