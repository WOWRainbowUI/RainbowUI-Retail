---@type string
local Name = ...
---@class Addon
local Addon = select(2, ...)

MDTG = Addon
MDTGuideDB = {
    active = false,
    dungeon = nil,
    offsetEnemyForces = nil,
    offsetBosses = nil,
    options = {
        height = 200,
        widthSide = 200,
        zoomMin = 1,
        zoomMax = 1,
        animate = true,
        fade = false,
        hide = false,
        version = 2,
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

local toggleBtn, currBtn, prevBtn, nextBtn, announceBtn
local hideFrames, hoverFrames
local zoomAnimGrp, fadeAnimGrp
local fadeTicker, isFaded
local isHidden
local previousSublevel
local retry

-- ---------------------------------------
--              Toggle mode
-- ---------------------------------------

function Addon.EnableGuideMode(noZoom)
    if MDTGuideDB.active then return end
    MDTGuideDB.active = true

    local main = MDT.main_frame

    -- Hide frames
    Addon.ToggleHideFrames()
    Addon.HideDungeonButtons()

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

    main.closeButton:SetWidth(18)
    main.closeButton:SetHeight(18)

    toggleBtn:SetPoint("RIGHT", main.closeButton, "LEFT")
    toggleBtn:SetWidth(18)
    toggleBtn:SetHeight(18)

    currBtn:Show()
    prevBtn:Show()
    nextBtn:Show()
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
    local w = main.topPanel
    w:ClearAllPoints()
    w:SetPoint("BOTTOMLEFT", main, "TOPLEFT")
    w:SetPoint("BOTTOMRIGHT", main, "TOPRIGHT")
    w:SetHeight(30)
    w = main.topPanelLogo
    w:SetWidth(24)
    w:SetHeight(24)

    -- Reset bottom panel
    main.bottomPanel:SetHeight(30)

    -- Reset side panel
    w = main.sidePanel
    w:SetWidth(251)
    w:SetPoint("TOPLEFT", main, "TOPRIGHT", 0, 30)
    w:SetPoint("BOTTOMLEFT", main, "BOTTOMRIGHT", 0, -30)

    main.closeButton:SetWidth(24)
    main.closeButton:SetHeight(24)

    toggleBtn:SetPoint("RIGHT", main.maximizeButton, "LEFT", 0, 0)
    toggleBtn:SetWidth(24)
    toggleBtn:SetHeight(24)

    currBtn:Hide()
    prevBtn:Hide()
    nextBtn:Hide()
    announceBtn:Hide()

    -- Reset enemy info
    local f = main.sidePanel.PullButtonScrollGroup.frame
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

    ---@type table<FontString | AceGUIWidget>
    hideFrames = hideFrames or {
        main.bottomPanelString,
        main.sidePanel.WidgetGroup,
        main.sidePanel.ProgressBar,
        main.toolbar.toggleButton,
        main.maximizeButton,
        main.HelpButton,
        main.DungeonSelectionGroup,
        main.seasonSelectionGroup,
        main.externalButtonGroup
    }

    for _, f in pairs(hideFrames) do
        f = f.frame or f
        f[fn](f)
    end
end

function Addon.HideDungeonButtons()
    for i=1,100 do
        local f = _G["MDTDungeonButton" .. i]
        if f then f:Hide() else break end
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
    local f = 1 - 1 / s

    x = math.max(0, math.min(x, width * f))
    y = math.max(0, math.min(y, height * f))

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

-- This seems to fix screen freezes due to multiple rapid calls
Addon.Zoom = Addon.FnDebounce(Addon.Zoom, 0, true, true)

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
--               Fade/Hide
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

function Addon.SetHide(hide)
    if hide ~= nil then
        MDTGuideDB.options.hide = hide
    end

    if isHidden and not MDT.main_frame:IsShown() then
        MDT:ShowInterface()
    end
end

-- ---------------------------------------
--                Announce
-- ---------------------------------------

---@param n? number
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

---@param selection? number[]
function Addon.AnnounceSelectedPulls(selection)
    selection = selection or MDT:GetCurrentPreset().value.selection
    if not selection then return end

    for _, i in ipairs(selection) do
        Addon.AnnouncePull(i)
    end
end

---@param n? number 
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

function Addon.GetEnemyForces(real)
    local ef = not real and MDTGuideDB.offsetEnemyForces or 0
    if not Addon.IsCurrentInstance() then return ef end

    local n = select(3, C_Scenario.GetStepInfo())
    if not n or n == 0 then return ef end

    local info = C_ScenarioInfo.GetCriteriaInfo(n)

    return ef + tonumber((info.quantityString:gsub("%%", "")))
end

function Addon.GetNumDefeatedEncounters(real)
    local b = not real and MDTGuideDB.offsetBosses or 0
    if not Addon.IsCurrentInstance() then return b end

    local n = select(3, C_Scenario.GetStepInfo())
    if not n or n == 0 then return b end

    for i = 1, n - 1 do
        local info = C_ScenarioInfo.GetCriteriaInfo(i)
        if info.completed then b = b + 1 end
    end

    return b
end

---@return number?
---@return MDTPull?
function Addon.GetCurrentPullByEnemyForces(real)
    local trash, bosses = Addon.GetEnemyForces(real), Addon.GetNumDefeatedEncounters(real)
    local prevBossPull = nil

    return Addon.IteratePulls(function(_, enemy, _, _, pull, i)
        if not enemy.isBoss then
            trash = trash - enemy.count
        elseif i ~= prevBossPull then
            bosses, prevBossPull = bosses - 1, i
        end

        if trash < 0 or bosses < 0 then return i, pull end
    end)
end

function Addon.SetEnemyForcesOffsets(trash, bosses)
    MDTGuideDB.offsetEnemyForces = trash and trash - Addon.GetEnemyForces(true) or nil
    MDTGuideDB.offsetBosses = bosses and bosses - Addon.GetNumDefeatedEncounters(true) or nil
end

-- ---------------------------------------
--               Progress
-- ---------------------------------------

function Addon.SetCurrentPull(n, permanent)
    local pulls = Addon.GetCurrentPulls()

    if n < 1 or n > #pulls then return end

    if permanent then
        local trash, bosses = 0, 0

        Addon.IteratePulls(function (_, enemy, _, _, _, i)
            if i == n then
                return true
            elseif enemy.isBoss then
                bosses = bosses + 1
            else
                trash = trash + enemy.count
            end
        end)

        Addon.SetEnemyForcesOffsets(trash, bosses)
    end

    MDT:SetSelectionToPull(n)

    if MDT:GetCurrentSubLevel() == Addon.GetBestSubLevel(pulls[n]) then return end

    Addon.ZoomToPull(n)
end

function Addon.ChangeCurrentPullBy(by, permanent)
    local n = MDT:GetCurrentPreset().value.currentPull or #Addon.GetCurrentPulls()
    Addon.SetCurrentPull(n + by, permanent)
end

function Addon.GetCurrentPull()
    return Addon.GetCurrentPullByEnemyForces()
end

function Addon.ZoomToCurrentPull()
    if not Addon.IsActive() then return end

    local n = Addon.GetCurrentPull()
    if not n then return end

    Addon.SetCurrentPull(n)
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
    if not Addon.IsActive() then return end

    local n, ef = Addon.GetCurrentPullByEnemyForces(), Addon.GetEnemyForces()
    if not n then return end

    Addon.IteratePulls(function(_, enemy, cloneId, enemyId, _, i)
        if i > n then return true end

        ef = ef - enemy.count

        local color = i == n and (ef < 0 or enemy.isBoss) and Addon.COLOR_CURR or Addon.COLOR_DEAD

        Addon.ColorEnemy(enemyId, cloneId, color)
    end)
end

-- ---------------------------------------
--                 State
-- ---------------------------------------

function Addon.IsActive()
    local main = MDT.main_frame
    return MDTGuideDB.active and main and main:IsShown()
end

function Addon.IsInRun()
    return Addon.IsActive() and Addon.IsCurrentInstance() and Addon.GetEnemyForces() > 0 and true
end

-- ---------------------------------------
--              Events/Hooks
-- ---------------------------------------

local Frame = CreateFrame("Frame")

-- Event listeners
local OnEvent = function(_, ev, ...)
    if not MDT or MDT:GetDB().devMode then return end

    if ev == "ADDON_LOADED" then
        if ... == Name then
            Frame:UnregisterEvent("ADDON_LOADED")

            Addon.Options:OnLoaded()

            

            -- Hook showing interface
            local initialized = false

            hooksecurefunc(MDT, "UpdateBottomText", function()
                if initialized then return end
                initialized = true

                local main = MDT.main_frame

                -- Insert toggle button
                if not toggleBtn then
                    ---@type MaximizeMinimizeButtonFrame
                    local f = CreateFrame("Button", nil, MDT.main_frame, "MaximizeMinimizeButtonFrameTemplate")
                    f[MDTGuideDB.active and "Minimize" or "Maximize"](f)
                    f:SetOnMaximizedCallback(function() Addon.DisableGuideMode() end)
                    f:SetOnMinimizedCallback(function() Addon.EnableGuideMode() end)
                    f:Show()

                    f:SetPoint("RIGHT", main.maximizeButton, "LEFT", 0, 0)
                    main.maximizeButton:SetPoint("RIGHT", main.closeButton, "LEFT", 0, 0)

                    main.sidePanel.WidgetGroup.PresetDropDown.frame:SetWidth(145)

                    toggleBtn = f
                end

                if not announceBtn then
                    ---@type SquareIconButton
                    local f = CreateFrame("Button", nil, MDT.main_frame, "SquareIconButtonTemplate")
                    f:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
                    f:SetDisabledTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Disabled")
                    f:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    f:SetFrameLevel(4)
                    f:SetHeight(13)
                    f:SetWidth(13)
                    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                    f:SetScript("OnClick", function(_, btn)
                        if btn == "RightButton" then
                            Addon.AnnounceNextPulls()
                        else
                            Addon.AnnounceSelectedPulls()
                        end
                    end)
                    f:SetScript("OnLeave", GameTooltip_Hide)
                    f:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
                        GameTooltip:AddLine("Announce selected pulls")
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cffeda55fRight-click:|r Also announce following pulls", 0.2, 1, 0.2)
                        if not IsInGroup() then
                            GameTooltip:AddLine("(Shows preview while not in a group)", 0.7, 0.7, 0.7, true)
                        end
                        GameTooltip:Show()
                    end)

                    f:SetPoint("RIGHT", toggleBtn, "LEFT", -5, 0)
                    f:Hide()

                    announceBtn = f
                end

                -- Insert current pull button
                if not currBtn then
                    ---@type SquareIconButton
                    local f = CreateFrame("Button", nil, MDT.main_frame.bottomPanel, "SquareIconButtonTemplate")
                    -- f:SetNormalTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
                    -- f:SetPushedTexture("Interface\\Buttons\\LockButton-Unlocked-Down")
                    f:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
                    f:SetPushedTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Down")
                    f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Disabled")
                    f:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    f:SetFrameLevel(4)
                    f:SetHeight(21)
                    f:SetWidth(21)
                    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                    f:SetScript("OnClick", function(_, btn)
                        if btn == "RightButton" then
                            Addon.SetCurrentPull(MDT:GetCurrentPreset().value.currentPull, true)
                        else
                            if IsShiftKeyDown() then Addon.SetEnemyForcesOffsets() end
                            Addon.ZoomToCurrentPull()
                        end
                    end)
                    f:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
                        GameTooltip:AddLine("Go to current pull")
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cffeda55fRight-click:|r Set current pull to selected pull", 0.2, 1, 0.2)
                        GameTooltip:AddLine("|cffeda55fShift-click:|r Reset current pull to raw dungeon progress", 0.2, 1, 0.2)
                        GameTooltip:Show()
                    end)
                    f:SetScript("OnLeave", GameTooltip_Hide)

                    f:SetPoint("LEFT", MDT.main_frame.bottomPanel, "RIGHT", 90, 0)
                    f:Hide()

                    currBtn = f
                end

                if not prevBtn then
                    ---@type SquareIconButton
                    local f = CreateFrame("Button", nil, MDT.main_frame.bottomPanel, "SquareIconButtonTemplate")
                    f:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
                    f:SetPushedTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Down")
                    f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Disabled")
                    f:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    f:RotateTextures(math.rad(90))
                    f:SetFrameLevel(4)
                    f:SetHeight(21)
                    f:SetWidth(21)
                    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                    f:SetScript("OnClick", function(_, btn) Addon.ChangeCurrentPullBy(-1, btn == "RightButton") end)
                    f:SetScript("OnLeave", GameTooltip_Hide)
                    f:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
                        GameTooltip:AddLine("Go to previous pull")
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cffeda55fRight-click:|r Set current pull to previous pull", 0.2, 1, 0.2)
                        GameTooltip:Show()
                    end)

                    f:SetPoint("RIGHT", currBtn, "LEFT", -1, 0)
                    f:Hide()

                    prevBtn = f
                end

                if not nextBtn then
                    ---@type SquareIconButton
                    local f = CreateFrame("Button", nil, MDT.main_frame.bottomPanel, "SquareIconButtonTemplate")
                    f:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
                    f:SetPushedTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Down")
                    f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Disabled")
                    f:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    f:RotateTextures(math.rad(90))
                    f:SetFrameLevel(4)
                    f:SetHeight(21)
                    f:SetWidth(21)
                    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                    f:SetScript("OnClick", function(_, btn) Addon.ChangeCurrentPullBy(1, btn == "RightButton") end)
                    f:SetScript("OnLeave", GameTooltip_Hide)
                    f:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
                        GameTooltip:AddLine("Go to next pull")
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cffeda55fRight-click:|r Set current pull to next pull", 0.2, 1, 0.2)
                        GameTooltip:Show()
                    end)

                    f:SetPoint("LEFT", currBtn, "RIGHT", 1, 0)
                    f:Hide()

                    nextBtn = f
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

            -- Hook dungeon button update
            hooksecurefunc(MDT, "UpdateDungeonDropDown", function ()
                if not Addon.IsActive() then return end
                Addon.HideDungeonButtons()
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

                local scale = MDT:GetScale() or 1
                local zoomScale = Addon.GetZoomScale()

                if scale ~= 1 and zoomScale < 1 then scale = scale * zoomScale end

                local dungeonId = Addon.GetCurrentDungeonId()
                local multipliers = MDT.scaleMultiplier

                local origScale = multipliers[dungeonId]
                multipliers[dungeonId] = (origScale or 1) * scale

                DrawHull(...)

                multipliers[dungeonId] = origScale
            end

            -- Hook hull number drawing
            hooksecurefunc(MDT, "DrawHullFontString", function (_, _, pullIdx)
                local name = "MDTFontStringContainerFrame"
                local scale = MDTGuideDB.active and MDT:GetScale() or 1

                local zoomScale = Addon.GetZoomScale()
                if scale ~= 1 and zoomScale < 1 then scale = scale * zoomScale end

                local i, frame = -1, _G[name .. (pullIdx - 1)]
                repeat
                    if frame and frame.pullIdx == pullIdx then
                        local point, relativeTo, relativePoint, x, y = frame:GetPoint(1)
                        frame:SetScale(scale)
                        frame:ClearAllPoints()
                        frame:SetPoint(point, relativeTo, relativePoint, x / scale, y / scale)
                        break
                    end
                    i = i + 1
                    frame = _G[name .. i]
                until not frame
            end)
        end
    elseif ev == "PLAYER_ENTERING_WORLD" or ev == "ZONE_CHANGED_NEW_AREA" or ev == "WORLD_STATE_TIMER_START" then
        local isParty = select(2, IsInInstance()) == "party"
        if not isParty then return end

        local map = C_Map.GetBestMapForUnit("player")
        if not map then retry = {ev, ...} return end

        local dungeon = Addon.GetInstanceDungeonId(map)
        Addon.SetInstanceDungeon(dungeon)
    elseif ev == "SCENARIO_CRITERIA_UPDATE" then
        Addon.ZoomToCurrentPull()
    elseif ev == "SCENARIO_COMPLETED" or ev == "CHAT_MSG_SYSTEM" and canaccessvalue(...) and (...):match(Addon.PATTERN_INSTANCE_RESET) then
        Addon.SetInstanceDungeon()
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
                C_Timer.After(0.1, function () Addon.ZoomToCurrentPull() end)
            end
        end
    end
end

local OnUpdate = function ()
    if not MDT then return end
    previousSublevel = MDT:GetCurrentSubLevel()

    if retry then
        local args = retry
        retry = nil
        OnEvent(nil, unpack(args))
    end
end

Frame:SetScript("OnEvent", OnEvent)
Frame:SetScript("OnUpdate", OnUpdate)
Frame:RegisterEvent("ADDON_LOADED")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Frame:RegisterEvent("WORLD_STATE_TIMER_START")
Frame:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
Frame:RegisterEvent("SCENARIO_COMPLETED")
Frame:RegisterEvent("CHAT_MSG_SYSTEM")
Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
