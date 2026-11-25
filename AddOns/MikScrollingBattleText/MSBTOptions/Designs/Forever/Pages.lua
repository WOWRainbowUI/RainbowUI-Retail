
local MSBTWindow = MSBTOptions.Window
local MSBTDesigns = MSBTOptions.Designs
local MSBTControls = MSBTOptions.Controls
local MSBTPopups = MSBTOptions.Popups
local MSBTSounds = MSBTOptions.Sounds
local MSBTGeneral = MSBTOptions.Tabs.general
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

local COLORS = MSBTWindow.COLORS
local EraseTable = MikSBT.EraseTable
local Print = MikSBT.Print



local COLUMN = 345
local ROW_HEIGHT = 26
local SOUND_LINE_HEIGHT = 30
local DEFAULT_PROFILE_NAME = "Default"
-- Blizzard's own text is chosen from two dropdowns under its enable switch, as in the game's combat
-- options: what its text at the character shows, and what stands over targets. An entry is ticked
-- while its text shows. It names its text in the window's table (text, tooltip) or by the key of a
-- classic checkbox (locale), and what it reads and writes: a "...Disabled" field of the profile
-- (option), a Blizzard switch of the profiles module (switch), or one of the client's two texts for
-- spell effects (mechanics). The numbers over targets are the profile's field, or the switch where
-- the profiles module has it.
local BLIZZARD_MENUS = {
	{ text = "blizzardOnMe", entries = {
		{ text = "incoming", tooltip = "blizzardIncomingTooltip", option = "blizzardIncomingDisabled" },
		{ text = "notifications", tooltip = "blizzardNotificationsTooltip", option = "blizzardNotificationsDisabled" },
		{ locale = "blizzardReputation", switch = "reputation" },
		{ locale = "blizzardHonor", switch = "honor" },
	} },
	{ text = "blizzardOnTarget", entries = {
		{ text = "blizzardNumbers", tooltip = "blizzardNumbersTooltip", option = "blizzardOutgoingDisabled", switch = "numbers" },
		{ locale = "spellMechanicsOwn", mechanics = "own" },
		{ locale = "spellMechanicsOthers", mechanics = "others" },
	} },
}
local BLIZZARD_MENU_WIDTH = 240
local BLIZZARD_MENU_TOP = 8
local BLIZZARD_MENU_STEP = 34
local LANGUAGE_NOTE_TOP = 96
-- The reset button stands in the second section, under the slider that ends 60 below its top.
local RESET_TOP = 74
-- The alert thresholds are sliders under the sound switches; the list below starts under them.
local THRESHOLDS = { "lowHealthThreshold", "lowManaThreshold" }
local THRESHOLD_DEFAULT = 35
local THRESHOLD_LEFT = 32
local THRESHOLD_TOP = 112
local THRESHOLD_STEP = 50
local SLIDER_HEIGHT = 30
local SOUNDS_SECTION_HEIGHT = THRESHOLD_TOP + (#THRESHOLDS - 1) * THRESHOLD_STEP + SLIDER_HEIGHT + 12

-- Field part and text of the sub-options under MSBT's enable switch, as on the classic General tab.
local SUB_OPTIONS = {
	{ "Outgoing", "disableOutgoing" },
	{ "Notifications", "disableNotifications" },
	{ "Incoming", "disableIncoming" },
}
-- Each entry opens what its classic General button opens: a popup that takes the shared config, or
-- the classic export of that name, which takes the anchor.
local FONTS_COLORS = {
	{ "masterFont", "ShowMasterFont" },
	{ "addFont", "ShowAddFont" },
	{ "partialEffects", MSBTPopups.ShowPartialEffects },
	{ "damageColors", MSBTPopups.ShowDamageColors },
	{ "classColors", MSBTPopups.ShowClassColors },
}



-- Popups copy what they need, so one table serves every click, as on the classic tabs.
local config = {}
local generalSwitches = {}
local soundSwitches = {}
local thresholdSliders = {}
local fontsColorsButtons = {}
local soundNames = {}
local refreshingThresholds

local msbtCheckbox
local speedSlider
local designDropdown
local reloadDesignButton
local soundsPage
local soundListbox
local noSoundsFontString
local profilePage
local profileFontString
local deleteButton



local function CreateText(parent, template, color, text)
	local fontString = parent:CreateFontString(nil, "OVERLAY", template)
	fontString:SetTextColor(color[1], color[2], color[3])
	fontString:SetJustifyH("LEFT")
	fontString:SetText(text)
	return fontString
end


local function CreateSection(page, top, height)
	local section = CreateFrame("Frame", nil, page)
	section:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -top)
	section:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, -top)
	section:SetHeight(height)
	MSBTWindow.Box(section, COLORS.panel)
	return section
