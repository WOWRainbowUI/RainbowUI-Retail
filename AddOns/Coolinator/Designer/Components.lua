---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

addonTable.Designer.IconMixin = {}

function addonTable.Designer.IconMixin:OnLoad()
  self:SetSize(addonTable.Constants.nativeSize - 4, addonTable.Constants.nativeSize - 4)
  self:SetFlattensRenderLayers(true)

  self.Icon = self:CreateTexture(nil, "ARTWORK")
  self.Icon:SetSize(addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
  self.Icon:SetPoint("CENTER")

  self.BaseCooldown = CreateFrame("Cooldown", nil, self, "CooldownFrameTemplate")
  self.BaseCooldown:SetAllPoints()
  self.BaseCooldown:SetDrawEdge(false)
	self.BaseCooldown:SetSwipeColor(0, 0, 0, 0.8);
  self.BaseCooldown:SetSwipeTexture("Interface/HUD/UI-HUD-CoolDownManager-Icon-Swipe")

  self.CountFrame = CreateFrame("Frame", nil, self)
  self.CountFrame:SetAllPoints()
  self.CountFrame.text = self.CountFrame:CreateFontString(nil, nil, "NumberFontNormal")
  self.CountFrame.text:SetPoint("BOTTOMRIGHT", -2, -2)

  self.KeyBindingFrame = CreateFrame("Frame", nil, self)
  self.KeyBindingFrame:SetAllPoints(self.Icon)
  self.KeyBindingFrame.text = self.KeyBindingFrame:CreateFontString(nil, nil, "NumberFontNormal")
  self.KeyBindingFrame.text:SetPoint("TOPRIGHT", -2, -2)
  self.KeyBindingFrame.text:SetTextColor(0.7, 0.7, 0.7)
  self.KeyBindingFrame.text:SetWidth(addonTable.Constants.nativeSize - 6)
  self.KeyBindingFrame.text:SetWordWrap(false)

  self.DebuffBorder = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.AuraDebuffBorderMixin)
  self.DebuffBorder:SetAllPoints(self.Icon)

  self:SetScript("OnEnter", self.OnEnter)
  self:SetScript("OnLeave", self.OnLeave)

  addonTable.CallbackRegistry:RegisterCallback("Update.KeyBindings", function(_, spellID)
    self:UpdateBindingText()
  end, self)
end

function addonTable.Designer.IconMixin:UpdateBindingText()
  if not addonTable.Config.Get(addonTable.Config.Options.SHOW_KEYBINDINGS) then
    self.KeyBindingFrame.text:SetText("")
    return
  end
  local binding
  if self.details.resource.spellID and self.details.resource.kind == "ability" then
    binding = addonTable.State.Bindings.spells[C_Spell.GetBaseSpell(self.details.resource.spellID)]
  elseif self.details.resource.itemID then
    binding = addonTable.State.Bindings.items[self.details.resource.itemID]
  elseif self.details.resource.equipmentSlot then
    local location = ItemLocation:CreateFromEquipmentSlot(self.details.resource.equipmentSlot)
    if C_Item.DoesItemExist(location) then
      binding = addonTable.State.Bindings.items[C_Item.GetItemID(location)]
    end
  end
  self.KeyBindingFrame.text:SetText(binding and binding.binding or "")
end

function addonTable.Designer.IconMixin:Setup(details)
  self.details = details
  local texture
  self.DebuffBorder:Hide()
  if details.resource.spellID then
    texture = C_Spell.GetSpellTexture(details.resource.spellID)
    if details.resource.kind == "aura" then
      self.Icon:SetDesaturated(not addonTable.Utilities.IsAuraSpellKnown(details.resource.spellID) or false)
      self.DebuffBorder:Show()
      self.DebuffBorder:Setup(details)
      self.DebuffBorder:SetFrameLevel(self:GetFrameLevel() + 4)
    elseif details.resource.kind == "ability" then
      self.Icon:SetDesaturated(not addonTable.Utilities.IsAbilitySpellKnown(details.resource.spellID) or false)
    end
  elseif details.resource.itemID then
    texture = C_Item.GetItemIconByID(details.resource.itemID)
    self.Icon:SetDesaturated(C_Item.GetItemCount(details.resource.itemID) == 0)
  elseif details.resource.equipmentSlot then
    local location = ItemLocation:CreateFromEquipmentSlot(details.resource.equipmentSlot)
    texture = location:IsValid() and C_Item.GetItemIcon(location) or C_Item.GetItemIconByID(0)
    self.Icon:SetDesaturated(not C_Item.DoesItemExist(location))
  end
  self.Icon:SetTexture(texture)
  self.CountFrame.text:SetText("2")
  self:UpdateBindingText()

  addonTable.Display.StyleIcon({id = self.details.style}, self, self.Icon, self.CountFrame.text, self.KeyBindingFrame.text, {self.Icon}, {{swipe = true, text = true, widget = self.BaseCooldown}})
end

function addonTable.Designer.IconMixin:OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, self)
  if self.details.resource.spellID then
    GameTooltip:SetSpellByID(self.details.resource.spellID)
  elseif self.details.resource.itemID then
    GameTooltip:SetItemByID(self.details.resource.itemID)
  elseif self.details.resource.equipmentSlot then
    GameTooltip:SetInventoryItem("player", self.details.resource.equipmentSlot)
  end
  if self.Icon:IsDesaturated() then
    GameTooltip:AddLine(RED_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.UNLEARNED))
    GameTooltip:Show()
  end
