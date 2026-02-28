--=====================================================================================
-- RGX | Simple Quest Plates! - options_general.lua

-- Author: DonnieDice
-- Description: General settings tab (addon state, combat, font)
--=====================================================================================

local addonName, SQP = ...
local format = string.format

function SQP:CreateGeneralOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── LEFT COLUMN: Addon state + toggles + combat ───────────────────────────
    local yOffset = -15

    -- Addon State
    local addonStateLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    addonStateLabel:SetPoint("TOPLEFT", 20, yOffset)
    addonStateLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ADDON_STATE"] or "Addon State") .. "|r")
    yOffset = yOffset - 20

    local enableButton  = self:CreateStyledButton(leftColumn, self.L["OPTIONS_ENABLE"]  or "Enable",  80, 25)
    local disableButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_DISABLE"] or "Disable", 80, 25)
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
    yOffset = yOffset - 33

    -- General Settings
    local generalSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    generalSection:SetPoint("TOPLEFT", 20, yOffset)
    generalSection:SetText("|cff58be81" .. (self.L["OPTIONS_GENERAL"] or "General Settings") .. "|r")
    yOffset = yOffset - 20

    local debugFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_DEBUG"] or "Enable Debug Mode")
    debugFrame:SetPoint("TOPLEFT", 20, yOffset)
    debugFrame.checkbox:SetChecked(SQPSettings.debug)
    self.optionControls.debug = debugFrame.checkbox
    debugFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('debug', self:GetChecked())
        SQP:PrintMessage(SQPSettings.debug and "Debug mode enabled" or "Debug mode disabled")
    end)
    yOffset = yOffset - 26

    local chatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_CHAT_MESSAGES"] or "Show Chat Messages")
    chatFrame:SetPoint("TOPLEFT", 20, yOffset)
    chatFrame.checkbox:SetChecked(SQPSettings.showMessages ~= false)
    self.optionControls.showMessages = chatFrame.checkbox
    chatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showMessages', self:GetChecked())
    end)
    yOffset = yOffset - 30

    -- Combat Settings
    local combatSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    combatSection:SetPoint("TOPLEFT", 20, yOffset)
    combatSection:SetText("|cff58be81" .. (self.L["OPTIONS_COMBAT"] or "Combat Settings") .. "|r")
    yOffset = yOffset - 20

    local combatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_HIDE_COMBAT"] or "Hide Icons in Combat")
    combatFrame:SetPoint("TOPLEFT", 20, yOffset)
    combatFrame.checkbox:SetChecked(SQPSettings.hideInCombat)
    self.optionControls.hideInCombat = combatFrame.checkbox
    combatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInCombat', self:GetChecked()); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    local instanceFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_HIDE_INSTANCE"] or "Hide Icons in Instances")
    instanceFrame:SetPoint("TOPLEFT", 20, yOffset)
    instanceFrame.checkbox:SetChecked(SQPSettings.hideInInstance)
    self.optionControls.hideInInstance = instanceFrame.checkbox
    instanceFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInInstance', self:GetChecked()); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    local testButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_TEST"] or "Test Detection", 140, 25)
    testButton:SetPoint("TOPLEFT", 20, yOffset)
    testButton:SetScript("OnClick", function() SQP:TestQuestDetection() end)
    yOffset = yOffset - 34

    local resetButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_RESET"] or "Reset All Settings", 160, 25)
    resetButton:SetPoint("TOPLEFT", 20, yOffset)
    resetButton:SetAlpha(0.8)
    resetButton:SetScript("OnClick", function() StaticPopup_Show("SQP_RESET_CONFIRM") end)

    -- ── RIGHT COLUMN: Font Settings ───────────────────────────────────────────
    local rightYOffset = -15

    local fontTitle = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontTitle:SetPoint("TOPLEFT", 20, rightYOffset)
    fontTitle:SetText("|cff58be81" .. (self.L["OPTIONS_FONT_SETTINGS"] or "Font Settings") .. "|r")
    rightYOffset = rightYOffset - 22

    -- Font Size
    local fontSizeLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontSizeLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    fontSizeLabel:SetText(self.L["OPTIONS_FONT_SIZE"] or "Font Size")

    local fontSlider = self:CreateStyledSlider(rightColumn, 8, 20, 1, 160)
    fontSlider:SetPoint("TOPLEFT", fontSizeLabel, "BOTTOMLEFT", 0, -5)
    fontSlider:SetValue(SQPSettings.fontSize or 12)

    local fontValue = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fontValue:SetPoint("LEFT", fontSlider, "RIGHT", 6, 0)
    fontValue:SetText(tostring(SQPSettings.fontSize or 12))

    local fontSizeReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('fontSize', 12)
        fontSlider:SetValue(12); fontValue:SetText("12")
        SQP:RefreshAllNameplates()
    end)
    fontSizeReset:SetPoint("LEFT", fontValue, "RIGHT", 4, 0)

    fontSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('fontSize', value); fontValue:SetText(tostring(value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- Font Family
    local fontFamilyLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontFamilyLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    fontFamilyLabel:SetText(self.L["OPTIONS_FONT_FAMILY"] or "Font Family")

    local fontFamilyReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('fontFamily', "Fonts\\FRIZQT__.TTF")
        UIDropDownMenu_SetText(fontDropdown, "Default (Friz Quadrata)")
        SQP:RefreshAllNameplates()
    end)
    fontFamilyReset:SetPoint("LEFT", fontFamilyLabel, "RIGHT", 5, 0)
    rightYOffset = rightYOffset - 22

    local fontDropdown = CreateFrame("Frame", "SQPFontDropdown", rightColumn, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", 5, rightYOffset)
    UIDropDownMenu_SetWidth(fontDropdown, 180)
    self.optionControls.fontFamily = fontDropdown

    local fontOptions = {
        {text = "Default (Friz Quadrata)", font = "Fonts\\FRIZQT__.TTF"},
        {text = "Arial Narrow",            font = "Fonts\\ARIALN.TTF"},
        {text = "Skurri",                  font = "Fonts\\SKURRI.TTF"},
        {text = "Morpheus",                font = "Fonts\\MORPHEUS.TTF"},
        {text = "2002 (Pixel)",            font = "Fonts\\2002.TTF"},
        {text = "2002 Bold (Pixel)",       font = "Fonts\\2002B.TTF"},
        {text = "Nimrod MT",               font = "Fonts\\NIM_____.ttf"},
    }

    UIDropDownMenu_Initialize(fontDropdown, function(self, level)
        for _, opt in ipairs(fontOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text
            info.func = function()
                SQP:SetSetting('fontFamily', opt.font)
                UIDropDownMenu_SetText(fontDropdown, opt.text)
                SQP:RefreshAllNameplates()
            end
            info.checked = (SQPSettings.fontFamily == opt.font)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local currentFont = SQPSettings.fontFamily or "Fonts\\FRIZQT__.TTF"
    for _, opt in ipairs(fontOptions) do
        if opt.font == currentFont then
            UIDropDownMenu_SetText(fontDropdown, opt.text); break
        end
    end
    rightYOffset = rightYOffset - 38

    -- Outline Width
    local outlineLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    outlineLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    outlineLabel:SetText(self.L["OPTIONS_OUTLINE_WIDTH"] or "Outline Width")

    local outlineNames = {"None", "Normal", "Thick"}
    local function GetSliderVal()
        local w = SQP:GetOutlineInfo()
        if w >= 3 then return 2 elseif w >= 2 then return 1 else return 0 end
    end

    local outlineSlider = self:CreateStyledSlider(rightColumn, 0, 2, 1, 160)
    outlineSlider:SetPoint("TOPLEFT", outlineLabel, "BOTTOMLEFT", 0, -5)
    local initVal = GetSliderVal()
    outlineSlider:SetValue(initVal)
    self.optionControls.outlineSlider = outlineSlider

    local outlineValueText = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    outlineValueText:SetPoint("LEFT", outlineSlider, "RIGHT", 6, 0)
    outlineValueText:SetText(outlineNames[initVal + 1])
    self.optionControls.outlineValueText = outlineValueText

    local outlineReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('outlineWidth', 0); SQP:SetSetting('fontOutline', "")
        outlineSlider:SetValue(0); outlineValueText:SetText("None")
        SQP:RefreshAllNameplates()
    end)
    outlineReset:SetPoint("LEFT", outlineValueText, "RIGHT", 4, 0)

    outlineSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        if value == 0 then
            SQP:SetSetting('outlineWidth', 0); SQP:SetSetting('fontOutline', "")
        elseif value == 1 then
            SQP:SetSetting('outlineWidth', 2); SQP:SetSetting('fontOutline', "OUTLINE")
        else
            SQP:SetSetting('outlineWidth', 3); SQP:SetSetting('fontOutline', "THICKOUTLINE")
        end
        outlineValueText:SetText(outlineNames[value + 1])
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- Outline Opacity
    local alphaLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    alphaLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    alphaLabel:SetText("Outline Opacity")

    local initAlpha = math.floor((SQPSettings.outlineAlpha or 1.0) * 100 + 0.5)
    local alphaSlider = self:CreateStyledSlider(rightColumn, 0, 100, 5, 160)
    alphaSlider:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -5)
    alphaSlider:SetValue(initAlpha)
    self.optionControls.outlineAlphaSlider = alphaSlider

    local alphaValue = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    alphaValue:SetPoint("LEFT", alphaSlider, "RIGHT", 6, 0)
    alphaValue:SetText(initAlpha .. "%")

    local alphaReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('outlineAlpha', 0)
        alphaSlider:SetValue(0); alphaValue:SetText("0%")
        SQP:RefreshAllNameplates()
    end)
    alphaReset:SetPoint("LEFT", alphaValue, "RIGHT", 4, 0)

    alphaSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5 + 0.5) * 5
        SQP:SetSetting('outlineAlpha', value / 100)
        alphaValue:SetText(value .. "%")
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- Outline Color
    local colorBtn = CreateFrame("Button", nil, rightColumn)
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
    cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
    local sw = colorBtn:CreateTexture(nil, "ARTWORK")
    sw:SetSize(16, 16); sw:SetPoint("CENTER")
    sw:SetColorTexture(unpack(SQPSettings.outlineColor or {0, 0, 0}))

    local colorLbl = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    colorLbl:SetText("Outline Color")

    local colorResetBtn = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('outlineColor', {0, 0, 0})
        sw:SetColorTexture(0, 0, 0); SQP:RefreshAllNameplates()
    end)
    colorResetBtn:SetPoint("LEFT", colorLbl, "RIGHT", 6, 0)

    colorBtn:SetScript("OnClick", function()
        local r, g, b = unpack(SQPSettings.outlineColor or {0, 0, 0})
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('outlineColor', {nr, ng, nb}); sw:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('outlineColor', {r, g, b}); sw:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
end
