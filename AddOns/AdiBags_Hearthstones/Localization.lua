--[[
AdiBags_Hearthstones - Adds various hearthing items to AdiBags virtual groups
Copyright © 2023 Paul Vandersypen, All Rights Reserved
]]--

local _, addon = ...

local L = setmetatable({}, {
	__index = function(self, key)
		if key then
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

local locale = GetLocale()

if locale == "ruRU" then
L["Items that hearth you to various places."] = "Предметы, возвращающие вас в разные места."


elseif locale == "deDE" then
L["Items that hearth you to various places."] = "Teleportationsgegenstände"


elseif locale == "itIT" then
L["Items that hearth you to various places."] = "Oggetti che ti teletrasportano in vari luoghi."


elseif locale == "frFR" then
L["Items that hearth you to various places."] = "Objets qui vous téléportent à divers endroits."


elseif locale == "koKR" then
L["Items that hearth you to various places."] = "여러 위치로 순간 이동하는 아이템입니다."


elseif locale == "zhCN" then
L["Items that hearth you to various places."] = "传送你到各个地方的物品."


elseif locale == "ptBR" then
L["Items that hearth you to various places."] = "Itens que te teleportam para vários lugares."


elseif locale == "zhTW" then
L["Items that hearth you to various places."] = "傳送你到各個地方的物品。"


elseif locale == "esES" then
L["Items that hearth you to various places."] = "Objetos que teletransporten a varios lugares."


elseif locale == "esMX" then
L["Items that hearth you to various places."] = "Objetos que teletransporten a varios lugares."


else
-- enUS default
L["Items that hearth you to various places."] = true
end

-- Replace remaining true values by their key
for k,v in pairs(L) do
	if v == true then
		L[k] = k
	end
end