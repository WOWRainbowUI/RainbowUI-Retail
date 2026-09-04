---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.AuraInvertedIconMixin = {}

local offsetSize = addonTable.Constants.nativeSize - 4
local wrapperSize = 100

function addonTable.Display.AuraInvertedIconMixin:OnLoad()
  self:SetSize(offsetSize, offsetSize)
  self:SetIgnoringChildrenForBounds(true)

  self:SetScript("OnShow", self.OnShow)
  self:SetScript("OnHide", self.OnHide)

  self.ButtonInit = function(auraButton)
    auraButton:SetCollapsesLayout(true)
    auraButton:SetMouseMotionEnabled(false)
  end

  self.SizeButton = function(auraButton, details)
    local dim = PixelUtil.ConvertPixelsToUIForRegion(wrapperSize, self)
    auraButton:SetSize(dim, dim)
    auraButton:SetScale(self:GetEffectiveScale() / UIParent:GetScale())
  end

  self.Container = CreateFrame("Frame", nil, self)
  self.Container:SetPoint("CENTER")
  self.Container:SetClipsChildren(true)
  self.AuraWrapper = CreateFrame("Frame", nil, self)
  self.AuraWrapper:SetPoint("TOPLEFT", self.Container)
  self.AuraWrapper.sizing = CreateFrame("Frame", nil, self.AuraWrapper, "DisableUntrustedLayoutScriptsTemplate")
  self.AuraWrapper.sizing:SetSize(0.0001, 0.0001)
  self.iconWrapper = CreateFrame("Frame", nil, self.Container)
  self.iconWrapper:SetPoint("TOPLEFT", self.AuraWrapper, "TOPRIGHT")
  self.Icon = self.iconWrapper:CreateTexture()
  self.Icon:SetPoint("CENTER")
  self.iconWrapper.Icon = self.Icon

  self.Glow = addonTable.Utilities.InitFrameWithMixin(self.iconWrapper, addonTable.Display.GlowMixin)
  self.Glow:SetAllPoints(self.Icon)
  self.Glow:Hide()
end

function addonTable.Display.AuraInvertedIconMixin:Enable()
end

function addonTable.Display.AuraInvertedIconMixin:Disable()
end

function addonTable.Display.AuraInvertedIconMixin:IgnoreForSizing()
  return false
end

function addonTable.Display.AuraInvertedIconMixin:GetDefaultSize()
  return offsetSize, offsetSize
end

function addonTable.Display.AuraInvertedIconMixin:ApplyPadding(horizontal, vertical)
  if addonTable.Utilities.IsAurasRestricted() then
    return
  end

  if not self.helpfulButton then
    local prev
    self.index, self.helpfulButton, self.harmfulButton, self.helpfulPetButton = addonTable.Display.GeneratePlayerAuraSlots(
      {initializeFrame = function(auraButton)
        self.ButtonInit(auraButton)
        self.SizeButton(auraButton, self.details)
        if not prev then
          auraButton:SetPoint("LEFT", self.Container, "LEFT")
        else
          auraButton:SetPoint("LEFT", prev, "RIGHT")
        end
        self.AuraWrapper.sizing:SetPoint("LEFT", auraButton, "RIGHT")
        prev = auraButton
      end, candidateFilters = self.include},
      {initializeFrame = function(auraButton)
        self.ButtonInit(auraButton)
        self.SizeButton(auraButton, self.details)
        if not prev then
          auraButton:SetPoint("LEFT", self.Container, "LEFT")
        else
          auraButton:SetPoint("LEFT", prev, "RIGHT")
        end
        self.AuraWrapper.sizing:SetPoint("LEFT", auraButton, "RIGHT")
        prev = auraButton
      end, candidateFilters = self.include}
    )

  else
    self.SizeButton(self.helpfulButton, self.details)
    self.SizeButton(self.helpfulPetButton, self.details)
    self.SizeButton(self.harmfulButton, self.details)
  end

  PixelUtil.SetSize(self, offsetSize + horizontal, offsetSize + vertical)
end

function addonTable.Display.AuraInvertedIconMixin:Setup(details)
  self.details = details
  self.iconWrapper.details = details

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
    addonTable.Display.SetAuraSlotsFilters(self.index, self.include, self.include)
  end

  self.Icon:SetTexture(C_Spell.GetSpellTexture(self.details.resource.spellID))
  addonTable.Display.StyleIcon({id = details.style}, self.iconWrapper, self.Icon, nil, nil, {self.Icon}, {})

  if addonTable.Constants.GlowsMap[details.whenInactive] then
    self.Glow:Show()
    self.Glow:SetAsset(addonTable.Constants.GlowsMap[details.whenInactive], details.glowColor, details.glowReverse)
  else
    self.Glow:Hide()
  end
end

function addonTable.Display.AuraInvertedIconMixin:ApplySize()
  local dim = PixelUtil.ConvertPixelsToUIForRegion(wrapperSize, self)
  self.iconWrapper:SetSize(dim, dim)
  self.Container:SetSize(dim, dim)
end

function addonTable.Display.AuraInvertedIconMixin:OnShow()
  if self.index then
    addonTable.Display.SetAuraSlotsEnabled(self.index, true)
  end
end

function addonTable.Display.AuraInvertedIconMixin:OnHide()
  if self.index then
    addonTable.Display.SetAuraSlotsEnabled(self.index, false)
  end
end

function addonTable.Display.AuraInvertedIconMixin:TriggerLayout()
  self:SetIgnoringChildrenForBounds(false)
  self.AuraWrapper:SetSize(0.001, 0.001)
  self.AuraWrapper:ResizeToBoundsRect()
  self:SetIgnoringChildrenForBounds(true)
end
