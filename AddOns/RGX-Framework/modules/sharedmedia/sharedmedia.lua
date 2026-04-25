--=====================================================================================
-- RGX-Framework | RGXSharedMedia
-- Multi-type media registry with external-addon scanner.
-- Inspired by BLU's rewritten SharedMedia bridge (no LibStub/LibSharedMedia dep).
--
-- Supported media types (extensible):
--   "sound"      - .ogg / .mp3 / .wav files
--   "statusbar"  - texture paths for status bars
--   "font"       - font file paths
--
-- Public API (see bottom of file for summary):
--   SM:Register(mediaType, name, path, opts)
--   SM:RegisterPack(mediaType, packName, entries)
--   SM:RegisterSoundPack(packName, entries)          -- convenience
--   SM:Fetch(mediaType, id)                          -- direct key lookup
--   SM:Find(mediaType, name)                         -- search by display name
--   SM:List(mediaType)                               -- sorted array of all entries
--   SM:ListPacks(mediaType)                          -- sorted array of pack names
--   SM:Scan()                                        -- trigger full re-scan
--   SM:QueueScan(delay)                              -- deduped delayed scan
--=====================================================================================

local addonName, RGX = ...

local SM = {}

-- Per-type storage
-- registry[mediaType][id] = { id, name, path, packName, packId, isBridge }
SM.registry = {}

-- packs[mediaType][packId] = { name = packName, count = N }
SM.packs = {}

-- Dedup: path already seen per type
SM._seenPaths = {}

-- Scanner state
SM._pendingScan  = false
SM._kittyHooked  = false
SM._invokedDBM   = {}

-- ── Constants ─────────────────────────────────────────────────────────────────

local MAX_SOUNDS_PER_SCAN   = 3000
local MAX_TABLES_PER_SOURCE = 1500
local MAX_SCAN_DEPTH        = 8

local IGNORED_GLOBALS = {
    ["_G"] = true, ["RGXFramework"] = true,
    ["math"] = true, ["string"] = true, ["table"] = true,
    ["coroutine"] = true, ["debug"] = true, ["bit"] = true,
    ["bit32"] = true, ["utf8"] = true, ["io"] = true,
    ["os"] = true, ["package"] = true,
}

