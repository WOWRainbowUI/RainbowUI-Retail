-- Currency.lua
local addonName, lv = ...
local L = lv.L

-- 1. ORDERED LIST (Midnight-only)
lv.ORDERED_KEYWORDS = {
    "Undercoin",
    "Voidlight Marl",          -- Midnight (replaces Resonance Crystals)
    "Brimming Arcana",         -- Midnight
    "Remnant of Anguish",      -- Midnight
    "Restored Coffer Key",
    "Coffer Key Shards",
    "Untainted Mana-Crystals",
    "Shard of Dundun",         -- Midnight
    "Adventurer Dawncrest",    -- Midnight
    "Veteran Dawncrest",       -- Midnight
    "Champion Dawncrest",      -- Midnight
    "Hero Dawncrest",          -- Midnight
    "Myth Dawncrest"           -- Midnight
}

local CURRENCY_DIVIDER_UPGRADE_CRESTS = "__DIVIDER_UPGRADE_CRESTS__"
local CURRENCY_DIVIDER_DELVE = "__DIVIDER_DELVE__"
local CURRENCY_DISPLAY_ORDER = {
    "Voidlight Marl",
    "Brimming Arcana",
    "Remnant of Anguish",
    "Shard of Dundun",
    CURRENCY_DIVIDER_DELVE,
    "Undercoin",
    "Restored Coffer Key",
    "Coffer Key Shards",
    "Untainted Mana-Crystals",
    CURRENCY_DIVIDER_UPGRADE_CRESTS,
    "Adventurer Dawncrest",
    "Veteran Dawncrest",
    "Champion Dawncrest",
    "Hero Dawncrest",
    "Myth Dawncrest",
}

-- TWW-specific currencies to hide when Midnight launches
local TWW_CURRENCIES = {
    ["Resonance Crystals"] = true,
    ["Twilight's Blade Insignia"] = true, -- Pre-patch currency
    ["Weathered Ethereal Crest"] = true,
    ["Carved Ethereal Crest"] = true,
    ["Runed Ethereal Crest"] = true,
    ["Gilded Ethereal Crest"] = true,
}

-- Midnight currency names (English and localized)
local MIDNIGHT_CURRENCIES = {
    ["Untainted Mana-Crystals"] = true,
    ["Voidlight Marl"] = true,
    ["Shard of Dundun"] = true,
    ["Brimming Arcana"] = true,
    ["Remnant of Anguish"] = true,
    ["Adventurer Dawncrest"] = true,
}

-- Detect if Midnight has launched by checking for Midnight currencies.
-- LiteVault currently runs in Midnight-only mode.
local function IsMidnightActive()
    return true
end

-- Legacy detection retained below (currently bypassed by Midnight-only mode).
local function IsMidnightActive_Legacy()
    -- Build lookup with localized names too
    local midnightLookup = {}
    for englishName in pairs(MIDNIGHT_CURRENCIES) do
        midnightLookup[englishName] = true
        local localizedName = L[englishName]
        if localizedName then
            midnightLookup[localizedName] = true
        end
    end

    local count = C_CurrencyInfo.GetCurrencyListSize()
    for i = 1, count do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        if info and midnightLookup[info.name] then
            return true
        end
    end
    return false
end

-- Build lookup tables for the scanner (English names AND localized names)
local TARGET_NAMES = {}        -- localizedName -> englishKey
local TARGET_ENGLISH = {}      -- englishName -> true
for _, englishName in ipairs(lv.ORDERED_KEYWORDS) do
    TARGET_ENGLISH[englishName] = true
    -- Also add the localized version pointing back to English key
    local localizedName = L[englishName]
    if localizedName and localizedName ~= englishName then
        TARGET_NAMES[localizedName] = englishName
    end
end

-- Canonicalize crest naming so minor game-name variations still map to stable keys.
local function CanonicalizeCrestKey(rawName)
    if not rawName then return nil end
    local n = rawName:lower()
    if n:find("adventurer", 1, true) and (n:find("dawncrest", 1, true) or n:find("crest", 1, true)) then return "Adventurer Dawncrest" end
    if n:find("veteran", 1, true) and (n:find("dawncrest", 1, true) or n:find("crest", 1, true)) then return "Veteran Dawncrest" end
    if n:find("champion", 1, true) and (n:find("dawncrest", 1, true) or n:find("crest", 1, true)) then return "Champion Dawncrest" end
    if n:find("hero", 1, true) and (n:find("dawncrest", 1, true) or n:find("crest", 1, true)) then return "Hero Dawncrest" end
    if (n:find("myth", 1, true) or n:find("mythic", 1, true)) and (n:find("dawncrest", 1, true) or n:find("crest", 1, true)) then return "Myth Dawncrest" end
    return nil
