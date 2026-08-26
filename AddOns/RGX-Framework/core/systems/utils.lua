--[[
    RGX-Framework - Utils
--]]

local _, RGX = ...

-- String
function RGX:Trim(str)
    return str:match("^%s*(.-)%s*$")
end

function RGX:Split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

-- Table
function RGX:TableKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    table.sort(keys)
    return keys
end

function RGX:TableValues(tbl)
    local values = {}
    for _, v in pairs(tbl) do table.insert(values, v) end
    return values
end

function RGX:TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

function RGX:TableMap(tbl, fn)
    local result = {}
    for k, v in pairs(tbl) do result[k] = fn(v, k) end
    return result
end

function RGX:TableFilter(tbl, fn)
    local result = {}
    for _, v in ipairs(tbl) do
        if fn(v) then result[#result + 1] = v end
    end
    return result
end

function RGX:TableFind(tbl, fn)
    for _, v in ipairs(tbl) do
        if fn(v) then return v end
    end
    return nil
end

function RGX:MergeTable(dst, src)
  if type(src) ~= "table" then return dst end
  for k, v in pairs(src) do
    if type(v) == "table" then
      if type(dst[k]) ~= "table" then dst[k] = {} end
      self:MergeTable(dst[k], v)
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

-- Math
function RGX:Round(num, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

-- String
function RGX:Format(pattern, ...)
    return string.format(pattern, ...)
end

function RGX:StartsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function RGX:EndsWith(str, suffix)
    return str:sub(-#suffix) == suffix
end

-- Output helpers
RGX.LOGO_TEXTURE = "Interface\\AddOns\\RGX-Framework\\media\\logo.tga"

-- All player-facing framework / consumer output uses one prefix:
--   <logo icon> - [RGX] <message>
function RGX:Print(...)
    print(self:CreateChatPrefix(), ...)
end

function RGX:Warn(...)
    print(self:CreateChatPrefix({ tagColor = "ffcc00" }), ...)
end

function RGX:Error(...)
    print(self:CreateChatPrefix({ tagColor = "ff4444" }), ...)
end

-- Chat
function RGX:CreateChatPrefix(opts)
    opts = opts or {}

    local icon = opts.icon
    if icon == nil then
        icon = RGX.LOGO_TEXTURE
    end
    local tag = opts.tag or "RGX"
    local tagColor = opts.tagColor or "58be81"
    local iconSize = tonumber(opts.iconSize) or 16
    local spacer = opts.spacer

    if spacer == nil then
        spacer = " - "
    end

    local iconMarkup = ""
    if icon ~= "" then
        iconMarkup = string.format("|T%s:%d:%d:0:0|t", icon, iconSize, iconSize)
    end

    return string.format(
        "%s%s|cffffffff[|r|cff%s%s|r|cffffffff]|r",
        iconMarkup,
        spacer,
        tagColor,
        tag
    )
end

-- Login messages (startup lines only) ----------------------------------------
-- Persisted globally in the framework SavedVariables; default ON.
-- These gate ONLY LoginMessage(). Print/Warn/Error always work.

function RGX:IsLoginMessagesEnabled()
    local db = rawget(_G, "RGXFrameworkDB")
    if type(db) == "table" and type(db.showLoginMessages) == "boolean" then
        return db.showLoginMessages
    end
    return true
end

function RGX:SetLoginMessagesEnabled(enabled)
    enabled = (enabled == true)
    local db = rawget(_G, "RGXFrameworkDB")
    if type(db) ~= "table" then
        db = {}
        rawset(_G, "RGXFrameworkDB", db)
    end
    if type(self.db) ~= "table" then
        self.db = db
    end
    db.showLoginMessages = enabled
    return enabled
end

function RGX:LoginMessage(message, opts)
    if not self:IsLoginMessagesEnabled() then
        return false
    end
    if type(opts) ~= "table" then
        opts = nil
    end
    print(self:CreateChatPrefix(opts), message)
    return true
end

-- Deep copy with circular-reference and metatable support
function RGX:DeepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local copy = {}
    seen[value] = copy
    for k, v in pairs(value) do
        copy[self:DeepCopy(k, seen)] = self:DeepCopy(v, seen)
    end
    return setmetatable(copy, getmetatable(value))
end

-- Throttle: execute func at most once per `seconds` interval for a given key.
RGX._throttleTimers = RGX._throttleTimers or {}
function RGX:Throttle(key, seconds, func)
    local now = GetTime and GetTime() or 0
    local last = self._throttleTimers[key]
    if not last or (now - last) >= seconds then
        self._throttleTimers[key] = now
        return func()
    end
end

-- Debounce: delay func by `seconds`, cancelling any pending call for the same key.
RGX._debounceTimers = RGX._debounceTimers or {}
function RGX:Debounce(key, seconds, func)
    local pending = self._debounceTimers[key]
    if pending and pending.active then
        pending.active = false
    end
    self._debounceTimers[key] = self:After(seconds, function()
        self._debounceTimers[key] = nil
        func()
    end)
end

-- WoW
function RGX:GetWoWVersion()
    return select(4, GetBuildInfo())
end

function RGX:IsRetail()
    return select(4, GetBuildInfo()) >= 100000
end

function RGX:IsClassicEra()
    local v = select(4, GetBuildInfo())
    return v >= 11000 and v < 20000
end
