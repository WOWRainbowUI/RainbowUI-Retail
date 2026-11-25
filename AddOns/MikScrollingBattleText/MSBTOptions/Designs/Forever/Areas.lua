
local MSBTWindow = MSBTOptions.Window
local MSBTControls = MSBTOptions.Controls
local MSBTPopups = MSBTOptions.Popups
local MSBTProfiles = MikSBT.Profiles
local MSBTAnimations = MikSBT.Animations
local Areas = MSBTOptions.Tabs.scrollAreas
local L = MikSBT.translations

local EraseTable = MikSBT.EraseTable
local COLORS = MSBTWindow.COLORS
local DEFAULTS = MSBTPopups.SCROLL_AREA_DEFAULTS



local PANEL_WIDTH = 270
local CONTROL_WIDTH = 114
local COLUMN_LEFT = 12
local COLUMN_RIGHT = 144
local ROW_HEIGHT = 24
local BUTTON_HEIGHT = 22
local SKETCH_MAX_HEIGHT = 240
-- About as long as a preview line stays on the screen at the default speed.
local PREVIEW_TIME = 3

-- Normal text on the left, sticky text on the right; the keys name the area fields.
local STYLE_COLUMNS = {
	{ x = COLUMN_LEFT, styles = "animationStyles", style = "animationStyle",
		direction = "direction", behavior = "behavior", textAlign = "textAlignIndex" },
	{ x = COLUMN_RIGHT, styles = "stickyAnimationStyles", style = "stickyAnimationStyle",
		direction = "stickyDirection", behavior = "stickyBehavior", textAlign = "stickyTextAlignIndex" },
}



local content
local listbox
local sketch
local panel
local titleFontString
local deleteButton
local xEditbox
local yEditbox
local heightSlider
local widthSlider
local speedSlider
local inheritCheckbox
local iconDropdown
local hideIconsCheckbox
local mergePetAreaCheckbox
local scale
local sketchMaxWidth
local screenWidth
local screenHeight
local boxes = {}
local keys = {}
local configTable = {}
local selected
local filling
local Select



local function Settings()
	return MSBTAnimations.scrollAreas[selected]
end


local function ByName(a, b)
	return MSBTAnimations.scrollAreas[a].name < MSBTAnimations.scrollAreas[b].name
end


local function CreateText(parent, template, color)
	local fontString = parent:CreateFontString(nil, "OVERLAY", template)
	fontString:SetJustifyH("LEFT")
	fontString:SetWordWrap(false)
	fontString:SetTextColor(color[1], color[2], color[3])
	return fontString
end


local function CreateButton(parent, label, tooltip, handler)
	local button = MSBTControls.CreateOptionButton(parent)
	button:Configure(BUTTON_HEIGHT, label, tooltip)
	button:SetClickHandler(handler)
	MSBTWindow.SkinButton(button)
	return button
end


local function CreateIconButton(icon, tooltip, handler)
	return MSBTWindow.CreateIconButton(panel, icon, tooltip, handler)
end



local OnBoxMouseDown
local OnBoxDragStop


local function OnBoxDragStart(this)
	this:StartMoving()
end


-- A box shows its name only while selected, so the tooltip names the others.
local function OnBoxEnter(this)
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1)
end


local function OnBoxLeave()
	GameTooltip:Hide()
end


-- Built on an area's first appearance and kept for it, also while it is not listed.
local function CreateBox(key)
	local box = CreateFrame("Frame", nil, sketch)
	box:EnableMouse(true)
	box:SetMovable(true)
	box:RegisterForDrag("LeftButton")
	box:SetScript("OnMouseDown", OnBoxMouseDown)
	box:SetScript("OnDragStart", OnBoxDragStart)
	box:SetScript("OnDragStop", OnBoxDragStop)
	box:SetScript("OnEnter", OnBoxEnter)
	box:SetScript("OnLeave", OnBoxLeave)
	box.border = MSBTWindow.Fill(box, COLORS.border)
	MSBTWindow.Fill(box, COLORS.line, "BORDER", 1)
	box.label = CreateText(box, "GameFontHighlightSmall", COLORS.text)
	box.label:SetPoint("CENTER")
	box.key = key
	boxes[key] = box
	return box
end


