--[[

	This file is part of 'Masque: Caith', an add-on for World of Warcraft. For bug reports,
	documentation and license information, please visit https://github.com/SFX-WoW/Masque_Dominos.

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
	L["A port of the original Dominos skin for Masque."] = "A port of the original Dominos skin for Masque."
	return
--elseif Locale == "deDE" then
--elseif Locale == "esES" or Locale == "esMX" then
--elseif Locale == "frFR" then
--elseif Locale == "itIT" then
--elseif Locale == "koKR" then
elseif Locale == "ptBR" then
	L["A port of the original Dominos skin for Masque."] = "Uma adaptação da aparência original Dominos para o Masque."
elseif Locale == "ruRU" then
	L["A port of the original Dominos skin for Masque."] = "Порт оригинального скина Dominos для Masque."
--elseif Locale == "zhCN" then
elseif Locale == "zhTW" then
	L["A port of the original Dominos skin for Masque."] = "Masque原始Dominos外觀移植版。"
end
