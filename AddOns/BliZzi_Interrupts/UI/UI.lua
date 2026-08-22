-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    UI.lua - BliZzi Interrupts
    Main frame, bars, resize handle and display update loop.
]]

BIT    = BIT or {}
BIT.UI = BIT.UI or {}

local bars         = {}
local mainFrame    = nil
local titleText    = nil
local resizeHandle = nil
local _posEditor        = nil
local _posEditorRefresh = nil
local isResizing   = false
local shouldShowByZone = true

------------------------------------------------------------
-- Fade helper
-- FadeFrame(frame, targetAlpha, duration)
-- Smoothly transitions a frame to targetAlpha over duration seconds.
-- Automatically calls Show() at start and Hide() when fading to 0.
------------------------------------------------------------
local _fadeTickers = {}   -- frame → ticker, so we can cancel mid-fade

local function FadeFrame(frame, targetAlpha, duration)
    if not frame then return end
    duration = duration or 0.3

    -- Cancel any in-progress fade on this frame
    if _fadeTickers[frame] then
        _fadeTickers[frame]:Cancel()
        _fadeTickers[frame] = nil
    end

    local startAlpha = frame:GetAlpha()

    -- Already at target — just make sure visibility is correct
    if math.abs(startAlpha - targetAlpha) < 0.01 then
        if targetAlpha <= 0 then frame:Hide() else frame:Show() end
        -- Sync child bar alphas too (SetAlpha doesn't propagate to child frames)
        for _, bar in ipairs(bars) do bar:SetAlpha(targetAlpha) end
        return
    end

    if targetAlpha > 0 then
        frame:SetAlpha(startAlpha)
        frame:Show()
    end

    local elapsed  = 0
    local interval = 0.02   -- ~50fps
    _fadeTickers[frame] = C_Timer.NewTicker(interval, function(t)
        elapsed = elapsed + interval
        local pct   = math.min(elapsed / duration, 1)
        local alpha = startAlpha + (targetAlpha - startAlpha) * pct
        frame:SetAlpha(alpha)
        -- Child frames need explicit alpha (WoW doesn't propagate parent alpha to child frames)
        for _, bar in ipairs(bars) do bar:SetAlpha(alpha) end
        if pct >= 1 then
            t:Cancel()
            _fadeTickers[frame] = nil
            if targetAlpha <= 0 then frame:Hide() end
        end
    end)
end

------------------------------------------------------------
-- Layout helper
------------------------------------------------------------
local function GetBarLayout()
    local db    = BIT.db
    local fw    = db.frameWidth
    local titleH = db.showTitle and 20 or 0

    -- Snap barH to a value that is an exact integer number of screen pixels.
    -- mainFrame may have its own scale (ApplyAutoScale), so use GetEffectiveScale()
    -- on the mainFrame itself if it exists, otherwise fall back to UIParent.
    local uiScale = (mainFrame and mainFrame:GetEffectiveScale()) or UIParent:GetEffectiveScale()
    local rawH    = math.max(2, db.barHeight)
    local barH    = math.floor(rawH * uiScale + 0.5) / uiScale

    -- Icon size + column width. This one value is BOTH the icon's square
    -- size AND the horizontal column the bar fill insets away from, so the
    -- fill/name/CD span the bar's remaining width automatically.
    --   interruptIconSize == 0 → Auto: square matches the bar height (the
    --                            classic look).
    --   interruptIconSize  > 0 → independent size; the icon is bottom-aligned
    --                            with the bar (shared lower edge) and overhangs
    --                            UPWARD when larger — see the icon anchor in
    --                            RebuildBars / setCol.
    -- Icon column size (interruptIconSize, or the bar height in Auto).
    -- "Show Icon" off collapses it to 0 so the bar spans the full width.
    local iconS = barH
    local cfgIcon = db.interruptIconSize
    if cfgIcon and cfgIcon > 0 then
        iconS = math.max(2, math.floor(cfgIcon * uiScale + 0.5) / uiScale)
    end
    -- Horizontal gap between the icon and the bar (only while the icon shows).
    -- Raw value (NOT pixel-snapped): empty space between two already-snapped
    -- elements, so snapping adds nothing but tied the gap to the frame's
    -- transiently-varying scale (1px-live-vs-reload flip). Raw is exact + stable.
    local iconGap = 0
    if db.showIcon ~= false and db.interruptIconGap and db.interruptIconGap > 0 then
        iconGap = db.interruptIconGap
    end
    if db.showIcon == false then iconS = 0 end
    -- barInset = total horizontal space the bar fill avoids (icon + gap).
    local barInset = iconS + iconGap
    local barW  = math.max(60, fw - barInset)
    local autoNameSize = math.max(9,  math.floor(barH * 0.45))
    local autoCdSize   = math.max(10, math.floor(barH * 0.55))
    local fontSize   = (db.nameFontSize  and db.nameFontSize  > 0) and db.nameFontSize  or autoNameSize
    local cdFontSize = (db.readyFontSize and db.readyFontSize > 0) and db.readyFontSize or autoCdSize
    return barW, barH, iconS, fontSize, cdFontSize, titleH, barInset
end

-- Icon Only mode: returns true when the tracker should use compact icon grid
-- Icon Only Mode was removed in 3.3.8 — the feature conflicted with the new
-- Attached-to-Unit-Frames display and caused overlap confusion. The stub
-- always returns false so the remaining code paths that branch on
-- iconOnly stay dormant without needing line-by-line deletion.
local function IsIconOnlyMode()
    return false
end

-- Build the "|cFFrrggbb" prefix used to color player names in the tracker.
-- Chooses between the class color (when the user enabled that toggle) and
-- the custom color picker value. Falls back to white on any lookup miss.
local function NameColorCode(class)
    local db = BIT.db or {}
    local r, g, b = 1, 1, 1
    if db.nameColorUseClass and class and BIT.CLASS_COLORS and BIT.CLASS_COLORS[class] then
        local c = BIT.CLASS_COLORS[class]
        r, g, b = c[1] or 1, c[2] or 1, c[3] or 1
    else
        r = db.nameColorR or 1
        g = db.nameColorG or 1
        b = db.nameColorB or 1
    end
    return string.format("|cFF%02X%02X%02X",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5))
end

------------------------------------------------------------
-- Free-anchor frame picker
------------------------------------------------------------
-- Resolve a saved frame name / dotted global path ("SomePanel" or
-- "Parent.Child") to a live, anchorable frame. nil if it can't be found.
local function ResolveFramePath(path)
    if type(path) ~= "string" or path == "" then return nil end
    local target = _G
    for part in string.gmatch(path, "([^%.]+)") do
        if type(target) ~= "table" then return nil end
        target = target[part]
    end
    if type(target) ~= "table" or type(target.GetCenter) ~= "function" then
        return nil
    end
    return target
end
BIT.UI.ResolveFramePath = ResolveFramePath

-- Resolve the on-screen name of a frame: its own GetName, else a global
-- lookup, else a "Parent.Key" path (up to 5 levels). This is what lets a
-- picked anchor survive /reload — it's stored and re-resolved by name.
local function ResolvePickName(frame, depth)
    depth = depth or 0
    if not frame or depth > 5 then return nil end
    local okN, name = pcall(frame.GetName, frame)
    if okN and type(name) == "string" and name ~= "" then return name end
    if depth == 0 then
        for k, v in pairs(_G) do
            if v == frame and type(k) == "string" then return k end
        end
    end
    local parent = frame.GetParent and frame:GetParent()
    if not parent then return nil end
    local key = frame.GetParentKey and frame:GetParentKey()
    if not key then
        for k, v in pairs(parent) do
            if v == frame and type(k) == "string" then key = k; break end
        end
    end
    if key then
        local pn = ResolvePickName(parent, depth + 1)
        if pn then return pn .. "." .. key end
    end
    return nil
end

local _pickHighlight
-- Frame under the cursor: modern GetMouseFoci, legacy GetMouseFocus, then a
-- secret-safe bounds scan for restricted frames the focus APIs skip.
local function FrameUnderCursor()
    local focus
    if GetMouseFoci then
        local foci = GetMouseFoci()
        focus = foci and foci[1]
    elseif GetMouseFocus then
        focus = GetMouseFocus()
    end
    if (not focus or focus == WorldFrame) and EnumerateFrames then
        local cx, cy = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        if scale and scale > 0 then cx, cy = cx / scale, cy / scale end
        local best, bestLvl = nil, -1
        local f = EnumerateFrames()
        while f do
            if f ~= _pickHighlight and f.IsVisible and f:IsVisible() then
                -- One pcall via GetRect (left, bottom, width, height) instead
                -- of four separate edge getters — same bounds test, 4x fewer
                -- protected calls across the whole frame tree.
                local ok, l, b, wdt, hgt = pcall(f.GetRect, f)
                if ok and type(l) == "number" and type(b) == "number"
                   and type(wdt) == "number" and type(hgt) == "number"
                   and not (issecretvalue and (issecretvalue(l) or issecretvalue(b) or issecretvalue(wdt) or issecretvalue(hgt)))
                   and cx >= l and cx <= l + wdt and cy >= b and cy <= b + hgt then
                    local lvl = (f.GetFrameLevel and f:GetFrameLevel()) or 0
                    if lvl > bestLvl then bestLvl = lvl; best = f end
                end
            end
            f = EnumerateFrames(f)
        end
        focus = best
    end
    if focus == WorldFrame or focus == _pickHighlight then return nil end
    return focus
end

local _pickOverlay
-- Start the anchor picker. onConfirm(frameName) fires on left-click,
-- onCancel() on right-click / ESC, onHover(frameName|nil) whenever the
-- frame under the cursor changes (the caller shows the name in its own
-- fixed panel — no cursor-following tooltip). Highlights the hovered frame.
--
-- Performance: the expensive part is FrameUnderCursor (it can walk the whole
-- frame tree when the cursor is over empty space / a restricted frame). That
-- ran every screen frame in the first version and spiked CPU + stuttered the
-- cursor. It now runs on a throttle, the cursor reticle is set once, and the
-- highlight / name only refresh when the target actually changes.
local PICK_SCAN_INTERVAL = 0.05   -- 20 Hz scan: responsive but ~3-5x cheaper
function BIT.UI:StartFramePicker(onConfirm, onCancel, onHover)
    if not _pickOverlay then _pickOverlay = CreateFrame("Frame") end
    if not _pickHighlight then
        _pickHighlight = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        _pickHighlight:SetFrameStrata("TOOLTIP")
        _pickHighlight:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 2 })
        _pickHighlight:SetBackdropBorderColor(0, 1, 0, 1)
    end

    local lastName, lastFocus, leftWasDown
    local sinceScan = 0
    SetCursor("CAST_CURSOR")   -- set ONCE; re-setting every tick caused flicker

    local function stop(confirmed)
        _pickOverlay:SetScript("OnUpdate", nil)
        _pickHighlight:Hide()
        ResetCursor()
        if confirmed and lastName and type(onConfirm) == "function" then
            onConfirm(lastName)
        elseif not confirmed and type(onCancel) == "function" then
            onCancel()
        end
    end

    _pickOverlay:SetScript("OnUpdate", function(_, dt)
        -- Cheap input checks stay every frame so cancel / select feel instant.
        if IsMouseButtonDown("RightButton") or IsKeyDown("ESCAPE") then
            stop(false); return
        end
        local leftDown = IsMouseButtonDown("LeftButton")
        if leftDown and not leftWasDown and lastName then
            stop(true); return
        end
        leftWasDown = leftDown

        -- Throttle the frame-tree scan + visual refresh.
        sinceScan = sinceScan + (dt or 0)
        if sinceScan < PICK_SCAN_INTERVAL then return end
        sinceScan = 0

        local focus = FrameUnderCursor()
        if focus == lastFocus then return end   -- nothing moved: skip all work
        lastFocus = focus

        local name = focus and ResolvePickName(focus) or nil
        if focus and name then
            lastName = name
            _pickHighlight:ClearAllPoints()
            _pickHighlight:SetFrameLevel(((focus.GetFrameLevel and focus:GetFrameLevel()) or 0) + 20)
            _pickHighlight:SetPoint("TOPLEFT", focus, "TOPLEFT", -2, 2)
            _pickHighlight:SetPoint("BOTTOMRIGHT", focus, "BOTTOMRIGHT", 2, -2)
            _pickHighlight:Show()
        else
            lastName = nil
            _pickHighlight:Hide()
        end
        if type(onHover) == "function" then onHover(lastName) end
    end)
end

------------------------------------------------------------
-- Zone visibility
------------------------------------------------------------
-- Pure per-zone toggle check for the CURRENT context (no force / combat /
-- settings-open overrides). True when the tracker is set to show in this
-- zone. Used by CheckZoneVisibility for the window fade AND by the Core
-- activity gate (BIT:UpdateKickWatch) so the broad cast watchers are torn
-- down in a zone the tracker isn't shown in (e.g. raid + "Show in Raid" off).
function BIT.UI:IsZoneEnabled()
    local db = BIT.db
    if not db then return true end
    if BIT.testMode then return true end
    -- "Show in raid" applies to both raid INSTANCES and raid GROUPS: a raid
    -- group in the open world or a 5-man should still respect showInRaid.
    local _, instanceType = IsInInstance()
    if IsInRaid()              then return db.showInRaid      and true or false end
    if instanceType == "party" then return db.showInDungeon   and true or false end
    if instanceType == "raid"  then return db.showInRaid      and true or false end
    if instanceType == "arena" then return db.showInArena     and true or false end
    if instanceType == "pvp"   then return db.showInBG        and true or false end
    return db.showInOpenWorld and true or false
end

function BIT.UI:CheckZoneVisibility(force)
    -- Feature switched off: keep the window hidden and skip all work
    -- (this also fires from the shared core event frame, so it's the
    -- main guard against a passive repaint reviving the tracker).
    if BIT.Interrupts and not BIT.Interrupts:IsEnabled() then
        if mainFrame then FadeFrame(mainFrame, 0, 0.2) end
        return
    end
    local db = BIT.db
    -- Test mode acts like a permanent force-on: any zone-change event
    -- during /bittest would otherwise re-evaluate the per-zone toggles
    -- and could fade the window out (e.g. when "Open World" is off and
    -- the player is in open world), which freezes the bar tick because
    -- UpdateDisplay early-returns on `not shouldShowByZone`.
    if force or BIT.testMode then
        shouldShowByZone = true
    else
        shouldShowByZone = BIT.UI:IsZoneEnabled()
    end
    if mainFrame then
        local settingsOpen = BIT_SettingsFrame and BIT_SettingsFrame:IsShown()
        -- Display mode controls window visibility unconditionally — even
        -- while the settings panel is open. The user wants live feedback
        -- on what the chosen mode actually looks like, so the bars window
        -- must hide as soon as ATTACHED is picked, not only after the
        -- settings dialog is closed.
        if db.interruptDisplayMode == "ATTACHED" then
            FadeFrame(mainFrame, 0, 0.2)
        else
            -- Test mode forces full visibility regardless of zone or
            -- the "Hide out of combat" toggle — the user explicitly
            -- triggered a preview and expects to see the bars.
            local shouldShow = settingsOpen or BIT.testMode
                or (shouldShowByZone and (not db.hideOutOfCombat or BIT.inCombat))
            local targetAlpha = shouldShow and (db.alpha or 1.0) or 0
            FadeFrame(mainFrame, targetAlpha, 0.4)
        end
    end

    -- Rebuild attached icons on zone transitions — party frames can change
    -- (e.g. entering/leaving an instance), so the anchor may have moved.
    if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
        BIT.UI.AttachedInterrupts:Rebuild()
    end

    -- Sync the Core activity gate: when this zone isn't shown, the broad
    -- cast watchers are torn down so the addon costs ~nothing here. Covers
    -- live "Show in <zone>" setting flips (this runs on each toggle change).
    if BIT.UpdateKickWatch then BIT:UpdateKickWatch() end
end

