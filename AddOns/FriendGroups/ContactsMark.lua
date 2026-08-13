-- ============================================================================
--  ContactsMark.lua
--  The FriendGroups mark in the empty band above the Contacts sub-tab strip.
--
--  Blizzard fills the top-left of FriendsFrame with a portrait ring, and the
--  addon writes its own logo into it (Platform_SocialUI, [[PORTRAIT]]). Every UI
--  suite that reskins that window removes the ring, and what it leaves behind is
--  a band of dead space: above the Friends / Recent Allies / Recruit A Friend
--  strip, left of the status dropdown, with nothing in it. The mark goes there
--  instead, drawn flat -- no ring and no black backing disc, because the mark is
--  transparent around the glyph and a dark window is exactly the backing it
--  wants.
--
--  Written for EllesmereUI first, inside EllesmereSkin.lua. This file is that
--  geometry lifted out so a SECOND suite can use it without a second copy of the
--  numbers: EllesmereSkin.lua calls Mark.Create for its mark, and the ElvUI
--  driver at the bottom of this file calls it for ElvUI's. A tweak to the pixel
--  conversion or the asset now moves both, which is the whole point of the split.
--
--  Loaded BEFORE EllesmereSkin.lua -- it only defines functions, so the position
--  costs nothing -- and listed in FriendGroups.toc alone. Retail-only for the
--  same reason the EllesmereUI skin is: no Classic flavor has FriendsTabHeader's
--  sub-tab strip to hang this off.
-- ============================================================================

local addonName, addonTable = ...
local Compat = addonTable.Compat

local Mark = {}
addonTable.ContactsMark = Mark
_G.FriendGroupsContactsMark = Mark

-- The same asset the TOC declares as IconTexture and Platform_SocialUI writes to
-- the portrait, so the two never disagree about what the addon's mark is.
Mark.TEXTURE = "Interface\\AddOns\\FriendGroups\\Textures\\fg"
Mark.SIZE    = 34

-- Game pixels -> UI units, in the coordinate space `frame` is positioned in.
--
-- SetPoint takes UI units and a screenshot is measured in pixels, and the two are only the
-- same number on a pixel-perfect UI scale. The UI's coordinate space is 768 units tall at
-- scale 1, so one unit is (screenHeight / 768) * scale pixels: 1.0 at 1080p with the scale
-- slider at 0.71, but ~1.9 at 1440p with it at 1.0. That factor is why a 12-unit nudge
-- travelled about 23 pixels. The frame's OWN effective scale is used, not UIParent's, so a
-- suite that scales the contact window is accounted for too.
function Mark.GamePixels(frame, px)
    local _, screenHeight = GetPhysicalScreenSize()
    local scale = frame:GetEffectiveScale()
    if not screenHeight or screenHeight <= 0 or not scale or scale <= 0 then return px end

    return px * 768 / (screenHeight * scale)
end

-- The first button of Blizzard's sub-tab strip, or nil while the strip is unbuilt.
--
-- ENUMERATED rather than named: TabSystem's children are anonymous, and both suites
-- restyle them in place, so "the first Button under TabSystem" is the only description
-- that survives a build which renames or re-orders them. Same walk EllesmereSkin's
-- SkinSubTabs does.
function Mark.FirstSubTab()
    local header = _G.FriendsTabHeader
    local system = header and header.TabSystem
    if not system then return nil end

    for i = 1, select("#", system:GetChildren()) do
        local st = select(i, system:GetChildren())
        if st and st.IsObjectType and st:IsObjectType("Button") then return st end
    end
    return nil
end

-- Anchored to the FIRST sub-tab rather than to the window corner, so its place in the band
-- holds at any width (FriendGroups_UpdateSize grows the window by up to 150px) and moves
-- with the strip if a future build re-lays the header out.
--
-- The offsets are in DIFFERENT terms on purpose. x and y are plain unit offsets. lift is a
-- correction measured off the rendered window in GAME PIXELS and converted here -- so the
-- raise out of the tab strip is the distance that was actually measured on screen, on any
-- UI scale, rather than that number of units.
function Mark.Place(holder, anchor, x, y, lift)
    holder:ClearAllPoints()
    holder:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", x, y + Mark.GamePixels(holder, lift))
end

-- A child FRAME carrying the texture, not a texture on the parent: StripTextures enumerates
-- a frame's own regions, and every suite skin (plus EllesmereUIFriends) runs one of those
-- over FriendsTabHeader. A region there would be blanked by the next pass.
function Mark.Create(parent, anchor, x, y, lift)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(Mark.SIZE, Mark.SIZE)
    -- Placed after parenting: the holder's effective scale means nothing before that, and
    -- the lift is computed from it.
    Mark.Place(holder, anchor, x, y, lift)

    local tex = holder:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture(Mark.TEXTURE)
    holder.texture = tex

    -- Decoration only. The gear at the other end of this band owns the menu, and a second
    -- mouse-enabled frame here would only eat clicks meant for the window drag.
    holder:EnableMouse(false)

    return holder
end

-- ---------------------------------------------------------------------------
--  ElvUI driver
--
--  ElvUI's Friends skin (ElvUI/Game/Mainline/Skins/Friends.lua) runs
--  S:HandlePortraitFrame over FriendsFrame, which alpha-zeroes the portrait, and
--  hides FriendsFrameIcon outright. It puts nothing back, so the band is the same
--  hole EllesmereUI leaves -- and it keeps FriendsTabHeader.TabSystem's buttons
--  (it skins them with S:HandleTab), so the anchor this mark needs is still there.
--
--  There is no ElvUI API call here and no colour taken from it. The mark is the
--  addon's own asset dropped into space ElvUI vacated, so nothing to fight over
--  and nothing to keep in sync with their media settings.
-- ---------------------------------------------------------------------------
local ELV_ADDON = "ElvUI"
local EUI_ADDON = "EllesmereUI"

