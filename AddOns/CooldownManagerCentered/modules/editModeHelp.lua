local _, ns = ...

local EditModeHelp = {}
ns.EditModeHelp = EditModeHelp

local pointMap = {
    ["TOPLEFT"] = "TOP",
    ["TOP"] = "TOP",
    ["TOPRIGHT"] = "TOP",
    ["LEFT"] = "CENTER",
    ["CENTER"] = "CENTER",
    ["RIGHT"] = "CENTER",
    ["BOTTOMLEFT"] = "BOTTOM",
    ["BOTTOM"] = "BOTTOM",
    ["BOTTOMRIGHT"] = "BOTTOM",
}
local viewers = {
    {
        frame = BuffIconCooldownViewer,
        viewerName = "BuffIconCooldownViewer",
        growthFrom = "cooldownManager_alignBuffIcons_growFromDirection",
    },
    {
        frame = EssentialCooldownViewer,
        viewerName = "EssentialCooldownViewer",
        growthFrom = "cooldownManager_centerEssential_growFromDirection",
    },
    {
        frame = UtilityCooldownViewer,
        viewerName = "UtilityCooldownViewer",
        growthFrom = "cooldownManager_centerUtility_growFromDirection",
    },
    {
        frame = BuffBarCooldownViewer,
        viewerName = "BuffBarCooldownViewer",
        growthFrom = "cooldownManager_alignBuffBars_growFromDirection",
    },
}

local function GetPointAndOffset(frame, growFromDirection)
    if not frame.isHorizontal and frame ~= BuffBarCooldownViewer then
        return nil
    end
    local point, relativeTo = frame:GetPoint(1)

    if relativeTo ~= UIParent then
        return nil
    end

    local y = nil
    point = nil

    if growFromDirection == "BOTTOM" then
        point = "BOTTOM"
    else
        point = "TOP"
    end
    if point == "BOTTOM" then
        y = frame:GetBottom()
    else
        y = frame:GetTop()
    end

    local x = frame:GetCenter()
    local pX = UIParent:GetCenter()
    return { point = point, x = x - pX, y = y }
end
local helpText = nil
local function GetHelpText()
    local text = "To edit |cff008945Cool|r|cff1e9a4e|r|cff3faa4fdown Ma|r|cff5fb64anag|r|cff7ac243er|r"
    if not EditModeManagerFrame:GetAccountSettingValueBool(Enum.EditModeAccountSetting.SettingsExpanded) then
        text = text .. '\nclick "Expand options", and'
    end
    text = text .. '\nenable "Cooldown Manager" above'
    return text
end
local function CreateHelpText()
    if not EditModeManagerFrame then
        return
    end
    if helpText then
        if not EditModeManagerFrame:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowCooldownViewer) then
            helpText.text:SetText(GetHelpText())
        else
            helpText.text:SetText("")
        end
        return
    end
    helpText = CreateFrame("Frame", nil, EditModeManagerFrame)
    helpText:SetSize(400, 50)
    helpText:SetPoint("TOP", EditModeManagerFrame, "BOTTOM", 0, 20)
    helpText.text = helpText:CreateFontString(nil, "OVERLAY", "GameFontNormalLargeOutline")
    helpText.text:ClearAllPoints()
    helpText.text:SetAllPoints()
    helpText.text:SetText("")
    if not EditModeManagerFrame:GetAccountSettingValueBool(Enum.EditModeAccountSetting.ShowCooldownViewer) then
        helpText.text:SetText(GetHelpText())
    end
end
local arrowsForViewers = {}

for _, viewerInfo in ipairs(viewers) do
    local viewerName = viewerInfo.viewerName
    local newArrows = {
        top = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "BOTTOM",
        },
        left = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "RIGHT",
        },
        right = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "LEFT",
        },
        bottom = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "TOP",
        },
    }
    arrowsForViewers[viewerName] = newArrows
    for name, info in pairs(newArrows) do
        local frame = info.frame
        frame:SetParent(viewerInfo.frame)
    end
end
for _, viewerInfo in ipairs(viewers) do
    local viewerName = viewerInfo.viewerName
    local arrowFrames = arrowsForViewers[viewerName]
    for name, info in pairs(arrowFrames) do
        local frame = info.frame
        frame:SetSize(10, 14)
        frame:SetScale(1)
        frame.background = frame:CreateTexture(nil, "BACKGROUND")
        frame.background:ClearAllPoints()
        frame.background:SetAllPoints()
        frame.background:SetAtlas("bags-greenarrow", false)
        frame.background:SetRotation(
            name == "left" and math.pi / 2 or (name == "right" and -math.pi / 2 or (name == "bottom" and math.pi or 0))
        )
        frame:SetFrameStrata("HIGH")
        frame:Hide()
    end
