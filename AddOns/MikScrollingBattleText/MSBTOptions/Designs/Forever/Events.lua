
local MSBTWindow = MSBTOptions.Window
local MSBTOptMain = MSBTOptions.Main
local MSBTControls = MSBTOptions.Controls
local MSBTPopups = MSBTOptions.Popups
local MSBTProfiles = MikSBT.Profiles
local MSBTAnimations = MikSBT.Animations
local Formatter = MikSBT.Services.Formatter
local Events = MSBTOptions.Tabs.events
local L = MikSBT.translations

local EraseTable = MikSBT.EraseTable
local fonts = MikSBT.Media.fonts
local COLORS = MSBTWindow.COLORS



local ROW_HEIGHT = 29
local TOP_HEIGHT = 48
local AURA_LIST_HEIGHT = 252
local LOOT_LIST_HEIGHT = 116
local PANEL_WIDTH = 270
local CONTROL_WIDTH = 160
local PREVIEW_MAX_SIZE = 32
local CHIP_COUNT = 5
local CHIP_WIDTH = 46
local COLUMN_EVENT = 26
local COLUMN_PREVIEW = 136
local COLUMN_AREA = 256
local COLUMN_SOUND = 364
local HEADER_INSET = 8
local SOUND_ICON ="Interface\\Addons\\MikScrollingBattleText\\MSBTOptions\\Designs\\Forever\\Artwork\\FlatSound"
local SOUND_ICON_SIZE = 16
local SEARCH_CATEGORIES = { "INCOMING_PLAYER_EVENTS", "INCOMING_PET_EVENTS", "OUTGOING_PLAYER_EVENTS",
	"OUTGOING_PET_EVENTS", "NOTIFICATION_EVENTS", "LOOT_EVENTS" }

-- Sample values for the rendered previews; school 4 is fire and power type 0 is mana.
local sample = {
	amount = 1234, damageType = 4, powerType = 0, ignoreDamageColoring = true,
	name = L.WINDOW.sampleName, effectName = L.WINDOW.sampleSkill,
}
local LOOT_SAMPLES = {
	NOTIFICATION_LOOT = L.WINDOW.sampleItem, NOTIFICATION_CURRENCY = L.WINDOW.sampleItem,
	NOTIFICATION_MONEY = L.WINDOW.sampleMoney,
}
-- What %t shows in a preview where it is not the damage type.
local SAMPLE_TOTAL = "5678"

-- One event font field per control; the labels follow the event being normal or crit.
local FONT_FIELDS = {
	{ field = "fontName", normal = L.DROPDOWNS.normalFont, crit = L.DROPDOWNS.critFont },
	{ field = "outlineIndex", normal = L.DROPDOWNS.normalOutline, crit = L.DROPDOWNS.critOutline },
	{ field = "fontSize", normal = L.SLIDERS.normalFontSize, crit = L.SLIDERS.critFontSize, min = 4 },
	{ field = "fontAlpha", normal = L.SLIDERS.normalFontOpacity, crit = L.SLIDERS.critFontOpacity, min = 1 },
}



local content
local listbox
local panel
local controls
local titleFontString
local previewFontString
local areaDropdown
local colorswatch
local stickyCheckbox
local fontSection
local resourceScroll
local resourceButton
local resourceCheckboxes
local auraPanel
local lootPanel
local questCheckbox
local tableWidth
local tableHeight
local chips = {}
local fontControls = {}
local qualityCheckboxes = {}
local inherited = {}
local headers = {}
-- Event names shown without the prefix their group repeats, by event.
local shortNames = {}
-- The groups a category has listed so far, while its rows are added.
local listedGroups = {}
-- A selected aura is shown through this one table, as aura rows carry only their ID.
local auraEvent = { codes = L.EVENT_CODES.SKILL_LONG }
local shownArg
local selected
local pendingSelection
local filling
local Refresh



-- Loot messages are filled in by the loot notifications themselves, not by the formatter:
-- %e is the item or the money text, %a the count and %t the total, money only has %e.
-- The formatter knows %t as the damage type only. An event whose codes describe another %t, such
-- as a total, shows a count there.
local function Render(settings, eventType, codes)
	local lootSample = LOOT_SAMPLES[eventType]
	if lootSample then
		local message = settings.message:gsub("%%e", lootSample)
		if eventType ~= "NOTIFICATION_MONEY" then message = message:gsub("%%a", "2"):gsub("%%t", "5") end
		return message
	end
	sample.message = settings.message
	if codes:find("%t", 1, true) and not codes:find(L.EVENT_CODES.DAMAGE_TYPE_TAKEN, 1, true)
		and not codes:find(L.EVENT_CODES.DAMAGE_TYPE_DONE, 1, true) then
		sample.message = settings.message:gsub("%%t", SAMPLE_TOTAL)
	end
	return Formatter:FormatEvent(sample)
