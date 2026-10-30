---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.AbsorbTextMixin = {}

function addonTable.Display.AbsorbTextMixin:PostInit()
  self.abbreviateAbsolute = self.details.abbreviate and (addonTable.Display.Utilities.AbbreviateNumbersAlt or AbbreviateNumbers) or BreakUpLargeNumbers
end

function addonTable.Display.AbsorbTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.Cache:RegisterCallback(self.unit, "health", function(state)
      self:UpdateText(state)
    end)
    self:UpdateText(addonTable.Cache:Get(self.unit, "health"))
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.AbsorbTextMixin:Strip()
  self.abbreviateAbsolute = nil
  self:UnregisterAllEvents()
  self.text:SetAlpha(1)
end

function addonTable.Display.AbsorbTextMixin:OnEvent()
  self:UpdateText()
end

function addonTable.Display.AbsorbTextMixin:UpdateText(state)
  local absolute = self.abbreviateAbsolute(state.absorbs)
  self.text:SetText("+" .. absolute)
  self.text:SetAlpha(state.absorbs)
end
