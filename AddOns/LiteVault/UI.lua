-- UI.lua (Enhanced Visual Polish)
local addonName, lv = ...
local L = lv.L

local function UIText(key, fallback)
    local v = L and L[key]
    if not v or v == key then
        local enUS = lv.LocaleData and lv.LocaleData["enUS"]
        return fallback or (enUS and enUS[key]) or key
    end
    return v
end

local function FormatGoldThousands(gold)
    local grouped = tostring(math.floor(tonumber(gold) or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return grouped
end

-- Custom gold formatting with grouped gold and zero-padded silver/copper.
local function FormatGoldAligned(copperAmount, iconSize)
    iconSize = iconSize or 14
    copperAmount = math.max(0, tonumber(copperAmount) or 0)
    local gold = math.floor(copperAmount / 10000)
    local silver = math.floor((copperAmount % 10000) / 100)
    local copper = copperAmount % 100
    local baseline = math.floor(iconSize * 0.18)

    local goldIcon = string.format("|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:%d|t", iconSize, iconSize, baseline)
    local silverIcon = string.format("|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:%d|t", iconSize, iconSize, baseline)
    local copperIcon = string.format("|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:%d|t", iconSize, iconSize, baseline)

    -- Zero-pad silver and copper to 2 digits
    return string.format("%s%s %02d%s %02d%s", FormatGoldThousands(gold), goldIcon, silver, silverIcon, copper, copperIcon)
end
lv.FormatGoldAligned = FormatGoldAligned

-- Compact formatting is intentionally limited to the Dashboard balance rows.
-- Other callers of FormatGoldAligned continue to receive exact coin values.
local function FormatDashboardMoney(copperAmount, iconSize)
    copperAmount = math.max(0, tonumber(copperAmount) or 0)
    local gold = copperAmount / 10000
    if gold < 1000 then
        return FormatGoldAligned(copperAmount, iconSize)
    end

    local divisor, suffix, decimals
    if gold < 1000000 then
        divisor, suffix = 1000, "k"
        if gold < 10000 then
            decimals = 2
        elseif gold < 100000 then
            decimals = 1
        else
            decimals = 0
        end
    else
        divisor, suffix = 1000000, "m"
        if gold < 10000000 then
            decimals = 2
        elseif gold < 100000000 then
            decimals = 1
        else
            decimals = 0
        end
    end

    local value = string.format("%." .. decimals .. "f", gold / divisor)
    if decimals > 0 then
        value = value:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    end
    return value .. suffix
end

local function FormatDashboardExactMoney(copperAmount)
    copperAmount = math.max(0, math.floor(tonumber(copperAmount) or 0))
    local gold = math.floor(copperAmount / 10000)
    local silver = math.floor((copperAmount % 10000) / 100)
    local copper = copperAmount % 100
    return string.format("%sg %ds %dc", FormatGoldThousands(gold), silver, copper)
end

-- 1. MAIN WINDOW
local LVWindow = CreateFrame("Frame", "LiteVaultWindow", UIParent, "BackdropTemplate")
LVWindow:SetSize(lv.Layout.mainFrameWidth, lv.Layout.mainFrameHeight)
LVWindow:SetPoint("CENTER")
LVWindow:SetFrameStrata("MEDIUM")
LVWindow:SetToplevel(true)
LVWindow:SetMovable(true)
LVWindow:EnableMouse(true)
LVWindow:RegisterForDrag("LeftButton")
LVWindow:SetScript("OnDragStart", LVWindow.StartMoving)
LVWindow:SetScript("OnDragStop", LVWindow.StopMovingOrSizing)
LVWindow:Hide()
lv.LVWindow = LVWindow

-- REGISTER FOR ESCAPE KEY CLOSING
tinsert(UISpecialFrames, "LiteVaultWindow") 

LVWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
lv.EnsureBorderStyle(LVWindow, "window")

-- Apply theme colors (initial application, will be updated by theme system)
local function ApplyMainWindowTheme(frame, theme)
    frame:SetBackdropColor(unpack(theme.background))
    lv.ApplyBorderStyle(frame, "window", theme)
end

-- Register for theme updates (called after theme system loads)
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(LVWindow, ApplyMainWindowTheme)
        ApplyMainWindowTheme(LVWindow, lv.GetTheme())
    end
end)

-- Close sub-windows when main window closes
LVWindow:SetScript("OnHide", function()
    if lv.LVCurrencyWindow then lv.LVCurrencyWindow:Hide() end
    if lv.LVVaultWindow then lv.LVVaultWindow:Hide() end
    if lv.WarbandLedgerWindow then lv.WarbandLedgerWindow:Hide() end
    if lv.LVProfessionWindow then lv.LVProfessionWindow:Hide() end
    if _G["LiteVaultRaidFrame"] then _G["LiteVaultRaidFrame"]:Hide() end
    if _G["LiteVaultInstancePanel"] then _G["LiteVaultInstancePanel"]:Hide() end
    if lv.HideTeleportPanel then
        lv.HideTeleportPanel()
    elseif _G["LiteVaultTeleportPanel"] then
        _G["LiteVaultTeleportPanel"]:Hide()
    end
    if _G["LiteVaultFactionWeeklyFrame"] then _G["LiteVaultFactionWeeklyFrame"]:Hide() end
    if _G["LiteVaultWeeklyPlannerFrame"] then _G["LiteVaultWeeklyPlannerFrame"]:Hide() end
    if lv.ProfitGraphWindow then lv.ProfitGraphWindow:Hide() end
    if lv.HideAllActionMenus then lv.HideAllActionMenus() end
end)

LVWindow:SetScript("OnShow", function()
    if lv.UpdateCurrentCharData then lv.UpdateCurrentCharData() end
    if lv.UpdateUI then lv.UpdateUI(true) end
end)

-- Custom "Close" Button (Main Window) - Enhanced styling
local closeBtn = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
closeBtn:SetSize((lv.Layout and lv.Layout.topCloseWidth) or 70, 26)
closeBtn:SetPoint("TOPRIGHT", -12, -12)
closeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

closeBtn.Text = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
closeBtn.Text:SetPoint("CENTER")
closeBtn.Text:SetText(L["BUTTON_CLOSE"])
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(closeBtn.Text, 11)
end

closeBtn:SetScript("OnClick", function() LVWindow:Hide() end)
closeBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
closeBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBg))
    self.Text:SetTextColor(unpack(t.textSecondary))
end)

-- Register close button for theming
local function ApplyCloseBtnTheme(btn, theme)
    btn:SetBackdropColor(unpack(theme.buttonBg))
    btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    btn.Text:SetTextColor(unpack(theme.textSecondary))
end
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(closeBtn, ApplyCloseBtnTheme)
        ApplyCloseBtnTheme(closeBtn, lv.GetTheme())
    end
end)

-- Instances Button
local instancesBtn = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
instancesBtn:SetSize((lv.Layout and lv.Layout.topInstancesWidth) or 90, 26)
instancesBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
instancesBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
instancesBtn.Text = instancesBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
instancesBtn.Text:SetPoint("CENTER")
instancesBtn.Text:SetText(L["BUTTON_INSTANCES"])
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(instancesBtn.Text, 11)
end
lv.instancesBtn = instancesBtn

instancesBtn:SetScript("OnClick", function()
    if lv.SetMainView then
        lv.SetMainView("instances")
    end
end)
instancesBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    local ttTitle = L["TOOLTIP_INSTANCE_TRACKER_TITLE"]
    local ttDesc = L["TOOLTIP_INSTANCE_TRACKER_DESC"]
    GameTooltip:SetText(ttTitle, 1, 0.82, 0)
    GameTooltip:AddLine(ttDesc, 1, 1, 1)
    GameTooltip:Show()
end)
instancesBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBg))
    self.Text:SetTextColor(unpack(t.textSecondary))
    GameTooltip:Hide()
end)
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(instancesBtn, ApplyCloseBtnTheme)
        ApplyCloseBtnTheme(instancesBtn, lv.GetTheme())
    end
end)
instancesBtn:Hide()
instancesBtn:EnableMouse(false)

local dashboardTab = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
dashboardTab:SetSize(92, 24)
dashboardTab:SetPoint("BOTTOMLEFT", LVWindow, "TOPLEFT", 34, -3)
dashboardTab:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
dashboardTab.Text = dashboardTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
dashboardTab.Text:SetPoint("CENTER")
dashboardTab.Text:SetText(UIText("BUTTON_DASHBOARD"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(dashboardTab.Text, 11)
end
lv.dashboardTab = dashboardTab

local profitTab = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
profitTab:SetSize(92, 24)
profitTab:SetPoint("LEFT", dashboardTab, "RIGHT", -4, 0)
profitTab:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
profitTab.Text = profitTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
profitTab.Text:SetPoint("CENTER")
profitTab.Text:SetText(UIText("BUTTON_PROFIT"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(profitTab.Text, 11)
end
lv.profitTab = profitTab

local folioTab = nil
lv.folioTab = nil

local instancesTab = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
instancesTab:SetSize(92, 24)
instancesTab:SetPoint("LEFT", profitTab, "RIGHT", -4, 0)
instancesTab:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
instancesTab.Text = instancesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
instancesTab.Text:SetPoint("CENTER")
instancesTab.Text:SetText(UIText("BUTTON_INSTANCES"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(instancesTab.Text, 11)
end
lv.instancesTab = instancesTab

local achievementsBtn = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
achievementsBtn:SetSize(110, 24)
achievementsBtn:SetPoint("LEFT", instancesTab, "RIGHT", -4, 0)
achievementsBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
achievementsBtn.Text = achievementsBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
achievementsBtn.Text:SetPoint("CENTER")
achievementsBtn.Text:SetText(UIText("BUTTON_ACHIEVEMENTS"))
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(achievementsBtn.Text, 11)
end
lv.achievementsBtn = achievementsBtn

local factionsTab = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
factionsTab:SetSize(92, 24)
factionsTab:SetPoint("LEFT", achievementsBtn, "RIGHT", -4, 0)
factionsTab:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
factionsTab.Text = factionsTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
factionsTab.Text:SetPoint("CENTER")
factionsTab.Text:SetText(L["BUTTON_FACTIONS"])
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(factionsTab.Text, 11)
end
lv.factionsTab = factionsTab

local optionsTab = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
optionsTab:SetSize(92, 24)
optionsTab:SetPoint("LEFT", factionsTab, "RIGHT", -4, 0)
optionsTab:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
optionsTab.Text = optionsTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsTab.Text:SetPoint("CENTER")
optionsTab.Text:SetText(L["BUTTON_OPTIONS"])
if lv.ApplyLocaleFont then
    lv.ApplyLocaleFont(optionsTab.Text, 11)
end
lv.optionsTab = optionsTab

local function UpdateTopTabLayout()
    local function FitTabWidth(tab, minWidth)
        if not tab or not tab.Text then return minWidth or 92 end
        local textWidth = math.ceil(tab.Text:GetStringWidth() or 0)
        local width = math.max(minWidth or 92, textWidth + 22)
        tab:SetWidth(width)
        return width
    end

    FitTabWidth(dashboardTab, 92)
    FitTabWidth(profitTab, 92)
    FitTabWidth(instancesTab, 92)
    FitTabWidth(achievementsBtn, 110)
    FitTabWidth(factionsTab, 92)
    FitTabWidth(optionsTab, 92)

    optionsTab:ClearAllPoints()
    optionsTab:SetPoint("BOTTOMLEFT", LVWindow, "TOPLEFT", 34, -3)
    dashboardTab:ClearAllPoints()
    dashboardTab:SetPoint("LEFT", optionsTab, "RIGHT", -4, 0)
    profitTab:ClearAllPoints()
    profitTab:SetPoint("LEFT", dashboardTab, "RIGHT", -4, 0)
    factionsTab:ClearAllPoints()
    factionsTab:SetPoint("LEFT", profitTab, "RIGHT", -4, 0)
    achievementsBtn:ClearAllPoints()
    achievementsBtn:SetPoint("LEFT", factionsTab, "RIGHT", -4, 0)
    instancesTab:ClearAllPoints()
    instancesTab:SetPoint("LEFT", achievementsBtn, "RIGHT", -4, 0)
end

UpdateTopTabLayout()

dashboardTab:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
dashboardTab:SetScript("OnLeave", function()
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

profitTab:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
profitTab:SetScript("OnLeave", function()
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

achievementsBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
achievementsBtn:SetScript("OnLeave", function()
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

instancesTab:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
instancesTab:SetScript("OnLeave", function()
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

optionsTab:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
optionsTab:SetScript("OnLeave", function()
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

factionsTab:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
factionsTab:SetScript("OnLeave", function()
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

-- Raid Lockouts Button
local raidLockoutsBtn = CreateFrame("Button", nil, LVWindow, "BackdropTemplate")
raidLockoutsBtn:SetSize(120, 26)
raidLockoutsBtn:SetPoint("RIGHT", instancesBtn, "LEFT", -8, 0)
raidLockoutsBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

raidLockoutsBtn.Text = raidLockoutsBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
raidLockoutsBtn.Text:SetPoint("CENTER")
raidLockoutsBtn.Text:SetText(L["BUTTON_RAID_LOCKOUTS"])

raidLockoutsBtn:SetScript("OnClick", function()
    if lv.ShowRaidLockoutWindow then
        lv.ShowRaidLockoutWindow()
    end
end)
raidLockoutsBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))

    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(L["TOOLTIP_RAID_LOCKOUTS_TITLE"], 1, 0.82, 0)
    GameTooltip:AddLine(L["TOOLTIP_RAID_LOCKOUTS_DESC"], 1, 1, 1)
    GameTooltip:Show()
end)

-- Register raid lockouts button for theming
local function ApplyRaidBtnTheme(btn, theme)
    btn:SetBackdropColor(unpack(theme.buttonBg))
    btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    btn.Text:SetTextColor(unpack(theme.textSecondary))
end
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(raidLockoutsBtn, ApplyRaidBtnTheme)
        ApplyRaidBtnTheme(raidLockoutsBtn, lv.GetTheme())
    end
end)
raidLockoutsBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBg))
    self.Text:SetTextColor(unpack(t.textSecondary))
    GameTooltip:Hide()
end)

-- Raid access now lives on per-character rows via the "Raids" button.
raidLockoutsBtn:Hide()
raidLockoutsBtn:EnableMouse(false)

-- Theme and Language buttons moved to Options panel in List.lua

local mainTitle = LVWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
mainTitle:SetPoint("TOP", 0, -20)
mainTitle:SetText(L["TITLE_LITEVAULT"])
mainTitle:SetTextColor(1, 0.82, 0)

local versionText = LVWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
versionText:SetPoint("TOP", mainTitle, "BOTTOM", 0, -4)
versionText:SetText("|cff9933ff" .. L["ADDON_VERSION"] .. "|r")

-- 2. FILTER FRAME
local FilterFrame = CreateFrame("Frame", "LiteVaultFilterFrame", LVWindow, "BackdropTemplate")
FilterFrame:SetSize(180, 240)
FilterFrame:Hide()
FilterFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
lv.EnsureBorderStyle(FilterFrame, "panelCompact")

local fTitle = FilterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
fTitle:SetPoint("TOPLEFT", 15, -12)
fTitle:SetText(L["TITLE_MAP_FILTERS"])

-- Filter Frame "Close" Button
local fClose = CreateFrame("Button", nil, FilterFrame, "BackdropTemplate")
fClose:SetSize(60, 22)
fClose:SetPoint("TOPRIGHT", -5, -5)
fClose:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })

fClose.Text = fClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fClose.Text:SetPoint("CENTER")
fClose.Text:SetText(L["BUTTON_CLOSE"])

fClose:SetScript("OnClick", function() FilterFrame:Hide() end)
fClose:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
fClose:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

-- Register filter frame for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(FilterFrame, function(f, theme)
            f:SetBackdropColor(unpack(theme.background))
            lv.ApplyBorderStyle(f, "panelCompact", theme)
        end)
        lv.RegisterThemedElement(fClose, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        -- Apply initial theme
        local t = lv.GetTheme()
        FilterFrame:SetBackdropColor(unpack(t.background))
        lv.ApplyBorderStyle(FilterFrame, "panelCompact", t)
        fClose:SetBackdropColor(unpack(t.buttonBgAlt))
        fClose:SetBackdropBorderColor(unpack(t.borderPrimary))
        fClose.Text:SetTextColor(unpack(t.textPrimary))
    end
end)

lv.FilterFrame = FilterFrame
lv.filterChecks = {}

local selectAll = CreateFrame("Button", nil, FilterFrame, "BackdropTemplate")
selectAll:SetSize(70, 22)
selectAll:SetPoint("TOPLEFT", 15, -35)
selectAll:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
selectAll.Text = selectAll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
selectAll.Text:SetPoint("CENTER"); selectAll.Text:SetText(L["BUTTON_ALL"])
selectAll:SetScript("OnClick", function()
    for k in pairs(LiteVaultDB.filters) do
        LiteVaultDB.filters[k] = true
        if lv.filterChecks[k] then lv.filterChecks[k]:SetChecked(true) end
    end
    if lv.UpdateCalendar then lv.UpdateCalendar() end
end)
selectAll:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
selectAll:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
end)

local unselectAll = CreateFrame("Button", nil, FilterFrame, "BackdropTemplate")
unselectAll:SetSize(70, 22); unselectAll:SetPoint("LEFT", selectAll, "RIGHT", 5, 0)
unselectAll:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
unselectAll.Text = unselectAll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
unselectAll.Text:SetPoint("CENTER"); unselectAll.Text:SetText(L["BUTTON_NONE"])
unselectAll:SetScript("OnClick", function()
    for k in pairs(LiteVaultDB.filters) do
        LiteVaultDB.filters[k] = false
        if lv.filterChecks[k] then lv.filterChecks[k]:SetChecked(false) end
    end
    if lv.UpdateCalendar then lv.UpdateCalendar() end
end)
unselectAll:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
unselectAll:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
end)

-- Register filter buttons for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(selectAll, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(unselectAll, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        -- Apply initial theme
        local t = lv.GetTheme()
        selectAll:SetBackdropColor(unpack(t.buttonBgAlt))
        selectAll:SetBackdropBorderColor(unpack(t.borderPrimary))
        selectAll.Text:SetTextColor(unpack(t.textPrimary))
        unselectAll:SetBackdropColor(unpack(t.buttonBgAlt))
        unselectAll:SetBackdropBorderColor(unpack(t.borderPrimary))
        unselectAll.Text:SetTextColor(unpack(t.textPrimary))
    end
end)

local filterList = { {textKey="FILTER_TIMEWALKING", k="timewalking"}, {textKey="FILTER_DARKMOON", k="darkmoon"}, {textKey="FILTER_DUNGEONS", k="dungeon"}, {textKey="FILTER_PVP", k="pvp"}, {textKey="FILTER_BONUS", k="bonus"} }
for i, item in ipairs(filterList) do
    local cb = CreateFrame("CheckButton", nil, FilterFrame, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 15, -60 - (i-1)*28); cb.Text:SetText(L[item.textKey]); cb.key = item.k
    cb:SetScript("OnClick", function(self) LiteVaultDB.filters[self.key] = self:GetChecked(); if lv.UpdateCalendar then lv.UpdateCalendar() end end)
    lv.filterChecks[item.k] = cb
end

-- 3. INITIALIZE SUB-MODULES
lv.InitCalendar(LVWindow)
lv.InitList(LVWindow, LVWindow)

-- 3.5. SORT CONTROLS (NEW)
local sortFrame = CreateFrame("Frame", nil, LVWindow)
sortFrame:SetPoint("TOPLEFT", 35, -65) -- Moved way down from -35 to -65
sortFrame:SetSize(540, 25)
lv.sortFrame = sortFrame

local sortLabel = sortFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sortLabel:SetPoint("LEFT", 0, 0)
sortLabel:SetText(L["LABEL_SORT_BY"])

-- Register sort label with the canonical LiteVault title accent.
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(sortLabel, function(label, theme)
            label:SetTextColor(unpack(theme.textGold))
        end)
        sortLabel:SetTextColor(unpack(lv.GetTheme().textGold))
    end
end)

local sortButtons = {}
local sortModes = {
    {textKey = "SORT_GOLD", mode = "gold"},
    {textKey = "SORT_ILVL", mode = "ilvl"},
    {textKey = "SORT_MPLUS", mode = "mplus"},
    {textKey = "SORT_LAST_ACTIVE", mode = "lastActive"}
}

local function UpdateSortButtonStates(theme)
    local t = theme or lv.GetTheme()
    if not t then return end
    local activeMode = lv.NormalizeCharacterSortMode and lv.NormalizeCharacterSortMode(lv.currentSortMode) or lv.currentSortMode or "gold"

    for _, b in ipairs(sortButtons) do
        if activeMode == b.mode then
            b:SetBackdropBorderColor(unpack(t.borderPrimary))
            b:SetBackdropColor(unpack(t.tabActive))
            b.text:SetTextColor(unpack(t.textPrimary))
        else
            b:SetBackdropBorderColor(unpack(t.borderSubdued))
            b:SetBackdropColor(unpack(t.tabInactive))
            b.text:SetTextColor(unpack(t.textSecondary))
        end
    end
end

lv.UpdateSortButtonStates = UpdateSortButtonStates

for i, sortInfo in ipairs(sortModes) do
    local btn = CreateFrame("Button", nil, sortFrame, "BackdropTemplate")
    btn:SetSize(75, 24)
    if i == 1 then
        btn:SetPoint("LEFT", sortLabel, "RIGHT", 10, 0)
    else
        btn:SetPoint("LEFT", sortButtons[i - 1], "RIGHT", 8, 0)
    end
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(L[sortInfo.textKey])

    btn.mode = sortInfo.mode

    btn:SetScript("OnClick", function(self)
        -- Sort and update
        if lv.SortCharacterList then lv.SortCharacterList(self.mode) end
        if lv.UpdateSortButtonStates then lv.UpdateSortButtonStates() end
        if lv.UpdateUI then lv.UpdateUI() end
    end)

    btn:SetScript("OnEnter", function(self)
        if lv.currentSortMode ~= self.mode then
            local t = lv.GetTheme()
            self:SetBackdropBorderColor(unpack(t.borderHover))
            self:SetBackdropColor(unpack(t.buttonBgHover))
        end
    end)

    btn:SetScript("OnLeave", function(self)
        if lv.currentSortMode ~= self.mode then
            local t = lv.GetTheme()
            self:SetBackdropBorderColor(unpack(t.borderSubdued))
            self:SetBackdropColor(unpack(t.tabInactive))
        end
    end)

    sortButtons[i] = btn
end

-- Store reference and register sort buttons for theming
lv.sortButtons = sortButtons

-- Apply initial theme to sort buttons
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for _, btn in ipairs(sortButtons) do
            lv.RegisterThemedElement(btn, function(b, theme)
                UpdateSortButtonStates(theme)
            end)
        end
    end
    if lv.SortCharacterList then
        lv.SortCharacterList((LiteVaultDB and LiteVaultDB.characterSortMode) or lv.currentSortMode)
    end
    UpdateSortButtonStates()
end)

