local env = select(2, ...)
local Config = env.Config
local Sound = env.WPM:Import("wpm_modules\\sound")
local CallbackRegistry = env.WPM:Import("wpm_modules\\callback-registry")
local MapPin = env.WPM:New("@\\MapPin")

local SetSuperTrackedUserWaypoint = C_SuperTrack.SetSuperTrackedUserWaypoint
local IsSuperTrackingAnything = C_SuperTrack.IsSuperTrackingAnything
local ClearAllSuperTracked = C_SuperTrack.ClearAllSuperTracked
local GetHighestPrioritySuperTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType
local CanSetUserWaypointOnMap = C_Map.CanSetUserWaypointOnMap
local SetUserWaypoint = C_Map.SetUserWaypoint
local ClearUserWaypoint = C_Map.ClearUserWaypoint
local HasUserWaypoint = C_Map.HasUserWaypoint
local CreateFrame = CreateFrame
local tostring = tostring

local SessionData = {
    name  = nil,
    mapID = nil,
    x     = nil,
    y     = nil,
    flags = nil
}

local function GetUserWaypointPosition()
    local userWaypoint = C_Map.GetUserWaypoint()
    if not userWaypoint then return nil end

    return userWaypoint.uiMapID, userWaypoint.position
end

local function ApplySavedNavigation(saved)
    if not saved then return SessionData end

    SessionData.name = saved.name
    SessionData.mapID = saved.mapID
    SessionData.x = saved.x
    SessionData.y = saved.y
    SessionData.flags = saved.flags

    return SessionData
end

local function PlayUserNavigationAudio()
    local Setting_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.NewUserNavigation

    if Setting_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation")
        end
    end

    Sound.PlaySound("Main", soundID)
end

function MapPin.ClearUserNavigation()
    if MapPin.GetUserNavigation() then ClearUserWaypoint() end
    MapPin.SetUserNavigation(nil, nil, nil, nil, nil)
end

function MapPin.ClearDestination()
    if MapPin.IsUserNavigationTracked() then
        MapPin.ClearUserNavigation()
    end

    if IsSuperTrackingAnything() then
        ClearAllSuperTracked()
    end
end

function MapPin.SetUserNavigation(name, mapID, x, y, flags)
    SessionData.name = name
    SessionData.mapID = mapID
    SessionData.x = x
    SessionData.y = y
    SessionData.flags = flags
    Config.DBLocal:SetVariable("slashWayCache", SessionData)
end

function MapPin.GetUserNavigation()
    local savedWay = Config.DBLocal:GetVariable("slashWayCache")
    local navigation = ApplySavedNavigation(savedWay)
    if not savedWay then
        Config.DBLocal:SetVariable("slashWayCache", navigation)
    end
    return navigation
end