end


local function SetColor(fontString, color)
	fontString:SetTextColor(color[1], color[2], color[3])
end


local function SetEventColor(fontString, settings)
	fontString:SetTextColor(settings.colorR or 1, settings.colorG or 1, settings.colorB or 1)
end


local function IsHeader(item)
	return type(item) == "table" and item.header ~= nil
end


local function CreateText(parent, template, color)
	local fontString = parent:CreateFontString(nil, "OVERLAY", template)
	fontString:SetJustifyH("LEFT")
	fontString:SetWordWrap(false)
	SetColor(fontString, color)
	return fontString
end


local function CreateButton(parent, label, tooltip, handler)
	local button = MSBTControls.CreateOptionButton(parent)
	button:Configure(22, label, tooltip)
	button:SetClickHandler(handler)
	MSBTWindow.SkinButton(button)
	return button
end


local function CreateCheckbox(parent, label, tooltip, handler)
	local checkbox = MSBTControls.CreateCheckbox(parent)
	checkbox:Configure(18, label, tooltip)
	checkbox:SetClickHandler(handler)
	MSBTWindow.SkinCheckbox(checkbox)
	return checkbox
end



-- Melee results by their name without the direction; a type that is not listed goes to the rest,
-- so an event added later does not pose as melee.
local MELEE_RESULTS = {
	DAMAGE = true, DAMAGE_CRIT = true, MISS = true, DODGE = true, PARRY = true,
	BLOCK = true, DEFLECT = true, ABSORB = true, IMMUNE = true, EVADE = true,
}

-- Groups follow the classic order of player and pet events: melee results, ranged results,
-- spells, healing, then the rest. Notifications and loot have no groups.
local function GroupOf(eventType)
	if eventType:find("^NOTIFICATION") then return end
	if eventType:find("HEAL") or eventType:find("HOT") then return "headerHealing" end
	if eventType:find("SPELL") then return "headerSpells" end
	local result = eventType:gsub("^PET_", ""):gsub("^[A-Z]+_", "", 1)
	if result:find("^RANGED_") then return "headerRanged" end
	return MELEE_RESULTS[result] and "headerMelee" or "headerOther"
end


