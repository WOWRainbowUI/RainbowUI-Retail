--[[
    Loxx Interrupt Tracker v1.2.4 - Midnight 12.0.x

    Maintained by Loxxar.

    - Addon-to-addon sync (SendAddonMessage)
    - ShimmerTracker pattern for player CD (taint-safe)
    - ElvUI auto-detection (font, texture)
    - Simplified config (/loxx)
    - Corner drag-to-resize
    - SavedVariables

    Main chunk: ONLY plain CreateFrame("Frame") + RegisterEvent.
]]

local ADDON_NAME = "LoxxInterruptTracker"
local MSG_PREFIX = "LOXX"
local LOXX_VERSION = "1.2.4"
local LOXX_DB_VERSION = 4   -- bump when SavedVars schema changes

------------------------------------------------------------
-- Spell data (multiple possible interrupts per class/spec)
------------------------------------------------------------
local ALL_INTERRUPTS = {
    [6552]   = { name = "Pummel",            cd = 15, icon = 132938 },
    [1766]   = { name = "Kick",              cd = 15, icon = 132219 },
    [2139]   = { name = "Counterspell",      cd = 24, icon = 135856 },
    [57994]  = { name = "Wind Shear",        cd = 12, icon = 136018 },
    [106839] = { name = "Skull Bash",        cd = 15, icon = 236946 },
    [78675]  = { name = "Solar Beam",        cd = 60, icon = 236748 },
    [47528]  = { name = "Mind Freeze",       cd = 15, icon = 237527 },
    [96231]  = { name = "Rebuke",            cd = 15, icon = 523893 },
    [183752] = { name = "Disrupt",           cd = 15, icon = 1305153 },
    [116705] = { name = "Spear Hand Strike", cd = 15, icon = 608940 },
    [15487]  = { name = "Silence",           cd = 45, icon = 458230 },
    [147362] = { name = "Counter Shot",      cd = 24, icon = 249170 },
    [187707] = { name = "Muzzle",            cd = 15, icon = 1376045 },
    [19647]  = { name = "Spell Lock",        cd = 24, icon = 136174 },
    [132409] = { name = "Spell Lock",        cd = 24, icon = 136174 },
    [119914] = { name = "Axe Toss",          cd = 30, icon = "Interface\\Icons\\ability_warrior_titansgrip" },
    [1276467] = { name = "Fel Ravager",      cd = 25, icon = "Interface\\Icons\\spell_shadow_summonfelhunter" },
    [351338] = { name = "Quell",             cd = 20, icon = 4622469 },
}

-- Which spells to check per class (order matters: first found wins)
local CLASS_INTERRUPT_LIST = {
    WARRIOR     = { 6552 },
    ROGUE       = { 1766 },
    MAGE        = { 2139 },
    SHAMAN      = { 57994 },
    DRUID       = { 106839, 78675 },           -- Skull Bash (feral/guardian), Solar Beam (balance)
    DEATHKNIGHT = { 47528 },
    PALADIN     = { 96231 },
    DEMONHUNTER = { 183752 },
    MONK        = { 116705 },
    PRIEST      = { 15487 },                    -- Silence (shadow only)
    HUNTER      = { 147362, 187707 },           -- Counter Shot (BM/MM), Muzzle (survival)
    WARLOCK     = { 19647, 132409, 119914 },
    EVOKER      = { 351338 },
}

local CLASS_COLORS = {
    WARRIOR     = { 0.78, 0.61, 0.43 },
    ROGUE       = { 1.00, 0.96, 0.41 },
    MAGE        = { 0.41, 0.80, 0.94 },
    SHAMAN      = { 0.00, 0.44, 0.87 },
    DRUID       = { 1.00, 0.49, 0.04 },
    DEATHKNIGHT = { 0.77, 0.12, 0.23 },
    PALADIN     = { 0.96, 0.55, 0.73 },
    DEMONHUNTER = { 0.64, 0.19, 0.79 },
    MONK        = { 0.00, 1.00, 0.59 },
    PRIEST      = { 1.00, 1.00, 1.00 },
    HUNTER      = { 0.67, 0.83, 0.45 },
    WARLOCK     = { 0.58, 0.51, 0.79 },
    EVOKER      = { 0.20, 0.58, 0.50 },
}

------------------------------------------------------------
-- Defaults
------------------------------------------------------------
local DEFAULTS = {
    frameWidth      = 180,  -- fixed — no auto-scaling
    barHeight       = 20,   -- fixed — fits 12px font
    locked          = false,
    showTitle       = true,
    alpha           = 0.9,
    nameFontSize    = 12,
    readyFontSize   = 12,
    readyTextSize   = 12,
    showReady       = true,
    showInDungeon   = true,
    showInOpenWorld = true,
    showInArena     = false,
    soundOnReady    = false,
    soundID         = 8960,
    showTooltip     = true,
    hideOutOfCombat = false,
    rotationEnabled = false,
}

------------------------------------------------------------
-- Sound list for the "Sound on Ready" dropdown
-- Each entry: { name = "Display Name", id = numericSoundID }
-- IDs resolved from SOUNDKIT at runtime; numeric fallback if needed.
------------------------------------------------------------
local function SK(key, fallback)
    return (SOUNDKIT and SOUNDKIT[key]) or fallback
end
local SOUND_LIST = {
    { name = "Sound1", id = SK("AUCTION_WINDOW_OPEN",            3087)  },
    { name = "Sound2", id = SK("PVP_THROUGH_QUEUE_READY_CHECK", 12867)  },
}

------------------------------------------------------------
-- State
------------------------------------------------------------
local db
local myClass, myName, mySpellID
local myCachedCD
local myBaseCd                  -- real base CD from spellbook (with talents)
local myKickCdEnd = 0           -- clean tracking of our own kick CD
local myIsPetSpell = false      -- is our primary kick a pet spell?
local myExtraKicks = {}         -- extra kicks for own player {spellID → {baseCd, cdEnd}}
local partyAddonUsers = {}
local bars = {}
local wasOnCd = {}            -- tracks CD state per player key for sound transitions
local MAX_BARS        = 40   -- absolute cap (supports up to 40-man raids)
local currentMaxBars  = 7    -- updated dynamically based on group size
local mainFrame, titleText, configFrame
local updateTicker
local ready = false
local lastAnnounce = 0
local testMode = false
local testTicker = nil
local inCombat = false
local spyMode = false
-- Forward declarations: defined later in the stats/rotation block but called earlier
local RecordKick
local AdvanceRotation
local BroadcastRotation
local loxxCurrentRun  = nil   -- stats: current instance run
local statsFrame      = nil   -- stats window
local rotationPanel   = nil   -- rotation management panel
local rotationOrder   = {}    -- array of player names (ordered)
local rotationIndex   = 1     -- current player's turn (1-based)
-- Error log (in-memory, also persisted via SavedVars)
local loxxErrorLog = {}
local loxxLastErr  = ""
local loxxErrCount = 0

-- String-keyed version for laundered (still-tainted) spellID lookups
local ALL_INTERRUPTS_STR = {}
for id, data in pairs(ALL_INTERRUPTS) do
    ALL_INTERRUPTS_STR[tostring(id)] = data
end

-- String-keyed versions of talent tables.
-- C_Traits.GetDefinitionInfo returns defInfo.spellID as a secret value in WoW 12.0+,
-- which can't be used as a numeric table key. Fallback: convert to string.
local CD_REDUCTION_TALENTS_STR = {}
local CD_ON_KICK_TALENTS_STR   = {}
local EXTRA_KICK_TALENTS_STR   = {}

-- Class → primary interrupt mapping (for auto-detection when mob gets interrupted)
local CLASS_INTERRUPTS = {
    WARRIOR     = { id = 6552,   cd = 15, name = "Pummel" },
    ROGUE       = { id = 1766,   cd = 15, name = "Kick" },
    MAGE        = { id = 2139,   cd = 24, name = "Counterspell" },
    SHAMAN      = { id = 57994,  cd = 12, name = "Wind Shear" },
    DRUID       = { id = 106839, cd = 15, name = "Skull Bash" },
    DEATHKNIGHT = { id = 47528,  cd = 15, name = "Mind Freeze" },
    PALADIN     = { id = 96231,  cd = 15, name = "Rebuke" },
    DEMONHUNTER = { id = 183752, cd = 15, name = "Disrupt" },
    HUNTER      = { id = 147362, cd = 24, name = "Counter Shot" },
    MONK        = { id = 116705, cd = 15, name = "Spear Hand Strike" },
    WARLOCK     = { id = 19647,  cd = 24, name = "Spell Lock" },
    PRIEST      = { id = 15487,  cd = 45, name = "Silence" },
    EVOKER      = { id = 351338, cd = 20, name = "Quell" },
}

-- SpecID → interrupt override (when spec changes the interrupt or CD)
local SPEC_INTERRUPT_OVERRIDES = {
    [255]  = { id = 187707,  cd = 15, name = "Muzzle" },          -- Survival Hunter
    [264]  = { id = 57994,   cd = 30, name = "Wind Shear" },      -- Restoration Shaman (30s vs 12s for Ele/Enh)
    [266]  = { id = 119914,  cd = 30, name = "Axe Toss", isPet = true, petSpellID = 89766 },  -- Demonology Warlock (Felguard)
}

-- Specs that have NO interrupt (remove from tracker after inspect)
-- Be conservative: only list specs we're SURE have no interrupt
local SPEC_NO_INTERRUPT = {
    [256]  = true, -- Discipline Priest (no Silence)
    [257]  = true, -- Holy Priest (no Silence)
    [105]  = true, -- Restoration Druid (Skull Bash removed in 12.0)
    [65]   = true, -- Holy Paladin (no Rebuke)
    -- [1468] = true, -- Preservation Evoker - verify if Quell removed
    -- [270]  = true, -- Mistweaver Monk - verify if Spear Hand Strike removed
}

-- Talents that PERMANENTLY reduce interrupt cooldowns (scanned via inspect)
local CD_REDUCTION_TALENTS = {
    -- Hunter: Lone Survivor - "Counter Shot and Muzzle CD reduced by 2 sec" (passive)
    [388039] = { affects = 147362, reduction = 2,  name = "Lone Survivor" },
    -- Evoker: Interwoven Threads - "All spell CDs reduced by 10%" (percentage)
    [412713] = { affects = 351338, pctReduction = 10, name = "Interwoven Threads" },
}

-- Talents that reduce CD only on SUCCESSFUL interrupt (applied per-kick, not on baseCd)
local CD_ON_KICK_TALENTS = {
    -- DK: Coldthirst - "Mind Freeze CD reduced by 3 sec on successful interrupt"
    [378848] = { reduction = 3, name = "Coldthirst" },
}

-- Talents that grant an EXTRA interrupt ability (second bar)
local EXTRA_KICK_TALENTS = {
    -- (auto-detected dynamically when a different kick is used)
}

-- Populate string-keyed talent tables (built after numeric tables are defined)
for id, v in pairs(CD_REDUCTION_TALENTS) do CD_REDUCTION_TALENTS_STR[tostring(id)] = v end
for id, v in pairs(CD_ON_KICK_TALENTS)   do CD_ON_KICK_TALENTS_STR[tostring(id)]   = v end
for id, v in pairs(EXTRA_KICK_TALENTS)   do EXTRA_KICK_TALENTS_STR[tostring(id)]   = v end

-- Specs that always have extra kicks
local SPEC_EXTRA_KICKS = {
    [266] = {
        { id = 132409, cd = 24, name = "Fel Ravager / Spell Lock",
          icon = "Interface\\Icons\\spell_shadow_summonfelhunter",
          talentCheck = 1276467 },  -- Check if Grimoire: Fel Ravager talent is known
    },
}

-- Spell aliases: some spells fire different IDs on party vs own client
-- e.g., Fel Ravager summon fires as 1276467 on party but 132409 on own
local SPELL_ALIASES = {
    [1276467] = 132409,  -- Fel Ravager summon → Spell Lock extra kick bar
    [132409]  = 19647,   -- Command Demon: Spell Lock → primary Spell Lock bar (19647)
                         -- Note: Demo Warlock extra kick check still uses original spellID before alias
}

-- Inspect queue
local inspectQueue = {}
local inspectBusy = false
local inspectUnit = nil
local inspectedPlayers = {} -- name → true
local noInterruptPlayers = {} -- name → true (healers etc. with no kick)


local spyCastCount = 0
local partyFrames = {}
local partyPetFrames = {}
-- Pre-create party watcher frames at load time (clean untainted context)
for i = 1, 4 do
    partyFrames[i] = CreateFrame("Frame")
    partyPetFrames[i] = CreateFrame("Frame")
end
local RegisterPartyWatchers

-- Use the game's default font (supports all locales: Latin, Cyrillic, Korean, Chinese)
local FONT_FACE = GameFontNormal and GameFontNormal:GetFont() or "Fonts\\FRIZQT__.TTF"
local FONT_FLAGS  = "OUTLINE"
local BAR_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"
local FLAT_TEX    = "Interface\\BUTTONS\\WHITE8X8"

-- Locale-specific font fallbacks (if GameFontNormal not available at load time)
local LOCALE_FONTS = {
    ["koKR"] = "Fonts\\2002.TTF",
    ["zhCN"] = "Fonts\\ARKai_T.TTF",
    ["zhTW"] = "Fonts\\blei00d.TTF",
    ["ruRU"] = "Fonts\\FRIZQT___CYR.TTF",
}

------------------------------------------------------------
-- Error logger
------------------------------------------------------------
local function LoxxLogError(msg)
    local ts = date("%H:%M:%S")
    if msg == loxxLastErr then
        loxxErrCount = loxxErrCount + 1
        if loxxErrCount > 5 then return end  -- suppress storm of identical errors
        msg = msg .. " (x" .. loxxErrCount .. ")"
    else
        loxxLastErr  = msg
        loxxErrCount = 1
    end
    local entry = "[" .. ts .. "] " .. msg
    table.insert(loxxErrorLog, 1, entry)   -- newest first
    while #loxxErrorLog > 50 do table.remove(loxxErrorLog) end
    if LOXXSavedVars then LOXXSavedVars.loxxErrorLog = loxxErrorLog end
end

------------------------------------------------------------
-- ElvUI detection
------------------------------------------------------------
local function DetectElvUI()
    -- Apply locale font fallback if needed
    local locale = GetLocale()
    if LOCALE_FONTS[locale] and FONT_FACE == "Fonts\\FRIZQT__.TTF" then
        FONT_FACE = LOCALE_FONTS[locale]
    end
    -- Re-read from GameFontNormal in case it's ready now
    if GameFontNormal then
        local gf = GameFontNormal:GetFont()
        if gf then FONT_FACE = gf end
    end

    if ElvUI then
        local E = unpack(ElvUI)
        if E and E.media then
            if E.media.normFont then FONT_FACE = E.media.normFont end
            if E.media.normTex then BAR_TEXTURE = E.media.normTex end
        end
    end
end

------------------------------------------------------------
-- Communication
------------------------------------------------------------
local function SendLOXX(msg)
    -- Pick the correct channel BEFORE sending to avoid system error messages.
    -- PARTY works outside instances; INSTANCE_CHAT works inside M+/raids.
    local inInstance = IsInInstance()
    local channel = inInstance and "INSTANCE_CHAT" or "PARTY"
    pcall(C_ChatInfo.SendAddonMessage, MSG_PREFIX, msg, channel)
end

local function ReadMyBaseCd()
    if not mySpellID then return end
    local ok, ms = pcall(GetSpellBaseCooldown, mySpellID)
    if ok and ms then
        local clean = tonumber(string.format("%.0f", ms))
        if clean and clean > 0 then
            myBaseCd = clean / 1000
        end
    end
    -- TryCacheCD gives actual observed CD (after all modifiers)
    if myCachedCD and myCachedCD > 1.5 then
        myBaseCd = myCachedCD
    end
end

local function AnnounceJoin()
    if not myClass or not mySpellID then return end
    local now = GetTime()
    if now - lastAnnounce < 3 then return end
    lastAnnounce = now
    ReadMyBaseCd()
    local cd = myBaseCd or ALL_INTERRUPTS[mySpellID].cd
    SendLOXX("JOIN:" .. myClass .. ":" .. mySpellID .. ":" .. cd)
end

