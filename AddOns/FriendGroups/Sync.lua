--[[
    FriendGroups - Settings Profile Serializer (Phase A core)

    Pure-Lua, API-free serialization of the user-facing settings/customisation set
    into a compact, checksummed, copy/paste-safe string. No WoW API surface beyond
    optional refresh hooks in Apply(), so the Serialize/Deserialize pair is fully
    testable outside the client.

    Wire format (pre-encoding):
        P1|t<mask>|h<height>|o<map>|c<map>|n<map>|m<map>
    Final string:
        FG1:<checksum>:<base64(payload)>

    Maps are  key~value;key~value  with ~ ; | \ escaped via backslash.
]]--

local addonName, addonTable = ...

local M = {}
_G.FriendGroups_Sync = M

M.PROTOCOL = "P1"           -- bump only on a breaking wire change (INNER payload format)
M.NICKNAME_MAXLEN = 20      -- characters (codepoints), not bytes

-- LibDeflate (pure Lua, no WoW API) is loaded by the .toc before this file. It powers the
-- FG2 envelope: deflate-compress the payload, then paste-safe print-encode it. Compression
-- is what keeps the string small enough (and the decode fast enough) at the 600-friend x
-- 10-alt ceiling to avoid the client freeze that disconnects the account.
--
-- The reference is captured optionally so this module still loads and unit-tests OUTSIDE the
-- client (a test harness may inject LibDeflate as a global). When absent, Serialize falls back
-- to the legacy uncompressed FG1 envelope, and Deserialize still reads FG1 but reports a
-- localized "library missing" reason for FG2. In-game the library is always present.
local LibDeflate = (_G.LibStub and _G.LibStub("LibDeflate", true)) or _G.LibDeflate

-- Max deflate ratio: smallest paste string and fastest DecompressDeflate on import, at the
-- cost of a slower one-off CompressDeflate on export (the safe, user-initiated side).
local COMPRESS_LEVEL = 9

-- ============================================================================
-- [[ BOOLEAN FIELD LAYOUT ]]
-- APPEND-ONLY. The index is the bit position; reordering corrupts older peers.
-- ============================================================================
local BOOL_FIELDS = {
    "hide_offline", "colour_classes", "show_faction_icons", "show_realm",
    "hide_high_level", "add_favorite_group", "gray_faction", "show_mobile_afk",
    "add_mobile_text", "ingame_only", "ingame_retail", "show_btag",
    "show_retail", "show_search", "hide_empty_groups", "hide_afk",
    "open_one_group", "auto_accept_invite", "auto_accept_sync", "auto_accept_res",
    "auto_release", "offline_tracker", "show_flags", "show_contact_cap",
    "show_guildmates", "show_known_alts",
    -- Appended in 12.1.10. APPEND-ONLY: must stay last so existing backup strings keep
    -- their bit positions (older strings simply lack this bit, decoding as false/Narrow).
    "wide_list",
    -- Appended in 12.2.x. Default-ON display toggles: stored INVERTED (the bit means
    -- "disabled") so older backups that lack these bits decode as enabled -- their
    -- correct default -- instead of being turned off. APPEND-ONLY.
    "show_class_icons", "show_note", "show_status", "eui_skin",
    -- Normal (midway) width flag; pairs with wide_list to encode Narrow/Normal/Wide.
    "width_normal",
    -- Default-ON display toggles, stored inverted (see DEFAULT_ON_INVERTED).
    "show_game_icon", "show_faction_color",
}

-- Allowed values for the one numeric scalar we sync.
local VALID_HEIGHTS = { [0] = true, [190] = true, [380] = true }

-- Default-ON display toggles: stored inverted (the bit means "disabled") so a
-- missing bit in an older backup decodes as enabled (the correct default).
local DEFAULT_ON_INVERTED = {
    show_class_icons = true, show_note = true, show_status = true, eui_skin = true,
    show_game_icon = true, show_faction_color = true,
}

