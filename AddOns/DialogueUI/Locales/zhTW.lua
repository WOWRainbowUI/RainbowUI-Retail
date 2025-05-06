
if not (GetLocale() == "zhTW") then return end;


local _, addon = ...
local L = addon.L;


L["Renown Level Label"] = "名望 "


--DO NOT TRANSLATE
L["Abbrev Breakpoint 1000"] = "千";     --1,000 = 1K
L["Abbrev Breakpoint 10000"] = "萬";    --Reserved for Asian languages that have words for 10,000
L["Match Stat Armor"] = "([,%d%.]+)點護甲";
L["Match Stat Stamina"] = "([,%d%.]+)耐力";     --No Space!
L["Match Stat Strengh"] = "([,%d%.]+)力量";
L["Match Stat Agility"] = "([,%d%.]+)敏捷";
L["Match Stat Intellect"] = "([,%d%.]+)智力";
L["Match Stat Spirit"] = "([,%d%.]+)精神";
L["Match Stat DPS"] = "每秒傷害([,%d%.]+)";


L["Quest Frequency Daily"] = DAILY or "每日";
L["Quest Frequency Weekly"] = WEEKLY or "每週";

L["Quest Type Repeatable"] = "可重覆";
L["Quest Type Trivial"] = "低等級";    --Low-level quest
L["Quest Type Dungeon"] = LFG_TYPE_DUNGEON or "地城";
L["Quest Type Raid"] = LFG_TYPE_RAID or "團隊";
L["Quest Type Covenant Calling"] = "誓盟使命";

L["Accept"] = ACCEPT or "接受";
L["Continue"] = CONTINUE or "繼續";
L["Complete Quest"] = COMPLETE or "完成";   --Complete (Verb)  We no longer use COMPLETE_QUEST because the it's too long in some languages
L["Incomplete"] = INCOMPLETE or "未完成";
L["Cancel"] = CANCEL or "取消";
L["Goodbye"] = GOODBYE or "再見";
L["Decline"] = DECLINE or "拒絕";
L["OK"] = "OK";
L["Quest Objectives"] = OBJECTIVES_LABEL or "目標";   --We use the shorter one, not QUEST_OBJECTIVES
L["Reward"] = REWARD or "獎勵";
L["Rewards"] = REWARDS or "獎勵";
L["War Mode Bonus"] = WAR_MODE_BONUS or "戰爭模式加成";
L["Honor Points"] = HONOR_POINTS or "榮譽";
L["Symbol Gold"] = GOLD_AMOUNT_SYMBOL or "金";
L["Symbol Silver"] = SILVER_AMOUNT_SYMBOL or "銀";
L["Symbol Copper"] = COPPER_AMOUNT_SYMBOL or "銅";
L["Requirements"] = REQUIREMENTS or "需要";
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "目前:";
L["Renown Level Label"] = RENOWN_LEVEL_LABEL or "名望 ";  --There is a space
L["Abilities"] = ABILITIES or "能力";
L["Traits"] = GARRISON_RECRUIT_TRAITS or "特質";
L["Costs"] = "花費";   --The costs to continue an action, usually gold
L["Ready To Enter"] = QUEUED_STATUS_PROPOSAL or "可以進入";
L["Show Comparison"] = "顯示比較";   --Toggle item comparison on the tooltip
L["Hide Comparison"] = "隱藏比較";
L["Copy Text"] = "複製文字";
L["To Next Level Label"] = COVENANT_MISSIONS_XP_TO_LEVEL or "到下個等級";
L["Quest Accepted"] = "已接取任務";
L["Quest Log Full"] = "任務日誌已滿";
L["Quest Auto Accepted Tooltip"] = "遊戲會自動接取這個任務。";
L["Level Maxed"] = "(最大)";   --Reached max level
L["Paragon Reputation"] = "巔峰";
L["Different Item Types Alert"] = "物品類型不同!";
L["Click To Read"] = "點一下左鍵唸出";
L["Item Level"] = STAT_AVERAGE_ITEM_LEVEL or "物品等級";
L["Gossip Quest Option Prepend"] = "(任務)";   --Some gossip options start with blue (Quest), we prioritize them when sorting. See GOSSIP_QUEST_OPTION_PREPEND
L["TTS Button Tooltip"] = "左鍵: 開始/停止唸出內容\n右鍵: 開啟/關閉自動播放。";
L["Item Is An Upgrade"] = "這件裝備對你有提升";
L["Identical Stats"] = "這兩件裝備的屬性相同";   --Two items provide the same stats
L["Quest Completed On Account"] = (ACCOUNT_COMPLETED_QUEST_NOTICE or "你的戰隊已經完成此任務。");
L["New Quest Available"] = "有新任務";
L["Campaign Quest"] = TRACKER_HEADER_CAMPAIGN_QUESTS or "戰役";
L["Click To Open BtWQuests"] = "點一下在任務指南插件查看此任務。";
L["Story Progress"] = STORY_PROGRESS or "故事進度";
L["Quest Complete Alert"] = QUEST_WATCH_POPUP_QUEST_COMPLETE or "任務完成!";
L["Item Equipped"] = "已裝備";
L["Collection Collected"] = COLLECTED or "已收集";

