
local module = {}
local moduleName = "Triggers"
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local MSBTParser = MikSBT.Parser

local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format
local string_gmatch = string.gmatch
local FormatLargeNumber = FormatLargeNumber

local EraseTable = MikSBT.EraseTable
local GetSpellCooldown = MikSBT.GetSpellCooldown
local GetSpellInfo = MikSBT.GetSpellInfo
local HasAura = MikSBT.HasAura
local GetComboPoints = MikSBT.GetComboPoints
local IsRestrictedContext = MikSBT.IsRestrictedContext
local Print = MikSBT.Print
local ShortenNumber = MikSBT.ShortenNumber
local DisplayEvent = MikSBT.Animations.DisplayEvent
local TestFlagsAny = MSBTParser.TestFlagsAny

local REACTION_HOSTILE = MSBTParser.REACTION_HOSTILE

local FLAG_YOU = 0xF0000000


local _

local cleuTriggerDisableNoticeShown

local playerClass


-- Retired trigger events remain recognizable in saved profiles.
local retiredCombatLogEvents = {
	DAMAGE_SHIELD = true,
	DAMAGE_SHIELD_MISSED = true,
	DAMAGE_SPLIT = true,
	ENCHANT_APPLIED = true,
	ENCHANT_REMOVED = true,
	ENVIRONMENTAL_DAMAGE = true,
	PARTY_KILL = true,
	RANGE_DAMAGE = true,
	RANGE_MISSED = true,
	SPELL_AURA_APPLIED = true,
	SPELL_AURA_APPLIED_DOSE = true,
	SPELL_AURA_BROKEN_SPELL = true,
	SPELL_AURA_REFRESH = true,
	SPELL_AURA_REMOVED = true,
	SPELL_AURA_REMOVED_DOSE = true,
	SPELL_BUILDING_DAMAGE = true,
	SPELL_CAST_FAILED = true,
	SPELL_CAST_START = true,
	SPELL_CAST_SUCCESS = true,
	SPELL_CREATE = true,
	SPELL_DAMAGE = true,
	SPELL_DISPEL = true,
	SPELL_DISPEL_FAILED = true,
	SPELL_DRAIN = true,
	SPELL_ENERGIZE = true,
	SPELL_EXTRA_ATTACKS = true,
	SPELL_HEAL = true,
	SPELL_INTERRUPT = true,
	SPELL_LEECH = true,
	SPELL_MISSED = true,
	SPELL_PERIODIC_DAMAGE = true,
	SPELL_PERIODIC_DRAIN = true,
	SPELL_PERIODIC_ENERGIZE = true,
	SPELL_PERIODIC_HEAL = true,
	SPELL_PERIODIC_LEECH = true,
	SPELL_PERIODIC_MISSED = true,
	SPELL_STOLEN = true,
	SPELL_SUMMON = true,
	SWING_DAMAGE = true,
	SWING_MISSED = true,
	UNIT_DESTROYED = true,
	UNIT_DIED = true,
}

local testFuncs
local eventConditionFuncs
local exceptionConditionFuncs

local categorizedTriggers = {}
local triggerExceptions = {}

local firedTimes = {}


local powerTypes = {}

local triggerRestrictionNotified

local function IsCLEUTriggerMainEvent(mainEvent)
	if mainEvent == "GENERIC_MISSED" or mainEvent == "GENERIC_DAMAGE" then
		return true
	end
	if mainEvent == "SPELL_AURA_APPLIED" or mainEvent == "SPELL_AURA_REMOVED" then
		return true
	end
	if retiredCombatLogEvents[mainEvent] then
		return true
	end
	return false
end

local function IsSkillUnavailable(skillName)
	if not skillName or skillName == "" then
		return true
	end

	if not GetSpellInfo(skillName) then
		return true
	end

	local start, duration = GetSpellCooldown(skillName)
	if type(start) == "number" and type(duration) == "number" and start > 0 and duration > 1.5 then
		return true
	end
end

