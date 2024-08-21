--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local _, KT = ...

-- Deactivate Blizzard Tracker
ObjectiveTrackerFrame:Hide()
hooksecurefunc(ObjectiveTrackerFrame, "Show", function(self)
    self:Hide()
end)
hooksecurefunc(ObjectiveTrackerFrame, "SetShown", function(self, show)
    if show then
        self:Hide()
    end
end)
EventRegistry:UnregisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", ObjectiveTrackerManager)

-- Utils
function KT.BackupMixin(mixin, method)
    KT[mixin] = KT[mixin] or {}
    KT[mixin][method] = _G[mixin][method]
    _G[mixin][method] = nil
end