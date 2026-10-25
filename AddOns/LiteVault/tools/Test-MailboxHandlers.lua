-- Behavioral tests for mailbox-closed handling (Lua 5.1).
-- Retail no longer fires MAIL_CLOSED; Blizzard's mail frame opens and closes through the
-- player interaction manager (Enum.PlayerInteractionType.MailInfo). Modules/MailTracker.lua
-- reports each mailbox visit once through lv.MailboxClosedHandlers, used by Core, Currency
-- and GoldTracker. Loads the real files in TOC order with a minimal WoW API harness.
-- Run from the addon root:  lua5.1 tools/Test-MailboxHandlers.lua

local failures, checks = {}, 0
local function check(condition, message)
    checks = checks + 1
    if not condition then failures[#failures + 1] = message end
end

-- ---------------------------------------------------------------- WoW harness
local now, clock = 1800000000, 100
local created, timers, hooks = {}, {}, {}
local stubMeta = {}
local function NewStub(kind, name, parent)
    local object = setmetatable({ _kind = kind, _scripts = {}, _events = {}, _shown = false, _parent = parent }, stubMeta)
    created[#created + 1] = object
    if name then _G[name] = object end
    return object
end
stubMeta.__index = function(self, key)
    if key == "GetFrameLevel" or key == "GetWidth" or key == "GetHeight" or key == "GetStringWidth" then return function() return 1 end end
    if key == "CreateFontString" or key == "CreateTexture" or key == "CreateAnimationGroup" then return function(owner) return NewStub(key, nil, owner) end end
    if key == "SetScript" then return function(owner, scriptName, fn) owner._scripts[scriptName] = fn end end
    if key == "GetScript" then return function(owner, scriptName) return owner._scripts[scriptName] end end
    if key == "HookScript" then
        return function(owner, scriptName, fn)
            local previous = owner._scripts[scriptName]
            owner._scripts[scriptName] = function(...) if previous then previous(...) end return fn(...) end
        end
    end
    if key == "RegisterEvent" then return function(owner, event) owner._events[event] = true end end
    if key == "UnregisterEvent" then return function(owner, event) owner._events[event] = nil end end
    if key == "IsEventRegistered" then return function(owner, event) return owner._events[event] == true end end
    if key == "Show" then return function(owner) owner._shown = true end end
    if key == "Hide" then return function(owner) owner._shown = false end end
    if key == "IsShown" or key == "IsVisible" then return function(owner) return owner._shown end end
    if key == "GetParent" then return function(owner) return owner._parent end end
    if type(key) == "string" and key:match("^%u") then return function() return nil end end
    return nil
end

CreateFrame = function(kind, name, parent) return NewStub(kind, name, parent) end
UIParent = NewStub("UIParent")
UISpecialFrames, NUM_CHAT_WINDOWS = {}, 1
tinsert, tremove, wipe = table.insert, table.remove, function(t) for k in pairs(t) do t[k] = nil end return t end
GameTooltip = NewStub("GameTooltip")
C_Timer = {
    After = function(delay, fn) timers[#timers + 1] = { delay = delay, fn = fn } end,
    NewTicker = function() return { Cancel = function() end } end,
    NewTimer = function() return { Cancel = function() end } end,
}
local function RunTimers()
    local guard = 0
    while #timers > 0 and guard < 50 do
        local pending = timers; timers = {}
        for _, t in ipairs(pending) do t.fn() end
        guard = guard + 1
    end
end
GetServerTime, time, date = function() return now end, function() return now end, os.date
GetTime = function() return clock end
GetLocale = function() return "enUS" end
GetBuildInfo = function() return "12.1.5", "99999", "Oct 13 2026", 120105 end
GetCurrentRegion = function() return 1 end
local money = 50000
GetMoney = function() return money end
UnitName = function() return "Alpha" end
GetRealmName = function() return "Realm" end
UnitGUID = function() return "Player-1-0000" end
UnitClass = function() return "Mage", "MAGE" end
UnitLevel = function() return 90 end
InCombatLockdown = function() return false end
hooksecurefunc = function(target, method, fn)
    if type(target) == "string" then hooks[target] = method else hooks[tostring(method)] = fn end
end
ChatFrame_AddMessageEventFilter = function() end
SlashCmdList = {}
local handlerErrors = {}
geterrorhandler = function() return function(err) handlerErrors[#handlerErrors + 1] = tostring(err) end end
C_AddOns = { GetAddOnMetadata = function() return "12.1.5.1" end, IsAddOnLoaded = function() return false end }
C_CurrencyInfo = { GetCurrencyInfo = function() return nil end, GetCurrencyListSize = function() return 0 end, GetCoinTextureString = function(v) return tostring(v) end }
C_Item = { GetItemInfo = function() return nil end, GetItemInfoInstant = function() return nil end, GetItemCount = function() return 0 end, GetItemQualityColor = function() return 1, 1, 1, "ffffffff" end }
C_Container = { GetContainerNumSlots = function() return 0 end }
Enum = { PlayerInteractionType = { MailInfo = 17 } } -- fixture value; the code reads the enum
HasNewMail = function() return false end
local inbox = { shown = 0, total = 0 }
GetInboxNumItems = function() return inbox.shown, inbox.total end
local invoices = {}
GetInboxInvoiceInfo = function(index) local i = invoices[index]; if i then return i.type, i.item, "Buyer", i.bid, 0, i.deposit, i.consignment end end
GetInboxText = function() return nil end
MailFrame = NewStub("Frame", "MailFrame")
LibStub = function() return { NewDataObject = function(_, _, obj) return obj end, Register = function() end } end

-- ------------------------------------------------------------ saved variables
LiteVaultDB = { ["Alpha-Realm"] = { class = "MAGE", level = 90, gold = money, region = "US" } }
LiteVaultOrder = { "Alpha-Realm" }
LiteVaultMinimapDB = {}

-- ------------------------------------------------------------------- load
local lv = {}
lv.EnsureBorderStyle = function() end -- Theme.lua helper; visuals are not under test
local files = { "Locales/Localization.lua", "Locales/enUS.lua", "Locales/Repair.lua", "Core.lua",
    "GoldTracker/State.lua", "GoldTracker.lua", "Currency.lua", "Modules/MailTracker.lua" }
for _, file in ipairs(files) do
    local chunk, loadError = loadfile(file)
    assert(chunk, loadError)
    local ok, runError = pcall(chunk, "LiteVault", lv)
    assert(ok, file .. ": " .. tostring(runError))
end
lv.PLAYER_KEY = "Alpha-Realm"

local function FramesFor(event)
    local list = {}
    for _, object in ipairs(created) do if object._events[event] and object._scripts.OnEvent then list[#list + 1] = object end end
    return list
end
local function Fire(event, ...)
    for _, frame in ipairs(FramesFor(event)) do frame._scripts.OnEvent(frame, event, ...) end
end

-- Only MailTracker listens for MAIL_CLOSED now (as one of three close signals).
local mailClosedListeners = FramesFor("MAIL_CLOSED")
local mailTrackerFrame
for _, frame in ipairs(FramesFor("UPDATE_PENDING_MAIL")) do mailTrackerFrame = frame end
check(#mailClosedListeners == 1 and mailClosedListeners[1] == mailTrackerFrame, "a legacy handler still registers MAIL_CLOSED directly")
check(mailTrackerFrame and mailTrackerFrame._events.PLAYER_INTERACTION_MANAGER_FRAME_HIDE, "MailTracker does not listen for the interaction-manager close")

-- Core, GoldTracker and Currency each registered one handler before MailTracker loaded.
check(type(lv.MailboxClosedHandlers) == "table" and #lv.MailboxClosedHandlers == 3, "expected 3 mailbox-closed handlers, found " .. tostring(lv.MailboxClosedHandlers and #lv.MailboxClosedHandlers))

-- Startup events: unrelated setup in other modules may need APIs this harness lacks, so each
-- frame runs protected; the modules under test must start cleanly.
local function FireSetup(event, ...)
    for _, frame in ipairs(FramesFor(event)) do
        local ok, err = pcall(frame._scripts.OnEvent, frame, event, ...)
        if not ok then
            local message = tostring(err)
            local critical = frame == mailTrackerFrame or message:match("GoldTracker") or message:match("Currency") or message:match("MailTracker")
            check(not critical, event .. " failed in a module under test: " .. message)
        end
    end
end
FireSetup("ADDON_LOADED", "LiteVault")
FireSetup("PLAYER_LOGIN")
FireSetup("PLAYER_ENTERING_WORLD", false, false)
pcall(RunTimers) -- startup timers belong to unrelated setup
for key in pairs(handlerErrors) do handlerErrors[key] = nil end
timers = {}
check(MailFrame._scripts.OnShow and MailFrame._scripts.OnHide, "mail frame show/hide hooks were not installed")

-- Observe each legacy handler's effect.
local coreRefreshes, currencyScans = 0, 0
local realQueueRefresh = lv.QueueRefresh
lv.QueueRefresh = function(opts) if opts and opts.currentChar then coreRefreshes = coreRefreshes + 1 end end
lv.ScanCurrencies = function() currencyScans = currencyScans + 1 end
local state = lv.GoldTrackerInternal and lv.GoldTrackerInternal.State
check(state and state.mailItemQueue, "GoldTracker state is not reachable")
local function Transactions() return #((LiteVaultDB.goldHistory and LiteVaultDB.goldHistory.transactions) or {}) end

local function OpenMailbox()
    MailFrame._shown = true
    Fire("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", 17)
    if MailFrame._scripts.OnShow then MailFrame._scripts.OnShow(MailFrame) end
    Fire("MAIL_SHOW")
end
local function CloseMailbox(signals)
    MailFrame._shown = false
    for _, signal in ipairs(signals) do
        if signal == "interaction" then Fire("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", 17)
        elseif signal == "frame" then if MailFrame._scripts.OnHide then MailFrame._scripts.OnHide(MailFrame) end
        elseif signal == "event" then Fire("MAIL_CLOSED") end
    end
end

-- ---------------------------------------------- one closure, every signal
OpenMailbox()
local takeMoney = hooks["TakeInboxMoney"]
check(type(takeMoney) == "function", "GoldTracker did not hook TakeInboxMoney")
invoices[1] = { type = "seller", item = "Linen Cloth", bid = 10000, deposit = 0, consignment = 300 }
if takeMoney then takeMoney(1) end
check(#state.mailItemQueue == 1 and state.mailItemQueue[1].expectedGold == 9700, "auction invoice was not queued")
local txBefore = Transactions()
CloseMailbox({ "interaction", "frame", "event" }) -- all three close signals for the same visit
RunTimers()
check(coreRefreshes == 1, "Core refreshed " .. coreRefreshes .. " times for one mailbox closure")
check(currencyScans == 1, "Currency rescanned " .. currencyScans .. " times for one mailbox closure")
check(#state.mailItemQueue == 0 and next(state.processedMailIndices) == nil, "GoldTracker kept the visit's leftover mail queue after closing")
check(Transactions() == txBefore, "closing the mailbox inserted a transaction without a money change")

-- A close signal with no open mailbox does nothing.
CloseMailbox({ "interaction", "frame", "event" })
RunTimers()
check(coreRefreshes == 1 and currencyScans == 1, "a close without an open mailbox ran the handlers")

-- Each later visit is handled once again.
OpenMailbox()
CloseMailbox({ "frame" })
RunTimers()
check(coreRefreshes == 2 and currencyScans == 2, "a second visit closed by the mail frame alone was not handled once")
OpenMailbox()
CloseMailbox({ "event" })
RunTimers()
check(coreRefreshes == 3 and currencyScans == 3, "a visit closed by MAIL_CLOSED alone was not handled once")

-- Reopening before the settle delay keeps the new visit's queue.
OpenMailbox()
if takeMoney then takeMoney(1) end
CloseMailbox({ "interaction" })
OpenMailbox()
if takeMoney then
    invoices[2] = { type = "seller", item = "Silk Cloth", bid = 5000, deposit = 0, consignment = 200 }
    takeMoney(2)
end
RunTimers()
check(#state.mailItemQueue >= 1, "reopening the mailbox lost the new visit's mail queue")

-- Auction mail income is still recorded by PLAYER_MONEY as auction proceeds.
for key in pairs(state.mailItemQueue) do state.mailItemQueue[key] = nil end
for key in pairs(state.processedMailIndices) do state.processedMailIndices[key] = nil end
invoices[3] = { type = "seller", item = "Mageweave Cloth", bid = 20000, deposit = 0, consignment = 1000 }
if takeMoney then takeMoney(3) end
local before = Transactions()
money = money + 19000
clock = clock + 1
Fire("PLAYER_MONEY")
RunTimers()
local history = LiteVaultDB.goldHistory and LiteVaultDB.goldHistory.transactions or {}
local newest = history[1]
check(Transactions() == before + 1 and newest and newest.source == "auction" and newest.amount == 19000, "auction mail gold was not recorded once as auction proceeds")
check(#state.mailItemQueue == 0, "the auction sale stayed queued after its gold arrived")
CloseMailbox({ "interaction" })
RunTimers()
check(Transactions() == before + 1, "closing the mailbox recorded the auction sale a second time")

check(#handlerErrors == 0, "a mailbox-closed handler raised: " .. tostring(handlerErrors[1]))
lv.QueueRefresh = realQueueRefresh
if #failures > 0 then
    for _, message in ipairs(failures) do print("FAIL: " .. message) end
    error(string.format("%d of %d mailbox handler checks failed", #failures, checks))
end
print(string.format("Mailbox-closed handlers (Core, Currency, GoldTracker, MailTracker): %d checks passed", checks))