local function IsTriggerDataRestricted()
	local restricted = IsRestrictedContext()

	if restricted and not triggerRestrictionNotified then
		triggerRestrictionNotified = true
		Print("Some trigger checks (buff/cooldown conditions) are temporarily disabled by Blizzard restrictions in this combat context.")
	elseif not restricted and triggerRestrictionNotified then
		triggerRestrictionNotified = nil
		Print("Restricted trigger checks have been re-enabled.")
	end

	return restricted
end

local function CreateTestFuncs()
	testFuncs = {
		eq = function(l, r) return l == r end,
		ne = function(l, r) return l ~= r end,
		like = function(l, r) return type(l)=="string" and type(r)=="string" and string_find(l, r) end,
		unlike = function(l, r) return type(l)=="string" and type(r)=="string" and not string_find(l, r) end,
		lt = function(l, r) return type(l)=="number" and type(r)=="number" and l < r end,
		gt = function(l, r) return type(l)=="number" and type(r)=="number" and l > r end,
	}
end

local function CreateConditionFuncs()

	eventConditionFuncs = {

		sourceName = function (f, t, v) return f(t.sourceName, v) end,
		sourceAffiliation = function (f, t, v) if (v == FLAG_YOU) then return f(t.sourceUnit, "player") else return f(TestFlagsAny(t.sourceFlags, v), true) end end,
		sourceReaction = function (f, t, v) return f(TestFlagsAny(t.sourceFlags, v), true) end,
		sourceControl = function (f, t, v) return f(TestFlagsAny(t.sourceFlags, v), true) end,
		sourceUnitType = function (f, t, v) return f(TestFlagsAny(t.sourceFlags, v), true) end,

		recipientName = function (f, t, v) return f(t.recipientName, v) end,
		recipientAffiliation = function (f, t, v) if (v == FLAG_YOU) then return f(t.recipientUnit, "player") else return f(TestFlagsAny(t.recipientFlags, v), true) end end,
		recipientReaction = function (f, t, v) return f(TestFlagsAny(t.recipientFlags, v), true) end,
		recipientControl = function (f, t, v) return f(TestFlagsAny(t.recipientFlags, v), true) end,
		recipientUnitType = function (f, t, v) return f(TestFlagsAny(t.recipientFlags, v), true) end,

		skillID = function (f, t, v) return f(t.skillID, v) end,
		skillName = function (f, t, v) return f(t.skillName, v) end,
		skillSchool = function (f, t, v) return f(t.skillSchool, v) end,

		extraSkillID = function (f, t, v) return f(t.extraSkillID, v) end,
		extraSkillName = function (f, t, v) return f(t.extraSkillName, v) end,
		extraSkillSchool = function (f, t, v) return f(t.extraSkillSchool, v) end,

		amount = function (f, t, v) return f(t.amount, v) end,
		overkillAmount = function (f, t, v) return f(t.overkillAmount, v) end,
		damageType = function (f, t, v) return f(t.damageType, v) end,
		resistAmount = function (f, t, v) return f(t.resistAmount, v) end,
		blockAmount = function (f, t, v) return f(t.blockAmount, v) end,
		absorbAmount = function (f, t, v) return f(t.absorbAmount, v) end,
		isCrit = function (f, t, v) return f(t.isCrit and true or false, v) end,
		isGlancing = function (f, t, v) return f(t.isGlancing and true or false, v) end,
		isCrushing = function (f, t, v) return f(t.isCrushing and true or false, v) end,

		missType = function (f, t, v) return f(t.missType, v) end,

		hazardType = function (f, t, v) return f(t.hazardType, v) end,

		powerType = function (f, t, v) return f(t.powerType, v) end,
		extraAmount = function (f, t, v) return f(t.extraAmount, v) end,

		auraType = function (f, t, v) return f(t.auraType, v) end,

	}

	exceptionConditionFuncs = {
		activeTalents = function (f, t, v) return f(GetActiveSpecGroup(), v) end,
		buffActive = function (f, t, v) if IsTriggerDataRestricted() then return false end return HasAura("player", v, "HELPFUL") and true or false end,
		buffInactive = function (f, t, v) if IsTriggerDataRestricted() then return false end return not HasAura("player", v, "HELPFUL") and true or false end,
		currentCP = function (f, t, v) return f(GetComboPoints(), v) end,
		inCombat = function (f, t, v) return f(UnitAffectingCombat("player") == true and true or false, v) end,
		recentlyFired = function (f, t, v) return f(GetTime() - firedTimes[t], v) end,
		trivialTarget = function (f, t, v) return f(UnitIsTrivial("target") == true and true or false, v) end,
		unavailableSkill = function (f, t, v) if IsTriggerDataRestricted() then return false end return IsSkillUnavailable(v) and true or false end,
		warriorStance = function (f, t, v) if (playerClass == "WARRIOR") then return f(GetShapeshiftForm(), v) end end,
		zoneName = function (f, t, v) return f(GetZoneText(), v) end,
		zoneType = function (f, t, v) local _, zoneType = IsInInstance() return f(zoneType, v) end,
	}
