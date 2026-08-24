---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

addonTable.Display.AbilityChargesPipMixin = {}

function addonTable.Display.AbilityChargesPipMixin:OnLoad()
  self:SetCollapsesLayout(true)
  self:SetIgnoringChildrenForBounds(true)

  addonTable.Display.GenerateStatusBar(self)
  self.offsetStatusBar = CreateFrame("StatusBar", nil, self)
  self.offsetStatusBar:SetStatusBarTexture("Interface/AddOns/Coolinator/Assets/Special/transparent.png")

  self.chargingStatusBar = CreateFrame("StatusBar", nil, self)
end

function addonTable.Display.AbilityChargesPipMixin:OnEvent(eventName, ...)
  self:Import()
end

function addonTable.Display.AbilityChargesPipMixin:Setup(details)
  self:RegisterEvent("SPELL_UPDATE_CHARGES")

  self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
  self.details = details
  self.index = details.index
  self.statusBar:SetMinMaxValues(self.index - 1, self.index)

  self.chargingStatusBar:SetScale(1/self.lowerScale * details.scale)
  local foregroundAsset = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")
  self.chargingStatusBar:SetStatusBarTexture(foregroundAsset)
  self.chargingStatusBar:SetAlpha(0.6)
  self.chargingStatusBar:GetStatusBarTexture():SetVertexColor(details.foreground.color.r, details.foreground.color.g, details.foreground.color.b)
  self.chargingStatusBar:GetStatusBarTexture():RemoveMaskTexture(self.borderMask)
  self.chargingStatusBar:GetStatusBarTexture():AddMaskTexture(self.borderMask)

  if details.layout == "vertical" then
    self.chargingStatusBar:SetOrientation("VERTICAL")
    self.offsetStatusBar:SetOrientation("VERTICAL")
  else
    self.chargingStatusBar:SetOrientation("HORIZONTAL")
    self.offsetStatusBar:SetOrientation("HORIZONTAL")
  end

  self.statusBar:SetFrameLevel(self.statusBar:GetFrameLevel() + 1)
  self.chargingStatusBar:SetFrameLevel(self.statusBar:GetFrameLevel() + 3)
  self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 5)

  self:Import()
end

function addonTable.Display.AbilityChargesPipMixin:Disable()
  self:UnregisterAllEvents()
end

function addonTable.Display.AbilityChargesPipMixin:Import()
  local chargesInfo = C_Spell.GetSpellCharges(self.details.resource.spellID)
  if chargesInfo.maxCharges < self.index then
    self:Hide()
    return
  end
  self:Show()

  self.maxCharges = chargesInfo.maxCharges

  self.statusBar:SetValue(chargesInfo.currentCharges)

  self.chargingStatusBar:SetShown(chargesInfo.isActive)
  self.offsetStatusBar:SetShown(chargesInfo.isActive)
  if chargesInfo.isActive then
    self.offsetStatusBar:SetMinMaxValues(0, self.maxCharges)
    self.offsetStatusBar:SetValue(chargesInfo.currentCharges)
    self.chargingStatusBar:SetTimerDuration(C_Spell.GetSpellChargeDuration(self.details.resource.spellID))
  end
end

function addonTable.Display.AbilityChargesPipMixin:ApplyPadding(horizontal, vertical)
  if not self:IsShown() then
    return
  end
  self:SetSize(self.sizingWidth + horizontal, self.sizingHeight + vertical)
end

function addonTable.Display.AbilityChargesPipMixin:GetDefaultSize()
  return self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
end

function addonTable.Display.AbilityChargesPipMixin:ApplySize(width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  self.sizingWidth, self.sizingHeight = sizing.rawWidth, sizing.rawHeight
  PixelUtil.SetSize(self, sizing.rawWidth, sizing.rawHeight)
  PixelUtil.SetSize(self.statusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
  if self.maxCharges then
    self.offsetStatusBar:ClearAllPoints()
    self.chargingStatusBar:ClearAllPoints()
    if self.details.layout == "horizontal" then
      PixelUtil.SetSize(self.offsetStatusBar, sizing.rawWidth * self.maxCharges, sizing.rawHeight)
      PixelUtil.SetPoint(self.offsetStatusBar, "LEFT", self, "LEFT", (1 - self.index) * sizing.rawWidth, 0)
      self.chargingStatusBar:SetPoint("LEFT", self.offsetStatusBar:GetStatusBarTexture(), "RIGHT")
    else
      PixelUtil.SetSize(self.offsetStatusBar, sizing.rawWidth, sizing.rawHeight * self.maxCharges)
      PixelUtil.SetPoint(self.offsetStatusBar, "BOTTOM", self, "BOTTOM", 0, (1 - self.index) * sizing.rawHeight)
      self.chargingStatusBar:SetPoint("BOTTOM", self.offsetStatusBar:GetStatusBarTexture(), "TOP")
    end
    PixelUtil.SetSize(self.chargingStatusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
  end
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
end

function addonTable.Display.AbilityChargesPipMixin:ShouldCollapse()
  return true
end