end


local function CreateButton(parent, label, tooltip, handler)
	local button = MSBTControls.CreateOptionButton(parent)
	button:Configure(ROW_HEIGHT, label, tooltip)
	button:SetClickHandler(handler)
	MSBTWindow.SkinButton(button)
	return button
end


local function PopupConfig(parent, anchor, hideHandler)
	EraseTable(config)
	config.parentFrame = parent
	config.anchorFrame = anchor
	config.hideHandler = hideHandler
	return config
end


-- inverted saves the opposite for the "...Disabled" fields; context reapplies the Blizzard text.
local function OnClickSwitch(this, isChecked)
	if this.inverted then isChecked = not isChecked end
	MSBTProfiles.SetOption(nil, this.option, isChecked)
	if this.context then MSBTProfiles.ApplyContextOptions() end
end


local function CreateSwitch(parent, switches, localeKey, option, inverted, context)
	local locale = L.CHECKBOXES[localeKey]
	local checkbox = MSBTControls.CreateCheckbox(parent)
	checkbox:Configure(20, locale.label, locale.tooltip)
	checkbox:SetClickHandler(OnClickSwitch)
	checkbox.option, checkbox.inverted, checkbox.context = option, inverted, context
	MSBTWindow.SkinCheckbox(checkbox)
	switches[#switches + 1] = checkbox
	return checkbox
end


local function PopulateSwitches(switches)
	local profile = MSBTProfiles.currentProfile
	for _, checkbox in ipairs(switches) do
		local value = profile[checkbox.option]
		if checkbox.inverted then value = not value end
		checkbox:SetChecked(value)
	end
end


-- The numbers over targets stand for the client's setting where the profiles module has the switch
-- for them and the locale the text that only that switch brings; else for the profile's field.
local function UsesSwitch(entry)
	if not entry.option then return true end
	return entry.switch and MSBTProfiles.GetBlizzardSwitch and MSBTProfiles.SetBlizzardSwitch
		and L.CHECKBOXES.disableOutgoing.blizzardTooltip and true or false
end


-- Whether an entry's text shows. nil where the profiles module, the locale or the client lacks the
-- setting; such an entry is left out of its dropdown.
local function ReadEntry(entry)
	local profiles = MSBTProfiles
	if entry.option then
		if UsesSwitch(entry) then return profiles.GetBlizzardSwitch(entry.switch) ~= false end
		return not profiles.currentProfile[entry.option]
	end
	if not L.CHECKBOXES[entry.locale] then return nil end
	if entry.mechanics then
		if not (profiles.GetSpellMechanicsText and profiles.SetSpellMechanicsText) then return nil end
		local own, others = profiles.GetSpellMechanicsText()
		if entry.mechanics == "own" then return own end
		return others
	end
	-- A Blizzard switch also needs the record that Cancel puts back.
	if not (profiles.GetBlizzardSwitch and profiles.SetBlizzardSwitch
		and profiles.TakeBlizzardSwitches and profiles.RestoreBlizzardSwitches) then return nil end
	return (profiles.GetBlizzardSwitch(entry.switch))
end


-- The profile's field saves the opposite and reapplies the Blizzard text, like the classic checkbox;
-- the client's settings are marked and written by the profiles module.
local function OnPickEntry(entry)
	local isShown = not ReadEntry(entry)
	if not UsesSwitch(entry) then
		MSBTProfiles.SetOption(nil, entry.option, not isShown)
		MSBTProfiles.ApplyContextOptions()
		return
	end
	if entry.mechanics then
		MSBTProfiles.SetSpellMechanicsText(entry.mechanics, isShown)
	else
		MSBTProfiles.SetBlizzardSwitch(entry.switch, isShown)
	end
	MSBTWindow.RefreshSwitches()
end


local function EntryTexts(entry)
	if entry.text then return L.WINDOW[entry.text], L.WINDOW[entry.tooltip] end
	local locale = L.CHECKBOXES[entry.locale]
	return locale.label, locale.tooltip
end


local function ShowEntryTooltip(tooltip, description)
	local label, text = EntryTexts(description:GetData())
	GameTooltip_SetTitle(tooltip, label)
	if text then GameTooltip_AddNormalLine(tooltip, text, true) end
end


-- The game's menu asks for its entries each time it opens, so every entry shows the value of that
-- moment, and a click, which answers nothing, leaves the menu open. The menu stands at the screen's
-- scale, not the window's, and is made as wide as the dropdown looks.
local function ListEntries(dropdown, root)
	root:SetMinimumWidth(dropdown:GetWidth() * dropdown:GetEffectiveScale() / UIParent:GetEffectiveScale())
	for _, entry in ipairs(dropdown.entries) do
		if ReadEntry(entry) ~= nil then
			root:CreateCheckbox((EntryTexts(entry)), ReadEntry, OnPickEntry, entry):SetTooltip(ShowEntryTooltip)
		end
	end
end


-- The game's own dropdown with its menu. A client without that menu system gets no dropdown; its
-- classic design has every one of these settings as a checkbox.
local function CreateBlizzardMenu(section, menu)
	if type(WowStyle2DropdownMixin) ~= "table" then return nil end
	local dropdown = CreateFrame("DropdownButton", nil, section, "WowStyle2DropdownTemplate")
	dropdown:SetWidth(BLIZZARD_MENU_WIDTH)
	dropdown:OverrideText(L.WINDOW[menu.text])
	dropdown.entries = menu.entries
	dropdown:SetupMenu(ListEntries)
	return dropdown
end


local function CurrentProfileName()
	for name, profile in pairs(MSBTProfiles.savedVariables.profiles) do
		if profile == MSBTProfiles.currentProfile then return name end
	end
end



-- The reload button stays while the chosen design differs from the one the game's settings window shows.
local function RefreshReloadButton()
	if MSBTDesigns.IsSwitchPending() then reloadDesignButton:Show() else reloadDesignButton:Hide() end
end


local function RefreshGeneral()
	msbtCheckbox:SetChecked(not MSBTProfiles.IsModDisabled())
	PopulateSwitches(generalSwitches)
	speedSlider:SetValue(MSBTProfiles.currentProfile.animationSpeed)
	designDropdown:SetSelectedID(MSBTDesigns.GetSelected())
	RefreshReloadButton()
end


local function ResetBlizzardSCT()
	MSBTGeneral.ResetBlizzardSCT()
	RefreshGeneral()
end


local function OnClickResetBlizzardSCT(this)
	PopupConfig(this:GetParent(), this).acknowledgeHandler = ResetBlizzardSCT
	MSBTPopups.ShowAcknowledge(config)
end


local function OnClickReloadDesign()
	MSBTDesigns.ReloadForDesign(MSBTWindow.IsDocked() and "settings" or "window")
end


local function CreateGeneral(page)
	local section = CreateSection(page, 0, 130)
	local locale = L.CHECKBOXES["enableMSBT"]
	msbtCheckbox = MSBTControls.CreateCheckbox(section)
	msbtCheckbox:Configure(20, locale.label, locale.tooltip)
	msbtCheckbox:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -12)
	msbtCheckbox:SetClickHandler(function(this, isChecked)
		MSBTProfiles.SetOptionUserDisabled(not isChecked)
		RefreshGeneral()
	end)
	MSBTWindow.SkinCheckbox(msbtCheckbox)
	for index, option in ipairs(SUB_OPTIONS) do
		local checkbox = CreateSwitch(section, generalSwitches, option[2], "msbt" .. option[1] .. "Disabled", false, true)
		checkbox:SetPoint("TOPLEFT", msbtCheckbox, "BOTTOMLEFT", 20, -6 - (index - 1) * ROW_HEIGHT)
	end
	local blizzard = CreateSwitch(section, generalSwitches, "enableBlizzardDamage", "blizzardDamageEnabled", false, true)
	blizzard:SetPoint("TOPLEFT", section, "TOPLEFT", COLUMN, -12)
	for index, menu in ipairs(BLIZZARD_MENUS) do
		local dropdown = CreateBlizzardMenu(section, menu)
		if dropdown then
			dropdown:SetPoint("TOPLEFT", blizzard, "BOTTOMLEFT", 20, -BLIZZARD_MENU_TOP - (index - 1) * BLIZZARD_MENU_STEP)
		end
	end

	section = CreateSection(page, 140, 150)
	local anchor
	for index, switch in ipairs({
		{ "enableNames", "hideSkills", true },
		{ "enableIcons", "skillIconsDisabled", true },
		{ "stickyCrits", "stickyCritsDisabled", true },
		{ "stackSimilarHits", "stackSimilarHits" },
		{ "shortenNumbers", "shortenNumbers" },
	}) do
		anchor = CreateSwitch(section, generalSwitches, switch[1], switch[2], switch[3])
		anchor:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -12 - (index - 1) * ROW_HEIGHT)
	end
	locale = L.SLIDERS["animationSpeed"]
	speedSlider = MSBTControls.CreateSlider(section)
	speedSlider:Configure(300, locale.label, locale.tooltip)
	speedSlider:SetPoint("TOPLEFT", section, "TOPLEFT", COLUMN, -30)
	speedSlider:SetMinMaxValues(20, 250)
	speedSlider:SetValueStep(10)
	speedSlider:SetValueChangedHandler(function(this, value)
		MSBTProfiles.SetOption(nil, "animationSpeed", value)
	end)
	MSBTWindow.SkinSlider(speedSlider)
	-- Below the slider, where the column is free; the third section holds the design choice and the
	-- language note.
	locale = L.BUTTONS["resetBlizzardSCT"]
	local button = CreateButton(section, locale.label, locale.tooltip, OnClickResetBlizzardSCT)
	button:SetPoint("TOPLEFT", section, "TOPLEFT", COLUMN, -RESET_TOP)
	local fontString = CreateText(section, "GameFontHighlightSmall", COLORS.hint, L.TABS.resetBlizzardSCT.tooltip)
	fontString:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -6)
	fontString:SetWidth(320)

	section = CreateSection(page, 300, 156)
	locale = L.DROPDOWNS["optionsDesign"]
	designDropdown = MSBTControls.CreateDropdown(section)
	designDropdown:Configure(180, locale.label, locale.tooltip)
	designDropdown:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -8)
	for _, key in ipairs(MSBTDesigns.keys) do
		designDropdown:AddItem(MSBTDesigns.designs[key].label, key)
	end
	designDropdown:SetChangeHandler(function(this, id)
		MSBTDesigns.Select(id)
		this:SetSelectedID(MSBTDesigns.GetSelected())
		RefreshReloadButton()
	end)
	MSBTWindow.SkinDropdown(designDropdown)
	-- Beside the field, which stands at the bottom of the dropdown's frame, clear of the field's ground.
	locale = L.BUTTONS["reloadDesign"]
	reloadDesignButton = CreateButton(section, locale.label, locale.tooltip, OnClickReloadDesign)
	reloadDesignButton:SetPoint("BOTTOMLEFT", designDropdown, "BOTTOMRIGHT", 14, 0)
	reloadDesignButton:Hide()

	fontString = CreateText(section, "GameFontHighlightSmall", COLORS.text, L.LANGUAGE_INFO)
	fontString:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -LANGUAGE_NOTE_TOP)
	fontString:SetPoint("RIGHT", section, "RIGHT", -12, 0)
