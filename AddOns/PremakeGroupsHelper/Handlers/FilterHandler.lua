-------------------------------------------------------------------------------
-- Premade Groups Filter
-------------------------------------------------------------------------------
-- Copyright (C) 2020 Elotheon-Arthas-EU
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
-------------------------------------------------------------------------------

local addonName, addon = ...
local utils = addon.utils
local event = addon.event
local const = addon.const
local config = addon.config
addon.handlers = addon.handlers or {}
local handlers = addon.handlers
handlers.filter = handlers.filter or utils.class("filterHandler", addon.schedule).new()
local filterHandler = handlers.filter

function filterHandler:exec(searchResultID)
    if not self.handlers then
        return
    end

    for k, v in ipairs(self.handlers) do
        if not v.doFilter(v, searchResultID) then
            return false
        end
    end

    return true
end

function filterHandler:FilterSearchResults(results)
    local filteredIDs = {}

    utils.twalk(results, function(searchResultID, _)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(searchResultID)
        if searchResultInfo then
            -- have friends
            local friendGuildChar = (searchResultInfo.numBNetFriends or 0) + (searchResultInfo.numCharFriends or 0) + (searchResultInfo.numGuildMates or 0)
            if (friendGuildChar == 0) then
                if not self:exec(searchResultID) then
                    filteredIDs[searchResultID] = true
                end
            end
        end
    end)

    utils.twalk(filteredIDs, function( _, searchResultID)
        utils.tremovebyvalue(results, searchResultID, false)
    end)
end

function filterHandler:LFGListUtil_SortSearchResults(results)
    self:FilterSearchResults(results)
    
    LFGListFrame.SearchPanel.totalResults = #results
    if #results > 0 then
        LFGListSearchPanel_UpdateResults(LFGListFrame.SearchPanel)
    end
end

function filterHandler:init()
    --dialog:registerHandlers(self)
    event:registerHandlers(self)
end

filterHandler:init()
----------------- filters ------------------
local baseFilter = utils.class("base").new()

function baseFilter:getArgs(categoryID, searchResultID)
    local cfg = config:getValue({self.__cname}, categoryID)

    if not cfg then
        return false, nil, nil
    end

    return cfg.enable or false, cfg, C_LFGList.GetSearchResultInfo(searchResultID)
end

function baseFilter:isInRange(min, max, value, ingorezero)
    if ingorezero then
        if value < min then
            return false
        end

        if value > max then
            return false
        end
    else
        if min ~= 0 and (value < min) then
            return false
        end
    
        if max ~= 0 and (value > max) then
            return false
        end
    end

    return true
end

--MythicScore
local MythicScoreFilter = utils.class("mythicscore", baseFilter).new()

function MythicScoreFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()

    if categoryID ~= const.CATEGORY_TYPE_DUNGEON then
        return true
    end

    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  searchResultInfo.leaderOverallDungeonScore or 0, false)
end

function MythicScoreFilter:init()
    filterHandler:registerHandlers(self)
end

MythicScoreFilter:init()

--DungeonFilter
local DungeonFilter = utils.class("dungeon", baseFilter).new()

function DungeonFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
    if not activityInfo then
        return true
    end
    
    local groupID = activityInfo.groupFinderActivityGroupID

    if groupID and groupID ~= 0 then
        if not cfg.group then
            return false
        end

        return cfg.group[groupID] or false
    end

    if not cfg.activity then
        return false
    end

    return cfg.activity[searchResultInfo.activityID] or false
end

function DungeonFilter:init()
    filterHandler:registerHandlers(self)
end

DungeonFilter:init()

--ClassFilter
local ClassFilter = utils.class("class", baseFilter).new()

function ClassFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local numMembers = searchResultInfo.numMembers
    local found = false
    for i = 1, numMembers do
        local name, className = C_LFGList.GetSearchResultMemberInfo(searchResultID, i)
        if cfg[className] and cfg[className] == true then
            found = true
            --return (cfg.negate and false or true)
        end
    end

    --如果找到了对应的职业
    if found then
        if cfg.negate then
            return false
        end
        
        return true
    end

    if cfg.negate then
        return true
    end

    return false
    
    --utils.dump((cfg.negate and true) or false, "not found")
    --return (cfg.negate and true) or false

    --[[
    --返回false为被考虑，返回true为不过滤
    if found then
        return (cfg.negate and true or false)
    else
        return (cfg.negate and false or true)
    end]]
end

function ClassFilter:init()
    filterHandler:registerHandlers(self)
end

ClassFilter:init()

--ItemLevelFilter
local ItemLevelFilter = utils.class("ilvl", baseFilter).new()

function ItemLevelFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  searchResultInfo.requiredItemLevel or 0, false)
end

