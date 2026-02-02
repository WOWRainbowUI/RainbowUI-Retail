local addonName, ACP = ...
local options = {}
local _

function ACP.ActionCamPlusConfig_Setup()
	local defaults = {
		lastVersion = ACP.version,

		ACP_AddonEnabled = true,
		ACP_ActionCam = false,
		ACP_Focusing = false,
		ACP_FocusingInteract = false,
		ACP_Pitch = true,
		ACP_SetCameraZoom = true,
		ACP_AutoSetCameraDistance = true,
		unmountedCamDistance = 20,

		ACP_Mounted = true,
		ACP_MountedActionCam = true,
		ACP_MountedFocusing = false,
		ACP_MountedFocusingInteract = false,
		ACP_MountedPitch = false,
		ACP_DruidFormMounts = true,
		ACP_MountedSetCameraZoom = true,
		ACP_AutoSetMountedCameraDistance = true,
		ACP_MountSpecificZoom = false,
		mountedCamDistance = 30,

		ACP_Combat = false,
		ACP_CombatActionCam = false,
		ACP_CombatFocusing = false,
		ACP_CombatFocusingInteract = false,
		ACP_CombatPitch = false,
		ACP_CombatSetCameraZoom = false,
		ACP_AutoSetCombatCameraDistance = true,
		combatCamDistance = 20,

		defaultZoomSpeed = GetCVar("cameraZoomSpeed"),
		transitionUsingSpeed = true,
		transitionSpeed = 3,
		transitionTime = 4,
		transitionFunction = 2,
		focusStrengthVertical = .75,
		focusStrengthHorizontal = 1,

		pitchStrength = 0.4,
		pitchDownStrength = 0.25,
		pitchFlightStrength = 0.75,

		horizontalOffset = 1,
		horizontalOffsetTime = 2,
		syncHorizontalOffsetTime = true,
		leftShoulder = false,

		mountZooms = {}
	}

	if not ActionCamPlusDB then
		ActionCamPlusDB = defaults
	elseif not ActionCamPlusDB.lastVersion or ActionCamPlusDB.lastVersion ~= ACP.version then
		ACP.UpdateDB(defaults)
	end

	ACP.AddOptions()
end

local WINDOW_HEIGHT = 640
local WINDOW_WIDTH = 540
local WINDOW_PADDING = 30
local INDENT = 20
local OPTION_SPACING = 2
local TAB_SELECT_HEIGHT = 40
local CONTENT_WIDTH = WINDOW_WIDTH - WINDOW_PADDING * 2
local COLUMN_GAP = 10

ActionCamPlusOptionsFrame = CreateFrame("Frame", "ActionCamPlusOptionsFrame", UIParent, "SettingsFrameTemplate")
ActionCamPlusOptionsFrame:SetScript("OnEvent", function(self, event, ...) self:PLAYER_ENTERING_WORLD(...) end)
ActionCamPlusOptionsFrame:SetToplevel(true)
ActionCamPlusOptionsFrame:SetFrameStrata("HIGH")
ActionCamPlusOptionsFrame:EnableMouse(true)
ActionCamPlusOptionsFrame:SetMovable(true)
ActionCamPlusOptionsFrame.NineSlice.Text:SetText("動感鏡頭 Plus 設定選項")

tinsert(UISpecialFrames, ActionCamPlusOptionsFrame:GetName())
ActionCamPlusOptionsFrame:RegisterForDrag("LeftButton")

ActionCamPlusOptionsFrame:SetScript("OnMouseDown", function(self, button) if button == "LeftButton" then self:StartMoving() end end)
ActionCamPlusOptionsFrame:SetScript("OnMouseUp", function(self, button) if button == "LeftButton" then self:StopMovingOrSizing() end end)
ActionCamPlusOptionsFrame:SetPoint("CENTER", UIParent)
ActionCamPlusOptionsFrame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)

local tabSystem

local closebutton = CreateFrame("Button", "$parentButtonClose", ActionCamPlusOptionsFrame, "UIPanelButtonTemplate")
closebutton:SetText("Close")
closebutton:SetSize(80, 20)
closebutton:SetPoint("BOTTOM", 0, 10)
closebutton:SetScript("OnClick", function() ActionCamPlusOptionsFrame:Hide() end)

-- UI element templates
-----------------------

