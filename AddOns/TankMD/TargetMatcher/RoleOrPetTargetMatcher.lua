local _, addon = ...
local RoleOrPetTargetMatcherPrototype = setmetatable({}, addon.RoleTargetMatcherPrototype)
addon.RoleOrPetTargetMatcherPrototype = RoleOrPetTargetMatcherPrototype
RoleOrPetTargetMatcherPrototype.__index = RoleOrPetTargetMatcherPrototype

function addon:CreateRoleOrPetTargetMatcher(role)
	local targetMatcher = setmetatable({}, RoleOrPetTargetMatcherPrototype)
	targetMatcher.role = role
	return targetMatcher
end

function RoleOrPetTargetMatcherPrototype:FindTargets()
	local targets = addon.RoleTargetMatcherPrototype.FindTargets(self)
	if #targets == 0 then
		return {"pet"}
	end
	return targets
end
