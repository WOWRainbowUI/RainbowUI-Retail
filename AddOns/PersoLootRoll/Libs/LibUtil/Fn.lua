local MAJOR, MINOR = "LibUtil", 1
local Lib, minor = LibStub and LibStub(MAJOR, true)
if not Lib or next(Lib.Fn) or (minor or 0) > MINOR then return end
local Util = Lib

---@class LibUtil.Fn
local Self = Util.Fn

-------------------------------------------------------
--                      Function                     --
-------------------------------------------------------

function Self.New(fn, obj) return type(fn) == "string" and (obj and obj[fn] or _G[fn]) or fn end
function Self.Id(...) return ... end
function Self.True() return true end
function Self.False() return false end
function Self.Zero() return 0 end
function Self.Noop() end

---@param index boolean?
---@param notVal boolean?
---@return any
function Self.Call(fn, v, i, index, notVal, ...)
    if index and notVal then
        return fn(i, ...)
    elseif index then
        return fn(v, i, ...)
    elseif notVal then
        return fn(...)
    else
        return fn(v, ...)
    end
end

-- Get a value directly or as return value of a function
---@param fn function
function Self.Val(fn, ...)
    return (type(fn) == "function" and Util.Push(fn(...)) or Util.Push(fn)).Pop()
end

-- Some math
---@param i number
function Self.Inc(i)
    return i+1
end

---@param i number
function Self.Dec(i)
    return i-1
end

---@param a number
---@param b number
function Self.Add(a, b)
    return a+b
end

---@param a number
---@param b number
function Self.Sub(a, b)
    return a-b
end

---@param a number
---@param b number
function Self.Mul(a, b)
    return a*b
end

---@param a number
---@param b number
function Self.Div(a, b)
    return a/b
end

-- MODIFY

-- General purpose function slow-down
---@param fn function
---@param n number
---@param debounce boolean
---@param leading boolean
---@param update boolean
function Self.SlowDown(fn, n, debounce, leading, update)
    local Timer = LibStub("AceTimer-3.0")
    local args = {}
    local handle, called, scheduler, handler

    scheduler = function (...)
        if not handle or update then
            Util.Tbl.Pack(args, ...)
        end

        if handle then
            called = true
            if debounce then
                Timer:CancelTimer(handle)
            end
        elseif leading then
            fn(...)
        end

        if not handle or debounce then
            handle = Timer:ScheduleTimer(handler, n)
        end
    end

    handler = function ()
        handle = nil
        if not leading then
            fn(unpack(args))
        elseif called then
            called = nil
            scheduler(unpack(args))
        end
    end

    return scheduler
end

-- Throttle a function, so it is executed at most every n seconds
function Self.Throttle(fn, n, ...)
    return Self.SlowDown(fn, n, false, ...)
end

-- Debounce a function, so it is executed only n seconds after the last call
function Self.Debounce(fn, n, ...)
    return Self.SlowDown(fn, n, true, ...)
end