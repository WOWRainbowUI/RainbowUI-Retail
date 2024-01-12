---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

---@param data ItemData
categories:RegisterCategoryFunction("KeystonesCategoryFilter", function(data)
	if C_Item.IsItemKeystoneByID(data.itemInfo.itemID) then
		return L:G("|cff7997dbKeystone|r")
	end
	return nil
end)
