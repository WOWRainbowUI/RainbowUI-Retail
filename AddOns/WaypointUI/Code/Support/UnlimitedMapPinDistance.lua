local env = select(2, ...)
local Support = env.WPM:Import("@\\Support")
local Support_UnlimitedMapPinDistance = env.WPM:New("@\\Support\\UnlimitedMapPinDistance")

local function OnAddonLoad()
    if not SuperTrackedFrame.Time then return end
    SuperTrackedFrame.Time:SetParent(nil)
    SuperTrackedFrame.Time:ClearAllPoints()
end

Support.Add("UnlimitedMapPinDistance", OnAddonLoad)