--String Format
L["Format Reputation Reward Tooltip"] = QUEST_REPUTATION_REWARD_TOOLTIP or "獎勵 %d 聲望和 %s";
L["Format You Have X"] = "- 你有 |cffffffff%s|r 個";
L["Format You Have X And Y In Bank"] = "- 你有 |cffffffff%s|r 個 (|cffffffff%s|r 個在銀行)";
L["Format Suggested Players"] = QUEST_SUGGESTED_GROUP_NUM or "建議玩家數 [%d]";
L["Format Current Skill Level"] = "目前等級: |cffffffff%d/%d|r";
L["Format Reward Title"] = HONOR_REWARD_TITLE or "頭銜: %s";
L["Format Follower Level Class"] = FRIENDS_LEVEL_TEMPLATE or "等級 %d %s";
L["Format Monster Say"] = CHAT_MONSTER_SAY_GET or "%s 說: ";
L["Format Quest Accepted"] = ERR_QUEST_ACCEPTED_S or "已接取任務: %s";
L["Format Quest Completed"] = ERR_QUEST_COMPLETE_S or "%s 已完成。";
L["Format Player XP"] = PET_BATTLE_CURRENT_XP_FORMAT_BOTH or  "經驗值: %d/%d (%d%%)";
L["Format Gold Amount"] = GOLD_AMOUNT or "%d 金";
L["Format Silver Amount"] = SILVER_AMOUNT or "%d 銀";
L["Format Copper Amount"] = COPPER_AMOUNT or "%d 銅";
L["Format Unit Level"] = UNIT_LEVEL_TEMPLATE or "等級 %d";
L["Format Replace Item"] = "取代 %s";
L["Format Item Level"] = "物品等級 %d";   --_G.ITEM_LEVEL in Classic is different
L["Format Breadcrumb Quests Available"] = "可接的系列任務: %s";    --This type of quest guide the player to a new quest zone. See "Breadcrumb" on https://warcraft.wiki.gg/wiki/Quest#Quest_variations
L["Format Functionality Handled By"] = "此功能由 %s 提供";      --A functionality is provided by [another addon name] (Used in Settings.lua)

L["Format Time Left"] = BONUS_OBJECTIVE_TIME_LEFT or "剩餘時間: %s";
L["Format Your Progress"] = "你的進度: |cffffffff%d/%d|r";
L["Format And More"] = LFG_LIST_AND_MORE or "還有 %d 個...";
L["Format Chapter Progress"] = STORY_CHAPTERS or "%d/%d 章節";
L["Format Quest Progress"] = "%d/%d 任務";

--Settings
L["UI"] = "介面";
L["Camera"] = "鏡頭";
L["Control"] = "控制";
L["Gameplay"] = SETTING_GROUP_GAMEPLAY or "遊戲體驗";
L["Accessibility"] = SETTING_GROUP_ACCESSIBILITY or "協助工具";

