local _, addon = ...
local LSM = LibStub("LibSharedMedia-3.0")

-- Data structure: ["Font Name"] = { file = "filename.ttf", cyrillic = true/false }
local myFonts = {
    ["Pepsi Modern"]         = { file = "pepsi_modern.ttf",      cyrillic = false },
    ["Pepsi Cursive"]        = { file = "pepsi_cursive.ttf",     cyrillic = false },
    ["Bangers"]              = { file = "Bangers.ttf",           cyrillic = false },
    ["Pf Tempesta Seven"]    = { file = "pf_tempesta_seven.ttf", cyrillic = false },
    ["Prototype"]            = { file = "Prototype.ttf",         cyrillic = false },
    ["Expressway"]           = { file = "Expressway.ttf",        cyrillic = true  },
    ["Roboto Bold"]          = { file = "Roboto-Bold.ttf",       cyrillic = true  },
    ["Big Noodle Titling"]   = { file = "bignoodletitling.ttf",  cyrillic = false },
    ["Die Die Die"]          = { file = "DIEDIEDI.ttf",          cyrillic = false },
    ["LifeCraft"]            = { file = "LifeCraft_Font.ttf",    cyrillic = false },
    ["Ginko"]                = { file = "Ginko.ttf",             cyrillic = false },
    ["Gotham Narrow Ultra"]  = { file = "Gotham Narrow Ultra.otf",cyrillic = false },
    ["Yikes"]                = { file = "yikes.ttf",             cyrillic = false },
    ["Denmark"]              = { file = "Denmark.ttf",           cyrillic = false },
    ["Zero Cool"]            = { file = "ZeroCool.ttf",          cyrillic = true },
    ["Custom Font NDR"]      = { file = "customfontndr.ttf",     cyrillic = true },
    ["Alte Haas Grotesk"]    = { file = "AlteHaasGroteskBold.ttf",  cyrillic = false },
}

function addon:RegisterFonts()
    local prefix = "Interface\\AddOns\\NiceDamage\\fonts\\"
    local isRussian = (GetLocale() == "ruRU")

    local mask = (LSM.LOCALE_BIT_koKR or 1) + 
                 (LSM.LOCALE_BIT_ruRU or 2) + 
                 (LSM.LOCALE_BIT_zhCN or 4) + 
                 (LSM.LOCALE_BIT_zhTW or 8) + 
                 (LSM.LOCALE_BIT_western or 128)

    for name, data in pairs(myFonts) do
        -- Check if this is the custom font and if it should be loaded
        local shouldLoad = true
        if name == "Custom Font NDR" and not self.db.profile.loadCustomFont then
            shouldLoad = false
        end

        if shouldLoad then
            local displayName = name
            
            if isRussian and not data.cyrillic then
                displayName = name .. " |cff888888[Latin]|r"
            end

            LSM:Register("font", displayName, prefix .. data.file, mask)
        end
    end
end