-- show_known_alts is "on unless explicitly false"; DEFAULT_ON_INVERTED keys encode
-- the disabled state; everything else is plain truthy.
local function EffectiveBool(sv, key)
    if key == "show_known_alts" then
        return sv[key] ~= false
    end
    if DEFAULT_ON_INVERTED[key] then
        return sv[key] == false
    end
    return sv[key] and true or false
end

-- ============================================================================
-- [[ LOW-LEVEL HELPERS (pure) ]]
-- ============================================================================

-- Escape the structural characters so names/values can contain anything.
-- ~ ; |  separate fields/entries/key-values;  , ^  separate alt-record fields/records.
local function Esc(s)
    return (tostring(s):gsub("[\\~;|,%^]", "\\%0"))
end

-- Remove one level of backslash escaping.
local function Unesc(s)
    return (s:gsub("\\(.)", "%1"))
end

-- Split on UNescaped separator, preserving backslashes (unescape the leaves later).
local function SplitRaw(s, sep)
    local parts, start, i, n = {}, 1, 1, #s
    while i <= n do
        local ch = s:sub(i, i)
        if ch == "\\" then
            i = i + 2
        elseif ch == sep then
            parts[#parts + 1] = s:sub(start, i - 1)
            start = i + 1
            i = i + 1
        else
            i = i + 1
        end
    end
    parts[#parts + 1] = s:sub(start)
    return parts
end

-- Truncate to maxChars codepoints on a UTF-8 boundary (never split a multibyte char).
local function Utf8Trunc(s, maxChars)
    local i, chars, len = 1, 0, #s
    while i <= len and chars < maxChars do
        local b = s:byte(i)
        local step = (b < 0x80) and 1 or (b < 0xE0) and 2 or (b < 0xF0) and 3 or 4
        i = i + step
        chars = chars + 1
    end
    return s:sub(1, i - 1)
end

-- Neutralise UI escapes / control chars in a free-text label, then length-cap it.
local function SanitizeLabel(s, maxChars)
    s = tostring(s):gsub("|", ""):gsub("%c", "")
    return Utf8Trunc(s, maxChars or M.NICKNAME_MAXLEN)
end

-- A Name-Realm character key: no pipes, no control chars, contains a hyphen.
local function IsValidCharKey(v)
    return type(v) == "string" and #v > 0 and #v <= 64
        and not v:find("|", 1, true) and not v:find("%c") and v:find("-", 1, true) ~= nil
end

-- DJB2-style checksum (paste-integrity only; security is the Phase B HMAC).
local function Checksum(s)
    local h = 5381
    for i = 1, #s do
        h = (h * 33 + s:byte(i)) % 2147483647
    end
    return h
end

-- ============================================================================
-- [[ BASE64 (standard alphabet, byte-safe for UTF-8 payloads) ]]
-- ============================================================================
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function Base64Enc(data)
    return ((data:gsub(".", function(x)
        local r, b = "", x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
        return B64:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

local function Base64Dec(data)
    data = data:gsub("[^" .. "%w%+%/%=" .. "]", "")
    return (data:gsub(".", function(x)
        if x == "=" then return "" end
        local r, f = "", (B64:find(x, 1, true) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then return "" end   -- consume (drop) the sub-byte padding remainder
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

-- ============================================================================
-- [[ MAP ENCODE / DECODE ]]
-- ============================================================================
-- Stable string sort of a table's keys, so identical data always encodes identically
-- (deterministic string + checksum). tostring guards against a stray non-string key.
local function SortedKeys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    return keys
end

local function EncodeMap(map, valEncoder)
    if type(map) ~= "table" then return "" end
    local out = {}
    for _, k in ipairs(SortedKeys(map)) do
        local v = map[k]
        local ev = valEncoder and valEncoder(v) or tostring(v)
        if ev ~= nil and ev ~= false then
            out[#out + 1] = Esc(k) .. "~" .. Esc(ev)
        end
    end
    return table.concat(out, ";")
end

-- decoder(key, value) is called for each entry with already-unescaped strings.
local function DecodeMap(str, decoder)
    if not str or str == "" then return end
    for _, entry in ipairs(SplitRaw(str, ";")) do
        if entry ~= "" then
            local kv = SplitRaw(entry, "~")
            local k = Unesc(kv[1] or "")
            local v = Unesc(kv[2] or "")
            if k ~= "" then decoder(k, v) end
        end
    end
end

-- A set { name = true } encoded as ;-joined escaped names.
local function EncodeSet(set)
    if type(set) ~= "table" then return "" end
    local out = {}
    for _, k in ipairs(SortedKeys(set)) do out[#out + 1] = Esc(tostring(k)) end
    return table.concat(out, ";")
end

-- ============================================================================
-- [[ ALT CACHE ENCODE / DECODE ]]
-- Structure: alt_cache[accountId] = { {record}, ... }. Persistent fields are
-- stored positionally; the lowercase search* fields are derived on decode.
-- Layout:  account ~ rec ^ rec ; account ~ rec ...   (record fields joined by ,)
-- ============================================================================
local ALT_FIELDS = { "key", "charName", "realm", "level", "class", "faction", "zone", "guild", "project", "timestamp" }
local ALT_NUM = { level = true, project = true, timestamp = true }

local function EncodeAltCache(altCache)
    if type(altCache) ~= "table" then return "" end
    local accounts = {}
    for _, accountId in ipairs(SortedKeys(altCache)) do
        local altList = altCache[accountId]
        if type(altList) == "table" then
            local records = {}
            for _, alt in ipairs(altList) do
                if type(alt) == "table" then
                    local fields = {}
                    for i = 1, #ALT_FIELDS do
                        local v = alt[ALT_FIELDS[i]]
                        fields[i] = Esc(v == nil and "" or tostring(v))
                    end
                    records[#records + 1] = table.concat(fields, ",")
                end
            end
            accounts[#accounts + 1] = Esc(accountId) .. "~" .. table.concat(records, "^")
        end
    end
    return table.concat(accounts, ";")
end

local function DecodeAltCache(str, into)
    if not str or str == "" then return end
    for _, accountPart in ipairs(SplitRaw(str, ";")) do
        if accountPart ~= "" then
            local kv = SplitRaw(accountPart, "~")
            local accountId = Unesc(kv[1] or "")
            local recordList = kv[2] or ""
            if accountId ~= "" then
                local list = {}
                for _, recStr in ipairs(SplitRaw(recordList, "^")) do
                    if recStr ~= "" then
                        local f = SplitRaw(recStr, ",")
                        local alt = {}
                        for i = 1, #ALT_FIELDS do
                            local name = ALT_FIELDS[i]
                            local raw = Unesc(f[i] or "")
                            if ALT_NUM[name] then
                                alt[name] = tonumber(raw) or 0
                            else
                                alt[name] = SanitizeLabel(raw, 100)
                            end
                        end
                        -- Rebuild derived lowercase search fields.
                        alt.searchName = (alt.charName or ""):lower()
                        alt.searchRealm = (alt.realm or ""):lower()
                        alt.searchClass = (alt.class or ""):lower()
                        alt.searchZone = (alt.zone or ""):lower()
                        if alt.key and alt.key ~= "" then
                            list[#list + 1] = alt
                        end
                    end
                end
                into[accountId] = list
            end
        end
    end
end

-- ============================================================================
-- [[ SERIALIZE ]]
-- ============================================================================
function M.Serialize(sv, timestamp)
    if type(sv) ~= "table" then return nil end

    -- Pack booleans into one integer (arithmetic; exact for this many bits).
    local mask = 0
    for i = 1, #BOOL_FIELDS do
        if EffectiveBool(sv, BOOL_FIELDS[i]) then
            mask = mask + 2 ^ (i - 1)
        end
    end

    local height = tonumber(sv.extra_height) or 0

    local parts = {
        M.PROTOCOL,
        -- %.0f (not %d): with 32+ bool fields the packed mask exceeds the signed
        -- 32-bit range that %d coerces to (it errors past 2^31). The double is exact
        -- to 2^53 and the decoder reads it back with tonumber + arithmetic bit tests.
        "t" .. string.format("%.0f", mask),
        "h" .. string.format("%d", height),
        -- Raw ranks: they are fractional positions relative to the deterministic
        -- auto-order (identical on every account), so they must NOT be renumbered.
        "o" .. EncodeMap(sv.group_order, function(v)
            return type(v) == "number" and string.format("%.14g", v) or nil
        end),
        "c" .. EncodeMap(sv.banner_colors),
        "n" .. EncodeMap(sv.nicknames, function(v) return SanitizeLabel(v) end),
        "m" .. EncodeMap(sv.manual_mains),
        -- main_guild: the selected main's guild per friend, so the guild group
        -- converges across boxes even where the main isn't locally cached.
        "g" .. EncodeMap(sv.main_guild, function(v) return SanitizeLabel(v, 32) end),
        -- Full comprehensive backup: the observed known-alts database and the
        -- set of guilds the player has belonged to.
        "A" .. EncodeAltCache(sv.alt_cache),
        "k" .. EncodeSet(sv.known_player_guilds),
        -- Creation time of this backup (epoch seconds), shown to the user on restore.
        "D" .. string.format("%d", tonumber(timestamp) or 0),
    }

    local payload = table.concat(parts, "|")
    -- Checksum is over the RAW payload, so paste-integrity verification is identical
    -- regardless of which envelope carries it.
    local chk = string.format("%d", Checksum(payload))

    -- FG2: deflate-compressed, then LibDeflate's copy/paste-safe print encoding.
    if LibDeflate then
        local packed = LibDeflate:CompressDeflate(payload, { level = COMPRESS_LEVEL })
        if packed and packed ~= "" then
            return "FG2:" .. chk .. ":" .. LibDeflate:EncodeForPrint(packed)
        end
    end

    -- FG1 (legacy fallback): uncompressed Base64. Only reached if LibDeflate is unavailable.
    return "FG1:" .. chk .. ":" .. Base64Enc(payload)
end

-- ============================================================================
-- [[ DESERIALIZE ]]
-- Returns a normalised profile table, or nil plus a reason code (not localised;
-- the caller maps the code to a localised L[] message).
-- ============================================================================
function M.Deserialize(str)
    if type(str) ~= "string" then return nil, "FORMAT" end

    -- env 1 = legacy uncompressed Base64 (FG1); env 2 = deflate + print-encode (FG2).
    -- The checksum digits are unambiguous: (%d+) stops at the mandatory ":" separator, so
    -- the print-encoded body may itself contain digits or colons without confusing the parse.
    local env, chk, body = str:match("^FG([12]):(%d+):(.+)$")
    if not env then return nil, "FORMAT" end

    local payload
    if env == "2" then
        if not LibDeflate then return nil, "LIBMISSING" end
        local packed = LibDeflate:DecodeForPrint(body)
        if not packed or packed == "" then return nil, "FORMAT" end
        payload = LibDeflate:DecompressDeflate(packed)
    else
        payload = Base64Dec(body)
    end
    if not payload or payload == "" then return nil, "FORMAT" end
    if string.format("%d", Checksum(payload)) ~= chk then return nil, "CHECKSUM" end

    local fields = SplitRaw(payload, "|")
    if (fields[1] or "") ~= M.PROTOCOL then return nil, "PROTOCOL" end

    local profile = {
        bools = {},
        extra_height = nil,
        group_order = {},
        banner_colors = {},
        nicknames = {},
        manual_mains = {},
        main_guild = {},
        -- nil (not {}) so a backup that predates these fields leaves them untouched
        -- on import, rather than wiping the local alt database.
        alt_cache = nil,
        known_player_guilds = nil,
        timestamp = nil,
    }

    for i = 2, #fields do
        local tag = fields[i]:sub(1, 1)
        local body = fields[i]:sub(2)

        if tag == "t" then
            local mask = tonumber(body) or 0
            for b = 1, #BOOL_FIELDS do
                profile.bools[BOOL_FIELDS[b]] = (math.floor(mask / 2 ^ (b - 1)) % 2) == 1
            end
        elseif tag == "h" then
            local n = tonumber(body)
            if n and VALID_HEIGHTS[n] then profile.extra_height = n end
        elseif tag == "o" then
            DecodeMap(body, function(name, val)
                local r = tonumber(val)
                if r then profile.group_order[name] = r end
            end)
        elseif tag == "c" then
            DecodeMap(body, function(name, val)
                if val:match("^%x%x%x%x%x%x$") then profile.banner_colors[name] = val end
            end)
        elseif tag == "n" then
            DecodeMap(body, function(id, val)
                local clean = SanitizeLabel(val)
                if clean ~= "" then profile.nicknames[id] = clean end
            end)
        elseif tag == "m" then
            DecodeMap(body, function(id, val)
                if IsValidCharKey(val) then profile.manual_mains[id] = val end
            end)
        elseif tag == "g" then
            DecodeMap(body, function(id, val)
                local clean = SanitizeLabel(val, 32)
                if clean ~= "" and clean ~= "NONE" and clean ~= "-" then
                    profile.main_guild[id] = clean
                end
            end)
        elseif tag == "A" then
            profile.alt_cache = profile.alt_cache or {}
            DecodeAltCache(body, profile.alt_cache)
        elseif tag == "k" then
            profile.known_player_guilds = profile.known_player_guilds or {}
            for _, name in ipairs(SplitRaw(body, ";")) do
                local clean = SanitizeLabel(Unesc(name), 32)
                if clean ~= "" then profile.known_player_guilds[clean] = true end
            end
        elseif tag == "D" then
            local n = tonumber(body)
            if n and n > 0 then profile.timestamp = n end
        end
    end

    return profile
end

-- ============================================================================
-- [[ APPLY (mirror the profile into live SavedVars + refresh) ]]
-- Uses WoW globals; guarded so the module still loads/tests outside the client.
-- ============================================================================
function M.Apply(profile)
    local sv = _G.FriendGroups_SavedVars
    if type(sv) ~= "table" or type(profile) ~= "table" then return false end

    for i = 1, #BOOL_FIELDS do
        local key = BOOL_FIELDS[i]
        if DEFAULT_ON_INVERTED[key] then
            sv[key] = not profile.bools[key]   -- bit set == disabled
        else
            sv[key] = profile.bools[key] and true or false
        end
    end

    if profile.extra_height ~= nil then sv.extra_height = profile.extra_height end

    -- Full-mirror: replace the customisation tables wholesale.
    sv.group_order   = profile.group_order   or {}
    sv.banner_colors = profile.banner_colors or {}
    sv.nicknames     = profile.nicknames     or {}
    sv.manual_mains  = profile.manual_mains  or {}
    sv.main_guild    = profile.main_guild    or {}

    -- Only replace the alt database / known guilds when the backup actually carried
    -- them (newer format). Older backups leave the local data intact.
    if profile.alt_cache then sv.alt_cache = profile.alt_cache end
    if profile.known_player_guilds then sv.known_player_guilds = profile.known_player_guilds end

    -- Match the menu's side-effect: alt tracking off clears its derived caches.
    if not sv.show_known_alts and _G.wipe then
        if type(sv.alt_cache) == "table" then _G.wipe(sv.alt_cache) end
        if type(sv.guid_index) == "table" then _G.wipe(sv.guid_index) end
    end

    if _G.FriendGroups_UpdateSize then _G.FriendGroups_UpdateSize() end
    if _G.FriendGroups_UpdateContactCap then _G.FriendGroups_UpdateContactCap() end
    if _G.FriendGroups_RequestFullUpdate then _G.FriendGroups_RequestFullUpdate() end

    return true
end

-- ============================================================================
-- [[ THIN WRAPPERS over live SavedVars ]]
-- ============================================================================
function M.Export()
    local sv = _G.FriendGroups_SavedVars
    local now = (type(_G.time) == "function") and _G.time() or 0
    if type(sv) == "table" then sv.last_export_time = now end
    return M.Serialize(sv, now)
end

-- Returns true (plus the backup's creation timestamp) on success,
-- or false plus a reason code on failure.
function M.Import(str)
    local profile, reason = M.Deserialize(str)
    if not profile then return false, reason end
    return M.Apply(profile), nil, profile.timestamp
end
