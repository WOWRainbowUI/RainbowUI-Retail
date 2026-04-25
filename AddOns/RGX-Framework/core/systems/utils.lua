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
        if dst[k] == nil then
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
function RGX:Print(...)
    print("|cff58be81[RGX]|r", ...)
end

function RGX:Warn(...)
    print("|cffffcc00[RGX]|r", ...)
end

function RGX:Error(...)
    print("|cffff4444[RGX]|r", ...)
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
