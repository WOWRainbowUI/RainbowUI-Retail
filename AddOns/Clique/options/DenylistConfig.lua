--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2024 - James N. Whitehead II
-------------------------------------------------------------------]] ---

local addonName = select(1, ...)

---@class addon
local addon = select(2, ...)
local L = addon.L

local panel = CreateFrame("Frame")
panel:Hide()

panel.name = L["Frame Denylist"]
panel.parent = addonName

addon.optpanels["BLACKLIST"] = panel

function panel:OnCommit()
    panel.okay()
end

function panel:OnDefault()
end

function panel:OnRefresh ()
    panel.refresh()
end

panel:SetScript("OnShow", function(self)
    if not panel.initialized then
        panel:CreateOptions()
        panel.refresh()
    end
    panel.refresh()
end)

local function make_label(name, template)
    local label = panel:CreateFontString("CliqueOptionsBlacklist" .. name, "OVERLAY", template)
    label:SetWidth(panel:GetWidth())
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label.type = "label"
    return label
end

local state = {}

function panel:CreateOptions()
    panel.initialized = true

    self.intro = make_label("Intro", "GameFontHighlightSmall")
    self.intro:SetPoint("TOPLEFT", panel, 5, -5)
    self.intro:SetPoint("RIGHT", panel, -5, 0)
    self.intro:SetHeight(45)
    self.intro:SetText(L["This panel allows you to deny certain frames from being included for Clique bindings. Any frames that are selected in this list will not be registered, although you may have to reload your user interface to have them return to their original bindings."])

    self.background = CreateFrame("Frame", "CliqueDenylistconfigScrollBackground", self, "TooltipBackdropTemplate")
    self.background:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 4, 535)
    self.background:SetPoint("BOTTOMRIGHT", -31, 50)
    self.background:SetFrameLevel(2)

    local bgColor = BLACK_FONT_COLOR
    local bgAlpha = 1
    local bgR, bgG, bgB = bgColor:GetRGB()
    self.background:SetBackdropColor(bgR, bgG, bgB, bgAlpha)

    local bgBorderColor = DARKGRAY_COLOR
    local borderR, borderG, borderB = bgBorderColor:GetRGB()
    local borderAlpha = 1
    self.background:SetBackdropBorderColor(borderR, borderG, borderB, borderAlpha)

    self.scrollFrame = CreateFrame("Frame", "CliqueDenylistConfigScrollFrame", self.background, "WowScrollBoxList")
    self.scrollFrame:ClearAllPoints()
    self.scrollFrame:SetPoint("TOPLEFT", 5, -5)
    self.scrollFrame:SetPoint("BOTTOMRIGHT", -5, 0)
    self.scrollFrame:SetHeight(320)
    self.scrollFrame:Show()

    self.scrollbar = CreateFrame("EventFrame", "CliqueDenylistConfigScrollBar", self.background, "MinimalScrollBar")
    self.scrollbar:ClearAllPoints()
    self.scrollbar:SetPoint("TOPLEFT", self.background, "TOPRIGHT", 10, 0)
    self.scrollbar:SetPoint("BOTTOMLEFT", self.background, "BOTTOMRIGHT", 10, 0)

    self.dataProvider = CreateDataProvider()

    local dataProvider = self.dataProvider
    local scrollView = CreateScrollBoxListLinearView()

    ScrollUtil.InitScrollBoxListWithScrollBar(self.scrollFrame, self.scrollbar, scrollView)
    scrollView:SetElementInitializer("CliqueUICheckboxRowTemplate", function(button, data)
        panel:InitializeCheckboxRow(button, data)
    end)
    scrollView:SetDataProvider(dataProvider)

    self.selectall = CreateFrame("Button", "CliqueOptionsBlacklistSelectAll", self, "UIPanelButtonTemplate")
    self.selectall:SetText(L["Select All"])
    self.selectall:SetPoint("BOTTOMLEFT", 10, 10)
    self.selectall:SetWidth(100)
    self.selectall:SetScript("OnClick", function(button)
        for idx = 1, panel.dataProvider:GetSize() do
            local prev = panel.dataProvider:Find(idx)
            local name = prev.text
            panel.dataProvider:ReplaceAtIndex(idx, {
                text = prev.text,
                checked = true,
            })
            panel:ToggleSetting(name, true)
        end
        panel:FireBlacklistChanged()
    end)

    self.selectnone = CreateFrame("Button", "CliqueOptionsBlacklistSelectNone", self, "UIPanelButtonTemplate")
    self.selectnone:SetText(L["Select None"])
    self.selectnone:SetPoint("BOTTOMLEFT", self.selectall, "BOTTOMRIGHT", 5, 0)
    self.selectnone:SetWidth(100)
    self.selectnone:SetScript("OnClick", function(button)
        for idx = 1, panel.dataProvider:GetSize() do
            local prev = panel.dataProvider:Find(idx)
            local name = prev.text
            panel.dataProvider:ReplaceAtIndex(idx, {
                text = prev.text,
                checked = false,
            })
            panel:ToggleSetting(name, false)
        end
        panel:FireBlacklistChanged()
    end)
end

function panel:InitializeCheckboxRow(button, data)
    if not button.created then
        button.created = true
        button.CheckButton:SetScript("OnClick", function(checkButton)
            panel:CheckboxRowClicked(checkButton)
        end)
    end

    button.CheckButton.Text:SetText(data.text)
    button.CheckButton:SetChecked(data.checked)
    button.CheckButton.data = data
end

function panel:CheckboxRowClicked(checkButton)
    local rowIndex = panel.dataProvider:FindIndex(checkButton.data)
    if rowIndex then
        -- Found the previous row, let's update the checked state
        local data = checkButton.data
        local newData = {
            text = data.text,
            checked = not data.checked
        }
        panel.dataProvider:ReplaceAtIndex(rowIndex, newData)
        panel:ToggleSetting(newData.text, newData.checked)
        panel:FireBlacklistChanged()
    end
end

function panel:ToggleSetting(frame, value)
    if not not value then
        addon.settings.blacklist[frame] = true
    else
        addon.settings.blacklist[frame] = nil
    end
end

function panel:FireBlacklistChanged()
    addon:FireMessage("BLACKLIST_CHANGED")
end

function panel.okay()
    xpcall(function()
    -- Clear the existing blacklist
    for frame, value in pairs(state) do
        if not not value then
            addon.settings.blacklist[frame] = true
        else
            addon.settings.blacklist[frame] = nil
        end
    end

    addon:FireMessage("BLACKLIST_CHANGED")
    end, geterrorhandler())
end

function panel.refresh()
    xpcall(function()

    if not panel.initialized then
        panel:CreateOptions()
    end

    local dataProvider = panel.dataProvider
    dataProvider:Flush()

    local sorted = {}
    for frame in pairs(addon.ccframes) do
        local name = frame:GetName()
        table.insert(sorted, name)
    end

    for name, frame in pairs(addon.hccframes) do
        table.insert(sorted, name)
    end

    table.sort(sorted)

    for idx, name in ipairs(sorted) do
        local data = {
            text = name,
            checked = not not addon.settings.blacklist[name]
        }

        dataProvider:Insert(data)
    end

   end, geterrorhandler())
end

if Settings and Settings.RegisterCanvasLayoutSubcategory then
    local category, layout = Settings.RegisterCanvasLayoutSubcategory(addon.optpanels.ABOUT.category, addon.optpanels.BLACKLIST, addon.optpanels.BLACKLIST.name)
    addon.optpanels.BLACKLIST.category = category
    addon.optpanels.BLACKLIST.layout = layout
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel, addon.optpanels.ABOUT)
end
