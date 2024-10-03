local addonName, ACP = ...;
local options = {}
local _
--NOTE: The options in ActionCamPlusDB, the checkbox frames, and the functions in ActionCamPlusConfig_SettingUpdate are reduntantly named to make the code more compact.

-- Positional Variables
local top = -30
local leftMargin = 30
local listIndent = 34
local listItemHeight = -20
local listVertPad = 6
local sectionVertPad = 0
local cameraSliderIndent = -15

-- Draw all the option elements when the options frame loads
function ActionCamPlusConfig_Setup()
	-- OLD DEFAULTS KEEP UNTIL SAFELY DEAD
	-- local defaults = {			
	-- 	lastVersion = version,
	-- 	addonEnabled = true, 
	-- 	focusEnabled = false,
	-- 	mountedCamDistance = 30,
	-- 	unmountedCamDistance = 20,
	-- 	transitionSpeed = 12,
	-- 	defaultZoomSpeed = 50,
	-- 	mountSpecificZoom = false,
	-- 	druidFormMounts = true,
	-- 	mountZooms = {}
	-- }

	local defaults = {			-- Set defaults
		lastVersion = ACP.version,

		ACP_AddonEnabled = true,
		ACP_ActionCam = true,
		ACP_Focusing = false,
		ACP_Pitch = true,
		ACP_SetCameraZoom = true,
		ACP_AutoSetCameraDistance = true,
		unmountedCamDistance = 20,

		ACP_Mounted = true,
		ACP_MountedActionCam = false,
		ACP_MountedFocusing = false,
		ACP_MountedPitch = false,
		ACP_DruidFormMounts = true,
		ACP_MountedSetCameraZoom = true,
		ACP_AutoSetMountedCameraDistance = true,
		ACP_MountSpecificZoom = false,
		mountedCamDistance = 30,

		ACP_Combat = false,
		ACP_CombatActionCam = true,
		ACP_CombatFocusing = true,
		ACP_CombatPitch = true,
		ACP_CombatSetCameraZoom = false,
		ACP_AutoSetCombatCameraDistance = true,
		combatCamDistance = 20,
		
		transitionSpeed = 3,
		defaultZoomSpeed = 40,
		
		mountZooms = {}
	}
	
	if not ActionCamPlusDB then
		ActionCamPlusDB = defaults

	elseif not ActionCamPlusDB.lastVersion or ActionCamPlusDB.lastVersion ~= ACP.version then 
		ACP.UpdateDB(defaults)
	end

	----------------------
	-- Parent Frame
	----------------------
	ActionCamPlusOptionsFrame = CreateFrame("Frame", "ActionCamPlusOptionsFrame", UIParent, "BackdropTemplate")
	ActionCamPlusOptionsFrame:SetToplevel(true)
	ActionCamPlusOptionsFrame:SetFrameStrata("HIGH")
	ActionCamPlusOptionsFrame:EnableMouse(true)
	ActionCamPlusOptionsFrame:SetMovable(true)
	
	tinsert(UISpecialFrames, ActionCamPlusOptionsFrame:GetName())
	ActionCamPlusOptionsFrame:RegisterForDrag("LeftButton")

	local backdropInfo =
		{
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true,
			tileEdge = true,
			tileSize = 32,
			edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 },
		}

	ActionCamPlusOptionsFrame:SetBackdrop(backdropInfo)

	ActionCamPlusOptionsFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	ActionCamPlusOptionsFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
	ActionCamPlusOptionsFrame:SetPoint("CENTER", UIParent)
	ActionCamPlusOptionsFrame:SetSize(540, 580)

	local titlebox = ActionCamPlusOptionsFrame:CreateTexture("titlebox", "ARTWORK")
	titlebox:SetSize(360, 64)
	titlebox:SetPoint("TOP", 0, 12)
	titlebox:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")

	local titletext = ActionCamPlusOptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	titletext:SetPoint("TOP", titletext:GetParent(), 0, -1.5)
	titletext:SetText("ActionCamPlus Options")

	local closebutton = CreateFrame("Button", "$parentButtonClose", ActionCamPlusOptionsFrame, "UIPanelButtonTemplate")
	closebutton:SetText("Close")
	closebutton:SetSize(80, 20)
	closebutton:SetPoint("BOTTOM", 0, 20)
	closebutton:SetScript("OnClick", function() ActionCamPlusOptionsFrame:Hide() end)

	----------------------
	---------------
	----------------------

	-- For reference:  ACP.createCheckButton(name, parent, anchor, offX, offY, label, tooltip, framepoint="TOPLEFT", anchorpoint="BOTTOMLEFT")

	-- Addon Enabled
	options.ACP_AddonEnabled = ACP.createCheckButton("AddonEnabled", ActionCamPlusOptionsFrame, ActionCamPlusOptionsFrame, leftMargin, top,
						"Addon Enabled",
						"Toggles ActionCamPlus functionality.",
						"TOPLEFT", "TOPLEFT")
	-- On Foot Options
				-- Action Cam
				options.ACP_ActionCam = ACP.createCheckButton("ActionCam", ACP_AddonEnabled, ACP_AddonEnabled, listIndent, 5,
									"Action Cam",
									"Enable Action Cam while on foot.")

				-- Focusing
				options.ACP_Focusing = ACP.createCheckButton("Focusing", ACP_AddonEnabled, ACP_ActionCam, 0,  listVertPad,
									"Focusing",
									"Target Focusing enabled while on foot.")

				-- Pitch
				options.ACP_Pitch = ACP.createCheckButton("Pitch", ACP_AddonEnabled, ACP_Focusing, 0,  listVertPad,
									"Pitch",
									"Camera pitch enabled while on foot.")

				-- Set Camera Zoom
				options.ACP_SetCameraZoom = ACP.createCheckButton("SetCameraZoom", ACP_AddonEnabled, ACP_Pitch, 0,  listVertPad,
									"Change Camera Zoom",
									"ActionCamPlus will change your camera distance to your unmounted or out of combat setting.")

				-- Auto Set Camera Distance
				options.ACP_AutoSetCameraDistance = ACP.createCheckButton("AutoSetCameraDistance", ACP_SetCameraZoom, ACP_SetCameraZoom, 0,  listVertPad,
									"Auto Set Camera Distance",
									"ActionCamPlus will automatically set your default camera distance to wherever you scroll.")

				options.ACP_UnmountedZoomDistance = ACP.createCameraSlider("UnmountedZoomDistance", ACP_AutoSetCameraDistance, "unmountedCamDistance", 1, 39, "Unmounted Camera Distance", ACP_AutoSetCameraDistance, "TOPLEFT", "BOTTOMLEFT", 0, cameraSliderIndent)

	-- Mounted Header
	options.ACP_Mounted = ACP.createCheckButton("Mounted", ACP_AddonEnabled, ActionCamPlusOptionsFrame, leftMargin-10, top,
						"Mounted",
						"Enables ActionCamPlus behavior while mounted.", 
						"TOPLEFT", "TOP")
	-- Mounted Options
				-- Action Cam
				options.ACP_MountedActionCam = ACP.createCheckButton("MountedActionCam", ACP_Mounted, ACP_Mounted, listIndent,  5,
									"Action Cam",
									"Enable Action Cam while mounted.")

				-- Focusing
				options.ACP_MountedFocusing = ACP.createCheckButton("MountedFocusing", ACP_Mounted, ACP_MountedActionCam, 0,  listVertPad,
									"Focusing",
									"Target Focusing enabled while mounted.")

				-- Pitch
				options.ACP_MountedPitch = ACP.createCheckButton("MountedPitch", ACP_Mounted, ACP_MountedFocusing, 0,  listVertPad,
									"Pitch",
									"Camera pitch enabled while mounted.")

				-- Druid Form Mounts
				options.ACP_DruidFormMounts = ACP.createCheckButton("DruidFormMounts", ACP_Mounted, ACP_MountedPitch, 0,  listVertPad,
									"Druid Form Mounts",
									"Druids' travel forms will be treated as mounts.")

				-- Set Camera Zoom
				options.ACP_MountedSetCameraZoom = ACP.createCheckButton("MountedSetCameraZoom", ACP_Mounted, ACP_DruidFormMounts, 0,  listVertPad,
									"Change Camera Zoom",
									"When you mount, ActionCamPlus will set the camera distance to your mounted setting.")

				-- Auto Set Camera Distance
				options.ACP_AutoSetMountedCameraDistance = ACP.createCheckButton("AutoSetMountedCameraDistance", ACP_MountedSetCameraZoom, ACP_MountedSetCameraZoom, 0,  listVertPad,
									"Auto Set Camera Distance",
									"While mounted, ActionCamPlus will set your mounted camera distance to wherever you scroll.")

				-- Mount Specific Zoom
				options.ACP_MountSpecificZoom = ACP.createCheckButton("MountSpecificZoom", ACP_MountedSetCameraZoom, ACP_AutoSetMountedCameraDistance, 0,  listVertPad,
									"Mount-Specific Zoom",
									"ActionCamPlus will remember a zoom level for each mount.")

				options.ACP_MountedZoomDistance = ACP.createCameraSlider("MountedZoomDistance", ACP_AutoSetMountedCameraDistance, "mountedCamDistance", 1, 39, "Mounted Camera Distance", ACP_MountSpecificZoom, "TOPLEFT", "BOTTOMLEFT", 0, cameraSliderIndent)

	-- Combat Header
	options.ACP_Combat = ACP.createCheckButton("Combat", ACP_AddonEnabled, ActionCamPlusOptionsFrame, leftMargin, 0,
						"Combat",
						"Enables ActionCamPlus behavior while in combat.",
						"TOPLEFT", "LEFT")
	-- Combat Options
				-- Action Cam
				options.ACP_CombatActionCam = ACP.createCheckButton("CombatActionCam", ACP_Combat, ACP_Combat, listIndent,  5,
									"Action Cam",
									"Enable Action Cam while in combat.")

				-- Focusing
				options.ACP_CombatFocusing = ACP.createCheckButton("CombatFocusing", ACP_Combat, ACP_CombatActionCam, 0,  listVertPad,
									"Focusing",
									"Target Focusing enabled while in combat.")

				-- Pitch
				options.ACP_CombatPitch = ACP.createCheckButton("CombatPitch", ACP_Combat, ACP_CombatFocusing, 0,  listVertPad,
									"Pitch",
									"Camera pitch enabled while in combat.")

				-- Set Camera Zoom
				options.ACP_CombatSetCameraZoom = ACP.createCheckButton("CombatSetCameraZoom", ACP_Combat, ACP_CombatPitch, 0,  listVertPad,
									"Change Camera Zoom",
									"When you enter combat, ActionCamPlus will set the camera distance to your combat setting.")

				-- Auto Set Camera Distance
				options.ACP_AutoSetCombatCameraDistance = ACP.createCheckButton("AutoSetCombatCameraDistance", ACP_CombatSetCameraZoom, ACP_CombatSetCameraZoom, 0,  listVertPad,
									"Auto Set Camera Distance",
									"While in combat, ActionCamPlus will set your combat setting to wherever you scroll.")

				options.ACP_CombatZoomDistance = ACP.createCameraSlider("CombatZoomDistance", ACP_AutoSetCombatCameraDistance, "combatCamDistance", 1, 39, "Combat Camera Distance", ACP_AutoSetCombatCameraDistance, "TOPLEFT", "BOTTOMLEFT", 0, cameraSliderIndent)

	-- Zoom Options
	options.ACP_transitionSpeed = ACP.createSlider("transitionSpeed", ActionCamPlusOptionsFrame, "transitionSpeed", 1, 40, "Transition Speed", ActionCamPlusOptionsFrame, "TOPRIGHT", "RIGHT", -leftMargin-20, top-50)
	options.ACP_defaultZoomSpeed = ACP.createSlider("defaultZoomSpeed", ActionCamPlusOptionsFrame, "defaultZoomSpeed", 1, 40, "Scoll Zoom Speed", ACP_transitionSpeed, "TOP", "BOTTOM", 0, -50)
	options.ACP_defaultZoomSpeed:HookScript("OnValueChanged", function(self, v) SetCVar("cameraZoomSpeed", floor(v + .5)) end)
