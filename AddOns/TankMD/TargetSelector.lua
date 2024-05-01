---@class AddonNamespace
local addon = select(2, ...)

local TargetSelector = {}
addon.TargetSelector = TargetSelector

---@alias TargetSelector (fun(): string|nil)

---@param selector TargetSelector
---@return string[]
function TargetSelector.Evaluate(selector)
	local seen = {}
	local targets = {}
	for target in selector do
		-- Split uniqueness checking out into TargetSelector.Unique if there is ever a reason to not always be unique
		if not seen[target] then
			seen[target] = true
			targets[#targets + 1] = target
		end
	end
	return targets
end

---@param selectors TargetSelector[]
---@return TargetSelector
function TargetSelector.Chain(selectors)
	return coroutine.wrap(function()
		for _, selector in ipairs(selectors) do
			for target in selector do
				coroutine.yield(target)
			end
		end
	end)
end

---@param selector TargetSelector
---@return TargetSelector
function TargetSelector.Sort(selector)
	local targets = TargetSelector.Evaluate(selector)
	table.sort(targets)
	return addon.Util.IterateTable(targets)
end

---@param filter TargetSelectionFilter
---@return TargetSelector
function TargetSelector.PartyOrRaid(filter)
	return coroutine.wrap(function()
		for name in addon.Util.IterateGroupMemberNames() do
			if filter(name) then
				coroutine.yield(name)
			end
		end
	end)
end

---@return TargetSelector
function TargetSelector.Player()
	return addon.Util.IterateSingleValue("player")
end

---@return TargetSelector
function TargetSelector.Pet()
	return addon.Util.IterateSingleValue("pet")
end

---@return TargetSelector
function TargetSelector.Focus()
	-- This should not allow the selection of pets, since pets can have duplicate names,
	-- but we want to refer to a specific unit even if unit ids shift around.
	local focusGUID = UnitGUID("focus")
	if focusGUID and IsGUIDInGroup(focusGUID) then
		local name = UnitName("focus")
		return addon.Util.IterateSingleValue(name)
	else
		return function() end
	end
end
