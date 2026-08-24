---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
addonTable.CallbackRegistry:OnLoad()
addonTable.CallbackRegistry:GenerateCallbackEvents(addonTable.Constants.Events)

local hidden = CreateFrame("Frame")
hidden:Hide()
addonTable.hiddenFrame = hidden

local function ImportExisting()
  local spec = addonTable.Utilities.GetSpecID()
  local existing = addonTable.Core.GetExistingLayoutName()
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
  -- Import existing layout (if set)
  if existing and (assignments[spec] == nil or assignments[spec] == addonTable.Constants.DefaultName) then
    local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[spec]
    local newName = addonTable.Locales.IMPORTED_X:format(existing)
    local new = addonTable.Core.GenerateCoolinatorLayoutFromExisting(existing)
    if not new.entries[1] or #new.entries[1].entries == 0 then
      return
    end
    designs[newName] = new
    assignments[spec] = newName

    return true
  end
  return false
end

function addonTable.Core.AutoGenerateLayout(name)
  local spec = addonTable.Utilities.GetSpecID()
  local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
  if not designs[spec] then
    designs[spec] = {}
  end
  designs[spec][name or addonTable.Constants.DefaultName] = addonTable.Core.GenerateDefaultCDMLayout()
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
  if assignments[spec] == nil then
    assignments[spec] = addonTable.Constants.DefaultName
  end
end

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()
  addonTable.SlashCmd.Initialize()

  addonTable.Core.MigrateSettings()

  addonTable.Assets.Initialize()

  addonTable.CustomiseDialog.Initialize()
  addonTable.Designer.Initialize()

  CreateFrame("Frame", "CoolinatorPrimaryGroupAnchor")

  addonTable.State.UsingMasque = C_AddOns.IsAddOnLoaded("Masque") and addonTable.Config.Get(addonTable.Config.Options.USE_MASQUE)
end

local function GetCDMActiveLayout()
  local id = CooldownViewerSettings.layoutManager.activeLayoutID
  local layout = CooldownViewerSettings.layoutManager.layouts[id]
  return layout and layout.layoutName
end

local function ValidateCDM()
  if GetCDMActiveLayout() ~= "Coolinator (" .. CooldownViewerUtil.GetCurrentClassAndSpecTag() .. ")" then
    addonTable.State.CDM = nil
    addonTable.Dialogs.ShowConfirm(addonTable.Locales.SPEC_MISMATCH_IN_BLIZZARD_CDM, RELOADUI, CANCEL, ReloadUI)
    return false
  end
  return true
end

local function TriggerUpdate()
  addonTable.CallbackRegistry:TriggerEvent("CDMUpdating", true)
  addonTable.CurrentNumberFont = addonTable.Core.GetFont()

  addonTable.Core.AutoGenerateLayout()
  addonTable.SpellEquivalence = addonTable.Core.GenerateSpellOverrides()
  ImportExisting()
  local layout = addonTable.Core.GetCurrentDesign()
  if layout then
    addonTable.Core.ApplyPresets(layout)
    addonTable.State.CDM = {auraMap = addonTable.Core.GetCDMMappingAuras()}
    addonTable.State.Bindings = addonTable.Core.StoreKeyBindings()
    addonTable.CallbackRegistry:TriggerEvent("CDMUpdating", false)
    addonTable.CallbackRegistry:TriggerEvent("Layout")
    addonTable.CallbackRegistry:TriggerEvent("Designer.Layout")
  end
end
addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, refreshState)
  if refreshState[addonTable.Constants.RefreshReason.Design] then
    TriggerUpdate()
  elseif refreshState[addonTable.Constants.RefreshReason.Reload] then
    addonTable.Dialogs.ShowConfirm(addonTable.Locales.SETTING_CHANGED_THAT_REQUIRES_A_RELOAD, RELOADUI, CANCEL, ReloadUI)
  end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("SPELLS_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_BINDINGS")
