local AddonName, MKPT_env, _ = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("Myu's Knowledge Points Tracker")

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")

local EventHandler = {}

events:SetScript("OnEvent", function(_, event, ...)
  EventHandler[event](...)
end)

function EventHandler.ADDON_LOADED(loadedAddonName, _)
  if loadedAddonName ~= AddonName then return end

  MKPT_env.InitializeSavedVariables()
  MKPT_env.InitializeSlashCommand()
  MKPT_env.InitializeMinimapIcon()
  MKPT_env.InitializeCompartmentIcon()
  MKPT_env.InitializeOptionsMenu()

  events:UnregisterEvent("ADDON_LOADED")
end

function EventHandler.PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi, _)
  if not (isInitialLogin or isReloadingUi) then return end

  MKPT_env.InitProfessions()
  MKPT_env.CreateUI()

  if MKPT_env.charDb.state.show then
    MKPT_env.ui:Show()
  end

  MKPT_env.RefreshAutoHide()

  events:RegisterEvent("LEARNED_SPELL_IN_SKILL_LINE")
  events:RegisterEvent("SKILL_LINES_CHANGED")
  events:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
  events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  events:RegisterEvent("BAG_UPDATE_DELAYED")
  events:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE")
  events:RegisterEvent("VIGNETTES_UPDATED")
  events:RegisterEvent("NAVIGATION_DESTINATION_REACHED")
  events:RegisterEvent("PLAYER_REGEN_DISABLED")
  events:RegisterEvent("PLAYER_REGEN_ENABLED")
  events:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
  events:RegisterEvent("TRAIT_CONFIG_UPDATED")

  events:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function EventHandler.LEARNED_SPELL_IN_SKILL_LINE(spellId, _)
  local profession = MKPT_env.FindProfessionBySpellId(spellId)
  if profession then
    local f = MKPT_env.ui
    f:UpdateDetail()
    f:RenderTree()
  end
end

function EventHandler.SKILL_LINES_CHANGED()
  local f = MKPT_env.ui
  f:RenderTree()
  MKPT_env.RefreshTrackedItem()
end

function EventHandler.CURRENCY_DISPLAY_UPDATE(currencyId, ...)
  if MKPT_env.IsTrackedCurrency(currencyId) or MKPT_env.MKPT_Profession.FindProfessionByCatchUpCurrencyId(currencyId) then
    local f = MKPT_env.ui
    f:RenderTree()
    MKPT_env.RefreshTrackedItem()
  end
end

function EventHandler.BAG_UPDATE_DELAYED()
  local f = MKPT_env.ui
  f:RenderTree()
  MKPT_env.RefreshTrackedItem()
end

function EventHandler.ZONE_CHANGED_NEW_AREA()
  local inInstance, _ = IsInInstance()
  local f = MKPT_env.ui

  if inInstance then
    f:Hide()
    return
  end

  f:RenderTree()
  if MKPT_env.charDb.state.show then
    f:Show()
  else
    f:Hide()
  end
end

function EventHandler.ACTIVE_DELVE_DATA_UPDATE()
  if C_PartyInfo.IsDelveInProgress() then
    local f = MKPT_env.ui
    f:Hide()
  end
end

function EventHandler.VIGNETTES_UPDATED()
  local trackedItem = MKPT_env.MKPT_Item.GetTrackedItem()
  if not trackedItem or not trackedItem.vignetteId then
    return
  end

  local vignettes = C_VignetteInfo.GetVignettes() or {}
  for _, trackedVignette in ipairs(trackedItem.vignetteId) do
    for _, guid in pairs(vignettes) do
      local info = C_VignetteInfo.GetVignetteInfo(guid)
      if info and info.vignetteID == trackedVignette then
        C_SuperTrack.SetSuperTrackedVignette(guid)
        if SuperTrackedFrame and SuperTrackedFrame.SetTargetAlphaForState then
          SuperTrackedFrame:SetTargetAlphaForState(0, 0.6)
        end
        return
      end
    end
  end
end

function EventHandler.NAVIGATION_DESTINATION_REACHED()
  EventHandler.VIGNETTES_UPDATED()
end

local isVisibleBeforeCombat = false

function EventHandler.PLAYER_REGEN_DISABLED()
  if not MKPT_env.db.ui.hideInCombat then
    return
  end
  isVisibleBeforeCombat = MKPT_env.ui:IsShown()
  MKPT_env.ui:Hide()
end

function EventHandler.PLAYER_REGEN_ENABLED()
  if not MKPT_env.db.ui.hideInCombat then
    return
  end
  if isVisibleBeforeCombat then
    MKPT_env.ui:Show()
  end
end

function EventHandler.TRAIT_CONFIG_UPDATED(_)
  MKPT_env.ui:RenderTree()
end