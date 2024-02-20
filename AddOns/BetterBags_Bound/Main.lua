-- BetterBags namespace
-----------------------------------------------------------
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')

-- Use the L:G() function to get the localized string.
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

-- Lua API
-----------------------------------------------------------
local _G = _G
local string_find = string.find

-- WoW API
-----------------------------------------------------------
local CreateFrame = _G.CreateFrame
local C_TooltipInfo_GetBagItem = C_TooltipInfo and C_TooltipInfo.GetBagItem

-- Addon Constants
-----------------------------------------------------------
local S_BOA = "BoA"
local S_BOE = "BoE"
--- Whether we have C_TooltipInfo APIs available
local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-----------------------------------------------------------
-- Filter Setup
-----------------------------------------------------------

-- Tooltip used for scanning.
-- Let's keep this name for all scanner addons.
local _SCANNER = "AVY_ScannerTooltip"

-- Use this API to register a function that will be called for every item in the player's bags.
-- The function you provide will be given an ItemData table, which contains all properties of an item
-- loaded from the Blizzard API. From here, you can call any custom code you want to analyze the item.
-- Your function must return a string, which is the category name that the item should be placed in.
-- If your function returns nil, the item will not be placed in any category.
-- Results of this function, including nil, are cached, so you do not need to worry about performance
-- after the first scan.
---@param data ItemData
categories:RegisterCategoryFunction("BoEBoAItemsCategoryFilter", function(data)
	local quality = data.itemInfo.itemQuality
	local bindType = data.itemInfo.bindType

	-- Only parse items that are Common (1) and above, and are of type BoP, BoE, and BoU
	local junk = quality ~= nil and quality == 0
	if (not junk or (bindType ~= nil and bindType > 0 and bindType < 4)) then
		local category = GetItemCategory(data.bagid, data.slotid, data.itemInfo)
		if (category == S_BOE or category == S_BOA) then
			return L:G(category)
		end
	end

	return nil
end)

--- Get the category of an item.
---@param bagIndex number
---@param slotIndex number
---@param itemInfo ExpandedItemInfo
---@return string|nil
function GetItemCategory(bagIndex, slotIndex, itemInfo)
	local category = nil

	if (IsRetail) then
		local tooltipInfo = C_TooltipInfo_GetBagItem(bagIndex, slotIndex)
		if not tooltipInfo then return end
		for i = 2, 4 do
			local line = tooltipInfo.lines[i]
			if (not line) then
				break
			end
			local bind = GetBindString(line.leftText)
			if (bind) then
				category = bind
				break
			end
		end
	else
		if (itemInfo.bindType == 2 or itemInfo.bindType == 3) then
			local Scanner = CreateFrame("GameTooltip", _SCANNER .. itemInfo.itemGUID, nil, "GameTooltipTemplate")
			Scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
			Scanner:ClearLines()
			if bagIndex == BANK_CONTAINER then
				Scanner:SetInventoryItem("player", BankButtonIDToInvSlotID(slotIndex, nil))
			else
				Scanner:SetBagItem(bagIndex, slotIndex)
			end
			local lines = GetTooltipLines(Scanner)
			for _, line in ipairs(lines) do
				if (line == '') then
					break
				end
				local bind = GetBindString(line)
				if (bind) then
					category = bind
					break
				end
			end
			Scanner:Hide()
		end
	end
	return category
end

function GetBindString(msg)
	if (msg) then
		if (string_find(msg, ITEM_ACCOUNTBOUND) or string_find(msg, ITEM_BNETACCOUNTBOUND) or string_find(msg, ITEM_BIND_TO_BNETACCOUNT)) then
			return S_BOA
		elseif (string_find(msg, ITEM_BIND_ON_EQUIP)) then
			return S_BOE
		end
	end
end

---@param tooltip GameTooltip
function GetTooltipLines(tooltip)
	local textLines = {}
	local regions = { tooltip:GetRegions() }
	for _, r in ipairs(regions) do
		if r:IsObjectType("FontString") then
			table.insert(textLines, r:GetText())
		end
	end
	return textLines
end
