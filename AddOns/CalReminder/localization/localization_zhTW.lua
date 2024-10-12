local L = LibStub("AceLocale-3.0"):NewLocale("CalReminder", "zhTW", false)

if L then

L["SPACE_BEFORE_DOT"] = ""

L["CALREMINDER_SHOWEVENT"] = "顯示活動"

L["CALREMINDER_WELCOME"] = "輸入 /crm 打開行事曆活動提醒的設定選項。"

L["CALREMINDER_DDAY_REMINDER"] = "親愛的%s，你尚未回覆今晚的活動邀請%s: %s。"
L["CALREMINDER_LDAY_REMINDER"] = "親愛的%s，你尚未回覆明晚的活動邀請%s: %s。"
L["CALREMINDER_ACHIV_REMINDER"] = "待回覆的邀請"

L["CALREMINDER_OPTIONS_NPC"] = "%s NPC"
L["CALREMINDER_OPTIONS_NPC_DESC"] = "選擇提醒你即將到來活動的%s NPC。"

L["CALREMINDER_CALLTOARMS_TOOLTIP_DETAILS"] = "向線上的受邀者發送訊息。"
L["CALREMINDER_CALLTOARMS_DIALOG"] = "要傳送給線上的 '%s' 玩家的訊息："

L["CALREMINDER_TENTATIVE_REASON_DIALOG"] = "不確定性詳情:"
L["CALREMINDER_TENTATIVE_REASON"] = "理由: "
L["CALREMINDER_TENTATIVE_REASON1"] = "稍微遲到"
L["CALREMINDER_TENTATIVE_REASON2"] = "明顯遲到"
L["CALREMINDER_TENTATIVE_REASON3"] = "不確定我是否能趕到"
L["CALREMINDER_TENTATIVE_REASON4"] = "裝等不夠"
L["CALREMINDER_TENTATIVE_REASON5"] = "提早離開"
L["CALREMINDER_TENTATIVE_REASON6"] = "其他 (請註明)"

--自行加入
L["CALREMINDER"] = "行事曆活動提醒"
L["CalReminder"] = "活動提醒"
end
