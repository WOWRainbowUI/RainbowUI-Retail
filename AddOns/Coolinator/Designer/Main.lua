---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Designer.GenerateEditable(callback)
  local specID = addonTable.Utilities.GetSpecID()
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
  if assignments[specID] and assignments[specID] ~= addonTable.Constants.DefaultName then
    return true
  else
    addonTable.Dialogs.ShowEditBox(addonTable.Locales.CHOOSE_A_NEW_DESIGN_NAME, OKAY, CANCEL, function(text)
      if text == addonTable.Constants.DefaultName then
        addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_DESIGN_NAME)
      else
        local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[specID]
        designs[text] = CopyTable(designs[addonTable.Constants.DefaultName])
        assignments[specID] = text
        addonTable.CallbackRegistry:TriggerEvent("Designer.Open")
        if callback then
          callback()
        end
      end
    end)
  end
end

function addonTable.Designer.GetCurrent()
  local specID = addonTable.Utilities.GetSpecID()
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
  assert(assignments[specID] and assignments[specID] ~= addonTable.Constants.DefaultName)
  local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
  return designs[specID][assignments[specID]]
end

function addonTable.Designer.GetActiveAuras(design)
  local result = {}
  if design.kind == "group" or design.kind == "stack" then
    for _, entry in ipairs(design.entries) do
      Mixin(result, addonTable.Designer.GetActiveAuras(entry))
    end
  elseif design.kind == "bar" and design.resource.kind == "aura" then
    result[design.resource.spellID] = true
  elseif design.kind == "icon" and design.resource.kind == "aura" then
    result[design.resource.spellID] = true
  end

  return result
end

function addonTable.Designer.GetActiveAbilities(design)
  local result = {}
  if design.kind == "group" or design.kind == "stack" then
    for _, entry in ipairs(design.entries) do
      Mixin(result, addonTable.Designer.GetActiveAbilities(entry))
    end
  elseif design.kind == "bar" and design.resource.kind == "ability" then
    result[C_Spell.GetBaseSpell(design.resource.spellID)] = true
  elseif design.kind == "icon" and design.resource.kind == "ability" then
    result[C_Spell.GetBaseSpell(design.resource.spellID)] = true
  end
  
  return result
end

function addonTable.Designer.GetActiveAbilityCharges(design)
  local result = {}
  if design.kind == "group" or design.kind == "stack" then
    for _, entry in ipairs(design.entries) do
      Mixin(result, addonTable.Designer.GetActiveAbilityCharges(entry))
    end
  elseif design.kind == "bar" and design.resource.kind == "abilityCharge" then
    result[C_Spell.GetBaseSpell(design.resource.spellID)] = true
  end
  
  return result
end

function addonTable.Designer.GetActiveItems(design)
  local result = {}
  if design.kind == "group" or design.kind == "stack" then
    for _, entry in ipairs(design.entries) do
      Mixin(result, addonTable.Designer.GetActiveItems(entry))
    end
  elseif design.kind == "bar" and design.resource.kind == "item" then
    result[design.resource.itemID] = true
  elseif design.kind == "icon" and design.resource.kind == "item" then
    result[design.resource.itemID] = true
  end

  return result
end

function addonTable.Designer.GetActiveEquipment(design)
  local result = {}
  if design.kind == "group" or design.kind == "stack" then
    for _, entry in ipairs(design.entries) do
      Mixin(result, addonTable.Designer.GetActiveEquipment(entry))
    end
  elseif design.kind == "bar" and design.resource.kind == "equipment" then
    result[design.resource.equipmentSlot] = true
  elseif design.kind == "icon" and design.resource.kind == "equipment" then
    result[design.resource.equipmentSlot] = true
  end

  return result
end

function addonTable.Designer.GetAvailableClassResources()
  return addonTable.Constants.ClassResources[addonTable.Utilities.GetSpecID()]
end

function addonTable.Designer.Initialize()
  addonTable.CallbackRegistry:RegisterCallback("Designer.Options", function(_, details)
    addonTable.Designer.GenerateOptionsFromDetails(details)
  end)
end

function addonTable.Designer.ConvertAnchorToCorner(targetCorner, frame, parent)
  local _ = frame:GetRect() -- Force evaluation of the position of the frame
  if targetCorner == "TOPLEFT" then
    return "TOPLEFT", frame:GetLeft(), frame:GetTop() - parent:GetTop()/frame:GetScale()
  elseif targetCorner == "TOPRIGHT" then
    return "TOPRIGHT", frame:GetRight() - parent:GetRight()/frame:GetScale(), frame:GetTop() - parent:GetTop()/frame:GetScale()
  elseif targetCorner == "BOTTOMLEFT" then
    return "BOTTOMLEFT", frame:GetLeft(), frame:GetBottom()
  elseif targetCorner == "BOTTOMRIGHT" then
    return "BOTTOMRIGHT", frame:GetRight() - parent:GetRight()/frame:GetScale(), frame:GetBottom()
  elseif targetCorner == "RIGHT" then
    return "RIGHT", frame:GetRight() - parent:GetRight()/frame:GetScale(), select(2, frame:GetCenter()) - select(2, parent:GetCenter())/frame:GetScale()
  elseif targetCorner == "LEFT" then
    return "LEFT", frame:GetLeft(), select(2, frame:GetCenter()) - select(2, parent:GetCenter())/frame:GetScale()
  elseif targetCorner == "TOP" then
    return "TOP", select(1, frame:GetCenter() - select(1, parent:GetCenter())/frame:GetScale()), (frame:GetTop() - parent:GetTop()/frame:GetScale())
  elseif targetCorner == "BOTTOM" then
    return "BOTTOM", select(1, frame:GetCenter()) - select(1, parent:GetCenter())/frame:GetScale(), frame:GetBottom()
  elseif targetCorner == "CENTER" then
    return "CENTER", select(1, frame:GetCenter()) - select(1, parent:GetCenter())/frame:GetScale(), select(2, frame:GetCenter()) - select(2, parent:GetCenter())/frame:GetScale()
  else
    error("Unknown anchor")
  end
end

function addonTable.Designer.GetLabel(details)
  local label = addonTable.Constants.KindToLabel[details.kind]
  if details.kind == "bar" and details.resource then
    label = label .. " - " .. addonTable.Constants.BarResourceLabelMap[details.resource.kind]
    if details.resource.kind == "class" then
      label = label .. " - " .. addonTable.Constants.BarClassResourceLabelMap[details.resource.resource]
    end
    if details.resource.kind == "aura" or details.resource.kind == "ability" then
      label = label .. ": " .. details.resource.spellID
    elseif details.resource.kind == "item" then
      label = label .. ": " .. details.resource.itemID
    end
  elseif details.kind == "icon" then
    label = label .. " - " .. addonTable.Constants.IconResourceLabelMap[details.resource.kind]
    if details.resource.kind == "aura" or details.resource.kind == "ability" then
      label = label .. ": " .. details.resource.spellID
    elseif details.resource.kind == "item" then
      label = label .. ": " .. details.resource.itemID
    end
  end

  return label
end
