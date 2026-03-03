local _, MKPT_env, _ = ...

---@class Utils
---@field WEEKLY_QUEST_ICON string
---@field WEEKLY_TREASURE_ICON string
---@field UNIQUE_BOOK_ICON string
local Utils = {}
MKPT_env.Utils = Utils

function Utils.WeeklyTextColor(text)
  return WrapTextInColorCode(text, "FF006FDD")
end
function Utils.CatchUpTextColor(text)
    return WrapTextInColorCode(text, "FF1EFF00")
end
function Utils.UniqueTextColor(text)
    return WrapTextInColorCode(text, "FFA435EE")
end
function Utils.MissingTextColor(text)
    return WrapTextInColorCode(text, "FFFF8000")
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

Utils.WEEKLY_QUEST_ICON = CreateAtlasMarkup("quest-recurring-available", 16, 16)
Utils.WEEKLY_TREASURE_ICON = CreateAtlasMarkup("VignetteLoot", 16, 16)
Utils.UNIQUE_BOOK_ICON = CreateAtlasMarkup("Levelup-Icon-Bag", 16, 16)
Utils.UNIQUE_TREASURE_ICON = CreateAtlasMarkup("poi-islands-table", 16, 16)
Utils.TREATISE_ICON = CreateAtlasMarkup("Professions-Crafting-Orders-Icon", 16, 16)
Utils.UNIQUE_TREASURE_ICON_FADED = CreateAtlasMarkup("poi-islands-table", 16, 16, 0, 0, 64, 64, 64)
Utils.CATCHUP_ICON = CreateAtlasMarkup("characterundelete-RestoreButton", 16, 16)
Utils.FIRST_GATHER_ICON = CreateAtlasMarkup("Professions_Tracking_Ore", 16, 16).."/"..CreateAtlasMarkup("Professions_Tracking_Herb", 16, 16)
