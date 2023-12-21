local addonName, addon = ...
addon.const = addon.const or {}
local const = addon.const

const.DIFFICULTY_NORMAL     = 1
const.DIFFICULTY_HEROIC     = 2
const.DIFFICULTY_MYTHIC     = 3
const.DIFFICULTY_MYTHICPLUS = 4

const.ORDER_TYPE_DEFAULT = 1
const.ORDER_TYPE_TIME = 2
const.ORDER_TYPE_SCORE = 3
const.ORDER_TYPE_LESS_PROCESS = 4
const.ORDER_TYPE_MORE_PROCESS = 5

--Hard-coded values. Should probably make these part of the DB, but it gets a little more complicated with the per-expansion textures
--[[LFG_LIST_CATEGORY_TEXTURES = {
	[1] = "questing",
	[2] = "dungeons",
	[3] = "raids", --Prefix for expansion
	[4] = "arenas",
	[5] = "scenarios",
	[6] = "custom", -- Prefix for "-pve" or "-pvp"
	[7] = "skirmishes",
	[8] = "battlegrounds",
	[9] = "ratedbgs",
	[10] = "ashran",
	[111] = "islands",
	[113] = "torghast",
};
]]

const.CATEGORY_TYPE_QUESTING = 1
const.CATEGORY_TYPE_DUNGEON  = 2
const.CATEGORY_TYPE_RAID     = 3
const.CATEGORY_TYPE_ARENA    = 4
const.CATEGORY_TYPE_SCENARIO = 5
const.CATEGORY_TYPE_CUSTOM   = 6
const.CATEGORY_TYPE_SKIRMISH = 7
const.CATEGORY_TYPE_BG       = 8
const.CATEGORY_TYPE_RBG      = 9
const.CATEGORY_TYPE_ASHRAN   = 10
const.CATEGORY_TYPE_ISLAND   = 111
const.CATEGORY_TYPE_TORGHAST = 113
--custom
const.CATEGORY_TYPE_CLASSRAID = 500

const.DUNGEON_MENU_TYPE_ACTIVITY = 1
const.DUNGEON_MENU_TYPE_GROUP = 2
const.DUNGEON_MENU_TYPE_LIST = 3