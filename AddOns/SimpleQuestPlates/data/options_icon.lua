--=====================================================================================
-- RGX | Simple Quest Plates! - options_icon.lua

-- Author: DonnieDice
-- Description: Icon options tab content
--=====================================================================================

local addonName, SQP = ...
local format = string.format

-- Create icon settings section
function SQP:CreateIconOptions(content)
    -- Initialize control storage if not exists
    if not self.optionControls then
        self.optionControls = {}
    end
    
    -- Create two-column layout
    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(320)
    
    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)
    
    -- LEFT COLUMN - Position Settings
    local yOffset = -20
    
    -- Position Section
    local positionLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    positionLabel:SetPoint("TOPLEFT", 20, yOffset)
    positionLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_POSITION"] or "Icon Position") .. "|r")
    yOffset = yOffset - 20  -- Condensed
    
    -- X Offset
    local xLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    xLabel:SetPoint("TOPLEFT", 20, yOffset)
    xLabel:SetText(self.L["OPTIONS_OFFSET_X"] or "Horizontal Offset")
    
    local xSlider = self:CreateStyledSlider(leftColumn, -50, 50, 1, 200)
    xSlider:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -5)
    xSlider:SetValue(SQPSettings.offsetX)
    self.optionControls.offsetX = xSlider  -- Store reference
    
    local xValue = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    xValue:SetPoint("LEFT", xSlider, "RIGHT", 10, 0)
    xValue:SetText(tostring(SQPSettings.offsetX))
    
    local xResetBtn = self:CreateStyledButton(leftColumn, "Reset", 50, 20)
    xResetBtn:SetPoint("LEFT", xValue, "RIGHT", 10, 0)
    xResetBtn:SetAlpha(0.8)
    xResetBtn:SetScript("OnClick", function()
        SQP:SetSetting('offsetX', 0)
        xSlider:SetValue(0)
        xValue:SetText("0")
        SQP:RefreshAllNameplates()
    end)
    
    xSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetX', value)
        xValue:SetText(tostring(value))
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 50  -- Condensed
    
    -- Y Offset
    local yLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    yLabel:SetPoint("TOPLEFT", 20, yOffset)
    yLabel:SetText(self.L["OPTIONS_OFFSET_Y"] or "Vertical Offset")
    
    local ySlider = self:CreateStyledSlider(leftColumn, -50, 50, 1, 200)
    ySlider:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -5)
    ySlider:SetValue(SQPSettings.offsetY)
    self.optionControls.offsetY = ySlider  -- Store reference
    
    local yValue = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    yValue:SetPoint("LEFT", ySlider, "RIGHT", 10, 0)
    yValue:SetText(tostring(SQPSettings.offsetY))
    
    local yResetBtn = self:CreateStyledButton(leftColumn, "Reset", 50, 20)
    yResetBtn:SetPoint("LEFT", yValue, "RIGHT", 10, 0)
    yResetBtn:SetAlpha(0.8)
    yResetBtn:SetScript("OnClick", function()
        SQP:SetSetting('offsetY', 0)
        ySlider:SetValue(0)
        yValue:SetText("0")
        SQP:RefreshAllNameplates()
    end)
    
    ySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetY', value)
        yValue:SetText(tostring(value))
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 50  -- Condensed
    
    -- Anchor selection
    local anchorLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    anchorLabel:SetPoint("TOPLEFT", 20, yOffset)
    anchorLabel:SetText(self.L["OPTIONS_ANCHOR"] or "Nameplate Side")
    yOffset = yOffset - 20  -- Condensed
    
    -- Create buttons
    local leftButton = self:CreateStyledButton(leftColumn, "Left Side", 90, 25)
    leftButton:SetPoint("TOPLEFT", 20, yOffset)
    
    local rightButton = self:CreateStyledButton(leftColumn, "Right Side", 90, 25)
    rightButton:SetPoint("LEFT", leftButton, "RIGHT", 10, 0)
    
    -- Store anchor buttons for refresh
    self.optionControls.anchorButtons = {left = leftButton, right = rightButton}
    
    -- Create button state update function
    local function UpdateButtonStates()
        if SQPSettings.anchor == "RIGHT" then
            leftButton:SetAlpha(1)
            rightButton:SetAlpha(0.6)
        else
            leftButton:SetAlpha(0.6)
            rightButton:SetAlpha(1)
        end
    end
    self.optionControls.updateAnchorButtons = UpdateButtonStates
    
    -- Set button scripts
    leftButton:SetScript("OnClick", function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        SQP:RefreshAllNameplates()
        UpdateButtonStates()
    end)
    
    rightButton:SetScript("OnClick", function()
        SQP:SetSetting('anchor', "LEFT")
        SQP:SetSetting('relativeTo', "RIGHT")
        SQP:RefreshAllNameplates()
        UpdateButtonStates()
    end)
    
    -- Set initial button states
    UpdateButtonStates()
    
    -- Store references for reset functionality
    self.optionControls.anchorUpdateFunc = UpdateButtonStates
    
    -- RIGHT COLUMN - Icon Style
    local rightYOffset = -20
    
    -- Icon Style Section
    local styleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    styleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    styleLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_STYLE"] or "Icon Style") .. "|r")
    rightYOffset = rightYOffset - 20  -- Condensed
    
    -- Global Scale setting
    local scaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    scaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    scaleLabel:SetText(self.L["OPTIONS_GLOBAL_SCALE"] or "Global Scale")
    
    local scaleSlider = self:CreateStyledSlider(rightColumn, 0.5, 3.0, 0.1, 200)  -- Increased max to 3.0
    scaleSlider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -5)
    scaleSlider:SetValue(SQPSettings.scale)
    self.optionControls.scale = scaleSlider  -- Store reference
    
    local scaleValue = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    scaleValue:SetPoint("LEFT", scaleSlider, "RIGHT", 10, 0)
    scaleValue:SetText(format("%.1f", SQPSettings.scale))
    
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        SQP:SetSetting('scale', value)
        scaleValue:SetText(format("%.1f", value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 50  -- Condensed spacing after scale slider
    
    -- Icon tint color picker
    local iconColorBtn = CreateFrame("Button", nil, rightColumn)
    iconColorBtn:SetSize(20, 20)
    iconColorBtn:SetPoint("TOPLEFT", 30, rightYOffset)
    
    local iconBg = iconColorBtn:CreateTexture(nil, "BACKGROUND")
    iconBg:SetAllPoints()
    iconBg:SetColorTexture(0, 0, 0, 1)
    
    local iconSwatch = iconColorBtn:CreateTexture(nil, "ARTWORK")
    iconSwatch:SetSize(16, 16)
    iconSwatch:SetPoint("CENTER")
    local iconColor = SQPSettings.iconTintColor or {1, 1, 1}
    iconSwatch:SetColorTexture(unpack(iconColor))
    
    -- Store color swatch reference
    self.optionControls.iconTintColorSwatch = iconSwatch
    
    local iconColorText = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    iconColorText:SetPoint("LEFT", iconColorBtn, "RIGHT", 5, 0)
    iconColorText:SetText(self.L["OPTIONS_ICON_COLOR"] or "Icon Tint Color")
    
    iconColorBtn:SetScript("OnClick", function()
        local r, g, b = unpack(SQPSettings.iconTintColor or {1, 1, 1})
        
        local info = {}
        info.r = r
        info.g = g
        info.b = b
        info.hasOpacity = false
        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('iconTintColor', {r, g, b})
            iconSwatch:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('iconTintColor', {r, g, b})
            iconSwatch:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    
    -- Icon color reset button
    local iconResetBtn = self:CreateStyledButton(rightColumn, "Reset", 50, 20)
    iconResetBtn:SetPoint("LEFT", iconColorText, "RIGHT", 10, 0)
    iconResetBtn:SetAlpha(0.8)
    iconResetBtn:SetScript("OnClick", function()
        SQP:SetSetting('iconTintColor', {1, 1, 1})
        iconSwatch:SetColorTexture(1, 1, 1)
        SQP:RefreshAllNameplates()
    end)
    
    rightYOffset = rightYOffset - 60
    
    -- Reset all icon settings button
    local resetAllBtn = self:CreateStyledButton(rightColumn, "Reset All Icon Settings", 180, 30)
    resetAllBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    resetAllBtn:SetAlpha(0.8)
    resetAllBtn:SetScript("OnClick", function()
        SQP:SetSetting('offsetX', 0)
        SQP:SetSetting('offsetY', 0)
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        SQP:SetSetting('scale', 1.0)
        SQP:SetSetting('iconTint', false)
        SQP:SetSetting('iconTintColor', {1, 1, 1})
        
        xSlider:SetValue(0)
        xValue:SetText("0")
        ySlider:SetValue(0)
        yValue:SetText("0")
        scaleSlider:SetValue(1.0)
        scaleValue:SetText("1.0")
        iconSwatch:SetColorTexture(1, 1, 1)
        UpdateButtonStates()
        
        SQP:RefreshAllNameplates()
    end)
end