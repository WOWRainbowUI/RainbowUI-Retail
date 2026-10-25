-- Behavioral tests for Season 2 raid tracking (Lua 5.1): The Unbinding of Kith'ix,
-- The Tidebound Grotto difficulties and Venomous Abyss saved-lockout boss mapping.
-- Loads the real locale files (client language deDE) and RaidLockouts.lua with a
-- minimal WoW API harness, and drives the same entry points the game uses:
-- ENCOUNTER_END, saved-lockout scans, the weekly reset path, raid tabs and the grid.
-- Run from the addon root:  lua5.1 tools/Test-RaidKithix.lua

local S2, KITHIX = "midnight_s2", "midnight_s2_kithix"
local TIDEBOUND, VENOMOUS = "midnight_s2_tidebound_grotto", "midnight_s2_venomous_abyss"
local KITHIX_INSTANCE_ID, KITHIX_ENCOUNTER_ID = 3095, 3513
local TIDEBOUND_INSTANCE_ID, NYMRISSA_ENCOUNTER_ID = 2987, 3379
local VENOMOUS_INSTANCE_ID, VASHNIK_ENCOUNTER_ID = 3004, 3455
local LFR, NORMAL, HEROIC, MYTHIC, MYTHIC_FLEX, STORY, WORLD = 17, 14, 15, 16, 233, 220, 250

