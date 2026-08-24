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

local prevSpec = 1
function addonTable.Utilities.GetSpecID()
  local specIndex = C_SpecializationInfo.GetSpecialization() or prevSpec
  local spec = C_SpecializationInfo.GetSpecializationInfo(specIndex)
  prevSpec = specIndex
  return spec
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

function addonTable.Utilities.IsAuraSpellKnown(spellID)
  if addonTable.Constants.AurasFromItems[spellID] then
    return spellID
  end
  local mapped = addonTable.State.CDM.auraMap[spellID]
  if mapped then
    local isKnown = C_CooldownViewer.GetCooldownViewerCooldownInfo(mapped).isKnown
    if isKnown then
      return spellID
    end
  end
  return C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Pet)
end

function addonTable.Utilities.IsAbilitySpellKnown(spellID)
  local newSpellID = C_Spell.GetOverrideSpell(spellID)
  if C_Spell.IsSpellPassive(newSpellID) then
    return
  end
  if C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Pet) then
    return newSpellID or spellID
  end
  if newSpellID and newSpellID ~= spellID then
    if C_SpellBook.IsSpellKnown(newSpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(newSpellID, Enum.SpellBookSpellBank.Pet) then
      return newSpellID
    end
  end
  newSpellID = addonTable.SpellEquivalence[spellID]
  if newSpellID and newSpellID ~= spellID then
    if C_SpellBook.IsSpellKnown(newSpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(newSpellID, Enum.SpellBookSpellBank.Pet) then
      return newSpellID
    end
  end
  if spellID == addonTable.Constants.GCD then
    return spellID
  end

  return nil
end
