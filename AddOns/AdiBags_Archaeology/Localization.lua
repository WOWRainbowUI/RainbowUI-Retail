--[[
AdiBags_Archaeology - Adds Archaeology items to AdiBags virtual groups
Copyright © 2023 Paul Vandersypen, All Rights Reserved
]]--

local _, addon = ...

-- localization table; returns English phrase if translation is not found -----
-- see https://phanx.net/addons/tutorials/localize for details ----------------
local L = setmetatable({}, {
    __index = function(t, k)
        local v = tostring(k)
        rawset(t, k, v)
        return v
    end
})

local LOCALE = GetLocale()
if LOCALE == "enUS" then
L["Archaeology Items"] = true
elseif LOCALE == "deDE" then
L["Archaeology Items"] = "Archäologie-Gegenstände"

elseif LOCALE == "koKR" then
L["Archaeology Items"] = "고고학 아이템"

elseif LOCALE == "ruRU" then
L["Archaeology Items"] = "Предметы археологии"

elseif LOCALE == "esES" then
L["Archaeology Items"] = "Archaeology Items"

elseif LOCALE == "esMX" then
L["Archaeology Items"] = "Archaeology Items"

elseif LOCALE == "itIT" then
L["Archaeology Items"] = "Articoli di archeologia"

elseif LOCALE == "ptBR" then
L["Archaeology Items"] = "Itens de Arqueologia"

elseif LOCALE == "zhTW" then
L["Archaeology Items"] = "考古學"

elseif LOCALE == "zhCN" then
L["Archaeology Items"] = "考古项目"

elseif LOCALE == "frFR" then
L["Archaeology Items"] = "Articles d'Archéologie"

end

-- Replace remaining true values by their key
for k, v in pairs(L) do
	if v == true then
		L[k] = k
	end
end

-- return localization to files
addon.L = L