L["Option Enabled"] = VIDEO_OPTIONS_ENABLED or "啟用";
L["Option Disabled"] = VIDEO_OPTIONS_DISABLED or "停用";
L["Move Position"] = "移動";
L["Reset Position"] = RESET_POSITION or "重置位置";
L["Drag To Move"] = "左鍵拖曳移動視窗。";
L["Middle Click To Reset Position"] = "中鍵重置位置";

L["Quest"] = "任務";
L["Gossip"] = "閒聊";
L["Theme"] = "主題";
L["Theme Desc"] = "選擇介面的顏色主題。";
L["Theme Brown"] = "羊皮紙";
L["Theme Dark"] = "暗黑";
L["Frame Size"] = "框架大小";
L["Frame Size Desc"] = "設定對話介面的大小。\n\n預設: 中";
L["Size Extra Small"] = "特別小";
L["Size Small"] = "小";
L["Size Medium"] = "中";
L["Size Large"] = "大";
L["Font Size"] = "文字大小";
L["Font Size Desc"] = "設定介面的文字大小。\n\n預設: 12";
L["Font"] = "字體";
L["Font Desc"] = "設定介面的字體。";
L["Font Tooltip Normal"] = "當前字體: ";
L["Font Tooltip Missing"] = "找不到選擇的字體，現在改用預設字體。";
L["Default"] = "預設";
L["Default Font"] = "預設字體";
L["System Font"] = "系統字體";
L["Frame Orientation"] = "位置";
L["Frame Orientation Desc"] = "將羊皮紙放在畫面的左側或右側。";
L["Orientation Left"] = "左";
L["Orientation Right"] = "右";
L["Hide UI"] = "隱藏介面";
L["Hide UI Desc"] = "和 NPC 互動時淡出遊戲介面。";
L["Show Chat Window"] = "NPC 聊天視窗";
L["Show Chat Window Left Desc"] = "在畫面左下方顯示 NPC 聊天視窗。";
L["Show Chat Window Right Desc"] = "在畫面右下方顯示 NPC 聊天視窗。";
L["Hide Unit Names"] = "隱藏單位名字";
L["Hide Unit Names Desc"] = "和 NPC 互動時隱藏玩家和其他 NPC 的名字。";
L["Hide Sparkles"] = "隱藏外框發光";
L["Hide Sparkles Desc"] = "停用任務 NPC 外框發光的效果。\n\n介面被隱藏時，魔獸會自動幫任務 NPC 的模組加上發光效果。";
L["Show Copy Text Button"] = "顯示複製文字按鈕";
L["Show Copy Text Button Desc"] = "在對話介面的右上方顯示複製文字按鈕。\n\n也會包含遊戲資料，像是任務、NPC、物品ID。";
L["Show Quest Type Text"] = "顯示任務類型文字";
L["Show Quest Type Text Desc"] = "如果任務類型特殊，則在選項右側顯示任務類型。\n\n低等級任務永遠都會顯示。";
L["Show NPC Name On Page"] = "顯示 NPC 名字";
L["Show NPC Name On Page Desc"] = "在頁面中顯示 NPC 名字。";
L["Simplify Currency Rewards"] = "簡化貨幣獎勵";
L["Simplify Currency Rewards Desc"] = "貨幣獎勵顯示為小圖示並省略名稱。";
L["Mark Highest Sell Price"] = "標示售價最高的";
L["Mark Highest Sell Price Desc"] = "選擇獎勵時，顯示哪件商品的售價最高。";
L["Use Blizzard Tooltip"] = "使用暴雪浮動提示資訊";
L["Use Blizzard Tooltip Desc"] = "任務獎勵按鈕使用遊戲內建的浮動提示資訊，而不是我們的特殊浮動提示資訊。";
L["Roleplaying"] = GDAPI_REALMTYPE_RP or "角色扮演";
L["Use RP Name In Dialogues"] = "對話視窗使用 RP 名字";
L["Use RP Name In Dialogues Desc"] = "將對話視窗文字中，你的角色名字換成你的 RP 名字。";

