-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    DefensiveOverlay.lua - BliZzi Party Tools
    -----------------------------------------------------------------------
    Mirrors the defensives that are active RIGHT NOW as icons on the
    member's unit frame, for as long as each buff runs.

    Design notes — why this reads NO aura data:
      * In 12.x the game refuses every addon-side aura read while auras
        are secret, i.e. in combat ("Auras cannot be accessed when secret
        while tainted"). GetUnitAuras / GetAuraDataByIndex both throw, so
        an addon that scans auras itself shows nothing exactly when it
        matters.
      * Instead each unit gets a Blizzard AuraContainer
        (CustomAuraContainerTemplate): we only DECLARE what to show — the
        server category filters HELPFUL|BIG_DEFENSIVE and
        HELPFUL|EXTERNAL_DEFENSIVE — and the engine finds, shows, hides
        and paints the auras itself, in and out of combat. No spell
        database, no secret values ever reach Lua.
      * An aura can carry both flags (Life Cocoon is big AND external);
        the external group negates BIG_DEFENSIVE so it renders once.
      * Engine buttons may only be written while they are created
        (initializeFrame). Later writes are denied while auras are
        secret, so icon, border and the glow host are all set up there;
        restyles afterwards go through container-level setters.
      * Layout: the first icon sits centered on the frame, further ones
        extend to the right (their count can't be read to re-center).
    -----------------------------------------------------------------------
]]

BIT = BIT or {}
BIT.DefensiveOverlay = BIT.DefensiveOverlay or {}
local OVL = BIT.DefensiveOverlay

local UNITS      = { "player", "party1", "party2", "party3", "party4" }
local MAX_ICONS  = 4    -- per group (big / external)
local ICON_GAP   = 2    -- px between adjacent icons

-- Filter strings in canonical form: polarity first, then the tokens in
-- alphabetical order, a negated token sorting right after its bare name.
local FILTER_BIG   = "HELPFUL|BIG_DEFENSIVE"
local FILTER_EXT   = "HELPFUL|!BIG_DEFENSIVE|EXTERNAL_DEFENSIVE"
-- Extra group: buffs picked by spell ID that the server does NOT flag as
-- defensive. Negating both flags keeps a listed buff from ever rendering
-- twice should Blizzard flag it later.
local FILTER_EXTRA = "HELPFUL|!BIG_DEFENSIVE|!EXTERNAL_DEFENSIVE"

-- Defensive buffs Blizzard leaves unflagged, matched by BUFF spell ID
-- (the aura on the unit, not the ability that applies it). Matching is
-- done by the engine, so it works in combat and on party members too.
local EXTRA_DEFENSIVES = {
    [187827] = true,   -- Metamorphosis (Vengeance Demon Hunter)
}

local _containers = {}   -- unit -> AuraContainer
local _glowHosts  = {}   -- one per engine button, for glow restyles
local _eventFrame

-- Module switched off as a whole (listed as "Unavailable" in the settings)
-- while it is being reworked. The saved settings are untouched; set this
-- to false to bring the module back.
OVL.UNAVAILABLE = true

local function IsEnabled()
    if OVL.UNAVAILABLE then return false end
    return BIT.db and BIT.db.defensiveOverlayEnabled == true
end

local function GlowWanted()
    return BIT.db and BIT.db.defensiveOverlayGlow ~= false
end

-- Current content type. IsInInstance can hand back tainted values during
-- transitions, so it is pcall'd and anything unexpected counts as open world.
local function ContextKey()
    local ok, isInst, instType = pcall(IsInInstance)
    if ok and isInst then
        if instType == "party" then return "dungeon" end
        if instType == "raid"  then return "raid"    end
        if instType == "arena" then return "arena"   end
        if instType == "pvp"   then return "bg"      end
    end
    return "openworld"
end

-- Visibility settings (Defensives page). The checks mirror the defaults
-- in Core/Data.lua: dungeon / open world default ON (~= false), raid /
-- arena / battleground default OFF (== true). Outside an allowed context
-- the containers are switched off, so the engine does no aura work there.
local function ZoneAllowed()
    local db = BIT.db
    if not db then return true end
    local ctx = ContextKey()
    if ctx == "dungeon"   then return db.defensiveOverlayShowInDungeon   ~= false end
    if ctx == "raid"      then return db.defensiveOverlayShowInRaid      == true  end
    if ctx == "arena"     then return db.defensiveOverlayShowInArena     == true  end
    if ctx == "bg"        then return db.defensiveOverlayShowInBG        == true  end
    return db.defensiveOverlayShowInOpenWorld ~= false