end



local function EnableFontsColors()
	for _, button in ipairs(fontsColorsButtons) do button:Enable() end
end


local function OnClickFontsColors(this)
	for _, button in ipairs(fontsColorsButtons) do button:Disable() end
	local parent = this:GetParent()
	if type(this.show) == "string" then
		MSBTGeneral[this.show](parent, this, "TOPRIGHT", "BOTTOMRIGHT", EnableFontsColors)
	else
		PopupConfig(parent, this, EnableFontsColors)
		config.anchorPoint, config.relativePoint = "TOPRIGHT", "BOTTOMRIGHT"
		this.show(config)
	end
end


-- The name, hint and button word of an entry: the label and tooltip of its classic button, which
-- for adding a font are the custom font texts.
local function FontsColorsTexts(key)
	if key == "addFont" then return L.CUSTOM_FONTS.add, L.CUSTOM_FONTS.help, L.WINDOW.add end
	local locale = L.BUTTONS[key]
	return locale.label, locale.tooltip, L.WINDOW.edit
end


local function CreateFontsColors(page)
	local section = CreateSection(page, 0, #FONTS_COLORS * 70 + 10)
	for index, entry in ipairs(FONTS_COLORS) do
		local label, tooltip, word = FontsColorsTexts(entry[1])
		local top = 10 + (index - 1) * 70
		local fontString = CreateText(section, "GameFontNormal", COLORS.gold, label)
		fontString:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -top)
		fontString = CreateText(section, "GameFontHighlightSmall", COLORS.hint, tooltip)
		fontString:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -top - 20)
		fontString:SetWidth(520)
		local button = CreateButton(section, word, tooltip, OnClickFontsColors)
		button:SetPoint("TOPRIGHT", section, "TOPRIGHT", -12, -top - 8)
		button.show = entry[2]
		fontsColorsButtons[index] = button
	end
