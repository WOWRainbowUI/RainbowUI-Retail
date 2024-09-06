local widget, version = "Tab", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local type = _G.type
local CreateFrame = _G.CreateFrame
local OFFSET_X = -10
local OFFSET_Y = 4

local function selectTab(self, idx)
	if idx and self.buttons[idx] then
		self.selected = idx
		PanelTemplates_SetTab(self, idx)
		if type(self.buttons[idx].func) == "function" then
			self.buttons[idx].func(idx, self.arg1, self.arg2, self.arg3)
		end
	end
end

local function getSelectedTab(self)
	return self.selected
end

local function resizeLine(self, p, v, width)
	local t = 0
	for i = p, v do
		t = t + self.buttons[i]:GetWidth() + OFFSET_X
	end
	t = (width - t) / (v - p + 1)
	for i = p, v do
		PanelTemplates_TabResize(self.buttons[i], t)
	end
end

local function onUpdate(self)
	self:SetScript("OnUpdate", nil)
	PanelTemplates_TabResize(self.buttons[1], 0)
	local w, h = self.buttons[1]:GetWidth() + OFFSET_X, 0
	local width, p = self:GetWidth() + OFFSET_X, 1
	for i = 2, self.num do
		PanelTemplates_TabResize(self.buttons[i], 0)
		w = w + self.buttons[i]:GetWidth() + OFFSET_X
		self.buttons[i]:ClearAllPoints()
		if w < width then
			self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i - 1], "TOPRIGHT", OFFSET_X, 0)
		else
			h = h + 1
			self.buttons[i]:SetPoint("TOPLEFT", self.buttons[p], "BOTTOMLEFT", 0, OFFSET_Y)
			--if w > width then
				resizeLine(self, p, i - 1, width)
			--end
			w, p = self.buttons[i]:GetWidth() + OFFSET_X, i
		end
	end
	resizeLine(self, p, self.num, width)
	h = h + 1
	self:SetHeight(h * self.buttons[1]:GetHeight() - (h - 2) * OFFSET_Y)
end

local function onShow(self)
	self:SetScript("OnUpdate", onUpdate)
end

local function onHide(self)
	self:SetScript("OnUpdate", nil)
end

local function buttonOnClick(self)
	selectTab(self:GetParent(), self:GetID())
end

local function createButton(self, i)
	self.buttons[i] = CreateFrame("Button", self:GetName().."Tab"..i, self, "OptionsFrameTabButtonTemplate")
	self.buttons[i]:SetPoint("TOPLEFT", self.buttons[i - 1], "TOPRIGHT", -12, 0)
	self.buttons[i]:SetID(i)
	self.buttons[i]:SetText(self.get[i].name or "")
	self.buttons[i]:SetScript("OnClick", buttonOnClick)
	self.buttons[i].func = self.get[i].func
	PanelTemplates_TabResize(self.buttons[i], 0)
end

LBO:RegisterWidget(widget, version, function(self, name)
	if type(self.get) ~= "table" or #self.get == 0 then return end
	self:SetHeight(1)
	self.num, self.buttons = #self.get, {}
	for i = 1, self.num do
		createButton(self, i)
	end
	self.buttons[1]:ClearAllPoints()
	self.buttons[1]:SetPoint("TOPLEFT", 0, 0)
	PanelTemplates_SetNumTabs(self, self.num)
	self.SetValue = selectTab
	self.GetValue = getSelectedTab
	if self.get.fixed then return end
	self:SetScript("OnSizeChanged", onShow)
	self:SetScript("OnShow", onShow)
	self:SetScript("OnHide", onHide)
end)