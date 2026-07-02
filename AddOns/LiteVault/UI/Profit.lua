-- UI/Profit.lua
local addonName, lv = ...
local L = lv.L

-- Profit UI renders GoldTracker-backed transaction history and summaries.
-- Transaction capture and source classification live in GoldTracker.lua.
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

local function FormatGoldAligned(copperAmount, iconSize)
    return lv.FormatGoldAligned(copperAmount, iconSize)
end

local LVWindow = lv.LVWindow
local WeeklyBox = lv.WeeklyBox
local weeklyUI = lv.weeklyUI
local GetCurrentWeeklyQuestList = lv.GetCurrentWeeklyQuestList
local BuildWeeklyWarningText = lv.BuildWeeklyWarningText
local UpdateWeeklyWarningLayout = lv.UpdateWeeklyWarningLayout
local BuildWeeklyQuestText = lv.BuildWeeklyQuestText

local GoldBox = CreateFrame("Frame", nil, LVWindow, "BackdropTemplate")
GoldBox:SetSize(360, 218) -- Width matched to WeeklyBox (360)
GoldBox:SetPoint("TOP", WeeklyBox, "BOTTOM", 0, -6) -- Perfectly aligned with WeeklyBox
GoldBox:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14 })

-- Store reference for theming
lv.GoldBox = GoldBox

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(GoldBox, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundTransparent))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        GoldBox:SetBackdropColor(unpack(t.backgroundTransparent))
        GoldBox:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

local function CreateProfitPanel(parent, width, height)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(width, height)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    return panel
end

local function ApplyProfitPanelTheme(panel, theme)
    panel:SetBackdropColor(unpack(theme.buttonBgAlt or theme.backgroundTransparent or theme.background))
    panel:SetBackdropBorderColor(unpack(theme.borderSecondary or theme.borderPrimary))
end

local function ApplyProfitSummaryBoxTheme(panel, theme)
    panel:SetBackdropColor(unpack(theme.backgroundSolid or theme.buttonBg or theme.background))
    panel:SetBackdropBorderColor(unpack(theme.borderPrimary))
end

local function CreateProfitHeaderButton(parent, width, label)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, 22)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.Text:SetPoint("CENTER")
    button.Text:SetText(label or "")
    return button
end

local function FormatProfitGoalInputGold(copper)
    local gold = (tonumber(copper) or 0) / 10000
    local text = string.format("%.2f", gold)
    text = text:gsub("%.?0+$", "")
    return text
end

local function ParseProfitGoalGoldInput(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = text:gsub("[,%s]", ""):gsub("[gG]", "")
    if cleaned == "" then
        return 0
    end

    local amountGold = tonumber(cleaned)
    if not amountGold or amountGold < 0 then
        return nil
    end

    return math.floor((amountGold * 10000) + 0.5)
end

local function FormatProfitGoalPercentText(percent)
    local clamped = math.max(0, math.min(1, tonumber(percent) or 0))
    return string.format("%d%%", math.floor((clamped * 100) + 0.5))
end

local function CreateProfitEntryRow(parent, yOffset)
    local row = CreateProfitPanel(parent, 402, 54)
    row:SetPoint("TOPLEFT", 18, yOffset)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.name:SetPoint("TOPLEFT", 14, -11)
    row.name:SetJustifyH("LEFT")
    row.name:SetWidth(240)

    row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.gold:SetPoint("BOTTOMRIGHT", -14, 10)
    row.gold:SetWidth(144)
    row.gold:SetJustifyH("RIGHT")
    row.gold:SetWordWrap(false)
    if row.gold.SetNonSpaceWrap then
        row.gold:SetNonSpaceWrap(false)
    end

    return row
end

local function ConfigureProfitHiddenScroll(scrollFrame)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local step = 54
        local newScroll = current - (delta * step)
        self:SetVerticalScroll(math.max(0, math.min(newScroll, maxScroll)))
    end)
end

local function GetProfitListRow(pool, parent, index)
    if not pool[index] then
        local row = CreateProfitEntryRow(parent, 0)
        row:ClearAllPoints()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(row, ApplyProfitPanelTheme)
        end
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            ApplyProfitPanelTheme(row, t)
        end
        pool[index] = row
    end
    return pool[index]
end

local function GetStartOfDayTimestamp(timestamp)
    local d = date("*t", timestamp or time())
    d.hour, d.min, d.sec = 0, 0, 0
    return time(d)
end

local function GetStartOfMonthTimestamp(timestamp)
    local d = date("*t", timestamp or time())
    d.day, d.hour, d.min, d.sec = 1, 0, 0, 0
    return time(d)
end

local function GetCurrentProfitCharKey()
    return lv.PLAYER_KEY
end

local function BuildCurrentCharacterProfitOpts()
    return {
        charKey = GetCurrentProfitCharKey(),
        includeIgnored = true,
        region = nil,
    }
end

local function GetCharacterRecord(charKey)
    if not (LiteVaultDB and charKey) then
        return nil
    end
    local data = LiteVaultDB[charKey]
    return type(data) == "table" and data or nil
end

local function GetCharacterDisplayName(charKey)
    return (type(charKey) == "string" and charKey:match("^([^-]+)")) or charKey or "Unknown"
end

local function GetSourceDefinitions()
    return (lv.GetProfitSources and lv.GetProfitSources()) or {}
end

local function BuildSourceLabelMap()
    local labels = {}
    for _, source in ipairs(GetSourceDefinitions()) do
        if source and source.key then
            labels[source.key] = source.label or source.key
        end
    end
    return labels
end

local function GetTransactionsForPeriod(period, opts)
    if not lv.GetProfitTransactions then
        return {}
    end
    local query = {}
    for key, value in pairs(opts or {}) do
        query[key] = value
    end
    query.period = period
    return lv.GetProfitTransactions(query) or {}
end

local function GetSummaryForPeriod(period, opts)
    if not lv.GetProfitSummary then
        return {
            period = period,
            count = 0,
            income = 0,
            expense = 0,
            net = 0,
            transactions = {},
        }
    end
    return lv.GetProfitSummary(period, opts) or {
        period = period,
        count = 0,
        income = 0,
        expense = 0,
        net = 0,
        transactions = {},
    }
end

local function BuildProfitGraphBuckets(transactions, labels)
    local points = {}
    local buckets = {}
    for _, tx in ipairs(transactions or {}) do
        if tx and tx.timestamp and tx.amount then
            local bucketKey = labels.bucketFn(tx.timestamp)
            buckets[bucketKey] = (buckets[bucketKey] or 0) + tx.amount
        end
    end

    for _, entry in ipairs(labels.order) do
        points[#points + 1] = {
            label = entry.label,
            tooltipLabel = entry.tooltipLabel,
            value = buckets[entry.bucketKey] or 0,
        }
    end

    return points
end

local function FormatProfitGraphAmount(amount)
    amount = amount or 0
    if amount > 0 then
        return "|cff00ff00+" .. FormatGoldAligned(amount, 14) .. "|r"
    elseif amount < 0 then
        return "|cffff0000-" .. FormatGoldAligned(math.abs(amount), 14) .. "|r"
    end
    return FormatGoldAligned(0, 14)
end

local function GetLineAngle(dx, dy)
    if math.atan2 then
        return math.atan2(dy, dx)
    end
    if dx == 0 then
        return (dy >= 0) and (math.pi / 2) or (-math.pi / 2)
    end
    local angle = math.atan(dy / dx)
    if dx < 0 then
        angle = angle + math.pi
    end
    return angle
end

