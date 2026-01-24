--[[

	This file is part of 'Masque: Serenity', an add-on for World of Warcraft. For bug reports,
	documentation and license information, please visit https://github.com/SFX-WoW/Masque_Serenity.

	* File...: Locales.lua
	* Author.: StormFX

]]

local _, Core = ...

----------------------------------------
-- Locals
---

local Locale = GetLocale()
local L = {}

----------------------------------------
-- Core
---

Core.Locale = setmetatable(L, {
	__index = function(self, k)
		self[k] = k
		return k
	end
})

----------------------------------------
-- Localization
---

if Locale == "enGB" or Locale == "enUS" then
	L["A port of the original Serenity skin by Sairen."] = "A port of the original Serenity skin by Sairen."
	L["A port of the original Serenity Square skin by Sairen."] = "A port of the original Serenity Square skin by Sairen."
	L["An alternate version of Serenity with modified Checked and Equipped textures."] = "An alternate version of Serenity with modified Checked and Equipped textures."
	L["An alternate version of Serenity Square with modified Checked and Equipped textures."] = "An alternate version of Serenity Square with modified Checked and Equipped textures."
	return
--elseif Locale == "deDE" then
--elseif Locale == "esES" or Locale == "esMX" then
--elseif Locale == "frFR" then
--elseif Locale == "itIT" then
--elseif Locale == "koKR" then
--elseif Locale == "ptBR" then
elseif Locale == "ruRU" then
	L["A port of the original Serenity skin by Sairen."] = "Порт оригинального скина Serenity от Sairen."
	L["A port of the original Serenity Square skin by Sairen."] = "Порт оригинального скина Serenity Square от Sairen."
	L["An alternate version of Serenity with modified Checked and Equipped textures."] = "Альтернативная версия Serenity с измененными текстурами Checked и Equipped."
	L["An alternate version of Serenity Square with modified Checked and Equipped textures."] = "Альтернативная версия Serenity Square с измененными текстурами Checked и Equipped."
--elseif Locale == "zhCN" then
elseif Locale == "zhTW" then
	L["A port of the original Serenity skin by Sairen."] = "這是 Sairen 原版 Serenity 外觀的移植版。"
	L["A port of the original Serenity Square skin by Sairen."] = "這是 Sairen 原版 Serenity Square 外觀的移植版。"
	L["An alternate version of Serenity Square with modified Checked and Equipped textures."] = "Serenity Square 的另一個版本，但有修改過的確認與裝備材質。"
	L["An alternate version of Serenity with modified Checked and Equipped textures."] = "Serenity 的另一個版本，但有修改過的確認與裝備材質。"
end
