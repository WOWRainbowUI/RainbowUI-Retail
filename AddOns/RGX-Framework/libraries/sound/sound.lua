--[[
RGX-Framework - Sound Module

One-call level-up sound system with variant playback, default-sound muting,
and settings management — shared across all level-up addons so no addon has
to reimplement it.

Quick start:
local Sound = RGX:GetSound()

local handle = Sound:Register("MyAddon", {
    sounds = {
        high   = "Interface\\Addons\\MyAddon\\sounds\\levelup_high.ogg",
        medium = "Interface\\Addons\\MyAddon\\sounds\\levelup_med.ogg",
        low    = "Interface\\Addons\\MyAddon\\sounds\\levelup_low.ogg",
    },
    defaultSoundId = 569593,
    savedVar       = "MyAddonSettings",
    defaults       = {
        enabled      = true,
        soundVariant = "medium",
        muteDefault  = true,
        showWelcome  = true,
        volume       = "Master",
        firstRun     = true,
    },
    triggerEvent   = "PLAYER_LEVEL_UP",
})

-- After ADDON_LOADED for this addon:
handle:Init()

-- Play the level-up sound (respects enabled + variant settings):
handle:Play()

-- Mute/unmute the default WoW sound:
handle:MuteDefault()
handle:UnmuteDefault()

-- Test sound:
handle:Test()

-- Variant accessors:
handle:GetVariant()      -- "medium"
handle:SetVariant("high") -- prints confirmation

-- Settings accessors (thin wrappers over the SavedVar):
handle:GetSetting("enabled")
handle:SetSetting("enabled", false)

-- Enable/disable (also handles mute/unmute):
handle:Enable()
handle:Disable()

-- Welcome message on PLAYER_LOGIN:
handle:ShowWelcome(prefix, title)

-- Cleanup on PLAYER_LOGOUT:
handle:Logout()
]]

local _, Sound = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX Sound: RGX-Framework not loaded")
    return
end

Sound.name = "sound"
Sound.version = "1.0.0"

Sound._registry = {}

local VALID_CHANNELS = {
    Master = true,
    SFX = true,
    Music = true,
    Ambience = true,
}

local VALID_VARIANTS = {
    high = true,
    medium = true,
    med = true,
    low = true,
}

local function normalizeVariant(v)
    if v == "med" then return "medium" end
    return v
end

--[[============================================================================
HANDLE — per-addon sound controller
============================================================================]]

local Handle = {}
Handle.__index = Handle

function Handle:Init()
    local svName = self._savedVar
    if not svName then return end
    _G[svName] = _G[svName] or {}
    local db = _G[svName]
    if type(self._defaults) == "table" then
        for k, v in pairs(self._defaults) do
            if db[k] == nil then
                db[k] = v
            end
        end
    end
    self:MuteDefault()
end

function Handle:GetSetting(key)
    local db = self._savedVar and _G[self._savedVar]
    if db and db[key] ~= nil then
        return db[key]
    end
    return self._defaults and self._defaults[key]
end

function Handle:SetSetting(key, value)
    local db = self._savedVar and _G[self._savedVar]
    if not db then return false end
    if self._defaults and self._defaults[key] ~= nil then
        if type(value) ~= type(self._defaults[key]) then
            return false
        end
    end
    db[key] = value
    return true
end

function Handle:Play()
    if not self:GetSetting("enabled") then
        return false
    end

    local variant = normalizeVariant(self:GetSetting("soundVariant") or "medium")
    local path = self._sounds and self._sounds[variant]
    if not path then
        return false
    end

    local channel = self:GetSetting("volume") or "Master"
    return PlaySoundFile(path, channel)
end

function Handle:Test()
    return self:Play()
end

function Handle:PlayVariant(variant)
    variant = normalizeVariant(variant or "medium")
    local path = self._sounds and self._sounds[variant]
    if not path then
        return false
    end
    local channel = self:GetSetting("volume") or "Master"
    return PlaySoundFile(path, channel)
end

function Handle:GetVariant()
    return normalizeVariant(self:GetSetting("soundVariant") or "medium")
end

function Handle:SetVariant(variant)
    variant = normalizeVariant(variant)
    if not self._sounds or not self._sounds[variant] then
        return false
    end
    self:SetSetting("soundVariant", variant)
    return true
end

function Handle:GetVolume()
    return self:GetSetting("volume") or "Master"
end

