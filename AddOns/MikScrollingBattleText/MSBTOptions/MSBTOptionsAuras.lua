local module = {}
MSBTOptions.Auras = module

local Controls = MSBTOptions.Controls
local Profiles = MikSBT.Profiles
local Tracking = MikSBT.Configuration.AuraTracking
local Spells = MikSBT.API.Spells
local L = MikSBT.translations

local function SaveRule(id, enabled)
	-- Save the whole map so an unchecked (false) row remains in the list.
	local rules = {}
	for key, value in pairs(Profiles.currentProfile.auraTracking or {}) do
		rules[key] = value
	end
	rules[id] = enabled
	Profiles.SetOption(nil, "auraTracking", rules)
	if enabled == nil and Profiles.currentProfile.auraSettings then
		local styles = {}
		for key, value in pairs(Profiles.currentProfile.auraSettings) do
			if key ~= id then styles[key] = value end
		end
		Profiles.SetOption(nil, "auraSettings", styles)
	end
end

function module.SaveSetting(id, field, value)
	local profile = Profiles.currentProfile
	local current = Tracking:GetSettings(profile, id)
	if value == current[field] then return end
	if value == profile.events.NOTIFICATION_BUFF[field] then value = nil end
	local styles, overrides = {}, {}
	for key, settings in pairs(profile.auraSettings or {}) do
		styles[key] = settings
	end
	for key, setting in pairs(styles[id] or {}) do overrides[key] = setting end
	overrides[field] = value
	styles[id] = next(overrides) and overrides or nil
	Profiles.SetOption(nil, "auraSettings", styles)
end

function module.AddRows(list, firstID)
	local ids = {}
	for id in pairs(Profiles.currentProfile.auraTracking or {}) do
		ids[#ids + 1] = id
	end
	table.sort(ids, function(left, right)
		if left == firstID then return right ~= firstID end
		if right == firstID then return false end
		return left < right
	end)
	for _, id in ipairs(ids) do list:AddItem(id) end
end

function module.CreateLine(parent, refresh, handlers)
	local line = CreateFrame("Frame", nil, parent)
	line:SetAllPoints(parent)

	local checkbox = Controls.CreateCheckbox(line)
	checkbox:Configure(24, nil, L.AURA_TRACKING_CHECKBOX)
	checkbox:SetPoint("LEFT", 26, 0)
	checkbox:SetClickHandler(function(_, enabled)
		SaveRule(line.auraID, enabled)
	end)
	line.checkbox = checkbox

	local remove = Controls.CreateIconButton(line, "Delete")
	remove:SetPoint("RIGHT", -10, 0)
	remove:SetTooltip(L.AURA_TRACKING_REMOVE)
	remove:SetClickHandler(function()
		SaveRule(line.auraID, nil)
		refresh()
	end)
	line.remove = remove

	local settings = Controls.CreateIconButton(line, "Configure")
	settings:SetPoint("RIGHT", remove, "LEFT", 0, 0)
	settings:SetTooltip(L.BUTTONS.eventSettings.tooltip)
	settings:SetClickHandler(handlers.settings)
	line.settingsButton = settings

	local font = Controls.CreateIconButton(line, "FontSettings")
	font:SetPoint("RIGHT", settings, "LEFT", 0, 0)
	font:SetTooltip(L.BUTTONS.eventFontSettings.tooltip)
	font:SetClickHandler(handlers.font)
	line.fontButton = font

	local swatch = Controls.CreateColorswatch(line)
	swatch:SetPoint("LEFT", 5, 0)
	swatch:SetColorChangedHandler(handlers.color)
	line.colorSwatch = swatch

	local label = line:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
	label:SetPoint("RIGHT", font, "LEFT", -5, 0)
	label:SetJustifyH("LEFT")
	line.label = label
	return line
end

function module.DisplayLine(line, id)
	line.auraID = id
	line.eventType = id
	line.codes = L.EVENT_CODES.SKILL_LONG
	line.checkbox:SetChecked(Profiles.currentProfile.auraTracking[id])
	local settings = Tracking:GetSettings(Profiles.currentProfile, id)
	line.colorSwatch:SetColor(settings.colorR or 1, settings.colorG or 1,
		settings.colorB or 1)
	local info = Spells:GetInfo(tonumber(id))
	line.label:SetText((info and info.name or L.AURA_TRACKING_UNKNOWN)
		.. " (" .. id .. ")")
end

function module.Create(parent, refresh)
	local panel = CreateFrame("Frame", nil, parent)
	panel:SetWidth(400)
	panel:SetHeight(60)
	panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -308)

	local input = Controls.CreateEditbox(panel)
	input:Configure(285, L.AURA_TRACKING_INPUT, L.AURA_TRACKING_HELP)
	input:SetPoint("TOPLEFT", 5, 0)
	panel.input = input

	local function AddAura()
		local id = Tracking:Resolve(input:GetText())
		if not id then MikSBT.Print(L.AURA_TRACKING_INVALID); return end
		if Profiles.currentProfile.auraTracking[id] == nil then
			SaveRule(id, false)
		end
		input:SetText("")
		refresh(id)
	end
	local add = Controls.CreateOptionButton(panel)
	add:Configure(20, L.AURA_TRACKING_ADD, L.AURA_TRACKING_HELP)
	add:SetPoint("BOTTOMLEFT", input, "BOTTOMRIGHT", 10, 0)
	add:SetClickHandler(AddAura)
	input:SetEnterHandler(AddAura)
	panel.add = add

	local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOPLEFT", input, "BOTTOMLEFT", 0, -6)
	hint:SetText(L.AURA_TRACKING_TITLE)

	function panel:Enable()
		input:Enable()
		add:Enable()
	end
	function panel:Disable()
		input:Disable()
		add:Disable()
	end
	return panel
end

return module
