---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.SpacerMixin = {}
function addonTable.Display.SpacerMixin:OnLoad()
end

function addonTable.Display.SpacerMixin:Setup(details)
  self.details = details
  self.width = details.width * (addonTable.Constants.nativeSize - 4)
  self.height = details.height * (addonTable.Constants.nativeSize - 4)
end

function addonTable.Display.SpacerMixin:ApplySize(width, height)
  PixelUtil.SetSize(self, self.width, self.height)
end

function addonTable.Display.SpacerMixin:ApplyPadding(horizontal, vertical)
  PixelUtil.SetSize(self, self.width + horizontal, self.height + vertical)
end
