--[[
    WaypointUI API Documentation

    `WaypointUIAPI.Navigation`
        `ClearDestination()`                            -- Clears any active navigation (user waypoint or supertracked content)
        `ClearUserNavigation()`                         -- Clears the current user-placed waypoint marker
        `GetUserNavigation()`                           -- Returns the current waypoint session info (name, mapID, x, y, flags) or nil
        `NewUserNavigation(name, mapID, x, y, flags)`   -- Creates and tracks a new user waypoint at the specified coordinates
        `IsUserNavigationTracked()`                     -- Returns true if a user waypoint is currently being tracked

    `WaypointUIAPI.OpenSettingUI()`
]]

local env = select(2, ...)
WaypointUIAPI = WaypointUIAPI or {}

do -- @\\MapPin
    local MapPin = env.WPM:Await("@\\MapPin")
    WaypointUIAPI.Navigation = {
        ClearDestination        = MapPin.ClearDestination,
        ClearUserNavigation     = MapPin.ClearUserNavigation,
        GetUserNavigation       = MapPin.GetUserNavigation,
        NewUserNavigation       = MapPin.NewUserNavigation,
        IsUserNavigationTracked = MapPin.IsUserNavigationTracked
    }
end

do -- @\\Setting
    local Setting = env.WPM:Await("@\\Setting")
    WaypointUIAPI_OpenSettingUI = Setting.OpenSettingUI
    WaypointUIAPI.OpenSettingUI = Setting.OpenSettingUI
end
