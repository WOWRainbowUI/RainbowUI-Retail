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


---@class CacheSpellInfo
---@field name string
---@field link string
---@field icon number
---@field description string

local cache = {
    itemInfo = {},
    spellInfo = {}
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
---@param loadedCallback fun(itemInfo:CacheItemInfo)|?
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
---@param loadedCallback fun(itemInfo:CacheItemInfo)|?
---@return CacheItemInfo|?
function cache:GetItemInfo(itemID, loadedCallback)
    if not self.itemInfo[itemID] then
        self:CacheItemInfo(itemID, loadedCallback)
    elseif loadedCallback and type(loadedCallback) == "function" then
        loadedCallback(self.itemInfo[itemID])
    end
    return self.itemInfo[itemID]
end

---@param spellID number
---@param loadedCallback fun(spellInfo:CacheSpellInfo)|?
---@return CacheItemInfo|?
function cache:GetSpellInfo(spellID, loadedCallback)
    if not self.spellInfo[spellID] then
        self:CacheSpellInfo(spellID, loadedCallback)
    elseif loadedCallback and type(loadedCallback) == "function" then
        loadedCallback(self.spellInfo[spellID])
    end
    return self.spellInfo[spellID]
end

---@param spellID number
---@param loadedCallback fun(spellInfo:CacheSpellInfo)|?
function cache:CacheSpellInfo(spellID, loadedCallback)
    local spell = Spell:CreateFromSpellID(spellID)
    spell:ContinueOnSpellLoad(function()
        self.spellInfo[spellID] = {
            name = spell:GetSpellName(),
            link = GetSpellLink(spellID),
            icon = GetSpellTexture(spellID),
            description = spell:GetSpellDescription(),
        }
        if loadedCallback and type(loadedCallback) == "function" then
            loadedCallback(self.spellInfo[spellID])
        end
    end)
end
