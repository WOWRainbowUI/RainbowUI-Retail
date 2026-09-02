local RestrictedValue = MikSBT.API.RestrictedValue
local BlizzardCombatText = {}

local CVARS = {
	"floatingCombatTextCombatHealing",
	"floatingCombatTextCombatDamage",
	"floatingCombatTextCombatHealing_v2",
	"floatingCombatTextCombatDamage_v2",
	"floatingCombatTextCombatLogPeriodicSpells_v2",
	"floatingCombatTextPetMeleeDamage_v2",
	"floatingCombatTextPetSpellDamage_v2",
}

local function CanWriteCVars()
	if type(InCombatLockdown) ~= "function" then
		return true
	end

	local success, inCombat = pcall(InCombatLockdown)
	if not success then
		return false
	end

	inCombat = RestrictedValue:Boolean(inCombat)
	return inCombat == false
end

local function SetCVarValue(name, value)
	if C_CVar and type(C_CVar.SetCVar) == "function" then
		local success, result = pcall(C_CVar.SetCVar, name, value)
		return success and result == true
	end

	if type(SetCVar) == "function" then
		local success, result = pcall(SetCVar, name, value)
		return success and result ~= false
	end

	return false
end

function BlizzardCombatText:SetEnabled(isEnabled)
	if type(isEnabled) ~= "boolean" or not CanWriteCVars() then
		return false
	end

	local value = isEnabled and 1 or 0
	local allSucceeded = true
	for _, cvar in ipairs(CVARS) do
		if not SetCVarValue(cvar, value) then
			allSucceeded = false
		end
	end

	return allSucceeded
end

MikSBT.API.BlizzardCombatText = BlizzardCombatText

return BlizzardCombatText
