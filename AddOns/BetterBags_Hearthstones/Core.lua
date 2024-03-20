---@class BetterBags: AceAddon
local BetterBags = LibStub("AceAddon-3.0"):GetAddon("BetterBags")
assert(BetterBags, "BetterBags_Hearthstones requires BetterBags")

---@class Categories: AceModule
local categories = BetterBags:GetModule("Categories")

---@type string, AddonNS
local _, addon = ...

-- create a category and populate with itemIDs
for itemID in pairs(addon.db) do
    categories:AddItemToCategory(itemID, TUTORIAL_TITLE31)
end