function ActionCamPlusOptionsFrame.CreateTab(self, name)
	local tabIndex = tabSystem:AddTab(name)
	local tab = tabSystem.tabs[tabIndex]

	tab.content = CreateFrame("Frame", "$parent"..name.."Options", ActionCamPlusOptionsFrame)
	local padding = WINDOW_PADDING * 2
	tab.content:SetSize(CONTENT_WIDTH, WINDOW_HEIGHT - padding - TAB_SELECT_HEIGHT - 10)
	tab.content:SetPoint("TOP", tabSystem, "BOTTOM", 0, -10)
	tab.content:Hide()

	return tab.content
end

function ActionCamPlusOptionsFrame.CreateCheckbox(self, name, setting, parent, depenency, tooltip, indent)
	local checkbox = CreateFrame("CheckButton", "$parent"..setting.."Checkbox", parent, "SettingsCheckBoxControlTemplate")
	checkbox:SetWidth(CONTENT_WIDTH / 2 - COLUMN_GAP)
	checkbox.Tooltip:SetPoint("RIGHT", checkbox, "RIGHT")
	checkbox.Checkbox:SetPoint("LEFT", checkbox, "LEFT", indent and INDENT * indent or 0, 0)
	checkbox.Text:SetPoint("LEFT", checkbox.Checkbox, "RIGHT", 4, 0)
	checkbox.Text:SetText(name)
	checkbox.setting = setting
	checkbox.Checkbox:SetChecked(ActionCamPlusDB[setting])

	checkbox:SetScript("OnShow", ActionCamPlusConfig_OnShow)
	checkbox.Checkbox:SetScript("OnClick", function(self, button, down)
		ActionCamPlusDB[checkbox.setting] = not ActionCamPlusDB[checkbox.setting]
		checkbox:SetValue(ActionCamPlusDB[checkbox.setting])
		ACP.CheckAllSettings()
		ACP.UpdateDependencies(checkbox)
	end)

	function checkbox.UpdateValue(self)
		self.Checkbox:SetChecked(ActionCamPlusDB[self.setting])
	end

	function checkbox.Disable(self)
		self.Checkbox:Disable()
		self.Text:SetFontObject("GameFontDisable")
		self.enabled = false
	end

	function checkbox.Enable(self)
		self.Checkbox:Enable()
		self.Text:SetFontObject("GameFontNormal")
		self.enabled = true
	end

	checkbox.Tooltip.tooltipText = tooltip

	if depenency and depenency.children then tinsert(depenency.children, checkbox) end
	checkbox.children = {}
	checkbox.blacklist = {}

	options[setting] = checkbox
	return checkbox
end

function ActionCamPlusOptionsFrame.CreateSlider(self, name, setting, parent, dependency, tooltip, settings)
	local op = Settings.CreateSliderOptions(settings.min, settings.max, settings.step)
	op:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value end)
	op:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Top, name);

	local frameName = "$parent"..setting.."SliderContainer"
	local sliderContainer = CreateFrame("Frame", frameName, parent)
	sliderContainer:SetSize(CONTENT_WIDTH / 2 - COLUMN_GAP, 50)

	sliderContainer.slider = CreateFrame("Frame", nil, sliderContainer, "MinimalSliderWithSteppersTemplate")
	sliderContainer.slider:SetPoint("BOTTOMLEFT")
	sliderContainer.slider:SetWidth(sliderContainer:GetWidth() - 30)
	sliderContainer.slider:Init(ACP.roundToNearest(ActionCamPlusDB[setting], settings.step), op.minValue, op.maxValue, op.steps, op.formatters)
	sliderContainer.slider:RegisterCallback("OnValueChanged",
		function(self, value)
			if ActionCamPlusDB[setting] ~= value then
				if settings.cvar then
					local cvars = settings.cvar
					if type(settings.cvar) ~= "table" then cvars = {cvars} end
					for _,cvar in pairs(cvars) do
						SetCVar(cvar, tostring(value), "ACP")
					end
				end

				ActionCamPlusDB[setting] = value
				ACP.CheckAllSettings()
			end
		end, sliderContainer.slider)

	sliderContainer.slider.TopText:ClearAllPoints()
	sliderContainer.slider.TopText:SetPoint("BOTTOM", sliderContainer.slider.Slider, "TOP", 0, -4)

	sliderContainer.slider:SetScript("OnMouseWheel", function(self, delta)
		self.Slider:SetValue(self.Slider:GetValue() + delta * settings.step)
	end)

	function sliderContainer.UpdateValue(self) self.slider.Slider:SetValue(ActionCamPlusDB[setting]) end
	function sliderContainer.Enable(self) self:Toggle(true) end
	function sliderContainer.Disable(self) self:Toggle(false) end
	function sliderContainer.Toggle(self, value)
		for _,k in pairs({self.slider.Slider, self.slider.Back, self.slider.Forward}) do
			k:EnableMouse(value)
		end
		local font = value and "GameFontNormal" or "GameFontDisable"
		self.slider.TopText:SetFontObject(font)
		self.slider.RightText:SetFontObject(font)
		self.enabled = value
	end

	sliderContainer.slider.RightText.oldSetText = sliderContainer.slider.RightText.SetText
	sliderContainer.slider.RightText.SetText = function(self, value)
		self:oldSetText(ACP.roundToNearest(value, settings.step))
	end
	sliderContainer.slider.RightText:ClearAllPoints()
	sliderContainer.slider.RightText:SetPoint("LEFT", sliderContainer.slider.Slider, "RIGHT", 20, 0)

	if tooltip then
		sliderContainer.tooltipOverlay = CreateFrame("Frame", nil, sliderContainer)
		sliderContainer.tooltipOverlay:SetAllPoints()
		sliderContainer.tooltipOverlay:SetPropagateMouseClicks(true)
		sliderContainer.tooltipOverlay:SetPropagateMouseMotion(true)
		sliderContainer.tooltipOverlay:SetFrameLevel(100)

		sliderContainer.tooltipOverlay.tooltipText = tooltip
		ActionCamPlusOptionsFrame:SetOptionTooltip(sliderContainer.tooltipOverlay, -10, -20)
	end

	options[setting] = sliderContainer
	if dependency and dependency.children then tinsert(dependency.children, sliderContainer) end
	return sliderContainer
