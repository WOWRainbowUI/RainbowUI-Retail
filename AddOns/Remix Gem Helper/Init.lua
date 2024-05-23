---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants

local defaultDatabase = {
    show_unowned = false,
    show_primordial = false,
    show_frame = true,
    show_helpframe = true
}

for lang, langInfo in pairs(Private.Locales) do
    if langInfo.isEditing then
        print(string.format("You're currently Editing: '%s'", lang))
        function GetLocale() return lang end
    end
end

local addon = LibStub("RasuAddon"):CreateAddon(
    const.ADDON_NAME,
    "RemixGemHelperDB",
    defaultDatabase,
    Private.Locales
)

Private.Addon = addon
