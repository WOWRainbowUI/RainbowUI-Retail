local widget, version = "Media", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local type = _G.type
local CreateFrame = _G.CreateFrame
local PlaySound = _G.PlaySound
local PlaySoundFile = _G.PlaySoundFile
local menu = LibBlueOption10MediaMenu or nil
local SM = LibStub("LibSharedMedia-3.0", true)
local BUTTON_WIDTH = 90
local BUTTON_HEIGHT = 16

local function update(self)
	if self then
		self.value, self.type = self:GetValue()
		self.type = (self.type or ""):lower()
		self.texture:Hide()
		self.textureBG:Hide()
		if SM and SM.MediaTable[self.type] and self.value then
			if self.type == "statusbar" then
				self.text:SetFont(STANDARD_TEXT_FONT, 12)
				self.texture:SetTexture(SM:Fetch("statusbar", self.value))
				self.texture:SetVertexColor(0, 1, 0)
				self.texture:Show()
				self.textureBG:Show()
			elseif self.type == "sound" then
				self.text:SetFont(STANDARD_TEXT_FONT, 12)
			elseif self.type == "font" then
				self.text:SetFont(SM:Fetch("font", self.value), 12)
			else
				self.type = nil
			end
			if self.type and SM.MediaTable[self.type] then
				if SM.MediaTable[self.type][self.value] then
					self.valuetext = self.value
				elseif SM.DefaultMedia[self.type] then
					self.valuetext = SM.DefaultMedia[self.type]
				else
					self.valuetext = ""
				end
				self.valuetext = self.valuetext:gsub("Blizzard: ", "")
				self.text:SetText(self.valuetext)
			else
				self.text:SetText("")
			end
		else
			self.type = nil
			self.text:SetText("")
		end
	end
	if menu then
		menu:SetMenu(nil)
	end
end

local function createListFrame()
	if not menu then
		menu = LBO:CreateDropDownMenu(widget, "TOOLTIP")
		menu.buttons = {}
	end
end

local function listButtonOnEnter(button)
	if menu.type == "statusbar" then
		button.texture:SetDesaturated(nil)
		button.texture:SetVertexColor(1, 1, 0)
	else
		button.texture:Show()
	end
end

local function listButtonOnLeave(button)
	if menu.type == "statusbar" then
		if menu.value == button.value then
			button.texture:SetDesaturated(nil)
			button.texture:SetVertexColor(0, 1, 0)
		else
			button.texture:SetDesaturated(true)
			button.texture:SetVertexColor(1, 1, 1)
		end
	else
		button.texture:Hide()
	end
end

local function listButtonOnClick(button)
	if menu.type == "sound" then
		PlaySoundFile(SM:Fetch("sound", button.value))
	else
--		PlaySound("igMainMenuOptionCheckBoxOff")
	end
	menu.parent:SetValue(button.value)
end

local function createListButton(idx)
	if not menu.buttons[idx] then
		menu.buttons[idx] = CreateFrame("Button", "menuButton"..idx, menu)
		menu.buttons[idx]:Hide()
		menu.buttons[idx]:SetID(idx)
		menu.buttons[idx]:SetWidth(BUTTON_WIDTH)
		menu.buttons[idx]:SetHeight(BUTTON_HEIGHT)
		menu.buttons[idx]:SetNormalTexture("")
		menu.buttons[idx]:SetHighlightTexture("")
		menu.buttons[idx].texture = menu.buttons[idx]:CreateTexture(nil, "BACKGROUND")
		menu.buttons[idx].texture:SetAllPoints()
		menu.buttons[idx].text = menu.buttons[idx]:CreateFontString(nil, "BACKGROUND")
		menu.buttons[idx].text:SetPoint("LEFT", 2, 0)
		menu.buttons[idx].text:SetPoint("RIGHT", -2, 0)
		menu.buttons[idx].text:SetJustifyH("CENTER")
		menu.buttons[idx]:SetScript("OnEnter", listButtonOnEnter)
		menu.buttons[idx]:SetScript("OnLeave", listButtonOnLeave)
		menu.buttons[idx]:SetScript("OnClick", listButtonOnClick)
		menu.buttons[idx]:SetPoint("TOPLEFT", 10, -10)
	end
	return menu.buttons[idx]