------------------------------------------------------------
-- Rebuild bars
------------------------------------------------------------
function BIT.UI:RebuildBars()
    if BIT.Interrupts and not BIT.Interrupts:IsEnabled() then return end
    local db  = BIT.db
    local m   = BIT.Media

    for i = 1, 7 do
        if bars[i] then
            bars[i]:Hide()
            bars[i]:SetParent(nil)
            bars[i] = nil
        end
    end

    local barW, barH, iconS, fontSize, cdFontSize, titleH, barInset = GetBarLayout()
    local iconOnly = IsIconOnlyMode()
    if iconOnly then titleH = 0 end

    if not mainFrame then return end
    mainFrame:SetSize(db.frameWidth, mainFrame:GetHeight() or 200)
    -- Alpha is managed by CheckZoneVisibility / FadeFrame — don't override here
    if titleText then
        local attachedBars = db.interruptDisplayMode == "ATTACHED_BARS"
        if db.showTitle and not iconOnly and not attachedBars then titleText:Show() else titleText:Hide() end
        local titleSize = (db.titleFontSize and db.titleFontSize > 0) and db.titleFontSize or 12
        m:SetFont(titleText, titleSize)
        local align   = db.titleAlign or "CENTER"
        local titleY  = -titleH + (db.titleOffsetY or 0)
        titleText:ClearAllPoints()
        if align == "LEFT" then
            titleText:SetPoint("BOTTOMLEFT",  mainFrame, "TOPLEFT",  0, titleY)
        elseif align == "RIGHT" then
            titleText:SetPoint("BOTTOMRIGHT", mainFrame, "TOPRIGHT", 0, titleY)
        else
            titleText:SetPoint("BOTTOM",      mainFrame, "TOP",      0, titleY)
        end
        titleText:SetTextColor(db.titleColorR or 0, db.titleColorG or 0.867, db.titleColorB or 0.867)
        -- Force re-render so alignment takes effect immediately
        titleText:SetText(titleText:GetText())
    end
    -- Re-anchor frame so bar[1] stays fixed when title is toggled
    if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end


    local prevFrame = nil
    local barGap = db.barGap or 0
    local growUp = db.growUpward
    local iconOnly = IsIconOnlyMode()

    for i = 1, 7 do
        local f = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")

        if iconOnly then
            -- ── Icon Only mode: square icon cells in a horizontal row ──
            local icoSize = db.iconOnlySize or 36
            local icoGap  = db.iconOnlySpacing or 4
            local perRow  = db.iconOnlyPerRow or 7
            local goRight = (db.iconOnlyGrowth or "RIGHT") == "RIGHT"
            f:SetSize(icoSize, icoSize)

            local col = (i - 1) % perRow
            local row = math.floor((i - 1) / perRow)
            local xOff = col * (icoSize + icoGap)
            local yOff = row * (icoSize + icoGap)
            if goRight then
                if growUp then
                    f:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", xOff, yOff)
                else
                    f:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", xOff, -yOff - titleH)
                end
            else
                if growUp then
                    f:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -xOff, yOff)
                else
                    f:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -xOff, -yOff - titleH)
                end
            end
        else
            -- ── Normal bar mode ──
            f:SetSize(db.frameWidth, barH)
            if i == 1 then
                if growUp then
                    f:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 0, 0)
                else
                    f:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -titleH)
                end
            else
                if growUp then
                    f:SetPoint("BOTTOMLEFT", prevFrame, "TOPLEFT", 0, barGap)
                else
                    f:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0, -barGap)
                end
            end
        end
        prevFrame = f
        f:EnableMouse(false)

        local iconRight = db.iconSide == "RIGHT"

        -- Icon
        local ico = f:CreateTexture(nil, "ARTWORK")
        if iconOnly then
            ico:SetAllPoints(f)
        elseif iconRight then
            -- Fixed square, BOTTOM-aligned with the bar so it shares the bar's
            -- lower edge and overhangs upward when larger (screenshot look).
            ico:SetSize(iconS, iconS)
            ico:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
        else
            ico:SetSize(iconS, iconS)
            ico:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
        end
        ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        f.icon = ico

        -- Icon background
        local iconBg = f:CreateTexture(nil, "BACKGROUND", nil, 0)
        if iconOnly then
            iconBg:SetAllPoints(f)
        elseif iconRight then
            iconBg:SetSize(iconS, iconS)
            iconBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
        else
            iconBg:SetSize(iconS, iconS)
            iconBg:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
        end
        iconBg:SetTexture(m.flatTexture)
        iconBg:SetVertexColor(0.1, 0.1, 0.1, 1)
        f.iconBg = iconBg

        -- Icon border frame
        local iconBorderFrame = CreateFrame("Frame", nil, f, "BackdropTemplate")
        if iconOnly then
            iconBorderFrame:SetAllPoints(f)
        elseif iconRight then
            iconBorderFrame:SetSize(iconS, iconS)
            iconBorderFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
        else
            iconBorderFrame:SetSize(iconS, iconS)
            iconBorderFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
        end
        iconBorderFrame:SetFrameLevel(f:GetFrameLevel() + 5)
        f.iconBorderFrame = iconBorderFrame

        -- Frame over the icon — carries the spell tooltip on hover.
        local iconBtn = CreateFrame("Button", nil, f)
        if iconOnly then
            iconBtn:SetAllPoints(f)
        elseif iconRight then
            iconBtn:SetSize(iconS, iconS)
            iconBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
        else
            iconBtn:SetSize(iconS, iconS)
            iconBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
        end
        iconBtn:SetFrameLevel(f:GetFrameLevel() + 10)
        iconBtn:EnableMouse(true)
        -- SetPropagateMouseClicks is protected in 11.x/12.x; defer if currently in combat
        if not InCombatLockdown() then
            iconBtn:SetPropagateMouseClicks(true)
        else
            BIT._pendingPropagate = BIT._pendingPropagate or {}
            BIT._pendingPropagate[#BIT._pendingPropagate+1] = iconBtn
        end
        f.iconBtn = iconBtn

        -- "Show Icon" off → the icon column collapsed to 0 in GetBarLayout.
        -- Hide the icon elements so no zero-width remnant lingers.
        if iconS == 0 then
            ico:Hide(); iconBg:Hide(); iconBorderFrame:Hide()
            iconBtn:Hide(); iconBtn:EnableMouse(false)
        end

        -- Spell tooltip on hover. Gated by BIT.db.interruptTooltip.
        -- Default-enabled: only an explicit `false` from the user toggle
        -- suppresses the tooltip; nil (e.g. fresh install before defaults
        -- have merged, or profile-switch transient state) means "show",
        -- matching the toggle getter's `~= false` semantics.
        --
        -- The captured `f` carries `f.spellID` (set by ApplyBar each tick)
        -- so the tooltip always reflects the bar's currently-tracked
        -- spell — for spec-overridden interrupts the ID will already
        -- point at the spec variant by the time the user mouses over.
        iconBtn:SetScript("OnEnter", function(self)
            if db and db.interruptTooltip == false then return end
            -- While the interrupt-feedback overlay is showing, the icon is the
            -- INTERRUPTED spell — show ITS tooltip. The interrupted spell ID is
            -- often a SECRET value in instances and can't drive a tooltip; in
            -- that case show NOTHING rather than the player's own kick (which
            -- wouldn't match the displayed enemy icon).
            if f._intActive then
                local isid
                local li = f._ownerName and BIT._lastInterrupt and BIT._lastInterrupt[f._ownerName]
                if li and li.spellID ~= nil then
                    local okSec, isSec = pcall(issecretvalue, li.spellID)
                    if okSec and not isSec then isid = li.spellID end
                end
                if not isid then return end  -- secret enemy spell → no tooltip
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if not pcall(GameTooltip.SetSpellByID, GameTooltip, isid) then
                    GameTooltip:Hide()
                    return
                end
                GameTooltip:Show()
                return
            end
            -- Normal: the icon is the player's own interrupt — show its tooltip.
            local sid = f.spellID
            if not sid then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if not pcall(GameTooltip.SetSpellByID, GameTooltip, sid) then
                GameTooltip:Hide()
                return
            end
            GameTooltip:Show()
        end)
        iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Bar background solid (fills bar area) — hidden in Icon Only mode
        local barBgSolid = f:CreateTexture(nil, "BACKGROUND", nil, -1)
        if iconOnly then
            barBgSolid:Hide()
        elseif iconRight then
            barBgSolid:SetPoint("TOPLEFT",     f, "TOPLEFT",    0,         0)
            barBgSolid:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",-barInset, 0)
        else
            barBgSolid:SetPoint("TOPLEFT",     f, "TOPLEFT",    barInset, 0)
            barBgSolid:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0,       0)
        end
        barBgSolid:SetTexture(m.flatTexture)
        barBgSolid:SetVertexColor(0, 0, 0, 1)
        f.barBgSolid = barBgSolid

        -- Textured bar background — hidden in Icon Only mode
        local barBg = f:CreateTexture(nil, "BACKGROUND", nil, 0)
        if iconOnly then
            barBg:Hide()
        elseif iconRight then
            barBg:SetPoint("TOPLEFT",     f, "TOPLEFT",    0,         0)
            barBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",-barInset, 0)
        else
            barBg:SetPoint("TOPLEFT",     f, "TOPLEFT",    barInset, 0)
            barBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0,       0)
        end
        m:SetBarTexture(barBg)
        barBg:SetVertexColor(0.15, 0.15, 0.15, 0.9)
        f.barBg = barBg

        -- StatusBar (CD progress) — hidden in Icon Only mode
        local sb = CreateFrame("StatusBar", nil, f)
        if iconOnly then
            sb:Hide()
        elseif iconRight then
            sb:SetPoint("TOPLEFT",     f, "TOPLEFT",    0,         0)
            sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",-barInset, 0)
        else
            sb:SetPoint("TOPLEFT",     f, "TOPLEFT",    barInset, 0)
            sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0,       0)
        end
        m:SetBarTexture(sb)
        sb:SetStatusBarColor(1, 1, 1, 0.85)
        sb:SetMinMaxValues(0, 1)
        sb:SetValue(0)
        sb:SetFrameLevel(f:GetFrameLevel() + 1)
        -- Remove the default NineSlice border WoW adds to StatusBar frames
        if sb.NineSlice then sb.NineSlice:SetAtlas("") sb.NineSlice:Hide() end
        if sb.BorderFrame then sb.BorderFrame:Hide() end
        -- Bar value is driven by UpdateDisplay (10x/s) — no OnUpdate needed
        sb._cdEnd  = 0
        sb._baseCd = 1
        f.cdBar = sb

        -- Content layer (text) — must be above border overlays
        local content = CreateFrame("Frame", nil, f)
        if iconOnly then
            content:SetAllPoints(f)
        elseif iconRight then
            content:SetPoint("TOPLEFT",     f, "TOPLEFT",    0,         0)
            content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",-barInset, 0)
        else
            content:SetPoint("TOPLEFT",     f, "TOPLEFT",    barInset, 0)
            content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0,       0)
        end
        content:SetFrameLevel(sb:GetFrameLevel() + 20)
        f.contentFrame = content

        -- Raid-target marker for the interrupt-feedback overlay, hung on the
        -- OUTER side of the icon (away from the bar): left of the icon when the
        -- icon is on the left, right of it when the icon is on the right. Drawn
        -- on the content frame (raised above the bar border). Hidden until
        -- ApplyBar swaps in an interrupted spell AND the mob carries a marker.
        -- The marker rides the icon (a small badge on the OUTER side, away
        -- from the bar). It only appears while the icon is shown — the
        -- "Show raid markers" toggle is hidden when Show Icon is off.
        local intMark = content:CreateTexture(nil, "OVERLAY", nil, 7)
        local markSize = math.max(10, math.floor((iconS > 0 and iconS or 20) * 0.9))
        intMark:SetSize(markSize, markSize)
        if iconRight then
            intMark:SetPoint("LEFT", ico, "RIGHT", 2, 0)
        else
            intMark:SetPoint("RIGHT", ico, "LEFT", -2, 0)
        end
        -- Use the raid-target sprite sheet so the (possibly secret) marker index
        -- can be shown via the C-side SetSpriteSheetCell without touching it in Lua.
        intMark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        intMark:Hide()
        f.intMark = intMark

        -- Name text — hidden in Icon Only mode
        local nm = content:CreateFontString(nil, "OVERLAY")
        m:SetFont(nm, fontSize)
        nm:SetPoint("LEFT", 6 + (db.nameOffsetX or 0), (db.nameOffsetY or 0))
        nm:SetJustifyH("LEFT")
        nm:SetWidth(db.showReady and (barW - 50) or (barW - 10))
        nm:SetWordWrap(false)
        nm:SetShadowOffset(db.shadowOffsetX or 0, db.shadowOffsetY or 0)
        if iconOnly then nm:Hide() end
        f.nameText      = nm
        f.nameShortW    = barW - 50   -- width when CD/READY text is shown
        f.nameFullW     = barW - 10   -- width when no CD/READY text

        -- Party CD text — hidden in Icon Only mode
        local pcd = content:CreateFontString(nil, "OVERLAY")
        m:SetFont(pcd, cdFontSize)
        pcd:SetPoint("RIGHT", -6 + (db.cdOffsetX or 0), (db.cdOffsetY or 0))
        pcd:SetShadowOffset(db.shadowOffsetX or 0, db.shadowOffsetY or 0)
        if iconOnly then pcd:Hide() end
        f.partyCdText = pcd

        -- Player CD wrapper (taint-safe) — propagates clicks to the frame for drag
        local wrap = CreateFrame("Frame", nil, content)
        wrap:SetAllPoints()
        wrap:SetFrameLevel(content:GetFrameLevel() + 1)
        wrap:EnableMouse(true)
        -- SetPropagateMouseClicks is protected in 11.x/12.x; defer if currently in combat
        if not InCombatLockdown() then
            wrap:SetPropagateMouseClicks(true)  -- pass unhandled clicks down to mainFrame for drag
        else
            BIT._pendingPropagate = BIT._pendingPropagate or {}
            BIT._pendingPropagate[#BIT._pendingPropagate+1] = wrap
        end
        f.barWrap = wrap
        local mycd = wrap:CreateFontString(nil, "OVERLAY")
        m:SetFont(mycd, cdFontSize)
        mycd:SetPoint("RIGHT", -6 + (db.cdOffsetX or 0), (db.cdOffsetY or 0))
        mycd:SetShadowOffset(db.shadowOffsetX or 0, db.shadowOffsetY or 0)
        if iconOnly then mycd:Hide() end
        f.playerCdWrapper = wrap
        f.playerCdText    = mycd

        -- Icon Only: CD countdown overlay centered on the icon
        if iconOnly then
            local icoCounterSize = db.iconOnlyCounterSize or 14
            -- Create on a high-level overlay frame so text draws above icon + border
            local cdOverlay = CreateFrame("Frame", nil, f)
            cdOverlay:SetAllPoints(f)
            cdOverlay:SetFrameLevel(f:GetFrameLevel() + 30)
            local icoCd = cdOverlay:CreateFontString(nil, "OVERLAY")
            m:SetFont(icoCd, icoCounterSize)
            icoCd:SetPoint("CENTER", f, "CENTER", 0, 0)
            icoCd:SetJustifyH("CENTER")
            icoCd:SetJustifyV("MIDDLE")
            icoCd:SetShadowOffset(1, -1)
            icoCd:SetTextColor(1, 1, 1)
            f.iconOnlyCdText = icoCd
        end

        -- Single outer border wraps the whole bar (icon + bar column).
        -- Icon and bar are treated as one unit; no separate icon border
        -- (see ApplyBorderToFrame where iconBorderOverlay is cleared).
        local borderOverlay = CreateFrame("Frame", nil, f, "BackdropTemplate")
        borderOverlay:SetAllPoints(f)
        borderOverlay:SetFrameLevel(sb:GetFrameLevel() + 10)
        borderOverlay:EnableMouse(false)
        f.borderOverlay = borderOverlay

        local iconBorderOverlay = CreateFrame("Frame", nil, f, "BackdropTemplate")
        if iconOnly then
            iconBorderOverlay:SetAllPoints(f)
        elseif iconRight then
            iconBorderOverlay:SetPoint("TOPLEFT",     f, "TOPRIGHT",    -iconS, 0)
            iconBorderOverlay:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  0,     0)
        else
            iconBorderOverlay:SetPoint("TOPLEFT",     f, "TOPLEFT",    0,     0)
            iconBorderOverlay:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", iconS, 0)
        end
        iconBorderOverlay:SetFrameLevel(sb:GetFrameLevel() + 11)
        iconBorderOverlay:EnableMouse(false)
        if iconS == 0 then iconBorderOverlay:Hide() end  -- "Show Icon" off
        f.iconBorderOverlay = iconBorderOverlay

        f:Hide()

        -- Rotation indicator: 2px vertical divider between icon and bar.
        -- "Show Icon" off (iconS == 0): there is no icon/bar seam — the
        -- straddling anchors would overhang the frame edge by 2px (and
        -- poke past the unit frame in attached-bars mode), so anchor the
        -- line fully INSIDE the bar as an edge marker instead.
        local rotLine = f:CreateTexture(nil, "OVERLAY")
        rotLine:SetWidth(5)
        if iconOnly then
            -- No rotation line in Icon Only mode
            rotLine:Hide()
        elseif iconRight then
            if iconS == 0 then
                rotLine:SetPoint("TOPLEFT",     f, "TOPRIGHT",    -5, 0)
                rotLine:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  0, 0)
            else
                rotLine:SetPoint("TOPLEFT",     f, "TOPRIGHT",    -iconS - 2, 0)
                rotLine:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -iconS + 3, 0)
            end
        else
            if iconS == 0 then
                rotLine:SetPoint("TOPLEFT",     f, "TOPLEFT",    0, 0)
                rotLine:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", 5, 0)
            else
                rotLine:SetPoint("TOPLEFT",     f, "TOPLEFT",    iconS - 2, 0)
                rotLine:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", iconS + 3, 0)
            end
        end
        rotLine:SetColorTexture(0, 1, 0, 1)
        rotLine:Hide()
        f.rotLine = rotLine

        -- Store layout geometry on the bar so ApplyBarContentInset can
        -- re-position the inner elements whenever the border style changes
        -- (without rebuilding the whole bar).
        f._iconS     = iconS
        f._barInset  = barInset   -- icon + horizontal gap; bar fill / seam inset
        f._iconRight = iconRight
        f._barH      = barH   -- bar height; border logic compares it to iconS

        bars[i] = f

        -- Apply border and reposition inner content with border-aware insets.
        -- ApplyBorderToFrame now cascades into ApplyBarContentInset internally.
        BIT.UI:ApplyBorderToFrame(f)
    end

    -- FrameLevel fixup: borders must draw above ALL bar base frames (including
    -- bars created after them), but below their own content/text frames.
    -- We raise all borderOverlays to a shared high base, then content above that.
    local highBase = mainFrame:GetFrameLevel() + 500
    for i = 1, 7 do
        local b = bars[i]
        if b then
            b.borderOverlay:SetFrameLevel(highBase)
            b.iconBorderOverlay:SetFrameLevel(highBase + 1)
            if b.contentFrame then
                b.contentFrame:SetFrameLevel(highBase + 10 + i)
                if b.playerCdWrapper then
                    b.playerCdWrapper:SetFrameLevel(highBase + 11 + i)
                end
            end
        end
    end

    BIT.UI:ApplyClickThrough()

    -- Immediately populate the newly created (hidden) bars so there is no
    -- render frame where all bars are invisible → eliminates flicker when
    -- changing settings that trigger a full rebuild.
    BIT.UI:UpdateDisplay()

    -- Keep Party CD Bars in sync with any structural setting change
    if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end

    -- The settings preview mirrors the live bar's look — refresh it after any
    -- rebuild so it always reflects the current configuration. Registered by
    -- the settings page; a no-op until then (and guarded to the page on-screen).
    if BIT.UI._previewRebuild then BIT.UI._previewRebuild() end
