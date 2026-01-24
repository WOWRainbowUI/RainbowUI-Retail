-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Parser (12.0.1 Compatible)
-- Author: Mikord (Modified for Midnight Beta by Community)
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Parser"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

local bit_band = bit.band
local bit_bor = bit.bor
local GetTime = GetTime
local UnitClass = UnitClass
local UnitGUID = UnitGUID
local UnitName = UnitName

local EraseTable = MikSBT.EraseTable
local GetSpellInfo = MikSBT.GetSpellInfo
local GetSpellTexture = MikSBT.GetSpellTexture
local Print = MikSBT.Print


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Bit flags (kept from original for compatibility).
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

-- Value when there is no GUID.
local GUID_NONE				= "0x0000000000000000"

-- Update timings.
local UNIT_MAP_UPDATE_DELAY = 0.2
local PET_UPDATE_DELAY = 1
local CLASS_HOLD_TIME = 300

-- Commonly used flag combinations.
local FLAGS_ME			= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_PLAYER)
local FLAGS_MINE		= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN)
local FLAGS_MY_GUARDIAN	= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_GUARDIAN)

-- 12.0.1 specific: Correlation window for spell casts.
local CAST_CORRELATION_WINDOW = 1.2 

-- Spells that stay active for a long duration (Ground Effects / Totems)
local PERSISTENT_SPELLS = {
	[73920]  = 12, -- Shaman: Healing Rain / Acid Rain
	[265046] = 12, -- Shaman: Earthen Wall Totem
	[10]     = 8,  -- Mage: Blizzard
	[2120]   = 8,  -- Mage: Flamestrike
	[26573]  = 10, -- Paladin: Consecration
	[145205] = 10, -- Druid: Wild Mushroom / Efflorescence
	[43265]  = 10, -- DK: Death and Decay
	[5740]   = 8,  -- Warlock: Rain of Fire
}

-- Table to track currently active ground effects
local activeGroundEffects = {}


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

local _
local eventFrame
local playerName
local playerGUID
local lastUnitMapUpdate = 0
local lastPetMapUpdate = 0
local isUnitMapStale
local isPetMapStale
local unitMap = {}
local petMap = {}
local parserEvent = {}
local handlers = {}
local classMapCleanupTime = 0
local classMap = {}
local classTimes = {}
local arenaUnits = {}
local recentCasts = {}


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

local function RegisterHandler(handler) handlers[handler] = true end
local function UnregisterHandler(handler) handlers[handler] = nil end

local function TestFlagsAny(unitFlags, testFlags)
	if bit_band(unitFlags, testFlags) > 0 then return true end
end

local function TestFlagsAll(unitFlags, testFlags)
	if bit_band(unitFlags, testFlags) == testFlags then return true end
end

local function SendParserEvent()
	for handler in pairs(handlers) do
		local success, ret = pcall(handler, parserEvent)
		if not success then geterrorhandler()(ret) end
	end
end

local function FindActiveAuraForTick(unitTarget, action)
	local filter = action == "HEAL" and "HELPFUL" or "HARMFUL"
	for i = 1, 40 do
		local aura = C_UnitAuras.GetAuraDataByIndex(unitTarget, i, filter)
		if not aura then break end
		if not issecretvalue(aura.sourceUnit) and aura.sourceUnit == "player" and aura.duration and aura.duration > 0 then
			return aura.name, aura.icon, aura.spellId
		end
	end
	return nil, nil, nil
end


-------------------------------------------------------------------------------
-- Event parsing (12.0.1 method using UNIT_COMBAT).
-------------------------------------------------------------------------------