L["Camera Movement"] = "鏡頭移動";
L["Camera Movement Off"] = "關閉";
L["Camera Movement Zoom In"] = "拉近";
L["Camera Movement Horizontal"] = "水平";
L["Maintain Camera Position"] = "保持鏡頭位置";
L["Maintain Camera Position Desc"] = "NPC 互動結束後短暫保持鏡頭位置。 \n\n啟用此選項將減少因對話之間的延遲而導致的鏡頭突然移動。";
L["Change FOV"] = "更改視角";
L["Change FOV Desc"] = "縮小鏡頭的可見範圍，靠近並放大 NPC。";
L["Disable Camera Movement Instance"] = "在副本中時停用";
L["Disable Camera Movement Instance Desc"] = "在地城和團隊中不要移動鏡頭。";
L["Maintain Offset While Mounted"] = "騎乘時保持位置";
L["Maintain Offset While Mounted Desc"] = "騎乘坐騎時，嘗試保持角色在畫面上的位置。\n\n啟用此選項可能會對大型坐騎的水平偏移進行過度補償。";
L["Camera Zoom Multiplier"] = "變焦倍數";
L["Camera Zoom Multiplier Desc"] = "數值越小，相機距離目標越近。\n\n距離也受到目標大小的影響。";

L["Input Device"] = "輸入裝置";
L["Input Device Desc"] = "會影響快速鍵圖示和介面的版面配置。";
L["Input Device KBM"] = "鍵盤和滑鼠";
L["Input Device Xbox"] = "Xbox";
L["Input Device Xbox Tooltip"] = "確認按鈕: [KEY:XBOX:PAD1]\n取消按鈕: [KEY:XBOX:PAD2]";
L["Input Device PlayStation"] = "PlayStation";
L["Input Device PlayStation Tooltip"] = "確認按鈕: [KEY:PS:PAD1]\n取消按鈕: [KEY:PS:PAD2]";
L["Input Device Switch"] = "Switch";
L["Input Device Switch Tooltip"] = "確認按鈕: [KEY:SWITCH:PAD1]\n取消按鈕: [KEY:SWITCH:PAD2]";
L["Use Custom Bindings"] = "使用自訂按鈕綁定";
L["Use Custom Bindings Desc"] = "啟用此選項來使用你自己的按鈕綁定。";
L["Primary Control Key"] = "確認按鈕";
L["Primary Control Key Desc"] = "按此鍵來選擇第一個可用選項，例如「接受任務」。"
L["Press Button To Scroll Down"] = "按下按鈕往下捲頁";
L["Press Button To Scroll Down Desc"] = "如果內容超出可以看見的範圍，按下確認按鈕將向下捲動頁面而不是接受任務。";
L["Right Click To Close UI"] = "點右鍵關閉介面";
L["Right Click To Close UI Desc"] = "在任務對話的介面上點右鍵將它關閉。";
L["Press Tab To Select Reward"] = "按 Tab 鍵選擇獎勵";
L["Press Tab To Select Reward Desc"] = "交回任務時，按 [KEY:PC:TAB] 循環切換可選擇的獎勵。";
L["Disable Hokey For Teleport"] = "傳送時停用快速鍵";
L["Disable Hokey For Teleport Desc"] = "當你選擇傳送目的地的時候停用快速鍵。";
L["Experimental Features"] = "實驗性";
L["Emulate Swipe"] = "模擬滑動手勢";
L["Emulate Swipe Desc"] = "拖曳視窗內容來上下捲動。";
L["Mobile Device Mode"] = "行動裝置模式";
L["Mobile Device Mode Desc"] = "實驗性功能:\n\n加大介面和文字大小，讓小螢幕裝置更容易閱讀。";
L["Mobile Device Mode Override Option"] = "此選項目前沒有效果，因為在控制設定中啟用了 \"行動裝置模式\"。";
L["GamePad Click First Object"] = "選擇第一個對話選項";
L["GamePad Click First Object Desc"] = "開始與 NPC 進行新的互動時，按確認按鈕會選擇第一個對話選項。";