end

local ALWAYS_SHOW_ZERO = {
    ["Coffer Key Shards"] = true,
    ["Untainted Mana-Crystals"] = true,
    ["Voidlight Marl"] = true,
    ["Shard of Dundun"] = true,
    ["Brimming Arcana"] = true,
    ["Remnant of Anguish"] = true,
    ["Adventurer Dawncrest"] = true,
    ["Veteran Dawncrest"] = true,
    ["Champion Dawncrest"] = true,
    ["Hero Dawncrest"] = true,
    ["Myth Dawncrest"] = true,
}

-- Known Midnight crest currency IDs (populate as IDs are confirmed).
local MIDNIGHT_CREST_CURRENCY_IDS = {
    ["Adventurer Dawncrest"] = 3383,
    ["Veteran Dawncrest"] = 3341,
    ["Champion Dawncrest"] = 3343,
    ["Hero Dawncrest"] = 3345,
    ["Myth Dawncrest"] = 3347,
}

local UPGRADE_CREST_KEYS = {}
for crestName in pairs(MIDNIGHT_CREST_CURRENCY_IDS) do
    UPGRADE_CREST_KEYS[crestName] = true
end

-- Midnight currencies that should be read directly by currency ID.
local MIDNIGHT_DIRECT_CURRENCY_IDS = {
    ["Undercoin"] = 2803,
    ["Coffer Key Shards"] = 3310,
    ["Untainted Mana-Crystals"] = 3356,
    ["Voidlight Marl"] = 3316,
    ["Shard of Dundun"] = 3376,
    ["Brimming Arcana"] = 3379,
    ["Remnant of Anguish"] = 3392,
}

local CURRENCY_ID_BY_KEYWORD = {}
for currencyName, currencyID in pairs(MIDNIGHT_CREST_CURRENCY_IDS) do
    CURRENCY_ID_BY_KEYWORD[currencyName] = currencyID
end
for currencyName, currencyID in pairs(MIDNIGHT_DIRECT_CURRENCY_IDS) do
    CURRENCY_ID_BY_KEYWORD[currencyName] = currencyID
end
    for currencyID, currencyName in pairs(lv.FORCE_IDS or {}) do
        CURRENCY_ID_BY_KEYWORD[currencyName] = currencyID
    end

-- TWW currency IDs for Midnight detection (locale-independent)
local TWW_CURRENCY_IDS = {
    [2815] = true, -- Resonance Crystals
    [3008] = true, -- Twilight's Blade Insignia
    [2914] = true, -- Weathered Ethereal Crest
    [2915] = true, -- Carved Ethereal Crest
    [2916] = true, -- Runed Ethereal Crest
    [2917] = true, -- Gilded Ethereal Crest
}

local GetCurrencyCapMeta
local GetCurrencyIDByKeyword

