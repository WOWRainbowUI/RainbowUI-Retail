--[[ RGX-Framework - Commands ]]

local _, RGX = ...
local L = (RGX:GetModule("locale") or {}).L or {}

RGX:RegisterSlashCommand({ "rgx", "rgxframework", "rgxf" }, function(msg)
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
        -- One switch for the framework's debug output (including the options open timings and font reports).
        RGX.debugMode = not RGX.debugMode
        local state = RGX.debugMode and (L["COMMAND_FONT_DEBUG_ON"] or "ON") or (L["COMMAND_FONT_DEBUG_OFF"] or "OFF")
        local Fonts = RGX:GetModule("fonts")
        if Fonts then Fonts._forceDebug = RGX.debugMode end
        RGX:Print(L["COMMAND_DEBUG_PREFIX"] or "Debug:", state)
    elseif cmd == "dbtest" then
        -- The database test harness relocated out of the runtime package
        -- (tests/database_test.lua) so the shipped runtime stays clean; it is
        -- now exercised by the headless CI harness
        -- (tools/ci/database-runtime-test.mjs) rather than in-game. See #79.
        RGX:Print(L["COMMAND_DB_TESTS_RELOCATED"]
            or "DB test harness moved to tests/ (run via CI: npm --prefix tools/ci run lua-runtime-check).")
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
            RGX:Print(L["COMMAND_LOGIN_USAGE"] or "Usage: /rgxf login on|off|status")
        end
    elseif cmd == "style" or cmd == "theme" then
        -- /rgx style [id]: show or choose the interface style (framework, materialround, classic, forever).
        -- It is the same choice as the Theme tab: saved, and applied to windows built afterwards (reload to re-skin).
        local Design = type(RGX.GetDesign) == "function" and RGX:GetDesign() or nil
        local arg = strtrim(rest):lower()
        if not (Design and Design.STYLE_ORDER) then
            RGX:Print("The design module is not loaded.")
        elseif arg:match("^override") then
            -- /rgx style override on|off: the beta global theme override switch (off by default).
            local want = arg:match("^override%s+(%a+)$")
            if want == "on" or want == "off" then
                if type(RGX.db) == "table" then RGX.db.themeOverride = (want == "on") end
                if want == "on" then
                    if RGX.db.style then Design:SetStyle(RGX.db.style) end
                    if Design.ApplyOverrideTheme then Design:ApplyOverrideTheme(RGX.db)
                    elseif RGX.db.themePreset and Design.SetThemePreset then Design:SetThemePreset(RGX.db.themePreset) end
                else
                    Design:SetStyle("framework")
                    if Design.SetThemePreset then Design:SetThemePreset("cyan") end
                end
                if Design.NotifyThemeChanged then Design:NotifyThemeChanged() end
                RGX:Print("Global theme override (beta): " .. want .. ".")
            else
                RGX:Print("Global theme override (beta): " .. ((type(RGX.db) == "table" and RGX.db.themeOverride == true) and "on" or "off")
                    .. " (change with /rgx style override on|off)")
            end
        elseif arg == "" or arg == "list" then
            local saved = type(RGX.db) == "table" and RGX.db.style and Design:ResolveStyle(RGX.db.style) or "framework"
            RGX:Print("Interface style: " .. tostring(saved)
                .. " (choose with /rgx style " .. table.concat(Design.STYLE_ORDER, "|") .. ")")
        elseif Design:ResolveStyle(arg) then
            -- Saved always; applied live only while the beta override is on, like the Theme tab.
            local id = Design:ResolveStyle(arg)
            local on = type(RGX.db) == "table" and RGX.db.themeOverride == true
            if type(RGX.db) == "table" then RGX.db.style = id end
            if on then
                Design:SetStyle(id)
                if Design.NotifyThemeChanged then Design:NotifyThemeChanged() end
                RGX:Print("Interface style set to " .. id .. ".")
            else
                RGX:Print("Interface style saved as " .. id .. ". It applies while the theme override is on (/rgx style override on).")
            end
        else
            RGX:Print("Unknown style. Choose " .. table.concat(Design.STYLE_ORDER, ", ") .. ".")
        end
    elseif cmd == "editor" then
        RGX:OpenDefinitionEditor()
    elseif cmd == "version" or cmd == "ver" then
        local ver = tostring(RGX.version or (L["COMMAND_VERSION_UNKNOWN"] or "unknown"))
        RGX:Print((L["COMMAND_VERSION_PREFIX"] or "RGX-Framework v") .. ver)
    else
        RGX:Print(L["COMMAND_LIST"] or "Commands: modules, fonts, debug, dbtest, login, style, editor, version")
    end
end, "RGXFRAMEWORK")
