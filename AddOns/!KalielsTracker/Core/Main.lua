--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local Noop = function() end

-- Deactivate Blizzard Tracker
ObjectiveTrackerManager.AddContainer = Noop
ObjectiveTrackerManager.AssignModulesOrder = Noop
ObjectiveTrackerManager.SetModuleContainer = Noop
ObjectiveTrackerManager.UpdateAll = Noop
ObjectiveTrackerFrame:UnregisterAllEvents()
ObjectiveTrackerFrame:Hide()
hooksecurefunc(ObjectiveTrackerFrame, "Show", function(self)
    self:Hide()
end)
hooksecurefunc(ObjectiveTrackerFrame, "SetShown", function(self, show)
    if show then
        self:Hide()
    end
end)

-- Event Bridge
do
    local THROTTLE_SECONDS = 0.2
    local lastUpdate = 0
    ObjectiveTrackerFrame:HookScript("OnEvent", function(self, event, ...)
        if event == "SUPER_TRACKING_PATH_UPDATED" then
            local now = GetTime()
            if (now - lastUpdate) < THROTTLE_SECONDS then return end
            lastUpdate = now

            KT_QuestObjectiveTracker:MarkDirty()
            KT_CampaignQuestObjectiveTracker:MarkDirty()
            KT_WorldQuestObjectiveTracker:MarkDirty()
        end
    end)
    ObjectiveTrackerFrame:RegisterEvent("SUPER_TRACKING_PATH_UPDATED")
end

-- Utils
function KT.BackupMixin(mixin, method)
    KT[mixin] = KT[mixin] or {}
    KT[mixin][method] = _G[mixin][method]
    _G[mixin][method] = nil
end