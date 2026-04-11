
local module = {}
local moduleName = "Parser"
MikSBT[moduleName] = module

local string_find = string.find
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_len = string.len
local bit_band = bit.band
local bit_bor = bit.bor
local GetTime = GetTime
local UnitClass = UnitClass
local UnitGUID = UnitGUID
local UnitName = UnitName

local EraseTable = MikSBT.EraseTable
local GetSpellInfo = MikSBT.GetSpellInfo
local Print = MikSBT.Print

local Obliterate = GetSpellInfo(49020)
local FrostStrike = GetSpellInfo(49143)
local Stormstrike = GetSpellInfo(17364)

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsCataClassic = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC

local AFFILIATION_MINE		= 0x00000001
local AFFILIATION_PARTY		= 0x00000002
local AFFILIATION_RAID		= 0x00000004
local AFFILIATION_OUTSIDER	= 0x00000008
local REACTION_FRIENDLY		= 0x00000010
local REACTION_NEUTRAL		= 0x00000020
local REACTION_HOSTILE		= 0x00000040
local CONTROL_HUMAN			= 0x00000100
local CONTROL_SERVER		= 0x00000200
local UNITTYPE_PLAYER		= 0x00000400
local UNITTYPE_NPC			= 0x00000800
local UNITTYPE_PET			= 0x00001000
local UNITTYPE_GUARDIAN		= 0x00002000
local UNITTYPE_OBJECT		= 0x00004000
local TARGET_TARGET			= 0x00010000
local TARGET_FOCUS			= 0x00020000
local OBJECT_NONE			= 0x80000000

local GUID_NONE				= "0x0000000000000000"

local MAX_BUFFS = 40
local MAX_DEBUFFS = 40

local AURA_TYPE_BUFF = "BUFF"
local AURA_TYPE_DEBUFF = "DEBUFF"

local UNIT_MAP_UPDATE_DELAY = 0.2
local PET_UPDATE_DELAY = 1
local REFLECT_HOLD_TIME = 3
local CLASS_HOLD_TIME = 300

local FLAGS_ME			= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_PLAYER)
local FLAGS_MINE		= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN)
local FLAGS_MY_GUARDIAN	= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_GUARDIAN)

local _

local eventFrame
local isEnabled
local eventsRegistered
local deferredRegisterTicker
local parserDisabledNoticeShown

local playerName
local playerGUID

local lastUnitMapUpdate = 0
local lastPetMapUpdate = 0

local isUnitMapStale
local isPetMapStale

local unitMap = {}
local petMap = {}

local captureFuncs

local fullParseEvents

local searchMap
local searchCaptureFuncs
local rareWords = {}
local searchPatterns = {}
local captureOrders = {}

local captureTable = {}
local parserEvent = {}

local handlers = {}

local reflectedSkills = {}
local reflectedTimes = {}

local classMapCleanupTime = 0
local classMap = {}
local classTimes = {}
local arenaUnits = {}

local function RegisterHandler(handler)
	handlers[handler] = true
end

local function UnregisterHandler(handler)
	handlers[handler] = nil
end

local function TestFlagsAny(unitFlags, testFlags)
	if bit_band(unitFlags, testFlags) > 0 then
		return true
	end
end

local function TestFlagsAll(unitFlags, testFlags)
	if bit_band(unitFlags, testFlags) == testFlags then
		return true
	end
end

local function SendParserEvent()
	for handler in pairs(handlers) do
		local success, ret = pcall(handler, parserEvent)
		if not success then
			geterrorhandler()(ret)
		end
	end
end

local function GlobalStringCompareFunc(globalStringNameOne, globalStringNameTwo)

	local globalStringOne = _G[globalStringNameOne]
	local globalStringTwo = _G[globalStringNameTwo]

	local gsOneStripped = string_gsub(globalStringOne, "%%%d?%$?[sd]", "")
	local gsTwoStripped = string_gsub(globalStringTwo, "%%%d?%$?[sd]", "")

	if string_len(gsOneStripped) == string_len(gsTwoStripped) then

		local numCapturesOne = 0
		for _ in string_gmatch(globalStringOne, "%%%d?%$?[sd]") do
			numCapturesOne = numCapturesOne + 1
		end

		local numCapturesTwo = 0
		for _ in string_gmatch(globalStringTwo, "%%%d?%$?[sd]") do
			numCapturesTwo = numCapturesTwo + 1
		end

		return numCapturesOne < numCapturesTwo

	else

		return string_len(gsOneStripped) > string_len(gsTwoStripped)
	end