local function OnAddonMessage(prefix, message, channel, sender)
    if prefix ~= MSG_PREFIX then return end
    local shortName = Ambiguate(sender, "short")
    local parts = { strsplit(":", message) }
    local command = parts[1]

    -- PING: don't filter self (for diagnostics)
    if command == "PING" then
        local via = parts[2] or "unknown"
        local self_tag = (shortName == myName) and " |cFFFFFF00(SELF)|r" or ""
        print("|cFF00DDDD[LOXX]|r Received PING from |cFF00FF00" .. shortName .. "|r channel=" .. tostring(channel) .. " tag=" .. via .. self_tag)
        return
    end

    -- All other messages: filter self
    if shortName == myName then return end

    if command == "JOIN" then
        local cls = parts[2]
        local spellID = tonumber(parts[3])
        local baseCd = tonumber(parts[4])
        if cls and CLASS_COLORS[cls] and spellID and ALL_INTERRUPTS[spellID] then
            partyAddonUsers[shortName] = partyAddonUsers[shortName] or {}
            partyAddonUsers[shortName].class = cls
            partyAddonUsers[shortName].spellID = spellID
            partyAddonUsers[shortName].cdEnd = partyAddonUsers[shortName].cdEnd or 0
            if baseCd and baseCd > 0 then
                partyAddonUsers[shortName].baseCd = baseCd
            end
            AnnounceJoin()
        end
    elseif command == "CAST" then
        local cd = tonumber(parts[2])
        if cd and cd > 0 and partyAddonUsers[shortName] then
            partyAddonUsers[shortName].cdEnd = GetTime() + cd
            partyAddonUsers[shortName].baseCd = cd
            RecordKick(shortName)
        end
    elseif command == "ROT" then
        -- ROT:player1,player2,...:index
        local playersPart = parts[2]
        local idxPart = tonumber(parts[3])
        if playersPart and idxPart then
            local names = {}
            for n in playersPart:gmatch("[^,]+") do names[#names+1] = n end
            rotationOrder = names
            rotationIndex = math.max(1, math.min(idxPart, #names))
            if LOXXSavedVars then
                LOXXSavedVars.rotationOrder = rotationOrder
                LOXXSavedVars.rotationIndex = rotationIndex
            end
        end
    elseif command == "ROT_IDX" then
        local idx = tonumber(parts[2])
        if idx and #rotationOrder > 0 then
            rotationIndex = math.max(1, math.min(idx, #rotationOrder))
            if LOXXSavedVars then LOXXSavedVars.rotationIndex = rotationIndex end
        end
    end
end

local function OnSpellCastSucceeded(unit, castGUID, spellID, isParty, cleanName)
    if isParty and cleanName and spellID then
        local now = GetTime()
        -- Resolve alias (e.g., 1276467 Fel Ravager summon → 132409 Spell Lock)
        local resolvedID = SPELL_ALIASES[spellID] or spellID
        if partyAddonUsers[cleanName] then
            local info = partyAddonUsers[cleanName]
            -- Check if it's an extra kick first (check both original and resolved ID)
            local isExtra = false
            if info.extraKicks then
                for _, ek in ipairs(info.extraKicks) do
                    if resolvedID == ek.spellID or spellID == ek.spellID then
                        ek.cdEnd = now + ek.baseCd
                        isExtra = true
                        if spyMode then
                            print("|cFF00DDDD[SPY]|r " .. cleanName .. " used extra kick " .. ek.name .. " → CD=" .. ek.baseCd .. "s (spellID=" .. spellID .. " resolved=" .. resolvedID .. ")")
                        end
                        break
                    end
                end
            end
            if not isExtra then
                -- If this is a different interrupt than primary, auto-add as extra
                if info.spellID and resolvedID ~= info.spellID and ALL_INTERRUPTS[resolvedID] then
                    if not info.extraKicks then info.extraKicks = {} end
                    -- Check it's not already there
                    local found = false
                    for _, ek in ipairs(info.extraKicks) do
                        if ek.spellID == resolvedID then found = true; break end
                    end
                    if not found then
                        local ekData = ALL_INTERRUPTS[resolvedID]
                        table.insert(info.extraKicks, {
                            spellID = resolvedID,
                            baseCd = ekData.cd,
                            cdEnd = now + ekData.cd,
                            name = ekData.name,
                        })
                        if spyMode then
                            print("|cFF00DDDD[SPY]|r Auto-added extra kick for " .. cleanName .. ": " .. ekData.name .. " CD=" .. ekData.cd .. "s")
                        end
                    else
                        -- Update existing extra kick
                        for _, ek in ipairs(info.extraKicks) do
                            if ek.spellID == resolvedID then
                                ek.cdEnd = now + ek.baseCd
                                break
                            end
                        end
                    end
                else
                    -- Primary kick
                    local baseCd = info.baseCd or (ALL_INTERRUPTS[resolvedID] and ALL_INTERRUPTS[resolvedID].cd) or 15
                    info.cdEnd = now + baseCd
                    info.lastKickTime = now
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r " .. cleanName .. " used kick → CD=" .. baseCd .. "s (pending confirm)")
                    end
                end
            end
        else
            -- Don't auto-register players known to have no interrupt
            if noInterruptPlayers[cleanName] then return end
            local ok, _, cls = pcall(UnitClass, unit)
            if ok and cls and CLASS_COLORS[cls] then
                -- Also check role: skip healers (except shaman)
                local role = UnitGroupRolesAssigned(unit)
                if role == "HEALER" and cls ~= "SHAMAN" then
                    noInterruptPlayers[cleanName] = true
                    return
                end
                partyAddonUsers[cleanName] = {
                    class = cls,
                    spellID = spellID,
                    baseCd = ALL_INTERRUPTS[spellID] and ALL_INTERRUPTS[spellID].cd or 15,
                    cdEnd = now + (ALL_INTERRUPTS[spellID] and ALL_INTERRUPTS[spellID].cd or 15),
                    lastKickTime = now,
                }
            end
        end
        return
    end

    -- Own kicks (player or pet for warlock)
    if unit ~= "player" and unit ~= "pet" then return end
    if not ALL_INTERRUPTS[spellID] then return end

    -- Check if it's an extra kick
    if myExtraKicks[spellID] then
        myExtraKicks[spellID].cdEnd = GetTime() + myExtraKicks[spellID].baseCd
        if spyMode then
            print("|cFF00DDDD[SPY]|r Own extra kick: " .. (myExtraKicks[spellID].name or "?") .. " CD=" .. myExtraKicks[spellID].baseCd)
        end
        return
    end

    -- If this is a DIFFERENT interrupt than our primary, auto-add as extra
    if mySpellID and spellID ~= mySpellID then
        local data = ALL_INTERRUPTS[spellID]
        myExtraKicks[spellID] = { baseCd = data.cd, cdEnd = GetTime() + data.cd }
        if spyMode then
            print("|cFF00DDDD[SPY]|r Auto-added extra kick: " .. data.name .. " CD=" .. data.cd)
        end
        return
    end

    local cd = myCachedCD or myBaseCd or ALL_INTERRUPTS[spellID].cd
    myKickCdEnd = GetTime() + cd
    SendLOXX("CAST:" .. cd)
    RecordKick(myName)
    AdvanceRotation()
end

local function CleanPartyList()
    if testMode then return end
    local currentNames = {}
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then currentNames[UnitName(u)] = true end
    end
    for name in pairs(partyAddonUsers) do
        if not currentNames[name] then partyAddonUsers[name] = nil end
    end
    -- Clean inspect caches for people who left
    for name in pairs(noInterruptPlayers) do
        if not currentNames[name] then
            noInterruptPlayers[name] = nil
            inspectedPlayers[name] = nil
        end
    end
    for name in pairs(inspectedPlayers) do
        if not currentNames[name] then inspectedPlayers[name] = nil end
    end
    AnnounceJoin()
end

-- Auto-register party members by class (no addon comms needed!)
-- This is the key to working in M+ where SendAddonMessage is blocked
local HEALER_KEEPS_KICK = {
    SHAMAN  = true, -- Resto Shaman keeps Wind Shear
}

local function AutoRegisterPartyByClass()
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then
            local name = UnitName(u)
            local _, cls = UnitClass(u)
            if name and cls and CLASS_INTERRUPTS[cls] then
                if not partyAddonUsers[name] and not noInterruptPlayers[name] then
                    -- Skip healers from classes that lose their kick as healer
                    local role = UnitGroupRolesAssigned(u)
                    if role == "HEALER" and not HEALER_KEEPS_KICK[cls] then
                        if spyMode then
                            print("|cFF00DDDD[SPY]|r Skipping " .. name .. " (" .. cls .. " HEALER) - no kick expected")
                        end
                    else
                        local kickInfo = CLASS_INTERRUPTS[cls]
                        partyAddonUsers[name] = {
                            class = cls,
                            spellID = kickInfo.id,
                            baseCd = kickInfo.cd,
                            cdEnd = 0,
                        }
                        if spyMode then
                            print("|cFF00DDDD[SPY]|r Auto-registered " .. name .. " (" .. cls .. ") " .. kickInfo.name .. " CD=" .. kickInfo.cd)
                        end
                    end
                end
            end
        end
    end
end

------------------------------------------------------------
-- Inspect party members for spec + talents (before M+ key)
------------------------------------------------------------
local function ScanInspectTalents(unit)
    local name = UnitName(unit)
    if not name then return end
    local info = partyAddonUsers[name]
    if not info then return end

    -- 1) Get spec → override interrupt if needed, or remove if no interrupt
    local specID = GetInspectSpecialization(unit)
    if specID and specID > 0 then
        -- Remove talent-checked extra kicks (will be re-added if talent found)
        if info.extraKicks and SPEC_EXTRA_KICKS[specID] then
            for _, extraSpec in ipairs(SPEC_EXTRA_KICKS[specID]) do
                if extraSpec.talentCheck then
                    for j = #info.extraKicks, 1, -1 do
                        if info.extraKicks[j].spellID == extraSpec.id then
                            table.remove(info.extraKicks, j)
                            if spyMode then
                                print("|cFF00DDDD[SPY]|r Removed " .. extraSpec.name .. " from " .. name .. " (re-inspecting)")
                            end
                        end
                    end
                end
            end
        end
        -- Check if this spec has NO interrupt
        if SPEC_NO_INTERRUPT[specID] then
            partyAddonUsers[name] = nil
            inspectedPlayers[name] = true
            noInterruptPlayers[name] = true
            if spyMode then
                print("|cFF00DDDD[SPY]|r " .. name .. " has no interrupt (specID=" .. specID .. ") → removed")
            end
            return
        end
        local override = SPEC_INTERRUPT_OVERRIDES[specID]
        if override then
            local applyOverride = true
            -- For pet-based overrides, check if the correct pet is active
            if override.isPet then
                -- Find the pet unit for this party member
                local petUnit = nil
                if unit == "player" then
                    petUnit = "pet"
                else
                    local idx = unit:match("party(%d)")
                    if idx then petUnit = "partypet" .. idx end
                end
                if petUnit and UnitExists(petUnit) then
                    local family = UnitCreatureFamily(petUnit)
                    -- Axe Toss = Felguard only. If Felhunter/Imp/etc, skip override
                    if override.id == 119914 and family and family ~= "Felguard" then
                        applyOverride = false
                        if spyMode then
                            print("|cFF00DDDD[SPY]|r Spec override " .. override.name .. " SKIPPED for " .. name .. " (pet=" .. tostring(family) .. ", not Felguard)")
                        end
                    end
                elseif petUnit and not UnitExists(petUnit) then
                    -- No pet out → skip pet override
                    applyOverride = false
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r Spec override " .. override.name .. " SKIPPED for " .. name .. " (no pet)")
                    end
                end
            end
            if applyOverride then
                info.spellID = override.id
                info.baseCd = override.cd
                if spyMode then
                    print("|cFF00DDDD[SPY]|r Spec override for " .. name .. ": " .. override.name .. " CD=" .. override.cd .. " (specID=" .. specID .. ")")
                end
            else
                -- Fall back to default warlock kick (Spell Lock)
                local fallbackID = 19647
                if ALL_INTERRUPTS[fallbackID] then
                    info.spellID = fallbackID
                    info.baseCd = ALL_INTERRUPTS[fallbackID].cd
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r Fallback for " .. name .. ": Spell Lock CD=" .. info.baseCd)
                    end
                end
            end
        end
        -- Add extra kicks for this spec
        local extraSpecs = SPEC_EXTRA_KICKS[specID]
        if extraSpecs then
            if not info.extraKicks then info.extraKicks = {} end
            for _, extraSpec in ipairs(extraSpecs) do
                -- If talentCheck is set, skip here — will be added during talent tree scan
                if not extraSpec.talentCheck then
                    local found = false
                    for _, ek in ipairs(info.extraKicks) do
                        if ek.spellID == extraSpec.id then found = true; break end
                    end
                    if not found then
                        table.insert(info.extraKicks, {
                            spellID = extraSpec.id,
                            baseCd = extraSpec.cd,
                            cdEnd = 0,
                            name = extraSpec.name,
                            icon = extraSpec.icon,
                        })
                        if spyMode then
                            print("|cFF00FF00[SPY]|r " .. name .. " spec extra kick: " .. extraSpec.name .. " CD=" .. extraSpec.cd .. "s")
                        end
                    end
                elseif spyMode then
                    print("|cFF00DDDD[SPY]|r " .. name .. " extra kick " .. extraSpec.name .. " deferred to talent scan (check " .. extraSpec.talentCheck .. ")")
                end
            end
        end
    end

    -- 2) Scan talent tree for CD-reduction talents
    local configID = -1 -- Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID
    local ok, configInfo = pcall(C_Traits.GetConfigInfo, configID)
    if not ok or not configInfo or not configInfo.treeIDs or #configInfo.treeIDs == 0 then
        if spyMode then print("|cFF00DDDD[SPY]|r No trait config for " .. name) end
        return
    end

    local treeID = configInfo.treeIDs[1]
    local ok2, nodeIDs = pcall(C_Traits.GetTreeNodes, treeID)
    if not ok2 or not nodeIDs then
        if spyMode then print("|cFF00DDDD[SPY]|r No tree nodes for " .. name) end
        return
    end

    if spyMode then
        print("|cFF00DDDD[SPY]|r Scanning " .. #nodeIDs .. " talent nodes for " .. name)
    end

    for _, nodeID in ipairs(nodeIDs) do
        local ok3, nodeInfo = pcall(C_Traits.GetNodeInfo, configID, nodeID)
        if ok3 and nodeInfo and nodeInfo.activeEntry and nodeInfo.activeRank and nodeInfo.activeRank > 0 then
            local entryID = nodeInfo.activeEntry.entryID
            if entryID then
                local ok4, entryInfo = pcall(C_Traits.GetEntryInfo, configID, entryID)
                if ok4 and entryInfo and entryInfo.definitionID then
                    local ok5, defInfo = pcall(C_Traits.GetDefinitionInfo, entryInfo.definitionID)
                    if ok5 and defInfo and defInfo.spellID then
                        -- Check passive CD reductions
                        -- In WoW 12.0+, defInfo.spellID may be a secret value that
                        -- can't be used as a numeric table key. Try numeric first,
                        -- then fall back to a string-keyed version of each table.
                        local defSpellID = defInfo.spellID
                        local defSpellStr = nil
                        do
                            local sok, s = pcall(tostring, defSpellID)
                            if sok then defSpellStr = s end
                        end
                        local talent = (pcall(function() return CD_REDUCTION_TALENTS[defSpellID] end) and CD_REDUCTION_TALENTS[defSpellID])
                            or (defSpellStr and CD_REDUCTION_TALENTS_STR[defSpellStr])
                        if talent then
                            local newCd
                            if talent.pctReduction then
                                -- Percentage reduction (e.g., Interwoven Threads: -10%)
                                newCd = info.baseCd * (1 - talent.pctReduction / 100)
                                newCd = math.floor(newCd + 0.5) -- round
                            else
                                -- Flat reduction
                                newCd = info.baseCd - talent.reduction
                            end
                            if newCd < 1 then newCd = 1 end
                            info.baseCd = newCd
                            if spyMode then
                                print("|cFF00FF00[SPY]|r " .. name .. " has |cFFFFFF00" .. talent.name .. "|r → CD adjusted to " .. newCd .. "s")
                            end
                        end
                        -- Check conditional CD reductions (on successful kick)
                        local onKick = (pcall(function() return CD_ON_KICK_TALENTS[defSpellID] end) and CD_ON_KICK_TALENTS[defSpellID])
                            or (defSpellStr and CD_ON_KICK_TALENTS_STR[defSpellStr])
                        if onKick then
                            info.onKickReduction = onKick.reduction
                            if spyMode then
                                print("|cFF00FF00[SPY]|r " .. name .. " has |cFFFFFF00" .. onKick.name .. "|r → -" .. onKick.reduction .. "s on successful kick")
                            end
                        end
                        -- Check extra kick talents (second interrupt ability)
                        local extra = (pcall(function() return EXTRA_KICK_TALENTS[defSpellID] end) and EXTRA_KICK_TALENTS[defSpellID])
                            or (defSpellStr and EXTRA_KICK_TALENTS_STR[defSpellStr])
                        if extra then
                            if not info.extraKicks then info.extraKicks = {} end
                            table.insert(info.extraKicks, {
                                spellID = extra.id,
                                baseCd = extra.cd,
                                cdEnd = 0,
                                name = extra.name,
                            })
                            if spyMode then
                                print("|cFF00FF00[SPY]|r " .. name .. " has |cFFFFFF00" .. extra.name .. "|r → extra kick CD=" .. extra.cd .. "s")
                            end
                        end
                        -- Check SPEC_EXTRA_KICKS with talentCheck (e.g., Grimoire: Fel Ravager)
                        if specID and SPEC_EXTRA_KICKS[specID] then
                            for _, extraSpec in ipairs(SPEC_EXTRA_KICKS[specID]) do
                                local matchesTalent = false
                                if extraSpec.talentCheck then
                                    local ok1, eq1 = pcall(function() return extraSpec.talentCheck == defSpellID end)
                                    if ok1 and eq1 then matchesTalent = true end
                                    if not matchesTalent and defSpellStr then
                                        matchesTalent = (tostring(extraSpec.talentCheck) == defSpellStr)
                                    end
                                end
                                if matchesTalent then
                                    if not info.extraKicks then info.extraKicks = {} end
                                    local found = false
                                    for _, ek in ipairs(info.extraKicks) do
                                        if ek.spellID == extraSpec.id then found = true; break end
                                    end
                                    if not found then
                                        table.insert(info.extraKicks, {
                                            spellID = extraSpec.id,
                                            baseCd = extraSpec.cd,
                                            cdEnd = 0,
                                            name = extraSpec.name,
                                            icon = extraSpec.icon,
                                        })
                                        if spyMode then
                                            print("|cFF00FF00[SPY]|r " .. name .. " has talent " .. (defSpellStr or "?") .. " → extra kick " .. extraSpec.name .. " CD=" .. extraSpec.cd .. "s")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    inspectedPlayers[name] = true
    if spyMode then
        print("|cFF00DDDD[SPY]|r Inspect done for " .. name .. " → " .. (ALL_INTERRUPTS[info.spellID] and ALL_INTERRUPTS[info.spellID].name or "?") .. " CD=" .. info.baseCd)
    end
end

local function ProcessInspectQueue()
    if inspectBusy then return end
    while #inspectQueue > 0 do
        local unit = table.remove(inspectQueue, 1)
        if UnitExists(unit) and UnitIsConnected(unit) then
            local name = UnitName(unit)
            if name and not inspectedPlayers[name] then
                inspectBusy = true
                inspectUnit = unit
                NotifyInspect(unit)
                if spyMode then
                    print("|cFF00DDDD[SPY]|r NotifyInspect(" .. unit .. ") → " .. name)
                end
                return
            end
        end
    end
end

local function QueuePartyInspect()
    inspectQueue = {}
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then
            local name = UnitName(u)
            if name and not inspectedPlayers[name] then
                table.insert(inspectQueue, u)
            end
        end
    end
    ProcessInspectQueue()
end
------------------------------------------------------------
-- Compute bar layout from frame size
------------------------------------------------------------
local function GetBarLayout()
    local fw = db.frameWidth
    local titleH = db.showTitle and 20 or 0
    local barH = math.max(12, db.barHeight)
    local iconS = barH
    local barW = fw - iconS
    barW = math.max(60, barW)
    local fontSize      = math.max(2, db.nameFontSize  or 12)
    local cdFontSize    = math.max(2, db.readyFontSize or 12)
    local readyFontSize = math.max(2, db.readyTextSize or 12)
    return barW, barH, iconS, fontSize, cdFontSize, titleH, readyFontSize
end

------------------------------------------------------------
-- Update currentMaxBars based on group size
------------------------------------------------------------
local function UpdateMaxBars()
    local groupSize = GetNumGroupMembers()
    local inRaid    = IsInRaid()
    local needed
    if not inRaid then
        needed = 7          -- party (5) + buffer for extra kicks
    elseif groupSize <= 10 then
        needed = 12         -- 10-man raid + buffer
    elseif groupSize <= 20 then
        needed = 22         -- 20-man raid + buffer
    else
        needed = 42         -- 40-man raid + buffer
    end
    needed = math.min(needed, MAX_BARS)
    if needed ~= currentMaxBars then
        currentMaxBars = needed
        return true   -- caller should RebuildBars
    end
    return false
end

------------------------------------------------------------
-- Rebuild bars
------------------------------------------------------------
local function RebuildBars()
    UpdateMaxBars()
    for i = 1, MAX_BARS do
        if bars[i] then
            bars[i]:Hide()
            bars[i]:SetParent(nil)
            bars[i] = nil
        end
    end

    local barW, barH, iconS, fontSize, cdFontSize, titleH, readyFontSzBuild = GetBarLayout()

    mainFrame:SetWidth(db.frameWidth)
    mainFrame:SetAlpha(db.alpha)

    if titleText then
        if db.showTitle then titleText:Show() else titleText:Hide() end
    end
    if mainFrame.titleBand then
        if db.showTitle then mainFrame.titleBand:Show() else mainFrame.titleBand:Hide() end
    end
    if mainFrame.titleSep then
        if db.showTitle then mainFrame.titleSep:Show() else mainFrame.titleSep:Hide() end
    end

    for i = 1, currentMaxBars do
        local yOff = -(titleH + (i - 1) * (barH + 1))

        local f = CreateFrame("Frame", nil, mainFrame)
        f:SetSize(iconS + barW - 6, barH)
        f:SetPoint("TOPLEFT", 3, yOff)

        -- Icon
        local ico = f:CreateTexture(nil, "ARTWORK")
        ico:SetSize(iconS, barH)
        ico:SetPoint("LEFT", 0, 0)
        ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        f.icon = ico

        -- Bar background (uniform dark, Details-style)
        local barBg = f:CreateTexture(nil, "BACKGROUND")
        barBg:SetPoint("TOPLEFT", iconS, 0)
        barBg:SetPoint("BOTTOMRIGHT", 0, 0)
        barBg:SetTexture(BAR_TEXTURE)
        barBg:SetVertexColor(0.08, 0.08, 0.08, 1)
        f.barBg = barBg

        -- StatusBar
        local sb = CreateFrame("StatusBar", nil, f)
        sb:SetPoint("TOPLEFT", iconS, 0)
        sb:SetPoint("BOTTOMRIGHT", 0, 0)
        sb:SetStatusBarTexture(BAR_TEXTURE)
        sb:SetStatusBarColor(1, 1, 1, 0.85)
        sb:SetMinMaxValues(0, 1)
        sb:SetValue(0)
        sb:SetFrameLevel(f:GetFrameLevel() + 1)
        f.cdBar = sb

        -- Content layer
        local content = CreateFrame("Frame", nil, f)
        content:SetPoint("TOPLEFT", iconS, 0)
        content:SetPoint("BOTTOMRIGHT", 0, 0)
        content:SetFrameLevel(sb:GetFrameLevel() + 1)

        -- Name text
        local nm = content:CreateFontString(nil, "OVERLAY")
        nm:SetFont(FONT_FACE, fontSize, FONT_FLAGS)
        nm:SetPoint("LEFT", 6, 0)
        nm:SetJustifyH("LEFT")
        nm:SetWidth(barW - 50)
        nm:SetWordWrap(false)
        nm:SetShadowOffset(1, -1)
        nm:SetShadowColor(0, 0, 0, 1)
        f.nameText = nm

        -- Party CD text
        local pcd = content:CreateFontString(nil, "OVERLAY")
        pcd:SetFont(FONT_FACE, cdFontSize, FONT_FLAGS)
        pcd:SetPoint("RIGHT", -6, 0)
        pcd:SetShadowOffset(1, -1)
        pcd:SetShadowColor(0, 0, 0, 1)
        f.partyCdText = pcd

        -- Player CD wrapper + text (taint-safe via SetAlphaFromBoolean)
        local wrap = CreateFrame("Frame", nil, content)
        wrap:SetAllPoints()
        wrap:SetFrameLevel(content:GetFrameLevel() + 1)
        local mycd = wrap:CreateFontString(nil, "OVERLAY")
        mycd:SetFont(FONT_FACE, cdFontSize, FONT_FLAGS)
        mycd:SetPoint("RIGHT", -6, 0)
        mycd:SetShadowOffset(1, -1)
        mycd:SetShadowColor(0, 0, 0, 1)
        f.playerCdWrapper = wrap
        f.playerCdText = mycd
        f.cdFontSz    = cdFontSize
        f.readyFontSz = readyFontSzBuild

        f:EnableMouse(true)
        f:SetScript("OnEnter", function(self)
            if not db.showTooltip then return end
            if not self.ttSpellName then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self.ttSpellName, 1, 1, 1)
            if self.ttRem and self.ttRem > 0 then
                GameTooltip:AddLine(string.format("CD: %.1fs / %.0fs", self.ttRem, self.ttBaseCd or 0), 1, 0.82, 0)
            else
                GameTooltip:AddLine("READY", 0, 1, 0)
            end
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function(self)
            if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
        end)

        -- Rotation highlight: yellow left border on the current rotation player's bar
        local rotHL = f:CreateTexture(nil, "OVERLAY")
        rotHL:SetTexture(FLAT_TEX)
        rotHL:SetVertexColor(1, 0.85, 0, 1)
        rotHL:SetPoint("TOPLEFT",    0, 0)
        rotHL:SetPoint("BOTTOMLEFT", 0, 0)
        rotHL:SetWidth(3)
        rotHL:Hide()
        f.rotHighlight = rotHL

        f:Hide()
        bars[i] = f
    end

end

------------------------------------------------------------
-- Display update
------------------------------------------------------------
local shouldShowByZone = true -- cached visibility state

local function CheckZoneVisibility()
    -- Raid (6+ players): always hide — not designed for large groups
    if IsInRaid() then
        shouldShowByZone = false
    else
        local _, instanceType = IsInInstance()
        if instanceType == "party" then
            shouldShowByZone = db.showInDungeon
        elseif instanceType == "arena" then
            shouldShowByZone = db.showInArena
        else
            shouldShowByZone = db.showInOpenWorld
        end
    end
    -- Combat-only mode: hide when out of combat
    local shouldShow = shouldShowByZone and (not db.hideOutOfCombat or inCombat)
    if mainFrame then
        if shouldShow then
            mainFrame:Show()
        else
            mainFrame:Hide()
        end
    end
end

local function UpdateDisplay()
    if not ready or not shouldShowByZone then return end

    local _, barH, _, _, _, titleH = GetBarLayout()
    local now = GetTime()
    local barIdx = 1

    -- ── Helper: render a party-side bar (partyCdText path) ───────
    local function RenderPartyBar(bar, icon, name, col, baseCd, rem, spellName)
        bar:Show()
        bar.icon:SetTexture(icon)
        bar.playerCdText:Hide()
        bar.playerCdWrapper:SetAlpha(1)
        bar.partyCdText:Show()
        bar.nameText:SetText("|cFFFFFFFF" .. name .. "|r")
        bar.cdBar:SetMinMaxValues(0, baseCd)
        -- Tooltip data
        bar.ttSpellName = spellName
        bar.ttBaseCd    = baseCd
        if rem > 0.5 then
            bar.cdBar:SetValue(rem)
            bar.cdBar:SetStatusBarColor(col[1], col[2], col[3], 0.85)
            bar.partyCdText:SetFont(FONT_FACE, bar.cdFontSz,   FONT_FLAGS)
            bar.partyCdText:SetText(string.format("%.0f", rem))
            bar.partyCdText:SetTextColor(1, 1, 1)
            bar.ttRem = rem
        else
            bar.cdBar:SetMinMaxValues(0, 1)
            bar.cdBar:SetValue(1)
            bar.cdBar:SetStatusBarColor(col[1], col[2], col[3], 0.35)
            bar.partyCdText:SetFont(FONT_FACE, bar.readyFontSz, FONT_FLAGS)
            bar.partyCdText:SetText(db.showReady and "READY" or "")
            bar.partyCdText:SetTextColor(0.2, 1.0, 0.2)
            bar.ttRem = 0
        end
    end

    -- ── 1. PLAYER'S OWN BAR (always first) ───────────────────────
    local mySpellData = mySpellID and ALL_INTERRUPTS[mySpellID]
    if mySpellData then
        local bar = bars[barIdx]
        bar:Show()
        bar.icon:SetTexture(mySpellData.icon)
        local col = CLASS_COLORS[myClass] or { 1, 1, 1 }
        bar.nameText:SetText("|cFFFFFFFF" .. (myName or "?") .. "|r")
        bar.ttSpellName = mySpellData.name
        bar.ttBaseCd    = myBaseCd or mySpellData.cd

        if myKickCdEnd > now then
            local cdRemaining = myKickCdEnd - now
            bar.partyCdText:Hide()
            bar.playerCdText:Show()
            bar.playerCdText:SetFont(FONT_FACE, bar.cdFontSz, FONT_FLAGS)
            bar.playerCdText:SetText(string.format("%.0f", cdRemaining))
            bar.playerCdText:SetTextColor(1, 1, 1)
            bar.cdBar:SetMinMaxValues(0, myBaseCd or mySpellData.cd)
            bar.cdBar:SetValue(cdRemaining)
            bar.cdBar:SetStatusBarColor(col[1], col[2], col[3], 0.85)
            bar.playerCdWrapper:SetAlpha(1)
            wasOnCd["__self__"] = true
            bar.ttRem = cdRemaining
        else
            if wasOnCd["__self__"] and db.soundOnReady then
                PlaySound(db.soundID or 8960, "Master")
            end
            wasOnCd["__self__"] = false
            bar.playerCdText:Hide()
            bar.playerCdWrapper:SetAlpha(1)
            bar.partyCdText:Show()
            bar.partyCdText:SetFont(FONT_FACE, bar.readyFontSz, FONT_FLAGS)
            bar.partyCdText:SetText(db.showReady and "READY" or "")
            bar.partyCdText:SetTextColor(0.2, 1.0, 0.2)
            bar.cdBar:SetMinMaxValues(0, 1)
            bar.cdBar:SetValue(1)
            bar.cdBar:SetStatusBarColor(col[1], col[2], col[3], 0.35)
            bar.ttRem = 0
        end
        -- Rotation highlight for self bar
        if bar.rotHighlight then
            local isRotTurn = db.rotationEnabled and rotationOrder[rotationIndex] == myName
            if isRotTurn then bar.rotHighlight:Show() else bar.rotHighlight:Hide() end
        end
        barIdx = barIdx + 1
    end

    -- ── 2. OWN EXTRA KICKS (e.g. Demo: Spell Lock + Fel Ravager) ─
    for ekKey, ekInfo in pairs(myExtraKicks) do
        if barIdx > currentMaxBars then break end
        local ekData = ALL_INTERRUPTS[ekKey]
        local ekIcon = ekInfo.icon or (ekData and ekData.icon)
        if ekIcon or ekData then
            local bar = bars[barIdx]
            bar:Show()
            bar.icon:SetTexture(ekIcon or (ekData and ekData.icon))
            local col = CLASS_COLORS[myClass] or { 1, 1, 1 }
            bar.nameText:SetText("|cFFFFFFFF" .. (myName or "?") .. "|r")
            bar.ttSpellName = ekInfo.name or (ekData and ekData.name) or "?"
            bar.ttBaseCd    = ekInfo.baseCd

            if ekInfo.cdEnd > now then
                local ekRem = ekInfo.cdEnd - now
                bar.partyCdText:Hide()
                bar.playerCdText:Show()
                bar.playerCdText:SetFont(FONT_FACE, bar.cdFontSz, FONT_FLAGS)
                bar.playerCdText:SetText(string.format("%.0f", ekRem))
                bar.playerCdText:SetTextColor(1, 1, 1)
                bar.cdBar:SetMinMaxValues(0, ekInfo.baseCd)
                bar.cdBar:SetValue(ekRem)
                bar.cdBar:SetStatusBarColor(col[1], col[2], col[3], 0.85)
                bar.playerCdWrapper:SetAlpha(1)
                bar.ttRem = ekRem
            else
                bar.playerCdText:Hide()
                bar.playerCdWrapper:SetAlpha(1)
                bar.partyCdText:Show()
                bar.partyCdText:SetFont(FONT_FACE, bar.readyFontSz, FONT_FLAGS)
                bar.partyCdText:SetText(db.showReady and "READY" or "")
                bar.partyCdText:SetTextColor(0.2, 1.0, 0.2)
                bar.cdBar:SetMinMaxValues(0, 1)
                bar.cdBar:SetValue(1)
                bar.cdBar:SetStatusBarColor(col[1], col[2], col[3], 0.35)
                bar.ttRem = 0
            end
            barIdx = barIdx + 1
        end
    end

    -- ── 3. PARTY BARS — collected then sorted ────────────────────
    -- Sort: READY first; within READY shorter baseCd first (more precious);
    --       within ON CD soonest-ready first.
    local partyEntries = {}
    for name, info in pairs(partyAddonUsers) do
        local ok, data = pcall(function() return info.spellID and ALL_INTERRUPTS[info.spellID] end)
        if ok and data then
            local rem = 0
            if info.cdEnd > now then rem = info.cdEnd - now end
            local baseCd = info.baseCd or data.cd
            table.insert(partyEntries, {
                kind    = "party",
                name    = name, info = info, data = data,
                rem     = rem,  baseCd = baseCd,
                isReady = (rem <= 0.5),
            })
        elseif spyMode and info.spellID then
            print("|cFFFF4400[LOXX]|r Unknown spellID=" .. tostring(info.spellID) .. " for " .. name)
        end

        if info.extraKicks then
            local col = CLASS_COLORS[info.class] or { 1, 1, 1 }
            for _, ek in ipairs(info.extraKicks) do
                local okEk, ekData = pcall(function()
                    return ek.spellID and ALL_INTERRUPTS[ek.spellID]
                end)
                local ekIcon = ek.icon or (okEk and ekData and ekData.icon)
                if ekIcon or (okEk and ekData) then
                    local ekRem = 0
                    if ek.cdEnd > now then ekRem = ek.cdEnd - now end
                    table.insert(partyEntries, {
                        kind    = "partyExtra",
                        name    = name, info = info, ek = ek,
                        ekData  = okEk and ekData, ekIcon = ekIcon,
                        ekRem   = ekRem, baseCd = ek.baseCd,
                        isReady = (ekRem <= 0.5), col = col,
                    })
                end
            end
        end
    end

    table.sort(partyEntries, function(a, b)
        if a.isReady ~= b.isReady then return a.isReady end
        if a.isReady then
            local aB, bB = (a.baseCd or 0), (b.baseCd or 0)
            if aB ~= bB then return aB < bB end
        else
            local aR = (a.kind == "party") and a.rem or a.ekRem
            local bR = (b.kind == "party") and b.rem or b.ekRem
            -- Snap to 0.1s grid: prevents bars from swapping every frame
            -- when two CDs expire nearly simultaneously (common in M+ chains).
            local aSnap = math.floor(aR * 10 + 0.5)
            local bSnap = math.floor(bR * 10 + 0.5)
            if aSnap ~= bSnap then return aSnap < bSnap end
        end
        return (a.name or "") < (b.name or "")  -- stable: alphabetical tiebreak
    end)

    for _, e in ipairs(partyEntries) do
        if barIdx > currentMaxBars then break end
        local bar = bars[barIdx]
        if e.kind == "party" then
            local col = CLASS_COLORS[e.info.class] or { 1, 1, 1 }
            RenderPartyBar(bar, e.data.icon, e.name, col, e.baseCd, e.rem, e.data.name)
            if e.rem <= 0.5 then
                if wasOnCd[e.name] and db.soundOnReady then
                    PlaySound(db.soundID or 8960, "Master")
                end
                wasOnCd[e.name] = false
            else
                wasOnCd[e.name] = true
            end
        else -- partyExtra
            local col = e.col
            local icon = e.ekIcon or (e.ekData and e.ekData.icon)
            local spName = (e.ekData and e.ekData.name) or (e.ek.name) or "?"
            RenderPartyBar(bar, icon, e.name, col, e.baseCd, e.ekRem, spName)
        end
        -- Rotation highlight for party bar
        if bar.rotHighlight then
            local isRotTurn = db.rotationEnabled and rotationOrder[rotationIndex] == e.name
            if isRotTurn then bar.rotHighlight:Show() else bar.rotHighlight:Hide() end
        end
        barIdx = barIdx + 1
    end

    for i = barIdx, currentMaxBars do bars[i]:Hide() end

    local numVisible = barIdx - 1

    -- ── Ligne "prochaine dispo globale" — toujours visible ───────────────
    local alertH = 0
    if mainFrame.alertBand then
        if numVisible == 0 then
            mainFrame.alertBand:Hide()
        else
            alertH = 22
            mainFrame.alertBand:Show()

            -- Iterate all players: count ready kicks, find next available
            local minRem      = nil
            local nextKicker  = nil
            local readyCount  = 0
            local firstName   = nil

            -- Helper: check if a kick (primary or extra) is ready for a player
            local function PlayerHasReadyKick(info, now)
                if not info then return false end
                if info.cdEnd and info.cdEnd <= now then return true end
                if info.extraKicks then
                    for _, ek in ipairs(info.extraKicks) do
                        if not ek.cdEnd or ek.cdEnd <= now then return true end
                    end
                end
                return false
            end
            local function PlayerNextRemaining(info, now)
                local best = nil
                if info and info.cdEnd and info.cdEnd > now then
                    best = info.cdEnd - now
                end
                if info and info.extraKicks then
                    for _, ek in ipairs(info.extraKicks) do
                        if ek.cdEnd and ek.cdEnd > now then
                            local r = ek.cdEnd - now
                            if best == nil or r < best then best = r end
                        end
                    end
                end
                return best
            end

            -- Self
            if mySpellID and ALL_INTERRUPTS[mySpellID] then
                if myKickCdEnd <= now then
                    readyCount = readyCount + 1
                    if firstName == nil then firstName = myName end
                else
                    local r = myKickCdEnd - now
                    if minRem == nil or r < minRem then minRem = r; nextKicker = myName end
                end
            end
            for _, ekInfo in pairs(myExtraKicks) do
                if ekInfo.cdEnd and ekInfo.cdEnd <= now then
                    readyCount = readyCount + 1
                    if firstName == nil then firstName = myName end
                elseif ekInfo.cdEnd and ekInfo.cdEnd > now then
                    local r = ekInfo.cdEnd - now
                    if minRem == nil or r < minRem then minRem = r; nextKicker = myName end
                end
            end

            -- Party
            for name, info in pairs(partyAddonUsers) do
                if PlayerHasReadyKick(info, now) then
                    readyCount = readyCount + 1
                    if firstName == nil then firstName = name end
                else
                    local r = PlayerNextRemaining(info, now)
                    if r and (minRem == nil or r < minRem) then minRem = r; nextKicker = name end
                end
            end

            if readyCount > 0 then
                mainFrame.alertBand.bg:SetVertexColor(0.0, 0.28, 0.0, 0.9)
                if readyCount == 1 then
                    mainFrame.alertBand.label:SetText(
                        "|cFF44FF44" .. (firstName or "?") .. " — READY|r")
                else
                    mainFrame.alertBand.label:SetText(string.format(
                        "|cFF44FF44%d kicks ready  (%s)|r", readyCount, firstName or "?"))
                end
            elseif minRem and minRem < 3 then
                mainFrame.alertBand.bg:SetVertexColor(0.55, 0.30, 0.0, 0.9)
                mainFrame.alertBand.label:SetText(string.format(
                    "|cFFFFAA00%s in %.1fs|r", nextKicker or "?", minRem))
            elseif minRem then
                mainFrame.alertBand.bg:SetVertexColor(0.50, 0.0, 0.0, 0.9)
                mainFrame.alertBand.label:SetText(string.format(
                    "|cFFFF3030NO KICK — %.0fs|r", minRem))
            else
                mainFrame.alertBand:Hide()
                alertH = 0
            end
        end
    end

    -- Auto-fit height to visible bars (do NOT touch position - was causing window to jump)
    if numVisible > 0 then
        mainFrame:SetHeight(titleH + numVisible * (barH + 1) + alertH)
    end
end

------------------------------------------------------------
-- Find my interrupt spell (check all possible for class/spec)
------------------------------------------------------------
local function FindMyInterrupt()
    local oldSpellID = mySpellID
    mySpellID = nil
    myIsPetSpell = false
    -- Preserve existing cdEnd values
    local oldExtraKicks = myExtraKicks
    myExtraKicks = {}

    -- Check if my spec has no interrupt (e.g., Resto Druid, Holy Priest)
    local specIndex = GetSpecialization()
    local specID = nil
    if specIndex then
        specID = GetSpecializationInfo(specIndex)
        if specID and SPEC_NO_INTERRUPT[specID] then
            if spyMode then
                print("|cFF00DDDD[SPY]|r My spec " .. specID .. " has no interrupt")
            end
            mySpellID = nil
            if oldSpellID then myCachedCD = nil; myBaseCd = nil end
            return
        end
    end

    -- Spec override for primary kick (e.g., Demo warlock → Axe Toss)
    if specID and SPEC_INTERRUPT_OVERRIDES[specID] then
        local override = SPEC_INTERRUPT_OVERRIDES[specID]
        -- For pet spells, verify the pet actually has this spell
        if override.isPet then
            local petKnown = false
            local method = "none"

            -- Method 1: IsSpellKnown(id, true) - pet spellbook
            if IsSpellKnown(override.id, true) then
                petKnown = true; method = "IsSpellKnown(pet)"
            end
            -- Method 2: Check actual pet spell ID (89766 = Axe Toss)
            if not petKnown and override.petSpellID and IsSpellKnown(override.petSpellID, true) then
                petKnown = true; method = "IsSpellKnown(petSpell)"
            end
            -- Method 3: IsSpellKnown(id) - player side (Command Demon wrapper)
            if not petKnown and IsSpellKnown(override.id) then
                petKnown = true; method = "IsSpellKnown(player)"
            end
            -- Method 4: IsPlayerSpell
            if not petKnown then
                local ok, result = pcall(IsPlayerSpell, override.id)
                if ok and result then petKnown = true; method = "IsPlayerSpell" end
            end
            -- Method 5: Check if pet exists and has Felguard spells
            if not petKnown and override.petSpellID and UnitExists("pet") then
                local ok, result = pcall(IsPlayerSpell, override.petSpellID)
                if ok and result then petKnown = true; method = "IsPlayerSpell(petSpell)" end
            end

            if spyMode then
                print("|cFF00DDDD[SPY]|r Pet override check: " .. override.name .. " → " .. method .. " petKnown=" .. tostring(petKnown))
            end

            if petKnown then
                mySpellID = override.id
                myBaseCd = override.cd
                myIsPetSpell = true
                if spyMode then
                    print("|cFF00DDDD[SPY]|r My spec override: " .. override.name .. " CD=" .. override.cd .. " (pet detected)")
                end
            else
                if spyMode then
                    local family = UnitExists("pet") and UnitCreatureFamily("pet") or "no pet"
                    print("|cFF00DDDD[SPY]|r Spec override " .. override.name .. " SKIPPED (pet=" .. tostring(family) .. ")")
                end
            end
        else
            mySpellID = override.id
            myBaseCd = override.cd
            myIsPetSpell = false
            if spyMode then
                print("|cFF00DDDD[SPY]|r My spec override: " .. override.name .. " CD=" .. override.cd)
            end
        end
    end

    -- Pre-add extra kicks by spec (only if the talent is actually known)
    if specID and SPEC_EXTRA_KICKS[specID] then
        for _, extra in ipairs(SPEC_EXTRA_KICKS[specID]) do
            -- If talentCheck is set, check that spell instead (e.g., check Grimoire: Fel Ravager talent, not Spell Lock)
            local checkID = extra.talentCheck or extra.id
            local known = IsSpellKnown(checkID) or IsSpellKnown(checkID, true)
            if not known then
                local ok, result = pcall(IsPlayerSpell, checkID)
                if ok and result then known = true end
            end
            if known then
                local oldCdEnd = oldExtraKicks[extra.id] and oldExtraKicks[extra.id].cdEnd or 0
                myExtraKicks[extra.id] = {
                    baseCd = extra.cd,
                    cdEnd = oldCdEnd,
                    name = extra.name,
                    icon = extra.icon,
                    talentCheck = extra.talentCheck,
                }
                if spyMode then
                    print("|cFF00DDDD[SPY]|r My spec extra kick: " .. extra.name .. " CD=" .. extra.cd .. " (talent " .. checkID .. " known)")
                end
            elseif spyMode then
                print("|cFF00DDDD[SPY]|r Spec extra kick " .. extra.name .. " NOT known (talent " .. checkID .. " missing)")
            end
        end
    end

    -- Build set of spell IDs managed by SPEC_EXTRA_KICKS (skip them in auto-detect)
    local specManagedSpells = {}
    if specID and SPEC_EXTRA_KICKS[specID] then
        for _, extra in ipairs(SPEC_EXTRA_KICKS[specID]) do
            specManagedSpells[extra.id] = true
        end
    end

    local spellList = CLASS_INTERRUPT_LIST[myClass]
    if not spellList then return end

    -- Find primary kick (if not set by spec override) and extra kicks
    for _, sid in ipairs(spellList) do
        local known = IsSpellKnown(sid) or IsSpellKnown(sid, true)
        -- Also try IsPlayerSpell for talent-granted abilities
        if not known then
            local ok, result = pcall(IsPlayerSpell, sid)
            if ok and result then known = true end
        end
        if known then
            if not mySpellID then
                mySpellID = sid
            elseif sid ~= mySpellID and not myExtraKicks[sid] and not specManagedSpells[sid] then
                -- Don't add spells managed by SPEC_EXTRA_KICKS (talent check handles those)
                local data = ALL_INTERRUPTS[sid]
                if data then
                    local oldCdEnd = oldExtraKicks[sid] and oldExtraKicks[sid].cdEnd or 0
                    myExtraKicks[sid] = { baseCd = data.cd, cdEnd = oldCdEnd }
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r Found extra kick: " .. data.name .. " CD=" .. data.cd)
                    end
                end
            end
        end
    end

    -- Cache correct icon for pet spells using C_Spell on the actual pet version
    -- 119914 = Command Demon wrapper, 89766 = actual Axe Toss pet spell
    local PET_SPELL_ICONS = {
        [119914] = 89766,  -- Axe Toss: use pet version for correct icon
    }
    if mySpellID and PET_SPELL_ICONS[mySpellID] and ALL_INTERRUPTS[mySpellID] then
        local petSpellID = PET_SPELL_ICONS[mySpellID]
        local ok, tex = pcall(C_Spell.GetSpellTexture, petSpellID)
        if ok and tex then
            ALL_INTERRUPTS[mySpellID].icon = tex
            if spyMode then
                print("|cFF00DDDD[SPY]|r Cached icon for " .. mySpellID .. " from pet spell " .. petSpellID .. " → " .. tostring(tex))
            end
        end
    end

    -- Only reset cached CD if spell changed
    if mySpellID ~= oldSpellID then
        myCachedCD = nil
        if not myBaseCd and mySpellID then ReadMyBaseCd() end
    end

    -- Scan own talents for CD reductions (Interwoven Threads etc.)
    if mySpellID then
        local configID = nil
        if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
            local ok0, cid = pcall(C_ClassTalents.GetActiveConfigID)
            if ok0 and cid then configID = cid end
        end
        if configID then
            local ok1, configInfo = pcall(C_Traits.GetConfigInfo, configID)
            if ok1 and configInfo and configInfo.treeIDs and #configInfo.treeIDs > 0 then
                local treeID = configInfo.treeIDs[1]
                local ok2, nodeIDs = pcall(C_Traits.GetTreeNodes, treeID)
                if ok2 and nodeIDs then
                    for _, nodeID in ipairs(nodeIDs) do
                        local ok3, nodeInfo = pcall(C_Traits.GetNodeInfo, configID, nodeID)
                        if ok3 and nodeInfo and nodeInfo.activeEntry and nodeInfo.activeRank and nodeInfo.activeRank > 0 then
                            local entryID = nodeInfo.activeEntry.entryID
                            if entryID then
                                local ok4, entryInfo = pcall(C_Traits.GetEntryInfo, configID, entryID)
                                if ok4 and entryInfo and entryInfo.definitionID then
                                    local ok5, defInfo = pcall(C_Traits.GetDefinitionInfo, entryInfo.definitionID)
                                    if ok5 and defInfo and defInfo.spellID then
                                        -- defInfo.spellID may be a secret value in 12.0; try string fallback
                                        local defSpellStr2 = nil
                                        do local sok, s = pcall(tostring, defInfo.spellID); if sok then defSpellStr2 = s end end
                                        local talent = (pcall(function() return CD_REDUCTION_TALENTS[defInfo.spellID] end) and CD_REDUCTION_TALENTS[defInfo.spellID])
                                            or (defSpellStr2 and CD_REDUCTION_TALENTS_STR[defSpellStr2])
                                        if talent and talent.affects == mySpellID then
                                            if talent.pctReduction then
                                                local newCd = (myBaseCd or ALL_INTERRUPTS[mySpellID].cd) * (1 - talent.pctReduction / 100)
                                                myBaseCd = math.floor(newCd + 0.5)
                                            elseif talent.reduction then
                                                myBaseCd = (myBaseCd or ALL_INTERRUPTS[mySpellID].cd) - talent.reduction
                                            end
                                            if myBaseCd < 1 then myBaseCd = 1 end
                                            if spyMode then
                                                print("|cFF00DDDD[SPY]|r Own talent: " .. talent.name .. " → CD=" .. myBaseCd)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

------------------------------------------------------------
-- Config panel
------------------------------------------------------------
-- Forward declarations: ShowStatsWindow and ShowRotationPanel are defined later
-- in the file but referenced here (CreateConfigPanel / SetupSlash).
local ShowStatsWindow
local ShowRotationPanel

-- Compatibility helper: create a labeled slider without deprecated templates.
-- Layout:   [Text centered above]
--  [Low]  ====track/thumb====  [High]
local function MakeSlider(name, parent)
    local s = CreateFrame("Slider", name, parent)
    s:SetOrientation("HORIZONTAL")
    s:SetHitRectInsets(0, 0, -10, -10)

    -- Track: native WoW slider background texture (tiled)
    local track = s:CreateTexture(nil, "BACKGROUND")
    track:SetTexture("Interface\\Buttons\\UI-SliderBar-Background")
    track:SetHorizTile(true)
    track:SetPoint("LEFT",  0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetHeight(8)

    -- Thumb: native WoW diamond button
    local thumb = s:CreateTexture(nil, "OVERLAY")
    thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    thumb:SetSize(32, 32)
    s:SetThumbTexture(thumb)

    -- Left arrow < indicator (native WoW style)
    local leftArr = s:CreateTexture(nil, "ARTWORK")
    leftArr:SetTexture("Interface\\Buttons\\UI-SliderBar-Arrow")
    leftArr:SetSize(10, 10)
    leftArr:SetPoint("RIGHT", s, "LEFT", -3, 0)
    leftArr:SetTexCoord(0, 0.5, 0, 1)

    -- Right arrow > indicator (horizontally flipped)
    local rightArr = s:CreateTexture(nil, "ARTWORK")
    rightArr:SetTexture("Interface\\Buttons\\UI-SliderBar-Arrow")
    rightArr:SetSize(10, 10)
    rightArr:SetPoint("LEFT", s, "RIGHT", 3, 0)
    rightArr:SetTexCoord(1, 0.5, 0, 1)

    -- .Text: current value label, centered above the slider
    local t = s:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    t:SetPoint("BOTTOM", s, "TOP", 0, 2)
    t:SetJustifyH("CENTER")
    s.Text = t

    -- .Low: min label, below slider left
    local loLbl = s:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    loLbl:SetPoint("TOPLEFT", s, "BOTTOMLEFT", 0, -2)
    s.Low = loLbl

    -- .High: max label, below slider right
    local hiLbl = s:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hiLbl:SetPoint("TOPRIGHT", s, "BOTTOMRIGHT", 0, -2)
    s.High = hiLbl

    return s
end

local function CreateCheckbox(parent, label, x, y, key, onChecked)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", x, y)
    local cbLabel = cb.text or cb.Text
    if cbLabel then cbLabel:SetText(label) end
    cb:SetChecked(db[key])
    cb:SetScript("OnClick", function(self)
        db[key] = self:GetChecked() and true or false
        if onChecked then onChecked() else RebuildBars() end
    end)
    return cb
end

------------------------------------------------------------
-- Frame position save/restore (defined early for CreateConfigPanel)
------------------------------------------------------------
local function LoxxSaveFramePosition(frame)
    if not frame then return false end
    local x, y = frame:GetLeft(), frame:GetTop()
    if not x or not y then return false end
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    LOXXAccountVars = LOXXAccountVars or {}
    LOXXAccountVars.frameX = x
    LOXXAccountVars.frameY = y
    if db then
        db.frameX = x
        db.frameY = y
    end
    return true
end

local function LoxxRestoreFramePosition(frame)
    if not frame then return end
    local x, y
    if db and db.frameX and db.frameY then
        x, y = db.frameX, db.frameY
    elseif LOXXAccountVars and LOXXAccountVars.frameX and LOXXAccountVars.frameY then
        x, y = LOXXAccountVars.frameX, LOXXAccountVars.frameY
    end
    if x and y then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    else
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
    end
end

------------------------------------------------------------
-- Changelog window (same design as config, attached to it)
------------------------------------------------------------
local changelogFrame = nil
local function ShowChangelogWindow()
    if changelogFrame and changelogFrame:IsShown() then
        changelogFrame:Hide()
        return
    end
    if changelogFrame then
        changelogFrame:Show()
        return
    end

    local CW, CH = 420, 500
    changelogFrame = CreateFrame("Frame", "LoxxChangelogFrame", UIParent, "BasicFrameTemplate")
    changelogFrame:SetSize(CW, CH)
    changelogFrame:SetPoint("TOPLEFT", configFrame, "TOPRIGHT", 4, 0)
    changelogFrame:SetFrameStrata("DIALOG")
    changelogFrame:SetMovable(true)
    changelogFrame:EnableMouse(true)
    changelogFrame:RegisterForDrag("LeftButton")
    changelogFrame:SetScript("OnDragStart", changelogFrame.StartMoving)
    changelogFrame:SetScript("OnDragStop",  changelogFrame.StopMovingOrSizing)
    changelogFrame:SetClampedToScreen(true)
    if changelogFrame.TitleText then changelogFrame.TitleText:SetText("") end

    -- Header (same as config)
    local hdr = changelogFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
    hdr:SetTexture(FLAT_TEX)
    hdr:SetVertexColor(0.12, 0.09, 0.02, 1)
    hdr:SetPoint("TOPLEFT",  0, -22)
    hdr:SetPoint("TOPRIGHT", 0, -22)
    hdr:SetHeight(52)
    local hdrLineTop = changelogFrame:CreateTexture(nil, "BORDER")
    hdrLineTop:SetTexture(FLAT_TEX)
    hdrLineTop:SetVertexColor(0.87, 0.73, 0.37, 0.75)
    hdrLineTop:SetPoint("TOPLEFT",  0, -22)
    hdrLineTop:SetPoint("TOPRIGHT", 0, -22)
    hdrLineTop:SetHeight(1)
    local hdrLineBot = changelogFrame:CreateTexture(nil, "BORDER")
    hdrLineBot:SetTexture(FLAT_TEX)
    hdrLineBot:SetVertexColor(0.87, 0.73, 0.37, 0.75)
    hdrLineBot:SetPoint("TOPLEFT",  0, -74)
    hdrLineBot:SetPoint("TOPRIGHT", 0, -74)
    hdrLineBot:SetHeight(1)
    local hdrTitle = changelogFrame:CreateFontString(nil, "OVERLAY")
    hdrTitle:SetFont(FONT_FACE, 22, FONT_FLAGS)
    hdrTitle:SetShadowOffset(2, -2)
    hdrTitle:SetShadowColor(0, 0, 0, 1)
    hdrTitle:SetPoint("TOP", 0, -34)
    hdrTitle:SetJustifyH("CENTER")
    hdrTitle:SetText("|cFFFFD100Changelog|r")

    -- ScrollFrame
    local scroll = CreateFrame("ScrollFrame", nil, changelogFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -80)
    scroll:SetPoint("BOTTOMRIGHT", -32, 40)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(CW - 60, 100)
    scroll:SetScrollChild(content)

    local txt = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txt:SetPoint("TOPLEFT", 0, 0)
    txt:SetWidth(CW - 60)
    txt:SetJustifyH("LEFT")
    txt:SetJustifyV("TOP")
    txt:SetWordWrap(true)
    txt:SetNonSpaceWrap(false)
    txt:SetFont(FONT_FACE, 12, FONT_FLAGS)
    txt:SetText(LOXX_CHANGELOG or "Aucun changelog disponible.")

    -- Hauteur du contenu pour le scroll (estimation par lignes)
    local lineHeight = 18
    local lineCount = 1
    for _ in (LOXX_CHANGELOG or ""):gmatch("\n") do lineCount = lineCount + 1 end
    content:SetHeight(math.max(400, lineCount * lineHeight))

    changelogFrame:Show()
end

local function CreateConfigPanel()
    if configFrame then
        if configFrame:IsShown() then configFrame:Hide() else configFrame:Show() end
        return
    end

    local PW, PH = 600, 580
    local MID = 300
    local SL_W = 210

    configFrame = CreateFrame("Frame", "LoxxConfigFrame", UIParent, "BasicFrameTemplate")
    configFrame:SetSize(PW, PH)
    configFrame:SetPoint("CENTER")
    configFrame:SetFrameStrata("DIALOG")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop",  configFrame.StopMovingOrSizing)
    configFrame:SetClampedToScreen(true)
    if configFrame.TitleText then configFrame.TitleText:SetText("") end

    -- Header (decorative only)
    local hdr = configFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
    hdr:SetTexture(FLAT_TEX)
    hdr:SetVertexColor(0.12, 0.09, 0.02, 1)
    hdr:SetPoint("TOPLEFT",  0, -22)
    hdr:SetPoint("TOPRIGHT", 0, -22)
    hdr:SetHeight(52)
    local hdrLineTop = configFrame:CreateTexture(nil, "BORDER")
    hdrLineTop:SetTexture(FLAT_TEX)
    hdrLineTop:SetVertexColor(0.87, 0.73, 0.37, 0.75)
    hdrLineTop:SetPoint("TOPLEFT",  0, -22)
    hdrLineTop:SetPoint("TOPRIGHT", 0, -22)
    hdrLineTop:SetHeight(1)
    local hdrLineBot = configFrame:CreateTexture(nil, "BORDER")
    hdrLineBot:SetTexture(FLAT_TEX)
    hdrLineBot:SetVertexColor(0.87, 0.73, 0.37, 0.75)
    hdrLineBot:SetPoint("TOPLEFT",  0, -74)
    hdrLineBot:SetPoint("TOPRIGHT", 0, -74)
    hdrLineBot:SetHeight(1)
    local hdrTitle = configFrame:CreateFontString(nil, "OVERLAY")
    hdrTitle:SetFont(FONT_FACE, 28, FONT_FLAGS)
    hdrTitle:SetShadowOffset(2, -2)
    hdrTitle:SetShadowColor(0, 0, 0, 1)
    hdrTitle:SetPoint("TOP", 0, -34)
    hdrTitle:SetJustifyH("CENTER")
    hdrTitle:SetText("|cFFFFD100Loxx Interrupt Tracker|r")

    -- Vertical divider (decorative only)
    local div = configFrame:CreateTexture(nil, "ARTWORK")
    div:SetTexture(FLAT_TEX)
    div:SetVertexColor(0.45, 0.38, 0.22, 0.5)
    div:SetPoint("TOPLEFT",    configFrame, "TOPLEFT", MID,     -76)
    div:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", MID, 44)
    div:SetWidth(2)

    local L_X1, L_CBX1, L_CBX2, SL_XL = 14, 20, 152, 52
    local R_X1, R_CBX1, R_CBX2 = 314, 314, 446

    local function SectionLabelL(text, yOff)
        local lbl = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", L_X1, yOff)
        lbl:SetText("|cFFFFD100" .. text .. "|r")
        local rule = configFrame:CreateTexture(nil, "ARTWORK")
        rule:SetTexture(FLAT_TEX)
        rule:SetVertexColor(0.87, 0.73, 0.37, 0.35)
        rule:SetPoint("LEFT", lbl, "RIGHT", 6, 0)
        rule:SetPoint("RIGHT", configFrame, "LEFT", MID - 10, 0)
        rule:SetHeight(1)
    end
    local function SectionLabelR(text, yOff)
        local lbl = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", R_X1, yOff)
        lbl:SetText("|cFFFFD100" .. text .. "|r")
        local rule = configFrame:CreateTexture(nil, "ARTWORK")
        rule:SetTexture(FLAT_TEX)
        rule:SetVertexColor(0.87, 0.73, 0.37, 0.35)
        rule:SetPoint("LEFT", lbl, "RIGHT", 6, 0)
        rule:SetPoint("RIGHT", configFrame, "RIGHT", -14, 0)
        rule:SetHeight(1)
    end

    -- ── LEFT COLUMN ─────────────────────────────────────────────
    local yL = -82
    SectionLabelL("DISPLAY", yL)
    yL = yL - 22

    local alphaSlider = MakeSlider("LOXX_Slider_alpha", configFrame)
    alphaSlider:SetPoint("TOPLEFT", SL_XL, yL)
    alphaSlider:SetSize(SL_W, 26)
    yL = yL - 48
    local initW = db.frameWidth or 180
    local widthSlider = MakeSlider("LOXX_Slider_width", configFrame)
    widthSlider:SetPoint("TOPLEFT", SL_XL, yL)
    widthSlider:SetSize(SL_W, 26)
    widthSlider:SetMinMaxValues(120, 400)
    widthSlider:SetValueStep(10)
    widthSlider:SetObeyStepOnDrag(true)
    widthSlider:SetValue(initW)
    widthSlider.Text:SetText("Width: " .. tostring(initW) .. "px")
    widthSlider.Low:SetText("120")
    widthSlider.High:SetText("400")
    widthSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 10 + 0.5) * 10
        db.frameWidth = value
        self.Text:SetText("Width: " .. tostring(value) .. "px")
        RebuildBars()
    end)

    yL = yL - 48
    local initH = db.barHeight or 20
    local heightSlider = MakeSlider("LOXX_Slider_height", configFrame)
    heightSlider:SetPoint("TOPLEFT", SL_XL, yL)
    heightSlider:SetSize(SL_W, 26)
    heightSlider:SetMinMaxValues(14, 50)
    heightSlider:SetValueStep(1)
    heightSlider:SetObeyStepOnDrag(true)
    heightSlider:SetValue(initH)
    heightSlider.Text:SetText("Height: " .. tostring(initH) .. "px")
    heightSlider.Low:SetText("14")
    heightSlider.High:SetText("50")
    heightSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        db.barHeight = value
        self.Text:SetText("Height: " .. tostring(value) .. "px")
        RebuildBars()
    end)

    -- OPTIONS
    yL = yL - 48
    SectionLabelL("OPTIONS", yL)
    yL = yL - 24
    CreateCheckbox(configFrame, "Show Title", L_CBX1, yL, "showTitle")
    yL = yL - 28
    CreateCheckbox(configFrame, "Lock Position", L_CBX1, yL, "locked")
    CreateCheckbox(configFrame, "Show READY", L_CBX2, yL, "showReady")
    yL = yL - 28
    do
        local cb = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", L_CBX1, yL)
        local cbLabel = cb.text or cb.Text
        if cbLabel then cbLabel:SetText("Hide out of combat") end
        cb:SetChecked(db.hideOutOfCombat)
        cb:SetScript("OnClick", function(self)
            db.hideOutOfCombat = self:GetChecked() and true or false
            CheckZoneVisibility()
        end)
    end

    -- FONT SIZES
    yL = yL - 40
    SectionLabelL("FONT SIZES", yL)
    yL = yL - 22
    local initNameFont = math.max(2, db.nameFontSize or 12)
    local nameSlider = MakeSlider("LOXX_Slider_nameFont", configFrame)
    nameSlider:SetPoint("TOPLEFT", SL_XL, yL)
    nameSlider:SetSize(SL_W, 26)
    nameSlider:SetMinMaxValues(2, 32)
    nameSlider:SetValueStep(1)
    nameSlider:SetObeyStepOnDrag(true)
    nameSlider:SetValue(initNameFont)
    nameSlider.Text:SetText("Name Size: " .. tostring(initNameFont))
    nameSlider.Low:SetText("2")
    nameSlider.High:SetText("32")
    nameSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        db.nameFontSize = value
        self.Text:SetText("Name Size: " .. tostring(value))
        RebuildBars()
    end)

    yL = yL - 48
    local initCdFont = math.max(2, db.readyFontSize or 12)
    local cdSlider = MakeSlider("LOXX_Slider_cdFont", configFrame)
    cdSlider:SetPoint("TOPLEFT", SL_XL, yL)
    cdSlider:SetSize(SL_W, 26)
    cdSlider:SetMinMaxValues(2, 32)
    cdSlider:SetValueStep(1)
    cdSlider:SetObeyStepOnDrag(true)
    cdSlider:SetValue(initCdFont)
    cdSlider.Text:SetText("CD Size: " .. tostring(initCdFont))
    cdSlider.Low:SetText("2")
    cdSlider.High:SetText("32")
    cdSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        db.readyFontSize = value
        self.Text:SetText("CD Size: " .. tostring(value))
        RebuildBars()
    end)

    yL = yL - 48
    local initReadyFont = math.max(2, db.readyTextSize or 12)
    local readySlider = MakeSlider("LOXX_Slider_readyFont", configFrame)
    readySlider:SetPoint("TOPLEFT", SL_XL, yL)
    readySlider:SetSize(SL_W, 26)
    readySlider:SetMinMaxValues(2, 32)
    readySlider:SetValueStep(1)
    readySlider:SetObeyStepOnDrag(true)
    readySlider:SetValue(initReadyFont)
    readySlider.Text:SetText("Ready Size: " .. tostring(initReadyFont))
    readySlider.Low:SetText("2")
    readySlider.High:SetText("32")
    readySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        db.readyTextSize = value
        self.Text:SetText("Ready Size: " .. tostring(value))
        RebuildBars()
    end)

    -- ── RIGHT COLUMN ─────────────────────────────────────────────
    local yR = -82
    SectionLabelR("SHOW IN", yR)
    yR = yR - 24
    local function VisCheck(parent, label, x, y, key)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", x, y)
        local cbLabel = cb.text or cb.Text
        if cbLabel then cbLabel:SetText(label) end
        cb:SetChecked(db[key])
        cb:SetScript("OnClick", function(self)
            db[key] = self:GetChecked() and true or false
            CheckZoneVisibility()
        end)
        return cb
    end
    VisCheck(configFrame, "Dungeons", R_CBX1, yR, "showInDungeon")
    VisCheck(configFrame, "Arena", R_CBX2, yR, "showInArena")
    yR = yR - 28
    VisCheck(configFrame, "Open World", R_CBX1, yR, "showInOpenWorld")

    -- SOUND
    yR = yR - 40
    SectionLabelR("SOUND", yR)
    yR = yR - 24
    local soundOptions = { { name = "None", id = nil } }
    for _, s in ipairs(SOUND_LIST) do soundOptions[#soundOptions+1] = s end
    local function getSoundOptIdx()
        if not db.soundOnReady then return 1 end
        for i = 2, #soundOptions do
            if soundOptions[i].id == db.soundID then return i end
        end
        return 2
    end

    local sndDropBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    sndDropBtn:SetSize(140, 22)
    sndDropBtn:SetPoint("TOPLEFT", R_CBX1, yR)
    sndDropBtn:SetText(soundOptions[getSoundOptIdx()].name .. "  v")

    local sndPopup = CreateFrame("Frame", nil, configFrame)
    sndPopup:SetFrameStrata("TOOLTIP")
    sndPopup:SetSize(140, #soundOptions * 22 + 8)
    sndPopup:SetPoint("TOPLEFT", sndDropBtn, "BOTTOMLEFT", 0, -2)
    sndPopup:Hide()
    local popBg = sndPopup:CreateTexture(nil, "BACKGROUND")
    popBg:SetAllPoints() ; popBg:SetTexture(FLAT_TEX) ; popBg:SetVertexColor(0.08, 0.08, 0.08, 0.97)
    local popBd = sndPopup:CreateTexture(nil, "BORDER")
    popBd:SetPoint("TOPLEFT", -1, 1) ; popBd:SetPoint("BOTTOMRIGHT", 1, -1)
    popBd:SetTexture(FLAT_TEX) ; popBd:SetVertexColor(0.45, 0.38, 0.22, 0.9)
    for i, opt in ipairs(soundOptions) do
        local row = CreateFrame("Button", nil, sndPopup)
        row:SetSize(136, 20)
        row:SetPoint("TOPLEFT", 2, -4 - (i - 1) * 22)
        local txt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        txt:SetAllPoints() ; txt:SetJustifyH("LEFT") ; txt:SetText("  " .. opt.name)
        row:SetScript("OnEnter", function() txt:SetTextColor(1, 0.82, 0) end)
        row:SetScript("OnLeave", function() txt:SetTextColor(1, 1, 1) end)
        local optIdx = i
        row:SetScript("OnClick", function()
            local o = soundOptions[optIdx]
            if o.id then
                db.soundOnReady = true
                db.soundID = o.id
                PlaySound(o.id, "Master")
            else
                db.soundOnReady = false
                db.soundID = nil
            end
            sndDropBtn:SetText(o.name .. "  v")
            sndPopup:Hide()
        end)
    end
    sndDropBtn:SetScript("OnClick", function()
        if sndPopup:IsShown() then sndPopup:Hide() else sndPopup:Show() end
    end)

    -- UI
    yR = yR - 40
    SectionLabelR("UI", yR)
    yR = yR - 24
    CreateCheckbox(configFrame, "Tooltip on Hover", R_CBX1, yR, "showTooltip")

    -- ROTATION
    yR = yR - 40
    SectionLabelR("ROTATION", yR)
    yR = yR - 24
    local rotCb = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
    rotCb:SetPoint("TOPLEFT", R_CBX1, yR)
    local rotLbl = rotCb.text or rotCb.Text
    if rotLbl then rotLbl:SetText("Enable Rotation") end
    rotCb:SetChecked(db.rotationEnabled)
    rotCb:SetScript("OnClick", function(self)
        db.rotationEnabled = self:GetChecked() and true or false
        if LOXXSavedVars then LOXXSavedVars.rotationEnabled = db.rotationEnabled end
    end)

    yR = yR - 28
    local mgrBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    mgrBtn:SetSize(130, 22)
    mgrBtn:SetPoint("TOPLEFT", R_CBX1, yR)
    mgrBtn:SetText("Manage Kick Rotation")
    mgrBtn:SetScript("OnClick", function() ShowRotationPanel() end)

    -- ── FOOTER ───────────────────────────────────────────────────
    do
        local rule = configFrame:CreateTexture(nil, "ARTWORK")
        rule:SetTexture(FLAT_TEX)
        rule:SetVertexColor(0.45, 0.38, 0.22, 0.4)
        rule:SetPoint("TOPLEFT",  8, -486)
        rule:SetPoint("TOPRIGHT", -8, -486)
        rule:SetHeight(1)
    end
    local changelogBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    changelogBtn:SetSize(90, 24)
    changelogBtn:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -14, 44)
    changelogBtn:SetText("Changelog")
    changelogBtn:SetScript("OnClick", function() ShowChangelogWindow() end)

    local savePosBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    savePosBtn:SetSize(100, 24)
    savePosBtn:SetPoint("RIGHT", changelogBtn, "LEFT", -10, 0)
    savePosBtn:SetText("Save Position")
    savePosBtn:SetScript("OnClick", function()
        local function toChat(msg)
            if ChatFrame1 and ChatFrame1.AddMessage then
                ChatFrame1:AddMessage(msg)
            end
        end
        local function toCenter(msg)
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(msg, 0.27, 1, 0.27, 1, 3)
            end
        end
        local ok, err = pcall(function()
            if not mainFrame then
                toChat("|cFF00DDDD[LOXX]|r Aucune fenêtre à sauvegarder.")
                return
            end
            if LoxxSaveFramePosition(mainFrame) then
                toChat("|cFF00DDDD[LOXX]|r |cFF44FF44Position sauvegardée !|r")
                toCenter("LOXX: Position sauvegardee !")
            else
                toChat("|cFF00DDDD[LOXX]|r Fenêtre masquée, impossible de sauvegarder.")
            end
        end)
        if not ok and err then
            toChat("|cFFFF4444[LOXX]|r Erreur: " .. tostring(err))
        end
    end)

    -- Run Stats button (gold, like other buttons)
    local statsBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    statsBtn:SetSize(100, 24)
    statsBtn:SetPoint("RIGHT", savePosBtn, "LEFT", -10, 0)
    statsBtn:SetText("Run Stats")
    if statsBtn.GetFontString and statsBtn:GetFontString() then
        statsBtn:GetFontString():SetTextColor(1, 0.82, 0)  -- doré (FFFFD100)
    end
    statsBtn:SetScript("OnClick", function() ShowStatsWindow() end)

    local footerMsg = configFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footerMsg:SetPoint("BOTTOM", 0, 30)
    footerMsg:SetText("Thanks to my favorite haters who pushed me to continue this addon  #FUALL")

    local footerVer = configFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footerVer:SetPoint("BOTTOM", 0, 14)
    footerVer:SetText("|cFF888888v" .. LOXX_VERSION .. "|r")

    configFrame:Show()
end

------------------------------------------------------------
-- Create main frame + resize handle (from ADDON_LOADED)
------------------------------------------------------------
local function CreateUI()
    mainFrame = CreateFrame("Frame", "LOXXMainFrame", UIParent)
    mainFrame:SetSize(db.frameWidth, 200)
    -- Restore saved position
    LoxxRestoreFramePosition(mainFrame)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", function(self)
        if not db.locked then self:StartMoving() end
    end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        LoxxSaveFramePosition(self)
    end)
    mainFrame:SetAlpha(db.alpha)

    -- Background
    local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(FLAT_TEX)
    bg:SetVertexColor(0.06, 0.06, 0.06, 0.95)

    local GR, GG, GB = 0.87, 0.73, 0.37  -- kept for titleSep colour

    -- Title header band (warm dark like Details)
    local titleBand = mainFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    titleBand:SetTexture(FLAT_TEX)
    titleBand:SetVertexColor(0.09, 0.07, 0.03, 1)
    titleBand:SetPoint("TOPLEFT", 0, 0)
    titleBand:SetPoint("TOPRIGHT", 0, 0)
    titleBand:SetHeight(20)
    mainFrame.titleBand = titleBand

    -- Gold separator line below title
    local titleSep = mainFrame:CreateTexture(nil, "BORDER")
    titleSep:SetTexture(FLAT_TEX)
    titleSep:SetVertexColor(GR, GG, GB, 0.9)
    titleSep:SetPoint("TOPLEFT", 0, -20)
    titleSep:SetPoint("TOPRIGHT", 0, -20)
    titleSep:SetHeight(1)
    mainFrame.titleSep = titleSep

    -- Title (gold, like Details)
    titleText = mainFrame:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT_FACE, 12, FONT_FLAGS)
    titleText:SetPoint("TOPLEFT", 6, -2)
    titleText:SetPoint("TOPRIGHT", -6, -2)
    titleText:SetHeight(16)
    titleText:SetJustifyH("LEFT")
    titleText:SetJustifyV("MIDDLE")
    titleText:SetText("|cFFFFD100Interrupts|r")
    if not db.showTitle then titleText:Hide() end


    -- Alert band (danger: no kick available) — attached inside mainFrame at bottom
    local alertBand = CreateFrame("Frame", nil, mainFrame)
    alertBand:SetHeight(22)
    alertBand:SetPoint("BOTTOMLEFT",  mainFrame, "BOTTOMLEFT",  0, 0)
    alertBand:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
    alertBand:SetFrameLevel(mainFrame:GetFrameLevel() + 5)
    alertBand:Hide()
    local alertBg = alertBand:CreateTexture(nil, "BACKGROUND")
    alertBg:SetAllPoints()
    alertBg:SetTexture(FLAT_TEX)
    alertBg:SetVertexColor(0.55, 0.0, 0.0, 0.9)
    alertBand.bg = alertBg
    local alertLabel = alertBand:CreateFontString(nil, "OVERLAY")
    alertLabel:SetFont(FONT_FACE, 11, FONT_FLAGS)
    alertLabel:SetAllPoints()
    alertLabel:SetJustifyH("CENTER")
    alertLabel:SetJustifyV("MIDDLE")
    alertLabel:SetText("")
    alertBand.label = alertLabel
    mainFrame.alertBand = alertBand

    mainFrame:Show()
    -- Seed saved position on first install (before player ever drags)
    C_Timer.After(0, function()
        if mainFrame and not (LOXXAccountVars and LOXXAccountVars.frameX and LOXXAccountVars.frameY)
            and not (db and db.frameX and db.frameY) then
            LoxxSaveFramePosition(mainFrame)
        end
    end)
    RebuildBars()
