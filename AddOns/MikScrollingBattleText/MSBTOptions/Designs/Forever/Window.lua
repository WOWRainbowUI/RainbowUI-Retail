
local module = {}
local moduleName = "Window"
MSBTOptions[moduleName] = module



local MSBTOptMain = MSBTOptions.Main
local MSBTControls = MSBTOptions.Controls
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations



local WIDTH = 960
local HEIGHT = 640
local HEADER_HEIGHT = 64
local FOOTER_HEIGHT = 48
local SIDEBAR_WIDTH = 230
local GROUP_HEIGHT = 22
local ENTRY_HEIGHT = 28
local PAGE_LEFT = SIDEBAR_WIDTH + 20
local PAGE_TOP = HEADER_HEIGHT + 60
local PAGE_WIDTH = WIDTH - PAGE_LEFT - 20
local PAGE_HEIGHT = HEIGHT - PAGE_TOP - FOOTER_HEIGHT - 12
local CHANGE_LINE_HEIGHT = 26

local COLORS = {
	window = { 0.090, 0.075, 0.055 },
	panel = { 0.075, 0.063, 0.047 },
	field = { 0.055, 0.043, 0.031 },
	bar = { 0.165, 0.129, 0.094 },
	line = { 0.227, 0.184, 0.114 },
	border = { 0.431, 0.353, 0.200 },
	gold = { 0.910, 0.765, 0.353 },
	text = { 0.914, 0.886, 0.816 },
	hint = { 0.659, 0.608, 0.502 },
	red = { 0.490, 0.114, 0.071 },
}
local SELECTED_COLOR = { 0.910, 0.765, 0.353, 0.16 }
local HOVER_COLOR = { 0.910, 0.765, 0.353, 0.08 }
local HIGHLIGHT_COLOR = { 0.910, 0.765, 0.353, 0.15 }
local CHECK_HIGHLIGHT_COLOR = { 0.910, 0.765, 0.353, 0.2 }
local PUSHED_COLOR = { 0, 0, 0, 0.25 }
local DISABLED_COLOR = { 0, 0, 0, 0.4 }
local ROUNDED_TEXTURE = "Interface\\Addons\\MikScrollingBattleText\\MSBTOptions\\Designs\\Forever\\Artwork\\RoundedBox"
local ICON_TEXTURE = "Interface\\Addons\\MikScrollingBattleText\\MSBTOptions\\Designs\\Forever\\Artwork\\Flat"
-- The factory's icon buttons by the name in their texture, and the flat symbol for each.
local ICON_SYMBOLS = { delete = "Delete", configure = "Settings", fontsettings = "Font" }
local SEARCH_HEIGHT = 46
local BLIZZARD_GROUP_HEIGHT = 30
local BLIZZARD_GROUP_GAP = 18
local DROPDOWN_LINE_HEIGHT = 20
-- The dropdown list hangs in its field, and Raise leaves it under the controls beside the field,
-- such as the sliders of a popup; it stands this many frame levels above the field instead.
local DROPDOWN_LIST_LIFT = 50
-- Blizzard's menu ground under the dropdown list: how far it reaches above and below the entries,
-- the height of the art, and the margin beside the panel it draws at full size.
local GROUND_TOP, GROUND_BOTTOM, GROUND_ART_HEIGHT, GROUND_SIDE = 18, 29, 90, 16.3
local MIN_THUMB_HEIGHT = 24
local MIN_SCALE = 0.8
local MAX_SCALE = 2
-- Inside the game's settings window the header, the page and the footer's Changes and Reset Profile
-- buttons stay, without the sidebar, the border, the size grip, Cancel and Apply. The window then
-- fits the settings panel with the margin and the largest scale the classic design uses.
local DOCKED_LEFT = 20
local DOCKED_WIDTH = PAGE_WIDTH + 2 * DOCKED_LEFT
local DOCK_PADDING = 16
local DOCK_MAX_SCALE = 1.6
local GRIP_TEXTURE = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-"
local MOVER_BACKDROP = { bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 }
local MOVER_COLOR = { 0.090, 0.075, 0.055, 0.55 }
local MOVER_SELECTED_COLOR = { 0.090, 0.075, 0.055, 0.8 }
-- The scroll area configuration's left edge, right of the screen center, clear of the default areas.
local CONFIG_OFFSET = 320

-- The art of Blizzard's own options; the new design wears it only when the client has every piece.
local BLIZZARD_ATLASES = {
	"checkbox-minimal", "checkmark-minimal", "checkmark-minimal-disabled",
	"Minimal_SliderBar_Left", "Minimal_SliderBar_Right", "_Minimal_SliderBar_Middle", "Minimal_SliderBar_Button",
	"common-dropdown-c-button", "common-dropdown-c-button-hover-1", "common-dropdown-c-button-open",
	"common-dropdown-c-button-pressed-1", "common-dropdown-c-button-disabled", "common-dropdown-c-bg",
	"common-dropdown-customize-mouseover", "minimal-scrollbar-small-thumb-middle", "!minimal-scrollbar-track-middle",
	"minimal-scrollbar-arrow-top", "minimal-scrollbar-arrow-top-over", "minimal-scrollbar-arrow-top-down",
	"minimal-scrollbar-arrow-bottom", "minimal-scrollbar-arrow-bottom-over", "minimal-scrollbar-arrow-bottom-down",
	"minimal-scrollbar-track-top", "minimal-scrollbar-track-bottom", "minimal-scrollbar-small-thumb-top",
	"minimal-scrollbar-small-thumb-bottom",
	"Options_CategoryHeader_1", "Options_List_Active", "Options_List_Hover", "Options_HorizontalDivider",
}

-- Sidebar order; tab names the classic tab whose label and hint an entry without its own text uses.
-- An entry added from outside has its own label and hint and no tab.
local ENTRIES = {
	{ group = "groupDisplay" },
	{ key = "general", tab = "general" },
	{ key = "scrollAreas", tab = "scrollAreas" },
	{ key = "fontsColors" },
	{ group = "groupEvents" },
	{ key = "incoming", tab = "events" },
	{ key = "outgoing", tab = "events" },
	{ key = "pet", tab = "events" },
	{ key = "notifications", tab = "events" },
	{ key = "lootAlerts", tab = "lootAlerts" },
	{ group = "groupMore" },
	{ key = "sounds", tab = "sounds" },
	{ key = "profile", tab = "profile" },
	{ key = "changes" },
}



local frame
local pageArea
local titleFontString
local hintFontString
local profileDropdown
local changesButton
local applyButton
local cancelButton
local resetButton
local entryButtons = {}
local pages = {}
local pageFrames = {}
local currentKey = "general"
local keyBeforeSearch
local searchEditbox
local shownFrame
local snapshots
local baseSnapshot
local baseMechanics
local switchesChanged
local keepBaseOnHide
local chrome = {}
local divider
local dockedPanel
local dockedKey
local dockedOpeners
local reopenSettings
local CheckboxEnable
local DropdownDisable, DropdownEnable, DropdownClear, DropdownRemoveItem
local hasBlizzardArt
local dropdownList
local scrollAreaConfig
local MoverSetBackdropColor
local PopupSetPoint

local changes
local changesListbox
local undoAllButton
local noChangesFontString



local function SetTextColor(fontString, color)
	fontString:SetTextColor(color[1], color[2], color[3])
end


-- Asked once; without the art the flat drawing stays.
local function HasBlizzardArt()
	if hasBlizzardArt == nil then
		hasBlizzardArt = C_Texture ~= nil
		for _, atlas in ipairs(BLIZZARD_ATLASES) do
			hasBlizzardArt = hasBlizzardArt and C_Texture.GetAtlasInfo(atlas) ~= nil
		end
	end
	return hasBlizzardArt
end


local function AtlasTexture(region, atlas, layer)
	local texture = region:CreateTexture(nil, layer or "BACKGROUND")
	texture:SetAtlas(atlas, true)
	return texture
end


-- Blizzard draws its grounds larger than the frame, with their shadow outside it.
local function Around(texture, region, left, top, right, bottom)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", region, "TOPLEFT", -left, top)
	texture:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", right, -bottom)
	return texture
end


local function AtlasAround(texture, atlas)
	texture:SetAtlas(atlas)
	return Around(texture, texture:GetParent(), 7, 7, 7, 7)
end


