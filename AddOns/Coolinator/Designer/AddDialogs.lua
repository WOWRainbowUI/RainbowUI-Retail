---@class addonTableCoolinator
local addonTable = select(2, ...)

local function Announce()
  addonTable.CallbackRegistry:TriggerEvent("Designer.Layout")
end

local Kind = {
  Spell = 1,
  Aura = 2,
  Item = 3,
  Equipment = 4,
}
local index = 1
local function GetSpellIconDialog(allGetter, activeGetter, kind)
  local frame = addonTable.CustomiseDialog.Components.GetContentFrame("CoolinatorDesignerInsertDialog" .. index, 300, 400)
  index = index + 1
  table.insert(UISpecialFrames, frame:GetName())
  local container = CreateFrame("Frame", nil, frame)
  container:SetPoint("TOPLEFT", addonTable.Constants.ButtonFrameOffset, -25)
  container:SetPoint("BOTTOMRIGHT")
  local seen = {}

  local offsetY = 0

  if kind == Kind.Item or kind == Kind.Spell or kind == Kind.Aura then
    offsetY = -30
    local editBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    editBox:SetNumeric(true)
    editBox:SetPoint("TOP", -40, -5)
    editBox:SetSize(80, 22)
    editBox:SetAutoFocus(false)

    local function Evaluate()
      local number = tonumber(editBox:GetText())
      if kind == Kind.Spell then
        number = number and C_Spell.GetBaseSpell(number)
      end
      return number
    end

    local icon = frame:CreateTexture()
    icon:SetSize(25, 25)
    icon:SetPoint("RIGHT", editBox, "LEFT", -5, 0)

    local addIDButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
    addIDButton:SetText(addonTable.Locales.ADD_ID)
    DynamicResizeButton_Resize(addIDButton)
    addIDButton:SetPoint("LEFT", editBox, "RIGHT", 5, 0)

    editBox:SetScript("OnShow", function()
      editBox:SetText("")
    end)
    editBox:SetScript("OnEnterPressed", function()
      if addIDButton:IsEnabled() then
        addIDButton:Click()
      end
    end)
    editBox:SetScript("OnTextChanged", function()
      local number = Evaluate()
      if kind == Kind.Spell or kind == Kind.Aura then
        icon:SetTexture(number and C_Spell.GetSpellTexture(number))
      elseif kind == Kind.Item then
        icon:SetTexture(number and C_Item.GetItemIconByID(number))
      end
      addIDButton:SetEnabled(number and not seen[number])
    end)
    addIDButton:SetScript("OnClick", function()
      local number = Evaluate()
      if number and not seen[number] then
        frame.callback(number)
      end
    end)
    local function ShowTooltip(self)
      local number = Evaluate()
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      if seen[number] then
        GameTooltip:SetText(RED_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.ALREADY_ADDED))
        GameTooltip:Show()
      elseif number then
        if kind == Kind.Spell then
          GameTooltip:SetSpellByID(C_Spell.GetOverrideSpell(number))
        elseif kind == Kind.Aura then
          GameTooltip:SetSpellByID(number)
        elseif kind == Kind.Item then
          GameTooltip:SetItemByID(number)
        end
      end
    end
    addIDButton:SetScript("OnEnter", ShowTooltip)
    icon:SetScript("OnEnter", ShowTooltip)
    addIDButton:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    icon:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  end
  
  frame.scrollBox = CreateFrame("Frame", nil, container, "WowScrollBoxList")
  frame.scrollBox:SetPoint("TOPLEFT", 0, offsetY)
  frame.scrollBox:SetPoint("BOTTOMRIGHT", -10, 0)
  frame.scrollBar = CreateFrame("EventFrame", nil, container, "MinimalScrollBar")
  frame.scrollBar:SetPoint("TOPRIGHT", -8, offsetY)
  frame.scrollBar:SetPoint("BOTTOMRIGHT", -8, 0)
  frame.view = CreateScrollBoxListGridView(6, 10, 10, 10, 10, 5, 5)
  frame.view:SetElementSizeCalculator(function()
    return 40, 40
  end)
  frame.view:SetElementInitializer("Button", function(button, data)
    if not button.setup then
      button.setup = true
      button.Icon = button:CreateTexture()
      button.Icon:SetAllPoints()
      button.Highlight = button:CreateTexture(nil, "HIGHLIGHT")
      button.Highlight:SetBlendMode("ADD")
      button.Highlight:SetTexture("Interface/Buttons/ButtonHilight-Square")
      button.Highlight:SetAllPoints()
    end
    button.Highlight:Hide()
    if kind == Kind.Spell then
      local override = C_Spell.GetOverrideSpell(data)
      button.Icon:SetDesaturated(not addonTable.Utilities.IsAbilitySpellKnown(override))
      button.Icon:SetTexture(C_Spell.GetSpellTexture(override))
    elseif kind == Kind.Aura then
      button.Icon:SetDesaturated(not addonTable.Utilities.IsAuraSpellKnown(data))
      button.Icon:SetTexture(C_Spell.GetSpellTexture(data))
    elseif kind == Kind.Item then
      button.Icon:SetDesaturated(C_Item.GetItemCount(data) == 0)
      button.Icon:SetTexture(C_Item.GetItemIconByID(data))
    elseif kind == Kind.Equipment then
      local location = ItemLocation:CreateFromEquipmentSlot(data)
      button.Icon:SetDesaturated(not C_Item.DoesItemExist(location))
      button.Icon:SetTexture(C_Item.DoesItemExist(location) and C_Item.GetItemIcon(location) or C_Item.GetItemIconByID(0))
    else
      assert(false)
    end
    button:SetScript("OnClick", function()
      frame.callback(data)
      frame:Hide()
    end)
    button:SetScript("OnEnter", function()
      button.Highlight:Show()
      GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
      if kind == Kind.Spell then
        GameTooltip:SetSpellByID(C_Spell.GetOverrideSpell(data))
      elseif kind == Kind.Aura then
        GameTooltip:SetSpellByID(data)
      elseif kind == Kind.Item then
        GameTooltip:SetItemByID(data)
      elseif kind == Kind.Equipment then
        if button.Icon:IsDesaturated() then
          GameTooltip:SetText(C_Item.GetItemInventorySlotInfo(data))
          GameTooltip:AddLine(addonTable.Locales.NOTHING_IN_SLOT)
          GameTooltip:Show()
        else
          GameTooltip:SetInventoryItem("player", data)
        end
      end
    end)
    button:SetScript("OnLeave", function()
      button.Highlight:Hide()
      GameTooltip:Hide()
    end)
  end)
  ScrollUtil.InitScrollBoxListWithScrollBar(frame.scrollBox, frame.scrollBar, frame.view)

  function frame:Update(callback)
    frame.callback = callback
    local all = allGetter()
    table.sort(all)
    seen = activeGetter()
    all = tFilter(all, function(data)
      return not seen[data]
    end, true)
    frame.view:SetDataProvider(CreateDataProvider(all))
    frame:Show()
  end

  return frame