function Handle:SetVolume(channel)
    if not VALID_CHANNELS[channel] then
        return false
    end
    self:SetSetting("volume", channel)
    return true
end

function Handle:MuteDefault()
    if self:GetSetting("enabled") and self:GetSetting("muteDefault") then
        local id = self._defaultSoundId
        if id then
            MuteSoundFile(id)
        end
    end
end

function Handle:UnmuteDefault()
    local id = self._defaultSoundId
    if id then
        UnmuteSoundFile(id)
    end
end

function Handle:Enable()
    self:SetSetting("enabled", true)
    self:MuteDefault()
end

function Handle:Disable()
    self:SetSetting("enabled", false)
    self:UnmuteDefault()
end

function Handle:IsEnabled()
    return self:GetSetting("enabled") == true
end

function Handle:ShowWelcome(prefix, title)
    if not self:GetSetting("showWelcome") then
        return
    end

    local version = self._addonVersion or ""
    local status = self:IsEnabled()
        and (self._locale and self._locale["ENABLED_STATUS"] or "|cff00ff00Enabled|r")
        or (self._locale and self._locale["DISABLED_STATUS"] or "|cffff0000Disabled|r")
    local versionStr = version ~= "" and (" |cff8080ff(v" .. version .. ")|r") or ""

    print(prefix .. " " .. status .. versionStr)

    if self:GetSetting("firstRun") then
        if self._locale and self._locale["COMMUNITY_MESSAGE"] then
            print(prefix .. " " .. self._locale["COMMUNITY_MESSAGE"])
        end
        self:SetSetting("firstRun", false)
    end

    if self._locale and self._locale["TYPE_HELP"] then
        print(prefix .. " " .. self._locale["TYPE_HELP"])
    end
end

function Handle:Logout()
    self:UnmuteDefault()
end

function Handle:SetLocale(localeTable)
    self._locale = localeTable
end

function Handle:GetLocale()
    return self._locale
end

--[[============================================================================
REGISTER — create a new handle
============================================================================]]

--[[
Register(addonName, config) -> Handle

config:
    sounds (table, required) — variant -> sound path mapping
        { high = "path", medium = "path", low = "path" }
    defaultSoundId (number) — WoW sound ID to mute/unmute (default 569593)
    savedVar (string) — SavedVariables global name
    defaults (table) — default settings table
    triggerEvent (string) — event that triggers sound playback (default "PLAYER_LEVEL_UP")
    addonVersion (string) — version string for welcome message
]]
function Sound:Register(addonName, config)
    assert(type(addonName) == "string" and addonName ~= "", "RGXSound:Register requires addonName")
    assert(type(config) == "table", "RGXSound:Register requires config table")
    assert(type(config.sounds) == "table", "RGXSound:Register requires config.sounds")

    if self._registry[addonName] then
        return self._registry[addonName]
    end

    local handle = setmetatable({}, Handle)
    handle._addonName = addonName
    handle._sounds = config.sounds
    handle._defaultSoundId = config.defaultSoundId or 569593
    handle._savedVar = config.savedVar
    handle._defaults = config.defaults
    handle._triggerEvent = config.triggerEvent or "PLAYER_LEVEL_UP"
    handle._addonVersion = config.addonVersion or ""
    handle._locale = nil

    self._registry[addonName] = handle
    return handle
end

function Sound:Get(addonName)
    return self._registry[addonName]
end

function Sound:GetAll()
    return self._registry
end

function Sound:MuteList(ids)
    if type(ids) ~= "table" then return end
    for _, id in ipairs(ids) do
        MuteSoundFile(id)
    end
end

function Sound:UnmuteList(ids)
    if type(ids) ~= "table" then return end
    for _, id in ipairs(ids) do
        UnmuteSoundFile(id)
    end
end

--[[============================================================================
PLAYER SOUND FILES — find a file the player copied in by the name they typed
============================================================================]]

-- WoW plays only files under Interface\AddOns, sees only files that existed when the game started (a /reload does
-- not pick up new ones), and cannot list a folder. The only test for a file is whether it plays, so a probe plays
-- the file muted, stops it at once, and retries unmuted on a client that will not report on a muted file.

Sound.USER_FOLDER = "Interface\\AddOns\\RGX_Sounds\\"
Sound.EXTENSIONS = { "ogg", "mp3", "wav" }
-- The standard sound layout for RGX addons. Inside the addon's own folder:
--   sounds\wow_default\  the game's own sounds the addon ships
--   sounds\game\         sounds from other games (or any further group folder)
--   sounds\user\         shipped empty for the player's own files (an update replaces it)
-- and, beside the addon, Interface\AddOns\<Shared>\ for the player's files that updates never touch.
Sound.LAYOUT = { root = "sounds", wowDefault = "wow_default", game = "game", user = "user" }

