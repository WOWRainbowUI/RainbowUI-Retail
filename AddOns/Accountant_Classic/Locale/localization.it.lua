-- $Id$ 
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "itIT", false)

if not L then return end

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) oro"
L["(%d+) Silver"] = "(%d+) argento"
L["(%d+) Copper"] = "(%d+) rame"
