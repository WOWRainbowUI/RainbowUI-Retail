local addonName, addonTable = ...
local C, L = addonTable.C, addonTable.L

-- Lua
local _G = getfenv(0)
local error = _G.error
local geterrorhandler = _G.geterrorhandler
local next = _G.next
local s_format = _G.string.format
local s_match = _G.string.match
local s_split = _G.string.split
local t_concat = _G.table.concat
local tonumber = _G.tonumber
local type = _G.type
local xpcall = _G.xpcall

-- Mine
local E, P = {}, {}
addonTable.E, addonTable.P = E, P

_G[addonName] = {
	[1] = E,
	[2] = C,
	[3] = L,
}

do
	local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
	local registeredEvents = {}

	local dispatcher = CreateFrame("Frame")
	dispatcher:SetScript("OnEvent", function(_, event, ...)
		for func in next, registeredEvents[event] do
			func(...)
		end

		if oneTimeEvents[event] == false then
			oneTimeEvents[event] = true
		end
	end)

	function E:RegisterEvent(event, func, unit1, unit2)
		if oneTimeEvents[event] then
			error(s_format("Failed to register for '%s' event, already fired!", event), 3)
		end

		if not func or type(func) ~= "function" then
			error(s_format("Failed to register for '%s' event, no handler!", event), 3)
		end

		if not registeredEvents[event] then
			registeredEvents[event] = {}

			if unit1 then
				P:Call(dispatcher.RegisterUnitEvent, dispatcher, event, unit1, unit2)
			else
				P:Call(dispatcher.RegisterEvent, dispatcher, event)
			end
		end

		registeredEvents[event][func] = true
	end

	function E:UnregisterEvent(event, func)
		local funcs = registeredEvents[event]

		if funcs and funcs[func] then
			funcs[func] = nil

			if not next(funcs) then
				registeredEvents[event] = nil

				P:Call(dispatcher.UnregisterEvent, dispatcher, event)
			end
		end
	end
end

function P:UpdateTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dest[k] = self:UpdateTable(v, dest[k])
		else
			if dest[k] == nil then
				dest[k] = v
			end
		end
	end

	return dest
end

do
	local function errorHandler(err)
		return geterrorhandler()(err)
	end

	function P:Call(func, ...)
		return xpcall(func, errorHandler, ...)
	end
end

-- Libs
P.CallbackHandler = LibStub("CallbackHandler-1.0"):New(E)

-------------
-- HELPERS --
-------------

function E:SanitizeLink(link)
	if not link or link == "[]" or link == "" then
		return
	end

	local temp, name = s_match(link, "|H(.+)|h%[(.+)%]|h")
	link = temp or link

	local linkTable = {s_split(":", link)}

	if linkTable[1] ~= "item" then
		return link, link, linkTable[1], tonumber(linkTable[2]), name
	end

	-- remove modifier types and values due to inconsistencies
	local numBonusIDs = tonumber(linkTable[14])
	if numBonusIDs then
		local numModifiers = tonumber(linkTable[15 + numBonusIDs])
		if numModifiers then
			for i = 16 + numBonusIDs, 16 + numBonusIDs + numModifiers * 2 - 1 do
				linkTable[i] = ""
			end
		end
	end

	return t_concat(linkTable, ":"), link, linkTable[1], tonumber(linkTable[2]), name
end

function E:GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()

	if not (x and y) then
		return "UNKNOWN"
	end

	local screenWidth = UIParent:GetRight()
	local screenHeight = UIParent:GetTop()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3

	if y >= screenHeight * 2 / 3 then
		if x <= screenLeft then
			return "TOPLEFT"
		elseif x >= screenRight then
			return "TOPRIGHT"
		else
			return "TOP"
		end
	elseif y <= screenHeight / 3 then
		if x <= screenLeft then
			return "BOTTOMLEFT"
		elseif x >= screenRight then
			return "BOTTOMRIGHT"
		else
			return "BOTTOM"
		end
	else
		if x <= screenLeft then
			return "LEFT"
		elseif x >= screenRight then
			return "RIGHT"
		else
			return "CENTER"
		end
	end
end

do
	local ILVL_LINE = Enum.TooltipDataLineType.ItemLevel
	local ILVL_PATTERN = "(%d+)"

	local itemCache = {}

	function E:GetItemLevel(itemLink)
		local _, _, _, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(itemLink)
		if not itemEquipLoc or itemEquipLoc == "INVTYPE_NON_EQUIP_IGNORE" then
			return 0
		end

		if itemCache[itemLink] then
			return itemCache[itemLink]
		end

		local data = C_TooltipInfo.GetHyperlink(itemLink, nil, nil, true)
		if not data then
			return 0
		end

		local ilvl
		for _, line in next, data.lines do
			if line.type == ILVL_LINE then
				ilvl = line.leftText:match(ILVL_PATTERN)
				if ilvl then
					ilvl = tonumber(ilvl:trim())
				end

				break
			end
		end

		itemCache[itemLink] = ilvl

		return ilvl or 0
	end
end
