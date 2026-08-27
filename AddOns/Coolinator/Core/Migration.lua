---@class addonTableCoolinator
local addonTable = select(2, ...)

local function GetColor(rgb, a)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b, a = a}
end

local function AddAlignment(group)
  if group.kind == "group" then
    if group.layout ~= "standalone" then
      group.alignment = "CENTER"
    end
    for _, entry in ipairs(group.entries) do
      AddAlignment(entry)
    end
  end
end

function addonTable.Core.RemoveDeadGroups(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      addonTable.Core.RemoveDeadGroups(entry)
      if #entry.entries == 0 then
        table.remove(group.entries, i)
      end
    end
  end
end

local function AddStylev3(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      AddStylev3(entry)
    elseif entry.kind == "icon" then
      entry.style = "blizzard"
    end
  end
end

local function UseBaseSpellsv4(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      UseBaseSpellsv4(entry)
    elseif entry.kind == "icon" and entry.resource.kind == "ability" then
      entry.resource.spellID = C_Spell.GetBaseSpell(entry.resource.spellID)
    elseif entry.kind == "icon" and entry.resource.kind == "aura" then
      entry.resource.spellID = C_Spell.GetBaseSpell(entry.resource.spellID)
    end
  end
end

local function Textsv6(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Textsv6(entry)
    elseif entry.kind == "icon" then
      entry.showTooltips = true
      entry.texts = {
        cooldown = {
          anchor = {},
          scale = Round(14/12 * 100) / 100,
          color = GetColor("FFFFFF"),
          visible = true,
          showFractions = false,
        },
        count = {
          anchor = {"BOTTOMLEFT", -2, -2},
          scale = Round(11/12 * 100) / 100,
          color = GetColor("FFFFFF"),
          visible = true,
        }
      }
    end
  end
end

local function Textsv7(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Textsv7(entry)
    elseif entry.kind == "icon" then
      entry.showTooltips = nil
      entry.texts.keybinding = {
        anchor = {"TOPRIGHT", 18, 18},
        scale = Round(13/12 * 100) / 100,
        color = GetColor("b3b3b3"),
        visible = true,
        widthLimit = 0.8,
      }
      entry.texts.count = {
        anchor = {"BOTTOMRIGHT", 18, -18},
        scale = 1,
        color = GetColor("ffffff"),
        visible = true,
        widthLimit = 0.8,
      }
      entry.texts.cooldown = {
        anchor = {},
        scale = Round(20/12 * 100) / 100,
        color = GetColor("FFFFFF"),
        visible = true,
        showFractions = false,
        widthLimit = 0.9,
      }
    end
  end
end

local function Iconsv9(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Iconsv9(entry)
    elseif entry.kind == "icon" then
      if entry.resource.kind == "ability" then
        entry.desaturateCooldown = false
      end
      entry.showSwipe = true
    end
  end
end

local function Iconsv10(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Iconsv10(entry)
    elseif entry.kind == "icon" then
      entry.showIcon = not entry.textsOnly
      entry.showSwipe = not entry.textsOnly
      entry.textsOnly = nil
    end
  end
end

local function Iconsv11(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Iconsv11(entry)
    elseif entry.kind == "bar" and entry.resource.kind == "class" then
      entry.icon = nil
    end
  end
end

local function FuryPainv12(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" and entry.entries then
      FuryPainv12(entry)
    elseif entry.kind == "bar" and entry.resource and entry.resource.kind == "class" and entry.resource.resource == "pain" then
      entry.resource.resource = "fury"
    end
  end
end

local function BarTextsv13(group)
  local barTexts = {
    name = {
      anchor = {"LEFT", 8, 0},
      scale = Round(10/12 * 100) / 100,
      color = GetColor("cfcfcf"),
      visible = true,
      widthLimit = 0.6,
      display = {"elapsed", "duration"}, -- elapsed/remaining and duration, with duration being optional
    },
    duration = {
      anchor = {"RIGHT", -8, 0},
      scale = Round(10/12 * 100) / 100,
      color = GetColor("cfcfcf"),
      visible = true,
      showFractions = false,
      widthLimit = 0.4,
    }
  }

  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      BarTextsv13(entry)
    elseif entry.kind == "bar" and (entry.resource.kind == "ability" or entry.resource.kind == "aura") and not entry.texts then
      entry.texts = CopyTable(barTexts)
    end
  end
end

local function Iconsv14(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Iconsv14(entry)
    elseif entry.kind == "icon" then
      if entry.resource.kind == "ability" then
        entry.hideCooldown = false
      end
    end
  end
end

local function Runesv15(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      Runesv15(entry)
    elseif entry.kind == "bar" and entry.resource.kind == "class" and entry.resource.resource == "runes" then
      entry.foreground.readyColor = CopyTable(entry.foreground.color)
    end
  end
end

local function ClassValuev16(group)
  local resources = {
    ["energy"] = true,
    ["mana"] = true,
    ["rage"] = true,
    ["runic-power"] = true,
    ["fury"] = true,
    ["focus"] = true,
    ["insanity"] = true,
    ["lunar-power"] = true,
    ["maelstrom"] = true,
  }
  local valueBarTexts = {
    value = {
      anchor = {"CENTER", 0, 0},
      scale = 1.1,
      color = GetColor("b3b3b3"),
      visible = false,
      widthLimit = 0.8,
    },
  }

  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      ClassValuev16(entry)
    elseif entry.kind == "bar" and entry.resource.kind == "class" and resources[entry.resource.resource] then
      entry.texts = CopyTable(valueBarTexts)
    end
  end
end

local function Swipev18(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Swipev18(entry)
    elseif entry.kind == "icon" then
      entry.swipeColor = GetColor("000000", 0.8)
      entry.reverse = false
    end
  end
end

local function Hidev19(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Hidev19(entry)
    elseif entry.kind == "icon" and (entry.resource.kind ~= "aura") then
      entry.hideReady = false
      entry.hideCooldown = entry.hideCooldown or false
      entry.desaturateCooldown = entry.desaturateCooldown or false
    end
  end
end

local function CastBarDurationv20(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      CastBarDurationv20(entry)
    elseif entry.kind == "bar" and entry.resource.kind == "cast" then
      entry.texts.duration.display = {"elapsed"}
      entry.texts.duration.showFractions = true
    elseif entry.kind == "bar" and (entry.resource.kind == "aura" or entry.resource.kind == "ability") then
      entry.texts.duration.display = {"remaining"}
      entry.texts.duration.showFractions = false
    end
  end
end

local function GroupVisibilityv21(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" then
      entry.visibility = {}
      GroupVisibilityv21(entry)
    end
  end
end

local function Iconsv22(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Iconsv22(entry)
    elseif entry.kind == "icon" then
      if entry.resource.kind == "ability" then
        if entry.hideCooldown then
          entry.whenCooldown = "hide"
        elseif entry.desaturateCooldown then
          entry.whenCooldown = "desaturate"
        else
          entry.whenCooldown = "none"
        end
        entry.hideCooldown = nil
        entry.desaturateCooldown = nil

        if entry.hideReady then
          entry.whenReady = "hide"
        else
          entry.whenReady = "none"
        end
        entry.hideReady = nil
        entry.glowColor = GetColor("ffe114")
        entry.glowReverse = false
      elseif entry.resource.kind == "aura" then
        entry.whenActive = "none"
        entry.whenInactive = "hide"
        entry.glowColor = GetColor("ffe114")
        entry.glowReverse = false
      end
    end
  end
end

local function Iconsv23(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Iconsv23(entry)
    elseif entry.kind == "icon" then
      if entry.resource.kind == "equipment" or entry.resource.kind == "item" then
        if entry.hideCooldown then
          entry.whenCooldown = "hide"
        elseif entry.desaturateCooldown then
          entry.whenCooldown = "desaturate"
        else
          entry.whenCooldown = "none"
        end
        entry.hideCooldown = nil
        entry.desaturateCooldown = nil

        if entry.hideReady then
          entry.whenReady = "hide"
        else
          entry.whenReady = "none"
        end
        entry.hideReady = nil
        entry.glowColor = GetColor("ffe114")
        entry.glowReverse = false
      elseif entry.resource.kind == "aura" then
        entry.whenActive = "none"
        entry.whenInactive = "hide"
        entry.glowColor = GetColor("ffe114")
        entry.glowReverse = false
      end
    end
  end
end

local function Iconsv24(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Iconsv24(entry)
    elseif entry.kind == "icon" then
      if entry.resource.kind == "ability" then
        entry.showRange = true
      end
    end
  end
end

local function Iconsv25(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Iconsv25(entry)
    elseif entry.kind == "icon" then
      if entry.resource.kind == "aura" then
        entry.showPandemic = true
        entry.pandemicColor = GetColor("ff3030")
      end
    end
  end
end

local function Combov26(group)
  for i = #group.entries, 1, -1 do
    local entry = group.entries[i]
    if entry.kind == "group" or entry.kind == "stack" then
      Combov26(entry)
    elseif entry.kind == "bar" then
      if entry.resource.kind == "class" and entry.resource.resource == "combo-points" then
        entry.foreground.chargedColor = GetColor("55aaff")
        entry.border.chargedColor = CopyTable(entry.border.readyColor)
      end
    end
  end
end

local steps = {
  AddAlignment,
  addonTable.Core.RemoveDeadGroups,
  AddStylev3,
  UseBaseSpellsv4,
  UseBaseSpellsv4,
  Textsv6,
  Textsv7,
  Textsv7,
  Iconsv9,
  Iconsv10,
  Iconsv11,
  FuryPainv12,
  BarTextsv13,
  Iconsv14,
  Runesv15,
  Runesv15,
  ClassValuev16,
  BarTextsv13,
  Swipev18,
  Hidev19,
  CastBarDurationv20,
  GroupVisibilityv21,
  Iconsv22,
  Iconsv22,
  Iconsv23,
  Iconsv24,
  Iconsv24,
  Iconsv25,
  Combov26,
  Combov26,
}
addonTable.Constants.CurrentLayoutVersion = #steps

function addonTable.Core.UpgradeDesign(design)
  if not design.version then
    design.version = 0
  end
  for index, callback in ipairs(steps) do
    if design.version < index then
      callback(design)
    end
  end
  design.version = #steps
end

function addonTable.Core.MigrateSettings()
  addonTable.Core.AutoGenerateLayout()

  for specID, specDetails in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
    for label, design in pairs(specDetails) do
      addonTable.Core.UpgradeDesign(design)
    end
  end

  local presets = addonTable.Config.Get(addonTable.Config.Options.PRESETS)
  if presets.migrated == nil or presets.migrated < 2 then
    addonTable.Config.Set(addonTable.Config.Options.PRESETS, {})
    for specID, specDetails in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
      for label, design in pairs(specDetails) do
        addonTable.Core.GeneratePresetsFromDesign(design)
      end
    end
    presets = addonTable.Config.Get(addonTable.Config.Options.PRESETS)
    presets.migrated = 2
  end
  local presetsGrouped = addonTable.Core.GetPresetsGrouped(presets)
  addonTable.Core.UpgradeDesign(presetsGrouped)
  presets.version = presetsGrouped.version
end
