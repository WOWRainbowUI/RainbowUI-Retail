---@class addonTableCoolinator
local addonTable = select(2, ...)

local offsetSize = addonTable.Constants.nativeSize - 4

addonTable.Display.CooldownMixin = {}
function addonTable.Display.CooldownMixin:OnLoad()
  self:SetSize(offsetSize, offsetSize)
  self:SetFlattensRenderLayers(true)
  self:SetCollapsesLayout(true)
  self:SetIgnoringChildrenForBounds(true)

  self.Icon = self:CreateTexture(nil, "ARTWORK")
  self.Icon:SetPoint("CENTER")
  self.NotUsable = self:CreateTexture(nil, "OVERLAY")
  self.NotUsable:SetAllPoints(self.Icon)
  self.NotUsable:SetTexture("Interface/AddOns/Coolinator/Assets/Special/white.png")
  self.NotUsable:SetVertexColor(0, 0, 0, 0.5)

  self.ChargesCooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
  self.ChargesCooldown:SetAllPoints(self.Icon)
  self.ChargesCooldown:SetDrawSwipe(false)
  self.ChargesCooldown:SetDrawBling(false)

  self.BaseCooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
  self.BaseCooldown:SetAllPoints(self.Icon)
  self.BaseCooldown:SetDrawEdge(false)
  self.BaseCooldown:SetDrawBling(false)

  self.TextsContainer = CreateFrame("Frame", nil, self)
  self.TextsContainer:SetAllPoints(self.Icon)
  self.TextsContainer.count = self.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
  self.TextsContainer.keybinding = self.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
  self.TextsContainer.keybinding:SetWordWrap(false)

	self.SpellActivationAlert = CreateFrame("Frame", nil, self, "ActionButtonSpellAlertTemplate")
	self.SpellActivationAlert:SetPoint("CENTER")
	self.SpellActivationAlert:SetFrameStrata("MEDIUM")

  self.Glow = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.GlowMixin)
  self.Glow:SetAllPoints(self.Icon)
  self.Glow:Hide()

  self:SetScript("OnEvent", self.OnEvent)
  self:SetScript("OnEnter", self.OnEnter)
  self:SetScript("OnLeave", self.OnLeave)

  self:SetAttribute("ping-receiver", true);

  self.spellCallback = function(kind)
    if kind == "cooldown" then
      self:UpdateSpellCooldowns()
    elseif kind == "chargesValue" then
      self:UpdateSpellCharges()
    elseif kind == "usable" then
      self:UpdateUsable()
    elseif kind == "range" then
      self:UpdateRange()
    end
  end
end

function addonTable.Display.CooldownMixin:Style()
  addonTable.Display.StyleIcon({id = self.details.style}, self, self.Icon, self.TextsContainer.count, self.TextsContainer.keybinding,
    {self.Icon, self.NotUsable},
    {{swipe = true, text = true, widget = self.BaseCooldown}, {text = true, widget = self.ChargesCooldown},}
  )
end

function addonTable.Display.CooldownMixin:GetDefaultSize()
  return offsetSize, offsetSize
end

function addonTable.Display.CooldownMixin:ApplyPadding(horizontal, vertical)
  self.paddingH, self.paddingV = horizontal, vertical
  local width, height = PixelUtil.ConvertPixelsToUIForRegion(offsetSize + horizontal, self), PixelUtil.ConvertPixelsToUIForRegion(offsetSize + vertical, self)
  self:SetSize(width, height)
  PixelUtil.SetSize(self.SpellActivationAlert, width * 1.4, height * 1.4);
end

function addonTable.Display.CooldownMixin:OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, self)
  if self.spellID then
    GameTooltip:SetSpellByID(self.spellID)
  elseif self.itemID then
    GameTooltip:SetSpellByID(select(2, C_Item.GetItemSpell(self.itemID)))
  elseif self.equipmentSlot then
    GameTooltip:SetInventoryItem("player", self.equipmentSlot)
  end
end

function addonTable.Display.CooldownMixin:OnLeave()
  GameTooltip:Hide()
end

