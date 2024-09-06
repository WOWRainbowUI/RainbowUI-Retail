local widget, version = "Button", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local function setSize(self, w, h)
	if width then
		self.SetWidth(self.button, width)
	end
	if height then
		self.SetHeight(self.button, height)
	end
end

local function click(self, button)
--	PlaySound("igMainMenuOptionCheckBoxOn")
	self = self:GetParent()
	if type(self.get) == "function" then
		self.get(button, self.arg1, self.arg2, self.arg3)
		self:Update()
	end
end

local function enable(self)
	self.button:Enable()
end

local function disable(self)
	self.button:Disable()
end

LBO:RegisterWidget(widget, version, function(self, name)
	self.button = CreateFrame("Button", name.."Button", self, "UIPanelButtonTemplate")
	self.button:RegisterForClicks("AnyUp")
	self.button:SetPoint("LEFT", 0, 0)
	self.button:SetPoint("RIGHT", 0, 0)
	self.button:SetWidth(0)
	self.button:SetHeight(24)
	self.button:SetScript("OnClick", click)
	self.title = self.button:GetFontString()
	self.Enable = enable
	self.Disable = disable
	self.SetSize = setSize
	self.GetValue = nil
	self.SetValue = nil
end)