L["Key Space"] = "空白";
L["Key Interact"] = "互動";
L["Cannot Use Key Combination"] = "不支援按鈕組合";
L["Interact Key Not Set"] = "[KEY:PC:INVALID] 尚未設定互動按鍵。"
L["Use Default Control Key Alert"] = "將會使用 [KEY:PC:SPACE] 作為確認按鈕。";
L["Key Disabled"] = "已停用";
L["Key Disabled Tooltip"] = "確認按鈕已被停用。\n\n你將無法使用按鍵來接受任務。";

L["Auto Quest Popup"] = "自動彈出任務";
L["Auto Quest Popup Desc"] = "如果新任務是拾取物品或進入區域時自動觸發的，便先顯示彈出通知，而不是直接顯示任務的詳細內容。\n\n不適用登入時彈出的任務。";
L["Popup Position"] = "彈出通知位置";    --Pop-up window position
L["Widget Is Docked Generic"] = "這個小套件會和其他彈出視窗排列在一起。";   --Indicate a window is docked with other pop-up windows
L["Widget Is Docked Named"] = "%s 會和其他彈出視窗排列在一起。";
L["Quest Item Display"] = "顯示任務物品";
L["Quest Item Display Desc"] = "自動顯示任務物品的說明，無需打開袋子即可使用它。";
L["Quest Item Display Hide Seen"] = "忽略已看見的物品";
L["Quest Item Display Hide Seen Desc"] = "忽略你的任何角色已發現過的物品。";
L["Quest Item Display Await World Map"] = " 等待世界地圖";
L["Quest Item Display Await World Map Desc"] = "打開世界地圖時，會暫時隱藏任務物品，並且暫停自動關閉。";
L["Quest Item Display Reset Position Desc"] = "重置視窗的位置。";
L["Valuable Reward Popup"] = "有價值的獎勵彈出通知";
L["Valuable Reward Popup Desc"] = "當你收到升級、寶箱或未收集的造型等有價值的物品時，請顯示一個按鈕，讓你可以直接使用它。";
L["Auto Complete Quest"] = "自動完成任務";
L["Auto Complete Quest Desc"] = "自動完成以下任務，然後在獨立的視窗中顯示對話和獎勵。如果獎勵包含箱子，你可以點擊打開它。\n\n- 糖果桶 (萬鬼節)\n- 卡茲阿爾加週任";
L["Press Key To Use Item"] = "按下按鈕來使用";
L["Press Key To Use Item Desc PC"] = "非戰鬥中時按下 [KEY:PC:SPACE] 來使用物品。";
L["Press Key To Use Item Desc Xbox"] = "非戰鬥中時按下 [KEY:XBOX:PAD3] 來使用物品。";
L["Press Key To Use Item Desc PlayStation"] = "非戰鬥中時按下 [KEY:PS:PAD3] 來使用物品。";
L["Press Key To Use Item Desc Switch"] = "非戰鬥中時按下 [KEY:SWITCH:PAD3] 來使用物品。";
L["Auto Select"] = "自動選擇";
L["Auto Select Gossip"] = "自動選擇選項";
L["Auto Select Gossip Desc"] = "與特定 NPC 互動時自動選擇最佳的對話選項。";
L["Force Gossip"] = "強制閒聊";
L["Force Gossip Desc"] = "預設情況下，遊戲有時會自動選擇第一個選項而不顯示對話框。 透過啟用強制閒聊，該對話框便會出現。";
L["Skip GameObject"] = "忽略遊戲物件";   --Sub-option of Force Gossip
L["Skip GameObject Desc"] = "不顯示遊戲物件 (例如專業工作台) 的隱藏對話。";
L["Show Hint"] = "顯示提示";
L["Show Hint Desc"] = "加入可以選擇正確答案的按鈕 (如果有正確答案的話)。\n\n目前只支援時光漫遊的謎題。";
L["Nameplate Dialog"] = "在名條上顯示對話";
L["Nameplate Dialog Desc"] = "如果 NPC 沒有提供選擇，則在 NPC 名條上顯示對話。\n\n此選項會修改 CVar \"SoftTarget Nameplate Interact\"。";
L["Compatibility"] = "相容性";
L["Disable DUI In Instance"] = "副本中使用魔獸預設介面。";
L["Disable DUI In Instance Desc"] = "在副本或團隊中停用任務對話插件，改用遊戲內建介面。";

