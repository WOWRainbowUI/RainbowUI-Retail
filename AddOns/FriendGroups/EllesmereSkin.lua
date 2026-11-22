-- EllesmereUI theme for FriendGroups, applied when the EllesmereUI core is loaded. Restyles in
-- place and keeps FriendGroups' geometry (resizing is what conflicts with EUI's own list).
-- No fallbacks, cosmetic only, no protected attributes; toggle applies on reload.

local addonName, addonTable = ...
local L = addonTable.L
-- The Contacts-page mark, shared with the ElvUI driver in ContactsMark.lua (loaded just
-- before this file). Only the offsets below are EllesmereUI's; the asset, the size and the
-- pixel conversion live there so the two suites cannot drift apart.
local Mark = addonTable.ContactsMark

local Skin = {}
_G.FriendGroupsEUISkin = Skin

Skin.detected = false
Skin.enabled  = false

local EUI_ADDON = "EllesmereUI"

-- EllesmereUI window palette (copied from its friends skin).
local BG_R, BG_G, BG_B = 0.03, 0.045, 0.05     -- frame / tab background
local SEARCH_BG   = { 0.025, 0.035, 0.045, 0.92 }
-- Opaque black: a lighter edge made the tab strip look wider than the list.
local BORDER_COL  = { 0, 0, 0, 1 }
local TAB_WASH    = { 1, 1, 1, 0.05 }          -- active-tab wash
local NAME_SIZE, INFO_SIZE, TAB_SIZE, TITLE_SIZE = 12, 9, 9, 12

-- ---------------------------------------------------------------------------
--  EllesmereUI theme accessors (guaranteed present when detected)
-- ---------------------------------------------------------------------------
local function EUI() return _G.EllesmereUI end

local function GetFont()
    local eui = EUI()
    if eui and eui.GetFontPath then return eui.GetFontPath("friends") end
    return STANDARD_TEXT_FONT
end

local function GetAccent()
    local eui = EUI()
    local a = eui and (eui.ACCENT_COLOR or eui.ELLESMERE_GREEN)
    if a then return a.r, a.g, a.b end
    return 0.047, 0.824, 0.624   -- EllesmereUI default teal #0CD29F
end

-- [[ 12.1 SOCIAL UI: COLOURISE ONLY ]] EUI reskins SocialUIFrame itself; we only tint our own
-- regions (header banner, row background, count, drag indicator). Colours from the public
-- skin facade (EllesmereUI.RegisterSkin); without it, the same direct accessors as above.

-- The facade handed back by RegisterSkin, or nil.
local euiFacade

-- Built lazily, cached, and invalidated by both the enable toggle and EUI's own
-- live-recolour callback. The API explicitly asks callers not to hold getter
-- results across long lifetimes, which is what OnLooksChanged is for.
local socialTheme, socialThemeBuilt

-- The header band sits darker than the rows so a group reads as a band rather
-- than as one more row. Both are derived from the house panel fill, so a user who
-- recolours EllesmereUI gets both moving together.
local SOCIAL_HEADER_DARKEN = 0.55
local SOCIAL_HEADER_ALPHA  = 0.98
local SOCIAL_ROW_ALPHA     = 0.55

-- Test seam, works without EllesmereUI: /run FriendGroupsEUISkin.forceTheme = true; ReloadUI()
Skin.forceTheme = false

local function BuildSocialTheme()
    -- Marked built and cleared up front, so a build that cannot resolve a colour leaves
    -- NO theme rather than the previous one, and is not retried on every row recycle.
    socialThemeBuilt = true
    socialTheme = nil

    local fontPath, fontFlag, ar, ag, ab, pr, pg, pb

    if euiFacade then
        fontPath, fontFlag = euiFacade.GetFont()
        ar, ag, ab = euiFacade.GetAccentColor()
        pr, pg, pb = euiFacade.GetPanelColor()
    else
        -- No facade: fontFlag nil means "keep the string's flags". The facade's "" means no outline.
        fontPath = GetFont()
        ar, ag, ab = GetAccent()
        pr, pg, pb = BG_R, BG_G, BG_B
    end

    if not fontPath or not pr then return end

    -- Accent not stored: the user changes it at runtime and nothing invalidates a copy on the
    -- fallback path. Read live via Skin.GetAccentRGB.
    socialTheme = {
        fontPath = fontPath,
        fontFlag = fontFlag,
        headerBanner = {
            pr * SOCIAL_HEADER_DARKEN,
            pg * SOCIAL_HEADER_DARKEN,
            pb * SOCIAL_HEADER_DARKEN,
            SOCIAL_HEADER_ALPHA,
        },
        rowBackground = { pr, pg, pb, SOCIAL_ROW_ALPHA },
    }
end

-- Theme or nil. Also FriendGroups' gold replacement everywhere; cached after the first build.
function Skin.GetTheme()
    if not (Skin.enabled or Skin.forceTheme) then return nil end
    if not socialThemeBuilt then BuildSocialTheme() end
    return socialTheme
end

