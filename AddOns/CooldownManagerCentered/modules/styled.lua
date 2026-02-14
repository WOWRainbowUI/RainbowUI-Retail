local _, ns = ...

local StyledIcons = {}
ns.StyledIcons = StyledIcons

local isModuleStyledEnabled = false
local areHooksInitialized = false

local BASE_SQUARE_MASK = "Interface\\AddOns\\CooldownManagerCentered\\Media\\Art\\Square"

local viewersSettingKey = {
    EssentialCooldownViewer = "Essential",
    UtilityCooldownViewer = "Utility",
    BuffIconCooldownViewer = "BuffIcons",
}

local normalizedSizeConfig = {
    Utility = { width = 50, height = 50 },
}

local originalSizesConfig = {
    Essential = { width = 50, height = 50 },
    Utility = { width = 30, height = 30 },
    BuffIcons = { width = 40, height = 40 },
}

local function IsNormalizedSizeEnabled()
    return ns.db.profile.cooldownManager_normalizeUtilitySize or false
end

local function IsAnyStyledFeatureEnabled()
    if not ns.db or not ns.db.profile then
        return false
    end
    for _, viewerSettingName in pairs(viewersSettingKey) do
        local squareKey = "cooldownManager_squareIcons_" .. viewerSettingName
        if ns.db.profile[squareKey] then
            return true
        end
    end
    if ns.db.profile.cooldownManager_normalizeUtilitySize then
        return true
    end

    return false
end
function StyledIcons:IsAnyStyledFeatureEnabled()
    return IsAnyStyledFeatureEnabled()
end
local function GetViewerIconSize(viewerSettingName)
    local data = originalSizesConfig[viewerSettingName]
    local isNormalizedUtility = viewerSettingName == "Utility" and ns.db.profile.cooldownManager_normalizeUtilitySize
    if isNormalizedUtility then
        data = normalizedSizeConfig[viewerSettingName]
    end

    if ns.db.profile.cooldownManager_experimental_enableRectangularIcons then
        if viewerSettingName == "Essential" or isNormalizedUtility then
            return 50, 40
        elseif viewerSettingName == "Utility" then
            return 30, 24
        elseif viewerSettingName == "BuffIcons" then
            return 40, 32
        end
    end
    return data.width, data.height
end

local function ApplySquareStyle(button, viewerSettingName, iconScale)
    local width, height = GetViewerIconSize(viewerSettingName)

    local borderKey = "cooldownManager_squareIconsBorder_" .. viewerSettingName
    local borderThickness = ns.db.profile[borderKey]
    if borderThickness > 0 then
        borderThickness = ns.Scaling:RoundToPixelSize(borderThickness, button)
    end

    button:SetSize(width, height)

    local widthToHeightRatio = width / height
    if button.Icon then
        button.Icon:ClearAllPoints()
        button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

        -- Calculate zoom-based texture coordinates
        local zoom = 0
        if ns.db and ns.db.profile then
            local zoomKey = "cooldownManager_squareIconsZoom_" .. viewerSettingName
            zoom = ns.db.profile[zoomKey] or 0
        end
        local crop = zoom * 0.5
        if button.Icon.SetTexCoord then
            button.Icon:SetTexCoord(crop, 1 - crop, crop * widthToHeightRatio, 1 - crop * widthToHeightRatio)
        end
    end
    for i = 1, select("#", button:GetChildren()) do
        local texture = select(i, button:GetChildren())
        if texture and texture.SetSwipeTexture then
            texture:SetSwipeTexture(BASE_SQUARE_MASK)
            texture:ClearAllPoints()
            texture:SetPoint("TOPLEFT", button, "TOPLEFT", borderThickness, -borderThickness)
            texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -borderThickness, borderThickness)
        end
    end
    for _, region in next, { button:GetRegions() } do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()
            local atlas = region:GetAtlas()

            if (issecretvalue and not issecretvalue(texture) or not issecretvalue) and texture == 6707800 then
                region:SetTexture(BASE_SQUARE_MASK)
                region.__wt_set6707800 = true
            elseif atlas == "UI-HUD-CoolDownManager-IconOverlay" then
                region:SetAlpha(0) -- 6704514
            end
        end
    end
    -- There should be one region left that isn't mapped

    -- Create/update inset black border (overlays icon edges)
    if not button.cmcBorder then
        button.cmcBorder = CreateFrame("Frame", nil, button, "BackdropTemplate")
        button.cmcBorder:SetFrameLevel(button:GetFrameLevel() + 1)
    end
    button.cmcBorder:ClearAllPoints()
    button.cmcBorder:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button.cmcBorder:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    if borderThickness <= 0 then
        button.cmcBorder:Hide()
        button._cmcSquareStyled = true
        return
    end
    button.cmcBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = borderThickness,
    })
    button.cmcBorder:SetBackdropBorderColor(0, 0, 0, 1)
    button.cmcBorder:Show()

    button._cmcSquareStyled = true
end