local function ParseUnitCombat(unitTarget, action, descriptor, amount, damageType)
	if (not amount or amount == 0) and (action ~= "MISS" and action ~= "DODGE" and action ~= "PARRY" and action ~= "BLOCK" and action ~= "RESIST" and action ~= "ABSORB") then 
		return 
	end
	
	local timestamp = GetTime()
	local correlatedSpell, spellIcon, spellID
	local isFromAura = false

	-- 1. Check recent casts (Direct/Instant spells)
	for i = #recentCasts, 1, -1 do
		local cast = recentCasts[i]
		if timestamp - cast.time <= CAST_CORRELATION_WINDOW then
			correlatedSpell, spellIcon, spellID = cast.spellName, cast.icon, cast.spellID
			break
		end
	end
	
	-- 2. NEW: Check Ground Effects (Acid Rain, etc) if no instant match
	if not correlatedSpell then
		for name, data in pairs(activeGroundEffects) do
			if timestamp <= data.expires then
				correlatedSpell, spellIcon, spellID = data.name, data.icon, data.id
				break
			else
				activeGroundEffects[name] = nil -- Clean up expired
			end
		end
	end

	-- 3. Check for active DoT/HoT aura
	if not correlatedSpell then
		local auraName, auraIcon, auraSpellId = FindActiveAuraForTick(unitTarget, action)
		if auraName then
			correlatedSpell, spellIcon, spellID = auraName, auraIcon, auraSpellId
			isFromAura = true
		end
	end
	
	-- Filter Logic
	if unitTarget == "player" then
	elseif correlatedSpell then
	else
		return
	end
	
	-- Populate Event
	for key in pairs(parserEvent) do parserEvent[key] = nil end
	
	local eventType
	if action == "HEAL" then eventType = "heal"
	elseif action == "MISS" or action == "DODGE" or action == "PARRY" or action == "BLOCK" or action == "RESIST" or action == "ABSORB" then
		eventType = "miss"
		parserEvent.missType = action
	else eventType = "damage" end
	
	local isCrit = (descriptor and descriptor ~= "" and (descriptor == "CRITICAL" or descriptor:find("CRITICAL")))
	
	parserEvent.eventType = eventType
	parserEvent.amount = amount
	parserEvent.isCrit = isCrit
	parserEvent.skillName = correlatedSpell
	parserEvent.skillID = spellID
	parserEvent.skillIcon = spellIcon
	parserEvent.damageType = damageType
	
	if eventType == "heal" then
		parserEvent.isHoT = isFromAura
		parserEvent.overhealAmount = 0
	elseif eventType == "damage" then
		parserEvent.isDoT = isFromAura
		parserEvent.overkillAmount = 0
	end
	
	-- Routing Logic
	if unitTarget == "player" and correlatedSpell and eventType == "heal" then
		parserEvent.recipientGUID, parserEvent.recipientName, parserEvent.recipientFlags, parserEvent.recipientUnit = playerGUID, playerName, FLAGS_ME, "player"
		parserEvent.sourceGUID, parserEvent.sourceName, parserEvent.sourceFlags, parserEvent.sourceUnit = playerGUID, playerName, FLAGS_ME, nil
		if not classMap[playerGUID] then _, classMap[playerGUID] = UnitClass("player") end
		SendParserEvent()
		return
	elseif unitTarget == "player" then
		parserEvent.recipientGUID, parserEvent.recipientName, parserEvent.recipientFlags, parserEvent.recipientUnit = playerGUID, playerName, FLAGS_ME, "player"
		parserEvent.sourceGUID, parserEvent.sourceFlags, parserEvent.sourceUnit = GUID_NONE, OBJECT_NONE, nil
	else
		parserEvent.sourceGUID, parserEvent.sourceName, parserEvent.sourceFlags, parserEvent.sourceUnit = playerGUID, playerName, FLAGS_ME, "player" 
		local rawName = UnitName(unitTarget)
		parserEvent.recipientName = (rawName and issecretvalue(rawName)) and "Enemy" or (rawName or "Unknown")
		local rawGUID = UnitGUID(unitTarget)
		parserEvent.recipientGUID = (rawGUID and not issecretvalue(rawGUID)) and rawGUID or GUID_NONE
		parserEvent.recipientUnit = unitTarget
	end
	
	SendParserEvent()
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

local function OnUpdateDelayedInfo(this, elapsed)
	if isUnitMapStale then
		lastUnitMapUpdate = lastUnitMapUpdate + elapsed
		if lastUnitMapUpdate >= UNIT_MAP_UPDATE_DELAY then
			if not playerGUID then playerGUID = UnitGUID("player") end
			if playerGUID then
				local now = GetTime()
				for guid in pairs(unitMap) do unitMap[guid] = nil; classTimes[guid] = now + CLASS_HOLD_TIME end
				local unitPrefix = IsInRaid() and "raid" or "party"
				for i = 1, GetNumGroupMembers() do
					local uid = unitPrefix .. i; local g = UnitGUID(uid)
					if g then unitMap[g] = uid; if not classMap[g] then _, classMap[g] = UnitClass(uid) end; classTimes[g] = nil end
				end
				unitMap[playerGUID] = "player"; if not classMap[playerGUID] then _, classMap[playerGUID] = UnitClass("player") end; classTimes[playerGUID] = nil
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
				for guid in pairs(petMap) do petMap[guid] = nil; classTimes[guid] = now + CLASS_HOLD_TIME end
				local unitPrefix = IsInRaid() and "raidpet" or "partypet"
				for i = 1, GetNumGroupMembers() do
					local uid = unitPrefix .. i
					if UnitExists(uid) then
						local g = UnitGUID(uid)
						if g then petMap[g] = uid; if not classMap[g] then _, classMap[g] = UnitClass(uid) end; classTimes[g] = nil end
					end
				end
				if petName then
					local uid = "pet"; local g = UnitGUID(uid)
					if g == UnitGUID("vehicle") then uid = "player" end
					petMap[g] = uid; if not classMap[g] then _, classMap[g] = UnitClass(uid) end; classTimes[g] = nil
				end
				isPetMapStale = false
			end
			lastPetMapUpdate = 0
		end
	end
	if not isUnitMapStale and not isPetMapStale then this:Hide() end