function addonTable.Display.CooldownMixin:OnEvent(eventName, ...)
  local data = ...
  if eventName == "SPELL_UPDATE_COOLDOWN" then
    if self.itemID then
      self:UpdateItemCooldowns()
    elseif self.equipmentSlot then
      self:UpdateEquipmentCooldowns()
    end
  elseif eventName == "BAG_UPDATE_COOLDOWN" then
    self:UpdateItemUses()
  elseif eventName == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" and self.spellID and C_Spell.GetBaseSpell(data) == C_Spell.GetBaseSpell(self.spellID) then
    self:SetActivationAlert(true)
  elseif eventName == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" and self.spellID and C_Spell.GetBaseSpell(data) == C_Spell.GetBaseSpell(self.spellID) then
    self:SetActivationAlert(false)
  elseif eventName == "ITEM_COUNT_CHANGED" and data == self.itemID then
    self:UpdateItemByID(self.itemID)
  end
end

function addonTable.Display.CooldownMixin:SetActivationAlert(state)
  if state and self.details.showIcon then
    self.SpellActivationAlert:Show()
	  self.SpellActivationAlert.ProcStartFlipbook:Show();
	  self.SpellActivationAlert.ProcLoopFlipbook:Show();
	  self.SpellActivationAlert.ProcAltGlow:Hide();
	  self.SpellActivationAlert.ProcStartAnim:Play();
	  self.SpellActivationAlert:SetFrameLevel(self:GetFrameLevel() + 2)
	else
	  self.SpellActivationAlert:Hide()
	  self.SpellActivationAlert.ProcStartAnim:Stop();
	end
end

function addonTable.Display.CooldownMixin:SetEnabled(state)
  if state then
    self:Enable()
  else
    self:Disable()
  end
end

function addonTable.Display.CooldownMixin:Enable()
  self.itemID = nil
  self.spellID = nil
  self.equipmentSlot = nil

  self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
  self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

  addonTable.CallbackRegistry:RegisterCallback("Update.SpellIcons", function(_, spellID)
    if self.spellID and (not spellID or C_Spell.GetBaseSpell(self.spellID) == spellID) then
      self.Icon:SetTexture(C_Spell.GetSpellTexture(self.spellID))
    end
  end, self)
  addonTable.CallbackRegistry:RegisterCallback("Update.KeyBindings", function(_, spellID)
    self:UpdateBindingText()
  end, self)
  addonTable.CallbackRegistry:RegisterCallback("Update.SpellsDisplay", function()
    if not self.spellID then
      return
    end
    local override = C_Spell.GetOverrideSpell(self.details.resource.spellID)
    if override ~= self.spellID then
      addonTable.Display.AbilityTracking:UnregisterCallback(self.spellID, self.spellCallback)
      self:UpdateSpellByID(override)
    end
  end, self)
end

function addonTable.Display.CooldownMixin:Disable()
  self.itemID = nil
  self.spellID = nil

  self:UnregisterAllEvents()
  addonTable.CallbackRegistry:UnregisterCallback("Update.SpellIcons", self)
  addonTable.CallbackRegistry:UnregisterCallback("Update.KeyBindings", self)
  addonTable.CallbackRegistry:UnregisterCallback("Update.SpellsDisplay", self)
end

function addonTable.Display.CooldownMixin:Setup(details)
  self:SetCollapsesLayout(addonTable.Config.Get(addonTable.Config.Options.COMPRESS_LAYOUT))
  self.details = details
  self.spellID = nil
  self.itemID = nil
  self.equipmentSlot = nil

  self.wasReady = nil
  if addonTable.Constants.GlowsMap[details.whenReady] then
    self.Glow:SetAsset(addonTable.Constants.GlowsMap[details.whenReady], details.glowColor, details.glowReverse)
  end

  self.BaseCooldown:SetScript("OnCooldownDone", nil)
  if details.resource.spellID then
    self.ignoreGCD = details.resource.spellID ~= addonTable.Constants.GCD and not addonTable.Config.Get(addonTable.Config.Options.SHOW_GCD_SWIPE)
    self:UpdateSpellByID(addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID, details.resource.rank) or details.resource.spellID)
  elseif details.resource.itemID then
    self:UpdateItemByID(details.resource.itemID)
  else
    self:UpdateItemByEquipmentSlot(details.resource.equipmentSlot)
  end

  self.BaseCooldown:SetDrawSwipe(details.showSwipe)
  self.ChargesCooldown:SetDrawEdge(details.showSwipe)
  self.BaseCooldown:SetCountdownFormatter(addonTable.Display.GetDurationFormatter(details.texts.cooldown.showFractions))
  self.BaseCooldown:SetCountdownFormatter(addonTable.Display.GetDurationFormatter(details.texts.cooldown.showFractions))

  self:UpdateBindingText()
  self:Style()

  self:SetMouseMotionEnabled(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))
  self.TextsContainer:SetFrameLevel(self:GetFrameLevel() + 4)
  self.Glow:SetFrameLevel(self:GetFrameLevel() + 3)
