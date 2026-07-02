-- Calendar.lua
local addonName, lv = ...
local L = lv.L

local function UIText(key, fallback)
    local v = L and L[key]
    if v and v ~= "" and v ~= key then
        return v
    end
    local enUS = lv.LocaleData and lv.LocaleData["enUS"]
    local baseValue = enUS and enUS[key]
    if baseValue and baseValue ~= "" then
        return baseValue
    end
    return fallback or key
end

-- Day names will be set after L is loaded
local DAY_NAMES = nil
local DAYS_IN_MONTH = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
local dayButtons = {}
local currentPlannerChar = nil

local function FormatTooltipMoney(copper)
    if GetCoinTextureString then
        return GetCoinTextureString(math.abs(copper))
    end

    local gold = math.floor(math.abs(copper) / 10000)
    local silver = math.floor((math.abs(copper) % 10000) / 100)
    local copperAmt = math.abs(copper) % 100
    return string.format("%dg %ds %dc", gold, silver, copperAmt)
end

local function GetCalendarMoneyStats(year, month)
    local dailyStats = lv.GetProfitDailyStats and lv.GetProfitDailyStats(year, month, {
        includeIgnored = false,
        region = lv.REGION,
    }) or nil
    if not dailyStats then
        return {}, nil, nil
    end

    return dailyStats.byDay or {}, dailyStats.bestDay, dailyStats.worstDay
end

local function CalendarProfitHighlightsEnabled()
    if LiteVaultDB and LiteVaultDB.disableCalendarProfitHighlights ~= nil then
        return not LiteVaultDB.disableCalendarProfitHighlights
    end
    return true
end

-- UTILITY: Safely extract a string from potentially tainted WoW calendar data
-- WoW's Calendar API can return "secret" strings that crash on string operations
-- This function returns nil if the value cannot be safely used
local function SafeString(value)
    if value == nil then return nil end
    if issecretvalue and issecretvalue(value) then return nil end
    local result = nil
    local ok = pcall(function()
        -- Only copy already-safe values; never coerce Blizzard secret strings.
        local copied = "" .. value
        result = string.gsub(copied, "^(.*)$", "%1")
    end)
    if not ok then return nil end
    -- Verify the string is actually usable
    local canUse = pcall(function() local _ = string.len(result) end)
    return canUse and result or nil
end

local function GetPlannerEntries(charKey)
    charKey = charKey or lv.PLAYER_KEY
    if not LiteVaultDB or not charKey or not LiteVaultDB[charKey] then
        return nil
    end

    local db = LiteVaultDB[charKey]
    db.weeklyPlanner = db.weeklyPlanner or {
        { text = "", checked = false },
        { text = "", checked = false },
        { text = "", checked = false },
        { text = "", checked = false },
        { text = "", checked = false },
        { text = "", checked = false },
    }
    return db.weeklyPlanner
end