end

local function ConvertGlobalString(globalStringName)

	local globalString = _G[globalStringName]
	if globalString == nil then
		return
	end

	if searchPatterns[globalStringName] then
		return searchPatterns[globalStringName], captureOrders[globalStringName]
	end

	local captureOrder
	local numCaptures = 0

	local searchPattern = string.gsub(globalString, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")

	for captureIndex in string_gmatch(searchPattern, "%%(%d)%$[sd]") do
		if not captureOrder then
			captureOrder = {}
		end
		numCaptures = numCaptures + 1
		captureOrder[tonumber(captureIndex)] = numCaptures
	end

	searchPattern = string.gsub(searchPattern, "%%%d?%$?s", "(.+)")
	searchPattern = string.gsub(searchPattern, "%%%d?%$?d", "(%%d+)")

	searchPattern = string.gsub(searchPattern, "%$", "%%$")

	searchPatterns[globalStringName] = searchPattern
	captureOrders[globalStringName] = captureOrder

	return searchPattern, captureOrder
end

local function CaptureData(matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9)

	if matchStart then
		captureTable[1] = c1
		captureTable[2] = c2
		captureTable[3] = c3
		captureTable[4] = c4
		captureTable[5] = c5
		captureTable[6] = c6
		captureTable[7] = c7
		captureTable[8] = c8
		captureTable[9] = c9

		return matchEnd
	end

	return nil
end

local function ReorderCaptures(capOrder)
	local t, o = captureTable, capOrder

	t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9] = t[o[1] or 1], t[o[2] or 2], t[o[3] or 3], t[o[4] or 4], t[o[5] or 5], t[o[6] or 6], t[o[7] or 7], t[o[8] or 8], t[o[9] or 9]
end

local function ParseSearchMessage(event, combatMessage)
	if not searchMap[event] then
		return
	end

	if type(combatMessage) ~= "string" then
		return
	end

	for _, globalStringName in pairs(searchMap[event]) do

		local captureFunc = searchCaptureFuncs[globalStringName]
		if captureFunc then

			local canSearch = true
			if rareWords[globalStringName] then
				local okRareWord, rareWordMatch = pcall(string_find, combatMessage, rareWords[globalStringName], 1, true)
				if not okRareWord then
					canSearch = false
				elseif not rareWordMatch then
					canSearch = false
				end
			end

			if canSearch then

				local okPattern, matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9 = pcall(string_find, combatMessage, searchPatterns[globalStringName])
				if not okPattern then
					return
				end

				matchEnd = CaptureData(matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9)

				if matchEnd then

					if captureOrders[globalStringName] then
						ReorderCaptures(captureOrders[globalStringName])
					end

					for key in pairs(parserEvent) do
						parserEvent[key] = nil
					end

					parserEvent.sourceGUID = GUID_NONE
					parserEvent.sourceFlags = OBJECT_NONE
					parserEvent.recipientGUID = playerGUID
					parserEvent.recipientName = playerName
					parserEvent.recipientFlags = FLAGS_ME
					parserEvent.recipientUnit = "player"

					captureFunc(parserEvent, captureTable)

					SendParserEvent()
					return
				end
			end
		end
	end
end

