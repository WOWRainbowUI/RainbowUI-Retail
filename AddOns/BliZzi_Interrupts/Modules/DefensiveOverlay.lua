-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    DefensiveOverlay.lua - BliZzi Party Tools
    -----------------------------------------------------------------------
    Mirrors the defensives that are active RIGHT NOW as icons centered on
    the member's unit frame, for as long as each buff runs. When two or
    more are up at once they sit side by side, the group staying centered
    on the frame.

    Design notes — why this needs NO spell database:
      * The server-side aura category filter does the classification:
        C_UnitAuras.GetUnitAuras(unit, "HELPFUL|BIG_DEFENSIVE") returns
        exactly the auras that ARE active big defensives, and the
        EXTERNAL_DEFENSIVE filter covers target-cast externals. We
        never need to know WHICH spell it is.
      * Everything we touch on the aura is display-only and therefore
        safe under 12.x secret-value rules: `aura.icon` goes straight
        into a C-side SetTexture, and the swipe comes from the
        DurationObject returned by C_UnitAuras.GetAuraDuration handed
        to Cooldown:SetCooldownFromDurationObject — no arithmetic on
        any aura field, ever.
      * The icons are parented to the unit frame, so they inherit the
        frame's fading (range dimming etc.) and hide with it.
    -----------------------------------------------------------------------
]]

BIT = BIT or {}
BIT.DefensiveOverlay = BIT.DefensiveOverlay or {}
local OVL = BIT.DefensiveOverlay

local UNITS      = { "player", "party1", "party2", "party3", "party4" }
local _isWatched = { player = true, party1 = true, party2 = true,
                     party3 = true, party4 = true }
local MAX_ICONS  = 6    -- safety cap on simultaneous icons per member
local ICON_GAP   = 2    -- px between adjacent icons

local _units  = {}       -- unit -> { icons = { frame, frame, ... } }
local _scratch = {}      -- reused active-aura list (UpdateUnit is not re-entrant)
local _extScratch = {}   -- externals collected separately, appended after bigs
local _eventFrame

local function IsEnabled()
    return BIT.db and BIT.db.defensiveOverlayEnabled == true
end

local function GlowOn(f)
    if BIT.db and BIT.db.defensiveOverlayGlow ~= false
       and BIT.PartyCooldowns and BIT.PartyCooldowns.StartGlowOn then
        BIT.PartyCooldowns:StartGlowOn(f)
    end
end

local function GlowOff(f)
    if BIT.PartyCooldowns and BIT.PartyCooldowns.StopGlowOn then
        BIT.PartyCooldowns:StopGlowOn(f)
    end
end

-- Resolve the member's unit frame through the same provider selection
-- the Party CDs anchored mode uses (ElvUI / Cell / Grid2 / ... / AUTO).
local function GetAnchor(unit)
    local hint = (BIT.db and BIT.db.partyCooldownsProvider) or "AUTO"
    if hint == "AUTO" then hint = nil end
    if BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame then
        return BIT.UnitFrames:GetPartyFrame(unit, hint)
    end
    return nil
end

local function CreateIconFrame()
    local f = CreateFrame("Frame", nil, UIParent)
    f:Hide()
    f:EnableMouse(false)

    local border = f:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0, 0, 0, 1)

    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.tex = tex

    -- No cooldown swipe and no countdown number on the overlay — just
    -- the icon + glow (the anchored Party CDs icons carry the timer).
    return f
end

local function EnsureUnit(unit)
    local rec = _units[unit]
    if not rec then rec = { icons = {} }; _units[unit] = rec end
    return rec
end

local function HideIcon(f)
    if not f then return end
    if f:IsShown() then GlowOff(f) end
    f:Hide()
end

-- Hide every icon of a unit from `startIdx` onward (leaves the pool
-- frames alive for reuse).
local function HideIconsFrom(rec, startIdx)
    if not rec then return end
    for i = startIdx, #rec.icons do
        HideIcon(rec.icons[i])
    end
end