-- Blizzard's list shows its entries gold and the selected one light, the flat list the reverse.
local function EntryColor(isSelected)
	return isSelected ~= HasBlizzardArt() and COLORS.gold or COLORS.text
end


-- Height limits the fill to a band of that height at the bottom of the frame.
local function Fill(region, color, layer, inset, height)
	inset = inset or 0
	local texture = region:CreateTexture(nil, layer or "BACKGROUND")
	texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
	if height then
		texture:SetPoint("TOPLEFT", region, "BOTTOMLEFT", inset, height - inset)
	else
		texture:SetPoint("TOPLEFT", region, "TOPLEFT", inset, -inset)
	end
	texture:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", -inset, inset)
	return texture
end


-- Rounded where the client can slice textures; elsewhere the plain colour stays square.
-- Option buttons crop their state textures, so the whole rounded texture is selected again.
local function Paint(texture, color)
	if texture.SetTextureSliceMargins then
		texture:SetTexture(ROUNDED_TEXTURE)
		texture:SetTexCoord(0, 1, 0, 1)
		texture:SetTextureSliceMargins(8, 8, 8, 8)
		texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
	else
		texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
	end
	return texture
end


local function Box(region, ground, border, height)
	border = border or COLORS.border
	ground = ground or COLORS.field
	Paint(Fill(region, border, "BACKGROUND", 0, height), border)
	return Paint(Fill(region, ground, "BORDER", 1, height), ground)
end


local function HideTextures(...)
	for index = 1, select("#", ...) do
		local region = select(index, ...)
		if region:GetObjectType() == "Texture" then region:Hide() end
	end
end


local function PlaceIcon(button, texture, color, inset)
	texture:ClearAllPoints()
	texture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
	texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
	texture:SetVertexColor(color[1], color[2], color[3])
end


-- One white symbol serves every state, tinted: Chevron, Delete, Font, Play, Settings, Sound.
local function SkinIconButton(button, icon, inset)
	local path = ICON_TEXTURE .. icon
	inset = inset or 2
	button:SetNormalTexture(path)
	button:SetPushedTexture(path)
	button:SetDisabledTexture(path)
	button:SetHighlightTexture(path)
	PlaceIcon(button, button:GetNormalTexture(), COLORS.gold, inset)
	PlaceIcon(button, button:GetPushedTexture(), COLORS.text, inset)
	PlaceIcon(button, button:GetDisabledTexture(), COLORS.line, inset)
	PlaceIcon(button, button:GetHighlightTexture(), COLORS.gold, inset)
	button:GetHighlightTexture():SetBlendMode("ADD")
end


-- The factory builds a button from one of its own symbols; the flat symbol then replaces it.
local function CreateIconButton(parent, icon, tooltip, handler)
	local button = MSBTControls.CreateIconButton(parent, "Configure")
	button:SetTooltip(tooltip)
	button:SetClickHandler(handler)
	SkinIconButton(button, icon)
	return button
end


-- As a state texture of a button the client stretches and crops Blizzard's art, so a button's art
-- is a texture of its own that follows the button's state through its scripts.
local BUTTON_STATES = { rest = "", hover = "-hover-1", pressed = "-pressed-1", disabled = "-disabled" }
local ARROW_STATES = { rest = "", hover = "-over", pressed = "-down", disabled = "" }

local function ShowButtonState(button, state)
	local states = button.groundStates
	button.ground:SetAtlas(button.groundAtlas .. (button:IsEnabled() and states[state] or states.disabled),
		button.groundAtlasSize)
end


local function ShowButtonAtRest(button)
	ShowButtonState(button, "rest")
end


local function ShowButtonHovered(button)
	ShowButtonState(button, "hover")
end


local function ShowButtonPressed(button)
	ShowButtonState(button, "pressed")
end


local function ShowButtonReleased(button)
	ShowButtonState(button, button:IsMouseOver() and "hover" or "rest")
end


-- Scroll button templates differ between clients, so a state texture may be missing.
local function HideStateTextures(...)
	for index = 1, select("#", ...) do
		local texture = select(index, ...)
		if texture then texture:SetAlpha(0) end
	end
end


local function GiveGround(button, ground, atlas, states, useAtlasSize)
	HideStateTextures(button:GetNormalTexture(), button:GetPushedTexture(), button:GetDisabledTexture(),
		button:GetHighlightTexture())
	button.ground, button.groundAtlas, button.groundStates, button.groundAtlasSize = ground, atlas, states, useAtlasSize
	button:HookScript("OnEnter", ShowButtonHovered)
	button:HookScript("OnLeave", ShowButtonAtRest)
	button:HookScript("OnMouseDown", ShowButtonPressed)
	button:HookScript("OnMouseUp", ShowButtonReleased)
	button:HookScript("OnEnable", ShowButtonAtRest)
	button:HookScript("OnDisable", ShowButtonAtRest)
	ShowButtonAtRest(button)
end


local function SkinButton(button, isMain)
	if not HasBlizzardArt() then
		Box(button, isMain and COLORS.red or COLORS.field, isMain and COLORS.gold or COLORS.border)
		button:GetNormalTexture():SetColorTexture(0, 0, 0, 0)
		Paint(button:GetPushedTexture(), PUSHED_COLOR)
		Paint(button:GetDisabledTexture(), DISABLED_COLOR)
		Paint(button:GetHighlightTexture(), HIGHLIGHT_COLOR)
	-- The factory's red button is Blizzard's own main button.
	elseif isMain then
		return
	else
		GiveGround(button, AtlasAround(button:CreateTexture(nil, "BACKGROUND"), "common-dropdown-c-button"),
			"common-dropdown-c-button", BUTTON_STATES)
	end
	button:SetNormalFontObject(GameFontHighlight)
	button:SetHighlightFontObject(GameFontHighlight)
	button:SetDisabledFontObject(GameFontDisable)
	button:SetLabel(button:GetText())
end


local function EnableSkinnedCheckbox(checkbox)
	CheckboxEnable(checkbox)
	SetTextColor(checkbox.fontString, COLORS.text)
end


local function SkinCheckbox(checkbox)
	local check = checkbox.checkFrame
	if HasBlizzardArt() then
		check:GetNormalTexture():SetAtlas("checkbox-minimal")
		check:GetPushedTexture():SetAtlas("checkbox-minimal")
		check:GetCheckedTexture():SetAtlas("checkmark-minimal")
		check:GetDisabledCheckedTexture():SetAtlas("checkmark-minimal-disabled")
	else
		Box(check)
		check:GetNormalTexture():SetColorTexture(0, 0, 0, 0)
		check:GetPushedTexture():SetColorTexture(0, 0, 0, 0)
		Paint(check:GetHighlightTexture(), CHECK_HIGHLIGHT_COLOR)
	end
	SetTextColor(checkbox.fontString, COLORS.text)
	-- The factory makes the box as wide as its label measures at one scale; at another the text
	-- comes out a little wider and would wrap, so the label takes the width it needs.
	checkbox.fontString:ClearAllPoints()
	checkbox.fontString:SetPoint("LEFT", check, "RIGHT", 2, 0)
	checkbox.fontString:SetWordWrap(false)
	CheckboxEnable = CheckboxEnable or checkbox.Enable
	checkbox.Enable = EnableSkinnedCheckbox
end


-- The factory's border is Blizzard's own input art, so only the flat look replaces it.
local function SkinEditbox(editbox)
	if HasBlizzardArt() then return end
	HideTextures(editbox.editboxFrame:GetRegions())
	Box(editbox, nil, nil, 20)
end


-- Blizzard's arrow at its own size, on a texture of its own like a button's ground.
local function SkinScrollButton(button, atlas)
	button:SetSize(17, 11)
	local arrow = AtlasTexture(button, atlas, "ARTWORK")
	arrow:SetPoint("CENTER")
	GiveGround(button, arrow, atlas, ARROW_STATES, true)
end


-- The chevron points down; the button above a list shows it upside down.
local function FlipTextures(...)
	for index = 1, select("#", ...) do
		select(index, ...):SetTexCoord(0, 1, 1, 0)
	end
end


-- The thumb is as long as the share of the list that shows, as Blizzard's is.
local function SizeThumb(slider)
	local _, range = slider:GetMinMaxValues()
	local parent = slider:GetParent()
	local visible = parent.lines and #parent.lines or parent:GetHeight()
	local share = visible > 0 and visible / (range + visible) or 1
	slider:GetThumbTexture():SetHeight(math.max(MIN_THUMB_HEIGHT, slider:GetHeight() * share))
