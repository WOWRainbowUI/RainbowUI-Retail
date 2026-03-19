
local module = {}
local moduleName = "Main"
MikSBT[moduleName] = module

local MSBTAnimations = MikSBT.Animations
local MSBTMedia = MikSBT.Media
local MSBTParser = MikSBT.Parser
local MSBTTriggers = MikSBT.Triggers
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

local table_remove = table.remove
local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format
local string_upper = string.upper
local math_abs = math.abs
local math_floor = math.floor
local bit_bor = bit.bor
local FormatLargeNumber = FormatLargeNumber
local GetTime = GetTime

local EraseTable = MikSBT.EraseTable
local GetSkillName = MikSBT.GetSkillName
local GetSpellInfo = MikSBT.GetSpellInfo
local ShortenNumber = MikSBT.ShortenNumber
local DisplayEvent = MSBTAnimations.DisplayEvent
local IsScrollAreaActive = MSBTAnimations.IsScrollAreaActive
local IsScrollAreaIconShown = MSBTAnimations.IsScrollAreaIconShown
local TestFlagsAll = MSBTParser.TestFlagsAll

local triggerSuppressions = MSBTTriggers.triggerSuppressions
local powerTypes = MSBTTriggers.powerTypes
local classMap = MSBTParser.classMap

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local MERGE_DELAY_TIME = 0.3

local THROTTLE_UPDATE_TIME = 0.5

local EMOTE_HOLD_TIME = 1
local ENEMY_BUFF_HOLD_TIME = 5

local DAMAGETYPE_PHYSICAL = 0x1
local DAMAGETYPE_HOLY = 0x2
local DAMAGETYPE_FIRE = 0x4
local DAMAGETYPE_NATURE = 0x8
local DAMAGETYPE_FROST = 0x10
local DAMAGETYPE_SHADOW = 0x20
local DAMAGETYPE_ARCANE = 0x40

local DAMAGETYPE_SPELLSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_ARCANE
local DAMAGETYPE_FLAMESTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FIRE
local DAMAGETYPE_FROSTSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FROST
local DAMAGETYPE_STORMSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_NATURE
local DAMAGETYPE_SHADOWSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_SHADOW
local DAMAGETYPE_HOLYSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY

local DAMAGETYPE_SPELLFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLFROST = DAMAGETYPE_FROST + DAMAGETYPE_ARCANE
local DAMAGETYPE_DIVINE = DAMAGETYPE_HOLY + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSHADOW = DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_HOLYFIRE = DAMAGETYPE_HOLY + DAMAGETYPE_FIRE
local DAMAGETYPE_HOLYSTORM = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE
local DAMAGETYPE_HOLYFROST = DAMAGETYPE_HOLY + DAMAGETYPE_FROST
local DAMAGETYPE_FIRESTORM = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE
local DAMAGETYPE_SHADOWFLAME = DAMAGETYPE_FIRE + DAMAGETYPE_SHADOW
local DAMAGETYPE_FROSTFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_FROST
local DAMAGETYPE_FROSTSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWFROST = DAMAGETYPE_FROST + DAMAGETYPE_SHADOW
local DAMAGETYPE_SHADOWHOLY = DAMAGETYPE_HOLY + DAMAGETYPE_SHADOW
local DAMAGETYPE_SHADOWSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW

local DAMAGETYPE_ELEMENTAL = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_COSMIC = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_CHROMATIC = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_MAGIC = DAMAGETYPE_ARCANE + DAMAGETYPE_FIRE + DAMAGETYPE_FROST + DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW + DAMAGETYPE_HOLY
local DAMAGETYPE_CHAOS = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY + DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE

local SPELLID_AUTOSHOT = 75

local SPELL_BLINK					= GetSkillName(1953)

local SPELL_BLOOD_STRIKE			= WOW_PROJECT_ID < WOW_PROJECT_CLASSIC and GetSkillName(60945)

local SPELL_RAIN_OF_FIRE			= GetSkillName(5740)

local _

local eventFrame = CreateFrame("Frame")
local throttleFrame = CreateFrame("Frame")

local playerClass

local combatEventCache = {}

local eventHandlers = {}
local damageTypeMap = {}
local damageColorProfileEntries = {}
local powerTokens = {}
local uniquePowerTypes = {}

local throttledAbilities = {}

local unmergedEvents = {}
local mergedEvents = {}

local lastMergeUpdate = 0
local lastThrottleUpdate = 0

local isEnglish
local lastPowerAmounts = {}
local finisherShown
local recentEmotes = {}
local recentEnemyBuffs = {}
local ignoreAuras = {}
local playerGUID
local lastPlayerSpellID
local lastPlayerSpellTime = 0
local AUTOSHOT_SPELL_ID = 6603
local OUTGOING_GROUP_DELAY = 0.05
local INCOMING_GROUP_DELAY = 0.12
local OUTGOING_FALLBACK_ATTRIBUTION_WINDOW = 0.9
local OUTGOING_DELAYED_SPELL_ATTRIBUTION_WINDOW = 3.0
local INCOMING_SELF_HEAL_ICON_ATTRIBUTION_WINDOW = 12.0
local DAMAGE_METER_FALLBACK_STALE_TIME = 0.35
local USE_DAMAGE_METER_OUTGOING = true
local DOT_FALLBACK_DURATION = 18
local outgoingBatches = {}
local incomingDamageBatches = {}
local incomingHealBatches = {}
local damageMeterTicker
local damageMeterLastSpellTotals = {}
local lastDamageMeterPoll = 0
local lastDamageMeterDeltaTime = 0
local lastAutoAttackFallbackTime = 0
local lastDotFallbackSpellID
local lastDotFallbackExpire = 0
local lastDotFallbackAuraIDs
local lastDotFallbackRequireAura = true
local DOT_FALLBACK_SPELLS = {
	[8921] = {8921}, -- Moonfire
	[93402] = {93402}, -- Sunfire
	[106830] = {106830, 405233}, -- Thrash (Cat) cast + periodic aura
	[77758] = {77758, 405233}, -- Thrash (Bear) cast + periodic aura
}
local DOT_FALLBACK_TIMED_SPELLS = {
	[202770] = 8, -- Fury of Elune: periodic area damage window
}

local offHandTrailer
local offHandPattern

local function CreateDamageMaps()

	damageTypeMap[DAMAGETYPE_PHYSICAL] = STRING_SCHOOL_PHYSICAL
	damageTypeMap[DAMAGETYPE_HOLY] = STRING_SCHOOL_HOLY
	damageTypeMap[DAMAGETYPE_FIRE] = STRING_SCHOOL_FIRE
	damageTypeMap[DAMAGETYPE_NATURE] = STRING_SCHOOL_NATURE
	damageTypeMap[DAMAGETYPE_FROST] = STRING_SCHOOL_FROST
	damageTypeMap[DAMAGETYPE_SHADOW] = STRING_SCHOOL_SHADOW
	damageTypeMap[DAMAGETYPE_ARCANE] = STRING_SCHOOL_ARCANE
	damageTypeMap[DAMAGETYPE_HOLYSTRIKE] = STRING_SCHOOL_HOLYSTRIKE
	damageTypeMap[DAMAGETYPE_FLAMESTRIKE] = STRING_SCHOOL_FLAMESTRIKE
	damageTypeMap[DAMAGETYPE_STORMSTRIKE] = STRING_SCHOOL_STORMSTRIKE
	damageTypeMap[DAMAGETYPE_SHADOWSTRIKE] = STRING_SCHOOL_SHADOWSTRIKE
	damageTypeMap[DAMAGETYPE_FROSTSTRIKE] = STRING_SCHOOL_FROSTSTRIKE
	damageTypeMap[DAMAGETYPE_SPELLSTRIKE] = STRING_SCHOOL_SPELLSTRIKE
	damageTypeMap[DAMAGETYPE_HOLYFIRE] = STRING_SCHOOL_HOLYFIRE
	damageTypeMap[DAMAGETYPE_SHADOWHOLY] = STRING_SCHOOL_SHADOWHOLY
	damageTypeMap[DAMAGETYPE_DIVINE] = STRING_SCHOOL_DIVINE
	damageTypeMap[DAMAGETYPE_HOLYSTORM] = STRING_SCHOOL_HOLYSTORM
	damageTypeMap[DAMAGETYPE_HOLYFROST] = STRING_SCHOOL_HOLYFROST
	damageTypeMap[DAMAGETYPE_FIRESTORM] = STRING_SCHOOL_FIRESTORM
	damageTypeMap[DAMAGETYPE_FROSTFIRE] = STRING_SCHOOL_FROSTFIRE
	damageTypeMap[DAMAGETYPE_SHADOWFLAME] = STRING_SCHOOL_SHADOWFLAME
	damageTypeMap[DAMAGETYPE_SPELLFIRE] = STRING_SCHOOL_SPELLFIRE
	damageTypeMap[DAMAGETYPE_FROSTSTORM] = STRING_SCHOOL_FROSTSTORM
	damageTypeMap[DAMAGETYPE_SHADOWSTORM] = STRING_SCHOOL_SHADOWSTORM
	damageTypeMap[DAMAGETYPE_SPELLSTORM] = STRING_SCHOOL_SPELLSTORM
	damageTypeMap[DAMAGETYPE_SHADOWFROST] = STRING_SCHOOL_SHADOWFROST
	damageTypeMap[DAMAGETYPE_SPELLFROST] = STRING_SCHOOL_SPELLFROST
	damageTypeMap[DAMAGETYPE_SPELLSHADOW] = STRING_SCHOOL_SPELLSHADOW
	damageTypeMap[DAMAGETYPE_ELEMENTAL] = STRING_SCHOOL_ELEMENTAL
	damageTypeMap[DAMAGETYPE_COSMIC] = STRING_SCHOOL_COSMIC or L.COSMIC
	damageTypeMap[DAMAGETYPE_CHROMATIC] = STRING_SCHOOL_CHROMATIC
	damageTypeMap[DAMAGETYPE_MAGIC] = STRING_SCHOOL_MAGIC
	damageTypeMap[DAMAGETYPE_CHAOS] = STRING_SCHOOL_CHAOS

	damageColorProfileEntries[DAMAGETYPE_PHYSICAL] = "physical"
	damageColorProfileEntries[DAMAGETYPE_HOLY] = "holy"
	damageColorProfileEntries[DAMAGETYPE_FIRE] = "fire"
	damageColorProfileEntries[DAMAGETYPE_NATURE] = "nature"
	damageColorProfileEntries[DAMAGETYPE_FROST] = "frost"
	damageColorProfileEntries[DAMAGETYPE_SHADOW] = "shadow"
	damageColorProfileEntries[DAMAGETYPE_ARCANE] = "arcane"
	damageColorProfileEntries[DAMAGETYPE_HOLYSTRIKE] = "holystrike"
	damageColorProfileEntries[DAMAGETYPE_FLAMESTRIKE] = "flamestrike"
	damageColorProfileEntries[DAMAGETYPE_STORMSTRIKE] = "stormstrike"
	damageColorProfileEntries[DAMAGETYPE_FROSTSTRIKE] = "froststrike"
	damageColorProfileEntries[DAMAGETYPE_SHADOWSTRIKE] = "shadowstrike"
	damageColorProfileEntries[DAMAGETYPE_SPELLSTRIKE] = "spellstrike"
	damageColorProfileEntries[DAMAGETYPE_HOLYFIRE] = "radiant"
	damageColorProfileEntries[DAMAGETYPE_SHADOWHOLY] = "twilight"
	damageColorProfileEntries[DAMAGETYPE_DIVINE] = "divine"
	damageColorProfileEntries[DAMAGETYPE_HOLYSTORM] = "holystorm"
	damageColorProfileEntries[DAMAGETYPE_HOLYFROST] = "holyfrost"
	damageColorProfileEntries[DAMAGETYPE_FIRESTORM] = "volcanic"
	damageColorProfileEntries[DAMAGETYPE_FROSTFIRE] = "frostfire"
	damageColorProfileEntries[DAMAGETYPE_SHADOWFLAME] = "shadowflame"
	damageColorProfileEntries[DAMAGETYPE_SPELLFIRE] = "spellfire"
	damageColorProfileEntries[DAMAGETYPE_FROSTSTORM] = "froststorm"
	damageColorProfileEntries[DAMAGETYPE_SHADOWSTORM] = "plague"
	damageColorProfileEntries[DAMAGETYPE_SPELLSTORM] = "astral"
	damageColorProfileEntries[DAMAGETYPE_SHADOWFROST] = "shadowfrost"
	damageColorProfileEntries[DAMAGETYPE_SPELLFROST] = "spellfrost"
	damageColorProfileEntries[DAMAGETYPE_SPELLSHADOW] = "spellshadow"
	damageColorProfileEntries[DAMAGETYPE_ELEMENTAL] = "elemental"
	damageColorProfileEntries[DAMAGETYPE_COSMIC] = "cosmic"
	damageColorProfileEntries[DAMAGETYPE_CHROMATIC] = "chromatic"
	damageColorProfileEntries[DAMAGETYPE_MAGIC] = "magic"
	damageColorProfileEntries[DAMAGETYPE_CHAOS] = "chaos"
