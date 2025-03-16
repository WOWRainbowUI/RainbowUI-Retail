local L = LibStub("AceLocale-3.0"):NewLocale("EasyFrames", "zhTW")
if not L then return end

L["loaded. Options:"] = "已載入，選項指令："

L["When you change this option you need to reload your UI.\n\n Do you want to reload the UI?"] = "更改此選項需要重新載入介面。\n\n是否要現在重新載入介面?"
L["You are going to toggle the \"Use the Easy Frames style\" setting, you need to reload the UI for it to work correctly.\n\n Do you want to reload the UI?"] = "切換 \"使用傳統頭像風格\" 設定需要重新載入介面才能正常運作。\n\n是否要現在重新載入介面?"

L["Opacity"] = "不透明度"
L["Opacity of combat texture"] = "戰鬥材質的不透明度。"

L["Main options"] = "主要選項"
L["In main options you can set the global options like colored frames, buffs settings, etc"] = "在主要選項中可以設定整體使用的選項，像是彩色框架、職業圖示頭像...等。"

L["Percent"] = "百分比"
L["Current + Max"] = "目前 + 最大"
L["Current + Max + Percent"] = "目前 + 最大 + 百分比"
L["Current + Percent"] = "目前 + 百分比"
L["Custom format"] = "自訂格式"
L["Smart"] = "智能"

L["None"] = "無"
L["Outline"] = "外框"
L["Thickoutline"] = "粗外框"
L["Monochrome"] = "無消除鋸齒外框"

L["Portrait"] = "頭像"
L["Default"] = "預設"
L["Hide"] = "隱藏"

L["HP and MP bars"] = "血量和能量條"

L["Font size"] = "文字大小"
L["Healthbar font size"] = "血量條文字大小"
L["Manabar font size"] = "能量條能量大小"
L["Font family"] = "字體"
L["Healthbar font style"] = "血量條文字樣式"
L["Healthbar font family"] = "血量條字體"
L["Manabar font style"] = "能量條文樣式"
L["Manabar font family"] = "能量條字體"
L["Font style"] = "文字樣式"

L["Reverse the direction of losing health/mana"] = "反向顯示損失的血量/能量"
L["By default direction starting from right to left. If checked direction of losing health/mana will be from left to right"] = "預設的方向是從右到左，勾選時損失血量/能量的方向會從左到右。"

L["Custom format of HP"] = "自訂血量格式"
L["You can set custom HP format. More information about custom HP format you can read on project site.\n\n" ..
    "Formulas:"] = "可以自訂血量格式，關於血量格式的更多相關資訊請參閱插件的專案網站。\n\n公式語法:"
L["Use full values of health"] = "使用完整的血量數值"
L["Formula converts the original value to the specified value.\n\n" ..
    "Description: for example formula is '%.fM'.\n" ..
    "The first part '%.f' is the formula itself, the second part 'M' is the abbreviation\n\n" ..
    "Example, value is 150550. '%.f' will be converted to '151' and '%.1f' to '150.6'"] = "公式語法會將原始的數值轉換成指定的數值。\n\n說明: 例如公式語法為 '%.fM'。\n第一個部分的 '%.f' 是公式本身，第二個部分的 'M' 是百萬的單位簡寫\n\n舉例來說，當數值是 150550 時，'%.f' 會將其轉換成 '151'，而 '%.1f' 會轉換成 '150.6'"
L["Value greater than 1000"] = "數值大於 1000"
L["Value greater than 10 000"] = "數值大於 10,000"
L["Value greater than 100 000"] = "數值大於 100,000"
L["Value greater than 1 000 000"] = "數值大於 1,000,000"
L["Value greater than 10 000 000"] = "數值大於 10,000,000"
L["Value greater than 100 000 000"] = "數值大於 100,000,000"
L["Value greater than 1 000 000 000"] = "數值大於 1,000,000,000"
L["By default all formulas use divider (for value eq 1000 and more it's 1000, for 1 000 000 and more it's 1 000 000, etc).\n\n" ..
    "If checked formulas will use full values of HP (without divider)"] = "所有公式預設都會使用千位分隔符號 (大於或等於 1000 的數值會是 1000，大於或等於 1 000 000 會是 1 000 000，以此類推)。\n\n勾選時，公式會使用完整的血量數值 (沒有分隔符號)。"
