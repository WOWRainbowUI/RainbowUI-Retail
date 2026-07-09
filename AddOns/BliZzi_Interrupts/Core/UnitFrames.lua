-- Copyright (c) 2026 BliZzi1337. All rights reserved.
--[[
    UnitFrames.lua - BliZzi_Interrupts
    ─────────────────────────────────────────────────────────
    Shared unit-frame resolver. Given a unit token (player, party1..4)
    returns the on-screen frame currently displaying that unit, picking
    between the Blizzard frames and the most common third-party party
    addons (ElvUI, EllesmereUI, NDui, Cell, Grid2, ShadowedUnitFrames,
    Danders / D4, EnhanceQoL, VuhDo, and Mich's RaidFrames).

    Lives at Core/ level because three different features need it:
      • Interrupt Tracker — "attached to unit frames" display mode
      • PI Caller — border + glow overlays on party-member frames
      • Party Cooldowns — defensive-CD icons attached per-member

    Public API:
      BIT.UnitFrames:GetPartyFrame(unit, providerOverride)
         -> on-screen frame, or nil if no provider matched
      BIT.UnitFrames:GetAvailableProviders()
         -> list of { value, label } entries for settings dropdowns
      BIT.UnitFrames:CountFrameAddons()
         -> number of detected 3rd-party providers (>1 = ambiguous,
            useful for a first-run "which one do you use?" prompt)

    Provider precedence in AUTO mode (first match wins):
      ElvUI → EllesmereUI → NDui → Danders → Cell → Grid2 → EnhanceQoL → SUF → VuhDo → Mich's → Blizzard
    This order tries the most opinionated / replacement-style addons
    first because users running those almost always want them as the
    anchor target, with Blizzard as the always-present fallback.

    Each provider's IsXxxActive() probe is a cheap global check; the
    Find functions return nil immediately when their provider isn't
    loaded so a full AUTO sweep is essentially free in the common
    "only one frame addon loaded" case.
    ─────────────────────────────────────────────────────────
]]

BIT = BIT or {}
BIT.UnitFrames = BIT.UnitFrames or {}

------------------------------------------------------------
-- Provider activation probes
--
-- Each function returns true when the corresponding party-frame addon
-- has loaded AND created its top-level container global. We deliberately
-- check the FRAME globals (not just IsAddOnLoaded) because some addons
-- can be present in the addon list but not actually displaying party
-- frames yet (e.g. before the first PLAYER_LOGIN tick after a /reload).
------------------------------------------------------------
local function IsElvUIActive()
    return _G["ElvUI"] ~= nil or _G["ElvUF_PartyGroup1"] ~= nil
end

local function IsDandersActive()
    return _G["DandersPartyHeader"] ~= nil
end

local function IsGrid2Active()
    return _G["Grid2LayoutFrame"] ~= nil
end

local function IsCellActive()
    return _G["Cell"] ~= nil
end

local function IsEnhanceQOLActive()
    if _G["EQOLUFPartyHeader"] ~= nil then return true end
    if _G["EQOLUFPartyHeaderUnitButton1"] ~= nil then return true end
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("EnhanceQoL") then
        return true
    end
    return false
end

local function IsSUFActive()
    -- ShadowedUnitFrames creates SUFHeaderparty as the party header and
    -- SUFUnitplayer as the standalone player frame. Either present means
    -- SUF is loaded and has initialised its frames.
    return _G["SUFHeaderparty"] ~= nil or _G["SUFUnitplayer"] ~= nil
end

local function IsMichsActive()
    -- Mich's RaidFrames creates MRF_PartyHeader for party content and
    -- MRF_RaidHeader1..8 (one per raid sub-group). The presence of any
    -- of these globals means the addon has loaded and spawned its
    -- SecureGroupHeaderTemplate-based headers.
    if _G["MRF_PartyHeader"] ~= nil then return true end
    for i = 1, 8 do
        if _G["MRF_RaidHeader" .. i] ~= nil then return true end
    end
    return false
end

local function IsVuhDoActive()
    -- VuhDo names each health-bar unit button Vd<panel>H<n> (e.g. Vd1H1),
    -- parented to its panel frame Vd<panel>. The first button of panel 1 is
    -- the cheapest "frames are up" probe; fall back to the addon-loaded
    -- check so the provider still lists in settings before panels render.
    if _G["Vd1H1"] ~= nil then return true end
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("VuhDo") then
        return true
    end
    return false
end

local function IsNDuiActive()
    -- NDui bundles its own embedded oUF and spawns plainly-prefixed globals
    -- (oUF_Player, oUF_Party, oUF_Raid1..8). Those names are generic to ANY
    -- bare-oUF layout, so confirm NDui itself is loaded before trusting them —
    -- this stops a non-NDui oUF profile from being mislabelled as "NDui".
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("NDui") then
        return true
    end
    return _G["NDui"] ~= nil
end

local function IsEllesmereActive()
    -- EllesmereUI uses SEPARATE headers for party vs raid:
    --   • Party (5-man): ERFPartyHeader (SecureGroupHeader, party1-4 +
    --     player) plus a static ERFPartySelfButton (unit=player, used with
    --     "Show Self First").
    --   • Raid: ERFFlatHeader (merged) and ERFGroupHeader1..8 (separated).
    -- Its standalone player frame (oUF) is EllesmereUIUnitFrames_Player.
    if _G["ERFPartyHeader"] ~= nil or _G["ERFFlatHeader"] ~= nil or _G["ERFGroupHeader1"] ~= nil then return true end
    if _G["EllesmereUIUnitFrames_Player"] ~= nil then return true end
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        if C_AddOns.IsAddOnLoaded("EllesmereUIRaidFrames")
           or C_AddOns.IsAddOnLoaded("EllesmereUIUnitFrames") then
            return true
        end
    end
    return false
end

------------------------------------------------------------
-- Frame helpers
------------------------------------------------------------

-- Visibility short-circuit: a frame that isn't visible right now isn't
-- a valid anchor target even if its unit attribute matches (e.g. ElvUI
-- often has both party AND raid headers alive simultaneously, only one
-- is on-screen at a time).
local function visible(f) return f and f:IsVisible() end

-- Read a frame's bound unit. Secure-header children set their unit via
-- SetAttribute("unit", ...); we prefer that over the .unit table field
-- because the attribute survives child recycling on roster changes. The
-- pcall is needed because GetAttribute can throw on tainted handlers in
-- 12.0.5 secure-frame edge cases.
local function GetFrameUnit(btn)
    if not btn then return nil end
    local u
    if btn.GetAttribute then
        local ok, val = pcall(btn.GetAttribute, btn, "unit")
        if ok then u = val end
    end
    if (not u or u == "") and btn.unit then u = btn.unit end
    if type(u) ~= "string" or u == "" then return nil end
    return u
end

-- Generic numbered-button scan. Iterates "<prefix>1" through "<prefix>N"
-- and returns the first child whose unit matches.
-- 12.0.5 note: we compare unit strings directly instead of calling
-- UnitIsUnit() — in Midnight that API can return a tainted boolean when
-- one side is a secret value, which throws as soon as the bool is
-- evaluated in an `if`. Direct string compare side-steps the issue,
-- and since each header child is bound to a single fixed unit slot the
-- alias resolution UnitIsUnit() would do isn't needed here.
local function ScanUnitButtons(prefix, unit, maxSlots)
    for i = 1, maxSlots do
        local btn = _G[prefix .. i]
        if btn and GetFrameUnit(btn) == unit then return btn end
    end
end

-- Grid2 lays out frames in multiple headers when used in raids. Walk
-- a small number of headers (1..8 covers up to 40-man raid groups) and
-- look for the unit in each.
local function ScanGrid2(unit)
    for h = 1, 8 do
        local f = ScanUnitButtons("Grid2LayoutHeader" .. h .. "UnitButton", unit, 40)
        if f then return f end
    end
end

------------------------------------------------------------
-- Provider-specific finders
--
-- Each returns the active on-screen frame for the given unit, or nil
-- if the provider isn't loaded / the unit isn't currently rendered by
-- that provider.
------------------------------------------------------------

local function FindElvUI(unit)
    if not IsElvUIActive() then return nil end
    -- Preferred path: walk the actual on-screen header children. Compared
    -- to the legacy `oUF.units[unit]` table this is robust to ElvUI
    -- spawning multiple frames (party + raid headers simultaneously) —
    -- the visible-filter picks whichever is currently rendered.
    local group = _G["ElvUF_PartyGroup1"]
    if group then
        for i = 1, group:GetNumChildren() do
            local child = select(i, group:GetChildren())
            if visible(child) and GetFrameUnit(child) == unit then
                return child
            end
        end
    end
    if unit == "player" then
        local pf = _G["ElvUF_Player"]
        if visible(pf) then return pf end
    end
    local f = ScanUnitButtons("ElvUF_PartyGroup1UnitButton", unit, 5)
    if visible(f) then return f end
end

local function FindDanders(unit)
    if not IsDandersActive() then return nil end
    local f = ScanUnitButtons("DandersPartyHeaderUnitButton", unit, 5)
    if visible(f) then return f end
    if unit == "player" then
        local playerBtn = _G["DandersPartyHeaderUnitButton0"] or _G["DandersPlayerFrame"]
        if visible(playerBtn) then return playerBtn end
    end
end

local function FindGrid2(unit)
    if not IsGrid2Active() then return nil end
    local f = ScanGrid2(unit)
    if visible(f) then return f end
end

local function FindEnhanceQOL(unit)
    if not IsEnhanceQOLActive() then return nil end
    local f = ScanUnitButtons("EQOLUFPartyHeaderUnitButton", unit, 5)
    if visible(f) then return f end
    if unit == "player" then
        local pf = _G["EQOLUFPlayerFrame"] or _G["EQOLUFPartyHeaderUnitButton0"]
        if visible(pf) then return pf end
    end
end

local function FindSUF(unit)
    if not IsSUFActive() then return nil end
    local f = ScanUnitButtons("SUFHeaderpartyUnitButton", unit, 5)
    if visible(f) then return f end
    if unit == "player" then
        local pf = _G["SUFUnitplayer"]
        if visible(pf) then return pf end
    end
end

-- Mich's RaidFrames uses SecureGroupHeaderTemplate to spawn its unit
-- buttons, same pattern as ElvUI's oUF-based headers. Children get a
-- `.unit` field set via OnAttributeChanged when SecureGroupHeader binds
-- them to a slot. We iterate header children rather than scanning a
-- numbered global prefix because the SecureGroupHeader names children
-- dynamically (no stable global like `MRF_PartyButton1`).
local function FindMichs(unit)
    if not IsMichsActive() then return nil end
    -- Party context: single header MRF_PartyHeader covers player + party1..4.
    local partyHeader = _G["MRF_PartyHeader"]
    if partyHeader and visible(partyHeader) then
        for i = 1, partyHeader:GetNumChildren() do
            local child = select(i, partyHeader:GetChildren())
            if visible(child) and GetFrameUnit(child) == unit then
                return child
            end
        end
    end
    -- Raid context: one header per sub-group, MRF_RaidHeader1..8 (8 groups
    -- of 5 = up to 40-man). When the user is in a raid layout the party
    -- header is hidden and the raid headers light up — we walk all of
    -- them so the same finder works in both contexts.
    for g = 1, 8 do
        local raidHeader = _G["MRF_RaidHeader" .. g]
        if raidHeader and visible(raidHeader) then
            for i = 1, raidHeader:GetNumChildren() do
                local child = select(i, raidHeader:GetChildren())
                if visible(child) and GetFrameUnit(child) == unit then
                    return child
                end
            end
        end
    end
end

-- VuhDo's health-bar unit buttons are named Vd<panel>H<n> (e.g. Vd1H1),
-- parented to their panel frame Vd<panel>. Each is a secure button with
-- its unit bound via the "unit" attribute (used for click-casting), so
-- GetFrameUnit reads it the same way as the header-based providers. We
-- sweep up to 10 panels; within a panel the buttons are contiguous, so a
-- nil button ends that panel's scan early. Panels that don't exist are
-- skipped outright.
local function FindVuhDo(unit)
    if not IsVuhDoActive() then return nil end
    for panel = 1, 10 do
        if _G["Vd" .. panel] then
            for btn = 1, 40 do
                local f = _G["Vd" .. panel .. "H" .. btn]
                if not f then break end  -- end of this panel's button range
                if visible(f) and GetFrameUnit(f) == unit then return f end
            end
        end
    end
end

-- EllesmereUI uses SecureGroupHeaderTemplate headers (same pattern as
-- Mich's / ElvUI). Children bind their unit via the secure header, so we
-- walk header children and read the unit attribute. CRUCIAL: party and
-- raid use DIFFERENT headers — a 5-man party renders in ERFPartyHeader
-- (NOT the raid ERFGroupHeader/ERFFlatHeader, which only light up in an
-- actual raid). The player in party mode may be a header child OR sit on
-- the static ERFPartySelfButton (used with EllesmereUI's "Show Self
-- First"). Scanning only the raid headers anchored self (via the oUF
-- fallback) but never party members — the bug this path fixes.
local function _scanHeaderChildren(header, unit)
    if not (header and visible(header)) then return nil end
    for i = 1, header:GetNumChildren() do
        local child = select(i, header:GetChildren())
        if visible(child) and GetFrameUnit(child) == unit then return child end
    end
end

local function FindEllesmere(unit)
    if not IsEllesmereActive() then return nil end
    -- Party (5-man): static self button first (it owns the player slot
    -- when "Show Self First" is on), then the party header children.
    if unit == "player" then
        local selfBtn = _G["ERFPartySelfButton"]
        if visible(selfBtn) and GetFrameUnit(selfBtn) == "player" then return selfBtn end
    end
    local f = _scanHeaderChildren(_G["ERFPartyHeader"], unit)
    if f then return f end
    -- Raid: merged flat header, or one header per sub-group.
    f = _scanHeaderChildren(_G["ERFFlatHeader"], unit)
    if f then return f end
    for g = 1, 8 do
        f = _scanHeaderChildren(_G["ERFGroupHeader" .. g], unit)
        if f then return f end
    end
    -- Standalone player unit frame fallback.
    if unit == "player" then
        local pf = _G["EllesmereUIUnitFrames_Player"]
        if visible(pf) then return pf end
    end
end

-- NDui spawns SecureGroupHeader-based group frames via its embedded oUF:
-- the party header oUF_Party (party1-4, plus the player when NDui's "show
-- player in party" option is on) and one header per raid sub-group,
-- oUF_Raid1..8. The standalone player frame is oUF_Player. Header children
-- bind their unit via the secure header, so we read the unit attribute the
-- same way as the other header-based providers (EllesmereUI / Mich's).
local function FindNDui(unit)
    if not IsNDuiActive() then return nil end
    -- Party (5-man): single oUF_Party header.
    local f = _scanHeaderChildren(_G["oUF_Party"], unit)
    if f then return f end
    -- Raid: one header per sub-group, oUF_Raid1..8.
    for g = 1, 8 do
        f = _scanHeaderChildren(_G["oUF_Raid" .. g], unit)
        if f then return f end
    end
    -- Standalone player frame fallback (player is its own big frame by default).
    if unit == "player" then
        local pf = _G["oUF_Player"]
        if visible(pf) then return pf end
    end
end

local function FindCell(unit)
    if not IsCellActive() then return nil end
    local header = _G["CellPartyFrameHeader"]
    if header and header:IsVisible() then
        local f = ScanUnitButtons("CellPartyFrameHeaderUnitButton", unit, 5)
        if visible(f) then return f end
    end
    if unit == "player" then
        local solo = _G["CellSoloFramePlayer"]
        if visible(solo) then return solo end
    end
end

local function FindBlizzard(unit)
    -- Newer "PartyFrame" container (Edit Mode classic party layout).
    -- Member1..4 cover party1..4 — player is on PlayerFrame separately.
    local pf = _G["PartyFrame"]
    if pf then
        for i = 1, 4 do
            local f = pf["MemberFrame" .. i]
            if visible(f) and GetFrameUnit(f) == unit then return f end
        end
    end
    -- Compact party (raid-style toggle off). Member1..5 includes player
    -- as the first slot, party1..4 as the rest.
    for i = 1, 5 do
        local f = _G["CompactPartyFrameMember" .. i]
        if visible(f) and GetFrameUnit(f) == unit then return f end
    end
    -- Compact raid container — when raid-style is on, party frames live
    -- inside the raid container as CompactRaidFrame1..N globals.
    for i = 1, 40 do
        local f = _G["CompactRaidFrame" .. i]
        if visible(f) and GetFrameUnit(f) == unit then return f end
    end
    -- Standalone player frame fallback (works in both layouts).
    if unit == "player" then
        local bf = _G["PlayerFrame"]
        if visible(bf) then return bf end
    end
end

------------------------------------------------------------
-- AUTO detection — ordered priority
------------------------------------------------------------
local function FindAuto(unit)
    return FindElvUI(unit)
        or FindEllesmere(unit)
        or FindNDui(unit)
        or FindDanders(unit)
        or FindCell(unit)
        or FindGrid2(unit)
        or FindEnhanceQOL(unit)
        or FindSUF(unit)
        or FindVuhDo(unit)
        or FindMichs(unit)
        or FindBlizzard(unit)
end

-- Forced-provider modes always fall back to Blizzard if the chosen
-- provider can't resolve the unit (e.g. user picked ElvUI but is
-- currently in a context where ElvUI's frames are hidden). The fallback
-- means the icons keep rendering instead of silently disappearing.
local PROVIDER_FINDERS = {
    ELVUI       = function(unit) return FindElvUI(unit)       or FindBlizzard(unit) end,
    ELLESMERE   = function(unit) return FindEllesmere(unit)   or FindBlizzard(unit) end,
    NDUI        = function(unit) return FindNDui(unit)        or FindBlizzard(unit) end,
    DANDERS     = function(unit) return FindDanders(unit)     or FindBlizzard(unit) end,
    CELL        = function(unit) return FindCell(unit)        or FindBlizzard(unit) end,
    GRID2       = function(unit) return FindGrid2(unit)       or FindBlizzard(unit) end,
    ENHANCEQOL  = function(unit) return FindEnhanceQOL(unit)  or FindBlizzard(unit) end,
    SUF         = function(unit) return FindSUF(unit)         or FindBlizzard(unit) end,
    VUHDO       = function(unit) return FindVuhDo(unit)       or FindBlizzard(unit) end,
    MICHS       = function(unit) return FindMichs(unit)       or FindBlizzard(unit) end,
    BLIZZARD    = FindBlizzard,
    AUTO        = FindAuto,
}

------------------------------------------------------------
-- Party-frame CONTAINER resolver
--
-- Unlike GetPartyFrame (which returns a single member's button), this
-- returns the whole party-frame container/header for a provider — used to
-- anchor the standalone Interrupt Tracker block as one unit so it travels
-- with the party frames. AUTO sweeps the same priority order and returns
-- the first container that's currently on screen.
------------------------------------------------------------
local CONTAINER_GETTERS = {
    ELVUI      = function() return _G["ElvUF_PartyGroup1"] end,
    -- EllesmereUI: party and raid headers coexist (one hidden). Return the
    -- first VISIBLE one — a plain `or` chain would stop at a hidden party
    -- header in raids and miss the live raid header.
    ELLESMERE  = function()
        for _, n in ipairs({ "ERFPartyHeader", "ERFFlatHeader", "ERFGroupHeader1" }) do
            local f = _G[n]
            if f and f:IsVisible() then return f end
        end
        return _G["EllesmereUIRaidFrameContainer"]
    end,
    -- NDui: party header in a party, first visible raid header otherwise.
    NDUI       = function()
        local p = _G["oUF_Party"]
        if p and p:IsVisible() then return p end
        for g = 1, 8 do
            local r = _G["oUF_Raid" .. g]
            if r and r:IsVisible() then return r end
        end
        return nil
    end,
    DANDERS    = function() return _G["DandersPartyHeader"] end,
    CELL       = function() return _G["CellPartyFrameHeader"] end,
    GRID2      = function() return _G["Grid2LayoutFrame"] end,
    ENHANCEQOL = function() return _G["EQOLUFPartyHeader"] end,
    SUF        = function() return _G["SUFHeaderparty"] end,
    VUHDO      = function() return _G["Vd1"] end,
    MICHS      = function() return _G["MRF_PartyHeader"] end,
    BLIZZARD   = function() return _G["CompactPartyFrame"] or _G["PartyFrame"] end,
}
local CONTAINER_AUTO_ORDER = {
    "ELVUI", "ELLESMERE", "NDUI", "DANDERS", "CELL", "GRID2",
    "ENHANCEQOL", "SUF", "VUHDO", "MICHS", "BLIZZARD",
}

local function _resolveContainer(key)
    local g = CONTAINER_GETTERS[key]
    local f = g and g()
    if visible(f) then return f end
    return nil
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------

-- Resolve the party-frame container for a provider. Forced providers fall
-- back to Blizzard's container when theirs isn't on screen; AUTO sweeps.
function BIT.UnitFrames:GetPartyContainer(provider)
    provider = provider or "AUTO"
    if provider ~= "AUTO" then
        return _resolveContainer(provider) or _resolveContainer("BLIZZARD")
    end
    for _, key in ipairs(CONTAINER_AUTO_ORDER) do
        local f = _resolveContainer(key)
        if f then return f end
    end
    return nil
end

-- Resolve a unit token to its on-screen frame.
-- providerOverride is the caller's choice of provider ("AUTO" / "ELVUI"
-- / etc.); pass nil to let the caller's default kick in. The caller
-- typically reads its own DB key (e.g. partyCooldownsProvider) and
-- passes that through, so different features can have different
-- provider preferences if the user wants.
function BIT.UnitFrames:GetPartyFrame(unit, providerOverride)
    if not unit then return nil end
    local provider = providerOverride or "AUTO"
    local finder   = PROVIDER_FINDERS[provider] or FindAuto
    return finder(unit)
end

-- Returns the list of provider options that make sense to expose in a
-- settings dropdown. AUTO + Blizzard are always present; third-party
-- providers are only listed when their addon is currently loaded.
function BIT.UnitFrames:GetAvailableProviders()
    local list = { { value = "AUTO", label = "Auto Detect" } }
    if IsElvUIActive()      then list[#list + 1] = { value = "ELVUI",      label = "ElvUI" }        end
    if IsEllesmereActive()  then list[#list + 1] = { value = "ELLESMERE",  label = "EllesmereUI" }  end
    if IsNDuiActive()       then list[#list + 1] = { value = "NDUI",       label = "NDui" }         end
    if IsDandersActive()    then list[#list + 1] = { value = "DANDERS",    label = "D4 / Danders" } end
    if IsCellActive()       then list[#list + 1] = { value = "CELL",       label = "Cell" }         end
    if IsGrid2Active()      then list[#list + 1] = { value = "GRID2",      label = "Grid2" }        end
    if IsEnhanceQOLActive() then list[#list + 1] = { value = "ENHANCEQOL", label = "EnhanceQoL" }   end
    if IsSUFActive()        then list[#list + 1] = { value = "SUF",        label = "ShadowedUF" }   end
    if IsVuhDoActive()      then list[#list + 1] = { value = "VUHDO",      label = "VuhDo" }        end
    if IsMichsActive()      then list[#list + 1] = { value = "MICHS",      label = "Mich's RaidFrames" } end
    list[#list + 1] = { value = "BLIZZARD", label = "Blizzard" }
    return list
end

-- Count of detected 3rd-party providers. Mainly useful for a first-run
-- "you have N party-frame addons loaded, which one should we use?"
-- prompt to surface the choice before the user wonders why icons are
-- anchored to the wrong addon.
function BIT.UnitFrames:CountFrameAddons()
    local n = 0
    if IsElvUIActive()      then n = n + 1 end
    if IsEllesmereActive()  then n = n + 1 end
    if IsNDuiActive()       then n = n + 1 end
    if IsDandersActive()    then n = n + 1 end
    if IsCellActive()       then n = n + 1 end
    if IsGrid2Active()      then n = n + 1 end
    if IsEnhanceQOLActive() then n = n + 1 end
    if IsSUFActive()        then n = n + 1 end
    if IsVuhDoActive()      then n = n + 1 end
    if IsMichsActive()      then n = n + 1 end
    return n
end