-- Font for the legacy window's chrome. Not GetTheme().fontPath (EUI's Blizzard-skin font,
-- right for 12.1 only). Read fresh, never cached.
function Skin.GetChromeFontPath()
    if not (Skin.enabled or Skin.forceTheme) then return nil end
    return GetFont()
end

-- Live accent, never cached: EUI mutates ELLESMERE_GREEN in place and repaints via
-- ApplyAccentLive -> UpdateAccentElements -> WSkin.RefreshLooks -> our OnLooksChanged.
function Skin.GetAccentRGB()
    if not (Skin.enabled or Skin.forceTheme) then return nil end

    if euiFacade then
        return euiFacade.GetAccentColor()
    end
    return GetAccent()
end

if EUI() and type(EUI().RegisterSkin) == "function" then
    EUI().RegisterSkin("FriendGroups", function(S)
        euiFacade = S
        socialThemeBuilt = false

        if type(S.OnLooksChanged) == "function" then
            S.OnLooksChanged(function()
                socialThemeBuilt = false
                Skin.RefreshAccent()
                -- Repaint through the addon's own coalesced rebuild rather than
                -- walking the ScrollBox here: the rows are pooled, and the list
                -- update is the one path that reaches every one of them.
                if type(FriendGroups_RequestListUpdate) == "function" then
                    FriendGroups_RequestListUpdate()
                end
            end)
        end
    end)
end

-- ---------------------------------------------------------------------------
--  Small skinning primitives (texture-based, no BackdropTemplate dependency)
-- ---------------------------------------------------------------------------

-- Hide every Texture region on a frame (Blizzard chrome removal).
local function StripTextures(f)
    if not f or not f.GetRegions then return end
    for i = 1, select("#", f:GetRegions()) do
        local r = select(i, f:GetRegions())
        if r and r.IsObjectType and r:IsObjectType("Texture") then
            r:SetTexture(nil)
            r:SetAlpha(0)
        end
    end
end

-- Add a 1px border made of four thin textures.
local function AddBorder(f, r, g, b, a, level)
    if not f or f.euiBorder then return end
    local t = {}
    local function edge()
        local tex = f:CreateTexture(nil, level or "OVERLAY")
        tex:SetColorTexture(r, g, b, a)
        return tex
    end
    t.top = edge();    t.top:SetPoint("TOPLEFT", 0, 0);    t.top:SetPoint("TOPRIGHT", 0, 0);    t.top:SetHeight(1)
    t.bottom = edge(); t.bottom:SetPoint("BOTTOMLEFT", 0, 0); t.bottom:SetPoint("BOTTOMRIGHT", 0, 0); t.bottom:SetHeight(1)
    t.left = edge();   t.left:SetPoint("TOPLEFT", 0, 0);   t.left:SetPoint("BOTTOMLEFT", 0, 0);   t.left:SetWidth(1)
    t.right = edge();  t.right:SetPoint("TOPRIGHT", 0, 0); t.right:SetPoint("BOTTOMRIGHT", 0, 0); t.right:SetWidth(1)
    f.euiBorder = t
end

-- Add a solid background texture behind a frame's content.
local function AddBackground(f, r, g, b, a, sublevel)
    if not f or f.euiBg then return end
    local bg = f:CreateTexture(nil, "BACKGROUND", nil, sublevel or -8)
    bg:SetAllPoints(f)
    bg:SetColorTexture(r, g, b, a or 1)
    f.euiBg = bg
    return bg
end

-- ---------------------------------------------------------------------------
--  Bottom action buttons (Add Friend / Send Message, etc.)
-- ---------------------------------------------------------------------------
local KNOWN_BUTTONS = {
    "FriendsFrameAddFriendButton",
    "FriendsFrameSendMessageButton",
}

-- Buttons painted with the accent, kept so a live accent change can repaint them. The
-- legacy skin paints each button ONCE, so without this list an accent change leaves the
-- old colour on screen until the next reload.
local euiAccentButtons = {}