-- Inside a group whose event names all begin with the same "Prefix: ", the rows leave it out.
-- A group's events need not follow each other in the list.
local function ShortenNames(events, first, group)
	local prefix = events[first].label:match("^.-: ")
	if not prefix then return end
	for index = first, #events do
		local event = events[index]
		if GroupOf(event.eventType) == group and event.label:sub(1, #prefix) ~= prefix then return end
	end
	for index = first, #events do
		local event = events[index]
		if GroupOf(event.eventType) == group then shortNames[event] = event.label:sub(#prefix + 1) end
	end
end


-- One header item per category and group, made on first use; a page with two categories
-- names the direction in its headers.
local function Header(category, group, named)
	local key = category .. group
	local header = headers[key]
	if not header then
		local text = L.WINDOW[group]
		if named then
			text = L.WINDOW[category:find("^INCOMING") and "incoming" or "outgoing"] .. " \194\183 " .. text
		end
		header = { header = text }
		headers[key] = header
	end
	return header
end



local function OnEnableClicked(this, isChecked)
	local row = this:GetParent()
	if row.auraID then
		MSBTOptions.Auras.SaveRule(row.auraID, isChecked)
	else
		Events.EnableOnClick(this, isChecked)
	end
end


local function OnRemoveAura(this)
	MSBTOptions.Auras.SaveRule(this:GetParent().auraID, nil)
	Refresh(nil, shownArg)
end


local function CreateColumn(row, x, width, color)
	local fontString = CreateText(row, "GameFontHighlightSmall", color)
	fontString:SetPoint("LEFT", row, "LEFT", x, 0)
	fontString:SetWidth(width)
	return fontString
end


local function CreateRow(this)
	local row = CreateFrame("Button", nil, this)

	local checkbox = CreateCheckbox(row, nil, nil, OnEnableClicked)
	checkbox:SetPoint("LEFT", row, "LEFT", 4, 0)
	row.enableCheckbox = checkbox

	local button = MSBTWindow.CreateIconButton(row, "Delete", L.AURA_TRACKING_REMOVE, OnRemoveAura)
	button:SetPoint("LEFT", row, "LEFT", COLUMN_SOUND, 0)
	row.removeButton = button

	row.nameFontString = CreateColumn(row, COLUMN_EVENT, COLUMN_PREVIEW - COLUMN_EVENT - 4, COLORS.text)
	row.previewFontString = CreateColumn(row, COLUMN_PREVIEW, COLUMN_AREA - COLUMN_PREVIEW - 4, COLORS.text)
	row.areaFontString = CreateColumn(row, COLUMN_AREA, COLUMN_SOUND - COLUMN_AREA - 4, COLORS.hint)
	local soundIcon = row:CreateTexture(nil, "OVERLAY")
	soundIcon:SetTexture(SOUND_ICON)
	soundIcon:SetWidth(SOUND_ICON_SIZE)
	soundIcon:SetHeight(SOUND_ICON_SIZE)
	soundIcon:SetPoint("LEFT", row, "LEFT", COLUMN_SOUND, 0)
	soundIcon:SetVertexColor(COLORS.gold[1], COLORS.gold[2], COLORS.gold[3])
	row.soundIcon = soundIcon

	-- A group header stands on a bar over the whole row, with a line on its upper edge and its
	-- text in white, as the groups of the sidebar.
	row.headerBar = MSBTWindow.Fill(row, COLORS.bar)
	local edge = row:CreateTexture(nil, "BORDER")
	edge:SetColorTexture(COLORS.border[1], COLORS.border[2], COLORS.border[3])
	edge:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
	edge:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)
	edge:SetHeight(1)
	row.headerEdge = edge
	local header = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	header:SetJustifyH("LEFT")
	header:SetWordWrap(false)
	header:SetWidth(tableWidth - 2 * HEADER_INSET)
	header:SetPoint("LEFT", row, "LEFT", HEADER_INSET, 0)
	row.headerFontString = header
	return row
end


-- Rows hold an event, an aura ID or a group header; a header takes no clicks.
local function DisplayRow(this, row, item)
	local isHeader = IsHeader(item)
	row:EnableMouse(not isHeader)
	row.enableCheckbox:SetShown(not isHeader)
	row.removeButton:SetShown(type(item) == "string")
	row.headerBar:SetShown(isHeader)
	row.headerEdge:SetShown(isHeader)
	row.headerFontString:SetText(isHeader and item.header or "")
	if isHeader then
		row.tooltip, row.eventType, row.auraID = nil, nil, nil
		row.nameFontString:SetText("")
		row.previewFontString:SetText("")
		row.areaFontString:SetText("")
		row.soundIcon:Hide()
		return
	end

	local auraID = type(item) == "string" and item or nil
	local eventType = auraID or item.eventType
	local settings = Events.GetSettings(eventType)
	local area = MSBTAnimations.scrollAreas[settings.scrollArea or Events.DEFAULT_SCROLL_AREA]
	row.eventType, row.auraID = eventType, auraID
	row.tooltip = nil
	if auraID then
		row.enableCheckbox:SetChecked(MSBTProfiles.currentProfile.auraTracking[auraID])
		row.nameFontString:SetText(MSBTOptions.Auras.Label(auraID))
		row.soundIcon:Hide()
	else
		row.enableCheckbox:SetChecked(not settings.disabled)
		row.nameFontString:SetText(shortNames[item] or item.label)
		-- The tooltip has the full name; a custom sound is a file path, of which the file name is shown.
		local tooltip = item.tooltip and item.label .. "\n" .. item.tooltip or item.label
		local sound = settings.soundFile
		local hasSound = sound ~= nil and sound ~= ""
		if hasSound then tooltip = tooltip .. "\n" .. (sound:match("[^\\/]+$") or sound) end
		row.tooltip = tooltip
		row.soundIcon:SetShown(hasSound)
	end
	row.previewFontString:SetText(Render(settings, eventType, auraID and auraEvent.codes or item.codes))
	SetEventColor(row.previewFontString, settings)
	-- A deleted scroll area leaves its key in the events that used it.
	row.areaFontString:SetText(area and area.name or settings.scrollArea)
end



-- Shows the saved values of the selected event; filling keeps the controls from saving them back.
local function Fill()
	local settings = Events.GetSettings(selected.eventType)
	filling = true
	if controls.messageEditbox:GetText() ~= settings.message then
		controls.messageEditbox:SetText(settings.message)
	end
	areaDropdown:SetSelectedID(settings.scrollArea or Events.DEFAULT_SCROLL_AREA)
	colorswatch:SetColor(settings.colorR or 1, settings.colorG or 1, settings.colorB or 1)
	stickyCheckbox:SetChecked(settings.alwaysSticky)
	stickyCheckbox:SetShown(not settings.isCrit)

	local own
	own, inherited.fontName, inherited.outlineIndex, inherited.fontSize, inherited.fontAlpha =
		Events.FontSource(selected.eventType)
	for _, control in ipairs(fontControls) do
		local spec = control.spec
		local value = own[spec.field]
		if spec.field == "fontName" and not fonts[value] then value = nil end
		local locale = settings.isCrit and spec.crit or spec.normal
		control:SetLabel(locale.label)
		control:SetTooltip(locale.tooltip)
		control.inheritCheckbox:SetChecked(not value)
		if value then control:Set(value) end
		control:ToggleInherit(not value, inherited[spec.field])
	end
	filling = false

	-- A registered font whose file is missing fails to load; the game font then shows the text.
	-- Not every client reports the failure from SetFont, so the font is read back.
	previewFontString:SetFont(fonts[fontControls[1]:Get()],
		math.min(fontControls[3]:Get(), PREVIEW_MAX_SIZE),
		MSBTPopups.OUTLINE_MAP[fontControls[2]:Get()] or "")
	if not previewFontString:GetFont() then previewFontString:SetFontObject(GameFontNormal) end
	previewFontString:SetText(Render(settings, selected.eventType, selected.codes))
	SetEventColor(previewFontString, settings)
	previewFontString:SetAlpha(fontControls[4]:Get() / 100)
end


-- Resource Gains shows its resource list in place of the font controls on request.
local function ShowResources(isShown)
	fontSection:SetShown(not isShown)
	resourceScroll:SetShown(isShown)
	resourceButton:SetLabel(isShown and L.WINDOW.font or L.WINDOW.resources)
	resourceButton:SetTooltip(isShown and L.WINDOW.fontTooltip or L.WINDOW.resourcesTooltip)
	local exclusions = MSBTProfiles.currentProfile.resourceExclusions
	for token, checkbox in pairs(resourceCheckboxes) do
		checkbox:SetChecked(not exclusions or exclusions[token] ~= true)
	end
end


-- The colour picker and the custom sound input save to the selected event, so they close with it.
local function CloseEditors()
	if ColorPickerFrame.associatedColorSwatch == colorswatch then
		ColorPickerFrame.associatedColorSwatch = nil
		ColorPickerFrame:Hide()
	end
	MSBTOptMain.HidePopups()
end


local function Select(item)
	CloseEditors()
	if type(item) == "string" then
		auraEvent.eventType, auraEvent.label = item, MSBTOptions.Auras.Label(item)
		item = auraEvent
	end
	local settings = Events.GetSettings(item.eventType)
	selected = item
	panel.eventType = item.eventType
	titleFontString:SetText(item.label)
	resourceButton:SetShown(item.eventType == "NOTIFICATION_RESOURCE_GAIN")
	ShowResources(false)

	local count = 0
	for line in item.codes:gmatch("[^\n]+") do
		count = count + 1
		chips[count]:SetText(line:match("^%S+"))
		chips[count]:SetTooltip(line)
	end
	for index, chip in ipairs(chips) do chip:SetShown(index <= count) end

	areaDropdown:Clear()
	for key, area in pairs(MSBTAnimations.scrollAreas) do areaDropdown:AddItem(area.name, key) end
	-- A deleted scroll area stays listed under its key, as the row shows it.
	local areaKey = settings.scrollArea or Events.DEFAULT_SCROLL_AREA
	if not MSBTAnimations.scrollAreas[areaKey] then areaDropdown:AddItem(areaKey, areaKey) end
	areaDropdown:Sort()
	local fontDropdown = fontControls[1]
	fontDropdown:Clear()
	for fontName in pairs(fonts) do fontDropdown:AddItem(fontName, fontName) end
	fontDropdown:Sort()
	MSBTOptions.Sounds.PopulateEventSound(panel, settings.soundFile)
	Fill()
end


local function Changed()
	listbox:Refresh()
	Fill()
end


-- Saves one field of the selected event or aura through the classic tab's saver.
local function Save(field, value, default)
	if filling then return end
	Events.SaveOption(selected.eventType, field, value, default)
	Changed()
end



local function OnClickRow(this, row, item)
	Select(item)
end


local function OnMessageChanged(this)
	Save("message", this:GetText())
end


-- Focusing the field highlights all of it, and Insert would replace the highlight.
local function OnClickChip(this)
	local editboxFrame = controls.messageEditbox.editboxFrame
	editboxFrame:HighlightText(0, 0)
	editboxFrame:Insert(this:GetText())
end


local function OnAreaChanged(this, id)
	Save("scrollArea", id, Events.DEFAULT_SCROLL_AREA)
end


local function OnColorChanged(this)
	Events.ColorswatchOnChanged(this)
	Changed()
end


local function OnStickyClicked(this, isChecked)
	Save("alwaysSticky", isChecked)
end


local function OnSoundChanged(this, id)
	Save("soundFile", id)
end


local function EnableSoundControls()
	for _, control in pairs(controls) do control:Enable() end
end


-- An inherited control is disabled, so only Fill changes it, and Fill sets filling.
local function OnFontControlChanged(this, value)
	Save(this.spec.field, value)
end


-- Inherit saves nil; unchecking it keeps the shown inherited value as the event's own.
local function OnInheritClicked(this, isChecked)
	local control = this.control
	Save(control.spec.field, not isChecked and control:Get() or nil)
	-- An aura does not keep a value equal to the buff notification's, so the save may leave
	-- the field inherited; the control stays open until a different value is chosen.
	if not isChecked then
		this:SetChecked(false)
		control:ToggleInherit(false)
	end
end


-- The classic popup saves a copy of the map, so each change saves a new one too.
local function OnResourceClicked(this, isChecked)
	local exclusions = {}
	for token, excluded in pairs(MSBTProfiles.currentProfile.resourceExclusions or exclusions) do
		exclusions[token] = excluded
	end
	exclusions[this.token] = not isChecked or nil
	MSBTProfiles.SetOption(nil, "resourceExclusions", exclusions)
end


local function OnClickResources()
	ShowResources(not resourceScroll:IsShown())
end


-- Headers and auras carry no event type of their own and are left alone.
local function SetAll(this)
	for index = 1, listbox:GetNumItems() do
		local item = listbox:GetItem(index)
		if type(item) == "table" and item.eventType then
			Events.SaveOption(item.eventType, "disabled", this.disabled)
		end
	end
	listbox:Refresh()
end



-- A group's rows stand together under one header, in the classic order, and the groups come in
-- the order of their first row. The classic tab lists the ranged results between the melee
-- results; here they follow the melee group.
local function AddCategory(category, named)
	local events = Events.GetEvents(category)
	EraseTable(listedGroups)
	for index, event in ipairs(events) do
		local group = GroupOf(event.eventType)
		if not group then
			listbox:AddItem(event)
		elseif not listedGroups[group] then
			listedGroups[group] = true
			listbox:AddItem(Header(category, group, named))
			ShortenNames(events, index, group)
			for later = index, #events do
				if GroupOf(events[later].eventType) == group then listbox:AddItem(events[later]) end
			end
		end
	end
end


-- Events of different categories share names, so the hits of each category follow its name.
-- lower() folds ASCII letters only; umlauts keep their case.
local function AddMatches(text)
	text = text:lower()
	for index, category in ipairs(SEARCH_CATEGORIES) do
		local header
		for _, event in ipairs(Events.GetEvents(category)) do
			if event.label:lower():find(text, 1, true) then
				if not header then
					header = headers[category] or { header = L.EVENT_CATEGORIES[index] or L.TABS.lootAlerts.label }
					headers[category] = header
					listbox:AddItem(header)
				end
				listbox:AddItem(event)
			end
		end
	end
end


-- The argument is the list of categories of an entry, or the search text.
-- The list is rebuilt every time, as tracked auras can change with the profile.
Refresh = function(page, arg)
	local isSearch = type(arg) == "string"
	local isNotifications = not isSearch and arg[1] == "NOTIFICATION_EVENTS"
	local isLoot = not isSearch and arg[1] == "LOOT_EVENTS"
	local previous = pendingSelection or arg == shownArg and listbox:GetSelectedItem()
	local offset = listbox:GetOffset()
	-- Only a newly added aura goes first and is scrolled to; others keep order and offset.
	local added = pendingSelection
	pendingSelection = nil
	shownArg = arg

	EraseTable(shortNames)
	listbox:Clear()
	listbox:Configure(tableWidth, isNotifications and AURA_LIST_HEIGHT or isLoot and LOOT_LIST_HEIGHT
		or tableHeight - TOP_HEIGHT, ROW_HEIGHT)
	auraPanel:SetShown(isNotifications)
	lootPanel:SetShown(isLoot)
	if isSearch then
		AddMatches(arg)
	else
		if isNotifications then
			MSBTOptions.Auras.AddRows(listbox, added)
		end
		for _, category in ipairs(arg) do AddCategory(category, #arg > 1) end
	end
	if isLoot then
		local profile = MSBTProfiles.currentProfile
		for quality, checkbox in pairs(qualityCheckboxes) do
			checkbox:SetChecked(not profile.qualityExclusions[quality])
		end
		questCheckbox:SetChecked(profile.alwaysShowQuestItems)
	end

	local first, found
	for index = 1, listbox:GetNumItems() do
		local item = listbox:GetItem(index)
		if item == previous then found = index end
		if not first and not IsHeader(item) then first = index end
	end
	local index = found or first
	if index then listbox:SetSelectedItem(index) end
	if found and not added then listbox:SetOffset(offset) end
	panel:SetShown(index ~= nil)
	listbox:Refresh()
	if index then Select(listbox:GetItem(index)) else CloseEditors() end
end


local function OnAuraAdded(id)
	pendingSelection = id
	Refresh(nil, shownArg)
end



local function CreateHeader(text, x, isRightEdge)
	local fontString = CreateText(content, "GameFontNormalSmall", COLORS.hint)
	local point = isRightEdge and "TOPRIGHT" or "TOPLEFT"
	fontString:SetPoint(point, content, "TOPLEFT", x, -TOP_HEIGHT + 14)
	fontString:SetText(text)
end


local function CreateTable()
	local allOff = CreateButton(content, L.WINDOW.allOff, L.WINDOW.allOffTooltip, SetAll)
	allOff:SetPoint("TOPRIGHT", content, "TOPLEFT", tableWidth, 0)
	allOff.disabled = true
	local button = CreateButton(content, L.WINDOW.allOn, L.WINDOW.allOnTooltip, SetAll)
	button:SetPoint("TOPRIGHT", allOff, "TOPLEFT", -8, 0)
	button.disabled = false

	CreateHeader(L.WINDOW.columnOn, 4)
	CreateHeader(L.WINDOW.columnEvent, COLUMN_EVENT)
	CreateHeader(L.WINDOW.columnPreview, COLUMN_PREVIEW)
	CreateHeader(L.WINDOW.columnArea, COLUMN_AREA)
	-- The last column ends where the sound symbol does, clear of the list's scroll bar.
	CreateHeader(L.WINDOW.columnSound, COLUMN_SOUND + SOUND_ICON_SIZE, true)

	listbox = MSBTControls.CreateListbox(content)
	listbox:Configure(tableWidth, tableHeight - TOP_HEIGHT, ROW_HEIGHT)
	listbox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -TOP_HEIGHT)
	listbox:SetCreateLineHandler(CreateRow)
	listbox:SetDisplayHandler(DisplayRow)
	listbox:SetClickHandler(OnClickRow)
	MSBTWindow.Fill(listbox, COLORS.panel)
	MSBTWindow.SkinListbox(listbox)

	-- Sits below the shorter list of the Notifications entry.
	auraPanel = MSBTOptions.Auras.Create(content, OnAuraAdded)
	auraPanel:SetWidth(tableWidth)
	MSBTWindow.SkinEditbox(auraPanel.input)
	MSBTWindow.SkinButton(auraPanel.add)
	-- The input starts 5 in and the button follows 10 after it; the input takes what the button leaves.
	auraPanel.input:SetWidth(tableWidth - 5 - 10 - auraPanel.add:GetWidth())
end


-- The Loot Alerts options besides its events, below the shorter list of that entry.
local function CreateLootPanel()
	lootPanel = CreateFrame("Frame", nil, content)
	lootPanel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -TOP_HEIGHT - LOOT_LIST_HEIGHT - 12)
	lootPanel:SetWidth(tableWidth)
	lootPanel:SetHeight(tableHeight - TOP_HEIGHT - LOOT_LIST_HEIGHT - 12)

	local fontString = CreateText(lootPanel, "GameFontNormalSmall", COLORS.hint)
	fontString:SetPoint("TOPLEFT", lootPanel, "TOPLEFT", 4, 0)
	fontString:SetText(L.MSG_ITEM_QUALITIES .. ":")
	local firstQuality, lastQuality = Events.Qualities()
	for quality = firstQuality, lastQuality do
		local checkbox = CreateCheckbox(lootPanel, Events.QualityLabel(quality), L.MSG_DISPLAY_QUALITY,
			Events.QualityOnClick)
		checkbox:SetPoint("TOPLEFT", lootPanel, "TOPLEFT", 4, -18 - (quality - firstQuality) * 24)
		checkbox.quality = quality
		qualityCheckboxes[quality] = checkbox
	end

	local locale = L.CHECKBOXES.alwaysShowQuestItems
	questCheckbox = CreateCheckbox(lootPanel, locale.label, locale.tooltip, Events.QuestItemsOnClick)
	questCheckbox:SetPoint("TOPLEFT", lootPanel, "TOPLEFT", 190, -18)

	-- The item list popup hangs from the buttons' parent; at the top of the page it stays in the window.
	local listParent = CreateFrame("Frame", nil, lootPanel)
	listParent:SetPoint("TOPRIGHT", content, "TOPLEFT", tableWidth, 0)
	listParent:SetWidth(1)
	listParent:SetHeight(1)
	local anchor = questCheckbox
	for _, listName in ipairs({ "itemsAllowed", "itemExclusions" }) do
		locale = L.BUTTONS[listName]
		local button = CreateButton(listParent, locale.label, locale.tooltip, Events.ItemListOnClick)
		button:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -12)
		button.listName = listName
		anchor = button
	end