end

-- ────────────────────────────────────────────────────────────────────
-- Settings preview bar
-- A single, STATIC interrupt bar that mirrors the live tracker exactly —
-- same GetBarLayout() geometry, same media (texture/font), same colours,
-- and the same ApplyBorderToFrame() border path. Built only for the
-- settings "click a part to jump to its setting" preview; never registered
-- in the live `bars` pool, so it has zero effect on the real tracker. Part
-- handles are stamped on the returned frame (f.icon / f.nameText /
-- f.partyCdText / f.cdBar / f.intMark / f._previewTitle) for the click
-- overlays. NO frame here enables the mouse — the overlays own all clicks.
-- ────────────────────────────────────────────────────────────────────
function BIT.UI:BuildPreviewBar(parent)
    if not parent then return nil end
    local db = BIT.db
    local m  = BIT.Media
    if not db or not m then return nil end
    local barW, barH, iconS, fontSize, cdFontSize, titleH, barInset = GetBarLayout()
    local iconRight = db.iconSide == "RIGHT"

    -- The preview shows EVERY part even when its toggle is off — disabled
    -- parts are dimmed / desaturated (not hidden) so they stay visible and
    -- clickable as jump targets. Re-derive the icon column when Show Icon is
    -- off (GetBarLayout collapses it to 0) so the icon slot still renders.
    local iconHidden   = (db.showIcon == false)
    local titleHidden  = (db.showTitle == false)
    local nameHidden   = (db.showName == false)
    local markerHidden = (db.interruptShowMarker == false)
    if iconHidden then
        local cfg = db.interruptIconSize
        iconS    = (cfg and cfg > 0) and cfg or barH
        local g  = (db.interruptIconGap and db.interruptIconGap > 0) and db.interruptIconGap or 0
        barInset = iconS + g
        barW     = math.max(60, (db.frameWidth or 180) - barInset)
    end

    -- Resolve fill + background colours exactly like the live renderer
    -- (FillBarColor / FillBgColor): class colour when "Use class colors" is on,
    -- otherwise the cooldown colour for the fill and the neutral/custom bg.
    local classCol = (BIT.myClass and BIT.CLASS_COLORS and BIT.CLASS_COLORS[BIT.myClass]) or { 1, 1, 1 }
    local fillR, fillG, fillB
    if db.useClassColors then
        fillR, fillG, fillB = classCol[1], classCol[2], classCol[3]
    else
        fillR, fillG, fillB = db.cdBarColorR or 0.8, db.cdBarColorG or 0.2, db.cdBarColorB or 0.2
    end
    -- Ready-state fill (the live tracker's "off cooldown" look):
    -- class color, or the user's Ready Bar custom color — mirrors
    -- FillBarColor in the live renderer.
    local readyR, readyG, readyB
    if db.useClassColors then
        readyR, readyG, readyB = classCol[1], classCol[2], classCol[3]
    else
        readyR, readyG, readyB = db.customColorR or 0.4, db.customColorG or 0.8, db.customColorB or 1.0
    end
    local bgR, bgG, bgB, bgA
    if db.useCustomBgColor then
        bgR, bgG, bgB = db.customBgColorR or 0.1, db.customBgColorG or 0.1, db.customBgColorB or 0.1
        bgA = db.customBgColorA or 0.9
    elseif db.useClassColors then
        bgR, bgG, bgB = classCol[1] * 0.25, classCol[2] * 0.25, classCol[3] * 0.25
        bgA = 0.9
    else
        bgR, bgG, bgB = 0.1, 0.1, 0.1
        bgA = 0.9
    end

    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(db.frameWidth or 180, barH)
    f:EnableMouse(false)

    -- Icon: the player's own resolved interrupt (BIT.Self.spellID is
    -- spec-aware — Muzzle for Survival, Wind Shear for Resto, pet kicks
    -- etc.). Falls back to a sample kick texture for specs without an
    -- interrupt so the preview slot never renders empty.
    local ico = f:CreateTexture(nil, "ARTWORK")
    ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local icoTex
    if C_Spell and C_Spell.GetSpellTexture then
        local ownKick = BIT.Self and BIT.Self.spellID
        if ownKick then icoTex = C_Spell.GetSpellTexture(ownKick) end
        icoTex = icoTex or C_Spell.GetSpellTexture(1766)
    end
    ico:SetTexture(icoTex or "Interface\\Icons\\INV_Misc_QuestionMark")
    f.icon = ico

    local iconBg = f:CreateTexture(nil, "BACKGROUND", nil, 0)
    iconBg:SetTexture(m.flatTexture)
    iconBg:SetVertexColor(bgR * 0.7, bgG * 0.7, bgB * 0.7, 1)
    f.iconBg = iconBg

    local iconBorderFrame = CreateFrame("Frame", nil, f, "BackdropTemplate")
    iconBorderFrame:SetFrameLevel(f:GetFrameLevel() + 5)
    f.iconBorderFrame = iconBorderFrame

    local iconBtn = CreateFrame("Button", nil, f)
    iconBtn:SetFrameLevel(f:GetFrameLevel() + 10)
    iconBtn:EnableMouse(false)
    f.iconBtn = iconBtn

    -- Bar backgrounds: solid black under, textured grey over.
    local barBgSolid = f:CreateTexture(nil, "BACKGROUND", nil, -1)
    barBgSolid:SetTexture(m.flatTexture)
    barBgSolid:SetVertexColor(0, 0, 0, 1)
    f.barBgSolid = barBgSolid

    local barBg = f:CreateTexture(nil, "BACKGROUND", nil, 0)
    m:SetBarTexture(barBg)
    barBg:SetVertexColor(bgR, bgG, bgB, bgA)
    f.barBg = barBg

    -- Fill StatusBar — coloured like a cooldown in progress, ~60% full.
    local sb = CreateFrame("StatusBar", nil, f)
    m:SetBarTexture(sb)
    sb:SetMinMaxValues(0, 1)
    sb:SetValue(0.62)
    sb:SetFrameLevel(f:GetFrameLevel() + 1)
    if sb.NineSlice   then sb.NineSlice:SetAtlas(""); sb.NineSlice:Hide() end
    if sb.BorderFrame then sb.BorderFrame:Hide() end
    sb:SetStatusBarColor(fillR, fillG, fillB, 0.85)
    f.cdBar = sb

    local content = CreateFrame("Frame", nil, f)
    content:SetFrameLevel(sb:GetFrameLevel() + 20)
    f.contentFrame = content

    -- Raid-target marker (sample skull) on the icon's outer side.
    local intMark = content:CreateTexture(nil, "OVERLAY", nil, 7)
    local markSize = math.max(10, math.floor((iconS > 0 and iconS or 20) * 0.9))
    intMark:SetSize(markSize, markSize)
    if iconRight then
        intMark:SetPoint("LEFT", ico, "RIGHT", 2, 0)
    else
        intMark:SetPoint("RIGHT", ico, "LEFT", -2, 0)
    end
    intMark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    intMark:SetTexCoord(0.75, 1.0, 0.25, 0.5)   -- skull cell
    f.intMark = intMark
    if markerHidden or iconHidden then intMark:SetAlpha(0.4); intMark:SetDesaturated(true) end

    -- Name.
    local nm = content:CreateFontString(nil, "OVERLAY")
    m:SetFont(nm, fontSize)
    nm:SetPoint("LEFT", 6 + (db.nameOffsetX or 0), (db.nameOffsetY or 0))
    nm:SetJustifyH("LEFT")
    nm:SetWidth(db.showReady and (barW - 50) or (barW - 10))
    nm:SetWordWrap(false)
    nm:SetShadowOffset(db.shadowOffsetX or 0, db.shadowOffsetY or 0)
    if db.nameColorUseClass and BIT.myClass and BIT.CLASS_COLORS and BIT.CLASS_COLORS[BIT.myClass] then
        local c = BIT.CLASS_COLORS[BIT.myClass]
        nm:SetTextColor(c[1], c[2], c[3])
    else
        nm:SetTextColor(db.nameColorR or 1, db.nameColorG or 1, db.nameColorB or 1)
    end
    -- Use the same name resolver as the live own-bar so a set custom name
    -- (per-character or global, when enabled for the Interrupt feature) shows.
    local pname = BIT.myName or (UnitName and UnitName("player")) or "Player"
    nm:SetText((BIT.GetDisplayName and BIT.GetDisplayName(pname, "INTERRUPTS")) or pname)
    if nameHidden then nm:SetAlpha(0.3) end
    f.nameText = nm

    -- Cooldown number.
    local pcd = content:CreateFontString(nil, "OVERLAY")
    m:SetFont(pcd, cdFontSize)
    pcd:SetPoint("RIGHT", -6 + (db.cdOffsetX or 0), (db.cdOffsetY or 0))
    pcd:SetShadowOffset(db.shadowOffsetX or 0, db.shadowOffsetY or 0)
    pcd:SetTextColor(1, 1, 1)
    pcd:SetText("5")
    f.partyCdText = pcd

    -- Looping preview cycle: hold the READY state for 3s first (full
    -- bar in the ready color, no counter — exactly how the live
    -- tracker renders an off-cooldown kick), then play the countdown
    -- (bar drains / fills + counter ticks, the way test mode looks).
    -- Respects the configured Bar Fill Mode. The phase is persisted on
    -- the parent so a rebuild (live setting change) doesn't restart
    -- the cycle.
    local READY_HOLD = 3
    local fillMode = db.barFillMode or "DRAIN"
    f._animTotal   = db.interruptRecordDuration or 15   -- counter starts from the Interrupt history duration slider
    f._animElapsed = (parent and parent._animElapsed) or 0
    f:SetScript("OnUpdate", function(self, e)
        local cycle = READY_HOLD + self._animTotal
        local t = ((self._animElapsed or 0) + e) % cycle
        self._animElapsed = t
        if parent then parent._animElapsed = t end

        if t < READY_HOLD then
            -- Ready phase: paint once on entry, then idle. Mirrors the
            -- live renderer's ready state exactly: EMPTY status bar
            -- over the ready-tinted background, READY text (honoring
            -- the Show READY Text toggle) in the ready text color.
            if self._animPhase ~= "ready" then
                self._animPhase = "ready"
                if self.cdBar then self.cdBar:SetValue(0) end
                if self.barBg then
                    self.barBg:SetVertexColor(readyR, readyG, readyB, 0.85)
                end
                if self.partyCdText then
                    self.partyCdText:SetText(db.showReady and ((BIT.L and BIT.L["READY"]) or "READY") or "")
                    self.partyCdText:SetTextColor(
                        db.readyColorR or 0.2,
                        db.readyColorG or 1.0,
                        db.readyColorB or 0.2)
                end
            end
            return
        end

        if self._animPhase ~= "cd" then
            self._animPhase = "cd"
            if self.cdBar then
                self.cdBar:SetStatusBarColor(fillR, fillG, fillB, 0.85)
            end
            if self.barBg then
                self.barBg:SetVertexColor(bgR, bgG, bgB, bgA)
            end
            if self.partyCdText then
                self.partyCdText:SetTextColor(1, 1, 1)
            end
        end
        local tc = t - READY_HOLD
        local remain = self._animTotal - tc
        if self.cdBar then
            local frac = remain / self._animTotal
            self.cdBar:SetValue(fillMode == "FILL" and (1 - frac) or frac)
        end
        if self.partyCdText then self.partyCdText:SetText(tostring(math.ceil(remain))) end
    end)

    -- Border overlays (positioned + textured by the shared ApplyBorderToFrame).
    local borderOverlay = CreateFrame("Frame", nil, f, "BackdropTemplate")
    borderOverlay:SetAllPoints(f)
    borderOverlay:SetFrameLevel(sb:GetFrameLevel() + 10)
    borderOverlay:EnableMouse(false)
    f.borderOverlay = borderOverlay

    local iconBorderOverlay = CreateFrame("Frame", nil, f, "BackdropTemplate")
    iconBorderOverlay:SetFrameLevel(sb:GetFrameLevel() + 11)
    iconBorderOverlay:EnableMouse(false)
    f.iconBorderOverlay = iconBorderOverlay

    -- Window title above the bar.
    local title = f:CreateFontString(nil, "OVERLAY")
    local titleSize = (db.titleFontSize and db.titleFontSize > 0) and db.titleFontSize or 12
    m:SetFont(title, titleSize)
    title:SetTextColor(db.titleColorR or 0, db.titleColorG or 0.867, db.titleColorB or 0.867)
    title:SetText((BIT.L and BIT.L["TITLE_TEXT"]) or "Interrupts")
    local align  = db.titleAlign or "CENTER"
    local titleY = 3 + (db.titleOffsetY or 0)
    if align == "LEFT" then
        title:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, titleY)
    elseif align == "RIGHT" then
        title:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, titleY)
    else
        title:SetPoint("BOTTOM", f, "TOP", 0, titleY)
    end
    if titleHidden then title:SetAlpha(0.3) end
    f._previewTitle = title

    -- Geometry stamps so the shared border/inset path positions everything.
    f._iconS     = iconS
    f._barInset  = barInset
    f._iconRight = iconRight
    f._barH      = barH

    if iconHidden then
        ico:SetDesaturated(true); ico:SetAlpha(0.45); iconBg:SetAlpha(0.45)
    end

    BIT.UI:ApplyBorderToFrame(f)
    return f
end

------------------------------------------------------------
-- Click-through control
-- • db.locked = true  → whole frame is click-through (no drag, no interact)
------------------------------------------------------------
function BIT.UI:ApplyClickThrough()
    if not mainFrame then return end
    local db = BIT.db
    local locked    = db.locked or false
    -- Move-all mode (minimap right-click) temporarily overrides the lock
    -- so the window can be dragged; runtime flag only, the user's saved
    -- Lock Position setting is never touched.
    if BIT._moveAllUnlock then locked = false end

    -- mainFrame: needs mouse only when unlocked (for drag + pos editor click)
    mainFrame:EnableMouse(not locked)
    -- Re-assert SetMovable based on the current lock state so a profile
    -- switch from a locked profile to an unlocked one re-enables drag.
    mainFrame:SetMovable(not locked)

    for i = 1, 7 do
        local b = bars[i]
        if b then
            -- iconBtn: keep the mouse ENABLED so the spell tooltip still fires
            -- on hover (OnEnter). It isn't click-interactive, but clicks pass
            -- straight through to the frame via SetPropagateMouseClicks(true)
            -- (set at creation), so leaving the mouse on doesn't swallow drag
            -- clicks. Disabling it here was what stopped the tooltip showing.
            if b.iconBtn then
                b.iconBtn:EnableMouse(true)
            end
            -- barWrap: needs mouse only when frame is not locked
            -- (it propagates clicks to mainFrame for dragging)
            if b.barWrap then
                b.barWrap:EnableMouse(not locked)
            end
        end
    end

end

------------------------------------------------------------
-- Border helper
------------------------------------------------------------
local function ApplyBackdrop(f, path, size, r, g, b, a)
    if not f then return end
    if not path or path == "" then
        f:SetBackdrop(nil)
        return
    end
    f:SetBackdrop({
        edgeFile = path,
        edgeSize = size,
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    f:SetBackdropBorderColor(r, g, b, a)
end

-- The plain "Solid" border, set by the Border Texture dropdown.
local function _isSolidBorder()
    return BIT.db and BIT.db.borderTextureName == "Solid"
end

-- One physical pixel expressed in the frame's own coordinate units, so a
-- texture sized to N*onePixel renders as EXACTLY N physical pixels at any UI
-- scale (with pixel snapping off). This is the pixel-perfect trick quality UIs
-- use; it fixes SetBackdrop's uneven per-side edge rounding (bottom/right
-- losing a pixel at fractional scales — the reported bug).
local function _onePixel(frame)
    local _, physH = GetPhysicalScreenSize()
    if not physH or physH <= 0 then return 1 end
    local es = frame and frame:GetEffectiveScale() or 1
    if not es or es <= 0 then es = 1 end
    return (768 / physH) / es
end

-- Pixel-perfect SOLID border: four edge textures each explicitly sized to the
-- SAME physical thickness on every side, anchored INWARD from the overlay's
-- edges (matching the SetBackdrop edgeFile direction, so inward/outward/offset
-- positioning of the overlay is unchanged). Every edge spans the full side —
-- corners are double-drawn, which is invisible for an opaque colour (the normal
-- case) and avoids the inverted-rectangle glitch a corner inset would cause
-- when a large border meets a small icon.
local function ApplySolidEdges(overlay, size, r, g, b, a)
    if not overlay then return end
    if not overlay._ppEdges then
        local e = {}
        for _, k in ipairs({ "T", "B", "L", "R" }) do
            local tex = overlay:CreateTexture(nil, "OVERLAY")
            if tex.SetSnapToPixelGrid then tex:SetSnapToPixelGrid(false); tex:SetTexelSnappingBias(0) end
            e[k] = tex
        end
        overlay._ppEdges = e
    end
    local e    = overlay._ppEdges
    local px   = _onePixel(overlay)
    local edge = math.max(px, math.floor((size or 1) + 0.5) * px)
    e.T:ClearAllPoints(); e.T:SetPoint("TOPLEFT",    overlay, "TOPLEFT",    0, 0); e.T:SetPoint("TOPRIGHT",    overlay, "TOPRIGHT",    0, 0); e.T:SetHeight(edge)
    e.B:ClearAllPoints(); e.B:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT", 0, 0); e.B:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0); e.B:SetHeight(edge)
    e.L:ClearAllPoints(); e.L:SetPoint("TOPLEFT",    overlay, "TOPLEFT",    0, 0); e.L:SetPoint("BOTTOMLEFT",  overlay, "BOTTOMLEFT",  0, 0); e.L:SetWidth(edge)
    e.R:ClearAllPoints(); e.R:SetPoint("TOPRIGHT",   overlay, "TOPRIGHT",   0, 0); e.R:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0); e.R:SetWidth(edge)
    for _, k in ipairs({ "T", "B", "L", "R" }) do e[k]:SetColorTexture(r, g, b, a); e[k]:Show() end