end

function ActionCamPlusOptionsFrame.CreateHeader(self, name, parent, dependency, setWhite)
	local header = CreateFrame("Frame", "$parent"..gsub(name, ' ', '').."Header", parent)
	header:SetSize(CONTENT_WIDTH / 2 - COLUMN_GAP, 30)
	header.text = header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	if setWhite then header.text:SetTextColor(1,1,1) end
	header.text:SetPoint("BOTTOMLEFT"); header.text:SetPoint("BOTTOMRIGHT");
	header.text:SetText(name)
	header.text:SetJustifyH("LEFT")
	local Path, Size, Flags = header.text:GetFont()
	header.text:SetFont(Path,18,Flags)
	header.Enable = function(self) self:Toggle(true) end
	header.Disable = function(self) self:Toggle(false) end
	header.Toggle = function(self, value)
		local font = value and "GameFontNormal" or "GameFontDisable"
		self.text:SetFontObject(font)
		self.enabled = value
	end

	if dependency and dependency.children then
		tinsert(dependency.children, header)
	end
	options[name] = header
	return header
end

function ActionCamPlusOptionsFrame.CreateDropdown(self, name, setting, parent, dependency, tooltip, customSetSelected)
	local dropdownContainer = CreateFrame("Frame", "$parent"..name.."DropdownContainer", parent)
	dropdownContainer:SetSize(CONTENT_WIDTH / 2 - COLUMN_GAP, 48)

	dropdownContainer.label = dropdownContainer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	dropdownContainer.label:SetPoint("TOP", dropdownContainer, "TOP")
	dropdownContainer.label:SetText(name)

	local dropdown = CreateFrame("DropdownButton", "Dropdown", dropdownContainer, "WowStyle1DropdownTemplate")
	dropdown.setting = ActionCamPlusDB[setting]
	dropdown:SetWidth(dropdownContainer:GetWidth() * .8)
	dropdownContainer.dropdown = dropdown

	local function IsSelected(value)
		return ActionCamPlusDB[setting] == value
	end

	local function SetSelected(value)
		ActionCamPlusDB[setting] = value
	end

	dropdown:SetupMenu(function(dropdown, rootDescription)
		for i,option in pairs(ACP.transitionFunctions) do
			local radioDescription = rootDescription:CreateRadio(option.name, IsSelected, customSetSelected or SetSelected, i);
		end
	end)
	dropdown:SetPoint("BOTTOM", dropdownContainer, "BOTTOM", 0, 4)

	function dropdownContainer.Disable(self) dropdown:Disable() self:Toggle(false) end
	function dropdownContainer.Enable(self) dropdown:Enable() self:Toggle(true) end
	function dropdownContainer.Toggle(self, value)
		local font = value and "GameFontNormal" or "GameFontDisable"
		self.label:SetFontObject(font)
	end

	if tooltip then
		dropdownContainer.tooltipOverlay = CreateFrame("Frame", nil, dropdownContainer)
		dropdownContainer.tooltipOverlay:SetAllPoints()
		dropdownContainer.tooltipOverlay:SetPropagateMouseClicks(true)
		dropdownContainer.tooltipOverlay:SetPropagateMouseMotion(true)
		dropdownContainer.tooltipOverlay:SetFrameLevel(100)

		dropdownContainer.tooltipOverlay.tooltipText = tooltip
		ActionCamPlusOptionsFrame:SetOptionTooltip(dropdownContainer.tooltipOverlay, -10, -20)
	end

	if dependency and dependency.children then tinsert(dependency.children, dropdownContainer) end
	return dropdownContainer
