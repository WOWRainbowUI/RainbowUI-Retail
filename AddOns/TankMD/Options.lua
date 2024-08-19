---@class AddonNamespace
local addon = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("TankMD")

addon.defaultProfile = {
	profile = {
		tankSelectionMethod = "tankRoleOnly",
		prioritizeFocus = false,
	},
}

---@type AceConfig.OptionsTable
addon.optionsTable = {
	name = L.header,
	type = "group",
	childGroups = "tab",
	order = 1,
	get = function(info)
		return addon.db.profile[info[#info]]
	end,
	set = function(info, value)
		addon.db.profile[info[#info]] = value
		local TankMD = AceAddon:GetAddon("TankMD")
		---@cast TankMD TankMD
		TankMD:QueueButtonTargetUpdate()
	end,
	args = {
		general = {
			type = "group",
			name = L.general,
			order = 1,
			args = {
				tankSelectionMethod = {
					type = "select",
					name = L.tank_selection_method,
					order = 1,
					width = "full",
					values = {
						tankRoleOnly = L.tank_role_only,
						tanksAndMainTanks = L.tanks_and_main_tanks,
						prioritizeMainTanks = L.prioritize_main_tanks,
						mainTanksOnly = L.main_tanks_only,
					},
					sorting = { "tankRoleOnly", "tanksAndMainTanks", "prioritizeMainTanks", "mainTanksOnly" },
					disabled = function()
						local _, class = UnitClass("player")
						return class ~= "HUNTER" and class ~= "ROGUE"
					end,
				},
				prioritizeFocus = {
					type = "toggle",
					name = L.prioritize_focus,
					desc = L.prioritize_focus_desc,
					order = 2,
					width = "full",
				}
			},
		},
	},
}
