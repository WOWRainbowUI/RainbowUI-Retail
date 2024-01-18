---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Categories: AceModule
local categories = addon:GetModule('Categories')
---@class Localization: AceModule
local L = addon:GetModule('Localization')
-------------------------------------------------------
local debug = false
-------------------------------------------------------
local function printChat(message)
	if debug == true then
		print("[掰特包分類] "..message)
	end
end
-------------------------------------------------------
local GearsetItems = {}

for i = 0, (C_EquipmentSet.GetNumEquipmentSets()-1) - 1 do -- start at x, increase until GetSavedSetCount, by x increment, starts at 0 and the last one should be null, so shouldn't be counted
    printChat("套裝設定 " .. (i+1)) -- Starts at 0, but display as 1
    local itemIDs = C_EquipmentSet.GetItemIDs(i)
    if itemIDs then
        local setItemIDs = {}  -- Create a new table for each equipment set
        for _, itemID in ipairs(itemIDs) do
            printChat("ID: " .. itemID)
            table.insert(setItemIDs, itemID)
        end
        table.insert(GearsetItems, setItemIDs)  -- Insert the table of item IDs into GearsetItems
    else
        printChat("缺少套裝設定 " .. (i + 1) .. "。") -- Starts at 0, but display as 1
    end
end

-- Now GearsetItems contains a list of tables, each representing the item IDs for a specific equipment set

for _, itemList in ipairs(GearsetItems) do
    for _, ItemID in ipairs(itemList) do
        categories:AddItemToCategory(ItemID, "Sets")
    end
end