local function ParseLogMessage(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName, recipientFlags, recipientRaidFlags, ...)

	local captureFunc = captureFuncs[event]
	if not captureFunc then
		return
	end

	if sourceGUID == recipientGUID and reflectedTimes[recipientGUID] and event == "SPELL_DAMAGE" then
		local skillID = ...
		if skillID == reflectedSkills[recipientGUID] then

			reflectedTimes[recipientGUID] = nil
			reflectedSkills[recipientGUID] = nil

			sourceGUID = playerGUID
			sourceName = playerName
			sourceFlags = FLAGS_ME
		end
	end

	local sourceUnit = unitMap[sourceGUID] or petMap[sourceGUID]
	local recipientUnit = unitMap[recipientGUID] or petMap[recipientGUID]

	if not sourceUnit and TestFlagsAll(sourceFlags, FLAGS_MINE) then
		sourceUnit = TestFlagsAll(sourceFlags, FLAGS_MY_GUARDIAN) and "pet" or "player"
	end
	if not recipientUnit and TestFlagsAll(recipientFlags, FLAGS_MINE) then
		recipientUnit = TestFlagsAll(recipientFlags, FLAGS_MY_GUARDIAN) and "pet" or "player"
	end

	if not fullParseEvents[event] and sourceUnit ~= "player" and sourceUnit ~= "pet" and recipientUnit ~= "player" and recipientUnit ~= "pet" then
		return
	end

	for k in pairs(parserEvent) do
		parserEvent[k] = nil
	end

	parserEvent.sourceGUID = sourceGUID
	parserEvent.sourceName = sourceName
	parserEvent.sourceFlags = sourceFlags
	parserEvent.sourceUnit = sourceUnit
	parserEvent.recipientGUID = recipientGUID
	parserEvent.recipientName = recipientName
	parserEvent.recipientFlags = recipientFlags
	parserEvent.recipientUnit = recipientUnit

	captureFunc(parserEvent, ...)

	if parserEvent.skillID == 66198 then
		parserEvent.skillName = Obliterate
	elseif parserEvent.skillID == 66196 then
		parserEvent.skillName = FrostStrike
	elseif parserEvent.skillID == 32175 or parserEvent.skillID == 32176 then
		parserEvent.skillName = Stormstrike
	end

	if parserEvent.eventType == "miss" and parserEvent.missType == "REFLECT" and recipientUnit == "player" then

		for guid, reflectTime in pairs(reflectedTimes) do
			if timestamp - reflectTime > REFLECT_HOLD_TIME then
				reflectedTimes[guid] = nil
				reflectedSkills[guid] = nil
			end
		end

		reflectedTimes[sourceGUID] = timestamp
		reflectedSkills[sourceGUID] = parserEvent.skillID
	end

	SendParserEvent()
end

local function CreateFullParseList()
	fullParseEvents = {
		SPELL_AURA_APPLIED = true,
		SPELL_AURA_REMOVED = true,
		SPELL_AURA_APPLIED_DOSE = true,
		SPELL_AURA_REMOVED_DOSE = true,
		SPELL_CAST_START = true,
	}
end

local function CreateSearchMap()
	searchMap = {

		CHAT_MSG_COMBAT_HONOR_GAIN = {"COMBATLOG_HONORGAIN", "COMBATLOG_HONORAWARD"},

		CHAT_MSG_COMBAT_FACTION_CHANGE = {"FACTION_STANDING_INCREASED", "FACTION_STANDING_DECREASED"},

		CHAT_MSG_SKILL = {"SKILL_RANK_UP"},

		CHAT_MSG_COMBAT_XP_GAIN = {"COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"},

		CHAT_MSG_LOOT = {
			"LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
			"LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_SELF"
		},

		CHAT_MSG_MONEY = {"YOU_LOOT_MONEY", "LOOT_MONEY_SPLIT"},

		CHAT_MSG_CURRENCY = { "CURRENCY_GAINED", "CURRENCY_GAINED_MULTIPLE", "CURRENCY_GAINED_MULTIPLE_BONUS" },
	}

	for event, map in pairs(searchMap) do

		for i = #map, 1, -1 do
			if not _G[map[i]] then
				table.remove(map, i)
			end
		end

		table.sort(map, GlobalStringCompareFunc)
	end
end

