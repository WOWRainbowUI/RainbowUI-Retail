---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.AbilityStatusBarMixin = CreateFromMixins(addonTable.Display.BaseDurationStatusBarMixin)

function addonTable.Display.AbilityStatusBarMixin:OnLoad()
  addonTable.Display.BaseDurationStatusBarMixin.OnLoad(self)
  self:SetScript("OnEvent", self.OnEvent)
end

function addonTable.Display.AbilityStatusBarMixin:Enable(details)
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

function addonTable.Display.AbilityStatusBarMixin:Disable(details)
  self:UnregisterAllEvents()

  addonTable.CallbackRegistry:UnregisterCallback("Update.SpellIcons", self)
  addonTable.CallbackRegistry:UnregisterCallback("Update.SpellsDisplay", self)

  if self.ticker then
    self.ticker:Cancel()
  end
end

function addonTable.Display.AbilityStatusBarMixin:OnEvent()
  self:UpdateSpellByID(self.spellID)
end

function addonTable.Display.AbilityStatusBarMixin:Setup(details)
  addonTable.Display.BaseDurationStatusBarMixin.Setup(self, details)

  self.ignoreGCD = details.resource.spellID ~= addonTable.Constants.GCD and not addonTable.Config.Get(addonTable.Config.Options.SHOW_GCD_SWIPE)
  self:UpdateSpellByID(addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID) or details.resource.spellID)
end

function addonTable.Display.AbilityStatusBarMixin:UpdateSpellByID(spellID)
  self.spellID = spellID

  self.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))

  if self.ticker then
    self.ticker:Cancel()
  end

  local baseDuration = C_Spell.GetSpellCooldownDuration(spellID, self.ignoreGCD)
  self.statusBar:SetTimerDuration(baseDuration, nil, Enum.StatusBarTimerDirection.RemainingTime)

  self.DurationBinding:SetDuration(baseDuration)
  self.DurationBinding:Enable()
  self.DurationBinding:UpdateFontString()

  if C_Spell.IsSpellDataCached(spellID) then
    self.TextsContainer.Name:SetText(C_Spell.GetSpellName(spellID))
  else
    Spell:CreateFromSpellID(spellID):ContinueOnSpellLoad(function()
      self.TextsContainer.Name:SetText(C_Spell.GetSpellName(spellID))
    end)
  end

  local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
  self:SetShown(cooldownInfo.isActive and (not self.ignoreGCD or not cooldownInfo.isOnGCD))
  if not self:IsShown() then
    self:Collapse()
    if self.ticker then
      self.ticker:Cancel()
      self.ticker = nil
    end
  else
    self:Expand()

    self.ticker = C_Timer.NewTicker(0.1, function()
      cooldownInfo = C_Spell.GetSpellCooldown(spellID)
      self:SetShown(cooldownInfo.isActive and (not self.ignoreGCD or not cooldownInfo.isOnGCD))
      if not self:IsShown() then
        self:SetSize(0.001, 0.001)
        self.ticker:Cancel()
        self.ticker = nil
      end
    end)
  end
end
