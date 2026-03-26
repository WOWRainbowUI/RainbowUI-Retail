-- Ledger.lua - Weekly Profit Ledger
local addonName, lv = ...
local L = lv.L

-- Known cache/container items that give gold (track under Cache/Trove)
local CACHE_ITEMS = {
    [224784] = true,  -- Pinnacle Cache (old)
    [244865] = true,  -- Pinnacle Cache
    [226103] = true,  -- The Weaver's Trove
    [232463] = true,  -- Overflowing Undermine Trove
    [224585] = true,  -- Socially Expected Tip Chest
    [250764] = true,  -- Nanny's Surge Dividends
    [250766] = true,  -- Radiant Cache
    [250765] = true,  -- Awakened Mechanical Cache
    [250763] = true,  -- Theater Troupe's Trove
    [217011] = true,  -- Amateur Actor's Chest
    [217012] = true,  -- Novice Actor's Chest
    [217013] = true,  -- Expert Actor's Chest
    [235151] = true,  -- Distinguished Actor's Chest
    [244883] = true,  -- Seasoned Undermine Adventurer's Cache

    [268490] = true,  -- Apex Cache
    [268489] = true,  -- Surplus Bag of Party Favors
    [268487] = true,  -- Avid Learner's Supply Pack
    [268488] = true,  -- Overflowing Abundant Satchel
    [268485] = true,  -- Victorious Stormarion Pinnacle Cache
    [264274] = true,  -- Fabled Adventurer's Cache
}

-- Track cache item counts to detect when they're used
local cacheItemCounts = {}

-- Gold source categories (names are set dynamically from locale)
lv.LEDGER_SOURCES = {
    {key = "quest", nameKey = "LEDGER_QUESTS", icon = 236376},           -- Quest icon
    {key = "auction", nameKey = "LEDGER_AUCTION", icon = 133784},  -- AH icon
    {key = "trade", nameKey = "LEDGER_TRADE", icon = 236448},            -- Trade icon
    {key = "vendor", nameKey = "LEDGER_VENDOR", icon = 133785},          -- Merchant icon
    {key = "repair", nameKey = "LEDGER_REPAIRS", icon = 132281},         -- Ability_repair
    {key = "transmog", nameKey = "LEDGER_TRANSMOG", icon = 135019},      -- White shirt icon
    {key = "flightpath", nameKey = "LEDGER_FLIGHT", icon = 132239}, -- Ability_mount_gryphon_01
    {key = "crafting", nameKey = "LEDGER_CRAFTING", icon = 136241},      -- Tradeskill icon
    {key = "cache", nameKey = "LEDGER_CACHE", icon = 134344},      -- Chest icon
    {key = "mail", nameKey = "LEDGER_MAIL", icon = 133468},              -- Mail icon
    {key = "loot", nameKey = "LEDGER_LOOT", icon = 133786},              -- Loot bag icon
    {key = "other", nameKey = "LEDGER_OTHER", icon = 133786},            -- Misc icon
}

-- Tracking state
local lastMoney = 0
local inQuest = false
local inAuction = false
local inTrade = false
local inVendor = false
local inRepairMerchant = false  -- Track if at a repair-capable merchant
local inTransmog = false        -- Track if at transmogrifier
local inFlightPath = false      -- Track if at flight master
local inMail = false
local inAuctionMail = false     -- Track if collecting gold from AH sale mail
local inLoot = false
local inWarbandBank = false
local inCrafting = false       -- Track if in crafting/profession window
local inTrainer = false        -- Track if at a profession/class trainer
local recentCraftingActivity = false -- Catch delayed profession gold changes after UI closes
local currentLedgerChar = nil  -- Track which character's ledger is open

local function MarkRecentCraftingActivity(duration)
    recentCraftingActivity = true
    C_Timer.After(duration or 8, function()
        recentCraftingActivity = false
    end)
end

local function Use24HourLedgerTime()
    if GetCVarBool then
        return GetCVarBool("timeMgrUseMilitaryTime")
    end
    return not (LiteVaultDB and LiteVaultDB.use24HourClock == false)
end

local function FormatLedgerAbsoluteTime(timestamp)
    local ts = timestamp or time()
    if Use24HourLedgerTime() then
        return date("%m/%d %H:%M", ts)
    end
    return date("%m/%d %I:%M %p", ts)
end

-- Initialize ledger for a character
local function InitLedger(charKey)
    if not LiteVaultDB[charKey] then return end
    if not LiteVaultDB[charKey].weeklyLedger then
        LiteVaultDB[charKey].weeklyLedger = {}
    end
    local ledger = LiteVaultDB[charKey].weeklyLedger
    for _, source in ipairs(lv.LEDGER_SOURCES) do
        if not ledger[source.key] then
            ledger[source.key] = {income = 0, expense = 0}
        end
    end
end

-- Track recent loot activity separately (for cache detection)
local recentLootActivity = false
local recentCacheUsed = false  -- Track when cache/trove items are opened

-- Get the active gold source based on current state
-- Pass goldDiff to determine if this is an expense (for repair/transmog/etc detection)
local function GetActiveSource(goldDiff)
    -- Check frame visibility as backup (more reliable than just events)
    if inWarbandBank or (BankFrame and BankFrame:IsShown()) then return "warbandBank" end
    if inAuction or (AuctionHouseFrame and AuctionHouseFrame:IsShown()) then return "auction" end
    if inCrafting or inTrainer or recentCraftingActivity or (ProfessionsFrame and ProfessionsFrame:IsShown()) then return "crafting" end
    if inTrade or (TradeFrame and TradeFrame:IsShown()) then return "trade" end
    -- Transmog detection: at transmogrifier + gold decreased = transmog cost
    if inTransmog and goldDiff and goldDiff < 0 then return "transmog" end
    -- Repair detection: at repair merchant + gold decreased = repair cost
    if inRepairMerchant and goldDiff and goldDiff < 0 then return "repair" end
    -- Flight path detection: at flight master + gold decreased = flight cost
    if inFlightPath and goldDiff and goldDiff < 0 then return "flightpath" end
    if inVendor or (MerchantFrame and MerchantFrame:IsShown()) then return "vendor" end
    -- Check for auction house mail (sales) before regular mail
    if inAuctionMail then return "auction" end
    if inMail or (MailFrame and MailFrame:IsShown()) then return "mail" end

    -- Cache/Trove detection - check before quest since quest rewards often include cache items
    if recentCacheUsed then return "cache" end

    -- Quest detection (including world quests) - check before loot since quest rewards show loot frame
    if inQuest then return "quest" end

    -- Loot detection (mob drops, chests)
    if inLoot or recentLootActivity or (LootFrame and LootFrame:IsShown()) then return "loot" end

    return "other"
