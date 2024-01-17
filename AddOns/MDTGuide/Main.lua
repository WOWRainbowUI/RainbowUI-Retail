---@type string
local Name = ...
---@class Addon
local Addon = select(2, ...)

MDTG = Addon
MDTGuideDB = {
    active = false,
    dungeon = nil,
    route = { path = "", kills = {} },
    options = {
        height = 200,
        widthSide = 200,
        zoomMin = 1,
        zoomMax = 1,
        animate = true,
        fade = false,
        hide = false,
        route = false,
        version = 1,
    }
}

-- TODO: Legacy globals
MDTGuideOptions = nil
MDTGuideActive = nil

Addon.WIDTH = 840
Addon.HEIGHT = 555
Addon.RATIO = Addon.WIDTH / Addon.HEIGHT
Addon.MIN_HEIGHT = 150
Addon.MIN_Y, Addon.MAX_Y = 200, 270
Addon.MIN_X, Addon.MAX_X = Addon.MIN_Y * Addon.RATIO, Addon.MAX_Y * Addon.RATIO
Addon.ZOOM = 1.8
Addon.ZOOM_BORDER = 15
Addon.COLOR_CURR = { 0.13, 1, 1 }
Addon.COLOR_DEAD = { 0.55, 0.13, 0.13 }
Addon.DEBUG = false
Addon.PATTERN_INSTANCE_RESET = "^" .. INSTANCE_RESET_SUCCESS:gsub("%%s", ".+") .. "$"
Addon.MDT_VERSION = "4.3.2.*"

local toggleBtn, currentPullBtn, announceBtn
local hideFrames, hoverFrames
local zoomAnimGrp, fadeAnimGrp
local fadeTicker, isFaded
local isHidden
local mdtVersionMismatch
local previousSublevel

-- ---------------------------------------
--              Toggle mode
-- ---------------------------------------

function Addon.EnableGuideMode(noZoom)
    if MDTGuideDB.active then return end
    MDTGuideDB.active = true

    local main = MDT.main_frame

    -- Hide frames
    Addon.ToggleHideFrames()

    -- Resize
    main:SetResizeBounds(Addon.MIN_HEIGHT * Addon.RATIO, Addon.MIN_HEIGHT)
    MDT:StartScaling()
    MDT:SetScale(MDTGuideDB.options.height / Addon.HEIGHT)
    MDT:UpdateMap(true)
    MDT:DrawAllHulls()

    -- Zoom
    if not noZoom and main.mapPanelFrame:GetScale() > 1 then
        Addon.ZoomBy(Addon.ZOOM)
    end

    -- Adjust top panel
    local f = main.topPanel
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", main, "TOPLEFT")
    f:SetPoint("BOTTOMRIGHT", main, "TOPRIGHT", MDTGuideDB.options.widthSide, 0)
    f:SetHeight(25)
    f = main.topPanelLogo
    f:SetWidth(16)
    f:SetHeight(16)

    -- Adjust bottom panel
    main.bottomPanel:SetHeight(20)

    -- Adjust side panel
    f = main.sidePanel
    f:SetWidth(MDTGuideDB.options.widthSide)
    f:SetPoint("TOPLEFT", main, "TOPRIGHT", 0, 25)
    f:SetPoint("BOTTOMLEFT", main, "BOTTOMRIGHT", 0, -20)
    toggleBtn:SetPoint("RIGHT", main.closeButton, "LEFT")
    currentPullBtn:Show()
    announceBtn:Show()

    -- Adjust enemy info
    f = main.sidePanel.PullButtonScrollGroup
    f.frame:ClearAllPoints()
    f.frame:SetPoint("TOPLEFT", main.scrollFrame, "TOPRIGHT")
    f.frame:SetPoint("BOTTOMLEFT", main.scrollFrame, "BOTTOMRIGHT")
    f.frame:SetWidth(MDTGuideDB.options.widthSide)

    -- Hide some special frames
    if main.toolbar:IsShown() then
        main.toolbar.toggleButton:GetScript("OnClick")()
    end

    MDT:ToggleBoralusSelector()

    -- Adjust enemy info frame
    if MDT.EnemyInfoFrame and MDT.EnemyInfoFrame:IsShown() then
        Addon.AdjustEnemyInfo()
    end

    -- Prevent closing with esc
    for i, v in pairs(UISpecialFrames) do
        if v == "MDTFrame" then tremove(UISpecialFrames, i) break end
    end

    -- Set fade
    Addon.SetFade()

    return true
end

