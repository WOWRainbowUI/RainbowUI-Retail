---@class GUTIL-2.0
local GUTIL = LibStub:NewLibrary("GUTIL-2.0", 8)
if not GUTIL then return end

--- CLASSICS insert
local Object = {}
Object.__index = Object

GUTIL.Object = Object

function Object:new()
end

function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end

function Object:implement(...)
  for _, cls in pairs({ ... }) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end

function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

function Object:__tostring()
  return "Object"
end

function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

--- CLASSICS END

if not GUTIL then return end

---Returns an item string from an item link if found
---@param itemLink string
---@return string? itemString
function GUTIL:GetItemStringFromLink(itemLink)
  return select(3, strfind(itemLink, "|H(.+)|h%["))
end

---Returns the quality of the item based on an item link if the item has a quality
---@param itemLink string
---@return number? qualityID
function GUTIL:GetQualityIDFromLink(itemLink)
  local qualityID = string.match(itemLink, "Quality%-Tier(%d+)")
  return tonumber(qualityID)
end

function GUTIL:StringStartsWith(mainString, prefix)
  return string.sub(mainString, 1, #prefix) == prefix
end

function GUTIL:GetItemTooltipText(itemLink)
  local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)

  if not tooltipData then
    return ""
  end

  local tooltipText = ""
  for _, line in pairs(tooltipData.lines) do
    local lineText = ""
    for _, arg in pairs(line.args) do
      if arg.stringVal then
        lineText = lineText .. arg.stringVal
      end
    end
    tooltipText = tooltipText .. lineText .. "\n"
  end

  return tooltipText
end

---Finds the first element in the table where findFunc(element) returns true
---@generic K
---@generic V
---@param t table<K, V>
---@param findFunc fun(value: V): boolean
---@return V? element
---@return K? key
function GUTIL:Find(t, findFunc)
  for k, v in pairs(t) do
    if findFunc(v) then
      return v, k
    end
  end

  return nil
end

--- to concat lists together (behaviour unpredictable with tables that have strings or not ordered numbers as indices)
---@generic V
---@param tableList table<number, V[]>
---@return V[]
function GUTIL:Concat(tableList)
  local finalList = {}
  for _, currentTable in pairs(tableList) do
    for _, item in pairs(currentTable) do
      table.insert(finalList, item)
    end
  end
  return finalList
end

---makes a table unique
---@generic V
---@param t V[]
---@param compareFunc? fun(element: V): any return a value with that the elements should be compared with in uniqueness
---@return V[]
function GUTIL:ToSet(t, compareFunc)
  local set = {}
  local containedMap = {} -- to speed things up

  if not compareFunc then
    for _, element in pairs(t) do
      if not containedMap[element] then
        table.insert(set, element)
        containedMap[element] = true
      end
    end
  else
    for _, element in pairs(t) do
      local uniqueValue = compareFunc(element)
      if not containedMap[uniqueValue] then
        table.insert(set, element)
        containedMap[uniqueValue] = true
      end
    end
  end

  return set
end

---@class GUTIL.MapOptions
---@field subTable boolean a subproperty that is a table that is to be mapped instead of the table itself
---@field isTableList boolean if the table only consists of other tables, map each subTable instead

--- maps a table to another table by calling mapFunc for each element. If the mapFunc returns nil the element will be skipped
---@generic K
---@generic V
---@generic R
---@param t table<K, V>
---@param mapFunc fun(value:V, key:K): R
---@param options GUTIL.MapOptions?
---@return R[]
function GUTIL:Map(t, mapFunc, options)
  options = options or {}
  local mapped = {}
  if not options.subTable then
    for k, v in pairs(t) do
      if options.isTableList then
        if type(v) ~= "table" then
          error("GUTIL.Map: t contains a nontable element")
        end
        for subK, subV in pairs(v) do
          local mappedValue = mapFunc(subV, subK)
          if not mappedValue then
            error("GUTIL.Map: Did you forget to return in mapFunc?")
          end
          table.insert(mapped, mappedValue)
        end
      else
        local mappedValue = mapFunc(v, k)
        if mappedValue then
          table.insert(mapped, mappedValue)
        end
      end
    end
    return mapped
  else
    for k, v in pairs(t) do
      if not v[options.subTable] or type(v[options.subTable]) ~= "table" then
        print("GUTIL.Map: given options.subTable is not existing or no table: " .. tostring(v[options.subTable]))
      else
        for subK, subV in pairs(v[options.subTable]) do
          local mappedValue = mapFunc(subV, subK)
          if not mappedValue then
            error("GUTIL.Map: Did you forget to return in mapFunc?")
          end
          table.insert(mapped, mappedValue)
        end
      end
    end
    return mapped
  end
