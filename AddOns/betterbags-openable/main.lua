local addonName, root = ... --[[@type string, table]]
---@class BetterBagsOpenable: AceModule AceDB
local addon = LibStub('AceAddon-3.0'):NewAddon(root, addonName)

---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon('BetterBags')
---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Debug: AceModule
local debug = BetterBags:GetModule('Debug')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')

---@class Profile
local profile = {
	FilterGenericUse = false,
	FilterToys = true,
	FilterAppearance = true,
	FilterMounts = true,
	FilterRepGain = true,
	CreatableItem = true
}

--Setup DB
local DataBase = LibStub('AceDB-3.0'):New('BetterBagsOpenableDB', {profile = profile}, true)
local DB = DataBase.profile ---@type Profile

--Get Locale
local REP_USE_TEXT = QUEST_REPUTATION_REWARD_TOOLTIP:match('%%d%s*(.-)%s*%%s')
local Localized = {
	zhTW = {
		['Use: Teaches you how to summon this mount'] = '教你學會如何召喚這個坐騎。',
		['Use: Collect the appearance'] = '收集這個外觀'
	}
}

local Locale = GetLocale()
function GetLocaleString(key)
	if Localized[Locale] then
		return Localized[Locale][key]
	end
	return key
end

--Setup Options
local options = {
	FilterGenericUse = {
		type = 'toggle',
		width = 'full',
		order = 0,
		name = '一般能「使用：」的物品分類',
		desc = '過濾所有有 "使用" 效果的物品。',
		get = function()
			return DB.FilterGenericUse
		end,
		set = function(_, value)
			DB.FilterGenericUse = value
		end
	},
	FilterToys = {
		type = 'toggle',
		width = 'full',
		order = 1,
		name = '玩具分類',
		desc = '過濾所有在浮動提示資訊中有寫「' .. ITEM_TOY_ONUSE .. '」的物品',
		get = function()
			return DB.FilterToys
		end,
		set = function(_, value)
			DB.FilterToys = value
		end
	},
	FilterMounts = {
		type = 'toggle',
		width = 'full',
		order = 1,
		name = '坐騎分類',
		desc = '過濾所有在浮動提示資訊中有寫「' .. GetLocaleString('Use: Teaches you how to summon this mount') .. '」的物品',
		get = function()
			return DB.FilterMounts
		end,
		set = function(_, value)
			DB.FilterMounts = value
		end
	},
	FilterAppearance = {
		type = 'toggle',
		width = 'full',
		order = 2,
		name = '造型物品分類',
		desc = '過濾所有在浮動提示資訊中有寫「' .. ITEM_COSMETIC_LEARN .. '」的物品',
		get = function()
			return DB.FilterAppearance
		end,
		set = function(_, value)
			DB.FilterAppearance = value
		end
	},
	FilterRepGain = {
		type = 'toggle',
		width = 'full',
		order = 2,
		name = '聲望物品分類',
		desc = '過濾所有在浮動提示資訊中有寫「' .. ITEM_SPELL_TRIGGER_ONUSE .. '」和「' .. REP_USE_TEXT .. '」的物品',
		get = function()
			return DB.FilterRepGain
		end,
		set = function(_, value)
			DB.FilterRepGain = value
		end
	},
	CreatableItem = {
		type = 'toggle',
		width = 'full',
		order = 3,
		name = '可製造的物品分類',
		desc = '過濾所有在浮動提示資訊中有寫「' .. ITEM_CREATE_LOOT_SPEC_ITEM .. '」的物品',
		get = function()
			return DB.CreatableItem
		end,
		set = function(_, value)
			DB.CreatableItem = value
		end
	}
}

config:AddPluginConfig('打開', options)

local function Log(msg)
	debug:Log('Openable', msg)
end

local Tooltip = CreateFrame('GameTooltip', 'BBOpenable', nil, 'GameTooltipTemplate')
local PREFIX = '|cff2beefd'
local OPENABLE_CATEGORY_TITLE = '|cff2beefd 打開'

local SearchItems = {
	'Open the container',
	'Use: Open',
	ITEM_OPENABLE
}

---@param data ItemData
local function filter(data)
	Tooltip:ClearLines()
	Log('Filtering ' .. data.itemHash)
	Log('Bag ID: ' .. data.bagid .. ' Slot ID: ' .. data.slotid)
	--Set the Item in the tooltip
	Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	Tooltip:SetBagItem(data.bagid, data.slotid)
	Log('NumLines ' .. Tooltip:NumLines())

	for i = 1, Tooltip:NumLines() do
		line = _G['BBOpenableTextLeft' .. i]
		local LineText = line:GetText()
		Log(LineText)

		--Search for the strings in the tooltip
		for _, v in pairs(SearchItems) do
			if string.find(LineText, v) then
				return OPENABLE_CATEGORY_TITLE
			end
		end

		if DB.FilterAppearance and (string.find(LineText, ITEM_COSMETIC_LEARN) or string.find(LineText, GetLocaleString('Use: Collect the appearance'))) then
			return PREFIX .. '造型'
		end

		-- Remove (%s). from ITEM_CREATE_LOOT_SPEC_ITEM
		local CreateItemString = ITEM_CREATE_LOOT_SPEC_ITEM:gsub(' %(%%s%)%.', '')
		if DB.CreatableItem and string.find(LineText, CreateItemString) then
			return PREFIX .. '製造'
		end

		if LineText == LOCKED then
			return PREFIX .. '已鎖'
		end

		if DB.FilterToys and string.find(LineText, ITEM_TOY_ONUSE) then
			return PREFIX .. '玩具'
		end

		if DB.FilterRepGain and string.find(LineText, REP_USE_TEXT) and string.find(LineText, ITEM_SPELL_TRIGGER_ONUSE) then
			return PREFIX .. '聲望'
		end

		if DB.FilterMounts and string.find(LineText, GetLocaleString('Use: Teaches you how to summon this mount')) then
			return PREFIX .. '坐騎'
		end

		if DB.FilterGenericUse and string.find(LineText, ITEM_SPELL_TRIGGER_ONUSE) then
			return PREFIX .. '使用'
		end
	end
end

categories:RegisterCategoryFunction('reg', filter)
