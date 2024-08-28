---@class AddonNamespace
local addon = select(2, ...)

local TargetSelectionFilter = {}
addon.TargetSelectionFilter = TargetSelectionFilter

---@alias TargetSelectionFilter fun(unit: string): boolean

---@param filters (TargetSelectionFilter)[]
---@return TargetSelectionFilter
function TargetSelectionFilter.Any(filters)
	return function(unit)
		if #filters == 0 then return true end
		for _, filter in ipairs(filters) do
			if filter(unit) then
				return true
			end
		end
		return false
	end
end

---@param filters (TargetSelectionFilter)[]
---@return TargetSelectionFilter
function TargetSelectionFilter.All(filters)
	return function(unit)
		for _, filter in ipairs(filters) do
			if not filter(unit) then
				return false
			end
		end
		return true
	end
end

---@param targetRole "TANK"|"HEALER"|"DAMAGER"
---@return TargetSelectionFilter
function TargetSelectionFilter.Role(targetRole)
	return function(unit)
		local role = UnitGroupRolesAssigned(unit)
		if role ~= "NONE" then
			return targetRole == role
		end
		return false
	end
end

---@return TargetSelectionFilter
function TargetSelectionFilter.MainTank()
	return function(unit)
		local isMainTank = GetPartyAssignment("MAINTANK", unit, true)
		return isMainTank
	end
end
