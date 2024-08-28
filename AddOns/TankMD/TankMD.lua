---@type string
local addonName = ...
---@class AddonNamespace
local addon = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("TankMD")

---@class TankMD: AceAddon, AceEvent-3.0, AceConsole-3.0
local TankMD = AceAddon:NewAddon("TankMD", "AceEvent-3.0", "AceConsole-3.0")
---@type MisdirectButton[]
TankMD.buttons = {}
TankMD.isUpdateQueued = false


function TankMD:OnInitialize()
	addon.db = AceDB:New("TankMDDB", addon.defaultProfile)

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "QueueButtonTargetUpdate")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", "QueueButtonTargetUpdate")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "QueueButtonTargetUpdate")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ProcessQueuedButtonTargetUpdate")
end

function TankMD:OnEnable()
	self:CreateMisdirectButtons()
	self:RegisterChatCommand("tankmd", "SlashCommand")

	AceConfig:RegisterOptionsTable(addonName, addon.optionsTable)
	AceConfigDialog:AddToBlizOptions(addonName, L.title)

	local profiles = AceDBOptions:GetOptionsTable(addon.db)
	AceConfig:RegisterOptionsTable(addonName .. "_Profiles", profiles)
	AceConfigDialog:AddToBlizOptions(addonName .. "_Profiles", L.profiles, L.title)
end

function TankMD:SlashCommand(args)
	if args == "debug" then
		for i, button in ipairs(self.buttons) do
			self:Printf(
				"Button %d: %s (%s)",
				i,
				button:GetTarget() or "no target",
				button:IsEnabled() and "enabled" or "disabled"
			)
		end
	else
		for i, button in ipairs(self.buttons) do
			if button:IsEnabled() and button:GetTarget() then
				self:Printf(
					L.button_target,
					i,
					button:GetTarget()
				)
			end
		end
	end
end

function TankMD:QueueButtonTargetUpdate()
	self.isUpdateQueued = true
	self:ProcessQueuedButtonTargetUpdate()
end

function TankMD:ProcessQueuedButtonTargetUpdate()
	if not self.isUpdateQueued or InCombatLockdown() then return end
	self.isUpdateQueued = false

	local targets = self:GetTargets()
	for i, button in ipairs(self.buttons) do
		button:SetTarget(targets[i])
	end
end

function TankMD:CreateMisdirectButtons()
	if #self.buttons > 0 then return end -- only run once

	local _, class = UnitClass("player")
	local spell = self:GetMisdirectSpellID(class)

	for i = 1, 5 do
		local button = addon:CreateMisdirectButton(spell, i)
		self.buttons[i] = button
	end
	self:QueueButtonTargetUpdate()
end

do
	local misdirectSpells = {
		["HUNTER"] = 34477,
		["ROGUE"] = 57934,
		["DRUID"] = 29166,
		["EVOKER"] = 360827,
		["PALADIN"] = 1044,
	}

	---@param class string
	---@return integer spellID Spell id for the class's misdirect. Defaults to Misdirection if the class does not have a misdirect.
	function TankMD:GetMisdirectSpellID(class)
		return misdirectSpells[class] or misdirectSpells["HUNTER"]
	end
end

do
	-- What role to target with the ability
	local targets = {
		["HUNTER"] = "TANK",
		["ROGUE"] = "TANK",
		["DRUID"] = "HEALER",
		["EVOKER"] = "TANK",
		["PALADIN"] = "TANK",
	}

	---@param class string
	---@return "TANK"|"HEALER" role Target role for the class's misdirect. Defaults to TANK if the class does not have a misdirect.
	function TankMD:GetMisdirectTargetRole(class)
		return targets[class] or "TANK"
	end
end

---@return string[]
function TankMD:GetTargets()
	local _, class = UnitClass("player")
	local createSelector = addon.ClassTargetSelectors[class]
	local selector = createSelector and createSelector() or addon.TargetSelector.Chain({})
	return addon.TargetSelector.Evaluate(selector)
end