local function RestoreOriginalStyle(button, viewerSettingName)
    local width, height = GetViewerIconSize(viewerSettingName)
    button:SetSize(width, height)

    if button.Icon then
        button.Icon:ClearAllPoints()
        button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0)

        button.Icon:SetSize(width, height)
    end

    if not button._cmcSquareStyled then
        return
    end

    for i = 1, select("#", button:GetChildren()) do
        local child = select(i, button:GetChildren())
        if child and child.SetSwipeTexture then
            child:SetSwipeTexture(6707800)
            child:ClearAllPoints()
            child:SetPoint("CENTER", button, "CENTER", 0, 0)
            child:SetSize(width, height)
            break
        end
    end

    for _, region in next, { button:GetRegions() } do
        if region:IsObjectType("Texture") then
            local texture = region:GetTexture()
            local atlas = region:GetAtlas()

            if region.__wt_set6707800 then
                region:SetTexture(6707800)
            elseif atlas == "UI-HUD-CoolDownManager-IconOverlay" then
                region:SetAlpha(1) -- 6704514
            end
        end
    end

    if button.cmcBorder then
        button.cmcBorder:Hide()
    end

    button._cmcSquareStyled = false
end
local function ApplyNormalizedSizeToButton(button, viewerSettingName)
    local width, height = GetViewerIconSize(viewerSettingName)
    button:SetSize(width, height)

    for i = 1, select("#", button:GetRegions()) do
        local texture = select(i, button:GetRegions())
        if texture.GetAtlas and texture:GetAtlas() == "UI-HUD-CoolDownManager-IconOverlay" then
            texture:ClearAllPoints()
            texture:SetPoint("CENTER", button, "CENTER", 0, 0)
            texture:SetSize(width * 1.36, height * 1.36)
        end
    end

    if button.Icon then
        button.Icon:ClearAllPoints()
        button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0)
        local settingName = viewersSettingKey[viewerSettingName]

        local padding = button._cmcSquareStyled and 4 or 0
        button.Icon:SetSize(width - padding, height - padding)
    end
end

-- Process all children of a viewer
local function ProcessViewer(viewer, viewerSettingName, applySquareStyle)
    if not viewer or not IsAnyStyledFeatureEnabled() then
        return
    end
    local normalize = (viewerSettingName == "Utility") and IsNormalizedSizeEnabled()

    local children = { viewer:GetChildren() }
    for _, child in ipairs(children) do
        if child.Icon then -- Only process icon-like children
            if normalize then
                ApplyNormalizedSizeToButton(child, viewerSettingName)
            end
            if applySquareStyle then
                ApplySquareStyle(child, viewerSettingName, viewer.iconScale)
            end
            if child.TriggerPandemicAlert and not child._wt_isStyleHooked then
                child._wt_isStyleHooked = true
                hooksecurefunc(child, "TriggerPandemicAlert", function()
                    if child.PandemicIcon then
                        if applySquareStyle then
                            child.PandemicIcon:SetScale(1.38) -- magic numbers - TODO fix someday (DebuffBorder/2 +X) where X =0.03
                        else
                            child.PandemicIcon:SetScale(1.0)
                        end
                    end
                    C_Timer.After(0, function()
                        if child.PandemicIcon then
                            if applySquareStyle then
                                child.PandemicIcon:SetScale(1.38) -- magic numbers - TODO fix someday (DebuffBorder/2 +X) where X =0.03
                            else
                                child.PandemicIcon:SetScale(1.0)
                            end
                        end
                    end)
                end)
            end
            if child.DebuffBorder then
                -- DevTools_Dump(child.DebuffBorder.Texture:GetAtlas()) -- secret and only set AFTER show event
                if applySquareStyle then
                    child.DebuffBorder:SetScale(1.7) -- magic numbers - TODO fix someday
                else
                    child.DebuffBorder:SetScale(1.0)
                end
            end
        end
    end
end

local function GetSettingKey(viewerSettingName)
    return "cooldownManager_squareIcons_" .. viewerSettingName
end

local function IsSquareIconsEnabled(viewerSettingName)
    if not ns.db or not ns.db.profile then
        return false
    end
    return ns.db.profile[GetSettingKey(viewerSettingName)] or false
end

function StyledIcons:RefreshViewer(viewerName)
    local viewerFrame = _G[viewerName]
    if not viewerFrame then
        return
    end

    local settingName = viewersSettingKey[viewerName]
    if not settingName then
        return
    end

    local enabled = IsSquareIconsEnabled(settingName)
    ProcessViewer(viewerFrame, settingName, enabled)
end

function StyledIcons:RefreshAll()
    for viewerName, settingName in pairs(viewersSettingKey) do
        local viewerFrame = _G[viewerName]
        if viewerFrame then
            local enabled = IsSquareIconsEnabled(settingName)
            ProcessViewer(viewerFrame, settingName, enabled)
        end
    end
end

function StyledIcons:Enable()
    if isModuleStyledEnabled then
        return
    end

    isModuleStyledEnabled = true

    self:RefreshAll()
end

function StyledIcons:Initialize()
    if not IsAnyStyledFeatureEnabled() then
        return
    end

    self:Enable()
end

function StyledIcons:OnSettingChanged()
    local shouldBeEnabled = IsAnyStyledFeatureEnabled()

    if shouldBeEnabled and not isModuleStyledEnabled then
        self:Enable()
    elseif not shouldBeEnabled and isModuleStyledEnabled then
        ns.API:ShowReloadUIConfirmation()
    elseif isModuleStyledEnabled then
        self:RefreshAll()
    end

    if ns.CooldownManager then
        ns.CooldownManager.ForceRefreshAll()
    end
end
