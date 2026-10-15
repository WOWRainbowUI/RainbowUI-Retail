-- Made by Sharpedge_Gaming
-- 12.1.5

local ADDON_NAME = ...

-- Keybinding labels shown in Options > Keybindings > AddOns
BINDING_HEADER_RELOADUI = "ReloadUI"
BINDING_NAME_RELOADUI_RELOAD = "Reload UI"

-- Saved settings
local DEFAULTS = {
    showGameMenuButton = true,
    showSettingsButton = true,
    playSound = true,
}

local db

local function InitDB()
    if type(ReloadUIDB) ~= "table" then
        ReloadUIDB = {}
    end
    for key, value in pairs(DEFAULTS) do
        if ReloadUIDB[key] == nil then
            ReloadUIDB[key] = value
        end
    end
    db = ReloadUIDB
end

local function GetOption(key)
    if db and db[key] ~= nil then
        return db[key]
    end
    return DEFAULTS[key]
end

-- Helpers
local function IsElvUILoaded()
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded("ElvUI")
    elseif IsAddOnLoaded then
        return IsAddOnLoaded("ElvUI")
    end
    return false
end

local function SkinWithElvUI(button)
    if not button or button.isSkinned then return end
    if IsElvUILoaded() and ElvUI and ElvUI[1] and ElvUI[1].Skins and ElvUI[1].Skins.HandleButton then
        ElvUI[1].Skins:HandleButton(button)
    end
end

local function DoReload()
    if GetOption("playSound") then
        PlaySound(SOUNDKIT.IG_MAINMENU_LOGOUT)
    end
    ReloadUI()
end

-- Global entry point used by Bindings.xml
function ReloadUIAddon_DoReload()
    DoReload()
end

-- Game Menu button
-- Find the Log Out button among the menu's active pooled buttons.
-- Matches on the localized LOG_OUT global so it works in every client language.
local function FindLogoutButton(menu, ignore)
    if not menu.buttonPool then return nil end
    for button in menu.buttonPool:EnumerateActive() do
        if button ~= ignore and button.GetText and button:GetText() == LOG_OUT then
            return button
        end
    end
    return nil
end

-- Move our button into the slot directly above Log Out.
-- Every button at or after Log Out shifts down one layout slot,
-- then the menu relayouts and resizes itself around the new order.
local function MoveAboveLogout(menu, reloadButton)
    local logout = FindLogoutButton(menu, reloadButton)
    if not logout or not logout.layoutIndex then return end

    local targetIndex = logout.layoutIndex

    for button in menu.buttonPool:EnumerateActive() do
        if button ~= reloadButton and button.layoutIndex and button.layoutIndex >= targetIndex then
            button.layoutIndex = button.layoutIndex + 1
        end
    end

    reloadButton.layoutIndex = targetIndex

    -- Keep Reload UI in the group above Log Out so the section gap stays where Blizzard put it
    reloadButton.topPadding = nil

    if menu.MarkDirty then
        menu:MarkDirty()
    elseif menu.Layout then
        menu:Layout()
    end
end

-- The Game Menu rebuilds its buttons from a pool every time it opens, so the
-- show/hide option takes effect the next time the menu is opened.
local function AddGameMenuButton(menu)
    if not GetOption("showGameMenuButton") then return end
    if not menu or not menu.AddButton then return end

    local button = menu:AddButton("Reload UI", DoReload)
    if not button then return end

    MoveAboveLogout(menu, button)
    SkinWithElvUI(button)
end

local function HookGameMenu()
    if not GameMenuFrame or GameMenuFrame.__ReloadUIHooked then return end
    if GameMenuFrame.InitButtons then
        hooksecurefunc(GameMenuFrame, "InitButtons", AddGameMenuButton)
        GameMenuFrame.__ReloadUIHooked = true
    end
end

-- Settings Panel button
local function UpdateSettingsPanelButton()
    if SettingsPanelReloadUI then
        SettingsPanelReloadUI:SetShown(GetOption("showSettingsButton"))
    end
end

local function CreateSettingsPanelButton()
    if not SettingsPanel then return end

    if not SettingsPanelReloadUI then
        local button = CreateFrame("Button", "SettingsPanelReloadUI", SettingsPanel, "UIPanelButtonTemplate")
        button:SetText("RELOAD UI")
        button:SetSize(96, 22)
        button:SetPoint("BOTTOMLEFT", SettingsPanel, "BOTTOMLEFT", 16, 16)
        button:SetScript("OnClick", DoReload)
        SkinWithElvUI(button)
    end

    UpdateSettingsPanelButton()
end

-- Options page (Settings > AddOns > ReloadUI)
local optionsRegistered = false

local function RegisterOptions()
    if optionsRegistered or not Settings or not Settings.RegisterVerticalLayoutCategory then return end
    optionsRegistered = true

    local category = Settings.RegisterVerticalLayoutCategory("ReloadUI")

    local function AddCheckbox(key, label, tooltip, onChanged)
        local setting = Settings.RegisterAddOnSetting(
            category,
            "ReloadUI_" .. key,
            key,
            db,
            Settings.VarType.Boolean,
            label,
            DEFAULTS[key]
        )
        if onChanged then
            setting:SetValueChangedCallback(onChanged)
        end
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    AddCheckbox(
        "showGameMenuButton",
        "Show Game Menu button",
        "Adds a Reload UI button to the Escape menu, just above Log Out. Takes effect the next time the menu opens."
    )

    AddCheckbox(
        "showSettingsButton",
        "Show Settings panel button",
        "Adds a Reload UI button to the bottom left corner of this Settings window.",
        UpdateSettingsPanelButton
    )

    AddCheckbox(
        "playSound",
        "Play sound on reload",
        "Plays the menu sound when you reload from a button or keybind."
    )

    Settings.RegisterAddOnCategory(category)
end

-- Events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitDB()
        RegisterOptions()
        HookGameMenu()
        CreateSettingsPanelButton()
    elseif event == "PLAYER_LOGIN" then
        if not db then InitDB() end
        RegisterOptions()
        HookGameMenu()
        CreateSettingsPanelButton()
        self:UnregisterAllEvents()
    end
end)