end


local function CreateFontControls()
	local anchor = controls.soundDropdown
	local inheritLocale = L.CHECKBOXES.inheritValue or L.CHECKBOXES.inheritField
	for _, spec in ipairs(FONT_FIELDS) do
		local control
		if spec.min then
			control = MSBTControls.CreateSlider(fontSection)
			control:Configure(CONTROL_WIDTH)
			control:SetMinMaxValues(spec.min, 100)
			control:SetValueStep(1)
			control:SetValueChangedHandler(OnFontControlChanged)
			control:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -16)
			control.Set, control.Get = control.SetValue, control.GetValue
			control.ToggleInherit = MSBTPopups.ToggleSliderInheritState
			MSBTWindow.SkinSlider(control)
		else
			control = MSBTControls.CreateDropdown(fontSection)
			control:Configure(CONTROL_WIDTH)
			control:SetChangeHandler(OnFontControlChanged)
			control:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6)
			control.Set, control.Get = control.SetSelectedID, control.GetSelectedID
			control.ToggleInherit = MSBTPopups.ToggleDropdownInheritState
			MSBTWindow.SkinDropdown(control)
		end
		control.spec = spec

		local checkbox = CreateCheckbox(fontSection, inheritLocale.label, inheritLocale.tooltip, OnInheritClicked)
		checkbox:SetPoint("BOTTOMLEFT", control, "BOTTOMRIGHT", 12, spec.min and 6 or 3)
		checkbox.control = control
		control.inheritCheckbox = checkbox

		fontControls[#fontControls + 1] = control
		anchor = control
	end
	fontControls[1]:SetListboxHeight(180)
	for index, name in ipairs(L.OUTLINES) do fontControls[2]:AddItem(name, index) end
end


local function CreateResourceList()
	resourceButton = CreateButton(panel, L.WINDOW.resources, L.WINDOW.resourcesTooltip, OnClickResources)
	resourceButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -12, -10)

	resourceScroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
	resourceScroll:SetPoint("TOPLEFT", controls.soundDropdown, "BOTTOMLEFT", 0, -8)
	resourceScroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 10)
	local list = CreateFrame("Frame", nil, resourceScroll)
	list:SetWidth(PANEL_WIDTH - 60)
	resourceScroll:SetScrollChild(list)
	MSBTWindow.SkinScrollFrame(resourceScroll)
	resourceCheckboxes = MSBTPopups.CreateResourceList(list, OnResourceClicked)
	for _, checkbox in pairs(resourceCheckboxes) do MSBTWindow.SkinCheckbox(checkbox) end
