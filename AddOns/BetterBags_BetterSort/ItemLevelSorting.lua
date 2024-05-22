---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Sort: AceModule
local sort = BetterBags:GetModule('Sort')
---@class Bags: AceModule
local DB = BetterBags:GetModule('Database')

-- MARK: local BetterBags functions
-------------------------------------------------------
local GetItemSortFunction = sort.GetItemSortFunction

-- MARK: Overrides
-------------------------------------------------------
---@param kind BagKind
---@param view BagView
---@return function
function sort:GetItemSortFunction(kind, view)
    -- Get the base item sort function
    local defaultItemSortFunction = GetItemSortFunction(self, kind, view)
    -- By default this function can return false in case of an undefined bag kind
    -- So we simply return the base item sort function in that case
    if not defaultItemSortFunction then return defaultItemSortFunction end

    -- Wrap the original function inside our own sorting function, so we have proper fallback
    -- Essentially needed since this is the only place where we have information about the bag kind
    -- and as such this is the only place where we known if we should sort by item level or not
    local shouldSortByItemLevel = DB:GetItemLevelOptions(kind).sort
    if shouldSortByItemLevel then
        return function(a, b)
            return SortItemsByItemLevelThenDefault(a, b, defaultItemSortFunction)
        end
    end

    return defaultItemSortFunction
end

-- MARK: Sorting functions
-------------------------------------------------------
---@param a Item
---@param b Item
---@param defaultItemSortFunction function
---@return boolean
function SortItemsByItemLevelThenDefault(a, b, defaultItemSortFunction)
    local aData, bData = getValidData(a), getValidData(b)
    if not aData or not bData then return defaultItemSortFunction(a, b) end

    local maybeSortedByItemLevel = MaybeSortItemsByItemLevel(aData, bData)
    if maybeSortedByItemLevel == nil then
        return defaultItemSortFunction(a, b)
    end

    return maybeSortedByItemLevel
end

---@param aData ItemData
---@param bData ItemData
---@return boolean
function MaybeSortItemsByItemLevel(aData, bData)
    -- No item level so use the default sort
    if not isGearWithItemLevel(aData.itemInfo) or not isGearWithItemLevel(bData.itemInfo) then
        return nil
    end

    -- Equal item levels so use the default sort
    if aData.itemInfo.currentItemLevel == bData.itemInfo.currentItemLevel then 
        return nil 
    end

    return aData.itemInfo.currentItemLevel < bData.itemInfo.currentItemLevel
end

-- MARK: Helper Functions
-------------------------------------------------------
---@param a Item
---@param b Item
---@return ItemData | nil
function getValidData(item)
    if item.isFreeSlot then return nil end
    local itemData = item:GetItemData()
    if not itemData or not itemData.itemInfo then
        return nil
    end

    return itemData
end

---@param itemInfo ExpandedItemInfo
---@return boolean
function isGearWithItemLevel(itemInfo) 
    return (itemInfo.classID == Enum.ItemClass.Armor or itemInfo.classID == Enum.ItemClass.Weapon) 
            and itemInfo.currentItemLevel
end
