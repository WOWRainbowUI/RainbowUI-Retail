local widget, version = "ShowHide", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local function enable(self)
	self.visible:Show()
end

local function disable(self)
	self.visible:Hide()
end

LBO:RegisterWidget(widget, version, function(self, name)
	self.visible = CreateFrame("Frame", nil, self)
	self.visible:SetAllPoints()
	self.Enable = enable
	self.Disable = disable
	enable(self)
end)