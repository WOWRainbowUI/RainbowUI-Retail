--@curseforge-project-slug: libsfdropdown@
-----------------------------------------------------------
-- LibSFDropDown - DropDown menu for non-Blizzard addons --
-----------------------------------------------------------
local MAJOR_VERSION, MINOR_VERSION = "LibSFDropDown-1.5", 28
local lib, oldminor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end
oldminor = oldminor or 0


local math, next, ipairs, rawget, type, wipe = math, next, ipairs, rawget, type, wipe
local CreateFrame, GetBindingKey, PlaySound, SOUNDKIT, GameTooltip, GetScreenWidth, UIParent, GetCursorPosition, InCombatLockdown = CreateFrame, GetBindingKey, PlaySound, SOUNDKIT, GameTooltip, GetScreenWidth, UIParent, GetCursorPosition, InCombatLockdown
local SearchBoxTemplate_OnTextChanged, CreateScrollBoxListLinearView, ScrollBoxConstants, ScrollUtil, CreateDataProvider, GetAtlasInfo = SearchBoxTemplate_OnTextChanged, CreateScrollBoxListLinearView, ScrollBoxConstants, ScrollUtil, CreateDataProvider, C_Texture.GetAtlasInfo

if oldminor < 1 then
	lib._v = {
		-- DROPDOWNBUTTON = nil,
		defaultStyle = "backdrop",
		menuStyle = "modernMenu",
		menuStyles = {},
		widgetFrames = {},
		colorSwatchFrames = {},
		dropDownSearchFrames = {},
		dropDownMenusList = {},
		dropDownCreatedButtons = {},
		dropDownCreatedModernButtons = {},
		dropDownCreatedStretchButtons = {},
	}
	lib._m = {
		__metatable = "access denied",
		__index = {},
	}
	setmetatable(lib, lib._m)
end

if oldminor < 8 then
	lib._v.dropDownButtonMixin = {}
	lib._v.dropDownButtonProxy = {}
end

if oldminor < 12 then
	lib._v.dropDownMenuButtonHeight = 20
	lib._v.dropDownSearchListMaxSize = 20
end

if oldminor < 19 then
	local frameDummy = CreateFrame("FRAME")
	local function onHide(region) lib._v.fontStringRightPool:Release(region) end
	local function poolReset(pool, region, new)
		region:Hide()
		region:ClearAllPoints()
		if new then
			region:SetScript("OnHide", onHide)
		else
			region:GetParent().rightString = nil
			region:SetParent(frameDummy)
		end
	end
	lib._v.frameDummy = frameDummy
	lib._v.fontStringRightPool = CreateFontStringPool(frameDummy, "ARTWORK", 1, nil, poolReset)
end

local v = lib._v
local menuStyles = v.menuStyles

