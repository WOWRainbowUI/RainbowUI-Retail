---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.AuraStatusBarMixin = CreateFromMixins(addonTable.Display.BaseDurationStatusBarMixin)

function addonTable.Display.AuraStatusBarMixin:OnLoad()
  addonTable.Display.BaseDurationStatusBarMixin.OnLoad(self)

  self:SetScript("OnEvent", self.OnEvent)

  self.TextsContainer.Charges = self.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
end

function addonTable.Display.AuraStatusBarMixin:Enable(details)
  self:RegisterEvent("SPELL_UPDATE_COOLDOWN")

  addonTable.CallbackRegistry:RegisterCallback("Update.SpellIcons", function(_, spellID)
    if self.spellID and (not spellID or C_Spell.GetBaseSpell(self.spellID) == spellID) then
      self.Icon:SetTexture(C_Spell.GetSpellTexture(self.spellID))
    end
  end, self)

  addonTable.CallbackRegistry:RegisterCallback("Update.SpellsDisplay", function(_, spellID)
    if not self.spellID then
      return
    end
    local override = C_Spell.GetOverrideSpell(self.details.resource.spellID)
    if override ~= self.spellID then
      self:UpdateSpellByID(override)
    end
  end, self)
end

function addonTable.Display.AuraStatusBarMixin:Disable(details)
  self:UnregisterAllEvents()

  if self.ticker then
    self.ticker:Cancel()
  end
end

function addonTable.Display.AuraStatusBarMixin:OnEvent()
  self:UpdateSpellByID(self.spellID)
end

function addonTable.Display.AuraStatusBarMixin:Setup(details)
  addonTable.Display.BaseDurationStatusBarMixin.Setup(self. details)

  self:UpdateForAura()
end

function addonTable.Display.AuraStatusBarMixin:ApplySize(width, height)
  addonTable.Display.BaseDurationStatusBarMixin.ApplySize(self, width, height)
  PixelUtil.SetPoint(self.TextsContainer.Charges, "BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", -5, 5)
end

function addonTable.Display.AuraStatusBarMixin:UpdateForAura()
  local auraDetails = C_UnitAuras.GetUnitAuraBySpellID("player", self.details.resource.spellID)

  if not auraDetails or self.unit == "target" and auraDetails.sourceUnit ~= "player" then
    self:Hide()
    return
  end
  self:Show()

  self.auraInstanceID = auraDetails.auraInstanceID
  self.Icon:SetTexture(auraDetails.icon)
  self.statusBar:SetTimerDuration(C_UnitAuras.GetAuraDuration(self.unit, auraDetails.auraInstanceID))
end