function MapPin.NewUserNavigation(name, mapID, x, y, flags)
    if not mapID or not x or not y then return end

    if x > 100 or y > 100 or x < 0 or y < 0 then
        local mapInfo = C_Map.GetMapInfo(mapID)
        if mapInfo and mapInfo.parentMapID and mapInfo.parentMapID ~= 0 then
            local parentMapID = mapInfo.parentMapID
            if not CanSetUserWaypointOnMap(parentMapID) then return end
            local _, childOrigin = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
            local _, childRightEdge = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 0))
            local _, childBottomEdge = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 1))
            local _, parentOrigin = C_Map.GetWorldPosFromMapPos(parentMapID, CreateVector2D(0, 0))
            local _, parentRightEdge = C_Map.GetWorldPosFromMapPos(parentMapID, CreateVector2D(1, 0))
            local _, parentBottomEdge = C_Map.GetWorldPosFromMapPos(parentMapID, CreateVector2D(0, 1))
            if childOrigin and childRightEdge and childBottomEdge and parentOrigin and parentRightEdge and parentBottomEdge then
                local normalizedX, normalizedY = x / 100, y / 100
                local worldX = childOrigin.x + normalizedX * (childRightEdge.x - childOrigin.x) + normalizedY * (childBottomEdge.x - childOrigin.x)
                local worldY = childOrigin.y + normalizedX * (childRightEdge.y - childOrigin.y) + normalizedY * (childBottomEdge.y - childOrigin.y)
                local offsetX, offsetY = worldX - parentOrigin.x, worldY - parentOrigin.y
                local parentBasisXx, parentBasisYx = parentRightEdge.x - parentOrigin.x, parentBottomEdge.x - parentOrigin.x
                local parentBasisXy, parentBasisYy = parentRightEdge.y - parentOrigin.y, parentBottomEdge.y - parentOrigin.y
                local determinant = parentBasisXx * parentBasisYy - parentBasisYx * parentBasisXy
                if determinant ~= 0 then
                    local parentNormalizedX = (offsetX * parentBasisYy - offsetY * parentBasisYx) / determinant * 100
                    local parentNormalizedY = (offsetY * parentBasisXx - offsetX * parentBasisXy) / determinant * 100
                    return MapPin.NewUserNavigation(name, parentMapID, parentNormalizedX, parentNormalizedY, flags)
                end
            end
        end
        return
    end

    if not CanSetUserWaypointOnMap(mapID) then return end

    local pos = CreateVector2D(x / 100, y / 100)
    local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)

    MapPin.SetUserNavigation(name, mapID, pos.x, pos.y, flags)
    SetUserWaypoint(mapPoint)
    SetSuperTrackedUserWaypoint(true)

    CallbackRegistry.Trigger("MapPin.NewUserNavigation")

    PlayUserNavigationAudio()
end

function MapPin.IsUserNavigationTracked()
    if not HasUserWaypoint() then return false end

    local pinTracked = GetHighestPrioritySuperTrackingType() == Enum.SuperTrackingType.UserWaypoint
    local waypointMapID, waypointPos = GetUserWaypointPosition()
    local currentUserNavigationInfo = MapPin.GetUserNavigation()

    if not waypointMapID or not waypointPos then return false end
    if not currentUserNavigationInfo or not currentUserNavigationInfo.mapID or not currentUserNavigationInfo.x or not currentUserNavigationInfo.y then return false end

    local mapIDMatch = tostring(waypointMapID) == tostring(currentUserNavigationInfo.mapID)
    local xMatch = string.format("%0.1f", waypointPos.x * 100) == string.format("%0.1f", currentUserNavigationInfo.x * 100)
    local yMatch = string.format("%0.1f", waypointPos.y * 100) == string.format("%0.1f", currentUserNavigationInfo.y * 100)

    return (pinTracked and mapIDMatch and xMatch and yMatch)
end

function MapPin.IsUserNavigationFlagged(flag)
    local currentUserNavigationInfo = MapPin.GetUserNavigation()
    if currentUserNavigationInfo and currentUserNavigationInfo.flags == flag then
        return true
    end
    return false
end

function MapPin.ToggleSuperTrackedPinDisplay(shown)
    for pin in WorldMapFrame:EnumeratePinsByTemplate("WaypointLocationPinTemplate") do
        pin:SetAlpha(shown and 1 or 0)
        pin:EnableMouse(shown)
    end
end

do --Automatically clear supertracking when the user waypoint is removed
    local f = CreateFrame("Frame")
    f:RegisterEvent("USER_WAYPOINT_UPDATED")
    f:SetScript("OnEvent", function(self, event, ...)
        if not C_Map.HasUserWaypoint() and C_SuperTrack.IsSuperTrackingMapPin() then
            C_SuperTrack.ClearAllSuperTracked()
        end
    end)
end

local function OnAddonLoad()
    MapPin.GetUserNavigation()
    CallbackRegistry.Trigger("MapPin.Ready")
end

CallbackRegistry.Add("Preload.AddonReady", OnAddonLoad)
