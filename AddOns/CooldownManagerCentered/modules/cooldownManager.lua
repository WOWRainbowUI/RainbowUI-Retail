local _, ns = ...

-- Initialize namespace and DB early
ns.db = ns.db or {}
ns.db.profile = ns.db.profile or {}
local CooldownManager = {}
ns.CooldownManager = CooldownManager

CMC_DEBUG = false
local PrintDebug = function(...)
    if CMC_DEBUG then
        print("[CMC]", ...)
    end
end

local floor = math.floor

-- Architecture:
-- LayoutEngine: pure layout computations (no frame access)
-- ViewerAdapters: WoW Frame interaction per viewer type

local LayoutEngine = {}
local ViewerAdapters = {}

local viewers = {
    BuffIconCooldownViewer = _G["BuffIconCooldownViewer"],
    BuffBarCooldownViewer = _G["BuffBarCooldownViewer"],
    EssentialCooldownViewer = _G["EssentialCooldownViewer"],
    UtilityCooldownViewer = _G["UtilityCooldownViewer"],
}

-- Defaults
local fontSizeDefault = {
    EssentialCooldownViewer = 14,
    UtilityCooldownViewer = 12,
    BuffIconCooldownViewer = 14,
}
local viewerSettingsMap = {
    ["EssentialCooldownViewer"] = {
        squareIconsEnabled = "cooldownManager_squareIcons_Essential",
        squareIconsBorder = "cooldownManager_squareIconsBorder_Essential",
        squareIconsBorderOverlap = "cooldownManager_squareIconsBorder_Essential_Overlap",
    },
    ["UtilityCooldownViewer"] = {
        squareIconsEnabled = "cooldownManager_squareIcons_Utility",
        squareIconsBorder = "cooldownManager_squareIconsBorder_Utility",
        squareIconsBorderOverlap = "cooldownManager_squareIconsBorder_Utility_Overlap",
    },
    ["BuffIconCooldownViewer"] = {
        squareIconsEnabled = "cooldownManager_squareIcons_BuffIcons",
        squareIconsBorder = "cooldownManager_squareIconsBorder_BuffIcons",
        squareIconsBorderOverlap = "cooldownManager_squareIconsBorder_BuffIcons_Overlap",
    },
}

-- Map viewer names to setting key names for StyledIcons functions
local viewerToSettingKey = {
    ["EssentialCooldownViewer"] = "Essential",
    ["UtilityCooldownViewer"] = "Utility",
    ["BuffIconCooldownViewer"] = "BuffIcons",
}

function LayoutEngine.CenteredRowXOffsets(count, itemWidth, padding, directionModifier, iconLimit, iconRef)
    if not count or count <= 0 then
        return {}
    end
    local dir = directionModifier or 1
    local iconsMissing = iconLimit - count
    local startX = ((itemWidth + padding) * iconsMissing / 2) * dir
    local offsets = {}
    for i = 1, count do
        offsets[i] = ns.Scaling:RoundToPixelSize(startX + (i - 1) * (itemWidth + padding) * dir, iconRef)
    end
    return offsets
end

function LayoutEngine.CenteredColYOffsets(count, itemHeight, padding, directionModifier, iconLimit, iconRef)
    if not count or count <= 0 then
        return {}
    end
    local dir = directionModifier or 1
    local iconsMissing = iconLimit - count
    local startY = -((itemHeight + padding) * iconsMissing / 2) * dir
    local offsets = {}
    for i = 1, count do
        offsets[i] = ns.Scaling:RoundToPixelSize(startY - (i - 1) * (itemHeight + padding) * dir, iconRef)
    end
    return offsets
end

function LayoutEngine.StartRowXOffsets(count, itemWidth, padding, directionModifier)
    -- Why: Produce X offsets starting from the left edge.
    -- When: Positioning icons aligned to start; supports reversed direction via modifier.
    if not count or count <= 0 then
        return {}
    end
    local dir = directionModifier or 1
    local offsets = {}
    for i = 1, count do
        offsets[i] = ((i - 1) * (itemWidth + padding) * dir)
    end
    return offsets
end