end

---@generic V
---@param t V[]
---@param filterFunc fun(value: V): boolean
---@return V[]
function GUTIL:Filter(t, filterFunc)
  local filtered = {}
  for k, v in pairs(t) do
    if filterFunc(v) then
      table.insert(filtered, v)
    end
  end
  return filtered
end

function GUTIL:CreateRegistreeForEvents(events)
  local registree = CreateFrame("Frame", nil)
  registree:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
  for _, event in pairs(events) do
    registree:RegisterEvent(event)
  end
  return registree
end

---Validate if a string is of format 100g50s10c
---@param moneyString string
---@return boolean valid
function GUTIL:ValidateMoneyString(moneyString)
  -- check if the string matches the pattern
  if not string.match(moneyString, "^%d*g?%d*s?%d*c?$") then
    return false
  end

  -- check if the string contains at least one of g, s, or c
  if not string.match(moneyString, "[gsc]") then
    return false
  end

  -- check if the string contains multiple g, s, or c
  if string.match(moneyString, "g.*g") then
    return false
  end
  if string.match(moneyString, "s.*s") then
    return false
  end
  if string.match(moneyString, "c.*c") then
    return false
  end

  -- check if it ends incorrectly
  if string.match(moneyString, "%d$") then
    return false
  end

  -- check if the string contains invalid characters
  if string.match(moneyString, "[^%dgsc]") then
    return false
  end

  -- all checks passed, the string is valid
  return true
end

---Returns the given copper value as gold, silver and copper seperated, as string formated or as numbers
---@param copperValue number
---@param formatString? boolean
---@return string | number
---@return number?
---@return number?
function GUTIL:GetMoneyValuesFromCopper(copperValue, formatString)
  local gold = math.floor(copperValue / 10000)
  local silver = math.floor(copperValue % 10000 / 100)
  local copper = math.floor(copperValue % 100)

  if not formatString then
    return gold, silver, copper
  else
    return gold .. "g " .. silver .. "s " .. copper .. "c"
  end
end

---Colorizes a Text based on a color in GUTIL.COLORS (hex with alpha prefix)
---@param text string
---@param color string
---@return string colorizedText
function GUTIL:ColorizeText(text, color)
  local startLine = "\124c"
  local endLine = "\124r"
  return startLine .. color .. text .. endLine
end

---@enum GUTIL.COLORS
GUTIL.COLORS = {
  GREEN = "ff00FF00",
  RED = "ffFF0000",
  DARK_BLUE = "ff2596be",
  BRIGHT_BLUE = "ff00ccff",
  LEGENDARY = "ffff8000",
  EPIC = "ffa335ee",
  RARE = "ff0070dd",
  UNCOMMON = "ff1eff00",
  GREY = "ff9d9d9d",
  ARTIFACT = "ffe6cc80",
  GOLD = "fffffc01",
  SILVER = "ffdadada",
  COPPER = "ffc9803c",
  PATREON = "ffff424D",
  WHISPER = "ffff80ff",
  WHITE = "ffffffff",
}

---@enum GUTIL.CLASS_COLORS
GUTIL.CLASS_COLORS = {
  WARRIOR = "ffc79c6e", -- #C79C6E
  ARMS = "ffc79c6e",
  FURY = "ffc79c6e",
  PROTECTION = "ffc79c6e",

  PALADIN = "fff58cba", -- #F58CBA
  HOLY = "fff58cba",
  RETRIBUTION = "fff58cba",
  PROTECTION_PALADIN = "fff58cba",

  HUNTER = "ffabd473", -- #ABD473
  BEAST_MASTERY = "ffabd473",
  MARKSMANSHIP = "ffabd473",
  SURVIVAL = "ffabd473",

  ROGUE = "fffff569", -- #FFF569
  ASSASSINATION = "fffff569",
  OUTLAW = "fffff569",
  SUBTLETY = "fffff569",

  PRIEST = "ffffffff", -- #FFFFFF
  DISCIPLINE = "ffffffff",
  HOLY_PRIEST = "ffffffff",
  SHADOW = "ffffffff",

  DEATHKNIGHT = "ffc41f3b", -- #C41F3B
  BLOOD = "ffc41f3b",
  FROST = "ffc41f3b",
  UNHOLY = "ffc41f3b",

  SHAMAN = "ff0070de", -- #0070DE
  ELEMENTAL = "ff0070de",
  ENHANCEMENT = "ff0070de",
  RESTORATION = "ff0070de",

  MAGE = "ff69ccf0", -- #69CCF0
  ARCANE = "ff69ccf0",
  FIRE = "ff69ccf0",
  FROST_MAGE = "ff69ccf0",

  WARLOCK = "ff9482c9", -- #9482C9
  AFFLICTION = "ff9482c9",
  DEMONOLOGY = "ff9482c9",
  DESTRUCTION = "ff9482c9",

  MONK = "ff00ff96", -- #00FF96
  BREWMASTER = "ff00ff96",
  MISTWEAVER = "ff00ff96",
  WINDWALKER = "ff00ff96",

  DRUID = "ffff7d0a", -- #FF7D0A
  BALANCE = "ffff7d0a",
  FERAL = "ffff7d0a",
  GUARDIAN = "ffff7d0a",
  RESTORATION_DRUID = "ffff7d0a",

  DEMONHUNTER = "ffa330c9", -- #A330C9
  HAVOC = "ffa330c9",
  VENGEANCE = "ffa330c9",

  EVOKER = "ff33937f", -- #33937F
  AUGMENTATION = "ff33937f",
  DEVASTATION = "ff33937f",
  PRESERVATION = "ff33937f",
}