local function GetTrackedPlannerCharacters()
    local chars = {}
    local seen = {}
    if not LiteVaultDB then
        return chars
    end

    local function CanUseChar(charKey, data)
        return type(data) == "table"
            and data.class
            and charKey ~= "Warband Bank"
            and not data.isIgnored
            and (not data.region or data.region == lv.REGION)
    end

    if LiteVaultOrder then
        for _, charKey in ipairs(LiteVaultOrder) do
            local data = LiteVaultDB[charKey]
            if CanUseChar(charKey, data) then
                chars[#chars + 1] = charKey
                seen[charKey] = true
            end
        end
    end

    for charKey, data in pairs(LiteVaultDB) do
        if not seen[charKey] and CanUseChar(charKey, data) then
            chars[#chars + 1] = charKey
        end
    end

    return chars
end

-- 1. INITIALIZATION
function lv.InitCalendar(parent)
    local WorldEventsFrame
    local PlannerFrame
    local CalFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    CalFrame:SetSize(360, 400)
    -- The dashboard no longer has the old profit panel on the right,
    -- so the calendar column sits better a bit lower against the character stack.
    CalFrame:SetPoint("TOPRIGHT", -28, -100)
    CalFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14 })
    lv.CalFrame = CalFrame

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(CalFrame, function(f, theme)
                f:SetBackdropColor(unpack(theme.backgroundTransparent))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            CalFrame:SetBackdropColor(unpack(t.backgroundTransparent))
            CalFrame:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    -- Header Box
    local headerBg = CreateFrame("Frame", nil, CalFrame, "BackdropTemplate")
    headerBg:SetSize(340, 36)
    headerBg:SetPoint("TOP", 0, -10)
    headerBg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8, insets = { left = 3, right = 3, top = 3, bottom = 3 } })

    -- Register header for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(headerBg, function(f, theme)
                f:SetBackdropColor(unpack(theme.buttonBgAlt))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            headerBg:SetBackdropColor(unpack(t.buttonBgAlt))
            headerBg:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    lv.calTitle = headerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    lv.calTitle:SetPoint("CENTER", 0, 0)

    -- Store reference for title color updates
    lv.calHeaderBg = headerBg

    -- Register title for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(lv.calTitle, function(f, theme)
                f:SetTextColor(unpack(theme.textAccent))
            end)
            local t = lv.GetTheme()
            lv.calTitle:SetTextColor(unpack(t.textAccent))
        end
    end)

    -- PREVIOUS MONTH BUTTON (White)
    local prevMonth = CreateFrame("Button", nil, headerBg)
    prevMonth:SetSize(32, 32)
    prevMonth:SetPoint("LEFT", 5, 0)
    prevMonth:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prevMonth:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    prevMonth:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    prevMonth:GetNormalTexture():SetVertexColor(1, 1, 1)
    prevMonth:GetPushedTexture():SetVertexColor(1, 1, 1)
    
    prevMonth:SetScript("OnClick", function()
        lv.VIEW_MONTH = lv.VIEW_MONTH - 1
        if lv.VIEW_MONTH < 1 then lv.VIEW_MONTH = 12; lv.VIEW_YEAR = lv.VIEW_YEAR - 1 end
        C_Calendar.SetAbsMonth(lv.VIEW_MONTH, lv.VIEW_YEAR)
        lv.UpdateCalendar()
        if lv.WorldEventsFrame and lv.WorldEventsFrame:IsShown() then
            lv.UpdateWorldEventsFrame()
        end
    end)

    -- NEXT MONTH BUTTON (White)
    local nextMonth = CreateFrame("Button", nil, headerBg)
    nextMonth:SetSize(32, 32)
    nextMonth:SetPoint("RIGHT", -5, 0)
    nextMonth:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextMonth:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    nextMonth:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    nextMonth:GetNormalTexture():SetVertexColor(1, 1, 1)
    nextMonth:GetPushedTexture():SetVertexColor(1, 1, 1)
    
    nextMonth:SetScript("OnClick", function()
        lv.VIEW_MONTH = lv.VIEW_MONTH + 1
        if lv.VIEW_MONTH > 12 then lv.VIEW_MONTH = 1; lv.VIEW_YEAR = lv.VIEW_YEAR + 1 end
        C_Calendar.SetAbsMonth(lv.VIEW_MONTH, lv.VIEW_YEAR)
        lv.UpdateCalendar()
        if lv.WorldEventsFrame and lv.WorldEventsFrame:IsShown() then
            lv.UpdateWorldEventsFrame()
        end
    end)

    -- Filter Button
    local filterBtn = CreateFrame("Button", nil, CalFrame, "BackdropTemplate")
    filterBtn:SetSize(80, 22)
    filterBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    filterBtn.Text = filterBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    filterBtn.Text:SetPoint("CENTER")
    filterBtn.Text:SetText(L["BUTTON_FILTER"])
    lv.calFilterBtn = filterBtn

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(filterBtn, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            filterBtn:SetBackdropColor(unpack(t.buttonBg))
            filterBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
            filterBtn.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    filterBtn:SetScript("OnClick", function()
        if lv.FilterFrame:IsShown() then
            lv.FilterFrame:Hide()
        else
            if lv.WorldEventsFrame and lv.WorldEventsFrame:IsShown() then
                lv.WorldEventsFrame:Hide()
            end
            if _G["LiteVaultWeeklyPlannerFrame"] and _G["LiteVaultWeeklyPlannerFrame"]:IsShown() then
                _G["LiteVaultWeeklyPlannerFrame"]:Hide()
            end
            for k, cb in pairs(lv.filterChecks) do cb:SetChecked(LiteVaultDB.filters[k]) end
            lv.FilterFrame:ClearAllPoints()
            lv.FilterFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 0)
            lv.FilterFrame:Show()
        end
    end)

    filterBtn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["TOOLTIP_FILTER_TITLE"], 1, 0.82, 0)
        GameTooltip:AddLine(L["TOOLTIP_FILTER_DESC"], 1, 1, 1)
        GameTooltip:Show()
    end)
    filterBtn:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBg))
        GameTooltip:Hide()
    end)

    -- Planner Button (next to filter)
    local plannerBtn = CreateFrame("Button", nil, CalFrame, "BackdropTemplate")
    plannerBtn:SetSize(80, 22)
    plannerBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    plannerBtn.Text = plannerBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    plannerBtn.Text:SetPoint("CENTER")
    plannerBtn.Text:SetText(UIText("BUTTON_WEEKLY_PLANNER"))
    lv.calPlannerBtn = plannerBtn

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(plannerBtn, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            plannerBtn:SetBackdropColor(unpack(t.buttonBg))
            plannerBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
            plannerBtn.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    -- World Events Button
    local worldEventsBtn = CreateFrame("Button", nil, CalFrame, "BackdropTemplate")
    worldEventsBtn:SetSize(100, 22)
    worldEventsBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    worldEventsBtn.Text = worldEventsBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    worldEventsBtn.Text:SetPoint("CENTER")
    worldEventsBtn.Text:SetText(L["BUTTON_WORLD_EVENTS"])
    lv.calWorldEventsBtn = worldEventsBtn

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(worldEventsBtn, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            worldEventsBtn:SetBackdropColor(unpack(t.buttonBg))
            worldEventsBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
            worldEventsBtn.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    worldEventsBtn:SetPoint("BOTTOM", CalFrame, "BOTTOM", 0, 10)
    plannerBtn:SetPoint("RIGHT", worldEventsBtn, "LEFT", -8, 0)
    filterBtn:SetPoint("LEFT", worldEventsBtn, "RIGHT", 8, 0)

    -- World Events Frame (popup tab)
    WorldEventsFrame = CreateFrame("Frame", "LiteVaultWorldEventsFrame", parent, "BackdropTemplate")
    WorldEventsFrame:SetSize(240, 320)
    WorldEventsFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 0)
    WorldEventsFrame:SetFrameStrata("DIALOG")
    WorldEventsFrame:SetToplevel(true)
    WorldEventsFrame:Hide()
    WorldEventsFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(WorldEventsFrame, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            WorldEventsFrame:SetBackdropColor(unpack(t.background))
            WorldEventsFrame:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    local weTitle = WorldEventsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    weTitle:SetPoint("TOPLEFT", 15, -12)
    weTitle:SetText(L["BUTTON_WORLD_EVENTS"])
    weTitle:SetTextColor(1, 0.82, 0)
    lv.calWorldEventsTitle = weTitle

    -- Close button
    local weClose = CreateFrame("Button", nil, WorldEventsFrame, "BackdropTemplate")
    weClose:SetSize(60, 22)
    weClose:SetPoint("TOPRIGHT", -5, -5)
    weClose:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    weClose.Text = weClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    weClose.Text:SetPoint("CENTER")
    weClose.Text:SetText(L["BUTTON_CLOSE"])
    lv.calWorldEventsCloseBtn = weClose

    -- Register for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(weClose, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            weClose:SetBackdropColor(unpack(t.buttonBgAlt))
            weClose:SetBackdropBorderColor(unpack(t.borderPrimary))
            weClose.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    weClose:SetScript("OnClick", function() WorldEventsFrame:Hide() end)
    weClose:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end)
    weClose:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end)

    -- Content area for events
    WorldEventsFrame.content = WorldEventsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    WorldEventsFrame.content:SetPoint("TOPLEFT", 15, -40)
    WorldEventsFrame.content:SetPoint("BOTTOMRIGHT", -15, 10)
    WorldEventsFrame.content:SetJustifyH("LEFT")
    WorldEventsFrame.content:SetJustifyV("TOP")
    WorldEventsFrame.content:SetSpacing(4)

    lv.WorldEventsFrame = WorldEventsFrame

    PlannerFrame = CreateFrame("Frame", "LiteVaultWeeklyPlannerFrame", parent, "BackdropTemplate")
    PlannerFrame:SetSize(282, 358)
    PlannerFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT", 5, 0)
    PlannerFrame:SetFrameStrata("DIALOG")
    PlannerFrame:SetToplevel(true)
    PlannerFrame:Hide()
    PlannerFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14, insets = { left = 4, right = 4, top = 4, bottom = 4 } })

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(PlannerFrame, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            PlannerFrame:SetBackdropColor(unpack(t.background))
            PlannerFrame:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    local plannerHeader = CreateFrame("Frame", nil, PlannerFrame, "BackdropTemplate")
    plannerHeader:SetSize(260, 34)
    plannerHeader:SetPoint("TOP", 0, -10)
    plannerHeader:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 } })

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(plannerHeader, function(f, theme)
                f:SetBackdropColor(unpack(theme.dataBoxBgAlt or theme.dataBoxBg))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            plannerHeader:SetBackdropColor(unpack(t.dataBoxBgAlt or t.dataBoxBg))
            plannerHeader:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    local plannerClose = CreateFrame("Button", nil, plannerHeader, "BackdropTemplate")
    plannerClose:SetSize(54, 22)
    plannerClose:SetPoint("RIGHT", -6, 0)
    plannerClose:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    plannerClose.Text = plannerClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    plannerClose.Text:SetPoint("CENTER")
    plannerClose.Text:SetText(L["BUTTON_CLOSE"])
    lv.calPlannerCloseBtn = plannerClose

    local plannerTitle = plannerHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    plannerTitle:SetPoint("LEFT", 12, 0)
    plannerTitle:SetPoint("RIGHT", plannerClose, "LEFT", -8, 0)
    plannerTitle:SetJustifyH("LEFT")
    plannerTitle:SetTextColor(1, 0.82, 0)
    lv.calPlannerTitle = plannerTitle

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(plannerClose, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            plannerClose:SetBackdropColor(unpack(t.buttonBgAlt))
            plannerClose:SetBackdropBorderColor(unpack(t.borderPrimary))
            plannerClose.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    plannerClose:SetScript("OnClick", function() PlannerFrame:Hide() end)
    plannerClose:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end)
    plannerClose:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end)

    local plannerNote = PlannerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    plannerNote:SetPoint("TOPLEFT", 16, -52)
    plannerNote:SetPoint("TOPRIGHT", -16, -52)
    plannerNote:SetJustifyH("LEFT")
    plannerNote:SetText("|cff999999" .. UIText("TOOLTIP_WEEKLY_PLANNER_DESC") .. "|r")

    local plannerCharBtn = CreateFrame("Button", nil, PlannerFrame, "BackdropTemplate")
    plannerCharBtn:SetSize(248, 24)
    plannerCharBtn:SetPoint("TOPLEFT", 16, -86)
    plannerCharBtn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    plannerCharBtn.Text = plannerCharBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    plannerCharBtn.Text:SetPoint("CENTER")
    lv.calPlannerCharBtn = plannerCharBtn

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(plannerCharBtn, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            end)
            local t = lv.GetTheme()
            plannerCharBtn:SetBackdropColor(unpack(t.buttonBg))
            plannerCharBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
            plannerCharBtn.Text:SetTextColor(unpack(t.textPrimary))
        end
    end)

    local plannerCharMenu = CreateFrame("Frame", nil, PlannerFrame, "BackdropTemplate")
    plannerCharMenu:SetSize(248, 4)
    plannerCharMenu:SetPoint("TOPLEFT", plannerCharBtn, "BOTTOMLEFT", 0, -4)
    plannerCharMenu:SetFrameStrata("FULLSCREEN_DIALOG")
    plannerCharMenu:SetToplevel(true)
    plannerCharMenu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    plannerCharMenu:Hide()
    PlannerFrame.charMenu = plannerCharMenu

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(plannerCharMenu, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            local t = lv.GetTheme()
            plannerCharMenu:SetBackdropColor(unpack(t.background))
            plannerCharMenu:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end)

    PlannerFrame.charButtons = {}
    for i = 1, 20 do
        local btn = CreateFrame("Button", nil, plannerCharMenu, "BackdropTemplate")
        btn:SetSize(236, 20)
        btn:SetPoint("TOPLEFT", 6, -6 - ((i - 1) * 22))
        btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
        btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.Text:SetPoint("CENTER")
        btn:Hide()
        PlannerFrame.charButtons[i] = btn

        C_Timer.After(0, function()
            if lv.RegisterThemedElement then
                lv.RegisterThemedElement(btn, function(b, theme)
                    b:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
                    b:SetBackdropBorderColor(unpack(theme.borderPrimary))
                    b.Text:SetTextColor(unpack(theme.textPrimary))
                end)
                local t = lv.GetTheme()
                btn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
                btn:SetBackdropBorderColor(unpack(t.borderPrimary))
                btn.Text:SetTextColor(unpack(t.textPrimary))
            end
        end)
    end

    PlannerFrame.rows = {}
    for i = 1, 6 do
        local row = CreateFrame("Frame", nil, PlannerFrame)
        row:SetSize(248, 34)
        row:SetPoint("TOPLEFT", 16, -122 - ((i - 1) * 38))

        row.check = CreateFrame("CheckButton", nil, row, "InterfaceOptionsCheckButtonTemplate")
        row.check:SetPoint("LEFT", 2, 0)

        row.bg = CreateFrame("Frame", nil, row, "BackdropTemplate")
        row.bg:SetPoint("LEFT", row.check, "RIGHT", 4, 0)
        row.bg:SetSize(216, 28)
        row.bg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 } })

        row.edit = CreateFrame("EditBox", nil, row.bg)
        row.edit:SetPoint("TOPLEFT", 6, -3)
        row.edit:SetPoint("BOTTOMRIGHT", -6, 3)
        row.edit:SetFontObject(ChatFontNormal)
        row.edit:SetAutoFocus(false)
        row.edit:SetTextInsets(0, 0, 0, 0)
        row.edit:SetJustifyH("LEFT")
        row.edit:SetMaxLetters(80)

        PlannerFrame.rows[i] = row

        C_Timer.After(0, function()
            if lv.RegisterThemedElement then
                lv.RegisterThemedElement(row.bg, function(f, theme)
                    f:SetBackdropColor(unpack(theme.dataBoxBgAlt or theme.dataBoxBg))
                    f:SetBackdropBorderColor(unpack(theme.borderPrimary))
                end)
                local t = lv.GetTheme()
                row.bg:SetBackdropColor(unpack(t.dataBoxBgAlt or t.dataBoxBg))
                row.bg:SetBackdropBorderColor(unpack(t.borderPrimary))
            end
        end)
    end

    function lv.UpdateWeeklyPlannerFrame()
        if not PlannerFrame then return end
        local trackedChars = GetTrackedPlannerCharacters()
        if not currentPlannerChar or not LiteVaultDB or not LiteVaultDB[currentPlannerChar] then
            currentPlannerChar = lv.PLAYER_KEY
        end
        if not LiteVaultDB[currentPlannerChar] and trackedChars[1] then
            currentPlannerChar = trackedChars[1]
        end

        local entries = GetPlannerEntries(currentPlannerChar)
        local nameOnly = (currentPlannerChar or lv.PLAYER_KEY or ""):match("^([^-]+)") or (UnitName("player") or "Unknown")
        plannerTitle:SetText(string.format(UIText("TITLE_CHARACTER_WEEKLY_PLANNER_FMT"), nameOnly, UIText("TITLE_WEEKLY_PLANNER")))
        plannerCharBtn.Text:SetText(nameOnly)

        local visibleCount = 0
        for i, charKey in ipairs(trackedChars) do
            local btn = PlannerFrame.charButtons[i]
            if btn then
                visibleCount = visibleCount + 1
                local shortName = charKey:match("^([^-]+)") or charKey
                btn.Text:SetText(shortName)
                btn.charKey = charKey
                btn:Show()
                btn:SetScript("OnClick", function(self)
                    currentPlannerChar = self.charKey
                    plannerCharMenu:Hide()
                    if lv.UpdateWeeklyPlannerFrame then
                        lv.UpdateWeeklyPlannerFrame()
                    end
                end)
            end
        end
        for i = visibleCount + 1, #PlannerFrame.charButtons do
            PlannerFrame.charButtons[i]:Hide()
            PlannerFrame.charButtons[i].charKey = nil
        end
        local shownRows = math.min(visibleCount, #PlannerFrame.charButtons)
        plannerCharMenu:SetHeight(math.max(30, 12 + (shownRows * 22)))

        if not entries then return end

        for i, row in ipairs(PlannerFrame.rows) do
            local entry = entries[i]
            if entry then
                row.check:SetChecked(entry.checked and true or false)
                row.edit:SetText(entry.text or "")
                row.check:SetScript("OnClick", function(self)
                    entry.checked = self:GetChecked() and true or false
                end)
                row.edit:SetScript("OnEnterPressed", function(self)
                    self:ClearFocus()
                end)
                row.edit:SetScript("OnEscapePressed", function(self)
                    self:ClearFocus()
                    self:SetText(entry.text or "")
                end)
                row.edit:SetScript("OnTextChanged", function(self, userInput)
                    if userInput then
                        entry.text = self:GetText() or ""
                    end
                end)
            end
        end
    end

    plannerCharBtn:SetScript("OnClick", function()
        if plannerCharMenu:IsShown() then
            plannerCharMenu:Hide()
        else
            if lv.UpdateWeeklyPlannerFrame then
                lv.UpdateWeeklyPlannerFrame()
            end
            plannerCharMenu:ClearAllPoints()
            plannerCharMenu:SetPoint("TOPLEFT", plannerCharBtn, "BOTTOMLEFT", 0, -4)
            plannerCharMenu:Show()
        end
    end)
    plannerCharBtn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
    end)
    plannerCharBtn:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBg))
    end)

    worldEventsBtn:SetScript("OnClick", function()
        if WorldEventsFrame:IsShown() then
            WorldEventsFrame:Hide()
        else
            if lv.FilterFrame and lv.FilterFrame:IsShown() then
                lv.FilterFrame:Hide()
            end
            if PlannerFrame:IsShown() then
                PlannerFrame:Hide()
            end
            plannerCharMenu:Hide()
            lv.UpdateWorldEventsFrame()
            WorldEventsFrame:Show()
        end
    end)

    worldEventsBtn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["TOOLTIP_WORLD_EVENTS_TITLE"], 1, 0.82, 0)
        GameTooltip:AddLine(L["TOOLTIP_WORLD_EVENTS_DESC"], 1, 1, 1)
        GameTooltip:Show()
    end)
    worldEventsBtn:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBg))
        GameTooltip:Hide()
    end)

    plannerBtn:SetScript("OnClick", function()
        if PlannerFrame:IsShown() then
            PlannerFrame:Hide()
            plannerCharMenu:Hide()
        else
            if lv.FilterFrame and lv.FilterFrame:IsShown() then
                lv.FilterFrame:Hide()
            end
            if WorldEventsFrame:IsShown() then
                WorldEventsFrame:Hide()
            end
            if lv.UpdateWeeklyPlannerFrame then
                lv.UpdateWeeklyPlannerFrame()
            end
            PlannerFrame:Show()
        end
    end)

    plannerBtn:SetScript("OnEnter", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderHover))
        self:SetBackdropColor(unpack(t.buttonBgHover))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(UIText("TOOLTIP_WEEKLY_PLANNER_TITLE"), 1, 0.82, 0)
        GameTooltip:AddLine(UIText("TOOLTIP_WEEKLY_PLANNER_DESC"), 1, 1, 1)
        GameTooltip:Show()
    end)
    plannerBtn:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBg))
        GameTooltip:Hide()
    end)

    -- Initialize localized day names
    DAY_NAMES = {L["DAY_SUN"], L["DAY_MON"], L["DAY_TUE"], L["DAY_WED"], L["DAY_THU"], L["DAY_FRI"], L["DAY_SAT"]}

    -- Store day headers for theming
    lv.dayHeaders = {}
    for i, name in ipairs(DAY_NAMES) do
        local h = CreateFrame("Frame", nil, CalFrame, "BackdropTemplate")
        h:SetSize(44, 20)
        h:SetPoint("TOPLEFT", 15 + ((i-1)*48), -55)
        h:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
        local t = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        t:SetPoint("CENTER"); t:SetText(name); t:SetTextColor(1, 1, 1)
        h.dayText = t  -- Store reference for refresh
        lv.dayHeaders[i] = h
    end

    -- Function to refresh day header text when locale changes
    function lv.RefreshCalendarLocale()
        DAY_NAMES = {L["DAY_SUN"], L["DAY_MON"], L["DAY_TUE"], L["DAY_WED"], L["DAY_THU"], L["DAY_FRI"], L["DAY_SAT"]}
        for i, h in ipairs(lv.dayHeaders) do
            if h.dayText then
                h.dayText:SetText(DAY_NAMES[i])
            end
        end
        -- Also refresh the calendar to update month name
        if lv.UpdateCalendar then lv.UpdateCalendar() end
    end

    -- Register day headers for theming
    C_Timer.After(0, function()
        if lv.RegisterThemedElement and lv.dayHeaders then
            for _, h in ipairs(lv.dayHeaders) do
                lv.RegisterThemedElement(h, function(f, theme)
                    f:SetBackdropColor(unpack(theme.calendarHeaderBg))
                end)
            end
            local t = lv.GetTheme()
            for _, h in ipairs(lv.dayHeaders) do
                h:SetBackdropColor(unpack(t.calendarHeaderBg))
            end
        end
    end)