local function CreateSearchCaptureFuncs()
	searchCaptureFuncs = {

		COMBATLOG_HONORAWARD = function(p, c) p.eventType, p.amount = "honor", c[1] end,
		COMBATLOG_HONORGAIN = function(p, c) p.eventType, p.sourceName, p.sourceRank, p.amount = "honor", c[1], c[2], c[3] end,

		COMBATLOG_XPGAIN_FIRSTPERSON = function(p, c) p.eventType, p.sourceName, p.amount = "experience", c[1], c[2] end,
		COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = function(p, c) p.eventType, p.amount = "experience", c[1] end,

		FACTION_STANDING_DECREASED = function(p, c) p.eventType, p.isLoss, p.factionName, p.amount = "reputation", true, c[1], c[2] end,
		FACTION_STANDING_INCREASED = function(p, c) p.eventType, p.factionName, p.amount = "reputation", c[1], c[2] end,
		FACTION_STANDING_DECREASED_ACCOUNT_WIDE = function(p, c) p.eventType, p.isLoss, p.factionName, p.amount = "reputation", true, c[1], c[2] end,
		FACTION_STANDING_INCREASED_ACCOUNT_WIDE = function(p, c) p.eventType, p.factionName, p.amount = "reputation", c[1], c[2] end,

		SKILL_RANK_UP = function(p, c) p.eventType, p.skillName, p.amount = "proficiency", c[1], c[2] end,

		LOOT_ITEM_SELF = function(p, c) p.eventType, p.itemLink, p.amount = "loot", c[1], c[2] end,
		LOOT_ITEM_CREATED_SELF = function(p, c) p.eventType, p.isCreate, p.itemLink, p.amount = "loot", true, c[1], c[2] end,
		LOOT_MONEY_SPLIT = function(p, c) p.eventType, p.isMoney, p.moneyString = "loot", true, c[1] end,
		CURRENCY_GAINED = function(p, c) p.eventType, p.isCurrency, p.itemLink, p.amount = "loot", true, c[1], c[2] end,
	}

	if not IsRetail then
		searchCaptureFuncs["FACTION_STANDING_DECREASED_ACCOUNT_WIDE"] = nil
		searchCaptureFuncs["FACTION_STANDING_INCREASED_ACCOUNT_WIDE"] = nil
	end

	searchCaptureFuncs["LOOT_ITEM_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_SELF"]
	searchCaptureFuncs["LOOT_ITEM_CREATED_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
	searchCaptureFuncs["LOOT_ITEM_PUSHED_SELF"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
	searchCaptureFuncs["LOOT_ITEM_PUSHED_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
	searchCaptureFuncs["YOU_LOOT_MONEY"] = searchCaptureFuncs["LOOT_MONEY_SPLIT"]
	searchCaptureFuncs["CURRENCY_GAINED_MULTIPLE"] = searchCaptureFuncs["CURRENCY_GAINED"]
	searchCaptureFuncs["CURRENCY_GAINED_MULTIPLE_BONUS"] = searchCaptureFuncs["CURRENCY_GAINED"]

	for globalStringName in pairs(searchCaptureFuncs) do
		if not _G[globalStringName] then
			Print("Unable to find global string: " .. globalStringName, 1, 0, 0)
			searchCaptureFuncs[globalStringName] = nil
		end
	end
end

local function FindRareWords()

	local wordCounts = {}

	for globalStringName in pairs(searchCaptureFuncs) do

		local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "")

		for word in string_gmatch(strippedGS, "%w+") do
			wordCounts[word] = (wordCounts[word] or 0) + 1
		end
	end

	for globalStringName in pairs(searchCaptureFuncs) do
		local leastSeen, rarestWord

		local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "")

		for word in string_gmatch(strippedGS, "%w+") do
			if not leastSeen or wordCounts[word] < leastSeen then
				leastSeen = wordCounts[word]
				rarestWord = word
			end
		end

		rareWords[globalStringName] = rarestWord
	end
end

local function ValidateRareWords()

	for globalStringName, rareWord in pairs(rareWords) do

		if not string_find(_G[globalStringName], rareWord, 1, true) then
			rareWords[globalStringName] = nil
		end
	end
end

local function ConvertGlobalStrings()

	for globalStringName in pairs(searchCaptureFuncs) do

		searchPatterns[globalStringName] = "^" .. ConvertGlobalString(globalStringName)
	end
end

local function CreateCaptureFuncs()
	captureFuncs = {

		SWING_DAMAGE = function(p, ...) p.eventType, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "damage", ... end,
		RANGE_DAMAGE = function(p, ...) p.eventType, p.isRange, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing, p.isOffHand = "damage", true, ... end,
		SPELL_DAMAGE = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing, p.isOffHand = "damage", ... end,
		SPELL_PERIODIC_DAMAGE = function(p, ...) p.eventType, p.isDoT, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing, p.isOffHand = "damage", true, ... end,
		SPELL_BUILDING_DAMAGE = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "damage", ... end,
		DAMAGE_SHIELD = function(p, ...) p.eventType, p.isDamageShield, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "damage", true, ... end,

		SWING_MISSED = function(p, ...) p.eventType, p.missType, p.isOffHand, p.amount = "miss", ... end,
		RANGE_MISSED = function(p, ...) p.eventType, p.isRange, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", true, ... end,
		SPELL_MISSED = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", ... end,
		SPELL_PERIODIC_MISSED = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", ... end,
		DAMAGE_SHIELD_MISSED = function(p, ...) p.eventType, p.isDamageShield, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", true, ... end,
		SPELL_DISPEL_FAILED = function(p, ...) p.eventType, p.missType, p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool = "miss", "RESIST", ... end,

		SPELL_HEAL = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount, p.overhealAmount, p.absorbAmount, p.isCrit = "heal", ... end,
		SPELL_PERIODIC_HEAL = function(p, ...) p.eventType, p.isHoT, p.skillID, p.skillName, p.skillSchool, p.amount, p.overhealAmount, p.absorbAmount, p.isCrit = "heal", true, ... end,

		ENVIRONMENTAL_DAMAGE = function(p, ...) p.eventType, p.hazardType, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "environmental", ... end,

		SPELL_ENERGIZE = function(p, ...) p.eventType, p.isGain, p.skillID, p.skillName, p.skillSchool, p.amount, p.overEnergized, p.powerType = "power", true, ... p.amount = floor(p.amount * 10 + 0.5) / 10 end,
		SPELL_DRAIN = function(p, ...) p.eventType, p.isDrain, p.skillID, p.skillName, p.skillSchool, p.amount, p.powerType, p.extraAmount = "power", true, ... end,
		SPELL_LEECH = function(p, ...) p.eventType, p.isLeech, p.skillID, p.skillName, p.skillSchool, p.amount, p.powerType, p.extraAmount = "power", true, ... end,

		SPELL_INTERRUPT = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool = "interrupt", ... end,

		SPELL_AURA_APPLIED = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", ... end,
		SPELL_AURA_APPLIED_DOSE = function(p, ...) p.eventType, p.isDose, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", true, ... end,
		SPELL_AURA_REMOVED = function(p, ...) p.eventType, p.isFade, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", true, ... end,
		SPELL_AURA_REMOVED_DOSE = function(p, ...) p.eventType, p.isFade, p.isDose, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", true, true, ... end,

		ENCHANT_APPLIED = function(p, ...) p.eventType, p.skillName, p.itemID, p.itemName = "enchant", ... end,
		ENCHANT_REMOVED = function(p, ...) p.eventType, p.isFade, p.skillName, p.itemID, p.itemName = "enchant", true, ... end,

		SPELL_DISPEL = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool, p.auraType = "dispel", ... end,

		SPELL_CAST_START = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool = "cast", ... end,

		PARTY_KILL = function(p, ...) p.eventType = "kill" end,

		SPELL_EXTRA_ATTACKS = function(p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount = "extraattacks", ... end,
	}

	captureFuncs["DAMAGE_SPLIT"] = captureFuncs["SPELL_DAMAGE"]
	captureFuncs["SPELL_PERIODIC_MISSED"] = captureFuncs["SPELL_MISSED"]
	captureFuncs["SPELL_PERIODIC_ENERGIZE"] = captureFuncs["SPELL_ENERGIZE"]
	captureFuncs["SPELL_PERIODIC_DRAIN"] = captureFuncs["SPELL_DRAIN"]
	captureFuncs["SPELL_PERIODIC_LEECH"] = captureFuncs["SPELL_LEECH"]
	captureFuncs["SPELL_STOLEN"] = captureFuncs["SPELL_DISPEL"]

	module.captureFuncs = captureFuncs
end

local function OnUpdateDelayedInfo(this, elapsed)

	if isUnitMapStale then

		lastUnitMapUpdate = lastUnitMapUpdate + elapsed

		if lastUnitMapUpdate >= UNIT_MAP_UPDATE_DELAY then

			if not playerGUID then
				playerGUID = UnitGUID("player")
			end
			if playerGUID then

				local now = GetTime()
				for guid in pairs(unitMap) do
					unitMap[guid] = nil
					classTimes[guid] = now + CLASS_HOLD_TIME
				end

				local unitPrefix = IsInRaid() and "raid" or "party"
				local numGroupMembers = GetNumGroupMembers()
				for i = 1, numGroupMembers do
					local unitID = unitPrefix .. i

					local guid = UnitGUID(unitID)
					if guid then
						unitMap[guid] = unitID
						if not classMap[guid] then
							_, classMap[guid] = UnitClass(unitID)
						end
						classTimes[guid] = nil
					end
				end

				unitMap[playerGUID] = "player"
				if not classMap[playerGUID] then
					_, classMap[playerGUID] = UnitClass("player")
				end
				classTimes[playerGUID] = nil

				isUnitMapStale = false
			end

			lastUnitMapUpdate = 0
		end
	end

	if isPetMapStale then

		lastPetMapUpdate = lastPetMapUpdate + elapsed

		if lastPetMapUpdate >= PET_UPDATE_DELAY then

			local petName = UnitName("pet")
			if not petName or petName ~= UNKNOWN then

				local now = GetTime()
				for guid in pairs(petMap) do
					petMap[guid] = nil
					classTimes[guid] = now + CLASS_HOLD_TIME
				end

				local unitPrefix = IsInRaid() and "raidpet" or "partypet"
				local numGroupMembers = GetNumGroupMembers()
				for i = 1, numGroupMembers do
					local unitID = unitPrefix .. i
					if UnitExists(unitID) then

						local guid = UnitGUID(unitID)
						if guid ~= nil then
							petMap[guid] = unitID
							if not classMap[guid] then
								_, classMap[guid] = UnitClass(unitID)
							end
							classTimes[guid] = nil
						end
					end
				end

				if petName then
					local unitID = "pet"
					local guid = UnitGUID(unitID)
					if guid == UnitGUID("vehicle") then
						unitID = "player"
					end
					petMap[guid] = unitID
					if not classMap[guid] then
						_, classMap[guid] = UnitClass(unitID)
					end
					classTimes[guid] = nil
				end

				isPetMapStale = false
			end

			lastPetMapUpdate = 0
		end
	end

	if not isUnitMapStale and not isPetMapStale then
		this:Hide()
	end
end

local function OnEvent(this, event, arg1, arg2, ...)
	if not isEnabled then
		return
	end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		ParseLogMessage(CombatLogGetCurrentEventInfo())

	elseif event == "UPDATE_MOUSEOVER_UNIT" then

		local mouseoverGUID = UnitGUID("mouseover")
		if not mouseoverGUID then
			return
		end

		if classMap[mouseoverGUID] and not classTimes[mouseoverGUID] then
			return
		end

		classTimes[mouseoverGUID] = GetTime() + CLASS_HOLD_TIME
		if not classMap[mouseoverGUID] then
			_, classMap[mouseoverGUID] = UnitClass("mouseover")
		end

	elseif event == "PLAYER_TARGET_CHANGED" then

		local targetGUID = UnitGUID("target")
		if not targetGUID then
			return
		end

		if classMap[targetGUID] and not classTimes[targetGUID] then
			return
		end

		local now = GetTime()
		classTimes[targetGUID] = now + CLASS_HOLD_TIME
		if not classMap[targetGUID] then
			_, classMap[targetGUID] = UnitClass("target")
		end

		if now >= classMapCleanupTime then
			for guid, cleanupTime in pairs(classTimes) do
				if now >= cleanupTime then
					classMap[guid] = nil
					classTimes[guid] = nil
				end
			end

			classMapCleanupTime = now + CLASS_HOLD_TIME
		end

	elseif event == "GROUP_ROSTER_UPDATE" then

		isUnitMapStale = true
		eventFrame:Show()

	elseif event == "UNIT_PET" then
		isPetMapStale = true
		eventFrame:Show()

	elseif event == "ARENA_OPPONENT_UPDATE" then

		if arg2 == "seen" then
			local arenaGUID = UnitGUID(arg1)
			if not arenaGUID then
				return
			end
			arenaUnits[arg1] = arenaGUID
			_, classMap[arenaGUID] = UnitClass(arg1)

		elseif arg2 == "cleared" then
			local arenaGUID = arenaUnits[arg1]
			if not arenaGUID then
				return
			end
			arenaUnits[arg1] = nil
			classMap[arenaGUID] = nil
		end

	else
		ParseSearchMessage(event, arg1)
	end
end

local function SafeRegisterEvent(frame, event) end

local function TryRegisterEvents()
	for event in pairs(searchMap) do
		eventFrame:RegisterEvent(event)
	end
	eventsRegistered = true
	return true
end

local function Enable()
	if not eventsRegistered then
		local ok = TryRegisterEvents()
		if not ok then
			if not parserDisabledNoticeShown then
				MikSBT.Print("Parser-driven features are disabled due Blizzard protected event restrictions.")
				parserDisabledNoticeShown = true
			end
			isEnabled = false
			eventFrame:Hide()
			return
		end
	end

	isUnitMapStale = true
	isPetMapStale = true

	isEnabled = true

	eventFrame:Show()
end

local function Disable()
	isEnabled = false
	if deferredRegisterTicker then
		deferredRegisterTicker:Cancel()
		deferredRegisterTicker = nil
	end

	eventFrame:Hide()

	EraseTable(reflectedTimes)
	EraseTable(reflectedSkills)
end

eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo)

playerName = UnitName("player")
playerGUID = UnitGUID("player")

CreateSearchMap()
CreateSearchCaptureFuncs()
CreateCaptureFuncs()

CreateFullParseList()

FindRareWords()
ValidateRareWords()

ConvertGlobalStrings()

module.AFFILIATION_MINE		= AFFILIATION_MINE
module.AFFILIATION_PARTY	= AFFILIATION_PARTY
module.AFFILIATION_RAID		= AFFILIATION_RAID
module.AFFILIATION_OUTSIDER	= AFFILIATION_OUTSIDER
module.REACTION_FRIENDLY	= REACTION_FRIENDLY
module.REACTION_NEUTRAL		= REACTION_NEUTRAL
module.REACTION_HOSTILE		= REACTION_HOSTILE
module.CONTROL_HUMAN		= CONTROL_HUMAN
module.CONTROL_SERVER		= CONTROL_SERVER
module.UNITTYPE_PLAYER		= UNITTYPE_PLAYER
module.UNITTYPE_NPC			= UNITTYPE_NPC
module.UNITTYPE_PET			= UNITTYPE_PET
module.UNITTYPE_GUARDIAN	= UNITTYPE_GUARDIAN
module.UNITTYPE_OBJECT		= UNITTYPE_OBJECT
module.TARGET_TARGET		= TARGET_TARGET
module.TARGET_FOCUS			= TARGET_FOCUS
module.OBJECT_NONE			= OBJECT_NONE

module.unitMap = unitMap
module.classMap = classMap

module.RegisterHandler				= RegisterHandler
module.UnregisterHandler			= UnregisterHandler
module.TestFlagsAny					= TestFlagsAny
module.TestFlagsAll					= TestFlagsAll
module.Enable						= Enable
module.Disable						= Disable