function Addon.DisableGuideMode()
    if not MDTGuideDB.active then return end
    MDTGuideDB.active = false

    local main = MDT.main_frame

    Addon.ToggleHideFrames()

    -- Reset top panel
    local f = main.topPanel
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", main, "TOPLEFT")
    f:SetPoint("BOTTOMRIGHT", main, "TOPRIGHT")
    f:SetHeight(30)
    f = main.topPanelLogo
    f:SetWidth(24)
    f:SetHeight(24)

    -- Reset bottom panel
    main.bottomPanel:SetHeight(30)

    -- Reset side panel
    f = main.sidePanel
    f:SetWidth(251)
    f:SetPoint("TOPLEFT", main, "TOPRIGHT", 0, 30)
    f:SetPoint("BOTTOMLEFT", main, "BOTTOMRIGHT", 0, -30)
    toggleBtn:SetPoint("RIGHT", main.maximizeButton, "LEFT", 0, 0)
    currentPullBtn:Hide()
    announceBtn:Hide()

    -- Reset enemy info
    f = main.sidePanel.PullButtonScrollGroup.frame
    f:ClearAllPoints()
    f:SetWidth(248)
    f:SetHeight(410)
    f:SetPoint("TOPLEFT", main.sidePanel.WidgetGroup.frame, "BOTTOMLEFT", -4, -32)
    f:SetPoint("BOTTOMLEFT", main.sidePanel, "BOTTOMLEFT", 0, 30)

    -- Reset size
    Addon.ZoomBy(1 / Addon.ZOOM)
    MDT:GetDB().nonFullscreenScale = 1
    MDT:Minimize()
    main:SetResizeBounds(Addon.WIDTH * 0.75, Addon.HEIGHT * 0.75)

    -- Reset enemy info frame
    if MDT.EnemyInfoFrame and MDT.EnemyInfoFrame:IsShown() then
        Addon.AdjustEnemyInfo()
    end

    -- Allow closing with esc
    local found
    for _, v in pairs(UISpecialFrames) do
        if v == "MDTFrame" then found = true break end
    end
    if not found then
        tinsert(UISpecialFrames, "MDTFrame")
    end

    -- Disable fade
    Addon.SetFade()

    return true
end

function Addon.ToggleGuideMode()
    if MDTGuideDB.active then
        Addon.DisableGuideMode()
    else
        Addon.EnableGuideMode()
    end
end

function Addon.ReloadGuideMode(fn)
    if Addon.IsActive() then
        Addon.ToggleGuideMode()
        fn()
        Addon.ToggleGuideMode()
    else
        fn()
    end
end

function Addon.AdjustEnemyInfo()
    local f = MDT.EnemyInfoFrame
    if f then
        if not MDTGuideDB.active then
            f.frame:ClearAllPoints()
            f.frame:SetAllPoints(MDTScrollFrame)
            f:EnableResize(false)
            f.frame:SetMovable(false)
            f.frame.StartMoving = function() end
        elseif f:GetPoint(2) then
            f:ClearAllPoints()
            f:SetPoint("CENTER")
            f.frame:SetMovable(true)
            f.frame.StartMoving = UIParent.StartMoving
            f:SetWidth(800)
            f:SetHeight(550)
        end

        MDT:UpdateEnemyInfoFrame()
        f.enemyDataContainer.stealthCheckBox:SetWidth((f.enemyDataContainer.frame:GetWidth() / 2) - 40)
        f.enemyDataContainer.stealthDetectCheckBox:SetWidth((f.enemyDataContainer.frame:GetWidth() / 2))
        f.spellScroll:SetWidth(f.spellScrollContainer.content:GetWidth() or 0)
    end
end

function Addon.ToggleHideFrames()
    local main = MDT.main_frame
    local fn = MDTGuideDB.active and "Hide" or "Show"

    hideFrames = hideFrames or {
        main.bottomPanelString,
        main.sidePanel.WidgetGroup,
        main.sidePanel.ProgressBar,
        main.toolbar.toggleButton,
        main.maximizeButton,
        main.HelpButton,
        main.DungeonSelectionGroup
    }

    for _, f in pairs(hideFrames) do
        f = f.frame or f
        f[fn](f)
    end
end

-- ---------------------------------------
--                 Zoom
-- ---------------------------------------

