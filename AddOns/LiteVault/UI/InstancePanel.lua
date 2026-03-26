local addonName, lv = ...
local L = lv.L

local panel
local widgets = {}
local elapsedTicker = 0
local currentTab = "instances"

local function GetPanelContentWidth()
    if not panel then return 400 end
    return math.max(400, (panel:GetWidth() or 0) - 24)
end

local function GetRecentSectionHeight()
    if not panel then return 102 end
    return math.max(102, (panel:GetHeight() or 470) - 366)
end

local function GetMPlusRecentSectionHeight()
    if not panel then return 230 end
    return math.max(230, (panel:GetHeight() or 470) - 238)
end

local function LayoutPanel()
    if not panel or not widgets.title then return end

    local contentWidth = GetPanelContentWidth()
    local recentHeight = GetRecentSectionHeight()
    local mplusRecentHeight = GetMPlusRecentSectionHeight()
    local secondColumnX = math.max(192, math.floor(contentWidth * 0.45))

    widgets.title:SetWidth(math.max(220, contentWidth - 180))

    for _, boxName in ipairs({ "capBox", "currentBox", "perfBox", "legacyBox", "mplusBox" }) do
        local box = widgets[boxName]
        if box and box._baseHeight then
            box:SetWidth(contentWidth)
            box:SetHeight(box._baseHeight)
        end
    end

    if widgets.recentBox then
        widgets.recentBox:SetWidth(contentWidth)
        widgets.recentBox:SetHeight(recentHeight)
    end
    if widgets.mplusRecentBox then
        widgets.mplusRecentBox:SetWidth(contentWidth)
        widgets.mplusRecentBox:SetHeight(mplusRecentHeight)
    end

    if widgets.capStatus then
        widgets.capStatus:ClearAllPoints()
        widgets.capStatus:SetPoint("TOPLEFT", secondColumnX, -30)
    end
    if widgets.raidsToday then
        widgets.raidsToday:ClearAllPoints()
        widgets.raidsToday:SetPoint("TOPLEFT", secondColumnX, -30)
    end
    if widgets.avgRaid then
        widgets.avgRaid:ClearAllPoints()
        widgets.avgRaid:SetPoint("TOPLEFT", secondColumnX, -50)
    end
    if widgets.legacyGold then
        widgets.legacyGold:ClearAllPoints()
        widgets.legacyGold:SetPoint("TOPLEFT", secondColumnX, -30)
    end

    if widgets.recentContent then
        widgets.recentContent:SetWidth(contentWidth - 24)
    end
    if widgets.mplusRecentContent then
        widgets.mplusRecentContent:SetWidth(contentWidth - 24)
    end

    for _, row in ipairs(widgets.recentRows or {}) do
        row:SetWidth(contentWidth - 26)
        row.text:SetWidth(contentWidth - 26)
    end
    for _, row in ipairs(widgets.mplusRecentRows or {}) do
        row:SetWidth(contentWidth - 26)
    end
end

local function T(key, fallback)
    if not L then return fallback end
    local v = L[key]
    if not v or v == key then
        return fallback
    end
    return v
end

local function FormatSlotTimer(seconds)
    local s = math.max(0, tonumber(seconds) or 0)
    local m = math.floor(s / 60)
    local r = s % 60
    return string.format(T("%dm %02ds", "%dm %02ds"), m, r)
end

local function StartOfCurrentResetDay()
    local now = time()
    if lv.GetSecondsUntilDailyReset then
        local untilReset = tonumber(lv.GetSecondsUntilDailyReset()) or 0
        return now - math.max(0, 86400 - untilReset)
    end

    local t = date("*t", now)
    t.hour, t.min, t.sec = 0, 0, 0
    return time(t)
end

local function GetRunCharacterName(run)
    if not run then return nil end
    if run.charName and run.charName ~= "" then
        return run.charName
    end
    if run.charKey and run.charKey ~= "" then
        return (run.charKey:match("^([^-]+)")) or run.charKey
    end
    return nil
