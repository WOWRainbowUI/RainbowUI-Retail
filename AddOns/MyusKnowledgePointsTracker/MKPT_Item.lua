local _, MKPT_env, _ = ...

---@class MKPT_Item - Defines an source of knowledge points
---@field profession MKPT_Profession - Profession which this kp belongs to
---@field itemId number - itemId of the item represented by this kpSource
---@field questId table - array of questIds for this kpSource, can be a hidden quest id to track completion (treasure collected) or an actual quest (DMF/Trainer quest)
---@field waypoint table - table containing mapID and coordinates for the kp location
---@field atlasIcon string - atlasIcon to override default categoryIcon
---@field kp number - amount of kp granted by this source
---@field text string - extra description for this kpSource
local MKPT_Item = {}
MKPT_env.MKPT_Item = MKPT_Item

local Utils = MKPT_env.Utils
local idIdx = {}
local questIdIdx = {}
local spellIdIdx = {}

MKPT_Item.FindById = function(entryId)
  return idIdx[entryId]
end

MKPT_Item.FindByQuestId = function(questId)
  return questIdIdx[questId]
end

MKPT_Item.FindBySpellId = function(spellId)
  return spellIdIdx[spellId]
end

MKPT_Item.GetTrackedItem = function()
  return MKPT_env.trackedItem
end

function MKPT_Item:New(item)
  item = item or {}
  setmetatable(item, self)
  self.__index = self

  if item.spell then spellIdIdx[item.spell] = self end
  if item:GetId() then idIdx[item:GetId()] = self end
  for _, questId in ipairs(item.questId or {}) do
    questIdIdx[questId] = item
  end

  return item
end

function MKPT_Item:AddRequirement(requirement)
  if not self.requirements then self.requirements = {} end

  table.insert(self.requirements, requirement)

  return self
end

function MKPT_Item:GetId()
  return self.itemId
end

function MKPT_Item:IsUnique()
  return false
end

function MKPT_Item:IsCatchUp()
  return false
end

function MKPT_Item:Show()
  return self.profession.expanded and self.profession:IsLearned() and self:GetRemainingKnowledgePoints() > 0
end

function MKPT_Item:GetFormattedName()
  local name = self:GetName()
  if not name then return nil end

  if not self:MeetRequirements() then
    return Utils.RequirementsNotMetColor(name)
  elseif self:IsUnique() then
    return Utils.UniqueTextColor(name)
  elseif self:IsCatchUp() then
    return Utils.CatchUpTextColor(name)
  else
    return Utils.WeeklyTextColor(name)
  end
end

function MKPT_Item:GetName()
  local name = C_Item.GetItemNameByID(self.itemId)
  if not name then
    C_Item.RequestLoadItemDataByID(self.itemId)
  end
  return name
end

function MKPT_Item:GetIcon()
  if self.icon then return self.icon end

  self.icon = select(5, C_Item.GetItemInfoInstant(self.itemId))

  return self.icon
end

function MKPT_Item:GetCategoryIcon()
  return CreateAtlasMarkup(self.atlasIcon, 16, 16)
end

function MKPT_Item:GetRemainingKnowledgePoints()
  local questCount = #self.questId

  for _, questId in ipairs(self.questId) do
    if C_QuestLog.IsQuestFlaggedCompleted(questId) then
      questCount = questCount - 1
    end
  end

  return questCount * self.kp
end

function MKPT_Item:IsAvailable()
  return self.profession:IsLearned() and self:GetRemainingKnowledgePoints() > 0
end

function MKPT_Item:MeetRequirements()
  for _, requirement in ipairs(self.requirements or {}) do
    if not requirement:MeetsRequirement() then
      return false
    end
  end
  return true
end