end

function addonTable.Designer.IconMixin:OnLeave()
  GameTooltip:Hide()
end

addonTable.Designer.BarMixin = {}

function addonTable.Designer.BarMixin:OnLoad()
  self.statusBar = CreateFrame("StatusBar", nil, self)
  self.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", "Cooli: Solid Transparency"))
  self.statusBar:SetMinMaxValues(0, 5)
  self.statusBar:SetValue(3)
  self.statusBar:SetAllPoints()

  self.background = self.statusBar:CreateTexture(nil, "BACKGROUND")
  self.background:SetAllPoints()
  self.borderWrapper = CreateFrame("Frame", nil, self)
  self.borderWrapper:SetPoint("CENTER", self.statusBar)
  self.borderWrapper:SetSize(10, 10)
  self.border = self.borderWrapper:CreateTexture(nil, "BORDER")
  self.border:SetPoint("CENTER")
  self.borderMask = self.statusBar:CreateMaskTexture()
  self.borderMask:SetAllPoints()
end

function addonTable.Designer.BarMixin:Setup(details)
  self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
  self.details = details

  if details.thresholdColors then
    local color = details.thresholdColors[2].color
    self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  end

  self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)
end

function addonTable.Designer.BarMixin:GetDefaultSize()
  return self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
end

function addonTable.Designer.BarMixin:ApplySize(width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  PixelUtil.SetSize(self, sizing.rawWidth, sizing.rawHeight)
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
end

function addonTable.Designer.BarMixin:OnEnter()
  GameTooltip_SetDefaultAnchor(GameTooltip, self)
  if self.details.resource.spellID then
    GameTooltip:SetSpellByID(self.details.resource.spellID)
  elseif self.details.resource.itemID then
    if self.details.resource.itemID > 0 then
      GameTooltip:SetItemByID(self.details.resource.itemID)
    else
      GameTooltip:SetItemByID(-self.details.resource.itemID)
    end
  end
end

function addonTable.Designer.BarMixin:OnLeave()
  GameTooltip:Hide()
end

addonTable.Designer.BarWithIconMixin = CreateFromMixins(addonTable.Designer.BarMixin)

function addonTable.Designer.BarWithIconMixin:OnLoad()
  addonTable.Designer.BarMixin.OnLoad(self)

  self.icon = CreateFrame("Frame", nil, self)
  self.icon.Icon = self.icon:CreateTexture()
  self.icon.Icon:SetAllPoints()
  self.icon.Mask = self.icon:CreateMaskTexture()
  self.icon.Mask:SetAtlas("UI-HUD-CoolDownManager-Mask")
  self.icon.Mask:SetAllPoints()
  self.icon.Icon:AddMaskTexture(self.icon.Mask)

  self.statusBar:ClearAllPoints()
end

function addonTable.Designer.BarWithIconMixin:Setup(details)
  addonTable.Designer.BarMixin.Setup(self, details)

  self.icon.Icon:SetShown(self.details.icon.show)
  if details.resource and self.details.icon.show then
    if details.resource.spellID then
      self.icon.Icon:SetTexture(C_Spell.GetSpellTexture(details.resource.spellID))
    elseif details.resource.kind == "cast" then
      self.icon.Icon:SetTexture(addonTable.Constants.IsRetail and 236205 or 135753)
    end
  end

  if details.resource and details.resource.kind == "cast" then
    local color = details.colors.casting
    self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  end
end

function addonTable.Designer.BarWithIconMixin:ApplySize(width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  PixelUtil.SetSize(self, sizing.rawWidth, sizing.rawHeight)
  PixelUtil.SetSize(self.statusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
  if sizing.iconSize > 0 then
    self.icon:Show()
    PixelUtil.SetSize(self.icon, sizing.iconSize, sizing.iconSize)
  else
    self.icon:Hide()
  end

  self.icon:ClearAllPoints()
  self.statusBar:ClearAllPoints()
  if self.details.layout == "horizontal" then
    self.icon:SetPoint(self.details.icon.position == "left" and "LEFT" or "RIGHT")
    self.statusBar:SetPoint(self.details.icon.position == "left" and "RIGHT" or "LEFT")
  else
    self.icon:SetPoint(self.details.icon.position == "left" and "BOTTOM" or "TOP")
    self.statusBar:SetPoint(self.details.icon.position == "left" and "TOP" or "BOTTOM")
  end
end

addonTable.Designer.GroupMixin = CreateFromMixins(addonTable.Display.GroupMixin)

function addonTable.Designer.GroupMixin:Setup(details)
  addonTable.Display.GroupMixin.Setup(self, details)
  self.autoSize = false
end

function addonTable.Designer.GroupMixin:ApplyPadding(...)
end

function addonTable.Designer.GroupMixin:SetupVisibility()
end

function addonTable.Designer.GroupMixin:RegisterForLayout()
end

function addonTable.Designer.GroupMixin:UpdateVisibility()
end

function addonTable.Designer.GroupMixin:TriggerLayout()
end
