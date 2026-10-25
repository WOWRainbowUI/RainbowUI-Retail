-- MailTracker.lua - per-character mail status for the character cards.
--
-- Blizzard only exposes mail for the logged-in character:
--   * HasNewMail() reports new mail received since the last mailbox visit. Its false
--     value does NOT mean the mailbox is empty, so it may set the "new mail" flag but
--     never clears anything.
--   * The inbox contents (GetInboxNumItems) are loaded only while a mailbox is open and
--     are reported by MAIL_INBOX_UPDATE. Outside an open mailbox the client returns its
--     stored copy, which is not proof of anything, so counts are captured only during a
--     mailbox visit. A count of zero is accepted only when the mailbox closes after the
--     inbox list was delivered, so an empty result before the list loads is never taken
--     as an empty mailbox.
-- Each character keeps its last known status in LiteVaultDB[charKey].mail. Other
-- characters' status is shown as last known, never as live.
local addonName, lv = ...
local L = lv.L

-- No numeric fallback: without the enum, MAIL_SHOW and the MailFrame hook still cover the mailbox.
local MAIL_INTERACTION_TYPE = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.MailInfo

local session = {
    mailboxOpen = false,
    inboxLoaded = false, -- MAIL_INBOX_UPDATE observed during the current mailbox visit
}

local function Now()
    return (GetServerTime and GetServerTime()) or time()
end

local function GetTrackedRecord()
    local charKey = lv.PLAYER_KEY
    if not (LiteVaultDB and charKey) then return nil end
    if LiteVaultDB.declinedCharacters and LiteVaultDB.declinedCharacters[charKey] then return nil end
    local data = LiteVaultDB[charKey]
    if type(data) ~= "table" or not data.class or data.class == "Bank" then return nil end
    data.mail = type(data.mail) == "table" and data.mail or {}
    return data.mail
end

local function RefreshCards()
    if lv.QueueRefresh then
        lv.QueueRefresh({ ui = true })
    elseif lv.UpdateUI then
        lv.UpdateUI()
    end
end

-- New mail since the last mailbox visit: may set the flag, never clears it.
local function ObserveNewMail()
    if session.mailboxOpen then return end -- the open mailbox is the better source
    if not (HasNewMail and HasNewMail()) then return end
    local mail = GetTrackedRecord()
    if not mail then return end
    local changed = not mail.hasNew
    mail.hasNew = true
    mail.newAt = Now()
    mail.checkedAt = mail.newAt
    if changed then RefreshCards() end
end

-- Inbox count from an open mailbox. allowZero is true only at close after the list loaded.
local function ObserveInbox(allowZero)
    if not GetInboxNumItems then return end
    local shown, total = GetInboxNumItems()
    if type(shown) ~= "number" then return end
    local count = (type(total) == "number" and total >= shown) and total or shown
    if count <= 0 and not allowZero then return end
    local mail = GetTrackedRecord()
    if not mail then return end
    mail.count = count
    mail.shown = shown
    mail.countAt = Now()
    mail.checkedAt = mail.countAt
    -- The player has now seen the inbox, which is what HasNewMail() measures against.
    mail.hasNew = nil
    mail.newAt = nil
    RefreshCards()
end

-- Blizzard's mail frame opens and closes through the player interaction manager
-- (Enum.PlayerInteractionType.MailInfo); MAIL_CLOSED no longer fires on Retail. Several
-- signals can report the same visit, so opening is idempotent and each closure is handled once.
local function OpenMailbox()
    if session.mailboxOpen then return end
    session.mailboxOpen = true
    session.inboxLoaded = false
end

-- Core, Currency and GoldTracker add their mailbox-closed handlers to this shared list
-- (they load before this file, so the list may already exist).
lv.MailboxClosedHandlers = lv.MailboxClosedHandlers or {}

local function CloseMailbox()
    if not session.mailboxOpen then return end
    if session.inboxLoaded then
        ObserveInbox(true)
    end
    session.mailboxOpen = false
    session.inboxLoaded = false
    for _, handler in ipairs(lv.MailboxClosedHandlers) do
        local ok, err = pcall(handler)
        if not ok and geterrorhandler then geterrorhandler()(err) end
    end
end

-- Public: what a character card should show, or nil when there is nothing to show.
function lv.GetCharacterMailState(charKey, data)
    data = data or (LiteVaultDB and LiteVaultDB[charKey])
    local mail = type(data) == "table" and data.mail
    if type(mail) ~= "table" then return nil end
    local hasNew = mail.hasNew == true
    local count = type(mail.count) == "number" and mail.count or nil
    if not hasNew and not (count and count > 0) then return nil end
    return {
        hasNew = hasNew,
        count = count,
        checkedAt = mail.checkedAt,
        live = charKey == lv.PLAYER_KEY, -- only the logged-in character updates this session
    }
end

-- Public: card tooltip. Offline characters are labelled as last known status.
function lv.ShowCharacterMailTooltip(owner, charKey)
    local state = lv.GetCharacterMailState(charKey)
    if not (state and owner and GameTooltip) then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(_G.MAIL_LABEL or "Mail", 1, 0.82, 0)
    if state.hasNew then
        GameTooltip:AddLine(_G.HAVE_MAIL or "You have unread mail", 1, 1, 1, true)
    end
    if state.count then
        GameTooltip:AddLine(string.format("%s: %d", _G.INBOX or "Inbox", state.count), 1, 1, 1)
    end
    if state.checkedAt then
        GameTooltip:AddLine(string.format(L["TEXT_MAIL_LAST_CHECKED_FMT"], date("%Y-%m-%d %H:%M", state.checkedAt)), 0.7, 0.7, 0.7)
    end
    if not state.live then
        GameTooltip:AddLine(L["TEXT_MAIL_OFFLINE_NOTE"], 0.6, 0.6, 0.6, true)
    end
    GameTooltip:Show()
end

local mailEvents = CreateFrame("Frame")
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "UPDATE_PENDING_MAIL", "MAIL_SHOW", "MAIL_INBOX_UPDATE",
    "MAIL_CLOSED", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" }) do
    pcall(mailEvents.RegisterEvent, mailEvents, event)
end
local mailFrameHooked = false
mailEvents:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Watch the mail frame itself as well as the interaction events.
        if not mailFrameHooked and MailFrame and MailFrame.HookScript then
            MailFrame:HookScript("OnShow", OpenMailbox)
            MailFrame:HookScript("OnHide", CloseMailbox)
            mailFrameHooked = true
        end
        ObserveNewMail()
    elseif event == "UPDATE_PENDING_MAIL" then
        ObserveNewMail()
    elseif event == "MAIL_SHOW" then
        OpenMailbox()
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
        if MAIL_INTERACTION_TYPE and arg1 == MAIL_INTERACTION_TYPE and not session.mailboxOpen then OpenMailbox() end
    elseif event == "MAIL_INBOX_UPDATE" then
        if session.mailboxOpen then
            session.inboxLoaded = true
            ObserveInbox(false)
        end
    elseif event == "MAIL_CLOSED" then
        CloseMailbox()
    elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then
        if MAIL_INTERACTION_TYPE and arg1 == MAIL_INTERACTION_TYPE then CloseMailbox() end
    end
end)