end

function ActionCamPlusOptionsFrame.SetOptionTooltip(self, option, x, y)
	option:SetScript("OnEnter", function()
		GameTooltip:SetOwner(option, "ANCHOR_RIGHT", x, y)
		GameTooltip:SetText(option.tooltipText, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	option:SetScript("OnLeave", function()
		GameTooltip:Hide()
		GameTooltip:ClearLines()
	end)
end

-----------------------------------------------
-----------------------------------------------
-----------------------------------------------
function ACP.AddOptions()
	local optionScale = .9
	local TAB1_OPTION_SPACING = 6

	local HORIZONTAL_OFFSET_TOOLTIP = "所謂的「動作鏡頭」效果。越肩視角。"
	local FOCUS_ENEMIES_TOOLTIP = "調整鏡頭角度以鎖定並保持目標敵人在畫面中。"
	local FOCUS_INTERACT_TOOLTIP = "調整鏡頭角度以保持有對話視窗的 NPC 在畫面中。"
	local PITCH_TOOLTIP = "根據縮放距離增加鏡頭的垂直角度。拉遠時效果更顯著。"
	local AUTO_ZOOM_TOOLTIP = "切換到此狀態時自動將鏡頭縮放到設定距離。"
	local AUTO_SET_CAMERA_TOOLTIP = "離開此狀態時記住手動設定的鏡頭距離，以便再次啟用時恢復。"
	local FOCUS_STRENGTH_TOOLTIP = "鏡頭鎖定聚焦敵人或 NPC 對話目標的強度。"

	-- Tab Setup
	if ACP.useClassicUI then
		-- Classic client doesn't have the dungeon journal tabs that I like so we fall back to these
		ActionCamPlusOptionsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		tabSystem = CreateFrame("Frame", "$parentTabSystem", ActionCamPlusOptionsFrame)
		tabSystem.tabs = {}
		tabSystem.AddTab = function(self, name)
			-- this template has an OnLoad baked into the xml -___- wtf blizzard
			-- Because I don't want to create my own xml just to init this frame we have to temporarily disable this function
			-- that is called during the OnLoad so that it doesn't error out due to missing properties that I didn't even get
			-- a chance to initialize
			local tempFuncBackup = PanelTemplates_TabResize
			PanelTemplates_TabResize = function() end
			local tab = CreateFrame("Button", "$parentTab" .. #self.tabs + 1, ActionCamPlusOptionsFrame, "TabButtonTemplate")
			PanelTemplates_TabResize = tempFuncBackup
			tab.index = #self.tabs + 1
			tab:SetScale(1.2)

			tab:SetText(name)
			_G[tab:GetName().."Text"]:SetPoint("BOTTOM", tab, "BOTTOM", 0, 2)
			tab:SetScript("OnLoad", nil); tab:SetScript("OnShow", nil);
			tab:SetScript("OnClick", function(self, _)
				tabSystem:SetTab(self.index)
			end)

			self.tabs[tab.index] = tab
			PanelTemplates_SetNumTabs(self, tab.index)
			self:UpdateTabs()
			TEST = tab
			return tab.index
		end
		tabSystem.SetTab = function(self, index)
			for _,t in pairs(tabSystem.tabs) do
				if t.index == index then
					PanelTemplates_SelectTab(t)
					t.content:Show()
					tabSystem.selectedTab = index
				else
					PanelTemplates_DeselectTab(t)
					t.content:Hide()
				end
			end
		end
		tabSystem.UpdateTabs = function(self)
			for i,t in pairs(self.tabs) do
				t:ClearAllPoints()
				if t.index == 1 then t:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 10, 0)
				else t:SetPoint("BOTTOMLEFT", self.tabs[t.index - 1], "BOTTOMRIGHT", 5, 0)
				end
				PanelTemplates_TabResize(t, nil, ((self:GetWidth() - 20) / #self.tabs - (5 * (#self.tabs - 1))) / t:GetScale())
			end
		end
	else
		tabSystem = CreateFrame("Frame", "$parentTabSystem", ActionCamPlusOptionsFrame, "TabSystemTemplate")
		tabSystem.tabTemplate = "SpellBookCategoryTabTemplate"
		tabSystem.maxTabWidth = CONTENT_WIDTH / 2
		tabSystem.minTabWidth = CONTENT_WIDTH / 2 - 10
		tabSystem:SetSize(CONTENT_WIDTH, 40)
		tabSystem:SetPoint("TOP", 0, -WINDOW_PADDING - 4)
		tabSystem:OnLoad()
		tabSystem:SetTabSelectedCallback(function(tabID, isUserAction)
			for t in tabSystem.tabPool:EnumerateActive() do
				if t:GetTabID() == tabID then t.content:Show()
				else t.content:Hide() end
			end
		end)
	end

	tabSystem:SetSize(CONTENT_WIDTH, 40)
	tabSystem:SetPoint("TOP", 0, -WINDOW_PADDING - 4)

	local generalTab = ActionCamPlusOptionsFrame:CreateTab("一般")
	local situationalTab = ActionCamPlusOptionsFrame:CreateTab("情境")
	ActionCamPlusOptionsFrame.tabSystem = tabSystem
	tabSystem:SetTab(1)

	-- options background texture
	for i,k in pairs({"Left", "Right"}) do
		ActionCamPlusOptionsFrame[k] = ActionCamPlusOptionsFrame:CreateTexture(nil, "OVERLAY", nil, 2)
		ActionCamPlusOptionsFrame[k]:SetAtlas("Options_InnerFrame", true)
		ActionCamPlusOptionsFrame[k]:SetTexCoord(i == 1 and 1 or .5, i == 1 and .5 or 1 ,0,1)
		ActionCamPlusOptionsFrame[k]:SetSize((WINDOW_WIDTH - WINDOW_PADDING) / 2, WINDOW_HEIGHT - WINDOW_PADDING * 2 - TAB_SELECT_HEIGHT)
		ActionCamPlusOptionsFrame[k]:SetPoint(i == 1 and "TOPRIGHT" or "TOPLEFT", tabSystem, "BOTTOM")
	end

	-- TAB 1
	local addonEnabled = ActionCamPlusOptionsFrame:CreateCheckbox("啟用插件", "ACP_AddonEnabled", generalTab, nil, "切換動感鏡頭 Plus 功能")
	addonEnabled:SetPoint("TOPLEFT")

	local tab1Options = {}

	local zoomHeader = ActionCamPlusOptionsFrame:CreateHeader("縮放", generalTab, addonEnabled)
	tinsert(tab1Options, zoomHeader)
	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("手動滾動速度", "defaultZoomSpeed", generalTab, addonEnabled,
		"手動滾動時的縮放速度。", { min = 1, max = 50, step = 1, cvar = "cameraZoomSpeed"}))

	local swappableSliders = CreateFrame("Frame", "SwappableSliders", generalTab)
	swappableSliders:SetSize(CONTENT_WIDTH / 2, 70)
	local transitionSpeed = ActionCamPlusOptionsFrame:CreateSlider("", "transitionSpeed", swappableSliders, addonEnabled,
		"狀態切換時的縮放速度。", { min = 1, max = 20, step = .5})
	transitionSpeed:SetPoint("BOTTOM")
	local transitionTime = ActionCamPlusOptionsFrame:CreateSlider("", "transitionTime", swappableSliders, addonEnabled,
		"狀態切換所需的變換時間。", { min = 1, max = 10, step = .25})
	transitionTime:SetPoint("BOTTOM")

	local transitionToggle = CreateFrame("Button", nil, swappableSliders, "UIPanelButtonTemplate")
	transitionToggle:SetText("變換"..(ActionCamPlusDB.transitionUsingSpeed and "速度" or "時間"))
	transitionToggle:SetSize(160, 30)
	transitionToggle:SetPoint("TOP", -14, 0)
	transitionToggle:SetScript("OnClick", function()
		ActionCamPlusDB.transitionUsingSpeed = not ActionCamPlusDB.transitionUsingSpeed
		if ActionCamPlusDB.transitionUsingSpeed then
			transitionToggle:SetText("變換速度")
			transitionSpeed:Show(); transitionTime:Hide();
		else
			transitionToggle:SetText("變換時間")
			transitionSpeed:Hide(); transitionTime:Show();
		end
	end)
	if ActionCamPlusDB.transitionUsingSpeed then transitionTime:Hide() else transitionSpeed:Hide() end
	tinsert(addonEnabled.children, transitionToggle)

	tinsert(tab1Options, swappableSliders)

	local function dropdownSelect(value)
		ActionCamPlusDB.transitionFunction = value
		local c = ACP.transitionFunctions[value].coefficients
		if not c then return end
		ACP.x1, ACP.y1, ACP.x2, ACP.y2 = c[1], c[2], c[3], c[4]
		ACP.C1 = 3*(1 - 3*ACP.x2 + 3*ACP.x1)
		ACP.C2 = 2*(3*ACP.x2 - 6*ACP.x1)
		ACP.C3 = 3*ACP.x1

		if ACP.transitionFunctions[value].func == "ease" and not ACP.transitionFunctions[value].dropTable then
			local dropTable = {}
			for t = 0, 100 do
				dropTable[cbSystemEquation(t/1000, ACP.x1, ACP.x2)] = t/1000
			end
			ACP.transitionFunctions[value].dropTable = {}
		end
	end

	local transitionStyleDropdown = ActionCamPlusOptionsFrame:CreateDropdown("變換樣式", "transitionFunction", generalTab, addonEnabled,
		"用於計算變換曲線的函數，包含縮放和偏移。", dropdownSelect)
	dropdownSelect(ActionCamPlusDB.transitionFunction)
	tinsert(tab1Options, transitionStyleDropdown)


	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateHeader("動作鏡頭", generalTab, addonEnabled))
	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("水平偏移", "horizontalOffset", generalTab, addonEnabled,
		"越肩鏡頭偏移的幅度。", { min = .5, max = 5, step = .5 }))

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("偏移時間", "horizontalOffsetTime", generalTab, addonEnabled,
		"偏移變換應持續多久。", { min = .25, max = 5, step = .25 }))

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateCheckbox("與縮放同步", "syncHorizontalOffsetTime", generalTab, addonEnabled,
		"同步縮放和偏移變換，使它們同時完成。"))


	for i,op in pairs(tab1Options) do
		op:SetPoint("TOPLEFT", i == 1 and addonEnabled or tab1Options[i-1], "BOTTOMLEFT", 0, -TAB1_OPTION_SPACING)
	end

	-- TAB 1 Col 2
	tab1Options = {}

	-- focus
	local focusHeader = ActionCamPlusOptionsFrame:CreateHeader("聚焦", generalTab, addonEnabled)
	focusHeader:ClearAllPoints()
	focusHeader:SetPoint("TOPRIGHT", generalTab, "TOPRIGHT", 0, -addonEnabled:GetHeight() - OPTION_SPACING)

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("水平聚焦強度", "focusStrengthHorizontal", generalTab, addonEnabled,
		FOCUS_STRENGTH_TOOLTIP, { min = 0, max = 1, step = .05, cvar = {"test_cameraTargetFocusEnemyStrengthYaw", "test_cameraTargetFocusInteractStrengthYaw"} }))

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("垂直聚焦強度", "focusStrengthVertical", generalTab, addonEnabled,
		FOCUS_STRENGTH_TOOLTIP, { min = 0, max = 1, step = .05, cvar = {"test_cameraTargetFocusEnemyStrengthPitch", "test_cameraTargetFocusInteractStrengthPitch"} }))

	-- pitch
	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateHeader("俯仰", generalTab, addonEnabled))

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("垂直強度", "pitchStrength", generalTab, addonEnabled,
		"俯仰選項的強度。數值越低效果越強。暴雪說明：「保持腳部在螢幕高度比例以下」",
		{ min = 0, max = 1, step = .05, cvar = "test_cameraDynamicPitchBaseFovPad" }))

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("向下強度", "pitchDownStrength", generalTab, addonEnabled,
		"當你向下看時減少多少俯仰角。", { min = 0, max = 1, step = .05, cvar = "test_cameraDynamicPitchBaseFovPadDownScale" }))

	tinsert(tab1Options, ActionCamPlusOptionsFrame:CreateSlider("飛行俯仰強度", "pitchFlightStrength", generalTab, addonEnabled,
		"飛行時的整體強度。", { min = 0, max = 1, step = .05, cvar = "test_cameraDynamicPitchBaseFovPadFlying" }))

	for i,op in pairs(tab1Options) do
		op:SetPoint("TOPRIGHT", i == 1 and focusHeader or tab1Options[i-1], "BOTTOMRIGHT", 0, -TAB1_OPTION_SPACING)
	end

	-- TAB 2 
	local massSetup = function(optionsData, headOption)
		for i, option in pairs(optionsData) do
			local op = ActionCamPlusOptionsFrame[option.optionType or "CreateCheckbox"](ActionCamPlusOptionsFrame, option.name, option.setting, headOption,
				option.dependency or addonEnabled,
				option.tooltip, option.settings and option.settings or 1)
			local anchorFrame = i == 1 and headOption or optionsData[i-1].frame
			op:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -OPTION_SPACING)
			option.frame = op
		end
	end

	-- On foot
	local onFootHeader = ActionCamPlusOptionsFrame:CreateHeader("步行", situationalTab, addonEnabled, false)
	onFootHeader.text:SetFontObject("GameFontNormal")
	onFootHeader.text:ClearAllPoints()
	onFootHeader.text:SetAllPoints()
	onFootHeader:SetHeight(26)
	onFootHeader:SetPoint("TOPLEFT")
	onFootHeader:SetScale(optionScale)

	tinsert(addonEnabled.children, onFootHeader)

	local onFootOptions = {
		{name = "水平偏移", setting = "ACP_ActionCam", tooltip = HORIZONTAL_OFFSET_TOOLTIP},
		{name = "切換側邊", setting = "leftShoulder", tooltip = "偏移至角色左肩。"},
		{name = "聚焦敵人", setting = "ACP_Focusing", tooltip = FOCUS_ENEMIES_TOOLTIP},
		{name = "聚焦互動", setting = "ACP_FocusingInteract", tooltip = FOCUS_INTERACT_TOOLTIP},
		{name = "俯仰", setting = "ACP_Pitch", tooltip = PITCH_TOOLTIP},
		{name = "更改鏡頭縮放", setting = "ACP_SetCameraZoom", tooltip = AUTO_ZOOM_TOOLTIP},
		{name = "自動設定鏡頭距離", setting = "ACP_AutoSetCameraDistance", tooltip = AUTO_SET_CAMERA_TOOLTIP},
		{optionType = "CreateSlider", name = "未坐騎鏡頭距離", setting = "unmountedCamDistance", tooltip = nil, dependency = "", settings = {
			min = 1, max = 30, step = .5
		}}
	}

	massSetup(onFootOptions, onFootHeader)
	tinsert(options["ACP_AutoSetCameraDistance"].blacklist, options["unmountedCamDistance"])
	options["leftShoulder"].Checkbox:SetPoint("LEFT", options["leftShoulder"], "LEFT", INDENT * 2, 0)

	-- Combat
	local combatEnabled = ActionCamPlusOptionsFrame:CreateCheckbox("戰鬥", "ACP_Combat", situationalTab, addonEnabled, "啟用以下設定以便在進入戰鬥時啟動。")
	combatEnabled:SetPoint("TOPLEFT", situationalTab, "LEFT")
	combatEnabled:SetScale(optionScale)
	local Path, Size, Flags = combatEnabled.Text:GetFont()
	combatEnabled.Text:SetFont(Path,18,Flags)

	local combatOptions = {
		{name = "水平偏移", setting = "ACP_CombatActionCam", tooltip = HORIZONTAL_OFFSET_TOOLTIP},
		{name = "聚焦敵人", setting = "ACP_CombatFocusing", tooltip = FOCUS_ENEMIES_TOOLTIP},
		{name = "聚焦互動", setting = "ACP_CombatFocusingInteract", tooltip = FOCUS_INTERACT_TOOLTIP},
		{name = "俯仰", setting = "ACP_CombatPitch", tooltip = PITCH_TOOLTIP},
		{name = "更改鏡頭縮放", setting = "ACP_CombatSetCameraZoom", tooltip = AUTO_ZOOM_TOOLTIP},
		{name = "自動設定鏡頭距離", setting = "ACP_AutoSetCombatCameraDistance", tooltip = AUTO_SET_CAMERA_TOOLTIP},
		{optionType = "CreateSlider", name = "戰鬥鏡頭距離", setting = "combatCamDistance", tooltip = "", dependency = "", settings = {
			min = 1, max = 30, step = .5
		}}
	}

	massSetup(combatOptions, combatEnabled)
	tinsert(options["ACP_AutoSetCombatCameraDistance"].blacklist, options["combatCamDistance"])

	-- Mounted
	local mountedEnabled = ActionCamPlusOptionsFrame:CreateCheckbox("騎乘", "ACP_Mounted", situationalTab, addonEnabled, "啟用以下設定以便在進入戰鬥時啟動。")
	mountedEnabled:SetPoint("TOPRIGHT")
	mountedEnabled:SetScale(optionScale)
	mountedEnabled.Text:SetFont(Path,18,Flags)

	local mountedOptions = {
		{name = "水平偏移", setting = "ACP_MountedActionCam", tooltip = HORIZONTAL_OFFSET_TOOLTIP},
		{name = "聚焦敵人", setting = "ACP_MountedFocusing", tooltip = FOCUS_ENEMIES_TOOLTIP},
		{name = "聚焦互動", setting = "ACP_MountedFocusingInteract", tooltip = FOCUS_INTERACT_TOOLTIP},
		{name = "俯仰", setting = "ACP_MountedPitch", tooltip = PITCH_TOOLTIP},
		{name = "德魯伊形態坐騎", setting = "ACP_DruidFormMounts", tooltip = "將德魯伊旅行形態視為坐騎。"},
		{name = "更改鏡頭縮放", setting = "ACP_MountedSetCameraZoom", tooltip = AUTO_ZOOM_TOOLTIP},
		{name = "坐騎特定縮放", setting = "ACP_MountSpecificZoom", tooltip = "記住每個坐騎不同的縮放等級。"},
		{name = "自動設定鏡頭距離", setting = "ACP_AutoSetMountedCameraDistance", tooltip = AUTO_SET_CAMERA_TOOLTIP},
		{optionType = "CreateSlider", name = "騎乘鏡頭距離", setting = "mountedCamDistance", tooltip = "", dependency = "", settings = {
			min = 1, max = 30, step = .5
		}}
	}

	massSetup(mountedOptions, mountedEnabled)
	tinsert(options["ACP_AutoSetMountedCameraDistance"].blacklist, options["mountedCamDistance"])

	ACP.UpdateDependencies(addonEnabled)
