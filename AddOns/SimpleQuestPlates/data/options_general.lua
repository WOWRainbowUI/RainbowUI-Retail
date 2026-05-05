--=====================================================================================
-- RGX | Simple Quest Plates! - options_general.lua

-- Author: DonnieDice
-- Description: Global settings tab (addon state, combat, position, scale)
--=====================================================================================

local addonName, SQP = ...
local format = string.format
local generalFontDropdownCount = 0

function SQP:RefreshOptionsPreview(activatePreviewFn)
    if type(activatePreviewFn) == "function" then
        activatePreviewFn()
    end

    if self.previewFrame and type(self.previewFrame.UpdatePreview) == "function" then
        self.previewFrame:UpdatePreview()
    end
end

function SQP:CreateGlobalOptions(content)
    if not self.optionControls then self.optionControls = {} end
    local rgxFonts = _G.RGXFonts

    local function CreateNameplateFontControl(parent, y)
        local defaultSharedSize = 12
        local function CreateBluStyleFontDropdown(anchorParent, defaultFontName)
            generalFontDropdownCount = generalFontDropdownCount + 1

            local holder = CreateFrame("Frame", nil, anchorParent)
            holder:SetSize(220, 28)

            local dropdownName = "SQPGeneralFontDropdown" .. generalFontDropdownCount
            local dropdown = CreateFrame("Frame", dropdownName, holder, "UIDropDownMenuTemplate")
            dropdown:ClearAllPoints()
            dropdown:SetPoint("TOPLEFT", holder, "TOPLEFT", -15, 8)
            dropdown:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 17, -8)
            dropdown:SetScript("OnHide", nil)

            local left = _G[dropdownName .. "Left"]
            local middle = _G[dropdownName .. "Middle"]
            local right = _G[dropdownName .. "Right"]
            if left and middle and right then
                middle:ClearAllPoints()
                right:ClearAllPoints()
                middle:SetPoint("LEFT", left, "RIGHT", 0, 0)
                middle:SetPoint("RIGHT", right, "LEFT", 0, 0)
                right:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", 0, 17)
            end

            local text = _G[dropdownName .. "Text"]
            if text and left and right then
                text:ClearAllPoints()
                text:SetPoint("RIGHT", right, "RIGHT", -43, 2)
                text:SetPoint("LEFT", left, "LEFT", 25, 2)
                text:SetJustifyH("LEFT")
            end

            local currentFontName = rgxFonts:ResolveName(SQPSettings.fontFamily, defaultFontName) or defaultFontName

            local function SetSelected(fontName)
                local resolvedName = rgxFonts:ResolveName(fontName, defaultFontName) or defaultFontName
                local fontPath = rgxFonts:GetPath(resolvedName)
                currentFontName = resolvedName
                SQP:SetSetting("fontFamily", fontPath)
                SQP:SetSetting("killFontFamily", fontPath)
                SQP:SetSetting("lootFontFamily", fontPath)
                SQP:SetSetting("percentFontFamily", fontPath)
                UIDropDownMenu_SetText(dropdown, rgxFonts:GetDropdownFontLabel(resolvedName))
                SQP:RefreshOptionsPreview()
                SQP:RefreshAllNameplates()
            end

            local function AddItems(items, level)
                for _, item in ipairs(items or {}) do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = item.text
                    info.notCheckable = item.notCheckable == true or item.value == nil
                    info.disabled = item.disabled == true

                    if type(item.children) == "table" and #item.children > 0 then
                        info.hasArrow = true
                        info.menuList = item.children
                        info.notCheckable = true
                    elseif item.value ~= nil then
                        info.value = item.value
                        info.checked = (currentFontName == item.value)
                        info.func = function()
                            SetSelected(item.value)
                            CloseDropDownMenus()
                        end
                    end

                    UIDropDownMenu_AddButton(info, level)
                end
            end

            UIDropDownMenu_Initialize(dropdown, function(_, level, menuList)
                level = level or 1
                if level == 1 then
                    currentFontName = rgxFonts:ResolveName(SQPSettings.fontFamily, defaultFontName) or defaultFontName
                    AddItems(rgxFonts:BuildGroupedFontItems({ current = currentFontName, keepShownOnClick = false }), level)
                elseif menuList then
                    AddItems(menuList, level)
                end
            end)

            UIDropDownMenu_SetWidth(dropdown, 176)
            UIDropDownMenu_SetText(dropdown, rgxFonts:GetDropdownFontLabel(currentFontName))

            function holder:Reset()
                SetSelected(defaultFontName)
            end

            return holder
        end

        local fontHeader = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fontHeader:SetPoint("TOPLEFT", 20, y)
        fontHeader:SetText(self.L["|cff58be81Nameplate Text|r"])
        y = y - 14

        if not rgxFonts or type(rgxFonts.CreateFontSettingControl) ~= "function" then
            if DEFAULT_CHAT_FRAME then
                -- DEFAULT_CHAT_FRAME:AddMessage("|cffffaa00[SQP:fonts]|r RGXFonts missing or CreateFontSettingControl unavailable.")
            end
            local missing = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            missing:SetPoint("TOPLEFT", 20, y)
            missing:SetWidth(250)
            missing:SetJustifyH("LEFT")
            missing:SetText(self.L["|cffff5555RGX font dropdown is unavailable.|r"])
            return y - 26
        end

        local fallbackName = type(rgxFonts.GetDefault) == "function" and rgxFonts:GetDefault() or "FrizQuadrata"
        local defaultName =
            (type(rgxFonts.ResolveName) == "function" and rgxFonts:ResolveName(SQPSettings.fontFamily, fallbackName))
            or (type(rgxFonts.FindByPath) == "function" and rgxFonts:FindByPath(SQPSettings.fontFamily))
            or fallbackName

        local familyLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        familyLabel:SetPoint("TOPLEFT", 20, y)
        familyLabel:SetText(self.L["Font"])
        y = y - 14

        local ok, fontControl = pcall(CreateBluStyleFontDropdown, parent, defaultName)

        if not ok or not fontControl then
            if DEFAULT_CHAT_FRAME then
                -- DEFAULT_CHAT_FRAME:AddMessage("|cffffaa00[SQP:fonts]|r Unable to build RGX font dropdown: " .. tostring(fontControl))
            end
            local failed = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            failed:SetPoint("TOPLEFT", 20, y)
            failed:SetWidth(250)
            failed:SetJustifyH("LEFT")
            failed:SetText(self.L["|cffff5555Unable to build RGX font dropdown.|r"])
            if not ok then
                local details = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
                details:SetPoint("TOPLEFT", 20, y - 14)
                details:SetWidth(250)
                details:SetJustifyH("LEFT")
                details:SetText("|cffaaaaaa" .. tostring(fontControl) .. "|r")
                return y - 44
            end
            return y - 26
        end

        fontControl:SetPoint("TOPLEFT", 20, y - 4)
        self.optionControls.rgxGeneralFontDropdown = fontControl

        local familyReset = self:CreateInlineResetButton(parent, function()
            if type(fontControl.Reset) == "function" then
                fontControl:Reset()
            end
        end)
        familyReset:SetPoint("LEFT", fontControl, "RIGHT", 6, 6)
        y = y - 62

	local sharedSize = tonumber(SQPSettings.killFontSize) or tonumber(SQPSettings.fontSize) or defaultSharedSize
	local sizeSlider = self:CreateStyledSlider(parent, {
		key = "killFontSize",
		label = "Size",
		min = 6,
		max = 26,
		step = 1,
		default = defaultSharedSize,
		storage = SQPSettings,
		width = 160,
		onChange = function(val)
			SQP:SetSetting("fontSize", val)
			SQP:SetSetting("killFontSize", val)
			SQP:SetSetting("lootFontSize", val)
			SQP:SetSetting("percentFontSize", val)
			SQP:RefreshOptionsPreview()
			SQP:RefreshAllNameplates()
		end,
	})
	sizeSlider:SetPoint("TOPLEFT", 20, y)
	self.optionControls.sharedFontSize = sizeSlider

	y = y - 38

        local note = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        note:SetPoint("TOPLEFT", 20, y)
        note:SetWidth(220)
        note:SetJustifyH("LEFT")
        note:SetText(self.L["|cffaaaaaaChanges kill, loot, and percent numbers. Percent sign sizing stays separate.|r"])
        return y - 30
    end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(288)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 14, 0)

    -- ── LEFT COLUMN: Addon state + toggles + combat ────────────────────────────
    local yOffset = -12

    -- Addon State
    local addonStateLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    addonStateLabel:SetPoint("TOPLEFT", 20, yOffset)
    addonStateLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ADDON_STATE"] or "Addon State") .. "|r")
    yOffset = yOffset - 14

    local enableButton  = self:CreateStyledButton(leftColumn, self.L["OPTIONS_ENABLE"]  or "Enable",  68, 20)
    local disableButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_DISABLE"] or "Disable", 68, 20)
    enableButton:SetPoint("TOPLEFT", 20, yOffset)
    disableButton:SetPoint("LEFT", enableButton, "RIGHT", 10, 0)

    local function UpdateEnabledButtons()
        if SQPSettings.enabled ~= false then
            enableButton:SetAlpha(1); disableButton:SetAlpha(0.6)
        else
            enableButton:SetAlpha(0.6); disableButton:SetAlpha(1)
        end
    end
    UpdateEnabledButtons()
    self.optionControls.updateEnabledButtons = UpdateEnabledButtons

    enableButton:SetScript("OnClick", function()
        SQP:SetSetting('enabled', true); UpdateEnabledButtons(); SQP:RefreshAllNameplates()
    end)
    disableButton:SetScript("OnClick", function()
        SQP:SetSetting('enabled', false); UpdateEnabledButtons(); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 24

    -- General Settings
    local generalSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    generalSection:SetPoint("TOPLEFT", 20, yOffset)
    generalSection:SetText("|cff58be81" .. (self.L["OPTIONS_GENERAL"] or "General Settings") .. "|r")
    yOffset = yOffset - 14

    local debugFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_DEBUG"] or "Enable Debug Mode")
    debugFrame:SetPoint("TOPLEFT", 20, yOffset)
    debugFrame.checkbox:SetChecked(SQPSettings.debug)
    self.optionControls.debug = debugFrame.checkbox
    debugFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('debug', self:GetChecked())
        SQP:PrintMessage(SQPSettings.debug and "Debug mode enabled" or "Debug mode disabled")
    end)
    yOffset = yOffset - 18

    local chatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_CHAT_MESSAGES"] or "Show Chat Messages")
    chatFrame:SetPoint("TOPLEFT", 20, yOffset)
    chatFrame.checkbox:SetChecked(SQPSettings.showMessages ~= false)
    self.optionControls.showMessages = chatFrame.checkbox
    chatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showMessages', self:GetChecked())
    end)
    yOffset = yOffset - 20

    local minimapSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minimapSection:SetPoint("TOPLEFT", 20, yOffset)
    minimapSection:SetText(self.L["|cff58be81Minimap Icon|r"])
    yOffset = yOffset - 14

    local minimapFrame = self:CreateStyledCheckbox(leftColumn, self.L["Show minimap icon"])
    minimapFrame:SetPoint("TOPLEFT", 20, yOffset)
    minimapFrame.checkbox:SetChecked(SQPSettings.minimapIconEnabled ~= false)
    self.optionControls.minimapIconEnabled = minimapFrame.checkbox
    minimapFrame.checkbox:SetScript("OnClick", function(self)
        SQP:ToggleMinimapIcon(self:GetChecked())
    end)
    yOffset = yOffset - 20

    local minimapHint = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minimapHint:SetPoint("TOPLEFT", 20, yOffset)
    minimapHint:SetWidth(250)
    minimapHint:SetJustifyH("LEFT")
    minimapHint:SetText(self.L["|cffaaaaaaLeft-click opens options. Drag to move. Ctrl-right-click hides it.|r"])
    yOffset = yOffset - 32

    -- Global Animation Override
    -- Combat Settings
    local combatSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    combatSection:SetPoint("TOPLEFT", 20, yOffset)
    combatSection:SetText("|cff58be81" .. (self.L["OPTIONS_COMBAT"] or "Combat Settings") .. "|r")
    yOffset = yOffset - 14

    local combatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_HIDE_COMBAT"] or "Hide Icons in Combat")
    combatFrame:SetPoint("TOPLEFT", 20, yOffset)
    combatFrame.checkbox:SetChecked(SQPSettings.hideInCombat)
    self.optionControls.hideInCombat = combatFrame.checkbox
    combatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInCombat', self:GetChecked()); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 18

    local instanceFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_HIDE_INSTANCE"] or "Hide Icons in Instances")
    instanceFrame:SetPoint("TOPLEFT", 20, yOffset)
    instanceFrame.checkbox:SetChecked(SQPSettings.hideInInstance)
    self.optionControls.hideInInstance = instanceFrame.checkbox
    instanceFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInInstance', self:GetChecked()); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    local testButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_TEST"] or "Test Detection", 120, 20)
    testButton:SetPoint("TOPLEFT", 20, yOffset)
    testButton:SetScript("OnClick", function() SQP:TestQuestDetection() end)

    local resetButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_RESET"] or "Reset All Settings", 138, 20)
    resetButton:SetPoint("LEFT", testButton, "RIGHT", 8, 0)
    resetButton:SetAlpha(0.8)
    resetButton:SetScript("OnClick", function() StaticPopup_Show("SQP_RESET_CONFIRM") end)

    -- ── RIGHT COLUMN: Position & Scale ────────────────────────────────────────
    local rightYOffset = -12

    local posScaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    posScaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    posScaleLabel:SetText(self.L["|cff58be81Position & Scale|r"])
    rightYOffset = rightYOffset - 14

	-- Global Scale
	local scaleSlider = self:CreateStyledSlider(rightColumn, {
		key = "scale",
		label = "Scale",
		min = 0.5,
		max = 3.0,
		step = 0.1,
		default = 1.1,
		storage = SQPSettings,
		suffix = "",
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	scaleSlider:SetPoint("TOPLEFT", 20, rightYOffset)
	self.optionControls.scale = scaleSlider
	self.optionControls.scaleLabel = scaleSlider.valueLabel

	rightYOffset = rightYOffset - 42

	-- X Offset
	local xSlider = self:CreateStyledSlider(rightColumn, {
		key = "offsetX",
		label = "Offset X",
		min = -100,
		max = 100,
		step = 1,
		default = 0,
		storage = SQPSettings,
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	xSlider:SetPoint("TOPLEFT", 20, rightYOffset)
	self.optionControls.offsetX = xSlider
	self.optionControls.offsetXLabel = xSlider.valueLabel

	rightYOffset = rightYOffset - 42

	-- Y Offset
	local ySlider = self:CreateStyledSlider(rightColumn, {
		key = "offsetY",
		label = "Offset Y",
		min = -100,
		max = 100,
		step = 1,
		default = 3,
		storage = SQPSettings,
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	ySlider:SetPoint("TOPLEFT", 20, rightYOffset)
	self.optionControls.offsetY = ySlider
	self.optionControls.offsetYLabel = ySlider.valueLabel

	rightYOffset = rightYOffset - 42

    -- Nameplate Side
    local anchorLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    anchorLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    anchorLabel:SetText(self.L["Nameplate Side"])
    rightYOffset = rightYOffset - 18

    local leftBtn  = self:CreateStyledButton(rightColumn, self.L["Left Side"],  84, 20)
    local rightBtn = self:CreateStyledButton(rightColumn, self.L["Right Side"], 84, 20)
    leftBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    rightBtn:SetPoint("LEFT", leftBtn, "RIGHT", 8, 0)
    self.optionControls.anchorButtons = {left = leftBtn, right = rightBtn}

    local function UpdateAnchorButtons()
        leftBtn:SetAlpha( SQPSettings.anchor == "RIGHT" and 1 or 0.6)
        rightBtn:SetAlpha(SQPSettings.anchor == "LEFT"  and 1 or 0.6)
    end
    self.optionControls.updateAnchorButtons = UpdateAnchorButtons
    UpdateAnchorButtons()

    leftBtn:SetScript("OnClick", function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    rightBtn:SetScript("OnClick", function()
        SQP:SetSetting('anchor', "LEFT")
        SQP:SetSetting('relativeTo', "RIGHT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)

    local anchorReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    anchorReset:SetPoint("LEFT", rightBtn, "RIGHT", 6, 0)

    rightYOffset = rightYOffset - 30
    CreateNameplateFontControl(rightColumn, rightYOffset)
end