end


local function CreatePanel()
	panel = CreateFrame("Frame", nil, content)
	panel:SetPoint("TOPRIGHT", content, "TOPRIGHT")
	panel:SetWidth(PANEL_WIDTH)
	panel:SetHeight(tableHeight)
	MSBTWindow.Box(panel, COLORS.panel)
	panel.controls = {}
	controls = panel.controls

	titleFontString = CreateText(panel, "GameFontNormalLarge", COLORS.gold)
	titleFontString:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -12)
	titleFontString:SetWidth(PANEL_WIDTH - 24)

	previewFontString = CreateText(panel, "GameFontNormal", COLORS.text)
	previewFontString:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -38)
	previewFontString:SetWidth(PANEL_WIDTH - 24)
	previewFontString:SetHeight(40)

	local editbox = MSBTControls.CreateEditbox(panel)
	local locale = L.EDITBOXES.eventMessage
	editbox:Configure(PANEL_WIDTH - 24, locale.label, locale.tooltip)
	editbox:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -84)
	editbox:SetTextChangedHandler(OnMessageChanged)
	MSBTWindow.SkinEditbox(editbox)
	controls.messageEditbox = editbox

	for index = 1, CHIP_COUNT do
		local chip = CreateButton(panel, "", nil, OnClickChip)
		chip:SetHeight(18)
		chip:SetWidth(CHIP_WIDTH)
		chip:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", (index - 1) * (CHIP_WIDTH + 4), -6)
		chips[index] = chip
	end

	areaDropdown = MSBTControls.CreateDropdown(panel)
	locale = L.DROPDOWNS.outputScrollArea
	areaDropdown:Configure(CONTROL_WIDTH, locale.label, locale.tooltip)
	areaDropdown:SetPoint("TOPLEFT", editbox, "BOTTOMLEFT", 0, -36)
	areaDropdown:SetChangeHandler(OnAreaChanged)
	MSBTWindow.SkinDropdown(areaDropdown)

	colorswatch = MSBTControls.CreateColorswatch(panel)
	colorswatch:SetPoint("BOTTOMLEFT", areaDropdown, "BOTTOMRIGHT", 14, 5)
	colorswatch:SetColorChangedHandler(OnColorChanged)
	local fontString = CreateText(panel, "GameFontHighlightSmall", COLORS.text)
	fontString:SetPoint("LEFT", colorswatch, "RIGHT", 6, 0)
	fontString:SetText(L.WINDOW.color)

	locale = L.CHECKBOXES.stickyEvent
	stickyCheckbox = CreateCheckbox(panel, locale.label, locale.tooltip, OnStickyClicked)
	stickyCheckbox:SetPoint("TOPLEFT", areaDropdown, "BOTTOMLEFT", 0, -8)

	MSBTOptions.Sounds.CreateEventControls(panel, EnableSoundControls, OnSoundChanged)
	controls.soundDropdown:ClearAllPoints()
	controls.soundDropdown:SetPoint("TOPLEFT", stickyCheckbox, "BOTTOMLEFT", 0, -6)
	controls.soundDropdown:SetWidth(CONTROL_WIDTH)
	MSBTWindow.SkinDropdown(controls.soundDropdown)
	MSBTWindow.SkinIconButton(controls.customSoundButton, "Settings")

	-- The popup's Play button has a text label; this one plays through the same handler.
	local play = MSBTWindow.CreateIconButton(panel, "Play",
		L.BUTTONS.playSound.label .. "\n" .. L.BUTTONS.playSound.tooltip, controls.playSoundButton.clickHandler)
	play:SetPoint("LEFT", controls.customSoundButton, "RIGHT", 10, 0)
	controls.playSoundButton:Hide()
	controls.playSoundButton = play

	fontSection = CreateFrame("Frame", nil, panel)
	fontSection:SetAllPoints(panel)
	CreateFontControls()
	CreateResourceList()
end


local function CreatePage(page, width, height)
	content = CreateFrame("Frame", nil, page)
	content:SetAllPoints(page)
	tableWidth, tableHeight = width - PANEL_WIDTH - 12, height
	CreateTable()
	CreateLootPanel()
	CreatePanel()
end



MSBTWindow.RegisterPage("incoming", CreatePage, Refresh, { "INCOMING_PLAYER_EVENTS" })
MSBTWindow.RegisterPage("outgoing", CreatePage, Refresh, { "OUTGOING_PLAYER_EVENTS" })
MSBTWindow.RegisterPage("pet", CreatePage, Refresh, { "INCOMING_PET_EVENTS", "OUTGOING_PET_EVENTS" })
MSBTWindow.RegisterPage("notifications", CreatePage, Refresh, { "NOTIFICATION_EVENTS" })
MSBTWindow.RegisterPage("lootAlerts", CreatePage, Refresh, { "LOOT_EVENTS" })
MSBTWindow.RegisterPage("search", CreatePage, Refresh)
