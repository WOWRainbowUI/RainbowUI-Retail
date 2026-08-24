---@class addonTableCoolinator
local addonTable = select(2, ...)

local frame = CreateFrame("Frame")
frame:RegisterUnitEvent("UNIT_AURA", "player", "target")
frame:RegisterUnitEvent("UNIT_TARGET", "player")
frame:SetScript("OnEvent", function()
  addonTable.CallbackRegistry:TriggerEvent("Classic.AuraUpdate")
end)

addonTable.Display.AuraIconMixin = {}
function addonTable.Display.AuraIconMixin:OnLoad()
  self:SetSize(addonTable.Constants.nativeSize - 4, addonTable.Constants.nativeSize - 4)
  self:SetFlattensRenderLayers(true)

  self.Icon = self:CreateTexture(nil, "ARTWORK")
  self.Icon:SetSize(addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
  self.Icon:SetPoint("CENTER")

  self.BaseCooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
  self.BaseCooldown:SetAllPoints()
  self.BaseCooldown:SetDrawEdge(false)

  self.CountFrame = CreateFrame("Frame", nil, self)
  self.CountFrame:SetAllPoints()
  self.CountFrame.text = self.CountFrame:CreateFontString(nil, nil, "NumberFontNormal")
  self.CountFrame.text:SetPoint("BOTTOMRIGHT", -2, -2)

  self.DebuffBorder = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.AuraDebuffBorderMixin)
  self.DebuffBorder:SetAllPoints(self.Icon)

  self:SetScript("OnEnter", self.OnEnter)
  self:SetScript("OnLeave", self.OnLeave)

  addonTable.CallbackRegistry:RegisterCallback("UpdateKeyBindings", function(_, spellID)
    self:UpdateBindingText()
  end, self)
end

function addonTable.Display.AuraIconMixin:Disable()
  addonTable.CallbackRegistry:UnregisterCallback("Classic.AuraUpdate", self)
end

function addonTable.Display.AuraIconMixin:Setup(sourceWidget, details)
  self.details = details
  local texture = C_Spell.GetSpellTexture(details.resource.spellID)
  self.Icon:SetDesaturated(not addonTable.Utilities.IsAuraSpellKnown(details.resource.spellID) or false)
  self.DebuffBorder:Show()
  self.DebuffBorder:Setup(details)
  self.DebuffBorder:SetFrameLevel(self:GetFrameLevel() + 4)
  self.Icon:SetTexture(texture)
  self.CountFrame.text:SetText("")

  self.unit = addonTable.Constants.ClassicAuraIsHarmful[details.resource.spellID] and "target" or "player"

  self:SetMouseMotionEnabled(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))

  addonTable.Display.StyleIcon({id = self.details.style}, self, self.Icon, self.CountFrame.text, self.KeyBindingFrame.text, {self.Icon}, {{swipe = true, text = true, widget = self.BaseCooldown}})

  addonTable.CallbackRegistry:RegisterCallback("Classic.AuraUpdate", self.UpdateForAura, self)
  self:UpdateForAura()
end

function addonTable.Display.AuraIconMixin:DoesSpellIDApply(spellID)
  return self.details and self.details.resource.spellID == spellID
end

function addonTable.Display.AuraIconMixin:UpdateForAura()
  local auraDetails = C_UnitAuras.GetUnitAuraBySpellID("player", self.details.resource.spellID)

  if not auraDetails or self.unit == "target" and auraDetails.sourceUnit ~= "player" then
    self:Hide()
    return
  end
  self:Show()

  self.auraInstanceID = auraDetails.auraInstanceID
  self.Icon:SetTexture(auraDetails.icon)
  self.BaseCooldown:SetCooldownFromDurationObject(C_UnitAuras.GetAuraDuration(self.unit, auraDetails.auraInstanceID))
end

function addonTable.Display.AuraIconMixin:OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, self)
  GameTooltip:SetUnitAuraByAuraInstanceID(self.player, self.auraInstanceID)
end

function addonTable.Display.AuraIconMixin:OnLeave()
  GameTooltip:Hide()
end
