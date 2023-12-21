local MAJOR, MINOR = "LibUtil", 1
local Lib, minor = LibStub and LibStub(MAJOR, true)
if not Lib or next(Lib.Misc) or (minor or 0) > MINOR then return end
local Util = Lib

---@class LibUtil.Misc
local Self = Util.Misc

-------------------------------------------------------
--                      General                      --
-------------------------------------------------------

-- Check if val is an instance of a class
function Self.InstanceOf(val, of)
    local meta = getmetatable(val)
    return of and meta and meta.__index == of
end

-- Check if two values are equal
function Self.Equals(a, b)
    return a == b
end

-- Compare two values, returns -1 for a < b, 0 for a == b and 1 for a > b
---@generic T
---@param a T
---@param b T
function Self.Compare(a, b)
    return a == b and 0
        or a == nil and -1
        or b == nil and 1
        or a > b and 1 or -1
end

-- Create an iterator
---@param from? number
---@param to? number
---@param step? number
---@return fun(steps?: number, reset?: boolean): number?
function Self.Iter(from, to, step)
    local i = from or 0
    return function (steps, reset)
        i = (reset and (from or 0) or i) + (step or 1) * (steps or 1)
        return (not to or i <= to) and i or nil
    end
end

-- Return val if it's not nil, default otherwise
---@generic T
---@param val T
---@param default T
---@return T
function Self.Default(val, default)
    if val ~= nil then return val else return default end
end

-- Return a when cond is true, b otherwise
---@generic T
---@param cond any
---@param a T
---@param b T
---@return T
function Self.Check(cond, a, b)
    if cond then return a else return b end
end

-- Check if the value is truthy (true, ~=0, ~="", ~=[])
---@param val any
function Self.IsSet(val)
    if not val or val == 0 then return false end
    local t = type(val)
    if t == "string" then return val:trim() ~= "" end
    if t == "table" then return next(val) ~= nil end
    return true
end

-- Check if the value is falsy (false, 0, "", [])
function Self.IsEmpty(val)
    return not Self.IsSet(val)
end

-- Iterate tables or parameter lists
---@generic T, I
---@param t T[]
---@param i I
---@return I, T
local Fn = function (t, i)
    i = (i or 0) + 1
    if i > #t then
        return Util.Tbl.ReleaseTmp(t)
    else
        local v = t[i]
        return i, Self.Check(v == Util.Tbl.NIL, nil, v)
    end
end
---@generic T, I
---@return function(t: T[], i: I): I, T
---@return T
---@return I
function Self.Each(...)
    if ... and type(...) == "table" then
        return next, ...
    elseif select("#", ...) == 0 then
        return Util.Fn.Noop, nil, nil
    else
        return Fn, Util.Tbl.Tmp(...), nil
    end
end
---@generic T, I
---@return function(t: T[], i: I): I, T
---@return T
---@return I
function Self.IEach(...)
    if ... and type(...) == "table" then
        return Fn, ...
    else
        return Self.Each(...)
    end
end

-- Shortcut for val == x or val == y or ...
---@param val any
---@return boolean
function Self.In(val, ...)
    for i,v in Self.Each(...) do
        if v == val then return true end
    end
    return false
end

-- Shortcut for val == a and b or val == c and d or ...
---@param val any
---@return any
function Self.Select(val, ...)
    local n = select("#", ...)

    for i=1, n - n % 2, 2 do
        local a, b = select(i, ...)
        if val == a then return b end
    end

    if n % 2 == 1 then
        return select(n, ...)
    end
end

-------------------------------------------------------
--                       Stack                       --
-------------------------------------------------------

-- Useful for ternary conditionals, e.g. val = (cond1 and Push(false) or cond2 and Push(true) or Push(nil)).Pop()

Self.stack = {}

---@param val any
function Self.Push(val)
    tinsert(Self.stack, val == nil and Util.Tbl.NIL or val)
    return Self
end

---@return any
function Self.Pop()
    local val = tremove(Self.stack)
    return Self.Check(val == Util.Tbl.NIL, nil, val)
end

-------------------------------------------------------
--                       Other                       --
-------------------------------------------------------

-- Safecall
local xpcall = xpcall

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end

		local function dispatch(func, ...)
			method = func
			if not method then return end
			ARGS = ...
			return xpcall(call, eh)
		end

		return dispatch
	]]

	local ARGS = {}
	for i = 1, argCount do ARGS[i] = "arg"..i end
	code = code:gsub("ARGS", table.concat(ARGS, ", "))
	return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})
Dispatchers[0] = function(func)
	return xpcall(func, errorhandler)
end

---@param func function
function Self.Safecall(func, ...)
	return Dispatchers[select("#", ...)](func, ...)
end

-- Dump all given values
function Self.Dump(...)
    for i=1,select("#", ...) do
        print(Util.Str.ToString((select(i, ...))))
    end
end

-- Stacktrace
function Self.Trace()
    local s = Util(debugstack(2)):Split("\n"):Except("")()
    print("------------------------- Trace -------------------------")
    for i,v in pairs(s) do
        print(i .. ": " .. v)
    end
    print("---------------------------------------------------------")
end