local function SkinButtonFlat(btn)
    if not btn or btn.euiSkinned then return end
    btn.euiSkinned = true
    euiAccentButtons[#euiAccentButtons + 1] = btn
    StripTextures(btn)
    if btn.Left then btn.Left:SetAlpha(0) end
    if btn.Middle then btn.Middle:SetAlpha(0) end
    if btn.Right then btn.Right:SetAlpha(0) end
    local nt = btn.GetNormalTexture and btn:GetNormalTexture();   if nt then nt:SetAlpha(0) end
    local pt = btn.GetPushedTexture and btn:GetPushedTexture();   if pt then pt:SetAlpha(0) end
    local ht = btn.GetHighlightTexture and btn:GetHighlightTexture(); if ht then ht:SetTexture(nil) end

    AddBackground(btn, 0.06, 0.06, 0.07, 0.95, -1)
    local ar, ag, ab = GetAccent()
    AddBorder(btn, ar, ag, ab, 0.5)
    local fs = btn.GetFontString and btn:GetFontString()
    if fs then
        fs:SetFont(GetFont(), INFO_SIZE, "")
        fs:SetTextColor(ar, ag, ab, 0.9)
    end
end

-- ---------------------------------------------------------------------------
--  Tabs (Friends / Recent / Recruit / ... and bottom Contacts/Who/Raid/QJ)
-- ---------------------------------------------------------------------------
local euiTabs = {}

-- Blank a Blizzard tab's background + hover-highlight art (named textures) so no
-- lines/shapes render. Content-blanked (texture AND atlas) so they stay invisible
-- even if Blizzard re-shows them. Does NOT touch our own bg/wash (different keys).
local TAB_ART_KEYS = {
    "Left", "Middle", "Right", "LeftDisabled", "MiddleDisabled", "RightDisabled",
    "LeftHighlight", "MiddleHighlight", "RightHighlight",
}
local function BlankTabArt(tab)
    if not tab then return end
    for _, key in ipairs(TAB_ART_KEYS) do
        local r = tab[key]
        if r and r.SetTexture then
            r:SetTexture(""); if r.SetAtlas then r:SetAtlas("") end; r:SetAlpha(0)
        end
    end
    local hl = tab:GetHighlightTexture()
    if hl then hl:SetTexture(""); if hl.SetAtlas then hl:SetAtlas("") end; hl:SetAlpha(0) end
end

-- i is Blizzard's LOGICAL tab index (what PanelTemplates_GetSelectedTab returns),
-- which is not the index in the frame name: Forever drops the Who tab but keeps the
-- names Tab1/Tab3/Tab4, so Tabs[] is the only correct map. Mirrors GetTabByIndex.
local function GetFriendsTab(frame, i)
    return (frame.Tabs and frame.Tabs[i]) or _G["FriendsFrameTab" .. i]
end

local function SkinTabsOnce()
    local frame = FriendsFrame
    if not frame then return end
    local font = GetFont()
    local ar, ag, ab = GetAccent()
    for i = 1, (frame.numTabs or 4) do
        local tab = GetFriendsTab(frame, i)
        if tab and not tab.euiSkinned then
            tab.euiSkinned = true
            -- Capture Blizzard's tab textures and blank them (texture AND atlas).
            -- The selected tab re-shows its legacy art, so we re-blank these in
            -- UpdateTabs too. Captured BEFORE our own textures so we never hide ours.
            local blizTex = {}
            for j = 1, select("#", tab:GetRegions()) do
                local r = select(j, tab:GetRegions())
                if r and r.IsObjectType and r:IsObjectType("Texture") then blizTex[#blizTex + 1] = r end
            end
            local hl = tab:GetHighlightTexture(); if hl then blizTex[#blizTex + 1] = hl end
            for _, r in ipairs(blizTex) do
                r:SetTexture(""); if r.SetAtlas then r:SetAtlas("") end; r:SetAlpha(0)
            end
            -- Kill the tab's hover-highlight art (Left/Middle/RightHighlight etc.).
            -- These are created lazily on first hover, so also re-blank on OnEnter.
            BlankTabArt(tab)
            tab:HookScript("OnEnter", function(self) BlankTabArt(self) end)

            local bg = tab:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(BG_R, BG_G, BG_B, 1)

            -- Active-tab colour fill (no line, no shape).
            local wash = tab:CreateTexture(nil, "ARTWORK", nil, -6)
            wash:SetAllPoints()
            wash:SetColorTexture(TAB_WASH[1], TAB_WASH[2], TAB_WASH[3], TAB_WASH[4])
            wash:SetBlendMode("ADD")
            wash:Hide()

            local bliz = tab:GetFontString()
            -- Blizzard's localized label only; fallback is empty, never an English string.
            local txt = (bliz and bliz:GetText()) or ""
            if bliz then bliz:SetTextColor(0, 0, 0, 0) end
            if tab.SetPushedTextOffset then tab:SetPushedTextOffset(0, 0) end

            local label = tab:CreateFontString(nil, "OVERLAY")
            label:SetFont(font, TAB_SIZE, "")
            label:SetPoint("CENTER", tab, "CENTER", 0, 0)
            label:SetText(txt)

            local ul = tab:CreateTexture(nil, "OVERLAY", nil, 6)
            ul:SetHeight(1)
            ul:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
            ul:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 0, 0)
            ul:SetColorTexture(ar, ag, ab, 1)
            ul:Hide()

            euiTabs[i] = { tab = tab, blizLabel = bliz, label = label, underline = ul, wash = wash, blizTex = blizTex }
        end
    end
end

local function UpdateTabs(override)
    local selected = override
        or (PanelTemplates_GetSelectedTab and PanelTemplates_GetSelectedTab(FriendsFrame))
        or 1
    for i, t in pairs(euiTabs) do
        local active = (i == selected)
        -- Re-blank Blizzard's tab art + hover highlight (they re-apply on selection).
        if t.blizTex then
            for _, r in ipairs(t.blizTex) do
                r:SetTexture(""); if r.SetAtlas then r:SetAtlas("") end; r:SetAlpha(0)
            end
        end
        BlankTabArt(t.tab)
        if t.blizLabel then t.blizLabel:SetTextColor(0, 0, 0, 0) end   -- keep Blizzard text hidden
        if t.label then t.label:SetTextColor(1, 1, 1, active and 1 or 0.5) end
        if t.underline then t.underline:SetShown(active) end
        if t.wash then t.wash:SetShown(active) end
    end
end

-- [[ Sub-tabs ]] FriendsTabHeader.TabSystem, restyled in place.
local euiSubTabs = {}

local function RefreshSubTabs()
    local ar, ag, ab = GetAccent()
    for _, e in ipairs(euiSubTabs) do
        local selected = e.btn.IsEnabled and not e.btn:IsEnabled()
        if e.label then
            if selected then e.label:SetTextColor(ar, ag, ab, 1)
            else e.label:SetTextColor(1, 1, 1, 0.55) end
        end
        if e.underline then e.underline:SetShown(selected) end
    end
end

local function SkinSubTabs()
    if Skin._subTabsDone then return end
    local header = _G.FriendsTabHeader
    local system = header and header.TabSystem
    if not system then return end
    Skin._subTabsDone = true

    local font = GetFont()
    local ar, ag, ab = GetAccent()
    StripTextures(header)
    StripTextures(system)
    for i = 1, select("#", system:GetChildren()) do
        local st = select(i, system:GetChildren())
        if st and st.IsObjectType and st:IsObjectType("Button") then
            StripTextures(st)
            local bliz = st:GetFontString()
            if bliz then bliz:SetFont(font, 11, ""); bliz:SetTextColor(1, 1, 1, 0.55) end
            local ul = st:CreateTexture(nil, "OVERLAY", nil, 6)
            ul:SetHeight(1)
            ul:SetPoint("BOTTOMLEFT", st, "BOTTOMLEFT", 0, -1)
            ul:SetPoint("BOTTOMRIGHT", st, "BOTTOMRIGHT", 0, -1)
            ul:SetColorTexture(ar, ag, ab, 1)
            ul:Hide()
            euiSubTabs[#euiSubTabs + 1] = { btn = st, label = bliz, underline = ul }
            st:HookScript("OnClick", function() C_Timer.After(0, RefreshSubTabs) end)
        end
    end
    RefreshSubTabs()
end

-- [[ Contacts-page mark ]] Parented to FriendsTabHeader, which is shown only on that page:
-- no tab detection (RaidFrame reports IsShown at login). Drawing is ContactsMark.lua's.
-- Offsets from the first sub-tab's TOPLEFT: X in UI units, lift in game pixels.
local LOGO_X       = 35     -- UI units, right of the tab's left edge
local LOGO_Y       = -7     -- UI units, below the tab's top edge
local LOGO_Y_LIFT  = 11     -- GAME PIXELS to raise it out of the tab strip

local function SkinContactsLogo()
    if Skin._logo then return end

    local header = _G.FriendsTabHeader
    -- OUR restyled strip, not Mark.FirstSubTab's raw walk: reaching this point means
    -- SkinSubTabs has run, and using its record keeps the mark's appearance tied to the
    -- pass that owns the tabs it sits on.
    local firstTab = euiSubTabs[1] and euiSubTabs[1].btn
    if not header or not firstTab then return end

    Skin._logo = Mark.Create(header, firstTab, LOGO_X, LOGO_Y, LOGO_Y_LIFT)
end

-- [[ 12.1 Social UI widget pass ]] Chrome around our regions, only via EUI's idempotent
-- primitives (S.Font/Button/EditBox/Dropdown); needs the facade. Regions are enumerated,
-- not named, so a renamed 12.1 internal can't break it.
local SOCIAL_SWEEP_MAX_DEPTH = 3

-- Labelled buttons get the accent on border and label, like EUI's own primary buttons.
-- Icon-only buttons are left as plates.
local function AccentButton(btn, S)
    local fs = btn.GetFontString and btn:GetFontString()
    if not fs or (fs:GetText() or "") == "" then return end

    local ar, ag, ab = GetAccent()

    -- Colour-only; the family was already set by the S.Font sweep.
    if type(S.White) == "function" then S.White(fs, ar, ag, ab) end

    -- AddBorder no-ops on a frame that already has one, but the registration must be
    -- guarded too -- this runs on every list rebuild, and an unguarded append would grow
    -- the repaint list without bound for the life of the session.
    if not btn.euiBorder then
        AddBorder(btn, ar, ag, ab, 0.5)
        euiAccentButtons[#euiAccentButtons + 1] = btn
    end
end

-- Re-font every FontString a frame owns DIRECTLY. Used where recursing would be wrong.
local function FontRegionsOf(frame, S)
    if not frame or not frame.GetRegions then return end
    for i = 1, select("#", frame:GetRegions()) do
        local r = select(i, frame:GetRegions())
        if r and r.IsObjectType and r:IsObjectType("FontString") then
            S.Font(r)
        end
    end
end

local function SweepWidgets(frame, S, depth, skip)
    if not frame or depth > SOCIAL_SWEEP_MAX_DEPTH then return end

    if frame.GetRegions then
        for i = 1, select("#", frame:GetRegions()) do
            local r = select(i, frame:GetRegions())
            if r and r.IsObjectType and r:IsObjectType("FontString") then
                -- Family only, at the string's existing size -- S.Font is documented
                -- as "same size", which is what keeps text scaling intact.
                S.Font(r)
            end
        end
    end

    if not frame.GetChildren then return end
    for i = 1, select("#", frame:GetChildren()) do
        local child = select(i, frame:GetChildren())
        -- The ScrollBox subtree is the contact rows: pooled, recycled, and already
        -- themed by the row pass. A card IS a Button, so sweeping into it would
        -- flatten every row the way a dialog button gets flattened.
        if child and child ~= frame and not skip[child] then
            if child.IsObjectType and child:IsObjectType("Button") then
                S.Button(child)
                AccentButton(child, S)
            end
            SweepWidgets(child, S, depth + 1, skip)
        end
    end
end

function Skin.SkinSocialWidgets(view)
    if not Skin.enabled or not euiFacade or not view then return false end

    local S = euiFacade
    if type(S.Font) ~= "function" or type(S.Button) ~= "function" then return false end

    local skip = {}
    if view.ScrollBox then skip[view.ScrollBox] = true end

    SweepWidgets(view, S, 0, skip)

    -- Title and BattleTag hang off SocialUIFrame, shared by six tabs: only its own regions,
    -- never a recursive sweep (that would restyle Raid and Quick Join). Font only; tag stays blue.
    FontRegionsOf(SocialUIFrame, S)
    if SocialUIFrame then FontRegionsOf(SocialUIFrame.TitleContainer, S) end

    -- Two widgets with dedicated primitives, applied by their verified paths (both are
    -- already read by Platform_SocialUI, so neither name is a guess). The sweep above
    -- would only have re-fonted them.
    local filterBar = view.FilterBar
    if filterBar then
        if type(S.EditBox) == "function" and filterBar.SearchBar then
            S.EditBox(filterBar.SearchBar)
        end
        if type(S.Dropdown) == "function" and filterBar.SearchFilterDropdown then
            S.Dropdown(filterBar.SearchFilterDropdown)
        end
    end

    return true
end

-- [[ Live accent repaint ]] Legacy chrome is painted once; re-state accent colours on
-- OnLooksChanged. Facade path only; without it the chrome updates on reload.
function Skin.RefreshAccent()
    if not Skin.enabled then return end

    local ar, ag, ab = GetAccent()

    for _, t in pairs(euiTabs) do
        if t.underline then t.underline:SetColorTexture(ar, ag, ab, 1) end
    end

    for _, btn in ipairs(euiAccentButtons) do
        local border = btn.euiBorder
        if border then
            for _, edge in pairs(border) do
                if edge.SetColorTexture then edge:SetColorTexture(ar, ag, ab, 0.5) end
            end
        end
        local fs = btn.GetFontString and btn:GetFontString()
        if fs then fs:SetTextColor(ar, ag, ab, 0.9) end
    end

    -- Sub-tabs re-read the accent themselves; this just re-runs that pass.
    RefreshSubTabs()
end

-- [[ Secondary panels ]] Hide insets and flatten buttons only; Raid has protected controls.
local function HidePanelChrome(f)
    if not f then return end
    if f.Bg then f.Bg:Hide() end
    if f.NineSlice then f.NineSlice:Hide() end
    if f.Inset then
        if f.Inset.Bg then f.Inset.Bg:Hide() end
        if f.Inset.NineSlice then f.Inset.NineSlice:Hide() end
    end
end

local function SkinPanels()
    HidePanelChrome(_G.RecentAlliesFrame)
    HidePanelChrome(_G.RecruitAFriendFrame)
    HidePanelChrome(_G.WhoFrame)
    HidePanelChrome(_G.RaidFrame)
    HidePanelChrome(_G.QuickJoinFrame)
    local wi = _G.WhoFrameListInset
    if wi then
        if wi.Bg then wi.Bg:Hide() end
        if wi.NineSlice then wi.NineSlice:Hide() end
    end
    for _, n in ipairs({ "WhoFrameWhoButton", "WhoFrameAddFriendButton", "WhoFrameGroupInviteButton" }) do
        SkinButtonFlat(_G[n])
    end
    RefreshSubTabs()
end

-- ---------------------------------------------------------------------------
--  Window chrome (one-time)
-- ---------------------------------------------------------------------------
local function SkinWindow()
    local frame = FriendsFrame
    if not frame or Skin._windowDone then return end
    Skin._windowDone = true

    local font = GetFont()

    -- Hide Blizzard decorations.
    if frame.NineSlice then frame.NineSlice:Hide() end
    if frame.Bg then frame.Bg:Hide() end
    if frame.TitleBg then frame.TitleBg:Hide() end
    if frame.TopTileStreaks then frame.TopTileStreaks:SetAlpha(0) end
    if frame.PortraitContainer then frame.PortraitContainer:Hide() end
    if frame.portrait then frame.portrait:Hide() end
    if frame.PortraitFrame then frame.PortraitFrame:Hide() end
    if _G.FriendsFramePortrait then _G.FriendsFramePortrait:Hide() end
    if _G.FriendsFrameIcon then _G.FriendsFrameIcon:Hide() end
    for _, key in ipairs({ "TopBorder", "TopRightCorner", "RightBorder", "BottomRightCorner",
                           "BottomBorder", "BottomLeftCorner", "LeftBorder", "TopLeftCorner",
                           "BtnCornerLeft", "BtnCornerRight" }) do
        if frame[key] then frame[key]:Hide() end
    end
    if frame.Inset then
        if frame.Inset.NineSlice then frame.Inset.NineSlice:Hide() end
        if frame.Inset.Bg then frame.Inset.Bg:Hide() end
    end

    -- Dark background + subtle border. Hide the border's BOTTOM edge: it lands on
    -- the frame's bottom (the tab-attach line) and reads as a grey line peeking
    -- through the gaps between the tabs.
    AddBackground(frame, BG_R, BG_G, BG_B, 1, -8)
    AddBorder(frame, BORDER_COL[1], BORDER_COL[2], BORDER_COL[3], BORDER_COL[4], "OVERLAY")
    if frame.euiBorder and frame.euiBorder.bottom then frame.euiBorder.bottom:Hide() end

    -- Tab bar background strip beneath the bottom tabs.
    local firstTab = _G.FriendsFrameTab1
    if firstTab then
        local tb = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        tb:SetColorTexture(BG_R, BG_G, BG_B, 1)
        tb:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 2)
        tb:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 2)
        tb:SetPoint("BOTTOM", firstTab, "BOTTOM", 0, 0)
    end

    -- Hide the Blizzard title and redraw it in the skin font, KEEPING its text (the
    -- localized "Contacts") -- not the BattleTag, which the status dropdown already
    -- shows just below (avoids the duplicate BattleTag).
    local titleText
    if frame.TitleContainer then
        local bt = frame.TitleContainer.TitleText or (frame.TitleContainer.GetFontString and frame.TitleContainer:GetFontString())
        if bt then titleText = bt:GetText(); bt:SetAlpha(0) end
    elseif _G.FriendsFrameTitleText then
        titleText = _G.FriendsFrameTitleText:GetText()
        _G.FriendsFrameTitleText:SetAlpha(0)
    end
    local titleFS = frame:CreateFontString(nil, "OVERLAY")
    titleFS:SetFont(font, TITLE_SIZE, "")
    titleFS:SetTextColor(1, 1, 1, 0.75)
    titleFS:SetPoint("TOP", frame, "TOP", 0, -5)
    titleFS:SetText(titleText or FRIENDS)   -- FRIENDS is Blizzard's localized fallback

    -- Tabs (bottom), sub-tabs (top), secondary panels + bottom buttons.
    SkinTabsOnce()
    SkinSubTabs()
    SkinContactsLogo()   -- after SkinSubTabs: it anchors to the first sub-tab
    SkinPanels()
    for _, name in ipairs(KNOWN_BUTTONS) do
        SkinButtonFlat(_G[name])
    end

    -- Re-skin secondary panels when the bottom tabs are clicked (Who/Raid/QJ
    -- panels are load-on-demand and may not exist until first shown).
    for i = 1, (frame.numTabs or 4) do
        local tab = GetFriendsTab(frame, i)
        if tab then
            tab:HookScript("OnClick", function()
                C_Timer.After(0, function() SkinSubTabs(); SkinContactsLogo(); SkinPanels(); UpdateTabs() end)
            end)
        end
    end

    -- Search box (FriendGroups' own edit box).
    local search = _G.FriendGroups_SearchBox or _G.FriendGroupsGlobalSearch
    if search and not search.euiSkinned then
        search.euiSkinned = true
        StripTextures(search)
        AddBackground(search, SEARCH_BG[1], SEARCH_BG[2], SEARCH_BG[3], SEARCH_BG[4], -1)
        AddBorder(search, 1, 1, 1, 0.4)
        if search.Instructions then search.Instructions:SetFont(font, INFO_SIZE, "") end
        if search.SetFont then search:SetFont(font, INFO_SIZE, "") end
    end

    -- Close button: replace the red Blizzard X with a flat EllesmereUI "x".
    local closeBtn = frame.CloseButton or _G.FriendsFrameCloseButton
    if closeBtn and not closeBtn.euiSkinned then
        closeBtn.euiSkinned = true
        StripTextures(closeBtn)
        local x = closeBtn:CreateFontString(nil, "OVERLAY")
        x:SetFont(font, 16, "")
        x:SetText("x")
        x:SetTextColor(1, 1, 1, 0.5)
        x:SetPoint("CENTER", -2, -3)
        closeBtn:HookScript("OnEnter", function() x:SetTextColor(1, 1, 1, 0.9) end)
        closeBtn:HookScript("OnLeave", function() x:SetTextColor(1, 1, 1, 0.5) end)
    end

    -- Keep active-tab styling in sync.
    hooksecurefunc(frame, "Show", function() UpdateTabs() end)
    -- Pairs, not a bare frame list: _G.WhoFrame is nil on Forever and ipairs would stop
    -- there, silently dropping Raid and Quick Join. The index must be Blizzard's own
    -- constant, because Forever renumbers Raid to 2 and Quick Join to 3.
    for _, e in ipairs({
        { _G.FRIEND_TAB_FRIENDS, _G.FriendsListFrame },
        { _G.FRIEND_TAB_WHO, _G.WhoFrame },
        { _G.FRIEND_TAB_RAID, _G.RaidFrame },
        { _G.FRIEND_TAB_QUICK_JOIN, _G.QuickJoinFrame },
    }) do
        local idx, sf = e[1], e[2]
        if idx and sf then sf:HookScript("OnShow", function() UpdateTabs(idx) end) end
    end
    UpdateTabs()
end

-- [[ Row / divider skin ]] Fonts every pass: recycled rows reset their fonts.
local function SkinFrame(button)
    if not button then return end
    local font = GetFont()

    -- Group divider header.
    if button.rawGroupName ~= nil or button.collapseButton then
        if button.name and button.name.SetFont then button.name:SetFont(font, NAME_SIZE, "") end
        if button.info and button.info.SetFont then button.info:SetFont(font, INFO_SIZE, "") end
        local hasCustom = button.rawGroupName and FriendGroups_SavedVars and FriendGroups_SavedVars.banner_colors
            and FriendGroups_SavedVars.banner_colors[button.rawGroupName]
        if button.solidBannerTexture and not hasCustom then
            button.solidBannerTexture:SetColorTexture(0.025, 0.025, 0.03, 0.98)
        end
        return
    end

    -- Friend row.
    if button.name and button.name.SetFont then button.name:SetFont(font, NAME_SIZE, "") end
    if button.info and button.info.SetFont then button.info:SetFont(font, INFO_SIZE, "") end
    if button.status and button.status.SetFont then button.status:SetFont(font, INFO_SIZE, "") end
    -- Never repaint button.background (FriendGroups owns it, faction tints flicker). Re-run the
    -- row layout so the status icon re-anchors to the new name width.
    if FriendGroups_ApplyRowLayout then FriendGroups_ApplyRowLayout(button) end
end

local function SkinRows()
    if not Skin.enabled then return end
    local sb = FriendsListFrame and FriendsListFrame.ScrollBox
    if sb and sb.ForEachFrame then
        sb:ForEachFrame(SkinFrame)
    end
end

-- Re-skin rows whenever the ScrollBox redraws (covers scrolling, which does not
-- go through FriendGroups_FriendsListUpdate). Installed once, lazily.
local function InstallScrollHook()
    if Skin._sbHook then return end
    local sb = FriendsListFrame and FriendsListFrame.ScrollBox
    if not sb or not sb.Update then return end
    hooksecurefunc(sb, "Update", function()
        if Skin.enabled then SkinRows() end
    end)
    Skin._sbHook = true
end

-- ---------------------------------------------------------------------------
--  Wiring
-- ---------------------------------------------------------------------------
local function InstallRowHook()
    if Skin._rowHook then return end
    if type(FriendGroups_FriendsListUpdate) ~= "function" then return end
    -- Hook the update driver and re-walk next frame: the element factory holds a captured
    -- initializer, so hooking the row function is bypassed.
    hooksecurefunc("FriendGroups_FriendsListUpdate", function()
        if Skin.enabled then C_Timer.After(0, SkinRows) end
    end)
    Skin._rowHook = true
end

function Skin.RefreshEnabled()
    local on = FriendGroups_SavedVars and FriendGroups_SavedVars.eui_skin
    if on == nil then on = true end
    Skin.enabled = Skin.detected and on and true or false
    socialThemeBuilt = false
end

-- [[ EUI renderer conflicts ]] EllesmereUIFriends and the Forever tiles paint the same cards.
-- Not gated on eui_skin. docs: FriendGroups-eui-conflicts.md
local EUI_FRIENDS_ADDON = "EllesmereUIFriends"

-- EllesmereUI 9.7.6+ on Forever. friendsListCard.enabled has no options UI; it
-- turns off the tiles alone and leaves EllesmereUI's window skin on.
local function ForeverTilesActive()
    local E = _G.EllesmereUI
    if not (E and E.IS_FOREVER and E.FriendsKit and type(E.GetBlizzWindowStyle) == "function") then
        return false
    end
    if type(E.PadTaintStandDown) == "function" and E.PadTaintStandDown() then return false end
    if E.GetBlizzWindowStyle("socialui") == "off" then return false end
    local card = type(EllesmereUIDB) == "table" and EllesmereUIDB.friendsListCard
    return not (type(card) == "table" and card.enabled == false)
end

local function DisableForeverTiles()
    if type(EllesmereUIDB) ~= "table" then return end
    if type(EllesmereUIDB.friendsListCard) ~= "table" then EllesmereUIDB.friendsListCard = {} end
    EllesmereUIDB.friendsListCard.enabled = false
end

local function DisableFriendsAddon()
    -- One argument: current character only. Takes effect on the reload.
    if C_AddOns and C_AddOns.DisableAddOn then C_AddOns.DisableAddOn(EUI_FRIENDS_ADDON) end
end

local function RegisterConflictPopup(name, textKey, acceptKey, disable, dismissKey)
    StaticPopupDialogs[name] = {
        text = L[textKey],
        button1 = L[acceptKey],
        button2 = L["EUI_FRIENDS_KEEP"],
        OnAccept = function()
            disable()
            ReloadUI()
        end,
        OnCancel = function(_, _, reason)
            -- Also fires on ESC, timeout and override; only a click means "keep both".
            if reason ~= "clicked" or not dismissKey then return end
            if type(FriendGroups_SavedVars) == "table" then FriendGroups_SavedVars[dismissKey] = true end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

RegisterConflictPopup("FRIENDGROUPS_EUI_FRIENDS_CONFLICT", "EUI_FRIENDS_CONFLICT", "EUI_FRIENDS_DISABLE",
    DisableFriendsAddon, "eui_conflict_dismissed")
-- No dismiss key: the tiles popup returns every login while the tiles are on.
RegisterConflictPopup("FRIENDGROUPS_EUI_TILES_CONFLICT", "EUI_TILES_CONFLICT", "EUI_TILES_DISABLE",
    DisableForeverTiles, nil)

local function RaiseConflict(popup, textKey, dismissKey)
    print(L[textKey])
    if dismissKey and type(FriendGroups_SavedVars) == "table" and FriendGroups_SavedVars[dismissKey] then
        return
    end
    -- Deferred: a popup raised under the loading screen can go unseen.
    C_Timer.After(5, function() StaticPopup_Show(popup) end)
end

local function WarnFriendsConflict()
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(EUI_FRIENDS_ADDON) then
        RaiseConflict("FRIENDGROUPS_EUI_FRIENDS_CONFLICT", "EUI_FRIENDS_CONFLICT", "eui_conflict_dismissed")
    elseif ForeverTilesActive() then
        RaiseConflict("FRIENDGROUPS_EUI_TILES_CONFLICT", "EUI_TILES_CONFLICT", nil)
    end
end

-- The reload confirmation for the enable/disable toggle is FRIENDGROUPS_RELOAD, defined in
-- FriendGroups.lua and shared with the Classic own-list toggle.

-- Contact count, BattleTag and status dropdown: font only. Re-applied on each show because
-- Blizzard repopulates the BattleTag frame.
local function FontStringsIn(frame)
    if not frame then return end
    local font = GetFont()
    local function apply(r)
        if r and r.IsObjectType and r:IsObjectType("FontString") and r.GetFont then
            local _, size, flags = r:GetFont()
            r:SetFont(font, size or 12, flags or "")
        end
    end
    if frame.GetRegions then
        for i = 1, select("#", frame:GetRegions()) do apply((select(i, frame:GetRegions()))) end
    end
    if frame.GetChildren then
        for i = 1, select("#", frame:GetChildren()) do
            local child = select(i, frame:GetChildren())
            if child and child.GetRegions then
                for j = 1, select("#", child:GetRegions()) do apply((select(j, child:GetRegions()))) end
            end
        end
    end
end

local function SkinDynamicText()
    if not Skin.enabled then return end
    local font = GetFont()
    if _G.FriendGroups_ContactText then
        local _, size, flags = FriendGroups_ContactText:GetFont()
        FriendGroups_ContactText:SetFont(font, size or 11, flags or "")
    end
    FontStringsIn(_G.FriendsFrameBattlenetFrame)
    FontStringsIn(_G.FriendsFrameStatusDropdown)
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function()
    Skin.detected = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(EUI_ADDON) or false

    if FriendGroups_SavedVars and FriendGroups_SavedVars.eui_skin == nil then
        FriendGroups_SavedVars.eui_skin = true
    end
    Skin.RefreshEnabled()

    -- Raised before the enable check: the renderer collision exists whether or not
    -- the user wants our EllesmereUI colours.
    WarnFriendsConflict()

    if not Skin.enabled then return end

    InstallRowHook()

    if FriendsFrame then
        -- Re-run on every open: SkinWindow runs once, possibly before the sub-tab strip exists.
        -- Each call is idempotent.
        local function ApplySkin()
            SkinWindow()
            InstallScrollHook()
            C_Timer.After(0, function()
                SkinSubTabs()
                SkinContactsLogo()
                UpdateTabs()
                SkinRows()
                SkinDynamicText()
            end)
        end

        FriendsFrame:HookScript("OnShow", ApplySkin)
        if FriendsFrame:IsShown() then ApplySkin() end
    end
end)