end

local function AbbreviateSkillName(skillName)
	if (string_find(skillName, "[%s%-]")) then
		skillName = string_gsub(skillName, "(%a)[%l%p]*[%s%-]*", "%1")
	end

	return skillName
end

local function FormatPartialEffects(absorbAmount, blockAmount, resistAmount, isGlancing, isCrushing)

	local currentProfile = MSBTProfiles.currentProfile

	local effectSettings, amount
	local partialEffectText = ""

	if absorbAmount then
		effectSettings = currentProfile.absorb
		amount = absorbAmount

	elseif blockAmount then
		effectSettings = currentProfile.block
		amount = blockAmount

	elseif resistAmount then
		effectSettings = currentProfile.resist
		amount = resistAmount
	end

	local trailer = effectSettings and effectSettings.trailer
	if trailer and not effectSettings.disabled then

		local formattedAmount = amount
		if currentProfile.shortenNumbers then
			formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
		elseif currentProfile.groupNumbers then
			formattedAmount = FormatLargeNumber(formattedAmount)
		end

		trailer = string_gsub(trailer, "%%a", formattedAmount)

		if not currentProfile.partialColoringDisabled then
			partialEffectText = string_format("|cFF%02x%02x%02x%s|r", effectSettings.colorR * 255, effectSettings.colorG * 255, effectSettings.colorB * 255, trailer)
		else
			partialEffectText = trailer
		end
	end

	effectSettings = nil
	trailer = nil

	if isGlancing then
		effectSettings = currentProfile.glancing

	elseif isCrushing then
		effectSettings = currentProfile.crushing
	end

	trailer = effectSettings and effectSettings.trailer
	if trailer and not effectSettings.disabled then

		if not currentProfile.partialColoringDisabled then
			partialEffectText = partialEffectText .. string_format("|cFF%02x%02x%02x%s|r", effectSettings.colorR * 255, effectSettings.colorG * 255, effectSettings.colorB * 255, trailer)
		else
			partialEffectText = partialEffectText .. trailer
		end
	end

	return partialEffectText
end

local function FormatEvent(message, amount, damageType, overhealAmount, overkillAmount, powerType, name, class, effectName, partialEffects, mergeTrailer, ignoreDamageColoring, hideSkills, hideNames)

	local currentProfile = MSBTProfiles.currentProfile
	local checkParens

	if amount and string_find(message, "%a", 1, true) then

		local partialAmount = ""
		if overhealAmount and overhealAmount > 0 and not currentProfile.overheal.disabled then

			amount = amount - overhealAmount

			partialAmount = overhealAmount
			if currentProfile.shortenNumbers then
				partialAmount = ShortenNumber(partialAmount, currentProfile.shortenNumberPrecision)
			elseif currentProfile.groupNumbers then
				partialAmount = FormatLargeNumber(partialAmount)
			end

			local overhealSettings = currentProfile.overheal
			partialAmount = string_gsub(overhealSettings.trailer, "%%a", partialAmount)
			if not currentProfile.partialColoringDisabled then
				partialAmount = string_format("|cFF%02x%02x%02x%s|r", overhealSettings.colorR * 255, overhealSettings.colorG * 255, overhealSettings.colorB * 255, partialAmount)
			end

		elseif overkillAmount and overkillAmount > 0 and not currentProfile.overkill.disabled then

			amount = amount - overkillAmount

			partialAmount = overkillAmount
			if currentProfile.shortenNumbers then
				partialAmount = ShortenNumber(partialAmount, currentProfile.shortenNumberPrecision)
			elseif currentProfile.groupNumbers then
				partialAmount = FormatLargeNumber(partialAmount)
			end

			local overkillSettings = currentProfile.overkill
			partialAmount = string_gsub(overkillSettings.trailer, "%%a", partialAmount)
			if not currentProfile.partialColoringDisabled then
				partialAmount = string_format("|cFF%02x%02x%02x%s|r", overkillSettings.colorR * 255, overkillSettings.colorG * 255, overkillSettings.colorB * 255, partialAmount)
			end
		end

		local formattedAmount = amount

		if currentProfile.shortenNumbers then
			formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
		elseif currentProfile.groupNumbers then
			formattedAmount = FormatLargeNumber(formattedAmount)
		end

		if damageType and not ignoreDamageColoring and not currentProfile.damageColoringDisabled then

			local damageSettings = currentProfile[damageColorProfileEntries[damageType]]
			if damageSettings and not damageSettings.disabled then
				formattedAmount = string_format("|cFF%02x%02x%02x%s|r", damageSettings.colorR * 255, damageSettings.colorG * 255, damageSettings.colorB * 255, formattedAmount)
			end
		end

		message = string_gsub(message, "%%a", formattedAmount .. partialAmount)
	end

	if powerType and string_find(message, "%p", 1, true) then
		local powerString = _G[powerTokens[powerType] or "UNKNOWN"]

		message = string_gsub(message, "%%p", powerString or UNKNOWN)
	end

	if name and string_find(message, "%n", 1, true) then
		if hideNames then
			message = string_gsub(message, "%s?%-?%s?%%n", "")
			checkParens = true
		else

			if string_find(name, "-", 1, true) then
				name = string_gsub(name, "(.-)%-.*", "%1")
			end

			if class and not currentProfile.classColoringDisabled then
				local classSettings = currentProfile[class]
				if classSettings and not classSettings.disabled then
					name = string_format("|cFF%02x%02x%02x%s|r", classSettings.colorR * 255, classSettings.colorG * 255, classSettings.colorB * 255, name)
				end
			end

			message = string_gsub(message, "%%n", name)
		end
	else
		message = string_gsub(message, "%%n", "")
		checkParens = true
	end

	if effectName and string_find(message, "%e", 1, true) then
		message = string_gsub(message, "%%e", effectName)
	end

	if effectName then
		if string_find(message, "%s", 1, true) then

			if (hideSkills) then
				message = string_gsub(message, "%s?%-?%s?%%sl?%s?%-?%s?", "")
				checkParens = true
			else

				local isChanged
				if (currentProfile.abilitySubstitutions[effectName]) then
					effectName = currentProfile.abilitySubstitutions[effectName]
					isChanged = true
				end

				if string_find(message, "%sl", 1, true) then
					message = string_gsub(message, "%%sl", effectName)
				end

				if isEnglish and not isChanged and currentProfile.abbreviateAbilities then
					effectName = AbbreviateSkillName(effectName)
				end

				message = string_gsub(message, "%%s", effectName)
			end
		end
	end

	if checkParens then
		message = string_gsub(message, "%(%)", "")
		message = string_gsub(message, "%[%]", "")
		message = string_gsub(message, "%{%}", "")
		message = string_gsub(message, "%<%>", "")
	end

	if damageType and string_find(message, "%t", 1, true) then
		message = string_gsub(message, "%%t", damageTypeMap[damageType] or STRING_SCHOOL_UNKNOWN)
	end

	if partialEffects then
		message = message .. partialEffects
	end

	if mergeTrailer then
		message = message .. mergeTrailer
	end

	return message
end

local function GetInOutEventData(parserEvent)
	local eventTypeString, affectedUnitName, affectedUnitClass

	if parserEvent.recipientUnit == "player" then
		affectedUnitName = parserEvent.sourceName
		eventTypeString = "INCOMING"
		affectedUnitClass = classMap[parserEvent.sourceGUID]
	elseif parserEvent.sourceUnit == "player" then
		affectedUnitName = parserEvent.recipientName
		eventTypeString = "OUTGOING"
		affectedUnitClass = classMap[parserEvent.recipientGUID]
	elseif parserEvent.recipientUnit == "pet" then
		affectedUnitName = parserEvent.sourceName
		eventTypeString = "PET_INCOMING"
		affectedUnitClass = classMap[parserEvent.sourceGUID]
	elseif parserEvent.sourceUnit == "pet" then
		affectedUnitName = parserEvent.recipientName
		eventTypeString = "PET_OUTGOING"
		affectedUnitClass = classMap[parserEvent.recipientGUID]
	end

	return eventTypeString, affectedUnitName, affectedUnitClass