end

function addonTable.Display.CooldownMixin:UpdateBindingText()
  if not addonTable.Config.Get(addonTable.Config.Options.SHOW_KEYBINDINGS) then
    self.TextsContainer.keybinding:SetText("")
    return
  end
  local binding
  if self.spellID then
    binding = addonTable.State.Bindings.spells[C_Spell.GetBaseSpell(self.spellID)]
  elseif self.itemID then
    binding = addonTable.State.Bindings.items[self.itemID]
  elseif self.equipmentSlot then
    local location = ItemLocation:CreateFromEquipmentSlot(self.equipmentSlot)
    if C_Item.DoesItemExist(location) then
      binding = addonTable.State.Bindings.items[C_Item.GetItemID(location)]
    end
  end
  self.TextsContainer.keybinding:SetText(binding and binding.binding or "")
end

function addonTable.Display.CooldownMixin:ApplyVisual(visual)
  self:Show()
  self.Glow:Hide()
  self.Icon:SetDesaturated(false)
  if visual == "desaturate" then
    self.Icon:SetDesaturated(true)
  elseif visual == "hide" then
    self:Hide()
  elseif visual ~= "none" then
    self.Glow:Show()
  end
end

function addonTable.Display.CooldownMixin:UpdateForState(state, notUsable)
  local newState = tostring(state) .. " " .. tostring(notUsable)
  if newState ~= self.wasReady then
    local details = self.details
    self:ApplyVisual(state and details.whenCooldown or notUsable and details.whenResources or details.whenReady)
  end
  self.wasReady = newState
end

function addonTable.Display.CooldownMixin:UpdateSpellCooldowns()
  local state = addonTable.Display.AbilityTracking:Get(self.spellID)

  if state.charge then
    self.ChargesCooldown:SetCooldownFromDurationObject(state.charge.duration)
    self.ChargesCooldown:SetHideCountdownNumbers(not self.details.texts.cooldown.visible or not state.charge.focus)
  else
    self.ChargesCooldown:Clear()
  end

  self:UpdateForState(state.cooldown and state.cooldown.focus or false, not state.usable)
  if state.cooldown then
    self.BaseCooldown:SetCooldownFromDurationObject(state.cooldown.duration)
    self.BaseCooldown:SetHideCountdownNumbers(not self.details.texts.cooldown.visible or not state.cooldown.focus)
  else
    self.BaseCooldown:Clear()
  end
end

function addonTable.Display.CooldownMixin:UpdateSpellByID(spellID, activationOff)
  self.spellID = spellID

  self:UpdateSpellCooldowns()

  self.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
  self:UpdateSpellCharges()

  if not activationOff then
    self:SetActivationAlert(C_SpellActivationOverlay.IsSpellOverlayed(spellID))
  end
  self:UpdateRange()
  self:UpdateUsable()

  addonTable.Display.AbilityTracking:RegisterCallback(self.spellID, self.spellCallback)
end

function addonTable.Display.CooldownMixin:UpdateRange()
  if self.details.showRange and not addonTable.Display.AbilityTracking:Get(self.spellID).inRange then
    self.Icon:SetVertexColor(0.8, 0, 0, 1)
  else
    self.Icon:SetVertexColor(1, 1, 1, 1)
  end