end


local function Between(texture, top, bottom)
	texture:SetPoint("TOPLEFT", top, "BOTTOMLEFT")
	texture:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT")
	return texture
end


-- Blizzard's track and thumb have rounded ends; the slider places its one thumb texture, which
-- stays invisible while the pieces anchored to it draw the thumb.
local function SkinScrollBar(slider, up, down)
	local thumb = slider:GetThumbTexture()
	if HasBlizzardArt() then
		local top = AtlasTexture(slider, "minimal-scrollbar-track-top")
		top:SetPoint("TOP")
		local bottom = AtlasTexture(slider, "minimal-scrollbar-track-bottom")
		bottom:SetPoint("BOTTOM")
		Between(AtlasTexture(slider, "!minimal-scrollbar-track-middle"), top, bottom):SetVertTile(true)
		thumb:SetAlpha(0)
		top = AtlasTexture(slider, "minimal-scrollbar-small-thumb-top", "ARTWORK")
		top:SetPoint("TOP", thumb)
		bottom = AtlasTexture(slider, "minimal-scrollbar-small-thumb-bottom", "ARTWORK")
		bottom:SetPoint("BOTTOM", thumb)
		Between(AtlasTexture(slider, "minimal-scrollbar-small-thumb-middle", "ARTWORK"), top, bottom)
		SkinScrollButton(up, "minimal-scrollbar-arrow-top")
		SkinScrollButton(down, "minimal-scrollbar-arrow-bottom")
		up:ClearAllPoints()
		up:SetPoint("BOTTOM", slider, "TOP", 0, 5)
		down:ClearAllPoints()
		down:SetPoint("TOP", slider, "BOTTOM", 0, -5)
	else
		Fill(slider, COLORS.field)
		thumb:SetColorTexture(COLORS.border[1], COLORS.border[2], COLORS.border[3])
		SkinIconButton(up, "Chevron", 2)
		FlipTextures(up:GetNormalTexture(), up:GetPushedTexture(), up:GetDisabledTexture(), up:GetHighlightTexture())
		SkinIconButton(down, "Chevron", 2)
	end
	thumb:SetWidth(8)
	thumb:SetHeight(MIN_THUMB_HEIGHT)
	slider:HookScript("OnMinMaxChanged", SizeThumb)
end


-- The bar of a UIPanelScrollFrameTemplate scroll frame, by the keys this client's template sets.
local function SkinScrollFrame(scrollFrame)
	local bar = rawget(scrollFrame, "ScrollBar")
	local up, down = bar and rawget(bar, "ScrollUpButton"), bar and rawget(bar, "ScrollDownButton")
	if up and down then SkinScrollBar(bar, up, down) end
end


local function SkinListbox(listbox)
	SkinScrollBar(listbox.sliderFrame, listbox.upButton, listbox.downButton)
	-- The selection bar belongs to this listbox alone, unlike the shared hover bar.
	local bar = listbox.highlightFrame:GetRegions()
	bar:SetBlendMode("BLEND")
	bar:SetColorTexture(SELECTED_COLOR[1], SELECTED_COLOR[2], SELECTED_COLOR[3], SELECTED_COLOR[4])
end


local function SkinSlider(slider)
	local track = slider.sliderFrame
	if HasBlizzardArt() then
		track:SetBackdrop(nil)
		track:GetThumbTexture():SetAtlas("Minimal_SliderBar_Button", true)
		local left = AtlasTexture(track, "Minimal_SliderBar_Left")
		left:SetPoint("LEFT")
		local right = AtlasTexture(track, "Minimal_SliderBar_Right")
		right:SetPoint("RIGHT")
		local middle = AtlasTexture(track, "_Minimal_SliderBar_Middle")
		middle:SetHorizTile(true)
		middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
		middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
	else
		track:SetBackdropColor(COLORS.field[1], COLORS.field[2], COLORS.field[3])
		track:SetBackdropBorderColor(COLORS.border[1], COLORS.border[2], COLORS.border[3])
		track:GetThumbTexture():SetVertexColor(COLORS.gold[1], COLORS.gold[2], COLORS.gold[3])
	end
end



-- Shows the field's ground as open while its list shows, else as hovered or at rest.
local function ShowDropdownState(dropdown, isOver)
	local ground = dropdown and dropdown.ground
	if not ground then return end
	local isOpen = dropdownList and dropdownList:IsShown() and dropdownList.dropdown == dropdown
	ground:SetAtlas(isOpen and "common-dropdown-c-button-open"
		or not dropdown.buttonFrame:IsEnabled() and "common-dropdown-c-button-disabled"
		or isOver and "common-dropdown-c-button-hover-1" or "common-dropdown-c-button")
	if dropdown.arrow then dropdown.arrow:SetShown(isOver and dropdown.buttonFrame:IsEnabled() and true or false) end
end


local function HideDropdownList(dropdown)
	if dropdownList and dropdownList.dropdown == dropdown then dropdownList:Hide() end
end


local function CreateDropdownLine(listbox)
	local line = CreateFrame("Button", nil, listbox)
	local fontString = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fontString:SetPoint("LEFT", line, "LEFT", 14, 0)
	fontString:SetPoint("RIGHT", line, "RIGHT", -4, 0)
	fontString:SetJustifyH("LEFT")
	fontString:SetWordWrap(false)
	line.fontString = fontString
	if HasBlizzardArt() then
		local hover = line:CreateTexture(nil, "HIGHLIGHT")
		hover:SetAtlas("common-dropdown-customize-mouseover")
		hover:SetAllPoints(line)
		hover:SetAlpha(0.15)
	else
		Paint(Fill(line, HOVER_COLOR, "HIGHLIGHT"), HOVER_COLOR)
	end
	return line
end


local function DisplayDropdownLine(listbox, line, item)
	local dropdown = listbox.dropdown
	line.fontString:SetText(dropdown.items[item])
	SetTextColor(line.fontString, item == dropdown.selectedItem and COLORS.gold or COLORS.text)
end


-- Does what the classic list does with a chosen line.
local function OnClickDropdownLine(listbox, line, item)
	local dropdown = listbox.dropdown
	dropdown.selectedFontString:SetText(dropdown.items[item])
	dropdown.selectedItem = item
	listbox:Hide()
	if dropdown.changeHandler then dropdown:changeHandler(dropdown.itemIDs[item]) end
end


-- The classic list is one frame both designs would share, so the new design has its own.
local function CreateDropdownList(dropdown)
	local list = MSBTControls.CreateListbox(dropdown)
	list:Hide()
	list:SetCreateLineHandler(CreateDropdownLine)
	list:SetDisplayHandler(DisplayDropdownLine)
	list:SetClickHandler(OnClickDropdownLine)
	list:SetScript("OnHide", function(self) ShowDropdownState(self.dropdown) end)
	if HasBlizzardArt() then
		-- Blizzard's menu ground with its own slices. The entries lie 3 inside the field's edges and
		-- 6 below it. The ground is placed when the list opens, because its width follows the
		-- list's height.
		list.ground = list:CreateTexture(nil, "BACKGROUND")
		list.ground:SetAtlas("common-dropdown-c-bg")
		list.insetX, list.insetY = 3, 6
	else
		Box(list, COLORS.field, COLORS.border)
		list.insetX, list.insetY = 0, 0
	end
	SkinListbox(list)
	return list
end


