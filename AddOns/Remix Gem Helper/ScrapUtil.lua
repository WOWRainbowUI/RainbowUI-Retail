---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants

local scrapUtil = {}
Private.ScrapUtil = scrapUtil

---@return table
function scrapUtil:GetScrappableItems()
    local scrapable = {}
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemLoc = ItemLocation:CreateFromBagAndSlot(bag, slot)
            if C_Item.DoesItemExist(itemLoc) and C_Item.CanScrapItem(itemLoc) then
                tinsert(scrapable, {
                    itemID = C_Item.GetItemID(itemLoc),
                    itemLink = C_Item.GetItemLink(itemLoc)
                })
            end
        end
    end
    return scrapable
end