end

function addonTable.Display.CooldownMixin:UpdateUsable()
  local state = addonTable.Display.AbilityTracking:Get(self.spellID)
  self.NotUsable:SetShown(not state.usable and self.details.showIcon)
  self:UpdateForState(state.cooldown and state.cooldown.focus or false, not state.usable)
end

function addonTable.Display.CooldownMixin:UpdateSpellCharges()
  local state = addonTable.Display.AbilityTracking:Get(self.spellID)
  self.TextsContainer.count:SetText(state.chargesValue)
end

function addonTable.Display.CooldownMixin:UpdateItemCooldowns()
  local start, duration = C_Item.GetItemCooldown(self.itemID)
  self:UpdateForState(start ~= 0)
  if start ~= 0 then
    local durationObject = C_DurationUtil.CreateDuration()
    durationObject:SetTimeFromStart(start, duration)
    self.BaseCooldown:SetCooldownFromDurationObject(durationObject)
  else
    self.BaseCooldown:Clear()
  end
end

function addonTable.Display.CooldownMixin:UpdateItemByID(itemID)
  self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
  self:RegisterEvent("ITEM_COUNT_CHANGED")
  self:RegisterEvent("BAG_UPDATE_COOLDOWN")

  self.itemID = itemID
  self.Icon:SetTexture(C_Item.GetItemIconByID(self.itemID))
  self.ChargesCooldown:Clear()

  self:UpdateItemCooldowns()
  self:UpdateItemUses()

  self.NotUsable:Hide()

  self.BaseCooldown:SetScript("OnCooldownDone", function()
    self:UpdateItemCooldowns()
  end)
end

function addonTable.Display.CooldownMixin:UpdateItemUses()
  local count = C_Item.GetItemCount(self.itemID, false, true)
  self.TextsContainer.count:SetText(count)

  if C_Item.GetItemCount(self.itemID) == 0 then
    C_Timer.After(0, function()
      addonTable.CallbackRegistry:TriggerEvent("Layout")
    end)
  end
end

function addonTable.Display.CooldownMixin:UpdateEquipmentCooldowns()
  local start, duration = GetInventoryItemCooldown("player", self.equipmentSlot)
  self:UpdateForState(start ~= 0)
  if start ~= 0 then
    local durationObject = C_DurationUtil.CreateDuration()
    durationObject:SetTimeFromStart(start, duration)
    self.BaseCooldown:SetCooldownFromDurationObject(durationObject)
  else
    self.BaseCooldown:Clear()
  end
end

function addonTable.Display.CooldownMixin:UpdateItemByEquipmentSlot(equipmentSlot)
  self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
  self:RegisterEvent("ITEM_COUNT_CHANGED")

  self.equipmentSlot = equipmentSlot

  local location = ItemLocation:CreateFromEquipmentSlot(equipmentSlot)
  if not C_Item.DoesItemExist(location) then
    C_Timer.After(0, function()
      addonTable.CallbackRegistry:TriggerEvent("Layout")
    end)
    return
  end
  self.ChargesCooldown:Clear()
  self:UpdateEquipmentCooldowns()
  self.TextsContainer.count:SetText(C_Item.GetItemCount(C_Item.GetItemID(location), false, true))
  self.Icon:SetTexture(C_Item.GetItemIcon(location))

  self.NotUsable:Hide()

  self.BaseCooldown:SetScript("OnCooldownDone", function()
    self:UpdateEquipmentCooldowns()
  end)
end

function addonTable.Display.CooldownMixin:HasAction()
  return self.binding ~= nil
end

function addonTable.Display.CooldownMixin:GetAllowRadialWheel()
  return false
end

function addonTable.Display.CooldownMixin:GetTargetInfo()
  if self.spellID then
    return {spellID = self.spellID}
  elseif self.itemID then
    return {itemID = self.itemID}
  elseif self.equipmentSlot then
    return {itemID = C_Item.GetItemID(ItemLocation:CreateFromEquipmentSlot(self.equipmentSlot))}
  else
    return {}
  end
end

function addonTable.Display.CooldownMixin:GetIsPingable()
  return true
end
