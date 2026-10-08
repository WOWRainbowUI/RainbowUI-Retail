-- Made by Sharpedge_Gaming
--  12.1.0

local function IsElvUILoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded("ElvUI")
    elseif IsAddOnLoaded then
        return IsAddOnLoaded("ElvUI")
    end
    return false
end

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