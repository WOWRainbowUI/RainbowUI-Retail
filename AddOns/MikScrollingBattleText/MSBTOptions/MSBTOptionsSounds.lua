local module = {}
MSBTOptions.Sounds = module

local Controls = MSBTOptions.Controls
local Popups = MSBTOptions.Popups
local Media = MikSBT.Media
local SoundAPI = MikSBT.API.Sounds
local L = MikSBT.translations

function module.ShowTab(frame)
	if not frame.created then
		frame.controls = {}
		local controls = frame.controls
		local locale = L.CHECKBOXES.enableSounds
		local checkbox = Controls.CreateCheckbox(frame)
		checkbox:Configure(28, locale.label, locale.tooltip)
		checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -18)
		checkbox:SetClickHandler(function(_, checked)
			MikSBT.Profiles.SetOption(nil, "soundsDisabled", not checked)
		end)
		controls.enableSoundsCheckbox = checkbox

		local resourceSounds = {
			{ control = "lowHealthSoundCheckbox", locale = "lowHealthSound",
				option = "lowHealthSoundDisabled" },
			{ control = "lowManaSoundCheckbox", locale = "lowManaSound",
				option = "lowManaSoundDisabled" },
		}
		for index, resource in ipairs(resourceSounds) do
			local anchor = checkbox
			local option = resource.option
			checkbox = Controls.CreateCheckbox(frame)
			locale = L.CHECKBOXES[resource.locale]
			checkbox:Configure(24, locale.label, locale.tooltip)
			checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT",
				index == 1 and 15 or 0, -4)
			checkbox:SetClickHandler(function(_, checked)
				MikSBT.Profiles.SetOption(nil, option, not checked)
			end)
			controls[resource.control] = checkbox
		end

		local button = Controls.CreateOptionButton(frame)
		locale = L.BUTTONS.addCustomSound
		button:Configure(20, locale.label, locale.tooltip)
		button:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", -15, -20)
		button:SetClickHandler(function(this)
			Popups.DisableControls(controls)
			module.ShowAddSound(frame, this, function()
				for _, control in pairs(controls) do
					if control.Enable then control:Enable() end
				end
			end)
		end)
		controls.addCustomSoundButton = button
		frame.created = true
	end

	local controls = frame.controls
	local profile = MikSBT.Profiles.currentProfile
	controls.enableSoundsCheckbox:SetChecked(not profile.soundsDisabled)
	controls.lowHealthSoundCheckbox:SetChecked(not profile.lowHealthSoundDisabled)
	controls.lowManaSoundCheckbox:SetChecked(not profile.lowManaSoundDisabled)
end

local function ValidateRegistration(name, file)
	if type(name) ~= "string" or name:match("^%s*$") then
		return L.MSG_INVALID_CUSTOM_SOUND_NAME
	end
	if name == "None" or Media.sounds[name] then
		return L.MSG_SOUND_NAME_ALREADY_EXISTS
	end
	if not SoundAPI:NormalizeFile(file) then return L.MSG_INVALID_SOUND_FILE end
end

function module.ShowAddSound(parent, anchor, hideHandler)
	local nameLocale = L.EDITBOXES.customSoundName
	local pathLocale = L.EDITBOXES.customSoundPath
	Popups.ShowInput({
		title = L.BUTTONS.addCustomSound.label,
		parentFrame = parent,
		anchorFrame = anchor,
		anchorPoint = "BOTTOMLEFT",
		relativePoint = "TOPLEFT",
		editboxLabel = nameLocale.label,
		editboxTooltip = nameLocale.tooltip,
		showSecondEditbox = true,
		secondEditboxLabel = pathLocale.label,
		secondEditboxTooltip = pathLocale.tooltip,
		validateHandler = ValidateRegistration,
		hideHandler = hideHandler,
		saveHandler = function(settings)
			local name = settings.inputText
			local file = SoundAPI:NormalizeFile(settings.secondInputText)
			local problem = ValidateRegistration(name, file)
			if problem then MikSBT.Print(problem); return end
			if Media.RegisterSound(name, file) then
				local saved = MikSBT.Profiles.savedMedia
				if type(saved.sounds) ~= "table" then saved.sounds = {} end
				saved.sounds[name] = file
			end
		end,
	})
end

function module.PopulateEventSound(frame, selected)
	local dropdown = frame.controls.soundDropdown
	dropdown:Clear()
	for name in Media.IterateSounds() do dropdown:AddItem(name, name) end
	dropdown:Sort()
	dropdown:AddItem(NONE, "")
	if selected and selected ~= "" and not Media.sounds[selected] then
		dropdown:AddItem(tostring(selected), selected)
	end
	dropdown:SetSelectedID(selected or "")
end

function module.CreateEventControls(frame, enableControls)
	local controls = frame.controls
	local locale = L.DROPDOWNS.sound
	local dropdown = Controls.CreateDropdown(frame)
	dropdown:Configure(150, locale.label, locale.tooltip)
	dropdown:SetPoint("TOPLEFT", controls.messageEditbox, "BOTTOMLEFT", 0, -20)
	controls.soundDropdown = dropdown

	local custom = Controls.CreateIconButton(frame, "Configure")
	custom:SetTooltip(L.BUTTONS.customSound.tooltip)
	custom:SetPoint("LEFT", dropdown, "RIGHT", 10, -5)
	custom:SetClickHandler(function()
		Popups.DisableControls(controls)
		Popups.ShowInput({
			parentFrame = frame,
			anchorFrame = custom,
			editboxLabel = L.EDITBOXES.soundFile.label,
			editboxTooltip = L.EDITBOXES.soundFile.tooltip,
			validateHandler = function(file)
				if not SoundAPI:NormalizeFile(file) then
					return L.MSG_INVALID_SOUND_FILE
				end
			end,
			saveHandler = function(settings)
				local file = SoundAPI:NormalizeFile(settings.inputText)
				if file then module.PopulateEventSound(frame, file) end
			end,
			hideHandler = enableControls,
		})
	end)
	controls.customSoundButton = custom

	local play = Controls.CreateOptionButton(frame)
	locale = L.BUTTONS.playSound
	play:Configure(20, locale.label, locale.tooltip)
	play:SetPoint("LEFT", custom, "RIGHT", 10, 0)
	play:SetClickHandler(function()
		local selected = dropdown:GetSelectedID()
		if not selected or selected == "" then return end
		if not Media.PlaySound(selected) then
			MikSBT.Print(L.MSG_SOUND_PLAYBACK_FAILED)
		end
	end)
	controls.playSoundButton = play
end
