local addonName, lv = ...
local L = lv.L

local STALE_WINDOW_SECONDS = 5 * 24 * 60 * 60
local TOKEN_HISTORY_INTERVAL_SECONDS = 6 * 60 * 60
local TOKEN_HISTORY_CAP = 30

local function LText(key, fallback)
    local value = L and L[key]
    if value and value ~= "" and value ~= key then
        return value
    end
    local enUS = lv.LocaleData and lv.LocaleData["enUS"]
    local baseValue = enUS and enUS[key]
    if baseValue and baseValue ~= "" then
        return baseValue
    end
    return fallback or key
end

local function EnsureTokenDB()
    LiteVaultDB = LiteVaultDB or {}
    LiteVaultDB.wowToken = LiteVaultDB.wowToken or {
        tokenPrice = nil,
        tokenPriceUpdated = nil,
        tokenPreviousPrice = nil,
        tokenDelta = nil,
        tokenHistory = {},
    }
    if type(LiteVaultDB.wowToken.tokenHistory) ~= "table" then
        LiteVaultDB.wowToken.tokenHistory = {}
    end
    return LiteVaultDB.wowToken
end

local function GetNowTimestamp()
    return (GetServerTime and GetServerTime()) or time()
end

local function HasTokenAPI()
    return C_WowTokenPublic and type(C_WowTokenPublic.GetCurrentMarketPrice) == "function"
end

local function GetWarbandGoldTotal()
    if not LiteVaultDB then
        return 0
    end

    local total = 0
    for charKey, data in pairs(LiteVaultDB) do
        if type(charKey) == "string"
            and type(data) == "table"
            and type(data.gold) == "number"
            and charKey ~= "Warband Bank"
            and data.class and data.class ~= "Bank"
            and (not data.region or data.region == lv.REGION)
            and not (LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[charKey]) then
            total = total + math.max(0, data.gold or 0)
        end
    end

    local wbBankGold = (LiteVaultDB["Warband Bank"] and tonumber(LiteVaultDB["Warband Bank"].gold)) or 0
    total = total + math.max(0, wbBankGold)
    return total
end

local function IsTokenPriceStale(updatedAt)
    updatedAt = tonumber(updatedAt)
    if not updatedAt or updatedAt <= 0 then
        return false
    end
    return (GetNowTimestamp() - updatedAt) > STALE_WINDOW_SECONDS
end

local function GetTokenHistory(db)
    db = db or EnsureTokenDB()
    if type(db.tokenHistory) ~= "table" then
        db.tokenHistory = {}
    end
    return db.tokenHistory
end

local function TrimTokenHistory(history)
    while #history > TOKEN_HISTORY_CAP do
        table.remove(history, 1)
    end
end

