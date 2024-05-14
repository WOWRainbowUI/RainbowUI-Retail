---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')
---@class Database: AceModule
local database = BetterBags:GetModule('Database')
---@class Constants: AceModule
local const = BetterBags:GetModule('Constants')
---@class Sort: AceModule
local sort = BetterBags:GetModule('Sort')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')

---@enum Add gear section order
const.GEAR_SECTION_ORDER = {
    "Head",
    "Neck",
    "Shoulder",
    "Back",
    "Chest",
    "Wrist",
    "Hands",
    "Waist",
    "Legs",
    "Feet",
    "Finger",
    "Trinket",
    "Two-Hand",
    "One-Hand",
    "Off Hand",
    "Ranged",
    "Low iLvl"
}
---@enum Add sort types
const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY = 4
const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY = 5

-- Add config option
local _GetBagOptions = config.GetBagOptions
---@param kind BagKind
---@return AceConfig.OptionsTable
function config:GetBagOptions(kind)
    local options = _GetBagOptions(self, kind)
    options.args.sectionSorting.values[const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY] = L:G("Gear > Alphabetically")
    options.args.sectionSorting.values[const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY] = L:G("Hearthstone > Gear > Alphabetically")
    return options
end


---@param kind BagKind
---@param view BagView
---@return function
function sort:GetSectionSortFunction(kind, view)
    local sortType = database:GetSectionSortType(kind, view)
    if sortType == const.SECTION_SORT_TYPE.ALPHABETICALLY then
        return self.SortSectionsAlphabetically
    elseif sortType == const.SECTION_SORT_TYPE.SIZE_ASCENDING then
        return self.SortSectionsBySizeAscending
    elseif sortType == const.SECTION_SORT_TYPE.SIZE_DESCENDING then
        return self.SortSectionsBySizeDescending
    elseif sortType == const.SECTION_SORT_TYPE.GEAR_ALPHABETICALLY then
        return self.SortSectionsGearAlphabetically
    elseif sortType == const.SECTION_SORT_TYPE.HEARTHSTONE_GEAR_ALPHABETICALLY then
        return self.SortSectionsHearthstoneGearAlphabetically
    end
    assert(false, "Unknown sort type: " .. sortType)
    return function() end
end

-- Add sort function
---@param a Section
---@param b Section
---@return boolean
function sort.SortSectionsGearAlphabetically(a, b)
    if a.title:GetText() == L:G("Recent Items") then return true end
    if b.title:GetText() == L:G("Recent Items") then return false end
    
    for _, gearType in pairs(const.GEAR_SECTION_ORDER) do
        if a.title:GetText() == L:G(gearType) then return true end
        if b.title:GetText() == L:G(gearType) then return false end
    end

    if a:GetFillWidth() then return false end
    if b:GetFillWidth() then return true end

    if a.title:GetText() == L:G("Free Space") then return false end
    if b.title:GetText() == L:G("Free Space") then return true end
    
    return stripColorCode(a.title:GetText()) < stripColorCode(b.title:GetText())
end

-- Add sort function
---@param a Section
---@param b Section
---@return boolean
function sort.SortSectionsHearthstoneGearAlphabetically(a, b)
    if a.title:GetText() == L:G("Recent Items") then return true end
    if b.title:GetText() == L:G("Recent Items") then return false end

    if a.title:GetText() == L:G("Hearthstones") then return true end
    if b.title:GetText() == L:G("Hearthstones") then return false end

    for _, gearType in pairs(const.GEAR_SECTION_ORDER) do
        if a.title:GetText() == L:G(gearType) then return true end
        if b.title:GetText() == L:G(gearType) then return false end
    end

    if a:GetFillWidth() then return false end
    if b:GetFillWidth() then return true end

    if a.title:GetText() == L:G("Free Space") then return false end
    if b.title:GetText() == L:G("Free Space") then return true end

    return stripColorCode(a.title:GetText()) < stripColorCode(b.title:GetText())
end

---@param text string
---@return string
function stripColorCode(text)
    if string.sub(text, 1, 4) == "|cff" then
        return string.sub(text, 11)
    end
    return text
end
