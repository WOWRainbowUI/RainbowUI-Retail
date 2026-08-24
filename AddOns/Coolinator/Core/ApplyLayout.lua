---@class addonTableCoolinator
local addonTable = select(2, ...)

local function GetColor(rgb, a)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b, a = a}
end

local SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES = 2;
local SAVE_FIELD_ID_LAYOUTS = 3;
local SAVE_FIELD_ID_LAYOUT_ID_DATA = 4;

local SAVE_FIELD_ID_COOLDOWN_ORDER = 1;
local SAVE_FIELD_ID_CATEGORY_OVERRIDES = 2;

function addonTable.Core.GetCDMData(doNotTryAgain)
  local tag = CooldownViewerUtil.GetCurrentClassAndSpecTag()
  local raw = C_CooldownViewer.GetLayoutData()
  raw = raw:match("^%d%|(.*)$")
  if raw then
    local cdmData = C_EncodingUtil.DeserializeCBOR(C_EncodingUtil.DecompressString(C_EncodingUtil.DecodeBase64(raw), Enum.CompressionMethod.Deflate))
    if cdmData[1] < 4 then
      CooldownViewerSettings.dataSerialization:WriteData()
      if not doNotTryAgain then
        return addonTable.Core.GetCDMData(true)
      end
    end
    assert(cdmData[1] == 4 or cdmData[1] == 5, "Layout has changed, contact developer - " .. tostring(cdmData[1]))

    return cdmData, tag
  end

  return nil, tag
end

function addonTable.Core.GetCDMLayoutName()
  return "Coolinator (" .. CooldownViewerUtil.GetCurrentClassAndSpecTag() .. ")"
end

function addonTable.Core.GetCDMMappingAuras(activeOnly)
  local allAuras = {}

  tAppendAll(allAuras, C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, not activeOnly))
  tAppendAll(allAuras, C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, not activeOnly))
  local auraMapping = {}
  for _, cdmID in ipairs(allAuras) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(cdmID)
    auraMapping[info.spellID] = cdmID
    auraMapping[info.overrideSpellID] = cdmID
    auraMapping[C_Spell.GetBaseSpell(info.spellID)] = cdmID
    auraMapping[C_Spell.GetBaseSpell(info.overrideSpellID)] = cdmID
    if info.overrideTooltipSpellID then
      auraMapping[info.overrideTooltipSpellID] = cdmID
      auraMapping[C_Spell.GetBaseSpell(info.overrideTooltipSpellID)] = cdmID
    end
    for _, spellID in ipairs(info.linkedSpellIDs) do
      auraMapping[spellID] = cdmID
    end
  end

  for spellID in pairs(addonTable.Constants.Totems) do
    auraMapping[spellID] = nil
  end

  return auraMapping, allAuras
end

function addonTable.Core.GetCDMOrderAurasOnly(layout)
  local auraMappingActive = addonTable.Core.GetCDMMappingAuras(true)

  return {auraMap = auraMappingActive}
end

function addonTable.Core.GetExistingLayoutName()
  local cdmData , tag = addonTable.Core.GetCDMData()
  if not cdmData or not cdmData[SAVE_FIELD_ID_LAYOUT_ID_DATA] then
    return nil
  end

  for id, label in pairs(cdmData[SAVE_FIELD_ID_LAYOUT_ID_DATA]) do
    if cdmData[SAVE_FIELD_ID_LAYOUTS][tag] ~= nil and cdmData[SAVE_FIELD_ID_LAYOUTS][tag][id] ~= nil and cdmData[SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES][tag] == id and label ~= addonTable.Core.GetCDMLayoutName() then
      return label
    end
  end
end

