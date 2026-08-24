---@class addonTableCoolinator
local addonTable = select(2, ...)

local textsByKey = {
  Duration = "duration",
  Name = "name",
}

addonTable.Display.CastBarMixin = {}

function addonTable.Display.CastBarMixin:OnLoad()
  self:SetScript("OnEvent", self.OnEvent)

  self.statusBar = CreateFrame("StatusBar", nil, self)
  self.statusBar:SetPoint("CENTER")

  self.background = self.statusBar:CreateTexture(nil, "BACKGROUND")
  self.background:SetAllPoints()
  self.borderWrapper = CreateFrame("Frame", nil, self)
  self.borderWrapper:SetAllPoints()
  self.border = self.borderWrapper:CreateTexture(nil, "BORDER")
  self.border:SetPoint("CENTER", self.statusBar)
  self.borderMask = self.statusBar:CreateMaskTexture()
  self.borderMask:SetAllPoints(self.statusBar)

  self.icon = self:CreateTexture(nil, "OVERLAY")
  self.icon:SetSize(addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
  self.icon:SetPoint("CENTER")

  self.TextsContainer = CreateFrame("Frame", nil, self)
  self.TextsContainer:SetAllPoints()
  self.TextsContainer.Duration = self.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
  self.TextsContainer.Duration:SetWordWrap(false)
  self.TextsContainer.Name = self.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
  self.TextsContainer.Name:SetWordWrap(false)

  self.DurationBinding = C_DurationUtil.CreateDurationTextBinding()
  self.DurationBinding:SetFontString(self.TextsContainer.Duration)
  self.DurationBinding:SetZeroDurationText("0")

  self.unit = "player"
end

function addonTable.Display.CastBarMixin:Enable(details)
  self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
  self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

  PlayerCastingBarFrame:SetParent(addonTable.hiddenFrame)
end

function addonTable.Display.CastBarMixin:Disable(details)
  self:UnregisterAllEvents()

  if self.timer then
    self.timer:Cancel()
  end

  PlayerCastingBarFrame:SetParent(UIParent)
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_START" or eventName == "UNIT_SPELLCAST_CHANNEL_START" or eventName == "UNIT_SPELLCAST_EMPOWER_START" then
    self:UpdateForCast()
  elseif ( eventName == "UNIT_SPELLCAST_STOP" ) then
    local _unitTarget, _castGUID, _spellID, castID = ...
    if not self.isChanneled and castID == self.castID then
      self:UpdateForCastEnd(true)
    end
  elseif eventName == "UNIT_SPELLCAST_CHANNEL_STOP" then
    local _unit, _castGUID, _spellID, interruptedBy, castID = ...
    if self.castID == castID then
      self:UpdateForCastEnd(interruptedBy == nil)
    end
  elseif eventName == "UNIT_SPELLCAST_EMPOWER_STOP" then
    local _unit, _castGUID, _spellID, complete, _interruptedBy, castID = ...
    if castID == self.castID then
      self:UpdateForCastEnd(complete)
    end
  elseif eventName == "UNIT_SPELLCAST_FAILED" then
    local _unitTarget, _castGUID, _spellID, castID = ...
    if castID == self.castID then
      self:UpdateForCastEnd(false)
    end
  elseif eventName == "UNIT_SPELLCAST_INTERRUPTED" then
    local _unitTarget, _castGUID, _spellID, _interruptedBy, castID = ...
    if castID == self.castID then
      self:UpdateForCastEnd(false)
    end
  elseif eventName == "UNIT_SPELLCAST_DELAYED" or eventName == "UNIT_SPELLCAST_CHANNEL_UPDATE" or eventName == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
    local _unitTarget, _castGUID, _spellID, castID = ...
    if self.castID == castID then
      self:UpdateForCast()
    end
  elseif eventName == "UNIT_SPELLCAST_INTERRUPTIBLE" or eventName == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
    if self.castID then
      self:UpdateForCast()
    end
  end
end

function addonTable.Display.CastBarMixin:Setup(details)
  self.details = details

  self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)

  self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 1)
  self.TextsContainer:SetFrameLevel(self.statusBar:GetFrameLevel() + 4)

  self.icon:SetShown(details.icon.show)

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

  addonTable.Display.ApplyTexts(self, details, textsByKey, details.scale)

  self:UpdateForCast()