end

local function GetRunCharacterClass(run)
    if not run then return nil end
    if run.charClass and run.charClass ~= "" then
        return run.charClass
    end
    if run.charKey and LiteVaultDB and LiteVaultDB[run.charKey] and LiteVaultDB[run.charKey].class then
        return LiteVaultDB[run.charKey].class
    end
    return nil
end

local function GetClassColorHex(classTag)
    if not classTag then return "ffffffff" end
    if C_ClassColor and C_ClassColor.GetClassColor then
        local cc = C_ClassColor.GetClassColor(classTag)
        if cc and cc.GenerateHexColor then
            return cc:GenerateHexColor()
        end
    end
    if RAID_CLASS_COLORS and RAID_CLASS_COLORS[classTag] and RAID_CLASS_COLORS[classTag].colorStr then
        return RAID_CLASS_COLORS[classTag].colorStr
    end
    return "ffffffff"
end

local function BuildRunCrestGainText(run)
    if not run or not run.crestGains then
        return nil
    end

    local order = {
        { key = "Adventurer Dawncrest", currencyID = 3383 },
        { key = "Veteran Dawncrest", currencyID = 3341 },
        { key = "Champion Dawncrest", currencyID = 3343 },
        { key = "Hero Dawncrest", currencyID = 3345 },
        { key = "Myth Dawncrest", currencyID = 3347 },
    }

    local parts = {}
    for _, entry in ipairs(order) do
        local amount = tonumber(run.crestGains[entry.key]) or 0
        if amount > 0 then
            local iconFileID = nil
            if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo and entry.currencyID then
                local info = C_CurrencyInfo.GetCurrencyInfo(entry.currencyID)
                iconFileID = info and info.iconFileID or nil
            end
            if iconFileID then
                parts[#parts + 1] = string.format("|T%d:14:14:0:0|t%d", iconFileID, amount)
            else
                parts[#parts + 1] = string.format("%s %d", entry.key, amount)
            end
        end
    end

    if #parts == 0 then
        return nil
    end

    return "|cffd4af37" .. T("Crests:", "Crests:") .. " " .. table.concat(parts, " ") .. "|r"
end

local function BuildRunTitleText(run)
    if not run then
        return UNKNOWN
    end

    local name = run.name or UNKNOWN
    local difficultyName = run.difficultyName
    if difficultyName and difficultyName ~= "" then
        return string.format("%s (%s)", name, difficultyName)
    end

    return name
end

local function GetMPlusRuns(windowStart, limit)
    local out = {}
    local runs = lv.Stats.GetRecentRuns(500)
    for _, run in ipairs(runs) do
        local endTime = run.endTime or run.startTime or 0
        if endTime >= (windowStart or 0) and run.type == "dungeon" and run.isMythicPlus then
            out[#out + 1] = run
            if limit and #out >= limit then
                break
            end
        end
    end
    return out
end

local function EnsurePanel()
    if panel then return end

    panel = CreateFrame("Frame", "LiteVaultInstancePanel", LiteVaultWindow, "BackdropTemplate")
    panel:SetPoint("TOPLEFT", LiteVaultWindow, "TOPLEFT", 35, -65)
    panel:SetPoint("BOTTOMRIGHT", LiteVaultWindow, "BOTTOMRIGHT", -15, 25)
    panel:SetFrameStrata("MEDIUM")
    panel:Hide()
    panel:SetScript("OnHide", function()
        if LiteVaultWindow and LiteVaultWindow:IsShown() and lv.GetMainView and lv.GetMainView() == "instances" and lv.SetMainView then
            lv.SetMainView("dashboard")
        end
    end)
    panel:SetScript("OnSizeChanged", LayoutPanel)

    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    widgets.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    widgets.title:SetPoint("TOPLEFT", 14, -12)
    widgets.title:SetWidth(300)
    widgets.title:SetJustifyH("LEFT")
    lv.ApplyLocaleFont(widgets.title, 16)

    local mplusBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    mplusBtn:SetSize(lv.Layout.instancePanelTabWidth or 70, 22)
    mplusBtn:SetPoint("TOPRIGHT", -10, -10)
    mplusBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    mplusBtn.Text = mplusBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mplusBtn.Text:SetPoint("CENTER")
    mplusBtn.Text:SetText(T("LABEL_MYTHIC_PLUS", "M+"))
    lv.ApplyLocaleFont(mplusBtn.Text, 11)
    mplusBtn:SetScript("OnClick", function()
        if currentTab == "instances" then
            currentTab = "mplus"
        else
            currentTab = "instances"
        end
        if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
    end)
    widgets.mplusBtn = mplusBtn

    local function CreateSection(y, h, titleText)
        local box = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        box:SetPoint("TOPLEFT", 12, y)
        box:SetSize(GetPanelContentWidth(), h)
        box._baseHeight = h
        box:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        local title = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 10, -8)
        title:SetText(titleText)
        title:SetTextColor(1, 0.82, 0)

        return box, title
    end

    widgets.capBox, widgets.capTitle = CreateSection(-42, 72, "")
    widgets.capCurrent = widgets.capBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.capCurrent:SetPoint("TOPLEFT", 12, -30)
    widgets.capStatus = widgets.capBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.capStatus:SetPoint("TOPLEFT", 150, -30)
    widgets.capNext = widgets.capBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.capNext:SetPoint("TOPLEFT", 12, -50)

    widgets.currentBox, widgets.currentTitle = CreateSection(-120, 72, "")
    widgets.currentName = widgets.currentBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.currentName:SetPoint("TOPLEFT", 12, -30)
    widgets.currentDuration = widgets.currentBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.currentDuration:SetPoint("TOPLEFT", 12, -50)
    widgets.currentMountsBtn = CreateFrame("Button", nil, widgets.currentBox)
    widgets.currentMountsBtn:SetPoint("TOPRIGHT", -12, -44)
    widgets.currentMountsBtn:SetSize(240, 22)
    widgets.currentMounts = widgets.currentMountsBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.currentMounts:SetPoint("RIGHT", 0, 0)
    widgets.currentMounts:SetJustifyH("RIGHT")
    widgets.currentMounts:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    widgets.currentMountIcon = widgets.currentMountsBtn:CreateTexture(nil, "ARTWORK")
    widgets.currentMountIcon:SetSize(20, 20)
    widgets.currentMountIcon:SetPoint("RIGHT", widgets.currentMounts, "LEFT", -5, 0)
    widgets.currentMountIcon:Hide()
    widgets.currentMountsBtn.mountEntries = nil
    widgets.currentMountsBtn:SetScript("OnEnter", function(self)
        if not self.mountEntries or #self.mountEntries == 0 then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(T("Mount Drops", "Mount Drops"), 1, 0.82, 0)
        for _, m in ipairs(self.mountEntries) do
            if m.collected then
                GameTooltip:AddLine("|cff00ff00" .. m.name .. " " .. T("(Collected)", "(Collected)") .. "|r")
            else
                GameTooltip:AddLine("|cffff4040" .. m.name .. " " .. T("(Uncollected)", "(Uncollected)") .. "|r")
            end
        end
        GameTooltip:Show()
    end)
    widgets.currentMountsBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    widgets.perfBox, widgets.perfTitle = CreateSection(-198, 72, "")
    widgets.dungeonsToday = widgets.perfBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.dungeonsToday:SetPoint("TOPLEFT", 12, -30)
    widgets.raidsToday = widgets.perfBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.raidsToday:SetPoint("TOPLEFT", 192, -30)
    widgets.avgDungeon = widgets.perfBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.avgDungeon:SetPoint("TOPLEFT", 12, -50)
    widgets.avgRaid = widgets.perfBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.avgRaid:SetPoint("TOPLEFT", 192, -50)

    widgets.legacyBox, widgets.legacyTitle = CreateSection(-276, 72, "")
    widgets.legacyRuns = widgets.legacyBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.legacyRuns:SetPoint("TOPLEFT", 12, -30)
    widgets.legacyGold = widgets.legacyBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.legacyGold:SetPoint("TOPLEFT", 192, -30)
    widgets.legacyAvg = widgets.legacyBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.legacyAvg:SetPoint("TOPLEFT", 12, -50)

    widgets.recentBox, widgets.recentTitle = CreateSection(-354, 102, "")
    widgets.recentScroll = CreateFrame("ScrollFrame", nil, widgets.recentBox)
    widgets.recentScroll:SetPoint("TOPLEFT", 10, -24)
    widgets.recentScroll:SetPoint("BOTTOMRIGHT", -10, 8)
    widgets.recentScroll:EnableMouseWheel(true)

    widgets.recentContent = CreateFrame("Frame", nil, widgets.recentScroll)
    widgets.recentContent:SetPoint("TOPLEFT")
    widgets.recentContent:SetSize(GetPanelContentWidth() - 24, 1)
    widgets.recentScroll:SetScrollChild(widgets.recentContent)

    widgets.recentRows = {}
    for i = 1, 20 do
        local row = CreateFrame("Button", nil, widgets.recentContent)
        row:SetPoint("TOPLEFT", 2, -2 - ((i - 1) * 16))
        row:SetSize(GetPanelContentWidth() - 26, 16)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 0, 0)
        row.text:SetWidth(GetPanelContentWidth() - 26)
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)
        lv.ApplyLocaleFont(row.text, 11)
        row:EnableMouse(false)
        widgets.recentRows[i] = row
    end
    widgets.recentScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local step = 16
        local maxScroll = math.max(0, (widgets.recentContent:GetHeight() or 0) - (self:GetHeight() or 0))
        local nextScroll = current - (delta * step)
        if nextScroll < 0 then nextScroll = 0 end
        if nextScroll > maxScroll then nextScroll = maxScroll end
        self:SetVerticalScroll(nextScroll)
    end)

    -- M+ tab view
    widgets.mplusBox, widgets.mplusTitle = CreateSection(-42, 178, "")
    widgets.mplusCurrentKey = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.mplusCurrentKey:SetPoint("TOPLEFT", 12, -30)
    widgets.mplusScore = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.mplusScore:SetPoint("TOPLEFT", 12, -50)
    widgets.mplusToday = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.mplusToday:SetPoint("TOPLEFT", 12, -76)
    widgets.mplusWeek = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.mplusWeek:SetPoint("TOPLEFT", 12, -96)

    widgets.mplusRecentBox, widgets.mplusRecentTitle = CreateSection(-226, 230, "")
    widgets.mplusRecentScroll = CreateFrame("ScrollFrame", nil, widgets.mplusRecentBox)
    widgets.mplusRecentScroll:SetPoint("TOPLEFT", 10, -24)
    widgets.mplusRecentScroll:SetPoint("BOTTOMRIGHT", -10, 8)
    widgets.mplusRecentScroll:EnableMouseWheel(true)
    widgets.mplusRecentContent = CreateFrame("Frame", nil, widgets.mplusRecentScroll)
    widgets.mplusRecentContent:SetPoint("TOPLEFT")
    widgets.mplusRecentContent:SetSize(GetPanelContentWidth() - 24, 1)
    widgets.mplusRecentScroll:SetScrollChild(widgets.mplusRecentContent)
    widgets.mplusRecentRows = {}
    for i = 1, 20 do
        local row = widgets.mplusRecentContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", 2, -2 - ((i - 1) * 16))
        row:SetWidth(GetPanelContentWidth() - 26)
        row:SetJustifyH("LEFT")
        row:SetWordWrap(false)
        widgets.mplusRecentRows[i] = row
    end
    widgets.mplusRecentScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local step = 16
        local maxScroll = math.max(0, (widgets.mplusRecentContent:GetHeight() or 0) - (self:GetHeight() or 0))
        local nextScroll = current - (delta * step)
        if nextScroll < 0 then nextScroll = 0 end
        if nextScroll > maxScroll then nextScroll = maxScroll end
        self:SetVerticalScroll(nextScroll)
    end)

    panel:SetScript("OnUpdate", function(_, elapsed)
        elapsedTicker = elapsedTicker + elapsed
        if elapsedTicker < 1 then return end
        elapsedTicker = 0
        if lv.UpdateInstancePanel then
            lv.UpdateInstancePanel()
        end
    end)

    local function ApplyTheme()
        local t = lv.GetTheme()
        panel:SetBackdropColor(unpack(t.backgroundSolid or t.background))
        panel:SetBackdropBorderColor(unpack(t.borderPrimary))
        widgets.mplusBtn:SetBackdropColor(unpack(t.buttonBg))
        widgets.mplusBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        widgets.mplusBtn.Text:SetTextColor(unpack(t.textSecondary))
        for _, boxName in ipairs({ "capBox", "currentBox", "perfBox", "legacyBox", "recentBox", "mplusBox", "mplusRecentBox" }) do
            local box = widgets[boxName]
            box:SetBackdropColor(unpack(t.backgroundAlt or t.background))
            box:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
    end

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(panel, ApplyTheme)
            ApplyTheme()
        end
        LayoutPanel()
    end)
