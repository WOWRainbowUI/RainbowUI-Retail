--[[
RGX-Framework - Locale Module

Framework-owned localization registry plus the framework's own translated
strings. Ships complete WoW client locale coverage for user-facing output
produced by RGX-Framework itself:

    enUS (base), deDE, esES, esMX, frFR, itIT, koKR, ptBR, ptPT,
    ruRU, zhCN, zhTW

Consumer convention (program issue #19's framework-conventions leg):

    local addonName, addon = ...
    local L = RGXLocale:NewLocale(addonName, "enUS", true)
    L["MY_KEY"] = "Hello"

    local deDE = RGXLocale:NewLocale(addonName, "deDE")
    if deDE then deDE["MY_KEY"] = "Hallo" end

The enUS base must be loaded unconditionally BEFORE any locale-specific
override so untranslated keys always fall through to English. Locale-specific
blocks are guarded by a locale match and return nil when not active, so a
caller can write `if L then ... end` (or simply skip when nil).

This module never changes the frozen consumer SetLocale/GetLocale contract
exposed by modules/sound/sound.lua:249-253 (Handle:SetLocale(localeTable) /
Handle:GetLocale()); consumer addons keep their own per-addon locale tables.

Usage inside the framework:

    local L = RGX:GetLocaleModule().L
    RGX:Print(L["COMMAND_MODULES"], table.concat(mods, ", "))
]]

local _, RGX = ...

local Locale = {}

-- ── Per-addon registry (community-translation API surface) ──────────────────

-- tables[addonName][locale] = table-or-nil  (nil when the locale block was
-- created for a different client locale than the current one and is
-- therefore "guarded off" for this session).
Locale._tables = {}

-- Active client locale, resolved once. _G.GetLocale is provided by the WoW
-- client at runtime; on non-WoW test harnesses we accept an injected value.
local function ActiveLocale()
    if type(_G.GetLocale) == "function" then
        local ok, v = pcall(_G.GetLocale)
        if ok and type(v) == "string" then return v end
    end
    return "enUS"
end
Locale._clientLocale = ActiveLocale()

---Create or fetch a locale table for an addon.
---@param addonName string  Registry bucket; consumers pass their own folder name.
---@param locale string     WoW client locale id ("enUS", "deDE", ...).
---@param isDefault boolean True marks the unconditionally-loaded base table.
---@return table|nil        The locale table, or nil when guarded off
---                          (locale ~= client locale and not the default).
function Locale:NewLocale(addonName, locale, isDefault)
    if type(addonName) ~= "string" or addonName == "" then
        error("RGXLocale:NewLocale: addonName must be a non-empty string", 2)
    end
    if type(locale) ~= "string" or locale == "" then
        error("RGXLocale:NewLocale: locale must be a WoW client locale id", 2)
    end
    self._tables[addonName] = self._tables[addonName] or {}
    local bucket = self._tables[addonName]

    -- Reload idempotency: reuse the existing table for a (addon, locale)
    -- pair so SafeLoad-style re-registration does not wipe translations.
    if bucket[locale] ~= nil then
        return bucket[locale]
    end

    local t
    if isDefault or locale == self._clientLocale then
        t = {}
        -- Chain the override onto the enUS base so missing keys fall back
        -- to English (the base must have been registered first; if it was
        -- not, the override table simply behaves as a flat table).
        if not isDefault then
            local base = bucket["enUS"]
            if base then
                setmetatable(t, { __index = base })
            end
        end
        bucket[locale] = t
        return t
    end

    -- Guarded off: not the active client locale and not a default block.
    bucket[locale] = false
    return nil
end

---Return the registered locale table for this client, or the default.
---@param addonName string
---@return table|nil
function Locale:GetLocaleTable(addonName)
    local bucket = self._tables[addonName]
    if not bucket then return nil end
    local override = bucket[self._clientLocale]
    if override then return override end
    return bucket["enUS"]
end

-- Register the conventional global early so other modules and consumers can
-- reliable discover the API even before strings are populated.
_G.RGXLocale = Locale
RGX:RegisterModule("locale", Locale, { category = "library" })

-- ── Framework-owned enUS base (loaded unconditionally) ──────────────────────

local L = Locale:NewLocale("RGX-Framework", "enUS", true)

-- /rgx command outputs (core/commands.lua)
L["COMMAND_MODULES_HEADER"]       = "Modules:"
L["COMMAND_FONTS_HEADER"]         = "Fonts:"
L["COMMAND_FONTS_AVAILABLE"]      = "available"
L["COMMAND_FONT_DEBUG_ON"]        = "ON"
L["COMMAND_FONT_DEBUG_OFF"]       = "OFF"
L["COMMAND_FONT_DEBUG_PREFIX"]    = "Font debug:"
L["COMMAND_DB_TESTS_MISSING"]     = "DB Tests not loaded."
L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Login messages:"
L["COMMAND_LOGIN_USAGE"]          = "Usage: /rgx login on|off|status"
L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
L["COMMAND_VERSION_UNKNOWN"]      = "unknown"
L["COMMAND_LIST"]                 = "Commands: modules, fonts, debug, dbtest, login, editor, version"

-- Login line (core/initialization.lua)
L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s loaded."

-- UI control fallback labels (modules/ui/controls.lua)
L["UI_COLORPICKER_NOT_LOADED"]    = "RGX ColorPicker not loaded"
L["UI_COLOR_DEFAULT_LABEL"]       = "Color"
L["UI_SLIDER_DEFAULT_LABEL"]      = "Slider"

-- Reputation module (modules/reputation/reputation.lua)
L["REP_RANK_1"]                   = "Hated"
L["REP_RANK_2"]                   = "Hostile"
L["REP_RANK_3"]                   = "Unfriendly"
L["REP_RANK_4"]                   = "Neutral"
L["REP_RANK_5"]                   = "Friendly"
L["REP_RANK_6"]                   = "Honored"
L["REP_RANK_7"]                   = "Revered"
L["REP_RANK_8"]                   = "Exalted"
L["REP_FACTION_FALLBACK_FORMAT"]  = "Faction %d"
L["REP_UNKNOWN"]                  = "Unknown"
L["REP_COVENANT"]                 = "Covenant"

Locale.L = L
