local MAJOR_VERSION, MINOR_VERSION = "LibBlueDB-1.0", 3
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type = _G.type
local next = _G.next
local pairs = _G.pairs
local rawget = _G.rawget
local rawset = _G.rawset
local twipe = _G.table.wipe
local tinsert = _G.table.insert
local tremove = _G.table.remove

local function overrideDB(save, default, over)
	for p, v in pairs(default) do
		if type(v) == "table" then
			if not rawget(save, p) then
				rawset(save, p, lib:NewTable(over))
			end
			if type(save[p]) == "table" then
				overrideDB(save[p], v, over)
			end
		elseif rawget(save, p) == nil then
			rawset(save, p, v)
		end
	end
end

local function clearOverride(save, default, over)
	for p, v in pairs(save) do
		if type(v) == "table" then
			if type(default[p]) == "table" then
				clearOverride(v, default[p], over)
				if not next(v) then
					save[p] = lib:RemoveTable(over, save[p])
				end
			else
				save[p] = nil
			end
		elseif v == default[p] then
			save[p] = nil
		end
	end
end

lib.database = lib.database or {}
lib.getTable = lib.getTable or {}
lib.tableArray = lib.tableArray or {}
lib.eventframe = lib.eventframe or CreateFrame("Frame")
lib.eventframe:UnregisterAllEvents()
lib.eventframe:RegisterEvent("PLAYER_LOGOUT")
lib.eventframe:SetScript("OnEvent", function()
	for save, default in pairs(lib.database) do
		clearOverride(save, default, nil)
	end
end)

function lib:RegisterDB(save, default, getTable)
	if type(save) == "table" then
		if not lib.database[save] and type(default) == "table" and next(default) then
			if type(getTable) == "function" then
				lib.getTable[save] = getTable
			else
				lib.getTable[save] = nil
			end
			clearOverride(save, default, save)
			overrideDB(save, default, save)
			lib.database[save] = default
		end
		return save
	end
	return nil
end

function lib:UnregisterDB(save, default)
	if save and lib.database[save] then
		clearOverride(save, lib.database[save], save)
		lib.database[save] = nil
		lib.getTable[save] = nil
	end
	return nil
end

function lib:NewTable(save)
	if save and lib.getTable[save] then
		if lib.tableArray[lib.getTable[save]] and #lib.tableArray[lib.getTable[save]] > 0 then
			return tremove(lib.tableArray[lib.getTable[save]], 1)
		else
			return lib.getTable[save]()
		end
	elseif lib.tableArray.self and #lib.tableArray.self > 0 then
		return tremove(lib.tableArray.self, 1)
	else
		return {}
	end
end

function lib:RemoveTable(save, tbl)
	if save then
		twipe(tbl)
		if lib.getTable[save] then
			if not lib.tableArray[lib.getTable[save]] then
				lib.tableArray[lib.getTable[save]] = {}
			end
			tinsert(lib.tableArray[lib.getTable[save]], tbl)
		else
			if not lib.tableArray.self then
				lib.tableArray.self = {}
			end
			tinsert(lib.tableArray.self, tbl)
		end
	end
	return nil
end

if not InterfaceOptionsFrame.LibBlueOptionHandler then
	InterfaceOptionsFrame.LibBlueOptionHandler = CreateFrame("Frame", nil, InterfaceOptionsFrame)
	InterfaceOptionsFrame.LibBlueOptionHandler:SetScript("OnShow", function(self)
		self.SetSize(InterfaceOptionsFrame, 856, 656)
		InterfaceOptionsFrame:ClearAllPoints()
		InterfaceOptionsFrame:SetPoint("CENTER", 0, 0)
	end)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", InterfaceOptionsFrame.StartMoving)
	InterfaceOptionsFrame:SetScript("OnDragStop", InterfaceOptionsFrame.StopMovingOrSizing)
	UIParent.SetFrameStrata(InterfaceOptionsFrame, "HIGH")
	InterfaceOptionsFrame.SetFrameStrata = InterfaceOptionsFrame.GetFrameStrata
	if InterfaceOptionsFrame.SetMinResize then
		InterfaceOptionsFrame:SetMinResize(856, 656)
		InterfaceOptionsFrame.SetMinResize = InterfaceOptionsFrame.GetMinResize
	elseif InterfaceOptionsFrame.SetResizeBounds then
		InterfaceOptionsFrame:SetResizeBounds(856, 656)
		InterfaceOptionsFrame.SetMinResize = InterfaceOptionsFrame.GetResizeBounds
	end
	InterfaceOptionsFrame:SetSize(856, 656)
	InterfaceOptionsFrame.SetWidth = InterfaceOptionsFrame.GetWidth
	InterfaceOptionsFrame.SetHeight = InterfaceOptionsFrame.GetHeight
	InterfaceOptionsFrame.SetSize = InterfaceOptionsFrame.GetSize
end