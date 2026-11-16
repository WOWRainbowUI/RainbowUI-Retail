
if (GetLocale() ~= "zhCN") then return end

local L = MikSBT.translations

L.FONT_FILES["MSBT ARKai_C"] = "Fonts\\ARKai_C.TTF"

L.DEFAULT_FONT_NAME = "MSBT ARKai_C"

L.COMMAND_USAGE = {
	"使用方法: " .. MikSBT.COMMAND .. " <命令> [参数]",
	" 命令:",
	"  " .. L.COMMAND_RESET .. " - 重置",
	"  " .. L.COMMAND_DISABLE .. " - 禁用",
	"  " .. L.COMMAND_ENABLE .. " - 启用",
	"  " .. L.COMMAND_SHOWVER .. " - 显示当前版本",
	"  " .. L.COMMAND_HELP .. " - 帮助",
}

L.MSG_DISABLE				= "禁用插件."
L.MSG_ENABLE				= "启用插件."
L.MSG_PROFILE_RESET			= "重置配置"
L.MSG_HITS					= "击中"
L.MSG_CRIT					= "爆击"
L.MSG_CRITS					= "爆击"
L.MSG_MULTIPLE_TARGETS		= "多个目标"
L.MSG_READY_NOW				= "准备完毕"

L.MSG_INCOMING			= "承受伤害"
L.MSG_OUTGOING			= "输出伤害"
L.MSG_NOTIFICATION		= "通告信息"
L.MSG_STATIC			= "静态信息"

L.MSG_COMBAT					= "战斗"
L.MSG_DISPEL					= "驱散"


L.MSG_KILLING_BLOW				= "击杀"
L.MSG_TRIGGER_LOW_HEALTH		= "生命值低"
L.MSG_TRIGGER_LOW_MANA			= "魔法值低"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "宠物生命值低"

-- Recent feature translations (2026-11-13).
L.COSMIC = "宇宙"
L.CP_FULL = "终结他！"
L.COMBO_POINT = "连击点"
L.COMBO_POINTS = "连击点"
L.SETUP_RELOAD_PROMPT = "MSBT 需要重新加载界面才能开始运行。"
L.RESOURCE_NAMES = {
    MANA = "法力",
    RAGE = "怒气",
    FOCUS = "集中值",
    ENERGY = "能量",
    COMBO_POINTS = "连击点",
    RUNES = "符文",
    RUNIC_POWER = "符文能量",
    SOUL_SHARDS = "灵魂碎片",
    LUNAR_POWER = "星界能量",
    HOLY_POWER = "圣能",
    ALTERNATE_POWER = "备用能量",
    MAELSTROM = "漩涡值",
    CHI = "真气",
    INSANITY = "狂乱值",
    BURNING_EMBERS = "爆燃灰烬",
    DEMONIC_FURY = "恶魔之怒",
    ARCANE_CHARGES = "奥术充能",
    FURY = "恶魔之怒",
    PAIN = "痛苦值",
    ESSENCE = "精华",
    RUNE_BLOOD = "鲜血符文",
    RUNE_FROST = "冰霜符文",
    RUNE_UNHOLY = "邪恶符文",
    ALTERNATE_QUEST_POWER = "任务备用能量",
    ALTERNATE_ENCOUNTER_POWER = "战斗备用能量",
    ALTERNATE_MOUNT_POWER = "坐骑备用能量",
    BALANCE = "平衡",
    HAPPINESS = "快乐值",
    SHADOW_ORBS = "暗影宝珠",
    RUNE_CHROMATIC = "多彩符文",
}
