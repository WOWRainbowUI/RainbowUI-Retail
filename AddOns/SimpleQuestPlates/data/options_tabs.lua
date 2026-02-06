--=====================================================================================
-- RGX | Simple Quest Plates! - options_tabs.lua

-- Author: DonnieDice
-- Description: Tab system for options panel
--=====================================================================================

local addonName, SQP = ...

-- Create tab button
function SQP:CreateTabButton(parent, id, text)
    local tab = CreateFrame("Button", nil, parent)
    tab:SetSize(120, 32)
    tab.id = id
    
    -- Background
    local bg = tab:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    tab.bg = bg
    
    -- Border
    local border = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    tab.border = border
    
    -- Text
    local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    tab.label = label
    
    -- Highlight
    tab:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    
    -- Active state
    function tab:SetActive(active)
        if active then
            self.bg:SetColorTexture(0.15, 0.15, 0.15, 1)
            self.border:SetBackdropBorderColor(unpack(SQP.SECTION_COLOR))
            self.label:SetTextColor(unpack(SQP.SECTION_COLOR))
        else
            self.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
            self.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            self.label:SetTextColor(1, 1, 1, 1)
        end
    end
    
    return tab
end

-- Create tab panel
function SQP:CreateTabPanel(parent, needsScroll)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop(self.BACKDROP_DARK)
    panel:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    panel:SetBackdropBorderColor(0.2, 0.2, 0.2)
    panel:Hide()
    
    if needsScroll then
        -- Create scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 10, -10)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
        
        -- Style scroll bar
        local scrollBar = scrollFrame.ScrollBar
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -20, -16)
        scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -20, 16)
        
        -- Content frame
        local content = CreateFrame("Frame", nil, scrollFrame)
        -- Delay width setting until after panel is shown
        panel:SetScript("OnShow", function(self)
            content:SetWidth(scrollFrame:GetWidth())
        end)
        content:SetHeight(600) -- Height will be adjusted dynamically
        scrollFrame:SetScrollChild(content)
        
        panel.scrollFrame = scrollFrame
        panel.content = content
    else
        -- Simple content frame (no scrolling)
        local content = CreateFrame("Frame", nil, panel)
        content:SetPoint("TOPLEFT", 10, -10)
        content:SetPoint("BOTTOMRIGHT", -10, 10)
        
        panel.content = content
    end
    
    return panel
end

-- Initialize tab system
function SQP:InitializeTabs(container, previewContainer)
    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetHeight(40)
    tabContainer:SetPoint("TOPLEFT", previewContainer, "BOTTOMLEFT", 0, -10)
    tabContainer:SetPoint("TOPRIGHT", previewContainer, "BOTTOMRIGHT", 0, -10)
    
    -- Tab buttons
    local tabs = {}
    local tabPanels = {}
    
    local tabInfo = {
        {id = "general", text = "General"},
        {id = "font", text = "Font"},
        {id = "icon", text = "Icon"},
        {id = "about", text = "About"},
        {id = "rgx", text = "RGX Mods"}
    }
    
    -- Create tabs
    for i, info in ipairs(tabInfo) do
        local tab = self:CreateTabButton(tabContainer, info.id, info.text)
        tab:SetPoint("LEFT", tabContainer, "LEFT", (i-1) * 125, 0)
        
        -- Create panel without scrolling (all tabs fit now)
        local needsScroll = false
        local panel = self:CreateTabPanel(container, needsScroll)
        panel:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -5)
        panel:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)
        
        tab:SetScript("OnClick", function()
            -- Hide all panels
            for _, p in pairs(tabPanels) do
                p:Hide()
            end
            -- Deactivate all tabs
            for _, t in pairs(tabs) do
                t:SetActive(false)
            end
            -- Show selected panel and activate tab
            panel:Show()
            tab:SetActive(true)
        end)
        
        tabs[info.id] = tab
        tabPanels[info.id] = panel
    end
    
    -- Default to first tab
    tabs.general:SetActive(true)
    tabPanels.general:Show()
    
    return tabs, tabPanels
end