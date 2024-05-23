---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants
local addon = Private.Addon

---@class SocketTypeInfo
---@field name string
---@field icon integer
---@field color colorRGB

local gemUtil = {
    owned_gems = {}
}
Private.GemUtil = gemUtil

---@param key number|string|?
---@return SocketTypeInfo|?
function gemUtil:GetSocketTypeInfo(key)
    if not key then return end
    if type(key) == "number" then
        key = const.SOCKET_TYPES_INDEX[key]
    end
    local category = const.SOCKET_TYPE_INFO[key]
    return category
end

---@param key number|string|?
---@return string
function gemUtil:GetSocketTypeName(key)
    local typeInfo = self:GetSocketTypeInfo(key)
    return typeInfo and typeInfo.name or "All"
end

---@param socketTypeName string
---@return integer usedSlots
---@return integer maxSlots
---@return integer|? freeEquipmentSlot
---@return integer|? freeSocketSlot
function gemUtil:GetSocketsInfo(socketTypeName)
    local usedSlots, maxSlots = 0, 0
    local freeEquipmentSlot, freeSocketSlot, freeIlvl
    for _, equipmentSlot in ipairs(const.SOCKET_EQUIPMENT_SLOTS) do
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(equipmentSlot)
        if itemLoc:IsValid() then
            local itemLink = C_Item.GetItemLink(itemLoc)
            if itemLink then
                local itemStats = C_Item.GetItemStats(itemLink)
                if itemStats then
                    for stat, itemMaxSlots in pairs(itemStats) do
                        if stat:match("EMPTY_SOCKET_" .. socketTypeName:upper()) then
                            local itemGems = gemUtil:GetItemGems(itemLink)
                            local itemUsedSlots = #itemGems
                            maxSlots = maxSlots + itemMaxSlots
                            usedSlots = usedSlots + itemUsedSlots

                            if itemUsedSlots < itemMaxSlots then
                                local itemLevel = C_Item.GetCurrentItemLevel(itemLoc)
                                if not freeEquipmentSlot or freeIlvl < itemLevel then
                                    freeEquipmentSlot = equipmentSlot
                                    freeIlvl = itemLevel
                                    for slotIndex = 1, 3 do
                                        local fss = itemGems.freeSpots[slotIndex]
                                        if fss then
                                            freeSocketSlot = slotIndex
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return usedSlots, maxSlots, freeEquipmentSlot, freeSocketSlot
end

---@class GemItemInfo
---@field hyperlink string
---@field stackCount number
---@field itemID number

---@param dataTable table
---@param itemInfo GemItemInfo|ContainerItemInfo
---@param locType "BAG_GEM"|"BAG_SOCKET"|"EQUIP_SOCKET"|"UNCOLLECTED"
---@param locIndex integer|?
---@param locSlot integer|?
---@param gemSlot integer|?
function gemUtil:AddGemData(dataTable, itemInfo, locType, locIndex, locSlot, gemSlot)
    if type(itemInfo) ~= "table" then return end
    local itemType = select(6, C_Item.GetItemInfoInstant(itemInfo.hyperlink))
    if itemType == 3 and self:GetGemSocketType(itemInfo.itemID) then
        for i = 1, itemInfo.stackCount do
            tinsert(dataTable, {
                itemID = itemInfo.itemID,
                locType = locType,
                locIndex = locIndex,
                locSlot = locSlot,
                gemType = self:GetSocketTypeName(self:GetGemSocketType(itemInfo.itemID)),
                gemSlot = gemSlot
            })
            Private.Cache:CacheItemInfo(itemInfo.itemID)
        end
    else
        local gems = self:GetItemGems(itemInfo.hyperlink)
        if #gems < 1 then return end
        for gemSlot, gemID in ipairs(gems) do
            if type(gemID) == "number" then
                local cacheInfo = Private.Cache:GetItemInfo(gemID)
                if cacheInfo and cacheInfo.link then
                    local hyperlink = cacheInfo.link
                    self:AddGemData(dataTable, {
                        itemID = gemID,
                        stackCount = 1,
                        hyperlink = hyperlink,
                    }, "BAG_SOCKET", locIndex, locSlot, gemSlot)
                end
            end
        end
    end
end

