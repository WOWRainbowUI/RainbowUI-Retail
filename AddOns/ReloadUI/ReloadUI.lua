-- Made by Sharpedge_Gaming
-- v2.2 - 11.0.2
--[[
local function CreateGameMenuButton()
    local button = CreateFrame("Button", "GameMenuButtonReloadButton", GameMenuFrame, "GameMenuButtonTemplate")
    button:SetText(RELOADUI)
    
    button:SetSize(200, 30)  
    
    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT)
        ReloadUI()
    end)
	
	 button:GetFontString():SetFont(STANDARD_TEXT_FONT, 15) 

    GameMenuFrame:HookScript("OnShow", function()
        GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 25)

        if GameMenuButtonLogout then
            button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 28, -315)  
            GameMenuButtonLogout:ClearAllPoints()
            GameMenuButtonLogout:SetPoint("TOP", button, "BOTTOM", 0, -1)  
        else
            button:SetPoint("TOPLEFT", GameMenuFrame, "TOPLEFT", 28, -115)
        end
    end)
end
--]]
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
    -- CreateGameMenuButton()
    CreateSettingsPanelButton()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ReloadUI" then
        C_Timer.After(0.1, InitializeButtons)
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Add reload option to addon action forbidden
do local ADDON_ACTION_FORBIDDEN = StaticPopupDialogs.ADDON_ACTION_FORBIDDEN;
	ADDON_ACTION_FORBIDDEN.button3 = RELOADUI;
	ADDON_ACTION_FORBIDDEN.OnAlt = ReloadUI;
end































