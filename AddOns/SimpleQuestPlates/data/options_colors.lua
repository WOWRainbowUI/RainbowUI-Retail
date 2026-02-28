--=====================================================================================
-- RGX | Simple Quest Plates! - options_colors.lua

-- Author: DonnieDice
-- Description: Colors & tinting options tab
--=====================================================================================

local addonName, SQP = ...

function SQP:CreateColorsOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── LEFT COLUMN: Quest text colors ──────────────────────────────────────
    local yOffset = -15

    local colorTitle = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorTitle:SetPoint("TOPLEFT", 20, yOffset)
    colorTitle:SetText("|cff58be81" .. (self.L["OPTIONS_TEXT_COLORS"] or "Quest Text Colors") .. "|r")
    yOffset = yOffset - 22

    local defaults = {
        killColor    = {1, 0.82, 0},
        itemColor    = {0.2, 1, 0.2},
        percentColor = {0.2, 1, 1},
        outlineColor = {0, 0, 0},
    }
    local swatches = {}

    local function MakeColorRow(parent, label, key, yOff, previewMode)
        local btn = CreateFrame("Button", nil, parent)
        btn:SetSize(20, 20)
        btn:SetPoint("TOPLEFT", 20, yOff)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 1)

        local sw = btn:CreateTexture(nil, "ARTWORK")
        sw:SetSize(16, 16)
        sw:SetPoint("CENTER")
        sw:SetColorTexture(unpack(SQPSettings[key] or defaults[key]))
        swatches[key] = sw

        local lbl = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        lbl:SetPoint("LEFT", btn, "RIGHT", 6, 0)
        lbl:SetText(label)

        local resetBtn = SQP:CreateInlineResetButton(parent, function()
            local defVal = defaults[key]
            if defVal then
                SQP:SetSetting(key, {unpack(defVal)})
                sw:SetColorTexture(unpack(defVal))
                SQP:RefreshAllNameplates()
            end
        end)
        resetBtn:SetPoint("LEFT", lbl, "RIGHT", 5, 0)

        local function SwitchPreview()
            if previewMode and SQP.previewFrame then
                if previewMode == "kill" and SQP.previewFrame.activateKillMode then
                    SQP.previewFrame.activateKillMode()
                elseif previewMode == "loot" and SQP.previewFrame.activateLootMode then
                    SQP.previewFrame.activateLootMode()
                elseif previewMode == "percent" and SQP.previewFrame.activatePercentMode then
                    SQP.previewFrame.activatePercentMode()
                end
            end
        end

        btn:SetScript("OnClick", function()
            SwitchPreview()
            local r, g, b = unpack(SQPSettings[key] or defaults[key])
            local info = { r = r, g = g, b = b, hasOpacity = false }
            info.swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                SQP:SetSetting(key, {nr, ng, nb})
                sw:SetColorTexture(nr, ng, nb)
                SQP:RefreshAllNameplates()
            end
            info.cancelFunc = function()
                SQP:SetSetting(key, {r, g, b})
                sw:SetColorTexture(r, g, b)
                SQP:RefreshAllNameplates()
            end
            ColorPickerFrame:SetupColorPickerAndShow(info)
        end)
    end

    MakeColorRow(leftColumn, self.L["OPTIONS_COLOR_KILL"]    or "Kill Quests",      "killColor",    yOffset, "kill")    yOffset = yOffset - 26
    MakeColorRow(leftColumn, self.L["OPTIONS_COLOR_ITEM"]    or "Item Quests",      "itemColor",    yOffset, "loot")    yOffset = yOffset - 26
    MakeColorRow(leftColumn, self.L["OPTIONS_COLOR_PERCENT"] or "Progress Quests",  "percentColor", yOffset, "percent") yOffset = yOffset - 26
    MakeColorRow(leftColumn, self.L["OPTIONS_COLOR_OUTLINE"] or "Text Outline",     "outlineColor", yOffset, nil)       yOffset = yOffset - 26

    -- ── RIGHT COLUMN: Icon tinting ───────────────────────────────────────────
    local rightYOffset = -15

    local tintTitle = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tintTitle:SetPoint("TOPLEFT", 20, rightYOffset)
    tintTitle:SetText("|cff58be81Icon Tinting|r")
    rightYOffset = rightYOffset - 22

    -- Helper: tint section (checkbox + color picker)
    local function MakeTintSection(parent, header, tintKey, colorKey, yOff)
        local hdr = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        hdr:SetPoint("TOPLEFT", 20, yOff)
        hdr:SetText("|cffaaaaaa" .. header .. "|r")
        yOff = yOff - 20

        local cbFrame = SQP:CreateStyledCheckbox(parent, "Enable Tinting")
        cbFrame:SetPoint("TOPLEFT", 20, yOff)
        cbFrame.checkbox:SetChecked(SQPSettings[tintKey] == true)
        SQP.optionControls[tintKey] = cbFrame.checkbox
        yOff = yOff - 26

        local colorBtn = CreateFrame("Button", nil, parent)
        colorBtn:SetSize(20, 20)
        colorBtn:SetPoint("TOPLEFT", 30, yOff)
        local cbg = colorBtn:CreateTexture(nil, "BACKGROUND")
        cbg:SetAllPoints()
        cbg:SetColorTexture(0, 0, 0, 1)
        local sw = colorBtn:CreateTexture(nil, "ARTWORK")
        sw:SetSize(16, 16)
        sw:SetPoint("CENTER")
        sw:SetColorTexture(unpack(SQPSettings[colorKey] or {1,1,1}))

        local colorLbl = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        colorLbl:SetPoint("LEFT", colorBtn, "RIGHT", 6, 0)
        colorLbl:SetText("Tint Color")

        local resetBtn = SQP:CreateInlineResetButton(parent, function()
            if not SQPSettings[tintKey] then return end
            SQP:SetSetting(colorKey, {1,1,1})
            sw:SetColorTexture(1,1,1)
            SQP:RefreshAllNameplates()
        end)
        resetBtn:SetPoint("LEFT", colorLbl, "RIGHT", 6, 0)

        local function UpdateAlpha()
            local a = SQPSettings[tintKey] == true and 1 or 0.4
            colorBtn:SetAlpha(a)
            colorLbl:SetAlpha(a)
            resetBtn:SetAlpha(a * 0.7)
        end

        cbFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting(tintKey, self:GetChecked())
            UpdateAlpha()
            SQP:RefreshAllNameplates()
        end)

        colorBtn:SetScript("OnClick", function()
            if not SQPSettings[tintKey] then return end
            local r, g, b = unpack(SQPSettings[colorKey] or {1,1,1})
            local info = { r = r, g = g, b = b, hasOpacity = false }
            info.swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                SQP:SetSetting(colorKey, {nr, ng, nb})
                sw:SetColorTexture(nr, ng, nb)
                SQP:RefreshAllNameplates()
            end
            info.cancelFunc = function()
                SQP:SetSetting(colorKey, {r, g, b})
                sw:SetColorTexture(r, g, b)
                SQP:RefreshAllNameplates()
            end
            ColorPickerFrame:SetupColorPickerAndShow(info)
        end)

        UpdateAlpha()
        return yOff - 36
    end

    rightYOffset = MakeTintSection(rightColumn, "Main Icon", "iconTintMain", "iconTintMainColor", rightYOffset)
    rightYOffset = MakeTintSection(rightColumn, "Task Icons (Kill/Loot)", "iconTintQuest", "iconTintQuestColor", rightYOffset)
end
