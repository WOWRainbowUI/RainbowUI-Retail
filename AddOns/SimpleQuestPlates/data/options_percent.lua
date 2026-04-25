--=====================================================================================
-- RGX | Simple Quest Plates! - options_percent.lua

-- Author: DonnieDice
-- Description: Percent quest tab (visibility, display style, color, animate, tinting, position, font)
--=====================================================================================

local addonName, SQP = ...

function SQP:CreatePercentOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(288)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 14, 0)

    -- ── Slider helper ─────────────────────────────────────────────────────────
    local function MakeSlider(parent, labelText, key, defaultVal, minVal, maxVal, yOff)
        local val = SQPSettings[key] ~= nil and SQPSettings[key] or defaultVal
        local lbl = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", 20, yOff)
        lbl:SetText(string.format("%s: %d", labelText, val))
        SQP.optionControls[key .. "Label"] = lbl

        local sl = SQP:CreateStyledSlider(parent, minVal, maxVal, 1, 160)
        sl:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -4)
        sl:SetValue(val)
        SQP.optionControls[key] = sl

        local resetBtn = SQP:CreateInlineResetButton(parent, function()
            SQP:SetSetting(key, defaultVal)
            sl:SetValue(defaultVal)
            lbl:SetText(string.format("%s: %d", labelText, defaultVal))
            SQP:RefreshAllNameplates()
        end)
        resetBtn:SetPoint("LEFT", sl, "RIGHT", 5, 0)

        sl:SetScript("OnValueChanged", function(self, newVal)
            newVal = math.floor(newVal + 0.5)
            SQP:SetSetting(key, newVal)
            lbl:SetText(string.format("%s: %d", labelText, newVal))
            if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
                SQP.previewFrame.activatePercentMode()
            end
            SQP:RefreshAllNameplates()
        end)
        return yOff - 36
    end

    local function ActivatePercent()
        if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
            SQP.previewFrame.activatePercentMode()
        end
    end

    -- ── LEFT COLUMN ────────────────────────────────────────────────────────────
    local yOffset = -15

    local header = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    header:SetPoint("TOPLEFT", 20, yOffset)
    header:SetText(self.L["|cff58be81Percent Icon|r"])
    yOffset = yOffset - 16

    -- Show Percent Icon
    local showFrame = self:CreateStyledCheckbox(leftColumn, self.L["Show Percent Icon"])
    showFrame:SetPoint("TOPLEFT", 20, yOffset)
    showFrame.checkbox:SetChecked(SQPSettings.showPercentIcon ~= false)
    self.optionControls.showPercentIcon = showFrame.checkbox
    showFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showPercentIcon', self:GetChecked())
        ActivatePercent()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 24

    -- Display Style
    yOffset = self:CreateDisplayStyleSection(leftColumn, "percent", ActivatePercent, yOffset)

    -- Animate
    local animHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    animHeader:SetPoint("TOPLEFT", 20, yOffset)
    animHeader:SetText(self.L["|cff58be81Animate|r"])
    yOffset = yOffset - 16

    local animTaskFrame = self:CreateStyledCheckbox(leftColumn, self.L["Animate Task Icons"])
    animTaskFrame:SetPoint("TOPLEFT", 20, yOffset)
    animTaskFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
    self.optionControls.animateQuestIconsPercent = animTaskFrame.checkbox
    animTaskFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('animateQuestIcons', self:GetChecked())
        if SQP.optionControls then
            if SQP.optionControls.animateQuestIcons then
                SQP.optionControls.animateQuestIcons:SetChecked(self:GetChecked())
            end
            if SQP.optionControls.animateQuestIconsLoot then
                SQP.optionControls.animateQuestIconsLoot:SetChecked(self:GetChecked())
            end
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    local animFrame = self:CreateStyledCheckbox(leftColumn, self.L["Animate Main Icon"])
    animFrame:SetPoint("TOPLEFT", 20, yOffset)
    animFrame.checkbox:SetChecked(SQPSettings.percentAnimateMain == true)
    self.optionControls.percentAnimateMain = animFrame.checkbox
    animFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('percentAnimateMain', self:GetChecked())
        ActivatePercent()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    local percentAnimIntensityLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    percentAnimIntensityLabel:SetPoint("TOPLEFT", 20, yOffset)
    percentAnimIntensityLabel:SetText(string.format(self.L["Intensity: %d%%"], SQPSettings.percentAnimationIntensity or 100))
    self.optionControls.percentAnimationIntensityLabel = percentAnimIntensityLabel

    local percentAnimIntensitySlider = self:CreateStyledSlider(leftColumn, 25, 200, 5, 160)
    percentAnimIntensitySlider:SetPoint("TOPLEFT", percentAnimIntensityLabel, "BOTTOMLEFT", 0, -4)
    percentAnimIntensitySlider:SetValue(SQPSettings.percentAnimationIntensity or 100)
    self.optionControls.percentAnimationIntensity = percentAnimIntensitySlider

    local percentAnimIntensityReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('percentAnimationIntensity', 100)
        percentAnimIntensitySlider:SetValue(100)
        percentAnimIntensityLabel:SetText(self.L["Intensity: 100%"])
        ActivatePercent()
        SQP:RefreshAllNameplates()
    end)
    percentAnimIntensityReset:SetPoint("LEFT", percentAnimIntensitySlider, "RIGHT", 5, 0)

    percentAnimIntensitySlider:SetScript("OnValueChanged", function(self, newVal)
        newVal = math.floor(newVal / 5 + 0.5) * 5
        SQP:SetSetting('percentAnimationIntensity', newVal)
        percentAnimIntensityLabel:SetText(string.format(self.L["Intensity: %d%%"], newVal))
        ActivatePercent()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 38

    -- Percent Color
    local colorHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    colorHeader:SetPoint("TOPLEFT", 20, yOffset)
    colorHeader:SetText(self.L["|cff58be81Color|r"])
    yOffset = yOffset - 16

    local pctDefault = {0.2, 1, 1}
    local colorBtn = CreateFrame("Button", nil, leftColumn)
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("TOPLEFT", 20, yOffset)
    local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
    cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
    local sw = colorBtn:CreateTexture(nil, "ARTWORK")
    sw:SetSize(16, 16); sw:SetPoint("CENTER")
    sw:SetColorTexture(unpack(SQPSettings.percentColor or pctDefault))
    SQP.optionControls.percentColorSwatch = sw

    local colorLbl = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    colorLbl:SetText(self.L["Percent Color"])

    local colorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('percentColor', {unpack(pctDefault)})
        sw:SetColorTexture(unpack(pctDefault)); SQP:RefreshAllNameplates()
    end)
    colorReset:SetPoint("LEFT", colorLbl, "RIGHT", 5, 0)

    colorBtn:SetScript("OnClick", function()
        ActivatePercent()
        local r, g, b = unpack(SQPSettings.percentColor or pctDefault)
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('percentColor', {nr, ng, nb}); sw:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('percentColor', {r, g, b}); sw:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    yOffset = yOffset - 28

    -- ── RIGHT COLUMN ──────────────────────────────────────────────────────────
    -- Percent Sign Tinting (compact inline row)
    yOffset = self:CreateMiniIconTintSection(leftColumn, "percent", ActivatePercent, yOffset)

    local rightYOffset = -15

    local posHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    posHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    posHeader:SetText(self.L["|cff58be81Position|r"])
    rightYOffset = rightYOffset - 16

    rightYOffset = MakeSlider(rightColumn, self.L["Offset X"], "percentIconOffsetX", 18, -80, 80, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, self.L["Offset Y"], "percentIconOffsetY",  0, -80, 80, rightYOffset)

    rightYOffset = self:CreateFontSection(rightColumn, "percent", rightYOffset, ActivatePercent)

    -- Reset this tab to percent defaults
    rightYOffset = rightYOffset - 14
    local resetBtn = self:CreateStyledButton(rightColumn, self.L["Reset Percent Settings"], 160, 22)
    resetBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    resetBtn:SetScript("OnClick", function()
        local D = SQP.DEFAULTS
        local oc = SQP.optionControls
        SQP:SetSetting('showPercentIcon', D.showPercentIcon)
        SQP:SetSetting('percentShowIconBackground', D.percentShowIconBackground)
        SQP:SetSetting('animateQuestIcons', D.animateQuestIcons)
        SQP:SetSetting('percentAnimateMain', D.percentAnimateMain)
        SQP:SetSetting('percentAnimationIntensity', D.percentAnimationIntensity)
        SQP:SetSetting('percentColor', {unpack(D.percentColor)})
        SQP:SetSetting('percentTintIcon', D.percentTintIcon)
        SQP:SetSetting('percentTintIconColor', {unpack(D.percentTintIconColor)})
        SQP:SetSetting('percentFontSize', D.percentFontSize)
        SQP:SetSetting('percentFontFamily', D.percentFontFamily)
        SQP:SetSetting('percentIconOffsetX', D.percentIconOffsetX)
        SQP:SetSetting('percentIconOffsetY', D.percentIconOffsetY)
        if oc.showPercentIcon then oc.showPercentIcon:SetChecked(D.showPercentIcon) end
        if oc.percentShowIconBackgroundStyleUpdater then oc.percentShowIconBackgroundStyleUpdater() end
        if oc.animateQuestIconsPercent then oc.animateQuestIconsPercent:SetChecked(D.animateQuestIcons) end
        if oc.animateQuestIcons then oc.animateQuestIcons:SetChecked(D.animateQuestIcons) end
        if oc.animateQuestIconsLoot then oc.animateQuestIconsLoot:SetChecked(D.animateQuestIcons) end
        if oc.percentAnimateMain then oc.percentAnimateMain:SetChecked(D.percentAnimateMain) end
        if oc.percentAnimationIntensity then oc.percentAnimationIntensity:SetValue(D.percentAnimationIntensity) end
        if oc.percentAnimationIntensityLabel then
            oc.percentAnimationIntensityLabel:SetText(string.format(self.L["Intensity: %d%%"], D.percentAnimationIntensity))
        end
        if oc.percentTintIcon then oc.percentTintIcon:SetChecked(D.percentTintIcon) end
        if oc.percentColorSwatch then oc.percentColorSwatch:SetColorTexture(unpack(D.percentColor)) end
        if oc.percentTintIconColorSwatch then oc.percentTintIconColorSwatch:SetColorTexture(unpack(D.percentTintIconColor)) end
        if oc.percentTintIconAlphaUpdate then oc.percentTintIconAlphaUpdate() end
        if oc.percentIconOffsetX then oc.percentIconOffsetX:SetValue(D.percentIconOffsetX) end
        if oc.percentIconOffsetY then oc.percentIconOffsetY:SetValue(D.percentIconOffsetY) end
        if oc.percentFontSize then oc.percentFontSize:SetValue(D.percentFontSize) end
        if oc.percentFontFamily and type(oc.percentFontFamily.Reset) == "function" then
            oc.percentFontFamily:Reset()
        elseif oc.percentFontFamily and type(oc.percentFontFamily.SetPath) == "function" then
            oc.percentFontFamily:SetPath(D.percentFontFamily)
        elseif oc.percentFontFamily and UIDropDownMenu_SetText then
            UIDropDownMenu_SetText(oc.percentFontFamily, "Friz Quadrata")
        end
        SQP:RefreshAllNameplates()
        ActivatePercent()
    end)
end