end



-- The sliders are filled under a guard, so showing the page and putting a profile back write nothing.
local function PopulateThresholds()
	local profile = MSBTProfiles.currentProfile
	refreshingThresholds = true
	for _, slider in ipairs(thresholdSliders) do
		local value = profile[slider.option]
		if type(value) ~= "number" or not (value >= 1 and value <= 99) then value = THRESHOLD_DEFAULT end
		slider:SetValue(value)
	end
	refreshingThresholds = false
end


local function RefreshSounds()
	PopulateSwitches(soundSwitches)
	PopulateThresholds()
	local sounds = MSBTProfiles.savedMedia.sounds
	EraseTable(soundNames)
	for name in pairs(sounds) do soundNames[#soundNames + 1] = name end
	table.sort(soundNames)
	soundListbox:Clear()
	for index = 1, #soundNames do soundListbox:AddItem(index) end
	noSoundsFontString:SetShown(#soundNames == 0)
end


local function RemoveSound(name)
	MSBTSounds.RemoveSound(name)
	RefreshSounds()
end


local function OnClickPlay(this)
	MSBTSounds.PlaySound(soundNames[this:GetParent().item])
end


local function OnClickRemove(this)
	PopupConfig(soundsPage, this)
	config.anchorPoint, config.relativePoint = "TOPRIGHT", "BOTTOMRIGHT"
	config.acknowledgeHandler = RemoveSound
	config.saveArg1 = soundNames[this:GetParent().item]
	MSBTPopups.ShowAcknowledge(config)
end


local function CreateSoundLine(listbox)
	local line = CreateFrame("Button", nil, listbox)
	line:EnableMouse(false)
	line.nameFontString = CreateText(line, "GameFontHighlight", COLORS.text)
	line.nameFontString:SetPoint("LEFT", line, "LEFT", 8, 0)
	line.nameFontString:SetWidth(200)
	local remove = MSBTWindow.CreateIconButton(line, "Delete", L.WINDOW.remove .. "\n" .. L.WINDOW.removeTooltip,
		OnClickRemove)
	remove:SetPoint("RIGHT", line, "RIGHT", -4, 0)
	local play = MSBTWindow.CreateIconButton(line, "Play",
		L.BUTTONS.playSound.label .. "\n" .. L.BUTTONS.playSound.tooltip, OnClickPlay)
	play:SetPoint("RIGHT", remove, "LEFT", -8, 0)

	-- The path ends at the play button.
	line.fileFontString = CreateText(line, "GameFontHighlightSmall", COLORS.hint)
	line.fileFontString:SetPoint("LEFT", line, "LEFT", 216, 0)
	line.fileFontString:SetPoint("RIGHT", play, "LEFT", -8, 0)
	return line
end


local function DisplaySoundLine(listbox, line, item)
	local name = soundNames[item]
	line.item = item
	line.nameFontString:SetText(name)
	line.fileFontString:SetText(MSBTProfiles.savedMedia.sounds[name])
end


local function OnThresholdChanged(this, value)
	if refreshingThresholds then return end
	MSBTProfiles.SetOption(nil, this.option, math.floor(value + 0.5))
end


local function CreateThresholdSlider(section, option, index)
	local locale = L.SLIDERS[option]
	local slider = MSBTControls.CreateSlider(section)
	slider:Configure(300, locale.label, locale.tooltip)
	slider:SetPoint("TOPLEFT", section, "TOPLEFT", THRESHOLD_LEFT, -THRESHOLD_TOP - (index - 1) * THRESHOLD_STEP)
	slider:SetMinMaxValues(1, 99)
	slider:SetValueStep(1)
	slider.option = option
	slider:SetValueChangedHandler(OnThresholdChanged)
	MSBTWindow.SkinSlider(slider)
	thresholdSliders[index] = slider
end


local function CreateSounds(page, width, height)
	soundsPage = page
	local section = CreateSection(page, 0, SOUNDS_SECTION_HEIGHT)
	local anchor = CreateSwitch(section, soundSwitches, "enableSounds", "soundsDisabled", true)
	anchor:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -12)
	for index, switch in ipairs({
		{ "lowHealthSound", "lowHealthSoundDisabled" },
		{ "lowManaSound", "lowManaSoundDisabled" },
	}) do
		CreateSwitch(section, soundSwitches, switch[1], switch[2], true)
			:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 20, -6 - (index - 1) * ROW_HEIGHT)
	end
	for index, option in ipairs(THRESHOLDS) do CreateThresholdSlider(section, option, index) end

	local locale = L.BUTTONS["addCustomSound"]
	CreateButton(section, locale.label, locale.tooltip, function(this)
		MSBTSounds.ShowAddSound(page, this, RefreshSounds)
	end):SetPoint("TOPRIGHT", section, "TOPRIGHT", -12, -12)

	soundListbox = MSBTControls.CreateListbox(page)
	soundListbox:Configure(width, height - SOUNDS_SECTION_HEIGHT - 10, SOUND_LINE_HEIGHT)
	soundListbox:SetPoint("TOPLEFT", page, "TOPLEFT", 0, -SOUNDS_SECTION_HEIGHT - 10)
	soundListbox:SetCreateLineHandler(CreateSoundLine)
	soundListbox:SetDisplayHandler(DisplaySoundLine)
	MSBTWindow.Fill(soundListbox, COLORS.panel)
	MSBTWindow.SkinListbox(soundListbox)

	noSoundsFontString = CreateText(soundListbox, "GameFontHighlight", COLORS.hint, L.WINDOW.noSounds)
	noSoundsFontString:SetPoint("TOPLEFT", soundListbox, "TOPLEFT", 8, -10)