L["Displayed HP by pattern"] = "使用文字標籤顯示血量"
L["You can use patterns:\n\n" ..
    "%CURRENT% - return current health\n" ..
    "%MAX% - return maximum of health\n" ..
    "%PERCENT% - return percent of current/max health\n" ..
	"%PERCENT_DECIMAL% - return decimal percent of current/max health\n\n" ..
    "All values are returned from formulas. For set abbreviation use formulas' fields"] = "可以使用的文字標籤有:\n\n%CURRENT% - 傳回目前的血量\n%MAX% - 傳回最大血量\n%PERCENT% - 傳回目前血量除以最大血量的百分比\n%PERCENT_DECIMAL% - 傳回目前血量除以最大血量包含小數點的百分比\n\n所有數值都會透過公式傳回，請使用公式的欄位設定好單位簡寫。"
L["Use Chinese numerals format"] = "使用中文數字單位"
L["By default all formulas use divider (for value eq 1000 and more is 1000, for 1 000 000 and more is 1 000 000, etc).\n" ..
    "But with this option divider eq 10 000 and 100 000 000.\n\n" ..
    "The description of the formulas remains the same, so the description of the formulas is not correct with this parameter, but the formulas work correctly.\n\n" ..
    "Use these formulas for Chinese numerals:\n" ..
    "Value greater than 1000 -> '%.2f万', and '%.2f萬' for zhTW.\n" ..
    "Value greater than 100 000 -> '%.1f万', and '%.1f萬' for zhTW.\n" ..
    "Value greater than 1 000 000 -> '%.1f万', and '%.1f萬' for zhTW.\n" ..
    "Value greater than 10 000 000 -> '%.0f万', and '%.0f萬' for zhTW.\n" ..
    "Value greater than 100 000 000 -> '%.2f亿', and '%.2f億' for zhTW.\n" ..
    "Value greater than 1 000 000 000 -> '%.2f亿', and '%.2f億' for zhTW.\n\n" ..
    "More information about Chinese numerals format you can read on project site"] = "所有公式預設都會使用千位分隔符號 (大於或等於 1000 的數值會是 1000，大於或等於 1 000 000 會是 1 000 000，以此類推)。\n\n勾選時，會使用 10 000 和 100 000 000。\n\n公式的說明仍然相同，因此使用此選項時說明會是不正確的，但公式運算是正確的。\n\n啟用中文數字時建議使用下列公式:\n" ..
	"數值大於 1000 -> '%.2f万', 和 '%.2f萬' (台灣)。\n" ..
    "數值大於 100 000 -> '%.1f万', 和 '%.1f萬' (台灣)。\n" ..
    "數值大於 1 000 000 -> '%.1f万', 和 '%.1f萬' (台灣)。\n" ..
    "數值大於 10 000 000 -> '%.0f万', 和 '%.0f萬' (台灣)。\n" ..
    "數值大於 100 000 000 -> '%.2f亿', 和 '%.2f億' (台灣)。\n" ..
    "數值大於 1 000 000 000 -> '%.2f亿', 和 '%.2f億' (台灣)。\n\n" ..
    "可以在專案網站中閱讀更多關於中文數字單位的資訊"

L["Custom format of mana"] = "自訂能量格式"
L["You can set custom mana format. More information about custom mana format you can read on project site.\n\n" ..
        "Formulas:"] = "可以自訂能量格式，關於能量格式的更多相關資訊請參閱專案網站。\n\n公式語法:"
L["Use full values of mana"] = "使用完整的能量數值"
L["By default all formulas use divider (for value eq 1000 and more it's 1000, for 1 000 000 and more it's 1 000 000, etc).\n\n" ..
        "If checked formulas will use full values of mana (without divider)"] = "所有公式預設都會使用千位分隔符號 (大於或等於 1000 的數值會是 1000，大於或等於 1 000 000 會是 1 000 000，以此類推)。\n\n勾選時，公式會使用完整的能量數值 (沒有分隔符號)。"
