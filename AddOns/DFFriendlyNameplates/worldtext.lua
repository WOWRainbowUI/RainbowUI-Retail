local _, DFFN = ...
local HttpsxLib = DFFN.httpsxLib
local DFFNamePlates = DFFN.DFFNamePlates
local module = {}

module.tab = DFFNamePlates:AddTabButton("世界文字", 2, module)

function module:OnLoad()
    local tab = self.tab
    if not tab then return end

    local content = tab.frame

    local enableWorldTextNames = HttpsxLib:CreateCheckBox(content, "啟用世界文字名稱", "TOPLEFT", content, 5, -30)
    local warningWorldText = HttpsxLib:CreateButton(content, "!", 20, 20, "LEFT", enableWorldTextNames.text, "RIGHT", 5,
        0)

    warningWorldText.text:SetTextColor(1, 0.82, 0, 0.95)
    warningWorldText:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("這將會 關閉/開啟「啟用友方名條」選項")
        GameTooltip:Show()
    end)
    warningWorldText:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
    end)

    enableWorldTextNames:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.WorldTextSettings["enabled"] = checked
        if checked then
            DFFriendlyNamePlates.NamePlatesSettings["enabled"] = false
            DFFNamePlates.settings.NamePlatesSettings["enabled"]:SetChecked(false)
            DFFNamePlates:SetNPSettingsEnabled(false)
            SetCVar("nameplateshowfriendlyPlayers", "0");
        else
            DFFNamePlates:SetNPSettingsEnabled(true)
            SetCVar("nameplateshowfriendlyPlayers", "1");
            DFFriendlyNamePlates.NamePlatesSettings["enabled"] = true
            DFFNamePlates.settings.NamePlatesSettings["enabled"]:SetChecked(true)
        end

        if DFFriendlyNamePlates.WorldTextSettings["enabled"] or
            DFFriendlyNamePlates.WorldTextSettings["alwaysShow"] then
            SetCVar("WorldTextMinSize", DFFriendlyNamePlates.WorldTextSettings["worldTextSize"]);
            SetCVar("WorldTextMinAlpha_v2", DFFriendlyNamePlates.WorldTextSettings["worldTextAlpha"]);
        else
            SetCVar("WorldTextMinSize", DFFNamePlates.DEFAULT_WORLD_TEXT_SIZE);
            SetCVar("WorldTextMinAlpha_v2", DFFNamePlates.DEFAULT_WORLD_TEXT_ALPHA);
        end
    end)

    local enableAlwaysWorldText = HttpsxLib:CreateCheckBox(content, "總是套用設定", "TOPLEFT", content, 5, -60)

    local warningAlwaysWorldText = HttpsxLib:CreateButton(content, "!", 20, 20, "LEFT", enableAlwaysWorldText.text,
        "RIGHT", 11, 0)
    warningAlwaysWorldText.text:SetTextColor(1, 0.82, 0, 0.95)
    warningAlwaysWorldText:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("世界文字大小和世界文字透明度設定將總是套用，|n|n" ..
            "即使「啟用世界文字名稱」已停用")
        GameTooltip:Show()
    end)
    warningAlwaysWorldText:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
    end)

    enableAlwaysWorldText:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.WorldTextSettings["alwaysShow"] = checked

        if DFFriendlyNamePlates.WorldTextSettings["enabled"] or
            DFFriendlyNamePlates.WorldTextSettings["alwaysShow"] then
            SetCVar("WorldTextMinSize", DFFriendlyNamePlates.WorldTextSettings["worldTextSize"]);
            SetCVar("WorldTextMinAlpha_v2", DFFriendlyNamePlates.WorldTextSettings["worldTextAlpha"]);
        else
            SetCVar("WorldTextMinSize", DFFNamePlates.DEFAULT_WORLD_TEXT_SIZE);
            SetCVar("WorldTextMinAlpha_v2", DFFNamePlates.DEFAULT_WORLD_TEXT_ALPHA);
        end
    end)

    local hidePlayerGuildCB = HttpsxLib:CreateCheckBox(content, "隱藏玩家公會", "TOPLEFT", content, 5, -90)
    local hidePlayerTitleCB = HttpsxLib:CreateCheckBox(content, "隱藏玩家頭銜", "TOPLEFT", content, 5, -120)

    hidePlayerGuildCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.WorldTextSettings["hidePlayerGuild"] = checked
        SetCVar("UnitNamePlayerGuild", checked and "0" or "1");
    end)

    hidePlayerTitleCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        DFFriendlyNamePlates.WorldTextSettings["hidePlayerTitle"] = checked
        SetCVar("UnitNamePlayerPVPTitle", checked and "0" or "1");
    end)

    local worldTextSizeTitle = HttpsxLib:CreateText(content, "世界文字大小", "TOPLEFT", content, "TOPLEFT", 75, -157,
        11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local worldTextSizeSlider = HttpsxLib:CreateSlider(content, 140, 0, 99, 1, "TOPLEFT", content, 45, -170,
        10,
        function(self, value)
            --DFFriendlyNamePlates.NamePlatesSettings["fontSize"] = value
            --DFFNamePlates:UpdateFont()
            DFFriendlyNamePlates.WorldTextSettings["worldTextSize"] = value
            if DFFriendlyNamePlates.WorldTextSettings["enabled"] or
                DFFriendlyNamePlates.WorldTextSettings["alwaysShow"] then
                SetCVar("WorldTextMinSize", value);
            end
        end)

    local worldTextAlphaTitle = HttpsxLib:CreateText(content, "世界文字透明度", "TOPLEFT", content, "TOPLEFT", 75, -225,
        11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local worldTextAlphaSlider = HttpsxLib:CreateSlider(content, 140, 0, 1.0, 0.1, "TOPLEFT", content, 45, -242,
        1.0,
        function(self, value)
            DFFriendlyNamePlates.WorldTextSettings["worldTextAlpha"] = value
            if DFFriendlyNamePlates.WorldTextSettings["enabled"] or
                DFFriendlyNamePlates.WorldTextSettings["alwaysShow"] then
                SetCVar("WorldTextMinAlpha_v2", value);
            end
        end)


    DFFNamePlates.settings.WorldTextSettings = {}

    DFFNamePlates.settings.WorldTextSettings["enabled"] = enableWorldTextNames
    DFFNamePlates.settings.WorldTextSettings["alwaysShow"] = enableAlwaysWorldText
    DFFNamePlates.settings.WorldTextSettings["worldTextSize"] = worldTextSizeSlider
    DFFNamePlates.settings.WorldTextSettings["worldTextAlpha"] = worldTextAlphaSlider
    DFFNamePlates.settings.WorldTextSettings["hidePlayerGuild"] = hidePlayerGuildCB
    DFFNamePlates.settings.WorldTextSettings["hidePlayerTitle"] = hidePlayerTitleCB
end