end

-- Record a gold change to the ledger
local function RecordGoldChange(amount, source)
    -- Warband bank transfers are tracked in the dedicated Warband tab, not per-character ledger.
    if source == "warbandBank" then return end

    local charKey = lv.PLAYER_KEY
    if not charKey then return end
    if not LiteVaultDB then return end

    -- Don't track for declined characters
    local declined = LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[charKey]
    if declined or not LiteVaultDB[charKey] then return end

    InitLedger(charKey)
    local ledger = LiteVaultDB[charKey].weeklyLedger

    if not ledger[source] then
        ledger[source] = {income = 0, expense = 0}
    end

    if amount > 0 then
        ledger[source].income = (ledger[source].income or 0) + amount
    else
        ledger[source].expense = (ledger[source].expense or 0) + math.abs(amount)
    end

    -- Log individual transaction for history
    if not ledger.transactions then
        ledger.transactions = {}
    end
    table.insert(ledger.transactions, 1, {
        amount = amount,
        source = source,
        timestamp = time()
    })
    -- Keep only last 3000 transactions
    while #ledger.transactions > 3000 do
        table.remove(ledger.transactions)
    end
end

-- Format gold as "XXg XXs XXc"
local function FormatGoldText(copper, showSign)
    if copper == 0 then return "0g 0s 0c" end

    local sign = ""
    if showSign then
        sign = copper >= 0 and "|cff00ff00+|r" or "|cffff0000-|r"
    end

    copper = math.abs(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copperAmt = copper % 100

    return string.format("%s%dg %ds %dc", sign, gold, silver, copperAmt)
end

-- Format gold with color
local function FormatGoldColored(copper)
    if copper == 0 then return "|cff888888-|r" end

    local color = copper >= 0 and "00ff00" or "ff4444"
    local sign = copper >= 0 and "+" or "-"

    copper = math.abs(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copperAmt = copper % 100

    if gold > 0 then
        return string.format("|cff%s%s%dg %ds %dc|r", color, sign, gold, silver, copperAmt)
    elseif silver > 0 then
        return string.format("|cff%s%s%ds %dc|r", color, sign, silver, copperAmt)
    else
        return string.format("|cff%s%s%dc|r", color, sign, copperAmt)
    end
end

-- Event frame for tracking gold sources
local ledgerFrame = CreateFrame("Frame")
ledgerFrame:RegisterEvent("ADDON_LOADED")
ledgerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ledgerFrame:RegisterEvent("PLAYER_MONEY")

-- Quest events
ledgerFrame:RegisterEvent("QUEST_ACCEPTED")
ledgerFrame:RegisterEvent("QUEST_TURNED_IN")
ledgerFrame:RegisterEvent("QUEST_COMPLETE")
ledgerFrame:RegisterEvent("QUEST_FINISHED")
ledgerFrame:RegisterEvent("QUEST_REMOVED")           -- Fires when world quests complete
ledgerFrame:RegisterEvent("QUEST_LOG_UPDATE")        -- Fires on quest state changes
ledgerFrame:RegisterEvent("QUEST_AUTOCOMPLETE")      -- Fires for auto-complete quests (world quests)

-- Auction events
ledgerFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
ledgerFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

-- Trade events
ledgerFrame:RegisterEvent("TRADE_SHOW")
ledgerFrame:RegisterEvent("TRADE_CLOSED")

-- Vendor events
ledgerFrame:RegisterEvent("MERCHANT_SHOW")
ledgerFrame:RegisterEvent("MERCHANT_CLOSED")

-- Transmog events
ledgerFrame:RegisterEvent("TRANSMOGRIFY_OPEN")
ledgerFrame:RegisterEvent("TRANSMOGRIFY_CLOSE")

-- Flight path events
ledgerFrame:RegisterEvent("TAXIMAP_OPENED")
ledgerFrame:RegisterEvent("TAXIMAP_CLOSED")

-- Mail events
ledgerFrame:RegisterEvent("MAIL_SHOW")
ledgerFrame:RegisterEvent("MAIL_CLOSED")

-- Crafting events
ledgerFrame:RegisterEvent("TRADE_SKILL_SHOW")
ledgerFrame:RegisterEvent("TRADE_SKILL_CLOSE")
ledgerFrame:RegisterEvent("CRAFTINGORDERS_SHOW_CUSTOMER")
ledgerFrame:RegisterEvent("CRAFTINGORDERS_HIDE_CUSTOMER")
ledgerFrame:RegisterEvent("CRAFTINGORDERS_SHOW_CRAFTER")
ledgerFrame:RegisterEvent("CRAFTINGORDERS_HIDE_CRAFTER")
ledgerFrame:RegisterEvent("TRAINER_SHOW")
ledgerFrame:RegisterEvent("TRAINER_CLOSED")

-- Loot events
ledgerFrame:RegisterEvent("LOOT_OPENED")
ledgerFrame:RegisterEvent("LOOT_CLOSED")
ledgerFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")  -- Detect cache item usage
ledgerFrame:RegisterEvent("BAG_UPDATE_DELAYED")        -- Detect cache item consumption

-- Bank events
ledgerFrame:RegisterEvent("BANKFRAME_OPENED")
ledgerFrame:RegisterEvent("BANKFRAME_CLOSED")

ledgerFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == addonName then
        lastMoney = GetMoney()
        C_Timer.After(1, function()
            if LiteVaultDB and LiteVaultDB[lv.PLAYER_KEY] then
                InitLedger(lv.PLAYER_KEY)
            end
        end)

        -- Hook mail functions to detect AH sale gold collection
        -- TakeInboxMoney is called when manually taking gold from a mail
        hooksecurefunc("TakeInboxMoney", function(index)
            local invoiceType = GetInboxInvoiceInfo(index)
            if invoiceType == "seller" then
                inAuctionMail = true
                C_Timer.After(1, function() inAuctionMail = false end)
            end
        end)

        -- AutoLootMailItem is called when auto-looting mail (shift-click or "Open All")
        hooksecurefunc("AutoLootMailItem", function(index)
            local invoiceType = GetInboxInvoiceInfo(index)
            if invoiceType == "seller" then
                inAuctionMail = true
                C_Timer.After(1, function() inAuctionMail = false end)
            end
        end)

        -- Hook container item usage to detect cache items being opened
        hooksecurefunc(C_Container, "UseContainerItem", function(bagID, slot)
            local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
            if itemInfo and itemInfo.itemID and CACHE_ITEMS[itemInfo.itemID] then
                recentCacheUsed = true
                C_Timer.After(10, function() recentCacheUsed = false end)
            end
        end)

    elseif event == "PLAYER_ENTERING_WORLD" then
        lastMoney = GetMoney()
        -- Initialize cache item counts for tracking consumption
        for itemID in pairs(CACHE_ITEMS) do
            cacheItemCounts[itemID] = C_Item.GetItemCount(itemID, true) or 0
        end

    elseif event == "PLAYER_MONEY" then
        local currentMoney = GetMoney()
        local diff = currentMoney - lastMoney
        lastMoney = currentMoney

        if diff ~= 0 then
            local source = GetActiveSource(diff)
            RecordGoldChange(diff, source)

            -- Auto-refresh ledger window if it's open
            if lv.LVLedgerWindow and lv.LVLedgerWindow:IsShown() and currentLedgerChar then
                lv.ShowLedgerWindow(currentLedgerChar, true)  -- true = refresh mode, don't toggle
            end
        end

    -- Quest tracking (includes world quests)
    elseif event == "QUEST_ACCEPTED" or event == "QUEST_COMPLETE" then
        inQuest = true
        C_Timer.After(5, function() inQuest = false end)
    elseif event == "QUEST_TURNED_IN" then
        inQuest = true
        C_Timer.After(5, function() inQuest = false end)
    elseif event == "QUEST_REMOVED" then
        -- World quests fire this when completed, gold reward comes shortly after
        inQuest = true
        C_Timer.After(5, function() inQuest = false end)
    elseif event == "QUEST_LOG_UPDATE" then
        -- Quest log changed - could be world quest completing
        -- Short window to catch immediate gold rewards
        inQuest = true
        C_Timer.After(2, function() inQuest = false end)
    elseif event == "QUEST_AUTOCOMPLETE" then
        -- Auto-complete quests (world quests, bonus objectives)
        inQuest = true
        C_Timer.After(10, function() inQuest = false end)
    elseif event == "QUEST_FINISHED" then
        C_Timer.After(2, function() inQuest = false end)

    -- Auction House tracking
    elseif event == "AUCTION_HOUSE_SHOW" then
        inAuction = true
    elseif event == "AUCTION_HOUSE_CLOSED" then
        C_Timer.After(0.5, function() inAuction = false end)

    -- Trade tracking
    elseif event == "TRADE_SHOW" then
        inTrade = true
    elseif event == "TRADE_CLOSED" then
        C_Timer.After(0.5, function() inTrade = false end)

    -- Vendor tracking
    elseif event == "MERCHANT_SHOW" then
        inVendor = true
        -- Check if this merchant can repair
        inRepairMerchant = CanMerchantRepair()
    elseif event == "MERCHANT_CLOSED" then
        C_Timer.After(0.5, function()
            inVendor = false
            inRepairMerchant = false
        end)

    -- Transmog tracking
    elseif event == "TRANSMOGRIFY_OPEN" then
        inTransmog = true
    elseif event == "TRANSMOGRIFY_CLOSE" then
        C_Timer.After(0.5, function() inTransmog = false end)

    -- Flight path tracking
    elseif event == "TAXIMAP_OPENED" then
        inFlightPath = true
    elseif event == "TAXIMAP_CLOSED" then
        C_Timer.After(0.5, function() inFlightPath = false end)

    -- Mail tracking
    elseif event == "MAIL_SHOW" then
        inMail = true
    elseif event == "MAIL_CLOSED" then
        C_Timer.After(0.5, function() inMail = false end)

    -- Crafting tracking
    elseif event == "TRADE_SKILL_SHOW" or event == "CRAFTINGORDERS_SHOW_CUSTOMER" or event == "CRAFTINGORDERS_SHOW_CRAFTER" then
        inCrafting = true
        MarkRecentCraftingActivity()
    elseif event == "TRADE_SKILL_CLOSE" or event == "CRAFTINGORDERS_HIDE_CUSTOMER" or event == "CRAFTINGORDERS_HIDE_CRAFTER" then
        MarkRecentCraftingActivity()
        C_Timer.After(0.5, function() inCrafting = false end)

    -- Trainer tracking (profession training costs should count as crafting)
    elseif event == "TRAINER_SHOW" then
        inTrainer = true
        MarkRecentCraftingActivity()
    elseif event == "TRAINER_CLOSED" then
        MarkRecentCraftingActivity()
        C_Timer.After(0.5, function() inTrainer = false end)

    -- Loot tracking (caches, containers, mob drops)
    elseif event == "LOOT_OPENED" then
        inLoot = true
        recentLootActivity = true
    elseif event == "LOOT_CLOSED" then
        C_Timer.After(0.5, function() inLoot = false end)
        -- Keep recentLootActivity true longer for cache gold that arrives after frame closes
        C_Timer.After(3, function() recentLootActivity = false end)

    -- Detect cache/container item usage (Pinnacle Cache, Weaver's Trove, etc.)
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
        -- arg3 = spellID for UNIT_SPELLCAST_SUCCEEDED
        if arg3 then
            local spellName = C_Spell.GetSpellName(arg3)
            -- "Opening" is used by most container/cache items
            if spellName and spellName == "Opening" then
                -- Set cache flag - this will be validated by BAG_UPDATE_DELAYED
                recentCacheUsed = true
                C_Timer.After(5, function() recentCacheUsed = false end)
            end
        end

    -- Detect cache item consumption by tracking item count changes
    elseif event == "BAG_UPDATE_DELAYED" then
        for itemID in pairs(CACHE_ITEMS) do
            local newCount = C_Item.GetItemCount(itemID, true) or 0
            local oldCount = cacheItemCounts[itemID] or 0
            if newCount < oldCount then
                -- A cache item was consumed
                recentCacheUsed = true
                C_Timer.After(5, function() recentCacheUsed = false end)
            end
            cacheItemCounts[itemID] = newCount
        end

    -- Warband Bank tracking
    elseif event == "BANKFRAME_OPENED" then
        inWarbandBank = true
    elseif event == "BANKFRAME_CLOSED" then
        C_Timer.After(0.5, function() inWarbandBank = false end)
    end
end)

-- ============================================================
-- LEDGER WINDOW UI
-- ============================================================

local ledgerRows = {}

local LVLedgerWindow = CreateFrame("Frame", "LiteVaultLedgerWindow", UIParent, "BackdropTemplate")
-- Use wider window for Chinese locales
local ledgerWidth = (lv.Layout and lv.Layout.useChineseFont) and 500 or 440
LVLedgerWindow:SetSize(ledgerWidth, 100)
LVLedgerWindow:SetPoint("CENTER")
LVLedgerWindow:SetFrameStrata("DIALOG")
LVLedgerWindow:SetMovable(true)
LVLedgerWindow:EnableMouse(true)
LVLedgerWindow:SetToplevel(true)
LVLedgerWindow:RegisterForDrag("LeftButton")
LVLedgerWindow:SetScript("OnDragStart", LVLedgerWindow.StartMoving)
LVLedgerWindow:SetScript("OnDragStop", LVLedgerWindow.StopMovingOrSizing)

-- Void Border style matching other windows
LVLedgerWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
LVLedgerWindow:Hide()

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(LVLedgerWindow, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundSolid))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
            -- Refresh ledger content if open (updates Total/Net row colors)
            if f:IsShown() and currentLedgerChar then
                lv.ShowLedgerWindow(currentLedgerChar, true)
            end
        end)
        local t = lv.GetTheme()
        LVLedgerWindow:SetBackdropColor(unpack(t.backgroundSolid))
        LVLedgerWindow:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

