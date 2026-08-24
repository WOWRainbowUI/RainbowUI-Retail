---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.LayoutManagerNextMixin = CreateFromMixins(addonTable.Display.LayoutManagerSharedMixin)
function addonTable.Display.LayoutManagerNextMixin:OnLoad()
  addonTable.Display.LayoutManagerSharedMixin.OnLoad(self)

  self.specialistPools = {
    auraIcon = addonTable.Display.GeneratePool(addonTable.Display.AuraIconNextMixin, "CoolinatorPropagateMouseClicksTemplate"),
    auraBar = addonTable.Display.GeneratePool(addonTable.Display.AuraStatusBarNextMixin, "CoolinatorPropagateMouseClicksTemplate"),
  }
  self.prelaidWidgets = {
    auraIcon = {},
    auraBar = {},
  }
  for key, mixin in pairs(addonTable.Display.ClassResourceStatusBar) do
    self.pools["class-" .. key] = addonTable.Display.GeneratePool(mixin)
  end

  addonTable.CallbackRegistry:RegisterCallback("Layout", function()
    if not addonTable.Utilities.IsAurasRestricted() then
      for _, pool in pairs(self.specialistPools) do
        pool:ReleaseAll()
      end
      self.prelaidWidgets = {
        auraIcon = {},
        auraBar = {},
      }
    end

    self:Layout()
  end)

  self:Layout()
end

function addonTable.Display.LayoutManagerNextMixin:GetIcon(details)
  if details.resource.kind == "aura" and addonTable.Constants.Totems[details.resource.spellID] then
    local frame = self.pools.totemIcon:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame

  elseif details.resource.kind == "aura" then
    local stack = self.prelaidWidgets.auraIcon[details.resource.spellID]
    local counter = self.prelaidWidgets.auraIconCounters[details.resource.spellID]
    local frame = stack and stack[counter or 1]
    if not frame then
      if not addonTable.Utilities.IsAurasRestricted() then
        frame = self.specialistPools.auraIcon:Acquire()
        if not stack then
          stack = {}
          self.prelaidWidgets.auraIcon[details.resource.spellID] = stack
        end
        table.insert(stack, frame)
        frame:Setup(details)
      else
        return
      end
    else
      frame:ClearAllPoints()
    end
    self.prelaidWidgets.auraIconCounters[details.resource.spellID] = (counter or 1) + 1
    frame:Show()
    frame:Enable()
    return frame

  else
    return addonTable.Display.LayoutManagerSharedMixin.GetIcon(self, details)
  end
end

function addonTable.Display.LayoutManagerNextMixin:GetBar(details)
  if details.resource.kind == "aura" and addonTable.Constants.Totems[details.resource.spellID] then
    local frame = self.pools.totemStatusBar:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame

  elseif details.resource.kind == "aura" then
    local stack = self.prelaidWidgets.auraBar[details.resource.spellID]
    local counter = self.prelaidWidgets.auraBarCounters[details.resource.spellID]
    local frame = stack and stack[counter or 1]
    if not frame then
      if not addonTable.Utilities.IsAurasRestricted() then
        frame = self.specialistPools.auraBar:Acquire()
        if not stack then
          stack = {}
          self.prelaidWidgets.auraBar[details.resource.spellID] = stack
        end
        table.insert(stack, frame)
        frame:Setup(details)
      else
        return
      end
    end
    self.prelaidWidgets.auraBarCounters[details.resource.spellID] = (counter or 1) + 1
    frame:Show()
    frame:Enable()
    return frame

  else
    return addonTable.Display.LayoutManagerSharedMixin.GetBar(self, details)
  end
end

function addonTable.Display.LayoutManagerNextMixin:Layout()
  self.prelaidWidgets.auraIconCounters = {}
  self.prelaidWidgets.auraBarCounters = {}

  for _, list in pairs(self.prelaidWidgets.auraIcon) do
    for _, w in ipairs(list) do
      w:Disable()
      w:ClearAllPoints()
      w:Hide()
    end
  end
  for _, list in pairs(self.prelaidWidgets.auraBar) do
    for _, w in ipairs(list) do
      w:Disable()
      w:ClearAllPoints()
      w:Hide()
    end
  end

  addonTable.Display.LayoutManagerSharedMixin.Layout(self)
end