local function BuildWeeklyProfitGraphSeries(charKey)
    local now = time()
    local todayStart = GetStartOfDayTimestamp(now)
    local firstDay = todayStart - (6 * 86400)
    local transactions = GetTransactionsForPeriod("week", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    local labels = { order = {} }
    for i = 0, 6 do
        local dayStart = firstDay + (i * 86400)
        labels.order[#labels.order + 1] = {
            bucketKey = dayStart,
            label = date("%a", dayStart):sub(1, 3),
            tooltipLabel = date("%b %d", dayStart),
        }
    end
    labels.bucketFn = GetStartOfDayTimestamp
    local points = BuildProfitGraphBuckets(transactions, labels)

    return {
        title = UIText("LABEL_WEEKLY_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"),
        emptyText = UIText("TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"),
        points = points,
    }
end

local function BuildWarbandProfitGraphSeries()
    local now = time()
    local todayStart = GetStartOfDayTimestamp(now)
    local firstDay = todayStart - (6 * 86400)
    local transactions = GetTransactionsForPeriod("week")
    local labels = { order = {} }
    for i = 0, 6 do
        local dayStart = firstDay + (i * 86400)
        labels.order[#labels.order + 1] = {
            bucketKey = dayStart,
            label = date("%a", dayStart):sub(1, 3),
            tooltipLabel = date("%b %d", dayStart),
        }
    end
    labels.bucketFn = GetStartOfDayTimestamp
    local points = BuildProfitGraphBuckets(transactions, labels)

    return {
        title = UIText("LABEL_WARBAND_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"),
        emptyText = UIText("TEXT_PROFIT_GRAPH_EMPTY_WARBAND"),
        points = points,
    }
end

local function BuildWarbandMonthlyProfitGraphSeries()
    local now = time()
    local today = date("*t", now)
    local dayCount = today.day
    local transactions = GetTransactionsForPeriod("month")
    local labels = { order = {} }
    for day = 1, dayCount do
        local label = ((day == 1) or (day == dayCount) or (day % 5 == 0)) and tostring(day) or ""
        labels.order[#labels.order + 1] = {
            bucketKey = day,
            label = label,
            tooltipLabel = string.format("%s %d", date("%b", now), day),
        }
    end
    labels.bucketFn = function(timestamp)
        return date("*t", timestamp).day
    end
    local points = BuildProfitGraphBuckets(transactions, labels)
    local hasHistory = false
    for _, point in ipairs(points) do
        if (point.value or 0) ~= 0 then
            hasHistory = true
            break
        end
    end

    return {
        title = UIText("LABEL_WARBAND_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"),
        emptyText = hasHistory and UIText("TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY") or UIText("TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"),
        points = points,
    }
end

local function BuildMonthlyProfitGraphSeries(charKey)
    local now = time()
    local today = date("*t", now)
    local transactions = GetTransactionsForPeriod("month", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    local dayCount = today.day
    local labels = { order = {} }
    for day = 1, dayCount do
        local label = ((day == 1) or (day == dayCount) or (day % 5 == 0)) and tostring(day) or ""
        labels.order[#labels.order + 1] = {
            bucketKey = day,
            label = label,
            tooltipLabel = string.format("%s %d", date("%b", now), day),
        }
    end
    labels.bucketFn = function(timestamp)
        return date("*t", timestamp).day
    end
    local points = BuildProfitGraphBuckets(transactions, labels)
    local hasHistory = false
    for _, point in ipairs(points) do
        if (point.value or 0) ~= 0 then
            hasHistory = true
            break
        end
    end

    return {
        title = UIText("LABEL_MONTHLY_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"),
        emptyText = hasHistory and UIText("TEXT_PROFIT_GRAPH_EMPTY_MONTHLY") or UIText("TEXT_PROFIT_GRAPH_PENDING_MONTHLY"),
        points = points,
    }
end

local function GetProfitLedgerSourceName(key)
    for _, source in ipairs(GetSourceDefinitions()) do
        if source.key == key then
            return source.label or key
        end
    end
    return key or ""
end

local function GetProfitTokenDisplayText()
    local tokenInfo = lv.GetWowTokenInfo and lv.GetWowTokenInfo() or nil
    if not tokenInfo or not tokenInfo.supported or not tokenInfo.price then
        return UIText("MSG_WOW_TOKEN_VISIT_AH_SHORT"), tokenInfo
    end

    local gold = math.floor((tokenInfo.price or 0) / COPPER_PER_GOLD)
    return string.format("%s|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:2:0|t", BreakUpLargeNumbers(gold)), tokenInfo
end

local function FormatProfitTokenGoldOnly(copperAmount, iconSize)
    local gold = math.floor(math.max(0, tonumber(copperAmount) or 0) / COPPER_PER_GOLD)
    iconSize = iconSize or 14
    return string.format("%s|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0|t", BreakUpLargeNumbers(gold), iconSize, iconSize)
end

local function FormatProfitTokenGoldText(copperAmount)
    local gold = math.floor(math.max(0, tonumber(copperAmount) or 0) / COPPER_PER_GOLD)
    return string.format("%sg", BreakUpLargeNumbers(gold))
end

local function ShowProfitTokenTooltip(owner)
    local info = lv.GetWowTokenInfo and lv.GetWowTokenInfo() or nil
    GameTooltip:SetOwner(owner, "ANCHOR_TOP")
    GameTooltip:AddLine(UIText("TOOLTIP_WOW_TOKEN_TITLE"), 1, 0.82, 0)
    GameTooltip:AddLine(UIText("TOOLTIP_WOW_TOKEN_DESC"), 1, 1, 1, true)
    if not info or not info.supported then
        GameTooltip:AddLine(UIText("MSG_WOW_TOKEN_API_UNAVAILABLE"), 1, 0.3, 0.3, true)
    elseif not info.price then
        GameTooltip:AddLine(info.helpText or UIText("MSG_WOW_TOKEN_VISIT_AH"), 1, 1, 1, true)
    else
        GameTooltip:AddDoubleLine(UIText("LABEL_WOW_TOKEN"), FormatProfitTokenGoldOnly(info.price, 14), 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine(UIText("LABEL_LAST_UPDATED"), info.updatedText or UIText("LABEL_UNKNOWN"), 1, 1, 1, 0.82, 0.82, 0.82)
        if info.deltaText then
            GameTooltip:AddDoubleLine(UIText("LABEL_TOKEN_DELTA"), info.deltaText, 1, 1, 1, 1, 1, 1)
        end
        GameTooltip:AddDoubleLine(
            UIText("LABEL_TOKEN_AFFORDABLE"),
            info.canAfford and UIText("BUTTON_YES") or UIText("BUTTON_NO"),
            1, 1, 1,
            info.canAfford and 0.2 or 1,
            info.canAfford and 0.9 or 0.3,
            info.canAfford and 0.2 or 0.3
        )
        if info.stale then
            GameTooltip:AddLine(UIText("LABEL_TOKEN_STALE"), 1, 0.3, 0.3)
        end
    end
    GameTooltip:Show()
end

local function IsProfitAuctionFeeTransaction(trans)
    return trans and (trans.source == "ahFee" or (trans.source == "auction" and trans.detailName == "Fee"))
end

local function GetProfitAuctionFeeQuantitySuffix(detailText)
    if type(detailText) ~= "string" then
        return ""
    end
    return detailText:match("( x%d+)$") or ""
end

local function GetProfitGenericDetailFallback(trans)
    if not trans or not trans.source then
        return ""
    end
    if trans.source == "ahFee" then
        return UIText("TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT")
    elseif trans.source == "upgrade" then
        return UIText("TEXT_PROFIT_FALLBACK_GEAR_UPGRADE")
    elseif trans.source == "quest" then
        return UIText("TEXT_PROFIT_FALLBACK_GOLD_REWARD")
    elseif trans.source == "worldQuest" then
        return UIText("TEXT_PROFIT_FALLBACK_GOLD_REWARD")
    elseif trans.source == "mail" then
        return (tonumber(trans.amount) or 0) < 0
            and UIText("TEXT_PROFIT_FALLBACK_GOLD_SENT")
            or UIText("TEXT_PROFIT_FALLBACK_GOLD_RECEIVED")
    elseif trans.source == "auction" then
        return (tonumber(trans.amount) or 0) < 0
            and UIText("TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE")
            or UIText("TEXT_PROFIT_FALLBACK_AUCTION_SALE")
    elseif trans.source == "guildBank" then
        return (tonumber(trans.amount) or 0) < 0
            and UIText("TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT")
            or UIText("TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL")
    elseif trans.source == "trade" then
        return (tonumber(trans.amount) or 0) < 0
            and UIText("TEXT_PROFIT_FALLBACK_TRADE_PAYMENT")
            or UIText("TEXT_PROFIT_FALLBACK_TRADE_GAIN")
    elseif trans.source == "crafting" then
        return UIText("TEXT_PROFIT_FALLBACK_CRAFTING_ORDER")
    elseif trans.source == "loot" then
        return UIText("TEXT_PROFIT_FALLBACK_RAW_GOLD")
    elseif trans.source == "repair" then
        return UIText("TEXT_PROFIT_FALLBACK_SERVICE_COST")
    elseif trans.source == "training" then
        return UIText("TEXT_PROFIT_FALLBACK_TRAINING_COST")
    elseif trans.source == "transmog" then
        return UIText("TEXT_PROFIT_FALLBACK_APPEARANCE_COST")
    elseif trans.source == "flightpath" then
        return UIText("TEXT_PROFIT_FALLBACK_TRAVEL_COST")
    elseif trans.source == "barber" then
        return UIText("TEXT_PROFIT_FALLBACK_BARBER_COST")
    elseif trans.source == "blackMarket" then
        return UIText("TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE")
    end
    return GetProfitLedgerSourceName(trans.source)
end

local function IsProfitGenericSourceDetail(trans, detailName, sourceName, genericFallback)
    if type(detailName) ~= "string" or detailName == "" then
        return true
    end
    if detailName == sourceName or detailName == genericFallback then
        return true
    end
    if trans and trans.source == "worldQuest" and detailName == GetProfitLedgerSourceName("loot") then
        return true
    end
    if trans and trans.source == "loot" and detailName == GetProfitLedgerSourceName("loot") then
        return true
    end
    if not trans or not trans.source then
        return false
    end

    local genericNames = {
        mail = { Mail = true },
        auction = { Auction = true, ["Auction House"] = true },
        guildBank = { ["Guild Bank"] = true },
        trade = { Trade = true },
        crafting = { Craft = true, Crafting = true },
    }

    local names = genericNames[trans.source]
    return names and names[detailName] or false
end

local GetProfitLedgerDetailText

local function GetProfitLedgerSourceTag(trans)
    if not trans or not trans.source then
        return ""
    end
    if IsProfitAuctionFeeTransaction(trans) then
        return "AH Fee"
    end
    if trans.source == "auction" or trans.source == "ahFee" then
        return "AH"
    end
    return GetProfitLedgerSourceName(trans.source)
end

local function GetProfitLedgerDisplayTextFromLink(itemLink)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end
    local itemName = itemLink:match("%[(.-)%]")
    if not itemName or itemName == "" then
        return nil
    end

    local itemID = tonumber(itemLink:match("|Hitem:(%d+)"))
    local suffix = itemLink:match("|h|r(.*)$") or ""
    if itemID and GetItemInfo and GetItemQualityColor then
        local resolvedName, _, quality = GetItemInfo(itemID)
        if resolvedName and quality then
            local _, _, _, qualityHex = GetItemQualityColor(quality)
            if qualityHex and qualityHex ~= "" then
                return "|c" .. qualityHex .. "[" .. resolvedName .. "]|r" .. suffix
            end
        end
    end

    local colorCode = itemLink:match("(|c%x%x%x%x%x%x%x%x)")
    if colorCode then
        return colorCode .. "[" .. itemName .. "]|r" .. suffix
    end
    return "[" .. itemName .. "]" .. suffix
end

local function GetProfitLedgerResolvedItemLink(trans)
    if not trans then
        return nil
    end

    if type(trans.detailLink) == "string" and trans.detailLink:match("|Hitem:") then
        return trans.detailLink
    end

    local itemID = tonumber(trans.itemID)
    if itemID and itemID > 0 then
        local itemLink = nil
        if GetItemInfo then
            itemLink = select(2, GetItemInfo(itemID))
        end
        if (not itemLink or itemLink == "") and C_Item and C_Item.GetItemInfo then
            itemLink = select(2, C_Item.GetItemInfo(itemID))
        end
        if type(itemLink) == "string" and itemLink:match("|Hitem:") then
            return itemLink
        end
    end

    return nil
end

local function GetProfitVendorDetailDisplay(trans)
    if not trans then
        return ""
    end

    local itemLink = GetProfitLedgerResolvedItemLink(trans)
    local count = tonumber(trans.count) or 1
    if itemLink then
        local displayLink = GetProfitLedgerDisplayTextFromLink(itemLink) or itemLink
        return string.format("%dx %s", count, displayLink)
    end

    local detailName = trans.detailName
    if type(detailName) == "string" and detailName ~= "" then
        return string.format("%dx %s", count, detailName)
    end

    return GetProfitLedgerDetailText(trans)
end

local function GetProfitUpgradeDetailDisplay(trans)
    if not trans then
        return ""
    end
    return GetProfitGenericDetailFallback(trans)
end

local function GetProfitLedgerDetailDisplay(trans)
    if not trans then
        return ""
    end
    if trans.source == "vendor" then
        return GetProfitVendorDetailDisplay(trans)
    end
    if trans.source == "upgrade" then
        return GetProfitUpgradeDetailDisplay(trans)
    end
    if IsProfitAuctionFeeTransaction(trans) then
        return GetProfitLedgerDetailText(trans)
    end
    if trans.cacheItemLink and trans.cacheItemLink ~= "" then
        return GetProfitLedgerDisplayTextFromLink(trans.cacheItemLink) or GetProfitLedgerDetailText(trans)
    end
    if trans.detailLink and trans.detailLink ~= "" then
        return GetProfitLedgerDisplayTextFromLink(trans.detailLink) or GetProfitLedgerDetailText(trans)
    end
    return GetProfitLedgerDetailText(trans)
end

GetProfitLedgerDetailText = function(trans)
    if not trans then
        return ""
    end
    if IsProfitAuctionFeeTransaction(trans) then
        local feeName = trans.detailLink and GetProfitLedgerDisplayTextFromLink(trans.detailLink)
            or trans.detailText
            or ((trans.detailName and trans.detailName ~= trans.sourceLabel) and trans.detailName)
        if not feeName or feeName == "" or feeName == "Auction House" then
            return GetProfitGenericDetailFallback(trans)
        end
        return string.format("%s%s", feeName, GetProfitAuctionFeeQuantitySuffix(trans.detailText))
    end
    if trans.source == "cache" and trans.cacheName and trans.cacheName ~= "" then
        return trans.cacheName
    end
    if trans.source == "upgrade" then
        return GetProfitGenericDetailFallback(trans)
    end
    local sourceName = GetProfitLedgerSourceName(trans.source)
    local genericFallback = GetProfitGenericDetailFallback(trans)
    local detailName = trans.detailName
    if type(detailName) == "string" then
        if IsProfitGenericSourceDetail(trans, detailName, sourceName, genericFallback) then
            detailName = nil
        end
    end
    if detailName and detailName ~= "" then
        return detailName
    end
    return genericFallback
end

local function GetProfitLedgerSourceDisplay(trans)
    local sourceTag = GetProfitLedgerSourceTag(trans)
    local detailText = GetProfitLedgerDetailText(trans)
    if sourceTag ~= "" and detailText ~= "" then
        return string.format("%s: %s", sourceTag, detailText)
    end
    return detailText ~= "" and detailText or GetProfitLedgerSourceName(trans and trans.source or "")
end

local function GetProfitLedgerTooltipLink(trans)
    if trans and trans.source == "upgrade" then
        return nil
    end
    return trans and (trans.cacheItemLink or trans.detailLink) or nil
end

local function FormatProfitLedgerAmount(amount)
    amount = amount or 0
    local color = amount >= 0 and "00ff00" or "ff4444"
    local sign = amount >= 0 and "+" or "-"
    return string.format("|cff%s%s%s|r", color, sign, FormatGoldAligned(math.abs(amount), 14))
end

local PROFIT_BREAKDOWN_SOURCE_COLORS = {
    auction = { 1.00, 0.65, 0.00, 1 },      -- WGT Auction House orange
    ahFee = { 1.00, 0.65, 0.00, 1 },        -- WGT AH Fee orange
    blackMarket = { 1.00, 0.65, 0.00, 1 },  -- WGT Black Market orange
    vendor = { 0.27, 1.00, 0.27, 1 },       -- WGT Vendor green
    quest = { 1.00, 1.00, 0.00, 1 },        -- WGT Quest yellow
    worldQuest = { 0.00, 0.80, 1.00, 1 },   -- WGT World Quest cyan
    loot = { 1.00, 1.00, 1.00, 1 },         -- WGT Looted white
    flightpath = { 1.00, 1.00, 1.00, 1 },   -- WGT Flight Path white
    trade = { 0.00, 1.00, 1.00, 1 },        -- WGT Trade cyan
    mail = { 1.00, 0.87, 0.68, 1 },         -- WGT Mail parchment
    warbandBank = { 0.27, 0.53, 1.00, 1 },  -- WGT Warband Bank blue
    guildBank = { 0.69, 0.28, 0.97, 1 },    -- WGT Guild Bank purple
    crafting = { 0.67, 0.83, 0.45, 1 },     -- WGT Craft green
    repair = { 1.00, 0.42, 0.42, 1 },       -- WGT Repair salmon
    transmog = { 0.80, 0.60, 1.00, 1 },     -- WGT Transmog lavender
    training = { 0.85, 0.65, 0.13, 1 },     -- WGT Training goldenrod
    cache = { 0.33, 0.78, 0.96, 1 },        -- LiteVault-only cache accent
    upgrade = { 0.98, 0.45, 0.28, 1 },      -- LiteVault-only upgrade accent
    other = { 0.72, 0.74, 0.78, 1 },
}

local function GetProfitBreakdownSourceColor(source)
    local color = PROFIT_BREAKDOWN_SOURCE_COLORS[source or "other"] or PROFIT_BREAKDOWN_SOURCE_COLORS.other
    return color[1], color[2], color[3], color[4]
end

local function WrapProfitSourceText(source, text)
    if not text or text == "" then
        return ""
    end

    local r, g, b = GetProfitBreakdownSourceColor(source)
    return CreateColor(r, g, b):WrapTextInColorCode(tostring(text))
end

local function GetProfitBreakdownSourceLabel(source)
    return GetProfitLedgerSourceName(source)
end

local function BuildWarbandSourceBreakdown(transactions)
    local function ApplyRoundedDisplayPercents(entries)
        local remainders = {}
        local assigned = 0

        for index, entry in ipairs(entries) do
            local exact = math.max(0, (entry.share or 0) * 100)
            local base = math.floor(exact)
            entry.displayPercent = base
            assigned = assigned + base
            remainders[#remainders + 1] = {
                index = index,
                remainder = exact - base,
                amount = entry.amount or 0,
            }
        end

        table.sort(remainders, function(a, b)
            if a.remainder == b.remainder then
                return (a.amount or 0) > (b.amount or 0)
            end
            return (a.remainder or 0) > (b.remainder or 0)
        end)

        local remaining = math.max(0, 100 - assigned)
        local cursor = 1
        while remaining > 0 and remainders[cursor] do
            local target = entries[remainders[cursor].index]
            if target then
                target.displayPercent = (target.displayPercent or 0) + 1
                remaining = remaining - 1
            end
            cursor = cursor + 1
            if cursor > #remainders then
                cursor = 1
            end
        end
    end

    local function Flatten(entries, total, key)
        local flattened = {}
        for _, entry in ipairs(entries or {}) do
            local amount = entry and entry[key] or 0
            if amount and amount > 0 then
                local source = entry.source or "other"
                flattened[#flattened + 1] = {
                    source = source,
                    label = entry.sourceLabel or GetProfitBreakdownSourceLabel(source),
                    amount = amount,
                    share = (total > 0) and (amount / total) or 0,
                }
            end
        end

        if total > 0 and #flattened > 0 then
            ApplyRoundedDisplayPercents(flattened)
        end

        table.sort(flattened, function(a, b)
            if a.amount == b.amount then
                return tostring(a.label or "") < tostring(b.label or "")
            end
            return (a.amount or 0) > (b.amount or 0)
        end)
        return flattened
    end

    if lv.GetProfitSourceBreakdown then
        local breakdown = lv.GetProfitSourceBreakdown("week") or {}
        local entries = breakdown.entries or {}
        return {
            incomeEntries = Flatten(entries, breakdown.income or 0, "income"),
            expenseEntries = Flatten(entries, breakdown.expense or 0, "expense"),
            totalIncome = breakdown.income or 0,
            totalExpense = breakdown.expense or 0,
        }
    end

    local incomeBySource, expenseBySource = {}, {}
    local totalIncome, totalExpense = 0, 0
    for _, tx in ipairs(transactions or {}) do
        if tx and tx.source and tx.source ~= "warbandBank" then
            local amount = tx.amount or 0
            if amount > 0 then
                incomeBySource[tx.source] = (incomeBySource[tx.source] or 0) + amount
                totalIncome = totalIncome + amount
            elseif amount < 0 then
                expenseBySource[tx.source] = (expenseBySource[tx.source] or 0) + math.abs(amount)
                totalExpense = totalExpense + math.abs(amount)
            end
        end
    end

    local function FlattenFallback(map, total)
        local entries = {}
        for source, amount in pairs(map) do
            entries[#entries + 1] = {
                source = source,
                label = GetProfitBreakdownSourceLabel(source),
                amount = amount,
                share = (total > 0) and (amount / total) or 0,
            }
        end
        table.sort(entries, function(a, b)
            if a.amount == b.amount then
                return tostring(a.label or "") < tostring(b.label or "")
            end
            return (a.amount or 0) > (b.amount or 0)
        end)
        if total > 0 and #entries > 0 then
            ApplyRoundedDisplayPercents(entries)
        end
        return entries
    end

    return {
        incomeEntries = FlattenFallback(incomeBySource, totalIncome),
        expenseEntries = FlattenFallback(expenseBySource, totalExpense),
        totalIncome = totalIncome,
        totalExpense = totalExpense,
    }
end

local function FormatProfitBreakdownAmount(amount, isExpense, iconSize)
    amount = math.abs(amount or 0)
    if isExpense then
        return "|cffff6666-" .. FormatGoldAligned(amount, iconSize or 14) .. "|r"
    end
    return "|cff00ff88+" .. FormatGoldAligned(amount, iconSize or 14) .. "|r"
end

local function FormatProfitBreakdownShare(value)
    if type(value) == "table" then
        if value.displayPercent ~= nil then
            return string.format("%d%%", value.displayPercent)
        end
        value = value.share
    end
    return string.format("%d%%", math.floor(((value or 0) * 100) + 0.5))
end

local RenderProfitLedger
local RenderWarbandProfitBreakdown

-- Filters are explicit booleans so new sources can default on without
-- overwriting sources the user intentionally unchecked.
local function ProfitLedgerMatchesSourceFilter(trans, activeFilters)
    if type(activeFilters) ~= "table" or not next(activeFilters) then
        return true
    end
    return trans and trans.source and activeFilters[trans.source] == true
end

local function BuildProfitLedgerFilterOptions(transactions)
    local options = {}
    local seen = {}
    for _, tx in ipairs(transactions or {}) do
        if tx and tx.source and not seen[tx.source] and tx.source ~= "warbandBank" then
            seen[tx.source] = true
        end
    end

    for _, source in ipairs(GetSourceDefinitions()) do
        if seen[source.key] then
            options[#options + 1] = {
                key = source.key,
                label = (source.key == "auction") and "AH" or GetProfitLedgerSourceName(source.key),
            }
        end
    end

    return options
end

local function CountProfitLedgerSelectedFilters(activeFilters)
    local count = 0
    if type(activeFilters) ~= "table" then
        return 0
    end
    for _, enabled in pairs(activeFilters) do
        if enabled == true then
            count = count + 1
        end
    end
    return count
end

local function SetProfitLedgerFiltersFromOptions(frame, options, checked)
    frame.activeSourceFilters = {}
    for _, option in ipairs(options or {}) do
        frame.activeSourceFilters[option.key] = checked and true or false
    end
end

local function UpdateProfitLedgerFilterButtonLabel(frame)
    if not (frame and frame.filterToggle and frame.filterToggle.Text) then
        return
    end

    local totalCount = #(frame.currentFilterOptions or {})
    local selectedCount = CountProfitLedgerSelectedFilters(frame.activeSourceFilters)
    local label = UIText("BUTTON_FILTER")
    if totalCount > 0 and selectedCount < totalCount then
        label = string.format("%s (%d)", label, selectedCount)
    end
    frame.filterToggle.Text:SetText(label)
end

local function StyleProfitLedgerFilterButton(button, active)
    local t = lv.GetTheme and lv.GetTheme()
    if not button or not t then
        return
    end
    if active then
        button:SetBackdropColor(unpack(t.tabActive or t.buttonBgHover or t.buttonBg))
        button:SetBackdropBorderColor(unpack(t.tabActiveBorder or t.borderPrimary))
        if button.Text then
            button.Text:SetTextColor(unpack(t.textPrimary))
        end
    else
        button:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        button:SetBackdropBorderColor(unpack(t.borderPrimary))
        if button.Text then
            button.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        end
    end
end

local function ApplyProfitLedgerFilterMenuTheme(frame, theme)
    if not (frame and theme) then
        return
    end

    if frame.filterMenu then
        frame.filterMenu:SetBackdropColor(unpack(theme.background))
        frame.filterMenu:SetBackdropBorderColor(unpack(theme.borderPrimary))
        if frame.filterMenu.title then
            frame.filterMenu.title:SetTextColor(unpack(theme.textPrimary))
        end
        if frame.filterMenu.close then
            StyleProfitLedgerFilterButton(frame.filterMenu.close, false)
        end
        if frame.filterMenu.allBtn then
            StyleProfitLedgerFilterButton(frame.filterMenu.allBtn, false)
        end
        if frame.filterMenu.noneBtn then
            StyleProfitLedgerFilterButton(frame.filterMenu.noneBtn, false)
        end
    end

    if frame.filterToggle then
        StyleProfitLedgerFilterButton(frame.filterToggle, frame.filterMenu and frame.filterMenu:IsShown())
    end

    if frame.modeToggle then
        StyleProfitLedgerFilterButton(frame.modeToggle, false)
    end

    if frame.filterChecks then
        for _, cb in ipairs(frame.filterChecks) do
            if cb and cb.Text then
                cb.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end
        end
    end
end

local function CreateProfitLedgerFilterButton(parent, width, label)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, 20)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.Text:SetPoint("CENTER")
    button.Text:SetText(label)
    StyleProfitLedgerFilterButton(button, false)
    return button
end

local function GetProfitLedgerFilterCheck(frame, index)
    frame.filterChecks = frame.filterChecks or {}
    if not frame.filterChecks[index] then
        local cb = CreateFrame("CheckButton", nil, frame.filterMenu, "InterfaceOptionsCheckButtonTemplate")
        cb:SetScript("OnClick", function(self)
            local parent = self.ownerFrame
            if not parent then
                return
            end
            parent.activeSourceFilters = parent.activeSourceFilters or {}
            if self:GetChecked() then
                parent.activeSourceFilters[self.filterKey] = true
            else
                parent.activeSourceFilters[self.filterKey] = false
            end
            UpdateProfitLedgerFilterButtonLabel(parent)
            if parent.currentLedgerSeries then
                RenderProfitLedger(parent.currentLedgerSeries)
            end
        end)
        local t = lv.GetTheme and lv.GetTheme()
        if t and cb.Text then
            cb.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        end
        frame.filterChecks[index] = cb
    end
    return frame.filterChecks[index]
end

local function RefreshProfitLedgerFilterMenu(frame, options)
    if not (frame and frame.filterMenu) then
        return
    end

    frame.currentFilterOptions = options or {}
    frame.activeSourceFilters = frame.activeSourceFilters or {}

    local yOffset = -56
    for index, option in ipairs(frame.currentFilterOptions) do
        local cb = GetProfitLedgerFilterCheck(frame, index)
        cb.ownerFrame = frame
        cb.filterKey = option.key
        cb.Text:SetText(option.label)
        cb:SetChecked(frame.activeSourceFilters[option.key] == true)
        cb:ClearAllPoints()
        cb:SetPoint("TOPLEFT", 14, yOffset)
        cb:Show()
        yOffset = yOffset - 24
    end
    if frame.filterChecks then
        for index = #frame.currentFilterOptions + 1, #frame.filterChecks do
            frame.filterChecks[index]:Hide()
        end
    end

    frame.filterMenu:SetHeight(math.max(92, 64 + (#frame.currentFilterOptions * 24)))
    UpdateProfitLedgerFilterButtonLabel(frame)
end

local function EnsureProfitLedgerFilterSelection(frame, options)
    if frame.activeSourceFilters == nil then
        SetProfitLedgerFiltersFromOptions(frame, options, true)
    end

    local available = {}
    for _, option in ipairs(options or {}) do
        available[option.key] = true
        if frame.activeSourceFilters[option.key] == nil then
            frame.activeSourceFilters[option.key] = true
        end
    end

    for key in pairs(frame.activeSourceFilters) do
        if not available[key] then
            frame.activeSourceFilters[key] = nil
        end
    end
end

local function EnsureProfitLedgerFilterControls(frame)
    if frame.filterToggle then
        return
    end

    frame.filterToggle = CreateProfitLedgerFilterButton(frame.filterBar, 82, UIText("BUTTON_FILTER"))
    frame.filterToggle.ownerFrame = frame
    frame.filterToggle:SetPoint("LEFT", frame.filterBar, "LEFT", 0, 0)
    frame.filterToggle:SetScript("OnClick", function(self)
        local menu = self.ownerFrame and self.ownerFrame.filterMenu
        if not menu then
            return
        end
        if menu:IsShown() then
            menu:Hide()
        else
            menu:ClearAllPoints()
            menu:SetPoint("TOPRIGHT", self.ownerFrame, "TOPLEFT", -8, -62)
            menu:Show()
        end
        StyleProfitLedgerFilterButton(self, menu:IsShown())
    end)

    frame.filterMenu = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.filterMenu:SetSize(220, 140)
    frame.filterMenu:SetFrameStrata("DIALOG")
    frame.filterMenu:SetFrameLevel(frame:GetFrameLevel() + 10)
    frame.filterMenu:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame.filterMenu:Hide()
    frame.filterMenu.ownerFrame = frame
    frame.filterMenu:SetScript("OnHide", function(self)
        if self.ownerFrame and self.ownerFrame.filterToggle then
            StyleProfitLedgerFilterButton(self.ownerFrame.filterToggle, false)
        end
    end)

    frame.filterMenu.title = frame.filterMenu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.filterMenu.title:SetPoint("TOPLEFT", 12, -12)
    frame.filterMenu.title:SetText(UIText("BUTTON_FILTER"))

    frame.filterMenu.close = CreateProfitLedgerFilterButton(frame.filterMenu, 54, UIText("BUTTON_CLOSE"))
    frame.filterMenu.close:SetPoint("TOPRIGHT", -8, -8)
    frame.filterMenu.close:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)

    frame.filterMenu.allBtn = CreateProfitLedgerFilterButton(frame.filterMenu, 64, UIText("BUTTON_ALL"))
    frame.filterMenu.allBtn:SetPoint("TOPLEFT", 12, -32)
    frame.filterMenu.allBtn:SetScript("OnClick", function(self)
        local owner = self:GetParent() and self:GetParent().ownerFrame
        if not owner then
            return
        end
        SetProfitLedgerFiltersFromOptions(owner, owner.currentFilterOptions, true)
        RefreshProfitLedgerFilterMenu(owner, owner.currentFilterOptions)
        if owner.currentLedgerSeries then
            RenderProfitLedger(owner.currentLedgerSeries)
        end
    end)

    frame.filterMenu.noneBtn = CreateProfitLedgerFilterButton(frame.filterMenu, 64, UIText("BUTTON_NONE"))
    frame.filterMenu.noneBtn:SetPoint("LEFT", frame.filterMenu.allBtn, "RIGHT", 6, 0)
    frame.filterMenu.noneBtn:SetScript("OnClick", function(self)
        local owner = self:GetParent() and self:GetParent().ownerFrame
        if not owner then
            return
        end
        SetProfitLedgerFiltersFromOptions(owner, owner.currentFilterOptions, false)
        RefreshProfitLedgerFilterMenu(owner, owner.currentFilterOptions)
        if owner.currentLedgerSeries then
            RenderProfitLedger(owner.currentLedgerSeries)
        end
    end)
end

local function BuildWeeklyProfitLedgerSeries(charKey)
    local summary = GetSummaryForPeriod("week", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    local transactions = GetTransactionsForPeriod("week", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    local charData = GetCharacterRecord(charKey)

    return {
        title = UIText("LABEL_WEEKLY_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"),
        emptyText = UIText("TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"),
        transactions = transactions,
        earned = summary.income or 0,
        net = summary.net or 0,
        spent = summary.expense or 0,
        showCharacter = true,
        charName = GetCharacterDisplayName(charKey),
        class = charData and charData.class or nil,
        wide = true,
    }
end

local function BuildMonthlyProfitLedgerSeries(charKey)
    local summary = GetSummaryForPeriod("month", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    local transactions = GetTransactionsForPeriod("month", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    local charData = GetCharacterRecord(charKey)

    return {
        title = UIText("LABEL_MONTHLY_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"),
        emptyText = UIText("TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"),
        transactions = transactions,
        earned = summary.income or 0,
        net = summary.net or 0,
        spent = summary.expense or 0,
        showCharacter = true,
        charName = GetCharacterDisplayName(charKey),
        class = charData and charData.class or nil,
        wide = true,
    }
end

local function BuildWarbandProfitLedgerSeries()
    local summary = GetSummaryForPeriod("week")
    local sourceTransactions = GetTransactionsForPeriod("week")
    local transactions = {}
    for _, tx in ipairs(sourceTransactions) do
        local copy = {}
        for key, value in pairs(tx) do
            copy[key] = value
        end
        local charData = GetCharacterRecord(copy.charKey)
        copy._sourceTx = tx
        copy.charName = GetCharacterDisplayName(copy.charKey)
        copy.class = charData and charData.class or nil
        transactions[#transactions + 1] = copy
    end

    return {
        title = UIText("LABEL_WARBAND_PROFIT"),
        subtitle = UIText("TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"),
        emptyText = UIText("TEXT_PROFIT_LEDGER_EMPTY_WARBAND"),
        transactions = transactions,
        earned = summary.income or 0,
        net = summary.net or 0,
        spent = summary.expense or 0,
        showCharacter = true,
        isWarband = true,
        wide = true,
    }
end

local function EnsureProfitBreakdownCard(parent, index)
    parent.breakdownCards = parent.breakdownCards or {}
    if parent.breakdownCards[index] then
        return parent.breakdownCards[index]
    end

    local card = CreateProfitPanel(parent, 318, 414)
    if index == 1 then
        card:SetPoint("TOPLEFT", 56, 0)
    else
        card:SetPoint("TOPRIGHT", -56, 0)
    end

    card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.title:SetPoint("TOPLEFT", 16, -14)
    card.title:SetWidth(280)
    card.title:SetJustifyH("LEFT")

    card.subtitle = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.subtitle:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -4)
    card.subtitle:SetWidth(280)
    card.subtitle:SetJustifyH("LEFT")
    card.subtitle:SetJustifyV("TOP")

    card.circle = CreateFrame("Frame", nil, card)
    card.circle:SetSize(184, 184)
    card.circle:SetPoint("TOP", 0, -54)

    card.ringSegments = {}
    local ringCount = 20
    local radius = 74
    for i = 1, ringCount do
        local segment = CreateFrame("Frame", nil, card.circle)
        segment:SetSize(10, 10)
        segment:EnableMouse(true)
        if segment.SetMouseMotionEnabled then
            segment:SetMouseMotionEnabled(true)
        end
        segment.texture = segment:CreateTexture(nil, "ARTWORK")
        segment.texture:SetAllPoints()
        segment.mask = segment:CreateMaskTexture()
        segment.mask:SetAllPoints(segment.texture)
        segment.mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        segment.texture:AddMaskTexture(segment.mask)
        local angle = (((i - 1) / ringCount) * (math.pi * 2)) - (math.pi / 2)
        segment:SetPoint("CENTER", card.circle, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
        segment.tooltipTitle = nil
        segment.tooltipAmount = nil
        segment.tooltipShare = nil
        segment:SetScript("OnEnter", function(self)
            if not self.tooltipTitle then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltipTitle, 1, 0.82, 0)
            if self.tooltipAmount then
                GameTooltip:AddLine(self.tooltipAmount, 1, 1, 1)
            end
            if self.tooltipShare then
                GameTooltip:AddLine(self.tooltipShare, 0.82, 0.82, 0.82)
            end
            GameTooltip:Show()
        end)
        segment:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        card.ringSegments[i] = segment
    end

    card.percent = card.circle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    card.percent:SetPoint("CENTER", card.circle, "CENTER", 0, 16)

    card.centerLabel = card.circle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    card.centerLabel:SetPoint("TOP", card.percent, "BOTTOM", 0, -5)
    card.centerLabel:SetWidth(176)
    card.centerLabel:SetJustifyH("CENTER")

    card.centerAmount = card.circle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    card.centerAmount:SetPoint("TOP", card.centerLabel, "BOTTOM", 0, -4)
    card.centerAmount:SetWidth(176)
    card.centerAmount:SetJustifyH("CENTER")

    card.sourcesBox = CreateProfitPanel(card, 282, 142)
    card.sourcesBox:SetPoint("TOPLEFT", 18, -252)

    card.legendTitle = card.sourcesBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.legendTitle:SetPoint("TOPLEFT", 12, -10)
    card.legendTitle:SetWidth(252)
    card.legendTitle:SetJustifyH("LEFT")

    card.rows = {}

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(card, ApplyProfitPanelTheme)
            lv.RegisterThemedElement(card.sourcesBox, ApplyProfitPanelTheme)
            lv.RegisterThemedElement(card.title, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.subtitle, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.percent, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.centerLabel, function(label, theme)
                label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.centerAmount, function(label, theme)
                label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.legendTitle, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            for _, row in ipairs(card.rows) do
                lv.RegisterThemedElement(row.label, function(label, theme)
                    label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
                end)
                lv.RegisterThemedElement(row.share, function(label, theme)
                    label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
                end)
            end
        end
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            ApplyProfitPanelTheme(card, t)
            ApplyProfitPanelTheme(card.sourcesBox, t)
            card.title:SetTextColor(unpack(t.textPrimary))
            card.subtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            card.percent:SetTextColor(unpack(t.textPrimary))
            card.centerLabel:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            card.centerAmount:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            card.legendTitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            for _, row in ipairs(card.rows) do
                row.label:SetTextColor(unpack(t.textSecondary or t.textPrimary))
                row.share:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            end
        end
    end)

    parent.breakdownCards[index] = card
    return card
end

local GetProfitBreakdownRow
local ResizeProfitBreakdownCard

local function UpdateProfitBreakdownCard(card, cfg)
    if not card then
        return
    end

    local entries = (cfg and cfg.entries) or {}
    local top = entries[1]
    local t = lv.GetTheme and lv.GetTheme()
    local muted = t and (t.borderSecondary or t.borderPrimary) or { 0.36, 0.38, 0.42, 1 }

    card.title:SetText((cfg and cfg.title) or "")
    card.subtitle:SetText((cfg and cfg.subtitle) or "")
    card.legendTitle:SetText(UIText("LABEL_TOP_SOURCES"))

    local share = top and top.share or 0
    for i, segment in ipairs(card.ringSegments) do
        local ratio = (i - 0.5) / #card.ringSegments
        local cumulative = 0
        local matched = nil
        for _, entry in ipairs(entries) do
            cumulative = cumulative + (entry.share or 0)
            if ratio <= cumulative then
                matched = entry
                break
            end
        end

        if matched then
            local cr, cg, cb, ca = GetProfitBreakdownSourceColor(matched.source)
            segment.texture:SetColorTexture(cr, cg, cb, ca or 1)
            segment.tooltipTitle = matched.label or matched.source or UIText("LABEL_UNKNOWN")
            segment.tooltipAmount = FormatProfitBreakdownAmount(matched.amount or 0, cfg and cfg.isExpense)
            segment.tooltipShare = string.format("%s %s", UIText("LABEL_SHARE"), FormatProfitBreakdownShare(matched))
        else
            segment.texture:SetColorTexture(muted[1], muted[2], muted[3], 0.28)
            segment.tooltipTitle = nil
            segment.tooltipAmount = nil
            segment.tooltipShare = nil
        end
    end

    if top then
        card.percent:SetText(FormatProfitBreakdownShare(top))
        card.centerLabel:SetText(WrapProfitSourceText(top.source, top.label or ""))
        card.centerAmount:SetText(FormatProfitBreakdownAmount(top.amount or 0, cfg and cfg.isExpense))
    else
        card.percent:SetText("0%")
        card.centerLabel:SetText((cfg and cfg.emptyLabel) or UIText("MSG_NO_TRANSACTIONS"))
        card.centerAmount:SetText((cfg and cfg.isExpense) and "|cffff6666-" .. FormatGoldAligned(0, 14) .. "|r" or "|cff00ff88+" .. FormatGoldAligned(0, 14) .. "|r")
    end

    for i = 1, #entries do
        local row = GetProfitBreakdownRow(card, i)
        local entry = entries[i]
        if entry then
            local sr, sg, sb, sa = GetProfitBreakdownSourceColor(entry.source)
            row.swatch:SetColorTexture(sr, sg, sb, sa or 1)
            row.label:SetText(string.format("%d. %s", i, WrapProfitSourceText(entry.source, entry.label or entry.source or UIText("LABEL_UNKNOWN"))))
            row.share:SetText("|cff999999" .. FormatProfitBreakdownShare(entry) .. "|r")
            row.amount:SetText(FormatProfitBreakdownAmount(entry.amount or 0, cfg and cfg.isExpense, 11))
            row:Show()
        end
    end
    if card.rows then
        for i = #entries + 1, #card.rows do
            card.rows[i]:Hide()
        end
    end
end

GetProfitBreakdownRow = function(card, index)
    card.rows = card.rows or {}
    if card.rows[index] then
        return card.rows[index]
    end

    local row = CreateFrame("Frame", nil, card.sourcesBox)
    row:SetSize(258, 22)
    row:SetPoint("TOPLEFT", 12, -30 - ((index - 1) * 22))

    row.swatch = row:CreateTexture(nil, "ARTWORK")
    row.swatch:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.swatch:SetSize(8, 8)
    row.swatch:SetPoint("LEFT", 0, 0)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.label:SetPoint("LEFT", 14, 0)
    row.label:SetWidth(112)
    row.label:SetJustifyH("LEFT")
    row.label:SetWordWrap(false)

    row.amount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.amount:SetPoint("RIGHT", 0, 0)
    row.amount:SetWidth(96)
    row.amount:SetJustifyH("RIGHT")
    row.amount:SetWordWrap(false)
    if row.amount.SetNonSpaceWrap then
        row.amount:SetNonSpaceWrap(false)
    end

    row.share = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.share:SetPoint("RIGHT", row.amount, "LEFT", -6, 0)
    row.share:SetWidth(40)
    row.share:SetJustifyH("RIGHT")
    row.share:SetWordWrap(false)

    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(row.label, function(label, theme)
            label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
        end)
        lv.RegisterThemedElement(row.share, function(label, theme)
            label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
        end)
    end

    local t = lv.GetTheme and lv.GetTheme()
    if t then
        row.label:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        row.share:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
    end

    card.rows[index] = row
    return row
end

ResizeProfitBreakdownCard = function(card, rowCount)
    rowCount = math.max(5, tonumber(rowCount) or 0)
    local extraRows = math.max(0, rowCount - 5)
    local extraHeight = extraRows * 22

    card:SetSize(318, 414 + extraHeight)
    card.sourcesBox:SetSize(282, 142 + extraHeight)
end

local function BuildProfitExportState(frame)
    if not frame or not frame.currentProfitMode then
        return nil
    end

    local mode = frame.currentProfitMode
    if mode ~= "weekly" and mode ~= "monthly" and mode ~= "warband" then
        return nil
    end

    local period = (mode == "monthly") and "month" or "week"
    local opts = {}
    if mode ~= "warband" and frame.currentCharKey then
        opts.charKey = frame.currentCharKey
    end

    local title
    if mode == "warband" then
        title = UIText("BUTTON_WARBAND_PROFIT_EXPORT")
    elseif mode == "monthly" then
        title = UIText("BUTTON_MONTHLY_PROFIT_EXPORT")
    else
        title = UIText("BUTTON_WEEKLY_PROFIT_EXPORT")
    end

    return {
        period = period,
        opts = opts,
        title = title,
    }
end

local function EnsureProfitExportWindow()
    if lv.ProfitExportWindow then
        return lv.ProfitExportWindow
    end

    local frame = CreateFrame("Frame", "LiteVaultProfitExportWindow", LVWindow, "BackdropTemplate")
    frame:SetSize(760, 500)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(LVWindow:GetFrameLevel() + 40)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 18, -16)
    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
    frame.subtitle:SetText(UIText("TEXT_PROFIT_EXPORT_SUBTITLE"))

    frame.close = CreateProfitHeaderButton(frame, 62, L["BUTTON_CLOSE"])
    frame.close:SetPoint("TOPRIGHT", -12, -12)
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    frame.copyHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.copyHint:SetPoint("TOPLEFT", 18, -54)
    frame.copyHint:SetPoint("TOPRIGHT", -18, -54)
    frame.copyHint:SetJustifyH("LEFT")
    frame.copyHint:SetText(UIText("TEXT_PROFIT_EXPORT_HINT"))

    frame.editPanel = CreateProfitPanel(frame, 724, 388)
    frame.editPanel:SetPoint("TOPLEFT", 18, -76)
    frame.editPanel:SetPoint("BOTTOMRIGHT", -18, 52)

    frame.scroll = CreateFrame("ScrollFrame", nil, frame.editPanel, "UIPanelScrollFrameTemplate")
    frame.scroll:SetPoint("TOPLEFT", 8, -8)
    frame.scroll:SetPoint("BOTTOMRIGHT", -30, 8)

    frame.editBox = CreateFrame("EditBox", nil, frame.scroll)
    frame.editBox:SetMultiLine(true)
    frame.editBox:SetFontObject(ChatFontNormal)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:SetWidth(668)
    frame.editBox:SetHeight(360)
    frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    frame.editBox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    frame.editBox:SetScript("OnTextChanged", function(self)
        local lineHeight = select(2, self:GetFont()) or 14
        local numLines = self:GetNumLines() or 1
        self:SetHeight(math.max(360, (numLines * lineHeight) + 24))
    end)
    frame.scroll:SetScrollChild(frame.editBox)

    frame.selectAll = CreateProfitHeaderButton(frame, 92, UIText("BUTTON_SELECT_ALL"))
    frame.selectAll:SetPoint("BOTTOMRIGHT", -82, 14)
    frame.selectAll:SetScript("OnClick", function()
        frame.editBox:SetFocus()
        frame.editBox:HighlightText()
    end)

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(frame, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            lv.RegisterThemedElement(frame.editPanel, ApplyProfitPanelTheme)
            lv.RegisterThemedElement(frame.close, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary))
            end)
            lv.RegisterThemedElement(frame.selectAll, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.title, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.subtitle, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.copyHint, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
        end
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            frame:SetBackdropColor(unpack(t.background))
            frame:SetBackdropBorderColor(unpack(t.borderPrimary))
            ApplyProfitPanelTheme(frame.editPanel, t)
            frame.close:SetBackdropColor(unpack(t.buttonBg))
            frame.close:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.close.Text:SetTextColor(unpack(t.textSecondary))
            frame.selectAll:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            frame.selectAll:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.selectAll.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            frame.title:SetTextColor(unpack(t.textPrimary))
            frame.subtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.copyHint:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
        end
    end)

    lv.ProfitExportWindow = frame
    return frame
end

local function ShowProfitExportWindow(exportState)
    if not exportState or not lv.ExportProfitCSV then
        return
    end

    local frame = EnsureProfitExportWindow()
    local csv = lv.ExportProfitCSV(exportState.period, exportState.opts or {}) or ""
    frame.title:SetText(exportState.title or UIText("BUTTON_EXPORT_CSV"))
    frame.editBox:SetText(csv)
    frame.editBox:SetCursorPosition(0)
    frame.scroll:SetVerticalScroll(0)
    frame:Show()
    frame.editBox:SetFocus()
    frame.editBox:HighlightText()
end

local function UpdateProfitExportButton(frame)
    if not frame or not frame.exportButton then
        return
    end

    local exportState = nil
    if frame.currentProfitView == "ledger" or frame.currentProfitView == "breakdown" then
        exportState = BuildProfitExportState(frame)
    end

    frame.exportState = exportState
    if exportState then
        frame.exportButton:Show()
    else
        frame.exportButton:Hide()
    end
end

local function EnsureProfitGoalEditorWindow()
    if lv.ProfitGoalEditorWindow then
        return lv.ProfitGoalEditorWindow
    end

    local frame = CreateFrame("Frame", "LiteVaultProfitGoalEditorWindow", LVWindow, "BackdropTemplate")
    frame:SetSize(360, 180)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(LVWindow:GetFrameLevel() + 45)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 18, -16)
    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)
    frame.subtitle:SetWidth(320)
    frame.subtitle:SetJustifyH("LEFT")
    frame.subtitle:SetText(UIText("TEXT_PROFIT_GOAL_EDITOR_HINT"))

    frame.inputLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.inputLabel:SetPoint("TOPLEFT", frame.subtitle, "BOTTOMLEFT", 0, -16)
    frame.inputLabel:SetText(UIText("LABEL_GOAL_AMOUNT"))

    frame.input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.input:SetSize(200, 24)
    frame.input:SetPoint("TOPLEFT", frame.inputLabel, "BOTTOMLEFT", 0, -8)
    frame.input:SetAutoFocus(false)
    frame.input:SetScript("OnEscapePressed", function() frame:Hide() end)

    frame.errorText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.errorText:SetPoint("TOPLEFT", frame.input, "BOTTOMLEFT", 0, -8)
    frame.errorText:SetWidth(300)
    frame.errorText:SetJustifyH("LEFT")
    frame.errorText:SetText("")

    frame.save = CreateProfitHeaderButton(frame, 72, UIText("BUTTON_SAVE"))
    frame.save:SetPoint("BOTTOMRIGHT", -94, 16)
    frame.cancel = CreateProfitHeaderButton(frame, 72, UIText("BUTTON_CANCEL"))
    frame.cancel:SetPoint("RIGHT", frame.save, "LEFT", -8, 0)
    frame.cancel:SetScript("OnClick", function() frame:Hide() end)

    frame.save:SetScript("OnClick", function()
        local amountCopper = ParseProfitGoalGoldInput(frame.input:GetText() or "")
        if amountCopper == nil then
            frame.errorText:SetText("|cffff6666" .. UIText("MSG_PROFIT_GOAL_INVALID") .. "|r")
            return
        end

        if lv.SetProfitGoal then
            lv.SetProfitGoal(frame.goalPeriod, amountCopper)
        end
        frame.errorText:SetText("")
        frame:Hide()
        if lv.UpdateTrackingDisplays then
            lv.UpdateTrackingDisplays()
        end
    end)

    frame.input:SetScript("OnEnterPressed", function()
        frame.save:Click()
    end)

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(frame, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            lv.RegisterThemedElement(frame.save, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary))
            end)
            lv.RegisterThemedElement(frame.cancel, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.title, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.subtitle, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.inputLabel, function(label, theme)
                label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
        end
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            frame:SetBackdropColor(unpack(t.background))
            frame:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.save:SetBackdropColor(unpack(t.buttonBg))
            frame.save:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.save.Text:SetTextColor(unpack(t.textSecondary))
            frame.cancel:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            frame.cancel:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.cancel.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            frame.title:SetTextColor(unpack(t.textPrimary))
            frame.subtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.inputLabel:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        end
    end)

    lv.ProfitGoalEditorWindow = frame
    return frame
end

local function ShowProfitGoalEditor(period)
    local frame = EnsureProfitGoalEditorWindow()
    local goalEntry = lv.GetProfitGoal and lv.GetProfitGoal(period) or nil
    frame.goalPeriod = period
    frame.title:SetText((period == "month") and UIText("BUTTON_EDIT_MONTHLY_GOAL") or UIText("BUTTON_EDIT_WEEKLY_GOAL"))
    frame.input:SetText(goalEntry and FormatProfitGoalInputGold(goalEntry.amount) or "")
    frame.input:HighlightText()
    frame.errorText:SetText("")
    frame:Show()
    frame.input:SetFocus()
end

local function EnsureProfitGraphWindow()
    if lv.ProfitGraphWindow then
        return lv.ProfitGraphWindow
    end

    local frame = CreateFrame("Frame", "LiteVaultProfitGraphWindow", LVWindow, "BackdropTemplate")
    frame:SetSize(560, 360)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(LVWindow:GetFrameLevel() + 30)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 18, -16)
    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -6)

    frame.close = CreateFrame("Button", nil, frame, "BackdropTemplate")
    frame.close:SetSize(62, 22)
    frame.close:SetPoint("TOPRIGHT", -12, -12)
    frame.close:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame.close.Text = frame.close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.close.Text:SetPoint("CENTER")
    frame.close.Text:SetText(L["BUTTON_CLOSE"])
    frame.close:SetScript("OnClick", function() frame:Hide() end)

    frame.exportButton = CreateProfitHeaderButton(frame, 88, UIText("BUTTON_EXPORT_CSV"))
    frame.exportButton:SetPoint("RIGHT", frame.close, "LEFT", -8, 0)
    frame.exportButton:Hide()
    frame.exportButton:SetScript("OnClick", function(self)
        ShowProfitExportWindow(self:GetParent().exportState)
    end)

    frame.graphPanel = CreateProfitPanel(frame, 524, 250)
    frame.graphPanel:SetPoint("TOPLEFT", 18, -62)
    frame.graphPanel:SetPoint("BOTTOMRIGHT", -18, 50)

    frame.emptyText = frame.graphPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.emptyText:SetPoint("CENTER")
    frame.emptyText:SetWidth(430)
    frame.emptyText:SetJustifyH("CENTER")
    frame.emptyText:SetJustifyV("MIDDLE")
    frame.emptyText:Hide()

    frame.graphArea = CreateFrame("Frame", nil, frame.graphPanel)
    frame.graphArea:SetPoint("TOPLEFT", 12, -12)
    frame.graphArea:SetPoint("BOTTOMRIGHT", -12, 28)

    frame.detailHeader = CreateFrame("Frame", nil, frame.graphPanel)
    frame.detailHeader:SetPoint("TOPLEFT", 10, -36)
    frame.detailHeader:SetPoint("TOPRIGHT", -10, -36)
    frame.detailHeader:SetHeight(18)
    frame.detailHeader:Hide()

    frame.filterBar = CreateFrame("Frame", nil, frame.graphPanel)
    frame.filterBar:SetPoint("TOPLEFT", 8, -8)
    frame.filterBar:SetPoint("TOPRIGHT", -8, -8)
    frame.filterBar:SetHeight(24)
    frame.filterBar:Hide()
    EnsureProfitLedgerFilterControls(frame)

    frame.modeToggle = CreateProfitLedgerFilterButton(frame.filterBar, 96, UIText("BUTTON_BREAKDOWN"))
    frame.modeToggle:SetPoint("RIGHT", frame.filterBar, "RIGHT", 0, 0)
    frame.modeToggle:Hide()

    frame.detailHeader.source = frame.detailHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.detailHeader.source:SetPoint("LEFT", 10, 0)
    frame.detailHeader.source:SetWidth(80)
    frame.detailHeader.source:SetJustifyH("LEFT")

    frame.detailHeader.detail = frame.detailHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.detailHeader.detail:SetPoint("LEFT", 102, 0)
    frame.detailHeader.detail:SetJustifyH("LEFT")

    frame.detailHeader.amount = frame.detailHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.detailHeader.amount:SetPoint("RIGHT", -10, 0)
    frame.detailHeader.amount:SetWidth(172)
    frame.detailHeader.amount:SetJustifyH("RIGHT")

    frame.detailHeader.meta = frame.detailHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.detailHeader.meta:SetPoint("RIGHT", frame.detailHeader.amount, "LEFT", -10, 0)
    frame.detailHeader.meta:SetWidth(150)
    frame.detailHeader.meta:SetJustifyH("LEFT")

    frame.detailHeader.detail:SetPoint("RIGHT", frame.detailHeader.meta, "LEFT", -10, 0)

    frame.detailHeader.divider = frame.detailHeader:CreateTexture(nil, "ARTWORK")
    frame.detailHeader.divider:SetPoint("BOTTOMLEFT", 0, -3)
    frame.detailHeader.divider:SetPoint("BOTTOMRIGHT", 0, -3)
    frame.detailHeader.divider:SetHeight(1)

    frame.detailScroll = CreateFrame("ScrollFrame", nil, frame.graphPanel)
    frame.detailScroll:SetPoint("TOPLEFT", 8, -58)
    frame.detailScroll:SetPoint("BOTTOMRIGHT", -8, 8)
    frame.detailScroll:Hide()
    frame.detailScroll:EnableMouseWheel(true)
    frame.detailScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local step = 44
        local newScroll = current - (delta * step)
        self:SetVerticalScroll(math.max(0, math.min(newScroll, maxScroll)))
    end)

    frame.detailContent = CreateFrame("Frame", nil, frame.detailScroll)
    frame.detailContent:SetSize(500, 1)
    frame.detailScroll:SetScrollChild(frame.detailContent)

    frame.breakdownPanel = CreateFrame("Frame", nil, frame.graphPanel)
    frame.breakdownPanel:SetPoint("TOPLEFT", 8, -40)
    frame.breakdownPanel:SetPoint("BOTTOMRIGHT", -8, -8)
    frame.breakdownPanel:Hide()

    frame.breakdownCards = {}
    EnsureProfitBreakdownCard(frame.breakdownPanel, 1)
    EnsureProfitBreakdownCard(frame.breakdownPanel, 2)

    frame.baseline = frame.graphArea:CreateTexture(nil, "BORDER")
    frame.baseline:SetColorTexture(0.55, 0.58, 0.62, 0.8)

    frame.summaryBox = CreateProfitPanel(frame, 800, 34)
    frame.summaryBox:SetPoint("BOTTOMLEFT", 18, 12)
    frame.summaryBox:SetPoint("BOTTOMRIGHT", -18, 12)

    frame.summary = frame.summaryBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.summary:SetPoint("LEFT", frame.summaryBox, "LEFT", 14, 1)
    frame.summary:SetPoint("RIGHT", frame.summaryBox, "RIGHT", -12, 0)
    frame.summary:SetPoint("CENTER", frame.summaryBox, "CENTER", 0, 1)
    frame.summary:SetJustifyH("LEFT")

    frame.points = {}
    for i = 1, 31 do
        local point = CreateFrame("Frame", nil, frame.graphArea)
        point:SetSize(10, 10)
        point:Hide()
        point.texture = point:CreateTexture(nil, "ARTWORK")
        point.texture:SetAllPoints()
        point.label = frame.graphArea:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        point.label:SetJustifyH("CENTER")
        point.value = 0
        point.tooltipLabel = ""
        point:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.tooltipLabel or "", 1, 0.82, 0)
            GameTooltip:AddLine(FormatProfitGraphAmount(self.value or 0), 1, 1, 1)
            GameTooltip:Show()
        end)
        point:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        frame.points[i] = point
    end

    frame.segments = {}
    for i = 1, 30 do
        local segment = frame.graphArea:CreateTexture(nil, "ARTWORK")
        segment:Hide()
        segment:SetTexture("Interface\\Buttons\\WHITE8X8")
        frame.segments[i] = segment
    end

    frame.ledgerRows = {}

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(frame.filterMenu, function()
                ApplyProfitLedgerFilterMenuTheme(frame, lv.GetTheme and lv.GetTheme() or nil)
            end)
            lv.RegisterThemedElement(frame.filterToggle, function()
                ApplyProfitLedgerFilterMenuTheme(frame, lv.GetTheme and lv.GetTheme() or nil)
            end)
            lv.RegisterThemedElement(frame, function(f, theme)
                f:SetBackdropColor(unpack(theme.background))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            end)
            lv.RegisterThemedElement(frame.graphPanel, ApplyProfitPanelTheme)
            lv.RegisterThemedElement(frame.summaryBox, ApplyProfitSummaryBoxTheme)
            lv.RegisterThemedElement(frame.close, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary))
            end)
            lv.RegisterThemedElement(frame.exportButton, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.modeToggle, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.title, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.subtitle, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.summary, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.emptyText, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.detailHeader.source, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.detailHeader.detail, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.detailHeader.meta, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(frame.detailHeader.amount, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
        end
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            frame:SetBackdropColor(unpack(t.background))
            frame:SetBackdropBorderColor(unpack(t.borderPrimary))
            ApplyProfitPanelTheme(frame.graphPanel, t)
            ApplyProfitSummaryBoxTheme(frame.summaryBox, t)
            frame.close:SetBackdropColor(unpack(t.buttonBg))
            frame.close:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.close.Text:SetTextColor(unpack(t.textSecondary))
            frame.exportButton:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            frame.exportButton:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.exportButton.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            frame.modeToggle:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            frame.modeToggle:SetBackdropBorderColor(unpack(t.borderPrimary))
            frame.modeToggle.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            frame.title:SetTextColor(unpack(t.textPrimary))
            frame.subtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.summary:SetTextColor(unpack(t.textPrimary))
            frame.emptyText:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.detailHeader.source:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.detailHeader.detail:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.detailHeader.meta:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.detailHeader.amount:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            frame.detailHeader.divider:SetColorTexture(unpack(t.borderSecondary or t.borderPrimary))
            ApplyProfitLedgerFilterMenuTheme(frame, t)
        end
    end)

    lv.ProfitGraphWindow = frame
    return frame
end

local function RenderProfitGraph(series)
    local frame = EnsureProfitGraphWindow()
    local points = (series and series.points) or {}
    local hasData = false
    local maxAbs = 0
    local total = 0
    local hasNegative = false
    local isMonthlyView = #points > 14

    if isMonthlyView then
        frame:SetSize(720, 400)
    else
        frame:SetSize(560, 360)
    end

    frame.title:SetText(series.title or UIText("BUTTON_PROFIT"))
    frame.subtitle:SetText(series.subtitle or "")
    frame.currentLedgerSeries = nil
    UpdateProfitExportButton(frame)

    for _, point in ipairs(points) do
        local value = point.value or 0
        total = total + value
        if value ~= 0 then
            hasData = true
        end
        if value < 0 then
            hasNegative = true
        end
        maxAbs = math.max(maxAbs, math.abs(value))
    end

    frame:Show()
    frame.graphArea:Show()
    frame.filterBar:Hide()
    frame.breakdownPanel:Hide()
    if frame.modeToggle then
        frame.modeToggle:Hide()
    end
    if frame.filterMenu then frame.filterMenu:Hide() end
    frame.detailScroll:Hide()
    frame.detailHeader:Hide()
    frame.emptyText:SetShown(not hasData)
    frame.emptyText:SetText(series.emptyText or UIText("MSG_NO_TRANSACTIONS"))

    local leftPad = 4
    local bottomPad = 18
    local topPad = 10
    local areaWidth = frame.graphArea:GetWidth() - (leftPad * 2)
    local areaHeight = frame.graphArea:GetHeight()
    local count = math.max(1, #points)
    local gap = (count > 14) and 2 or 4
    local barWidth = math.max(8, math.floor((areaWidth - ((count - 1) * gap)) / count))
    local usedWidth = (barWidth * count) + ((count - 1) * gap)
    local startX = leftPad + math.max(0, math.floor((areaWidth - usedWidth) / 2))
    local plotHeight = areaHeight - bottomPad - topPad
    local baselineY = hasNegative and (bottomPad + math.floor(plotHeight / 2)) or bottomPad
    local positiveHeight = hasNegative and math.max(16, math.floor(plotHeight / 2) - 8) or math.max(16, plotHeight - 8)
    local negativeHeight = hasNegative and math.max(16, math.floor(plotHeight / 2) - 8) or 0

    frame.baseline:ClearAllPoints()
    frame.baseline:SetPoint("BOTTOMLEFT", frame.graphArea, "BOTTOMLEFT", startX, baselineY)
    frame.baseline:SetSize(usedWidth, 1)
    frame.baseline:SetShown(hasData)

    local t = lv.GetTheme and lv.GetTheme()
    local labelColor = t and (t.textMuted or t.textSecondary or t.textPrimary) or { 0.8, 0.8, 0.8, 1 }

    local renderedPoints = {}
    for i, pointFrame in ipairs(frame.points) do
        local point = points[i]
        if point and hasData then
            local value = point.value or 0
            local xOffset = startX + ((i - 1) * (barWidth + gap))
            local xCenter = xOffset + math.floor(barWidth / 2)
            local scaledHeight = 0
            if maxAbs > 0 and value ~= 0 then
                local scaleHeight = (value >= 0) and positiveHeight or negativeHeight
                scaledHeight = math.floor((math.abs(value) / maxAbs) * scaleHeight)
            end
            local yCenter = baselineY + ((value >= 0) and scaledHeight or -scaledHeight)

            pointFrame:ClearAllPoints()
            pointFrame:SetPoint("CENTER", frame.graphArea, "BOTTOMLEFT", xCenter, yCenter)
            pointFrame.tooltipLabel = point.tooltipLabel or point.label or ""
            pointFrame.value = value
            pointFrame:Show()
            if value > 0 then
                pointFrame.texture:SetColorTexture(0.14, 0.82, 0.34, 1)
            elseif value < 0 then
                pointFrame.texture:SetColorTexture(0.86, 0.25, 0.25, 1)
            else
                pointFrame.texture:SetColorTexture(0.72, 0.74, 0.78, 1)
            end

            pointFrame.label:ClearAllPoints()
            pointFrame.label:SetPoint("TOP", frame.graphArea, "BOTTOMLEFT", xCenter, -2)
            pointFrame.label:SetText(point.label or "")
            pointFrame.label:SetTextColor(unpack(labelColor))
            pointFrame.label:Show()

            renderedPoints[i] = { x = xCenter, y = yCenter, value = value }
        else
            pointFrame:Hide()
            pointFrame.label:Hide()
            renderedPoints[i] = nil
        end
    end

    for i, segment in ipairs(frame.segments) do
        local a = renderedPoints[i]
        local b = renderedPoints[i + 1]
        if a and b and hasData then
            local dx = b.x - a.x
            local dy = b.y - a.y
            local length = math.sqrt((dx * dx) + (dy * dy))
            local angle = GetLineAngle(dx, dy)
            segment:ClearAllPoints()
            segment:SetPoint("CENTER", frame.graphArea, "BOTTOMLEFT", a.x + (dx / 2), a.y + (dy / 2))
            segment:SetSize(length, 3)
            segment:SetRotation(angle)
            if a.value >= 0 and b.value >= 0 then
                segment:SetColorTexture(0.14, 0.82, 0.34, 0.95)
            elseif a.value < 0 and b.value < 0 then
                segment:SetColorTexture(0.86, 0.25, 0.25, 0.95)
            else
                segment:SetColorTexture(0.82, 0.78, 0.36, 0.95)
            end
            segment:Show()
        else
            segment:Hide()
        end
    end

    frame.summary:SetText(string.format("%s %s", UIText("LABEL_NET"), FormatProfitGraphAmount(total)))
end

RenderWarbandProfitBreakdown = function(series)
    local frame = EnsureProfitGraphWindow()
    local breakdown = BuildWarbandSourceBreakdown(series and series.transactions or {})
    local incomeCard = EnsureProfitBreakdownCard(frame.breakdownPanel, 1)
    local expenseCard = EnsureProfitBreakdownCard(frame.breakdownPanel, 2)
    local rowCount = math.max(#(breakdown.incomeEntries or {}), #(breakdown.expenseEntries or {}), 5)
    local extraRows = math.max(0, rowCount - 5)
    local extraHeight = extraRows * 22

    ResizeProfitBreakdownCard(incomeCard, rowCount)
    ResizeProfitBreakdownCard(expenseCard, rowCount)
    frame:SetSize(892, 628 + extraHeight)
    frame.title:SetText(UIText("BUTTON_WARBAND_PROFIT_BREAKDOWN"))
    frame.subtitle:SetText(UIText("TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"))
    frame:Show()
    frame.currentLedgerSeries = series
    UpdateProfitExportButton(frame)

    if frame.filterMenu then
        frame.filterMenu:Hide()
    end
    frame.graphArea:Hide()
    frame.baseline:Hide()
    frame.detailHeader:Hide()
    frame.detailScroll:Hide()
    frame.emptyText:Hide()
    frame.breakdownPanel:Show()
    frame.filterBar:Hide()
    if frame.filterToggle then
        frame.filterToggle:Hide()
    end
    if frame.modeToggle then
        frame.modeToggle:Hide()
    end

    UpdateProfitBreakdownCard(incomeCard, {
        title = UIText("LABEL_TOP_INCOME_SOURCE"),
        subtitle = UIText("TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"),
        entries = breakdown.incomeEntries,
        total = breakdown.totalIncome,
        emptyLabel = UIText("MSG_PROFIT_NO_INCOME"),
    })
    UpdateProfitBreakdownCard(expenseCard, {
        title = UIText("LABEL_TOP_EXPENSE_SOURCE"),
        subtitle = UIText("TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"),
        entries = breakdown.expenseEntries,
        total = breakdown.totalExpense,
        emptyLabel = UIText("MSG_PROFIT_NO_SPENDING"),
        isExpense = true,
    })

    frame.summary:SetText(string.format(
        "%s %s    %s %s    %s %s",
        UIText("LABEL_GAINED"),
        FormatProfitGraphAmount(breakdown.totalIncome or 0),
        UIText("LABEL_SPENT"),
        FormatProfitBreakdownAmount(breakdown.totalExpense or 0, true),
        UIText("LABEL_NET"),
        FormatProfitGraphAmount((breakdown.totalIncome or 0) - (breakdown.totalExpense or 0))
    ))
    frame.summary:Show()
end

local function GetProfitLedgerRow(frame, index)
    if not frame.ledgerRows[index] then
        local sourceColumnLeft = 10
        local sourceColumnWidth = 80
        local detailColumnLeft = 102
        local columnGap = 10
        local amountColumnRight = -10
        local amountColumnWidth = 172

        local row = CreateFrame("Button", nil, frame.detailContent)
        row:SetHeight(46)
        row:SetPoint("LEFT", 0, 0)
        row:SetPoint("RIGHT", 0, 0)
        row:EnableMouse(true)
        if row.SetMouseMotionEnabled then
            row:SetMouseMotionEnabled(true)
        end

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints()

        row.source = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.source:SetPoint("TOPLEFT", sourceColumnLeft, -8)
        row.source:SetWidth(sourceColumnWidth)
        row.source:SetJustifyH("LEFT")

        row.primary = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.primary:SetPoint("TOPLEFT", detailColumnLeft, -7)
        row.primary:SetJustifyH("LEFT")

        row.secondary = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.secondary:SetPoint("BOTTOMLEFT", detailColumnLeft, 8)
        row.secondary:SetJustifyH("LEFT")

        row.amount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.amount:SetPoint("RIGHT", amountColumnRight, 0)
        row.amount:SetWidth(amountColumnWidth)
        row.amount:SetJustifyH("RIGHT")
        row.amount:SetWordWrap(false)
        if row.amount.SetNonSpaceWrap then
            row.amount:SetNonSpaceWrap(false)
        end

        row.primary:SetPoint("RIGHT", row.amount, "LEFT", -columnGap, 0)
        row.secondary:SetPoint("RIGHT", row.amount, "LEFT", -columnGap, 0)

        row:SetScript("OnEnter", function(self)
            if self.tooltipLink then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(self.tooltipLink)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        frame.ledgerRows[index] = row
    end
    return frame.ledgerRows[index]
end

RenderProfitLedger = function(series)
    local frame = EnsureProfitGraphWindow()
    local transactions = (series and series.transactions) or {}
    local filterOptions = BuildProfitLedgerFilterOptions(transactions)

    frame:SetSize(720, 430)
    frame.title:SetText(series.title or UIText("BUTTON_PROFIT"))
    frame.subtitle:SetText(series.subtitle or "")
    frame:Show()
    frame.currentLedgerSeries = series
    UpdateProfitExportButton(frame)
    EnsureProfitLedgerFilterSelection(frame, filterOptions)
    RefreshProfitLedgerFilterMenu(frame, filterOptions)
    if frame.filterToggle then
        frame.filterToggle:Show()
        StyleProfitLedgerFilterButton(frame.filterToggle, frame.filterMenu and frame.filterMenu:IsShown())
    end
    if frame.modeToggle then
        frame.modeToggle:Hide()
    end

    frame.graphArea:Hide()
    frame.baseline:Hide()
    frame.filterBar:Show()
    frame.detailHeader:Show()
    frame.detailScroll:Show()
    frame.breakdownPanel:Hide()
    frame.detailHeader.source:SetText(UIText("LABEL_SOURCE"))
    frame.detailHeader.detail:SetText(UIText("LABEL_DETAIL"))
    frame.detailHeader.meta:SetText(series.showCharacter and UIText("LABEL_CHARACTER_TIME") or "")
    frame.detailHeader.amount:SetText(UIText("LABEL_GOLD"))

    for _, point in ipairs(frame.points) do
        point:Hide()
        point.label:Hide()
    end
    for _, segment in ipairs(frame.segments) do
        segment:Hide()
    end

    for _, row in ipairs(frame.ledgerRows) do
        row:Hide()
    end

    local shown = 0
    local yOffset = 0
    for _, tx in ipairs(transactions) do
        if ProfitLedgerMatchesSourceFilter(tx, frame.activeSourceFilters) then
            shown = shown + 1
            local row = GetProfitLedgerRow(frame, shown)
            local sourceTag = GetProfitLedgerSourceTag(tx)
            local detailText = GetProfitLedgerDetailText(tx)
            local detailDisplay = GetProfitLedgerDetailDisplay(tx)
            local timeText = date("%m/%d %I:%M %p", tx.timestamp or time())
            local secondaryText = "|cff999999" .. timeText .. "|r"

            if series.showCharacter then
                local displayCharName = tx.charName or series.charName
                local displayClass = tx.class or series.class
                if displayCharName then
                    local charText = displayCharName
                    if displayClass then
                        local cc = C_ClassColor.GetClassColor(displayClass)
                        if cc then
                            charText = cc:WrapTextInColorCode(displayCharName)
                        end
                    end
                    secondaryText = charText .. "  |cff666666|  |r" .. secondaryText
                end
            end

            row.source:SetText(WrapProfitSourceText(tx.source, sourceTag or ""))
            row.primary:SetText(tostring(detailDisplay or detailText or ""))
            row.secondary:SetText(secondaryText)
            row.amount:SetText(FormatProfitLedgerAmount(tx.amount or 0))
            row.tooltipLink = GetProfitLedgerTooltipLink(tx)
            if tx.source == "vendor" then
                row.tooltipLink = GetProfitLedgerResolvedItemLink(tx)
            end
            row.transaction = tx._sourceTx or tx
            row.transactionCharKey = tx.charKey or lv.PLAYER_KEY

            if shown % 2 == 0 then
                row.bg:SetColorTexture(1, 1, 1, 0.04)
            else
                row.bg:SetColorTexture(0, 0, 0, 0.1)
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.detailContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("RIGHT", frame.detailContent, "RIGHT", 0, 0)
            row:Show()
            yOffset = yOffset + 48
        end
    end

    frame.detailContent:SetHeight(math.max(1, yOffset))
    frame.detailContent:SetWidth(math.max(1, frame.graphPanel:GetWidth() - 16))
    frame.detailScroll:SetVerticalScroll(0)
    frame.emptyText:SetShown(shown == 0)
    frame.emptyText:SetText(series.emptyText or UIText("MSG_NO_TRANSACTIONS"))
    frame.summary:SetText(string.format(
        "%s %s    %s |cffff6666-%s|r    %s %s",
        UIText("LABEL_EARNED"),
        FormatGoldAligned(series.earned or 0, 14),
        UIText("LABEL_SPENT"),
        FormatGoldAligned(series.spent or 0, 14),
        UIText("LABEL_NET"),
        FormatProfitGraphAmount(series.net or 0)
    ))
    frame.summary:Show()
end

local function ShowProfitGraph(mode, charKey)
    local frame = EnsureProfitGraphWindow()
    frame.currentProfitView = "graph"
    frame.currentProfitMode = mode
    frame.currentCharKey = charKey or GetCurrentProfitCharKey()
    if mode == "warband" then
        RenderProfitGraph(BuildWarbandProfitGraphSeries())
    elseif mode == "monthly" then
        RenderProfitGraph(BuildMonthlyProfitGraphSeries(frame.currentCharKey))
    else
        RenderProfitGraph(BuildWeeklyProfitGraphSeries(frame.currentCharKey))
    end
end

local function ShowProfitDetail(mode, charKey)
    local frame = EnsureProfitGraphWindow()
    frame.currentProfitMode = mode
    frame.currentCharKey = charKey or GetCurrentProfitCharKey()
    if mode == "weekly" then
        frame.currentProfitView = "ledger"
        RenderProfitLedger(BuildWeeklyProfitLedgerSeries(frame.currentCharKey))
    elseif mode == "warband" then
        frame.currentProfitView = "ledger"
        RenderProfitLedger(BuildWarbandProfitLedgerSeries())
    elseif mode == "monthly" then
        frame.currentProfitView = "ledger"
        RenderProfitLedger(BuildMonthlyProfitLedgerSeries(frame.currentCharKey))
    else
        frame.currentProfitView = "graph"
        ShowProfitGraph(mode, frame.currentCharKey)
    end
end

local function ShowWarbandProfitBreakdown()
    local frame = EnsureProfitGraphWindow()
    frame.currentProfitView = "breakdown"
    frame.currentProfitMode = "warband"
    RenderWarbandProfitBreakdown(BuildWarbandProfitLedgerSeries())
end

function lv.RefreshOpenProfitWindow()
    local frame = lv.ProfitGraphWindow
    if frame and frame:IsShown() then
        local mode = frame.currentProfitMode or "weekly"
        local charKey = frame.currentCharKey or GetCurrentProfitCharKey()
        if frame.currentProfitView == "breakdown" then
            ShowWarbandProfitBreakdown()
        elseif frame.currentProfitView == "ledger" then
            ShowProfitDetail(mode, charKey)
        else
            ShowProfitGraph(mode, charKey)
        end
    end
end

local goldUI = {}

local function UpdateProfitTokenHistoryPanel(tokenInfo)
    if not goldUI.tokenHistoryPanel or not goldUI.tokenHistoryRows then
        return
    end

    local title = UIText("TITLE_WOW_TOKEN_HISTORY")
    local history = (tokenInfo and tokenInfo.history) or {}

    if goldUI.tokenHistoryTitle then
        goldUI.tokenHistoryTitle:SetText(title)
    end

    if goldUI.tokenHistoryCurrentValue then
        goldUI.tokenHistoryCurrentValue:SetText((tokenInfo and tokenInfo.price) and FormatProfitTokenGoldOnly(tokenInfo.price, 12) or UIText("LABEL_UNKNOWN"))
    end
    if goldUI.tokenHistoryPreviousValue then
        goldUI.tokenHistoryPreviousValue:SetText((tokenInfo and tokenInfo.previousPrice) and FormatProfitTokenGoldOnly(tokenInfo.previousPrice, 12) or "-")
    end
    if goldUI.tokenHistoryChangeValue then
        goldUI.tokenHistoryChangeValue:SetText((tokenInfo and tokenInfo.deltaText) or "-")
    end
    if goldUI.tokenHistoryUpdatedValue then
        goldUI.tokenHistoryUpdatedValue:SetText((tokenInfo and (tokenInfo.updatedRelativeText or tokenInfo.updatedText)) or UIText("LABEL_UNKNOWN"))
    end
    if goldUI.tokenHistoryAffordableValue then
        goldUI.tokenHistoryAffordableValue:SetText((tokenInfo and tokenInfo.price)
            and (tokenInfo.canAfford and UIText("BUTTON_YES") or UIText("BUTTON_NO"))
            or "-")
    end
    if goldUI.tokenHistoryStatus then
        if not tokenInfo or not tokenInfo.supported then
            goldUI.tokenHistoryStatus:SetText(UIText("MSG_WOW_TOKEN_API_UNAVAILABLE"))
            goldUI.tokenHistoryStatus:Show()
            goldUI.tokenHistoryScroll:Hide()
        elseif not tokenInfo.price then
            goldUI.tokenHistoryStatus:SetText(tokenInfo.helpText or UIText("MSG_WOW_TOKEN_VISIT_AH"))
            goldUI.tokenHistoryStatus:Show()
            goldUI.tokenHistoryScroll:Hide()
        else
            goldUI.tokenHistoryStatus:Hide()
            goldUI.tokenHistoryScroll:Show()
        end
    end

    for index, row in ipairs(goldUI.tokenHistoryRows) do
        local historyIndex = #history - index + 1
        local entry = historyIndex >= 1 and history[historyIndex] or nil
        if entry then
            row.time:SetText(entry.relativeText or UIText("LABEL_UNKNOWN"))
            row.price:SetText(FormatProfitTokenGoldText(entry.priceCopper))
            row.change:SetText("")
            row:Show()
        else
            row.time:SetText("")
            row.price:SetText("")
            row.change:SetText("")
            row:Hide()
        end
    end

    if goldUI.tokenHistoryContent then
        goldUI.tokenHistoryContent:SetHeight(math.max(1, math.min(#history, 5) * 24))
    end
end

goldUI.pageTitle = GoldBox:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
goldUI.pageTitle:SetPoint("TOPLEFT", 28, -22)
goldUI.pageTitle:SetText(UIText("BUTTON_PROFIT"))

goldUI.pageSubtitle = GoldBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.pageSubtitle:SetPoint("TOPLEFT", goldUI.pageTitle, "BOTTOMLEFT", 0, -6)
goldUI.pageSubtitle:SetText(UIText("TEXT_PROFIT_SUBTITLE"))

goldUI.tokenCard = CreateProfitPanel(GoldBox, 212, 46)
goldUI.tokenCard:SetPoint("TOPRIGHT", GoldBox, "TOPRIGHT", -28, -22)
goldUI.tokenCard:EnableMouse(true)
goldUI.tokenCard:SetScript("OnEnter", function(self)
    ShowProfitTokenTooltip(self)
end)
goldUI.tokenCard:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
goldUI.tokenCard:SetScript("OnMouseUp", function()
    if goldUI.tokenHistoryPanel then
        UpdateProfitTokenHistoryPanel(lv.GetWowTokenInfo and lv.GetWowTokenInfo() or nil)
        goldUI.tokenHistoryPanel:SetShown(not goldUI.tokenHistoryPanel:IsShown())
    end
end)

goldUI.tokenTitle = goldUI.tokenCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.tokenTitle:SetPoint("TOPLEFT", 14, -10)
goldUI.tokenTitle:SetText(UIText("LABEL_WOW_TOKEN"))

goldUI.tokenValue = goldUI.tokenCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenValue:SetPoint("BOTTOMRIGHT", -14, 10)
goldUI.tokenValue:SetJustifyH("RIGHT")
goldUI.tokenValue:SetText(UIText("MSG_WOW_TOKEN_VISIT_AH_SHORT"))

goldUI.summaryCards = {}
local summaryCardDefs = {
    { key = "weekly", titleKey = "LABEL_WEEKLY_PROFIT", titleFallback = "Weekly Profit" },
    { key = "monthly", titleKey = "LABEL_MONTHLY_PROFIT", titleFallback = "Monthly Profit" },
    { key = "warband", titleKey = "LABEL_WARBAND_WEEKLY_PROFIT", titleFallback = "Warband Weekly Profit" },
}

for i, def in ipairs(summaryCardDefs) do
    local card = CreateProfitPanel(GoldBox, 282, 104)
    if i == 1 then
        card:SetPoint("TOPLEFT", 28, -72)
    else
        card:SetPoint("LEFT", goldUI.summaryCards[i - 1], "RIGHT", 16, 0)
    end

    card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.title:SetPoint("TOPLEFT", 16, -14)
    card.title:SetText(UIText(def.titleKey, def.titleFallback))

    card.meta = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.meta:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -8)
    card.meta:SetPoint("RIGHT", card, "RIGHT", -16, 0)
    card.meta:SetJustifyH("LEFT")
    card.meta:SetText("")
    card.meta:Hide()

    card.value = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    card.value:SetPoint("BOTTOMRIGHT", -16, 16)
    card.value:SetJustifyH("RIGHT")
    card.value:SetText(FormatGoldAligned(0, 16))
    card.graphMode = def.key
    card:EnableMouse(true)
    card:SetScript("OnEnter", function(self)
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            self:SetBackdropBorderColor(unpack(t.borderHover or t.borderPrimary))
        end
    end)
    card:SetScript("OnLeave", function(self)
        local t = lv.GetTheme and lv.GetTheme()
        if t then
            self:SetBackdropBorderColor(unpack(t.borderSecondary or t.borderPrimary))
        end
    end)

    goldUI.summaryCards[i] = card
    goldUI[def.key .. "Card"] = card
end

goldUI.title = goldUI.weeklyCard.title
goldUI.content = goldUI.weeklyCard.value
goldUI.warbandTitle = goldUI.warbandCard.title
goldUI.warbandContent = goldUI.warbandCard.value
goldUI.monthlyTitle = goldUI.monthlyCard.title
goldUI.monthlyContent = goldUI.monthlyCard.value

goldUI.tokenCard:ClearAllPoints()
goldUI.tokenCard:SetPoint("BOTTOM", goldUI.warbandCard, "TOP", 35, 4)

goldUI.tokenHistoryPanel = CreateFrame("Frame", "LiteVaultTokenHistoryWindow", UIParent, "BackdropTemplate")
goldUI.tokenHistoryPanel:SetSize(500, 320)
goldUI.tokenHistoryPanel:SetPoint("CENTER")
goldUI.tokenHistoryPanel:SetMovable(true)
goldUI.tokenHistoryPanel:EnableMouse(true)
goldUI.tokenHistoryPanel:RegisterForDrag("LeftButton")
goldUI.tokenHistoryPanel:SetScript("OnDragStart", goldUI.tokenHistoryPanel.StartMoving)
goldUI.tokenHistoryPanel:SetScript("OnDragStop", goldUI.tokenHistoryPanel.StopMovingOrSizing)
goldUI.tokenHistoryPanel:SetFrameStrata("DIALOG")
goldUI.tokenHistoryPanel:SetToplevel(true)
goldUI.tokenHistoryPanel:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
table.insert(UISpecialFrames, "LiteVaultTokenHistoryWindow")
goldUI.tokenHistoryPanel:Hide()

goldUI.tokenHistoryTitle = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
goldUI.tokenHistoryTitle:SetPoint("TOPLEFT", 15, -15)
goldUI.tokenHistoryTitle:SetJustifyH("LEFT")
goldUI.tokenHistoryTitle:SetText(UIText("TITLE_WOW_TOKEN_HISTORY"))

goldUI.tokenHistoryClose = CreateFrame("Button", nil, goldUI.tokenHistoryPanel, "BackdropTemplate")
goldUI.tokenHistoryClose:SetSize(60, 22)
goldUI.tokenHistoryClose:SetPoint("TOPRIGHT", -10, -10)
goldUI.tokenHistoryClose:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
goldUI.tokenHistoryClose.Text = goldUI.tokenHistoryClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
goldUI.tokenHistoryClose.Text:SetPoint("CENTER")
goldUI.tokenHistoryClose.Text:SetText(UIText("BUTTON_CLOSE"))
goldUI.tokenHistoryClose:SetScript("OnClick", function()
    goldUI.tokenHistoryPanel:Hide()
end)
goldUI.tokenHistoryClose:SetScript("OnEnter", function(self)
    local theme = lv.GetTheme and lv.GetTheme()
    if theme then
        self:SetBackdropBorderColor(unpack(theme.borderHover or theme.borderPrimary))
        self:SetBackdropColor(unpack(theme.buttonBgHover or theme.buttonBg))
        self.Text:SetTextColor(unpack(theme.textPrimary))
    end
end)
goldUI.tokenHistoryClose:SetScript("OnLeave", function(self)
    local theme = lv.GetTheme and lv.GetTheme()
    if theme then
        self:SetBackdropBorderColor(unpack(theme.borderPrimary))
        self:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
        self.Text:SetTextColor(unpack(theme.textPrimary))
    end
end)

goldUI.tokenHistoryCurrentLabel = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenHistoryCurrentLabel:SetPoint("TOPLEFT", 18, -50)
goldUI.tokenHistoryCurrentLabel:SetText(UIText("LABEL_CURRENT"))
goldUI.tokenHistoryCurrentValue = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
goldUI.tokenHistoryCurrentValue:SetPoint("TOPRIGHT", -18, -50)
goldUI.tokenHistoryCurrentValue:SetJustifyH("RIGHT")
goldUI.tokenHistoryCurrentValue:SetWidth(240)

goldUI.tokenHistoryPreviousLabel = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenHistoryPreviousLabel:SetPoint("TOPLEFT", 18, -76)
goldUI.tokenHistoryPreviousLabel:SetText(UIText("LABEL_PREVIOUS"))
goldUI.tokenHistoryPreviousValue = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
goldUI.tokenHistoryPreviousValue:SetPoint("TOPRIGHT", -18, -76)
goldUI.tokenHistoryPreviousValue:SetJustifyH("RIGHT")
goldUI.tokenHistoryPreviousValue:SetWidth(240)

goldUI.tokenHistoryChangeLabel = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenHistoryChangeLabel:SetPoint("TOPLEFT", 18, -102)
goldUI.tokenHistoryChangeLabel:SetText(UIText("LABEL_TOKEN_DELTA"))
goldUI.tokenHistoryChangeValue = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
goldUI.tokenHistoryChangeValue:SetPoint("TOPRIGHT", -18, -102)
goldUI.tokenHistoryChangeValue:SetJustifyH("RIGHT")
goldUI.tokenHistoryChangeValue:SetWidth(240)

goldUI.tokenHistoryUpdatedLabel = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenHistoryUpdatedLabel:SetPoint("TOPLEFT", 18, -128)
goldUI.tokenHistoryUpdatedLabel:SetText(UIText("LABEL_LAST_UPDATED"))
goldUI.tokenHistoryUpdatedValue = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
goldUI.tokenHistoryUpdatedValue:SetPoint("TOPRIGHT", -18, -128)
goldUI.tokenHistoryUpdatedValue:SetJustifyH("RIGHT")
goldUI.tokenHistoryUpdatedValue:SetWidth(240)

goldUI.tokenHistoryAffordableLabel = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenHistoryAffordableLabel:SetPoint("TOPLEFT", 18, -154)
goldUI.tokenHistoryAffordableLabel:SetText(UIText("LABEL_TOKEN_AFFORDABLE"))
goldUI.tokenHistoryAffordableValue = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
goldUI.tokenHistoryAffordableValue:SetPoint("TOPRIGHT", -18, -154)
goldUI.tokenHistoryAffordableValue:SetJustifyH("RIGHT")
goldUI.tokenHistoryAffordableValue:SetWidth(240)

goldUI.tokenHistoryHeader = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.tokenHistoryHeader:SetPoint("TOPLEFT", 18, -188)
goldUI.tokenHistoryHeader:SetText(UIText("LABEL_RECENT_HISTORY"))

goldUI.tokenHistoryStatus = goldUI.tokenHistoryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.tokenHistoryStatus:SetPoint("TOPLEFT", 18, -212)
goldUI.tokenHistoryStatus:SetPoint("TOPRIGHT", -18, -212)
goldUI.tokenHistoryStatus:SetJustifyH("LEFT")
goldUI.tokenHistoryStatus:SetWordWrap(true)
goldUI.tokenHistoryStatus:Hide()

goldUI.tokenHistoryScroll = CreateFrame("ScrollFrame", nil, goldUI.tokenHistoryPanel)
goldUI.tokenHistoryScroll:SetPoint("TOPLEFT", 18, -212)
goldUI.tokenHistoryScroll:SetPoint("BOTTOMRIGHT", -18, 18)
goldUI.tokenHistoryScroll:EnableMouseWheel(true)
goldUI.tokenHistoryContent = CreateFrame("Frame", nil, goldUI.tokenHistoryScroll)
goldUI.tokenHistoryContent:SetSize(446, 1)
goldUI.tokenHistoryScroll:SetScrollChild(goldUI.tokenHistoryContent)
goldUI.tokenHistoryScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = math.max(0, (goldUI.tokenHistoryContent:GetHeight() or 1) - self:GetHeight())
    local step = 24
    self:SetVerticalScroll(math.max(0, math.min(current - (delta * step), maxScroll)))
end)

goldUI.tokenHistoryRows = {}
for index = 1, 5 do
    local row = CreateFrame("Frame", nil, goldUI.tokenHistoryContent)
    row:SetSize(446, 24)
    row:SetPoint("TOPLEFT", 0, -((index - 1) * 24))
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    if index % 2 == 0 then
        row.bg:SetColorTexture(1, 1, 1, 0.05)
    else
        row.bg:SetColorTexture(0, 0, 0, 0.1)
    end
    row.time = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.time:SetPoint("LEFT", 8, 0)
    row.time:SetWidth(120)
    row.time:SetJustifyH("LEFT")
    row.price = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.price:SetPoint("RIGHT", -8, 0)
    row.price:SetWidth(180)
    row.price:SetJustifyH("RIGHT")
    row.change = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.change:SetPoint("RIGHT", 0, 0)
    row.change:SetWidth(0)
    row.change:SetJustifyH("RIGHT")
    row.change:Hide()
    goldUI.tokenHistoryRows[index] = row
end

goldUI.goalPanel = CreateProfitPanel(GoldBox, 878, 94)
goldUI.goalPanel:SetPoint("TOPLEFT", goldUI.weeklyCard, "BOTTOMLEFT", 0, -14)

goldUI.goalTitle = goldUI.goalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.goalTitle:SetPoint("TOPLEFT", 16, -12)
goldUI.goalTitle:SetText(UIText("LABEL_PROFIT_GOALS"))

goldUI.goalSubtitle = goldUI.goalPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.goalSubtitle:SetPoint("TOPLEFT", goldUI.goalTitle, "BOTTOMLEFT", 0, -4)
goldUI.goalSubtitle:SetText("")
goldUI.goalSubtitle:Hide()

goldUI.goalRows = {}

local function CreateProfitGoalRow(parent, period, labelText, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row.period = period
    row:SetSize(846, 22)
    row:SetPoint("TOPLEFT", 16, yOffset)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.label:SetPoint("LEFT", 0, 0)
    row.label:SetWidth(96)
    row.label:SetJustifyH("LEFT")
    row.label:SetText(labelText)

    row.status = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.status:SetPoint("LEFT", 110, 0)
    row.status:SetWidth(320)
    row.status:SetJustifyH("LEFT")

    row.remaining = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.remaining:SetPoint("LEFT", 0, 0)
    row.remaining:SetWidth(1)
    row.remaining:SetJustifyH("LEFT")
    row.remaining:Hide()

    row.barBg = row:CreateTexture(nil, "BACKGROUND")
    row.barBg:SetPoint("LEFT", 444, 0)
    row.barBg:SetSize(150, 8)
    row.barBg:SetColorTexture(0.28, 0.30, 0.34, 0.9)

    row.barFill = row:CreateTexture(nil, "ARTWORK")
    row.barFill:SetPoint("LEFT", row.barBg, "LEFT", 0, 0)
    row.barFill:SetHeight(8)
    row.barFill:Hide()

    row.percent = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.percent:SetPoint("LEFT", row.barBg, "RIGHT", 10, 0)
    row.percent:SetWidth(42)
    row.percent:SetJustifyH("RIGHT")

    row.button = CreateProfitHeaderButton(row, 56, UIText("BUTTON_SET"))
    row.button:SetPoint("RIGHT", 0, 0)
    row.button:SetScript("OnClick", function()
        ShowProfitGoalEditor(period)
    end)

    goldUI.goalRows[period] = row
    return row
end

CreateProfitGoalRow(goldUI.goalPanel, "week", UIText("LABEL_WEEKLY_GOAL"), -34)
CreateProfitGoalRow(goldUI.goalPanel, "month", UIText("LABEL_MONTHLY_GOAL"), -66)

goldUI.warbandHistoryBtn = CreateFrame("Button", nil, GoldBox, "BackdropTemplate")
goldUI.warbandHistoryBtn:SetSize(168, 20)
goldUI.warbandHistoryBtn:SetPoint("BOTTOM", GoldBox, "BOTTOM", -90, 18)
goldUI.warbandHistoryBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
goldUI.warbandHistoryBtn.Text = goldUI.warbandHistoryBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.warbandHistoryBtn.Text:SetPoint("CENTER")
goldUI.warbandHistoryBtn.Text:SetText(UIText("BUTTON_WARBAND_BANK_HISTORY"))
goldUI.warbandHistoryBtn:SetScript("OnClick", function()
    if lv.ShowWarbandLedger then
        lv.ShowWarbandLedger()
    end
end)
goldUI.warbandHistoryBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover or t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgHover or t.buttonBg))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
goldUI.warbandHistoryBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        self.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
    end
end)

goldUI.warbandBreakdownBtn = CreateFrame("Button", nil, GoldBox, "BackdropTemplate")
goldUI.warbandBreakdownBtn:SetSize(168, 20)
goldUI.warbandBreakdownBtn:SetPoint("LEFT", goldUI.warbandHistoryBtn, "RIGHT", 12, 0)
goldUI.warbandBreakdownBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
goldUI.warbandBreakdownBtn.Text = goldUI.warbandBreakdownBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.warbandBreakdownBtn.Text:SetPoint("CENTER")
goldUI.warbandBreakdownBtn.Text:SetText(UIText("BUTTON_WARBAND_PROFIT_BREAKDOWN"))
goldUI.warbandBreakdownBtn:EnableMouse(false)
goldUI.warbandBreakdownBtn:SetScript("OnClick", nil)
goldUI.warbandBreakdownBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderHover or t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgHover or t.buttonBg))
        self.Text:SetTextColor(unpack(t.textPrimary))
    end
end)
goldUI.warbandBreakdownBtn:Hide()
goldUI.warbandBreakdownBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme and lv.GetTheme()
    if t then
        self:SetBackdropBorderColor(unpack(t.borderPrimary))
        self:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        self.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
    end