local KNOWN_ADDON_SOUNDS = {
    ["Prat-3.0"] = {
        packName = "Prat",
        sounds = {
            { name = "Bell",    path = "Interface\\AddOns\\Prat-3.0\\sounds\\Bell.ogg" },
            { name = "Chime",   path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Chime.ogg" },
            { name = "Heart",   path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Heart.ogg" },
            { name = "IM",      path = "Interface\\AddOns\\Prat-3.0\\Sounds\\IM.ogg" },
            { name = "Info",    path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Info.ogg" },
            { name = "Kachink", path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Kachink.ogg" },
            { name = "Popup",   path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Link.ogg" },
            { name = "Text1",   path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Text1.ogg" },
            { name = "Text2",   path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Text2.ogg" },
            { name = "Xylo",    path = "Interface\\AddOns\\Prat-3.0\\Sounds\\Xylo.ogg" },
        },
    },
    ["TradeSkillMaster"] = {
        packName = "TradeSkillMaster",
        sounds = {
            { name = "Cash Register", path = "Interface\\AddOns\\TradeSkillMaster\\Media\\register.mp3" },
        },
    },
}

-- ── Local utilities ───────────────────────────────────────────────────────────

local function SafeUnpack(t)
    return (unpack or table.unpack)(t)
end

local function NormalizePath(path)
    if type(path) ~= "string" then return nil end
    local ok, normalized = pcall(string.gsub, path, "/", "\\")
    return ok and type(normalized) == "string" and normalized or nil
end

local function IsAudioPath(path)
    local p = NormalizePath(path)
    if not p then return false end
    local lower = string.lower(p)
    if not string.find(lower, "interface\\addons\\", 1, true) then return false end
    return string.match(lower, "%.ogg$") or string.match(lower, "%.mp3$") or string.match(lower, "%.wav$")
end

local function ExtractAddonFolder(path)
    local p = NormalizePath(path)
    if not p then return "SharedMedia" end
    local folder = string.match(p, "[Ii]nterface\\[Aa]dd[oO]ns\\([^\\]+)")
    return (folder and folder ~= "") and folder or "SharedMedia"
end

local function FileNameFromPath(path)
    local p = NormalizePath(path) or path
    return string.match(p, "([^\\]+)%.[^%.]+$") or p
end

local function HashString(s)
    local hash = 5381
    for i = 1, #s do
        hash = (hash * 33 + string.byte(s, i)) % 4294967295
    end
    return hash
end

local function IsAddonLoaded(name)
    if type(name) ~= "string" or name == "" then return false end
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, name)
        return ok and loaded == true
    elseif IsAddOnLoaded then
        local ok, loaded = pcall(IsAddOnLoaded, name)
        return ok and loaded == true
    end
    return false
end

local function GetAddonCount()
    if C_AddOns and C_AddOns.GetNumAddOns then return C_AddOns.GetNumAddOns() end
    if GetNumAddOns then return GetNumAddOns() end
    return 0
end

local function GetAddonMetadata(index, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, v = pcall(C_AddOns.GetAddOnMetadata, index, key)
        return ok and v or nil
    elseif GetAddOnMetadata then
        local ok, v = pcall(GetAddOnMetadata, index, key)
        return ok and v or nil
    end
end

local function ShouldIgnoreGlobal(name)
    if type(name) ~= "string" then return true end
    if IGNORED_GLOBALS[name] then return true end
    return string.match(name, "^C_%u")
        or string.match(name, "^Enum")
        or string.match(name, "^LE_")
        or string.match(name, "^SLASH_")
        or string.match(name, "^BINDING_")
        or string.match(name, "^CHAT_")
        or string.match(name, "^ERR_")
        or string.match(name, "^ITEM_")
end

local function IsLikelySoundContainer(name)
    if type(name) ~= "string" or name == "" then return false end
    local lower = string.lower(name)
    return string.find(lower, "sound",  1, true)
        or string.find(lower, "media",  1, true)
        or string.find(lower, "pack",   1, true)
        or string.find(lower, "audio",  1, true)
        or string.find(lower, "voice",  1, true)
        or string.find(lower, "music",  1, true)
        or string.find(lower, "kitty",  1, true)
        or string.find(lower, "dbm",    1, true)
end

local function IsLikelyMediaProvider(name)
    if type(name) ~= "string" or name == "" then return false end
    local lower = string.lower(name)
    return string.find(lower, "sharedmedia", 1, true)
        or string.find(lower, "sound",       1, true)
        or string.find(lower, "audio",       1, true)
        or string.find(lower, "voice",       1, true)
        or string.find(lower, "music",       1, true)
        or string.find(lower, "kitty",       1, true)
        or string.find(lower, "dbm",         1, true)
        or string.find(lower, "media",       1, true)
        or string.find(lower, "pack",        1, true)
end

local function ForEachSafe(tbl, fn)
    if type(tbl) ~= "table" then return end
    local key = nil
    while true do
        local ok, nextKey, nextVal = pcall(next, tbl, key)
        if not ok then return end
        if nextKey == nil then return end
        if fn(nextKey, nextVal) == false then return end
        key = nextKey
    end
end

-- ── Registry core ─────────────────────────────────────────────────────────────

local function EnsureType(self, mediaType)
    if not self.registry[mediaType]  then self.registry[mediaType]  = {} end
    if not self.packs[mediaType]     then self.packs[mediaType]     = {} end
    if not self._seenPaths[mediaType] then self._seenPaths[mediaType] = {} end
end

-- Internal: register a single entry, returns true if newly added
function SM:_Put(mediaType, id, name, path, packId, packName, isBridge)
    EnsureType(self, mediaType)

    local lowerPath = string.lower(path)
    if self._seenPaths[mediaType][lowerPath] then return false end
    self._seenPaths[mediaType][lowerPath] = true

    self.registry[mediaType][id] = {
        id       = id,
        name     = name,
        path     = path,
        packId   = packId,
        packName = packName,
        isBridge = isBridge or false,
    }

    if packId then
        self.packs[mediaType][packId] = self.packs[mediaType][packId]
            or { name = packName or packId, count = 0 }
        self.packs[mediaType][packId].count = self.packs[mediaType][packId].count + 1
    end

    return true
end

-- ── Public registration API ───────────────────────────────────────────────────

-- Register a single media entry.
-- opts: { packName, packId, isBridge }
function SM:Register(mediaType, name, path, opts)
    if type(mediaType) ~= "string" or type(name) ~= "string" or type(path) ~= "string" then
        return false
    end

    opts = opts or {}
    local packId   = opts.packId   or opts.packName or "custom"
    local packName = opts.packName or packId
    local id = string.format("%s:%s", string.lower(packId), string.lower(name))

    return self:_Put(mediaType, id, name, path, packId, packName, opts.isBridge)
end

-- Register a batch of media entries under a named pack.
-- entries can be:
--   { name1 = path1, name2 = path2 }
--   { { name = "Bell", path = "..." }, ... }
--   { path1, path2 }   (auto-named from filename)
function SM:RegisterPack(mediaType, packName, entries)
    if type(mediaType) ~= "string" or type(packName) ~= "string" then return 0 end
    if type(entries) ~= "table" then return 0 end

    local registered = 0
    ForEachSafe(entries, function(key, value)
        local name, path

        if type(value) == "string" then
            -- { name = path } or { [i] = path }
            path = value
            name = type(key) == "string" and key or FileNameFromPath(value)
        elseif type(value) == "table" then
            -- { { name = "...", path = "..." } }
            path = value.path or value.file or value.sound
            name = value.name or (path and FileNameFromPath(path))
        end

        if type(path) == "string" and type(name) == "string" then
            local normalizedPath = NormalizePath(path) or path
            if self:Register(mediaType, name, normalizedPath, { packName = packName }) then
                registered = registered + 1
            end
        end
    end)

    return registered
end

-- Convenience: register a sound pack
function SM:RegisterSoundPack(packName, entries)
    return self:RegisterPack("sound", packName, entries)
end

-- Convenience: register a statusbar texture pack
function SM:RegisterStatusBarPack(packName, entries)
    return self:RegisterPack("statusbar", packName, entries)
end

-- ── Lookup API ────────────────────────────────────────────────────────────────

-- Get entry by generated id (fastest)
function SM:Fetch(mediaType, id)
    local t = self.registry[mediaType]
    return t and t[id]
end

-- Search by display name (O(n) — use for UI pickers, not hot paths)
function SM:Find(mediaType, name)
    local t = self.registry[mediaType]
    if not t then return nil end
    local lower = string.lower(name)
    for _, entry in pairs(t) do
        if string.lower(entry.name) == lower then
            return entry
        end
    end
    return nil
end

-- Returns a sorted array of all entries for a media type
-- Filter: { packId = "..." } to restrict by pack
function SM:List(mediaType, filter)
    local t = self.registry[mediaType]
    if not t then return {} end

    local result = {}
    for _, entry in pairs(t) do
        if not filter or not filter.packId or entry.packId == filter.packId then
            table.insert(result, entry)
        end
    end
    table.sort(result, function(a, b)
        local pa = string.lower(a.packName or "")
        local pb = string.lower(b.packName or "")
        if pa ~= pb then return pa < pb end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return result
end

-- Returns a sorted array of pack descriptors: { id, name, count }
function SM:ListPacks(mediaType)
    local t = self.packs[mediaType]
    if not t then return {} end

    local result = {}
    for packId, packData in pairs(t) do
        table.insert(result, { id = packId, name = packData.name, count = packData.count })
    end
    table.sort(result, function(a, b)
        return string.lower(a.name) < string.lower(b.name)
    end)
    return result
end

-- Returns path string for a media entry, or nil if not found
-- SM:GetPath("sound", "mypack:bell")
function SM:GetPath(mediaType, id)
    local entry = self:Fetch(mediaType, id)
    return entry and entry.path or nil
end

-- ── Sound bridge scanner ──────────────────────────────────────────────────────

-- Register a bridge sound path (auto-detected; not persisted)
function SM:_BridgePath(path, preferredPackName, preferredDisplayName)
    if not IsAudioPath(path) then return false end

    local normalizedPath = NormalizePath(path)
    local lowerPath = string.lower(normalizedPath)

    -- Skip loose user-custom paths (bare Interface\AddOns\file.ogg)
    if string.match(lowerPath, "^interface\\addons\\[^\\]+%.[^\\]+$") then return false end
    if string.match(lowerPath, "^interface\\addons\\sounds\\[^\\]+%.[^\\]+$") then return false end

    local packName = preferredPackName or ExtractAddonFolder(normalizedPath)
    local lowerPack = string.lower(packName)
    if lowerPack == "sharedmedia" or lowerPack == "blizzard" then return false end

    local displayName = preferredDisplayName or FileNameFromPath(normalizedPath)
    local id = string.format("bridge:%s:%08x", string.gsub(lowerPack, "[^%w]", "_"), HashString(lowerPath))

    return self:_Put("sound", id, displayName, normalizedPath, packName, packName, true)
end

-- Collect audio paths from a value recursively
local function CollectAudioPaths(value, found, visited, state, depth)
    if state.total >= MAX_SOUNDS_PER_SCAN then return end

    local vtype = type(value)

    if vtype == "string" then
        if IsAudioPath(value) then
            local p = NormalizePath(value)
            local lp = string.lower(p)
            if not found[lp] then
                found[lp] = p
                state.total = state.total + 1
            end
        end
        return
    end

    if vtype ~= "table" or depth > MAX_SCAN_DEPTH then return end
    if visited[value] then return end
    if state.tables >= MAX_TABLES_PER_SOURCE then return end

    visited[value] = true
    state.tables = state.tables + 1

    ForEachSafe(value, function(k, v)
        if type(k) == "string" and IsAudioPath(k) then
            local p = NormalizePath(k)
            local lp = string.lower(p)
            if not found[lp] then
                found[lp] = p
                state.total = state.total + 1
            end
        end
        CollectAudioPaths(v, found, visited, state, depth + 1)
        if state.total >= MAX_SOUNDS_PER_SCAN then return false end
    end)
end

function SM:_ScanKitty()
    if type(_G.KittyGetSoundPacks) ~= "function" then return 0 end
    local ok, packs = pcall(_G.KittyGetSoundPacks)
    if not ok or type(packs) ~= "table" then return 0 end

    local found = {}
    local state = { total = 0, tables = 0 }
    CollectAudioPaths(packs, found, {}, state, 0)

    local count = 0
    for _, p in pairs(found) do
        if self:_BridgePath(p) then count = count + 1 end
    end
    return count
end

function SM:_HookKitty()
    if self._kittyHooked then return end
    local orig = _G.KittyRegisterSoundPack
    if type(orig) ~= "function" then return end

    self._kittyHooked = true
    _G.KittyRegisterSoundPack = function(name, opts, ...)
        local result = { pcall(orig, name, opts, ...) }
        local ok = table.remove(result, 1)
        if not ok then error(result[1]) end

        if type(opts) == "table" then
            local found = {}
            local state = { total = 0, tables = 0 }
            CollectAudioPaths(opts, found, {}, state, 0)
            for _, p in pairs(found) do self:_BridgePath(p) end
        end

        self:QueueScan(0.05)
        return SafeUnpack(result)
    end
end

function SM:_InvokeDBMRegistrars()
    local dbmKeys = {
        "X-DBM-CountPack-GlobalName",
        "X-DBM-VictoryPack-GlobalName",
        "X-DBM-DefeatPack-GlobalName",
        "X-DBM-MusicPack-GlobalName",
    }
    if type(_G.DBM) ~= "table" then return 0 end

    local count = 0
    for i = 1, GetAddonCount() do
        for _, key in ipairs(dbmKeys) do
            local fn = GetAddonMetadata(i, key)
            if type(fn) == "string" and fn ~= "" and not self._invokedDBM[fn] then
                local globalFn = _G[fn]
                if type(globalFn) == "function" then
                    if pcall(globalFn) then
                        self._invokedDBM[fn] = true
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

function SM:_ScanKnownAddons()
    local count = 0
    for addon, data in pairs(KNOWN_ADDON_SOUNDS) do
        if IsAddonLoaded(addon) and type(data.sounds) == "table" then
            for _, entry in ipairs(data.sounds) do
                if type(entry.path) == "string" then
                    if self:_BridgePath(entry.path, data.packName, entry.name) then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count
end

function SM:_ScanAddonGlobals()
    local found = {}
    local state = { total = 0, tables = 0 }

    -- Scan root tables for loaded addons by name
    if C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetAddOnInfo then
        for i = 1, C_AddOns.GetNumAddOns() do
            local info = C_AddOns.GetAddOnInfo(i)
            local name = type(info) == "table" and info.name or info
            if type(name) == "string" then
                local candidate = _G[name]
                    or _G[string.gsub(name, "%-", "_")]
                    or _G[string.gsub(name, "[^%w_]", "_")]
                if type(candidate) == "table" then
                    state.tables = 0
                    CollectAudioPaths(candidate, found, {}, state, 0)
                    if state.total >= MAX_SOUNDS_PER_SCAN then break end
                end
            end
        end
    elseif GetNumAddOns and GetAddOnInfo then
        for i = 1, GetNumAddOns() do
            local name = GetAddOnInfo(i)
            if type(name) == "string" then
                local candidate = _G[name]
                if type(candidate) == "table" then
                    state.tables = 0
                    CollectAudioPaths(candidate, found, {}, state, 0)
                    if state.total >= MAX_SOUNDS_PER_SCAN then break end
                end
            end
        end
    end

    -- Fallback: scan globals whose names suggest sound/media containers
    if state.total < MAX_SOUNDS_PER_SCAN then
        ForEachSafe(_G, function(globalName, globalValue)
            if not ShouldIgnoreGlobal(globalName)
                and IsLikelySoundContainer(globalName)
                and type(globalValue) == "table" then
                state.tables = 0
                CollectAudioPaths(globalValue, found, {}, state, 0)
                if state.total >= MAX_SOUNDS_PER_SCAN then return false end
            end
        end)
    end

    local count = 0
    for _, p in pairs(found) do
        if self:_BridgePath(p) then count = count + 1 end
    end
    return count
end

-- Wipe all bridge-discovered sounds and re-run all scanners
function SM:Scan()
    -- Remove existing bridge entries for sounds
    local soundReg = self.registry["sound"]
    if soundReg then
        for id, entry in pairs(soundReg) do
            if entry.isBridge then
                soundReg[id] = nil
                if entry.packId and self.packs["sound"] and self.packs["sound"][entry.packId] then
                    self.packs["sound"][entry.packId].count = self.packs["sound"][entry.packId].count - 1
                end
            end
        end
    end
    -- Reset path dedup for sounds so bridge re-registration works
    self._seenPaths["sound"] = self._seenPaths["sound"] or {}
    for lp, _ in pairs(self._seenPaths["sound"]) do
        local entry = soundReg and soundReg["bridge:" .. lp]
        if not entry then
            self._seenPaths["sound"][lp] = nil
        end
    end

    self:_HookKitty()

    local n1 = self:_ScanKitty()
    local n2 = self:_InvokeDBMRegistrars()
    local n3 = self:_ScanKnownAddons()
    local n4 = self:_ScanAddonGlobals()

    RGX:Debug(string.format(
        "[RGXSharedMedia] Scan complete — Kitty:%d DBM:%d Compat:%d Generic:%d",
        n1, n2, n3, n4
    ))
end

function SM:QueueScan(delay)
    if self._pendingScan then return end
    self._pendingScan = true

    local function run()
        self._pendingScan = false
        local ok, err = pcall(function() self:Scan() end)
        if not ok then
            RGX:Debug("[RGXSharedMedia] Scan error: " .. tostring(err))
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(delay or 0, run)
    else
        run()
    end
end

-- ── Event handling ────────────────────────────────────────────────────────────

function SM:OnAddonLoaded(name)
    if IsLikelyMediaProvider(name) then
        self:_HookKitty()
        self:QueueScan(0.25)
    end
end

function SM:OnPlayerLogin()
    self:QueueScan(1.0)
end

-- ── Init ──────────────────────────────────────────────────────────────────────

function SM:Init()
    self:_HookKitty()

    RGX:RegisterEvent("ADDON_LOADED", function(_, name)
        SM:OnAddonLoaded(name)
    end)

    RGX:RegisterEvent("PLAYER_LOGIN", function()
        SM:OnPlayerLogin()
    end)

    self:Scan()
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXSharedMedia = SM
RGX:RegisterModule("sharedmedia", SM)
