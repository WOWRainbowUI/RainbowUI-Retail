if not (GetLocale() == "zhTW") then return end;

local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "功能選項";
L["Quick Slot Generic Description"] = "\n\n*快捷按鈕是一組在特定情形下出現的、可交互的按鈕。";
L["Restriction Combat"] = "戰鬥中不可用";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*如需更改標記大小，請打開 世界地圖 - 地圖篩選 - Plumber";

--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "一般";
--- order: 2
L["Module Category NPC Interaction"] = "NPC 互動";
--- order: 3
L["Module Category Class"] = "職右";   --Player Class (rogue, paladin...)
--- order: 4
L["Module Category Dreamseeds"] = "夢境種子";     --Added in patch 10.2.0

--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "自動加入活動";
L["ModuleDescription AutoJoinEvents"] = "在時間裂隙事件期間與索莉多米對話會自動選擇加入活動。";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "背包物品追蹤";
L["ModuleDescription BackpackItemTracker"] = "和追蹤貨幣一樣在背包介面上追蹤可堆疊的物品。\n\n節日代幣會被自動追蹤，並顯示在最左側。";
L["Instruction Track Item"] = "追蹤物品";
L["Hide Not Owned Items"] = "隱藏未擁有的物品";
L["Hide Not Owned Items Tooltip"] = "你曾追蹤過但現在不再擁有的物品將被收納進一個隱藏的選單。";
L["Concise Tooltip"] = "簡化浮動提示資訊";
L["Concise Tooltip Tooltip"] = "只顯示物品的綁定類型和你能擁有的最大數量。";
L["Item Track Too Many"] = "最多只能自訂追蹤 %d 個物品。"
L["Tracking List Empty"] = "追蹤列表為空。";
L["Holiday Ends Format"] = "結束於:  %s";
L["Not Found"] = "未找到物品";   --Item not found
L["Own"] = "擁有";   --Something that the player has/owns
L["Numbers To Earn"] = "還可獲取";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "已獲取";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "追蹤紋章";     --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "在最左側顯示你已獲得的最高等級的紋章。";
L["Currently Pinned Colon"] = "當前顯示: ";     --Tells the currently pinned item


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "馭龍競速評級";
L["ModuleDescription GossipFrameMedal Format"] = "將預設圖標 %s 替換為你獲得的獎章 %s。\n\n在你與青銅時光守護者對話後，可能需要短暫的時間來從服務器獲取記錄。";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "德魯伊模型修復";
L["ModuleDescription DruidModelFix"] = "修復使用群星雕文導致人物界面模型變白的問題。\n\n暴雪將在10.2.0版本修復這個問題。";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "顯示捐獻物品數";
L["ModuleDescription PlayerChoiceFrameToken"] = "在玩家選擇介面上顯示你有多少待捐贈的物品。\n\n目前僅支援夢境灌注。";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "快捷按鈕: 夢境種子";
L["ModuleDescription EmeraldBountySeedList"] = "當你走近翡翠恩惠時顯示可播種的種子。"..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "地圖標記: 夢境種子";
L["ModuleDescription WorldMapPinSeedPlanting"] = "在大地圖上顯示夢境種子的位置和其生長周期。"..L["Map Pin Change Size Method"].."\n\n|cffd4641c啟用這個功能將移除大地圖上原有的翡翠恩惠標記，這可能會影響其他地圖插件的行為。";
L["Pin Size"] = "標記大小";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "捐獻界面: 夢境灌注";
L["ModuleDescription AlternativePlayerChoiceUI"] = "將原始的夢境灌注界面替換為一個遮擋更少的界面，並顯示你擁有物品的數量。你還可以通過長按的方式來自動捐獻物品。";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "便捷開鎖";
L["ModuleDescription HandyLockpick"] = "右鍵點擊可直接解鎖放在背包或玩家交易界面裡的保險箱。\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- 不能直接解鎖放在銀行中的物品\n- 受軟選取目標模式的影響";
L["Instruction Pick Lock"] = "<右鍵點擊以解鎖>";

--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "暴雪修正: 事件通知";
L["ModuleDescription BlizzFixEventToast"] = "修正事件通知，讓它不會影響滑鼠點擊。並且讓你能用使用右鍵點它來直接關閉。\n\n*事件通知是當你完成特定活動時在畫面上方出現的大型橫幅通知。";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "對話頭像";
L["ModuleDescription TalkingHead"] = "將預設的對話頭像替換為一個乾淨、無頭像的介面。";
L["EditMode TalkingHead"] = "夢境工具組: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "立即顯示文字";   --Should texts immediately, no gradual fading
L["TalkingHead Option Condition Header"] = "隱藏這些來源的文字:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "世界任務";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "隱藏世界任務的對話頭像。\n有時在接取世界任務之前就會觸發的對話頭像無法隱藏。";
L["TalkingHead Option Condition Instance"] = INSTANCE or "副本";
L["TalkingHead Option Condition Instance Tooltip"] = "在副本中時隱藏對話頭像";


--AzerothianArchives
L["ModuleName AzerothianArchives"] = "對話頭像: Azerothian Archives";
L["ModuleDescription AzerothianArchives"] = "在你為艾澤拉斯檔案館辦事時，替換預設的對話頭像介面。";


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "優先順序";
L["Priority Default"] = "預設";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "依照魔獸的預設值，可能的話，優先順序為任務、屍體、商人位置。否則開始追蹤作用中的種子。";
L["Stop Tracking"] = "停止追蹤";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "左鍵 追蹤位置";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "左鍵 使用 TomTom 導航";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "導航: 夢境種子";
L["ModuleDescription Navigator_Dreamseed"] = "使用導航系統引導你到夢境種子。\n\n*右鍵點位置指示 (如果有的話) 顯示更多選項。\n\n|cffd4641c當你在翡翠夢境時，將會取代遊戲內建的導航。\n\n種子位置的指示可能會被任務覆蓋掉。|r";
L["Priority New Seeds"] = "尋找新種子";
L["Priority Rewards"] = "收集獎勵";
L["Stop Tracking Dreamseed Tooltip"] = "停止追蹤種子直到你用左鍵點擊地圖標記。";

--Rare/Location Announcement
L["Announce Location Tooltip"] = "在聊天頻道中分享這個位置。";
L["Announce Forbidden Reason In Cooldown"] = "你不久前分享過位置。";
L["Announce Forbidden Reason Duplicate Message"] = "其他玩家不久前分享過這個位置。";
L["Announce Forbidden Reason Soon Despawn"] = "你不能通告一個即將消失的位置。";
L["Available In Format"] = "此時間後可用: |cffffffff%s|r";

--Generic
L["Reposition Button Horizontal"] = "水平移動";   --Move the window horizontally
L["Reposition Button Vertical"] = "垂直移動";
L["Reposition Button Tooltip"] = "左鍵拖曳移動視窗。";
L["Font Size"] = FONT_SIZE or "文字大小";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "重置為預設位置";

-- !! Do NOT translate the following entries
L["currency-2706"] = "Whelpling";
L["currency-2707"] = "Drake";
L["currency-2708"] = "Wyrm";
L["currency-2709"] = "Aspect";

-- 自行加入
L["Plumber"] = "夢境工具"