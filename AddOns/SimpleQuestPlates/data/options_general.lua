--=====================================================================================
-- RGX | Simple Quest Plates! - options_general.lua

-- Author: DonnieDice
-- Description: Global settings tab (addon state, combat, position, scale)
--=====================================================================================

local addonName, SQP = ...
local format = string.format

function SQP:CreateGlobalOptions(content)
    if not self.optionControls then self.optionControls = {} end
    local rgxFonts = _G.RGXFonts
    local rgxAccent = "bc6fa8"

    local function CreateNameplateFontControl(parent, y)
        local fontHeader = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fontHeader:SetPoint("TOPLEFT", 20, y)
        fontHeader:SetText("|cff" .. rgxAccent .. "Nameplate Font|r")
        y = y - 14

        if not rgxFonts or type(rgxFonts.CreateFontSettingControl) ~= "function" then
            if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage("|cffffaa00[SQP:fonts]|r RGXFonts missing or CreateFontSettingControl unavailable.")
            end
            local missing = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            missing:SetPoint("TOPLEFT", 20, y)
            missing:SetWidth(250)
            missing:SetJustifyH("LEFT")
            missing:SetText("|cffff5555RGX font dropdown is unavailable.|r")
            return y - 26
        end

        local fallbackName = type(rgxFonts.GetDefault) == "function" and rgxFonts:GetDefault() or "FrizQuadrata"
        local defaultName =
            (type(rgxFonts.ResolveName) == "function" and rgxFonts:ResolveName(SQPSettings.fontFamily, fallbackName))
            or (type(rgxFonts.FindByPath) == "function" and rgxFonts:FindByPath(SQPSettings.fontFamily))
            or fallbackName

        local ok, fontControl = pcall(function()
            if rgxFonts.DebugStatus then
                rgxFonts:DebugStatus("SQP CreateNameplateFontControl")
            end
            return rgxFonts:CreateFontSettingControl(parent, {
                label = "Nameplate text font",
                width = 240,
                height = 56,
                dropdownHeight = 56,
                buttonWidth = 188,
                storage = SQPSettings,
                key = "fontFamily",
                defaultName = defaultName,
                onChange = function(_, fontName, fontPath)
                    SQP:SetSetting('fontFamily', fontPath)
                    SQP:SetSetting('killFontFamily', fontPath)
                    SQP:SetSetting('lootFontFamily', fontPath)
                    SQP:SetSetting('percentFontFamily', fontPath)
                    SQP:RefreshAllNameplates()
                end,
            })
        end)

        if not ok or not fontControl then
            if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage("|cffffaa00[SQP:fonts]|r Unable to build RGX font dropdown: " .. tostring(fontControl))
            end
            local failed = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
            failed:SetPoint("TOPLEFT", 20, y)
            failed:SetWidth(250)
            failed:SetJustifyH("LEFT")
            failed:SetText("|cffff5555Unable to build RGX font dropdown.|r")
            if not ok then
                local details = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
                details:SetPoint("TOPLEFT", 20, y - 14)
                details:SetWidth(250)
                details:SetJustifyH("LEFT")
                details:SetText("|cffaaaaaa" .. tostring(fontControl) .. "|r")
                return y - 44
            end
            return y - 26
        end

        fontControl:SetPoint("TOPLEFT", 20, y)
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cff58be81[SQP:fonts]|r RGX font dropdown built.")
        end
        self.optionControls.rgxGeneralFontDropdown = fontControl
        y = y - 58

        local note = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        note:SetPoint("TOPLEFT", 20, y)
        note:SetWidth(250)
        note:SetJustifyH("LEFT")
        note:SetText("|cff58be81Changes the text font used by SQP nameplate icons.|r")
        return y - 30
    end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(298)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 10, 0)

    -- ── LEFT COLUMN: Addon state + toggles + combat ────────────────────────────
    local yOffset = -12

    -- Addon State
    local addonStateLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    addonStateLabel:SetPoint("TOPLEFT", 20, yOffset)
    addonStateLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ADDON_STATE"] or "Addon State") .. "|r")
    yOffset = yOffset - 14

    local enableButton  = self:CreateStyledButton(leftColumn, self.L["OPTIONS_ENABLE"]  or "Enable",  68, 20)
    local disableButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_DISABLE"] or "Disable", 68, 20)
    enableButton:SetPoint("TOPLEFT", 20, yOffset)
    disableButton:SetPoint("LEFT", enableButton, "RIGHT", 10, 0)

    local function UpdateEnabledButtons()
        if SQPSettings.enabled ~= false then
            enableButton:SetAlpha(1); disableButton:SetAlpha(0.6)
        else
            enableButton:SetAlpha(0.6); disableButton:SetAlpha(1)
        end
    end
    UpdateEnabledButtons()
    self.optionControls.updateEnabledButtons = UpdateEnabledButtons

    enableButton:SetScript("OnClick", function()
        SQP:SetSetting('enabled', true); UpdateEnabledButtons(); SQP:RefreshAllNameplates()
    end)
    disableButton:SetScript("OnClick", function()
        SQP:SetSetting('enabled', false); UpdateEnabledButtons(); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 24

    -- General Settings
    local generalSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    generalSection:SetPoint("TOPLEFT", 20, yOffset)
    generalSection:SetText("|cff58be81" .. (self.L["OPTIONS_GENERAL"] or "General Settings") .. "|r")
    yOffset = yOffset - 14

    local debugFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_DEBUG"] or "Enable Debug Mode")
    debugFrame:SetPoint("TOPLEFT", 20, yOffset)
    debugFrame.checkbox:SetChecked(SQPSettings.debug)
    self.optionControls.debug = debugFrame.checkbox
    debugFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('debug', self:GetChecked())
        SQP:PrintMessage(SQPSettings.debug and "Debug mode enabled" or "Debug mode disabled")
    end)
    yOffset = yOffset - 18

    local chatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_CHAT_MESSAGES"] or "Show Chat Messages")
    chatFrame:SetPoint("TOPLEFT", 20, yOffset)
    chatFrame.checkbox:SetChecked(SQPSettings.showMessages ~= false)
    self.optionControls.showMessages = chatFrame.checkbox
    chatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showMessages', self:GetChecked())
    end)
    yOffset = yOffset - 20

    local minimapSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minimapSection:SetPoint("TOPLEFT", 20, yOffset)
    minimapSection:SetText("|cff58be81Minimap Icon|r")
    yOffset = yOffset - 14

    local minimapFrame = self:CreateStyledCheckbox(leftColumn, "Show minimap icon")
    minimapFrame:SetPoint("TOPLEFT", 20, yOffset)
    minimapFrame.checkbox:SetChecked(SQPSettings.minimapIconEnabled ~= false)
    self.optionControls.minimapIconEnabled = minimapFrame.checkbox
    minimapFrame.checkbox:SetScript("OnClick", function(self)
        SQP:ToggleMinimapIcon(self:GetChecked())
    end)
    yOffset = yOffset - 20

    local minimapHint = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    minimapHint:SetPoint("TOPLEFT", 20, yOffset)
    minimapHint:SetWidth(250)
    minimapHint:SetJustifyH("LEFT")
    minimapHint:SetText("|cffaaaaaaLeft-click opens options. Drag to move. Ctrl-right-click hides it.|r")
    yOffset = yOffset - 32

    -- Global Animation Override
    -- Combat Settings
    local combatSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    combatSection:SetPoint("TOPLEFT", 20, yOffset)
    combatSection:SetText("|cff58be81" .. (self.L["OPTIONS_COMBAT"] or "Combat Settings") .. "|r")
    yOffset = yOffset - 14

    local combatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_HIDE_COMBAT"] or "Hide Icons in Combat")
    combatFrame:SetPoint("TOPLEFT", 20, yOffset)
    combatFrame.checkbox:SetChecked(SQPSettings.hideInCombat)
    self.optionControls.hideInCombat = combatFrame.checkbox
    combatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInCombat', self:GetChecked()); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 18

    local instanceFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_HIDE_INSTANCE"] or "Hide Icons in Instances")
    instanceFrame:SetPoint("TOPLEFT", 20, yOffset)
    instanceFrame.checkbox:SetChecked(SQPSettings.hideInInstance)
    self.optionControls.hideInInstance = instanceFrame.checkbox
    instanceFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInInstance', self:GetChecked()); SQP:RefreshAllNameplates()
    end)
    yOffset = yOffset - 20

    local testButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_TEST"] or "Test Detection", 120, 20)
    testButton:SetPoint("TOPLEFT", 20, yOffset)
    testButton:SetScript("OnClick", function() SQP:TestQuestDetection() end)

    local resetButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_RESET"] or "Reset All Settings", 138, 20)
    resetButton:SetPoint("LEFT", testButton, "RIGHT", 8, 0)
    resetButton:SetAlpha(0.8)
    resetButton:SetScript("OnClick", function() StaticPopup_Show("SQP_RESET_CONFIRM") end)

    -- ── RIGHT COLUMN: Position & Scale ────────────────────────────────────────
    local rightYOffset = -12

    local posScaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    posScaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    posScaleLabel:SetText("|cff58be81Position & Scale|r")
    rightYOffset = rightYOffset - 14

    -- Global Scale
    local scaleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    scaleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    scaleLabel:SetText(format("Scale: %.1f", SQPSettings.scale or 1.1))
    self.optionControls.scaleLabel = scaleLabel

    local scaleSlider = self:CreateStyledSlider(rightColumn, 0.5, 3.0, 0.1, 160)
    scaleSlider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -4)
    scaleSlider:SetValue(SQPSettings.scale or 1.1)
    self.optionControls.scale = scaleSlider

    local scaleReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('scale', 1.1)
        scaleSlider:SetValue(1.1)
        scaleLabel:SetText("Scale: 1.1")
        SQP:RefreshAllNameplates()
    end)
    scaleReset:SetPoint("TOPLEFT", scaleSlider, "TOPRIGHT", 8, 0)

    scaleSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10
        SQP:SetSetting('scale', value)
        scaleLabel:SetText(format("Scale: %.1f", value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 40

    -- X Offset
    local xLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    xLabel:SetText(format("Offset X: %d", SQPSettings.offsetX or 0))
    self.optionControls.offsetXLabel = xLabel

    local xSlider = self:CreateStyledSlider(rightColumn, -100, 100, 1, 160)
    xSlider:SetPoint("TOPLEFT", xLabel, "BOTTOMLEFT", 0, -4)
    xSlider:SetValue(SQPSettings.offsetX or 0)
    self.optionControls.offsetX = xSlider

    local xReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('offsetX', 0)
        xSlider:SetValue(0)
        xLabel:SetText("Offset X: 0")
        SQP:RefreshAllNameplates()
    end)
    xReset:SetPoint("TOPLEFT", xSlider, "TOPRIGHT", 8, 0)

    xSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetX', value)
        xLabel:SetText(format("Offset X: %d", value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 40

    -- Y Offset
    local yLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    yLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    yLabel:SetText(format("Offset Y: %d", SQPSettings.offsetY or 3))
    self.optionControls.offsetYLabel = yLabel

    local ySlider = self:CreateStyledSlider(rightColumn, -100, 100, 1, 160)
    ySlider:SetPoint("TOPLEFT", yLabel, "BOTTOMLEFT", 0, -4)
    ySlider:SetValue(SQPSettings.offsetY or 3)
    self.optionControls.offsetY = ySlider

    local yReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('offsetY', 3)
        ySlider:SetValue(3)
        yLabel:SetText("Offset Y: 3")
        SQP:RefreshAllNameplates()
    end)
    yReset:SetPoint("TOPLEFT", ySlider, "TOPRIGHT", 8, 0)

    ySlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        SQP:SetSetting('offsetY', value)
        yLabel:SetText(format("Offset Y: %d", value))
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 40

    -- Nameplate Side
    local anchorLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    anchorLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    anchorLabel:SetText("Nameplate Side")
    rightYOffset = rightYOffset - 18

    local leftBtn  = self:CreateStyledButton(rightColumn, "Left Side",  84, 20)
    local rightBtn = self:CreateStyledButton(rightColumn, "Right Side", 84, 20)
    leftBtn:SetPoint("TOPLEFT", 20, rightYOffset)
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

    local anchorReset = self:CreateInlineResetButton(rightColumn, function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    anchorReset:SetPoint("LEFT", rightBtn, "RIGHT", 6, 0)

    rightYOffset = rightYOffset - 38

    local fontCard = CreateFrame("Frame", nil, rightColumn, "BackdropTemplate")
    fontCard:SetPoint("TOPLEFT", rightColumn, "TOPLEFT", 10, rightYOffset)
    fontCard:SetSize(270, 98)
    fontCard:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    fontCard:SetBackdropColor(0.04, 0.05, 0.07, 0.72)
    fontCard:SetBackdropBorderColor(0.20, 0.26, 0.34, 0.95)
    CreateNameplateFontControl(fontCard, -10)
end
