local MAJOR, MINOR = "LibUtil", 1
local Lib, minor = LibStub and LibStub(MAJOR, true)
if not Lib or next(Lib.Tbl) or (minor or 0) > MINOR then return end
local Util = Lib

---@class LibUtil.Tbl
---@operator call:table
local Self = Util.Tbl

-------------------------------------------------------
--                       Table                       --
-------------------------------------------------------

-- GET/SET

-- Get a value from a table
---@return any
function Self.Get(t, ...)
    local n, path = select("#", ...), ...

    if n == 1 and type(path) == "string" and path:find("%.") then
        path = Self.Tmp(("."):split((...)))
    elseif type(path) ~= "table" then
        path = Self.Tmp(...)
    end

    for i,k in Util.IEach(path) do
        if k == nil then
            break
        elseif t ~= nil then
            t = t[k]
        end
    end

    return t
end

-- Set a value on a table
---@vararg any
---@return table
---@return any
function Self.Set(t, ...)
    local n, path = select("#", ...), ...
    local val = select(n, ...)

    if n == 2 and type(path) == "string" and path:find("%.") then
        path = Self.Tmp(("."):split((...)))
    elseif type(path) ~= "table" then
        path = Self.Tmp(...)
        tremove(path)
    end

    local u, j = t
    for i,k in Util.IEach(path) do
        if k == nil then
            break
        elseif j then
            if u[j] == nil then u[j] = Self.New() end
            u = u[j]
        end
        j = k
    end

    u[j] = val

    return t, val
end

-- Get a random key from the table
function Self.RandomKey(t)
    if not next(t) then
        return
    else
        local n = random(Self.Count(t))
        for i,v in pairs(t) do
            n = n - 1
            if n == 0 then return i end
        end
    end
end

-- Get a random entry from the table
---@param t table
---@return any
function Self.Random(t)
    local key = Self.RandomKey(t)
    return key and t[key]
end

-- Get table keys
---@param t table
---@return table
function Self.Keys(t)
    local u = Self.New()
    for i,v in pairs(t) do tinsert(u, i) end
    return u
end

-- Get table values as continuously indexed list
---@param t table
---@return table
function Self.Values(t)
    local u = Self.New()
    for i,v in pairs(t) do tinsert(u, v) end
    return u
end

-- Turn a table into a continuously indexed list (in-place)
---@param t table
---@return table
function Self.List(t)
    local n = Self.Count(t)
    for k=1, n do
        if not t[k] then
            local l
            for i,v in pairs(t) do
                if type(i) == "number" then
                    l = min(l or i, i)
                else
                    l = i break
                end
            end
            t[k], t[l] = t[l], nil
        end
    end
    return t
end

-- Check if the table is a continuesly indexed list
function Self.IsList(t)
    return #t == Self.Count(t)
end

-- SUB

---@param t table
---@param s integer
---@param e integer
function Self.Sub(t, s, e)
    return {unpack(t, s or 1, e)}
end

function Self.Head(t, n)
    return Self.Sub(t, 1, n or 1)
end

