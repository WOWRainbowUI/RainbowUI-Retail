local widget, version = "DropDown", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local type = _G.type
local max = _G.math.max
local CreateFrame = _G.CreateFrame
local menu = LibBlueOption10DropDownMenu or nil

local function update(self)
	if self then
		self.value, self.list = self:GetValue()
		if type(self.list) == "table" and type(self.value) == "number" and self.list[self.value] then
			self.text:SetText(self.list[self.value])
		else
			self.text:SetText(self.value)
		end
	end
	if menu then
		menu:SetMenu(nil)
	end
end

local function listButtonOnClick(button)
--	PlaySound("igMainMenuOptionCheckBoxOff")
	if button:GetID() > 0 then
		if type(menu.value) == "number" then
			menu.parent:SetValue(button:GetID())
		else
			menu.parent:SetValue(menu.list[button:GetID()])
		end
	elseif menu then
		menu:SetMenu(nil)
	end
end

local function createListButton(idx)
	menu.buttons[idx] = CreateFrame("Button", "menuButton"..idx, menu)
	menu.buttons[idx]:SetID(idx)
	menu.buttons[idx]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	menu.buttons[idx]:RegisterForClicks("LeftButtonUp")
	menu.buttons[idx]:SetHeight(16)
	menu.buttons[idx]:SetScript("OnClick", listButtonOnClick)
	menu.buttons[idx].checked = menu.buttons[idx]:CreateTexture(nil, "OVERLAY")
	menu.buttons[idx].checked:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	menu.buttons[idx].checked:SetPoint("LEFT", 10, 0)
	menu.buttons[idx].checked:SetWidth(20)
	menu.buttons[idx].checked:SetHeight(20)
	menu.buttons[idx].checked:SetAlpha(0)
	menu.buttons[idx].text = menu.buttons[idx]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmallLeft")
	menu.buttons[idx].text:SetPoint("LEFT", menu.buttons[idx].checked, "RIGHT", 0, 0)
	menu.buttons[idx].text:SetPoint("RIGHT", menu.buttons[idx], "RIGHT", -10, 0)
	if idx > 1 then
		menu.buttons[idx]:SetPoint("TOPLEFT", menu.buttons[idx - 1], "BOTTOMLEFT", 0, 0)
		menu.buttons[idx]:SetPoint("TOPRIGHT", menu.buttons[idx - 1], "BOTTOMRIGHT", 0, 0)
	elseif idx == 1 then
		menu.buttons[idx]:SetPoint("TOPLEFT", menu, "TOPLEFT", 10, -10)
		menu.buttons[idx]:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -10, -10)
	else
		menu.buttons[idx]:SetPoint("BOTTOMLEFT", menu, "BOTTOMLEFT", 10, 10)
		menu.buttons[idx]:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", -10, 10)
	end
end

local function createListFrame()
	if not menu then
		menu = LBO:CreateDropDownMenu(widget, "TOOLTIP")
		menu.buttons = {}
		createListButton(0)
		menu.buttons[0].text:SetText(CLOSE)
		menu.minWidth = menu.buttons[0].text:GetStringWidth()
	end
end

local function hide(self)
	if menu and menu.parent == self then
		menu:SetMenu(nil)
		return true
	end
	return nil
end

local function setListButton(idx, name)
	if not menu.buttons[idx] then
		createListButton(idx)
	end
	if menu.value == idx or menu.value == name then
		menu.buttons[idx].checked:SetAlpha(1)
	else
		menu.buttons[idx].checked:SetAlpha(0)
	end
	menu.buttons[idx].text:SetText(name)
	menu.buttons[idx]:Show()
	menu.displayWidth = max(menu.displayWidth, menu.buttons[idx].text:GetStringWidth() or 0)
end

local function click(self)
	createListFrame()
	if hide(self) then
		return nil
	else
		menu:SetMenu(self)
		menu.value, menu.list = self:GetValue()
		menu.displayWidth = menu.minWidth
		if type(menu.list) == "table" then
			menu.listNum = #menu.list
			for i = 1, menu.listNum do
				setListButton(i, menu.list[i])
			end
		else
			menu.listNum = 0
		end
		for i = menu.listNum + 1, #menu.buttons do
			menu.buttons[i]:Hide()
		end
		menu:SetWidth(max(menu.displayWidth + 80, self:GetWidth() - 10))
		menu:SetHeight(menu.listNum * 16 + 36)
		menu:Show()
		return true
	end
end

LBO:RegisterWidget(widget, version, function(self, name)
	LBO:CreateDropDown(self, true, click)
	self.Setup = update
end)