---@class addonTableCoolinator
local addonTable = select(2, ...)

local textsByKey = {
  Duration = "duration",
  Name = "name",
}

addonTable.Display.AuraStatusBarNextMixin = {}

function addonTable.Display.AuraStatusBarNextMixin:OnLoad()
  self:SetScript("OnShow", self.OnShow)
  self:SetScript("OnHide", self.OnHide)
  self:SetScript("OnEvent", self.OnEvent)

  self.ButtonInit = function(auraButton)
    auraButton:SetCollapsesLayout(true)
    auraButton:SetIgnoringChildrenForBounds(true)
    auraButton.statusBar = CreateFrame("StatusBar", nil, auraButton)
    auraButton.statusBar:SetPoint("CENTER")
    auraButton:SetDurationBar(auraButton.statusBar, {direction = Enum.StatusBarTimerDirection.RemainingTime})

    auraButton.background = auraButton.statusBar:CreateTexture(nil, "BACKGROUND")
    auraButton.background:SetAllPoints(auraButton.statusBar)
    auraButton.borderWrapper = CreateFrame("Frame", nil, auraButton)
    auraButton.borderWrapper:SetAllPoints()
    auraButton.border = auraButton.borderWrapper:CreateTexture(nil, "BORDER")
    auraButton.border:SetPoint("CENTER", auraButton.statusBar)
    auraButton.borderMask = auraButton.statusBar:CreateMaskTexture()
    auraButton.borderMask:SetAllPoints(auraButton.statusBar)

    auraButton.Icon = auraButton:CreateTexture(nil, "OVERLAY")
    auraButton.Icon:SetSize(addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
    auraButton.Icon:SetPoint("CENTER")
    auraButton:SetIcon(auraButton.Icon)

    auraButton.TextsContainer = CreateFrame("Frame", nil, auraButton)
    auraButton.TextsContainer:SetAllPoints()
    auraButton.TextsContainer.Charges = auraButton.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
    auraButton:SetApplicationCount(auraButton.TextsContainer.Charges)
    auraButton.TextsContainer.Duration = auraButton.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
    auraButton.TextsContainer.Name = auraButton.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
    auraButton:SetSpellName(auraButton.TextsContainer.Name)

    auraButton:SetPoint("TOPLEFT", self)

    local sizeAssistant = CreateFrame("Frame", nil, self, "DisableUntrustedLayoutScriptsTemplate")
    sizeAssistant:SetSize(0.001, 0.001)
    sizeAssistant:SetPoint("TOPLEFT", auraButton, "BOTTOMRIGHT")
  end

  self.StyleButton = function(auraButton, details, durationFormat)
    auraButton:SetCollapsesLayout(addonTable.Config.Get(addonTable.Config.Options.COMPRESS_LAYOUT))
    auraButton.details = details
    auraButton.rawWidth, auraButton.rawHeight, auraButton.borderWidth, auraButton.borderHeight, auraButton.lowerScale = addonTable.Display.ApplyStatusBar(details, auraButton.statusBar, auraButton.border, auraButton.borderMask, auraButton.background)
    auraButton.borderWrapper:SetFrameLevel(auraButton.statusBar:GetFrameLevel() + 2)
    auraButton.TextsContainer:SetFrameLevel(auraButton.statusBar:GetFrameLevel() + 4)
    auraButton:SetDurationText(auraButton.TextsContainer.Duration, durationFormat)
    auraButton:SetMouseMotionEnabled(false and addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))

    addonTable.Display.ApplyTexts(auraButton, details, textsByKey, details.scale)

    auraButton.Icon:SetShown(details.icon.show)
  end

  self.SizeButton = function(auraButton, width, height)
    local sizing = addonTable.Display.GetSizingForStatusBar(auraButton, width, height)
    auraButton.sizingWidth, auraButton.sizingHeight = sizing.rawWidth, sizing.rawHeight
    self.sizingWidth, self.sizingHeight = sizing.rawWidth, sizing.rawHeight
    PixelUtil.SetSize(auraButton.statusBar, sizing.statusWidth * auraButton.lowerScale, sizing.statusHeight * auraButton.lowerScale)
    PixelUtil.SetSize(auraButton.border, sizing.borderWidth * auraButton.lowerScale, sizing.borderHeight * auraButton.lowerScale)
    if sizing.iconSize > 0 then
      auraButton.Icon:Show()
      auraButton.TextsContainer.Charges:Show()
      PixelUtil.SetPoint(auraButton.TextsContainer.Charges, "BOTTOMRIGHT", auraButton.Icon, "BOTTOMRIGHT", -5, 5)
      PixelUtil.SetSize(auraButton.Icon, sizing.iconSize, sizing.iconSize)
    else
      auraButton.Icon:Hide()
      auraButton.TextsContainer.Charges:Hide()
    end

    auraButton.Icon:ClearAllPoints()
    auraButton.statusBar:ClearAllPoints()
    auraButton.TextsContainer.Duration:ClearAllPoints()
    if auraButton.details.layout == "horizontal" then
      auraButton.Icon:SetPoint(auraButton.details.icon.position == "left" and "LEFT" or "RIGHT")
      auraButton.statusBar:SetPoint(auraButton.details.icon.position == "left" and "RIGHT" or "LEFT")
    else
      auraButton.Icon:SetPoint(auraButton.details.icon.position == "left" and "BOTTOM" or "TOP")
      auraButton.statusBar:SetPoint(auraButton.details.icon.position == "left" and "TOP" or "BOTTOM")
    end

    addonTable.Display.SizeTextsForBar(auraButton, auraButton.details, textsByKey, auraButton.details.scale)
  end
