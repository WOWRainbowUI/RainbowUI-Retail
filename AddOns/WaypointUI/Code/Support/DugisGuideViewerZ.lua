local env = select(2, ...)
local Config = env.Config
local MapPin = env.WPM:Import("@\\MapPin")
local Support = env.WPM:Import("@\\Support")
local Support_DugisGuideViewerZ = env.WPM:New("@\\Support\\DugisGuideViewerZ")
local function IsModuleEnabled() return Config.DBGlobal:GetVariable("DugisSupportEnabled") == true end

local DugisWaypointInfo = { name = nil, mapID = nil, x = nil, y = nil }


function Support_DugisGuideViewerZ.PlaceWaypointAtSession()
    MapPin.NewUserNavigation(DugisWaypointInfo.name, DugisWaypointInfo.mapID, DugisWaypointInfo.x, DugisWaypointInfo.y, "Dugis_Waypoint")
    Support_DugisGuideViewerZ.UpdateSuperTrackPinVisibility()
end

function Support_DugisGuideViewerZ.UpdateSuperTrackPinVisibility()
    MapPin.ToggleSuperTrackedPinDisplay(not MapPin.IsUserNavigationFlagged("Dugis_Waypoint"))
end

local function OnWaypointsChanged()
    if not IsModuleEnabled() then return end

    local activePoint = DugisArrowGlobal and DugisArrowGlobal.GetActivePoint and DugisArrowGlobal:GetActivePoint()
    if not activePoint or not activePoint.m then
        if MapPin.IsUserNavigationFlagged("Dugis_Waypoint") then
            MapPin.ClearUserNavigation()
        end
        return
    end

    local wp = activePoint.waypoint
    DugisWaypointInfo.name = (wp and wp.desc) or "Dugi Waypoint"
    DugisWaypointInfo.mapID = activePoint.m
    DugisWaypointInfo.x = activePoint.x * 100
    DugisWaypointInfo.y = activePoint.y * 100

    if Config.DBGlobal:GetVariable("DugisAutoReplaceWaypoint") == true or not C_SuperTrack.IsSuperTrackingAnything() or MapPin.IsUserNavigationFlagged("Dugis_Waypoint") then
        Support_DugisGuideViewerZ.PlaceWaypointAtSession()
    end
end

local function OnAddonLoad()
    local f = CreateFrame("Frame")
    f:RegisterEvent("USER_WAYPOINT_UPDATED")
    f:SetScript("OnEvent", function()
        Support_DugisGuideViewerZ.UpdateSuperTrackPinVisibility()
    end)

    local scanner = nil
    scanner = C_Timer.NewTicker(0.1, function()
        if DugisArrowGlobal and DugisArrowGlobal.WaypointsChanged and type(DugisArrowGlobal.WaypointsChanged) == "function" then
            hooksecurefunc(DugisArrowGlobal, "WaypointsChanged", OnWaypointsChanged)
            scanner:Cancel()
            scanner = nil
        end
    end)

    local UnloadEvent = CreateFrame("Frame")
    UnloadEvent:RegisterEvent("ADDONS_UNLOADING")
    UnloadEvent:SetScript("OnEvent", function()
        if MapPin.IsUserNavigationFlagged("Dugis_Waypoint") then
            MapPin.ClearUserNavigation()
        end
    end)
end

Support.Add("DugisGuideViewerZ", OnAddonLoad)