L["Displayed mana by pattern"] = "使用文字標籤顯示能量"
L["You can use patterns:\n\n" ..
        "%CURRENT% - return current mana\n" ..
        "%MAX% - return maximum of mana\n" ..
        "%PERCENT% - return percent of current/max mana\n" ..
        "%PERCENT_DECIMAL% - return decimal percent of current/max mana\n\n" ..
        "All values are returned from formulas. For set abbreviation use formulas' fields"] = "可以使用的文字標籤有:\n\n%CURRENT% - 傳回目前的能量\n%MAX% - 傳回最大能量\n%PERCENT% - 傳回目前能量除以最大能量的百分比\n%PERCENT_DECIMAL% - 傳回目前能量除以最大能量包含小數點的百分比\n\n所有數值都會透過公式傳回，請使用公式的欄位設定好單位簡寫。"


L["Frames"] = "框架"
L["Setting for unit frames"] = "單位框架的設定。"

L["Use the Easy Frames style"] = "使用傳統頭像風格"
L["Otherwise, use the standard Blizzard style and textures that they introduced in version 10 (Dragonflight), but with the Easy Frames features applied."] = "否則的話會使用 10 版 (巨龍崛起) 新的暴雪頭像風格和材質，但是仍可套用插件的功能。"
L["Class colored healthbars"] = "血量條使用職業顏色"
L["If checked frames becomes class colored.\n\n" ..
    "This option excludes the option 'Healthbar color is based on the current health value'"] = "勾選時，框架會變成職業顏色。\n\n這個選項會停用 '依據目前血量變化血量條顏色' 選項。"
L["Healthbar color is based on the current health value"] = "依據目前血量變化血量條顏色"
L["Healthbar color is based on the current health value.\n\n"..
    "This option excludes the option 'Class colored healthbars'"] = "依據目前血量變化血量條顏色。\n\n這個選項會停用 '血量條使用職業顏色' 選項。"
L["Custom buffsize"] = "自訂增益效果大小"
L["WARNING: These functions are experimental and may cause errors in logs, such as 'StatusBar:SetWidth()', 'StatusBar:Show()', 'Update_MaxHealthLoss'.\n\n"] = "警告: 這些是實驗性的功能，可能會造成類似這樣的錯誤訊息 'StatusBar:SetWidth()', 'StatusBar:Show()', 'Update_MaxHealthLoss'.\n\n"
L["Buffs settings (like custom buffsize, max buffs count, etc)"] = "增益效果設定 (包括自訂圖示大小、最多圖示數量...等等)。"
L["Turn on custom buffsize"] = "啟用自訂大小"
L["Turn on custom target and focus frames buffsize"] = "啟用目標和專注目標框架的自訂增益效果大小。"
L["Buffs"] = "增益效果"
L["Buffsize"] = "增益效果大小"
L["Self buffsize"] = "自己的增益效果大小"
L["Buffsize that you create"] = "自己施放的增益效果大小。"
L["Highlight dispelled buffs"] = "顯著標示可驅散"
L["Highlight buffs that can be dispelled from target frame"] = "顯著標示目標框架可驅散的效果。"
L["Dispelled buff scale"] = "可驅散的效果縮放大小"
L["Dispelled buff scale that can be dispelled from target frame"] = "目標框架可驅散的效果縮放大小。"
L["Only if player can dispel them"] = "只有玩家可驅散時"
L["Highlight dispelled buffs only if player can dispel them"] = "只有玩家可驅散時才要顯著標示可驅散的效果。"
L["Limit the number of buffs/debuffs"] = "限制增益/減益的數量"
L["Limit the number of displayed buffs/debuffs on the Target and Focus frames."] = "限制在當前目標和專注目標框架上顯示的增益/減益效果數量。"
L["Show only my debuffs"] = "只顯示我的減益效果"
L["Show only my debuffs (which the player creates)"] = "只顯示我的減益效果 (由玩家所施放的)"
L["Max buffs count"] = "最多增益數量"
L["How many buffs you can see on target/focus frames"] = "在目標/專注目標框架最多能夠看到幾個增益效果。"
L["Max debuffs count"] = "最多減益數量"
L["How many debuffs you can see on target/focus frames"] = "在目標/專注目標框架最多能夠看到幾個減益效果。"
L["Class portraits (old style)"] = "職業頭像 (舊風格)"
L["Class portraits (new style)"] = "職業頭像 (新風格)"
L["Specialization icon"] = "專精圖示"
L["Replaces the unit-frame portrait with their class icon"] = "使用職業圖示取代單位框架的頭像。"
L["Hide frames out of combat"] = "非戰鬥中隱藏框架"
L["Hide frames out of combat (for example in resting)"] = "非戰鬥中隱藏框架 (例如休息時)。"
L["Only if HP equal to 100%"] = "只有血量等於 100% 時"
L["Hide frames out of combat only if HP equal to 100%"] = "只有血量等於 100% 時才要在非戰鬥中隱藏框架。"
L["Opacity of frames"] = "框架不透明度"
L["Opacity of frames when frames is hidden (in out of combat)"] = "框架隱藏時的不透明度 (非戰鬥中)。"