local currentMainView = "dashboard"
local FactionWeeklyWindow

local function ApplyGoldBoxLayout(view)
    if not lv.GoldBox then return end

    lv.GoldBox:ClearAllPoints()
    if view == "profit" then
        lv.GoldBox:SetPoint("TOPLEFT", LVWindow, "TOPLEFT", 18, -74)
        lv.GoldBox:SetPoint("BOTTOMRIGHT", LVWindow, "BOTTOMRIGHT", -18, 18)
    else
        lv.GoldBox:SetSize(360, 218)
        if lv.WeeklyBox then
            lv.GoldBox:SetPoint("TOP", lv.WeeklyBox, "BOTTOM", 0, -6)
        end
    end
end

local function SetDashboardContentVisible(visible)
    local method = visible and "Show" or "Hide"
    if lv.charBg and lv.charBg[method] then lv.charBg[method](lv.charBg) end
    if lv.CalFrame and lv.CalFrame[method] then lv.CalFrame[method](lv.CalFrame) end
    if lv.WeeklyBox and lv.WeeklyBox[method] then lv.WeeklyBox[method](lv.WeeklyBox) end
    ApplyGoldBoxLayout("dashboard")
    if lv.GoldBox then lv.GoldBox:Hide() end
    if lv.SetDashboardFolioVisible then lv.SetDashboardFolioVisible(visible) end
    if LVWindow.totalBg and LVWindow.totalBg[method] then LVWindow.totalBg[method](LVWindow.totalBg) end
    if lv.sortFrame and lv.sortFrame[method] then lv.sortFrame[method](lv.sortFrame) end
    if lv.manageBtn and lv.manageBtn[method] then lv.manageBtn[method](lv.manageBtn) end
    if not visible then
        if lv.FilterFrame then lv.FilterFrame:Hide() end
        if lv.WorldEventsFrame then lv.WorldEventsFrame:Hide() end
        if _G["LiteVaultWeeklyPlannerFrame"] then _G["LiteVaultWeeklyPlannerFrame"]:Hide() end
    end
end

local function SetProfitContentVisible(visible)
    if not lv.GoldBox then return end

    if visible then
        ApplyGoldBoxLayout("profit")
        lv.GoldBox:Show()
    else
        ApplyGoldBoxLayout("dashboard")
        lv.GoldBox:Hide()
    end
end

local function SetFactionCardsVisible(visible)
    for _, card in ipairs(lv.factionCards or {}) do
        if card then
            if visible then
                card:Show()
            else
                card:Hide()
            end
        end
    end
end

lv.UIText = UIText
if lv.InitAchievementsUI then
    lv.InitAchievementsUI({
        LVWindow = LVWindow,
        dashboardTab = dashboardTab,
        profitTab = profitTab,
        instancesTab = instancesTab,
        achievementsBtn = achievementsBtn,
        factionsTab = factionsTab,
        optionsTab = optionsTab,
        UIText = UIText,
        getCurrentMainView = function() return currentMainView end,
        setCurrentMainView = function(view) currentMainView = view end,
        setDashboardContentVisible = SetDashboardContentVisible,
        setProfitContentVisible = SetProfitContentVisible,
        setFolioContentVisible = function(visible)
            if lv.SetFolioContentVisible then
                lv.SetFolioContentVisible(visible)
            end
        end,
        setFactionCardsVisible = SetFactionCardsVisible,
        getFactionWeeklyWindow = function() return FactionWeeklyWindow end,
    })
end

-- 4. TRACKING DISPLAYS
local WeeklyBox = CreateFrame("Frame", nil, LVWindow, "BackdropTemplate")
WeeklyBox:SetSize(360, math.max(lv.Layout.weeklyBoxHeight or 120, 170))
WeeklyBox:SetPoint("TOP", lv.CalFrame, "BOTTOM", 0, -8) -- Centered under calendar
WeeklyBox:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
lv.EnsureBorderStyle(WeeklyBox, "panelStructural")

-- Store reference for theming
lv.WeeklyBox = WeeklyBox

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(WeeklyBox, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundTransparent))
            lv.ApplyBorderStyle(f, "panelStructural", theme)
        end)
        local t = lv.GetTheme()
        WeeklyBox:SetBackdropColor(unpack(t.backgroundTransparent))
        lv.ApplyBorderStyle(WeeklyBox, "panelStructural", t)
    end
end)
if lv.AttachFolioDashboardFrame then
    lv.AttachFolioDashboardFrame()
end
local weeklyViewMode = "weeklies"
local function CreateWeeklyContentArea()
    local title = WeeklyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)

    local summary = WeeklyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    summary:SetPoint("TOP", title, "BOTTOM", 0, -5)
    summary:SetText("")

    local content = WeeklyBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    content:SetPoint("TOPLEFT", 15, -50)
    content:SetPoint("RIGHT", -15, 0)
    content:SetJustifyH("LEFT")
    content:SetWordWrap(true)
    content:SetSpacing(lv.Layout.verticalPadding)

    local warning = WeeklyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    warning:SetPoint("TOPLEFT", 15, -50)
    warning:SetJustifyH("LEFT")
    warning:SetTextColor(1, 0.15, 0.15)
    warning:SetText("")
    warning:Hide()

    return title, summary, content, warning
end

local weeklyUI = {}
weeklyUI.title, weeklyUI.summary, weeklyUI.content, weeklyUI.warning = CreateWeeklyContentArea()
weeklyUI.rows = {}
lv.weeklyUI = weeklyUI

local WEEKLY_ROW_HEIGHT = 28
local WEEKLY_METADATA_ROW_HEIGHT = 32
local WEEKLY_ROW_GAP = 3
local WEEKLY_STATUS_WIDTH = 116

local function ApplyWeeklyQuestRowTheme(row, theme)
    row:SetBackdropColor(unpack(theme.weeklyQuestRowBg))
    row:SetBackdropBorderColor(unpack(theme.weeklyQuestRowBorder))
    row.name:SetTextColor(unpack(theme.textPrimary))
    row.metadata:SetTextColor(unpack(theme.textMuted))
end

local function EnsureWeeklyQuestRow(index)
    local row = weeklyUI.rows[index]
    if row then return row end

    row = CreateFrame("Frame", nil, WeeklyBox, "BackdropTemplate")
    row:SetSize(320, WEEKLY_ROW_HEIGHT)
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })

    row.status = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.status:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    row.status:SetWidth(WEEKLY_STATUS_WIDTH)
    row.status:SetJustifyH("RIGHT")

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("TOPLEFT", 11, -4)
    row.name:SetPoint("RIGHT", row.status, "LEFT", -10, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)

    row.metadata = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.metadata:SetPoint("TOPLEFT", row, "TOPLEFT", 11, -19)
    row.metadata:SetPoint("RIGHT", row.status, "LEFT", -10, 0)
    row.metadata:SetJustifyH("LEFT")
    row.metadata:SetWordWrap(false)

    weeklyUI.rows[index] = row
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(row, ApplyWeeklyQuestRowTheme)
    end
    ApplyWeeklyQuestRowTheme(row, lv.GetTheme())
    return row
end

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(weeklyUI.title, function(label, theme)
            label:SetTextColor(unpack(theme.textGold))
        end)
        lv.RegisterThemedElement(weeklyUI.summary, function(label, theme)
            label:SetTextColor(unpack(theme.weeklyQuestSummaryText))
        end)
    end
    local t = lv.GetTheme()
    weeklyUI.title:SetTextColor(unpack(t.textGold))
    weeklyUI.summary:SetTextColor(unpack(t.weeklyQuestSummaryText))
end)

local weeklyTabDefs = {
    { key = "weeklies", labelKey = "BUTTON_WEEKLIES", quests = function() return lv.WEEKLY_QUESTS or {} end },
}
local factionWeeklyTabDefs = {
    { key = "amani", labelKey = "BUTTON_AMANI_TRIBE", quests = function() return lv.WEEKLY_AMANI_TRIBE_QUESTS or {} end },
    { key = "harati", labelKey = "BUTTON_HARATI", quests = function() return lv.WEEKLY_HARATI_QUESTS or {} end },
    { key = "singularity", labelKey = "BUTTON_SINGULARITY", quests = function() return lv.WEEKLY_SINGULARITY_QUESTS or {} end },
    { key = "silvermoon", labelKey = "BUTTON_SILVERMOON_COURT", quests = function() return lv.WEEKLY_SILVERMOON_COURT_QUESTS or {} end, warningKey = "WARNING_WEEKLY_RUNESTONES" },
    { key = "ritualsites", labelKey = "BUTTON_RITUAL_SITES", quests = function() return lv.WEEKLY_RITUAL_SITES_QUESTS or {} end },
    { key = "zuljarra", labelKey = "BUTTON_ZULJARRA_FORCES", quests = function() return lv.WEEKLY_ZULJARRA_QUESTS or {} end },
}

local function GetWeeklyTabDef(mode)
    for _, def in ipairs(weeklyTabDefs) do
        if def.key == mode then
            return def
        end
    end
end

local function GetFactionWeeklyTabDef(mode)
    for _, def in ipairs(factionWeeklyTabDefs) do
        if def.key == mode then
            return def
        end
    end
end

