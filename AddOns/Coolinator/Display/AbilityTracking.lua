---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.AbilityTrackingMixin = {}

function addonTable.Display.AbilityTrackingMixin:OnLoad()
  self.abilities = {}
  self.active = {}

  self.callbacks = {}

  self.ticker = C_Timer.NewTicker(0.05, function()
    self:PassiveUpdate()
  end)

  self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
  self:RegisterEvent("SPELL_RANGE_CHECK_UPDATE")
  self:RegisterEvent("SPELL_UPDATE_USABLE")
  self:RegisterEvent("SPELL_UPDATE_CHARGES")
  self:RegisterEvent("SPELL_UPDATE_USES")

  self:SetScript("OnEvent", self.OnEvent)
end

function addonTable.Display.AbilityTrackingMixin:GetCharges(spellID)
  local binding = addonTable.State.Bindings.spells[C_Spell.GetBaseSpell(spellID)]
  if binding then
    return C_ActionBar.GetActionDisplayCount(binding.action)
  else
    return C_Spell.GetSpellDisplayCount(spellID)
  end
end

function addonTable.Display.AbilityTrackingMixin:ApplyCooldownToState(spellID)
  local state = self.abilities[spellID]

  local chargesInfo = C_Spell.GetSpellCharges(spellID)
  local cooldownInfo = C_Spell.GetSpellCooldown(spellID)

  state.hasChargesValue = chargesInfo ~= nil

  if cooldownInfo.isActive then
    state.cooldown = {
      focus = not cooldownInfo.isOnGCD,
      duration = C_Spell.GetSpellCooldownDuration(spellID)
    }
  else
    state.cooldown = nil
  end

  if chargesInfo and chargesInfo.isActive then
    state.charge = {
      focus = not cooldownInfo.isActive or cooldownInfo.isOnGCD,
      duration = C_Spell.GetSpellChargeDuration(spellID)
    }
  else
    state.charge = nil
  end

  self.active[spellID] = state.cooldown or state.charge or false
end

function addonTable.Display.AbilityTrackingMixin:InitNew(spellID)
  local state = {}
  self.abilities[spellID] = state

  self:ApplyCooldownToState(spellID)

  state.usable = C_Spell.IsSpellUsable(spellID)
  state.chargesValue = self:GetCharges(spellID)

  C_Spell.EnableSpellRangeCheck(spellID, true)

  state.inRange = C_Spell.IsSpellInRange(spellID, "target") ~= false
end

function addonTable.Display.AbilityTrackingMixin:PassiveUpdate()
  for spellID in pairs(self.active) do
    local state = self.abilities[spellID]
    local updateNeeded = false

    if state.cooldown then
      local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
      if not cooldownInfo.isActive then
        updateNeeded = true
        state.cooldown = nil
      end
    end

    if state.charge then
      local chargesInfo = C_Spell.GetSpellCharges(spellID)
      if not chargesInfo or not chargesInfo.isActive then
        updateNeeded = true
        state.charge = nil
      else
        local oldFocus = state.charge.focus
        local newFocus = not state.cooldown or not state.cooldown.focus or false
        if oldFocus ~= newFocus then
          state.charge.focus = newFocus
          updateNeeded = true
        end
      end
    end

    if updateNeeded then
      for _, callback in pairs(self.callbacks[spellID]) do
        callback("cooldown")
      end

      if state.charge == nil and state.cooldown == nil then
        self.active[spellID] = nil
      end
    end
  end
end

function addonTable.Display.AbilityTrackingMixin:UpdateUsable()
  for spellID, state in pairs(self.abilities) do
    local oldUsable = state.usable
    local newUsable = C_Spell.IsSpellUsable(spellID)
    if oldUsable ~= newUsable then
      state.usable = newUsable
      for _, callback in pairs(self.callbacks[spellID]) do
        callback("usable")
      end
    end
  end
end

function addonTable.Display.AbilityTrackingMixin:UpdateCharges()
  for spellID, state in pairs(self.abilities) do
    if state.hasChargesValue then
      state.chargesValue = self:GetCharges(spellID)
      for _, callback in pairs(self.callbacks[spellID]) do
        callback("chargesValue")
      end
    end
  end
end

function addonTable.Display.AbilityTrackingMixin:Get(spellID)
  if not self.abilities[spellID] then
    self:InitNew(spellID)
  end

  return self.abilities[spellID]
end

function addonTable.Display.AbilityTrackingMixin:RegisterCallback(spellID, callback)
  self.callbacks[spellID] = self.callbacks[spellID] or {}
  table.insert(self.callbacks[spellID], callback)
end

function addonTable.Display.AbilityTrackingMixin:UnregisterCallback(spellID, callback)
  local index = tIndexOf(self.callbacks[spellID], callback)
  if index then
    table.remove(self.callbacks[spellID])
    if #self.callbacks[spellID] == 0 then
      self.callbacks[spellID] = nil
      self.abilities[spellID] = nil
      self.active[spellID] = nil
    end
  end
end

function addonTable.Display.AbilityTrackingMixin:Reset()
  self.abilities = {}
  for spellID in pairs(self.abilities) do
    C_Spell.EnableSpellRangeCheck(spellID, false)
  end
  self.active = {}
  self.callbacks = {}
end

function addonTable.Display.AbilityTrackingMixin:OnEvent(eventName, ...)
  if eventName == "SPELL_UPDATE_USABLE" then
    self:UpdateUsable()
  elseif eventName == "SPELL_UPDATE_CHARGES" then
    self:UpdateCharges()
  elseif eventName == "SPELL_UPDATE_USES" then
    self:UpdateCharges()
  elseif eventName == "SPELL_RANGE_CHECK_UPDATE" then
    local spellID, isInRange, checkedRange = ...
    if self.abilities[spellID] then
      local oldRange = self.abilities[spellID].inRange
      local newRange = isInRange or not checkedRange
      if oldRange ~= newRange then
        self.abilities[spellID].inRange = newRange
        for _, callback in pairs(self.callbacks[spellID]) do
          callback("range")
        end
      end
    end
  elseif eventName == "SPELL_UPDATE_COOLDOWN" then
    local _, _, cooldownCategory = ...
    if cooldownCategory == nil then
      return
    end
    for spellID in pairs(self.abilities) do
      self:ApplyCooldownToState(spellID)
      if self.active[spellID] then
        for _, callback in pairs(self.callbacks[spellID]) do
          callback("cooldown")
        end
      end
    end
  end
end