-- Register for Escape key to close
table.insert(UISpecialFrames, "LiteVaultLedgerWindow")

-- Clear tracked char when window hides
LVLedgerWindow:SetScript("OnHide", function()
    currentLedgerChar = nil
end)

-- Gold coin icon
LVLedgerWindow.coinIcon = LVLedgerWindow:CreateTexture(nil, "ARTWORK")
LVLedgerWindow.coinIcon:SetSize(18, 18)
LVLedgerWindow.coinIcon:SetPoint("TOPLEFT", 12, -10)
LVLedgerWindow.coinIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")

-- Title
LVLedgerWindow.title = LVLedgerWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
LVLedgerWindow.title:SetPoint("LEFT", LVLedgerWindow.coinIcon, "RIGHT", 6, 0)

-- Subtitle (week info)
LVLedgerWindow.subtitle = LVLedgerWindow:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
LVLedgerWindow.subtitle:SetPoint("TOPLEFT", LVLedgerWindow.title, "BOTTOMLEFT", 0, -1)
LVLedgerWindow.subtitle:SetTextColor(0.6, 0.5, 0.8)

-- Close Button (matches main UI style)
local ledgerClose = CreateFrame("Button", nil, LVLedgerWindow, "BackdropTemplate")
ledgerClose:SetSize(70, 26)
ledgerClose:SetPoint("TOPRIGHT", -12, -12)
ledgerClose:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
ledgerClose.Text = ledgerClose:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ledgerClose.Text:SetPoint("CENTER")
ledgerClose.Text:SetText(L["BUTTON_CLOSE"])
lv.ledgerCloseBtn = ledgerClose

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(ledgerClose, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBg))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textSecondary))
        end)
        local t = lv.GetTheme()
        ledgerClose:SetBackdropColor(unpack(t.buttonBg))
        ledgerClose:SetBackdropBorderColor(unpack(t.borderPrimary))
        ledgerClose.Text:SetTextColor(unpack(t.textSecondary))
    end
