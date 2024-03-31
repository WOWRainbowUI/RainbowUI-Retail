-- ReloadUI
-- Made by Sharpedge_Gaming
-- v2.1 - 10.2.5

local function CreateGameMenuButton()
    local button = CreateFrame("Button", "GameMenuButtonReloadButton", GameMenuFrame, "GameMenuButtonTemplate")
    button:SetText(RELOADUI)
    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT)
        ReloadUI()
    end)

    if GameMenuFrame_UpdateVisibleButtons then
        hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", function()
            GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 25)
            local point, relativeTo, relativePoint, x, y = GameMenuButtonLogout:GetPoint(1)
            if relativeTo and relativeTo ~= button then
                button:SetPoint(point, relativeTo, relativePoint, x, y - 1)
            end
            GameMenuButtonLogout:ClearAllPoints()
            GameMenuButtonLogout:SetPoint("TOP", button, "BOTTOM", 0, -1)
        end)
    end
end

local function CreateSettingsPanelButton()
    local button = CreateFrame("Button", "SettingsPanelReloadUI", SettingsPanel, "UIPanelButtonTemplate")
    button:SetText(RELOADUI)
    button:SetSize(96, 22)
    button:SetPoint("BOTTOMLEFT", SettingsPanel, "BOTTOMLEFT", 16, 16)
    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT)
        ReloadUI()
        HideUIPanel(InterfaceOptionsFrame)
    end)
end

local function InitializeButtons()
    CreateGameMenuButton()
    CreateSettingsPanelButton()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ReloadUI" then
        InitializeButtons()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)




























