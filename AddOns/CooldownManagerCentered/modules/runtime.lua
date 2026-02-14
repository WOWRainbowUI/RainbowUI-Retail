local _, ns = ...

local Runtime = {}
ns.Runtime = Runtime

local function UpdateRuntime()
    if Runtime.isInEditMode or Runtime.hasSettingsOpened then
        Runtime.stop = true
    else
        Runtime.stop = false
    end
end

Runtime.stop = false
Runtime.isInEditMode = false
Runtime.hasSettingsOpened = false

local viewers = {
    ["BuffIconCooldownViewer"] = BuffIconCooldownViewer,
    ["BuffBarCooldownViewer"] = BuffBarCooldownViewer,
    ["EssentialCooldownViewer"] = EssentialCooldownViewer,
    ["UtilityCooldownViewer"] = UtilityCooldownViewer,
}

function Runtime:IsReady(viewerNameOrFrame)
    local viewer = nil
    if type(viewerNameOrFrame) == "string" then
        viewer = _G[viewerNameOrFrame]
    elseif type(viewerNameOrFrame) == "table" then
        viewer = viewerNameOrFrame
    end
    if not viewer or not viewer.IsInitialized or not EditModeManagerFrame then
        return false
    end

    if EditModeManagerFrame.layoutApplyInProgress or not viewer:IsInitialized() then
        return false
    end

    return true
end

function Runtime:IsAllReady()
    for _, viewer in pairs(viewers) do
        if not self:IsReady(viewer) then
            return false
        end
    end
    return true
end

function Runtime:ShowAll()
    if C_CVar.GetCVar("cooldownViewerEnabled") ~= "1" then
        return
    end
    for _, viewer in pairs(viewers) do
        if viewer then
            local visibleSetting = viewer.visibleSetting
            local forceShow = false
            if visibleSetting == Enum.CooldownViewerVisibleSetting.Always then
                forceShow = true
            elseif visibleSetting == Enum.CooldownViewerVisibleSetting.InCombat then
                forceShow = InCombatLockdown()
            elseif visibleSetting == Enum.CooldownViewerVisibleSetting.Hidden then
                -- Don't show
            end
            if not viewer:IsShown() and forceShow then
                ShowUIPanel(viewer)
            end
        end
    end
end

EventRegistry:RegisterCallback("CooldownViewerSettings.OnDataChanged", function()
    if not Runtime:IsAllReady() then
        return
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end)
EventRegistry:RegisterCallback("CooldownViewerSettings.OnShow", function()
    Runtime.hasSettingsOpened = true
    UpdateRuntime()
    if not Runtime:IsAllReady() then
        return
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end)
EventRegistry:RegisterCallback("CooldownViewerSettings.OnHide", function()
    Runtime.hasSettingsOpened = false
    UpdateRuntime()
    if not Runtime:IsAllReady() then
        return
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end)
EventRegistry:RegisterCallback("EditMode.Enter", function()
    Runtime.isInEditMode = true
    UpdateRuntime()
    if not Runtime:IsAllReady() then
        return
    end
    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end)

EventRegistry:RegisterCallback("EditMode.Exit", function()
    Runtime.isInEditMode = false
    UpdateRuntime()
    if not Runtime:IsAllReady() then
        return
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end)
local EventHandler = {}
EventHandler.events = {}
EventHandler.frame = CreateFrame("FRAME")

EventHandler.events["PLAYER_ENTERING_WORLD"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end
    Runtime:ShowAll()

    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
        C_Timer.After(0, function()
            if ns.CooldownManager then
                ns.CooldownManager.ForceRefreshAll()
            end
        end)
    end)
end

EventHandler.events["EDIT_MODE_LAYOUTS_UPDATED"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end

EventHandler.events["TRAIT_CONFIG_UPDATED"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshAll()
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefreshAll()
        end
    end)
end
EventHandler.events["PLAYER_SPECIALIZATION_CHANGED"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end
    if ns.StyledIcons then
        ns.StyledIcons:RefreshAll()
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
end
EventHandler.events["UPDATE_SHAPESHIFT_FORM"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
end
EventHandler.events["PLAYER_REGEN_DISABLED"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
end
EventHandler.events["CINEMATIC_STOP"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
end
EventHandler.events["SPELL_UPDATE_COOLDOWN"] = function(self, event, ...)
    if not Runtime:IsAllReady() then
        return
    end
    C_Timer.After(0, function()
        if ns.CooldownManager then
            ns.CooldownManager.ForceRefresh({ utility = true })
        end
    end)
end

for event, handler in pairs(EventHandler.events) do
    EventHandler.frame:RegisterEvent(event)
end

EventHandler.frame:SetScript("OnEvent", function(self, event, ...)
    EventHandler.events[event](self, event, ...)
end)

hooksecurefunc(BuffIconCooldownViewer, "RefreshLayout", function()
    if not Runtime:IsReady(BuffIconCooldownViewer) then
        return
    end
    if ns.StyledIcons then
        ns.StyledIcons:RefreshViewer("BuffIcons")
    end
    if ns.CooldownFont then
        ns.CooldownFont:RefreshViewer("BuffIconCooldownViewer")
    end
    if ns.Swipe then
        ns.Swipe:RefreshViewer("BuffIconCooldownViewer")
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefresh({ icons = true })
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshViewer("BuffIcons")
        end

        if ns.CooldownManager then
            ns.CooldownManager.ForceRefresh({ icons = true })
        end
    end)
end)
hooksecurefunc(BuffBarCooldownViewer, "RefreshLayout", function()
    if not Runtime:IsReady(BuffBarCooldownViewer) then
        return
    end
    if ns.CooldownManager then
        ns.CooldownManager.ForceRefresh({ bars = true })
    end
end)
hooksecurefunc(EssentialCooldownViewer, "RefreshLayout", function()
    if not Runtime:IsReady(EssentialCooldownViewer) then
        return
    end
    if ns.StyledIcons then
        ns.StyledIcons:RefreshViewer("Essential")
    end
    if ns.CooldownFont then
        ns.CooldownFont:RefreshViewer("EssentialCooldownViewer")
    end
    if ns.Swipe then
        ns.Swipe:RefreshViewer("EssentialCooldownViewer")
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefresh({ essential = true })
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshViewer("Essential")
        end
        if ns.CooldownManager then
            ns.CooldownManager.ForceRefresh({ essential = true })
        end
    end)
end)
hooksecurefunc(UtilityCooldownViewer, "RefreshLayout", function()
    if not Runtime:IsReady(UtilityCooldownViewer) then
        return
    end
    if ns.StyledIcons then
        ns.StyledIcons:RefreshViewer("Utility")
    end
    if ns.CooldownFont then
        ns.CooldownFont:RefreshViewer("UtilityCooldownViewer")
    end
    if ns.Swipe then
        ns.Swipe:RefreshViewer("UtilityCooldownViewer")
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefresh({ utility = true })
    end
    C_Timer.After(0, function()
        if ns.StyledIcons then
            ns.StyledIcons:RefreshViewer("Utility")
        end
        if ns.CooldownManager then
            ns.CooldownManager.ForceRefresh({ utility = true })
        end
    end)
end)
