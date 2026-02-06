--=====================================================================================
-- RGX | Simple Quest Plates! - options_general.lua
-- Version: 1.0.0
-- Author: DonnieDice
-- Description: General options tab content
--=====================================================================================

local addonName, SQP = ...
local format = string.format

-- Create general options (first tab)
function SQP:CreateGeneralOptions(content)
    -- Initialize control storage if not exists
    if not self.optionControls then
        self.optionControls = {}
    end
    
    -- Create two-column layout
    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(320)
    
    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)
    
    -- LEFT COLUMN
    local yOffset = -20
    
    -- General Settings Section
    local generalSection = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    generalSection:SetPoint("TOPLEFT", 20, yOffset)
    generalSection:SetText("|cff58be81" .. (self.L["OPTIONS_GENERAL"] or "General Settings") .. "|r")
    yOffset = yOffset - 20  -- Further condensed
    
    -- Debug mode checkbox
    local debugFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_DEBUG"] or "Enable Debug Mode")
    debugFrame:SetPoint("TOPLEFT", 20, yOffset)
    debugFrame.checkbox:SetChecked(SQPSettings.debug)
    self.optionControls.debug = debugFrame.checkbox  -- Store reference
    debugFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('debug', self:GetChecked())
        if SQPSettings.debug then
            SQP:PrintMessage("Debug mode enabled")
        else
            SQP:PrintMessage("Debug mode disabled")
        end
    end)
    yOffset = yOffset - 30  -- Further condensed
    
    -- Chat messages checkbox
    local chatFrame = self:CreateStyledCheckbox(leftColumn, self.L["OPTIONS_CHAT_MESSAGES"] or "Show Chat Messages")
    chatFrame:SetPoint("TOPLEFT", 20, yOffset)
    chatFrame.checkbox:SetChecked(SQPSettings.showMessages ~= false)
    self.optionControls.showMessages = chatFrame.checkbox  -- Store reference
    chatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showMessages', self:GetChecked())
    end)
    -- Removed Global Scale - moved back to Icon tab
    yOffset = yOffset - 40
    
    -- Reset all settings button (left column)
    local resetButton = self:CreateStyledButton(leftColumn, self.L["OPTIONS_RESET"] or "Reset All Settings", 160, 30)
    resetButton:SetPoint("TOPLEFT", 20, yOffset)
    resetButton:SetAlpha(0.8)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("SQP_RESET_CONFIRM")
    end)
    
    -- RIGHT COLUMN
    local rightYOffset = -20
    
    -- Combat Settings Section
    local combatSection = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    combatSection:SetPoint("TOPLEFT", 20, rightYOffset)
    combatSection:SetText("|cff58be81" .. (self.L["OPTIONS_COMBAT"] or "Combat Settings") .. "|r")
    rightYOffset = rightYOffset - 20  -- Further condensed
    
    -- Hide in combat checkbox
    local combatFrame = self:CreateStyledCheckbox(rightColumn, self.L["OPTIONS_HIDE_COMBAT"] or "Hide Icons in Combat")
    combatFrame:SetPoint("TOPLEFT", 20, rightYOffset)
    combatFrame.checkbox:SetChecked(SQPSettings.hideInCombat)
    self.optionControls.hideInCombat = combatFrame.checkbox  -- Store reference
    combatFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInCombat', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 30  -- Further condensed
    
    -- Hide in instances checkbox
    local instanceFrame = self:CreateStyledCheckbox(rightColumn, self.L["OPTIONS_HIDE_INSTANCE"] or "Hide Icons in Instances")
    instanceFrame:SetPoint("TOPLEFT", 20, rightYOffset)
    instanceFrame.checkbox:SetChecked(SQPSettings.hideInInstance)
    self.optionControls.hideInInstance = instanceFrame.checkbox  -- Store reference
    instanceFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('hideInInstance', self:GetChecked())
        SQP:RefreshAllNameplates()
    end)
    rightYOffset = rightYOffset - 45  -- Further condensed
    
    -- Test Detection button (moved to right column)
    local testButton = self:CreateStyledButton(rightColumn, self.L["OPTIONS_TEST"] or "Test Detection", 140, 30)
    testButton:SetPoint("TOPLEFT", 20, rightYOffset)
    testButton:SetScript("OnClick", function()
        SQP:TestQuestDetection()
    end)
end