end)

goldUI.weeklyListPanel = CreateProfitPanel(GoldBox, 438, 356)
goldUI.weeklyListPanel:SetPoint("TOPLEFT", goldUI.goalPanel, "BOTTOMLEFT", 0, -12)
goldUI.monthlyListPanel = CreateProfitPanel(GoldBox, 438, 356)
goldUI.monthlyListPanel:SetPoint("TOPRIGHT", goldUI.goalPanel, "BOTTOMRIGHT", 0, -12)

goldUI.earnersTitle = goldUI.weeklyListPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.earnersTitle:SetPoint("TOPLEFT", 18, -16)
goldUI.earnersTitle:SetText(UIText("LABEL_TOP_WEEKLY_EARNERS"))

goldUI.earnersSubtitle = goldUI.weeklyListPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.earnersSubtitle:SetPoint("TOPLEFT", goldUI.earnersTitle, "BOTTOMLEFT", 0, -6)
goldUI.earnersSubtitle:SetText(UIText("TEXT_TOP_WEEKLY_EARNERS_SUBTITLE"))

goldUI.weeklyListScroll = CreateFrame("ScrollFrame", nil, goldUI.weeklyListPanel)
goldUI.weeklyListScroll:SetPoint("TOPLEFT", 8, -54)
goldUI.weeklyListScroll:SetPoint("BOTTOMRIGHT", -8, 8)
ConfigureProfitHiddenScroll(goldUI.weeklyListScroll)

