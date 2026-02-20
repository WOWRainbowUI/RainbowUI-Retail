local _, DFFN = ...
local HttpsxLib = DFFN.httpsxLib
local DFFNamePlates = DFFN.DFFNamePlates
local module = {}

module.tab = DFFNamePlates:AddTabButton("Nameplates", 1, module)

function module:OnLoad()
    local tab = self.tab

    if not tab then return end

    local content = tab.frame

    local enableNameplatesCB = HttpsxLib:CreateCheckBox(content, "Enable Friendly Nameplates", "TOPLEFT", content, 5, -30)

    enableNameplatesCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["enabled"] = checked
        DFFNamePlates:SetNPSettingsEnabled(checked)
        if not checked then
            SetCVar("nameplateshowfriendlyPlayers", "0");
        else
            SetCVar("nameplateshowfriendlyPlayers", "1");
        end
    end)

    local showOnlyNameCB = HttpsxLib:CreateCheckBox(content, "Show Only Name", "TOPLEFT", content, 5, -60)

    showOnlyNameCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showOnlyName"] = checked
        SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", checked and "1" or "0")
        DFFNamePlates:reloadNP()
    end)

    local showOnlyNameNpcCB = HttpsxLib:CreateCheckBox(content, "Show Only Name (NPC)", "TOPLEFT", content, 5, -90)

    showOnlyNameNpcCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpc"] = checked
        DFFNamePlates:reloadNP()
        DFFNamePlates:SetNpcTypeEnabled(checked)
    end)

    local npcType = {
        { text = "always",          value = "always" },
        { text = "only dungeon",    value = "dungeon" },
        { text = "only raids",      value = "raids" },
        { text = "dungeon + raids", value = "dungeon_raids" }
    }

    local showOnlyNameNpcDropdown = HttpsxLib:CreateDropDown(content, 110, npcType, "LEFT", showOnlyNameNpcCB.text, 145,
        0,
        "always",
        function(self, value, text)
            if value == nil or text == nil then return end
            DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpcType"] = value
            DFFNamePlates:reloadNP()
        end)


    local hideCastBarCB = HttpsxLib:CreateCheckBox(content, "Hide Cast Bar", "TOPLEFT", content, 5, -120)

    local warningHideCastBar = HttpsxLib:CreateText(content, "Required Reload UI", "LEFT", hideCastBarCB.text, "RIGHT",
        10, 0, 9,
        { 1, 0.31, 0.31, 1.0 }, "")
    warningHideCastBar:Hide()

    hideCastBarCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["hideCastBar2"] = checked
        DFFNamePlates:reloadNP()
    end)


    local titleColors = HttpsxLib:CreateText(content, "Colors:", "TOP", tab.frame, "TOP", 0, -140, 12,
        { 0.9, 0.8, 0.5, 1 }, "OUTLINE")


    local showClassColorCB = HttpsxLib:CreateCheckBox(content, "Show Class Color Name", "TOPLEFT", content, 5, -160)

    showClassColorCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showClassColor"] = checked
        SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", checked and "1" or "0");
    end)

    local showColorBySelectionCB = HttpsxLib:CreateCheckBox(content, "Show Color by Selection", "TOPLEFT", content, 5,
        -190)

    showColorBySelectionCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showColorBySelection"] = checked

        if checked then
            DFFNamePlates:reloadNP()
        else
            local ns = GetCVar("nameplateStyle")
            SetCVar("nameplateStyle", 10)
            C_Timer.After(0.133, function() SetCVar("nameplateStyle", ns) end)
        end
    end)


    local titleColors = HttpsxLib:CreateText(content, "Font:", "TOP", tab.frame, "TOP", 0, -220, 12,
        { 0.9, 0.8, 0.5, 1 }, "OUTLINE")

    local customFontCB = HttpsxLib:CreateCheckBox(content, "Custom Font", "TOPLEFT", content, 5, -240)

    local fontSettingsTitle = HttpsxLib:CreateText(content, "Font:", "TOPLEFT", content, "TOPLEFT", 10, -270, 11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local fonts = {
        { text = "Default Game Font", value = DFFNamePlates.defaultFont.name },
    }

    for k, v in DFFNamePlates:IterateMediaData("font") do
        table.insert(fonts, { text = k, value = v })
    end

    local fontDropdown = HttpsxLib:CreateDropDown(content, 140, fonts, "LEFT", fontSettingsTitle, 50, 0,
        "Default Game Font",
        function(self, value, text)
            if value == nil or text == nil then return end
            DFFriendlyNamePlates.NamePlatesSettings["fontName"] = value
            DFFNamePlates:UpdateFont()
            DFFNamePlates:setFontForAll()
        end)

    local SizeSettingsTitle = HttpsxLib:CreateText(content, "Size:", "TOPLEFT", content, "TOPLEFT", 10, -330, 11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local fontSizeSlider = HttpsxLib:CreateSlider(content, 140, 1, 116, 1, "LEFT", SizeSettingsTitle, 50, 5,
        12,
        function(self, value)
            DFFriendlyNamePlates.NamePlatesSettings["fontSize"] = value
            DFFNamePlates:UpdateFont()
            DFFNamePlates:setFontForAll()
        end)

    local fontStyleTitle = HttpsxLib:CreateText(content, "Style:", "TOPLEFT", content, "TOPLEFT", 10, -300, 11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local styles = {
        { text = "None",          value = "" },
        { text = "Outline",       value = "OUTLINE" },
        { text = "Slug",          value = "SLUG" },
        { text = "Outline, Slug", value = "OUTLINE, SLUG" },
    }

    local fontStyleDropdown = HttpsxLib:CreateDropDown(content, 140, styles, "LEFT", fontStyleTitle, 50, 0,
        "Outline, Slug",
        function(self, value, text)
            if value == nil or text == nil then return end
            DFFriendlyNamePlates.NamePlatesSettings["fontStyle"] = value
            DFFNamePlates:UpdateFont()
            DFFNamePlates:setFontForAll()
        end)


    function DFFNamePlates:SetNpcTypeEnabled(checked)
        local a = checked
        showOnlyNameNpcDropdown:SetShown(a)
    end

    function DFFNamePlates:SetNPSettingsEnabled(checked)
        local a = checked and 1 or 0.5
        showOnlyNameCB:SetAlpha(a)
        showClassColorCB:SetAlpha(a)
        hideCastBarCB:SetAlpha(a)


        showOnlyNameCB:SetEnabled(checked)
        showClassColorCB:SetEnabled(checked)
        hideCastBarCB:SetEnabled(checked)

    end

    function DFFNamePlates:SetFontSettingsEnabled(checked)
        local a = checked and 1 or 0.5
        fontSettingsTitle:SetAlpha(a)
        fontDropdown:SetAlpha(a)
        SizeSettingsTitle:SetAlpha(a)
        fontStyleTitle:SetAlpha(a)
        fontSizeSlider:SetAlpha(a)
        fontStyleDropdown:SetAlpha(a)

        fontDropdown.enabled = checked
        fontDropdown.button:SetEnabled(checked)
        fontSizeSlider:SetEnabled(checked)
        fontSizeSlider.valueText:SetEnabled(checked)
        fontStyleDropdown.enabled = checked
        fontStyleDropdown.button:SetEnabled(checked)
    end

    customFontCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFNamePlates:SetFontSettingsEnabled(checked)
        DFFriendlyNamePlates.NamePlatesSettings["customFont"] = checked
        if not checked then
            SystemFont_NamePlate_Outlined:SetFont(DFFNamePlates.defaultFont.name, DFFNamePlates.defaultFont.size,
                DFFNamePlates.defaultFont.flags)
            SystemFont_NamePlate:SetFont(DFFNamePlates.defaultFont2.name, DFFNamePlates.defaultFont2.size,
                DFFNamePlates.defaultFont2.flags)
            DFFNamePlates:reloadNP()
        else
            DFFNamePlates:UpdateFont()
            DFFNamePlates:setFontForAll()
        end
    end)
    DFFNamePlates:SetFontSettingsEnabled(false)

    DFFNamePlates.settings.NamePlatesSettings = {}

    DFFNamePlates.settings.NamePlatesSettings["showOnlyName"] = showOnlyNameCB
    DFFNamePlates.settings.NamePlatesSettings["showClassColor"] = showClassColorCB
    DFFNamePlates.settings.NamePlatesSettings["customFont"] = customFontCB
    DFFNamePlates.settings.NamePlatesSettings["fontName"] = fontDropdown
    DFFNamePlates.settings.NamePlatesSettings["fontSize"] = fontSizeSlider
    DFFNamePlates.settings.NamePlatesSettings["fontStyle"] = fontStyleDropdown
    DFFNamePlates.settings.NamePlatesSettings["enabled"] = enableNameplatesCB
    DFFNamePlates.settings.NamePlatesSettings["hideCastBar2"] = hideCastBarCB
    DFFNamePlates.settings.NamePlatesSettings["showOnlyNameNpc"] = showOnlyNameNpcCB
    DFFNamePlates.settings.NamePlatesSettings["showOnlyNameNpcType"] = showOnlyNameNpcDropdown
    DFFNamePlates.settings.NamePlatesSettings["showColorBySelection"] = showColorBySelectionCB
end
