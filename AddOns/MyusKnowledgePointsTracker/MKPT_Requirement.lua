local _, MKPT_env, _ = ...

local Utils = MKPT_env.Utils

local MKPT_Requirement = {}
MKPT_Requirement.__index = MKPT_Requirement
MKPT_env.MKPT_Requirement = MKPT_Requirement

--- Represents a requirement to be met in order to
---@class MKPT_Requirement
function MKPT_Requirement:New()
  local o = {}
  setmetatable(o, self)
  return o
end

function MKPT_Requirement:MeetsRequirement()
  error("MeetsRequirement method not implemented", 2)
end

---@class MKPT_QuestRequirement : MKPT_Requirement
---@field questId number - QuestId of the required quest to be completed
local MKPT_QuestRequirement = MKPT_Requirement:New()
MKPT_env.MKPT_QuestRequirement = MKPT_QuestRequirement

function MKPT_QuestRequirement:New(questId)
  local o = MKPT_Requirement.New()
  setmetatable(o, self)

  C_QuestLog.RequestLoadQuestByID(questId)
  self.__index = self
  o.questId = questId

  return o
end

---@return true if quest is completed, false if not
function MKPT_QuestRequirement:MeetsRequirement()
  return C_QuestLog.IsQuestFlaggedCompleted(self.questId)
end

---Gets quest name concatenated with ✓ for completed quests and X otherwise
---@return string
function MKPT_QuestRequirement:GetDescription()
  local icon
  if self:MeetsRequirement() then
    icon = CreateAtlasMarkup("groupfinder-icon-greencheckmark", 12, 12)
  else
    icon = CreateAtlasMarkup("groupfinder-icon-redx", 12, 12)
  end

  local questName = C_QuestLog.GetTitleForQuestID(self.questId)

  if not questName then
    C_QuestLog.RequestLoadQuestByID(self.questId)
    questName = "Id "..self.questId
  end

  return CreateAtlasMarkup("Quest-Campaign-Available", 12, 12).." "..questName.." "..icon
end

---@class MKPT_CurrencyRequirement : MKPT_Requirement
---@field currencyId number - Id of the required currency
---@field requiredQuantity number - Quantity required to meet the requirement
local MKPT_CurrencyRequirement = MKPT_Requirement:New()
MKPT_env.MKPT_CurrencyRequirement = MKPT_CurrencyRequirement

function MKPT_CurrencyRequirement:New(currencyId, requiredQuantity)
  local o = MKPT_Requirement.New()
  setmetatable(o, self)
  self.__index = self

  o.currencyId = currencyId
  o.requiredQuantity = requiredQuantity

  return o
end

---@return true if the required quantity of currency is available, false otherwise
function MKPT_CurrencyRequirement:MeetsRequirement()
  local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currencyId)
  return currencyInfo.quantity >= self.requiredQuantity
end

---Gets Currency name, contatenated with it's current quantity / required quantity
---@return string
function MKPT_CurrencyRequirement:GetDescription()
  local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.currencyId)

  local currencyDescription = CreateSimpleTextureMarkup(currencyInfo.iconFileID, 13, 13).." "..currencyInfo.name

  local currentQuantityStr
  if self:MeetsRequirement() then
    currentQuantityStr = Utils.CatchUpTextColor(currencyInfo.quantity)
  else
    currentQuantityStr = Utils.RequirementsNotMetColor(currencyInfo.quantity)
  end

  return currencyDescription..": "..currentQuantityStr.."/"..self.requiredQuantity
end

---@class MKPT_RenownRequirement : MKPT_Requirement
---@field majorFactionId number - Id of the required currency
---@field requiredLevel number - Renown level required
local MKPT_RenownRequirement = MKPT_Requirement:New()
MKPT_env.MKPT_RenownRequirement = MKPT_RenownRequirement

---@param majorFactionId number - Id of the required currency
---@param requiredLevel number - Renown level required
function MKPT_RenownRequirement:New(majorFactionId, requiredLevel)
  local o = MKPT_Requirement.New()
  setmetatable(o, self)
  self.__index = self

  o.majorFactionId = majorFactionId
  o.requiredLevel = requiredLevel

  return o
end

