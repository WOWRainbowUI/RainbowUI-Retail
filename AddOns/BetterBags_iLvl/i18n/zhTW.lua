-- Thanks to RainbowUI on Curse

if(GetLocale() ~= 'zhTW') then
    return
end

local _, ns = ...
local L = ns.L

L["CATEGORY_NAME"] = "低等級";
L["OPTIONS_DESC"] = "選擇要放入此分類的中的物品等級界線 (所有物品等級嚴格低於此數值的物品將被放置在此分類中) 更改數值後，可能會需要重新載入介面。"
L["OPTIONS_INCLUDE_JUNK"] = "灰色品質的物品也要放入此分類";
L["OPTIONS_REFRESH"] = "重新載入介面";
L["OPTIONS_RESET_DEFAULT"] = "重置為預設值";
L["OPTIONS_THRESHOLD"] = "低等級 (預設: _default_)";
L["OPTIONS_THRESHOLD_ERROR"] = "請輸入有效的物品等級數字";