function MKPT_Item:ToggleTrack()
  if self:IsHighlighted() then
    self:Untrack()
    return nil
  end

  local untracked = MKPT_env.trackedItem
  if untracked then untracked:Untrack() end

  local wp = self.waypoint
  if wp then
    local mapPoint = UiMapPoint.CreateFromCoordinates(wp.map, wp.x, wp.y)
    C_Map.SetUserWaypoint(mapPoint)
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    local _, isTomTomLoaded = C_AddOns.IsAddOnLoaded("TomTom")
    if isTomTomLoaded and TomTom then
      local itemName = self:GetName() or "Item not cached"
      self.tomtomUid = TomTom:AddWaypoint(wp.map, wp.x, wp.y, { title = itemName, persistent = false, source = "MKPT_WA" })
    end
  end
  MKPT_env.trackedItem = self
  return untracked
end

function MKPT_Item:Untrack()
  if MKPT_env.trackedItem ~= self then return end

  C_SuperTrack.SetSuperTrackedUserWaypoint(false)
  C_Map.ClearUserWaypoint()
  if TomTom and self.tomtomUid then
    TomTom:RemoveWaypoint(self.tomtomUid)
  end
  MKPT_env.trackedItem = nil
end

function MKPT_Item:IsHighlighted()
  return MKPT_env.trackedItem == self
end

function MKPT_Item:GetDescription()
  if not self.waypoint then
    return self.text or "Location unknown"
  end

  local requirementsText = self.text and self.text.."\n\n" or ""
  if self.requirements then
    for _, v in ipairs(self.requirements) do
      requirementsText = requirementsText..v:GetDescription().."\n"
    end
    requirementsText = requirementsText.."\n"
  end

  local name = self:GetName() or "Not loaded yet"
  local mapInfo = C_Map.GetMapInfo(self.waypoint.map)
  return requirementsText..string.format("%s\n%s - x:%.2f y:%.2f", name, mapInfo.name, self.waypoint.x * 100, self.waypoint.y * 100)
end

local MKPT_CatchUp = MKPT_Item:New()
MKPT_env.MKPT_CatchUp = MKPT_CatchUp

function MKPT_CatchUp:GetRemainingKnowledgePoints()
  local weekly = self.profession:GetCatchUpCurrencyLeft()
  for _, requirement in ipairs(self.requirements or {}) do
    if requirement.kpItem then
      weekly = weekly - requirement.kpItem:GetRemainingKnowledgePoints()
    end
  end
  return weekly
end

function MKPT_CatchUp:GetName()
  return MKPT_Item.GetName(self)
end

function MKPT_CatchUp:IsCatchUp()
  return true
end

function MKPT_CatchUp:Show()
  return not MKPT_env.db.config.hideCatchUp and MKPT_Item.Show(self)
end

function MKPT_CatchUp:MeetRequirements()
  return MKPT_Item.MeetRequirements(self)
end

function MKPT_CatchUp:GetDescription()
  local requirementsText = ""

  if self.text then
    requirementsText = self.text.."\n"
  end

  if self.requirements then
    local lockedText = self:MeetRequirements() and "\nUnlocked\n" or "\nFinish to unlock:\n"
    requirementsText = requirementsText..lockedText
    for _, v in ipairs(self.requirements) do
      requirementsText = requirementsText..v:GetDescription().."\n"
    end
    
  end

  return requirementsText
end

local MKPT_PatronCatchUp = MKPT_CatchUp:New()
MKPT_env.MKPT_PatronCatchUp = MKPT_PatronCatchUp

function MKPT_PatronCatchUp:MeetRequirements()
  return true
end

function MKPT_PatronCatchUp:GetDescription()
  local requirementsText = self.text and self.text.."\n" or ""
  return requirementsText..CreateSimpleTextureMarkup(4914670, 16, 16).." ~24 hours - "..CreateSimpleTextureMarkup(5976939, 16, 16).." ~84 hours"
end

local MKPT_DarkmoonQuest = MKPT_Item:New()
MKPT_env.MKPT_DarkmoonQuest = MKPT_DarkmoonQuest

function MKPT_DarkmoonQuest:New(o)
  if o.questId and o.questId[1] then
    C_QuestLog.RequestLoadQuestByID(o.questId[1])
  end

  return MKPT_Item.New(self, o)
