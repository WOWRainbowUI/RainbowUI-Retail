--[[
    RGX-Framework - Minimap Module

    One-call minimap button with circular drag, persistent angle, tooltip, and
    show/hide — shared across all RGX addons so no addon has to reimplement it.

    Quick start:
        local MM = RGX:GetMinimap()

        local btn = MM:Create({
            name         = "MyAddonMinimapButton",
            icon         = "Interface\\AddOns\\MyAddon\\media\\logo.tga",
            defaultAngle = 220,

            -- Flat storage (reads/writes storage[angleKey] and storage[enabledKey])
            storage    = MyAddonDB,
            angleKey   = "minimapAngle",    -- default "minimapAngle"
            enabledKey = "minimapEnabled",  -- default "minimapEnabled"

            -- OR custom callbacks (takes priority over storage)
            getAngle = function() return db.angle end,
            setAngle = function(v) db.angle = v end,

            tooltip = {
                title = "|cffFF8000My Addon|r",
                icon  = "Interface\\AddOns\\MyAddon\\media\\logo.tga",
                lines = {
                    { left = "|cff58be81Left-Click|r",  right = "Open options" },
                    { left = "|cff4ecdc4Drag|r",        right = "Move around minimap" },
                    { left = "|cffe74c3cCtrl+Right|r",  right = "Hide icon" },
                },
            },

            onLeftClick  = function(btn) MyAddon:OpenOptions() end,
            onRightClick = function(btn) MyAddon:OpenContextMenu(btn) end,
            onCtrlRight  = function(btn) btn:SetVisible(false) end,
        })

        -- After creating
        btn:SetVisible(true)

    Button API:
        btn:SetVisible(bool)   — show/hide + save enabled state
        btn:Toggle()           — flip visibility
        btn:PlaceAtAngle()     — reposition from saved angle (call after Show)
        btn:GetAngle()
        btn:SetAngle(deg)
        btn:IsShown()
        btn.frame              — the raw WoW Button frame
--]]

local _, Minimap = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX Minimap: RGX-Framework not loaded")
    return
end

Minimap.name    = "minimap"
Minimap.version = "1.0.0"

-- Active button registry (by frame name)
Minimap._buttons = {}

--[[============================================================================
    INTERNAL HELPERS
============================================================================]]

local function CalcMinimapRadius()
    if not _G.Minimap then return 80 end
    return math.max(_G.Minimap:GetWidth() or 140, _G.Minimap:GetHeight() or 140) / 2 + 10
end

local function PlaceButton(frame, angleDeg)
    if not _G.Minimap then return end
    local rad = math.rad(angleDeg or 220)
    local r   = CalcMinimapRadius()
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", _G.Minimap, "CENTER", math.cos(rad) * r, math.sin(rad) * r)
end

local function AngleFromCursor()
    if not _G.Minimap then return 220 end
    local mx, my  = _G.Minimap:GetCenter()
    if not mx or not my then return 220 end
    local scale   = _G.Minimap:GetEffectiveScale()
    local cx, cy  = GetCursorPosition()
    cx, cy        = cx / scale, cy / scale
    local deg     = math.deg(math.atan2(cy - my, cx - mx))
    if deg < 0 then deg = deg + 360 end
    return deg
end

--[[============================================================================
    BUTTON WRAPPER
============================================================================]]

local Button = {}
Button.__index = Button

function Button:GetAngle()
    if type(self._getAngle) == "function" then
        return self._getAngle() or self._defaultAngle
    end
    if self._storage and self._angleKey then
        return tonumber(self._storage[self._angleKey]) or self._defaultAngle
    end
    return self._defaultAngle
end

function Button:SetAngle(deg)
    self._angle = deg
    if type(self._setAngle) == "function" then
        self._setAngle(deg)
    elseif self._storage and self._angleKey then
        self._storage[self._angleKey] = deg
    end
end

function Button:PlaceAtAngle()
    PlaceButton(self.frame, self:GetAngle())
end

function Button:IsShown()
    return self.frame:IsShown()
end

function Button:Show()
    self:PlaceAtAngle()
    self.frame:Show()
end

function Button:Hide()
    self.frame:Hide()
end

function Button:Toggle()
    if self:IsShown() then
        self:SetVisible(false)
    else
        self:SetVisible(true)
    end
end

function Button:SetVisible(show)
    if show then
        self:Show()
    else
        self:Hide()
    end
    -- Persist enabled state
    if self._storage and self._enabledKey then
        self._storage[self._enabledKey] = show and true or false
    end
    if type(self._onVisibilityChanged) == "function" then
        self._onVisibilityChanged(show, self)
    end
end

function Button:GetEnabled()
    if self._storage and self._enabledKey then
        local v = self._storage[self._enabledKey]
        return v ~= false
    end
    return true
end

--[[============================================================================
    TOOLTIP BUILDER
============================================================================]]

local function ShowTooltip(btn, opts)
    if not GameTooltip then return end
    local tt = opts.tooltip
    if not tt then return end

    GameTooltip:SetOwner(btn.frame, "ANCHOR_LEFT")
    GameTooltip:ClearLines()

    local title = tt.title or ""
    if tt.icon and tt.icon ~= "" then
        title = "|T" .. tt.icon .. ":18:18:0:0|t " .. title
    end
    GameTooltip:AddLine(title)

    if tt.description then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(tt.description, 1, 1, 1, true)
    end

    local lines = type(tt.getLines) == "function" and tt.getLines(btn) or tt.lines
    if type(lines) == "table" and #lines > 0 then
        GameTooltip:AddLine(" ")
        for _, line in ipairs(lines) do
            if line.left and line.right then
                GameTooltip:AddDoubleLine(line.left, line.right, 1, 1, 1, 1, 1, 1)
            elseif line.text then
                GameTooltip:AddLine(line.text, 1, 1, 1, true)
            end
        end
    end

    GameTooltip:Show()