end

-- 2. UPDATE LOGIC
function lv.UpdateCalendar()
    if not lv.calTitle or not lv.CalFrame then return end
    local today = date("*t")
    if not lv.VIEW_MONTH then lv.VIEW_MONTH, lv.VIEW_YEAR = today.month, today.year end

    local firstTime = time({year=lv.VIEW_YEAR, month=lv.VIEW_MONTH, day=1})
    local firstDay = date("*t", firstTime)
    -- Use localized month name
    local monthName = L["MONTH_" .. lv.VIEW_MONTH] or date("%B", firstTime)
    lv.calTitle:SetText(monthName .. " " .. lv.VIEW_YEAR)
    
    if (lv.VIEW_YEAR % 4 == 0 and (lv.VIEW_YEAR % 100 ~= 0 or lv.VIEW_YEAR % 400 == 0)) then DAYS_IN_MONTH[2] = 29 else DAYS_IN_MONTH[2] = 28 end
    local startOffset = firstDay.wday - 1
    local moneyStatsByDay, bestMoneyDay, worstMoneyDay = GetCalendarMoneyStats(lv.VIEW_YEAR, lv.VIEW_MONTH)
    
    for i=1, 42 do
        if not dayButtons[i] then
            dayButtons[i] = CreateFrame("Button", nil, lv.CalFrame, "BackdropTemplate")
            dayButtons[i]:SetSize(44, 44)
            dayButtons[i]:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 } })
            dayButtons[i].text = dayButtons[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            dayButtons[i].text:SetPoint("TOPLEFT", 5, -5)
            dayButtons[i].bars = {}
            for j=1, 5 do 
                local t = dayButtons[i]:CreateTexture(nil, "ARTWORK")
                t:SetHeight(4); t:SetTexture("Interface\\Buttons\\WHITE8X8")
                dayButtons[i].bars[j] = t 
            end
            dayButtons[i]:SetScript("OnEnter", function(self)
                if self.dayNum then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(string.format(L["TOOLTIP_ACTIVITY_FOR"], lv.VIEW_MONTH, self.dayNum, lv.VIEW_YEAR), 1, 1, 1)
                    if self.moneyStats then
                        GameTooltip:AddLine(" ")
                        local netColor = self.moneyStats.net >= 0 and "|cff55ff55" or "|cffff6666"
                        local netSign = self.moneyStats.net >= 0 and "+" or "-"
                        GameTooltip:AddLine(string.format("%s: %s%s|r", UIText("LABEL_NET"), netColor, netSign .. FormatTooltipMoney(self.moneyStats.net)))
                        if self.moneyStats.income > 0 then
                            GameTooltip:AddLine(string.format("%s: |cff55ff55+%s|r", UIText("LABEL_GAINED"), FormatTooltipMoney(self.moneyStats.income)))
                        end
                        if self.moneyStats.expense > 0 then
                            GameTooltip:AddLine(string.format("%s: |cffff6666-%s|r", UIText("LABEL_SPENT"), FormatTooltipMoney(self.moneyStats.expense)))
                        end
                    end
                    if self.eventList then
                        GameTooltip:AddLine(" ")
                        for _, evt in ipairs(self.eventList) do GameTooltip:AddLine(evt.title, 0.4, 0.6, 1) end
                    end
                    GameTooltip:Show() 
                end 
            end)
            dayButtons[i]:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        
        local btn, dayNum = dayButtons[i], i - startOffset
        local t = lv.GetTheme()
        btn:SetBackdropColor(unpack(t.calendarDayBg))
        btn:SetBackdropBorderColor(unpack(t.calendarDayBorder))
        btn.text:SetTextColor(unpack(t.textPrimary))
        btn.dayNum = nil
        btn.eventList = nil
        btn.moneyStats = nil
        for _, bar in ipairs(btn.bars) do bar:Hide() end

        if dayNum > 0 and dayNum <= DAYS_IN_MONTH[lv.VIEW_MONTH] then
            btn:Show()
            btn.text:SetText(dayNum)
            btn.dayNum = dayNum
            if dayNum == today.day and lv.VIEW_MONTH == today.month and lv.VIEW_YEAR == today.year then
                btn:SetBackdropBorderColor(unpack(t.calendarTodayBorder))
                btn:SetBackdropColor(unpack(t.calendarTodayBg))
            end

            local moneyStats = moneyStatsByDay[dayNum]
            if CalendarProfitHighlightsEnabled() and moneyStats and moneyStats.net ~= 0 then
                btn.moneyStats = moneyStats
                if moneyStats.net > 0 then
                    btn.text:SetTextColor(0.65, 1, 0.65)
                    if not (dayNum == today.day and lv.VIEW_MONTH == today.month and lv.VIEW_YEAR == today.year) then
                        btn:SetBackdropBorderColor(0.18, 0.72, 0.28, 1)
                    end
                    if dayNum == bestMoneyDay then
                        btn:SetBackdropColor(0.08, 0.16, 0.08, 0.95)
                    else
                        btn:SetBackdropColor(0.05, 0.13, 0.07, 0.95)
                    end
                else
                    btn.text:SetTextColor(1, 0.65, 0.65)
                    if not (dayNum == today.day and lv.VIEW_MONTH == today.month and lv.VIEW_YEAR == today.year) then
                        btn:SetBackdropBorderColor(0.78, 0.28, 0.28, 1)
                    end
                    if dayNum == worstMoneyDay then
                        btn:SetBackdropColor(0.16, 0.06, 0.06, 0.95)
                    else
                        btn:SetBackdropColor(0.13, 0.05, 0.05, 0.95)
                    end
                end
            end
            
            -- CHECK 1: Character Login Activity
            local checkDate = string.format("%d-%d-%d", lv.VIEW_YEAR, lv.VIEW_MONTH, dayNum)
            if LiteVaultDB then
                for name, data in pairs(LiteVaultDB) do
                    if type(data) == "table" and data.lastActive == checkDate
                        and (not data.region or data.region == lv.REGION) then
                        btn.eventList = btn.eventList or {}
                        local cc = C_ClassColor.GetClassColor(data.class or "WARRIOR")
                        table.insert(btn.eventList, { title = "|c" .. cc:GenerateHexColor() .. name:match("^([^-]+)") .. "|r Logged In" })
                    end
                end
            end

            -- CHECK 2: System Events
            local filters = (LiteVaultDB and LiteVaultDB.filters) or {}
            local numEvents = C_Calendar.GetNumDayEvents(0, dayNum)
            local activeBars = {}
            
            if numEvents > 0 then
                local foundTypes = {}
                for e = 1, numEvents do
                    local event = C_Calendar.GetDayEvent(0, dayNum, e)
                    if not event then break end

                    local title = SafeString(event.title)

                    -- Only process if we got a valid title string
                    if title then
                        -- Pre-check: does title contain any timewalking/pvp/dungeon keyword?
                        local titleHasTimewalking = false
                        local titleHasPvP = false
                        local titleHasDungeon = false
                        for checkKw, checkCfg in pairs(lv.EVENT_CONFIG) do
                            if string.find(title, checkKw) then
                                if checkCfg.key == "timewalking" then titleHasTimewalking = true end
                                if checkCfg.key == "pvp" then titleHasPvP = true end
                                if checkCfg.key == "dungeon" then titleHasDungeon = true end
                            end
                        end

                        for kw, cfg in pairs(lv.EVENT_CONFIG) do
                            if string.find(title, kw) then
                                -- Use cfg.key to determine event type (works across all locales)
                                local show = (cfg.key == "timewalking" and filters.timewalking) or
                                             (cfg.key == "darkmoon" and filters.darkmoon) or
                                             (cfg.key == "dungeon" and filters.dungeon and not titleHasTimewalking) or
                                             (cfg.key == "pvp" and filters.pvp) or
                                             (cfg.key == "bonus" and filters.bonus and not titleHasPvP and not titleHasDungeon)

                                if show then
                                    if not foundTypes[cfg.order] then table.insert(activeBars, cfg); foundTypes[cfg.order] = true end
                                    btn.eventList = btn.eventList or {}

                                    local rangeStr = ""
                                    local timeOk = pcall(function()
                                        if event.startTime and event.endTime then
                                            local sM, sD = event.startTime.month, event.startTime.monthDay
                                            local eM, eD = event.endTime.month, event.endTime.monthDay
                                            if sM == eM and sD == eD then
                                                rangeStr = string.format(" |cffaaaaaa(%d/%d)|r", sM, sD)
                                            else
                                                rangeStr = string.format(" |cffaaaaaa(%d/%d - %d/%d)|r", sM, sD, eM, eD)
                                            end
                                        end
                                    end)

                                    table.insert(btn.eventList, { title = title .. rangeStr })
                                    break -- FIX: Stop looking for other keywords once a match is found to prevent duplicates
                                end
                            end
                        end
                    end
                end
                table.sort(activeBars, function(a,b) return a.order < b.order end)
                for k, cfg in ipairs(activeBars) do 
                    if k <= 5 then 
                        local b = btn.bars[k]
                        b:SetVertexColor(cfg.r, cfg.g, cfg.b)
                        b:ClearAllPoints()
                        b:SetPoint("BOTTOMLEFT", 2, 2 + ((k-1)*5))
                        b:SetPoint("BOTTOMRIGHT", -2, 2 + ((k-1)*5))
                        b:Show() 
                    end 
                end
            end
            btn:SetPoint("TOPLEFT", 15 + ((i-1)%7)*48, -80 - math.floor((i-1)/7)*46)
        else
            btn:Hide()
        end
    end
end

-- 3. WORLD EVENTS FRAME UPDATE
-- Translation mapping for world events (English key -> localized display)
local WORLD_EVENT_TRANSLATIONS = {
    ["Love is in the Air"] = "WORLD_EVENT_LOVE",
    ["Lunar Festival"] = "WORLD_EVENT_LUNAR",
    ["Noblegarden"] = "WORLD_EVENT_NOBLEGARDEN",
    ["Children's Week"] = "WORLD_EVENT_CHILDREN",
    ["Midsummer Fire Festival"] = "WORLD_EVENT_MIDSUMMER",
    ["Brewfest"] = "WORLD_EVENT_BREWFEST",
    ["Hallow's End"] = "WORLD_EVENT_HALLOWS",
    ["Feast of Winter Veil"] = "WORLD_EVENT_WINTERVEIL",
    ["Day of the Dead"] = "WORLD_EVENT_DEAD",
    ["Pirates' Day"] = "WORLD_EVENT_PIRATES",
    ["Trial of Style"] = "WORLD_EVENT_STYLE",
    ["Outland Cup"] = "WORLD_EVENT_OUTLAND",
    ["Northrend Cup"] = "WORLD_EVENT_NORTHREND",
    ["Kalimdor Cup"] = "WORLD_EVENT_KALIMDOR",
    ["Eastern Kingdoms Cup"] = "WORLD_EVENT_EASTERN",
    ["Winds of Mysterious Fortune"] = "WORLD_EVENT_WINDS",
    -- zhTW reverse mappings
    ["æ„›å°±åœ¨èº«é‚Š"] = "WORLD_EVENT_LOVE",
    ["æ–°å¹´æ…¶å…¸"] = "WORLD_EVENT_LUNAR",
    ["è²´æ—èŠ±åœ’"] = "WORLD_EVENT_NOBLEGARDEN",
    ["å…’ç«¥é€±"] = "WORLD_EVENT_CHILDREN",
    ["ä»²å¤ç«ç„°ç¯€æ…¶"] = "WORLD_EVENT_MIDSUMMER",
    ["å•¤é…’ç¯€"] = "WORLD_EVENT_BREWFEST",
    ["è¬é¬¼ç¯€"] = "WORLD_EVENT_HALLOWS",
    ["å†¬å¹•ç¯€"] = "WORLD_EVENT_WINTERVEIL",
    ["äº¡è€…ç¯€"] = "WORLD_EVENT_DEAD",
    ["æµ·ç›œç¯€"] = "WORLD_EVENT_PIRATES",
    ["æ™‚å°šå¤§è€ƒé©—"] = "WORLD_EVENT_STYLE",
    ["å¤–åŸŸæ¯"] = "WORLD_EVENT_OUTLAND",
    ["åŒ—è£‚å¢ƒæ¯"] = "WORLD_EVENT_NORTHREND",
    ["å¡æž—å¤šæ¯"] = "WORLD_EVENT_KALIMDOR",
    ["æ±éƒ¨çŽ‹åœ‹æ¯"] = "WORLD_EVENT_EASTERN",
    ["ç¥žç§˜å‘½é‹ä¹‹é¢¨"] = "WORLD_EVENT_WINDS",
    -- zhCN reverse mappings
    ["æƒ…äººèŠ‚"] = "WORLD_EVENT_LOVE",
    ["æ˜¥èŠ‚"] = "WORLD_EVENT_LUNAR",
    ["å¤æ´»èŠ‚"] = "WORLD_EVENT_NOBLEGARDEN",
    ["å„¿ç«¥å‘¨"] = "WORLD_EVENT_CHILDREN",
    ["ä»²å¤ç«ç„°èŠ‚"] = "WORLD_EVENT_MIDSUMMER",
    ["ç¾Žé…’èŠ‚"] = "WORLD_EVENT_BREWFEST",
    ["ä¸‡åœ£èŠ‚"] = "WORLD_EVENT_HALLOWS",
    ["å†¬å¹•èŠ‚"] = "WORLD_EVENT_WINTERVEIL",
    ["äº¡çµèŠ‚"] = "WORLD_EVENT_DEAD",
    ["æµ·ç›—æ—¥"] = "WORLD_EVENT_PIRATES",
    ["è¯•è¡£å¤§ä¼š"] = "WORLD_EVENT_STYLE",
    ["å¤–åŸŸæ¯"] = "WORLD_EVENT_OUTLAND",
    ["è¯ºæ£®å¾·æ¯"] = "WORLD_EVENT_NORTHREND",
    ["å¡åˆ©å§†å¤šæ¯"] = "WORLD_EVENT_KALIMDOR",
    ["ä¸œéƒ¨çŽ‹å›½æ¯"] = "WORLD_EVENT_EASTERN",
    ["ç¥žç§˜å‘½è¿ä¹‹é£Ž"] = "WORLD_EVENT_WINDS",
    -- koKR reverse mappings
    ["ì˜¨ ì„¸ìƒì— ì‚¬ëž‘ì„"] = "WORLD_EVENT_LOVE",
    ["ë‹¬ì˜ ì¶•ì œ"] = "WORLD_EVENT_LUNAR",
    ["ê·€ì¡±ì˜ ì •ì›"] = "WORLD_EVENT_NOBLEGARDEN",
    ["ì–´ë¦°ì´ ì£¼ê°„"] = "WORLD_EVENT_CHILDREN",
    ["í•œì—¬ë¦„ ë¶ˆê½ƒì¶•ì œ"] = "WORLD_EVENT_MIDSUMMER",
    ["ê°€ì„ ì¶•ì œ"] = "WORLD_EVENT_BREWFEST",
    ["í• ë¡œìœˆ ì¶•ì œ"] = "WORLD_EVENT_HALLOWS",
    ["ê²¨ìš¸ë§žì´ ì¶•ì œ"] = "WORLD_EVENT_WINTERVEIL",
    ["ë§ìžì˜ ë‚ "] = "WORLD_EVENT_DEAD",
    ["í•´ì ì˜ ë‚ "] = "WORLD_EVENT_PIRATES",
    ["ìŠ¤íƒ€ì¼ì˜ ì‹œí—˜"] = "WORLD_EVENT_STYLE",
    ["ì•„ì›ƒëžœë“œ ì»µ"] = "WORLD_EVENT_OUTLAND",
    ["ë…¸ìŠ¤ë Œë“œ ì»µ"] = "WORLD_EVENT_NORTHREND",
    ["ì¹¼ë¦¼ë„ì–´ ì»µ"] = "WORLD_EVENT_KALIMDOR",
    ["ë™ë¶€ ì™•êµ­ ì»µ"] = "WORLD_EVENT_EASTERN",
    ["ì‹ ë¹„ë¡œìš´ í–‰ìš´ì˜ ë°”ëžŒ"] = "WORLD_EVENT_WINDS",
    -- deDE reverse mappings
    ["Liebe liegt in der Luft"] = "WORLD_EVENT_LOVE",
    ["Mondfest"] = "WORLD_EVENT_LUNAR",
    ["Nobelgarten"] = "WORLD_EVENT_NOBLEGARDEN",
    ["Kinderwoche"] = "WORLD_EVENT_CHILDREN",
    ["Sonnenwendfest"] = "WORLD_EVENT_MIDSUMMER",
    ["Braufest"] = "WORLD_EVENT_BREWFEST",
    ["SchlotternÃ¤chte"] = "WORLD_EVENT_HALLOWS",
    ["Winterhauch"] = "WORLD_EVENT_WINTERVEIL",
    ["Tag der Toten"] = "WORLD_EVENT_DEAD",
    ["Piratentag"] = "WORLD_EVENT_PIRATES",
    ["Probe des Stils"] = "WORLD_EVENT_STYLE",
    ["Scherbenwelt-Cup"] = "WORLD_EVENT_OUTLAND",
    ["Nordend-Cup"] = "WORLD_EVENT_NORTHREND",
    ["Kalimdor-Cup"] = "WORLD_EVENT_KALIMDOR",
    ["Ã–stliche KÃ¶nigreiche-Cup"] = "WORLD_EVENT_EASTERN",
    ["Winde des geheimnisvollen GlÃ¼cks"] = "WORLD_EVENT_WINDS",
    -- frFR reverse mappings
    ["De l'amour dans l'air"] = "WORLD_EVENT_LOVE",
    ["FÃªte lunaire"] = "WORLD_EVENT_LUNAR",
    ["Le Jardin des nobles"] = "WORLD_EVENT_NOBLEGARDEN",
    ["Semaine des enfants"] = "WORLD_EVENT_CHILDREN",
    ["FÃªte du Feu du solstice d'Ã©tÃ©"] = "WORLD_EVENT_MIDSUMMER",
    ["FÃªte des Brasseurs"] = "WORLD_EVENT_BREWFEST",
    ["Sanssaint"] = "WORLD_EVENT_HALLOWS",
    ["Voile d'hiver"] = "WORLD_EVENT_WINTERVEIL",
    ["Jour des morts"] = "WORLD_EVENT_DEAD",
    ["Jour des pirates"] = "WORLD_EVENT_PIRATES",
    ["Ã‰preuve de style"] = "WORLD_EVENT_STYLE",
    ["Coupe de l'Outreterre"] = "WORLD_EVENT_OUTLAND",
    ["Coupe de Norfendre"] = "WORLD_EVENT_NORTHREND",
    ["Coupe de Kalimdor"] = "WORLD_EVENT_KALIMDOR",
    ["Coupe des Royaumes de l'Est"] = "WORLD_EVENT_EASTERN",
    ["Vents de fortune mystÃ©rieuse"] = "WORLD_EVENT_WINDS",
    -- esES reverse mappings
    ["El amor estÃ¡ en el aire"] = "WORLD_EVENT_LOVE",
    ["Festival Lunar"] = "WORLD_EVENT_LUNAR",
    ["JardÃ­n Noble"] = "WORLD_EVENT_NOBLEGARDEN",
    ["Semana de los NiÃ±os"] = "WORLD_EVENT_CHILDREN",
    ["Festival de Fuego del Solsticio de Verano"] = "WORLD_EVENT_MIDSUMMER",
    ["Fiesta de la Cerveza"] = "WORLD_EVENT_BREWFEST",
    ["Halloween"] = "WORLD_EVENT_HALLOWS",
    ["Festival de Invierno"] = "WORLD_EVENT_WINTERVEIL",
    ["DÃ­a de los Muertos"] = "WORLD_EVENT_DEAD",
    ["DÃ­a de los Piratas"] = "WORLD_EVENT_PIRATES",
    ["Prueba de Estilo"] = "WORLD_EVENT_STYLE",
    ["Copa de Terrallende"] = "WORLD_EVENT_OUTLAND",
    ["Copa de Rasganorte"] = "WORLD_EVENT_NORTHREND",
    ["Copa de Kalimdor"] = "WORLD_EVENT_KALIMDOR",
    ["Copa de los Reinos del Este"] = "WORLD_EVENT_EASTERN",
    ["Vientos de fortuna misteriosa"] = "WORLD_EVENT_WINDS",
    -- ptBR reverse mappings
    ["O Amor EstÃ¡ no Ar"] = "WORLD_EVENT_LOVE",
    ["Festival da Lua"] = "WORLD_EVENT_LUNAR",
    ["Jardinova"] = "WORLD_EVENT_NOBLEGARDEN",
    ["Semana das CrianÃ§as"] = "WORLD_EVENT_CHILDREN",
    ["Festival do Fogo do SolstÃ­cio"] = "WORLD_EVENT_MIDSUMMER",
    ["CervaFest"] = "WORLD_EVENT_BREWFEST",
    ["NoturnÃ¡lia"] = "WORLD_EVENT_HALLOWS",
    ["Festa do VÃ©u de Inverno"] = "WORLD_EVENT_WINTERVEIL",
    ["Dia dos Mortos"] = "WORLD_EVENT_DEAD",
    ["Dia dos Piratas"] = "WORLD_EVENT_PIRATES",
    ["Prova de Estilo"] = "WORLD_EVENT_STYLE",
    ["Copa de TerralÃ©m"] = "WORLD_EVENT_OUTLAND",
    ["Copa de NortÃºndria"] = "WORLD_EVENT_NORTHREND",
    ["Copa de Kalimdor"] = "WORLD_EVENT_KALIMDOR",
    ["Copa dos Reinos do Leste"] = "WORLD_EVENT_EASTERN",
    ["Ventos da Fortuna Misteriosa"] = "WORLD_EVENT_WINDS",
    -- ruRU reverse mappings
    ["Ð›ÑŽÐ±Ð¾Ð²ÑŒ Ð²Ð¸Ñ‚Ð°ÐµÑ‚ Ð² Ð²Ð¾Ð·Ð´ÑƒÑ…Ðµ"] = "WORLD_EVENT_LOVE",
    ["Ð›ÑƒÐ½Ð½Ñ‹Ð¹ Ñ„ÐµÑÑ‚Ð¸Ð²Ð°Ð»ÑŒ"] = "WORLD_EVENT_LUNAR",
    ["Ð¡Ð°Ð´ Ñ‡ÑƒÐ´ÐµÑ"] = "WORLD_EVENT_NOBLEGARDEN",
    ["Ð”ÐµÑ‚ÑÐºÐ°Ñ Ð½ÐµÐ´ÐµÐ»Ñ"] = "WORLD_EVENT_CHILDREN",
    ["ÐžÐ³Ð½ÐµÐ½Ð½Ñ‹Ð¹ ÑÐ¾Ð»Ð½Ñ†ÐµÐ²Ð¾Ñ€Ð¾Ñ‚"] = "WORLD_EVENT_MIDSUMMER",
    ["Ð¥Ð¼ÐµÐ»ÑŒÐ½Ð¾Ð¹ Ñ„ÐµÑÑ‚Ð¸Ð²Ð°Ð»ÑŒ"] = "WORLD_EVENT_BREWFEST",
    ["Ð¢Ñ‹ÐºÐ²Ð¾Ð²Ð¸Ð½"] = "WORLD_EVENT_HALLOWS",
    ["Ð—Ð¸Ð¼Ð½Ð¸Ð¹ ÐŸÐ¾ÐºÑ€Ð¾Ð²"] = "WORLD_EVENT_WINTERVEIL",
    ["Ð”ÐµÐ½ÑŒ Ð¼Ñ‘Ñ€Ñ‚Ð²Ñ‹Ñ…"] = "WORLD_EVENT_DEAD",
    ["Ð”ÐµÐ½ÑŒ Ð¿Ð¸Ñ€Ð°Ñ‚Ð°"] = "WORLD_EVENT_PIRATES",
    ["Ð˜ÑÐ¿Ñ‹Ñ‚Ð°Ð½Ð¸Ðµ ÑÑ‚Ð¸Ð»ÐµÐ¼"] = "WORLD_EVENT_STYLE",
    ["ÐšÑƒÐ±Ð¾Ðº Ð—Ð°Ð¿Ñ€ÐµÐ´ÐµÐ»ÑŒÑ"] = "WORLD_EVENT_OUTLAND",
    ["ÐšÑƒÐ±Ð¾Ðº ÐÐ¾Ñ€Ð´ÑÐºÐ¾Ð»Ð°"] = "WORLD_EVENT_NORTHREND",
    ["ÐšÑƒÐ±Ð¾Ðº ÐšÐ°Ð»Ð¸Ð¼Ð´Ð¾Ñ€Ð°"] = "WORLD_EVENT_KALIMDOR",
    ["ÐšÑƒÐ±Ð¾Ðº Ð’Ð¾ÑÑ‚Ð¾Ñ‡Ð½Ñ‹Ñ… ÐºÐ¾Ñ€Ð¾Ð»ÐµÐ²ÑÑ‚Ð²"] = "WORLD_EVENT_EASTERN",
    ["Ð’ÐµÑ‚Ñ€Ð° Ñ‚Ð°Ð¸Ð½ÑÑ‚Ð²ÐµÐ½Ð½Ð¾Ð¹ ÑƒÐ´Ð°Ñ‡Ð¸"] = "WORLD_EVENT_WINDS",
}

-- Helper function to get localized event name
local function GetLocalizedEventName(title)
    local key = WORLD_EVENT_TRANSLATIONS[title]
    if key then
        return L[key]
    end
    return title
end

-- Whitelist of world events to display (English + localized names)
local WORLD_EVENTS = {
    -- English
    "Love is in the Air",
    "Lunar Festival",
    "Noblegarden",
    "Children's Week",
    "Midsummer Fire Festival",
    "Brewfest",
    "Hallow's End",
    "Feast of Winter Veil",
    "Day of the Dead",
    "Pirates' Day",
    "Trial of Style",
    "Outland Cup",
    "Northrend Cup",
    "Kalimdor Cup",
    "Eastern Kingdoms Cup",
    "Winds of Mysterious Fortune",
    -- zhTW
    "æ„›å°±åœ¨èº«é‚Š",
    "æ–°å¹´æ…¶å…¸",
    "è²´æ—èŠ±åœ’",
    "å…’ç«¥é€±",
    "ä»²å¤ç«ç„°ç¯€æ…¶",
    "å•¤é…’ç¯€",
    "è¬é¬¼ç¯€",
    "å†¬å¹•ç¯€",
    "äº¡è€…ç¯€",
    "æµ·ç›œç¯€",
    "æ™‚å°šå¤§è€ƒé©—",
    "å¤–åŸŸæ¯",
    "åŒ—è£‚å¢ƒæ¯",
    "å¡æž—å¤šæ¯",
    "æ±éƒ¨çŽ‹åœ‹æ¯",
    "ç¥žç§˜å‘½é‹ä¹‹é¢¨",
    -- zhCN
    "æƒ…äººèŠ‚",
    "æ˜¥èŠ‚",
    "å¤æ´»èŠ‚",
    "å„¿ç«¥å‘¨",
    "ä»²å¤ç«ç„°èŠ‚",
    "ç¾Žé…’èŠ‚",
    "ä¸‡åœ£èŠ‚",
    "å†¬å¹•èŠ‚",
    "äº¡çµèŠ‚",
    "æµ·ç›—æ—¥",
    "è¯•è¡£å¤§ä¼š",
    "å¤–åŸŸæ¯",
    "è¯ºæ£®å¾·æ¯",
    "å¡åˆ©å§†å¤šæ¯",
    "ä¸œéƒ¨çŽ‹å›½æ¯",
    "ç¥žç§˜å‘½è¿ä¹‹é£Ž",
    -- koKR
    "ì˜¨ ì„¸ìƒì— ì‚¬ëž‘ì„",
    "ë‹¬ì˜ ì¶•ì œ",
    "ê·€ì¡±ì˜ ì •ì›",
    "ì–´ë¦°ì´ ì£¼ê°„",
    "í•œì—¬ë¦„ ë¶ˆê½ƒì¶•ì œ",
    "ê°€ì„ ì¶•ì œ",
    "í• ë¡œìœˆ ì¶•ì œ",
    "ê²¨ìš¸ë§žì´ ì¶•ì œ",
    "ë§ìžì˜ ë‚ ",
    "í•´ì ì˜ ë‚ ",
    "ìŠ¤íƒ€ì¼ì˜ ì‹œí—˜",
    "ì•„ì›ƒëžœë“œ ì»µ",
    "ë…¸ìŠ¤ë Œë“œ ì»µ",
    "ì¹¼ë¦¼ë„ì–´ ì»µ",
    "ë™ë¶€ ì™•êµ­ ì»µ",
    "ì‹ ë¹„ë¡œìš´ í–‰ìš´ì˜ ë°”ëžŒ",
    -- deDE
    "Liebe liegt in der Luft",
    "Mondfest",
    "Nobelgarten",
    "Kinderwoche",
    "Sonnenwendfest",
    "Braufest",
    "SchlotternÃ¤chte",
    "Winterhauch",
    "Tag der Toten",
    "Piratentag",
    "Probe des Stils",
    "Scherbenwelt-Cup",
    "Nordend-Cup",
    "Kalimdor-Cup",
    "Ã–stliche KÃ¶nigreiche-Cup",
    "Winde des geheimnisvollen GlÃ¼cks",
    -- frFR
    "De l'amour dans l'air",
    "FÃªte lunaire",
    "Le Jardin des nobles",
    "Semaine des enfants",
    "FÃªte du Feu du solstice d'Ã©tÃ©",
    "FÃªte des Brasseurs",
    "Sanssaint",
    "Voile d'hiver",
    "Jour des morts",
    "Jour des pirates",
    "Ã‰preuve de style",
    "Coupe de l'Outreterre",
    "Coupe de Norfendre",
    "Coupe de Kalimdor",
    "Coupe des Royaumes de l'Est",
    "Vents de fortune mystÃ©rieuse",
    -- esES
    "El amor estÃ¡ en el aire",
    "Festival Lunar",
    "JardÃ­n Noble",
    "Semana de los NiÃ±os",
    "Festival de Fuego del Solsticio de Verano",
    "Fiesta de la Cerveza",
    "Halloween",
    "Festival de Invierno",
    "DÃ­a de los Muertos",
    "DÃ­a de los Piratas",
    "Prueba de Estilo",
    "Copa de Terrallende",
    "Copa de Rasganorte",
    "Copa de Kalimdor",
    "Copa de los Reinos del Este",
    "Vientos de fortuna misteriosa",
    -- ptBR
    "O Amor EstÃ¡ no Ar",
    "Festival da Lua",
    "Jardinova",
    "Semana das CrianÃ§as",
    "Festival do Fogo do SolstÃ­cio",
    "CervaFest",
    "NoturnÃ¡lia",
    "Festa do VÃ©u de Inverno",
    "Dia dos Mortos",
    "Dia dos Piratas",
    "Prova de Estilo",
    "Copa de TerralÃ©m",
    "Copa de NortÃºndria",
    "Copa de Kalimdor",
    "Copa dos Reinos do Leste",
    "Ventos da Fortuna Misteriosa",
    -- ruRU
    "Ð›ÑŽÐ±Ð¾Ð²ÑŒ Ð²Ð¸Ñ‚Ð°ÐµÑ‚ Ð² Ð²Ð¾Ð·Ð´ÑƒÑ…Ðµ",
    "Ð›ÑƒÐ½Ð½Ñ‹Ð¹ Ñ„ÐµÑÑ‚Ð¸Ð²Ð°Ð»ÑŒ",
    "Ð¡Ð°Ð´ Ñ‡ÑƒÐ´ÐµÑ",
    "Ð”ÐµÑ‚ÑÐºÐ°Ñ Ð½ÐµÐ´ÐµÐ»Ñ",
    "ÐžÐ³Ð½ÐµÐ½Ð½Ñ‹Ð¹ ÑÐ¾Ð»Ð½Ñ†ÐµÐ²Ð¾Ñ€Ð¾Ñ‚",
    "Ð¥Ð¼ÐµÐ»ÑŒÐ½Ð¾Ð¹ Ñ„ÐµÑÑ‚Ð¸Ð²Ð°Ð»ÑŒ",
    "Ð¢Ñ‹ÐºÐ²Ð¾Ð²Ð¸Ð½",
    "Ð—Ð¸Ð¼Ð½Ð¸Ð¹ ÐŸÐ¾ÐºÑ€Ð¾Ð²",
    "Ð”ÐµÐ½ÑŒ Ð¼Ñ‘Ñ€Ñ‚Ð²Ñ‹Ñ…",
    "Ð”ÐµÐ½ÑŒ Ð¿Ð¸Ñ€Ð°Ñ‚Ð°",
    "Ð˜ÑÐ¿Ñ‹Ñ‚Ð°Ð½Ð¸Ðµ ÑÑ‚Ð¸Ð»ÐµÐ¼",
    "ÐšÑƒÐ±Ð¾Ðº Ð—Ð°Ð¿Ñ€ÐµÐ´ÐµÐ»ÑŒÑ",
    "ÐšÑƒÐ±Ð¾Ðº ÐÐ¾Ñ€Ð´ÑÐºÐ¾Ð»Ð°",
    "ÐšÑƒÐ±Ð¾Ðº ÐšÐ°Ð»Ð¸Ð¼Ð´Ð¾Ñ€Ð°",
    "ÐšÑƒÐ±Ð¾Ðº Ð’Ð¾ÑÑ‚Ð¾Ñ‡Ð½Ñ‹Ñ… ÐºÐ¾Ñ€Ð¾Ð»ÐµÐ²ÑÑ‚Ð²",
    "Ð’ÐµÑ‚Ñ€Ð° Ñ‚Ð°Ð¸Ð½ÑÑ‚Ð²ÐµÐ½Ð½Ð¾Ð¹ ÑƒÐ´Ð°Ñ‡Ð¸",
}

function lv.UpdateWorldEventsFrame()
    if not lv.WorldEventsFrame then return end

    local today = date("*t")
    local viewMonth = lv.VIEW_MONTH or today.month
    local viewYear = lv.VIEW_YEAR or today.year
    local events = {}
    local foundEvents = {} -- Track unique events by title

    -- Get days in viewed month
    local daysInMonth = DAYS_IN_MONTH[viewMonth]
    if viewMonth == 2 and (viewYear % 4 == 0 and (viewYear % 100 ~= 0 or viewYear % 400 == 0)) then
        daysInMonth = 29
    end

    -- Scan the currently viewed month for events
    for day = 1, daysInMonth do
        local numEvents = C_Calendar.GetNumDayEvents(0, day)
        for e = 1, numEvents do
            local event = C_Calendar.GetDayEvent(0, day, e)
            if event and event.calendarType == "HOLIDAY" then
                local title = SafeString(event.title)
                if title and not foundEvents[title] then
                    -- Check if event matches whitelist
                    for _, eventName in ipairs(WORLD_EVENTS) do
                        if string.find(title, eventName) then
                            foundEvents[title] = true

                            local dateStr = ""
                            local isActive = false
                            if event.startTime and event.endTime then
                                dateStr = string.format("%d/%d - %d/%d",
                                    event.startTime.month, event.startTime.monthDay,
                                    event.endTime.month, event.endTime.monthDay)

                                -- Check if currently active (based on real today, not viewed month)
                                local startDate = event.startTime.month * 100 + event.startTime.monthDay
                                local endDate = event.endTime.month * 100 + event.endTime.monthDay
                                local todayDate = today.month * 100 + today.day
                                isActive = todayDate >= startDate and todayDate <= endDate
                            end

                            table.insert(events, {
                                title = GetLocalizedEventName(title),
                                dates = dateStr,
                                isActive = isActive,
                                startMonth = event.startTime and event.startTime.month or 12,
                                startDay = event.startTime and event.startTime.monthDay or 31
                            })
                            break
                        end
                    end
                end
            end
        end
    end

    -- Sort by start date
    table.sort(events, function(a, b)
        if a.startMonth == b.startMonth then
            return a.startDay < b.startDay
        end
        return a.startMonth < b.startMonth
    end)

    -- Build display text
    local displayText = ""
    if #events > 0 then
        for _, evt in ipairs(events) do
            if evt.isActive then
                displayText = displayText .. "|cffffff00" .. evt.title .. "|r\n"
            else
                displayText = displayText .. "|cff888888" .. evt.title .. "|r\n"
            end
            if evt.dates ~= "" then
                displayText = displayText .. "|cffaaaaaa" .. evt.dates .. "|r\n\n"
            end
        end
    else
        displayText = "|cff888888" .. L["MSG_NO_WORLD_EVENTS"] .. "|r"
    end

    lv.WorldEventsFrame.content:SetText(displayText)
end
