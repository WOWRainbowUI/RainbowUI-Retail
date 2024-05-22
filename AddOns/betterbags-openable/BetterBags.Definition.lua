local const = {}

-- ItemData contains all the information about an item in a bag or bank.
---@class (exact) ItemData
---@field basic boolean
---@field itemInfo ExpandedItemInfo
---@field containerInfo ContainerItemInfo
---@field questInfo ItemQuestInfo
---@field bagid number
---@field slotid number
---@field slotkey string
---@field isItemEmpty boolean
---@field kind BagKind
---@field newItemTime number
---@field stacks number
---@field stackedOn string
---@field stackedCount number
---@field itemLinkInfo ItemLinkInfo
---@field itemHash string
---@field bagName string
---@field forceClear boolean
---@field nextStack string
local itemDataProto = {}

-- ItemInfo is the information about an item that is returned by GetItemInfo.
---@class (exact) ExpandedItemInfo
---@field itemID number
---@field itemGUID string
---@field itemName string
---@field itemLink string
---@field itemQuality Enum.ItemQuality
---@field itemLevel number
---@field itemMinLevel number
---@field itemType string
---@field itemSubType string
---@field itemStackCount number
---@field itemEquipLoc string
---@field itemTexture number
---@field sellPrice number
---@field classID Enum.ItemClass
---@field subclassID number
---@field bindType Enum.ItemBind
---@field expacID ExpansionType
---@field setID number
---@field isCraftingReagent boolean
---@field effectiveIlvl number
---@field isPreview boolean
---@field baseIlvl number
---@field itemIcon? number
---@field isBound boolean
---@field isLocked boolean
---@field isNewItem boolean
---@field currentItemCount number
---@field category string
---@field currentItemLevel number
---@field equipmentSet string|nil

---@enum BagKind
const.BAG_KIND = {
	UNDEFINED = -1,
	BACKPACK = 0,
	BANK = 1,
	REAGENT_BANK = 2
}

---@enum ExpansionType
const.EXPANSION_TYPE = {
	LE_EXPANSION_CLASSIC = 0,
	LE_EXPANSION_BURNING_CRUSADE = 1,
	LE_EXPANSION_WRATH_OF_THE_LICH_KING = 2,
	LE_EXPANSION_CATACLYSM = 3,
	LE_EXPANSION_MISTS_OF_PANDARIA = 4,
	LE_EXPANSION_WARLORDS_OF_DRAENOR = 5,
	LE_EXPANSION_LEGION = 6,
	LE_EXPANSION_BATTLE_FOR_AZEROTH = 7,
	LE_EXPANSION_SHADOWLANDS = 8,
	LE_EXPANSION_DRAGONFLIGHT = 9
}

-- ItemLinkInfo contains all the information parsed from an item link.
---@class (exact) ItemLinkInfo
---@field itemID number
---@field enchantID string
---@field gemID1 string
---@field gemID2 string
---@field gemID3 string
---@field gemID4 string
---@field suffixID string
---@field uniqueID string
---@field linkLevel string
---@field specializationID string
---@field modifiersMask string
---@field itemContext string
---@field bonusIDs string[]
---@field modifierIDs string[]
---@field relic1BonusIDs string[]
---@field relic2BonusIDs string[]
---@field relic3BonusIDs string[]
---@field crafterGUID string
---@field extraEnchantID string

---@class (exact) BetterBags

---@class Categories
local categories = {}

-- RegisterCategoryFunction registers a function that will be called to get the category name for all items.
-- Registered functions are only called once per item, and the result is cached. Registering a new
-- function will clear the cache. Do not abuse this API,
-- as it has the potential to cause a significant amount of CPU usage the first time an item is rendered,
-- which at game load time, is every item.
---@param id string A unique identifier for the category function. This is not used for the category name!
---@param func fun(data: ItemData): string|nil The function to call to get the category name for an item.
function categories:RegisterCategoryFunction(id, func)
end

-- AddItemToCategory adds an item to a custom category by its ItemID.
---@param id number The ItemID of the item to add to a custom category.
---@param category string The name of the custom category to add the item to.
function categories:AddItemToCategory(id, category)
end

---@class Config
local config = {}

-- AddPluginConfig adds a plugin's configuration to the BetterBags configuration.
---@param name string
---@param opts AceConfig.OptionsTable
function config:AddPluginConfig(name, opts)
end
