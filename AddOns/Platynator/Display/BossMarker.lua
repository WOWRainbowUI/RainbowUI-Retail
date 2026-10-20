---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.BossMarkerMixin = {}

function addonTable.Display.BossMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    if self.details.openWorldOnly and addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true}) then
      self:Hide()
      return
    end
    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
    addonTable.CallbackRegistry:RegisterCallback("DungeonLevelUpdate", self.UpdateState, self)
    self:UpdateState()
  else
    self:StripInternal()
  end
end

function addonTable.Display.BossMarkerMixin:OnEvent()
  self:UpdateState()
end

function addonTable.Display.BossMarkerMixin:UpdateState()
  local inRaidOrDungeon = addonTable.Display.Utilities.IsInRelevantInstance({raid = true, dungeon = true})
  local kind
  if inRaidOrDungeon then
    kind = addonTable.Display.Utilities.GetEliteType(self.unit)
  else
    kind = addonTable.Display.Utilities.GetDelveType(self.unit)
  end

  self:SetShown(kind == "boss")
end

function addonTable.Display.BossMarkerMixin:StripInternal()
  self:UnregisterAllEvents()
  addonTable.CallbackRegistry:UnregisterCallback("DungeonLevelUpdate", self)
end

function addonTable.Display.BossMarkerMixin:Strip()
  self:StripInternal()
end