function Addon.Zoom(s, x, y, smooth)
    local main = MDT.main_frame
    local scroll, map = main.scrollFrame, main.mapPanelFrame

    -- Don't go out of bounds
    local scale = MDT:GetScale()
    local width, height = Addon.WIDTH * scale, Addon.HEIGHT * scale

    if x > width * (1 - 1 / s) then
        local diff = x + width * (1 / s - 1)
        x, y, s = x + diff, y + diff * (1 / Addon.RATIO), 1 / (1 - (x + diff) / width)
    end
    if y > height * (1 - 1 / s) then
        local diff = y + height * (1 / s - 1)
        y, x, s = y + diff, x + diff * Addon.RATIO, 1 / (1 - (y + diff) / height)
    end

    if zoomAnimGrp then
        zoomAnimGrp = zoomAnimGrp:Stop()
    end

    if MDTGuideDB.options.animate and smooth then
        local fromS = map:GetScale()
        local fromX = scroll:GetHorizontalScroll()
        local fromY = scroll:GetVerticalScroll()
        zoomAnimGrp = main:CreateAnimationGroup()
        local anim = zoomAnimGrp:CreateAnimation("Animation")
        anim:SetDuration(0.4)
        anim:SetSmoothing("IN_OUT")
        anim:SetScript("OnUpdate", function()
            local p = anim:GetSmoothProgress()
            map:SetScale(fromS + (s - fromS) * p)
            scroll:SetHorizontalScroll(fromX + (x - fromX) * p)
            scroll:SetVerticalScroll(fromY + (y - fromY) * p)
        end)
        anim:SetScript("OnFinished", function()
            zoomAnimGrp = nil
            MDT:ZoomMap(0)
        end)
        zoomAnimGrp:Play()
    else
        map:SetScale(s)
        scroll:SetHorizontalScroll(x)
        scroll:SetVerticalScroll(y)
        MDT:ZoomMap(0)
    end
end

function Addon.ZoomBy(factor)
    local main = MDT.main_frame
    local scroll, map = main.scrollFrame, main.mapPanelFrame

    local scale = factor * map:GetScale()
    local n = (factor - 1) / 2 / scale
    local scrollX = scroll:GetHorizontalScroll() + n * scroll:GetWidth()
    local scrollY = scroll:GetVerticalScroll() + n * scroll:GetHeight()

    Addon.Zoom(scale, scrollX, scrollY)
end

function Addon.ZoomTo(minX, minY, maxX, maxY, subLevel)
    -- Change sublevel if required
    local currSub = MDT:GetCurrentSubLevel()
    subLevel = subLevel or currSub
    if subLevel ~= currSub then
        MDT:SetCurrentSubLevel(subLevel)
        MDT:UpdateMap(true, true, true)
        MDT:DungeonEnemies_UpdateSelected()
    end

    local diffX, diffY = maxX - minX, maxY - minY

    -- Ensure min rect size
    local scale = MDT:GetScale()
    local sizeScale = scale * Addon.GetDungeonScale() * Addon.GetZoomScale()
    local sizeX = Addon.MIN_X * sizeScale * MDTGuideDB.options.zoomMin
    local sizeY = Addon.MIN_Y * sizeScale * MDTGuideDB.options.zoomMin

    if diffX < sizeX then
        minX, maxX, diffX = minX - (sizeX - diffX) / 2, maxX + (sizeX - diffX) / 2, sizeX
    end
    if diffY < sizeY then
        minY, maxY, diffY = minY - (sizeY - diffY) / 2, maxY + (sizeY - diffY) / 2, sizeY
    end

    -- Get zoom and scroll values
    local s = min(15, Addon.WIDTH / diffX, Addon.HEIGHT / diffY)
    local scrollX = minX + diffX / 2 - Addon.WIDTH / s / 2
    local scrollY = -maxY + diffY / 2 - Addon.HEIGHT / s / 2

    Addon.Zoom(s, scrollX * scale, scrollY * scale, subLevel == previousSublevel)
end

