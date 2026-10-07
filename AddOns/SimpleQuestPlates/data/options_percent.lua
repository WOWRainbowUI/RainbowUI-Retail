--=====================================================================================
-- RGX | Simple Quest Plates! - options_percent.lua

-- Author: DonnieDice
-- Description: Percent tab — Display, Color, and Animation cards in framework columns
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global

function SQP:CreatePercentOptions(content)
    if not self.optionControls then self.optionControls = {} end

    -- Swap the two card stacks while retaining their internal ordering.
    local leftColumn, rightColumn = SQP:CreateOptionColumns(content)

    local function ActivatePercent()
        if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
            SQP.previewFrame.activatePercentMode()
        end
    end

    local function MakeSlider(parent, labelText, key, defaultVal, minVal, maxVal, yOff)
        local slider = SQP:CreateStyledSlider(parent, {
            key = key,
            label = labelText,
            min = minVal,
            max = maxVal,
            step = 1,
            default = defaultVal,
            storage = SQPSettings,
            width = 160,
            onChange = function(val)
                if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
                    SQP.previewFrame.activatePercentMode()
                end
                SQP:RefreshAllNameplates()
            end,
        })
        slider:SetPoint("TOPLEFT", 8, yOff)
        slider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yOff)
        SQP.optionControls[key] = slider
        SQP.optionControls[key .. "Label"] = slider.valueLabel
        return yOff - slider:GetHeight() - 8
    end

    -- RIGHT: task icon visibility, side, dimensions, tint, and reset.
    local taskCard = SQP:CreateCard(rightColumn, "Percent Task Icon")
    do
        local c = taskCard.content
        local yOffset = -8

        local showSwitch = self:CreateHeaderSwitch(taskCard, "showPercentIcon")
        SQP:SetControlTooltip(showSwitch, "Display toggle: show or hide the percent sign on quest nameplates.")
        yOffset = self:CreateMiniIconTintSection(c, "percent", ActivatePercent, yOffset)

        self:CreateIconSideSection(c, "percent", ActivatePercent, yOffset, { center = true })
        yOffset = yOffset - 24



        yOffset = MakeSlider(c, "Size",     "percentIconSize",    8,   8,  40, yOffset)
        yOffset = MakeSlider(c, "Offset X", "percentIconOffsetX",  0, -80, 80, yOffset)
        yOffset = MakeSlider(c, "Offset Y", "percentIconOffsetY",  0, -80, 80, yOffset)

        yOffset = yOffset - 10
        local resetBtn = self:CreateStyledButton(c, "Reset Percent Settings", 160, 22)
        resetBtn:SetPoint("TOP", c, "TOP", 0, yOffset)
        resetBtn:SetScript("OnClick", function()
            local D = SQP.DEFAULTS
            local oc = SQP.optionControls
            SQP:SetSetting('percentAnimationsEnabled', D.percentAnimationsEnabled)
            if oc.percentAnimationsEnabled then oc.percentAnimationsEnabled:SetChecked(D.percentAnimationsEnabled) end
            SQP:SetSetting('showPercentIcon', D.showPercentIcon)
            SQP:SetSetting('percentShowIconBackground', D.percentShowIconBackground)
            SQP:SetSetting('percentLevelChip', nil)
            SQP:SetSetting('percentSignSide', D.percentSignSide)
            SQP:SetSetting('animateQuestIcons', D.animateQuestIcons)
            SQP:SetSetting('percentAnimateMain', D.percentAnimateMain)
            SQP:SetSetting('percentAnimationIntensity', D.percentAnimationIntensity)
            SQP:SetSetting('percentColor', {unpack(D.percentColor)})
            SQP:SetSetting('percentTintIcon', D.percentTintIcon)
            SQP:SetSetting('percentTintIconColor', {unpack(D.percentTintIconColor)})
            SQP:SetSetting('percentIconSize', D.percentIconSize)
            SQP:SetSetting('percentFontSize', D.percentFontSize)
            SQP:SetSetting('percentFontFamily', D.percentFontFamily)
            SQP:SetSetting('percentIconOffsetX', D.percentIconOffsetX)
            SQP:SetSetting('percentIconOffsetY', D.percentIconOffsetY)
            if oc.showPercentIcon then oc.showPercentIcon:SetChecked(D.showPercentIcon) end
            if oc.percentShowIconBackgroundStyleUpdater then oc.percentShowIconBackgroundStyleUpdater() end
            if oc.updatePercentSignSideButtons then oc.updatePercentSignSideButtons() end
            if oc.animateQuestIconsPercent then oc.animateQuestIconsPercent:SetChecked(D.animateQuestIcons) end
            if oc.animateQuestIcons then oc.animateQuestIcons:SetChecked(D.animateQuestIcons) end
            if oc.animateQuestIconsLoot then oc.animateQuestIconsLoot:SetChecked(D.animateQuestIcons) end
            if oc.percentAnimateMain then oc.percentAnimateMain:SetChecked(D.percentAnimateMain) end
            if oc.percentAnimationIntensity and oc.percentAnimationIntensity.SetValue then
                oc.percentAnimationIntensity.SetValue(D.percentAnimationIntensity)
            end
            if oc.percentTintIcon then oc.percentTintIcon:SetChecked(D.percentTintIcon) end
            if oc.percentColorSwatch then oc.percentColorSwatch:SetColorTexture(unpack(D.percentColor)) end
            if oc.percentTintIconColorSwatch then oc.percentTintIconColorSwatch:SetColorTexture(unpack(D.percentTintIconColor)) end
            if oc.percentTintIconAlphaUpdate then oc.percentTintIconAlphaUpdate() end
            if oc.percentIconSize   then oc.percentIconSize.SetValue(D.percentIconSize) end
            if oc.percentIconOffsetX then oc.percentIconOffsetX.SetValue(D.percentIconOffsetX) end
            if oc.percentIconOffsetY then oc.percentIconOffsetY.SetValue(D.percentIconOffsetY) end
            if oc.percentFontSize then oc.percentFontSize.SetValue(SQP:GetSettingBaseline("percentFontSize")) end
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
        taskCard:FitContent()
    end

    -- LEFT: Main Icon first, then Animation.
    local mainCard = SQP:CreateCard(leftColumn, "Percent Main Icon")
    local animCard = SQP:CreateCard(leftColumn, "Percent Animation", { above = mainCard })
    SQP:CreateHeaderSwitch(animCard, "percentAnimationsEnabled")
    do
        local c = animCard.content
        local yOffset = -8

        local animFrame = self:CreateStyledCheckbox(c, "Animate Task Icons")
        animFrame:SetPoint("TOPLEFT", 8, yOffset - 26)
        animFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
        self.optionControls.animateQuestIconsPercent = animFrame.checkbox
        animFrame.checkbox:SetScript("OnClick", function(self)
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

        local animMainFrame = self:CreateStyledCheckbox(c, "Animate Main Icon")
        animMainFrame:SetPoint("TOPLEFT", 8, yOffset + 26)
        animMainFrame.checkbox:SetChecked(SQPSettings.percentAnimateMain == true)
        self.optionControls.percentAnimateMain = animMainFrame.checkbox
        animMainFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('percentAnimateMain', self:GetChecked())
            ActivatePercent()
            SQP:RefreshAllNameplates()
        end)
        yOffset = yOffset - 26

        local percentAnimIntensitySlider = SQP:CreateStyledSlider(c, {
            key = "percentAnimationIntensity",
            label = "Intensity",
            min = 25,
            max = 200,
            step = 5,
            default = 100,
            storage = SQPSettings,
            width = 160,
            suffix = "%",
            onChange = function(val)
                -- Cascade from the Global slider must not flip the preview.
                if not SQP._cascadingGlobalIntensity
                    and SQP.previewFrame and SQP.previewFrame.activatePercentMode then
                    SQP.previewFrame.activatePercentMode()
                elseif SQP.UpdatePreviewManually then
                    SQP:UpdatePreviewManually()
                end
                SQP:RefreshAllNameplates()
            end,
        })
        percentAnimIntensitySlider:SetPoint("TOPLEFT", 8, yOffset)
        percentAnimIntensitySlider:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
        self.optionControls.percentAnimationIntensity = percentAnimIntensitySlider
        self.optionControls.percentAnimationIntensityLabel = percentAnimIntensitySlider.valueLabel
        animCard:FitContent()
    end

    -- Populate the Main Icon card above Animation.
    do
        local c = mainCard.content
        local yOffset = -8
        local textRowY = yOffset
        yOffset = yOffset - 24

        -- Percent Color
        local colorHeader = c:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        SQP:ApplyDefaultFont(colorHeader)
        colorHeader:SetPoint("TOPLEFT", 8, yOffset)
        colorHeader:SetText("|cff58be81Color|r")
        yOffset = yOffset - 16

        local pctDefault = {0.2, 1, 1}
        local colorBtn = CreateFrame("Button", nil, c)
        colorBtn:SetSize(20, 20)
        colorBtn:SetPoint("TOPLEFT", 8, yOffset)
        local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
        cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
        local sw = colorBtn:CreateTexture(nil, "ARTWORK")
        sw:SetSize(16, 16); sw:SetPoint("CENTER")
        sw:SetColorTexture(unpack(SQPSettings.percentColor or pctDefault))
        SQP.optionControls.percentColorSwatch = sw

        local colorLbl = c:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        SQP:ApplyDefaultFont(colorLbl)
        colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
        colorLbl:SetText("Count Color")
        colorLbl:SetTextColor(_G.RGXDesign:Unpack("text"))

        local colorReset = self:CreateInlineResetButton(c, function()
            SQP:SetSetting('percentColor', {unpack(pctDefault)})
            sw:SetColorTexture(unpack(pctDefault)); SQP:RefreshAllNameplates()
        end)
        _G.RGXUI:AnchorRowReset(c, colorReset, colorBtn)

        colorBtn:SetScript("OnClick", function()
            ActivatePercent()
            local r, g, b = unpack(SQPSettings.percentColor or pctDefault)
            _G.RGXColors:OpenPicker({
                r = r, g = g, b = b,
                onChanged = function(_, nr, ng, nb)
                    SQP:SetSetting('percentColor', {nr, ng, nb})
                    sw:SetColorTexture(nr, ng, nb)
                    SQP:RefreshAllNameplates()
                end,
            })
        end)
        yOffset = yOffset - 28

        -- Background Style ends the Main Icon card.
        yOffset = self:CreateDisplayStyleSection(c, "percent", ActivatePercent, yOffset, { textRowY = textRowY })
        mainCard:FitContent()
    end
end
