local widget, version = "BasicTemplates", 1
local LBO = LibStub("LibBlueOption-1.0")
LBO.templates = LBO.templates or {}
if LBO.templates.version and LBO.templates.version >= version then return end
LBO.templates.version = version

local _G = _G
local type = _G.type
local pairs = _G.pairs
local CreateFrame = _G.CreateFrame

local editBoxBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = true, edgeSize = 1, tileSize = 5,
}

local function editBoxOnLeave(box)
	box:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
end

local function editBoxOnEnter(box)
	box:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
end

local function editBoxHasFocus(box)
	return LBO.templates.editBoxFocus == box
end

local function editBoxSetNumeric(box, state)
	box.numeric = state
end

local function editBoxGetValue(box)
	if box.numeric then
		return box:GetNumber() or 0
	else
		return (box:GetText() or ""):trim()
	end
end

local function editBoxSetValue(box, value)
	if box.numeric then
		box.prevalue = value or 0
		box:SetNumber(box.prevalue)
	else
		box.prevalue = (value or ""):trim()
		box:SetText(box.prevalue)
	end
end

local function editBoxFocusGained(box)
	LBO.templates.editBoxFocus = box
	box.prevalue = editBoxGetValue(box)
	if box.highlight then
		box:HighlightText()
	end
end

local function editBoxFocusLost(box)
	LBO.templates.editBoxFocus = nil
	if box.enterPress then
		editBoxSetValue(box, editBoxGetValue(box))
	else
		editBoxSetValue(box, box.prevalue or "")
	end
end

local function editBoxOnEnterPressed(box)
	box.enterPress = true
	box:ClearFocus()
	box.enterPress = nil
	if type(box.Update) == "function" then
		box:Update(editBoxGetValue(box))
	end
end

local function editBoxEnable(box)
	box:EnableMouse(true)
	box:SetTextColor(1, 1, 1)
end

local function editBoxDisable(box)
	box:EnableMouse(nil)
	editBoxOnLeave(box)
	box:ClearFocus()
	box:SetTextColor(0.58, 0.58, 0.58)
end

