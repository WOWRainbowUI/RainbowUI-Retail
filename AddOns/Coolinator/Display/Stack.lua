---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.StackMixin = {}

function addonTable.Display.StackMixin:OnLoad()
end

function addonTable.Display.StackMixin:Disable()
end

function addonTable.Display.StackMixin:GetDefaultSize()
  return self.width, self.height
end

function addonTable.Display.StackMixin:SetDefaultSize(width, height)
  self.width, self.height = width, height
end

function addonTable.Display.StackMixin:Setup(details)
  self.details = details
  self.children = {}
  self.width, self.height = 0, 0
end

function addonTable.Display.StackMixin:ApplySize(width, height)
  for _, child in ipairs(self.children) do
    if child.ApplySize then
      child:ApplySize(self.width, self.height)
    end
  end
end

function addonTable.Display.StackMixin:TriggerLayout()
  for _, child in ipairs(self.children) do
    if child.TriggerLayout then
      child:TriggerLayout()
    end
  end
  self:SetSize(0.001, 0.001)
  if self.ResizeToBoundsRect then
    self:ResizeToBoundsRect()
  else
    local _, _, width, height = self:GetBoundsRect()
    self:SetSize(width, height)
  end
end

function addonTable.Display.StackMixin:ApplyPadding(horizontal, vertical)
  for _, child in ipairs(self.children) do
    child:ApplyPadding(horizontal / child:GetScale(), vertical / child:GetScale())
  end

  self:SetSize(0.001, 0.001)
  if self.ResizeToBoundsRect then
    self:ResizeToBoundsRect()
  else
    local _, _, width, height = self:GetBoundsRect()
    self:SetSize(width, height)
  end
end
