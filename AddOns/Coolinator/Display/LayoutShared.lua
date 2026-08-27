---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.LayoutManagerSharedMixin = CreateFromMixins(addonTable.Display.BaseLayoutManagerMixin)
function addonTable.Display.LayoutManagerSharedMixin:OnLoad()
  addonTable.Display.BaseLayoutManagerMixin.OnLoad(self)
  self:SetScript("OnEvent", self.OnEvent)
  self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
  self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
  self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")

  self.disabled = {}

  addonTable.CallbackRegistry:RegisterCallback("Designer.Open", function()
    self.disabled.designer = true
    self:Delayout()
  end)
  addonTable.CallbackRegistry:RegisterCallback("Designer.Close", function()
    self.disabled.designer = nil
    addonTable.CallbackRegistry:TriggerEvent("Layout")
  end)

  self.pools = {
    group = addonTable.Display.GeneratePool(addonTable.Display.GroupMixin),
    stack = addonTable.Display.GeneratePool(addonTable.Display.StackMixin),
    spacer = addonTable.Display.GeneratePool(addonTable.Display.SpacerMixin),
    cooldown = addonTable.Display.GeneratePool(addonTable.Display.CooldownMixin),
    abilityBar = addonTable.Display.GeneratePool(addonTable.Display.AbilityStatusBarMixin),
    abilityChargesPip = addonTable.Display.GeneratePool(addonTable.Display.AbilityChargesPipMixin),
    auraStatusBar = addonTable.Display.GeneratePool(addonTable.Display.AuraStatusBarMixin),
    totemStatusBar = addonTable.Display.GeneratePool(addonTable.Display.TotemStatusBarMixin),
    totemIcon = addonTable.Display.GeneratePool(addonTable.Display.TotemIconMixin),
    castBar = addonTable.Display.GeneratePool(addonTable.Display.CastBarMixin),
  }
end

function addonTable.Display.LayoutManagerSharedMixin:Delayout()
  local oldPending = self.pending
  self.pending = true

  for _, p in pairs(self.pools) do
    p:ReleaseAll()
  end

  self.toArrange = {}

  self.pending = oldPending
end

function addonTable.Display.LayoutManagerSharedMixin:Layout()
  if next(self.disabled) then
    return
  end
  self.pending = true

  self.autoSize = addonTable.Config.Get(addonTable.Config.Options.COMPRESS_LAYOUT)

  self.currentLayout = addonTable.Core.GetCurrentDesign()

  self:Delayout()

  local wrapper = self:GetGroup(self.currentLayout)

  wrapper:SetParent(UIParent)
  wrapper:Show()

  self:ArrangeGroup(wrapper, wrapper.details)

  self.root = wrapper

  if self.root.children[1] then
    CoolinatorPrimaryGroupAnchor:SetAllPoints(self.root.children[1])
  end

  self.pending = false
end

function addonTable.Display.LayoutManagerSharedMixin:GetIcon(details)
  if details.resource.kind == "ability" then
    if not addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID) then
      return
    end
    local frame = self.pools.cooldown:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame

  elseif details.resource.kind == "item" then
    if C_Item.GetItemCount(details.resource.itemID) < 1 then
      return
    end
    local frame = self.pools.cooldown:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame
  elseif details.resource.kind == "equipment" then
    local location = ItemLocation:CreateFromEquipmentSlot(details.resource.equipmentSlot)
    if not C_Item.DoesItemExist(location) then
      return
    end
    local frame = self.pools.cooldown:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame
  end
end

function addonTable.Display.LayoutManagerSharedMixin:GetBar(details)
  if details.resource.kind == "ability" then
    if not addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID) then
      return
    end
    local frame = self.pools.abilityBar:Acquire()
    frame:Show()
    frame:Enable()
    frame:Setup(details)
    return frame

  elseif details.resource.kind == "abilityCharge" then
    if not addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID) then
      return
    end
    local frame = self.pools.abilityChargesPip:Acquire()
    frame:Show()
    frame:Setup(details)
    return frame

  elseif details.resource.kind == "class" then
    if not self.pools["class-" .. details.resource.resource] then
      addonTable.Utilities.Message("Unknown class resource")
      return
    end
    local bar = self.pools["class-" .. details.resource.resource]:Acquire()
    bar:Show()
    bar:Setup(details)
    return bar

  elseif details.resource.kind == "cast" then
    local bar = self.pools.castBar:Acquire()
    bar:Show()
    bar:Enable()
    bar:Setup(details)
    return bar
  end
end

function addonTable.Display.LayoutManagerSharedMixin:OnEvent(eventName, data)
  if eventName == "UPDATE_BONUS_ACTIONBAR" or eventName == "UPDATE_VEHICLE_ACTIONBAR" or eventName == "UPDATE_OVERRIDE_ACTIONBAR" then
    if (C_ActionBar.HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "") or
      (C_ActionBar.HasOverrideActionBar() and C_ActionBar.GetOverrideBarSkin() and C_ActionBar.GetOverrideBarSkin() ~= 0) then
      self.disabled.vehicle = true
      self:Delayout()
    elseif self.disabled.vehicle then
      self.disabled.vehicle = nil
      self:Layout()
    end
  end
end