end

local function OnEvent(this, event, arg1, arg2, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unitTarget, castGUID, spellID = arg1, arg2, ...
		if unitTarget == "player" then
			local spellInfo = C_Spell.GetSpellInfo(spellID)
			local spellName = spellInfo and spellInfo.name or "Unknown"
			local spellIcon = C_Spell.GetSpellTexture(spellID)
			local timestamp = GetTime()

			if PERSISTENT_SPELLS[spellID] then
				activeGroundEffects[spellName] = { name = spellName, icon = spellIcon, id = spellID, expires = timestamp + PERSISTENT_SPELLS[spellID] }
			end
			
			local lowerName = spellName:lower()
			if lowerName:find("mount") or lowerName:find("form") or lowerName:find("travel") or lowerName:find("flight") or lowerName:find("summon") or spellID == 150544 then
				for i = #recentCasts, 1, -1 do table.remove(recentCasts, i) end
			else
				table.insert(recentCasts, { spellID = spellID, spellName = spellName, icon = spellIcon, time = timestamp, castGUID = castGUID })
			end
			for i = #recentCasts, 1, -1 do
				if timestamp - recentCasts[i].time > CAST_CORRELATION_WINDOW then table.remove(recentCasts, i) end
			end
		end

	elseif event == "UNIT_COMBAT" then
		ParseUnitCombat(arg1, arg2, ...)

	elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_MONEY" or event == "CHAT_MSG_CURRENCY" then
		for key in pairs(parserEvent) do parserEvent[key] = nil end
		parserEvent.eventType = "loot"; parserEvent.recipientUnit = "player"
		if event == "CHAT_MSG_MONEY" then
			parserEvent.isMoney = true; parserEvent.moneyString = arg1
		elseif event == "CHAT_MSG_CURRENCY" then
			parserEvent.isCurrency = true; parserEvent.itemLink = string.match(arg1, "(|Hcurrency:.-|h.-|h)")
		else
			local link = string.match(arg1, "(|Hitem:.-|h.-|h)")
			local amt = string.match(arg1, "x(%d+)") or string.match(arg1, "%s(%d+)$")
			parserEvent.itemLink = link; parserEvent.amount = tonumber(amt) or 1
			if arg1 and string.find(arg1, "creates") then parserEvent.isCreate = true end
		end
		if parserEvent.itemLink or parserEvent.isMoney then SendParserEvent() end

	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		local mGUID = UnitGUID("mouseover")
		if mGUID and not (classMap[mGUID] and not classTimes[mGUID]) then
			classTimes[mGUID] = GetTime() + CLASS_HOLD_TIME
			if not classMap[mGUID] then _, classMap[mGUID] = UnitClass("mouseover") end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		local tGUID = UnitGUID("target")
		if tGUID and not (classMap[tGUID] and not classTimes[tGUID]) then
			local now = GetTime()
			classTimes[tGUID] = now + CLASS_HOLD_TIME
			if not classMap[tGUID] then _, classMap[tGUID] = UnitClass("target") end
		end
	elseif event == "GROUP_ROSTER_UPDATE" then isUnitMapStale = true; eventFrame:Show()
	elseif event == "UNIT_PET" then isPetMapStale = true; eventFrame:Show()
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		-- When a nameplate appears, ensure we track its class/name
		local nGUID = UnitGUID(arg1)
		if nGUID and not classMap[nGUID] then
			_, classMap[nGUID] = UnitClass(arg1)
		end
	end 
end

local function Enable()
	eventFrame:RegisterEvent("UNIT_COMBAT")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	eventFrame:RegisterEvent("CHAT_MSG_LOOT")
	eventFrame:RegisterEvent("CHAT_MSG_MONEY")
	eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
	eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventFrame:RegisterEvent("UNIT_PET")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	-- 12.0.1 FIX: Listen for nameplate events to catch non-targeted damage
	eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	isUnitMapStale = true; isPetMapStale = true; eventFrame:Show()
end

local function Disable()
	eventFrame:Hide()
	eventFrame:UnregisterAllEvents()
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo)
playerName = UnitName("player")
playerGUID = UnitGUID("player")


-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

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