function LayoutEngine.EndRowXOffsets(count, itemWidth, padding, directionModifier)
    -- Why: Produce X offsets starting from the right edge.
    -- When: Positioning icons aligned to end; supports reversed direction via modifier.
    if not count or count <= 0 then
        return {}
    end
    local dir = directionModifier or 1
    local offsets = {}
    for i = 1, count do
        offsets[i] = (-((i - 1) * (itemWidth + padding)) * dir)
    end
    return offsets
end

function LayoutEngine.StartColYOffsets(count, itemHeight, padding, directionModifier)
    -- Why: Produce Y offsets starting from the top edge.
    -- When: Positioning icons aligned to start; supports reversed direction via modifier.
    if not count or count <= 0 then
        return {}
    end
    local dir = directionModifier or 1
    local offsets = {}
    for i = 1, count do
        offsets[i] = (-((i - 1) * (itemHeight + padding)) * dir)
    end
    return offsets
end

function LayoutEngine.EndColYOffsets(count, itemHeight, padding, directionModifier)
    -- Why: Produce Y offsets starting from the bottom edge.
    -- When: Positioning icons aligned to end; supports reversed direction via modifier.
    if not count or count <= 0 then
        return {}
    end
    local dir = directionModifier or 1
    local offsets = {}
    for i = 1, count do
        offsets[i] = ((i - 1) * (itemHeight + padding) * dir)
    end
    return offsets
end

