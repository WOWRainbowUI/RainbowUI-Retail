---@class addonTableChattynator
local addonTable = select(2, ...)

local itemPattern = "|cnIQ%d?:|Hitem:%d+:[:%d%a-]*|h%[[^|]+%]|h|r"
local function ItemIcons(data)
  if data.typeInfo.player then
    data.text = data.text:gsub(itemPattern, function(itemLink) 
      local _,_,_,_,iconID = C_Item.GetItemInfoInstant(itemLink)
      return "|T" .. iconID .. ":TextHeight-1:TextHeight-1:0:-1:64:64:5:59:5:59|t" .. itemLink
    end)
  end
end

function addonTable.Modifiers.InitializeItemIcons()
  if addonTable.Config.Get(addonTable.Config.Options.ITEM_ICONS) then
    addonTable.Messages:AddLiveModifier(ItemIcons)
  end
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.ITEM_ICONS then
      if addonTable.Config.Get(addonTable.Config.Options.ITEM_ICONS) then
        addonTable.Messages:AddLiveModifier(ItemIcons)
      else
        addonTable.Messages:RemoveLiveModifier(ItemIcons)
      end
    end
  end)
end