local failures, checks = {}, 0
local function check(condition, message)
    checks = checks + 1
    if not condition then failures[#failures + 1] = message end
end

-- ---------------------------------------------------------------- WoW harness
local now = 1800000000
local created, timers = {}, {}
local stubMeta = {}
local function NewStub(kind, name, parent)
    local object = setmetatable({ _kind = kind, _scripts = {}, _events = {}, _shown = false, _parent = parent }, stubMeta)
    created[#created + 1] = object
    if name then _G[name] = object end
    return object
end
local numericGetters = {
    GetFrameLevel = 1, GetStringWidth = 40, GetWidth = 100, GetHeight = 20, GetNumPoints = 0,
    GetLeft = 0, GetRight = 0, GetTop = 0, GetBottom = 0, GetAlpha = 1, GetScale = 1, GetEffectiveScale = 1,
}
local creators = { CreateFontString = true, CreateTexture = true, CreateMaskTexture = true, CreateAnimationGroup = true, CreateLine = true }
stubMeta.__index = function(self, key)
    if numericGetters[key] then return function() return numericGetters[key] end end
    if creators[key] then return function(owner) return NewStub(key, nil, owner) end end
    if key == "SetScript" then return function(owner, scriptName, fn) owner._scripts[scriptName] = fn end end
    if key == "GetScript" then return function(owner, scriptName) return owner._scripts[scriptName] end end
    if key == "HookScript" then
        return function(owner, scriptName, fn)
            local previous = owner._scripts[scriptName]
            owner._scripts[scriptName] = function(...) if previous then previous(...) end return fn(...) end
        end
    end
    if key == "RegisterEvent" then return function(owner, event) owner._events[event] = true end end
    if key == "UnregisterEvent" then return function(owner, event) owner._events[event] = nil end end
    if key == "IsEventRegistered" then return function(owner, event) return owner._events[event] == true end end
    if key == "SetText" then return function(owner, text) owner._text = text end end
    if key == "GetText" then return function(owner) return owner._text end end
    if key == "Show" then return function(owner) owner._shown = true end end
    if key == "Hide" then return function(owner) owner._shown = false end end
    if key == "IsShown" or key == "IsVisible" then return function(owner) return owner._shown end end
    if key == "GetParent" then return function(owner) return owner._parent end end
    if key == "IsMouseOver" then return function() return false end end
    -- WoW widget methods are PascalCase; lowercase keys are addon fields and stay nil.
    if type(key) == "string" and key:match("^%u") then return function() return nil end end
    return nil
end

local lv = {
    PLAYER_KEY = "Alpha-Realm",
    REGION = "US",
}
local theme = setmetatable({}, { __index = function() return { 0.5, 0.5, 0.5, 1 } end })
local weeklyResetStart = now - 3600
lv.GetTheme = function() return theme end
lv.RegisterThemedElement = function() end
lv.EnsureBorderStyle = function() end
lv.ApplyBorderStyle = function() end
lv.ApplyLocaleFont = function() end
lv.GetLastWeeklyReset = function() return weeklyResetStart end
lv.IsLiteVaultCharacterRecord = function(charKey, data)
    return type(charKey) == "string" and type(data) == "table" and data.class ~= nil and data.class ~= "Bank"
end

local instance = { name = nil, difficulty = nil, instanceID = nil }
local savedInstances = {}
local secondsUntilWeeklyReset = 6 * 86400
local requestRaidInfoCount = 0

CreateFrame = function(kind, name, parent) return NewStub(kind, name, parent) end
UIParent = NewStub("UIParent")
UISpecialFrames = {}
tinsert = table.insert
GameTooltip = NewStub("GameTooltip")
C_Timer = {
    After = function(_, fn) timers[#timers + 1] = fn end,
    NewTicker = function() return { Cancel = function() end } end,
}
GetServerTime = function() return now end
time = function() return now end
date = os.date
C_DateAndTime = { GetSecondsUntilWeeklyReset = function() return secondsUntilWeeklyReset end }
InCombatLockdown = function() return false end
RequestRaidInfo = function() requestRaidInfoCount = requestRaidInfoCount + 1 end
GetNumSavedInstances = function() return #savedInstances end
GetSavedInstanceInfo = function(index)
    local s = savedInstances[index]
    -- name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid,
    -- maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId
    return s.name, 1, s.reset, s.difficulty, true, false, 0, true, 20, "", #s.encounters, 0, false, s.instanceID
end
GetSavedInstanceEncounterInfo = function(index, bossIndex)
    local encounter = savedInstances[index].encounters[bossIndex]
    return encounter and encounter.name, nil, encounter and encounter.dead
end
GetInstanceInfo = function() return instance.name, "raid", instance.difficulty, "", 20, 0, false, instance.instanceID end
C_ClassColor = { GetClassColor = function()
    return { r = 1, g = 1, b = 1, WrapTextInColorCode = function(_, text) return text end, GenerateHexColor = function() return "ffffffff" end }
end }
RAID_CLASS_COLORS = setmetatable({}, { __index = function() return { r = 1, g = 1, b = 1, colorStr = "ffffffff" } end })
GetStatistic = function() return "0" end
C_Map = { GetBestMapForUnit = function() return nil end }
hooksecurefunc = function() end
SlashCmdList = {}
GetLocale = function() return "deDE" end

-- ------------------------------------------------------------ saved variables
local function NewCharacter(class) return { class = class, level = 90, lastLogin = now } end
LiteVaultOrder = { "Alpha-Realm", "Beta-Realm", "Gamma-Realm", "Delta-Realm" }
LiteVaultDB = {
    ["Alpha-Realm"] = NewCharacter("MAGE"),
    ["Beta-Realm"] = NewCharacter("PRIEST"),
    ["Delta-Realm"] = NewCharacter("ROGUE"),
    ["Warband Bank"] = { class = "Bank", gold = 0 },
}
-- Gamma predates Kith'ix: schema-5 history and a current Venomous Abyss lockout.
LiteVaultDB["Gamma-Realm"] = NewCharacter("WARRIOR")
LiteVaultDB["Gamma-Realm"].raidData = {
    schemaVersion = 5,
    seasons = { [S2] = { raids = { midnight_s2_venomous_abyss = { difficulties = {
        [16] = { encounters = { [3420] = { killed = true, bossIndex = 5, encounterID = 3420, displayName = "Sszorak" } }, updatedAt = now - 100 },
    } } } } },
}
LiteVaultDB["Gamma-Realm"].raidLockouts = { [S2] = { midnight_s2_venomous_abyss = {
    [16] = { bosses = { [5] = true }, bossNames = { [5] = "Sszorak" }, scannedAt = now - 100 },
} } }

-- ------------------------------------------------------------------- load
-- Same order as LiteVault.toc: the localization core, English, the client locale, the overlay.
for _, localeFile in ipairs({ "Locales/Localization.lua", "Locales/enUS.lua", "Locales/deDE.lua", "Locales/Repair.lua" }) do
    assert(loadfile(localeFile))("LiteVault", lv)
end
local L = lv.L
assert(L["The Tidebound Grotto"] == "Die Gezeitengebundene Grotte", "deDE locale data did not load")
local chunk = assert(loadfile("RaidLockouts.lua"))
chunk("LiteVault", lv)

local eventFrame
for _, object in ipairs(created) do
    if object._events.ENCOUNTER_END then eventFrame = object end
end
assert(eventFrame and eventFrame._scripts.OnEvent, "ENCOUNTER_END handler was not registered")
local function Fire(event, ...) eventFrame._scripts.OnEvent(eventFrame, event, ...) end
local function FlushTimers()
    local guard = 0
    while #timers > 0 and guard < 200 do
        local pending = timers
        timers = {}
        for _, fn in ipairs(pending) do fn() end
        guard = guard + 1
    end
end
local function EnterKithix(name, difficulty, instanceID)
    instance.name, instance.difficulty, instance.instanceID = name, difficulty, instanceID
end
local function Kill(name, difficulty, success)
    Fire("ENCOUNTER_END", KITHIX_ENCOUNTER_ID, name, difficulty, 20, success == nil and 1 or success)
end
local function Progress(charKey, difficulty) return lv.GetCharacterRaidBossState(charKey, S2, KITHIX, difficulty, 1) end
local function Weekly(charKey, difficulty) return lv.GetCharacterRaidWeeklyBossState(charKey, S2, KITHIX, difficulty, 1) end
-- Switching characters in game is a relog: per-session live raid state starts empty.
local function SwitchCharacter(charKey)
    lv.PLAYER_KEY = charKey
    lv._liveRaidState, lv._liveRaidResetEpoch, lv._pendingRaidEncounter = nil, nil, nil
end
local function Enter(name, difficulty, instanceID)
    instance.name, instance.difficulty, instance.instanceID = name, difficulty, instanceID
end

-- ------------------------------------------------------------ configuration
local season = lv.RAID_SEASONS[S2]
check(season and season.raidOrder[3] == KITHIX and #season.raidOrder == 3, "Kith'ix is not the third Season 2 raid")
check(lv.GetRaidBossCount(S2, KITHIX) == 1, "Kith'ix boss count is not 1")
local raidCount = 0
for _, configuredSeason in pairs(lv.RAID_SEASONS) do for _ in pairs(configuredSeason.raids) do raidCount = raidCount + 1 end end
check(raidCount == 7, "expected 7 configured raids (6 existing + Kith'ix), found " .. raidCount)
local difficultyIDs = {}
for _, difficultyInfo in ipairs(season.raids[KITHIX].difficulties) do
    difficultyIDs[#difficultyIDs + 1] = difficultyInfo.storageKey .. ":" .. difficultyInfo.tag
end
check(table.concat(difficultyIDs, ",") == "17:L,14:N,15:H,233:M", "Kith'ix difficulties are " .. table.concat(difficultyIDs, ","))

-- ---------------------------------------------- identification (locale-safe)
local function Resolve(name, id) local seasonKey, raidKey = lv.ResolveConfiguredRaid(name, id) return raidKey end
check(Resolve("Освобождение Кит'икса", KITHIX_INSTANCE_ID) == KITHIX, "Kith'ix not resolved by instance ID on a ruRU name")
check(Resolve(nil, KITHIX_INSTANCE_ID) == KITHIX, "Kith'ix not resolved by instance ID alone")
check(Resolve("The Unbinding of Kith'ix", nil) == KITHIX, "Kith'ix English name fallback failed")
check(Resolve("Die Entfesslung von Kith'ix", nil) == KITHIX, "Kith'ix deDE name fallback failed")
check(Resolve("The Voidspire", 2912) == "midnight_s1_voidspire", "Voidspire ID resolution regressed")
check(Resolve(nil, 2939) == "midnight_s1_dreamrift", "Dreamrift ID resolution regressed")
check(Resolve(nil, 2913) == "midnight_s1_march", "March on Quel'Danas ID resolution regressed")
check(Resolve(nil, 3004) == "midnight_s2_venomous_abyss", "Venomous Abyss ID resolution regressed")
check(Resolve(nil, 2987) == "midnight_s2_tidebound_grotto", "Tidebound Grotto ID resolution regressed")
check(Resolve("Sporefall", nil) == "midnight_s1_sporefall", "Sporefall name fallback regressed")
check(Resolve(nil, 16279) == nil, "Sporefall's old AreaTable ID 16279 resolves again")
check(Resolve("Some Dungeon", 9999) == nil, "an unrelated instance resolved to a raid")

-- --------------------------------------------------------------- 0/1 state
for _, difficulty in ipairs({ LFR, NORMAL, HEROIC, MYTHIC_FLEX }) do
    check(not Progress("Alpha-Realm", difficulty) and not Weekly("Alpha-Realm", difficulty), "fresh character shows a Kith'ix kill on difficulty " .. difficulty)
end
check(lv.GetRaidProgressionCount("Alpha-Realm", S2, KITHIX, MYTHIC_FLEX) == 0, "fresh Kith'ix progress is not 0/1")

-- Story Mode has no lockout; a Story kill must record nothing.
EnterKithix("Освобождение Кит'икса", STORY, KITHIX_INSTANCE_ID)
Kill("Кит'икс", STORY)
check(not Progress("Alpha-Realm", STORY) and not Weekly("Alpha-Realm", STORY), "a Story Mode kill was recorded")
local alphaLockouts = LiteVaultDB["Alpha-Realm"].raidLockouts
check(not (alphaLockouts and alphaLockouts[S2] and alphaLockouts[S2][KITHIX] and alphaLockouts[S2][KITHIX][STORY]), "a Story Mode lockout bucket was created")

-- A wipe must record nothing.
EnterKithix("Освобождение Кит'икса", MYTHIC_FLEX, KITHIX_INSTANCE_ID)
Kill("Кит'икс", MYTHIC_FLEX, 0)
check(not Progress("Alpha-Realm", MYTHIC_FLEX), "a failed Kith'ix attempt was recorded")

-- --------------------------------- 1/1: flexible Mythic kill on a ruRU client
Kill("Кит'икс", MYTHIC_FLEX)
check(Progress("Alpha-Realm", MYTHIC_FLEX), "Mythic (233) kill missing from character progression")
check(Weekly("Alpha-Realm", MYTHIC_FLEX), "Mythic (233) kill missing from this week's lockout")
check(lv.GetRaidProgressionCount("Alpha-Realm", S2, KITHIX, MYTHIC_FLEX) == 1, "Kith'ix Mythic progress is not 1/1")
for _, difficulty in ipairs({ LFR, NORMAL, HEROIC }) do
    check(not Progress("Alpha-Realm", difficulty), "Mythic kill leaked into difficulty " .. difficulty)
end
local function Dig(value, ...)
    for _, key in ipairs({ ... }) do
        if type(value) ~= "table" then return nil end
        value = value[key]
    end
    return value
end
local stored = Dig(LiteVaultDB["Alpha-Realm"], "raidData", "seasons", S2, "raids", KITHIX, "difficulties", MYTHIC_FLEX, "encounters", KITHIX_ENCOUNTER_ID)
check(stored and stored.bossIndex == 1 and stored.encounterID == KITHIX_ENCOUNTER_ID, "kill not stored under encounter 3513 / boss 1")
check(stored and stored.displayName == "Kith'ix", "stored kill does not use the canonical boss name")
check(stored and stored.firstKillSource == "observed" and stored.firstKillAt == now, "first-kill date was not recorded as observed")
check(not lv.GetCharacterRaidBossState("Alpha-Realm", S2, "midnight_s2_venomous_abyss", 16, 1)
    and not lv.GetCharacterRaidBossState("Alpha-Realm", S2, "midnight_s2_venomous_abyss", MYTHIC_FLEX, 1), "Kith'ix kill leaked into Venomous Abyss boss 1")
check(not lv.GetCharacterRaidBossState("Alpha-Realm", S2, "midnight_s2_tidebound_grotto", 16, 1), "Kith'ix kill leaked into Tidebound Grotto")

-- Encounter ID wins even when the instance cannot be identified.
EnterKithix("Unrecognized Instance Name", HEROIC, nil)
Kill("Кит'икс", HEROIC)
check(Progress("Alpha-Realm", HEROIC) and Weekly("Alpha-Realm", HEROIC), "Heroic kill not matched by encounter ID 3513")

-- ------------------------------------------------------- character isolation
for _, difficulty in ipairs({ LFR, NORMAL, HEROIC, MYTHIC_FLEX }) do
    check(not Progress("Beta-Realm", difficulty) and not Weekly("Beta-Realm", difficulty), "Alpha's kill appears on Beta at difficulty " .. difficulty)
end
local warbandKilled, killers = lv.GetWarbandRaidBossState(S2, KITHIX, MYTHIC_FLEX, 1)
check(warbandKilled and #killers == 1 and killers[1].key == "Alpha-Realm", "warband row does not credit exactly Alpha")
check(LiteVaultDB["Warband Bank"].raidLockouts == nil and LiteVaultDB["Warband Bank"].raidData == nil, "raid data was written to the Warband Bank record")

-- ------------------------------------------- saved lockouts and resync (Beta)
lv.PLAYER_KEY = "Beta-Realm"
savedInstances = {
    { name = "Die Entfesslung von Kith'ix", reset = 3600, difficulty = NORMAL, instanceID = KITHIX_INSTANCE_ID, encounters = { { name = "Kith'ix", dead = true } } },
    { name = "Die Entfesslung von Kith'ix", reset = 0, difficulty = HEROIC, instanceID = KITHIX_INSTANCE_ID, encounters = { { name = "Kith'ix", dead = true } } },
    { name = "Die Entfesslung von Kith'ix", reset = 3600, difficulty = STORY, instanceID = KITHIX_INSTANCE_ID, encounters = { { name = "Kith'ix", dead = true } } },
}
lv.ScanRaidInfoPanel()
check(Weekly("Beta-Realm", NORMAL) and Progress("Beta-Realm", NORMAL), "saved Normal lockout was not imported")
check(not Weekly("Beta-Realm", HEROIC), "an expired (previous week) lockout was imported")
check(not Weekly("Beta-Realm", STORY), "a Story Mode saved entry was imported")
check(Progress("Alpha-Realm", MYTHIC_FLEX) and not Progress("Alpha-Realm", NORMAL), "Beta's scan changed Alpha's data")

-- ------------------------------------------------------------- weekly reset
LiteVaultDB["Beta-Realm"].lastLockoutReset = now - 8 * 86400
savedInstances = {}
lv.ScanRaidLockouts()
FlushTimers()
check(not Weekly("Beta-Realm", NORMAL), "this-week Kith'ix lockout survived the weekly reset")
check(Progress("Beta-Realm", NORMAL), "weekly reset erased Kith'ix progression history")
check(requestRaidInfoCount > 0, "weekly scan did not request fresh raid info")

-- --------------------------------------------- saved-variable compatibility
lv.EnsureRaidDataSchema(LiteVaultDB["Gamma-Realm"])
lv.PLAYER_KEY = "Gamma-Realm"
lv.ScanRaidInfoPanel()
local gamma = LiteVaultDB["Gamma-Realm"]
check(gamma.raidData.schemaVersion == 5, "raid schema version changed")
check(lv.GetCharacterRaidBossState("Gamma-Realm", S2, "midnight_s2_venomous_abyss", 16, 5), "existing Venomous Abyss history was lost")
check(gamma.raidLockouts[S2][KITHIX] ~= nil, "existing character did not receive an empty Kith'ix lockout bucket")
check(not Progress("Gamma-Realm", MYTHIC_FLEX), "existing character shows an unearned Kith'ix kill")

-- ------------------------------------------------------ The Tidebound Grotto
-- Client MapDifficulty for map 2987: World 250, Normal 14, Heroic 15, flexible Mythic 233.
local tideboundDifficulties = {}
for _, difficultyInfo in ipairs(season.raids[TIDEBOUND].difficulties) do
    tideboundDifficulties[#tideboundDifficulties + 1] = tostring(difficultyInfo.storageKey) .. ":" .. difficultyInfo.tag
end
check(table.concat(tideboundDifficulties, ",") == "250:W,14:N,15:H,233:M", "Tidebound difficulties are " .. table.concat(tideboundDifficulties, ","))
local function Tidebound(charKey, difficulty) return lv.GetCharacterRaidBossState(charKey, S2, TIDEBOUND, difficulty, 1) end
local function TideboundWeekly(charKey, difficulty) return lv.GetCharacterRaidWeeklyBossState(charKey, S2, TIDEBOUND, difficulty, 1) end

SwitchCharacter("Alpha-Realm")
Enter(L["The Tidebound Grotto"], MYTHIC_FLEX, TIDEBOUND_INSTANCE_ID)
Fire("ENCOUNTER_END", NYMRISSA_ENCOUNTER_ID, L["Nymrissa Wavecaller"], MYTHIC_FLEX, 25, 1)
check(Tidebound("Alpha-Realm", MYTHIC_FLEX) and TideboundWeekly("Alpha-Realm", MYTHIC_FLEX), "Tidebound Mythic (233) kill was not recorded")
check(not Tidebound("Alpha-Realm", MYTHIC) and not TideboundWeekly("Alpha-Realm", MYTHIC), "Tidebound Mythic kill was stored under fixed Mythic 16")
Enter(L["The Tidebound Grotto"], WORLD, TIDEBOUND_INSTANCE_ID)
Fire("ENCOUNTER_END", NYMRISSA_ENCOUNTER_ID, L["Nymrissa Wavecaller"], WORLD, 40, 1)
check(Tidebound("Alpha-Realm", WORLD) and TideboundWeekly("Alpha-Realm", WORLD), "Tidebound World (250) kill was not recorded")
check(not Tidebound("Alpha-Realm", NORMAL) and not Tidebound("Alpha-Realm", HEROIC), "Tidebound kills leaked into Normal/Heroic")
check(not Progress("Alpha-Realm", WORLD) and not lv.GetCharacterRaidBossState("Alpha-Realm", S2, VENOMOUS, WORLD, 1), "World kill leaked into another raid")

SwitchCharacter("Beta-Realm")
savedInstances = {
    { name = L["The Tidebound Grotto"], reset = 3600, difficulty = WORLD, instanceID = TIDEBOUND_INSTANCE_ID, encounters = { { name = L["Nymrissa Wavecaller"], dead = true } } },
}
lv.ScanRaidInfoPanel()
check(TideboundWeekly("Beta-Realm", WORLD) and Tidebound("Beta-Realm", WORLD), "saved Tidebound World lockout was not imported")
check(not TideboundWeekly("Beta-Realm", MYTHIC_FLEX), "Beta shows Alpha's Tidebound Mythic kill")
savedInstances = {}

-- -------------------------------------------- Venomous Abyss saved boss mapping
-- Saved lockouts list encounters in Blizzard's lockout-slot (Bit) order from the client
-- DungeonEncounter table, which differs from LiteVault's display order.
local VENOMOUS_DISPLAY = { "Nek'zali the Soulcoiler", "Entombed Sentinels", "Vashnik the Malignant", "The Lost Explorers",
    "Sszorak", "The Twin Fangs", "The Coiled Altar", "Ula'tek" }
local VENOMOUS_SAVED_ORDER = { "Sszorak", "The Twin Fangs", "The Coiled Altar", "Entombed Sentinels",
    "Vashnik the Malignant", "Nek'zali the Soulcoiler", "Ula'tek", "The Lost Explorers" }
local function DisplayIndex(englishName)
    for index, name in ipairs(VENOMOUS_DISPLAY) do if name == englishName then return index end end
end
local function SavedVenomous(difficulty, dead, localized)
    local encounters = {}
    for i, englishName in ipairs(VENOMOUS_SAVED_ORDER) do
        encounters[i] = { name = localized and L[englishName] or englishName, dead = dead[englishName] == true }
    end
    return { name = localized and L["The Venomous Abyss"] or "The Venomous Abyss", reset = 3600, difficulty = difficulty, instanceID = VENOMOUS_INSTANCE_ID, encounters = encounters }
end
local function VenomousWeekly(index, difficulty) return lv.GetCharacterRaidWeeklyBossState("Delta-Realm", S2, VENOMOUS, difficulty, index) end
local function VenomousProgress(index, difficulty) return lv.GetCharacterRaidBossState("Delta-Realm", S2, VENOMOUS, difficulty, index) end
local function OnlyMarked(difficulty, expected, label)
    for index = 1, 8 do
        local want = expected[index] == true
        check(VenomousWeekly(index, difficulty) == want, string.format("%s: boss %d (%s) this-week state should be %s", label, index, VENOMOUS_DISPLAY[index], tostring(want)))
    end
end

SwitchCharacter("Delta-Realm")
check(L["Sszorak"] == "Sszorak" and L["The Lost Explorers"] == "Die verirrten Entdecker", "deDE Venomous Abyss boss names did not load")
savedInstances = { SavedVenomous(MYTHIC, { ["Sszorak"] = true, ["The Lost Explorers"] = true }, true) }
lv.ScanRaidInfoPanel()
OnlyMarked(MYTHIC, { [DisplayIndex("Sszorak")] = true, [DisplayIndex("The Lost Explorers")] = true }, "deDE saved lockout")
check(VenomousProgress(5, MYTHIC) and VenomousProgress(4, MYTHIC) and not VenomousProgress(1, MYTHIC) and not VenomousProgress(8, MYTHIC),
    "deDE saved kills were recorded against list positions instead of bosses")

savedInstances = { SavedVenomous(HEROIC, { ["Ula'tek"] = true, ["Nek'zali the Soulcoiler"] = true }, false) }
lv.ScanRaidInfoPanel()
OnlyMarked(HEROIC, { [DisplayIndex("Ula'tek")] = true, [DisplayIndex("Nek'zali the Soulcoiler")] = true }, "English saved lockout")

-- Raid Finder lockouts count every encounter in the instance, so a wing can start at index 4.
savedInstances = { { name = L["The Venomous Abyss"], reset = 3600, difficulty = LFR, instanceID = VENOMOUS_INSTANCE_ID, encounters = {
    { name = L["Sszorak"], dead = false }, { name = L["The Twin Fangs"], dead = false }, { name = L["The Coiled Altar"], dead = false },
    { name = L["Vashnik the Malignant"], dead = true },
} } }
lv.ScanRaidInfoPanel()
OnlyMarked(LFR, { [DisplayIndex("Vashnik the Malignant")] = true }, "Raid Finder wing lockout")

-- An unrecognised name in a multi-boss raid is skipped, never guessed by position.
savedInstances = { { name = L["The Venomous Abyss"], reset = 3600, difficulty = NORMAL, instanceID = VENOMOUS_INSTANCE_ID, encounters = { { name = "Unbekannter Boss", dead = true } } } }
lv.ScanRaidInfoPanel()
OnlyMarked(NORMAL, {}, "unknown saved name")
check(lv.lastUnmatchedSavedEncounter and lv.lastUnmatchedSavedEncounter.name == "Unbekannter Boss", "unmatched saved encounter was not recorded for diagnostics")

-- Live kills use the locale-independent encounter ID.
savedInstances = {}
Enter(L["The Venomous Abyss"], NORMAL, VENOMOUS_INSTANCE_ID)
Fire("ENCOUNTER_END", VASHNIK_ENCOUNTER_ID, L["Vashnik the Malignant"], NORMAL, 20, 1)
check(VenomousProgress(3, NORMAL) and VenomousWeekly(3, NORMAL), "Vashnik (3455) kill was not mapped to boss 3")
check(not VenomousProgress(5, NORMAL), "encounter-ID kill was mapped to the wrong boss")

-- Legacy raids without encounter IDs keep their previous position-based mapping.
savedInstances = { { name = L["The Voidspire"], reset = 3600, difficulty = MYTHIC, instanceID = 2912, encounters = {
    { name = "Unbekannt A", dead = false }, { name = "Unbekannt B", dead = true },
} } }
lv.ScanRaidInfoPanel()
check(lv.GetCharacterRaidWeeklyBossState("Delta-Realm", "midnight_s1", "midnight_s1_voidspire", MYTHIC, 2)
    and not lv.GetCharacterRaidWeeklyBossState("Delta-Realm", "midnight_s1", "midnight_s1_voidspire", MYTHIC, 1), "legacy position fallback changed")
savedInstances = {}

-- ------------------------------------------------------ roster and raid grid
SwitchCharacter("Alpha-Realm")
check(lv.GetCurrentRaidProgressionKills("Alpha-Realm", 16) == 0, "roster badge counts Kith'ix while Venomous Abyss is selected")
FlushTimers()
local function FindTab(raidDisplayKey)
    for _, object in ipairs(created) do
        if object._scripts.OnClick and type(object.Text) == "table" and object.Text._text == L[raidDisplayKey] then return object end
    end
end
-- Three rows per boss: Character (Alpha), This Week (Alpha), Warband (all characters).
local function ReadGridCells(bossName)
    local cells, headerShown = {}, false
    for _, object in ipairs(created) do
        if object.bossName == bossName and object.difficultyKey and object._shown then
            local cell = cells[object.difficultyKey] or { total = 0, killed = 0, warbandKillers = {} }
            cells[object.difficultyKey] = cell
            cell.total = cell.total + 1
            if object.isKilled then cell.killed = cell.killed + 1 end
            for _, killer in ipairs(object.killers or {}) do cell.warbandKillers[#cell.warbandKillers + 1] = killer.key end
        end
        if object._text == bossName then headerShown = true end
    end
    return cells, headerShown
end

local kithixTab = FindTab("The Unbinding of Kith'ix")
check(kithixTab ~= nil, "no raid tab button for The Unbinding of Kith'ix")
if kithixTab then
    kithixTab._scripts.OnClick(kithixTab)
    check(lv.GetCurrentRaidBossCount() == 1, "selected raid boss count is not 1")
    check(lv.GetCurrentRaidProgressionKills("Alpha-Realm", 16) == 1, "roster Mythic does not map to flexible Mythic 233")
    check(lv.GetCurrentRaidProgressionKills("Alpha-Realm", 15) == 1, "roster Heroic count is wrong")
    check(lv.GetCurrentRaidProgressionKills("Alpha-Realm", 14) == 0, "roster Normal count is wrong")
    local cells, headerShown = ReadGridCells(L["Kith'ix"])
    check(headerShown, "raid grid did not render the Kith'ix boss header")
    for _, difficulty in ipairs({ LFR, NORMAL, HEROIC, MYTHIC_FLEX }) do
        check(cells[difficulty] and cells[difficulty].total == 3, "raid grid does not render 3 rows for difficulty " .. difficulty)
    end
    check(cells[MYTHIC_FLEX] and cells[MYTHIC_FLEX].killed == 3, "Mythic kill is not shown in Character, This Week and Warband rows")
    check(cells[HEROIC] and cells[HEROIC].killed == 3, "Heroic kill is not shown in Character, This Week and Warband rows")
    check(cells[NORMAL] and cells[NORMAL].killed == 1 and table.concat(cells[NORMAL].warbandKillers, ",") == "Beta-Realm",
        "Normal should be killed only in the Warband row, credited to Beta")
    check(cells[LFR] and cells[LFR].killed == 0, "raid grid shows an unearned LFR kill")
    check(cells[STORY] == nil and cells[MYTHIC] == nil, "raid grid rendered a Story or fixed-Mythic column")
end

local tideboundTab = FindTab("The Tidebound Grotto")
check(tideboundTab ~= nil, "no raid tab button for The Tidebound Grotto")
if tideboundTab then
    tideboundTab._scripts.OnClick(tideboundTab)
    check(lv.GetCurrentRaidProgressionKills("Alpha-Realm", 16) == 1, "roster Mythic does not map to Tidebound flexible Mythic 233")
    local cells, headerShown = ReadGridCells(L["Nymrissa Wavecaller"])
    check(headerShown, "raid grid did not render the Nymrissa Wavecaller header")
    for _, difficulty in ipairs({ WORLD, NORMAL, HEROIC, MYTHIC_FLEX }) do
        check(cells[difficulty] and cells[difficulty].total == 3, "Tidebound grid does not render 3 rows for difficulty " .. difficulty)
    end
    check(cells[MYTHIC_FLEX] and cells[MYTHIC_FLEX].killed == 3, "Tidebound Mythic kill is not shown in all three rows")
    check(cells[WORLD] and cells[WORLD].killed == 3 and table.concat(cells[WORLD].warbandKillers, ",") == "Alpha-Realm,Beta-Realm",
        "Tidebound World kills are not shown, or Warband does not credit Alpha and Beta")
    check(cells[NORMAL] and cells[NORMAL].killed == 0 and cells[HEROIC] and cells[HEROIC].killed == 0, "Tidebound grid shows unearned Normal/Heroic kills")
    check(cells.world == nil and cells[MYTHIC] == nil, "Tidebound grid still renders the placeholder World or fixed-Mythic column")
end

if #failures > 0 then
    for _, message in ipairs(failures) do print("FAIL: " .. message) end
    error(string.format("%d of %d raid tracking checks failed", #failures, checks))
end
print(string.format("Season 2 raid tracking (Kith'ix, Tidebound Grotto, Venomous Abyss): %d checks passed", checks))
