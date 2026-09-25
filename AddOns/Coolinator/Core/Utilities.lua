---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Utilities.Message(text)
  print("|cff96742a" .. addonTable.Locales.COOLINATOR .. "|r: " .. text)
end

function addonTable.Utilities.InitFrameWithMixin(parent, mixin)
  local f = CreateFrame("Frame", nil, parent)
  Mixin(f, mixin)
  f:OnLoad()
  return f
end

do
  local callbacksPending = {}
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("ADDON_LOADED")
  frame:SetScript("OnEvent", function(_, _, addonName)
    if callbacksPending[addonName] then
      for _, cb in ipairs(callbacksPending[addonName]) do
        xpcall(cb, CallErrorHandler)
      end
      callbacksPending[addonName] = nil
    end
  end)

  local AddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

  -- Necessary because cannot nest EventUtil.ContinueOnAddOnLoaded
  function addonTable.Utilities.OnAddonLoaded(addonName, callback)
    if select(2, AddOnLoaded(addonName)) then
      xpcall(callback, CallErrorHandler)
    else
      callbacksPending[addonName] = callbacksPending[addonName] or {}
      table.insert(callbacksPending[addonName], callback)
    end
  end
end

local setupComplete = false
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
  frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
  setupComplete = true
end)
function addonTable.Utilities.IsAurasRestricted()
  return setupComplete and (InCombatLockdown() or C_Secrets.ShouldAurasBeSecret())
end

local auraTypes = {
  [Enum.AddOnRestrictionType.Combat] = true,
  [Enum.AddOnRestrictionType.Encounter] = true,
  [Enum.AddOnRestrictionType.ChallengeMode] = true,
  [Enum.AddOnRestrictionType.PvPMatch] = true,
}
function addonTable.Utilities.WillRestrictionApplySoon(restrictionType, state)
  return state == Enum.AddOnRestrictionState.Activating and auraTypes[restrictionType] and not addonTable.Utilities.IsAurasRestricted()
end

if not addonTable.Constants.IsForever then
  local prevSpec = 1
  function addonTable.Utilities.GetSpecID()
    local specIndex = C_SpecializationInfo.GetSpecialization() or prevSpec
    local spec = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    prevSpec = specIndex
    return spec
  end
else
  local prevSpec = 1
  local _, class = UnitClass("player")
  function addonTable.Utilities.GetSpecID()
    local specIndex = C_SpecializationInfo.GetActiveSpecGroup() or prevSpec
    local spec = class .. specIndex
    prevSpec = specIndex
    return spec
  end
end

function addonTable.Utilities.PurgeKey(t, k)
  t[k] = nil
  local c = 42
  repeat
    if t[c] == nil then
      t[c] = nil
    end
    c = c + 1
  until issecurevariable(t, k)
end

local function BasicIsAbilitySpellKnown(spellID)
  local newSpellID = C_Spell.GetOverrideSpell(spellID)
  if C_Spell.IsSpellPassive(newSpellID) then
    return
  end
  if C_SpellBook.IsSpellKnownOrInSpellBook(spellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnownOrInSpellBook(spellID, Enum.SpellBookSpellBank.Pet) then
    return newSpellID or spellID
  end
  if newSpellID and newSpellID ~= spellID then
    if C_SpellBook.IsSpellKnownOrInSpellBook(newSpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnownOrInSpellBook(newSpellID, Enum.SpellBookSpellBank.Pet) then
      return newSpellID
    end
  end
  newSpellID = addonTable.SpellEquivalence[spellID]
  if newSpellID and newSpellID ~= spellID then
    if C_SpellBook.IsSpellKnownOrInSpellBook(newSpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnownOrInSpellBook(newSpellID, Enum.SpellBookSpellBank.Pet) then
      return newSpellID
    end
  end
  if spellID == addonTable.Constants.GCD then
    return spellID
  end

  return nil
end

if addonTable.Constants.IsRetail then
  addonTable.Utilities.IsAbilitySpellKnown = BasicIsAbilitySpellKnown
  function addonTable.Utilities.GetAltAuras(spellID)
    if addonTable.State.CDM.auraMap[spellID] then
      local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(addonTable.State.CDM.auraMap[spellID])
      return cooldownInfo.linkedSpellIDs
    end
  end
else
  local rankData = addonTable.Data.Spells[UnitClassBase("player")]
  local rankMap = {}
  for index, entry in ipairs(rankData) do
    for _, spellID in ipairs(entry.spells) do
      rankMap[spellID] = index
    end
  end
  function addonTable.Utilities.IsAbilitySpellKnown(spellID)
    if rankMap[spellID] then
      local index = rankMap[spellID]
      local spells = rankData[index].spells
      for j = #spells, 1, -1 do
        local newSpellID = BasicIsAbilitySpellKnown(spells[j])
        if newSpellID then
          return newSpellID
        end
      end
    else
      return BasicIsAbilitySpellKnown(spellID)
    end
  end

  function addonTable.Utilities.GetAltAuras(spellID)
    if rankMap[spellID] then
      return rankData[rankMap[spellID]].spells
    end
  end
end
