local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "zhTW", false, false);
if not L then return end

L['Modules'] = "功能模組";
L['Left-Click'] = "左鍵";
L['Right-Click'] = "右鍵";
L['k'] = "千"; -- short for 1000
L['M'] = "百萬"; -- short for 1000000
L['B'] = "十億"; -- short for 1000000000
L['L'] = "本地"; -- For the local ping
L['W'] = "世界"; -- For the world ping
L['w'] = "萬";	-- short for 10000, used in zhCN and zhTW
L['e'] = "億"; -- short for 100000000
L['c'] = "兆"; -- short for 1000000000000

-- General
L["Positioning"] = "位置";
L['Bar Position'] = "資訊列位置";
L['Top'] = "上";
L['Bottom'] = "下";
L['Bar Color'] = "資訊列顏色";
L['Use Class Color for Bar'] = "使用職業顏色";
L["Miscellaneous"] = "其他";
L['Hide Bar in combat'] = "戰鬥中隱藏";
L["Hide when in flight"] = true;
L['Bar Padding'] = "資訊列內距";
L['Module Spacing'] = "模組間距";
L['Bar Margin'] = "資訊列間距";
L["Leftmost and rightmost margin of the bar modules"] = "資訊列模組最左邊和最右邊的間距";
L['Hide order hall bar'] = "隱藏職業大廳列";
L['Use ElvUI for tooltips'] = "使用ElvUI浮動提示";
L["Lock Bar"] = "鎖定資訊列";
L["Lock the bar in place"] = "鎖定在此位置";
L["Lock the bar to prevent dragging"] = "鎖定避免拖動";
L["Makes the bar span the entire screen width"] = "讓資訊列橫跨整個畫面";
L["Position the bar at the top or bottom of the screen"] = "將資訊列顯示在畫面的最上方或最下方";
L["X Offset"] = "水平位移";
L["Y Offset"] = "垂直位移";
L["Horizontal position of the bar"] = "資訊列的水平位置";
L["Vertical position of the bar"] = "資訊列的垂直位置";
L["Behavior"] = "行為";
L["Spacing"] = "間距";

-- Positioning Options
L['Positioning Options'] = "位置選項";
L['Horizontal Position'] = "水平位置";
L['Bar Width'] = "資訊列寬度";
L['Left'] = "左";
L['Center'] = "中";
L['Right'] = "右";

-- Media
L['Font'] = "字體";
L['Small Font Size'] = "小字體大小";
L['Text Style'] = "文字樣式";

-- Text Colors
L["Colors"] = "顏色";
L['Text Colors'] = "文字顏色";
L['Normal'] = "平時";
L['Inactive'] = "未使用時";
L["Use Class Color for Text"] = "使用職業顏色";
L["Only the alpha can be set with the color picker"] = "顏色選擇器中只能設定透明度";
L['Use Class Colors for Hover'] = "使用職業顏色";
L['Hover'] = "滑鼠指向時";

-------------------- MODULES ---------------------------

L['Social'] = "好友";
L['Micromenu'] = "微型選單";
L['Show Social Tooltips'] = "顯示公會/好友名單";
L['Main Menu Icon Right Spacing'] = "主選單圖示右方間距";
L['Icon Spacing'] = "圖示間距";
L["Hide BNet App Friends"] = "隱藏戰網 app 好友";
L['Open Guild Page'] = "開啟公會視窗";
L['No Tag'] = "沒有 Tag";
L['Whisper BNet'] = "密語 Battle Tag";
L['Whisper Character'] = "密語伺服器角色";
L['Hide Social Text'] = "隱藏人數";
L['Social Text Offset'] = "人數文字位置偏移";
L["GMOTD in Tooltip"] = "顯示公會今日資訊";
L["Modifier for friend invite"] = "組隊邀請的組合鍵";
L['Show/Hide Buttons'] = "顯示/隱藏按鈕";
L['Show Menu Button'] = "顯示選單按鈕";
L['Show Chat Button'] = "顯示聊天按鈕";
L['Show Guild Button'] = "顯示公會按鈕";
L['Show Social Button'] = "顯示好友按鈕";
L['Show Character Button'] = "顯示角色按鈕";
L['Show Spellbook Button'] = "顯示法術書按鈕";
L['Show Talents Button'] = "顯示天賦按鈕";
L['Show Achievements Button'] = "顯示成就按鈕";
L['Show Quests Button'] = "顯示任務按鈕";
L['Show LFG Button'] = "顯示隊伍搜尋器按鈕";
L['Show Journal Button'] = "顯示冒險指南按鈕";
L['Show PVP Button'] = "顯示 PVP 按鈕";
L['Show Pets Button'] = "顯示收藏按鈕";
L['Show Shop Button'] = "顯示遊戲商城按鈕";
L['Show Help Button'] = "顯示客服支援按鈕";
L['No Info'] = "沒有資訊";
L['Classic'] = "經典版";
L['Alliance'] = "聯盟";
L['Horde'] = "部落";

