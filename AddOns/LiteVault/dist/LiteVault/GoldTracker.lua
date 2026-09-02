local addonName, lv = ...
local L = lv.L

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

local time = time
local date = date
local pairs = pairs
local ipairs = ipairs
local type = type
local math_abs = math.abs
local math_floor = math.floor
local string_format = string.format
local string_match = string.match
local string_gsub = string.gsub
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local table_concat = table.concat

local SOURCE_DEFS = {
    { key = "vendor", label = LText("LEDGER_VENDOR") },
    { key = "mail", label = LText("LEDGER_MAIL") },
    { key = "auction", label = LText("LEDGER_AUCTION") },
    { key = "wowToken", label = LText("TEXT_PROFIT_SOURCE_WOW_TOKEN", "WoW Token") },
    { key = "ahFee", label = LText("TEXT_PROFIT_SOURCE_AH_FEE") },
    { key = "quest", label = LText("LABEL_QUEST") },
    { key = "worldQuest", label = LText("TEXT_PROFIT_SOURCE_WORLD_QUEST") },
    { key = "weeklyCache", label = LText("TEXT_PROFIT_SOURCE_WEEKLY_CACHE", "Weekly Cache") },
    { key = "cache", label = LText("TEXT_PROFIT_SOURCE_CHEST") },
    { key = "loot", label = LText("TEXT_PROFIT_SOURCE_LOOTED") },
    { key = "trade", label = LText("LEDGER_TRADE") },
    { key = "crafting", label = LText("TEXT_PROFIT_SOURCE_CRAFT") },
    { key = "upgrade", label = LText("LEDGER_UPGRADE") },
    { key = "repair", label = LText("TEXT_PROFIT_SOURCE_REPAIR") },
    { key = "transmog", label = LText("LEDGER_TRANSMOG") },
    { key = "flightpath", label = LText("TEXT_PROFIT_SOURCE_FLIGHT_PATH") },
    { key = "blackMarket", label = LText("TEXT_PROFIT_SOURCE_BLACK_MARKET") },
    { key = "training", label = LText("TEXT_PROFIT_SOURCE_TRAINING") },
    { key = "guildBank", label = LText("TEXT_PROFIT_SOURCE_GUILD_BANK") },
    { key = "warbandBank", label = LText("BUTTON_WARBAND_BANK") },
    { key = "other", label = LText("LEDGER_OTHER") },
}

local SOURCE_LABEL_BY_KEY = {}
for _, source in ipairs(SOURCE_DEFS) do
    SOURCE_LABEL_BY_KEY[source.key] = source.label
end

local NON_PROFIT_SOURCES = {
    wowToken = true,
}

function lv.IsNonProfitGoldSource(sourceKey)
    return sourceKey ~= nil and NON_PROFIT_SOURCES[sourceKey] == true
end

local QUALITY_COLORS = {
    [0] = "9d9d9d",
    [1] = "ffffff",
    [2] = "1eff00",
    [3] = "0070dd",
    [4] = "a335ee",
    [5] = "ff8000",
    [6] = "e6cc80",
    [7] = "00ccff",
    [8] = "00ccff",
}

local CACHE_ITEMS = {
    [224784] = true,
    [244865] = true,
    [226103] = true,
    [232463] = true,
    [224585] = true,
    [250764] = true,
    [250766] = true,
    [250765] = true,
    [250763] = true,
    [217011] = true,
    [217012] = true,
    [217013] = true,
    [235151] = true,
    [244883] = true,
    [254677] = true,
    [268490] = true,
    [260979] = true,
    [269704] = true,
    [263465] = true,
    [268489] = true,
    [268487] = true,
    [263466] = true,
    [268488] = true,
    [260940] = true,
    [268485] = true,
    [260193] = true,
    [264274] = true,
    [264914] = true,
    [270244] = true,
    [270247] = true,
    [262346] = true,
    [262938] = true,
    [263433] = true,
    [263934] = true,
}

local CACHE_NAME_PATTERNS = {
    "cache",
    "trove",
    "chest",
    "satchel",
    "sack",
    "bag",
    "box",
    "pouch",
    "pack",
    "coffer",
    "strongbox",
    "dividends",
}

local ITEM_UPGRADE_INTERACTION_TYPE = (Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.ItemUpgrade) or 53

local lastTriggerTime = 0
local lastTradeTime = 0
local lastQuestTime = 0
local lastQuestWasWorldQuest = false
local lastQuestWasWeekly = false
local lastTurnedInQuestID = nil
local pendingWorldQuestGold = false
local pendingWorldQuestTime = 0
local confirmedWorldQuestGold = false
local confirmedWorldQuestTime = 0
local trackedWorldQuests = {}
local activeQuestTypes = {}
local lastTurnInQuestDebug = nil
local lastQuestRemovalDebug = nil
local lastAHMailTime = 0
local lastRepairTime = 0
local lastGuildRepairTime = 0
local lastFlightTime = 0
local cachedPlayerName = nil
local inItemUpgrade = false
local recentCacheUsed = false
local recentCacheToken = 0
local lastRecentCacheUsedTime = 0
local lastQueuedCacheSnapshot = nil
local lastLikelyCacheSlots = {}
local lastBagSlotSnapshot = {}

