-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
-- BliZzi Interrupts — Profile (Import / Export)
-- Serializes BIT.db settings and/or charDb position to a shareable string.

local BIT = BIT
local FORMAT_VERSION = "161"  -- legacy KV+Base64 format (still imported for backwards compat)
local ENCODE_PREFIX  = "!BIT!"

-- Modern serialization layer: LibSerialize + LibDeflate. This is the
-- format Wago and the rest of the Ace3 ecosystem speak. Loaded via
-- LibStub so missing-library scenarios fall back to the legacy
-- Base64+KV pipeline below without breaking import / export.
local LibSerialize = LibStub and LibStub:GetLibrary("LibSerialize", true)
local LibDeflate   = LibStub and LibStub:GetLibrary("LibDeflate", true)

-- Format version for the new payload format. Bumped independently of
-- the legacy `FORMAT_VERSION` so old strings keep their own
-- compatibility ladder while the new format runs on its own.
local NEW_FORMAT_VERSION = 200

-- Safe locale accessor (metatable returns key itself for missing keys, so rawget is needed)
local function LL(key, fallback)
    return rawget(BIT.L, key) or fallback or key
end

------------------------------------------------------------
-- Base64 encode / decode  (pure Lua, no library needed)
------------------------------------------------------------
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64R = {}
for i = 1, #B64 do B64R[B64:sub(i,i)] = i - 1 end