-- Boxes are anchored at the area's offset from the screen center, scaled to the sketch.
local function DrawBox(key)
	local settings = MSBTAnimations.scrollAreas[key]
	local box = boxes[key] or CreateBox(key)
	box:ClearAllPoints()
	box:SetPoint("BOTTOMLEFT", sketch, "CENTER", (settings.offsetX or 0) * scale, (settings.offsetY or 0) * scale)
	box:SetWidth((settings.scrollWidth or DEFAULTS.scrollWidth) * scale)
	box:SetHeight((settings.scrollHeight or DEFAULTS.scrollHeight) * scale)
	box.tooltip = settings.name
	box.label:SetText(settings.name)
	local isSelected = key == selected
	box.label:SetShown(isSelected)
	local color = isSelected and COLORS.gold or COLORS.border
	box.border:SetColorTexture(color[1], color[2], color[3])
	box:Show()
end


-- Shows the saved values of the selected area; filling keeps the controls from saving them back.
local function Fill()
	local settings = Settings()
	filling = true
	titleFontString:SetText(settings.name)
	if Areas.IsBuiltIn(selected) then deleteButton:Disable() else deleteButton:Enable() end

	for _, column in ipairs(STYLE_COLUMNS) do
		local style = settings[column.style] or DEFAULTS[column.style]
		MSBTPopups.FillStyleList(column.styleDropdown, MSBTAnimations[column.styles])
		column.styleDropdown:SetSelectedID(style)
		MSBTPopups.FillStyleDropdowns(MSBTAnimations[column.styles][style],
			column.directionDropdown, column.behaviorDropdown)
		if settings[column.direction] then column.directionDropdown:SetSelectedID(settings[column.direction]) end
		if settings[column.behavior] then column.behaviorDropdown:SetSelectedID(settings[column.behavior]) end
		column.textAlignDropdown:SetSelectedID(settings[column.textAlign] or DEFAULTS[column.textAlign])
	end

	-- Rewriting a field being typed in would drop a trailing "." or "-".
	if tonumber(xEditbox:GetText()) ~= (settings.offsetX or 0) then xEditbox:SetText(settings.offsetX or 0) end
	if tonumber(yEditbox:GetText()) ~= (settings.offsetY or 0) then yEditbox:SetText(settings.offsetY or 0) end
	heightSlider:SetValue(settings.scrollHeight or DEFAULTS.scrollHeight)
	widthSlider:SetValue(settings.scrollWidth or DEFAULTS.scrollWidth)

	local profileSpeed = MSBTProfiles.currentProfile.animationSpeed
	local isInherited = not settings.animationSpeed or settings.animationSpeed == profileSpeed
	inheritCheckbox:SetChecked(isInherited)
	if settings.animationSpeed then speedSlider:SetValue(settings.animationSpeed) end
	MSBTPopups.ToggleSliderInheritState(speedSlider, isInherited, profileSpeed)

	iconDropdown:SetSelectedID(settings.iconAlign or DEFAULTS.iconAlign)
	hideIconsCheckbox:SetChecked(settings.skillIconsDisabled)
	local destination = Areas.GetPetMergeDestination(selected)
	mergePetAreaCheckbox:SetShown(destination ~= nil)
	if destination then
		local locale = L.CHECKBOXES.mergePetScrollArea
		mergePetAreaCheckbox:SetLabel(locale.label:format(destination))
		mergePetAreaCheckbox:SetTooltip(locale.tooltip:format(destination))
		mergePetAreaCheckbox:SetChecked(settings.mergeWhenDisabled == true)
	end
	filling = false
end


Select = function(key)
	selected = key
	for index = 1, listbox:GetNumItems() do
		if listbox:GetItem(index) == key then
			-- Scrolls only as far as needed to show the row.
			listbox:SetOffset(math.max(index - listbox:GetNumLines(), math.min(listbox:GetOffset(), index - 1)))
			listbox:SetSelectedItem(index)
		end
	end
	listbox:Refresh()
	for _, other in ipairs(keys) do DrawBox(other) end
	boxes[key]:Raise()
	Fill()
end


-- The sketch shows a centered band of the screen, as wide as a 16:9 screen is, so a wider screen
-- does not shrink it. An area beyond the band widens the view just enough to hold it.
local function SizeSketch()
	screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()
	local viewWidth = math.min(screenWidth, screenHeight * 16 / 9)
	for _, settings in pairs(MSBTAnimations.scrollAreas) do
		local left = settings.offsetX or 0
		local right = left + (settings.scrollWidth or DEFAULTS.scrollWidth)
		viewWidth = math.max(viewWidth, 2 * math.abs(left), 2 * math.abs(right))
	end
	viewWidth = math.min(viewWidth, screenWidth)
	scale = math.min(sketchMaxWidth / viewWidth, SKETCH_MAX_HEIGHT / screenHeight)
	sketch:SetWidth(viewWidth * scale)
	sketch:SetHeight(screenHeight * scale)