end)

ledgerClose:SetScript("OnClick", function() LVLedgerWindow:Hide() end)
ledgerClose:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
ledgerClose:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBg))
    self.Text:SetTextColor(unpack(t.textSecondary))
end)

lv.LVLedgerWindow = LVLedgerWindow

-- Track current tab
local currentTab = "summary"

-- Tab button helper function
local function CreateTabButton(parent, text, xOffset)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(80, 22)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, -42)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(text)
    return btn
end

-- Create tab buttons
local summaryTab = CreateTabButton(LVLedgerWindow, L["TAB_SUMMARY"], 15)
local historyTab = CreateTabButton(LVLedgerWindow, L["TAB_HISTORY"], 100)
local warbandTab = CreateTabButton(LVLedgerWindow, L["TAB_WARBAND"] or "Warband", 185)
lv.ledgerSummaryTab = summaryTab
lv.ledgerHistoryTab = historyTab
lv.ledgerWarbandTab = warbandTab

-- Register tabs for theme updates
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(summaryTab, function(btn, theme)
            -- Will be set properly by SetTab, just ensure backdrop exists
            if currentTab == "summary" then
                btn:SetBackdropColor(unpack(theme.tabActive))
                btn:SetBackdropBorderColor(unpack(theme.tabActiveBorder))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            else
                btn:SetBackdropColor(unpack(theme.tabInactive))
                btn:SetBackdropBorderColor(unpack(theme.tabInactiveBorder))
                btn.Text:SetTextColor(unpack(theme.textSecondary))
            end
        end)
        lv.RegisterThemedElement(historyTab, function(btn, theme)
            if currentTab == "history" then
                btn:SetBackdropColor(unpack(theme.tabActive))
                btn:SetBackdropBorderColor(unpack(theme.tabActiveBorder))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            else
                btn:SetBackdropColor(unpack(theme.tabInactive))
                btn:SetBackdropBorderColor(unpack(theme.tabInactiveBorder))
                btn.Text:SetTextColor(unpack(theme.textSecondary))
            end
        end)
        lv.RegisterThemedElement(warbandTab, function(btn, theme)
            if currentTab == "warband" then
                btn:SetBackdropColor(unpack(theme.tabActive))
                btn:SetBackdropBorderColor(unpack(theme.tabActiveBorder))
                btn.Text:SetTextColor(unpack(theme.textPrimary))
            else
                btn:SetBackdropColor(unpack(theme.tabInactive))
                btn:SetBackdropBorderColor(unpack(theme.tabInactiveBorder))
                btn.Text:SetTextColor(unpack(theme.textSecondary))
            end
        end)
    end