--[[
List of button attributes (examples: https://github.com/sfmict/LibSFDropDown/wiki/Examples)
====================================================================================================
info.text = [string, function(self, arg1, arg2)] -- The text of the button or function that returns the text
info.rightText = [string, function(self, arg1, arg2)] -- The text on the right side of the button or function that returns the text
info.value = [anything] -- The value that is set to button.value
info.func = [function(self, arg1, arg2, checked)] -- The function that is called when you click the button
info.checked = [nil, true, 2, function(self, arg1, arg2)] -- Check the button if true or function returns true (2 for square)
info.isNotRadio = [nil, true] -- Check the button uses radial image if false check box image if true
info.notCheckable = [nil, true] -- Shrink the size of the buttons and don't display a check box
info.isTitle = [nil, true] -- If it's a title the button is disabled and the font color is set to yellow
info.disabled = [nil, true, function(self, arg1, arg2)] -- Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
info.hasArrow = [nil, true] -- Show the expand arrow for multilevel menus
info.hasArrowUp = [nil, true] -- The same as info.hasArrow but opens the menu up
info.keepShownOnClick = [nil, true] -- Don't hide the dropdownlist after a button is clicked
info.arg1 = [anything] -- This is the first argument used by info.func
info.arg2 = [anything] -- This is the second argument used by info.func
info.icon = [texture] -- An icon or an atlas for the button
info.iconOnly = [nil, true] -- Stretches the texture to the width of the button
info.iconInfo = [nil, table] -- A table that looks like {
	tCoordLeft = [0.0 - 1.0], -- left for SetTexCoord func
	tCoordRight = [0.0 - 1.0], -- right for SetTexCoord func
	tCoordTop = [0.0 - 1.0], -- top for SetTexCoord func
	tCoordBottom = [0.0 - 1.0], -- bottom for SetTexCoord func
	tSizeX = [number], -- texture width
	tSizeY = [number], -- texture height
	tWrap = [nil, string]. -- horizontal wrapping type from SetTexture function
	r = [0.0 - 1.0], -- r for SetVertexColor func
	g = [0.0 - 1.0], -- g for SetVertexColor func
	b = [0.0 - 1.0], -- b for SetVertexColor func
	a = [0.0 - 1.0], -- a for SetVertexColor func
}
info.indent = [number] -- Number of pixels to pad the button on the left side
info.remove = [function(self, arg1, arg2)] -- The function that is called when you click the remove button
info.removeDoNotHide = [nil, true] -- Don't hide menu when clicking remove button
info.order = [function(self, delta, arg1, arg2)] -- The function that is called when you click the up or down arrow button
info.hasColorSwatch = [nil, true] -- Show color swatch or not, for color selection
info.r = [0.0 - 1.0] -- Red color value of the color swatch
info.g = [0.0 - 1.0] -- Green color value of the color swatch
info.b = [0.0 - 1.0] -- Blue color value of the color swatch
info.swatchFunc = [function] -- Function called by the color picker on color change
info.hasOpacity = [nil, true] -- Show the opacity slider on the colorpicker frame
info.opacity = [0.0 - 1.0] -- Percentatge of the opacity, 1.0 is fully shown, 0 is transparent
info.opacityFunc = [function] -- Function called by the opacity slider when you change its value
info.cancelFunc = [function(previousValues)] -- Function called by the colorpicker when you click the cancel button (it takes the previous values as its argument)
info.justifyH = [nil, "CENTER", "RIGHT"] -- Justify button text
info.fontObject = [fontObject] -- The font object replacement for Normal and Highlight
info.rightFontObject = [fontObject] -- The font object replacement for info.rightText
info.font = [font] -- The font replacement for Normal and HighLight
info.rightFont = [font] -- The font replacement for info.rightText
info.OnEnter = [function(self, arg1, arg2)] -- Handler OnEnter
info.OnLeave = [function(self, arg1, arg2)] -- Handler OnLeave
info.tooltipWhileDisabled = [nil, true] -- Show the tooltip, even when the button is disabled
info.OnTooltipShow = [function(self, tooltipFrame, arg1, arg2)] -- Handler tooltip show
info.widgets = [table] -- A table of widgets, that adds mini buttons to the button, looks like {
	{
		width = [nil, number], -- width of widget, default menuButtonHeight (20)
		height = [nil, number], -- height of widget, default menuButtonHeight (20)
		icon = [texture], -- An icon for the widget
		iconInfo = [nil, table], -- A table looks like info.iconInfo (without rgba)
		OnClick = [function(infoBtn, arg1, arg2)] -- The function that is called when you click the button
		OnEnter = [function(infoBtn, arg1, arg2)] -- Handler OnEnter
		OnLeave = [function(infoBtn, arg1, arg2)] -- Handler OnLeave
		OnTooltipShow = [function(infoBtn, tooltipFrame, arg1, arg2)] -- Handler tooltip show
	},
}
info.customFrame = [frame] -- Allows this button to be a completely custom frame
info.fixedWidth = [nil, true] -- If nil then custom frame is stretched
info.OnLoad = [function(customFrame)] -- Function called when the custom frame is attached
info.search = [function(searchString, infoText, infoRightText, btnInfo)] -- Optional custom search function, must return true/false
info.hideSearch = [nil, true] -- Remove SearchBox if info.list displays as scroll menu
info.listMaxSize = [number] -- Number of max size info.list, after a scroll frame is added
info.list = [table] -- The table of info buttons, if there are more than 20 (default) buttons, a scroll frame is added. Available attributes in table "dropDownOptions".
]]
v.dropDownOptions = {
	"text",
	"rightText",
	"value",
	"func",
	"checked",
	"isNotRadio",
	"notCheckable",
	"isTitle",
	"disabled",
	"hasArrow",
	"hasArrowUp",
	"keepShownOnClick",
	"arg1",
	"arg2",
	"icon",
	"iconOnly",
	"iconInfo",
	"indent",
	"remove",
	"removeDoNotHide",
	"order",
	"hasColorSwatch",
	"r",
	"g",
	"b",
	"swatchFunc",
	"hasOpacity",
	"opacity",
	"opacityFunc",
	"cancelFunc",
	"justifyH",
	"fontObject",
	"rightFontObject",
	"font",
	"rightFont",
	"OnEnter",
	"OnLeave",
	"tooltipWhileDisabled",
	"OnTooltipShow",
	"widgets",
}


menuStyles.backdrop = function(parent)
	return CreateFrame("FRAME", nil, parent, "DialogBorderDarkTemplate")
end
menuStyles.menuBackdrop = function(parent)
	return CreateFrame("FRAME", nil, parent, "TooltipBackdropTemplate")
end
menuStyles.modernMenu = function(parent)
	local f = CreateFrame("FRAME", nil, parent)
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAtlas("common-dropdown-bg")
	f.bg:SetPoint("TOPLEFT", -5, 2)
	f.bg:SetPoint("BOTTOMRIGHT", 5, -8)
	f.bg:SetAlpha(.925)
	return f
end


function v.createMenuStyle(menu, name, frameFunc)
	local f = frameFunc(menu)
	f:SetFrameLevel(menu:GetFrameLevel())
	if not f:GetPoint() then
		f:SetAllPoints()
	end
	f:Hide()
	menu.styles[name] = f
end


function v.setIcon(texture, icon, info, menuButtonHeight, noColor)
	local atlasInfo = GetAtlasInfo(icon)
	local width, iconWrap = atlasInfo and atlasInfo.width / atlasInfo.height * menuButtonHeight or menuButtonHeight
	if info then
		if not noColor then texture:SetVertexColor(info.r or 1, info.g or 1, info.b or 1, info.a or 1) end
		texture:SetSize(info.tSizeX or width, info.tSizeY or menuButtonHeight)
		texture:SetTexCoord(info.tCoordLeft or 0, info.tCoordRight or 1, info.tCoordTop or 0, info.tCoordBottom or 1)
		texture:SetHorizTile(info.tWrap and true or false)
		iconWrap = info.tWrap
	else
		if not noColor then texture:SetVertexColor(1, 1, 1, 1) end
		texture:SetSize(width, menuButtonHeight)
		texture:SetTexCoord(0, 1, 0, 1)
		texture:SetHorizTile(false)
	end
	if atlasInfo then
		texture:SetAtlas(icon)
	else
		texture:SetTexture(icon, iconWrap)
	end
end


function v.getNextWidgetName(widgetType)
	v.widgetNum = v.widgetNum or {}
	v.widgetNum[widgetType] = (v.widgetNum[widgetType] or 0) + 1
	return MAJOR_VERSION..widgetType..v.widgetNum[widgetType]
end


---------------------------------------------------
-- FONT
---------------------------------------------------
function v.getFontObject(self, font, fontObject)
	if not self._fontObject then
		self._fontObject = CreateFont(v.getNextWidgetName("font"))
		self._fontObject:CopyFontObject(GameFontHighlightLeft)
	end
	local _, size, outline = (fontObject or GameFontHighlightLeft):GetFont()
	self._fontObject:SetFont(font, size, outline)
	return self._fontObject
end


function v.setButtonFont(btn)
	btn:SetDisabledFontObject(btn.isTitle and GameFontNormalLeft or GameFontDisableLeft)
	local fontObject = btn.fontObject or GameFontHighlightLeft
	if btn.font then
		fontObject = v.getFontObject(btn.NormalText, btn.font, fontObject)
	end
	btn:SetNormalFontObject(fontObject)
	btn:SetHighlightFontObject(fontObject)
end


function v.setRightFont(btn)
	local fontObject = btn.rightFontObject or GameFontHighlightRight
	if btn.rightFont then
		fontObject = v.getFontObject(btn.rightString, btn.rightFont, fontObject)
	end
	btn.rightString:SetFontObject(fontObject)
end


---------------------------------------------------
-- DROPDOWN MENU
---------------------------------------------------
local function DropDownMenuList_OnHide(self)
	self:Hide()
	self:ClearAllPoints()

	if self.customFrames then
		for i = 1, #self.customFrames do
			self.customFrames[i]:Hide()
		end
		self.customFrames = nil
	end

	local level = self.scrollChild.id
	local f = v[level]
	v[level] = nil
	v[level + 1] = nil

	if f and f.highlight and not f:IsMouseOver() then
		f.highlight:Hide()
	end
end


local function DropDownMenuListScrollFrame_OnVerticalScroll(self, offset)
	local scrollRange = self:GetVerticalScrollRange()
	self.scrollBar:SetScrollPercentage(scrollRange > 0 and offset / scrollRange or 0, ScrollBoxConstants.NoScrollInterpolation)
	v.DROPDOWNBUTTON:ddCloseMenus(self.scrollChild.id + 1)
end


local function DropDownMenuListScrollFrame_OnScrollRangeChanged(self, xrange, yrange)
	self:GetScript("OnVerticalScroll")(self, self:GetVerticalScroll())
	local height = self:GetHeight()
	self.scrollBar:SetVisibleExtentPercentage(height > 0 and height / (yrange + height) or 0)
	self.scrollBar:SetPanExtentPercentage(yrange > 0 and 30 / yrange or 0)
end


local function DropDownMenuListScrollFrame_OnMouseWheel(self, delta)
	if self.scrollBar:IsShown() then self.scrollBar:ScrollStepInDirection(-delta) end
	v.DROPDOWNBUTTON:ddCloseMenus(self.scrollChild.id + 1)
end


local function DropDownMenuListScrollBar_OnScroll(scrollFrame, scrollPercentage)
	scrollFrame:SetVerticalScroll(scrollPercentage * scrollFrame:GetVerticalScrollRange())
end


local function CreateDropDownMenuList(parent)
	local menu = CreateFrame("FRAME", nil, parent)
	menu:Hide()
	menu:EnableMouse(true)
	menu:SetClampedToScreen(true)
	menu:SetFrameStrata("FULLSCREEN_DIALOG")
	menu:SetScript("OnHide", DropDownMenuList_OnHide)

	menu.scrollFrame = CreateFrame("ScrollFrame", nil, menu)
	menu.scrollFrame:SetPoint("TOPLEFT", 15, -15)
	menu.scrollFrame:SetScript("OnVerticalScroll", DropDownMenuListScrollFrame_OnVerticalScroll)
	menu.scrollFrame:SetScript("OnScrollRangeChanged", DropDownMenuListScrollFrame_OnScrollRangeChanged)
	menu.scrollFrame:SetScript("OnMouseWheel", DropDownMenuListScrollFrame_OnMouseWheel)

	menu.scrollBar = CreateFrame("EventFrame", nil, menu, "MinimalScrollBar")
	menu.scrollFrame.scrollBar = menu.scrollBar
	menu.scrollBar:SetPoint("TOPLEFT", menu.scrollFrame, "TOPRIGHT", 6, 0)
	menu.scrollBar:SetPoint("BOTTOMLEFT", menu.scrollFrame, "BOTTOMRIGHT", 6, 0)
	menu.scrollBar:RegisterCallback(menu.scrollBar.Event.OnScroll, DropDownMenuListScrollBar_OnScroll, menu.scrollFrame)

	menu.scrollChild = CreateFrame("FRAME")
	menu.scrollChild:SetSize(1, 1)
	menu.scrollFrame:SetScrollChild(menu.scrollChild)
	menu.scrollFrame.scrollChild = menu.scrollChild
	menu.scrollBar.scrollChild = menu.scrollChild

	menu.styles = {}
	for name, frameFunc in next, menuStyles do
		v.createMenuStyle(menu, name, frameFunc)
	end
	menu.activeStyle = menu.styles[v.defaultStyle]

	return menu
end


---------------------------------------------------
-- DROPDOWN MENU BUTTON
---------------------------------------------------
local function DropDownMenuButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	if not self.notCheckable then
		self._checked = not self._checked or self._checked == 2
		if self.keepShownOnClick then
			self.GroupCheck:Hide()
			self.Check:SetShown(self._checked)
		end
	end

	if type(self.func) == "function" then
		self:func(self.arg1, self.arg2, self._checked)
	end

	if not self.keepShownOnClick then
		v.DROPDOWNBUTTON:ddCloseMenus()
	end
end


local function DropDonwMenuButton_Delayed(self, elapsed)
	self.delay = self.delay - elapsed
	if self.delay > 0 then return end

	if v.delayedFrame then
		if v[v.delayedLevel] ~= v.delayedFrame then
			v.DROPDOWNBUTTON:ddToggle(v.delayedLevel, v.delayedFrame.value, v.delayedFrame)
			v[v.delayedLevel] = v.delayedFrame
		end
	else
		v[v.delayedLevel] = nil
		v.DROPDOWNBUTTON:ddCloseMenus(v.delayedLevel)
	end

	self:SetScript("OnUpdate", nil)
end


local function DropDownMenuButton_OnEnterInit(self)
	local level = self:GetParent().id + 1
	local f = v[level]
	if f and f.highlight then f.highlight:Hide() end

	v.delayedLevel = level
	v.frameDummy.delay = .2
	if (self.hasArrow or self.hasArrowUp) and self:IsEnabled() then
		v.delayedFrame = self
	else
		v.delayedFrame = nil
	end
	v.frameDummy:SetScript("OnUpdate", DropDonwMenuButton_Delayed)

	if self.remove then
		v.removeButton:SetAlpha(1)
	end

	if self.order then
		v.arrowDownButton:SetAlpha(1)
		v.arrowUpButton:SetAlpha(1)
	end

	if self.widgets then
		v.widgetAlpha(1)
	end

	if self:IsEnabled() then self.highlight:Show() end
end


local function DropDownMenuButton_OnEnter(self)
	if self.remove then
		v.removeButton:SetParent(self)
		v.removeButton:SetPoint("RIGHT", self.removePostion, 0)
		v.removeButton:Show()
		self.removeFrame = true
	end

	if self.order then
		v.arrowDownButton:SetParent(self)
		v.arrowDownButton:SetPoint("RIGHT", self.orderPosition, 0)
		v.arrowDownButton:Show()

		v.arrowUpButton:SetParent(self)
		v.arrowUpButton:Show()
	end

	if self.widgets then
		v.widgetInit(self)
	end

	if self.OnTooltipShow and (self:IsEnabled() or self.tooltipWhileDisabled) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		self:OnTooltipShow(GameTooltip, self.arg1, self.arg2)
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end

	if self.OnEnter then
		self:OnEnter(self.arg1, self.arg2)
	end

	DropDownMenuButton_OnEnterInit(self)
end


local function DropDownMenuButton_OnLeave(self)
	local f = v[self:GetParent().id + 1]
	if self ~= f then
		self.highlight:Hide()
		if f and f.highlight then f.highlight:Show() end
	end

	if self.remove then
		v.removeButton:SetAlpha(0)
	end

	if self.order then
		v.arrowDownButton:SetAlpha(0)
		v.arrowUpButton:SetAlpha(0)
	end

	if self.widgets then
		v.widgetAlpha(0)
	end

	if self.OnTooltipShow and (self:IsEnabled() or self.tooltipWhileDisabled) then
		GameTooltip:Hide()
	end

	if self.OnLeave then
		self:OnLeave(self.arg1, self.arg2)
	end

	v.frameDummy:SetScript("OnUpdate", nil)
end


local function DropDownMenuButton_OnDisable(self)
	self.Check:SetDesaturated(true)
	self.Check:SetAlpha(.5)
	self.UnCheck:SetDesaturated(true)
	self.UnCheck:SetAlpha(.5)
	self.ExpandArrow:SetDesaturated(true)
	self.ExpandArrow:SetAlpha(.5)
end


local function DropDownMenuButton_OnEnable(self)
	self.Check:SetDesaturated()
	self.Check:SetAlpha(1)
	self.UnCheck:SetDesaturated()
	self.UnCheck:SetAlpha(1)
	self.ExpandArrow:SetDesaturated()
	self.ExpandArrow:SetAlpha(1)
end


local function DropDownMenuButton_OnHide(self)
	self:Hide()
	self.highlight:Hide()
	self.colorSwatch = nil
end


function v.dropDownMenuButtonInit(btn)
	btn:SetMotionScriptsWhileDisabled(true)
	btn:SetNormalFontObject(GameFontHighlightLeft)
	btn:SetHighlightFontObject(GameFontHighlightLeft)
	btn:SetDisabledFontObject(GameFontDisableLeft)
	btn:SetScript("OnClick", DropDownMenuButton_OnClick)
	btn:SetScript("OnEnter", DropDownMenuButton_OnEnter)
	btn:SetScript("OnLeave", DropDownMenuButton_OnLeave)
	btn:SetScript("OnDisable", DropDownMenuButton_OnDisable)
	btn:SetScript("OnEnable", DropDownMenuButton_OnEnable)
	btn:SetScript("OnHide", DropDownMenuButton_OnHide)

	btn.highlight = btn:CreateTexture(nil, "BORDER")
	btn.highlight:SetTexture("Interface/QuestFrame/UI-QuestTitleHighlight")
	btn.highlight:Hide()
	btn.highlight:SetBlendMode("ADD")
	btn.highlight:SetAllPoints()

	btn.Check = btn:CreateTexture(nil, "ARTWORK", nil, 2)
	btn.Check:SetPoint("LEFT")

	btn.UnCheck = btn:CreateTexture(nil, "ARTWORK", nil, 1)
	btn.UnCheck:SetPoint("LEFT")

	btn.Icon = btn:CreateTexture(nil, "BACKGROUND")

	btn.ExpandArrow = btn:CreateTexture(nil, "ARTWORK")
	btn.ExpandArrow:SetTexture("Interface/ChatFrame/ChatFrameExpandArrow")
	btn.ExpandArrow:SetSize(16, 16)
	btn.ExpandArrow:SetPoint("RIGHT", 4, 0)

	btn:SetText(" ")
	btn.NormalText = btn:GetFontString()

	btn.GroupCheck = btn:CreateTexture(nil, "ARTWORK", nil, 2)
	btn.GroupCheck:SetColorTexture(1, .8, 0)
	btn.GroupCheck:SetSize(8, 8)
	btn.GroupCheck:SetPoint("CENTER", btn.UnCheck)
end


---------------------------------------------------
-- WIDGETS
---------------------------------------------------
local function OnHide(self)
	self:Hide()
end


local function widget_OnEnter(self)
	self.icon:SetVertexColor(1, 1, 1)
	local parent = self:GetParent()

	if self.OnTooltipShow then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		self.OnTooltipShow(parent, GameTooltip, parent.arg1, parent.arg2)
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end

	if self.OnEnter then
		self.OnEnter(parent, parent.arg1, parent.arg2)
	end

	DropDownMenuButton_OnEnterInit(parent)
end


local function widget_OnLeave(self)
	self.icon:SetVertexColor(.7, .7, .7)
	local parent = self:GetParent()

	if self.OnTooltipShow then
		GameTooltip:Hide()
	end

	if self.OnLeave then
		self.OnLeave(parent.arg1, parent.arg2)
	end

	parent:GetScript("OnLeave")(parent)
end


local function widget_OnMouseDown(self)
	self.icon:SetScale(.9)
end


local function widget_OnMouseUp(self)
	self.icon:SetScale(1)
end


local function widget_OnClick(self)
	if self.OnClick then
		local parent = self:GetParent()
		self.OnClick(parent, parent.arg1, parent.arg2)
	end
end


local function createWidget()
	local btn = CreateFrame("BUTTON")
	btn:Hide()
	btn:SetAlpha(0)
	btn:SetScript("OnEnter", widget_OnEnter)
	btn:SetScript("OnLeave", widget_OnLeave)
	btn:SetScript("OnMouseDown", widget_OnMouseDown)
	btn:SetScript("OnMouseUp", widget_OnMouseUp)
	btn:SetScript("OnHide", OnHide)
	btn:SetScript("OnClick", widget_OnClick)

	btn.icon = btn:CreateTexture(nil, "BACKGROUND")
	btn.icon:SetPoint("CENTER")
	btn.icon:SetVertexColor(.7, .7, .7)

	return btn
end


setmetatable(v.widgetFrames, {__index = function(self, key)
	self[key] = createWidget()
	return self[key]
end})


function v.widgetInit(parent)
	local position = parent.widgetPosition
	local menuButtonHeight = v.DROPDOWNBUTTON.ddMenuButtonHeight or v.dropDownMenuButtonHeight
	for i = 1, #parent.widgets do
		local info = parent.widgets[i]
		local btn = v.widgetFrames[i]
		btn:SetParent(parent)
		btn:SetSize(info.width or menuButtonHeight, info.height or menuButtonHeight)
		btn:SetPoint("RIGHT", position, 0)
		btn.OnClick = info.OnClick
		btn.OnEnter = info.OnEnter
		btn.OnLeave = info.OnLeave
		btn.OnTooltipShow = info.OnTooltipShow
		v.setIcon(btn.icon, info.icon, info.iconInfo, menuButtonHeight, true)
		btn:Show()
		position = position - btn:GetWidth()
	end
end


function v.widgetAlpha(alpha)
	for i = 1, #v.widgetFrames do
		local frame = v.widgetFrames[i]
		if frame:IsShown() then
			frame:SetAlpha(alpha)
		else
			break
		end
	end
end


---------------------------------------------------
-- CONTROL BUTTONS
---------------------------------------------------
-- REMOVE BUTTON
local function RemoveButton_OnClick(self)
	local parent = self:GetParent()
	parent:remove(parent.arg1, parent.arg2)
	if not parent.removeDoNotHide then v.DROPDOWNBUTTON:ddCloseMenus() end
end


if not v.removeButton then
	v.removeButton = createWidget()
	v.removeButton:SetSize(16, 16)
	v.removeButton:SetScript("OnClick", RemoveButton_OnClick)

	v.removeButton.icon:SetTexture("Interface/BUTTONS/UI-GroupLoot-Pass-Up")
	v.removeButton.icon:SetSize(16, 16)
end


-- ORDER
local function ArrowButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	local parent = self:GetParent()
	parent:order(self.delta, parent.arg1, parent.arg2)
	v.DROPDOWNBUTTON:ddRefresh(parent:GetParent().id, v.DROPDOWNBUTTON.anchorFrame)
end


if not v.arrowDownButton then
	v.arrowDownButton = createWidget()
	v.arrowDownButton:SetSize(12, 16)
	v.arrowDownButton:SetScript("OnClick", ArrowButton_OnClick)
	v.arrowDownButton.delta = 1

	v.arrowDownButton.icon:SetTexture("Interface/BUTTONS/UI-MicroStream-Yellow")
	v.arrowDownButton.icon:SetSize(8, 14)
	v.arrowDownButton.icon:SetTexCoord(.25, .75, 0, .875)
end


if not v.arrowUpButton then
	v.arrowUpButton = createWidget()
	v.arrowUpButton:SetSize(12, 16)
	v.arrowUpButton:SetPoint("RIGHT", v.arrowDownButton, "LEFT")
	v.arrowUpButton:SetScript("OnClick", ArrowButton_OnClick)
	v.arrowUpButton.delta = -1

	v.arrowUpButton.icon:SetTexture("Interface/BUTTONS/UI-MicroStream-Yellow")
	v.arrowUpButton.icon:SetSize(8, 14)
	v.arrowUpButton.icon:SetTexCoord(.25, .75, .875, 0)
end


---------------------------------------------------
-- DROPDOWN COLOR SWATCH
---------------------------------------------------
local function ColorSwatch_OnClick(self)
	v.DROPDOWNBUTTON:ddCloseMenus()
	if OpenColorPicker then
		OpenColorPicker(self:GetParent())
	else
		ColorPickerFrame:SetupColorPickerAndShow(self:GetParent())
	end
end


local function ColorSwatch_OnEnter(self)
	self.swatchBg:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
	local parent = self:GetParent()
	parent:GetScript("OnEnter")(parent)
end


local function ColorSwatch_OnLeave(self)
	self.swatchBg:SetVertexColor(HIGHLIGHT_FONT_COLOR:GetRGB())
	local parent = self:GetParent()
	parent:GetScript("OnLeave")(parent)
end


local function CreateColorSwatchFrame()
	local f = CreateFrame("BUTTON")
	f:Hide()
	f:SetSize(16, 16)
	f:SetScript("OnHide", OnHide)
	f:SetScript("OnClick", ColorSwatch_OnClick)
	f:SetScript("OnEnter", ColorSwatch_OnEnter)
	f:SetScript("OnLeave", ColorSwatch_OnLeave)

	f.swatchBg = f:CreateTexture(nil, "BACKGROUND", nil, -3)
	f.swatchBg:SetSize(14, 14)
	f.swatchBg:SetPoint("CENTER")
	f.swatchBg:SetColorTexture(HIGHLIGHT_FONT_COLOR:GetRGB())

	f.innerBorder = f:CreateTexture(nil, "BACKGROUND", nil, -2)
	f.innerBorder:SetSize(12, 12)
	f.innerBorder:SetPoint("CENTER")
	f.innerBorder:SetColorTexture(BLACK_FONT_COLOR:GetRGB())

	f.color = f:CreateTexture(nil, "BACKGROUND", nil, -1)
	f.color:SetSize(10, 10)
	f.color:SetPoint("CENTER")
	f.color:SetColorTexture(HIGHLIGHT_FONT_COLOR:GetRGB())

	return f
end


local colorSwatchFrames = v.colorSwatchFrames
local function GetColorSwatchFrame()
	for i = 1, #colorSwatchFrames do
		local frame = colorSwatchFrames[i]
		if not frame:IsShown() then return frame end
	end
	local frame = CreateColorSwatchFrame()
	colorSwatchFrames[#colorSwatchFrames + 1] = frame
	return frame
end


---------------------------------------------------
-- DROPDOWN MENU SEARCH
---------------------------------------------------
local function DropDownMenuSearchBox_OnTextChanged(self, userInput)
	SearchBoxTemplate_OnTextChanged(self)
	if userInput then
		self:GetParent():updateFilters()
	end
end


local function DropDownMenuSearchBox_OnEnter(self)
	v.DROPDOWNBUTTON:ddCloseMenus(self:GetParent().scrollBox:GetScrollTarget().id + 1)
end


local function DropDownMenuSearchBoxClear_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	local searchBox = self:GetParent()
	searchBox:SetText("")
	searchBox:ClearFocus()
	searchBox:GetParent():updateFilters()
end


local function DropDownMenuScrollBox_OnScroll(f)
	v.DROPDOWNBUTTON:ddCloseMenus(f.scrollBox:GetScrollTarget().id + 1)
end


local function DropDownMenuSearchButtonInit(btn, info)
	for i = 1, #v.dropDownOptions do
		local opt = v.dropDownOptions[i]
		btn[opt] = info[opt]
	end

	local disabled = btn.disabled
	if type(disabled) == "function" then disabled = disabled(btn, btn.arg1, btn.arg2) end
	if disabled or btn.isTitle then
		btn:Disable()
	else
		btn:Enable()
	end

	btn._text = btn.text
	if btn._text then
		v.setButtonFont(btn)
		if type(btn._text) == "function" then btn._text = btn:_text(btn.arg1, btn.arg2) end
		btn:SetText(btn._text)
	else
		btn:SetText("")
	end

	local textPos = -5
	local hasArrow = btn.hasArrow or btn.hasArrowUp
	if hasArrow then
		textPos = -12
	end
	btn.ExpandArrow:SetShown(hasArrow)

	if btn.hasColorSwatch then
		if not btn.colorSwatch then
			btn.colorSwatch = GetColorSwatchFrame()
			btn.colorSwatch:SetParent(btn)
		end
		btn.colorSwatch:SetPoint("RIGHT", textPos, 0)
		textPos = textPos - 17
		btn.colorSwatch.color:SetVertexColor(btn.r, btn.g, btn.b)
		btn.colorSwatch:Show()
		if not btn.func then
			btn.func = function() btn.colorSwatch:Click() end
		end
	elseif btn.colorSwatch then
		btn.colorSwatch:Hide()
		btn.colorSwatch = nil
	end

	if btn.rightString then btn.rightString:Hide() end

	btn._rightText = btn.rightText
	if btn._rightText then
		btn.rightString = v.fontStringRightPool:Acquire()
		btn.rightString:SetParent(btn)
		btn.rightString:SetPoint("RIGHT", textPos, 0)
		v.setRightFont(btn)
		if type(btn._rightText) == "function" then btn._rightText = btn:_rightText(btn.arg1, btn.arg2) end
		btn.rightString:SetText(btn._rightText)
		btn.rightString:SetJustifyH("RIGHT")
		btn.rightString:Show()
		textPos = textPos - btn.rightString:GetWidth()
	end

	if btn.remove then
		btn.removePostion = textPos
		textPos = textPos - 17
	end

	if btn.order then
		btn.orderPosition = textPos
		textPos = textPos - 25
	end

	local menuButtonHeight = v.DROPDOWNBUTTON.ddMenuButtonHeight or v.dropDownMenuButtonHeight
	if btn.widgets then
		btn.widgetPosition = textPos
		for i = 1, #btn.widgets do
			textPos = textPos - (btn.widgets[i].width or menuButtonHeight)
		end
	end

	if btn.icon then
		v.setIcon(btn.Icon, btn.icon, btn.iconInfo, menuButtonHeight)

		if btn.iconOnly then
			btn.Icon:SetDrawLayer("BACKGROUND")
			btn.Icon:SetPoint("RIGHT")
		else
			btn.Icon:SetDrawLayer("ARTWORK")
			btn.Icon:ClearAllPoints()
		end
		btn.Icon:Show()
	else
		btn.Icon:Hide()
	end

	local indent = btn.indent or 0
	textPos = textPos == -5 and 0 or textPos - 2
	btn.NormalText:ClearAllPoints()
	if btn.notCheckable then
		btn.Check:Hide()
		btn.UnCheck:Hide()
		btn.GroupCheck:Hide()
		if btn.icon then
			btn.Icon:SetPoint("LEFT", indent, 0)
			if not btn.iconOnly then
				indent = indent + btn.Icon:GetWidth() + 2
			end
		end

		if btn.justifyH == "CENTER" then
			btn.NormalText:SetPoint("CENTER", (indent + textPos) / 2, 0)
		elseif btn.justifyH == "RIGHT" then
			btn.NormalText:SetPoint("RIGHT", textPos, 0)
		else
			btn.NormalText:SetPoint("LEFT", indent, 0)
		end
	else
		btn.Check:SetPoint("LEFT", indent, 0)
		btn.UnCheck:SetPoint("LEFT", indent, 0)
		if btn.icon then
			btn.Icon:SetPoint("LEFT", 20 + indent, 0)
			if not btn.iconOnly then
				indent = indent + btn.Icon:GetWidth() + 2
			end
		end
		btn.NormalText:SetPoint("LEFT", 20 + indent, 0)

		btn._checked = btn.checked
		if type(btn._checked) == "function" then
			btn._checked = btn:_checked(btn.arg1, btn.arg2)
		elseif v.DROPDOWNBUTTON.ddAutoSetText and btn._checked == nil and not btn.isNotRadio then
			btn._checked = btn.value == v.DROPDOWNBUTTON:ddGetSelectedValue()
		end

		if btn.isNotRadio or btn._checked == 2 then
			btn.Check:SetAtlas("common-dropdown-icon-checkmark-yellow", true)
			btn.UnCheck:SetAtlas("common-dropdown-ticksquare", true)
		else
			btn.Check:SetAtlas("common-dropdown-icon-radialtick-yellow", true)
			btn.UnCheck:SetAtlas("common-dropdown-tickradial", true)
		end

		btn.Check:SetShown(btn._checked and btn._checked ~= 2)
		btn.UnCheck:Show()
		btn.GroupCheck:SetShown(btn._checked == 2)
	end
end


local function DropDownMenuSearchButton_OnAcquired(owner, frame, data, new)
	if new then v.dropDownMenuButtonInit(frame) end
end


local DropDownMenuSearchMixin = {}


function DropDownMenuSearchMixin:reset()
	self.index = 1
	self.width = 0
	wipe(self.buttons)
	return self
end


function DropDownMenuSearchMixin:init(menu, info)
	self:SetParent(menu.scrollChild)
	self:SetFrameLevel(menu.scrollChild:GetFrameLevel())
	self:SetPoint("TOPLEFT", 0, -menu.height)
	self:SetPoint("RIGHT")
	self.scrollBox:GetScrollTarget().id = menu.scrollChild.id

	local menuButtonHeight = v.DROPDOWNBUTTON.ddMenuButtonHeight or v.dropDownMenuButtonHeight
	self.view:SetElementExtent(menuButtonHeight)

	local height = menuButtonHeight * (info.listMaxSize or v.dropDownSearchListMaxSize)
	self.scrollBox:SetHeight(height)

	if info.hideSearch then
		self.searchBox:Hide()
		self.scrollBox:SetPoint("TOPLEFT", 0, -3)
		height = height + 3
	else
		self.searchBox:Show()
		self.scrollBox:SetPoint("TOPLEFT", self.searchBox, "BOTTOMLEFT", -5, -3)
		height = height + 26
	end
	self.search = info.search

	for i = 1, #info.list do
		self:addButton(info.list[i])
	end

	self:SetHeight(height)
	self.searchBox:SetText("")
	self:updateFilters()
	self:Show()

	return self.width, height
end


do
	local deleteStr, len = {
		{"|?|c%x%x%x%x%x%x%x%x", 10},
		{"|?|r", 2},
	}
	local function compareFunc(s)
		return #s == len and "" or s
	end
	local function find(text, str)
		for i = 1, #deleteStr do
			local ds = deleteStr[i]
			len = ds[2]
			text = text:gsub(ds[1], compareFunc)
		end
		return text:lower():find(str, 1, true)
	end
	local function search(str, text, rightText)
		return #str == 0
		    or not (text or rightText)
		    or text and find(text, str)
		    or rightText and find(rightText, str)
	end

	function DropDownMenuSearchMixin:updateFilters()
		local text = self.searchBox:GetText():trim():lower()
		local search = self.search or search
		self.dataProvider = CreateDataProvider()

		for i = 1, #self.buttons do
			local info = self.buttons[i]
			local infoText = type(info.text) == "function" and info:text(info.arg1, info.arg2) or info.text
			local infoRightText = type(info.rightText) == "function" and info:rightText(info.arg1, info.arg2) or info.rightText
			if search(text, infoText, infoRightText, info) then
				self.dataProvider:Insert(info)
			end
		end

		self.scrollBox:SetDataProvider(self.dataProvider, ScrollBoxConstants.RetainScrollPosition)
	end
end


function DropDownMenuSearchMixin:addButton(info)
	local frames = self.view:GetFrames()
	if #frames == 0 then
		self.view:AcquireInternal(1, info)
		self.view:InvokeInitializers()
	end
	local btn = frames[1]

	local btnInfo = {}
	for i = 1, #v.dropDownOptions do
		local opt = v.dropDownOptions[i]
		btnInfo[opt] = info[opt]
		btn[opt] = info[opt]
	end
	self.buttons[#self.buttons + 1] = btnInfo

	local width = 50
	local menuButtonHeight = v.DROPDOWNBUTTON.ddMenuButtonHeight or v.dropDownMenuButtonHeight

	if btn.text then
		local disabled = btn.disabled
		if type(disabled) == "function" then disabled = disabled(btn, btn.arg1, btn.arg2) end
		if disabled or btn.isTitle then
			btn:Disable()
		else
			btn:Enable()
		end

		v.setButtonFont(btn)
		btn:SetText(type(btn.text) == "function" and btn:text(btn.arg1, btn.arg2) or btn.text)
		width = width + btn.NormalText:GetWidth()
	end

	if btn.rightText then
		btn.rightString = btn.NormalText
		v.setRightFont(btn)
		btn.rightString = nil
		btn:SetText(type(btn.rightText) == "function" and btn:rightText(btn.arg1, btn.arg2) or btn.rightText)
		width = width + btn.NormalText:GetWidth()
	end

	if btn.indent then
		width = width + btn.indent
	end

	if btn.notCheckable then
		width = width - 20
	elseif not btn.isNotRadio then
		local checked = btn.checked
		if type(checked) == "function" then
			checked = checked(btn, btn.arg1, btn.arg2)
		elseif v.DROPDOWNBUTTON.ddAutoSetText and checked == nil then
			checked = btn.value == v.DROPDOWNBUTTON:ddGetSelectedValue()
		end
		if checked and checked ~= 2 then self.index = #self.buttons end
	end

	if btn.icon and not btn.iconOnly then
		width = width + (btn.iconInfo and btn.iconInfo.tSizeX or menuButtonHeight) + 2
	end

	local textPos = -7
	if btn.hasArrow or btn.hasArrowUp then
		textPos = -12
	end

	if btn.remove then
		textPos = textPos - 17
	end

	if btn.order then
		textPos = textPos - 25
	end

	if btn.widgets then
		for i = 1, #btn.widgets do
			textPos = textPos - (btn.widgets[i].width or menuButtonHeight)
		end
	end

	if btn.hasColorSwatch then
		textPos = textPos - 17
	end

	width = width - (textPos == -7 and 0 or textPos)

	if self.width < width then
		self.width = width
	end
end


local function CreateDropDownMenuSearch()
	local f = CreateFrame("FRAME")
	f:Hide()
	f:SetScript("OnHide", OnHide)

	f.searchBox = CreateFrame("EditBox", v.getNextWidgetName("SearchBox"), f, "SearchBoxTemplate")
	f.searchBox:SetMaxLetters(40)
	f.searchBox:SetHeight(20)
	f.searchBox:SetPoint("TOPLEFT", 5, -3)
	f.searchBox:SetPoint("TOPRIGHT", 1, -3)
	f.searchBox:SetScript("OnTextChanged", DropDownMenuSearchBox_OnTextChanged)
	f.searchBox:SetScript("OnEnter", DropDownMenuSearchBox_OnEnter)

	f.searchBox.clearButton:SetScript("OnClick", DropDownMenuSearchBoxClear_OnClick)

	f.scrollBox = CreateFrame("FRAME", nil, f, "WowScrollBoxList")
	f.scrollBox:SetPoint("RIGHT", -20, 0)
	f.scrollBox:RegisterCallback(f.scrollBox.Event.OnScroll, DropDownMenuScrollBox_OnScroll, f)

	f.scrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
	f.scrollBar:SetPoint("TOPLEFT", f.scrollBox, "TOPRIGHT", 8, -2)
	f.scrollBar:SetPoint("BOTTOMLEFT", f.scrollBox, "BOTTOMRIGHT", 8, 0)

	f.view = CreateScrollBoxListLinearView()
	f.view:SetElementExtent(v.dropDownMenuButtonHeight)
	f.view:SetElementInitializer("BUTTON", DropDownMenuSearchButtonInit)
	f.view:RegisterCallback(f.view.Event.OnAcquiredFrame, DropDownMenuSearchButton_OnAcquired, f)

	ScrollUtil.InitScrollBoxListWithScrollBar(f.scrollBox, f.scrollBar, f.view)

	f.buttons = {}
	for k, v in next, DropDownMenuSearchMixin do
		f[k] = v
	end

	return f
end


local dropDownSearchFrames = v.dropDownSearchFrames
local function GetDropDownSearchFrame()
	for i = 1, #dropDownSearchFrames do
		local frame = dropDownSearchFrames[i]
		if not frame:IsShown() then return frame:reset() end
	end
	local frame = CreateDropDownMenuSearch()
	dropDownSearchFrames[#dropDownSearchFrames + 1] = frame
	return frame:reset()
end


---------------------------------------------------
-- DROPDOWN CREATING
---------------------------------------------------
local dropDownMenusList = setmetatable(v.dropDownMenusList, {
	__index = function(self, key)
		local frame = CreateDropDownMenuList(key == 1 and UIParent or self[key - 1])
		if key ~= 1 then
			frame:SetFrameLevel(self[key - 1]:GetFrameLevel() + 5)
		end
		frame.scrollChild.id = key
		frame.searchFrames = {}
		frame.buttonsList = setmetatable({}, {
			__index = function(self, key)
				local btn = CreateFrame("BUTTON", nil, frame.scrollChild)
				btn:SetPoint("RIGHT")
				v.dropDownMenuButtonInit(btn)
				self[key] = btn
				return btn
			end,
		})
		self[key] = frame
		return frame
	end,
})


local menu1 = dropDownMenusList[1]
-- CLOSE ON ESC
menu1:SetScript("OnKeyDown", function(self, key)
	if key == GetBindingKey("TOGGLEGAMEMENU") then
		self:Hide()
		self:SetPropagateKeyboardInput(false)
	else
		self:SetPropagateKeyboardInput(true)
	end
end)


-- CLOSE WHEN CLICK ON A FREE PLACE
local function ContainsMouse()
	for i = 1, #dropDownMenusList do
		local menu = dropDownMenusList[i]
		if menu:IsShown() and menu:IsMouseOver() then
			return true
		end
	end
	return false
end


local GetMouseFocus = GetMouseFocus
if not GetMouseFocus then
	local GetMouseFoci = GetMouseFoci
	GetMouseFocus = function() return GetMouseFoci()[1] end
end


local function ContainsFocus()
	local focus = GetMouseFocus()
	return focus and focus.LibSFDropDownNoGMEvent
end


menu1:SetScript("OnEvent", function(self, event, button)
	if event == "PLAYER_REGEN_DISABLED" then
		self:EnableKeyboard(false)
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:EnableKeyboard(true)
	elseif (button == "LeftButton" or button == "RightButton")
	and not (ContainsFocus() or ContainsMouse()) then
		self:Hide()
	end
end)
menu1:SetScript("OnShow", function(self)
	self:Raise()
	self:EnableKeyboard(not InCombatLockdown())
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("GLOBAL_MOUSE_DOWN")
end)
menu1:SetScript("OnHide", function(self)
	DropDownMenuList_OnHide(self)
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("GLOBAL_MOUSE_DOWN")
end)


---------------------------------------------------
-- DROPDOWN TOGGLE BUTTON
---------------------------------------------------
local function MenuReset(menu)
	menu.width = 0
	menu.height = 0
	menu.numButtons = 0
	menu:ClearAllPoints()
	wipe(menu.searchFrames)
end


local DropDownButtonMixin = v.dropDownButtonMixin


function DropDownButtonMixin:ddSetSelectedValue(value, level, anchorFrame)
	self.selectedValue = value
	self:ddRefresh(level, anchorFrame)
end


function DropDownButtonMixin:ddGetSelectedValue()
	return self.selectedValue
end


function DropDownButtonMixin:ddSetSelectedText(text, icon, iconInfo, iconOnly, fontObject, font)
	local normalFontObject = fontObject or self.Text.fontObject or GameFontHighlightSmall
	if font then
		self.Text:SetFontObject(v.getFontObject(self.Text, font, normalFontObject))
	else
		self.Text:SetFontObject(normalFontObject)
	end
	self.Text:SetText(text)

	if not self.Icon then return end
	if icon then
		self.Icon:Show()
		v.setIcon(self.Icon, icon, iconInfo, self.Left and 16 or 19)

		if iconOnly then
			if self.Left then
				self.Text:SetPoint("LEFT", self.Left, "RIGHT", 0, 1)
				self.Icon:SetPoint("LEFT", self.Left, "RIGHT", -2, 1)
				self.Icon:SetPoint("RIGHT", self.Right, "LEFT", -15, 1)
			else
				self.Text:SetPoint("LEFT", 8, 0)
				self.Icon:SetPoint("LEFT", 3, 0)
				self.Icon:SetPoint("RIGHT", self.Arrow, "LEFT", 3, 0)
			end
		else
			self.Icon:ClearAllPoints()
			if self.Left then
				self.Text:SetPoint("LEFT", self.Left, "RIGHT", self.Icon:GetWidth() - 2, 1)
				self.Icon:SetPoint("RIGHT", self.Text, "RIGHT", -math.min(self.Text:GetStringWidth(), self.Text:GetWidth()) - 1, 0)
			else
				self.Text:SetPoint("LEFT", self.Icon:GetWidth() + 6, 0)
				self.Icon:SetPoint("RIGHT", self.Text, "RIGHT", -math.min(self.Text:GetStringWidth(), self.Text:GetWidth()) - 2, 0)
			end
		end
	else
		self.Icon:Hide()
		if self.Left then
			self.Text:SetPoint("LEFT", self.Left, "RIGHT", 0, 1)
		else
			self.Text:SetPoint("LEFT", 8, 0)
		end
	end
end


function DropDownButtonMixin:ddSetInitFunc(initFunction)
	self.ddInitializeFunc = initFunction
end


function DropDownButtonMixin:ddInitialize(level, value, initFunction)
	if type(level) == "function" then
		initFunction = level
		level = nil
		value = nil
	elseif type(value) == "function" and not initFunction then
		initFunction = value
		value = nil
	end
	self:ddSetInitFunc(initFunction)

	if not self.ddAutoSetText then return end
	level = level or 1
	local menu = dropDownMenusList[level]
	menu.anchorFrame = self
	v.DROPDOWNBUTTON = self
	MenuReset(menu)
	if level == 1 and value == nil then
		value = self.ddMenuValue
	end
	self:ddInitializeFunc(level, value)

	for i = 1, menu.numButtons do
		local btn = menu.buttonsList[i]

		if not (btn.notCheckable or btn.isNotRadio) and btn.value == self:ddGetSelectedValue() then
			local text = type(btn.text) == "function" and btn:text(btn.arg1, btn.arg2) or btn.text
			self:ddSetSelectedText(text, btn.icon, btn.iconInfo, btn.iconOnly, btn.fontObject, btn.font)
		end

		btn:Hide()
		if btn.colorSwatch then
			btn.colorSwatch:Hide()
			btn.colorSwatch = nil
		end
	end

	for i = 1, #menu.searchFrames do
		local searchFrame = menu.searchFrames[i]

		for j = 1, #searchFrame.buttons do
			local btn = searchFrame.buttons[j]

			if not (btn.notCheckable or btn.isNotRadio) and btn.value == self:ddGetSelectedValue() then
				local text = type(btn.text) == "function" and btn:text(btn.arg1, btn.arg2) or btn.text
				self:ddSetSelectedText(text, btn.icon, btn.iconInfo, btn.iconOnly, btn.fontObject, btn.font)
				break
			end
		end

		searchFrame:Hide()
	end
end


function DropDownButtonMixin:ddSetDisplayMode(displayMode)
	self.ddDisplayMode = displayMode
end


function DropDownButtonMixin:ddSetAutoSetText(enabled)
	self.ddAutoSetText = enabled
end


function DropDownButtonMixin:ddSetMaxHeight(height)
	self.ddMaxHeight = height
end


function DropDownButtonMixin:ddSetMinMenuWidth(width)
	self.ddMinMenuWidth = width
end


function DropDownButtonMixin:ddSetOpenMenuUp(enabled)
	self.ddOpenMenuUp = enabled
end


function DropDownButtonMixin:ddIsOpenMenuUp()
	return self.ddOpenMenuUp and true or false
end


function DropDownButtonMixin:ddSetValue(value)
	self.ddMenuValue = value
end


function DropDownButtonMixin:ddSetMenuButtonHeight(height)
	self.ddMenuButtonHeight = height
end


function DropDownButtonMixin:ddSetNoGlobalMouseEvent(enabled, frame)
	(frame or self).LibSFDropDownNoGMEvent = enabled and true or nil
end


function DropDownButtonMixin:ddHideWhenButtonHidden(frame)
	if frame then
		frame:HookScript("OnHide", function() self:ddOnHide() end)
	else
		self:HookScript("OnHide", self.ddOnHide)
	end
end


function DropDownButtonMixin:ddToggle(level, value, anchorFrame, point, rPoint, xOffset, yOffset)
	if not level then level = 1 end
	local menu = dropDownMenusList[level]

	if menu:IsShown() then
		menu:Hide()
		if level == 1 and menu.anchorFrame == anchorFrame then return end
	end
	menu.anchorFrame = anchorFrame
	menu:Show()

	if level == 1 then
		v.DROPDOWNBUTTON = self
		if value == nil then value = self.ddMenuValue end
	end
	MenuReset(menu)
	self:ddInitializeFunc(level, value)

	menu.width = math.max(menu.width, self.ddMinMenuWidth or v.dropDownMenuButtonHeight)
	menu.height = math.max(menu.height, self.ddMenuButtonHeight or v.dropDownMenuButtonHeight)
	menu.scrollChild:SetWidth(menu.width)
	menu.width = menu.width + 30
	menu.height = menu.height + 30
	local maxHeight = self.ddMaxHeight or UIParent:GetHeight()
	if menu.height > maxHeight then
		menu.height = maxHeight
		menu.width = menu.width + 20
		menu.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 15)
		menu.scrollBar:Show()
	else
		menu.scrollFrame:SetPoint("BOTTOMRIGHT", -15, 15)
		menu.scrollBar:Hide()
	end
	menu:SetSize(menu.width, menu.height)

	if type(point) == "number" then
		xOffset = point
		yOffset = rPoint
		point = nil
		rPoint = nil
	elseif type(rPoint) == "number" then
		yOffset = xOffset
		xOffset = rPoint
		rPoint = point
	end

	if anchorFrame == "cursor" then
		anchorFrame = UIParent
		local x, y = GetCursorPosition()
		local scale = UIParent:GetScale()
		xOffset = (xOffset or 0) + x / scale
		yOffset = (yOffset or 0) + y / scale
		if self:ddIsOpenMenuUp() then yOffset = yOffset - UIParent:GetHeight() end
	end

	if level == 1 then
		if not point then
			point, rPoint = "TOPLEFT", "BOTTOMLEFT"
			if self:ddIsOpenMenuUp() then point, rPoint = rPoint, point end
		end
		menu:SetPoint(point, anchorFrame, rPoint or point, xOffset or 0, yOffset or 0)
	else
		if not point then
			if anchorFrame.hasArrowUp then
				point, rPoint = "BOTTOMLEFT", "BOTTOMRIGHT"
			else
				point, rPoint = "TOPLEFT", "TOPRIGHT"
			end
		end
		if GetScreenWidth() - anchorFrame:GetRight() - 2 < menu.width then
			point, rPoint = rPoint, point
		end
		menu:SetPoint(point, anchorFrame, rPoint or point, xOffset or 0, yOffset or anchorFrame.hasArrowUp and -15 or 15)
	end

	-- fix scroll thumb disappear
	menu.scrollBar:SetScrollPercentage(0)
	for i = 1, #menu.searchFrames do
		local f = menu.searchFrames[i]
		f.scrollBox:SetScrollPercentage(0)
		f.scrollBox:ScrollToElementDataIndex(f.index)
	end

	local style = v.DROPDOWNBUTTON.ddDisplayMode
	if style == "menu" then
		style = v.menuStyle
	elseif not menu.styles[style] then
		style = v.defaultStyle
	end
	menu.activeStyle:Hide()
	menu.activeStyle = menu.styles[style]
	menu.activeStyle:Show()
end


do
	local function RefreshButton(self, btn, setText)
		if type(btn.disabled) == "function" then
			btn:SetEnabled(not btn:disabled(btn.arg1, btn.arg2))
		end

		if type(btn.text) == "function" then
			btn._text = btn:text(btn.arg1, btn.arg2)
			btn:SetText(btn._text)
		end

		if not btn.notCheckable then
			if type(btn.checked) == "function" then
				btn._checked = btn:checked(btn.arg1, btn.arg2)
			elseif self.ddAutoSetText and btn.checked == nil and not btn.isNotRadio then
				btn._checked = btn.value == self:ddGetSelectedValue()
			end
			btn.Check:SetShown(btn._checked and btn._checked ~= 2)
			btn.UnCheck:Show()
			btn.GroupCheck:SetShown(btn._checked == 2)

			if setText and btn._checked and not btn.isNotRadio then
				self:ddSetSelectedText(btn._text, btn.icon, btn.iconInfo, btn.iconOnly, btn.fontObject, btn.font)
			end
		end
	end


	function DropDownButtonMixin:ddRefresh(level, anchorFrame)
		if not level then level = 1 end
		if not anchorFrame then anchorFrame = self end
		local menu = dropDownMenusList[level]
		local setText = self.ddAutoSetText and menu.anchorFrame == anchorFrame

		for i = 1, #menu.buttonsList do
			local btn = menu.buttonsList[i]
			if not btn:IsShown() then break end
			RefreshButton(self, btn, setText)
		end

		for i = 1, #menu.searchFrames do
			local scrollBox = menu.searchFrames[i].scrollBox
			if not scrollBox:IsShown() then break end
			local buttons = scrollBox.view:GetFrames()
			for j = 1, #buttons do
				local btn = buttons[j]
				if btn:IsShown() then
					RefreshButton(self, btn, setText)
				end
			end
		end
	end
end


function DropDownButtonMixin:ddIsMenuShown(level)
	if self == v.DROPDOWNBUTTON then
		local menu = lib:GetMenu(level)
		if menu then return menu:IsShown() end
	end
	return false
end


function DropDownButtonMixin:ddCloseMenus(level)
	local menu = lib:GetMenu(level)
	if menu then menu:Hide() end
end


function DropDownButtonMixin:ddOnHide()
	if self == v.DROPDOWNBUTTON then
		self:ddCloseMenus()
	end
end


function DropDownButtonMixin:ddAddButton(info, level)
	if not level then level = 1 end
	local menu = dropDownMenusList[level]

	if info.list then
		if #info.list > (info.listMaxSize or v.dropDownSearchListMaxSize) then
			local searchFrame = GetDropDownSearchFrame()
			local width, height = searchFrame:init(menu, info)

			menu.width = math.max(menu.width, width)
			menu.height = menu.height + height

			menu.searchFrames[#menu.searchFrames + 1] = searchFrame
		else
			for i = 1, #info.list do
				self:ddAddButton(info.list[i], level)
			end
		end
		return
	end

	if info.customFrame then
		local frame = info.customFrame
		frame:SetParent(menu.scrollChild)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", 0, -menu.height)

		menu.width = math.max(menu.width, frame:GetWidth())
		menu.height = menu.height + frame:GetHeight()

		if not info.fixedWidth then
			frame:SetPoint("RIGHT")
		end
		frame:Show()
		if info.OnLoad then info.OnLoad(frame) end

		menu.customFrames = menu.customFrames or {}
		menu.customFrames[#menu.customFrames + 1] = frame
		return
	end

	menu.numButtons = menu.numButtons + 1
	local btn = menu.buttonsList[menu.numButtons]
	local width = 0
	local menuButtonHeight = self.ddMenuButtonHeight or v.dropDownMenuButtonHeight
	btn:SetHeight(menuButtonHeight)

	for i = 1, #v.dropDownOptions do
		local opt = v.dropDownOptions[i]
		btn[opt] = info[opt]
	end

	local disabled = btn.disabled
	if type(disabled) == "function" then disabled = disabled(btn, btn.arg1, btn.arg2) end
	if disabled or btn.isTitle then
		btn:Disable()
	else
		btn:Enable()
	end

	btn._text = btn.text
	if btn._text then
		v.setButtonFont(btn)
		if type(btn._text) == "function" then btn._text = btn:_text(btn.arg1, btn.arg2) end
		btn:SetText(btn._text)
		width = width + btn.NormalText:GetWidth()
	else
		btn:SetText("")
	end

	local textPos = -5
	local hasArrow = btn.hasArrow or btn.hasArrowUp
	if hasArrow then
		textPos = -12
	end
	btn.ExpandArrow:SetShown(hasArrow)

	if btn.hasColorSwatch then
		btn.colorSwatch = GetColorSwatchFrame()
		btn.colorSwatch:SetParent(btn)
		btn.colorSwatch:SetPoint("RIGHT", textPos, 0)
		textPos = textPos - 17
		btn.colorSwatch.color:SetVertexColor(btn.r, btn.g, btn.b)
		btn.colorSwatch:Show()
		if not btn.func then
			btn.func = function() btn.colorSwatch:Click() end
		end
	end

	btn._rightText = btn.rightText
	if btn._rightText then
		btn.rightString = v.fontStringRightPool:Acquire()
		btn.rightString:SetParent(btn)
		btn.rightString:SetPoint("RIGHT", textPos, 0)
		v.setRightFont(btn)
		if type(btn._rightText) == "function" then btn._rightText = btn:_rightText(btn.arg1, btn.arg2) end
		btn.rightString:SetText(btn._rightText)
		btn.rightString:SetJustifyH("RIGHT")
		btn.rightString:Show()
		textPos = textPos - btn.rightString:GetWidth()
	end

	if btn.remove then
		btn.removePostion = textPos
		textPos = textPos - 17
	end

	if btn.order then
		btn.orderPosition = textPos
		textPos = textPos - 25
	end

	if btn.widgets then
		btn.widgetPosition = textPos
		for i = 1, #btn.widgets do
			textPos = textPos - (btn.widgets[i].width or menuButtonHeight)
		end
	end

	if btn.icon then
		v.setIcon(btn.Icon, btn.icon, btn.iconInfo, menuButtonHeight)

		if btn.iconOnly then
			btn.Icon:SetDrawLayer("BACKGROUND")
			btn.Icon:SetPoint("RIGHT")
		else
			btn.Icon:SetDrawLayer("ARTWORK")
			btn.Icon:ClearAllPoints()
			width = width + btn.Icon:GetWidth() + 2
		end
		btn.Icon:Show()
	else
		btn.Icon:Hide()
	end

	local indent = btn.indent or 0
	textPos = textPos == -5 and 0 or textPos - 2
	width = width + indent - textPos

	btn.NormalText:ClearAllPoints()
	if btn.notCheckable then
		btn.Check:Hide()
		btn.UnCheck:Hide()
		btn.GroupCheck:Hide()
		if btn.icon then
			btn.Icon:SetPoint("LEFT", indent, 0)
			if not btn.iconOnly then
				indent = indent + btn.Icon:GetWidth() + 2
			end
		end

		if btn.justifyH == "CENTER" then
			btn.NormalText:SetPoint("CENTER", (indent + textPos) / 2, 0)
		elseif btn.justifyH == "RIGHT" then
			btn.NormalText:SetPoint("RIGHT", textPos, 0)
		else
			btn.NormalText:SetPoint("LEFT", indent, 0)
		end
	else
		btn.Check:SetPoint("LEFT", indent, 0)
		btn.UnCheck:SetPoint("LEFT", indent, 0)
		if btn.icon then
			btn.Icon:SetPoint("LEFT", 20 + indent, 0)
			if not btn.iconOnly then
				indent = indent + btn.Icon:GetWidth() + 2
			end
		end
		btn.NormalText:SetPoint("LEFT", 20 + indent, 0)
		width = width + 22

		btn._checked = btn.checked
		if type(btn._checked) == "function" then
			btn._checked = btn:_checked(btn.arg1, btn.arg2)
		elseif v.DROPDOWNBUTTON.ddAutoSetText and btn._checked == nil and not btn.isNotRadio then
			btn._checked = btn.value == v.DROPDOWNBUTTON:ddGetSelectedValue()
		end

		if btn.isNotRadio or btn._checked == 2 then
			btn.Check:SetAtlas("common-dropdown-icon-checkmark-yellow", true)
			btn.UnCheck:SetAtlas("common-dropdown-ticksquare", true)
		else
			btn.Check:SetAtlas("common-dropdown-icon-radialtick-yellow", true)
			btn.UnCheck:SetAtlas("common-dropdown-tickradial", true)
		end

		btn.Check:SetShown(btn._checked and btn._checked ~= 2)
		btn.UnCheck:Show()
		btn.GroupCheck:SetShown(btn._checked == 2)
	end

	btn:SetPoint("TOPLEFT", 0, -menu.height)
	btn:Show()

	menu.height = menu.height + menuButtonHeight
	menu.width = math.max(menu.width, width)
end


function DropDownButtonMixin:ddAddSeparator(level)
	local info = {
		disabled = true,
		notCheckable = true,
		iconOnly = true,
		icon = "Interface/Common/UI-TooltipDivider-Transparent",
		iconInfo = {
			tSizeX = 0,
			tSizeY = 8,
		},
	}
	self:ddAddButton(info, level)
end


function DropDownButtonMixin:ddAddSpace(level)
	local info = {
		disabled = true,
		notCheckable = true,
	}
	self:ddAddButton(info, level)
end


DropDownButtonMixin.ddEasyMenuInitialize = function(self, level, menuList)
	for i = 1, #menuList do
		local info = menuList[i]
		if info.menuList then
			info.hasArrow = true
			info.value = info.menuList
		end
		if info.list then
			for j = 1, #info.list do
				local subInfo = info.list[j]
				if subInfo.menuList then
					subInfo.hasArrow = true
					subInfo.value = subInfo.menuList
				end
			end
		end
		self:ddAddButton(info, level)
	end
end


function DropDownButtonMixin:ddEasyMenu(menuList, anchorFrame, xOffset, yOffset, displayMode)
	self:ddSetDisplayMode(displayMode)
	self:ddInitialize(1, menuList, self.ddEasyMenuInitialize)
	self:ddToggle(1, menuList, anchorFrame, xOffset, yOffset)
end


-- SET PROXY
for funcName in next, DropDownButtonMixin do
	v.dropDownButtonProxy[funcName] = function(...) return DropDownButtonMixin[funcName](...) end
end


---------------------------------------------------
-- LIBRARY METHODS
---------------------------------------------------
local libMethods = lib._m.__index


function libMethods:GetMenu(level)
	return rawget(dropDownMenusList, level or 1)
end


function libMethods:IterateMenus()
	return ipairs(dropDownMenusList)
end


function libMethods:IterateMenuButtons(level)
	local menu = self:GetMenu(level)
	if menu then
		return ipairs(menu.buttonsList)
	else
		error("The menu with a level "..level.." dosn't exist.")
	end
end


function libMethods:IterateSearchFrames()
	return ipairs(dropDownSearchFrames)
end


function libMethods:IterateSearchFrameButtons(num)
	local searchFrame = dropDownSearchFrames[num]
	if searchFrame then
		return ipairs({searchFrame.scrollBox:GetScrollTarget():GetChildren()})
	else
		error("SearchFrame number "..num.." dosn't exist.")
	end
end


function libMethods:CreateMenuStyle(name, overwrite, frameFunc)
	if type(overwrite) == "function" then
		frameFunc = overwrite
		overwrite = nil
	end
	if type(name) == "string" and type(frameFunc) == "function" then
		if menuStyles[name] then
			if overwrite and name ~= "backdrop" and name ~= "menuBackdrop" then
				for i = 1, #dropDownMenusList do
					local styles = dropDownMenusList[i].styles
					styles[name]:Hide()
					styles[name] = nil
				end
				menuStyles[name] = nil
			else
				return false
			end
		end
		for i = 1, #dropDownMenusList do
			self._v.createMenuStyle(dropDownMenusList[i], name, frameFunc)
		end
		menuStyles[name] = frameFunc
		return true
	end
end


function libMethods:SetDefaultStyle(name)
	if menuStyles[name] then
		v.defaultStyle = name
	else
		error("The style named \""..name.."\" dosn't exist.")
	end
end


function libMethods:SetMenuStyle(name)
	if menuStyles[name] then
		v.menuStyle = name
	else
		error("The style named \""..name.."\" dosn't exist.")
	end
end


function libMethods:SetMixin(btn)
	for k, v in next, self._v.dropDownButtonProxy do
		btn[k] = v
	end
	return btn
end


function libMethods:IterateCreatedButtons()
	return ipairs(self._v.dropDownCreatedButtons)
end


function libMethods:IterateCreatedModernButtons()
	return ipairs(self._v.dropDownCreatedModernButtons)
end


function libMethods:IterateCreatedStretchButtons()
	return ipairs(self._v.dropDownCreatedStretchButtons)
end


local function DropDownTooltip_OnEnter(self)
	if self.Text:IsTruncated() then
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
		GameTooltip:SetText(self.Text:GetText())
		GameTooltip:Show()
	end
end


local function DropDownTooltip_OnLeave()
	GameTooltip:Hide()
end


do
	local function SetEnabled(self, enabled)
		self.Button:SetEnabled(enabled)
		self.Icon:SetDesaturated(not enabled)
		local color = enabled and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR
		self.Text:SetTextColor(color:GetRGB())
	end


	local function Enable(self)
		self:SetEnabled(true)
	end


	local function Disable(self)
		self:SetEnabled(false)
	end


	local function Button_OnClick(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		local parent = self:GetParent()
		parent:ddToggle(1, nil, parent, -5, 3 * (parent:ddIsOpenMenuUp() and -1 or 1))
	end


	function libMethods:CreateButtonOriginal(parent, width)
		self.CreateButtonOriginal = nil

		local btn = CreateFrame("FRAME", nil, parent)
		btn:SetSize(width or 135, 24)
		btn:SetScript("OnEnter", DropDownTooltip_OnEnter)
		btn:SetScript("OnLeave", DropDownTooltip_OnLeave)

		self:SetMixin(btn)
		btn:ddSetAutoSetText(true)
		btn:ddHideWhenButtonHidden()
		btn.SetEnabled = SetEnabled
		btn.Enable = Enable
		btn.Disable = Disable

		btn.Left = btn:CreateTexture(nil, "BACKGROUND")
		btn.Left:SetTexture("Interface/Glues/CharacterCreate/CharacterCreate-LabelFrame")
		btn.Left:SetSize(25, 64)
		btn.Left:SetPoint("LEFT", -15, 0)
		btn.Left:SetTexCoord(0, .1953125, 0, 1)

		btn.Right = btn:CreateTexture(nil, "BACKGROUND")
		btn.Right:SetTexture("Interface/Glues/CharacterCreate/CharacterCreate-LabelFrame")
		btn.Right:SetSize(25, 64)
		btn.Right:SetPoint("RIGHT", 15, 0)
		btn.Right:SetTexCoord(.8046875, 1, 0, 1)

		btn.Middle = btn:CreateTexture(nil, "BACKGROUND")
		btn.Middle:SetTexture("Interface/Glues/CharacterCreate/CharacterCreate-LabelFrame")
		btn.Middle:SetHeight(64)
		btn.Middle:SetPoint("LEFT", btn.Left, "RIGHT")
		btn.Middle:SetPoint("RIGHT", btn.Right, "LEFT")
		btn.Middle:SetTexCoord(.1953125, .8046875, 0, 1)

		btn.Text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		btn.Text:SetWordWrap(false)
		btn.Text:SetJustifyH("RIGHT")
		btn.Text:SetPoint("LEFT", btn.Left, "RIGHT", 0, 2)
		btn.Text:SetPoint("RIGHT", btn.Right, "LEFT", -17, 2)

		btn.Icon = btn:CreateTexture(nil, "ARTWORK")

		btn.Mask = btn:CreateMaskTexture()
		btn.Mask:SetTexture("interface/masks/squaremask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		btn.Mask:SetPoint("LEFT", 0, 1)
		btn.Mask:SetPoint("RIGHT", 0, 1)
		btn.Mask:SetHeight(16)

		btn.Icon:AddMaskTexture(btn.Mask)

		btn.Button = CreateFrame("BUTTON", nil, btn)
		btn.Button:SetMotionScriptsWhileDisabled(true)
		btn.Button:SetSize(26, 26)
		btn.Button:SetPoint("RIGHT", btn.Right, "LEFT", 9, 1)
		btn.Button:SetNormalTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Up")
		btn.Button:SetPushedTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Down")
		btn.Button:SetDisabledTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Disabled")
		btn.Button:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
		btn.Button:GetHighlightTexture():SetBlendMode("ADD")
		btn.Button:SetScript("OnClick", Button_OnClick)
		btn:ddSetNoGlobalMouseEvent(true, btn.Button)

		return btn
	end


	function libMethods:CreateButton(...)
		local btn = self:CreateButtonOriginal(...)
		self._v.dropDownCreatedButtons[#self._v.dropDownCreatedButtons + 1] = btn
		return btn
	end
end


do
	local function updateState(self)
		if self:IsEnabled() then
			if self.down and self.over then
				self.Arrow:SetAtlas("common-dropdown-a-button-pressedhover", true)
			elseif self.over then
				self.Arrow:SetAtlas("common-dropdown-a-button-hover", true)
			elseif self.down then
				self.Arrow:SetAtlas("common-dropdown-a-button-pressed", true)
			else
				self.Arrow:SetAtlas("common-dropdown-a-button", true)
			end
		else
			self.Arrow:SetAtlas("common-dropdown-a-button-disabled", true)
		end
	end


	local function OnEnter(self)
		self.over = true
		updateState(self)
		DropDownTooltip_OnEnter(self)
	end


	local function OnLeave(self)
		self.over = nil
		updateState(self)
		DropDownTooltip_OnLeave(self)
	end


	local function OnMouseDown(self)
		self.down = true
		updateState(self)
	end


	local function OnMouseUp(self)
		self.down = nil
		updateState(self)
	end


	local function OnClick(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self:ddToggle(1, nil, self, -5, 0)
	end


	local function OnEnable(self)
		self.Icon:SetDesaturated()
		self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
		updateState(self)
	end


	local function OnDisable(self)
		self.Icon:SetDesaturated(true)
		self.Text:SetTextColor(GRAY_FONT_COLOR:GetRGB())
		updateState(self)
	end


	function libMethods:CreateModernButtonOriginal(parent, width)
		self.CreateModernButtonOriginal = nil

		local btn = CreateFrame("BUTTON", nil, parent)
		width = width or 135
		btn:SetSize(width, 25)
		btn:SetScript("OnEnter", OnEnter)
		btn:SetScript("OnLeave", OnLeave)
		btn:SetScript("OnMouseDown", OnMouseDown)
		btn:SetScript("OnMouseUp", OnMouseUp)
		btn:SetScript("OnEnable", OnEnable)
		btn:SetScript("OnDisable", OnDisable)
		btn:SetScript("OnClick", OnClick)
		btn:SetMotionScriptsWhileDisabled(true)

		self:SetMixin(btn)
		btn:ddSetAutoSetText(true)
		btn:ddSetDisplayMode("menu")
		btn:ddHideWhenButtonHidden()
		btn:ddSetNoGlobalMouseEvent(true)
		btn:ddSetMinMenuWidth(width - 20)

		btn.Background = btn:CreateTexture(nil, "BACKGROUND")
		btn.Background:SetPoint("TOPLEFT", -8, 7)
		btn.Background:SetPoint("BOTTOMRIGHT", 8, -9)
		btn.Background:SetAtlas("common-dropdown-textholder", true)

		btn.Arrow = btn:CreateTexture(nil, "OVERLAY")
		btn.Arrow:SetPoint("RIGHT", 1, -3)
		btn.Arrow:SetAtlas("common-dropdown-a-button", true)

		btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		btn.Text.fontObject = GameFontHighlight
		btn.Text:SetWordWrap(false)
		btn.Text:SetJustifyH("RIGHT")
		btn.Text:SetHeight(10)
		btn.Text:SetPoint("RIGHT", btn.Arrow, "LEFT")
		btn.Text:SetPoint("LEFT", 8, 0)

		btn.Icon = btn:CreateTexture(nil, "ARTWORK")

		btn.Mask = btn:CreateMaskTexture()
		btn.Mask:SetTexture("interface/masks/squaremask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		btn.Mask:SetPoint("LEFT")
		btn.Mask:SetPoint("RIGHT")
		btn.Mask:SetHeight(19)

		btn.Icon:AddMaskTexture(btn.Mask)

		return btn
	end


	function libMethods:CreateModernButton(...)
		local btn = self:CreateModernButtonOriginal(...)
		self._v.dropDownCreatedModernButtons[#self._v.dropDownCreatedModernButtons + 1] = btn
		return btn
	end
end


do
	local function OnClick(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self:ddToggle(1, nil, self, self:GetWidth() - 13, (self:GetHeight() / 2 + 2) * (self:ddIsOpenMenuUp() and -1 or 1))
	end


	function libMethods:CreateStretchButtonOriginal(parent, width, height, wrap)
		self.CreateStretchButtonOriginal = nil

		local btn = CreateFrame("BUTTON", nil, parent, "UIMenuButtonStretchTemplate")
		if width then btn:SetWidth(width) end
		if height then btn:SetHeight(height) end
		if wrap == nil then wrap = false end
		btn:SetScript("OnClick", OnClick)
		btn:SetScript("OnEnter", DropDownTooltip_OnEnter)
		btn:SetScript("OnLeave", DropDownTooltip_OnLeave)
		btn:SetMotionScriptsWhileDisabled(true)

		self:SetMixin(btn)
		btn:ddSetDisplayMode("menu")
		btn:ddHideWhenButtonHidden()
		btn:ddSetNoGlobalMouseEvent(true)

		btn.Arrow = btn:CreateTexture(nil, "ARTWORK")
		btn.Arrow:SetTexture("Interface/ChatFrame/ChatFrameExpandArrow")
		btn.Arrow:SetSize(10, 12)
		btn.Arrow:SetPoint("RIGHT", -5, 0)

		btn:SetText(" ")
		btn.Text = btn:GetFontString()
		btn.Text:SetWordWrap(wrap)
		btn.Text:ClearAllPoints()
		btn.Text:SetPoint("TOP", 0, -4)
		btn.Text:SetPoint("BOTTOM", 0, 4)
		btn.Text:SetPoint("LEFT", 4, 0)
		btn.Text:SetPoint("RIGHT", -15, 0)

		return btn
	end


	function libMethods:CreateStretchButton(...)
		local btn = self:CreateStretchButtonOriginal(...)
		self._v.dropDownCreatedStretchButtons[#self._v.dropDownCreatedStretchButtons + 1] = btn
		return btn
	end
end


---------------------------------------------------
-- UPDATE OLD VERSION
---------------------------------------------------
if oldminor == 0 then return end

if oldminor < 4 then
	for i, menu in lib:IterateMenus() do
		menu.scrollFrame:SetScript("OnVerticalScroll", DropDownMenuListScrollFrame_OnVerticalScroll)
		menu.scrollFrame:SetScript("OnScrollRangeChanged", DropDownMenuListScrollFrame_OnScrollRangeChanged)
		menu.scrollFrame:SetScript("OnMouseWheel", DropDownMenuListScrollFrame_OnMouseWheel)
	end
end

if oldminor < 5 then
	for i, f in lib:IterateSearchFrames() do
		for callbackType, callbackTable in pairs(f.view:GetCallbackTables()) do
			local callbacks = callbackTable[f.view.Event.OnAcquiredFrame]
			if callbacks then wipe(callbacks) end
		end
	end
end

if oldminor < 7 then
	local function updateBtn(btn)
		btn.GroupCheck = btn:CreateTexture(nil, "ARTWORK", nil, 2)
		btn.GroupCheck:SetColorTexture(1, .8, 0)
		btn.GroupCheck:SetSize(8, 8)
		btn.GroupCheck:SetPoint("CENTER", btn.UnCheck)
	end

	for i, menu in lib:IterateMenus() do
		setmetatable(menu.buttonsList, {
			__index = function(self, key)
				local btn = CreateFrame("BUTTON", nil, menu.scrollChild)
				btn:SetPoint("RIGHT")
				v.dropDownMenuButtonInit(btn)
				self[key] = btn
				return btn
			end,
		})

		for j, btn in lib:IterateMenuButtons(i) do
			if not btn.GroupCheck then updateBtn(btn) end
		end
	end

	for i in lib:IterateSearchFrames() do
		for j, btn in lib:IterateSearchFrameButtons(i) do
			if not btn.GroupCheck then updateBtn(btn) end
		end
	end
end

if oldminor < 8 then
	for i = 1, #v.dropDownCreatedButtons do
		lib:SetMixin(v.dropDownCreatedButtons[i])
	end

	for i = 1, #v.dropDownCreatedStretchButtons do
		lib:SetMixin(v.dropDownCreatedStretchButtons[i])
	end
end

if oldminor < 9 then
	if v.menuStyle == "menuBackdrop" then
		v.menuStyle = "modernMenu"
	end

	for i, menu in lib:IterateMenus() do
		if not menu:IsShown() then
			for _, style in next, menu.styles do
				style:Hide()
			end
		end
		if not menu.styles.modernMenu and v.menuStyles.modernMenu then
			v.createMenuStyle(menu, "modernMenu", v.menuStyles.modernMenu)
		end
	end
end

if oldminor < 10 then
	local function updateButton(btn)
		btn:SetScript("OnClick", DropDownMenuButton_OnClick)

		btn.Check:SetDrawLayer("ARTWORK", 2)
		btn.Check:SetTexCoord(0, 1, 0, 1)

		btn.UnCheck:SetDrawLayer("ARTWORK", 1)
		btn.UnCheck:SetTexCoord(0, 1, 0, 1)

		btn.GroupCheck:SetDrawLayer("ARTWORK", 2)
		btn.GroupCheck:SetPoint("CENTER", btn.UnCheck)
	end

	for i in lib:IterateMenus() do
		for j, btn in lib:IterateMenuButtons(i) do
			updateButton(btn)
		end
	end

	for i in lib:IterateSearchFrames() do
		for j, btn in lib:IterateSearchFrameButtons(i) do
			updateButton(btn)
		end
	end
end

if oldminor < 12 then
	for i in lib:IterateMenus() do
		for j, btn in lib:IterateMenuButtons(i) do
			btn:SetScript("OnClick", DropDownMenuButton_OnClick)
		end
	end

	for i in lib:IterateSearchFrames() do
		for j, btn in lib:IterateSearchFrameButtons(i) do
			btn:SetScript("OnClick", DropDownMenuButton_OnClick)
		end
	end
end

if oldminor < 15 then
	v.dropDownCreatedModernButtons = {}
end

if oldminor < 17 then
	for i, menu in lib:IterateMenus() do
		if not menu.activeStyle then
			menu.activeStyle = menu.styles[v.defaultStyle]
		end
	end
end

if oldminor < 26 then
	for i, f in lib:IterateSearchFrames() do
		for k, v in next, DropDownMenuSearchMixin do f[k] = v end
		f.buttonsList = nil
		f.view:SetElementInitializer("BUTTON", DropDownMenuSearchButtonInit)
		f.view:RegisterCallback(f.view.Event.OnAcquiredFrame, DropDownMenuSearchButton_OnAcquired, f)
	end
end

if oldminor < 28 then
	for i, menu in lib:IterateMenus() do
		menu.scrollFrame:SetScript("OnVerticalScroll", DropDownMenuListScrollFrame_OnVerticalScroll)
		menu.scrollFrame:SetScript("OnMouseWheel", DropDownMenuListScrollFrame_OnMouseWheel)
		menu.scrollFrame:SetScript("OnEnter", nil)

		menu.scrollBar:SetScript("OnEnter", nil)
		menu.scrollBar.Back:SetScript("OnEnter", MinimalScrollBarStepperScriptsMixin.OnEnter)
		menu.scrollBar.Forward:SetScript("OnEnter", MinimalScrollBarStepperScriptsMixin.OnEnter)
		menu.scrollBar.Track:SetScript("OnEnter", nil)
		menu.scrollBar.Track.Thumb:SetScript("OnEnter", MinimalScrollBarThumbScriptsMixin.OnEnter)

		if i ~= 1 then
			menu:SetScript("OnHide", DropDownMenuList_OnHide)
		end
		for j, btn in lib:IterateMenuButtons(i) do
			btn:SetScript("OnEnter", DropDownMenuButton_OnEnter)
			btn:SetScript("OnLeave", DropDownMenuButton_OnLeave)
			btn:SetScript("OnHide", DropDownMenuButton_OnHide)
		end
	end

	for i, f in lib:IterateSearchFrames() do
		f.scrollBox:RegisterCallback(f.scrollBox.Event.OnScroll, DropDownMenuScrollBox_OnScroll, f)

		f.scrollBar:SetScript("OnEnter", nil)
		f.scrollBar.Back:SetScript("OnEnter", MinimalScrollBarStepperScriptsMixin.OnEnter)
		f.scrollBar.Forward:SetScript("OnEnter", MinimalScrollBarStepperScriptsMixin.OnEnter)
		f.scrollBar.Track:SetScript("OnEnter", nil)
		f.scrollBar.Track.Thumb:SetScript("OnEnter", MinimalScrollBarThumbScriptsMixin.OnEnter)

		for j, btn in lib:IterateSearchFrameButtons(i) do
			btn:SetScript("OnEnter", DropDownMenuButton_OnEnter)
			btn:SetScript("OnLeave", DropDownMenuButton_OnLeave)
			btn:SetScript("OnHide", DropDownMenuButton_OnHide)
		end
	end

	for i = 1, #v.widgetFrames do
		local widget = v.widgetFrames[i]
		widget:SetScript("OnEnter", widget_OnEnter)
		widget:SetScript("OnLeave", widget_OnLeave)
	end
end