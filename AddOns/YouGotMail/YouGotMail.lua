--------------
-- Variables
--------------
local addonName, addonTable = ...
local debugmode = false

--------------
-- Functions
--------------
function Debug(text)
    if debugmode then print(text) end
end

function CheckTheMail()
    if (HasNewMail()) then
        if (YouGotMailDB.mail == false or time() > YouGotMailDB.time + 3600) then
            YouGotMailDB.mail = true
            YouGotMailDB.time = time()
            PlayNotification()
        end
    else
        ResetMailFlags()
    end
end

function PlayNotification()
    PlaySoundFile("Interface\\AddOns\\YouGotMail\\YouGotMail.ogg")
end

function ResetMailFlags()
    YouGotMailDB.mail = false
    YouGotMailDB.time = nil
end

--------------
-- Initialize
--------------
function Initialize()
    if not YouGotMailDB then
        YouGotMailDB = {}
    end
    if not YouGotMailDB.voice then
        YouGotMailDB.voice = 1
    end
end

--------------
-- Slash Cmd
--------------
function SlashCommand()
    PlayNotification()
    Debug("YGM addon playing notice")
end

--------------
-- Events
--------------
local f = CreateFrame("Frame")

f:RegisterEvent("UPDATE_PENDING_MAIL")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent",
    function (self, event, arg1, ...)
        if event == "ADDON_LOADED" and arg1 == addonName then
            SLASH_YOUGOTMAIL1 = "/ygm"
            SlashCmdList["YOUGOTMAIL"] = SlashCommand
            Initialize()
            Debug("YGM addon initialize.")
            self:UnregisterEvent("ADDON_LOADED")
            return
        end
        CheckTheMail()
    end
)

-- Notes:
-- If a player already has been notified that they have mail, we do not
-- to spam them with notices. So we record the time at which they have
-- been notified, and then check that it's been at least an hour before
-- we notify them again.
