local RestrictedValue = MikSBT.API.RestrictedValue
local Units = {}

local function IsUnitToken(unit)
	return RestrictedValue:String(unit) ~= nil
end

local function CallBoolean(func, ...)
	if type(func) ~= "function" then
		return false
	end

	local success, value = pcall(func, ...)
	return success and RestrictedValue:Boolean(value) or false
end

local function CallNumber(func, ...)
	if type(func) ~= "function" then
		return nil
	end

	local success, value = pcall(func, ...)
	return success and RestrictedValue:Number(value) or nil
end

local function CallString(func, ...)
	if type(func) ~= "function" then
		return nil
	end

	local success, value = pcall(func, ...)
	return success and RestrictedValue:String(value) or nil
end

local function IsAccessibleAuraResult(value)
	if type(value) == "table" then
		return RestrictedValue:Table(value) ~= nil
	end

	return RestrictedValue:Value(value) ~= nil
end

function Units:GetGUID(unit)
	if not IsUnitToken(unit) then
		return nil
	end

	return CallString(UnitGUID, unit)
end

function Units:GetName(unit)
	if not IsUnitToken(unit) then
		return nil
	end

	return CallString(UnitName, unit)
end

function Units:GetClass(unit)
	if not IsUnitToken(unit) or type(UnitClass) ~= "function" then
		return nil
	end

	local success, name, token, id = pcall(UnitClass, unit)
	if not success then
		return nil
	end

	name = RestrictedValue:String(name)
	token = RestrictedValue:String(token)
	id = RestrictedValue:Number(id)
	if not name or not token then
		return nil
	end

	return {
		name = name,
		token = token,
		id = id,
	}
end

function Units:Exists(unit)
	return IsUnitToken(unit) and CallBoolean(UnitExists, unit) or false
end

function Units:CanAttack(sourceUnit, targetUnit)
	if not IsUnitToken(sourceUnit) or not IsUnitToken(targetUnit) then
		return false
	end

	return CallBoolean(UnitCanAttack, sourceUnit, targetUnit)
end

function Units:AffectingCombat(unit)
	return IsUnitToken(unit) and CallBoolean(UnitAffectingCombat, unit) or false
end

function Units:GetPower(unit, powerType)
	if not IsUnitToken(unit) or RestrictedValue:Number(powerType) == nil then
		return nil
	end

	return CallNumber(UnitPower, unit, powerType)
end

function Units:GetPowerMax(unit, powerType)
	if not IsUnitToken(unit) or RestrictedValue:Number(powerType) == nil then
		return nil
	end

	return CallNumber(UnitPowerMax, unit, powerType)
end

function Units:GetAttackSpeed(unit)
	if not IsUnitToken(unit) or type(UnitAttackSpeed) ~= "function" then
		return nil
	end

	local success, mainSpeed, offSpeed = pcall(UnitAttackSpeed, unit)
	if not success then
		return nil
	end

	return RestrictedValue:Number(mainSpeed), RestrictedValue:Number(offSpeed)
end

function Units:HasAura(unit, aura, filter)
	if not IsUnitToken(unit) then
		return false
	end

	local auraType = type(aura)
	if auraType ~= "number" and auraType ~= "string" then
		return false
	end

	local getter
	if C_UnitAuras then
		if auraType == "number" then
			getter = C_UnitAuras.GetAuraDataBySpellID
		else
			getter = C_UnitAuras.GetAuraDataBySpellName
		end
	end

	if type(getter) == "function" then
		local success, auraData = pcall(getter, unit, aura, filter)
		return success and RestrictedValue:Table(auraData) ~= nil
	end
	if AuraUtil then
		local auraGetter = auraType == "number" and AuraUtil.FindAuraBySpellID
			or AuraUtil.FindAuraByName
		if type(auraGetter) == "function" then
			local success, auraData = pcall(auraGetter, aura, unit, filter)
			if success and IsAccessibleAuraResult(auraData) then
				return true
			end
		end
	end
	if type(UnitBuff) == "function" and filter ~= "HARMFUL" then
		local success, auraData = pcall(UnitBuff, unit, aura)
		if success and IsAccessibleAuraResult(auraData) then
			return true
		end
	end
	if type(UnitAura) == "function" then
		local success, auraData = pcall(UnitAura, unit, aura, filter or "HELPFUL")
		if success and IsAccessibleAuraResult(auraData) then
			return true
		end
	end

	return false
end

MikSBT.API.Units = Units

return Units