local function MaybeAppendTokenHistory(db, price, nowTimestamp)
    local history = GetTokenHistory(db)
    local lastEntry = history[#history]
    local lastPrice = lastEntry and tonumber(lastEntry.priceCopper) or nil
    local lastTimestamp = lastEntry and tonumber(lastEntry.timestamp) or nil
    local priceChanged = (not lastPrice) or (lastPrice ~= price)
    local intervalElapsed = (not lastTimestamp) or ((nowTimestamp - lastTimestamp) >= TOKEN_HISTORY_INTERVAL_SECONDS)

    if not priceChanged and not intervalElapsed then
        return
    end

    local deltaCopper = nil
    if lastPrice and lastPrice > 0 then
        deltaCopper = price - lastPrice
    end

    table.insert(history, {
        timestamp = nowTimestamp,
        priceCopper = price,
        deltaCopper = deltaCopper,
    })
    TrimTokenHistory(history)
end

local function StoreTokenPrice(price)
    price = tonumber(price)
    if not price or price <= 0 then
        return false
    end

    local db = EnsureTokenDB()
    local nowTimestamp = GetNowTimestamp()
    local previous = tonumber(db.tokenPrice)
    if previous and previous > 0 and previous ~= price then
        db.tokenPreviousPrice = previous
        db.tokenDelta = price - previous
    elseif not previous or previous <= 0 then
        db.tokenPreviousPrice = nil
        db.tokenDelta = nil
    end

    db.tokenPrice = price
    db.tokenPriceUpdated = nowTimestamp
    MaybeAppendTokenHistory(db, price, nowTimestamp)
    return true
end

local function TryReadCurrentTokenPrice()
    if not HasTokenAPI() then
        return nil
    end
    return C_WowTokenPublic.GetCurrentMarketPrice()
end

local function RefreshTokenPrice()
    local changed = StoreTokenPrice(TryReadCurrentTokenPrice())
    if changed and lv.UpdateUI then
        lv.UpdateUI()
    end
    return changed
end

lv.RefreshWowTokenUI = RefreshTokenPrice

local function RequestTokenPriceRefresh()
    if not HasTokenAPI() then
        return false
    end

    RefreshTokenPrice()

    if C_WowTokenPublic and type(C_WowTokenPublic.UpdateMarketPrice) == "function" then
        C_WowTokenPublic.UpdateMarketPrice()
        if C_Timer then
            C_Timer.After(1, RefreshTokenPrice)
        end
        return true
    end

    return false
end

local function FormatTokenTimestamp(ts)
    ts = tonumber(ts)
    if not ts or ts <= 0 then
        return nil
    end
    return date("%Y-%m-%d %H:%M", ts)
end

local function FormatDeltaText(delta)
    delta = tonumber(delta)
    if not delta or delta == 0 then
        return nil
    end

    local formatter = lv.FormatGoldAligned or GetCoinTextureString
    if not formatter then
        return tostring(delta)
    end

    local prefix = delta > 0 and "+" or "-"
    return prefix .. formatter(math.abs(delta), 14)
end

local function FormatTokenHistoryPrice(price)
    local formatter = lv.FormatGoldAligned or GetCoinTextureString
    if not formatter then
        return tostring(price)
    end
    return formatter(price, 14)
end

local function FormatRelativeAge(timestamp)
    local ts = tonumber(timestamp)
    if not ts or ts <= 0 then
        return LText("LABEL_UNKNOWN")
    end

    local delta = math.max(0, GetNowTimestamp() - ts)
    if delta < 60 then
        return LText("TIME_JUST_NOW")
    elseif delta < 3600 then
        return string.format(LText("TIME_MINUTES_AGO_FMT"), math.floor(delta / 60))
    elseif delta < 86400 then
        return string.format(LText("TIME_HOURS_AGO_FMT"), math.floor(delta / 3600))
    elseif delta < (2 * 86400) then
        return LText("TIME_YESTERDAY")
    end
    return string.format(LText("TIME_DAYS_AGO_FMT"), math.floor(delta / 86400))
end

local function BuildTokenHistoryInfo(db)
    local history = GetTokenHistory(db)
    local info = {}
    for index, entry in ipairs(history) do
        local price = tonumber(entry and entry.priceCopper)
        local timestamp = tonumber(entry and entry.timestamp)
        if price and price > 0 and timestamp and timestamp > 0 then
            info[#info + 1] = {
                timestamp = timestamp,
                priceCopper = price,
                deltaCopper = tonumber(entry.deltaCopper),
                priceText = FormatTokenHistoryPrice(price),
                deltaText = FormatDeltaText(entry.deltaCopper),
                updatedText = FormatTokenTimestamp(timestamp),
                relativeText = FormatRelativeAge(timestamp),
                index = index,
            }
        end
    end
    return info
end

function lv.GetWowTokenInfo()
    local db = EnsureTokenDB()
    local price = tonumber(db.tokenPrice)
    local updatedAt = tonumber(db.tokenPriceUpdated)
    local delta = tonumber(db.tokenDelta)
    local totalGold = GetWarbandGoldTotal()
    local hasPrice = price and price > 0
    local history = BuildTokenHistoryInfo(db)

    return {
        supported = HasTokenAPI(),
        price = hasPrice and price or nil,
        updatedAt = updatedAt,
        updatedText = FormatTokenTimestamp(updatedAt),
        updatedRelativeText = FormatRelativeAge(updatedAt),
        previousPrice = tonumber(db.tokenPreviousPrice),
        delta = delta,
        deltaText = FormatDeltaText(delta),
        stale = hasPrice and IsTokenPriceStale(updatedAt) or false,
        totalGold = totalGold,
        canAfford = hasPrice and totalGold >= price or false,
        helpText = LText("MSG_WOW_TOKEN_VISIT_AH"),
        history = history,
        historyCount = #history,
    }
end

function lv.RequestWowTokenPriceRefresh()
    return RequestTokenPriceRefresh()
end

SLASH_LITEVAULTTOKEN1 = "/lvtoken"
SlashCmdList["LITEVAULTTOKEN"] = function()
    local info = lv.GetWowTokenInfo and lv.GetWowTokenInfo() or nil
    if not info then
        print("|cff9482c9[LiteVault]|r " .. LText("MSG_WOW_TOKEN_DATA_UNAVAILABLE"))
        return
    end

    if not info.supported then
        print("|cff9482c9[LiteVault]|r " .. LText("MSG_WOW_TOKEN_API_UNAVAILABLE"))
        return
    end

    if not info.price then
        print("|cff9482c9[LiteVault]|r " .. (info.helpText or LText("MSG_WOW_TOKEN_VISIT_AH")))
        return
    end

    local moneyText = (GetCoinTextureString and GetCoinTextureString(info.price)) or tostring(info.price)
    local updatedText = info.updatedText or LText("LABEL_UNKNOWN")
    local affordText = info.canAfford and LText("BUTTON_YES") or LText("BUTTON_NO")
    print("|cff9482c9[LiteVault]|r " .. LText("LABEL_WOW_TOKEN") .. " " .. moneyText)
    print("|cff9482c9[LiteVault]|r " .. LText("LABEL_LAST_UPDATED") .. ": " .. updatedText)
    if info.previousPrice and info.previousPrice > 0 then
        print("|cff9482c9[LiteVault]|r " .. LText("LABEL_PREVIOUS") .. ": " .. FormatTokenHistoryPrice(info.previousPrice))
    end
    if info.deltaText then
        print("|cff9482c9[LiteVault]|r " .. LText("LABEL_TOKEN_DELTA") .. ": " .. info.deltaText)
    end
    print("|cff9482c9[LiteVault]|r " .. LText("LABEL_TOKEN_AFFORDABLE") .. ": " .. affordText)
    print("|cff9482c9[LiteVault]|r " .. LText("LABEL_HISTORY_COUNT") .. ": " .. tostring(info.historyCount or 0))
    if info.history and #info.history > 0 then
        print("|cff9482c9[LiteVault]|r " .. LText("LABEL_RECENT_HISTORY") .. ":")
        local startIndex = math.max(1, #info.history - 4)
        for index = #info.history, startIndex, -1 do
            local entry = info.history[index]
            print(string.format("|cff9482c9[LiteVault]|r %s: %s", entry.relativeText or LText("LABEL_UNKNOWN"), entry.priceText or tostring(entry.priceCopper)))
        end
    end
end

local tokenFrame = CreateFrame("Frame")
tokenFrame:RegisterEvent("ADDON_LOADED")
tokenFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
tokenFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
tokenFrame:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED")
tokenFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            EnsureTokenDB()
        end
        return
    end

    if event == "AUCTION_HOUSE_SHOW" or event == "AUCTION_HOUSE_CLOSED" then
        RequestTokenPriceRefresh()
    elseif event == "TOKEN_MARKET_PRICE_UPDATED" then
        RefreshTokenPrice()
    end
end)
