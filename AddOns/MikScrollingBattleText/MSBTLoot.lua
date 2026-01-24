-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Loot
-- Author: Mikord (12.0.1 Restoration - Final Production)
-- Status: RESTORED (Async Item Loading with Exponential Backoff)
-------------------------------------------------------------------------------

local module = {}
local moduleName = "Loot"
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local MSBTParser = MikSBT.Parser

local string_gsub = string.gsub
local string_format = string.format
local math_ceil = math.ceil
local GetItemInfo = C_Item.GetItemInfo
local GetItemCount = C_Item.GetItemCount
local DisplayEvent = MikSBT.Animations.DisplayEvent

local GOLD = string_gsub(GOLD_AMOUNT, "%%d *", "")
local SILVER = string_gsub(SILVER_AMOUNT, "%%d *", "")
local COPPER = string_gsub(COPPER_AMOUNT, "%%d *", "")
local ITEM_TYPE_QUEST = C_Item.GetItemClassInfo(LE_ITEM_CLASS_QUESTITEM or Enum.ItemClass.Questitem)

local _
local qualityPatterns = {}

-- Forward declaration for recursion
local HandleItems

-------------------------------------------------------------------------------
-- Event handlers
-------------------------------------------------------------------------------

local function HandleMoney(parserEvent)
	local moneyString = parserEvent.moneyString
	moneyString = string_gsub(moneyString, GOLD, "|cffffd700%1|r")
	moneyString = string_gsub(moneyString, SILVER, "|cff808080%1|r")
	moneyString = string_gsub(moneyString, COPPER, "|cffeda55f%1|r")

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_MONEY
	if eventSettings and not eventSettings.disabled then
		local message = eventSettings.message
		message = string_gsub(message, "%%e", moneyString)
		DisplayEvent(eventSettings, message)
	end
end

local function HandleCurrency(parserEvent)
	local itemLink = parserEvent.itemLink
	local itemName, numAmount, itemTexture, totalMax, itemQuality, numLootedFromMessage
	local currency = C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink)
	if currency then
		itemName, numAmount, itemTexture, totalMax, itemQuality = currency.name, currency.quantity, currency.iconFileID, currency.maxQuantity, currency.quality
	else
		if string.match(itemLink,"^, %d+") then
			numLootedFromMessage = string.match(itemLink, "%d+")
			currency = C_CurrencyInfo.GetCurrencyInfo(1901)
			itemName, numAmount, itemTexture, totalMax, itemQuality = currency.name, currency.quantity, currency.iconFileID, currency.maxQuantity, currency.quality
		else
			return
		end
	end

	local currentProfile = MSBTProfiles.currentProfile
	local showEvent = true
	if currentProfile.itemExclusions[itemName] then showEvent = false end
	if currentProfile.itemsAllowed[itemName] then showEvent = true end
	if not showEvent then return end

	if qualityPatterns[itemQuality] then
		itemName = string_format(qualityPatterns[itemQuality], itemName)
	end

	local numLooted = parserEvent.amount or numLootedFromMessage or 1
	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CURRENCY
	if eventSettings and not eventSettings.disabled then
		local message = eventSettings.message
		message = string_gsub(message, "%%e", itemName)
		message = string_gsub(message, "%%a", numLooted)
		message = string_gsub(message, "%%t", numAmount)
		DisplayEvent(eventSettings, message, itemTexture)
	end
end

-- ****************************************************************************
-- HandleItems (Production Edition)
-- Implements Async Retry Loop to handle 12.0.1 Server Latency
-- ****************************************************************************
HandleItems = function(parserEvent, retryCount)
	if (parserEvent.isCreate) then return end
	local itemLink = parserEvent.itemLink
	if not itemLink then return end

	-- 1. Attempt to get cached data
	local itemName, _, itemQuality, _, _, itemType, _, _, _, itemTexture = C_Item.GetItemInfo(itemLink)

	-- 2. Async Handler: If data missing, request and retry later
	if not itemName then
		retryCount = retryCount or 0
		
		-- Stop after ~2 seconds (3 retries) to prevent infinite loops
		if retryCount > 3 then return end

		-- Ask server for data
		C_Item.RequestLoadItemDataByID(itemLink)
		
		-- Exponential backoff: 0.2s -> 0.4s -> 0.8s
		local delay = 0.2 * (2 ^ retryCount)
		C_Timer.After(delay, function()
			HandleItems(parserEvent, retryCount + 1)
		end)
		return
	end
	
	-- 3. Data Loaded: Process Filters
	local currentProfile = MSBTProfiles.currentProfile
	local showEvent = true
	
	if currentProfile.qualityExclusions[itemQuality] then
		showEvent = false
	end
	if itemType == ITEM_TYPE_QUEST and currentProfile.alwaysShowQuestItems then
		showEvent = true
	end
	if currentProfile.itemExclusions[itemName] then
		showEvent = false
	end
	if currentProfile.itemsAllowed[itemName] then
		showEvent = true
	end
	
	if not showEvent then return end

	-- 4. Format & Display
	if qualityPatterns[itemQuality] then
		itemName = string_format(qualityPatterns[itemQuality], itemName)
	end

	local numLooted = parserEvent.amount or 1
	local numItems = GetItemCount(itemLink)
	if numItems == 0 then numItems = numLooted end 
	local numTotal = numItems

	local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_LOOT
	if eventSettings and not eventSettings.disabled then
		local message = eventSettings.message
		message = string_gsub(message, "%%e", itemName)
		message = string_gsub(message, "%%a", numLooted)
		message = string_gsub(message, "%%t", numTotal)
		DisplayEvent(eventSettings, message, itemTexture)
	end
end


-- ****************************************************************************
-- Parser Handler
-- ****************************************************************************
local function ParserEventsHandler(parserEvent)
	if parserEvent.recipientUnit ~= "player" or parserEvent.eventType ~= "loot" then
		return
	end

	if parserEvent.isMoney then
		HandleMoney(parserEvent)
	elseif parserEvent.isCurrency then
		HandleCurrency(parserEvent)
	elseif parserEvent.itemLink then
		HandleItems(parserEvent)
	end
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------
for k, v in pairs(ITEM_QUALITY_COLORS) do
	qualityPatterns[k] = string_format("|cFF%02x%02x%02x[%%s]|r", math_ceil(v.r * 255), math_ceil(v.g * 255), math_ceil(v.b * 255))
end

MSBTParser.RegisterHandler(ParserEventsHandler)