function gemUtil:RefreshOwnedGems()
    wipe(self.owned_gems)
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            self:AddGemData(self.owned_gems, C_Container.GetContainerItemInfo(bag, slot), "BAG_GEM", bag, slot)
        end
    end
    for _, itemSlot in ipairs(const.SOCKET_EQUIPMENT_SLOTS) do
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(itemSlot)

        if itemLoc:IsValid() then
            local itemLink = C_Item.GetItemLink(itemLoc)
            if itemLink then
                for gemIndex = 1, 3 do
                    local gemName, gemLink = C_Item.GetItemGem(itemLink, gemIndex)
                    if gemName and gemLink then
                        self:AddGemData(self.owned_gems, {
                            itemName = gemName,
                            itemID = C_Item.GetItemInfoInstant(gemLink),
                            stackCount = 1,
                            hyperlink = gemLink
                        }, "EQUIP_SOCKET", itemSlot, gemIndex)
                    end
                end
            end
        end
    end
end

---@param itemID integer
---@return string|?
function gemUtil:GetGemSocketType(itemID)
    return const.GEM_SOCKET_TYPE[itemID]
end

function gemUtil:GetItemGems(itemLink)
    local _, linkOptions = LinkUtil.ExtractLink(itemLink)
    local item = { strsplit(":", linkOptions) }
    local gemsList = {
        freeSpots = {}
    }
    for i = 1, 4 do
        local gem = tonumber(item[i + 2])
        if gem then
            tinsert(gemsList, gem)
        else
            gemsList.freeSpots[i] = true
        end
    end
    return gemsList
end

local function isMatchingFilter(itemID, filter)
    filter = filter:gsub("%%", "%%%%"):gsub("%+", "%%+")
    local gemItemInfo = Private.Cache:GetItemInfo(itemID)
    local gemNameAndDesc = (gemItemInfo and gemItemInfo.name or "") ..
        (gemItemInfo and gemItemInfo.description or ""):lower()
    if not (filter and not gemNameAndDesc:match(filter)) then
        return true
    end
    return false
end

---@param socketTypeFilter string|number|?
---@param nameFilter string|?
---@return table
function gemUtil:GetFilteredGems(socketTypeFilter, nameFilter)
    local validGems = {}
    self:RefreshOwnedGems()
    if nameFilter then nameFilter = nameFilter:lower() end
    if type(socketTypeFilter) == "number" then
        socketTypeFilter = self:GetSocketTypeName(socketTypeFilter)
    end
    socketTypeFilter = socketTypeFilter or "ALL"
    socketTypeFilter = socketTypeFilter:upper()
    for _, socketType in ipairs(const.SOCKET_TYPES_INDEX) do
        validGems[socketType] = {}
    end
    for _, gemInfo in pairs(self.owned_gems) do
        local gemType = self:GetGemSocketType(gemInfo.itemID)
        if socketTypeFilter == "ALL" or gemType == socketTypeFilter then
            if gemType ~= "PRIMORDIAL" or addon:GetDatabaseValue("show_primordial") then
                if isMatchingFilter(gemInfo.itemID, nameFilter) then
                    tinsert(validGems[gemType], gemInfo)
                end
            end
        end
    end

    if addon:GetDatabaseValue("show_unowned") then
        for gemItemID, gemType in pairs(const.GEM_SOCKET_TYPE) do
            if socketTypeFilter == "ALL" or gemType == socketTypeFilter then
                if isMatchingFilter(gemItemID, nameFilter) then
                    local dupeID = false
                    for _, gemInfo in ipairs(self.owned_gems) do
                        if gemInfo.itemID == gemItemID then
                            dupeID = true
                            break
                        end
                    end
                    if (not dupeID) and (gemType ~= "PRIMORDIAL" or addon:GetDatabaseValue("show_primordial")) then
                        local cacheInfo = Private.Cache:GetItemInfo(gemItemID)
                        if cacheInfo and cacheInfo.link then
                            local hyperlink = cacheInfo.link
                            self:AddGemData(validGems[gemType],
                                {
                                    itemID = gemItemID,
                                    stackCount = 1,
                                    hyperlink = hyperlink
                                }, "UNCOLLECTED")
                        end
                    end
                end
            end
        end
    end
    return validGems
end

function gemUtil:GetGemStats(description)
    local stat = ""
    if description and type(description) == "string" then
        stat = description:match("%++[^\n]+")
    end
    return stat
end