end

local function IconSize()
    return (BIT.db and BIT.db.defensiveOverlaySize) or 26
end

------------------------------------------------------------------------
-- Overlay glow — self-contained, READ-FREE.
-- The shared glow libraries size their effect from the frame's rect and
-- check its visibility. On an engine aura button both come back as
-- secret values (even out of combat in restricted content), the math
-- throws and no glow appears. The overlay knows the icon size anyway (it
-- sets it), so the glow styles are drawn here from THAT number — nothing
-- is ever read from the button:
--   PIXEL     lines running round the icon (lines / length / thickness /
--             frequency from the Glow settings; negative = reverse)
--   AUTOCAST  small sparks travelling round the icon
--   BUTTON / PROC / default
--             soft additive glow ring (Blizzard's action-button glow
--             texture) with a gentle pulse
-- Motion is ENGINE-driven (AnimationGroups), never an OnUpdate: scripts
-- on frames under an aura button do not tick while auras are restricted,
-- which left an OnUpdate-driven glow frozen. Each edge holds a periodic
-- pattern of lines in a clipped strip; a looping Translation shifts the
-- pattern by exactly one period, so the reset is invisible and the lines
-- appear to run round the icon forever.
------------------------------------------------------------------------
local DEFAULT_GLOW = { 1.00, 0.82, 0.25 }   -- warm gold, like a proc glow
local SOFT_TEX     = "Interface\\Buttons\\UI-ActionButton-Border"

local function GlowColor()
    local db = BIT.db
    if db and db.partyCooldownsGlowCustom then
        if db.partyCooldownsGlowUseClassColor then
            local _, classFile = UnitClass("player")
            local cc = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
            if cc then return cc.r, cc.g, cc.b end
        end
        return db.partyCooldownsGlowColorR or 0.95,
               db.partyCooldownsGlowColorG or 0.95,
               db.partyCooldownsGlowColorB or 0.32
    end
    return DEFAULT_GLOW[1], DEFAULT_GLOW[2], DEFAULT_GLOW[3]
end

-- Effective style: the style picker only counts with "custom glow" on;
-- otherwise the soft default ring.
local function GlowStyle()
    local db = BIT.db
    if db and db.partyCooldownsGlowCustom then
        local st = db.partyCooldownsGlowStyle or "PIXEL"
        if st == "PIXEL" or st == "AUTOCAST" then return st end
    end
    return "SOFT"
end

local function GlowThickness()
    local t = BIT.db and BIT.db.partyCooldownsGlowThickness or 2
    if t < 1 then t = 1 elseif t > 10 then t = 10 end
    return t
end

local function GlowLines()
    local n = BIT.db and BIT.db.partyCooldownsGlowLines or 8
    if n < 1 then n = 1 elseif n > 20 then n = 20 end
    return math.floor(n)
end

local function GlowFrequency()
    return BIT.db and BIT.db.partyCooldownsGlowFrequency or 0.25
end

-- The four edge strips just outside the icon's 1px black border, clockwise.
-- x / y = strip TOPLEFT relative to the host for icon size s, thickness t;
-- dx / dy = direction the pattern moves on that edge.
local EDGES = {
    { horiz = true,  x = function(s, t) return -(1 + t) end, y = function(s, t) return 1 + t end,    dx =  1, dy =  0 }, -- top    →
    { horiz = false, x = function(s, t) return s + 1 end,    y = function(s, t) return 1 + t end,    dx =  0, dy = -1 }, -- right  ↓
    { horiz = true,  x = function(s, t) return -(1 + t) end, y = function(s, t) return -(s + 1) end, dx = -1, dy =  0 }, -- bottom ←
    { horiz = false, x = function(s, t) return -(1 + t) end, y = function(s, t) return 1 + t end,    dx =  0, dy =  1 }, -- left   ↑
}

