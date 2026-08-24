---@class addonTableCoolinator
local addonTable = select(2, ...)
addonTable.Config = {}

local settings = {
  DESIGNS = {key = "designs", default = {}, refresh = {addonTable.Constants.RefreshReason.Design}},
  DESIGN_ASSIGNMENTS = {key = "design_assignments", default = {}, refresh = {addonTable.Constants.RefreshReason.Design}},

  COMPRESS_LAYOUT = {key = "compress_layout", default = true, refresh = {addonTable.Constants.RefreshReason.Design}},
  USE_BLIZZARD_WIDGETS = {key = "use_blizzard_widgets", default = false, refresh = {addonTable.Constants.RefreshReason.Design}},
  SHOW_KEYBINDINGS = {key = "show_keybindings", default = false, refresh = {addonTable.Constants.RefreshReason.Design}},
  SHOW_TOOLTIPS = {key = "show_tooltips", default = true, refresh = {addonTable.Constants.RefreshReason.Design}},
  SHOW_GCD_SWIPE = {key = "show_gcd_swipe", default = false, refresh = {addonTable.Constants.RefreshReason.Design}},

  USE_MASQUE = {key = "use_masque", default = false, refresh = {addonTable.Constants.RefreshReason.Reload}},
  
  PRESETS = {key = "presets", default = {migrated = 1, version = 12}, refresh = {addonTable.Constants.RefreshReason.Design}},

  SOUNDS = {key = "sounds", default = {abilities = {}, auras = {}}},

  SAVED_ANCHORS = {key = "saved_anchors", default = {}},

  NUMBER_FONT = {key = "number_font", default = {asset = addonTable.Constants.DefaultFont, flags = {outline = true, shadow = true, slug = true}, size = 1.0}, refresh = {addonTable.Constants.RefreshReason.Design}},

  CURRENT_SKIN = {key = "current_skin", default = "blizzard"},
}

addonTable.Config.RefreshType = {}

addonTable.Config.Options = {}
addonTable.Config.Defaults = {}

for key, details in pairs(settings) do
  if details.refresh then
    local refreshType = {}
    for _, r in ipairs(details.refresh) do
      refreshType[r] = true
    end
    addonTable.Config.RefreshType[details.key] = refreshType
  end
  addonTable.Config.Options[key] = details.key
  addonTable.Config.Defaults[details.key] = details.default
end

