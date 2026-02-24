local _, ns = ...

local CMCVisibility = {}
ns.CMCVisibility = CMCVisibility

local clientSceneActive = false
local inCombat = InCombatLockdown()

local viewers = {
    {
        viewer = _G["BuffIconCooldownViewer"],
        viewerName = "BuffIconCooldownViewer",
    },
    {
        viewer = _G["BuffBarCooldownViewer"],
        viewerName = "BuffBarCooldownViewer",
    },
    {
        viewer = _G["EssentialCooldownViewer"],
        viewerName = "EssentialCooldownViewer",
    },
    {
        viewer = _G["UtilityCooldownViewer"],
        viewerName = "UtilityCooldownViewer",
    },
    {
        viewer = _G["CMCTracker1"],
        viewerName = "CMCTracker1",
        settingsKey = "tracker1",
    },
    {
        viewer = _G["CMCTracker2"],
        viewerName = "CMCTracker2",
        settingsKey = "tracker2",
    },
}

function CMCVisibility:Update(viewer, viewerName, settingsKey)
    if not viewer then
        if _G[viewerName] then
            viewer = _G[viewerName]
            for _, v in ipairs(viewers) do
                if v.viewerName == viewerName then
                    v.viewer = viewer
                    break
                end
            end
        else
            return
        end
    end

    if
        not ns.db.profile.cooldownManager_visibility_enabled_rules
        or ns.API:GetTableLength(ns.db.profile.cooldownManager_visibility_enabled_rules) == 0
    then
        return
    end

    local isMounted = IsMounted()
    local shapeshiftFormID = GetShapeshiftFormID()
    local hasTarget = UnitExists("target")

    local rules = ns.db.profile.cooldownManager_visibility_enabled_rules
    local alpha = 1
    if settingsKey then
        alpha = ns.db.profile.editMode[settingsKey].alpha
    elseif viewer.settingMap and viewer.settingMap[Enum.EditModeCooldownViewerSetting.Opacity] then
        alpha = (viewer.settingMap[Enum.EditModeCooldownViewerSetting.Opacity].value + 50) / 100
    end

    if rules.SHOW_IN_COMBAT and (inCombat or InCombatLockdown()) then
        viewer:SetAlpha(alpha)
        return
    end
    if
        rules.HIDE_IN_VEHICLES and (clientSceneActive or C_ActionBar.HasOverrideActionBar() or UnitInVehicle("player"))
    then
        viewer:SetAlpha(0)
        return
    end
    if rules.SHOW_WITH_TARGET and hasTarget then
        viewer:SetAlpha(alpha)
        return
    end
    if
        rules.HIDE_WHEN_MOUNTED
        and (isMounted or shapeshiftFormID == 3 or shapeshiftFormID == 29 or shapeshiftFormID == 27)
    then
        viewer:SetAlpha(0)
        return
    end
    if rules.HIDE_OUT_OF_COMBAT and not inCombat then
        viewer:SetAlpha(0)
        return
    end

    viewer:SetAlpha(alpha)
end

function CMCVisibility:UpdateAll()
    for _, viewerData in ipairs(viewers) do
        local viewer = viewerData.viewer
        local viewerName = viewerData.viewerName
        local settingsKey = viewerData.settingsKey
        self:Update(viewer, viewerName, settingsKey)
    end
end

local EventFrame = CreateFrame("Frame")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "CLIENT_SCENE_OPENED" then
        local sceneType = ...
        clientSceneActive = (sceneType == 1)
    elseif event == "CLIENT_SCENE_CLOSED" then
        clientSceneActive = false
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    end

    CMCVisibility:UpdateAll()
end)

local isInitialized = false
function CMCVisibility:Initialize()
    if
        not ns.db.profile.cooldownManager_visibility_enabled_rules
        or ns.API:GetTableLength(ns.db.profile.cooldownManager_visibility_enabled_rules) == 0
    then
        CMCVisibility:DeInitialize()
        return
    end
    if not isInitialized then
        EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        EventFrame:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
        EventFrame:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
        EventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
        EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        EventFrame:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
        EventFrame:RegisterEvent("CLIENT_SCENE_OPENED")
        EventFrame:RegisterEvent("CLIENT_SCENE_CLOSED")
        EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        EventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    end
    self:UpdateAll()
    isInitialized = true
end

function CMCVisibility:DeInitialize()
    EventFrame:UnregisterAllEvents()
    isInitialized = false

    for _, viewerData in ipairs(viewers) do
        local viewer = viewerData.viewer
        local settingsKey = viewerData.settingsKey

        if viewer then
            local alpha
            local alpha = 1
            if settingsKey then
                alpha = ns.db.profile.editMode[settingsKey].alpha
            elseif viewer.settingMap and viewer.settingMap[Enum.EditModeCooldownViewerSetting.Opacity] then
                alpha = (viewer.settingMap[Enum.EditModeCooldownViewerSetting.Opacity].value + 50) / 100
            end

            viewer:SetAlpha(alpha)
        end
    end
end