end

------------------------------------------------------------
-- Slash commands
------------------------------------------------------------
local function SetupSlash()
    SLASH_LOXX1 = "/loxx"
    SlashCmdList["LOXX"] = function(msg)
        local cmd = (msg or ""):lower():trim()
        if cmd == "show" then
            if mainFrame then mainFrame:Show() end
        elseif cmd == "hide" then
            if mainFrame then mainFrame:Hide() end
        elseif cmd == "config" or cmd == "options" or cmd == "settings" then
            CreateConfigPanel()
        elseif cmd == "lock" then
            db.locked = true
            print("|cFF00DDDD[LOXX]|r Locked")
        elseif cmd == "unlock" then
            db.locked = false
            print("|cFF00DDDD[LOXX]|r Unlocked")
        elseif cmd == "test" then
            if testMode then
                -- Stop test
                testMode = false
                if testTicker then testTicker:Cancel() testTicker = nil end
                partyAddonUsers = {}
                print("|cFF00DDDD[LOXX]|r Test mode |cFFFF4444OFF|r")
            else
                -- Start test with fake players
                testMode = true
                partyAddonUsers = {
                    ["Thralldk"] = { class = "DEATHKNIGHT", spellID = 47528, baseCd = 15, cdEnd = 0 },
                    ["Jainalee"] = { class = "MAGE", spellID = 2139, baseCd = 20, cdEnd = 0 },
                    ["Sylvanash"] = { class = "ROGUE", spellID = 1766, baseCd = 15, cdEnd = 0 },
                }
                -- Simulate random kicks
                testTicker = C_Timer.NewTicker(2, function()
                    if not testMode then return end
                    for name, info in pairs(partyAddonUsers) do
                        local now = GetTime()
                        if info.cdEnd < now and math.random() < 0.3 then
                            info.cdEnd = now + info.baseCd
                        end
                    end
                end)
                print("|cFF00DDDD[LOXX]|r Test mode |cFF00FF00ON|r - 3 fake players. /loxx test to stop.")
            end
        elseif cmd == "ping" then
            print("|cFF00DDDD[LOXX]|r === PING ===")
            print("  IsInInstance: " .. tostring(IsInInstance()))
            pcall(C_ChatInfo.RegisterAddonMessagePrefix, MSG_PREFIX)
            -- Test PARTY
            local ok1, ret1 = pcall(C_ChatInfo.SendAddonMessage, MSG_PREFIX, "PING:PARTY", "PARTY")
            print("  PARTY -> ok=" .. tostring(ok1) .. " ret=" .. tostring(ret1))
            -- Test WHISPER to each party member
            for i = 1, 4 do
                local unit = "party" .. i
                if UnitExists(unit) then
                    local ok, name, realm = pcall(UnitFullName, unit)
                    if ok and name then
                        local target = (realm and realm ~= "") and (name .. "-" .. realm) or name
                        local ok2, ret2 = pcall(C_ChatInfo.SendAddonMessage, MSG_PREFIX, "PING:WHISPER", "WHISPER", target)
                        print("  WHISPER " .. target .. " -> ok=" .. tostring(ok2) .. " ret=" .. tostring(ret2))
                    end
                end
            end
            print("  Waiting for echo...")
        elseif cmd == "spy" then
            if spyMode then
                spyMode = false
                print("|cFF00DDDD[LOXX]|r Spy mode |cFFFF4444OFF|r")
            else
                spyMode = true
                spyCastCount = 0
                print("|cFF00DDDD[LOXX]|r Spy mode |cFF00FF00ON|r")
                -- Check watcher status
                for i = 1, 4 do
                    local unit = "party" .. i
                    local exists = UnitExists(unit)
                    local name = exists and UnitName(unit) or "?"
                    local hasFrame = partyFrames[i] ~= nil
                    local isReg = hasFrame and partyFrames[i]:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED")
                    print("  " .. unit .. ": exists=" .. tostring(exists) .. " name=" .. tostring(name) .. " frame=" .. tostring(hasFrame) .. " registered=" .. tostring(isReg))
                end
                print("  Ask your mate to cast ANY spell")
                -- Force re-register watchers
                RegisterPartyWatchers()
                AutoRegisterPartyByClass()
                inspectedPlayers = {} -- reset to re-inspect
                noInterruptPlayers = {}
                QueuePartyInspect()
                print("  Watchers re-registered! Inspecting talents...")
            end
        elseif cmd == "pos" then
            -- Debug: show frame position and saved values
            if mainFrame then
                local l, t = mainFrame:GetLeft(), mainFrame:GetTop()
                print("|cFF00DDDD[LOXX]|r Current position: " .. tostring(l) .. ", " .. tostring(t))
                print("  Account saved: " .. tostring(LOXXAccountVars and LOXXAccountVars.frameX) .. ", " .. tostring(LOXXAccountVars and LOXXAccountVars.frameY))
                print("  Char saved: " .. tostring(db and db.frameX) .. ", " .. tostring(db and db.frameY))
            else
                print("|cFF00DDDD[LOXX]|r mainFrame not yet created.")
            end
        elseif cmd == "debug" then
            print("|cFF00DDDD[LOXX]|r v" .. LOXX_VERSION .. " | " .. tostring(myClass) .. " | CD cached: " .. tostring(myCachedCD))
            for name, info in pairs(partyAddonUsers) do
                local rem = info.cdEnd - GetTime()
                if rem < 0 then rem = 0 end
                local spellName = ALL_INTERRUPTS[info.spellID] and ALL_INTERRUPTS[info.spellID].name or "?"
                local inspected = inspectedPlayers[name] and "inspected" or "not inspected"
                print(string.format("  %s (%s) %s CD=%.0f rem=%.1f [%s]", name, info.class, spellName, info.baseCd, rem, inspected))
            end
        elseif cmd == "stats" then
            ShowStatsWindow()
        elseif cmd == "logs" or cmd == "log" then
            if #loxxErrorLog == 0 then
                print("|cFF00DDDD[LOXX]|r No errors recorded.")
            else
                print("|cFF00DDDD[LOXX]|r === Recent errors (" .. #loxxErrorLog .. ") ===")
                for i = 1, math.min(20, #loxxErrorLog) do
                    print("|cFFFF4444[" .. i .. "]|r " .. loxxErrorLog[i])
                end
                if #loxxErrorLog > 20 then
                    print("  ... " .. (#loxxErrorLog - 20) .. " more. Use /loxx logs clear to wipe.")
                end
            end
        elseif cmd == "logs clear" or cmd == "log clear" then
            loxxErrorLog = {}
            if LOXXSavedVars then LOXXSavedVars.loxxErrorLog = {} end
            print("|cFF00DDDD[LOXX]|r Error log cleared.")
        elseif cmd == "help" then
            print("|cFF00DDDD[LOXX]|r /loxx (options) | show | hide | lock | unlock | test | spy | pos | debug | stats | logs | logs clear")
        else
            -- Default: open config
            CreateConfigPanel()
        end
    end
end

------------------------------------------------------------
-- Run statistics
------------------------------------------------------------
local function StartNewRun()
    if loxxCurrentRun and next(loxxCurrentRun.players) then
        LOXXSavedVars.loxxRunHistory = LOXXSavedVars.loxxRunHistory or {}
        table.insert(LOXXSavedVars.loxxRunHistory, 1, loxxCurrentRun)
        while #LOXXSavedVars.loxxRunHistory > 50 do
            table.remove(LOXXSavedVars.loxxRunHistory)
        end
    end
    local name, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
    local keyLevel = 0
    if C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo then
        keyLevel = C_ChallengeMode.GetActiveKeystoneInfo() or 0
    end
    loxxCurrentRun = {
        dungeon      = name or "Unknown",
        instanceID   = instanceID,
        instanceType = instanceType,
        keyLevel     = keyLevel,
        date         = date("%Y-%m-%d %H:%M"),
        players      = {},
    }
end

RecordKick = function(playerName)
    if not loxxCurrentRun then return end
    if not IsInInstance() then return end
    loxxCurrentRun.players[playerName] = (loxxCurrentRun.players[playerName] or 0) + 1
end

------------------------------------------------------------
-- Interrupt rotation
------------------------------------------------------------
AdvanceRotation = function()
    if not db.rotationEnabled or #rotationOrder == 0 then return end
    rotationIndex = rotationIndex % #rotationOrder + 1
    if LOXXSavedVars then LOXXSavedVars.rotationIndex = rotationIndex end
    SendLOXX("ROT_IDX:" .. rotationIndex)
end

BroadcastRotation = function()
    if #rotationOrder == 0 then return end
    SendLOXX("ROT:" .. table.concat(rotationOrder, ",") .. ":" .. rotationIndex)
end

------------------------------------------------------------
-- Stats window (same design as Changelog, collée à gauche de Settings)
------------------------------------------------------------
ShowStatsWindow = function()
    if statsFrame and statsFrame:IsShown() then
        statsFrame:Hide()
        statsFrame = nil
        return
    end
    if statsFrame then statsFrame = nil end

    local SW, SH = 380, 500
    local sf = CreateFrame("Frame", "LOXXStatsFrame", UIParent, "BasicFrameTemplate")
    sf:SetSize(SW, SH)
    if configFrame then
        sf:SetPoint("TOPRIGHT", configFrame, "TOPLEFT", -4, 0)
    else
        sf:SetPoint("CENTER")
    end
    sf:SetMovable(true)
    sf:EnableMouse(true)
    sf:RegisterForDrag("LeftButton")
    sf:SetScript("OnDragStart", sf.StartMoving)
    sf:SetScript("OnDragStop",  sf.StopMovingOrSizing)
    sf:SetClampedToScreen(true)
    sf:SetFrameStrata("DIALOG")
    if sf.TitleText then sf.TitleText:SetText("") end

    -- Header (même design que Changelog)
    local hdr = sf:CreateTexture(nil, "BACKGROUND", nil, 2)
    hdr:SetTexture(FLAT_TEX)
    hdr:SetVertexColor(0.12, 0.09, 0.02, 1)
    hdr:SetPoint("TOPLEFT",  0, -22)
    hdr:SetPoint("TOPRIGHT", 0, -22)
    hdr:SetHeight(52)
    local hdrLineTop = sf:CreateTexture(nil, "BORDER")
    hdrLineTop:SetTexture(FLAT_TEX)
    hdrLineTop:SetVertexColor(0.87, 0.73, 0.37, 0.75)
    hdrLineTop:SetPoint("TOPLEFT",  0, -22)
    hdrLineTop:SetPoint("TOPRIGHT", 0, -22)
    hdrLineTop:SetHeight(1)
    local hdrLineBot = sf:CreateTexture(nil, "BORDER")
    hdrLineBot:SetTexture(FLAT_TEX)
    hdrLineBot:SetVertexColor(0.87, 0.73, 0.37, 0.75)
    hdrLineBot:SetPoint("TOPLEFT",  0, -74)
    hdrLineBot:SetPoint("TOPRIGHT", 0, -74)
    hdrLineBot:SetHeight(1)
    local hdrTitle = sf:CreateFontString(nil, "OVERLAY")
    hdrTitle:SetFont(FONT_FACE, 22, FONT_FLAGS)
    hdrTitle:SetShadowOffset(2, -2)
    hdrTitle:SetShadowColor(0, 0, 0, 1)
    hdrTitle:SetPoint("TOP", 0, -34)
    hdrTitle:SetJustifyH("CENTER")
    hdrTitle:SetText("|cFFFFD100Interrupt Statistics|r")

    -- ScrollFrame (même layout que Changelog)
    local scroll = CreateFrame("ScrollFrame", nil, sf, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -80)
    scroll:SetPoint("BOTTOMRIGHT", -32, 40)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(SW - 60, 100)
    scroll:SetScrollChild(content)
    statsFrame = sf

    local y = -6
    local function AddLine(text, indent, template)
        local fs = content:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", indent or 0, y)
        fs:SetText(text)
    end
    local function AddSep()
        local s = content:CreateTexture(nil, "ARTWORK")
        s:SetTexture(FLAT_TEX)
        s:SetVertexColor(0.45, 0.38, 0.22, 0.5)
        s:SetPoint("TOPLEFT",  0, y - 4)
        s:SetPoint("TOPRIGHT", -4, y - 4)
        s:SetHeight(1)
        y = y - 12
    end
    local function SortedPlayers(players)
        local t = {}
        for n, k in pairs(players) do t[#t+1] = {name=n, kicks=k} end
        table.sort(t, function(a, b) return a.kicks > b.kicks end)
        return t
    end

    -- Current run
    if loxxCurrentRun and next(loxxCurrentRun.players) then
        AddLine("|cFF00DDDDCurrent Run|r", 0, "GameFontNormal") ; y = y - 18
        local keyStr = loxxCurrentRun.keyLevel > 0 and (" [+" .. loxxCurrentRun.keyLevel .. "]") or ""
        AddLine("|cFFFFD100" .. (loxxCurrentRun.dungeon or "?") .. keyStr .. "|r  " .. (loxxCurrentRun.date or ""), 0)
        y = y - 16
        for _, row in ipairs(SortedPlayers(loxxCurrentRun.players)) do
            AddLine("  " .. row.name .. " — " .. row.kicks .. " kick" .. (row.kicks ~= 1 and "s" or ""), 8)
            y = y - 14
        end
        y = y - 8
    end

    -- History
    local runs = LOXXSavedVars.loxxRunHistory or {}
    if #runs > 0 then
        AddSep()
        AddLine("|cFFFFD100History|r", 0, "GameFontNormal") ; y = y - 20
        for i, run in ipairs(runs) do
            local keyStr = run.keyLevel > 0 and (" [+" .. run.keyLevel .. "]") or ""
            AddLine("|cFFFFCC00" .. (run.dungeon or "?") .. keyStr .. "|r  " .. (run.date or ""), 0)
            -- Delete button (small X)
            local delBtn = CreateFrame("Button", nil, content)
            delBtn:SetSize(16, 14)
            delBtn:SetPoint("TOPRIGHT", -4, y + 2)
            delBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
            delBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
            local runIdx = i
            delBtn:SetScript("OnClick", function()
                table.remove(LOXXSavedVars.loxxRunHistory, runIdx)
                sf:Hide() ; statsFrame = nil ; ShowStatsWindow()
            end)
            y = y - 16
            for _, row in ipairs(SortedPlayers(run.players)) do
                AddLine("  " .. row.name .. " — " .. row.kicks .. " kick" .. (row.kicks ~= 1 and "s" or ""), 8)
                y = y - 14
            end
            y = y - 8
        end
    end

    content:SetHeight(math.abs(y) + 20)

    sf:Show()
end

------------------------------------------------------------
-- Rotation panel
------------------------------------------------------------
local function BuildRotationPanel()
    if not rotationPanel then return end
    -- Auto-populate from party if list is empty
    if #rotationOrder == 0 then
        if myName then rotationOrder[#rotationOrder+1] = myName end
        for i = 1, 4 do
            local u = "party" .. i
            if UnitExists(u) then
                local n = UnitName(u)
                if n and n ~= myName then rotationOrder[#rotationOrder+1] = n end
            end
        end
        rotationIndex = 1
    end
    rotationPanel.rows = rotationPanel.rows or {}
    for _, rf in ipairs(rotationPanel.rows) do rf:Hide() end

    local y = -80
    for i, name in ipairs(rotationOrder) do
        local idx = i
        local f = rotationPanel.rows[idx]
        if not f then
            f = CreateFrame("Frame", nil, rotationPanel)
            f:SetSize(204, 24)
            f.nm = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            f.nm:SetPoint("LEFT", 4, 0)
            f.nm:SetWordWrap(false)
            f.upBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            f.upBtn:SetSize(20, 18) ; f.upBtn:SetPoint("RIGHT", -24, 0) ; f.upBtn:SetText("^")
            f.downBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            f.downBtn:SetSize(20, 18) ; f.downBtn:SetPoint("RIGHT", -2, 0) ; f.downBtn:SetText("v")
            rotationPanel.rows[idx] = f
        end
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", 8, y)
        local isCurrent = (idx == rotationIndex) and db.rotationEnabled
        f.nm:SetText((isCurrent and "|cFFFFD100>>> |r" or "      ") .. idx .. ". " .. name)
        if idx > 1 then
            f.upBtn:Show()
            f.upBtn:SetScript("OnClick", function()
                rotationOrder[idx], rotationOrder[idx-1] = rotationOrder[idx-1], rotationOrder[idx]
                if rotationIndex == idx then rotationIndex = idx - 1
                elseif rotationIndex == idx - 1 then rotationIndex = idx end
                if LOXXSavedVars then LOXXSavedVars.rotationOrder = rotationOrder end
                BuildRotationPanel()
            end)
        else f.upBtn:Hide() end
        if idx < #rotationOrder then
            f.downBtn:Show()
            f.downBtn:SetScript("OnClick", function()
                rotationOrder[idx], rotationOrder[idx+1] = rotationOrder[idx+1], rotationOrder[idx]
                if rotationIndex == idx then rotationIndex = idx + 1
                elseif rotationIndex == idx + 1 then rotationIndex = idx end
                if LOXXSavedVars then LOXXSavedVars.rotationOrder = rotationOrder end
                BuildRotationPanel()
            end)
        else f.downBtn:Hide() end
        f:Show()
        y = y - 28
    end
    rotationPanel:SetHeight(math.max(340, 120 + #rotationOrder * 28))
end

ShowRotationPanel = function()
    if not rotationPanel then
        if not configFrame then return end

        local RW, RH = 240, 340
        rotationPanel = CreateFrame("Frame", "LOXXRotationPanel", UIParent, "BasicFrameTemplate")
        rotationPanel:SetSize(RW, RH)
        rotationPanel:SetPoint("TOPLEFT", configFrame, "TOPRIGHT", 4, 0)
        if rotationPanel.TitleText then rotationPanel.TitleText:SetText("") end
        rotationPanel:SetMovable(true)
        rotationPanel:EnableMouse(true)
        rotationPanel:RegisterForDrag("LeftButton")
        rotationPanel:SetScript("OnDragStart", rotationPanel.StartMoving)
        rotationPanel:SetScript("OnDragStop",  rotationPanel.StopMovingOrSizing)
        rotationPanel:SetClampedToScreen(true)
        rotationPanel:SetFrameStrata("DIALOG")

        -- Header (même design que Changelog)
        local hdr = rotationPanel:CreateTexture(nil, "BACKGROUND", nil, 2)
        hdr:SetTexture(FLAT_TEX)
        hdr:SetVertexColor(0.12, 0.09, 0.02, 1)
        hdr:SetPoint("TOPLEFT",  0, -22)
        hdr:SetPoint("TOPRIGHT", 0, -22)
        hdr:SetHeight(52)
        local hdrLineTop = rotationPanel:CreateTexture(nil, "BORDER")
        hdrLineTop:SetTexture(FLAT_TEX)
        hdrLineTop:SetVertexColor(0.87, 0.73, 0.37, 0.75)
        hdrLineTop:SetPoint("TOPLEFT",  0, -22)
        hdrLineTop:SetPoint("TOPRIGHT", 0, -22)
        hdrLineTop:SetHeight(1)
        local hdrLineBot = rotationPanel:CreateTexture(nil, "BORDER")
        hdrLineBot:SetTexture(FLAT_TEX)
        hdrLineBot:SetVertexColor(0.87, 0.73, 0.37, 0.75)
        hdrLineBot:SetPoint("TOPLEFT",  0, -74)
        hdrLineBot:SetPoint("TOPRIGHT", 0, -74)
        hdrLineBot:SetHeight(1)
        local hdrTitle = rotationPanel:CreateFontString(nil, "OVERLAY")
        hdrTitle:SetFont(FONT_FACE, 22, FONT_FLAGS)
        hdrTitle:SetShadowOffset(2, -2)
        hdrTitle:SetShadowColor(0, 0, 0, 1)
        hdrTitle:SetPoint("TOP", 0, -34)
        hdrTitle:SetJustifyH("CENTER")
        hdrTitle:SetText("|cFFFFD100Kick Rotation|r")

        -- Permanent bottom buttons
        local resetBtn = CreateFrame("Button", nil, rotationPanel, "UIPanelButtonTemplate")
        resetBtn:SetSize(80, 22) ; resetBtn:SetPoint("BOTTOMLEFT", 8, 8) ; resetBtn:SetText("Reset")
        resetBtn:SetScript("OnClick", function()
            rotationOrder = {} ; rotationIndex = 1
            if LOXXSavedVars then
                LOXXSavedVars.rotationOrder = rotationOrder
                LOXXSavedVars.rotationIndex = rotationIndex
            end
            BuildRotationPanel()
        end)
        local syncBtn = CreateFrame("Button", nil, rotationPanel, "UIPanelButtonTemplate")
        syncBtn:SetSize(80, 22) ; syncBtn:SetPoint("BOTTOMRIGHT", -8, 8) ; syncBtn:SetText("Sync Party")
        syncBtn:SetScript("OnClick", function()
            if LOXXSavedVars then
                LOXXSavedVars.rotationOrder = rotationOrder
                LOXXSavedVars.rotationIndex = rotationIndex
            end
            BroadcastRotation()
            print("|cFF00DDDD[LOXX]|r Rotation synced to party.")
        end)
    end
    BuildRotationPanel()
    if rotationPanel:IsShown() then rotationPanel:Hide() else rotationPanel:Show() end
end

------------------------------------------------------------
-- Initialize
------------------------------------------------------------
local function RegisterBlizzardOptions()
    local panel = CreateFrame("Frame")
    panel.name = "Loxx Interrupt Tracker"

    -- Column layout: left x=16, right x=310. Sliders: width=220.
    local LX   = 16    -- left col labels/checkboxes
    local RX   = 310   -- right col labels/checkboxes
    local LSL  = 20    -- left col slider x
    local RSL  = 314   -- right col slider x
    local SW   = 220   -- slider width

    -- Shared helper: slider
    local function BS(name, parent, x, y, min, max, step, initVal, labelFn, onChanged)
        local s = MakeSlider(name, parent)
        s:SetPoint("TOPLEFT", x, y)
        s:SetSize(SW, 18)
        s:SetMinMaxValues(min, max)
        s:SetValueStep(step)
        s:SetObeyStepOnDrag(true)
        s:SetValue(initVal)
        s.Text:SetText(labelFn(initVal))
        s.Low:SetText(tostring(min))
        s.High:SetText(tostring(max))
        s:SetScript("OnValueChanged", function(self, v)
            v = onChanged(v)
            self.Text:SetText(labelFn(v))
        end)
        return s
    end

    -- Shared helper: checkbox
    local function BC(label, dbKey, x, y)
        local cb = CreateFrame("CheckButton", "LOXX_Blizz_" .. dbKey, panel, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", x, y)
        local lbl = cb.text or cb.Text
        if lbl then lbl:SetText(label) end
        cb:SetChecked(db[dbKey])
        cb:SetScript("OnClick", function(self)
            db[dbKey] = self:GetChecked()
            if dbKey == "showTitle" or dbKey == "showReady" then RebuildBars() end
            if dbKey:find("^show") or dbKey == "hideOutOfCombat" then CheckZoneVisibility() end
        end)
    end

    -- Shared helper: section label
    local function BH(text, x, y)
        local h = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", x, y)
        h:SetText("|cFFFFD100" .. text .. "|r")
    end

    -- ── Title ────────────────────────────────────────────────────────────────
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", LX, -16)
    title:SetText("|cFF00DDDDLoxx Interrupt Tracker|r")

    local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", LX, -40)
    hint:SetText("Full settings available via  /loxx")

    -- Thin separator below title
    local sep = panel:CreateTexture(nil, "ARTWORK")
    sep:SetTexture(FLAT_TEX)
    sep:SetVertexColor(0.45, 0.38, 0.22, 0.5)
    sep:SetPoint("TOPLEFT",  LX,      -54)
    sep:SetPoint("TOPRIGHT", -LX,     -54)
    sep:SetHeight(1)

    -- ── LEFT COLUMN ──────────────────────────────────────────────────────────
    local yL = -66

    BH("DISPLAY", LX, yL) ; yL = yL - 22
    BC("Show Title Bar",   "showTitle",  LX, yL) ; yL = yL - 24
    BC("Lock Position",    "locked",     LX, yL) ; yL = yL - 24
    BC("Show READY Text",  "showReady",  LX, yL) ; yL = yL - 24
    BC("Tooltip on Hover", "showTooltip",LX, yL) ; yL = yL - 24
    BC("Hide out of combat","hideOutOfCombat", LX, yL) ; yL = yL - 36

    BH("FONT SIZES", LX, yL) ; yL = yL - 22
    BS("LOXX_Blizz_NameFont", panel, LSL, yL, 2, 32, 1,
        math.max(2, db.nameFontSize or 12),
        function(v) return "Name: " .. v end,
        function(v) v = math.floor(v+0.5); db.nameFontSize = v; RebuildBars(); return v end)
    yL = yL - 44
    BS("LOXX_Blizz_CdFont", panel, LSL, yL, 2, 32, 1,
        math.max(2, db.readyFontSize or 12),
        function(v) return "Cooldown: " .. v end,
        function(v) v = math.floor(v+0.5); db.readyFontSize = v; RebuildBars(); return v end)
    yL = yL - 44
    BS("LOXX_Blizz_ReadyFont", panel, LSL, yL, 2, 32, 1,
        math.max(2, db.readyTextSize or 12),
        function(v) return "Ready: " .. v end,
        function(v) v = math.floor(v+0.5); db.readyTextSize = v; RebuildBars(); return v end)

    -- ── RIGHT COLUMN ─────────────────────────────────────────────────────────
    local yR = -66

    BH("SHOW IN", RX, yR) ; yR = yR - 22
    BC("Dungeons (M+ & Heroic)", "showInDungeon",   RX, yR) ; yR = yR - 24
    BC("Open World",             "showInOpenWorld",  RX, yR) ; yR = yR - 24
    BC("Arena",                  "showInArena",      RX, yR) ; yR = yR - 36

    BH("SIZE", RX, yR) ; yR = yR - 22
    BS("LOXX_Blizz_Width", panel, RSL, yR, 120, 400, 10,
        db.frameWidth or 180,
        function(v) return "Width: " .. v .. "px" end,
        function(v) v = math.floor(v/10+0.5)*10; db.frameWidth = v; RebuildBars(); return v end)
    yR = yR - 44
    BS("LOXX_Blizz_Height", panel, RSL, yR, 14, 50, 1,
        db.barHeight or 20,
        function(v) return "Height: " .. v .. "px" end,
        function(v) v = math.floor(v+0.5); db.barHeight = v; RebuildBars(); return v end)
    yR = yR - 44

    BH("OPACITY", RX, yR) ; yR = yR - 22
    BS("LOXX_Blizz_Alpha", panel, RSL, yR, 0.3, 1.0, 0.05,
        db.alpha or 0.9,
        function(v) return string.format("Opacity: %.0f%%", v * 100) end,
        function(v)
            v = math.floor(v * 20 + 0.5) / 20
            db.alpha = v
            if mainFrame then mainFrame:SetAlpha(v) end
            return v
        end)

    -- Register with Settings API (TWW 12.0+)
    if Settings and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        category.ID = "LoxxInterruptTracker"
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

local function Initialize()
    LOXXSavedVars = LOXXSavedVars or {}
    LOXXSavedVars.db = LOXXSavedVars.db or {}
    db = LOXXSavedVars.db

    -- Migration: anciennes données en racine → .db
    for k, v in pairs(DEFAULTS) do
        if LOXXSavedVars[k] ~= nil and db[k] == nil then
            db[k] = LOXXSavedVars[k]
            LOXXSavedVars[k] = nil
        end
    end
    for _, k in ipairs({ "frameX", "frameY", "dbVersion" }) do
        if LOXXSavedVars[k] ~= nil and db[k] == nil then
            db[k] = LOXXSavedVars[k]
            LOXXSavedVars[k] = nil
        end
    end

    -- SavedVars schema versioning: fill new keys, remove obsolete ones.
    local savedVer = db.dbVersion or 1
    for k, v in pairs(DEFAULTS) do
        if db[k] == nil then db[k] = v end
    end
    if savedVer < LOXX_DB_VERSION then
        -- Remove keys that are no longer in DEFAULTS (avoids stale bloat)
        local keepKeys = { dbVersion = true, frameX = true, frameY = true }
        for k in pairs(db) do
            if not keepKeys[k] and DEFAULTS[k] == nil then
                db[k] = nil
            end
        end
        -- v3: force-reset bar dimensions removed from auto-scaling
        if savedVer < 3 then
            db.barHeight     = DEFAULTS.barHeight
            db.frameWidth    = DEFAULTS.frameWidth
            db.nameFontSize  = DEFAULTS.nameFontSize
            db.readyFontSize = DEFAULTS.readyFontSize
            db.readyTextSize = DEFAULTS.readyTextSize
        end
        -- v4: growUp removed; reset sizes to new compact defaults
        if savedVer < 4 then
            db.growUp      = nil
            db.barHeight   = DEFAULTS.barHeight
            db.frameWidth  = DEFAULTS.frameWidth
        end
    end
    db.dbVersion = LOXX_DB_VERSION

    -- Persistent storage outside db (not subject to DEFAULTS migrations)
    LOXXSavedVars.loxxRunHistory = LOXXSavedVars.loxxRunHistory or {}
    LOXXSavedVars.loxxErrorLog   = LOXXSavedVars.loxxErrorLog   or {}
    loxxErrorLog = LOXXSavedVars.loxxErrorLog
    rotationOrder = LOXXSavedVars.rotationOrder or {}
    rotationIndex = LOXXSavedVars.rotationIndex or 1

    -- Account-wide storage (position shared across all characters)
    LOXXAccountVars = LOXXAccountVars or {}

    pcall(C_ChatInfo.RegisterAddonMessagePrefix, MSG_PREFIX)

    local _, cls = UnitClass("player")
    myClass = cls
    myName = UnitName("player")

    DetectElvUI()
    CreateUI()
    RegisterBlizzardOptions()
    SetupSlash()
    FindMyInterrupt()

    ready = true

    if updateTicker then updateTicker:Cancel() end
    local lastTickErr = ""
    updateTicker = C_Timer.NewTicker(0.1, function()
        local ok, err = pcall(UpdateDisplay)
        if not ok then
            local e = tostring(err)
            if e ~= lastTickErr then
                lastTickErr = e
                LoxxLogError("Ticker: " .. e)
            end
        end
    end)

    -- Periodic re-inspect to detect talent changes on party members (every 30s)
    C_Timer.NewTicker(30, function()
        if not IsInGroup() then return end
        -- Reset inspected flags so next QueuePartyInspect re-checks talents
        for name in pairs(inspectedPlayers) do
            inspectedPlayers[name] = nil
        end
        QueuePartyInspect()
    end)

    C_Timer.After(2, AnnounceJoin)
    print("|cFF00DDDD[Loxx Interrupt Tracker]|r v" .. LOXX_VERSION .. " | /loxx")
end

------------------------------------------------------------
-- MAIN CHUNK (DO NOT TOUCH)
------------------------------------------------------------
local ef = CreateFrame("Frame")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("GROUP_ROSTER_UPDATE")
ef:RegisterEvent("PLAYER_ENTERING_WORLD")
ef:RegisterEvent("CHAT_MSG_ADDON")
ef:RegisterEvent("CHAT_MSG_ADDON_LOGGED")
-- SPELL_UPDATE_COOLDOWN removed (restricted in Midnight)
ef:RegisterEvent("SPELLS_CHANGED")
ef:RegisterEvent("PLAYER_REGEN_ENABLED")
ef:RegisterEvent("PLAYER_REGEN_DISABLED")
ef:RegisterEvent("INSPECT_READY")
ef:RegisterEvent("CHALLENGE_MODE_START")
ef:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
ef:RegisterEvent("UNIT_PET")
ef:RegisterEvent("ROLE_CHANGED_INFORM")
ef:RegisterEvent("PLAYER_LOGOUT")
-- COMBAT_LOG_EVENT_UNFILTERED is restricted in Midnight 12.0: Frame:RegisterEvent()
-- is blocked for this event. CD tracking for non-addon players falls back to
-- the existing UNIT_SPELLCAST_SUCCEEDED timestamp-correlation system.

-- Player's own casts: separate frame with unit filter
local playerCastFrame = CreateFrame("Frame")
playerCastFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
playerCastFrame:SetScript("OnEvent", function(_, _, unit, castGUID, spellID)
    -- Debug: log all player/pet casts in spy mode
    if spyMode and unit == "player" then
        local isInterrupt = ALL_INTERRUPTS[spellID] and "YES" or "no"
        local isExtra = myExtraKicks[spellID] and "YES" or "no"
        print("|cFF00DDDD[SPY]|r PLAYER cast spellID=" .. tostring(spellID) .. " interrupt=" .. isInterrupt .. " extra=" .. isExtra)
    end

    if unit == "pet" then
        if spyMode then
            print("|cFF00DDDD[SPY]|r PET cast detected on unit=pet")
        end

        -- Player's own pet: spell ID should be accessible, but wrap in pcall
        -- in case it is also secret on some Midnight builds.
        if spyMode then
            print("|cFF00DDDD[SPY]|r   pet spellID=" .. tostring(spellID) .. " mySpellID=" .. tostring(mySpellID))
        end

        local ok_lookup, data = pcall(function() return ALL_INTERRUPTS[spellID] end)
        if not ok_lookup then data = nil end
        local usedID = spellID

        if data then
            -- Check if it's an extra kick
            local isExtra = false
            for ekID, ekInfo in pairs(myExtraKicks) do
                if usedID == ekID then
                    ekInfo.cdEnd = GetTime() + ekInfo.baseCd
                    isExtra = true
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r   → EXTRA kick: " .. data.name .. " CD=" .. ekInfo.baseCd)
                    end
                    break
                end
            end
            if not isExtra then
                -- Auto-add as extra if different from primary
                if mySpellID and usedID ~= mySpellID then
                    myExtraKicks[usedID] = { baseCd = data.cd, cdEnd = GetTime() + data.cd }
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r   → AUTO-ADDED extra kick: " .. data.name .. " CD=" .. data.cd)
                    end
                else
                    local cd = myCachedCD or myBaseCd or data.cd
                    myKickCdEnd = GetTime() + cd
                    -- Broadcast to party addon users (Warlock Felhunter Spell Lock
                    -- fires on unit=="pet", not "player", so SendLOXX must be called here)
                    SendLOXX("CAST:" .. cd)
                    RecordKick(myName)
                    AdvanceRotation()
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r   → PRIMARY kick: " .. data.name .. " CD=" .. cd .. " (broadcast sent)")
                    end
                end
            end
        elseif spyMode then
            print("|cFF00DDDD[SPY]|r   → not a known interrupt")
        end
    else
        OnSpellCastSucceeded(unit, castGUID, spellID, false)
    end
end)


-- Track recent party casts for correlation (timestamp per player name)
local recentPartyCasts = {}

-- Handler for mob interrupt detection
local function OnMobInterrupted(unit)
    if spyMode then
        print("|cFF00DDDD[SPY-MOB]|r INTERRUPTED on " .. tostring(unit))
    end

    -- A mob was interrupted! Find who kicked via time correlation
    local now = GetTime()
    local bestName = nil
    local bestDelta = 999

    for name, ts in pairs(recentPartyCasts) do
        local delta = now - ts
        if delta > 1.0 then
            recentPartyCasts[name] = nil
        elseif delta < bestDelta then
            bestDelta = delta
            bestName = name
        end
    end

    if bestName and bestDelta < 1.5 then
        if spyMode then
            print("  |cFF00FF00>>> " .. bestName .. " kicked successfully! (delta=" .. string.format("%.3f", bestDelta) .. "s)|r")
        end

        if partyAddonUsers[bestName] then
            local info = partyAddonUsers[bestName]
            -- Set primary kick on cooldown (timestamp correlation confirmed an interrupt)
            -- This is the fallback path when UNIT_SPELLCAST_SUCCEEDED spell ID is secret.
            local baseCd = info.baseCd or 15
            info.cdEnd = now + baseCd
            -- Apply conditional CD reduction on top (e.g., Coldthirst: -3s on successful kick)
            if info.onKickReduction then
                local newCdEnd = info.cdEnd - info.onKickReduction
                if newCdEnd < now then newCdEnd = now end
                info.cdEnd = newCdEnd
                if spyMode then
                    local rem = newCdEnd - now
                    print("  |cFFFFFF00Coldthirst! CD reduced by " .. info.onKickReduction .. "s → " .. string.format("%.0f", rem) .. "s remaining|r")
                end
            end
        else
            -- Auto-register via class (non-addon user)
            RecordKick(bestName)  -- only here: addon users are counted via OnAddonMessage CAST
            if not noInterruptPlayers[bestName] then
                for idx = 1, 4 do
                    local u = "party" .. idx
                    if UnitExists(u) and UnitName(u) == bestName then
                        local _, cls = UnitClass(u)
                        local role = UnitGroupRolesAssigned(u)
                        if cls and CLASS_INTERRUPTS[cls] and not (role == "HEALER" and cls ~= "SHAMAN") then
                            local kickInfo = CLASS_INTERRUPTS[cls]
                            partyAddonUsers[bestName] = {
                                class = cls,
                                spellID = kickInfo.id,
                                baseCd = kickInfo.cd,
                                cdEnd = now + kickInfo.cd,
                            }
                            if spyMode then
                                print("  Registered " .. bestName .. " (" .. cls .. ") CD=" .. kickInfo.cd)
                            end
                        end
                        break
                    end
                end
            end
        end
    elseif spyMode then
        print("  No matching party cast (best=" .. tostring(bestName) .. " delta=" .. string.format("%.3f", bestDelta) .. ")")
    end
end

-- Mob interrupt detection: target, focus, boss units (always tracked in instances),
-- and nameplate units (handled below).
local mobInterruptFrame = CreateFrame("Frame")
mobInterruptFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED",
    "target", "focus",
    "boss1", "boss2", "boss3", "boss4", "boss5")
mobInterruptFrame:SetScript("OnEvent", function(self, event, unit)
    OnMobInterrupted(unit)
end)

-- Nameplate interrupt tracking: one frame per nameplate
local nameplateCastFrames = {}
local nameplateFrame = CreateFrame("Frame")
nameplateFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
nameplateFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
nameplateFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        if not nameplateCastFrames[unit] then
            nameplateCastFrames[unit] = CreateFrame("Frame")
        end
        local f = nameplateCastFrames[unit]
        f:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
        f:SetScript("OnEvent", function(_, _, eUnit)
            OnMobInterrupted(eUnit)
        end)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        if nameplateCastFrames[unit] then
            nameplateCastFrames[unit]:UnregisterAllEvents()
            nameplateCastFrames[unit] = nil
        end
    end
end)

-- Party event frames: OnValueChanged spell detection + time correlation
RegisterPartyWatchers = function()
    for i = 1, 4 do
        local unit = "party" .. i
        partyFrames[i]:UnregisterAllEvents()
        if UnitExists(unit) then
            partyFrames[i]:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
            partyFrames[i]:SetScript("OnEvent", function(self, event, eUnit, eCastGUID, eSpellID, eCastBarID)
                local cleanUnit = "party" .. i
                local cleanName = UnitName(cleanUnit)

                -- Store timestamp for correlation backup
                if cleanName then
                    recentPartyCasts[cleanName] = GetTime()
                end

                -- In Midnight, eSpellID is a secret value and cannot be used
                -- as a table index. Detection is handled entirely by
                -- UNIT_SPELLCAST_INTERRUPTED correlation (timestamp above).
                if spyMode then
                    print("|cFF00DDDD[SPY]|r SUCCEEDED " .. cleanUnit .. " (" .. tostring(cleanName) .. ") — timestamp stored for correlation")
                end
            end)
        end
    end
    if spyMode then
        local reg = {}
        for i = 1, 4 do
            local u = "party" .. i
            if UnitExists(u) then table.insert(reg, u .. "=" .. (UnitName(u) or "?")) end
        end
        print("|cFF00DDDD[SPY]|r Watchers: " .. (#reg > 0 and table.concat(reg, ", ") or "none"))
    end

    -- Pet watchers (Warlock Felhunter Spell Lock, Hunter pet, etc.)
    for i = 1, 4 do
        local petUnit = "partypet" .. i
        local ownerUnit = "party" .. i
        partyPetFrames[i]:UnregisterAllEvents()
        if UnitExists(petUnit) then
            partyPetFrames[i]:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", petUnit)
            partyPetFrames[i]:SetScript("OnEvent", function(self, event, eUnit, eCastGUID, eSpellID, eCastBarID)
                local cleanOwner = "party" .. i
                local cleanName = UnitName(cleanOwner)

                -- Store timestamp for correlation
                if cleanName then
                    recentPartyCasts[cleanName] = GetTime()
                end

                -- In Midnight, eSpellID is a secret value for party pets too.
                -- Timestamp stored above is sufficient for correlation.
                if spyMode then
                    print("|cFF00DDDD[SPY]|r PET SUCCEEDED partypet" .. i .. " (owner=" .. tostring(cleanName) .. ") — timestamp stored")
                end
            end)
        end
    end
end

ef:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        Initialize()
    elseif event == "CHAT_MSG_ADDON" or event == "CHAT_MSG_ADDON_LOGGED" then
        OnAddonMessage(arg1, arg2, arg3, arg4)
    -- SPELL_UPDATE_COOLDOWN removed (restricted in Midnight)
    elseif event == "SPELLS_CHANGED" then
        FindMyInterrupt()
        AnnounceJoin()
        -- For warlocks: pet spellbook may not be ready yet, retry
        if myClass == "WARLOCK" then
            C_Timer.After(1.5, FindMyInterrupt)
            C_Timer.After(3.0, FindMyInterrupt)
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        CheckZoneVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        CheckZoneVisibility()
    elseif event == "INSPECT_READY" then
        if inspectBusy and inspectUnit then
            local ok, err = pcall(ScanInspectTalents, inspectUnit)
            if not ok and spyMode then
                print("|cFFFF0000[SPY]|r Inspect scan error: " .. tostring(err))
            end
            ClearInspectPlayer()
            inspectBusy = false
            inspectUnit = nil
            C_Timer.After(0.5, ProcessInspectQueue)
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local changedUnit = arg1
        if changedUnit and changedUnit ~= "player" then
            local name = UnitName(changedUnit)
            if name then
                inspectedPlayers[name] = nil
                noInterruptPlayers[name] = nil
                -- Re-register with class default
                local _, cls = UnitClass(changedUnit)
                if cls and CLASS_INTERRUPTS[cls] then
                    local kickInfo = CLASS_INTERRUPTS[cls]
                    partyAddonUsers[name] = {
                        class = cls,
                        spellID = kickInfo.id,
                        baseCd = kickInfo.cd,
                        cdEnd = 0,
                        onKickReduction = nil,
                    }
                end
                if spyMode then
                    print("|cFF00DDDD[SPY]|r " .. name .. " changed spec → re-inspecting")
                end
                C_Timer.After(1, QueuePartyInspect)
            end
        end
    elseif event == "UNIT_PET" then
        local unit = arg1
        -- Own pet changed → re-detect our kicks (multiple retries as pet spellbook loads slowly)
        if unit == "player" then
            C_Timer.After(0.5, FindMyInterrupt)
            C_Timer.After(1.5, FindMyInterrupt)
            C_Timer.After(3.0, FindMyInterrupt)
            if spyMode then
                C_Timer.After(3.0, function()
                    print("|cFF00DDDD[SPY]|r Pet changed → primary kick: " .. tostring(mySpellID))
                end)
            end
        end
        -- Party pet changed → re-inspect and re-register watchers
        RegisterPartyWatchers()
        if unit and unit:find("^party") then
            local name = UnitName(unit)
            if name then
                inspectedPlayers[name] = nil
                C_Timer.After(1, QueuePartyInspect)
                if spyMode then
                    print("|cFF00DDDD[SPY]|r " .. name .. " pet changed → re-inspecting")
                end
            end
        end
    elseif event == "ROLE_CHANGED_INFORM" then
        -- Roles changed → remove healers without kick
        for i = 1, 4 do
            local u = "party" .. i
            if UnitExists(u) then
                local name = UnitName(u)
                local _, cls = UnitClass(u)
                local role = UnitGroupRolesAssigned(u)
                if name and role == "HEALER" and cls ~= "SHAMAN" and partyAddonUsers[name] then
                    partyAddonUsers[name] = nil
                    noInterruptPlayers[name] = true
                    if spyMode then
                        print("|cFF00DDDD[SPY]|r Role changed: " .. name .. " is HEALER (" .. cls .. ") → removed")
                    end
                end
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        CleanPartyList()
        RegisterPartyWatchers()
        AutoRegisterPartyByClass()
        CheckZoneVisibility()   -- hide/show based on group size (raid = 6+)
        -- Rebuild bars if group size changed category (5 → 10 → 20 → 40)
        if UpdateMaxBars() then RebuildBars() end
        -- Queue inspect for new members (1s delay for units to be ready)
        C_Timer.After(1, QueuePartyInspect)
    elseif event == "PLAYER_ENTERING_WORLD" then
        inCombat = InCombatLockdown()  -- vrai si reload UI en combat
        pcall(C_ChatInfo.RegisterAddonMessagePrefix, MSG_PREFIX)
        CheckZoneVisibility()
        RegisterPartyWatchers()
        AutoRegisterPartyByClass()
        -- Stats: start new run if entering a new instance
        local inInst, instType = IsInInstance()
        if inInst and (instType == "party" or instType == "raid" or instType == "arena") then
            local _, _, _, _, _, _, _, newInstanceID = GetInstanceInfo()
            if not loxxCurrentRun or loxxCurrentRun.instanceID ~= newInstanceID then
                StartNewRun()
            end
        end
        -- Rotation: restore from SavedVars
        if LOXXSavedVars and LOXXSavedVars.rotationOrder then
            rotationOrder = LOXXSavedVars.rotationOrder
            rotationIndex = LOXXSavedVars.rotationIndex or 1
        end
        C_Timer.After(1, AutoRegisterPartyByClass)
        C_Timer.After(2, QueuePartyInspect) -- inspect any not-yet-inspected members
        C_Timer.After(3, function()
            FindMyInterrupt()
            AnnounceJoin()
            AutoRegisterPartyByClass()
        end)
    elseif event == "CHALLENGE_MODE_START" then
        StartNewRun()
    elseif event == "PLAYER_LOGOUT" then
        -- Persist frame position right before WoW saves variables
        if mainFrame then LoxxSaveFramePosition(mainFrame) end
    end
end)
