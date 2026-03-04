--=====================================================================================
-- RGX | Simple Quest Plates! - options_kill.lua

-- Author: DonnieDice
-- Description: Kill icon tab (visibility, display style, animate, color, tinting, size, font)
--=====================================================================================

local addonName, SQP = ...

function SQP:CreateKillOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

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
            if SQP.previewFrame and SQP.previewFrame.activateKillMode then
                SQP.previewFrame.activateKillMode()
            end
            SQP:RefreshAllNameplates()
        end)
        return yOff - 36
    end

    local function ActivateKill()
        if SQP.previewFrame and SQP.previewFrame.activateKillMode then
            SQP.previewFrame.activateKillMode()
        end
    end

    -- ── LEFT COLUMN ────────────────────────────────────────────────────────────
    local yOffset = -15

    local header = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetPoint("TOPLEFT", 20, yOffset)
    header:SetText("|cff58be81Kill Icon|r")
    yOffset = yOffset - 22

    -- Show Kill Icon
    local showFrame = self:CreateStyledCheckbox(leftColumn, "Show Kill Icon")
    showFrame:SetPoint("TOPLEFT", 20, yOffset)
    showFrame.checkbox:SetChecked(SQPSettings.showKillIcon ~= false)
    self.optionControls.showKillIcon = showFrame.checkbox
    showFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showKillIcon', self:GetChecked())
        ActivateKill()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 30

    -- Display Style
    yOffset = self:CreateDisplayStyleSection(leftColumn, "kill", ActivateKill, yOffset)

    -- Animate Task Icons (kill + loot mini icons)
    local animHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    animHeader:SetPoint("TOPLEFT", 20, yOffset)
    animHeader:SetText("|cff58be81Animate|r")
    yOffset = yOffset - 20

    local animFrame = self:CreateStyledCheckbox(leftColumn, "Animate Task Icons")
    animFrame:SetPoint("TOPLEFT", 20, yOffset)
    animFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
    self.optionControls.animateQuestIcons = animFrame.checkbox
    animFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('animateQuestIcons', self:GetChecked())
        if SQP.optionControls and SQP.optionControls.animateQuestIconsLoot then
            SQP.optionControls.animateQuestIconsLoot:SetChecked(self:GetChecked())
        end
        if SQP.optionControls and SQP.optionControls.animateQuestIconsPercent then
            SQP.optionControls.animateQuestIconsPercent:SetChecked(self:GetChecked())
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    local animMainFrame = self:CreateStyledCheckbox(leftColumn, "Animate Main Icon")
    animMainFrame:SetPoint("TOPLEFT", 20, yOffset)
    animMainFrame.checkbox:SetChecked(SQPSettings.killAnimateMain == true)
    self.optionControls.killAnimateMain = animMainFrame.checkbox
    animMainFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('killAnimateMain', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    local killAnimIntensityLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    killAnimIntensityLabel:SetPoint("TOPLEFT", 20, yOffset)
    killAnimIntensityLabel:SetText(string.format("Intensity: %d%%", SQPSettings.killAnimationIntensity or 100))
    self.optionControls.killAnimationIntensityLabel = killAnimIntensityLabel

    local killAnimIntensitySlider = self:CreateStyledSlider(leftColumn, 25, 200, 5, 160)
    killAnimIntensitySlider:SetPoint("TOPLEFT", killAnimIntensityLabel, "BOTTOMLEFT", 0, -4)
    killAnimIntensitySlider:SetValue(SQPSettings.killAnimationIntensity or 100)
    self.optionControls.killAnimationIntensity = killAnimIntensitySlider

    local killAnimIntensityReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('killAnimationIntensity', 100)
        killAnimIntensitySlider:SetValue(100)
        killAnimIntensityLabel:SetText("Intensity: 100%")
        ActivateKill()
        SQP:RefreshAllNameplates()
    end)
    killAnimIntensityReset:SetPoint("LEFT", killAnimIntensitySlider, "RIGHT", 5, 0)

    killAnimIntensitySlider:SetScript("OnValueChanged", function(self, newVal)
        newVal = math.floor(newVal / 5 + 0.5) * 5
        SQP:SetSetting('killAnimationIntensity', newVal)
        killAnimIntensityLabel:SetText(string.format("Intensity: %d%%", newVal))
        ActivateKill()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 44

    -- Kill Color
    local colorHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorHeader:SetPoint("TOPLEFT", 20, yOffset)
    colorHeader:SetText("|cff58be81Color|r")
    yOffset = yOffset - 20

    local killDefault = {1, 0.82, 0}
    local colorBtn = CreateFrame("Button", nil, leftColumn)
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("TOPLEFT", 20, yOffset)
    local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
    cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
    local sw = colorBtn:CreateTexture(nil, "ARTWORK")
    sw:SetSize(16, 16); sw:SetPoint("CENTER")
    sw:SetColorTexture(unpack(SQPSettings.killColor or killDefault))
    SQP.optionControls.killColorSwatch = sw

    local colorLbl = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    colorLbl:SetText("Kill Color")

    local colorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('killColor', {unpack(killDefault)})
        sw:SetColorTexture(unpack(killDefault)); SQP:RefreshAllNameplates()
    end)
    colorReset:SetPoint("LEFT", colorLbl, "RIGHT", 5, 0)

    colorBtn:SetScript("OnClick", function()
        ActivateKill()
        local r, g, b = unpack(SQPSettings.killColor or killDefault)
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('killColor', {nr, ng, nb}); sw:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('killColor', {r, g, b}); sw:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    yOffset = yOffset - 34

    -- Kill Icon Tinting (mini icon, compact inline row)
    yOffset = self:CreateMiniIconTintSection(leftColumn, "kill", ActivateKill, yOffset)

    -- ── RIGHT COLUMN ──────────────────────────────────────────────────────────
    local rightYOffset = -15

    local posHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    posHeader:SetText("|cff58be81Size & Position|r")
    rightYOffset = rightYOffset - 22

    rightYOffset = MakeSlider(rightColumn, "Size",     "killIconSize",    14,  8,   40, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, "Offset X", "killIconOffsetX",  2, -80,  80, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, "Offset Y", "killIconOffsetY", 15, -80,  80, rightYOffset)

    rightYOffset = self:CreateFontSection(rightColumn, "kill", rightYOffset, "SQPKillFontDropdown", ActivateKill)

    -- Reset this tab to kill defaults
    rightYOffset = rightYOffset - 14
    local resetBtn = self:CreateStyledButton(rightColumn, "Reset Kill Settings", 160, 22)
    resetBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    resetBtn:SetScript("OnClick", function()
        local D = SQP.DEFAULTS
        local oc = SQP.optionControls
        SQP:SetSetting('showKillIcon',      D.showKillIcon)
        SQP:SetSetting('killShowIconBackground', D.killShowIconBackground)
        SQP:SetSetting('animateQuestIcons', D.animateQuestIcons)
        SQP:SetSetting('killAnimateMain',   D.killAnimateMain)
        SQP:SetSetting('killAnimationIntensity', D.killAnimationIntensity)
        SQP:SetSetting('killColor',         {unpack(D.killColor)})
        SQP:SetSetting('killTintIcon',      D.killTintIcon)
        SQP:SetSetting('killTintIconColor', {unpack(D.killTintIconColor)})
        SQP:SetSetting('killFontSize',      D.killFontSize)
        SQP:SetSetting('killFontFamily',    D.killFontFamily)
        -- Update checkboxes
        if oc.showKillIcon      then oc.showKillIcon:SetChecked(D.showKillIcon) end
        if oc.killShowIconBackgroundStyleUpdater then oc.killShowIconBackgroundStyleUpdater() end
        if oc.animateQuestIcons then oc.animateQuestIcons:SetChecked(D.animateQuestIcons) end
        if oc.animateQuestIconsLoot then oc.animateQuestIconsLoot:SetChecked(D.animateQuestIcons) end
        if oc.animateQuestIconsPercent then oc.animateQuestIconsPercent:SetChecked(D.animateQuestIcons) end
        if oc.killAnimateMain   then oc.killAnimateMain:SetChecked(D.killAnimateMain) end
        if oc.killAnimationIntensity then oc.killAnimationIntensity:SetValue(D.killAnimationIntensity) end
        if oc.killAnimationIntensityLabel then
            oc.killAnimationIntensityLabel:SetText(string.format("Intensity: %d%%", D.killAnimationIntensity))
        end
        if oc.killTintIcon      then oc.killTintIcon:SetChecked(D.killTintIcon) end
        -- Update color swatches
        if oc.killColorSwatch              then oc.killColorSwatch:SetColorTexture(unpack(D.killColor)) end
        if oc.killTintIconColorSwatch      then oc.killTintIconColorSwatch:SetColorTexture(unpack(D.killTintIconColor)) end
        if oc.killTintIconAlphaUpdate      then oc.killTintIconAlphaUpdate() end
        -- Update sliders (OnValueChanged fires and updates label + setting)
        if oc.killIconSize    then oc.killIconSize:SetValue(D.killIconSize) end
        if oc.killIconOffsetX then oc.killIconOffsetX:SetValue(D.killIconOffsetX) end
        if oc.killIconOffsetY then oc.killIconOffsetY:SetValue(D.killIconOffsetY) end
        if oc.killFontSize    then oc.killFontSize:SetValue(D.killFontSize) end
        if oc.killFontFamily and UIDropDownMenu_SetText then UIDropDownMenu_SetText(oc.killFontFamily, "Friz Quadrata") end
        SQP:RefreshAllNameplates()
        ActivateKill()
    end)
end