end

local function setListButton(button, idx)
	button.value = menu.list[button:GetID()]
	if menu.type == "statusbar" then
		button.text:SetFont(STANDARD_TEXT_FONT, 11)
		button.texture:SetTexture(SM:Fetch("statusbar", button.value))
		button.texture:SetBlendMode("DISABLE")
		if menu.value == button.value then
			button.texture:SetDesaturated(nil)
			button.texture:SetVertexColor(0, 1, 0)
		else
			button.texture:SetDesaturated(true)
			button.texture:SetVertexColor(1, 1, 1)
		end
		button.text:SetTextColor(1, 1, 1)
		button.texture:Show()
	else
		button.texture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		button.texture:SetBlendMode("ADD")
		button.texture:SetVertexColor(1, 1, 1)
		button.texture:Hide()
		if menu.type == "font" then
			button.text:SetFont(SM:Fetch("font", button.value), 11)
		else
			button.text:SetFont(STANDARD_TEXT_FONT, 11)
		end
		button.text:SetTextColor(1, 1, menu.value == button.value and 0 or 1)
	end
	button.text:SetShadowColor(0, 0, 0)
	button.text:SetShadowOffset(1, -1)
	button.text:SetText(button.value:gsub("Blizzard: ", "") or "")
	if idx > 1 then
		button:ClearAllPoints()
		if menu.listNum < 11 then
			button:SetPoint("TOP", menu.buttons[idx - 1], "BOTTOM", 0, -2)
		elseif mod(idx, ceil(menu.listNum / 4)) == 1 then
			button:SetPoint("LEFT", menu.buttons[idx - ceil(menu.listNum / 4)] , "RIGHT", 2, 0)
		else
			button:SetPoint("TOP", menu.buttons[idx - 1] , "BOTTOM", 0, -2)
		end
	end
	button:Show()
end

local function hide(self)
	if not self.type then
		if menu then
			menu:SetMenu(nil)
		end
		return true
	elseif menu and menu.parent == self then
		menu:SetMenu(nil)
		return true
	end
	return nil
end

local function click(self)
	createListFrame()
	if hide(self) then
		return nil
	else
		menu.list = SM:List(self.type)
		if type(menu.list) == "table" then
			menu.listNum = #menu.list
		else
			menu.listNum = 0
		end
		if menu.listNum > 0 then
			menu:SetMenu(self)
			menu.type = self.type
			menu.value = self.value
			for i = 1, menu.listNum do
				setListButton(createListButton(i), i)
			end
			for i = menu.listNum + 1, #menu.buttons do
				menu.buttons[i]:Hide()
			end
			if menu.listNum < 11 then
				menu:SetWidth(BUTTON_WIDTH + 20)
				menu:SetHeight(menu.listNum * BUTTON_HEIGHT + 2 * (menu.listNum - 1) + 20)
			else
				menu:SetWidth(BUTTON_WIDTH * 4 + 26)
				menu:SetHeight(BUTTON_HEIGHT * ceil(menu.listNum / 4) + 2 * (ceil(menu.listNum / 4) - 1) + 20)
			end
			menu:Show()
		else
			menu:SetMenu(nil)
		end
		return true
	end
end

local function disable(self)
	self:DropdownDisable()
	self.texture:SetAlpha(0.5)
end

local function enable(self)
	self:DropdownEnable()
	self.texture:SetAlpha(1)
end

LBO:RegisterWidget(widget, version, function(self, name)
	LBO:CreateDropDown(self, true, click)
	self.texture = self.over:CreateTexture(nil, "ARTWORK")
	self.texture:SetPoint("TOPLEFT", 7, -3)
	self.texture:SetPoint("BOTTOMRIGHT", 3, 3)
	self.textureBG = self.over:CreateTexture(nil, "BORDER")
	self.textureBG:SetTexture(0, 0, 0)
	self.textureBG:SetAllPoints(self.texture)
	self.Setup = update
	self.DropdownDisable = self.Disable
	self.DropdownEnable = self.Enable
	self.Enable = enable
	self.Disable = disable
end)