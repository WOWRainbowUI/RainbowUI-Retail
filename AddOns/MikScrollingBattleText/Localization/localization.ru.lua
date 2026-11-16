
if (GetLocale() ~= "ruRU") then return end

local L = MikSBT.translations

L.FONT_FILES = {
	["MSBT Morpheus"]		= "Fonts\\MORPHEUS.TTF",
	["MSBT Nim"]			= "Fonts\\NIM_____.ttf",
	["MSBT Skurri"]			= "Fonts\\SKURRI.TTF",
}

L.DEFAULT_FONT_NAME = "MSBT Nim"

L.COMMAND_USAGE = {
	"Используйте: " .. MikSBT.COMMAND .. " <команда> [параметр]",
	" Команды:",
	"  " .. L.COMMAND_RESET .. " - Сброс текущего профиля на стандартные настройки.",
	"  " .. L.COMMAND_DISABLE .. " - Отключить данный мод.",
	"  " .. L.COMMAND_ENABLE .. " - Включить данный мод.",
	"  " .. L.COMMAND_SHOWVER .. " - Показать текущую версию.",
	"  " .. L.COMMAND_HELP .. " - Показать доступные команды.",
}

L.MSG_DISABLE					= "Мод отключен."
L.MSG_ENABLE					= "Мод включен."
L.MSG_PROFILE_RESET				= "Сброс профиля"
L.MSG_HITS						= "Попадания"
L.MSG_CRIT						= "Крит"
L.MSG_CRITS						= "Критов"
L.MSG_MULTIPLE_TARGETS			= "Несколько"
L.MSG_READY_NOW					= "Готов"

L.MSG_INCOMING			= "Входящий"
L.MSG_OUTGOING			= "Исходящий"
L.MSG_NOTIFICATION		= "Извещения"
L.MSG_STATIC			= "Статический"

L.MSG_COMBAT					= "Бой"
L.MSG_DISPEL					= "Рассеяно"


L.MSG_KILLING_BLOW				= "Победный удар!"
L.MSG_TRIGGER_LOW_HEALTH		= "Малый запас здоровья"
L.MSG_TRIGGER_LOW_MANA			= "Малый запас маны"
L.MSG_TRIGGER_LOW_PET_HEALTH	= "Малый запас здоровья питомца"

-- Recent feature translations (2026-11-13).
L.COSMIC = "Космическая"
L.CP_FULL = "Прикончи его!"
L.COMBO_POINT = "Очко серии приемов"
L.COMBO_POINTS = "Очки серии приемов"
L.SETUP_RELOAD_PROMPT = "Чтобы MSBT начал работать, необходимо перезагрузить интерфейс."
L.RESOURCE_NAMES = {
    MANA = "Мана",
    RAGE = "Ярость",
    FOCUS = "Концентрация",
    ENERGY = "Энергия",
    COMBO_POINTS = "Очко серии приемов",
    RUNES = "Руны",
    RUNIC_POWER = "Сила рун",
    SOUL_SHARDS = "Осколки души",
    LUNAR_POWER = "Астральная мощь",
    HOLY_POWER = "Энергия Света",
    ALTERNATE_POWER = "Дополнительный ресурс",
    MAELSTROM = "Энергия Водоворота",
    CHI = "Энергия ци",
    INSANITY = "Безумие",
    BURNING_EMBERS = "Пылающие угли",
    DEMONIC_FURY = "Демоническая ярость",
    ARCANE_CHARGES = "Чародейские заряды",
    FURY = "Гнев",
    PAIN = "Боль",
    ESSENCE = "Сущность",
    RUNE_BLOOD = "Руна крови",
    RUNE_FROST = "Руна льда",
    RUNE_UNHOLY = "Руна нечестивости",
    ALTERNATE_QUEST_POWER = "Ресурс задания",
    ALTERNATE_ENCOUNTER_POWER = "Ресурс сражения",
    ALTERNATE_MOUNT_POWER = "Ресурс транспорта",
    BALANCE = "Баланс",
    HAPPINESS = "Настроение",
    SHADOW_ORBS = "Сферы Тьмы",
    RUNE_CHROMATIC = "Хроматическая руна",
}