L["Disable UI Motions"] = "減少介面移動";
L["Disable UI Motions Desc"] = "減少介面移動，例如展開介面或輕推按鈕文字。";

L["TTS"] = TEXT_TO_SPEECH or "文字轉語音";
L["TTS Desc"] = "點一下介面左上方的按鈕將對話內容文字大聲唸出來。";
L["TTS Use Hotkey"] = "使用快速鍵";
L["TTS Use Hotkey Desc"] = "開始和停止唸出內容請按下:";
L["TTS Use Hotkey Tooltip PC"] = "[KEY:PC:R]";
L["TTS Use Hotkey Tooltip Xbox"] = "[KEY:XBOX:LT]";
L["TTS Use Hotkey Tooltip PlayStation"] = "[KEY:PS:LT]";
L["TTS Auto Play"] = "自動唸出內容";
L["TTS Auto Play Desc"] = "自動唸出對話內容。";
L["TTS Skip Recent"] = "忽略最近唸過的內容";
L["TTS Skip Recent Desc"] = "忽略最近唸過的內容文字。";
L["TTS Auto Play Delay"] = "延遲唸出";
L["TTS Auto Play Delay Desc"] = "自動唸出之前添加短暫的延遲，這樣就不會與 NPC 本身的語音重疊。";
L["TTS Auto Stop"] = "離開時停止";
L["TTS Auto Stop Desc"] = "離開 NPC 時停止唸出內容。";
L["TTS Stop On New"] = "開始新對話時停止";
L["TTS Stop On New Desc"] = "開始瀏覽另一個不同的對話時，停止唸出之前的內容。";
L["TTS Voice Male"] = "男聲";
L["TTS Voice Male Desc"] = "和男角互動時使用這個聲音:";
L["TTS Voice Female"] = "女聲";
L["TTS Voice Female Desc"] = "和女角互動時使用這個聲音:";
L["TTS Use Narrator"] = "旁白";
L["TTS Use Narrator Desc"] = "使用不同的聲音唸出 NPC 名字、任務標題、任務目標和其他用 <> 括起來的文字。";
L["TTS Voice Narrator"] = "語音";
L["TTS Voice Narrator Desc"] = "旁白使用這個語音:";
L["TTS Volume"] = VOLUME or "音量";
L["TTS Volume Desc"] = "調整說話音量。";
L["TTS Rate"] = "說話速度";
L["TTS Rate Desc"] = "調整說話速度。";
L["TTS Include Content"] = "包含內文";
L["TTS Content NPC Name"] = "NPC 名字";
L["TTS Content Quest Name"] = "任務標題";
L["TTS Content Objective"] = "任務目標";
L["TTS Button Read Original"] = "改為唸出原文";
L["TTS Button Read Translation"] = "改為唸出翻譯";

--Book UI and Settings
L["Readables"] = "可閱讀";   --Readable Objects
L["Readable Objects"] = "可閱讀的物件";     --Used as a label for a setting in Accessibility-TTS
L["BookUI Enable"] = "可閱讀的物件使用新介面";
L["BookUI Enable Desc"] = "像是書本、信件或便籤這些可閱讀的物件使用新的介面。";
L["BookUI Frame Size Desc"] = "設定書本介面的大小。";
L["BookUI Keep UI Open"] = "保持視窗開啟";
L["BookUI Keep UI Open Desc"] = "焦點移出物件時也要保持視窗開啟。\n\n按 Esc 鍵或在介面上點右鍵來關閉視窗。";
L["BookUI Show Location"] = "顯示位置";
L["BookUI Show Location Desc"] = "在標題列顯示物件的位置。\n\n只對遊戲物件有效，背包中的物品沒有作用。";
L["BookUI Show Item Description"] = "顯示物品說明";
L["BookUI Show Item Description Desc"] = "如果物品的浮動提示資訊中有任何說明，在介面的最上方顯示出來。";
L["BookUI Darken Screen"] = "畫面調暗";
L["BookUI Darken Screen Desc"] = "將介面下方的區域變暗，以便能專注於內容。";
L["BookUI TTS Voice"] = "語音";
L["BookUI TTS Voice Desc"] = "可閱讀的物件使用這個語音:";
L["BookUI TTS Click To Read"] = "點一下段落唸出";
L["BookUI TTS Click To Read Desc"] = "點一下段落將它唸出來。\n\n點一下已經在唸的段落來停止唸出。";