end

local function ConvertType(value)
	if type(value) == "string" then
		if value == "true" then
			return true
		end
		if value == "false" then
			return false
		end
		if tonumber(value) then
			return tonumber(value)
		end
		if value == "nil" then
			return nil
		end
	end

	return value
end

local function CategorizeTrigger(triggerSettings)

	if triggerSettings.disabled then
		return
	end
	if triggerSettings.classes and not string_find(triggerSettings.classes, playerClass, nil, 1) then
		return
	end
	if not triggerSettings.mainEvents then
		return
	end

	local eventConditions, conditions
	for mainEvent, conditionsString in string_gmatch(triggerSettings.mainEvents .. "&&", "(.-)%{(.-)%}&&") do
		-- Preserve saved threshold definitions without activating them.
		if mainEvent == "UNIT_HEALTH" or mainEvent == "UNIT_POWER_UPDATE" then
			return
		end
		if IsCLEUTriggerMainEvent(mainEvent) then
			if not cleuTriggerDisableNoticeShown then
				-- Print("CLEU-based triggers are disabled.")
				cleuTriggerDisableNoticeShown = true
			end
		else

			conditions = { triggerSettings = triggerSettings }
			if conditionsString and conditionsString ~= "" then
				for conditionEntry in string_gmatch(conditionsString .. ";;", "(.-);;") do
					conditions[#conditions + 1] = ConvertType(conditionEntry)
				end
			end

			if not categorizedTriggers[mainEvent] then
				categorizedTriggers[mainEvent] = {}
			end
			eventConditions = categorizedTriggers[mainEvent]

			eventConditions[#eventConditions + 1] = conditions

		end
	end

	if not triggerSettings.exceptions or triggerSettings.exceptions == "" then
		return
	end

	local exceptionConditions = {}
	for exceptionValue in string_gmatch(triggerSettings.exceptions .. ";;", "(.-);;") do
		exceptionConditions[#exceptionConditions + 1] = ConvertType(exceptionValue)
	end

	for x = 1, #exceptionConditions, 3 do
		if exceptionConditions[x] == "recentlyFired" then
			firedTimes[triggerSettings] = 0
		end
	end

	triggerExceptions[triggerSettings] = exceptionConditions
end

local function UpdateTriggers()

	for mainEvent in pairs(categorizedTriggers) do
		EraseTable(categorizedTriggers[mainEvent])
	end

	EraseTable(triggerExceptions)
	EraseTable(firedTimes)

	local currentProfileTriggers = rawget(MSBTProfiles.currentProfile, "triggers")
	if currentProfileTriggers then
		for triggerKey, triggerSettings in pairs(currentProfileTriggers) do
			if triggerSettings then
				CategorizeTrigger(triggerSettings)
			end
		end
	end

	for triggerKey, triggerSettings in pairs(MSBTProfiles.masterProfile.triggers) do
		if not currentProfileTriggers or rawget(currentProfileTriggers, triggerKey) == nil then
			CategorizeTrigger(triggerSettings)
		end
	end

end

local function DisplayTrigger(triggerSettings, sourceName, sourceClass, recipientName, recipientClass, skillName, extraSkillName, amount, effectTexture)

	local currentProfile = MSBTProfiles.currentProfile

	local message = triggerSettings.message
	local iconSkill = triggerSettings.iconSkill

	if sourceName and string_find(message, "%n", 1, true) then

		if string_find(sourceName, "-", 1, true) then
			sourceName = string_gsub(sourceName, "(.-)%-.*", "%1")
		end

		if sourceClass and not currentProfile.classColoringDisabled then
			local classSettings = currentProfile[sourceClass]
			if classSettings and not classSettings.disabled then
				sourceName = string_format("|cFF%02x%02x%02x%s|r", classSettings.colorR * 255, classSettings.colorG * 255, classSettings.colorB * 255, sourceName)
			end
		end

		message = string_gsub(message, "%%n", sourceName)
	end

	if recipientName and string_find(message, "%r", 1, true) then

		if string_find(recipientName, "-", 1, true) then
			recipientName = string_gsub(recipientName, "(.-)%-.*", "%1")
		end

		if recipientClass and not currentProfile.classColoringDisabled then
			local classSettings = currentProfile[recipientClass]
			if classSettings and not classSettings.disabled then
				recipientName = string_format("|cFF%02x%02x%02x%s|r", classSettings.colorR * 255, classSettings.colorG * 255, classSettings.colorB * 255, recipientName)
			end
		end

		message = string_gsub(message, "%%r", recipientName)
	end

	if skillName and string_find(message, "%s", 1, true) then
		message = string_gsub(message, "%%s", skillName)
	end

	if extraSkillName and string_find(message, "%e", 1, true) then
		message = string_gsub(message, "%%e", extraSkillName)
	end

	if amount and string_find(message, "%a", 1, true) then

		local formattedAmount = amount
		if currentProfile.shortenNumbers then
			formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
		elseif currentProfile.groupNumbers then
			formattedAmount = FormatLargeNumber(formattedAmount)
		end
		message = string_gsub(message, "%%a", formattedAmount)
	end

	if iconSkill then
		if skillName and string_find(iconSkill, "%s", 1, true) then
			iconSkill = string_gsub(iconSkill, "%%s", skillName)
		end
		if extraSkillName and string_find(iconSkill, "%e", 1, true) then
			iconSkill = string_gsub(iconSkill, "%%e", extraSkillName)
		end
		_, _, effectTexture = GetSpellInfo(iconSkill)
	end

	DisplayEvent(triggerSettings, message, effectTexture, true)
end

-- Kept for the profile/runtime facade; legacy trigger events are retired.
local function Enable() end
local function Disable() end

_, playerClass = UnitClass("player")


CreateTestFuncs()
CreateConditionFuncs()

powerTypes["MANA"] = Enum.PowerType.Mana
powerTypes["RAGE"] = Enum.PowerType.Rage
powerTypes["FOCUS"] = Enum.PowerType.Focus
powerTypes["ENERGY"] = Enum.PowerType.Energy
powerTypes["COMBO_POINTS"] = Enum.PowerType.ComboPoints
powerTypes["RUNES"] = Enum.PowerType.Runes
powerTypes["RUNIC_POWER"] = Enum.PowerType.RunicPower
powerTypes["SOUL_SHARDS"] = Enum.PowerType.SoulShards
powerTypes["LUNAR_POWER"] = Enum.PowerType.LunarPower
powerTypes["HOLY_POWER"] = Enum.PowerType.HolyPower
powerTypes["ALTERNATE_POWER"] = Enum.PowerType.Alternate
powerTypes["MAELSTROM"] = Enum.PowerType.Maelstrom
powerTypes["CHI"] = Enum.PowerType.Chi
powerTypes["INSANITY"] = Enum.PowerType.Insanity
powerTypes["ARCANE_CHARGES"] = Enum.PowerType.ArcaneCharges
powerTypes["FURY"] = Enum.PowerType.Fury
powerTypes["PAIN"] = Enum.PowerType.Pain
powerTypes["ESSENCE"] = Enum.PowerType.Essence

module.categorizedTriggers		= categorizedTriggers
module.powerTypes				= powerTypes

module.ConvertType				= ConvertType
module.UpdateTriggers			= UpdateTriggers
module.Enable					= Enable
module.Disable					= Disable
module.IsCLEUTriggerMainEvent	= IsCLEUTriggerMainEvent

