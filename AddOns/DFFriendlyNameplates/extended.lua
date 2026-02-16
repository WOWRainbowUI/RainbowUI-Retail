local _, DFFN = ...
local HttpsxLib = DFFN.httpsxLib
local DFFNamePlates = DFFN.DFFNamePlates
local module = {}

module.tab = DFFNamePlates:AddTabButton("Extended", 3, module)

function module:OnLoad()
    local tab = self.tab

    if not tab then return end

    local content = tab.frame

    local blizzardSizeTile = HttpsxLib:CreateText(content, "Blizzard Nameplate Size", "TOPLEFT", content, "TOPLEFT", 75,
        -50,
        11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local blizzardSizeSlider = HttpsxLib:CreateSlider(content, 140, 1, 5, 1, "TOPLEFT", content, 75, -67,
        1,
        function(self, value)
            SetCVar("nameplateSize", value);
        end)

    local blizzardStyleTitle = HttpsxLib:CreateText(content, "Blizzard Style:", "TOPLEFT", content, "TOPLEFT", 10, -130,
        11.5,
        { 0.9, 0.9, 0.9, 1 }, "")

    local styles = {
        { text = "Modern (0)",       value = "0" },
        { text = "Thin Bars (1)",    value = "1" },
        { text = "Blocky Bars (2)",  value = "2" },
        { text = "Clean Health (4)", value = "3" },
        { text = "Blocky Cast (5)",  value = "4" },
        { text = "Legacy Red (6)",   value = "5" },
    }

    local blizzardStyleDropdown = HttpsxLib:CreateDropDown(content, 140, styles, "LEFT", blizzardStyleTitle, 95, 0,
        "Outline, Slug",
        function(self, value, text)
            if value == nil or text == nil then return end
            SetCVar("nameplateStyle", value);
        end)

    local hideInOpenWorldCB = HttpsxLib:CreateCheckBox(content, "Hide Friendly Nameplates in Open World", "TOPLEFT",
        content, 10, -170)

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

    local customWidthCB = HttpsxLib:CreateCheckBox(content, "Custom Width", "TOPLEFT", content, 10, -230)

    local customWidthBox = HttpsxLib:CreateNumberEditBox(content, 50, 20, "RIGHT", customWidthCB.text, 110, 0, 132,
        function(self, value)
            C_NamePlate.SetNamePlateSize(value, 26);
            DFFNamePlates:reloadNP()
        end
    )

    customWidthCB:Hide()  --Disabled until Blizzard separates width settings for friendly and enemy nameplates
    customWidthBox:Hide() --Disabled until Blizzard separates width settings for friendly and enemy nameplates

    local moreSettingsButton = HttpsxLib:CreateButton(content, "Open Blizzard Nameplate settings", 280, 25, "TOPLEFT",
        content, 10, -340)
    moreSettingsButton.icon = moreSettingsButton:CreateTexture(nil, "OVERLAY")
    moreSettingsButton.icon:SetSize(26, 26)
    moreSettingsButton.icon:SetPoint("LEFT", moreSettingsButton, "LEFT", 4, 1)
    moreSettingsButton.icon:SetTexture("interface\\hud\\uigroupmanager")
    moreSettingsButton.icon:SetTexCoord(0.9365234375, 0.9755859375, 0.1220703125, 0.0830078125)

    moreSettingsButton:SetScript("OnClick", function()
        Settings.OpenToCategory(60)
    end)

    DFFNamePlates.settings.ExtendedSettings = {}
    DFFNamePlates.settings.ExtendedSettings["blizzardSize"] = blizzardSizeSlider
    DFFNamePlates.settings.ExtendedSettings["blizzardStyle"] = blizzardStyleDropdown
    DFFNamePlates.settings.ExtendedSettings["hideInOpenWorld"] = hideInOpenWorldCB
end