goldUI.weeklyListContent = CreateFrame("Frame", nil, goldUI.weeklyListScroll)
goldUI.weeklyListContent:SetSize(420, 1)
goldUI.weeklyListScroll:SetScrollChild(goldUI.weeklyListContent)

goldUI.monthlyEarnersTitle = goldUI.monthlyListPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
goldUI.monthlyEarnersTitle:SetPoint("TOPLEFT", 18, -16)
goldUI.monthlyEarnersTitle:SetText(UIText("LABEL_TOP_MONTHLY_EARNERS"))

goldUI.monthlyEarnersSubtitle = goldUI.monthlyListPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
goldUI.monthlyEarnersSubtitle:SetPoint("TOPLEFT", goldUI.monthlyEarnersTitle, "BOTTOMLEFT", 0, -6)
goldUI.monthlyEarnersSubtitle:SetText(UIText("TEXT_TOP_MONTHLY_EARNERS_SUBTITLE"))

goldUI.monthlyListScroll = CreateFrame("ScrollFrame", nil, goldUI.monthlyListPanel)
goldUI.monthlyListScroll:SetPoint("TOPLEFT", 8, -54)
goldUI.monthlyListScroll:SetPoint("BOTTOMRIGHT", -8, 8)
ConfigureProfitHiddenScroll(goldUI.monthlyListScroll)