end)

-- Summary container (holds existing rows)
local summaryContainer = CreateFrame("Frame", nil, LVLedgerWindow)
summaryContainer:SetPoint("TOPLEFT", 0, -68)
summaryContainer:SetPoint("BOTTOMRIGHT", 0, 0)

-- History container (scroll frame)
local historyContainer = CreateFrame("Frame", nil, LVLedgerWindow)
historyContainer:SetPoint("TOPLEFT", 0, -68)
historyContainer:SetPoint("BOTTOMRIGHT", 0, 10)
historyContainer:Hide()

-- Warband container
local warbandContainer = CreateFrame("Frame", nil, LVLedgerWindow)
warbandContainer:SetPoint("TOPLEFT", 0, -68)
warbandContainer:SetPoint("BOTTOMRIGHT", 0, 10)
warbandContainer:Hide()

-- Create scroll frame for history (no visible scrollbar, mouse wheel only)
local historyScroll = CreateFrame("ScrollFrame", nil, historyContainer)
historyScroll:SetPoint("TOPLEFT", 10, -10)
historyScroll:SetPoint("BOTTOMRIGHT", -10, 10)

local historyContent = CreateFrame("Frame", nil, historyScroll)
historyContent:SetSize(400, 1)
historyScroll:SetScrollChild(historyContent)

-- Enable mouse wheel scrolling
historyScroll:EnableMouseWheel(true)
historyScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local maxScroll = self:GetVerticalScrollRange()
    local step = 40  -- pixels per scroll
    local newScroll = current - (delta * step)
    newScroll = math.max(0, math.min(newScroll, maxScroll))
    self:SetVerticalScroll(newScroll)
end)

-- History row pool
local historyRows = {}
local function GetHistoryRow(index)
    if not historyRows[index] then
        local f = CreateFrame("Frame", nil, historyContent)
        f:SetSize(350, 20)

        f.bg = f:CreateTexture(nil, "BACKGROUND")
        f.bg:SetAllPoints()
        f.bg:SetColorTexture(1, 1, 1, 0.03)

        f.time = f:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
        f.time:SetPoint("LEFT", 5, 0)
        f.time:SetWidth(70)
        f.time:SetJustifyH("LEFT")
        f.time:SetTextColor(0.6, 0.6, 0.6)

        f.source = f:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
        f.source:SetPoint("LEFT", 80, 0)
        f.source:SetWidth(120)
        f.source:SetJustifyH("LEFT")

        f.amount = f:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
        f.amount:SetPoint("RIGHT", -5, 0)
        f.amount:SetWidth(120)
        f.amount:SetJustifyH("RIGHT")

        historyRows[index] = f
    end
    return historyRows[index]
end

-- Warband rows
local warbandRows = {}
local function GetWarbandRow(index)
    if not warbandRows[index] then
        local f = CreateFrame("Frame", nil, warbandContainer)
        f:SetSize(390, 18)

        f.bg = f:CreateTexture(nil, "BACKGROUND")
        f.bg:SetAllPoints()

        f.time = f:CreateFontString(nil, "OVERLAY", "Tooltip_Med")
        f.time:SetPoint("LEFT", 0, 0)
        f.time:SetWidth(80)
        f.time:SetJustifyH("LEFT")

        f.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.name:SetPoint("LEFT", 85, 0)
        f.name:SetWidth(110)
        f.name:SetJustifyH("LEFT")

        f.action = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.action:SetPoint("LEFT", 200, 0)
        f.action:SetWidth(90)
        f.action:SetJustifyH("LEFT")

        f.gold = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.gold:SetPoint("RIGHT", 0, 0)
        f.gold:SetJustifyH("RIGHT")

        warbandRows[index] = f
    end
    return warbandRows[index]
end

