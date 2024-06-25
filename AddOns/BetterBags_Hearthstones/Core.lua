---@class BetterBags: AceAddon
local BetterBags = LibStub("AceAddon-3.0"):GetAddon("BetterBags")
assert(BetterBags, "BetterBags_Hearthstones requires BetterBags")

---@class Categories: AceModule
local categories = BetterBags:GetModule("Categories")

---@class Localization: AceModule
local L = BetterBags:GetModule("Localization")

---@type string, table
local _, addon = ...

-- wipe Teleporters category, as it does slmost the same thing, just with fewer items in its DB
categories:WipeCategory("Teleporters")

-- create a category and populate with itemIDs
for itemID in pairs(addon.db) do
    categories:AddItemToCategory(itemID, L:G(TUTORIAL_TITLE31))
end