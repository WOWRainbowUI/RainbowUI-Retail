--=====================================================================================
-- RGX | Simple Quest Plates! - options_quest_icons.lua

-- Author: DonnieDice
-- Description: Task icon options tab (visibility, animation, offsets, sizes)
--=====================================================================================

local addonName, SQP = ...

function SQP:CreateQuestIconOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── Helper: offset/size slider with inline reset ──────────────────────────
    local function MakeSlider(parent, labelText, key, defaultVal, minVal, maxVal, yOff, previewMode)
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
            if previewMode and SQP.previewFrame then
                if previewMode == "kill" and SQP.previewFrame.activateKillMode then
                    SQP.previewFrame.activateKillMode()
                elseif previewMode == "loot" and SQP.previewFrame.activateLootMode then
                    SQP.previewFrame.activateLootMode()
                elseif previewMode == "percent" and SQP.previewFrame.activatePercentMode then
                    if SQP.previewFrame.questType ~= "percent" then
                        SQP.previewFrame.activatePercentMode()
                    end
                end
            end
            SQP:RefreshAllNameplates()
        end)
        return yOff - 36
    end

    -- ── LEFT COLUMN: Toggles + Kill icon settings ─────────────────────────────
    local yOffset = -15

    local toggleHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    toggleHeader:SetPoint("TOPLEFT", 20, yOffset)
    toggleHeader:SetText("|cff58be81Task Icons|r")
    yOffset = yOffset - 22

    local showKillFrame = self:CreateStyledCheckbox(leftColumn, "Show Kill Icon")
    showKillFrame:SetPoint("TOPLEFT", 20, yOffset)
    showKillFrame.checkbox:SetChecked(SQPSettings.showKillIcon ~= false)
    self.optionControls.showKillIcon = showKillFrame.checkbox
    showKillFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showKillIcon', self:GetChecked())
        if SQP.previewFrame and SQP.previewFrame.activateKillMode then
            SQP.previewFrame.activateKillMode()
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    local showLootFrame = self:CreateStyledCheckbox(leftColumn, "Show Loot Icon")
    showLootFrame:SetPoint("TOPLEFT", 20, yOffset)
    showLootFrame.checkbox:SetChecked(SQPSettings.showLootIcon ~= false)
    self.optionControls.showLootIcon = showLootFrame.checkbox
    showLootFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showLootIcon', self:GetChecked())
        if SQP.previewFrame and SQP.previewFrame.activateLootMode then
            SQP.previewFrame.activateLootMode()
        end
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 26

    local animateQIFrame = self:CreateStyledCheckbox(leftColumn, "Animate Task Icons")
    animateQIFrame:SetPoint("TOPLEFT", 20, yOffset)
    animateQIFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
    self.optionControls.animateQuestIcons = animateQIFrame.checkbox
    animateQIFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('animateQuestIcons', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 34

    -- Kill icon settings
    local killHeader = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    killHeader:SetPoint("TOPLEFT", 20, yOffset)
    killHeader:SetText("|cff58be81Kill Icon|r")
    yOffset = yOffset - 18

    yOffset = MakeSlider(leftColumn, "Size",   "killIconSize",    16, 8, 40, yOffset, "kill")
    yOffset = MakeSlider(leftColumn, "Offset X", "killIconOffsetX", 12, -80, 80, yOffset, "kill")
    yOffset = MakeSlider(leftColumn, "Offset Y", "killIconOffsetY", 12, -80, 80, yOffset, "kill")

    -- ── RIGHT COLUMN: Loot + Percent settings ─────────────────────────────────
    local rightYOffset = -15

    local lootHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    lootHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    lootHeader:SetText("|cff58be81Loot Icon|r")
    rightYOffset = rightYOffset - 18

    rightYOffset = MakeSlider(rightColumn, "Size",   "lootIconSize",    16, 8, 40, rightYOffset, "loot")
    rightYOffset = MakeSlider(rightColumn, "Offset X", "lootIconOffsetX", -12, -80, 80, rightYOffset, "loot")
    rightYOffset = MakeSlider(rightColumn, "Offset Y", "lootIconOffsetY",  12, -80, 80, rightYOffset, "loot")
    rightYOffset = rightYOffset - 6

    local percentHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    percentHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    percentHeader:SetText("|cff58be81Percent Icon|r")
    rightYOffset = rightYOffset - 18

    rightYOffset = MakeSlider(rightColumn, "Size",   "percentIconSize",    14, 8, 40, rightYOffset, "percent")
    rightYOffset = MakeSlider(rightColumn, "Offset X", "percentIconOffsetX",  8, -80, 80, rightYOffset, "percent")
    rightYOffset = MakeSlider(rightColumn, "Offset Y", "percentIconOffsetY",  3, -80, 80, rightYOffset, "percent")
end