local function ToggleDropdownList(this)
	local dropdown = this:GetParent()
	dropdownList = dropdownList or CreateDropdownList(dropdown)
	local list = dropdownList
	local isOpen = list:IsShown() and list.dropdown == dropdown
	list:Hide()
	if isOpen then
		ShowDropdownState(dropdown, true)
		return
	end
	if #dropdown.items == 0 then return end

	list.dropdown = dropdown
	list:SetParent(dropdown)
	list:SetFrameStrata("FULLSCREEN_DIALOG")
	list:SetFrameLevel(dropdown:GetFrameLevel() + DROPDOWN_LIST_LIFT)
	list:ClearAllPoints()
	list:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", list.insetX, -list.insetY)
	local count = #dropdown.items
	list:Clear()
	local height = math.min(count * DROPDOWN_LINE_HEIGHT, dropdown.listboxHeight or 200)
	list:Configure(math.max(dropdown:GetWidth(), dropdown.listboxWidth or 0) - 2 * list.insetX, height,
		DROPDOWN_LINE_HEIGHT)
	if list.ground then
		-- The client shrinks the art when the ground is lower than the art itself, and the panel in
		-- it then reaches further out. The ground is narrowed by as much, so that the panel is as
		-- wide as the field for a list of any length. Measured in the client for one and two entries.
		local shrink = math.min(1, (height + GROUND_TOP + GROUND_BOTTOM) / GROUND_ART_HEIGHT)
		local side = list.insetX + GROUND_SIDE * shrink
		Around(list.ground, list, side, GROUND_TOP, side, GROUND_BOTTOM)
	end
	for item = 1, count do list:AddItem(item) end
	list:SetOffset(dropdown.selectedItem - 1)
	-- The listbox moves the shared hover bar of the classic lists; these lines have their own.
	for _, line in ipairs(list.lines) do
		line:SetScript("OnEnter", nil)
		line:SetScript("OnLeave", nil)
	end
	list:Show()
	list:Raise()
	ShowDropdownState(dropdown, true)
end


local function OnEnterDropdownField(this)
	local dropdown = this:GetParent()
	ShowDropdownState(dropdown, true)
	dropdown:GetScript("OnEnter")(dropdown)
end


local function OnLeaveDropdownField(this)
	local dropdown = this:GetParent()
	ShowDropdownState(dropdown)
	dropdown:GetScript("OnLeave")(dropdown)
end


-- The factory's methods know only the classic list, so the new list is closed first.
local function DisableSkinnedDropdown(dropdown)
	HideDropdownList(dropdown)
	DropdownDisable(dropdown)
	ShowDropdownState(dropdown)
end


local function EnableSkinnedDropdown(dropdown)
	DropdownEnable(dropdown)
	ShowDropdownState(dropdown)
end


local function ClearSkinnedDropdown(dropdown)
	HideDropdownList(dropdown)
	DropdownClear(dropdown)
end


local function RemoveSkinnedDropdownItem(dropdown, id)
	HideDropdownList(dropdown)
	DropdownRemoveItem(dropdown, id)
end


local function SkinDropdown(dropdown)
	HideTextures(dropdown:GetRegions())
	DropdownDisable = DropdownDisable or dropdown.Disable
	DropdownEnable = DropdownEnable or dropdown.Enable
	DropdownClear = DropdownClear or dropdown.Clear
	DropdownRemoveItem = DropdownRemoveItem or dropdown.RemoveItem
	dropdown.Disable = DisableSkinnedDropdown
	dropdown.Enable = EnableSkinnedDropdown
	dropdown.Clear = ClearSkinnedDropdown
	dropdown.RemoveItem = RemoveSkinnedDropdownItem
	local button, text = dropdown.buttonFrame, dropdown.selectedFontString
	button:SetScript("OnClick", ToggleDropdownList)
	dropdown:HookScript("OnHide", HideDropdownList)
	text:SetWordWrap(false)
	text:ClearAllPoints()
	if HasBlizzardArt() then
		-- The arrow button becomes the whole field, invisible over Blizzard's ground.
		button:SetAlpha(0)
		button:ClearAllPoints()
		button:SetPoint("BOTTOMLEFT")
		button:SetPoint("BOTTOMRIGHT")
		button:SetHeight(25)
		button:SetScript("OnEnter", OnEnterDropdownField)
		button:SetScript("OnLeave", OnLeaveDropdownField)
		dropdown.ground = Around(dropdown:CreateTexture(nil, "BACKGROUND"), button, 7, 7, 7, 7)
		dropdown.ground:SetAtlas("common-dropdown-c-button")
		-- Blizzard's small arrow under a hovered field; a client without it keeps the field without one.
		if C_Texture.GetAtlasInfo("common-dropdown-c-button-hover-arrow") then
			dropdown.arrow = dropdown:CreateTexture(nil, "OVERLAY")
			dropdown.arrow:SetAtlas("common-dropdown-c-button-hover-arrow", true)
			dropdown.arrow:SetPoint("BOTTOM", button, "BOTTOM", 0, -5)
			dropdown.arrow:Hide()
		end
		text:SetPoint("LEFT", button, "LEFT", 13, 0)
		text:SetPoint("RIGHT", button, "RIGHT", -13, 0)
		text:SetJustifyH("CENTER")
	else
		Box(dropdown, nil, nil, 25)
		SkinIconButton(button, "Chevron")
		text:SetPoint("LEFT", dropdown, "BOTTOMLEFT", 8, 12)
		text:SetPoint("RIGHT", button, "LEFT")
		text:SetJustifyH("LEFT")
	end
end



local SkinTree

-- A factory control is known by the fields its factory sets; true when it was skinned.
local function SkinControl(control)
	if control.checkFrame then
		SkinCheckbox(control)
	elseif control.buttonFrame and control.selectedFontString then
		SkinDropdown(control)
	elseif control.editboxFrame then
		SkinEditbox(control)
	elseif control.displayFrame and control.sliderFrame then
		SkinListbox(control)
		-- Lines are built when items arrive, so each is skinned as it is built.
		local createLine = control.lineHandler
		if createLine then
			control.lineHandler = function(this)
				local line = createLine(this)
				SkinTree(line)
				return line
			end
		end
	elseif control.sliderFrame then
		SkinSlider(control)
	elseif control:GetObjectType() == "Button" and control.SetLabel then
		SkinButton(control)
	else
		local texture = control.GetNormalTexture and control:GetNormalTexture()
		local icon = texture and ICON_SYMBOLS[tostring(texture:GetTextureFilePath()):lower():match("(%a+)icon[^\\/]*$")]
		if not icon then return false end
		SkinIconButton(control, icon)
	end
	return true
end


-- Tooltip panels take the flat ground; other frames are searched for controls.
function SkinTree(...)
	for index = 1, select("#", ...) do
		local child = select(index, ...)
		if not SkinControl(child) then
			if child.GetBackdrop and child:GetBackdrop() then
				child:SetBackdrop(nil)
				Box(child, COLORS.panel, COLORS.line)
			end
			if child:GetObjectType() == "ScrollFrame" then SkinScrollFrame(child) end
			SkinTree(child:GetChildren())
		end
	end
end


-- The classic code colours every mover when the selection changes, so each call shows the
-- mover's own state instead: gold and its label when selected.
local function ShowMoverState(mover)
	local isSelected = mover.scrollArea == scrollAreaConfig.currentScrollArea
	local ground = isSelected and MOVER_SELECTED_COLOR or MOVER_COLOR
	local border = isSelected and COLORS.gold or COLORS.border
	MoverSetBackdropColor(mover, ground[1], ground[2], ground[3], ground[4])
	mover:SetBackdropBorderColor(border[1], border[2], border[3])
	mover.fontString:SetShown(isSelected)
end


-- Neighbouring labels would cover each other, so a mover without its label names its area here.
local function OnEnterMover(mover)
	if mover.fontString:IsShown() then return end
	GameTooltip:SetOwner(mover, "ANCHOR_RIGHT")
	GameTooltip:SetText(mover.fontString:GetText(), nil, nil, nil, nil, 1)
end


local function HideTooltip()
	GameTooltip:Hide()
end


local function SkinMover(mover)
	MoverSetBackdropColor = MoverSetBackdropColor or mover.SetBackdropColor
	mover.SetBackdropColor = ShowMoverState
	mover:SetBackdrop(MOVER_BACKDROP)
	mover:SetScript("OnEnter", OnEnterMover)
	mover:SetScript("OnLeave", HideTooltip)
	mover:HookScript("OnMouseDown", HideTooltip)
end


-- The classic code anchors a popup to the button that opened it, also while it is shown, so the
-- popup itself takes every anchor as the window's center.
local function CenterPopup(popup)
	PopupSetPoint(popup, "CENTER", frame or UIParent, "CENTER")
end


