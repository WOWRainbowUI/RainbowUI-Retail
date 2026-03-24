
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

local classMap = MSBTParser.classMap
local REACTION_HOSTILE = MSBTParser.REACTION_HOSTILE
local unitMap = MSBTParser.unitMap

local FLAG_YOU = 0xF0000000

local MAX_PARTY_MEMBERS = 5
local MAX_RAID_MEMBERS = 40

local _

local eventFrame
local isEnabled
local eventsRegistered
local triggersDisabledNoticeShown
local cleuTriggerDisableNoticeShown

local playerName, playerGUID, playerClass

local listenEvents = {}

local captureFuncs
local testFuncs
local eventConditionFuncs
local exceptionConditionFuncs

local categorizedTriggers = {}
local triggerExceptions = {}
local parserEvent = {}
local lookupTable = {}

local lastPercentages = {}
local lastPowerTypes = {}
local firedTimes = {}
local triggersToFire = {}

local triggerSuppressions = {}

local powerTypes = {}

local triggerRestrictionNotified

local function IsCLEUTriggerMainEvent(mainEvent)
	if mainEvent == "GENERIC_MISSED" or mainEvent == "GENERIC_DAMAGE" then
		return true
	end
	if mainEvent == "SPELL_AURA_APPLIED" or mainEvent == "SPELL_AURA_REMOVED" then
		return true
	end
	if captureFuncs and captureFuncs[mainEvent] then
		return true
	end
	return false
end

local function TriggerUsesCLEUMainEvents(mainEvents)
	if not mainEvents or mainEvents == "" then
		return false
	end
	for mainEvent in string_gmatch(mainEvents .. "&&", "(.-)%{.-%}&&") do
		if IsCLEUTriggerMainEvent(mainEvent) then
			return true
		end
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

local function NormalizeNumber(value)
	local ok, result = pcall(function()
		return value + 0
	end)
	if ok and type(result) == "number" then
		return result
	end
	return nil
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

