local _, DFFN = ...
local HttpsxLib = DFFN.httpsxLib
local DFFNamePlates = DFFN.DFFNamePlates
local L = DFFN.L
local module = {}

module.tab = DFFNamePlates:AddTabButton("TAB_EXTENDED", 3, module)

function module:OnLoad()
    local tab = self.tab

    if not tab then return end

    local content = tab.frame

    local blizzardSizeSlider = HttpsxLib:CreateSlider(content, 140, 1, 5, 1, "TOPLEFT", content, 75, -67,
        1,
        function(self, value)
            SetCVar("nameplateSize", value);
        end)

            local blizzardSizeTile = HttpsxLib:CreateText(content, L("EX_BLIZZ_SIZE"), "TOP",
        blizzardSizeSlider, "TOP", 0, 15, 11.5, { 0.9, 0.9, 0.9, 1 }, "")

    local blizzardStyleTitle = HttpsxLib:CreateText(content, L("EX_BLIZZ_STYLE"), "TOPLEFT", content,
        "TOPLEFT", 10, -130, 11.5, { 0.9, 0.9, 0.9, 1 }, "")

    local styles = {
        { text = L("EX_STYLE_MODERN"),         value = "0" },
        { text = L("EX_STYLE_THIN"),           value = "1" },
        { text = L("EX_STYLE_BLOCKY"),         value = "2" },
        { text = L("EX_STYLE_CLEAN_HEALTH"),   value = "3" },
        { text = L("EX_STYLE_BLOCKY_CAST"),    value = "4" },
        { text = L("EX_STYLE_LEGACY_RED"),     value = "5" },
    }

    local blizzardStyleDropdown = HttpsxLib:CreateDropDown(content, 140, styles, "LEFT", blizzardStyleTitle, 95, 0,
        "Outline, Slug",
        function(self, value, text)
            if value == nil or text == nil then return end
            SetCVar("nameplateStyle", value);
        end)

    local hideInOpenWorldCB = HttpsxLib:CreateCheckBox(content,
        L("EX_HIDE_OPEN_WORLD"), "TOPLEFT", content, 10, -170)

    hideInOpenWorldCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.ExtendedSettings["hideInOpenWorld"] = checked

            if DFFriendlyNamePlates.NamePlatesSettings["enabled"] then
                if DFFNamePlates.instanceType == "none" and checked then
                    SetCVar("nameplateshowfriendlyPlayers", "0")
                else
                    SetCVar("nameplateshowfriendlyPlayers", "1")
                end
            end
    end)

    local customWidthCB = HttpsxLib:CreateCheckBox(content, L("EX_CUSTOM_WIDTH"), "TOPLEFT", content,
        10, -230)

    local customWidthBox = HttpsxLib:CreateNumberEditBox(content, 50, 20, "RIGHT", customWidthCB.text, 110, 0, 132,
        function(self, value)
            C_NamePlate.SetNamePlateSize(value, 26);
            DFFNamePlates:reloadNP()
        end
    )

    customWidthCB:Hide()  --Disabled until Blizzard separates width settings for friendly and enemy nameplates
    customWidthBox:Hide() --Disabled until Blizzard separates width settings for friendly and enemy nameplates

    local localeItems = {
        { text = "English (enUS)", value = "enUS", font = "Fonts\\FRIZQT__.TTF" },
        { text = "Русский (ruRU)", value = "ruRU", font = "Fonts\\FRIZQT___CYR.TTF" },
        { text = "简体中文 (zhCN)", value = "zhCN", font = "Fonts\\ARHei.ttf" },
        { text = "繁體中文 (zhTW)", value = "zhTW", font = "Fonts\\bHEI01B.ttf" },
        { text = "한국어 (koKR)", value = "koKR", font = "Fonts\\2002.TTF" },
    }

    local languageTitle = HttpsxLib:CreateText(content, L("UI_LANGUAGE") .. ":", "TOPLEFT", content,
        "TOPLEFT", 48, -260, 11.5, { 0.9, 0.9, 0.9, 1 }, "")

    local languageDropdown = HttpsxLib:CreateDropDown(content, 140, localeItems, "RIGHT", languageTitle, 145, 0,
        "English",
        function(self, value)
            DFFNamePlates.pendingLanguage = value
            if DFFNamePlates.UpdateLanguageApplyState then
                DFFNamePlates:UpdateLanguageApplyState()
            end
        end)

    local languageReloadButton = HttpsxLib:CreateButton(content,
        L("UI_RELOAD_LANG"), 280, 25, "TOPLEFT", content, 10, -280)

    function DFFNamePlates:UpdateLanguageApplyState()
        local activeLocale = DFFN.GetSelectedLocale()
        local pendingLocale = DFFN.NormalizeLocale(self.pendingLanguage or activeLocale)
        local changed = pendingLocale ~= activeLocale
        languageReloadButton:SetEnabled(changed)
        languageReloadButton:SetAlpha(changed and 1 or 0.6)
    end

    languageReloadButton:SetScript("OnClick", function()
        local activeLocale = DFFN.GetSelectedLocale()
        local pendingLocale = DFFN.NormalizeLocale(DFFNamePlates.pendingLanguage or activeLocale)

        if pendingLocale == activeLocale then
            return
        end

        DFFriendlyNamePlates.Settings = DFFriendlyNamePlates.Settings or {}
        DFFriendlyNamePlates.Settings.locale = pendingLocale
        ReloadUI()
    end)

    local moreSettingsButton = HttpsxLib:CreateButton(content,
        L("EX_OPEN_BLIZZ_SETTINGS"), 280, 25, "TOPLEFT", content, 10, -340)
    moreSettingsButton.icon = moreSettingsButton:CreateTexture(nil, "OVERLAY")
    moreSettingsButton.icon:SetSize(26, 26)
    moreSettingsButton.icon:SetPoint("LEFT", moreSettingsButton, "LEFT", 4, 1)
    moreSettingsButton.icon:SetTexture("interface\\hud\\uigroupmanager")
    moreSettingsButton.icon:SetTexCoord(0.9365234375, 0.9755859375, 0.1220703125, 0.0830078125)

    moreSettingsButton:SetScript("OnClick", function()
        Settings.OpenToCategory(109)
    end)

    DFFNamePlates.settings.ExtendedSettings = {}
    DFFNamePlates.settings.ExtendedSettings["blizzardSize"] = blizzardSizeSlider
    DFFNamePlates.settings.ExtendedSettings["blizzardStyle"] = blizzardStyleDropdown
    DFFNamePlates.settings.ExtendedSettings["hideInOpenWorld"] = hideInOpenWorldCB
    DFFNamePlates.settings.ExtendedSettings["language"] = languageDropdown
    DFFNamePlates.settings.ExtendedSettings["applyLanguage"] = languageReloadButton
end