-- Offsets from the first sub-tab's TOPLEFT. Deliberately the same three numbers
-- EllesmereSkin tuned against the live window: the band is Blizzard's own layout, not
-- either suite's, so the hole is in the same place in both. Tune with `/fg mark`.
local ELV_X      = 35     -- UI units, right of the tab's left edge
local ELV_Y      = -7     -- UI units, below the tab's top edge
local ELV_Y_LIFT = 11     -- GAME PIXELS to raise it out of the tab strip

local elvMark
local elvHidden = false

-- Idempotent: called on every open of the window, and returns on the first line once the
-- mark exists. Cheap enough that "which open is the one that needed it" never has to be
-- reasoned about -- the same call shape EllesmereSkin's ApplySkin uses.
local function EnsureElvMark()
    if elvMark then return end
    -- The 12.1 Social UI has its own portrait path and its own frame; this decorates the
    -- legacy panel's header and would anchor to nothing there.
    if Compat.IsSocialUIActive and Compat.IsSocialUIActive() then return end

    local frame = _G.FriendsFrame
    local header = _G.FriendsTabHeader
    local firstTab = Mark.FirstSubTab()
    if type(frame) ~= "table" or not header or not firstTab then return end

    -- MEASURED, not inferred from "is ElvUI loaded". A user can run ElvUI with its
    -- Blizzard skins off, or with just the Friends skin off, and then Blizzard's portrait
    -- ring is still there carrying our mark already -- a second copy of it one row below
    -- would read as a bug. Re-tested on each open until it passes, so whichever order the
    -- two addons settle in, the next open corrects it.
    if not (Compat.PortraitIsSuppressed and Compat.PortraitIsSuppressed(frame)) then return end

    elvMark = Mark.Create(header, firstTab, ELV_X, ELV_Y, ELV_Y_LIFT)
    if elvHidden then elvMark:Hide() end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded
    if not loaded or not loaded(ELV_ADDON) then return end

    -- EllesmereSkin.lua draws this same mark for the EllesmereUI suite, from the same
    -- factory and into the same band. Only one of them may run or the band gets two.
    -- Gated on the ADDON rather than on FriendGroupsEUISkin.enabled, which is not resolved
    -- until that file's own PLAYER_LOGIN handler runs and would make this depend on the
    -- order two handlers happen to fire in.
    if loaded(EUI_ADDON) then return end

    local frame = _G.FriendsFrame
    if not frame then return end

    -- Deferred a frame: ElvUI skins the window from its own load path, and the sub-tab
    -- strip this anchors to is not necessarily built when the first OnShow fires.
    local function Apply() C_Timer.After(0, EnsureElvMark) end

    frame:HookScript("OnShow", Apply)
    if frame:IsShown() then Apply() end
end)

-- ---------------------------------------------------------------------------
--  /fg mark -- live tuning
--
--  The three offsets above were measured against one window on one UI scale. Rather than
--  ship a reload cycle per nudge, this moves the mark in place and prints the numbers back
--  in the exact form they are written in this file, so a good position can be reported and
--  baked in.
--
--  SESSION ONLY, deliberately. Persisting it would mean a SavedVariable, a Sync.lua key and
--  a settings entry for what is a two-line constant once the number is known.
-- ---------------------------------------------------------------------------
function Mark.Command(msg)
    local rest = (msg or ""):match("^%s*%S+%s*(.-)%s*$") or ""

    local args = {}
    for tok in rest:gmatch("%S+") do args[#args + 1] = tok end

    local function Report()
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "FriendGroups mark -- x=%s y=%s lift=%s  (mark=%s elvui=%s)",
            tostring(ELV_X), tostring(ELV_Y), tostring(ELV_Y_LIFT),
            elvMark and (elvMark:IsShown() and "shown" or "hidden") or "none",
            tostring(C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(ELV_ADDON) or false)))
        DEFAULT_CHAT_FRAME:AddMessage("  /fg mark <x> <y> [lift]  |  /fg mark on  |  /fg mark off")
    end

    if #args == 0 then
        -- No arguments is a READ, never a reset: the command is used to hunt for a number,
        -- and a bare /fg mark that threw the current one away would be its own bug.
        Report()
        return
    end

    if args[1] == "off" or args[1] == "on" then
        elvHidden = (args[1] == "off")
        if elvMark then elvMark:SetShown(not elvHidden) end
        Report()
        return
    end

    local x, y = tonumber(args[1]), tonumber(args[2])
    if not x or not y then
        DEFAULT_CHAT_FRAME:AddMessage("FriendGroups: usage /fg mark <x> <y> [lift]")
        return
    end
    -- lift is optional and keeps its current value when omitted -- x/y are what a screenshot
    -- measurement usually moves, and re-typing the lift every time invites a typo in it.
    local lift = tonumber(args[3]) or ELV_Y_LIFT

    ELV_X, ELV_Y, ELV_Y_LIFT = x, y, lift
    if elvMark then Mark.Place(elvMark, Mark.FirstSubTab() or elvMark:GetParent(), x, y, lift) end
    Report()
end
