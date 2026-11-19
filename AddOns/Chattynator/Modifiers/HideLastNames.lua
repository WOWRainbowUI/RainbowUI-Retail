---@class addonTableChattynator
local addonTable = select(2, ...)

local playerPattern = "(|Hplayer:[^|]+|h%[?)(|?c?)([^|]-)(|?r?)(%]?|h)"
local sep = " "
if Constants.CharacterNameSeparatorConsts then -- Only exists on Forever
  sep = Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR
end
local function HideLastNames(data)
  if data.typeInfo.player and data.typeInfo.player.name then
    data.text = data.text:gsub(playerPattern, function(x1, x2, x3, x4, x5)
      if x2 == "|c" then
        return x1 .. x2 .. x3:gsub("([fF][fF]%x%x%x%x%x%x%d?%d?:?[^" .. sep .. "]+).*", "%1") .. x4 .. x5
      else
        return x1 .. x2 .. x3:gsub("^(%d?%d?:?[^"..sep.."]+)%s.*", "%1") .. x4 .. x5
      end
    end, 1)
  end
end

function addonTable.Modifiers.InitializeHideLastNames()
  if not addonTable.Constants.IsForever then
    return
  end

  if addonTable.Config.Get(addonTable.Config.Options.HIDE_LAST_NAMES) then
    addonTable.Messages:AddLiveModifier(HideLastNames)
  end
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.HIDE_LAST_NAMES then
      if addonTable.Config.Get(addonTable.Config.Options.HIDE_LAST_NAMES) then
        addonTable.Messages:AddLiveModifier(HideLastNames)
      else
        addonTable.Messages:RemoveLiveModifier(HideLastNames)
      end
    end
  end)
end
