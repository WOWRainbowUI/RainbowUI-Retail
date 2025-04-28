--------------------------------------------------------------------------
-- zhTW.lua 
--------------------------------------------------------------------------
--[[
GTFO Traditional Chinese Localization
Translators: wowuicn, lsjyzjl, xazhaoyang, Andyca, BNSSNB
]]--

if (GetLocale() == "zhTW") then

GTFOLocal = 
{
	Addon_Name = "地板傷害警報",
	Option_Name = "戰鬥-警報",
	Master_Volume = "主音量",
	Active_Off = "插件暫停",
	Active_On = "插件恢復",
	AlertType_Fail = "犯錯",
	AlertType_FriendlyFire = "友方誤傷",
	AlertType_High = "高",
	AlertType_Low = "低",
	ClosePopup_Message = "你可以稍後輸入：%s 來設定GTFO。",
	Group_None = "無",
	Group_NotInGroup = "你不一個隊伍或團隊中.",
	Group_PartyMembers = "其中有 %d 位 / 全隊： %d 位隊伍成員使用了本插件。",
	Group_RaidMembers = "其中有 %d 位 / 全隊： %d 位團員使用了本插件。",
	Help_Intro = "v%s (|cFFFFFFFF命令列表|r)",
	Help_Options = "顯示選項",
	Help_Suspend = "暫停/恢復插件",
	Help_Suspended = "該插件目前是暫停狀態。",
	Help_TestFail = "播放測試音效 (犯錯警報)",
	Help_TestFriendlyFire = "測試播放音效 (友方誤傷)",
	Help_TestHigh = "播放測試音效 (高傷害)",
	Help_TestLow = "播放測試音效 (低傷害)",
	Help_Version = "顯示團隊中，其他正在使用這個插件的成員",
	Loading_Loaded = "v%s 載入完成.",
	Loading_LoadedSuspended = "v%s 載入完成. (|cFFFF1111暫停|r)",
	Loading_LoadedWithPowerAuras = "v%s 與 Power Auras 同時載入完成。",
	Loading_NewDatabase = "v%s: 發現新的資料庫版本，重設為預設值。",
	Loading_OutOfDate = "v%s 有新版本可供下載!  |cFFFFFFFF請儘快更新。|r",
	LoadingPopup_Message = "GTFO 設定已被重置為預設值，是否要立即設定 GTFO?",
	Loading_PowerAurasOutOfDate = "你的 |cFFFFFFFFPower Auras Classic|r 版本已過期!  GTFO & Power Auras 將無法同時載入。",
	Recount_Environmental = "環境",
	Recount_Name = "GTFO 警報",
	Skada_AlertList = "GTFO 警報類型",
	Skada_Category = "警報",
	Skada_SpellList = "GTFO 法術",
	TestSound_Fail = "測試播放 (犯錯警報) 音效。",
	TestSound_FailMuted = "測試播放 (犯錯警報) 音效。[|cFFFF4444靜音|r]",
	TestSound_FriendlyFire = "測試播放 (友方誤傷) 音效。",
	TestSound_FriendlyFireMuted = "測試播放 (友方誤傷) 音效。[|cFFFF4444靜音|r]",
	TestSound_High = "測試播放 (高傷害) 音效。",
	TestSound_HighMuted = "測試播放 (高傷害) 音效。[|cFFFF4444靜音|r]",
	TestSound_Low = "測試播放 (低傷害) 音效。",
	TestSound_LowMuted = "測試播放 (低傷害) 音效。[|cFFFF4444靜音|r]",
	UI_Enabled = "啟用",
	UI_EnabledDescription = "啟用地板傷害警報 GTFO 插件。",
	UI_Fail = "犯錯警報音效",
	UI_FailDescription = "當你應該走位卻沒走位時，播放GTFO警報音效 -- 希望下次能改善!",
	UI_FriendlyFire = "友方誤傷音效",
	UI_FriendlyFireDescription = "當你的站位受到友方誤傷時 (如燃燒、爆炸等)，啟用 GTFO 警告音效。你們其中之一最好離開!",
	UI_HighDamage = "團隊/高傷害音效",
	UI_HighDamageDescription = "當你位於會受到高傷害的位置時，立即啟用播放GTFO強烈的警告音效。",
	UI_LowDamage = "PvP/環境/低傷害音效",
	UI_LowDamageDescription = "當你還在考慮或是沒離開低傷害區時，啟動GTFO低傷害音效。",
	UI_SoundChannel = "聲音頻道",
	UI_SoundChannelDescription = "這是GTFO警告聲音將歸屬的聲音頻道。",
	UI_SpecialAlerts = "特殊警報",
	UI_SpecialAlertsHeader = "啟用特殊警報",
	UI_Test = "測試",
	UI_TestDescription = "測試音效.",
	UI_TestMode = "實驗/測試模式",
	UI_TestModeDescription = "啟用未測試的/未驗證的警報。(Beta/PTR)",
	UI_TestModeDescription2 = "如有任何問題，請回報到 |cFF44FFFF%s@%s.%s|r",
	UI_Trivial = "低等級警報",
	UI_TrivialDescription = "啟用低等級首領戰的警報，否則這些警報對你角色的當前等級而言將會被視為無關緊要。",
	UI_TrivialDescription2 = "使用滑桿來設定承受傷害的HP值%最小值，警告才不會被認為是無關緊要的。",
	UI_TrivialSlider = "最低 % 的HP (玩家血量)",
	UI_Unmute = "靜音時也要播放音效",
	UI_UnmuteDescription = "主音量靜音時，GTFO 會暫時開啟音量來播放 GTFO 的警報音效。",
	UI_UnmuteDescription2 = "這個設定需要主音量 (和選擇的頻道) 音量滑桿高於 0%。",
	UI_Volume = "GTFO 音量",
	UI_VolumeDescription = "設定警報音效的音量。",
	UI_VolumeLoud = "4: 大聲",
	UI_VolumeLouder = "5: 超大聲",
	UI_VolumeMax = "最大",
	UI_VolumeMin = "最小",
	UI_VolumeNormal = "3: 一般 (推薦)",
	UI_VolumeQuiet = "1: 安靜",
	UI_VolumeSoft = "2: 柔和",
	Version_Off = "版本更新提醒關閉",
	Version_On = "版本更新提醒啟用",
	-- 4.66
	Vibration_On = "搖桿震動開啟",
	Vibration_Off = "搖桿震動關閉",
	UI_Vibration = "震動",
	UI_VibrationDescription = "發出警報時也會震動搖桿。",
	UI_CustomSounds = "自訂音效",
	UI_CustomSoundsHeader = "取代已有的音效警報",
	UI_Reset = "重置",
	UI_ResetCustomSounds = "將此音效重置為預設的音效。",
	-- 5.0
	UI_CustomSounds_Set = "設定 |cFFFFFFFF%s|r 警報的自訂音效。",
	UI_CustomSounds_Removed = "|cFFFFFFFF%s|r 警報的自訂音效已經恢復成預設值。",
	-- 5.3
	Help_IgnoreSpell = "從你的自訂忽略清單中新增/移除法術 (進階)";
	UI_NotSupported_Classic = "這個功能不支援經典版。";
	UI_IgnoreSpell_Help = "要從你的自訂忽略清單中新增/移除法術，輸入: |cFFFFFFFF/GTFO Ignore 12345|r 其中 |cFF44FFFF12345|r 是你想要忽略的法術ID。";
	UI_IgnoreSpell_None = "目前沒有忽略任何法術。";
	UI_IgnoreSpell_List = "目前忽略了下列的法術:";
	UI_IgnoreSpell_InvalidSpellId = "法術ID |cFF44FFFF%s|r 無效。";
	UI_IgnoreSpell_Add = "現在會忽略法術 #%s: %s";
	UI_IgnoreSpell_Remove = "不會再忽略法術 #%s: %s";
	-- 5.16
	BrannMode_On = "只有布萊恩提醒",
	BrannMode_OnWithDefault = "布萊恩及標準提醒",
	BrannMode_Off = "關閉布萊恩提醒",
	UI_BrannMode = "布萊恩提醒",
	UI_BrannModeDescription = "啟用此選項可讓布萊恩·銅鬚對你大吼。",
	UI_AprilFoolsDay = "愚人節玩笑",
	UI_AprilFoolsDayDescription = "取消勾選此項即可永久關閉這個有趣的愚人節玩笑。:(\n\n如果你改變心意，可以輸入 |cFFFFFFFF/GTFO Brann|r 來讓他回來。",
	-- 5.17.
	UI_IgnoreTime = "警報延遲時間",
	UI_IgnoreTimeDescription = "警報音效間隔的最小延遲時間。如果警報太頻繁，請增加此數值。",
	UI_IgnoreTime_Seconds = "秒",
}

end