function ItemLevelFilter:init()
    filterHandler:registerHandlers(self)
end

ItemLevelFilter:init()

--DifficultyFilter
local DifficultyFilter = utils.class("difficulty", baseFilter).new()

function DifficultyFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if categoryID ~= const.CATEGORY_TYPE_DUNGEON and 
        categoryID ~= const.CATEGORY_TYPE_RAID and 
        --categoryID ~= const.CATEGORY_TYPE_ARENA and 
        --categoryID ~= const.CATEGORY_TYPE_SKIRMISH and
        categoryID ~= const.CATEGORY_TYPE_CLASSRAID
    then
        return true
    end
    
    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    
    local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID)
    if not activityInfo then
        return true
    end
    
    local fullName = activityInfo.fullName
    local shortName = activityInfo.shortName

    local difficulty = addon:getDifficulty(searchResultInfo.activityID, fullName, shortName)

    if cfg.value ~= difficulty then
        return false
    end

    return true
end

function DifficultyFilter:init()
    filterHandler:registerHandlers(self)
end

DifficultyFilter:init()

--MembersFilter
local MembersFilter = utils.class("members", baseFilter).new()

function MembersFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end
    
    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max, searchResultInfo.numMembers or 0, false)
end

function MembersFilter:init()
    filterHandler:registerHandlers(self)
end

MembersFilter:init()

--TanksFilter
local TanksFilter = utils.class("tanks", baseFilter).new()

function TanksFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local roles = C_LFGList.GetSearchResultMemberCounts(searchResultID)

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  roles['TANK'] or 0, true)
end

function TanksFilter:init()
    filterHandler:registerHandlers(self)
end

TanksFilter:init()

--TanksFilter
local HealsFilter = utils.class("heals", baseFilter).new()

function HealsFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end
    
    local roles = C_LFGList.GetSearchResultMemberCounts(searchResultID)

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  roles['HEALER'] or 0, true)
end

function HealsFilter:init()
    filterHandler:registerHandlers(self)
end

HealsFilter:init()

--DpsFilter
local DpsFilter = utils.class("dps", baseFilter).new()

function DpsFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end
    
    local roles = C_LFGList.GetSearchResultMemberCounts(searchResultID)

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  roles['DAMAGER'] or 0, true)
end

function DpsFilter:init()
    filterHandler:registerHandlers(self)
end

DpsFilter:init()

--DefeatedFilter
local DefeatedFilter = utils.class("defeated", baseFilter).new()

function DefeatedFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()

    if categoryID ~= const.CATEGORY_TYPE_RAID then
        return true
    end

    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local encounterInfo = C_LFGList.GetSearchResultEncounterInfo(searchResultID)
    local numGroupDefeated = encounterInfo and utils.tnums(encounterInfo) or 0

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  numGroupDefeated, false)
end

function DefeatedFilter:init()
    filterHandler:registerHandlers(self)
end

DefeatedFilter:init()

--MythicScore
local PvpRatingFilter = utils.class("pvprating", baseFilter).new()

function PvpRatingFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()

    if (not 
        (categoryID == const.CATEGORY_TYPE_ARENA or 
        --categoryID == const.CATEGORY_TYPE_SKIRMISH or 
        categoryID == const.CATEGORY_TYPE_RBG 
        --categoryID == const.CATEGORY_TYPE_RBG
        ))
    then
        return true
    end

    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max,  searchResultInfo.leaderPvpRatingInfo.rating or 0, false)
end

function PvpRatingFilter:init()
    filterHandler:registerHandlers(self)
end

PvpRatingFilter:init()

--CreateTime
local CreateTimeFilter = utils.class("createtime", baseFilter).new()

function CreateTimeFilter:doFilter(searchResultID)
    local categoryID = utils.getCategory()
    local enable, cfg, searchResultInfo = self:getArgs(categoryID, searchResultID)

    if (not enable) or (not cfg) or (not searchResultInfo) then
        return true
    end

    local min = cfg.min or 0
    local max = cfg.max or 99999999

    if min > max then max = min end

    return self:isInRange(min, max, searchResultInfo.age or 0, false)
end

function CreateTimeFilter:init()
    filterHandler:registerHandlers(self)
end

CreateTimeFilter:init()

--Duplicate
local DuplicateFilter = utils.class("duplicate").new()

--用于移除相同重复显示问题
function DuplicateFilter:doFilter(searchResultID)
    local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(searchResultID);
    local searchResultInfo = C_LFGList.GetSearchResultInfo(searchResultID)
    if searchResultInfo then
        if appStatus == "applied" then
            return false
        end
    end

    return true
end

function DuplicateFilter:init()
    filterHandler:registerHandlers(self)
end

DuplicateFilter:init()
