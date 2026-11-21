-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Traditional Chinese Localization
-- Author: Mikord
-- Traditional Chinese Translation by: 世界之樹-Myth, yleaf(yaroot@gmail.com)
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't Traditional Chinese.
if (GetLocale() ~= "zhTW") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- Traditional Chinese localization
-------------------------------------------------------------------------------

------------------------------
-- Fonts
------------------------------

L.FONT_FILES["MSBT bLEI00D"] = "Fonts\\bLEI00D.TTF"

L.DEFAULT_FONT_NAME = "MSBT bLEI00D"

L.MSBT_MSBT = "戰鬥-捲動文字"
L.MSBT_OPENOPTION = " 開啟捲動戰鬥文字設定"


------------------------------
-- Commands
------------------------------

L.COMMAND_USAGE = {
 "使用方法: " .. MikSBT.COMMAND .. " <指令> [參數]",
 " 指令:",
 "  " .. L.COMMAND_RESET .. " - 重置",
 "  " .. L.COMMAND_DISABLE .. " - 停用",
 "  " .. L.COMMAND_ENABLE .. " - 啟用",
 "  " .. L.COMMAND_SHOWVER .. " - 顯示目前版本",
 "  " .. L.COMMAND_HELP .. " - 說明",
}


------------------------------
-- Output messages
------------------------------

L.MSG_DISABLE				= "停用插件."
L.MSG_ENABLE				= "啟用插件."
L.MSG_PROFILE_RESET			= "重置設定"
L.MSG_HITS					= "擊中"
L.MSG_CRIT					= "爆擊"
L.MSG_CRITS					= "爆擊"
L.MSG_MULTIPLE_TARGETS		= "多數目標"
L.MSG_READY_NOW				= "準備完畢"


------------------------------
-- Scroll area names
------------------------------

L.MSG_INCOMING			= "承受傷害"
L.MSG_OUTGOING			= "輸出傷害"
L.MSG_NOTIFICATION		= "通知訊息"
L.MSG_STATIC			= "靜態訊息"


---------------------------------------
-- Master profile event output messages
---------------------------------------

L.MSG_COMBAT					= "戰鬥"
L.MSG_DISPEL					= "驅散魔法"

L.MSG_KILLING_BLOW				= "擊殺"
L.MSG_TRIGGER_LOW_HEALTH		= "生命值偏低"
L.MSG_TRIGGER_LOW_MANA			= "法力值偏低"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "寵物生命偏低"


L.CP_FULL = "終結技就緒！"
-- Recent feature translations (2026-11-13).
L.COSMIC = "宇宙"
L.COMBO_POINT = "連擊點"
L.COMBO_POINTS = "連擊點"
L.SETUP_RELOAD_PROMPT = "MSBT 需要重新載入介面才能開始運作。"
L.RESOURCE_NAMES = {
    MANA = "法力",
    RAGE = "怒氣",
    FOCUS = "集中值",
    ENERGY = "能量",
    COMBO_POINTS = "連擊點",
    RUNES = "符文",
    RUNIC_POWER = "符能",
    SOUL_SHARDS = "靈魂裂片",
    LUNAR_POWER = "星界能量",
    HOLY_POWER = "聖能",
    ALTERNATE_POWER = "替代能量",
    MAELSTROM = "漩渦值",
    CHI = "真氣",
    INSANITY = "瘋狂值",
    BURNING_EMBERS = "燃火餘燼",
    DEMONIC_FURY = "惡魔之怒",
    ARCANE_CHARGES = "秘法充能",
    FURY = "魔怒",
    PAIN = "苦痛值",
    ESSENCE = "精華",
    RUNE_BLOOD = "血魄符文",
    RUNE_FROST = "冰霜符文",
    RUNE_UNHOLY = "穢邪符文",
    ALTERNATE_QUEST_POWER = "任務替代能量",
    ALTERNATE_ENCOUNTER_POWER = "戰鬥替代能量",
    ALTERNATE_MOUNT_POWER = "坐騎替代能量",
    BALANCE = "平衡",
    HAPPINESS = "快樂值",
    SHADOW_ORBS = "暗影寶珠",
    RUNE_CHROMATIC = "炫彩符文",
}

L.COMMAND_USAGE_DESIGN = "  %s - 以此設計開啟選項視窗。"

L.CLEU_TRIGGERS_DISABLED = "依賴戰鬥紀錄事件的觸發器已停用。"

L.MSG_CONTROL_BROKEN = "解除控場"