local function CreateCaptureFuncs()
	captureFuncs = {

		SPELL_AURA_BROKEN_SPELL = function (p, ...) p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool, p.auraType = ... end,
		SPELL_AURA_REFRESH = function (p, ...) p.skillID, p.skillName, p.skillSchool, p.auraType = ... end,
		SPELL_CAST_SUCCESS = function (p, ...) p.skillID, p.skillName, p.skillSchool = ... end,
		SPELL_CAST_FAILED = function (p, ...) p.skillID, p.skillName, p.skillSchool, p.missType = ... end,
		SPELL_SUMMON = function (p, ...) p.skillID, p.skillName, p.skillSchool = ... end,
		SPELL_CREATE = function (p, ...) p.skillID, p.skillName, p.skillSchool = ... end,
		UNIT_DIED = function (p, ...) end,
		UNIT_DESTROYED = function (p, ...) end,
	}

	captureFuncs.__index = MSBTParser.captureFuncs
	setmetatable(captureFuncs, captureFuncs)
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

		threshold = function (f, t, v) if (type(v)=="number") then return f(t.currentPercentage, v/100) and not f(t.lastPercentage, v/100) end end,
		unitID = function (f, t, v) if ((v == "party" and string_find(t.unitID, "party%d+")) or (v == "raid" and (string_find(t.unitID, "raid%d+") or string_find(t.unitID, "party%d+")))) then v = t.unitID end return f(t.unitID, v) end,
		unitReaction = function (f, t, v) if (v == REACTION_HOSTILE) then return f(UnitIsFriend(t.unitID, "player"), false) else return f(UnitIsFriend(t.unitID, "player"), true) end end,
	}

	exceptionConditionFuncs = {
		activeTalents = function (f, t, v) return f(GetActiveSpecGroup(), v) end,
		buffActive = function (f, t, v) if IsTriggerDataRestricted() then return false end return HasAura("player", v, "HELPFUL") and true or false end,
		buffInactive = function (f, t, v) if IsTriggerDataRestricted() then return false end return not HasAura("player", v, "HELPFUL") and true or false end,
		currentCP = function (f, t, v) return f(GetComboPoints(), v) end,
		currentPower = function (f, t, v) return f(UnitPower("player"), v) end,
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
		if IsCLEUTriggerMainEvent(mainEvent) then
			if not cleuTriggerDisableNoticeShown then
				Print("CLEU-based triggers are disabled.")
				cleuTriggerDisableNoticeShown = true
			end
		else

		conditions = { triggerSettings = triggerSettings }
		if conditionsString and conditionsString ~= "" then
			for conditionEntry in string_gmatch(conditionsString .. ";;", "(.-);;") do
				conditions[#conditions + 1] = ConvertType(conditionEntry)
			end
		end

		if mainEvent == "GENERIC_MISSED" then
			listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

			if not categorizedTriggers["SWING_MISSED"] then
				categorizedTriggers["SWING_MISSED"] = {}
			end
			if not categorizedTriggers["RANGE_MISSED"] then
				categorizedTriggers["RANGE_MISSED"] = {}
			end
			if not categorizedTriggers["SPELL_MISSED"] then
				categorizedTriggers["SPELL_MISSED"] = {}
			end

			categorizedTriggers["SWING_MISSED"][#categorizedTriggers["SWING_MISSED"] + 1] = conditions
			categorizedTriggers["RANGE_MISSED"][#categorizedTriggers["RANGE_MISSED"] + 1] = conditions
			categorizedTriggers["SPELL_MISSED"][#categorizedTriggers["SPELL_MISSED"] + 1] = conditions

		elseif mainEvent == "GENERIC_DAMAGE" then
			listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

			if not categorizedTriggers["SWING_DAMAGE"] then
				categorizedTriggers["SWING_DAMAGE"] = {}
			end
			if not categorizedTriggers["RANGE_DAMAGE"] then
				categorizedTriggers["RANGE_DAMAGE"] = {}
			end
			if not categorizedTriggers["SPELL_DAMAGE"] then
				categorizedTriggers["SPELL_DAMAGE"] = {}
			end

			categorizedTriggers["SWING_DAMAGE"][#categorizedTriggers["SWING_DAMAGE"] + 1] = conditions
			categorizedTriggers["RANGE_DAMAGE"][#categorizedTriggers["RANGE_DAMAGE"] + 1] = conditions
			categorizedTriggers["SPELL_DAMAGE"][#categorizedTriggers["SPELL_DAMAGE"] + 1] = conditions

		elseif mainEvent == "SPELL_AURA_APPLIED" then
			listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

			if not categorizedTriggers["SPELL_AURA_APPLIED"] then
				categorizedTriggers["SPELL_AURA_APPLIED"] = {}
			end
			if not categorizedTriggers["SPELL_AURA_APPLIED_DOSE"]then
				categorizedTriggers["SPELL_AURA_APPLIED_DOSE"] = {}
			 end

			categorizedTriggers["SPELL_AURA_APPLIED"][#categorizedTriggers["SPELL_AURA_APPLIED"] + 1] = conditions
			categorizedTriggers["SPELL_AURA_APPLIED_DOSE"][#categorizedTriggers["SPELL_AURA_APPLIED_DOSE"] + 1] = conditions

			local skillName, recipientAffiliation
			for x = 1, #conditions, 3 do
				if conditions[x] == "skillName" and conditions[x + 1] == "eq" and conditions[x + 2] then
					skillName = conditions[x + 2]
				end
				if conditions[x] == "recipientAffiliation" and conditions[x + 1] == "eq" and conditions[x + 2] == FLAG_YOU then
					recipientAffiliation = FLAG_YOU
				end
				if conditions[x] == "skillID" and conditions[x + 1] == "eq" and conditions[x + 2] then
					skillName = GetSpellInfo(conditions[x + 2]) or UNKNOWN
				end
			end

				if skillName and recipientAffiliation then
					triggerSuppressions[skillName] = true
				end

		elseif mainEvent == "SPELL_AURA_REMOVED" then
			listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

			if not categorizedTriggers["SPELL_AURA_REMOVED"] then
				categorizedTriggers["SPELL_AURA_REMOVED"] = {}
			end
			if not categorizedTriggers["SPELL_AURA_REMOVED_DOSE"] then
				categorizedTriggers["SPELL_AURA_REMOVED_DOSE"] = {}
			end

			categorizedTriggers["SPELL_AURA_REMOVED"][#categorizedTriggers["SPELL_AURA_REMOVED"] + 1] = conditions
			categorizedTriggers["SPELL_AURA_REMOVED_DOSE"][#categorizedTriggers["SPELL_AURA_REMOVED_DOSE"] + 1] = conditions

		else

			if not categorizedTriggers[mainEvent] then
				categorizedTriggers[mainEvent] = {}
			end
			eventConditions = categorizedTriggers[mainEvent]

			if mainEvent == "UNIT_HEALTH" then
				listenEvents[mainEvent] = true
				lastPercentages[mainEvent] = {}

				for x = 1, #conditions, 3 do
					if conditions[x] == "unitID" then

						local conditionValue = conditions[x + 2]
						if conditionValue == "party" then
							for partyMember = 1, MAX_PARTY_MEMBERS do
								local unitID = "party" .. partyMember
								if not eventConditions[unitID] then
									eventConditions[unitID] = {}
								end
								eventConditions[unitID][#eventConditions[unitID] + 1] = conditions
							end

						elseif conditionValue == "raid" then
							for raidMember = 1, MAX_RAID_MEMBERS do
								local unitID = "raid" .. raidMember
								if not eventConditions[unitID] then
									eventConditions[unitID] = {}
								end
								eventConditions[unitID][#eventConditions[unitID] + 1] = conditions
							end

						else
							if not eventConditions[conditionValue] then
								eventConditions[conditionValue] = {}
							end
							eventConditions[conditionValue][#eventConditions[conditionValue] + 1] = conditions
						end
					end
				end

			elseif mainEvent == "UNIT_POWER_UPDATE" then
				listenEvents[mainEvent] = true

				local powerType
				for x = 1, #conditions, 3 do
					if conditions[x] == "powerType" then
						powerType = conditions[x + 2]
						break
					end
				end

				if powerType then
					lastPercentages[powerType] = {}

					for x = 1, #conditions, 3 do
						if conditions[x] == "unitID" then
							if not eventConditions[powerType] then
								eventConditions[powerType] = {}
							end
							local powerConditions = eventConditions[powerType]

							local conditionValue = conditions[x + 2]
							if conditionValue == "party" then
								for partyMember = 1, MAX_PARTY_MEMBERS do
									local unitID = "party" .. partyMember
									if not powerConditions[unitID] then
										powerConditions[unitID] = {}
									end
									powerConditions[unitID][#powerConditions[unitID] + 1] = conditions
								end

							elseif conditionValue == "raid" then
								for raidMember = 1, MAX_RAID_MEMBERS do
									local unitID = "raid" .. raidMember
									if not powerConditions[unitID] then
										powerConditions[unitID] = {}
									end
									powerConditions[unitID][#powerConditions[unitID] + 1] = conditions
								end

							else

								if not powerConditions[conditionValue] then
									powerConditions[conditionValue] = {}
								end
								powerConditions[conditionValue][#powerConditions[conditionValue] + 1] = conditions
							end
						end
					end
				end

			elseif mainEvent == "SKILL_COOLDOWN" then
				eventConditions[#eventConditions + 1] = conditions
				MikSBT.Cooldowns.UpdateRegisteredEvents()

			elseif mainEvent == "PET_COOLDOWN" then
				eventConditions[#eventConditions + 1] = conditions
				MikSBT.Cooldowns.UpdateRegisteredEvents()

			elseif mainEvent == "ITEM_COOLDOWN" then
				eventConditions[#eventConditions + 1] = conditions
				MikSBT.Cooldowns.UpdateRegisteredEvents()

			elseif captureFuncs[mainEvent] then
				listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true
				eventConditions[#eventConditions + 1] = conditions
			end
		end
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
	EraseTable(listenEvents)

	for mainEvent in pairs(categorizedTriggers) do
		EraseTable(categorizedTriggers[mainEvent])
	end

	MikSBT.Cooldowns.UpdateRegisteredEvents()

	EraseTable(triggerExceptions)

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

	DisplayEvent(triggerSettings, message, effectTexture)
end

local function TestExceptions(triggerSettings)

	if not triggerExceptions[triggerSettings] then
		return
	end

	local exceptionConditions = triggerExceptions[triggerSettings]
	for position = 1, #exceptionConditions, 3 do

		local conditionFunc = exceptionConditionFuncs[exceptionConditions[position]]
		local testFunc = testFuncs[exceptionConditions[position + 1]]
		if conditionFunc and testFunc and conditionFunc(testFunc, triggerSettings, exceptionConditions[position + 2]) then
			return true
		end
	end

	if firedTimes[triggerSettings] then
		firedTimes[triggerSettings] = GetTime()
	end
end

local function HandleHealthAndPowerTriggers(unit, event, currentAmount, maxAmount, powerType)

	local eventTriggers = categorizedTriggers[event]
	if powerType and eventTriggers then
		eventTriggers = eventTriggers[powerType]
	end
	if not eventTriggers or not eventTriggers[unit] then
		return
	end

	currentAmount = NormalizeNumber(currentAmount)
	maxAmount = NormalizeNumber(maxAmount)
	if not currentAmount or not maxAmount or maxAmount <= 0 then
		return
	end

	local currentPercentage = currentAmount / maxAmount
	local lastEventPercentages = lastPercentages[powerType or event]
	local lastPercentage = lastEventPercentages[unit]

	if not lastPercentage then
		lastEventPercentages[unit] = currentPercentage
		return
	end
	if UnitIsDeadOrGhost(unit) then
		lastEventPercentages[unit] = nil
		return
	end

	lookupTable.amount = currentAmount
	lookupTable.currentPercentage = currentPercentage
	lookupTable.lastPercentage = lastPercentage
	lookupTable.unitID = unit
	lookupTable.powerType = powerType

	for k in pairs(triggersToFire) do
		triggersToFire[k] = nil
	end

	for _, eventConditions in ipairs(eventTriggers[unit]) do

		local doFire = true

		if not triggersToFire[eventConditions.triggerSettings] then

			for position = 1, #eventConditions, 3 do

				local conditionFunc = eventConditionFuncs[eventConditions[position]]
				local testFunc = testFuncs[eventConditions[position + 1]]
				if conditionFunc and testFunc and not conditionFunc(testFunc, lookupTable, eventConditions[position + 2]) then
					doFire = false
					break
				end
			end

			if doFire then
				triggersToFire[eventConditions.triggerSettings] = true
			end
		end
	end

	if next(triggersToFire) then

		local recipientName = UnitName(unit)
		local _, recipientClass = UnitClass(unit)
		local amount = currentAmount
		for triggerSettings in pairs(triggersToFire) do
			if not TestExceptions(triggerSettings) then
				DisplayTrigger(triggerSettings, nil, nil, recipientName, recipientClass, nil, nil, amount)
			end
		end
	end

	lastEventPercentages[unit] = currentPercentage
end

local function HandleCooldowns(cooldownType, cooldownID, cooldownName, effectTexture)

	local event = "SKILL_COOLDOWN"
	if cooldownType == "pet" then
		event = "PET_COOLDOWN"
	elseif cooldownType == "item" then
		event = "ITEM_COOLDOWN"
	end

	local eventTriggers = categorizedTriggers[event]
	if not eventTriggers then
		return
	end

	if cooldownType == "item" then
		lookupTable.itemID = cooldownID
		lookupTable.itemName = cooldownName
	else
		lookupTable.skillID = cooldownID
		lookupTable.skillName = cooldownName
	end

	for k in pairs(triggersToFire) do
		triggersToFire[k] = nil
	end

	for _, eventConditions in ipairs(eventTriggers) do

		local doFire = true

		if not triggersToFire[eventConditions.triggerSettings] then

			for position = 1, #eventConditions, 3 do

				local conditionFunc = eventConditionFuncs[eventConditions[position]]
				local testFunc = testFuncs[eventConditions[position + 1]]
				if conditionFunc and testFunc and not conditionFunc(testFunc, lookupTable, eventConditions[position + 2]) then
					doFire = false
					break
				end
			end

			if doFire then
				triggersToFire[eventConditions.triggerSettings] = true
			end
		end
	end

	if next(triggersToFire) then

		local recipientName = playerName
		for triggerSettings in pairs(triggersToFire) do
			if not TestExceptions(triggerSettings) then
				DisplayTrigger(triggerSettings, nil, nil, recipientName, playerClass, cooldownName, nil, nil, effectTexture)
			end
		end
	end
end

local function HandleCombatLogTriggers(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName, recipientFlags, recipientRaidFlags, ...)

	if not categorizedTriggers[event] then
		return
	end

	local captureFunc = captureFuncs[event]
	if not captureFunc then
		return
	end

	for k in pairs(parserEvent) do
		parserEvent[k] = nil
	end

	parserEvent.sourceGUID = sourceGUID
	parserEvent.sourceName = sourceName
	parserEvent.sourceFlags = sourceFlags
	parserEvent.recipientGUID = recipientGUID
	parserEvent.recipientName = recipientName
	parserEvent.recipientFlags = recipientFlags
	parserEvent.sourceUnit = unitMap[sourceGUID]
	parserEvent.recipientUnit = unitMap[recipientGUID]

	captureFunc(parserEvent, ...)

	for k in pairs(triggersToFire) do triggersToFire[k] = nil end

	for _, eventConditions in ipairs(categorizedTriggers[event]) do

		local doFire = true

		if not triggersToFire[eventConditions.triggerSettings] then

			for position = 1, #eventConditions, 3 do

				local conditionFunc = eventConditionFuncs[eventConditions[position]]
				local testFunc = testFuncs[eventConditions[position + 1]]
				if conditionFunc and testFunc and not conditionFunc(testFunc, parserEvent, eventConditions[position + 2]) then
					doFire = false
					break
				end
			end

			if doFire then
				triggersToFire[eventConditions.triggerSettings] = true
			end
		end
	end

	if next(triggersToFire) then
		local effectTexture
		if parserEvent.skillID or parserEvent.extraSkillID then
			_, _, effectTexture = GetSpellInfo(parserEvent.extraSkillID or parserEvent.skillID)
		end

		local sourceName = parserEvent.sourceName
		local recipientName = parserEvent.recipientName
		local sourceClass = classMap[sourceGUID]
		local recipientClass = classMap[recipientGUID]
		local skillName = parserEvent.skillName
		local extraSkillName = parserEvent.extraSkillName
		local amount = parserEvent.amount
		for triggerSettings in pairs(triggersToFire) do
			if not TestExceptions(triggerSettings) then
				DisplayTrigger(triggerSettings, sourceName, sourceClass, recipientName, recipientClass, skillName, extraSkillName, amount, effectTexture)
			end
		end
	end
end

local function OnEvent(this, event, arg1, arg2, ...)
	if not isEnabled then
		return
	end

	if event == "UNIT_HEALTH" then

		if not categorizedTriggers[event] or not categorizedTriggers[event][arg1] then
			return
		end
		HandleHealthAndPowerTriggers(arg1, event, UnitHealth(arg1), UnitHealthMax(arg1))

	elseif event == "UNIT_POWER_UPDATE" then

		if not categorizedTriggers[event] then
			return
		end
		local powerType = powerTypes[arg2]
		if not powerType then
			return
		end
		if not categorizedTriggers[event][powerType] or not categorizedTriggers[event][powerType][arg1] then
			return
		end
		HandleHealthAndPowerTriggers(arg1, event, UnitPower(arg1, powerType), UnitPowerMax(arg1, powerType), powerType)

	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		HandleCombatLogTriggers(CombatLogGetCurrentEventInfo())
	end
end

local function SafeRegisterEvent(frame, event) end

local function Enable()
	if not eventsRegistered then
		if not triggersDisabledNoticeShown then
			MikSBT.Print("Trigger event processing is disabled due Blizzard protected event restrictions.")
			triggersDisabledNoticeShown = true
		end
		isEnabled = false
		return
	end
	isEnabled = true
end

local function Disable()
	isEnabled = false
end

playerName = UnitName("player")
playerGUID = UnitGUID("player")
_, playerClass = UnitClass("player")

eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)

CreateCaptureFuncs()
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

module.triggerSuppressions		= triggerSuppressions
module.categorizedTriggers		= categorizedTriggers
module.powerTypes				= powerTypes

module.HandleCooldowns			= HandleCooldowns
module.HandleCombatLogTriggers	= HandleCombatLogTriggers
module.ConvertType				= ConvertType
module.UpdateTriggers			= UpdateTriggers
module.Enable					= Enable
module.Disable					= Disable
module.IsCLEUTriggerMainEvent	= IsCLEUTriggerMainEvent
module.TriggerUsesCLEUMainEvents = TriggerUsesCLEUMainEvents