function addonTable.Config.IsValidOption(name)
  for _, option in pairs(addonTable.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

local function RawSet(name, value)
  local tree = {strsplit(".", name)}
  if addonTable.Config.CurrentProfile == nil then
    error("COOLINATOR_CONFIG not initialized")
  elseif not addonTable.Config.IsValidOption(tree[1]) then
    error("Invalid option '" .. name .. "'")
  elseif #tree == 1 then
    local oldValue = addonTable.Config.CurrentProfile[name]
    addonTable.Config.CurrentProfile[name] = value
    if value ~= oldValue then
      return true
    end
  else
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree - 1 do
      root = root[tree[i]]
      if type(root) ~= "table" then
        error("Invalid option '" .. name .. "', broke at [" .. i .. "]")
      end
    end
    local tail = tree[#tree]
    if root[tail] == nil then
      error("Invalid option '" .. name .. "', broke at [tail]")
    end
    local oldValue = root[tail]
    root[tail] = value
    if value ~= oldValue then
      return true
    end
  end
  return false
end

function addonTable.Config.Set(name, value)
  if RawSet(name, value) then
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", name)
    if addonTable.Config.RefreshType[name] then
      addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", addonTable.Config.RefreshType[name])
    end
  end
end

-- Set multiple settings at once and after all are set fire the setting changed
-- events
function addonTable.Config.MultiSet(nameValueMap)
  local changed = {}
  for name, value in pairs(nameValueMap) do
    if RawSet(name, value) then
      table.insert(changed, name)
    end
  end

  local refreshState = {}
  for _, name in ipairs(changed) do
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", name)
    if addonTable.Config.RefreshType[name] then
      refreshState = Mixin(refreshState, addonTable.Config.RefreshType[name])
    end
  end
  if next(refreshState) ~= nil then
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", refreshState)
  end
end

local addedInstalledNestedToList = {}
local installedNested = {}

function addonTable.Config.Install(name, defaultValue)
  if COOLINATOR_CONFIG == nil then
    error("COOLINATOR_CONFIG not initialized")
  elseif name:find("%.") == nil then
    if addonTable.Config.CurrentProfile[name] == nil then
      addonTable.Config.CurrentProfile[name] = defaultValue
    end
  else
    if not addedInstalledNestedToList[name] then
      addedInstalledNestedToList[name] = true
      table.insert(installedNested, name)
    end
    local tree = {strsplit(".", name)}
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree - 1 do
      if not root[tree[i]] then
        root[tree[i]] = {}
      end
      root = root[tree[i]]
    end
    if root[tree[#tree]] == nil then
      root[tree[#tree]] = defaultValue
    end
  end
end

function addonTable.Config.ResetOne(name)
  local newValue = addonTable.Config.Defaults[name]
  if newValue == nil then
    error("Can't reset that", name)
  else
    if type(newValue) == "table" then
      newValue = CopyTable(newValue)
    end
    addonTable.Config.Set(name, newValue)
  end
end

function addonTable.Config.Reset()
  COOLINATOR_CONFIG = {
    Profiles = {
      DEFAULT = {},
    },
    CharacterSpecific = {},
    Version = 1,
  }
  addonTable.Config.InitializeData()
end

local function ImportDefaultsToProfile()
  for option, value in pairs(addonTable.Config.Defaults) do
    if addonTable.Config.CurrentProfile[option] == nil then
      if type(value) == "table" then
        addonTable.Config.CurrentProfile[option] = CopyTable(value)
      else
        addonTable.Config.CurrentProfile[option] = value
      end
    end
  end
end

function addonTable.Config.InitializeData()
  if COOLINATOR_CONFIG == nil then
    addonTable.Config.Reset()
    return
  end

  if COOLINATOR_CONFIG.Profiles == nil then
    COOLINATOR_CONFIG = {
      Profiles = {
        DEFAULT = COOLINATOR_CONFIG,
      },
      CharacterSpecific = {},
      Version = 1,
    }
  end

  if COOLINATOR_CONFIG.Profiles.DEFAULT == nil then
    COOLINATOR_CONFIG.Profiles.DEFAULT = {}
  end
  if COOLINATOR_CONFIG.Profiles[COOLINATOR_CURRENT_PROFILE] == nil then
    COOLINATOR_CURRENT_PROFILE = "DEFAULT"
  end

  addonTable.Config.CurrentProfile = COOLINATOR_CONFIG.Profiles[COOLINATOR_CURRENT_PROFILE]
  ImportDefaultsToProfile()
end

function addonTable.Config.GetProfileNames()
  return GetKeysArray(COOLINATOR_CONFIG.Profiles)
end

function addonTable.Config.MakeProfile(newProfileName, clone)
  assert(tIndexOf(addonTable.Config.GetProfileNames(), newProfileName) == nil, "Existing Profile")
  if clone then
    COOLINATOR_CONFIG.Profiles[newProfileName] = CopyTable(addonTable.Config.CurrentProfile)
  else
    COOLINATOR_CONFIG.Profiles[newProfileName] = {}
  end
  addonTable.Config.ChangeProfile(newProfileName)
end

function addonTable.Config.DeleteProfile(profileName)
  assert(profileName ~= "DEFAULT" and profileName ~= COOLINATOR_CURRENT_PROFILE)

  COOLINATOR_CONFIG.Profiles[profileName] = nil
end

function addonTable.Config.DumpCurrentProfile()
  return CopyTable(COOLINATOR_CONFIG.Profiles[COOLINATOR_CURRENT_PROFILE])
end

function addonTable.Config.ChangeProfile(newProfileName, comparisonData)
  assert(tIndexOf(addonTable.Config.GetProfileNames(), newProfileName) ~= nil, "Invalid Profile")

  local changedOptions = {}
  local refreshState = {}
  local newProfile = COOLINATOR_CONFIG.Profiles[newProfileName]
  local oldProfile = comparisonData or addonTable.Config.CurrentProfile

  for name, value in pairs(oldProfile) do
    if value ~= newProfile[name] then
      table.insert(changedOptions, name)
      Mixin(refreshState, addonTable.Config.RefreshType[name] or {})
    end
  end

  tAppendAll(changedOptions, installedNested)

  addonTable.Config.CurrentProfile = newProfile
  COOLINATOR_CURRENT_PROFILE = newProfileName

  ImportDefaultsToProfile()

  addonTable.Core.MigrateSettings()

  for _, name in ipairs(changedOptions) do
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", name)
  end
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", refreshState)
end

function addonTable.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if addonTable.Config.CurrentProfile == nil then
    return addonTable.Config.Defaults[name]
  elseif name:find("%.") == nil then
    return addonTable.Config.CurrentProfile[name]
  else
    local tree = {strsplit(".", name)}
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree do
      root = root[tree[i]]
      if root == nil then
        break
      end
    end
    return root
  end
end