L['Durability Warning Threshold'] = "裝備耐久度警告門檻";
L['Show Item Level'] = "顯示物品等級";
L['Show Coordinates'] = "顯示座標";

L['Master Volume'] = "主音量";
L["Volume step"] = "每點一下調整的值";

L['Time Format'] = "時間格式";
L['Use Server Time'] = "使用伺服器時間";
L['New Event!'] = "新活動!";
L['Local Time'] = "本地時間";
L['Realm Time'] = "伺服器時間";
L['Open Calendar'] = "開啟行事曆";
L['Open Clock'] = "開啟時鐘";
L['Hide Event Text'] = "隱藏活動文字";

L['Travel'] = "旅行傳送";
L['Port Options'] = "傳送選項";
L['Ready'] = "完成";
L['Travel Cooldowns'] = "旅行傳送冷卻";
L['Change Port Option'] = "變更傳送選項";

L["Registered characters"] = "已記錄的角色";
L['Show Free Bag Space'] = "顯示背包剩餘空間";
L['Show Other Realms'] = "顯示其他伺服器";
L['Always Show Silver and Copper'] = "總是顯示銀和銅";
L['Shorten Gold'] = "金額縮寫";
L['Toggle Bags'] = "打開/關閉背包";
L['Session Total'] = "本次登入總計";

L['Show XP Bar Below Max Level'] = "未滿等時顯示經驗條";
L['Use Class Colors for XP Bar'] = "使用職業顏色";
L['Show Tooltips'] = "顯示浮動提示資訊";
L['Text on Right'] = "文字在右側";
L['Currency Select'] = "要顯示的兌換通貨";
L['First Currency'] = "第一種兌換通貨";
L['Second Currency'] = "第二種兌換通貨";
L['Third Currency'] = "第三種兌換通貨";
L['Rested'] = "休息加成";

L['Show World Ping'] = "顯示世界延遲";
L['Number of Addons To Show'] = "顯示的插件數目";
L['Addons to Show in Tooltip'] = "顯示插件數目";
L['Show All Addons in Tooltip with Shift'] = "按住 Shift 顯示全部";
L['Memory Usage'] = "記憶體使用量";
L['Garbage Collect'] = "清理記憶體";
L['Cleaned'] = "已清理";

L['Use Class Colors'] = "使用職業顏色";
L['Cooldowns'] = "冷卻時間";
L['Toggle Profession Frame'] = "打開/關閉專業視窗";
L['Toggle Profession Spellbook'] = "打開/關閉專業技能書";

L['Set Specialization'] = "切換專精";
L['Set Loadout'] = "切換天賦配置";
L['Set Loot Specialization'] = "切換優先拾取的專精";
L['Current Specialization'] = "目前職業專精";
L['Current Loot Specialization'] = "目前優先拾取的專精";
L['Enable Loadout Switcher'] = "啟用切換天賦配置";
L['Talent Minimum Width'] = "天賦最小寬度";
L['Open Artifact'] = "檢視神兵武器";
L['Remaining'] = "還需要";
L['Kills to level'] = "隻便會升級";
L['Last xp gain'] = "上次獲得經驗值";
L['Available Ranks'] = "神兵武器等級";
L['Artifact Knowledge'] = "神兵知識等級";

-- Travel
L['Hearthstone'] = "爐石";
L['Hearthstones'] = "爐石";
L['M+ Teleports'] = "M+ 傳送門";
L['Only show current season'] = "只顯示當前賽季";
L["Mythic+ Teleports"] = "M+ 傳送門";
L['Show Mythic+ Teleports'] = "顯示 M+ 傳送門";
L['Use Random Hearthstone'] = "使用隨機爐石";
L['Empty Hearthstones List'] = "如果下方的清單是空的，或是沒有完整顯示出你擁有的爐石，請等幾秒後再重新載入介面 (暴雪使用非同步的方式載入物品資訊，這是目前唯一的解決方法)。"
L['Hearthstones Select'] = "選擇爐石";
L['Hearthstones Select Desc'] = "選擇要使用哪個爐石 (如果選擇了多個爐石，請勾選 \"使用隨機爐石\" 選項)";

