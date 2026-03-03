local _, MKPT_env, _ = ...

---@class MKPT_Profession
local MKPT_Profession = {}

local showAllProfessions = false

local catchUpCurrencyIdx = {}
function MKPT_Profession.FindProfessionByCatchUpCurrencyId(currencyId)
  return catchUpCurrencyIdx[currencyId]
end

MKPT_env.MKPT_Profession = MKPT_Profession

---@class MKPT_Profession
---@field id number - profession skillLineId
---@field spellId number - profession spellId
---@field catchUpCurrencyId number - id of hidden catchUp currency
---@field trainerLocation table - location of the trainer NPC for expansion/profession
---@field name string - profession name without the expansion e.g. 'Tailoring'
---@field expansionName string - profession name with the expansion e.g 'Midnight Tailoring'
---@field expansionTrainerName string - learn + profession name with the expansion e.g 'Learn Midnight Tailoring'
---@field skillLine number - skillLineId of the base profession
---@field icon texture - icon of the profession
---@field expanded boolean - wether to show/hide profession items on the menu
---@field entries table - holds profession related MKPT_Items
function MKPT_Profession:New(professionId, spellId, catchUpCurrencyId, trainerLocation)
  local profession = {}
  setmetatable(profession, self)
  self.__index = self
  profession.id = professionId
  profession.spellId = spellId
  profession.catchUpCurrencyId = catchUpCurrencyId
  catchUpCurrencyIdx[catchUpCurrencyId] = profession

  local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(profession.id)
  profession.trainerLocation = trainerLocation
  profession.name = info.parentProfessionName
  profession.expansionName = info.professionName
  profession.expansionTrainerName = LEARN_SKILL_TEMPLATE:format(profession.expansionName)
  profession.skillLine = info.parentProfessionID
  profession.icon = C_TradeSkillUI.GetTradeSkillTexture(profession.id)
  profession.expanded = false
  profession.entries = {}
  return profession
end

function MKPT_Profession:AddEntry(entry)
  table.insert(self.entries, entry)

  entry.profession = self

  return self
end

function MKPT_Profession:GetSkillLevel()
  -- Only skill levels of the trained professions from the latest expansions are available at login time
  local prof1, prof2, _ = GetProfessions()
  if prof1 then
    local _, _, skillLevel, maxSkillLevel, _, _, skillLine, bonusSkill, _, _, professionName = GetProfessionInfo(prof1)
    if skillLine == self.skillLine and self.expansionName == professionName then
      return { skillLevel = skillLevel, maxSkillLevel = maxSkillLevel, bonusSkill = bonusSkill }
    end
  end
  if prof2 then
    local _, _, skillLevel, maxSkillLevel, _, _, skillLine, bonusSkill, _, _, professionName = GetProfessionInfo(prof2)
    if skillLine == self.skillLine and self.expansionName == professionName then
      return { skillLevel = skillLevel, maxSkillLevel = maxSkillLevel, bonusSkill = bonusSkill }
    end
  end

  -- Fallback for legacy expansion professions, only works if craft window was opened at least once in the current gaming session
  local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(self.id)
  if info.skillLevel > 0 then
    return { skillLevel = info.skillLevel, maxSkillLevel = info.maxSkillLevel, bonusSkill = info.skillModifier }
  end

  return nil
end

function MKPT_Profession:HasSkillLine()
  local prof1, prof2, _ = GetProfessions()

  if prof1 then
    local _, _, _, _, _, _, skillLine, _ = GetProfessionInfo(prof1)
    if skillLine == self.skillLine then return true end
  end
  if prof2 then
    local _, _, _, _, _, _, skillLine, _ = GetProfessionInfo(prof2)
    if skillLine == self.skillLine then return true end
  end
  return false or showAllProfessions
end