-- Fill `_scratch` with the currently-active defensives, big ones first,
-- externals after, capped at MAX_ICONS.
--
-- ONE aura fetch + per-aura category probes with if/elseif — NOT one
-- GetUnitAuras call per category: an aura can carry BOTH category
-- flags (Life Cocoon is BIG_DEFENSIVE and EXTERNAL_DEFENSIVE at once)
-- and separate per-category fetches collected it twice → double icon
-- on the unit frame (live report). The probe API returns clean
-- booleans even for secret party auras, and a secret auraInstanceID
-- may be PASSED to it — we just never compare or store-by-key it.
-- pcall posture matches the Party CDs scan loop throughout.
local function CollectDefensives(unit)
    wipe(_scratch)
    wipe(_extScratch)
    local ok, list = pcall(C_UnitAuras.GetUnitAuras, unit, "HELPFUL")
    if not ok or type(list) ~= "table" then return end
    for _, aura in ipairs(list) do
        if aura and aura.auraInstanceID then
            local okB, outB = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID,
                unit, aura.auraInstanceID, "HELPFUL|BIG_DEFENSIVE")
            if okB and outB == false then
                if #_scratch < MAX_ICONS then
                    _scratch[#_scratch + 1] = aura
                end
            else
                local okE, outE = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID,
                    unit, aura.auraInstanceID, "HELPFUL|EXTERNAL_DEFENSIVE")
                if okE and outE == false and #_extScratch < MAX_ICONS then
                    _extScratch[#_extScratch + 1] = aura
                end
            end
        end
    end
    -- Priority: big self-defensives first, then externals.
    for _, aura in ipairs(_extScratch) do
        if #_scratch >= MAX_ICONS then break end
        _scratch[#_scratch + 1] = aura
    end
end

-- Paint one icon: just the texture. Redrawn unconditionally — aura
-- instance IDs can be secret for party members, so a "same aura?"
-- comparison could throw, and SetTexture is a cheap idempotent C-side
-- display call. No swipe / countdown (glow-only overlay).
local function PaintIcon(f, unit, aura)
    pcall(f.tex.SetTexture, f.tex, aura.icon)
end

local function UpdateUnit(unit)
    local rec = _units[unit]

    if not IsEnabled() or not UnitExists(unit) then
        HideIconsFrom(rec, 1)
        return
    end

    CollectDefensives(unit)
    local count = #_scratch
    if count == 0 then
        HideIconsFrom(rec, 1)
        return
    end

    local parent = GetAnchor(unit)
    if not parent then
        HideIconsFrom(rec, 1)
        return
    end

    rec = EnsureUnit(unit)
    local size    = (BIT.db and BIT.db.defensiveOverlaySize) or 26
    local offX    = (BIT.db and BIT.db.defensiveOverlayOffsetX) or 0
    local offY    = (BIT.db and BIT.db.defensiveOverlayOffsetY) or 0
    local step    = size + ICON_GAP
    -- Center the whole row on the frame: first icon's center sits half
    -- the total width left of center, each next one a step to the right.
    local totalW  = count * size + (count - 1) * ICON_GAP
    local startX  = -(totalW / 2) + size / 2 + offX
    local level   = (parent:GetFrameLevel() or 0) + 20

    for i = 1, count do
        local f = rec.icons[i]
        if not f then f = CreateIconFrame(); rec.icons[i] = f end

        f:SetSize(size, size)
        if f:GetParent() ~= parent then f:SetParent(parent) end
        f:ClearAllPoints()
        f:SetPoint("CENTER", parent, "CENTER", startX + (i - 1) * step, offY)
        f:SetFrameLevel(level)

        PaintIcon(f, unit, _scratch[i])

        if not f:IsShown() then
            f:Show()
            GlowOn(f)
        end
    end

    HideIconsFrom(rec, count + 1)
end

function OVL:RefreshAll()
    for _, unit in ipairs(UNITS) do
        UpdateUnit(unit)
    end
end

-- Live restyle for the settings sliders/toggles: re-run layout (new
-- size / offsets) and restart the glow on every visible icon so a
-- size or color change — and the glow on/off toggle — takes effect
-- without waiting for the next aura event.
function OVL:RefreshStyle()
    for unit, rec in pairs(_units) do
        UpdateUnit(unit)
        for _, f in ipairs(rec.icons) do
            if f:IsShown() then
                GlowOff(f)
                GlowOn(f)
            end
        end
    end
end

local function OnEvent(_, event, unit)
    if event == "UNIT_AURA" then
        -- Broad registration + manual filter: per-unit RegisterUnitEvent
        -- silently drops party-slot deliveries in 12.x (same lesson as
        -- the Party CDs observer).
        if _isWatched[unit] then UpdateUnit(unit) end
    else
        -- GROUP_ROSTER_UPDATE / PLAYER_ENTERING_WORLD: members changed
        -- or frames re-resolved — refresh everything.
        OVL:RefreshAll()
    end
end

-- Register / unregister according to the enable toggle. Safe to call
-- repeatedly (settings toggle, profile switch, login).
function OVL:ApplyEnabled()
    if IsEnabled() then
        if not _eventFrame then
            _eventFrame = CreateFrame("Frame")
            _eventFrame:SetScript("OnEvent",
                (BIT.Prof and BIT.Prof.Wrap) and BIT.Prof.Wrap("PARTY_CDS", OnEvent) or OnEvent)
        end
        _eventFrame:RegisterEvent("UNIT_AURA")
        _eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        _eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RefreshAll()
    else
        if _eventFrame then _eventFrame:UnregisterAllEvents() end
        for _, rec in pairs(_units) do
            HideIconsFrom(rec, 1)
        end
    end
end

-- Boot: wait for PLAYER_LOGIN + one frame so BIT.db is initialised,
-- then arm according to the saved setting.
do
    local boot = CreateFrame("Frame")
    boot:RegisterEvent("PLAYER_LOGIN")
    boot:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_LOGIN")
        C_Timer.After(0, function()
            if BIT.DefensiveOverlay and BIT.DefensiveOverlay.ApplyEnabled then
                BIT.DefensiveOverlay:ApplyEnabled()
            end
        end)
    end)
end