-- (Re)apply style, colour, size and on/off to one glow host. Writes only.
local function PaintGlow(host)
    local r, g, b = GlowColor()
    local style   = GlowStyle()
    local s       = IconSize()
    host._soft:Hide()
    host._pulse:Stop()
    for _, e in ipairs(host._edges) do e.ag:Stop(); e.clip:Hide() end

    if not GlowWanted() then host:Hide(); return end
    host:Show()

    if style == "SOFT" then
        -- Blizzard's action-button glow ring, sized for a 36px button at
        -- ~1.9x; scaled with the icon. Pulse is an engine animation.
        host._soft:SetSize(s * 1.9, s * 1.9)
        host._soft:SetVertexColor(r, g, b, 1)
        host._soft:Show()
        host._pulse:Play()
        return
    end

    -- PIXEL: N lines round the whole ring; AUTOCAST: small square sparks.
    local t, n, len = GlowThickness(), GlowLines(), nil
    if style == "AUTOCAST" then
        t = t + 1
        n = math.max(4, n)
        len = t
    else
        len = BIT.db and BIT.db.partyCooldownsGlowLength
        if not len or len <= 0 then len = nil end
    end
    local L   = s + 2 + 2 * t          -- side length of the ring
    local G   = 4 * L / n              -- pattern period = spacing of the lines
    len = math.max(1, math.min(len or G * 0.5, G))

    -- Frequency = revolutions per second (negative = reverse). Shifting by
    -- one period takes 1 / (|f| * n) seconds.
    local f = GlowFrequency()
    if style == "AUTOCAST" and f == 0 then f = 0.25 end
    local dur  = (f ~= 0) and (1 / (math.abs(f) * n)) or nil
    local sign = (f < 0) and -1 or 1
    local count = math.ceil((L + 2 * G) / G) + 1

    for i, spec in ipairs(EDGES) do
        local e = host._edges[i]
        e.clip:ClearAllPoints()
        e.clip:SetPoint("TOPLEFT", host, "TOPLEFT", spec.x(s, t), spec.y(s, t))
        e.track:ClearAllPoints()
        if spec.horiz then
            e.clip:SetSize(L, t)
            e.track:SetPoint("TOPLEFT", e.clip, "TOPLEFT", -G, 0)
            e.track:SetSize(L + 2 * G, t)
        else
            e.clip:SetSize(t, L)
            e.track:SetPoint("TOPLEFT", e.clip, "TOPLEFT", 0, G)
            e.track:SetSize(t, L + 2 * G)
        end
        for k = 1, count do
            local tex = e.tex[k]
            if not tex then
                tex = e.track:CreateTexture(nil, "OVERLAY")
                e.tex[k] = tex
            end
            tex:ClearAllPoints()
            if spec.horiz then
                tex:SetPoint("TOPLEFT", e.track, "TOPLEFT", (k - 1) * G, 0)
                tex:SetSize(len, t)
            else
                tex:SetPoint("TOPLEFT", e.track, "TOPLEFT", 0, -(k - 1) * G)
                tex:SetSize(t, len)
            end
            tex:SetColorTexture(r, g, b, 1)
            tex:Show()
        end
        for k = count + 1, #e.tex do e.tex[k]:Hide() end
        e.clip:Show()
        if dur then
            e.move:SetOffset(spec.dx * G * sign, spec.dy * G * sign)
            e.move:SetDuration(dur)
            e.ag:Play()
        end
    end
end

local function BuildGlow(host)
    -- Soft ring (BUTTON / PROC / default) + its pulse.
    local soft = host:CreateTexture(nil, "OVERLAY")
    soft:SetTexture(SOFT_TEX)
    soft:SetBlendMode("ADD")
    soft:SetPoint("CENTER", host, "CENTER", 0, 0)
    soft:Hide()
    host._soft = soft
    local ag = host:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(1)
    a:SetToAlpha(0.55)
    a:SetDuration(0.7)
    a:SetSmoothing("IN_OUT")
    host._pulse = ag

    -- Running lines: per edge a clipping strip holding a moving track.
    host._edges = {}
    for i = 1, 4 do
        local clip = CreateFrame("Frame", nil, host)
        clip:SetClipsChildren(true)
        clip:EnableMouse(false)
        local track = CreateFrame("Frame", nil, clip)
        track:EnableMouse(false)
        local mg = track:CreateAnimationGroup()
        mg:SetLooping("REPEAT")
        local move = mg:CreateAnimation("Translation")
        move:SetSmoothing("NONE")
        host._edges[i] = { clip = clip, track = track, ag = mg, move = move, tex = {} }
    end

    PaintGlow(host)
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