end
function MKPT_DarkmoonQuest:GetId()
  return self.questId and self.questId[1]
end

function MKPT_DarkmoonQuest:Show()
  return not MKPT_env.db.config.hideWeeklyQuests and MKPT_Item.Show(self)
end

function MKPT_DarkmoonQuest:GetName()
  if self.name then return self.name end

  self.name = C_QuestLog.GetTitleForQuestID(self:GetId())
  return self.name
end

function MKPT_DarkmoonQuest:GetIcon()
  -- Darkmoon eye IconId
  return 1100023
end

function MKPT_DarkmoonQuest:IsDmfUp()
  local dayOfWeek = tonumber(date("%w"))
  local dayOfMonth = tonumber(date("%e"))

  local firstSundayOfMonth = ((dayOfMonth - (dayOfWeek + 1)) % 7) + 1
  local daysSinceFirstSunday = dayOfMonth - firstSundayOfMonth
  return daysSinceFirstSunday >= 0 and daysSinceFirstSunday <= 6
end

function MKPT_DarkmoonQuest:GetRemainingKnowledgePoints()
  return not self:IsDmfUp() and 0 or MKPT_Item.GetRemainingKnowledgePoints(self)
end

function MKPT_DarkmoonQuest:GetCategoryIcon()
  return Utils.WEEKLY_QUEST_ICON
end

function MKPT_DarkmoonQuest:GetFormattedName()
  if not self:MeetRequirements() then
    return Utils.RequirementsNotMetColor(self:GetName())
  end
  return Utils.DarkmoonTextColor(self:GetName())
end

local MKPT_UniqueBook = MKPT_Item:New()
MKPT_env.MKPT_UniqueBook = MKPT_UniqueBook

function MKPT_UniqueBook:IsUnique()
  return true
end

function MKPT_UniqueBook:GetRemainingKnowledgePoints()
  if self._done then return 0 end
  local remainingKp = MKPT_Item.GetRemainingKnowledgePoints(self)
  self._done = remainingKp == 0
  return remainingKp
end

function MKPT_UniqueBook:GetCategoryIcon()
  local atlasIcon = self.atlasIcon
  if atlasIcon then
    return CreateAtlasMarkup(atlasIcon, 16, 16)
  end

  return Utils.UNIQUE_BOOK_ICON
end

function MKPT_UniqueBook:Show()
  return not MKPT_env.db.config.hideUniqueBooks and MKPT_Item.Show(self)
end

local MKPT_UniqueTreasure = MKPT_env.MKPT_UniqueBook:New()
MKPT_env.MKPT_UniqueTreasure = MKPT_UniqueTreasure

function MKPT_UniqueTreasure:GetCategoryIcon()
  local waypoint = self.waypoint
  local playerMap = C_Map.GetBestMapForUnit("player")

  if waypoint and playerMap then
    local parentMap = C_Map.GetMapInfo(C_Map.GetMapInfo(playerMap).parentMapID or playerMap)
    playerMap = parentMap.mapType == 3 and parentMap.mapID or playerMap

    local waypointMap = waypoint.map
    local parentWaypointMap = C_Map.GetMapInfo(C_Map.GetMapInfo(waypointMap).parentMapID)
    waypointMap = parentWaypointMap.mapType == 3 and parentWaypointMap.mapID or waypointMap

    if waypointMap == playerMap then
      return Utils.UNIQUE_TREASURE_ICON
    end
  end

  return Utils.UNIQUE_TREASURE_ICON_FADED
end

function MKPT_UniqueTreasure:Show()
  return not MKPT_env.db.config.hideUniqueTreasures and MKPT_Item.Show(self)
end

local MKPT_WeeklyTreasure = MKPT_Item:New()
MKPT_env.MKPT_WeeklyTreasure = MKPT_WeeklyTreasure

function MKPT_WeeklyTreasure:GetCategoryIcon()
  if self.atlasIcon then
    return CreateAtlasMarkup(self.atlasIcon, 16, 16)
  end

  return Utils.WEEKLY_TREASURE_ICON