goldUI.monthlyListContent = CreateFrame("Frame", nil, goldUI.monthlyListScroll)
goldUI.monthlyListContent:SetSize(420, 1)
goldUI.monthlyListScroll:SetScrollChild(goldUI.monthlyListContent)

goldUI.earnRows = {}
lv.earnRows = goldUI.earnRows

goldUI.monthlyEarnRows = {}
lv.monthlyEarnRows = goldUI.monthlyEarnRows

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        for _, card in ipairs(goldUI.summaryCards) do
            lv.RegisterThemedElement(card, ApplyProfitPanelTheme)
        end
        lv.RegisterThemedElement(goldUI.tokenCard, ApplyProfitPanelTheme)
        lv.RegisterThemedElement(goldUI.tokenHistoryPanel, function(frame, theme)
            frame:SetBackdropColor(unpack(theme.backgroundSolid or theme.background))
            frame:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        lv.RegisterThemedElement(goldUI.goalPanel, ApplyProfitPanelTheme)
        lv.RegisterThemedElement(goldUI.warbandHistoryBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.warbandBreakdownBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.weeklyListPanel, ApplyProfitPanelTheme)
        lv.RegisterThemedElement(goldUI.monthlyListPanel, ApplyProfitPanelTheme)
        lv.RegisterThemedElement(goldUI.pageTitle, function(label, theme)
            label:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.pageSubtitle, function(label, theme)
            label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.goalTitle, function(label, theme)
            label:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.tokenTitle, function(label, theme)
            label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.tokenValue, function(label, theme)
            label:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryTitle, function(label, theme)
            label:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryClose, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryCurrentLabel, function(label, theme)
            label:SetTextColor(1, 0.84, 0)
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryPreviousLabel, function(label, theme)
            label:SetTextColor(1, 0.84, 0)
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryChangeLabel, function(label, theme)
            label:SetTextColor(1, 0.84, 0)
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryUpdatedLabel, function(label, theme)
            label:SetTextColor(1, 0.84, 0)
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryAffordableLabel, function(label, theme)
            label:SetTextColor(1, 0.84, 0)
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryHeader, function(label, theme)
            label:SetTextColor(1, 1, 0)
        end)
        lv.RegisterThemedElement(goldUI.tokenHistoryStatus, function(label, theme)
            label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
        end)
        for _, row in ipairs(goldUI.tokenHistoryRows or {}) do
            lv.RegisterThemedElement(row.time, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(row.price, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(row.change, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
        end
        lv.RegisterThemedElement(goldUI.goalSubtitle, function(label, theme)
            label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
        end)
        for _, card in ipairs(goldUI.summaryCards) do
            lv.RegisterThemedElement(card.title, function(label, theme)
                label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.meta, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(card.value, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
        end
        for _, row in pairs(goldUI.goalRows) do
            lv.RegisterThemedElement(row.label, function(label, theme)
                label:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(row.status, function(label, theme)
                label:SetTextColor(unpack(theme.textPrimary))
            end)
            lv.RegisterThemedElement(row.remaining, function(label, theme)
                label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            end)
            lv.RegisterThemedElement(row.button, function(btn, theme)
                btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
                btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
                btn.Text:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
            end)
        end
        lv.RegisterThemedElement(goldUI.earnersTitle, function(label, theme)
            label:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.earnersSubtitle, function(label, theme)
            label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.monthlyEarnersTitle, function(label, theme)
            label:SetTextColor(unpack(theme.textPrimary))
        end)
        lv.RegisterThemedElement(goldUI.monthlyEarnersSubtitle, function(label, theme)
            label:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
        end)
    end

    local t = lv.GetTheme and lv.GetTheme()
    if t then
        goldUI.pageTitle:SetTextColor(unpack(t.textPrimary))
        goldUI.pageSubtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
        for _, card in ipairs(goldUI.summaryCards) do
            ApplyProfitPanelTheme(card, t)
            card.title:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            card.meta:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            card.value:SetTextColor(unpack(t.textPrimary))
        end
        ApplyProfitPanelTheme(goldUI.tokenCard, t)
        goldUI.tokenTitle:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        goldUI.tokenHistoryPanel:SetBackdropColor(unpack(t.backgroundSolid or t.background))
        goldUI.tokenHistoryPanel:SetBackdropBorderColor(unpack(t.borderPrimary))
        goldUI.tokenHistoryTitle:SetTextColor(unpack(t.textPrimary))
        goldUI.tokenHistoryClose:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        goldUI.tokenHistoryClose:SetBackdropBorderColor(unpack(t.borderPrimary))
        goldUI.tokenHistoryClose.Text:SetTextColor(unpack(t.textPrimary))
        goldUI.tokenHistoryCurrentLabel:SetTextColor(1, 0.84, 0)
        goldUI.tokenHistoryPreviousLabel:SetTextColor(1, 0.84, 0)
        goldUI.tokenHistoryChangeLabel:SetTextColor(1, 0.84, 0)
        goldUI.tokenHistoryUpdatedLabel:SetTextColor(1, 0.84, 0)
        goldUI.tokenHistoryAffordableLabel:SetTextColor(1, 0.84, 0)
        goldUI.tokenHistoryHeader:SetTextColor(1, 1, 0)
        goldUI.tokenHistoryStatus:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        for _, row in ipairs(goldUI.tokenHistoryRows or {}) do
            row.time:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            row.price:SetTextColor(unpack(t.textPrimary))
            row.change:SetTextColor(unpack(t.textPrimary))
        end
        ApplyProfitPanelTheme(goldUI.goalPanel, t)
        goldUI.goalTitle:SetTextColor(unpack(t.textPrimary))
        goldUI.goalSubtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
        for _, row in pairs(goldUI.goalRows) do
            row.label:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            row.status:SetTextColor(unpack(t.textPrimary))
            row.remaining:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
            row.button:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
            row.button:SetBackdropBorderColor(unpack(t.borderPrimary))
            row.button.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
            row.barBg:SetColorTexture(unpack(t.borderSecondary or t.borderPrimary))
        end
        goldUI.warbandHistoryBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        goldUI.warbandHistoryBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        goldUI.warbandHistoryBtn.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        goldUI.warbandBreakdownBtn:SetBackdropColor(unpack(t.buttonBgAlt or t.buttonBg))
        goldUI.warbandBreakdownBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        goldUI.warbandBreakdownBtn.Text:SetTextColor(unpack(t.textSecondary or t.textPrimary))
        ApplyProfitPanelTheme(goldUI.weeklyListPanel, t)
        ApplyProfitPanelTheme(goldUI.monthlyListPanel, t)
        goldUI.earnersTitle:SetTextColor(unpack(t.textPrimary))
        goldUI.earnersSubtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
        goldUI.monthlyEarnersTitle:SetTextColor(unpack(t.textPrimary))
        goldUI.monthlyEarnersSubtitle:SetTextColor(unpack(t.textMuted or t.textSecondary or t.textPrimary))
    end
end)

-- 5. UPDATE FUNCTIONS
local function GetWarbandTransferNet(summary)
    if type(summary) == "table" then
        return summary.net or 0
    end
    return 0
end

local function GetTransferAdjustedWeeklyDelta(charKey, charData)
    local summary = GetSummaryForPeriod("week", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    return summary.net or 0
end

local function GetTransferAdjustedMonthlyDelta(charKey, charData)
    local summary = GetSummaryForPeriod("month", {
        charKey = charKey,
        includeIgnored = true,
        region = nil,
    })
    return summary.net or 0
end

local function UpdateProfitGoalRow(row, progress)
    if not row then
        return
    end

    local goalAmount = progress and tonumber(progress.goal) or 0
    local currentAmount = progress and tonumber(progress.current) or 0
    local clampedPercent = math.max(0, math.min(1, progress and tonumber(progress.percent) or 0))

    if goalAmount > 0 then
        row.status:SetText(string.format("%s / %s", FormatProfitGraphAmount(currentAmount), FormatGoldAligned(goalAmount, 14)))
        row.percent:SetText(FormatProfitGoalPercentText(clampedPercent))
        row.button.Text:SetText(UIText("BUTTON_EDIT"))
    else
        row.status:SetText(UIText("MSG_PROFIT_GOAL_NOT_SET"))
        row.percent:SetText("0%")
        row.button.Text:SetText(UIText("BUTTON_SET"))
    end

    row.remaining:SetText("")
    local totalBarWidth = row.barBg:GetWidth() or 150
    local barWidth = totalBarWidth * clampedPercent
    row.barFill:ClearAllPoints()
    row.barFill:SetPoint("LEFT", row.barBg, "LEFT", 0, 0)
    row.barFill:SetWidth(math.max(0, barWidth))
    if progress and progress.met then
        row.barFill:SetColorTexture(0.14, 0.82, 0.34, 1)
    else
        row.barFill:SetColorTexture(0.93, 0.72, 0.22, 1)
    end
    row.barFill:SetShown(goalAmount > 0 and barWidth > 0)
end

local function UpdateSummaryCard(card, summary, mode)
    if not card then
        return
    end
    card.value:SetText(FormatProfitGraphAmount(summary.net or 0))
    if card.meta then
        card.meta:SetText("")
        card.meta:Hide()
    end
    card.graphMode = mode
end

local function PopulateTopEarnersList(pool, parent, scrollFrame, listContent, entries, period)
    for _, row in ipairs(pool) do
        row:Hide()
    end

    local contentWidth = math.max(1, scrollFrame:GetWidth())
    local yOffset = 0
    for index, entry in ipairs(entries or {}) do
        local row = GetProfitListRow(pool, parent, index)
        local nameText = string.format("%d. %s", index, GetCharacterDisplayName(entry.charKey))
        local charData = GetCharacterRecord(entry.charKey)
        if charData and charData.class then
            local classColor = C_ClassColor.GetClassColor(charData.class)
            if classColor then
                nameText = string.format("%d. %s", index, classColor:WrapTextInColorCode(GetCharacterDisplayName(entry.charKey)))
            end
        end

        row.name:SetText(nameText)
        row.gold:SetText(FormatProfitGraphAmount(entry.amount or 0))
        row:EnableMouse(true)
        row:SetScript("OnMouseUp", function()
            ShowProfitDetail(period, entry.charKey)
        end)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 6, -yOffset)
        row:SetPoint("RIGHT", parent, "RIGHT", -6, 0)
        row:Show()
        yOffset = yOffset + 58
    end

    listContent:SetHeight(math.max(1, yOffset))
    listContent:SetWidth(contentWidth)
    scrollFrame:SetVerticalScroll(0)
end

function lv.UpdateTrackingDisplays()
    if not LiteVaultDB or not LiteVaultDB[lv.PLAYER_KEY] then return end
    local data = LiteVaultDB[lv.PLAYER_KEY]
    local cCol = C_ClassColor.GetClassColor(data.class or "WARRIOR")
    weeklyUI.title:SetText(string.format(L["LABEL_WEEKLY_QUESTS"], "|c" .. cCol:GenerateHexColor() .. UnitName("player") .. "|r"))
    
    data.weeklyQuests = data.weeklyQuests or {}
    local questList = GetCurrentWeeklyQuestList()
    UpdateWeeklyWarningLayout(BuildWeeklyWarningText())
    weeklyUI.content:SetText(BuildWeeklyQuestText(data, questList))

    local currentCharOpts = BuildCurrentCharacterProfitOpts()
    local weeklySummary = GetSummaryForPeriod("week", currentCharOpts)
    local monthlySummary = GetSummaryForPeriod("month", currentCharOpts)
    local warbandSummary = GetSummaryForPeriod("week")
    local weeklyGoalProgress = lv.GetProfitGoalProgress and lv.GetProfitGoalProgress("week") or nil
    local monthlyGoalProgress = lv.GetProfitGoalProgress and lv.GetProfitGoalProgress("month") or nil
    local weeklyTopEarners = lv.GetProfitTopEarners and lv.GetProfitTopEarners("week", 5) or {}
    local monthlyTopEarners = lv.GetProfitTopEarners and lv.GetProfitTopEarners("month", 5) or {}
    local tokenText, tokenInfo = GetProfitTokenDisplayText()
    local theme = lv.GetTheme and lv.GetTheme() or nil

    UpdateSummaryCard(goldUI.weeklyCard, weeklySummary, "weekly")
    UpdateSummaryCard(goldUI.monthlyCard, monthlySummary, "monthly")
    UpdateSummaryCard(goldUI.warbandCard, warbandSummary, "warband")
    if goldUI.tokenValue then
        goldUI.tokenValue:SetText(tokenText or "")
        if theme then
            if not tokenInfo or not tokenInfo.supported or not tokenInfo.price then
                goldUI.tokenValue:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            elseif tokenInfo.stale then
                goldUI.tokenValue:SetTextColor(unpack(theme.textMuted or theme.textSecondary or theme.textPrimary))
            elseif tokenInfo.canAfford then
                goldUI.tokenValue:SetTextColor(0.2, 0.9, 0.2)
            else
                goldUI.tokenValue:SetTextColor(unpack(theme.textPrimary))
            end
        end
    end
    UpdateProfitTokenHistoryPanel(tokenInfo)

    goldUI.weeklyCard:SetScript("OnMouseUp", function()
        ShowProfitDetail("weekly", GetCurrentProfitCharKey())
    end)
    goldUI.monthlyCard:SetScript("OnMouseUp", function()
        ShowProfitDetail("monthly", GetCurrentProfitCharKey())
    end)
    goldUI.warbandCard:SetScript("OnMouseUp", function()
        ShowProfitDetail("warband")
    end)

    goldUI.warbandBreakdownBtn:EnableMouse(true)
    goldUI.warbandBreakdownBtn:SetScript("OnClick", ShowWarbandProfitBreakdown)
    goldUI.warbandBreakdownBtn:Show()

    UpdateProfitGoalRow(goldUI.goalRows.week, weeklyGoalProgress)
    UpdateProfitGoalRow(goldUI.goalRows.month, monthlyGoalProgress)

    PopulateTopEarnersList(lv.earnRows, goldUI.weeklyListContent, goldUI.weeklyListScroll, goldUI.weeklyListContent, weeklyTopEarners, "weekly")
    PopulateTopEarnersList(lv.monthlyEarnRows, goldUI.monthlyListContent, goldUI.monthlyListScroll, goldUI.monthlyListContent, monthlyTopEarners, "monthly")

    if lv.ProfitGraphWindow and lv.ProfitGraphWindow:IsShown() then
        lv.RefreshOpenProfitWindow()
    end
end

function lv.UpdateProfitLocalizationText()
    if type(goldUI) ~= "table" then
        return
    end
    if not (goldUI.title and goldUI.warbandTitle and goldUI.earnersTitle) then
        return
    end

    goldUI.title:SetText(L["LABEL_WEEKLY_PROFIT"])
    goldUI.warbandTitle:SetText(L["LABEL_WARBAND_PROFIT"])
    if goldUI.warbandHistoryBtn and goldUI.warbandHistoryBtn.Text then
        goldUI.warbandHistoryBtn.Text:SetText(UIText("BUTTON_WARBAND_BANK_HISTORY"))
    end
    if goldUI.warbandBreakdownBtn and goldUI.warbandBreakdownBtn.Text then
        goldUI.warbandBreakdownBtn.Text:SetText(UIText("BUTTON_WARBAND_PROFIT_BREAKDOWN"))
    end
    if goldUI.goalTitle then
        goldUI.goalTitle:SetText(UIText("LABEL_PROFIT_GOALS"))
    end
    if goldUI.goalSubtitle then
        goldUI.goalSubtitle:SetText(UIText("TEXT_PROFIT_GOALS_SUBTITLE"))
    end
    if goldUI.goalRows and goldUI.goalRows.week and goldUI.goalRows.week.label then
        goldUI.goalRows.week.label:SetText(UIText("LABEL_WEEKLY_GOAL"))
    end
    if goldUI.goalRows and goldUI.goalRows.month and goldUI.goalRows.month.label then
        goldUI.goalRows.month.label:SetText(UIText("LABEL_MONTHLY_GOAL"))
    end
    if goldUI.pageTitle then
        goldUI.pageTitle:SetText(UIText("BUTTON_PROFIT"))
    end
    if goldUI.pageSubtitle then
        goldUI.pageSubtitle:SetText(UIText("TEXT_PROFIT_SUBTITLE"))
    end
    if goldUI.tokenTitle then
        goldUI.tokenTitle:SetText(UIText("LABEL_WOW_TOKEN"))
    end
    if goldUI.monthlyTitle then
        goldUI.monthlyTitle:SetText((L["LABEL_MONTHLY_PROFIT"] ~= "LABEL_MONTHLY_PROFIT") and L["LABEL_MONTHLY_PROFIT"] or "Monthly Profit")
    end
    if goldUI.warbandTitle then
        goldUI.warbandTitle:SetText(UIText("LABEL_WARBAND_WEEKLY_PROFIT"))
    end
    goldUI.earnersTitle:SetText((L["LABEL_TOP_WEEKLY_EARNERS"] ~= "LABEL_TOP_WEEKLY_EARNERS") and L["LABEL_TOP_WEEKLY_EARNERS"] or "Top Weekly Earners")
    if goldUI.earnersSubtitle then
        goldUI.earnersSubtitle:SetText(UIText("TEXT_TOP_WEEKLY_EARNERS_SUBTITLE"))
    end
    if goldUI.monthlyEarnersTitle then
        goldUI.monthlyEarnersTitle:SetText((L["LABEL_TOP_MONTHLY_EARNERS"] ~= "LABEL_TOP_MONTHLY_EARNERS") and L["LABEL_TOP_MONTHLY_EARNERS"] or "Top Monthly Earners")
    end
    if goldUI.monthlyEarnersSubtitle then
        goldUI.monthlyEarnersSubtitle:SetText(UIText("TEXT_TOP_MONTHLY_EARNERS_SUBTITLE"))
    end
end
