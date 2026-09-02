-- Localization.lua - Core localization system for LiteVault
local addonName, lv = ...

-- =============================================================================
-- LOCALIZATION TABLE
-- =============================================================================
-- Simple L["key"] lookup with fallback to key name if string not found
local L = setmetatable({}, {
    __index = function(t, key)
        return key -- Fallback: return key if string not found
    end
})

lv.L = L

function lv.GetAddonVersion()
    local version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version")
    return (type(version) == "string" and version ~= "") and version or "12.1.0.5"
end

-- =============================================================================
-- DEBUG STATE
-- =============================================================================
lv.localeDebug = {
    showKeys = false,      -- Show string keys instead of translations
    showBorders = false,   -- Show visual borders on text elements
    forcedLocale = nil,    -- Override detected locale
}

-- Track bordered elements for cleanup
local borderedElements = {}

-- =============================================================================
-- LOCALE FUNCTIONS
-- =============================================================================

-- Get current locale (respects forced locale for testing)
function lv.GetLocale()
    if lv.localeDebug.forcedLocale then
        return lv.localeDebug.forcedLocale
    end
    return GetLocale()
end

-- Register locale strings (called by each locale file)
local function IsBrokenLocaleValue(value)
    if type(value) ~= "string" then return true end
    if value:find("\239\191\189", 1, true) then return true end -- U+FFFD
    -- Strong mojibake prefixes only. Do not reject arbitrary UTF-8 lead or
    -- continuation bytes; Lua patterns operate on bytes, not code points.
    if value:find("\195\131\194", 1, true)
        or value:find("\195\130\194", 1, true)
        or value:find("\195\162\226", 1, true) then return true end
    if value:find("[%z\1-\8\11\12\14-\31\127]") then return true end
    if value:find("%a%?%a") then return true end
    return false
end

lv.IsBrokenLocaleValueForTests = IsBrokenLocaleValue

