local addonName, lv = ...
local L = lv.L

local panel
local widgets = {}
local elapsedTicker = 0
local currentTab = "instances"
local mplusHistoryFilter = "week"
local mplusPlannerMode = false
local mplusPlannerAvoided = {}

-- One geometry contract for both the Mythic+ history header and every row.
-- Rewards intentionally receives the remaining safe space and may truncate.
local MPLUS_HISTORY_COLUMNS = {
    { key="LABEL_DUNGEON", fallback="Dungeon",   x=0,   width=170, justify="LEFT" },
    { key="LABEL_KEY", fallback="Key",           x=174, width=40,  justify="CENTER" },
    { key="LABEL_RESULT", fallback="Result",     x=218, width=82,  justify="CENTER" },
    { key="LABEL_TIME", fallback="Time",         x=304, width=60,  justify="CENTER" },
    { key="LABEL_CHARACTER", fallback="Character", x=368, width=92, justify="LEFT" },
    { key="LABEL_DATE", fallback="Date",         x=464, width=78,  justify="CENTER" },
    { key="LABEL_REWARDS", fallback="Rewards",   x=546, width=106, justify="LEFT" },
}

local function ApplyMPlusColumnGeometry(fontString, column)
    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", column.x, 0)
    fontString:SetWidth(column.width)
    fontString:SetJustifyH(column.justify)
    fontString:SetWordWrap(false)
end

-- Shared by panel construction callbacks, live theme refresh, and the external
-- UpdateInstancePanel refresh path. Keep this at file scope so every caller
-- resolves the same local helper.
local function ApplyMPlusHistoryRowTheme(row, theme, hovered)
    if not (row and theme) then return end
    local background = hovered and (theme.buttonBgHover or theme.buttonBg)
        or (row.rowIndex % 2 == 0 and theme.rowStripeEven or theme.rowStripeOdd)
        or theme.backgroundAlt or theme.background
    row:SetBackdropColor(unpack(background))
    local border = hovered and (theme.borderHover or theme.borderPrimary)
        or (theme.borderSubdued or theme.borderPrimary)
    if hovered then
        row:SetBackdropBorderColor(border[1], border[2], border[3], 0.55)
    else
        row:SetBackdropBorderColor(border[1], border[2], border[3], 0.12)
    end
end

local function GetPanelContentWidth()
    if not panel then return 400 end
    return math.max(400, (panel:GetWidth() or 0) - 24)
end

local function GetRecentSectionHeight()
    if not panel then return 102 end
    return math.max(102, (panel:GetHeight() or 470) - 366)
end

local function GetMPlusRecentSectionHeight()
    if not panel then return 180 end
    return math.max(120, (panel:GetHeight() or 670) - 392)
end

local function LayoutPanel()
    if not panel or not widgets.title then return end

    local contentWidth = GetPanelContentWidth()
    local recentHeight = GetRecentSectionHeight()
    local mplusRecentHeight = GetMPlusRecentSectionHeight()
    local secondColumnX = math.max(192, math.floor(contentWidth * 0.45))

    widgets.title:SetWidth(math.max(220, contentWidth - 180))

    for _, boxName in ipairs({ "capBox", "currentBox", "perfBox", "legacyBox", "mplusBox", "mplusSeasonBox" }) do
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
    if widgets.mplusPlannerBox then
        widgets.mplusPlannerBox:SetWidth(contentWidth)
        widgets.mplusPlannerBox:SetHeight(math.max(300, (panel:GetHeight() or 670) - 198))
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
        local enUS = lv.LocaleData and lv.LocaleData["enUS"]
        return fallback or (enUS and enUS[key]) or key
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