function addonTable.Core.GenerateCoolinatorLayoutFromExisting(layoutName)
  local cdmData , tag = addonTable.Core.GetCDMData(true)
  if not cdmData then
    return
  end

  local layoutID
  local correctName = layoutName
  for i, name in pairs(cdmData[SAVE_FIELD_ID_LAYOUT_ID_DATA] or {}) do
    if name == correctName then
      layoutID = i
      break
    end
  end

  local overrides = cdmData[SAVE_FIELD_ID_LAYOUTS][tag][layoutID][SAVE_FIELD_ID_CATEGORY_OVERRIDES] or {}
  local barsSaved = overrides[Enum.CooldownViewerCategory.TrackedBar] or {}
  local aurasSaved = overrides[Enum.CooldownViewerCategory.TrackedBuff] or {}
  local essentialSaved = overrides[Enum.CooldownViewerCategory.Essential] or {}
  local utilitySaved = overrides[Enum.CooldownViewerCategory.Utility] or {}
  local hiddenAuras = overrides[Enum.CooldownViewerCategory.HiddenAura] or {}
  local hiddenAbilities = overrides[Enum.CooldownViewerCategory.HiddenSpell] or {}

  local essentialOrder = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Essential, true)
  local utilityOrder = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Utility, true)

  local auraOrder = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, true)
  local barOrder = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, true)

  local order = cdmData[SAVE_FIELD_ID_LAYOUTS][tag][layoutID][SAVE_FIELD_ID_COOLDOWN_ORDER]
  local orderMap = {}
  if order and #order > 0 then
    for index, cooldownID in ipairs(order) do
      orderMap[cooldownID] = index
    end
  else
    local complete = {}
    tAppendAll(complete, auraOrder)
    tAppendAll(complete, barOrder)
    tAppendAll(complete, essentialOrder)
    tAppendAll(complete, utilityOrder)

    for index, cooldownID in ipairs(complete) do
      orderMap[cooldownID] = index
    end
  end

  auraOrder = tFilter(auraOrder, function(cooldownID)
    return tIndexOf(hiddenAuras, cooldownID) == nil
  end, true)
  barOrder = tFilter(barOrder, function(cooldownID)
    return tIndexOf(hiddenAuras, cooldownID) == nil
  end, true)

  essentialOrder = tFilter(essentialOrder, function(cooldownID)
    return tIndexOf(hiddenAbilities, cooldownID) == nil
  end, true)
  utilityOrder = tFilter(utilityOrder, function(cooldownID)
    return tIndexOf(hiddenAbilities, cooldownID) == nil
  end, true)

  for index = #essentialOrder, 1, -1 do
    local cooldownID = essentialOrder[index]
    if tIndexOf(utilitySaved, cooldownID) ~= nil then
      table.remove(essentialOrder, index)
    elseif C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID).flags ~= Enum.CooldownSetSpellFlags.HideByDefault and tIndexOf(essentialSaved, cooldownID) == nil then
      table.insert(essentialSaved, cooldownID)
    end
  end

  for index = #utilityOrder, 1, -1 do
    local cooldownID = utilityOrder[index]
    if tIndexOf(essentialSaved, cooldownID) ~= nil then
      table.remove(utilityOrder, index)
    elseif C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID).flags ~= Enum.CooldownSetSpellFlags.HideByDefault and tIndexOf(utilitySaved, cooldownID) == nil then
      table.insert(utilitySaved, cooldownID)
    end
  end

  for index = #auraOrder, 1, -1 do
    local cooldownID = auraOrder[index]
    local flags = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID).flags
    if tIndexOf(barsSaved, cooldownID) ~= nil then
      table.remove(auraOrder, index)
    elseif bit.band(flags, Enum.CooldownSetSpellFlags.HideByDefault) == 0 and bit.band(flags, Enum.CooldownSetSpellFlags.HideAura) == 0 and tIndexOf(barsSaved, cooldownID) == nil then
      table.insert(aurasSaved, cooldownID)
    end
  end

  for index = #barOrder, 1, -1 do
    local cooldownID = barOrder[index]
    local flags = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID).flags
    if tIndexOf(aurasSaved, cooldownID) ~= nil then
      table.remove(barOrder, index)
    elseif bit.band(flags, Enum.CooldownSetSpellFlags.HideByDefault) == 0 and bit.band(flags, Enum.CooldownSetSpellFlags.HideAura) == 0 and tIndexOf(barsSaved, cooldownID) == nil then
      table.insert(barsSaved, cooldownID)
    end
  end

  table.sort(essentialSaved, function(a, b) return (orderMap[a] or 100000) < (orderMap[b] or 100000) end)
  table.sort(utilitySaved, function(a, b) return (orderMap[a] or 100000) < (orderMap[b] or 100000) end)
  table.sort(aurasSaved, function(a, b) return (orderMap[a] or 100000) < (orderMap[b] or 100000) end)
  table.sort(barsSaved, function(a, b) return (orderMap[a] or 100000) < (orderMap[b] or 100000) end)

  local result = {
    kind = "group",
    layout = "vertical",
    anchor = {"BOTTOM", "UIParent", "BOTTOM", 0, 200},
    preset = "DEFAULT",
    padding = 0.2,
    alpha = 1,
    scale = 1,
    alignment = "CENTER",
    entries = {
      {
        kind = "group",
        layout = "horizontal",
        direction = "right",
        padding = 0.1,
        alpha = 1,
        scale = 0.8,
        preset = "UTILITY",
        alignment = "CENTER",
        entries = {},
      },
      {
        kind = "group",
        layout = "horizontal",
        direction = "right",
        padding = 0.1,
        alpha = 1,
        scale = 1.25,
        preset = "ESSENTIAL",
        alignment = "CENTER",
        entries = {},
      },
      {
        kind = "group",
        layout = "horizontal",
        direction = "right",
        padding = 0.1,
        alpha = 1,
        scale = 1,
        preset = "AURAS",
        alignment = "CENTER",
        entries = {},
      },
    }
  }

  local seen = {}
  for _, id in ipairs(utilitySaved) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info then
      local spellID = C_Spell.GetBaseSpell(addonTable.Core.GetSpellFromCDMInfo(info))
      if not seen[spellID] then
        local entry = CopyTable(addonTable.Designer.Defaults.AbilityIcon)
        entry.preset = "UTILITY"
        entry.resource.spellID = spellID
        table.insert(result.entries[1].entries, entry)
      end
      seen[spellID] = true
    end
  end

  for _, id in ipairs(essentialSaved) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info then
      local spellID = C_Spell.GetBaseSpell(addonTable.Core.GetSpellFromCDMInfo(info))
      if not seen[spellID] then
        local entry = CopyTable(addonTable.Designer.Defaults.AbilityIcon)
        entry.preset = "ESSENTIAL"
        entry.resource.spellID = spellID
        table.insert(result.entries[2].entries, entry)
      end
      seen[spellID] = true
    end
  end

  for _, id in ipairs(aurasSaved) do
    local entry = CopyTable(addonTable.Designer.Defaults.AuraIcon)
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info then
      entry.preset = "AURA"
      entry.resource.spellID = addonTable.Core.GetSpellFromCDMInfo(info)
      table.insert(result.entries[3].entries, entry)
    end
  end

  local barGroups = {
    kind = "group",
    layout = "vertical",
    padding = 0.2,
    alpha = 1,
    alignment = "CENTER",
    scale = 1,
    preset = "AURA_BARS",
    entries = {
    }
  }
  for _, id in ipairs(barsSaved) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info then
      local entry = CopyTable(addonTable.Designer.Defaults.AuraBar)
      entry.preset = "DEFAULT"
      entry.resource.spellID = addonTable.Core.GetSpellFromCDMInfo(info)
      table.insert(barGroups.entries, entry)
    end
  end

  table.insert(result.entries, barGroups)

  --[[table.insert(result.entries, {
    kind = "bar",
    resource = {kind = "class", resource = "icicles"},
    width = 2, --0, -- widest of the entries just above or just below in the layout
    height = 0.65,
    scale = 1.5,
    alpha = 1,
    layout = "horizontal",
    direction = "left",
    icon = {show = true, position = "right"},
    foreground = {
      asset = "Cooli: Fade Right",
      color = {r = 0, g = 0, b = 1},
    },
    background = {
      asset = "Cooli: Solid White",
      color = GetColor("6bcbff", 0.3),
    },
    border = {
      asset = "Platy: Round Thin",
      color = {r = 0, g = 0, b = 0},
    },
  })]]

  local final = {
    kind = "group",
    version = 2,
    layout = "standalone",
    entries = {
      result
    },
  }
  addonTable.Core.GeneratePresetsFromDesign(final, false)
  addonTable.Core.RemoveDeadGroups(final)
  return final
end
