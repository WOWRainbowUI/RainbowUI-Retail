---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

addonTable.Display.AuraStacksBaseMixin = {}

function addonTable.Display.AuraStacksBaseMixin:OnLoad()
  self:SetScript("OnShow", self.OnShow)
  self:SetScript("OnHide", self.OnHide)
  self:SetScript("OnEvent", self.OnEvent)
  self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
  self:SetCollapsesLayout(true)

  self.background = self:CreateTexture(nil, "BACKGROUND")
  self.background:SetPoint("CENTER")
  self.borderWrapper = CreateFrame("Frame", nil, self)
  self.borderWrapper:SetAllPoints()
  self.border = self.borderWrapper:CreateTexture(nil, "BORDER")
  self.border:SetPoint("CENTER", self)
  self.borderMask = self:CreateMaskTexture()
  self.borderMask:SetAllPoints(self.background)

  self.background:AddMaskTexture(self.borderMask)

  self.ButtonInit = function(auraButton)
    auraButton:SetMouseMotionEnabled(false)
    auraButton:SetIgnoringChildrenForBounds(true)
    auraButton.statusBar = CreateFrame("StatusBar", nil, auraButton)
    auraButton.statusBar:SetPoint("CENTER")
    auraButton.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", "Cooli: Solid Transparency"))

    auraButton.mask = auraButton:CreateMaskTexture()
    auraButton.mask:SetAllPoints(auraButton.statusBar:GetStatusBarTexture())
    auraButton.mask:SetBlockingLoadsRequested(true)
    auraButton.mask:SetTexture(LSM:Fetch("statusbar", "Cooli: Solid White"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

    auraButton.foreground = auraButton:CreateTexture(nil, "ARTWORK")
    auraButton.foreground:SetPoint("CENTER")

    auraButton.foreground:AddMaskTexture(self.borderMask)

    auraButton.foreground:AddMaskTexture(auraButton.mask)
    auraButton.statusBar:SetPoint("RIGHT", auraButton.foreground)

    auraButton:SetPoint("CENTER", self)
  end

  self.StyleButton = function(auraButton, details)
    auraButton:SetMouseMotionEnabled(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))
    auraButton.details = details

    local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Cooli: 1px")
    assert(borderDetails)
    local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)
    assert(borderSliceDetails)
    local foregroundAsset = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")

    auraButton:SetApplicationBar(auraButton.statusBar, {maxApplications = self.applicationLimit})

    auraButton.foreground:SetTexture(foregroundAsset)
    auraButton.foreground:SetVertexColor(details.foreground.color.r, details.foreground.color.g, details.foreground.color.b)
    auraButton.foreground:SetScale(borderSliceDetails.scaleModifier * details.scale)
  end
end

