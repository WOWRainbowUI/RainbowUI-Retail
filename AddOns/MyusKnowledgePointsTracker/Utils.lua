local _, MKPT_env, _ = ...

---@class Utils
---@field WEEKLY_QUEST_ICON string
---@field WEEKLY_TREASURE_ICON string
---@field UNIQUE_BOOK_ICON string
local Utils = {}
MKPT_env.Utils = Utils

function Utils.WeeklyTextColor(text)
    return WrapTextInColorCode(text, MKPT_env.db.ui.colors.weekly)
end

function Utils.CatchUpTextColor(text)
    return WrapTextInColorCode(text, MKPT_env.db.ui.colors.catchUp)
end

function Utils.UniqueTextColor(text)
    return WrapTextInColorCode(text, MKPT_env.db.ui.colors.unique)
end

function Utils.MissingTextColor(text)
    return WrapTextInColorCode(text, MKPT_env.db.ui.colors.missing)
end

function Utils.DarkmoonTextColor(text)
    return WrapTextInColorCode(text, "ff843fff")
end

function Utils.RequirementsNotMetColor(text)
    return WrapTextInColorCode(text, "FFFF0000")
end

function Utils.WhiteTextColor(text)
    return WrapTextInColorCode(text, "00FFFFFF")
end

function Utils.GoldTextColor(text)
    return WrapTextInColorCode(text, "FFFFD700")
end

function Utils.UnspentKpsTextColor(text)
    return WrapTextInColorCode(text, MKPT_env.db.ui.colors.unspent)
end

Utils.WEEKLY_QUEST_ICON = CreateAtlasMarkup("quest-recurring-available", 16, 16)
Utils.WEEKLY_TREASURE_ICON = CreateAtlasMarkup("VignetteLoot", 16, 16)
Utils.UNIQUE_BOOK_ICON = CreateAtlasMarkup("Levelup-Icon-Bag", 16, 16)
Utils.UNIQUE_TREASURE_ICON = CreateAtlasMarkup("poi-islands-table", 16, 16)
Utils.TREATISE_ICON = CreateAtlasMarkup("Professions-Crafting-Orders-Icon", 16, 16)
Utils.UNIQUE_TREASURE_ICON_FADED = CreateAtlasMarkup("poi-islands-table", 16, 16, 0, 0, 64, 64, 64)
Utils.CATCHUP_ICON = CreateAtlasMarkup("characterundelete-RestoreButton", 16, 16)
Utils.FIRST_GATHER_ICON = CreateAtlasMarkup("Professions_Tracking_Ore", 16, 16) ..
    "/" .. CreateAtlasMarkup("Professions_Tracking_Herb", 16, 16)
Utils.SETTINGS_ICON = CreateAtlasMarkup("mechagon-projects", 16, 16)
Utils.DUNDUN_ICON = CreateTextureMarkup("Interface\\Icons\\INV_Ore_FelIron", 64, 64, 16, 16, 0.05, 0.95, 0.05, 0.95)

function Utils.GetFirstSundayOfMonth(year, month)
    local timetable = date("*t", time { year = year, month = month, day = 1 })
    local firstSundayOfMonth = (timetable.day - timetable.wday) % 7 + 1
    return firstSundayOfMonth
end

function Utils.GetPlayerRegion()
    local playerData = C_BattleNet.GetGameAccountInfoByGUID(UnitGUID("player"));
    -- GetCurrentRegion() uses the battle.net client or client locale as source, which may not match the actual realm region in some cases
    return (playerData and playerData.regionID) or GetCurrentRegion()
end

function Utils.GetLastSundayOfMonth(year, month)
    local firstDayOfNextMonth = time { year = year, month = month + 1, day = 1, hour = 0, min = 0, sec = 0 }
    local lastDayOfMonth = date("*t", firstDayOfNextMonth - 86400)

    local lastSundayUnix = firstDayOfNextMonth - (lastDayOfMonth.wday * 86400)

    return date("*t", lastSundayUnix).day
