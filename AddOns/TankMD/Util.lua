---@class AddonNamespace
local addon = select(2, ...)

local Util = {}
addon.Util = Util

local raidUnits = {
	"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
	"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
	"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
	"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40"
}
local partyUnits = { "player", "party1", "party2", "party3", "party4" }


---@return fun(): string|nil
function Util.IterateGroupMemberNames()
	return coroutine.wrap(function()
		local units = IsInRaid() and raidUnits or partyUnits
		for _, unit in ipairs(units) do
			local name = UnitName(unit)
			if name and name ~= UNKNOWNOBJECT then
				coroutine.yield(name)
			end
		end
	end)
end

---@generic T
---@param t T[]
---@return fun(): T|nil
function Util.IterateTable(t)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

---@generic T
---@param value T
---@return fun(): T|nil
function Util.IterateSingleValue(value)
	local done = false
	return function()
		if not done then
			done = true
			return value
		end
	end
end