local ahPurchaseQueue = {}
local vendorSellQueue = {}
local merchantPurchaseQueue = {}
local mailItemQueue = {}
local cacheItemCounts = {}
local pendingCacheSnapshots = {}
local pendingUpgradeSnapshots = {}
local pendingItemFixups = {}
local processedMailIndices = {}
local postedAuctionItems = {}
local lastCraftingOrderItem = nil
local lastCraftingOrderItemID = nil
local lastCraftingOrderCount = nil
local lastFulfilledOrderItem = nil
local lastFulfilledOrderItemID = nil
local lastFulfilledOrderCount = nil
local nextQueueToken = 0
local UPGRADE_BATCH_BURST_WINDOW = 2.0
local UPGRADE_BATCH_RECENT_WINDOW = 5.0
local REWARD_PENDING_TTL_SECONDS = 2.5
local REWARD_PENDING_CHAT_TTL_SECONDS = 1.5
local pendingQuestReward = nil
local pendingWorldQuestReward = nil
local lastSourceAttributionDebug = nil
local PrunePendingCacheSnapshots
local HasFreshCacheSignal
local function ShallowCopy(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

local function SafeCharKey()
    if type(lv.PLAYER_KEY) == "string" and lv.PLAYER_KEY ~= "" then
        return lv.PLAYER_KEY
    end

    local name = UnitName and UnitName("player")
    local realm = GetRealmName and GetRealmName()
    if name and realm and realm ~= "" then
        return name .. "-" .. realm:gsub("%s+", "")
    end
    return nil
end

local function GetDisplayNameFromLink(itemLink)
    return type(itemLink) == "string" and itemLink:match("%[(.-)%]") or nil
end

local function GetPreciseNow()
    return (GetTimePreciseSec and GetTimePreciseSec()) or time()
end

local function SetPendingReward(sourceKey, questID, amount, ttlSeconds, reason)
    local reward = {
        source = sourceKey,
        questID = questID,
        amount = tonumber(amount),
        createdAt = GetTime(),
        expiresAt = GetTime() + (ttlSeconds or REWARD_PENDING_TTL_SECONDS),
        reason = reason,
    }
    if sourceKey == "worldQuest" then
        pendingWorldQuestReward = reward
    else
        pendingQuestReward = reward
    end
    return reward
end

local function ClearPendingReward(sourceKey)
    if sourceKey == "worldQuest" then
        pendingWorldQuestReward = nil
    elseif sourceKey == "quest" then
        pendingQuestReward = nil
    end
end

local function GetPendingReward(sourceKey, nowTime)
    local reward = (sourceKey == "worldQuest") and pendingWorldQuestReward or pendingQuestReward
    if not reward then
        return nil
    end
    nowTime = nowTime or GetTime()
    if tonumber(reward.expiresAt) and nowTime <= reward.expiresAt then
        return reward
    end
    ClearPendingReward(sourceKey)
    return nil
end

local function DescribePendingReward(reward, nowTime)
    if not reward then
        return "none"
    end
    nowTime = nowTime or GetTime()
    local ttlRemaining = math.max(0, (tonumber(reward.expiresAt) or 0) - nowTime)
    return string_format(
        "%s amount=%s ttl=%.1fs questID=%s via=%s",
        tostring(reward.source or "?"),
        tostring(reward.amount),
        ttlRemaining,
        tostring(reward.questID or "?"),
        tostring(reward.reason or "?")
    )
end

local function ExtractMoneyAmountFromMessage(message)
    if type(message) ~= "string" then
        return nil
    end
    if GetMoneyFromString then
        local ok, amount = pcall(GetMoneyFromString, message)
        if ok and type(amount) == "number" and amount > 0 then
            return amount
        end
    end
    return nil
end

local QUEST_REWARD_CHAT_GLOBAL_KEYS = {
    "ERR_QUEST_REWARD_MONEY_S",
    "ERR_QUEST_REWARD_MONEY",
}

local cachedQuestRewardChatPatterns = nil
local cachedNormalizedQuestRewardChatPatterns = nil

local function NormalizeSystemMessageText(text)
    if type(text) ~= "string" then
        return nil
    end
    return text:gsub("\239\188\154", ":"):gsub("\239\188\140", ","):gsub("%s+", " ")
end

local function EscapeLuaPatternLiteral(text)
    return (text or ""):gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

local function BuildLocalizedFormatPattern(fmt)
    if type(fmt) ~= "string" or fmt == "" then
        return nil
    end

    local parts = { "^" }
    local index = 1
    while index <= #fmt do
        local rest = fmt:sub(index)
        local placeholder = rest:match("^(%%[%d%$%.%-]*[%a])")
        if rest:match("^%%%%") then
            parts[#parts + 1] = "%%"
            index = index + 2
        elseif placeholder then
            parts[#parts + 1] = ".+"
            index = index + #placeholder
        else
            local char = fmt:sub(index, index)
            if char:match("%s") then
                local whitespaceEnd = index + 1
                while whitespaceEnd <= #fmt and fmt:sub(whitespaceEnd, whitespaceEnd):match("%s") do
                    whitespaceEnd = whitespaceEnd + 1
                end
                parts[#parts + 1] = "%s+"
                index = whitespaceEnd
            else
                parts[#parts + 1] = EscapeLuaPatternLiteral(char)
                index = index + 1
            end
        end
    end

    parts[#parts + 1] = "%s*$"
    return table_concat(parts)
end

local function GetQuestRewardChatPatterns()
    if cachedQuestRewardChatPatterns then
        return cachedQuestRewardChatPatterns, cachedNormalizedQuestRewardChatPatterns
    end

    cachedQuestRewardChatPatterns = {}
    cachedNormalizedQuestRewardChatPatterns = {}

    local seen = {}
    for _, globalKey in ipairs(QUEST_REWARD_CHAT_GLOBAL_KEYS) do
        local fmt = _G and _G[globalKey]
        local pattern = BuildLocalizedFormatPattern(fmt)
        if pattern and not seen[pattern] then
            seen[pattern] = true
            table_insert(cachedQuestRewardChatPatterns, pattern)
            table_insert(cachedNormalizedQuestRewardChatPatterns, BuildLocalizedFormatPattern(NormalizeSystemMessageText(fmt)) or pattern)
        end
    end

    return cachedQuestRewardChatPatterns, cachedNormalizedQuestRewardChatPatterns
end

local function IsLocalizedQuestRewardMoneyMessage(message)
    if type(message) ~= "string" or message == "" then
        return false
    end

    local patterns, normalizedPatterns = GetQuestRewardChatPatterns()
    if not patterns or #patterns == 0 then
        return false
    end

    local normalizedMessage = NormalizeSystemMessageText(message)
    for index, pattern in ipairs(patterns) do
        if string_match(message, pattern) then
            return true
        end

        local normalizedPattern = normalizedPatterns and normalizedPatterns[index]
        if normalizedMessage and normalizedPattern and string_match(normalizedMessage, normalizedPattern) then
            return true
        end
    end

    return false
end

local function IsLootSourceActive()
    return LootFrame and LootFrame.IsShown and LootFrame:IsShown()
end

local function IsQuestSourceActive()
    return (QuestFrame and QuestFrame.IsShown and QuestFrame:IsShown())
        or (GossipFrame and GossipFrame.IsShown and GossipFrame:IsShown())
end

local function GetPendingCacheSnapshot(windowSeconds)
    PrunePendingCacheSnapshots(windowSeconds)
    return pendingCacheSnapshots[1]
end

local function IsRealNamedCacheSnapshot(snapshot)
    if not snapshot then
        return false
    end
    if snapshot.itemID or snapshot.itemLink then
        return true
    end

    local genericLabel = SOURCE_LABEL_BY_KEY.cache or "Chest"
    local name = tostring(snapshot.name or "")
    return name ~= "" and name ~= genericLabel
end

local function IsOpenedNamedCacheSnapshot(snapshot)
    return snapshot and snapshot.openedContainer and IsRealNamedCacheSnapshot(snapshot) or false
end

local function FindPendingCacheSnapshot(windowSeconds, predicate)
    PrunePendingCacheSnapshots(windowSeconds)
    for index, snapshot in ipairs(pendingCacheSnapshots) do
        if not predicate or predicate(snapshot) then
            return snapshot, index
        end
    end
    return nil, nil
end

local function HasRealCacheSnapshotEvidence(windowSeconds)
    local snapshot = FindPendingCacheSnapshot(windowSeconds, IsRealNamedCacheSnapshot)
    return snapshot ~= nil
end

local function HasOpenedNamedCacheSnapshotEvidence(windowSeconds)
    local snapshot = FindPendingCacheSnapshot(windowSeconds, IsOpenedNamedCacheSnapshot)
    return snapshot ~= nil
end

local function IsTransactionBackedByRealCacheEvidence(tx)
    if not tx then
        return false
    end
    if tx.itemID or tx.detailLink or tx.cacheItemLink then
        return true
    end

    local genericLabel = SOURCE_LABEL_BY_KEY.cache or "Chest"
    local cacheName = tostring(tx.cacheName or "")
    local detailName = tostring(tx.detailName or "")
    if cacheName ~= "" and cacheName ~= genericLabel then
        return true
    end
    return detailName ~= "" and detailName ~= genericLabel
end

local function GetRecentQuestFallbackState(nowTime)
    local age = nowTime - (lastQuestTime or 0)
    if age >= 0 and age < 5.0 then
        return true, age
    end
    return false, age
end

local function HasRecentPendingWorldQuestGold(nowTime)
    nowTime = nowTime or GetTime()
    local age = nowTime - (pendingWorldQuestTime or 0)
    if pendingWorldQuestGold and age >= 0 and age < 5.0 then
        return true, age
    end
    if pendingWorldQuestGold and age >= 5.0 then
        pendingWorldQuestGold = false
        pendingWorldQuestTime = 0
    end
    return false, age
end

local function HasRecentConfirmedWorldQuestGold(nowTime)
    nowTime = nowTime or GetTime()
    local age = nowTime - (confirmedWorldQuestTime or 0)
    if confirmedWorldQuestGold and age >= 0 and age < 5.0 then
        return true, age
    end
    if confirmedWorldQuestGold and age >= 5.0 then
        confirmedWorldQuestGold = false
        confirmedWorldQuestTime = 0
    end
    return false, age
end

local function ConsumeConfirmedWorldQuestGold()
    confirmedWorldQuestGold = false
    confirmedWorldQuestTime = 0
    pendingWorldQuestGold = false
    pendingWorldQuestTime = 0
end

local function DescribeQuestSourceState(nowTime, pendingReward)
    local parts = {}
    if pendingReward then
        table_insert(parts, DescribePendingReward(pendingReward, nowTime))
    end

    local hasRecentQuest, age = GetRecentQuestFallbackState(nowTime)
    if hasRecentQuest and not lastQuestWasWorldQuest then
        table_insert(parts, string_format("recent quest fallback age=%.1fs", age))
    end

    if #parts == 0 then
        return "none"
    end
    return table_concat(parts, "; ")
end

local function DescribeWorldQuestSourceState(nowTime, pendingReward)
    local parts = {}
    if pendingReward then
        table_insert(parts, DescribePendingReward(pendingReward, nowTime))
    end

    local hasPendingWorldQuest, pendingAge = HasRecentPendingWorldQuestGold(nowTime)
    if hasPendingWorldQuest then
        table_insert(parts, string_format("pending world quest age=%.1fs", pendingAge))
    end

    local hasConfirmedWorldQuest, confirmedAge = HasRecentConfirmedWorldQuestGold(nowTime)
    if hasConfirmedWorldQuest then
        table_insert(parts, string_format("confirmed world quest age=%.1fs", confirmedAge))
    end

    local hasRecentQuest, questAge = GetRecentQuestFallbackState(nowTime)
    if hasRecentQuest and lastQuestWasWorldQuest then
        table_insert(parts, string_format("recent world quest fallback age=%.1fs", questAge))
    end

    if #parts == 0 then
        return "none"
    end
    return table_concat(parts, "; ")
end

local function DescribeActiveCacheSource(flagWindowSeconds, snapshotWindowSeconds)
    local flagWindow = flagWindowSeconds or 4
    local hasRecentFlag = recentCacheUsed and (GetTime() - (lastRecentCacheUsedTime or 0)) < flagWindow
    local snapshot = GetPendingCacheSnapshot(snapshotWindowSeconds or 20)
    if not hasRecentFlag and not snapshot then
        return "none"
    end

    if snapshot and snapshot.name then
        return "snapshot:" .. tostring(snapshot.name)
    end
    if hasRecentFlag then
        return "recent cache flag"
    end
    return "cache signal"
end

local function RecordSourceAttributionDebug(debugInfo)
    lastSourceAttributionDebug = debugInfo
end

local function AllocateQueueToken()
    nextQueueToken = nextQueueToken + 1
    return nextQueueToken
end

local function IsLikelyCacheItem(itemID, itemLink, itemName)
    if itemID and CACHE_ITEMS[itemID] then
        return true
    end

    local name = itemName
    if not name and itemLink and C_Item and C_Item.GetItemInfo then
        name = C_Item.GetItemInfo(itemLink)
    end
    if not name and type(itemLink) == "string" then
        name = itemLink:match("%[(.-)%]")
    end
    if not name and itemID and C_Item and C_Item.GetItemInfo then
        name = C_Item.GetItemInfo(itemID)
    end
    if type(name) ~= "string" then
        return false
    end

    name = name:lower()
    for _, pattern in ipairs(CACHE_NAME_PATTERNS) do
        if name:find(pattern, 1, true) then
            return true
        end
    end

    return false
end

local function CleanCSVText(text)
    if type(text) ~= "string" then
        return ""
    end

    local cleaned = text
    cleaned = string_gsub(cleaned, "|c%x%x%x%x%x%x%x%x", "")
    cleaned = string_gsub(cleaned, "|r", "")
    cleaned = string_gsub(cleaned, "|H.-|h", "")
    cleaned = string_gsub(cleaned, "|h", "")
    cleaned = string_gsub(cleaned, "|A:[^|]+|a", "")
    return cleaned
end

local function EscapeCSVField(value)
    if value == nil then
        return ""
    end

    local text = tostring(value)
    if text:find('"', 1, true) then
        text = string_gsub(text, '"', '""')
    end

    if text:find(",", 1, true) or text:find('"', 1, true) or text:find("\n", 1, true) or text:find("\r", 1, true) then
        return '"' .. text .. '"'
    end

    return text
end

local function FormatCSVWholeNumber(value)
    local formatted = tostring(value or 0)
    local changed = true
    while changed do
        formatted, changed = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        changed = changed > 0
    end
    return formatted
end

local function FormatCSVAmount(amount)
    amount = tonumber(amount) or 0
    local sign = amount >= 0 and "+" or "-"
    local absolute = math_abs(amount)
    local gold = math_floor(absolute / 10000)
    local silver = math_floor((absolute % 10000) / 100)
    local copper = absolute % 100
    local parts = {}

    if gold > 0 then
        parts[#parts + 1] = FormatCSVWholeNumber(gold) .. "g"
    end
    if silver > 0 then
        parts[#parts + 1] = tostring(silver) .. "s"
    end
    if copper > 0 or #parts == 0 then
        parts[#parts + 1] = tostring(copper) .. "c"
    end

    return sign .. table_concat(parts, " ")
end

local function IsExportAuctionFeeTransaction(tx)
    return tx and (tx.source == "ahFee" or (tx.source == "auction" and tx.detailName == "Fee"))
end

local function GetExportSourceLabel(tx)
    if not tx then
        return ""
    end
    if IsExportAuctionFeeTransaction(tx) then
        return SOURCE_LABEL_BY_KEY.ahFee or "AH Fee"
    end
    return tx.sourceLabel or SOURCE_LABEL_BY_KEY[tx.source or "other"] or ""
end

local function GetExportGenericDetailFallback(tx)
    if not tx or not tx.source then
        return ""
    end
    if IsExportAuctionFeeTransaction(tx) then
        return LText("TEXT_PROFIT_FALLBACK_AUCTION_FEE")
    elseif tx.source == "upgrade" then
        return LText("TEXT_PROFIT_FALLBACK_GEAR_UPGRADE")
    elseif tx.source == "quest" then
        return LText("TEXT_PROFIT_FALLBACK_GOLD_REWARD")
    elseif tx.source == "worldQuest" then
        return LText("TEXT_PROFIT_FALLBACK_GOLD_REWARD")
    elseif tx.source == "weeklyCache" then
        return LText("TEXT_PROFIT_FALLBACK_GOLD_REWARD")
    elseif tx.source == "mail" then
        return (tonumber(tx.amount) or 0) < 0
            and LText("TEXT_PROFIT_FALLBACK_GOLD_SENT")
            or LText("TEXT_PROFIT_FALLBACK_GOLD_RECEIVED")
    elseif tx.source == "wowToken" then
        return LText("TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE", "WoW Token Purchase")
    elseif tx.source == "auction" then
        return (tonumber(tx.amount) or 0) < 0
            and LText("TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE")
            or LText("TEXT_PROFIT_FALLBACK_AUCTION_SALE")
    elseif tx.source == "guildBank" then
        return (tonumber(tx.amount) or 0) < 0
            and LText("TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT")
            or LText("TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL")
    elseif tx.source == "trade" then
        return (tonumber(tx.amount) or 0) < 0
            and LText("TEXT_PROFIT_FALLBACK_TRADE_PAYMENT")
            or LText("TEXT_PROFIT_FALLBACK_TRADE_GAIN")
    elseif tx.source == "crafting" then
        return LText("TEXT_PROFIT_FALLBACK_CRAFTING_ORDER")
    elseif tx.source == "loot" then
        return LText("TEXT_PROFIT_FALLBACK_RAW_GOLD")
    elseif tx.source == "repair" then
        return LText("TEXT_PROFIT_FALLBACK_SERVICE_COST")
    elseif tx.source == "training" then
        return LText("TEXT_PROFIT_FALLBACK_TRAINING_COST")
    elseif tx.source == "transmog" then
        return LText("TEXT_PROFIT_FALLBACK_APPEARANCE_COST")
    elseif tx.source == "flightpath" then
        return LText("TEXT_PROFIT_FALLBACK_TRAVEL_COST")
    elseif tx.source == "blackMarket" then
        return LText("TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE")
    end
    return GetExportSourceLabel(tx)
end

local function IsExportGenericSourceDetail(tx, detailName, sourceName, genericFallback)
    if detailName == "" then
        return true
    end
    if detailName == sourceName or detailName == genericFallback then
        return true
    end
    if tx and tx.source == "worldQuest" and detailName == (SOURCE_LABEL_BY_KEY.loot or "Looted") then
        return true
    end
    if tx and tx.source == "loot" and detailName == (SOURCE_LABEL_BY_KEY.loot or "Looted") then
        return true
    end
    if not tx or not tx.source then
        return false
    end

    local genericNames = {
        mail = { Mail = true },
        auction = { Auction = true, ["Auction House"] = true },
        guildBank = { ["Guild Bank"] = true },
        trade = { Trade = true },
        crafting = { Craft = true, Crafting = true },
    }

    local names = genericNames[tx.source]
    return names and names[detailName] or false
end

local function GetExportAuctionFeeQuantitySuffix(detailText)
    if type(detailText) ~= "string" then
        return ""
    end
    return detailText:match("( x%d+)$") or ""
end

local function GetExportDetailText(tx)
    if not tx then
        return ""
    end

    local genericFallback = GetExportGenericDetailFallback(tx)
    local sourceName = GetExportSourceLabel(tx)

    if IsExportAuctionFeeTransaction(tx) then
        local feeName = CleanCSVText(tx.detailLink or "")
        if feeName == "" then
            feeName = CleanCSVText(tx.detailText or "")
        end
        if feeName == "" then
            local detailName = CleanCSVText(tx.detailName or "")
            if detailName ~= sourceName then
                feeName = detailName
            end
        end
        if feeName == "" or feeName == "Auction House" or feeName == "AH Fee" or feeName == genericFallback then
            return genericFallback
        end
        return feeName .. GetExportAuctionFeeQuantitySuffix(tx.detailText)
    end

    if tx.source == "vendor" then
        local vendorDetail = CleanCSVText(tx.detailLink or tx.detailName or "")
        if vendorDetail ~= "" then
            return string_format("%dx %s", tonumber(tx.count) or 1, vendorDetail)
        end
        return genericFallback
    end

    if tx.source == "upgrade" then
        return genericFallback
    end

    if tx.source == "cache" then
        local cacheDetail = CleanCSVText(tx.cacheItemLink or tx.detailLink or tx.cacheName or tx.detailName or "")
        if cacheDetail ~= "" and cacheDetail ~= sourceName and cacheDetail ~= genericFallback then
            return cacheDetail
        end
        return genericFallback
    end

    local linkedDetail = CleanCSVText(tx.detailLink or "")
    if linkedDetail ~= "" then
        return linkedDetail
    end

    local detailName = CleanCSVText(tx.detailName or "")
    if detailName ~= "" then
        if IsExportGenericSourceDetail(tx, detailName, sourceName, genericFallback) then
            detailName = ""
        end
    end

    if detailName ~= "" then
        return detailName
    end

    return genericFallback
end

local function GetStorage()
    LiteVaultDB = LiteVaultDB or {}
    LiteVaultDB.goldHistory = LiteVaultDB.goldHistory or {
        version = 1,
        transactions = {},
        lastKnownMoney = {},
        itemCache = {},
        goals = {
            week = nil,
            month = nil,
        },
    }

    local storage = LiteVaultDB.goldHistory
    storage.transactions = storage.transactions or {}
    storage.lastKnownMoney = storage.lastKnownMoney or {}
    storage.itemCache = storage.itemCache or {}
    storage.goals = storage.goals or { week = nil, month = nil }
    if type(storage.lastRetentionAt) ~= "number" or (time() - storage.lastRetentionAt) > (7 * 24 * 60 * 60) then
        -- Weekly/monthly reporting needs far less, but retain over a year for export and audits.
        local cutoff = time() - (400 * 24 * 60 * 60)
        for i = #storage.transactions, 1, -1 do
            local tx = storage.transactions[i]
            if type(tx) == "table" and type(tx.timestamp) == "number" and tx.timestamp < cutoff then
                table.remove(storage.transactions, i)
            end
        end
        storage.lastRetentionAt = time()
    end
    return storage
end

local VALID_GOAL_PERIODS = {
    week = true,
    month = true,
}

local function NormalizeProfitGoalEntry(goalValue)
    if goalValue == nil then
        return nil
    end

    if type(goalValue) == "number" then
        local amount = math_floor(goalValue)
        if amount > 0 then
            return {
                scope = "warband",
                amount = amount,
                updatedAt = time(),
            }
        end
        return nil
    end

    if type(goalValue) == "table" then
        local amount = tonumber(goalValue.amount or goalValue.copper or goalValue.value)
        if amount and amount > 0 then
            return {
                scope = "warband",
                amount = math_floor(amount),
                updatedAt = tonumber(goalValue.updatedAt) or time(),
            }
        end
    end

    return nil
end

local function GetNormalizedProfitGoal(period, persist)
    if not VALID_GOAL_PERIODS[period] then
        return nil
    end

    local storage = GetStorage()
    storage.goals = storage.goals or { week = nil, month = nil }
    local currentValue = storage.goals[period]
    local normalized = NormalizeProfitGoalEntry(currentValue)
    if persist and normalized ~= currentValue then
        storage.goals[period] = normalized
    end
    return normalized
end

local function ExtractAndStripPip(itemLink)
    if not itemLink then
        return itemLink, nil
    end

    local pipAtlas = itemLink:match("|A:(Professions%-ChatIcon%-Quality%-[%d%-]*Tier%d)")
    local stripped = itemLink:gsub(" ?|A:Professions%-ChatIcon%-Quality%-[%d%-]*Tier%d[^|]*|a", "")
    return stripped, pipAtlas
end

local function StripQualityPip(itemLink)
    local stripped = ExtractAndStripPip(itemLink)
    return stripped
end

local function GetItemID(itemInfo)
    if not itemInfo then
        return nil
    end
    if type(itemInfo) == "number" then
        return itemInfo
    end

    local itemID = itemInfo:match("|Hitem:(%d+)")
    if itemID then
        return tonumber(itemID)
    end

    if C_Item and C_Item.GetItemIDForItemInfo then
        local success, resolvedID = pcall(C_Item.GetItemIDForItemInfo, itemInfo)
        if success and resolvedID and resolvedID > 0 then
            return resolvedID
        end

        local plainName = itemInfo:match("%[([^%]]+)%]") or itemInfo
        if plainName ~= itemInfo then
            success, resolvedID = pcall(C_Item.GetItemIDForItemInfo, plainName)
            if success and resolvedID and resolvedID > 0 then
                return resolvedID
            end
        end
    end

    return nil
end

local function CaptureItemData(itemInfo, qualityTier)
    if not itemInfo then
        return nil, nil, nil, nil
    end

    local itemID = GetItemID(itemInfo)
    local itemLink = itemInfo

    if itemID and C_Item and C_Item.GetItemInfo then
        local _, resolvedLink = C_Item.GetItemInfo(itemID)
        if resolvedLink then
            itemLink = resolvedLink
        elseif (type(itemInfo) == "number" or not tostring(itemInfo):match("|H")) and C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID then
            if not C_Item.IsItemDataCachedByID(itemID) then
                C_Item.RequestLoadItemDataByID(itemID)
            end
            local quality = C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(itemID) or nil
            local name = C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID) or nil
            if name then
                local color = QUALITY_COLORS[quality or 1] or "ffffff"
                itemLink = string_format("|cff%s[%s]|r", color, name)
            end
        end
    end

    local pipAtlas
    itemLink, pipAtlas = ExtractAndStripPip(itemLink)
    return itemLink, itemID, qualityTier, pipAtlas
end

local function MarkRecentCacheUsed(duration)
    recentCacheToken = recentCacheToken + 1
    local token = recentCacheToken
    recentCacheUsed = true
    lastRecentCacheUsedTime = GetTime()
    if C_Timer then
        C_Timer.After(duration or 15, function()
            if token == recentCacheToken then
                recentCacheUsed = false
            end
        end)
    end
end

PrunePendingCacheSnapshots = function(windowSeconds)
    local cutoff = time() - (windowSeconds or 20)
    while #pendingCacheSnapshots > 0 do
        local snapshot = pendingCacheSnapshots[1]
        if snapshot and snapshot.timestamp and snapshot.timestamp >= cutoff then
            break
        end
        table_remove(pendingCacheSnapshots, 1)
    end
end

local function PrunePendingUpgradeSnapshots(windowSeconds)
    local cutoff = time() - (windowSeconds or 20)
    while #pendingUpgradeSnapshots > 0 do
        local snapshot = pendingUpgradeSnapshots[1]
        if snapshot and snapshot.timestamp and snapshot.timestamp >= cutoff then
            break
        end
        table_remove(pendingUpgradeSnapshots, 1)
    end
end

local function QueueCacheSnapshot(itemID, itemLink, itemName, evidenceKind)
    if not IsLikelyCacheItem(itemID, itemLink, itemName) then
        return
    end

    local finalLink, finalItemID, _, pip = CaptureItemData(itemLink or itemID or itemName)
    if pip and finalLink and not finalLink:match("|A:Professions") then
        finalLink = finalLink .. " " .. string_format("|A:%s:12:12:0:-6|a", pip)
    end
    local resolvedName = GetDisplayNameFromLink(finalLink)
        or itemName
        or (finalItemID and string_format(LText("TEXT_PROFIT_ITEM_FALLBACK_FMT"), finalItemID))
        or SOURCE_LABEL_BY_KEY.cache

    local preciseNow = GetPreciseNow()
    if lastQueuedCacheSnapshot
        and not lastQueuedCacheSnapshot.consumed
        and lastQueuedCacheSnapshot.itemID == finalItemID
        and lastQueuedCacheSnapshot.name == resolvedName
        and (preciseNow - (lastQueuedCacheSnapshot.preciseTimestamp or 0)) <= 0.75 then
        if evidenceKind == "openedContainer" then
            lastQueuedCacheSnapshot.openedContainer = true
        end
        MarkRecentCacheUsed()
        return
    end

    local snapshot = {
        itemID = finalItemID or itemID,
        itemLink = finalLink or itemLink,
        name = resolvedName,
        timestamp = time(),
        preciseTimestamp = preciseNow,
        openedContainer = (evidenceKind == "openedContainer"),
    }
    pendingCacheSnapshots[#pendingCacheSnapshots + 1] = snapshot
    lastQueuedCacheSnapshot = snapshot
    while #pendingCacheSnapshots > 10 do
        table_remove(pendingCacheSnapshots, 1)
    end
    MarkRecentCacheUsed()
end

local function QueueUpgradeSnapshot()
    local itemLink = C_ItemUpgrade and C_ItemUpgrade.GetItemHyperlink and C_ItemUpgrade.GetItemHyperlink()
    local finalLink, itemID = CaptureItemData(itemLink)
    local itemName = GetDisplayNameFromLink(finalLink) or "Gear Upgrade"

    local snapshot = {
        itemID = itemID,
        itemLink = finalLink or itemLink,
        name = itemName,
        expectedCopper = nil,
        timestamp = time(),
        preciseTimestamp = GetPreciseNow(),
    }
    pendingUpgradeSnapshots[#pendingUpgradeSnapshots + 1] = snapshot
    while #pendingUpgradeSnapshots > 10 do
        table_remove(pendingUpgradeSnapshots, 1)
    end
end

local function ConsumePendingCacheSnapshot(windowSeconds, predicate)
    local _, index = FindPendingCacheSnapshot(windowSeconds, predicate)
    if not index then
        return nil
    end
    local snapshot = table_remove(pendingCacheSnapshots, index)
    if snapshot then
        snapshot.consumed = true
    end
    return snapshot
end

local function ConsumePendingUpgradeSnapshot(windowSeconds)
    PrunePendingUpgradeSnapshots(windowSeconds)
    if #pendingUpgradeSnapshots == 0 then
        return nil
    end
    return table_remove(pendingUpgradeSnapshots, 1)
end

local function ConsumeUpgradeSnapshotPrefix(count)
    if type(count) ~= "number" or count <= 0 then
        return nil
    end

    local consumed = {}
    for _ = 1, math.min(count, #pendingUpgradeSnapshots) do
        consumed[#consumed + 1] = table_remove(pendingUpgradeSnapshots, 1)
    end
    return consumed
end

local function GetRecentUpgradeBurstCount(windowSeconds)
    PrunePendingUpgradeSnapshots(windowSeconds)
    if #pendingUpgradeSnapshots == 0 then
        return 0
    end

    local nowPrecise = GetPreciseNow()
    local firstPrecise = nil
    local count = 0

    for index, snapshot in ipairs(pendingUpgradeSnapshots) do
        local preciseTs = tonumber(snapshot and snapshot.preciseTimestamp) or tonumber(snapshot and snapshot.timestamp) or 0
        if (nowPrecise - preciseTs) > UPGRADE_BATCH_RECENT_WINDOW then
            break
        end

        if not firstPrecise then
            firstPrecise = preciseTs
        elseif (preciseTs - firstPrecise) > UPGRADE_BATCH_BURST_WINDOW then
            break
        end

        count = index
    end

    return count
end

local function ConsumeUpgradeSnapshotsForDiff(diff, windowSeconds)
    PrunePendingUpgradeSnapshots(windowSeconds)
    if type(diff) ~= "number" or diff >= 0 or #pendingUpgradeSnapshots == 0 then
        return nil, nil
    end

    local target = math_abs(diff)
    local runningTotal = 0

    for index, snapshot in ipairs(pendingUpgradeSnapshots) do
        local expectedCopper = tonumber(snapshot and snapshot.expectedCopper)
        if not expectedCopper or expectedCopper <= 0 then
            break
        end

        runningTotal = runningTotal + expectedCopper
        if runningTotal == target then
            return ConsumeUpgradeSnapshotPrefix(index), "expected"
        elseif runningTotal > target then
            break
        end
    end

    local burstCount = GetRecentUpgradeBurstCount(windowSeconds)
    if burstCount >= 2 and (target % burstCount) == 0 then
        return ConsumeUpgradeSnapshotPrefix(burstCount), "evenSplit"
    end

    return nil, nil
end

local function PeekUpgradeSnapshotsForDiff(diff, windowSeconds)
    PrunePendingUpgradeSnapshots(windowSeconds)
    if type(diff) ~= "number" or diff >= 0 or #pendingUpgradeSnapshots == 0 then
        return nil, nil
    end

    local target = math_abs(diff)
    local runningTotal = 0
    local snapshots = {}

    for _, snapshot in ipairs(pendingUpgradeSnapshots) do
        local expectedCopper = tonumber(snapshot and snapshot.expectedCopper)
        if not expectedCopper or expectedCopper <= 0 then
            break
        end

        snapshots[#snapshots + 1] = snapshot
        runningTotal = runningTotal + expectedCopper
        if runningTotal == target then
            return snapshots, "expected"
        elseif runningTotal > target then
            break
        end
    end

    local burstCount = GetRecentUpgradeBurstCount(windowSeconds)
    if burstCount >= 2 and (target % burstCount) == 0 then
        local evenSnapshots = {}
        for index = 1, math.min(burstCount, #pendingUpgradeSnapshots) do
            evenSnapshots[#evenSnapshots + 1] = pendingUpgradeSnapshots[index]
        end
        if #evenSnapshots == burstCount then
            return evenSnapshots, "evenSplit"
        end
    end

    return nil, nil
end

local function HasRecentCacheSnapshot(windowSeconds)
    PrunePendingCacheSnapshots(windowSeconds)
    return #pendingCacheSnapshots > 0
end

HasFreshCacheSignal = function(flagWindowSeconds, snapshotWindowSeconds)
    local flagWindow = flagWindowSeconds or 4
    if recentCacheUsed and (GetTime() - (lastRecentCacheUsedTime or 0)) < flagWindow then
        return true
    end
    return HasRecentCacheSnapshot(snapshotWindowSeconds or 20)
end

local function HasPendingUpgradeSnapshot(windowSeconds)
    PrunePendingUpgradeSnapshots(windowSeconds)
    return #pendingUpgradeSnapshots > 0
end

local function RefreshBagSlotSnapshot()
    lastBagSlotSnapshot = {}
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
        return
    end

    for bagID = (BACKPACK_CONTAINER or 0), (NUM_BAG_SLOTS or 4) do
        local slots = C_Container.GetContainerNumSlots(bagID) or 0
        for slot = 1, slots do
            local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
            if itemInfo and itemInfo.itemID then
                lastBagSlotSnapshot[bagID] = lastBagSlotSnapshot[bagID] or {}
                lastBagSlotSnapshot[bagID][slot] = {
                    itemID = itemInfo.itemID,
                    hyperlink = itemInfo.hyperlink,
                    itemName = itemInfo.itemName,
                    stackCount = itemInfo.stackCount,
                }
            end
        end
    end
end

local function MarkCacheContainerIfPresent(bagID, slot)
    if not bagID or not slot or not (C_Container and C_Container.GetContainerItemInfo) then
        return
    end

    local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
    local fallbackInfo = lastLikelyCacheSlots
        and lastLikelyCacheSlots[bagID]
        and lastLikelyCacheSlots[bagID][slot]
        or nil

    local itemID = itemInfo and itemInfo.itemID or (fallbackInfo and fallbackInfo.itemID)
    local itemLink = itemInfo and itemInfo.hyperlink or (fallbackInfo and fallbackInfo.hyperlink)
    local itemName = itemInfo and itemInfo.itemName or (fallbackInfo and fallbackInfo.itemName)

    if itemID and CACHE_ITEMS[itemID] then
        MarkRecentCacheUsed()
    end
    if IsLikelyCacheItem(itemID, itemLink, itemName) then
        QueueCacheSnapshot(itemID, itemLink, itemName, "openedContainer")
    end
end

local function BuildLikelyCacheBagState()
    local state = {}
    local slotState = {}
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then
        return state
    end

    for bagID = (BACKPACK_CONTAINER or 0), (NUM_BAG_SLOTS or 4) do
        local slots = C_Container.GetContainerNumSlots(bagID) or 0
        for slot = 1, slots do
            local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
            if itemInfo and itemInfo.itemID and IsLikelyCacheItem(itemInfo.itemID, itemInfo.hyperlink, itemInfo.itemName) then
                slotState[bagID] = slotState[bagID] or {}
                slotState[bagID][slot] = {
                    itemID = itemInfo.itemID,
                    hyperlink = itemInfo.hyperlink,
                    itemName = itemInfo.itemName,
                }
                local entry = state[itemInfo.itemID]
                if not entry then
                    entry = {
                        bags = 0,
                        link = itemInfo.hyperlink,
                        name = itemInfo.itemName,
                    }
                    state[itemInfo.itemID] = entry
                end
                entry.bags = entry.bags + (itemInfo.stackCount or 1)
                entry.link = entry.link or itemInfo.hyperlink
                entry.name = entry.name or itemInfo.itemName
            end
        end
    end

    lastLikelyCacheSlots = slotState
    return state
end

local function ScanCacheItemCounts()
    local bagState = BuildLikelyCacheBagState()
    local trackedIDs = {}

    for itemID in pairs(CACHE_ITEMS) do
        trackedIDs[itemID] = true
    end
    for itemID in pairs(cacheItemCounts) do
        trackedIDs[itemID] = true
    end
    for itemID in pairs(bagState) do
        trackedIDs[itemID] = true
    end

    for itemID in pairs(trackedIDs) do
        local currentBag = bagState[itemID]
        local newBags = currentBag and currentBag.bags or 0
        local newTotal = 0
        if C_Item and C_Item.GetItemCount then
            newTotal = C_Item.GetItemCount(itemID, true) or newBags
        else
            newTotal = newBags
        end

        local old = cacheItemCounts[itemID]
        local oldTotal = type(old) == "table" and old.total or old
        local oldBags = type(old) == "table" and old.bags or old
        if (oldTotal and newTotal < oldTotal) or (oldBags and newBags < oldBags) then
            local snapshotLink = (currentBag and currentBag.link) or (type(old) == "table" and old.link) or nil
            local snapshotName = (currentBag and currentBag.name) or (type(old) == "table" and old.name) or nil
            MarkRecentCacheUsed()
            if IsLikelyCacheItem(itemID, snapshotLink, snapshotName) then
                QueueCacheSnapshot(itemID, snapshotLink, snapshotName, "bagChange")
            end
        end

        if newTotal > 0 or newBags > 0 or CACHE_ITEMS[itemID] then
            cacheItemCounts[itemID] = {
                total = newTotal,
                bags = newBags,
                link = (currentBag and currentBag.link) or (type(old) == "table" and old.link) or nil,
                name = (currentBag and currentBag.name) or (type(old) == "table" and old.name) or nil,
            }
        else
            cacheItemCounts[itemID] = nil
        end
    end
end

local function AttachCacheSnapshotToTransaction(tx, windowSeconds, predicate)
    if not tx then
        return
    end
    local snapshot = ConsumePendingCacheSnapshot(windowSeconds, predicate)
    if not snapshot then
        return
    end
    tx.detailName = snapshot.name or tx.detailName
    tx.detailLink = snapshot.itemLink or tx.detailLink
    tx.cacheName = snapshot.name or tx.cacheName
    tx.cacheItemLink = snapshot.itemLink or tx.cacheItemLink
    tx.itemID = snapshot.itemID or tx.itemID
    tx.count = tx.count or 1
end

local function AttachUpgradeSnapshotToTransaction(tx, windowSeconds)
    if not tx then
        return
    end
    ConsumePendingUpgradeSnapshot(windowSeconds)
end

local function RefreshQueuedItem(queueEntry)
    if not queueEntry then
        return
    end

    local currentItem = queueEntry.item
    if not (currentItem and currentItem:match("|cff9d9d9d%[")) then
        return
    end

    local itemID = queueEntry.itemID
    local cachedPip = queueEntry.pip
    local cachedQuality = nil
    local storage = GetStorage()

    if (not itemID or itemID == 0) and currentItem then
        local itemName = currentItem:match("%[([^%]]+)%]")
        if itemName then
            local posted = postedAuctionItems[itemName]
            if posted then
                itemID = posted.itemID
                cachedPip = cachedPip or posted.pip
                queueEntry.itemID = itemID
            end

            local cached = storage.itemCache[itemName]
            if cached then
                if (not itemID or itemID == 0) and cached.itemID then
                    itemID = cached.itemID
                    queueEntry.itemID = itemID
                end
                if cached.quality then
                    cachedQuality = cached.quality
                end
                if not cachedPip and cached.pip then
                    cachedPip = cached.pip
                end
            end
        end
    end

    if itemID and itemID > 0 and C_Item and C_Item.GetItemInfo then
        local _, itemLink = C_Item.GetItemInfo(itemID)
        if itemLink then
            local finalItem, finalItemID, _, pip = CaptureItemData(itemLink)
            local pipToUse = pip or cachedPip
            if pipToUse and finalItem and not finalItem:match("|A:Professions") then
                finalItem = finalItem .. " " .. string_format("|A:%s:12:12:0:-6|a", pipToUse)
            end
            queueEntry.item = finalItem
            queueEntry.itemID = finalItemID or itemID
            queueEntry.pip = pipToUse
            return
        end

        if C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID and not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        end
    end

    if not queueEntry.item and itemID and itemID > 0 and cachedQuality then
        local color = QUALITY_COLORS[cachedQuality] or "ffffff"
        local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID) or tostring(itemID)
        queueEntry.item = string_format("|cff%s[%s]|r", color, name)
        queueEntry.itemID = itemID
        queueEntry.pip = cachedPip
    end
end

local function ScheduleItemFixup(tx, itemID)
    if not (tx and itemID and C_Timer and C_Item and C_Item.GetItemInfo) then
        return
    end

    pendingItemFixups[#pendingItemFixups + 1] = {
        tx = tx,
        itemID = itemID,
        retries = 0,
    }
end

local function ProcessItemFixups()
    local pending = {}
    for _, fixup in ipairs(pendingItemFixups) do
        local tx = fixup.tx
        local itemID = fixup.itemID
        if tx and itemID and C_Item and C_Item.GetItemInfo then
            local _, itemLink = C_Item.GetItemInfo(itemID)
            if itemLink then
                local cleanLink, _, _, pip = CaptureItemData(itemLink)
                local pipToUse = pip or tx.pip
                if pipToUse and cleanLink and not cleanLink:match("|A:Professions") then
                    cleanLink = cleanLink .. " " .. string_format("|A:%s:12:12:0:-6|a", pipToUse)
                end
                tx.detailLink = cleanLink
                tx.detailName = GetDisplayNameFromLink(cleanLink) or tx.detailName
                tx.itemID = itemID
                tx.pip = pipToUse
            else
                fixup.retries = (fixup.retries or 0) + 1
                if fixup.retries < 8 then
                    if C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID and not C_Item.IsItemDataCachedByID(itemID) then
                        C_Item.RequestLoadItemDataByID(itemID)
                    end
                    pending[#pending + 1] = fixup
                end
            end
        end
    end

    pendingItemFixups = pending
    if #pendingItemFixups > 0 then
        C_Timer.After(0.5, ProcessItemFixups)
    end
end

local function StartFixupProcessing()
    if #pendingItemFixups > 0 and C_Timer then
        C_Timer.After(0.5, ProcessItemFixups)
    end
end

local function GetItemLinkFromName(itemName)
    if type(itemName) ~= "string" or itemName == "" then
        return nil
    end

    local itemID = GetItemID(itemName)
    if itemID and C_Item and C_Item.GetItemInfo then
        local _, itemLink = C_Item.GetItemInfo(itemID)
        if itemLink then
            return StripQualityPip(itemLink)
        end

        if C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID and not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        end
    end

    local name = itemName:match("%[([^%]]+)%]") or itemName
    return string_format("|cffffffff[%s]|r", name)
end

local function GetVendorSellPrice(itemID, itemLink)
    local target = itemLink or itemID
    if not target then
        return nil
    end

    local sellPrice = nil
    if GetItemInfo then
        sellPrice = select(11, GetItemInfo(target))
    end
    if (not sellPrice or sellPrice <= 0) and C_Item and C_Item.GetItemInfo then
        sellPrice = select(11, C_Item.GetItemInfo(target))
    end

    if type(sellPrice) ~= "number" or sellPrice <= 0 then
        return nil
    end

    return sellPrice
end

local function GetMerchantPriceData(index)
    if not (GetMerchantItemInfo and index) then
        return nil, 1, false
    end

    local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(index)
    local merchantStackCount = tonumber(stackCount) or 1
    if merchantStackCount < 1 then
        merchantStackCount = 1
    end

    local copperPrice = tonumber(price)
    if copperPrice and copperPrice < 0 then
        copperPrice = nil
    end

    return copperPrice, merchantStackCount, extendedCost == true
end

local function NormalizeMerchantPurchaseCount(requestedQuantity, merchantStackCount)
    local count = tonumber(requestedQuantity)
    if count and count > 0 then
        return math.max(1, math_floor(count + 0.5))
    end

    local stackCount = tonumber(merchantStackCount)
    if stackCount and stackCount > 0 then
        return math.max(1, math_floor(stackCount + 0.5))
    end

    return 1
end

local function CalculateMerchantExpectedCopper(price, merchantStackCount, purchaseCount, requestedQuantity)
    local copperPrice = tonumber(price)
    local stackCount = tonumber(merchantStackCount) or 1
    local count = tonumber(purchaseCount) or 1
    local requested = tonumber(requestedQuantity)
    local unitCopper = nil
    local expectedCopper = nil

    if not copperPrice or copperPrice <= 0 then
        return nil, nil
    end

    if stackCount <= 1 then
        unitCopper = copperPrice
    elseif (copperPrice % stackCount) == 0 then
        unitCopper = copperPrice / stackCount
    end

    if requested and requested > 0 and stackCount > 0 and (requested % stackCount) == 0 then
        expectedCopper = copperPrice * (requested / stackCount)
    elseif requested == nil then
        expectedCopper = copperPrice
    elseif unitCopper then
        expectedCopper = unitCopper * count
    end

    return unitCopper, expectedCopper
end

local function GetQueueEntryDisplayName(queueEntry)
    if not queueEntry then
        return "Unknown"
    end
    return GetDisplayNameFromLink(queueEntry.item) or queueEntry.item or "Unknown"
end

local function BuildVendorQueueEntrySummary(queueEntry)
    local name = GetQueueEntryDisplayName(queueEntry)
    local count = tonumber(queueEntry and queueEntry.count) or 1
    if count > 1 then
        return string_format("%s x%d", name, count)
    end
    return name
end

local function ConsumeVendorSellQueueForDiff(diff)
    if not diff or diff <= 0 or #vendorSellQueue == 0 then
        return nil
    end

    for index, entry in ipairs(vendorSellQueue) do
        if entry and entry.expectedCopper and entry.expectedCopper == diff then
            return { table_remove(vendorSellQueue, index) }
        end
    end

    local runningTotal = 0
    local prefixCount = 0
    for index, entry in ipairs(vendorSellQueue) do
        local expectedCopper = entry and entry.expectedCopper
        if type(expectedCopper) ~= "number" or expectedCopper <= 0 then
            break
        end

        runningTotal = runningTotal + expectedCopper
        prefixCount = index

        if runningTotal == diff then
            local consumed = {}
            for _ = 1, prefixCount do
                consumed[#consumed + 1] = table_remove(vendorSellQueue, 1)
            end
            return consumed
        elseif runningTotal > diff then
            break
        end
    end

    return nil
end

local function ConsumeMerchantPurchaseQueueForDiff(diff)
    if not diff or diff >= 0 or #merchantPurchaseQueue == 0 then
        return nil
    end

    local target = math_abs(diff)

    for index, entry in ipairs(merchantPurchaseQueue) do
        if entry and entry.expectedCopper and entry.expectedCopper == target then
            return { table_remove(merchantPurchaseQueue, index) }
        end
    end

    local runningTotal = 0
    local prefixCount = 0
    for index, entry in ipairs(merchantPurchaseQueue) do
        local expectedCopper = entry and entry.expectedCopper
        if type(expectedCopper) ~= "number" or expectedCopper <= 0 then
            break
        end

        runningTotal = runningTotal + expectedCopper
        prefixCount = index

        if runningTotal == target then
            local consumed = {}
            for _ = 1, prefixCount do
                consumed[#consumed + 1] = table_remove(merchantPurchaseQueue, 1)
            end
            return consumed
        elseif runningTotal > target then
            break
        end
    end

    return nil
end

local function FindQueueEntryIndex(queue, targetEntry)
    if type(queue) ~= "table" or not targetEntry then
        return nil
    end
    for index, entry in ipairs(queue) do
        if entry == targetEntry then
            return index
        end
    end
    return nil
end

local function ConsumeSpecificQueueEntries(queue, entries)
    if type(queue) ~= "table" or type(entries) ~= "table" then
        return {}
    end

    local consumed = {}
    for _, entry in ipairs(entries) do
        local index = FindQueueEntryIndex(queue, entry)
        if index then
            consumed[#consumed + 1] = table_remove(queue, index)
        end
    end
    return consumed
end

local function PeekVendorSellQueueForDiff(diff)
    if not diff or diff <= 0 or #vendorSellQueue == 0 then
        return nil
    end

    for _, entry in ipairs(vendorSellQueue) do
        if entry and entry.expectedCopper and entry.expectedCopper == diff then
            return { entry }
        end
    end

    local runningTotal = 0
    local entries = {}
    for _, entry in ipairs(vendorSellQueue) do
        local expectedCopper = entry and entry.expectedCopper
        if type(expectedCopper) ~= "number" or expectedCopper <= 0 then
            break
        end

        runningTotal = runningTotal + expectedCopper
        entries[#entries + 1] = entry

        if runningTotal == diff then
            return entries
        elseif runningTotal > diff then
            break
        end
    end

    return nil
end

local function PeekMerchantPurchaseQueueForDiff(diff)
    if not diff or diff >= 0 or #merchantPurchaseQueue == 0 then
        return nil
    end

    local target = math_abs(diff)

    for _, entry in ipairs(merchantPurchaseQueue) do
        if entry and entry.expectedCopper and entry.expectedCopper == target then
            return { entry }
        end
    end

    local runningTotal = 0
    local entries = {}
    for _, entry in ipairs(merchantPurchaseQueue) do
        local expectedCopper = entry and entry.expectedCopper
        if type(expectedCopper) ~= "number" or expectedCopper <= 0 then
            break
        end

        runningTotal = runningTotal + expectedCopper
        entries[#entries + 1] = entry

        if runningTotal == target then
            return entries
        elseif runningTotal > target then
            break
        end
    end

    return nil
end

local function MarkGeneratedSplitTransaction(tx)
    if not tx then
        return
    end

    tx.flags = type(tx.flags) == "table" and tx.flags or {}
    tx.flags.generatedSplit = true
end

local function TransactionSignature(tx)
    local flags = type(tx.flags) == "table" and tx.flags or nil
    return table_concat({
        tostring(tx.charKey or ""),
        tostring(tx.source or ""),
        tostring(tx.amount or 0),
        tostring(tx.itemID or 0),
        tostring(tx.count or 0),
        tostring(tx.detailName or ""),
        tostring(flags and flags.queueToken or ""),
    }, "|")
end

local function HasRecentTransactionLike(tx, windowSeconds)
    local storage = GetStorage()
    local cutoff = (tx.timestamp or time()) - (windowSeconds or 5)
    local signature = TransactionSignature(tx)
    for i = 1, math.min(20, #storage.transactions) do
        local existing = storage.transactions[i]
        if existing and (existing.timestamp or 0) < cutoff then
            break
        end
        if existing and TransactionSignature(existing) == signature then
            return true
        end
    end
    return false
end

local function InsertTransaction(tx)
    if type(tx) ~= "table" then
        return false
    end

    local storage = GetStorage()
    tx.timestamp = tx.timestamp or time()
    tx.source = tx.source or "other"
    tx.sourceLabel = tx.sourceLabel or SOURCE_LABEL_BY_KEY[tx.source] or tx.source
    tx.charKey = tx.charKey or SafeCharKey()
    tx.detailName = tx.detailName or GetDisplayNameFromLink(tx.detailLink) or tx.sourceLabel
    tx.flags = type(tx.flags) == "table" and tx.flags or nil

    if tx.flags and tx.flags.generatedSplit and HasRecentTransactionLike(tx, 3) then
        return false
    end

    table_insert(storage.transactions, 1, tx)
    return true
end

local function BuildTransaction(sourceKey, amount, timestamp)
    local tx = {
        timestamp = timestamp or time(),
        amount = amount,
        source = sourceKey or "other",
        sourceLabel = SOURCE_LABEL_BY_KEY[sourceKey or "other"] or SOURCE_LABEL_BY_KEY.other,
        charKey = cachedPlayerName or SafeCharKey(),
    }
    if sourceKey == "worldQuest" then
        tx.flags = { worldQuest = true }
    end
    return tx
end

local function ApplyQueueItemToTransaction(tx, queueEntry)
    if not (tx and queueEntry) then
        return
    end

    RefreshQueuedItem(queueEntry)
    tx.detailLink = queueEntry.item
    tx.detailName = GetDisplayNameFromLink(queueEntry.item) or queueEntry.item or tx.sourceLabel
    tx.itemID = queueEntry.itemID
    tx.count = queueEntry.count or 1
    tx.pip = queueEntry.pip
    if queueEntry.dedupeToken then
        tx.flags = type(tx.flags) == "table" and tx.flags or {}
        tx.flags.queueToken = queueEntry.dedupeToken
    end
end

local function ApplyVendorSellEntryToTransaction(tx, queueEntry)
    if not (tx and queueEntry) then
        return
    end

    ApplyQueueItemToTransaction(tx, queueEntry)
    tx.detailName = BuildVendorQueueEntrySummary(queueEntry)
    tx.detailText = nil
end

local function RetagRecentTransactionAsWorldQuest(expectedAmount, reason)
    local storage = GetStorage()
    local charKey = cachedPlayerName or SafeCharKey()
    local nowTs = time()

    for i = 1, math.min(10, #storage.transactions) do
        local tx = storage.transactions[i]
        local eligibleSource = tx and (
            tx.source == "loot"
            or (tx.source == "cache" and not IsTransactionBackedByRealCacheEvidence(tx))
        )
        if tx and tx.charKey == charKey and tx.amount and tx.amount > 0 and eligibleSource then
            local age = nowTs - (tx.timestamp or 0)
            local amountMatches = (not expectedAmount) or tx.amount == expectedAmount
            if age >= 0 and age <= 5 and amountMatches then
                tx.source = "worldQuest"
                tx.sourceLabel = SOURCE_LABEL_BY_KEY.worldQuest
                tx.flags = tx.flags or {}
                tx.flags.worldQuest = true
                tx.flags.worldQuestRetagReason = reason or "matched recent provisional world quest reward"
                tx.detailLink = nil
                tx.cacheItemLink = nil
                tx.cacheName = nil
                tx.detailText = nil
                tx.detailName = LText("TEXT_PROFIT_FALLBACK_GOLD_REWARD")
                return
            elseif age > 5 then
                return
            end
        end
    end
end

local function IsWorldQuestQuestID(questID, questInfo)
    if not questID then
        return false
    end
    local isCampaign = C_CampaignInfo and C_CampaignInfo.IsCampaignQuest and C_CampaignInfo.IsCampaignQuest(questID)
    if isCampaign then
        return false
    end

    local classification = questInfo and questInfo.questClassification
    if classification == nil and C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
        classification = C_QuestInfoSystem.GetQuestClassification(questID)
    end

    local worldQuestEnum = Enum and Enum.QuestClassification and Enum.QuestClassification.WorldQuest
    return worldQuestEnum ~= nil and classification == worldQuestEnum or false
end

local function CacheActiveQuestType(questID, isWorldQuest)
    if not questID then
        return
    end

    local confirmed = isWorldQuest and true or false
    activeQuestTypes[questID] = {
        isWorldQuest = confirmed,
        questType = confirmed and "worldQuest" or "quest",
    }

    if confirmed then
        trackedWorldQuests[questID] = true
    else
        trackedWorldQuests[questID] = nil
    end
end

local function GetCachedActiveQuestType(questID)
    return questID and activeQuestTypes[questID] or nil
end

local function ClearCachedActiveQuestType(questID)
    if not questID then
        return
    end
    activeQuestTypes[questID] = nil
    trackedWorldQuests[questID] = nil
end

local function InitCurrentCharacterState()
    local charKey = SafeCharKey()
    cachedPlayerName = charKey
    if not charKey or not GetMoney then
        return
    end

    local storage = GetStorage()
    if type(GetMoney()) == "number" and type(storage.lastKnownMoney[charKey]) ~= "number" then
        storage.lastKnownMoney[charKey] = GetMoney()
    end
end

local function IsWarbandBankActive()
    if lv and lv.atWarbandBank then
        return true
    end
    if AccountBankPanel and AccountBankPanel.IsShown and AccountBankPanel:IsShown() then
        return true
    end
    return false
end

local function RecordAuctionMailFallback()
    if #mailItemQueue == 0 then
        return
    end

    local charKey = cachedPlayerName or SafeCharKey()
    local nowTs = time()
    for _, sale in ipairs(mailItemQueue) do
        if sale.isAH and sale.expectedGold and sale.expectedGold > 0 then
            RefreshQueuedItem(sale)
            local tx = BuildTransaction("auction", sale.expectedGold, nowTs)
            ApplyQueueItemToTransaction(tx, sale)
            if not HasRecentTransactionLike(tx, 60) then
                InsertTransaction(tx)
            end
        end
    end

    for key in pairs(mailItemQueue) do
        mailItemQueue[key] = nil
    end
end

local function CheckInvoice(index)
    if not index then
        return
    end

    local invoiceType, itemName, _, bid, _, _, consignment = GetInboxInvoiceInfo(index)
    if not invoiceType then
        return
    end

    local dedupKey = (itemName or "") .. ":" .. tostring(bid or 0)
    if processedMailIndices[dedupKey] then
        return
    end
    processedMailIndices[dedupKey] = true
    lastAHMailTime = GetTime()

    local bodyText = GetInboxText and GetInboxText(index) or nil
    local itemLink = bodyText and bodyText:match("|c%x+|Hitem:[^|]+|h%[[^%]]+%]|h|r") or nil
    local itemCount = 1
    if bodyText then
        local countMatch = bodyText:match("|h|r%s*x(%d+)")
            or bodyText:match("|h|r%s*%((%d+)%)")
            or bodyText:match("%((%d+)%)")
            or bodyText:match("%s+x(%d+)")
        if countMatch then
            itemCount = tonumber(countMatch) or 1
        end
    end

    if itemCount == 1 and GetInboxHeaderInfo then
        local _, _, _, subject = GetInboxHeaderInfo(index)
        if subject then
            local subjectCount = subject:match("%((%d+)%)")
            if subjectCount then
                itemCount = tonumber(subjectCount) or 1
            end
        end
    end

    itemLink = itemLink or (GetInboxItemLink and GetInboxItemLink(index, 1)) or nil
    local itemID = itemLink and GetItemID(itemLink) or nil
    local cachedPip = nil
    local cachedQuality = nil
    local storage = GetStorage()

    if (not itemID or itemID == 0) and itemName and C_Item and C_Item.GetItemIDForItemInfo then
        local success, result = pcall(C_Item.GetItemIDForItemInfo, itemName)
        if success and result and result > 0 then
            itemID = result
        end
    end

    if itemName and postedAuctionItems[itemName] then
        local cached = postedAuctionItems[itemName]
        if not itemID or itemID == 0 then
            itemID = cached.itemID
        end
        cachedPip = cached.pip
    end

    if itemName and storage.itemCache[itemName] then
        local cached = storage.itemCache[itemName]
        if (not itemID or itemID == 0) and cached.itemID then
            itemID = cached.itemID
        end
        cachedQuality = cached.quality
        if not cachedPip and cached.pip then
            cachedPip = cached.pip
        end
    end

    if itemID and itemID > 0 and not itemLink and C_Item and C_Item.GetItemInfo then
        local _, resolvedLink = C_Item.GetItemInfo(itemID)
        if resolvedLink then
            itemLink = resolvedLink
        elseif C_Item.IsItemDataCachedByID and C_Item.RequestLoadItemDataByID and not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        end
    end

    if not itemLink and itemName and cachedQuality then
        local color = QUALITY_COLORS[cachedQuality] or "ffffff"
        itemLink = string_format("|cff%s[%s]|r", color, itemName)
    end

    if not itemLink and itemName then
        itemLink = GetItemLinkFromName(itemName)
    end

    local finalItem, finalItemID, _, pip = CaptureItemData(itemLink or itemName)
    if (not finalItemID or finalItemID == 0) and itemID and itemID > 0 then
        finalItemID = itemID
    end
    local pipToUse = pip or cachedPip
    if pipToUse and finalItem and not finalItem:match("|A:Professions") then
        finalItem = finalItem .. " " .. string_format("|A:%s:12:12:0:-6|a", pipToUse)
    end

    if itemName then
        local cacheEntry = storage.itemCache[itemName] or {}
        local shouldSave = false
        if finalItemID and finalItemID > 0 and not cacheEntry.itemID then
            cacheEntry.itemID = finalItemID
            shouldSave = true
        end
        local quality = finalItemID and C_Item and C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(finalItemID) or nil
        if quality and quality > 0 and not cacheEntry.quality then
            cacheEntry.quality = quality
            shouldSave = true
        end
        if pipToUse and not cacheEntry.pip then
            cacheEntry.pip = pipToUse
            shouldSave = true
        end
        if shouldSave then
            storage.itemCache[itemName] = cacheEntry
        end
    end

    local expectedGold = nil
    if invoiceType == "seller" and bid and consignment then
        expectedGold = bid - consignment
    end

    table_insert(mailItemQueue, {
        item = finalItem,
        itemID = finalItemID,
        count = itemCount,
        isAH = true,
        pip = pipToUse,
        expectedGold = expectedGold,
    })
end

local function InstallHooks()
    if not hooksecurefunc then
        return
    end

    hooksecurefunc("TakeInboxMoney", function(index)
        CheckInvoice(index)
    end)

    hooksecurefunc("AutoLootMailItem", function(index)
        CheckInvoice(index)
    end)

    if TakeInboxItem then
        hooksecurefunc("TakeInboxItem", function(mailIndex, attachIndex)
            if not mailIndex then
                return
            end
            if GetInboxInvoiceInfo and GetInboxInvoiceInfo(mailIndex) then
                return
            end

            local itemLink = GetInboxItemLink and GetInboxItemLink(mailIndex, attachIndex or 1)
            if itemLink then
                local _, _, _, _, itemCount = GetInboxItem(mailIndex, attachIndex or 1)
                local item, itemID, _, pip = CaptureItemData(itemLink)
                table_insert(mailItemQueue, {
                    item = item,
                    itemID = itemID,
                    count = itemCount or 1,
                    isAH = false,
                    pip = pip,
                })
            end
        end)
    end

    if C_Container and C_Container.UseContainerItem then
        hooksecurefunc(C_Container, "UseContainerItem", function(bagID, slotIndex)
            if MerchantFrame and MerchantFrame.IsShown and MerchantFrame:IsShown() then
                local info = C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bagID, slotIndex)
                if info then
                    local item, itemID, _, pip = CaptureItemData(info.hyperlink or info.itemName)
                    local count = info.stackCount or 1
                    local expectedCopper = nil
                    local sellPrice = GetVendorSellPrice(itemID, item or info.hyperlink or info.itemName)
                    if sellPrice and sellPrice > 0 then
                        expectedCopper = sellPrice * count
                    end
                    table_insert(vendorSellQueue, {
                        item = item,
                        itemID = itemID,
                        count = count,
                        pip = pip,
                        expectedCopper = expectedCopper,
                        queuedAt = time(),
                    })
                end
            end
        end)
    end

    if BuyMerchantItem then
        hooksecurefunc("BuyMerchantItem", function(index, quantity)
            local link = GetMerchantItemLink and GetMerchantItemLink(index)
            local name = GetMerchantItemInfo and GetMerchantItemInfo(index)
            local item, itemID, _, pip = CaptureItemData(link or name)
            local price, merchantStackCount = GetMerchantPriceData(index)
            local purchaseCount = NormalizeMerchantPurchaseCount(quantity, merchantStackCount)
            local unitCopper, expectedCopper = CalculateMerchantExpectedCopper(price, merchantStackCount, purchaseCount, quantity)

            table_insert(merchantPurchaseQueue, {
                item = item or link or name,
                itemID = itemID,
                count = purchaseCount,
                requestedQuantity = tonumber(quantity),
                merchantStackCount = merchantStackCount,
                unitCopper = unitCopper,
                expectedCopper = expectedCopper,
                pip = pip,
                dedupeToken = AllocateQueueToken(),
            })
        end)
    end

    if RepairAllItems then
        hooksecurefunc("RepairAllItems", function(guildBankRepair)
            if guildBankRepair then
                lastGuildRepairTime = GetTime()
            else
                lastRepairTime = GetTime()
            end
        end)
    end

    if TakeTaxiNode then
        hooksecurefunc("TakeTaxiNode", function()
            lastFlightTime = GetTime()
        end)
    end

    if C_AuctionHouse then
        if C_AuctionHouse.PlaceAuctionBid then
            hooksecurefunc(C_AuctionHouse, "PlaceAuctionBid", function(auctionID)
                local info = C_AuctionHouse.GetAuctionInfoByID and C_AuctionHouse.GetAuctionInfoByID(auctionID)
                if info and info.itemKey then
                    local itemLink, itemID, _, pip = CaptureItemData(info.itemLink or info.itemKey.itemID)
                    if pip and itemLink and not itemLink:match("|A:Professions") then
                        itemLink = itemLink .. " " .. string_format("|A:%s:12:12:0:-6|a", pip)
                    end
                    table_insert(ahPurchaseQueue, {
                        item = itemLink,
                        itemID = itemID,
                        count = info.quantity or 1,
                        pip = pip,
                    })
                end
            end)
        end

        if C_AuctionHouse.ConfirmCommoditiesPurchase then
            hooksecurefunc(C_AuctionHouse, "ConfirmCommoditiesPurchase", function(itemID, quantity)
                local itemLink, storedID, _, pip = CaptureItemData(itemID)
                if C_Item and C_Item.GetItemInfo then
                    local _, link = C_Item.GetItemInfo(itemID)
                    if link then
                        local linkPip = link:match("|A:(Professions%-ChatIcon%-Quality%-[%d%-]*Tier%d)")
                        if linkPip then
                            pip = linkPip
                            itemLink = StripQualityPip(link)
                        end
                    end
                end
                if pip and itemLink and not itemLink:match("|A:Professions") then
                    itemLink = itemLink .. " " .. string_format("|A:%s:12:12:0:-6|a", pip)
                end
                table_insert(ahPurchaseQueue, {
                    item = itemLink,
                    itemID = storedID,
                    count = quantity or 1,
                    pip = pip,
                })
            end)
        end

        if C_AuctionHouse.PostCommodity then
            hooksecurefunc(C_AuctionHouse, "PostCommodity", function(itemLocation)
                if not itemLocation then
                    return
                end
                local itemID = C_Item and C_Item.GetItemID and C_Item.GetItemID(itemLocation)
                local itemLink = C_Item and C_Item.GetItemLink and C_Item.GetItemLink(itemLocation)
                if itemID and C_Item and C_Item.GetItemNameByID then
                    local itemName = C_Item.GetItemNameByID(itemID)
                    if itemName then
                        local pipAtlas = itemLink and itemLink:match("|A:(Professions%-ChatIcon%-Quality%-[%d%-]*Tier%d)")
                        postedAuctionItems[itemName] = { itemID = itemID, pip = pipAtlas }
                        local storage = GetStorage()
                        storage.itemCache[itemName] = {
                            itemID = itemID,
                            quality = C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(itemID) or nil,
                            pip = pipAtlas,
                        }
                    end
                end
            end)
        end

        if C_AuctionHouse.PostItem then
            hooksecurefunc(C_AuctionHouse, "PostItem", function(itemLocation)
                if not itemLocation then
                    return
                end
                local itemID = C_Item and C_Item.GetItemID and C_Item.GetItemID(itemLocation)
                local itemLink = C_Item and C_Item.GetItemLink and C_Item.GetItemLink(itemLocation)
                if itemID and C_Item and C_Item.GetItemNameByID then
                    local itemName = C_Item.GetItemNameByID(itemID)
                    if itemName then
                        local pipAtlas = itemLink and itemLink:match("|A:(Professions%-ChatIcon%-Quality%-[%d%-]*Tier%d)")
                        postedAuctionItems[itemName] = { itemID = itemID, pip = pipAtlas }
                        local storage = GetStorage()
                        storage.itemCache[itemName] = {
                            itemID = itemID,
                            quality = C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(itemID) or nil,
                            pip = pipAtlas,
                        }
                    end
                end
            end)
        end
    end

    if C_CraftingOrders and C_CraftingOrders.PlaceNewOrder then
        hooksecurefunc(C_CraftingOrders, "PlaceNewOrder", function()
            local frame = ProfessionsCustomerOrdersFrame
            if frame and frame.Form then
                local form = frame.Form
                local qualityTier = form.order and form.order.minQuality or 1
                if form.transaction then
                    local schematic = form.transaction.GetRecipeSchematic and form.transaction:GetRecipeSchematic()
                    if schematic and schematic.outputItemID then
                        local itemLink, itemID = CaptureItemData(schematic.outputItemID)
                        local qualityIcon = string_format("|A:Professions-ChatIcon-Quality-Tier%d:12:12:0:-6|a", qualityTier)
                        lastCraftingOrderItem = (itemLink or string.format("[%s]", LText("LABEL_UNKNOWN"))) .. " " .. qualityIcon
                        lastCraftingOrderItemID = itemID
                        lastCraftingOrderCount = 1
                    end
                end
            end
        end)
    end

    if C_CraftingOrders and C_CraftingOrders.FulfillOrder then
        hooksecurefunc(C_CraftingOrders, "FulfillOrder", function()
            local order = C_CraftingOrders.GetClaimedOrder and C_CraftingOrders.GetClaimedOrder()
            if order then
                local qualityTier = order.minQuality or 1
                local itemLink, itemID = CaptureItemData(order.outputItemHyperlink or order.itemID)
                if itemLink then
                    local qualityIcon = string_format("|A:Professions-ChatIcon-Quality-Tier%d:12:12:0:-6|a", qualityTier)
                    lastFulfilledOrderItem = itemLink .. " " .. qualityIcon
                    lastFulfilledOrderItemID = itemID
                    lastFulfilledOrderCount = 1
                end
            end
        end)
    end

    if C_ItemUpgrade and C_ItemUpgrade.UpgradeItem then
        hooksecurefunc(C_ItemUpgrade, "UpgradeItem", function()
            QueueUpgradeSnapshot()
        end)
    end
end

local function BuildSourceClaim(sourceKey, reason, evidenceClass, claimType, payload)
    return {
        source = sourceKey or "other",
        reason = reason or "",
        evidenceClass = evidenceClass or 5,
        claimType = claimType or "unknown",
        payload = payload,
    }
end

local function BuildSourceAttributionDebug(nowTime, diff, claim, lootActive)
    return {
        diff = diff,
        pendingQuestSource = DescribeQuestSourceState(nowTime, GetPendingReward("quest", nowTime)),
        pendingWorldQuestSource = DescribeWorldQuestSourceState(nowTime, GetPendingReward("worldQuest", nowTime)),
        activeCacheSource = DescribeActiveCacheSource(4, 20),
        activeLootSource = lootActive and "LootFrame visible" or "none",
        sourceWon = claim and claim.source or "other",
        reason = claim and claim.reason or "none",
        evidenceClass = claim and claim.evidenceClass or nil,
        claimType = claim and claim.claimType or nil,
    }
end

local function BuildExactPendingRewardClaim(nowTime, diff)
    if type(diff) ~= "number" or diff <= 0 then
        return nil
    end

    local candidates = {}

    local pendingWorldQuest = GetPendingReward("worldQuest", nowTime)
    if pendingWorldQuest
        and pendingWorldQuest.questID == lastTurnedInQuestID
        and pendingWorldQuest.amount
        and pendingWorldQuest.amount == diff then
        candidates[#candidates + 1] = pendingWorldQuest
    end

    local pendingQuest = GetPendingReward("quest", nowTime)
    if pendingQuest
        and pendingQuest.questID == lastTurnedInQuestID
        and pendingQuest.amount
        and pendingQuest.amount == diff then
        candidates[#candidates + 1] = pendingQuest
    end

    if #candidates == 0 then
        return nil
    end

    table_sort(candidates, function(a, b)
        return (tonumber(a and a.createdAt) or 0) > (tonumber(b and b.createdAt) or 0)
    end)

    local reward = candidates[1]
    local sourceKey = reward.source or "quest"
    if sourceKey == "weeklyCache" then
        sourceKey = "quest"
    end
    local claimType = "pendingQuestExact"
    if sourceKey == "worldQuest" then
        claimType = "pendingWorldQuestExact"
    end

    return BuildSourceClaim(sourceKey, "pending reward exactly matched gold delta", 1, claimType, reward)
end

local function BuildAuctionPurchaseClaim(diff)
    if type(diff) ~= "number" or diff >= 0 or #ahPurchaseQueue ~= 1 then
        return nil
    end

    return BuildSourceClaim("auction", "single queued auction purchase was unambiguous", 1, "auctionPurchaseQueued", ahPurchaseQueue[1])
end

local function BuildAuctionMailClaim(diff)
    if type(diff) ~= "number" or diff <= 0 or #mailItemQueue == 0 then
        return nil
    end

    local bestIdx = nil
    local bestMatchDiff = diff * 0.05
    for index, sale in ipairs(mailItemQueue) do
        if sale and sale.isAH then
            local itemDiff = math_abs((sale.expectedGold or 0) - diff)
            if itemDiff < bestMatchDiff then
                bestMatchDiff = itemDiff
                bestIdx = index
            end
        end
    end

    if bestIdx then
        return BuildSourceClaim("auction", "auction mail sale matched expected invoice amount", 1, "auctionMailExact", {
            entries = { mailItemQueue[bestIdx] },
            mode = "single",
        })
    end

    local remainingDiff = diff
    local consumedItems = {}
    for _, sale in ipairs(mailItemQueue) do
        local expected = sale and sale.expectedGold or 0
        if sale and sale.isAH and expected > 0 and expected <= remainingDiff * 1.1 then
            consumedItems[#consumedItems + 1] = sale
            remainingDiff = remainingDiff - expected
        end
    end

    if #consumedItems > 0 then
        return BuildSourceClaim("auction", "auction mail sale matched existing batched invoice rules", 1, "auctionMailBatch", {
            entries = consumedItems,
            mode = "batch",
        })
    end

    return nil
end

local function GetWowTokenPriceCopper()
    local info = lv.GetWowTokenInfo and lv.GetWowTokenInfo() or nil
    local price = tonumber(info and info.price)
    if price and price > 0 then
        return price
    end

    local tokenDB = LiteVaultDB and LiteVaultDB.wowToken
    price = tonumber(tokenDB and tokenDB.tokenPrice)
    if price and price > 0 then
        return price
    end

    return nil
end

local function IsLikelyWowTokenPurchase(diff)
    diff = tonumber(diff)
    if not diff or diff >= 0 then
        return false
    end

    local tokenPrice = GetWowTokenPriceCopper()
    if not tokenPrice or tokenPrice <= 0 then
        return false
    end

    local spent = math_abs(diff)
    local tolerance = math.max(10000, math_floor(tokenPrice * 0.005))

    return math_abs(spent - tokenPrice) <= tolerance, tokenPrice
end

local function ConsumeQuestSourceState(sourceKey)
    lastQuestTime = 0
    lastQuestWasWorldQuest = false
    lastQuestWasWeekly = false
    lastTurnedInQuestID = nil
    pendingWorldQuestGold = false
    pendingWorldQuestTime = 0

    if sourceKey == "worldQuest" then
        ConsumeConfirmedWorldQuestGold()
        ClearPendingReward("worldQuest")
    else
        ClearPendingReward("quest")
    end
end

local function ConsumeClaimSideEffects(claim)
    if type(claim) ~= "table" then
        return
    end

    local claimType = claim.claimType
    local sourceKey = claim.source

    if claimType == "repairPersonal" then
        lastRepairTime = 0
    elseif claimType == "repairGuild" then
        lastGuildRepairTime = 0
    elseif claimType == "tradeRecent" or claimType == "tradeContext" then
        lastTradeTime = 0
    elseif claimType == "flightRecent" or claimType == "flightContext" then
        lastFlightTime = 0
    elseif claimType == "confirmedWorldQuest"
        or claimType == "pendingWorldQuestExact"
        or claimType == "pendingQuestExact"
        or claimType == "questWindow"
        or claimType == "recentQuestFallback"
        or claimType == "recentWorldQuestFallback" then
        ConsumeQuestSourceState(sourceKey)
    end
end

local function DetermineSource(nowTime, diff)
    local isAHOpen = (C_AuctionHouse and C_AuctionHouse.IsAuctionHouseOpen and C_AuctionHouse.IsAuctionHouseOpen())
    local positiveGold = diff > 0
    local negativeGold = diff < 0
    local lootActive = positiveGold and IsLootSourceActive() or false
    local questSourceActive = positiveGold and IsQuestSourceActive() or false

    local claim = BuildExactPendingRewardClaim(nowTime, diff)
    if not claim and positiveGold then
        local vendorEntries = PeekVendorSellQueueForDiff(diff)
        if vendorEntries and #vendorEntries > 0 then
            claim = BuildSourceClaim("vendor", "vendor sell queue exactly matched gold delta", 1, "vendorSellMatched", vendorEntries)
        end
    end
    if not claim and negativeGold then
        local merchantEntries = PeekMerchantPurchaseQueueForDiff(diff)
        if merchantEntries and #merchantEntries > 0 then
            claim = BuildSourceClaim("vendor", "merchant purchase queue exactly matched gold delta", 1, "merchantPurchaseMatched", merchantEntries)
        end
    end
    if not claim and negativeGold then
        local upgradeSnapshots, splitMode = PeekUpgradeSnapshotsForDiff(diff, 20)
        if upgradeSnapshots and #upgradeSnapshots > 0 then
            claim = BuildSourceClaim("upgrade", "upgrade snapshots matched negative gold", 1, "upgradeMatched", {
                snapshots = upgradeSnapshots,
                splitMode = splitMode,
            })
        end
    end
    if not claim and negativeGold then
        claim = BuildAuctionPurchaseClaim(diff)
    end
    if not claim and positiveGold then
        claim = BuildAuctionMailClaim(diff)
    end

    if not claim and questSourceActive then
        claim = BuildSourceClaim("quest", "quest or gossip frame open", 2, "questWindow")
    end
    if not claim and positiveGold and confirmedWorldQuestGold and (nowTime - confirmedWorldQuestTime < 2.0) then
        claim = BuildSourceClaim("worldQuest", "confirmed world quest reward won", 2, "confirmedWorldQuest")
    end

    -- Intentional LiteVault correction to a WGT 12.0.7.0003 edge case:
    -- when a quest grants a named cache that is opened moments later, the
    -- opened-container evidence should beat only the generic recent-quest
    -- fallback, while still leaving direct quest/world-quest authority intact.
    if not claim and positiveGold then
        local openedSnapshot = FindPendingCacheSnapshot(20, IsOpenedNamedCacheSnapshot)
        if openedSnapshot then
            claim = BuildSourceClaim("cache", "opened named cache evidence won before recent quest fallback", 2, "openedNamedCache", openedSnapshot)
        end
    end

    if not claim and negativeGold and (nowTime - lastRepairTime < 1.0) and MerchantFrame and MerchantFrame.IsShown and MerchantFrame:IsShown() then
        claim = BuildSourceClaim("repair", "merchant repair activity won", 2, "repairPersonal")
    end
    if not claim and negativeGold and (nowTime - lastGuildRepairTime < 0.3) and MerchantFrame and MerchantFrame.IsShown and MerchantFrame:IsShown() then
        claim = BuildSourceClaim("repair", "merchant guild repair remainder won", 2, "repairGuild")
    end
    if not claim and ((TradeFrame and TradeFrame.IsShown and TradeFrame:IsShown()) or (nowTime - lastTradeTime < 1.0)) then
        claim = BuildSourceClaim("trade", "trade window activity won", 2, (TradeFrame and TradeFrame.IsShown and TradeFrame:IsShown()) and "tradeContext" or "tradeRecent")
    end
    if not claim and ((FlightMapFrame and FlightMapFrame.IsShown and FlightMapFrame:IsShown()) or (TaxiFrame and TaxiFrame.IsShown and TaxiFrame:IsShown()) or (UnitOnTaxi and UnitOnTaxi("player")) or (nowTime - lastFlightTime < 2.0)) then
        claim = BuildSourceClaim("flightpath", "flight path context active", 2, ((nowTime - lastFlightTime < 2.0) and "flightRecent" or "flightContext"))
    end
    if not claim and negativeGold and inItemUpgrade then
        claim = BuildSourceClaim("upgrade", "item upgrade interaction active", 2, "upgradeInteraction")
    end
    if not claim and negativeGold then
        local matchedToken, tokenPrice = IsLikelyWowTokenPurchase(diff)
        if matchedToken then
            claim = BuildSourceClaim("wowToken", "negative gold matched last known WoW Token price", 1, "wowTokenPriceMatch", {
                price = tokenPrice,
            })
        end
    end

    if not claim and (isAHOpen or (AuctionHouseFrame and AuctionHouseFrame.IsShown and AuctionHouseFrame:IsShown()) or (AuctionFrame and AuctionFrame.IsShown and AuctionFrame:IsShown())) then
        if diff < 0 and #ahPurchaseQueue == 0 then
            claim = BuildSourceClaim("ahFee", "auction house open with negative gold and no purchase queue", 3, "auctionFeeContext")
        else
            claim = BuildSourceClaim("auction", "auction house open", 3, "auctionContext")
        end
    end
    if not claim and MerchantFrame and MerchantFrame.IsShown and MerchantFrame:IsShown() then
        claim = BuildSourceClaim("vendor", "merchant window open", 3, "merchantContext")
    end
    if not claim and MailFrame and MailFrame.IsShown and MailFrame:IsShown() then
        if (nowTime - lastAHMailTime < 30.0) then
            claim = BuildSourceClaim("auction", "recent auction mail activity won", 3, "auctionMailContext")
        elseif diff > 0 and #mailItemQueue > 0 and mailItemQueue[1].isAH then
            claim = BuildSourceClaim("auction", "mail queue marked as auction proceeds", 3, "auctionMailContext")
        elseif diff > 0 then
            local foundInvoice = false
            if GetInboxNumItems and GetInboxInvoiceInfo then
                for i = 1, GetInboxNumItems() do
                    if GetInboxInvoiceInfo(i) then
                        foundInvoice = true
                        break
                    end
                end
            end
            claim = BuildSourceClaim(foundInvoice and "auction" or "mail", foundInvoice and "mail invoice matched auction proceeds" or "mail window open", 3, foundInvoice and "auctionMailContext" or "mailContext")
        else
            claim = BuildSourceClaim("mail", "mail window open", 3, "mailContext")
        end
    end
    if not claim and (ProfessionsCustomerOrdersFrame and ProfessionsCustomerOrdersFrame.IsShown and ProfessionsCustomerOrdersFrame:IsShown()) then
        claim = BuildSourceClaim("crafting", "customer order frame open", 3, "craftingContext")
    end
    if not claim and (ProfessionsFrame and ProfessionsFrame.IsShown and ProfessionsFrame:IsShown() and ProfessionsFrame.OrdersPage and ProfessionsFrame.OrdersPage.IsShown and ProfessionsFrame.OrdersPage:IsShown()) then
        claim = BuildSourceClaim("crafting", "professions orders page open", 3, "craftingContext")
    end
    if not claim and diff < 0 and ((ProfessionsFrame and ProfessionsFrame.IsShown and ProfessionsFrame:IsShown()) or (ClassTrainerFrame and ClassTrainerFrame.IsShown and ClassTrainerFrame:IsShown())) then
        claim = BuildSourceClaim("training", "training/professions purchase context active", 3, "trainingContext")
    end
    if not claim and ((WardrobeFrame and WardrobeFrame.IsShown and WardrobeFrame:IsShown()) or (C_Transmog and C_Transmog.IsAtTransmogNPC and C_Transmog.IsAtTransmogNPC())) then
        claim = BuildSourceClaim("transmog", "transmog context active", 3, "transmogContext")
    end
    if not claim and (BlackMarketFrame and BlackMarketFrame.IsShown and BlackMarketFrame:IsShown()) then
        claim = BuildSourceClaim("blackMarket", "black market frame open", 3, "blackMarketContext")
    end
    if not claim and (GuildBankFrame and GuildBankFrame.IsShown and GuildBankFrame:IsShown()) then
        claim = BuildSourceClaim("guildBank", "guild bank frame open", 3, "guildBankContext")
    end
    if not claim and positiveGold and (nowTime - lastQuestTime < 5.0) and not lootActive then
        if lastQuestWasWorldQuest then
            claim = BuildSourceClaim("worldQuest", "recent world quest fallback won", 4, "recentWorldQuestFallback")
        else
            claim = BuildSourceClaim("quest", "recent quest fallback won", 4, "recentQuestFallback")
        end
    end

    if not claim and positiveGold then
        local namedCacheSnapshot = FindPendingCacheSnapshot(20, IsRealNamedCacheSnapshot)
        if namedCacheSnapshot then
            claim = BuildSourceClaim("cache", "real named cache evidence won after WGT sources", 4, "namedCacheBagChange", namedCacheSnapshot)
        end
    end

    claim = claim or BuildSourceClaim("loot", "default loot fallback", 5, "lootFallback")
    return claim, BuildSourceAttributionDebug(nowTime, diff, claim, lootActive)
end

local function AttachTransactionDetail(tx, sourceKey, diff, claim)
    local claimType = claim and claim.claimType or nil
    local claimPayload = claim and claim.payload or nil

    if sourceKey == "wowToken" then
        tx.detailName = LText("TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE", "WoW Token Purchase")
        tx.flags = tx.flags or {}
        tx.flags.wowToken = true

        if claimPayload and claimPayload.price then
            tx.tokenPrice = claimPayload.price
        end
    elseif sourceKey == "auction" then
        if claimType == "auctionPurchaseQueued" and claimPayload then
            ConsumeSpecificQueueEntries(ahPurchaseQueue, { claimPayload })
            ApplyQueueItemToTransaction(tx, claimPayload)
        elseif (claimType == "auctionMailExact" or claimType == "auctionMailBatch")
            and type(claimPayload) == "table"
            and type(claimPayload.entries) == "table" then
            local consumedItems = ConsumeSpecificQueueEntries(mailItemQueue, claimPayload.entries)
            if #consumedItems > 0 then
                local first = consumedItems[1]
                ApplyQueueItemToTransaction(tx, first)
                local extraTotal = 0
                for index = 2, #consumedItems do
                    local sale = consumedItems[index]
                    local extraAmount = sale.expectedGold or 0
                    extraTotal = extraTotal + extraAmount
                    if extraAmount ~= 0 then
                        local extraTx = BuildTransaction("auction", extraAmount, tx.timestamp)
                        ApplyQueueItemToTransaction(extraTx, sale)
                        MarkGeneratedSplitTransaction(extraTx)
                        InsertTransaction(extraTx)
                    end
                end
                tx.amount = diff - extraTotal
            end
        elseif #ahPurchaseQueue > 0 and diff < 0 then
            ApplyQueueItemToTransaction(tx, table_remove(ahPurchaseQueue, 1))
        elseif #mailItemQueue > 0 and diff > 0 then
            local matchedClaim = BuildAuctionMailClaim(diff)
            if matchedClaim and matchedClaim.payload and matchedClaim.payload.entries then
                local consumedItems = ConsumeSpecificQueueEntries(mailItemQueue, matchedClaim.payload.entries)
                if #consumedItems > 0 then
                    local first = consumedItems[1]
                    ApplyQueueItemToTransaction(tx, first)
                    local extraTotal = 0
                    for index = 2, #consumedItems do
                        local sale = consumedItems[index]
                        local extraAmount = sale.expectedGold or 0
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("auction", extraAmount, tx.timestamp)
                            ApplyQueueItemToTransaction(extraTx, sale)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                    tx.amount = diff - extraTotal
                end
            end
        end
    elseif sourceKey == "mail" then
        if #mailItemQueue > 0 then
            ApplyQueueItemToTransaction(tx, table_remove(mailItemQueue, 1))
        end
    elseif sourceKey == "vendor" then
        if claimType == "vendorSellMatched" and type(claimPayload) == "table" then
            local matchedSales = ConsumeSpecificQueueEntries(vendorSellQueue, claimPayload)
            if #matchedSales > 0 then
                local firstSale = matchedSales[1]
                ApplyVendorSellEntryToTransaction(tx, firstSale)
                local extraTotal = 0
                for index = 2, #matchedSales do
                    local sale = matchedSales[index]
                    local extraAmount = sale.expectedCopper or 0
                    extraTotal = extraTotal + extraAmount
                    if extraAmount ~= 0 then
                        local extraTx = BuildTransaction("vendor", extraAmount, tx.timestamp)
                        ApplyVendorSellEntryToTransaction(extraTx, sale)
                        MarkGeneratedSplitTransaction(extraTx)
                        InsertTransaction(extraTx)
                    end
                end
                tx.amount = diff - extraTotal
            end
        elseif claimType == "merchantPurchaseMatched" and type(claimPayload) == "table" then
            local matchedPurchases = ConsumeSpecificQueueEntries(merchantPurchaseQueue, claimPayload)
            if #matchedPurchases > 0 then
                local firstPurchase = matchedPurchases[1]
                ApplyQueueItemToTransaction(tx, firstPurchase)
                local extraTotal = 0
                for index = 2, #matchedPurchases do
                    local purchase = matchedPurchases[index]
                    local extraAmount = purchase.expectedCopper and -purchase.expectedCopper or 0
                    extraTotal = extraTotal + extraAmount
                    if extraAmount ~= 0 then
                        local extraTx = BuildTransaction("vendor", extraAmount, tx.timestamp)
                        ApplyQueueItemToTransaction(extraTx, purchase)
                        MarkGeneratedSplitTransaction(extraTx)
                        InsertTransaction(extraTx)
                    end
                end
                tx.amount = diff - extraTotal
            end
        elseif #vendorSellQueue > 0 and diff > 0 then
            local matchedSales = ConsumeVendorSellQueueForDiff(diff)
            if matchedSales and #matchedSales > 0 then
                local firstSale = matchedSales[1]
                ApplyVendorSellEntryToTransaction(tx, firstSale)
                local extraTotal = 0
                if #matchedSales > 1 then
                    for index = 2, #matchedSales do
                        local sale = matchedSales[index]
                        local extraAmount = sale.expectedCopper or 0
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("vendor", extraAmount, tx.timestamp)
                            ApplyVendorSellEntryToTransaction(extraTx, sale)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                end
                tx.amount = diff - extraTotal
            else
                ApplyVendorSellEntryToTransaction(tx, table_remove(vendorSellQueue, 1))
            end
        elseif #merchantPurchaseQueue > 0 and diff < 0 then
            local matchedPurchases = ConsumeMerchantPurchaseQueueForDiff(diff)
            if matchedPurchases and #matchedPurchases > 0 then
                local firstPurchase = matchedPurchases[1]
                ApplyQueueItemToTransaction(tx, firstPurchase)
                local extraTotal = 0
                if #matchedPurchases > 1 then
                    for index = 2, #matchedPurchases do
                        local purchase = matchedPurchases[index]
                        local extraAmount = purchase.expectedCopper and -purchase.expectedCopper or 0
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("vendor", extraAmount, tx.timestamp)
                            ApplyQueueItemToTransaction(extraTx, purchase)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                end
                tx.amount = diff - extraTotal
            else
                ApplyQueueItemToTransaction(tx, table_remove(merchantPurchaseQueue, 1))
            end
        end
    elseif sourceKey == "cache" then
        if claimPayload then
            AttachCacheSnapshotToTransaction(tx, 20, function(snapshot)
                return snapshot == claimPayload
            end)
        elseif HasOpenedNamedCacheSnapshotEvidence(20) then
            AttachCacheSnapshotToTransaction(tx, 20, IsOpenedNamedCacheSnapshot)
        else
            AttachCacheSnapshotToTransaction(tx, 20, IsRealNamedCacheSnapshot)
        end
    elseif sourceKey == "weeklyCache" then
        if HasRealCacheSnapshotEvidence(20) then
            AttachCacheSnapshotToTransaction(tx, 20, IsRealNamedCacheSnapshot)
        end
    elseif sourceKey == "upgrade" then
        if claimType == "upgradeMatched" and type(claimPayload) == "table" and type(claimPayload.snapshots) == "table" then
            local matchedSnapshots = ConsumeSpecificQueueEntries(pendingUpgradeSnapshots, claimPayload.snapshots)
            local splitMode = claimPayload.splitMode
            if #matchedSnapshots > 0 then
                if splitMode == "expected" and #matchedSnapshots > 1 then
                    local extraTotal = 0
                    for index = 2, #matchedSnapshots do
                        local snapshot = matchedSnapshots[index]
                        local extraAmount = -(tonumber(snapshot and snapshot.expectedCopper) or 0)
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("upgrade", extraAmount, tx.timestamp)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                    tx.amount = diff - extraTotal
                elseif splitMode == "evenSplit" and #matchedSnapshots > 1 then
                    local splitAmount = math_floor(math_abs(diff) / #matchedSnapshots)
                    local extraTotal = 0
                    for index = 2, #matchedSnapshots do
                        local extraAmount = -splitAmount
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("upgrade", extraAmount, tx.timestamp)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                    tx.amount = diff - extraTotal
                end
            end
        else
            local matchedSnapshots, splitMode = ConsumeUpgradeSnapshotsForDiff(diff, 20)
            if matchedSnapshots and #matchedSnapshots > 0 then
                if splitMode == "expected" and #matchedSnapshots > 1 then
                    local extraTotal = 0
                    for index = 2, #matchedSnapshots do
                        local snapshot = matchedSnapshots[index]
                        local extraAmount = -(tonumber(snapshot and snapshot.expectedCopper) or 0)
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("upgrade", extraAmount, tx.timestamp)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                    tx.amount = diff - extraTotal
                elseif splitMode == "evenSplit" and #matchedSnapshots > 1 then
                    local splitAmount = math_floor(math_abs(diff) / #matchedSnapshots)
                    local extraTotal = 0
                    for index = 2, #matchedSnapshots do
                        local extraAmount = -splitAmount
                        extraTotal = extraTotal + extraAmount
                        if extraAmount ~= 0 then
                            local extraTx = BuildTransaction("upgrade", extraAmount, tx.timestamp)
                            MarkGeneratedSplitTransaction(extraTx)
                            InsertTransaction(extraTx)
                        end
                    end
                    tx.amount = diff - extraTotal
                end
            else
                AttachUpgradeSnapshotToTransaction(tx, 20)
            end
        end
    elseif sourceKey == "crafting" then
        if lastCraftingOrderItem and diff < 0 then
            tx.detailLink = lastCraftingOrderItem
            tx.detailName = GetDisplayNameFromLink(lastCraftingOrderItem) or LText("TEXT_PROFIT_SOURCE_CRAFT")
            tx.itemID = lastCraftingOrderItemID
            tx.count = lastCraftingOrderCount or 1
            lastCraftingOrderItem = nil
            lastCraftingOrderItemID = nil
            lastCraftingOrderCount = nil
        elseif lastFulfilledOrderItem and diff > 0 then
            tx.detailLink = lastFulfilledOrderItem
            tx.detailName = GetDisplayNameFromLink(lastFulfilledOrderItem) or LText("TEXT_PROFIT_SOURCE_CRAFT")
            tx.itemID = lastFulfilledOrderItemID
            tx.count = lastFulfilledOrderCount or 1
            lastFulfilledOrderItem = nil
            lastFulfilledOrderItemID = nil
            lastFulfilledOrderCount = nil
        end
    end

    ConsumeClaimSideEffects(claim)
    tx.detailName = tx.detailName or tx.sourceLabel
end

local function ScanExistingWorldQuests()
    for questID in pairs(trackedWorldQuests) do
        trackedWorldQuests[questID] = nil
    end
    for questID in pairs(activeQuestTypes) do
        activeQuestTypes[questID] = nil
    end

    if not (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo) then
        return
    end

    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(i)
        if info and info.questID and not info.isHeader then
            CacheActiveQuestType(info.questID, IsWorldQuestQuestID(info.questID, info))
        end
    end
end

local function GetPeriodStart(period)
    if period == "week" then
        return (lv.GetLastWeeklyReset and lv.GetLastWeeklyReset()) or (time() - 7 * 24 * 60 * 60)
    elseif period == "month" then
        local d = date("*t")
        d.day = 1
        d.hour = 0
        d.min = 0
        d.sec = 0
        return time(d)
    end
    return nil
end

local function NormalizeSourceFilter(sources)
    if type(sources) ~= "table" then
        return nil
    end

    local normalized = {}
    local hasAny = false
    for key, value in pairs(sources) do
        if type(key) == "number" then
            normalized[value] = true
            hasAny = true
        elseif value then
            normalized[key] = true
            hasAny = true
        end
    end

    return hasAny and normalized or nil
end

local function TransactionMatchesOptions(tx, opts)
    opts = opts or {}
    if type(tx) ~= "table" then
        return false
    end

    if opts.includeNonProfit ~= true and lv.IsNonProfitGoldSource(tx.source) then
        return false
    end

    local period = opts.period
    local startTs = period and GetPeriodStart(period) or nil
    if startTs and (tx.timestamp or 0) < startTs then
        return false
    end

    if opts.charKey and tx.charKey ~= opts.charKey then
        return false
    end

    local sourceFilter = NormalizeSourceFilter(opts.sources)
    if sourceFilter and not sourceFilter[tx.source] then
        return false
    end

    local charData = LiteVaultDB and tx.charKey and LiteVaultDB[tx.charKey] or nil
    if charData and charData.class then
        if opts.includeIgnored ~= true and charData.isIgnored then
            return false
        end
        local region = opts.region
        if region == nil then
            region = lv.REGION
        end
        if region and charData.region and charData.region ~= region then
            return false
        end
    end

    return true
end

function lv.GetProfitTransactions(opts)
    local storage = GetStorage()
    local results = {}
    local limit = opts and opts.limit
    for _, tx in ipairs(storage.transactions or {}) do
        if TransactionMatchesOptions(tx, opts) then
            results[#results + 1] = ShallowCopy(tx)
            if limit and #results >= limit then
                break
            end
        end
    end
    return results
end

function lv.GetCurrentMonthWowTokenPurchaseCount(opts)
    local query = ShallowCopy(opts or {})
    query.period = "month"
    query.sources = { wowToken = true }
    query.includeNonProfit = true
    query.limit = nil

    local count = 0
    local transactions = lv.GetProfitTransactions(query)
    for _, tx in ipairs(transactions or {}) do
        if tx and tx.source == "wowToken" then
            count = count + 1
        end
    end

    return count, GetPeriodStart("month")
end

function lv.GetProfitSummary(period, opts)
    local query = ShallowCopy(opts or {})
    query.period = period
    local transactions = lv.GetProfitTransactions(query)
    local income = 0
    local expense = 0
    for _, tx in ipairs(transactions) do
        local amount = tx.amount or 0
        if amount > 0 then
            income = income + amount
        elseif amount < 0 then
            expense = expense + math_abs(amount)
        end
    end

    return {
        period = period,
        count = #transactions,
        income = income,
        expense = expense,
        net = income - expense,
        startTime = GetPeriodStart(period),
        transactions = transactions,
    }
end

function lv.GetProfitDailyStats(year, month, opts)
    local statsByDay = {}
    local bestDay, bestValue = nil, 0
    local worstDay, worstValue = nil, 0
    local storage = GetStorage()
    local query = ShallowCopy(opts or {})
    local sourceFilter = NormalizeSourceFilter(query.sources)

    local function AddAmount(day, amount)
        if type(day) ~= "number" or day < 1 or day > 31 or type(amount) ~= "number" or amount == 0 then
            return
        end

        local dayStats = statsByDay[day]
        if not dayStats then
            dayStats = { net = 0, income = 0, expense = 0 }
            statsByDay[day] = dayStats
        end

        dayStats.net = dayStats.net + amount
        if amount > 0 then
            dayStats.income = dayStats.income + amount
        else
            dayStats.expense = dayStats.expense + math_abs(amount)
        end
    end

    for _, tx in ipairs(storage.transactions or {}) do
        if type(tx) == "table"
            and tx.timestamp
            and tx.amount
            and tx.source ~= "warbandBank"
            and TransactionMatchesOptions(tx, query) then
            local charData = LiteVaultDB and tx.charKey and LiteVaultDB[tx.charKey] or nil
            if charData and charData.class then
                local includeIgnored = (query.includeIgnored == true)
                local region = query.region
                if region == nil then
                    region = lv.REGION
                end

                if (includeIgnored or not charData.isIgnored)
                    and (not region or not charData.region or charData.region == region)
                    and (not sourceFilter or sourceFilter[tx.source]) then
                    local txDate = date("*t", tx.timestamp)
                    if txDate and txDate.year == year and txDate.month == month then
                        AddAmount(txDate.day, tx.amount)
                    end
                end
            end
        end
    end

    for day, dayStats in pairs(statsByDay) do
        if dayStats.net > bestValue then
            bestValue = dayStats.net
            bestDay = day
        end
        if dayStats.net < worstValue then
            worstValue = dayStats.net
            worstDay = day
        end
    end

    return {
        byDay = statsByDay,
        bestDay = bestDay,
        worstDay = worstDay,
    }
end

function lv.GetProfitGoal(period)
    local goal = GetNormalizedProfitGoal(period, true)
    return goal and ShallowCopy(goal) or nil
end

function lv.SetProfitGoal(period, copper)
    if not VALID_GOAL_PERIODS[period] then
        return false
    end

    local storage = GetStorage()
    storage.goals = storage.goals or { week = nil, month = nil }

    local amount = tonumber(copper)
    if not amount or amount <= 0 then
        storage.goals[period] = nil
        return true
    end

    storage.goals[period] = {
        scope = "warband",
        amount = math_floor(amount),
        updatedAt = time(),
    }
    return true
end

function lv.GetProfitGoalProgress(period, opts)
    if not VALID_GOAL_PERIODS[period] then
        return {
            period = period,
            goal = 0,
            current = 0,
            remaining = 0,
            percent = 0,
            met = false,
        }
    end

    local goalEntry = GetNormalizedProfitGoal(period, true)
    local goalAmount = goalEntry and tonumber(goalEntry.amount) or 0
    local summary = lv.GetProfitSummary(period, opts) or {}
    local current = tonumber(summary.net) or 0

    return {
        period = period,
        goal = goalAmount,
        current = current,
        remaining = (goalAmount > 0) and math.max(0, goalAmount - current) or 0,
        percent = (goalAmount > 0) and math.min(1, current / goalAmount) or 0,
        met = (goalAmount > 0) and (current >= goalAmount) or false,
        scope = goalEntry and goalEntry.scope or "warband",
        updatedAt = goalEntry and goalEntry.updatedAt or nil,
    }
end

function lv.GetProfitTopEarners(period, limit, opts)
    local query = ShallowCopy(opts or {})
    query.period = period
    local transactions = lv.GetProfitTransactions(query)
    local totals = {}

    for _, tx in ipairs(transactions) do
        local charKey = tx.charKey
        if charKey then
            local entry = totals[charKey]
            if not entry then
                local charData = LiteVaultDB and LiteVaultDB[charKey] or nil
                entry = {
                    charKey = charKey,
                    name = charKey:match("^([^-]+)") or charKey,
                    class = charData and charData.class or nil,
                    amount = 0,
                }
                totals[charKey] = entry
            end
            entry.amount = entry.amount + (tx.amount or 0)
        end
    end

    local results = {}
    for _, entry in pairs(totals) do
        results[#results + 1] = entry
    end

    table_sort(results, function(a, b)
        if a.amount == b.amount then
            return tostring(a.name or "") < tostring(b.name or "")
        end
        return (a.amount or 0) > (b.amount or 0)
    end)

    local maxItems = tonumber(limit) or #results
    while #results > maxItems do
        results[#results] = nil
    end
    return results
end

function lv.GetProfitSourceBreakdown(period, opts)
    local query = ShallowCopy(opts or {})
    query.period = period
    local transactions = lv.GetProfitTransactions(query)
    local buckets = {}
    local totalIncome = 0
    local totalExpense = 0

    for _, tx in ipairs(transactions) do
        if not (tx and tx.source == "warbandBank") then
            local sourceKey = tx.source or "other"
            local entry = buckets[sourceKey]
            if not entry then
                entry = {
                    source = sourceKey,
                    sourceLabel = SOURCE_LABEL_BY_KEY[sourceKey] or sourceKey,
                    income = 0,
                    expense = 0,
                    net = 0,
                    count = 0,
                }
                buckets[sourceKey] = entry
            end

            local amount = tx.amount or 0
            if amount > 0 then
                entry.income = entry.income + amount
                totalIncome = totalIncome + amount
            elseif amount < 0 then
                entry.expense = entry.expense + math_abs(amount)
                totalExpense = totalExpense + math_abs(amount)
            end
            entry.net = entry.net + amount
            entry.count = entry.count + 1
        end
    end

    local entries = {}
    for _, entry in pairs(buckets) do
        entries[#entries + 1] = entry
    end

    table_sort(entries, function(a, b)
        local aMagnitude = math_abs(a.net or 0)
        local bMagnitude = math_abs(b.net or 0)
        if aMagnitude == bMagnitude then
            return tostring(a.sourceLabel or "") < tostring(b.sourceLabel or "")
        end
        return aMagnitude > bMagnitude
    end)

    return {
        period = period,
        entries = entries,
        income = totalIncome,
        expense = totalExpense,
        net = totalIncome - totalExpense,
    }
end

function lv.ExportProfitCSV(period, opts)
    local query = ShallowCopy(opts or {})
    query.period = period
    local transactions = lv.GetProfitTransactions(query)
    local output = { "Date,Time,Character,Source,Detail,Amount,Copper\n" }

    table_sort(transactions, function(a, b)
        return (a.timestamp or 0) < (b.timestamp or 0)
    end)

    for _, tx in ipairs(transactions) do
        local timestamp = tx.timestamp or time()
        local sourceText = CleanCSVText(GetExportSourceLabel(tx))
        local detailText = CleanCSVText(GetExportDetailText(tx))
        output[#output + 1] = string_format(
            "%s,%s,%s,%s,%s,%s,%s\n",
            EscapeCSVField(date("%Y-%m-%d", timestamp)),
            EscapeCSVField(date("%H:%M:%S", timestamp)),
            EscapeCSVField(tx.charKey or ""),
            EscapeCSVField(sourceText),
            EscapeCSVField(detailText),
            EscapeCSVField(FormatCSVAmount(tx.amount or 0)),
            EscapeCSVField(tx.amount or 0)
        )
    end

    return table_concat(output, "")
end

function lv.GetProfitSources(opts)
    local results = {}
    for _, source in ipairs(SOURCE_DEFS) do
        if (opts and opts.includeNonProfit == true) or not lv.IsNonProfitGoldSource(source.key) then
            results[#results + 1] = ShallowCopy(source)
        end
    end
    return results
end

SLASH_LVGOLDDEBUG1 = "/lvgolddebug"
SlashCmdList["LVGOLDDEBUG"] = function()
    print("|cff9482c9[LiteVault]|r GoldTracker source debug")

    if lastSourceAttributionDebug then
        print(string_format(
            " Last attribution: source=%s diff=%s class=%s claim=%s reason=%s",
            tostring(lastSourceAttributionDebug.sourceWon or "?"),
            tostring(lastSourceAttributionDebug.diff or "?"),
            tostring(lastSourceAttributionDebug.evidenceClass or "?"),
            tostring(lastSourceAttributionDebug.claimType or "?"),
            tostring(lastSourceAttributionDebug.reason or "?")
        ))
    else
        print(" Last attribution: none")
    end
    print(string_format(
        " Quest state: recent=%.2fs worldQuest=%s weekly=%s pendingWQ=%s confirmedWQ=%s lastQuestID=%s",
        GetTime() - (lastQuestTime or 0),
        tostring(lastQuestWasWorldQuest and true or false),
        tostring(lastQuestWasWeekly and true or false),
        tostring(pendingWorldQuestGold and true or false),
        tostring(confirmedWorldQuestGold and true or false),
        tostring(lastTurnedInQuestID or "nil")
    ))
    if lastTurnInQuestDebug then
        print(string_format(
            " Turn-in trace: questID=%s cachedType=%s cachedWorldQuest=%s pendingBucket=%s",
            tostring(lastTurnInQuestDebug.questID or "nil"),
            tostring(lastTurnInQuestDebug.cachedType or "nil"),
            tostring(lastTurnInQuestDebug.cachedWorldQuest and true or false),
            tostring(lastTurnInQuestDebug.pendingBucket or "nil")
        ))
    else
        print(" Turn-in trace: none")
    end
    if lastQuestRemovalDebug then
        print(string_format(
            " Removal trace: questID=%s cachedType=%s cachedWorldQuest=%s",
            tostring(lastQuestRemovalDebug.questID or "nil"),
            tostring(lastQuestRemovalDebug.cachedType or "nil"),
            tostring(lastQuestRemovalDebug.cachedWorldQuest and true or false)
        ))
    else
        print(" Removal trace: none")
    end
    print(string_format(
        " Queues: ah=%d vendor=%d merchant=%d mail=%d cache=%d upgrade=%d warbandBank=%s itemUpgrade=%s",
        #ahPurchaseQueue,
        #vendorSellQueue,
        #merchantPurchaseQueue,
        #mailItemQueue,
        #pendingCacheSnapshots,
        #pendingUpgradeSnapshots,
        tostring(IsWarbandBankActive() and true or false),
        tostring(inItemUpgrade and true or false)
    ))
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MAIL_SHOW")
eventFrame:SetScript("OnEvent", function(self)
    for key in pairs(mailItemQueue) do
        mailItemQueue[key] = nil
    end
    for key in pairs(processedMailIndices) do
        processedMailIndices[key] = nil
    end

    if self.hooksSetUp then
        return
    end
    self.hooksSetUp = true

    if OpenMailFrame and OpenMailFrame.HookScript then
        OpenMailFrame:HookScript("OnShow", function()
            local mailIndex = InboxFrame and InboxFrame.openMailID
            if mailIndex and GetInboxInvoiceInfo and GetInboxInvoiceInfo(mailIndex) then
                lastAHMailTime = GetTime()
            end
        end)
    end

    if InboxFrame_OnClick then
        hooksecurefunc("InboxFrame_OnClick", function(button, index)
            local mailIndex = index or (button and button.index)
            if mailIndex and GetInboxInvoiceInfo and GetInboxInvoiceInfo(mailIndex) then
                lastAHMailTime = GetTime()
            end
        end)
    end
end)

eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MAIL_CLOSED")
eventFrame:SetScript("OnEvent", function()
    if C_Timer then
        C_Timer.After(0.5, RecordAuctionMailFallback)
    end
end)

eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MERCHANT_CLOSED")
eventFrame:SetScript("OnEvent", function()
    if C_Timer then
        C_Timer.After(0.5, function()
            for key in pairs(vendorSellQueue) do
                vendorSellQueue[key] = nil
            end
            for key in pairs(merchantPurchaseQueue) do
                merchantPurchaseQueue[key] = nil
            end
        end)
    end
end)

eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("TAXIMAP_CLOSED")
eventFrame:SetScript("OnEvent", function()
    lastFlightTime = GetTime()
end)

eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
eventFrame:SetScript("OnEvent", function()
    if C_Timer then
        C_Timer.After(0.5, function()
            for key in pairs(ahPurchaseQueue) do
                ahPurchaseQueue[key] = nil
            end
        end)
    end
end)

eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_MONEY")
eventFrame:RegisterEvent("TRADE_CLOSED")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("QUEST_REMOVED")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
eventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
eventFrame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
local deferredBankMoneyCheck = false
eventFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == addonName then
        GetStorage()
        InstallHooks()
        InitCurrentCharacterState()
        RefreshBagSlotSnapshot()
        ScanCacheItemCounts()
    elseif event == "PLAYER_LOGIN" then
        InitCurrentCharacterState()
        ScanExistingWorldQuests()
        RefreshBagSlotSnapshot()
        ScanCacheItemCounts()
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitCurrentCharacterState()
        RefreshBagSlotSnapshot()
        ScanCacheItemCounts()
    elseif event == "TRADE_CLOSED" then
        lastTradeTime = GetTime()
    elseif event == "QUEST_ACCEPTED" then
        local questID = tonumber(arg2) or tonumber(arg1)
        if questID then
            CacheActiveQuestType(questID, IsWorldQuestQuestID(questID))
        end
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        if arg1 == ITEM_UPGRADE_INTERACTION_TYPE then
            inItemUpgrade = true
        end
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        if arg1 == ITEM_UPGRADE_INTERACTION_TYPE and C_Timer then
            C_Timer.After(0.5, function()
                inItemUpgrade = false
            end)
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
        if arg3 and C_Spell and C_Spell.GetSpellName then
            local spellName = C_Spell.GetSpellName(arg3)
            local openingSpellName = C_Spell.GetSpellName(3365)
            if arg3 == 3365 or (openingSpellName and spellName == openingSpellName) or spellName == "Opening" then
                MarkRecentCacheUsed()
            end
        end
    elseif event == "ITEM_LOCK_CHANGED" then
        MarkCacheContainerIfPresent(arg1, arg2)
    elseif event == "BAG_UPDATE_DELAYED" then
        RefreshBagSlotSnapshot()
        ScanCacheItemCounts()
    elseif event == "CHAT_MSG_MONEY" or event == "CHAT_MSG_SYSTEM" then
        local nowTime = GetTime()
        local recentQuestCompletion = (nowTime - lastQuestTime < 10.0)
        local rewardAmount = ExtractMoneyAmountFromMessage(arg1)
        if recentQuestCompletion and lastQuestWasWorldQuest and IsLocalizedQuestRewardMoneyMessage(arg1) then
            confirmedWorldQuestGold = true
            confirmedWorldQuestTime = nowTime
            pendingWorldQuestGold = false
            pendingWorldQuestTime = 0
            ClearPendingReward("worldQuest")
            RetagRecentTransactionAsWorldQuest(rewardAmount, rewardAmount and "world quest chat amount confirmation" or "world quest chat confirmation")
        end
    elseif event == "QUEST_TURNED_IN" or event == "QUEST_REMOVED" then
        local cachedQuestType = GetCachedActiveQuestType(arg1)
        local isWorldQuest = cachedQuestType and cachedQuestType.isWorldQuest or false
        local isWeekly = false

        if not isWorldQuest and event == "QUEST_TURNED_IN" and arg1 then
            local logIdx = C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetLogIndexForQuestID(arg1)
            if logIdx then
                local info = C_QuestLog.GetInfo and C_QuestLog.GetInfo(logIdx)
                isWeekly = info and info.frequency == 2 or false
            end
            if not isWeekly and QuestIsWeekly then
                isWeekly = QuestIsWeekly()
            end
        end

        lastQuestTime = GetTime()

        if event == "QUEST_TURNED_IN" then
            lastQuestWasWorldQuest = isWorldQuest
            lastQuestWasWeekly = isWeekly or false
            lastTurnedInQuestID = arg1
            confirmedWorldQuestGold = false
            confirmedWorldQuestTime = 0
            if isWorldQuest then
                ClearPendingReward("quest")
            else
                pendingWorldQuestGold = false
                pendingWorldQuestTime = 0
                ClearPendingReward("worldQuest")
            end
            local pendingSourceKey = isWorldQuest and "worldQuest" or "quest"
            if tonumber(arg3) and tonumber(arg3) > 0 then
                SetPendingReward(pendingSourceKey, arg1, tonumber(arg3), REWARD_PENDING_TTL_SECONDS, "QUEST_TURNED_IN amount")
            else
                SetPendingReward(pendingSourceKey, arg1, nil, REWARD_PENDING_CHAT_TTL_SECONDS, "QUEST_TURNED_IN awaiting chat confirmation")
            end
            lastTurnInQuestDebug = {
                questID = arg1,
                cachedType = cachedQuestType and cachedQuestType.questType or "quest",
                cachedWorldQuest = cachedQuestType and cachedQuestType.isWorldQuest or false,
                pendingBucket = (pendingSourceKey == "worldQuest") and "pendingWorldQuestReward" or "pendingQuestReward",
            }
        elseif isWorldQuest then
            lastQuestWasWorldQuest = true
            ClearPendingReward("quest")
        elseif lastTurnedInQuestID ~= arg1 then
            lastQuestWasWorldQuest = false
            pendingWorldQuestGold = false
            pendingWorldQuestTime = 0
            ClearPendingReward("worldQuest")
        end
        if event == "QUEST_REMOVED" then
            lastQuestRemovalDebug = {
                questID = arg1,
                cachedType = cachedQuestType and cachedQuestType.questType or "quest",
                cachedWorldQuest = cachedQuestType and cachedQuestType.isWorldQuest or false,
            }
        end

        if isWorldQuest then
            pendingWorldQuestGold = true
            pendingWorldQuestTime = lastQuestTime
            local pendingReward = GetPendingReward("worldQuest", lastQuestTime)
            local authoritativeAmount = tonumber(arg3) or tonumber(pendingReward and pendingReward.amount)
            RetagRecentTransactionAsWorldQuest(authoritativeAmount, event .. " authoritative world quest correction")
        end
        ClearCachedActiveQuestType(arg1)
    elseif event == "PLAYER_MONEY" and IsWarbandBankActive() and C_Timer then
        if not deferredBankMoneyCheck then
            deferredBankMoneyCheck = true
            C_Timer.After(0.6, function()
                deferredBankMoneyCheck = false
                local handler = eventFrame:GetScript("OnEvent")
                if handler then handler(eventFrame, "LITEVAULT_DEFERRED_PLAYER_MONEY") end
            end)
        end
    elseif event == "PLAYER_MONEY" or event == "LITEVAULT_DEFERRED_PLAYER_MONEY" then
        local nowTime = GetTime()
        local charKey = cachedPlayerName or SafeCharKey()
        if not charKey or not GetMoney then
            return
        end

        local storage = GetStorage()
        local currentMoney = GetMoney()
        local lastMoney = storage.lastKnownMoney[charKey]
        if type(lastMoney) ~= "number" then
            storage.lastKnownMoney[charKey] = currentMoney
            return
        end

        local diff = currentMoney - lastMoney
        if diff == 0 then
            return
        end

        if lv and lv.ConsumeConfirmedWarbandTransfer and lv.ConsumeConfirmedWarbandTransfer(diff) then
            storage.lastKnownMoney[charKey] = currentMoney
            return
        end

        lastTriggerTime = nowTime
        local claim, attributionDebug = DetermineSource(nowTime, diff)
        RecordSourceAttributionDebug(attributionDebug)
        local sourceKey = claim and claim.source or "loot"
        local tx = BuildTransaction(sourceKey, diff, time())
        AttachTransactionDetail(tx, sourceKey, diff, claim)
        local inserted = InsertTransaction(tx)
        if not inserted then
            return
        end
        storage.lastKnownMoney[charKey] = currentMoney

        if tx.detailLink and tx.itemID and tx.detailLink:match("|cff9d9d9d%[") then
            ScheduleItemFixup(tx, tx.itemID)
            StartFixupProcessing()
        end
    end
end)
