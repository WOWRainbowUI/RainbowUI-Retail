---@class addonTableCoolinator
local addonTable = select(2, ...)

local function GetColor(rgb, a)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b, a = a}
end

--- Generates default CDM layout for current spec
function addonTable.Core.GenerateDefaultCDMLayout()
  local spellEssential = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Essential, true)
  local spellUtility = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Utility, true)

  local auraTracked = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, true)
  local auraBars = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, true)

  spellEssential = tFilter(spellEssential, function(id) return C_CooldownViewer.GetCooldownViewerCooldownInfo(id).flags ~= Enum.CooldownSetSpellFlags.HideByDefault end, true)
  spellUtility = tFilter(spellUtility, function(id) return C_CooldownViewer.GetCooldownViewerCooldownInfo(id).flags ~= Enum.CooldownSetSpellFlags.HideByDefault end, true)

  auraTracked = tFilter(auraTracked, function(id)
    local flags = C_CooldownViewer.GetCooldownViewerCooldownInfo(id).flags
    return bit.band(Enum.CooldownSetSpellFlags.HideByDefault, flags) == 0
  end, true)
  auraBars = tFilter(auraBars, function(id)
    local flags = C_CooldownViewer.GetCooldownViewerCooldownInfo(id).flags
    return bit.band(Enum.CooldownSetSpellFlags.HideByDefault, flags) == 0
  end, true)

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
  for _, id in ipairs(spellUtility) do
    local spellID = addonTable.Core.GetSpellFromCDMInfo(C_CooldownViewer.GetCooldownViewerCooldownInfo(id))
    if not seen[spellID] then
      local entry = CopyTable(addonTable.Designer.Defaults.AbilityIcon)
      entry.preset = "UTILITY"
      entry.resource.spellID = spellID
      table.insert(result.entries[1].entries, entry)
    end
    seen[spellID] = true
  end

  for _, id in ipairs(spellEssential) do
    local spellID = addonTable.Core.GetSpellFromCDMInfo(C_CooldownViewer.GetCooldownViewerCooldownInfo(id))
    if not seen[spellID] then
      local entry = CopyTable(addonTable.Designer.Defaults.AbilityIcon)
      entry.preset = "ESSENTIAL"
      entry.resource.spellID = spellID
      table.insert(result.entries[2].entries, entry)
    end
    seen[spellID] = true
  end

  for _, id in ipairs(auraTracked) do
    local entry = CopyTable(addonTable.Designer.Defaults.AuraIcon)
    entry.preset = "AURA"
    entry.resource.spellID = addonTable.Core.GetSpellFromCDMInfo(C_CooldownViewer.GetCooldownViewerCooldownInfo(id))
    table.insert(result.entries[3].entries, entry)
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
  for _, id in ipairs(auraBars) do
    local entry = CopyTable(addonTable.Designer.Defaults.AuraBar)
    entry.preset = "DEFAULT"
    entry.resource.spellID = addonTable.Core.GetSpellFromCDMInfo(C_CooldownViewer.GetCooldownViewerCooldownInfo(id))
    table.insert(barGroups.entries, entry)
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
    version = addonTable.Constants.CurrentLayoutVersion,
    layout = "standalone",
    entries = {
      result
    },
  }
  addonTable.Core.GeneratePresetsFromDesign(final, false)
  addonTable.Core.RemoveDeadGroups(final)
  return final
end
