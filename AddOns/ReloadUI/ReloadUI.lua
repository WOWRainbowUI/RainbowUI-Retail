-- Made by Sharpedge_Gaming
--  11.2

local function IsElvUILoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded("ElvUI")
    elseif IsAddOnLoaded then
        return IsAddOnLoaded("ElvUI")
    end
    return false
end

local function PlaceReloadUIButton()
    -- Remove old button if it exists (avoid stacking)
    if GameMenuButtonReloadButton then
        GameMenuButtonReloadButton:Hide()
        GameMenuButtonReloadButton:SetParent(nil)
        GameMenuButtonReloadButton = nil
    end

    local button = CreateFrame("Button", "GameMenuButtonReloadButton", GameMenuFrame, "GameMenuButtonTemplate")
    button:SetText(RELOADUI)
    button:SetSize(200, 28)
    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT)
        ReloadUI()
    end)
    button:GetFontString():SetFont(STANDARD_TEXT_FONT, 15)

    local isElvUI = IsElvUILoaded()

    -- ElvUI skinning
    if isElvUI and ElvUI and ElvUI[1] and ElvUI[1].Skins and ElvUI[1].Skins.HandleButton then
        ElvUI[1].Skins:HandleButton(button)
    end

    if GameMenuButtonLogout then
        button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 28, -115)
        GameMenuButtonLogout:ClearAllPoints()
        GameMenuButtonLogout:SetPoint("TOP", button, "BOTTOM", 0, -1)
    else
        if isElvUI then
            button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 28, -347)
        else
            button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 28, -315)
        end
    end
end

local function TryHookGameMenu()
    if GameMenuFrame then
        if not GameMenuFrame.__ReloadUIHooked then
            GameMenuFrame:HookScript("OnShow", PlaceReloadUIButton)
            GameMenuFrame.__ReloadUIHooked = true
        end
    else
        C_Timer.After(0.1, TryHookGameMenu)
    end
end

--[[ -- 自行修改
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "ElvUI" or arg1 == "ReloadUI" then
            C_Timer.After(0.1, TryHookGameMenu)
        end
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(0.1, TryHookGameMenu)
    end
end)
--]]

-- SettingsPanel button logic
local function CreateSettingsPanelButton()
    if SettingsPanelReloadUI then return end 

    local button = CreateFrame("Button", "SettingsPanelReloadUI", SettingsPanel, "UIPanelButtonTemplate")
    button:SetText(RELOADUI)
    button:SetSize(96, 22)
    button:SetPoint("BOTTOMLEFT", SettingsPanel, "BOTTOMLEFT", 16, 16)
    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT)
        ReloadUI()
        HideUIPanel(InterfaceOptionsFrame)
    end)

    -- ElvUI skinning for SettingsPanel button
    if IsElvUILoaded() and ElvUI and ElvUI[1] and ElvUI[1].Skins and ElvUI[1].Skins.HandleButton then
        ElvUI[1].Skins:HandleButton(button)
    end
end

-- SettingsPanel hook
local sf = CreateFrame("Frame")
sf:RegisterEvent("ADDON_LOADED")
sf:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "ReloadUI" then
        C_Timer.After(0.1, CreateSettingsPanelButton)
        self:UnregisterEvent("ADDON_LOADED")
    end
end)