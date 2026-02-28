--=====================================================================================
-- RGX | Simple Quest Plates! - options_kill.lua

-- Author: DonnieDice
-- Description: Kill icon tab (visibility, animation, color, tint, size, offsets)
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

    -- ── LEFT COLUMN: Toggles + Color + Tinting ────────────────────────────────
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
        if SQP.previewFrame and SQP.previewFrame.activateKillMode then
            SQP.previewFrame.activateKillMode()
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    -- Animate Task Icons (global — affects kill + loot)
    local animFrame = self:CreateStyledCheckbox(leftColumn, "Animate Task Icons")
    animFrame:SetPoint("TOPLEFT", 20, yOffset)
    animFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
    self.optionControls.animateQuestIcons = animFrame.checkbox
    animFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('animateQuestIcons', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

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

    local colorLbl = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    colorLbl:SetText("Kill Color")

    local colorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('killColor', {unpack(killDefault)})
        sw:SetColorTexture(unpack(killDefault)); SQP:RefreshAllNameplates()
    end)
    colorReset:SetPoint("LEFT", colorLbl, "RIGHT", 5, 0)

    colorBtn:SetScript("OnClick", function()
        if SQP.previewFrame and SQP.previewFrame.activateKillMode then
            SQP.previewFrame.activateKillMode()
        end
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

    -- Kill Icon Tinting (shared iconTintQuest / iconTintQuestColor with Loot tab)
    local tintHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tintHeader:SetPoint("TOPLEFT", 20, yOffset)
    tintHeader:SetText("|cff58be81Icon Tinting|r")
    yOffset = yOffset - 20

    local tintNote = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    tintNote:SetPoint("TOPLEFT", 20, yOffset)
    tintNote:SetText("|cffaaaaaa(Shared with Loot tab)|r")
    yOffset = yOffset - 18

    local tintCbFrame = self:CreateStyledCheckbox(leftColumn, "Enable Tinting")
    tintCbFrame:SetPoint("TOPLEFT", 20, yOffset)
    tintCbFrame.checkbox:SetChecked(SQPSettings.iconTintQuest == true)
    self.optionControls.iconTintQuest = tintCbFrame.checkbox
    yOffset = yOffset - 26

    local tintColorBtn = CreateFrame("Button", nil, leftColumn)
    tintColorBtn:SetSize(20, 20)
    tintColorBtn:SetPoint("TOPLEFT", 30, yOffset)
    local tintBg = tintColorBtn:CreateTexture(nil, "BACKGROUND")
    tintBg:SetAllPoints(); tintBg:SetColorTexture(0, 0, 0, 1)
    local tintSw = tintColorBtn:CreateTexture(nil, "ARTWORK")
    tintSw:SetSize(16, 16); tintSw:SetPoint("CENTER")
    tintSw:SetColorTexture(unpack(SQPSettings.iconTintQuestColor or {1, 1, 1}))

    local tintColorLbl = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tintColorLbl:SetPoint("LEFT", tintColorBtn, "RIGHT", 6, 0)
    tintColorLbl:SetText("Tint Color")

    local tintReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('iconTintQuestColor', {1, 1, 1})
        tintSw:SetColorTexture(1, 1, 1); SQP:RefreshAllNameplates()
    end)
    tintReset:SetPoint("LEFT", tintColorLbl, "RIGHT", 6, 0)

    local function UpdateTintAlpha()
        local a = SQPSettings.iconTintQuest == true and 1 or 0.4
        tintColorBtn:SetAlpha(a); tintColorLbl:SetAlpha(a); tintReset:SetAlpha(a * 0.7)
    end
    UpdateTintAlpha()

    tintCbFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('iconTintQuest', self:GetChecked())
        UpdateTintAlpha(); SQP:RefreshAllNameplates()
    end)

    tintColorBtn:SetScript("OnClick", function()
        if not SQPSettings.iconTintQuest then return end
        local r, g, b = unpack(SQPSettings.iconTintQuestColor or {1, 1, 1})
        local info = {r = r, g = g, b = b, hasOpacity = false}
        info.swatchFunc = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            SQP:SetSetting('iconTintQuestColor', {nr, ng, nb})
            tintSw:SetColorTexture(nr, ng, nb); SQP:RefreshAllNameplates()
        end
        info.cancelFunc = function()
            SQP:SetSetting('iconTintQuestColor', {r, g, b})
            tintSw:SetColorTexture(r, g, b); SQP:RefreshAllNameplates()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    -- ── RIGHT COLUMN: Size & Position ─────────────────────────────────────────
    local rightYOffset = -15

    local posHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    posHeader:SetText("|cff58be81Size & Position|r")
    rightYOffset = rightYOffset - 22

    rightYOffset = MakeSlider(rightColumn, "Size",     "killIconSize",    14,  8,   40, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, "Offset X", "killIconOffsetX",  2, -80,  80, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, "Offset Y", "killIconOffsetY", 15, -80,  80, rightYOffset)
end
