Syndicator.SlashCmd = {}

function Syndicator.SlashCmd.Initialize()
  SlashCmdList["Syndicator"] = Syndicator.SlashCmd.Handler
  SLASH_Syndicator1 = "/syndicator"
  SLASH_Syndicator2 = "/syn"
end

local INVALID_OPTION_VALUE = "Wrong config value type %s (required %s)"
function Syndicator.SlashCmd.Config(optionName, value1, ...)
  if optionName == nil then
    Syndicator.Utilities.Message("No config option name supplied")
    for _, name in pairs(Syndicator.Config.Options) do
      Syndicator.Utilities.Message(name .. ": " .. tostring(Syndicator.Config.Get(name)))
    end
    return
  end

  local currentValue = Syndicator.Config.Get(optionName)
  if currentValue == nil then
    Syndicator.Utilities.Message("Unknown config: " .. optionName)
    return
  end

  if value1 == nil then
    Syndicator.Utilities.Message("Config " .. optionName .. ": " .. tostring(currentValue))
    return
  end

  if type(currentValue) == "boolean" then
    if value1 ~= "true" and value1 ~= "false" then
      Syndicator.Utilities.Message(INVALID_OPTION_VALUE:format(type(value1), type(currentValue)))
      return
    end
    Syndicator.Config.Set(optionName, value1 == "true")
  elseif type(currentValue) == "number" then
    if tonumber(value1) == nil then
      Syndicator.Utilities.Message(INVALID_OPTION_VALUE:format(type(value1), type(currentValue)))
      return
    end
    Syndicator.Config.Set(optionName, tonumber(value1))
  elseif type(currentValue) == "string" then
    Syndicator.Config.Set(optionName, strjoin(" ", value1, ...))
  else
    Syndicator.Utilities.Message("Unable to edit option type " .. type(currentValue))
    return
  end
  Syndicator.Utilities.Message("Now set " .. optionName .. ": " .. tostring(Syndicator.Config.Get(optionName)))
end

function Syndicator.SlashCmd.Debug(...)
  Syndicator.Config.Set(Syndicator.Config.Options.DEBUG, not Syndicator.Config.Get(Syndicator.Config.Options.DEBUG))
  if Syndicator.Config.Get(Syndicator.Config.Options.DEBUG) then
    Syndicator.Utilities.Message("Debug mode on")
  else
    Syndicator.Utilities.Message("Debug mode off")
  end
end

function Syndicator.SlashCmd.RemoveCharacter(characterName)
  local characterData = SYNDICATOR_DATA.Characters[characterName or ""]
  if not characterData then
    Syndicator.Utilities.Message("無法辨識的角色")
    return
  end

  Syndicator.Utilities.RemoveCharacter(characterName)

  Syndicator.Utilities.Message("角色 '" .. characterName .. "' 已移除。")
end

function Syndicator.SlashCmd.HideCharacter(characterName)
  local characterData = SYNDICATOR_DATA.Characters[characterName or ""]
  if not characterData then
    Syndicator.Utilities.Message("無法辨識的角色")
    return
  end

  characterData.details.hidden = not characterData.details.hidden

  Syndicator.Utilities.Message("角色 '" .. characterName .. "' 隱藏狀態: " .. (characterData.details.hidden and "是" or "否"))
end

function Syndicator.SlashCmd.HideGuild(guildName)
  local guildData = SYNDICATOR_DATA.Guilds[guildName or ""]
  if not guildData then
    Syndicator.Utilities.Message("無法辨識的公會")
    return
  end

  guildData.details.hidden = not guildData.details.hidden

  Syndicator.Utilities.Message("角色 '" .. guildName .. "' 已隱藏: " .. tostring(guildData.details.hidden))
end

function Syndicator.SlashCmd.CustomiseUI()
  Syndicator.CallbackRegistry:TriggerEvent("ShowCustomise")
end

local COMMANDS = {
  ["c"] = Syndicator.SlashCmd.Config,
  ["config"] = Syndicator.SlashCmd.Config,
  ["d"] = Syndicator.SlashCmd.Debug,
  ["debug"] = Syndicator.SlashCmd.Debug,
  ["remove"] = Syndicator.SlashCmd.RemoveCharacter,
  ["hide"] = Syndicator.SlashCmd.HideCharacter,
  ["hideguild"] = Syndicator.SlashCmd.HideGuild,
}
function Syndicator.SlashCmd.Handler(input)
  local split = {strsplit("\a", (input:gsub("%s+","\a")))}

  local root = split[1]
  if root == "" then
    Syndicator.Utilities.Message("缺少指令")
  elseif COMMANDS[root] ~= nil then
    table.remove(split, 1)
    COMMANDS[root](unpack(split))
  else
    Syndicator.Utilities.Message("未知的指令 '" .. root .. "'")
  end
end