function Addon.ZoomToPull(n)
    n = n or MDT:GetCurrentPull()

    local pulls = Addon.GetCurrentPulls()

    local pull = pulls[n]
    if not pull then return end

    local level = Addon.GetBestSubLevel(pull)
    if not level then return end

    local dungeonScale = Addon.GetDungeonScale()
    local sizeScale = MDT:GetScale() * dungeonScale * Addon.GetZoomScale()
    local sizeX = Addon.MAX_X * sizeScale * MDTGuideDB.options.zoomMax
    local sizeY = Addon.MAX_Y * sizeScale * MDTGuideDB.options.zoomMax
    local border = Addon.ZOOM_BORDER * dungeonScale

    -- Get rect to zoom to
    local minX, minY, maxX, maxY = Addon.GetPullRect(n, level, border)

    -- Try to include prev/next pulls
    for i = 1, 4 do
        for p = -i, i, 2 * i do
            pull = pulls[n + p]

            if pull then
                local pMinX, pMinY, pMaxX, pMaxY = Addon.CombineRects(minX, minY, maxX, maxY, Addon.GetPullRect(pull, level, border))

                if pMinX and pMaxX - pMinX <= sizeX and pMaxY - pMinY <= sizeY then
                    minX, minY, maxX, maxY = pMinX, pMinY, pMaxX, pMaxY
                end
            end
        end
    end

    -- Zoom to rect
    Addon.ZoomTo(minX, minY, maxX, maxY, level)

    -- Scroll pull list
    Addon.ScrollToPull(n)
end

function Addon.ScrollToPull(n, center)
    local main = MDT.main_frame
    local scroll = main.sidePanel.pullButtonsScrollFrame

    local pull = main.sidePanel.newPullButtons[n]
    if not pull then return end

    local height = scroll.scrollframe:GetHeight()
    local offset = (scroll.status or scroll.localstatus).offset
    local top = -select(5, pull.frame:GetPoint(1))
    local bottom = top + pull.frame:GetHeight()

    local diff, scrollTo = scroll.content:GetHeight() - height, nil

    if center then
        scrollTo = max(0, min(top + (bottom - top) / 2 - height / 2, diff))
    elseif top < offset then
        scrollTo = top
    elseif bottom > offset + height then
        scrollTo = bottom - height
    end

    if not scrollTo then return end

    scroll:SetScroll(scrollTo / diff * 1000)
    scroll:FixScroll()
end

-- ---------------------------------------
--                 Fade
-- ---------------------------------------

function Addon.SetFade(fade)
    if fade ~= nil then
        MDTGuideDB.options.fade = fade
    end

    if Addon.IsActive() and MDTGuideDB.options.fade then
        if not fadeTicker then
            fadeTicker = C_Timer.NewTicker(0.5, Addon.Fade)

            for _, f in pairs(Addon.GetHoverFrames()) do
                f:SetScript("OnEnter", Addon.Fade)
                f:SetScript("OnLeave", Addon.Fade)
            end

            Addon.Fade()
        end
    elseif fadeTicker then
        fadeTicker = fadeTicker:Cancel()

        for _, f in pairs(Addon.GetHoverFrames()) do
            f:SetScript("OnEnter", nil)
            f:SetScript("OnLeave", nil)
        end

        Addon.FadeIn()
    end
end

function Addon.Fade()
    if Addon.MouseIsOver() then
        Addon.FadeIn()
    elseif not isFaded then
        isFaded = true
        C_Timer.After(0.5, Addon.FadeOut)
    end
end

function Addon.FadeIn()
    if isFaded then
        isFaded = false
        Addon.SetAlpha(1, true)
    end
end

function Addon.FadeOut()
    if isFaded and not Addon.MouseIsOver() then
        Addon.SetAlpha(MDTGuideDB.options.fade, true)
    end
end

function Addon.SetAlpha(alpha, smooth)
    local main = MDT.main_frame

    if smooth then
        local from = main:GetAlpha()
        fadeAnimGrp = main:CreateAnimationGroup()
        local anim = fadeAnimGrp:CreateAnimation("Animation")
        anim:SetDuration(0.3)
        anim:SetSmoothing("OUT")
        anim:SetScript("OnUpdate", function()
            Addon.SetAlpha(from + (alpha - from) * anim:GetSmoothProgress())
        end)
        anim:SetScript("OnFinished", function()
            fadeAnimGrp = nil
            Addon.SetAlpha(alpha)
        end)
        fadeAnimGrp:Play()
    else
        main:SetAlpha(alpha)
        main.sidePanel.pullButtonsScrollFrame.frame:SetAlpha(alpha)
    end
end

function Addon.MouseIsOver()
    for _, f in pairs(Addon.GetHoverFrames()) do
        if f:IsMouseOver() then return true end
    end
    return false
end

function Addon.GetHoverFrames()
    local main = MDT.main_frame

    hoverFrames = hoverFrames or {
        main,
        main.topPanel,
        main.bottomPanel,
        main.sidePanel
    }

    return hoverFrames
end

-- ---------------------------------------
--                Announce
-- ---------------------------------------

