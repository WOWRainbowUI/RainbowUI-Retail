--=====================================================================================
-- RGX-Framework | RGXDataBroker
-- Data object registry for minimap/datatext displays, RGX's own.
--
-- Quick start (3 lines):
--   local DB = RGX:GetDataBroker()
--   local obj = DB:NewDataObject("MyAddon", { type="data source", text="Hi", icon="..." })
--   obj.text = "Updated text"   -- live, fires callbacks automatically
--
-- Public API:
--   DB:NewDataObject(name, attrs)         -- create/return a live proxy data source
--   DB:GetDataObject(name)                -- retrieve existing object by name
--   DB:GetAllDataObjects()                -- { name = proxy, ... }
--   DB:OnNewDataObject(fn)                -- fn(name, proxy) on each new registration
--   DB:OnAttributeChanged(fn)             -- fn(name, attr, value) on any field write
--=====================================================================================

local addonName, RGX = ...

local DB = {}

DB._objects          = {}  -- name → proxy
DB._raw              = {}  -- name → raw attribute table
DB._newCallbacks     = {}
DB._changeCallbacks  = {}

-- ── Internal callbacks ────────────────────────────────────────────────────────

local function FireNew(name, proxy)
    for _, fn in ipairs(DB._newCallbacks) do
        local ok, err = pcall(fn, name, proxy)
        if not ok then
            pcall(function() RGX:Debug("[RGXDataBroker] OnNewDataObject error: " .. tostring(err)) end)
        end
    end
end

local function FireChange(name, attr, value)
    for _, fn in ipairs(DB._changeCallbacks) do
        local ok, err = pcall(fn, name, attr, value)
        if not ok then
            pcall(function() RGX:Debug("[RGXDataBroker] OnAttributeChanged error: " .. tostring(err)) end)
        end
    end
end

-- ── Proxy factory ─────────────────────────────────────────────────────────────

local function MakeProxy(name, raw)
    return setmetatable({}, {
        __index    = raw,
        __newindex = function(_, k, v)
            raw[k] = v
            FireChange(name, k, v)
        end,
        __tostring = function()
            return "RGXDataObject[" .. name .. "]"
        end,
    })
end

-- ── Public API ────────────────────────────────────────────────────────────────

function DB:NewDataObject(name, attrs)
    if self._objects[name] then
        -- Update existing object attrs
        local raw = self._raw[name]
        for k, v in pairs(attrs or {}) do
            raw[k] = v
        end
        return self._objects[name]
    end

    local raw   = {}
    for k, v in pairs(attrs or {}) do raw[k] = v end
    local proxy = MakeProxy(name, raw)

    self._objects[name] = proxy
    self._raw[name]     = raw

    FireNew(name, proxy)

    return proxy
end

function DB:GetDataObject(name)
    return self._objects[name]
end

function DB:GetAllDataObjects()
    local copy = {}
    for k, v in pairs(self._objects) do copy[k] = v end
    return copy
end

function DB:OnNewDataObject(fn)
    if type(fn) ~= "function" then return end
    table.insert(self._newCallbacks, fn)
    -- fire immediately for already-registered objects
    for name, proxy in pairs(self._objects) do
        pcall(fn, name, proxy)
    end
end

function DB:OnAttributeChanged(fn)
    if type(fn) ~= "function" then return end
    table.insert(self._changeCallbacks, fn)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXDataBroker = DB
RGX:RegisterModule("databroker", DB, { category = "library" })
