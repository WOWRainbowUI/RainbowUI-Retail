--[[

	This file is part of 'Masque: Squat', an add-on for World of Warcraft.

	* File...: Locales.lua
	* Author.: StormFX & dlecina

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
	L["A nice and short skin for Masque."] = "A nice and short skin for Masque."
	return
end