function Addon.AnnouncePull(n)
    n = n or MDT:GetCurrentPreset().value.currentPull
    if not n then return end

    local enemies = Addon.GetCurrentEnemies()

    local pull = Addon.GetCurrentPulls()[n]
    if not pull then return end

    Addon.Chat("---------- Pull " .. n .. " ----------")

    for enemyId, clones in pairs(pull) do
        local enemy = enemies[enemyId]
        if #clones > 0 and enemy and enemy.name then
            Addon.Chat(#clones .. "x " .. enemy.name)
        end
    end

    local forces = MDT:CountForces(n, true)
    if forces > 0 then
        Addon.Chat("Forces: " .. forces .. " => " .. MDT:FormatEnemyForces(MDT:CountForces(n, false)))
    end
end

function Addon.AnnounceSelectedPulls(selection)
    selection = selection or MDT:GetCurrentPreset().value.selection
    if not selection then return end

    for _, i in ipairs(selection) do
        Addon.AnnouncePull(i)
    end
end

function Addon.AnnounceNextPulls(n)
    n = n or MDT:GetCurrentPreset().value.currentPull
    if not n then return end

    for i = n, #Addon.GetCurrentPulls() do
        Addon.AnnouncePull(i)
    end
end

-- ---------------------------------------
--             Enemy forces
-- ---------------------------------------

function Addon.GetEnemyForces()
    local n = select(3, C_Scenario.GetStepInfo())
    if not n or n == 0 then return end

    ---@type number, _, _, string
    local total, _, _, curr = select(5, C_Scenario.GetCriteriaInfo(n)) --[[@as any]]

    return tonumber((curr:gsub("%%", ""))), total
end

function Addon.IsEncounterDefeated(encounterID)
    -- The asset ID seems to be the only thing connecting scenario steps
    -- and journal encounters, other than trying to match the name :/
    local assetID = select(7, EJ_GetEncounterInfo(encounterID))
    local n = select(3, C_Scenario.GetStepInfo())
    if not assetID or not n or n == 0 then return end

    for i = 1, n - 1 do
        local isDead, _, _, _, stepAssetID = select(3, C_Scenario.GetCriteriaInfo(i))
        if stepAssetID == assetID then
            return isDead
        end
    end
end

function Addon.GetCurrentPullByEnemyForces()
    local ef = Addon.GetEnemyForces()
    if not ef then return end

    return Addon.IteratePulls(function(_, enemy, _, _, pull, i)
        ef = ef - enemy.count
        if ef < 0 or enemy.isBoss and not Addon.IsEncounterDefeated(enemy.encounterID) then
            return i, pull
        end
    end)
end

-- ---------------------------------------
--               Progress
-- ---------------------------------------

function Addon.GetCurrentPull()
    if not Addon.IsCurrentInstance() then return end

    if Addon.UseRoute() then
        return Addon.GetCurrentPullByRoute()
    else
        return Addon.GetCurrentPullByEnemyForces()
    end
end

function Addon.ZoomToCurrentPull(refresh)
    if Addon.UseRoute() and refresh then
        Addon.UpdateRoute(true)
    elseif Addon.IsActive() then
        local n, pull = Addon.GetCurrentPull()
        if n then
            MDT:SetSelectionToPull(n)
            if MDT:GetCurrentSubLevel() ~= Addon.GetBestSubLevel(pull) then
                Addon.ZoomToPull(n)
            end
        end
    end
end

function Addon.ColorEnemy(enemyId, cloneId, color)
    local r, g, b = unpack(color)
    local blip = MDT:GetBlip(enemyId, cloneId)
    if blip then
        blip.texture_SelectedHighlight:SetVertexColor(r, g, b, 0.7)
        blip.texture_Portrait:SetVertexColor(r, g, b, 1)
    end
end

function Addon.ColorEnemies()
    if Addon.IsActive() and Addon.IsCurrentInstance() then
        if Addon.UseRoute() then
            local n = Addon.GetCurrentPullByRoute()
            if n and n > 0 then
                Addon.IteratePull(n, function(_, _, cloneId, enemyId)
                    Addon.ColorEnemy(enemyId, cloneId, Addon.COLOR_CURR)
                end)
            end
            for enemyId, cloneId in MDTGuideDB.route.path:gmatch("-e(%d+)c(%d+)-") do
                Addon.ColorEnemy(tonumber(enemyId), tonumber(cloneId), Addon.COLOR_DEAD)
            end
        else
            local n = Addon.GetCurrentPullByEnemyForces()
            if n and n > 0 then
                Addon.IteratePulls(function(_, _, cloneId, enemyId, _, i)
                    if i > n then
                        return true
                    else
                        Addon.ColorEnemy(enemyId, cloneId, i == n and Addon.COLOR_CURR or Addon.COLOR_DEAD)
                    end
                end)
            end
        end
    end
end

-- ---------------------------------------
--                 State
-- ---------------------------------------

function Addon.IsActive()
    local main = MDT.main_frame
    return MDTGuideDB.active and main and main:IsShown()
end

function Addon.IsInRun()
    return Addon.IsActive() and Addon.IsCurrentInstance() and Addon.GetEnemyForces() and true
end

function Addon.CheckMDTVersion()
    if mdtVersionMismatch ~= nil then return end

    local cmp = 0

    local a = C_AddOns.GetAddOnMetadata("MythicDungeonTools", "Version")

    if not a then
        cmp = -1
    else
        local b = Addon.MDT_VERSION
        local ta, tb = { strsplit(".", a) }, { strsplit(".", b) }

        for i = 1, max(#ta, #tb) do
            if tb[i] == "*" then break end
            local va, vb = tonumber(ta[i]) or 0, tonumber(tb[i]) or 0
            if va < vb then cmp = -1 break end
            if va > vb then cmp = 1 break end
        end
    end

    mdtVersionMismatch = cmp ~= 0

    if mdtVersionMismatch then
        Addon.Error("============================================")
        Addon.Error("Unsupported Mythic Dungeon Tools version %s detected!", a or "?")
        Addon.Error("MDTGuide only supports MDT versions %s.", Addon.MDT_VERSION)
        Addon.Error("Please update your %s to the newest version.", cmp < 0 and "MDT" or "MDTGuide")
        Addon.Error("If your MDT window is broken run the following: |cffcccccc/mdt reset|r")
        Addon.Error("============================================")
    end
end

-- ---------------------------------------
--              Events/Hooks
-- ---------------------------------------

local Frame = CreateFrame("Frame")

-- Event listeners
local OnEvent = function(_, ev, ...)
    if not MDT or MDT:GetDB().devMode then return end
    if mdtVersionMismatch then return end

    if ev == "ADDON_LOADED" then
        if ... == Name then
            Frame:UnregisterEvent("ADDON_LOADED")

            Addon.MigrateOptions()

            -- Check MDT version
            Addon.CheckMDTVersion()

            if mdtVersionMismatch then return end

            -- Hook showing interface
            local initialized = false

            hooksecurefunc(MDT, "UpdateBottomText", function()
                if initialized then return end
                initialized = true

                local main = MDT.main_frame

                -- Insert toggle button
                if not toggleBtn then
                    ---@type MaximizeMinimizeButtonFrame
                    toggleBtn = CreateFrame("Button", nil, MDT.main_frame, "MaximizeMinimizeButtonFrameTemplate")
                    toggleBtn[MDTGuideDB.active and "Minimize" or "Maximize"](toggleBtn)
                    toggleBtn:SetOnMaximizedCallback(function() Addon.DisableGuideMode() end)
                    toggleBtn:SetOnMinimizedCallback(function() Addon.EnableGuideMode() end)
                    toggleBtn:Show()

                    main.maximizeButton:SetPoint("RIGHT", main.closeButton, "LEFT", 0, 0)
                    toggleBtn:SetPoint("RIGHT", main.maximizeButton, "LEFT", 0, 0)
                end

                -- Insert current pull button
                if not currentPullBtn then
                    ---@type SquareIconButton
                    currentPullBtn = CreateFrame("Button", nil, MDT.main_frame, "SquareIconButtonTemplate")
                    currentPullBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
                    currentPullBtn:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
                    currentPullBtn:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
                    currentPullBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    currentPullBtn:SetFrameLevel(4)
                    currentPullBtn:SetHeight(21)
                    currentPullBtn:SetWidth(21)
                    currentPullBtn:SetScript("OnClick", function() Addon.ZoomToCurrentPull() end)
                    currentPullBtn:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(currentPullBtn, "ANCHOR_BOTTOM", 0, 0)
                        GameTooltip:AddLine("Go to current pull")
                        GameTooltip:Show()
                    end)
                    currentPullBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

                    currentPullBtn:SetPoint("RIGHT", toggleBtn, "LEFT", 0, 0.5)
                end

                if not announceBtn then
                    announceBtn = CreateFrame("Button", nil, MDT.main_frame, "SquareIconButtonTemplate")
                    announceBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
                    announceBtn:SetDisabledTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Disabled")
                    announceBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    announceBtn:SetFrameLevel(4)
                    announceBtn:SetHeight(13)
                    announceBtn:SetWidth(13)
                    announceBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                    announceBtn:SetScript("OnClick", function(_, btn)
                        if btn == "RightButton" then
                            Addon.AnnounceNextPulls()
                        else
                            Addon.AnnounceSelectedPulls()
                        end
                    end)
                    announceBtn:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(announceBtn, "ANCHOR_BOTTOM", 0, 0)
                        GameTooltip:AddLine("Announce selected pulls")
                        GameTooltip:AddLine("Right click: Also announce following pulls", 1, 1, 1, true)
                        if not IsInGroup() then
                            GameTooltip:AddLine("(Shows preview while not in a group)", 0.7, 0.7, 0.7, true)
                        end
                        GameTooltip:Show()
                    end)
                    announceBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

                    announceBtn:SetPoint("RIGHT", currentPullBtn, "LEFT", -8, 0)
                end

                hooksecurefunc(main, "Show", function ()
                    if not MDTGuideDB.active then return end
                    Addon.ToggleHideFrames()
                end)

                if MDTGuideDB.active then
                    MDTGuideDB.active = false
                    Addon.EnableGuideMode(true)
                end
            end)

            -- Hook maximize/minimize
            hooksecurefunc(MDT, "Maximize", function()
                local main = MDT.main_frame

                Addon.DisableGuideMode()

                if toggleBtn then
                    toggleBtn:Hide()
                    main.maximizeButton:SetPoint("RIGHT", main.closeButton, "LEFT")
                end
            end)
            hooksecurefunc(MDT, "Minimize", function()
                local main = MDT.main_frame

                Addon.DisableGuideMode()

                if toggleBtn then
                    toggleBtn:Show()
                    main.maximizeButton:SetPoint("RIGHT", main.closeButton, "LEFT", 0, 0)
                end
            end)

            -- Hook dungeon selection
            hooksecurefunc(MDT, "ZoomMapToDefault", function()
                Addon.SetCurrentDungeon()
            end)

            -- Hook pull selection
            hooksecurefunc(MDT, "SetSelectionToPull", function(_, pull)
                if Addon.IsActive() and tonumber(pull) and Addon.GetLastSubLevel(pull) == MDT:GetCurrentSubLevel() then
                    Addon.ZoomToPull(pull)
                end
            end)

            -- Hook pull tooltip
            hooksecurefunc(MDT, "ActivatePullTooltip", function()
                if not Addon.IsActive() then return end

                local tooltip = MDT.pullTooltip
                local y2, _, frame, pos, _, y1 = select(5, tooltip:GetPoint(2)), tooltip:GetPoint(1)
                local w = frame:GetWidth() + tooltip:GetWidth()

                tooltip:SetPoint("TOPRIGHT", frame, pos, w, y1)
                tooltip:SetPoint("BOTTOMRIGHT", frame, pos, 250 + w, y2)
            end)

            -- Hook enemy blips
            hooksecurefunc(MDT, "DungeonEnemies_UpdateSelected", Addon.ColorEnemies)

            -- Hook enemy info frame
            hooksecurefunc(MDT, "ShowEnemyInfoFrame", Addon.AdjustEnemyInfo)

            -- Hook menu creation
            hooksecurefunc(MDT, "CreateMenu", function()
                local main = MDT.main_frame

                -- Hook size change
                main.resizer:HookScript("OnMouseUp", function()
                    if not MDTGuideDB.active then return end
                    MDTGuideDB.options.height = main:GetHeight()
                end)
            end)

            -- Hook hull drawing
            local DrawHull = MDT.DrawHull
            MDT.DrawHull = function(...)
                if not MDTGuideDB.active then return DrawHull(...) end

                local multipliers = MDT.scaleMultiplier
                local scale = MDT:GetScale() or 1

                local zoomScale = Addon.GetZoomScale()
                if scale ~= 1 and zoomScale < 1 then scale = scale * zoomScale end

                for i = 1, MDT:GetNumDungeons() do multipliers[i] = (multipliers[i] or 1) * scale end

                DrawHull(...)

                for i, v in pairs(multipliers) do multipliers[i] = v / scale end
            end

            -- Hook hull number drawing
            hooksecurefunc(MDT, "DrawHullFontString", function ()
                local name = "MDTFontStringContainerFrame"
                local scale = MDTGuideDB.active and MDT:GetScale() or 1

                local zoomScale = Addon.GetZoomScale()
                if scale ~= 1 and zoomScale < 1 then scale = scale * zoomScale end

                local i = 0
                while _G[name .. i] ~= nil do
                    _G[name .. i].fs:SetTextScale(scale)
                    i = i + 1
                end
            end)
        end
    elseif ev == "SCENARIO_CRITERIA_UPDATE" and not Addon.UseRoute() then
        Addon.ZoomToCurrentPull(true)
    elseif ev == "PLAYER_REGEN_ENABLED" or ev == "PLAYER_REGEN_DISABLED" then
        if not MDTGuideDB.active or not MDT.main_frame then return end

        local isShown = MDT.main_frame:IsShown()

        if isShown and MDTGuideDB.options.hide and ev == "PLAYER_REGEN_DISABLED" then
            isHidden = true
            MDT:HideInterface()
        elseif isHidden then
            isHidden = false
            if not isShown then
                MDT:ShowInterface()
                Addon.ZoomToCurrentPull(true)
            end
        end
    end
