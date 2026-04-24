--=====================================================================================
-- RGX | Simple Quest Plates! - options_core.lua

-- Author: DonnieDice
-- Description: Core options panel framework
--=====================================================================================

local addonName, SQP = ...

-- Constants
SQP.PANEL_NAME = SQP.L["PANEL_NAME"]
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
    previewContainer:SetHeight(80)
    previewContainer:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -6)
    previewContainer:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -6)
    previewContainer:SetBackdrop(self.BACKDROP_DARK)
    previewContainer:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    previewContainer:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    -- Create preview inside the container
    self.previewFrame = self:CreatePreviewSection(previewContainer)
    self.previewFrame:SetPoint("CENTER", previewContainer, "CENTER", 0, 0)
    
    -- Initialize tabs below preview
    local tabs, tabPanels = self:InitializeTabs(container, previewContainer)
    if tabPanels.objectives and tabPanels.objectives.scrollFrame then
        tabPanels.objectives.scrollFrame:Hide()
    end
    local objectiveTabs, objectivePanels = self:InitializeObjectiveTabs(tabPanels.objectives)
    
    -- Populate tab content
    self:CreateGlobalOptions(tabPanels.general.content)
    self:CreateKillOptions(objectivePanels.kill.content)
    self:CreateLootOptions(objectivePanels.loot.content)
    self:CreatePercentOptions(objectivePanels.percent.content)
    self:CreateAboutSection(tabPanels.about.content)

    self.mainTabs = tabs
    self.objectiveTabs = objectiveTabs
    
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
    if InCombatLockdown() then
        self:PrintMessage(self.L["ERROR_COMBAT_LOCKDOWN"] or "Cannot open options during combat.")
        return
    end
    if Settings and Settings.OpenToCategory and self.settingsCategory then
        Settings.OpenToCategory(self.settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel) -- Call twice for Blizzard bug
    end
end

-- Create reset confirmation dialog
StaticPopupDialogs["SQP_RESET_CONFIRM"] = {
    text = SQP.L["RESET_CONFIRM"],
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        SQP:ResetSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
