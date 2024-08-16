--[[

	This file is part of 'Masque: Squat', an add-on for World of Warcraft. For license information,
	please see the included License.txt file or visit https://github.com/dlecina/Masque_Squat.

	* File....: Locales.lua
	* Authors.: dlecina

]]

-- GLOBALS: GetLocale, setmetatable

local _, Core = ...

----------------------------------------
-- Locales
---

local L = {}

Core.Locale = setmetatable(L, {
	__index = function(self, k)
		self[k] = k
		return k
	end
})

local Locale = GetLocale()

if Locale == "enGB" or Locale == "enUS" then
	-- enUS/enGB for Reference
	--L["A nice and short skin for Masque."] = "A nice and short skin for Masque."
	return
--elseif Locale == "deDE" then
--elseif Locale == "esES" or Locale == "esMX" then
elseif Locale == "frFR" then
	L["A larger version of Apathy inspired by Caith UI."] = "Une version plus grande de Apathy inspirée par Caith UI."
elseif Locale == "itIT" then
	L["A larger version of Apathy inspired by Caith UI."] = "Una versione più grande di Apathy inspirata dalla UI di Caith."
--elseif Locale == "koKR" then
--elseif Locale == "ptBR" then
--elseif Locale == "ruRU" then
--elseif Locale == "zhCN" then
--elseif Locale == "zhTW" then
end