end

function addonTable.Display.AuraStatusBarNextMixin:GetDefaultSize()
  return 0, 0
end

function addonTable.Display.AuraStatusBarNextMixin:GetApplicableSize()
  return self.sizingWidth, self.sizingHeight
end

function addonTable.Display.AuraStatusBarNextMixin:Enable()
  self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
end

function addonTable.Display.AuraStatusBarNextMixin:Disable(details)
  self:UnregisterAllEvents()
end

function addonTable.Display.AuraStatusBarNextMixin:TriggerLayout()
  self:SetIgnoringChildrenForBounds(false)
  self:SetSize(0.001, 0.001)
  self:ResizeToBoundsRect()
  self:SetIgnoringChildrenForBounds(true)

  if self.helpfulButton:CanBeAccessedInContext() then
    self.helpfulButton:SetAlpha(self:GetEffectiveAlpha())
    self.harmfulButton:SetAlpha(self:GetEffectiveAlpha())
  end
end

function addonTable.Display.AuraStatusBarNextMixin:Setup(details)
  self.details = details

  self.sizingWidth, self.sizingHeight = nil, nil

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

  self.include = {
    includeSpellIDs = {[self.details.resource.spellID] = true}
  }
  if addonTable.State.CDM.auraMap[self.details.resource.spellID] then
    local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(addonTable.State.CDM.auraMap[self.details.resource.spellID])
    for _, spellID in ipairs(cooldownInfo.linkedSpellIDs) do
      self.include.includeSpellIDs[spellID] = true
    end
  end

  self.durationFormat = {
    textFormat = {
      formatString = format,
      components = components,
    }
  }

  if self.helpfulButton then
    self.StyleButton(self.helpfulButton, details, self.durationFormat)
    self.StyleButton(self.harmfulButton, details, self.durationFormat)

    addonTable.Display.SetAuraSlotsFilters(self.index, self.include, self.include)
  end
end

function addonTable.Display.AuraStatusBarNextMixin:IgnoreForSizing()
  return true
end

function addonTable.Display.AuraStatusBarNextMixin:ApplyPadding(horizontal, vertical)
  if addonTable.Utilities.IsAurasRestricted() then
    return
  end

  if not self.helpfulButton then
    self.index, self.helpfulButton, self.harmfulButton = addonTable.Display.GeneratePlayerAuraSlots(
      {initializeFrame = function(auraButton)
        self.ButtonInit(auraButton)
        self.StyleButton(auraButton, self.details, self.durationFormat)
        self.SizeButton(auraButton, self.parentWidth, self.parentHeight)
        auraButton:SetSize(auraButton.sizingWidth + horizontal, auraButton.sizingHeight + vertical)
        auraButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
        auraButton:SetFrameLevel(self:GetFrameLevel() + 1)
      end, candidateFilters = self.include},
      {initializeFrame = function(auraButton)
        self.ButtonInit(auraButton)
        self.StyleButton(auraButton, self.details, self.durationFormat)
        self.SizeButton(auraButton, self.parentWidth, self.parentHeight)
        auraButton:SetSize(auraButton.sizingWidth + horizontal, auraButton.sizingHeight + vertical)
        auraButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
        auraButton:SetFrameLevel(self:GetFrameLevel() + 1)
      end, candidateFilters = self.include}
    )

  else
    self.helpfulButton:SetSize(self.helpfulButton.sizingWidth + horizontal, self.helpfulButton.sizingHeight + vertical)
    self.helpfulButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
    self.helpfulButton:SetFrameLevel(self:GetFrameLevel() + 1)

    self.harmfulButton:SetSize(self.harmfulButton.sizingWidth + horizontal, self.harmfulButton.sizingHeight + vertical)
    self.harmfulButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
    self.harmfulButton:SetFrameLevel(self:GetFrameLevel() + 1)
  end
end

function addonTable.Display.AuraStatusBarNextMixin:ApplySize(width, height)
  self.parentWidth, self.parentHeight = width, height

  if addonTable.Utilities.IsAurasRestricted() then
    return
  end

  if self.helpfulButton then
    self.SizeButton(self.helpfulButton, width, height)
  end

  if self.harmfulButton then
    self.SizeButton(self.harmfulButton, width, height)
  end
end

function addonTable.Display.AuraStatusBarNextMixin:OnShow()
  if self.index then
    addonTable.Display.SetAuraSlotsEnabled(self.index, true)
  end
end

function addonTable.Display.AuraStatusBarNextMixin:OnHide()
  if self.index then
    addonTable.Display.SetAuraSlotsEnabled(self.index, false)
  end
end

function addonTable.Display.AuraStatusBarNextMixin:OnEvent(_, restrictionType, state)
  if addonTable.Utilities.WillRestrictionApplySoon(restrictionType, state) then
    self.helpfulButton:SetAlpha(1)
    self.harmfulButton:SetAlpha(1)
  end
end
