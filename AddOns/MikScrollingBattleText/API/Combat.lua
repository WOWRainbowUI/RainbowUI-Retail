local RestrictedValue = MikSBT.API.RestrictedValue
local Combat = {}

function Combat:NormalizeUnitCombat(unit, action, flags, amount, schoolMask)
	unit = RestrictedValue:String(unit)
	action = RestrictedValue:String(action)
	amount = RestrictedValue:Number(amount)
	if not unit or not action or amount == nil then
		return nil
	end

	flags = RestrictedValue:String(flags)
	schoolMask = RestrictedValue:Number(schoolMask)

	return {
		unit = unit,
		action = action,
		flags = flags,
		amount = amount,
		schoolMask = schoolMask,
		isCritical = flags == "CRITICAL",
	}
end

MikSBT.API.Combat = Combat

return Combat
