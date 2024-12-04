local _, addonTable = ...
local E, C = addonTable.E, addonTable.C

-- Lua
local _G = getfenv(0)

E:RegisterSkin("beautycase", {
	name = "化妝箱",
	leaves = {
		points = {
			{x = -4, y = 18}, -- topleft
			{x = 12, y = 12}, -- topright
			{y = -14}, -- bottomright
		},
	},
	border = {
		offset = -4,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border-beautycase",
	},
})

E:RegisterSkin("beautycase-no-art", {
	name = "化妝箱 (無背景圖)",
	template = "beautycase",
	text_bg = {
		hidden = true,
	},
	leaves = {
		hidden = true,
	},
	dragon = {
		hidden = true,
	},
	icon_highlight = {
		hidden = true,
	},
	bg = {
		default = {
			texture = {0.06, 0.06, 0.06, 0.8},
		},
	},
})

E:RegisterSkin("beautycase-legacy", {
	name = "Beautycase (Legacy)",
	template = "default-legacy",
	leaves = {
		points = {
			{x = -4, y = 18}, -- topleft
			{x = 12, y = 12}, -- topright
			{y = -14}, -- bottomright
		},
	},
	border = {
		offset = -4,
		texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-border-beautycase",
	},
})

E:RegisterSkin("beautycase-twotone", {
	name = "化妝箱 (雙色調)",
	template = "beautycase",
	title = {
		color = {0.15, 0.15, 0.15},
	},
	text_bg = {
		hidden = true,
	},
	bg = {
		default = {
			texture = "Interface\\AddOns\\ls_Toasts\\assets\\toast-bg-default-as",
		},
	},
})
