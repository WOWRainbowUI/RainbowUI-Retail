---@class RemixGemHelperPrivate
local Private = select(2, ...)

---@class CacheItemInfo
---@field name string
---@field link string
---@field quality string
---@field icon number
---@field type number
---@field subType number
---@field description string

local cache = {
    itemInfo = {}
}
Private.Cache = cache

local function itemLinkToDescription(itemLink)
    local data = C_TooltipInfo.GetHyperlink(itemLink)
    local description = ""
    if data and data.lines then
        for _, line in ipairs(data.lines) do
            local lText = line.leftText or ""
            local rText = line.rightText or ""
            description = string.format("%s%s %s\n", description, lText, rText)
        end
    end
    return description
end

---@param itemID number
---@param loadedCallback fun(itemID:integer)|?
function cache:CacheItemInfo(itemID, loadedCallback)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
        local itemInfo = { C_Item.GetItemInfo(item:GetItemLink()) }
        self.itemInfo[itemID] = {
            name = itemInfo[1],
            link = itemInfo[2],
            quality = itemInfo[3],
            icon = itemInfo[10],
            type = itemInfo[12],
            subType = itemInfo[13],
            description = itemLinkToDescription(item:GetItemLink())
        }
        if loadedCallback and type(loadedCallback) == "function" then
            loadedCallback(self.itemInfo[itemID])
        end
    end)
end

---@param itemID number
---@param loadedCallback fun(itemID:integer)|?
---@return CacheItemInfo
function cache:GetItemInfo(itemID, loadedCallback)
    local itemInfo = self.itemInfo[itemID]
    if not itemInfo then
        self:CacheItemInfo(itemID, loadedCallback)
    end
    return itemInfo
end
