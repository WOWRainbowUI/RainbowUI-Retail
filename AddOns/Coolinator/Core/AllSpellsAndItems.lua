---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Core.GetSpellFromCDMInfo(info)
  return info.overrideTooltipSpellID or info.overrideSpellID or info.spellID
end

function addonTable.Core.GetAllAuras()
  local result = {}

  if C_CooldownViewer then
    local auraTracked = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, true)
    local auraBars = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, true)

    for _, aura in ipairs(auraTracked) do
      table.insert(result, addonTable.Core.GetSpellFromCDMInfo(C_CooldownViewer.GetCooldownViewerCooldownInfo(aura)))
    end
    for _, aura in ipairs(auraBars) do
      table.insert(result, addonTable.Core.GetSpellFromCDMInfo(C_CooldownViewer.GetCooldownViewerCooldownInfo(aura)))
    end
  end

  return result
end

local pandaRacial = 107079
local undeadRacial = 7744
local racialSpell = addonTable.Constants.IsRetail and pandaRacial or undeadRacial
local racialText

if racialText == nil then
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("SPELL_TEXT_UPDATE")
  frame:RegisterEvent("SPELL_DATA_LOAD_RESULT")
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:SetScript("OnEvent", function(_, _, spellID)
    racialText = C_Spell.GetSpellSubtext(racialSpell)
    if spellID == racialSpell then
      racialText = C_Spell.GetSpellSubtext(racialSpell)
    else
      C_Spell.RequestLoadSpellData(racialSpell)
    end
    if racialText then
      frame:UnregisterEvent("SPELL_TEXT_UPDATE")
      frame:UnregisterEvent("SPELL_DATA_LOAD_RESULT")
    end
  end)
end

local function GetCDMAbilities(seen)
  local result = {}
  if not C_CooldownViewer then
    return result
  end

  local function AutoIncludeBase(spellID)
    local base = C_Spell.GetBaseSpell(spellID)
    if base and not seen[base] then
      seen[base] = true
    end
  end

  local function RecordSeen(info)
    seen[info.overrideSpellID] = true
    AutoIncludeBase(info.overrideSpellID)
    if info.overrideTooltipSpellID then
      seen[info.overrideTooltipSpellID] = true
      AutoIncludeBase(info.overrideTooltipSpellID)
    end
    seen[info.spellID] = true
    AutoIncludeBase(info.spellID)
  end

  local abilityTracked = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Essential, true)
  local abilityBars = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Utility, true)

  for _, ability in ipairs(abilityTracked) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(ability)
    local spellID = addonTable.Core.GetSpellFromCDMInfo(info)
    if not seen[spellID] then
      table.insert(result, spellID)
    end
    RecordSeen(info)
  end
  for _, ability in ipairs(abilityBars) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(ability)
    local spellID = addonTable.Core.GetSpellFromCDMInfo(info)
    if not seen[spellID] then
      table.insert(result, spellID)
    end
    RecordSeen(info)
  end

  return result
end

local function GetAllSpellBookAbilities(seen)
  local result = {}
  seen = seen or {}

  local function ProcessSpellID(spellID)
    local base = C_Spell.GetBaseSpell(spellID)
    if not seen[spellID] and not seen[base] then
      table.insert(result, base or spellID)
    end
    seen[spellID] = true
    if base then
      seen[base] = true
    end
  end

  -- Pull in remaing spells from spellbook, just in case Blizzard missed one
  local specID = addonTable.Utilities.GetSpecID()
  local className = UnitClass("player")
  for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
    if skillLineInfo.name == className or skillLineInfo.specID == specID then
      local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
      for j = offset+1, offset+numSlots do
        local info = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
        if info.spellID and not info.isPassive then
          ProcessSpellID(info.spellID)
        elseif info.itemType == Enum.SpellBookItemType.Flyout then
          local _, _, count = GetFlyoutInfo(info.actionID)
          for k = 1, count do
            local spellID = GetFlyoutSlotInfo(info.actionID, k)
            if spellID then
              ProcessSpellID(spellID)
            end
          end
        end
      end
    end
  end

  return result
