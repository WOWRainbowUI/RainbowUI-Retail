--=====================================================================================
-- RGX | Simple Quest Plates! - options_percent.lua

-- Author: DonnieDice
-- Description: Percent quest tab (color, size, offsets)
--=====================================================================================

local addonName, SQP = ...

function SQP:CreatePercentOptions(content)
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
            if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
                SQP.previewFrame.activatePercentMode()
            end
            SQP:RefreshAllNameplates()
        end)
        return yOff - 36
    end

    -- ── LEFT COLUMN: Color ─────────────────────────────────────────────────────
    local yOffset = -15

    local header = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header:SetPoint("TOPLEFT", 20, yOffset)
    header:SetText(self.L["|cff58be81Percent Icon|r"])
    yOffset = yOffset - 22

    local noteText = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    noteText:SetPoint("TOPLEFT", 20, yOffset)
    noteText:SetText(self.L["|cffaaaaaaShown for quests tracked by percentage (area/time).|r"])
    noteText:SetWidth(240)
    noteText:SetJustifyH("LEFT")
    yOffset = yOffset - 28

    -- Show Percent Icon
    local showFrame = self:CreateStyledCheckbox(leftColumn, self.L["Show Percent Icon"])
    showFrame:SetPoint("TOPLEFT", 20, yOffset)
    showFrame.checkbox:SetChecked(SQPSettings.showPercentIcon ~= false)
    self.optionControls.showPercentIcon = showFrame.checkbox
    showFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showPercentIcon', self:GetChecked())
        if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
            SQP.previewFrame.activatePercentMode()
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 30

    -- Percent Color
    local colorHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorHeader:SetPoint("TOPLEFT", 20, yOffset)
    colorHeader:SetText(self.L["|cff58be81Color|r"])
    yOffset = yOffset - 20

    local pctDefault = {0.2, 1, 1}
    local colorBtn = CreateFrame("Button", nil, leftColumn)
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("TOPLEFT", 20, yOffset)
    local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
    cbg:SetAllPoints(); cbg:SetColorTexture(0, 0, 0, 1)
    local sw = colorBtn:CreateTexture(nil, "ARTWORK")
    sw:SetSize(16, 16); sw:SetPoint("CENTER")
    sw:SetColorTexture(unpack(SQPSettings.percentColor or pctDefault))

    local colorLbl = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
    colorLbl:SetText(self.L["Percent Color"])

    local colorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('percentColor', {unpack(pctDefault)})
        sw:SetColorTexture(unpack(pctDefault)); SQP:RefreshAllNameplates()
    end)
    colorReset:SetPoint("LEFT", colorLbl, "RIGHT", 5, 0)

    colorBtn:SetScript("OnClick", function()
        if SQP.previewFrame and SQP.previewFrame.activatePercentMode then
            SQP.previewFrame.activatePercentMode()
        end
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

    -- ── RIGHT COLUMN: Size & Position ─────────────────────────────────────────
    local rightYOffset = -15

    local posHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    posHeader:SetText(self.L["|cff58be81Size & Position|r"])
    rightYOffset = rightYOffset - 22

    rightYOffset = MakeSlider(rightColumn, self.L["Size"],     "percentIconSize",     8,  8,   40, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, self.L["Offset X"], "percentIconOffsetX", -17, -80,  80, rightYOffset)
    rightYOffset = MakeSlider(rightColumn, self.L["Offset Y"], "percentIconOffsetY",   0, -80,  80, rightYOffset)
end