end

-- Offset for local machine timezone. The time() function adds local timezone, this is used to bring it back to UTC.
local LOCAL_TIME_OFFSET = difftime(time(date("*t")), time(date("!*t")))
-- US region
local PST_OFFSET = -8 * 3600
local PDT_OFFSET = -7 * 3600
-- KR region
local KST_OFFSET = 9 * 3600
-- EU region
local CET_OFFSET = 1 * 3600
local CEST_OFFSET = 2 * 3600
-- TW region
local TST_OFFSET = 8 * 3600
-- CN region
local CST_OFFSET = 8 * 3600

local function IsPacificDaylightSavings(unixUtcTime)
    local year = tonumber(date("!%Y"))
    -- PDT begins at second Sunday of March 2:00 AM PST
    local pdtBeginUnix = time { year = year, month = 3, day = Utils.GetFirstSundayOfMonth(year, 3) + 7, hour = 2, min = 0, sec = 0 } +
        LOCAL_TIME_OFFSET - PST_OFFSET
    -- PDT ends at first Sunday of November 2:00 AM PDT
    local pdtEndUnix = time { year = year, month = 11, day = Utils.GetFirstSundayOfMonth(year, 11), hour = 2, min = 0, sec = 0 } +
        LOCAL_TIME_OFFSET - PDT_OFFSET

    return pdtBeginUnix <= unixUtcTime and pdtEndUnix > unixUtcTime
end

local function IsEuropeanSummerTime(unixUtcTime)
    local year = tonumber(date("!%Y"))
    -- CEST begins at the last Sunday of March 2:00 AM CET
    local cestBeginUnix = time { year = year, month = 3, day = Utils.GetLastSundayOfMonth(year, 3), hour = 2, min = 0, sec = 0 } +
        LOCAL_TIME_OFFSET - CET_OFFSET
    -- CEST ends on the last Sunday of October 3:00 AM CEST
    local cestEndUnix = time { year = year, month = 10, day = Utils.GetLastSundayOfMonth(year, 10), hour = 3, min = 0, sec = 0 } +
        LOCAL_TIME_OFFSET - CEST_OFFSET

    return cestBeginUnix <= unixUtcTime and cestEndUnix > unixUtcTime
end

-- DMF begins at Midnight of the first Sunday of the month based on the region timezone, not server.
-- Id - Region - Timezones
-- 1  -   US   - PST-8,PDT-7
-- 2  -   KR   - KST+9
-- 3  -   EU   - CET+1,CEST+2
-- 4  -   TW   - TST+8
-- 5  -   CN   - CST+8
function Utils.IsDmfUp(region, unixtime)
    -- Adds the respective region's timezone offset to unixtime(UTC)
    if region == 1 then
        -- 1 US
        if IsPacificDaylightSavings(unixtime) then
            unixtime = unixtime + PDT_OFFSET
        else
            unixtime = unixtime + PST_OFFSET
        end
    elseif region == 2 then
        -- 2 KR 	
        unixtime = unixtime + KST_OFFSET
    elseif region == 3 then
        -- 3 EU
        if IsEuropeanSummerTime(unixtime) then
            unixtime = unixtime + CEST_OFFSET
        else
            unixtime = unixtime + CET_OFFSET
        end
    elseif region == 4 then
        -- 4 TW
        unixtime = unixtime + TST_OFFSET
    elseif region == 5 then
        -- 5 CN
        unixtime = unixtime + CST_OFFSET
    end

    -- Adding ! to the date function's first parameter causes it to ignore local timezone
    local regionDateTable = date("!*t", unixtime)

    local dayOfMonth = regionDateTable.day
    local firstSundayOfMonth = Utils.GetFirstSundayOfMonth(regionDateTable.year, regionDateTable.month)
    local daysSinceFirstSunday = dayOfMonth - firstSundayOfMonth

    return daysSinceFirstSunday >= 0 and daysSinceFirstSunday <= 6
end
