---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.TotemIconMixin = {}

function addonTable.Display.TotemIconMixin:OnLoad()
  self:SetIgnoringChildrenForBounds(true)
  self:SetCollapsesLayout(true)
  self:SetFlattensRenderLayers(true)

  self.Icon = self:CreateTexture()
  self.Icon:SetSize(addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
  self.Icon:SetPoint("CENTER")

  self.BaseCooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
  self.BaseCooldown:SetAllPoints(self.Icon)
  self.BaseCooldown:SetDrawEdge(false)
  self.BaseCooldown:SetUseAuraDisplayTime(true)

  self.Glow = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.GlowMixin)
  self.Glow:SetAllPoints()

  self:SetScript("OnEnter", self.OnEnter)
  self:SetScript("OnLeave", self.OnLeave)

  self.BaseCooldown:SetScript("OnCooldownDone", function()
    self:Hide()
  end)
end

function addonTable.Display.TotemIconMixin:Enable(details)
  addonTable.CallbackRegistry:RegisterCallback("Update.Totems", self.UpdateTotem, self)
end

function addonTable.Display.TotemIconMixin:Disable(details)
  addonTable.CallbackRegistry:UnregisterCallback("Update.Totems", self)
end

function addonTable.Display.TotemIconMixin:Setup(details)
  self:SetCollapsesLayout(addonTable.Config.Get(addonTable.Config.Options.COMPRESS_LAYOUT))
  self.details = details

  local spellID = addonTable.Constants.Totems[details.resource.spellID]
  spellID = spellID ~= 0 and spellID or details.resource.spellID
  self.spellID = C_Spell.GetOverrideSpell(spellID)

  self.Icon:SetTexture(C_Spell.GetSpellTexture(self.details.resource.spellID))

  local usingGlow = addonTable.Constants.GlowsMap[details.whenActive] ~= nil
  self.Glow:SetShown(usingGlow)
  if usingGlow then
    self.Glow:SetAsset(addonTable.Constants.GlowsMap[details.whenActive], details.glowColor, details.glowReverse)
    self.Glow:SetFrameLevel(self:GetFrameLevel() + 4)
  end

  self:SetMouseMotionEnabled(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))

  self:Update()
  addonTable.Display.StyleIcon({id  = details.style}, self, self.Icon, nil, nil, {self.Icon}, {{text = true, swipe = true, widget = self.BaseCooldown}})
end

function addonTable.Display.TotemIconMixin:ApplyPadding(horizontal, vertical)
  self:SetSize(addonTable.Constants.nativeSize - 4 + horizontal, addonTable.Constants.nativeSize - 4 + vertical)
end

function addonTable.Display.TotemIconMixin:GetDefaultSize()
  local dim = addonTable.Constants.nativeSize - 4
  return dim, dim
end

function addonTable.Display.TotemIconMixin:Update()
  self.overrideTooltip = nil
  if not self:UpdateTotem() then
    self:UpdatePet()
  end
end

function addonTable.Display.TotemIconMixin:UpdateTotem()
  local spellIDToIndex = addonTable.Display.GetTotems()
  local index = spellIDToIndex[self.spellID]
  local duration = index and GetTotemDuration(index)
  if not duration then
    self:Hide()
    return
  end
  self:Show()
  local _, _, _, _, icon, spellID = GetTotemInfo(index)
  self.overrideTooltip = spellID
  self.Icon:SetTexture(icon)
  self.BaseCooldown:SetCooldownFromDurationObject(duration)

  return true
end

function addonTable.Display.TotemIconMixin:UpdatePet()
  local spellIDToIndex = addonTable.Display.GetTotemPets()
  local info = spellIDToIndex[self.spellID]
  if not info then
    self:Hide()
    return
  end
  local duration = C_DurationUtil.CreateDuration()
  duration:SetTimeFromStart(info.start, info.duration)
  self:Show()
  self.overrideTooltip = info.spellID
  local icon = C_Spell.GetSpellTexture(info.spellID)
  self.Icon:SetTexture(icon)

  self.BaseCooldown:SetCooldownFromDurationObject(duration)

  return true
end

function addonTable.Display.TotemIconMixin:OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, self)
  GameTooltip:SetSpellByID(self.overrideTooltip)
end

function addonTable.Display.TotemIconMixin:OnLeave()
  GameTooltip:Hide()
end
