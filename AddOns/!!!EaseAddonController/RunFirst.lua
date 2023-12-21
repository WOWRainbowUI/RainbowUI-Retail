local _, U1 = ...
--GetLocale = function() return "zhCN" end

U1PlayerName = UnitName("player")
U1PlayerClass = select(2, UnitClass("player"))

local f = CreateFrame("Frame") --最先注册
f:RegisterEvent("ADDON_LOADED") --ADDON_LOADED已经可以获取db了
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGOUT")
U1.eventframe = f
--f:SetScript("OnEvent", function(...) print(...) end) -- will be placed in 163UI.lua

function CoreBuildLocale()
    return setmetatable({},{
        __index = function(self, key) return key end,
        __call = function(self, key) return rawget(self, key) or key  end
    })
end
U1.L = CoreBuildLocale()
U1.CN = GetLocale():sub(1, 2) == "zh"

function U1Message(text, r, g, b, chatFrame)
    (chatFrame or DEFAULT_CHAT_FRAME):AddMessage(U1.L"|cff1acd1c[EAC]|r- " .. text, r, g, b);
end

UI163_USER_MODE = 1             --- alwaysRegister=1 and not checkVendor
UI163_USE_X_CATEGORIES = nil   --- use X-Categories tag
