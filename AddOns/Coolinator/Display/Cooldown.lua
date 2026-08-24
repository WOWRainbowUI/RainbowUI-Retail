---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.CooldownMixin = {}
function addonTable.Display.CooldownMixin:OnLoad()
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
end

function addonTable.Display.CooldownMixin:Style()
  addonTable.Display.StyleIcon({id = self.details.style}, self, self.Icon, self.TextsContainer.count, self.TextsContainer.keybinding,
    {self.Icon, self.NotUsable},
    {{swipe = true, text = true, widget = self.BaseCooldown}, {text = true, widget = self.ChargesCooldown},}
  )
end

function addonTable.Display.CooldownMixin:GetDefaultSize()
  local dim = addonTable.Constants.nativeSize - 4
  return dim, dim
end

function addonTable.Display.CooldownMixin:ApplyPadding(horizontal, vertical)
  self.paddingH, self.paddingV = horizontal, vertical
  local width, height = PixelUtil.ConvertPixelsToUIForRegion(addonTable.Constants.nativeSize - 4 + horizontal, self), PixelUtil.ConvertPixelsToUIForRegion(addonTable.Constants.nativeSize - 4 + vertical, self)
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
    if self.spellID then
      self:UpdateSpellCooldowns()
    elseif self.itemID then
      self:UpdateItemCooldowns()
    elseif self.equipmentSlot then
      self:UpdateEquipmentCooldowns()
    end
  elseif eventName == "BAG_UPDATE_COOLDOWN" then
    if self.itemID then
      self:UpdateItemUses()
    end
  elseif eventName == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" and self.spellID and C_Spell.GetBaseSpell(data) == C_Spell.GetBaseSpell(self.spellID) then
    self:SetActivationAlert(true)
  elseif eventName == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" and self.spellID and C_Spell.GetBaseSpell(data) == C_Spell.GetBaseSpell(self.spellID) then
    self:SetActivationAlert(false)
  elseif eventName == "SPELL_RANGE_CHECK_UPDATE" and self.spellID and data == self.spellID then
    local spellID, isInRange, checkedRange = ...
    if spellID == self.spellID and self.details.showRange then
      if not checkedRange or isInRange then
        self.Icon:SetVertexColor(1, 1, 1, 1)
      else
        self.Icon:SetVertexColor(0.8, 0, 0, 1)
      end
    end
  elseif eventName == "SPELL_UPDATE_USABLE" and self.spellID then
    self:UpdateUsable()
  elseif eventName == "SPELL_UPDATE_CHARGES" and self.spellID then
    self:UpdateSpellCharges()
  elseif eventName == "SPELL_UPDATE_USES" and self.spellID == data then
    self:UpdateSpellCharges()
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

  self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
  self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
  self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
  self:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")
  self:RegisterEvent("SPELL_UPDATE_USABLE")
  self:RegisterEvent("SPELL_UPDATE_CHARGES")
  self:RegisterEvent("SPELL_UPDATE_USES")
  self:RegisterEvent("ITEM_COUNT_CHANGED")
  self:RegisterEvent("BAG_UPDATE_COOLDOWN")

  addonTable.CallbackRegistry:RegisterCallback("Update.SpellIcons", function(_, spellID)
    if self.spellID and (not spellID or C_Spell.GetBaseSpell(self.spellID) == spellID) then
      self.Icon:SetTexture(C_Spell.GetSpellTexture(self.spellID))
    end
  end, self)
  addonTable.CallbackRegistry:RegisterCallback("Update.KeyBindings", function(_, spellID)
    self:UpdateBindingText()
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

function addonTable.Display.CooldownMixin:Disable()
  if self.spellID then
    C_Spell.EnableSpellRangeCheck(self.spellID, false)
  end
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

  if details.resource.spellID then
    self.ignoreGCD = details.resource.spellID ~= addonTable.Constants.GCD and not addonTable.Config.Get(addonTable.Config.Options.SHOW_GCD_SWIPE)
    self:UpdateSpellByID(addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID) or details.resource.spellID)
  elseif details.resource.itemID then
    self:UpdateItemByID(details.resource.itemID)
  else
    self:UpdateItemByEquipmentSlot(details.resource.equipmentSlot)
  end

  self.BaseCooldown:SetScript("OnCooldownDone", nil)
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
  if state ~= self.wasReady then
    local details = self.details
    self:ApplyVisual(state and details.whenCooldown or notUsable and "none" or details.whenReady)
  end
  self.wasReady = state
end

function addonTable.Display.CooldownMixin:UpdateSpellCooldowns()
  local chargesInfo = C_Spell.GetSpellCharges(self.spellID)
  local cooldownInfo = C_Spell.GetSpellCooldown(self.spellID)

  if chargesInfo and chargesInfo.isActive  then
    local chargeDuration = C_Spell.GetSpellChargeDuration(self.spellID)
    self.ChargesCooldown:SetCooldownFromDurationObject(chargeDuration)
    self.ChargesCooldown:SetAlphaFromBoolean(C_Spell.GetSpellCharges(self.spellID))
    self.ChargesCooldown:SetHideCountdownNumbers(not self.details.texts.cooldown.visible or cooldownInfo.isActive and cooldownInfo.isOnGCD == false)
  else
    self.ChargesCooldown:Clear()
  end

  self.spellCooldownState = cooldownInfo.isActive and not cooldownInfo.isOnGCD
  self:UpdateForState(self.spellCooldownState, not C_Spell.IsSpellUsable(self.spellID))
  if cooldownInfo.isActive then
    local baseDuration = C_Spell.GetSpellCooldownDuration(self.spellID, self.ignoreGCD)
    self.BaseCooldown:SetCooldownFromDurationObject(baseDuration)
    self.BaseCooldown:SetHideCountdownNumbers(not self.details.texts.cooldown.visible or cooldownInfo.isOnGCD)
    self.BaseCooldown:SetScript("OnCooldownDone", function()
      self.spellCooldownState = false
      self:UpdateForState(false)
    end)
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
  if self.details.showRange then
    C_Spell.EnableSpellRangeCheck(self.spellID, true)
  end
  if self.details.showRange and C_Spell.IsSpellInRange(self.spellID, "target") == false then
    self.Icon:SetVertexColor(0.8, 0, 0, 1)
  else
    self.Icon:SetVertexColor(1, 1, 1, 1)
  end
  self:UpdateUsable()
end

function addonTable.Display.CooldownMixin:UpdateUsable()
  local usable = C_Spell.IsSpellUsable(self.spellID)
  self.NotUsable:SetShown(not usable and self.details.showIcon)
  self:UpdateForState(self.spellCooldownState, not usable)
end

function addonTable.Display.CooldownMixin:UpdateSpellCharges()
  local binding = addonTable.State.Bindings.spells[C_Spell.GetBaseSpell(self.spellID)]
  if binding then
    self.TextsContainer.count:SetText(C_ActionBar.GetActionDisplayCount(binding.action))
  else
    self.TextsContainer.count:SetText(C_Spell.GetSpellDisplayCount(self.spellID))
  end
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
  self.itemID = itemID
  self.Icon:SetTexture(C_Item.GetItemIconByID(self.itemID))
  self.ChargesCooldown:Clear()

  self:UpdateItemCooldowns()
  self:UpdateItemUses()

  self.NotUsable:Hide()
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
