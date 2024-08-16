local MAJOR_VERSION, MINOR_VERSION = "LibBlueOption-1.0", 4
if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type = _G.type
local max = _G.math.max
local min = _G.math.min
local twipe = _G.table.wipe
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local UnitAffectingCombat = _G.UnitAffectingCombat

lib.widgets = lib.widgets or {}
lib.widgetsVersion = lib.widgetsVersion or {}
lib.widgetsVisible = lib.widgetsVisible or {}
lib.widgetsCombat = lib.widgetsCombat or {}
lib.widgetsNum = lib.widgetsNum or {}
lib.widgetMenus = lib.widgetMenus or {}
lib.widgetHiddenHandler = lib.widgetHiddenHandler or {}
lib.widgetParents = lib.widgetParents or {}

lib.frame = lib.frame or CreateFrame("Frame")
lib.frame:UnregisterAllEvents()
lib.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
lib.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.frame:SetScript("OnEvent", function()
	lib.inCombat = InCombatLockdown() or UnitAffectingCombat("player")
	for obj in pairs(lib.widgetsCombat) do
		obj:Update()
	end
end)
lib.inCombat = InCombatLockdown() or UnitAffectingCombat("player")

function lib:NewWidget(widget, version)
	if type(widget) == "string" and type(version) == "number" then
		if lib.widgets[widget] and lib.widgetsVersion[widget] then
			if lib.widgetsVersion[widget] < version then
				return true
			else
				return nil
			end
		else
			return true
		end
	else
		return nil
	end
end

function lib:RegisterWidget(widget, version, constructor)
	if lib:NewWidget(widget, version) then
		lib.widgets[widget], lib.widgetsVersion[widget] = constructor, version
		lib.widgetsNum[widget] = lib.widgetsNum[widget] or 0
	end
end

local function widgetOnEnter(self)
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true)
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end
	if self.highlight then
		if self.isDisabled then
			self.highlight:Hide()
		else
			self.highlight:Show()
		end
	end
end

local function widgetParentOnEnter(self)
	widgetOnEnter(self:GetParent())
end

local function widgetOnLeave(self)
	GameTooltip_Hide()
	if self.highlight then
		self.highlight:Hide()
	end
end

local function widgetParentOnLeave(self)
	widgetOnLeave(self:GetParent())
end

local function widgetParentOnShow(self)
	for widget in pairs(lib.widgetHiddenHandler[self]) do
		widget:Update()
	end
end

local function widgetSetStatus(self)
	if lib:GetObjectElementValue(self, "hidden") then
		if self:GetParent() and self.Update then
			if not lib.widgetHiddenHandler[self:GetParent()] then
				lib.widgetHiddenHandler[self:GetParent()] = {}
				self:GetParent():HookScript("OnShow", widgetParentOnShow)
			end
			lib.widgetHiddenHandler[self:GetParent()][self] = true
		end
		self:Hide()
		return
	else
		self:Show()
	end
	if lib:GetObjectElementValue(self, "disable") or (lib.inCombat and lib:GetObjectElementValue(self, "combat")) then
		self.isDisabled = true
		if self.Disable then
			self:Disable()
		end
		if self.highlight then
			self.highlight:Hide()
		end

	else
		self.isDisabled = nil
		if self.Enable then
			self:Enable()
		end
	end
end

local function widgetUpdate(self)
	widgetSetStatus(self)
	if self:IsVisible() and self.Setup then
		self:Setup()
	end
end

local function widgetGetValue(self)
	return lib:GetObjectElementValue(self, "get")
end

local function widgetSetValue(self, value)
	if type(self.set) == "function" then
		self.set(value, self.arg1, self.arg2, self.arg3)
		widgetUpdate(self)
	end
end

local function widgetOnShow(self)
	self:Update()
	lib.widgetsVisible[self] = true
	if lib:GetObjectElementValue(self, "combat") then
		lib.widgetsCombat[self] = true
	end
end

