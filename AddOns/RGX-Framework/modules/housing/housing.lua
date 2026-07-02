--=====================================================================================
-- RGX-Framework | RGXHousing
-- Housing progression and decor collection callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local Housing = {
    _eventsInit = false,
    _onFavorGained = {},
    _onLevelUp = {},
    _onRewards = {},
    _onDecorCollected = {},
    houseFavorByGUID = {},
    houseLevelByGUID = {},
    lastKnownHouseLevel = nil,
    lastDecorCollectAt = 0,
}

local DECOR_ITEM_TYPE = 3
local DECOR_DEDUPE_SECONDS = 0.50

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    list[#list + 1] = fn
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXHousing] Callback error: " .. tostring(err)) end
    end
end

local function IsDecor(itemType)
    if itemType == DECOR_ITEM_TYPE then return true end
    return type(itemType) == "string" and string.lower(itemType) == "decor"
end

function Housing:OnFavorGained(fn) return AddCb(self._onFavorGained, fn) end
function Housing:OnLevelUp(fn) return AddCb(self._onLevelUp, fn) end
function Housing:OnRewards(fn) return AddCb(self._onRewards, fn) end
function Housing:OnDecorCollected(fn) return AddCb(self._onDecorCollected, fn) end

function Housing:OnCurrentHouseInfo(houseInfo)
    if type(houseInfo) ~= "table" then return end
    local guid = houseInfo.houseGUID or "current"
    local favor = tonumber(houseInfo.houseFavor or houseInfo.levelFavor)
    local level = tonumber(houseInfo.houseLevel or houseInfo.level)
    if favor then self.houseFavorByGUID[guid] = favor end
    if level then
        self.houseLevelByGUID[guid] = level
        self.lastKnownHouseLevel = level
    end
end

function Housing:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("CURRENT_HOUSE_INFO_RECIEVED", function(_, info) Housing:OnCurrentHouseInfo(info) end, "RGXHousing_InfoReceived")
    RGX:RegisterEvent("CURRENT_HOUSE_INFO_UPDATED", function(_, info) Housing:OnCurrentHouseInfo(info) end, "RGXHousing_InfoUpdated")

    RGX:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED", function(_, info)
        if type(info) ~= "table" then return end
        local guid = info.houseGUID or "current"
        local newFavor = tonumber(info.houseFavor) or 0
        local oldFavor = Housing.houseFavorByGUID[guid]
        Housing.houseFavorByGUID[guid] = newFavor
        if oldFavor ~= nil and newFavor > oldFavor then
            Fire(Housing._onFavorGained, newFavor, oldFavor, guid, info)
        end
    end, "RGXHousing_Favor")

    RGX:RegisterEvent("HOUSE_LEVEL_CHANGED", function(_, info)
        if type(info) ~= "table" then return end
        local newLevel = tonumber(info.level) or 0
        local oldLevel = Housing.lastKnownHouseLevel
        Housing.lastKnownHouseLevel = newLevel
        if oldLevel ~= nil and newLevel > oldLevel then
            Fire(Housing._onLevelUp, newLevel, oldLevel, info)
        end
    end, "RGXHousing_Level")

    RGX:RegisterEvent("RECEIVED_HOUSE_LEVEL_REWARDS", function(_, level, rewards)
        Fire(Housing._onRewards, level, rewards)
    end, "RGXHousing_Rewards")

    RGX:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED", function(_, itemType, itemName, icon)
        if not IsDecor(itemType) then return end
        local now = GetTime and GetTime() or 0
        if Housing.lastDecorCollectAt and (now - Housing.lastDecorCollectAt) < DECOR_DEDUPE_SECONDS then return end
        Housing.lastDecorCollectAt = now
        Fire(Housing._onDecorCollected, itemType, itemName, icon)
    end, "RGXHousing_Decor")
end

_G.RGXHousing = Housing
RGX:RegisterModule("housing", Housing)
