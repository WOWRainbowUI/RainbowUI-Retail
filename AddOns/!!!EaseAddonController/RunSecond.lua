--- Run after core but before 163UI.lua

local playerName = UnitName("player")

EacDisableAddOn = function(name)
	C_AddOns.DisableAddOn(name, playerName)
end


EacEnableAddOn = function(name)
	C_AddOns.EnableAddOn(name, playerName)
end