local function GetDebugLocaleValue(key, value)
    if not lv.localeDebug.showKeys then return value end
    local formats = {}
    for token in value:gmatch("%%[%d%$%.%-]*[sdif]") do formats[#formats + 1] = token end
    if #formats > 0 then return tostring(key) .. " " .. table.concat(formats, " ") end
    return tostring(key)
end

-- English always loads, other locales only load if they match current locale
function lv.RegisterLocale(locale, strings)
    local currentLocale = lv.GetLocale()

    -- Always load English as base
    if locale == "enUS" then
        for key, value in pairs(strings) do
            L[key] = GetDebugLocaleValue(key, value)
        end
        L.ADDON_VERSION = lv.localeDebug.showKeys and "ADDON_VERSION" or ("v" .. lv.GetAddonVersion())
    -- Load matching locale (overwrites English, unless the localized value is corrupted)
    elseif locale == currentLocale then
        for key, value in pairs(strings) do
            if not IsBrokenLocaleValue(value) then
                L[key] = GetDebugLocaleValue(key, value)
            end
        end
    end
end

-- Reload all locales (used when forcing a different language)
function lv.ReloadLocales()
    -- Clear existing strings
    for k in pairs(L) do
        L[k] = nil
    end

    -- Re-register all locales (files are already loaded, just re-call registration)
    if lv.LocaleData then
        -- First load English
        if lv.LocaleData["enUS"] then
            lv.RegisterLocale("enUS", lv.LocaleData["enUS"])
        end
        -- Then load current locale (overwrites English where translations exist)
        local currentLocale = lv.GetLocale()
        if currentLocale ~= "enUS" and lv.LocaleData[currentLocale] then
            lv.RegisterLocale(currentLocale, lv.LocaleData[currentLocale])
        end
    end
    L.ADDON_VERSION = "v" .. lv.GetAddonVersion()

    -- Refresh layout values for new locale
    if lv.RefreshLayout then
        lv.RefreshLayout()
    end

    -- Refresh all UI text elements
    if lv.RefreshLocalizedUI then
        lv.RefreshLocalizedUI()
    end
end

-- =============================================================================
-- DEBUG FEATURES
-- =============================================================================

-- Toggle key display mode
function lv.ToggleLocaleDebugKeys()
    lv.localeDebug.showKeys = not lv.localeDebug.showKeys

    if lv.localeDebug.showKeys then
        print("|cff9933ffLiteVault:|r Locale debug mode |cff00ff00ON|r - Showing string keys")
    else
        print("|cff9933ffLiteVault:|r Locale debug mode |cffff0000OFF|r - Showing translations")
    end

    lv.ReloadLocales()
end

-- Toggle border visualization mode
function lv.ToggleLocaleBorders()
    lv.localeDebug.showBorders = not lv.localeDebug.showBorders

    if lv.localeDebug.showBorders then
        print("|cff9933ffLiteVault:|r Border mode |cff00ff00ON|r - Showing text boundaries")
        print("|cff9933ffLiteVault:|r |cff00ff00Green|r = fits, |cffff0000Red|r = may overflow")
    else
        print("|cff9933ffLiteVault:|r Border mode |cffff0000OFF|r")
        -- Clean up borders
        lv.ClearAllBorders()
    end

    -- Refresh UI to apply borders
    if lv.UpdateUI then lv.UpdateUI() end
end

-- Force a specific locale for testing
function lv.ForceLocale(locale)
    -- Map lowercase input to correct case (slash command lowercases input)
    local localeMap = {
        enus = "enUS", dede = "deDE", frfr = "frFR", eses = "esES", ptbr = "ptBR",
        ruru = "ruRU", zhcn = "zhCN", zhtw = "zhTW", kokr = "koKR"
    }

    -- Normalize input (handle both "zhTW" and "zhtw")
    local normalizedLocale = locale and (localeMap[locale:lower()] or locale)

    local validLocales = {
        enUS = true, deDE = true, frFR = true, esES = true, ptBR = true,
        ruRU = true, zhCN = true, zhTW = true, koKR = true
    }

    if normalizedLocale and validLocales[normalizedLocale] then
        lv.localeDebug.forcedLocale = normalizedLocale

        -- Save to DB for persistence
        if LiteVaultDB then
            LiteVaultDB.forcedLocale = normalizedLocale
        end

        -- Reload locales with new language
        lv.ReloadLocales()

        print("|cff9933ffLiteVault:|r Locale forced to |cffffd100" .. normalizedLocale .. "|r")
        print("|cff9933ffLiteVault:|r Use |cffffff00/lvlocale reset|r to return to auto-detect")

        -- Refresh UI
        if lv.UpdateUI then lv.UpdateUI() end
    else
        print("|cff9933ffLiteVault:|r Invalid locale. Valid options:")
        print("  enUS, deDE, frFR, esES, ptBR, ruRU, zhCN, zhTW, koKR")
    end
end

-- Reset to auto-detected locale
function lv.ResetLocale()
    lv.localeDebug.forcedLocale = nil

    -- Clear from DB
    if LiteVaultDB then
        LiteVaultDB.forcedLocale = nil
    end

    -- Reload locales with auto-detected language
    lv.ReloadLocales()

    print("|cff9933ffLiteVault:|r Locale reset to auto-detect: |cffffd100" .. GetLocale() .. "|r")

    -- Refresh UI
    if lv.UpdateUI then lv.UpdateUI() end
end

-- Add debug border to a FontString
function lv.AddDebugBorder(fontString)
    if not lv.localeDebug.showBorders then return end
    if not fontString or not fontString.GetStringWidth then return end

    -- Get dimensions
    local textWidth = fontString:GetStringWidth()
    local textHeight = fontString:GetStringHeight()
    local containerWidth = fontString:GetWidth()

    -- Determine if overflowing (text wider than container, if container is set)
    local isOverflowing = containerWidth > 0 and textWidth > containerWidth

    -- Create or get border texture
    if not fontString.lvDebugBorder then
        local border = fontString:GetParent():CreateTexture(nil, "OVERLAY")
        border:SetPoint("TOPLEFT", fontString, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", fontString, "BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(0, 0, 0, 0)
        fontString.lvDebugBorder = border
        table.insert(borderedElements, fontString)
    end

    -- Set border color based on overflow status
    if isOverflowing then
        fontString.lvDebugBorder:SetColorTexture(1, 0, 0, 0.3) -- Red = overflow
    else
        fontString.lvDebugBorder:SetColorTexture(0, 1, 0, 0.2) -- Green = fits
    end
    fontString.lvDebugBorder:Show()
end

-- Clear all debug borders
function lv.ClearAllBorders()
    for _, fontString in ipairs(borderedElements) do
        if fontString.lvDebugBorder then
            fontString.lvDebugBorder:Hide()
        end
    end
end

-- =============================================================================
-- SLASH COMMANDS
-- =============================================================================
SLASH_LVLOCALE1 = "/lvlocale"
SlashCmdList["LVLOCALE"] = function(msg)
    msg = msg:lower():gsub("^%s*(.-)%s*$", "%1") -- trim whitespace

    if msg == "debug" then
        lv.ToggleLocaleDebugKeys()

    elseif msg == "borders" then
        lv.ToggleLocaleBorders()

    elseif msg:match("^lang%s+(.+)$") then
        local locale = msg:match("^lang%s+(.+)$")
        lv.ForceLocale(locale)

    elseif msg == "reset" then
        lv.ResetLocale()

    else
        -- Show status
        local currentLocale = lv.GetLocale()
        local detectedLocale = GetLocale()

        print("|cff9933ffLiteVault Localization|r")
        print("  Detected locale: |cffffd100" .. detectedLocale .. "|r")

        if lv.localeDebug.forcedLocale then
            print("  Forced locale: |cffffd100" .. lv.localeDebug.forcedLocale .. "|r")
        end

        print("  Debug keys: " .. (lv.localeDebug.showKeys and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
        print("  Debug borders: " .. (lv.localeDebug.showBorders and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
        print("")
        print("|cffffff00Commands:|r")
        print("  |cffffff00/lvlocale debug|r - Toggle key display mode")
        print("  |cffffff00/lvlocale borders|r - Toggle text border visualization")
        print("  |cffffff00/lvlocale lang XX|r - Force locale (e.g., deDE, zhCN)")
        print("  |cffffff00/lvlocale reset|r - Reset to auto-detect")
    end
end

-- =============================================================================
-- INITIALIZATION
-- =============================================================================
-- Load saved forced locale preference
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "LiteVault" then
        -- Restore forced locale if saved
        if LiteVaultDB and LiteVaultDB.forcedLocale then
            lv.localeDebug.forcedLocale = LiteVaultDB.forcedLocale
            -- Reload locales with forced language
            C_Timer.After(0.1, function()
                lv.ReloadLocales()
            end)
        end

        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Storage for locale data (populated by locale files)
lv.LocaleData = {}

-- =============================================================================
-- LOCALE-SPECIFIC LAYOUT ADJUSTMENTS
-- =============================================================================
-- Must be defined here (in Localization.lua) so it's available to all files

local function InitLayout()
    local currentLocale = lv.GetLocale and lv.GetLocale() or GetLocale()
    local isChinese = (currentLocale == "zhTW" or currentLocale == "zhCN")
    local isKorean = (currentLocale == "koKR")
    local isCJK = isChinese or isKorean
    local isWide = isCJK or currentLocale == "deDE" or currentLocale == "frFR" or currentLocale == "ruRU"

    lv.Layout = {
        -- Frame dimensions (Chinese needs larger frames)
        mainFrameWidth = isChinese and 1000 or 980,
        mainFrameHeight = isChinese and 870 or 820,
        charListWidth = isChinese and 560 or 540,
        totalDisplayWidth = isChinese and 560 or 540,

        -- Vertical padding for lists (Chinese needs more spacing)
        verticalPadding = isChinese and 9 or 5,

        -- Box heights (Chinese needs taller boxes for increased line spacing)
        weeklyBoxHeight = isChinese and 210 or 175,
        weeklyTabWidth = isWide and 92 or 78,
        weeklyEventTabWidth = isWide and 84 or 72,

        -- Header offsets (Chinese shifts 5px right)
        manageButtonLeft = isChinese and 40 or 35,
        totalGoldLeft = isChinese and 25 or 20,

        professionWindowWidth = isCJK and 780 or (isWide and 770 or 760),
        professionWindowHeight = isCJK and 550 or 540,
        professionTabWidth = isWide and 116 or 104,
        professionTreasureTabWidth = isWide and 120 or 108,
        professionCloseWidth = isWide and 76 or 68,
        professionTreasureRowHeight = isCJK and 220 or 206,
        professionTreasureRowSpacing = isCJK and 228 or 214,

        optionsPanelWidth = isCJK and 360 or (isWide and 330 or 280),
        optionsPanelHeight = isCJK and 650 or 640,
        optionsPanelDescWidth = isCJK and 290 or (isWide and 260 or 220),
        optionsPanelLangButtonWidth = isCJK and 170 or (isWide and 160 or 150),

        instancePanelWidth = isCJK and 430 or 400,
        instancePanelTitleWidth = isCJK and 170 or 140,
        instancePanelCloseWidth = isWide and 68 or 60,
        instancePanelTabWidth = isWide and 78 or 70,

        topCloseWidth = isWide and 80 or 70,
        topVaultWidth = isWide and 92 or 80,
        topInstancesWidth = isWide and 102 or 90,
        raidTabWidth = isWide and 142 or 130,
        raidLongTabWidth = isWide and 160 or 146,
        raidDifficultyWidth = isWide and 104 or 90,
        raidViewToggleWidth = isWide and 124 or 110,
        raidCloseWidth = isWide and 80 or 70,

        -- Font settings for Chinese (crisp text)
        useChineseFont = isCJK,
        isCJK = isCJK,
        isWideTextLocale = isWide,
    }
end

-- Initialize layout immediately
InitLayout()

-- Helper function to apply Chinese font styling (crisp text)
function lv.ApplyLocaleFont(fontString, size)
    -- Blizzard's locale-aware font objects already handle CJK correctly.
    -- Forcing UNIT_NAME_FONT here causes missing-glyph squares on some zh clients.
    -- Keep this as a no-op so existing font objects render with the client's proper locale font.
end

function lv.IsCJKLocale()
    return lv.Layout and lv.Layout.isCJK
end

function lv.IsWideTextLocale()
    return lv.Layout and lv.Layout.isWideTextLocale
end

-- Re-initialize layout when locale changes
function lv.RefreshLayout()
    InitLayout()
end



