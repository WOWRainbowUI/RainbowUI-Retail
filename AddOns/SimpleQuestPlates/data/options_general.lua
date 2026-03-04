--=====================================================================================
-- RGX | Simple Quest Plates! - options_general.lua

-- Author: DonnieDice
-- Description: Global settings tab (addon state, combat, position, scale)
--=====================================================================================

local addonName, SQP = ...
local format = string.format

function SQP:CreateGlobalOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── LEFT COLUMN: Addon state + toggles + combat ────────────────────────────
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

    -- Global Animation Override
    local animSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    animSection:SetPoint("TOPLEFT", 20, yOffset)
    animSection:SetText(self.L["|cff58be81Animation|r"])
    yOffset = yOffset - 20

    local overrideAnimFrame = self:CreateStyledCheckbox(leftColumn, self.L["Use Global Animation Override"])
    overrideAnimFrame:SetPoint("TOPLEFT", 20, yOffset)
    overrideAnimFrame.checkbox:SetChecked(SQPSettings.useGlobalAnimationSettings == true)
    self.optionControls.useGlobalAnimationSettings = overrideAnimFrame.checkbox
    yOffset = yOffset - 26

    local globalAnimEnableFrame = self:CreateStyledCheckbox(leftColumn, self.L["Enable All Animations"])
    globalAnimEnableFrame:SetPoint("TOPLEFT", 20, yOffset)
    globalAnimEnableFrame.checkbox:SetChecked(SQPSettings.globalAnimationEnabled ~= false)
    self.optionControls.globalAnimationEnabled = globalAnimEnableFrame.checkbox
    yOffset = yOffset - 28

    local function GetAnimationCombatMode()
        local mode = SQPSettings.animationCombatMode
        if mode ~= "always" and mode ~= "combat" and mode ~= "outofcombat" then
            mode = "always"
        end
        return mode
    end

    local animModeLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    animModeLabel:SetPoint("TOPLEFT", 20, yOffset)
    animModeLabel:SetText(self.L["Animate When"])
    yOffset = yOffset - 20

    local animAlwaysBtn = self:CreateStyledButton(leftColumn, self.L["Always"], 58, 22)
    local animCombatBtn = self:CreateStyledButton(leftColumn, self.L["Combat"], 58, 22)
    local animOutBtn = self:CreateStyledButton(leftColumn, self.L["No Combat"], 70, 22)
    animAlwaysBtn:SetPoint("TOPLEFT", 20, yOffset)
    animCombatBtn:SetPoint("LEFT", animAlwaysBtn, "RIGHT", 6, 0)
    animOutBtn:SetPoint("LEFT", animCombatBtn, "RIGHT", 6, 0)
    self.optionControls.animationCombatModeButtons = {
        always = animAlwaysBtn,
        combat = animCombatBtn,
        outofcombat = animOutBtn,
    }

    local function UpdateAnimationModeButtons()
        local mode = GetAnimationCombatMode()
        animAlwaysBtn:SetAlpha(mode == "always" and 1 or 0.6)
        animCombatBtn:SetAlpha(mode == "combat" and 1 or 0.6)
        animOutBtn:SetAlpha(mode == "outofcombat" and 1 or 0.6)
    end
    UpdateAnimationModeButtons()
    yOffset = yOffset - 30

    animAlwaysBtn:SetScript("OnClick", function()
        SQP:SetSetting('animationCombatMode', "always")
        UpdateAnimationModeButtons()
        SQP:RefreshAllNameplates()
    end)
    animCombatBtn:SetScript("OnClick", function()
        SQP:SetSetting('animationCombatMode', "combat")
        UpdateAnimationModeButtons()
        SQP:RefreshAllNameplates()
    end)
    animOutBtn:SetScript("OnClick", function()
        SQP:SetSetting('animationCombatMode', "outofcombat")
        UpdateAnimationModeButtons()
        SQP:RefreshAllNameplates()
    end)

    local globalIntensityLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    globalIntensityLabel:SetPoint("TOPLEFT", 20, yOffset)
    globalIntensityLabel:SetText(format(self.L["Global Intensity: %d%%"], SQPSettings.globalAnimationIntensity or 100))
    self.optionControls.globalAnimationIntensityLabel = globalIntensityLabel

    local globalIntensitySlider = self:CreateStyledSlider(leftColumn, 25, 200, 5, 160)
    globalIntensitySlider:SetPoint("TOPLEFT", globalIntensityLabel, "BOTTOMLEFT", 0, -4)
    globalIntensitySlider:SetValue(SQPSettings.globalAnimationIntensity or 100)
    self.optionControls.globalAnimationIntensity = globalIntensitySlider

    local globalIntensityReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('globalAnimationIntensity', 100)
        globalIntensitySlider:SetValue(100)
        globalIntensityLabel:SetText(self.L["Global Intensity: 100%"])
        SQP:RefreshAllNameplates()
    end)
    globalIntensityReset:SetPoint("LEFT", globalIntensitySlider, "RIGHT", 4, 0)
    yOffset = yOffset - 44

    local function UpdateGlobalAnimationControls()
        local override = SQPSettings.useGlobalAnimationSettings == true
        if globalAnimEnableFrame then
            globalAnimEnableFrame:SetAlpha(override and 1 or 0.5)
            if globalAnimEnableFrame.checkbox then
                globalAnimEnableFrame.checkbox:SetEnabled(override)
            end
        end
        if globalIntensitySlider then
            globalIntensitySlider:SetEnabled(override)
            globalIntensitySlider:SetAlpha(override and 1 or 0.5)
        end
        if globalIntensityReset then
            globalIntensityReset:SetAlpha(override and 0.7 or 0.35)
        end
        if globalIntensityLabel then
            globalIntensityLabel:SetAlpha(override and 1 or 0.6)
        end
    end

    overrideAnimFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('useGlobalAnimationSettings', self:GetChecked())
        UpdateGlobalAnimationControls()
        SQP:RefreshAllNameplates()
    end)
    globalAnimEnableFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('globalAnimationEnabled', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    globalIntensitySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5 + 0.5) * 5
        SQP:SetSetting('globalAnimationIntensity', value)
        globalIntensityLabel:SetText(format(self.L["Global Intensity: %d%%"], value))
        SQP:RefreshAllNameplates()
    end)
    UpdateGlobalAnimationControls()

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

    -- ── RIGHT COLUMN: Position & Scale ────────────────────────────────────────
    local rightYOffset = -15

    local posScaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posScaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    posScaleLabel:SetText(self.L["|cff58be81Position & Scale|r"])
    rightYOffset = rightYOffset - 20

    -- Global Scale
    local scaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    scaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    scaleLabel:SetText(format(self.L["Scale: %.1f"], SQPSettings.scale or 1.1))
    self.optionControls.scaleLabel = scaleLabel

    local scaleSlider = self:CreateStyledSlider(rightColumn, 0.5, 3.0, 0.1, 160)
    scaleSlider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -4)
    scaleSlider:SetValue(SQPSettings.scale or 1.1)
    self.optionControls.scale = scaleSlider

    local scaleReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('scale', 1.1)
        scaleSlider:SetValue(1.1)
        scaleLabel:SetText(self.L["Scale: 1.1"])
        SQP:RefreshAllNameplates()
    end)
    scaleReset:SetPoint("LEFT", scaleSlider, "RIGHT", 4, 0)

    scaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        SQP:SetSetting('scale', value)
        scaleLabel:SetText(format(self.L["Scale: %.1f"], value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- X Offset
    local xLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    xLabel:SetText(format(self.L["Offset X: %d"], SQPSettings.offsetX or 0))
    self.optionControls.offsetXLabel = xLabel

    local xSlider = self:CreateStyledSlider(rightColumn, -100, 100, 1, 160)
    xSlider:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -4)
    xSlider:SetValue(SQPSettings.offsetX or 0)
    self.optionControls.offsetX = xSlider

    local xReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('offsetX', 0)
        xSlider:SetValue(0)
        xLabel:SetText(self.L["Offset X: 0"])
        SQP:RefreshAllNameplates()
    end)
    xReset:SetPoint("LEFT", xSlider, "RIGHT", 4, 0)

    xSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetX', value)
        xLabel:SetText(format(self.L["Offset X: %d"], value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- Y Offset
    local yLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    yLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    yLabel:SetText(format(self.L["Offset Y: %d"], SQPSettings.offsetY or 3))
    self.optionControls.offsetYLabel = yLabel

    local ySlider = self:CreateStyledSlider(rightColumn, -100, 100, 1, 160)
    ySlider:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -4)
    ySlider:SetValue(SQPSettings.offsetY or 3)
    self.optionControls.offsetY = ySlider

    local yReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('offsetY', 3)
        ySlider:SetValue(3)
        yLabel:SetText(self.L["Offset Y: 3"])
        SQP:RefreshAllNameplates()
    end)
    yReset:SetPoint("LEFT", ySlider, "RIGHT", 4, 0)

    ySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetY', value)
        yLabel:SetText(format(self.L["Offset Y: %d"], value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- Nameplate Side
    local anchorLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    anchorLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    anchorLabel:SetText(self.L["Nameplate Side"])
    rightYOffset = rightYOffset - 22

    local leftBtn  = self:CreateStyledButton(rightColumn, self.L["Left Side"],  90, 25)
    local rightBtn = self:CreateStyledButton(rightColumn, self.L["Right Side"], 90, 25)
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
end
