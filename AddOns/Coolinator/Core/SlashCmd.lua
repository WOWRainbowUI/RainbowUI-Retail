---@class addonTableCoolinator
local addonTable = select(2, ...)
addonTable.SlashCmd = {}

function addonTable.SlashCmd.Initialize()
  SlashCmdList["Coolinator"] = addonTable.SlashCmd.Handler
  SLASH_Coolinator1 = "/coolinator"
  SLASH_Coolinator2 = "/cooli"
end

local INVALID_OPTION_VALUE = "Wrong config value type %s (required %s)"
function addonTable.SlashCmd.Config(optionName, value1, ...)
  if optionName == nil then
    addonTable.Utilities.Message("No config option name supplied")
    for _, name in pairs(addonTable.Config.Options) do
      addonTable.Utilities.Message(name .. ": " .. tostring(addonTable.Config.Get(name)))
    end
    return
  end

  local currentValue = addonTable.Config.Get(optionName)
  if currentValue == nil then
    addonTable.Utilities.Message("Unknown config: " .. optionName)
    return
  end

  if value1 == nil then
    addonTable.Utilities.Message("Config " .. optionName .. ": " .. tostring(currentValue))
    return
  end

  if type(currentValue) == "boolean" then
    if value1 ~= "true" and value1 ~= "false" then
      addonTable.Utilities.Message(INVALID_OPTION_VALUE:format(type(value1), type(currentValue)))
      return
    end
    addonTable.Config.Set(optionName, value1 == "true")
  elseif type(currentValue) == "number" then
    if tonumber(value1) == nil then
      addonTable.Utilities.Message(INVALID_OPTION_VALUE:format(type(value1), type(currentValue)))
      return
    end
    addonTable.Config.Set(optionName, tonumber(value1))
  elseif type(currentValue) == "string" then
    addonTable.Config.Set(optionName, strjoin(" ", value1, ...))
  else
    addonTable.Utilities.Message("Unable to edit option type " .. type(currentValue))
    return
  end
  addonTable.Utilities.Message("Now set " .. optionName .. ": " .. tostring(addonTable.Config.Get(optionName)))
end

function addonTable.SlashCmd.Reset()
  COOLINATOR_CONFIG = nil
  ReloadUI()
end

function addonTable.SlashCmd.Version()
  addonTable.Utilities.Message(
    BLUE_FONT_COLOR:WrapTextInColorCode("Version: ") .. C_AddOns.GetAddOnMetadata("Coolinator", "Version") ..
    LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(", " .. date() .. ", ") ..
    BLUE_FONT_COLOR:WrapTextInColorCode("WoW: ") .. select(4, GetBuildInfo())
  )
end

function addonTable.SlashCmd.CustomiseUI()
  addonTable.CustomiseDialog.Toggle()
end

function addonTable.SlashCmd.Designer()
  addonTable.Designer.Toggle()
end

function addonTable.SlashCmd.ChangeDesign(...)
  if addonTable.Utilities.IsAurasRestricted() then
    addonTable.Utilities.Message(addonTable.Locales.CANNOT_CHANGE_DESIGN_DUE_TO_RESTRICTIONS)
  end
  local name = strjoin(" ", ...)
  local specID = addonTable.Utilities.GetSpecID()
  local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[specID]
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
  if designs[name] then
    addonTable.CallbackRegistry:TriggerEvent("Designer.Close")
    assignments[specID] = name
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  else
    addonTable.Utilities.Message(addonTable.Locales.MISSING_DESIGN_X:format(name))
  end
end

function addonTable.SlashCmd.RegenerateLayout()
  local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[addonTable.Utilities.GetSpecID()]
  addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[addonTable.Utilities.GetSpecID()] = { DEFAULT = designs.DEFAULT }
  addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)[addonTable.Utilities.GetSpecID()] = addonTable.Constants.DefaultName
  addonTable.Designer.GenerateEditable()
end

local COMMANDS = {
  [""] = addonTable.SlashCmd.CustomiseUI,
  ["v"] = addonTable.SlashCmd.Version,
  ["version"] = addonTable.SlashCmd.Version,
  ["d"] = addonTable.SlashCmd.Designer,
  ["design"] = addonTable.SlashCmd.Designer,
  [addonTable.Locales.SLASH_DESIGN] = addonTable.SlashCmd.Designer,
  ["cd"] = addonTable.SlashCmd.ChangeDesign,
  ["changedesign"] = addonTable.SlashCmd.ChangeDesign,
  [addonTable.Locales.SLASH_CHANGE_DESIGN] = addonTable.SlashCmd.ChangeDesign,
  ["c"] = addonTable.SlashCmd.Config,
  ["config"] = addonTable.SlashCmd.Config,
  ["reset"] = addonTable.SlashCmd.Reset,
  [addonTable.Locales.SLASH_RESET] = addonTable.SlashCmd.Reset,
  ["regenerate"] = addonTable.SlashCmd.RegenerateLayout,
  ["regen"] = addonTable.SlashCmd.RegenerateLayout,
  [addonTable.Locales.SLASH_REGEN] = addonTable.SlashCmd.RegenerateLayout,
}
local HELP = {
  {"", addonTable.Locales.SLASH_HELP},
  {addonTable.Locales.SLASH_RESET, addonTable.Locales.SLASH_RESET_HELP},
  {addonTable.Locales.SLASH_DESIGN, addonTable.Locales.SLASH_DESIGN_HELP},
  {addonTable.Locales.SLASH_CHANGE_DESIGN, addonTable.Locales.SLASH_CHANGE_DESIGN_HELP},
  {addonTable.Locales.SLASH_REGEN, addonTable.Locales.SLASH_REGEN_HELP},
}

function addonTable.SlashCmd.Handler(input)
  local split = {strsplit("\a", (input:gsub("%s+","\a")))}

  local root = split[1]
  if COMMANDS[root] ~= nil then
    table.remove(split, 1)
    COMMANDS[root](unpack(split))
  else
    if root ~= "help" and root ~= "h" then
      addonTable.Utilities.Message(addonTable.Locales.SLASH_UNKNOWN_COMMAND:format(root))
    end

    for _, entry in ipairs(HELP) do
      if entry[1] == "" then
        addonTable.Utilities.Message("/cooli - " .. entry[2])
      else
        addonTable.Utilities.Message("/cooli " .. entry[1] .. " - " .. entry[2])
      end
    end
  end
end
