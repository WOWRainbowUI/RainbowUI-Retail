local _, addon = ...

local config = {}
addon.config = config

config.misdirectSpells = {
	["HUNTER"] = 34477,
	["ROGUE"] = 57934,
	["DRUID"] = 29166,
	["EVOKER"] = 360827,
}

-- Key is the target's index (first target found, second target found, etc.)
-- Value is the name of the button that will be created for /click
config.misdirectButtons = {
	[1] = "TankMDButton1",
	[2] = "TankMDButton2",
	[3] = "TankMDButton3",
	[4] = "TankMDButton4",
	[5] = "TankMDButton5",
}

-- Events which queue a tank update
config.queueEvents = {
	["GROUP_ROSTER_UPDATE"] = true,
	["PLAYER_ENTERING_WORLD"] = true,
}

-- Events which update the tank if an update is queued
config.updateEvents = {
	["PLAYER_REGEN_ENABLED"] = true,
}

-- What role to target with the ability
config.targets = {
	["HUNTER"] = "TANK",
	["ROGUE"] = "TANK",
	["DRUID"] = "HEALER",
	["EVOKER"] = "TANK",
}