-- Runs once for every popup instance of the new design; the classic instances never get here.
-- The scroll area configuration builds a mover when an area first shows there, so each is skinned
-- as it is stored; it shows while the window is hidden and stays clear of the movers in the middle.
local function SkinPopup(popup)
	HideTextures(popup:GetRegions())
	Box(popup, COLORS.window)
	SkinTree(popup:GetChildren())
	-- A popup may hang its content on a frame of its own that stands lower by the picture in the corner
	-- of the classic header. The flat popup has no such header, so that frame goes back to the popup's corner.
	if popup.content then popup.content:SetPoint("TOPLEFT", popup, "TOPLEFT", 0, 0) end
	if popup.moverFrames then
		scrollAreaConfig = popup
		setmetatable(popup.moverFrames, { __newindex = function(movers, key, mover)
			rawset(movers, key, mover)
			SkinMover(mover)
		end })
		popup:ClearAllPoints()
		popup:SetPoint("LEFT", UIParent, "CENTER", CONFIG_OFFSET, 0)
	else
		PopupSetPoint = PopupSetPoint or popup.SetPoint
		popup.SetPoint = CenterPopup
	end
end



local function CurrentProfileName()
	for name, profile in pairs(MSBTProfiles.savedVariables.profiles) do
		if profile == MSBTProfiles.currentProfile then return name end
	end
end


-- The switches that stand for a client setting are written to the client at once and their marks
-- sit in the profile outside the profile snapshots, so Cancel puts them back from a record taken
-- when the window opened. With the profiles module's Take and Restore functions the record is
-- theirs and opaque; with only the older text functions it holds the two effect values.
local function HasRecordFunctions()
	return MSBTProfiles.TakeBlizzardSwitches and MSBTProfiles.RestoreBlizzardSwitches
end


local function TakeMechanics()
	if HasRecordFunctions() then return { record = MSBTProfiles.TakeBlizzardSwitches() } end
	if not (MSBTProfiles.GetSpellMechanicsText and MSBTProfiles.SetSpellMechanicsText) then return end
	local own, others = MSBTProfiles.GetSpellMechanicsText()
	return { texts = { own = own, others = others } }
end


local function RestoreMechanics()
	if not baseMechanics then return end
	if baseMechanics.record then
		MSBTProfiles.RestoreBlizzardSwitches(baseMechanics.record)
		return
	end
	local own, others = MSBTProfiles.GetSpellMechanicsText()
	local current = { own = own, others = others }
	for which, value in pairs(baseMechanics.texts) do
		if current[which] ~= nil and current[which] ~= value then
			MSBTProfiles.SetSpellMechanicsText(which, value)
		end
	end
end


local function SameValue(left, right)
	if type(left) ~= "table" or type(right) ~= "table" then return left == right end
	for key, value in pairs(left) do
		if not SameValue(value, right[key]) then return false end
	end
	for key in pairs(right) do
		if left[key] == nil then return false end
	end
	return true
end


local function HasPendingChanges()
	return baseSnapshot and (switchesChanged or MSBTProfiles.HasImportedMedia()
		or snapshots:Count(baseSnapshot, 1) > 0)
end


local function RestorePendingChanges()
	MSBTProfiles.FinishImportedMedia(false)
	snapshots:Restore(baseSnapshot)
	RestoreMechanics()
end

function module.EndSession()
	MSBTProfiles.FinishImportedMedia(true)
	baseSnapshot, baseMechanics, switchesChanged = nil, nil, false
end

-- Runs after every profile write while the window exists, so it must not create tables.
local function UpdateState()
	if not frame:IsShown() then return end
	profileDropdown:SetSelectedID(CurrentProfileName())
	changesButton:SetLabel(string.format(L.WINDOW.changesCount,
		snapshots:Count(snapshots:GetLoginSnapshot())))
	if HasPendingChanges() then applyButton:Enable() else applyButton:Disable() end
end


-- The switches are written to the client, which no profile hook sees, so the page tells the window.
local function RefreshSwitches()
	switchesChanged = baseMechanics ~= nil and not SameValue(TakeMechanics(), baseMechanics)
	UpdateState()
end


local function UpdateHeader()
	if not frame:IsShown() then return end
	profileDropdown:Clear()
	for name in pairs(MSBTProfiles.savedVariables.profiles) do
		profileDropdown:AddItem(name, name)
	end
	profileDropdown:Sort()
	UpdateState()
end


local function RefreshPage()
	local page = pages[currentKey]
	if page and page.refresh then page.refresh(shownFrame, page.arg) end
end


local function SelectPage(key)
	MSBTOptMain.HidePopups()
	if shownFrame then shownFrame:Hide() end
	local button = entryButtons[currentKey]
	if button then
		button.selected:Hide()
		SetTextColor(button.fontString, EntryColor(false))
	end

	currentKey = key
	-- Changing the text runs OnSearchChanged, which finds no search page shown any more.
	if key ~= "search" then searchEditbox:SetText("") end
	button = entryButtons[key]
	if button then
		button.selected:Show()
		SetTextColor(button.fontString, EntryColor(true))
		titleFontString:SetText(button.label)
		hintFontString:SetText(button.hint)
	else
		titleFontString:SetText(L.WINDOW.search)
		hintFontString:SetText(L.WINDOW.searchHint)
	end

	local page = pages[key]
	if page then
		shownFrame = pageFrames[page.create]
		if not shownFrame then
			shownFrame = CreateFrame("Frame", nil, pageArea)
			shownFrame:SetAllPoints(pageArea)
			page.create(shownFrame, PAGE_WIDTH, PAGE_HEIGHT)
			pageFrames[page.create] = shownFrame
		end
		shownFrame:Show()
		if page.refresh then page.refresh(shownFrame, page.arg) end
	end
	UpdateHeader()
end


local function AfterRestore()
	UpdateHeader()
	RefreshPage()
end


local function OnClickEntry(this)
	SelectPage(this.key)
end


-- The search page gets the text as its argument; an empty field returns to the entry before.
local function OnSearchChanged(this)
	local page = pages.search
	if not page then return end
	local text = this:GetText()
	if text ~= "" then
		page.arg = text
		if currentKey == "search" then
			RefreshPage()
		else
			keyBeforeSearch = currentKey
			SelectPage("search")
		end
	elseif currentKey == "search" then
		SelectPage(keyBeforeSearch)
	end
end


-- The label of an entry, also where no sidebar is built.
local function EntryLabel(entry)
	local tabLocale = entry.tab and L.TABS[entry.tab]
	return entry.label or L.WINDOW[entry.key] or tabLocale.label
end


local function CreateEntry(parent, entry)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(SIDEBAR_WIDTH - 17)
	button:SetHeight(ENTRY_HEIGHT - 2)
	if HasBlizzardArt() then
		AtlasTexture(button, "Options_List_Hover", "HIGHLIGHT"):SetPoint("CENTER")
		button.selected = AtlasTexture(button, "Options_List_Active")
		button.selected:SetPoint("CENTER")
	else
		Paint(Fill(button, HOVER_COLOR, "HIGHLIGHT"), HOVER_COLOR)
		button.selected = Paint(Fill(button, SELECTED_COLOR), SELECTED_COLOR)
	end
	button.selected:Hide()

	local fontString = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fontString:SetPoint("LEFT", button, "LEFT", 12, 0)
	SetTextColor(fontString, EntryColor(false))
	button.fontString = fontString

	local tabLocale = entry.tab and L.TABS[entry.tab]
	button.label = EntryLabel(entry)
	button.hint = entry.hint or L.WINDOW[entry.key .. "Hint"] or tabLocale.tooltip:match("^[^\n]*")
	fontString:SetText(button.label)

	button.key = entry.key
	button:SetScript("OnClick", OnClickEntry)
	entryButtons[entry.key] = button
	return button
end