end

local function GetAllRacialAbilities(seen)
  local result = {}
  seen = seen or {}

  local function ProcessSpellID(spellID)
    local base = C_Spell.GetBaseSpell(spellID)
    if not seen[spellID] and not seen[base] then
      table.insert(result, base or spellID)
    end
    seen[spellID] = true
    if base then
      seen[base] = true
    end
  end

  -- Pull in remaing spells from spellbook, just in case Blizzard missed one
  for i = 1, C_SpellBook.GetNumSpellBookSkillLines() do
    local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(i)
    local offset, numSlots = skillLineInfo.itemIndexOffset, skillLineInfo.numSpellBookItems
    for j = offset+1, offset+numSlots do
      local info = C_SpellBook.GetSpellBookItemInfo(j, Enum.SpellBookSpellBank.Player)
      if info.subName == racialText and info.spellID and not info.isPassive then
        ProcessSpellID(info.spellID)
      end
    end
  end

  return result
end

if addonTable.Constants.IsRetail then
  function addonTable.Core.GetAllClassAbilities()
    local result = {}
    local seen = {}

    tAppendAll(result, GetCDMAbilities(seen))

    table.insert(result, addonTable.Constants.GCD) -- Global Cooldown

    tAppendAll(result, GetAllSpellBookAbilities(seen))
    tAppendAll(result, GetAllRacialAbilities(seen))

    return result
  end
else
  function addonTable.Core.GetAllClassAbilities()
    local result = {}
    local seen = {}

    for _, entry in ipairs(addonTable.Data.Spells[UnitClassBase("player")]) do
      local spellID = entry.spells[#entry.spells]
      if not C_Spell.IsSpellPassive(spellID) then
        table.insert(result, spellID)
      end
      for _, spellID in ipairs(entry.spells) do
        seen[spellID] = true
      end
    end

    tAppendAll(result, GetAllRacialAbilities(seen))

    --table.insert(result, addonTable.Constants.GCD) -- Global Cooldown

    return result
  end
end

function addonTable.Core.GetAllAbilities()
  local result = addonTable.Core.GetAllClassAbilities()

  if addonTable.Constants.IsRetail then
    local seen = {}

    local skyridingFlyoutID = 229
    local _, _, skyridingSpellCount = GetFlyoutInfo(skyridingFlyoutID)
    for i = 1, skyridingSpellCount do
      local spellID, _, isKnown = GetFlyoutSlotInfo(skyridingFlyoutID, i)
      if spellID and isKnown and not C_Spell.IsSpellPassive(spellID) and not seen[spellID] then
        table.insert(result, spellID)
        seen[spellID] = true
      end
    end
  end

  return result
end

if addonTable.Constants.IsRetail then
  function addonTable.Core.GetAllItems()
    return {
      5512, 224464, -- Healthstone, Demonic Healthstone (Warlock)
      -- Potions:
      245897, 245898, 241309, 241308, 241305, 241304, 241307, 241306, 241287, 241286, 241303, 241302, 241301, 241300, 241295, 241294, 241289, 241288, 245900, 245901, 241297, 241296, 241299, 241298, 263974, 241293, 241292, 241339, 241338, 258138,
      -- Food
      275259, --Hearty Venom-Spiced Cutlets
      275262, --Hearty Puffer Plate
      275263, --Hearty Sweet-And-Sour Skewers
      275267, --Hearty Amani Cornucopia
      275268, --Hearty Loa's Gathering
      275269, --Hearty Feast of Knowledge
  }
  end
else
  function addonTable.Core.GetAllItems()
    return {
      5512, -- Healthstone
  }
  end
end

function addonTable.Core.GetAllEquipment()
  local result = {}
  for i = 1, 16 do
    table.insert(result, i)
  end
  table.remove(result, 4)
  return result
end
