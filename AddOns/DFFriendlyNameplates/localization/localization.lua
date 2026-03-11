local _, DFFN = ...

DFFN.Locales = DFFN.Locales or {}
DFFN.Locales.enUS = DFFN.Locales.enUS or {}
DFFN.Localization = DFFN.Locales.enUS

local supportedLocales = {
    enUS = true,
    ruRU = true,
    zhCN = true,
    zhTW = true,
    koKR = true,
}

function DFFN.NormalizeLocale(locale)
    if type(locale) ~= "string" then
        return "enUS"
    end

    if supportedLocales[locale] then
        return locale
    end

    return "enUS"
end

function DFFN.GetSelectedLocale()
    local savedLocale = DFFriendlyNamePlates
        and DFFriendlyNamePlates.Settings
        and DFFriendlyNamePlates.Settings.locale

    return DFFN.NormalizeLocale(savedLocale or GetLocale())
end

function DFFN.L(key)
    local selectedLocale = DFFN.GetSelectedLocale()
    local selectedTable = DFFN.Locales[selectedLocale] or DFFN.Locales.enUS or {}
    local fallbackTable = DFFN.Locales.enUS or {}

    DFFN.Localization = selectedTable

    if selectedTable[key] ~= nil then
        return selectedTable[key]
    end

    if fallbackTable[key] ~= nil then
        return fallbackTable[key]
    end

    return key
end
