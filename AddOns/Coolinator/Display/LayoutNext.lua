---@class addonTableCoolinator
local addonTable = select(2, ...)

local prelaidKeys = {
  "auraIcon",
  "auraMissing",
  "auraBar",
  "auraStackPip"
}

addonTable.Display.LayoutManagerNextMixin = CreateFromMixins(addonTable.Display.LayoutManagerSharedMixin)
function addonTable.Display.LayoutManagerNextMixin:OnLoad()
  addonTable.Display.LayoutManagerSharedMixin.OnLoad(self)

  self.specialistPools = {
    auraIcon = addonTable.Display.GeneratePool(addonTable.Display.AuraIconNextMixin),
    auraBar = addonTable.Display.GeneratePool(addonTable.Display.AuraStatusBarNextMixin),
    auraStackPip = addonTable.Display.GeneratePool(addonTable.Display.AuraStacksPipMixin),
    auraMissing = addonTable.Display.GeneratePool(addonTable.Display.AuraInvertedIconMixin),
  }
  self.prelaidWidgets = {}
  for _, k in ipairs(prelaidKeys) do
    self.prelaidWidgets[k] = {}
  end
  for key, mixin in pairs(addonTable.Display.ClassResourceStatusBar) do
    self.pools["class-" .. key] = addonTable.Display.GeneratePool(mixin)
  end

  addonTable.CallbackRegistry:RegisterCallback("Layout", function()
    if not addonTable.Utilities.IsAurasRestricted() then
      for _, pool in pairs(self.specialistPools) do
        pool:ReleaseAll()
      end
      for _, k in ipairs(prelaidKeys) do
        self.prelaidWidgets[k] = {}
      end
    end

    self:Layout()
  end)

  self:Layout()
end

function addonTable.Display.LayoutManagerNextMixin:GetPrelaid(key, details)
  local stack = self.prelaidWidgets[key][details.resource.spellID]
  local counter = self.prelaidWidgets[key .. "Counters"][details.resource.spellID]
  local frame = stack and stack[counter or 1]
  if not frame then
    if not addonTable.Utilities.IsAurasRestricted() then
      frame = self.specialistPools[key]:Acquire()
      if not stack then
        stack = {}
        self.prelaidWidgets[key][details.resource.spellID] = stack
      end
      table.insert(stack, frame)
      frame:Setup(details)
    else
      return
    end
  else
    frame:ClearAllPoints()
  end
  self.prelaidWidgets[key .. "Counters"][details.resource.spellID] = (counter or 1) + 1
  frame:Show()
  frame:Enable()
  return frame
end

function addonTable.Display.LayoutManagerNextMixin:GetIcon(details)
  if details.resource.kind == "aura" and addonTable.Constants.Totems[details.resource.spellID] then
    local frame = self.pools.totemIcon:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame

  elseif details.resource.kind == "aura" then
    return self:GetPrelaid("auraIcon", details)

  elseif details.resource.kind == "auraMissing" then
    return self:GetPrelaid("auraMissing", details)

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
    return self:GetPrelaid("auraBar", details)

  elseif details.resource.kind == "auraStackPip" then
    return self:GetPrelaid("auraStackPip", details)

  else
    return addonTable.Display.LayoutManagerSharedMixin.GetBar(self, details)
  end
end

function addonTable.Display.LayoutManagerNextMixin:Layout()
  for _, k in ipairs(prelaidKeys) do
    self.prelaidWidgets[k .. "Counters"] = {}
    for _, list in pairs(self.prelaidWidgets[k]) do
      for _, w in ipairs(list) do
        w:Disable()
        w:ClearAllPoints()
        w:Hide()
      end
    end
  end

  addonTable.Display.LayoutManagerSharedMixin.Layout(self)
end
