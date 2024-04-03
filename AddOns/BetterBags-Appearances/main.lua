-- Variables --
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, "BetterBags - Appearances requires BetterBags")

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')

---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

---@class Appearances: AceModule
local Appearances = BetterBags:NewModule('Appearances')

local nonEquippableTypes = {
    ["INVTYPE_NON_EQUIP_IGNORE"] = true,
    ["INVTYPE_TRINKET"] = true,
    ["INVTYPE_FINGER"] = true,
    ["INVTYPE_NECK"] = true
}

-- Create a hidden tooltip for scanning
local scanTooltip = CreateFrame("GameTooltip", "BindCheckTooltipScanner", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

-- Functions --
-- On plugin load, wipe the categories we've added
function Appearances:OnInitialize()
    categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Learnable"), "ff00ff00"))
    categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Tradable"), "ff00ff00"))
    categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Sellable"), "ff00ff00"))
end

-- Debug dump functions
-- @debug@
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function printTable(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            printTable(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))      
        else
            print(formatting .. v)
        end
    end
end
-- @end-debug@

function isEquipabble(itemInfo)
    return not nonEquippableTypes[itemInfo.itemEquipLoc]
end

function canLearnAppearance(data)
    local canCollect = false
    local itemLink = C_Container.GetContainerItemLink(data.bagid, data.slotid)
    local _, _, transmogSource, _ = C_Transmog.CanTransmogItem(itemLink)
    if not transmogSource then
        return nil
    end
    local itemAppearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
    if sourceID then
        _, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)
        local sources = C_TransmogCollection.GetAllAppearanceSources(itemAppearanceID)
        for _, v in pairs(sources) do
            local _,_,_,_,isCollected = C_TransmogCollection.GetAppearanceSourceInfo(v)
            -- If any source is collected, we can't collect it.
            if isCollected then
                canCollect = false
                break
            end
        end
        return canCollect
    end
end

function checkItemBindStatus(itemLink)
    scanTooltip:ClearLines() -- Reset the tooltip
    scanTooltip:SetHyperlink(itemLink) -- Set the item's hyperlink to fill the tooltip with item info

    for i = 2, scanTooltip:NumLines() do -- Start at 2 to skip the item name
        local line = _G["BindCheckTooltipScannerTextLeft" .. i]:GetText()
        if line then
            if line:find(ITEM_BIND_ON_EQUIP) then
                return "BoE"
            elseif line:find(ITEM_ACCOUNTBOUND) or line:find(ITEM_BIND_TO_ACCOUNT) or line:find(ITEM_BIND_TO_BNETACCOUNT) or line:find(ITEM_BNETACCOUNTBOUND) then
                return "BoA"
            elseif line:find(ITEM_BIND_ON_PICKUP) then
                return "BoP"
            end
        end
    end
    return "None" -- No bind information found
end

-- Register the category function
categories:RegisterCategoryFunction("MogCategorization", function(data)
    -- If we can't ever equip it, don't bother.
    if not isEquipabble(data.itemInfo) then
        return nil
    end

    -- If it's the Underlight Angler artifact, also don't bother.
    if data.itemInfo.itemID == 133755 then
        return nil
    end

    local bindType = checkItemBindStatus(data.itemInfo.itemLink)

    -- Current character can't learn the appearance for whatever reason
    if not canLearnAppearance(data) then
        if bindType == "BoE" or bindType == "BoA" then
            -- If BoE or BoA, it should be categorized in "Mog - Tradable"
            return WrapTextInColorCode(L:G("Mog - Tradable"), "ff00ff00")
        end

        -- If BoP, it should be categorized in "Mog - Sell"
        if bindType == "BoP" then
            return WrapTextInColorCode(L:G("Mog - Sellable"), "ff00ff00")
        end
    end

    if canLearnAppearance(data) then
        return WrapTextInColorCode(L:G("Mog - Learnable"), "ff00ff00")
    end
end)
