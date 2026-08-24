---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Core.GenerateSpellOverrides()
  local spellEssential = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Essential, true)
  local spellUtility = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.Utility, true)

  local auraTracked = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBuff, true)
  local auraBars = C_CooldownViewer.GetCooldownViewerCategorySet(Enum.CooldownViewerCategory.TrackedBar, true)

  local all = spellEssential
  tAppendAll(all, spellUtility)
  tAppendAll(all, auraTracked)
  tAppendAll(all, auraBars)

  local equivalence = {}

  for _, id in ipairs(all) do
    local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(id)
    if info.overrideSpellID then
      equivalence[info.overrideSpellID] = info.spellID
      equivalence[info.spellID] = info.overrideSpellID
    end
  end

  return equivalence
end
