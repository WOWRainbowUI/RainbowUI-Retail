-- This will get a handle to the BetterBags addon.
---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(addon, "BetterBags_Openable requires BetterBags")

-- This will get a handle to the Categories module, which exposes
-- the API for creating categories.
---@class Categories: AceModule
local categories = addon:GetModule('Categories')

-- This will get a handle to the Config module, which exposes
-- the API for creating a configuration entry in the BetterBags config panel.
---@class Config: AceModule
local config = addon:GetModule('Config')

-- This will get a handle to the localization module, which should be
-- used for all text your users will see. For all category names,
-- you should use the L:G() function to get the localized string.
---@class Localization: AceModule
local L = addon:GetModule('Localization')

-- This will create a custom category based and add each item using their ID.
for itemID in pairs(addon.items) do
    categories:AddItemToCategory(itemID, L:G("Openable"))
end