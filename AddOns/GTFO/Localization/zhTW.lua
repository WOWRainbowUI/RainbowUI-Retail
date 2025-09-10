--------------------------------------------------------------------------
-- zhTW.lua 
--------------------------------------------------------------------------
--[[
GTFO Traditional Chinese Localization
Translators: wowuicn, lsjyzjl, xazhaoyang, Andyca, BNSSNB
]]--

if (GetLocale() == "zhTW") then
	local L = GTFOLocal;
	L.Addon_Name = "地板傷害警報";
	L.Option_Name = "戰鬥-警報";
	L.Master_Volume = "主音量";
	L.Active_Off = "插件暫停";
	L.Active_On = "插件恢復";
	L.AlertType_Fail = "犯錯";
	L.AlertType_FriendlyFire = "友方攻擊";
	L.AlertType_High = "高";
	L.AlertType_Low = "低";
	L.ClosePopup_Message = "你可以稍後輸入：%s 來設定GTFO。";
	L.Group_None = "無";
	L.Group_NotInGroup = "你不一個隊伍或團隊中.";
	L.Group_PartyMembers = "其中有 %d 位 / 全隊： %d 位隊伍成員使用了本插件。";
	L.Group_RaidMembers = "其中有 %d 位 / 全隊： %d 位團員使用了本插件。";
	L.Help_Intro = "v%s (|cFFFFFFFF命令列表|r)";
	L.Help_Options = "顯示選項";
	L.Help_Suspend = "暫停/恢復插件";
	L.Help_Suspended = "該插件目前是暫停狀態.";
	L.Help_TestFail = "播放一個測試音效 (犯錯警報)";
	L.Help_TestFriendlyFire = "測試播放一個音效 (友方攻擊)";
	L.Help_TestHigh = "播放一個測試音效 (高傷害)";
	L.Help_TestLow = "播放一個測試音效 (低傷害)";
	L.Help_Version = "顯示團隊中，其他正在使用這個插件的成員";
	L.Loading_Loaded = "v%s 載入完成.";
	L.Loading_LoadedSuspended = "v%s 載入完成. (|cFFFF1111暫停|r)";
	L.Loading_LoadedWithPowerAuras = "v%s 與 Power Auras 同時載入完成.";
	L.Loading_NewDatabase = "v%s: 發現新的數據庫版本，重設為預設。";
	L.Loading_OutOfDate = "v%s 發現一個新的版本下載!  |cFFFFFFFF請盡快更新.|r";
	L.LoadingPopup_Message = "你的GTFO設定已被重置為預設值。你是否想要立即設定GTFO？";
	L.Loading_PowerAurasOutOfDate = "你的 |cFFFFFFFFPower Auras Classic|r 版本已過期!  GTFO & Power Auras 將無法同時載入。";
	L.Recount_Environmental = "環境";
	L.Recount_Name = "GTFO 警報";
	L.Skada_AlertList = "GTFO 警報類型";
	L.Skada_Category = "警報";
	L.Skada_SpellList = "GTFO 法術";
	L.TestSound_Fail = "測試播放一個(犯錯警報)音效。";
	L.TestSound_FailMuted = "測試播放一個(犯錯警報)音效. [|cFFFF4444靜音|r]";
	L.TestSound_FriendlyFire = "測試播放一個(友方攻擊)音效.";
	L.TestSound_FriendlyFireMuted = "測試播放一個(友方攻擊)音效. [|cFFFF4444靜音|r]";
	L.TestSound_High = "測試播放一個(高傷害)音效.";
	L.TestSound_HighMuted = "測試播放一個(高傷害)音效. [|cFFFF4444靜音|r]";
	L.TestSound_Low = "測試播放一個(低傷害)音效.";
	L.TestSound_LowMuted = "測試播放一個(低傷害)音效. [|cFFFF4444靜音|r]";
	L.UI_Enabled = "啟用";
	L.UI_EnabledDescription = "啟用 GTFO 插件.";
	L.UI_Fail = "犯錯警報音效";
	L.UI_FailDescription = "當你應該走位卻沒走位時，播放GTFO警報音效 -- 希望下次能改善!";
	L.UI_FriendlyFire = "友方攻擊音效";
	L.UI_FriendlyFireDescription = "當你的站位受到友方攻擊時(如燃燒、爆炸等)，啟用GTFO警告音效。你們其中之一最好離開!";
	L.UI_HighDamage = "團隊/高傷害音效";
	L.UI_HighDamageDescription = "當你位於會受到高傷害的位置時，立即啟用播放GTFO強烈的警告音效。";
	L.UI_LowDamage = "PvP/環境/低傷害音效";
	L.UI_LowDamageDescription = "當你還在考慮或是沒離開低傷害區時，啟動GTFO低傷害音效。";
	L.UI_SoundChannel = "聲音頻道";
	L.UI_SoundChannelDescription = "這是GTFO警告聲音將歸屬的聲音頻道。";
	L.UI_SpecialAlerts = "特殊警報";
	L.UI_SpecialAlertsHeader = "啟用特殊警報";
	L.UI_Test = "測試";
	L.UI_TestDescription = "測試音效.";
	L.UI_TestMode = "實驗/測試模式";
	L.UI_TestModeDescription = "啟用未測試的/未驗證的警報。(Beta/PTR)";
	L.UI_TestModeDescription2 = "如有任何問題，請回報到 |cFF44FFFF%s@%s.%s|r";
	L.UI_Trivial = "低等級警報";
	L.UI_TrivialDescription = "啟用低等級的副本警報.";
	L.UI_TrivialDescription2 = "設定最低能承受傷害的HP值滑塊，警告才不會被認為無關緊要。";
	L.UI_TrivialSlider = "最低 % 的HP (玩家血量)";
	L.UI_Unmute = "當靜音時播放音效";
	L.UI_UnmuteDescription = "如果你關閉了主音量，GTFO將暫時開啟音量來播放GTFO的警報。";
	L.UI_UnmuteDescription2 = "這個設定需要主音量(並且頻道已選)高於 0%.";
	L.UI_Volume = "GTFO 音量";
	L.UI_VolumeDescription = "設置警報音效的音量.";
	L.UI_VolumeLoud = "4: 大聲";
	L.UI_VolumeLouder = "5: 大聲";
	L.UI_VolumeMax = "最大";
	L.UI_VolumeMin = "最小";
	L.UI_VolumeNormal = "3: 一般 (推薦)";
	L.UI_VolumeQuiet = "1: 安靜";
	L.UI_VolumeSoft = "2: 柔和";
	L.Version_Off = "版本更新提醒關閉";
	L.Version_On = "版本更新提醒啟用";
	-- 4.66
	L.Vibration_On = "搖桿震動開啟";
	L.Vibration_Off = "搖桿震動關閉";
	L.UI_Vibration = "震動";
	L.UI_VibrationDescription = "發出警報時也會震動搖桿。";
	L.UI_CustomSounds = "自訂音效";
	L.UI_CustomSoundsHeader = "取代已有的音效警報";
	L.UI_Reset = "重置";
	L.UI_ResetCustomSounds = "將此音效重置為預設的音效。";
	-- 5.0
	L.UI_CustomSounds_Set = "設定 |cFFFFFFFF%s|r 警報的自訂音效。";
	L.UI_CustomSounds_Removed = "|cFFFFFFFF%s|r 警報的自訂音效已經恢復成預設值。";
	-- 5.3
	L.Help_IgnoreSpell = "從你的自訂忽略清單中新增/移除法術 (進階)";
	L.UI_NotSupported_Classic = "這個功能不支援經典版。";
	L.UI_IgnoreSpell_Help = "要從你的自訂忽略清單中新增/移除法術，輸入: |cFFFFFFFF/GTFO Ignore 12345|r 其中 |cFF44FFFF12345|r 是你想要忽略的法術ID。";
	L.UI_IgnoreSpell_None = "目前沒有忽略任何法術。";
	L.UI_IgnoreSpell_List = "目前忽略了下列的法術:";
	L.UI_IgnoreSpell_InvalidSpellId = "法術ID |cFF44FFFF%s|r 無效。";
	L.UI_IgnoreSpell_Add = "現在會忽略法術 #%s: %s";
	L.UI_IgnoreSpell_Remove = "不會再忽略法術 #%s: %s";
	-- 5.16
	L.BrannMode_On = "只有布萊恩提醒";
	L.BrannMode_OnWithDefault = "布萊恩及標準提醒";
	L.BrannMode_Off = "關閉布萊恩提醒";
	L.UI_BrannMode = "布萊恩提醒";
	L.UI_BrannModeDescription = "啟用此選項可讓布萊恩·銅鬚對你大吼。";
	L.UI_AprilFoolsDay = "愚人節玩笑";
	L.UI_AprilFoolsDayDescription = "取消勾選此項即可永久關閉這個有趣的愚人節玩笑。:(\n\n如果你改變心意，可以輸入 |cFFFFFFFF/GTFO Brann|r 來讓他回來。";
	-- 5.17.
	L.UI_IgnoreTime = "警報延遲時間";
	L.UI_IgnoreTimeDescription = "警報音效間隔的最小延遲時間。如果警報太頻繁，請增加此數值。";
	L.UI_IgnoreTime_Seconds = "秒";
end