local function BuildRunCrestGainText(run, omitLabel)
    if not run or not run.crestGains then
        return nil
    end

    local order = {
        { key = "Adventurer Dawncrest", currencyID = 3383 },
        { key = "Veteran Dawncrest", currencyID = 3341 },
        { key = "Champion Dawncrest", currencyID = 3343 },
        { key = "Hero Dawncrest", currencyID = 3345 },
        { key = "Myth Dawncrest", currencyID = 3347 },
        { tier="adventurer", key = "Adventurer Mistcrest", currencyID = 3442, alternateCurrencyID = 3437 },
        { tier="veteran", key = "Veteran Mistcrest", currencyID = 3443, alternateCurrencyID = 3438 },
        { tier="champion", key = "Champion Mistcrest", currencyID = 3444, alternateCurrencyID = 3439 },
        { tier="hero", key = "Hero Mistcrest", currencyID = 3445, alternateCurrencyID = 3440 },
        { tier="myth", key = "Myth Mistcrest", currencyID = 3446, alternateCurrencyID = 3441 },
    }

    local parts = {}
    for _, entry in ipairs(order) do
        local amount = tonumber(run.crestGains[entry.key]) or 0
        if amount > 0 then
            local iconFileID = nil
            if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo and entry.currencyID then
                local resolvedID = entry.currencyID
                if entry.alternateCurrencyID then
                    resolvedID = lv.ResolveActiveCrestCurrencyID({
                        tier=entry.tier, key=entry.key, preferredCurrencyID=entry.currencyID,
                        alternateCurrencyIDs={entry.alternateCurrencyID},
                    })
                end
                local info = resolvedID and C_CurrencyInfo.GetCurrencyInfo(resolvedID)
                iconFileID = info and info.iconFileID or nil
            end
            if iconFileID then
                parts[#parts + 1] = string.format("|T%d:14:14:0:0|t%d", iconFileID, amount)
            elseif omitLabel then
                parts[#parts + 1] = tostring(amount)
            else
                parts[#parts + 1] = string.format("%s %d", entry.key, amount)
            end
        end
    end

    if #parts == 0 then
        return nil
    end

    if omitLabel then return table.concat(parts, " ") end
    return "|cffd4af37" .. string.format(T("TEXT_CRESTS_WITH_VALUES_FMT"), table.concat(parts, " ")) .. "|r"
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
        if endTime >= (windowStart or 0) and run.type == "dungeon" and run.isMythicPlus and not run.practiceRun then
            out[#out + 1] = run
            if limit and #out >= limit then
                break
            end
        end
    end
    return out
end

local function GetFilteredMPlusRuns(filter)
    local runs = GetMPlusRuns(0)
    local out = {}
    local weeklyReset = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or 0
    local currentSeasonID = C_MythicPlus and C_MythicPlus.GetCurrentSeason and tonumber(C_MythicPlus.GetCurrentSeason()) or nil
    local contentSeasonKey = lv.GetActiveUpgradeSeasonKey and lv.GetActiveUpgradeSeasonKey() or nil
    for _, run in ipairs(runs) do
        local completedAt = run.endTime or run.startTime or 0
        local include = filter == "all"
        if filter == "week" then
            include = completedAt >= weeklyReset
        elseif filter == "season" then
            include = (currentSeasonID and tonumber(run.mplusSeasonID) == currentSeasonID)
                or (not run.mplusSeasonID and run.contentSeasonKey and run.contentSeasonKey == contentSeasonKey)
        end
        if include then out[#out + 1] = run end
    end
    return out
end

local function GetMPlusResultText(run)
    if run.onTime == true then
        local upgrades = tonumber(run.keystoneUpgradeLevels) or 0
        return upgrades > 0 and string.format("%s +%d", T("STATUS_TIMED", "Timed"), upgrades) or T("STATUS_TIMED", "Timed")
    elseif run.onTime == false then
        return T("STATUS_DEPLETED", "Depleted")
    end
    return T("LABEL_NOT_AVAILABLE", "--")
end

local function GetMPlusDurationSeconds(run)
    if tonumber(run.mplusTimeMS) then return tonumber(run.mplusTimeMS) / 1000 end
    return tonumber(run.duration) or 0
end

local function GetMPlusRewardText(run)
    local parts = {}
    local money = tonumber(run.rewardMoney) or tonumber(run.gold) or 0
    if money > 0 then parts[#parts + 1] = GetCoinTextureString(money, 11) end
    local crestText = BuildRunCrestGainText(run)
    if crestText then parts[#parts + 1] = BuildRunCrestGainText(run, true) end
    return table.concat(parts, " ")
end

local function ShowMPlusRunTooltip(row)
    local run = row and row.run
    if not run then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(run.challengeMapName or run.name or UNKNOWN, 1, 0.82, 0)
    local characterName = GetRunCharacterName(run)
    if characterName then GameTooltip:AddLine(characterName, 1, 1, 1) end
    if run.endTime then GameTooltip:AddLine(date("%x", run.endTime), 0.8, 0.8, 0.8) end
    GameTooltip:AddDoubleLine(T("LABEL_KEY", "Key"), run.keystoneLevel and ("+" .. run.keystoneLevel) or T("TEXT_HISTORICAL_DATA_UNAVAILABLE", "Historical data unavailable"))
    GameTooltip:AddDoubleLine(T("LABEL_RESULT", "Result"), run.onTime == nil and T("TEXT_HISTORICAL_DATA_UNAVAILABLE", "Historical data unavailable") or GetMPlusResultText(run))
    local duration = GetMPlusDurationSeconds(run)
    GameTooltip:AddDoubleLine(run.mplusTimeMS and T("LABEL_TIME", "Time") or T("LABEL_RECORDED_DURATION", "Recorded duration"), lv.Stats.FormatDuration(duration))
    if run.mplusTimeMS and run.challengeTimeLimit then
        local limit = tonumber(run.challengeTimeLimit)
        GameTooltip:AddDoubleLine(T("LABEL_TIMER", "Timer"), string.format("%s / %s", lv.Stats.FormatDuration(duration), lv.Stats.FormatDuration(limit)))
        local delta = math.abs(limit - duration)
        GameTooltip:AddDoubleLine(duration <= limit and T("LABEL_TIME_REMAINING", "Time Remaining") or T("LABEL_OVER_TIMER", "Over Timer"), lv.Stats.FormatDuration(delta))
    end
    if run.oldOverallDungeonScore and run.newOverallDungeonScore then
        GameTooltip:AddDoubleLine(T("LABEL_MPLUS_SCORE_PLAIN", "M+ Score"), string.format("%d -> %d (%+d)", run.oldOverallDungeonScore, run.newOverallDungeonScore, run.ratingChange or 0))
    end
    if run.isMapRecord then GameTooltip:AddLine(T("LABEL_MAP_RECORD", "Map Record"), 0.3, 1, 0.3) end
    if run.isAffixRecord then GameTooltip:AddLine(T("LABEL_AFFIX_RECORD", "Affix Record"), 0.3, 1, 0.3) end
    local rewards = GetMPlusRewardText(run)
    if rewards ~= "" then GameTooltip:AddLine(string.format(T("TOOLTIP_REWARDS_FMT"), rewards), 0.9, 0.9, 0.9, true) end
    GameTooltip:Show()
end

local function GetAPIRGB(color, fallback)
    if color and color.GetRGB then
        local r, g, b = color:GetRGB()
        if r and g and b then return r, g, b end
    end
    return unpack(fallback or {1, 0.82, 0})
end

local function GetCurrentSeasonBestRows()
    local rows = {}
    local pool = lv.MPlusPlanner and lv.MPlusPlanner.GetCurrentMapPool and lv.MPlusPlanner.GetCurrentMapPool() or {}
    for _, map in ipairs(pool) do
        local challengeMapID = map.mapChallengeModeID
        if map.name then
            local intimeInfo, overtimeInfo
            if C_MythicPlus and C_MythicPlus.GetSeasonBestForMap then
                intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(challengeMapID)
            end
            local best, onTime = intimeInfo, true
            if not best and overtimeInfo then best, onTime = overtimeInfo, false end
            rows[#rows + 1] = {
                challengeMapID=challengeMapID, name=map.name, timeLimit=map.timeLimit,
                texture=map.texture, best=best, onTime=best and onTime or nil,
                dungeonScore=best and tonumber(best.dungeonScore) or nil,
            }
        end
    end
    local lowestCompleted
    for _, row in ipairs(rows) do
        if row.dungeonScore and (not lowestCompleted or row.dungeonScore < lowestCompleted.dungeonScore) then lowestCompleted = row end
    end
    table.sort(rows, function(a, b) return (a.dungeonScore or -1) < (b.dungeonScore or -1) end)
    for _, row in ipairs(rows) do row.isLowestScore = row == lowestCompleted end
    return rows
end

local function FormatSeasonBestDate(completionDate)
    if type(completionDate) ~= "table" then return nil end
    local month, day, year = completionDate.month, completionDate.day, completionDate.year
    if not (month and day and year) then return nil end
    return string.format("%02d/%02d/%02d", month, day, year % 100)
end

local function ShowSeasonBestTooltip(row)
    local data = row and row.data
    if not data then return end
    GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
    GameTooltip:SetText(data.name, 1, 0.82, 0)
    if data.best then
        GameTooltip:AddDoubleLine(T("LABEL_BEST", "Best"), "+" .. (data.best.level or 0))
        GameTooltip:AddDoubleLine(T("LABEL_RESULT", "Result"), data.onTime and T("STATUS_TIMED", "Timed") or T("STATUS_DEPLETED", "Depleted"))
        GameTooltip:AddDoubleLine(T("LABEL_TIME", "Time"), lv.Stats.FormatDuration(data.best.durationSec or 0))
        if data.timeLimit then
            GameTooltip:AddDoubleLine(T("LABEL_TIMER", "Timer"), string.format("%s / %s", lv.Stats.FormatDuration(data.best.durationSec or 0), lv.Stats.FormatDuration(data.timeLimit)))
            local delta = math.abs(data.timeLimit - (data.best.durationSec or 0))
            GameTooltip:AddDoubleLine(data.onTime and T("LABEL_TIME_REMAINING", "Time Remaining") or T("LABEL_OVER_TIMER", "Over Timer"), lv.Stats.FormatDuration(delta))
        end
        GameTooltip:AddDoubleLine(T("LABEL_SCORE", "Score"), tostring(data.dungeonScore or 0))
        local completed = FormatSeasonBestDate(data.best.completionDate)
        if completed then GameTooltip:AddDoubleLine(T("LABEL_DATE", "Date"), completed) end
        if data.isLowestScore then GameTooltip:AddLine(T("LABEL_LOWEST_SCORE", "Lowest Score"), 1, 0.82, 0) end
    else
        GameTooltip:AddLine(T("LABEL_NO_RUN", "No Run"), 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
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
    lv.EnsureBorderStyle(panel, "panel")

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
    mplusBtn.Text:SetText(T("LABEL_MYTHIC_PLUS"))
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
        GameTooltip:SetText(T("TITLE_MOUNT_DROPS"), 1, 0.82, 0)
        for _, m in ipairs(self.mountEntries) do
            if m.collected then
                GameTooltip:AddLine("|cff00ff00" .. string.format(T("TOOLTIP_MOUNT_COLLECTED_FMT"), m.name) .. "|r")
            else
                GameTooltip:AddLine("|cffff4040" .. string.format(T("TOOLTIP_MOUNT_UNCOLLECTED_FMT"), m.name) .. "|r")
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
    widgets.mplusBox, widgets.mplusTitle = CreateSection(-42, 132, "")
    widgets.mplusCharacterLabel = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.mplusCharacterLabel:SetPoint("TOPLEFT", 12, -27)
    widgets.mplusCharacter = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.mplusCharacter:SetPoint("TOPLEFT", 12, -41)
    widgets.mplusCurrentKeyLabel = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.mplusCurrentKeyLabel:SetPoint("TOPLEFT", 12, -92)
    widgets.mplusCurrentKey = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    widgets.mplusCurrentKey:SetPoint("TOPLEFT", 12, -106)
    widgets.mplusScoreLabel = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    widgets.mplusScoreLabel:SetPoint("TOPLEFT", 12, -60)
    widgets.mplusScoreBadge = CreateFrame("Frame", nil, widgets.mplusBox, "BackdropTemplate")
    widgets.mplusScoreBadge:SetPoint("TOPLEFT", 105, -56)
    widgets.mplusScoreBadge:SetSize(86, 30)
    widgets.mplusScoreBadge:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    widgets.mplusScore = widgets.mplusScoreBadge:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    widgets.mplusScore:SetPoint("CENTER")
    widgets.mplusPlanButton = CreateFrame("Button", nil, widgets.mplusBox, "BackdropTemplate")
    widgets.mplusPlanButton:SetPoint("TOPLEFT", 205, -60); widgets.mplusPlanButton:SetSize(100, 22)
    widgets.mplusPlanButton:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10,insets={left=2,right=2,top=2,bottom=2}})
    widgets.mplusPlanButton.Text=widgets.mplusPlanButton:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); widgets.mplusPlanButton.Text:SetPoint("CENTER")
    widgets.mplusPlanButton:SetScript("OnClick",function()
        mplusPlannerMode=true
        if widgets.plannerResults then widgets.plannerResults:SetText("") end
        if widgets.plannerMessage then widgets.plannerMessage:SetText("") end
        if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end
    end)
    widgets.mplusWarbandTitle = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widgets.mplusWarbandTitle:SetPoint("TOPLEFT", 335, -28)
    widgets.mplusWeekStatLabels = {}
    widgets.mplusWeekStats = {}
    for i, point in ipairs({{335,-50},{500,-50},{335,-78},{500,-78}}) do
        local label = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", point[1], point[2]); label:SetWidth(155); label:SetJustifyH("LEFT")
        local stat = widgets.mplusBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        stat:SetPoint("TOPLEFT", point[1], point[2] - 14); stat:SetWidth(155); stat:SetJustifyH("LEFT")
        widgets.mplusWeekStatLabels[i] = label
        widgets.mplusWeekStats[i] = stat
    end

    widgets.mplusSeasonBox, widgets.mplusSeasonTitle = CreateSection(-180, 188, "")
    widgets.mplusSeasonSubtitle = widgets.mplusSeasonBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.mplusSeasonSubtitle:SetPoint("TOPRIGHT", -12, -8)
    widgets.mplusSeasonHeaders = {}
    local seasonHeaderSpecs = {{10,270,"LEFT","LABEL_DUNGEON","Dungeon"},{284,48,"CENTER","LABEL_BEST","Best"},{336,82,"CENTER","LABEL_RESULT","Result"},{422,72,"CENTER","LABEL_TIME","Time"},{498,70,"CENTER","LABEL_SCORE","Score"}}
    for i, spec in ipairs(seasonHeaderSpecs) do
        local header = widgets.mplusSeasonBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", spec[1], -25); header:SetWidth(spec[2]); header:SetJustifyH(spec[3])
        header:SetText(T(spec[4], spec[5])); widgets.mplusSeasonHeaders[i] = {fontString=header, key=spec[4], fallback=spec[5]}
    end
    widgets.mplusSeasonRows = {}
    for i = 1, 8 do
        local row = CreateFrame("Button", nil, widgets.mplusSeasonBox, "BackdropTemplate")
        row:SetPoint("TOPLEFT", 10, -42 - ((i - 1) * 17))
        row:SetSize(GetPanelContentWidth() - 20, 16)
        row:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
        row.cells = {}
        local seasonColumns = {{0,270,"LEFT"},{274,48,"CENTER"},{326,82,"CENTER"},{412,72,"CENTER"},{488,70,"CENTER"}}
        for columnIndex, spec in ipairs(seasonColumns) do
            local cell = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            cell:SetPoint("LEFT", spec[1], 0); cell:SetWidth(spec[2]); cell:SetJustifyH(spec[3]); cell:SetWordWrap(false)
            row.cells[columnIndex] = cell
        end
        row:SetScript("OnEnter", ShowSeasonBestTooltip)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        widgets.mplusSeasonRows[i] = row
    end

    widgets.mplusRecentBox, widgets.mplusRecentTitle = CreateSection(-374, 180, "")
    widgets.mplusFilterButtons = {}
    for i, filter in ipairs({
        {key="week", label="FILTER_THIS_WEEK"}, {key="season", label="FILTER_SEASON"}, {key="all", label="FILTER_ALL_HISTORY"},
    }) do
        local button = CreateFrame("Button", nil, widgets.mplusRecentBox, "BackdropTemplate")
        button:SetSize(105, 22)
        button:SetPoint("TOPLEFT", 10 + ((i - 1) * 112), -24)
        button:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=10, insets={left=2,right=2,top=2,bottom=2}})
        button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.Text:SetPoint("CENTER")
        button.filterKey = filter.key
        button.labelKey = filter.label
        button:SetScript("OnClick", function(self) mplusHistoryFilter = self.filterKey; lv.UpdateInstancePanel() end)
        button:SetScript("OnEnter", function(self)
            local theme = lv.GetTheme()
            self:SetBackdropColor(unpack(theme.buttonBgHover or theme.buttonBg))
            self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
            self.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        button:SetScript("OnLeave", function(self)
            local theme = lv.GetTheme()
            local active = self.filterKey == mplusHistoryFilter
            self:SetBackdropColor(unpack(active and (theme.buttonBgActive or theme.buttonBgHover or theme.buttonBg) or theme.buttonBg))
            self:SetBackdropBorderColor(unpack(active and (theme.borderHover or theme.borderPrimary) or theme.borderPrimary))
            self.Text:SetTextColor(unpack(active and theme.textPrimary or theme.textSecondary))
        end)
        widgets.mplusFilterButtons[i] = button
    end
    widgets.mplusHeaderRow = CreateFrame("Frame", nil, widgets.mplusRecentBox)
    widgets.mplusHeaderRow:SetPoint("TOPLEFT", 12, -47)
    widgets.mplusHeaderRow:SetSize(GetPanelContentWidth() - 26, 16)
    widgets.mplusHeaders = {}
    for columnIndex, column in ipairs(MPLUS_HISTORY_COLUMNS) do
        local header = widgets.mplusHeaderRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ApplyMPlusColumnGeometry(header, column)
        header:SetText(T(column.key, column.fallback))
        widgets.mplusHeaders[columnIndex] = header
    end
    widgets.mplusRecentScroll = CreateFrame("ScrollFrame", nil, widgets.mplusRecentBox)
    widgets.mplusRecentScroll:SetPoint("TOPLEFT", 10, -68)
    widgets.mplusRecentScroll:SetPoint("BOTTOMRIGHT", -10, 8)
    widgets.mplusRecentScroll:EnableMouseWheel(true)
    widgets.mplusRecentContent = CreateFrame("Frame", nil, widgets.mplusRecentScroll)
    widgets.mplusRecentContent:SetPoint("TOPLEFT")
    widgets.mplusRecentContent:SetSize(GetPanelContentWidth() - 24, 1)
    widgets.mplusRecentScroll:SetScrollChild(widgets.mplusRecentContent)
    widgets.mplusRecentRows = {}
    for i = 1, 20 do
        local row = CreateFrame("Button", nil, widgets.mplusRecentContent, "BackdropTemplate")
        row:SetPoint("TOPLEFT", 2, -2 - ((i - 1) * 24))
        row:SetSize(GetPanelContentWidth() - 26, 23)
        row.columns = {}
        for columnIndex, column in ipairs(MPLUS_HISTORY_COLUMNS) do
            local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            ApplyMPlusColumnGeometry(fs, column)
            row.columns[columnIndex] = fs
        end
        row:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
        row.rowIndex = i
        row:SetScript("OnEnter", function(self)
            local theme = lv.GetTheme()
            ApplyMPlusHistoryRowTheme(self, theme, true)
            ShowMPlusRunTooltip(self)
        end)
        row:SetScript("OnLeave", function(self)
            ApplyMPlusHistoryRowTheme(self, lv.GetTheme(), false)
            GameTooltip:Hide()
        end)
        widgets.mplusRecentRows[i] = row
    end
    widgets.mplusRecentScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll() or 0
        local step = 24
        local maxScroll = math.max(0, (widgets.mplusRecentContent:GetHeight() or 0) - (self:GetHeight() or 0))
        local nextScroll = current - (delta * step)
        if nextScroll < 0 then nextScroll = 0 end
        if nextScroll > maxScroll then nextScroll = maxScroll end
        self:SetVerticalScroll(nextScroll)
    end)

    -- Production Mythic+ Rating Planner (transient; no SavedVariables).
    widgets.mplusPlannerBox, widgets.mplusPlannerTitle = CreateSection(-180, 400, "")
    local function PlannerButton(parent, width)
        local button=CreateFrame("Button",nil,parent,"BackdropTemplate"); button:SetSize(width,22)
        button:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=10,insets={left=2,right=2,top=2,bottom=2}})
        button.Text=button:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); button.Text:SetPoint("CENTER")
        return button
    end
    local function PlannerInput(x, width, default)
        local edit=CreateFrame("EditBox",nil,widgets.mplusPlannerBox,"InputBoxTemplate")
        edit:SetPoint("TOPLEFT",x,-48); edit:SetSize(width,22); edit:SetAutoFocus(false); edit:SetNumeric(true); edit:SetMaxLetters(5); edit:SetText(default or "")
        return edit
    end
    widgets.plannerBack=PlannerButton(widgets.mplusPlannerBox,130); widgets.plannerBack:SetPoint("TOPRIGHT",-10,-8)
    widgets.plannerBack:SetScript("OnClick",function() mplusPlannerMode=false; if lv.UpdateInstancePanel then lv.UpdateInstancePanel() end end)
    widgets.plannerCurrentLabel=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); widgets.plannerCurrentLabel:SetPoint("TOPLEFT",12,-30)
    widgets.plannerCurrent=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontHighlight"); widgets.plannerCurrent:SetPoint("TOPLEFT",12,-49)
    widgets.plannerTargetLabel=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); widgets.plannerTargetLabel:SetPoint("TOPLEFT",120,-30)
    widgets.plannerTarget=PlannerInput(120,90,"")
    widgets.plannerMinLabel=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); widgets.plannerMinLabel:SetPoint("TOPLEFT",235,-30)
    widgets.plannerMin=PlannerInput(235,70,"2")
    widgets.plannerMaxLabel=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); widgets.plannerMaxLabel:SetPoint("TOPLEFT",330,-30)
    widgets.plannerMax=PlannerInput(330,70,"15")
    widgets.plannerAvoidTitle=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontNormalSmall"); widgets.plannerAvoidTitle:SetPoint("TOPLEFT",12,-78)
    widgets.plannerAvoidButtons={}
    for i=1,8 do
        local button=PlannerButton(widgets.mplusPlannerBox,310)
        button:SetPoint("TOPLEFT",12+(((i-1)%2)*323),-96-(math.floor((i-1)/2)*25))
        button:SetScript("OnClick",function(self)
            if self.mapID then mplusPlannerAvoided[self.mapID]=not mplusPlannerAvoided[self.mapID]; lv.UpdateInstancePanel() end
        end)
        widgets.plannerAvoidButtons[i]=button
    end
    widgets.plannerCalculate=PlannerButton(widgets.mplusPlannerBox,130); widgets.plannerCalculate:SetPoint("TOPLEFT",12,-198)
    widgets.plannerMessage=widgets.mplusPlannerBox:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); widgets.plannerMessage:SetPoint("LEFT",widgets.plannerCalculate,"RIGHT",10,0); widgets.plannerMessage:SetWidth(490); widgets.plannerMessage:SetJustifyH("LEFT")
    widgets.plannerResultsScroll=CreateFrame("ScrollFrame",nil,widgets.mplusPlannerBox)
    widgets.plannerResultsScroll:SetPoint("TOPLEFT",10,-228); widgets.plannerResultsScroll:SetPoint("BOTTOMRIGHT",-10,8); widgets.plannerResultsScroll:EnableMouseWheel(true)
    widgets.plannerResultsContent=CreateFrame("Frame",nil,widgets.plannerResultsScroll); widgets.plannerResultsContent:SetPoint("TOPLEFT"); widgets.plannerResultsContent:SetSize(GetPanelContentWidth()-32,1)
    widgets.plannerResults=widgets.plannerResultsContent:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    widgets.plannerResults:SetPoint("TOPLEFT"); widgets.plannerResults:SetWidth(GetPanelContentWidth()-32); widgets.plannerResults:SetJustifyH("LEFT"); widgets.plannerResults:SetJustifyV("TOP")
    widgets.plannerResultsScroll:SetScrollChild(widgets.plannerResultsContent)
    widgets.plannerResultsScroll:SetScript("OnMouseWheel",function(self,delta)local max=math.max(0,(widgets.plannerResults:GetHeight() or 0)-(self:GetHeight() or 0)); self:SetVerticalScroll(math.max(0,math.min(max,(self:GetVerticalScroll() or 0)-(delta*36)))) end)
    local function RenderPlannerResult(result)
        widgets.plannerMessage:SetText("")
        if not result or result.status~="ok" then
            local key=result and (result.status=="alreadyReached" and "TEXT_PLANNER_ALREADY_REACHED" or result.status=="unreachable" and "TEXT_PLANNER_UNREACHABLE" or result.status=="invalidMinimum" and "TEXT_PLANNER_INVALID_MINIMUM" or result.status=="invalidMaximum" and "TEXT_PLANNER_INVALID_MAXIMUM" or "TEXT_PLANNER_INVALID_TARGET")
            widgets.plannerMessage:SetText(T(key or "TEXT_PLANNER_INVALID_TARGET"))
            if result and result.status=="alreadyReached" then
                widgets.plannerResults:SetText(string.format("%s: %d\n%s: %d",T("LABEL_CURRENT_RATING","Current Rating"),result.current,T("LABEL_TARGET_RATING","Target Rating"),result.target))
            else
                widgets.plannerResults:SetText(result and result.maximumProjected and string.format("%s: ~%d",T("LABEL_MAXIMUM_PROJECTED_RATING","Maximum Projected Rating"),result.maximumProjected) or "")
            end
            widgets.plannerResultsContent:SetHeight(math.max(1,widgets.plannerResults:GetStringHeight() or 1)); return
        end
        local grouped, order={},{}
        for _, strategy in ipairs({"fastest","balanced","easiest"}) do
            local route=result.routes[strategy]; local signature=lv.MPlusPlanner.RouteSignature(route.route)
            if not grouped[signature] then grouped[signature]={route=route,labels={}}; order[#order+1]=signature end
            grouped[signature].labels[#grouped[signature].labels+1]=T("PLANNER_"..string.upper(strategy),string.upper(strategy))
        end
        local lines={string.format("%s: %d    %s: %d",T("LABEL_CURRENT_RATING","Current Rating"),result.current,T("LABEL_TARGET_RATING","Target Rating"),result.target),""}
        for _, signature in ipairs(order) do
            local group=grouped[signature]; local route=group.route
            lines[#lines+1]="|cffd4af37"..table.concat(group.labels," / ").."|r"
            lines[#lines+1]=string.format("%d %s    %s: ~%d",route.runCount,T("LABEL_RUNS","Runs"),T("LABEL_PROJECTED_RATING","Projected Rating"),result.current+route.gain)
            lines[#lines+1]=string.format("%s    %s    %s    %s",T("LABEL_DUNGEON","Dungeon"),T("LABEL_CURRENT","Current"),T("LABEL_PLAN","Plan"),T("LABEL_GAIN","Gain"))
            for _,entry in ipairs(route.route) do lines[#lines+1]=string.format("%s    %d    +%d %s    |cff40ff40+%d|r",entry.dungeon.name,entry.dungeon.dungeonScore,entry.level,T("STATUS_TIMED","Timed"),entry.gain) end
            lines[#lines+1]=""
        end
        lines[#lines+1]="|cff888888"..T("TEXT_PLANNER_TIMED_ASSUMPTION","Projection assumes each suggested key is completed in time.").."|r"
        widgets.plannerResults:SetText(table.concat(lines,"\n"))
        widgets.plannerResultsContent:SetHeight(math.max(1,widgets.plannerResults:GetStringHeight() or 1))
    end
    widgets.renderPlannerResult=RenderPlannerResult
    widgets.plannerCalculate:SetScript("OnClick",function()
        local result=lv.MPlusPlanner.Calculate(widgets.plannerTarget:GetText(),widgets.plannerMin:GetText(),widgets.plannerMax:GetText(),mplusPlannerAvoided)
        RenderPlannerResult(result)
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
        lv.ApplyBorderStyle(panel, "panel", t)
        widgets.mplusBtn:SetBackdropColor(unpack(t.buttonBg))
        widgets.mplusBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        widgets.mplusBtn.Text:SetTextColor(unpack(t.textSecondary))
        for _, boxName in ipairs({ "capBox", "currentBox", "perfBox", "legacyBox", "recentBox", "mplusBox", "mplusSeasonBox", "mplusRecentBox", "mplusPlannerBox" }) do
            local box = widgets[boxName]
            box:SetBackdropColor(unpack(t.backgroundAlt or t.background))
            box:SetBackdropBorderColor(unpack(t.borderPrimary))
        end
        for _, button in ipairs({widgets.mplusPlanButton,widgets.plannerBack,widgets.plannerCalculate}) do button:SetBackdropColor(unpack(t.buttonBg)); button:SetBackdropBorderColor(unpack(t.borderPrimary)) end
        for _, header in ipairs(widgets.mplusHeaders or {}) do header:SetTextColor(unpack(t.textSecondary)) end
        for _, button in ipairs(widgets.mplusFilterButtons or {}) do
            local active = button.filterKey == mplusHistoryFilter
            button:SetBackdropColor(unpack(active and (t.buttonBgActive or t.buttonBgHover or t.buttonBg) or t.buttonBg))
            button:SetBackdropBorderColor(unpack(active and (t.borderHover or t.borderPrimary) or t.borderPrimary))
            button.Text:SetTextColor(unpack(active and t.textPrimary or t.textSecondary))
        end
        for _, row in ipairs(widgets.mplusRecentRows or {}) do
            ApplyMPlusHistoryRowTheme(row, t, false)
            for columnIndex, column in ipairs(row.columns or {}) do
                if columnIndex ~= 3 or not row.run then column:SetTextColor(unpack(t.textPrimary)) end
            end
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

    widgets.title:SetText(T("TITLE_INSTANCE_TRACKER"))
    local t = lv.GetTheme()
    if currentTab == "instances" then
        widgets.mplusBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        widgets.mplusBtn:SetBackdropColor(unpack(t.buttonBg))
        widgets.mplusBtn.Text:SetTextColor(unpack(t.textSecondary))
        widgets.mplusBtn.Text:SetText(T("LABEL_MYTHIC_PLUS"))
    else
        widgets.mplusBtn:SetBackdropBorderColor(unpack(t.borderHover))
        widgets.mplusBtn:SetBackdropColor(unpack(t.buttonBgHover))
        widgets.mplusBtn.Text:SetTextColor(unpack(t.textPrimary))
        widgets.mplusBtn.Text:SetText(T("BUTTON_BACK"))
    end

    widgets.capTitle:SetText(T("SECTION_INSTANCE_CAP"))
    local capCount = (lv.InstanceCap and lv.InstanceCap.GetCurrentCount and lv.InstanceCap.GetCurrentCount()) or 0
    local capStatus = (lv.InstanceCap and lv.InstanceCap.GetStatus and lv.InstanceCap.GetStatus()) or "SAFE"
    local slotIn = (lv.InstanceCap and lv.InstanceCap.GetTimeUntilSlot and lv.InstanceCap.GetTimeUntilSlot()) or 0
    widgets.capCurrent:SetText(string.format(T("LABEL_CAP_CURRENT"), capCount))
    widgets.capStatus:SetText(string.format(T("LABEL_CAP_STATUS"), T("STATUS_" .. capStatus, capStatus)))
    widgets.capNext:SetText(string.format(T("LABEL_NEXT_SLOT"), FormatSlotTimer(slotIn)))

    if capStatus == "LOCKED" then
        widgets.capStatus:SetTextColor(1.0, 0.2, 0.2)
    elseif capStatus == "WARNING" then
        widgets.capStatus:SetTextColor(1.0, 0.82, 0.2)
    else
        widgets.capStatus:SetTextColor(0.35, 0.9, 0.35)
    end

    widgets.currentTitle:SetText(T("SECTION_CURRENT_RUN"))
    local current = lv.InstanceTracker and lv.InstanceTracker.GetCurrentRun and lv.InstanceTracker.GetCurrentRun() or nil
    if current then
        widgets.currentName:SetText(string.format("%s (%s)", current.name or UNKNOWN, current.difficultyName or ""))
        local seconds = time() - (current.startTime or time())
        widgets.currentDuration:SetText(string.format(T("LABEL_DURATION"), lv.Stats.FormatDuration(seconds)))
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
                    widgets.currentMounts:SetText(string.format("%s" .. T("LABEL_MOUNTS_FMT") .. "|r", color, mountStatus.owned, mountStatus.total))
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
        widgets.currentName:SetText(T("LABEL_NOT_IN_INSTANCE"))
        widgets.currentDuration:SetText(string.format(T("LABEL_DURATION"), lv.Stats.FormatDuration(0)))
        widgets.currentMountsBtn.mountEntries = nil
        widgets.currentMounts:SetText("")
        widgets.currentMountIcon:Hide()
    end

    widgets.perfTitle:SetText(T("SECTION_PERFORMANCE"))
    local dCount = lv.Stats.GetTodayRuns("dungeon")
    local rCount = lv.Stats.GetTodayRuns("raid")
    local dAvg = lv.Stats.GetAverageTime("dungeon")
    local rAvg = lv.Stats.GetAverageTime("raid")
    widgets.dungeonsToday:SetText(string.format(T("LABEL_DUNGEONS_TODAY"), dCount))
    widgets.raidsToday:SetText(string.format(T("LABEL_RAIDS_TODAY"), rCount))
    widgets.avgDungeon:SetText(string.format(T("LABEL_AVG_TIME"), lv.Stats.FormatDuration(dAvg)))
    widgets.avgRaid:SetText(string.format(T("LABEL_AVG_TIME"), lv.Stats.FormatDuration(rAvg)))

    widgets.legacyTitle:SetText(T("SECTION_LEGACY_RAIDS"))
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
    widgets.legacyRuns:SetText(string.format(T("LABEL_LEGACY_RUNS"), legacyRuns))
    widgets.legacyGold:SetText(string.format(T("LABEL_GOLD_EARNED"), GetCoinTextureString(legacyGold)))
    widgets.legacyAvg:SetText(string.format(T("LABEL_AVG_TIME"), lv.Stats.FormatDuration(legacyAvg)))

    widgets.recentTitle:SetText(T("SECTION_RECENT_RUNS"))
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
                row.text:SetText(T("LABEL_NO_RECENT_RUNS"))
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
    widgets.mplusTitle:SetText(T("SECTION_MPLUS"))
    local playerData = LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY]
    local playerName = (lv.PLAYER_KEY and lv.PLAYER_KEY:match("^([^-]+)")) or UNKNOWN
    widgets.mplusCharacterLabel:SetText(T("LABEL_CURRENT_CHARACTER", "Current Character"))
    widgets.mplusCharacterLabel:SetTextColor(unpack(t.textSecondary))
    widgets.mplusCharacter:SetText(string.format("|c%s%s|r", GetClassColorHex(playerData and playerData.class), playerName))
    local key = playerData and playerData.currentKey
    if key and key.name and key.level then
        local keyTexture = key.texture
        if key.mapChallengeModeID and C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
            local _, _, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(key.mapChallengeModeID)
            keyTexture = texture or backgroundTexture or keyTexture
        end
        local icon = keyTexture and string.format("|T%s:20:20|t ", keyTexture) or ""
        widgets.mplusCurrentKey:SetText(string.format(icon .. "%s +%d", key.name, key.level))
    else
        widgets.mplusCurrentKey:SetText(T("LABEL_NO_MPLUS_KEY", "No M+ Key"))
    end
    widgets.mplusCurrentKeyLabel:SetText(T("LABEL_MPLUS_CURRENT_KEY"))
    widgets.mplusCurrentKeyLabel:SetTextColor(unpack(t.textSecondary))
    widgets.mplusCurrentKey:SetTextColor(unpack(t.textPrimary))
    local overallScore = 0
    if C_ChallengeMode and C_ChallengeMode.GetOverallDungeonScore then
        overallScore = tonumber(C_ChallengeMode.GetOverallDungeonScore()) or 0
    end
    widgets.mplusScoreLabel:SetText(T("LABEL_MPLUS_SCORE_PLAIN", "M+ Score"))
    widgets.mplusScoreLabel:SetTextColor(unpack(t.textSecondary))
    widgets.mplusScore:SetText(tostring(math.floor(overallScore + 0.5)))
    local scoreColor = C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor and C_ChallengeMode.GetDungeonScoreRarityColor(overallScore)
    local scoreR, scoreG, scoreB = GetAPIRGB(scoreColor, t.borderHover or t.borderPrimary)
    widgets.mplusScore:SetTextColor(scoreR, scoreG, scoreB)
    widgets.mplusScoreBadge:SetBackdropColor(unpack(t.backgroundAlt or t.background))
    widgets.mplusScoreBadge:SetBackdropBorderColor(scoreR, scoreG, scoreB, 0.45)
    widgets.mplusPlanButton.Text:SetText(T("BUTTON_PLAN_RATING","Plan Rating"))
    widgets.mplusPlanButton:SetBackdropColor(unpack(t.buttonBg)); widgets.mplusPlanButton:SetBackdropBorderColor(unpack(t.borderPrimary))

    local weekStart = lv.GetLastWeeklyReset and lv.GetLastWeeklyReset() or 0
    local weekRuns = GetMPlusRuns(weekStart)
    local timedCount, bestTimed = 0, nil
    local weeklyCrests = {}
    for _, run in ipairs(weekRuns) do
        if run.onTime == true then
            timedCount = timedCount + 1
            if run.keystoneLevel and (not bestTimed or run.keystoneLevel > bestTimed) then bestTimed = run.keystoneLevel end
        end
        for crestName, amount in pairs(run.crestGains or {}) do weeklyCrests[crestName] = (weeklyCrests[crestName] or 0) + (tonumber(amount) or 0) end
    end
    local crestSummary = BuildRunCrestGainText({crestGains=weeklyCrests}, true) or T("LABEL_NOT_AVAILABLE", "--")
    widgets.mplusWarbandTitle:SetText(T("LABEL_WARBAND_THIS_WEEK", "Warband This Week"))
    local weekLabels = {T("LABEL_RUNS", "Runs"), T("STATUS_TIMED", "Timed"), T("LABEL_BEST_TIMED", "Best Timed"), T("LABEL_CRESTS", "Crests")}
    for i, label in ipairs(weekLabels) do widgets.mplusWeekStatLabels[i]:SetText(label); widgets.mplusWeekStatLabels[i]:SetTextColor(unpack(t.textSecondary)); widgets.mplusWeekStats[i]:SetTextColor(unpack(t.textPrimary)) end
    widgets.mplusWeekStats[1]:SetText(tostring(#weekRuns))
    widgets.mplusWeekStats[2]:SetText(tostring(timedCount))
    widgets.mplusWeekStats[3]:SetText(bestTimed and ("+" .. bestTimed) or T("LABEL_NOT_AVAILABLE", "--"))
    widgets.mplusWeekStats[4]:SetText(crestSummary)

    widgets.mplusPlannerTitle:SetText(T("TITLE_MPLUS_RATING_PLANNER","Mythic+ Rating Planner"))
    widgets.plannerBack.Text:SetText(T("BUTTON_BACK_TO_DASHBOARD","Back to Dashboard"))
    widgets.plannerCurrentLabel:SetText(T("LABEL_CURRENT_RATING","Current Rating")); widgets.plannerCurrentLabel:SetTextColor(unpack(t.textSecondary)); widgets.plannerCurrent:SetText(tostring(overallScore))
    widgets.plannerTargetLabel:SetText(T("LABEL_TARGET_RATING","Target Rating")); widgets.plannerMinLabel:SetText(T("LABEL_MINIMUM_KEY","Minimum Key")); widgets.plannerMaxLabel:SetText(T("LABEL_MAXIMUM_KEY","Maximum Key"))
    widgets.plannerAvoidTitle:SetText(T("LABEL_AVOID_DUNGEONS","Avoid Dungeons")); widgets.plannerCalculate.Text:SetText(T("BUTTON_CALCULATE_PLAN","Calculate Plan"))
    local plannerPool=lv.MPlusPlanner and lv.MPlusPlanner.GetCurrentMapPool() or {}
    for i,button in ipairs(widgets.plannerAvoidButtons) do
        local dungeon=plannerPool[i]; button.mapID=dungeon and dungeon.mapChallengeModeID or nil
        if dungeon then
            local avoided=mplusPlannerAvoided[button.mapID]
            button.Text:SetText((avoided and "|cffff5050[x]|r " or "[ ] ")..dungeon.name)
            button:SetBackdropColor(unpack(avoided and (t.buttonBgHover or t.buttonBg) or t.buttonBg)); button:Show()
        else button:Hide() end
    end

    widgets.mplusSeasonTitle:SetText(T("SECTION_SEASON_BESTS", "Season Bests"))
    widgets.mplusSeasonSubtitle:SetText(string.format("|c%s%s|r", GetClassColorHex(playerData and playerData.class), playerName))
    for _, header in ipairs(widgets.mplusSeasonHeaders) do header.fontString:SetText(T(header.key, header.fallback)); header.fontString:SetTextColor(unpack(t.textSecondary)) end
    local seasonBests = GetCurrentSeasonBestRows()
    for i, row in ipairs(widgets.mplusSeasonRows) do
        local data = seasonBests[i]
        row.data = data
        if data then
            for _, cell in ipairs(row.cells) do cell:SetTextColor(unpack(t.textPrimary)) end
            local icon = data.texture and string.format("|T%s:14:14|t ", data.texture) or ""
            row.cells[1]:SetText((data.isLowestScore and "|cffffcc00!|r " or "") .. icon .. data.name)
            if data.best then
                row.cells[2]:SetText("+" .. (data.best.level or 0))
                local keyColor = C_ChallengeMode and C_ChallengeMode.GetKeystoneLevelRarityColor and C_ChallengeMode.GetKeystoneLevelRarityColor(data.best.level or 0)
                row.cells[2]:SetTextColor(GetAPIRGB(keyColor, t.textPrimary))
                row.cells[3]:SetText(data.onTime and T("STATUS_TIMED", "Timed") or T("STATUS_DEPLETED", "Depleted"))
                row.cells[3]:SetTextColor(data.onTime and 0.3 or 1, data.onTime and 1 or 0.3, 0.3)
                row.cells[4]:SetText(lv.Stats.FormatDuration(data.best.durationSec or 0))
                row.cells[5]:SetText(tostring(data.dungeonScore or 0))
                local dungeonScoreColor = C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor and C_ChallengeMode.GetDungeonScoreRarityColor(data.dungeonScore or 0)
                row.cells[5]:SetTextColor(GetAPIRGB(dungeonScoreColor, t.textPrimary))
            else
                local muted = t.textMuted or t.textSecondary
                row.cells[2]:SetText(T("LABEL_NOT_AVAILABLE", "--")); row.cells[2]:SetTextColor(unpack(muted))
                row.cells[3]:SetText(T("LABEL_NO_RUN", "No Run")); row.cells[3]:SetTextColor(unpack(muted))
                row.cells[4]:SetText(T("LABEL_NOT_AVAILABLE", "--")); row.cells[4]:SetTextColor(unpack(muted))
                row.cells[5]:SetText(T("LABEL_NOT_AVAILABLE", "--")); row.cells[5]:SetTextColor(unpack(muted))
            end
            row:SetBackdropColor(unpack((i % 2 == 0 and t.rowStripeEven or t.rowStripeOdd) or t.backgroundAlt or t.background))
            row:Show()
        else
            row.data = nil; row:Hide()
        end
    end

    widgets.mplusRecentTitle:SetText(T("SECTION_MPLUS_HISTORY", "Mythic+ History"))
    for columnIndex, column in ipairs(MPLUS_HISTORY_COLUMNS) do
        widgets.mplusHeaders[columnIndex]:SetText(T(column.key, column.fallback))
        widgets.mplusHeaders[columnIndex]:SetTextColor(unpack(t.textSecondary))
    end
    for _, button in ipairs(widgets.mplusFilterButtons or {}) do
        button.Text:SetText(T(button.labelKey))
        button:SetBackdropColor(unpack(button.filterKey == mplusHistoryFilter and (t.buttonBgHover or t.buttonBg) or t.buttonBg))
        button:SetBackdropBorderColor(unpack(button.filterKey == mplusHistoryFilter and (t.borderHover or t.borderPrimary) or t.borderPrimary))
        button.Text:SetTextColor(unpack(button.filterKey == mplusHistoryFilter and t.textPrimary or t.textSecondary))
    end
    local recentMPlus = GetFilteredMPlusRuns(mplusHistoryFilter)
    local shownM = 0
    for i = 1, 20 do
        local row = widgets.mplusRecentRows[i]
        local run = recentMPlus[i]
        if run then
            row.run = run
            for _, column in ipairs(row.columns) do column:SetTextColor(unpack(t.textPrimary)) end
            row.columns[1]:SetText(run.challengeMapName or run.name or UNKNOWN)
            if run.challengeMapID and C_ChallengeMode and C_ChallengeMode.GetMapUIInfo then
                local _, _, _, texture, backgroundTexture = C_ChallengeMode.GetMapUIInfo(run.challengeMapID)
                local iconTexture = texture or backgroundTexture
                if iconTexture then row.columns[1]:SetText(string.format("|T%s:14:14|t %s", iconTexture, run.challengeMapName or run.name or UNKNOWN)) end
            end
            row.columns[2]:SetText(run.keystoneLevel and ("+" .. run.keystoneLevel) or T("LABEL_NOT_AVAILABLE", "--"))
            row.columns[3]:SetText(GetMPlusResultText(run))
            if run.onTime == true then row.columns[3]:SetTextColor(0.3,1,0.3) elseif run.onTime == false then row.columns[3]:SetTextColor(1,0.3,0.3) else row.columns[3]:SetTextColor(unpack(t.textMuted or t.textSecondary)) end
            row.columns[4]:SetText(lv.Stats.FormatDuration(GetMPlusDurationSeconds(run)))
            local runChar = GetRunCharacterName(run) or T("LABEL_NOT_AVAILABLE", "--")
            row.columns[5]:SetText(string.format("|c%s%s|r", GetClassColorHex(GetRunCharacterClass(run)), runChar))
            row.columns[6]:SetText(run.endTime and date("%x", run.endTime) or T("LABEL_NOT_AVAILABLE", "--"))
            row.columns[7]:SetText(GetMPlusRewardText(run))
            ApplyMPlusHistoryRowTheme(row, t, false)
            row:Show()
            shownM = shownM + 1
        else
            if i == 1 then
                row.run = nil
                local emptyKey = mplusHistoryFilter == "week" and "TEXT_NO_MPLUS_RUNS_THIS_WEEK"
                    or (mplusHistoryFilter == "season" and "TEXT_NO_MPLUS_RUNS_THIS_SEASON" or "TEXT_NO_MPLUS_RUNS_RECORDED")
                row.columns[1]:SetText(T(emptyKey))
                row.columns[1]:SetTextColor(unpack(t.textMuted or t.textSecondary))
                for columnIndex=2,7 do row.columns[columnIndex]:SetText("") end
                ApplyMPlusHistoryRowTheme(row, t, false)
                row:Show()
                shownM = shownM + 1
            else
                row.run = nil
                row:Hide()
            end
        end
    end
    local mContentHeight = math.max((shownM * 24) + 4, widgets.mplusRecentScroll:GetHeight() or 1)
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
        widgets.mplusSeasonBox:SetShown(not showInstances and not mplusPlannerMode)
        widgets.mplusRecentBox:SetShown(not showInstances and not mplusPlannerMode)
        widgets.mplusPlannerBox:SetShown(not showInstances and mplusPlannerMode)
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
            tooltip:AddLine(T("SECTION_INSTANCE_CAP"))
            tooltip:AddLine(string.format(T("LABEL_CAP_CURRENT"), count))
            tooltip:AddLine(string.format(T("LABEL_CAP_STATUS"), T("STATUS_" .. status, status)))
        end
        tooltip:Show()
    end
end)