-- 2. SCANNER (Locale-aware with name matching)
function lv.ScanCurrencies()
    if not LiteVaultDB then return end
    local name = lv.PLAYER_KEY or (UnitName("player") .. "-" .. GetRealmName())
    -- Don't create entry for declined characters
    local declined = LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[name]
    if declined or not LiteVaultDB[name] then return end
    local db = LiteVaultDB[name]

    -- Wipe old data
    db.currencies = {}

    -- Check if Midnight has launched
    local midnightActive = IsMidnightActive()

    if C_CurrencyInfo.ExpandCurrencyList then
        C_CurrencyInfo.ExpandCurrencyList(0, true)
    end

    local count = C_CurrencyInfo.GetCurrencyListSize()
    for i = 1, count do
        local info = C_CurrencyInfo.GetCurrencyListInfo(i)
        if info and not info.isHeader then
            local englishKey = nil

            -- Check if this currency matches our targets
            -- First check English name (for enUS clients)
            if TARGET_ENGLISH[info.name] then
                englishKey = info.name
            -- Then check localized name mapping (for non-enUS clients)
            elseif TARGET_NAMES[info.name] then
                englishKey = TARGET_NAMES[info.name]
            else
                -- Check pattern matching for new currencies
                for _, pattern in ipairs(lv.CURRENCY_PATTERNS or {}) do
                    if info.name:match(pattern) then
                        englishKey = info.name -- Use as-is for pattern matches
                        break
                    end
                end
            end

            -- Skip TWW-specific currencies if Midnight has launched
            if englishKey and midnightActive and TWW_CURRENCIES[englishKey] then
                englishKey = nil
            end

            -- Canonicalize crest keys (e.g., apostrophe/plural/name-format differences).
            if englishKey then
                englishKey = CanonicalizeCrestKey(englishKey) or englishKey
            end

            -- Only include if we found a match AND quantity > 0
            if englishKey and info.quantity > 0 then
                db.currencies[englishKey] = {
                    amount = info.quantity,
                    icon = info.iconFileID
                }
                if UPGRADE_CREST_KEYS[englishKey] then
                    db.currencies[englishKey].capMeta = GetCurrencyCapMeta(GetCurrencyIDByKeyword(englishKey))
                end
            end
        end
    end

    -- Ensure known Midnight crest rows have accurate icon/amount, even before name matching is perfect.
    for crestName, currencyID in pairs(MIDNIGHT_CREST_CURRENCY_IDS) do
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if info and type(info.quantity) == "number" then
            db.currencies[crestName] = {
                amount = info.quantity,
                icon = info.iconFileID or (db.currencies[crestName] and db.currencies[crestName].icon) or 134400,
                capMeta = GetCurrencyCapMeta(currencyID),
            }
        end
    end

    -- Ensure direct-ID Midnight currencies are always sourced from the correct currency.
    for currencyName, currencyID in pairs(MIDNIGHT_DIRECT_CURRENCY_IDS) do
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if info and type(info.quantity) == "number" then
            db.currencies[currencyName] = {
                amount = info.quantity,
                icon = info.iconFileID or (db.currencies[currencyName] and db.currencies[currencyName].icon) or 134400
            }
        end
    end

    -- Force-read known currency IDs that may not appear reliably in the expanded list.
    for currencyID, currencyName in pairs(lv.FORCE_IDS or {}) do
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if info and type(info.quantity) == "number" then
            db.currencies[currencyName] = {
                amount = info.quantity,
                icon = info.iconFileID or (db.currencies[currencyName] and db.currencies[currencyName].icon) or 134400
            }
        end
    end

    if lv.RefreshCurrencyWindow then
        lv.RefreshCurrencyWindow(name)
    end
end

-- Events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE") -- When items move in/out of bags
eventFrame:RegisterEvent("MAIL_CLOSED") -- When you receive mail
eventFrame:RegisterEvent("BANKFRAME_OPENED") -- When accessing warband bank
eventFrame:RegisterEvent("BANKFRAME_CLOSED") -- After warband bank transactions
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        C_Timer.After(1, lv.ScanCurrencies)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, lv.ScanCurrencies)
    elseif event == "CURRENCY_DISPLAY_UPDATE" or event == "BAG_UPDATE" or event == "MAIL_CLOSED" or event == "BANKFRAME_CLOSED" then
        lv.ScanCurrencies()
    elseif event == "BANKFRAME_OPENED" then
        C_Timer.After(0.5, lv.ScanCurrencies) -- Small delay for bank to load
    end
end)


-- 3. WINDOW DISPLAY
local currentCurrencyChar = nil
local currencyRows = {} -- Pool of row frames

GetCurrencyIDByKeyword = function(keyword)
    return CURRENCY_ID_BY_KEYWORD[keyword]
end

local function GetAccountCurrencyTotal(currencyID, currentAmount)
    if not currencyID or not C_CurrencyInfo or not C_CurrencyInfo.IsAccountTransferableCurrency or not C_CurrencyInfo.IsAccountTransferableCurrency(currencyID) then
        return nil
    end
    if not C_CurrencyInfo.IsAccountCharacterCurrencyDataReady or not C_CurrencyInfo.IsAccountCharacterCurrencyDataReady() then
        return nil
    end
    if not C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters then
        return nil
    end

    local total = currentAmount or 0
    local accountData = C_CurrencyInfo.FetchCurrencyDataFromAccountCharacters(currencyID) or {}
    for _, info in ipairs(accountData) do
        total = total + (info.quantity or 0)
    end
    return total
end