-- Thanks to arkinventory
function GUTIL:StripColor(text)
  local text = text or ""
  text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = string.gsub(text, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
  text = string.gsub(text, "|r", "")
  return text
end

function GUTIL:GetPercentRelativeTo(value, hundredPercentValue)
  local oneP = hundredPercentValue / 100
  local percent = GUTIL:Round(value / oneP, 0)

  if oneP == 0 then
    percent = 0
  end
  return percent
end

--- formats the given copper value as gold, silver and copper display with icons
---@param copperValue number
---@param useColor? boolean -- colors the numbers green if positive and red if negative
---@param percentRelativeTo number? if included: will be treated as 100% and a % value in relation to the coppervalue will be added
---@param separateThousands? boolean
function GUTIL:FormatMoney(copperValue, useColor, percentRelativeTo, separateThousands)
  copperValue = GUTIL:Round(copperValue) -- there is no such thing as decimal coppers (we no fuel station here)
  local absValue = abs(copperValue)
  local minusText = ""
  local color = GUTIL.COLORS.GREEN
  local percentageText = ""

  if percentRelativeTo then
    percentageText = " (" .. GUTIL:GetPercentRelativeTo(copperValue, percentRelativeTo) .. "%)"
  end

  if copperValue < 0 then
    minusText = "-"
    color = GUTIL.COLORS.RED
  end

  if useColor then
    return GUTIL:ColorizeText(minusText .. GetMoneyString(absValue, separateThousands) .. percentageText, color)
  else
    return minusText .. GetMoneyString(absValue, separateThousands) .. percentageText
  end
end

function GUTIL:Round(number, decimals)
  return tonumber((("%%.%df"):format(decimals)):format(number))
end

function GUTIL:GetItemIDByLink(hyperlink)
  local _, _, foundID = string.find(hyperlink, "item:(%d+)")
  return tonumber(foundID)
end

--- returns an ItemLocationMixin if found in the players bags or optional also bank
---@param itemID number
---@param includeBank boolean?
---@return ItemLocationMixin | nil itemLocation
function GUTIL:GetItemLocationFromItemID(itemID, includeBank)
  includeBank = includeBank or false
  local function FindBagAndSlot(itemID)
    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local slotItemID = C_Container.GetContainerItemID(bag, slot)
        if slotItemID == itemID then
          return bag, slot
        end
      end
    end
    if includeBank then
      for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
          local slotItemID = C_Container.GetContainerItemID(bag, slot)
          if slotItemID == itemID then
            return bag, slot
          end
        end
      end
    end
  end
  local bag, slot = FindBagAndSlot(itemID)

  if bag and slot then
    return ItemLocation:CreateFromBagAndSlot(bag, slot)
  end
  return nil -- Return nil if not found
end

---@param itemList ItemMixin[]
---@param callback function
function GUTIL:ContinueOnAllItemsLoaded(itemList, callback)
  local itemsToLoad = #itemList
  if itemsToLoad == 0 then
    callback()
  end
  local itemLoaded = function()
    itemsToLoad = itemsToLoad - 1

    if itemsToLoad <= 0 then
      callback()
    end
  end

  if itemsToLoad >= 1 then
    for _, itemToLoad in pairs(itemList) do
      itemToLoad:ContinueOnItemLoad(itemLoaded)
    end
  end
end

---@param conditionCallback fun(): boolean
---@param callback function will be executed as soon as the condition is fulfilled
---@param checkInterval number? Seconds - Default: 0 (once per frame).
---@param maxWaitSeconds number? Maximum Seconds to wait, default: 10. No callback called when timeout triggered
function GUTIL:WaitFor(conditionCallback, callback, checkInterval, maxWaitSeconds)
  maxWaitSeconds = maxWaitSeconds or 10
  local startTime = GetTimePreciseSec()
  local function checkCondition()
    local secondsElapsed = GetTimePreciseSec() - startTime
    if secondsElapsed >= maxWaitSeconds then
      return
    end
    if conditionCallback() then
      callback()
    else
      C_Timer.After(checkInterval or 0, checkCondition)
    end
  end

  checkCondition()
end

---@param event WowEvent
---@param callback function
---@param maxWaitSeconds number?
function GUTIL:WaitForEvent(event, callback, maxWaitSeconds)
  local frame = CreateFrame("frame")
  frame:RegisterEvent(event)

  local unregistered = false
  local function unregister()
    if unregistered then return end
    unregistered = true
    frame:UnregisterEvent(event)
    frame:SetScript("OnEvent", nil)
  end

  frame:SetScript("OnEvent", function(_, ...)
    callback(...)
    unregister()
  end)

  if maxWaitSeconds then
    C_Timer.After(maxWaitSeconds, unregister)
  end
end

function GUTIL:EquipItemByLink(link)
  for bag = BANK_CONTAINER, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      local item = C_Container.GetContainerItemLink(bag, slot)
      if item and item == link then
        if CursorHasItem() or CursorHasMoney() or CursorHasSpell() then ClearCursor() end
        C_Container.PickupContainerItem(bag, slot)
        AutoEquipCursorItem()
        return true
      end
    end
  end
end

function GUTIL:isItemSoulbound(itemID)
  return select(14, GetItemInfo(itemID)) == 1
end

--> GGUI or keep here?
function GUTIL:GetQualityIconString(qualityID, sizeX, sizeY, offsetX, offsetY)
  return CreateAtlasMarkup("Professions-Icon-Quality-Tier" .. qualityID, sizeX, sizeY, offsetX, offsetY)
end

--- Counts the number of items that return true for the given function
---@generic K
---@generic V
---@param t table<K, V>
---@param func fun(value: V): boolean
---@return number count
function GUTIL:Count(t, func)
  local count = 0
  for _, v in pairs(t) do
    if func and func(v) then
      count = count + 1
    elseif not func then
      count = count + 1
    end
  end

  return count
end

--- Returns true if any of the table's items resolves to true for the given function
---@generic K
---@generic V
---@param t table<K, V>
---@param func fun(value: V): boolean
---@return boolean
function GUTIL:Some(t, func)
  return self:Count(t, func) > 0
end

--- Returns true if all of the table's items resolve to true for the given function
---@generic V
---@param t V[]
---@param func fun(element: V):boolean
---@return boolean
function GUTIL:Every(t, func)
  local tableCount = self:Count(t)
  return self:Count(t, func) == tableCount
end

--- Variant of table.sort that does not sort it in place
---comment
---@param t table
---@param compFunc function sort function (a, b)
---@return table sorted sorted copy of given table
function GUTIL:Sort(t, compFunc)
  local sorted = {}
  for _, e in pairs(t) do
    table.insert(sorted, e)
  end

  table.sort(sorted, compFunc) -- more performant but in place

  return sorted
end

---Trims the table to a specific amount of elements.
---@param t table<number, any>
---@param amount number
---@param front boolean? if true table will be trimmed from front, otherwise from back
function GUTIL:TrimTable(t, amount, front)
  if #t == 0 then
    return t
  end
  if front then
    while (#t > amount) do
      table.remove(t, 1)
    end
  else
    while (#t > amount) do
      table.remove(t, #t)
    end
  end
end

--- compares versions like "7.8.10" and "10.8.9" (would say right is greater then left)
---@param versionA string
---@param versionB string
---@return number result 0 if same 1 if left is greater, -1 if left is smaller
function GUTIL:CompareVersionStrings(versionA, versionB)
  local function compareSubversions(subversionA, subversionB)
    for i = 1, math.max(#subversionA, #subversionB) do
      local numA = tonumber(subversionA[i]) or 0
      local numB = tonumber(subversionB[i]) or 0
      if numA < numB then
        return -1
      elseif numA > numB then
        return 1
      end
    end
    return 0
  end

  local subversionA = strsplit(versionA)
  local subversionB = strsplit(versionB)

  local result = compareSubversions(subversionA, subversionB)

  return result
end

---@generic K
---@generic V
---@param t table<K, V>
---@param initialValue any
---@param foldFunction fun(foldValue: any, nextElement: V, key: K): any
function GUTIL:Fold(t, initialValue, foldFunction)
  local accumulator = initialValue
  for key, value in pairs(t) do
    accumulator = foldFunction(accumulator, value, key)
  end

  return accumulator
end

--- splits a table into two tables, elements that resolve into true for the given function will be put into the first table
---@param t table
---@param splitFunc function
function GUTIL:Split(t, splitFunc)
  local tableA = {}
  local tableB = {}
  for _, element in pairs(t) do
    if splitFunc(element) then
      table.insert(tableA, element)
    else
      table.insert(tableB, element)
    end
  end
  return tableA, tableB
end

function GUTIL:IconToText(iconPath, height, width)
  if not width then
    return "\124T" .. iconPath .. ":" .. height .. "\124t"
  else
    return "\124T" .. iconPath .. ":" .. height .. ":" .. width .. "\124t"
  end
end

function GUTIL:ValidateNumberString(str, min, max, allowDecimals)
  local num = tonumber(str)
  if num == nil then
    return false -- Not a valid number
  end
  if not allowDecimals and num ~= math.floor(num) then
    return false -- Decimals not allowed
  end
  if (min and num < min) or (max and num > max) then
    return false -- Outside specified range
  end
  return true    -- Valid number within range
end

---@param timestampHigher number unix seconds
---@param timestampBLower number unix seconds
---@return integer dayDiff
function GUTIL:GetDaysBetweenTimestamps(timestampHigher, timestampBLower)
  -- Calculate the difference in seconds
  local differenceInSeconds = math.abs(timestampHigher - timestampBLower)

  -- Convert seconds to days
  local secondsInADay = 24 * 60 * 60 -- 24 hours * 60 minutes * 60 seconds
  local differenceInDays = differenceInSeconds / secondsInADay

  -- Round to the nearest whole number of days
  differenceInDays = math.floor(differenceInDays + 0.5)

  return differenceInDays
end

--- used by GUTIL:OrderedPairs function
---@generic K
---@generic V
---@param t table<K, V>
---@return K, V
function GUTIL.OrderedNext(t)
  local key = t[t.__next]
  if not key then return end
  t.__next = t.__next + 1
  return key, t.__source[key]
end

---based on [OrderedPairs User-Function](https://warcraft.wiki.gg/wiki/Orderedpairs)
---@generic K
---@generic V
---@param t table<K, V>
---@param compFunc? fun(a: V, b: V):boolean
---@return fun(t: table<K, V>): K, V orderedNext
---@return K[] keys
function GUTIL:OrderedPairs(t, compFunc)
  local keys, kn = { __source = t, __next = 1 }, 1
  for k in pairs(t) do
    keys[kn], kn = k, kn + 1
  end
  table.sort(keys, compFunc)
  return GUTIL.OrderedNext, keys
end

--- spreads the iteration (unsorted random) of a given function over multiple frames (one frame per iteration) to reduce game lag for heavy processing.
--- Use the finallyCallback to continue after the iteration ends
---@async
---@generic K
---@generic V
---@param t table<K, V> the table to be iterated on
---@param iterationFunction fun(key:K, value:V, counter:number):boolean|nil called for each iteration of the given table, if the function returns false iteration will be stopped
---@param finallyCallback? function called after the iteration ends
---@param maxIterations? integer maximum number of iterations. Default is nil meaning no maximum
---@param maxMS? number maximum time in ms after the iteration is canceled
function GUTIL:FrameDistributedIteration(t, iterationFunction, finallyCallback, maxIterations, maxMS)
  --- map the keys of the table to indexes
  local iterationCounter = 1
  local startMS = GetTime() * 1000
  local currentIterationKey = nil
  local currentTableValue = nil
  local function iterate()
    currentIterationKey, currentTableValue = next(t, currentIterationKey)

    if not currentIterationKey then
      -- no more elements - end iterations
      if finallyCallback then
        finallyCallback()
      end
      return
    end

    local result = iterationFunction(currentIterationKey, currentTableValue, iterationCounter)
    local stopIteration = result ~= nil and result == false
    iterationCounter = iterationCounter + 1
    local elapsedMS = (GetTime() * 1000) - startMS
    local secondsReached = maxMS and (maxMS <= elapsedMS)
    local iterationsReached = maxIterations and (iterationCounter > maxIterations)

    if stopIteration or iterationsReached or secondsReached then
      if finallyCallback then
        finallyCallback()
      end
      return
    else
      RunNextFrame(iterate)
    end
  end

  iterate()
end
