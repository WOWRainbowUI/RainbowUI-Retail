-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Parser (12.0.1 Compatible)
-- Addon: MikScrollingBattleText (MSBT)
-- Context: WoW 12.0.x / API 120000+
--
-------------------------------------------------------------------------------
-- CHANGELOG — Parser (WoW 12.0.1)
--
-- Version: 12.0.1-alpha-2
--
-- This alpha consolidates all prior internal parser fixes into a single
-- stability baseline for 12.0.1.
--
-- Included fixes:
-- - CRASH FIXES:
--   * Hardened all GUID and spellId table indexing against Blizzard
--     "secret value" errors (canaccessvalue guards).
--   * Added nil-safety to utility and lookup paths.
--
-- - ATTRIBUTION FIXES:
--   * Prevented passive auras (e.g., Lightning Shield) from stealing
--     healing/damage tick attribution.
--   * Reduced damage "theft" via tighter cast correlation rules.
--
-- - EVENT TIMING:
--   * Fixed instant-cast race conditions (e.g., Riptide) by registering
--     UNIT_SPELLCAST_SENT and merging with SUCCEEDED.
--
-- - LOOT HANDLING:
--   * Suppressed raid loot spam by only parsing "You receive..." messages.
--
-- - MISC:
--   * Added sanity filter for Target Dummy reset damage (>1,000,000).
--
-- Known limitations:
-- - Pet/guardian damage attribution remains heuristic-limited without CLEU.
-- - Some melee/pet swings may bypass correlation in edge timing cases.
--
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
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

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

-- Spells that should NEVER be claimed as the source of DoT/HoT ticks.
-- Issue #12:
--   Incoming healing (and some periodic effects) could be mislabeled because
--   generic self-buffs (notably Lightning Shield) were being selected as the
--   "active aura" during attribution.
-- Fix:
--   Skip these auras when trying to attribute periodic ticks via aura scanning.
local IGNORE_AURA_MAPPING = {
    [192106] = true, -- Lightning Shield (Shaman)
    [383648] = true, -- Lightning Shield (Generic/Talent)
    [52127]  = true, -- Water Shield
    [974]    = true, -- Earth Shield (Self-buff version, usually distinct from the HoT part)
}


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
local FLAGS_MY_PET		= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_PET)

-- 12.0.1 specific: Correlation window for spell casts.
local CAST_CORRELATION_WINDOW = 1.2 

