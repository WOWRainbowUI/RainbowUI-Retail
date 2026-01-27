local _, addon = ...
local D = addon.D

-- Mine
local function rgb(...)
	return addon:CreateColor(...)
end

D.global = {
	colors = {
		addon = rgb(28, 211, 162), -- #1CD3A2 (Crayola Carribean Green)
	},
}

D.profile = {
	strata = "DIALOG",
	skin = "default-legacy",
	font = {
		-- name = nil,
		size = 14,
	},
	colors = {
		name = true,
		border = true,
		icon_border = true,
		threshold = 1,
	},
	types = {},
	anchors = {
		[1] = {
			fadeout_delay = 2.8,
			growth_direction = "UP",
			growth_offset_x = 26,
			growth_offset_y = 14,
			max_active_toasts = 12,
			scale = 1,
			point = {
				p = "TOPLEFT",
				rP = "BOTTOMLEFT",
				x = 270,
				y = 370,
			},
		},
	},
}
