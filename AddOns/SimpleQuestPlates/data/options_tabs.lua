--=====================================================================================
-- RGX | Simple Quest Plates! - options_tabs.lua

-- Author: DonnieDice
-- Description: Tab system for options panel
--=====================================================================================

local addonName, SQP = ...

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

-- Create tab panel (no scroll — content must fit)
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

    local tabInfo = {
        {id = "global",  text = self.L["Global"]},
        {id = "kill",    text = self.L["Kill"]},
        {id = "loot",    text = self.L["Loot"]},
        {id = "percent", text = self.L["Percent"]},
        {id = "about",   text = self.L["About"]},
    }

    -- Create tabs (110px wide, 115px spacing = 5×115 = 575px; fits in ~580px content)
    for i, info in ipairs(tabInfo) do
        local tab = self:CreateTabButton(tabContainer, info.id, info.text)
        tab:SetPoint("LEFT", tabContainer, "LEFT", (i-1) * 115, 0)

        local panel = self:CreateTabPanel(container)
        panel:SetPoint("TOPLEFT", tabContainer, "BOTTOMLEFT", 0, -3)
        panel:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -10, 10)

        tab:SetScript("OnClick", function()
            -- Hide all panels and deactivate all tabs
            for _, p in pairs(tabPanels) do p:Hide() end
            for _, t in pairs(tabs) do t:SetActive(false) end
            -- Show selected panel and activate tab
            panel:Show()
            tab:SetActive(true)
            -- Auto-switch preview to the relevant quest type
            if SQP.previewFrame then
                if info.id == "kill" and SQP.previewFrame.activateKillMode then
                    SQP.previewFrame.activateKillMode()
                elseif info.id == "loot" and SQP.previewFrame.activateLootMode then
                    SQP.previewFrame.activateLootMode()
                elseif info.id == "percent" and SQP.previewFrame.activatePercentMode then
                    SQP.previewFrame.activatePercentMode()
                elseif SQP.previewFrame.activateKillMode then
                    SQP.previewFrame.activateKillMode()
                end
            end
        end)

        tabs[info.id] = tab
        tabPanels[info.id] = panel
    end

    -- Default to global tab
    tabs.global:SetActive(true)
    tabPanels.global:Show()

    return tabs, tabPanels
end