local function Base64Encode(s)
    local out, len = {}, #s
    for i = 1, len, 3 do
        local b1 = s:byte(i)
        local b2 = i+1 <= len and s:byte(i+1) or 0
        local b3 = i+2 <= len and s:byte(i+2) or 0
        local n  = b1 * 65536 + b2 * 256 + b3
        out[#out+1] = B64:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
        out[#out+1] = B64:sub(math.floor(n/4096)%64+1,   math.floor(n/4096)%64+1)
        out[#out+1] = i+1 <= len and B64:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1) or "="
        out[#out+1] = i+2 <= len and B64:sub(n%64+1, n%64+1) or "="
    end
    return table.concat(out)
end

local function Base64Decode(s)
    s = s:gsub("[^A-Za-z0-9+/=]", "")
    local out = {}
    for i = 1, #s, 4 do
        local c1 = B64R[s:sub(i,   i  )] or 0
        local c2 = B64R[s:sub(i+1, i+1)] or 0
        local c3 = B64R[s:sub(i+2, i+2)] or 0
        local c4 = B64R[s:sub(i+3, i+3)] or 0
        local n  = c1*262144 + c2*4096 + c3*64 + c4
        out[#out+1] = string.char(math.floor(n/65536)%256)
        if s:sub(i+2,i+2) ~= "=" then out[#out+1] = string.char(math.floor(n/256)%256) end
        if s:sub(i+3,i+3) ~= "=" then out[#out+1] = string.char(n%256) end
    end
    return table.concat(out)
end

------------------------------------------------------------
-- Version helpers
------------------------------------------------------------
local function GetAddonVersion()
    local v = C_AddOns and C_AddOns.GetAddOnMetadata("BliZzi_Interrupts", "Version")
    return v or "0.0.0"
end

-- Returns major, minor, patch as numbers (e.g. "3.1.0" → 3, 1, 0)
local function ParseVersion(vStr)
    local a, b, c = vStr:match("^(%d+)%.(%d+)%.(%d+)")
    return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

-- true if vA > vB
local function VersionGT(vA, vB)
    local a1,a2,a3 = ParseVersion(vA)
    local b1,b2,b3 = ParseVersion(vB)
    if a1 ~= b1 then return a1 > b1 end
    if a2 ~= b2 then return a2 > b2 end
    return a3 > b3
end

------------------------------------------------------------
-- Serialization helpers
------------------------------------------------------------

-- Keys in BIT.db that are tables and need special handling.
-- Each one needs a dedicated serialize/deserialize pair below — listing
-- a key here only tells the generic export loop "skip me, I'm a table".
local TABLE_KEYS = {
    disabledSpells         = true,  -- set of spell IDs
    rotationOrder          = true,  -- ordered list of player names
    offensiveCDAlertSpells = true,  -- map: spellID → bool (per-spell PI Caller whitelist)
    syncCdDisabled         = true,  -- set of disabled party-CD spell IDs
    customNamesFeatures    = true,  -- set: { INTERRUPTS=true, PARTY_CDS=true, KEYSTONE_LIST=true }
}

-- Categorisation: each user-visible setting belongs to one of the
-- settings pages. The Import / Export UI lets the user pick which
-- categories to include on export (default all). Keys not listed
-- here are always exported (cross-cutting concerns like language).
--
-- 3.8.0: SIZE_FONT and COLORS were merged into INTERRUPTS because
-- their settings now live on the Interrupts page (the legacy Size &
-- Font / Colors top-level pages were removed). Keys originally in
-- those two categories are now routed through INTERRUPTS by the
-- explicit lists below, so a "tick Interrupts in export" still picks
-- up every visual-styling key that used to require ticking three
-- separate boxes. Legacy exports made under the old layout still
-- import cleanly — the import path doesn't consult categories, only
-- raw key=value pairs.
BIT.PROFILE_CATEGORIES = {
    "INTERRUPTS",
    "PARTY_CDS", "SMART_MISDIRECT", "PI_CALLER",
    "KEYSTONE_LIST",
}

local KEY_CATEGORY = {}
local function _cat(name, keys)
    for _, k in ipairs(keys) do KEY_CATEGORY[k] = name end
end

-- Prefix-based category fallback so the profile system stays in sync
-- with module-prefixed DB keys automatically. When a new key isn't
-- listed in KEY_CATEGORY but starts with one of these prefixes, it
-- routes to the matching category without a Profile.lua edit. The
-- explicit category lists below are kept for documentation + so
-- anyone scanning Profile.lua sees the full picture.
--
-- IMPORTANT: list the LONGER prefixes first when one is a prefix of
-- another (e.g. "interruptAttach" before any hypothetical "interrupt"
-- entry) — the matcher returns the first hit.
local KEY_PREFIX_CATEGORY = {
    { prefix = "keystoneList",     cat = "KEYSTONE_LIST"   },
    { prefix = "offensiveCDAlert", cat = "PI_CALLER"       },
    { prefix = "piMacro",          cat = "PI_CALLER"       },
    { prefix = "partyCooldowns",   cat = "PARTY_CDS"       },
    { prefix = "defensiveOverlay", cat = "PARTY_CDS"       },
    { prefix = "smartMd",          cat = "SMART_MISDIRECT" },
    { prefix = "syncCd",           cat = "PARTY_CDS"       },
    { prefix = "interruptAttach",  cat = "INTERRUPTS"      },
    { prefix = "interruptAnchor",  cat = "INTERRUPTS"      },
}

-- Resolve the category for a key: explicit KEY_CATEGORY wins, then
-- the prefix table is consulted as fallback. Returns nil for truly
-- uncategorised keys (treated as "always export" by _includeKey).
local function ResolveCategory(key)
    local cat = KEY_CATEGORY[key]
    if cat then return cat end
    for _, rule in ipairs(KEY_PREFIX_CATEGORY) do
        if key:sub(1, #rule.prefix) == rule.prefix then
            return rule.cat
        end
    end
    return nil
end

_cat("INTERRUPTS", {
    "soloMode", "hideOutOfCombat", "rotationEnabled", "alpha",
    "interruptTooltip", "locked", "growUpward",
    "iconSide", "showIcon", "interruptShowMarker", "barFillMode", "sortMode",
    "interruptAttachPos", "interruptAttachOffsetX", "interruptAttachOffsetY",
    "interruptAttachIconSize", "interruptAttachCounterSize",
    "interruptAttachDesaturateOnCD", "interruptAttachShowOwn", "interruptAttachFrameProvider",
    "interruptFreeAnchor", "interruptFreeAnchorTarget", "interruptFreeAnchorX", "interruptFreeAnchorY",
    "showInDungeon", "showInRaid", "showInOpenWorld", "showInArena", "showInBG",
    "showFailedKick", "showWelcome", "showCustomNames",
    "soundEnabled", "soundKickSuccess", "soundKickFailed", "soundOwnKickOnly",
    "rotationOrder", "disabledSpells",
})

-- Visual styling keys (size, font, bar/border textures, colors).
-- Previously these lived in their own SIZE_FONT and COLORS top-level
-- pages with matching category names. In 3.8.0 the pages were folded
-- into the Interrupts page, so the keys also route through INTERRUPTS
-- for the per-category export filter. Listed in separate _cat blocks
-- (still tagging "INTERRUPTS") only to keep the structural grouping
-- visible at a glance when scanning this file.
_cat("INTERRUPTS", {
    -- Frame / bar geometry
    "frameWidth", "barHeight", "interruptIconSize", "interruptIconGap", "barGap", "frameScale",
    -- Title / name / CD-text positioning + sizing
    "showTitle", "titleFontSize", "titleAlign", "titleOffsetY",
    "showName", "showReady",
    "nameFontSize", "readyFontSize", "nameOffsetX", "nameOffsetY",
    "cdOffsetX", "cdOffsetY",
    -- Font face + outline / shadow
    "fontPath", "fontName",
    "fontOutline", "shadowOffsetX", "shadowOffsetY",
    -- Bar + border textures
    "barTexturePath", "barTextureName",
    "borderTexturePath", "borderTextureName", "borderSize", "borderOffset",
})

_cat("INTERRUPTS", {
    -- Bar colors (used when "Use Class Colors" is off)
    "useClassColors", "cdBarFade",
    "customColorR", "customColorG", "customColorB",
    "cdBarColorR",  "cdBarColorG",  "cdBarColorB",
    "useCustomBgColor",
    "customBgColorR", "customBgColorG", "customBgColorB", "customBgColorA",
    -- Border / title / name / ready colors
    "borderColorR", "borderColorG", "borderColorB", "borderColorA",
    "titleColorR",  "titleColorG",  "titleColorB",
    "nameColorUseClass", "nameColorR", "nameColorG", "nameColorB",
    "readyColorR",  "readyColorG",  "readyColorB",
})

_cat("PARTY_CDS", {
    "showSyncCDs", "syncOnlyInGroup", "showOwnSyncCD",
    "syncCdShowDMG", "syncCdShowDEF", "syncCdCatRowDMG", "syncCdCatRowDEF",
    "syncCdShowInDungeon", "syncCdShowInRaid", "syncCdShowInOpenWorld",
    "syncCdShowInArena", "syncCdShowInBG",
    "syncCdModeGroup", "syncCdModeRaid", "syncCdWindowCompact",
    "syncCdFrameProvider", "syncCdAttachPos", "syncCdBarsLocked",
    "syncCdAttachRowGap", "syncCdAttachOffsetX", "syncCdAttachOffsetY",
    "syncCdAttachMaxPerRow",
    "syncCdTBLayout",
    -- Legacy keys still listed so 3.4.x exports importing into 3.5+
    -- still register under the right page category.
    "syncCdTopLayout", "syncCdBottomLayout",
    "syncCdIconSize", "syncCdIconSpacing",
    "syncCdTooltip", "syncCdGlow", "syncCdCounterSize", "syncCdTimeFormat",
    "syncCdChargeSize", "syncCdChargeAnchor", "syncCdChargeOffX", "syncCdChargeOffY",
    "syncCdDisabled",
})

_cat("SMART_MISDIRECT", {
    "smartMdEnabled", "smartMdTankMethod", "smartMdPrioritizeFocus",
    "smartMdIncludePet", "smartMdAnnounceTarget",
    "smartMdManualName", "smartMdManualRealm",
})

_cat("PI_CALLER", {
    "offensiveCDAlertEnabled", "offensiveCDAlertMode",
    "offensiveCDAlertColorR", "offensiveCDAlertColorG", "offensiveCDAlertColorB",
    "offensiveCDAlertBorderSize",
    "offensiveCDAlertSpells",
    "piMacroEnabled", "piMacroNames",
})

-- Keystone List (Mythic+ keystone group display) — every BIT.db.keystoneList*
-- key lives in this category so import/export and per-spec profile bundles
-- carry the user's position, sizes and visibility/display toggles. Position
-- defaults are nil in DEFAULTS so the loop above can iterate them, but the
-- size sliders + toggles all have defaults set.
_cat("KEYSTONE_LIST", {
    "keystoneListEnabled",
    "keystoneListLocked",
    "keystoneListPosX",
    "keystoneListPosY",
    "keystoneListUseAbbreviation",
    "keystoneListShowNoPort",
    "keystoneListShowResilient",
    "keystoneListShowInParty",
    "keystoneListShowInRaid",
    "keystoneListShowSolo",
    "keystoneListHideInM",
    "keystoneListClickTeleport",
    "keystoneListPortCdAnnounce",
    "keystoneListPortCdMessage",
    "keystoneListQueueGlow",
    "keystoneListPostEnabled",
    "keystoneListPostOwnText",
    "keystoneListPostOtherText",
    "keystoneListGrowUpward",
    "keystoneListMirror",
    "keystoneListScale",
    "keystoneListLevelSize",
    "keystoneListNameSize",
    "keystoneListDungeonSize",
    "keystoneListBorderSize",
    "keystoneListBorderOffset",
    "keystoneListRowGap",
})

-- Returns true when `key` should be included given the per-category filter.
-- Uncategorised keys (e.g. `language`, `minimapButton`) are always included.
-- Category resolution: explicit KEY_CATEGORY → prefix match → uncategorised.
local function _includeKey(key, filter)
    local cat = ResolveCategory(key)
    if not cat then return true end
    return filter[cat] == true
end
-- Keys that are purely internal / should never be exported.
-- Note: media path keys (fontPath / borderTexturePath / barTexturePath) ARE
-- exported now — they get re-resolved by Name on import via the local LSM
-- list, with the imported Path as a fallback when the Name doesn't exist
-- on the importing client. See the post-import reconciliation block below.
local SKIP_KEYS  = { rotationIndex = true,
                     charProfiles = true, globalProfile = true, useGlobalDefault = true,
                     specProfiles = true, roleProfiles = true,
                     useSpecProfile = true, useRoleProfile = true,
                     -- internal version counter for Party CD category-toggle invalidation,
                     -- bumped at runtime — meaningless on import (the import will rebuild anyway)
                     syncCdCatVer = true,
                     -- per-character nickname lives in charDb; global nickname is account-wide
                     myCustomName = true, globalCustomName = true, useGlobalCustomName = true }

local function SerializeValue(v)
    local t = type(v)
    if t == "boolean" then return v and "b1" or "b0"
    elseif t == "number" then return "n" .. tostring(v)
    elseif t == "string" then
        -- escape ; and = so they don't collide with our delimiters
        return "s" .. v:gsub("\\", "\\\\"):gsub(";", "\\;"):gsub("=", "\\=")
    end
    return nil
end

local function DeserializeValue(raw)
    local prefix = raw:sub(1, 1)
    local body   = raw:sub(2)
    if prefix == "b" then return body == "1"
    elseif prefix == "n" then return tonumber(body)
    elseif prefix == "s" then
        return body:gsub("\\=", "="):gsub("\\;", ";"):gsub("\\\\", "\\")
    end
    return nil
end

-- Serialize disabledSpells: "123,456,789"
local function SerializeDisabledSpells(tbl)
    if not tbl then return "" end
    local ids = {}
    for id in pairs(tbl) do ids[#ids+1] = tostring(id) end
    return table.concat(ids, ",")
end

local function DeserializeDisabledSpells(str)
    local t = {}
    if str == "" then return t end
    for id in str:gmatch("[^,]+") do
        local n = tonumber(id)
        if n then t[n] = true end
    end
    return t
end

-- Serialize syncCdDisabled (same shape as disabledSpells: set of spell IDs).
local function SerializeSyncCdDisabled(tbl)
    if not tbl then return "" end
    local ids = {}
    for id in pairs(tbl) do
        local n = tonumber(id)
        if n then ids[#ids+1] = tostring(n) end
    end
    return table.concat(ids, ",")
end

local function DeserializeSyncCdDisabled(str)
    local t = {}
    if str == "" then return t end
    for id in str:gmatch("[^,]+") do
        local n = tonumber(id)
        if n then t[n] = true end
    end
    return t
end

-- Serialize customNamesFeatures: set of feature-key strings the user
-- has selected for custom-name substitution. Stored shape:
--   { INTERRUPTS = true, PARTY_CDS = true, KEYSTONE_LIST = true }
-- Wire format: comma-separated list of the keys that are true.
local function SerializeCustomNamesFeatures(tbl)
    if not tbl then return "" end
    local keys = {}
    for k, v in pairs(tbl) do
        if v == true and type(k) == "string" then
            keys[#keys+1] = k
        end
    end
    table.sort(keys)  -- stable wire-format for diffability
    return table.concat(keys, ",")
end

local function DeserializeCustomNamesFeatures(str)
    local t = {}
    if str == "" then return t end
    for k in str:gmatch("[^,]+") do
        if k ~= "" then t[k] = true end
    end
    return t
end

-- Serialize offensiveCDAlertSpells: "spellID:0|1,spellID:0|1,...".
-- Includes only entries with explicit overrides; defaults are inferred at
-- read time from the OffensiveCDAlert.SPELLS curated list.
local function SerializeOffensiveAlertSpells(tbl)
    if not tbl then return "" end
    local out = {}
    for id, on in pairs(tbl) do
        local n = tonumber(id)
        if n then
            out[#out+1] = tostring(n) .. ":" .. (on and "1" or "0")
        end
    end
    return table.concat(out, ",")
end

local function DeserializeOffensiveAlertSpells(str)
    local t = {}
    if str == "" then return t end
    for pair in str:gmatch("[^,]+") do
        local sid, val = pair:match("^(%-?%d+):([01])$")
        if sid then
            local n = tonumber(sid)
            if n then t[n] = (val == "1") end
        end
    end
    return t
end

-- Serialize rotationOrder: ordered list of player names.
-- "," is the delimiter; commas inside names (rare) are escaped as "\,".
local function SerializeRotationOrder(tbl)
    if not tbl then return "" end
    local out = {}
    for i = 1, #tbl do
        local s = tostring(tbl[i] or "")
        out[#out+1] = s:gsub("\\", "\\\\"):gsub(",", "\\,")
    end
    return table.concat(out, ",")
end

local function DeserializeRotationOrder(str)
    local t = {}
    if str == "" then return t end
    -- Walk the string, respecting "\," and "\\" escapes.
    local cur = ""
    local i = 1
    while i <= #str do
        local c = str:sub(i, i)
        if c == "\\" then
            local nx = str:sub(i+1, i+1)
            if nx == "," then cur = cur .. ","; i = i + 2
            elseif nx == "\\" then cur = cur .. "\\"; i = i + 2
            else cur = cur .. nx; i = i + 2 end
        elseif c == "," then
            t[#t+1] = cur; cur = ""; i = i + 1
        else
            cur = cur .. c; i = i + 1
        end
    end
    if cur ~= "" then t[#t+1] = cur end
    return t
end

------------------------------------------------------------
-- Shared helpers for both formats
------------------------------------------------------------

-- Resolve the user-facing `categories` argument into a filter table.
-- Mirrors the old logic so callers don't have to change.
local function _resolveFilter(categories)
    local filter
    if type(categories) == "table" then
        filter = categories
    elseif categories == false then
        filter = nil
    else
        filter = {}
        for _, c in ipairs(BIT.PROFILE_CATEGORIES or {}) do filter[c] = true end
    end
    local includeSettings = filter ~= nil and next(filter) ~= nil
    return filter, includeSettings
end

-- Build a structured payload table for the modern format. LibSerialize
-- handles nested tables natively, so we hand it real Lua values
-- directly — no string-encoding tricks needed.
local function _buildPayload(filter, includeSettings, includePos, includeBundle)
    local payload = {
        formatVersion = NEW_FORMAT_VERSION,
        addonVersion  = GetAddonVersion(),
    }

    if includeSettings then
        local s = {}
        -- Scalar settings driven off the DEFAULTS list.
        for k in pairs(BIT.DEFAULTS) do
            if not SKIP_KEYS[k] and not TABLE_KEYS[k] and _includeKey(k, filter) then
                local v = BIT.db[k]
                if v ~= nil then s[k] = v end
            end
        end
        -- Table-valued settings: shipped as-is, no custom serializer.
        if _includeKey("disabledSpells", filter) then
            local t = BIT.db.disabledSpells
            if t and next(t) then s.disabledSpells = t end
        end
        if _includeKey("syncCdDisabled", filter) then
            local t = BIT.db.syncCdDisabled
            if t and next(t) then s.syncCdDisabled = t end
        end
        if _includeKey("customNamesFeatures", filter) then
            local t = BIT.db.customNamesFeatures
            if t and next(t) then s.customNamesFeatures = t end
        end
        if _includeKey("offensiveCDAlertSpells", filter) then
            local t = BIT.db.offensiveCDAlertSpells
            if t and next(t) then s.offensiveCDAlertSpells = t end
        end
        if _includeKey("rotationOrder", filter) then
            local t = BIT.db.rotationOrder
            if t and #t > 0 then s.rotationOrder = t end
        end
        -- Media paths whose DEFAULTS value is nil (so the loop above
        -- can't iterate them); emit explicitly.
        for _, k in ipairs({ "fontPath", "borderTexturePath" }) do
            if _includeKey(k, filter) then
                local v = BIT.db[k]
                if type(v) == "string" and v ~= "" then s[k] = v end
            end
        end
        -- Per-profile position keys also default to nil (no saved
        -- position) and are likewise invisible to the DEFAULTS loop.
        -- Without these the active profile's frame placement would not
        -- ride along with single-profile exports.
        for _, k in ipairs({ "posX", "posY", "posXUp", "posYUp" }) do
            local v = BIT.db[k]
            if type(v) == "number" then s[k] = v end
        end
        payload.settings = s

        -- Module / partial-export marker: when the category filter doesn't
        -- span every category, record the included ones in the payload.
        -- Import-side code uses this to tell a module-scoped string apart
        -- from a full profile — the full import resets unshipped keys to
        -- defaults, which would wipe the other modules' settings.
        local all = true
        for _, c in ipairs(BIT.PROFILE_CATEGORIES or {}) do
            if filter[c] ~= true then all = false; break end
        end
        if not all then
            local cats = {}
            for _, c in ipairs(BIT.PROFILE_CATEGORIES or {}) do
                if filter[c] == true then cats[#cats + 1] = c end
            end
            payload.categories = cats
        end
    end

    if includePos then
        -- 3.5.0+: position lives per-profile in BIT.db (was per-char
        -- in BIT.charDb pre-3.5). Read from the active profile so the
        -- shipped position matches what the user sees on screen right
        -- now, not whatever stale value happened to land in charDb.
        payload.position = {
            posX   = BIT.db.posX,
            posY   = BIT.db.posY,
            posXUp = BIT.db.posXUp,
            posYUp = BIT.db.posYUp,
        }
    end

    -- Bundle section: every saved profile + the spec→profile mapping
    -- + the active profile name. Recipients can restore the entire
    -- profile setup in one import — same names, same per-spec
    -- assignments, same active profile. Older importers ignore this
    -- block and fall back to the `settings` snapshot above.
    --
    -- "Default" is intentionally excluded from the profile dump: it's
    -- the un-deletable / un-renamable fallback every install already
    -- has, so re-shipping it would just clobber the importer's own
    -- defaults. Spec-map entries that point at Default ARE kept though,
    -- so the importer's local Default lights up where the exporter
    -- expected it to.
    if includeBundle then
        local sv = BliZziInterruptsSavedVars
        if sv and sv.profiles then
            -- `includeBundle` may be a SET of profile names (partial bundle:
            -- the user picked specific profiles in the export UI). `true`
            -- keeps the classic ship-everything behaviour.
            local wants = (type(includeBundle) == "table") and includeBundle or nil
            local profilesOut = {}
            for name, profileTable in pairs(sv.profiles) do
                -- "Default" is normally excluded (see block comment above),
                -- but an EXPLICIT request via the wants set ships it — the
                -- WagoUI pack API exports profiles by name and must be able
                -- to export a user who only ever used Default. The importer
                -- side renames single-profile bundles anyway.
                if type(name) == "string" and name ~= ""
                   and (name ~= "Default" or (wants and wants["Default"]))
                   and type(profileTable) == "table"
                   and (not wants or wants[name]) then
                    -- Shallow copy so any internal-only keys can be
                    -- filtered without mutating the live profile.
                    local copy = {}
                    for k, v in pairs(profileTable) do
                        if not SKIP_KEYS[k] then copy[k] = v end
                    end
                    profilesOut[name] = copy
                end
            end
            payload.profiles = profilesOut

            if sv.specProfileMap then
                local mapOut = {}
                for specID, profileName in pairs(sv.specProfileMap) do
                    -- Spec IDs are global Blizzard constants, identical
                    -- across players; safe to ship as-is. For partial
                    -- bundles, drop mappings that point at profiles the
                    -- user didn't select (they'd dangle on the importer);
                    -- Default-pointing entries always ride along.
                    if type(specID) == "number" and type(profileName) == "string"
                       and (not wants or wants[profileName] or profileName == "Default") then
                        mapOut[specID] = profileName
                    end
                end
                payload.specProfileMap = mapOut
            end

            -- Don't ship "Default" as the active profile; importers
            -- whose own Default differs would get clobbered. Send the
            -- exporter's active name only when it's a real custom slot
            -- that is actually part of this (possibly partial) bundle.
            if sv.activeProfile and sv.activeProfile ~= "Default"
               and (not wants or wants[sv.activeProfile]) then
                payload.activeProfile = sv.activeProfile
            end
        end
    end

    return payload
end

-- Apply a SETTINGS section onto BIT.db. Resets to defaults first so a
-- partial export reverts un-shipped keys to their default value (same
-- contract as the legacy importer).
local function _applyPayloadSettings(settings)
    if type(settings) ~= "table" then return end
    for k, v in pairs(BIT.DEFAULTS) do
        if not SKIP_KEYS[k] then BIT.db[k] = v end
    end
    BIT.db.disabledSpells         = {}
    BIT.db.syncCdDisabled         = {}
    BIT.db.customNamesFeatures    = {}
    BIT.db.offensiveCDAlertSpells = {}
    BIT.db.rotationOrder          = {}

    for k, v in pairs(settings) do
        if not SKIP_KEYS[k] then
            local allowedPath = (k == "fontPath"
                              or k == "borderTexturePath"
                              or k == "barTexturePath")
            local allowedPos  = (k == "posX"   or k == "posY"
                              or k == "posXUp" or k == "posYUp")
            if BIT.DEFAULTS[k] ~= nil or TABLE_KEYS[k] or allowedPath or allowedPos then
                BIT.db[k] = v
            end
        end
    end
end

-- Apply a POSITION section. 3.5.0+ writes to the active profile's
-- BIT.db slots so the imported position lives alongside the rest of
-- that profile's settings (and respects the per-profile contract).
local function _applyPayloadPosition(position)
    if type(position) ~= "table" then return end
    if position.posX   then BIT.db.posX   = position.posX   end
    if position.posY   then BIT.db.posY   = position.posY   end
    if position.posXUp then BIT.db.posXUp = position.posXUp end
    if position.posYUp then BIT.db.posYUp = position.posYUp end
end

-- Common post-import refresh shared by both code paths: reconcile media
-- name → path via LibSharedMedia (so the importer reuses their own
-- locally-installed font / border / texture if the names match), push
-- live values into BIT.Media, re-apply locale, rebuild visuals.
local function _postImport()
    local function reconcileMedia(nameKey, pathKey, getList)
        if not BIT.Media or not getList then return end
        local wantedName = BIT.db[nameKey]
        if not wantedName or wantedName == "" or wantedName == "None" then
            if wantedName == "None" or wantedName == "" then
                BIT.db[pathKey] = nil
            end
            return
        end
        local list = getList(BIT.Media)
        if not list then return end
        for _, e in ipairs(list) do
            if e.name == wantedName and e.path and e.path ~= "" then
                BIT.db[pathKey] = e.path
                return
            end
        end
    end
    reconcileMedia("fontName",          "fontPath",          BIT.Media.GetAvailableFonts)
    reconcileMedia("borderTextureName", "borderTexturePath", BIT.Media.GetAvailableBorders)
    reconcileMedia("barTextureName",    "barTexturePath",    BIT.Media.GetAvailableTextures)

    if BIT.Media then
        BIT.Media.font           = BIT.db.fontPath
        BIT.Media.fontName       = BIT.db.fontName
        BIT.Media.barTexture     = BIT.db.barTexturePath
        BIT.Media.barTextureName = BIT.db.barTextureName
    end

    BIT:ApplyLocale()
    BIT.UI:RebuildBars()
    if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
    -- Keystone List: route through SetEnabled with the imported value so
    -- the FULL activation chain runs — network registration, personal
    -- keystone update, broadcasts, request, and (since 3.7.x) frame
    -- scale + position too. OnSettingsChanged alone is not enough here:
    -- it only re-applies position/scale without the network bits, which
    -- caused imported-and-enabled profiles to land in an empty frame
    -- that only became visible after the user opened the settings page.
    if BIT.KeystoneList and BIT.KeystoneList.SetEnabled then
        BIT.KeystoneList:SetEnabled(BIT.db.keystoneListEnabled and true or false)
    end
end

------------------------------------------------------------
-- Export
------------------------------------------------------------
-- Export a profile string.
--
-- `categories` may be:
--   * a table of { CATEGORY_NAME = true, ... } — only keys in those
--     categories (plus uncategorised cross-cutting keys) are exported
--   * `true` (or any truthy non-table)         — include all categories
--   * `false` / `nil`                          — settings section is
--                                                omitted entirely
-- `includePos` mirrors the previous behaviour and is independent of
-- the settings filter.
--
-- Output uses the modern Wago-compatible pipeline:
--     LibSerialize:Serialize -> LibDeflate:CompressDeflate
--                            -> LibDeflate:EncodeForPrint
-- The legacy Base64+KV format below stays around for backwards-
-- compatible *import* of older strings; we don't emit it any more.
local _legacyExportProfile  -- forward declaration

function BIT.ExportProfile(categories, includePos, includeBundle)
    if not LibSerialize or not LibDeflate then
        -- Hard-fall back to the legacy emitter when the libs failed to
        -- load. Functional equivalence — these strings still round-trip
        -- through the legacy import path below.
        return _legacyExportProfile(categories, includePos)
    end

    -- `includeBundle` defaults to true so the standard "Export Profile"
    -- button on the settings UI ships every profile + the spec-to-
    -- profile mapping in one string. Pass `false` explicitly when only
    -- the active profile's flat settings are wanted.
    if includeBundle == nil then includeBundle = true end

    local filter, includeSettings = _resolveFilter(categories)
    local payload    = _buildPayload(filter, includeSettings, includePos, includeBundle)
    local serialized = LibSerialize:Serialize(payload)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded    = LibDeflate:EncodeForPrint(compressed)
    return ENCODE_PREFIX .. encoded
end

-- Export one or more modules' settings as a shareable string (no profile
-- bundle, no position section). Accepts a single category key OR a set
-- table ({ INTERRUPTS = true, PARTY_CDS = true }). The payload carries
-- the `categories` marker so the import side recognises the string as
-- module-scoped and routes it through BIT.ImportModule instead of the
-- full-profile reset. Requires the modern LibSerialize pipeline — the
-- legacy emitter can't carry the marker. Selecting EVERY category is
-- still a module export here? No: the marker is only written for partial
-- filters (see _buildPayload), so an all-category set degrades to a
-- plain single-profile settings string by design.
function BIT.ExportModule(categories)
    if not categories or not LibSerialize or not LibDeflate then return nil end
    local filter
    if type(categories) == "table" then
        if not next(categories) then return nil end
        filter = categories
    else
        filter = { [categories] = true }
    end
    return BIT.ExportProfile(filter, false, false)
end

-- Pure-Lua fallback emitter used only when the libraries are missing
-- (e.g. running on a stripped-down install). The body is what
-- `BIT.ExportProfile` used to be on the legacy code path.
_legacyExportProfile = function(categories, includePos)
    local parts = { "BIT" .. FORMAT_VERSION }

    -- embed the current addon version so importers can check compatibility
    parts[#parts+1] = "v" .. GetAddonVersion()

    -- Resolve the filter table. Backwards-compat: boolean arg means
    -- "all categories on" (true) or "skip settings" (false).
    local filter
    if type(categories) == "table" then
        filter = categories
    elseif categories == false then
        filter = nil
    else
        filter = {}
        for _, c in ipairs(BIT.PROFILE_CATEGORIES or {}) do filter[c] = true end
    end
    local includeSettings = filter ~= nil and next(filter) ~= nil

    -- section flags: S=settings, P=position
    local flags = (includeSettings and "S" or "") .. (includePos and "P" or "")
    parts[#parts+1] = flags

    if includeSettings then
        parts[#parts+1] = "SETTINGS"
        -- Export ALL known scalar settings (not just non-defaults) so the
        -- import is a complete, unambiguous snapshot of the source
        -- character's configuration. The category filter narrows the set
        -- of keys per the Import / Export UI checkboxes.
        for k in pairs(BIT.DEFAULTS) do
            if not SKIP_KEYS[k] and not TABLE_KEYS[k] and _includeKey(k, filter) then
                local v  = BIT.db[k]
                local sv = SerializeValue(v)
                if sv then parts[#parts+1] = k .. "=" .. sv end
            end
        end
        -- Table-valued settings: each has a dedicated serializer above.
        -- Empty tables are skipped to keep the payload small.
        if _includeKey("disabledSpells", filter) then
            local ds = SerializeDisabledSpells(BIT.db.disabledSpells)
            if ds ~= "" then parts[#parts+1] = "disabledSpells=" .. ds end
        end
        if _includeKey("syncCdDisabled", filter) then
            local sd = SerializeSyncCdDisabled(BIT.db.syncCdDisabled)
            if sd ~= "" then parts[#parts+1] = "syncCdDisabled=" .. sd end
        end
        if _includeKey("customNamesFeatures", filter) then
            local cnf = SerializeCustomNamesFeatures(BIT.db.customNamesFeatures)
            if cnf ~= "" then parts[#parts+1] = "customNamesFeatures=" .. cnf end
        end
        if _includeKey("offensiveCDAlertSpells", filter) then
            local oa = SerializeOffensiveAlertSpells(BIT.db.offensiveCDAlertSpells)
            if oa ~= "" then parts[#parts+1] = "offensiveCDAlertSpells=" .. oa end
        end
        if _includeKey("rotationOrder", filter) then
            local ro = SerializeRotationOrder(BIT.db.rotationOrder)
            if ro ~= "" then parts[#parts+1] = "rotationOrder=" .. ro end
        end

        -- Media paths whose default is `nil`. These aren't iterable in
        -- BIT.DEFAULTS (Lua treats `t.k = nil` as deletion), so the
        -- loop above doesn't see them. We emit them explicitly so the
        -- importer can fall back to the source's path if it can't
        -- resolve the texture name locally via LibSharedMedia.
        -- (`barTexturePath` is omitted here because its default is a
        -- non-nil string and the generic loop above already emits it.)
        for _, k in ipairs({ "fontPath", "borderTexturePath" }) do
            if _includeKey(k, filter) then
                local v = BIT.db[k]
                if type(v) == "string" and v ~= "" then
                    local sv = SerializeValue(v)
                    if sv then parts[#parts+1] = k .. "=" .. sv end
                end
            end
        end
    end

    if includePos then
        parts[#parts+1] = "POSITION"
        local function addPos(key, val)
            if val then parts[#parts+1] = key .. "=n" .. tostring(val) end
        end
        addPos("posX",   BIT.charDb.posX)
        addPos("posY",   BIT.charDb.posY)
        addPos("posXUp", BIT.charDb.posXUp)
        addPos("posYUp", BIT.charDb.posYUp)
    end

    local plain = table.concat(parts, ";")
    return ENCODE_PREFIX .. Base64Encode(plain)
end

------------------------------------------------------------
-- Import
------------------------------------------------------------

-- Tries to decode the modern Wago-compatible payload. Returns
-- (true, payload) on success or (false, errorMessage) on any failure
-- so the caller knows whether to fall through to the legacy parser.
local function _tryDecodeNew(rawAfterPrefix)
    if not LibSerialize or not LibDeflate then
        return false, "Modern libs not available."
    end
    local decoded = LibDeflate:DecodeForPrint(rawAfterPrefix)
    if not decoded or decoded == "" then
        return false, "DecodeForPrint failed."
    end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed or decompressed == "" then
        return false, "Decompress failed."
    end
    local ok, payload = LibSerialize:Deserialize(decompressed)
    if not ok or type(payload) ~= "table" then
        return false, "Deserialize failed."
    end
    -- Sanity-check it actually came from us. Anyone running another
    -- LibSerialize export would otherwise overwrite the user's BIT.db
    -- with random garbage.
    if not payload.formatVersion then
        return false, "Not a BIT payload."
    end
    return true, payload
end

-- Bundle import: write every exported profile into BIT.db.profiles by
-- name (overwriting any local profile of the same name), restore the
-- spec→profile map, and switch to the exported active profile.
-- Returns (true, nProfiles, nMappings) on success.
local function _applyBundle(payload)
    local sv = BliZziInterruptsSavedVars
    if not sv then return false, 0, 0 end
    sv.profiles = sv.profiles or {}

    local importedProfiles = 0
    for name, src in pairs(payload.profiles or {}) do
        if type(name) == "string" and name ~= "" and type(src) == "table" then
            -- Reset the destination slot to defaults first, then overlay
            -- only what the export shipped — same contract as the
            -- single-profile importer (un-shipped keys revert).
            local dst = sv.profiles[name] or {}
            for k, v in pairs(BIT.DEFAULTS or {}) do
                if not SKIP_KEYS[k] then dst[k] = v end
            end
            dst.disabledSpells         = {}
            dst.syncCdDisabled         = {}
            dst.customNamesFeatures    = {}
            dst.offensiveCDAlertSpells = {}
            dst.rotationOrder          = {}
            for k, v in pairs(src) do
                if not SKIP_KEYS[k] then
                    local allowedPath = (k == "fontPath"
                                      or k == "borderTexturePath"
                                      or k == "barTexturePath")
                    local allowedPos  = (k == "posX"   or k == "posY"
                                      or k == "posXUp" or k == "posYUp")
                    if BIT.DEFAULTS[k] ~= nil or TABLE_KEYS[k] or allowedPath or allowedPos then
                        dst[k] = v
                    end
                end
            end
            sv.profiles[name] = dst
            importedProfiles = importedProfiles + 1
        end
    end

    -- Replace the spec map wholesale with the exported one. Only keep
    -- entries that point at a profile we actually imported (or that
    -- already existed locally) — orphaned entries are silently dropped.
    local importedMappings = 0
    if payload.specProfileMap then
        sv.specProfileMap = {}
        for specID, profileName in pairs(payload.specProfileMap) do
            if type(specID) == "number"
               and type(profileName) == "string"
               and sv.profiles[profileName] then
                sv.specProfileMap[specID] = profileName
                importedMappings = importedMappings + 1
            end
        end
    end

    -- Switch to the exported active profile if it landed; fall back to
    -- the current one (or Default) if the name doesn't exist post-import.
    local target = payload.activeProfile
    if target and sv.profiles[target] then
        sv.activeProfile = target
        BIT.db = sv.profiles[target]
    elseif not (sv.activeProfile and sv.profiles[sv.activeProfile]) then
        sv.activeProfile = "Default"
        sv.profiles["Default"] = sv.profiles["Default"] or {}
        BIT.db = sv.profiles["Default"]
    end

    return true, importedProfiles, importedMappings
end

local function _importFromPayload(payload, renameTo)
    if payload.addonVersion then
        local curVer = GetAddonVersion()
        if VersionGT(payload.addonVersion, curVer) then
            return false, string.format(
                "This profile was created with v%s but you have v%s. Please update the addon first.",
                payload.addonVersion, curVer)
        end
    end

    -- Bundle path: full multi-profile + spec-map restore. Takes priority
    -- over the legacy single-profile `settings` block (which our own
    -- exports include redundantly so older clients can still partially
    -- consume the string).
    if type(payload.profiles) == "table" and next(payload.profiles) then
        -- Single-profile bundle + a user-chosen name: import the profile
        -- under that name instead of the exporter's (the "export one
        -- profile, import under my own name" flow). Spec assignments and
        -- the active-profile pointer follow the rename. Multi-profile
        -- bundles keep their shipped names — there's no meaningful way
        -- to map ONE typed name onto several profiles.
        if type(renameTo) == "string" and renameTo ~= "" then
            local only, count = nil, 0
            for name in pairs(payload.profiles) do
                count = count + 1
                only = name
            end
            if count == 1 and renameTo ~= only then
                payload.profiles[renameTo] = payload.profiles[only]
                payload.profiles[only] = nil
                if type(payload.specProfileMap) == "table" then
                    for specID, pname in pairs(payload.specProfileMap) do
                        if pname == only then
                            payload.specProfileMap[specID] = renameTo
                        end
                    end
                end
                if payload.activeProfile == only then
                    payload.activeProfile = renameTo
                end
            end
        end
        local ok, nProfiles, nMappings = _applyBundle(payload)
        if not ok then return false, "Bundle import failed." end
        _postImport()
        if BIT.Profiles and BIT.Profiles.NotifyAllChanged then
            BIT.Profiles:NotifyAllChanged()
        end
        return true, string.format(
            "Imported %d profile(s), %d spec assignment(s).",
            nProfiles, nMappings), {
                kind          = "bundle",
                profiles      = nProfiles,
                mappings      = nMappings,
                activeProfile = payload.activeProfile,
            }
    end

    -- Single-profile path: settings + position only.
    if payload.settings then _applyPayloadSettings(payload.settings) end
    if payload.position then _applyPayloadPosition(payload.position) end

    _postImport()
    return true, "Import successful.", { kind = "single" }
end

-- Legacy importer — handles the old `!BIT!` + Base64 + KV-text format
-- that we used to emit. Kept around so older shared strings still
-- import on current builds.
local function _legacyImport(str)
    -- Decode !BIT! encoded strings
    if str:sub(1, #ENCODE_PREFIX) == ENCODE_PREFIX then
        local ok, decoded = pcall(Base64Decode, str:sub(#ENCODE_PREFIX + 1))
        if not ok or not decoded or decoded == "" then
            return false, "Failed to decode string."
        end
        str = decoded
    end

    local parts = {}
    -- split on ; but respect escaped \;
    local current = ""
    local i = 1
    while i <= #str do
        local c = str:sub(i, i)
        if c == "\\" and str:sub(i+1, i+1) == ";" then
            current = current .. ";"
            i = i + 2
        else
            if c == ";" then
                parts[#parts+1] = current
                current = ""
            else
                current = current .. c
            end
            i = i + 1
        end
    end
    if current ~= "" then parts[#parts+1] = current end

    if #parts < 2 then return false, "Invalid format." end

    local header = parts[1]
    -- Accept current version and the previous full-export version (160)
    local ACCEPTED = { ["BIT161"] = true, ["BIT160"] = true }
    if not ACCEPTED[header] then
        return false, "Incompatible version: " .. header
    end

    -- Version check: parts[2] is either "vX.Y.Z" (new) or the flags (old BIT160)
    local flagIdx = 2
    if parts[2] and parts[2]:sub(1,1) == "v" then
        local importVer = parts[2]:sub(2)  -- strip leading "v"
        local curVer    = GetAddonVersion()
        if VersionGT(importVer, curVer) then
            return false, string.format(
                "This profile was created with v%s but you have v%s. Please update the addon first.",
                importVer, curVer)
        end
        flagIdx = 3
    end

    local flags   = parts[flagIdx]
    local section = nil

    for idx = flagIdx + 1, #parts do
        local p = parts[idx]
        if p == "SETTINGS" then
            section = "SETTINGS"
            -- Reset to defaults first so any setting NOT in the string
            -- behaves exactly as it did on the source character (= default value).
            -- Without this, a delta-export could leave stale non-default values
            -- from the importing character intact.
            for k, v in pairs(BIT.DEFAULTS) do
                if not SKIP_KEYS[k] then BIT.db[k] = v end
            end
            -- Reset every table-valued setting to a fresh empty table; the
            -- import body may re-populate them. Without this, an empty
            -- export omits the line and the importer would keep their old
            -- values for those tables.
            BIT.db.disabledSpells         = {}
            BIT.db.syncCdDisabled         = {}
            BIT.db.customNamesFeatures    = {}
            BIT.db.offensiveCDAlertSpells = {}
            BIT.db.rotationOrder          = {}
        elseif p == "POSITION" then
            section = "POSITION"
        else
            local key, raw = p:match("^([^=]+)=(.*)$")
            if key and raw then
                if section == "SETTINGS" then
                    -- Table-valued settings: each has its own deserializer.
                    if key == "disabledSpells" then
                        BIT.db.disabledSpells = DeserializeDisabledSpells(raw)
                    elseif key == "syncCdDisabled" then
                        BIT.db.syncCdDisabled = DeserializeSyncCdDisabled(raw)
                    elseif key == "customNamesFeatures" then
                        BIT.db.customNamesFeatures = DeserializeCustomNamesFeatures(raw)
                    elseif key == "offensiveCDAlertSpells" then
                        BIT.db.offensiveCDAlertSpells = DeserializeOffensiveAlertSpells(raw)
                    elseif key == "rotationOrder" then
                        BIT.db.rotationOrder = DeserializeRotationOrder(raw)
                    elseif not SKIP_KEYS[key] then
                        -- Allow media-path keys whose DEFAULTS value is nil
                        -- (so they aren't iterable in DEFAULTS) but which
                        -- we still want to round-trip through the profile.
                        local allowedPath = (key == "fontPath"
                                          or key == "borderTexturePath"
                                          or key == "barTexturePath")
                        local v = DeserializeValue(raw)
                        if v ~= nil and (BIT.DEFAULTS[key] ~= nil or allowedPath) then
                            BIT.db[key] = v
                        end
                    end
                elseif section == "POSITION" then
                    local v = DeserializeValue(raw)
                    if v then BIT.charDb[key] = v end
                end
            end
        end
    end

    _postImport()
    return true, "Import successful."
end

-- Public dispatcher. Tries the modern Wago-compatible decoder first
-- (the format we now emit), then transparently falls back to the
-- legacy KV+Base64 parser so old strings keep working forever.
-- `renameTo` (optional): when the string is a SINGLE-profile bundle,
-- import that profile under this name instead of the exporter's.
function BIT.ImportProfile(str, renameTo)
    if not str or str == "" then return false, "Empty string." end

    local raw = str
    if str:sub(1, #ENCODE_PREFIX) == ENCODE_PREFIX then
        raw = str:sub(#ENCODE_PREFIX + 1)
    end

    local newOk, newPayload = _tryDecodeNew(raw)
    if newOk then
        -- Module-scoped strings must never run the full-profile import:
        -- it resets every unshipped key to default, wiping the other
        -- modules' settings. The settings-window import detects these
        -- via PeekProfileImport and offers the scoped BIT.ImportModule
        -- flow (with confirmation) instead.
        if type(newPayload) == "table"
           and type(newPayload.categories) == "table"
           and #newPayload.categories > 0 then
            return false, "This is a module export string — import it via the settings window (Profiles page), which applies only that module's settings."
        end
        return _importFromPayload(newPayload, renameTo)
    end

    return _legacyImport(str)
end

-- Peek at an encoded import string and report its shape without
-- mutating any state. Returns:
--   kind  — "bundle" / "single" / "legacy" / nil (undecodable)
--   meta  — table with extra info for bundles ({profiles=N, mappings=N,
--           activeProfile=string}); empty table for other kinds
function BIT.PeekProfileImport(str)
    if not str or str == "" then return nil, {} end
    local raw = str
    if str:sub(1, #ENCODE_PREFIX) == ENCODE_PREFIX then
        raw = str:sub(#ENCODE_PREFIX + 1)
    end
    local ok, payload = _tryDecodeNew(raw)
    if ok and type(payload) == "table" then
        -- Module-scoped export (BIT.ExportModule): carries a categories
        -- marker and only that module's settings. Checked before the
        -- bundle branch — a module string never ships a profiles table.
        if type(payload.categories) == "table" and #payload.categories > 0 then
            return "module", { categories = payload.categories }
        end
        if type(payload.profiles) == "table" and next(payload.profiles) then
            local nP, nM = 0, 0
            local names = {}
            for k in pairs(payload.profiles) do
                nP = nP + 1
                -- Only include keys that look like real names (strings) to
                -- defend against malformed bundles. Sorting alphabetically
                -- below gives a stable display order regardless of how the
                -- profiles were originally inserted into the payload.
                if type(k) == "string" then names[#names + 1] = k end
            end
            table.sort(names)
            if type(payload.specProfileMap) == "table" then
                for _ in pairs(payload.specProfileMap) do nM = nM + 1 end
            end
            return "bundle", {
                profiles      = nP,
                mappings      = nM,
                activeProfile = payload.activeProfile,
                names         = names,
            }
        end
        return "single", {}
    end
    -- Legacy strings start with "BIT" + version after Base64-decoding;
    -- we don't fully decode here (cheaper to let the importer do it),
    -- just report "legacy" so the caller picks the single-profile flow.
    return "legacy", {}
end

-- Public decode for external integrations (UI pack tooling): returns
-- the raw payload table of any modern "!BIT!" string, or nil when the
-- string isn't decodable. Read-only — never mutates any state.
function BIT.DecodeProfileString(str)
    if type(str) ~= "string" or str == "" then return nil end
    local raw = str
    if str:sub(1, #ENCODE_PREFIX) == ENCODE_PREFIX then
        raw = str:sub(#ENCODE_PREFIX + 1)
    end
    local ok, payload = _tryDecodeNew(raw)
    if ok and type(payload) == "table" then return payload end
    return nil
end

-- Import a module-scoped export string produced by BIT.ExportModule.
-- Applies ONLY the declared module's keys onto the ACTIVE profile:
-- that module's keys reset to defaults first (complete-snapshot
-- semantics, same contract as the full import but scoped), everything
-- OUTSIDE the module keeps the user's current values — no global reset.
function BIT.ImportModule(str)
    if not str or str == "" then return false, "Empty string." end
    local raw = str
    if str:sub(1, #ENCODE_PREFIX) == ENCODE_PREFIX then
        raw = str:sub(#ENCODE_PREFIX + 1)
    end
    local ok, payload = _tryDecodeNew(raw)
    if not ok or type(payload) ~= "table" then
        return false, "Not a valid module export string."
    end
    local cats = payload.categories
    if type(cats) ~= "table" or #cats == 0 then
        return false, "Not a module export string (this looks like a full profile)."
    end
    if type(payload.settings) ~= "table" then
        return false, "String contains no settings."
    end
    local catSet = {}
    for _, c in ipairs(cats) do catSet[c] = true end

    -- Media-path keys whose DEFAULTS value is nil (absent from the
    -- defaults table), so the DEFAULTS-presence check below can't
    -- validate them; category-gated like everything else.
    local NIL_DEFAULT_OK = { fontPath = true, borderTexturePath = true, barTexturePath = true }

    -- Reset the module's own keys to defaults so the import is a
    -- complete snapshot of that module (unshipped keys fall back to
    -- default rather than mixing with the previous configuration).
    for k, v in pairs(BIT.DEFAULTS) do
        if not SKIP_KEYS[k] and not TABLE_KEYS[k] then
            local c = ResolveCategory(k)
            if c and catSet[c] then BIT.db[k] = v end
        end
    end
    for k in pairs(TABLE_KEYS) do
        local c = ResolveCategory(k)
        if c and catSet[c] then BIT.db[k] = {} end
    end

    -- Apply shipped keys, restricted to the declared categories. The
    -- interrupt window position keys (nil-DEFAULTS, uncategorised) ride
    -- along only for INTERRUPTS strings — they ARE that window's placement.
    for k, v in pairs(payload.settings) do
        if not SKIP_KEYS[k] then
            local c = ResolveCategory(k)
            local isPos = (k == "posX" or k == "posY" or k == "posXUp" or k == "posYUp")
            if (c and catSet[c]
                and (BIT.DEFAULTS[k] ~= nil or TABLE_KEYS[k] or NIL_DEFAULT_OK[k]))
               or (isPos and catSet.INTERRUPTS and type(v) == "number") then
                BIT.db[k] = v
            end
        end
    end

    _postImport()
    if BIT.Profiles and BIT.Profiles.NotifyAllChanged then
        BIT.Profiles:NotifyAllChanged()
    end
    return true, "Module settings imported (" .. table.concat(cats, ", ") .. ")."
end

------------------------------------------------------------
-- Character Profile helpers
------------------------------------------------------------

-- Saves the current settings + position as a snapshot for this character
function BIT.SaveCharProfile()
    BIT.db.charProfiles = BIT.db.charProfiles or {}
    local snap = {}
    for k in pairs(BIT.DEFAULTS) do
        if BIT.db[k] ~= nil then snap[k] = BIT.db[k] end
    end
    -- fontPath/fontName use nil as DEFAULTS value so pairs() skips them; save explicitly
    if BIT.db.fontPath then snap.fontPath = BIT.db.fontPath end
    if BIT.db.fontName then snap.fontName = BIT.db.fontName end
    -- also snapshot per-character frame positions
    snap._posX   = BIT.charDb.posX
    snap._posY   = BIT.charDb.posY
    snap._posXUp = BIT.charDb.posXUp
    snap._posYUp = BIT.charDb.posYUp
    snap._syncX  = BIT.charDb.syncCdBarsPosX
    snap._syncY  = BIT.charDb.syncCdBarsPosY
    BIT.db.charProfiles[BIT.charKey or "Unknown"] = snap
end

-- Copies settings + position from another character's saved profile
function BIT.CopyCharProfile(sourceKey)
    local profiles = BIT.db.charProfiles
    if not profiles or not profiles[sourceKey] then return false end
    local snap = profiles[sourceKey]
    for k in pairs(BIT.DEFAULTS) do
        if snap[k] ~= nil then BIT.db[k] = snap[k] end
    end
    -- fontPath/fontName saved explicitly since their DEFAULTS are nil
    if snap.fontPath then BIT.db.fontPath = snap.fontPath end
    if snap.fontName then BIT.db.fontName = snap.fontName end
    -- restore positions if saved
    if snap._posX   then BIT.charDb.posX            = snap._posX   end
    if snap._posY   then BIT.charDb.posY            = snap._posY   end
    if snap._posXUp then BIT.charDb.posXUp          = snap._posXUp end
    if snap._posYUp then BIT.charDb.posYUp          = snap._posYUp end
    if snap._syncX  then BIT.charDb.syncCdBarsPosX  = snap._syncX  end
    if snap._syncY  then BIT.charDb.syncCdBarsPosY  = snap._syncY  end
    BIT:ApplyLocale()
    BIT.UI:RebuildBars()
    if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
    if BIT.SyncCD and BIT.SyncCD.ApplyBarsFrameSettings then
        BIT.SyncCD:ApplyBarsFrameSettings()
    end
    -- Save immediately so the new settings persist for this char
    BIT.SaveCharProfile()
    return true
end

-- Saves the current settings + all frame positions as the account-wide global default profile
function BIT.SaveGlobalProfile()
    local snap = {}
    for k in pairs(BIT.DEFAULTS) do
        if BIT.db[k] ~= nil then snap[k] = BIT.db[k] end
    end
    if BIT.db.fontPath then snap.fontPath = BIT.db.fontPath end
    if BIT.db.fontName then snap.fontName = BIT.db.fontName end
    snap._posX        = BIT.charDb.posX
    snap._posY        = BIT.charDb.posY
    snap._posXUp      = BIT.charDb.posXUp
    snap._posYUp      = BIT.charDb.posYUp
    snap._syncX       = BIT.charDb.syncCdBarsPosX
    snap._syncY       = BIT.charDb.syncCdBarsPosY
    snap._syncIconX   = BIT.charDb.syncCdPosX
    snap._syncIconY   = BIT.charDb.syncCdPosY
    BIT.db.globalProfile = snap
end

-- Applies the global default profile (settings + positions) to the current character
function BIT.ApplyGlobalProfile()
    local snap = BIT.db and BIT.db.globalProfile
    if not snap then return false end
    for k in pairs(BIT.DEFAULTS) do
        if snap[k] ~= nil then BIT.db[k] = snap[k] end
    end
    if snap.fontPath then BIT.db.fontPath = snap.fontPath end
    if snap.fontName then BIT.db.fontName = snap.fontName end
    if snap._posX      then BIT.charDb.posX            = snap._posX      end
    if snap._posY      then BIT.charDb.posY            = snap._posY      end
    if snap._posXUp    then BIT.charDb.posXUp          = snap._posXUp    end
    if snap._posYUp    then BIT.charDb.posYUp          = snap._posYUp    end
    if snap._syncX     then BIT.charDb.syncCdBarsPosX  = snap._syncX     end
    if snap._syncY     then BIT.charDb.syncCdBarsPosY  = snap._syncY     end
    if snap._syncIconX then BIT.charDb.syncCdPosX      = snap._syncIconX end
    if snap._syncIconY then BIT.charDb.syncCdPosY      = snap._syncIconY end
    BIT:ApplyLocale()
    if BIT.UI and BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
    if BIT.UI and BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
    if BIT.SyncCD and BIT.SyncCD.ApplyBarsFrameSettings then
        BIT.SyncCD:ApplyBarsFrameSettings()
    end
    BIT.SaveCharProfile()
    return true
end

-- Removes the global default profile
function BIT.ClearGlobalProfile()
    if BIT.db then BIT.db.globalProfile = nil end
end

-- Returns true if a global default profile is saved
function BIT.HasGlobalProfile()
    return BIT.db and BIT.db.globalProfile ~= nil
end

------------------------------------------------------------
-- Spec / Role Profile helpers
------------------------------------------------------------

-- Role tokens used as role-profile keys (match UnitGroupRolesAssigned values).
local VALID_ROLES = { TANK = true, HEALER = true, DAMAGER = true }

-- Build a full settings snapshot from current BIT.db (shared by Save*Profile).
local function BuildSettingsSnapshot()
    local snap = {}
    for k in pairs(BIT.DEFAULTS) do
        if BIT.db[k] ~= nil then snap[k] = BIT.db[k] end
    end
    if BIT.db.fontPath then snap.fontPath = BIT.db.fontPath end
    if BIT.db.fontName then snap.fontName = BIT.db.fontName end
    snap._posX      = BIT.charDb.posX
    snap._posY      = BIT.charDb.posY
    snap._posXUp    = BIT.charDb.posXUp
    snap._posYUp    = BIT.charDb.posYUp
    snap._syncX     = BIT.charDb.syncCdBarsPosX
    snap._syncY     = BIT.charDb.syncCdBarsPosY
    snap._syncIconX = BIT.charDb.syncCdPosX
    snap._syncIconY = BIT.charDb.syncCdPosY
    return snap
end

-- Apply a snapshot to BIT.db + BIT.charDb + refresh UI (shared by Apply*Profile).
local function ApplySettingsSnapshot(snap)
    for k in pairs(BIT.DEFAULTS) do
        if snap[k] ~= nil then BIT.db[k] = snap[k] end
    end
    if snap.fontPath then BIT.db.fontPath = snap.fontPath end
    if snap.fontName then BIT.db.fontName = snap.fontName end
    if snap._posX      then BIT.charDb.posX            = snap._posX      end
    if snap._posY      then BIT.charDb.posY            = snap._posY      end
    if snap._posXUp    then BIT.charDb.posXUp          = snap._posXUp    end
    if snap._posYUp    then BIT.charDb.posYUp          = snap._posYUp    end
    if snap._syncX     then BIT.charDb.syncCdBarsPosX  = snap._syncX     end
    if snap._syncY     then BIT.charDb.syncCdBarsPosY  = snap._syncY     end
    if snap._syncIconX then BIT.charDb.syncCdPosX      = snap._syncIconX end
    if snap._syncIconY then BIT.charDb.syncCdPosY      = snap._syncIconY end
    BIT:ApplyLocale()
    if BIT.UI and BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
    if BIT.UI and BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
    if BIT.SyncCD and BIT.SyncCD.ApplyBarsFrameSettings then
        BIT.SyncCD:ApplyBarsFrameSettings()
    end
end

-- Returns the player's current spec ID (or nil if unavailable).
function BIT.GetCurrentSpecID()
    local idx = GetSpecialization and GetSpecialization()
    if not idx then return nil end
    local sid = GetSpecializationInfo and GetSpecializationInfo(idx)
    return sid
end

-- Returns the player's current role token: "TANK", "HEALER", "DAMAGER", or nil.
-- Prefers the spec's role (stable across group changes) over UnitGroupRolesAssigned.
function BIT.GetCurrentRole()
    local idx = GetSpecialization and GetSpecialization()
    if idx then
        local _, _, _, _, role = GetSpecializationInfo(idx)
        if role and VALID_ROLES[role] then return role end
    end
    local r = UnitGroupRolesAssigned and UnitGroupRolesAssigned("player")
    if r and VALID_ROLES[r] then return r end
    return nil
end

-- Returns the localized spec name for a given specID (for UI labels).
function BIT.GetSpecName(specID)
    if not specID then return "?" end
    local _, name = pcall(function() return select(2, GetSpecializationInfoByID(specID)) end)
    return name or tostring(specID)
end

------------------------------------------------------------
-- Spec Profiles (specID-keyed)
------------------------------------------------------------

function BIT.SaveSpecProfile(specID)
    specID = specID or BIT.GetCurrentSpecID()
    if not specID then return false end
    BIT.db.specProfiles = BIT.db.specProfiles or {}
    BIT.db.specProfiles[specID] = BuildSettingsSnapshot()
    return true
end

function BIT.ApplySpecProfile(specID)
    specID = specID or BIT.GetCurrentSpecID()
    if not specID then return false end
    local snap = BIT.db.specProfiles and BIT.db.specProfiles[specID]
    if not snap then return false end
    ApplySettingsSnapshot(snap)
    BIT.SaveCharProfile()
    return true
end

function BIT.DeleteSpecProfile(specID)
    if not specID or not BIT.db.specProfiles then return false end
    if BIT.db.specProfiles[specID] == nil then return false end
    BIT.db.specProfiles[specID] = nil
    return true
end

function BIT.HasSpecProfile(specID)
    specID = specID or BIT.GetCurrentSpecID()
    return specID and BIT.db.specProfiles and BIT.db.specProfiles[specID] ~= nil or false
end

-- Returns an array of saved specIDs (sorted).
function BIT.GetAllSpecProfiles()
    local out = {}
    if BIT.db.specProfiles then
        for sid in pairs(BIT.db.specProfiles) do out[#out+1] = sid end
        table.sort(out)
    end
    return out
end

------------------------------------------------------------
-- Role Profiles (role-keyed: TANK / HEALER / DAMAGER)
------------------------------------------------------------

function BIT.SaveRoleProfile(role)
    role = role or BIT.GetCurrentRole()
    if not (role and VALID_ROLES[role]) then return false end
    BIT.db.roleProfiles = BIT.db.roleProfiles or {}
    BIT.db.roleProfiles[role] = BuildSettingsSnapshot()
    return true
end

function BIT.ApplyRoleProfile(role)
    role = role or BIT.GetCurrentRole()
    if not (role and VALID_ROLES[role]) then return false end
    local snap = BIT.db.roleProfiles and BIT.db.roleProfiles[role]
    if not snap then return false end
    ApplySettingsSnapshot(snap)
    BIT.SaveCharProfile()
    return true
end

function BIT.DeleteRoleProfile(role)
    if not (role and VALID_ROLES[role]) then return false end
    if not BIT.db.roleProfiles or BIT.db.roleProfiles[role] == nil then return false end
    BIT.db.roleProfiles[role] = nil
    return true
end

function BIT.HasRoleProfile(role)
    role = role or BIT.GetCurrentRole()
    return role and BIT.db.roleProfiles and BIT.db.roleProfiles[role] ~= nil or false
end

-- Deletes a saved per-character profile by charKey
function BIT.DeleteCharProfile(key)
    if not key or not BIT.db.charProfiles then return false end
    if BIT.db.charProfiles[key] == nil then return false end
    BIT.db.charProfiles[key] = nil
    return true
end

-- Returns a sorted list of charKeys that have saved profiles (excluding current char)
function BIT.GetOtherCharProfiles()
    local list = {}
    local profiles = BIT.db.charProfiles or {}
    for key in pairs(profiles) do
        if key ~= (BIT.charKey or "") then
            list[#list+1] = key
        end
    end
    table.sort(list)
    return list
end

------------------------------------------------------------
-- Confirmation dialog (StaticPopup)
------------------------------------------------------------
StaticPopupDialogs["BIT_CONFIRM_COPY_PROFILE"] = {
    text          = "|cFF00DDDDBliZzi Party Tools|r\n\nCopy profile from |cFFFFD700%s|r?\n|cFFAAAAAA(Settings and position will be overwritten.)|r",
    button1       = "Copy",
    button2       = "Cancel",
    OnAccept      = function(self, data)
        if data and data.key and data.onSuccess then
            local ok = BIT.CopyCharProfile(data.key)
            if ok then data.onSuccess() end
        end
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BIT_CONFIRM_DELETE_PROFILE"] = {
    text          = "|cFF00DDDDBliZzi Party Tools|r\n\nDelete profile |cFFFFD700%s|r?\n|cFFAAAAAA(This cannot be undone.)|r",
    button1       = "Delete",
    button2       = "Cancel",
    OnAccept      = function(self, data)
        if data and data.key then
            local ok = BIT.DeleteCharProfile(data.key)
            if ok and data.onSuccess then data.onSuccess() end
        end
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BIT_CONFIRM_DELETE_GLOBAL"] = {
    text          = "|cFF00DDDDBliZzi Party Tools|r\n\nDelete the global default profile?\n|cFFAAAAAA(This cannot be undone.)|r",
    button1       = "Delete",
    button2       = "Cancel",
    OnAccept      = function(self, data)
        BIT.ClearGlobalProfile()
        if data and data.onSuccess then data.onSuccess() end
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BIT_CONFIRM_DELETE_SPEC_PROFILE"] = {
    text          = "|cFF00DDDDBliZzi Party Tools|r\n\nDelete the spec profile for |cFFFFD700%s|r?\n|cFFAAAAAA(This cannot be undone.)|r",
    button1       = "Delete",
    button2       = "Cancel",
    OnAccept      = function(self, data)
        if data and data.specID then
            local ok = BIT.DeleteSpecProfile(data.specID)
            if ok and data.onSuccess then data.onSuccess() end
        end
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BIT_CONFIRM_DELETE_ROLE_PROFILE"] = {
    text          = "|cFF00DDDDBliZzi Party Tools|r\n\nDelete the |cFFFFD700%s|r role profile?\n|cFFAAAAAA(This cannot be undone.)|r",
    button1       = "Delete",
    button2       = "Cancel",
    OnAccept      = function(self, data)
        if data and data.role then
            local ok = BIT.DeleteRoleProfile(data.role)
            if ok and data.onSuccess then data.onSuccess() end
        end
    end,
    timeout       = 0,
    whileDead     = true,
    hideOnEscape  = true,
    preferredIndex = 3,
}

------------------------------------------------------------
-- Panel UI
------------------------------------------------------------
local profilePanel = nil

function BIT.UI:ShowProfilePanel()
    if profilePanel then
        if profilePanel:IsShown() then profilePanel:Hide() else profilePanel:Show() end
        return
    end

    local PW, PH = 400, 588
    profilePanel = CreateFrame("Frame", "BITProfilePanel", UIParent, "BackdropTemplate")
    profilePanel:SetSize(PW, PH)
    profilePanel:SetPoint("CENTER")
    profilePanel:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    profilePanel:SetBackdropColor(0.08, 0.08, 0.08, 0.97)
    profilePanel:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    profilePanel:SetMovable(true)
    profilePanel:EnableMouse(true)
    profilePanel:RegisterForDrag("LeftButton")
    profilePanel:SetScript("OnDragStart", profilePanel.StartMoving)
    profilePanel:SetScript("OnDragStop",  profilePanel.StopMovingOrSizing)
    profilePanel:SetClampedToScreen(true)
    profilePanel:SetFrameStrata("DIALOG")
    profilePanel:SetFrameLevel(200)

    -- Header bg
    local hdrBg = profilePanel:CreateTexture(nil, "BACKGROUND", nil, 1)
    hdrBg:SetColorTexture(0.04, 0.04, 0.04, 1)
    hdrBg:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  1, -1)
    hdrBg:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -1, -1)
    hdrBg:SetHeight(44)

    local hdrLine = profilePanel:CreateTexture(nil, "BORDER")
    hdrLine:SetColorTexture(0, 0.87, 0.87, 0.8)
    hdrLine:SetHeight(1)
    hdrLine:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  1, -44)
    hdrLine:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -1, -44)

    local title = profilePanel:CreateFontString(nil, "OVERLAY")
    title:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    title:SetText("|cFF00DDDD" .. (LL("PROFILE_TITLE", "Profile — Import / Export")) .. "|r")
    title:SetPoint("TOP", profilePanel, "TOP", 0, -16)

    local closeBtn = CreateFrame("Button", nil, profilePanel)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -4, -4)
    local closeLbl = closeBtn:CreateFontString(nil, "OVERLAY")
    closeLbl:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    closeLbl:SetText("|cFFFF4444x|r")
    closeLbl:SetAllPoints()
    closeLbl:SetJustifyH("CENTER")
    closeBtn:SetScript("OnClick", function() profilePanel:Hide() end)

    -- Helper: styled section label
    local function SectionLabel(text, yOff)
        local lbl = profilePanel:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        lbl:SetText("|cFFAAAAAA" .. text .. "|r")
        lbl:SetPoint("TOPLEFT", profilePanel, "TOPLEFT", 12, yOff)
        return lbl
    end

    -- Helper: styled checkbox
    local function MakeCheck(label, yOff, defaultVal)
        local f = CreateFrame("CheckButton", nil, profilePanel, "UICheckButtonTemplate")
        f:SetSize(20, 20)
        f:SetPoint("TOPLEFT", profilePanel, "TOPLEFT", 12, yOff)
        f:SetChecked(defaultVal)
        local lbl = profilePanel:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        lbl:SetText(label)
        lbl:SetPoint("LEFT", f, "RIGHT", 4, 0)
        return f
    end

    -- Helper: styled button (reuse rotation panel style)
    local function MakeBtn(label, w, h, parent)
        local btn = CreateFrame("Button", nil, parent or profilePanel)
        btn:SetSize(w, h)
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.10, 0.06, 0.06, 1)
        btn.bg = bg
        local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        border:SetBackdropBorderColor(0, 0.87, 0.87, 0.8)
        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        lbl:SetText("|cFF00DDDD" .. label .. "|r")
        lbl:SetAllPoints(); lbl:SetJustifyH("CENTER")
        btn:SetScript("OnEnter",    function() bg:SetColorTexture(0.05,0.18,0.18,1); border:SetBackdropBorderColor(0,1,1,1) end)
        btn:SetScript("OnLeave",    function() bg:SetColorTexture(0.10,0.06,0.06,1); border:SetBackdropBorderColor(0,0.87,0.87,0.8) end)
        btn:SetScript("OnMouseDown",function() bg:SetColorTexture(0.02,0.10,0.10,1) end)
        btn:SetScript("OnMouseUp",  function() bg:SetColorTexture(0.05,0.18,0.18,1) end)
        return btn
    end

    -- Helper: styled EditBox
    local function MakeEditBox(yOff, h, readOnly)
        local eb = CreateFrame("EditBox", nil, profilePanel, "BackdropTemplate")
        eb:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  12, yOff)
        eb:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, yOff)
        eb:SetHeight(h)
        eb:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
        eb:SetBackdropColor(0.05, 0.05, 0.05, 1)
        eb:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        eb:SetFontObject(GameFontNormal)
        eb:SetTextColor(0.9, 0.9, 0.9)
        eb:SetTextInsets(6, 6, 4, 4)
        eb:SetAutoFocus(false)
        eb:SetMultiLine(false)
        eb:SetMaxLetters(4096)
        if readOnly then
            eb:SetScript("OnChar", function(self) self:SetText(self._val or "") end)
        end
        eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        return eb
    end

    -- ── CHARACTER PROFILES SECTION ──────────────────────────────────
    SectionLabel(LL("PROFILE_CHARS", "Character Profiles"), -56)

    -- Current character label
    local curLbl = profilePanel:CreateFontString(nil, "OVERLAY")
    curLbl:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
    curLbl:SetText("|cFFAAAAAACurrent: |r|cFFFFD700" .. (BIT.charKey or "?") .. "|r")
    curLbl:SetPoint("TOPLEFT", profilePanel, "TOPLEFT", 12, -75)

    -- Save Now button
    local saveNowBtn = MakeBtn(LL("PROFILE_BTN_SAVE", "Save Now"), 90, 22)
    saveNowBtn:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -71)
    saveNowBtn:SetScript("OnClick", function()
        BIT.SaveCharProfile()
        curLbl:SetText("|cFFAAAAAACurrent: |r|cFF00FF00" .. (BIT.charKey or "?") .. " ✓|r")
        C_Timer.After(2, function()
            curLbl:SetText("|cFFAAAAAACurrent: |r|cFFFFD700" .. (BIT.charKey or "?") .. "|r")
        end)
    end)

    -- Scroll frame for other character profiles
    local ROW_H    = 24
    local LIST_H   = 120
    local scrollBg = CreateFrame("Frame", nil, profilePanel, "BackdropTemplate")
    scrollBg:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  12,  -100)
    scrollBg:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -100)
    scrollBg:SetHeight(LIST_H)
    scrollBg:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8",
                           edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
    scrollBg:SetBackdropColor(0.05, 0.05, 0.05, 1)
    scrollBg:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

    local sf = CreateFrame("ScrollFrame", nil, scrollBg, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",  scrollBg, "TOPLEFT",  4, -4)
    sf:SetPoint("BOTTOMRIGHT", scrollBg, "BOTTOMRIGHT", -24, 4)

    local sc = CreateFrame("Frame", nil, sf)
    sc:SetWidth(sf:GetWidth())
    sc:SetHeight(LIST_H)
    sf:SetScrollChild(sc)

    local emptyLbl = sc:CreateFontString(nil, "OVERLAY")
    emptyLbl:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
    emptyLbl:SetText("|cFF666666No other character profiles saved yet.|r")
    emptyLbl:SetPoint("TOPLEFT", sc, "TOPLEFT", 4, -6)

    local charRows = {}

    local function RebuildCharList()
        -- hide old rows
        for _, r in ipairs(charRows) do r:Hide() end
        charRows = {}

        local others = BIT.GetOtherCharProfiles()
        emptyLbl:SetShown(#others == 0)

        local rowY = 0
        for _, key in ipairs(others) do
            local row = CreateFrame("Frame", nil, sc, "BackdropTemplate")
            row:SetPoint("TOPLEFT",  sc, "TOPLEFT",  0, -rowY)
            row:SetPoint("TOPRIGHT", sc, "TOPRIGHT", 0, -rowY)
            row:SetHeight(ROW_H)
            row:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8" })
            row:SetBackdropColor(rowY % 2 == 0 and 0.10 or 0.13, 0.10, rowY % 2 == 0 and 0.10 or 0.13, 1)

            local nameLbl = row:CreateFontString(nil, "OVERLAY")
            nameLbl:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
            nameLbl:SetText("|cFFFFFFFF" .. key .. "|r")
            nameLbl:SetPoint("LEFT",  row, "LEFT", 6, 0)
            nameLbl:SetPoint("RIGHT", row, "RIGHT", -70, 0)
            nameLbl:SetWordWrap(false)

            local copyBtn = MakeBtn(LL("PROFILE_BTN_COPY_CHAR", "Copy"), 58, 18, row)
            copyBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
            local capturedKey = key
            copyBtn:SetScript("OnClick", function()
                StaticPopup_Show("BIT_CONFIRM_COPY_PROFILE", capturedKey, nil, {
                    key       = capturedKey,
                    onSuccess = function()
                        curLbl:SetText("|cFFAAAAAACurrent: |r|cFF00FF00Copied from " .. capturedKey .. " ✓|r")
                        C_Timer.After(3, function()
                            curLbl:SetText("|cFFAAAAAACurrent: |r|cFFFFD700" .. (BIT.charKey or "?") .. "|r")
                        end)
                    end,
                })
            end)

            row:Show()
            charRows[#charRows+1] = row
            rowY = rowY + ROW_H
        end
        sc:SetHeight(math.max(LIST_H, rowY))
    end

    RebuildCharList()

    local div1 = profilePanel:CreateTexture(nil, "BORDER")
    div1:SetColorTexture(0.25, 0.25, 0.25, 1)
    div1:SetHeight(1)
    div1:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  12, -228)
    div1:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -228)

    -- ── GLOBAL DEFAULT PROFILE SECTION ──────────────────────────────
    SectionLabel(LL("PROFILE_GLOBAL", "Global Default"), -240)

    local globalStatusLbl = profilePanel:CreateFontString(nil, "OVERLAY")
    globalStatusLbl:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
    globalStatusLbl:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -240)

    local function RefreshGlobalStatus()
        if BIT.HasGlobalProfile() then
            globalStatusLbl:SetText("|cFF00FF00" .. LL("PROFILE_GLOBAL_SAVED", "Saved") .. "|r")
        else
            globalStatusLbl:SetText("|cFF888888" .. LL("PROFILE_GLOBAL_NONE", "Not saved") .. "|r")
        end
    end
    RefreshGlobalStatus()

    local saveGlobalBtn = MakeBtn(LL("PROFILE_BTN_SAVE_GLOBAL", "Save as Global"), 130, 22)
    saveGlobalBtn:SetPoint("TOPLEFT", profilePanel, "TOPLEFT", 12, -260)
    saveGlobalBtn:SetScript("OnClick", function()
        BIT.SaveGlobalProfile()
        RefreshGlobalStatus()
    end)

    local applyGlobalBtn = MakeBtn(LL("PROFILE_BTN_APPLY_GLOBAL", "Apply Global"), 130, 22)
    applyGlobalBtn:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -260)
    applyGlobalBtn:SetScript("OnClick", function()
        if BIT.ApplyGlobalProfile() then
            curLbl:SetText("|cFFAAAAAACurrent: |r|cFF00FF00" .. (BIT.charKey or "?") .. " ✓|r")
            C_Timer.After(3, function()
                curLbl:SetText("|cFFAAAAAACurrent: |r|cFFFFD700" .. (BIT.charKey or "?") .. "|r")
            end)
        end
    end)

    local autoApplyChk = MakeCheck(LL("PROFILE_AUTO_APPLY", "Auto-apply to new characters"), -290, BIT.db.useGlobalDefault)
    autoApplyChk:SetScript("OnClick", function(self)
        BIT.db.useGlobalDefault = self:GetChecked() and true or false
    end)

    local div2 = profilePanel:CreateTexture(nil, "BORDER")
    div2:SetColorTexture(0.25, 0.25, 0.25, 1)
    div2:SetHeight(1)
    div2:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  12, -316)
    div2:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -316)

    -- ── EXPORT SECTION ──────────────────────────────────────────────
    SectionLabel(LL("PROFILE_EXPORT", "Export"), -328)

    local chkSettings = MakeCheck(LL("PROFILE_OPT_SETTINGS", "Settings"), -348,  true)
    local chkPosition = MakeCheck(LL("PROFILE_OPT_POSITION", "Position"), -348, false)
    chkPosition:SetPoint("TOPLEFT", profilePanel, "TOPLEFT", 140, -348)

    local exportBox = MakeEditBox(-374, 28, true)
    exportBox._val = ""

    local exportBtn = MakeBtn(LL("PROFILE_BTN_EXPORT", "Export"), 100, 26)
    exportBtn:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -408)
    exportBtn:SetScript("OnClick", function()
        local s = chkSettings:GetChecked()
        local p = chkPosition:GetChecked()
        if not s and not p then
            print("|cFF00DDDD[BliZzi]|r " .. (LL("PROFILE_ERR_NOTHING", "Select at least one option.")))
            return
        end
        local str = BIT.ExportProfile(s, p)
        exportBox._val = str
        exportBox:SetText(str)
        exportBox:HighlightText()
        exportBox:SetFocus()
    end)

    local div = profilePanel:CreateTexture(nil, "BORDER")
    div:SetColorTexture(0.25, 0.25, 0.25, 1)
    div:SetHeight(1)
    div:SetPoint("TOPLEFT",  profilePanel, "TOPLEFT",  12, -444)
    div:SetPoint("TOPRIGHT", profilePanel, "TOPRIGHT", -12, -444)

    -- ── IMPORT SECTION ──────────────────────────────────────────────
    SectionLabel(LL("PROFILE_IMPORT", "Import"), -456)

    local importBox = MakeEditBox(-476, 28, false)

    local statusLbl = profilePanel:CreateFontString(nil, "OVERLAY")
    statusLbl:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
    statusLbl:SetPoint("BOTTOMLEFT", profilePanel, "BOTTOMLEFT", 12, 44)
    statusLbl:SetText("")

    local importBtn = MakeBtn(LL("PROFILE_BTN_IMPORT", "Import"), 100, 26)
    importBtn:SetPoint("BOTTOMRIGHT", profilePanel, "BOTTOMRIGHT", -12, 10)
    importBtn:SetScript("OnClick", function()
        local str = importBox:GetText()
        local ok, msg = BIT.ImportProfile(str)
        if ok then
            statusLbl:SetText("|cFF00FF00" .. msg .. "|r")
            importBox:SetText("")
        else
            statusLbl:SetText("|cFFFF4444" .. msg .. "|r")
        end
    end)

    local clearBtn = MakeBtn(LL("PROFILE_BTN_CLEAR", "Clear"), 80, 26)
    clearBtn:SetPoint("BOTTOMRIGHT", importBtn, "BOTTOMLEFT", -6, 0)
    clearBtn:SetScript("OnClick", function()
        importBox:SetText("")
        exportBox:SetText("")
        exportBox._val = ""
        statusLbl:SetText("")
    end)

    profilePanel:Show()
end

------------------------------------------------------------
-- Profile category audit
--
-- Walks BIT.DEFAULTS and reports every key that ResolveCategory() can't
-- assign to a category. Such keys currently bypass the per-category
-- export filter (they're always included) — which is fine for genuinely
-- cross-cutting settings like `language` or `minimapButton`, but a sign
-- of drift if a feature-specific key shows up.
--
-- Runs once at addon load (deferred so SavedVars are populated) and
-- only emits output in devLogMode so end users don't see the noise.
-- Also exposed as `/bitprofileaudit` so any release-time check is one
-- slash-command away.
------------------------------------------------------------
local INTENTIONALLY_UNCATEGORISED = {
    -- Cross-cutting / account-wide settings that the existing design
    -- explicitly wants in EVERY exported bundle, regardless of the
    -- per-category filter the user selects. Listed here so the audit
    -- knows they're expected and doesn't flag them.
    language       = true,
    minimapButton  = true,
    minimapPos     = true,
}

function BIT.AuditProfileCategories(forcePrint)
    local defaults = BIT.DEFAULTS or {}
    local missing  = {}
    for key in pairs(defaults) do
        if not SKIP_KEYS[key]
           and not INTENTIONALLY_UNCATEGORISED[key]
           and not ResolveCategory(key) then
            missing[#missing+1] = key
        end
    end
    table.sort(missing)

    local emit = forcePrint or BIT.devLogMode
    if not emit then return missing end

    if #missing == 0 then
        local msg = "|cff0091edBIT|r |cFF88FFAA[PROFILE-AUDIT]|r OK — every BIT.DEFAULTS key resolves to a category, SKIP_KEYS, or INTENTIONALLY_UNCATEGORISED."
        print(msg)
        if BIT.DevLog then BIT.DevLog("[PROFILE-AUDIT] OK") end
    else
        local msg = "|cff0091edBIT|r |cffff8800[PROFILE-AUDIT]|r "
            .. #missing .. " DEFAULTS key(s) are uncategorised AND not flagged as intentional — they'll always export, even when the user unchecks every category. Fix by adding to KEY_CATEGORY, KEY_PREFIX_CATEGORY, SKIP_KEYS, or INTENTIONALLY_UNCATEGORISED: "
            .. table.concat(missing, ", ")
        print(msg)
        if BIT.DevLog then
            BIT.DevLog("[PROFILE-AUDIT] missing=" .. table.concat(missing, ","))
        end
    end
    return missing
end

-- Slash command for on-demand audit (independent of devLogMode so it's
-- always usable). Force-prints regardless of mode so the dev can quickly
-- verify the state after adding a feature.
SLASH_BITPROFILEAUDIT1 = "/bitprofileaudit"
SlashCmdList["BITPROFILEAUDIT"] = function()
    BIT.AuditProfileCategories(true)
end

-- One-shot audit at addon load, deferred so SavedVars (and therefore
-- BIT.devLogMode) are populated by the time we decide whether to print.
C_Timer.After(3, function()
    BIT.AuditProfileCategories(false)
end)