function LayoutEngine.BuildRows(iconLimit, children)
    -- Why: Group a flat list of icons into rows limited by `iconLimit`.
    -- When: Before computing centered layout for Essential/Utility viewers.
    local rows = {}
    local limit = iconLimit or 0
    if limit <= 0 then
        return rows
    end
    for i = 1, #children do
        local rowIndex = floor((i - 1) / limit) + 1
        rows[rowIndex] = rows[rowIndex] or {}
        rows[rowIndex][#rows[rowIndex] + 1] = children[i]
    end
    return rows
end

-- ViewerAdapters: BuffIcon/BuffBar collection + hooks
function ViewerAdapters.GetBuffIconFrames()
    -- Why: Collect visible Buff Icon viewer children, hook change events, and apply stack visuals.
    -- When: Before positioning buff icons and whenever aura events trigger layout updates.
    if not BuffIconCooldownViewer then
        return {}
    end
    local visible = {}
    local children = { BuffIconCooldownViewer:GetChildren() }
    local total = 0
    for _, child in ipairs(children) do
        if child and (child.icon or child.Icon) and child.layoutIndex ~= nil then
            total = total + 1
            if child:IsShown() then
                visible[#visible + 1] = child
            end
            if not child._wt_isHooked then
                child._wt_isHooked = true
                hooksecurefunc(child, "OnActiveStateChanged", ViewerAdapters.UpdateBuffIcons)
                hooksecurefunc(child, "OnUnitAuraAddedEvent", ViewerAdapters.UpdateBuffIcons)
                hooksecurefunc(child, "OnUnitAuraRemovedEvent", ViewerAdapters.UpdateBuffIcons)
            end
        end
    end

    table.sort(visible, function(a, b)
        return (a.layoutIndex or 0) < (b.layoutIndex or 0)
    end)
    return visible, total
end

function ViewerAdapters.GetBuffBarFrames()
    -- Why: Collect active Buff Bar frames with resilience to API differences, and hook changes.
    -- When: Before aligning bars vertically and whenever aura events trigger layout updates.
    if not BuffBarCooldownViewer then
        return {}
    end
    local frames = {}
    if BuffBarCooldownViewer.GetItemFrames then
        local ok, items = pcall(BuffBarCooldownViewer.GetItemFrames, BuffBarCooldownViewer)
        if ok and items then
            frames = items
        end
    end
    if #frames == 0 then
        local okc, children = pcall(BuffBarCooldownViewer.GetChildren, BuffBarCooldownViewer)
        if okc and children then
            for _, child in ipairs({ children }) do
                if child and child:IsObjectType("Frame") then
                    frames[#frames + 1] = child
                end
            end
        end
    end
    local active = {}
    for _, frame in ipairs(frames) do
        if frame:IsShown() and frame:IsVisible() then
            active[#active + 1] = frame
        end
        if not frame._wt_isHooked and (frame.icon or frame.Icon or frame.bar or frame.Bar) then
            frame._wt_isHooked = true
            hooksecurefunc(frame, "OnActiveStateChanged", ViewerAdapters.UpdateBuffBars)
            hooksecurefunc(frame, "OnUnitAuraAddedEvent", ViewerAdapters.UpdateBuffBars)
            hooksecurefunc(frame, "OnUnitAuraRemovedEvent", ViewerAdapters.UpdateBuffBars)
        end
    end
    table.sort(active, function(a, b)
        return (a.layoutIndex or 0) < (b.layoutIndex or 0)
    end)
    return active
end

function ViewerAdapters.UpdateBuffIcons()
    -- Why: Position Buff Icon viewer children based on isHorizontal, iconDirection, and alignment.
    -- When: On aura events, settings changes, or explicit refresh calls when the feature is enabled.

    if
        not ns.Runtime:IsReady(BuffIconCooldownViewer)
        or ns.db.profile.cooldownManager_alignBuffIcons_growFromDirection == "Disable"
    then
        return
    end

    local icons, total = ViewerAdapters.GetBuffIconFrames()
    local count = #icons
    if count == 0 then
        return
    end

    local refIcon = icons[1]
    local iconWidth = refIcon:GetWidth()
    local iconHeight = refIcon:GetHeight()
    if not iconWidth or iconWidth == 0 or not iconHeight or iconHeight == 0 then
        return
    end

    local isHorizontal = BuffIconCooldownViewer.isHorizontal ~= false
    local iconDirection = BuffIconCooldownViewer.iconDirection == 1 and "NORMAL" or "REVERSED"

    local alignment = ns.db.profile.cooldownManager_alignBuffIcons_growFromDirection or "CENTER"
    local padding = isHorizontal and BuffIconCooldownViewer.childXPadding or BuffIconCooldownViewer.childYPadding

    if isHorizontal then
        local offsets
        local anchor, relativePoint
        local iconDirectionModifier = iconDirection == "NORMAL" and 1 or -1
        if alignment == "START" then
            offsets = LayoutEngine.StartRowXOffsets(count, iconWidth, padding, iconDirectionModifier)
            anchor = iconDirection == "NORMAL" and "TOPLEFT" or "TOPRIGHT"
            relativePoint = iconDirection == "NORMAL" and "TOPLEFT" or "TOPRIGHT"
        elseif alignment == "END" then
            offsets = LayoutEngine.EndRowXOffsets(count, iconWidth, padding, iconDirectionModifier)
            anchor = iconDirection == "NORMAL" and "TOPRIGHT" or "TOPLEFT"
            relativePoint = iconDirection == "NORMAL" and "TOPRIGHT" or "TOPLEFT"
        else -- CENTER
            offsets = LayoutEngine.CenteredRowXOffsets(count, iconWidth, padding, iconDirectionModifier, total, refIcon)
            anchor = iconDirection == "NORMAL" and "TOPLEFT" or "TOPRIGHT"
            relativePoint = iconDirection == "NORMAL" and "TOPLEFT" or "TOPRIGHT"
        end

        for i, icon in ipairs(icons) do
            local x = offsets[i] or 0
            icon:ClearAllPoints()
            icon:SetPoint(anchor, BuffIconCooldownViewer, relativePoint, x, 0)
        end
    else
        -- Vertical layout
        local offsets
        local anchor, relativePoint
        local iconDirectionModifier = iconDirection == "NORMAL" and -1 or 1
        if alignment == "START" then
            offsets = LayoutEngine.StartColYOffsets(count, iconHeight, padding, iconDirectionModifier)
            anchor = iconDirection == "NORMAL" and "BOTTOMLEFT" or "TOPLEFT"
            relativePoint = iconDirection == "NORMAL" and "BOTTOMLEFT" or "TOPLEFT"
        elseif alignment == "END" then
            offsets = LayoutEngine.EndColYOffsets(count, iconHeight, padding, iconDirectionModifier)
            anchor = iconDirection == "NORMAL" and "TOPLEFT" or "BOTTOMLEFT"
            relativePoint = iconDirection == "NORMAL" and "TOPLEFT" or "BOTTOMLEFT"
        else -- CENTER
            offsets = LayoutEngine.CenteredColYOffsets(count, iconHeight, padding, iconDirectionModifier, total)
            anchor = iconDirection == "NORMAL" and "BOTTOMLEFT" or "TOPLEFT"
            relativePoint = iconDirection == "NORMAL" and "BOTTOMLEFT" or "TOPLEFT"
        end

        for i, icon in ipairs(icons) do
            local y = offsets[i] or 0
            icon:ClearAllPoints()
            icon:SetPoint(anchor, BuffIconCooldownViewer, relativePoint, 0, y)
        end
    end
end

function ViewerAdapters.UpdateBuffBars()
    -- Why: Align Buff Bar frames from chosen growth direction when enabled and changes detected.
    -- When: On aura events, settings changes, or explicit refresh calls when the feature is enabled.
    if
        not ns.Runtime:IsReady(BuffBarCooldownViewer)
        or ns.db.profile.cooldownManager_alignBuffBars_growFromDirection == "Disable"
    then
        return
    end

    local bars = ViewerAdapters.GetBuffBarFrames()
    local count = #bars
    if count == 0 then
        return
    end

    local refBar = bars[1]
    local barHeight = refBar and refBar:GetHeight()
    local spacing = BuffBarCooldownViewer.childYPadding or 0
    if not barHeight or barHeight == 0 then
        return
    end

    local growFromBottom = ns.db.profile.cooldownManager_alignBuffBars_growFromDirection == "BOTTOM"

    for index, bar in ipairs(bars) do
        local offsetIndex = index - 1
        local y = growFromBottom and offsetIndex * (barHeight + spacing) or -offsetIndex * (barHeight + spacing)

        bar:ClearAllPoints()
        if growFromBottom then
            bar:SetPoint("BOTTOM", BuffBarCooldownViewer, "BOTTOM", 0, y)
        else
            bar:SetPoint("TOP", BuffBarCooldownViewer, "TOP", 0, y)
        end
    end
end

function ViewerAdapters.CollectViewerChildren(viewer)
    -- Why: Standardized filtered list of visible icon-like children sorted by layoutIndex.
    -- When: Building rows/columns for Essential/Utility centered layouts.
    local all = {}
    local viewerName = viewer:GetName()
    local toDim = viewerName == "UtilityCooldownViewer" and ns.db.profile.cooldownManager_utility_dimWhenNotOnCD
    local toDimOpacity = ns.db.profile.cooldownManager_utility_dimOpacity or 0.3

    local children = { viewer:GetChildren() }
    for _, child in ipairs(children) do
        if child and child:IsShown() and child.Icon then
            all[#all + 1] = child

            -- TODO move from cooldown manager.lua
            if child.cooldownID and toDim then
                local info = C_CooldownViewer.GetCooldownViewerCooldownInfo(child.cooldownID)
                local spellID = info.overrideSpellID or info.spellID
                if not C_Spell.GetSpellCooldown(spellID).isOnGCD then
                    local cd = nil
                    if not issecretvalue(child.cooldownChargesShown) and child.cooldownChargesShown then
                        cd = ns.CooldownTracker:getChargeCD(spellID)
                    else
                        cd = ns.CooldownTracker:getSpellCD(spellID)
                    end

                    local curve = C_CurveUtil.CreateCurve()
                    curve:AddPoint(0.0, toDimOpacity)
                    curve:AddPoint(0.1, 1)
                    local EvaluateDuration = cd.EvaluateRemainingDuration and cd:EvaluateRemainingDuration(curve)

                    child:SetAlpha(EvaluateDuration)
                end
            else
                child:SetAlpha(1)
            end
        end
    end
    table.sort(all, function(a, b)
        return (a.layoutIndex or 0) < (b.layoutIndex or 0)
    end)
    return all
end

local function PositionRowHorizontal(
    viewer,
    row,
    yOffset,
    w,
    padding,
    iconDirectionModifier,
    rowAnchor,
    iconLimit,
    iconRef
)
    local count = #row
    local xOffsets = LayoutEngine.CenteredRowXOffsets(count, w, padding, iconDirectionModifier, iconLimit, iconRef)

    for i, icon in ipairs(row) do
        local x = xOffsets[i] or 0
        local stillNeedToSet = true

        if icon.GetPoint then
            local point, relativeTo, relativePoint, offsetX, offsetY = icon:GetPoint()
            if offsetX ~= nil and offsetY ~= nil then
                local xDiff = math.abs(x - offsetX)
                local yDiff = math.abs(yOffset - offsetY)
                if point == rowAnchor and relativePoint == rowAnchor and xDiff < 1 and yDiff < 1 then
                    stillNeedToSet = false
                    -- No need to reposition
                else
                    if xDiff <= 1 then
                        x = offsetX
                    end
                end
            end
        end
        if stillNeedToSet then
            icon:ClearAllPoints()
            icon:SetPoint(rowAnchor, viewer, rowAnchor, x, yOffset)
        end
    end
end

local function PositionRowVertical(
    viewer,
    row,
    xOffset,
    h,
    padding,
    iconDirectionModifier,
    colAnchor,
    iconLimit,
    iconRef
)
    local count = #row
    local yOffsets = LayoutEngine.CenteredColYOffsets(count, h, padding, iconDirectionModifier, iconLimit)

    for i, icon in ipairs(row) do
        local y = yOffsets[i] or 0
        local stillNeedToSet = true

        if icon.GetPoint then
            local point, relativeTo, relativePoint, offsetX, offsetY = icon:GetPoint()
            if offsetX ~= nil and offsetY ~= nil then
                local xDiff = math.abs(xOffset - offsetX)
                local yDiff = math.abs(y - offsetY)
                if point == colAnchor and relativePoint == colAnchor and xDiff <= 1 and yDiff <= 1 then
                    stillNeedToSet = false
                -- No need to reposition
                else
                    if yDiff <= 1 then
                        y = offsetY
                    end
                end
            end
        end
        if stillNeedToSet then
            icon:ClearAllPoints()
            icon:SetPoint(colAnchor, viewer, colAnchor, xOffset, y)
        end
    end
end

function ViewerAdapters.UpdateViewerSizeIfChanged(viewer)
    local viewerName = viewer:GetName()
    local currentWidth = viewer:GetWidth()
    local currentHeight = viewer:GetHeight()

    local children = ViewerAdapters.CollectViewerChildren(viewer)
    local top, right, bottom, left = 0, 0, 999999, 999999
    for _, child in ipairs(children) do
        local scale = child:GetEffectiveScale() / viewer:GetEffectiveScale()
        local cTop = child:GetTop() or 0
        local cRight = child:GetRight() or 0
        local cBottom = child:GetBottom() or 0
        local cLeft = child:GetLeft() or 0
        cTop = cTop * scale
        cRight = cRight * scale
        cBottom = cBottom * scale
        cLeft = cLeft * scale
        if cTop > top then
            top = cTop
        end
        if cRight > right then
            right = cRight
        end
        if cBottom < bottom then
            bottom = cBottom
        end
        if cLeft < left then
            left = cLeft
        end
    end

    local targetWidth = (right - left)
    local targetHeight = (top - bottom)

    if abs(currentWidth - targetWidth) >= 1 or abs(currentHeight - targetHeight) >= 1 then
        viewer:SetWidth(targetWidth)
        viewer:SetHeight(targetHeight)
        viewer:SetSize(targetWidth, targetHeight)
    end
end

function ViewerAdapters.UpdateEssential()
    ViewerAdapters.UpdateCDViewer(
        EssentialCooldownViewer,
        ns.db.profile.cooldownManager_centerEssential_growFromDirection
    )
end

function ViewerAdapters.UpdateUtility()
    ViewerAdapters.UpdateCDViewer(UtilityCooldownViewer, ns.db.profile.cooldownManager_centerUtility_growFromDirection)
end

function ViewerAdapters.UpdateCDViewer(viewer, fromDirection)
    if not ns.Runtime:IsReady(viewer) then
        return
    end

    local viewerName = viewer:GetName()

    local isHorizontal = viewer.isHorizontal ~= false
    local iconDirection = viewer.iconDirection == 1 and "NORMAL" or "REVERSED"
    local iconLimit = viewer.iconLimit or 0
    if iconLimit <= 0 then
        return
    end

    local children = ViewerAdapters.CollectViewerChildren(viewer)
    -- todo refactor DIMing as now we have to "early" return after collecting children, to leave dimming working
    if fromDirection == "Disable" or #children == 0 then
        return
    end

    local first = children[1]
    if not first then
        return
    end
    local w, h = first:GetWidth(), first:GetHeight()
    if not w or w == 0 or not h or h == 0 then
        return
    end

    local padding = isHorizontal and viewer.childXPadding or viewer.childYPadding
    if
        viewerName == "UtilityCooldownViewer"
        and ns.db.profile.cooldownManager_limitUtilitySizeToEssential
        and isHorizontal
    then
        local essentialViewer = viewers["EssentialCooldownViewer"]
        if essentialViewer then
            local eWidth = essentialViewer:GetWidth()
            if eWidth and eWidth > 0 then
                local iconActualWidth = (w + padding) * viewer.iconScale
                local maxIcons = floor((eWidth + (padding * viewer.iconScale)) / iconActualWidth)
                if maxIcons > 0 then
                    iconLimit = math.max(math.min(iconLimit, maxIcons), math.min(iconLimit, 6))
                end
            end
        end
    end

    local rows = LayoutEngine.BuildRows(iconLimit, children)
    if #rows == 0 then
        return
    end
    local maxIcons = math.min(iconLimit, #children)

    -- Get subsequent row scaling factor for this viewer (only Essential and Utility support it)
    local settingKey = viewerToSettingKey[viewerName]

    if isHorizontal then
        local rowOffsetModifier = fromDirection == "BOTTOM" and 1 or -1
        local iconDirectionModifier = iconDirection == "NORMAL" and 1 or -1
        local fromAnchor1 = fromDirection == "BOTTOM" and "BOTTOM" or "TOP"
        local fromAnchor2 = iconDirection == "NORMAL" and "LEFT" or "RIGHT"
        local rowAnchor = fromAnchor1 .. fromAnchor2

        -- if viewer == EssentialCooldownViewer then
        --     print(ns.Scaling:GetPixelSize(viewer), ns.Scaling:GetPixelSize(first))
        -- end
        local cumulativeOffset = 0
        for iRow, row in ipairs(rows) do
            local currentRowHeight = h

            local yOffset = cumulativeOffset * rowOffsetModifier
            PositionRowHorizontal(viewer, row, yOffset, w, padding, iconDirectionModifier, rowAnchor, maxIcons, first)

            cumulativeOffset = cumulativeOffset + ns.Scaling:RoundToPixelSize(currentRowHeight + padding)
        end
    else
        local rowOffsetModifier = fromDirection == "BOTTOM" and -1 or 1
        local iconDirectionModifier = iconDirection == "NORMAL" and -1 or 1
        local fromAnchor1 = fromDirection == "BOTTOM" and "RIGHT" or "LEFT"
        local fromAnchor2 = iconDirection == "NORMAL" and "BOTTOM" or "TOP"
        local colAnchor = fromAnchor2 .. fromAnchor1
        local cumulativeOffset = 0
        for iRow, row in ipairs(rows) do
            local currentColWidth = w

            local xOffset = cumulativeOffset * rowOffsetModifier
            PositionRowVertical(viewer, row, xOffset, h, padding, iconDirectionModifier, colAnchor, maxIcons, first)

            cumulativeOffset = cumulativeOffset + ns.Scaling:RoundToPixelSize(currentColWidth + padding)
        end
    end
    ViewerAdapters.UpdateViewerSizeIfChanged(viewer)
end

local function ShouldDebugRefreshLog()
    if ns.db.profile.cooldownManager_debugRefreshLogs ~= nil then
        return ns.db.profile.cooldownManager_debugRefreshLogs
    end
    return false
end

function CooldownManager.ForceRefresh(parts)
    parts = parts or { icons = true, bars = true, essential = true, utility = true }
    if parts.icons then
        ViewerAdapters.UpdateBuffIcons()
    end
    if parts.bars then
        ViewerAdapters.UpdateBuffBars()
    end
    if parts.essential then
        ViewerAdapters.UpdateEssential()
    end
    if parts.utility then
        ViewerAdapters.UpdateUtility()
    end
end

function CooldownManager.ForceRefreshAll()
    CooldownManager.ForceRefresh({ icons = true, bars = true, essential = true, utility = true })
end

local viewerReasonPartsMap = {
    EssentialCooldownViewer = { essential = true },
    UtilityCooldownViewer = { utility = true },
    BuffIconCooldownViewer = { icons = true },
    BuffBarCooldownViewer = { bars = true },
}

function CooldownManager.Initialize()
    CooldownManager.ForceRefreshAll()
end