local function widgetOnHide(self)
	lib.widgetsVisible[self] = nil
	lib.widgetsCombat[self] = nil
	for menu in pairs(lib.widgetMenus) do
		if menu.parent == self then
			menu:Hide()
			break
		end
	end
end

local function widgetSetScript(self, script, func)
	if self:HasScript(script) then
		if self:GetScript(script) then
			if type(func) == "function" then
				self:HookScript(script, func)
			end
		else
			self:SetScript(script, type(func) == "function" and func or nil)
		end
	end
end

function lib:CreateWidget(widget, parent, title, tooltipText, hidden, disable, combat, get, set, ...)
	if lib.widgets[widget] then
		lib.widgetsNum[widget] = lib.widgetsNum[widget] + 1
		local obj = CreateFrame("Frame", "LibBlueOption10"..widget..lib.widgetsNum[widget], parent or UIParent, BackdropTemplateMixin and "BackdropTemplate")
		if widget == "Menu" or widget == "Tab" then
			obj.get = title
			obj.arg1, obj.arg2, obj.arg3, obj.arg4, obj.arg5 = tooltipText, hidden, disable, combat, get
		elseif widget == "ShowHide" then
			obj:SetSize(1, 1)
			obj.disable, obj.combat = title, tooltipText
			obj.arg1, obj.arg2, obj.arg3 = hidden, disable, combat, get, ...
			obj.Update = widgetUpdate
		else
			obj:SetSize(160, 44)
			obj.hidden, obj.disable, obj.combat = hidden, disable, combat
			obj.tooltipText = tooltipText
			obj.get, obj.set = get, set
			obj.arg1, obj.arg2, obj.arg3, obj.arg4, obj.arg5 = ...
			obj.GetValue = widgetGetValue
			obj.SetValue = widgetSetValue
			obj.Update = widgetUpdate
		end
		lib.widgets[widget](obj, obj:GetName())
		for i, child in pairs(obj) do
			if type(child) == "table" and child.GetObjectType and child:GetParent() == obj then
				if child.HasScript and child:IsMouseEnabled() then
					widgetSetScript(child, "OnEnter", widgetParentOnEnter)
					widgetSetScript(child, "OnLeave", widgetParentOnLeave)
				end
			end
		end
		if obj.Update == widgetUpdate then
			if obj.title then
				obj.title:SetText(title)
			end
			widgetSetScript(obj, "OnShow", widgetOnShow)
			widgetSetScript(obj, "OnHide", widgetOnHide)
			if obj:IsVisible() then
				widgetOnShow(obj)
			else
				widgetOnHide(obj)
			end
		end
		return obj
	end
	return nil
end

local hobj

function lib:Refresh(parent)
	for obj in pairs(lib.widgetsVisible) do
		widgetUpdate(obj)
	end
	if parent and lib.widgetHiddenHandler[parent] then
		for obj in pairs(lib.widgetHiddenHandler[parent]) do
			if not lib.widgetsVisible[obj] then
				widgetUpdate(obj)
			end
		end
	else
		for widget, num in pairs(lib.widgetsNum) do
			for i = 1, num do
				hobj = _G["LibBlueOption10"..widget..i]
				if not lib.widgetsVisible[hobj] and hobj:GetParent():IsVisible() and hobj.hidden and not hobj:IsVisible() then
					widgetUpdate(hobj)
				end
			end
		end
	end
end

function lib:GetObjectElementValue(obj, element)
	if type(obj[element]) == "function" then
		return obj[element](obj.arg1, obj.arg2, obj.arg3, obj.arg4, obj.arg5)
	elseif obj[element] then
		return true
	else
		return nil
	end
end

function lib:GetStringToNumber(text)
	if type(text) == "string" then
		local n1, n2 = text:match("([0-9]+)%.([0-9]+)")
		if n1 and n2 then
			n1 = n1.."."..n2
			return tonumber(n1)
		else
			n1 = text:match("%.([0-9]+)")
			if n1 then
				return tonumber("0."..n1)
			else
				return tonumber(text:match("([0-9]+)") or "")
			end
		end
	elseif type(text) == "number" then
		return text
	else
		return nil
	end
end