---Calculates how many kp are still available
---@param self MKPT_Profession
---@return table - weekly, unique and catchUp keys with available kp as it's values
function MKPT_Profession:CalculateRemainingKps()
  local weekly, unique, catchUp = 0, 0, 0
  for _, item in pairs(self.entries) do
    local remaining = item:GetRemainingKnowledgePoints()
    if item:IsUnique() then
      unique = unique + remaining
    elseif item:IsCatchUp() then
      catchUp = catchUp + remaining
    else
      weekly = weekly + remaining
    end
  end
  return { weekly = weekly, unique = unique, catchUp = math.max(0, catchUp) }
end

---Remaining catchUp currency
---@param self MKPT_Profession
---@return number
function MKPT_Profession:GetCatchUpCurrencyLeft()
  local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(self.catchUpCurrencyId)
  return currencyInfo.maxQuantity - currencyInfo.quantity
end

---Verify if the player has trained this profession based on it's spellId
---@return boolean - true if the player trained the profession, false otherwise
function MKPT_Profession:IsLearned()
  return C_SpellBook.IsSpellKnown(self.spellId) or showAllProfessions
end

function MKPT_Profession:GetAvailableItems()
  return self.entries
end

local function GetPointsMissingForTree(configID, nodeID)
  local todo = { nodeID }
  local missing = 0
  while next(todo) do
    local nodeID = table.remove(todo)
    tAppendAll(todo, C_ProfSpecs.GetChildrenForPath(nodeID))
    local info = C_Traits.GetNodeInfo(configID, nodeID)
    if info then
      -- Enabling a node counts as 1 rank but doesn't cost anything
      local enableFix = info.activeRank == 0 and 1 or 0
      missing = missing + info.maxRanks - info.activeRank - enableFix
    end
  end
  return missing
end

function MKPT_Profession:CalculateSpendableKps()
  local configID = C_ProfSpecs.GetConfigIDForSkillLine(self.id)
  local traitTreeIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(self.id)
  local totalMissing = 0
  for _, traitTreeID in ipairs(traitTreeIDs) do
    local tabInfo = C_ProfSpecs.GetTabInfo(traitTreeID)
    if tabInfo then
      totalMissing = totalMissing + GetPointsMissingForTree(configID, tabInfo.rootNodeID)
    end
  end
  local currencyInfo = C_ProfSpecs.GetCurrencyInfoForSkillLine(self.id) or { numAvailable = 0 }
  return max(totalMissing - currencyInfo.numAvailable, 0)
end

function MKPT_Profession:ToggleTrack()
  if self:IsHighlighted() then
    self:Untrack()
    return nil
  end

  local untracked = MKPT_env.trackedItem
  if untracked then untracked:Untrack() end

  local wp = self.trainerLocation
  if wp then
    local mapPoint = UiMapPoint.CreateFromCoordinates(wp.map, wp.x, wp.y)
    C_Map.SetUserWaypoint(mapPoint)
    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    local _, isTomTomLoaded = C_AddOns.IsAddOnLoaded("TomTom")
    if isTomTomLoaded and TomTom then
      self.tomtomUid = TomTom:AddWaypoint(wp.map, wp.x, wp.y, { title = self.expansionTrainerName, persistent = false, source = "MKPT_WA" })
    end
  end
  MKPT_env.trackedItem = self
  return untracked
end

function MKPT_Profession:Untrack()
  if MKPT_env.trackedItem ~= self then return end

  C_SuperTrack.SetSuperTrackedUserWaypoint(false)
  C_Map.ClearUserWaypoint()
  if TomTom and self.tomtomUid then
    TomTom:RemoveWaypoint(self.tomtomUid)
  end
  MKPT_env.trackedItem = nil
end

function MKPT_Profession:IsHighlighted()
  return MKPT_env.trackedItem == self
end

function MKPT_Profession:IsAvailable()
  return self:HasSkillLine() and not self:IsLearned()
end

function MKPT_Profession:GetDescription()
  local waypoint = self.trainerLocation
  local mapInfo = C_Map.GetMapInfo(waypoint.map)
  return string.format("%s\n%s - x:%.2f y:%.2f", self.expansionTrainerName, mapInfo.name, waypoint.x * 100, waypoint.y * 100)
end
