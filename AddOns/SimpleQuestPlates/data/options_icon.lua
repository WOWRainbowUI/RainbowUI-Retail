--=====================================================================================
-- RGX | Simple Quest Plates! - options_icon.lua

-- Author: DonnieDice
-- Description: Main icon options tab (position, scale, display style)
--=====================================================================================

local addonName, SQP = ...
local format = string.format

function SQP:CreateIconOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── LEFT COLUMN: Position ────────────────────────────────────────────────
    local yOffset = -15

    local posLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posLabel:SetPoint("TOPLEFT", 20, yOffset)
    posLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_POSITION"] or "Icon Position") .. "|r")
    yOffset = yOffset - 22

    -- X Offset
    local xLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    xLabel:SetPoint("TOPLEFT", 20, yOffset)
    xLabel:SetText(self.L["OPTIONS_OFFSET_X"] or "Horizontal Offset")

    local xSlider = self:CreateStyledSlider(leftColumn, -100, 100, 1, 160)
    xSlider:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -5)
    xSlider:SetValue(SQPSettings.offsetX)
    self.optionControls.offsetX = xSlider

    local xValue = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    xValue:SetPoint("LEFT", xSlider, "RIGHT", 6, 0)
    xValue:SetText(tostring(SQPSettings.offsetX))

    local xReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('offsetX', 12)
        xSlider:SetValue(12)
        xValue:SetText("12")
        SQP:RefreshAllNameplates()
    end)
    xReset:SetPoint("LEFT", xValue, "RIGHT", 4, 0)

    xSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetX', value)
        xValue:SetText(tostring(value))
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 48

    -- Y Offset
    local yLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    yLabel:SetPoint("TOPLEFT", 20, yOffset)
    yLabel:SetText(self.L["OPTIONS_OFFSET_Y"] or "Vertical Offset")

    local ySlider = self:CreateStyledSlider(leftColumn, -100, 100, 1, 160)
    ySlider:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -5)
    ySlider:SetValue(SQPSettings.offsetY)
    self.optionControls.offsetY = ySlider

    local yValue = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    yValue:SetPoint("LEFT", ySlider, "RIGHT", 6, 0)
    yValue:SetText(tostring(SQPSettings.offsetY))

    local yReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('offsetY', 3)
        ySlider:SetValue(3)
        yValue:SetText("3")
        SQP:RefreshAllNameplates()
    end)
    yReset:SetPoint("LEFT", yValue, "RIGHT", 4, 0)

    ySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetY', value)
        yValue:SetText(tostring(value))
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 48

    -- Nameplate side
    local anchorLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    anchorLabel:SetPoint("TOPLEFT", 20, yOffset)
    anchorLabel:SetText(self.L["OPTIONS_ANCHOR"] or "Nameplate Side")
    yOffset = yOffset - 22

    local leftBtn  = self:CreateStyledButton(leftColumn, self.L["Left Side"],  90, 25)
    local rightBtn = self:CreateStyledButton(leftColumn, self.L["Right Side"], 90, 25)
    leftBtn:SetPoint("TOPLEFT", 20, yOffset)
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

    local anchorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    anchorReset:SetPoint("LEFT", rightBtn, "RIGHT", 6, 0)

    -- ── RIGHT COLUMN: Scale + Display Style ──────────────────────────────────
    local rightYOffset = -15

    local styleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    styleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    styleLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_STYLE"] or "Icon Style") .. "|r")
    rightYOffset = rightYOffset - 22

    -- Global Scale
    local scaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    scaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    scaleLabel:SetText(self.L["OPTIONS_GLOBAL_SCALE"] or "Global Scale")

    local scaleSlider = self:CreateStyledSlider(rightColumn, 0.5, 3.0, 0.1, 160)
    scaleSlider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -5)
    scaleSlider:SetValue(SQPSettings.scale)
    self.optionControls.scale = scaleSlider

    local scaleValue = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    scaleValue:SetPoint("LEFT", scaleSlider, "RIGHT", 6, 0)
    scaleValue:SetText(format("%.1f", SQPSettings.scale))

    local scaleReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('scale', 1.1)
        scaleSlider:SetValue(1.1)
        scaleValue:SetText("1.1")
        SQP:RefreshAllNameplates()
    end)
    scaleReset:SetPoint("LEFT", scaleValue, "RIGHT", 4, 0)

    scaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        SQP:SetSetting('scale', value)
        scaleValue:SetText(format("%.1f", value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 48

    -- Display Style (also available on Kill / Loot / Percent tabs)
    rightYOffset = self:CreateDisplayStyleSection(rightColumn, nil, nil, rightYOffset)
end
