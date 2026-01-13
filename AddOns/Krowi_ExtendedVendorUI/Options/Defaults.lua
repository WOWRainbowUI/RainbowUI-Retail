local _, addon = ...

addon.Options.Defaults = {
    profile = {
        ShowMinimapIcon = false,
        NumRows = 5,
        NumColumns = 4,
        Direction = addon.L["Columns first"],
        Minimap = {
            hide = true -- not ShowMinimapIcon
        },
        ShowOptionsButton = true,
        ShowHideOption = true,
        RememberFilter = false,
        RememberSearch = false,
        RememberSearchBetweenVendors = false,
        TokenBanner = {
            MoneyLabel = 'Icon',
            MoneyAbbreviate = 'None',
            ThousandsSeparator = 'Space',
            MoneyGoldOnly = false,
            MoneyColored = true,
	        CurrencyAbbreviate = 'None',
        }
    }
}