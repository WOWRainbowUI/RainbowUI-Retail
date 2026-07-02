--[[
RGX-Framework - Database

  RGX:DB("MyAddonDB", defaults)
      Simple flat SavedVariables. Deep-merges defaults, returns the table.

  RGX:NewDatabase("MyAddonDB", defaults, opts)
      Profile-aware database with metamethod access.

      db.enabled         → reads active profile, falls back to default
      db.enabled = false → writes to active profile
      db.global.foo      → cross-character storage
      db.char.foo        → per-character storage (keyed by "Name - Realm")
      db:CreateProfile("Tank")
      db:LoadProfile("Tank")
      db:DeleteProfile("Tank")
      db:RenameProfile("old", "new")
      db:CopyProfile("source", "target")
      db:ListProfiles()
      db:GetProfiles()           → alias for ListProfiles
      db:GetActiveProfile()      → current profile name
      db:ResetProfile("name")    → clear and re-apply defaults
      db:OnProfileChanged(fn)    → register a callback
      db:SerializeProfile("name")
      db:DeserializeProfile(str)
      db:ShowExportDialog("name")
      db:ShowImportDialog()

  RGX:OpenDB(globalName, opts)
      Same as NewDatabase but with opts.profile instead of flat defaults.
      Kept for backward compatibility.
--]]

local _, RGX = ...

-- ── Helpers ────────────────────────────────────────────────────────────────────

local PROTECTED_PROFILE = "Default"
local SERIAL_PREFIX = "RGX_DB_v1:"

