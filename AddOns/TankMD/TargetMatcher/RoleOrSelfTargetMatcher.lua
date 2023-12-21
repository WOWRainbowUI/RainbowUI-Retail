local _, addon = ...
local RoleOrSelfTargetMatcherPrototype = setmetatable({}, addon.RoleTargetMatcherPrototype)
addon.RoleOrSelfTargetMatcherPrototype = RoleOrSelfTargetMatcherPrototype
RoleOrSelfTargetMatcherPrototype.__index = RoleOrSelfTargetMatcherPrototype

function addon:CreateRoleOrSelfTargetMatcher(role)
	local targetMatcher = setmetatable({}, RoleOrSelfTargetMatcherPrototype)
	targetMatcher.role = role
	return targetMatcher
end

function RoleOrSelfTargetMatcherPrototype:FindTargets()
	local targets = addon.RoleTargetMatcherPrototype.FindTargets(self)
	if #targets == 0 then
		return {"player"}
	end
	return targets
end