GetCurrencyCapMeta = function(currencyID)
    if not currencyID or not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyInfo then
        return nil
    end

    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info then
        return nil
    end

    local function BuildCapMeta(earned, cap)
        earned = tonumber(earned)
        cap = tonumber(cap)
        if not cap or cap <= 0 then
            return nil
        end
        if earned and earned >= 0 and earned <= cap then
            return {
                earned = earned,
                cap = cap,
            }
        end
        return {
            earned = nil,
            cap = cap,
        }
    end

    local weeklyMeta = BuildCapMeta(info.quantityEarnedThisWeek, info.maxWeeklyQuantity)
    if weeklyMeta and weeklyMeta.earned ~= nil then
        return weeklyMeta
    end
    if weeklyMeta then
        return weeklyMeta
    end

    if C_TooltipInfo and C_TooltipInfo.GetCurrencyByID then
        local tooltipData = C_TooltipInfo.GetCurrencyByID(currencyID)
        local lines = tooltipData and tooltipData.lines
        if lines then
            for _, line in ipairs(lines) do
                local text = line and line.leftText
                if text then
                    local earnedText, capText = text:match("(%d+)%s*/%s*(%d+)")
                    if earnedText and capText then
                        local parsedEarned = tonumber(earnedText)
                        local parsedCap = tonumber(capText)
                        local tooltipMeta = BuildCapMeta(parsedEarned, parsedCap)
                        if tooltipMeta then
                            return tooltipMeta
                        end
                    end
                end
            end
        end
    end

    local fallbackEarned = info.useTotalEarnedForMaxQty and info.totalEarned or info.quantityEarnedThisWeek or info.totalEarned
    return BuildCapMeta(fallbackEarned, info.maxWeeklyQuantity or info.maxQuantity)

end

lv.GetCurrencyCapMeta = GetCurrencyCapMeta

-- FRAME SETUP
local LVCurrencyWindow = CreateFrame("Frame", "LiteVaultCurrencyWindow", UIParent, "BackdropTemplate")
LVCurrencyWindow:SetSize(320, 100) -- Height will auto-adjust
LVCurrencyWindow:SetPoint("CENTER")
LVCurrencyWindow:SetFrameStrata("DIALOG")
LVCurrencyWindow:SetMovable(true)
LVCurrencyWindow:EnableMouse(true)
LVCurrencyWindow:SetToplevel(true)
LVCurrencyWindow:RegisterForDrag("LeftButton")
LVCurrencyWindow:SetScript("OnDragStart", LVCurrencyWindow.StartMoving)
LVCurrencyWindow:SetScript("OnDragStop", LVCurrencyWindow.StopMovingOrSizing)

-- Void Border (Dark solid background)
LVCurrencyWindow:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
LVCurrencyWindow:Hide()

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(LVCurrencyWindow, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundSolid))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        LVCurrencyWindow:SetBackdropColor(unpack(t.backgroundSolid))
        LVCurrencyWindow:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

-- Title
LVCurrencyWindow.title = LVCurrencyWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
LVCurrencyWindow.title:SetPoint("TOPLEFT", 15, -12)

-- Close Button
local curClose = CreateFrame("Button", nil, LVCurrencyWindow, "BackdropTemplate")
curClose:SetSize(60, 22)
curClose:SetPoint("TOPRIGHT", -8, -8)
curClose:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
curClose.Text = curClose:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
curClose.Text:SetPoint("CENTER"); curClose.Text:SetText(L["BUTTON_CLOSE"])
lv.currencyCloseBtn = curClose

-- Register for theming
C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(curClose, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        local t = lv.GetTheme()
        curClose:SetBackdropColor(unpack(t.buttonBgAlt))
        curClose:SetBackdropBorderColor(unpack(t.borderPrimary))
        curClose.Text:SetTextColor(unpack(t.textPrimary))
    end
end)

curClose:SetScript("OnClick", function() LVCurrencyWindow:Hide() end)
curClose:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)
curClose:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
    self.Text:SetTextColor(unpack(t.textPrimary))
end)

lv.LVCurrencyWindow = LVCurrencyWindow

local ROW_WIDTH = 280
local NAME_COL_WIDTH = 195
local VALUE_COL_AMOUNT = -8
local VALUE_COL_ACCOUNT_DIVIDER = -162
local VALUE_COL_ACCOUNT = -116
local VALUE_COL_META_DIVIDER = -98
local VALUE_COL_META = -116
local VALUE_COL_CAP = -8

