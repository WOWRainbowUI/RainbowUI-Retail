-- Theme.lua - LiteVault Theme System
local addonName, lv = ...
local L = lv.L

-- ============================================================
-- THEME DEFINITIONS
-- ============================================================

lv.Themes = {
    dark = {
        name = "Dark (Void Purple)",

        -- Main window backgrounds
        background = {0.085, 0.090, 0.125, 0.985},
        backgroundSolid = {0.085, 0.090, 0.125, 1.0},
        backgroundTransparent = {0.085, 0.090, 0.125, 0.92},
        backgroundAlt = {0.125, 0.133, 0.180, 1.0},

        -- Borders
        borderPrimary = {0.67, 0.36, 1.0, 1},
        borderSecondary = {0.64, 0.58, 0.82, 1},
        borderHover = {1, 0.82, 0, 1},
        borderSubdued = {0.38, 0.36, 0.52, 0.78},
        borderMuted = {0.56, 0.58, 0.70, 0.92},

        -- Button backgrounds
        buttonBg = {0.158, 0.168, 0.228, 1.0},
        buttonBgHover = {0.225, 0.192, 0.318, 1.0},
        buttonBgAlt = {0.142, 0.150, 0.205, 1.0},
        buttonBgActive = {0.290, 0.224, 0.400, 1.0},

        -- Data box backgrounds
        dataBoxBg = {0.142, 0.150, 0.205, 0.98},
        dataBoxBgAlt = {0.126, 0.134, 0.184, 0.98},
        dataBoxBgVault = {0.150, 0.160, 0.214, 0.98},

        -- Text colors
        textPrimary = {1, 1, 1, 1},
        textSecondary = {0.92, 0.93, 0.98, 1},
        textMuted = {0.68, 0.70, 0.78, 1},
        textGold = {1, 0.82, 0, 1},
        textAccent = {0.78, 0.52, 1.0, 1},
        textSubtitle = {0.72, 0.64, 0.90, 1},

        -- Calendar specific
        calendarDayBg = {0.165, 0.173, 0.235, 0.86},
        calendarDayBorder = {0.54, 0.56, 0.68, 0.95},
        calendarTodayBg = {0.360, 0.255, 0.490, 0.86},
        calendarTodayBorder = {0.78, 0.52, 1.0, 1},
        calendarHeaderBg = {0.185, 0.160, 0.255, 0.98},

        -- Row striping
        rowStripeEven = {1, 1, 1, 0.05},
        rowStripeOdd = {0.02, 0.03, 0.08, 0.18},
        rowTotal = {0.36, 0.24, 0.56, 0.24},
        rowNet = {0.24, 0.18, 0.42, 0.32},

        -- Dividers/separators
        divider = {0.42, 0.38, 0.58, 0.30},
        dividerBright = {0.66, 0.56, 0.88, 0.58},

        -- Tab colors
        tabActive = {0.290, 0.224, 0.400, 1},
        tabActiveBorder = {0.8, 0.4, 1, 1},
        tabInactive = {0.164, 0.174, 0.232, 0.96},
        tabInactiveBorder = {0.40, 0.38, 0.56, 0.92},

        -- Portrait frame
        portraitBorder = {0.78, 0.52, 1.0, 1},
    },

    light = {
        name = "Light (Sage Green)",

        -- Main window backgrounds (#667766)
        background = {0.40, 0.47, 0.40, 0.98},
        backgroundSolid = {0.40, 0.47, 0.40, 1},
        backgroundTransparent = {0.40, 0.47, 0.40, 0.85},
        backgroundAlt = {0.35, 0.42, 0.35, 0.98},

        -- Borders (#333333)
        borderPrimary = {0.20, 0.20, 0.20, 1},
        borderSecondary = {0.20, 0.20, 0.20, 1},
        borderHover = {0.4, 0.4, 0.4, 1},
        borderSubdued = {0.25, 0.25, 0.25, 0.8},
        borderMuted = {0.20, 0.20, 0.20, 1},

        -- Button backgrounds (darker #4d5a4d)
        buttonBg = {0.30, 0.35, 0.30, 0.9},
        buttonBgHover = {0.38, 0.45, 0.38, 1},
        buttonBgAlt = {0.28, 0.33, 0.28, 0.9},
        buttonBgActive = {0.35, 0.42, 0.35, 1},

        -- Data box backgrounds (darker)
        dataBoxBg = {0.30, 0.35, 0.30, 0.9},
        dataBoxBgAlt = {0.28, 0.33, 0.28, 0.9},
        dataBoxBgVault = {0.29, 0.34, 0.29, 0.9},

        -- Text colors (light for contrast)
        textPrimary = {1, 1, 1, 1},
        textSecondary = {0.9, 0.9, 0.9, 1},
        textMuted = {0.7, 0.7, 0.7, 1},
        textGold = {1, 0.82, 0, 1},
        textAccent = {0.8, 0.9, 0.8, 1},
        textSubtitle = {0.75, 0.75, 0.75, 1},

        -- Calendar specific
        calendarDayBg = {0.30, 0.35, 0.30, 0.6},
        calendarDayBorder = {0.20, 0.20, 0.20, 1},
        calendarTodayBg = {0.55, 0.65, 0.45, 0.9},
        calendarTodayBorder = {0.7, 0.8, 0.5, 1},
        calendarHeaderBg = {0.28, 0.33, 0.28, 0.95},

        -- Row striping
        rowStripeEven = {1, 1, 1, 0.03},
        rowStripeOdd = {0, 0, 0, 0.06},
        rowTotal = {0.25, 0.30, 0.25, 0.3},
        rowNet = {0.22, 0.27, 0.22, 0.4},

        -- Dividers/separators
        divider = {0.3, 0.35, 0.3, 0.35},
        dividerBright = {0.4, 0.45, 0.4, 0.6},

        -- Tab colors
        tabActive = {0.45, 0.55, 0.42, 1},
        tabActiveBorder = {0.55, 0.65, 0.50, 1},
        tabInactive = {0.30, 0.35, 0.30, 0.9},
        tabInactiveBorder = {0.20, 0.20, 0.20, 0.8},

        -- Portrait frame
        portraitBorder = {0.20, 0.20, 0.20, 1},
    }
}

-- Current theme (defaults to dark)
lv.currentTheme = "dark"

-- ============================================================
-- THEME API FUNCTIONS
-- ============================================================

-- Get the active theme table
function lv.GetTheme()
    return lv.Themes[lv.currentTheme] or lv.Themes.dark
end

-- Get a specific color from the current theme (returns r, g, b, a)
function lv.GetColor(colorKey)
    local theme = lv.GetTheme()
    local color = theme[colorKey]
    if color then
        return unpack(color)
    end
    return 1, 1, 1, 1
end

-- Get a specific color as a table
function lv.GetColorTable(colorKey)
    local theme = lv.GetTheme()
    return theme[colorKey] or {1, 1, 1, 1}
end

-- Set the current theme
function lv.SetTheme(themeName)
    if lv.Themes[themeName] then
        lv.currentTheme = themeName
        if LiteVaultDB then
            LiteVaultDB.theme = themeName
        end
        lv.ApplyTheme()
    end
end

-- Toggle between themes
function lv.ToggleTheme()
    if lv.currentTheme == "dark" then
        lv.SetTheme("light")
    else
        lv.SetTheme("dark")
    end
end

-- ============================================================
-- THEME APPLICATION SYSTEM
-- ============================================================

-- Registry of themed UI elements
lv.ThemedElements = {}

-- Register a frame for theme updates
function lv.RegisterThemedElement(element, updateFunc)
    if element and updateFunc then
        table.insert(lv.ThemedElements, {
            element = element,
            updateFunc = updateFunc
        })
    end
end

-- Apply theme to all registered elements
function lv.ApplyTheme()
    local theme = lv.GetTheme()

    -- Update all registered elements
    for _, entry in ipairs(lv.ThemedElements) do
        if entry.element and entry.updateFunc then
            pcall(entry.updateFunc, entry.element, theme)
        end
    end

    -- Refresh the main UI
    if lv.UpdateUI then
        lv.UpdateUI()
    end

    -- Update dark mode checkbox if it exists
    if lv.darkModeCB then
        lv.darkModeCB:SetChecked(lv.currentTheme == "dark")
    end
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================

SLASH_LITEVAULTTHEME1 = "/lvtheme"
SlashCmdList["LITEVAULTTHEME"] = function(msg)
    msg = msg:lower():gsub("^%s*(.-)%s*$", "%1")

    if msg == "dark" then
        lv.SetTheme("dark")
        print("|cff9933ffLiteVault:|r Theme set to Dark (Void Purple)")
    elseif msg == "light" then
        lv.SetTheme("light")
        print("|cff9933ffLiteVault:|r Theme set to Light")
    elseif msg == "" or msg == "toggle" then
        lv.ToggleTheme()
        print("|cff9933ffLiteVault:|r Theme switched to " .. lv.GetTheme().name)
    else
        print("|cff9933ffLiteVault Theme Commands:|r")
        print("  /lvtheme - Toggle between themes")
        print("  /lvtheme dark - Switch to Dark theme")
        print("  /lvtheme light - Switch to Light theme")
        print("  Current: " .. lv.GetTheme().name)
    end
end