end



local function RefreshProfile()
	local name = CurrentProfileName()
	profileFontString:SetText(string.format(L.WINDOW.currentProfile, name or DEFAULT_PROFILE_NAME))
	if name == DEFAULT_PROFILE_NAME then deleteButton:Disable() else deleteButton:Enable() end
end


local function ValidateProfileName(name)
	if not name or name == "" then return L.MSG_INVALID_PROFILE_NAME end
	if MSBTProfiles.savedVariables.profiles[name] then return L.MSG_PROFILE_ALREADY_EXISTS end
end


local function CopyProfile(settings)
	MSBTProfiles.CopyProfile(CurrentProfileName(), settings.inputText)
	MSBTProfiles.SelectProfile(settings.inputText)
	-- The popup ran its hide handler before saving, so the page refreshes once more.
	RefreshProfile()
end


local function ResetProfile()
	MSBTProfiles.ResetProfile(CurrentProfileName())
end


local function DeleteProfile()
	MSBTProfiles.DeleteProfile(CurrentProfileName())
end


local function OnClickCopy(this)
	local locale = L.EDITBOXES["copyProfile"]
	PopupConfig(profilePage, this, RefreshProfile)
	config.defaultText = L.MSG_NEW_PROFILE
	config.editboxLabel = locale.label
	config.editboxTooltip = locale.tooltip
	config.validateHandler = ValidateProfileName
	config.saveHandler = CopyProfile
	MSBTPopups.ShowInput(config)