local function CreateSidebar()
	local sidebar = CreateFrame("Frame", nil, frame)
	chrome[#chrome + 1] = sidebar
	sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -HEADER_HEIGHT - 1)
	sidebar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", SIDEBAR_WIDTH, FOOTER_HEIGHT + 1)
	Fill(sidebar, COLORS.panel)
	local rule = sidebar:CreateTexture(nil, "ARTWORK")
	rule:SetColorTexture(COLORS.line[1], COLORS.line[2], COLORS.line[3])
	rule:SetPoint("TOPRIGHT")
	rule:SetPoint("BOTTOMRIGHT")
	rule:SetWidth(1)

	searchEditbox = MSBTControls.CreateEditbox(sidebar)
	searchEditbox:Configure(SIDEBAR_WIDTH - 17, L.WINDOW.search, L.WINDOW.searchTooltip)
	searchEditbox:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 8, -8)
	searchEditbox:SetTextChangedHandler(OnSearchChanged)
	SkinEditbox(searchEditbox)

	local offset = SEARCH_HEIGHT
	local art = HasBlizzardArt()
	for _, entry in ipairs(ENTRIES) do
		if entry.group then
			local fontString = sidebar:CreateFontString(nil, "OVERLAY", art and "GameFontHighlightMedium" or "GameFontNormalSmall")
			fontString:SetText(L.WINDOW[entry.group])
			if art then
				if offset > SEARCH_HEIGHT then offset = offset + BLIZZARD_GROUP_GAP end
				-- Blizzard's header bar is taller than its slot and runs on under the entries.
				AtlasTexture(sidebar, "Options_CategoryHeader_1", "BORDER"):SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, -offset)
				fontString:SetPoint("LEFT", sidebar, "TOPLEFT", 20, -offset - BLIZZARD_GROUP_HEIGHT / 2 - 1)
				offset = offset + BLIZZARD_GROUP_HEIGHT
			else
				fontString:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 14, -offset - 8)
				SetTextColor(fontString, COLORS.hint)
				offset = offset + GROUP_HEIGHT
			end
		-- An entry needs a registered page, or the classic tab that lends it label and hint.
		elseif entry.tab or pages[entry.key] then
			CreateEntry(sidebar, entry):SetPoint("TOPLEFT", sidebar, "TOPLEFT", 8, -offset)
			offset = offset + ENTRY_HEIGHT
		end
	end
end


-- The close button leaves the right corner free while the window is docked.
local function PlaceProfileDropdown(isDocked)
	profileDropdown:ClearAllPoints()
	profileDropdown:SetPoint("TOPRIGHT", frame, "TOPRIGHT", isDocked and -16 or -56, -12)
end


-- The game's settings window has its own Close button and applies changes at once, so docked the
-- footer keeps neither Cancel nor Apply, and Reset Profile takes the corner of Apply.
local function PlaceFooterButtons(isDocked)
	applyButton:SetShown(not isDocked)
	cancelButton:SetShown(not isDocked)
	resetButton:ClearAllPoints()
	if isDocked then
		resetButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 9)
	else
		resetButton:SetPoint("RIGHT", cancelButton, "LEFT", -10, 0)
	end
end


local function CreateHeader()
	local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -14)
	fontString:SetText("Mik's Scrolling Battle Text")
	SetTextColor(fontString, COLORS.gold)

	fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -38)
	fontString:SetText(string.format(L.WINDOW.subtitle, MikSBT.VERSION_STRING))
	SetTextColor(fontString, COLORS.hint)

	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	chrome[#chrome + 1] = closeButton
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -16)

	local objLocale = L.DROPDOWNS["profile"]
	profileDropdown = MSBTControls.CreateDropdown(frame)
	profileDropdown:Configure(180, objLocale.label, objLocale.tooltip)
	PlaceProfileDropdown(false)
	-- An open popup saves to a key of the old profile, so it closes before the switch.
	profileDropdown:SetChangeHandler(function(this, id)
		MSBTOptMain.HidePopups()
		MSBTProfiles.SelectProfile(id)
		RefreshPage()
	end)
	SkinDropdown(profileDropdown)
end


-- The window is never scaled beyond what the screen holds.
local function MaxScale()
	return math.min(MAX_SCALE, UIParent:GetWidth() / WIDTH, UIParent:GetHeight() / HEIGHT)
end


-- The whole window scales, so the pages keep their layout; its top left corner stays in place.
local function ScaleWindow(scale)
	local oldScale = frame:GetScale()
	local left, top = frame:GetLeft() * oldScale, frame:GetTop() * oldScale
	frame:SetScale(scale)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / scale, top / scale)
	MSBTProfiles.savedVariables.optionsScale = scale ~= 1 and scale or nil
end


local function CursorX()
	return GetCursorPosition() / UIParent:GetEffectiveScale()
end


-- The window's right edge follows the cursor at the distance the grip was taken at, so the window
-- scales while the button is held. This is the one script that runs per frame, and only during
-- the drag.
local gripOffset

local function OnUpdateGrip()
	local scale = frame:GetScale()
	local wanted = (CursorX() + gripOffset - frame:GetLeft() * scale) / WIDTH
	wanted = math.max(MIN_SCALE, math.min(MaxScale(), wanted))
	if wanted ~= scale then ScaleWindow(wanted) end
end


local function StopScaling(grip)
	grip:SetScript("OnUpdate", nil)
end


local function OnMouseDownGrip(grip, button)
	GameTooltip:Hide()
	if button ~= "LeftButton" then return end
	gripOffset = frame:GetRight() * frame:GetScale() - CursorX()
	grip:SetScript("OnUpdate", OnUpdateGrip)
end


local function OnMouseUpGrip(grip, button)
	StopScaling(grip)
	if button == "RightButton" then ScaleWindow(1) end
end


local function CreateFooter()
	applyButton = MSBTControls.CreateOptionButton(frame)
	applyButton:Configure(30, L.WINDOW.apply, L.WINDOW.applyTooltip)
	applyButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 9)
	applyButton:SetClickHandler(function()
		MSBTProfiles.FinishImportedMedia(true)
		baseSnapshot = snapshots:Take()
		baseMechanics = TakeMechanics()
		switchesChanged = false
		UpdateState()
	end)
	SkinButton(applyButton, true)

	cancelButton = MSBTControls.CreateOptionButton(frame)
	cancelButton:Configure(30, L.WINDOW.cancel, L.WINDOW.cancelTooltip)
	cancelButton:SetPoint("RIGHT", applyButton, "LEFT", -10, 0)
	cancelButton:SetClickHandler(function()
		RestorePendingChanges()
		module.Hide()
	end)
	SkinButton(cancelButton)

	resetButton = MSBTControls.CreateOptionButton(frame)
	resetButton:Configure(30, L.WINDOW.resetProfile, L.BUTTONS["resetProfile"].tooltip)
	resetButton:SetPoint("RIGHT", cancelButton, "LEFT", -10, 0)
	local confirmReset = {
		parentFrame = frame, anchorFrame = resetButton,
		anchorPoint = "BOTTOMRIGHT", relativePoint = "TOPRIGHT",
		acknowledgeHandler = function()
			MSBTProfiles.ResetProfile()
			RefreshPage()
		end,
	}
	resetButton:SetClickHandler(function() MSBTOptions.Popups.ShowAcknowledge(confirmReset) end)
	SkinButton(resetButton)

	changesButton = MSBTControls.CreateOptionButton(frame)
	changesButton:Configure(30, "", L.WINDOW.changesHint)
	changesButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 9)
	-- The game's settings list has no entry that this window can switch to by itself.
	changesButton:SetClickHandler(function()
		if dockedOpeners then dockedOpeners.changes() else SelectPage("changes") end
	end)
	SkinButton(changesButton)

	-- The factory's button brings the tooltip, the client's size grabber replaces its symbol, and
	-- it lies above the Apply button, whose corner it shares.
	local grip = MSBTControls.CreateIconButton(frame, "Configure")
	chrome[#chrome + 1] = grip
	grip:SetTooltip(L.WINDOW.resizeTooltip)
	grip:SetScript("OnClick", nil)
	grip:SetScript("OnMouseDown", OnMouseDownGrip)
	grip:SetScript("OnMouseUp", OnMouseUpGrip)
	-- A drag cut short by closing the window must not go on when it opens again.
	grip:SetScript("OnHide", StopScaling)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
	grip:SetFrameLevel(applyButton:GetFrameLevel() + 1)
	grip:SetNormalTexture(GRIP_TEXTURE .. "Up")
	grip:SetHighlightTexture(GRIP_TEXTURE .. "Highlight")
	grip:SetPushedTexture(GRIP_TEXTURE .. "Down")
end


local function CreateRule(anchor, offsetY)
	local texture = frame:CreateTexture(nil, "ARTWORK")
	texture:SetColorTexture(COLORS.border[1], COLORS.border[2], COLORS.border[3])
	texture:SetPoint(anchor .. "LEFT", frame, anchor .. "LEFT", 1, offsetY)
	texture:SetPoint(anchor .. "RIGHT", frame, anchor .. "RIGHT", -1, offsetY)
	texture:SetHeight(1)
	return texture
end


-- The page title, the hint, the divider and the page area start at left.
local function PlaceContent(left)
	titleFontString:ClearAllPoints()
	titleFontString:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -HEADER_HEIGHT - 16)
	if divider then
		divider:ClearAllPoints()
		divider:SetPoint("TOPLEFT", frame, "TOPLEFT", left, 3 - PAGE_TOP)
	end
	hintFontString:ClearAllPoints()
	hintFontString:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -HEADER_HEIGHT - 42)
	pageArea:ClearAllPoints()
	pageArea:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -PAGE_TOP)