end

local function HideSolidEdges(overlay)
    if overlay and overlay._ppEdges then
        for _, k in ipairs({ "T", "B", "L", "R" }) do overlay._ppEdges[k]:Hide() end
    end
end

-- Border dispatch: "Solid" → pixel-perfect edges (uniform on all sides);
-- decorative texture → Blizzard edgeFile backdrop (its per-side rounding is a
-- client limitation, and ornate 8-piece textures can't be drawn as 4 lines);
-- None → nothing.
local function ApplyBorderTexture(overlay, path, size, r, g, b, a)
    if not overlay then return end
    if not path or path == "" then
        HideSolidEdges(overlay)
        ApplyBackdrop(overlay, nil, 0, 0, 0, 0, 0)
    elseif _isSolidBorder() then
        ApplyBackdrop(overlay, nil, 0, 0, 0, 0, 0)   -- no edgeFile beneath the edges
        ApplySolidEdges(overlay, size, r, g, b, a)
    else
        HideSolidEdges(overlay)
        ApplyBackdrop(overlay, path, size, r, g, b, a)
    end
end

function BIT.UI:ApplyBorderToFrame(f)
    if not f then return end
    local db   = BIT.db
    local path = db.borderTexturePath
    local size = db.borderSize or 12
    local r    = db.borderColorR or 1
    local g    = db.borderColorG or 1
    local b    = db.borderColorB or 1
    local a    = db.borderColorA or 1
    -- The slider directly controls how far the border extends. Decorative
    -- textures may smear at very small sizes, but the user can simply pick
    -- a larger size — we don't silently override the slider anymore, since
    -- that made the visual footprint around the bar feel bloated.

    -- Draw the border strictly OUTSIDE the bar. Blizzard's backdrop
    -- edgeFile is drawn inward from the backdrop frame's own edges,
    -- so we expand the overlay outward by (size + offset). The "+size"
    -- part is mandatory just to push the rim to the bar's edge; the
    -- "+offset" part is user-controlled and decoupled from the texture
    -- thickness, so users can keep a thick border close to the bar or
    -- a thin border far away.
    local offset = db.borderOffset or 0
    -- Inward mode (db.borderInward): the OUTER edge stays fixed at the frame
    -- (+offset) and the edgeSize border draws inward from there, so raising
    -- Border Size grows the rim toward the centre and simply LAYS OVER the
    -- bar's edge — the bar and icon keep their full size and position (the
    -- overlay draws above the bar texture but below the text). Outward mode
    -- (default): expand the overlay out by size+offset so the whole border
    -- sits outside the bar.
    local inward  = db.borderInward
    local outward = inward and math.max(0, offset) or math.max(0, size + offset)
    -- Detached icon: when the icon has an independent size (it overhangs the
    -- bar) or a gap, bar and icon can't share one rectangle, so the bar border
    -- wraps the BAR COLUMN and the icon gets its own border. Each box is
    -- bordered as a STANDALONE rectangle — all four sides (including the seam
    -- side facing the other box) extend outward by `outward`, so the border
    -- size/offset sliders grow every edge uniformly. With a small/zero gap the
    -- two boxes' seam borders overlap (reads as one shared border); a larger
    -- Icon Gap separates them. When the icon matches the bar height (Auto) and
    -- there's no gap, keep the classic single unified border.
    local iconRight = f._iconRight
    local barInset  = f._barInset or f._iconS
    -- Detached whenever the icon can't share the bar's rectangle: a different
    -- height (overhang) OR a horizontal gap between icon and bar.
    local detached  = f._iconS and f._barH and f._iconS > 0
        and (f._iconS ~= f._barH or (barInset and barInset ~= f._iconS))

    local bo = f.borderOverlay
    if bo then
        bo:ClearAllPoints()
        if path and path ~= "" then
            if detached and iconRight then
                -- bar column on the LEFT; seam edge is the RIGHT.
                bo:SetPoint("TOPLEFT",     f, "TOPLEFT",     -outward,            outward)
                bo:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -barInset + outward, -outward)
            elseif detached then
                -- bar column on the RIGHT; seam edge is the LEFT.
                bo:SetPoint("TOPLEFT",     f, "TOPLEFT",      barInset - outward,  outward)
                bo:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  outward,            -outward)
            else
                bo:SetPoint("TOPLEFT",     f, "TOPLEFT",     -outward,  outward)
                bo:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  outward, -outward)
            end
        else
            bo:SetAllPoints(f)
        end
    end
    ApplyBorderTexture(bo, path, size, r, g, b, a)

    -- Icon border: a separate border around the (possibly overhanging) icon,
    -- only when detached AND a border texture is set. Each box (icon + bar)
    -- is bordered as a standalone rectangle so size/offset grow every edge.
    if f.iconBorderOverlay then
        if detached and f.icon and path and path ~= "" then
            local io = f.iconBorderOverlay
            io:ClearAllPoints()
            io:SetPoint("TOPLEFT",     f.icon, "TOPLEFT",     -outward,  outward)
            io:SetPoint("BOTTOMRIGHT", f.icon, "BOTTOMRIGHT",  outward, -outward)
            ApplyBorderTexture(io, path, size, r, g, b, a)
        else
            ApplyBorderTexture(f.iconBorderOverlay, nil, 0, 0, 0, 0, 0)
        end
    end

    -- Content stays flush in BOTH modes (effective size 0): the bar and icon
    -- keep their full size and position, and the inward-drawn border simply
    -- LAYS OVER the bar's outer edge (the border overlay draws above the bar
    -- textures but below the text, so the rim overlaps the bar while numbers
    -- stay readable). No inset — raising Border Size must not shrink the bar
    -- or shift the icon.
    f._effectiveBorderSize = 0
    if f._iconS and BIT.UI.ApplyBarContentInset then
        BIT.UI:ApplyBarContentInset(f)
    end
end

-- Pull the bar's inner elements away from the outer border edges so a
-- border with rounded corners has visual breathing room.
-- Both icon and bar columns are inset on the outer edges; only the seam
-- between them (at `iconS`) stays flush because that's a straight line
-- inside the border, no rounded-corner concerns.
-- Called at bar creation and again whenever the border style changes.
function BIT.UI:ApplyBarContentInset(bar)
    local db = BIT.db
    local iconS     = bar._iconS              -- icon square size
    local barInset  = bar._barInset or iconS  -- icon + horizontal gap
    local iconRight = bar._iconRight
    if not iconS then return end
    -- Border is drawn outside the frame (see ApplyBorderToFrame), so
    -- content can extend flush to f's edges — no inset needed. The
    -- effective-size field stamped by ApplyBorderToFrame is zero in
    -- this mode; use it directly for future-proof compatibility if we
    -- ever switch back to an inward-drawn border.
    local I = bar._effectiveBorderSize or 0

    -- Icon is a fixed square, BOTTOM-aligned with the bar so it shares the
    -- bar's lower edge and overhangs UPWARD when its size exceeds the bar
    -- height (the independent Icon Size setting). `I` is 0 in the
    -- outside-the-frame border mode; kept for forward-compat with an inward
    -- border.
    local function setCol(w)
        if not w then return end
        w:ClearAllPoints()
        w:SetSize(iconS, iconS)
        if iconRight then
            w:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -I, I)
        else
            w:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", I, I)
        end
    end
    local function setBar(w)
        if not w then return end
        w:ClearAllPoints()
        if iconRight then
            -- bar on the left — outer side is left, inner seam (icon + gap) right
            w:SetPoint("TOPLEFT",     bar, "TOPLEFT",      I,         -I)
            w:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -barInset,   I)
        else
            -- bar on the right — outer side is right, inner seam (icon + gap) left
            w:SetPoint("TOPLEFT",     bar, "TOPLEFT",      barInset,  -I)
            w:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -I,          I)
        end
    end
    setCol(bar.icon)
    setCol(bar.iconBg)
    setCol(bar.iconBorderFrame)
    setCol(bar.iconBtn)
    setBar(bar.barBgSolid)
    setBar(bar.barBg)
    setBar(bar.cdBar)
    setBar(bar.contentFrame)
end

function BIT.UI:ApplyBorderToAll()
    for i = 1, 7 do
        if bars[i] then
            self:ApplyBorderToFrame(bars[i])
        end
    end
    -- Keep attached interrupt icons in sync with border-style changes.
    -- _aiFrames is declared later in this file; guarded so load-order
    -- quirks don't break this call if the module isn't ready yet.
    if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts._ApplyBorderToAll then
        BIT.UI.AttachedInterrupts:_ApplyBorderToAll()
    end
end

-- Re-snap the pixel-perfect solid borders when the UI scale or resolution
-- changes: their per-side thickness is computed in physical pixels, so it must
-- be recomputed when the scale that maps UI units to pixels moves. Decorative
-- edgeFile borders are unaffected by the re-run (harmless no-op for them).
do
    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("UI_SCALE_CHANGED")
    watcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
    watcher:SetScript("OnEvent", function()
        if BIT.UI and BIT.UI.ApplyBorderToAll then BIT.UI:ApplyBorderToAll() end
    end)
end

------------------------------------------------------------
-- Display update (called every 0.1s)
------------------------------------------------------------

-- Match a bar by its owner name. Prefers the explicit _ownerName we stamp
-- during ShowBar (raw character name), falls back to the display-stripped
-- _lastName for forward-compat. Without this we'd miss the own bar whenever
-- the player has a custom display name set (own name differs from UnitName).
local function MatchBarByOwner(bar, playerName)
    if not bar then return false end
    if bar._ownerName then
        return bar._ownerName == playerName
    end
    if not bar._lastName then return false end
    local stripped = bar._lastName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    return stripped == playerName
end

-- hide CD text while waiting for kick outcome
function BIT.UI:SetPendingKickColor(playerName)
    for i = 1, 7 do
        local bar = bars[i]
        if MatchBarByOwner(bar, playerName) then
            bar._failedKick   = false
            bar._successKick  = false
            bar._pendingColor = true
            break
        end
    end
end
function BIT.UI:FlashFailedKick(playerName)
    if BIT.SUPPRESS_FAILKICK then return end  -- optional kill-switch (see Core.lua); off by default
    if not BIT.db.showFailedKick then return end
    for i = 1, 7 do
        local bar = bars[i]
        if MatchBarByOwner(bar, playerName) then
            bar._failedKick   = true
            bar._successKick  = false
            bar._pendingColor = false
            break
        end
    end
    if BIT.db.soundEnabled and (not BIT.db.soundOwnKickOnly or playerName == BIT.myName) then
        BIT.Media:PlayKickSound(BIT.db.soundKickFailed)
    end
end

-- mark own bar green on successful interrupt
function BIT.UI:MarkSuccessKick(playerName)
    if not BIT.db.showFailedKick then return end
    for i = 1, 7 do
        local bar = bars[i]
        if MatchBarByOwner(bar, playerName) then
            bar._successKick  = true
            bar._failedKick   = false
            bar._pendingColor = false
            break
        end
    end
    if BIT.db.soundEnabled and (not BIT.db.soundOwnKickOnly or playerName == BIT.myName) then
        BIT.Media:PlayKickSound(BIT.db.soundKickSuccess)
    end
end

local _col = {0, 0, 0}
local _bg  = {0, 0, 0}

-- Rotation lookup: name → position index, rebuilt when rotation changes
local _rotOrderOf    = {}
local _rotOrderDirty = true
function BIT.UI:MarkRotationDirty() _rotOrderDirty = true end

-- Reusable party sort tables
local _sortedParty       = {}
local _restoShamanEntries = {}

-- ── Hot-path helper: spell-CD remaining time, taint-safe ──────────────
-- ApplyBar runs per visible bar, every 10Hz tick. The previous code did
-- `pcall(function() ... end)` inline, which allocated a fresh closure
-- (and a new upvalue table referencing `spellID` + `now`) every call —
-- 50+ allocations per second of GC pressure for nothing. Hoisting the
-- function to file scope and calling `pcall(fn, args)` instead reuses
-- one shared function reference and passes the values as plain stack
-- args. Behaviour is byte-for-byte identical: the wrapped body still
-- runs inside pcall's protected mode so a tainted secret value in
-- cdInfo.duration / startTime can't leak out.
local function _SpellCdRemaining(spellID, nowTs)
    local cdInfo = C_Spell.GetSpellCooldown(spellID)
    if cdInfo and cdInfo.startTime and cdInfo.duration and cdInfo.duration > 0 then
        local r = (cdInfo.startTime + cdInfo.duration) - nowTs
        return r > 0 and r or nil
    end
end

-- ── Attached Bars mode ─────────────────────────────────────────────
-- ATTACHED_BARS display mode: each party member's full interrupt bar is
-- anchored to that member's unit frame (icon + name + CD + texture),
-- width matched to the frame. Re-anchored every tick because unit frames
-- can move / re-layout on roster changes. Bars whose frame can't be
-- resolved (member off-screen, provider hidden) hide themselves.
-- Each entry pins BOTH the bar's left and right edges to the frame's
-- corresponding corners, so the bar width tracks the unit frame exactly
-- (pixel-perfect — no GetWidth/SetWidth rounding that left a 1px overhang
-- on each side). Vertical extent stays at the bar's own height (barH).
--   lp/lrp = left  point + relative point   (match-width: pin both edges)
--   rp/rrp = right point + relative point
--   cp/crp = single center point            (fixed-width: one anchor + SetWidth)
--   gap    = baseline vertical gap from the frame edge
local ATTACH_BAR_POS = {
    TOP     = { lp = "BOTTOMLEFT", lrp = "TOPLEFT",    rp = "BOTTOMRIGHT", rrp = "TOPRIGHT",    cp = "BOTTOM", crp = "TOP",    gap =  2 },
    BOTTOM  = { lp = "TOPLEFT",    lrp = "BOTTOMLEFT", rp = "TOPRIGHT",    rrp = "BOTTOMRIGHT", cp = "TOP",    crp = "BOTTOM", gap = -2 },
    OVERLAY = { lp = "LEFT",       lrp = "LEFT",       rp = "RIGHT",       rrp = "RIGHT",       cp = "CENTER", crp = "CENTER", gap =  0 },
}


-- Resolve the unit token for a bar owner name (bar._ownerName). Compares
-- on the realm-stripped base name since owner keys may carry a "-Realm"
-- suffix while UnitName returns the short name.
local function _stripRealm(n) return n and n:match("^([^%-]+)") or n end
local function _UnitForOwner(name)
    if not name then return nil end
    if name == BIT.myName then return "player" end
    local base = _stripRealm(name)
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then
            local n = UnitName(u)
            if n and (n == name or _stripRealm(n) == base) then return u end
        end
    end
    return nil
end

-- The bar's 1px border is drawn just OUTSIDE the bar's frame rect, so
-- pinning the frame edges flush to the unit frame leaves the border
-- overhanging by 1px on each side. Inset both edges by the border width
-- so the visible border lines up with the unit frame edge.
local ATTACH_BAR_BORDER_INSET = 1

local _STRATA = { "BACKGROUND","LOW","MEDIUM","HIGH","DIALOG","FULLSCREEN","FULLSCREEN_DIALOG","TOOLTIP" }
local _STRATA_IDX = {}
for _i, _s in ipairs(_STRATA) do _STRATA_IDX[_s] = _i end
local function _strataOneBelow(s)
    local i = _STRATA_IDX[s] or 3  -- default MEDIUM
    return _STRATA[math.max(1, i - 1)]
end

local function _LayoutAttachedBars(numVisible)
    local db       = BIT.db
    local provider = db.interruptAttachFrameProvider or "AUTO"
    local posKey   = db.interruptAttachBarPos or "TOP"
    local pos      = ATTACH_BAR_POS[posKey] or ATTACH_BAR_POS.TOP
    local ox       = db.interruptAttachOffsetX or 0
    local oy       = (db.interruptAttachOffsetY or 0) + pos.gap
    local inset    = ATTACH_BAR_BORDER_INSET
    for i = 1, numVisible do
        local bar = bars[i]
        if bar and bar:IsShown() then
            local unit  = _UnitForOwner(bar._ownerName)
            local frame = unit and BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame
                          and BIT.UnitFrames:GetPartyFrame(unit, provider) or nil
            if frame then
                bar:ClearAllPoints()
                if db.interruptAttachBarMatchWidth ~= false then
                    -- Match unit frame width: pin both edges to the frame's
                    -- corners. Left edge +inset, right edge -inset so the
                    -- bar's outer 1px border sits flush with the frame, not
                    -- 1px beyond it. offsetX shifts without resizing.
                    bar:SetPoint(pos.lp, frame, pos.lrp, ox + inset, oy)
                    bar:SetPoint(pos.rp, frame, pos.rrp, ox - inset, oy)
                else
                    -- Fixed custom width: single centered anchor + SetWidth.
                    bar:SetPoint(pos.cp, frame, pos.crp, ox, oy)
                    bar:SetWidth(db.interruptAttachBarWidth or 120)
                end
                -- Strata: the user's Frame Layer setting governs the bar's
                -- layer here too. An EXPLICIT pick (anything other than the
                -- default MEDIUM) is applied directly. Left at the default
                -- MEDIUM it falls back to AUTO: sit one strata below the
                -- unit frame so the bar's border doesn't cover the frame's
                -- name (OVERLAY matches the frame instead). This keeps the
                -- border-behind-name behaviour for everyone who never opens
                -- the setting, while giving explicit control when wanted.
                local userStrata = BIT.db and BIT.db.interruptFrameStrata
                if userStrata and userStrata ~= "MEDIUM" and _STRATA_IDX[userStrata] then
                    bar:SetFrameStrata(userStrata)
                else
                    local okS, fs = pcall(frame.GetFrameStrata, frame)
                    local base = (okS and fs) or "MEDIUM"
                    bar:SetFrameStrata(posKey == "OVERLAY" and base or _strataOneBelow(base))
                end
                bar:Show()
            else
                bar:Hide()
            end
        end
    end
