local _, ns = ...
local addon = ns.Addon

function addon:OpenSettings()
    if InCombatLockdown() then
        ns.Addon:Print("Cannot open settings panel while in combat.")
        return
    end
    if ns.WilduSettings then
        local id = ns.WilduSettings.SettingsLayout.rootCategory:GetID()
        Settings.OpenToCategory(id)
    end
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CooldownManagerCenteredDB", ns.DEFAULT_SETTINGS, true)
    ns.db = self.db

    -- Register database callbacks for profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    self.db.RegisterCallback(self, "OnNewProfile", "OnNewProfile")
    self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileDeleted")

    if ns.WilduSettings then
        ns.WilduSettings:RegisterSettings()
        ns.WilduSettings:InitializeSettings()
    end
end
local openCooldownViewerSettings = function()
    if not InCombatLockdown() then
        CooldownViewerSettings:ShowUIPanel(false)
    else
        ns.Addon:Print("Cannot open Cooldown Viewer settings while in combat.")
    end
end

SLASH_CMC_CVS1 = "/cds"
SLASH_CMC_CVS2 = "/cdm"
SlashCmdList["CMC_CVS"] = openCooldownViewerSettings
SLASH_CMC_SETTINGS1 = "/cmc"
SlashCmdList["CMC_SETTINGS"] = function()
    addon:OpenSettings()
end

function addon:RefreshConfig()
    if ns.StyledIcons then
        ns.StyledIcons:Initialize()
    end
    if ns.CooldownManager then
        ns.CooldownManager.Initialize()
    end
    if ns.Stacks then
        ns.Stacks:Initialize()
    end
    if ns.Keybinds then
        ns.Keybinds:Initialize()
    end
    if ns.Assistant then
        ns.Assistant:Initialize()
    end
    if ns.Swipe then
        ns.Swipe:Initialize()
    end
    if ns.CooldownFont then
        ns.CooldownFont:Initialize()
    end
    if ns.NoAuras then
        ns.NoAuras:Initialize()
    end
    if ns.TrinketRacialTracker then
        ns.TrinketRacialTracker:Initialize()
    end

    ns.API:RefreshCooldownManager()
    ns.API:ShowReloadUIConfirmation()
    self:Print("Profile settings applied.")
end

function addon:OnNewProfile(event, db, profile)
    self:Print("Created new profile: " .. profile)
end

function addon:OnProfileDeleted(event, db, profile)
    self:Print("Deleted profile: " .. profile)
end

local function _cleanup()
    ns.db.profile.cooldownManager_forceCenterX_BuffIcons = nil
    ns.db.profile.cooldownManager_forceCenterX_Essential = nil
    ns.db.profile.cooldownManager_forceCenterX_Utility = nil
    ns.db.profile.cooldownManager_forceCenterX_BuffIcons_lastY = nil
    ns.db.profile.cooldownManager_forceCenterX_Essential_lastY = nil
    ns.db.profile.cooldownManager_forceCenterX_Utility_lastY = nil

    ns.db.profile.cooldownManager_experimental_subsequentRowScaling = nil
    ns.db.profile.cooldownManager_experimental_subsequentRowScaling_Essential = nil
    ns.db.profile.cooldownManager_experimental_subsequentRowScaling_Utility = nil

    if ns.db.profile.cooldownManager_experimental_buttonPress ~= nil then
        ns.db.profile.cooldownManager_buttonPress = ns.db.profile.cooldownManager_experimental_buttonPress
        ns.db.profile.cooldownManager_experimental_buttonPress = nil
    end
end

function addon:OnEnable()
    C_CVar.SetCVar("cooldownViewerEnabled", "1")
    if ns.StyledIcons then
        ns.StyledIcons:Initialize()
    end
    if ns.CooldownManager then
        ns.CooldownManager.Initialize()
    end
    if ns.Stacks then
        ns.Stacks:Initialize()
    end
    if ns.Keybinds then
        ns.Keybinds:Initialize()
    end
    if ns.Assistant then
        ns.Assistant:Initialize()
    end
    if ns.Swipe then
        ns.Swipe:Initialize()
    end
    if ns.CooldownFont then
        ns.CooldownFont:Initialize()
    end
    if ns.NoAuras then
        ns.NoAuras:Initialize()
    end
    if ns.TrinketRacialTracker then
        ns.TrinketRacialTracker:Initialize()
    end
    _cleanup()
    ns.ButtonPress:Initialize()
end
local gameVersion = select(1, GetBuildInfo())
addon.isMidnight = gameVersion:match("^12")
addon.isRetail = gameVersion:match("^11")

C_Timer.After(2, function()
    local time = C_DateAndTime.GetCurrentCalendarTime()
    local askedDate = time.year * 10000 + time.month * 100 + time.monthDay

    if
        ns.API:IsElvUICDMSkinningEnabled()
        and (ns.StyledIcons:IsAnyStyledFeatureEnabled() or ns.Stacks:IsAnyStacksFeatureEnabled())
        and (
            not ns.db.profile._elvui_skinning_asked
            or (ns.db.profile._elvui_skinning_asked < askedDate - 4 or ns.db.profile._elvui_skinning_asked < 10000)
        )
    then
        StaticPopup_Show("CMC_ELVUI_SKINNING_ASK")
        ns.db.profile._elvui_skinning_asked = askedDate
    end
end)

local AddOnFrame = CreateFrame("Frame")
AddOnFrame:RegisterEvent("ADDON_LOADED")
AddOnFrame:SetScript("OnEvent", function(_, event, argument)
    if not ns.db.profile.cooldownManager_buttonPress then
        return
    end
    if event == "ADDON_LOADED" and argument == "Dominos" then
        ns.ButtonPress:HookAllDominosButtons()
    end
    if event == "ADDON_LOADED" and argument == "ElvUI" then
        ns.ButtonPress:RegisterElvUICallbacks()
    end
end)
