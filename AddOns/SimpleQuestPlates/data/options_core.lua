--=====================================================================================
-- RGX | Simple Quest Plates! - options_core.lua

-- Author: DonnieDice
-- Description: Core options panel framework
--=====================================================================================

local addonName, SQP = ...

-- Constants
SQP.PANEL_NAME = "|TInterface\\AddOns\\SimpleQuestPlates\\images\\icon:0|t |cff58be81S|r|cffffffffimple|r |cff58be81Q|r|cffffffffuest|r |cff58be81P|r|cfffffffflates|r|cff58be81!|r"
SQP.SECTION_COLOR = {0.345, 0.745, 0.506} -- #58be81
SQP.PANEL_WIDTH = 700
SQP.PANEL_HEIGHT = 600

-- Custom backdrop
SQP.BACKDROP_DARK = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = {left = 1, right = 1, top = 1, bottom = 1}
}

-- Create the main options panel
function SQP:CreateOptionsPanel()
    -- Create main panel frame
    local panel = CreateFrame("Frame", "SQPOptionsPanel", UIParent)
    panel.name = self.PANEL_NAME
    
    -- Main container with custom background
    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetPoint("TOPLEFT", 10, -10)
    container:SetPoint("BOTTOMRIGHT", -10, 10)
    container:SetBackdrop(self.BACKDROP_DARK)
    container:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    container:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    -- Create header
    local header = self:CreatePanelHeader(container)
    
    -- Create preview section at the top
    local previewContainer = CreateFrame("Frame", nil, container, "BackdropTemplate")
    previewContainer:SetHeight(180)
    previewContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
    previewContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -10)
    previewContainer:SetBackdrop(self.BACKDROP_DARK)
    previewContainer:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    previewContainer:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    -- Create preview inside the container
    self.previewFrame = self:CreatePreviewSection(previewContainer)
    self.previewFrame:SetPoint("CENTER", previewContainer, "CENTER", 0, 0)
    
    -- Initialize tabs below preview
    local tabs, tabPanels = self:InitializeTabs(container, previewContainer)
    
    -- Populate tab content
    self:CreateGeneralOptions(tabPanels.general.content)
    self:CreateFontOptions(tabPanels.font.content)
    self:CreateIconOptions(tabPanels.icon.content)
    self:CreateAboutSection(tabPanels.about.content)
    self:CreateRGXSection(tabPanels.rgx.content)
    
    -- Register the panel
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Dragonflight and newer
        local category = Settings.RegisterCanvasLayoutCategory(panel, self.PANEL_NAME)
        Settings.RegisterAddOnCategory(category)
        self.settingsCategory = category
    else
        -- Older versions
        InterfaceOptions_AddCategory(panel)
    end
    
    self.optionsPanel = panel
end

-- Open options panel
function SQP:OpenOptions()
    if Settings and Settings.OpenToCategory and self.settingsCategory then
        Settings.OpenToCategory(self.settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel) -- Call twice for Blizzard bug
    end
end

-- Create reset confirmation dialog
StaticPopupDialogs["SQP_RESET_CONFIRM"] = {
    text = "|cff58be81Simple Quest Plates!|r\n\nAre you sure you want to reset all settings to defaults?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        SQP:ResetSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}