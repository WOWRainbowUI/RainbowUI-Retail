local MAJOR_VERSION, MINOR_VERSION = "LibEnhanceDDMenu-1.0", 5
local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type = _G.type
local pairs = _G.pairs
local max = _G.math.max
local ceil = _G.math.ceil

local securemenus = {
	["SET_FOCUS"] = true,
	["CLEAR_FOCUS"] = true,
}
local blizzardDropdowns = {
	"^PlayerFrameDropDown$",
	"^TargetFrameDropDown$",
	"^FocusFrameDropDown$",
	"^PartyMemberFrame(%d+)DropDown$",
	"^FriendsDropDown$",
	"^CompactRaidFrameMember(%d+)DropDown$",
	"^CompactPartyFrameMember(.+)DropDown$",
	"^ArenaEnemyFrame(%d+)DropDown$",
	"^ArenaEnemyFrame(%d+)PetFrameDropDown$",
}

lib.buttons = lib.buttons or {}
lib.unitmenus = lib.unitmenus or {}
lib.disableUnitMenu = lib.disableUnitMenu or {}

local function buttonOnEnter(self)
	UIDropDownMenu_StopCounting(self:GetParent())
end

local function buttonOnLeave(self)
	UIDropDownMenu_StartCounting(self:GetParent())
end

local function buttonPostClick()
	if DropDownList1:IsShown() then
		CloseDropDownMenus()
	end
end

local function buttonOnClick(self)
	if self.click then
		self.click(OPEN_DROPDOWNMENUS[1].which, DropDownList1._LEDDM.unitmenu.unit, DropDownList1._LEDDM.unitmenu.name, DropDownList1._LEDDM.unitmenu.server)
	end
end

local info = { notCheckable = 1, arg1 = "LEDDM_KillMe" }

local function setButton(name, func)
	lib.buttonIndex = lib.buttonIndex + 1
	if not lib.buttons[lib.buttonIndex] then
		lib.buttons[lib.buttonIndex] = CreateFrame("Button", nil, DropDownList1)
		lib.buttons[lib.buttonIndex]:SetNormalTexture(1, 1, 1)
		lib.buttons[lib.buttonIndex]:SetFrameLevel(DropDownList1:GetFrameLevel() + 2)
		lib.buttons[lib.buttonIndex]:SetPoint("TOP", lib.buttonIndex == 1 and DropDownList1Button1 or lib.buttons[lib.buttonIndex - 1], "BOTTOM", 0, 0)
		lib.buttons[lib.buttonIndex]:SetPoint("LEFT", DropDownList1, "LEFT", 15, 0)
		lib.buttons[lib.buttonIndex]:SetPoint("RIGHT", DropDownList1, "RIGHT", -13, 0)
		lib.buttons[lib.buttonIndex]:SetHeight(16)
		lib.buttons[lib.buttonIndex]:SetNormalFontObject("GameFontHighlightSmallLeft")
		lib.buttons[lib.buttonIndex]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		lib.buttons[lib.buttonIndex]:SetScript("OnHide", lib.buttons[lib.buttonIndex].Hide)
		lib.buttons[lib.buttonIndex]:SetScript("OnEnter", buttonOnEnter)
		lib.buttons[lib.buttonIndex]:SetScript("OnLeave", buttonOnLeave)
		lib.buttons[lib.buttonIndex]:SetScript("OnClick", buttonOnClick)
		lib.buttons[lib.buttonIndex]:SetScript("PostClick", buttonPostClick)
	end
	lib.buttons[lib.buttonIndex].click = func
	lib.buttons[lib.buttonIndex]:Show()
	lib.buttons[lib.buttonIndex]:SetText(name)
	if (info.text or ""):len() < name:len() then
		info.text = name
	end
end

if not DropDownList1._LEDDM then
	DropDownList1._LEDDM = CreateFrame("Frame", nil, DropDownList1)
	DropDownList1._LEDDM:RegisterEvent("PLAYER_REGEN_DISABLED")
	DropDownList1._LEDDM:SetScript("OnEvent", buttonPostClick)
	hooksecurefunc("UnitPopup_ShowMenu", function(dropdownMenu)
		if UIDROPDOWNMENU_MENU_LEVEL == 1 then
			DropDownList1._LEDDM.unitmenu = dropdownMenu
			DropDownList1._LEDDM.unitmenuName = dropdownMenu:GetName()
		end
	end)
	WorldFrame:HookScript("OnMouseDown", buttonPostClick)
end

