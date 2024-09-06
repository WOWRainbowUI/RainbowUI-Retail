local widget, version = "List", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local type = _G.type
local ipairs = _G.ipairs
local CreateFrame = _G.CreateFrame
local temp

local backdrop = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local function listUpdate(self)
	if type(self.list) ~= "table" or #self.list == 0 then
		self.selected = nil
		FauxScrollFrame_SetOffset(self, 0)
		for _, button in ipairs(self.buttons) do
			button:Hide()
		end
		FauxScrollFrame_Update(self, 0, #self.buttons, 18)
	else
		if #self.buttons >= #self.list then
			FauxScrollFrame_SetOffset(self, 0)
		end
		self.offset = FauxScrollFrame_GetOffset(self)
		for i, button in ipairs(self.buttons) do
			i = i + self.offset
			if self.list[i] then
				button:SetID(i)
				button:SetText(self.list[i])
				button:Show()
				if self.selected == i then
					button:SetHighlightFontObject("GameFontNormal")
					button:LockHighlight()
				else
					button:SetHighlightFontObject("GameFontHighlight")
					button:UnlockHighlight()
				end
			else
				button:Hide()
			end
		end
		FauxScrollFrame_Update(self, #self.list, #self.buttons, 18)
	end
end

local function onListScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 18, listUpdate)
end

local function getValue(self)
	return self.scrollframe.selected
end

local function setValue(self, value)
	if type(value) == "number" and self.scrollframe.list and self.scrollframe.list[value] then
		if self.scrollframe.selected ~= value then
			self.scrollframe.selected = value
			listUpdate(self.scrollframe)
		end
	elseif self.scrollframe.selected then
		self.scrollframe.selected = nil
		listUpdate(self.scrollframe)
	end
end

local function setup(self)
	if type(self.get) == "function" then
		self.scrollframe.list, self.scrollframe.unlock = self.get(self.arg1, self.arg2, self.arg3, self.arg4, self.arg5)
	else
		self.scrollframe.list, self.scrollframe.unlock = self.get, nil
	end
	if type(self.scrollframe.list) == "table" then
		if self.prev_numList ~= #self.scrollframe.list then
			self.scrollframe.selected = nil
			self.prev_numList = #self.scrollframe.list
		end
	else
		self.scrollframe.list = nil
		self.scrollframe.selected = nil
		self.prev_numList = 0
	end
	listUpdate(self.scrollframe)
end

local function enable(self)
	self.title:SetTextColor(1, 1, 1)
	for _, button in ipairs(self.scrollframe.buttons) do
		button:Enable()
	end
end

local function disable(self)
	self.title:SetTextColor(0.58, 0.58, 0.58)
	for _, button in ipairs(self.scrollframe.buttons) do
		button:Disable()
	end
end

local function buttonOnClick(self)
	if self:GetParent().selected ~= self:GetID() then
		self:GetParent().selected = self:GetID()
	elseif self:GetParent().unlock then
		self:GetParent().selected = nil
	else
		return nil
	end
	listUpdate(self:GetParent())
	if type(self:GetParent():GetParent().set) == "function" then
		self = self:GetParent():GetParent()
		self.set(self.scrollframe.selected, self.arg1, self.arg2, self.arg3, self.arg4, self.arg5)
	end
end

LBO:RegisterWidget(widget, version, function(self, name)
	self:SetWidth(180)
	self:SetHeight(204)
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.title:SetPoint("TOPLEFT", 0, 0)
	self.title:SetPoint("TOPRIGHT", 0, 0)
	self.scrollframe = CreateFrame("ScrollFrame", name.."Scroll", self, "ListScrollFrameTemplate" and BackdropTemplateMixin and "BackdropTemplate")
	self.scrollframe:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -1)
	self.scrollframe:SetPoint("BOTTOMRIGHT", 0, 0)
	self.scrollframe:SetBackdrop(backdrop)
	self.scrollframe:SetBackdropBorderColor(0.58, 0.58, 0.58)
	self.scrollframe:DisableDrawLayer("BACKGROUND")
	self.scrollframe.Hide = self.scrollframe.Show
	self.scrollframe.bar = _G[name.."ScrollScrollBar"]
	self.scrollframe.bar:ClearAllPoints()
	self.scrollframe.bar:SetPoint("TOPRIGHT", -4, -20)
	self.scrollframe.bar:SetPoint("BOTTOMRIGHT", -4, 19)
	self.scrollframe.up = _G[name.."ScrollScrollBarScrollUpButton"]
	self.scrollframe.down = _G[name.."ScrollScrollBarScrollDownButton"]
	temp = self.scrollframe.bar:CreateTexture(nil, "BACKGROUND")
	temp:SetTexture(0, 0, 0, 0.5)
	temp:SetPoint("TOP", self.scrollframe.up, "BOTTOM", 0, -3)
	temp:SetPoint("BOTTOM", self.scrollframe.down, "TOP", 0, 3)
	temp:SetWidth(8)
	temp = self.scrollframe.bar:CreateTexture(nil, "BACKGROUND")
	temp:SetTexture(1, 1, 1, 0.2)
	temp:SetPoint("TOP", self.scrollframe.up, "BOTTOM", 0, -4)
	temp:SetPoint("BOTTOM", self.scrollframe.down, "TOP", 0, 4)
	temp:SetWidth(6)
	self.scrollframe.buttons = {}
	for i = 1, 10 do
		self.scrollframe.buttons[i] = CreateFrame("Button", name.."List"..i, self.scrollframe, "OptionsListButtonTemplate")
		self.scrollframe.buttons[i]:Hide()
		self.scrollframe.buttons[i]:SetScript("OnClick", buttonOnClick)
		self.scrollframe.buttons[i]:SetNormalFontObject("GameFontHighlight")
		self.scrollframe.buttons[i]:SetDisabledFontObject("GameFontDisable")
		self.scrollframe.buttons[i]:SetWidth(0)
		self.scrollframe.buttons[i]:SetHeight(18)
		if i == 1 then
			self.scrollframe.buttons[i]:SetPoint("TOPLEFT", self.scrollframe, "TOPLEFT", 8, -6)
			self.scrollframe.buttons[i]:SetPoint("TOPRIGHT", self.scrollframe, "TOPRIGHT", -16, 0)
		else
			self.scrollframe.buttons[i]:SetPoint("TOPLEFT", self.scrollframe.buttons[i - 1], "BOTTOMLEFT", 0, 0)
			self.scrollframe.buttons[i]:SetPoint("TOPRIGHT", self.scrollframe.buttons[i - 1], "BOTTOMRIGHT", 0, 0)
		end
	end
	self.scrollframe:SetScript("OnVerticalScroll", onListScroll)
	self.Setup = setup
	self.Enable = enable
	self.Disable = disable
	self.GetValue = getValue
	self.SetValue = setValue
end)