end

--[[============================================================================
    CREATE
============================================================================]]

--[[
    Create(opts) -> Button wrapper

    opts:
        name           (string, required) — unique global frame name
        icon           (string, required) — icon texture path
        defaultAngle   (number)  — starting angle in degrees (default 220)
        buttonSize     (number)  — frame size (default 32)
        iconSize       (number)  — icon texture size (default 19)
        iconOffsetX    (number)  — icon center x offset (default 0)
        iconOffsetY    (number)  — icon center y offset (default -1)

        -- Storage (flat table)
        storage        (table)
        angleKey       (string)  — default "minimapAngle"
        enabledKey     (string)  — default "minimapEnabled"

        -- Storage (custom callbacks, override storage)
        getAngle       (fn() -> number)
        setAngle       (fn(number))

        -- Tooltip
        tooltip        (table)
            .title       (string)
            .icon        (string)
            .description (string)
            .lines       ({ left, right } or { text })

        -- Click handlers
        onLeftClick    (fn(btn))       — left click (not during drag)
        onRightClick   (fn(btn))       — right click; nil = no action
        onCtrlRight    (fn(btn))       — Ctrl+Right; default = btn:SetVisible(false)

        -- Visibility change
        onVisibilityChanged (fn(visible, btn))
]]
function Minimap:Create(opts)
    assert(type(opts) == "table", "RGXMinimap:Create requires an options table")
    assert(type(opts.name) == "string" and opts.name ~= "", "RGXMinimap:Create requires opts.name")
    assert(type(opts.icon) == "string" and opts.icon ~= "", "RGXMinimap:Create requires opts.icon")

    if not _G.Minimap then
        RGX:Debug("RGXMinimap: Minimap frame not available yet")
        return nil
    end

    -- Return existing if already created
    if _G[opts.name] then
        return self._buttons[opts.name] or _G[opts.name]
    end

    local defaultAngle = opts.defaultAngle or 220
    local buttonSize   = opts.buttonSize   or 32
    local iconSize     = opts.iconSize     or 19
    local iconOffX     = opts.iconOffsetX  or 0
    local iconOffY     = opts.iconOffsetY  or -1

    -- Build the WoW Button frame
    local frame = CreateFrame("Button", opts.name, _G.Minimap)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel((_G.Minimap:GetFrameLevel() or 1) + 8)
    frame:SetSize(buttonSize, buttonSize)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:RegisterForDrag("LeftButton")

    -- Circular background (dark circle)
    local backdrop = frame:CreateTexture(nil, "BACKGROUND")
    backdrop:SetSize(24, 24)
    backdrop:SetPoint("CENTER", frame, "CENTER", 1, 0)
    backdrop:SetTexture("Interface\\Buttons\\WHITE8X8")
    if backdrop.SetMask then
        backdrop:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall")
    end
    backdrop:SetVertexColor(0.03, 0.03, 0.03, 0.98)
    frame.backdrop = backdrop

    -- Tracking border ring overlay
    local ring = frame:CreateTexture(nil, "OVERLAY")
    ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    ring:SetSize(54, 54)
    ring:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    frame.ring = ring

    -- Addon icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(opts.icon)
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("CENTER", frame, "CENTER", iconOffX, iconOffY)
    icon:SetTexCoord(0.02, 0.98, 0.02, 0.98)
    frame.icon = icon

    -- Hover highlight
    frame:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Build the wrapper object
    local btn = setmetatable({}, Button)
    btn.frame          = frame
    btn._defaultAngle  = defaultAngle
    btn._storage       = opts.storage
    btn._angleKey      = opts.angleKey   or "minimapAngle"
    btn._enabledKey    = opts.enabledKey or "minimapEnabled"
    btn._getAngle      = opts.getAngle
    btn._setAngle      = opts.setAngle
    btn._onVisibilityChanged = opts.onVisibilityChanged

    local onLeftClick  = opts.onLeftClick
    local onRightClick = opts.onRightClick
    local onCtrlRight  = opts.onCtrlRight or function(b) b:SetVisible(false) end

    -- Scripts
    frame:SetScript("OnEnter", function()
        if not frame.isDragging then
            ShowTooltip(btn, opts)
        end
    end)

    frame:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    frame:SetScript("OnClick", function(_, mouseButton)
        if frame.isDragging then return end

        if mouseButton == "RightButton" and IsControlKeyDown() then
            if GameTooltip then GameTooltip:Hide() end
            onCtrlRight(btn)
            return
        end

        if mouseButton == "RightButton" then
            if GameTooltip then GameTooltip:Hide() end
            if type(onRightClick) == "function" then onRightClick(btn) end
        else
            if type(onLeftClick) == "function" then onLeftClick(btn) end
        end
    end)

    frame:SetScript("OnDragStart", function()
        frame.isDragging = true
        if GameTooltip then GameTooltip:Hide() end
        frame:SetScript("OnUpdate", function()
            local deg = AngleFromCursor()
            btn:SetAngle(deg)
            PlaceButton(frame, deg)
        end)
    end)

    frame:SetScript("OnDragStop", function()
        frame.isDragging = false
        frame:SetScript("OnUpdate", nil)
        btn:PlaceAtAngle()
    end)

    self._buttons[opts.name] = btn
    _G[opts.name] = frame

    return btn
end

--- Get a previously created button by name.
function Minimap:Get(name)
    return self._buttons[name]
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function Minimap:Init()
    RGX:RegisterModule("minimap", self)
    _G.RGXMinimap = self
end

Minimap:Init()