---@param t table
---@param n integer
function Self.Tail(t, n)
    return Self.Sub(t, #t - (n or 1))
end

---@param t table
---@param s integer
---@param e integer
---@param u integer
function Self.Splice(t, s, e, u)
    return Self.Merge(Self.Head(t, s), u or {}, Self.Sub(t, #t, e))
end

-- ITERATE

-- Good old FoldLeft
---@param t table
---@param u any
function Self.FoldL(t, fn, u, index, ...)
    fn, u = Util.Fn.New(fn), u or Self.New()
    for i,v in pairs(t) do
        if index then
            u = fn(u, v, i, ...)
        else
            u = fn(u, v, ...)
        end
    end
    return u
end

-- Iterate through a table
function Self.Iter(t, fn, ...)
    fn = Util.Fn.New(fn)
    for i,v in pairs(t) do
        fn(v, i, ...)
    end
    return t
end

-- Call a function on every table entry
---@param t table
---@param fn function|string
---@param index boolean
---@param notVal boolean
---@vararg any
function Self.Call(t, fn, index, notVal, ...)
    for i,v in pairs(t) do
        Util.Fn.Call(Util.Fn.New(fn, v), v, i, index, notVal, ...)
    end
end

-- COUNT, SUM, MULTIPLY, MIN, MAX

---@return integer
function Self.Count(t)
    return Self.FoldL(t, Util.Fn.Inc, 0)
end

---@param t table
---@return number
function Self.Sum(t)
    return Self.FoldL(t, Util.Fn.Add, 0)
end

---@param t table
---@return number
function Self.Mul(t)
    return Self.FoldL(t, Util.Fn.Mul, 1)
end

---@param t table
---@param start number
---@return number
function Self.Min(t, start)
    return Self.FoldL(t, math.min, start or select(2, next(t)))
end

---@param t table
---@param start number
---@return number
function Self.Max(t, start)
    return Self.FoldL(t, math.max, start or select(2, next(t)))
end

-- Count the # of occurences of given value(s)
---@param t table
function Self.CountOnly(t, ...)
    local n = 0
    for i,v in pairs(t) do
        if Util.In(v, ...) then n = n + 1 end
    end
    return n
end

-- Count the # of occurences of everything except given value(s)
function Self.CountExcept(t, ...)
    local n = 0
    for i,v in pairs(t) do
        if not Util.In(v, ...) then n = n + 1 end
    end
    return n
end

-- Count the # of tables that have given key/val pairs
---@param t table
function Self.CountWhere(t, ...)
    local n = 0
    for i,u in pairs(t) do
        if Self.Matches(u, ...) then n = n + 1 end
    end
    return n
end

-- Count using a function
---@param index boolean
---@param notVal boolean
function Self.CountFn(t, fn, index, notVal, ...)
    local n, fn = 0, Util.Fn.New(fn)
    for i,v in pairs(t) do
        local val = Util.Fn.Call(fn, v, i, index, notVal, ...)
        n = n + (tonumber(val) or val and 1 or 0)
    end
    return n
end

-- SEARCH

-- Search for something in a table and return the index
---@param t table
---@param fn function(v: any, i: any): boolean
function Self.Search(t, fn, ...)
    fn = Util.Fn.New(fn) or Util.Fn.Id
    for i,v in pairs(t) do
        if fn(v, i, ...) then
            return i
        end
    end
end

-- Check if one table is contained within the other
---@param t table
function Self.Contains(t, u, deep)
    if t == u then
        return true
    elseif (t == nil) ~= (u == nil) then
        return false
    end

    for i,v in pairs(u) do
        if deep and type(t[i]) == "table" and type(v) == "table" then
            if not Self.Contains(t[i], v, true) then
                return false
            end
        elseif t[i] ~= v then
            return false
        end
    end
    return true
end

-- Check if two tables are equal
---@param deep boolean
function Self.Equals(a, b, deep)
    return type(a) == "table" and type(b) == "table" and Self.Contains(a, b, deep) and Self.Contains(b, a, deep)
end

-- Check if a table matches the given key-value pairs
---@param t table
function Self.Matches(t, ...)
    if type(...) == "table" then
        return Self.Contains(t, ...)
    else
        for i=1, select("#", ...), 2 do
            local key, val = select(i, ...)
            local v = Self.Get(t, key)
            if v == nil or val ~= nil and v ~= val then
                return false
            end
        end

        return true
    end
end

-- Check if a value is a filled table
---@param t table
function Self.IsSet(t)
    return type(t) == "table" and next(t) and true or false
end

-- Check if a value is not a table or empty
---@param t table
function Self.IsEmpty(t)
    return not Self.IsSet(t)
end

-- Find a value in a table
---@generic K, V
---@param t table<K, V>
---@param val V
---@return K?
---@return V?
function Self.Find(t, val)
    for i,v in pairs(t) do
        if v == val then return i, v end
    end
end

-- Find a set of key/value pairs in a table
---@generic K, V
---@param t table<K, V>
---@vararg K|V
---@return K?
---@return V?
function Self.FindWhere(t, ...)
    for i,v in pairs(t) do
        if Self.Matches(v, ...) then return i, v end
    end
end

-- Find the first element matching a fn
---@generic K, V, A
---@param t table<K, V>
---@param fn? string|(fun(v: V, k: K, ...: A): any?)|(fun(v: V, ...: A): any?)
---@param index? boolean
---@param notVal? boolean
---@vararg A
---@return K?
---@return V?
function Self.FindFn(t, fn, index, notVal, ...)
    for i,v in pairs(t) do
        if Util.Fn.Call(Util.Fn.New(fn, v), v, i, index, notVal, ...) then
            return i, v
        end
    end
end

-- Find the first element (optinally matching a fn)
---@generic K, V, A
---@param t table<K, V>
---@param fn? string|(fun(v: V, k: K, ...: A): any?)|(fun(v: V, ...: A): any?)
---@param index? boolean
---@param notVal? boolean
---@vararg A
---@return V?
function Self.First(t, fn, index, notVal, ...)
    if not fn then
        return select(2, next(t))
    else
        return select(2, Self.FindFn(t, fn, index, notVal, ...))
    end
end

-- Find the first set of key/value pairs in a table
---@generic K, V
---@param t table<K, V>
---@vararg K|V
---@return V
function Self.FirstWhere(t, ...)
    return select(2, Self.FindWhere(t, ...))
end

-- FILTER

-- Filter by a function
---@param t table
---@param index boolean?
---@param notVal boolean?
---@param k boolean?
function Self.Filter(t, fn, index, notVal, k, ...)
    fn = Util.Fn.New(fn) or Util.Fn.Id

    if not k and Self.IsList(t) then
        for i=#t,1,-1 do
            if not Util.Fn.Call(fn, t[i], i, index, notVal, ...) then
                tremove(t, i)
            end
        end
    else
        for i,v in pairs(t) do
            if not Util.Fn.Call(fn, v, i, index, notVal, ...) then
                Self.Remove(t, i, k)
            end
        end
    end

    return t
end

-- Pick specific keys from a table
function Self.Select(t, ...)
    for i in pairs(t) do
        if not Util.In(i, ...) then t[i] = nil end
    end
    return t
end

-- Omit specific keys from a table
---@param t table
function Self.Unselect(t, ...)
    for i,v in Util.Each(...) do t[v] = nil end
    return t
end

-- Filter by a value
---@param k boolean
function Self.Only(t, val, k)
    return Self.Filter(t, Util.Equals, nil, nil, k, val)
end

-- Filter by not being a value
local Fn = function (v, val) return v ~= val end
---@param val any
---@param k boolean
function Self.Except(t, val, k)
    return Self.Filter(t, Fn, nil, nil, k, val)
end

-- Filter by a set of key/value pairs in a table
---@param t table
---@param k boolean
function Self.Where(t, k, ...)
    return Self.Filter(t, Self.Matches, nil, nil, k, ...)
end

-- Filter by not having a set of key/value pairs in a table
local Fn = function (...) return not Self.Matches(...) end
---@param t table
---@param k boolean
function Self.ExceptWhere(t, k, ...)
    return Self.Filter(t, Fn, nil, nil, k, ...)
end

-- COPY

-- Copy a table and optionally apply a function to every entry
---@param fn function
---@param index boolean
---@param notVal boolean
function Self.Copy(t, fn, index, notVal, ...)
    local fn, u = Util.Fn.New(fn), Self.New()
    for i,v in pairs(t) do
        if fn then
            u[i] = Util.Fn.Call(fn, v, i, index, notVal, ...)
        else
            u[i] = v
        end
    end
    return u
end

local Fn = function (v) return type(v) == "table" and Self.CopyDeep(v) or v end
function Self.CopyDeep(t)
    return Self.Copy(t, Fn)
end

-- Filter by a function
function Self.CopyFilter(t, fn, index, notVal, k, ...)
    fn = Util.Fn.New(fn) or Util.Fn.Id
    local u = Self.New()
    for i,v in pairs(t) do
        if Util.Fn.Call(fn, v, i, index, notVal, ...) then
            Self.Insert(u, k and i, v, k)
        end
    end
    return k and u or Self.List(u)
end

-- Pick specific keys from a table
function Self.CopySelect(t, ...)
    local u = Self.New()
    for i,v in Util.Each(...) do u[v] = t[v] end
    return u
end

-- Omit specific keys from a table
function Self.CopyUnselect(t, ...)
    local u = Self.New()
    for i,v in pairs(t) do
        if not Util.In(i, ...) then
            u[i] = v
        end
    end
    return u
end

-- Filter by a value
---@param t table
---@param k boolean
function Self.CopyOnly(t, val, k)
    local u = Self.New()
    for i,v in pairs(t) do
        if v == val then
            Self.Insert(u, k and i, v, k)
        end
    end
    return u
end

-- Filter by not being a value
---@generic T: table
---@param t T
---@param val any
---@param k boolean
---@return T
function Self.CopyExcept(t, val, k)
    local u = Self.New()
    for i,v in pairs(t) do
        if v ~= val then
            Self.Insert(u, k and i, v, k)
        end
    end
    return u
end

-- Filter by a set of key/value pairs in a table
---@param t table
---@param k boolean
function Self.CopyWhere(t, k, ...)
    local u = Self.New()
    for i,v in pairs(t) do
        if Self.FindWhere(u, ...) then
            Self.Insert(u, k and i, v, k)
        end
    end
    return u
end

-- Filter by not having a set of key/value pairs in a table
---@param t table
---@param k boolean
function Self.CopyExceptWhere(t, k, ...)
    local u = Self.New()
    for i,v in pairs(t) do
        if not Self.FindWhere(u, ...) then
            Self.Insert(u, k and i, v, k)
        end
    end
    return u
end

-- MAP

-- Change table values by applying a function
---@generic K, V, A, R
---@param t table<K, V>
---@param fn fun(v: V, i: K, ...: A): R
---@param index boolean
---@param notVal boolean
---@vararg A
---@return table<K, R>
function Self.Map(t, fn, index, notVal, ...)
    fn = Util.Fn.New(fn)
    for i,v in pairs(t) do
        t[i] = Util.Fn.Call(fn, v, i, index, notVal, ...)
    end
    return t
end

-- Change table keys by applying a function
---@param val boolean
---@param notIndex boolean
function Self.MapKeys(t, fn, val, notIndex, ...)
    fn = Util.Fn.New(fn)
    local u = Self.New()
    for i,v in pairs(t) do
        u[Util.Fn.Call(fn, i, v, val, notIndex, ...)] = v
    end
    return u
end

-- Change table values by extracting a key
---@param t table
function Self.Pluck(t, k)
    for i,v in pairs(t) do
        t[i] = v[k]
    end
    return t
end

-- Flip table keys and values
---@param t table
---@param val any
---@vararg any
---@return table
function Self.Flip(t, val, ...)
    local u = Self.New()
    for i,v in pairs(t) do
        if type(val) == "function" then
            u[v] = val(v, i, ...)
        elseif val ~= nil then
            u[v] = val
        else
            u[v] = i
        end
    end
    return u
end

-- GROUP

-- Group table entries by funciton
---@param t table
---@param fn function(v: any, i: any): any
function Self.Group(t, fn)
    fn = Util.Fn.New(fn) or Util.Fn.Id
    local u = Self.New()
    for i,v in pairs(t) do
        i = fn(v, i)
        u[i] = u[i] or Self.New()
        tinsert(u[i], v)
    end
    return u
end

-- Group table entries by key
---@param t table
function Self.GroupBy(t, k)
    local u = Self.New()
    for i,v in pairs(t) do
        i = v[k]
        u[i] = u[i] or Self.New()
        tinsert(u[i], v)
    end
    return u
end

-- Group the keys with the same values
---@generic K, V
---@param t table <K, V>
---@return table<V, K[]>
function Self.GroupKeys(t)
    local u = Self.New()
    for i,v in pairs(t) do
        u[v] = u[v] or Self.New()
        tinsert(u[v], i)
    end
    return u
end

-- SET

-- Make sure all table entries are unique
---@param t table
---@param k boolean
function Self.Unique(t, k)
    local u = Self.New()
    for i,v in pairs(t) do
        if u[v] ~= nil then
            Self.Remove(t, i, k)
        else
            u[v] = true
        end
    end
    Self.Release(u)
    return t
end

-- Substract the given tables from the table
---@param t table
function Self.Diff(t, ...)
    local k = select(select("#", ...), ...) == true

    for i,v in pairs(t) do
        for i=1, select("#", ...) - (k and 1 or 0) do
            if Util.In(v, (select(i, ...))) then
                Self.Remove(t, i, k)
                break
            end
        end
    end
    return t
end

-- Intersect the table with given tables
---@param t table
function Self.Intersect(t, ...)
    local k = select(select("#", ...), ...) == true

    for i,v in pairs(t) do
        for i=1, select("#", ...) - (k and 1 or 0) do
            if not Util.In(v, (select(i, ...))) then
                Self.Remove(t, i, k)
                break
            end
        end
    end
    return t
end

-- Check if the intersection of the given tables is not empty
---@param t table
function Self.Intersects(t, ...)
    for _,v in pairs(t) do
        local found = true
        for i=1, select("#", ...) do
            if not Util.In(v, (select(i, ...))) then
                found = false
                break
            end
        end

        if found then
            return true
        end
    end
    return false
end

-- CHANGE

---@param i any
---@param v any
---@param k boolean
function Self.Insert(t, i, v, k)
    if k or i and not tonumber(i) then
        t[i] = v
    elseif i then
        tinsert(t, i, v)
    else
        tinsert(t, v)
    end
end

function Self.Remove(t, i, k)
    if k or i and not tonumber(i) then
        t[i] = nil
    elseif i then
        tremove(t, i)
    else
        tremove(t)
    end
end

---@param t table
function Self.Push(t, v)
    tinsert(t, v)
    return t
end

---@param t table
function Self.Pop(t)
    return tremove(t)
end

---@param t table
function Self.Drop(t)
    tremove(t)
    return t
end

---@param t table
function Self.Shift(t)
    return tremove(t, 1)
end

---@param t table
function Self.Unshift(t, v)
    tinsert(t, 1, v)
    return t
end

-- Rotate by l (l>0: left, l<0: right)
---@param t table
---@param l integer
function Self.Rotate(t, l)
    l = l or 1
    for i=1, math.abs(l) do
        if l < 0 then
            tinsert(t, 1, tremove(t))
        else
            tinsert(t, tremove(t, 1))
        end
    end
    return t
end

-- Sort a table
local Fn = function (a, b) return a > b end
function Self.Sort(t, fn)
    fn = fn == true and Fn or Util.Fn.New(fn) or nil
    table.sort(t, fn)
    return t
end

-- Sort a table of tables by given table keys and default values
local Fn = function (a, b) return Util.Compare(b, a) end
function Self.SortBy(t, ...)
    local args = type(...) == "table" and (...) or Self.Tmp(...)
    return Self.Sort(t, function (a, b)
        for i=1, #args, 3 do
            local key, default, fn = args[i], args[i+1], args[i+2]
            fn = fn == true and Fn or Util.Fn.New(fn) or Util.Compare

            local cmp = fn(a and a[key] or default, b and b[key] or default)
            if cmp ~= 0 then return cmp == -1 end
        end
    end), Self.ReleaseTmp(args)
end

-- Merge two or more tables
function Self.Merge(t, ...)
    t = t or Self.New()
    for i=1,select("#", ...) do
        local tbl, j = (select(i, ...)), 1
        if tbl then
            for k,v in pairs(tbl) do
                if k == j then tinsert(t, v) else t[k] = v end
                j = j + 1
            end
        end
    end
    return t
end

-- OTHER

-- Convert the table into tuples of n
---@param t table
---@param n integer
function Self.Tuple(t, n)
    local u, n, r = Self.New(), n or 2
    for i,v in pairs(t) do
        if not r or #r == n then
            r = Self.New()
            tinsert(u, r)
        end
        tinsert(r, v)
    end
    return u
end

-- Flatten a list of tables by one dimension
local Fn = function (u, v) return Self.Merge(u, v) end
---@param t table
---@return table
function Self.Flatten(t)
    return Self.FoldL(t, Fn, Self.New())
end

-- Wipe multiple tables at once
---@vararg table
function Self.Wipe(...)
    for i=1,select("#", ...) do wipe((select(i, ...))) end
    return ...
end

-- Join a table of strings
function Self.Concat(t, del)
    return Util.Str.Join(del, t)
end

-- Use Blizzard's inspect tool
function Self.Inspect(t)
    UIParentLoadAddOn("Blizzard_DebugTools")
    DisplayTableInspectorWindow(t)
end

-------------------------------------------------------
--                  Reusable Table                   --
-------------------------------------------------------

-- Store unused tables in a cache to reuse them later

-- A cache for temp tables
Self.tblPool = {}
Self.tblPoolSize = 10

-- For when we need an empty table as noop or special marking
Self.EMPTY = {}

-- For when we need to store nil values in a table
Self.NIL = {}

-- Get a table (newly created or from the cache), and fill it with values
function Self.New(...)
    return Self.Pack(tremove(Self.tblPool) or {}, ...)
end

-- Get a table (newly created or from the cache), and fill it with key/value pairs
function Self.Hash(...)
    local t = tremove(Self.tblPool) or {}
    for i=1, select("#", ...), 2 do
        t[select(i, ...)] = select(i + 1, ...)
    end
    return t
end

-- Add one or more tables to the cache, first parameter can define a recursive depth
---@param depth integer|boolean|table
---@vararg table
function Self.Release(depth, ...)
    depth = type(depth) == "number" and max(0, depth) or type(depth) ~= "table" and Self.tblPoolSize or 0

    for i=1, select("#", ...) do
        local t = select(i, ...)
        if type(t) == "table" and t ~= Self.EMPTY and t ~= Self.NIL then
            if #Self.tblPool < Self.tblPoolSize then
                tinsert(Self.tblPool, t)

                if depth > 0 then
                    for _,v in pairs(t) do
                        if type(v) == "table" then Self.Release(depth - 1, v) end
                    end
                end

                wipe(t)
                setmetatable(t, nil)
            else
                break
            end
        end
    end
end

-- Wipe and fill a table with vararg data
function Self.Pack(t, ...)
    wipe(t)
    for i=1,select("#", ...) do
        t[i] = select(i, ...)
    end
    return t
end

-- Unpack and release a table
local Fn = function (t, ...) Self.Release(t) return ... end
---@param t table
function Self.Unpack(t)
    return Fn(t, unpack(t))
end

-------------------------------------------------------
--                  Temporary Table                  --
-------------------------------------------------------

-- Tables that are automatically released after certain operations (such as loops)

function Self.Tmp(...)
    local t = tremove(Self.tblPool) or {}
    for i=1, select("#", ...) do
        local v = select(i, ...)
        t[i] = v == nil and Self.NIL or v
    end
    return setmetatable(t, Self.EMPTY)
end

function Self.HashTmp(...)
    return setmetatable(Self.Hash(...), Self.EMPTY)
end

---@param t table
function Self.IsTmp(t)
    return getmetatable(t) == Self.EMPTY
end

---@vararg table
function Self.ReleaseTmp(...)
    for i=1, select("#", ...) do
        local t = select(i, ...)
        if type(t) == "table" and Self.IsTmp(t) then Self.Release(t) end
    end
end