end


-- The running addon reads the areas UpdateScrollAreas builds from the profile.
-- An area moved beyond the band widens the view, which scales every box.
local function Changed()
	MSBTAnimations.UpdateScrollAreas()
	local oldScale = scale
	SizeSketch()
	if scale ~= oldScale then
		for _, key in ipairs(keys) do DrawBox(key) end
	else
		DrawBox(selected)
	end
	Fill()
end


-- Saves one field of the selected area with the default the classic configuration saves it with.
local function Write(field, value)
	MSBTPopups.SaveScrollAreaOption(selected, field, value)
end


local function Save(field, value)
	if filling then return end
	Write(field, value)
	Changed()
end


local function Refresh()
	SizeSketch()
	EraseTable(keys)
	for key in pairs(MSBTAnimations.scrollAreas) do keys[#keys + 1] = key end
	table.sort(keys, ByName)

	local offset = listbox:GetOffset()
	listbox:Clear()
	for _, key in ipairs(keys) do listbox:AddItem(key) end
	listbox:SetOffset(offset)

	for _, box in pairs(boxes) do box:Hide() end
	Select(MSBTAnimations.scrollAreas[selected] and selected or keys[1])
end



OnBoxMouseDown = function(this)
	Select(this.key)
end


-- The drop point is read back in UI units and clamped so the whole area stays on the screen.
OnBoxDragStop = function(this)
	this:StopMovingOrSizing()
	local settings = Settings()
	local centerX, centerY = sketch:GetCenter()
	local x = math.floor((this:GetLeft() - centerX) / scale + 0.5)
	local y = math.floor((this:GetBottom() - centerY) / scale + 0.5)
	local maxX = math.floor(screenWidth / 2 - (settings.scrollWidth or DEFAULTS.scrollWidth))
	local maxY = math.floor(screenHeight / 2 - (settings.scrollHeight or DEFAULTS.scrollHeight))
	Write("offsetX", math.max(math.ceil(-screenWidth / 2), math.min(maxX, x)))
	Write("offsetY", math.max(math.ceil(-screenHeight / 2), math.min(maxY, y)))
	Changed()
end



local function CreateRow(this)
	local row = CreateFrame("Button", nil, this)
	local checkbox = MSBTControls.CreateCheckbox(row)
	checkbox:Configure(18, nil, L.CHECKBOXES.enableScrollArea.tooltip)
	checkbox:SetPoint("LEFT", row, "LEFT", 4, 0)
	checkbox:SetClickHandler(Areas.EnableOnClick)
	MSBTWindow.SkinCheckbox(checkbox)
	row.enableCheckbox = checkbox
	row.nameFontString = CreateText(row, "GameFontHighlight", COLORS.text)
	row.nameFontString:SetPoint("LEFT", row, "LEFT", 30, 0)
	return row
end


local function DisplayRow(this, row, key)
	local settings = MSBTAnimations.scrollAreas[key]
	row.scrollAreaKey = key
	row.enableCheckbox:SetChecked(not settings.disabled)
	row.nameFontString:SetText(settings.name)
end


local function OnClickRow(this, row, key)
	Select(key)
end



local function OnDropdownChanged(this, id)
	Save(this.field, id)
end


-- A new style offers its own directions and behaviors; the first of each is saved with it.
local function OnStyleChanged(this, id)
	local column = this.column
	MSBTPopups.FillStyleDropdowns(MSBTAnimations[column.styles][id], column.directionDropdown, column.behaviorDropdown)
	Write(column.style, id)
	Write(column.direction, column.directionDropdown:GetSelectedID())
	Write(column.behavior, column.behaviorDropdown:GetSelectedID())
	Changed()
end


local function OnSliderChanged(this, value)
	Save(this.field, value)
end


local function OnOffsetChanged(this)
	local value = tonumber(this:GetText())
	if value then Save(this.field, value) end
end


-- Inheriting moves the slider to the profile's speed, which saves the speed as inherited.
local function OnInheritClicked(this, isChecked)
	MSBTPopups.ToggleSliderInheritState(speedSlider, isChecked, MSBTProfiles.currentProfile.animationSpeed)
end


local function OnHideIconsClicked(this, isChecked)
	Save("skillIconsDisabled", isChecked)
end


local function ShowNameInput(anchor, defaultText, saveHandler)
	local locale = L.EDITBOXES.scrollAreaName
	EraseTable(configTable)
	configTable.defaultText = defaultText
	configTable.editboxLabel = locale.label
	configTable.editboxTooltip = locale.tooltip
	configTable.parentFrame = content
	configTable.anchorFrame = anchor
	configTable.anchorPoint = "TOP"
	configTable.relativePoint = "BOTTOM"
	configTable.validateHandler = Areas.ValidateName
	configTable.saveHandler = saveHandler
	configTable.saveArg1 = selected
	MSBTPopups.ShowInput(configTable)
end


local function OnAddSaved(settings)
	selected = Areas.Create(settings.inputText)
	Refresh()
end


local function OnClickAdd(this)
	ShowNameInput(this, L.MSG_NEW_SCROLL_AREA, OnAddSaved)
end


local function OnRenameSaved(settings)
	Areas.Rename(settings.saveArg1, settings.inputText)
	Refresh()
end


local function OnClickRename(this)
	ShowNameInput(this, Settings().name, OnRenameSaved)
end


local function OnDeleteConfirmed(key)
	Areas.Remove(key)
	Refresh()
end


local function OnClickDelete(this)
	EraseTable(configTable)
	configTable.parentFrame = content
	configTable.anchorFrame = this
	configTable.anchorPoint = "TOP"
	configTable.relativePoint = "BOTTOM"
	configTable.acknowledgeHandler = OnDeleteConfirmed
	configTable.saveArg1 = selected
	MSBTPopups.ShowAcknowledge(configTable)
end


local function OnClickFont()
	Areas.ShowFont(selected, content)
end


-- The window covers the screen center, so it steps aside while the test lines show. It comes back
-- through the registry, which opens nothing while the scroll areas are positioned.
local function OnClickPreview()
	MSBTWindow.Hide(true)
	MSBTPopups.PreviewScrollAreas()
	C_Timer.After(PREVIEW_TIME, MSBTOptions.Designs.Show)
end



local function CreateDropdown(localeKey, x, y, handler, field)
	local dropdown = MSBTControls.CreateDropdown(panel)
	local locale = L.DROPDOWNS[localeKey]
	dropdown:Configure(CONTROL_WIDTH, locale.label, locale.tooltip)
	dropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
	dropdown:SetChangeHandler(handler)
	MSBTWindow.SkinDropdown(dropdown)
	dropdown.field = field
	return dropdown
end


local function CreateSlider(localeKey, field, x, y)
	local slider = MSBTControls.CreateSlider(panel)
	local locale = L.SLIDERS[localeKey]
	slider:Configure(CONTROL_WIDTH, locale.label, locale.tooltip)
	slider:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
	MSBTPopups.ConfigureScrollAreaSlider(slider, field)
	slider:SetValueChangedHandler(OnSliderChanged)
	MSBTWindow.SkinSlider(slider)
	slider.field = field
	return slider
end


local function CreateEditbox(localeKey, field, x, y)
	local editbox = MSBTControls.CreateEditbox(panel)
	local locale = L.EDITBOXES[localeKey]
	editbox:Configure(CONTROL_WIDTH, locale.label, locale.tooltip)
	editbox:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
	editbox:SetTextChangedHandler(OnOffsetChanged)
	MSBTWindow.SkinEditbox(editbox)
	editbox.field = field
	return editbox
end


local function CreateCheckbox(localeKey, x, y, handler)
	local checkbox = MSBTControls.CreateCheckbox(panel)
	local locale = L.CHECKBOXES[localeKey]
	checkbox:Configure(18, locale.label, locale.tooltip)
	checkbox:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
	checkbox:SetClickHandler(handler)
	MSBTWindow.SkinCheckbox(checkbox)
	return checkbox
end


local function CreatePanel(height)
	panel = CreateFrame("Frame", nil, content)
	panel:SetPoint("TOPRIGHT", content, "TOPRIGHT")
	panel:SetWidth(PANEL_WIDTH)
	panel:SetHeight(height)
	MSBTWindow.Box(panel, COLORS.panel)

	titleFontString = CreateText(panel, "GameFontNormalLarge", COLORS.gold)
	titleFontString:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -12)
	titleFontString:SetWidth(PANEL_WIDTH - 110)
	deleteButton = CreateIconButton("Delete", L.BUTTONS.deleteScrollArea.tooltip, OnClickDelete)
	deleteButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -8)
	local renameButton = CreateIconButton("Settings", L.BUTTONS.editScrollAreaName.tooltip, OnClickRename)
	renameButton:SetPoint("RIGHT", deleteButton, "LEFT")
	local fontButton = CreateIconButton("Font", L.BUTTONS.scrollAreaFontSettings.tooltip, OnClickFont)
	fontButton:SetPoint("RIGHT", renameButton, "LEFT")

	for _, column in ipairs(STYLE_COLUMNS) do
		local dropdown = CreateDropdown(column.style, column.x, -40, OnStyleChanged, column.style)
		dropdown.column = column
		column.styleDropdown = dropdown
		column.directionDropdown = CreateDropdown("direction", column.x, -84, OnDropdownChanged, column.direction)
		column.behaviorDropdown = CreateDropdown("behavior", column.x, -128, OnDropdownChanged, column.behavior)
		dropdown = CreateDropdown("textAlign", column.x, -172, OnDropdownChanged, column.textAlign)
		for index, name in ipairs(L.TEXT_ALIGNS) do dropdown:AddItem(name, index) end
		column.textAlignDropdown = dropdown
	end

	xEditbox = CreateEditbox("xOffset", "offsetX", COLUMN_LEFT, -216)
	yEditbox = CreateEditbox("yOffset", "offsetY", COLUMN_RIGHT, -216)
	heightSlider = CreateSlider("scrollHeight", "scrollHeight", COLUMN_LEFT, -262)
	widthSlider = CreateSlider("scrollWidth", "scrollWidth", COLUMN_RIGHT, -262)
	speedSlider = CreateSlider("scrollAnimationSpeed", "animationSpeed", COLUMN_LEFT, -306)
	-- A language whose classic word for it reads like the footer's Apply has a word of its own.
	inheritCheckbox = CreateCheckbox(L.CHECKBOXES.inheritValue and "inheritValue" or "inheritField",
		COLUMN_RIGHT, -316, OnInheritClicked)

	iconDropdown = CreateDropdown("iconAlign", COLUMN_LEFT, -344, OnDropdownChanged, "iconAlign")
	iconDropdown:AddItem(L.TEXT_ALIGNS[1], "Left")
	iconDropdown:AddItem(L.TEXT_ALIGNS[3], "Right")
	hideIconsCheckbox = CreateCheckbox("hideSkillIcons", COLUMN_LEFT, -388, OnHideIconsClicked)
	mergePetAreaCheckbox = CreateCheckbox("mergePetScrollArea", COLUMN_LEFT, -414, function(_, isChecked)
		Save("mergeWhenDisabled", isChecked and true or nil)
	end)
