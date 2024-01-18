local _, addon = ...
addon.buttons = {}

-- Queue updates for all buttons
function addon:QueueUpdate()
	for _, misdirect in pairs(self.buttons) do
		misdirect.updateQueued = true
	end
end

-- Update target for all buttons
function addon:Update()
	if InCombatLockdown() then return end

	for _, misdirect in pairs(self.buttons) do
		if misdirect.updateQueued then
			misdirect:UpdateTarget()
			misdirect.updateQueued = false
		end
	end
end

function addon:CreateButtons()
	if #self.buttons > 0 then return end

	local _, class = UnitClass("player")
	local spell = self.config.misdirectSpells[class]
	local role = self.config.targets[class]

	local targetMatcher
	if class == "HUNTER" then
		targetMatcher = addon:CreateRoleOrPetTargetMatcher(role)
	elseif class == "EVOKER" then
		targetMatcher = addon:CreateRoleOrSelfTargetMatcher(role)
	else
		targetMatcher = addon:CreateRoleTargetMatcher(role)
	end

	for i, buttonName in pairs(self.config.misdirectButtons) do
		local button = self:CreateMisdirectButton(buttonName, spell, i, targetMatcher)
		tinsert(self.buttons, button)
		-- Backwards compatibility with old naming
		local compatibilityName = "MisdirectTankButton"
		if i > 2 then
			compatibilityName = string.format("MisdirectTank%dButton", i)
		end
		local compatibilityButton = self:CreateMisdirectButton(compatibilityName, spell, i, targetMatcher)
		tinsert(self.buttons, compatibilityButton)
	end
end