--- AddonFolders(addonName[, sharedFolder]) -> { root, wowDefault, game, user, shared }
function Sound:AddonFolders(addonName, sharedFolder)
    if type(addonName) ~= "string" or addonName == "" then return nil end
    local root = "Interface\\AddOns\\" .. addonName .. "\\" .. self.LAYOUT.root .. "\\"
    return {
        root = root,
        wowDefault = root .. self.LAYOUT.wowDefault .. "\\",
        game = root .. self.LAYOUT.game .. "\\",
        user = root .. self.LAYOUT.user .. "\\",
        shared = (type(sharedFolder) == "string" and sharedFolder ~= "") and ("Interface\\AddOns\\" .. sharedFolder .. "\\") or nil,
    }
end

--- UserFolders(addonName[, sharedFolder]) -> the folders a player's own files may be in, most durable first:
--- the shared folder beside the addon (survives updates), then the addon's shipped sounds\user\.
function Sound:UserFolders(addonName, sharedFolder)
    local f = self:AddonFolders(addonName, sharedFolder)
    if not f then return { self.USER_FOLDER } end
    local list = {}
    if f.shared then list[#list + 1] = f.shared end
    list[#list + 1] = f.user
    return list
end

--- LayoutGroup(path) -> addonName, group: which addon and layout folder a sound path is in ("wow_default", "game",
--- "user", another group name, or "shared" for a folder ending in _Sounds beside an addon); nil when it follows no layout.
function Sound:LayoutGroup(path)
    if type(path) ~= "string" then return nil end
    local p = path:gsub("/", "\\")
    local addon, group = p:match("^[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee]\\[Aa][Dd][Dd][Oo][Nn][Ss]\\([^\\]+)\\[Ss][Oo][Uu][Nn][Dd][Ss]\\([^\\]+)\\")
    if addon then return addon, group:lower() end
    local shared = p:match("^[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee]\\[Aa][Dd][Dd][Oo][Nn][Ss]\\([^\\]+_[Ss]ounds)\\")
    if shared then return shared:gsub("_[Ss]ounds$", ""), "shared" end
    return nil
end

-- Subfolders tried inside the designated folder when opts.deep is set and the name is not at its top level.
-- (The folder's own name is tried first too: unzipping often leaves Folder\Folder\file.ogg.)
Sound.SUBFOLDERS = { "sounds", "sound", "media", "media\\sounds", "audio", "sfx", "custom", "user", "user\\sounds" }

local function cleanInput(text)
    if type(text) ~= "string" then return nil end
    text = text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^[\"']+", ""):gsub("[\"']+$", "")
    text = text:gsub("/", "\\"):gsub("\\+", "\\")
    -- A pasted full path (C:\...\World of Warcraft\_forever_\Interface\AddOns\...) keeps only the part the game knows.
    local at = text:lower():find("interface\\addons\\", 1, true)
    if at and at > 1 then text = text:sub(at) end
    text = text:gsub("^\\+", "")
    if text == "" or text:find("%.%.") or text:find(":") then return nil end
    return text
end

local function splitExtension(name)
    local lower = name:lower()
    for _, ext in ipairs(Sound.EXTENSIONS) do
        if lower:sub(-(#ext + 1)) == "." .. ext then return name:sub(1, -(#ext + 2)), name:sub(-#ext) end
    end
    return name, nil
end

local function stop(handle)
    if handle and StopSound then pcall(StopSound, handle) end
end

--- ProbeFile(path) -> boolean: whether the game can play this file. Plays it muted and stops it straight away.
function Sound:ProbeFile(path)
    if type(path) ~= "string" or path == "" then return false end
    local canMute = type(MuteSoundFile) == "function" and type(UnmuteSoundFile) == "function"
    if canMute then pcall(MuteSoundFile, path) end
    local ok, willPlay, handle = pcall(PlaySoundFile, path, "Master")
    stop(handle)
    if canMute then pcall(UnmuteSoundFile, path) end
    if ok and willPlay then return true end
    if not canMute then return false end
    ok, willPlay, handle = pcall(PlaySoundFile, path, "Master")
    stop(handle)
    return (ok and willPlay) and true or false
end

-- File names to try for one typed name, most likely first: as typed, then with spaces, underscores and hyphens
-- interchanged (and dropped), each with the typed extension first; then the other extensions; then a doubled
-- extension (Windows hides extensions, so "boop.ogg" is often really "boop.ogg.ogg").
local function nameCandidates(leaf, extensions)
    local stem, typedExt = splitExtension(leaf)
    local stems, seen = {}, {}
    local function addStem(v) if v ~= "" and not seen[v:lower()] then seen[v:lower()] = true; stems[#stems + 1] = v end end
    addStem(stem)
    if stem:find("[%s_%-]") then
        addStem((stem:gsub("[%s%-]", "_")))
        addStem((stem:gsub("[_%-]", " ")))
        addStem((stem:gsub("[%s_]", "-")))
        addStem((stem:gsub("[%s_%-]+", "")))
    end
    local exts = {}
    if typedExt then exts[1] = typedExt end
    for _, e in ipairs(extensions) do if not typedExt or e:lower() ~= typedExt:lower() then exts[#exts + 1] = e end end
    local names = {}
    for _, st in ipairs(stems) do
        for _, e in ipairs(exts) do names[#names + 1] = st .. "." .. e end
    end
    if typedExt then
        for _, e in ipairs(extensions) do names[#names + 1] = leaf .. "." .. e end
    end
    return names
end

--- ResolveFile(input, opts) -> path | nil, tried
--- input: what the player typed: a full Interface\AddOns path (or a pasted path from the disk), a path from the
---   folder's name or inside a folder, a file name, or a bare name. The extension is optional, and a wrong or
---   doubled one is corrected; spaces, underscores and hyphens are interchangeable; quotes are ignored.
--- opts.folders: folders to search in order (each ending in a backslash); defaults to Sound:UserFolders(opts.addon,
---   opts.shared) when opts.addon is given (the standard layout), else { Sound.USER_FOLDER }.
--- opts.deep: also look one or two levels inside the first folder (Sound.SUBFOLDERS, and the folder's own name).
---   Only reached when nothing matched above, so an exact name costs a single probe.
--- opts.extensions: extensions to try; defaults to ogg, mp3, wav.
--- tried lists every path that was probed, in order, so the addon can tell the player where it looked.
function Sound:ResolveFile(input, opts)
    opts = opts or {}
    local tried, seen = {}, {}
    local text = cleanInput(input)
    if not text then return nil, tried end
    local extensions = opts.extensions or self.EXTENSIONS

    local function probe(path)
        local key = path:lower()
        if seen[key] then return false end
        seen[key] = true
        tried[#tried + 1] = path
        return self:ProbeFile(path)
    end
    local dir, leaf = text:match("^(.*\\)([^\\]+)$")
    if not dir then dir, leaf = "", text end
    local names = nameCandidates(leaf, extensions)
    local function tryIn(prefix)
        for _, name in ipairs(names) do
            local path = prefix .. name
            if probe(path) then return path end
        end
    end

    if text:lower():find("^interface\\addons\\") then
        return tryIn(dir), tried
    end

    local folders = {}
    local defaultFolders = opts.addon and self:UserFolders(opts.addon, opts.shared) or { self.USER_FOLDER }
    for _, folder in ipairs(opts.folders or defaultFolders) do
        if type(folder) == "string" and folder ~= "" then
            folders[#folders + 1] = folder:sub(-1) == "\\" and folder or (folder .. "\\")
        end
    end

    -- "BLU_Sounds\pack\x.ogg": a path that starts at an addon folder's name.
    if dir ~= "" then
        local found = tryIn("Interface\\AddOns\\" .. dir)
        if found then return found, tried end
    end
    for _, folder in ipairs(folders) do
        local found = tryIn(folder .. dir)
        if found then return found, tried end
    end

    if opts.deep and folders[1] then
        local base = folders[1]
        local own = base:match("([^\\]+)\\$")
        local subs = { own }
        for _, sub in ipairs(self.SUBFOLDERS) do subs[#subs + 1] = sub end
        for _, sub in ipairs(subs) do
            local found = tryIn(base .. sub .. "\\" .. dir)
            if found then return found, tried end
        end
    end
    return nil, tried
end

--[[============================================================================
INITIALIZATION
============================================================================]]

function Sound:Init()
    RGX:RegisterModule("sound", self, { category = "library" })
    _G.RGXSound = self
end

Sound:Init()
