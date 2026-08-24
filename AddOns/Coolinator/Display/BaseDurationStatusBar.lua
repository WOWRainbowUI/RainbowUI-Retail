---@class addonTableCoolinator
local addonTable = select(2, ...)

local textsByKey = {
  Duration = "duration",
  Name = "name",
}

addonTable.Display.BaseDurationStatusBarMixin = {}

function addonTable.Display.BaseDurationStatusBarMixin:OnLoad()
  self:SetIgnoringChildrenForBounds(true)

  self.statusBar = CreateFrame("StatusBar", nil, self)

  self.background = self.statusBar:CreateTexture(nil, "BACKGROUND")
  self.background:SetAllPoints(self.statusBar)
  self.borderWrapper = CreateFrame("Frame", nil, self)
  self.borderWrapper:SetAllPoints(self.statusBar)
  self.border = self.borderWrapper:CreateTexture(nil, "BORDER")
  self.border:SetPoint("CENTER", self.statusBar)
  self.borderMask = self.statusBar:CreateMaskTexture()
  self.borderMask:SetAllPoints(self.statusBar)

  self.Icon = self:CreateTexture(nil, "OVERLAY")
  self.Icon:SetSize(addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
  self.Icon:SetPoint("CENTER")

  addonTable.Display.GenerateTexts(self, textsByKey)

  self.DurationBinding = C_DurationUtil.CreateDurationTextBinding()
  self.DurationBinding:SetFontString(self.TextsContainer.Duration)
  self.DurationBinding:SetZeroDurationText("0")

  self.paddingH, self.paddingV = 0, 0
  self.sizingWidth, self.sizingHeight = 0, 0
end

function addonTable.Display.BaseDurationStatusBarMixin:Setup(details)
  self.details = details

  self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)

  self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)
  self.TextsContainer:SetFrameLevel(self.statusBar:GetFrameLevel() + 4)

  addonTable.Display.ApplyTexts(self, details, textsByKey, details.scale)

  local format = "{}"
  local components = {}
  local display = self.details.texts.duration.display
  if #display == 2 then
    format = "{}/{}"
    components = {
      {
        property = addonTable.Display.ConvertDurationDisplayToComponent(display[1]),
        formatter = addonTable.Display.GetDurationFormatter(self.details.texts.duration.showFractions),
      },
      {
        property = addonTable.Display.ConvertDurationDisplayToComponent(display[2]),
        formatter = addonTable.Display.GetDurationFormatter(self.details.texts.duration.showFractions),
      }
    }
  else
    components = {{
      property = addonTable.Display.ConvertDurationDisplayToComponent(display[1]),
      formatter = addonTable.Display.GetDurationFormatter(self.details.texts.duration.showFractions),
    }}
  end
  self.DurationBinding:SetTextFormat(format, components)

  self.Icon:SetShown(details.icon.show)
end

function addonTable.Display.BaseDurationStatusBarMixin:GetDefaultSize()
  return self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
end

function addonTable.Display.BaseDurationStatusBarMixin:ApplySize(width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  self.sizingWidth, self.sizingHeight = sizing.rawWidth, sizing.rawHeight
  PixelUtil.SetSize(self.statusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
  if sizing.iconSize > 0 then
    self.Icon:Show()
    PixelUtil.SetSize(self.Icon, sizing.iconSize, sizing.iconSize)
  else
    self.Icon:Hide()
  end

  self.Icon:ClearAllPoints()
  self.statusBar:ClearAllPoints()
  self.TextsContainer.Duration:ClearAllPoints()
  if self.details.layout == "horizontal" then
    self.Icon:SetPoint(self.details.icon.position == "left" and "LEFT" or "RIGHT")
    self.statusBar:SetPoint(self.details.icon.position == "left" and "RIGHT" or "LEFT")
  else
    self.Icon:SetPoint(self.details.icon.position == "left" and "BOTTOM" or "TOP")
    self.statusBar:SetPoint(self.details.icon.position == "left" and "TOP" or "BOTTOM")
  end
  addonTable.Display.SizeTextsForBar(self, self.details, textsByKey, self.details.scale)
end

function addonTable.Display.BaseDurationStatusBarMixin:ApplyPadding(horizontal, vertical)
  self.paddingH, self.paddingV = horizontal, vertical
  if not self.collapsed then
    PixelUtil.SetSize(self, self.sizingWidth + horizontal, self.sizingHeight + vertical)
  end
end

function addonTable.Display.BaseDurationStatusBarMixin:Collapse()
  if addonTable.Config.Get(addonTable.Config.Options.COMPRESS_LAYOUT) then
    self.collapsed = true
    self:SetSize(0.001, 0.001)
  else
    self.collapsed = false
  end
  self:Hide()
end

function addonTable.Display.BaseDurationStatusBarMixin:Expand()
  self.collapsed = false
  self:ApplyPadding(self.paddingH or 0, self.paddingV or 0)
  self:Show()
end