end

function BIT.UI:UpdateDisplay()
    if not BIT.ready then return end
    if BIT.Interrupts and not BIT.Interrupts:IsEnabled() then return end
    -- Test mode bypasses the per-zone gate so the user can preview bars
    -- regardless of the "Show in Open World / Dungeon / Raid / ..."
    -- toggles. CheckZoneVisibility above already defends this, but the
    -- belt-and-braces check here means any direct mutation of
    -- shouldShowByZone during a test still ticks the bars.
    if not (shouldShowByZone or BIT.testMode) then return end
    if BIT.db.hideOutOfCombat and not BIT.inCombat and not BIT.testMode then return end

    -- Attached-icon mode runs on every tick and early-outs when disabled.
    -- It's independent of the bar rendering below.
    if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Tick then
        BIT.UI.AttachedInterrupts:Tick()
    end

    local db  = BIT.db
    local now = GetTime()

    -- Free Anchor: re-apply each tick so the window snaps onto its picked
    -- target as soon as that frame exists (e.g. another addon loaded later)
    -- and re-pins if the anchor was cleared (cheap — a single SetPoint).
    if db.interruptFreeAnchor and BIT.UI.ApplyFramePosition then
        BIT.UI.ApplyFramePosition()
    end

    local _, barH, _, _, _, titleH = GetBarLayout()
    if IsIconOnlyMode() then titleH = 0 end
    local barIdx = 1

    -- Rebuild rotation lookup table only when dirty
    if _rotOrderDirty then
        wipe(_rotOrderOf)
        for i, nm in ipairs(BIT.rotationOrder) do
            _rotOrderOf[nm] = i
        end
        _rotOrderDirty = false
    end

    -- Helper: fill _col with bar color (no table allocation)
    local function FillBarColor(class)
        if db.useClassColors then
            local c = BIT.CLASS_COLORS[class] or { 1, 1, 1 }
            _col[1] = c[1]; _col[2] = c[2]; _col[3] = c[3]
        else
            _col[1] = db.customColorR or 0.4
            _col[2] = db.customColorG or 0.8
            _col[3] = db.customColorB or 1.0
        end
    end

    -- Helper: fill _bg with background color (no table allocation).
    -- Resolution order:
    --   1) Use Custom Background Color toggle on → custom RGB wins
    --      (works in both class-color and plain-color modes).
    --   2) Class colors on  → darker shade of the player's class color.
    --   3) Otherwise        → the standard neutral dark default.
    -- _bg[4] carries the background OPACITY. Only the explicit custom
    -- color honors the user's alpha slider; the class-shade and neutral
    -- fallbacks keep the standard 0.9 so their look is unchanged.
    local function FillBgColor(class)
        if db.useCustomBgColor then
            _bg[1] = db.customBgColorR or 0.1
            _bg[2] = db.customBgColorG or 0.1
            _bg[3] = db.customBgColorB or 0.1
            _bg[4] = db.customBgColorA or 0.9
        elseif db.useClassColors then
            local c = BIT.CLASS_COLORS[class] or { 1, 1, 1 }
            _bg[1] = c[1] * 0.25; _bg[2] = c[2] * 0.25; _bg[3] = c[3] * 0.25
            _bg[4] = 0.9
        else
            _bg[1] = 0.1
            _bg[2] = 0.1
            _bg[3] = 0.1
            _bg[4] = 0.9
        end
    end

    -- Kick Rotation feature removed: the rotation indicator never shows.
    local function ApplyRotBorder(bar, playerName)
        if bar.rotLine then bar.rotLine:Hide() end
    end

    -- Interrupt feedback overlay: while a tracked player is on interrupt CD
    -- because they just kicked, swap their ability icon for the icon of the
    -- spell they interrupted and badge it with the kicked mob's raid-target
    -- marker. Reverts to the ability icon once the CD expires. Standalone
    -- window only (display mode "BARS", icon column visible).
    local function ApplyInterruptVisual(bar)
        local store = BIT._lastInterrupt
        local owner = bar._ownerName
        local active
        if store and owner and (db.interruptDisplayMode or "BARS") == "BARS"
           and (bar._iconS or 0) > 0 and bar.cdEnd and bar.cdEnd > now then
            local li = store[owner]
            -- li.icon may be a SECRET value (enemy spell texture): test only with
            -- `~= nil` (secret-safe), never with plain truthiness or equality.
            if li and (li.icon ~= nil or li.mark ~= nil) then
                local exp = li.expireAt
                -- exp is a locally-modeled CD end (clean), but guard against a
                -- secret value so the comparison can never taint the frame.
                if type(exp) == "number"
                   and not (type(issecretvalue) == "function" and issecretvalue(exp))
                   and now < exp then
                    active = li
                end
            end
        end

        if active then
            -- Set once on the transition into the interrupt state. The texture
            -- may be secret, so we must NOT compare it — the _intActive flag is
            -- the gate, and SetTexture is wrapped in pcall (a secret texture can
            -- be displayed, just not used in logic).
            if not bar._intActive then
                if active.icon ~= nil then
                    pcall(bar.icon.SetTexture, bar.icon, active.icon)
                    bar.icon:SetDesaturated(false)
                    bar.icon:SetAlpha(1)
                    bar._lastIcon = nil  -- invalidate so ShowBar restores the ability icon
                end
                -- active.mark may be a SECRET value: never compare it, just feed
                -- it to the C-side SetSpriteSheetCell (4x4 raid-icon sheet), which
                -- accepts a secret cell index. Re-assert the sheet texture
                -- first, and show only if the call works.
                if bar.intMark and active.mark ~= nil and db.interruptShowMarker ~= false then
                    bar.intMark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                    local okMk = pcall(bar.intMark.SetSpriteSheetCell, bar.intMark, active.mark, 4, 4)
                    if okMk then bar.intMark:Show() else bar.intMark:Hide() end
                elseif bar.intMark then
                    bar.intMark:Hide()
                end
                bar._intActive = true
            end
        elseif bar._intActive then
            if bar._abilityIcon then
                pcall(bar.icon.SetTexture, bar.icon, bar._abilityIcon)
                bar._lastIcon = bar._abilityIcon
            end
            if bar.intMark then bar.intMark:Hide() end
            bar._intActive = false
        end
    end

    local function ApplyBar(bar, cdEnd, baseCd, isPetSpell, spellID)
        bar.spellID = spellID
        bar.cdEnd   = cdEnd
        FillBgColor(bar._class)

        if cdEnd > now then
            local rem = cdEnd - now
            -- duration can be a tainted secret value, so pcall is needed here.
            -- Call the hoisted file-level helper via pcall(fn, args) — that
            -- form passes the args on the stack with no closure allocation,
            -- whereas pcall(function() ... end) inline would build a new
            -- closure object every call (this path runs ~50x/sec).
            if isPetSpell == false and spellID then
                local ok, apiRem = pcall(_SpellCdRemaining, spellID, now)
                if ok and apiRem then rem = apiRem end
            end

            local sec = math.floor(rem + 0.5)

            if iconOnly then
                -- Icon Only mode: show CD countdown centered on icon, desaturate icon
                if bar._lastCdSec ~= sec and bar.iconOnlyCdText then
                    bar._lastCdSec = sec
                    bar.iconOnlyCdText:SetText(sec > 0 and tostring(sec) or "")
                end
                if bar.iconOnlyCdText then
                    bar.iconOnlyCdText:SetTextColor(1, 1, 1)
                    bar.iconOnlyCdText:Show()
                end
                bar.icon:SetDesaturated(true)
                bar.icon:SetAlpha(0.6)
            else
                -- Only update CD text when the displayed second changes
                if bar._lastCdSec ~= sec then
                    bar._lastCdSec = sec
                    bar.playerCdText:SetText(sec > 0 and tostring(sec) or "")
                end
                -- hide text while waiting for kick outcome, show with correct color once known
                local pending = bar._pendingColor
                if pending then
                    bar.playerCdText:Hide()
                else
                    if bar._failedKick then
                        bar.playerCdText:SetTextColor(1, 0.1, 0.1)
                    elseif bar._successKick then
                        bar.playerCdText:SetTextColor(0.1, 1, 0.1)
                    else
                        bar.playerCdText:SetTextColor(1, 1, 1)
                    end
                    bar.playerCdText:Show()
                end
                if not bar._cdVisible then
                    bar.partyCdText:Hide()
                    bar._cdVisible = true
                    if bar.nameText and bar.nameShortW then
                        bar.nameText:SetWidth(bar.nameShortW)
                    end
                end

                -- Update bar value directly (was OnUpdate before)
                if baseCd > 0 then
                    local val = (db.barFillMode == "FILL") and (baseCd - rem) or rem
                    bar.cdBar:SetMinMaxValues(0, baseCd)
                    bar.cdBar:SetValue(val < 0 and 0 or val)
                end
                local cdR, cdG, cdB
                if db.useClassColors then
                    cdR, cdG, cdB = _col[1], _col[2], _col[3]
                else
                    cdR = db.cdBarColorR or 0.8
                    cdG = db.cdBarColorG or 0.2
                    cdB = db.cdBarColorB or 0.2
                    if db.cdBarFade and baseCd > 0 then
                        -- t=1 → full CD (cd color), t=0 → almost ready (ready color)
                        local t = rem / baseCd
                        if t > 1 then t = 1 elseif t < 0 then t = 0 end
                        cdR = _col[1] + (cdR - _col[1]) * t
                        cdG = _col[2] + (cdG - _col[2]) * t
                        cdB = _col[3] + (cdB - _col[3]) * t
                    end
                end
                bar.cdBar:SetStatusBarColor(cdR, cdG, cdB, 0.85)
                bar.barBg:SetVertexColor(_bg[1], _bg[2], _bg[3], _bg[4] or 0.9)
                if bar.iconBg then bar.iconBg:SetVertexColor(_bg[1]*0.7, _bg[2]*0.7, _bg[3]*0.7, 1) end
                bar.playerCdWrapper:SetAlpha(1)
            end
        else
            if iconOnly then
                -- Icon Only mode: ready state — full color icon, no text
                if bar.iconOnlyCdText then
                    bar.iconOnlyCdText:SetText("")
                    bar.iconOnlyCdText:Hide()
                end
                bar.icon:SetDesaturated(false)
                bar.icon:SetAlpha(1)
                bar._cdVisible    = false
                bar._lastCdSec    = nil
            else
                if bar._cdVisible ~= false then
                    -- state just changed to ready
                    bar.playerCdText:Hide()
                    bar.partyCdText:Show()
                    if bar.nameText then
                        bar.nameText:SetWidth(db.showReady and bar.nameShortW or bar.nameFullW)
                    end
                    bar.cdBar:SetMinMaxValues(0, 1)
                    bar.cdBar:SetValue(0)
                    bar._cdVisible    = false
                    bar._lastCdSec    = nil
                    bar._lastCdEnd    = nil
                    bar._failedKick   = false
                    bar._successKick  = false
                    bar._pendingColor = false
                end
                -- always update color/text so settings changes apply immediately
                bar.partyCdText:SetText(db.showReady and BIT.L["READY"] or "")
                bar.partyCdText:SetTextColor(
                    db.readyColorR or 0.2,
                    db.readyColorG or 1.0,
                    db.readyColorB or 0.2)
                bar.playerCdWrapper:SetAlpha(1)
                bar.barBg:SetVertexColor(_col[1], _col[2], _col[3], 0.85)
            end
        end
        ApplyInterruptVisual(bar)
    end

    local iconOnly = IsIconOnlyMode()

    local function ShowBar(bar, icon, nameStr, class, cdEnd, baseCd, isPetSpell, spellID, ownerName)
        bar:Show()
        bar._class      = class
        bar._ownerName  = ownerName  -- raw character name for FlashFailedKick/MarkSuccessKick matching
        -- Remember the spec ability icon so ApplyInterruptVisual can restore it
        -- after a temporary interrupted-spell swap. While a swap is active, don't
        -- overwrite the displayed texture here — the overlay owns it each tick.
        bar._abilityIcon = icon
        if not bar._intActive and bar._lastIcon ~= icon then
            bar.icon:SetTexture(icon)
            bar._lastIcon = icon
        end
        bar.icon:SetDesaturated(false)
        bar.icon:SetAlpha(1)
        local nameChanged = (bar._lastName ~= nameStr)
        bar._lastName = nameStr
        if iconOnly then
            -- Icon Only mode: hide bar elements, show icon + CD overlay
            bar.nameText:Hide()
            bar.partyCdText:Hide()
            bar.playerCdText:Hide()
            if bar.cdBar then bar.cdBar:Hide() end
            if bar.barBg then bar.barBg:Hide() end
            if bar.barBgSolid then bar.barBgSolid:Hide() end
            if bar.rotLine then bar.rotLine:Hide() end
        else
            if nameChanged then
                bar.nameText:SetText(nameStr)
            end
            -- Attached-bars mode: the unit frame already shows the player's
            -- name, so the on-bar name is redundant — always hide it there.
            if db.showName == false or db.interruptDisplayMode == "ATTACHED_BARS" then
                bar.nameText:Hide()
            else
                bar.nameText:Show()
            end
        end
        FillBarColor(class)
        ApplyBar(bar, cdEnd, baseCd, isPetSpell, spellID)
    end

    -- Render one interrupt-history RECORD onto a styled bar. The record's
    -- name / icon / marker may all be SECRET values (read from the event GUID),
    -- so they are ONLY drawn (SetText / SetTexture / SetSpriteSheetCell) — never
    -- compared, concatenated, or used as a table key. The class colour comes from
    -- the C-side GetClassColor (a secret class token must not index a Lua table).
    local function ShowRecordBar(bar, rec)
        bar:Show()
        bar._ownerName  = nil   -- records aren't matched to a player
        bar._intActive  = false -- not the per-member interrupt-overlay path
        bar._class      = nil
        bar._lastIcon   = nil
        bar._lastName   = nil
        bar._cdVisible  = nil
        bar.spellID     = nil   -- record icon is an enemy spell with no usable ID → no hover tooltip

        local r, g, b = 0.8, 0.8, 0.8
        if rec.class ~= nil and C_ClassColor and C_ClassColor.GetClassColor then
            local ok, col = pcall(C_ClassColor.GetClassColor, rec.class)
            if ok and col then r, g, b = col.r, col.g, col.b end
        end

        -- Interrupted-spell icon (secret-safe).
        pcall(bar.icon.SetTexture, bar.icon, rec.icon)
        bar.icon:SetDesaturated(false)
        bar.icon:SetAlpha(1)

        -- Mob raid marker, left of the icon (secret index → SetSpriteSheetCell).
        -- Suppressed when the "Show raid markers" toggle is off.
        if bar.intMark then
            -- Marker rides the icon, so it's only shown when the icon is shown.
            if rec.mark ~= nil and db.interruptShowMarker ~= false and db.showIcon ~= false then
                bar.intMark:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                local okMk = pcall(bar.intMark.SetSpriteSheetCell, bar.intMark, rec.mark, 4, 4)
                if okMk then bar.intMark:Show() else bar.intMark:Hide() end
            else
                bar.intMark:Hide()
            end
        end

        -- Kicker name (secret → SetText only). Colour follows the
        -- "Use class color (names)" toggle: class colour when on (the
        -- secret-safe r,g,b from GetClassColor above), otherwise the
        -- custom name colour from the picker.
        if bar.nameText then
            pcall(bar.nameText.SetText, bar.nameText, rec.name)
            local nr, ng, nb = r, g, b
            if not db.nameColorUseClass then
                nr, ng, nb = db.nameColorR or 1, db.nameColorG or 1, db.nameColorB or 1
            end
            bar.nameText:SetTextColor(nr, ng, nb)
            if db.showName == false then bar.nameText:Hide() else bar.nameText:Show() end
        end

        -- Depleting timer over the record's lifetime (expireAt is a clean number).
        local rem = rec.expireAt - now
        if rem < 0 then rem = 0 end
        if bar.cdBar then
            local val = (db.barFillMode == "FILL") and (rec.duration - rem) or rem
            bar.cdBar:SetMinMaxValues(0, rec.duration)
            bar.cdBar:SetValue(val < 0 and 0 or val)
            bar.cdBar:SetStatusBarColor(r, g, b, 0.85)
            bar.cdBar:Show()
        end
        -- Background — mirror the live bars:
        --   * Custom Background on → the user's CLEAN db color (+ alpha).
        --   * Class Colors on      → a darker shade of the record's class
        --     color. The shade is only computed when the color value is
        --     a CLEAN number (test-mode records + non-secret real ones);
        --     a secret class token (M+ GUID) can't be multiplied without
        --     tainting the frame, so it falls back to the neutral dark.
        --   * Otherwise            → the fixed neutral dark.
        if db.useCustomBgColor then
            local br, bgc, bb = db.customBgColorR or 0.1, db.customBgColorG or 0.1, db.customBgColorB or 0.1
            local ba = db.customBgColorA or 0.9
            if bar.barBg  then bar.barBg:SetVertexColor(br, bgc, bb, ba) end
            if bar.iconBg then bar.iconBg:SetVertexColor(br * 0.7, bgc * 0.7, bb * 0.7, 1) end
        else
            local shaded = false
            if db.useClassColors then
                local okS, isSec = pcall(issecretvalue, r)
                if not (okS and isSec) then
                    -- r,g,b confirmed non-secret → safe to shade.
                    if bar.barBg  then bar.barBg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25, 0.9) end
                    if bar.iconBg then bar.iconBg:SetVertexColor(r * 0.175, g * 0.175, b * 0.175, 1) end
                    shaded = true
                end
            end
            if not shaded then
                if bar.barBg  then bar.barBg:SetVertexColor(0.1, 0.1, 0.1, 0.9) end
                if bar.iconBg then bar.iconBg:SetVertexColor(0.08, 0.08, 0.08, 1) end
            end
        end
        if bar.barBgSolid then bar.barBgSolid:Show() end

        local sec = math.floor(rem + 0.5)
        if bar.playerCdText then bar.playerCdText:Hide() end
        if bar.partyCdText then
            bar.partyCdText:SetText(sec > 0 and tostring(sec) or "")
            bar.partyCdText:SetTextColor(1, 1, 1)
            bar.partyCdText:Show()
        end
        if bar.playerCdWrapper then bar.playerCdWrapper:SetAlpha(1) end
        if bar.rotLine then bar.rotLine:Hide() end
    end

    local function AddOwnBar()
        local mySpellData = BIT.mySpellID and BIT.ALL_INTERRUPTS[BIT.mySpellID]
        if mySpellData then
            local bar     = bars[barIdx]
            local nameStr = NameColorCode(BIT.myClass) .. BIT.GetDisplayName(BIT.myName or "?", "INTERRUPTS") .. "|r"
            local isPet   = BIT.myIsPetSpell or (BIT.mySpellID
                and not C_SpellBook.IsSpellInSpellBook(BIT.mySpellID, Enum.SpellBookSpellBank.Player)
                and C_SpellBook.IsSpellInSpellBook(BIT.mySpellID, Enum.SpellBookSpellBank.Pet))
            ShowBar(bar, mySpellData.icon, nameStr, BIT.myClass,
                BIT.myKickCdEnd, BIT.myBaseCd or mySpellData.cd,
                isPet and true or false, BIT.mySpellID, BIT.myName)
            ApplyRotBorder(bar, BIT.myName)
            barIdx = barIdx + 1
        end
        for ekKey, ekInfo in pairs(BIT.myExtraKicks) do
            if barIdx > 7 then break end
            local ekData = BIT.ALL_INTERRUPTS[ekKey]
            local ekIcon = ekInfo.icon or (ekData and ekData.icon)
            if ekIcon or ekData then
                local bar     = bars[barIdx]
                local nameStr = NameColorCode(BIT.myClass) .. BIT.GetDisplayName(BIT.myName or "?", "INTERRUPTS") .. "|r"
                ShowBar(bar, ekIcon or ekData.icon, nameStr, BIT.myClass,
                    ekInfo.cdEnd, ekInfo.baseCd, nil, ekKey, BIT.myName)
                barIdx = barIdx + 1
            end
        end
    end

    -- Build sorted party list — reuse module-level tables to avoid GC
    wipe(_sortedParty)
    wipe(_restoShamanEntries)
    for name, info in pairs(BIT.partyAddonUsers) do
        if name ~= BIT.myName then
            local data = BIT.ALL_INTERRUPTS[info.spellID]
            if data then
                local rem   = math.max(0, info.cdEnd - now)
                local entry = { name = name, info = info, data = data, rem = rem }
                if info.spellID == 57994 and (info.baseCd or 0) >= 30 then
                    tinsert(_restoShamanEntries, entry)
                else
                    tinsert(_sortedParty, entry)
                end
            end
        end
    end
    if db.sortMode == "CD_DESC" then
        table.sort(_sortedParty, function(a, b) return a.rem > b.rem end)
    elseif db.sortMode == "CD_ASC" then
        table.sort(_sortedParty, function(a, b) return a.rem < b.rem end)
    end
    for _, e in ipairs(_restoShamanEntries) do tinsert(_sortedParty, e) end

    local function AddPartyBars()
        if db.soloMode then return end
        -- "Availability" mode (default on): a party member's bar is only shown
        -- while their interrupt is on cooldown, so a MISSING bar means that
        -- player is ready to kick. The own bar is always shown (AddOwnBar).
        local hideReady = db.interruptHideReady ~= false
        for _, entry in ipairs(_sortedParty) do
            if barIdx > 7 then break end
            local name, info, data = entry.name, entry.info, entry.data
            local nameStr = NameColorCode(info.class) .. BIT.GetDisplayName(name, "INTERRUPTS") .. "|r"
            if (not hideReady) or (info.cdEnd and info.cdEnd > now) then
                local bar = bars[barIdx]
                ShowBar(bar, data.icon, nameStr, info.class,
                    info.cdEnd, info.baseCd or data.cd, nil, info.spellID, name)
                ApplyRotBorder(bar, name)
                barIdx = barIdx + 1
            end
            if info.extraKicks then
                for _, ek in ipairs(info.extraKicks) do
                    if barIdx > 7 then break end
                    local ekData = ek.spellID and BIT.ALL_INTERRUPTS[ek.spellID]
                    local ekIcon = ek.icon or (ekData and ekData.icon)
                    if (ekIcon or ekData) and ((not hideReady) or (ek.cdEnd and ek.cdEnd > now)) then
                        local ebar = bars[barIdx]
                        ShowBar(ebar, ekIcon or ekData.icon, nameStr, info.class,
                            ek.cdEnd, ek.baseCd, nil, ek.spellID, name)
                        barIdx = barIdx + 1
                    end
                end
            end
        end
    end

    -- Interrupt-history list: show recent interrupts (who kicked what + the
    -- mob's marker), newest first, each for its lifetime, then gone. Replaces the
    -- per-member party rendering — which cannot be accurate without addon comm /
    -- roster matching (both unavailable for non-addon players and in M+).
    local function AddRecordBars()
        local recs = BIT._interruptRecords
        if not recs then return end
        for i = #recs, 1, -1 do                       -- drop expired
            if (recs[i].expireAt or 0) <= now then table.remove(recs, i) end
        end
        for i = #recs, 1, -1 do                       -- newest first
            if barIdx > 7 then break end
            ShowRecordBar(bars[barIdx], recs[i])
            barIdx = barIdx + 1
        end
    end

    AddOwnBar()
    AddRecordBars()

    for i = barIdx, 7 do
        local bar = bars[i]
        if bar:IsShown() then
            bar:Hide()
            bar._lastIcon  = nil
            bar._lastName  = nil
            bar._ownerName = nil
            bar._lastCdSec = nil
            bar._cdVisible = nil
            bar._intActive = false
            bar._intMarkIdx = nil
            if bar.intMark then bar.intMark:Hide() end
        end
    end

    -- ATTACHED_BARS: re-anchor each visible bar to its member's unit frame
    -- (overrides the stacked layout RebuildBars set). The standalone window
    -- itself shrinks to nothing so it isn't an invisible click-catcher.
    if db.interruptDisplayMode == "ATTACHED_BARS" then
        _LayoutAttachedBars(barIdx - 1)
        if not isResizing and mainFrame then mainFrame:SetSize(1, 1) end
        return
    end

    if not isResizing and mainFrame then
        local numVisible = barIdx - 1
        if numVisible > 0 then
            if iconOnly then
                local icoSize = db.iconOnlySize or 36
                local icoGap  = db.iconOnlySpacing or 4
                local perRow  = db.iconOnlyPerRow or 7
                local cols    = math.min(numVisible, perRow)
                local rows    = math.ceil(numVisible / perRow)
                local w = cols * icoSize + (cols - 1) * icoGap
                local h = titleH + rows * icoSize + (rows - 1) * icoGap
                mainFrame:SetSize(w, h)
            else
                local barGap = db.barGap or 0
                mainFrame:SetSize(db.frameWidth, titleH + numVisible * barH + (numVisible - 1) * barGap)
            end
        end
    end
end

-- Valid frame strata, low → high. Used to validate the user setting
-- (SetFrameStrata throws on an unknown string) and by the attached-bars
-- relative-strata logic above.
local VALID_STRATA = {
    BACKGROUND = true, LOW = true, MEDIUM = true, HIGH = true, DIALOG = true,
}

-- Apply the user-chosen window strata to the standalone tracker live
-- (no /reload needed). Children inherit it, so the whole bars window
-- moves layers together. Attached-bars mode overrides per-bar strata
-- relative to the unit frame, so this setting governs the standalone /
-- icon-window layering.
function BIT.UI:ApplyFrameStrata()
    if not mainFrame then return end
    local s = BIT.db and BIT.db.interruptFrameStrata
    if not VALID_STRATA[s] then s = "MEDIUM" end
    mainFrame:SetFrameStrata(s)
end

------------------------------------------------------------
-- Create main frame
------------------------------------------------------------
function BIT.UI:Create()
    local db = BIT.db
    local m  = BIT.Media

    mainFrame = CreateFrame("Frame", "BliZziInterruptsFrame", UIParent)
    mainFrame:SetSize(db.frameWidth, 200)
    mainFrame:SetFrameStrata(db.interruptFrameStrata or "MEDIUM")
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetAlpha(db.alpha)

    -- Normal drag when NOT using Edit Mode (respects lock).
    -- Reads BIT.db live (NOT the closure-captured `db` which would be a
    -- stale reference to whatever profile was active at Create time).
    -- Without this, switching profiles after addon load would freeze
    -- the lock state on the originally-loaded profile.
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton", "RightButton")
    mainFrame:SetScript("OnDragStart", function(self)
        if BIT._moveAllUnlock or not (BIT.db and BIT.db.locked) then self:StartMoving() end
    end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local _, _, _, _, _, titleH = GetBarLayout()
        local left = self:GetLeft()
        -- Position is now per-profile (lives in BIT.db). Each profile
        -- remembers its own placement, so switching to a different
        -- profile snaps the tracker to that profile's saved position.
        if BIT.db.growUpward then
            local bottom = self:GetBottom()
            if left and bottom then
                BIT.db.posXUp = left
                BIT.db.posYUp = bottom
            end
        else
            local top = self:GetTop()
            if left and top then
                BIT.db.posX = left
                BIT.db.posY = top - titleH
            end
        end
        -- sync position editor if open
        if _posEditor and _posEditor:IsShown() and _posEditorRefresh then
            _posEditorRefresh()
        end
    end)

    -- ── Position Editor ──────────────────────────────────────────────────
    -- Appears below the frame when clicked while unlocked.
    -- Shows X/Y editboxes + arrow buttons for pixel-perfect placement.
    _posEditor = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    _posEditor:SetSize(180, 90)
    _posEditor:SetFrameStrata("DIALOG")
    _posEditor:Hide()
    _posEditor:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    _posEditor:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    _posEditor:SetBackdropBorderColor(0, 0.8, 0.8, 0.8)

    -- Helper: read current anchor position (per-profile, BIT.db)
    local function _posGetXY()
        local _, _, _, _, _, titleH = GetBarLayout()
        if BIT.db.growUpward then
            return math.floor(BIT.db.posXUp or mainFrame:GetLeft() or 0),
                   math.floor(BIT.db.posYUp or mainFrame:GetBottom() or 0)
        else
            return math.floor(BIT.db.posX or mainFrame:GetLeft() or 0),
                   math.floor((BIT.db.posY or ((mainFrame:GetTop() or 0) - titleH)) )
        end
    end

    -- Helper: apply X/Y to frame + save (per-profile, BIT.db)
    local function _posApply(x, y)
        local _, _, _, _, _, titleH = GetBarLayout()
        mainFrame:ClearAllPoints()
        if BIT.db.growUpward then
            BIT.db.posXUp = x
            BIT.db.posYUp = y
            mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
        else
            BIT.db.posX = x
            BIT.db.posY = y
            mainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y + titleH)
        end
    end

    -- X label + editbox
    local xLabel = _posEditor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xLabel:SetPoint("TOPLEFT", _posEditor, "TOPLEFT", 8, -8)
    xLabel:SetText("|cFF00DDDDX:|r")

    local xBox = CreateFrame("EditBox", nil, _posEditor, "BackdropTemplate")
    xBox:SetSize(52, 20)
    xBox:SetPoint("LEFT", xLabel, "RIGHT", 4, 0)
    xBox:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
    xBox:SetBackdropColor(0.15, 0.15, 0.15, 1)
    xBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    xBox:SetAutoFocus(false)
    xBox:SetNumeric(false)
    xBox:SetMaxLetters(6)
    xBox:SetFontObject(GameFontNormal)
    xBox:SetTextInsets(4, 4, 0, 0)
    xBox:SetScript("OnEnterPressed", function(self)
        local v = tonumber(self:GetText())
        if v then local _, y = _posGetXY(); _posApply(v, y) end
        self:ClearFocus()
    end)
    xBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Y label + editbox
    local yLabel = _posEditor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    yLabel:SetPoint("LEFT", xBox, "RIGHT", 10, 0)
    yLabel:SetText("|cFF00DDDDY:|r")

    local yBox = CreateFrame("EditBox", nil, _posEditor, "BackdropTemplate")
    yBox:SetSize(52, 20)
    yBox:SetPoint("LEFT", yLabel, "RIGHT", 4, 0)
    yBox:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
    yBox:SetBackdropColor(0.15, 0.15, 0.15, 1)
    yBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    yBox:SetAutoFocus(false)
    yBox:SetNumeric(false)
    yBox:SetMaxLetters(6)
    yBox:SetFontObject(GameFontNormal)
    yBox:SetTextInsets(4, 4, 0, 0)
    yBox:SetScript("OnEnterPressed", function(self)
        local v = tonumber(self:GetText())
        if v then local x, _ = _posGetXY(); _posApply(x, v) end
        self:ClearFocus()
    end)
    yBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Refresh editboxes from current position
    function _posEditorRefresh()
        local x, y = _posGetXY()
        xBox:SetText(tostring(x))
        yBox:SetText(tostring(y))
    end

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, _posEditor, "BackdropTemplate")
    resetBtn:SetSize(60, 20)
    resetBtn:SetPoint("TOPLEFT", _posEditor, "TOPLEFT", 8, -34)
    resetBtn:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
    resetBtn:SetBackdropColor(0.12, 0.12, 0.12, 1)
    resetBtn:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    local resetLbl = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resetLbl:SetAllPoints()
    resetLbl:SetText("Reset")
    resetBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0, 0.8, 0.8, 1) end)
    resetBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1) end)
    resetBtn:SetScript("OnClick", function()
        -- Per-profile reset: nukes only the active profile's position.
        BIT.db.posX   = nil; BIT.db.posY   = nil
        BIT.db.posXUp = nil; BIT.db.posYUp = nil
        BIT.UI.ApplyFramePosition()
        _posEditorRefresh()
    end)

    -- Arrow buttons: direction, dx, dy
    local arrows = {
        { sym="^",  dx= 0, dy= 1, col=1, row=1 },
        { sym="v",  dx= 0, dy=-1, col=1, row=2 },
        { sym="<",  dx=-1, dy= 0, col=0, row=2 },
        { sym=">",  dx= 1, dy= 0, col=2, row=2 },
    }
    local arrowSize = 20
    local arrowOriginX = 82
    local arrowOriginY = -36

    for _, a in ipairs(arrows) do
        local btn = CreateFrame("Button", nil, _posEditor, "BackdropTemplate")
        btn:SetSize(arrowSize, arrowSize)
        btn:SetPoint("TOPLEFT", _posEditor, "TOPLEFT",
            arrowOriginX + a.col * (arrowSize + 2),
            arrowOriginY - (a.row - 1) * (arrowSize + 2))
        btn:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1 })
        btn:SetBackdropColor(0.12, 0.12, 0.12, 1)
        btn:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetAllPoints()
        lbl:SetText(a.sym)
        btn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0, 0.8, 0.8, 1) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1) end)

        -- Hold-to-repeat: fires once immediately, then repeats after 0.3s at 0.05s intervals
        local function doMove()
            local x, y = _posGetXY()
            _posApply(x + a.dx, y + a.dy)
            _posEditorRefresh()
        end
        btn:SetScript("OnClick", doMove)
    end

    -- Toggle editor on left-click while unlocked
    mainFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and not BIT.db.locked then
            if _posEditor:IsShown() then
                _posEditor:Hide()
            else
                _posEditorRefresh()
                -- Position editor below the main frame
                _posEditor:ClearAllPoints()
                _posEditor:SetPoint("TOP", mainFrame, "BOTTOM", 0, -4)
                _posEditor:Show()
            end
        end
    end)

    -- Hide editor when frame is hidden (e.g. out of combat)
    mainFrame:HookScript("OnHide", function()
        _posEditor:Hide()
    end)
    BIT.UI.HidePosEditor = function() _posEditor:Hide() end

    -- (The old floating "Lock" button below the unlocked frame was
    -- removed — locking is done via the settings toggle / move-all mode.)

    -- Background (transparent)
    local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(m.flatTexture)
    bg:SetVertexColor(0.05, 0.05, 0.05, 0)




    -- Title
    titleText = mainFrame:CreateFontString(nil, "OVERLAY")
    do
        local titleSize = (db.titleFontSize and db.titleFontSize > 0) and db.titleFontSize or 12
        m:SetFont(titleText, titleSize)
        local align     = db.titleAlign or "CENTER"
        local initTitleH = db.showTitle and 20 or 0
        if align == "LEFT" then
            titleText:SetPoint("BOTTOMLEFT",  mainFrame, "TOPLEFT",  0, -initTitleH)
        elseif align == "RIGHT" then
            titleText:SetPoint("BOTTOMRIGHT", mainFrame, "TOPRIGHT", 0, -initTitleH)
        else
            titleText:SetPoint("BOTTOM",      mainFrame, "TOP",      0, -initTitleH)
        end
    end
    titleText:SetText(BIT.L["TITLE_TEXT"])
    titleText:SetTextColor(db.titleColorR or 0, db.titleColorG or 0.867, db.titleColorB or 0.867)
    if not db.showTitle then titleText:Hide() end

    -- Position: posX/posY stored per-profile in BIT.db so each profile
    -- remembers its own placement. The frame TOPLEFT corresponds to
    -- bar[1] top minus titleH, so the title appears above without
    -- shifting the bar below it.
    local function ApplyFramePosition()
        local _, _, _, _, _, titleH = GetBarLayout()
        mainFrame:ClearAllPoints()
        -- Free anchor: pin the START bar (bar 1) to a user-picked frame and
        -- let the stack grow ONE way only — matching Grow Upward. Anchoring by
        -- CENTRE would make the window grow both up and down as bars are added
        -- (since the frame resizes around a fixed centre). Horizontally the
        -- block is centred on the target. Highest priority; falls through to
        -- the logic below if the target frame isn't on screen.
        if BIT.db.interruptFreeAnchor then
            local target = ResolveFramePath(BIT.db.interruptFreeAnchorTarget)
            if target then
                local fx = BIT.db.interruptFreeAnchorX or 0
                local fy = BIT.db.interruptFreeAnchorY or 0
                if BIT.db.growUpward then
                    -- bar 1 is the bottom row: bottom edge stays, grows upward.
                    mainFrame:SetPoint("BOTTOM", target, "CENTER", fx, fy)
                else
                    -- bar 1 is the top row (title sits above it): offset by
                    -- titleH so bar 1 — not the title — lands on the anchor.
                    mainFrame:SetPoint("TOP", target, "CENTER", fx, fy + titleH)
                end
                return
            end
        end
        -- ("Anchor to unit frames" was removed — Free Anchor above replaces it.)
        if BIT.db.growUpward then
            if BIT.db.posXUp and BIT.db.posYUp then
                mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", BIT.db.posXUp, BIT.db.posYUp)
            else
                mainFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 100, 200)
            end
        else
            if BIT.db.posX and BIT.db.posY then
                -- posY = bar[1] top; frame TOPLEFT = bar[1] top + titleH
                mainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", BIT.db.posX, BIT.db.posY + titleH)
            else
                mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -200)
            end
        end
    end
    ApplyFramePosition()
    BIT.UI.ApplyFramePosition = ApplyFramePosition

    -- The tracker is moved via the addon's own drag (unlock + drag) and the
    -- position editor — it is intentionally NOT registered with Blizzard
    -- Edit Mode.

    -- Expose for Config
    BIT.UI.mainFrame = mainFrame
    BIT.UI.titleText = titleText

    mainFrame:Show()
    self:RebuildBars()