local function ShowCurrencyTooltip(anchor, currencyID)
    if not anchor or not currencyID then
        return
    end

    GameTooltip:SetOwner(anchor, "ANCHOR_RIGHT")
    if GameTooltip.SetCurrencyByID then
        GameTooltip:SetCurrencyByID(currencyID)
    elseif GameTooltip.SetHyperlink then
        GameTooltip:SetHyperlink(("currency:%d"):format(currencyID))
    end
    GameTooltip:Show()
end

-- CREATE ROW POOL (We create them once, but position them later)
for i = 1, #CURRENCY_DISPLAY_ORDER do
    local f = CreateFrame("Frame", nil, LVCurrencyWindow)
    f:SetSize(ROW_WIDTH, 34)
    f:EnableMouse(true)
    
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(20, 20) -- Slightly tighter icon
    f.icon:SetPoint("LEFT")
    
    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.name:SetPoint("LEFT", 28, 0)
    f.name:SetWidth(NAME_COL_WIDTH)
    f.name:SetJustifyH("LEFT")
    lv.ApplyLocaleFont(f.name, 12) -- Apply crisp font for zhTW

    f.val = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.val:SetPoint("RIGHT", f, "RIGHT", VALUE_COL_AMOUNT, 0)
    f.val:SetWidth(48)
    f.val:SetJustifyH("RIGHT")
    lv.ApplyLocaleFont(f.val, 12) -- Apply crisp font for zhTW

    f.accountVal = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.accountVal:SetPoint("RIGHT", f, "RIGHT", VALUE_COL_ACCOUNT, 0)
    f.accountVal:SetWidth(42)
    f.accountVal:SetJustifyH("RIGHT")
    lv.ApplyLocaleFont(f.accountVal, 10)
    f.accountVal:SetTextColor(0.75, 0.75, 0.75)

    f.divider = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.divider:SetPoint("RIGHT", f, "RIGHT", VALUE_COL_ACCOUNT_DIVIDER, 0)
    lv.ApplyLocaleFont(f.divider, 10)
    f.divider:SetTextColor(0.75, 0.75, 0.75)
    f.divider:SetText("|")

    f.metaVal = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.metaVal:SetPoint("RIGHT", f, "RIGHT", VALUE_COL_META, 0)
    f.metaVal:SetWidth(42)
    f.metaVal:SetJustifyH("RIGHT")
    lv.ApplyLocaleFont(f.metaVal, 10)
    f.metaVal:SetTextColor(0.75, 0.75, 0.75)

    f.metaLeadDivider = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.metaLeadDivider:SetPoint("RIGHT", f, "RIGHT", VALUE_COL_META_DIVIDER, 0)
    lv.ApplyLocaleFont(f.metaLeadDivider, 10)
    f.metaLeadDivider:SetTextColor(0.75, 0.75, 0.75)
    f.metaLeadDivider:SetText("|")

    f.metaCap = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.metaCap:SetPoint("RIGHT", f, "RIGHT", VALUE_COL_CAP, 0)
    f.metaCap:SetWidth(74)
    f.metaCap:SetJustifyH("RIGHT")
    lv.ApplyLocaleFont(f.metaCap, 10)
    f.metaCap:SetTextColor(0.75, 0.75, 0.75)

    f.metaDivider = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.metaDivider:SetPoint("RIGHT", f.metaCap, "LEFT", -6, 0)
    lv.ApplyLocaleFont(f.metaDivider, 10)
    f.metaDivider:SetTextColor(0.75, 0.75, 0.75)
    f.metaDivider:SetText("|")

    f.sectionTitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.sectionTitle:SetPoint("CENTER")
    lv.ApplyLocaleFont(f.sectionTitle, 11)
    f.sectionTitle:SetTextColor(1, 0.82, 0)
    f.sectionTitle:Hide()

    f:SetScript("OnEnter", function(self)
        if self.currencyID and currentCurrencyChar == lv.PLAYER_KEY then
            ShowCurrencyTooltip(self, self.currencyID)
        end
    end)
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    currencyRows[i] = f
end