local function PopulateWarbandTab()
    local wbData = LiteVaultDB and LiteVaultDB["Warband Bank"]
    local transactions = (wbData and wbData.transactions) or {}

    for _, row in pairs(warbandRows) do
        row:Hide()
    end

    local title = warbandContainer.title
    if not title then
        title = warbandContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 15, -8)
        warbandContainer.title = title
    end

    local balance = (wbData and wbData.gold) or 0
    title:SetText(string.format("%s %s", L["LABEL_CURRENT_BALANCE"] or "Current Balance:", GetCoinTextureString(balance, 14)))
    title:SetTextColor(1, 0.84, 0)

    local header = warbandContainer.header
    if not header then
        header = warbandContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", 15, -28)
        warbandContainer.header = header
    end
    header:SetText(L["LABEL_RECENT_TRANSACTIONS"] or "Recent Transactions:")
    header:SetTextColor(1, 1, 0)

    if #transactions == 0 then
        local row = GetWarbandRow(1)
        row.bg:SetColorTexture(1, 1, 1, 0.04)
        row.time:SetText("")
        row.name:SetText("|cffaaaaaa" .. (L["MSG_NO_TRANSACTIONS"] or "(No transactions recorded yet)") .. "|r")
        row.action:SetText("")
        row.gold:SetText("")
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", warbandContainer, "TOPLEFT", 15, -50)
        row:Show()
        return
    end

    for i = 1, math.min(15, #transactions) do
        local tx = transactions[i]
        local row = GetWarbandRow(i)
        local charName = tx.char and (tx.char:match("^([^-]+)") or tx.char) or "Unknown"
        local charData = tx.char and LiteVaultDB and LiteVaultDB[tx.char]
        local classColor = (charData and C_ClassColor.GetClassColor(charData.class)) or C_ClassColor.GetClassColor("WARRIOR")
        local action = (tx.amount or 0) > 0 and ("|cff00ff00" .. (L["ACTION_DEPOSITED"] or "deposited") .. "|r")
            or ("|cffff0000" .. (L["ACTION_WITHDREW"] or "withdrew") .. "|r")
        local timeStr = FormatLedgerAbsoluteTime(tx.timestamp)

        if i % 2 == 0 then
            row.bg:SetColorTexture(1, 1, 1, 0.05)
        else
            row.bg:SetColorTexture(0, 0, 0, 0.1)
        end

        row.time:SetText("|cff999999" .. timeStr .. "|r")
        row.name:SetText("|c" .. classColor:GenerateHexColor() .. charName .. "|r")
        row.action:SetText(action)
        row.gold:SetText(GetCoinTextureString(math.abs(tx.amount or 0), 12))

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", warbandContainer, "TOPLEFT", 15, -50 - ((i - 1) * 18))
        row:Show()
    end
end

-- Get source name from key
local function GetSourceName(key)
    for _, source in ipairs(lv.LEDGER_SOURCES) do
        if source.key == key then
            return L[source.nameKey]
        end
    end
    return key
end

-- Tab switching function
local function SetTab(tab)
    currentTab = tab
    local t = lv.GetTheme()

    if tab == "summary" then
        summaryContainer:Show()
        historyContainer:Hide()
        warbandContainer:Hide()
        summaryTab:SetBackdropColor(unpack(t.tabActive))
        summaryTab:SetBackdropBorderColor(unpack(t.tabActiveBorder))
        summaryTab.Text:SetTextColor(unpack(t.textPrimary))
        historyTab:SetBackdropColor(unpack(t.tabInactive))
        historyTab:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
        historyTab.Text:SetTextColor(unpack(t.textSecondary))
        warbandTab:SetBackdropColor(unpack(t.tabInactive))
        warbandTab:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
        warbandTab.Text:SetTextColor(unpack(t.textSecondary))
    elseif tab == "history" then
        summaryContainer:Hide()
        historyContainer:Show()
        warbandContainer:Hide()
        historyTab:SetBackdropColor(unpack(t.tabActive))
        historyTab:SetBackdropBorderColor(unpack(t.tabActiveBorder))
        historyTab.Text:SetTextColor(unpack(t.textPrimary))
        summaryTab:SetBackdropColor(unpack(t.tabInactive))
        summaryTab:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
        summaryTab.Text:SetTextColor(unpack(t.textSecondary))
        warbandTab:SetBackdropColor(unpack(t.tabInactive))
        warbandTab:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
        warbandTab.Text:SetTextColor(unpack(t.textSecondary))

        -- Populate history
        if currentLedgerChar and LiteVaultDB[currentLedgerChar] then
            local ledger = LiteVaultDB[currentLedgerChar].weeklyLedger or {}
            local transactions = ledger.transactions or {}

            -- Hide all rows first
            for _, row in pairs(historyRows) do
                row:Hide()
            end

            local yOffset = 0
            local shown = 0
            for _, trans in ipairs(transactions) do
                if trans.source ~= "warbandBank" then
                    shown = shown + 1
                    local row = GetHistoryRow(shown)

                    row.time:SetText(FormatLedgerAbsoluteTime(trans.timestamp))

                    row.source:SetText("|cffffd100" .. GetSourceName(trans.source) .. "|r")

                    local amount = trans.amount or 0
                    local color = amount >= 0 and "00ff00" or "ff4444"
                    local sign = amount >= 0 and "+" or ""
                    local gold = math.floor(math.abs(amount) / 10000)
                    local silver = math.floor((math.abs(amount) % 10000) / 100)
                    local copper = math.abs(amount) % 100
                    row.amount:SetText(string.format("|cff%s%s%dg %ds %dc|r", color, sign, gold, silver, copper))

                    -- Alternating background
                    if shown % 2 == 0 then
                        row.bg:SetColorTexture(1, 1, 1, 0.04)
                    else
                        row.bg:SetColorTexture(0, 0, 0, 0.1)
                    end

                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", historyContent, "TOPLEFT", 0, -yOffset)
                    row:Show()
                    yOffset = yOffset + 20
                end
            end

            -- Set content height for scrolling
            historyContent:SetHeight(math.max(1, yOffset))

            -- Show empty message if no transactions
            if shown == 0 then
                local row = GetHistoryRow(1)
                row.time:SetText("")
                row.source:SetText("|cff666666" .. L["MSG_NO_TRANSACTIONS_WEEK"] .. "|r")
                row.amount:SetText("")
                row.bg:Hide()
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", historyContent, "TOPLEFT", 0, 0)
                row:Show()
                historyContent:SetHeight(20)
            end
        end
    else
        summaryContainer:Hide()
        historyContainer:Hide()
        warbandContainer:Show()
        LVLedgerWindow:SetHeight(math.max(LVLedgerWindow:GetHeight(), 420))
        warbandTab:SetBackdropColor(unpack(t.tabActive))
        warbandTab:SetBackdropBorderColor(unpack(t.tabActiveBorder))
        warbandTab.Text:SetTextColor(unpack(t.textPrimary))
        summaryTab:SetBackdropColor(unpack(t.tabInactive))
        summaryTab:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
        summaryTab.Text:SetTextColor(unpack(t.textSecondary))
        historyTab:SetBackdropColor(unpack(t.tabInactive))
        historyTab:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
        historyTab.Text:SetTextColor(unpack(t.textSecondary))
        PopulateWarbandTab()
    end
end

-- Tab button click handlers
summaryTab:SetScript("OnClick", function() SetTab("summary") end)
historyTab:SetScript("OnClick", function() SetTab("history") end)
warbandTab:SetScript("OnClick", function() SetTab("warband") end)

-- Tab hover effects
for _, tab in ipairs({summaryTab, historyTab, warbandTab}) do
    tab:SetScript("OnEnter", function(self)
        if (self == summaryTab and currentTab ~= "summary")
            or (self == historyTab and currentTab ~= "history")
            or (self == warbandTab and currentTab ~= "warband") then
            local t = lv.GetTheme()
            self:SetBackdropBorderColor(unpack(t.borderHover))
        end
    end)
    tab:SetScript("OnLeave", function(self)
        local t = lv.GetTheme()
        if self == summaryTab then
            if currentTab == "summary" then
                self:SetBackdropBorderColor(unpack(t.tabActiveBorder))
            else
                self:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
            end
        else
            if self == historyTab and currentTab == "history" then
                self:SetBackdropBorderColor(unpack(t.tabActiveBorder))
            elseif self == warbandTab and currentTab == "warband" then
                self:SetBackdropBorderColor(unpack(t.tabActiveBorder))
            else
                self:SetBackdropBorderColor(unpack(t.tabInactiveBorder))
            end
        end
    end)
end

-- Initialize to summary tab
SetTab("summary")

-- Locale-aware column positions
local isChinese = lv.Layout and lv.Layout.useChineseFont
local ledgerRowWidth = isChinese and 450 or 390
local ledgerNameWidth = isChinese and 130 or 110
local ledgerIncomePos = isChinese and 170 or 150
local ledgerExpensePos = isChinese and 310 or 270
local ledgerDividerWidth = isChinese and 440 or 380

-- Create row pool (parented to summaryContainer)
for i = 1, #lv.LEDGER_SOURCES + 2 do  -- +2 for total and net rows
    local f = CreateFrame("Frame", nil, summaryContainer, "BackdropTemplate")
    f:SetSize(ledgerRowWidth, 24)

    -- Alternating row background
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetColorTexture(1, 1, 1, 0.03)

    -- Icon for source
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(16, 16)
    f.icon:SetPoint("LEFT", f, "LEFT", 8, 0)

    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.name:SetPoint("LEFT", f.icon, "RIGHT", 6, 0)
    f.name:SetWidth(ledgerNameWidth)
    f.name:SetJustifyH("LEFT")

    f.income = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.income:SetPoint("LEFT", f, "LEFT", ledgerIncomePos, 0)
    f.income:SetWidth(110)
    f.income:SetJustifyH("RIGHT")

    f.expense = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.expense:SetPoint("LEFT", f, "LEFT", ledgerExpensePos, 0)
    f.expense:SetWidth(110)
    f.expense:SetJustifyH("RIGHT")

    f.divider = f:CreateTexture(nil, "ARTWORK")
    f.divider:SetSize(ledgerDividerWidth, 1)
    f.divider:SetPoint("BOTTOM", 0, 0)
    f.divider:SetColorTexture(0.4, 0.2, 0.6, 0.2) -- Will be updated by theme

    ledgerRows[i] = f
end

-- Header row (parented to summaryContainer)
local headerRow = CreateFrame("Frame", nil, summaryContainer)
headerRow:SetSize(ledgerRowWidth, 22)
headerRow:SetPoint("TOPLEFT", 15, -5)

headerRow.source = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerRow.source:SetPoint("LEFT", 30, 0)
headerRow.source:SetText("|cffcccccc" .. L["HEADER_SOURCE"] .. "|r")

headerRow.income = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerRow.income:SetPoint("LEFT", ledgerIncomePos, 0)
headerRow.income:SetWidth(110)
headerRow.income:SetJustifyH("RIGHT")
headerRow.income:SetText("|cff88ff88" .. L["HEADER_INCOME"] .. "|r")

headerRow.expense = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerRow.expense:SetPoint("LEFT", ledgerExpensePos, 0)
headerRow.expense:SetWidth(110)
headerRow.expense:SetJustifyH("RIGHT")
headerRow.expense:SetText("|cffff8888" .. L["HEADER_EXPENSE"] .. "|r")

-- Header divider
headerRow.divider = headerRow:CreateTexture(nil, "ARTWORK")
headerRow.divider:SetSize(ledgerDividerWidth, 1)
headerRow.divider:SetPoint("BOTTOMLEFT", 5, -2)
headerRow.divider:SetColorTexture(0.6, 0.3, 0.9, 0.5) -- Will be updated by theme

-- Store references for theme updates
lv.ledgerRows = ledgerRows
lv.ledgerHeaderRow = headerRow

-- Update ledger colors based on current theme
local function UpdateLedgerThemeColors()
    local isDark = (lv.currentTheme == "dark") or (lv.currentTheme == nil)

    -- Update row dividers
    if lv.ledgerRows then
        for _, row in pairs(lv.ledgerRows) do
            if row.divider then
                if isDark then
                    row.divider:SetColorTexture(0.4, 0.2, 0.6, 0.2)
                else
                    row.divider:SetColorTexture(0.2, 0.2, 0.2, 0.3)
                end
            end
        end
    end

    -- Update header divider
    if lv.ledgerHeaderRow and lv.ledgerHeaderRow.divider then
        if isDark then
            lv.ledgerHeaderRow.divider:SetColorTexture(0.6, 0.3, 0.9, 0.5)
        else
            lv.ledgerHeaderRow.divider:SetColorTexture(0.3, 0.3, 0.3, 0.5)
        end
    end
end

-- PUBLIC FUNCTION: Show the ledger window
-- Set refresh=true to update without toggling (for auto-refresh)
function lv.ShowLedgerWindow(charKey, refresh, forceTab)
    if LVLedgerWindow:IsShown() and currentLedgerChar == charKey and not refresh and not forceTab then
        LVLedgerWindow:Hide()
        currentLedgerChar = nil
        return
    end
    currentLedgerChar = charKey

    local data = LiteVaultDB[charKey]
    if not data then return end

    -- Update theme colors
    UpdateLedgerThemeColors()

    -- Initialize ledger if needed
    InitLedger(charKey)

    local nameOnly = charKey:match("^([^-]+)")
    local cc = C_ClassColor.GetClassColor(data.class or "WARRIOR")
    LVLedgerWindow.title:SetText(string.format(L["TITLE_WEEKLY_LEDGER"], cc:WrapTextInColorCode(nameOnly)))

    -- Calculate time until reset
    local secondsToReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
    local daysToReset = math.floor(secondsToReset / 86400)
    local hoursToReset = math.floor((secondsToReset % 86400) / 3600)
    LVLedgerWindow.subtitle:SetText("|cff9933ff" .. string.format(L["LABEL_RESETS_IN"], daysToReset, hoursToReset) .. "|r")

    local ledger = data.weeklyLedger or {}
    local yOffset = -30  -- Start below header (relative to summaryContainer)
    local visibleCount = 0
    local totalIncome = 0
    local totalExpense = 0

    -- Show each source
    for i, source in ipairs(lv.LEDGER_SOURCES) do
        local row = ledgerRows[i]
        local sourceData = ledger[source.key] or {income = 0, expense = 0}

        local income = sourceData.income or 0
        local expense = sourceData.expense or 0

        -- Only show sources with activity
        if income > 0 or expense > 0 then
            -- Set icon
            row.icon:SetTexture(source.icon)
            row.icon:Show()

            row.name:SetText("|cffffd100" .. L[source.nameKey] .. "|r")

            if income > 0 then
                row.income:SetText("|cff00ff00+" .. FormatGoldText(income, false) .. "|r")
            else
                row.income:SetText("|cff555555-|r")
            end

            if expense > 0 then
                row.expense:SetText("|cffff4444-" .. FormatGoldText(expense, false) .. "|r")
            else
                row.expense:SetText("|cff555555-|r")
            end

            -- Alternating row background
            if visibleCount % 2 == 0 then
                row.bg:SetColorTexture(1, 1, 1, 0.04)
            else
                row.bg:SetColorTexture(0, 0, 0, 0.1)
            end
            row.bg:Show()

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", summaryContainer, "TOPLEFT", 15, yOffset)
            row.divider:Hide()  -- Hide individual dividers for cleaner look
            row:Show()

            yOffset = yOffset - 24
            visibleCount = visibleCount + 1
            -- Keep Warband Bank transfers visible in rows, but do not count
            -- them toward total/net profit (internal transfer, not real profit/loss).
            if source.key ~= "warbandBank" then
                totalIncome = totalIncome + income
                totalExpense = totalExpense + expense
            end
        else
            row:Hide()
        end
    end

    -- Show "No activity" message if ledger is empty
    if visibleCount == 0 then
        local row = ledgerRows[1]
        row.icon:Hide()
        row.bg:Hide()
        row.name:SetText("|cff666666" .. L["MSG_NO_GOLD_ACTIVITY"] .. "|r")
        row.income:SetText("")
        row.expense:SetText("")
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", summaryContainer, "TOPLEFT", 15, yOffset)
        row.divider:Hide()
        row:Show()
        yOffset = yOffset - 24
        visibleCount = 1
    end

    -- Total row with separator
    if totalIncome > 0 or totalExpense > 0 then
        local totalRow = ledgerRows[#lv.LEDGER_SOURCES + 1]
        totalRow.icon:Hide()
        if lv.currentTheme == "light" then
            totalRow.bg:SetColorTexture(0.3, 0.4, 0.3, 0.4)   -- Sage green
        else
            totalRow.bg:SetColorTexture(0.3, 0.15, 0.5, 0.3)  -- Void purple
        end
        totalRow.bg:Show()
        totalRow.name:SetText("|cffffffff" .. L["LABEL_TOTAL"] .. "|r")
        totalRow.income:SetText("|cff00ff00+" .. FormatGoldText(totalIncome, false) .. "|r")
        totalRow.expense:SetText("|cffff4444-" .. FormatGoldText(totalExpense, false) .. "|r")
        totalRow:ClearAllPoints()
        totalRow:SetPoint("TOPLEFT", summaryContainer, "TOPLEFT", 15, yOffset - 8)
        if lv.currentTheme == "light" then
            totalRow.divider:SetColorTexture(0.3, 0.3, 0.3, 0.5)  -- Dark grey divider
        else
            totalRow.divider:SetColorTexture(0.6, 0.3, 0.9, 0.4)  -- Void purple divider
        end
        totalRow.divider:SetSize(380, 1)
        totalRow.divider:ClearAllPoints()
        totalRow.divider:SetPoint("TOP", 0, 4)
        totalRow.divider:Show()
        totalRow:Show()
        yOffset = yOffset - 32

        -- Net row
        local netRow = ledgerRows[#lv.LEDGER_SOURCES + 2]
        local net = totalIncome - totalExpense
        netRow.icon:Hide()
        if lv.currentTheme == "light" then
            netRow.bg:SetColorTexture(0.25, 0.35, 0.25, 0.45) -- Sage green
        else
            netRow.bg:SetColorTexture(0.2, 0.1, 0.4, 0.4)     -- Void purple
        end
        netRow.bg:Show()
        netRow.name:SetText("|cffffffff" .. L["LABEL_NET_PROFIT"] .. "|r")
        netRow.income:SetText("")
        local netColor = net >= 0 and "00ff00" or "ff4444"
        local netSign = net >= 0 and "+" or ""
        netRow.expense:SetText("|cff" .. netColor .. netSign .. FormatGoldText(math.abs(net), false) .. "|r")
        netRow:ClearAllPoints()
        netRow:SetPoint("TOPLEFT", summaryContainer, "TOPLEFT", 15, yOffset)
        netRow.divider:Hide()
        netRow:Show()
        yOffset = yOffset - 24
    else
        ledgerRows[#lv.LEDGER_SOURCES + 1]:Hide()
        ledgerRows[#lv.LEDGER_SOURCES + 2]:Hide()
    end

    -- Set fixed window size for tabs, then show
    local contentHeight = math.abs(yOffset) + 15
    LVLedgerWindow:SetHeight(math.max(280, contentHeight + 95))  -- +95 for header and tabs
    if forceTab == "warband" or currentTab == "warband" then
        LVLedgerWindow:SetHeight(math.max(LVLedgerWindow:GetHeight(), 420))
    end
    LVLedgerWindow:Show()

    -- Refresh current tab (in case history is active)
    if forceTab == "summary" or forceTab == "history" or forceTab == "warband" then
        SetTab(forceTab)
    else
        SetTab(currentTab)
    end
end

function lv.RefreshOpenLedgerWindow()
    if currentLedgerChar and lv.ShowLedgerWindow and LVLedgerWindow and LVLedgerWindow:IsShown() then
        lv.ShowLedgerWindow(currentLedgerChar, true, currentTab)
    end
end

lv.InitLedger = InitLedger
