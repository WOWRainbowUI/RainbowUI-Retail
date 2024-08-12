
if not (GetLocale() == "zhTW") then return end;


local _, addon = ...
local L = addon.L;


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
L["Complete Quest"] = COMPLETE_QUEST or "完成任務";
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
L["Click To Read"] = "點一下左鍵來閱讀";
L["Item Level"] = STAT_AVERAGE_ITEM_LEVEL or "物品等級";
L["Gossip Quest Option Prepend"] = "(任務)";   --Some gossip options start with blue (Quest), we prioritize them when sorting. See GOSSIP_QUEST_OPTION_PREPEND
L["TTS Button Tooltip"] = "左鍵: 開始/停止唸出內容\n右鍵: 開啟/關閉自動播放";
L["Item Is An Upgrade"] = "這件裝備對你有提升";
L["Identical Stats"] = "這兩件裝備的屬性相同";   --Two items provide the same stats
L["Quest Completed On Account"] = (ACCOUNT_COMPLETED_QUEST_NOTICE or "你的戰隊已經完成此任務。");


--String Format
L["Format Reputation Reward Tooltip"] = QUEST_REPUTATION_REWARD_TOOLTIP or "獎勵 %d 聲望和 %s";
L["Format You Have X"] = "- 你有 |cffffffff%d|r 個";
L["Format You Have X And Y In Bank"] = "- 你有 |cffffffff%d|r 個 (|cffffffff%d|r 個在銀行)";
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
L["Frame Orientation"] = "位置";
L["Frame Orientation Desc"] = "將羊皮紙放在畫面的左側或右側。";
L["Orientation Left"] = "左";
L["Orientation Right"] = "右";
L["Hide UI"] = "隱藏介面";
L["Hide UI Desc"] = "和 NPC 互動時淡出遊戲介面。";
L["Hide Unit Names"] = "隱藏單位名字";
L["Hide Unit Names Desc"] = "和 NPC 互動時隱藏玩家和其他 NPC 的名字。";
L["Show Copy Text Button"] = "顯示複製文字按鈕";
L["Show Copy Text Button Desc"] = "在對話介面的右上方顯示複製文字按鈕。";
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

L["Input Device"] = "輸入裝置";
L["Input Device Desc"] = "會影響快速鍵圖示和介面的版面配置。";
L["Input Device KBM"] = "鍵盤和滑鼠";
L["Input Device Xbox"] = "Xbox";
L["Input Device Xbox Tooltip"] = "確認按鈕: [KEY:XBOX:PAD1]\n取消按鈕: [KEY:XBOX:PAD2]";
L["Input Device PlayStation"] = "PlayStation";
L["Input Device PlayStation Tooltip"] = "確認按鈕: [KEY:PS:PAD1]\n取消按鈕: [KEY:PS:PAD2]";
L["Primary Control Key"] = "確認按鈕";
L["Primary Control Key Desc"] = "按此鍵來選擇第一個可用選項，例如「接受任務」。"
L["Press Button To Scroll Down"] = "按下按鈕往下捲頁";
L["Press Button To Scroll Down Desc"] = "如果內容超出可以看見的範圍，按下確認按鈕將向下捲動頁面而不是接受任務。";
L["Right Click To Close UI"] = "點右鍵關閉介面";
L["Right Click To Close UI Desc"] = "在任務對話的介面上點右鍵將它關閉。";

L["Key Space"] = "空白";
L["Key Interact"] = "互動";
L["Cannot Use Key Combination"] = "不支援按鈕組合";
L["Interact Key Not Set"] = "[KEY:PC:INVALID] 尚未設定互動按鍵。"
L["Use Default Control Key Alert"] = "將會使用 [KEY:PC:SPACE] 作為確認按鈕。";
L["Key Disabled"] = "已停用";
L["Key Disabled Tooltip"] = "確認按鈕已被停用。\n\n你將無法使用按鍵來接受任務。";

L["Quest Item Display"] = "顯示任務物品";
L["Quest Item Display Desc"] = "自動顯示任務物品的說明，無需打開袋子即可使用它。";
L["Quest Item Display Hide Seen"] = "忽略已看見的物品";
L["Quest Item Display Hide Seen Desc"] = "忽略你的任何角色已發現過的物品。";
L["Quest Item Display Reset Position Desc"] = "重置視窗的位置。";
L["Auto Select"] = "自動選擇";
L["Auto Select Gossip"] = "自動選擇選項";
L["Auto Select Gossip Desc"] = "與特定 NPC 互動時自動選擇最佳的對話選項。";
L["Force Gossip"] = "強制閒聊";
L["Force Gossip Desc"] = "預設情況下，遊戲有時會自動選擇第一個選項而不顯示對話框。 透過啟用強制閒聊，該對話框便會出現。";
L["Nameplate Dialog"] = "在名條上顯示對話";
L["Nameplate Dialog Desc"] = "如果 NPC 沒有提供選擇，則在 NPC 名條上顯示對話。\n\n此選項會修改 CVar \"SoftTarget Nameplate Interact\"。";

L["TTS"] = TEXT_TO_SPEECH or "文字轉語音";
L["TTS Desc"] = "點一下介面左上方的按鈕將對話內容文字大聲唸出來。\n\n語音、音量和速度會依據遊戲內建的文字轉語音設定。";
L["TTS Use Hotkey"] = "使用快速鍵";
L["TTS Use Hotkey Desc"] = "開始和停止唸出內容請按下:";
L["TTS Use Hotkey Tooltip PC"] = "[KEY:PC:R]";
L["TTS Use Hotkey Tooltip Xbox"] = "[KEY:XBOX:LT]";
L["TTS Use Hotkey Tooltip PlayStation"] = "[KEY:PS:LT]";
L["TTS Auto Play"] = "自動唸出內容";
L["TTS Auto Play Desc"] = "自動唸出對話內容。";
L["TTS Auto Stop"] = "離開時停止";
L["TTS Auto Stop Desc"] = "離開 NPC 時停止唸出內容。";

--Tutorial
L["Tutorial Settings Hotkey"] = "按下 [KEY:PC:F1] 打開設定";
L["Tutorial Settings Hotkey Console"] = "按下 [KEY:PC:F1] 或 [KEY:CONSOLE:MENU] 打開設定";   --Use this if gamepad enabled
L["Instuction Open Settings"] = "要打開設定選項，請在和 NPC 互動時按下 [KEY:PC:F1]。 ";    --Used in Game Menu - AddOns
L["Instuction Open Settings Console"] = "要打開設定選項，請在和 NPC 互動時按下 [KEY:PC:F1] 或 [KEY:CONSOLE:MENU]。";

-- 自行加入
L["Dialogue UI"] = "任務對話"