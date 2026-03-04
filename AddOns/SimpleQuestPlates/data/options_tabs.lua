--=====================================================================================
-- RGX | Simple Quest Plates! - options_tabs.lua

-- Author: DonnieDice
-- Description: Tab system for options panel
--=====================================================================================

local addonName, SQP = ...
local floor = math.floor

-- Create tab button
function SQP:CreateTabButton(parent, id, text)
    local tab = CreateFrame("Button", nil, parent)
    tab:SetSize(110, 26)
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

-- Create tab panel (no scroll - content must fit)
function SQP:CreateTabPanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop(self.BACKDROP_DARK)
    panel:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    panel:SetBackdropBorderColor(0.2, 0.2, 0.2)
    panel:Hide()

    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    panel.content = content
    return panel
end

-- Initialize tab system
function SQP:InitializeTabs(container, previewContainer)
    -- Tab container
    local tabContainer = CreateFrame("Frame", nil, container)
    tabContainer:SetHeight(32)
    tabContainer:SetPoint("TOPLEFT", previewContainer, "BOTTOMLEFT", 0, -6)
    tabContainer:SetPoint("TOPRIGHT", previewContainer, "BOTTOMRIGHT", 0, -6)

    -- Tab buttons
    local tabs = {}
    local tabPanels = {}
    local orderedTabs = {}

    local tabInfo = {
        {id = "global",  text = "Global"},
        {id = "kill",    text = "Kill"},
        {id = "loot",    text = "Loot"},
        {id = "percent", text = "Percent"},
        {id = "about",   text = "About"},
    }

    local function ActivateTab(id)
        for _, panel in pairs(tabPanels) do
            panel:Hide()
        end
        for _, tab in pairs(tabs) do
            tab:SetActive(false)
        end

        if tabPanels[id] then
            tabPanels[id]:Show()
        end
        if tabs[id] then
            tabs[id]:SetActive(true)
        end

        if SQP.previewFrame then
            if id == "kill" and SQP.previewFrame.activateKillMode then
                SQP.previewFrame.activateKillMode()
            elseif id == "loot" and SQP.previewFrame.activateLootMode then
                SQP.previewFrame.activateLootMode()
            elseif id == "percent" and SQP.previewFrame.activatePercentMode then
                SQP.previewFrame.activatePercentMode()
            elseif SQP.previewFrame.activateKillMode then
                SQP.previewFrame.activateKillMode()
            end
        end
    end

    -- Create tabs
    for index, info in ipairs(tabInfo) do
        local tab = self:CreateTabButton(tabContainer, info.id, info.text)
        local panel = self:CreateTabPanel(container)
        panel:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -3)
        panel:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)

        local tabId = info.id
        tab:SetScript("OnClick", function()
            ActivateTab(tabId)
        end)

        tabs[tabId] = tab
        tabPanels[tabId] = panel
        orderedTabs[index] = tab
    end

    -- Fill the tab row width evenly so no space remains after the last tab.
    local function LayoutTabs()
        local count = #orderedTabs
        if count == 0 then return end

        local containerWidth = tabContainer:GetWidth() or 0
        if containerWidth <= 0 then return end

        local gap = 4
        local totalGap = gap * (count - 1)
        local availableWidth = containerWidth - totalGap
        if availableWidth < count then
            availableWidth = count
        end

        local baseWidth = floor(availableWidth / count)
        local remainder = floor(availableWidth - (baseWidth * count))

        for index, tab in ipairs(orderedTabs) do
            tab:ClearAllPoints()
            tab:SetHeight(26)

            if index == 1 then
                tab:SetPoint("LEFT", tabContainer, "LEFT", 0, 0)
            else
                tab:SetPoint("LEFT", orderedTabs[index - 1], "RIGHT", gap, 0)
            end

            if index < count then
                local tabWidth = baseWidth
                if remainder > 0 then
                    tabWidth = tabWidth + 1
                    remainder = remainder - 1
                end
                tab:SetWidth(tabWidth)
            else
                tab:SetPoint("RIGHT", tabContainer, "RIGHT", 0, 0)
            end
        end
    end

    LayoutTabs()
    tabContainer:SetScript("OnSizeChanged", LayoutTabs)
    tabContainer:SetScript("OnShow", LayoutTabs)

    -- Default to global tab
    ActivateTab("global")

    return tabs, tabPanels
end