L["Texture"] = "材質"
L["Set the frames bar Texture"] = "設定框架條的材質。"
L["Bright frames border"] = "框架外框亮度"
L["You can set frames border bright/dark color. From bright to dark. 0 - dark, 100 - bright"] = "設定框架外框顯示較亮/或較暗的顏色， 0 - 暗，100 - 亮。"
L["Use a light texture"] = "使用亮色的材質"
L["Use a brighter texture (like Blizzard's default texture)"] = "使用較明亮的材質 (像是暴雪預設的材質)。"

L["Frames colors"] = "框架顏色"
L["In this section you can set the default colors for friendly, enemy and neutral frames"] = "設定友方、敵方和中立框架的預設顏色。"
L["Set default friendly healthbar color"] = "設定友方血條顏色"
L["You can set the default friendly healthbar color for frames"] = "設定友方框架預設的血條顏色。"
L["Set default enemy healthbar color"] = "設定敵方血條顏色"
L["You can set the default enemy healthbar color for frames"] = "設定敵方框架預設的血條顏色。"
L["Set default neutral healthbar color"] = "設定中立血條顏色"
L["You can set the default neutral healthbar color for frames"] = "設定中方框架預設的血條顏色。"
L["Reset color to default"] = "恢復成預設顏色"

L["Other"] = "其他"
L["In this section you can set the settings like 'show welcome message' etc"] = "這裡可以設定像是 '顯示歡迎訊息' 等。"
L["Show welcome message"] = "顯示歡迎訊息"
L["Show welcome message when addon is loaded"] = "插件載入時顯示歡迎訊息。"

L["Save positions of frames to current profile"] = "儲存框架目前位置到設定檔。"
L["Restore positions of frames from current profile"] = "還原目前設定檔中的框架位置。"
L["Saved"] = "已儲存"
L["Restored"] = "已還原"

L["Frame"] = "框架"
L["Select the frame you want to set the position"] = "選擇要設定位置的框架"
L["X"] = true
L["X coordinate"] = "水平坐標"
L["Y"] = true
L["Y coordinate"] = "垂直坐標"

L["Set the color of the frame name"] = "設定框架名稱顏色"