local function GetCurrentWeeklyQuestList()
    local def = GetWeeklyTabDef(weeklyViewMode)
    local questList = (def and def.quests and def.quests()) or {}
    local filtered = {}

    for _, quest in ipairs(questList) do
        if quest.dashboard ~= false then
            filtered[#filtered + 1] = quest
        end
    end

    return filtered
end
lv.GetCurrentWeeklyQuestList = GetCurrentWeeklyQuestList

local function BuildWeeklyWarningText()
    local def = GetWeeklyTabDef(weeklyViewMode)
    local warningText = (def and def.warningKey and L[def.warningKey]) or ""
    if weeklyViewMode == "events" then
        return ""
    end
    return warningText
end
lv.BuildWeeklyWarningText = BuildWeeklyWarningText

local function UpdateWeeklyWarningLayout(warningText)
    weeklyUI.warning:SetText(warningText or "")
    if warningText and warningText ~= "" then
        weeklyUI.warning:Show()
        weeklyUI.content:SetPoint("TOPLEFT", 15, -68)
    else
        weeklyUI.warning:Hide()
        weeklyUI.content:SetPoint("TOPLEFT", 15, -50)
    end
end
lv.UpdateWeeklyWarningLayout = UpdateWeeklyWarningLayout

local function NormalizeWeeklyQuestTitle(title)
    if type(title) ~= "string" then return nil end
    title = title:gsub("’", "'"):gsub("‘", "'")
    title = title:gsub("：", ":"):gsub("，", ",")
    title = title:gsub("’", "'"):gsub("‘", "'")
    title = title:gsub("ï¼š", ":"):gsub("：", ":")
    title = title:gsub("%s+", " ")
    title = title:match("^%s*(.-)%s*$")
    if title == "" then return nil end
    return title:lower()
end

local function BuildWeeklyQuestTitleSet(quest)
    local titles = {}
    if not quest or not quest.name then return titles end

    local function AddTitle(title)
        local normalized = NormalizeWeeklyQuestTitle(title)
        if normalized then
            titles[normalized] = true
        end
    end

    local localized = L[quest.name]
    AddTitle(localized)
    AddTitle(quest.name)
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        AddTitle(C_QuestLog.GetTitleForQuestID(quest.id))
        if quest.variants then
            for _, variantID in ipairs(quest.variants) do
                AddTitle(C_QuestLog.GetTitleForQuestID(variantID))
            end
        end
    end

    return titles
end

local function GetFreshSavedAccountWideWeeklyQuestRecord(quest)
    if not (quest and quest.accountWide and LiteVaultDB and LiteVaultDB.accountWideWeeklyQuests) then
        return nil
    end
    local saved = LiteVaultDB.accountWideWeeklyQuests[quest.name]
    local currentReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    if saved and currentReset and ((not saved.updatedAt) or saved.updatedAt < currentReset) then
        saved = nil
    end
    return saved
end

local function GetSavedWeeklyQuestState(quest)
    local saved = GetFreshSavedAccountWideWeeklyQuestRecord(quest)
    return saved and saved.state or nil
end

local function RecoverAccountWideWeeklyQuestState(quest)
    if not (quest and quest.accountWide and LiteVaultDB) then
        return nil
    end

    local currentReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    local recovered

    for charKey, charData in pairs(LiteVaultDB) do
        if type(charData) == "table" and charData.class then
            local saved = charData.weeklyQuests and charData.weeklyQuests[quest.name]
            if saved and saved.state == "done" then
                if currentReset and ((not saved.updatedAt) or saved.updatedAt < currentReset) then
                    -- stale entry from a prior week
                else
                    recovered = {
                        state = saved.state,
                        questID = saved.questID,
                        title = saved.title,
                        sourceKey = charKey,
                        updatedAt = saved.updatedAt,
                    }
                    break
                end
            end
        end
    end

    if recovered then
        LiteVaultDB.accountWideWeeklyQuests = LiteVaultDB.accountWideWeeklyQuests or {}
        recovered.source = recovered.source or "recovered_char_done"
        LiteVaultDB.accountWideWeeklyQuests[quest.name] = recovered
        return recovered.state
    end

    return nil
end

local function GetFreshSavedCharacterWeeklyQuestRecord(quest)
    if not (quest and quest.name and LiteVaultDB and lv.PLAYER_KEY) then
        return nil
    end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    local saved = db and db.weeklyQuests and db.weeklyQuests[quest.name]
    local currentReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    if saved and currentReset and ((not saved.updatedAt) or saved.updatedAt < currentReset) then
        saved = nil
    end
    return saved
end

local function GetSavedCharacterWeeklyQuestState(quest)
    local saved = GetFreshSavedCharacterWeeklyQuestRecord(quest)
    return saved and saved.state or nil
end

local function GetWeeklyQuestVariantDisplayName(quest, questID)
    if quest and questID and quest.variantNames and quest.variantNames[questID] then
        return L[quest.variantNames[questID]]
    end
    if questID and C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local title = C_QuestLog.GetTitleForQuestID(questID)
        if title and title ~= "" then
            return title
        end
    end
    return quest and L[quest.name] or ""
end

local function GetRotatingWeeklyQuestID(quest)
    if not (quest and quest.rotation and quest.rotation.referenceReset and quest.rotation.questIDs and lv.GetLastWeeklyReset) then
        return nil
    end
    local ids = quest.rotation.questIDs
    if #ids == 0 then return nil end

    local elapsedWeeks = math.floor((lv.GetLastWeeklyReset() - quest.rotation.referenceReset) / 604800)
    return ids[(elapsedWeeks % #ids) + 1]
end

local function GetNextRotatingWeeklyQuestID(quest)
    if not (quest and quest.rotation and quest.rotation.referenceReset and quest.rotation.questIDs and lv.GetLastWeeklyReset) then
        return nil
    end
    local ids = quest.rotation.questIDs
    if #ids == 0 then return nil end

    local elapsedWeeks = math.floor((lv.GetLastWeeklyReset() - quest.rotation.referenceReset) / 604800) + 1
    return ids[(elapsedWeeks % #ids) + 1]
end

local function GetWeeklyQuestDisplayName(quest)
    if not quest then return "" end

    if quest.name == "Legends of the Haranir" then
        return L[quest.name]
    end

    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        if C_QuestLog.GetLogIndexForQuestID(quest.id) then
            return GetWeeklyQuestVariantDisplayName(quest, quest.id)
        end
        if quest.variants then
            for _, variantID in ipairs(quest.variants) do
                if C_QuestLog.GetLogIndexForQuestID(variantID) then
                    return GetWeeklyQuestVariantDisplayName(quest, variantID)
                end
            end
        end
    end

    local saved = GetFreshSavedAccountWideWeeklyQuestRecord(quest) or GetFreshSavedCharacterWeeklyQuestRecord(quest)
    if saved and saved.questID then
        return GetWeeklyQuestVariantDisplayName(quest, saved.questID)
    end

    local rotatingQuestID = GetRotatingWeeklyQuestID(quest)
    if rotatingQuestID then
        return GetWeeklyQuestVariantDisplayName(quest, rotatingQuestID)
    end

    return GetWeeklyQuestVariantDisplayName(quest, quest.id)
end

local function BuildWeeklyQuestNextWeekText(quest)
    local nextQuestID = GetNextRotatingWeeklyQuestID(quest)
    if not nextQuestID then return nil end

    local nextName = GetWeeklyQuestVariantDisplayName(quest, nextQuestID)
    local label = L["LABEL_NEXT_WEEK_FMT"]
    return "|cff999999" .. string.format(label, nextName) .. "|r"
end

local function FindNearbyWeeklyQuestState(quest)
    if not (quest and quest.accountWide and quest.searchRange and C_QuestLog.GetTitleForQuestID) then
        return nil
    end

    local minQuestID = quest.id
    local maxQuestID = quest.id
    if quest.variants then
        for _, variantID in ipairs(quest.variants) do
            minQuestID = math.min(minQuestID, variantID)
            maxQuestID = math.max(maxQuestID, variantID)
        end
    end

    local titleSet = BuildWeeklyQuestTitleSet(quest)
    local foundInProgress = false

    for candidateID = math.max(1, minQuestID - quest.searchRange), maxQuestID + quest.searchRange do
        local title = C_QuestLog.GetTitleForQuestID(candidateID)
        if titleSet[NormalizeWeeklyQuestTitle(title)] then
            if C_QuestLog.IsQuestFlaggedCompleted(candidateID) then
                return "done"
            end
            if C_QuestLog.IsQuestFlaggedCompletedOnAccount and C_QuestLog.IsQuestFlaggedCompletedOnAccount(candidateID) then
                return "done"
            end
            if C_QuestLog.GetLogIndexForQuestID(candidateID) then
                foundInProgress = true
            end
        end
    end

    if foundInProgress then
        return "in_progress"
    end

    return nil
end

local function IsWeeklyQuestCompleted(questID, quest)
    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
        return true
    end
    if quest and quest.accountWide and C_QuestLog.IsQuestFlaggedCompletedOnAccount then
        return C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) and true or false
    end
    return false
end

local function GetGroupedWeeklyQuestState(quest)
    local sharedState = GetSavedWeeklyQuestState(quest)
    if not sharedState then
        sharedState = RecoverAccountWideWeeklyQuestState(quest)
    end
    if sharedState == "done" then
        return "done"
    end

    local savedState = GetSavedCharacterWeeklyQuestState(quest)
    if savedState == "done" then
        return "done"
    end

    local foundCompleted = false
    local foundInProgress = false
    local activeOnlyLookup = nil
    local currentWeekOnly = quest and quest.currentWeekOnly

    if quest.activeOnlyVariants then
        activeOnlyLookup = {}
        for _, variantID in ipairs(quest.activeOnlyVariants) do
            activeOnlyLookup[variantID] = true
        end
    end

    if not currentWeekOnly and C_QuestLog.IsQuestFlaggedCompleted(quest.id) then
        foundCompleted = true
    elseif C_QuestLog.GetLogIndexForQuestID(quest.id) then
        foundInProgress = true
    end

    if not foundCompleted and quest.id == 82449 then
        for i = 1, C_QuestLog.GetNumQuestLogEntries() do
            local info = C_QuestLog.GetInfo(i)
            if info and not info.isHeader and info.title and info.title:match("^Worldsoul:") then
                if C_QuestLog.IsQuestFlaggedCompleted(info.questID) then
                    foundCompleted = true
                else
                    foundInProgress = true
                end
                break
            end
        end
    end

    if not foundCompleted and quest.variants then
        for _, variantID in ipairs(quest.variants) do
            local isActiveOnlyVariant = activeOnlyLookup and activeOnlyLookup[variantID]
            if currentWeekOnly and isActiveOnlyVariant and C_QuestLog.IsQuestFlaggedCompleted(variantID) then
                foundCompleted = true
                break
            elseif not currentWeekOnly and not isActiveOnlyVariant and C_QuestLog.IsQuestFlaggedCompleted(variantID) then
                foundCompleted = true
                break
            elseif C_QuestLog.GetLogIndexForQuestID(variantID) then
                foundInProgress = true
            end
        end
    end

    if foundCompleted then
        return "done"
    elseif foundInProgress then
        return "in_progress"
    end

    return "not_started"
end

local function GetWeeklyQuestState(quest)
    local sharedState = GetSavedWeeklyQuestState(quest)
    if not sharedState then
        sharedState = RecoverAccountWideWeeklyQuestState(quest)
    end
    if sharedState == "done" then
        return "done"
    end

    local savedState = GetSavedCharacterWeeklyQuestState(quest)
    if savedState == "done" then
        return "done"
    end

    if quest.id == 82449 or quest.variants then
        return GetGroupedWeeklyQuestState(quest)
    end

    if quest.currentWeekOnly then
        if C_QuestLog.GetLogIndexForQuestID(quest.id) then
            return "in_progress"
        end
        return "not_started"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(quest.id) then
        return "done"
    elseif C_QuestLog.GetLogIndexForQuestID(quest.id) then
        return "in_progress"
    end

    return "not_started"
end

local function BuildWeeklyQuestStatusText(state)
    if state == "done" then
        return "|cff00ff00" .. L["STATUS_DONE"] .. "|r"
    elseif state == "in_progress" then
        return "|cffffff00" .. L["STATUS_IN_PROGRESS"] .. "|r"
    end

    return "|cffff0000" .. L["STATUS_NOT_STARTED"] .. "|r"
end

local function BuildWeeklyQuestText(data, questList)
    if not questList or #questList == 0 then
        return L["MSG_NO_WEEKLY_QUESTS_CONFIGURED"]
    end

    local rows = {}
    for _, quest in ipairs(questList) do
        local state = GetWeeklyQuestState(quest)
        local status = BuildWeeklyQuestStatusText(state)
        data.weeklyQuests[quest.id] = status
        local rowLabel = L[quest.name]
        if quest.name == "Community Engagement" then
            rows[#rows + 1] = string.format("%s - |cffff5555%s|r %s", rowLabel, L["WARNING_ACCOUNT_BOUND"], status)
        else
            local rowText = rowLabel .. ": " .. status
            rows[#rows + 1] = rowText
        end
    end

    return table.concat(rows, "\n") .. "\n"
end
lv.BuildWeeklyQuestText = BuildWeeklyQuestText

local function GetWeeklyQuestStatusLabel(state)
    local key = state == "done" and "STATUS_DONE"
        or state == "in_progress" and "STATUS_IN_PROGRESS"
        or "STATUS_NOT_STARTED"
    return tostring(L[key] or key):gsub("^%[", ""):gsub("%]$", ""):gsub("%-", " ")
end

local function RenderWeeklyQuestRows(data, questList)
    questList = questList or {}
    data.weeklyQuests = data.weeklyQuests or {}
    weeklyUI.content:Hide()

    for _, row in ipairs(weeklyUI.rows) do
        row:Hide()
    end

    if #questList == 0 then
        weeklyUI.summary:SetText(string.format(UIText("LABEL_WEEKLY_COMPLETION_SUMMARY", "%d / %d Complete"), 0, 0))
        weeklyUI.content:SetText(L["MSG_NO_WEEKLY_QUESTS_CONFIGURED"])
        weeklyUI.content:ClearAllPoints()
        weeklyUI.content:SetPoint("TOP", weeklyUI.summary, "BOTTOM", 0, -12)
        weeklyUI.content:SetWidth(320)
        weeklyUI.content:SetJustifyH("CENTER")
        weeklyUI.content:Show()
        return
    end

    local completed = 0
    local theme = lv.GetTheme()
    local rowTop = -42
    for index, quest in ipairs(questList) do
        local state = GetWeeklyQuestState(quest)
        if state == "done" then completed = completed + 1 end

        -- Preserve the existing weeklyQuests snapshot representation.
        data.weeklyQuests[quest.id] = BuildWeeklyQuestStatusText(state)

        local row = EnsureWeeklyQuestRow(index)
        local metadataKey = quest.dashboardMetadataKey
        local metadata = metadataKey and L[metadataKey] or ""
        local rowHeight = metadata ~= "" and WEEKLY_METADATA_ROW_HEIGHT or WEEKLY_ROW_HEIGHT
        row:SetHeight(rowHeight)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", WeeklyBox, "TOPLEFT", 20, rowTop)
        row.name:ClearAllPoints()
        if metadata ~= "" then
            row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 11, -4)
        else
            row.name:SetPoint("LEFT", row, "LEFT", 11, 0)
        end
        row.name:SetPoint("RIGHT", row.status, "LEFT", -10, 0)
        row.name:SetText(L[quest.name])
        row.metadata:SetText(metadata)
        if metadata ~= "" then
            row.metadata:Show()
        else
            row.metadata:Hide()
        end
        row.status:SetText(GetWeeklyQuestStatusLabel(state))
        if state == "done" then
            row.status:SetTextColor(unpack(theme.weeklyQuestCompleteText))
        elseif state == "in_progress" then
            row.status:SetTextColor(unpack(theme.textGold))
        else
            row.status:SetTextColor(unpack(theme.weeklyQuestNotStartedText))
        end
        row:Show()
        rowTop = rowTop - rowHeight - WEEKLY_ROW_GAP
    end

    weeklyUI.summary:SetText(string.format(UIText("LABEL_WEEKLY_COMPLETION_SUMMARY", "%d / %d Complete"), completed, #questList))
end
lv.RenderWeeklyQuestRows = RenderWeeklyQuestRows

local function StyleWeeklyTab(btn, visualState)
    local t = lv.GetTheme and lv.GetTheme() or nil
    if not t then return end
    local hovered = visualState == "hover"
    local pressed = visualState == "pressed"
    btn:SetBackdropColor(unpack(pressed and (t.buttonBgActive or t.buttonBgHover) or (hovered and t.buttonBgHover or t.buttonBg)))
    btn:SetBackdropBorderColor(unpack((hovered or pressed) and t.borderHover or t.borderPrimary))
    btn.Text:SetTextColor(unpack(t.textPrimary))
end

local function ApplyFactionWindowTheme(frame, theme)
    frame:SetBackdropColor(unpack(theme.background))
    lv.ApplyBorderStyle(frame, "panel", theme)
end

local function CreateFactionWeeklyWindow()
    local frame = CreateFrame("Frame", "LiteVaultFactionWeeklyFrame", LVWindow, "BackdropTemplate")
    frame:SetSize(700, 240)
    frame:SetPoint("TOP", LVWindow, "TOP", 0, -100)
    frame:SetFrameStrata("MEDIUM")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    lv.EnsureBorderStyle(frame, "panelTabbed")
    frame:Hide()

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(frame, ApplyFactionWindowTheme)
            ApplyFactionWindowTheme(frame, lv.GetTheme())
        end
    end)

    return frame
end

FactionWeeklyWindow = CreateFactionWeeklyWindow()

local factionSectionMode = "weeklies"
local factionSectionTabs = {}
local FactionTokkaWindow

local function StyleFactionSectionTab(button, active, hovered)
    lv.StyleInteriorNavigationButton(button, active, hovered)
end

local function UpdateFactionSectionTabs()
    for mode, button in pairs(factionSectionTabs) do
        StyleFactionSectionTab(button, mode == factionSectionMode)
    end
end

local function SetFactionSectionMode(mode)
    factionSectionMode = mode == "tokka" and "tokka" or "weeklies"
    local showWeeklies = factionSectionMode == "weeklies"
    FactionWeeklyWindow:SetShown(showWeeklies)
    if FactionTokkaWindow then FactionTokkaWindow:SetShown(not showWeeklies) end
    SetFactionCardsVisible(showWeeklies)
    UpdateFactionSectionTabs()
    if showWeeklies then
        if lv.UpdateFactionWeeklyWindow then lv.UpdateFactionWeeklyWindow() end
    elseif lv.UpdateCaptainTokkaWindow then
        lv.UpdateCaptainTokkaWindow()
    end
end

local function CreateFactionSectionTab(mode, labelKey, anchor)
    local button = lv.CreateInteriorNavigationButton(LVWindow, {
        width = 156,
        height = 24,
        text = L[labelKey],
    })
    if anchor then
        button:SetPoint("LEFT", anchor, "RIGHT", -4, 0)
    else
        button:SetPoint("BOTTOMLEFT", FactionWeeklyWindow, "TOPLEFT", 8, -3)
    end
    lv.ApplyLocaleFont(button.Text, 11)
    button:SetScript("OnClick", function() SetFactionSectionMode(mode) end)
    button:SetScript("OnEnter", function(self)
        StyleFactionSectionTab(self, factionSectionMode == mode, true)
    end)
    button:SetScript("OnLeave", function(self)
        StyleFactionSectionTab(self, factionSectionMode == mode, false)
    end)
    button:Hide()
    factionSectionTabs[mode] = button
    return button
end

local weekliesSectionTab = CreateFactionSectionTab("weeklies", "BUTTON_FACTION_WEEKLIES")
CreateFactionSectionTab("tokka", "BUTTON_CAPTAIN_TOKKA", weekliesSectionTab)

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for _, button in pairs(factionSectionTabs) do
            lv.RegisterThemedElement(button, function()
                UpdateFactionSectionTabs()
            end)
        end
    end
    UpdateFactionSectionTabs()
end)

local function CreateFactionTopControls()
    local title = FactionWeeklyWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)

    return title
end

local factionTitle = CreateFactionTopControls()

local function CreateFactionContentArea()
    local warning = FactionWeeklyWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    warning:SetPoint("TOPLEFT", 20, -120)
    warning:SetPoint("RIGHT", -20, 0)
    warning:SetJustifyH("LEFT")
    warning:SetJustifyV("TOP")
    warning:SetWordWrap(true)
    warning:SetTextColor(1, 0.15, 0.15)
    warning:Hide()

    local scrollFrame = CreateFrame("ScrollFrame", nil, FactionWeeklyWindow)
    scrollFrame:SetPoint("TOPLEFT", 20, -120)
    scrollFrame:SetPoint("BOTTOMRIGHT", -20, 20)
    scrollFrame:EnableMouseWheel(true)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local content = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    content:SetPoint("TOPLEFT", 0, 0)
    content:SetPoint("TOPRIGHT", 0, 0)
    content:SetJustifyH("LEFT")
    content:SetJustifyV("TOP")
    content:SetSpacing(lv.Layout.verticalPadding)
    lv.ApplyLocaleFont(content, 12)

    return warning, scrollFrame, scrollChild, content
end

local factionUI = {}
factionUI.warning, factionUI.scrollFrame, factionUI.scrollChild, factionUI.content = CreateFactionContentArea()
local factionCards = {}
lv.factionCards = factionCards
local factionWeeklyMode = "amani"

local FACTION_CARD_WIDTH = 310
local FACTION_CARD_HEIGHT = 82
local FACTION_CARD_COLUMNS = 2
local FACTION_CARD_X_STEP = 320
local FACTION_CARD_Y_STEP = 88
local FACTION_CARD_TOP_PADDING = 8
local FACTION_CARD_TEXT_GAP = 12

local FACTION_CARD_CONFIG = {
    { key = "amani", labelKey = "BUTTON_AMANI_TRIBE", short = "AT", atlas = "majorfactions_icons_origin512", color = {0.84, 0.68, 0.38} },
    { key = "harati", labelKey = "BUTTON_HARATI", short = "H", atlas = "majorfactions_icons_root512", color = {0.78, 0.18, 0.16} },
    { key = "singularity", labelKey = "BUTTON_SINGULARITY", short = "S", atlas = "majorfactions_icons_sky512", color = {0.45, 0.30, 0.85} },
    { key = "silvermoon", labelKey = "BUTTON_SILVERMOON_COURT", short = "SC", atlas = "majorfactions_icons_light512", color = {0.90, 0.64, 0.16} },
    { key = "ritualsites", labelKey = "BUTTON_RITUAL_SITES", short = "RS", atlas = "majorfactions_icons_RitualSites512", color = {0.82, 0.48, 0.96}, selectable = false },
    { key = "zuljarra", labelKey = "BUTTON_ZULJARRA_FORCES", short = "ZF", dynamicMajorFactionAtlas = true, color = {0.36, 0.62, 0.58} },
    { key = "tokka", labelKey = "BUTTON_CAPTAIN_TOKKA", short = "CT", dynamicMajorFactionAtlas = true, sectionMode = "tokka", color = {0.24, 0.66, 0.72} },
    { key = "valeera", labelKey = "LABEL_VALEERA_SANGUINAR", allowTextFallback = false, selectable = false, color = {0.72, 0.18, 0.22} },
    { key = "slayersduellum", labelKey = "LABEL_SLAYERS_DUELLUM", allowTextFallback = false, selectable = false, color = {0.20, 0.43, 0.78} },
}

-- Blizzard artwork identifiers used by the Midnight expansion landing page.
local FACTION_ARTWORK_BY_FACTION_ID = {
    [2744] = { kind = "creatureDisplay", id = 26365 }, -- Valeera Sanguinar
    [2770] = { kind = "texture", id = 7448209 },       -- Slayer's Duellum
    [2773] = { kind = "creatureDisplay", id = 145432, creatureID = 253515 }, -- Captain Tokka
}

local function GetDynamicMajorFactionAtlas(cfg)
    if not (cfg and cfg.dynamicMajorFactionAtlas) then return nil end
    local factionID = lv.MIDNIGHT_FACTION_IDS and lv.MIDNIGHT_FACTION_IDS[cfg.key]
    if not (factionID and C_MajorFactions and C_MajorFactions.GetMajorFactionData) then return nil end
    local factionData = C_MajorFactions.GetMajorFactionData(factionID)
    local textureKit = factionData and factionData.textureKit
    if type(textureKit) ~= "string" or textureKit == "" then return nil end
    local atlas = "majorfactions_icons_" .. textureKit .. "512"
    local atlasInfo = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
    return atlasInfo and atlas or nil
end

local function UpdateFactionCardEmblem(card)
    if not card or not card.cfg then
        return
    end

    local cfg = card.cfg
    local iconTexture

    local factionID = lv.MIDNIGHT_FACTION_IDS and lv.MIDNIGHT_FACTION_IDS[cfg.key]
    local artwork = factionID and FACTION_ARTWORK_BY_FACTION_ID[factionID]
    if artwork then
        if artwork.kind == "creatureDisplay" and SetPortraitTextureFromCreatureDisplayID then
            SetPortraitTextureFromCreatureDisplayID(card.emblemIcon, artwork.id)
            card.emblemIcon:Show()
            card.emblemText:Hide()
            return
        elseif artwork.kind == "texture" then
            card.emblemIcon:SetTexCoord(0, 1, 0, 1)
            card.emblemIcon:SetTexture(artwork.id)
            card.emblemIcon:Show()
            card.emblemText:Hide()
            return
        end
    end

    local resolvedAtlas = cfg.atlas or GetDynamicMajorFactionAtlas(cfg)
    if resolvedAtlas then
        card.emblemIcon:SetAtlas(resolvedAtlas, false)
        card.emblemIcon:Show()
        card.emblemText:Hide()
        return
    end

    if cfg.iconCurrencyID and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(cfg.iconCurrencyID)
        iconTexture = currencyInfo and (currencyInfo.iconFileID or currencyInfo.icon)
    end

    if not iconTexture and factionID == 2744 and C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        iconTexture = friendshipInfo and friendshipInfo.texture
    end

    if iconTexture then
        card.emblemIcon:SetTexture(iconTexture)
        card.emblemIcon:Show()
        card.emblemText:Hide()
    else
        card.emblemIcon:SetTexture(nil)
        card.emblemIcon:Hide()
        card.emblemText:SetText(cfg.allowTextFallback == false and "" or (cfg.short or ""))
        card.emblemText:SetShown(cfg.allowTextFallback ~= false)
    end
end

local function GetFactionCardAccent(cfg, theme, hovered)
    local source = cfg.color or {0.55, 0.55, 0.55}
    local scale = 0.86
    if hovered then scale = math.min(1.05, scale + 0.10) end
    return math.min(1, source[1] * scale), math.min(1, source[2] * scale), math.min(1, source[3] * scale)
end

local function UpdateFactionCardEmblemAccentGeometry(card)
    if not (card and card.emblemBg and card.emblemAccentLines) then return end

    local scale = card.emblemBg:GetEffectiveScale()
    local yOffset = 0
    if scale and scale > 0 then
        local emblemTop = card.emblemBg:GetTop()
        if emblemTop then
            local accentTop = emblemTop - 3
            yOffset = (math.floor((accentTop * scale) + 0.5) / scale) - accentTop
        end
    end
    local top, bottom, left, right = unpack(card.emblemAccentLines)

    for _, line in ipairs(card.emblemAccentLines) do
        if line.SetSnapToPixelGrid then
            line:SetSnapToPixelGrid(true)
        end
        if line.SetTexelSnappingBias then
            line:SetTexelSnappingBias(0)
        end
        line:ClearAllPoints()
    end

    top:SetPoint("TOPLEFT", 3, -3 + yOffset)
    top:SetPoint("TOPRIGHT", -3, -3 + yOffset)
    top:SetHeight(1)

    bottom:SetPoint("BOTTOMLEFT", 3, 3 + yOffset)
    bottom:SetPoint("BOTTOMRIGHT", -3, 3 + yOffset)
    bottom:SetHeight(1)

    left:SetPoint("TOPLEFT", 3, -3 + yOffset)
    left:SetPoint("BOTTOMLEFT", 3, 3 + yOffset)
    left:SetWidth(1)

    right:SetPoint("TOPRIGHT", -3, -3 + yOffset)
    right:SetPoint("BOTTOMRIGHT", -3, 3 + yOffset)
    right:SetWidth(1)
end

local function ApplyFactionCardVisual(card, theme, hovered)
    if not (card and card.cfg and theme) then return end
    local ar, ag, ab = GetFactionCardAccent(card.cfg, theme, hovered)
    local outer = hovered and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary
    local inner = theme.borderSubdued or theme.borderMuted or theme.borderPrimary
    local background = theme.buttonBgAlt or theme.dataBoxBgAlt or theme.backgroundAlt or theme.background

    card:SetBackdropColor(unpack(background))
    card:SetBackdropBorderColor(unpack(outer))
    card.innerBorder:SetBackdropBorderColor(inner[1], inner[2], inner[3], 0.62)
    card.topAccent:SetColorTexture(ar, ag, ab, hovered and 0.70 or 0.46)
    card.bottomAccent:SetColorTexture(ar, ag, ab, hovered and 0.64 or 0.40)
    for _, segment in ipairs(card.cornerBrackets) do
        segment:SetColorTexture(ar, ag, ab, hovered and 0.90 or 0.68)
    end
    card.emblemBg:SetBackdropColor(0.035, 0.04, 0.045, 0.96)
    card.emblemBg:SetBackdropBorderColor(unpack(outer))
    UpdateFactionCardEmblemAccentGeometry(card)
    for _, line in ipairs(card.emblemAccentLines) do
        line:SetColorTexture(ar, ag, ab, 0.88)
    end
    card.emblemText:SetTextColor(ar, ag, ab)
    card.nameText:SetTextColor(unpack(theme.textPrimary))
end

local ShowFactionCardTooltip
local RefreshFactionCards

local function CreateFactionCards()
    for index, cfg in ipairs(FACTION_CARD_CONFIG) do
        local card = CreateFrame("Frame", nil, FactionWeeklyWindow, "BackdropTemplate")
        card:EnableMouse(true)
        card:SetSize(FACTION_CARD_WIDTH, FACTION_CARD_HEIGHT)
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        card:SetPoint("TOPLEFT", FactionWeeklyWindow, "BOTTOMLEFT", 20 + (col * FACTION_CARD_X_STEP), -(16 + (row * FACTION_CARD_Y_STEP)))
        card:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 3,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })

        card.innerBorder = CreateFrame("Frame", nil, card, "BackdropTemplate")
        card.innerBorder:SetPoint("TOPLEFT", 3, -3)
        card.innerBorder:SetPoint("BOTTOMRIGHT", -3, 3)
        card.innerBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })

        card.topAccent = card:CreateTexture(nil, "BORDER")
        card.topAccent:SetPoint("TOPLEFT", 20, -4)
        card.topAccent:SetPoint("TOPRIGHT", -20, -4)
        card.topAccent:SetHeight(1)

        card.bottomAccent = card:CreateTexture(nil, "BORDER")
        card.bottomAccent:SetPoint("BOTTOMLEFT", 20, 4)
        card.bottomAccent:SetPoint("BOTTOMRIGHT", -20, 4)
        card.bottomAccent:SetHeight(1)

        card.cornerBrackets = {}
        local cornerSegments = {
            {"TOPLEFT", 4, -4, 8, 2}, {"TOPLEFT", 4, -4, 2, 8},
            {"TOPRIGHT", -4, -4, 8, 2}, {"TOPRIGHT", -4, -4, 2, 8},
            {"BOTTOMLEFT", 4, 4, 8, 2}, {"BOTTOMLEFT", 4, 4, 2, 8},
            {"BOTTOMRIGHT", -4, 4, 8, 2}, {"BOTTOMRIGHT", -4, 4, 2, 8},
        }
        for _, def in ipairs(cornerSegments) do
            local segment = card:CreateTexture(nil, "OVERLAY")
            segment:SetSize(def[4], def[5])
            segment:SetPoint(def[1], def[2], def[3])
            card.cornerBrackets[#card.cornerBrackets + 1] = segment
        end

        card.emblemBg = CreateFrame("Frame", nil, card, "BackdropTemplate")
        card.emblemBg:SetSize(42, 42)
        card.emblemBg:SetPoint("LEFT", 14, 0)
        card.emblemBg:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 2,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })

        card.emblemIcon = card.emblemBg:CreateTexture(nil, "ARTWORK")
        card.emblemIcon:SetPoint("TOPLEFT", 6, -6)
        card.emblemIcon:SetPoint("BOTTOMRIGHT", -6, 6)

        card.emblemAccentLines = {}

        local emblemAccentTop = card.emblemBg:CreateTexture(nil, "OVERLAY", nil, 7)
        emblemAccentTop:SetPoint("TOPLEFT", 3, -3)
        emblemAccentTop:SetPoint("TOPRIGHT", -3, -3)
        emblemAccentTop:SetHeight(1)
        card.emblemAccentLines[#card.emblemAccentLines + 1] = emblemAccentTop

        local emblemAccentBottom = card.emblemBg:CreateTexture(nil, "OVERLAY", nil, 7)
        emblemAccentBottom:SetPoint("BOTTOMLEFT", 3, 3)
        emblemAccentBottom:SetPoint("BOTTOMRIGHT", -3, 3)
        emblemAccentBottom:SetHeight(1)
        card.emblemAccentLines[#card.emblemAccentLines + 1] = emblemAccentBottom

        local emblemAccentLeft = card.emblemBg:CreateTexture(nil, "OVERLAY", nil, 7)
        emblemAccentLeft:SetPoint("TOPLEFT", 3, -3)
        emblemAccentLeft:SetPoint("BOTTOMLEFT", 3, 3)
        emblemAccentLeft:SetWidth(1)
        card.emblemAccentLines[#card.emblemAccentLines + 1] = emblemAccentLeft

        local emblemAccentRight = card.emblemBg:CreateTexture(nil, "OVERLAY", nil, 7)
        emblemAccentRight:SetPoint("TOPRIGHT", -3, -3)
        emblemAccentRight:SetPoint("BOTTOMRIGHT", -3, 3)
        emblemAccentRight:SetWidth(1)
        card.emblemAccentLines[#card.emblemAccentLines + 1] = emblemAccentRight

        card.emblemText = card.emblemBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        card.emblemText:SetPoint("CENTER")
        card.emblemText:SetText(cfg.short)

        card.nameText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        card.nameText:SetPoint("TOPLEFT", card.emblemBg, "TOPRIGHT", 14, -4)
        card.nameText:SetJustifyH("LEFT")

        card.levelText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        card.levelText:SetPoint("TOPLEFT", card.nameText, "BOTTOMLEFT", 0, -3)
        card.levelText:SetJustifyH("LEFT")

        card.progressText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        card.progressText:SetPoint("TOPLEFT", card.levelText, "BOTTOMLEFT", 0, 0)
        card.progressText:SetJustifyH("LEFT")

        card.cfg = cfg
        ApplyFactionCardVisual(card, lv.GetTheme(), false)
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(card, function(element, theme)
                ApplyFactionCardVisual(element, theme, element.factionCardHovered)
            end)
        end
        card:Hide()
        card:SetScript("OnEnter", ShowFactionCardTooltip)
        card:SetScript("OnLeave", function(self)
            self.factionCardHovered = false
            GameTooltip:Hide()
            if RefreshFactionCards then
                RefreshFactionCards()
            end
        end)

        UpdateFactionCardEmblem(card)
        factionCards[#factionCards + 1] = card
    end
end

CreateFactionCards()

local function RefreshFactionScrollLayout(resetScroll)
    local frameHeight = math.max(factionUI.scrollFrame:GetHeight(), 1)
    local frameWidth = math.max(factionUI.scrollFrame:GetWidth(), 1)
    local textHeight = math.ceil(factionUI.content:GetStringHeight())

    factionUI.content:ClearAllPoints()
    factionUI.content:SetPoint("TOPLEFT", 0, 0)
    factionUI.content:SetPoint("TOPRIGHT", 0, 0)

    local contentHeight = math.max(textHeight + 8, frameHeight)
    factionUI.scrollChild:SetSize(frameWidth, contentHeight)
    if resetScroll then
        factionUI.scrollFrame:SetVerticalScroll(0)
    else
        local maxScroll = math.max(0, contentHeight - frameHeight)
        if factionUI.scrollFrame:GetVerticalScroll() > maxScroll then
            factionUI.scrollFrame:SetVerticalScroll(maxScroll)
        end
    end
end

factionUI.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local step = 36
    local current = self:GetVerticalScroll()
    local maxScroll = math.max(0, factionUI.scrollChild:GetHeight() - self:GetHeight())
    if delta > 0 then
        self:SetVerticalScroll(math.max(0, current - step))
    else
        self:SetVerticalScroll(math.min(maxScroll, current + step))
    end
end)

FactionTokkaWindow = CreateFrame("Frame", "LiteVaultCaptainTokkaFrame", LVWindow, "BackdropTemplate")
FactionTokkaWindow:SetPoint("TOPLEFT", LVWindow, "TOPLEFT", 20, -100)
FactionTokkaWindow:SetPoint("BOTTOMRIGHT", LVWindow, "BOTTOMRIGHT", -20, 20)
FactionTokkaWindow:SetBackdrop({
    bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize=16, insets={left=4,right=4,top=4,bottom=4},
})
lv.EnsureBorderStyle(FactionTokkaWindow, "panelTabbed")
FactionTokkaWindow:Hide()

local tokkaTitle = FactionTokkaWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tokkaTitle:SetPoint("TOPLEFT", 20, -18)
tokkaTitle:SetText(L["BUTTON_CAPTAIN_TOKKA"])
lv.ApplyLocaleFont(tokkaTitle, 15)

local tokkaReputation = FactionTokkaWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
tokkaReputation:SetPoint("TOPLEFT", tokkaTitle, "BOTTOMLEFT", 0, -6)

local tokkaWarning = FactionTokkaWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
tokkaWarning:SetPoint("TOPLEFT", tokkaReputation, "BOTTOMLEFT", 0, -10)
tokkaWarning:SetPoint("RIGHT", FactionTokkaWindow, "RIGHT", -20, 0)
tokkaWarning:SetJustifyH("LEFT")
tokkaWarning:SetJustifyV("TOP")
tokkaWarning:SetWordWrap(true)
tokkaWarning:SetTextColor(1, 0.35, 0.2)
tokkaWarning:SetText(L["WARNING_TOKKA_ONE_TIME_ARTIFACTS"])
lv.ApplyLocaleFont(tokkaWarning, 11)

local tokkaScrollFrame = CreateFrame("ScrollFrame", nil, FactionTokkaWindow)
tokkaScrollFrame:SetPoint("TOPLEFT", 20, -112)
tokkaScrollFrame:SetPoint("BOTTOMRIGHT", -20, 20)
tokkaScrollFrame:EnableMouseWheel(true)
local tokkaScrollChild = CreateFrame("Frame", nil, tokkaScrollFrame)
tokkaScrollChild:SetSize(1, 1)
tokkaScrollFrame:SetScrollChild(tokkaScrollChild)
tokkaScrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local maxScroll = math.max(0, tokkaScrollChild:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(maxScroll, self:GetVerticalScroll() - (delta * 36))))
end)

local tokkaTracker = { rows = {} }

local function IsTokkaArtifactCompleted(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompletedOnAccount then
        return C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) and true or false
    end
    return C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted
        and C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
end

local function GetTokkaTreasureProgress()
    local completed = 0
    local artifacts = (lv.TOKKA_TREASURES_OF_THE_DAMNED and lv.TOKKA_TREASURES_OF_THE_DAMNED.artifacts) or {}
    for _, artifact in ipairs(artifacts) do
        if IsTokkaArtifactCompleted(artifact.questID) then completed = completed + 1 end
    end
    return completed, #artifacts
end

local function EnsureTokkaTrackerRows()
    if tokkaTracker.header then return end

    tokkaTracker.header = tokkaScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tokkaTracker.header:SetPoint("TOPLEFT", 4, -2)
    tokkaTracker.header:SetPoint("RIGHT", -4, 0)
    tokkaTracker.header:SetJustifyH("LEFT")
    lv.ApplyLocaleFont(tokkaTracker.header, 13)

    local artifacts = (lv.TOKKA_TREASURES_OF_THE_DAMNED and lv.TOKKA_TREASURES_OF_THE_DAMNED.artifacts) or {}
    for index, artifact in ipairs(artifacts) do
        local row = CreateFrame("Frame", nil, tokkaScrollChild, "BackdropTemplate")
        row:EnableMouse(true)
        row:SetHeight(25)
        row:SetPoint("TOPLEFT", 0, -(28 + ((index - 1) * 27)))
        row:SetPoint("RIGHT", 0, 0)
        row:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8" })
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.label:SetPoint("LEFT", 8, 0)
        row.label:SetPoint("RIGHT", -8, 0)
        row.label:SetJustifyH("LEFT")
        lv.ApplyLocaleFont(row.label, 12)
        row.artifact = artifact
        row:SetScript("OnEnter", function(self)
            local done = IsTokkaArtifactCompleted(self.artifact.questID)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L[self.artifact.artifactName] or self.artifact.artifactName, 1, 0.82, 0)
            GameTooltip:AddLine(string.format(L["LABEL_QUEST_FMT"], L[self.artifact.questName] or self.artifact.questName), 1, 1, 1)
            GameTooltip:AddLine(done and L["LABEL_COMPLETED"] or L["LABEL_NOT_COMPLETED"], done and 0.2 or 0.8, done and 1 or 0.8, done and 0.2 or 0.8)
            GameTooltip:AddLine(string.format(L["LABEL_QUEST_ID_FMT"], self.artifact.questID), 0.65, 0.65, 0.65)
            GameTooltip:AddLine(L["TOOLTIP_TOKKA_TREASURE_HINT"], 0.85, 0.85, 0.85, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        tokkaTracker.rows[index] = row
    end
end

local function SetTokkaTrackerVisible(visible)
    EnsureTokkaTrackerRows()
    tokkaTracker.header:SetShown(visible)
    for _, row in ipairs(tokkaTracker.rows) do row:SetShown(visible) end
end

local function RenderTokkaTracker()
    EnsureTokkaTrackerRows()
    local completed, total = GetTokkaTreasureProgress()
    local completeColor = completed == total and "|cff20ff20" or "|cffffff00"
    tokkaTracker.header:SetText(string.format("%s    %s%d / %d|r", L["TITLE_TREASURES_OF_THE_DAMNED"], completeColor, completed, total))
    for index, row in ipairs(tokkaTracker.rows) do
        local done = IsTokkaArtifactCompleted(row.artifact.questID)
        local prefix = done and "|cff20ff20[+] |r" or "|cff888888[-] |r"
        row.label:SetText(prefix .. (L[row.artifact.artifactName] or row.artifact.artifactName))
        local t = lv.GetTheme()
        local stripe = (index % 2 == 0) and t.rowStripeEven or t.rowStripeOdd
        row:SetBackdropColor(unpack(stripe))
    end
    local frameWidth = math.max(tokkaScrollFrame:GetWidth(), 1)
    tokkaScrollChild:SetSize(frameWidth, math.max(305, tokkaScrollFrame:GetHeight()))
    tokkaScrollFrame:SetVerticalScroll(0)
end

local factionTabButtons = {}

local function CreateFactionTabButton(index, def)
    local btn = CreateFrame("Button", nil, FactionWeeklyWindow, "BackdropTemplate")
    btn:SetSize(126, 28)
    if index == 1 then
        btn:SetPoint("TOPLEFT", factionTitle, "BOTTOMLEFT", 0, -10)
    elseif index <= 5 then
        btn:SetPoint("LEFT", factionTabButtons[index - 1], "RIGHT", 7, 0)
    else
        btn:SetPoint("TOPLEFT", factionTabButtons[1], "BOTTOMLEFT", 0, -7)
    end
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(L[def.labelKey])
    lv.ApplyLocaleFont(btn.Text, 10)
    btn.factionWeeklyKey = def.key
    btn.mode = btn.factionWeeklyKey
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetScript("OnEnter", function(self)
        StyleWeeklyTab(self, "hover")
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetButtonState("NORMAL")
        StyleWeeklyTab(self, "idle")
    end)
    btn:SetScript("OnMouseDown", function(self, mouseButton)
        StyleWeeklyTab(self, "pressed")
    end)
    btn:SetScript("OnMouseUp", function(self, mouseButton)
        StyleWeeklyTab(self, self:IsMouseOver() and "hover" or "idle")
    end)
    btn:SetScript("OnClick", function(self)
        local selectorKey = self.factionWeeklyKey
        factionWeeklyMode = selectorKey
        if lv.UpdateFactionWeeklyWindow then
            lv.UpdateFactionWeeklyWindow()
        end
    end)
    return btn
end

for i, def in ipairs(factionWeeklyTabDefs) do
    factionTabButtons[i] = CreateFactionTabButton(i, def)
end

local function InitializeFactionWindowThemes()
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            for _, btn in ipairs(factionTabButtons) do
                lv.RegisterThemedElement(btn, function(b) StyleWeeklyTab(b, "idle") end)
            end
        end
        for _, btn in ipairs(factionTabButtons) do
            StyleWeeklyTab(btn, "idle")
        end
    end)
end

InitializeFactionWindowThemes()

local function UpdateFactionTabButtons()
    for _, btn in ipairs(factionTabButtons) do
        local def = GetFactionWeeklyTabDef(btn.factionWeeklyKey)
        if btn.Text and def and def.labelKey then
            btn.Text:SetText(L[def.labelKey])
            StyleWeeklyTab(btn, "idle")
        end
    end
end

local factionParagonRewardRequests = {}
local factionParagonQuestLoads = {}

local function GetFactionRenownDetails(mode)
    local factionID = lv.MIDNIGHT_FACTION_IDS and lv.MIDNIGHT_FACTION_IDS[mode]
    if not factionID then
        return nil
    end

    if mode == "valeera" and C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local friendship = C_GossipInfo.GetFriendshipReputation(factionID)
        if friendship and friendship.friendshipFactionID then
            local standing = tonumber(friendship.standing) or 0
            local currentThreshold = tonumber(friendship.reactionThreshold) or 0
            local nextThreshold = tonumber(friendship.nextThreshold) or currentThreshold
            local maxRep = tonumber(friendship.maxRep) or 0
            local level = tonumber(tostring(friendship.reaction or ""):match("%d+")) or 0
            local atMax = (maxRep > 0 and standing >= maxRep) or level >= 80
            return {
                kind="friendship", mode=mode, factionID=factionID, name=friendship.name, level=math.min(level, 80),
                reactionName=friendship.reaction, earned=math.max(0, standing - currentThreshold),
                threshold=math.max(0, nextThreshold - currentThreshold), standing=standing, maxRep=maxRep,
                texture=friendship.texture, maxLevel=80, isAtMaxRenown=atMax,
            }
        end
    end

    if mode == "tokka" and C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local friendship = C_GossipInfo.GetFriendshipReputation(factionID)
        if friendship and friendship.friendshipFactionID and friendship.reaction and friendship.reaction ~= "" then
            local standing = tonumber(friendship.standing) or 0
            local currentThreshold = tonumber(friendship.reactionThreshold) or 0
            local nextThreshold = tonumber(friendship.nextThreshold)
            local maxRep = tonumber(friendship.maxRep) or 0
            local hasNextRank = nextThreshold and nextThreshold > currentThreshold
            local atMax = (maxRep > 0 and standing >= maxRep)
                or (not hasNextRank and (currentThreshold > 0 or standing > 0))
            return {
                kind="customFriendship", mode=mode, factionID=factionID, name=friendship.name,
                reactionName=friendship.reaction, earned=math.max(0, standing - currentThreshold),
                threshold=hasNextRank and (nextThreshold - currentThreshold) or 0,
                standing=standing, maxRep=maxRep, texture=friendship.texture, isAtMaxRenown=atMax,
            }
        end
    end

    local majorFactionData
    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
    end

    local renownInfo
    if C_MajorFactions and C_MajorFactions.GetMajorFactionRenownInfo then
        renownInfo = C_MajorFactions.GetMajorFactionRenownInfo(factionID)
    end
    local standardFactionData
    if not majorFactionData and not renownInfo and C_Reputation and C_Reputation.GetFactionDataByID then
        standardFactionData = C_Reputation.GetFactionDataByID(factionID)
    end
    if mode == "tokka" and not standardFactionData and C_Reputation and C_Reputation.GetFactionDataByID then
        standardFactionData = C_Reputation.GetFactionDataByID(factionID)
    end
    if not majorFactionData and not renownInfo and not standardFactionData then return nil end

    if standardFactionData then
        local earned = math.max(0, (standardFactionData.currentStanding or 0) - (standardFactionData.currentReactionThreshold or 0))
        local threshold = math.max(0, (standardFactionData.nextReactionThreshold or 0) - (standardFactionData.currentReactionThreshold or 0))
        local currentValue, paragonThreshold, rewardQuestID, hasRewardPending
        if standardFactionData.reaction == 8 and C_Reputation and C_Reputation.GetFactionParagonInfo then
            currentValue, paragonThreshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
        end
        local paragonProgress = currentValue and paragonThreshold and paragonThreshold > 0 and (currentValue % paragonThreshold) or nil
        if paragonProgress == 0 and hasRewardPending then paragonProgress = paragonThreshold end
        return {
            kind="standard", mode=mode, factionID=factionID, name=standardFactionData.name, reaction=standardFactionData.reaction or 0,
            reactionName=_G["FACTION_STANDING_LABEL" .. tostring(standardFactionData.reaction or 0)],
            earned=earned, threshold=threshold, maxLevel=8, isAtMaxRenown=standardFactionData.reaction == 8,
            isParagon=paragonProgress ~= nil, paragonProgress=paragonProgress, paragonThreshold=paragonThreshold,
            rewardQuestID=rewardQuestID, hasRewardPending=hasRewardPending,
        }
    end

    local renownLevel = (majorFactionData and majorFactionData.renownLevel) or (renownInfo and renownInfo.renownLevel) or 0
    local earned = (majorFactionData and majorFactionData.renownReputationEarned)
        or (renownInfo and renownInfo.renownReputationEarned)
        or (majorFactionData and majorFactionData.renownLevelThreshold)
        or (renownInfo and renownInfo.renownLevelThreshold)
        or 0
    local threshold = (majorFactionData and majorFactionData.renownLevelThreshold)
        or (renownInfo and renownInfo.renownLevelThreshold)
        or 0
    local maxLevel = (majorFactionData and majorFactionData.maxLevel)
        or (renownInfo and renownInfo.maxLevel)
        or (mode == "ritualsites" and 8 or nil)

    local currentValue
    local paragonThreshold
    local rewardQuestID
    local hasRewardPending = false
    local tooLowLevelForParagon = false
    local paragonStorageLevel
    if C_Reputation and C_Reputation.GetFactionParagonInfo then
        currentValue, paragonThreshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon, paragonStorageLevel = C_Reputation.GetFactionParagonInfo(factionID)
    end

    local isAtMaxRenown = maxLevel and renownLevel and renownLevel >= maxLevel
    local isParagon = false
    if currentValue ~= nil and paragonThreshold ~= nil and paragonThreshold > 0 then
        isParagon = isAtMaxRenown
        if not isParagon and C_Reputation and C_Reputation.IsFactionParagonForCurrentPlayer then
            isParagon = C_Reputation.IsFactionParagonForCurrentPlayer(factionID) and isAtMaxRenown
        end
    end

    local paragonProgress
    if isParagon and currentValue ~= nil and paragonThreshold and paragonThreshold > 0 then
        paragonProgress = currentValue % paragonThreshold
        if paragonProgress < 0 then
            paragonProgress = paragonProgress + paragonThreshold
        end
        if paragonProgress > paragonThreshold then
            paragonProgress = paragonThreshold
        end
        if paragonProgress == 0 and hasRewardPending then
            paragonProgress = paragonThreshold
        end
    end

    local rewardName
    local rewardIcon
    local rewardItemID
    if rewardQuestID and GetNumQuestLogRewards and GetQuestLogRewardInfo then
        local rewardCount = GetNumQuestLogRewards(rewardQuestID) or 0
        if rewardCount > 0 then
            for i = 1, rewardCount do
                local itemName, itemTexture, _, _, _, itemID = GetQuestLogRewardInfo(i, rewardQuestID)
                if itemName or itemID then
                    rewardName = itemName or (itemID and GetItemInfo and GetItemInfo(itemID)) or nil
                    rewardIcon = itemTexture or (itemID and C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID)) or nil
                    rewardItemID = itemID
                    break
                end
            end
        end
    end

    if isParagon then
        if not rewardName and C_Reputation and C_Reputation.RequestFactionParagonPreloadRewardData and not factionParagonRewardRequests[factionID] then
            factionParagonRewardRequests[factionID] = true
            C_Reputation.RequestFactionParagonPreloadRewardData(factionID)
            C_Timer.After(0.25, function()
                if FactionWeeklyWindow and FactionWeeklyWindow:IsShown() and lv.UpdateFactionWeeklyWindow then
                    lv.UpdateFactionWeeklyWindow()
                end
            end)
        end
        if rewardQuestID and not rewardName and C_QuestLog and C_QuestLog.RequestLoadQuestByID and not factionParagonQuestLoads[rewardQuestID] then
            factionParagonQuestLoads[rewardQuestID] = true
            C_QuestLog.RequestLoadQuestByID(rewardQuestID)
        end
    end

    return {
        factionID = factionID,
        name = (majorFactionData and majorFactionData.name) or (renownInfo and renownInfo.name) or nil,
        renownLevel = renownLevel,
        earned = earned,
        threshold = threshold,
        maxLevel = maxLevel,
        currentValue = currentValue,
        paragonThreshold = paragonThreshold,
        paragonProgress = paragonProgress,
        rewardQuestID = rewardQuestID,
        rewardName = rewardName,
        rewardIcon = rewardIcon,
        rewardItemID = rewardItemID,
        hasRewardPending = hasRewardPending,
        tooLowLevelForParagon = tooLowLevelForParagon,
        paragonStorageLevel = paragonStorageLevel,
        isParagon = isParagon,
        isAtMaxRenown = isAtMaxRenown,
    }
end

local function BuildFactionRenownText(mode)
    local details = GetFactionRenownDetails(mode)
    local renownText = UIText("LABEL_RENOWN_UNAVAILABLE")

    if details then
        if details.kind == "friendship" then
            if details.isAtMaxRenown then
                renownText = string.format(UIText("LABEL_RENOWN_LEVEL_MAXIMUM_FMT"), details.maxLevel or 80)
            else
                renownText = string.format(UIText("LABEL_RENOWN_LEVEL_PROGRESS_FMT"), details.level or 0, details.earned or 0, details.threshold or 0)
            end
        elseif details.kind == "customFriendship" then
            if details.isAtMaxRenown or not details.threshold or details.threshold <= 0 then
                renownText = details.reactionName or renownText
            else
                renownText = string.format("%s (%d/%d)", details.reactionName or "", details.earned or 0, details.threshold)
            end
        elseif details.kind == "standard" then
            if details.isParagon then
                renownText = string.format("%s %d/%d", UIText("LABEL_PARAGON"), details.paragonProgress or 0, details.paragonThreshold or 0)
            elseif details.isAtMaxRenown then
                renownText = details.reactionName or UIText("LABEL_MAXIMUM")
            else
                renownText = string.format("%s (%d/%d)", details.reactionName or "", details.earned or 0, details.threshold or 0)
            end
        elseif details.isParagon then
            local paragonLabel = UIText("LABEL_PARAGON")
            if details.paragonProgress and details.paragonThreshold then
                renownText = string.format("%s %d/%d", paragonLabel, details.paragonProgress, details.paragonThreshold)
            else
                renownText = paragonLabel
            end
        elseif details.maxLevel and details.renownLevel and details.renownLevel >= details.maxLevel then
            renownText = UIText("LABEL_MAX_RENOWN")
        elseif details.renownLevel then
            if details.threshold and details.threshold > 0 then
                renownText = string.format(UIText("LABEL_RENOWN_PROGRESS"), details.renownLevel, details.earned or 0, details.threshold or 0)
            else
                renownText = string.format(UIText("LABEL_RENOWN_VALUE_FMT"), details.renownLevel)
            end
        end
    end

    return renownText, details
end

local function BuildFactionTooltipText(details)
    if not details then
        return nil
    end

    local lines = {}
    if details.kind == "friendship" or details.kind == "customFriendship" or details.kind == "standard" then
        local mode = details.mode or (details.kind == "friendship" and "valeera" or "slayersduellum")
        lines[#lines + 1] = BuildFactionRenownText(mode)
    elseif details.isParagon then
        lines[#lines + 1] = UIText("LABEL_MAX_RENOWN")
        if details.paragonProgress and details.paragonThreshold then
            lines[#lines + 1] = string.format("%s %d/%d", UIText("LABEL_PARAGON"), details.paragonProgress, details.paragonThreshold)
        end
        if details.rewardName and details.rewardName ~= "" then
            lines[#lines + 1] = string.format(UIText("LABEL_REWARD_FMT"), details.rewardName)
        else
            lines[#lines + 1] = UIText("LABEL_REWARD_LOADING")
        end
    elseif details.maxLevel and details.renownLevel and details.renownLevel >= details.maxLevel then
        lines[#lines + 1] = UIText("LABEL_MAX_RENOWN")
    else
        if details.threshold and details.threshold > 0 then
            lines[#lines + 1] = string.format(UIText("LABEL_RENOWN_PROGRESS"), details.renownLevel or 0, details.earned or 0, details.threshold or 0)
        else
            lines[#lines + 1] = string.format("%s %d", UIText("LABEL_RENOWN"), details.renownLevel or 0)
        end
    end

    return table.concat(lines, "\n")
end

ShowFactionCardTooltip = function(self)
    local details = self and self.factionDetails
    local t = lv.GetTheme()
    self.factionCardHovered = true
    ApplyFactionCardVisual(self, t, true)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L[self.cfg.labelKey] or self.cfg.key, 1, 0.82, 0)

    local body = BuildFactionTooltipText(details)
    if body and body ~= "" then
        for line in body:gmatch("[^\n]+") do
            GameTooltip:AddLine(line, 0.85, 0.85, 0.85, true)
        end
    end
    GameTooltip:Show()
end

RefreshFactionCards = function()
    local showCards = (currentMainView == "factions") and FactionWeeklyWindow and FactionWeeklyWindow:IsShown()

    for _, card in ipairs(factionCards) do
        local progressText, info = BuildFactionRenownText(card.cfg.key)
        local label = (info and info.name) or L[card.cfg.labelKey] or card.cfg.key
        local level = info and (info.level or info.renownLevel or info.reaction or 0) or 0
        local earned = info and (info.earned or 0) or 0
        local threshold = info and (info.threshold or 0) or 0
        local isMaxed = info and info.isAtMaxRenown
        local t = lv.GetTheme()
        local levelLabel = L["LABEL_RENOWN_LEVEL"]

        card.nameText:SetText(label)
        card.factionDetails = info
        UpdateFactionCardEmblem(card)
        if not info then
            card.levelText:SetText(string.format("|cffcccccc%s|r", progressText))
            card.progressText:SetText("")
        elseif info.kind == "friendship" then
            card.levelText:SetText(string.format("|cffffd100%s|r", string.format(UIText("LABEL_RENOWN_LEVEL_FMT"), info.level or 0)))
            card.progressText:SetText(string.format("|cffcccccc%s|r", progressText))
        elseif info.kind == "customFriendship" then
            card.levelText:SetText(string.format("|cffffd100%s|r", info.reactionName or ""))
            card.progressText:SetText((info.isAtMaxRenown or threshold <= 0) and "" or string.format("|cffcccccc%d/%d|r", earned, threshold))
        elseif info.kind == "standard" then
            card.levelText:SetText(string.format("|cffffd100%s|r", info.reactionName or ""))
            card.progressText:SetText(info.isParagon and string.format("|cffcccccc%s|r", progressText) or (info.isAtMaxRenown and "" or string.format("|cffcccccc%d/%d|r", earned, threshold)))
        elseif info.isParagon then
            card.levelText:SetText(string.format("|cffffd100%s|r", UIText("LABEL_MAX_RENOWN")))
            card.progressText:SetText(string.format("|cffcccccc%s|r", progressText))
        elseif isMaxed then
            card.levelText:SetText(string.format("|cffffd100%s|r", UIText("LABEL_MAX_RENOWN")))
            card.progressText:SetText("")
        elseif threshold > 0 then
            card.levelText:SetText(string.format("|cffffd100%s %d|r", levelLabel, level))
            card.progressText:SetText(string.format("|cffcccccc%d/%d|r", earned, threshold))
        else
            card.levelText:SetText(string.format("|cffffd100%s %d|r", levelLabel, level))
            card.progressText:SetText("")
        end

        if t then
            ApplyFactionCardVisual(card, t, card.factionCardHovered)
        end

        if showCards then
            card:Show()
        else
            card:Hide()
        end
    end
end

local function BuildFactionWindowTitleText()
    local data = LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY]
    local cCol = C_ClassColor.GetClassColor((data and data.class) or "WARRIOR")
    return string.format(L["TITLE_FACTION_WEEKLIES"], "|c" .. cCol:GenerateHexColor() .. UnitName("player") .. "|r")
end

local function GetActiveFactionWeeklyTab()
    return GetFactionWeeklyTabDef(factionWeeklyMode)
end

local function GetFactionWarningText(def)
    if not def or def.key ~= "silvermoon" then
        return ""
    end
    if def.warningKey and L and L[def.warningKey] and L[def.warningKey] ~= def.warningKey then
        return L[def.warningKey]
    end
    return def.warningText or ""
end

local function UpdateFactionWarningLayout(warningText)
    warningText = warningText or ""
    factionUI.warning:SetText(warningText)
    factionUI.warning:SetPoint("TOPLEFT", 20, -120)
    factionUI.warning:SetPoint("RIGHT", -20, 0)

    if warningText ~= "" then
        factionUI.scrollFrame:SetPoint("TOPLEFT", 20, -162)
        factionUI.warning:Show()
    else
        factionUI.scrollFrame:SetPoint("TOPLEFT", 20, -120)
        factionUI.warning:Hide()
    end
end

local function GetHaratiWeeklyParentRecord(charDB, currentReset)
    local record = charDB and charDB.weeklyQuests and charDB.weeklyQuests["Legends of the Haranir"]
    if not record then
        return nil
    end
    if currentReset and ((not record.updatedAt) or record.updatedAt < currentReset) then
        return nil
    end
    return record
end

local function QuestMatchesHaratiRecord(quest, recordQuestID)
    if not (quest and recordQuestID) then
        return false
    end
    if quest.id == recordQuestID then
        return true
    end
    for _, variantID in ipairs(quest.variants or {}) do
        if variantID == recordQuestID then
            return true
        end
    end
    return false
end

local function GetHaratiQuestState(quest, charDB, trackedCfg, currentReset)
    if not (quest and trackedCfg) then
        return "not_started"
    end

    if quest.id == trackedCfg.parentID and lv.GetHaratiWeeklyState then
        local state = lv.GetHaratiWeeklyState(charDB)
        if state ~= "not_started" then
            return state
        end
        for _, relic in ipairs(lv.HARATI_RELICS or {}) do
            if C_QuestLog.GetLogIndexForQuestID(relic.firstQuestID)
                or C_QuestLog.GetLogIndexForQuestID(relic.repeatQuestID) then
                return "in_progress"
            end
        end
        return "not_started"
    end

    local haratiWeekly = charDB and charDB.weeklyQuests
    local childDone = false
    local childInProgress = false

    if haratiWeekly then
        for i = 2, #(lv.WEEKLY_HARATI_QUESTS or {}) do
            local childQuest = lv.WEEKLY_HARATI_QUESTS[i]
            local childRecord = childQuest and haratiWeekly[childQuest.name]
            if childRecord and ((not currentReset) or ((childRecord.updatedAt or 0) >= currentReset)) then
                if childRecord.state == "done" then
                    childDone = true
                    break
                elseif childRecord.state == "in_progress" then
                    childInProgress = true
                end
            end
        end
    end

    if not childDone then
        for _, childID in ipairs(trackedCfg.childIDs or {}) do
            if C_QuestLog.GetLogIndexForQuestID(childID) then
                childInProgress = true
                break
            end
        end
    end

    if quest.id == trackedCfg.parentID then
        if childDone then
            return "done"
        end
        if childInProgress then
            return "in_progress"
        end
        if C_QuestLog.GetLogIndexForQuestID(quest.id) then
            return "in_progress"
        end
        return "not_started"
    end

    local parentRecord = GetHaratiWeeklyParentRecord(charDB, currentReset)

    if parentRecord and QuestMatchesHaratiRecord(quest, parentRecord.questID) then
        return parentRecord.state or "not_started"
    end

    if C_QuestLog.GetLogIndexForQuestID(quest.id) then
        return "in_progress"
    end
    for _, variantID in ipairs(quest.variants or {}) do
        if C_QuestLog.GetLogIndexForQuestID(variantID) then
            return "in_progress"
        end
    end

    return "not_started"
end

local function GetFactionQuestState(quest)
    if factionWeeklyMode == "ritualsites" then
        local state = GetGroupedWeeklyQuestState(quest)
        if state then
            return state
        end
        if quest and quest.accountWide then
            if C_QuestLog.IsQuestFlaggedCompleted(quest.id) then
                return "done"
            elseif C_QuestLog.GetLogIndexForQuestID(quest.id) then
                return "in_progress"
            end
        end
        return "not_started"
    end

    local trackedChoices = lv.ACCOUNT_WIDE_FACTION_CHOICES
    local trackedCfg = trackedChoices and trackedChoices[factionWeeklyMode]
    local currentReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    local savedChoice
    if trackedCfg and trackedCfg.permanent then
        savedChoice = LiteVaultDB and LiteVaultDB.permanentFactionCompletions and LiteVaultDB.permanentFactionCompletions[factionWeeklyMode]
    else
        savedChoice = trackedCfg and LiteVaultDB and LiteVaultDB.accountWideFactionChoices and LiteVaultDB.accountWideFactionChoices[factionWeeklyMode]
    end
    if savedChoice and currentReset and ((not savedChoice.updatedAt) or savedChoice.updatedAt < currentReset) then
        savedChoice = nil
    end
    local usesSilvermoonCharTracking = (
        factionWeeklyMode == "silvermoon" and
        trackedCfg and
        trackedCfg.trackDailiesPerChar
    )
    local usesHaratiCharTracking = (
        factionWeeklyMode == "harati" and
        trackedCfg and
        trackedCfg.trackParentPerChar
    )
    local currentSilvermoonChoice = (
        usesSilvermoonCharTracking and
        savedChoice and
        savedChoice.sourceKey == lv.PLAYER_KEY
    ) and savedChoice or nil
    if usesSilvermoonCharTracking or usesHaratiCharTracking then
        savedChoice = nil
    end
    local charDB = LiteVaultDB and lv.PLAYER_KEY and LiteVaultDB[lv.PLAYER_KEY]
    local weeklyDailies = charDB and charDB.factionDailiesThisWeek and charDB.factionDailiesThisWeek[factionWeeklyMode]
    local parentWeeklies = charDB and charDB.factionParentWeeklies and charDB.factionParentWeeklies[factionWeeklyMode]
    if usesHaratiCharTracking and trackedCfg then
            if quest.id == trackedCfg.parentID or (trackedCfg.childLookup and trackedCfg.childLookup[quest.id]) then
                return GetHaratiQuestState(quest, charDB, trackedCfg, currentReset)
            end
    end
    if trackedCfg and quest.id == trackedCfg.parentID and not usesHaratiCharTracking then
            if trackedCfg.trackParentPerChar then
                local haratiWeeklyDone = false
                local haratiWeeklyInProgress = false
                local haratiWeekly = charDB and charDB.weeklyQuests
                if haratiWeekly then
                    local parentRecord = haratiWeekly["Legends of the Haranir"]
                    if parentRecord and parentRecord.state == "done" then
                        haratiWeeklyDone = true
                    elseif parentRecord and parentRecord.state == "in_progress" then
                        haratiWeeklyInProgress = true
                    else
                        for i = 2, #(lv.WEEKLY_HARATI_QUESTS or {}) do
                            local childRecord = haratiWeekly[(lv.WEEKLY_HARATI_QUESTS[i] and lv.WEEKLY_HARATI_QUESTS[i].name) or ""]
                            if childRecord and childRecord.state == "done" then
                                haratiWeeklyDone = true
                                break
                            elseif childRecord and childRecord.state == "in_progress" then
                                haratiWeeklyInProgress = true
                            end
                        end
                    end
                end
                local childDone = false
                local childInProgress = false
                for _, childID in ipairs(trackedCfg.childIDs or {}) do
                    if weeklyDailies and weeklyDailies[childID] then
                        childDone = true
                        break
                    end
                    if C_QuestLog.GetLogIndexForQuestID(childID) then
                        childInProgress = true
                    end
                end
                if haratiWeeklyDone then return "done" end
                if haratiWeeklyInProgress then return "in_progress" end
                if parentWeeklies and parentWeeklies[quest.id] and parentWeeklies[quest.id].state == "done" then return "done" end
                if weeklyDailies and weeklyDailies[quest.id] then return "done" end
                if childDone then return "done" end
                if childInProgress or C_QuestLog.GetLogIndexForQuestID(quest.id) then return "in_progress" end
                return "not_started"
            end
            if usesSilvermoonCharTracking then
                if parentWeeklies and parentWeeklies[quest.id] and parentWeeklies[quest.id].state == "done" then return "done" end
                if C_QuestLog.GetLogIndexForQuestID(quest.id) then return "in_progress" end
                return "not_started"
            end
            if savedChoice then
                return savedChoice.state or "not_started"
            end
    end
    if trackedCfg and trackedCfg.childLookup and trackedCfg.childLookup[quest.id] and not usesHaratiCharTracking then
            if trackedCfg.authoritativeChoice and savedChoice then
                if savedChoice.questID then
                    -- Account-wide authoritative: only the chosen quest is active, others are locked
                    if savedChoice.questID == quest.id then
                        return savedChoice.state or "not_started"
                    end
                    return "not_started"
                else
                    -- Permanent event is done but the specific child choice is unknown.
                    -- Hide child rows so only the parent completion line is shown.
                    if trackedCfg.permanent then
                        return "not_started"
                    end
                    local isDone = C_QuestLog.IsQuestFlaggedCompleted(quest.id)
                    if isDone then return "done" end
                    if C_QuestLog.GetLogIndexForQuestID(quest.id) then return "in_progress" end
                    return "not_started"
                end
            end

            -- Sub-faction selection quests are account-wide: once a sub-faction is chosen,
            -- the other sub-faction quests are locked for the whole account this week.
            if savedChoice and trackedCfg.subFactionLookup and trackedCfg.subFactionLookup[quest.id] then
                if savedChoice.questID == quest.id then
                    return savedChoice.state or "not_started"
                end
                if trackedCfg.subFactionLookup[savedChoice.questID] then
                    return "not_started"
                end
            end

            -- Daily quests: use per-character weekly DB only.
            if trackedCfg.trackDailiesPerChar then
                if weeklyDailies and weeklyDailies[quest.id] then return "done" end
                if C_QuestLog.GetLogIndexForQuestID(quest.id) then return "in_progress" end
                if trackedCfg.subFactionLookup and currentSilvermoonChoice and currentSilvermoonChoice.questID == quest.id and currentSilvermoonChoice.state == "done" then
                    return "done"
                end
                return "not_started"
            end

            local isDone = C_QuestLog.IsQuestFlaggedCompleted(quest.id)
            local isInProgress = not isDone and C_QuestLog.GetLogIndexForQuestID(quest.id)
            if isDone then return "done" end
            if isInProgress then return "in_progress" end
            return "not_started"
        end

    local savedState = GetSavedCharacterWeeklyQuestState(quest)
    if savedState == "done" then return "done" end
    if savedState == "in_progress" and C_QuestLog.GetLogIndexForQuestID(quest.id) then return "in_progress" end

    local isDone = C_QuestLog.IsQuestFlaggedCompleted(quest.id)
    local isInProgress = not isDone and C_QuestLog.GetLogIndexForQuestID(quest.id)

    if isDone then
        return "done"
    elseif isInProgress then
        return "in_progress"
    end

    return "not_started"
end

local function BuildFactionQuestStatusText(state)
    if state == "done" then
        return "|cff00ff00" .. L["STATUS_DONE"] .. "|r"
    elseif state == "in_progress" then
        return "|cffffff00" .. L["STATUS_IN_PROGRESS"] .. "|r"
    elseif state == "locked" then
        return "|cffff9900" .. L["STATUS_LOCKED"] .. "|r"
    end

    return "|cffff0000" .. L["STATUS_NOT_STARTED"] .. "|r"
end

local function BuildFactionQuestRowText(quest)
    if factionWeeklyMode == "silvermoon" and quest then
        local showSilvermoonQuest = (
            quest.id == 91966 or
            quest.id == 90574 or
            quest.id == 90576 or
            quest.id == 90573 or
            quest.id == 90575
        )
        if not showSilvermoonQuest then
            return nil
        end
    end
    if factionWeeklyMode == "harati" and quest and quest.id ~= lv.HARATI_SELECTOR_QUEST_ID then
        return nil
    end
    local state = GetFactionQuestState(quest)
    if state ~= "done" then
        return nil
    end
    local row = GetWeeklyQuestDisplayName(quest) .. ": " .. BuildFactionQuestStatusText(state)
    local nextWeekText = BuildWeeklyQuestNextWeekText(quest)
    if nextWeekText then
        row = row .. "\n  " .. nextWeekText
    end
    return row
end

local function BuildFactionQuestText(quests)
    local rows = {}
    for _, quest in ipairs(quests or {}) do
        local row = BuildFactionQuestRowText(quest)
        if row then
            rows[#rows + 1] = row
        end
    end

    if #rows == 0 then
        return UIText("MSG_NO_FACTION_WEEKLY_COMPLETIONS"), 0
    end
    return table.concat(rows, "\n"), #rows
end

function lv.UpdateFactionWeeklyWindow()
    factionTitle:SetText(BuildFactionWindowTitleText())
    UpdateFactionTabButtons()

    local def = GetActiveFactionWeeklyTab()
    local quests = (def and def.quests and def.quests()) or {}
    local warningText = GetFactionWarningText(def)
    UpdateFactionWarningLayout(warningText)
    factionUI.content:Show()
    SetTokkaTrackerVisible(false)
    local renderedText, renderedRows = BuildFactionQuestText(quests)
    local emptyCompletedRows = renderedRows == 0
    local theme = lv.GetTheme()
    factionUI.content:SetJustifyH(emptyCompletedRows and "CENTER" or "LEFT")
    if emptyCompletedRows then
        factionUI.content:SetTextColor(unpack(theme.textMuted))
    else
        factionUI.content:SetTextColor(1, 1, 1, 1)
    end
    factionUI.content:SetText("")
    factionUI.content:SetText(renderedText)
    RefreshFactionScrollLayout(true)

    RefreshFactionCards()
end

SLASH_LVHARATIDEBUG1 = "/lvharatidebug"
SlashCmdList["LVHARATIDEBUG"] = function()
    local lines = {}
    local function HaratiDebugBool(value)
        return value and "true" or "false"
    end
    local function HaratiDebugValue(value)
        if value == nil then return "nil" end
        return tostring(value)
    end
    local function EmitHaratiDebug(outputLines)
        local chunkSize = 8
        local chunkCount = math.max(1, math.ceil(#outputLines / chunkSize))
        for chunk = 1, chunkCount do
            if chunkCount > 1 then
                DEFAULT_CHAT_FRAME:AddMessage(string.format(
                    "|cff66ccffLiteVault Hara'ti Debug:|r chunk %d/%d", chunk, chunkCount
                ))
            end
            local first = ((chunk - 1) * chunkSize) + 1
            local last = math.min(chunk * chunkSize, #outputLines)
            for index = first, last do
                DEFAULT_CHAT_FRAME:AddMessage(outputLines[index])
            end
        end
    end
    local function Add(line)
        lines[#lines + 1] = line
    end
    local function QuestInLog(questID)
        return C_QuestLog and C_QuestLog.GetLogIndexForQuestID
            and C_QuestLog.GetLogIndexForQuestID(questID) ~= nil or false
    end
    local function CharacterCompleted(questID)
        return C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted
            and C_QuestLog.IsQuestFlaggedCompleted(questID) and true or false
    end
    local function AccountCompleted(questID)
        return C_QuestLog and C_QuestLog.IsQuestFlaggedCompletedOnAccount
            and C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID) and true or false
    end
    local function JoinIDs(ids)
        return #ids > 0 and table.concat(ids, ",") or "none"
    end

    local playerKey = lv.PLAYER_KEY
    local charDB = LiteVaultDB and playerKey and LiteVaultDB[playerKey] or nil
    local weeklyQuests = type(charDB) == "table" and charDB.weeklyQuests or nil
    local observations = type(charDB) == "table" and charDB.haratiFirstQuestObservations or nil
    local haratiWeekly = type(charDB) == "table" and charDB.haratiWeekly or nil
    local currentReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or nil
    local currentState, currentRecord = "unavailable", nil
    if lv.GetHaratiWeeklyState then
        currentState, currentRecord = lv.GetHaratiWeeklyState(charDB)
    end
    local characterName = UnitName and UnitName("player") or nil
    local realmName = GetNormalizedRealmName and GetNormalizedRealmName()
        or (GetRealmName and GetRealmName()) or nil
    local parentSaved = weeklyQuests and weeklyQuests["Legends of the Haranir"] or nil
    local repeatCandidates, firstCandidates, migrationCandidates, selectorCandidates = {}, {}, {}, {}

    Add("=== HARA'TI CORE ===")
    Add(string.format("playerKey=%s character=%s realm=%s reset=%s mode=%s state=%s",
        HaratiDebugValue(playerKey), HaratiDebugValue(characterName), HaratiDebugValue(realmName),
        HaratiDebugValue(currentReset), HaratiDebugValue(factionWeeklyMode), HaratiDebugValue(currentState)))
    if type(haratiWeekly) == "table" then
        Add(string.format("haratiWeekly completed=%s selected=%s resetStart=%s questID=%s path=%s source=%s completedAt=%s selectedAt=%s",
            HaratiDebugValue(haratiWeekly.completed), HaratiDebugValue(haratiWeekly.selected),
            HaratiDebugValue(haratiWeekly.resetStart), HaratiDebugValue(haratiWeekly.questID),
            HaratiDebugValue(haratiWeekly.path), HaratiDebugValue(haratiWeekly.source),
            HaratiDebugValue(haratiWeekly.completedAt), HaratiDebugValue(haratiWeekly.selectedAt)))
    else
        Add("haratiWeekly=nil")
    end
    if type(parentSaved) == "table" then
        Add(string.format("parent state=%s questID=%s title=%s updatedAt=%s resetStart=%s week=%s weekKey=%s source=%s",
            HaratiDebugValue(parentSaved.state), HaratiDebugValue(parentSaved.questID),
            HaratiDebugValue(parentSaved.title), HaratiDebugValue(parentSaved.updatedAt),
            HaratiDebugValue(parentSaved.resetStart), HaratiDebugValue(parentSaved.week),
            HaratiDebugValue(parentSaved.weekKey), HaratiDebugValue(parentSaved.source)))
    else
        Add("parent weeklyQuests[Legends of the Haranir]=nil")
    end

    Add("=== SELECTORS ===")
    local selectors = {
        {id = lv.HARATI_SELECTOR_FIRST, name = "Lost Legends"},
        {id = lv.HARATI_SELECTOR_REPEAT, name = "Echoes Rekindled"},
    }
    for _, selector in ipairs(selectors) do
        local inLog = QuestInLog(selector.id)
        local wouldSelect = inLog and currentState == "not_started"
        if wouldSelect then selectorCandidates[#selectorCandidates + 1] = selector.id end
        Add(string.format("%d %s inLog=%s character=%s account=%s class=%s selectorWouldFire=%s savedParentState=%s savedParentQuestID=%s",
            selector.id, selector.name, HaratiDebugBool(inLog), HaratiDebugBool(CharacterCompleted(selector.id)),
            HaratiDebugBool(AccountCompleted(selector.id)), HaratiDebugValue(lv.HARATI_SELECTOR_LOOKUP[selector.id]),
            HaratiDebugBool(wouldSelect), HaratiDebugValue(parentSaved and parentSaved.state),
            HaratiDebugValue(parentSaved and parentSaved.questID)))
    end

    Add("=== FIRST-TIME RELICS ===")
    for _, relic in ipairs(lv.HARATI_RELICS or {}) do
        local saved = weeklyQuests and weeklyQuests[relic.name] or nil
        local observation = observations and observations[relic.firstQuestID] or nil
        local completed = CharacterCompleted(relic.firstQuestID)
        local observedTransition = currentState ~= "done" and type(observation) == "table"
            and observation.resetStart == currentReset and observation.completed == false and completed == true
        local wouldFire = false
        Add(string.format("%d %s inLog=%s character=%s account=%s saved=%s/%s/%s observation=%s reset=%s previous=%s observedAt=%s transitionObserved=%s transitionWouldFire=%s",
            relic.firstQuestID, relic.name, HaratiDebugBool(QuestInLog(relic.firstQuestID)),
            HaratiDebugBool(completed), HaratiDebugBool(AccountCompleted(relic.firstQuestID)),
            HaratiDebugValue(saved and saved.state), HaratiDebugValue(saved and saved.questID),
            HaratiDebugValue(saved and saved.updatedAt), type(observation) == "table" and "present" or "nil",
            HaratiDebugValue(observation and observation.resetStart),
            HaratiDebugValue(observation and observation.completed),
            HaratiDebugValue(observation and observation.observedAt), HaratiDebugBool(observedTransition),
            HaratiDebugBool(wouldFire)))
    end

    Add("=== REPEAT RELICS ===")
    for _, relic in ipairs(lv.HARATI_RELICS or {}) do
        local saved = weeklyQuests and weeklyQuests[relic.name] or nil
        local completed = CharacterCompleted(relic.repeatQuestID)
        local wouldFire = currentState ~= "done" and completed
        if wouldFire then repeatCandidates[#repeatCandidates + 1] = relic.repeatQuestID end
        Add(string.format("%d %s inLog=%s character=%s account=%s saved=%s/%s/%s repeatWouldFire=%s",
            relic.repeatQuestID, relic.name, HaratiDebugBool(QuestInLog(relic.repeatQuestID)),
            HaratiDebugBool(completed), HaratiDebugBool(AccountCompleted(relic.repeatQuestID)),
            HaratiDebugValue(saved and saved.state), HaratiDebugValue(saved and saved.questID),
            HaratiDebugValue(saved and saved.updatedAt), HaratiDebugBool(wouldFire)))
    end

    Add("=== SAVED CHILD RECORDS ===")
    for _, relic in ipairs(lv.HARATI_RELICS or {}) do
        local saved = weeklyQuests and weeklyQuests[relic.name] or nil
        local recognized = type(saved) == "table" and lv.GetHaratiRelicForQuestID
            and lv.GetHaratiRelicForQuestID(saved.questID) ~= nil or false
        local wouldFire = type(saved) == "table" and saved.state == "done"
            and (saved.updatedAt or 0) >= (currentReset or math.huge) and recognized
        if wouldFire then migrationCandidates[#migrationCandidates + 1] = saved.questID end
        Add(string.format("%s state=%s questID=%s title=%s updatedAt=%s recognized=%s migrationWouldFire=%s%s",
            relic.name, HaratiDebugValue(saved and saved.state), HaratiDebugValue(saved and saved.questID),
            HaratiDebugValue(saved and saved.title), HaratiDebugValue(saved and saved.updatedAt),
            HaratiDebugBool(recognized), HaratiDebugBool(wouldFire),
            wouldFire and (" MIGRATION WOULD FIRE: " .. tostring(saved.questID)) or ""))
    end

    local winningSource = "no_completion_evidence"
    if currentState == "done" and type(currentRecord) == "table" then
        local source = currentRecord.source
        if source == "repeat_flag_reconstruction" then
            winningSource = "repeat_flag_reconstruction:" .. HaratiDebugValue(currentRecord.questID)
        elseif source == "same_reset_flag_transition" then
            winningSource = "same_reset_flag_transition:" .. HaratiDebugValue(currentRecord.questID)
        elseif source == "12.0.7.4_migration" then
            winningSource = "12.0.7.4_migration:" .. HaratiDebugValue(currentRecord.questID)
        elseif source == "quest_turn_in" then
            winningSource = "actual_relic_turnin:" .. HaratiDebugValue(currentRecord.questID)
        elseif source == nil then
            winningSource = "unknown_existing_record"
        else
            winningSource = "haratiWeekly_current_reset_completed"
        end
    elseif currentState == "in_progress" then
        winningSource = "selector_only"
    elseif type(haratiWeekly) == "table" and haratiWeekly.completed then
        winningSource = "unknown_existing_record"
    end

    Add("=== RECONSTRUCTION SUMMARY ===")
    Add(string.format("current haratiWeekly=%s stored source=%s", HaratiDebugValue(currentState),
        HaratiDebugValue(haratiWeekly and haratiWeekly.source)))
    Add(string.format("selector-only evidence=%s actual local turn-in evidence=%s",
        JoinIDs(selectorCandidates), haratiWeekly and haratiWeekly.source == "quest_turn_in"
            and HaratiDebugValue(haratiWeekly.questID) or "unavailable/not recorded"))
    Add("repeat reconstruction candidates=" .. JoinIDs(repeatCandidates))
    Add("same-reset first-transition candidates=" .. JoinIDs(firstCandidates))
    Add("migration candidates=" .. JoinIDs(migrationCandidates))
    Add("WINNING CURRENT STATE SOURCE: " .. winningSource)

    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        EmitHaratiDebug(lines)
    end
end

function lv.UpdateCaptainTokkaWindow()
    local theme = lv.GetTheme()
    FactionTokkaWindow:SetBackdropColor(unpack(theme.background))
    lv.ApplyBorderStyle(FactionTokkaWindow, "panel", theme)
    tokkaTitle:SetText(L["BUTTON_CAPTAIN_TOKKA"])
    tokkaWarning:SetText(L["WARNING_TOKKA_ONE_TIME_ARTIFACTS"])
    local reputationText = BuildFactionRenownText("tokka")
    tokkaReputation:SetText(reputationText or L["LABEL_RENOWN_UNAVAILABLE"])
    SetTokkaTrackerVisible(true)
    RenderTokkaTracker()
end

function lv.ShowFactionSection()
    for _, button in pairs(factionSectionTabs) do button:Show() end
    SetFactionSectionMode("weeklies")
end

function lv.HideFactionSection()
    FactionWeeklyWindow:Hide()
    if FactionTokkaWindow then FactionTokkaWindow:Hide() end
    for _, button in pairs(factionSectionTabs) do button:Hide() end
    SetFactionCardsVisible(false)
end

function lv.ShowFactionWeeklyWindow()
    if lv.SetMainView then
        lv.SetMainView("factions")
    else
        lv.ShowFactionSection()
        if lv.RefreshAchievementsButton then
            lv.RefreshAchievementsButton()
        end
        if lv.UpdateFactionWeeklyWindow then
            lv.UpdateFactionWeeklyWindow()
        end
    end
end

FactionWeeklyWindow:SetScript("OnHide", function()
    SetFactionCardsVisible(false)
    if lv.RefreshAchievementsButton then
        lv.RefreshAchievementsButton()
    end
end)

FactionWeeklyWindow:SetScript("OnShow", function()
    RefreshFactionCards()
end)

function lv.UpdateTotalDisplay(totG, totP)
    if not LVWindow.totalBg then
        LVWindow.totalBg = CreateFrame("Frame", nil, LVWindow, "BackdropTemplate")
        LVWindow.totalBg:SetPoint("BOTTOMLEFT", 35, 26)
        LVWindow.totalBg:SetSize(lv.Layout.totalDisplayWidth, 52)
        LVWindow.totalBg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        lv.EnsureBorderStyle(LVWindow.totalBg, "panelStructural")

        -- Register for theming
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(LVWindow.totalBg, function(f, theme)
                f:SetBackdropColor(unpack(theme.backgroundSolid))
                lv.ApplyBorderStyle(f, "panelStructural", theme)
            end)
        end

        -- Time Text & Interaction (Right)
        LVWindow.timeBtn = CreateFrame("Button", nil, LVWindow.totalBg)
        LVWindow.timeBtn:SetSize(200, 40)
        LVWindow.timeBtn:SetPoint("RIGHT", -20, 0)
        LVWindow.timeText = LVWindow.timeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LVWindow.timeText:SetPoint("RIGHT", 0, 0)
        LVWindow.timeStyle = 1 -- Default style

        -- Keep both money values in a compact, fixed column just after the
        -- longer Warband Bank label. Total Time retains its own right column.
        local moneyValueLeft = lv.Layout.totalGoldLeft + 125

        -- Total Gold row (left label, aligned value column)
        LVWindow.totalLabel = LVWindow.totalBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LVWindow.totalLabel:SetPoint("LEFT", lv.Layout.totalGoldLeft, 10)
        LVWindow.totalLabel:SetTextColor(1, 0.82, 0)

        LVWindow.totalValue = LVWindow.totalBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LVWindow.totalValue:SetPoint("LEFT", LVWindow.totalBg, "LEFT", moneyValueLeft, 10)
        LVWindow.totalValue:SetJustifyH("LEFT")

        -- Warband Bank row (same font as Total Gold)
        LVWindow.wbBankLabel = LVWindow.totalBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LVWindow.wbBankLabel:SetPoint("LEFT", lv.Layout.totalGoldLeft, -10)
        LVWindow.wbBankLabel:SetTextColor(1, 0.82, 0)

        LVWindow.wbBankValue = LVWindow.totalBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LVWindow.wbBankValue:SetPoint("LEFT", LVWindow.totalBg, "LEFT", moneyValueLeft, -10)
        LVWindow.wbBankValue:SetJustifyH("LEFT")

        local function CreateMoneyTooltipTarget(yOffset, titleProvider, amountKey)
            local target = CreateFrame("Frame", nil, LVWindow.totalBg)
            target:SetPoint("LEFT", 0, yOffset)
            target:SetPoint("RIGHT", LVWindow.timeBtn, "LEFT", -4, yOffset)
            target:SetHeight(22)
            target:EnableMouse(true)
            target:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(titleProvider(), 1, 0.82, 0)
                GameTooltip:AddLine(FormatDashboardExactMoney(LVWindow[amountKey]), 1, 1, 1)
                GameTooltip:Show()
            end)
            target:SetScript("OnLeave", function() GameTooltip:Hide() end)
            return target
        end

        LVWindow.totalMoneyTooltip = CreateMoneyTooltipTarget(10, function()
            return L["LABEL_TOTAL_GOLD"]:gsub("%%s", "")
        end, "totalMoneyExact")
        LVWindow.wbBankMoneyTooltip = CreateMoneyTooltipTarget(-10, function()
            return L["LABEL_WARBAND_BANK"]
        end, "wbBankMoneyExact")

        LVWindow.timeBtn:SetScript("OnClick", function()
            LVWindow.timeStyle = LVWindow.timeStyle + 1
            if LVWindow.timeStyle > 3 then LVWindow.timeStyle = 1 end
            if lv.UpdateUI then lv.UpdateUI() end
        end)

        LVWindow.timeBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(L["TOOLTIP_TOTAL_TIME_TITLE"])
            GameTooltip:AddLine(L["TOOLTIP_TOTAL_TIME_DESC"], 1, 1, 1)
            GameTooltip:AddLine("|cff00ccff" .. L["TOOLTIP_TOTAL_TIME_CLICK"] .. "|r")
            GameTooltip:Show()
        end)
        LVWindow.timeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    if currentMainView ~= "dashboard" then
        LVWindow.totalBg:Hide()
        return
    end

    LVWindow.totalBg:Show()

    -- Apply theme colors
    local t = lv.GetTheme()
    LVWindow.totalBg:SetBackdropColor(unpack(t.backgroundSolid))
    lv.ApplyBorderStyle(LVWindow.totalBg, "panelStructural", t)
    local totalGoldLabel = L["LABEL_TOTAL_GOLD"]:gsub("%%s", "")
    if LVWindow.totalLabel then
        LVWindow.totalLabel:SetText(totalGoldLabel)
    end
    if LVWindow.totalValue then
        LVWindow.totalMoneyExact = totG
        LVWindow.totalValue:SetText(FormatDashboardMoney(totG, 14))
    end
    local wbBankGold = (LiteVaultDB["Warband Bank"] and LiteVaultDB["Warband Bank"].gold) or 0
    if LVWindow.wbBankLabel then
        LVWindow.wbBankLabel:SetText(L["LABEL_WARBAND_BANK"])
    end
    if LVWindow.wbBankValue then
        LVWindow.wbBankMoneyExact = wbBankGold
        LVWindow.wbBankValue:SetText(FormatDashboardMoney(wbBankGold, 14))
    end
    if lv.FormatWarbandTime then
        LVWindow.timeText:SetText(string.format(L["LABEL_TOTAL_TIME"], lv.FormatWarbandTime(totP, LVWindow.timeStyle)))
    else
        LVWindow.timeText:SetText(string.format(L["LABEL_COMBINED_TIME"], math.floor(totP/86400), math.floor((totP%86400)/3600)))
    end
end

function lv.UpdateUI(force)
    if not force and LVWindow and not LVWindow:IsShown() then return end
    if lv.UpdateList then lv.UpdateList() end
    if lv.UpdateCalendar then lv.UpdateCalendar() end
    if lv.UpdateTrackingDisplays then lv.UpdateTrackingDisplays() end
end

-- 6. NEW CUSTOM PROMPT FRAME (CENTERED & STYLED)
local Prompt = CreateFrame("Frame", "LiteVaultTrackPrompt", UIParent, "BackdropTemplate")
Prompt:SetSize(460, 160)
Prompt:SetPoint("CENTER", 0, 100)
Prompt:SetFrameStrata("FULLSCREEN_DIALOG") -- Sits above Blizzard UI
Prompt:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
Prompt:Hide()

local promptUI = {}
promptUI.text = Prompt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
promptUI.text:SetPoint("CENTER", 0, 20)
promptUI.text:SetWidth(420)

promptUI.yesBtn = CreateFrame("Button", nil, Prompt, "BackdropTemplate")
promptUI.yesBtn:SetSize(100, 30)
promptUI.yesBtn:SetPoint("BOTTOMRIGHT", Prompt, "BOTTOM", -10, 20)
promptUI.yesBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
promptUI.yesBtn.Text = promptUI.yesBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
promptUI.yesBtn.Text:SetPoint("CENTER"); promptUI.yesBtn.Text:SetText(L["BUTTON_YES"])
promptUI.yesBtn:SetScript("OnClick", function()
    -- FIX: Force create the entry so UpdateCurrentCharData has something to write to
    if not LiteVaultDB[lv.PLAYER_KEY] then LiteVaultDB[lv.PLAYER_KEY] = {} end

    if lv.UpdateCurrentCharData then lv.UpdateCurrentCharData() end
    if lv.UpdateUI then lv.UpdateUI() end
    Prompt:Hide()
end)
promptUI.yesBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
promptUI.yesBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBg))
end)

promptUI.noBtn = CreateFrame("Button", nil, Prompt, "BackdropTemplate")
promptUI.noBtn:SetSize(100, 30)
promptUI.noBtn:SetPoint("BOTTOMLEFT", Prompt, "BOTTOM", 10, 20)
promptUI.noBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
promptUI.noBtn.Text = promptUI.noBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
promptUI.noBtn.Text:SetPoint("CENTER"); promptUI.noBtn.Text:SetText(L["BUTTON_NO"])
promptUI.noBtn:SetScript("OnClick", function()
    -- Remember they declined (separate from ignored list)
    if not LiteVaultDB.declinedCharacters then LiteVaultDB.declinedCharacters = {} end
    LiteVaultDB.declinedCharacters[lv.PLAYER_KEY] = true
    Prompt:Hide()
end)
promptUI.noBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
promptUI.noBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBg))
end)

-- Register prompt for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(Prompt, function(f, theme)
            f:SetBackdropColor(unpack(theme.dataBoxBg))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        lv.RegisterThemedElement(promptUI.yesBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        lv.RegisterThemedElement(promptUI.noBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        -- Apply initial theme
        local t = lv.GetTheme()
        Prompt:SetBackdropColor(unpack(t.dataBoxBg))
        Prompt:SetBackdropBorderColor(unpack(t.borderPrimary))
        promptUI.yesBtn:SetBackdropColor(unpack(t.buttonBg))
        promptUI.yesBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        promptUI.noBtn:SetBackdropColor(unpack(t.buttonBg))
        promptUI.noBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

function lv.ShowTrackPrompt()
    local name = UnitName("player")
    local _, class = UnitClass("player")
    local cCol = C_ClassColor.GetClassColor(class or "WARRIOR")
    promptUI.text:SetText(string.format(L["PROMPT_GREETINGS"], cCol:WrapTextInColorCode(name)))
    Prompt:Show()
end
-- ===========================================
-- WARBAND BANK LEDGER WINDOW
-- ===========================================
function lv.ShowWarbandLedger()
    if not lv.WarbandLedgerWindow then
        local f = CreateFrame("Frame", "LiteVaultWarbandLedger", UIParent, "BackdropTemplate")
        f:SetSize(420, 380)
        f:SetPoint("CENTER")
        f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetFrameStrata("DIALOG")
        table.insert(UISpecialFrames, "LiteVaultWarbandLedger")

        -- Register for theming
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(f, function(frame, theme)
                frame:SetBackdropColor(unpack(theme.backgroundSolid))
                frame:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
        end

        -- Apply initial theme
        local t = lv.GetTheme()
        f:SetBackdropColor(unpack(t.backgroundSolid))
        f:SetBackdropBorderColor(unpack(t.borderPrimary))

        -- Title
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOPLEFT", 15, -15)
        title:SetText(L["TITLE_WARBAND_LEDGER"])
        f.title = title

        -- Close button (styled like main UI)
        local closeBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        closeBtn:SetSize(60, 22)
        closeBtn:SetPoint("TOPRIGHT", -10, -10)
        closeBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })

        closeBtn.Text = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        closeBtn.Text:SetPoint("CENTER")
        closeBtn.Text:SetText(L["BUTTON_CLOSE"])
        f.closeBtn = closeBtn

        -- Register close button for theming
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(closeBtn, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
        end

        -- Apply initial theme to close button
        closeBtn:SetBackdropColor(unpack(t.buttonBgAlt))
        closeBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        closeBtn.Text:SetTextColor(unpack(t.textPrimary))

        closeBtn:SetScript("OnClick", function() f:Hide() end)
        closeBtn:SetScript("OnEnter", function(self)
            local theme = lv.GetTheme()
            self:SetBackdropBorderColor(unpack(theme.borderHover))
            self:SetBackdropColor(unpack(theme.buttonBgHover))
            self.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        closeBtn:SetScript("OnLeave", function(self)
            local theme = lv.GetTheme()
            self:SetBackdropBorderColor(unpack(theme.borderPrimary))
            self:SetBackdropColor(unpack(theme.buttonBgAlt))
            self.Text:SetTextColor(unpack(theme.textPrimary))
        end)

        -- Current balance
        f.balanceLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.balanceLabel:SetPoint("TOPLEFT", 15, -45)
        f.balanceLabel:SetText(L["LABEL_CURRENT_BALANCE"])
        f.balanceLabel:SetTextColor(1, 0.84, 0)

        f.balanceValue = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.balanceValue:SetPoint("TOPRIGHT", -15, -45)

        -- Recent transactions header
        f.txHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.txHeader:SetPoint("TOPLEFT", 15, -70)
        f.txHeader:SetText(L["LABEL_RECENT_TRANSACTIONS"])
        f.txHeader:SetTextColor(1, 1, 0)

        f.txScroll = CreateFrame("ScrollFrame", nil, f)
        f.txScroll:SetPoint("TOPLEFT", 15, -90)
        f.txScroll:SetPoint("BOTTOMRIGHT", -15, 15)
        f.txScroll:EnableMouseWheel(true)

        f.txContent = CreateFrame("Frame", nil, f.txScroll)
        f.txContent:SetSize(390, 1)
        f.txScroll:SetScrollChild(f.txContent)
        f.txScroll:SetScript("OnMouseWheel", function(self, delta)
            local current = self:GetVerticalScroll()
            local maxScroll = math.max(0, (f.txContent:GetHeight() or 1) - self:GetHeight())
            local step = 24
            self:SetVerticalScroll(math.max(0, math.min(current - (delta * step), maxScroll)))
        end)

        -- Transaction rows (name left, action middle, gold right) with alternating backgrounds
        f.txRows = {}
        for i = 1, 200 do
            local row = CreateFrame("Frame", nil, f.txContent)
            row:SetSize(390, 18)
            row:SetPoint("TOPLEFT", 0, -((i - 1) * 18))

            -- Alternating row background
            row.bg = row:CreateTexture(nil, "BACKGROUND")
            row.bg:SetAllPoints()
            if i % 2 == 0 then
                row.bg:SetColorTexture(1, 1, 1, 0.05)
            else
                row.bg:SetColorTexture(0, 0, 0, 0.1)
            end

            row.time = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            local font, size = row.time:GetFont()
            row.time:SetFont(font, size, "THINOUTLINE")
            row.time:SetPoint("LEFT", 0, 0)
            row.time:SetWidth(70)
            row.time:SetJustifyH("LEFT")

            row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.name:SetPoint("LEFT", 75, 0)
            row.name:SetWidth(100)
            row.name:SetJustifyH("LEFT")

            row.action = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.action:SetPoint("CENTER", 30, 0)
            row.action:SetWidth(80)
            row.action:SetJustifyH("CENTER")

            row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.gold:SetPoint("RIGHT", 0, 0)

            f.txRows[i] = row
        end

        lv.WarbandLedgerWindow = f
    end

    lv.RefreshWarbandLedger()
    lv.WarbandLedgerWindow:Show()
end

function lv.RefreshWarbandLedger()
    local f = lv.WarbandLedgerWindow
    if not f then return end

    -- Update current balance
    local wbGold = (LiteVaultDB["Warband Bank"] and LiteVaultDB["Warband Bank"].gold) or 0
    f.balanceValue:SetText(FormatGoldAligned(wbGold, 14))

    -- Clear all rows first
    for i = 1, #f.txRows do
        f.txRows[i].time:SetText("")
        f.txRows[i].name:SetText("")
        f.txRows[i].action:SetText("")
        f.txRows[i].gold:SetText("")
        f.txRows[i]:Hide()
    end

    -- Show transaction history
    local wbData = LiteVaultDB["Warband Bank"]
    if wbData and wbData.transactions and #wbData.transactions > 0 then
        local maxRows = math.min(#f.txRows, #wbData.transactions)
        for i = 1, maxRows do
            local tx = wbData.transactions[i]
            if tx and tx.char then
                local charName = tx.char:match("^([^-]+)") or tx.char
                local charData = LiteVaultDB[tx.char]
                local classColor = (charData and C_ClassColor.GetClassColor(charData.class)) or C_ClassColor.GetClassColor("WARRIOR")

                local action = tx.amount > 0 and "|cff00ff00" .. L["ACTION_DEPOSITED"] .. "|r" or "|cffff0000" .. L["ACTION_WITHDREW"] .. "|r"
                local timeStr = date("%m/%d %H:%M", tx.timestamp)

                f.txRows[i].time:SetText("|cff999999" .. timeStr .. "|r")
                f.txRows[i].name:SetText("|c" .. classColor:GenerateHexColor() .. charName .. "|r")
                f.txRows[i].action:SetText(action)
                f.txRows[i].gold:SetText(FormatGoldAligned(math.abs(tx.amount), 12))
                f.txRows[i]:Show()
            end
        end
        f.txContent:SetHeight(math.max(1, maxRows * 18))
        f.txScroll:SetVerticalScroll(0)
    else
        f.txRows[1].name:SetText("|cffaaaaaa" .. L["MSG_NO_TRANSACTIONS"] .. "|r")
        f.txRows[1]:Show()
        f.txContent:SetHeight(18)
        f.txScroll:SetVerticalScroll(0)
    end
end

-- =============================================================================
-- LOCALIZED UI REFRESH FUNCTION
-- =============================================================================
-- This function refreshes all UI text when the language changes
-- MUST be defined at end of file after all UI elements are created
function lv.RefreshLocalizedUI()
    -- Refresh local L reference to get updated locale table
    local L = lv.L

    -- Main window buttons
    closeBtn.Text:SetText(L["BUTTON_CLOSE"])
    if lv.dashboardTab and lv.dashboardTab.Text then
        lv.dashboardTab.Text:SetText(L["BUTTON_DASHBOARD"])
    end
    if lv.profitTab and lv.profitTab.Text then
        lv.profitTab.Text:SetText(UIText("BUTTON_PROFIT"))
    end
    if lv.achievementsBtn and lv.achievementsBtn.Text then
        lv.achievementsBtn.Text:SetText(L["BUTTON_ACHIEVEMENTS"])
    end
    if lv.instancesTab and lv.instancesTab.Text then
        local instanceText = L["BUTTON_INSTANCES"]
        lv.instancesTab.Text:SetText(instanceText)
    end
    if lv.optionsTab and lv.optionsTab.Text then
        lv.optionsTab.Text:SetText(L["BUTTON_OPTIONS"])
    end
    if lv.factionsTab and lv.factionsTab.Text then
        lv.factionsTab.Text:SetText(L["BUTTON_FACTIONS"])
    end
    UpdateTopTabLayout()
    if lv.instancesBtn and lv.instancesBtn.Text then
        local instanceText = L["BUTTON_INSTANCES"]
        lv.instancesBtn.Text:SetText(instanceText)
    end
    raidLockoutsBtn.Text:SetText(L["BUTTON_RAID_LOCKOUTS"])

    if lv.optionsPanelTitle then
        lv.optionsPanelTitle:SetText(L["TITLE_OPTIONS"])
    end
    if lv.optionsClose then
        lv.optionsClose.Text:SetText(L["BUTTON_CLOSE"])
    end
    if lv.disableTimePlayedCB then
        lv.disableTimePlayedCB.Text:SetText(L["OPTION_DISABLE_TIMEPLAYED"])
    end
    if lv.timePlayedDesc then
        lv.timePlayedDesc:SetText(L["OPTION_DISABLE_TIMEPLAYED_DESC"])
    end
    if lv.timeFormatCB then
        lv.timeFormatCB.Text:SetText(L["OPTION_ENABLE_24HR_CLOCK"])
    end
    if lv.timeFormatDesc then
        lv.timeFormatDesc:SetText(L["OPTION_ENABLE_24HR_CLOCK_DESC"])
    end
    if lv.disableBagViewCB then
        lv.disableBagViewCB.Text:SetText(L["OPTION_DISABLE_BAG_VIEWING"])
    end
    if lv.disableBagViewDesc then
        lv.disableBagViewDesc:SetText(L["OPTION_DISABLE_BAG_VIEWING_DESC"])
    end
    if lv.disableOverlayCB then
        lv.disableOverlayCB.Text:SetText(L["OPTION_DISABLE_CHARACTER_OVERLAY"])
    end
    if lv.disableOverlayDesc then
        lv.disableOverlayDesc:SetText(L["OPTION_DISABLE_CHARACTER_OVERLAY_DESC"])
    end
    if lv.disableTeleportsCB then
        lv.disableTeleportsCB.Text:SetText(L["OPTION_DISABLE_MPLUS_TELEPORTS"])
    end
    if lv.disableTeleportsDesc then
        lv.disableTeleportsDesc:SetText(L["OPTION_DISABLE_MPLUS_TELEPORTS_DESC"])
    end
    if lv.miniFolioEnabledCB then
        lv.miniFolioEnabledCB.Text:SetText(L["OPTION_ENABLE_MINI_OMNIUM_FOLIO"])
    end
    if lv.miniFolioEnabledDesc then
        lv.miniFolioEnabledDesc:SetText(L["OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC"])
    end
    if lv.disableRunestonePinsCB then
        lv.disableRunestonePinsCB.Text:SetText(L["OPTION_DISABLE_RUNESTONE_MAP_PINS"])
    end
    if lv.disableRunestonePinsDesc then
        lv.disableRunestonePinsDesc:SetText(L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"])
    end
    if lv.calendarProfitHighlightsCB then
        lv.calendarProfitHighlightsCB.Text:SetText(L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"])
    end
    if lv.calendarProfitHighlightsDesc then
        lv.calendarProfitHighlightsDesc:SetText(L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"])
    end
    if lv.RefreshBagPanelLocale then
        lv.RefreshBagPanelLocale()
    end

    -- Manage button (from List.lua)
    if lv.manageBtn then
        local managing = lv.isManaging and lv.isManaging() or false
        lv.manageBtn.Text:SetText(managing and L["BUTTON_BACK"] or L["BUTTON_MANAGE"])
    end

    -- Main title
    mainTitle:SetText(L["TITLE_LITEVAULT"])

    -- Filter frame
    fTitle:SetText(L["TITLE_MAP_FILTERS"])
    fClose.Text:SetText(L["BUTTON_CLOSE"])
    selectAll.Text:SetText(L["BUTTON_ALL"])
    unselectAll.Text:SetText(L["BUTTON_NONE"])

    -- Filter checkboxes
    local filterTextKeys = {"FILTER_TIMEWALKING", "FILTER_DARKMOON", "FILTER_DUNGEONS", "FILTER_PVP", "FILTER_BONUS"}
    local filterKeys = {"timewalking", "darkmoon", "dungeon", "pvp", "bonus"}
    for i, key in ipairs(filterKeys) do
        if lv.filterChecks[key] then
            lv.filterChecks[key].Text:SetText(L[filterTextKeys[i]])
        end
    end

    -- Sort buttons
    local sortTextKeys = {"SORT_GOLD", "SORT_ILVL", "SORT_MPLUS", "SORT_LAST_ACTIVE"}
    for i, btn in ipairs(sortButtons) do
        if btn.text and sortTextKeys[i] then
            btn.text:SetText(L[sortTextKeys[i]])
        end
    end
    sortLabel:SetText(L["LABEL_SORT_BY"])

    if lv.UpdateProfitLocalizationText then
        lv.UpdateProfitLocalizationText()
    end
    local activeDef = GetWeeklyTabDef(weeklyViewMode)
    local activeWarning = (activeDef and activeDef.warningKey and L[activeDef.warningKey]) or ""
    if weeklyViewMode == "events" then
        activeWarning = ""
    end
    weeklyUI.warning:SetText(activeWarning)
    if lv.UpdateFactionWeeklyWindow and FactionWeeklyWindow and FactionWeeklyWindow:IsShown() then
        lv.UpdateFactionWeeklyWindow()
    elseif RefreshFactionCards then
        RefreshFactionCards()
    end
    if LVWindow and LVWindow.wbBankLabel and LVWindow.wbBankValue then
        local totalGoldLabel = L["LABEL_TOTAL_GOLD"]:gsub("%%s", "")
        if LVWindow.totalLabel then
            LVWindow.totalLabel:SetText(totalGoldLabel)
        end
        local wbBankGold = (LiteVaultDB and LiteVaultDB["Warband Bank"] and LiteVaultDB["Warband Bank"].gold) or 0
        LVWindow.wbBankLabel:SetText(L["LABEL_WARBAND_BANK"])
        LVWindow.wbBankMoneyExact = wbBankGold
        LVWindow.wbBankValue:SetText(FormatDashboardMoney(wbBankGold, 14))
    end

    -- Resize frames for locale
    if lv.Layout then
        if LVWindow then
            LVWindow:SetSize(lv.Layout.mainFrameWidth, lv.Layout.mainFrameHeight)
        end
        if lv.WeeklyBox then
            lv.WeeklyBox:SetHeight(math.max(lv.Layout.weeklyBoxHeight or 120, 170))
        end
    end

    -- Language section in Options panel
    if lv.langSectionTitle then
        lv.langSectionTitle:SetText(L["TITLE_LANGUAGE_SELECT"])
    end
    if lv.UpdateOptionsPanelLayout then
        lv.UpdateOptionsPanelLayout()
    end

    -- Prompt buttons
    promptUI.yesBtn.Text:SetText(L["BUTTON_YES"])
    promptUI.noBtn.Text:SetText(L["BUTTON_NO"])

    -- Raid Lockouts window
    if lv.raidLockoutsCloseBtn and lv.raidLockoutsCloseBtn.Text then
        lv.raidLockoutsCloseBtn.Text:SetText(L["BUTTON_CLOSE"])
    end
    if lv.raidDiffButtons and lv.RAID_DIFFICULTIES then
        for _, diff in ipairs(lv.RAID_DIFFICULTIES) do
            local btn = lv.raidDiffButtons[diff.id]
            if btn and btn.text then
                btn.text:SetText(L[diff.nameKey])
            end
        end
    end

    -- Currency window
    if lv.currencyCloseBtn and lv.currencyCloseBtn.Text then
        lv.currencyCloseBtn.Text:SetText(L["BUTTON_CLOSE"])
    end

    -- Profession window
    if lv.professionCloseBtn and lv.professionCloseBtn.Text then
        lv.professionCloseBtn.Text:SetText(L["BUTTON_CLOSE"])
    end

    -- Calendar buttons
    if lv.calFilterBtn and lv.calFilterBtn.Text then
        lv.calFilterBtn.Text:SetText(L["BUTTON_FILTER"])
    end
    if lv.calPlannerBtn and lv.calPlannerBtn.Text then
        lv.calPlannerBtn.Text:SetText(L["BUTTON_WEEKLY_PLANNER"])
    end
    if lv.calWorldEventsBtn and lv.calWorldEventsBtn.Text then
        lv.calWorldEventsBtn.Text:SetText(L["BUTTON_WORLD_EVENTS"])
    end
    if lv.calWorldEventsTitle then
        lv.calWorldEventsTitle:SetText(L["BUTTON_WORLD_EVENTS"])
    end
    if lv.calWorldEventsCloseBtn and lv.calWorldEventsCloseBtn.Text then
        lv.calWorldEventsCloseBtn.Text:SetText(L["BUTTON_CLOSE"])
    end
    if lv.calPlannerCloseBtn and lv.calPlannerCloseBtn.Text then
        lv.calPlannerCloseBtn.Text:SetText(L["BUTTON_CLOSE"])
    end
    if lv.UpdateWeeklyPlannerFrame then
        lv.UpdateWeeklyPlannerFrame()
    end

    -- Warband Bank Ledger window
    if lv.WarbandLedgerWindow then
        if lv.WarbandLedgerWindow.title then
            lv.WarbandLedgerWindow.title:SetText(L["TITLE_WARBAND_LEDGER"])
        end
        if lv.WarbandLedgerWindow.closeBtn and lv.WarbandLedgerWindow.closeBtn.Text then
            lv.WarbandLedgerWindow.closeBtn.Text:SetText(L["BUTTON_CLOSE"])
        end
    end

    -- Refresh ledger buttons on character rows
    if lv.RefreshLedgerButtons then lv.RefreshLedgerButtons() end

    -- Refresh calendar (day names and month)
    if lv.RefreshCalendarLocale then lv.RefreshCalendarLocale() end

    -- Refresh standalone/optional surfaces that keep resolved strings after
    -- construction. Each module decides whether its frame is currently visible.
    if lv.RefreshGearPanelForCurrentChar then lv.RefreshGearPanelForCurrentChar() end
    if lv.UpdateVaultWindow and lv.LVVaultWindow and lv.LVVaultWindow:IsShown() then lv.UpdateVaultWindow() end
    if lv.RefreshCurrencyWindow then lv.RefreshCurrencyWindow() end
    if lv.RefreshFolioDisplays then lv.RefreshFolioDisplays() end
    if lv.RefreshMiniFolio then lv.RefreshMiniFolio() end
    if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
    if lv.UpdateTeleportPanel then lv.UpdateTeleportPanel() end
    if lv.RefreshOpenProfitWindow then lv.RefreshOpenProfitWindow() end
    if lv.RefreshWowTokenUI then lv.RefreshWowTokenUI() end
    if lv.UpdateRaidLockoutGrid then lv.UpdateRaidLockoutGrid() end
    if lv.RefreshAchievementsView then lv.RefreshAchievementsView() end

    -- Refresh the full UI
    if lv.UpdateUI then lv.UpdateUI() end
end