function LBO:CreateEditBox(parent, updatefunc, fontObject, justifyH, autoHighlight)
	local box = CreateFrame("EditBox", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	box:SetAutoFocus(nil)
	box:SetFontObject(fontObject or "GameFontHighlight")
	box:SetJustifyH(justifyH or "CENTER")
	box:EnableMouse(true)
	box:SetHeight(18)
	box:SetBackdrop(editBoxBackdrop)
	box:SetBackdropColor(0, 0, 0, 0.5)
	box:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
	box:SetScript("OnEnter", editBoxOnEnter)
	box:SetScript("OnLeave", editBoxOnLeave)
	box:SetScript("OnEditFocusGained", editBoxFocusGained)
	box:SetScript("OnEditFocusLost", editBoxFocusLost)
	box:SetScript("OnEnterPressed", editBoxOnEnterPressed)
	box:SetScript("OnEscapePressed", EditBox_ClearFocus)
	box:SetScript("OnHide", EditBox_ClearFocus)
	box.highlight = autoHighlight
	box.HasFocus = editBoxHasFocus
	box.SetNumeric = editBoxSetNumeric
	box.GetValue = editBoxGetValue
	box.SetValue = editBoxSetValue
	box.Enable = editBoxEnable
	box.Disable = editBoxDisable
	box.Update = updatefunc
	return box
end

local function dropdownOnHide(self)
	for menu in pairs(LBO.widgetMenus) do
		if menu.parent == self or menu.parent == self:GetParent() then
			menu.parent = nil
			menu:Hide()
		end
	end
end

local function dropDownEnable(self)
	self.button:Enable()
	self.text:SetTextColor(1, 1, 1)
	self.title:SetTextColor(1, 1, 1)
end

local function dropDownDisable(self)
	self.button:Disable()
	self.text:SetTextColor(0.58, 0.58, 0.58)
	self.title:SetTextColor(0.58, 0.58, 0.58)
	dropdownOnHide(self)
end

local function dropdownOnClick(self)
	if self.func then
		if self.func(self:GetParent()) then
			--PlaySound("igMainMenuOptionCheckBoxOn")
		else
			--PlaySound("igMainMenuOptionCheckBoxOff")
		end
	end
end

function LBO:CreateDropDown(parent, notNewCreate, clickfunc)
	local dropdown
	if notNewCreate then
		dropdown = parent
	else
		dropdown = CreateFrame("Frame", nil, parent)
	end
	dropdown.left = dropdown:CreateTexture(nil, "BACKGROUND")
	dropdown.left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	dropdown.left:SetTexCoord(0, 0.1953125, 0, 1)
	dropdown.left:SetPoint("TOPLEFT", -16, 0)
	dropdown.left:SetWidth(25)
	dropdown.left:SetHeight(64)
	dropdown.right = dropdown:CreateTexture(nil, "BACKGROUND")
	dropdown.right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	dropdown.right:SetTexCoord(0.8046875, 1, 0, 1)
	dropdown.right:SetPoint("TOPRIGHT", 16, 0)
	dropdown.right:SetWidth(25)
	dropdown.right:SetHeight(64)
	dropdown.middle = dropdown:CreateTexture(nil, "BACKGROUND")
	dropdown.middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame")
	dropdown.middle:SetTexCoord(0.1953125, 0.8046875, 0, 1)
	dropdown.middle:SetPoint("TOPLEFT", dropdown.left, "TOPRIGHT", 0, 0)
	dropdown.middle:SetPoint("BOTTOMRIGHT", dropdown.right, "BOTTOMLEFT", 0, 0)
	dropdown.title = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	dropdown.title:SetPoint("TOP", dropdown, "TOP", 0, -2)
	dropdown.title:SetTextColor(1, 1, 1)
	dropdown.button = CreateFrame("Button", nil, dropdown)
	dropdown.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	dropdown.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	dropdown.button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
	dropdown.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	dropdown.button:SetPoint("TOPLEFT", dropdown.right, -15, -20)
	dropdown.button:SetWidth(22)
	dropdown.button:SetHeight(22)
	dropdown.button:RegisterForClicks("LeftButtonUp")
	dropdown.button:SetScript("OnClick", dropdownOnClick)
	dropdown.button.func = type(clickfunc) == "function" and clickfunc or nil
	dropdown.over = CreateFrame("Frame", nil, dropdown)
	dropdown.over:EnableMouse(true)
	dropdown.over:SetPoint("TOPLEFT", dropdown.left, 15, -20)
	dropdown.over:SetPoint("BOTTOMRIGHT", dropdown.button, "BOTTOMLEFT", 0, 0)
	dropdown.over:SetScript("OnHide", dropdownOnHide)
	dropdown.text = dropdown.over:CreateFontString(nil, "OVERLAY", "GameFontHighlightLeft")
	dropdown.text:SetPoint("LEFT", 12, 0)
	dropdown.text:SetPoint("RIGHT", 0, 0)
	dropdown.Disable = dropDownDisable
	dropdown.Enable = dropDownEnable
	return dropdown
end

local dropdownMenuBackdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, edgeSize = 26, tileSize = 32,
	insets = { left = 6, right = 6, top = 6, bottom = 6 },
}
local function dropdownMenuSetMenu(self, parent)
	self.parent = parent
	if parent then
		self:ClearAllPoints()
		if parent.button then
			self:SetPoint("TOPRIGHT", parent.button, "BOTTOMLEFT", 10, 0)
		else
			self:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, 0)
		end
	else
		self:Hide()
	end
end

function LBO:CreateDropDownMenu(name, strata)
	if _G["LibBlueOption10"..name.."Menu"] then
		return _G["LibBlueOption10"..name.."Menu"]
	else
		local menu = CreateFrame("Frame", "LibBlueOption10"..name.."Menu", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		menu:EnableMouse(true)
		menu:SetClampedToScreen(true)
		menu:SetFrameStrata(strata or "TOOLTIP")
		menu:Hide()
		menu:SetToplevel(true)
		menu:SetBackdrop(dropdownMenuBackdrop)
		menu:SetBackdropColor(0, 0, 0, 0.8)
		menu.SetMenu = dropdownMenuSetMenu
		LBO.widgetMenus[menu] = name
		return menu
	end
end