end

function ACP.UpdateDB(defaults)
	for k,v in pairs(defaults) do
		-- print(k, ActionCamPlusDB[k], v)
		if not ActionCamPlusDB[k] then 
			ActionCamPlusDB[k] = v
		end
	end
	ActionCamPlusDB.lastVersion = ACP.version
end

-- recursive function to grey-out options that aren't doing anything
function ACP.UpdateDependencies(option)
	local children = {option:GetChildren()}

	if #children > 0 and not option.editbox then
		for _,child in pairs(children) do
			if child.editbox then
				if option:GetChecked() or option:IsSoftDisabled() then
					child:SoftDisable()
				else
					child:SoftEnable()
				end
			else
				if not option:GetChecked() or option:IsSoftDisabled() then
					child:SoftDisable()
				else
					child:SoftEnable()
				end
			end

			ACP.UpdateDependencies(child)
		end
	end
end

-- Function to change a setting
function ACP.SettingUpdate(setting, settingtype)
	if settingtype == "checkbutton" then 
		if setting:GetChecked() then
			ActionCamPlusDB[setting:GetName()] = true
		else
			ActionCamPlusDB[setting:GetName()] = false
		end
	end
end

-- Option UI element creation functions
function ACP.createCheckButton(name, parent, anchor, offX, offY, label, tooltip, framepoint, anchorpoint)
	framepoint = framepoint or "TOPLEFT"
	anchorpoint = anchorpoint or "BOTTOMLEFT"

	local checkButton = CreateFrame("CheckButton", "ACP_"..name, parent, "UICheckButtonTemplate")
	checkButton:SetPoint(framepoint, anchor, anchorpoint, offX, offY)
	checkButton:SetScript("OnClick", ActionCamPlusConfig_OnClick)
	checkButton:SetScript("OnShow", ActionCamPlusConfig_OnShow)

	checkButton:GetCheckedTexture():Show()
	checkButton:GetCheckedTexture():Hide()
	checkButton:SetChecked(true)
	checkButton.SoftDisableCheckedTexture = checkButton:CreateTexture("SoftDisableCheckedTexture", "OVERLAY")
	checkButton.SoftDisableCheckedTexture:SetTexture(checkButton:GetDisabledCheckedTexture():GetTexture())
	checkButton.SoftDisableCheckedTexture:SetAllPoints(checkButton)
	checkButton.SoftDisableCheckedTexture:Hide()

	checkButton.SoftDisable = function() ACP.SoftToggle(checkButton) end
	checkButton.SoftEnable = function() ACP.SoftToggle(checkButton, true) end
	checkButton.SoftDisabled = false
	checkButton.IsSoftDisabled = function() return checkButton.SoftDisabled end

	getglobal(checkButton:GetName() .. 'Text'):SetText(label)
	ACP.setOptionTooltip(checkButton, tooltip)

	return checkButton