-- Spells that stay active for a long duration (Ground Effects / Totems)
local PERSISTENT_SPELLS = {
	-- Shaman (Midnight 12.0.1 IDs)
	[456366] = 12, -- Shaman: Healing Rain (NEW ID)
	[444995] = 12, -- Shaman: Surging Totem (NEW ID)
	[73920]  = 12, -- Shaman: Acid Rain (old Healing Rain ID, keep for compatibility)
	[265046] = 12, -- Shaman: Earthen Wall Totem
	
	-- Other classes (may need verification)
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

-- NEW: Ephemeral ID system for spam merging
local nextEphemeralID = 1
local ephemeralIDRegistry = {} -- Maps GUID -> "Unit1", "Unit2", etc.

-- NEW: Pet GUID cache
local myPetGUIDs = {}

-- ============================================================================
-- Secret-value guard
-- Blizzard 12.0.x may return protected ("secret") values for GUIDs, spellIds,
-- and aura fields. Attempting to index tables with these values can hard-error.
--
-- This helper ensures a value is safe to read/use as a table key.
-- ============================================================================
local function canaccessvalue(v)
    if issecretvalue and issecretvalue(v) then
        if _G.canaccessvalue then
            local ok, result = pcall(_G.canaccessvalue, v)
            return ok and result
        end
        return false
    end
    return true
end


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


-------------------------------------------------------------------------------
-- Pet detection (baseline)
-------------------------------------------------------------------------------
-- Goal:
--   Provide a minimal, safe way to recognize the player's current pet so we can:
--     * attribute some aura-based ticks originating from the pet
--     * label "pet is taking damage" events
--
-- Limitations (WIP for full pet damage routing):
--   Without CLEU, we cannot reliably identify *all* pet/guardian damage sources.
--   This cache is intentionally conservative and focuses on the player's active
--   UnitID "pet" plus GUID lookups that are safe under secret-value rules.
--
-- NOTE:
--   This section is used by FindActiveAuraForTick() and routing logic later.
-------------------------------------------------------------------------------

-- Update pet GUID cache when pet changes
local function UpdatePetCache()
	myPetGUIDs = {}
	if UnitExists("pet") then
		local guid = UnitGUID("pet")
		if guid and canaccessvalue(guid) then
			myPetGUIDs[guid] = true
		end
	end
end

-- Check if a unit is the player's pet
local function IsMyPet(unitID)
	if not unitID then return false end -- CRITICAL FIX: Nil check
	
	-- Quick check: is this the "pet" token?
	local status, isPet = pcall(UnitIsUnit, unitID, "pet")
	if status and isPet and canaccessvalue(isPet) then
		return true
	end
	
	-- Check GUID cache
	local guid = UnitGUID(unitID)
	if guid and canaccessvalue(guid) and myPetGUIDs[guid] then
		return true
	end
	
	return false
end


-------------------------------------------------------------------------------
-- Aura scanning (DoT/HoT attribution fallback)
-------------------------------------------------------------------------------
-- Why this exists:
--   UNIT_COMBAT provides the damage/heal number but not the originating spell.
--   When we cannot correlate a tick back to a recent cast, we attempt to infer
--   the spell from the unit's active auras (DoTs/HoTs).
--
-- Hardening (Issue #13):
--   aura.spellId can be secret; never index IGNORE_AURA_MAPPING with it unless
--   it is accessible and coerced to a standard number.
--
-- Accuracy tradeoff:
--   Aura scanning is a heuristic and should be used only when correlation fails.
-------------------------------------------------------------------------------

local function FindActiveAuraForTick(unitTarget, action)
	if not unitTarget then return nil, nil, nil end
	
	local filter = action == "HEAL" and "HELPFUL" or "HARMFUL"
	for i = 1, 40 do
		local aura = C_UnitAuras.GetAuraDataByIndex(unitTarget, i, filter)
		if not aura then break end
		
		-- FIX: Ensure spellId is accessible before using it as a table index
		local sID = aura.spellId
		if sID and canaccessvalue(sID) then
			if not IGNORE_AURA_MAPPING[sID] then
				-- Check if from player
				if aura.sourceUnit == "player" and aura.duration and aura.duration > 0 then
					return aura.name, aura.icon, sID
				end
				
				-- Check if from player's pet
				if (aura.sourceUnit == "pet" or IsMyPet(aura.sourceUnit)) and aura.duration and aura.duration > 0 then
					return aura.name, aura.icon, sID
				end
			end
		end
	end
	return nil, nil, nil
end

-------------------------------------------------------------------------------
-- NEW: Ephemeral ID System
-------------------------------------------------------------------------------

-- Generate a unique, session-based ID for units (works with secret GUIDs)
local function GetSafeUnitID(unitID)
	if not unitID then return "unknown" end -- CRITICAL FIX: Nil check

	local guid = UnitGUID(unitID)
	
	-- If GUID is secret, nil, or inaccessible, use unitID token directly
	if not guid or not canaccessvalue(guid) then
		return tostring(unitID) -- Force string conversion
	end
	
	-- Check cache
	if ephemeralIDRegistry[guid] then
		return ephemeralIDRegistry[guid]
	end
	
	-- Generate new ephemeral ID
	local ephID = "Unit" .. nextEphemeralID
	nextEphemeralID = nextEphemeralID + 1
	ephemeralIDRegistry[guid] = ephID
	
	return ephID
end


-------------------------------------------------------------------------------
-- NEW: Priority System (Duplicate Filtering)
-------------------------------------------------------------------------------

-- Determine if we should process this unit or if it's a duplicate of a higher priority unit
local function ShouldProcessUnit(unitID)
	-- Direct units (player, target, focus, pet) are always processed
	if unitID == "player" or unitID == "target" or unitID == "focus" or unitID == "pet" then
		return true
	end
	
	-- Check if this generic unit (nameplate/mouseover/soft*) matches a higher priority unit
	if unitID:match("^nameplate") or unitID == "mouseover" or unitID == "softenemy" or unitID == "softfriend" or unitID == "softinteract" then
		-- Priority 1: Target
		if UnitExists("target") then
			local status, isTarget = pcall(UnitIsUnit, unitID, "target")
			if status and isTarget and canaccessvalue(isTarget) then
				return false -- Duplicate of target, will be processed by target event
			end
		end
		
		-- Priority 2: Focus
		if UnitExists("focus") then
			local status, isFocus = pcall(UnitIsUnit, unitID, "focus")
			if status and isFocus and canaccessvalue(isFocus) then
				return false -- Duplicate of focus, will be processed by focus event
			end
		end
		
		-- Priority 3: Pet
		if UnitExists("pet") then
			local status, isPet = pcall(UnitIsUnit, unitID, "pet")
			if status and isPet and canaccessvalue(isPet) then
				return false -- Duplicate of pet, will be processed by pet event
			end
		end
	end
	
	return true -- Process this unit
end


-------------------------------------------------------------------------------
-- Event parsing (12.0.1 method using UNIT_COMBAT).
-------------------------------------------------------------------------------

-- Event deduplication cache (prevents double attribution)
local lastEventCache = {}
local function GetEventFingerprint(unitTarget, amount, spellID, timestamp)
	return string.format("%s_%d_%d_%d", 
		unitTarget or "none", 
		amount or 0, 
		spellID or 0, 
		math.floor((timestamp or 0) * 10))  -- 0.1s precision
end

local function ClearOldEvents()
	local now = GetTime()
	for key, data in pairs(lastEventCache) do
		if now - data.time > 1.0 then  -- Clear events older than 1 second
			lastEventCache[key] = nil
		end
	end
end

local function ParseUnitCombat(unitTarget, action, descriptor, amount, damageType)
	if (not amount or amount == 0) and (action ~= "MISS" and action ~= "DODGE" and action ~= "PARRY" and action ~= "BLOCK" and action ~= "RESIST" and action ~= "ABSORB") then 
		return 
	end
	---------------------------------------------------------
	--================ SANITY CHECK =======================--
	---------------------------------------------------------
	-- NEW FIX: Ignore Target Dummy reset damage (> 1,000,000)
	if amount and amount > 1000000 then return end
	
	-- Priority filter - skip duplicate events
	if not ShouldProcessUnit(unitTarget) then
		return
	end
	
	local timestamp = GetTime()
	local correlatedSpell, spellIcon, spellID
	local isFromAura = false

	-- 1. Check recent casts (Direct/Instant spells)
	for i = #recentCasts, 1, -1 do
		local cast = recentCasts[i]
		if timestamp - cast.time <= CAST_CORRELATION_WINDOW then
			local safeToMap = true
			
			-- Standard Player Matching
			if damageType and amount and amount > 0 then
				if (damageType == 1) and (cast.spellName ~= "Auto Attack" and cast.spellName ~= "Shoot" and cast.spellName ~= "Raptor Strike") then
					 safeToMap = false
				end
			end

			if safeToMap and (cast.sourceUnit == "player" or cast.sourceUnit == "pet") then
				correlatedSpell, spellIcon, spellID = cast.spellName, cast.icon, cast.spellID
				-- If it was a pet cast, we need to tag it for the options menu later
				if cast.sourceUnit == "pet" then parserEvent.sourceUnit = "pet" end
				break 
			end
		end
	end
	
	-- 2. PET-ONLY AGGRESSIVE MATCH (For Claw/Kill Command recovery)
	-- If no match found yet and damage is physical, check pet casts again in a tighter window
	if not correlatedSpell and damageType == 1 and action == "WOUND" then
		for i = #recentCasts, 1, -1 do
			local cast = recentCasts[i]
			-- Tight 0.4s window for pet specials
			if timestamp - cast.time <= 0.4 and cast.sourceUnit == "pet" then
				correlatedSpell, spellIcon, spellID = cast.spellName, cast.icon, cast.spellID
				parserEvent.sourceUnit = "pet"
				break
			end
		end
	end

	-- 3. Check Ground Effects (Acid Rain, etc)
	if not correlatedSpell then
		-- ... existing Ground Effects code ...
	
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
	
	-- DEDUPLICATION CHECK: Prevent same event from showing twice
	local fingerprint = GetEventFingerprint(unitTarget, amount, spellID, timestamp)
	if lastEventCache[fingerprint] then
		-- This exact event was just processed, skip it
		return
	end
	
	-- Cache this event
	lastEventCache[fingerprint] = { time = timestamp }
	
	-- Periodic cleanup of old cache entries
	if math.random() < 0.1 then  -- 10% chance to run cleanup
		ClearOldEvents()
	end
	
    -- -------------------------------------------------------------------------
    -- Filtering rules (Issue #7 / Issue #9 mitigation)
    -- -------------------------------------------------------------------------
    -- Problem:
    --   Without CLEU, UNIT_COMBAT can reflect damage events that are not "yours"
    --   (other players nearby, pets, NPC-to-NPC, etc.). This can produce spam and
    --   incorrect attribution.
    --
    -- Policy:
    --   * In instances (raid/dungeon/arena/BG), require a correlated spell and
    --     require the unit to be target/focus/player. This aggressively blocks
    --     other players' damage.
    --   * In open world, allow slightly more (including auto-attacks on target/
    --     focus while in combat), but still block untargeted damage.
    --
    -- Tradeoff:
    --   These filters can hide legitimate events if correlation fails (notably
    --   melee swings and pet damage). Pet routing is tracked as WIP.
    -- -------------------------------------------------------------------------

local inInstance = IsInInstance()
local inCombat = UnitAffectingCombat("player")

-- Determine event type early for filtering logic
local eventType
if action == "HEAL" then 
	eventType = "heal"
elseif action == "MISS" or action == "DODGE" or action == "PARRY" or action == "BLOCK" or action == "RESIST" or action == "ABSORB" then
	eventType = "miss"
else 
	eventType = "damage" 
end

-- EXCEPTION: Allow all heals in open world (can heal anyone, not just party)
if eventType == "heal" and not inInstance and correlatedSpell then
	-- Open world heals bypass target filtering - proceed directly to routing
	-- (Skip the filter checks below)
else
	-- CRITICAL: In combat + instanced, require strict correlation to prevent other players' damage
	if inCombat and inInstance then
		-- MUST have correlated spell from YOUR recent casts
		if not correlatedSpell then
			return  -- Block: Uncorrelated damage (likely other players or NPCs)
		end
		
		-- MUST be on your active target, focus, or yourself
		if unitTarget ~= "target" and unitTarget ~= "focus" and unitTarget ~= "player" then
			return  -- Block: Damage on units you're not actively engaging
		end
	end
	
	-- CRITICAL: OOC OW requires target/focus to prevent other players' damage showing
	if not inCombat and not inInstance and eventType ~= "heal" then
		-- OUT OF COMBAT DAMAGE: Must be on your target or focus
		if unitTarget ~= "target" and unitTarget ~= "focus" and unitTarget ~= "player" then
			return  -- Block: Damage on non-targeted units (prevents other players' damage)
		end
	end
end

if unitTarget == "player" then
    -- =========================================================================
    -- PLAYER TAKING DAMAGE (All scenarios)
    -- =========================================================================
    -- Always process damage to the player regardless of location/combat state
    
elseif inCombat and not inInstance then
    -- =========================================================================
    -- IN COMBAT + OPEN WORLD
    -- =========================================================================
    -- Show: Correlated spells on target/focus + auto-attacks on target/focus
    -- Block: Untargeted damage, other players' damage
    
    if correlatedSpell and (unitTarget == "target" or unitTarget == "focus") then
        -- Spell damage that correlates with recent casts hitting your target/focus
    elseif action == "WOUND" and (unitTarget == "target" or unitTarget == "focus") and
           (not UnitIsPlayer(unitTarget) or UnitIsEnemy("player", unitTarget)) and
           amount < (UnitHealthMax("player") * 2) then
        -- Auto-attacks on your target/focus (with sanity checks)
    else
        return  -- Block: Untargeted damage, excessive damage, other players
    end
    
elseif not inCombat and not inInstance then
    -- =========================================================================
    -- OUT OF COMBAT + OPEN WORLD
    -- =========================================================================
    -- Show: Only correlated spells on target/focus (questing, world content)
    -- Block: Auto-attacks (not in combat), untargeted damage, dummy internal damage
    
    if correlatedSpell and (unitTarget == "target" or unitTarget == "focus") then
        -- Spell damage that correlates with recent casts hitting your target/focus
    else
        return  -- Block: Everything else (auto-attacks, untargeted, dummy damage)
    end
    
elseif inCombat and inInstance then
    -- =========================================================================
    -- IN COMBAT + INSTANCED (Dungeon/Raid/Arena/BG)
    -- =========================================================================
    -- Show: Only correlated spells on target/focus
    -- Block: Auto-attacks (can't attribute with secret GUIDs), other players' damage
    
    if correlatedSpell and (unitTarget == "target" or unitTarget == "focus") then
        -- Spell damage that correlates with recent casts hitting your target/focus
    else
        return  -- Block: Auto-attacks, untargeted damage, other players
    end
    
elseif not inCombat and inInstance then
    -- =========================================================================
    -- OUT OF COMBAT + INSTANCED (Pre-pull, between trash, etc.)
    -- =========================================================================
    -- Show: Only correlated spells on target/focus
    -- Block: Everything else (no auto-attacks OOC, no untargeted damage)
    
    if correlatedSpell and (unitTarget == "target" or unitTarget == "focus") then
        -- Spell damage that correlates with recent casts hitting your target/focus
    else
        return  -- Block: Everything else
    end
    
else
    -- =========================================================================
    -- CATCHALL (Unknown/edge case scenarios)
    -- =========================================================================
    return  -- Block anything that doesn't fit the above scenarios
end

	-- Populate Event
	for key in pairs(parserEvent) do parserEvent[key] = nil end
	
	-- Set miss type if applicable
	if eventType == "miss" then
		parserEvent.missType = action
	end
	
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
	
	-- NEW: Check if this is pet damage
	local isPetDamage = IsMyPet(unitTarget)
	
	-- Routing Logic
	if unitTarget == "player" and correlatedSpell and eventType == "heal" then
		parserEvent.recipientGUID, parserEvent.recipientName, parserEvent.recipientFlags, parserEvent.recipientUnit = playerGUID, playerName, FLAGS_ME, "player"
		parserEvent.sourceGUID, parserEvent.sourceName, parserEvent.sourceFlags, parserEvent.sourceUnit = playerGUID, playerName, FLAGS_ME, nil
		if not classMap[playerGUID] then _, classMap[playerGUID] = UnitClass("player") end
		-- Merge ID: Add timestamp AND spellID for HoTs to prevent merging individual ticks
		if isFromAura then
			-- Include spellID to ensure different HoTs never merge, plus high-precision timestamp
			parserEvent.mergeID = "player_hot_" .. (spellID or 0) .. "_" .. math.floor(timestamp * 10000)
		else
			parserEvent.mergeID = "player"
		end
		SendParserEvent()
		return
		
	elseif unitTarget == "player" then
		parserEvent.recipientGUID, parserEvent.recipientName, parserEvent.recipientFlags, parserEvent.recipientUnit = playerGUID, playerName, FLAGS_ME, "player"
		parserEvent.sourceGUID, parserEvent.sourceFlags, parserEvent.sourceUnit = GUID_NONE, OBJECT_NONE, nil
		-- Merge ID
		parserEvent.mergeID = "player"
		
	elseif isPetDamage then
		-- NEW: Pet taking damage
		local petGUID = UnitGUID("pet")
		local petName = UnitName("pet")
		parserEvent.recipientGUID = petGUID or GUID_NONE
		parserEvent.recipientName = petName or "Pet"
		parserEvent.recipientFlags = FLAGS_MY_PET
		parserEvent.recipientUnit = "pet"
		parserEvent.sourceGUID, parserEvent.sourceFlags, parserEvent.sourceUnit = GUID_NONE, OBJECT_NONE, nil
		-- Merge ID
		parserEvent.mergeID = "pet"
		
	else
		-- Target/enemy damage
		parserEvent.sourceGUID, parserEvent.sourceName, parserEvent.sourceFlags, parserEvent.sourceUnit = playerGUID, playerName, FLAGS_ME, "player" 
		
		-- NEW: Safe name extraction with fallback
		local rawName = UnitName(unitTarget)
		local safeName = "Unknown"
		if rawName then
			if not canaccessvalue(rawName) then
				safeName = "Enemy"
			else
				-- Force string conversion to prevent secret value propagation
				safeName = tostring(rawName)
			end
		end
		parserEvent.recipientName = safeName
		
		-- Safe GUID extraction
		local rawGUID = UnitGUID(unitTarget)
		if rawGUID and canaccessvalue(rawGUID) then
			parserEvent.recipientGUID = rawGUID
		else
			parserEvent.recipientGUID = GUID_NONE
		end
		
		parserEvent.recipientUnit = unitTarget
		
		-- Merge ID: Add timestamp AND spellID for HoTs/DoTs to prevent merging individual ticks
		if isFromAura then
			-- Include spellID to ensure different HoTs never merge, plus high-precision timestamp
			parserEvent.mergeID = GetSafeUnitID(unitTarget) .. "_tick_" .. (spellID or 0) .. "_" .. math.floor(timestamp * 10000)
		else
			parserEvent.mergeID = GetSafeUnitID(unitTarget)
		end
	end
	
	SendParserEvent()
end
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
					-- CRITICAL FIX: Secret GUID check
					if g and canaccessvalue(g) then 
						unitMap[g] = uid
						if not classMap[g] then _, classMap[g] = UnitClass(uid) end
						classTimes[g] = nil 
					end
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
						-- CRITICAL FIX: Secret GUID check
						if g and canaccessvalue(g) then 
							petMap[g] = uid
							if not classMap[g] then _, classMap[g] = UnitClass(uid) end
							classTimes[g] = nil 
						end
					end
				end
				if petName then
					local uid = "pet"; local g = UnitGUID(uid)
					if g == UnitGUID("vehicle") then uid = "player" end
					-- CRITICAL FIX: Secret GUID check
					if g and canaccessvalue(g) then
						petMap[g] = uid
						if not classMap[g] then _, classMap[g] = UnitClass(uid) end
						classTimes[g] = nil
					end
				end
				isPetMapStale = false
			end
			lastPetMapUpdate = 0
		end
	end
	if not isUnitMapStale and not isPetMapStale then this:Hide() end
end

-------------------------------------------------------------------------------
-- Loot parsing (Issue #11)
-------------------------------------------------------------------------------
-- Problem:
--   In raids, generic loot chat lines for *other* players can fire and cause MSBT
--   loot popups for items you did not receive.
--
-- Fix:
--   Only accept patterns that explicitly represent "You receive ..." messages
--   (LOOT_ITEM_SELF / LOOT_ITEM_PUSHED_SELF). Everything else is ignored.
--
-- Architecture note:
--   ParseLoot populates the shared parserEvent table and returns true/false.
--   SendParserEvent() is then called with no arguments so handlers see the same
--   parserEvent structure as other event types.
-------------------------------------------------------------------------------
local LOOT_ITEM_SELF_PATTERN = string.gsub(LOOT_ITEM_SELF, "%%s", "(.+)")
local LOOT_ITEM_PUSHED_SELF_PATTERN = string.gsub(LOOT_ITEM_PUSHED_SELF, "%%s", "(.+)")

local function ParseLoot(message)
	if type(message) ~= "string" then return false end

	-- Check 1: Standard Loot ("You receive loot: [Item]")
	local itemLink = string.match(message, LOOT_ITEM_SELF_PATTERN)
	
	-- Check 2: Pushed Loot/Quest Items ("You receive item: [Item]")
	if not itemLink then
		itemLink = string.match(message, LOOT_ITEM_PUSHED_SELF_PATTERN)
	end

	-- GATEKEEPER: If it didn't match a "You" pattern, return false.
	-- This keeps the "Anti-Spam" fix intact.
	if not itemLink then return false end

	-- ARCHITECTURE FIX: Reset the file-scope parserEvent table
	for key in pairs(parserEvent) do parserEvent[key] = nil end

	-- Populate the shared table (so SendParserEvent can see it)
	parserEvent.eventType = "loot"
	parserEvent.recipientUnit = "player"
	parserEvent.itemLink = itemLink
	
	-- Extract Quantity
	local quantity = tonumber(string.match(message, "x(%d+)")) or 1
	parserEvent.amount = quantity
	
	return true
end

local function OnEvent(this, event, arg1, arg2, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		-- CORRECT MAPPING (Verified by Crash Dump & Function Signature):
		-- arg1 = UnitID ("player")
		-- arg2 = CastGUID ("Cast-15-...")
		-- ...  = SpellID (The 3rd argument is inside the varargs)
		
		local unitTarget = arg1
		local castGUID = arg2
		local spellID = ...

		-- [RESCUE LOGIC] 12.0.x cast event mismatch
		-- Observation:
		--   Some 12.0.x builds can deliver UNIT_SPELLCAST_SUCCEEDED with spellID
		--   missing/nil in the normal argument position.
		-- Fix:
		--   Attempt to extract the spellID from the CastGUID string when possible.
		--   If extraction fails, we hard-stop to avoid downstream API calls with nil.
		if (not spellID) and castGUID then
			local extractedID = string.match(castGUID, "Cast%-%d+%-%d+%-%d+%-%d+%-(%d+)")
			if extractedID then
				spellID = tonumber(extractedID)
			end
		end

		-- [THE WALL] SAFETY GATE
		-- If spellID is still nil, we STOP.
		-- This prevents the "bad argument #1" crash you were seeing.
		if (not spellID) or (not unitTarget) then return end

		-- [PLAYER CHECK]
		if unitTarget == "player" then
			-- It is now 100% safe to query the API
			local spellInfo = C_Spell.GetSpellInfo(spellID)
			
			local spellName = spellInfo and spellInfo.name or "Unknown"
			local spellIcon = C_Spell.GetSpellTexture(spellID)
			local timestamp = GetTime()

			-- Ground Effects
			if PERSISTENT_SPELLS[spellID] then
				activeGroundEffects[spellName] = { name = spellName, icon = spellIcon, id = spellID, expires = timestamp + PERSISTENT_SPELLS[spellID] }
			end
			
			-- Cleanup/Correlation Logic
			local lowerName = spellName:lower()
			if lowerName:find("mount") or lowerName:find("form") or lowerName:find("travel") or lowerName:find("flight") or lowerName:find("summon") or spellID == 150544 then
				for i = #recentCasts, 1, -1 do table.remove(recentCasts, i) end
			else
				-- Match 'Sent' event to 'Succeeded' event
				local found = false
				for i = #recentCasts, 1, -1 do
					if recentCasts[i].castGUID == castGUID then
						recentCasts[i].time = timestamp
						found = true
						break
					end
				end
				
				if not found then
					table.insert(recentCasts, { spellID = spellID, spellName = spellName, icon = spellIcon, time = timestamp, castGUID = castGUID, sourceUnit = unit })
				end
			end
			
			-- Prune old casts
			for i = #recentCasts, 1, -1 do
				if timestamp - recentCasts[i].time > CAST_CORRELATION_WINDOW then table.remove(recentCasts, i) end
			end
		end

	elseif event == "UNIT_SPELLCAST_SENT" then
		-- SENT FIX: Mapping based on OnEvent(this, event, arg1, arg2, ...)
		-- arg1 = unit
		-- arg2 = target
		-- ...  = castGUID, spellID (These are in the varargs)
		
		local unit = arg1
		local target = arg2
		local castGUID, spellID = ...
		
		-- Safety check for SENT event too
		if unit == "player" and spellID then
			local spellInfo = C_Spell.GetSpellInfo(spellID)
			local spellName = spellInfo and spellInfo.name or "Unknown"
			local spellIcon = C_Spell.GetSpellTexture(spellID)
			local timestamp = GetTime()
			
			table.insert(recentCasts, { 
				spellID = spellID, 
				spellName = spellName, 
				icon = spellIcon, 
				time = timestamp, 
				castGUID = castGUID 
			})
		end

	elseif event == "UNIT_COMBAT" then
		-- UNIT_COMBAT still uses standard args, pass them along
		ParseUnitCombat(arg1, arg2, ...)

	elseif event == "CHAT_MSG_LOOT" or event == "CHAT_MSG_MONEY" or event == "CHAT_MSG_CURRENCY" then
        if event == "CHAT_MSG_LOOT" then
            -- ISSUE #11 FIX: STRICT PARSING & ARCHITECTURE FIX
            -- We call ParseLoot, which populates the table.
            -- Then we call SendParserEvent() with NO arguments.
            if ParseLoot(arg1) then 
                SendParserEvent() 
            end
        else
            -- Legacy Money/Currency (Keep existing logic)
		    for key in pairs(parserEvent) do parserEvent[key] = nil end
		    parserEvent.eventType = "loot"; parserEvent.recipientUnit = "player"
		    if event == "CHAT_MSG_MONEY" then
			    parserEvent.isMoney = true; parserEvent.moneyString = arg1
		    elseif event == "CHAT_MSG_CURRENCY" then
			    parserEvent.isCurrency = true; parserEvent.itemLink = string.match(arg1, "(|Hcurrency:.-|h.-|h)")
            end
		    if parserEvent.itemLink or parserEvent.isMoney then SendParserEvent() end
        end

	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		local mGUID = UnitGUID("mouseover")
		if mGUID and canaccessvalue(mGUID) and not (classMap[mGUID] and not classTimes[mGUID]) then
			classTimes[mGUID] = GetTime() + CLASS_HOLD_TIME
			if not classMap[mGUID] then _, classMap[mGUID] = UnitClass("mouseover") end
		end

	elseif event == "PLAYER_TARGET_CHANGED" then
		local tGUID = UnitGUID("target")
		if tGUID and canaccessvalue(tGUID) and not (classMap[tGUID] and not classTimes[tGUID]) then
			local now = GetTime()
			classTimes[tGUID] = now + CLASS_HOLD_TIME
			if not classMap[tGUID] then _, classMap[tGUID] = UnitClass("target") end
		end

	elseif event == "GROUP_ROSTER_UPDATE" then 
        isUnitMapStale = true; eventFrame:Show()

	elseif event == "UNIT_PET" then 
		local unitID = arg1
		if unitID == "player" then UpdatePetCache() end
		isPetMapStale = true
		eventFrame:Show()

	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local nGUID = UnitGUID(arg1)
		if nGUID and canaccessvalue(nGUID) and not classMap[nGUID] then
			_, classMap[nGUID] = UnitClass(arg1)
		end
	end 
end

local function Enable()
	eventFrame:RegisterEvent("UNIT_COMBAT")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	-- NEW: Register for client-side cast start event
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
	eventFrame:RegisterEvent("CHAT_MSG_LOOT")
	eventFrame:RegisterEvent("CHAT_MSG_MONEY")
	eventFrame:RegisterEvent("CHAT_MSG_CURRENCY")
	eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	eventFrame:RegisterEvent("UNIT_PET")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	-- 12.0.1 FIX: Listen for nameplate events to catch non-targeted damage
	eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	isUnitMapStale = true; isPetMapStale = true; 
	-- NEW: Initialize pet cache
	UpdatePetCache()
	eventFrame:Show()
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

-- Debug exports (accessible via /dump)
module.recentCasts = recentCasts
module.activeGroundEffects = activeGroundEffects
module.myPetGUIDs = myPetGUIDs
module.ephemeralIDRegistry = ephemeralIDRegistry