local function RenderCurrencyWindow(charKey)
    local data = LiteVaultDB[charKey]
    if not data or not data.currencies then return end
    
    local nameOnly = charKey:match("^([^-]+)")
    local cc = C_ClassColor.GetClassColor(data.class or "WARRIOR")
    LVCurrencyWindow.title:SetText(string.format(L["TITLE_CURRENCIES"], cc:WrapTextInColorCode(nameOnly)))
    
    -- DYNAMIC STACKING LOGIC
    local yOffset = -50 -- Start below the header
    local visibleCount = 0
    
    for i, keyword in ipairs(CURRENCY_DISPLAY_ORDER) do
        local row = currencyRows[i]

        if keyword == CURRENCY_DIVIDER_DELVE or keyword == CURRENCY_DIVIDER_UPGRADE_CRESTS then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 20, yOffset)
            row.icon:Hide()
            row.name:Hide()
            row.val:Hide()
            row.currencyID = nil
            row.accountVal:Hide()
            row.divider:Hide()
            row.metaVal:Hide()
            row.metaLeadDivider:Hide()
            row.metaCap:Hide()
            row.metaDivider:Hide()
            if keyword == CURRENCY_DIVIDER_DELVE then
                row.sectionTitle:SetText((L["SECTION_DELVE_CURRENCY"] ~= "SECTION_DELVE_CURRENCY") and L["SECTION_DELVE_CURRENCY"] or "Delve Currency")
            else
                row.sectionTitle:SetText((L["SECTION_UPGRADE_CRESTS"] ~= "SECTION_UPGRADE_CRESTS") and L["SECTION_UPGRADE_CRESTS"] or "Upgrade Crests")
            end
            row.sectionTitle:Show()
            row:Show()
            yOffset = yOffset - (18 + lv.Layout.verticalPadding)
            visibleCount = visibleCount + 1
        else
            local curData = data.currencies[keyword]

            if curData or ALWAYS_SHOW_ZERO[keyword] then
                local amount = (curData and curData.amount) or 0
                local currencyID = GetCurrencyIDByKeyword(keyword)
                local capMeta = (curData and curData.capMeta) or nil

                -- Populate Data
                row.icon:Show()
                row.name:Show()
                row.val:Show()
                row.sectionTitle:Hide()
                row.icon:SetTexture((curData and curData.icon) or 134400)
                row.name:SetText(L[keyword] or keyword) -- Localized when available, fallback to English key
                row.val:SetText(BreakUpLargeNumbers(amount))
                row.currencyID = currencyID
                row.divider:Hide()
                row.accountVal:SetText("")
                row.accountVal:Hide()
                row.metaLeadDivider:Hide()
                row.metaDivider:Hide()
                row.metaVal:SetText("")
                row.metaVal:Hide()
                row.metaDivider:Hide()
                row.metaLeadDivider:Hide()
                row.metaVal:SetText("")
                row.metaCap:SetText("")
                row.metaVal:Hide()
                row.metaCap:Hide()
                
                -- Set Position (Dynamic!)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 20, yOffset)
                row:Show()
                
                -- Move the offset down for the next item (locale-aware spacing)
                yOffset = yOffset - (25 + lv.Layout.verticalPadding) 
                visibleCount = visibleCount + 1
            else 
                row.divider:Hide()
                row.accountVal:Hide()
                row.metaDivider:Hide()
                row.metaLeadDivider:Hide()
                row.metaVal:Hide()
                row.metaCap:Hide()
                row.sectionTitle:Hide()
                row.currencyID = nil
                row:Hide()
            end
        end
    end
    
    -- Shrink/Grow window to fit content
    local totalHeight = math.abs(yOffset) + 15
    LVCurrencyWindow:SetHeight(math.max(100, totalHeight))
    LVCurrencyWindow:Show()
end

function lv.RefreshCurrencyWindow(updatedCharKey)
    if not currentCurrencyChar or not LVCurrencyWindow:IsShown() then return end
    if updatedCharKey and updatedCharKey ~= currentCurrencyChar then return end
    RenderCurrencyWindow(currentCurrencyChar)
end

-- PUBLIC FUNCTION
function lv.ShowCurrencyWindow(charKey)
    if LVCurrencyWindow:IsShown() and currentCurrencyChar == charKey then
        LVCurrencyWindow:Hide()
        currentCurrencyChar = nil
        return
    end
    currentCurrencyChar = charKey
    
    if C_CurrencyInfo and C_CurrencyInfo.RequestCurrencyDataForAccountCharacters then
        C_CurrencyInfo.RequestCurrencyDataForAccountCharacters()
    end
    if charKey == lv.PLAYER_KEY then lv.ScanCurrencies() end
    
    RenderCurrencyWindow(charKey)
end

