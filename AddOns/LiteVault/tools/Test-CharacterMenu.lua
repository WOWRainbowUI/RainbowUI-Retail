-- Behavioral tests for character management (Lua 5.1): the character card's
-- right-click menu (Favorite / Ignore-Restore / Delete / Cancel) and the slimmed
-- Actions menu (Bags / Gear). Loads the real locale files, Theme, Utils, UI Builders
-- and List.lua with a minimal WoW API harness, builds the character list, and
-- drives the same handlers a player uses.
-- Run from the addon root:  lua5.1 tools/Test-CharacterMenu.lua

local failures, checks = {}, 0
local function check(condition, message)
    checks = checks + 1
    if not condition then failures[#failures + 1] = message end
end

-- ---------------------------------------------------------------- WoW harness
local now = 1800000000
local created, timers = {}, {}
local stubMeta = {}
local function NewStub(kind, name, parent)
    local object = setmetatable({ _kind = kind, _scripts = {}, _events = {}, _shown = true, _parent = parent, _mouse = true }, stubMeta)
    created[#created + 1] = object
    if name then _G[name] = object end
    return object
end
local numericGetters = {
    GetFrameLevel = 1, GetStringWidth = 40, GetWidth = 100, GetHeight = 20, GetNumPoints = 0,
    GetLeft = 0, GetRight = 0, GetTop = 0, GetBottom = 0, GetAlpha = 1, GetScale = 1, GetEffectiveScale = 1,
    GetVerticalScroll = 0, GetVerticalScrollRange = 0, GetStringHeight = 12, GetLineHeight = 12, GetNumLines = 1,
}
local creators = { CreateFontString = true, CreateTexture = true, CreateMaskTexture = true, CreateAnimationGroup = true, CreateLine = true, CreateAnimation = true }
stubMeta.__index = function(self, key)
    if numericGetters[key] then return function() return numericGetters[key] end end
    if creators[key] then
        return function(owner, name, layer, template)
            local child = NewStub(key, nil, owner)
            child._template = template
            return child
        end
    end
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
    if key == "SetText" then
        return function(owner, text)
            owner._text = text
            -- Approximate rendered width: 8px per visible character (colour codes excluded).
            local plain = tostring(text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            owner._textWidth = #plain * 8
        end
    end
    if key == "GetUnboundedStringWidth" then return function(owner) return owner._textWidth or 0 end end
    if key == "SetWidth" then return function(owner, width) owner._width = width end end
    if key == "SetSize" then return function(owner, width, height) owner._width, owner._height = width, height end end
    if key == "SetWordWrap" then return function(owner, wrap) owner._wrap = wrap end end
    if key == "SetMouseMotionEnabled" then return function(owner, enabled) owner._mouseMotion = enabled end end
    if key == "SetMouseClickEnabled" then return function(owner, enabled) owner._mouseClick = enabled end end
    if key == "SetFont" then return function(owner, font, size, flags) owner._fontSize, owner._fontFlags = size, flags end end
    if key == "GetText" then return function(owner) return owner._text end end
    if key == "Show" then return function(owner) owner._shown = true end end
    if key == "Hide" then return function(owner) owner._shown = false end end
    if key == "SetShown" then return function(owner, shown) owner._shown = shown and true or false end end
    if key == "IsShown" or key == "IsVisible" then return function(owner) return owner._shown end end
    if key == "EnableMouse" then return function(owner, enabled) owner._mouse = enabled and true or false end end
    if key == "IsMouseEnabled" then return function(owner) return owner._mouse end end
    if key == "GetParent" then return function(owner) return owner._parent end end
    if key == "SetParent" then return function(owner, parent) owner._parent = parent end end
    if key == "IsMouseOver" then return function() return false end end
    if key == "GetFont" then return function() return "Fonts\\FRIZQT__.TTF", 12, "" end end
    if key == "GetTextColor" then return function() return 1, 1, 1, 1 end end
    if key == "GetBackdropColor" or key == "GetBackdropBorderColor" or key == "GetVertexColor" then return function() return 1, 1, 1, 1 end end
    if key == "GetPoint" then return function() return "TOPLEFT", nil, "TOPLEFT", 0, 0 end end
    if key == "GetName" then return function() return nil end end
    if key == "SetAtlas" then return function(owner, atlas) owner._atlas = atlas end end
    if key == "SetPoint" then
        return function(owner, ...)
            owner._point = { ... }
            owner._points = owner._points or {}
            owner._points[#owner._points + 1] = { ... }
        end
    end
    if key == "ClearAllPoints" then return function(owner) owner._point, owner._points = nil, nil end end
    -- WoW widget methods are PascalCase; lowercase keys are addon fields and stay nil.
    if type(key) == "string" and key:match("^%u") then return function() return nil end end
    return nil
end

CreateFrame = function(kind, name, parent, template)
    local frame = NewStub(kind, name, parent)
    -- Blizzard check-button templates provide a .Text font string child.
    if type(template) == "string" and template:find("CheckButtonTemplate", 1, true) then frame.Text = NewStub("FontString", nil, frame) end
    return frame
end
UIParent = NewStub("UIParent")
UISpecialFrames = {}
tinsert, tremove, wipe = table.insert, table.remove, function(t) for k in pairs(t) do t[k] = nil end return t end
GameTooltip = NewStub("GameTooltip")
C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end, NewTicker = function() return { Cancel = function() end } end, NewTimer = function() return { Cancel = function() end } end }
GetServerTime, time, date = function() return now end, function() return now end, os.date
GetLocale = function() return "enUS" end
GetTime = function() return 100 end
GetMoney = function() return 0 end
UnitName = function() return "Alpha" end
UnitClass = function() return "Mage", "MAGE" end
UnitLevel = function() return 90 end
UnitRace = function() return "Human", "Human" end
UnitSex = function() return 2 end
GetRealmName = function() return "Realm" end
InCombatLockdown = function() return false end
SetPortraitTexture = function() end
SetPortraitToTexture = function() end
hooksecurefunc = function() end
SlashCmdList = {}
YES, NO, CANCEL, UNKNOWN = "Yes", "No", "Cancel", "Unknown"
C_ClassColor = { GetClassColor = function()
    return { r = 1, g = 1, b = 1, WrapTextInColorCode = function(_, text) return text end, GenerateHexColor = function() return "ffffffff" end }
end }
RAID_CLASS_COLORS = setmetatable({}, { __index = function() return { r = 1, g = 1, b = 1, colorStr = "ffffffff" } end })
C_CurrencyInfo = { GetCurrencyInfo = function() return nil end, GetCoinTextureString = function(v) return tostring(v) end }
C_Item = { GetItemIconByID = function() return 0 end, GetItemCount = function() return 0 end,
    GetItemQualityColor = function() return 1, 1, 1, "ffffffff" end }
C_AddOns = { IsAddOnLoaded = function() return false end, GetAddOnMetadata = function() return "12.1.5.1" end }
GetCoinTextureString = function(v) return tostring(v) end
BreakUpLargeNumbers = function(v) return tostring(v) end
CLASS_ICON_TCOORDS = setmetatable({}, { __index = function() return { 0, 1, 0, 1 } end })
local knownAtlases = { ["PetJournal-FavoritesIcon"] = { width = 32, height = 32 }, ["ui-hud-minimap-mail-up"] = { width = 20, height = 15 } }
-- Mail API test doubles (values are fixtures, not claims about the live client).
Enum = { PlayerInteractionType = { MailInfo = 17 } }
MAIL_LABEL, HAVE_MAIL, INBOX = "Mail", "You have unread mail", "Inbox"
local mailFixture = { hasNew = false, shown = nil, total = nil }
HasNewMail = function() return mailFixture.hasNew end
GetInboxNumItems = function() return mailFixture.shown, mailFixture.total end
C_Texture = { GetAtlasInfo = function(atlas) return knownAtlases[atlas] end }

StaticPopupDialogs = {}
local popups = {}
StaticPopup_Show = function(which, text1, text2, data) popups[#popups + 1] = { which = which, text1 = text1, data = data } end

local lastMenu
MenuUtil = { CreateContextMenu = function(owner, generator)
    local menu = { owner = owner, buttons = {} }
    local root = { CreateButton = function(_, text, callback) menu.buttons[#menu.buttons + 1] = { text = text, callback = callback } end }
    generator(owner, root)
    lastMenu = menu
end }

-- ------------------------------------------------------------ saved variables
local function NewCharacter(class, gold) return { class = class, level = 90, gold = gold, lastLogin = now, region = "US" } end
LiteVaultOrder = { "Alpha-Realm", "Beta-Realm", "Gamma-Realm", "Delta-Realm" }
LiteVaultDB = {
    ["Alpha-Realm"] = NewCharacter("MAGE", 1000),
    ["Beta-Realm"] = NewCharacter("PRIEST", 10),
    ["Gamma-Realm"] = NewCharacter("WARRIOR", 500),
    ["Delta-Realm"] = NewCharacter("ROGUE", 300),
    ["Warband Bank"] = { class = "Bank", gold = 50, region = "US" },
    characterSortMode = "gold",
}
LiteVaultMinimapDB = {}

-- ------------------------------------------------------------------- load
local lv = { PLAYER_KEY = "Alpha-Realm", REGION = "US" }
lv.GetActiveCrestDefinitions = function() return {} end
lv.ResolveActiveCrestCurrencyID = function() return nil end
lv.GetActiveUpgradeSeasonKey = function() return "midnight_s2" end
lv.GetActiveCatalystCurrencyID = function() return 3465 end
lv.GetActiveSparkItemID = function() return 274476 end
lv.ASCENDANT_VOIDSHARD_ITEM_ID, lv.ASCENDANT_VOIDCORE_ITEM_ID = 268650, 268552
for _, file in ipairs({ "Locales/Localization.lua", "Locales/enUS.lua", "Locales/Repair.lua", "Theme.lua", "Utils.lua", "UI/Builders.lua", "Modules/MailTracker.lua", "List.lua" }) do
    assert(loadfile(file))("LiteVault", lv)
end
local L = lv.L
local updateUICalls = 0
lv.UpdateUI = function() updateUICalls = updateUICalls + 1; lv.UpdateList() end
lv.CloseAuxPanels = function() end

local window = NewStub("Frame", "LiteVaultWindow")
lv.InitList(window, window)
for _ = 1, 3 do
    local pending = timers; timers = {}
    for _, fn in ipairs(pending) do fn() end
end
lv.UpdateList()

-- ----------------------------------------------------------------- helpers
local function VisibleRows()
    local list = {}
    for _, object in ipairs(created) do
        if object.charName and object.dataBox and object.optionsBtn and object._shown then list[#list + 1] = object end
    end
    return list
end
local function RowFor(charKey)
    for _, row in ipairs(VisibleRows()) do if row.charName == charKey then return row end end
end
local function RightClick(charKey)
    lastMenu = nil
    local row = RowFor(charKey)
    if not row then return nil end
    row._scripts.OnMouseUp(row, "RightButton")
    return lastMenu
end
local function Labels(menu)
    local labels = {}
    for _, button in ipairs(menu and menu.buttons or {}) do labels[#labels + 1] = button.text end
    return table.concat(labels, " | ")
end
local function Click(menu, label)
    for _, button in ipairs(menu and menu.buttons or {}) do
        if button.text == label then button.callback(); return true end
    end
    return false
end
local function OrderIndex(charKey)
    for index, key in ipairs(LiteVaultOrder) do if key == charKey then return index end end
end
local GOLD_UNFAVORITE = "|cffffd100" .. L["BUTTON_UNFAVORITE"] .. "|r"

-- ------------------------------------------------------------- Actions menu
local alpha = RowFor("Alpha-Realm")
check(alpha ~= nil, "Alpha's character card was not built")
if alpha then
    check(alpha.favBtn == nil and alpha.actionBtn == nil and alpha.deleteBtn == nil, "Favorite / Ignore / Delete buttons still exist on the card")
    local actionLabels = {}
    for _, object in ipairs(created) do
        if object._parent == alpha.actionMenu and object.text and object.text._text then actionLabels[#actionLabels + 1] = object.text._text end
    end
    table.sort(actionLabels)
    check(table.concat(actionLabels, ",") == table.concat({ L["BUTTON_BAGS"], L["BUTTON_GEAR"] }, ","), "Actions menu entries are: " .. table.concat(actionLabels, ","))
    check(alpha.bagsActionBtn._shown and alpha.gearActionBtn._shown and alpha.optionsBtn._shown, "Actions button, Bags or Gear is hidden in normal mode")
end

-- ------------------------------------------------- right-click: four options
local expectedFresh = table.concat({ L["BUTTON_FAVORITE"], L["BUTTON_IGNORE"], L["BUTTON_DELETE"], CANCEL }, " | ")
local menu = RightClick("Beta-Realm")
check(menu ~= nil, "right-click on Beta opened no menu")
check(Labels(menu) == expectedFresh, "right-click options are: " .. Labels(menu))

-- Favorite: persists, re-sorts and refreshes immediately.
check(OrderIndex("Beta-Realm") == 4, "Beta (least gold) should sort last before favoriting")
local callsBefore = updateUICalls
check(Click(menu, L["BUTTON_FAVORITE"]), "Favorite entry could not be clicked")
check(LiteVaultDB["Beta-Realm"].isFavorite == true, "Favorite did not set isFavorite")
check(updateUICalls > callsBefore, "Favorite did not refresh the UI")
check(OrderIndex("Alpha-Realm") == 1 and OrderIndex("Beta-Realm") == 2, "favorited Beta does not sort right after the current character")
menu = RightClick("Beta-Realm")
check(menu and menu.buttons[1] and menu.buttons[1].text == GOLD_UNFAVORITE, "favorited character does not show a gold Unfavorite entry")
check(Labels(menu) == table.concat({ GOLD_UNFAVORITE, L["BUTTON_IGNORE"], L["BUTTON_DELETE"], CANCEL }, " | "), "favorited right-click options are: " .. Labels(menu))
-- Favorite star: shown beside the favorited name only, race/spec line moves after it.
local function StarState()
    local shownOn = {}
    for _, row in ipairs(VisibleRows()) do
        if row.favoriteStar and row.favoriteStar._shown then shownOn[#shownOn + 1] = row.charName end
    end
    table.sort(shownOn)
    return table.concat(shownOn, ",")
end
-- Race/spec has its own fixed line: one anchor to the card at (105, -42), never to the name or star.
local function IdentityOnOwnLine(charKey)
    local row = RowFor(charKey)
    local points = row and row.identityText and row.identityText._points
    local p = points and points[1]
    return (points and #points == 1 and p[1] == "TOPLEFT" and p[2] == 105 and p[3] == -42) and true or false
end
local beta = RowFor("Beta-Realm")
local betaStar = beta and beta.favoriteStar
check(betaStar ~= nil, "character cards have no favorite star")
check(StarState() == "Beta-Realm", "after favoriting, stars are shown on: [" .. StarState() .. "]")
check(betaStar and betaStar._kind == "CreateTexture" and betaStar._atlas == "PetJournal-FavoritesIcon", "favorite star does not use Blizzard's gold favorites atlas")
check(betaStar and next(betaStar._scripts) == nil, "favorite star has click or mouse handlers")
check(betaStar and betaStar._point and betaStar._point[1] == "LEFT" and betaStar._point[2] == beta.nameText and betaStar._point[3] == "RIGHT", "star is not placed directly after the name")
check(IdentityOnOwnLine("Beta-Realm"), "favorited card's race/spec line is not on its own fixed line")
check(IdentityOnOwnLine("Gamma-Realm"), "non-favorite card's race/spec line is not on its own fixed line")
check(Click(menu, GOLD_UNFAVORITE), "Unfavorite entry could not be clicked")
check(LiteVaultDB["Beta-Realm"].isFavorite == false, "Unfavorite did not clear isFavorite")
check(OrderIndex("Beta-Realm") == 4, "unfavorited Beta did not return to gold order")
check(StarState() == "", "after unfavoriting, stars are still shown on: [" .. StarState() .. "]")
check(IdentityOnOwnLine("Beta-Realm"), "race/spec line moved after unfavoriting")
-- The row Beta occupied while favorited (row 2) now shows another character and no star.
local secondRow = VisibleRows()[2]
check(secondRow and secondRow.favoriteStar and secondRow.charName ~= "Beta-Realm" and not secondRow.favoriteStar._shown, "reused card kept a stale favorite star")

-- Persistence: a favorite loaded from SavedVariables (reload / reopen) shows its star,
-- including on the current character and after switching characters.
LiteVaultDB["Gamma-Realm"].isFavorite = true
LiteVaultDB["Alpha-Realm"].isFavorite = true
lv.UpdateList()
check(StarState() == "Alpha-Realm,Gamma-Realm", "saved favorites do not show stars after a refresh: [" .. StarState() .. "]")
lv.PLAYER_KEY = "Gamma-Realm"
lv.UpdateList()
check(StarState() == "Alpha-Realm,Gamma-Realm" and OrderIndex("Gamma-Realm") == 1, "stars or order changed after switching characters: [" .. StarState() .. "]")
lv.PLAYER_KEY = "Alpha-Realm"
LiteVaultDB["Gamma-Realm"].isFavorite, LiteVaultDB["Alpha-Realm"].isFavorite = nil, nil
lv.UpdateList()
check(StarState() == "", "stars remain after favorites were cleared: [" .. StarState() .. "]")

-- Ignore / Restore.
menu = RightClick("Gamma-Realm")
callsBefore = updateUICalls
check(Click(menu, L["BUTTON_IGNORE"]), "Ignore entry could not be clicked")
check(LiteVaultDB["Gamma-Realm"].isIgnored == true and updateUICalls > callsBefore, "Ignore did not set isIgnored and refresh")
check(RowFor("Gamma-Realm") == nil, "ignored Gamma is still listed in normal mode")
local manageBtn = lv.manageBtn
check(manageBtn and manageBtn._scripts.OnClick, "Manage button not found")
if manageBtn and manageBtn._scripts.OnClick then
    manageBtn._scripts.OnClick(manageBtn)
    local gamma = RowFor("Gamma-Realm")
    check(gamma ~= nil, "ignored Gamma is not listed in manage mode")
    check(gamma and not gamma.optionsBtn._shown, "empty Actions button is shown in manage mode")
    menu = RightClick("Gamma-Realm")
    check(Labels(menu) == table.concat({ L["BUTTON_FAVORITE"], L["BUTTON_RESTORE"], L["BUTTON_DELETE"], CANCEL }, " | "), "ignored right-click options are: " .. Labels(menu))
    check(Click(menu, L["BUTTON_RESTORE"]), "Restore entry could not be clicked")
    check(LiteVaultDB["Gamma-Realm"].isIgnored == false, "Restore did not clear isIgnored")
    manageBtn._scripts.OnClick(manageBtn)
    check(RowFor("Gamma-Realm") ~= nil, "restored Gamma is not listed again in normal mode")
end

-- Delete requires confirmation; Cancel does nothing.
menu = RightClick("Delta-Realm")
local popupCount = #popups
check(Click(menu, L["BUTTON_DELETE"]), "Delete entry could not be clicked")
check(LiteVaultDB["Delta-Realm"] ~= nil, "Delete removed the character without confirmation")
local popup = popups[popupCount + 1]
check(popup and popup.which == "LITEVAULT_CONFIRM_DELETE_CHARACTER" and popup.text1 == "Delta" and popup.data == "Delta-Realm", "Delete did not open the confirmation popup for Delta")
local dialog = StaticPopupDialogs["LITEVAULT_CONFIRM_DELETE_CHARACTER"]
check(dialog and dialog.OnAccept, "delete confirmation dialog is not registered")
menu = RightClick("Beta-Realm")
local snapshot = { fav = LiteVaultDB["Beta-Realm"].isFavorite, ignored = LiteVaultDB["Beta-Realm"].isIgnored }
check(Click(menu, CANCEL), "Cancel entry could not be clicked")
check(LiteVaultDB["Beta-Realm"].isFavorite == snapshot.fav and LiteVaultDB["Beta-Realm"].isIgnored == snapshot.ignored and #popups == popupCount + 1, "Cancel changed state or opened a popup")
if dialog and dialog.OnAccept then
    dialog.OnAccept(nil, "Delta-Realm")
    check(LiteVaultDB["Delta-Realm"] == nil and OrderIndex("Delta-Realm") == nil and RowFor("Delta-Realm") == nil, "confirmed delete did not remove Delta")
end

-- The Warband Bank exposes no character management. SyncOrderList keeps it out of
-- the character list, so point a real card at the bank record to exercise the guard.
local bankListed = false
for _, row in ipairs(VisibleRows()) do if row.charName == "Warband Bank" then bankListed = true end end
check(not bankListed and OrderIndex("Warband Bank") == nil, "Warband Bank is listed as a character card")
local probeRow = RowFor("Alpha-Realm")
if probeRow then
    probeRow.charName = "Warband Bank"
    lastMenu = nil
    probeRow._scripts.OnMouseUp(probeRow, "RightButton")
    check(lastMenu == nil, "right-clicking a Warband Bank card opened a menu")
    probeRow.charName = "Alpha-Realm"
end

-- ------------------------------------------- card header: race/spec on its own line
local GOLD = "|cffffd100%s|r"
LiteVaultDB["Alpha-Realm"].race, LiteVaultDB["Alpha-Realm"].specName = "Human", "Fire"
LiteVaultDB["Beta-Realm"].race, LiteVaultDB["Beta-Realm"].specName = "Scourge", nil
LiteVaultDB["Gamma-Realm"].race, LiteVaultDB["Gamma-Realm"].specName = nil, "Arms"
local LONG = "Bartholomewsson-Twisting Nether of the Eastern Kingdoms"
LiteVaultDB[LONG] = NewCharacter("PALADIN", 5)
LiteVaultDB[LONG].race, LiteVaultDB[LONG].specName, LiteVaultDB[LONG].isFavorite = "Lightforged Draenei", "Retribution", true
LiteVaultDB["Empty-Realm"] = NewCharacter("DRUID", 1)
LiteVaultOrder[#LiteVaultOrder + 1] = LONG
LiteVaultOrder[#LiteVaultOrder + 1] = "Empty-Realm"
lv.UpdateList()

local function Header(charKey)
    local row = RowFor(charKey)
    if not row then return nil end
    return { row = row, identity = row.identityText._text, nameWidth = row.nameText._width, star = row.favoriteStar }
end
local expectedIdentity = {
    ["Alpha-Realm"] = string.format(GOLD, "Human | Fire"),
    ["Beta-Realm"] = string.format(GOLD, "Undead"),
    ["Gamma-Realm"] = string.format(GOLD, "Arms"),
    [LONG] = string.format(GOLD, "Lightforged Draenei | Retribution"),
    ["Empty-Realm"] = "",
}
for charKey, expected in pairs(expectedIdentity) do
    local header = Header(charKey)
    check(header ~= nil, charKey .. " card was not built for the layout check")
    if header then
        check(header.identity == expected, string.format("%s race/spec text is %q, expected %q", charKey, tostring(header.identity), expected))
        check(IdentityOnOwnLine(charKey), charKey .. " race/spec line is not on its own fixed line")
        local id = header.row.identityText
        check(id._width == 370 and id._height == 14 and id._wrap == false, charKey .. " race/spec line is not a single 370px line")
        check(id._template == "GameFontNormalSmall" and header.row.nameText._template == "GameFontNormalHuge",
            charKey .. " race/spec does not use the smaller font under the name")
        -- Stub GetFont reports 12 for every font object, so the bumped size reads as 13.
        check(id._fontSize == 13 and id._fontFlags == "OUTLINE", charKey .. " race/spec font is not one pixel above its base size")
        local namePoint = header.row.nameText._points and header.row.nameText._points[1]
        check(namePoint and namePoint[1] == "BOTTOMLEFT" and namePoint[2] == id and namePoint[3] == "TOPLEFT" and namePoint[5] == 2,
            charKey .. " name is not placed directly above the race/spec line")
        check(header.row.nameText._wrap == false, charKey .. " name line can wrap onto the race/spec line")
        local boxTop
        for _, p in ipairs(header.row.dataBox._points or {}) do if p[1] == "TOPLEFT" then boxTop = p[3] end end
        check(boxTop == -58 and (-42 - 14) > boxTop, charKey .. " race/spec line overlaps the data box")
        check(header.nameWidth and header.nameWidth <= 370, charKey .. " name line can run past the card")
    end
end
-- Short names keep their natural width (so the star sits right after the name);
-- an overlong name + realm is capped so name and star stay inside the card.
local alphaHeader, longHeader = Header("Alpha-Realm"), Header(LONG)
check(alphaHeader and alphaHeader.nameWidth == RowFor("Alpha-Realm").nameText._textWidth + 2, "short name does not keep its natural width")
check(longHeader and longHeader.nameWidth == 370 - 22 and longHeader.star._shown, "long favorited name is not capped to leave room for the star")
check(longHeader and longHeader.star._point and longHeader.star._point[2] == longHeader.row.nameText, "favorite star is not on the name line")
check(longHeader and longHeader.identity == expectedIdentity[LONG], "long name changed the race/spec line")
-- Manage mode uses the same card layout.
LiteVaultDB["Gamma-Realm"].isIgnored = true
if manageBtn and manageBtn._scripts.OnClick then
    manageBtn._scripts.OnClick(manageBtn)
    local ignored = Header("Gamma-Realm")
    check(ignored and ignored.identity == expectedIdentity["Gamma-Realm"] and IdentityOnOwnLine("Gamma-Realm"), "Manage mode card layout differs")
    manageBtn._scripts.OnClick(manageBtn)
end
LiteVaultDB["Gamma-Realm"].isIgnored = false

-- ----------------------------------------------------------------- mail tracking
GameTooltip._lines = {}
GameTooltip.SetText = function(self, text) self._lines = { text } end
GameTooltip.AddLine = function(self, text) self._lines[#self._lines + 1] = text end
MailFrame = NewStub("Frame", "MailFrame")
local mailEvents
for _, object in ipairs(created) do if object._events.UPDATE_PENDING_MAIL then mailEvents = object end end
check(mailEvents and mailEvents._events.MAIL_INBOX_UPDATE and mailEvents._events.MAIL_SHOW, "mail tracker events are not registered")
local function MailEvent(event, ...) mailEvents._scripts.OnEvent(mailEvents, event, ...) end
local function Indicator(charKey) local row = RowFor(charKey); return row and row.mailIndicator end
local function IndicatorShown(charKey) local i = Indicator(charKey); return (i and i._shown) and true or false end
local function Mail(charKey) return LiteVaultDB[charKey] and LiteVaultDB[charKey].mail or {} end
local function Tooltip(charKey)
    GameTooltip._lines = {}
    lv.ShowCharacterMailTooltip(Indicator(charKey), charKey)
    return table.concat(GameTooltip._lines, " / ")
end
local OFFLINE_NOTE = L["TEXT_MAIL_OFFLINE_NOTE"]

lv.PLAYER_KEY = "Alpha-Realm"
lv.UpdateList()
check(not IndicatorShown("Alpha-Realm") and not IndicatorShown("Beta-Realm"), "mail indicator shown before any mail was observed")
MailEvent("PLAYER_ENTERING_WORLD")
check(Mail("Alpha-Realm").hasNew == nil and Mail("Alpha-Realm").count == nil, "HasNewMail() false at login created a mail status")
check(MailFrame._scripts.OnHide ~= nil, "mail frame close hook was not installed")

-- New mail arrives: indicator on; a later HasNewMail() false must not clear it.
mailFixture.hasNew = true
MailEvent("UPDATE_PENDING_MAIL")
check(Mail("Alpha-Realm").hasNew == true and IndicatorShown("Alpha-Realm"), "new mail did not show the indicator")
check(Tooltip("Alpha-Realm") == "Mail / You have unread mail / " .. string.format(L["TEXT_MAIL_LAST_CHECKED_FMT"], date("%Y-%m-%d %H:%M", now)),
    "live new-mail tooltip is: " .. Tooltip("Alpha-Realm"))
mailFixture.hasNew = false
MailEvent("UPDATE_PENDING_MAIL")
MailEvent("PLAYER_ENTERING_WORLD")
check(Mail("Alpha-Realm").hasNew == true and IndicatorShown("Alpha-Realm"), "HasNewMail() false cleared the mail status")

-- Mailbox visit: an empty list before the inbox loads proves nothing.
MailEvent("MAIL_SHOW")
mailFixture.shown, mailFixture.total = 0, 0
MailEvent("MAIL_INBOX_UPDATE")
check(Mail("Alpha-Realm").hasNew == true and Mail("Alpha-Realm").count == nil and IndicatorShown("Alpha-Realm"), "an empty inbox result before the list loaded cleared the status")
mailFixture.shown, mailFixture.total = 3, 3
MailEvent("MAIL_INBOX_UPDATE")
check(Mail("Alpha-Realm").count == 3 and Mail("Alpha-Realm").hasNew == nil and IndicatorShown("Alpha-Realm"), "loaded inbox count was not captured")
check(Tooltip("Alpha-Realm"):find("Inbox: 3", 1, true) and not Tooltip("Alpha-Realm"):find(OFFLINE_NOTE, 1, true), "inbox tooltip is: " .. Tooltip("Alpha-Realm"))
-- Taking everything: zero is accepted only when the mailbox closes.
mailFixture.shown, mailFixture.total = 0, 0
MailEvent("MAIL_INBOX_UPDATE")
check(Mail("Alpha-Realm").count == 3, "an empty result was accepted before the mailbox closed")
MailEvent("MAIL_CLOSED")
check(Mail("Alpha-Realm").count == 0 and not IndicatorShown("Alpha-Realm"), "an emptied mailbox did not clear the indicator at close")

-- Close via the interaction-frame event, and via the mail frame hook.
MailEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", 17)
mailFixture.shown, mailFixture.total = 2, 2
MailEvent("MAIL_INBOX_UPDATE")
MailEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", 17)
check(Mail("Alpha-Realm").count == 2 and IndicatorShown("Alpha-Realm"), "mailbox opened/closed through interaction events was not tracked")
MailEvent("MAIL_SHOW")
mailFixture.shown, mailFixture.total = 0, 0
MailFrame._scripts.OnHide(MailFrame) -- closed before any inbox list arrived
check(Mail("Alpha-Realm").count == 2, "a mailbox visit without an inbox load cleared the count")
-- Stored inbox data outside an open mailbox is not trusted.
mailFixture.shown, mailFixture.total = 9, 9
MailEvent("MAIL_INBOX_UPDATE")
check(Mail("Alpha-Realm").count == 2, "inbox data outside an open mailbox was trusted")
-- The total includes mail beyond the loaded list.
MailEvent("MAIL_SHOW")
mailFixture.shown, mailFixture.total = 50, 63
MailEvent("MAIL_INBOX_UPDATE")
MailEvent("MAIL_CLOSED")
check(Mail("Alpha-Realm").count == 63, "total inbox count was not used")

-- Other characters: last known status, clearly labelled; records are per character.
lv.PLAYER_KEY = "Beta-Realm"
lv.UpdateList()
check(IndicatorShown("Alpha-Realm"), "last known mail status is not shown for an offline character")
check(Tooltip("Alpha-Realm"):find(OFFLINE_NOTE, 1, true) and Tooltip("Alpha-Realm"):find("Inbox: 63", 1, true), "offline tooltip is: " .. Tooltip("Alpha-Realm"))
mailFixture.hasNew = true
MailEvent("UPDATE_PENDING_MAIL")
check(Mail("Beta-Realm").hasNew == true and Mail("Alpha-Realm").count == 63 and Mail("Alpha-Realm").hasNew == nil, "Beta's mail changed Alpha's record")
check(not Tooltip("Beta-Realm"):find(OFFLINE_NOTE, 1, true), "the logged-in character's tooltip says last known")
LiteVaultDB.declinedCharacters = { ["Empty-Realm"] = true }
lv.PLAYER_KEY = "Empty-Realm"
MailEvent("UPDATE_PENDING_MAIL")
check(LiteVaultDB["Empty-Realm"].mail == nil, "mail status was saved for a declined character")
LiteVaultDB.declinedCharacters = nil
mailFixture.hasNew = false
lv.PLAYER_KEY = "Alpha-Realm"

-- Persistence: a reload rebuilds the cards from SavedVariables.
lv.UpdateList()
check(IndicatorShown("Alpha-Realm") and IndicatorShown("Beta-Realm") and not IndicatorShown("Gamma-Realm") and not IndicatorShown("Empty-Realm"), "saved mail status was not restored")

-- Layout: inside the data box, just in front of the right-aligned gold amount; hover only.
local alphaRow = RowFor("Alpha-Realm")
local alphaMail = Indicator("Alpha-Realm")
local function GoldAnchorOK(row, indicator)
    local point = indicator and indicator._point
    local goldWidth = row and row.goldText and row.goldText._textWidth
    return point and goldWidth and goldWidth > 0 and point[1] == "RIGHT" and point[2] == row.goldText and point[3] == "RIGHT"
        and point[4] == -(math.ceil(goldWidth) + 4) and point[5] == 0
end
check(alphaMail and alphaMail._parent == alphaRow.dataBox, "mail indicator is not inside the card's data box")
check(GoldAnchorOK(alphaRow, alphaMail), "mail indicator is not just in front of the gold amount")
check(alphaMail and alphaMail._height == 18 and alphaMail._width == 18, "mail indicator slot is not 18px")
-- The envelope follows the amount when the gold total changes length.
local savedGold = LiteVaultDB["Alpha-Realm"].gold
local shortWidth = alphaRow.goldText._textWidth
LiteVaultDB["Alpha-Realm"].gold = 123456789012
lv.UpdateList()
alphaRow, alphaMail = RowFor("Alpha-Realm"), Indicator("Alpha-Realm")
check(GoldAnchorOK(alphaRow, alphaMail) and alphaRow.goldText._textWidth > shortWidth, "mail indicator did not follow a longer gold amount")
LiteVaultDB["Alpha-Realm"].gold = savedGold
lv.UpdateList()
alphaRow, alphaMail = RowFor("Alpha-Realm"), Indicator("Alpha-Realm")
-- Its name-line slot is gone: nothing mail-related is anchored to the card header any more.
check(alphaMail and alphaMail._point and alphaMail._point[2] ~= alphaRow, "mail indicator is still anchored to the name line")
check(alphaMail and alphaMail._mouseMotion == true and alphaMail._mouseClick == false and alphaMail.icon._atlas == "ui-hud-minimap-mail-up", "mail indicator is clickable or does not use Blizzard's mail envelope")
check(alphaMail and alphaMail.icon._width == 18 and alphaMail.icon._height == 13.5 and alphaMail.icon._point and alphaMail.icon._point[1] == "CENTER", "mail envelope is stretched or not centred in its 18px slot")
check(alphaMail and alphaMail._scripts.OnEnter and alphaMail._scripts.OnMouseUp == nil, "mail indicator has no tooltip or captures clicks")
LiteVaultDB[LONG].mail = { hasNew = true, checkedAt = now }
lv.UpdateList()
check(Header(LONG).nameWidth == 370 - 22, "a long name with mail lost width to the old name-line mail slot")
check(RightClick("Alpha-Realm") ~= nil, "right-click menu stopped working on a card with mail")

if #failures > 0 then
    for _, message in ipairs(failures) do print("FAIL: " .. message) end
    error(string.format("%d of %d character menu checks failed", #failures, checks))
end
print(string.format("Character management menus: %d checks passed", checks))
