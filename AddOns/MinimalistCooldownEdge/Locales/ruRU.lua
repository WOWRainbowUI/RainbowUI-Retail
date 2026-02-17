-- ruRU.lua (Russian)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "ruRU")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Невозможно открыть настройки в бою."

-- Category Names
L["Action Bars"] = "Панели действий"
L["Nameplates"] = "Индикаторы имени"
L["Unit Frames"] = "Фреймы юнитов"
L["CD Manager & Others"] = "Менеджер КД и Прочее"

-- Group Headers
L["General"] = "Общее"
L["State"] = "Состояние"
L["Typography (Cooldown Numbers)"] = "Типографика (Числа перезарядки)"
L["Swipe Animation"] = "Анимация вращения"
L["Stack Counters / Charges"] = "Счётчики стаков / Заряды"
L["Maintenance"] = "Обслуживание"
L["Performance & Detection"] = "Производительность и Обнаружение"
L["Danger Zone"] = "Опасная зона"
L["Style"] = "Стиль"
L["Positioning"] = "Расположение"

-- Toggles & Settings
L["Enable %s"] = "Включить %s"
L["Toggle styling for this category."] = "Переключить стилизацию для этой категории."
L["Font Face"] = "Шрифт"
L["Game Default"] = "Шрифт игры"
L["Font"] = "Шрифт"
L["Size"] = "Размер"
L["Outline"] = "Обводка"
L["Color"] = "Цвет"
L["Hide Numbers"] = "Скрыть числа"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Полностью скрыть текст (полезно, если вам нужна только кромка вращения или стаки)."
L["Anchor Point"] = "Точка привязки"
L["Offset X"] = "Смещение X"
L["Offset Y"] = "Смещение Y"
L["Show Swipe Edge"] = "Показать кромку вращения"
L["Shows the white line indicating cooldown progress."] = "Показывает белую линию, обозначающую прогресс перезарядки."
L["Edge Thickness"] = "Толщина кромки"
L["Scale of the swipe line (1.0 = Default)."] = "Масштаб линии вращения (1.0 = По умолчанию)."
L["Customize Stack Text"] = "Настроить текст стаков"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Управление счётчиком зарядов (напр., 2 стака Поджигания)."
L["Reset %s"] = "Сбросить %s"
L["Revert this category to default settings."] = "Вернуть эту категорию к настройкам по умолчанию."

-- Outline Values
L["None"] = "Нет"
L["Thick"] = "Толстая"
L["Mono"] = "Моно"

-- Anchor Point Values
L["Bottom Right"] = "Снизу справа"
L["Bottom Left"] = "Снизу слева"
L["Top Right"] = "Сверху справа"
L["Top Left"] = "Сверху слева"
L["Center"] = "Центр"

-- General Tab
L["Scan Depth"] = "Глубина сканирования"
L["How deep the addon looks into UI frames to find cooldowns."] = "Насколько глубоко аддон ищет перезарядки в фреймах интерфейса."
L["Factory Reset (All)"] = "Сброс к заводским (Все)"
L["Resets the entire profile to default values and reloads the UI."] = "Сбрасывает весь профиль к значениям по умолчанию и перезагружает интерфейс."

-- Banner
L["BANNER_DESC"] = "Минималистичная настройка перезарядок. Выберите категорию слева, чтобы начать."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Эффективно (Стандартный интерфейс)\n|cfffff56910 - 15|r : Умеренно (Bartender, Dominos)\n|cffffa500> 15|r : Тяжело (ElvUI, сложные фреймы)"

-- Chat Messages
L["%s settings reset."] = "Настройки %s сброшены."
L["Profile reset. Reloading UI..."] = "Профиль сброшен. Перезагрузка интерфейса..."
L["Global Scan Depth changed. A /reload is recommended."] = "Глобальная глубина сканирования изменена. Рекомендуется /reload."