end

function BIT.UI:ApplyAutoScale()
    if not mainFrame then return end
    local _, screenHeight = GetPhysicalScreenSize()
    local scale = 1.0
    if screenHeight and screenHeight > 0 then
        scale = math.max(0.6, math.min(2.0, screenHeight / 1080))
    end
    mainFrame:SetScale(scale)
    -- Re-layout bars now that effective scale is known, so pixel snapping is correct
    BIT.UI:RebuildBars()
end
------------------------------------------------------------
-- Kick Rotation Panel
------------------------------------------------------------
local rotationPanel = nil

local function GetClassColor(playerName)
    if playerName == BIT.myName then
        local c = BIT.CLASS_COLORS[BIT.myClass]
        return c and {c[1], c[2], c[3]} or {1,1,1}
    end
    local info = BIT.partyAddonUsers[playerName]
    if info and info.class then
        local c = BIT.CLASS_COLORS[info.class]
        return c and {c[1], c[2], c[3]} or {1,1,1}
    end
    return {1, 1, 1}
end

-- Adds any party members not yet in rotationOrder (never removes existing)
local function SyncPartyToRotation()
    local inOrder = {}
    for _, n in ipairs(BIT.rotationOrder) do inOrder[n] = true end
    if BIT.myName and not inOrder[BIT.myName] then
        BIT.rotationOrder[#BIT.rotationOrder+1] = BIT.myName
        inOrder[BIT.myName] = true
    end
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then
            local n = UnitName(u)
            if n and not inOrder[n] then
                BIT.rotationOrder[#BIT.rotationOrder+1] = n
                inOrder[n] = true
            end
        end
    end
    BIT.db.rotationOrder = BIT.rotationOrder
    _rotOrderDirty = true
end

local ROW_H    = 32
local ROW_PAD  = 6
local PANEL_W  = 260
local HDR_H    = 48

local function BuildRotationPanel()
    if not rotationPanel then return end

    -- Always add any party members not yet in the list
    SyncPartyToRotation()

    rotationPanel.rows = rotationPanel.rows or {}
    for _, rf in ipairs(rotationPanel.rows) do rf:Hide() end

    local n = #BIT.rotationOrder
    local totalH = HDR_H + n * (ROW_H + ROW_PAD) + ROW_PAD + 44
    rotationPanel:SetSize(PANEL_W, math.max(160, totalH))

    local y = -(HDR_H + ROW_PAD)

    for i = 1, n do
        local idx  = i
        local name = BIT.rotationOrder[i]
        local f    = rotationPanel.rows[idx]

        if not f then
            f = CreateFrame("Frame", nil, rotationPanel)
            f:SetHeight(ROW_H)

            -- row background
            f.bg = f:CreateTexture(nil, "BACKGROUND")
            f.bg:SetAllPoints()
            f.bg:SetColorTexture(0.12, 0.12, 0.12, 0.9)

            -- left accent bar (colored by position: green/yellow/dim)
            f.accent = f:CreateTexture(nil, "BORDER")
            f.accent:SetWidth(3)
            f.accent:SetPoint("TOPLEFT",    f, "TOPLEFT",  0, 0)
            f.accent:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)

            -- position number
            f.posLabel = f:CreateFontString(nil, "OVERLAY")
            f.posLabel:SetFont(STANDARD_TEXT_FONT, 11, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
            f.posLabel:SetPoint("LEFT", f, "LEFT", 10, 0)
            f.posLabel:SetWidth(18)
            f.posLabel:SetJustifyH("RIGHT")

            -- player name
            f.nm = f:CreateFontString(nil, "OVERLAY")
            f.nm:SetFont(STANDARD_TEXT_FONT, 12, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
            f.nm:SetPoint("LEFT", f, "LEFT", 34, 0)
            f.nm:SetWidth(PANEL_W - 34 - 58)
            f.nm:SetJustifyH("LEFT")
            f.nm:SetWordWrap(false)

            -- up button
            f.upBtn = CreateFrame("Button", nil, f)
            f.upBtn:SetSize(22, ROW_H - 4)
            f.upBtn:SetPoint("RIGHT", f, "RIGHT", -26, 0)
            f.upBtn.tex = f.upBtn:CreateTexture(nil, "ARTWORK")
            f.upBtn.tex:SetAllPoints()
            f.upBtn.tex:SetColorTexture(0.25, 0.25, 0.25, 1)
            f.upBtn.lbl = f.upBtn:CreateFontString(nil, "OVERLAY")
            f.upBtn.lbl:SetFont(STANDARD_TEXT_FONT, 13, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
            f.upBtn.lbl:SetAllPoints()
            f.upBtn.lbl:SetJustifyH("CENTER")
            f.upBtn.lbl:SetText("|cFFCCCCCC^|r")
            f.upBtn:SetScript("OnEnter", function(self) self.tex:SetColorTexture(0.4, 0.4, 0.4, 1) end)
            f.upBtn:SetScript("OnLeave", function(self) self.tex:SetColorTexture(0.25, 0.25, 0.25, 1) end)

            -- down button
            f.downBtn = CreateFrame("Button", nil, f)
            f.downBtn:SetSize(22, ROW_H - 4)
            f.downBtn:SetPoint("RIGHT", f, "RIGHT", -2, 0)
            f.downBtn.tex = f.downBtn:CreateTexture(nil, "ARTWORK")
            f.downBtn.tex:SetAllPoints()
            f.downBtn.tex:SetColorTexture(0.25, 0.25, 0.25, 1)
            f.downBtn.lbl = f.downBtn:CreateFontString(nil, "OVERLAY")
            f.downBtn.lbl:SetFont(STANDARD_TEXT_FONT, 13, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
            f.downBtn.lbl:SetAllPoints()
            f.downBtn.lbl:SetJustifyH("CENTER")
            f.downBtn.lbl:SetText("|cFFCCCCCCv|r")
            f.downBtn:SetScript("OnEnter", function(self) self.tex:SetColorTexture(0.4, 0.4, 0.4, 1) end)
            f.downBtn:SetScript("OnLeave", function(self) self.tex:SetColorTexture(0.25, 0.25, 0.25, 1) end)

            rotationPanel.rows[idx] = f
        end

        f:ClearAllPoints()
        f:SetPoint("TOPLEFT",  rotationPanel, "TOPLEFT",  ROW_PAD, y)
        f:SetPoint("TOPRIGHT", rotationPanel, "TOPRIGHT", -ROW_PAD, y)

        -- accent color: offset from rotationIndex — 0=green, 1=yellow, 2=orange, rest=dim
        local n = #BIT.rotationOrder
        local offset = n > 0 and (idx - BIT.rotationIndex) % n or 0
        if     offset == 0 then f.accent:SetColorTexture(0,    1,    0,    1)
        elseif offset == 1 then f.accent:SetColorTexture(1,    0.85, 0,    1)
        elseif offset == 2 then f.accent:SetColorTexture(1,    0.45, 0,    1)
        else                    f.accent:SetColorTexture(0.35, 0.35, 0.35, 1) end

        -- position label: gold if current turn
        local isCurrent = (idx == BIT.rotationIndex) and BIT.db.rotationEnabled
        if isCurrent then
            f.posLabel:SetText("|cFFFFD100" .. idx .. ".|r")
        else
            f.posLabel:SetText("|cFF888888" .. idx .. ".|r")
        end

        -- player name with class color
        local cc = GetClassColor(name)
        f.nm:SetText(string.format("|cFF%02X%02X%02X%s|r",
            cc[1]*255, cc[2]*255, cc[3]*255, BIT.GetDisplayName(name, "INTERRUPTS")))

        -- up/down visibility
        if idx > 1 then
            f.upBtn:Show()
            f.upBtn:SetScript("OnClick", function()
                BIT.rotationOrder[idx], BIT.rotationOrder[idx-1] = BIT.rotationOrder[idx-1], BIT.rotationOrder[idx]
                if     BIT.rotationIndex == idx   then BIT.rotationIndex = idx - 1
                elseif BIT.rotationIndex == idx-1 then BIT.rotationIndex = idx end
                BIT.Rotation.index   = BIT.rotationIndex
                BIT.db.rotationOrder = BIT.rotationOrder
                BIT.db.rotationIndex = BIT.rotationIndex
                _rotOrderDirty = true
                BuildRotationPanel()
            end)
        else f.upBtn:Hide() end

        if idx < n then
            f.downBtn:Show()
            f.downBtn:SetScript("OnClick", function()
                BIT.rotationOrder[idx], BIT.rotationOrder[idx+1] = BIT.rotationOrder[idx+1], BIT.rotationOrder[idx]
                if     BIT.rotationIndex == idx   then BIT.rotationIndex = idx + 1
                elseif BIT.rotationIndex == idx+1 then BIT.rotationIndex = idx end
                BIT.Rotation.index   = BIT.rotationIndex
                BIT.db.rotationOrder = BIT.rotationOrder
                BIT.db.rotationIndex = BIT.rotationIndex
                _rotOrderDirty = true
                BuildRotationPanel()
            end)
        else f.downBtn:Hide() end

        f:Show()
        y = y - (ROW_H + ROW_PAD)
    end
end

function BIT.UI:ShowRotationPanel()
    if not rotationPanel then
        rotationPanel = CreateFrame("Frame", "BITRotationPanel", UIParent, "BackdropTemplate")
        rotationPanel:SetSize(PANEL_W, 320)
        rotationPanel:SetPoint("CENTER")
        rotationPanel:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        rotationPanel:SetBackdropColor(0.08, 0.08, 0.08, 0.97)
        rotationPanel:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        rotationPanel:SetMovable(true)
        rotationPanel:EnableMouse(true)
        rotationPanel:RegisterForDrag("LeftButton")
        rotationPanel:SetScript("OnDragStart", rotationPanel.StartMoving)
        rotationPanel:SetScript("OnDragStop",  rotationPanel.StopMovingOrSizing)
        rotationPanel:SetClampedToScreen(true)
        rotationPanel:SetFrameStrata("DIALOG")
        rotationPanel:SetFrameLevel(200)
        rotationPanel:Hide()  -- start hidden so first toggle shows it

        -- Header background
        local hdrBg = rotationPanel:CreateTexture(nil, "BACKGROUND", nil, 1)
        hdrBg:SetColorTexture(0.04, 0.04, 0.04, 1)
        hdrBg:SetPoint("TOPLEFT",  rotationPanel, "TOPLEFT",  1, -1)
        hdrBg:SetPoint("TOPRIGHT", rotationPanel, "TOPRIGHT", -1, -1)
        hdrBg:SetHeight(HDR_H - 1)

        -- Cyan accent line under header
        local hdrLine = rotationPanel:CreateTexture(nil, "BORDER")
        hdrLine:SetColorTexture(0, 0.87, 0.87, 0.8)
        hdrLine:SetHeight(1)
        hdrLine:SetPoint("TOPLEFT",  rotationPanel, "TOPLEFT",  1,  -(HDR_H))
        hdrLine:SetPoint("TOPRIGHT", rotationPanel, "TOPRIGHT", -1, -(HDR_H))

        -- Title
        local title = rotationPanel:CreateFontString(nil, "OVERLAY")
        title:SetFont(STANDARD_TEXT_FONT, 14, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
        title:SetText("|cFF00DDDD" .. (BIT.L["ROT_TITLE"] or "Kick Rotation") .. "|r")
        title:SetPoint("TOP", rotationPanel, "TOP", 0, -(HDR_H / 2) + 6)

        -- Close button
        local closeBtn = CreateFrame("Button", nil, rotationPanel)
        closeBtn:SetSize(20, 20)
        closeBtn:SetPoint("TOPRIGHT", rotationPanel, "TOPRIGHT", -4, -4)
        local closeTex = closeBtn:CreateFontString(nil, "OVERLAY")
        closeTex:SetFont(STANDARD_TEXT_FONT, 14, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
        closeTex:SetText("|cFFFF4444x|r")
        closeTex:SetAllPoints()
        closeTex:SetJustifyH("CENTER")
        closeBtn:SetScript("OnClick", function() rotationPanel:Hide() end)

        -- Bottom divider
        local botLine = rotationPanel:CreateTexture(nil, "BORDER")
        botLine:SetColorTexture(0.3, 0.3, 0.3, 1)
        botLine:SetHeight(1)
        botLine:SetPoint("BOTTOMLEFT",  rotationPanel, "BOTTOMLEFT",  1, 38)
        botLine:SetPoint("BOTTOMRIGHT", rotationPanel, "BOTTOMRIGHT", -1, 38)

        -- Helper: creates a styled button matching the addon theme
        local function MakeStyledBtn(label, w, h)
            local btn = CreateFrame("Button", nil, rotationPanel)
            btn:SetSize(w, h)

            local bg = btn:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.10, 0.06, 0.06, 1)
            btn.bg = bg

            local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
            border:SetAllPoints()
            border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
            border:SetBackdropBorderColor(0, 0.87, 0.87, 0.8)
            btn.border = border

            local lbl = btn:CreateFontString(nil, "OVERLAY")
            lbl:SetFont(STANDARD_TEXT_FONT, 12, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
            lbl:SetText("|cFF00DDDD" .. label .. "|r")
            lbl:SetAllPoints()
            lbl:SetJustifyH("CENTER")
            btn.lbl = lbl

            btn:SetScript("OnEnter", function()
                bg:SetColorTexture(0.05, 0.18, 0.18, 1)
                border:SetBackdropBorderColor(0, 1, 1, 1)
            end)
            btn:SetScript("OnLeave", function()
                bg:SetColorTexture(0.10, 0.06, 0.06, 1)
                border:SetBackdropBorderColor(0, 0.87, 0.87, 0.8)
            end)
            btn:SetScript("OnMouseDown", function()
                bg:SetColorTexture(0.02, 0.10, 0.10, 1)
            end)
            btn:SetScript("OnMouseUp", function()
                bg:SetColorTexture(0.05, 0.18, 0.18, 1)
            end)
            return btn
        end

        -- Three equal buttons across the bottom (78px each, 4px gap, 8px margins)
        local resetBtn = MakeStyledBtn(BIT.L["ROT_BTN_RESET"] or "Reset", 78, 26)
        resetBtn:SetPoint("BOTTOMLEFT", rotationPanel, "BOTTOMLEFT", 8, 8)
        resetBtn:SetScript("OnClick", function()
            BIT.rotationOrder    = {}
            BIT.rotationIndex    = 1
            BIT.Rotation.order   = BIT.rotationOrder
            BIT.Rotation.index   = 1
            BIT.db.rotationOrder = BIT.rotationOrder
            BIT.db.rotationIndex = BIT.rotationIndex
            BuildRotationPanel()
        end)

        local refreshBtn = MakeStyledBtn(BIT.L["ROT_BTN_REFRESH"] or "Refresh", 78, 26)
        refreshBtn:SetPoint("BOTTOMLEFT", rotationPanel, "BOTTOMLEFT", 90, 8)  -- 8+78+4
        refreshBtn:SetScript("OnClick", function()
            SyncPartyToRotation()
            BuildRotationPanel()
        end)

        local syncBtn = MakeStyledBtn(BIT.L["ROT_BTN_SYNC"] or "Sync Party", 78, 26)
        syncBtn:SetPoint("BOTTOMLEFT", rotationPanel, "BOTTOMLEFT", 172, 8)  -- 8+78+4+78+4
        syncBtn:SetScript("OnClick", function()
            BIT.db.rotationOrder = BIT.rotationOrder
            BIT.db.rotationIndex = BIT.rotationIndex
            BIT.BroadcastRotation()
            print(BIT.L["ROT_SYNCED"] or "|cFF00DDDD[BliZzi Party Tools]|r Rotation synced to party.")
        end)
    end

    BuildRotationPanel()
    if rotationPanel:IsShown() then rotationPanel:Hide() else rotationPanel:Show() end
end

------------------------------------------------------------
-- Attached Interrupt Icons
--   Alternative display mode for the interrupt tracker. When active, the
--   main bars window is hidden and each party member gets their own
--   interrupt-spell icon attached next to their unit frame.
--   The Blizzard/ElvUI/Cell/Grid2/Danders/SUF/EnhanceQoL frame provider
--   detection is shared with the other party-attached features via the
--   Core/UnitFrames.lua helper (BIT.UnitFrames:GetPartyFrame).
------------------------------------------------------------
BIT.UI.AttachedInterrupts = BIT.UI.AttachedInterrupts or {}
local AI = BIT.UI.AttachedInterrupts
local _aiFrames = {}  -- unit → { frame, icon, cooldown, text, _parent, memberName, spellID, baseCd, _lastCdEnd }

local AI_POS = {
    RIGHT  = { point = "LEFT",   relPoint = "RIGHT",  ox =  4, oy =  0 },
    LEFT   = { point = "RIGHT",  relPoint = "LEFT",   ox = -4, oy =  0 },
    TOP    = { point = "BOTTOM", relPoint = "TOP",    ox =  0, oy =  4 },
    BOTTOM = { point = "TOP",    relPoint = "BOTTOM", ox =  0, oy = -4 },
}

-- ── Hot-path helpers for AI:Tick (per-frame, called per-icon per-tick) ──
-- Each of these wraps an operation that can throw on a Midnight (12.x)
-- tainted "secret value" — durations / timestamps returned by the
-- Blizzard cooldown APIs are not always plain numbers and arithmetic on
-- them can propagate taint. Protected execution still happens via pcall;
-- hoisting the bodies to file scope means the per-tick loop calls
-- `pcall(_helper, args)` instead of `pcall(function() ... end)`, which
-- avoids allocating a fresh closure (and a new upvalue table) on every
-- icon, every tick. Functionally identical to the inline form.
local function _AI_SafePositiveSub(a, b)
    local v = a - b
    return v > 0 and v or nil
end

local function _AI_SafePositiveDuration(info)
    local d = info.duration
    return (d and d > 0) and d or nil
end

local function _AI_SafeIsNonPositive(v)
    return v <= 0
end

local function _AI_SafeSetCooldown(cooldown, startTs, duration)
    cooldown:SetCooldown(startTs, duration)
end

local function AI_GetParent(unit)
    -- Shared resolver in Core/UnitFrames.lua handles ElvUI, Cell, Grid2,
    -- ShadowedUnitFrames, Danders/D4, EnhanceQoL, and Blizzard frames.
    -- Each feature reads its own DB key so the user can pick a different
    -- provider per-feature if they want.
    if BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame then
        local provider = BIT.db and BIT.db.interruptAttachFrameProvider or "AUTO"
        return BIT.UnitFrames:GetPartyFrame(unit, provider)
    end
    return nil
end

local function AI_HideUnit(unit)
    local ctx = _aiFrames[unit]
    if ctx and ctx.frame then ctx.frame:Hide() end
end

local function AI_HideAll()
    for unit in pairs(_aiFrames) do AI_HideUnit(unit) end
end

-- Hide every interrupt-tracker visual at once — the standalone window
-- and all attached unit-frame icons. Called by the module's Disable()
-- so nothing lingers on screen when the feature is switched off.
function BIT.UI:HideAllInterrupt()
    if mainFrame then FadeFrame(mainFrame, 0, 0.2) end
    AI_HideAll()
end

-- Pick the interrupt spell + icon for a member. Uses BIT.Self for the local
-- player (the local player is NOT in BIT.Registry — that table only contains
-- party members). Returns: spellID, cd, texture
local function AI_ResolveSpell(memberName, unit)
    if unit == "player" then
        -- Use ONLY the resolved own interrupt (BIT.Self.spellID, kept in
        -- sync with BIT.mySpellID that the standalone bars use). NO class-
        -- default fallback: specs without an interrupt (e.g. Disc/Holy
        -- Priest, who don't have Silence) must show nothing — exactly like
        -- the standalone window. The old fallback wrongly painted the class
        -- default (Silence for any Priest) on those specs' frames.
        local sid = BIT.Self and BIT.Self.spellID
        if sid and sid > 0 then
            local data = BIT.ALL_INTERRUPTS and BIT.ALL_INTERRUPTS[sid]
            local tex  = data and data.icon
                         or (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(sid))
            local cd   = (BIT.Self and BIT.Self.cachedCd) or (BIT.Self and BIT.Self.baseCd)
                         or (data and data.cd) or 15
            return sid, cd, tex
        end
        return nil
    end
    local entry = BIT.Registry and BIT.Registry:Get(memberName)
    if entry and entry.spellID and entry.spellID > 0 then
        local data = BIT.ALL_INTERRUPTS and BIT.ALL_INTERRUPTS[entry.spellID]
        local tex  = data and data.icon
                     or (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(entry.spellID))
        local cd   = entry.baseCd or (data and data.cd) or 15
        return entry.spellID, cd, tex
    end
    return nil
end

-- Resolve the current cdEnd for an attached-icon context.
-- • Own player: BIT.Self.kickCdEnd (main kick) or extraKicks[spellID].cdEnd,
--   falling back to C_Spell.GetSpellCooldown for talent CDR accuracy.
-- • Party member: Registry entry's cdEnd (set by HandlePartyCast).
local function AI_ResolveCdEnd(ctx, unit, now)
    if unit == "player" then
        local self_ = BIT.Self
        if not self_ then return 0 end
        local cdEnd = 0
        if self_.extraKicks and self_.extraKicks[ctx.spellID]
           and self_.extraKicks[ctx.spellID].cdEnd then
            cdEnd = self_.extraKicks[ctx.spellID].cdEnd
        elseif self_.spellID == ctx.spellID and self_.kickCdEnd then
            cdEnd = self_.kickCdEnd
        end
        -- Refine with the live API — catches talent CDR (Seasoned Soldier,
        -- Coldthirst, etc.) that shortens the CD after the start time.
        -- Every access + compare on the returned struct is pcall-wrapped
        -- because the fields can be tainted secret numbers in 12.x.
        local okC, apiEnd = pcall(function()
            local info = C_Spell.GetSpellCooldown(ctx.spellID)
            if not info then return nil end
            local st, du = info.startTime, info.duration
            if not st or not du then return nil end
            if du <= 0 then return nil end
            return st + du
        end)
        if okC and apiEnd then
            local okCmp = pcall(function()
                if apiEnd > now then
                    if cdEnd == 0 or apiEnd < cdEnd then cdEnd = apiEnd end
                end
            end)
            -- If the compare itself threw (tainted apiEnd), silently fall back
            -- to the already-computed cdEnd from Self.kickCdEnd.
            if not okCmp then apiEnd = nil end
        end
        return cdEnd
    end
    local entry = BIT.Registry and BIT.Registry:Get(ctx.memberName)
    return (entry and entry.cdEnd) or 0
end

local function AI_BuildOrUpdateIcon(unit, memberName)
    local parent = AI_GetParent(unit)
    if not parent then
        AI_HideUnit(unit)
        return
    end
    local spellID, baseCd, tex = AI_ResolveSpell(memberName, unit)
    if not spellID or not tex then
        AI_HideUnit(unit)
        return
    end

    local db   = BIT.db
    local size = db.interruptAttachIconSize or 32
    local pos  = db.interruptAttachPos or "RIGHT"
    local ox   = db.interruptAttachOffsetX or 0
    local oy   = db.interruptAttachOffsetY or 0
    local cSz  = db.interruptAttachCounterSize or 14
    local cfg  = AI_POS[pos] or AI_POS.RIGHT

    local ctx = _aiFrames[unit]
    local needsNewFrame = not (ctx and ctx.frame and ctx._parent == parent)
    if needsNewFrame then
        if ctx and ctx.frame then
            ctx.frame:Hide()
            ctx.frame:SetParent(nil)
        end
        ctx = { _parent = parent }
        local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        f:SetFrameLevel((parent:GetFrameLevel() or 1) + 10)
        f.icon = f:CreateTexture(nil, "ARTWORK")
        f.icon:SetAllPoints(f)
        f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        -- Spell tooltip on hover. Mirrors the standalone-bar behaviour and
        -- shares the same BIT.db.interruptTooltip toggle. Default-enabled:
        -- only an explicit `false` value suppresses the tooltip — nil falls
        -- through to "show" so the feature works before defaults have
        -- merged into BIT.db on a fresh install. ctx is captured in the
        -- closure so the tooltip always shows the icon's currently
        -- tracked spell.
        f:EnableMouse(true)
        f:SetScript("OnEnter", function(self)
            if BIT.db and BIT.db.interruptTooltip == false then return end
            local sid = ctx.spellID
            if not sid then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local ok = pcall(GameTooltip.SetSpellByID, GameTooltip, sid)
            if not ok then
                GameTooltip:Hide()
                return
            end
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function() GameTooltip:Hide() end)
        -- Cooldown swipe overlay (Blizzard cooldown frame handles the sweep)
        f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
        f.cooldown:SetAllPoints(f)
        f.cooldown:SetDrawEdge(false)
        f.cooldown:SetDrawBling(false)
        f.cooldown:SetHideCountdownNumbers(true)  -- we draw our own text
        -- Border overlay (renders above cooldown swipe so it stays visible).
        -- Only `borderOverlay` is set on attached icons — leaving
        -- `iconBorderOverlay` nil prevents ApplyBorderToFrame from clearing
        -- the backdrop we just set (it would otherwise process both fields
        -- on the same physical frame and the second call wins, wiping the
        -- border). The single overlay is also expanded outward by the
        -- border size in ApplyBorderToFrame so the border sits OUTSIDE
        -- the icon, not over its texture.
        local bo = CreateFrame("Frame", nil, f, "BackdropTemplate")
        bo:SetAllPoints(f)
        bo:SetFrameLevel(f:GetFrameLevel() + 5)
        bo:EnableMouse(false)
        f.borderOverlay = bo
        -- Counter text (above everything)
        f.text = f:CreateFontString(nil, "OVERLAY")
        f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
        ctx.frame    = f
        _aiFrames[unit] = ctx
    end

    local f = ctx.frame
    f:SetSize(size, size)
    f:ClearAllPoints()
    f:SetPoint(cfg.point, parent, cfg.relPoint, cfg.ox + ox, cfg.oy + oy)
    -- Frame Layer: an explicit user pick (non-default) sets the icon's
    -- strata directly; the default MEDIUM re-inherits the unit frame's
    -- strata so the icon sits naturally on the frame as before.
    local userStrata = BIT.db and BIT.db.interruptFrameStrata
    if userStrata and userStrata ~= "MEDIUM" and _STRATA_IDX[userStrata] then
        f:SetFrameStrata(userStrata)
    else
        local okS, pst = pcall(parent.GetFrameStrata, parent)
        f:SetFrameStrata((okS and pst) or "MEDIUM")
    end
    f.icon:SetTexture(tex)
    -- Apply the same border style as the main bars. ApplyBorderToFrame
    -- expands f.borderOverlay outward by the border size so the border
    -- sits around the icon rather than overlapping its texture.
    if BIT.UI.ApplyBorderToFrame then
        BIT.UI:ApplyBorderToFrame(f)
    end

    if BIT.Media and BIT.Media.SetFont then
        BIT.Media:SetFont(f.text, cSz)
    else
        f.text:SetFont(STANDARD_TEXT_FONT, cSz, ("OUTLINE" .. (BIT.Media and BIT.Media.slugSuffix or ", SLUG")))
    end
    f.text:SetTextColor(1, 1, 1)

    ctx.memberName = memberName
    ctx.spellID    = spellID
    ctx.baseCd     = baseCd
    ctx._lastCdEnd = nil  -- force a fresh swipe on the next tick
    f:Show()
end

-- Called when party composition, settings or the display mode changes.
function AI:Rebuild()
    if BIT.Interrupts and not BIT.Interrupts:IsEnabled() then
        AI_HideAll()
        return
    end
    if not BIT.db or BIT.db.interruptDisplayMode ~= "ATTACHED" then
        AI_HideAll()
        return
    end
    -- Own icon is controlled by the "Show Own Icon on Player Frame" toggle
    -- in the Attached Display section.
    if BIT.db.interruptAttachShowOwn and BIT.myName then
        AI_BuildOrUpdateIcon("player", BIT.myName)
    else
        AI_HideUnit("player")
    end
    -- Solo Mode: only the own icon is drawn, party members are skipped.
    -- Mirror the behaviour of AddPartyBars() in the classic bars renderer.
    if BIT.db.soloMode then
        for i = 1, 4 do AI_HideUnit("party" .. i) end
        return
    end
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then
            local n = UnitName(u)
            if n then AI_BuildOrUpdateIcon(u, n) end
        else
            AI_HideUnit(u)
        end
    end
end

-- Cheap tick (called from the 10Hz update loop). Only touches frames that
-- are currently shown. Skips instantly when not in ATTACHED mode.
function AI:Tick()
    if not BIT.db or BIT.db.interruptDisplayMode ~= "ATTACHED" then return end
    local now   = GetTime()
    local desat = BIT.db.interruptAttachDesaturateOnCD and true or false
    for unit, ctx in pairs(_aiFrames) do
        local f = ctx.frame
        if f and f:IsShown() then
            local cdEnd = AI_ResolveCdEnd(ctx, unit, now)
            if cdEnd and cdEnd > now then
                local rem = cdEnd - now
                f.text:SetText(tostring(math.floor(rem + 0.5)))
                f.icon:SetDesaturated(desat)
                if ctx._lastCdEnd ~= cdEnd then
                    ctx._lastCdEnd = cdEnd
                    -- Derive the swipe start time. For party: use Registry's
                    -- lastKickAt; for self: cdEnd - baseCd; as a final fallback
                    -- trust the base CD. All numeric comparisons are wrapped
                    -- because durations/timestamps from the Blizzard APIs can
                    -- be secret values in 12.x (comparison throws).
                    local baseCd = ctx.baseCd or 15
                    if unit ~= "player" then
                        local entry = BIT.Registry and BIT.Registry:Get(ctx.memberName)
                        if entry and entry.lastKickAt then
                            local okD, derived = pcall(_AI_SafePositiveSub, cdEnd, entry.lastKickAt)
                            if okD and derived then baseCd = derived end
                        end
                    else
                        -- For own player, prefer the live API's duration. Fields
                        -- on the returned SpellCooldownInfo can be tainted too,
                        -- so every read + compare is pcall-guarded.
                        local okC, info = pcall(C_Spell.GetSpellCooldown, ctx.spellID)
                        if okC and info then
                            local okDur, dur = pcall(_AI_SafePositiveDuration, info)
                            if okDur and dur then baseCd = dur end
                        end
                    end
                    local okCmp, isNeg = pcall(_AI_SafeIsNonPositive, baseCd)
                    if not okCmp or isNeg then baseCd = ctx.baseCd or 15 end
                    -- SetCooldown may propagate taint; wrap to keep the tick loop alive.
                    pcall(_AI_SafeSetCooldown, f.cooldown, cdEnd - baseCd, baseCd)
                end
            else
                if ctx._lastCdEnd ~= 0 then
                    ctx._lastCdEnd = 0
                    f.cooldown:Clear()
                end
                f.text:SetText("")
                f.icon:SetDesaturated(false)
            end
        end
    end
end

-- Called from the main UI rebuild path to ensure the standalone bars window
-- is hidden when we're in ATTACHED mode (and visible otherwise).
function AI:ApplyModeToMainFrame(frame)
    if not frame then return end
    if BIT.db and BIT.db.interruptDisplayMode == "ATTACHED" then
        frame:Hide()
    end
end

-- Reapply border style to every attached icon. Hooked into BIT.UI:ApplyBorderToAll
-- so border changes from the Size & Font settings page propagate here too.
function AI:_ApplyBorderToAll()
    if not BIT.UI.ApplyBorderToFrame then return end
    for _, ctx in pairs(_aiFrames) do
        if ctx.frame then
            BIT.UI:ApplyBorderToFrame(ctx.frame)
        end
    end
end
