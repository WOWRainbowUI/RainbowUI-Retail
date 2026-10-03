--- Run after core but before 163UI.lua

EacDisableAddOn = function(name)
	C_AddOns.DisableAddOn(name, U1PlayerGUID)
end


EacEnableAddOn = function(name)
	C_AddOns.EnableAddOn(name, U1PlayerGUID)
end
