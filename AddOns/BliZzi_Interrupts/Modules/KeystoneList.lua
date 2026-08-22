--[[
================================================================================
  BliZzi Interrupts — Keystone List Module
================================================================================
  Optional Mythic+ keystone display for the party. Shows each member's owned
  keystone (dungeon + level) with a click-to-teleport button on hover.

  PROTOCOL
    Speaks "WA-KeyStGrList" on the PARTY addon channel. Compatible with the
    community Keystone Group List protocol — users running any compatible
    client see each other's keys without configuration.

  CROSS-ADDON COMPATIBILITY
    - LibOpenRaid-1.0  (cross-addon key sharing library)
    - LibKeystone      (alternative cross-addon protocol)
    Both are optional. If loaded, BIT receives keystone data from any addon
    that publishes through them.

  DEFAULT STATE
    Disabled. All paths short-circuit on `BIT.db.keystoneListEnabled == false`.
    Existing users see no UI change unless they actively enable the feature.

  TAINT SAFETY (Midnight 12.0.5)
    All bag/loot inputs that could carry tainted hyperlinks (item:180653) are
    routed through `issecretvalue`-aware refresh paths instead of being parsed.
================================================================================
]]

BIT = BIT or {}
BIT.KeystoneList = BIT.KeystoneList or {}
local KL = BIT.KeystoneList

------------------------------------------------------------
-- Constants
------------------------------------------------------------
local CHAT_PREFIX     = "WA-KeyStGrList"
local KEYSTONE_ITEM_ID = 180653            -- the keystone item ID (used by ITEM_CHANGED / CHAT_MSG_LOOT path)
local ROW_HEIGHT      = 38                  -- visual: per-entry row height
local LEVEL_BOX_W     = 42                  -- left "+XX" box width
local FRAME_WIDTH     = 250                 -- main frame width
local FRAME_PAD       = 4                   -- inner padding
local SHOW_DELAY      = 5                   -- seconds after GROUP_JOINED to start broadcasting
-- Resilient-icon atlas (golden hourglass with gem) — the standard
-- Blizzard chromie-time atlas the community keystone protocol uses.
-- We render it via SetAtlas on a dedicated Texture
-- region anchored to the row's bottom-right (badge style), instead of
-- as an inline `|A:...|a` text escape. The inline syntax is unreliable
-- across client versions; SetAtlas always works when the atlas exists.
local RESILIENT_ATLAS = "unitframeicon-chromietime"

------------------------------------------------------------
-- Dungeon → { abbr, port } map.
-- `port` is either a spellID (number) or a {Alliance, Horde} pair (table).
-- The dungeon IDs, abbreviations, and teleport spell IDs are all
-- public WoW game data — sourced from the in-game Mythic+ system
-- and the standard teleport spells exposed by C_Spell. Faction-
-- specific portals (Motherlode, Siege of Boralus) need the
-- Alliance/Horde pair for correct UnitFactionGroup() routing.
-- Adding new dungeons in future patches: append to this table; missing
-- entries fall through to "no port" gracefully.
------------------------------------------------------------
local DUNGEON_INFO = {
    -- Cataclysm
    [438] = { abbr = "VP",  port = 410080  }, -- Vortex Pinnacle
    [456] = { abbr = "TOT", port = 424142  }, -- Throne of the Tides
    [507] = { abbr = "GB",  port = 445424  }, -- Grim Batol

    -- Mists of Pandaria
    [2]   = { abbr = "TJS", port = 131204  }, -- Temple of the Jade Serpent

    -- Warlords of Draenor
    [161] = { abbr = "SR",  port = 159898  }, -- Skyreach
    [165] = { abbr = "SBG", port = 159899  }, -- Shadowmoon Burial Grounds
    [168] = { abbr = "EB",  port = 159901  }, -- The Everbloom

    -- Legion
    [198] = { abbr = "DHT", port = 424163  }, -- Darkheart Thicket
    [199] = { abbr = "BRH", port = 424153  }, -- Black Rook Hold
    [200] = { abbr = "HoV", port = 393764  }, -- Halls of Valor
    [206] = { abbr = "NL",  port = 410078  }, -- Neltharion's Lair
    [210] = { abbr = "CoS", port = 393766  }, -- Court of Stars
    [239] = { abbr = "SEAT", port = 1254551 }, -- Seat of the Triumvirate

    -- Battle for Azeroth
    [244] = { abbr = "AD",  port = 424187  }, -- Atal'Dazar
    [245] = { abbr = "FH",  port = 410071  }, -- Freehold
    [247] = { abbr = "ML",  port = { 467553, 467555 } }, -- The MOTHERLODE!! (A/H)
    [248] = { abbr = "WM",  port = 424167  }, -- Waycrest Manor
    [249] = { abbr = "KR",  port = 1286831 }, -- Kings' Rest (returns in Midnight S2; teleport added 12.1)
    [250] = { abbr = "ToS", port = 1286828 }, -- Temple of Sethraliss (returns in Midnight S2; teleport added 12.1)
    [251] = { abbr = "UNDR", port = 410074 }, -- The Underrot
    [353] = { abbr = "SoB", port = { 445418, 464256 } }, -- Siege of Boralus (A/H)
    [370] = { abbr = "WS",  port = 373274  }, -- Operation: Mechagon - Workshop

    -- Shadowlands
    [375] = { abbr = "Mists",   port = 354464 }, -- Mists of Tirna Scithe
    [376] = { abbr = "NW",      port = 354462 }, -- The Necrotic Wake
    [378] = { abbr = "HoA",     port = 354465 }, -- Halls of Atonement
    [382] = { abbr = "ToP",     port = 354467 }, -- Theater of Pain
    [391] = { abbr = "Streets", port = 367416 }, -- Tazavesh: Streets of Wonder
    [392] = { abbr = "Gambit",  port = 367416 }, -- Tazavesh: So'leah's Gambit

    -- Dragonflight
    -- Ruby Life Pools returns in Midnight S2; 12.1 adds a second teleport
    -- spell (1289780) via the new Keystone Hero achievement. We keep the
    -- original spell here (owned by everyone who unlocked it in DF) —
    -- revisit once 12.1 is live if fresh unlocks only learn the new ID.
    [399] = { abbr = "RLP",  port = 393256 }, -- Ruby Life Pools
    [400] = { abbr = "NO",   port = 393262 }, -- The Nokhud Offensive
    [401] = { abbr = "AV",   port = 393279 }, -- The Azure Vault
    [402] = { abbr = "AA",   port = 393273 }, -- Algeth'ar Academy
    [403] = { abbr = "ULD",  port = 393222 }, -- Uldaman: Legacy of Tyr
    [404] = { abbr = "NELT", port = 393276 }, -- Neltharus
    [405] = { abbr = "BH",   port = 393267 }, -- Brackenhide Hollow
    [406] = { abbr = "HOI",  port = 393283 }, -- Halls of Infusion
    [463] = { abbr = "DOTI Fall", port = 424197 }, -- Dawn of the Infinite: Galakrond's Fall
    [464] = { abbr = "DOTI Rise", port = 424197 }, -- Dawn of the Infinite: Murozond's Rise

    -- The War Within
    [499] = { abbr = "PSF", port = 445444 }, -- Priory of the Sacred Flame
    [500] = { abbr = "RO",  port = 445443 }, -- The Rookery
    [501] = { abbr = "SV",  port = 445269 }, -- The Stonevault
    [502] = { abbr = "CoT", port = 445416 }, -- City of Threads
    [503] = { abbr = "AK",  port = 445417 }, -- Ara-Kara, City of Echoes
    [504] = { abbr = "DC",  port = 445441 }, -- Darkflame Cleft
    [505] = { abbr = "DB",  port = 445414 }, -- The Dawnbreaker
    [506] = { abbr = "CM",  port = 445440 }, -- Cinderbrew Meadery
    [525] = { abbr = "FG",  port = 1216786 }, -- Operation: Floodgate
    [542] = { abbr = "ED",  port = 1237215 }, -- Eco-Dome Al'dani

    -- Midnight
    [556] = { abbr = "PoS", port = 1254555 }, -- Pit of Saron
    [557] = { abbr = "WS",  port = 1254400 }, -- Windrunner Spire
    [558] = { abbr = "MT",  port = 1254572 }, -- Magisters' Terrace
    [559] = { abbr = "NPX", port = 1254563 }, -- Nexus-Point Xenas
    [560] = { abbr = "MC",  port = 1254559 }, -- Maisara Caverns
    [583] = { abbr = "SEAT", port = 1254551 }, -- Seat of the Triumvirate

    -- Midnight Season 2 (patch 12.1). Added ahead of the patch so the
    -- list works on day one; teleports are the 12.1 Keystone Hero spells.
    [584] = { abbr = "BV",  port = 1286801 }, -- The Blinding Vale
    [585] = { abbr = "VA",  port = 1286804 }, -- Voidscar Arena
    [586] = { abbr = "DoN", port = 1286807 }, -- Den of Nalorakk
    [587] = { abbr = "MR",  port = 1286809 }, -- Murder Row
    [588] = { abbr = "AoF", port = 1286812 }, -- Altar of Fangs (new dungeon in 12.1)
}

-- Midnight Season 2 rotation (goes live with 12.1). The test layout
-- prefers these maps so the upcoming pool is preview-able before the
-- season starts; entries the current client can't resolve to a name yet
-- (GetMapUIInfo returns nil on pre-12.1 builds, e.g. Altar of Fangs)
-- are skipped at runtime.
local SEASON2_MAPS = { 587, 586, 584, 585, 588, 399, 250, 249 }

------------------------------------------------------------
-- State
------------------------------------------------------------
local keystonesDB           = {}    -- fullName → keystone object
local nativClients          = {}    -- fullName → true (has BIT or a compatible Keystone Group List client)
local personalResiliencyLevel = 0
local mainFrame             = nil
local rowPool               = {}
local activeRows            = {}
local hoverButton           = nil   -- single insecure action button
local challengeModeActive   = false
local visibilityShow        = true  -- internal show flag — gates visible UI without tearing down state
local broadcastTimer        = nil

-- Cast-progress state. Populated by event handlers later in the file
-- (UNIT_SPELLCAST_START/STOP/FAILED/INTERRUPTED/SUCCEEDED). The shared
-- OnUpdate ticker created further down reads these and animates the
-- castOverlay texture height. Declared as upvalues here so the event
-- branch and the ticker (both later in the file) share the same slots.
local _castActiveRow = nil

-- ── LFG queue-glow state ──────────────────────────────────────────────
-- When the user is signed up in the M+ Group Finder (PGF) and the queue
-- resolves into a full 5-player party, glow the matching dungeon icon in
-- the Keystone List so the user sees at a glance which dungeon they're
-- about to run. Two paths feed this:
--   • As leader: cache the activityID(s) of the player's active LFG
--     listing; when LFG_LIST_ACTIVE_ENTRY_UPDATE fires with created=false
--     and the group is full, glow that activity's mapID.
--   • As applicant: on LFG_LIST_APPLICATION_STATUS_UPDATED with newStatus
--     == "inviteaccepted", look up the searchResultID's activityID, wait
--     for GROUP_ROSTER_UPDATE to confirm a 5-person party, then glow.
-- Cleared on entering the dungeon, on leaving the party, on /reload, and
-- via a 30-minute hard-timeout safety net.
local _lfgActiveActivityIDs = nil   -- list of activityIDs of OUR current listing (leader path)
local _glowedMapID          = nil   -- which mapID is currently glowing (or nil)
local _glowAutoClearTimer   = nil   -- 30-second auto-clear timer (cancellable)
local _dungeonNameToMapID   = nil   -- lazy-built lookup: localized dungeon name → challengeMapID
-- Applicant-side "we accepted, now waiting for group to fill" state.
-- LFG_LIST_APPLICATION_STATUS_UPDATED fires only when WE accept an
-- invite — but the group may be 2/5 / 3/5 / 4/5 at that moment, with
-- the remaining members still being invited and accepting over the
-- next ~10-30 seconds. Without this state, we'd check group size 2s
-- after our accept, find < 5, and never fire because no further LFG
-- event fires for us. Instead, stash the activityID here and re-check
-- on every GROUP_ROSTER_UPDATE until the group hits 5 (or the 5-min
-- watchdog clears the state, or the user leaves the group).
local _pendingApplicantActivityID = nil
local _pendingApplicantClearTimer = nil

-- LibButtonGlow lookup, hoisted up here (above configureRow) because
-- configureRow's per-row glow application calls it. The library is
-- registered by SyncCD under "LibButtonGlowcustom" via LibStub. Lazy
-- fetch each call so addon load order doesn't matter — by the time the
-- first row gets configured, SyncCD has long since registered the lib.
-- Returning nil when the lib isn't available is fine; configureRow's
-- glow block silently no-ops in that case.
local function _GetLBG()
    if not _G.LibStub then return nil end
    local ok, lib = pcall(_G.LibStub, "LibButtonGlowcustom", true)
    if ok then return lib end
    return nil
end

------------------------------------------------------------
-- Locale shortcut
------------------------------------------------------------
local function L(key, fallback)
    local s = BIT.L and BIT.L[key]
    if s and s ~= key then return s end
    return fallback or key
end

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function isEnabled()
    return BIT.db and BIT.db.keystoneListEnabled == true
end

local function getPlayerFullName()
    local name = UnitName("player")
    local _, realm = UnitFullName("player")
    if not name then return nil end
    realm = (realm and realm ~= "") and realm or GetRealmName()
    return name .. "-" .. (realm or "")
end

local function isPlayerInMyParty(fullName)
    if not fullName then return false end
    local target = Ambiguate(fullName, "none")
    local self_  = getPlayerFullName()
    if self_ and Ambiguate(self_, "none") == target then return true end
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local n, r = UnitFullName(unit)
            if n then
                local _, selfRealm = UnitFullName("player")
                r = (r and r ~= "") and r or selfRealm or GetRealmName()
                local full = Ambiguate(n .. "-" .. (r or ""), "none")
                if full == target then return true end
            end
        end
    end
    return false
end

local function getDungeonPort(challengeMapID)
    local info = DUNGEON_INFO[challengeMapID]
    if not info then return nil end
    local port = info.port
    if not port or port == 0 then return nil end
    if type(port) == "table" then
        local faction = UnitFactionGroup("player")
        if faction == "Horde" then
            return port[2]
        end
        return port[1]
    end
    return port
end

-- English dungeon names by challengeMapID. C_ChallengeMode.GetMapUIInfo
-- already returns the CLIENT-language name (so German clients see German
-- names automatically) — this table exists only for the "Always use
-- English dungeon names" toggle, so a player on a non-English client can
-- force the English names they know from guides / LFG. Keep in sync with
-- DUNGEON_INFO; a missing entry falls back to the localized API name.
local DUNGEON_NAMES_EN = {
    [438] = "Vortex Pinnacle",
    [456] = "Throne of the Tides",
    [507] = "Grim Batol",
    [2]   = "Temple of the Jade Serpent",
    [161] = "Skyreach",
    [165] = "Shadowmoon Burial Grounds",
    [168] = "The Everbloom",
    [198] = "Darkheart Thicket",
    [199] = "Black Rook Hold",
    [200] = "Halls of Valor",
    [206] = "Neltharion's Lair",
    [210] = "Court of Stars",
    [239] = "Seat of the Triumvirate",
    [244] = "Atal'Dazar",
    [245] = "Freehold",
    [247] = "The MOTHERLODE!!",
    [248] = "Waycrest Manor",
    [249] = "Kings' Rest",
    [250] = "Temple of Sethraliss",
    [251] = "The Underrot",
    [353] = "Siege of Boralus",
    [370] = "Operation: Mechagon - Workshop",
    [375] = "Mists of Tirna Scithe",
    [376] = "The Necrotic Wake",
    [378] = "Halls of Atonement",
    [382] = "Theater of Pain",
    [391] = "Tazavesh: Streets of Wonder",
    [392] = "Tazavesh: So'leah's Gambit",
    [399] = "Ruby Life Pools",
    [400] = "The Nokhud Offensive",
    [401] = "The Azure Vault",
    [402] = "Algeth'ar Academy",
    [403] = "Uldaman: Legacy of Tyr",
    [404] = "Neltharus",
    [405] = "Brackenhide Hollow",
    [406] = "Halls of Infusion",
    [463] = "Dawn of the Infinite: Galakrond's Fall",
    [464] = "Dawn of the Infinite: Murozond's Rise",
    [499] = "Priory of the Sacred Flame",
    [500] = "The Rookery",
    [501] = "The Stonevault",
    [502] = "City of Threads",
    [503] = "Ara-Kara, City of Echoes",
    [504] = "Darkflame Cleft",
    [505] = "The Dawnbreaker",
    [506] = "Cinderbrew Meadery",
    [525] = "Operation: Floodgate",
    [542] = "Eco-Dome Al'dani",
    [556] = "Pit of Saron",
    [557] = "Windrunner Spire",
    [558] = "Magisters' Terrace",
    [559] = "Nexus-Point Xenas",
    [560] = "Maisara Caverns",
    [583] = "Seat of the Triumvirate",
    [584] = "The Blinding Vale",
    [585] = "Voidscar Arena",
    [586] = "Den of Nalorakk",
    [587] = "Murder Row",
    [588] = "Altar of Fangs",
}

local function getDungeonName(challengeMapID, useAbbr)
    if useAbbr then
        local info = DUNGEON_INFO[challengeMapID]
        if info and info.abbr then return info.abbr end
    end
    -- Force English full names regardless of client/addon language.
    if BIT.db and BIT.db.keystoneListForceEnglish then
        local en = DUNGEON_NAMES_EN[challengeMapID]
        if en then return en end
        -- No hardcoded name (e.g. a future dungeon) → fall through to
        -- the localized API name below rather than showing nothing.
    end
    if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
        local name = C_ChallengeMode.GetMapUIInfo(challengeMapID)
        return name
    end