end

function addonTable.Display.CastBarMixin:UpdateForCast()
  if self.timer then
    self.timer:Cancel()
  end

  local isChanneled = false
  local isEmpowered, numEmpowerStages
  local name, displayName, textureID, _, _, isTradeskill, _, notInterruptible, spellID, castID, delayTimeMs = UnitCastingInfo(self.unit)
  if name == nil then
    name, displayName, textureID, _, _, isTradeskill, notInterruptible, spellID, isEmpowered, numEmpowerStages, castID = UnitChannelInfo(self.unit)
    isChanneled = true
  end

  if name == nil then
    self:ClearCast()
    return
  end

  self:Show()

  self.castID = castID

  self.TextsContainer.Name:SetText(displayName)
  self.icon:SetTexture(textureID)

  local color, duration
  if isEmpowered then
    duration = UnitEmpoweredChannelDuration(self.unit, true)
    color = self.details.colors.empoweredStage3
  elseif isChanneled then
    duration = UnitChannelDuration(self.unit)
    color = self.details.colors.channeling
  else
    duration = UnitCastingDuration(self.unit)
    color = self.details.colors.casting
  end

  self.statusBar:SetTimerDuration(
    duration, nil,
    isChanneled and not isEmpowered and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime
  )
  self.TextsContainer.Duration:Show()
  self.DurationBinding:SetDuration(duration)
  self.DurationBinding:Enable()
  self.DurationBinding:UpdateFontString()

  self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)

  self.isChanneled = isChanneled
end

function addonTable.Display.CastBarMixin:UpdateForCastEnd(complete)
  if self.timer then
    self.timer:Cancel()
  end

  self.castID = nil

  if self.isChanneled then
    self:ClearCast()
    return
  end

  local color
  if complete then
    color = self.details.colors.complete
  else
    color = self.details.colors.interrupted
  end
  self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  self.statusBar:SetMinMaxValues(0, 1)
  self.statusBar:SetValue(1)
  self.TextsContainer.Duration:Hide()
  self.DurationBinding:Disable()

  self.timer = C_Timer.NewTimer(self.details.hideDelay, function()
    self:ClearCast()
    self.timer = nil
  end)
end

function addonTable.Display.CastBarMixin:ClearCast()
  self:Hide()
end

function addonTable.Display.CastBarMixin:GetDefaultSize()
  return self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
end

function addonTable.Display.CastBarMixin:ShouldCollapse()
  return false
end

function addonTable.Display.CastBarMixin:ApplySize(width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  self.sizingWidth, self.sizingHeight = sizing.rawWidth, sizing.rawHeight
  PixelUtil.SetSize(self, sizing.rawWidth, sizing.rawHeight)
  PixelUtil.SetSize(self.statusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
  if sizing.iconSize > 0 then
    self.icon:Show()
    PixelUtil.SetSize(self.icon, sizing.iconSize, sizing.iconSize)
  else
    self.icon:Hide()
  end

  self.icon:ClearAllPoints()
  self.statusBar:ClearAllPoints()
  self.TextsContainer.Duration:ClearAllPoints()
  if self.details.layout == "horizontal" then
    self.icon:SetPoint(self.details.icon.position == "left" and "LEFT" or "RIGHT")
    self.statusBar:SetPoint(self.details.icon.position == "left" and "RIGHT" or "LEFT")
  else
    self.icon:SetPoint(self.details.icon.position == "left" and "BOTTOM" or "TOP")
    self.statusBar:SetPoint(self.details.icon.position == "left" and "TOP" or "BOTTOM")
  end
  addonTable.Display.SizeTextsForBar(self, self.details, textsByKey, self.details.scale)
end

function addonTable.Display.CastBarMixin:ApplyPadding(horizontal, vertical)
  PixelUtil.SetSize(self, self.sizingWidth + horizontal, self.sizingHeight + vertical)
end
