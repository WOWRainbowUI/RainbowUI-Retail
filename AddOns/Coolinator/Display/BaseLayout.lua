---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.BaseLayoutManagerMixin = {}
function addonTable.Display.BaseLayoutManagerMixin:OnLoad()
  self.toArrange = {}

  self.relativeLayoutMode = true
end

function addonTable.Display.BaseLayoutManagerMixin:GetIcon(details)
  assert(false)
end

function addonTable.Display.BaseLayoutManagerMixin:GetBar(details)
  assert(false)
end

function addonTable.Display.BaseLayoutManagerMixin:Delayout()
  assert(false)
end

function addonTable.Display.BaseLayoutManagerMixin:Layout()
  assert(false)
end

local function AnchorStandalone(widget, anchor)
  local point, relativeTo, relativePoint, offsetX, offsetY = unpack(anchor)
  PixelUtil.SetPoint(widget, point, relativeTo, relativePoint, offsetX/widget:GetScale(), offsetY/widget:GetScale())
end

function addonTable.Display.BaseLayoutManagerMixin:GetStack(details)
  local offsetSize = addonTable.Constants.nativeSize - 4
  local wrapper = self.pools.stack:Acquire()
  wrapper:Show()
  wrapper:SetAlpha(1)
  wrapper:SetScale(1)
  wrapper:Setup(details)
  local width, height = 0, 0
  for index, entry in ipairs(details.entries) do
    if entry.kind == "icon" then
      local icon = self:GetIcon(entry)
      if icon then
        icon:SetScale(entry.scale)
        icon:SetAlpha(entry.alpha)
        icon:SetParent(wrapper)
        icon:SetPoint("CENTER", wrapper)
        width = math.max(width, entry.scale * offsetSize)
        height = math.max(height, entry.scale * offsetSize)
        icon:SetFrameLevel(self:GetFrameLevel() + 5 * (index - 1) + 1)
        table.insert(wrapper.children, icon)
      end
    elseif entry.kind == "bar" then
      local bar = self:GetBar(entry)
      if bar then
        bar:SetParent(wrapper)
        bar:SetAlpha(entry.alpha)
        bar:SetPoint("BOTTOM", wrapper)
        bar:SetFrameLevel(self:GetFrameLevel() + 5 * (index - 1) + 1)
        table.insert(wrapper.children, bar)
      end
    end
  end
  wrapper:SetDefaultSize(width, height)
  PixelUtil.SetSize(wrapper, width, height)

  return wrapper
end

function addonTable.Display.BaseLayoutManagerMixin:GetGroup(details)
  local wrapper = self.pools.group:Acquire()
  wrapper:Show()
  wrapper:SetAlpha(details.layout == "standalone" and 1 or details.alpha)
  wrapper:SetScale(details.layout == "standalone" and 1 or details.scale)
  wrapper:Setup(details)
  for _, entry in ipairs(details.entries) do
    if entry.kind == "icon" then
      local icon = self:GetIcon(entry)
      if icon then
        icon:SetScale(entry.scale)
        icon:SetAlpha(entry.alpha)
        icon:SetParent(wrapper)
        table.insert(wrapper.children, icon)
      end
    elseif entry.kind == "bar" then
      local bar = self:GetBar(entry)
      if bar then
        bar:SetParent(wrapper)
        bar:SetAlpha(entry.alpha)
        table.insert(wrapper.children, bar)
      end
    elseif entry.kind == "group" then
      local subWrapper = self:GetGroup(entry)
      table.insert(wrapper.children, subWrapper)
      subWrapper:SetParent(wrapper)
      if details.layout == "standalone" then
        AnchorStandalone(subWrapper, entry.anchor)
      end
    elseif entry.kind == "stack" then
      local stack = self:GetStack(entry)
      if stack then
        stack:SetScale(entry.scale)
        stack:SetAlpha(entry.alpha)
        stack:SetParent(wrapper)
        table.insert(wrapper.children, stack)
      end
    end
  end

  return wrapper
end