end

function addonTable.Designer.GetAuraDialog()
  local dialog = GetSpellIconDialog(addonTable.Core.GetAllAuras, function()
    return addonTable.Designer.GetActiveAuras(addonTable.Designer.GetCurrent())
  end, Kind.Aura)
  dialog:SetTitle(addonTable.Locales.CHOOSE_AURA)

  return dialog
end

function addonTable.Designer.GetAbilityDialog()
  local dialog = GetSpellIconDialog(addonTable.Core.GetAllAbilities, function()
    return addonTable.Designer.GetActiveAbilities(addonTable.Designer.GetCurrent())
  end, Kind.Spell)
  dialog:SetTitle(addonTable.Locales.CHOOSE_ABILITY)

  return dialog
end

function addonTable.Designer.GetAbilityChargesDialog()
  local dialog = GetSpellIconDialog(function()
    return tFilter(addonTable.Core.GetAllClassAbilities(), function(a)
      local chargeInfo = C_Spell.GetSpellCharges(a)
      return chargeInfo ~= nil and chargeInfo.maxCharges > 1
    end, true)
  end, function()
    return addonTable.Designer.GetActiveAbilityCharges(addonTable.Designer.GetCurrent())
  end, Kind.Spell)
  dialog:SetTitle(addonTable.Locales.CHOOSE_ABILITY)

  return dialog
end

function addonTable.Designer.GetPotionEffectDialog()
  local all = GetKeysArray(addonTable.Constants.AurasFromItems)
  local dialog = GetSpellIconDialog(function()
    return all
  end, function()
    return addonTable.Designer.GetActiveAuras(addonTable.Designer.GetCurrent())
  end, Kind.Aura)
  dialog:SetTitle(addonTable.Locales.CHOOSE_POTION_EFFECT)

  return dialog
end

function addonTable.Designer.GetItemDialog()
  local all = addonTable.Core.GetAllItems()
  local dialog = GetSpellIconDialog(function()
    return all
  end, function()
    return addonTable.Designer.GetActiveItems(addonTable.Designer.GetCurrent())
  end, Kind.Item)
  dialog:SetTitle(addonTable.Locales.CHOOSE_ITEM)

  return dialog
end

function addonTable.Designer.GetEquipmentDialog()
  local all = addonTable.Core.GetAllEquipment()
  local dialog = GetSpellIconDialog(function()
    return all
  end, function()
    return addonTable.Designer.GetActiveEquipment(addonTable.Designer.GetCurrent())
  end, Kind.Equipment)
  dialog:SetTitle(addonTable.Locales.CHOOSE_EQUIPMENT)

  return dialog
end
