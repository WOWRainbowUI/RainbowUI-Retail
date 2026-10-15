local L = setmetatable({}, {__index = function(_, key) return key end})
local locale = GetLocale()
if locale == "zhTW" then
L["ReloadUI"] = "重新載入按鈕"
L["Reload UI"] = "重新載入介面"
L["RELOAD UI"] = "重新載入"
L["Show Settings panel button"] = "顯示選項視窗按鈕"
L["Adds a Reload UI button to the bottom left corner of this Settings window."] = "在此選項視窗的左下角加入重新載入介面按鈕。"
L["Play sound on reload"] = "重新載入時播放音效"
L["Plays the menu sound when you reload from a button or keybind."] = "透過按鈕或快速鍵重新載入時播放選單音效。"
end
if locale == "zhCN" then
L["ReloadUI"] = "重新加载按钮"
L["Reload UI"] = "重新加载界面"
L["RELOAD UI"] = "重新加载"
L["Show Settings panel button"] = "显示设置窗口按钮"
L["Adds a Reload UI button to the bottom left corner of this Settings window."] = "在此设置窗口的左下角添加重新加载界面按钮。"
L["Play sound on reload"] = "重新加载时播放音效"
L["Plays the menu sound when you reload from a button or keybind."] = "通过按钮或快捷键重新加载时播放菜单音效。"
end
-- Made by Sharpedge_Gaming
-- 12.1.5

local ADDON_NAME = ...

-- Keybinding labels shown in Options > Keybindings > AddOns
BINDING_HEADER_RELOADUI = L["ReloadUI"]
BINDING_NAME_RELOADUI_RELOAD = L["Reload UI"]

-- Saved settings
local DEFAULTS = {
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
        button:SetText(L["RELOAD UI"])
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

    local category = Settings.RegisterVerticalLayoutCategory(L["ReloadUI"])

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
        "showSettingsButton",
        L["Show Settings panel button"],
        L["Adds a Reload UI button to the bottom left corner of this Settings window."],
        UpdateSettingsPanelButton
    )

    AddCheckbox(
        "playSound",
        L["Play sound on reload"],
        L["Plays the menu sound when you reload from a button or keybind."]
    )

    Settings.RegisterAddOnCategory(category)
    db.categoryID = category.ID
end

-- Events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitDB()
        RegisterOptions()
        CreateSettingsPanelButton()
    elseif event == "PLAYER_LOGIN" then
        if not db then InitDB() end
        RegisterOptions()
        CreateSettingsPanelButton()
        self:UnregisterAllEvents()
    end
end)
