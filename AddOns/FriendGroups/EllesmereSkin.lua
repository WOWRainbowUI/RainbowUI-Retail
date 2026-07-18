-- ============================================================================
--  EllesmereSkin.lua
--  Auto-applied EllesmereUI theme for FriendGroups.
--
--  When the EllesmereUI suite (core addon "EllesmereUI") is detected, this
--  module reskins Blizzard's FriendsFrame window and the contact rows so the
--  list matches EllesmereUI's dark, flat aesthetic. It restyles in place and
--  keeps FriendGroups' own geometry -- it does NOT resize/relayout the frame
--  the way EllesmereUI's contact-list module does (that is what conflicts).
--
--  Design rules (agreed):
--   * NO fallbacks. The skin only runs when EllesmereUI is installed, so its
--     colour/font API is guaranteed present. If it is absent we do nothing.
--   * Enable/disable is a user toggle (default enabled); changes apply on
--     reload, matching standard UI-addon behaviour.
--   * Purely cosmetic: we hide/recolour regions and add textures/fontstrings.
--     No secure/protected attributes are touched.
-- ============================================================================

local addonName, addonTable = ...
local L = addonTable.L

local Skin = {}
_G.FriendGroupsEUISkin = Skin

Skin.detected = false
Skin.enabled  = false

local EUI_ADDON = "EllesmereUI"

-- EllesmereUI window palette (copied from its friends skin).
local BG_R, BG_G, BG_B = 0.03, 0.045, 0.05     -- frame / tab background
local SEARCH_BG   = { 0.025, 0.035, 0.045, 0.92 }
local BORDER_COL  = { 1, 1, 1, 0.15 }          -- subtle window border
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

local function SkinButtonFlat(btn)
    if not btn or btn.euiSkinned then return end
    btn.euiSkinned = true
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

local function SkinTabsOnce()
    local frame = FriendsFrame
    if not frame then return end
    local font = GetFont()
    local ar, ag, ab = GetAccent()
    for i = 1, (frame.numTabs or 4) do
        local tab = _G["FriendsFrameTab" .. i]
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
            local txt = (bliz and bliz:GetText()) or ("Tab " .. i)
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

-- ---------------------------------------------------------------------------
--  Sub-tabs (Friends / Recent Allies / Recruit A Friend) -- Blizzard's
--  FriendsTabHeader.TabSystem. Restyled in place (kept functional).
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
--  Secondary panels (Who / Raid / Quick Join / Recent Allies / Recruit)
--  Consistent dark chrome: hide their Blizzard insets so the dark window
--  shows through, and flatten their buttons. (Deep list/roster reskins are
--  intentionally out of scope -- Raid especially has protected controls.)
-- ---------------------------------------------------------------------------
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
    SkinPanels()
    for _, name in ipairs(KNOWN_BUTTONS) do
        SkinButtonFlat(_G[name])
    end

    -- Re-skin secondary panels when the bottom tabs are clicked (Who/Raid/QJ
    -- panels are load-on-demand and may not exist until first shown).
    for i = 1, (frame.numTabs or 4) do
        local tab = _G["FriendsFrameTab" .. i]
        if tab then
            tab:HookScript("OnClick", function()
                C_Timer.After(0, function() SkinSubTabs(); SkinPanels(); UpdateTabs() end)
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
    for idx, sf in ipairs({ _G.FriendsListFrame, _G.WhoFrame, _G.RaidFrame, _G.QuickJoinFrame }) do
        if sf then sf:HookScript("OnShow", function() UpdateTabs(idx) end) end
    end
    UpdateTabs()
end

-- ---------------------------------------------------------------------------
--  Row / divider skin (runs after each FriendGroups list update)
-- ---------------------------------------------------------------------------
-- NOTE: fonts are applied on EVERY pass (not guarded/once). The ScrollBox
-- recycles row frames on scroll, and Blizzard/FriendGroups may reset a
-- fontstring's font when it re-renders a recycled row -- so a one-time apply
-- leaves scrolled-in rows on the default font (the "alternating fonts" bug).
-- Re-applying each pass is cheap (a dozen visible frames) and keeps it uniform.
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
    -- Do NOT repaint button.background here: FriendGroups owns it (incl. the
    -- faction tints), and overriding it each ScrollBox update makes the faction
    -- colours flicker. The dark window already shows through its low alpha.
    -- Re-run the core row layout so the inline status icon re-anchors to the
    -- new (skinned) name width.
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
    -- Re-skin visible rows after each rebuild. We hook the list-update driver
    -- (called by global name throughout FriendGroups) and re-walk the ScrollBox
    -- next frame, so we are never bypassed by the element factory's captured
    -- initializer reference.
    hooksecurefunc("FriendGroups_FriendsListUpdate", function()
        if Skin.enabled then C_Timer.After(0, SkinRows) end
    end)
    Skin._rowHook = true
end

function Skin.RefreshEnabled()
    local on = FriendGroups_SavedVars and FriendGroups_SavedVars.eui_skin
    if on == nil then on = true end
    Skin.enabled = Skin.detected and on and true or false
end

-- Reload confirmation for the enable/disable toggle.
StaticPopupDialogs["FRIENDGROUPS_EUI_RELOAD"] = {
    text = L["EUI_RELOAD_PROMPT"],
    button1 = YES,
    button2 = NO,
    OnAccept = function() ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- ---------------------------------------------------------------------------
--  Dynamic text not covered by the curated skin: the contact count and the
--  native BattleTag / status dropdown (which we keep rather than replace, so we
--  restyle the FONT ONLY -- preserving each string's size/flags/position). Blizzard
--  repopulates the BattleTag frame, so this is re-applied every time the frame shows.
-- ---------------------------------------------------------------------------
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
    if not Skin.enabled then return end

    InstallRowHook()

    if FriendsFrame then
        FriendsFrame:HookScript("OnShow", function()
            SkinWindow()
            InstallScrollHook()
            C_Timer.After(0, function() SkinRows(); SkinDynamicText() end)
        end)
        if FriendsFrame:IsShown() then
            SkinWindow()
            InstallScrollHook()
            C_Timer.After(0, function() SkinRows(); SkinDynamicText() end)
        end
    end
end)
