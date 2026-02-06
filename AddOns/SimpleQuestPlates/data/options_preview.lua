--=====================================================================================
-- RGX | Simple Quest Plates! - options_preview.lua

-- Author: DonnieDice
-- Description: Preview nameplate for options panel
--=====================================================================================

local addonName, SQP = ...
local CreateFrame = CreateFrame

-- Create preview nameplate section
function SQP:CreatePreviewSection(parent)
    -- Create preview container
    local previewFrame = CreateFrame("Frame", nil, parent)
    previewFrame:SetSize(parent:GetWidth() - 40, 140)
    previewFrame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    
    -- Preview title
    local previewTitle = previewFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    previewTitle:SetPoint("TOP", previewFrame, "TOP", 0, -5)
    previewTitle:SetText("|cff58be81Live Preview|r")
    
    -- Create fake nameplate
    local nameplate = CreateFrame("Frame", nil, previewFrame)
    nameplate:SetSize(200, 40)
    nameplate:SetPoint("CENTER", previewFrame, "CENTER", 0, 0)
    
    -- Nameplate background
    local nameplateBackground = nameplate:CreateTexture(nil, "BACKGROUND")
    nameplateBackground:SetAllPoints()
    nameplateBackground:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    
    -- Health bar
    local healthBar = CreateFrame("StatusBar", nil, nameplate)
    healthBar:SetSize(180, 12)
    healthBar:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    healthBar:SetStatusBarColor(1, 0.2, 0.2)
    healthBar:SetMinMaxValues(0, 100)
    healthBar:SetValue(75)
    
    -- Health bar background
    local healthBackground = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBackground:SetAllPoints()
    healthBackground:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    
    -- Name text
    local nameText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("BOTTOM", healthBar, "TOP", 0, 2)
    nameText:SetText("Murloc Warrior")
    nameText:SetTextColor(1, 0.82, 0)
    
    -- Level text
    local levelText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -2)
    levelText:SetText("Level 15")
    levelText:SetTextColor(0.8, 0.8, 0.8)
    
    -- Create preview quest icon
    local questFrame = CreateFrame("Frame", nil, nameplate)
    questFrame:SetAllPoints()
    
    -- Quest icon
    local icon = questFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    icon:SetSize(28, 22)
    icon:SetTexture('Interface/QuestFrame/AutoQuest-Parts')
    icon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)
    
    -- Quest count text
    local iconText = questFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
    iconText:SetPoint("CENTER", icon, 0.8, 0)
    iconText:SetShadowOffset(1, -1)
    iconText:SetTextColor(1, 0.82, 0)
    
    -- Apply font settings first, then set text
    SQP:UpdateQuestFont(iconText)
    iconText:SetText("3")
    
    -- Default to showing kill quest type
    if SQPSettings.customColors then
        iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
    else
        iconText:SetTextColor(1, 0.82, 0)
    end
    
    -- Loot icon
    local lootIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    lootIcon:SetAtlas('Banker')
    lootIcon:SetSize(16, 16)
    lootIcon:SetPoint('TOPLEFT', icon, 'BOTTOMRIGHT', -12, 12)
    lootIcon:Hide()
    
    -- Store references
    previewFrame.nameplate = nameplate
    previewFrame.questFrame = questFrame
    previewFrame.icon = icon
    previewFrame.iconText = iconText
    previewFrame.lootIcon = lootIcon
    
    -- Update function
    function previewFrame:UpdatePreview()
        -- Update icon position
        icon:ClearAllPoints()
        icon:SetPoint(
            SQPSettings.anchor or 'RIGHT',
            nameplate,
            SQPSettings.relativeTo or 'LEFT',
            SQPSettings.offsetX or 0,
            SQPSettings.offsetY or 0
        )
        
        -- Update scale
        questFrame:SetScale(SQPSettings.scale or 1)
        
        -- Update font
        SQP:UpdateQuestFont(iconText)
        
        -- Update icon tinting
        if SQPSettings.iconTintColor then
            icon:SetVertexColor(unpack(SQPSettings.iconTintColor))
        else
            icon:SetVertexColor(1, 1, 1, 1)
        end
    end
    
    -- Initial update
    previewFrame:UpdatePreview()
    
    -- Track active button
    local activeButton = nil
    
    -- Declare button variables
    local killButton, lootButton, percentButton
    
    -- Function to update button states
    local function SetActiveButton(button)
        -- Reset all buttons
        killButton:SetAlpha(0.6)
        lootButton:SetAlpha(0.6)
        percentButton:SetAlpha(0.6)
        
        -- Highlight active button
        if button then
            button:SetAlpha(1)
            activeButton = button
        end
    end
    
    -- Example toggle buttons
    killButton = self:CreateStyledButton(previewFrame, "Kill Quest", 80, 25)
    killButton:SetPoint("BOTTOM", previewFrame, "BOTTOM", -90, 5)
    killButton:SetScript("OnClick", function(self)
        iconText:SetText("5")
        iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
        lootIcon:Hide()
        SetActiveButton(self)
    end)
    
    lootButton = self:CreateStyledButton(previewFrame, "Loot Quest", 80, 25)
    lootButton:SetPoint("BOTTOM", previewFrame, "BOTTOM", 0, 5)
    lootButton:SetScript("OnClick", function(self)
        iconText:SetText("2")
        iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
        lootIcon:Show()
        SetActiveButton(self)
    end)
    
    percentButton = self:CreateStyledButton(previewFrame, "% Quest", 80, 25)
    percentButton:SetPoint("BOTTOM", previewFrame, "BOTTOM", 90, 5)
    percentButton:SetScript("OnClick", function(self)
        iconText:SetText("75")
        iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
        lootIcon:Hide()
        SetActiveButton(self)
    end)
    
    -- Set initial active button and trigger its click
    SetActiveButton(killButton)
    killButton:GetScript("OnClick")(killButton)
    
    -- Store additional references for color updates
    previewFrame.buttons = {killButton, lootButton, percentButton}
    
    return previewFrame
end

-- Hook into refresh function
local oldRefresh = SQP.RefreshAllNameplates
function SQP:RefreshAllNameplates()
    -- Call original function
    if oldRefresh then
        oldRefresh(self)
    end
    
    -- Update preview if it exists
    if self.previewFrame then
        self.previewFrame:UpdatePreview()
        
        -- Re-apply current quest type colors
        if self.previewFrame.iconText then
            local text = self.previewFrame.iconText:GetText()
            if text then
                if text == "5" then
                    -- Kill quest
                    self.previewFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
                elseif text == "2" then
                    -- Item quest
                    self.previewFrame.iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
                elseif text == "75" then
                    -- Progress quest
                    self.previewFrame.iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                end
            end
        end
    end
end