L["Player"] = "玩家"
L["In player options you can set scale player frame, healthbar text format, etc"] = "在玩家選項中可以設定玩家框架的縮放大小、血量條文字格式...等。"
L["Player name"] = "玩家名字"
L["Player name font family"] = "玩家名字字體"
L["Player name font size"] = "玩家名字大小"
L["Player name font style"] = "玩家名字樣式"
L["Player name color"] = "玩家名字顏色"
L["Show or hide some elements of frame"] = "顯示或隱藏框架的某些部分"
L["Show player name"] = "顯示玩家名字"
L["Show player name inside the frame"] = "名字在框架內側"
L["Player frame scale"] = "玩家框架縮放大小"
L["Scale of player unit frame"] = "玩家框架的縮放大小。"
L["Enable hit indicators"] = "啟用戰鬥文字"
L["Show or hide the damage/heal which you take on your unit frame"] = "在你的框架中顯示或隱藏你受到的傷害/治療。"
L["Player healthbar text format"] = "玩家血量條文字格式"
L["Set the player healthbar text format"] = "設定玩家血量條的文字格式。"
L["Player manabar text format"] = "玩家能量條文字格式"
L["Set the player manabar text format"] = "設定玩家能量條的文字格式。"
L["Show player specialbar"] = "顯示職業特殊能量條"
L["Show or hide the player specialbar, like Paladin's holy power, Priest's orbs, Monk's harmony or Warlock's soul shards"] = "顯示或隱藏玩家的職業特殊能量條，像是聖騎士的聖能、牧師的球、武僧的氣或術士的靈魂裂片。"
L["Allow Easy Frames to fix the position of the specialbar frame"] = "修正職業特殊能量條的位置"
L["If the setting is enabled, Easy Frames will change the position of the specialbar and set it closer to the PlayerFrame. " ..
    "Otherwise, the position can be changed by other addons and Easy Frames will not block its change.\n\n"..
    "When you change this option you need to reload your UI. \n\nCommand /reload"] = "啟用時，暴雪頭像 (美化調整) 將會更改職業特殊能量條的位置，將其設置得更靠近 玩家框架。否則，可以由其他插件更改位置，暴雪頭像 (美化調整) 不會阻止其更改。\n\n更改此選項時，需要重新載入介面。\n\n指令 /reload"
L["Show player resting icon"] = "顯示玩家休息圖示"
L["Show or hide player resting icon when player is resting (e.g. in the tavern or in the capital)"] = "顯示或隱藏玩家休息時的圖示 (例如在旅店或主城中時)。"
L["Show player status texture (inside the frame)"] = "顯示玩家狀態材質 (框架內側)"
L["Show or hide player status texture (blinking glow inside the frame when player is resting or in combat)"] = "顯示或隱藏玩家的狀態材質 (當玩家正在休息或戰鬥時框架會閃爍發光)。"
L["Show player combat texture (outside the frame)"] = "顯示玩家戰鬥材質 (框架外側)"
L["Show or hide player red background texture (blinking red glow outside the frame in combat)"] = "顯示或隱藏玩家的紅色背景材質 (戰鬥時框架外側會閃紅光)。"
L["Show player group number"] = "顯示玩家隊伍編號"
L["Show or hide player group number when player is in a raid group (over portrait)"] = "當玩家在團隊中時，顯示或隱藏玩家的小隊編號 (在頭像上)。"
L["Show player role icon"] = "顯示玩家角色圖示"
L["Show or hide player role icon when player is in a group"] = "當玩家在隊伍中時，顯示或隱藏玩家擔任的角色圖示。"
L["Show player PVP icon"] = "顯示玩家 PVP 圖示"
L["Show or hide player PVP icon"] = "顯示或隱藏玩家的 PVP 圖示"


L["Target"] = "目標"
L["In target options you can set scale target frame, healthbar text format, etc"] = "在目標選項中可以設定目標框架的縮放大小、血量條文字格式...等。"
L["Target name"] = "目標名字"
L["Target name font family"] = "目標名字字體"
L["Target name font size"] = "目標名字大小"
L["Target name font style"] = "目標名字樣式"
L["Target name color"] = "目標名字顏色"
L["Target frame scale"] = "目標框架縮放大小"
L["Scale of target unit frame"] = "目標框架的縮放大小。"
L["Target healthbar text format"] = "目標血量條文字格式"
L["Set the target healthbar text format"] = "設定目標血量條的文字格式。"
L["Target manabar text format"] = "目標能量條文字格式"
L["Set the target manabar text format"] = "設定目標能量條的文字格式。"
L["Show target name"] = "顯示目標名字"
L["Show target name inside the frame"] = "名字在框架內側"
L["Show target of target frame"] = "顯示目標的目標框架"
L["Show target combat texture (outside the frame)"] = "顯示目標戰鬥材質 (框架外側)"
L["Show or hide target red background texture (blinking red glow outside the frame in combat)"] = "顯示或隱藏目標的紅色背景材質 (戰鬥時框架外側會閃紅光)。"
L["Show blizzard's target castbar"] = "顯示暴雪的目標施法條"
L["When you change this option you need to reload your UI (because it's Blizzard config variable). \n\nCommand /reload"] = "更改這個選項需要重新載入介面 (因為這是暴雪的遊戲參數)。\n\n輸入指令 /reload"
L["Show target PVP icon"] = "顯示目標 PVP 圖示"
L["Show or hide target PVP icon"] = "顯示或隱藏目標的 PVP 圖示"