end


local function CreateWindow()
	snapshots = MSBTProfiles.GetProfileSnapshots()

	frame = CreateFrame("Frame", "MSBTOptionsWindowFrame", UIParent)
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(WIDTH)
	frame:SetHeight(HEIGHT)
	frame:SetPoint("CENTER")
	-- The game's settings window plays its own sounds.
	frame:SetScript("OnShow", function()
		if not dockedPanel then PlaySound(SOUNDKIT.IG_MAINMENU_OPTION) end
		baseSnapshot = baseSnapshot or snapshots:Take()
		baseMechanics = baseMechanics or TakeMechanics()
		SelectPage(dockedKey or currentKey)
	end)
	-- Still shown here means only a parent was hidden, as when the interface is hidden.
	frame:SetScript("OnHide", function(self)
		if self:IsShown() then return end
		if not dockedPanel then PlaySound(799) end
		MSBTOptMain.HidePopups()
		if not keepBaseOnHide then
			module.EndSession()
			MSBTOptions.Popups.UseDesignPopups("classic")
		end
	end)
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	table.insert(UISpecialFrames, frame:GetName())

	chrome[#chrome + 1] = Fill(frame, COLORS.border)
	chrome[#chrome + 1] = Fill(frame, COLORS.window, "BORDER", 1)
	CreateRule("TOP", -HEADER_HEIGHT)
	CreateRule("BOTTOM", FOOTER_HEIGHT)

	-- Blizzard's page title is white over a divider; the flat title is gold.
	local art = HasBlizzardArt()
	titleFontString = frame:CreateFontString(nil, "OVERLAY", art and "GameFontHighlightHuge" or "GameFontNormalHuge")
	if art then
		-- Below the hint line, which ends 6 above the page.
		divider = AtlasTexture(frame, "Options_HorizontalDivider", "ARTWORK")
	else
		SetTextColor(titleFontString, COLORS.gold)
	end

	hintFontString = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	hintFontString:SetWidth(PAGE_WIDTH)
	hintFontString:SetJustifyH("LEFT")
	SetTextColor(hintFontString, COLORS.hint)

	pageArea = CreateFrame("Frame", nil, frame)
	pageArea:SetWidth(PAGE_WIDTH)
	pageArea:SetHeight(PAGE_HEIGHT)
	PlaceContent(PAGE_LEFT)

	CreateHeader()
	CreateSidebar()
	CreateFooter()

	-- Every options write goes through these, so the footer follows without polling.
	for _, name in ipairs({ "SetOption", "SetOptionUserDisabled", "ResetOfficialBlizzardCombatText" }) do
		hooksecurefunc(MSBTProfiles, name, UpdateState)
	end
	for _, name in ipairs({ "SelectProfile", "CopyProfile", "DeleteProfile", "ResetProfile", "ImportProfile" }) do
		hooksecurefunc(MSBTProfiles, name, UpdateHeader)
	end
	-- Another design takes its popups when it opens, which ends a moment this window was put
	-- away for: its Cancel base is stale then.
	hooksecurefunc(MSBTOptions.Popups, "UseDesignPopups", function(key)
		if key ~= "forever" and not frame:IsShown() then
			module.EndSession()
			reopenSettings = nil
		end
	end)
end



local function FormatValue(value)
	if value == nil then return L.WINDOW.unset end
	if type(value) == "table" then return L.TABS.profile.label end
	return tostring(value)
end


local function UndoChange(this)
	snapshots:Revert(snapshots:GetLoginSnapshot(), changes[this:GetParent().item].path)
	AfterRestore()
end


local function CreateChangeLine(listbox)
	local line = CreateFrame("Button", nil, listbox)
	line:EnableMouse(false)

	local keyFontString = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	keyFontString:SetPoint("LEFT", line, "LEFT", 4, 0)
	keyFontString:SetWidth(360)
	keyFontString:SetJustifyH("LEFT")
	SetTextColor(keyFontString, COLORS.text)

	local oldFontString = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	oldFontString:SetPoint("LEFT", keyFontString, "RIGHT", 8, 0)
	oldFontString:SetWidth(90)
	oldFontString:SetJustifyH("LEFT")
	SetTextColor(oldFontString, COLORS.hint)

	local newFontString = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	newFontString:SetPoint("LEFT", oldFontString, "RIGHT", 8, 0)
	newFontString:SetWidth(90)
	newFontString:SetJustifyH("LEFT")
	SetTextColor(newFontString, COLORS.gold)

	local button = MSBTControls.CreateOptionButton(line)
	button:Configure(CHANGE_LINE_HEIGHT - 4, L.WINDOW.undo, L.WINDOW.undoTooltip)
	button:SetPoint("RIGHT", line, "RIGHT", -4, 0)
	button:SetClickHandler(UndoChange)
	SkinButton(button)

	line.undoButton = button
	line.keyFontString = keyFontString
	line.oldFontString = oldFontString
	line.newFontString = newFontString
	return line
end


local function DisplayChangeLine(listbox, line, item)
	local entry = changes[item]
	line.item = item
	local tooltip = entry.path[1] == "currentProfileName"
		and L.WINDOW.undoSelectedProfileTooltip or L.WINDOW.undoTooltip
	line.undoButton:SetTooltip(tooltip)
	line.keyFontString:SetText(entry.key)
	line.oldFontString:SetText(FormatValue(entry.old))
	line.newFontString:SetText(FormatValue(entry.new))
end


local function CreateChangesPage(page, width, height)
	undoAllButton = MSBTControls.CreateOptionButton(page)
	undoAllButton:Configure(26, L.WINDOW.undoAll, L.WINDOW.undoAllTooltip)
	undoAllButton:SetPoint("TOPRIGHT", page, "TOPRIGHT")
	undoAllButton:SetClickHandler(function()
		MSBTProfiles.FinishImportedMedia(false)
		snapshots:Restore(snapshots:GetLoginSnapshot())
		AfterRestore()
	end)
	SkinButton(undoAllButton)

	changesListbox = MSBTControls.CreateListbox(page)
	changesListbox:Configure(width, height - 36, CHANGE_LINE_HEIGHT)
	changesListbox:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -36)
	changesListbox:SetCreateLineHandler(CreateChangeLine)
	changesListbox:SetDisplayHandler(DisplayChangeLine)
	SkinListbox(changesListbox)

	noChangesFontString = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	noChangesFontString:SetPoint("TOPLEFT", page, "TOPLEFT", 4, -44)
	noChangesFontString:SetText(L.WINDOW.noChanges)
	SetTextColor(noChangesFontString, COLORS.hint)
end


-- Diff creates the entries, but only when this page is shown or an undo is clicked.
local function RefreshChangesPage()
	changes = snapshots:Diff(snapshots:GetLoginSnapshot())
	changesListbox:Clear()
	for index = 1, #changes do
		changesListbox:AddItem(index)
	end
	noChangesFontString:SetShown(#changes == 0)
	if #changes > 0 then undoAllButton:Enable() else undoAllButton:Disable() end
end



local function RegisterPage(key, create, refresh, arg)
	pages[key] = { create = create, refresh = refresh, arg = arg }
end


-- Adds a page after the pages of the design. A file outside the design calls it while the addon's
-- files load: the game's settings window takes its list once the addon has loaded, and the sidebar
-- is built with the window; a page added later is missing from them. The key must be new, and
-- label and hint are required. A field of the module: the main chunk is close to Lua's limit of
-- 200 locals.
function module.AddPage(key, label, hint, create, refresh)
	assert(label and hint and not pages[key], "AddPage needs a new key, a label and a hint")
	ENTRIES[#ENTRIES + 1] = { key = key, label = label, hint = hint }
	RegisterPage(key, create, refresh)
end


local function Show()
	-- Put away from the game's settings window, the options come back there, a frame later. The
	-- positioning window asks from its OnHide, and the game runs the settings window's own OnShow
	-- only after such a script: that OnShow would put the window back on its first page.
	if reopenSettings then
		local reopen = reopenSettings
		reopenSettings = nil
		C_Timer.After(0, reopen)
		return
	end
	if not frame then CreateWindow() end
	-- The saved scale, held to this screen: it may have been saved on a larger one.
	frame:SetScale(math.min(MSBTProfiles.savedVariables.optionsScale or 1, MaxScale()))
	-- With the interface hidden, Show runs no OnShow, but writes still need a base.
	baseSnapshot = baseSnapshot or snapshots:Take()
	baseMechanics = baseMechanics or TakeMechanics()
	MSBTOptions.Popups.UseDesignPopups("forever")
	frame:Show()
end


local function GetSettingsFrame()
	return SettingsPanel or InterfaceOptionsFrame
end


local function IsSettingsShown()
	local settingsFrame = GetSettingsFrame()
	return settingsFrame ~= nil and settingsFrame:IsShown()
end


-- Escape belongs to the game's settings window while the frame stands in it.
local function SetSpecialFrame(isSpecial)
	local frameName = frame:GetName()
	for index, name in ipairs(UISpecialFrames) do
		if name == frameName then
			if not isSpecial then table.remove(UISpecialFrames, index) end
			return
		end
	end
	if isSpecial then table.insert(UISpecialFrames, frameName) end
end


local function SetChromeShown(isShown)
	for _, region in ipairs(chrome) do
		region:SetShown(isShown)
	end
end


-- The frame is scaled to fit inside the panel and keeps its proportions.
local function UpdateDockedLayout()
	if not dockedPanel then return end
	local width, height = dockedPanel:GetWidth(), dockedPanel:GetHeight()
	local scale = 1
	if width and width > DOCK_PADDING * 2 and height and height > DOCK_PADDING * 2 then
		scale = math.min(DOCK_MAX_SCALE, (width - DOCK_PADDING * 2) / DOCKED_WIDTH,
			(height - DOCK_PADDING * 2) / HEIGHT)
	end
	frame:SetScale(scale)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", dockedPanel, "TOPLEFT", DOCK_PADDING / scale, -DOCK_PADDING / scale)
end


-- The pages of the sidebar, in its order, for the game's settings list.
local function DockPages()
	local list = {}
	for _, entry in ipairs(ENTRIES) do
		if entry.key and (entry.tab or pages[entry.key]) then
			list[#list + 1] = { key = entry.key, label = EntryLabel(entry) }
		end
	end
	return list
end


-- Puts the window into a panel of the game's settings window with the page of key. A category
-- switch there hides one panel and shows the next while the settings window stays open.
local function Dock(panel, key, openers)
	if not frame then CreateWindow() end
	reopenSettings = nil
	-- Another design's window closes while the game's settings window shows the options.
	MSBTOptions.Designs.HideOthers("forever")
	baseSnapshot = baseSnapshot or snapshots:Take()
	baseMechanics = baseMechanics or TakeMechanics()
	MSBTOptions.Popups.UseDesignPopups("forever")
	dockedPanel, dockedKey, dockedOpeners = panel, key, openers
	frame:SetParent(panel)
	frame:SetFrameStrata(panel:GetFrameStrata())
	frame:EnableMouse(false)
	frame:SetClampedToScreen(false)
	SetSpecialFrame(false)
	SetChromeShown(false)
	frame:SetWidth(DOCKED_WIDTH)
	frame:SetHeight(HEIGHT)
	PlaceContent(DOCKED_LEFT)
	PlaceProfileDropdown(true)
	PlaceFooterButtons(true)
	UpdateDockedLayout()
	if not panel.msbtDesignLayoutHooked then
		panel.msbtDesignLayoutHooked = true
		panel:HookScript("OnSizeChanged", function(this)
			if dockedPanel == this then UpdateDockedLayout() end
		end)
	end
	if frame:IsShown() then SelectPage(key) else frame:Show() end
end


-- The window leaves the panel and is the standalone window again. The session ends with the
-- game's settings window; a category switch keeps Cancel's base. When the settings window closes,
-- the frame is hidden with it, and its OnHide takes that for a hidden interface and does nothing;
-- hiding it here runs no OnHide then. So the popups close and the session ends here.
local function Undock(panel)
	if not dockedPanel or dockedPanel ~= panel then return end
	local isEnding = not keepBaseOnHide and not IsSettingsShown()
	local wasKeeping = keepBaseOnHide
	keepBaseOnHide = true
	frame:Hide()
	keepBaseOnHide = wasKeeping
	MSBTOptMain.HidePopups()
	if isEnding then
		module.EndSession()
		MSBTOptions.Popups.UseDesignPopups("classic")
	end
	dockedPanel, dockedKey, dockedOpeners = nil, nil, nil
	frame:SetParent(UIParent)
	frame:SetFrameStrata("DIALOG")
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	SetSpecialFrame(true)
	SetChromeShown(true)
	frame:SetWidth(WIDTH)
	frame:SetHeight(HEIGHT)
	PlaceContent(PAGE_LEFT)
	PlaceProfileDropdown(false)
	PlaceFooterButtons(false)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER")
end


local function IsDocked()
	return dockedPanel ~= nil
end


-- keepBase leaves Cancel's base in place while the window is put away for a moment. In the game's
-- settings window that window closes, and the next Show opens it again at this page.
local function Hide(keepBase)
	if not frame then return end
	if not keepBase then
		module.EndSession()
		reopenSettings = nil
	end
	keepBaseOnHide = keepBase
	if dockedPanel then
		if keepBase then reopenSettings = dockedOpeners[dockedKey] end
		local settingsFrame = GetSettingsFrame()
		if settingsFrame and settingsFrame:IsShown() then HideUIPanel(settingsFrame) end
		-- Still docked means the settings window had no hide to run it.
		if dockedPanel then Undock(dockedPanel) end
	end
	frame:Hide()
	keepBaseOnHide = nil
end


function module.ConfirmSwitch(switch)
	if dockedPanel or not HasPendingChanges() then return false end
	local dialog = "MSBT_APPLY_BEFORE_DESIGN_SWITCH"
	if not StaticPopupDialogs[dialog] then
		local function Finish(data, discard)
			if not data or data.snapshot ~= baseSnapshot then return end
			if discard then RestorePendingChanges() end
			data.switch()
		end
		StaticPopupDialogs[dialog] = {
			text = L.WINDOW.designSwitchPending,
			button1 = L.WINDOW.applyAndSwitch,
			button2 = L.WINDOW.cancel,
			button3 = L.WINDOW.discardAndSwitch,
			OnAccept = function(_, data) Finish(data, false) end,
			OnAlt = function(_, data) Finish(data, true) end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	end
	StaticPopup_Show(dialog, nil, nil, { snapshot = baseSnapshot, switch = switch })
	return true
end


local function IsShown()
	return frame ~= nil and frame:IsShown()
end


RegisterPage("changes", CreateChangesPage, RefreshChangesPage)



module.COLORS			= COLORS
module.Fill				= Fill
module.Box				= Box
module.SkinButton		= SkinButton
module.SkinIconButton	= SkinIconButton
module.CreateIconButton	= CreateIconButton
module.SkinCheckbox		= SkinCheckbox
module.SkinEditbox		= SkinEditbox
module.SkinDropdown		= SkinDropdown
module.SkinSlider		= SkinSlider
module.SkinListbox		= SkinListbox
module.SkinScrollFrame	= SkinScrollFrame
module.SkinPopup		= SkinPopup
module.RegisterPage		= RegisterPage
module.RefreshSwitches	= RefreshSwitches
module.Show				= Show
module.Hide				= Hide
module.IsShown			= IsShown
module.DockPages		= DockPages
module.Dock				= Dock
module.Undock			= Undock
module.IsDocked			= IsDocked

MSBTOptions.Designs.Register("forever", {
	label = L.MSG_FOREVER_DESIGN, Show = Show, Hide = Hide, IsShown = IsShown, SkinPopup = SkinPopup,
	DockPages = DockPages, Dock = Dock, Undock = Undock, IsDocked = IsDocked,
	ConfirmSwitch = module.ConfirmSwitch,
})