frame:RegisterEvent("UPDATE_MACROS")
frame:RegisterEvent("GROUP_FORMED")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
frame:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("TRAIT_CONFIG_UPDATED")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
frame:RegisterEvent("LOADING_SCREEN_ENABLED")
frame:RegisterEvent("PVP_MATCH_STATE_CHANGED") -- Cooldowns sometimes reset on this event (PvP Shuffle rounds)
frame:RegisterUnitEvent("UNIT_PET", "player")
frame:SetScript("OnEvent", function(_, eventName, data1, data2)
  if eventName == "ADDON_LOADED" and data1 == "Coolinator" then
    addonTable.Core.Initialize()
  elseif eventName == "TRAIT_CONFIG_UPDATED" or eventName == "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" or eventName == "GROUP_FORMED" then
    TriggerUpdate()
  elseif eventName == "SPELL_UPDATE_ICON" then
    addonTable.CallbackRegistry:TriggerEvent("Update.SpellIcons", data1)
  elseif eventName == "PLAYER_ENTERING_WORLD"  then
    C_Timer.After(0, function()
      frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    end)
    if not data1 and not data2 then
      addonTable.CallbackRegistry:TriggerEvent("Layout")
      addonTable.CallbackRegistry:TriggerEvent("Designer.Layout")
    end
  elseif eventName == "PVP_MATCH_STATE_CHANGED" then
    addonTable.CallbackRegistry:TriggerEvent("Layout")
  elseif eventName == "UPDATE_BINDINGS" or eventName == "ACTIONBAR_SLOT_CHANGED" or eventName == "UPDATE_MACROS" or eventName == "UPDATE_SHAPESHIFT_FORM" then
    addonTable.State.Bindings = addonTable.Core.StoreKeyBindings()
    addonTable.CallbackRegistry:TriggerEvent("Update.KeyBindings")
  elseif eventName == "SPELLS_CHANGED" then
    local layout = addonTable.Core.GetCurrentDesign()
    addonTable.State.CDM = addonTable.Core.GetCDMOrderAurasOnly()
    if layout then
      addonTable.CallbackRegistry:TriggerEvent("Update.SpellsDisplay")
    end
  elseif eventName == "UNIT_PET" then
    addonTable.CallbackRegistry:TriggerEvent("Layout")
  elseif eventName == "UNIT_INVENTORY_CHANGED" then
    frame:SetScript("OnUpdate", function()
      frame:SetScript("OnUpdate", nil)
      addonTable.CallbackRegistry:TriggerEvent("Layout")
      addonTable.CallbackRegistry:TriggerEvent("Designer.Layout")
    end)
  elseif eventName == "LOADING_SCREEN_ENABLED" then
    frame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
  end
end)

EventUtil.ContinueOnPlayerLogin(function()
  addonTable.CurrentNumberFont = addonTable.Core.GetFont()
  addonTable.State.CDM = addonTable.Core.GetCDMOrderAurasOnly()
  addonTable.SpellEquivalence = addonTable.Core.GenerateSpellOverrides()

  addonTable.Core.AutoGenerateLayout()
  local layout = addonTable.Core.GetCurrentDesign()
  if layout then
    addonTable.Core.ApplyPresets(layout)
  end

  addonTable.Display.LayoutManager = addonTable.Utilities.InitFrameWithMixin(UIParent, addonTable.Display.LayoutManagerNextMixin)
  addonTable.Designer.LayoutManager = addonTable.Utilities.InitFrameWithMixin(UIParent, addonTable.Designer.LayoutManagerMixin)
end)

local startupFrame = CreateFrame("Frame")
startupFrame:RegisterEvent("VARIABLES_LOADED")
startupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
startupFrame:RegisterEvent("COOLDOWN_VIEWER_DATA_LOADED")
startupFrame:RegisterEvent("SPELLS_CHANGED")
local seen = 4
startupFrame:SetScript("OnEvent", function(_, eventName)
  startupFrame:UnregisterEvent(eventName)
  seen = seen - 1
  if seen == 0 then
    if ImportExisting() then
      local layout = addonTable.Core.GetCurrentDesign()
      addonTable.Core.ApplyPresets(layout)
    end

    C_CVar.SetCVar("cooldownViewerEnabled", "0")

    addonTable.CallbackRegistry:TriggerEvent("Layout")
  end
end)

function addonTable.Core.GetCurrentDesign()
  local spec = addonTable.Utilities.GetSpecID()
  local assignment = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)[spec]
  local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
  if not designs[spec] then
    return
  end
  return designs[spec][assignment or addonTable.Constants.DefaultName]
end

function Coolinator_AddonCompartmentCallback()
  addonTable.CustomiseDialog.Toggle()
end