L["Focus"] = "專注目標"
L["In focus options you can set scale focus frame, healthbar text format, etc"] = "在專注目標選項中可以設定專注目標框架的縮放大小、血量條文字格式...等。"
L["Focus name"] = "專注目標名字"
L["Focus name font family"] = "專注目標名字字體"
L["Focus name font size"] = "專注目標名字大小"
L["Focus name font style"] = "專注目標名字樣式"
L["Focus name color"] = "專注目標名字顏色"
L["Focus frame scale"] = "專注目標框架縮放大小"
L["Scale of focus unit frame"] = "專注目標框架的縮放大小。"
L["Focus healthbar text format"] = "專注目標血量條文字格式"
L["Set the focus healthbar text format"] = "設定專注目標血量條的文字格式。"
L["Focus manabar text format"] = "專注目標能量條文字格式"
L["Set the focus manabar text format"] = "設定專注目標能量條的文字格式。"
L["Show target of focus frame"] = "顯示專注目標的目標框架"
L["Show name of focus frame"] = "顯示專注目標名字"
L["Show name of focus frame inside the frame"] = "名字在框架內側"
L["Show focus combat texture (outside the frame)"] = "顯示專注目標戰鬥材質 (框架外側)"
L["Show or hide focus red background texture (blinking red glow outside the frame in combat)"] = "顯示或隱藏專注目標的紅色背景材質 (戰鬥時框架外側會閃紅光)。"
L["Show focus PVP icon"] = "顯示專注目標 PVP 圖示"
L["Show or hide focus PVP icon"] = "顯示或隱藏專注目標的 PVP 圖示"

L["Pet"] = "寵物"
L["In pet options you can set scale pet frame, show/hide pet name, enable/disable pet hit indicators, etc"] = "在寵物選項中可以設定寵物框架的縮放大小、血量條文字格式...等。"
L["Pet name"] = "寵物名字"
L["Pet name font family"] = "寵物名字字體"
L["Pet name font size"] = "寵物名字大小"
L["Pet name font style"] = "寵物名字樣式"
L["Pet name color"] = "寵物名字顏色"
L["Pet frame scale"] = "寵物框架縮放大小"
L["Scale of pet unit frame"] = "寵物框架的縮放大小。"
L["Lock pet frame"] = "鎖定寵物框架"
L["Lock or unlock pet frame"] = "鎖定或解鎖寵物框架，解鎖時可以使用滑鼠來移動框架 (可以拖曳)。" ..
    "但是寵物框架是受保護的框架，無法在戰鬥中調整位置，也只有在非戰鬥中才能恢復框架位置。"
L["Reset position to default"] = "恢復成預設位置"
L["Pet healthbar text format"] = "寵物血量條文字格式"
L["Set the pet healthbar text format"] = "設定寵物血量條的文字格式。"
L["Pet manabar text format"] = "寵物能量條文字格式"
L["Set the pet manabar text format"] = "設定寵物能量條的文字格式。"
L["Show pet name"] = "顯示寵物名字"
L["Show or hide the damage/heal which your pet take on pet unit frame"] = "在寵物框架中顯示或隱藏寵物受到的傷害/治療。"
L["Show pet combat texture (inside the frame)"] = "顯示寵物戰鬥材質 (框架內側)"
L["Show or hide pet red background texture (blinking red glow inside the frame in combat)"] = "顯示或隱藏寵物的紅色背景材質 (戰鬥時框架內側會閃紅光)。"
L["Show pet combat texture (outside the frame)"] = "顯示寵物戰鬥材質 (框架外側)"
L["Show or hide pet red background texture (blinking red glow outside the frame in combat)"] = "顯示或隱藏寵物的紅色背景材質 (戰鬥時框架外側會閃紅光)。"