end


local function OnClickReset(this)
	PopupConfig(profilePage, this, RefreshProfile).acknowledgeHandler = ResetProfile
	MSBTPopups.ShowAcknowledge(config)
end


local function OnClickDelete(this)
	PopupConfig(profilePage, this, RefreshProfile).acknowledgeHandler = DeleteProfile
	MSBTPopups.ShowAcknowledge(config)
end


local function OnClickExport()
	local text, errorCode = MSBTProfiles.ExportProfile(CurrentProfileName())
	if not text then
		Print(L.PROFILE_TRANSFER.errors[errorCode], 1, 0.3, 0.3)
		return
	end
	MSBTOptions.ProfileTransfer.ShowExport({ parentFrame = profilePage, hideHandler = RefreshProfile }, text)
end


local function OnClickImport()
	MSBTOptions.ProfileTransfer.ShowImport({
		parentFrame = profilePage,
		hideHandler = RefreshProfile,
		importHandler = function(text, name)
			return MSBTProfiles.ImportProfile(text, name, true)
		end,
		successHandler = MSBTGeneral.ReportImport,
	})
end


local function CreateProfile(page)
	profilePage = page
	local section = CreateSection(page, 0, 130)
	profileFontString = CreateText(section, "GameFontNormal", COLORS.gold)
	profileFontString:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -12)

	local locale = L.BUTTONS["copyProfile"]
	local button = CreateButton(section, locale.label, locale.tooltip, OnClickCopy)
	button:SetPoint("TOPLEFT", section, "TOPLEFT", 12, -44)
	locale = L.BUTTONS["resetProfile"]
	local anchor = CreateButton(section, locale.label, locale.tooltip, OnClickReset)
	anchor:SetPoint("LEFT", button, "RIGHT", 10, 0)
	locale = L.BUTTONS["deleteProfile"]
	deleteButton = CreateButton(section, locale.label, locale.tooltip, OnClickDelete)
	deleteButton:SetPoint("LEFT", anchor, "RIGHT", 10, 0)

	locale = L.PROFILE_TRANSFER
	anchor = CreateButton(section, locale.export, locale.exportHelp, OnClickExport)
	anchor:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -12)
	CreateButton(section, locale.import, locale.importHelp, OnClickImport)
		:SetPoint("LEFT", anchor, "RIGHT", 10, 0)
end



-- The helpers a file outside the design builds its own page with.
MSBTWindow.CreateText = CreateText
MSBTWindow.CreateSection = CreateSection
MSBTWindow.CreateButton = CreateButton

MSBTWindow.RegisterPage("general", CreateGeneral, RefreshGeneral)
MSBTWindow.RegisterPage("fontsColors", CreateFontsColors)
MSBTWindow.RegisterPage("sounds", CreateSounds, RefreshSounds)
MSBTWindow.RegisterPage("profile", CreateProfile, RefreshProfile)