end

function ActionCamPlusOptionsFrame:PLAYER_ENTERING_WORLD(self, isInitialLogin, isReloadingUi)
	ActionCamPlusOptionsFrame.tabSystem:UpdateTabs()
end

function ACP.UpdateConfig()
	local settings = { "ACP_AddonEnabled", "leftShoulder"}
	for _,setting in pairs(settings) do
		options[setting]:UpdateValue()
	end
	ACP.UpdateDependencies(options.ACP_AddonEnabled)
end

function ActionCamPlusConfig_OnShow(self)
	self:SetChecked(ActionCamPlusDB[self.setting])
	ACP.UpdateDependencies(self)
end

function ACP.UpdateDependencies(option)
	if not option.Checkbox then return end
	local checked = option.Checkbox:GetChecked()

	if #option.children > 0 or  #option.blacklist> 0 then
		for _,child in pairs(option.children) do
			if checked then
				child:Enable()
			else
				child:Disable()
			end

			ACP.UpdateDependencies(child)
		end

		for _,b in pairs(option.blacklist) do
			if not checked and option.enabled then b:Enable()
			else b:Disable()
			end

			ACP.UpdateDependencies(b)
		end
	end
end

function ACP.UpdateDB(defaults)
	for k,v in pairs(defaults) do
		if ActionCamPlusDB[k] == nil then
			ActionCamPlusDB[k] = v
		end
	end
	-- ActionCamPlusDB.lastVersion = ACP.version
end

function ACP.truncate(number, decimals)
    return number - (number % (0.1 ^ decimals))
end

function ACP.roundToNearest(value, nearest)
	local base = 1 / nearest
	local rv = value * base
	if rv * 10 % 10 > 5 then return math.ceil(rv) / base
	else return math.floor(rv) / base
	end
end