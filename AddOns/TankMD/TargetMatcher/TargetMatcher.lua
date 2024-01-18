local _, addon = ...

local TargetMatcherPrototype = {}
addon.TargetMatcherPrototype = TargetMatcherPrototype
TargetMatcherPrototype.__index = TargetMatcherPrototype
TargetMatcherPrototype.raidUnits = {
	"raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9", "raid10",
	"raid11", "raid12", "raid13", "raid14", "raid15", "raid16", "raid17", "raid18", "raid19", "raid20",
	"raid21", "raid22", "raid23", "raid24", "raid25", "raid26", "raid27", "raid28", "raid29", "raid30",
	"raid31", "raid32", "raid33", "raid34", "raid35", "raid36", "raid37", "raid38", "raid39", "raid40"
}
TargetMatcherPrototype.partyUnits = {"player", "party1", "party2", "party3", "party4"}


function TargetMatcherPrototype:FindTargets()
	local groupMembers = self:GetSortedGroupMembers()
	local targets = {}
	for _, unit in ipairs(groupMembers) do
		if self:Matches(unit) then
			targets[#targets+1] = unit
		end
	end
	return targets
end

-- Override this method
function TargetMatcherPrototype:Matches(unit)
	return false
end

function TargetMatcherPrototype:GetSortedGroupMembers()
	local groupMembers = {}
	local units = IsInRaid() and self.raidUnits or self.partyUnits
	for i = 1, GetNumGroupMembers() do
		local unit = units[i]
		local name = UnitName(unit)
		groupMembers[i] = name
	end

	table.sort(groupMembers)

	return groupMembers
end
