--[[
RGX-Framework - Sound Module

One-call level-up sound system with variant playback, default-sound muting,
and settings management — shared across all level-up addons so no addon has
to reimplement it.

Quick start:
local Sound = RGX:GetSound()

local handle = Sound:Register("FFLU", {
    sounds = {
        high   = "Interface\\Addons\\FFLU\\sounds\\final_fantasy_high.ogg",
        medium = "Interface\\Addons\\FFLU\\sounds\\final_fantasy_med.ogg",
        low    = "Interface\\Addons\\FFLU\\sounds\\final_fantasy_low.ogg",
    },
    defaultSoundId = 569593,
    savedVar       = "FFLUSettings",
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

--[[============================================================================
INITIALIZATION
============================================================================]]

function Sound:Init()
    RGX:RegisterModule("sound", self)
    _G.RGXSound = self
end

Sound:Init()