end


-- Clipping keeps the box of an area placed off the screen from covering the controls around.
local function CreateSketch(width)
	sketchMaxWidth = width
	sketch = CreateFrame("Frame", nil, content)
	sketch:SetPoint("TOPLEFT", content, "TOPLEFT")
	sketch:SetClipsChildren(true)
	MSBTWindow.Box(sketch, COLORS.field)

	local line = sketch:CreateTexture(nil, "ARTWORK")
	line:SetColorTexture(COLORS.line[1], COLORS.line[2], COLORS.line[3])
	line:SetPoint("TOP")
	line:SetPoint("BOTTOM")
	line:SetWidth(1)
	line = sketch:CreateTexture(nil, "ARTWORK")
	line:SetColorTexture(COLORS.line[1], COLORS.line[2], COLORS.line[3])
	line:SetPoint("LEFT")
	line:SetPoint("RIGHT")
	line:SetHeight(1)
end


local function CreatePage(page, width, height)
	content = page
	local leftWidth = width - PANEL_WIDTH - 12
	CreateSketch(leftWidth)

	local locale = L.BUTTONS.scrollAreasPreview
	local previewButton = CreateButton(content, locale.label, locale.tooltip, OnClickPreview)
	previewButton:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -SKETCH_MAX_HEIGHT - 8)
	local onScreenButton = CreateButton(content, L.WINDOW.onScreen, L.WINDOW.onScreenTooltip, Areas.ConfigureOnScreen)
	onScreenButton:SetPoint("LEFT", previewButton, "RIGHT", 8, 0)

	local listTop = SKETCH_MAX_HEIGHT + BUTTON_HEIGHT + 16
	listbox = MSBTControls.CreateListbox(content)
	listbox:Configure(leftWidth, height - listTop - BUTTON_HEIGHT - 8, ROW_HEIGHT)
	listbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -listTop)
	listbox:SetCreateLineHandler(CreateRow)
	listbox:SetDisplayHandler(DisplayRow)
	listbox:SetClickHandler(OnClickRow)
	MSBTWindow.Fill(listbox, COLORS.panel)
	MSBTWindow.SkinListbox(listbox)

	locale = L.BUTTONS.addScrollArea
	local addButton = CreateButton(content, locale.label, locale.tooltip, OnClickAdd)
	addButton:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT")

	CreatePanel(height)
end



MSBTWindow.RegisterPage("scrollAreas", CreatePage, Refresh)
