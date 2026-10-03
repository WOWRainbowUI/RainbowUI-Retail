--[[ RGX-Framework - Commands ]]

local _, RGX = ...
local L = (RGX:GetModule("locale") or {}).L or {}

RGX:RegisterSlashCommand("rgx", function(msg)
    local input = strtrim(msg or "")
    local cmd, rest = input:match("^(%S+)%s*(.-)$")
    cmd = (cmd or ""):lower()
    rest = rest or ""

    if cmd == "modules" then
        local mods = RGX:GetLoadedModules()
        RGX:Print(L["COMMAND_MODULES_HEADER"] or "Modules:", table.concat(mods, ", "))
    elseif cmd == "fonts" or cmd == "font" then
        local Fonts = RGX:GetModule("fonts")
        if Fonts then
            local list = Fonts:ListAvailable()
            RGX:Print(
                L["COMMAND_FONTS_HEADER"] or "Fonts:",
                #list,
                L["COMMAND_FONTS_AVAILABLE"] or "available"
            )
            for i, f in ipairs(list) do
                print("  ", f.name, "-", f.displayName, "-", f.category)
            end
        end
    elseif cmd == "debug" then
        local Fonts = RGX:GetModule("fonts")
        if Fonts then
            Fonts._forceDebug = not Fonts._forceDebug
            local state = Fonts._forceDebug
                and (L["COMMAND_FONT_DEBUG_ON"] or "ON")
                or  (L["COMMAND_FONT_DEBUG_OFF"] or "OFF")
            RGX:Print(L["COMMAND_FONT_DEBUG_PREFIX"] or "Font debug:", state)
        end
    elseif cmd == "dbtest" then
        if type(RGX.RunDBTests) == "function" then
            RGX:RunDBTests()
        else
            RGX:Print(L["COMMAND_DB_TESTS_MISSING"] or "DB Tests not loaded.")
        end
    elseif cmd == "login" then
        local arg = strtrim(rest):lower()
        if arg == "on" then
            RGX:SetLoginMessagesEnabled(true)
            RGX:Print(
                L["COMMAND_LOGIN_MESSAGES_PREFIX"] or "Login messages:",
                L["COMMAND_FONT_DEBUG_ON"] or "ON"
            )
        elseif arg == "off" then
            -- This confirmation is a normal command response, not a login
            -- message, so it prints even after disabling.
            RGX:SetLoginMessagesEnabled(false)
            RGX:Print(
                L["COMMAND_LOGIN_MESSAGES_PREFIX"] or "Login messages:",
                L["COMMAND_FONT_DEBUG_OFF"] or "OFF"
            )
        elseif arg == "status" or arg == "" then
            local state = RGX:IsLoginMessagesEnabled()
                and (L["COMMAND_FONT_DEBUG_ON"] or "ON")
                or  (L["COMMAND_FONT_DEBUG_OFF"] or "OFF")
            RGX:Print(L["COMMAND_LOGIN_MESSAGES_PREFIX"] or "Login messages:", state)
        else
            RGX:Print(L["COMMAND_LOGIN_USAGE"] or "Usage: /rgx login on|off|status")
        end
    elseif cmd == "editor" then
        RGX:OpenDefinitionEditor()
    elseif cmd == "version" or cmd == "ver" then
        local ver = tostring(RGX.version or (L["COMMAND_VERSION_UNKNOWN"] or "unknown"))
        RGX:Print((L["COMMAND_VERSION_PREFIX"] or "RGX-Framework v") .. ver)
    else
        RGX:Print(L["COMMAND_LIST"] or "Commands: modules, fonts, debug, dbtest, login, editor, version")
    end
end, "RGX")