end

local function getDungeonTexture(challengeMapID)
    if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
        local _, _, _, mapTexture = C_ChallengeMode.GetMapUIInfo(challengeMapID)
        return mapTexture
    end
end

-- Returns the wide background texture for the dungeon (the 5th return value
-- of GetMapUIInfo). Falls back to the normal mapTexture when the background
-- art isn't available.
local function getDungeonBackground(challengeMapID)
    if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
        local _, _, _, mapTexture, mapBackground = C_ChallengeMode.GetMapUIInfo(challengeMapID)
        return mapBackground or mapTexture
    end
end

local function knownSpell(spellID)
    if not spellID then return false end
    if IsPlayerSpell and IsPlayerSpell(spellID) then return true end
    if IsSpellKnown and IsSpellKnown(spellID) then return true end
    return false
end

-- Returns one of: "ready" | "noport" | "cooldown" plus remaining seconds.
-- "ready"     → teleport spell is known and not on cooldown
-- "noport"    → spell is unknown to the player (haven't unlocked it yet)
-- "cooldown"  → spell is known but currently on cooldown — ONLY reported
--               when querying the local player's keystone. Cooldowns of
--               other players aren't visible to us, so a remote keystone
--               whose teleport spell happens to be on OUR client's cooldown
--               must NOT be reported as "Port CD" — the remote player may
--               not have used it at all. Pass isSelf=true to enable the
--               cooldown check; otherwise it's collapsed to "ready".
local function getPortStatus(challengeMapID, isSelf)
    local portID = getDungeonPort(challengeMapID)
    if not portID then return "noport", 0, nil end
    if not knownSpell(portID) then return "noport", 0, portID end
    if not isSelf then
        -- For other players, we can only report "ready" or "noport".
        -- The "ready" here means "WE have the teleport unlocked" — useful
        -- to signal that we can also press it ourselves. "Port CD" is
        -- self-only.
        return "ready", 0, portID
    end
    -- C_Spell.GetSpellCooldown is the modern API; older clients have
    -- GetSpellCooldown as a global. Wrap both in pcall.
    local startTime, duration = 0, 0
    if C_Spell and C_Spell.GetSpellCooldown then
        local ok, info = pcall(C_Spell.GetSpellCooldown, portID)
        if ok and info then
            startTime, duration = info.startTime or 0, info.duration or 0
        end
    elseif _G.GetSpellCooldown then
        local ok, s, d = pcall(_G.GetSpellCooldown, portID)
        if ok then startTime, duration = s or 0, d or 0 end
    end
    if duration and duration > 1.5 then  -- > GCD threshold; ignore the GCD cooldown
        local remaining = (startTime + duration) - GetTime()
        if remaining > 0 then return "cooldown", remaining, portID end
    end
    return "ready", 0, portID
end

-- Returns the BACKGROUND color (R,G,B,A) for the level box. Uses the
-- community Keystone Group List palette: green for low keys, purple
-- for mid, gold for high, red for extreme. Text inside the box stays white.
local function colorForLevel(level)
    if not level then return 0.20, 0.20, 0.20, 0.90 end
    if level >= 30 then return 0.55, 0.10, 0.10, 0.90 end  -- red (30+)
    if level >= 25 then return 0.60, 0.50, 0.10, 0.90 end  -- gold (25-29)
    if level >= 20 then return 0.40, 0.15, 0.50, 0.90 end  -- purple (20-24)
    if level >= 10 then return 0.15, 0.45, 0.15, 0.90 end  -- green (10-19)
    return 0.30, 0.30, 0.30, 0.90                          -- gray (sub-10)
end

local function classColorize(name, classFile)
    if not name then return name or "" end
    local c = classFile and (RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS) and (RAID_CLASS_COLORS or CUSTOM_CLASS_COLORS)[classFile]
    if c then
        return string.format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, name)
    end
    return name
end

-- Apply the addon's configured font + outline (from Size & Font) to a
-- FontString, at the given pixel size. Falls back to STANDARD_TEXT_FONT
-- if no fontPath is set yet (first run before user picks a font).
local function applyConfiguredFont(fs, size)
    if not fs then return end
    local path    = (BIT.db and BIT.db.fontPath) or _G.STANDARD_TEXT_FONT
    local outline = (BIT.db and BIT.db.fontOutline) or "OUTLINE"
    -- SLUG = the client's newer GPU text renderer (crisper outlines);
    -- mirrors the flag composition in Core/Media.lua (respects the
    -- "Disable crisp text" toggle via the shared slugSuffix).
    if outline == "NONE" then
        outline = ""
    else
        outline = outline .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")
    end
    pcall(fs.SetFont, fs, path, size, outline)
end

------------------------------------------------------------
-- Resiliency level
-- Uses the standard community-protocol gate: "lowest seasonal map best".
-- A keystone is resilient if level >= 12 AND level <= personalResiliencyLevel.
------------------------------------------------------------
local function getResiliencyLevel()
    local resiliencyLevel = 0
    local seasonLowestLevel = 100
    if not (C_ChallengeMode and C_ChallengeMode.GetMapTable and C_MythicPlus and C_MythicPlus.GetSeasonBestForMap) then
        return 0
    end
    local seasonMaps = C_ChallengeMode.GetMapTable()
    if not seasonMaps then return 0 end
    for _, map in ipairs(seasonMaps) do
        local mapInfo = C_MythicPlus.GetSeasonBestForMap(map)
        local mapBestLevel = (mapInfo and mapInfo.level) or 0
        if seasonLowestLevel > mapBestLevel then seasonLowestLevel = mapBestLevel end
    end
    if seasonLowestLevel >= 12 then
        if seasonLowestLevel > personalResiliencyLevel then
            personalResiliencyLevel = seasonLowestLevel
            resiliencyLevel = personalResiliencyLevel
        else
            resiliencyLevel = personalResiliencyLevel
        end
    end
    return resiliencyLevel
end

------------------------------------------------------------
-- DB operations
------------------------------------------------------------
local function dbAddKeystone(keystone)
    if not keystone or not keystone.keystoneOwner then return end
    keystonesDB[keystone.keystoneOwner] = keystone
end

local function dbRemoveKeystone(owner)
    if not owner then return end
    keystonesDB[owner] = nil
end

local function dbGetKeystone(owner)
    if not owner then return nil end
    return keystonesDB[owner]
end

local function dbGetPersonal()
    return dbGetKeystone(getPlayerFullName())
end

local function dbSetKeystone(keystone, data)
    keystone.challengeMapID = data.challengeMapID
    keystone.keystoneLevel  = data.keystoneLevel
    keystone.activityID     = data.activityID or 0
    keystone.groupID        = data.groupID or 0
    keystone.isResilient    = data.isResilient or false
    keystone.nativClient    = nativClients[data.keystoneOwner] or false
    keystone.keystoneOwner  = data.keystoneOwner
    keystone.displayName    = data.keystoneOwner and data.keystoneOwner:match("(.+)-") or data.keystoneOwner
    keystone.class          = data.class or keystone.class  -- preserved across updates if not supplied
    return keystone
end

local function dbCreateKeystone(data)
    local k = {}
    dbSetKeystone(k, data)
    dbAddKeystone(k)
    return k
end

-- Returns (updated_bool, keystone_or_false)
local function dbUpdateKeystone(data)
    if not data or not data.challengeMapID or not data.keystoneLevel or not data.keystoneOwner then
        return false, false
    end
    local existing = dbGetKeystone(data.keystoneOwner)
    if not existing then
        local k = dbCreateKeystone(data)
        return true, k
    end
    local nativClient = nativClients[data.keystoneOwner] or false
    local sameMap     = existing.challengeMapID == data.challengeMapID
    local sameLevel   = existing.keystoneLevel  == data.keystoneLevel
    local sameNativ   = existing.nativClient    == nativClient
    local sameRes     = existing.isResilient    == (data.isResilient or false)
    if sameMap and sameLevel and sameNativ and sameRes then
        return false, existing
    end
    dbSetKeystone(existing, data)
    return true, existing
end

------------------------------------------------------------
-- Personal keystone
------------------------------------------------------------
local function getPersonalKeystoneData()
    if not (C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID) then
        return false
    end
    local challengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local activityID, groupID, keystoneLevel = nil, nil, nil
    if C_LFGList and C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel then
        local ok, a, g, l = pcall(C_LFGList.GetOwnedKeystoneActivityAndGroupAndLevel)
        if ok then
            activityID, groupID, keystoneLevel = a, g, l
        end
    end
    if not keystoneLevel and C_MythicPlus.GetOwnedKeystoneLevel then
        local ok, l = pcall(C_MythicPlus.GetOwnedKeystoneLevel)
        if ok then keystoneLevel = l end
    end
    if not challengeMapID or not keystoneLevel then return false end
    if challengeMapID == 0 or keystoneLevel == 0 then return false end
    local resiliencyLevel = getResiliencyLevel() or 0
    local isResilient = (keystoneLevel >= 12) and (keystoneLevel <= resiliencyLevel)
    local _, classFile = UnitClass("player")
    return {
        challengeMapID = challengeMapID,
        keystoneLevel  = keystoneLevel,
        activityID     = activityID or 0,
        groupID        = groupID or 0,
        isResilient    = isResilient,
        nativClient    = true,
        keystoneOwner  = getPlayerFullName(),
        class          = classFile,
    }
end

local function updatePersonalKeystone()
    local data = getPersonalKeystoneData()
    if not data then return false, false end
    return dbUpdateKeystone(data)
end

------------------------------------------------------------
-- Native clients (players who speak the Keystone Group List protocol)
------------------------------------------------------------
local function registerNativClient(name)
    if not name then return end
    nativClients[name] = true
    local k = keystonesDB[name]
    if k then k.nativClient = true end
end

local function unregisterNativClient(name)
    if not name then return end
    nativClients[name] = nil
    local k = keystonesDB[name]
    if k then k.nativClient = false end
end

------------------------------------------------------------
-- Broadcast (Send / Request) on PARTY channel
------------------------------------------------------------
local function broadcastSend()
    if not isEnabled() then return false end
    if not IsInGroup() then return false end
    local k = dbGetPersonal()
    if not k then return false end
    if not k.challengeMapID or not k.keystoneLevel then return false end
    local resBit = k.isResilient and 1 or 0
    local msg = "KSGL:Send:" .. k.challengeMapID .. ":" .. k.keystoneLevel ..
                ":" .. (k.activityID or 0) .. ":" .. (k.groupID or 0) .. ":" .. resBit
    local ok = pcall(C_ChatInfo.SendAddonMessage, CHAT_PREFIX, msg, "PARTY")
    return ok
end

local function broadcastRequest()
    if not isEnabled() then return false end
    if not IsInGroup() then return false end
    local ok = pcall(C_ChatInfo.SendAddonMessage, CHAT_PREFIX, "KSGL:Request:0", "PARTY")
    return ok
end

------------------------------------------------------------
-- OpenRaidLib + LibKeystone integration
-- Optional. If either is loaded, we receive cross-addon keystone data.
------------------------------------------------------------
local openRaidLib  = nil
local libKeystone  = nil
local _orRegistered, _lkRegistered = false, false

-- Cross-addon sources (LibOpenRaid + LibKeystone) are always enabled when
-- the libraries are present. The toggle was removed in 3.6.0 — running both
-- protocols simultaneously is the safe default since each library is
-- already opt-in by virtue of having to be loaded by another addon.
local function useOpenRaid() return true end

local function lookupExternalKeystoneData(unitName, unitRealm)
    if not openRaidLib then return false end
    if not unitName or not unitRealm then return false end
    local fullName = unitName .. "-" .. unitRealm
    if nativClients[fullName] then return false end
    local _, playerRealm = UnitFullName("player")
    local lookupName = (unitRealm == playerRealm) and unitName or fullName
    local info = openRaidLib.GetKeystoneInfo and openRaidLib.GetKeystoneInfo(lookupName)
    if not info or not info.challengeMapID or info.challengeMapID == 0 then
        return false
    end
    return {
        challengeMapID = info.challengeMapID,
        keystoneLevel  = info.level or 0,
        nativClient    = false,
        keystoneOwner  = fullName,
    }
end

local function requestExternalKeystoneData()
    if openRaidLib and useOpenRaid() and openRaidLib.RequestKeystoneDataFromParty then
        pcall(openRaidLib.RequestKeystoneDataFromParty)
    end
    if libKeystone and libKeystone.Request then
        pcall(libKeystone.Request, "PARTY")
    end
end

local function setupOpenRaidCallback()
    if _orRegistered or not openRaidLib then return end
    if not openRaidLib.RegisterCallback then return end
    -- LibOpenRaid invokes the callback as a plain function (no self),
    -- with signature: (playerName_string, perPlayerKeystoneInfo_table, allKeystones_table).
    -- Earlier versions of this file mis-typed the signature with a leading
    -- `self` arg, which caused a runtime taint: `keystoneOwner` was actually
    -- the info table and the call to `:match(...)` on it errored out.
    local handler = {}
    handler.OnKeystoneUpdate = function(playerName, info, _allKeystones)
        if not isEnabled() then return end
        if not useOpenRaid() then return end
        if type(playerName) ~= "string" or type(info) ~= "table" then return end
        local fullName = playerName
        if not fullName:match(".+%-.+") then
            local _, realm = UnitFullName("player")
            fullName = fullName .. "-" .. (realm or GetRealmName() or "")
        end
        if not isPlayerInMyParty(fullName) then return end
        if nativClients[fullName] then return end  -- prefer native protocol data
        local mapID = info.challengeMapID or 0
        local lvl   = info.level or 0
        if mapID == 0 or lvl == 0 then return end
        local updated, k = dbUpdateKeystone({
            challengeMapID = mapID,
            keystoneLevel  = lvl,
            nativClient    = false,
            keystoneOwner  = fullName,
        })
        if updated and k then KL:RebuildDisplays() end
    end
    pcall(openRaidLib.RegisterCallback, handler, "KeystoneUpdate", "OnKeystoneUpdate")
    _orRegistered = true
end

local function setupLibKeystoneCallback()
    if _lkRegistered or not libKeystone then return end
    if not libKeystone.Register then return end
    pcall(libKeystone.Register, KL, function(keyLevel, keyChallengeMapID, _, sender)
        if not isEnabled() then return end
        if not useOpenRaid() then return end  -- gated by same toggle
        if not keyLevel or not keyChallengeMapID then return end
        if keyLevel == 0 or keyChallengeMapID == 0 then return end
        local _, playerRealm = UnitFullName("player")
        local fullName = sender or ""
        if sender and not sender:match(".+%-.+") then
            fullName = sender .. "-" .. (playerRealm or GetRealmName() or "")
        end
        if not isPlayerInMyParty(fullName) then return end
        if nativClients[fullName] then return end
        if openRaidLib then
            local lookupName = fullName
            local n, r = strsplit("-", fullName)
            if r == playerRealm then lookupName = n end
            local data = openRaidLib.GetKeystoneInfo and openRaidLib.GetKeystoneInfo(lookupName)
            if data and data.challengeMapID and data.challengeMapID > 0 and data.level and data.level > 0 then
                return
            end
        end
        local updated, k = dbUpdateKeystone({
            challengeMapID = keyChallengeMapID,
            keystoneLevel  = keyLevel,
            nativClient    = false,
            keystoneOwner  = fullName,
        })
        if updated and k then KL:RebuildDisplays() end
    end)
    _lkRegistered = true
end

