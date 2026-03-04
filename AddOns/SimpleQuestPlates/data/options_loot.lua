--=====================================================================================
-- RGX | Simple Quest Plates! - options_loot.lua

-- Author: DonnieDice
-- Description: Loot icon tab (visibility, display style, animate, color, tinting, size, font)
--=====================================================================================

local addonName, SQP = ...

function SQP:CreateLootOptions(content)
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
            if SQP.previewFrame and SQP.previewFrame.activateLootMode then
                SQP.previewFrame.activateLootMode()
            end
            SQP:RefreshAllNameplates()
        end)
        return yOff - 36
    end

    local function ActivateLoot()
        if SQP.previewFrame and SQP.previewFrame.activateLootMode then
            SQP.previewFrame.activateLootMode()
        end
    end

    -- ── LEFT COLUMN ────────────────────────────────────────────────────────────
    local yOffset = -15

    local header = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetPoint("TOPLEFT", 20, yOffset)
    header:SetText(self.L["|cff58be81Loot Icon|r"])
    yOffset = yOffset - 22

    -- Show Loot Icon
    local showFrame = self:CreateStyledCheckbox(leftColumn, self.L["Show Loot Icon"])
    showFrame:SetPoint("TOPLEFT", 20, yOffset)
    showFrame.checkbox:SetChecked(SQPSettings.showLootIcon ~= false)
    self.optionControls.showLootIcon = showFrame.checkbox
    showFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showLootIcon', self:GetChecked())
        ActivateLoot()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 30

    -- Display Style
    yOffset = self:CreateDisplayStyleSection(leftColumn, "loot", ActivateLoot, yOffset)

    -- Animate Task Icons
    local animHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    animHeader:SetPoint("TOPLEFT", 20, yOffset)
    animHeader:SetText(self.L["|cff58be81Animate|r"])
    yOffset = yOffset - 20

    local animFrame = self:CreateStyledCheckbox(leftColumn, self.L["Animate Task Icons"])
    animFrame:SetPoint("TOPLEFT", 20, yOffset)
    animFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
    self.optionControls.animateQuestIconsLoot = animFrame.checkbox
    animFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('animateQuestIcons', self:GetChecked())
        if SQP.optionControls and SQP.optionControls.animateQuestIcons then
            SQP.optionControls.animateQuestIcons:SetChecked(self:GetChecked())
        end
        if SQP.optionControls and SQP.optionControls.animateQuestIconsPercent then
            SQP.optionControls.animateQuestIconsPercent:SetChecked(self:GetChecked())
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    local animMainFrame = self:CreateStyledCheckbox(leftColumn, self.L["Animate Main Icon"])
    animMainFrame:SetPoint("TOPLEFT", 20, yOffset)
    animMainFrame.checkbox:SetChecked(SQPSettings.lootAnimateMain == true)
    self.optionControls.lootAnimateMain = animMainFrame.checkbox
    animMainFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('lootAnimateMain', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    local lootAnimIntensityLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    lootAnimIntensityLabel:SetPoint("TOPLEFT", 20, yOffset)
    lootAnimIntensityLabel:SetText(string.format(self.L["Intensity: %d%%"], SQPSettings.lootAnimationIntensity or 100))
    self.optionControls.lootAnimationIntensityLabel = lootAnimIntensityLabel

    local lootAnimIntensitySlider = self:CreateStyledSlider(leftColumn, 25, 200, 5, 160)
    lootAnimIntensitySlider:SetPoint("TOPLEFT", lootAnimIntensityLabel, "BOTTOMLEFT", 0, -4)
    lootAnimIntensitySlider:SetValue(SQPSettings.lootAnimationIntensity or 100)
    self.optionControls.lootAnimationIntensity = lootAnimIntensitySlider

    local lootAnimIntensityReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('lootAnimationIntensity', 100)
        lootAnimIntensitySlider:SetValue(100)
        lootAnimIntensityLabel:SetText(self.L["Intensity: 100%"])
        ActivateLoot()
        SQP:RefreshAllNameplates()
    end)
    lootAnimIntensityReset:SetPoint("LEFT", lootAnimIntensitySlider, "RIGHT", 5, 0)

    lootAnimIntensitySlider:SetScript("OnValueChanged", function(self, newVal)
        newVal = math.floor(newVal / 5 + 0.5) * 5
        SQP:SetSetting('lootAnimationIntensity', newVal)
        lootAnimIntensityLabel:SetText(string.format(self.L["Intensity: %d%%"], newVal))
        ActivateLoot()
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 44

    -- Loot Color
    local colorHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorHeader:SetPoint("TOPLEFT", 20, yOffset)
    colorHeader:SetText(self.L["|cff58be81Color|r"])
    yOffset = yOffset - 20

    local lootDefault = {0.2, 1, 0.2}
    local colorBtn = CreateFrame("Button", nil, leftColumn)
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("TOPLEFT", 20, yOffset)
    local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
    cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
    local sw = colorBtn:CreateTexture(nil, "ARTWORK")
    sw:SetSize(16, 16); sw:SetPoint("CENTER")
    sw:SetColorTexture(unpack(SQPSettings.itemColor or lootDefault))
    SQP.optionControls.lootColorSwatch = sw

    local colorLbl = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    colorLbl:SetText(self.L["Loot Color"])

    local colorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('itemColor', {unpack(lootDefault)})
        sw:SetColorTexture(unpack(lootDefault)); SQP:RefreshAllNameplates()
    end)
    colorReset:SetPoint("LEFT", colorLbl, "RIGHT", 5, 0)

    colorBtn:SetScript("OnClick", function()
        ActivateLoot()
        local r, g, b = unpack(SQPSettings.itemColor or lootDefault)
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('itemColor', {nr, ng, nb}); sw:SetColorTexture(nr, ng, nb)
            SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('itemColor', {r, g, b}); sw:SetColorTexture(r, g, b)
            SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    yOffset = yOffset - 34

    -- Loot Icon Tinting (mini icon, compact inline row)
    yOffset = self:CreateMiniIconTintSection(leftColumn, "loot", ActivateLoot, yOffset)

    -- ── RIGHT COLUMN ──────────────────────────────────────────────────────────
    local rightYOffset = -15

    local posHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    posHeader:SetText(self.L["|cff58be81Size & Position|r"])
    rightYOffset = rightYOffset - 22

    rightYOffset = MakeSlider(rightColumn, self.L["Size"],     "lootIconSize",    14,   8,  40, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, self.L["Offset X"], "lootIconOffsetX", -38, -80, 80, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, self.L["Offset Y"], "lootIconOffsetY",  16, -80, 80, rightYOffset)

    rightYOffset = self:CreateFontSection(rightColumn, "loot", rightYOffset, "SQPLootFontDropdown", ActivateLoot)

    -- Reset this tab to loot defaults
    rightYOffset = rightYOffset - 14
    local resetBtn = self:CreateStyledButton(rightColumn, self.L["Reset Loot Settings"], 160, 22)
    resetBtn:SetPoint("TOPLEFT", 20, rightYOffset)
    resetBtn:SetScript("OnClick", function()
        local D = SQP.DEFAULTS
        local oc = SQP.optionControls
        SQP:SetSetting('showLootIcon',      D.showLootIcon)
        SQP:SetSetting('lootShowIconBackground', D.lootShowIconBackground)
        SQP:SetSetting('animateQuestIcons', D.animateQuestIcons)
        SQP:SetSetting('lootAnimateMain',   D.lootAnimateMain)
        SQP:SetSetting('lootAnimationIntensity', D.lootAnimationIntensity)
        SQP:SetSetting('itemColor',         {unpack(D.itemColor)})
        SQP:SetSetting('lootTintIcon',      D.lootTintIcon)
        SQP:SetSetting('lootTintIconColor', {unpack(D.lootTintIconColor)})
        SQP:SetSetting('lootIconSize',      D.lootIconSize)
        SQP:SetSetting('lootIconOffsetX',   D.lootIconOffsetX)
        SQP:SetSetting('lootIconOffsetY',   D.lootIconOffsetY)
        SQP:SetSetting('lootFontSize',      D.lootFontSize)
        SQP:SetSetting('lootFontFamily',    D.lootFontFamily)
        -- Update checkboxes
        if oc.showLootIcon         then oc.showLootIcon:SetChecked(D.showLootIcon) end
        if oc.lootShowIconBackgroundStyleUpdater then oc.lootShowIconBackgroundStyleUpdater() end
        if oc.animateQuestIconsLoot then oc.animateQuestIconsLoot:SetChecked(D.animateQuestIcons) end
        if oc.animateQuestIcons then oc.animateQuestIcons:SetChecked(D.animateQuestIcons) end
        if oc.animateQuestIconsPercent then oc.animateQuestIconsPercent:SetChecked(D.animateQuestIcons) end
        if oc.lootAnimateMain      then oc.lootAnimateMain:SetChecked(D.lootAnimateMain) end
        if oc.lootAnimationIntensity then oc.lootAnimationIntensity:SetValue(D.lootAnimationIntensity) end
        if oc.lootAnimationIntensityLabel then
            oc.lootAnimationIntensityLabel:SetText(string.format(self.L["Intensity: %d%%"], D.lootAnimationIntensity))
        end
        if oc.lootTintIcon         then oc.lootTintIcon:SetChecked(D.lootTintIcon) end
        -- Update color swatches
        if oc.lootColorSwatch              then oc.lootColorSwatch:SetColorTexture(unpack(D.itemColor)) end
        if oc.lootTintIconColorSwatch      then oc.lootTintIconColorSwatch:SetColorTexture(unpack(D.lootTintIconColor)) end
        if oc.lootTintIconAlphaUpdate      then oc.lootTintIconAlphaUpdate() end
        -- Update sliders
        if oc.lootIconSize    then oc.lootIconSize:SetValue(D.lootIconSize) end
        if oc.lootIconOffsetX then oc.lootIconOffsetX:SetValue(D.lootIconOffsetX) end
        if oc.lootIconOffsetY then oc.lootIconOffsetY:SetValue(D.lootIconOffsetY) end
        if oc.lootFontSize    then oc.lootFontSize:SetValue(D.lootFontSize) end
        if oc.lootFontFamily and UIDropDownMenu_SetText then UIDropDownMenu_SetText(oc.lootFontFamily, "Friz Quadrata") end
        SQP:RefreshAllNameplates()
        ActivateLoot()
    end)
end
