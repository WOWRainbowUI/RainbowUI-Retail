local MAJOR, MINOR = "LibUtil", 1

---@class LibUtil: LibUtil.Misc
---@field Tbl LibUtil.Tbl
---@field Str LibUtil.Str
---@field Num LibUtil.Num
---@field Bool LibUtil.Bool
---@field Fn LibUtil.Fn
---@field Misc LibUtil.Misc
local Self = LibStub and LibStub:NewLibrary(MAJOR, MINOR)
if not Self then return end

-- Modules
local modules = {
    table = "Tbl",
    string = "Str",
    number = "Num",
    boolean = "Bool",
    ["function"] = "Fn",
    "Misc"
}

local Module = {
    __call = function (self, ...)
        return self.New(...)
    end
}

for _,mod in pairs(modules) do
    Self[mod] = setmetatable({}, Module)
end

-------------------------------------------------------
--                     Chaining                      --
-------------------------------------------------------

local Resolve = function (self, ...)
    local obj, mod = rawget(self, "obj"), rawget(self, "mod")
    local key, val = rawget(self, "key"), rawget(self, "val")

    mod = mod or modules[type(val)]
    obj = mod and obj[mod] or obj

    self.val = obj[key](val, ...)
    self.key, self.mod = nil, nil

    return self
end

local Chain = {
    __index = function (self, key)
        if rawget(self.obj, key) then
            self.mod = key
            return self
        else
            self.key = key
            return Resolve
        end
    end,
    __call = function (self, key)
        local val = rawget(self, "val")
        if key ~= nil then
            val = val[key]
        end
        self.obj.Tbl.Release(self)
        return val
    end
}

local Meta = {
    __index = Self.Misc,
    __call = function (self, val)
        local chain = setmetatable(self.Tbl.New(), Chain)
        chain.obj, chain.key, chain.val = self, nil, val
        return chain
    end
}

setmetatable(Self, Meta)
Self.__index = Self
Self.__call = Meta.__call