------------------------------------------------------------
-- UI: hover-attach teleport button
-- Single InsecureActionButton re-targets on row hover — the standard
-- pattern for taint-safe per-row click actions: we avoid creating a
-- SecureActionButton per row (which would taint the row's frame chain).
------------------------------------------------------------

-- Helper: format a remaining-cooldown number into a human string.
local function formatRemaining(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    else
        return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    end
end

-- Substitute the variable placeholders supported in port-CD announce
-- messages: {dungeon}, {abbr}, {remain}.
--
-- {level} and {player} were available in an early 3.6.4 cut but were
-- dropped before release: the chat already shows the sender name, and
-- the keystone level isn't useful in a "my port is on cooldown" message
-- (which is about the dungeon, not the run). The function still accepts
-- a `level` parameter for call-site compatibility — it just isn't
-- substituted into the template.
local function substitutePortVars(template, mapID, level, remainSec)
    if not template or template == "" then return "" end
    local fullName  = getDungeonName(mapID, false) or ("Map " .. tostring(mapID))
    local abbrName  = getDungeonName(mapID, true)  or fullName
    local out = template
    out = out:gsub("{dungeon}", fullName)
    out = out:gsub("{abbr}",    abbrName)
    out = out:gsub("{remain}",  formatRemaining(remainSec or 0))
    -- Strip any legacy {level} / {player} tokens that might still be in
    -- a user's saved custom message, so they don't appear verbatim in
    -- the chat output. The variables were never documented as stable.
    out = out:gsub("%s*{level}%s*",  " ")
    out = out:gsub("%s*{player}%s*", " ")
    return out
end

-- ── Keystone-post helpers (shift-click → chat) ────────────────────────
-- Substitution variables for the post-keystone templates. Same
-- convention as the port-CD announce: `{dungeon}` / `{abbr}` for the
-- dungeon name (full + short), `{level}` for the keystone level,
-- `{player}` for the keystone owner's display name. The {player}
-- variable resolves to the row owner — so own-key posts substitute
-- the user's own name, other-player posts substitute that player's
-- name.
--
-- {resilient} substitutes to a localized marker (e.g. "(resilient)")
-- when the keystone has the resilient flag, or to empty string when
-- not — the trailing-whitespace strip below cleans up the dangling
-- space if the variable was right-padded in the template.
local function substituteKeystonePostVars(template, mapID, level, ownerDisplayName, isResilient)
    if not template or template == "" then return "" end
    local fullName = getDungeonName(mapID, false) or ("Map " .. tostring(mapID))
    local abbrName = getDungeonName(mapID, true)  or fullName
    local resilientText = ""
    if isResilient then
        resilientText = L("KEY_POST_RESILIENT", "(resilient)")
    end
    local out = template
    out = out:gsub("{dungeon}",   fullName)
    out = out:gsub("{abbr}",      abbrName)
    out = out:gsub("{level}",     tostring(level or 0))
    out = out:gsub("{player}",    ownerDisplayName or "?")
    out = out:gsub("{resilient}", resilientText)
    -- Strip any newlines/tabs that snuck in from the multi-line editor —
    -- chat messages are single-line.
    out = out:gsub("[\r\n\t]+", " ")
    out = out:gsub("%s+", " ")
    -- Trim leading/trailing whitespace so an empty {resilient} at the
    -- end of the template doesn't leave a dangling space in chat.
    out = out:gsub("^%s+", "")
    out = out:gsub("%s+$", "")
    return out
end

-- Send a keystone-post chat line. `isOwn` selects which template to
-- pick (own vs other-player) and the matching localised default;
-- `isResilient` enables the {resilient} substitution so the marker
-- shows up in chat when the clicked row is a resilient keystone. Same
-- 5-second anti-spam throttle as the port-CD announce so a stuttery
-- shift-click doesn't double-post. No-op out of group / in test mode.
local _lastKeystonePostAt = 0
local _KEYSTONE_POST_COOLDOWN = 5
local function sendKeystonePost(mapID, level, ownerDisplayName, isOwn, isResilient)
    if KL._testMode then return end
    if not IsInGroup() then return end
    if BIT.db and BIT.db.keystoneListPostEnabled == false then return end
    local now = GetTime()
    if (now - _lastKeystonePostAt) < _KEYSTONE_POST_COOLDOWN then return end
    _lastKeystonePostAt = now
    local template
    if isOwn then
        template = (BIT.db and BIT.db.keystoneListPostOwnText) or ""
        if template == "" then
            template = L("KEY_POST_OWN_DEFAULT", "My key: {dungeon} +{level} {resilient}")
        end
    else
        template = (BIT.db and BIT.db.keystoneListPostOtherText) or ""
        if template == "" then
            template = L("KEY_POST_OTHER_DEFAULT", "{player}'s key: {dungeon} +{level} {resilient}")
        end
    end
    local msg = substituteKeystonePostVars(template, mapID, level, ownerDisplayName, isResilient)
    if msg == "" then return end
    local channel = IsInRaid() and "RAID" or "PARTY"
    pcall(SendChatMessage, msg, channel)
end

-- Send the port-CD announcement to the appropriate group chat channel.
-- Cooldown ≥ 1 minute and a one-message-per-N-seconds throttle prevent
-- spam if the user accidentally double-clicks. No-op when not in a group.
local _lastAnnounceAt = 0
local _ANNOUNCE_COOLDOWN = 5 -- seconds between announces (anti-spam)
local function sendPortCdAnnouncement(mapID, level, remainSec)
    if KL._testMode then return end
    if not IsInGroup() then return end
    local now = GetTime()
    if (now - _lastAnnounceAt) < _ANNOUNCE_COOLDOWN then return end
    _lastAnnounceAt = now
    local template = (BIT.db and BIT.db.keystoneListPortCdMessage) or ""
    if template == "" then
        template = L("KEY_PORTCD_DEFAULT", "Sorry, could I get a port please? My {dungeon} port is on cooldown ({remain} left).")
    end
    local msg = substitutePortVars(template, mapID, level, remainSec)
    if msg == "" then return end
    -- Editor allows multi-line input as a quality-of-life feature, but
    -- chat messages are single-line. Collapse any newlines / tabs that
    -- snuck in during editing into a single space so the message reads
    -- cleanly in the recipient's chat frame.
    msg = msg:gsub("[\r\n\t]+", " ")
    msg = msg:gsub("%s+", " ")
    local channel = IsInRaid() and "RAID" or "PARTY"
    pcall(SendChatMessage, msg, channel)
end

-- Which row the player last CLICKED to teleport, and when. The cast-
-- progress animation prefers this row over a spell-ID search: several
-- group members can carry the SAME dungeon key, and every one of those
-- rows shares one teleport spell — a search by spell ID alone always
-- lands on the topmost duplicate (live report: clicking the bottom row
-- animated the top one). Declared here so both the click hook below and
-- _startCastAnimation further down close over the same locals.
local _lastClickedCastRow, _lastClickedCastAt

local function ensureHoverButton()
    if hoverButton then return hoverButton end
    -- Parent the hover button to the keystone list frame, NOT to UIParent.
    -- Action-button manipulation that lives directly under UIParent has been
    -- known to leak taint into ToggleGameMenu / ClearTarget call paths in
    -- Midnight (12.0.5) — keeping the button inside our own frame chain
    -- isolates it. Falls back to UIParent on the very first hover before
    -- mainFrame exists, but in practice mainFrame is always created first.
    local parent = mainFrame or UIParent
    local btn = CreateFrame("Button", "BIT_KSGL_HoverButton", parent, "InsecureActionButtonTemplate")
    btn:RegisterForClicks("AnyDown", "AnyUp")
    btn:SetAttribute("type1", "spell")
    btn:Hide()
    btn:SetScript("OnLeave", function(self)
        self:ClearAllPoints()
        self:Hide()
    end)
    -- OnClick handler runs alongside the secure cast attempt. When the
    -- spell is on cooldown the cast fails silently — we use the click
    -- to optionally announce the cooldown to chat. Doesn't interfere
    -- with the normal cast path; the secure cast still fires when the
    -- spell is ready.
    --
    -- Shift-click branch: post the keystone info (dungeon + level, plus
    -- owner name when shift-clicking another player's row) to PARTY
    -- chat. Independent of the port-CD announce — works whether or not
    -- the port is on cooldown, and respects its own enable toggle +
    -- two configurable text templates (own / other). The cast attempt
    -- still fires on shift-click because port spells don't have a
    -- shift-modifier and we'd need a SetAttribute("shift-type1", "")
    -- to suppress it (which can't be done in combat without taint), so
    -- we let the cast happen as a side effect — clicking your own row
    -- ports + posts; clicking someone else's row attempts the cast
    -- (which silently fails if you don't know that port spell) + posts.
    btn:HookScript("OnClick", function(self)
        -- Remember the clicked ROW for the cast animation — before any
        -- early return below, and regardless of whether the cast will
        -- succeed (fires on both AnyDown and AnyUp; identical values).
        _lastClickedCastRow = self._currentRow
        _lastClickedCastAt  = GetTime()
        local mapID = self._currentMapID
        local level = self._currentLevel
        if not mapID then return end
        if IsShiftKeyDown() then
            local ownerDisplay = self._currentOwnerDisplay
            local isOwn        = self._currentIsOwn == true
            local isResilient  = self._currentIsResilient == true
            sendKeystonePost(mapID, level, ownerDisplay, isOwn, isResilient)
            return
        end
        if not BIT.db or BIT.db.keystoneListPortCdAnnounce ~= true then return end
        local status, remain, _portID = getPortStatus(mapID, true)
        if status ~= "cooldown" then return end
        sendPortCdAnnouncement(mapID, level, remain)
    end)
    hoverButton = btn
    return btn
end

-- Attach the secure click-button to a hover target. We deliberately size
-- the button to the iconBox (not the whole row) so clicking on the player
-- name or dungeon name area never fires the teleport. Skipped entirely
-- during combat — teleport spells cannot be cast in combat anyway, and
-- SetAttribute() during InCombatLockdown is the canonical taint trigger
-- that ends up attributed to the addon when the user opens the game
-- menu later (ClearTarget call path goes through tainted code).
local function attachHoverToRow(target, keystone, row)
    if not target or not keystone then return end
    if InCombatLockdown() then return end
    if not keystone.challengeMapID then return end
    local portID = getDungeonPort(keystone.challengeMapID)
    if not portID or not knownSpell(portID) then return end
    local btn = ensureHoverButton()
    btn:ClearAllPoints()
    btn:SetAllPoints(target)
    btn:SetAttribute("spell", portID)
    -- Stash the dungeon info so the OnClick hook can read it for the
    -- port-CD announce + shift-click keystone-post features. Stored
    -- on the button itself, not in a closure, because the same button
    -- is re-used across rows.
    btn._currentMapID         = keystone.challengeMapID
    btn._currentLevel         = keystone.keystoneLevel
    -- The ROW under the button, for the cast animation's clicked-row
    -- preference (duplicate keys of the same dungeon share one teleport
    -- spell, so a spell-ID search alone can't tell the rows apart).
    btn._currentRow           = row
    -- Owner identification for shift-click post. _currentIsOwn picks
    -- the right template (own vs other-player) and the display name
    -- becomes the {player} substitution when posting another player's
    -- key. Falls back to keystoneOwner if displayName is missing.
    -- _currentIsResilient drives the {resilient} substitution so the
    -- chat post can advertise that the clicked row is a resilient key.
    btn._currentOwnerDisplay  = keystone.displayName
                                or keystone.keystoneOwner
                                or "?"
    btn._currentIsOwn         = (keystone.keystoneOwner == getPlayerFullName())
    btn._currentIsResilient   = (keystone.isResilient == true)
    btn:SetFrameLevel(target:GetFrameLevel() + 1)
    btn:Show()
end

------------------------------------------------------------
-- Cast-progress helpers + shared OnUpdate ticker. Live here (below
-- the getDungeonPort / dbGetKeystone helpers, above createRow) so the
-- upvalue captures resolve cleanly to the file-locals defined above.
-- The visualization itself is a Texture child of each row's iconBox
-- (built in createRow). When the player begins a teleport channel,
-- UNIT_SPELLCAST_START finds the matching row via _findRowForCastSpell
-- and stashes start/end timestamps; the ticker shrinks/grows the
-- texture height as the cast progresses.
------------------------------------------------------------
local function _findRowForCastSpell(spellID)
    if not spellID or not activeRows then return nil end
    for i = 1, #activeRows do
        local row = activeRows[i]
        if row and row._mapID then
            local portID = getDungeonPort(row._mapID)
            if portID then
                -- pcall the equality compare — clean for local-player
                -- casts in normal builds, but defensively wrapped in
                -- case future 12.x patches taint the cast spellID.
                local ok, isMatch = pcall(function() return spellID == portID end)
                if ok and isMatch then return row end
            end
        end
    end
    return nil
end

local function _startCastAnimation(spellID)
    -- Prefer the row the player actually CLICKED. Only trusted when the
    -- click was moments ago, the row is still on screen, and its dungeon's
    -- teleport really is the spell being cast — a recycled row that shows
    -- a different dungeon by now fails the port check and falls through.
    -- The fallback search keeps casts started OUTSIDE the list (spellbook,
    -- cooldown manager) animating like before; with duplicates those can
    -- only ever pick the first row, since the spell doesn't say whose key.
    local row
    local clicked = _lastClickedCastRow
    if clicked and _lastClickedCastAt
       and (GetTime() - _lastClickedCastAt) <= 1.5
       and clicked._mapID and clicked:IsShown() then
        local portID = getDungeonPort(clicked._mapID)
        if portID then
            local ok, isMatch = pcall(function() return spellID == portID end)
            if ok and isMatch then row = clicked end
        end
    end
    row = row or _findRowForCastSpell(spellID)
    if not row then return end
    -- UnitCastingInfo returns milliseconds. Divide to align with GetTime().
    local _, _, _, startMs, endMs = UnitCastingInfo("player")
    if not startMs or not endMs or endMs <= startMs then return end
    row._castStart = startMs / 1000
    row._castEnd   = endMs   / 1000
    _castActiveRow = row
    if row.castOverlay then
        row.castOverlay:SetWidth(0)
        row.castOverlay:Show()
    end
end

local function _stopCastAnimation()
    local row = _castActiveRow
    _castActiveRow = nil
    if not row then return end
    row._castStart = nil
    row._castEnd   = nil
    if row.castOverlay then row.castOverlay:Hide() end
end

-- ~30 Hz ticker. Smooth fill animation over an 8-second channel
-- (~240 visual updates total), profiler-invisible cost. Only one row
-- at a time has an active cast (player casts one teleport at a time),
-- so no per-row loop — single state check + animate.
local _castTicker = CreateFrame("Frame")
local _castAccum  = 0
_castTicker:SetScript("OnUpdate", function(_, elapsed)
    _castAccum = _castAccum + elapsed
    if _castAccum < 0.033 then return end
    _castAccum = 0
    local row = _castActiveRow
    if not row or not row._castStart or not row._castEnd then return end
    local now   = GetTime()
    local total = row._castEnd - row._castStart
    if total <= 0 then return end
    local elapsedSec = now - row._castStart
    local ratio = elapsedSec / total
    if ratio < 0 then ratio = 0 end
    if ratio > 1 then ratio = 1 end
    local w = (row.iconBox and row.iconBox:GetWidth() or 0) * ratio
    if row.castOverlay then
        if w > 0 then
            row.castOverlay:SetWidth(w)
            row.castOverlay:Show()
        else
            row.castOverlay:Hide()
        end
    end
end)

------------------------------------------------------------
-- UI: Row creation / pool
-- Layout follows the community Keystone Group List convention:
-- dungeon mapBackground spans the row
-- behind the text, a colored level box sits on the left ("+XX" + optional
-- "no port"), and the right side has the player name (small, top) over the
-- dungeon name (large, bottom). The resilient indicator is inlined into
-- the dungeon name via |T...|t.
------------------------------------------------------------
local function createRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(FRAME_WIDTH - FRAME_PAD * 2, ROW_HEIGHT)

    -- Right side: no background. Player name and dungeon name float
    -- directly over whatever is behind the row. Each font has its own
    -- shadow / outline so it stays readable against busy backgrounds.

    -- ── Left "level box" — actually the DUNGEON ICON ──
    -- The square mapTexture (4th return of GetMapUIInfo) lives here, with
    -- the level number "+XX" overlaid centered on top. No more solid green
    -- placeholder — the dungeon icon IS the box. Uses BackdropTemplate so
    -- we can apply the same border style configured in Size & Font.
    row.iconBox = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.iconBox:SetWidth(LEVEL_BOX_W)
    -- Anchors are set per-row in configureRow because the mirror toggle
    -- can flip the iconBox between the left and right edge of the row.
    row.iconBox:EnableMouse(true)

    -- Outward-drawn border overlay. Blizzard's edgeFile draws INWARD from
    -- its frame's edges, so applying SetBackdrop directly on iconBox would
    -- eat into the icon's visible area — increasing the border size would
    -- visually shrink the icon. By drawing the border on a separate frame
    -- that's anchored slightly LARGER than iconBox (TOPLEFT(-outward, +outward),
    -- BOTTOMRIGHT(+outward, -outward) where outward = size + offset), the
    -- border sits strictly OUTSIDE the icon and the icon keeps its full
    -- size. Re-anchored each time the border settings change, see L1136 below.
    row.iconBorderOverlay = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.iconBorderOverlay:SetAllPoints(row.iconBox)
    row.iconBorderOverlay:EnableMouse(false)

    row.dungeonIcon = row.iconBox:CreateTexture(nil, "BACKGROUND")
    row.dungeonIcon:SetAllPoints()
    -- Crop the corner artifacts off square Blizzard icons
    row.dungeonIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Square invisible target for LibButtonGlow. The iconBox itself is
    -- rectangular (LEVEL_BOX_W × ROW_HEIGHT = 42 × 38), so anchoring the
    -- glow to it makes the spark / inner-glow / outer-glow textures
    -- render as horizontal rectangles — they look stretched and "off"
    -- when the rotating spark crosses its long axis. A dedicated square
    -- child frame (ROW_HEIGHT × ROW_HEIGHT, centered inside iconBox)
    -- gives LibButtonGlow square-aspect dimensions to work with so the
    -- glow renders as a clean concentric ring around the visible icon.
    row.glowTarget = CreateFrame("Frame", nil, row.iconBox)
    row.glowTarget:SetSize(ROW_HEIGHT, ROW_HEIGHT)
    row.glowTarget:SetPoint("CENTER", row.iconBox, "CENTER", 0, 0)
    row.glowTarget:EnableMouse(false)

    -- Dim overlay so the level number stays readable on bright icons
    row.iconDim = row.iconBox:CreateTexture(nil, "ARTWORK")
    row.iconDim:SetAllPoints()
    row.iconDim:SetColorTexture(0, 0, 0, 0.35)

    -- Teleport cast-progress overlay. Triggers when the player clicks
    -- a teleport icon: a "fill from left" green texture grows from
    -- empty to full over the 8-second channel duration, giving live
    -- visual feedback of the cast progress. Hidden by default; the
    -- UNIT_SPELLCAST_START handler sets _castStart/_castEnd and the
    -- ticker animates the texture width. Cancelled casts (move,
    -- stun, manual cancel) snap it back to hidden via UNIT_SPELLCAST_
    -- STOP / _FAILED / _INTERRUPTED handlers.
    --
    -- Anchored TOPLEFT+BOTTOMLEFT so SetWidth makes the texture grow
    -- rightward from the left edge of the icon, sweeping across the
    -- whole icon over the cast duration.
    --
    -- ARTWORK sub-level 2 puts it above iconDim (sub-level 0) but
    -- below the OVERLAY-layer level number, so "+XX" stays readable
    -- on top of the fill.
    row.castOverlay = row.iconBox:CreateTexture(nil, "ARTWORK", nil, 2)
    row.castOverlay:SetColorTexture(0.2, 1.0, 0.2, 0.5)  -- ready-green tint
    row.castOverlay:SetPoint("TOPLEFT",    row.iconBox, "TOPLEFT",    0, 0)
    row.castOverlay:SetPoint("BOTTOMLEFT", row.iconBox, "BOTTOMLEFT", 0, 0)
    row.castOverlay:Hide()

    -- "+XX" level number — centered in the dungeon icon, white with a
    -- thicker outline so it pops against any icon art. OVERLAY layer
    -- keeps it readable above the BACKGROUND icon, the ARTWORK dim
    -- and the ARTWORK cast-fill overlay.
    row.levelText = row.iconBox:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    row.levelText:SetPoint("CENTER", row.iconBox, "CENTER", 0, 0)
    row.levelText:SetTextColor(1, 1, 1)
    row.levelText:SetText("+0")

    -- "no port" red text at the bottom edge of the icon box
    row.noPortText = row.iconBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.noPortText:SetPoint("BOTTOM", row.iconBox, "BOTTOM", 0, 1)
    row.noPortText:SetTextColor(1, 0.25, 0.25)
    row.noPortText:SetText("")
    row.noPortText:Hide()

    -- ── Right side: just text, NO background dungeon art ──
    -- Player name: small, top. Word-wrap disabled so a long character
    -- name stays on one line and extends past the row edge if needed
    -- (Name-Realm strings can hit ~24 characters on cross-realm groups).
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    -- Anchors + justify are set per-row in configureRow (mirror flag).
    row.nameText:SetWordWrap(false)
    row.nameText:SetNonSpaceWrap(false)
    row.nameText:SetText("")

    -- Dungeon name: large, bottom. Same word-wrap rule — long names like
    -- "Seat of the Triumvirate" or "Dawn of the Infinite: Galakrond's
    -- Fall" must stay on a single line. Without this they would wrap to
    -- two lines and overflow the 38px row height. The right anchor is
    -- omitted so the text extends naturally to whatever width it needs.
    row.dungeonText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    -- Anchors + justify are set per-row in configureRow (mirror + resilient flags).
    row.dungeonText:SetWordWrap(false)
    row.dungeonText:SetNonSpaceWrap(false)
    row.dungeonText:SetTextColor(1, 1, 1)
    row.dungeonText:SetText("")

    -- Resilient indicator (chromie-time hourglass atlas) — sits LEFT of
    -- the dungeon name (or RIGHT in mirror mode). Anchors set in
    -- configureRow so the mirror toggle re-positions the icon properly.
    row.resilientTex = row:CreateTexture(nil, "OVERLAY")
    row.resilientTex:SetSize(22, 22)
    pcall(row.resilientTex.SetAtlas, row.resilientTex, RESILIENT_ATLAS, false)
    row.resilientTex:Hide()

    return row
end

local function getRow(parent)
    local row = table.remove(rowPool)
    if not row then row = createRow(parent) end
    row:SetParent(parent)
    -- Re-assert the row size on each reuse. A row's SetSize survives
    -- ClearAllPoints, but explicit re-setting protects against future
    -- code paths that might inadvertently anchor a row to opposing
    -- corners and lock the height to whatever the parent dictates.
    row:SetSize(FRAME_WIDTH - FRAME_PAD * 2, ROW_HEIGHT)
    row:Show()
    return row
end

local function releaseRow(row)
    if not row then return end
    row:Hide()
    row:ClearAllPoints()
    row.keystoneOwner = nil
    -- Clear any active cast-progress overlay so the next row that
    -- recycles this pooled instance doesn't briefly inherit stale
    -- cast state before configureRow re-applies a fresh one.
    row._castStart = nil
    row._castEnd   = nil
    if row.castOverlay then row.castOverlay:Hide() end
    table.insert(rowPool, row)
end

local function configureRow(row, keystone)
    if not row or not keystone then return end
    row.keystoneOwner = keystone.keystoneOwner
    -- Stash the dungeon mapID on the row so the LFG queue-glow logic can
    -- light up the matching row when the user's queued group fills. Set
    -- early so the glow-application block at the bottom of this function
    -- has it available regardless of which other branches run.
    row._mapID = keystone.challengeMapID
    -- Cache the full display payload on the row so the OnEnter handler
    -- below can build a synthetic keystone object from row data instead
    -- of re-fetching from keystonesDB. Without this cache there's a
    -- race window between a keystone update arriving (DB written) and
    -- RebuildDisplays running (row text refreshed) — during that window
    -- the row visually still shows the OLD dungeon, but dbGetKeystone
    -- would return the NEW one. Clicking the row would then teleport
    -- to the new dungeon instead of the one the user actually sees.
    -- Using the row-cached data makes the click consistent with what
    -- the user is looking at; the next RebuildDisplays pass refreshes
    -- both the visible row AND this cache so future clicks use the
    -- post-update destination.
    row._displayLevel       = keystone.keystoneLevel
    row._displayName        = keystone.displayName
    row._displayIsResilient = keystone.isResilient == true

    -- Apply the configured font (Size & Font tab) to every text element.
    -- Per-element sizes are configurable in Keystone List settings;
    -- port-status text uses a FIXED size so it doesn't grow/shrink with
    -- the level slider — the user wants the "no port" / "Port CD" text
    -- to stay compact regardless of how big "+XX" gets.
    local levelSize   = (BIT.db and BIT.db.keystoneListLevelSize)   or 16
    local nameSize    = (BIT.db and BIT.db.keystoneListNameSize)    or 11
    local dungeonSize = (BIT.db and BIT.db.keystoneListDungeonSize) or 14
    applyConfiguredFont(row.levelText,    levelSize)
    applyConfiguredFont(row.dungeonText,  dungeonSize)
    applyConfiguredFont(row.nameText,     nameSize)
    applyConfiguredFont(row.noPortText,   9)

    local lvl = keystone.keystoneLevel or 0

    -- Level number (white, centered over the dungeon icon)
    row.levelText:SetText("+" .. lvl)
    row.levelText:SetTextColor(1, 1, 1)

    -- Player name (class-colored, small, top of right side).
    -- Resolve via BIT.GetDisplayName so the multi-select Custom-Names
    -- filter applies — when "Keystone List" is unchecked in the
    -- dropdown the raw character short-name shows; when checked, any
    -- custom name received via SyncCD substitutes. The lookup key
    -- has to be the full "Name-Realm" form so the SyncCD users table
    -- matches; fall back to the short displayName when the realm
    -- suffix isn't available.
    local nameKey      = keystone.keystoneOwner or keystone.displayName or ""
    local resolved     = nameKey
    if BIT.GetDisplayName and nameKey ~= "" then
        resolved = BIT.GetDisplayName(nameKey, "KEYSTONE_LIST") or nameKey
    end
    -- Strip the "-Realm" suffix from the display string (the SyncCD
    -- short custom name is already realm-less, but if GetDisplayName
    -- returned the raw character key for any reason the row needs
    -- only the short visible form).
    local displayName = resolved:match("^([^%-]+)") or resolved
    if displayName == "" then displayName = keystone.displayName or "" end
    if keystone.class then
        displayName = classColorize(displayName, keystone.class)
    end
    row.nameText:SetText(displayName)

    -- Dungeon name (large, bottom of right side)
    local useAbbr = BIT.db and BIT.db.keystoneListUseAbbreviation == true
    local dungeonName = getDungeonName(keystone.challengeMapID, useAbbr)
                        or ("Map " .. tostring(keystone.challengeMapID))
    row.dungeonText:SetText(dungeonName)

    -- ── Layout (mirror-aware) ──────────────────────────
    -- Two layouts share the same row geometry — just flipped horizontally:
    --   normal: iconBox at left,  texts extend rightward, justify LEFT
    --   mirror: iconBox at right, texts extend leftward,  justify RIGHT
    -- Re-applied per row so the mirror toggle can flip the layout live
    -- without rebuilding everything.
    local mirror        = BIT.db and BIT.db.keystoneListMirror == true
    local showResilient = BIT.db and BIT.db.keystoneListShowResilient ~= false

    -- iconBox: pinned to the chosen edge, full row height
    row.iconBox:ClearAllPoints()
    if mirror then
        row.iconBox:SetPoint("TOPRIGHT",    row, "TOPRIGHT",    0, 0)
        row.iconBox:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
    else
        row.iconBox:SetPoint("TOPLEFT",    row, "TOPLEFT",    0, 0)
        row.iconBox:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
    end

    -- Player name (top): anchor to the OPPOSITE corner of iconBox so it
    -- extends away from the icon side. Justify mirrors too.
    row.nameText:ClearAllPoints()
    if mirror then
        row.nameText:SetPoint("TOPRIGHT", row.iconBox, "TOPLEFT", -5, -2)
        row.nameText:SetJustifyH("RIGHT")
    else
        row.nameText:SetPoint("TOPLEFT",  row.iconBox, "TOPRIGHT", 5, -2)
        row.nameText:SetJustifyH("LEFT")
    end

    -- Resilient indicator (only shown when the keystone is resilient AND
    -- the user hasn't disabled the option). Sits between the iconBox and
    -- the dungeon name in both layouts.
    row.resilientTex:ClearAllPoints()
    if mirror then
        row.resilientTex:SetPoint("BOTTOMRIGHT", row.iconBox, "BOTTOMLEFT", -4, -1)
    else
        row.resilientTex:SetPoint("BOTTOMLEFT",  row.iconBox, "BOTTOMRIGHT", 4, -1)
    end

    -- Dungeon name (bottom): four cases — mirror × resilient.
    -- Offsets:  4 (icon X gap) + 22 (icon width) + 2 (text gap) = 28
    --   resilient hidden → text starts where the icon WOULD be (= 5)
    --   resilient shown  → text starts AFTER the icon (= 28)
    row.dungeonText:ClearAllPoints()
    if mirror then
        row.dungeonText:SetJustifyH("RIGHT")
        if keystone.isResilient and showResilient then
            row.resilientTex:Show()
            row.dungeonText:SetPoint("BOTTOMRIGHT", row.iconBox, "BOTTOMLEFT", -28, 2)
        else
            row.resilientTex:Hide()
            row.dungeonText:SetPoint("BOTTOMRIGHT", row.iconBox, "BOTTOMLEFT", -5,  2)
        end
    else
        row.dungeonText:SetJustifyH("LEFT")
        if keystone.isResilient and showResilient then
            row.resilientTex:Show()
            row.dungeonText:SetPoint("BOTTOMLEFT",  row.iconBox, "BOTTOMRIGHT", 28, 2)
        else
            row.resilientTex:Hide()
            row.dungeonText:SetPoint("BOTTOMLEFT",  row.iconBox, "BOTTOMRIGHT", 5,  2)
        end
    end

    -- Dungeon icon — fills the LEFT box (the level number is overlaid on top)
    local iconTex = getDungeonTexture(keystone.challengeMapID)
                    or getDungeonBackground(keystone.challengeMapID)
    if iconTex then
        row.dungeonIcon:SetTexture(iconTex)
        row.dungeonIcon:Show()
        row.iconDim:Show()
    else
        -- Fallback: solid dark fill so the level number still has contrast
        row.dungeonIcon:SetColorTexture(0.10, 0.10, 0.10, 1)
        row.dungeonIcon:Show()
        row.iconDim:Show()
    end

    -- Port status indicator at the bottom of the icon box.
    --   ready    → no text, teleport ready to use
    --   noport   → "no port" red (player hasn't unlocked the teleport)
    --   cooldown → "Port CD" red (only for the LOCAL player — we can't
    --              know remote players' cooldowns)
    local showNoPort = BIT.db and BIT.db.keystoneListShowNoPort ~= false
    local isSelfRow = (keystone.keystoneOwner == getPlayerFullName())
    local status, _remain, portID = getPortStatus(keystone.challengeMapID, isSelfRow)
    if showNoPort then
        if status == "noport" and portID then
            row.noPortText:SetText(L("KEY_NO_PORT", "no port"))
            row.noPortText:Show()
        elseif status == "cooldown" then
            row.noPortText:SetText(L("KEY_PORT_CD", "Port CD"))
            row.noPortText:Show()
        else
            row.noPortText:Hide()
        end
    else
        row.noPortText:Hide()
    end

    -- Border: drawn OUTSIDE the icon via iconBorderOverlay so growing the
    -- border doesn't shrink the visible icon (same approach as the
    -- interrupt tracker bars in UI.lua → ApplyBorderToFrame).
    --
    -- Size + offset are dedicated to the keystone list (keystoneListBorderSize
    -- / keystoneListBorderOffset). Texture path and color stay shared with
    -- the global Size & Font settings for visual consistency — if you want
    -- those independent too, sing out and I'll wire separate keys.
    local bo = row.iconBorderOverlay
    if bo then
        local edgeFile = BIT.db and BIT.db.borderTexturePath
        local edgeSize = (BIT.db and BIT.db.keystoneListBorderSize) or 2
        local offset   = (BIT.db and BIT.db.keystoneListBorderOffset) or 0
        -- Negative outward = the bo frame ends up SMALLER than iconBox,
        -- so the border (which draws inward from bo's edges) ends up
        -- partially inside the icon area. That's a valid look — the
        -- icon's outermost edge pixels are usually low-information
        -- (we already crop 8% via SetTexCoord above).
        local outward  = edgeSize + offset

        bo:ClearAllPoints()
        if edgeFile and edgeFile ~= "" and edgeSize > 0 then
            bo:SetPoint("TOPLEFT",     row.iconBox, "TOPLEFT",     -outward,  outward)
            bo:SetPoint("BOTTOMRIGHT", row.iconBox, "BOTTOMRIGHT",  outward, -outward)
            bo:SetBackdrop({
                edgeFile = edgeFile,
                edgeSize = edgeSize,
                insets = { left = 0, right = 0, top = 0, bottom = 0 },
            })
            bo:SetBackdropBorderColor(
                (BIT.db.borderColorR) or 0,
                (BIT.db.borderColorG) or 0,
                (BIT.db.borderColorB) or 0,
                (BIT.db.borderColorA) or 1)
            bo:Show()
        else
            bo:SetAllPoints(row.iconBox)
            bo:SetBackdrop(nil)
        end
    end

    -- Hover/click target is the ICON ONLY. The whole hover-to-teleport
    -- subsystem (SecureAction button + spell tooltip) is now gated by a
    -- master toggle (keystoneListClickTeleport, default ON). Disabling it
    -- skips the button creation entirely — no SetAttribute calls, no
    -- secure-template plumbing — which is the safe path for users who
    -- run into Midnight taint issues from secure action handlers.
    local clickTeleport = BIT.db and BIT.db.keystoneListClickTeleport ~= false
    if clickTeleport then
        row.iconBox:EnableMouse(true)
        row.iconBox:SetScript("OnEnter", function(self)
            -- Build the keystone payload from the ROW's cached display
            -- data, not from a fresh keystonesDB lookup — see the
            -- comment on row._displayLevel above for the race-
            -- condition rationale. Result: clicking always teleports
            -- to the dungeon that's visible on the row.
            if row._mapID then
                local synthetic = {
                    challengeMapID = row._mapID,
                    keystoneLevel  = row._displayLevel,
                    keystoneOwner  = row.keystoneOwner,
                    displayName    = row._displayName,
                    isResilient    = row._displayIsResilient,
                }
                attachHoverToRow(self, synthetic, row)
            end
            if status == "ready" then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(portID)
                GameTooltip:Show()
            end
        end)
        row.iconBox:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    else
        -- Click-to-teleport disabled: nothing happens on hover, no secure
        -- button is created or attached.
        row.iconBox:EnableMouse(false)
        row.iconBox:SetScript("OnEnter", nil)
        row.iconBox:SetScript("OnLeave", nil)
        -- Hide any existing hover button so it doesn't linger from before
        if hoverButton then
            hoverButton:ClearAllPoints()
            hoverButton:Hide()
        end
    end
    -- Make sure the row itself is not a click/hover target anymore
    row:EnableMouse(false)
    row:SetScript("OnEnter", nil)
    row:SetScript("OnLeave", nil)

    -- ── LFG queue glow ────────────────────────────────────────────
    -- If the M+ Group Finder queue resolved to this dungeon, light up
    -- the icon. Re-checked on every row config (rebuilds, mirror toggle,
    -- font changes, …) so the glow stays applied across UI rebuilds —
    -- LibButtonGlow's overlay frame gets reparented to whichever row
    -- currently shows this dungeon's mapID. We anchor to row.glowTarget
    -- (a square child of iconBox) instead of iconBox itself because
    -- LibButtonGlow's spark/inner/outer-glow textures size proportionally
    -- to the parent — a rectangular parent makes the spark look stretched.
    -- Both Show and Hide are pcall'd so a tainted overlay can't crash
    -- the row build.
    do
        local lbg = _GetLBG()
        if lbg and row.glowTarget then
            local glowOn = _glowedMapID and row._mapID == _glowedMapID
            if glowOn and lbg.ShowOverlayGlow then
                pcall(lbg.ShowOverlayGlow, row.glowTarget)
            elseif lbg.HideOverlayGlow then
                pcall(lbg.HideOverlayGlow, row.glowTarget)
            end
        end
    end
end

------------------------------------------------------------
-- UI: main frame
------------------------------------------------------------
local function applyFrameScale()
    if not mainFrame then return end
    local s = (BIT.db and BIT.db.keystoneListScale) or 100
    if s < 50 then s = 50 elseif s > 200 then s = 200 end
    pcall(mainFrame.SetScale, mainFrame, s / 100)
end

local function applyFramePosition()
    if not mainFrame then return end
    local x = (BIT.db and BIT.db.keystoneListPosX) or 200
    local y = (BIT.db and BIT.db.keystoneListPosY) or 200
    local growUp = BIT.db and BIT.db.keystoneListGrowUpward == true
    mainFrame:ClearAllPoints()
    -- (x, y) is the position of the LOCAL PLAYER's row anchor edge:
    --   grow-down → user's row TOP edge — frame's TOPLEFT to UIParent's BOTTOMLEFT
    --   grow-up   → user's row BOTTOM edge — frame's BOTTOMLEFT to UIParent's BOTTOMLEFT
    -- Because the user's row is anchored at the same edge as the frame,
    -- toggling grow direction only flips where the OTHER rows extend —
    -- the user's row visually stays put.
    if growUp then
        mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    else
        mainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    end
end

local function ensureMainFrame()
    if mainFrame then return mainFrame end
    -- No backdrop / border / title — the frame is just a transparent
    -- container holding the rows. Each row carries its own visual (level
    -- box + dungeon art), so a wrapper frame would just add clutter.
    local f = CreateFrame("Frame", "BIT_KeystoneList_Frame", UIParent)
    f:SetSize(FRAME_WIDTH, ROW_HEIGHT * 5)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        -- Move-all mode (minimap right-click) overrides the lock at runtime.
        if BIT.db and BIT.db.keystoneListLocked and not BIT._moveAllUnlock then return end
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x = math.floor(self:GetLeft() or 0)
        -- Save the edge the user's row is anchored to: TOP for grow-down
        -- (user row at top), BOTTOM for grow-up (user row at bottom).
        local growUp = BIT.db and BIT.db.keystoneListGrowUpward == true
        local y
        if growUp then
            y = math.floor(self:GetBottom() or 0)
        else
            y = math.floor(self:GetTop() or 0)
        end
        if BIT.db then
            BIT.db.keystoneListPosX = x
            BIT.db.keystoneListPosY = y
        end
    end)

    f:Hide()
    mainFrame = f

    -- Not registered with Blizzard Edit Mode by design — the frame has its
    -- own drag handler (OnDragStart/Stop above) for positioning.

    applyFrameScale()
    applyFramePosition()
    return f
end

------------------------------------------------------------
-- UI: visibility logic — per-context toggles. Show / hide is decided
-- by which group context the user is in (raid vs party vs solo) plus
-- the active-M+ override.
------------------------------------------------------------
local function shouldShow()
    if not isEnabled() then return false end
    -- Test mode forces the frame visible so the user can position it.
    if KL._testMode then return true end
    -- Empty frame when no entries exist — don't fight the user with an
    -- always-visible empty box.
    local hasAnyEntry = false
    for _ in pairs(keystonesDB) do hasAnyEntry = true; break end
    if not hasAnyEntry then return false end

    local hideInM   = BIT.db and BIT.db.keystoneListHideInM == true
    local showInP   = BIT.db and BIT.db.keystoneListShowInParty ~= false   -- default true
    local showInR   = BIT.db and BIT.db.keystoneListShowInRaid == true     -- default false
    local showSolo  = BIT.db and BIT.db.keystoneListShowSolo ~= false      -- default true

    -- Active M+ run takes priority — the "Hide in M+" toggle wins over
    -- everything else. Outside of M+, fall through to the per-context
    -- visibility toggles.
    if challengeModeActive then
        return not hideInM
    end

    -- Active instanced content (Delves, Tuskarr Ritual / scenarios,
    -- arenas, battlegrounds) is treated like an active activity — the
    -- user is focused on the instance, not on coordinating keys, so
    -- hide automatically. Only "party" (5-man dungeons) and "raid"
    -- instance types fall through to the per-context toggles below
    -- because those are the contexts where seeing keys is still useful
    -- (heroic dungeon prep, raid-day key planning).
    local _, instanceType = IsInInstance()
    if instanceType and instanceType ~= "none"
       and instanceType ~= "party"
       and instanceType ~= "raid" then
        return false
    end

    -- Group context decides which "show" toggle applies. Order matters:
    -- IsInRaid() is true in a raid even though IsInGroup() is also true,
    -- so check raid first.
    if IsInRaid() then
        return showInR
    end
    if IsInGroup() then
        return showInP
    end
    -- Not in any group → solo / open world
    return showSolo
end

------------------------------------------------------------
-- Fade in / out helpers — smooth alpha transitions instead of instant
-- show / hide. Animation groups are created once and reused; cross-fading
-- (toggling rapidly) cancels the in-flight animation before starting the
-- new one so the alpha doesn't snap back.
------------------------------------------------------------
local FADE_DURATION = 0.25

local function ensureFadeAnimations(frame)
    if frame._fadeIn and frame._fadeOut then return end

    frame._fadeIn = frame:CreateAnimationGroup()
    local aIn = frame._fadeIn:CreateAnimation("Alpha")
    aIn:SetFromAlpha(0)
    aIn:SetToAlpha(1)
    aIn:SetDuration(FADE_DURATION)
    aIn:SetSmoothing("OUT")
    frame._fadeIn:SetScript("OnFinished", function()
        frame:SetAlpha(1)
    end)

    frame._fadeOut = frame:CreateAnimationGroup()
    local aOut = frame._fadeOut:CreateAnimation("Alpha")
    aOut:SetFromAlpha(1)
    aOut:SetToAlpha(0)
    aOut:SetDuration(FADE_DURATION)
    aOut:SetSmoothing("IN")
    frame._fadeOut:SetScript("OnFinished", function()
        frame:Hide()
        -- Reset alpha so the next fade-in starts from full opacity once
        -- the alpha-anim sets it to 0 again. Without this, a Show() with
        -- alpha already at 0 from the previous fade-out gets briefly
        -- visible at alpha=0 (i.e. invisible) before the anim takes over.
        frame:SetAlpha(1)
    end)
end

local function fadeInFrame(frame)
    if not frame then return end
    ensureFadeAnimations(frame)
    if frame._fadeOut:IsPlaying() then frame._fadeOut:Stop() end
    if frame:IsShown() and frame:GetAlpha() >= 0.99 then return end
    frame:SetAlpha(0)
    frame:Show()
    frame._fadeIn:Play()
end

local function fadeOutFrame(frame)
    if not frame then return end
    if not frame:IsShown() then return end
    ensureFadeAnimations(frame)
    if frame._fadeIn:IsPlaying() then frame._fadeIn:Stop() end
    frame:SetAlpha(1)
    frame._fadeOut:Play()
end

local function applyVisibility()
    if not mainFrame then return end
    visibilityShow = shouldShow()
    if visibilityShow then
        fadeInFrame(mainFrame)
    else
        fadeOutFrame(mainFrame)
    end
end

------------------------------------------------------------
-- UI: build display rows
------------------------------------------------------------
local function purgeDisplays()
    -- Remove rows for users no longer in party (except self).
    -- Test-mode entries are preserved — they're cleaned up explicitly via
    -- ToggleTestMode so the user's preview survives roster changes.
    local self_ = getPlayerFullName()
    for owner, k in pairs(keystonesDB) do
        local isTest = (type(k) == "table" and k._isTest)
        if not isTest and owner ~= self_ and not isPlayerInMyParty(owner) then
            keystonesDB[owner] = nil
            nativClients[owner] = nil
        end
    end
end

local function rebuildDisplays()
    if not mainFrame then return end
    -- Release current rows
    for _, row in ipairs(activeRows) do releaseRow(row) end
    wipe(activeRows)

    if not visibilityShow then return end

    -- Build the list with the local player ALWAYS first, others sorted
    -- by level desc afterward. Combined with the grow-direction toggle
    -- this pins the user to the anchor edge: with grow-down the user is
    -- top, group below; with grow-up the user is bottom, group above.
    local selfEntry, others = nil, {}
    local self_ = getPlayerFullName()

    if KL._testMode then
        -- Test mode: separate the player's preview row (i==1, _isSelf=true)
        -- from the four fake party rows. Pure local data, no DB writes.
        for _, k in pairs(keystonesDB) do
            if k._isTest then
                if k._isSelf then
                    selfEntry = k
                else
                    table.insert(others, k)
                end
            end
        end
    else
        -- Normal mode: pull self from the DB, walk party slots for others.
        if self_ then
            local k = dbGetKeystone(self_)
            if k then selfEntry = k end
        end
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                local n, r = UnitFullName(unit)
                if n then
                    local _, selfRealm = UnitFullName("player")
                    r = (r and r ~= "") and r or selfRealm or GetRealmName()
                    local full = n .. "-" .. (r or "")
                    if full ~= self_ then
                        local k = dbGetKeystone(full)
                        if not k then
                            local data = lookupExternalKeystoneData(n, r)
                            if data then
                                local _, kk = dbUpdateKeystone(data)
                                k = kk or nil
                            end
                        end
                        if k then
                            local _, classFile = UnitClass(unit)
                            if classFile then k.class = classFile end
                            table.insert(others, k)
                        end
                    end
                end
            end
        end
    end

    -- Sort the OTHERS only (self stays pinned). Highest level first,
    -- then by name. The player's own row is always entries[1] regardless
    -- of their key level so they don't slide around the list.
    table.sort(others, function(a, b)
        if (a.keystoneLevel or 0) ~= (b.keystoneLevel or 0) then
            return (a.keystoneLevel or 0) > (b.keystoneLevel or 0)
        end
        return (a.displayName or "") < (b.displayName or "")
    end)

    local entries = {}
    if selfEntry then table.insert(entries, selfEntry) end
    for _, k in ipairs(others) do table.insert(entries, k) end

    -- Resize the host frame to exactly fit the rows. No title bar, no
    -- internal padding — rows stack with a user-configurable gap between
    -- them (default 1px, controlled by keystoneListRowGap on the settings
    -- page). The frame's anchor edge (TOP for grow-down, BOTTOM for
    -- grow-up) is pinned to the local player's row Y, so resizing alone
    -- doesn't move that row — height changes only push the OPPOSITE edge.
    local count = #entries
    local rowGap = (BIT.db and BIT.db.keystoneListRowGap) or 1
    if rowGap < 0 then rowGap = 0 end
    local h = (count > 0) and (ROW_HEIGHT * count + rowGap * (count - 1)) or ROW_HEIGHT
    mainFrame:SetSize(FRAME_WIDTH, h)

    -- Grow direction: top→down anchors row 1 at frame's TOP; bottom→up
    -- anchors row 1 at frame's BOTTOM. Subsequent rows stack in the
    -- opposite direction so the FIRST entry (highest level after sorting)
    -- always sits closest to the user's chosen anchor edge.
    local growUp = BIT.db and BIT.db.keystoneListGrowUpward == true

    local prev = nil
    for _, k in ipairs(entries) do
        local row = getRow(mainFrame)
        configureRow(row, k)
        row:ClearAllPoints()
        if growUp then
            -- Grow upward: first row at the bottom, next row above it
            if prev then
                row:SetPoint("BOTTOMLEFT",  prev, "TOPLEFT",  0, rowGap)
                row:SetPoint("BOTTOMRIGHT", prev, "TOPRIGHT", 0, rowGap)
            else
                row:SetPoint("BOTTOMLEFT",  mainFrame, "BOTTOMLEFT",  0, 0)
                row:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
            end
        else
            -- Grow downward (default): first row at the top, next row below
            if prev then
                row:SetPoint("TOPLEFT",  prev, "BOTTOMLEFT",  0, -rowGap)
                row:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT", 0, -rowGap)
            else
                row:SetPoint("TOPLEFT",  mainFrame, "TOPLEFT",  0, 0)
                row:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
            end
        end
        table.insert(activeRows, row)
        prev = row
    end
end

function KL:RebuildDisplays()
    if not isEnabled() then
        if mainFrame then fadeOutFrame(mainFrame) end
        return
    end
    ensureMainFrame()
    applyVisibility()
    if visibilityShow then
        rebuildDisplays()
    end
end

function KL:Refresh()
    purgeDisplays()
    self:RebuildDisplays()
end

-- True when the list frame is currently on screen. Lets the minimap
-- tooltip distinguish "enabled but not shown right now" (e.g. inside an
-- active M+ run, or no keystones to list) from "switched off".
function KL:IsShown()
    return (mainFrame ~= nil and mainFrame:IsShown()) and true or false
end

------------------------------------------------------------
-- LFG queue-glow
--
-- Visual cue that fires when the user's M+ Group Finder queue resolves
-- into a full 5-player party — the matching dungeon icon in the keystone
-- list lights up with LibButtonGlow's pulsing yellow ring so the user
-- can tell at a glance which dungeon they're about to run.
--
-- Two paths can trigger the glow:
--   1) Group LEADER who created the listing — when the listing gets
--      auto-delisted because the group is full, LFG_LIST_ACTIVE_ENTRY_UPDATE
--      fires with `created == false` and the cached activityIDs identify
--      the dungeon.
--   2) APPLICANT who joined someone else's listing — when their app status
--      becomes "inviteaccepted", `LFG_LIST_APPLICATION_STATUS_UPDATED`
--      fires; the searchResultID resolves to an activityID via
--      `C_LFGList.GetSearchResultInfo`. Because GROUP_ROSTER_UPDATE may
--      not have settled yet, the trigger is deferred ~2s before checking
--      group size.
--
-- All API reads are pcall'd because LFG-related fields can be Midnight
-- "secret" values (string formatting / arithmetic on those throws).
-- Default ON (`keystoneListQueueGlow`); user can disable per profile.
------------------------------------------------------------

-- _GetLBG (LibButtonGlow lookup) is defined near the top of the file —
-- it has to be visible to configureRow which uses it for per-row glow
-- application. See the State section near the top for the definition.

-- Build/return a localized-dungeon-name → challengeMapID lookup. WoW's
-- LFG activity table doesn't expose challengeMapID directly for M+
-- listings, but the activity's display name matches the dungeon name
-- returned by `C_ChallengeMode.GetMapUIInfo` — so a name match is the
-- simplest reliable mapping. Lazily built; rebuilt on demand if a new
-- season's maps appear (M+ map table changes mid-expansion).
local function _BuildDungeonNameLookup()
    local lookup = {}
    if not C_ChallengeMode or not C_ChallengeMode.GetMapTable then
        return lookup
    end
    local ok, maps = pcall(C_ChallengeMode.GetMapTable)
    if not ok or not maps then return lookup end
    for _, mapID in ipairs(maps) do
        local okN, name = pcall(C_ChallengeMode.GetMapUIInfo, mapID)
        if okN and name and name ~= "" then
            lookup[name] = mapID
        end
    end
    return lookup
end

local function _GetDungeonNameLookup()
    if not _dungeonNameToMapID or next(_dungeonNameToMapID) == nil then
        _dungeonNameToMapID = _BuildDungeonNameLookup()
    end
    return _dungeonNameToMapID
end

-- Try to resolve an LFG activityID to a challengeMapID.
-- Strategy: pull the activity's full + short name from the LFG API and
-- match against the localized dungeon name lookup. Defensive against
-- both APIs returning nil / empty / tainted data.
local function _ActivityIDToMapID(activityID)
    if not activityID or type(activityID) ~= "number" then return nil end
    if not C_LFGList then return nil end

    local fullName, shortName
    -- Prefer GetActivityInfoTable — newer API, returns a table we can
    -- read defensively. Fall back to GetActivityFullName for older
    -- clients or if the table read trips on a secret value.
    if C_LFGList.GetActivityInfoTable then
        local ok, info = pcall(C_LFGList.GetActivityInfoTable, activityID)
        if ok and info then
            -- Each field read is pcall'd because Midnight tainted entries
            -- can throw on indexing. tostring lets us treat secret strings
            -- defensively too.
            local okF, fn = pcall(function() return info.fullName end)
            if okF and type(fn) == "string" then fullName = fn end
            local okS, sn = pcall(function() return info.shortName end)
            if okS and type(sn) == "string" then shortName = sn end
        end
    end
    if not fullName and C_LFGList.GetActivityFullName then
        local okN, n = pcall(C_LFGList.GetActivityFullName, activityID)
        if okN and type(n) == "string" then fullName = n end
    end
    if not fullName and not shortName then return nil end

    local lookup = _GetDungeonNameLookup()
    -- Exact match first (typical case: the activity name IS the dungeon name)
    if shortName and lookup[shortName] then return lookup[shortName] end
    if fullName  and lookup[fullName]  then return lookup[fullName]  end
    -- Substring fallback: catches "Mythic Keystone: Magisters' Terrace" etc.
    if fullName then
        for dName, mid in pairs(lookup) do
            if fullName:find(dName, 1, true) then return mid end
        end
    end
    return nil
end

-- Apply / clear glow on every visible row whose mapID matches `_glowedMapID`.
-- Called from configureRow during display rebuilds AND directly from the
-- LFG event handlers when the glow target changes mid-display.
-- Uses row.glowTarget (a square child of iconBox) — see configureRow's
-- glow block for the rationale.
local function _SyncGlowToRows()
    local lbg = _GetLBG()
    if not lbg then return end
    for _, row in ipairs(activeRows) do
        if row and row.glowTarget then
            if _glowedMapID and row._mapID == _glowedMapID then
                if lbg.ShowOverlayGlow then
                    pcall(lbg.ShowOverlayGlow, row.glowTarget)
                end
            else
                if lbg.HideOverlayGlow then
                    pcall(lbg.HideOverlayGlow, row.glowTarget)
                end
            end
        end
    end
end

-- Drop pending-applicant state (cached activityID waiting for the queued
-- group to fill, plus the 5-min watchdog that auto-clears it). Called
-- whenever the wait should end: glow scheduled, group left, toggle
-- disabled, or watchdog timeout. Idempotent — safe to call always.
local function _ClearPendingApplicantState()
    _pendingApplicantActivityID = nil
    if _pendingApplicantClearTimer then
        _pendingApplicantClearTimer:Cancel()
        _pendingApplicantClearTimer = nil
    end
end

-- Try to fire the glow for an applicant whose accept may now have
-- resolved into a full party. Called from two places:
--   1) Right after LFG_LIST_APPLICATION_STATUS_UPDATED sets the pending
--      state — covers the "user is the 5th member" case where the group
--      is already 5 the moment the accept lands.
--   2) Every GROUP_ROSTER_UPDATE while pending state is set — covers the
--      common "user joined as the 4th, the 5th comes ~10s later" case
--      where no further LFG event fires for the applicant.
-- The pending state is cleared atomically with scheduling so a follow-up
-- GROUP_ROSTER_UPDATE in the same frame (role assignments, realm sync,
-- etc.) can't double-schedule the same glow timer.
local function _TryFireApplicantGlow()
    if not _pendingApplicantActivityID then return end
    if not BIT.db or BIT.db.keystoneListQueueGlow == false then return end
    if not GetNumGroupMembers or GetNumGroupMembers() < 5 then return end
    local activityID = _pendingApplicantActivityID
    _ClearPendingApplicantState()
    -- 2s delay so the keystone list has time to receive KSGL broadcasts
    -- from the four new party members before we land the glow on a row
    -- that wouldn't exist yet.
    C_Timer.After(2, function()
        if not BIT.db or BIT.db.keystoneListQueueGlow == false then return end
        local mapID = _ActivityIDToMapID(activityID)
        if mapID then KL:GlowDungeonIcon(mapID) end
    end)
end

-- Public: light up the dungeon icon for `mapID`. Replaces any existing
-- glow target — re-queueing for a different dungeon while still in a
-- previous queued group will move the glow to the new target.
function KL:GlowDungeonIcon(mapID)
    if not mapID then return end
    if BIT.db and BIT.db.keystoneListQueueGlow == false then return end
    _glowedMapID = mapID
    _SyncGlowToRows()
    -- 30-second auto-clear. The glow is just a "your group is ready,
    -- here's the dungeon" reminder — long enough that the user catches
    -- it after looking away from the screen, short enough that it
    -- doesn't linger on the icon for half an hour if the cleanup events
    -- (zone-in, group-leave, port-cast) somehow all miss.
    if _glowAutoClearTimer then _glowAutoClearTimer:Cancel() end
    _glowAutoClearTimer = C_Timer.NewTimer(30, function()
        KL:ClearDungeonGlow()
    end)
end

-- Public: remove glow from any currently-glowing icon and cancel the
-- auto-clear timer. Idempotent — safe to call when nothing is glowing.
-- Also clears any pending-applicant state — when the user wants the
-- glow gone (toggle off, manual call, instance-enter, group-leave),
-- the "still waiting for the group to fill" tracker shouldn't keep
-- listening either.
function KL:ClearDungeonGlow()
    _glowedMapID = nil
    _SyncGlowToRows()
    if _glowAutoClearTimer then
        _glowAutoClearTimer:Cancel()
        _glowAutoClearTimer = nil
    end
    _ClearPendingApplicantState()
end

-- LFG event dispatcher. Centralised so registration is a single block in
-- setupEvents() and the handler logic stays alongside its state.
local function _OnLfgEvent(event, ...)
    if not BIT.db or BIT.db.keystoneListQueueGlow == false then
        -- Feature disabled — clear any leftover state but do nothing else
        _lfgActiveActivityIDs = nil
        return
    end

    if event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" then
        local created = ...
        if created then
            -- We just created (or updated) an entry. Cache its activityIDs
            -- so we can map them once the entry disappears.
            local ok, info = pcall(C_LFGList.GetActiveEntryInfo)
            if ok and info then
                local okIDs, ids = pcall(function() return info.activityIDs end)
                if okIDs and type(ids) == "table" then
                    _lfgActiveActivityIDs = ids
                else
                    -- Fallback for older API which returned activityID singular
                    local okSingle, sid = pcall(function() return info.activityID end)
                    if okSingle and sid then
                        _lfgActiveActivityIDs = { sid }
                    end
                end
            end
        else
            -- Entry was removed. We only want to glow if the entry was
            -- removed because the group filled up, not because the user
            -- manually delisted it. Cheap heuristic: the group is full
            -- (5 members) right now → most likely auto-delisted.
            if _lfgActiveActivityIDs and GetNumGroupMembers and GetNumGroupMembers() >= 5 then
                -- Capture the cached activityIDs in a local — we clear
                -- _lfgActiveActivityIDs immediately so a subsequent event
                -- can't mutate them under the deferred closure.
                local capturedIDs = _lfgActiveActivityIDs
                -- Defer ~2s before applying the glow: when the group
                -- fills, the OTHER 4 members' keystones are broadcast to
                -- us via the addon's PARTY-channel protocol. The list
                -- needs that incoming traffic to render rows for those
                -- players' dungeons before the glow can land on the
                -- right icon. Glowing instantly would either miss the
                -- target row (it doesn't exist yet) or land on the
                -- player's own row in a different dungeon.
                C_Timer.After(2, function()
                    if not BIT.db or BIT.db.keystoneListQueueGlow == false then return end
                    -- Try each cached activityID — first one that
                    -- resolves to a known M+ challengeMap wins. (Most
                    -- M+ listings cover a single dungeon, so usually
                    -- it's just `ids[1]`.)
                    for _, aid in ipairs(capturedIDs) do
                        local mapID = _ActivityIDToMapID(aid)
                        if mapID then
                            KL:GlowDungeonIcon(mapID)
                            break
                        end
                    end
                end)
            end
            _lfgActiveActivityIDs = nil
        end

    elseif event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
        local searchResultID, newStatus = ...
        if newStatus ~= "inviteaccepted" then return end
        if not searchResultID or not C_LFGList or not C_LFGList.GetSearchResultInfo then return end
        local ok, res = pcall(C_LFGList.GetSearchResultInfo, searchResultID)
        if not ok or not res then return end
        -- Newer clients return activityIDs (plural), older ones activityID.
        local activityID
        local okA, ids = pcall(function() return res.activityIDs end)
        if okA and type(ids) == "table" and ids[1] then
            activityID = ids[1]
        else
            local okS, sid = pcall(function() return res.activityID end)
            if okS and sid then activityID = sid end
        end
        if not activityID then return end
        -- Stash the activityID and arm a 5-min watchdog. The actual
        -- glow doesn't fire here — we wait for GROUP_ROSTER_UPDATE to
        -- confirm the group has filled to 5 players, which can take
        -- many seconds after we accept the invite (further applicants
        -- may still need to be invited and accept). This was the bug
        -- that made the glow miss when the user joined as the 4th and
        -- the 5th member came ~10s later: there's no further LFG event
        -- for the applicant in that window, so a one-shot 2s deferred
        -- check would always find a 4-person group and skip the glow.
        _ClearPendingApplicantState()  -- defensive: drop any stale state
        _pendingApplicantActivityID = activityID
        _pendingApplicantClearTimer = C_Timer.NewTimer(5 * 60, function()
            _ClearPendingApplicantState()
        end)
        -- Run a try-fire one frame later too: covers the "user IS the
        -- 5th member" case where GROUP_ROSTER_UPDATE may have already
        -- fired before this inviteaccepted event landed. Deferring by
        -- a single frame lets any racing GROUP_ROSTER_UPDATE settle so
        -- GetNumGroupMembers() returns the post-join count.
        C_Timer.After(0, _TryFireApplicantGlow)
    end
end

------------------------------------------------------------
-- Event handlers
------------------------------------------------------------
local function onAddonMessage(prefix, msg, channel, sender)
    if prefix ~= CHAT_PREFIX or channel ~= "PARTY" then return end
    if not msg then return end
    -- In modern retail `sender` is already "Name-Realm". The protocol's
    -- 5th-arg `senderFullName` is actually zoneChannelID, not a name — we
    -- ignore it and use `sender` as the canonical owner key.
    local self_ = getPlayerFullName()
    if not sender or sender == "" then return end
    -- Ensure sender carries a realm suffix (some channels strip it for same-realm)
    local sFull = sender
    if not sFull:match(".+%-.+") then
        local _, realm = UnitFullName("player")
        sFull = sFull .. "-" .. (realm or GetRealmName() or "")
    end
    if sFull == self_ then return end
    local messageType = msg:match("KSGL:(%a+):")
    if messageType == "Send" then
        local mapID    = tonumber(msg:match("KSGL:.-:(%d+):"))
        local lvl      = tonumber(msg:match("KSGL:.-:%d+:(%d+):"))
        local actID    = tonumber(msg:match("KSGL:.-:%d+:%d+:(%d+):")) or 0
        local grpID    = tonumber(msg:match("KSGL:.-:%d+:%d+:%d+:(%d+)")) or 0
        local resilFlag = tonumber(msg:match("KSGL:.-:%d+:%d+:%d+:%d+:(%d+)")) == 1
        if not mapID or not lvl then return end
        registerNativClient(sFull)
        local data = {
            challengeMapID = mapID,
            keystoneLevel  = lvl,
            activityID     = actID,
            groupID        = grpID,
            isResilient    = resilFlag,
            keystoneOwner  = sFull,
        }
        local updated, k = dbUpdateKeystone(data)
        if updated and k then KL:RebuildDisplays() end
    elseif messageType == "Request" then
        broadcastSend()
    end
end

local function onGroupRosterUpdate()
    if not isEnabled() then return end
    purgeDisplays()
    KL:RebuildDisplays()
end

local function onChallengeModeStart()
    challengeModeActive = true
    if not isEnabled() then return end
    C_Timer.After(1, function()
        local updated, k = updatePersonalKeystone()
        if updated and k then
            broadcastSend()
            KL:RebuildDisplays()
        end
    end)
    KL:RebuildDisplays()
end

local function onChallengeModeCompleted()
    challengeModeActive = false
    if not isEnabled() then return end
    C_Timer.After(1, function()
        local updated, k = updatePersonalKeystone()
        if updated and k then
            broadcastSend()
            KL:RebuildDisplays()
        end
    end)
    KL:RebuildDisplays()
end

-- Debounced "personal keystone might have changed" refresh. Multiple
-- back-to-back triggers (looting in M+, item upgrades, etc.) collapse
-- into a single deferred call so we never schedule more than one timer
-- in flight at once. Side benefit: cheap to invoke from frequent events.
local _refreshScheduled = false
local function scheduleKeystoneRefresh()
    if _refreshScheduled then return end
    _refreshScheduled = true
    C_Timer.After(1, function()
        _refreshScheduled = false
        if not isEnabled() then return end
        local updated, k = updatePersonalKeystone()
        if updated and k then broadcastSend(); KL:RebuildDisplays() end
    end)
end

-- ITEM_CHANGED and CHAT_MSG_LOOT registrations were REMOVED in 3.6.3.
-- Even with our handlers ignoring the hyperlink args, just registering
-- those events leaves our addon receiving secret-flagged payloads from
-- Blizzard's container code in Midnight, which seems to be enough to
-- leak taint into the protected `UseContainerItem` / `ClearTarget`
-- paths (users couldn't use Hearthstone or open the game menu).
--
-- BAG_UPDATE_DELAYED fires whenever bag contents change (loot, item
-- consumption, key downgrade/reroll) and passes NO arguments — there's
-- no hyperlink to taint us with. Combined with CHALLENGE_MODE_COMPLETED
-- and WEEKLY_REWARDS_UPDATE it covers every case the old events did.
local function onBagUpdateDelayed()
    if not isEnabled() then return end
    scheduleKeystoneRefresh()
end

local function onWeeklyRewardsUpdate()
    if not isEnabled() then return end
    C_Timer.After(2, function()
        updatePersonalKeystone()
        KL:RebuildDisplays()
    end)
end

-- Forward declaration: runInitialBroadcast is defined further down
-- (next to KL:Initialize for cohesion) but the event handlers below
-- reference it via closure. Without this, the closure captures a nil
-- upvalue and crashes when the event fires before Initialize runs.
local runInitialBroadcast
-- Same trick for the test-mode helpers — KL:SetEnabled (defined further
-- down) references clearTestKeystones to wipe preview rows when the user
-- disables the feature, but the helpers live at the bottom of the file
-- next to the rest of the test-mode code.
local clearTestKeystones, spawnTestKeystones

local function onPlayerEnteringWorld(isInitialLogin, isReload)
    if not isEnabled() then return end
    -- Try immediately so the frame appears right after /reload, with a
    -- 0.5s retry as backup in case APIs weren't ready on the first call.
    if runInitialBroadcast then runInitialBroadcast(isInitialLogin or isReload) end
    C_Timer.After(0.5, function()
        if runInitialBroadcast then runInitialBroadcast(isInitialLogin or isReload) end
    end)
end

------------------------------------------------------------
-- Group-join info banner
-- When the player joins a Group Finder dungeon group, briefly show a
-- center-screen banner with the listing's title, dungeon, category and
-- leader. The data is captured at invite-accept time — the search
-- result is still queryable then, unlike after the join completes.
-- Movable (drag), auto-fades after a few seconds.
------------------------------------------------------------
local JOIN_BANNER_HOLD = 5    -- seconds fully visible before the fade starts
local JOIN_BANNER_FADE = 1    -- fade-out duration

-- Taint-safe string read: Group Finder fields (leaderName etc.) can be
-- secret values in 12.x; SetText on a secret would taint the FontString.
local function _safeStr(v)
    if v == nil then return nil end
    local ok, sec = pcall(issecretvalue, v)
    if ok and sec then return nil end
    if type(v) ~= "string" or v == "" then return nil end
    return v
end

local function _saveJoinBannerPos(self)
    local cx, cy = self:GetCenter()
    local ux, uy = UIParent:GetCenter()
    if cx and ux and BIT.db then
        BIT.db.keystoneListJoinBannerX = math.floor(cx - ux + 0.5)
        BIT.db.keystoneListJoinBannerY = math.floor(cy - uy + 0.5)
    end
end

local function _positionJoinBanner(f)
    f:ClearAllPoints()
    local x = (BIT.db and BIT.db.keystoneListJoinBannerX) or 0
    local y = (BIT.db and BIT.db.keystoneListJoinBannerY) or 150
    f:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

-- The settings window owns the theme palette; reuse it so the banner
-- matches whatever theme the user picked. Falls back to nil (defaults
-- applied at the call site) if SettingsUI isn't loaded yet.
local function _joinBannerPalette()
    if BIT.SettingsUI and BIT.SettingsUI.GetThemePalette then
        local ok, pal = pcall(function() return BIT.SettingsUI:GetThemePalette() end)
        if ok and pal then return pal end
    end
    return nil
end

-- Build banner info from the player's OWN character + keystone, for the
-- Test Layout preview: their (class-coloured) name, their current
-- keystone dungeon + level, and a sample comment. Falls back to a sample
-- dungeon when the player has no keystone yet.
local function _ownKeystoneBannerInfo()
    local k     = dbGetPersonal()
    local name  = (k and k.displayName) or (UnitName and UnitName("player")) or "?"
    local class = (k and k.class) or (select(2, UnitClass("player")))
    local title = class and classColorize(name, class) or name
    local dungeon
    if k and k.challengeMapID and k.keystoneLevel then
        dungeon = (getDungeonName(k.challengeMapID) or "?") .. " +" .. k.keystoneLevel
    else
        dungeon = "Pit of Saron +19"  -- sample when no keystone is held
    end
    return {
        title    = title,
        dungeon  = dungeon,
        category = L("KEY_BANNER_DUNGEON", "Dungeon"),
        comment  = "only nice player",
    }
end

local function _ensureJoinBanner()
    if KL._joinBanner then return KL._joinBanner end
    local f = CreateFrame("Frame", "BIT_KL_JoinBanner", UIParent, "BackdropTemplate")
    f:SetSize(440, 132)
    f:SetFrameStrata("HIGH")
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    -- Mouse interaction is enabled only in preview mode (see ShowJoinBanner);
    -- the real, brief banner stays click-through so it never eats clicks
    -- in the middle of the screen.
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(0, 0, 0, 0.78)
    f:SetBackdropBorderColor(0.9, 0.75, 0.2, 0.9)
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        _saveJoinBannerPos(self)
    end)

    f.accent = f:CreateTexture(nil, "ARTWORK")
    f.accent:SetColorTexture(0.9, 0.75, 0.2, 1)
    f.accent:SetPoint("TOPLEFT", 1, -1)
    f.accent:SetPoint("TOPRIGHT", -1, -1)
    f.accent:SetHeight(2)

    f.titleFS    = f:CreateFontString(nil, "OVERLAY")
    f.dungeonFS  = f:CreateFontString(nil, "OVERLAY")
    f.categoryFS = f:CreateFontString(nil, "OVERLAY")
    f.leaderFS   = f:CreateFontString(nil, "OVERLAY")
    f.commentFS  = f:CreateFontString(nil, "OVERLAY")
    for _, fs in ipairs({ f.titleFS, f.dungeonFS, f.categoryFS, f.leaderFS, f.commentFS }) do
        fs:SetJustifyH("CENTER")
        -- Long listing titles / comments wrap onto additional lines; the
        -- banner height is measured AFTER wrapping (see ShowJoinBanner) so
        -- it grows downward instead of the text spilling past the edge.
        fs:SetWordWrap(true)
    end

    f.fadeOut = f:CreateAnimationGroup()
    local a = f.fadeOut:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0)
    a:SetDuration(JOIN_BANNER_FADE)
    a:SetStartDelay(JOIN_BANNER_HOLD)
    f.fadeOut:SetScript("OnFinished", function() f:Hide() end)

    f:Hide()
    KL._joinBanner = f
    return f
end

-- info = { title, dungeon, category, leader, comment }  (any field may be nil)
function KL:ShowJoinBanner(info, isPreview)
    if not info then return end
    local f = _ensureJoinBanner()

    -- Paint with the same theme the settings window uses.
    local pal = _joinBannerPalette()
    local bg  = (pal and pal.bg)     or { 0.06, 0.06, 0.08 }
    local ac  = (pal and pal.accent) or { 0.9, 0.75, 0.2 }
    f:SetBackdropColor(bg[1], bg[2], bg[3], 0.92)
    f:SetBackdropBorderColor(ac[1], ac[2], ac[3], 1)
    if f.accent then f.accent:SetColorTexture(ac[1], ac[2], ac[3], 1) end

    applyConfiguredFont(f.titleFS, 22)
    applyConfiguredFont(f.dungeonFS, 16)
    applyConfiguredFont(f.categoryFS, 12)
    applyConfiguredFont(f.leaderFS, 13)
    applyConfiguredFont(f.commentFS, 12)
    -- Title uses the theme accent; the preview passes a class-coloured name
    -- (embedded |c..| code) which overrides this base colour for that text.
    f.titleFS:SetTextColor(ac[1], ac[2], ac[3])
    f.dungeonFS:SetTextColor(1, 1, 1)
    f.categoryFS:SetTextColor(0.7, 0.7, 0.7)
    f.leaderFS:SetTextColor(0.6, 0.85, 0.6)
    f.commentFS:SetTextColor(0.75, 0.75, 0.75)

    -- Constrain each line's WIDTH before measuring: with word wrap on, a
    -- width-bound FontString reports its wrapped multi-line height via
    -- GetStringHeight. Measuring before the width was applied (the old
    -- order) returned the single-line height, so long comments overflowed
    -- the banner instead of growing it downward.
    local innerW = (f:GetWidth() or 440) - 24
    local lines = {}
    local function add(fs, text)
        if text and text ~= "" then
            fs:SetWidth(innerW)
            fs:SetText(text); fs:Show(); lines[#lines + 1] = fs
        else
            fs:Hide()
        end
    end
    add(f.titleFS, info.title)
    add(f.dungeonFS, info.dungeon)
    add(f.categoryFS, info.category and (L("KEY_BANNER_CATEGORY", "Category") .. ": " .. info.category) or nil)
    add(f.leaderFS, info.leader and (L("KEY_BANNER_LEADER", "Leader") .. ": " .. info.leader) or nil)
    add(f.commentFS, info.comment and ('"' .. info.comment .. '"') or nil)

    -- Stack the visible lines top→down, centered, and size the frame to fit
    -- the WRAPPED heights (banner grows downward with long comments).
    local pad, gap = 16, 6
    local totalH = pad
    for i, fs in ipairs(lines) do
        totalH = totalH + (fs:GetStringHeight() or 14)
        if i < #lines then totalH = totalH + gap end
    end
    totalH = totalH + pad
    f:SetHeight(math.max(56, totalH))
    local y = -pad
    for _, fs in ipairs(lines) do
        fs:ClearAllPoints()
        fs:SetPoint("TOP", f, "TOP", 0, y)
        y = y - (fs:GetStringHeight() or 14) - gap
    end

    _positionJoinBanner(f)
    f.fadeOut:Stop()
    f:SetAlpha(1)
    f._isPreview = isPreview and true or false
    f:EnableMouse(f._isPreview)  -- draggable only while previewing
    f:Show()
    if not isPreview then
        f.fadeOut:Play()
    end
end

function KL:HideJoinBanner()
    if KL._joinBanner then
        KL._joinBanner.fadeOut:Stop()
        KL._joinBanner:Hide()
    end
end

-- Persistent (non-fading) sample banner the user can drag into place.
-- Shown together with the Keystone List test layout (see ToggleTestMode)
-- so both placeholders are positioned in one go.
function KL:ShowJoinBannerPreview()
    KL:ShowJoinBanner(_ownKeystoneBannerInfo(), true)
end

-- Group Finder category names by categoryID (for the banner's Category line).
local JOIN_BANNER_CATEGORIES = {
    [1]   = "Quest",
    [2]   = "Dungeon",
    [3]   = "Raid",
    [4]   = "Arena",
    [5]   = "Scenario",
    [6]   = "Custom",
    [7]   = "Skirmish",
    [8]   = "Battleground",
    [9]   = "Rated Battleground",
    [10]  = "Ashran",
    [113] = "Torghast",
    [121] = "Delves",
}

-- Fired on LFG_LIST_APPLICATION_STATUS_UPDATED. When our application is
-- accepted (we're joining a Group Finder group), read the listing info
-- and show the banner immediately — the same moment the listing is still
-- queryable. (Earlier this deferred to GROUP_JOINED, which could fire
-- before this event and miss the banner entirely.)
local function _OnJoinBannerStatus(searchResultID, newStatus)
    if not isEnabled() then return end
    if not (BIT.db and BIT.db.keystoneListJoinBanner ~= false) then return end
    if newStatus ~= "inviteaccepted" then return end
    if not (searchResultID and C_LFGList and C_LFGList.GetSearchResultInfo) then return end
    local ok, res = pcall(C_LFGList.GetSearchResultInfo, searchResultID)
    if not ok or not res then return end

    local activityID
    local okA, ids = pcall(function() return res.activityIDs end)
    if okA and type(ids) == "table" and ids[1] then
        activityID = ids[1]
    else
        local okS, sid = pcall(function() return res.activityID end)
        if okS and sid then activityID = sid end
    end

    local dungeon, category
    if activityID and C_LFGList.GetActivityInfoTable then
        local okI, ainfo = pcall(C_LFGList.GetActivityInfoTable, activityID)
        if okI and ainfo then
            dungeon = _safeStr(ainfo.fullName)
            local cid = ainfo.categoryID
            if cid == 2 then
                category = L("KEY_BANNER_DUNGEON", "Dungeon")
            elseif cid then
                category = JOIN_BANNER_CATEGORIES[cid]
            end
        end
    end

    local title   = _safeStr(res.name)
    local leader  = _safeStr(res.leaderName)
    local comment = _safeStr(res.comment)
    if not (title or dungeon) then return end

    KL:ShowJoinBanner({
        title = title, dungeon = dungeon, category = category,
        leader = leader, comment = comment,
    })
end

local function onGroupJoined()
    if not isEnabled() then return end
    -- (The join banner is shown directly from _OnJoinBannerStatus when the
    -- Group Finder application is accepted — not here.)
    if broadcastTimer and broadcastTimer.Cancel then broadcastTimer:Cancel() end
    broadcastTimer = C_Timer.NewTimer(SHOW_DELAY, function()
        broadcastSend()
        broadcastRequest()
        requestExternalKeystoneData()
    end)
end

local function onGroupLeft()
    -- Clear non-self entries
    local self_ = getPlayerFullName()
    for owner in pairs(keystonesDB) do
        if owner ~= self_ then
            keystonesDB[owner] = nil
            nativClients[owner] = nil
        end
    end
    KL:RebuildDisplays()
end

-- Lightweight refresh: re-evaluates the port-status text on every visible
-- row without rebuilding/re-laying-out anything. Cheap enough to call from
-- SPELL_UPDATE_COOLDOWN which fires very frequently.
local function refreshPortStatusOnly()
    if not isEnabled() or not mainFrame or not mainFrame:IsShown() then return end
    local showNoPort = BIT.db and BIT.db.keystoneListShowNoPort ~= false
    local self_     = getPlayerFullName()
    for _, row in ipairs(activeRows) do
        local k = dbGetKeystone(row.keystoneOwner)
        if k and k.challengeMapID then
            local isSelfRow = (k.keystoneOwner == self_)
            local status, _r, portID = getPortStatus(k.challengeMapID, isSelfRow)
            if showNoPort then
                if status == "noport" and portID then
                    row.noPortText:SetText(L("KEY_NO_PORT", "no port"))
                    row.noPortText:Show()
                elseif status == "cooldown" then
                    row.noPortText:SetText(L("KEY_PORT_CD", "Port CD"))
                    row.noPortText:Show()
                else
                    row.noPortText:Hide()
                end
            end
        end
    end
end

------------------------------------------------------------
-- Event frame setup
------------------------------------------------------------
local function setupEvents()
    if KL._eventFrame then return end
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("GROUP_JOINED")
    f:RegisterEvent("GROUP_LEFT")
    f:RegisterEvent("CHALLENGE_MODE_START")
    f:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    f:RegisterEvent("CHALLENGE_MODE_RESET")
    -- ITEM_CHANGED + CHAT_MSG_LOOT replaced with BAG_UPDATE_DELAYED in 3.6.3.
    -- The old events deliver hyperlinks / messages that can be Midnight
    -- "secret" values; just receiving them was enough to taint the addon
    -- on some setups. BAG_UPDATE_DELAYED fires with no arguments and
    -- covers most scenarios (loot, key consumption, key looted).
    f:RegisterEvent("BAG_UPDATE_DELAYED")
    -- Keystone NPC-downgrade: the item ID (180653) doesn't change when
    -- you talk to the NPC and reduce your key, only the item LINK changes.
    -- That doesn't fire BAG_UPDATE_DELAYED because the bag's item set is
    -- identical. ITEM_CHANGED would catch it but we can't use it (taint).
    -- Workaround: hook gossip-close events — when the user finishes
    -- talking to ANY NPC we kick off a debounced personal-keystone
    -- refresh. Cheap when nothing changed; instant update when it did.
    -- Both events pass no hyperlink args so they're taint-safe.
    f:RegisterEvent("GOSSIP_CLOSED")
    f:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
    f:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    f:RegisterEvent("CHAT_MSG_ADDON")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    -- M+ Group Finder queue → dungeon icon glow.
    -- ACTIVE_ENTRY_UPDATE: leader path (own listing was created/removed).
    -- APPLICATION_STATUS_UPDATED: applicant path (joined someone's group).
    -- See `_OnLfgEvent` above for the full state machine + activityID
    -- → challengeMapID resolution.
    f:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
    f:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
    -- Player-only spell-cast watch: clear the queue glow as soon as the
    -- user successfully casts the M+ port spell for the currently-glowing
    -- dungeon. The glow's purpose is "remind me where we're going" — once
    -- you hit the port, the cue has done its job and shouldn't keep
    -- pulsing. RegisterUnitEvent constrains delivery to "player" only so
    -- the engine doesn't hand us nameplate / pet / party casts we'd
    -- discard one line later.
    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    -- Cast-progress visualization on the dungeon icon. UNIT_SPELLCAST_START
    -- fires the moment the player begins channelling a teleport; STOP /
    -- FAILED / INTERRUPTED close the window if the cast is cancelled
    -- before completion (move, take damage, manual cancel). SUCCEEDED
    -- already registered above handles the successful-cast case.
    f:RegisterUnitEvent("UNIT_SPELLCAST_START",       "player")
    f:RegisterUnitEvent("UNIT_SPELLCAST_STOP",        "player")
    f:RegisterUnitEvent("UNIT_SPELLCAST_FAILED",      "player")
    f:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    f:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            onPlayerEnteringWorld(...)
            -- Auto-clear queue glow when entering a 5-man instance (we're
            -- now AT the dungeon, no reminder needed). pcall because
            -- IsInInstance returns secret values in some 12.x edge cases.
            local ok, _, instType = pcall(IsInInstance)
            if ok and instType == "party" then KL:ClearDungeonGlow() end
        elseif event == "GROUP_ROSTER_UPDATE" then
            onGroupRosterUpdate()
            -- LFG queue glow (applicant path): if we accepted an invite
            -- but the group wasn't full yet at that moment, this is the
            -- event that tells us the late joiner(s) have arrived and
            -- the group is now 5/5. _TryFireApplicantGlow short-circuits
            -- if there's no pending state or the group still isn't full.
            _TryFireApplicantGlow()
        elseif event == "GROUP_JOINED" then
            onGroupJoined()
        elseif event == "GROUP_LEFT" then
            onGroupLeft()
            -- Leaving the queued group → drop the glow; the listing it
            -- pointed to is no longer relevant.
            KL:ClearDungeonGlow()
        elseif event == "CHALLENGE_MODE_START" then
            onChallengeModeStart()
            -- Run started → glow served its purpose, clear it.
            KL:ClearDungeonGlow()
        elseif event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_RESET" then
            onChallengeModeCompleted()
        elseif event == "BAG_UPDATE_DELAYED" then
            onBagUpdateDelayed()
        elseif event == "GOSSIP_CLOSED" or event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
            -- Catches keystone NPC downgrade where the item link changes
            -- without bag contents changing. Cheap, debounced, taint-safe.
            if isEnabled() then scheduleKeystoneRefresh() end
        elseif event == "WEEKLY_REWARDS_UPDATE" then
            onWeeklyRewardsUpdate()
        elseif event == "CHAT_MSG_ADDON" then
            onAddonMessage(...)
        elseif event == "ZONE_CHANGED_NEW_AREA" then
            if isEnabled() then KL:RebuildDisplays() end
        elseif event == "SPELL_UPDATE_COOLDOWN" then
            -- Lightweight: just re-check port status text per visible row.
            -- Avoid full RebuildDisplays since this event fires constantly.
            refreshPortStatusOnly()
        elseif event == "LFG_LIST_ACTIVE_ENTRY_UPDATE"
            or event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
            _OnLfgEvent(event, ...)
            -- Independently capture join-banner info (not gated by the
            -- queue-glow feature, which _OnLfgEvent early-returns on).
            if event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
                _OnJoinBannerStatus(...)
            end
        elseif event == "UNIT_SPELLCAST_START" then
            -- Player just began a channel (teleport spells channel for
            -- ~8s). If the spell matches one of the dungeon icons on
            -- the list, start the fill animation on that row.
            local _, _, spellID = ...
            if spellID then _startCastAnimation(spellID) end
        elseif event == "UNIT_SPELLCAST_STOP"
            or event == "UNIT_SPELLCAST_FAILED"
            or event == "UNIT_SPELLCAST_INTERRUPTED" then
            -- Cast cancelled (moved, took damage, manually cancelled,
            -- or simply ended). Hide the overlay. SUCCEEDED below also
            -- calls this for the completion case.
            _stopCastAnimation()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            -- Successful cast: end the fill animation cleanly.
            _stopCastAnimation()
            -- Clear queue glow when the user ports to the glowing
            -- dungeon. spellID is the 3rd payload arg (after unit and
            -- castGUID). Compare via pcall — Midnight 12.x sometimes
            -- delivers tainted "secret" spellIDs whose equality check
            -- can throw on tainted operands.
            if _glowedMapID then
                local _, _, spellID = ...
                if spellID then
                    local portID = getDungeonPort(_glowedMapID)
                    local ok, isMatch = pcall(function() return spellID == portID end)
                    if ok and isMatch then
                        KL:ClearDungeonGlow()
                    end
                end
            end
        end
    end)
    KL._eventFrame = f
    -- Bill the event handler to the Keystone List module in the
    -- settings CPU footer.
    BIT.Prof.Attach("KEYSTONE_LIST", f)

    -- Register the addon message prefix
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        if not C_ChatInfo.IsAddonMessagePrefixRegistered or
           not C_ChatInfo.IsAddonMessagePrefixRegistered(CHAT_PREFIX) then
            C_ChatInfo.RegisterAddonMessagePrefix(CHAT_PREFIX)
        end
    end
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
-- Shared initial-broadcast routine. Called from both Initialize (on
-- /reload or first login) and onPlayerEnteringWorld. Doing it from
-- Initialize covers the case where PLAYER_ENTERING_WORLD already fired
-- before our event handler was registered — without this, the user has
-- to toggle the feature off+on to see the list after a /reload.
-- Assigned (not declared) — the local was forward-declared earlier so
-- the event handlers above can capture it as an upvalue.
runInitialBroadcast = function(isInitialOrReload)
    if not isEnabled() then return end
    local self_ = getPlayerFullName()
    if self_ then registerNativClient(self_) end
    updatePersonalKeystone()
    broadcastSend()
    broadcastRequest()
    if isInitialOrReload then
        requestExternalKeystoneData()
    end
    local active = false
    if C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive then
        local ok, v = pcall(C_ChallengeMode.IsChallengeModeActive)
        if ok then active = v end
    elseif C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
        local ok, lvl = pcall(C_ChallengeMode.GetActiveKeystoneInfo)
        if ok then active = (lvl and lvl ~= 0) or false end
    end
    challengeModeActive = active
    KL:RebuildDisplays()
end

------------------------------------------------------------
-- First-run intro announcement — chat-message based as of 3.6.3. The
-- previous StaticPopup implementation registered an entry in Blizzard's
-- StaticPopupDialogs table at file-load time, which left a permanent
-- footprint in a Blizzard-managed global. A chat message is read-only
-- and cannot be a taint vector.
------------------------------------------------------------
local function showIntroAnnouncement()
    local msg = L("KEY_INTRO_TEXT", "")
    if msg and msg ~= "" then
        -- Ensure each line starts with a visible prefix
        for line in (msg .. "\n"):gmatch("(.-)\n") do
            if line ~= "" then
                DEFAULT_CHAT_FRAME:AddMessage("|cff0091ed[BliZzi Party Tools]|r " .. line)
            end
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff0091ed[BliZzi Party Tools]|r " ..
        L("KEY_INTRO_HINT", "Type /blizzi → Keystone List → Enable to turn the feature on."))
end

local function maybeShowIntroPopup()
    if not BliZziInterruptsSavedVars then return end
    if BliZziInterruptsSavedVars.keystoneListIntroSeen == true then return end
    -- Already discovered + enabled the feature themselves? No need to nag.
    if BIT.db and BIT.db.keystoneListEnabled == true then
        BliZziInterruptsSavedVars.keystoneListIntroSeen = true
        return
    end
    -- 8 s delay so the announcement doesn't pile on top of other addons'
    -- login chat spam.
    C_Timer.After(8, function()
        if not BliZziInterruptsSavedVars then return end
        if BliZziInterruptsSavedVars.keystoneListIntroSeen == true then return end
        BliZziInterruptsSavedVars.keystoneListIntroSeen = true
        showIntroAnnouncement()
    end)
end

-- Test trigger: clears the seen flag and prints the chat announcement
-- right away. Call from chat:  /run BIT.KeystoneList:ResetIntroPopup()
function KL:ResetIntroPopup()
    if BliZziInterruptsSavedVars then
        BliZziInterruptsSavedVars.keystoneListIntroSeen = nil
    end
    showIntroAnnouncement()
end

function KL:Initialize()
    if not BIT.db then return end
    setupEvents()

    -- Resolve optional libraries (may already be loaded by other addons)
    if LibStub and LibStub.GetLibrary then
        openRaidLib = LibStub:GetLibrary("LibOpenRaid-1.0", true)
        libKeystone = LibStub:GetLibrary("LibKeystone", true)
    end
    if openRaidLib then setupOpenRaidCallback() end
    if libKeystone then setupLibKeystoneCallback() end

    if isEnabled() then
        ensureMainFrame()
        -- Run initial broadcast IMMEDIATELY so the list appears right after
        -- /reload, with a 0.5s retry as backup in case APIs weren't ready.
        -- PLAYER_ENTERING_WORLD often fires before Initialize (which is
        -- one-frame-deferred from PLAYER_LOGIN), so we can't depend on its
        -- handler alone — without this, the user used to wait several
        -- seconds (or toggle off+on) for the list to appear.
        runInitialBroadcast(true)
        C_Timer.After(0.5, function() runInitialBroadcast(true) end)
    end

    -- Optional: announce the feature once via popup if the user hasn't
    -- enabled it yet and hasn't seen the intro popup before.
    maybeShowIntroPopup()
end

function KL:SetEnabled(enabled)
    if not BIT.db then return end
    BIT.db.keystoneListEnabled = enabled and true or false
    if enabled then
        ensureMainFrame()
        -- Apply scale + position immediately so the frame appears at the
        -- user's saved coordinates / size — important when SetEnabled is
        -- called from _postImport (the imported keystoneListPosX/Y and
        -- keystoneListScale must take effect without a /reload).
        applyFrameScale()
        applyFramePosition()
        local self_ = getPlayerFullName()
        if self_ then registerNativClient(self_) end
        updatePersonalKeystone()
        broadcastSend()
        broadcastRequest()
        requestExternalKeystoneData()
        self:RebuildDisplays()
    else
        -- Disabling the feature wipes test mode too — no point preserving
        -- a preview the user can no longer see.
        if self._testMode then
            self._testMode = false
            clearTestKeystones()
        end
        if mainFrame then fadeOutFrame(mainFrame) end
    end
end

-- Public preview method — fires an announce with the current template
-- and a fake remaining time, so the user can see what the message looks
-- like even when their port is currently ready. If the player is in a
-- group it sends to PARTY/RAID for real testing; if solo it prints
-- locally as a preview-only sample. Test mode also forces local-only
-- to avoid spamming a real group during layout previews.
function KL:PreviewPortCdAnnounce()
    if not BIT.db then return end
    -- Pick a sample dungeon: player's own keystone first, else any
    -- entry in the DB, else fall back to a Midnight S1 mapID.
    local self_ = getPlayerFullName()
    local k = self_ and dbGetKeystone(self_)
    local mapID, level
    if k then
        mapID = k.challengeMapID
        level = k.keystoneLevel
    else
        for owner, ent in pairs(keystonesDB) do
            mapID = ent.challengeMapID
            level = ent.keystoneLevel
            break
        end
    end
    if not mapID then mapID = 558 end  -- Magisters' Terrace fallback
    if not level then level = 18      end

    local fakeRemain = 8 * 60 + 32  -- 8m 32s — pretty mid-cooldown sample

    local template = BIT.db.keystoneListPortCdMessage or ""
    if template == "" then
        template = L("KEY_PORTCD_DEFAULT", "Sorry, could I get a port please? My {dungeon} port is on cooldown ({remain} left).")
    end
    local msg = substitutePortVars(template, mapID, level, fakeRemain)
    if msg == "" then return end
    -- Mirror the newline-collapsing the live announce does, so the test
    -- preview shows exactly what the recipient would see.
    msg = msg:gsub("[\r\n\t]+", " ")
    msg = msg:gsub("%s+", " ")

    -- Always preview locally (visible only to the user). Sending to PARTY
    -- here would spam a real group with test messages — the real announce
    -- still fires when the user clicks an icon while the port is on CD.
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff0091ed[BIT Preview]|r " .. msg
        .. "  |cffaaaaaa(" .. L("KEY_PORTCD_TEST_NOTE", "preview only — actual announce goes to party / raid") .. ")|r")
end

-- Test trigger for the shift-click keystone-post feature. Builds a
-- preview message using the requested own/other template + sample
-- data and prints it ONLY to the user's local chat frame — the real
-- post fires when the user shift-clicks a keystone-list icon. Same
-- "send to local-only chat for previews" rule as PreviewPortCdAnnounce.
function KL:PreviewKeystonePost(isOwn)
    if not BIT.db then return end
    -- Pick a sample dungeon: own keystone first, else any DB entry,
    -- else fall back to Magisters' Terrace +18.
    local self_ = getPlayerFullName()
    local own = self_ and dbGetKeystone(self_)
    local mapID, level
    if own then
        mapID = own.challengeMapID
        level = own.keystoneLevel
    else
        for _, ent in pairs(keystonesDB) do
            mapID = ent.challengeMapID
            level = ent.keystoneLevel
            break
        end
    end
    if not mapID then mapID = 558 end  -- Magisters' Terrace fallback
    if not level then level = 18      end

    -- Sample owner display name. For own preview it's our own short
    -- name; for "other" preview a placeholder so the user can see
    -- what the {player} substitution looks like in chat output.
    local ownerDisplay
    if isOwn then
        ownerDisplay = own and own.displayName
            or (BIT.GetDisplayName and BIT.GetDisplayName(self_, "KEYSTONE_LIST"))
            or self_
            or "?"
    else
        ownerDisplay = L("KEY_POST_TEST_OTHER_NAME", "Tankzor")
    end

    local template
    if isOwn then
        template = BIT.db.keystoneListPostOwnText or ""
        if template == "" then
            template = L("KEY_POST_OWN_DEFAULT", "My key: {dungeon} +{level} {resilient}")
        end
    else
        template = BIT.db.keystoneListPostOtherText or ""
        if template == "" then
            template = L("KEY_POST_OTHER_DEFAULT", "{player}'s key: {dungeon} +{level} {resilient}")
        end
    end
    -- Force isResilient=true in previews so the user can SEE what the
    -- {resilient} substitution looks like in their template — the live
    -- post will only emit the marker if the actual clicked keystone has
    -- the resilient flag set.
    local msg = substituteKeystonePostVars(template, mapID, level, ownerDisplay, true)
    if msg == "" then return end

    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff0091ed[BIT Preview]|r " .. msg
        .. "  |cffaaaaaa(" .. L("KEY_POST_TEST_NOTE", "preview only — actual post goes to party / raid") .. ")|r")
end

function KL:OnSettingsChanged()
    if not isEnabled() then
        if mainFrame then fadeOutFrame(mainFrame) end
        return
    end
    ensureMainFrame()
    -- Re-apply the frame scale + position so a profile import (which
    -- writes keystoneListScale + keystoneListPosX/Y) lands the frame at
    -- the imported size and coordinates without a /reload.
    applyFrameScale()
    applyFramePosition()
    self:RebuildDisplays()
end

------------------------------------------------------------
-- Test mode — populates the frame with 5 sample rows so the user can
-- position the frame as if a full M+ group were present. Doesn't broadcast
-- anything; entries are local-only and tagged so they get cleaned up when
-- the user disables test mode.
------------------------------------------------------------
-- Fallback test pool used only if BIT.TEST_POOL isn't loaded yet for some
-- reason (e.g. another addon imitating the load order). The real pool comes
-- from Core.lua which exposes BIT.TEST_POOL — single source of truth so the
-- Interrupt Tracker test mode and the Keystone List test layout share the
-- same flavour names.
local FALLBACK_TEST_POOL = {
    { name = "Jvyx",       class = "DRUID"       },
    { name = "Klââsaim",   class = "HUNTER"      },
    { name = "Mírajane",   class = "MAGE"        },
    { name = "Pandavii",   class = "DEMONHUNTER" },
}

-- spawnTestKeystones / clearTestKeystones are forward-declared near the top
-- of the file (next to runInitialBroadcast) so KL:SetEnabled can see them
-- via closure. Assignment, not declaration.
spawnTestKeystones = function()
    -- Preview pool preference order:
    --   1. The upcoming Season 2 rotation (SEASON2_MAPS), keeping only
    --      maps the current client resolves to a name — previews the new
    --      season's dungeons before the patch drops them into GetMapTable.
    --   2. Top up from the live season table if fewer than 5 resolved.
    --   3. Midnight S1 hardcoded fallback as the last resort.
    local mapIDs, seen = {}, {}
    if C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
        for _, id in ipairs(SEASON2_MAPS) do
            local ok, name = pcall(C_ChallengeMode.GetMapUIInfo, id)
            if ok and name then
                mapIDs[#mapIDs + 1] = id
                seen[id] = true
            end
        end
    end
    if #mapIDs < 5 and C_ChallengeMode and C_ChallengeMode.GetMapTable then
        local ok, t = pcall(C_ChallengeMode.GetMapTable)
        if ok and type(t) == "table" then
            for _, id in ipairs(t) do
                if not seen[id] then
                    mapIDs[#mapIDs + 1] = id
                    seen[id] = true
                end
            end
        end
    end
    if #mapIDs < 5 then
        -- Midnight S1 fallback
        mapIDs = { 557, 558, 559, 560, 556 }
    end
    -- Shuffle so repeated test runs show different dungeon orders
    for i = #mapIDs, 2, -1 do
        local j = math.random(i)
        mapIDs[i], mapIDs[j] = mapIDs[j], mapIDs[i]
    end

    -- Pick 4 distinct names from the shared interrupt-tracker test pool
    -- (BIT.TEST_POOL, defined in Core.lua). Shuffle a copy so each run
    -- shows different names; fall back to a small embedded list if the
    -- shared pool isn't available for any reason.
    local sourcePool = BIT.TEST_POOL or FALLBACK_TEST_POOL
    local shuffled = {}
    for _, p in ipairs(sourcePool) do shuffled[#shuffled + 1] = p end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    -- Use the player's REAL name + class for entry 1 so the preview feels
    -- realistic, but store under a fake "-Preview" owner so we don't stomp
    -- on the player's actual keystone in the DB. The display filter (in
    -- rebuildDisplays) shows only _isTest entries while test mode is on,
    -- so the player's real key is hidden and unaltered for the duration.
    local _, sCls   = UnitClass("player")
    local selfShort = UnitName("player") or "You"

    for i = 1, 5 do
        local mapID = mapIDs[((i - 1) % #mapIDs) + 1]
        local lvl   = math.random(12, 30)
        local name, class
        if i == 1 then
            name  = selfShort
            class = sCls or "WARRIOR"
        else
            -- Pick from shuffled pool. shuffled is 1-indexed and we need
            -- entries 2..5, so use shuffled[i-1] (1..4) skipping conflicts
            -- with the player's own name.
            local pick = shuffled[((i - 2) % #shuffled) + 1]
            if pick and pick.name == selfShort then
                pick = shuffled[(i % #shuffled) + 1]
            end
            name  = (pick and pick.name)  or ("Player" .. i)
            class = (pick and pick.class) or "WARRIOR"
        end
        local owner = name .. "-Preview"
        keystonesDB[owner] = {
            challengeMapID = mapID,
            keystoneLevel  = lvl,
            activityID     = 0,
            groupID        = 0,
            isResilient    = (lvl >= 12) and (i % 2 == 0),
            nativClient    = false,
            keystoneOwner  = owner,
            displayName    = name,
            class          = class,
            _isTest        = true,
            _isSelf        = (i == 1),  -- pin entry 1 as the "you" row in test mode
        }
    end
end

clearTestKeystones = function()
    for owner, k in pairs(keystonesDB) do
        if type(k) == "table" and k._isTest then
            keystonesDB[owner] = nil
        end
    end
end

function KL:IsTestModeActive()
    return self._testMode == true
end

function KL:ToggleTestMode()
    if not BIT.db then return end
    if self._testMode then
        self._testMode = false
        clearTestKeystones()
        -- After clearing, restore the real personal keystone if we have one
        updatePersonalKeystone()
        -- Drop the movable join-banner placeholder too.
        self:HideJoinBanner()
    else
        self._testMode = true
        BIT.db.keystoneListEnabled = true   -- force-enable so the frame shows
        ensureMainFrame()
        spawnTestKeystones()
        -- Also show the movable join-banner placeholder so it can be
        -- positioned alongside the list in one pass.
        self:ShowJoinBannerPreview()
    end
    self:RebuildDisplays()
end

-- CPU-footer attribution for the teleport-cast fill ticker (top-level
-- anonymous OnUpdate; wrapped after the fact).
BIT.Prof.Attach("KEYSTONE_LIST", _castTicker, "OnUpdate")

-- Hook into addon init (Core.lua calls BIT:Initialize at PLAYER_LOGIN).
-- We register a one-shot ADDON_LOADED handler so we don't depend on Core's order.
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self_, ev)
        if ev == "PLAYER_LOGIN" then
            self_:UnregisterEvent("PLAYER_LOGIN")
            -- Defer one frame so BIT.db is ready
            C_Timer.After(0, function()
                if BIT and BIT.KeystoneList and BIT.KeystoneList.Initialize then
                    pcall(BIT.KeystoneList.Initialize, BIT.KeystoneList)
                end
            end)
        end
    end)
end

------------------------------------------------------------
-- /bitports — teleport wiring report
--
-- Every season rotates the dungeon pool, and Blizzard hands out the new
-- teleport spells in a consecutive block that is usually assigned on the
-- PTR and re-assigned before the patch ships. A stale ID looks exactly
-- like "you don't own the teleport": getDungeonPort finds an entry,
-- knownSpell says no, the row renders as "no port" for someone who is
-- standing there with the teleport on their bars.
--
-- This walks the CURRENT season's dungeon list, shows what we have wired
-- up for each and whether it resolves, and — the part that saves the
-- guesswork — searches the player's own spellbook for the teleport that
-- belongs to that dungeon and prints its real spell ID. Whatever it
-- reports under FIX is what belongs in DUNGEON_INFO.
--
-- Lives here rather than in a chat one-liner because the chat box cuts
-- input at 255 characters, which silently truncates anything long enough
-- to do this job.
------------------------------------------------------------
SLASH_BITPORTS1 = "/bitports"
SlashCmdList["BITPORTS"] = function()
    local function C(hex, s) return "|cff" .. hex .. tostring(s) .. "|r" end
    print(C("0091ed", "BliZzi") .. " " .. C("ffa300", "Party Tools")
          .. " " .. C("aaaaaa", "[teleport report]") .. " ─────────────")

    -- Snapshot the player's spellbook once: { name = spellID }.
    local book = {}
    if C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines then
        local okN, lineCount = pcall(C_SpellBook.GetNumSpellBookSkillLines)
        for i = 1, (okN and lineCount or 0) do
            local okL, line = pcall(C_SpellBook.GetSpellBookSkillLineInfo, i)
            if okL and line and line.itemIndexOffset and line.numSpellBookItems then
                for j = line.itemIndexOffset + 1,
                        line.itemIndexOffset + line.numSpellBookItems do
                    local okI, item = pcall(C_SpellBook.GetSpellBookItemInfo, j,
                                            Enum.SpellBookSpellBank.Player)
                    if okI and item and item.name and item.spellID then
                        book[#book + 1] = { name = item.name, id = item.spellID }
                    end
                end
            end
        end
    end
    print(("  spellbook entries scanned: %d"):format(#book))

    -- Find a known spell whose name contains the dungeon's name (or vice
    -- versa). Locale-proof: both sides come from the running client.
    local function findTeleport(dungeonName)
        if not dungeonName or dungeonName == "" then return nil end
        local needle = dungeonName:lower()
        for _, s in ipairs(book) do
            local hay = s.name:lower()
            if hay:find(needle, 1, true) or needle:find(hay, 1, true) then
                return s.id, s.name
            end
        end
    end

    local okM, maps = pcall(C_ChallengeMode.GetMapTable)
    if not okM or type(maps) ~= "table" or #maps == 0 then
        print(C("ff8888", "  C_ChallengeMode.GetMapTable returned nothing — run this while logged in, outside a loading screen."))
        return
    end

    local broken = 0
    for _, mapID in ipairs(maps) do
        local okU, mapName = pcall(C_ChallengeMode.GetMapUIInfo, mapID)
        mapName = (okU and mapName) or "?"
        local wired  = getDungeonPort(mapID)
        local known  = wired and knownSpell(wired) or false
        local wiredName
        if wired and C_Spell and C_Spell.GetSpellName then
            local okS, n = pcall(C_Spell.GetSpellName, wired)
            wiredName = okS and n or nil
        end

        local state
        if not wired then          state = C("ff8888", "NOT IN TABLE")
        elseif known then          state = C("88ffaa", "ok")
        elseif not wiredName then  state = C("ff8888", "ID INVALID")
        else                       state = C("ffcc44", "not known to you") end

        print(("  [%d] %-28s %s  wired=%s %s"):format(
            mapID, mapName, state, tostring(wired), wiredName and ("(" .. wiredName .. ")") or ""))

        if not known then
            broken = broken + 1
            local realID, realName = findTeleport(mapName)
            if realID then
                print("        " .. C("88ffaa", "FIX") .. (" → [%d] = %d  -- %s")
                      :format(mapID, realID, realName))
            else
                print("        " .. C("aaaaaa", "no matching teleport in your spellbook (you may not own it)"))
            end
        end
    end
    print(("  %d of %d dungeons have no working teleport."):format(broken, #maps))
end
