--=====================================================================================
-- RGX | Simple Quest Plates! - options_icon.lua

-- Author: DonnieDice
-- Description: Main icon options tab (position + style)
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

    local xSlider = self:CreateStyledSlider(leftColumn, -50, 50, 1, 160)
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

    local ySlider = self:CreateStyledSlider(leftColumn, -50, 50, 1, 160)
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

    local leftBtn  = self:CreateStyledButton(leftColumn, "Left Side",  90, 25)
    local rightBtn = self:CreateStyledButton(leftColumn, "Right Side", 90, 25)
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

    -- Nameplate side reset (small button to the right of both side buttons)
    local anchorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    anchorReset:SetPoint("LEFT", rightBtn, "RIGHT", 6, 0)

    -- ── RIGHT COLUMN: Style ──────────────────────────────────────────────────
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

    -- Display Style (Icon / Text)
    local styleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    styleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    styleLabel:SetText("Display Style")
    rightYOffset = rightYOffset - 22

    local iconStyleBtn = self:CreateStyledButton(rightColumn, "Icon", 75, 25)
    local textStyleBtn = self:CreateStyledButton(rightColumn, "Text", 75, 25)
    iconStyleBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    textStyleBtn:SetPoint("LEFT", iconStyleBtn, "RIGHT", 8, 0)

    local function UpdateStyleButtons()
        iconStyleBtn:SetAlpha(SQPSettings.showIconBackground ~= false and 1 or 0.6)
        textStyleBtn:SetAlpha(SQPSettings.showIconBackground == false and 1 or 0.6)
    end
    UpdateStyleButtons()
    self.optionControls.updateStyleButtons = UpdateStyleButtons

    iconStyleBtn:SetScript("OnClick", function()
        SQP:SetSetting('showIconBackground', true)
        UpdateStyleButtons()
        SQP:RefreshAllNameplates()
    end)
    textStyleBtn:SetScript("OnClick", function()
        SQP:SetSetting('showIconBackground', false)
        UpdateStyleButtons()
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 34

    -- Animate Main Icon
    local animateFrame = self:CreateStyledCheckbox(rightColumn,
        self.L["OPTIONS_ANIMATE_ICON"] or "Animate Main Icon")
    animateFrame:SetPoint("TOPLEFT", 20, rightYOffset)
    animateFrame.checkbox:SetChecked(SQPSettings.animateQuestIcon == true)
    self.optionControls.animateQuestIcon = animateFrame.checkbox
    animateFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('animateQuestIcon', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 34

    -- Main Icon Tinting
    local tintHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tintHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    tintHeader:SetText("|cff58be81Main Icon Tinting|r")
    rightYOffset = rightYOffset - 22

    local tintCbFrame = self:CreateStyledCheckbox(rightColumn, "Enable Tinting")
    tintCbFrame:SetPoint("TOPLEFT", 20, rightYOffset)
    tintCbFrame.checkbox:SetChecked(SQPSettings.iconTintMain == true)
    self.optionControls.iconTintMain = tintCbFrame.checkbox
    rightYOffset = rightYOffset - 26

    local tintColorBtn = CreateFrame("Button", nil, rightColumn)
    tintColorBtn:SetSize(20, 20)
    tintColorBtn:SetPoint("TOPLEFT", 30, rightYOffset)
    local tintBg = tintColorBtn:CreateTexture(nil, "BACKGROUND")
    tintBg:SetAllPoints(); tintBg:SetColorTexture(0, 0, 0, 1)
    local tintSw = tintColorBtn:CreateTexture(nil, "ARTWORK")
    tintSw:SetSize(16, 16); tintSw:SetPoint("CENTER")
    tintSw:SetColorTexture(unpack(SQPSettings.iconTintMainColor or {1, 1, 1}))

    local tintColorLbl = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tintColorLbl:SetPoint("LEFT", tintColorBtn, "RIGHT", 6, 0)
    tintColorLbl:SetText("Tint Color")

    local tintReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('iconTintMainColor', {1, 1, 1})
        tintSw:SetColorTexture(1, 1, 1); SQP:RefreshAllNameplates()
    end)
    tintReset:SetPoint("LEFT", tintColorLbl, "RIGHT", 6, 0)

    local function UpdateTintAlpha()
        local a = SQPSettings.iconTintMain == true and 1 or 0.4
        tintColorBtn:SetAlpha(a); tintColorLbl:SetAlpha(a); tintReset:SetAlpha(a * 0.7)
    end
    UpdateTintAlpha()

    tintCbFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('iconTintMain', self:GetChecked())
        UpdateTintAlpha(); SQP:RefreshAllNameplates()
    end)

    tintColorBtn:SetScript("OnClick", function()
        if not SQPSettings.iconTintMain then return end
        local r, g, b = unpack(SQPSettings.iconTintMainColor or {1, 1, 1})
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('iconTintMainColor', {nr, ng, nb})
            tintSw:SetColorTexture(nr, ng, nb); SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('iconTintMainColor', {r, g, b})
            tintSw:SetColorTexture(r, g, b); SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
end