L["Classic"] = "經典時期";
L["Burning Crusade"] = "燃燒的遠征";
L["Wrath of the Lich King"] = "巫妖王之怒";
L["Cataclysm"] = "浩劫與重生";
L["Mists of Pandaria"] = "潘達利亞之謎";
L["Warlords of Draenor"] = "德拉諾之霸";
L["Legion"] = "軍臨天下";
L["Battle for Azeroth"] = "決戰艾澤拉斯";
L["Shadowlands"] = "暗影之境";
L["Dragonflight"] = "巨龍崛起";
L["The War Within"] = "地心之戰";
L["Current season"] = "當前賽季";

-- Additional
L["XIV Bar Continued"] = "資訊列";  -- used for config menu
L['Profiles'] = "設定檔";
L['Money'] = "金錢"
L['Enable in combat'] = "戰鬥中可使用"
L["Gold rounded values"] = "只顯示金的部分"
L['Daily Total'] = "本日總計"
L["All the characters listed above are currently registered in the gold database. To delete one or several character, please uncheck the box corresponding to the character(s) to delete.\nThe boxes will remain unchecked for the deleted character(s), until you reload or logout/login"] = "\n上方列出的是金錢資料庫中有記錄的所有角色。\n\n要刪除角色的記錄，請取消勾選角色前方的核取方塊。\n\n取消勾選的角色會暫時保存，直到重新載入介面或重新登出/登入遊戲後才會刪除。"
L["Overwatch"] = "鬥陣特攻"
L["Heroes of the Storm"] = "暴雪英霸"
L["Hearthstone "] = "爐石戰記"
L["Starcraft 2"] = "星海爭霸II"
L["Diablo 3"] = "暗黑破壞神III"
L['Starcraft Remastered'] = "星海爭霸 高畫質重製版"
L['Destiny 2'] = "天命 2"
L['Call of Duty: BO4'] = "決勝時刻: 黑色行動4"
L['Call of Duty: MW'] = "決勝時刻: 現代戰爭"
L['Call of Duty: MW2'] = "決勝時刻: 現代戰爭2"
L['Call of Duty: BOCW'] = "決勝時刻: 黑色行動冷戰"
L['Call of Duty: Vanguard'] = "決勝時刻: 先鋒"
L["Hide when in flight"] = "使用鳥點飛行時隱藏"
L["Classic"] = "《經典版》"
L['Warcraft 3 Reforged'] = "魔獸爭霸III: 淬鍊重生"
L['Diablo II: Resurrected'] = "暗黑破壞神II: 獄火重生"
L['Call of Duty: Vanguard'] = "決勝時刻: 先鋒"
L['Diablo Immortal'] = "暗黑破壞神 永生不朽"
L['Warcraft Arclight Rumble'] = "魔獸兵團"
L['Call of Duty: Modern Warfare II'] = "決勝時刻: 現代戰爭II 2022"
L["Diablo 4"] = "暗黑破壞神IV"
L["Blizzard Arcade Collection"] = "暴雪遊樂場典藏系列"
L["Crash Bandicoot 4"] = "袋狼大進擊4"
L["Hide Friends Playing Other Games"] = "隱藏其他遊戲好友"; -- used for the friend list function I added myself

-- Profile Import/Export
L["Profile Sharing"] = "分享設定檔";

L["Invalid import string"] = "無效的匯入字串";
L["Failed to decode import string"] = "無法解碼匯入字串";
L["Failed to decompress import string"] = "無法解壓縮匯入字串";
L["Failed to deserialize import string"] = "無法反序列化匯入字串";
L["Invalid profile format"] = "無效的設定檔格式";
L["Profile imported successfully as"] = "成功匯入設定檔為";

L["Copy the export string below:"] = "複製下方的匯出字串:";
L["Paste the import string below:"] = "在下方貼上匯入字串:";
L["Import or export your profiles to share them with other players."] = "匯入或匯出你的設定檔以便與其他玩家分享。";
L["Profile Import/Export"] = "匯入/匯出設定檔";
L["Export Profile"] = "匯出設定檔";
L["Export your current profile settings"] = "匯出當前設定檔中的設定";
L["Import Profile"] = "匯入設定檔";
L["Import a profile from another player"] = "匯入來自其他玩家的設定檔";

-- Changelog
L["%month%-%day%-%year%"] = "%year%年%month%月%day%日"
L["Version"] = "版本"
L["Important"] = "重要"
L["New"] = "新增"
L["Improvment"] = "改善"
L["Changelog"] = "更新記錄"