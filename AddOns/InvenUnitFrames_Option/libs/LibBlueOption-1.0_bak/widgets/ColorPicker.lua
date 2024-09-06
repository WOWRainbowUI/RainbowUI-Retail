local widget, version = "ColorPicker", 1
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local _G = _G
local type = _G.type

local function update(self)
	self.color.r, self.color.g, self.color.b, self.color.a = self:GetValue()
	self.color:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a or 1)
end

local function setColor(self)
	local r, g, b = ColorPickerFrame:GetColorRGB()
	if self.color.a then
		local a = 1 - OpacitySliderFrame:GetValue()
		self.color:SetVertexColor(r, g, b, a)
		if type(self.set) == "function" then
			self.set(r, g, b, a, self.arg1, self.arg2, self.arg3)
		end
	else
		self.color:SetVertexColor(r, g, b, 1)
		if type(self.set) == "function" then
			self.set(r, g, b, self.arg1, self.arg2, self.arg3)
		end
	end
end

local function undoColor(self)
	self.color:SetVertexColor(self.color.r, self.color.g, self.color.b, self.color.a or 1)
	if type(self.set) == "function" then
		if self.color.a then
			self.set(self.color.r, self.color.g, self.color.b, self.color.a, self.arg1, self.arg2, self.arg3)
		else
			self.set(self.color.r, self.color.g, self.color.b, self.arg1, self.arg2, self.arg3)
		end
	end
end

local function movableColorPickerFrame()
	if ColorPickerFrameTitleMover then return end
	local colorPickerFrameDragStart = function() ColorPickerFrame:StartMoving() end
	local colorPickerFrameDragStop = function() ColorPickerFrame:StopMovingOrSizing() end
	ColorPickerFrame:SetMovable(true)
	local mover = CreateFrame("Frame", "ColorPickerFrameTitleMover", ColorPickerFrame)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", colorPickerFrameDragStart)
	mover:SetScript("OnDragStop", colorPickerFrameDragStop)
	mover:SetScript("OnHide", colorPickerFrameDragStop)
	mover:SetPoint("CENTER", ColorPickerFrame, "TOP", 0, -8)
	mover:SetWidth(130)
	mover:SetHeight(28)
	mover = CreateFrame("Frame", "ColorPickerFrameTopMover", ColorPickerFrame)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", colorPickerFrameDragStart)
	mover:SetScript("OnDragStop", colorPickerFrameDragStop)
	mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOPLEFT", 0, 0)
	mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "TOPRIGHT", 0, -15)
	mover = CreateFrame("Frame", "ColorPickerFrameLeftMover", ColorPickerFrame)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", colorPickerFrameDragStart)
	mover:SetScript("OnDragStop", colorPickerFrameDragStop)
	mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOPLEFT", 0, 0)
	mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMLEFT", 15, 0)
	mover = CreateFrame("Frame", "ColorPickerFrameRightMover", ColorPickerFrame)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", colorPickerFrameDragStart)
	mover:SetScript("OnDragStop", colorPickerFrameDragStop)
	mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOPRIGHT", -15, 0)
	mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", 0, 0)
	mover = CreateFrame("Frame", "ColorPickerFrameBottomMover", ColorPickerFrame)
	mover:EnableMouse(true)
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", colorPickerFrameDragStart)
	mover:SetScript("OnDragStop", colorPickerFrameDragStop)
	mover:SetPoint("TOPLEFT", ColorPickerFrame, "BOTTOMLEFT", 0, 8)
	mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "BOTTOMRIGHT", 0, 0)
end

local function hide()
	if ColorPickerFrame:IsVisible() and type(ColorPickerFrame.cancelFunc) == "function" then
		ColorPickerFrame.cancelFunc()
	end
	HideUIPanel(ColorPickerFrame)
end

local function click(self)
--	PlaySound("igMainMenuOptionCheckBoxOn")
	hide()
	self = self:GetParent()
	self.color.r, self.color.g, self.color.b, self.color.a = self:GetValue()
	movableColorPickerFrame()
	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	ColorPickerFrame.func = function() setColor(self) end
	ColorPickerFrame.cancelFunc = function() undoColor(self) end
	ColorPickerFrame.swatchFunc = function() setColor(self) end
	ColorPickerFrame:SetColorRGB(self.color.r, self.color.g, self.color.b)
	if self.color.a then
		ColorPickerFrame.opacityFunc, ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = function() setColor(self) end, true, 1 - self.color.a
	else
		ColorPickerFrame.opacityFunc, ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = nil, nil, 0
	end
	ColorPickerFrame:ClearAllPoints()
	ColorPickerFrame:SetPoint("CENTER", UIParent, "CENTER")
	ShowUIPanel(ColorPickerFrame)
end

local function enable(self)
	self.bg:SetVertexColor(1, 1, 1)
	self.overlay:Hide()
	self.title:SetTextColor(1, 1 , 1)
	self.button:SetScript("OnClick", click)
end

local function disable(self)
	self.bg:SetVertexColor(0.5, 0.5, 0.5)
	self.overlay:Show()
	self.title:SetTextColor(0.58, 0.58, 0.58)
	self.button:SetScript("OnClick", nil)
	hide()
end

LBO:RegisterWidget(widget, version, function(self)
	self.bg = self:CreateTexture(nil, "BACKGROUND")
	self.bg:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	self.bg:SetPoint("LEFT", 0, 0)
	self.bg:SetWidth(24)
	self.bg:SetHeight(24)
	self.grid = self:CreateTexture(nil, "BORDER")
	self.grid:SetTexture("Tileset\\Generic\\Checkers")
	self.grid:SetDesaturated(true)
	self.grid:SetVertexColor(1, 1, 1, 0.75)
	self.grid:SetTexCoord(0.25, 0, 0.5, 0.25)
	self.grid:SetPoint("CENTER", self.bg, "CENTER", 0, 0)
	self.grid:SetWidth(14)
	self.grid:SetHeight(14)
	self.color = self:CreateTexture(nil, "ARTWORK")
	self.color:SetTexture(1, 1, 1, 1)
	self.color:SetAllPoints(self.grid)
	self.overlay = self:CreateTexture(nil, "OVERLAY")
	self.overlay:SetTexture(0, 0, 0, 1)
	self.overlay:SetAllPoints(self.grid)
	self.overlay:Hide()
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.title:SetPoint("LEFT", self.bg, "RIGHT", 0, 0)
	self.title:SetTextColor(1, 1, 1)
	self.title:SetJustifyH("LEFT")
	self.button = CreateFrame("Button", nil, self)
	self.button:RegisterForClicks("LeftButtonUp")
	self.button:SetPoint("LEFT", self.bg, "LEFT", 0, 0)
	self.button:SetPoint("RIGHT", self.title, "RIGHT", 0, 0)
	self.button:SetHeight(24)
	self.button:SetScript("OnClick", click)
	self.button:SetScript("OnHide", hide)
	self.SetValue = nil
	self.Enable = enable
	self.Disable = disable
	self.Setup = update
end)