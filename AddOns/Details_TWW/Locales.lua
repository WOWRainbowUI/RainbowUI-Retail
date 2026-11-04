local _, app = ...
local L = setmetatable({}, {__index = function(_, key) return key end})
app.L = L
app.displayName = "戰鬥統計外觀-地心之戰"
if GetLocale() == "zhTW" then
L["Skin the Blizzard damage meter"] = "套用暴雪傷害統計外觀"
L["Applies the 'The War Within' skin to the game's built-in damage meter, whichever style is picked in Edit Mode."] = "將地心之戰外觀套用至遊戲內建傷害統計，不受編輯模式所選樣式影響。"
L["Bar texture"] = "量條材質"
L["The fill of the damage meter bars. Bright shows the class color almost at full strength."] = "傷害統計量條的填色材質。「明亮」會顯示接近完整亮度的職業顏色。"
L["Default"] = "預設"
L["Bright"] = "明亮"
L["Apply to all Details! windows"] = "套用至所有 Details! 視窗"
L["Switches every open Details! window to the 'The War Within' skin. The skin is also in the skin list of Details!' own options, to pick it per window."] = "將所有開啟的 Details! 視窗切換至地心之戰外觀。也能在 Details! 選項的外觀清單中，逐一選擇視窗外觀。"
L["Switch every open Details! window to the 'The War Within' skin? This replaces the windows' appearance settings."] = "要將所有開啟的 Details! 視窗切換至地心之戰外觀嗎？這會取代視窗目前的外觀設定。"
L["Applied the Details! skin to %d window(s)."] = "已將 Details! 外觀套用至 %d 個視窗。"
L["Show minimap button"] = "顯示小地圖按鈕"
L["The minimap button opens these options."] = "點擊小地圖按鈕開啟這些設定。"
L["Log level"] = "記錄層級"
L["Left-click: options"] = "左鍵：設定選項"
L["The War Within: cast bar style bars, round class and spec icons and the TWW title bar."] = "地心之戰：施法條樣式量條、圓形職業及專精圖示與地心之戰標題列。"
end
if GetLocale() == "zhCN" then
L["Skin the Blizzard damage meter"] = "应用暴雪伤害统计外观"
L["Applies the 'The War Within' skin to the game's built-in damage meter, whichever style is picked in Edit Mode."] = "将地心之战外观应用于游戏内置伤害统计，不受编辑模式所选样式影响。"
L["Bar texture"] = "计量条材质"
L["The fill of the damage meter bars. Bright shows the class color almost at full strength."] = "伤害统计计量条的填充材质。“明亮”会显示接近完整亮度的职业颜色。"
L["Default"] = "默认"
L["Bright"] = "明亮"
L["Apply to all Details! windows"] = "应用到所有 Details! 窗口"
L["Switches every open Details! window to the 'The War Within' skin. The skin is also in the skin list of Details!' own options, to pick it per window."] = "将所有打开的 Details! 窗口切换至地心之战外观。也可在 Details! 选项的外观列表中逐个选择窗口外观。"
L["Switch every open Details! window to the 'The War Within' skin? This replaces the windows' appearance settings."] = "是否将所有打开的 Details! 窗口切换至地心之战外观？这将替换窗口当前的外观设置。"
L["Applied the Details! skin to %d window(s)."] = "已将 Details! 外观应用到 %d 个窗口。"
L["Show minimap button"] = "显示小地图按钮"
L["The minimap button opens these options."] = "点击小地图按钮打开这些设置。"
L["Log level"] = "日志级别"
L["Left-click: options"] = "左键：设置选项"
L["The War Within: cast bar style bars, round class and spec icons and the TWW title bar."] = "地心之战：施法条样式计量条、圆形职业及专精图标和地心之战标题栏。"
end