end

function lv.UpdateInstancePanel()
    if not panel then return end
    LayoutPanel()

    widgets.title:SetText(T("TITLE_INSTANCE_TRACKER", "Instance Tracker"))
    local t = lv.GetTheme()
    if currentTab == "instances" then
        widgets.mplusBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        widgets.mplusBtn:SetBackdropColor(unpack(t.buttonBg))
        widgets.mplusBtn.Text:SetTextColor(unpack(t.textSecondary))
        widgets.mplusBtn.Text:SetText(T("LABEL_MYTHIC_PLUS", "M+"))
    else
        widgets.mplusBtn:SetBackdropBorderColor(unpack(t.borderHover))
        widgets.mplusBtn:SetBackdropColor(unpack(t.buttonBgHover))
        widgets.mplusBtn.Text:SetTextColor(unpack(t.textPrimary))
        widgets.mplusBtn.Text:SetText(T("BUTTON_BACK", "Back"))
    end

    widgets.capTitle:SetText(T("SECTION_INSTANCE_CAP", "Instance Cap (10/hour)"))
    local capCount = (lv.InstanceCap and lv.InstanceCap.GetCurrentCount and lv.InstanceCap.GetCurrentCount()) or 0
    local capStatus = (lv.InstanceCap and lv.InstanceCap.GetStatus and lv.InstanceCap.GetStatus()) or "SAFE"
    local slotIn = (lv.InstanceCap and lv.InstanceCap.GetTimeUntilSlot and lv.InstanceCap.GetTimeUntilSlot()) or 0
    widgets.capCurrent:SetText(string.format(T("LABEL_CAP_CURRENT", "Current: %d/10"), capCount))
    widgets.capStatus:SetText(string.format(T("LABEL_CAP_STATUS", "Status: %s"), T("STATUS_" .. capStatus, capStatus)))
    widgets.capNext:SetText(string.format(T("LABEL_NEXT_SLOT", "Next slot in: %s"), FormatSlotTimer(slotIn)))

    if capStatus == "LOCKED" then
        widgets.capStatus:SetTextColor(1.0, 0.2, 0.2)
    elseif capStatus == "WARNING" then
        widgets.capStatus:SetTextColor(1.0, 0.82, 0.2)
    else
        widgets.capStatus:SetTextColor(0.35, 0.9, 0.35)
    end

    widgets.currentTitle:SetText(T("SECTION_CURRENT_RUN", "Current Run"))
    local current = lv.InstanceTracker and lv.InstanceTracker.GetCurrentRun and lv.InstanceTracker.GetCurrentRun() or nil
    if current then
        widgets.currentName:SetText(string.format("%s (%s)", current.name or UNKNOWN, current.difficultyName or ""))
        local seconds = time() - (current.startTime or time())
        widgets.currentDuration:SetText(string.format(T("LABEL_DURATION", "Duration: %s"), lv.Stats.FormatDuration(seconds)))
        if lv.MountDrops and lv.MountDrops.GetInstanceMountStatus then
            local mountStatus = lv.MountDrops.GetInstanceMountStatus(current.instanceID)
            if mountStatus then
                widgets.currentMountsBtn.mountEntries = mountStatus.entries
                local color = mountStatus.allCollected and "|cff00ff00" or "|cffff4040"
                local displayName = nil
                local displayEntry = nil
                for _, m in ipairs(mountStatus.entries or {}) do
                    if not m.collected then
                        displayName = m.name
                        displayEntry = m
                        break
                    end
                end
                if not displayName and mountStatus.entries and mountStatus.entries[1] then
                    displayName = mountStatus.entries[1].name
                    displayEntry = mountStatus.entries[1]
                end
                if displayName then
                    widgets.currentMounts:SetText(string.format("%s%s (%d/%d)|r", color, displayName, mountStatus.owned, mountStatus.total))
                    if displayEntry and displayEntry.icon then
                        widgets.currentMountIcon:SetTexture(displayEntry.icon)
                        widgets.currentMountIcon:Show()
                    else
                        widgets.currentMountIcon:Hide()
                    end
                else
                    widgets.currentMounts:SetText(string.format("%s" .. T("LABEL_MOUNTS_FMT", "Mounts: %d/%d") .. "|r", color, mountStatus.owned, mountStatus.total))
                    widgets.currentMountIcon:Hide()
                end
            else
                widgets.currentMountsBtn.mountEntries = nil
                widgets.currentMounts:SetText("")
                widgets.currentMountIcon:Hide()
            end
        else
            widgets.currentMountsBtn.mountEntries = nil
            widgets.currentMounts:SetText("")
            widgets.currentMountIcon:Hide()
        end
    else
        widgets.currentName:SetText(T("LABEL_NOT_IN_INSTANCE", "Not in an instance"))
        widgets.currentDuration:SetText(string.format(T("LABEL_DURATION", "Duration: %s"), lv.Stats.FormatDuration(0)))
        widgets.currentMountsBtn.mountEntries = nil
        widgets.currentMounts:SetText("")
        widgets.currentMountIcon:Hide()
    end

    widgets.perfTitle:SetText(T("SECTION_PERFORMANCE", "Performance Today"))
    local dCount = lv.Stats.GetTodayRuns("dungeon")
    local rCount = lv.Stats.GetTodayRuns("raid")
    local dAvg = lv.Stats.GetAverageTime("dungeon")
    local rAvg = lv.Stats.GetAverageTime("raid")
    widgets.dungeonsToday:SetText(string.format(T("LABEL_DUNGEONS_TODAY", "Dungeons: %d"), dCount))
    widgets.raidsToday:SetText(string.format(T("LABEL_RAIDS_TODAY", "Raids: %d"), rCount))
    widgets.avgDungeon:SetText(string.format(T("LABEL_AVG_TIME", "Avg: %s"), lv.Stats.FormatDuration(dAvg)))
    widgets.avgRaid:SetText(string.format(T("LABEL_AVG_TIME", "Avg: %s"), lv.Stats.FormatDuration(rAvg)))

    widgets.legacyTitle:SetText(T("SECTION_LEGACY_RAIDS", "Legacy Raids This Week"))
    local legacyRuns = 0
    local legacyDur = 0
    local legacyGold = 0
    local recent = lv.Stats.GetRecentRuns(200)
    local startWindow = 0
    if lv.GetLastWeeklyReset then
        startWindow = lv.GetLastWeeklyReset()
    end
    for _, run in ipairs(recent) do
        local endTime = run.endTime or run.startTime or 0
        if endTime >= startWindow and run.isLegacy and run.type == "raid" then
            legacyRuns = legacyRuns + 1
            legacyDur = legacyDur + (run.duration or 0)
            legacyGold = legacyGold + math.max(0, run.gold or 0)
        end
    end
    local legacyAvg = legacyRuns > 0 and math.floor(legacyDur / legacyRuns) or 0
    widgets.legacyRuns:SetText(string.format(T("LABEL_LEGACY_RUNS", "Runs: %d"), legacyRuns))
    widgets.legacyGold:SetText(string.format(T("LABEL_GOLD_EARNED", "Gold: %s"), GetCoinTextureString(legacyGold)))
    widgets.legacyAvg:SetText(string.format(T("LABEL_AVG_TIME", "Avg: %s"), lv.Stats.FormatDuration(legacyAvg)))

    widgets.recentTitle:SetText(T("SECTION_RECENT_RUNS", "Recent Runs"))
    local recentRuns = lv.Stats.GetRecentRuns(20)
    local shown = 0
    for i = 1, 20 do
        local row = widgets.recentRows[i]
        local run = recentRuns[i]
        if run then
            local text = string.format("%s - %s", BuildRunTitleText(run), lv.Stats.FormatDuration(run.duration or 0))
            local runChar = GetRunCharacterName(run)
            if runChar then
                local classHex = GetClassColorHex(GetRunCharacterClass(run))
                text = text .. string.format("  [|c%s%s|r]", classHex, runChar)
            end
            if run.gold and run.gold > 0 then
                text = text .. "  " .. GetCoinTextureString(run.gold)
            end
            local crestText = BuildRunCrestGainText(run)
            if crestText then
                text = text .. "  " .. crestText
            end
            row.text:SetText(text)
            row:Show()
            shown = shown + 1
        else
            if i == 1 then
                row.text:SetText(T("LABEL_NO_RECENT_RUNS", "No recent runs"))
                row:Show()
                shown = shown + 1
            else
                row:Hide()
            end
        end
    end
    local contentHeight = math.max((shown * 16) + 4, widgets.recentScroll:GetHeight() or 1)
    widgets.recentContent:SetHeight(contentHeight)
    local maxScroll = math.max(0, contentHeight - (widgets.recentScroll:GetHeight() or 0))
    if widgets.recentScroll:GetVerticalScroll() > maxScroll then
        widgets.recentScroll:SetVerticalScroll(maxScroll)
    end

    -- M+ tab content
    widgets.mplusTitle:SetText(T("SECTION_MPLUS", "Mythic+"))
    local playerData = LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY]
    local key = playerData and playerData.currentKey
    if key and key.name and key.level then
        widgets.mplusCurrentKey:SetText(string.format("|TInterface\\Icons\\inv_relics_hourglass:16:16|t " .. T("LABEL_MPLUS_CURRENT_KEY", "Current Key:") .. " |cff00ccff%s +%d|r", key.name, key.level))
    else
        widgets.mplusCurrentKey:SetText("|TInterface\\Icons\\inv_relics_hourglass:16:16|t " .. T("LABEL_MPLUS_CURRENT_KEY", "Current Key:") .. " |cffff4040" .. T("LABEL_NO_KEY", "No M+ Key") .. "|r")
    end
    widgets.mplusScore:SetText(string.format(T("LABEL_MPLUS_SCORE", "M+ Score: %d"), playerData and (playerData.mplus or 0) or 0))

    local todayStart = StartOfCurrentResetDay()
    local weekStart = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or 0
    local todayRuns = GetMPlusRuns(todayStart)
    local weekRuns = GetMPlusRuns(weekStart)
    widgets.mplusToday:SetText(string.format(T("LABEL_RUNS_TODAY", "Runs Today: %d"), #todayRuns))
    widgets.mplusWeek:SetText(string.format(T("LABEL_RUNS_THIS_WEEK", "Runs This Week: %d"), #weekRuns))

    widgets.mplusRecentTitle:SetText(T("SECTION_RECENT_MPLUS_RUNS", "Recent M+ Runs"))
    local recentMPlus = GetMPlusRuns(0, 20)
    local shownM = 0
    for i = 1, 20 do
        local row = widgets.mplusRecentRows[i]
        local run = recentMPlus[i]
        if run then
            local text = string.format("%s - %s", BuildRunTitleText(run), lv.Stats.FormatDuration(run.duration or 0))
            local runChar = GetRunCharacterName(run)
            if runChar then
                local classHex = GetClassColorHex(GetRunCharacterClass(run))
                text = text .. string.format("  [|c%s%s|r]", classHex, runChar)
            end
            if run.gold and run.gold > 0 then
                text = text .. "  " .. GetCoinTextureString(run.gold)
            end
            local crestText = BuildRunCrestGainText(run)
            if crestText then
                text = text .. "  " .. crestText
            end
            row:SetText(text)
            row:Show()
            shownM = shownM + 1
        else
            if i == 1 then
                row:SetText(T("LABEL_NO_RECENT_MPLUS_RUNS", "No recent M+ runs"))
                row:Show()
                shownM = shownM + 1
            else
                row:Hide()
            end
        end
    end
    local mContentHeight = math.max((shownM * 16) + 4, widgets.mplusRecentScroll:GetHeight() or 1)
    widgets.mplusRecentContent:SetHeight(mContentHeight)
    local mMaxScroll = math.max(0, mContentHeight - (widgets.mplusRecentScroll:GetHeight() or 0))
    if widgets.mplusRecentScroll:GetVerticalScroll() > mMaxScroll then
        widgets.mplusRecentScroll:SetVerticalScroll(mMaxScroll)
    end

    local showInstances = (currentTab == "instances")
    if not InCombatLockdown() then
        widgets.capBox:SetShown(showInstances)
        widgets.currentBox:SetShown(showInstances)
        widgets.perfBox:SetShown(showInstances)
        widgets.legacyBox:SetShown(showInstances)
        widgets.recentBox:SetShown(showInstances)

        widgets.mplusBox:SetShown(not showInstances)
        widgets.mplusRecentBox:SetShown(not showInstances)
    end
end

function lv.ShowInstancePanel()
    EnsurePanel()
    if lv.GetMainView and lv.GetMainView() ~= "instances" then
        return
    end
    lv.UpdateInstancePanel()
    if not InCombatLockdown() then panel:Show() end
end

function lv.ToggleInstancePanel()
    EnsurePanel()
    if panel:IsShown() then
        if lv.SetMainView then
            lv.SetMainView("dashboard")
        else
            panel:Hide()
        end
    else
        if lv.SetMainView then
            lv.SetMainView("instances")
        else
            lv.ShowInstancePanel()
        end
    end
end

SLASH_LVINSTANCES1 = "/lvinstances"
SlashCmdList["LVINSTANCES"] = function()
    lv.ToggleInstancePanel()
end

C_Timer.After(0, EnsurePanel)

local tooltipHook = CreateFrame("Frame")
tooltipHook:RegisterEvent("PLAYER_LOGIN")
tooltipHook:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    if not LibStub then return end
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB or not LDB.GetDataObjectByName then return end
    local obj = LDB:GetDataObjectByName("LiteVault")
    if not obj then return end
    local oldTooltip = obj.OnTooltipShow
    obj.OnTooltipShow = function(tooltip)
        if oldTooltip then
            oldTooltip(tooltip)
        end
        if lv.InstanceCap and lv.InstanceCap.GetCurrentCount then
            local count = lv.InstanceCap.GetCurrentCount()
            local status = lv.InstanceCap.GetStatus()
            tooltip:AddLine(" ")
            tooltip:AddLine(T("SECTION_INSTANCE_CAP", "Instance Cap (10/hour)"))
            tooltip:AddLine(string.format(T("LABEL_CAP_CURRENT", "Current: %d/10"), count))
            tooltip:AddLine(string.format(T("LABEL_CAP_STATUS", "Status: %s"), T("STATUS_" .. status, status)))
        end
        tooltip:Show()
    end
end)