local function GroupLayout()
    local s = IconSize()
    return { elementWidth = s, elementHeight = s,
             elementSpacing = ICON_GAP, lineSpacing = ICON_GAP }
end

-- Engine button initializer — the one window in which writes to the
-- button are guaranteed legal. Icon + 1px black border + a glow host
-- (our own child frame, so the glow can be restarted later without
-- touching the engine button).
local _buttons = {}       -- every engine button, for size restyles
local _resizePending = false

local function InitButton(button)
    -- The flow layout only ANCHORS group buttons; their physical size is
    -- ours to set (elementWidth/Height only feed the flow math). An
    -- unsized button renders nothing at all.
    local s = IconSize()
    pcall(button.SetSize, button, s, s)
    button._bitSize = s
    _buttons[#_buttons + 1] = button

    pcall(button.SetMouseClickEnabled, button, false)
    pcall(button.SetMouseMotionEnabled, button, false)

    local border = button:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0, 0, 0, 1)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(button)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Glow host: our own child frame covering the button, with the
    -- read-free glow built on it (it follows the button purely by anchor).
    local host = CreateFrame("Frame", nil, button)
    host:SetAllPoints(button)
    host:EnableMouse(false)
    BuildGlow(host)
    _glowHosts[#_glowHosts + 1] = host

    -- Register the icon LAST: SetIcon immediately runs the engine's
    -- display update against the regions created above.
    button:SetIcon(icon)
end

local function SetAnchorPoint(c, point)
    local f = c.SetFlowLayoutAnchorPoint or c.SetAuraLayoutAnchorPoint
    if f then pcall(f, c, point) end
end

local function SetGrowth(c)
    local FD = AnchorUtil and AnchorUtil.FlowDirection
    local f = c.SetFlowLayoutGrowthDirection or c.SetAuraLayoutGrowthDirection
    if FD and f then pcall(f, c, FD.Right, FD.Down) end
end

-- Container top-left = top-left of a single icon centered on the frame;
-- additional icons flow to the right.
local function Place(c, parent)
    local s    = IconSize()
    local offX = (BIT.db and BIT.db.defensiveOverlayOffsetX) or 0
    local offY = (BIT.db and BIT.db.defensiveOverlayOffsetY) or 0
    if c:GetParent() ~= parent then c:SetParent(parent) end
    c:ClearAllPoints()
    c:SetPoint("TOPLEFT", parent, "CENTER", -s / 2 + offX, s / 2 + offY)
    c:SetFrameLevel((parent:GetFrameLevel() or 0) + 20)
end

local function CreateContainer(unit, parent)
    if C_AddOns and not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
        pcall(C_AddOns.LoadAddOn, "Blizzard_AuraContainer")
    end
    local ok, c = pcall(CreateFrame, "AuraContainer", nil, parent, "CustomAuraContainerTemplate")
    if not ok or not c then return nil end

    -- Anchor + provisional size BEFORE declaring content: the engine lays
    -- out from an OnUpdate that needs a renderable rect.
    c:SetSize(1, 1)
    Place(c, parent)
    SetAnchorPoint(c, "TOPLEFT")
    SetGrowth(c)

    local okB = pcall(c.AddAuraGroup, c, "big", FILTER_BIG, {
        maxFrameCount = MAX_ICONS, layout = GroupLayout(), initializeFrame = InitButton,
    })
    local okE = pcall(c.AddAuraGroup, c, "ext", FILTER_EXT, {
        maxFrameCount = MAX_ICONS, layout = GroupLayout(), initializeFrame = InitButton,
    })
    local okX = pcall(c.AddAuraGroup, c, "extra", FILTER_EXTRA, {
        maxFrameCount = MAX_ICONS, layout = GroupLayout(), initializeFrame = InitButton,
        candidateFilters = { includeSpellIDs = EXTRA_DEFENSIVES },
    })
    if not (okB or okE or okX) then c:Hide(); return nil end
    c._bitGroups = { big = okB, ext = okE, extra = okX }

    c:SetUnit(unit)
    return c
end

local function Disable(c)
    if not c then return end
    pcall(c.SetEnabled, c, false)
    c:Hide()
end

local function UpdateUnit(unit)
    local c = _containers[unit]

    if not IsEnabled() then Disable(c); return end
    -- Content type switched off on the Defensives page: not just hidden,
    -- the container stops processing auras altogether.
    if not ZoneAllowed() then Disable(c); return end
    -- "Show own cooldowns" (Party CDs) governs the player slot here too:
    -- someone who switched their own icon row off does not want the same
    -- information glowing on their own unit frame instead.
    if unit == "player" and BIT.db and BIT.db.partyCooldownsShowOwn == false then
        Disable(c); return
    end

    local parent = UnitExists(unit) and GetAnchor(unit) or nil
    if not parent then Disable(c); return end

    if not c then
        c = CreateContainer(unit, parent)
        if not c then return end
        _containers[unit] = c
    else
        Place(c, parent)
    end
    c:Show()
    pcall(c.SetEnabled, c, true)
    pcall(c.UpdateAllAuras, c)
end

function OVL:RefreshAll()
    for _, unit in ipairs(UNITS) do
        UpdateUnit(unit)
    end
end

-- Live restyle for the settings sliders/toggles: new icon size goes in
-- through the container-level group layout, offsets through Place, and
-- the glow is restarted on every glow host.
-- Resize every engine button to the configured icon size. SetSize on an
-- aura button is denied while auras are secret (combat), so a change made
-- then is retried when combat ends.
local function ResizeButtons()
    local s = IconSize()
    if InCombatLockdown and InCombatLockdown() then
        _resizePending = true
        if _eventFrame then _eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") end
        return
    end
    _resizePending = false
    for _, b in ipairs(_buttons) do
        if b._bitSize ~= s and pcall(b.SetSize, b, s, s) then b._bitSize = s end
    end
end

function OVL:RefreshStyle()
    ResizeButtons()
    local layout = GroupLayout()
    for _, c in pairs(_containers) do
        if c._bitGroups then
            if c._bitGroups.big then pcall(c.SetAuraGroupLayout, c, "big", layout) end
            if c._bitGroups.ext then pcall(c.SetAuraGroupLayout, c, "ext", layout) end
            if c._bitGroups.extra then pcall(c.SetAuraGroupLayout, c, "extra", layout) end
        end
    end
    -- Glow: new colour / thickness / on-off on every host (writes only;
    -- the hosts follow the buttons' size by anchor).
    for _, host in ipairs(_glowHosts) do
        pcall(PaintGlow, host)
    end
    self:RefreshAll()
end

local function OnEvent(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        if _resizePending then ResizeButtons() end
        if not _resizePending and _eventFrame then _eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED") end
        return
    end
    -- GROUP_ROSTER_UPDATE / PLAYER_ENTERING_WORLD: members changed or
    -- frames re-resolved. Deferred a frame so unit-frame addons finish
    -- (re)building their frames first; aura changes themselves are the
    -- engine's job.
    C_Timer.After(0, function() OVL:RefreshAll() end)
    C_Timer.After(1, function() OVL:RefreshAll() end)
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
        _eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        _eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        _eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")   -- context gate
        self:RefreshAll()
    else
        if _eventFrame then _eventFrame:UnregisterAllEvents() end
        for _, c in pairs(_containers) do Disable(c) end
    end
end

-- ── Debug: /bitdef [unit] ────────────────────────────────────────────
-- Shows the overlay's state for a unit (enabled, own-slot gate, unit
-- frame, container) and — out of combat only, since the game blocks
-- addon aura reads in combat — every HELPFUL aura with the category
-- flags that decide whether the container shows it.
local function dbgFlag(unit, id, filter)
    local ok, out = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID, unit, id, filter)
    if not ok then return "|cffff8800err|r" end
    if out == false then return "|cff44ff44yes|r" end
    return "|cff777777no|r"
end

local function dbgName(aura)
    local sid = aura.spellId
    local okS, sec = pcall(issecretvalue, sid)
    if (okS and sec) or sid == nil then return "<secret>", nil end
    local okN, name = pcall(C_Spell.GetSpellName, sid)
    local okNS, nameSec = pcall(issecretvalue, name)
    if not okN or name == nil or (okNS and nameSec) then name = "?" end
    return name, sid
end

-- Glow summary. Nothing on the hosts is read (their visibility and rect
-- are secret on engine buttons); this reports what the glow is painted with.
local function DebugGlow(P)
    local r, g, b = GlowColor()
    print(P .. string.format("glow: on=%s  style=%s  colour=%.2f/%.2f/%.2f  thickness=%d  lines=%d  hosts=%d",
        tostring(GlowWanted() and true or false), GlowStyle(), r, g, b, GlowThickness(), GlowLines(), #_glowHosts))
end

function OVL:Debug(unit)
    unit = (unit and unit ~= "") and unit:lower() or "player"
    local P = "|cff0091edBIT|r |cFFAAAAAA[Defensives]|r "
    print(P .. "── " .. unit)
    if not UnitExists(unit) then print(P .. "unit does not exist") return end
    print(P .. "overlay enabled: " .. tostring(IsEnabled())
        .. "  context=" .. ContextKey() .. "  allowed here=" .. tostring(ZoneAllowed()))
    if unit == "player" and BIT.db and BIT.db.partyCooldownsShowOwn == false then
        print(P .. "|cffff4444own frame suppressed|r: Party CDs \"Show own cooldowns\" is OFF — the overlay follows it for the player slot")
    end
    local anchor = GetAnchor(unit)
    print(P .. "unit frame found: " .. (anchor and ("yes (" .. tostring(anchor:GetName() or "unnamed") .. ")") or "|cffff4444no|r"))
    local c = _containers[unit]
    if c then
        print(P .. "aura container: |cff44ff44active|r (groups big=" .. tostring(c._bitGroups and c._bitGroups.big)
            .. " ext=" .. tostring(c._bitGroups and c._bitGroups.ext)
            .. " extra=" .. tostring(c._bitGroups and c._bitGroups.extra) .. ")")
    else
        print(P .. "aura container: |cffff4444none|r")
    end

    DebugGlow(P)

    local inCombat = InCombatLockdown and InCombatLockdown()
    if inCombat then
        print(P .. "in combat: aura list not readable by addons (the container itself still works)")
        return
    end

    -- Container internals: rects and visibility under an aura container
    -- are SECRET values (reading them in a boolean test throws, even out
    -- of combat), so only plain counts are reported here.
    if c then
        local okK, n = pcall(function() return select("#", c:GetChildren()) end)
        print(P .. "engine buttons: " .. (okK and tostring(n) or "?")
            .. "  (sized " .. IconSize() .. "px, " .. #_buttons .. " initialised)")
    end

    local ok, list = pcall(C_UnitAuras.GetUnitAuras, unit, "HELPFUL")
    if not ok or type(list) ~= "table" then
        print(P .. "aura list not readable: " .. tostring(list))
        return
    end
    local n = 0
    for _, aura in ipairs(list) do
        local okRow, errRow = pcall(function()
            if aura and aura.auraInstanceID then
                n = n + 1
                local id = aura.auraInstanceID
                local big = dbgFlag(unit, id, FILTER_BIG)
                local ext = dbgFlag(unit, id, "HELPFUL|EXTERNAL_DEFENSIVE")
                local name, sid = dbgName(aura)
                local listed = sid and EXTRA_DEFENSIVES[sid]
                local shown = (big:find("yes") or ext:find("yes") or listed) and "|cff44ff44SHOWN|r" or "-"
                if listed then shown = shown .. " (extra list)" end
                print(string.format("  %s (%s)  BIG=%s EXT=%s  -> %s",
                    name, sid and tostring(sid) or "?", big, ext, shown))
            end
        end)
        if not okRow then print("  <aura row error> " .. tostring(errRow)) end
    end
    if n == 0 then print(P .. "no helpful auras") end
end

SLASH_BITDEF1 = "/bitdef"
SlashCmdList["BITDEF"] = function(msg) OVL:Debug(strtrim(msg or "")) end

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