end

local function UpdateFrameArrowsAnchors(forceHide)
    for i, viewerInfo in ipairs(viewers) do
        local frame = viewerInfo.frame
        local point, relativeTo, relativePoint, offsetX, offsetY = select(1, viewerInfo.frame:GetPoint(1))

        local viewerName = viewerInfo.viewerName
        local arrowFrames = arrowsForViewers[viewerName]
        for name, info in pairs(arrowFrames) do
            info.frame:SetPoint(info.anchor, viewerInfo.frame, point, 0, 0)
            info.frame:SetScale(1)

            info.frame:SetSize(10, 14)
            info.frame.background:SetScale(1)
            if info.frame.BCDMBorders then
                local regions = { info.frame:GetRegions() }
                for _, region in ipairs(regions) do
                    if region ~= info.frame.background then
                        region:Hide()
                    else
                        region:SetScale(1)
                        region:SetSize(10, 14)
                    end
                end
            end
            local pointLower = string.lower(point)
            if forceHide or not ns.Runtime.isInEditMode or pointLower:find(name) or viewerInfo.frame.isDragging then
                info.frame:Hide()
            else
                info.frame:Show()
                info.frame:SetFrameStrata("HIGH")
            end
        end
    end
end

local function UpdateViewerAnchor(frame, viewerInfo)
    if
        not frame.IsInitialized
        or not frame:IsInitialized()
        or frame.layoutApplyInProgress
        or not frame:CanBeMoved()
    then
        return
    end
    local growthFrom = ns.db.profile[viewerInfo.growthFrom]
    if not viewerInfo.growthFrom or not growthFrom or growthFrom == "Disable" then
        return
    end
    if viewerInfo.viewerName == "BuffIconCooldownViewer" and growthFrom ~= "CENTER" then
        return
    end
    if ns.Runtime.isInEditMode and EditModeManagerFrame:IsShown() then
        local data = GetPointAndOffset(frame, growthFrom)
        if not data then
            return
        end
        local currentPoint, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()
        if currentPoint ~= data.point or math.floor(data.x - offsetX) > 0 or math.floor(data.y - offsetY) > 0 then
            frame:ClearAllPoints()
            frame:SetPoint(data.point, UIParent, "BOTTOM", data.x, data.y)
            EditModeManagerFrame:OnSystemPositionChange(frame)
        end

        UpdateFrameArrowsAnchors()
    end
end

for _, viewerInfo in ipairs(viewers) do
    local frame = viewerInfo.frame
    hooksecurefunc(frame, "SetPoint", function()
        if
            not frame.IsInitialized
            or not frame:IsInitialized()
            or frame.layoutApplyInProgress
            or not frame:CanBeMoved()
        then
            return
        end
        C_Timer.After(0, function()
            UpdateViewerAnchor(frame, viewerInfo)
        end)
    end)
end

local function AddArrowsToTrinketRacialTracker()
    local viewerName = "CMCTrinketRacialTracker"
    if arrowsForViewers[viewerName] or not _G[viewerName] then
        return
    end
    local arrowFrames = {
        top = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "BOTTOM",
        },
        left = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "RIGHT",
        },
        right = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "LEFT",
        },
        bottom = {
            frame = CreateFrame("Frame", nil, UIParent),
            anchor = "TOP",
        },
    }
    for name, info in pairs(arrowFrames) do
        local frame = info.frame
        frame:SetSize(10, 14)
        frame:SetScale(1)
        frame.background = frame:CreateTexture(nil, "BACKGROUND")
        frame.background:ClearAllPoints()
        frame.background:SetAllPoints()
        frame.background:SetAtlas("bags-greenarrow", false)
        frame.background:SetRotation(
            name == "left" and math.pi / 2 or (name == "right" and -math.pi / 2 or (name == "bottom" and math.pi or 0))
        )
        frame:SetFrameStrata("HIGH")
        frame:Hide()
    end
    arrowsForViewers[viewerName] = arrowFrames
    table.insert(viewers, {
        frame = _G[viewerName],
        viewerName = viewerName,
    })
end

local ticker = nil
EventRegistry:RegisterCallback("EditMode.Enter", function()
    CreateHelpText()
    AddArrowsToTrinketRacialTracker()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
    C_Timer.After(0, function()
        UpdateFrameArrowsAnchors()
    end)
    ticker = C_Timer.NewTicker(0.5, function()
        CreateHelpText()
        UpdateFrameArrowsAnchors()
    end)
end)

EventRegistry:RegisterCallback("EditMode.Exit", function()
    C_Timer.After(0, function()
        UpdateFrameArrowsAnchors()
        if ticker then
            ticker:Cancel()
            ticker = nil
        end
    end)
end)