end

local function DetectPowerGain(powerAmount, powerType)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_POWER_GAIN

	if eventSettings.disabled or not powerType then
		return
	end

	local lastPowerAmount = lastPowerAmounts[powerType] or 65535
	if powerAmount > lastPowerAmount then
		DisplayEvent(eventSettings, FormatEvent(eventSettings.message, powerAmount - lastPowerAmount, nil, nil, nil, powerType, nil, nil, UNKNOWN))
	end
end

local function HandleComboPoints(amount, powerType)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CP_GAIN
	local maxAmount = UnitPowerMax("player", powerType)
	if amount == maxAmount then
		eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CP_FULL
	end

	if eventSettings.disabled then
		return
	end

	if amount == 0 then
		return
	end

	if amount <= 0 then
		return
	end

	DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleChi(amount, powerType)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CHI_CHANGE
	local maxAmount = UnitPowerMax("player", powerType)
	if amount == maxAmount then
		eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CHI_FULL
	end

	if eventSettings.disabled then
		return
	end

	if amount <= 0 then
		return
	end

	DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleArcanePower(amount, powerType)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_AC_CHANGE
	local maxAmount = UnitPowerMax("player", powerType)
	if amount == maxAmount then
		eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_AC_FULL
	end

	if eventSettings.disabled then
		return
	end

	if amount <= 0 then
		return
	end

	DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleHolyPower(amount, powerType)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_HOLY_POWER_CHANGE
	local maxAmount = UnitPowerMax("player", powerType)
	if amount == maxAmount then
		eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_HOLY_POWER_FULL
	end

	if eventSettings.disabled then
		return
	end

	if amount == 0 then
		return
	end

	if amount <= 0 then
		return
	end

	DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleEssence(amount, powerType)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_ESSENCE_CHANGE
	local maxAmount = UnitPowerMax("player", powerType)
	if (amount == maxAmount) then eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_ESSENCE_FULL end

	if (eventSettings.disabled) then return end

	if (amount == 0) then return end

	if amount <= 0 then
		return
	end

	DisplayEvent(eventSettings, FormatEvent(eventSettings.message, amount))
end

local function HandleMonsterEmotes(emoteString)

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_MONSTER_EMOTE

	if eventSettings.disabled then
		return
	end

	local now = GetTime()
	for emote, cleanupTime in pairs(recentEmotes) do
		if now >= cleanupTime then
			recentEmotes[emote] = nil
		end
	end

	if recentEmotes[emoteString] then
		return
	end

	DisplayEvent(eventSettings, FormatEvent(eventSettings.message, nil, nil, nil, nil, nil, nil, nil, emoteString))
	recentEmotes[emoteString] = now + EMOTE_HOLD_TIME
end