end

Frame:SetScript("OnEvent", OnEvent)
Frame:RegisterEvent("ADDON_LOADED")
Frame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
Frame:RegisterEvent("PLAYER_REGEN_DISABLED")

local OnUpdate = function ()
    if not MDT then return end
    previousSublevel = MDT:GetCurrentSubLevel()
end

Frame:SetScript("OnUpdate", OnUpdate)

-- ---------------------------------------
--                Options
-- ---------------------------------------

SLASH_MDTG1 = "/mdtg"

function SlashCmdList.MDTG(args)
    if mdtVersionMismatch then return end

    local op = MDTGuideDB.options
    local cmd, arg1, arg2 = strsplit(' ', args)

    -- Route
    if cmd == "route" then
        Addon.UseRoute(arg1 ~= "off")
        Addon.Echo("Route estimation", op.route and "enabled" or "disabled")

    -- Zoom
    elseif cmd == "zoom" then
        arg1 = tonumber(arg1)
        if not arg1 then
            return Addon.Echo(cmd, "First parameter must be a number.")
        end
        arg2 = not arg2 and arg1 or tonumber(arg2)
        if not arg2 then
            return Addon.Echo(cmd, "Second parameter must be a number if set.")
        end

        op.zoomMin = arg1
        op.zoomMax = arg2
        Addon.Echo("Zoom scale", "Set to %s/%s", arg1, arg2)

    -- Fade
    elseif cmd == "fade" then
        Addon.SetFade(tonumber(arg1) or arg1 ~= "off" and 0.3)
        Addon.Echo("Fade", op.fade and "enabled" or "disabled")

        -- Hide
    elseif cmd == "hide" then
        op.hide = arg1 ~= "off"

        if isHidden and not MDT.main_frame:IsShown() then
            MDT:ShowInterface()
        end

        Addon.Echo("Hide", op.hide and "enabled" or "disabled")

    -- Animate
    elseif cmd == "animate" then
        op.animate = arg1 ~= "off"

        Addon.Echo("Animations", op.animate and "enabled" or "disabled")

    -- Help
    else
        Addon.Echo("Usage")
        Addon.Command("route [on/off]", "Enable/Disable route estimation. (%s, off)", op.route and "on" or "off")
        Addon.Command("zoom <min-or-both> [<max>]", "Scale default min/max visible area size when zooming. (%s/%s, 1/1)", op.zoomMin, op.zoomMax)
        Addon.Command("fade [on/off/<opacity>]", "Enable/Disable fading or set opacity. (%s, 0.3)", op.fade or "off")
        Addon.Command("hide [on/off]", "Enable/Disable hiding in combat. (%s, off)", op.hide and "on" or "off")
        Addon.Command("animate [on/off]", "Enable/Disable animations. (%s, on)", op.animate and "on" or "off")
        Addon.Echo("|cffcccccc/mdtg|r", "Print this help message.")
        Addon.Echo("Legend", "<...> = number, [...] = optional, .../... = either or, (..., ...) = (current, default)")
    end
end

function Addon.MigrateOptions()
    -- Legacy globals
    if MDTGuideOptions and MDTGuideOptions.version == 1 then
        MDTGuideDB.active = MDTGuideActive
        MDTGuideDB.options = MDTGuideOptions
        MDTGuideActive = nil
        MDTGuideOptions = nil
    end

    -- Migrate options
    local op = MDTGuideDB.options

    if not op.version then
        op.zoom = nil
        op.zoomMin = 1
        op.zoomMax = 1
        op.route = false
        op.version = 1
    end
    if op.version <= 1 then
        op.animate = true
        op.version = 2
    end
end
