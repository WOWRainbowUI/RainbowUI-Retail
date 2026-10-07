-----------------------------------------------------------------------
-- Description: Creates and manages the main Accountant Classic window.
-- This file is used for the addon's primary frame, labels, scroll list,
-- and action buttons shown in the main UI.
-----------------------------------------------------------------------

local _G = getfenv(0)
local _, private = ...

local classic = _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE
local frame = CreateFrame("Frame", "AccountantClassicFrame", UIParent)
frame:SetSize(640, 512)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -104)
frame:SetToplevel(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:Hide()

local function texture(parent, name, layer, file, width, height, point, relative, relativePoint, x, y)
	local object = parent:CreateTexture(name, layer)
	object:SetTexture(file)
	object:SetSize(width, height)
	object:SetPoint(point, relative or parent, relativePoint or point, x or 0, y or 0)
	return object
end

local function label(parent, name, key, font, point, relative, relativePoint, x, y, width, height)
	local object = parent:CreateFontString(name, "ARTWORK", font)
	object:SetSize(width or 0, height or 0)
	object:SetPoint(point, relative or parent, relativePoint or point, x or 0, y or 0)
	parent[key] = object
	return object
end

frame.Portrait = texture(frame, "AccountantClassicFramePortrait", "BACKGROUND", nil, 60, 60, "TOPLEFT", frame, "TOPLEFT", 7, -6)
texture(frame, "AccountantClassicFrameLeft", "ARTWORK", "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantClassicFrame-Left", 512, 512, "TOPLEFT")
texture(frame, "AccountantClassicFrameRight", "ARTWORK", "Interface\\AddOns\\Accountant_Classic\\Images\\AccountantClassicFrame-Right", 128, 512, "TOPLEFT", frame, "TOPLEFT", 512, 0)
label(frame, "AccountantClassicFrameTitleText", "TitleText", "GameFontHighlight", "TOP", frame, "TOP", 0, -21, 620, 14):SetText("ACCLOC_TITLE")
label(frame, "AccountantClassicFrameSource", "Source", "GameFontHighlight", "TOPLEFT", frame, "TOPLEFT", 24, -93)
label(frame, "AccountantClassicFrameIn", "In", "GameFontHighlight", "TOPRIGHT", frame, "TOPLEFT", 460, -93)
label(frame, "AccountantClassicFrameOut", "Out", "GameFontHighlight", "TOPRIGHT", frame, "TOPLEFT", 620, -93)
label(frame, "AccountantClassicFrameTotalIn", "TotalIn", "GameFontHighlightSmall", "TOPLEFT", frame, "TOPLEFT", 75, -40)
label(frame, "AccountantClassicFrameTotalInValue", "TotalInValue", "NumberFontNormal", "TOPRIGHT", frame, "TOPLEFT", 360, -40)
label(frame, "AccountantClassicFrameTotalOut", "TotalOut", "GameFontHighlightSmall", "TOPLEFT", frame, "TOPLEFT", 75, -56)
label(frame, "AccountantClassicFrameTotalOutValue", "TotalOutValue", "NumberFontNormal", "TOPRIGHT", frame, "TOPLEFT", 360, -56)
label(frame, "AccountantClassicFrameTotalFlow", "TotalFlow", "GameFontHighlightSmall", "TOPLEFT", frame, "TOPLEFT", 75, -72)
label(frame, "AccountantClassicFrameTotalFlowValue", "TotalFlowValue", "NumberFontNormal", "TOPRIGHT", frame, "TOPLEFT", 360, -72)
label(frame, "AccountantClassicFrameExtraValue", "ExtraValue", "GameFontNormalSmall", "TOP", frame, "TOPLEFT", 600, -40)
label(frame, "AccountantClassicFrameExtra", "Extra", "GameFontHighlightSmall", "RIGHT", frame.ExtraValue, "LEFT", -2, 0)

for index = 1, 18 do
	local row = AccountantClassic_CreateRow(frame, "AccountantClassicFrameRow"..index)
	if index == 1 then
		row:SetPoint("TOPLEFT", frame, "TOPLEFT", 21, -113)
	else
		row:SetPoint("TOPLEFT", _G["AccountantClassicFrameRow"..(index - 1)], "BOTTOMLEFT", 0, -1)
	end
end

local scroll = CreateFrame("ScrollFrame", "AccountantClassicScrollBar", frame, "FauxScrollFrameTemplate")
scroll:SetSize(590, 340)
scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -112)
scroll:SetScript("OnVerticalScroll", function(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 19, AccountantClassicScrollBar_Update)
end)
scroll:SetScript("OnShow", function()
	AccountantClassicScrollBar_Update()
end)

local close = CreateFrame("Button", "AccountantClassicFrameCloseButton", frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", classic and 0 or 3, -16)

local function createActionButton(name, text, width, point, relative, relativePoint, x, y, click)
	local button = CreateFrame("Button", name, frame, "UIPanelButtonTemplate")
	button:SetSize(width, 22)
	button:SetText(text)
	button:SetPoint(point, relative, relativePoint, x, y)
	button:SetScript("OnClick", click)
	return button
end

local exit = createActionButton("AccountantClassicFrameExitButton", ACCLOC_EXIT, 124, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 17, function()
	HideUIPanel(frame)
end)
local options = createActionButton("AccountantClassicFrameOptionsButton", ACCLOC_OPTBUT, 124, "TOPRIGHT", exit, "TOPLEFT", 2, 0, function()
	_G.Accountant_Classic:OpenOptions()
end)
createActionButton("AccountantClassicFrameResetButton", ACCLOC_RESET, 124, "TOPRIGHT", options, "TOPLEFT", 2, 0, function()
	AccountantClassic_ResetData()
end)

local money = CreateFrame("Frame", "AccountantClassicMoneyFrame", frame, "SmallMoneyFrameTemplate")
money:SetPoint("TOPRIGHT", frame, "BOTTOMLEFT", 266, 32)

frame:SetScript("OnLoad", function(self)
	tinsert(UISpecialFrames, "AccountantClassicFrame")
	UIPanelWindows["AccountantClassicFrame"] = { area = "left", pushable = 11 }
	self:RegisterForDrag("LeftButton")
	self:SetClampedToScreen(true)
	AccountantClassic_RegisterEvents(self)
end)
frame:SetScript("OnShow", function(self)
	AccountantClassic_OnShow(self)
end)
frame:SetScript("OnEvent", function(self, event, ...)
	AccountantClassic_OnEvent(self, event, ...)
end)
frame:SetScript("OnMouseDown", function(self, button)
	AccountantClassic_OnMouseDown(self, button)
end)
frame:SetScript("OnMouseUp", function(self, button)
	AccountantClassic_OnMouseUp(self, button)
end)