--Keybinding Action
L["Bound To"] = "綁定到: ";
L["Hotkey Colon"] = "快速鍵: ";
L["Not Bound"] = NOT_BOUND or "沒有綁定";
L["Action Confirm"] = "確認";
L["Action Settings"] = "打開設定";
L["Action Option1"] = "選項 1";
L["Action Option2"] = "選項 2";
L["Action Option3"] = "選項 3";
L["Action Option4"] = "選項 4";
L["Action Option5"] = "選項 5";
L["Action Option6"] = "選項 6";
L["Action Option7"] = "選項 7";
L["Action Option8"] = "選項 8";
L["Action Option9"] = "選項 9";

--Tutorial
L["Tutorial Settings Hotkey"] = "按下 [KEY:PC:F1] 打開設定";
L["Tutorial Settings Hotkey Console"] = "按下 [KEY:PC:F1] 或 [KEY:CONSOLE:MENU] 打開設定";   --Use this if gamepad enabled
L["Instruction Open Settings"] = "當任務對話視窗顯示時，按下 [KEY:PC:F1] 可以打開設定。";    --Used in Game Menu - AddOns
L["Instruction Open Settings Console"] = "當任務對話視窗顯示時，按下 [KEY:PC:F1] 或 [KEY:CONSOLE:MENU] 可以打開設定。";
L["Instruction Open Settings Keybind Format"] = "當任務對話視窗顯示時，按下 [%s] 可以打開設定。";
L["Instruction Open Settings No Keybind"] = "還沒有設定打開設定的按鍵綁定。";
L["HelpTip Warband Completed Quest"] = "此圖示代表任務已經由戰隊完成了。";
L["Got It"] = HELP_TIP_BUTTON_GOT_IT or "知道了";
L["Open Settings"] = "打開設定";

--AddOn Compatibility for Language Translator
L["Translator"] = "翻譯";
L["Translator Source"] = "原始: ";
L["Translator No Quest Data Format"] = "沒有找到項目 [任務: %s]";
L["Translator Click To Hide Translation"] = "點一下隱藏翻譯";
L["Translator Click To Show Translation"] = "點一下顯示翻譯";

L["Show Answer"] = "顯示正確答案。";
L["Quest Failed Pattern"] = "才能完成此任務。$";
L["AutoCompleteQuest HallowsEnd"] = "糖果桶";     --Quest:28981

--Asking for Directions-- (match the name to replace gossip icon)
L["Pin Auction House"] = "拍賣場";
L["Pin Bank"] = "銀行";
L["Pin Barber"] = "美容師";
L["Pin Battle Pet Trainer"] = "戰寵訓練師";
L["Pin Crafting Orders"] = "製作訂單";
L["Pin Flight Master"] = "飛行管理員";
L["Pin Great Vault"] = "寶庫";
L["Pin Inn"] = "旅店";
L["Pin Item Upgrades"] = "物品升級";
L["Pin Mailbox"] = "郵箱";
L["Pin Other Continents"] = "其他大陸";
L["Pin POI"] = "地標";
L["Pin Profession Trainer"] = "專業技能訓練師";
L["Pin Rostrum"] = "外形調整台";
L["Pin Stable Master"] = "獸欄管理員";
L["Pin Trading Post"] = "貿易站";

-- 自行加入
L["Dialogue UI"] = "任務-對話"