end

function MKPT_WeeklyTreasure:Show()
  return not MKPT_env.db.config.hideWeeklyTreasures and MKPT_Item.Show(self)
end

function MKPT_WeeklyTreasure:GetDescription()
  if self.text then
    return self.text
  end
  local zoneName
  if MKPT_env.charDb.state.expansion == Enum.ExpansionLevel.WarWithin then
    zoneName = C_Map.GetMapInfo(2274).name -- Khaz Algar
  else
    zoneName = C_Map.GetMapInfo(2537).name -- Quel'Thalas
  end
  return Utils.WEEKLY_TREASURE_ICON.." Found on treasures around "..zoneName
end

local MKPT_WeeklyQuestItem = MKPT_Item:New()
MKPT_env.MKPT_WeeklyQuestItem = MKPT_WeeklyQuestItem

function MKPT_WeeklyQuestItem:GetRemainingKnowledgePoints()
  for _, questId in ipairs(self.questId) do
    if C_QuestLog.IsQuestFlaggedCompleted(questId) then
      return 0
    end
  end

  return self.kp
end

function MKPT_WeeklyQuestItem:GetCategoryIcon()
  return CreateAtlasMarkup("quest-recurring-available", 16, 16)
end

function MKPT_WeeklyQuestItem:Show()
  return not MKPT_env.db.config.hideWeeklyQuests and MKPT_Item.Show(self)
end

local MKPT_Treatise = MKPT_env.MKPT_WeeklyTreasure:New()
MKPT_env.MKPT_Treatise = MKPT_Treatise

function MKPT_Treatise:Show()
  return not MKPT_env.db.config.hideTreatise and MKPT_Item.Show(self)
end

function MKPT_Treatise:GetCategoryIcon()
  return Utils.TREATISE_ICON
end

function MKPT_Treatise:GetDescription()
  local itemDescription = MKPT_Item.GetDescription(self)

  return Utils.TREATISE_ICON.." Inscription work order".."\n"..itemDescription
end

local MKPT_FirstTimeRecipe = MKPT_env.MKPT_Item:New()
MKPT_env.MKPT_FirstTimeRecipe = MKPT_FirstTimeRecipe


function MKPT_FirstTimeRecipe:GetDescription()
  local description = nil
  for _, recipe in ipairs(self.recipes) do
    if not C_QuestLog.IsQuestFlaggedCompleted(recipe.questId) then
      description = (not description and "" or description.."\n")..C_Spell.GetSpellName(recipe.spellId)
    end
  end
  return description
end

function MKPT_FirstTimeRecipe:GetIcon()
  local iconID, _ = C_Spell.GetSpellTexture(self.spellId)
  return iconID
end

function MKPT_FirstTimeRecipe:GetCategoryIcon()
  if self.atlasIcon then
    return CreateAtlasMarkup(self.atlasIcon, 16, 16)
  end

  return Utils.TREATISE_ICON
end

function MKPT_FirstTimeRecipe:AddRecipe(questId, objectId, spellId)
  if not self.recipes then self.recipes = {} end
  table.insert(self.recipes, {questId=questId, objectId=objectId, spellId=spellId})
  return self
end

function MKPT_FirstTimeRecipe:GetName()
  return C_Spell.GetSpellName(self.spellId)
end

function MKPT_FirstTimeRecipe:GetFormattedName()
  return Utils.UniqueTextColor(self:GetName())
end

function MKPT_FirstTimeRecipe:IsUnique()
  return true
end

function MKPT_FirstTimeRecipe:GetRemainingKnowledgePoints()
  local points = 0
  for _, recipe in ipairs(self.recipes) do
    if not C_QuestLog.IsQuestFlaggedCompleted(recipe.questId) then
      points = points + 1
    end
  end
  return points
end

function MKPT_FirstTimeRecipe:Show()
  return not MKPT_env.db.config.hideFirstTimeGather and MKPT_Item.Show(self)
end
