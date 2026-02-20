local _, DFFN = ...
local HttpsxLib = DFFN.httpsxLib
local DFFNamePlates = DFFN.DFFNamePlates
local module = {}

module.tab = DFFNamePlates:AddTabButton("名條", 1, module)

function module:OnLoad()
    local tab = self.tab

    if not tab then return end

    local content = tab.frame

    local enableNameplatesCB = HttpsxLib:CreateCheckBox(content, "啟用友方名條", "TOPLEFT", content, 5, -30)

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

    local showOnlyNameCB = HttpsxLib:CreateCheckBox(content, "只顯示名稱", "TOPLEFT", content, 5, -60)

    showOnlyNameCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showOnlyName"] = checked
        SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", checked and "1" or "0")
        DFFNamePlates:reloadNP()
    end)

    local showOnlyNameNpcCB = HttpsxLib:CreateCheckBox(content, "只顯示名稱 (NPC)", "TOPLEFT", content, 5, -90)

    showOnlyNameNpcCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpc"] = checked
        DFFNamePlates:reloadNP()
        DFFNamePlates:SetNpcTypeEnabled(checked)
    end)

    local npcType = {
        { text = "總是",          value = "always" },
        { text = "只有地城",    value = "dungeon" },
        { text = "只有團本",      value = "raids" },
        { text = "地城+團本", value = "dungeon_raids" }
    }

    local showOnlyNameNpcDropdown = HttpsxLib:CreateDropDown(content, 110, npcType, "LEFT", showOnlyNameNpcCB.text, 145,
        0,
        "always",
        function(self, value, text)
            if value == nil or text == nil then return end
            DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpcType"] = value
            DFFNamePlates:reloadNP()
        end)


    local hideCastBarCB = HttpsxLib:CreateCheckBox(content, "隱藏施法條", "TOPLEFT", content, 5, -120)

    local warningHideCastBar = HttpsxLib:CreateText(content, "需要重新載入介面", "LEFT", hideCastBarCB.text, "RIGHT",
        10, 0, 9,
        { 1, 0.31, 0.31, 1.0 }, "")
    warningHideCastBar:Hide()

    hideCastBarCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["hideCastBar2"] = checked
        DFFNamePlates:reloadNP()
    end)


    local titleColors = HttpsxLib:CreateText(content, "顏色:", "TOP", tab.frame, "TOP", 0, -140, 12,
        { 0.9, 0.8, 0.5, 1 }, "OUTLINE")


    local showClassColorCB = HttpsxLib:CreateCheckBox(content, "名字顯示職業顏色", "TOPLEFT", content, 5, -160)

    showClassColorCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.NamePlatesSettings["showClassColor"] = checked
        SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", checked and "1" or "0");
    end)

    local showColorBySelectionCB = HttpsxLib:CreateCheckBox(content, "選取的顯示顏色", "TOPLEFT", content, 5,
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


    local titleColors = HttpsxLib:CreateText(content, "文字:", "TOP", tab.frame, "TOP", 0, -220, 12,
        { 0.9, 0.8, 0.5, 1 }, "OUTLINE")

    local customFontCB = HttpsxLib:CreateCheckBox(content, "自訂文字", "TOPLEFT", content, 5, -240)

    local fontSettingsTitle = HttpsxLib:CreateText(content, "字體:", "TOPLEFT", content, "TOPLEFT", 10, -270, 11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local fonts = {
        { text = "預設遊戲字體", value = DFFNamePlates.defaultFont.name },
    }

    for k, v in DFFNamePlates:IterateMediaData("font") do
        table.insert(fonts, { text = k, value = v })
    end

    local fontDropdown = HttpsxLib:CreateDropDown(content, 140, fonts, "LEFT", fontSettingsTitle, 50, 0,
        "預設遊戲字體",
        function(self, value, text)
            if value == nil or text == nil then return end
            DFFriendlyNamePlates.NamePlatesSettings["fontName"] = value
            DFFNamePlates:UpdateFont()
            DFFNamePlates:setFontForAll()
        end)

    local SizeSettingsTitle = HttpsxLib:CreateText(content, "大小:", "TOPLEFT", content, "TOPLEFT", 10, -330, 11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local fontSizeSlider = HttpsxLib:CreateSlider(content, 140, 1, 116, 1, "LEFT", SizeSettingsTitle, 50, 5,
        12,
        function(self, value)
            DFFriendlyNamePlates.NamePlatesSettings["fontSize"] = value
            DFFNamePlates:UpdateFont()
            DFFNamePlates:setFontForAll()
        end)

    local fontStyleTitle = HttpsxLib:CreateText(content, "樣式:", "TOPLEFT", content, "TOPLEFT", 10, -300, 11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local styles = {
        { text = "無",          value = "" },
        { text = "外框",       value = "OUTLINE" },
        { text = "加粗",          value = "SLUG" },
        { text = "外框, 加粗", value = "OUTLINE, SLUG" },
    }

    local fontStyleDropdown = HttpsxLib:CreateDropDown(content, 140, styles, "LEFT", fontStyleTitle, 50, 0,
        "外框, 加粗",
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
