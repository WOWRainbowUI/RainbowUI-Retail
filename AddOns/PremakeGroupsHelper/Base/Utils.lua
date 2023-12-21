local addonName, addon = ...
addon.utils = addon.utils or {}
local utils = addon.utils
local const = addon.const
local setmetatableindex_
setmetatableindex_ = function(t, index)
    --[[if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else]]
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    --end
end
setmetatableindex = setmetatableindex_

function utils.class(classname, ...)
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() end
    end

    cls.new = function(...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        return instance
    end

    cls.create = function(_, ...)
        return cls.new(...)
    end

    return cls
end

function utils.tkeys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function utils.tvalues(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function utils.tmerge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function utils.tremovebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function utils.tindexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end


function utils.tkeyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end


function utils.tfilter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

function utils.twalk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

function utils.tnums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function utils.handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function utils.formatMPlusRating(score)
    if not score or type(score) ~= "number" then
        score = 0
    end
    -- If the score is 1000 or larger, divide by 1000 to get a decimal, get the first 3 characters to prevent rounding and then add a K. Ex: 2563 = 2.5k
    -- If the score is less than 1000, we simply store it in the shortScore variable.
    
    --local shortScore = score >= 1000 and string.format("%3.2f", score/1000):sub(1,3) .. "k" or score
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR;
	
    local formattedScore = color:WrapTextInColorCode(score)
    return formattedScore
end

function utils.normalizePlayerName(name)
    local pos = string.find(name, '-', 1, true)

    if pos == nil then
        name = name .. '-' .. GetRealmName()
    end

    return name
end

function utils.getCategory()
    local categoryId = LFGListFrame.CategorySelection.selectedCategory or LFGListFrame.EntryCreation.selectedCategory
    local filters = LFGListFrame.CategorySelection.selectedFilters or LFGListFrame.EntryCreation.selectedFilters

    if C_LFGList.HasActiveEntryInfo() then
        local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
        local activityInfo = C_LFGList.GetActivityInfoTable(activeEntryInfo.activityID);
        categoryId = activityInfo.categoryID or categoryId
        filters = activityInfo.filters or filters
    end

    if categoryId ~= const.CATEGORY_TYPE_RAID then
        return categoryId
    end
        
    if filters ~= LE_LFG_LIST_FILTER_RECOMMENDED then --经典旧世
        return const.CATEGORY_TYPE_CLASSRAID
    end

    return categoryId
end