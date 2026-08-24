---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.CustomiseDialog.ImportData(import, name, overwrite)
  if import.addon ~= "Coolinator" then
    return false, 1
  end

  if name:match("^_") then
    return false, 2
  end

  import.addon = nil
  if import.kind == "design" then
    local designsRoot = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
    local specID = import.specID or addonTable.Utilities.GetSpecID()
    if not designsRoot[specID] then
      designsRoot[specID] = {}
    end
    local designs = designsRoot[specID]
    if designs[name] and not overwrite then
      return false, 3
    end

    addonTable.Core.UpgradeDesign(import.data)
    designs[name] = import.data

    addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)[import.specID or addonTable.Utilities.GetSpecID()] = name

    addonTable.Core.GeneratePresetsFromDesign(import.data, false)

    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})

  elseif import.kind == "profile" then
    import.version = nil
    import.kind = nil
    if overwrite and COOLINATOR_CONFIG.Profiles[name] then
      local oldDesigns = COOLINATOR_CONFIG.Profiles[name].designs
      local old = addonTable.Config.CurrentProfile
      COOLINATOR_CONFIG.Profiles[name] = import
      local designs = COOLINATOR_CONFIG.Profiles[name].designs
      for key, design in pairs(oldDesigns) do
        if designs[key] == nil then
          designs[key] = design
        end
      end
      addonTable.Config.ChangeProfile(name, old)
    else
      if COOLINATOR_CONFIG.Profiles[name] then
        return false, 4
      end
      addonTable.Config.MakeProfile(name, false)
      local old = addonTable.Config.CurrentProfile
      COOLINATOR_CONFIG.Profiles[COOLINATOR_CURRENT_PROFILE] = import
      addonTable.Config.ChangeProfile(COOLINATOR_CURRENT_PROFILE, old)
    end
  end

  return true
end