function addonTable.Display.BaseLayoutManagerMixin:ArrangeGroup(wrapper, details)
  local offsetSize = addonTable.Constants.nativeSize - 4

  if details.layout == "horizontal" then
    local point = "LEFT"
    if details.alignment ~= "CENTER" then
      point = details.alignment .. point
    end
    local padding = details.padding * offsetSize
    local maxHeight = 0
    local width = 0
    local lastChild
    for _, child in ipairs(wrapper.children) do
      if child.details.kind == "group" then
        self:ArrangeGroup(child, child.details)
      end

      if self.relativeLayoutMode and self.autoSize then
        if lastChild then
          child:SetPoint("LEFT", lastChild, "RIGHT")
        else
          if details.anchor and details.anchor[1]:match("RIGHT") then
            PixelUtil.SetPoint(child, "LEFT", wrapper, "LEFT", padding / 2 / child:GetScale(), 0)
          elseif details.anchor and details.anchor[1]:match("LEFT") then
            PixelUtil.SetPoint(child, "LEFT", wrapper, "LEFT", -padding / 2 / child:GetScale(), 0)
          else
            child:SetPoint("LEFT", wrapper)
          end
        end
        if details.alignment ~= "CENTER" then
          child:SetPoint(details.alignment, wrapper)
        end
      else
        PixelUtil.SetPoint(child, point, wrapper, point, width / child:GetScale(), 0)
      end
      if not self.autoSize or not child.IgnoreForSizing or not child:IgnoreForSizing() then
        local childWidth, childHeight
        if child.GetDefaultSize then
          childWidth, childHeight = child:GetDefaultSize()
        else
          childWidth, childHeight = child:GetWidth(), child:GetHeight()
        end
        maxHeight = math.max(childHeight * child:GetScale(), maxHeight)
        width = width + PixelUtil.ConvertPixelsToUIForRegion(childWidth + padding / child:GetScale(), child) * child:GetScale()
      end
      lastChild = child
    end
    if width > 0 then
      width = width - padding
    end
    local finalWidth, finalHeight = PixelUtil.ConvertPixelsToUIForRegion(width, wrapper), PixelUtil.ConvertPixelsToUIForRegion(maxHeight, wrapper)
    wrapper:SetSize(finalWidth, finalHeight)
    wrapper:SetDefaultSize(finalWidth, finalHeight)

  elseif details.layout == "vertical" then
    local point = "BOTTOM"
    if details.alignment ~= "CENTER" then
      point = point .. details.alignment
    end
    local padding = details.padding * offsetSize
    local height = 0
    local maxWidth = 0
    local lastChild
    for _, child in ipairs(wrapper.children) do
      if child.details.kind == "group" then
        self:ArrangeGroup(child, child.details)
      end

      if self.relativeLayoutMode and self.autoSize then
        if lastChild then
          child:SetPoint("BOTTOM", lastChild, "TOP")
        else
          if details.anchor and details.anchor[1]:match("TOP") then
            PixelUtil.SetPoint(child, "BOTTOM", wrapper, "BOTTOM", 0, padding / 2 / child:GetScale())
          elseif details.anchor and details.anchor[1]:match("BOTTOM") then
            PixelUtil.SetPoint(child, "BOTTOM", wrapper, "BOTTOM", 0, -padding / 2 / child:GetScale())
          else
            child:SetPoint("BOTTOM", wrapper)
          end
        end
        if details.alignment ~= "CENTER" then
          child:SetPoint(details.alignment, wrapper)
        end
      else
        PixelUtil.SetPoint(child, point, wrapper, point, 0, height / child:GetScale())
      end
      if not self.autoSize or not child.IgnoreForSizing or not child:IgnoreForSizing() then
        local childWidth, childHeight
        if child.GetDefaultSize then
          childWidth, childHeight = child:GetDefaultSize()
        else
          childWidth, childHeight = child:GetWidth(), child:GetHeight()
        end
        maxWidth = math.max(childWidth * child:GetScale(), maxWidth)
        height = height + PixelUtil.ConvertPixelsToUIForRegion(childHeight + padding / child:GetScale(), child) * child:GetScale()
      end
      lastChild = child
    end
    if height > 0 then
      height = height - padding
    end
    local finalWidth, finalHeight = PixelUtil.ConvertPixelsToUIForRegion(maxWidth, wrapper), PixelUtil.ConvertPixelsToUIForRegion(height, wrapper)
    wrapper:SetSize(finalWidth, finalHeight)
    wrapper:SetDefaultSize(finalWidth, finalHeight)

  else -- standalone
    for _, child in ipairs(wrapper.children) do
      if child.details.kind == "group" then
        self:ArrangeGroup(child, child.details)
      end
    end

    wrapper:ApplySize(0, 0)
    if self.relativeLayoutMode and self.autoSize then
      wrapper:ApplyPadding(0, 0)
      wrapper:TriggerLayout()
    else
      wrapper:ApplyPadding(0, 0)
      wrapper:ReanchorForSize()
    end
  end
end
