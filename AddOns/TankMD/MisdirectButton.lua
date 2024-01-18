local _, addon = ...

local MisdirectButtonPrototype = {}
MisdirectButtonPrototype.__index = MisdirectButtonPrototype

-- @string buttonName Global button that is created
-- @number spell spell id
-- @number index Match index to target
-- @param targetMatcher TargetMatcher that will provide a table of units
function addon:CreateMisdirectButton(buttonName, spell, index, targetMatcher)
	local misdirectButton = {}
	setmetatable(misdirectButton, MisdirectButtonPrototype)
	misdirectButton.index = index
	misdirectButton.targetMatcher = targetMatcher

	local button = CreateFrame("Button", buttonName, UIParent, "SecureActionButtonTemplate")
	button:Hide()
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", spell)
	button:SetAttribute("checkselfcast", false)
	button:SetAttribute("checkfocuscast", false)
	button:SetAttribute("allowVehicleTarget", false)
	button:RegisterForClicks("LeftButtonDown", "LeftButtonUp")

	misdirectButton.button = button

	return misdirectButton
end

function MisdirectButtonPrototype:UpdateTarget()
	local target = self:FindTarget()
	if target then
		self:SetEnabled(true)
		self.button:SetAttribute("unit", target)
	else
		self:SetEnabled(false)
	end
end

function MisdirectButtonPrototype:FindTarget()
	return self.targetMatcher:FindTargets()[self.index]
end

function MisdirectButtonPrototype:SetEnabled(enabled)
	if enabled then
		self.button:SetAttribute("type", "spell")
	else
		self.button:SetAttribute("type", nil)
	end
end
