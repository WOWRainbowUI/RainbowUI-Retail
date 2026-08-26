--[[ RGX-Framework - Commands ]]

local _, RGX = ...

RGX:RegisterSlashCommand("rgx", function(msg)
    local input = strtrim(msg or "")
    local cmd, rest = input:match("^(%S+)%s*(.-)$")
    cmd = (cmd or ""):lower()
    rest = rest or ""

    if cmd == "modules" then
        local mods = RGX:GetLoadedModules()
        RGX:Print("Modules:", table.concat(mods, ", "))
    elseif cmd == "fonts" or cmd == "font" then
        local Fonts = RGX:GetModule("fonts")
        if Fonts then
            local list = Fonts:ListAvailable()
            RGX:Print("Fonts:", #list, "available")
            for i, f in ipairs(list) do
                print("  ", f.name, "-", f.displayName, "-", f.category)
            end
        end
    elseif cmd == "debug" then
        local Fonts = RGX:GetModule("fonts")
        if Fonts then
            Fonts._forceDebug = not Fonts._forceDebug
            RGX:Print("Font debug:", Fonts._forceDebug and "ON" or "OFF")
        end
    elseif cmd == "dbtest" then
        if type(RGX.RunDBTests) == "function" then
            RGX:RunDBTests()
        else
            RGX:Print("DB Tests not loaded.")
        end
    elseif cmd == "login" then
        local arg = strtrim(rest):lower()
        if arg == "on" then
            RGX:SetLoginMessagesEnabled(true)
            RGX:Print("Login messages: ON")
        elseif arg == "off" then
            -- This confirmation is a normal command response, not a login
            -- message, so it prints even after disabling.
            RGX:SetLoginMessagesEnabled(false)
            RGX:Print("Login messages: OFF")
        elseif arg == "status" or arg == "" then
            RGX:Print("Login messages:", RGX:IsLoginMessagesEnabled() and "ON" or "OFF")
        else
            RGX:Print("Usage: /rgx login on|off|status")
        end
    elseif cmd == "version" or cmd == "ver" then
        RGX:Print("RGX-Framework v" .. (RGX.version or "unknown"))
    else
        RGX:Print("Commands: modules, fonts, debug, dbtest, login, version")
    end
end, "RGX")
