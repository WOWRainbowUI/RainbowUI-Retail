if GetLocale() ~= "ruRU" then return end
local L

---------------------------
--  Ulgrax the Devourer (2902) --
---------------------------
--L= DBM:GetModLocalization(2607)

--L:SetWarningLocalization({
--})
--
--L:SetTimerLocalization{
--}
--
--L:SetOptionLocalization({
--})
--
--L:SetMiscLocalization({
--})

---------------------------
--  The Bloodbound Horror --
---------------------------
--L= DBM:GetModLocalization(2611)

---------------------------
--  Sikran, Captain of the Sureki (2898) --
---------------------------
--L= DBM:GetModLocalization(2599)

---------------------------
--  Rasha'nan (2918) --
---------------------------
--L= DBM:GetModLocalization(2609)

---------------------------
--  Bloodtwister Ovi'nax (2919) --
---------------------------
L= DBM:GetModLocalization(2612)

L:SetOptionLocalization({
	EggBreakerBehavior	= "Установить режим разбивания яиц (перезапишет настройки всех остальных, если Вы являетесь лидером рейда)",
	MatchBW				= DBM_COMMON_L.SQUARE_ICON_SMALL ..", ".. DBM_COMMON_L.TRIANGLE_ICON_SMALL ..", ".. DBM_COMMON_L.DIAMOND_ICON_SMALL ..", ".. DBM_COMMON_L.CROSS_ICON_SMALL .. " приоритет ближнего боя > дальнего боя > целителей (соответствует режиму BigWigs)",--По умолчанию
	UseAllAscending		= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcons.blp:13:13:0:0:64:64:0:16:0:16|t, |TInterface\\TargetingFrame\\UI-RaidTargetingIcons.blp:13:13:0:0:64:64:16:32:0:16|t, |TInterface\\TargetingFrame\\UI-RaidTargetingIcons.blp:13:13:0:0:64:64:32:48:0:16|t, |TInterface\\TargetingFrame\\UI-RaidTargetingIcons.blp:13:13:0:0:64:64:48:64:0:16|t и т.д. с приоритетом ближнего боя > дальнего боя > целителей",
	AvoidRedNPurple		= DBM_COMMON_L.SQUARE_ICON_SMALL ..", ".. DBM_COMMON_L.TRIANGLE_ICON_SMALL ..", ".. DBM_COMMON_L.STAR_ICON_SMALL ..", ".. DBM_COMMON_L.CIRCLE_ICON_SMALL .. " приоритет ближнего боя > дальнего боя > целителей",
	DisableIconsForRaid	= "Отключить иконки и показывать крики без иконок",
	DisableAllForRaid	= "Полностью отключить иконки и крики"
})

---------------------------
--  Nexus-Princess Ky'veza(2920) --
---------------------------
--L= DBM:GetModLocalization(2601)

---------------------------
--  The Silken Court (2921) --
---------------------------
L= DBM:GetModLocalization(2608)

L:SetMiscLocalization({
	Red		= RED_FONT_COLOR:WrapTextInColorCode(" [R-Таказдж]"),--Нитемот Таказдж
	Blue	= BLUE_FONT_COLOR:WrapTextInColorCode(" [B-Анубараш]")--Ануб'араш
})

---------------------------
--  Queen Ansurek (2922) --
---------------------------
L= DBM:GetModLocalization(2602)

L:SetOptionLocalization({
	ToxinBehavior		= "Установить режим Реактивного токсина (перезапишет настройки всех остальных, если Вы лидер рейда)",
	MatchBW				= DBM_COMMON_L.SQUARE_ICON_SMALL ..", ".. DBM_COMMON_L.TRIANGLE_ICON_SMALL ..", ".. DBM_COMMON_L.DIAMOND_ICON_SMALL ..", ".. DBM_COMMON_L.STAR_ICON_SMALL ..", ".. DBM_COMMON_L.CIRCLE_ICON_SMALL .. " (все сложности) с приоритетом ближнего боя > дальнего боя > целителей (соответствует режиму Bigwigs)",--По умолчанию
	UseAllAscending		= DBM_COMMON_L.STAR_ICON_SMALL ..", ".. DBM_COMMON_L.CIRCLE_ICON_SMALL ..", ".. DBM_COMMON_L.DIAMOND_ICON_SMALL ..", ".. DBM_COMMON_L.TRIANGLE_ICON_SMALL ..", ".. DBM_COMMON_L.MOON_ICON_SMALL .. " (все сложности) с приоритетом ближнего боя > дальнего боя > целителей",
	DisableIconsForRaid	= "Отключить иконки и показывать крики без иконок",
	DisableAllForRaid	= "Полностью отключить иконки и крики"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("NerubarPalaceTrash")

L:SetGeneralLocalization({
	name =	"Трэш мобы Неруб'арский дворец"
})

L:SetMiscLocalization({
	AutoPotioned	= "Автоматически используемое зелье (Примечание: DBM не будет автоматически использовать зелье, если у Вас уже есть дебафф). Вы можете отключить это в настройках, если не хотите, чтобы зелье использовалось автоматически."
})

---------------------------
--  Vexie and the Geargrinders) --
---------------------------
--L= DBM:GetModLocalization(2639)

---------------------------
--  Cauldron of Carnage --
---------------------------
L= DBM:GetModLocalization(2640)

L:SetOptionLocalization({
	AdvancedBossFiltering	= "Активно сканировать расстояние до каждого из боссов и автоматически скрывать определенные оповещения и таймеры исчезновения для боссов, рядом с которыми Вы НЕ находитесь (более 60 м.)"
})

---------------------------
--  Rik Reverb --
---------------------------
--L= DBM:GetModLocalization(2641)

---------------------------
--  Stix Bunkjunker --
---------------------------
L= DBM:GetModLocalization(2642)

L:SetMiscLocalization({
	BombsLeft		= "Бомб осталось:"
})

---------------------------
--  Sprocketmonger Lockenstock --
---------------------------
L= DBM:GetModLocalization(2653)

L:SetWarningLocalization{
	specWarnPolGen	= "Изменение на %s - 3 сек.",
}

L:SetOptionLocalization({
	specWarnPolGen	= "Показывать спецпредупреждение, когда генератор полярности меняет заряд"
})

---------------------------
--  The One-Armed Bandit --
---------------------------
L= DBM:GetModLocalization(2644)

L:SetMiscLocalization({
	BaitCoil	= "Байт катушки"
})


---------------------------
--  Mug'Zee, Heads of Security --
---------------------------
--L= DBM:GetModLocalization(2645)

---------------------------
--  Chrome King Gallywix --
---------------------------
--L= DBM:GetModLocalization(2646)

---------------------------
--  Plexus Sentinel --
---------------------------
--L= DBM:GetModLocalization(2684)

---------------------------
--  Loom'ithar --
---------------------------
--L= DBM:GetModLocalization(2686)

---------------------------
--  Soulbinder Naazindhri --
---------------------------
--L= DBM:GetModLocalization(2685)

---------------------------
--  Forgeweaver Araz --
---------------------------
--L= DBM:GetModLocalization(2687)

---------------------------
--  The Soul Hunters --
---------------------------
--L= DBM:GetModLocalization(2688)

---------------------------
--  Fractillus --
---------------------------
--L= DBM:GetModLocalization(2747)

---------------------------
--  Nexus-King Salhadaar --
---------------------------
--L= DBM:GetModLocalization(2690)

---------------------------
--  Dimensius, the All-Devouring --
---------------------------
--L= DBM:GetModLocalization(2691)