local function MergeEvents(numEvents, currentProfile)

	local unmergedEvent
	local doMerge = false

	for i = 1, numEvents do

		unmergedEvent = unmergedEvents[i]

		for _, mergedEvent in ipairs(mergedEvents) do

			if unmergedEvent.eventType == mergedEvent.eventType then

				if not unmergedEvent.effectName then

					if unmergedEvent.name == mergedEvent.name and unmergedEvent.name then
						doMerge = true
					end

				elseif unmergedEvent.effectName == mergedEvent.effectName then

					if unmergedEvent.name ~= mergedEvent.name then
						mergedEvent.name = L.MSG_MULTIPLE_TARGETS
					end

					if unmergedEvent.class ~= mergedEvent.class then
						mergedEvent.class = nil
					end

					doMerge = true
				end
			end

			if doMerge then

				mergedEvent.partialEffects = nil

				unmergedEvent.eventMerged = true

				if unmergedEvent.amount then
					mergedEvent.amount = (mergedEvent.amount or 0) + unmergedEvent.amount
				end

				if unmergedEvent.overhealAmount then
					mergedEvent.overhealAmount = (mergedEvent.overhealAmount or 0) + unmergedEvent.overhealAmount
				end

				mergedEvent.numMerged = mergedEvent.numMerged + 1

				if unmergedEvent.isCrit then
					mergedEvent.numCrits = mergedEvent.numCrits + 1 else mergedEvent.isCrit = false
				end

				break
			end
		end

		if not doMerge then
			unmergedEvent.numMerged = 0

			if unmergedEvent.isCrit then
				unmergedEvent.numCrits = 1 else unmergedEvent.numCrits = 0
			end

			mergedEvents[#mergedEvents+1] = unmergedEvent
		end

		doMerge = false
	end

	if not currentProfile.hideMergeTrailer then
		for _, mergedEvent in ipairs(mergedEvents) do

			if mergedEvent.numMerged > 0 then

				local critTrailer = ""
				if mergedEvent.numCrits > 0 then
					critTrailer = string_format(", %d %s", mergedEvent.numCrits, mergedEvent.numCrits == 1 and L.MSG_CRIT or L.MSG_CRITS)
				end

				mergedEvent.mergeTrailer = string_format(" [%d %s%s]", mergedEvent.numMerged + 1, L.MSG_HITS, critTrailer)
			end
		end
	end

	for i = 1, numEvents do

		if unmergedEvents[1].eventMerged then
			EraseTable(unmergedEvents[1])
			combatEventCache[#combatEventCache + 1] = unmergedEvents[1]
		end

		table_remove(unmergedEvents, 1)
	end
end

local function DamageHandler(parserEvent, currentProfile)

	local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

	if not eventTypeString then
		return
	end

	if parserEvent.amount and parserEvent.amount < currentProfile.damageThreshold then
		return
	end

	local skillID = parserEvent.skillID
	if skillID == SPELLID_AUTOSHOT then
		skillID = nil
	end

	if skillID then
		eventTypeString = eventTypeString .. "_SPELL"
	end

	eventTypeString = eventTypeString .. (parserEvent.isDoT and "_DOT" or parserEvent.isDamageShield and "_DAMAGE_SHIELD" or "_DAMAGE")

	return eventTypeString, parserEvent.skillName, affectedUnitName, affectedUnitClass, true
end

local function MissHandler(parserEvent, currentProfile)

	local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

	if not eventTypeString then
		return
	end

	local skillID = parserEvent.skillID
	if skillID == SPELLID_AUTOSHOT then
		skillID = nil
	end

	if skillID then
		eventTypeString = eventTypeString .. "_SPELL"
	end

	eventTypeString = eventTypeString .. "_" .. parserEvent.missType

	return eventTypeString, parserEvent.skillName, affectedUnitName, affectedUnitClass, true
end

local function HealHandler(parserEvent, currentProfile)

	local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

	if not eventTypeString then
		return
	end

	local isHoT = parserEvent.isHoT
	local amount = parserEvent.amount
	if amount then

		if amount < currentProfile.healThreshold then
			return
		end

		local overhealAmount = parserEvent.overhealAmount
		local effectiveHealAmount = overhealAmount and (amount - overhealAmount) or amount

		if effectiveHealAmount == 0 then
			if not isHoT and currentProfile.hideFullOverheals then
				return
			end
			if isHoT and currentProfile.hideFullHoTOverheals then
				return
			end
		end
	end

	if parserEvent.sourceName == parserEvent.recipientName then
		eventTypeString = "SELF"
	end

	eventTypeString = eventTypeString .. (isHoT and "_HOT" or "_HEAL")

	return eventTypeString, parserEvent.skillName, affectedUnitName, affectedUnitClass, true
end

local function InterruptHandler(parserEvent, currentProfile)

	local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

	if not eventTypeString then
		return
	end

	eventTypeString = eventTypeString .. "_SPELL_INTERRUPT"

	return eventTypeString, parserEvent.extraSkillName, affectedUnitName, affectedUnitClass
end

local function EnvironmentalHandler(parserEvent, currentProfile)

	if parserEvent.recipientUnit ~= "player" then
		return
	end

	return "INCOMING_ENVIRONMENTAL", parserEvent.hazardType
end

local function AuraHandler(parserEvent, currentProfile)
	local eventTypeString, affectedUnitName, affectedUnitClass
	local effectName = parserEvent.skillName

	if parserEvent.recipientUnit == "player" then

		if ignoreAuras[parserEvent.skillName] and parserEvent.sourceUnit == "player" then
			return
		end

		-- Show all player aura notifications even when a trigger exists for the
		-- same aura name (for example proc triggers like Clearcasting).
		if triggerSuppressions[effectName] and parserEvent.isFade then
			return
		end

		eventTypeString = "NOTIFICATION_" .. parserEvent.auraType

		if not parserEvent.isFade then
			if (parserEvent.isDose) then
				eventTypeString = eventTypeString .. "_STACK"
			end
		else
			eventTypeString = eventTypeString .. "_FADE"
		end

	else

		if triggerSuppressions[effectName] then
			return
		end

		if not TestFlagsAll(parserEvent.recipientFlags, MSBTParser.TARGET_TARGET) then
			return
		end

		if not UnitIsEnemy("player", "target") then
			return
		end

		if parserEvent.auraType ~= "BUFF" or parserEvent.isFade == true then
			return
		end

		local now = GetTime()
		for buff, cleanupTime in pairs(recentEnemyBuffs) do
			if (now >= cleanupTime) then
				recentEnemyBuffs[buff] = nil
			end
		end

		if recentEnemyBuffs[effectName] then
			return
		end

		recentEnemyBuffs[effectName] = now + ENEMY_BUFF_HOLD_TIME

		eventTypeString = "NOTIFICATION_ENEMY_BUFF"
		affectedUnitName = parserEvent.recipientName
		affectedUnitClass = classMap[parserEvent.recipientGUID]
	end

	return eventTypeString, effectName, affectedUnitName, affectedUnitClass
end

local function EnchantHandler(parserEvent, currentProfile)

	if parserEvent.recipientUnit ~= "player" then
		return
	end

	local eventTypeString = "NOTIFICATION_ITEM_BUFF"
	if parserEvent.isFade then
		eventTypeString = eventTypeString .. "_FADE"
	end

	return eventTypeString, parserEvent.skillName
end

local function DispelHandler(parserEvent, currentProfile)

	local eventTypeString
	if parserEvent.sourceUnit == "player" then
		eventTypeString = "OUTGOING_DISPEL"
	elseif parserEvent.sourceUnit == "pet" then
		eventTypeString = "PET_OUTGOING_DISPEL"
	else

		return
	end

	return eventTypeString, parserEvent.extraSkillName, parserEvent.recipientName, classMap[parserEvent.recipientGUID]
end

local function PowerHandler(parserEvent, currentProfile)

	if uniquePowerTypes[parserEvent.powerType] ~= nil then
		return
	end

	if currentProfile.showAllPowerGains then
		return
	end

	local amount
	if parserEvent.isLeech then
		if parserEvent.sourceUnit ~= "player" then
			return
		end
		amount = parserEvent.extraAmount
	else
		if parserEvent.recipientUnit ~= "player" then
			return
		end
		amount = parserEvent.amount
	end

	if amount == 0 then
		return
	end

	if amount and math_abs(amount) < currentProfile.powerThreshold then
		return
	end

	local eventTypePrefix = "NOTIFICATION_POWER_"
	if parserEvent.powerType == powerTypes["ALTERNATE_POWER"] then
		eventTypePrefix = "NOTIFICATION_ALT_POWER_"
	end

	local eventTypeString = eventTypePrefix .. (parserEvent.isDrain and "LOSS" or "GAIN")

	return eventTypeString, parserEvent.skillName, nil, nil, true
end

local function KillHandler(parserEvent, currentProfile)

	if parserEvent.sourceUnit ~= "player" then
		return
	end

	if TestFlagsAll(parserEvent.recipientFlags, bit_bor(MSBTParser.UNITTYPE_GUARDIAN, MSBTParser.CONTROL_HUMAN)) then
		return
	end

	if parserEvent.recipientUnit == "pet" then
		return
	end

	local eventTypeString = "NOTIFICATION_"
	eventTypeString = eventTypeString .. (TestFlagsAll(parserEvent.recipientFlags, MSBTParser.CONTROL_SERVER) and "NPC" or "PC")
	eventTypeString = eventTypeString .. "_KILLING_BLOW"

	return eventTypeString, nil, parserEvent.recipientName, classMap[parserEvent.recipientGUID]
end

local function HonorHandler(parserEvent, currentProfile)

	if parserEvent.recipientUnit ~= "player" then
		return
	end

	return "NOTIFICATION_HONOR_GAIN"
end

local function ReputationHandler(parserEvent, currentProfile)

	if parserEvent.recipientUnit ~= "player" then
		return
	end

	local eventTypeString = "NOTIFICATION_REP_" .. (parserEvent.isLoss and "LOSS" or "GAIN")
	return eventTypeString, parserEvent.factionName
end

local function ProficiencyHandler(parserEvent, currentProfile)

	if parserEvent.recipientUnit ~= "player" then
		return
	end

	return "NOTIFICATION_SKILL_GAIN", parserEvent.skillName
end

local function ExperienceHandler(parserEvent, currentProfile)

	if parserEvent.recipientUnit ~= "player" then
		return
	end

	return "NOTIFICATION_EXPERIENCE_GAIN"
end

local function ExtraAttacksHandler(parserEvent, currentProfile)

	if parserEvent.sourceUnit ~= "player" then
		return
	end

	return "NOTIFICATION_EXTRA_ATTACK", parserEvent.skillName
end

local function ParserEventsHandler(parserEvent)

	local currentProfile = MSBTProfiles.currentProfile

	local eventTypeString, effectName, affectedUnitName, affectedUnitClass, mergeEligible

	local eventType = parserEvent.eventType

	local handler = eventHandlers[eventType]
	if handler then
		eventTypeString, effectName, affectedUnitName, affectedUnitClass, mergeEligible = handler(parserEvent, currentProfile)
	end

	if not eventTypeString then
		return
	end

	-- Keep outgoing-only output combat-gated while allowing incoming and
	-- notification/static output to continue out of combat.
	if not InCombatLockdown() then
		if string_find(eventTypeString, "OUTGOING", 1, true) == 1 or string_find(eventTypeString, "PET_OUTGOING", 1, true) == 1 then
			return
		end
	end

	if effectName and currentProfile.abilitySuppressions[effectName] then
		return
	end

	local isCrit = parserEvent.isCrit
	local eventSettings = currentProfile.events[isCrit and eventTypeString .. "_CRIT" or eventTypeString]
	if not eventSettings or eventSettings.disabled or not IsScrollAreaActive(eventSettings.scrollArea) then
		return
	end

	local damageType = parserEvent.damageType
	local skillID = parserEvent.skillID

	if skillID == SPELLID_AUTOSHOT then
		skillID = nil
		effectName = nil
	end

	local ignoreDamageColoring
	if eventType == "damage" and parserEvent.sourceUnit == "player" and damageType == DAMAGETYPE_PHYSICAL and skillID then
		ignoreDamageColoring = true
	end

	if eventType == "miss" and parserEvent.missType == "ABSORB" then
		damageType = parserEvent.skillSchool or DAMAGETYPE_PHYSICAL
	end

	local partialEffects
	if eventType == "damage" or eventType == "environmental" then
		partialEffects = FormatPartialEffects(parserEvent.absorbAmount, parserEvent.blockAmount, parserEvent.resistAmount, parserEvent.isGlancing, parserEvent.isCrushing)
	end

	local effectTexture
	if not currentProfile.skillIconsDisabled and IsScrollAreaIconShown(eventSettings.scrollArea) then
		if skillID then
			_, _, effectTexture = GetSpellInfo(skillID)
		end

		if (eventType == "dispel" or eventType == "interrupt" or (eventType == "miss" and parserEvent.missType == "RESIST")) and parserEvent.extraSkillID then
			_, _, effectTexture = GetSpellInfo(parserEvent.extraSkillID)
		end
		if not effectTexture and effectName then
			_, _, effectTexture = GetSpellInfo(effectName)
		end
	end

	if not mergeEligible then
		local outputMessage = FormatEvent(eventSettings.message, parserEvent.amount, damageType, nil, nil, nil, affectedUnitName, affectedUnitClass, effectName)
		DisplayEvent(eventSettings, outputMessage, effectTexture)

	elseif currentProfile.mergeExclusions[effectName] or (not effectName and currentProfile.mergeSwingsDisabled) then

		local hideSkills = effectTexture and not currentProfile.exclusiveSkillsDisabled or currentProfile.hideSkills
		local outputMessage = FormatEvent(eventSettings.message, parserEvent.amount, damageType, parserEvent.overhealAmount, parserEvent.overkillAmount, parserEvent.powerType, affectedUnitName, affectedUnitClass, effectName, partialEffects, nil, ignoreDamageColoring, hideSkills, currentProfile.hideNames)
		DisplayEvent(eventSettings, outputMessage, effectTexture)

	else

		local combatEvent = table_remove(combatEventCache) or {}

		if effectName and offHandTrailer and string_find(effectName, offHandTrailer, 1, true) then
			effectName = string_gsub(effectName, offHandPattern, "")
		end

		combatEvent.eventType = eventTypeString
		combatEvent.isCrit = isCrit
		combatEvent.amount = parserEvent.amount
		combatEvent.effectName = effectName
		combatEvent.effectTexture = effectTexture
		combatEvent.name = affectedUnitName
		combatEvent.class = affectedUnitClass
		combatEvent.damageType = damageType
		combatEvent.ignoreDamageColoring = ignoreDamageColoring
		combatEvent.partialEffects = partialEffects
		combatEvent.overhealAmount = parserEvent.overhealAmount
		combatEvent.overkillAmount = parserEvent.overkillAmount
		combatEvent.powerType = parserEvent.powerType

		if effectName then

			local throttleDuration = currentProfile.throttleList[effectName]

			if not throttleDuration then

				if parserEvent.isDoT and currentProfile.dotThrottleDuration > 0 then
					throttleDuration = currentProfile.dotThrottleDuration

				elseif parserEvent.isHoT and currentProfile.hotThrottleDuration > 0 then
					throttleDuration = currentProfile.hotThrottleDuration

				elseif parserEvent.powerType and currentProfile.powerThrottleDuration > 0 then
					throttleDuration = currentProfile.powerThrottleDuration
				end
			end

			if throttleDuration and throttleDuration > 0 then

				local throttledAbility = throttledAbilities[effectName]
				if not throttledAbility then
					throttledAbility = {}
					throttledAbility.throttleWindow = 0
					throttledAbility.lastEventTime = 0
					throttledAbilities[effectName] = throttledAbility
				end

				local now = GetTime()
				if throttledAbility.throttleWindow > 0 then
						throttledAbility.lastEventTime = now
						throttledAbility[#throttledAbility + 1] = combatEvent
						return

				else

					throttledAbility.throttleWindow = throttleDuration

					if not throttleFrame:IsVisible() then
						throttleFrame:Show()
					end

					if now - throttledAbility.lastEventTime < throttleDuration then
						throttledAbility.lastEventTime = now
						throttledAbility[#throttledAbility + 1] = combatEvent
						return
					end
				end
			end
		end

		unmergedEvents[#unmergedEvents + 1] = combatEvent

		if not eventFrame:IsVisible() then
			eventFrame:Show()
		end
	end
end

local function OnUpdateEventFrame(this, elapsed)

	lastMergeUpdate = lastMergeUpdate + elapsed

	if lastMergeUpdate >= MERGE_DELAY_TIME then

		local currentProfile = MSBTProfiles.currentProfile
		local hideNames = currentProfile.hideNames
		local exclusiveSkillsDisabled = currentProfile.exclusiveSkillsDisabled

		MergeEvents(#unmergedEvents, currentProfile)

		local eventSettings, hideSkills, outputMessage
		for i, combatEvent in ipairs(mergedEvents) do
			eventSettings = currentProfile.events[combatEvent.isCrit and combatEvent.eventType .. "_CRIT" or combatEvent.eventType]
			hideSkills = combatEvent.effectTexture and not exclusiveSkillsDisabled or currentProfile.hideSkills
			outputMessage = FormatEvent(eventSettings.message, combatEvent.amount, combatEvent.damageType, combatEvent.overhealAmount, combatEvent.overkillAmount, combatEvent.powerType, combatEvent.name, combatEvent.class, combatEvent.effectName, combatEvent.partialEffects, combatEvent.mergeTrailer, combatEvent.ignoreDamageColoring, hideSkills, hideNames)
			DisplayEvent(eventSettings, outputMessage, combatEvent.effectTexture)
			mergedEvents[i] = nil
			EraseTable(combatEvent)
			combatEventCache[#combatEventCache + 1] = combatEvent
		end

		if #unmergedEvents == 0 then
			this:Hide()
		end

		lastMergeUpdate = 0
	end
end

local function OnUpdateThrottleFrame(this, elapsed)

	lastThrottleUpdate = lastThrottleUpdate + elapsed

	if lastThrottleUpdate >= THROTTLE_UPDATE_TIME then

		local eventsThrottled

		for _, throttledAbility in pairs(throttledAbilities) do

			if throttledAbility.throttleWindow > 0 then

				throttledAbility.throttleWindow = throttledAbility.throttleWindow - lastThrottleUpdate

				if throttledAbility.throttleWindow <= 0 then

					if #throttledAbility > 0 then
						for i = 1, #throttledAbility do
							unmergedEvents[#unmergedEvents + 1] = throttledAbility[i]
							throttledAbility[i] = nil
						end

						if not eventFrame:IsVisible() then
							eventFrame:Show()
						end
					end

				else
					eventsThrottled = true
				end
			end
		end

		if not eventsThrottled then
			this:Hide()
		end

		lastThrottleUpdate = 0
	end
end

function eventFrame:UNIT_POWER_UPDATE(unitID, powerToken)

	if unitID ~= "player" then
		return
	end

	local powerType = powerTypes[powerToken]
	if not powerType then
		return
	end

	local powerAmount = UnitPower("player", powerType)

	local doFullDetect = true
	local lastPowerAmount = lastPowerAmounts[powerType]

	if powerToken == "CHI" and playerClass == "MONK" then
		if powerAmount ~= lastPowerAmount then
			HandleChi(powerAmount, powerType)
		end
		doFullDetect = false

	elseif powerToken == "HOLY_POWER" and playerClass == "PALADIN" then
		if powerAmount ~= lastPowerAmount then
			HandleHolyPower(powerAmount, powerType)
		end
		doFullDetect = false

	elseif powerToken == "COMBO_POINTS" and playerClass == "ROGUE" then
		if powerAmount ~= lastPowerAmount then
			HandleComboPoints(powerAmount, powerType)
		end
		doFullDetect = false

	elseif powerToken == "COMBO_POINTS" and playerClass == "DRUID" then
		if powerAmount ~= lastPowerAmount then
			HandleComboPoints(powerAmount, powerType)
		end
		doFullDetect = false

	elseif powerToken == "ARCANE_CHARGES" and playerClass == "MAGE" then
		if powerAmount ~= lastPowerAmount then
			HandleArcanePower(powerAmount, powerType)
		end
		doFullDetect = false

	elseif powerToken == "ESSENCE" and playerClass == "EVOKER" then
		if powerAmount ~= lastPowerAmount then
			HandleEssence(powerAmount, powerType)
		end
		doFullDetect = false

	end

	if doFullDetect and MSBTProfiles.currentProfile.showAllPowerGains then
		DetectPowerGain(powerAmount, powerType)
	end
	lastPowerAmounts[powerType] = powerAmount
end

function eventFrame:PLAYER_REGEN_ENABLED()
	EraseTable(incomingDamageBatches)
	EraseTable(incomingHealBatches)
	EraseTable(damageMeterLastSpellTotals)
	lastDamageMeterPoll = 0
	lastDamageMeterDeltaTime = 0
	lastAutoAttackFallbackTime = 0
	lastDotFallbackSpellID = nil
	lastDotFallbackAuraIDs = nil
	lastDotFallbackRequireAura = true
	lastDotFallbackExpire = 0

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COMBAT_LEAVE
	if not eventSettings.disabled then
		DisplayEvent(eventSettings, eventSettings.message)
	end
end

function eventFrame:PLAYER_REGEN_DISABLED()
	EraseTable(incomingDamageBatches)
	EraseTable(incomingHealBatches)
	EraseTable(damageMeterLastSpellTotals)
	lastDamageMeterPoll = 0
	lastDamageMeterDeltaTime = 0
	lastAutoAttackFallbackTime = 0
	lastDotFallbackSpellID = nil
	lastDotFallbackAuraIDs = nil
	lastDotFallbackRequireAura = true
	lastDotFallbackExpire = 0

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COMBAT_ENTER
	if not eventSettings.disabled then
		DisplayEvent(eventSettings, eventSettings.message)
	end
end

function eventFrame:CHAT_MSG_MONSTER_EMOTE(message, sourceName)
	if sourceName ~= UnitName("target") then
		return
	end
	HandleMonsterEmotes(string_gsub(message, "%%s", sourceName))
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

local function IsLikelySpellSchool(schoolMask)
	local maskType = type(schoolMask)
	if maskType == "number" then
		-- Combat school bitmask: 0x1 is physical.
		return schoolMask ~= 0 and schoolMask ~= 1
	elseif maskType == "string" then
		if schoolMask == "" then
			return false
		end
		local lowerMask = string.lower(schoolMask)
		local physicalName = STRING_SCHOOL_PHYSICAL and string.lower(STRING_SCHOOL_PHYSICAL) or "physical"
		return lowerMask ~= physicalName and lowerMask ~= "physical"
	end
	return false
end

local function IsAutoAttackSpellID(spellID)
	if not spellID then
		return true
	end
	if C_Spell and C_Spell.IsAutoAttackSpell and C_Spell.IsAutoAttackSpell(spellID) then
		return true
	end
	if C_Spell and C_Spell.IsRangedAutoAttackSpell and C_Spell.IsRangedAutoAttackSpell(spellID) then
		return true
	end
	return spellID == AUTOSHOT_SPELL_ID
end

local function CanUseAutoAttackFallback(now)
	local autoActive = false

	-- API compatibility across client variants.
	if type(IsCurrentSpell) == "function" then
		local ok, result = pcall(IsCurrentSpell, AUTOSHOT_SPELL_ID)
		if ok and result then
			autoActive = true
		end
	end
	if (not autoActive) and type(IsAutoRepeatSpell) == "function" then
		local ok, result = pcall(IsAutoRepeatSpell)
		if ok and result then
			autoActive = true
		end
	end
	if (not autoActive) and C_Spell and type(C_Spell.IsAutoAttackSpell) == "function" then
		-- If we can identify the spell as an auto-attack spell but cannot query
		-- active state on this client, allow timing gate to decide.
		local ok, result = pcall(C_Spell.IsAutoAttackSpell, AUTOSHOT_SPELL_ID)
		if ok and result then
			autoActive = true
		end
	end
	if not autoActive then
		return false
	end

	local mainSpeed, offSpeed = UnitAttackSpeed("player")
	local swingSpeed = mainSpeed or offSpeed or 2
	if offSpeed and offSpeed < swingSpeed then
		swingSpeed = offSpeed
	end

	-- Prevent rapid false attribution from multiple UNIT_COMBAT target events.
	local minGap = math.max(0.25, swingSpeed * 0.45)
	return (now - lastAutoAttackFallbackTime) >= minGap
end

local function IsDamageMeterOutgoingActive()
	return USE_DAMAGE_METER_OUTGOING and IsRetail and C_DamageMeter and Enum and Enum.DamageMeterType
end

local function IsDamageMeterDeltaFresh(now)
	if lastDamageMeterDeltaTime <= 0 then
		return false
	end
	now = now or GetTime()
	return (now - lastDamageMeterDeltaTime) <= DAMAGE_METER_FALLBACK_STALE_TIME
end

local function HasPlayerDebuffOnTarget(spellID)
	if not spellID or not UnitExists("target") then
		return false
	end

	if AuraUtil and AuraUtil.FindAuraBySpellID then
		local ok, auraData = pcall(AuraUtil.FindAuraBySpellID, spellID, "target", "HARMFUL|PLAYER")
		if ok and auraData then
			return true
		end
	end

	if C_UnitAuras and type(C_UnitAuras.GetAuraDataByIndex) == "function" then
		for i = 1, 40 do
			local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, "HARMFUL")
			if not ok or not aura then
				break
			end
			local auraSpellID = aura.spellId or aura.spellID
			local sourceUnit = aura.sourceUnit or aura.unitCaster
			local okMatch, isMatch = pcall(function()
				return auraSpellID == spellID
			end)
			local okSource, isOwned = pcall(function()
				return sourceUnit == "player" or sourceUnit == "pet" or sourceUnit == "vehicle"
			end)
			if okMatch and isMatch and okSource and isOwned then
				return true
			end
		end
	end

	if type(UnitAura) == "function" then
		for i = 1, 40 do
			local _, _, _, _, _, _, _, unitCaster, _, _, auraSpellID = UnitAura("target", i, "HARMFUL")
			if not auraSpellID then
				break
			end
			local okMatch, isMatch = pcall(function()
				return auraSpellID == spellID
			end)
			local okSource, isOwned = pcall(function()
				return unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"
			end)
			if okMatch and isMatch and okSource and isOwned then
				return true
			end
		end
	end
	return false
end

local function HasPlayerAnyDebuffOnTarget(spellIDs)
	if not spellIDs then
		return false
	end
	for i = 1, #spellIDs do
		if HasPlayerDebuffOnTarget(spellIDs[i]) then
			return true
		end
	end
	return false
end

local function BuildOutgoingHitsMessage(totalAmount, hitCount, critCount, isSpell)
	local currentProfile = MSBTProfiles.currentProfile
	local formattedAmount = totalAmount
	if currentProfile.shortenNumbers then
		formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
	elseif currentProfile.groupNumbers then
		formattedAmount = FormatLargeNumber(formattedAmount)
	end

	local amountColor = isSpell and "|cFFFFFF66" or "|cFFFFFFFF"
	local coloredAmount = string_format("%s%s|r", amountColor, formattedAmount)

	local hitsWord = (hitCount == 1) and "hit" or "hits"
	if critCount and critCount > 0 then
		if hitCount == 1 and critCount == 1 then
			return string_format("%s (Crit)", coloredAmount)
		end
		local critWord = (critCount == 1) and "Crit" or "Crits"
		return string_format("%s (%d %s, %d %s)", coloredAmount, hitCount, hitsWord, critCount, critWord)
	end
	if hitCount == 1 then
		return coloredAmount
	end
	return string_format("%s (%d %s)", coloredAmount, hitCount, hitsWord)
end

local function StripRealm(name)
	if not name then
		return UNKNOWN
	end
	if string_find(name, "-", 1, true) then
		return string_gsub(name, "(.-)%-.*", "%1")
	end
	return name
end

local function ResolveOutgoingDamageEventSettings(isSpell)
	local currentProfile = MSBTProfiles.currentProfile
	local primaryKey = isSpell and "OUTGOING_SPELL_DAMAGE" or "OUTGOING_DAMAGE"
	local secondaryKey = isSpell and "OUTGOING_DAMAGE" or "OUTGOING_SPELL_DAMAGE"

	local eventSettings = currentProfile.events[primaryKey]
	if eventSettings and not eventSettings.disabled then
		return primaryKey, eventSettings
	end

	eventSettings = currentProfile.events[secondaryKey]
	if eventSettings and not eventSettings.disabled then
		return secondaryKey, eventSettings
	end
end

local function FlushOutgoingBatch(batchKey)
	local batch = outgoingBatches[batchKey]
	if not batch then
		return
	end
	outgoingBatches[batchKey] = nil

	local normalEventKey, eventSettings = ResolveOutgoingDamageEventSettings(batch.isSpell)
	if not eventSettings then
		return
	end

	local currentProfile = MSBTProfiles.currentProfile
	local critSettings = currentProfile.events[normalEventKey .. "_CRIT"]
	local routeCritSeparately = false
	if batch.critCount and batch.critCount > 0 and critSettings and not critSettings.disabled then
		local normalScrollArea = eventSettings.scrollArea
		local critScrollArea = critSettings.scrollArea
		routeCritSeparately = normalScrollArea and critScrollArea and (normalScrollArea ~= critScrollArea)
	end

	if routeCritSeparately then
		local critAmount = batch.critAmount or 0
		if critAmount > batch.totalAmount then
			critAmount = batch.totalAmount
		end

		local nonCritCount = batch.hitCount - batch.critCount
		local nonCritAmount = batch.totalAmount - critAmount
		if nonCritCount > 0 and nonCritAmount > 0 then
			local nonCritMessage = BuildOutgoingHitsMessage(nonCritAmount, nonCritCount, 0, batch.isSpell)
			DisplayEvent(eventSettings, nonCritMessage, batch.effectTexture)
		end

		if batch.critCount > 0 and critAmount > 0 then
			local critMessage = BuildOutgoingHitsMessage(critAmount, batch.critCount, batch.critCount, batch.isSpell)
			DisplayEvent(critSettings, critMessage, batch.effectTexture)
		end
		return
	end

	local message = BuildOutgoingHitsMessage(batch.totalAmount, batch.hitCount, batch.critCount, batch.isSpell)
	local displaySettings = eventSettings
	if batch.critCount and batch.critCount > 0 then
		displaySettings = {}
		for k, v in pairs(eventSettings) do
			displaySettings[k] = v
		end
		displaySettings.isCrit = true
		local baseSize = eventSettings.fontSize or currentProfile.normalFontSize or 26
		displaySettings.fontSize = math_floor((baseSize * 1.5) + 0.5)
	end
	DisplayEvent(displaySettings, message, batch.effectTexture)
end

local function QueueOutgoingBatch(spellIDUsed, normalizedAmount, isCrit, effectTexture, forceIsSpell)
	if not normalizedAmount or normalizedAmount <= 0 then
		return
	end

	if not effectTexture then
		_, _, effectTexture = GetSpellInfo(spellIDUsed or AUTOSHOT_SPELL_ID)
	end
	if not effectTexture then
		spellIDUsed = AUTOSHOT_SPELL_ID
		_, _, effectTexture = GetSpellInfo(AUTOSHOT_SPELL_ID)
	end

	local batchKey = tostring(spellIDUsed or 0)
	local batch = outgoingBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			critCount = 0,
			critAmount = 0,
			totalAmount = 0,
			isSpell = (forceIsSpell ~= nil) and forceIsSpell or (not IsAutoAttackSpellID(spellIDUsed)),
			effectTexture = effectTexture,
		}
		outgoingBatches[batchKey] = batch
		C_Timer.After(OUTGOING_GROUP_DELAY, function()
			FlushOutgoingBatch(batchKey)
		end)
	end
	if forceIsSpell then
		batch.isSpell = true
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + normalizedAmount
	if effectTexture and not batch.effectTexture then
		batch.effectTexture = effectTexture
	end
	if isCrit then
		batch.critCount = batch.critCount + 1
		batch.critAmount = batch.critAmount + normalizedAmount
	end
end

local function ProcessDamageMeterOutgoing()
	if not IsDamageMeterOutgoingActive() then
		return
	end
	if not InCombatLockdown() then
		return
	end

	lastDamageMeterPoll = GetTime()

	local playerUnitGUID = UnitGUID("player") or playerGUID
	if not playerUnitGUID then
		return
	end

	local sourceGUIDs = { playerUnitGUID, UnitGUID("pet"), UnitGUID("vehicle") }
	local seen = {}

	for _, sourceGUID in ipairs(sourceGUIDs) do
		if sourceGUID and not seen[sourceGUID] then
			seen[sourceGUID] = true
			local ok, sessionSource = pcall(C_DamageMeter.GetCombatSessionSourceFromType, 0, Enum.DamageMeterType.DamageDone, sourceGUID)
			if ok and sessionSource and type(sessionSource.combatSpells) == "table" then
				for _, damageSpell in ipairs(sessionSource.combatSpells) do
					-- C_DamageMeter can expose restricted "secret" values. Keep every
					-- operation in one protected block and skip on any access error.
					pcall(function()
						local spellID = damageSpell.spellID
						local totalAmount = damageSpell.totalAmount
						if not spellID or totalAmount == nil then
							return
						end

						local key = tostring(sourceGUID) .. ":" .. tostring(spellID)
						local lastAmount = damageMeterLastSpellTotals[key] or 0
						local totalNum = tonumber(totalAmount)
						if not totalNum or totalNum <= 0 then
							return
						end

						local deltaAmount = totalNum - lastAmount
						if deltaAmount < 0 then
							deltaAmount = totalNum
						end

						if deltaAmount > 0 then
							QueueOutgoingBatch(spellID, deltaAmount, false)
							lastDamageMeterDeltaTime = lastDamageMeterPoll
						end
						damageMeterLastSpellTotals[key] = totalNum
					end)
				end
			end
		end
	end
end

local function StartDamageMeterTicker()
	if damageMeterTicker then
		return
	end
	damageMeterTicker = C_Timer.NewTicker(0.1, ProcessDamageMeterOutgoing)
end

local function StopDamageMeterTicker()
	if not damageMeterTicker then
		return
	end
	damageMeterTicker:Cancel()
	damageMeterTicker = nil
end

local incomingDamageSourceMap = {
	FALLING = "falling",
	DROWNING = "drowning",
	FIRE = "fire",
	LAVA = "lava",
	SLIME = "slime",
	EXHAUSTION = "fatigue",
}

local incomingDamageFlagIgnore = {
	CRITICAL = true,
	CRUSHING = true,
	GLANCING = true,
	BLOCK = true,
	ABSORB = true,
	RESIST = true,
}

local function GetIncomingDamageSourceLabel(flagText, schoolMask)
	if flagText and incomingDamageSourceMap[flagText] then
		return incomingDamageSourceMap[flagText]
	end
	if flagText and not incomingDamageFlagIgnore[flagText] then
		return string.lower(flagText)
	end
	if type(schoolMask) == "string" and schoolMask ~= "" then
		return string.lower(schoolMask)
	end
	return nil
end

local function GetLikelyIncomingHealSourceName()
	if UnitCastingInfo("player") or UnitChannelInfo("player") then
		return UnitName("player") or UNKNOWN
	end

	if UnitExists("target") and UnitCanAssist("player", "target") and UnitExists("targettarget") and UnitIsUnit("targettarget", "player") then
		return UnitName("target") or UNKNOWN
	end
	if UnitExists("focus") and UnitCanAssist("player", "focus") and UnitExists("focustarget") and UnitIsUnit("focustarget", "player") then
		return UnitName("focus") or UNKNOWN
	end

	return UNKNOWN
end

local function BuildActionMessage(eventSettings, amount)
	local function CleanupActionMessage(message)
		if not message then
			return message
		end
		-- Remove unresolved placeholders that can still leak through.
		message = string_gsub(message, "%%n", "")
		message = string_gsub(message, "%%sl", "")
		message = string_gsub(message, "%%s", "")
		message = string_gsub(message, "%%e", "")
		-- Remove dangling separators/wrappers from missing name/skill parts.
		message = string_gsub(message, "%(%s*%-?%s*%)", "")
		message = string_gsub(message, "%[%s*%-?%s*%]", "")
		message = string_gsub(message, "%{%s*%-?%s*%}", "")
		message = string_gsub(message, "%<%s*%-?%s*%>", "")
		message = string_gsub(message, "^%s*%-%s*", "")
		message = string_gsub(message, "%s*%-%s*$", "")
		message = string_gsub(message, "%s%s+", " ")
		message = string_gsub(message, "^%s+", "")
		message = string_gsub(message, "%s+$", "")
		return message
	end

	if not eventSettings or not eventSettings.message then
		return nil
	end
	local message = eventSettings.message
	if amount and amount > 0 then
		message = FormatEvent(message, amount)
		-- Incoming UNIT_COMBAT paths often lack reliable effect name data.
		-- Remove unresolved skill placeholders to avoid showing raw %s/%sl/%e.
		message = string_gsub(message, "<%%sl>%s*", "")
		message = string_gsub(message, "<%%s>%s*", "")
		message = string_gsub(message, "<%%e>%s*", "")
		message = string_gsub(message, "%%sl", "")
		message = string_gsub(message, "%%s", "")
		message = string_gsub(message, "%%e", "")
		return CleanupActionMessage(message)
	end

	message = string_gsub(message, "<%%a>%s*", "")
	message = string_gsub(message, "%%a", "")
	message = string_gsub(message, "<%%sl>%s*", "")
	message = string_gsub(message, "<%%s>%s*", "")
	message = string_gsub(message, "<%%e>%s*", "")
	message = string_gsub(message, "%%sl", "")
	message = string_gsub(message, "%%s", "")
	message = string_gsub(message, "%%e", "")
	return CleanupActionMessage(message)
end

local function BuildHitSummary(hitCount, critCount, singleCritLabel)
	if not hitCount or hitCount <= 0 then
		return nil
	end
	if critCount and critCount > 0 then
		if hitCount == 1 and critCount == 1 and singleCritLabel then
			return " (Crit)"
		end
		local hitsWord = (hitCount == 1) and "hit" or "hits"
		local critWord = (critCount == 1) and "Crit" or "Crits"
		return string_format(" (%d %s, %d %s)", hitCount, hitsWord, critCount, critWord)
	end
	if hitCount > 1 then
		local hitsWord = (hitCount == 1) and "hit" or "hits"
		return string_format(" (%d %s)", hitCount, hitsWord)
	end
	return nil
end

local function GetIncomingHealSourceLabel(flagText, schoolMask)
	local flag = flagText and string_upper(tostring(flagText)) or ""
	local school = schoolMask and string_upper(tostring(schoolMask)) or ""
	if string_find(flag, "LEECH", 1, true) or string_find(school, "LEECH", 1, true) then
		return "Leech"
	end
	return nil
end

local function QueueIncomingDamageBatch(normalizedAmount, isCrit, damageSource)
	if not normalizedAmount or normalizedAmount <= 0 then
		return
	end

	local batchKey = "incoming_damage"
	local batch = incomingDamageBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			critCount = 0,
			critAmount = 0,
			totalAmount = 0,
			damageSource = damageSource,
		}
		incomingDamageBatches[batchKey] = batch
		C_Timer.After(INCOMING_GROUP_DELAY, function()
			local queued = incomingDamageBatches[batchKey]
			if not queued then
				return
			end
			incomingDamageBatches[batchKey] = nil

			local currentProfile = MSBTProfiles.currentProfile
			local eventSettings = currentProfile.events.INCOMING_DAMAGE
			if not eventSettings or eventSettings.disabled then
				return
			end
			local critSettings = currentProfile.events.INCOMING_DAMAGE_CRIT

			local message = BuildActionMessage(eventSettings, queued.totalAmount)
			if not message or message == "" then
				return
			end

			local routeCritSeparately = false
			if queued.critCount and queued.critCount > 0 and critSettings and not critSettings.disabled then
				local normalScrollArea = eventSettings.scrollArea
				local critScrollArea = critSettings.scrollArea
				routeCritSeparately = normalScrollArea and critScrollArea and (normalScrollArea ~= critScrollArea)
			end

			if routeCritSeparately then
				local critAmount = queued.critAmount or 0
				if critAmount > queued.totalAmount then
					critAmount = queued.totalAmount
				end

				local nonCritCount = queued.hitCount - queued.critCount
				local nonCritAmount = queued.totalAmount - critAmount
				if nonCritCount > 0 and nonCritAmount > 0 then
					local nonCritMessage = BuildActionMessage(eventSettings, nonCritAmount)
					if nonCritMessage and nonCritMessage ~= "" then
						local nonCritSummary = BuildHitSummary(nonCritCount, 0, true)
						if nonCritSummary then
							nonCritMessage = nonCritMessage .. nonCritSummary
						end
						if queued.damageSource and queued.damageSource ~= "" then
							nonCritMessage = string_format("%s - %s", nonCritMessage, queued.damageSource)
						end
						DisplayEvent(eventSettings, nonCritMessage)
					end
				end

				if queued.critCount > 0 and critAmount > 0 then
					local critMessage = BuildActionMessage(critSettings, critAmount)
					if critMessage and critMessage ~= "" then
						local critSummary = BuildHitSummary(queued.critCount, queued.critCount, true)
						if critSummary then
							critMessage = critMessage .. critSummary
						end
						if queued.damageSource and queued.damageSource ~= "" then
							critMessage = string_format("%s - %s", critMessage, queued.damageSource)
						end
						DisplayEvent(critSettings, critMessage)
					end
				end
				return
			end

			local summary = BuildHitSummary(queued.hitCount, queued.critCount, true)
			if summary then
				message = message .. summary
			end
			if queued.damageSource and queued.damageSource ~= "" then
				message = string_format("%s - %s", message, queued.damageSource)
			end

			local displaySettings = eventSettings
			if queued.critCount and queued.critCount > 0 then
				displaySettings = {}
				for k, v in pairs(eventSettings) do
					displaySettings[k] = v
				end
				displaySettings.isCrit = true
				local baseSize = eventSettings.fontSize or currentProfile.normalFontSize or 26
				displaySettings.fontSize = math_floor((baseSize * 1.5) + 0.5)
			end
			DisplayEvent(displaySettings, message)
		end)
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + normalizedAmount
	if isCrit then
		batch.critCount = batch.critCount + 1
		batch.critAmount = batch.critAmount + normalizedAmount
	end
	if damageSource and damageSource ~= "" then
		if batch.damageSource and batch.damageSource ~= damageSource then
			batch.damageSource = "mixed"
		elseif not batch.damageSource then
			batch.damageSource = damageSource
		end
	end
end

local function QueueIncomingHealBatch(normalizedAmount, isCrit, effectTexture, sourceName, healSourceLabel)
	if not normalizedAmount or normalizedAmount <= 0 then
		return
	end

	local batchKey = "incoming_heal"
	local batch = incomingHealBatches[batchKey]
	if not batch then
		batch = {
			hitCount = 0,
			critCount = 0,
			critAmount = 0,
			totalAmount = 0,
			effectTexture = effectTexture,
			sourceName = sourceName,
			healSourceLabel = healSourceLabel,
		}
		incomingHealBatches[batchKey] = batch
		C_Timer.After(INCOMING_GROUP_DELAY, function()
			local queued = incomingHealBatches[batchKey]
			if not queued then
				return
			end
			incomingHealBatches[batchKey] = nil

			local currentProfile = MSBTProfiles.currentProfile
			local eventSettings = currentProfile.events.INCOMING_HEAL
			if not eventSettings or eventSettings.disabled then
				return
			end
			local critSettings = currentProfile.events.INCOMING_HEAL_CRIT

			local message = BuildActionMessage(eventSettings, queued.totalAmount)
			if not message or message == "" then
				return
			end

			local routeCritSeparately = false
			if queued.critCount and queued.critCount > 0 and critSettings and not critSettings.disabled then
				local normalScrollArea = eventSettings.scrollArea
				local critScrollArea = critSettings.scrollArea
				routeCritSeparately = normalScrollArea and critScrollArea and (normalScrollArea ~= critScrollArea)
			end

			if routeCritSeparately then
				local critAmount = queued.critAmount or 0
				if critAmount > queued.totalAmount then
					critAmount = queued.totalAmount
				end

				local nonCritCount = queued.hitCount - queued.critCount
				local nonCritAmount = queued.totalAmount - critAmount
				if nonCritCount > 0 and nonCritAmount > 0 then
					local nonCritMessage = BuildActionMessage(eventSettings, nonCritAmount)
					if nonCritMessage and nonCritMessage ~= "" then
						local nonCritSummary = BuildHitSummary(nonCritCount, 0, true)
						if nonCritSummary then
							nonCritMessage = nonCritMessage .. nonCritSummary
						end
						if queued.sourceName and queued.sourceName ~= "" and queued.sourceName ~= UNKNOWN then
							nonCritMessage = string_format("%s - %s", nonCritMessage, queued.sourceName)
						end
						if queued.healSourceLabel and queued.healSourceLabel ~= "" then
							nonCritMessage = string_format("%s [%s]", nonCritMessage, queued.healSourceLabel)
						end
						DisplayEvent(eventSettings, nonCritMessage, queued.effectTexture)
					end
				end

				if queued.critCount > 0 and critAmount > 0 then
					local critMessage = BuildActionMessage(critSettings, critAmount)
					if critMessage and critMessage ~= "" then
						local critSummary = BuildHitSummary(queued.critCount, queued.critCount, true)
						if critSummary then
							critMessage = critMessage .. critSummary
						end
						if queued.sourceName and queued.sourceName ~= "" and queued.sourceName ~= UNKNOWN then
							critMessage = string_format("%s - %s", critMessage, queued.sourceName)
						end
						if queued.healSourceLabel and queued.healSourceLabel ~= "" then
							critMessage = string_format("%s [%s]", critMessage, queued.healSourceLabel)
						end
						DisplayEvent(critSettings, critMessage, queued.effectTexture)
					end
				end
				return
			end

			local summary = BuildHitSummary(queued.hitCount, queued.critCount, true)
			if summary then
				message = message .. summary
			end
			if queued.sourceName and queued.sourceName ~= "" and queued.sourceName ~= UNKNOWN then
				message = string_format("%s - %s", message, queued.sourceName)
			end
			if queued.healSourceLabel and queued.healSourceLabel ~= "" then
				message = string_format("%s [%s]", message, queued.healSourceLabel)
			end

			local displaySettings = eventSettings
			if queued.critCount and queued.critCount > 0 then
				displaySettings = {}
				for k, v in pairs(eventSettings) do
					displaySettings[k] = v
				end
				displaySettings.isCrit = true
				local baseSize = eventSettings.fontSize or currentProfile.normalFontSize or 26
				displaySettings.fontSize = math_floor((baseSize * 1.5) + 0.5)
			end
			DisplayEvent(displaySettings, message, queued.effectTexture)
		end)
	end

	batch.hitCount = batch.hitCount + 1
	batch.totalAmount = batch.totalAmount + normalizedAmount
	if isCrit then
		batch.critCount = batch.critCount + 1
		batch.critAmount = batch.critAmount + normalizedAmount
	end
	if effectTexture and not batch.effectTexture then
		batch.effectTexture = effectTexture
	end
	if sourceName and sourceName ~= "" and sourceName ~= UNKNOWN then
		if batch.sourceName and batch.sourceName ~= sourceName then
			batch.sourceName = "multiple"
		elseif not batch.sourceName then
			batch.sourceName = sourceName
		end
	end
	if healSourceLabel and healSourceLabel ~= "" then
		batch.healSourceLabel = healSourceLabel
	end
end

function eventFrame:UNIT_SPELLCAST_SUCCEEDED(unitID, lineID, spellID)
	if unitID == "player" and spellID then
		lastPlayerSpellID = spellID
		lastPlayerSpellTime = GetTime()
		local timedDuration = DOT_FALLBACK_TIMED_SPELLS[spellID]
		if timedDuration then
			lastDotFallbackSpellID = spellID
			lastDotFallbackAuraIDs = nil
			lastDotFallbackRequireAura = false
			lastDotFallbackExpire = lastPlayerSpellTime + timedDuration
			return
		end
		local dotAuraIDs = DOT_FALLBACK_SPELLS[spellID]
		if dotAuraIDs then
			lastDotFallbackSpellID = spellID
			lastDotFallbackAuraIDs = dotAuraIDs
			lastDotFallbackRequireAura = true
			lastDotFallbackExpire = lastPlayerSpellTime + DOT_FALLBACK_DURATION
		end
	end
end

function eventFrame:UNIT_COMBAT(unitTarget, action, flagText, amount, schoolMask)
	local normalizedAmount = NormalizeNumber(amount)
	local isDamageEvent = action == "WOUND"
	local isHealEvent = action == "HEAL"
	local isCritEvent = (flagText == "CRITICAL")

	local currentProfile = MSBTProfiles.currentProfile

	if unitTarget == "player" then
		if isDamageEvent then
			if not normalizedAmount or normalizedAmount <= 0 then
				return
			end
			local eventSettings = currentProfile.events.INCOMING_DAMAGE
			if not eventSettings or eventSettings.disabled then
				return
			end

			local damageSource = GetIncomingDamageSourceLabel(flagText, schoolMask)
			QueueIncomingDamageBatch(normalizedAmount, isCritEvent, damageSource)
		elseif isHealEvent then
			if not normalizedAmount or normalizedAmount <= 0 then
				return
			end

			local eventSettings = currentProfile.events.INCOMING_HEAL
			if not eventSettings or eventSettings.disabled then
				return
			end

			local now = GetTime()
			local sourceName = StripRealm(GetLikelyIncomingHealSourceName())
			local playerName = StripRealm(UnitName("player"))
			local isLikelySelfHeal = sourceName and playerName and sourceName == playerName

			local attributionWindow = 1.5
			if isLikelySelfHeal then
				attributionWindow = INCOMING_SELF_HEAL_ICON_ATTRIBUTION_WINDOW
			end

			local healEffectTexture
			if lastPlayerSpellID and not IsAutoAttackSpellID(lastPlayerSpellID) and (now - lastPlayerSpellTime) <= attributionWindow then
				_, _, healEffectTexture = GetSpellInfo(lastPlayerSpellID)
			end

			local healSourceLabel = GetIncomingHealSourceLabel(flagText, schoolMask)
			QueueIncomingHealBatch(normalizedAmount, isCritEvent, healEffectTexture, sourceName, healSourceLabel)
		else
			local eventSettings = currentProfile.events["INCOMING_" .. tostring(action or "")]
			if eventSettings and not eventSettings.disabled then
				local message = BuildActionMessage(eventSettings, normalizedAmount)
				if message and message ~= "" then
					DisplayEvent(eventSettings, message)
				end
			end
		end
		return
	end

	if unitTarget == "target" then
		if not InCombatLockdown() then
			return
		end

		local effectTexture
		local spellIDUsed
		local now = GetTime()
		if lastPlayerSpellID and (now - lastPlayerSpellTime) <= OUTGOING_FALLBACK_ATTRIBUTION_WINDOW then
			spellIDUsed = lastPlayerSpellID
			_, _, effectTexture = GetSpellInfo(lastPlayerSpellID)
		end
		if not effectTexture and isDamageEvent and lastPlayerSpellID and not IsAutoAttackSpellID(lastPlayerSpellID) and (now - lastPlayerSpellTime) <= OUTGOING_DELAYED_SPELL_ATTRIBUTION_WINDOW then
			-- Allow delayed spell effects (for example Ignite ticks) to keep spell attribution.
			spellIDUsed = lastPlayerSpellID
			_, _, effectTexture = GetSpellInfo(lastPlayerSpellID)
		end
		if not effectTexture then
			local dotFallbackActive = isDamageEvent and lastDotFallbackSpellID and now <= lastDotFallbackExpire
			if dotFallbackActive and ((not lastDotFallbackRequireAura) or HasPlayerAnyDebuffOnTarget(lastDotFallbackAuraIDs)) then
				spellIDUsed = lastDotFallbackSpellID
				_, _, effectTexture = GetSpellInfo(lastDotFallbackSpellID)
			end
		end
		if not effectTexture then
			-- In DamageMeter mode, do not fall back to auto-shot attribution.
			if IsDamageMeterOutgoingActive() then
				if (not isDamageEvent) or (not CanUseAutoAttackFallback(now)) then
					return
				end
			end
			spellIDUsed = AUTOSHOT_SPELL_ID
			_, _, effectTexture = GetSpellInfo(AUTOSHOT_SPELL_ID)
		end

		if isDamageEvent then
			if not normalizedAmount or normalizedAmount <= 0 then
				return
			end

			-- In DamageMeter hybrid mode, only use fallback when meter deltas are stale.
			if IsDamageMeterOutgoingActive() then
				if IsDamageMeterDeltaFresh(now) and spellIDUsed ~= lastDotFallbackSpellID then
					return
				end
				if spellIDUsed == AUTOSHOT_SPELL_ID then
					lastAutoAttackFallbackTime = now
				end
				local forceIsSpell = (spellIDUsed == AUTOSHOT_SPELL_ID) and IsLikelySpellSchool(schoolMask) or nil
				QueueOutgoingBatch(spellIDUsed, normalizedAmount, isCritEvent, effectTexture, forceIsSpell)
				return
			end

			if spellIDUsed == AUTOSHOT_SPELL_ID then
				lastAutoAttackFallbackTime = now
			end
			local forceIsSpell = (spellIDUsed == AUTOSHOT_SPELL_ID) and IsLikelySpellSchool(schoolMask) or nil
			QueueOutgoingBatch(spellIDUsed, normalizedAmount, isCritEvent, effectTexture, forceIsSpell)
		else
			local eventSettings = currentProfile.events["OUTGOING_" .. tostring(action or "")]
			if eventSettings and not eventSettings.disabled then
				local message = BuildActionMessage(eventSettings, normalizedAmount)
				if message and message ~= "" then
					DisplayEvent(eventSettings, message, effectTexture)
				end
			end
		end
	end
end

local function Enable()
	local currentProfile = MSBTProfiles.currentProfile
	eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	eventFrame:RegisterEvent("UNIT_COMBAT")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	if IsDamageMeterOutgoingActive() then
		StartDamageMeterTicker()
	end

	MSBTParser.RegisterHandler(ParserEventsHandler)
end

local function Disable()
	eventFrame:Hide()
	eventFrame:UnregisterAllEvents()
	EraseTable(outgoingBatches)
	EraseTable(incomingDamageBatches)
	EraseTable(incomingHealBatches)
	EraseTable(damageMeterLastSpellTotals)
	lastDamageMeterPoll = 0
	lastDamageMeterDeltaTime = 0
	lastAutoAttackFallbackTime = 0
	lastDotFallbackSpellID = nil
	lastDotFallbackAuraIDs = nil
	lastDotFallbackRequireAura = true
	lastDotFallbackExpire = 0
	StopDamageMeterTicker()

	MSBTParser.UnregisterHandler(ParserEventsHandler)
end

eventFrame:Hide()
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)
eventFrame:SetScript("OnUpdate", OnUpdateEventFrame)

throttleFrame:Hide()
throttleFrame:SetScript("OnUpdate", OnUpdateThrottleFrame)

_, playerClass = UnitClass("player")
playerGUID = UnitGUID("player")

eventHandlers["damage"] = DamageHandler
eventHandlers["miss"] = MissHandler
eventHandlers["heal"] = HealHandler
eventHandlers["interrupt"] = InterruptHandler
eventHandlers["environmental"] = EnvironmentalHandler
eventHandlers["aura"] = AuraHandler
eventHandlers["enchant"] = EnchantHandler
eventHandlers["dispel"] = DispelHandler
eventHandlers["power"] = PowerHandler
eventHandlers["kill"] = KillHandler
eventHandlers["honor"] = HonorHandler
eventHandlers["reputation"] = ReputationHandler
eventHandlers["proficiency"] = ProficiencyHandler
eventHandlers["experience"] = ExperienceHandler
eventHandlers["extraattacks"] = ExtraAttacksHandler

for powerToken, powerType in pairs(powerTypes) do
	powerTokens[powerType] = powerToken
end

uniquePowerTypes[Enum.PowerType.HolyPower] = true
uniquePowerTypes[Enum.PowerType.Chi] = true
uniquePowerTypes[Enum.PowerType.ComboPoints] = true
uniquePowerTypes[Enum.PowerType.ArcaneCharges] = true

CreateDamageMaps()

if string_find(GetLocale(), "en..") then
	isEnglish = true
end

ignoreAuras[SPELL_BLINK] = true

ignoreAuras[SPELL_RAIN_OF_FIRE] = true

if type(SPELL_BLOOD_STRIKE) == "string" and SPELL_BLOOD_STRIKE ~= UNKNOWN then
	offHandPattern = string.gsub(SPELL_BLOOD_STRIKE, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")
end

module.damageTypeMap				= damageTypeMap
module.damageColorProfileEntries	= damageColorProfileEntries

module.Enable						= Enable
module.Disable						= Disable

MikSBT.DISPLAYTYPE_INCOMING			= "Incoming"
MikSBT.DISPLAYTYPE_OUTGOING			= "Outgoing"
MikSBT.DISPLAYTYPE_NOTIFICATION		= "Notification"
MikSBT.DISPLAYTYPE_STATIC			= "Static"

MikSBT.RegisterFont					= MSBTMedia.RegisterFont
MikSBT.RegisterAnimationStyle		= MSBTAnimations.RegisterAnimationStyle
MikSBT.RegisterStickyAnimationStyle	= MSBTAnimations.RegisterStickyAnimationStyle
MikSBT.RegisterSound				= MSBTMedia.RegisterSound
MikSBT.IterateFonts					= MSBTMedia.IterateFonts
MikSBT.IterateScrollAreas			= MSBTAnimations.IterateScrollAreas
MikSBT.IterateSounds				= MSBTMedia.IterateSounds
MikSBT.DisplayMessage				= MSBTAnimations.DisplayMessage
MikSBT.IsModDisabled				= MSBTProfiles.IsModDisabled