L["Party"] = "隊伍"
L["In party options you can set scale party frames, healthbar text format, etc"] = "在隊伍選項中可以設定隊伍框架的縮放大小、血量條文字格式...等。"
L["Set the portrait of party frames"] = "設定隊伍的頭像"
L["Party frames scale"] = "隊伍框架縮放大小"
L["Scale of party unit frames"] = "隊伍框架的縮放大小。"
L["Party healthbar text format"] = "隊伍血量條文字格式"
L["Set the party healthbar text format"] = "設定隊伍血量條的文字格式。"
L["Party manabar text format"] = "隊伍能量條文字格式"
L["Set the party manabar text format"] = "設定隊伍能量條的文字格式。"
L["Party frames names"] = "隊伍框架名字"
L["Show names of party frames"] = "顯示隊伍框架名字"
L["Party names font family"] = "隊伍名字字體"
L["Party names font size"] = "隊伍名字大小"
L["Party names font style"] = "隊伍名字樣式"
L["Party names color"] = "隊伍名字顏色"
L["Show party pet frames"] = "顯示隊伍寵物框架"

L["Boss"] = "首領"
L["In boss options you can set scale boss frames, healthbar text format, etc"] = "在首領選項中可以設定首領框架的縮放大小、血量條文字格式...等。"
L["Boss frames scale"] = "首領框架縮放大小"
L["Set the offset of the Objective Tracker frame"] = "移動任務追蹤清單"
L["When the scale of the boss frame is greater than 0.75 (this is the default Blizzard UI scale), the boss frame will be 'covered' by the Objective Tracker frame (the frame with quests under the boss frame). " ..
    "This setting creates an offset based on the Boss frames scale settings. \n\n" ..
    "If you see strange behavior with the boss frame and Objective Tracker frame it is recommended to turn this setting off. \n\n" ..
    "When you change this option you need to reload your UI. \n\nCommand /reload"] = "當首領框架的縮放大小大於 0.75 (遊戲預設的介面縮放大小)，首領框架會和任務追蹤清單重疊 (任務清單會在首領框架底下)。這個設定會依據首領框架的縮放大小設定來移動位置。\n\n如果移動後任務追蹤清單或首領框架的功能變得很奇怪，請關閉這個設定。\n\n更改這個選項需要重新載入介面。\n\n輸入指令 /reload\n\n特別注意: 使用 \"任務追蹤清單增強\" 插件時請勿啟用這個選項，請改在 \"任務追蹤清單增強\" 插件的設定中調整任務清單的位置。"
L["Scale of boss unit frames"] = "首領框架的縮放大小。"
L["Boss healthbar text format"] = "首領血量條文字格式"
L["Set the boss healthbar text format"] = "設定首領血量條的文字格式。"
L["Boss manabar text format"] = "首領能量條文字格式"
L["Set the boss manabar text format"] = "設定首領能量條的文字格式。"
L["Boss frames names"] = "首領框架名字"
L["Show names of boss frames"] = "顯示首領框架名字"
L["Boss names font style"] = "首領名字樣式"
L["Boss names font family"] = "首領名字字體"
L["Boss names font size"] = "首領名字大小"
L["Boss names color"] = "首領名字顏色"
L["Show names of boss frames inside the frame"] = "名字在框架內側"
L["Show indicator of threat"] = "顯示仇恨值指示"

-- 自行加入
L["Profiles"] = "設定檔"
L["EasyFrames"] = "暴雪頭像 (美化調整)"
L["Easy Frames"] = "頭像"
L["Set the player's portrait"] = "設定玩家的頭像"
L["Set the target's portrait"] = "設定目標的頭像"
L["Set the focus's portrait"] = "設定專注目標的頭像"
L["Set the manabar texture by force"] = "強制設定能量條材質"
L["Use a force manabar texture setter. The Blizzard UI resets to default manabar texture each time an addon tries to modify it. With this option, the texture setter will set texture by force.\n\nIMPORTANT. When this option is enabled the addon will use a more CPU. More information in the issue #28"] = "每次插件要改能量條材質時，暴雪 UI 都會將它恢復成預設的材質。這個選項會用強制的方式來設定材質。\n\n重要提醒: 啟用這個選項時，插件會使用較多的 CPU。更多資訊請參考 issue #28"
L["[IN DEVELOPING. Temporarily disabled due to API bug. Coming soon]\n\n"] = "[開發中，因為 API bug 暫時停用此功能。Coming soon]\n\n"