-- Deep-merge: source fills in missing keys in target.
local function MergeTable(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then return end
    for k, v in pairs(source) do
        if target[k] == nil then
            if type(v) == "table" then
                target[k] = {}
                MergeTable(target[k], v)
            else
                target[k] = v
            end
        elseif type(v) == "table" and type(target[k]) == "table" then
            MergeTable(target[k], v)
        end
    end
end
-- Read a nested key from a table using a dot-path string or array of keys.
local function GetPath(tbl, path, fallback)
    if not path then return tbl end
    local node = tbl
    if type(path) == "table" then
        for _, key in ipairs(path) do
            if type(node) ~= "table" then return fallback end
            node = node[key]
            if node == nil then return fallback end
        end
    elseif type(path) == "string" then
        for key in path:gmatch("[^%.]+") do
            if type(node) ~= "table" then return fallback end
            node = node[key]
            if node == nil then return fallback end
        end
    else
        return fallback
    end
    return node
end

-- Write a nested key in a table. Creates intermediate tables as needed.
local function SetPath(tbl, path, value)
    if not path then return false end
    local keys
    if type(path) == "table" then
        keys = path
    elseif type(path) == "string" then
        keys = {}
        for key in path:gmatch("[^%.]+") do
            keys[#keys + 1] = key
        end
    else
        return false
    end
    local node = tbl
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(node[key]) ~= "table" then node[key] = {} end
        node = node[key]
    end
    node[keys[#keys]] = value
    return true
end

-- ── RGX own database ───────────────────────────────────────────────────────────

function RGX:InitDatabase()
    _G.RGXFrameworkDB = _G.RGXFrameworkDB or {}
    self.db = _G.RGXFrameworkDB
    _G.RGXFrameworkDBChar = _G.RGXFrameworkDBChar or {}
    self.dbChar = _G.RGXFrameworkDBChar
 if type(self.defaults) == "table" and type(self.defaults.global) == "table" then
 MergeTable(self.db, self.defaults.global)
 end
    self:Debug("Database initialized")
end

function RGX:GetDB()
    return self.db
end

-- ── Simple flat DB ─────────────────────────────────────────────────────────────

function RGX:DB(name, defaults)
    _G[name] = _G[name] or {}
    local db = _G[name]
    if type(defaults) == "table" then
        self:MergeTable(db, defaults)
    end
    return db
end

function RGX:DBGet(db, path, fallback)
    return GetPath(db, path, fallback)
end

function RGX:DBSet(db, path, value)
    return SetPath(db, path, value)
end

-- ── Version migration ──────────────────────────────────────────────────────────

function RGX:MigrateDB(db, name, currentVersion, migrations)
    if type(currentVersion) ~= "number" or currentVersion < 1 then return end
    if type(migrations) ~= "table" then return end
    local stored = db._dbVersion or 0
    if stored >= currentVersion then return end
    for v = stored + 1, currentVersion do
        if type(migrations[v]) == "function" then
            local ok, err = pcall(migrations[v], db)
            if not ok then
                self:Error(string.format("DB migration %s v%d failed: %s", name, v, tostring(err)))
                return
            end
        end
    end
    db._dbVersion = currentVersion
end

-- ── Serialization (Recursive) ──────────────────────────────────────────────────

local function SerializeValue(val)
    local t = type(val)
    if t == "string" then
        -- Escape special characters for our simple parser
        local s = val:gsub("\\", "\\\\"):gsub(";", "\\s"):gsub("=", "\\e"):gsub("{", "\\l"):gsub("}", "\\r")
        return "S" .. s
    elseif t == "number" then
        return "N" .. tostring(val)
    elseif t == "boolean" then
        return "B" .. (val and "1" or "0")
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(val) do
            if type(k) == "string" or type(k) == "number" then
                local sv = SerializeValue(v)
                if sv then
                    table.insert(parts, tostring(k) .. "=" .. sv)
                end
            end
        end
        table.sort(parts)
        return "T{" .. table.concat(parts, ";") .. "}"
    end
end

local function DeserializeValue(str)
    if not str or str == "" then return nil end
    local prefix = str:sub(1, 1)
    local body = str:sub(2)

    if prefix == "S" then
        return body:gsub("\\r", "}"):gsub("\\l", "{"):gsub("\\e", "="):gsub("\\s", ";"):gsub("\\\\", "\\")
    elseif prefix == "N" then
        return tonumber(body)
    elseif prefix == "B" then
        return body == "1"
    elseif prefix == "T" then
        if body:sub(1, 1) ~= "{" or body:sub(-1) ~= "}" then return nil end
        local t = {}
        local content = body:sub(2, -2)

        -- Very basic recursive-descent parser for our T{k=v;k=T{...}} format
        local pos = 1
        while pos <= #content do
            local eq = content:find("=", pos)
            if not eq then break end
            local k = content:sub(pos, eq - 1)
            if tonumber(k) then k = tonumber(k) end

            pos = eq + 1
            local valStr
            local vPrefix = content:sub(pos, pos)
            if vPrefix == "T" then
                -- Find matching }
                local level = 0
                local endPos = pos + 1
                for i = pos + 1, #content do
                    local char = content:sub(i, i)
                    if char == "{" then
                        level = level + 1
                    elseif char == "}" then
                        if level == 0 then
                            endPos = i
                            break
                        else
                            level = level - 1
                        end
                    end
                end
                valStr = content:sub(pos, endPos)
                pos = endPos + 2 -- skip ;
            else
                local nextSemi = content:find(";", pos)
                if nextSemi then
                    valStr = content:sub(pos, nextSemi - 1)
                    pos = nextSemi + 1
                else
                    valStr = content:sub(pos)
                    pos = #content + 1
                end
            end
            if valStr then
                t[k] = DeserializeValue(valStr)
            end
        end
        return t
    end
end

function RGX:SerializeTable(t)
    local res = SerializeValue(t)
    return res and (SERIAL_PREFIX .. res) or ""
end

function RGX:DeserializeTable(str)
    if type(str) ~= "string" or not str:find("^" .. SERIAL_PREFIX, 1, true) then
        return nil
    end
    return DeserializeValue(str:sub(#SERIAL_PREFIX + 1))
end

-- ── Export / Import popups ─────────────────────────────────────────────────────

function RGX:ShowExportDialog(title, data)
    if type(StaticPopupDialogs) ~= "table" or type(StaticPopup_Show) ~= "function" then return end
    StaticPopupDialogs["RGX_EXPORT"] = {
        text = title or "Copy this data:",
        button1 = "Close",
        hasEditBox = true,
        editBoxWidth = 350,
        OnShow = function(self)
            if self.editBox then
                self.editBox:SetText(data or "")
                self.editBox:HighlightText()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("RGX_EXPORT")
end

function RGX:ShowImportDialog(title, onImport)
    if type(onImport) ~= "function" then return end
    if type(StaticPopupDialogs) ~= "table" or type(StaticPopup_Show) ~= "function" then return end
    StaticPopupDialogs["RGX_IMPORT"] = {
        text = title or "Paste data to import:",
        button1 = "Import",
        button2 = "Cancel",
        hasEditBox = true,
        editBoxWidth = 350,
        OnAccept = function(self)
            if self.editBox then
                onImport(self.editBox:GetText() or "")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("RGX_IMPORT")
end

-- ══════════════════════════════════════════════════════════════════════════════
-- DATABASE PROXY
-- ══════════════════════════════════════════════════════════════════════════════

-- The proxy is a table with __index and __newindex metamethods.
--
-- db.key reads from:  active profile → defaults
-- db.key = v writes to the active profile
-- db.global returns the cross-character storage table
-- db.char   returns the per-character storage table (keyed by "Name - Realm")
-- db:Method() calls one of the profile management methods below
--
-- Internal fields (stored on the proxy table itself, not in the profile):
--   _raw        → the SavedVariables global table (has .profiles, .global, .char, .activeProfile)
--   _defaults   → fallback values when a key is missing from the profile
--   _charDefaults → fallback values for per-character data
--   _charKey    → current "Name - Realm" key
--   _callbacks       → functions registered via OnProfileChanged
--   _onSwitch        → opt-in callback from opts.onSwitch
--   _guard           → lock to prevent re-entrant notification
--   _profileIsGlobal → when true, db.global returns the active profile (for legacy addons)

local DB = {} -- method table

-- ── Internal: build "Name - Realm" character key ──────────────────────────

local function CharKey()
    local name = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "Unknown"
    return name .. " - " .. realm
end

-- ── Internal: get the active profile table ────────────────────────────────────

local function ActiveProfile(self)
    local raw = self._raw
    return raw.profiles and raw.profiles[raw.activeProfile]
end

-- ── Internal: fire all "profile switched" callbacks ────────────────────────────

local function NotifySwitch(self)
    if self._guard then return end -- prevent re-entrant calls
    self._guard = true
    local name = self._raw.activeProfile
    local profile = ActiveProfile(self)
    if self._onSwitch then
        self._onSwitch(name, profile)
    end
    if self._callbacks then
        for _, cb in ipairs(self._callbacks) do
            cb(name, profile)
        end
    end
    self._guard = nil
end

-- ── Internal: apply defaults to a profile table ───────────────────────────────

local function FillDefaults(self, profile)
 if self._defaults then
 MergeTable(profile, self._defaults)
 end
end

-- ── Switch to a named profile (internal, used by CRUD methods) ────────────────

local function SwitchTo(self, name)
    local raw = self._raw
    raw.activeProfile = name
    raw.profiles[name].currentProfile = name
    FillDefaults(self, raw.profiles[name])
    NotifySwitch(self)
end

-- ── Ensure the protected "Default" profile always exists ──────────────────────

local function EnsureDefault(self)
    local raw = self._raw
    raw.profiles = raw.profiles or {}
    if raw.profiles[PROTECTED_PROFILE] then return end
    local tpl = {}
    FillDefaults(self, tpl)
    tpl.currentProfile = PROTECTED_PROFILE
    raw.profiles[PROTECTED_PROFILE] = tpl
end

-- ── Profile CRUD methods ──────────────────────────────────────────────────────

function DB:GetProfile()
    return ActiveProfile(self)
end

function DB:GetActiveProfile()
    return self._raw.activeProfile
end

function DB:GetChar()
    local raw = self._raw
    raw.char = raw.char or {}
    local key = self._charKey
    if type(raw.char[key]) ~= "table" then
        raw.char[key] = {}
    end
    local charData = raw.char[key]
    if self._charDefaults then
        MergeTable(charData, self._charDefaults)
    end
    return charData
end

function DB:ListProfiles()
    local names = {}
    for name in pairs(self._raw.profiles) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

function DB:GetProfiles()
    return self:ListProfiles()
end

function DB:CreateProfile(name)
    if not name or name == "" or name == PROTECTED_PROFILE then return false end
    self._raw.profiles = self._raw.profiles or {}
    local profile = {}
    FillDefaults(self, profile)
    profile.currentProfile = name
    self._raw.profiles[name] = profile
    SwitchTo(self, name)
    return true
end

function DB:LoadProfile(name)
    if not name or not self._raw.profiles[name] then return false end
    SwitchTo(self, name)
    return true
end

function DB:DeleteProfile(name)
    if not name or name == PROTECTED_PROFILE then return false end
    if not self._raw.profiles or not self._raw.profiles[name] then return false end
    self._raw.profiles[name] = nil
    if self._raw.activeProfile == name then
        local fallback = PROTECTED_PROFILE
        for pname in pairs(self._raw.profiles) do
            if pname ~= PROTECTED_PROFILE then
                fallback = pname; break
            end
        end
        SwitchTo(self, fallback)
    else
        NotifySwitch(self)
    end
    return true
end

function DB:RenameProfile(oldName, newName)
    if not oldName or not newName then return false end
    if oldName == PROTECTED_PROFILE or newName == PROTECTED_PROFILE then return false end
    if not self._raw.profiles or not self._raw.profiles[oldName] then return false end
    self._raw.profiles[newName] = self._raw.profiles[oldName]
    self._raw.profiles[oldName] = nil
    if self._raw.activeProfile == oldName then
        self._raw.activeProfile = newName
        self._raw.profiles[newName].currentProfile = newName
    end
    NotifySwitch(self)
    return true
end

function DB:CopyProfile(sourceName, targetName)
    if not targetName or targetName == "" or targetName == PROTECTED_PROFILE then return false end
    sourceName = sourceName or self._raw.activeProfile
    local source = self._raw.profiles and self._raw.profiles[sourceName]
    if not source then return false end
    local rgx = _G.RGXFramework
    local copy = rgx and rgx:DeepCopy(source) or {}
    copy.currentProfile = targetName
    self._raw.profiles[targetName] = copy
    SwitchTo(self, targetName)
    return true
end

function DB:ResetProfile(name)
 name = name or self._raw.activeProfile
 local profile = self._raw.profiles and self._raw.profiles[name]
 if not profile then return false end
 for k in pairs(profile) do
 if k ~= "currentProfile" then profile[k] = nil end
 end
 FillDefaults(self, profile)
 profile.currentProfile = name
 if name == self._raw.activeProfile then
 NotifySwitch(self)
 end
 return true
 end

function DB:OnProfileChanged(callback)
    if type(callback) ~= "function" then return end
    if not self._callbacks then self._callbacks = {} end
    self._callbacks[#self._callbacks + 1] = callback
end

-- ── Path accessors (used by GetDB/SetDB backward compat) ──────────────────────

function DB:Get(path, fallback)
    return GetPath(ActiveProfile(self), path, fallback)
end

function DB:Set(path, value)
    return SetPath(ActiveProfile(self), path, value)
end

-- ── Serialization ─────────────────────────────────────────────────────────────

function DB:SerializeProfile(name)
    name = name or self._raw.activeProfile
    local profile = self._raw.profiles and self._raw.profiles[name]
    if not profile then return "" end
    return RGX:SerializeTable(profile)
end

function DB:DeserializeProfile(str)
    return RGX:DeserializeTable(str)
end

function DB:ShowExportDialog(name)
    local data = self:SerializeProfile(name)
    RGX:ShowExportDialog("Copy profile data:", data)
end

function DB:ShowImportDialog()
    RGX:ShowImportDialog("Paste profile data:", function(str)
        local profile = self:DeserializeProfile(str)
        if profile then
            local name = "Imported_" .. date("%Y%m%d_%H%M%S")
            self._raw.profiles = self._raw.profiles or {}
            self._raw.profiles[name] = profile
            self:LoadProfile(name)
        end
    end)
end

-- ── METAMETHODS ───────────────────────────────────────────────────────────────
-- These are what make db.key and db.key = v work like a regular table.

-- __index: called when you read db.something
--   1. Is "something" a method on DB?        → return the function
--   2. Is it "global"?                       → return the cross-character table
--   3. Is it an internal field?              → return it from the proxy itself
--   4. Otherwise                             → read from active profile, then defaults
DB.__index = function(self, key)
 local method = DB[key]
 if method then return method end -- step 1

 if key == "global" then -- step 2
 if self._profileIsGlobal then
 return ActiveProfile(self) or self._raw.global
 end
 if not self._raw.global then self._raw.global = {} end
 return self._raw.global
 end

 if key == "char" then -- step 2b
 return self:GetChar()
 end

 if key == "_raw" or key == "_defaults" or key == "_charDefaults" or key == "_charKey" or key == "_callbacks" or key == "_onSwitch" or key == "_guard" or key == "_profileIsGlobal" then
 return rawget(self, key) -- step 3
 end

 local profile = ActiveProfile(self) -- step 4
 if profile then
 local val = profile[key]
 if val ~= nil then return val end
 end
 return self._defaults and self._defaults[key]
 end

 -- __newindex: called when you do db.something = value
 DB.__newindex = function(self, key, value)
 if key == "global" or key == "char" then return end -- block: use db.global.key / db.char.key
 if key == "_raw" or key == "_defaults" or key == "_charDefaults" or key == "_charKey" or key == "_callbacks" or key == "_onSwitch" or key == "_guard" or key == "_profileIsGlobal" then
 rawset(self, key, value)
 return
 end
 local profile = ActiveProfile(self)
 if profile then
 profile[key] = value
 end
 end

-- ══════════════════════════════════════════════════════════════════════════════
-- FACTORY FUNCTIONS
-- ══════════════════════════════════════════════════════════════════════════════

-- Modern API: flat defaults, metamethod access.
--   local db = RGX:NewDatabase("BLUDB", { enabled = true, volume = 1.0 }, {
--       global = { installedVersion = "1.0" },
--       char   = { lastZone = nil },        -- per-character defaults
--       profileIsGlobal = true,             -- db.global → active profile (legacy compat)
--       onSwitch = function(name, profile) RefreshUI() end,
--   })
function RGX:NewDatabase(globalName, defaults, opts)
    opts = opts or {}

    -- Step 1: initialize the SavedVariables global
    _G[globalName] = _G[globalName] or {}
    local raw = _G[globalName]
    raw.profiles = raw.profiles or {}
    raw.global = raw.global or {}
    raw.char = raw.char or {}

    -- Step 2: build the proxy table
    local db = setmetatable({
        _raw        = raw,
        _defaults   = defaults or {},
        _charDefaults = opts.char,
        _charKey    = CharKey(),
        _callbacks  = {},
        _onSwitch   = opts.onSwitch,
        _profileIsGlobal = opts.profileIsGlobal and true or nil,
    }, DB)

    -- Step 3: apply global defaults
 if type(opts.global) == "table" then
 MergeTable(raw.global, opts.global)
 end

    -- Step 3b: apply char defaults for current character
    if type(opts.char) == "table" then
        local key = db._charKey
        if type(raw.char[key]) ~= "table" then
            raw.char[key] = {}
        end
        MergeTable(raw.char[key], opts.char)
    end

    -- Step 4: ensure the Default profile exists
    EnsureDefault(db)

    -- Step 5: pick the active profile (last-used, or Default)
    local active = raw.activeProfile
    if not active or not raw.profiles[active] then
        active = PROTECTED_PROFILE
    end
    raw.activeProfile = active
    raw.profiles[active].currentProfile = active
    FillDefaults(db, raw.profiles[active])

    -- Step 6: fire the initial onSwitch callback (used by BLU for UI wiring)
    if opts.onSwitch then
        opts.onSwitch(active, raw.profiles[active])
    end

    return db
end

-- Backward-compat wrapper: same as NewDatabase but with opts.profile/{defaults} naming.
--   local handle = RGX:OpenDB("BLUDB", {
--       profile  = { enabled = true },
--       global   = { installedVersion = "1.0" },
--       onSwitch = function(name, profile) end,
--   })
function RGX:OpenDB(globalName, opts)
    opts = opts or {}
    return RGX:NewDatabase(globalName, opts.profile or opts.defaults, {
        global   = opts.global,
        char     = opts.char,
        profileIsGlobal = opts.profileIsGlobal,
        onSwitch = opts.onSwitch,
    })
end