end

function ActionCamPlusConfig_OnClick(self, mousebutton, down) 
	ACP.SettingUpdate(self, "checkbutton")

	if self:GetChecked() and self:IsSoftDisabled() then
		self.SoftDisableCheckedTexture:Show()
	else
		self.SoftDisableCheckedTexture:Hide()
	end

	ACP.SetActionCam()
	ACP.UpdateDependencies(self)
end

-- Make Sure all the settings are set when we open config
function ActionCamPlusConfig_OnShow(self)
	self:SetChecked(ActionCamPlusDB[self:GetName()])
	ACP.UpdateDependencies(self)
end

function ACP.SoftToggle(button, enable)
	text = getglobal(button:GetName().."Text")
	if enable then
		button.SoftDisableCheckedTexture:Hide()
		text:SetFontObject("GameFontNormal")
		button.SoftDisabled = false	
	else
		if button:GetChecked() then
			button.SoftDisableCheckedTexture:Show()

		end
		text:SetFontObject("GameFontDisable")
		button.SoftDisabled = true
	end
end

function ACP.setOptionTooltip(option, text)
	option:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(option, "ANCHOR_TOPLEFT")
		GameTooltip:SetText(text, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	option:SetScript("OnLeave", function()
		GameTooltip:Hide()
		GameTooltip:ClearLines()
	end)
end

-- hides the tooltip when we're done
function ActionCamPlusConfig_HideTooltip()
	GameTooltip:Hide()
	GameTooltip:ClearLines()
end

function ACP.createCameraSlider(name, parent, value, min, max, label, anchor, framepoint, anchorpoint, offX, offY)
	framepoint = framepoint or "TOPLEFT"
	anchorpoint = anchorpoint or "BOTTOMLEFT"

	local slider = CreateFrame("Slider", "ACP_"..name, parent, "OptionsSliderTemplate")
	local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
	slider.dbValue = value
	slider:SetMinMaxValues(min, max)

	if tonumber(ActionCamPlusDB[value]) > max then ActionCamPlusDB[value] = max end
	slider:SetValue(ActionCamPlusDB[value])
	slider:SetPoint(framepoint, anchor, anchorpoint, offX, offY)

	slider:SetWidth(150)
	slider:SetHeight(20)
	slider:SetOrientation('HORIZONTAL')

	getglobal(slider:GetName() .. 'Low'):SetText(min)
	getglobal(slider:GetName() .. 'High'):SetText(max)
	getglobal(slider:GetName() .. 'Text'):SetText(label)

	slider:SetValueStep(.25) slider:SetStepsPerPage(5)

	editbox:SetSize(30,30)
	editbox:ClearAllPoints()
	editbox:SetPoint("TOP", slider, "BOTTOM", 0, 5)
	editbox:SetText(slider:GetValue())
	editbox:SetAutoFocus(false)

	slider:SetScript("OnValueChanged", function(self, v)
		v = floor(v*2 + .4)/2
		ActionCamPlusDB[self.dbValue] = v
		self.editbox:SetText(v)
		ACP.testCameraDistance(v)
	end)
	editbox:SetScript("OnTextChanged", function(self)
		local val = self:GetText()
		if tonumber(val) then
			self:GetParent():SetValue(val)
		end
	end)
	editbox:SetScript("OnEnterPressed", function(self)
		local val = self:GetText()
		if tonumber(val) then
			self:GetParent():SetValue(val)
			self:ClearFocus()
		end
	end)

	slider.SoftDisable = function(self) 
		ACP.sliderSetEnabled(self, false)
	end
	slider.SoftEnable = function(self)
		ACP.sliderSetEnabled(self, true)
	end
	slider.IsSoftDisabled = function(self) return self:IsEnabled() end

	slider:Show()
	slider.editbox = editbox

	return slider
end


function ACP.createSlider(name, parent, value, min, max, label, anchor, framepoint, anchorpoint, offX, offY)
	framepoint = framepoint or "TOPLEFT"
	anchorpoint = anchorpoint or "BOTTOMLEFT"

	local slider = CreateFrame("Slider", "ACP_"..name, parent, "OptionsSliderTemplate")
	local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
	slider.dbValue = value
	slider:SetMinMaxValues(min, max)

	if tonumber(ActionCamPlusDB[value]) > max then ActionCamPlusDB[value] = max end
	slider:SetValue(ActionCamPlusDB[value])
	slider:SetPoint(framepoint, anchor, anchorpoint, offX, offY)

	slider:SetWidth(200)
	slider:SetHeight(20)
	slider:SetOrientation('HORIZONTAL')

	getglobal(slider:GetName() .. 'Low'):SetText(min)
	getglobal(slider:GetName() .. 'High'):SetText(max)
	getglobal(slider:GetName() .. 'Text'):SetText(label)

	slider:SetValueStep(1)
	slider:SetStepsPerPage(5)

	editbox:SetSize(30,30)
	editbox:ClearAllPoints()
	editbox:SetPoint("TOP", slider, "BOTTOM", 0, 5)
	editbox:SetText(slider:GetValue())
	editbox:SetAutoFocus(false)

	slider:SetScript("OnValueChanged", function(self, v)
		v = floor(v + .5)
		ActionCamPlusDB[self.dbValue] = v
		self.editbox:SetText(v)
	end)
	editbox:SetScript("OnTextChanged", function(self)
		local val = self:GetText()
		if tonumber(val) then
			self:GetParent():SetValue(val)
		end
	end)
	editbox:SetScript("OnEnterPressed", function(self)
		local val = self:GetText()
		if tonumber(val) then
			self:GetParent():SetValue(val)
			self:ClearFocus()
		end
	end)

	slider:Show()
	slider.editbox = editbox

	return slider
end

function ACP.sliderSetEnabled(slider, value)
	local color, boxcolor

	if value then
		slider:Enable()
		slider.editbox:Enable()
		namecolor = NORMAL_FONT_COLOR
		boxcolor = WHITE_FONT_COLOR
	else
		slider:Disable()
		slider.editbox:Disable()
		namecolor = GRAY_FONT_COLOR
		boxcolor = GRAY_FONT_COLOR
	end
	
	getglobal(slider:GetName() .. 'Text'):SetTextColor(namecolor.r, namecolor.g, namecolor.b)
	slider.editbox:SetTextColor(boxcolor.r, boxcolor.g, boxcolor.b)
end

local cameraTestThrottle
local cameraTestZoom
function ACP.testCameraDistance(value)
	cameraTestZoom = value
	if cameraTestThrottle then return end

	cameraTestThrottle = C_Timer.NewTicker(.5, function() 
		ACP.SetCameraZoom(cameraTestZoom)
		cameraTestThrottle = nil
	end, 1)
end

function ACP.UpdateZoomOptions()
	local sliders = {options.ACP_UnmountedZoomDistance, options.ACP_MountedZoomDistance, options.ACP_CombatZoomDistance}
	for i = 1, #sliders do
		sliders[i]:SetValue(ActionCamPlusDB[sliders[i].dbValue])
	end
end