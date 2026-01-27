local LIBCC_MAJOR, LIBCC_MINOR = "LibClickCasting-1.0", 1
local lib  = LibStub:NewLibrary(LIBCC_MAJOR, LIBCC_MINOR)

if not lib then return end -- No upgrade needed

lib.frame = lib.frame or CreateFrame("Frame")

local onEvent = function(self, event, ...)
end

lib.frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
lib.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
lib.frame:RegisterEvent("PLAYER_LOGIN")
lib.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
lib.frame:RegisterEvent("UNIT_FLAGS")

lib.frame:SetScript("OnEvent", onEvent)

-- Needs:
--  * Track combat status
--  * Track talent status
--  * Friend and enemy conditionals

-- This library is going to try and support a few different things with a
-- consistent interface:
--   * Click-casting on a unit frames
--   * OnEnter/OnLeave bindings that are only active over unit frames
--   * Global bindings (always active)
--
-- For click-casting, we're able to just set the bindings directly and
-- handle the registration of buttons, etc. We collapse any options into
-- macros and try to resolve conflicts so that the right thing happens.
--
-- With OnEnter and OnLeave bindings we will need to handle hooking the
-- frame scripts, making sure frames are only registered once, and the
-- setting and clearing of bindings. We'll also need to handle the dangle
-- cases, making sure that an override binding doesn't stick around when
-- it should be cleared.
--
-- For global bindings, we'll try to own the key binding completely and
-- cascade properly into any OnEnter/OnLeave bindings. These three things
-- are all kept separate so that they layer on top of each other, rather
-- than directly conflicting.
