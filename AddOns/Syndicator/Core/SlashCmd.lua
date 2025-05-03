Syndicator.SlashCmd = {}

function Syndicator.SlashCmd.Initialize()
  SlashCmdList["Syndicator"] = Syndicator.SlashCmd.Handler
  SLASH_Syndicator1 = "/syndicator"
  SLASH_Syndicator2 = "/syn"
end

local INVALID_OPTION_VALUE = "錯誤的設定值類型 %s (需要 %s)"
function Syndicator.SlashCmd.Config(optionName, value1, ...)
  if optionName == nil then
    Syndicator.Utilities.Message("沒有提供設定名稱")
    for _, name in pairs(Syndicator.Config.Options) do
      Syndicator.Utilities.Message(name .. ": " .. tostring(Syndicator.Config.Get(name)))
    end
    return
  end

  local currentValue = Syndicator.Config.Get(optionName)
  if currentValue == nil then
    Syndicator.Utilities.Message("未知的設定: " .. optionName)
    return
  end

  if value1 == nil then
    Syndicator.Utilities.Message("設定 " .. optionName .. ": " .. tostring(currentValue))
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
    Syndicator.Utilities.Message("無法編輯選項類型 " .. type(currentValue))
    return
  end
  Syndicator.Utilities.Message("現在設為 " .. optionName .. ": " .. tostring(Syndicator.Config.Get(optionName)))
end

function Syndicator.SlashCmd.Debug()
  Syndicator.Config.Set(Syndicator.Config.Options.DEBUG, not Syndicator.Config.Get(Syndicator.Config.Options.DEBUG))
  if Syndicator.Config.Get(Syndicator.Config.Options.DEBUG) then
    Syndicator.Utilities.Message("開啟除錯模式")
  else
    Syndicator.Utilities.Message("關閉除錯模式")
  end
end

function Syndicator.SlashCmd.RemoveCharacter(characterName)
  local success = pcall(Syndicator.API.DeleteCharacter, characterName)

  if not success then
    Syndicator.Utilities.Message("無法辨識或當前角色")
  else
    Syndicator.Utilities.Message("角色 '" .. characterName .. "' 已移除。")
  end
end

function Syndicator.SlashCmd.RemoveGuild(...)
  local guildName = strjoin(" ", ...)
  local success = pcall(Syndicator.API.DeleteGuild, guildName)

  if not success then
    Syndicator.Utilities.Message("無法辨識或當前公會")
  else
    Syndicator.Utilities.Message("公會 '" .. guildName .. "' 已移除。")
  end
end

function Syndicator.SlashCmd.HideCharacter(characterName)
  local success = pcall(Syndicator.API.ToggleCharacterHidden, characterName)
  if not success then
    Syndicator.Utilities.Message("無法辨識的角色")
  else
    local characterData = Syndicator.API.GetByCharacterFullName(characterName)
    Syndicator.Utilities.Message("角色 '" .. characterName .. "' 已隱藏: " .. tostring(characterData.details.hidden))
  end
end

function Syndicator.SlashCmd.HideGuild(...)
  local guildName = strjoin(" ", ...)
  local success = pcall(Syndicator.API.ToggleGuildHidden, guildName)

  if not success then
    Syndicator.Utilities.Message("無法辨識的公會")
  else
    local guildData = Syndicator.API.GetByGuildFullName(guildName)
    Syndicator.Utilities.Message("公會 '" .. guildName .. "' 已隱藏: " .. tostring(guildData.details.hidden))
  end
end

function Syndicator.SlashCmd.CustomiseUI()
  Syndicator.CallbackRegistry:TriggerEvent("ShowCustomise")
end

local COMMANDS = {
  [""] = function() Settings.OpenToCategory(Syndicator.Locales.SYNDICATOR) end,
  ["c"] = Syndicator.SlashCmd.Config,
  ["config"] = Syndicator.SlashCmd.Config,
  ["d"] = Syndicator.SlashCmd.Debug,
  ["debug"] = Syndicator.SlashCmd.Debug,
  ["remove"] = Syndicator.SlashCmd.RemoveCharacter,
  ["removecharacter"] = Syndicator.SlashCmd.RemoveCharacter,
  ["removeguild"] = Syndicator.SlashCmd.RemoveGuild,
  ["hide"] = Syndicator.SlashCmd.HideCharacter,
  ["hidecharacter"] = Syndicator.SlashCmd.HideCharacter,
  ["hideguild"] = Syndicator.SlashCmd.HideGuild,
}
function Syndicator.SlashCmd.Handler(input)
  local split = {strsplit("\a", (input:gsub("%s+","\a")))}

  local root = split[1]
  if COMMANDS[root] ~= nil then
    table.remove(split, 1)
    COMMANDS[root](unpack(split))
  else
    Syndicator.Utilities.Message("未知的指令 '" .. root .. "'")
  end
end