if not lib.newpoints then
	lib.newpoints = {}
	hooksecurefunc(DropDownList1, "SetPoint", function(self)
		if self:IsVisible() and self._LEDDM.visibleMenu and self._LEDDM.newPoint then
			self:ClearAllPoints()
			if self._LEDDM.newPoint[1] == "cursor" then
				local s = UIParent:GetScale()
				local x, y = GetCursorPosition()
				self._LEDDM.SetPoint(self, "TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
			else
				self._LEDDM.SetPoint(self, unpack(self._LEDDM.newPoint))
			end
		end
		self._LEDDM.newPoint = nil
	end)
end

DropDownList1._LEDDM:SetScript("OnShow", function(self)
	self.visibleMenu = UIDROPDOWNMENU_OPEN_MENU
	if lib.newpoints[self.visibleMenu] and lib.newpoints[self.visibleMenu].show() then
		self.newPoint = lib.newpoints[self.visibleMenu].point
	else
		self.newPoint = nil
	end
	if self.unitmenu and OPEN_DROPDOWNMENUS[1] and OPEN_DROPDOWNMENUS[1].which == self.unitmenu.which and OPEN_DROPDOWNMENUS[1].unit == self.unitmenu.unit then
		if DropDownList1Button1:IsShown() and DropDownList1Button1:GetText() == self.unitmenu.name then
			lib.buttonIndex, lib.text = 0
			if lib.unitmenus[self.unitmenu.which] then
				for p, v in pairs(lib.unitmenus[self.unitmenu.which]) do
					if v.view(self.unitmenu.which, self.unitmenu.unit, self.unitmenu.name, self.unitmenu.server) then
						setButton(p, v.click)
					end
				end
			end
			self.safemenu = true
			if self.unitmenuName then
				for i = 1, #blizzardDropdowns do
					if self.unitmenuName:find(blizzardDropdowns[i]) then
						self.safemenu = nil
						break
					end
				end
			else
				self.safemenu = nil
				return
			end
			if lib.buttonIndex > 0 or next(lib.disableUnitMenu) then
				local prev = lib.buttons[lib.buttonIndex] or DropDownList1Button1
				local numButtons = lib.buttonIndex + 1
				if lib.buttonIndex > 0 and info.text then
					UIDropDownMenu_AddButton(info)
				end
				for i = 2, UIDROPDOWNMENU_MAXBUTTONS do
					button = _G["DropDownList1Button"..i]
					if button:IsShown() then
						if self.safemenu and securemenus[button.value] and button:GetText() == _G[button.value] then
							button:Hide()
						elseif self.safemenu and info.text and button:GetText() == info.text and button.arg1 == info.arg1 then
							button:Hide()
						elseif lib.disableUnitMenu[button.value] then
							button:Hide()
						else
							button:ClearAllPoints()
							button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
							prev = button
							numButtons = numButtons + 1
						end
					else
						break
					end
				end
				DropDownList1:SetHeight((numButtons * UIDROPDOWNMENU_BUTTON_HEIGHT) + (UIDROPDOWNMENU_BORDER_HEIGHT * 2))
				return
			end
		end
	end
	self.unitmenu = nil
end)

DropDownList1._LEDDM:SetScript("OnHide", function(self)
	self.unitmenu, self.newPoint = nil
	self.hidefunc = lib.newpoints[self.visibleMenu] and lib.newpoints[self.visibleMenu].hide
	self.visibleMenu = nil
	if self.hidefunc then
		self.hidefunc()
	end
	self.hidefunc = nil
	for _, btn in pairs(lib.buttons) do
		btn:Hide()
	end
end)

for _, btn in pairs(lib.buttons) do
	btn:SetScript("OnEnter", buttonOnEnter)
	btn:SetScript("OnLeave", buttonOnLeave)
	btn:SetScript("OnClick", buttonOnClick)
	btn:SetScript("PostClick", buttonPostClick)
end

local dropDowns, dropDownID = { 2 }

local function hookDropDownButton(self)
	dropDownID = self:GetParent():GetID()
	while _G["DropDownList"..self:GetParent():GetID().."Button"..dropDowns[dropDownID]] do
		_G["DropDownList"..self:GetParent():GetID().."Button"..dropDowns[dropDownID]]:HookScript("OnEnter", hookDropDownButton)
		dropDowns[dropDownID] = dropDowns[dropDownID] + 1
	end
	if self.tooltipTitle == "_hyperlink" then
		if type(self.tooltipText) == "string" then
			if self.tooltipText:find("[a-z]+:[%-]-%d+") then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(self.tooltipText)
				GameTooltip:Show()
			else
				GameTooltip:Hide()
			end
		elseif type(self.tooltipText) == "function" then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			self.tooltipText(self.arg1, self.arg2)
			GameTooltip:Show()
		else
			GameTooltip:Hide()
		end
	end
	dropDownID = dropDownID + 1
	if _G["DropDownList"..dropDownID] and not dropDowns[dropDownID] then
		dropDowns[dropDownID] = 1
		_G["DropDownList"..dropDownID.."Button1"]:HookScript("OnEnter", hookDropDownButton)
	end
end

DropDownList1Button1:HookScript("OnEnter", hookDropDownButton)

local function returntrue() return true end

function lib:RegisterUnitMenu(which, name, click, view)
	if UnitPopupMenus[which] and name then
		lib.unitmenus[which] = lib.unitmenus[which] or {}
		lib.unitmenus[which][name] = lib.unitmenus[which][name] or {}
		lib.unitmenus[which][name].click = type(click) == "function" and click or nil
		lib.unitmenus[which][name].view = type(view) == "function" and view or returntrue
	end
end

function lib:RegisterNewPoint(menu, show, hide, ...)
	if type(menu) == "table" and menu.GetObjectType and not lib.newpoints[menu] then
		lib.newpoints[menu] = {
			show = type(show) == "function" and show or returntrue,
			hide = type(hide) == "function" and hide or nil,
			point = { ... },
		}
	end
end

function lib:DisableUnitMenu(menu)
	if UnitPopupMenus[menu] or UnitPopupButtons["LARGE_FOCUS"] then
		lib.disableUnitMenu[menu] = true
	end
end