---@return true if the required level of renown is met, false otherwise
function MKPT_RenownRequirement:MeetsRequirement()
  local renownLevel = C_MajorFactions.GetCurrentRenownLevel(self.majorFactionId) or 0
  return renownLevel >= self.requiredLevel
end

---Gets Renown faction name, contatenated with its' current level / required level
---@return string
function MKPT_RenownRequirement:GetDescription()
  local renownInfo = C_MajorFactions.GetMajorFactionData(self.majorFactionId)

  local renownFactionName
  local renownCurrentLevel

  if renownInfo then
    renownFactionName = renownInfo.name
    renownCurrentLevel = renownInfo.renownLevel
  else
    renownFactionName = "RenownFactionId: "..self.majorFactionId
    renownCurrentLevel = C_MajorFactions.GetCurrentRenownLevel(self.majorFactionId) or 0
  end

  local currentLevelStr
  if self:MeetsRequirement() then
    currentLevelStr = Utils.CatchUpTextColor(renownCurrentLevel)
  else
    currentLevelStr = Utils.RequirementsNotMetColor(renownCurrentLevel)
  end

  return renownFactionName..": "..currentLevelStr.."/"..self.requiredLevel
end

---@class MKPT_ItemRequirement : MKPT_Requirement
---@field itemId number - Id of the required item
---@field requiredQuantity number - Required quantity of the item
local MKPT_ItemRequirement = MKPT_Requirement:New()
MKPT_env.MKPT_ItemRequirement = MKPT_ItemRequirement

---@param itemId number - Id of the required item
---@param requiredQuantity number - Required quantity of the item
function MKPT_ItemRequirement:New(itemId, requiredQuantity)
  local o = MKPT_Requirement.New()
  setmetatable(o, self)
  self.__index = self

  if not C_Item.IsItemDataCachedByID(itemId) then
    C_Item.RequestLoadItemDataByID(itemId)
  end

  o.itemId = itemId
  o.requiredQuantity = requiredQuantity

  return o
end

---@return true if the required level of renown is met, false otherwise
function MKPT_ItemRequirement:MeetsRequirement()
  local itemCount = C_Item.GetItemCount(self.itemId)
  return itemCount >= self.requiredQuantity
end

---Gets Item name, contatenated with its' current quantity / required quantity
---@return string
function MKPT_ItemRequirement:GetDescription()
  local itemName = C_Item.GetItemNameByID(self.itemId) or ("Item id: "..self.itemId)
  local itemCount = C_Item.GetItemCount(self.itemId)
  local icon = C_Item.GetItemIconByID(self.itemId)

  local quantityStr
  if self:MeetsRequirement() then
    quantityStr = Utils.CatchUpTextColor(itemCount)
  else
    quantityStr = Utils.RequirementsNotMetColor(itemCount)
  end
  return CreateSimpleTextureMarkup(icon, 13, 13).." "..itemName.." "..quantityStr.."/"..self.requiredQuantity
end

---@class MKPT_KpItemRequirement : MKPT_Requirement
---@field kpItem MKPT_Item - a MKPT_Item object that is required
local MKPT_KpItemRequirement = MKPT_Requirement:New()
MKPT_env.MKPT_KpItemRequirement = MKPT_KpItemRequirement

---@param kpItem MKPT_Item - Add the MKPT_Item as a requirement
function MKPT_KpItemRequirement:New(kpItem)
  local o = MKPT_Requirement.New()
  setmetatable(o, self)
  self.__index = self

  o.kpItem = kpItem
  kpItem:GetFormattedName()

  return o
end

---@return boolean - true if the kpItem have been colected, false otherwise
function MKPT_KpItemRequirement:MeetsRequirement()
  return self.kpItem:GetRemainingKnowledgePoints() == 0
end

---Gets the MKPT_Item name with a green/red checkmark if it's completed/not completed
---@return string
function MKPT_KpItemRequirement:GetDescription()
  local icon
  if self:MeetsRequirement() then
    icon = CreateAtlasMarkup("groupfinder-icon-greencheckmark", 12, 12)
  else
    icon = ""
  end

  return self.kpItem:GetCategoryIcon().." "..(self.kpItem:GetFormattedName() or "???").." "..icon
end
