-- FriendGroups mark in the empty band above the Contacts sub-tab strip, where suites that
-- remove the portrait ring leave dead space. Shared by EllesmereSkin.lua and the ElvUI driver
-- below. Load before EllesmereSkin.lua. Retail only.

local addonName, addonTable = ...
local Compat = addonTable.Compat

local Mark = {}
addonTable.ContactsMark = Mark
_G.FriendGroupsContactsMark = Mark

-- The same asset the TOC declares as IconTexture and Platform_SocialUI writes to
-- the portrait, so the two never disagree about what the addon's mark is.
Mark.TEXTURE = "Interface\\AddOns\\FriendGroups\\Textures\\fg"
Mark.SIZE    = 34

-- Game pixels to UI units for `frame`: 768 units tall at scale 1, using the frame's own
-- effective scale so a suite that scales the window is covered.
function Mark.GamePixels(frame, px)
    local _, screenHeight = GetPhysicalScreenSize()
    local scale = frame:GetEffectiveScale()
    if not screenHeight or screenHeight <= 0 or not scale or scale <= 0 then return px end

    return px * 768 / (screenHeight * scale)
end

-- First button under TabSystem, or nil. Enumerated: the children are anonymous and suites
-- restyle them in place.
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

-- Anchored to the first sub-tab so it holds at any width. x and y are UI units; lift is
-- measured in game pixels and converted.
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

-- [[ ElvUI driver ]] ElvUI hides the portrait and FriendsFrameIcon but keeps the TabSystem
-- buttons this anchors to. No ElvUI API or colours used.
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

    -- Measured, not "ElvUI loaded": with its Friends skin off the portrait ring still carries our
    -- mark. Re-tested each open.
    if not (Compat.PortraitIsSuppressed and Compat.PortraitIsSuppressed(frame)) then return end

    elvMark = Mark.Create(header, firstTab, ELV_X, ELV_Y, ELV_Y_LIFT)
    if elvHidden then elvMark:Hide() end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function()
    local loaded = C_AddOns and C_AddOns.IsAddOnLoaded
    if not loaded or not loaded(ELV_ADDON) then return end

    -- One mark per band: EllesmereSkin draws its own. Gate on the addon, not on
    -- FriendGroupsEUISkin.enabled, which resolves later at its PLAYER_LOGIN.
    if loaded(EUI_ADDON) then return end

    local frame = _G.FriendsFrame
    if not frame then return end

    -- Deferred a frame: ElvUI skins the window from its own load path, and the sub-tab
    -- strip this anchors to is not necessarily built when the first OnShow fires.
    local function Apply() C_Timer.After(0, EnsureElvMark) end

    frame:HookScript("OnShow", Apply)
    if frame:IsShown() then Apply() end
end)

-- [[ /fg mark ]] Live tuning, session only: prints offsets in the form written above.
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
