--=====================================================================================
-- RGX | Simple Quest Plates! - options_loot.lua

-- Author: DonnieDice
-- Description: Loot tab — Display, Color, and Animation cards in framework columns
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global

function SQP:CreateLootOptions(content)
    if not self.optionControls then self.optionControls = {} end

    -- Swap the two card stacks while retaining their internal ordering.
    local leftColumn, rightColumn = SQP:CreateOptionColumns(content)

    local function ActivateLoot()
        if SQP.previewFrame and SQP.previewFrame.activateLootMode then
            SQP.previewFrame.activateLootMode()
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
                if SQP.previewFrame and SQP.previewFrame.activateLootMode then
                    SQP.previewFrame.activateLootMode()
                end
                SQP:RefreshAllNameplates()
            end,
        })
        slider:SetPoint("TOPLEFT", 8, yOff)
        slider:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yOff)
        SQP.optionControls[key] = slider
        if key == "lootIconOffsetX" and slider.resetButton then
            slider.resetButton:SetScript("OnClick", function()
                slider.SetValue(SQP:GetSettingBaseline(key))
            end)
        end
        SQP.optionControls[key .. "Label"] = slider.valueLabel
        return yOff - slider:GetHeight() - 8
    end

    -- RIGHT: task icon visibility, side, dimensions, tint, and reset.
    local taskCard = SQP:CreateCard(rightColumn, "Loot Task Icon")
    do
        local c = taskCard.content
        local yOffset = -8

        self:CreateHeaderSwitch(taskCard, "showLootIcon")
        yOffset = self:CreateMiniIconTintSection(c, "loot", ActivateLoot, yOffset)
        self:CreateIconSideSection(c, "loot", ActivateLoot, yOffset, { center = true })
        yOffset = yOffset - 24

        -- Task-icon dimensions; main background/text controls live separately.

        yOffset = MakeSlider(c, "Size",     "lootIconSize",    14,   8,  40, yOffset)
        yOffset = MakeSlider(c, "Offset X", "lootIconOffsetX", SQP:GetSettingBaseline("lootIconOffsetX"), -80, 80, yOffset)
        yOffset = MakeSlider(c, "Offset Y", "lootIconOffsetY", SQP:GetSettingBaseline("lootIconOffsetY"), -80, 80, yOffset)

        yOffset = yOffset - 10
        local resetBtn = self:CreateStyledButton(c, "Reset Loot Settings", 150, 22)
        resetBtn:SetPoint("TOP", c, "TOP", 0, yOffset)
        resetBtn:SetScript("OnClick", function()
            local D = SQP.DEFAULTS
            local oc = SQP.optionControls
            SQP:SetSetting('lootAnimationsEnabled', D.lootAnimationsEnabled)
            if oc.lootAnimationsEnabled then oc.lootAnimationsEnabled:SetChecked(D.lootAnimationsEnabled) end
            SQP:SetSetting('showLootIcon',      D.showLootIcon)
            SQP:SetSetting('lootShowIconBackground', D.lootShowIconBackground)
            SQP:SetSetting('lootLevelChip', nil)
            SQP:SetSetting('animateQuestIcons', D.animateQuestIcons)
            SQP:SetSetting('lootAnimateMain',   D.lootAnimateMain)
            SQP:SetSetting('lootAnimationIntensity', D.lootAnimationIntensity)
            SQP:SetSetting('itemColor',         {unpack(D.itemColor)})
            SQP:SetSetting('lootTintIcon',      D.lootTintIcon)
            SQP:SetSetting('lootTintIconColor', {unpack(D.lootTintIconColor)})
            SQP:SetSetting('lootIconSize',      D.lootIconSize)
            SQP:SetSetting('lootIconOffsetX',   SQP:GetSettingBaseline("lootIconOffsetX"))
            SQP:SetSetting('lootIconOffsetY',   D.lootIconOffsetY)
            SQP:SetSetting('lootFontSize',      D.lootFontSize)
            SQP:SetSetting('lootFontFamily',    D.lootFontFamily)
            SQP:SetSetting('lootIconSide',      D.lootIconSide)
            if oc.lootIconSideSideUpdater then oc.lootIconSideSideUpdater() end
            if oc.showLootIcon         then oc.showLootIcon:SetChecked(D.showLootIcon) end
            if oc.lootShowIconBackgroundStyleUpdater then oc.lootShowIconBackgroundStyleUpdater() end
            if oc.animateQuestIconsLoot then oc.animateQuestIconsLoot:SetChecked(D.animateQuestIcons) end
            if oc.animateQuestIcons then oc.animateQuestIcons:SetChecked(D.animateQuestIcons) end
            if oc.animateQuestIconsPercent then oc.animateQuestIconsPercent:SetChecked(D.animateQuestIcons) end
            if oc.lootAnimateMain      then oc.lootAnimateMain:SetChecked(D.lootAnimateMain) end
            if oc.lootAnimationIntensity and oc.lootAnimationIntensity.SetValue then
                oc.lootAnimationIntensity.SetValue(D.lootAnimationIntensity)
            end
            if oc.lootTintIcon         then oc.lootTintIcon:SetChecked(D.lootTintIcon) end
            if oc.lootColorSwatch              then oc.lootColorSwatch:SetColorTexture(unpack(D.itemColor)) end
            if oc.lootTintIconColorSwatch      then oc.lootTintIconColorSwatch:SetColorTexture(unpack(D.lootTintIconColor)) end
            if oc.lootTintIconAlphaUpdate      then oc.lootTintIconAlphaUpdate() end
            if oc.lootIconSize    then oc.lootIconSize.SetValue(D.lootIconSize) end
            if oc.lootIconOffsetX then oc.lootIconOffsetX.SetValue(SQP:GetSettingBaseline("lootIconOffsetX")) end
            if oc.lootIconOffsetY then oc.lootIconOffsetY.SetValue(D.lootIconOffsetY) end
            if oc.lootFontSize then oc.lootFontSize.SetValue(SQP:GetSettingBaseline("lootFontSize")) end
            if oc.lootFontFamily and type(oc.lootFontFamily.Reset) == "function" then
                oc.lootFontFamily:Reset()
            elseif oc.lootFontFamily and type(oc.lootFontFamily.SetPath) == "function" then
                oc.lootFontFamily:SetPath(D.lootFontFamily)
            elseif oc.lootFontFamily and UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(oc.lootFontFamily, "Friz Quadrata")
            end
            SQP:RefreshAllNameplates()
            ActivateLoot()
        end)
        taskCard:FitContent()
    end

    -- LEFT: Main Icon first, then Animation.
    local mainCard = SQP:CreateCard(leftColumn, "Loot Main Icon")
    local animCard = SQP:CreateCard(leftColumn, "Loot Animation", { above = mainCard })
    SQP:CreateHeaderSwitch(animCard, "lootAnimationsEnabled")
    do
        local c = animCard.content
        local yOffset = -8

        local animFrame = self:CreateStyledCheckbox(c, "Animate Task Icons")
        animFrame:SetPoint("TOPLEFT", 8, yOffset - 26)
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
        yOffset = yOffset - 26

        local animMainFrame = self:CreateStyledCheckbox(c, "Animate Main Icon")
        animMainFrame:SetPoint("TOPLEFT", 8, yOffset + 26)
        animMainFrame.checkbox:SetChecked(SQPSettings.lootAnimateMain == true)
        self.optionControls.lootAnimateMain = animMainFrame.checkbox
        animMainFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('lootAnimateMain', self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        yOffset = yOffset - 26

        local lootAnimIntensitySlider = SQP:CreateStyledSlider(c, {
            key = "lootAnimationIntensity",
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
                    and SQP.previewFrame and SQP.previewFrame.activateLootMode then
                    SQP.previewFrame.activateLootMode()
                elseif SQP.UpdatePreviewManually then
                    SQP:UpdatePreviewManually()
                end
                SQP:RefreshAllNameplates()
            end,
        })
        lootAnimIntensitySlider:SetPoint("TOPLEFT", 8, yOffset)
        lootAnimIntensitySlider:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
        self.optionControls.lootAnimationIntensity = lootAnimIntensitySlider
        self.optionControls.lootAnimationIntensityLabel = lootAnimIntensitySlider.valueLabel
        animCard:FitContent()
    end

    -- Populate the Main Icon card above Animation.
    do
        local c = mainCard.content
        local yOffset = -8
        local textRowY = yOffset
        yOffset = yOffset - 24

        -- Loot Color
        local colorHeader = c:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        SQP:ApplyDefaultFont(colorHeader)
        colorHeader:SetPoint("TOPLEFT", 8, yOffset)
        colorHeader:SetText("|cff58be81Color|r")
        yOffset = yOffset - 16

        local lootDefault = {0.2, 1, 0.2}
        local colorBtn = CreateFrame("Button", nil, c)
        colorBtn:SetSize(20, 20)
        colorBtn:SetPoint("TOPLEFT", 8, yOffset)
        local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
        cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
        local sw = colorBtn:CreateTexture(nil, "ARTWORK")
        sw:SetSize(16, 16); sw:SetPoint("CENTER")
        sw:SetColorTexture(unpack(SQPSettings.itemColor or lootDefault))
        SQP.optionControls.lootColorSwatch = sw

        local colorLbl = c:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        SQP:ApplyDefaultFont(colorLbl)
        colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
        colorLbl:SetText("Count Color")
        colorLbl:SetTextColor(_G.RGXDesign:Unpack("text"))

        local colorReset = self:CreateInlineResetButton(c, function()
            SQP:SetSetting('itemColor', {unpack(lootDefault)})
            sw:SetColorTexture(unpack(lootDefault)); SQP:RefreshAllNameplates()
        end)
        _G.RGXUI:AnchorRowReset(c, colorReset, colorBtn)

        colorBtn:SetScript("OnClick", function()
            ActivateLoot()
            local r, g, b = unpack(SQPSettings.itemColor or lootDefault)
            _G.RGXColors:OpenPicker({
                r = r, g = g, b = b,
                onChanged = function(_, nr, ng, nb)
                    SQP:SetSetting('itemColor', {nr, ng, nb})
                    sw:SetColorTexture(nr, ng, nb)
                    SQP:RefreshAllNameplates()
                end,
            })
        end)
        yOffset = yOffset - 28

        -- Background Style ends the Main Icon card.
        yOffset = self:CreateDisplayStyleSection(c, "loot", ActivateLoot, yOffset, { textRowY = textRowY })
        mainCard:FitContent()
    end
end