function addonTable.Display.AuraStacksBaseMixin:Setup(details)
  self.details = details

  self.sizingWidth, self.sizingHeight = nil, nil
  self.rawWidth, self.rawHeight = details.width * addonTable.Assets.BarBordersSize.width, details.height * addonTable.Assets.BarBordersSize.height
  if details.layout == "vertical" then
    local tmp = self.rawWidth
    self.rawWidth = self.rawHeight
    self.rawHeight = tmp
  end

  self.include = {
    includeSpellIDs = {[self.details.resource.spellID] = true},
    isFromPlayerOrPlayerPet = true,
  }

  if addonTable.State.CDM.auraMap[self.details.resource.spellID] then
    local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(addonTable.State.CDM.auraMap[self.details.resource.spellID])
    for _, spellID in ipairs(cooldownInfo.linkedSpellIDs) do
      self.include.includeSpellIDs[spellID] = true
    end
  end

  if self.helpfulButton then
    self.StyleButton(self.helpfulButton, details)
    self.StyleButton(self.helpfulPetButton, details)
    self.StyleButton(self.harmfulButton, details)

    addonTable.Display.SetAuraSlotsFilters(self.index, self.include, self.include)
  end

  local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Cooli: 1px")
  assert(borderDetails)
  local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)
  assert(borderSliceDetails)
  local backgroundAsset = LSM:Fetch("statusbar", details.background.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")

  local rawWidth, rawHeight = details.width * addonTable.Assets.BarBordersSize.width, details.height * addonTable.Assets.BarBordersSize.height
  if details.layout == "vertical" then
    local tmp = rawWidth
    rawWidth = rawHeight
    rawHeight = tmp
  end
  local borderWidth = rawWidth + (borderSliceDetails.padding.left + borderSliceDetails.padding.right) / 2
  local borderHeight = rawHeight + (borderSliceDetails.padding.top + borderSliceDetails.padding.bottom) / 2

  local lowerScale = 1/borderSliceDetails.scaleModifier

  self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = rawWidth, rawHeight, borderWidth, borderHeight, lowerScale

  self.background:SetTexture(backgroundAsset)
  self.background:SetVertexColor(details.background.color.r, details.background.color.g, details.background.color.b, details.background.color.a)
  self.background:SetScale(borderSliceDetails.scaleModifier * details.scale)

  local maskDetails = borderDetails.mask
  self.borderMask:SetBlockingLoadsRequested(true)
  self.borderMask:SetTexture(maskDetails.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  self.borderMask:SetTextureSliceMargins(maskDetails.margins.left, maskDetails.margins.top, maskDetails.margins.right, maskDetails.margins.bottom)

  self.border:SetTexture(borderSliceDetails.file)
  self.border:SetVertexColor(details.border.color.r, details.border.color.g, details.border.color.b, details.border.color.a)
  self.border:SetTextureSliceMargins(borderSliceDetails.margins.left, borderSliceDetails.margins.top, borderSliceDetails.margins.right, borderSliceDetails.margins.bottom)
  self.border:SetScale(borderSliceDetails.scaleModifier * details.scale)

  self.borderWrapper:SetFrameLevel(self:GetFrameLevel() + 5)
end

function addonTable.Display.AuraStacksBaseMixin:Enable()
  self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
end

function addonTable.Display.AuraStacksBaseMixin:Disable()
  self:UnregisterAllEvents()
end

function addonTable.Display.AuraStacksBaseMixin:ApplyPadding(horizontal, vertical)
  if addonTable.Utilities.IsAurasRestricted() then
    return
  end

  if not self.helpfulButton then
    self.index, self.helpfulButton, self.harmfulButton, self.helpfulPetButton = addonTable.Display.GeneratePlayerAuraSlots(
      {initializeFrame = function(auraButton)
        self.ButtonInit(auraButton)
        self.StyleButton(auraButton, self.details)
        self.SizeButton(auraButton, self.parentWidth, self.parentHeight)
        auraButton:SetSize(self.sizingWidth + horizontal, self.sizingHeight + vertical)
        auraButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
        auraButton:SetFrameLevel(self:GetFrameLevel() + 1)
      end, candidateFilters = self.include},
      {initializeFrame = function(auraButton)
        self.ButtonInit(auraButton)
        self.StyleButton(auraButton, self.details)
        self.SizeButton(auraButton, self.parentWidth, self.parentHeight)
        auraButton:SetSize(self.sizingWidth + horizontal, self.sizingHeight + vertical)
        auraButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
        auraButton:SetFrameLevel(self:GetFrameLevel() + 1)
      end, candidateFilters = self.include}
    )

  else
    self.helpfulButton:SetSize(self.sizingWidth + horizontal, self.sizingHeight + vertical)
    self.helpfulButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
    self.helpfulButton:SetFrameLevel(self:GetFrameLevel() + 1)

    self.helpfulPetButton:SetSize(self.sizingWidth + horizontal, self.sizingHeight + vertical)
    self.helpfulPetButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
    self.helpfulPetButton:SetFrameLevel(self:GetFrameLevel() + 1)

    self.harmfulButton:SetSize(self.sizingWidth + horizontal, self.sizingHeight + vertical)
    self.harmfulButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
    self.harmfulButton:SetFrameLevel(self:GetFrameLevel() + 1)
  end

  PixelUtil.SetSize(self, self.sizingWidth + horizontal, self.sizingHeight + vertical)
end

function addonTable.Display.AuraStacksBaseMixin:GetDefaultSize()
  return self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
end

function addonTable.Display.AuraStacksBaseMixin:ApplySize(width, height)
  self.parentWidth, self.parentHeight = width, height

  if addonTable.Utilities.IsAurasRestricted() then
    return
  end

  local rawWidth, rawHeight = self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
  if self.details.autoSize then
    if self.details.layout == "horizontal" and width ~= 0 then
      rawWidth = width or rawWidth
    end
    if self.details.layout == "vertical" and height ~= 0 then
      rawHeight = height or rawHeight
    end
  end

  local statusWidth, statusHeight = self.rawWidth, self.rawHeight
  local borderWidth, borderHeight = self.borderWidth, self.borderHeight
  statusWidth, statusHeight = rawWidth / self.details.scale, rawHeight / self.details.scale
  borderWidth = borderWidth + (statusWidth - self.rawWidth)
  borderHeight = borderHeight + (statusHeight - self.rawHeight)

  self.sizingWidth, self.sizingHeight = rawWidth, rawHeight
  self.statusWidth, self.statusHeight = statusWidth, statusHeight
  PixelUtil.SetSize(self.border, borderWidth * self.lowerScale, borderHeight * self.lowerScale)
  PixelUtil.SetSize(self.background, statusWidth * self.lowerScale, statusHeight * self.lowerScale)

  if self.helpfulButton then
    self.SizeButton(self.helpfulButton, width, height)
    self.SizeButton(self.helpfulPetButton, width, height)
    self.SizeButton(self.harmfulButton, width, height)
  end
end

function addonTable.Display.AuraStacksBaseMixin:OnShow()
  if self.index then
    addonTable.Display.SetAuraSlotsEnabled(self.index, true)
  end
end

function addonTable.Display.AuraStacksBaseMixin:OnHide()
  if self.index then
    addonTable.Display.SetAuraSlotsEnabled(self.index, false)
  end
end

function addonTable.Display.AuraStacksBaseMixin:OnEvent(_, restrictionType, state)
  if addonTable.Utilities.WillRestrictionApplySoon(restrictionType, state) then
    self.helpfulButton:SetAlpha(1)
    self.helpfulPetButton:SetAlpha(1)
    self.harmfulButton:SetAlpha(1)
  end
end

addonTable.Display.AuraStacksPipMixin = CreateFromMixins(addonTable.Display.AuraStacksBaseMixin)
function addonTable.Display.AuraStacksPipMixin:OnLoad()
  addonTable.Display.AuraStacksBaseMixin.OnLoad(self)

  self.ButtonInit = function(auraButton)
    auraButton:SetMouseMotionEnabled(false)
    auraButton:SetIgnoringChildrenForBounds(true)
    auraButton.statusBar = CreateFrame("StatusBar", nil, auraButton)
    auraButton.statusBar:SetPoint("CENTER")
    auraButton.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", "Cooli: Solid Transparency"))

    auraButton.mask = auraButton:CreateMaskTexture()
    auraButton.mask:SetAllPoints(auraButton.statusBar:GetStatusBarTexture())
    auraButton.mask:SetBlockingLoadsRequested(true)
    auraButton.mask:SetTexture(LSM:Fetch("statusbar", "Cooli: Solid White"), "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

    auraButton.foreground = auraButton:CreateTexture(nil, "ARTWORK")
    auraButton.foreground:SetPoint("CENTER")

    auraButton.foreground:AddMaskTexture(self.borderMask)

    auraButton.foreground:AddMaskTexture(auraButton.mask)
    auraButton.statusBar:SetPoint("RIGHT", auraButton.foreground)

    auraButton:SetPoint("CENTER", self)
  end

  self.StyleButton = function(auraButton, details)
    auraButton:SetMouseMotionEnabled(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))
    auraButton.details = details

    local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Cooli: 1px")
    assert(borderDetails)
    local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)
    assert(borderSliceDetails)
    local foregroundAsset = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")

    auraButton:SetApplicationBar(auraButton.statusBar, {maxApplications = self.applicationLimit})

    auraButton.foreground:SetTexture(foregroundAsset)
    auraButton.foreground:SetVertexColor(details.foreground.color.r, details.foreground.color.g, details.foreground.color.b)
    auraButton.foreground:SetScale(borderSliceDetails.scaleModifier * details.scale)
  end

  self.SizeButton = function(auraButton, width, height)
    PixelUtil.SetSize(auraButton.statusBar, (self.statusWidth * self.details.scale + 5) * self.applicationLimit, self.statusHeight * self.details.scale)
    PixelUtil.SetSize(auraButton.foreground, self.statusWidth * self.lowerScale, self.statusWidth * self.lowerScale)
  end
end

function addonTable.Display.AuraStacksPipMixin:Enable()
  addonTable.Display.AuraStacksBaseMixin.Enable(self)
  self:SetShown(self.cumulativeApplications >= self.details.index)
end

function addonTable.Display.AuraStacksPipMixin:Setup(details)
  self.applicationLimit = details.index
  self.cumulativeApplications = addonTable.Constants.AuraStackOverrides[details.resource.spellID] or C_Spell.GetSpellMaxCumulativeAuraApplications(details.resource.spellID)

  addonTable.Display.AuraStacksBaseMixin.Setup(self, details)
end

local textsByKey = {
  Applications = "applications",
}

local formatter = C_StringUtil.CreateNumericRuleFormatter()
formatter:AddBreakpoint({
  threshold = 0,
  format = "",
})
formatter:AddBreakpoint({
  threshold = 1,
  format = "%d",
})

addonTable.Display.AuraStacksBarMixin = CreateFromMixins(addonTable.Display.AuraStacksBaseMixin)
function addonTable.Display.AuraStacksBarMixin:OnLoad()
  addonTable.Display.AuraStacksBaseMixin.OnLoad(self)

  self.ButtonInit = function(auraButton)
    auraButton:SetMouseMotionEnabled(false)
    auraButton:SetIgnoringChildrenForBounds(true)
    auraButton.statusBar = CreateFrame("StatusBar", nil, auraButton)
    auraButton.statusBar:SetPoint("CENTER")
    auraButton.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", "Cooli: Solid Transparency"))
    auraButton.statusBar:GetStatusBarTexture():AddMaskTexture(self.borderMask)

    auraButton.statusBar:SetPoint("CENTER")

    auraButton.TextsContainer = CreateFrame("Frame", nil, auraButton)
    auraButton.TextsContainer:SetAllPoints(auraButton.statusBar)
    auraButton.TextsContainer.Applications = auraButton.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
    auraButton:SetApplicationCount(auraButton.TextsContainer.Applications, {formatter = formatter})

    auraButton:SetPoint("CENTER", self)
  end

  self.StyleButton = function(auraButton, details)
    auraButton:SetMouseMotionEnabled(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))
    auraButton.details = details

    local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Cooli: 1px")
    assert(borderDetails)
    local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)
    assert(borderSliceDetails)
    local foregroundAsset = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")

    auraButton:SetApplicationBar(auraButton.statusBar, {maxApplications = self.applicationLimit, interpolation = Enum.StatusBarInterpolation.ExponentialEaseOut})

    auraButton.statusBar:SetStatusBarTexture(foregroundAsset)
    auraButton.statusBar:GetStatusBarTexture():SetVertexColor(details.foreground.color.r, details.foreground.color.g, details.foreground.color.b)
    auraButton.statusBar:SetScale(borderSliceDetails.scaleModifier * details.scale)

    auraButton.TextsContainer:SetFrameLevel(auraButton.statusBar:GetFrameLevel() + 4)
    addonTable.Display.ApplyTexts(auraButton, details, textsByKey, details.scale)
  end

  self.SizeButton = function(auraButton, width, height)
    PixelUtil.SetSize(auraButton.statusBar, self.statusWidth * self.lowerScale, self.statusHeight * self.lowerScale)

    auraButton.sizingWidth, auraButton.sizingHeight = self.sizingWidth, self.sizingHeight
    auraButton.TextsContainer.Applications:ClearAllPoints()
    addonTable.Display.SizeTextsForBar(auraButton, self.details, textsByKey, self.details.scale)
  end
end

function addonTable.Display.AuraStacksBarMixin:Setup(details)
  self.applicationLimit = addonTable.Constants.AuraStackOverrides[details.resource.spellID] or C_Spell.GetSpellMaxCumulativeAuraApplications(details.resource.spellID)

  self:Show()

  addonTable.Display.AuraStacksBaseMixin.Setup(self, details)
end
