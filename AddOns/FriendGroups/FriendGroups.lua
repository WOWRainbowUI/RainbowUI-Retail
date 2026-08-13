--[[
	FriendGroups - FULL ORIGINAL CODE + SECURE ARCHITECTURE
    - Uses the exact original logic for groups, menus, and sorting.
    - Adds "Lazy Loading" to prevent VisitHouse() taint.
    - Adds Safety Shield to the House List.
]] --
local addonName, addonTable = ...
local L = addonTable.L or {}
local Compat = addonTable.Compat

-- [[ STATE MANAGEMENT ]] --
local FriendGroups_Loaded = false 

-- ============================================================================
-- [[ DIRTY ROSTER ENGINE (IDLE GC CHURN PREVENTER) ]]
-- ============================================================================
local FriendGroups_RosterDirty = true
local fgRosterEventFrame = CreateFrame("Frame")
-- 12.2.2b: GROUP_ROSTER_UPDATE refreshes visible rows (invite-restriction / travel pass
-- state) but never changes the group layout, so it requests a refresh without flagging
-- the roster dirty (handled in OnEvent below). Validated registration skips any event
-- the running client lacks instead of aborting file load.
Compat.RegisterEvents(fgRosterEventFrame, {
    "BN_FRIEND_INFO_CHANGED",
    "BN_FRIEND_LIST_SIZE_CHANGED",
    "BN_FRIEND_INVITE_ADDED",
    "BN_FRIEND_INVITE_REMOVED",
    "FRIENDLIST_UPDATE",
    "PLAYER_FLAGS_CHANGED",
    "GROUP_ROSTER_UPDATE",
})
fgRosterEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event ~= "GROUP_ROSTER_UPDATE" then
        FriendGroups_RosterDirty = true
    end
    -- 12.2.2b: this frame is now the primary refresh driver. In hook mode the spammy
    -- events are unregistered from FriendsFrame entirely (see EnableFriendGroups), so
    -- Blizzard's native FriendsList_Update no longer fires for them and cannot route a
    -- refresh to us. Visibility, combat and dirty guards all apply when the coalescer
    -- fires, so this is behaviour-identical to the pre-12.2.2 override path.
    FriendGroups_RequestListUpdate()
end)

-- ============================================================================
-- [[ MEMORY OPTIMIZATION UTILITIES ]]
-- ============================================================================
local FriendGroups_RealmStringCache = {}

function FriendGroups_CleanRealmName(realmName)
    if type(realmName) ~= "string" or realmName == "" then return "" end
    if FriendGroups_RealmStringCache[realmName] then
        return FriendGroups_RealmStringCache[realmName]
    end
    local cleanRealm = realmName:gsub("[%s%p]+", "")
    FriendGroups_RealmStringCache[realmName] = cleanRealm
    return cleanRealm
end

local FriendGroups_DPElementPool = {}

local function GetDPElement()
    local t = table.remove(FriendGroups_DPElementPool) or {}
    wipe(t)
    return t
end

-- [[ FORWARD DECLARATIONS ]] --
local EnableFriendGroups
local FriendGroups_FriendsListUpdate
local FriendGroups_FriendsListUpdateFriendButton
local FriendGroups_FriendsListButtonTemplateClick
local SetupGroupedView
local FriendGroups_SaveToAltCache

local ADDON_CHAT_PREFIX = "|cffFFE400[|r|cff3AFF00" .. "FriendGroups" .. "|r|cffFFE400]|r"
local function Print(...)
    local str = ADDON_CHAT_PREFIX .. "|cff00F7FF "
    local count = select("#", ...)
    for i = 1, count do
        str = str .. tostring(select(i, ...))
        if i < count then
            str = str .. " "
        end
    end
    DEFAULT_CHAT_FRAME:AddMessage(str .. "|r")
end

-- ============================================================================
-- [[ HOUSE ACCENT ]]
-- FriendGroups draws its own chrome in Blizzard gold (1, 0.82, 0): tooltip headers,
-- the contact counter, group lines, the drag indicator, menu section titles. That gold
-- is now resolved through here instead of being written literally, so the whole addon
-- retints together when the EllesmereUI skin is on.
--
-- Applies on EVERY platform, not just 12.1 -- the skin toggle is era-independent, and a
-- half-themed addon looks worse than an unthemed one.
--
-- Resolved LIVE on each call rather than cached: EllesmereUI's accent is user-editable at
-- runtime and the skin publishes a live value. These are tooltip and menu build paths,
-- both of which already do far more work than one table lookup.
--
-- Looked up by global name because EllesmereSkin.lua loads AFTER this file. It is a real
-- global there (_G.FriendGroupsEUISkin), and returns nil on any client where the skin is
-- absent or switched off -- which is the gold path, unchanged.
local FG_GOLD_R, FG_GOLD_G, FG_GOLD_B = 1, 0.82, 0

-- Floor width for the contact tooltip, in pixels.
--
-- GameTooltip decides where a WRAPPED line breaks from the tooltip's width AT THE MOMENT THE
-- LINE IS ADDED, and this tooltip adds its prose before the numeric AddDoubleLine rows that
-- set its real width. The prose was therefore wrapping against a narrow tooltip and then
-- being stretched by the rows underneath it, leaving one orphaned word per paragraph well
-- short of the right edge. Claiming the final width up front makes the wrap points honest.
--
-- Roughly the width the finished tooltip already had, so nothing that fitted before moves.
local FG_CONTACT_TOOLTIP_MIN_WIDTH = 300

function FriendGroups_AccentRGB()
    local skin = _G.FriendGroupsEUISkin
    if type(skin) == "table" and type(skin.GetAccentRGB) == "function" then
        -- Live, not from the cached theme: EllesmereUI's accent swatch is editable at
        -- runtime and mutates its colour table in place, so a copy taken at first paint
        -- would be wrong from the moment the user drags the picker.
        local r, g, b = skin.GetAccentRGB()
        if r then return r, g, b end
    end
    return FG_GOLD_R, FG_GOLD_G, FG_GOLD_B
end

-- The same accent as a |cff escape, for strings that carry their own colour (menu titles,
-- concatenated tooltip text). Built from the live RGB so the two can never disagree.
function FriendGroups_AccentColorCode()
    local r, g, b = FriendGroups_AccentRGB()
    -- Rounded to integers before formatting. %x against a float is tolerated by this Lua
    -- but truncates, and 0.824 * 255 = 210.1 losing its fraction is a visibly different
    -- teal from the one every other surface is using.
    return string.format("|cff%02x%02x%02x",
        math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
end

-- ============================================================================
-- [[ ROW FONT SCALE ]]
-- 1 Small, 2 Medium, 3 Large. Medium is the default and reproduces the historical
-- behaviour exactly, so an existing user who never touches this sees no change.
--
-- Stored as a scalar rather than a pair of booleans: three states in one field cannot
-- encode a contradiction the way two independent flags can. (The Narrow/Normal/Wide width
-- uses two flags only because it predates this and its wire format is fixed.)
--
-- Anything unrecognised -- nil, 0 from an older profile, a corrupted value -- reads as
-- Medium, so there is no state in which the list renders at an unusable size.
function FriendGroups_GetFontScale()
    local n = FriendGroups_SavedVars and tonumber(FriendGroups_SavedVars.font_size)
    if n == 1 or n == 3 then return n end
    return 2
end

function FriendGroups_SetFontScale(scale)
    scale = tonumber(scale)
    if scale ~= 1 and scale ~= 2 and scale ~= 3 then return end
    if type(FriendGroups_SavedVars) ~= "table" then return end
    if FriendGroups_GetFontScale() == scale then return end

    FriendGroups_SavedVars.font_size = scale

    -- Row HEIGHT is derived from the scale as well as the font, and the Social UI caches
    -- template extents. Without dropping that cache the text would resize inside rows that
    -- kept their old height, clipping the larger sizes.
    if type(Compat.OnFontScaleChanged) == "function" then
        Compat.OnFontScaleChanged()
    end

    -- Forced: the roster has not changed, only what should be drawn of it -- which is
    -- exactly the case the non-forcing path discards.
    FriendGroups_FriendsListUpdate(true)
end

-- Wrap a string in the house accent. Returns the string untouched when nothing is themed,
-- so the gold Blizzard font colour of a menu title is left to stand on its own.
function FriendGroups_AccentText(text)
    if type(text) ~= "string" or text == "" then return text end

    local r, g, b = FriendGroups_AccentRGB()
    if r == FG_GOLD_R and g == FG_GOLD_G and b == FG_GOLD_B then return text end

    return FriendGroups_AccentColorCode() .. text .. "|r"
end

-- ============================================================================
-- [[ ONLINE COUNTER PLACEMENT ]]
-- ============================================================================
-- The counter beside the search box is right-aligned onto the same column the group
-- headers right-align their "online/total" count in, so it reads as that column's grand
-- total. Where that column falls depends on the list backend, so it is measured from the
-- live frames (see FriendGroups_GetCountColumnInset) rather than hardcoded:
--   * ScrollBox clients: dividers fill the ScrollBox and inset their count by 20
--     (FriendGroups.xml).
--   * Classic HybridScroll clients: rows inset their count by 10 (Platform_Render).
-- Measuring also keeps the counter correct across the three list width modes for free.
local FG_COUNT_INSET_SCROLLBOX = 20
local FG_COUNT_INSET_CLASSIC = 10
-- Used only until the frames report geometry: retail's ScrollBox (28 inside the frame)
-- plus its 20 count inset.
local FG_COUNT_COLUMN_FALLBACK_INSET = 48
-- The search box is anchored 90 below FriendsListFrame's top and is 20 tall on every
-- flavour, so its vertical centre -- and therefore the counter's -- is 100 below the top.
local FG_COUNT_COLUMN_Y = -100
local FriendGroups_ContactTextInset = nil

-- Returns how far left of FriendsListFrame's right edge the count column's right edge sits,
-- or nil while the frames have no geometry yet (before first layout).
local function FriendGroups_GetCountColumnInset()
    local frameRight = FriendsListFrame and FriendsListFrame:GetRight()
    if not frameRight then return nil end

    local columnRight
    if Compat.HAS_SCROLLBOX then
        local box = FriendsListFrame.ScrollBox
        local boxRight = box and box:GetRight()
        if not boxRight then return nil end
        columnRight = boxRight - FG_COUNT_INSET_SCROLLBOX
    else
        local scrollFrame = FriendsFrameFriendsScrollFrame
        local buttons = scrollFrame and scrollFrame.buttons
        local row = buttons and buttons[1]
        local rowRight = row and row:GetRight()
        if not rowRight then return nil end
        columnRight = rowRight - FG_COUNT_INSET_CLASSIC
    end

    local inset = frameRight - columnRight

    -- Whatever the backend measures, never let the counter slide under the settings gear.
    local gear = FriendGroupsGlobalSettings
    local gearLeft = gear and gear:GetLeft()
    if gearLeft then
        local minInset = (frameRight - gearLeft) + 2
        if inset < minInset then inset = minInset end
    end

    return inset
end

local playerRealmID = GetRealmID();
local playerFactionGroup = UnitFactionGroup("player");
local INVITE_RESTRICTION_NONE = 9
local groupsTotal = {}
local groupsSorted = {}
local groupsCount = {}

-- Cross-file state for the Classic HybridScroll renderer (Platform_Render.lua),
-- which cannot see these file-locals. Tables are shared by reference (only ever
-- wiped in place, never reassigned); scalars are load-time constants.
addonTable.State = {
	groupsTotal = groupsTotal,
	groupsCount = groupsCount,
	playerFactionGroup = playerFactionGroup,
	INVITE_RESTRICTION_NONE = INVITE_RESTRICTION_NONE,
}

local searchBoxInit = false
local FriendGroups_Menu, FriendGroupsFrame, searchOpened
local searchValue = ""
local FriendGroups_SearchBox

-- Published for the platform renderers. On 12.1 the search box belongs to Blizzard's filter
-- bar, so the text arrives from outside this file and cannot touch the file-local directly.
--
-- searchValue and searchLowerValue must move TOGETHER: the per-friend filter compares against
-- the lowercase cache, so setting one without the other silently filters on a stale key.
-- (searchLowerValue is an implicit global in this file, assigned in the search box handler and
-- read by the filter; it is set here rather than from another file so the pairing stays local
-- to the one place that owns the meaning.)
--
-- Returns true only when the value actually changed, so a caller can skip the rebuild on
-- keystrokes that leave the text identical.
addonTable.State.SetSearchText = function(text)
    text = (type(text) == "string") and text or ""
    if text == searchValue then return false end
    searchValue = text
    searchLowerValue = text:lower()
    return true
end

-- The current term, so a caller that temporarily overrides it can put it back. Reads the
-- file-local rather than any widget's text: the two list platforms own different search
-- boxes, and this is the value the filter actually runs on.
addonTable.State.GetSearchText = function()
    return searchValue or ""
end

-- Data for the Custom Menu
local FriendGroups_ClickedData = {}

local settingsMenuItems = {
    -- SECTION 0: SIZE
    { text = L["SETTINGS_SIZE"], notCheckable = true, isTitle = true, submenu = true },
    { text = L["SETTINGS_SIZE_HEIGHT"], isSubTitle = true },
    {
        text = L["SET_SIZE_SMALL"],
        checked = function() return (FriendGroups_SavedVars.extra_height or 0) == 0 end,
        func = function()
            FriendGroups_SavedVars.extra_height = 0
            FriendGroups_UpdateSize()
        end
    },
    {
        text = L["SET_SIZE_MEDIUM"],
        checked = function() return (FriendGroups_SavedVars.extra_height or 0) == 190 end,
        func = function()
            FriendGroups_SavedVars.extra_height = 190
            FriendGroups_UpdateSize()
        end
    },
    {
        text = L["SET_SIZE_LARGE"],
        checked = function() return (FriendGroups_SavedVars.extra_height or 0) == 380 end,
        func = function()
            FriendGroups_SavedVars.extra_height = 380
            FriendGroups_UpdateSize()
        end
    },
    -- Horizontal divider separating list length (above) from list width (below).
    -- Width resizing is retail-only: MoP's fixed-width friends frame can't widen cleanly
    -- (Compat.CAN_RESIZE_WIDTH). Where these items are hidden the saved width flags are
    -- also never applied, so an imported retail profile cannot strand the list wide.
    { text = "", isTitle = true, condition = function() return Compat.CAN_RESIZE_WIDTH end },
    { text = L["SETTINGS_SIZE_WIDTH"], isSubTitle = true,
      condition = function() return Compat.CAN_RESIZE_WIDTH end },
    {
        text = L["SET_WIDTH_NARROW"],
        condition = function() return Compat.CAN_RESIZE_WIDTH end,
        checked = function() return not FriendGroups_SavedVars.wide_list and not FriendGroups_SavedVars.width_normal end,
        func = function()
            FriendGroups_SavedVars.wide_list = false
            FriendGroups_SavedVars.width_normal = false
            FriendGroups_UpdateSize()
            FriendGroups_FriendsListUpdate(true)
        end
    },
    {
        text = L["SET_WIDTH_NORMAL"],
        condition = function() return Compat.CAN_RESIZE_WIDTH end,
        checked = function() return FriendGroups_SavedVars.width_normal and not FriendGroups_SavedVars.wide_list end,
        func = function()
            FriendGroups_SavedVars.wide_list = false
            FriendGroups_SavedVars.width_normal = true
            FriendGroups_UpdateSize()
            FriendGroups_FriendsListUpdate(true)
        end
    },
    {
        text = L["SET_WIDTH_WIDE"],
        condition = function() return Compat.CAN_RESIZE_WIDTH end,
        checked = function() return FriendGroups_SavedVars.wide_list end,
        func = function()
            FriendGroups_SavedVars.wide_list = true
            FriendGroups_SavedVars.width_normal = false
            FriendGroups_UpdateSize()
            FriendGroups_FriendsListUpdate(true)
        end
    },

    -- [[ ROW FONT SCALE ]]
    -- Gated on the Social UI. The row fonts it scales are the ones Platform_SocialUI writes
    -- through FG_ShrinkFont; on 12.0.7 and Classic the rows take their size from Blizzard's
    -- own templates and nothing here would reach them. Showing the control where it cannot
    -- work is the same defect the EllesmereUI toggle had on 12.1, so it is hidden instead --
    -- exactly as the width items are hidden behind Compat.CAN_RESIZE_WIDTH.
    --
    -- The value is still STORED and still travels in a profile on every flavor, so a
    -- Classic round-trip cannot strip a retail user's choice.
    { text = "", isTitle = true, condition = function() return Compat.IsSocialUIActive() end },
    { text = L["SETTINGS_SIZE_FONT"], isSubTitle = true,
      condition = function() return Compat.IsSocialUIActive() end },
    {
        text = L["SET_FONT_SMALL"],
        condition = function() return Compat.IsSocialUIActive() end,
        checked = function() return FriendGroups_GetFontScale() == 1 end,
        func = function() FriendGroups_SetFontScale(1) end
    },
    {
        text = L["SET_FONT_MEDIUM"],
        condition = function() return Compat.IsSocialUIActive() end,
        checked = function() return FriendGroups_GetFontScale() == 2 end,
        func = function() FriendGroups_SetFontScale(2) end
    },
    {
        text = L["SET_FONT_LARGE"],
        condition = function() return Compat.IsSocialUIActive() end,
        checked = function() return FriendGroups_GetFontScale() == 3 end,
        func = function() FriendGroups_SetFontScale(3) end
    },

    -- SECTION 1: PRIVACY
    -- First section after the size controls, and deliberately ABOVE the Advanced split.
    -- This is flipped immediately before going live and immediately after coming off, so it
    -- has to be the first thing under the pointer when the menu opens -- a panic switch you
    -- have to hunt for is the same as not having one.
    { text = L["SETTINGS_PRIVACY"], notCheckable = true, isTitle = true },
    {
        text = L["SET_STREAMER_MODE"],
        tooltip = { L["SET_STREAMER_MODE_TT_1"], L["SET_STREAMER_MODE_TT_2"] },
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.streamer_mode end,
        func = function()
            FriendGroups_SavedVars.streamer_mode = not FriendGroups_SavedVars.streamer_mode
            FriendGroups_ApplyStreamerMode()
        end
    },

    -- SECTION 2: FILTERS
    { text = L["SETTINGS_FILTER"],    notCheckable = true, isTitle = true },
	{
        text = L["SET_HIDE_OFFLINE"],
        keepShownOnClick = true, 
        checked = function() return FriendGroups_SavedVars.hide_offline end,
        func = function()
            FriendGroups_SavedVars.hide_offline = not FriendGroups_SavedVars.hide_offline
            if FriendGroups_SavedVars.hide_offline then
                FriendGroups_SavedVars.offline_tracker = false
            end
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_HIDE_AFK"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.hide_afk end,
        func = function()
            FriendGroups_SavedVars.hide_afk = not FriendGroups_SavedVars.hide_afk
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_MOBILE_AFK"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_mobile_afk end,
        func = function()
            FriendGroups_SavedVars.show_mobile_afk = not FriendGroups_SavedVars.show_mobile_afk
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_HIDE_EMPTY"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.hide_empty_groups end,
        func = function()
            FriendGroups_SavedVars.hide_empty_groups = not FriendGroups_SavedVars.hide_empty_groups
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_INGAME_ONLY"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.ingame_only end,
        func = function()
            FriendGroups_SavedVars.ingame_only = not FriendGroups_SavedVars.ingame_only
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        -- Flavor-neutral: the filter tests Compat.IsSameProject, so one label serves
        -- both clients ("same game" = the game version this client is running).
        text = L["SET_SAME_GAME_ONLY"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_retail end,
        func = function()
            FriendGroups_SavedVars.show_retail = not FriendGroups_SavedVars.show_retail
            FriendGroups_FriendsListUpdate()
        end
    },

    -- SECTION 2: APPEARANCE
    { text = L["SETTINGS_APPEARANCE"], notCheckable = true, isTitle = true },
    {
        text = L["SET_CLASS_ICONS"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_class_icons ~= false end,
        func = function()
            FriendGroups_SavedVars.show_class_icons = not (FriendGroups_SavedVars.show_class_icons ~= false)
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_CLASS_COLOR"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.colour_classes end,
        func = function()
            FriendGroups_SavedVars.colour_classes = not FriendGroups_SavedVars.colour_classes
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_STATUS_INDICATOR"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_status ~= false end,
        func = function()
            FriendGroups_SavedVars.show_status = not (FriendGroups_SavedVars.show_status ~= false)
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_SHOW_NOTE"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_note ~= false end,
        func = function()
            FriendGroups_SavedVars.show_note = not (FriendGroups_SavedVars.show_note ~= false)
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_SHOW_REALM"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_realm end,
        func = function()
            FriendGroups_SavedVars.show_realm = not FriendGroups_SavedVars.show_realm
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_SHOW_FLAGS"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_flags end,
        func = function()
            FriendGroups_SavedVars.show_flags = not FriendGroups_SavedVars.show_flags
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_FACTION_ICONS"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_faction_icons end,
        func = function()
            FriendGroups_SavedVars.show_faction_icons = not FriendGroups_SavedVars.show_faction_icons
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_FACTION_COLOR"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_faction_color ~= false end,
        func = function()
            FriendGroups_SavedVars.show_faction_color = not (FriendGroups_SavedVars.show_faction_color ~= false)
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_GAME_ICON"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_game_icon ~= false end,
        func = function()
            FriendGroups_SavedVars.show_game_icon = not (FriendGroups_SavedVars.show_game_icon ~= false)
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_HIDE_MAX_LEVEL"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.hide_high_level end,
        func = function()
            FriendGroups_SavedVars.hide_high_level = not FriendGroups_SavedVars.hide_high_level
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        -- Bottom of Appearance; only shown when the EllesmereUI suite is detected.
        text = L["SET_EUI_SKIN"],
        tooltip = { L["SET_EUI_SKIN_TT"] },
        condition = function() return FriendGroupsEUISkin and FriendGroupsEUISkin.detected end,
        checked = function() return FriendGroups_SavedVars.eui_skin ~= false end,
        func = function()
            FriendGroups_SavedVars.eui_skin = not (FriendGroups_SavedVars.eui_skin ~= false)
            if FriendGroupsEUISkin and FriendGroupsEUISkin.RefreshEnabled then
                FriendGroupsEUISkin.RefreshEnabled()
            end
            StaticPopup_Show("FRIENDGROUPS_EUI_RELOAD")
        end
    },

    -- SECTION 3: GROUP SETTINGS
    { text = L["SETTINGS_BEHAVIOR"], notCheckable = true, isTitle = true, submenu = true },
    {
        text = L["SET_FAV_GROUP"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.add_favorite_group end,
        func = function()
            FriendGroups_SavedVars.add_favorite_group = not FriendGroups_SavedVars.add_favorite_group
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_GUILDMATES"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_guildmates end,
        func = function()
            FriendGroups_SavedVars.show_guildmates = not FriendGroups_SavedVars.show_guildmates
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_COLLAPSE"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.open_one_group end,
        func = function()
            FriendGroups_SavedVars.open_one_group = not FriendGroups_SavedVars.open_one_group
            FriendGroups_FriendsListUpdate()
        end
    },
	{
        text = L["SET_OFFLINE_TRACKER"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.offline_tracker end,
        func = function()
            FriendGroups_SavedVars.offline_tracker = not FriendGroups_SavedVars.offline_tracker
            if FriendGroups_SavedVars.offline_tracker then
                FriendGroups_SavedVars.hide_offline = false
                FriendGroups_SavedVars.hide_afk = false
                FriendGroups_SavedVars.show_mobile_afk = false
                FriendGroups_SavedVars.hide_empty_groups = false
                FriendGroups_SavedVars.ingame_only = false
                FriendGroups_SavedVars.show_retail = false
            end
            FriendGroups_FriendsListUpdate()
        end
    },

    -- [[ Everything below moves into the "Advanced" submenu (back-end config). ]]
    { isAdvancedStart = true },

	-- SECTION 4: AUTOMATION
    { text = L["SETTINGS_AUTOMATION"], notCheckable = true, isTitle = true },
    {
        text = L["SET_AUTO_ACCEPT"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_accept_invite end,
        func = function()
            FriendGroups_SavedVars.auto_accept_invite = not FriendGroups_SavedVars.auto_accept_invite
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_AUTO_PARTY_SYNC"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_accept_sync end,
        func = function()
            FriendGroups_SavedVars.auto_accept_sync = not FriendGroups_SavedVars.auto_accept_sync
            FriendGroups_FriendsListUpdate()
        end
    },
    -- The countdown toast is always shown for both automations above, and ownership is
    -- always ceded to GLogger when it is running with the matching automation enabled.
    -- Neither is exposed as a setting: the toast is the safety mechanism that makes
    -- auto-accept interruptible, and a "do not defer" override could not silence GLogger,
    -- only stack a second prompt on top.
    --
    -- Auto-accept resurrection and auto-release spirit lived here until 13.0.2. See the
    -- feature registry in Automation.lua for why they went, and BOOL_FIELDS in Sync.lua for
    -- why their two sync bits had to stay behind.

    -- SECTION 5: ALT CHARACTERS & CACHE
    { text = L["SETTINGS_ALT_CHARS"], notCheckable = true, isTitle = true },
    {
        text = L["SET_KNOWN_ALTS"],
        tooltip = { L["TOOLTIP_KNOWN_ALTS"] },
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_known_alts ~= false end,
        func = function()
            FriendGroups_SavedVars.show_known_alts = not (FriendGroups_SavedVars.show_known_alts ~= false)
            if not FriendGroups_SavedVars.show_known_alts then
                if FriendGroupsAltTooltip then 
                    FriendGroupsAltTooltip:Hide() 
                end
                if FriendGroups_SavedVars.alt_cache then 
                    wipe(FriendGroups_SavedVars.alt_cache) 
                end
                if FriendGroups_SavedVars.guid_index then 
                    wipe(FriendGroups_SavedVars.guid_index) 
                end
                if L["MSG_ALT_TRACKING_DISABLED"] then
                    print(L["MSG_ALT_TRACKING_DISABLED"])
                end
            end
        end
    },
	{
        text = L["SETTINGS_PURGE_CACHE"],
        notCheckable = true,
		func = function()
            -- 1. Purge Known Alts Cache (Private BNet)
            if FriendGroups_SavedVars.alt_cache then
                wipe(FriendGroups_SavedVars.alt_cache)
            end

            -- Last-known WoW-friend names. Wiped with the rest, and refills by itself the
            -- next time each friend is seen online -- until then those rows are searchable
            -- by note and group only, exactly as a fresh install behaves.
            if FriendGroups_SavedVars.wow_friend_names then
                wipe(FriendGroups_SavedVars.wow_friend_names)
            end
            
            -- 2. Purge Auto-Guild Caches & Known Guilds Memory
            if FriendGroups_SavedVars.alt_guild_rosters then
                wipe(FriendGroups_SavedVars.alt_guild_rosters)
            end
            if FriendGroups_SavedVars.bnet_guild_map then
                wipe(FriendGroups_SavedVars.bnet_guild_map)
            end
            if FriendGroups_SavedVars.known_player_guilds then
                wipe(FriendGroups_SavedVars.known_player_guilds)
            end
            
            -- Hide static panel if it is currently open
            if FriendGroupsAltTooltip then
                FriendGroupsAltTooltip:Hide()
            end
            
            -- 3. Force the native guild listener to flag the cache as dirty
            if C_GuildInfo and C_GuildInfo.GuildRoster then
                C_GuildInfo.GuildRoster()
            end
            
            print(L["MSG_PURGE_CACHE"])
        end
    },

    -- SECTION: PROFILE SYNC
    { text = L["SETTINGS_PROFILE"], notCheckable = true, isTitle = true },
    -- Timestamp of the last export, rendered as a subtitle under the section heading so it
    -- sits with the backup actions it describes. Skipped entirely when nothing was ever
    -- exported, which is why it is a marker the builder resolves rather than a static entry.
    { isBackupStamp = true },
    {
        text = L["SETTINGS_EXPORT"],
        notCheckable = true,
        tooltip = { L["TOOLTIP_EXPORT_1"], L["TOOLTIP_EXPORT_2"], L["TOOLTIP_EXPORT_3"] },
        func = function() FriendGroups_ShowExport() end
    },
    {
        text = L["SETTINGS_IMPORT"],
        notCheckable = true,
        tooltip = { L["TOOLTIP_IMPORT_1"], L["TOOLTIP_IMPORT_2"], L["TOOLTIP_IMPORT_3"] },
        func = function() StaticPopup_Show("FRIENDGROUPS_IMPORT") end
    },

    -- SECTION 6: SYSTEM & RESET
    { text = "", notCheckable = true, isTitle = true },
    {
        text = L["SETTINGS_RESET_ORDER"],
        notCheckable = true,
        func = function()
            if FriendGroups_SavedVars.group_order then
                wipe(FriendGroups_SavedVars.group_order)
            end
            FriendGroups_FriendsListUpdate()
        end
    },
	{
        text = L["SETTINGS_RESET"],
        notCheckable = true,
        func = function()
            CloseDropDownMenus()
            FriendGroups_SavedVars.hide_offline = false
            FriendGroups_SavedVars.colour_classes = true
            FriendGroups_SavedVars.show_class_icons = true
            FriendGroups_SavedVars.show_note = true
            FriendGroups_SavedVars.show_status = true
            FriendGroups_SavedVars.show_faction_icons = true
            FriendGroups_SavedVars.show_faction_color = true
            FriendGroups_SavedVars.show_game_icon = true
            FriendGroups_SavedVars.show_realm = true
            -- Was the ONE key present in the fresh-install defaults and absent here, so a
            -- reset silently left realm flags at whatever they already were instead of
            -- restoring them. Found by diffing the two lists rather than by reading; that
            -- diff is the check to repeat whenever a setting is added.
            FriendGroups_SavedVars.show_flags = true
            FriendGroups_SavedVars.hide_high_level = true
            FriendGroups_SavedVars.add_favorite_group = true
            FriendGroups_SavedVars.show_guildmates = true
            FriendGroups_SavedVars.gray_faction = false
            FriendGroups_SavedVars.show_mobile_afk = false
            FriendGroups_SavedVars.add_mobile_text = true
            FriendGroups_SavedVars.ingame_only = false
            FriendGroups_SavedVars.ingame_retail = false
            FriendGroups_SavedVars.show_btag = false
            FriendGroups_SavedVars.show_retail = false
            FriendGroups_SavedVars.show_search = true
            FriendGroups_SavedVars.hide_empty_groups = false
            FriendGroups_SavedVars.hide_afk = false
            FriendGroups_SavedVars.open_one_group = false
            FriendGroups_SavedVars.auto_accept_invite = true
            FriendGroups_SavedVars.auto_accept_sync = true
            FriendGroups_SavedVars.offline_tracker = true
            FriendGroups_SavedVars.streamer_mode = false
            FriendGroups_SavedVars.show_known_alts = true
            -- The three size axes at their defaults: Medium height, Wide panel, Small text.
            -- Written EXPLICITLY, never left nil, so the reset state is byte-identical to a
            -- fresh install rather than relying on what a missing value happens to read as.
            FriendGroups_SavedVars.extra_height = 190
            FriendGroups_SavedVars.wide_list = true
            FriendGroups_SavedVars.width_normal = false
            FriendGroups_SavedVars.font_size = 1
            FriendGroups_SavedVars.collapsed = {}
            FriendGroups_SavedVars.group_order = {}

            if type(Compat.OnFontScaleChanged) == "function" then
                Compat.OnFontScaleChanged()
            end
            FriendGroups_UpdateSize()
            FriendGroups_UpdateContactCap()
            FriendGroups_FriendsListUpdate()
            
            print(L["MSG_RESET"])
        end
    },
}

--[[
	Init Values
]] --

-- ============================================================================
-- [[ GUILD CACHE ENGINE (OPTIMIZED: LAZY HEARTBEAT & FINGERPRINTING) ]]
-- ============================================================================
local FriendGroups_GuildCacheDirty = true
local FriendGroups_PlayerGuildName = ""
local FriendGroups_LiveGuildSessionDict = {} -- [[ NEW: Fast O(1) Memory-Safe Lookup ]]

-- Live accessor for the platform renderers. addonTable.State shares tables by reference,
-- but a string cannot be, so the guild name is published as a closure over the upvalue
-- instead -- declared here rather than beside the State table above, which is built long
-- before this local exists and would capture a global lookup instead.
addonTable.State.GetPlayerGuildName = function() return FriendGroups_PlayerGuildName end

local fgGuildEventFrame = CreateFrame("Frame")
Compat.RegisterEvents(fgGuildEventFrame, {
    "GUILD_ROSTER_UPDATE",
    "PLAYER_GUILD_UPDATE",
})
fgGuildEventFrame:SetScript("OnEvent", function()
    -- [[ DIRTY FLAG BUCKET: Ignore event spam, just flip the switch ]]
    FriendGroups_GuildCacheDirty = true
end)

function FG_IsCharOnline(charKey)
    if not charKey then return false end
    
    local cName = strsplit("-", charKey)
    local wowFriend = C_FriendList.GetFriendInfo(cName)
    if wowFriend and wowFriend.connected then return true end
    
    local numBNetTotal = C_BattleNet and C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends and BNGetNumFriends() or 0
    if numBNetTotal > 0 then
        for i = 1, numBNetTotal do
            local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
            if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
                if accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
                    local bName = accountInfo.gameAccountInfo.characterName or ""
                    local bRealm = FriendGroups_CleanRealmName(accountInfo.gameAccountInfo.realmName or accountInfo.gameAccountInfo.realmDisplayName or "")
                    if (bName .. "-" .. bRealm) == charKey then return true end
                end
            end
        end
    end
    return false
end

function FriendGroups_BuildGuildCache()
    if not FriendGroups_GuildCacheDirty then return end
    
    if not FriendGroups_SavedVars.known_player_guilds then
        FriendGroups_SavedVars.known_player_guilds = {}
    end
    
    local guildName = GetGuildInfo("player")
    FriendGroups_PlayerGuildName = (type(guildName) == "string") and guildName or ""
    
    if FriendGroups_PlayerGuildName ~= "" then
        FriendGroups_SavedVars.known_player_guilds[FriendGroups_PlayerGuildName] = true
        wipe(FriendGroups_LiveGuildSessionDict)
        
        -- Fallback chain: Modern C_ API first, legacy global second
        local numTotal = (C_GuildInfo and C_GuildInfo.GetNumGuildMembers) and C_GuildInfo.GetNumGuildMembers() or GetNumGuildMembers()
        local myRealm = GetNormalizedRealmName()
        
        for i = 1, numTotal do
            -- Safe capture of the first return value, supporting both future tables and legacy multi-var returns
            local name = (C_GuildInfo and C_GuildInfo.GetGuildRosterInfo) and C_GuildInfo.GetGuildRosterInfo(i) or GetGuildRosterInfo(i)
            
            if name and type(name) == "string" then
                local baseName, realmName = strsplit("-", name)
                if baseName then
                    local targetRealm = realmName or myRealm
                    if targetRealm and type(targetRealm) == "string" then
                        local cleanRealm = FriendGroups_CleanRealmName(targetRealm)
                        local uniqueKey = baseName .. "-" .. cleanRealm
                        
                        FriendGroups_LiveGuildSessionDict[uniqueKey] = true
                        FriendGroups_LiveGuildSessionDict[baseName] = true
                    end
                end
            end
        end
    else
        wipe(FriendGroups_LiveGuildSessionDict)
    end
    
    if FriendGroups_SavedVars.alt_guild_rosters then FriendGroups_SavedVars.alt_guild_rosters = nil end
    if FriendGroups_SavedVars.bnet_guild_map then FriendGroups_SavedVars.bnet_guild_map = nil end
    
    FriendGroups_GuildCacheDirty = false
end

-- [[ THE LAZY HEARTBEAT ]]
local function FriendGroups_LazyGuildScanner()
    if FriendGroups_GuildCacheDirty then
        FriendGroups_BuildGuildCache()
    end
    C_Timer.After(180, FriendGroups_LazyGuildScanner)
end
C_Timer.After(5, FriendGroups_LazyGuildScanner)


--[[
	Helper Functions
]] --

function FriendGroups_DebugLog(tData, strName)
	if not DevTool then
		LoadAddOn("DevTool")
	end
	if DevTool then
		DevTool:AddData(tData, strName)
	end
end

local FriendGroups_OriginalHeight = nil
local FriendGroupsList_OriginalHeight = nil
local FriendGroups_OriginalWidth = nil
local FriendGroupsList_OriginalWidth = nil

-- Fixed amount (in pixels) the contacts window grows by when "Widen Contact List" is on.
-- Sized to comfortably fit a full "aka [MainName]" suffix that the standard width clips.
FriendGroups_WideListExtra = 150

-- [[ WIDTH MODE READERS ]]
-- Every consumer of wide_list / width_normal goes through these two functions, so a
-- client that cannot resize (Compat.CAN_RESIZE_WIDTH false -- Classic's fixed-width
-- frame art) reports "no extra width" regardless of what the saved variables hold.
-- That is what keeps an imported retail profile inert on Classic, where the width menu
-- is hidden and the user would otherwise have no way back to the default width. It also
-- heals an install already carrying the flags from an earlier build: nothing is
-- rewritten, the values are just never read, so they survive a re-export.
-- FriendGroups_SavedVars is guarded because these are called from the row renderer,
-- which can run before the ADDON_LOADED handler seeds the table on a fresh profile.

-- True only where the full-width mode is both selected AND supported.
function FriendGroups_IsWideList()
    if not Compat.CAN_RESIZE_WIDTH then return false end
    local sv = FriendGroups_SavedVars
    return (sv ~= nil and sv.wide_list) and true or false
end

-- Extra horizontal pixels for the current width mode: Wide = full, Normal = half,
-- Narrow (and every non-resizable client) = 0.
function FriendGroups_GetExtraWidth()
    if not Compat.CAN_RESIZE_WIDTH then return 0 end
    local sv = FriendGroups_SavedVars
    if sv == nil then return 0 end
    if sv.wide_list then return FriendGroups_WideListExtra end
    if sv.width_normal then return math.floor(FriendGroups_WideListExtra / 2) end
    return 0
end

function FriendGroups_UpdateSize()
    -- 1. Store the original Blizzard defaults the very first time we run
    if not FriendGroups_OriginalHeight then
        FriendGroups_OriginalHeight = FriendsFrame:GetHeight()
        FriendGroupsList_OriginalHeight = FriendsListFrame:GetHeight()
    end
    if not FriendGroups_OriginalWidth then
        FriendGroups_OriginalWidth = FriendsFrame:GetWidth()
        FriendGroupsList_OriginalWidth = FriendsListFrame:GetWidth()
    end

    -- 2. Determine target height/width based on saved variables
    local extra = FriendGroups_SavedVars.extra_height or 0
    -- Width: Narrow (0) / Normal (half) / Wide (full). Two booleans encode the three
    -- states (wide_list takes priority over width_normal); the reader returns 0 on any
    -- client that cannot resize, making the SetWidth below a no-op back to the captured
    -- Blizzard default there. Height is unconditional -- every flavor resizes vertically.
    local extraWidth = FriendGroups_GetExtraWidth()

    -- 3. Apply
    FriendsFrame:SetHeight(FriendGroups_OriginalHeight + extra)
    FriendsListFrame:SetHeight(FriendGroupsList_OriginalHeight + extra)
    FriendsFrame:SetWidth(FriendGroups_OriginalWidth + extraWidth)
    FriendsListFrame:SetWidth(FriendGroupsList_OriginalWidth + extraWidth)

    -- 4. Re-anchor ScrollBox to fill the new space (ScrollBox clients only).
    if Compat.HAS_SCROLLBOX then
        FriendsListFrame.ScrollBox:ClearAllPoints()
        FriendsListFrame.ScrollBox:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 7, -115)
        FriendsListFrame.ScrollBox:SetPoint("BOTTOMRIGHT", FriendsListFrame, "BOTTOMRIGHT", -28, 35)
    else
        -- Classic: the native HybridScroll button pool is sized to the default frame
        -- height. After resizing the frame, create enough buttons to fill it so a Large
        -- list shows more rows instead of empty space (CreateButtons appends until the
        -- current height is covered). Deferred a frame so the scroll frame's anchored
        -- height reflects the new size before it is measured.
        local sf = FriendsFrameFriendsScrollFrame
        if sf and HybridScrollFrame_CreateButtons then
            C_Timer.After(0, function()
                HybridScrollFrame_CreateButtons(sf, "FriendsFrameButtonTemplate")
                if FriendGroups_FriendsListUpdate then FriendGroups_FriendsListUpdate(true) end
            end)
        end
    end
end

function FriendGroups_Rename(self, oldGroup)
	local input = self:GetEditBox():GetText()
    
	if input == "" or not oldGroup then return end

	-- Migrate any manual ordering rank so the renamed group keeps its position.
	if FriendGroups_SavedVars.group_order and FriendGroups_SavedVars.group_order[oldGroup] ~= nil then
		FriendGroups_SavedVars.group_order[input] = FriendGroups_SavedVars.group_order[oldGroup]
		FriendGroups_SavedVars.group_order[oldGroup] = nil
	end

	local groups = {}
    -- Modern API prioritization for total friends
    local numBNetTotal = C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
    
	for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo then
            local presenceID = accountInfo.bnetAccountID
            local noteText = accountInfo.note
            local note = FriendGroups_NoteAndGroups(noteText, groups)
            if groups[oldGroup] then
                groups[oldGroup] = nil
                groups[input] = true
                note = FriendGroups_CreateNote(note, groups)
                
                -- Modern API prioritization for setting notes
                if C_BattleNet.SetFriendNote then
                    C_BattleNet.SetFriendNote(presenceID, note)
                else
                    BNSetFriendNote(presenceID, note)
                end
            end
        end
	end
    
    local numWoWTotal = C_FriendList.GetNumFriends and C_FriendList.GetNumFriends() or 0
	for i = 1, numWoWTotal do
		local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo then
            local note = friendInfo.notes
            local name = friendInfo.name
            note = FriendGroups_NoteAndGroups(note, groups)

            if groups[oldGroup] then
                groups[oldGroup] = nil
                groups[input] = true
                note = FriendGroups_CreateNote(note, groups)
                C_FriendList.SetFriendNotes(name, note)
            end
        end
	end
	FriendGroups_FriendsListUpdate()
end

function FriendGroups_InviteOrGroup(groupName, invite)
    if invite then
        -- Use the live UI cache so we only invite exactly who is visible in the group
        if not groupsTotal[groupName] then return end

        local inviteDelay = 0
        
        for _, playerData in ipairs(groupsTotal[groupName]) do
            local id = playerData.id
            local buttonType = playerData.buttonType

            if buttonType == FRIENDS_BUTTON_TYPE_BNET then
                local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(id)
                if friendAccountInfo and friendAccountInfo.gameAccountInfo then
                    local gameAccountInfo = friendAccountInfo.gameAccountInfo
                    
                    -- Only invite BNet friends whose live WoW session is on OUR project;
                    -- cross-project accounts cannot be grouped and would silently fail.
                    if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and Compat.IsSameProject(gameAccountInfo) then
                        local gameAccountID = gameAccountInfo.gameAccountID
                        if gameAccountID then
                            C_Timer.After(inviteDelay, function()
                                BNInviteFriend(gameAccountID)
                            end)
                            inviteDelay = inviteDelay + 0.2
                        end
                    end
                end
            elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
                local friend_info = C_FriendList.GetFriendInfoByIndex(id)
                if friend_info and friend_info.connected and friend_info.name then
                    local charName = friend_info.name
                    C_Timer.After(inviteDelay, function()
                        Compat.InviteUnit(charName)
                    end)
                    inviteDelay = inviteDelay + 0.2
                end
            end
        end
    else
        -- Removing a group still relies on text parsing to strip the hashtag out of the raw notes
        local groups = {}

        local numBNetTotal = C_BattleNet and C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
        for i = 1, numBNetTotal do
            local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(i)
            if friendAccountInfo then
                local presenceID = friendAccountInfo.bnetAccountID
                local noteText = friendAccountInfo.note
                local note = FriendGroups_NoteAndGroups(noteText, groups)
                if groups[groupName] then
                    groups[groupName] = nil
                    note = FriendGroups_CreateNote(note, groups)
                    if C_BattleNet and C_BattleNet.SetFriendNote then
                        C_BattleNet.SetFriendNote(presenceID, note)
                    else
                        BNSetFriendNote(presenceID, note)
                    end
                end
            end
        end
        for i = 1, C_FriendList.GetNumFriends() do
            local friend_info = C_FriendList.GetFriendInfoByIndex(i)
            if friend_info then
                local name = friend_info.name
                local noteText = friend_info.notes
                local note = FriendGroups_NoteAndGroups(noteText, groups)

                if groups[groupName] then
                    groups[groupName] = nil
                    note = FriendGroups_CreateNote(note, groups)
                    C_FriendList.SetFriendNotes(name, note)
                end
            end
        end
    end
end

function FriendGroups_AddGroup(note, group)
	local groups = {}
	note = FriendGroups_NoteAndGroups(note, groups)
	groups[""] = nil
	groups[group] = true
	return FriendGroups_CreateNote(note, groups)
end

-- Add a manual <GuildName> tag to a note. Placed in the free-text portion (before the
-- first # hashtag) so it isn't swallowed into a group name. No-op if already present.
function FriendGroups_AddGuildTag(note, guildName)
	note = (type(note) == "string") and note or ""
	if not guildName or guildName == "" then return note end
	local tag = "<" .. guildName .. ">"
	if note:find(tag, 1, true) then return note end
	if note == "" then return tag end
	return tag .. " " .. note
end

-- Strip a manual <GuildName> tag (and one adjacent space) from a note. Plain-text
-- matching so guild names with magic characters are handled safely.
function FriendGroups_RemoveGuildTag(note, guildName)
	note = (type(note) == "string") and note or ""
	if not guildName or guildName == "" then return note end
	local tag = "<" .. guildName .. ">"
	local s, e = note:find(tag, 1, true)
	while s do
		-- Consume one adjacent space (prefer trailing, since AddGuildTag puts it there).
		if note:sub(e + 1, e + 1) == " " then
			e = e + 1
		elseif note:sub(s - 1, s - 1) == " " then
			s = s - 1
		end
		note = note:sub(1, s - 1) .. note:sub(e + 1)
		s, e = note:find(tag, 1, true)
	end
	return note
end

-- ============================================================================
-- [[ NOTE GRAMMAR ]]
-- The friend note is the addon's persistent store. Three token types, disjoint
-- delimiters, one terminator:
--
--     @[Nickname]  <GuildName>  free text  #Group1#Group2
--
--   #Group     -- group membership. Everything from the FIRST '#' to the end of
--                 the note is groups (FriendGroups_GetPlayerGroups).
--   <Guild>    -- manual guild-group membership (FriendGroups_AddGuildTag).
--   @[Nick]    -- custom nickname (below).
--
-- The note is the SINGLE SOURCE OF TRUTH for all three. Nothing about membership
-- or nicknames is persisted anywhere else -- FriendGroups_SavedVars.nicknames is a
-- derived cache, rebuilt from notes (see NICKNAME RECONCILE). Editing the note by
-- hand, including from the Battle.net desktop or mobile app, is therefore a fully
-- supported way to set any of them.
--
-- The delimiters are WIRE FORMAT and are never localized. (Contrast the auto guild
-- group, whose *label* is localized: a localized delimiter would break every note
-- the moment the player switched client language or flavor.)
--
-- Square brackets rather than a bare "@Nick" are load-bearing. The reconcile pass
-- reads notes the addon did not write, and real notes contain incidental '@'
-- characters ("met @ Blackrock", "ping me @ 8pm"); a bare-'@' grammar would adopt
-- those as nicknames. "@[" is a sequence essentially nobody types by accident, and
-- the closing bracket lets a nickname contain spaces ("@[Osiris the Kiwi]") without
-- swallowing whatever the user wrote after it.
-- ============================================================================

local FG_NICKNAME_PATTERN = "@%[([^%]]*)%]"

-- Nickname parses are memoized per note string, mirroring FriendGroups_NoteCache:
-- FriendGroups_SetGroups runs this for every friend on every rebuild. Kept as a
-- separate table rather than widening NoteCache's value shape, which four call
-- sites depend on. Same bounded-growth flush rule.
local FriendGroups_NickCache = {}
local FriendGroups_NickCacheCount = 0

-- Read the nickname tag out of a note. Returns "" when absent.
-- Sanitizes on read: hand-authored tags are untrusted input.
function FriendGroups_GetNicknameTag(note)
	if type(note) ~= "string" or note == "" then return "" end

	local cached = FriendGroups_NickCache[note]
	if cached ~= nil then return cached end

	if FriendGroups_NickCacheCount > 1500 then
		wipe(FriendGroups_NickCache)
		FriendGroups_NickCacheCount = 0
	end

	-- First match wins if a hand-edited note somehow carries several tags; our own
	-- writer collapses them to one on the next explicit Set Nickname.
	local nick = Compat.SanitizeNickname(note:match(FG_NICKNAME_PATTERN) or "")

	FriendGroups_NickCache[note] = nick
	FriendGroups_NickCacheCount = FriendGroups_NickCacheCount + 1
	return nick
end

-- Strip every @[...] tag from a note, consuming one adjacent space per removal so
-- the remaining text does not accumulate gaps. Mirrors FriendGroups_RemoveGuildTag.
function FriendGroups_StripNicknameTag(note)
	if type(note) ~= "string" or note == "" then return "" end
	local s, e = note:find(FG_NICKNAME_PATTERN)
	while s do
		if note:sub(e + 1, e + 1) == " " then
			e = e + 1
		elseif note:sub(s - 1, s - 1) == " " then
			s = s - 1
		end
		note = note:sub(1, s - 1) .. note:sub(e + 1)
		s, e = note:find(FG_NICKNAME_PATTERN)
	end
	return note
end

-- Return `note` with its nickname tag replaced by `nick` (or removed when `nick` is
-- empty). Replace-not-append, so repeated writes are idempotent.
--
-- The tag is placed FIRST. The Battle.net desktop and mobile clients render the note
-- in a narrow column and truncate it, and leading position is the only position that
-- survives that truncation -- which is the entire point of storing it there. This also
-- matches FriendGroups_AddGuildTag, which likewise prepends.
--
-- Callers must check the result against Compat.BNET_NOTE_MAXBYTES before writing.
function FriendGroups_SetNicknameTag(note, nick)
	local rest = FriendGroups_StripNicknameTag(note)
	rest = rest:match("^%s*(.-)%s*$") or ""

	nick = Compat.SanitizeNickname(nick)
	if nick == "" then return rest end

	local tag = "@[" .. nick .. "]"
	if rest == "" then return tag end
	return tag .. " " .. rest
end

-- Strip the nickname tag for DISPLAY. The row already renders the nickname as the
-- friend's bold name, so leaving the tag in the appended note text duplicates it.
function FriendGroups_NoteForDisplay(note)
	if type(note) ~= "string" then return "" end
	return strtrim(FriendGroups_StripNicknameTag(note))
end

-- ============================================================================
-- [[ NICKNAME RECONCILE ]]
-- FriendGroups_SavedVars.nicknames is a CACHE of what the notes say, not a store.
-- It exists only so the four read sites (the name-text builder and the sort-key
-- builder) keep their current signatures -- neither has a note in scope.
--
-- Reconcile is deliberately DESTRUCTIVE: a note with no @[...] tag clears the cache
-- entry, which is what makes deleting the tag from the Battle.net app remove the
-- nickname in game. That power is why the guards below are not optional:
--
--   * Only accounts actually ENUMERATED in a pass are ever touched. The cache is
--     never iterated and diffed against the roster, so a short or empty friend list
--     (during login, or before BN_CONNECTED) cannot wipe anything -- the loop simply
--     does not run for absent friends.
--   * A note that is not a readable string means UNKNOWN, not "no tag". Under 12.0.7
--     presence reduction a field can read as absent; that must never delete.
--   * Nothing reconciles until FriendGroups_NicknameSyncReady is set, which happens
--     only after the one-time migration has completed (or was never needed).
--
-- Entries for removed friends are left alone rather than pruned: pruning would mean
-- diffing against the roster, reintroducing the wipe hazard, and the entry self-heals
-- anyway (re-add that friend with a tagless note and this clears it).
-- ============================================================================

-- The single identity a Battle.net contact is filed under: nicknames, the alt cache, manual
-- mains, assignment caches -- all of them key by this.
--
-- The obvious `battleTag or accountName` is WRONG on 12.1 and was the cause of two separate
-- bugs. A title friend ("WoW Friend") reports battleTag as an EMPTY STRING rather than nil,
-- and "" is truthy in Lua -- so that expression collapsed every title friend onto the single
-- shared key "". ReconcileNickname bails on an empty identifier, so their nicknames were never
-- cached and never rendered; ShowButtonAltTooltip does not bail, so every title friend's alts
-- were filed together and unrelated players appeared in each other's panels.
--
-- Treating empty as absent fixes both, and is harmless on every earlier client, where the
-- field is either a real BattleTag or nil.
-- Colour a group header's label should be drawn in, or nil to leave it alone.
--
--   explicit font_colors override  -> that colour
--   banner colour set, no override -> white, because the default grey label is close to
--                                     unreadable once a saturated banner sits behind it
--   no banner                      -> nil, so the header keeps its normal appearance
--
-- Shared by both renderers so the two platforms cannot drift.
function FriendGroups_HeaderFontRGB(groupName)
	if type(groupName) ~= "string" or groupName == "" then return nil end
	if type(FriendGroups_SavedVars) ~= "table" then return nil end

	local override = FriendGroups_SavedVars.font_colors and FriendGroups_SavedVars.font_colors[groupName]
	if type(override) == "string" and #override >= 6 then
		return (tonumber(override:sub(1, 2), 16) or 255) / 255,
			(tonumber(override:sub(3, 4), 16) or 255) / 255,
			(tonumber(override:sub(5, 6), 16) or 255) / 255
	end

	local banner = FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName]
	if type(banner) == "string" and #banner >= 6 then
		return 1, 1, 1
	end

	return nil
end

addonTable.State.HeaderFontRGB = FriendGroups_HeaderFontRGB

function FriendGroups_AccountIdentifier(accountInfo)
	if type(accountInfo) ~= "table" then return nil end

	local tag = accountInfo.battleTag
	if type(tag) == "string" and tag ~= "" then return tag end

	local name = accountInfo.accountName
	if type(name) == "string" and name ~= "" then return name end

	return nil
end

addonTable.State.AccountIdentifier = FriendGroups_AccountIdentifier

FriendGroups_NicknameSyncReady = false

function FriendGroups_ReconcileNickname(accountInfo)
	if not FriendGroups_NicknameSyncReady then return end
	if not accountInfo or not FriendGroups_SavedVars then return end

	local note = accountInfo.note
	if type(note) ~= "string" then return end

	local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
	if type(accountIdentifier) ~= "string" or accountIdentifier == "" then return end

	if not FriendGroups_SavedVars.nicknames then
		FriendGroups_SavedVars.nicknames = {}
	end

	local nick = FriendGroups_GetNicknameTag(note)

	-- FriendGroups nicknames and 12.1's native "Edit Name" are deliberately SEPARATE stores.
	-- They look similar but do different jobs: the nickname is this addon's, lives in the
	-- Battle.net note, covers both friend tiers, shows in the Battle.net app and travels in a
	-- Sync profile. Edit Name is Blizzard's per-title custom name and is theirs alone.
	--
	-- An earlier build mirrored one onto the other. It could not work: with the note treated
	-- as authoritative, the first edit ADOPTED the native name, and every edit after was
	-- overwritten back from the note on the next roster pass -- two stores fighting over one
	-- value, which is what "it writes both, then stops updating" looked like from outside.

	FriendGroups_SavedVars.nicknames[accountIdentifier] = (nick ~= "") and nick or nil
end

function FriendGroups_Create(self, data)
	local input = self:GetEditBox():GetText()
	if input == "" then
		return
	end
	local note = FriendGroups_AddGroup(data.note, input)
	if data.name then
		data.set(data.name, note)
	else
		data.set(data.id, note)

		FriendGroups_SavedVars.collapsed[input] = true
	end
end

function FriendGroups_NoteAndGroups(note, groups)
    -- 12.0 FIX: Secure note string check to prevent strsplit crash
    if type(note) ~= "string" then note = "" end

	if not note or note == "" then
		return FriendGroups_FillGroups(groups, "")
	end
	if groups then
		return FriendGroups_FillGroups(groups, strsplit("#", note))
	end
	return strsplit("#", note)
end

function FriendGroups_RemoveGroup(note, group)
	local groups = {}
	note = FriendGroups_NoteAndGroups(note, groups)
	groups[""] = nil
	groups[group] = nil

	return FriendGroups_CreateNote(note, groups)
end

function FriendGroups_CreateNote(note, groups)
	local value = ""
	if note then
		value = note
	end
	for group in pairs(groups) do
		value = value .. "#" .. group
	end
	return value
end

function FriendGroups_FillGroups(groups, note, ...)
	wipe(groups)
	local n = select('#', ...)
	for i = 1, n do
		local v = select(i, ...)
		v = strtrim(v)
		groups[v] = true
	end
	if n == 0 then
		groups[""] = true
	end
	return note
end

function FriendGroups_HasValue(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function FriendGroups_SplitBattleTag(battleTag)
	if type(battleTag) ~= "string" then return battleTag end

	local sep = "#"
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(battleTag, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t[1]
end

function FriendGroups_GetClassColorCode(class, returnTable)
	if not class then
		return returnTable and FRIENDS_GRAY_COLOR or
			string.format("|cFF%02x%02x%02x", FRIENDS_GRAY_COLOR.r * 255, FRIENDS_GRAY_COLOR.g * 255,
				FRIENDS_GRAY_COLOR.b * 255)
	end

	local initialClass = class
	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		if class == v then
			class = k
			break
		end
	end

	if class == initialClass then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			if class == v then
				class = k
				break
			end
		end
	end

	local color = class ~= "" and RAID_CLASS_COLORS[class] or FRIENDS_GRAY_COLOR
	if returnTable then
		return color
	else
		return string.format("|cFF%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
	end
end

FriendGroups_ActiveAKA = {}

-- ============================================================================
-- [[ STREAMER MODE ]]
-- Reveals the first three characters of a name and replaces the rest, so a contact list
-- left on screen during a broadcast stays readable to its owner without publishing who is
-- on it. Display only, in every sense that matters:
--
--   * nothing masked is ever written back -- not to the alt cache, not to a note, not to
--     an export. Masking happens at the point a string is handed to a fontstring, so the
--     saved variables cannot be poisoned by having the mode switched on;
--   * search still matches on the REAL values. Typing a name finds the contact and then
--     shows them masked, which is the only behaviour that is not maddening to use;
--   * whisper, invite and copy paths never come through here, so they keep the real name.
--
-- Three CHARACTERS, not three bytes. Slicing UTF-8 by byte count would cut a Cyrillic or
-- CJK name mid-sequence and render replacement boxes.
--
-- [[ AND NEVER MORE THAN HALF THE NAME ]]
-- Three is a ceiling, not a quota. A fixed three reveals a proportion of the name that
-- depends entirely on how long the name is, and CJK is where that falls apart: a four-
-- character Chinese name is a whole name, so "拾贰国记" -> "拾贰国***" published three
-- quarters of it and read as unmasked, while the same three letters off "Backhawksleg"
-- give away almost nothing. Latin names run long and CJK names do not, so counting
-- codepoints alone does not make the locales equivalent -- capping at half the name does.
--
--   Backhawksleg (12)  -> Bac***      three, the ceiling
--   拾贰国记      (4)   -> 拾贰***      half
--   Kiwi         (4)   -> Ki***       half
--   Kiw          (3)   -> K***        half, rounded down, floored at one
-- ============================================================================

-- Byte offset just past the first `maxChars` UTF-8 characters, and how many were found.
-- A malformed lead byte is treated as one character so this can never loop or overrun.
local function FG_Utf8Walk(s, maxChars)
	local i, n, len = 1, 0, #s
	while i <= len and n < maxChars do
		local b = s:byte(i)
		i = i + ((b >= 240 and 4) or (b >= 224 and 3) or (b >= 192 and 2) or 1)
		n = n + 1
	end
	if i > len + 1 then i = len + 1 end
	return i, n
end

-- Characters to reveal from a name of `total` characters: at most three, never more than
-- half, never fewer than one.
local FG_MASK_MAX_REVEAL = 3
local function FG_RevealCount(total)
	local half = math.floor(total / 2)
	if half > FG_MASK_MAX_REVEAL then half = FG_MASK_MAX_REVEAL end
	if half < 1 then half = 1 end
	return half
end

-- Mask a single plain-text name. Returns the mask suffix ALONE whenever there is nothing
-- safe to reveal, which is the honest answer for the cases below rather than a guess.
function FriendGroups_MaskName(name)
	if type(name) ~= "string" or name == "" then
		return L["STREAMER_MASK_SUFFIX"]
	end

	-- A 12.1 title friend's accountName is a |K escape -- "|Kj2|k", six bytes the client
	-- resolves from its own name cache at draw time. Taking three characters off it yields
	-- "|Kj", a broken escape that renders as literal junk. There is no prefix of this value
	-- that means anything, so it is never sliced. FriendGroups_StreamerName below reaches
	-- for the remembered plain-text name first, and only lands here when there is none.
	if name:find("|K", 1, true) then
		return L["STREAMER_MASK_SUFFIX"]
	end
	if issecretvalue and issecretvalue(name) then
		return L["STREAMER_MASK_SUFFIX"]
	end

	-- The realm half and the BattleTag discriminator are dropped rather than masked: they
	-- are not part of the name, and "Kiw***-Nobundo" narrows the field far more than the
	-- three revealed letters do.
	local clean = name:match("^(.-)%-") or name
	clean = clean:match("^(.-)#") or clean
	if clean == "" then
		return L["STREAMER_MASK_SUFFIX"]
	end

	-- Walked to the ceiling's worth plus one, which is all the length information the reveal
	-- rule needs: anything longer than 2 * FG_MASK_MAX_REVEAL reveals the ceiling either way,
	-- so a 40-character name costs the same walk as a four-character one.
	local _, total = FG_Utf8Walk(clean, FG_MASK_MAX_REVEAL * 2)
	local stop = select(1, FG_Utf8Walk(clean, FG_RevealCount(total)))
	return clean:sub(1, stop - 1) .. L["STREAMER_MASK_SUFFIX"]
end

-- ============================================================================
-- [[ SESSION NAME MAP ]]
-- Plain-text names observed THIS SESSION, keyed by bnetAccountID. A file-local, so it is
-- empty at every login by construction -- which is the entire point.
--
-- FriendGroups_SavedVars.wow_friend_names records the same fact permanently, and this is
-- PREFERRED over it rather than a replacement for it: a name captured this session is known
-- to belong to the contact it is filed under, whereas the persisted copy is keyed on
-- bnetAccountID, which the API documents as a TEMPORARY SESSION ID.
--
-- Reading the session map ALONE was tried and was worse. It is correct, but for an offline
-- title friend never seen online this session there is nothing to read, so most of the list
-- collapsed to a row of indistinguishable "[***]" -- which defeats the point of revealing
-- any characters at all. The persisted name remains the fallback: a stale one costs a few
-- misleading characters, a missing one costs the feature.
--
-- Note the two can legitimately disagree even when nothing is stale. The persisted name is
-- the character the contact was last seen PLAYING, while the row displays their canonical
-- title-friend name; a contact whose main is Monkbeemix but who last logged in on an alt
-- will mask from the alt. There is no fix for that while the displayed name is a Kstring
-- the addon cannot read -- see [[wow-121-kstring-friend-names]].
-- ============================================================================
local FriendGroups_SessionNames = {}

function FriendGroups_RememberSessionName(bnetAccountID, name)
	if type(bnetAccountID) ~= "number" then return end
	if type(name) ~= "string" or name == "" then return end
	FriendGroups_SessionNames[bnetAccountID] = name
end

-- Session name first, persisted name second. Both are plain text captured while the contact
-- was online; the first is guaranteed to be theirs, the second only very probably.
local function FG_RememberedName(bnetAccountID)
	if type(bnetAccountID) ~= "number" then return nil end

	local session = FriendGroups_SessionNames[bnetAccountID]
	if type(session) == "string" and session ~= "" then return session end

	if type(FriendGroups_SavedVars) == "table"
		and type(FriendGroups_SavedVars.wow_friend_names) == "table" then
		local entry = FriendGroups_SavedVars.wow_friend_names[bnetAccountID]
		if entry and type(entry.name) == "string" and entry.name ~= "" then
			return entry.name
		end
	end

	return nil
end

-- True when a value can actually be sliced -- real text, not a |K escape and not a secret.
local function FG_IsMaskable(value)
	if type(value) ~= "string" or value == "" then return false end
	if value:find("|K", 1, true) then return false end
	if issecretvalue and issecretvalue(value) then return false end
	return true
end

-- [[ WHY THIS EXISTS: ON 12.1 THE ACCOUNT NAME IS NEVER TEXT ]]
-- accountName is documented as a Kstring for the WHOLE Battle.net friend list on 12.1, not
-- just for the title tier -- the client resolves it from its own name cache at draw time.
-- So masking accountName directly gave a bare "*** " for every single contact, which is
-- what a first pass at this did.
--
-- The fix is to mask the first candidate that is REAL TEXT, in preference order, rather
-- than the first candidate that exists:
--   battleTag           plain on 12.1 (FriendGroups_SplitBattleTag has always sliced it),
--                       and its name half is the closest thing to a stable identity;
--   characterName       plain, but only while the friend is online;
--   a remembered name   captured while its owner was online, this session for preference and
--                       from the saved cache otherwise -- see FG_RememberedName above.
-- Falls through to the suffix alone only when every candidate is an escape.
function FriendGroups_MaskFirstPlain(...)
	for i = 1, select("#", ...) do
		local candidate = select(i, ...)
		if FG_IsMaskable(candidate) then
			return FriendGroups_MaskName(candidate)
		end
	end
	return L["STREAMER_MASK_SUFFIX"]
end

-- Mask for display, resolving the |K case through a remembered plain-text name.
function FriendGroups_StreamerName(name, accountInfo)
	local gameInfo = accountInfo and accountInfo.gameAccountInfo
	return FriendGroups_MaskFirstPlain(
		name,
		accountInfo and accountInfo.battleTag,
		gameInfo and gameInfo.characterName,
		accountInfo and FG_RememberedName(accountInfo.bnetAccountID))
end

-- The one place the setting is read. Every call site asks this rather than testing the
-- saved variable itself, so the mode cannot end up half-applied by a site that checked a
-- differently-spelled flag.
function FriendGroups_IsStreamerMode()
	return type(FriendGroups_SavedVars) == "table" and FriendGroups_SavedVars.streamer_mode == true
end

-- Repaint everything the mode touches. Toggling it changes only what is DRAWN -- no group
-- membership, no note, no cached value -- so the assignment cache is deliberately left
-- alone and this is a pure re-render.
--
-- The rebuild is FORCED. A settings change never dirties the roster, so the throttled path
-- would take its rosterUnchanged shortcut and return without drawing anything, and the mode
-- would appear not to work until some unrelated friend event happened to come along.
function FriendGroups_ApplyStreamerMode()
	FriendGroups_FriendsListUpdate(true)
	if Compat and type(Compat.RefreshOwnBattleTag) == "function" then
		Compat.RefreshOwnBattleTag()
	end
end

-- gameInfo (the friend's gameAccountInfo) resolves WHICH game's level cap applies
-- for the hide-max-level rule; nil-safe (Compat.IsMaxLevel fails open and shows
-- the level when the friend's game cannot be determined).
function FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag, timerunningSeasonID, realmName, gameInfo)
	local nameText

	-- set up player name and character name
	-- Empty-string battleTags (12.1 title friends) must resolve to the account name, not to "".
	local accountIdentifier = (type(battleTag) == "string" and battleTag ~= "") and battleTag or accountName
	local streamerMode = FriendGroups_IsStreamerMode()

	-- Nicknames are deliberately NOT masked. They are the user's own words for someone, not
	-- that person's identity, and a nicknamed contact never renders an account name at all
	-- (this branch replaces it), so those rows are already private.
	if FriendGroups_SavedVars and FriendGroups_SavedVars.nicknames and accountIdentifier and FriendGroups_SavedVars.nicknames[accountIdentifier] then
		nameText = "|cFF00FF00" .. FriendGroups_SavedVars.nicknames[accountIdentifier] .. "|r"
	elseif accountName then
		if streamerMode then
			-- battleTag FIRST, whichever display setting is on: on 12.1 accountName is a
			-- Kstring for every contact, so masking it directly would print "***" for the
			-- whole list. The tag's name half is real text and survives the friend going
			-- offline, which characterName does not.
			nameText = FriendGroups_MaskFirstPlain(battleTag, accountName, characterName)
		elseif FriendGroups_SavedVars.show_btag and battleTag then
			nameText = FriendGroups_SplitBattleTag(battleTag)
		else
			nameText = accountName
		end
	else
		nameText = UNKNOWN
	end

	-- append character name
	if characterName then
		-- [[ RAW FOR COMPARISON, MASKED FOR DISPLAY ]]
		-- characterName itself stays untouched below because the "aka" test compares against
		-- it, and a masked or icon-prefixed value would never match the remembered main.
		--
		-- That separation also repairs a latent bug: AddSmallIcon used to overwrite
		-- characterName with "|T...|t Name" BEFORE the aka comparison ran, so a timerunning
		-- friend could never match their own main and the aka tag showed while they were
		-- standing on it.
		local displayCharacterName = characterName
		if streamerMode then
			displayCharacterName = FriendGroups_MaskName(displayCharacterName)
		end
		if timerunningSeasonID then
			displayCharacterName = TimerunningUtil.AddSmallIcon(displayCharacterName)
		end

		local levelSuffix
		if (not level) or level == 0 or (FriendGroups_SavedVars.hide_high_level and Compat.IsMaxLevel(gameInfo, level)) then
			levelSuffix = ""
		else
			levelSuffix = " " .. level
		end

        -- [[ NEW: Separate AKA string generation (Outside of Suffix Brackets) ]]
        local akaText = ""
        -- Empty-string battleTags (12.1 title friends) must resolve to the account name, not to "".
        local accountIdentifier = (type(battleTag) == "string" and battleTag ~= "") and battleTag or accountName
        if accountIdentifier and FriendGroups_ActiveAKA and FriendGroups_ActiveAKA[accountIdentifier] then
            local akaInfo = FriendGroups_ActiveAKA[accountIdentifier]
            -- Only render the AKA if they are not actively logged into the main character.
            -- The match must compare BOTH name and realm: a friend can have a same-named
            -- character on a different realm (e.g. main Snarge-Area52 vs. current
            -- Snarge-Proudmoore), and a name-only check would wrongly hide the aka there.
            local onMainCharacter = (akaInfo.name == characterName)
            if onMainCharacter and akaInfo.realm and realmName and realmName ~= "" then
                onMainCharacter = (FriendGroups_CleanRealmName(akaInfo.realm) == FriendGroups_CleanRealmName(realmName))
            end
            if akaInfo.name and not onMainCharacter then
                local akaDisplayName = akaInfo.name
                if streamerMode then
                    akaDisplayName = FriendGroups_MaskName(akaDisplayName)
                end
                local akaFormattedName = "[" .. akaDisplayName .. "]"

                -- Apply class or faction colors strictly to the name inside the AKA brackets
                if FriendGroups_SavedVars.colour_classes and akaInfo.class then
                    akaFormattedName = FriendGroups_GetClassColorCode(akaInfo.class) .. akaFormattedName .. FONT_COLOR_CODE_CLOSE
                elseif not canCoop and FriendGroups_SavedVars.gray_faction then
                    akaFormattedName = "|cFF949694" .. akaFormattedName .. "|r"
                end
                
                if L["FORMAT_AKA_DISPLAY"] then
                    akaText = string.format(L["FORMAT_AKA_DISPLAY"], akaFormattedName)
                end
            end
        end

		if client == BNET_CLIENT_WOW then
			if characterName ~= "" and level ~= 0 then
				if not canCoop and FriendGroups_SavedVars.gray_faction then
					nameText = "|CFF949694" .. nameText .. " [" .. displayCharacterName .. "]" .. levelSuffix .. "|r"
				elseif FriendGroups_SavedVars.colour_classes then
					local nameColor = FriendGroups_GetClassColorCode(class)
					nameText = nameText .. " " .. nameColor .. "[" .. displayCharacterName .. "]" .. FONT_COLOR_CODE_CLOSE .. levelSuffix
				else
					nameText = nameText .. " [" .. displayCharacterName .. "]" .. FONT_COLOR_CODE_CLOSE .. levelSuffix
				end
			end
		else
			nameText = nameText .. " " .. FRIENDS_OTHER_NAME_COLOR_CODE .. "[" .. displayCharacterName .. "]" .. FONT_COLOR_CODE_CLOSE .. levelSuffix
		end
        
        -- [[ Append the newly formatted AKA text outside the main brackets ]]
        nameText = nameText .. akaText
	end

	return nameText
end

-- ============================================================================
-- [[ MEMORY OPTIMIZATION & CACHING ]]
-- ============================================================================
local FriendGroups_TablePool = {}
local FriendGroups_NoteCache = { [""] = {} }
local FriendGroups_WorkingGroupTable = {}

local function FG_GetTable()
    local t = table.remove(FriendGroups_TablePool) or {}
    wipe(t)
    return t
end

local function FG_ReleaseTable(t)
    if type(t) == "table" then
        wipe(t)
        table.insert(FriendGroups_TablePool, t)
    end
end

local FriendGroups_NoteCacheCount = 0

function FriendGroups_GetPlayerGroups(note)
    -- 12.0 FIX: Secure note string check to prevent string.match crash
    if type(note) ~= "string" then note = "" end
    
    if note == "" then 
        return FriendGroups_NoteCache[""] 
    end

    if FriendGroups_NoteCache[note] then
        return FriendGroups_NoteCache[note]
    end

    -- Safety Flush: Prevent infinite memory bloat from external note-sync addons
    if FriendGroups_NoteCacheCount > 1500 then
        wipe(FriendGroups_NoteCache)
        FriendGroups_NoteCache[""] = {}
        FriendGroups_NoteCacheCount = 0
    end

    local groups = {}
    local formattedNote = string.match(note, "#.*")

    if formattedNote then
        for s in string.gmatch(formattedNote, "[^#]+") do
            table.insert(groups, s)
        end
    end

    FriendGroups_NoteCache[note] = groups
    FriendGroups_NoteCacheCount = FriendGroups_NoteCacheCount + 1
    
    return groups
end

function FriendGroups_GetPlayerData(friendsListData, playerId, playerType)
	for _, playerData in pairs(friendsListData) do
		if playerData and playerData.id and playerData.id == playerId and playerData.buttonType and playerData.buttonType == playerType then
			return playerData
		end
	end

	return nil
end

function FriendGroups_ShowRichPresenceOnly(client, wowProjectID, faction, realmID, areaName)
	if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
		return true;
	elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= playerFactionGroup) or (realmID ~= playerRealmID)) then
		return true;
	else
		-- Display Rich Presence as a safety fallback if the areaName is explicitly blank or nil.
        -- This accurately catches Plunderstorm, Character Select screens, and transitional loading states.
		if (client == BNET_CLIENT_WOW) and (wowProjectID == WOW_PROJECT_ID) then
			if not areaName or areaName == "" then
				return true;
			end
		end

		return false;
	end;
end

function FriendGroups_GetOnlineInfoText(client, isMobile, rafLinkType, locationText, realmText)
	if not locationText then
		return UNKNOWN;
	end

	if isMobile then
		return LOCATION_MOBILE_APP;
	end
	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
		if rafLinkType == Enum.RafLinkType.Recruit then
			return RAF_RECRUIT_FRIEND:format(locationText);
		else
			return RAF_RECRUITER_FRIEND:format(locationText);
		end
	end

	if FriendGroups_SavedVars.show_realm and realmText and realmText ~= "" then
		locationText = locationText .. " - " .. realmText
	end

	return locationText;
end

function FriendGroups_GetFriendInfoById(id)
	local accountName, characterName, class, level, isFavoriteFriend, isOnline,
	bnetAccountId, client, canCoop, wowProjectID, lastOnline,
	isAFK, isGameAFK, isDND, isGameBusy, mobile, zoneName, battleTag, factionName,
	gameText, realmName, timerunningSeasonID

    -- 12.0 FIX: Strictly use C_BattleNet. Old global BNet functions are permanently removed.
	if C_BattleNet and C_BattleNet.GetFriendAccountInfo then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)
		if accountInfo then
			accountName = accountInfo.accountName
			isFavoriteFriend = accountInfo.isFavorite
			bnetAccountId = accountInfo.bnetAccountID
			isAFK = accountInfo.isAFK
			isDND = accountInfo.isDND
			lastOnline = accountInfo.lastOnlineTime
			battleTag = accountInfo.battleTag

			local gameAccountInfo = accountInfo.gameAccountInfo
			if gameAccountInfo then
				isOnline = gameAccountInfo.isOnline
				isGameAFK = gameAccountInfo.isGameAFK
				isGameBusy = gameAccountInfo.isGameBusy
				mobile = gameAccountInfo.isWowMobile
				characterName = gameAccountInfo.characterName
				class = gameAccountInfo.className
				level = gameAccountInfo.characterLevel
				client = gameAccountInfo.clientProgram
				wowProjectID = gameAccountInfo.wowProjectID
				gameText = gameAccountInfo.richPresence
				zoneName = gameAccountInfo.areaName
				realmName = gameAccountInfo.realmName
				factionName = gameAccountInfo.factionName
				timerunningSeasonID = gameAccountInfo.timerunningSeasonID
			end

			if Compat.IS_MAINLINE then
				canCoop = CanCooperateWithGameAccount(accountInfo)
			else
				-- Classic's CanCooperateWithGameAccount expects a numeric BNet account ID
				-- (it calls BNGetGameAccountInfo internally); the account table crashes it.
				canCoop = bnetAccountId and CanCooperateWithGameAccount(bnetAccountId) or false
			end
		end
	end

	if realmName and realmName ~= "" then
		if zoneName then
			zoneName = zoneName .. " - " .. realmName
		end
	end

	return accountName, characterName, class, level, isFavoriteFriend, isOnline,
		bnetAccountId, client, canCoop, wowProjectID, lastOnline,
		isAFK, isGameAFK, isDND, isGameBusy, mobile, zoneName, gameText, battleTag, factionName, timerunningSeasonID
end

function FriendGroups_GetFactionIcon(factionGroup)
	if (factionGroup and factionGroup ~= "" and factionGroup ~= "Neutral") then
		return "Interface\\FriendsFrame\\PlusManz-" .. factionGroup;
	else
		return ""
	end
end

function FriendGroups_GetStatusString(playerData)
	local status = "Offline"

	if playerData.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(playerData.id)

		if friendAccountInfo then
			local gameAccountInfo = friendAccountInfo.gameAccountInfo

			if friendAccountInfo.isAFK and gameAccountInfo and gameAccountInfo.isOnline then
				status = "AFK"
			end

			if friendAccountInfo.isDND and gameAccountInfo and gameAccountInfo.isOnline then
				status = "DND"
			end

			if not friendAccountInfo.isAFK and not friendAccountInfo.isDND then
				if gameAccountInfo.isOnline then
					status = "Online"

					if gameAccountInfo.isGameBusy then
						status = "DND"
					end

					if gameAccountInfo.isGameAFK then
						status = "AFK"
					end

					if gameAccountInfo.clientProgram == "BSAp" then
						status = status .. "Mobile"
					end

					if gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
						status = status .. "InGame"
					end
				end
			end
		end
	elseif playerData.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local friendInfo = C_FriendList.GetFriendInfoByIndex(playerData.id)

		if friendInfo.connected then
			status = "OnlineInGame"

			if friendInfo.dnd then
				status = "DNDInGame"
			end

			if friendInfo.afk then
				status = "AFKInGame"
			end
		end
	end

	return status
end

function FriendGroups_SortTableByStatus(playerA, playerB)
	if not playerA then
		playerA = {}
	end

	if not playerB then
		playerB = {}
	end

	-- 1. Presence tier: actively in WoW first, then otherwise-online, then offline.
	local rankA = playerA.isInGame and 1 or (playerA.isOnline and 2 or 3)
	local rankB = playerB.isInGame and 1 or (playerB.isOnline and 2 or 3)
	if rankA ~= rankB then
		return rankA < rankB
	end

	-- 2. Nickname subgroup: custom-nicknamed friends first within the presence tier.
	--    Their sortName is the nickname itself, so tier 4 orders them by nickname.
	local nickA = playerA.hasNickname and 1 or 2
	local nickB = playerB.hasNickname and 1 or 2
	if nickA ~= nickB then
		return nickA < nickB
	end

	-- 3. Battle.net account friends before WoW-character friends within the same tier.
	--
	-- buttonType alone stopped answering this on 12.1. Both tiers now arrive through the one
	-- C_BattleNet enumeration, so the roster pass labels every row _BNET, this test compared
	-- 2 == 2 for every pair, and the whole tier silently fell through to alphabetical -- a
	-- Battle.net friend sorting below two WoW friends purely on spelling.
	--
	-- The real tier is Compat.IsTitleFriend, resolved during the roster pass and carried here
	-- on playerData. Compat.RenderSocialUIList derives exactly the same thing for the card,
	-- but that runs AFTER sorting, so it could never inform this.
	--
	-- Both signals are read so one comparator serves every flavor: 12.0.7 and Classic fill
	-- buttonType from separate enumerations, 12.1 fills isTitleFriend.
	local typeA = (not playerA.isTitleFriend and playerA.buttonType == FRIENDS_BUTTON_TYPE_BNET) and 1 or 2
	local typeB = (not playerB.isTitleFriend and playerB.buttonType == FRIENDS_BUTTON_TYPE_BNET) and 1 or 2
	if typeA ~= typeB then
		return typeA < typeB
	end

	-- 4. Alphabetical by display name (nickname for nicknamed friends)
	local nameA = playerA.sortName or ""
	local nameB = playerB.sortName or ""
	if nameA ~= nameB then
		return nameA < nameB
	end

	-- 5. Deterministic backstop (unique per friend within the same tier/type)
	return (playerA.id or 0) < (playerB.id or 0)
end

-- ============================================================================
-- [[ OFFLINE TRACKER GROUPS ]]
-- The four buckets an offline contact is filed into, ordered shortest absence first.
--
-- Rank 1 (GROUP_OFFLINE_0) is the CATCH-ALL, and it is what makes the set a partition of
-- "offline" rather than three special cases. It holds everyone the dated tiers cannot
-- claim: gone less than a month, and -- more importantly -- everyone whose absence is not
-- datable at all. A 12.1 title friend has no Battle.net account behind it, so
-- accountInfo.lastOnlineTime reads 0 for that whole tier, and a legacy C_FriendList friend
-- has no such field in the first place. Before this bucket existed both of those fell
-- through the tracker entirely and were left scattered through the custom groups.
--
-- Built ONCE from L rather than compared inline. These three names were hand-written into
-- eight separate three-way comparisons across two files, so a fourth bucket would have had
-- to be added to every one of them -- and a missed site does not error, it merely reads as
-- a cosmetic oddity (a header printing "0/13" instead of "13", or a system group that
-- suddenly answers to drag-and-drop). One table, one predicate, one rank.
--
-- Safe to resolve at file scope: the TOC loads locales\localizations.xml before this file,
-- so L is fully populated here and never changes afterwards. Missing keys are skipped
-- rather than indexed, so a locale that has not been updated degrades to "that bucket does
-- not exist" instead of erroring on a nil table key.
-- ============================================================================
local FriendGroups_OfflineGroupRankMap = {}
do
	local orderedKeys = { "GROUP_OFFLINE_0", "GROUP_OFFLINE_1", "GROUP_OFFLINE_2", "GROUP_OFFLINE_3" }
	for i = 1, #orderedKeys do
		local groupName = L[orderedKeys[i]]
		if type(groupName) == "string" and groupName ~= "" then
			FriendGroups_OfflineGroupRankMap[groupName] = i
		end
	end
end

-- 1..4 for an offline-tracker group, nil for anything else. Global because the Social UI
-- renderer needs the same answer for its header text, and a file-local cannot be shared.
function FriendGroups_OfflineGroupRank(groupName)
	return FriendGroups_OfflineGroupRankMap[groupName]
end

function FriendGroups_IsOfflineGroup(groupName)
	return FriendGroups_OfflineGroupRankMap[groupName] ~= nil
end

-- ============================================================================
-- [[ MANUAL GROUP ORDER ENGINE ]]
-- Layers a manual ordering on top of the automatic hierarchy. Each movable group
-- may carry a fractional rank in FriendGroups_SavedVars.group_order (keyed by group
-- name, matching the existing collapsed[] / banner_colors[] convention). Groups with
-- no rank fall back to their automatic position, so untouched lists behave exactly as
-- before. The fixed system anchors below are never movable.
-- ============================================================================
local FriendGroups_AutoPos = {}        -- [groupName] = automatic sort index (1..N)
local FriendGroups_MovableOrder = {}   -- array of movable group names in display order
local FriendGroups_MovableIndex = {}   -- [groupName] = index within FriendGroups_MovableOrder

local function FriendGroups_IsFixedAnchor(groupName)
	return groupName == L["GROUP_NONE"]
		or groupName == L["GROUP_EMPTY"]
		or groupName == ""
		or FriendGroups_IsOfflineGroup(groupName)
end

local function FriendGroups_GetEffectiveRank(groupName)
	local order = FriendGroups_SavedVars and FriendGroups_SavedVars.group_order
	if order and order[groupName] ~= nil and not FriendGroups_IsFixedAnchor(groupName) then
		return order[groupName]
	end
	return FriendGroups_AutoPos[groupName] or 0
end

-- Force the friends ScrollBox to repaint a reordered list. The rebuild restores the
-- scroll to the SAME percentage (a no-op that fires no scroll event), so the box keeps
-- showing the old rows until you scroll. We reproduce a real scroll: nudge the offset a
-- hair, then restore it (no interpolation = invisible), which re-acquires the row frames.
local function FG_ForceScrollRedraw()
	local sb = FriendsListFrame and FriendsListFrame.ScrollBox
	if not sb then return end
	if sb.FullUpdate then sb:FullUpdate(true) end
	if sb.GetScrollPercentage and sb.SetScrollPercentage then
		local noInterp = ScrollBoxConstants and ScrollBoxConstants.NoScrollInterpolation
		local p = sb:GetScrollPercentage() or 0
		sb:SetScrollPercentage((p >= 1) and (p - 0.01) or (p + 0.01), noInterp)
		sb:SetScrollPercentage(p, noInterp)
	elseif sb.Update then
		sb:Update()
	end
end

-- Re-sort, then repaint now AND on the next frame. The context menu is still closing
-- when the click handler runs, which can swallow the immediate repaint of the new order
-- (the cause of "had to click move twice"); the deferred pass lands after it closes.
local function FG_RefreshOrderNow()
	if FriendGroups_FriendsListUpdate then FriendGroups_FriendsListUpdate(true) end
	FG_ForceScrollRedraw()
	if C_Timer and C_Timer.After then
		C_Timer.After(0, FG_ForceScrollRedraw)
	end
end

local function FriendGroups_MoveGroup(groupName, direction)
	if not groupName or FriendGroups_IsFixedAnchor(groupName) then return end
	if not FriendGroups_SavedVars.group_order then
		FriendGroups_SavedVars.group_order = {}
	end

	-- Copy the current movable order, swap by one, then assign DENSE integer ranks to
	-- every movable group. Dense ranks make each click move exactly one position (no
	-- fractional ties with auto-positions that silently leave the order unchanged), and
	-- keep exports collision-free (no movable group falls back to an auto index).
	local arr = {}
	for i = 1, #FriendGroups_MovableOrder do arr[i] = FriendGroups_MovableOrder[i] end

	local idx
	for i = 1, #arr do if arr[i] == groupName then idx = i break end end
	if not idx then return end

	local swapWith = idx + (direction < 0 and -1 or 1)
	if swapWith < 1 or swapWith > #arr then return end
	arr[idx], arr[swapWith] = arr[swapWith], arr[idx]

	local order = FriendGroups_SavedVars.group_order
	for i = 1, #arr do order[arr[i]] = i end

	FG_RefreshOrderNow()
end

-- Absolute-destination counterpart to FriendGroups_MoveGroup, for drag and drop: a pointer
-- names a place to land rather than a direction to step. Same dense-rank rewrite, same
-- refusal to move a fixed anchor, so both input methods leave group_order in one shape.
--
-- targetSlot is an INSERTION SLOT in the movable order as it looks right now, meaning "put
-- this group before whatever currently sits at this slot"; #MovableOrder + 1 means last.
-- Removing the group first shifts everything after it up by one, so a downward move has to
-- compensate -- the classic off-by-one in list reordering, handled explicitly below.
local function FriendGroups_MoveGroupToIndex(groupName, targetSlot)
	if not groupName or FriendGroups_IsFixedAnchor(groupName) then return end
	if type(targetSlot) ~= "number" then return end
	if not FriendGroups_SavedVars.group_order then
		FriendGroups_SavedVars.group_order = {}
	end

	local arr = {}
	for i = 1, #FriendGroups_MovableOrder do arr[i] = FriendGroups_MovableOrder[i] end

	local idx
	for i = 1, #arr do if arr[i] == groupName then idx = i break end end
	if not idx then return end

	targetSlot = math.floor(targetSlot)
	if targetSlot < 1 then targetSlot = 1 end
	if targetSlot > #arr + 1 then targetSlot = #arr + 1 end

	-- Dropping onto its own slot, or the one immediately after, is a no-op.
	if targetSlot == idx or targetSlot == idx + 1 then return end

	table.remove(arr, idx)
	if targetSlot > idx then targetSlot = targetSlot - 1 end
	if targetSlot < 1 then targetSlot = 1 end
	if targetSlot > #arr + 1 then targetSlot = #arr + 1 end
	table.insert(arr, targetSlot, groupName)

	local order = FriendGroups_SavedVars.group_order
	for i = 1, #arr do order[arr[i]] = i end

	FG_RefreshOrderNow()
end

-- Published for the platform renderers: all three are file-locals, and the Social UI's
-- drag-and-drop needs to ask whether a group may move, where it currently sits, and to place
-- it somewhere new.
addonTable.State.MoveGroupToIndex = FriendGroups_MoveGroupToIndex
addonTable.State.IsFixedAnchor = FriendGroups_IsFixedAnchor
addonTable.State.GetMovableIndex = function(groupName) return FriendGroups_MovableIndex[groupName] end
addonTable.State.GetMovableCount = function() return #FriendGroups_MovableOrder end

local function FriendGroups_ResetGroupPosition(groupName)
	if groupName and FriendGroups_SavedVars.group_order then
		FriendGroups_SavedVars.group_order[groupName] = nil
	end
	FG_RefreshOrderNow()
end

function FriendGroups_SortGroupsCustom(groupA, groupB)
	if groupA == L["GROUP_FAVORITES"] then
		return true
	end
    if groupB == L["GROUP_FAVORITES"] then
        return false
    end

    local isGuildA = string.find(groupA, L["GROUP_GUILDMATES"], 1, true)
    local isGuildB = string.find(groupB, L["GROUP_GUILDMATES"], 1, true)

    if isGuildA and not isGuildB then
        return true
    end
    if isGuildB and not isGuildA then
        return false
    end

	-- [[ OFFLINE BLOCK ]]
	-- Pinned as a contiguous block at the very BOTTOM of the list, below [No Group], in
	-- absence order. Tested before the [No Group] rule below precisely so it outranks it:
	-- [No Group] is a list of people who are around and simply untagged, which is far more
	-- useful to have in reach than a bucket of people who are not here at all.
	--
	-- These groups previously had NO rule here at all and fell through to the plain string
	-- compare below, which put them wherever their localized name happened to sort. Two
	-- things came out of that, both invisible until you look for them:
	--
	--   * The block landed in the MIDDLE of the custom groups. "[" is byte 91, so
	--     "[Offline 1 Month]" sorted after a group named "Raiders" but before one named
	--     "alts" -- and because these are fixed anchors, they could not be dragged out of
	--     wherever that put them.
	--   * A plain "[Offline]" sorts LAST of the four in every locale checked, because a
	--     space (32) beats "]" (93) at the point the names diverge. The catch-all would
	--     have appeared BELOW "[Offline 3+ Months]", inverting the reading order.
	--
	-- Ranking on the key rather than on the translation makes the order identical in all
	-- twelve locales instead of an artefact of how each one worded the string.
	local offlineRankA = FriendGroups_OfflineGroupRank(groupA)
	local offlineRankB = FriendGroups_OfflineGroupRank(groupB)
	if offlineRankA and offlineRankB then
		return offlineRankA < offlineRankB
	end
	if offlineRankA then return false end
	if offlineRankB then return true end

	-- [No Group] is last of everything that is left -- i.e. last except for the offline
	-- block resolved above.
	if groupA == L["GROUP_NONE"] then
		return false
	end
	if groupB == L["GROUP_NONE"] then
		return true
	end

	return groupA < groupB
end

-- Phase-2 comparator: order by effective rank (manual override or automatic position),
-- breaking ties by the automatic order and then name for determinism.
function FriendGroups_SortGroupsByRank(groupA, groupB)
	local ea = FriendGroups_GetEffectiveRank(groupA)
	local eb = FriendGroups_GetEffectiveRank(groupB)
	if ea ~= eb then
		return ea < eb
	end

	local pa = FriendGroups_AutoPos[groupA] or 0
	local pb = FriendGroups_AutoPos[groupB] or 0
	if pa ~= pb then
		return pa < pb
	end

	return groupA < groupB
end

local FriendGroups_AssignmentCache = {}
local FriendGroups_CacheGeneration = 0

-- ============================================================================
-- [[ UNIQUE ONLINE COUNTER ]]
-- ============================================================================
-- The counter beside the search box reports DISTINCT online contacts. Three kinds of
-- duplication have to collapse for that number to be honest:
--   * one friend, many groups (Favorites + a guild + a custom group) -> keyed per
--     friend rather than per group row, so membership never inflates the total;
--   * one BNet account playing several game accounts -> already one row per account;
--   * a BNet friend who is ALSO on the WoW character list -> the two lists are walked
--     separately, so they are stitched back together by the GUID of the character the
--     friend is logged into (see FriendGroups_ResolveOnlineKey).
-- Filled during FriendGroups_FriendsListUpdate's single pass, read by
-- FriendGroups_UpdateContactCap.
local FriendGroups_OnlineKeys = {}      -- [identityKey] = true, every unique online contact
local FriendGroups_OnlineByGroup = {}   -- [groupName] = { [identityKey] = true }
local FriendGroups_OnlineGuidKeys = {}  -- [playerGuid] = identityKey, online BNet characters
local FriendGroups_OnlineTotal = 0

-- Published for the platform renderers. On 12.1 the online-contact counter has no fontstring
-- of its own -- the legacy one is parented to the hidden FriendsListFrame -- so the Social UI
-- renders this number into the panel title instead, and needs to read it from outside.
addonTable.State.GetOnlineTotal = function() return FriendGroups_OnlineTotal end

-- Visibility rules for an ONLINE friend, shared by the roster build and the online
-- counter so the tooltip's per-group numbers can never drift from the group headers.
-- Offline friends are handled separately by the caller.
local function FriendGroups_PassesOnlineFilters(statusText, client, isSameProject)
    if FriendGroups_SavedVars.hide_afk and (statusText == "AFK" or statusText == "AFKMobile") then
        return false
    end
    if FriendGroups_SavedVars.ingame_only and client ~= BNET_CLIENT_WOW then
        return false
    end
    if FriendGroups_SavedVars.show_retail and client == BNET_CLIENT_WOW and not isSameProject then
        return false
    end
    return true
end

-- Resolves the identity key an online friend is counted under. A BNet friend registers
-- the GUID of the character they are currently playing; a WoW character friend on that
-- same character then resolves to the BNet key instead of minting its own, so one human
-- on both friend lists counts once. This depends on FriendGroups_FriendsListUpdate
-- walking the BNet list before the WoW list.
local function FriendGroups_ResolveOnlineKey(buttonType, accountIdentifier, id, playerGuid)
    if buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local key = accountIdentifier and ("B:" .. accountIdentifier) or ("B#" .. tostring(id))
        if playerGuid and playerGuid ~= "" then
            FriendGroups_OnlineGuidKeys[playerGuid] = key
        end
        return key
    elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
        if playerGuid and playerGuid ~= "" then
            return FriendGroups_OnlineGuidKeys[playerGuid] or ("W:" .. playerGuid)
        end
        return "W#" .. tostring(id)
    end
    return nil
end

function FriendGroups_SetGroups(id, buttonType, passedAccountInfo)
    local noteText = ""
    local statusText = "Offline"
    local favorite = false
    local charName, client, isOnline, isRetail, isSameProject, accountIdentifier = "", "", false, false, false, nil
    local altCacheCount = 0
    -- Readable alphabetical key for a 12.1 WoW-friend row. Their accountIdentifier is the
    -- |K escape, which sorts by an opaque client id instead of by anything the player can
    -- see; this carries a real name out of the Battle.net branch for the sort key below.
    local titleSortName = nil
    -- True for a 12.1 "WoW Friend" (title tier). These arrive through the SAME Battle.net
    -- enumeration as real account friends, so buttonType cannot tell them apart -- this is
    -- what carries the real tier to the sort. Always false on 12.0.7 and Classic, where the
    -- two tiers still come from separate enumerations and buttonType is already correct.
    local isTitleFriend = false
    -- GUID of the character this friend is logged into; links the BNet and WoW friend
    -- lists together for the unique online counter. Nil when offline or not in WoW.
    local playerGuid = nil

    -- Inline state resolution to completely bypass redundant API table allocations
    if buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local friendAccountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(id)
        if friendAccountInfo then
            noteText = friendAccountInfo.note or ""
            favorite = friendAccountInfo.isFavorite
            accountIdentifier = FriendGroups_AccountIdentifier(friendAccountInfo)

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            if gameAccountInfo then
                isOnline = gameAccountInfo.isOnline
                client = gameAccountInfo.clientProgram
                isRetail = (gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE)
                -- Same-project drives the "show only <this client>'s friends" filter:
                -- retail-identical (self == mainline) and correct on Classic (self == Classic).
                isSameProject = Compat.IsSameProject(gameAccountInfo)
                charName = (type(gameAccountInfo.characterName) == "string") and gameAccountInfo.characterName or ""

                -- [[ LAST-KNOWN NAME CAPTURE ]]
                -- A 12.1 WoW-friend's accountName is a |K escape the client resolves at draw
                -- time (measured: #accountName == 6 for a row reading "Backhawksleg-Nobundo"),
                -- so it can be displayed but never compared. The ONE moment their name exists
                -- as plain text is while they are online, in gameAccountInfo -- so it is
                -- recorded then and used to answer searches after they log off.
                --
                -- Keyed on bnetAccountID, NEVER on the |K escape. That escape is "|Kj<n>|k",
                -- an index into the client's own name cache, which there is every reason to
                -- believe is session-scoped -- persisting data under it would file one friend's
                -- name against another after a reload.
                --
                -- [[ NOT GATED ON THE TITLE TIER ]]
                -- This used to require Compat.IsTitleFriend, on the reasoning that the title
                -- ("WoW Friend") tier was the one whose accountName is a Kstring. Two things
                -- make that gate wrong:
                --
                --   accountName is documented as a Kstring for the WHOLE 12.1 Battle.net
                --   friend list, not just that tier (see FriendGroups_MaskFirstPlain), so
                --   every contact benefits from a plain-text name being on file;
                --
                --   and the tier can be ABSENT. IsTitleFriend resolves through
                --   FriendsListUtil.IsTitleFriend / Enum.BattleNetFriendLevel.Title, and on a
                --   12.1 client where the Social UI was walked back neither need exist -- so
                --   the gate answered false for every friend, nothing was ever recorded, and
                --   the offline-name recovery in FriendGroups_Search had an empty table to
                --   read. Search by name then failed for exactly the contacts it was built
                --   for, with no error to say why.
                --
                -- FG_IsMaskable replaces it as the real precondition: is this value plain text
                -- we can compare and store, rather than an escape or a secret value.
                if FG_IsMaskable(charName) then
                    local key = friendAccountInfo.bnetAccountID
                    if type(key) == "number" and type(FriendGroups_SavedVars.wow_friend_names) == "table" then
                        local realmValue = gameAccountInfo.realmName
                        local realm = FG_IsMaskable(realmValue) and realmValue or ""
                        FriendGroups_SavedVars.wow_friend_names[key] = { name = charName, realm = realm }
                        -- Same fact, recorded again in a table that does NOT survive the
                        -- session. See FriendGroups_SessionNames for why the persisted copy
                        -- cannot be trusted to name the right person.
                        FriendGroups_RememberSessionName(key, charName)
                    end
                end
                playerGuid = (type(gameAccountInfo.playerGuid) == "string") and gameAccountInfo.playerGuid or nil

                if friendAccountInfo.isAFK and isOnline then statusText = "AFK"
                elseif friendAccountInfo.isDND and isOnline then statusText = "DND"
                elseif isOnline then
                    statusText = "Online"
                    if gameAccountInfo.isGameBusy then statusText = "DND"
                    elseif gameAccountInfo.isGameAFK then statusText = "AFK" end
                    if client == "BSAp" then statusText = statusText .. "Mobile" end
                    if client == BNET_CLIENT_WOW then statusText = statusText .. "InGame" end
                end
            end
            
            if accountIdentifier and FriendGroups_SavedVars and type(FriendGroups_SavedVars.alt_cache) == "table" and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
                altCacheCount = #FriendGroups_SavedVars.alt_cache[accountIdentifier]
            end

            -- [[ READABLE SORT KEY FOR WoW-FRIEND ROWS ]]
            -- Resolved OUTSIDE the gameAccountInfo block above, because the remembered name
            -- has to be reachable when there is no session at all -- which is the case this
            -- exists for. Live name first, remembered name second.
            isTitleFriend = Compat.IsTitleFriend(friendAccountInfo)
            if isTitleFriend then
                if charName ~= "" then
                    titleSortName = charName
                elseif type(FriendGroups_SavedVars.wow_friend_names) == "table" then
                    local remembered = FriendGroups_SavedVars.wow_friend_names[friendAccountInfo.bnetAccountID]
                    if remembered and remembered.name and remembered.name ~= "" then
                        titleSortName = remembered.name
                    end
                end
            end
        end
    elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = passedAccountInfo or C_FriendList.GetFriendInfoByIndex(id)
        if info then
            noteText = info.notes or ""
            isOnline = info.connected
            client = BNET_CLIENT_WOW
            charName = (type(info.name) == "string") and info.name or ""
            playerGuid = (type(info.guid) == "string") and info.guid or nil

            if isOnline then
                statusText = "OnlineInGame"
                if info.dnd then statusText = "DNDInGame"
                elseif info.afk then statusText = "AFKInGame" end
            end
        end
    end

    if type(noteText) ~= "string" then noteText = "" end

    -- [[ OPTIMIZATION: Use Unique Identifier for Cache instead of dynamic List Index ]]
    local uniqueID = id
    if buttonType == FRIENDS_BUTTON_TYPE_BNET and accountIdentifier then
        uniqueID = accountIdentifier
    elseif buttonType == FRIENDS_BUTTON_TYPE_WOW and charName ~= "" then
        uniqueID = charName
    end
    
    local cacheKey = buttonType .. "_" .. tostring(uniqueID)
    local cache = FriendGroups_AssignmentCache[cacheKey]
    
    local manualMain = (FriendGroups_SavedVars.manual_mains and accountIdentifier) and FriendGroups_SavedVars.manual_mains[accountIdentifier] or nil
    
    local isCacheValid = cache 
        and cache.noteText == noteText 
        and cache.statusText == statusText 
        and cache.favorite == favorite 
        and cache.charName == charName 
        and cache.isOnline == isOnline 
        and cache.altCacheCount == altCacheCount
        and cache.guildSetting == FriendGroups_SavedVars.show_guildmates
        and cache.offlineSetting == FriendGroups_SavedVars.offline_tracker
        and cache.favSetting == FriendGroups_SavedVars.add_favorite_group
        and cache.manualMain == manualMain

    if not isCacheValid then
        if buttonType == FRIENDS_BUTTON_TYPE_BNET and accountIdentifier then
            local friendAccountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(id)
            -- 12.1 title friends arrive through the Battle.net enumeration but are NOT
            -- Battle.net account friends: they have no BattleTag, so accountIdentifier falls
            -- back to a character name and the alt cache -- which exists to collect the
            -- characters behind ONE Battle.net account -- has nothing meaningful to key by.
            -- Caching them files unrelated players against each other. Compat.IsTitleFriend
            -- answers false on every pre-12.1 client, so this changes nothing there.
            if friendAccountInfo and Compat.IsTitleFriend(friendAccountInfo) then
                friendAccountInfo = nil
            end
            if friendAccountInfo and friendAccountInfo.gameAccountInfo then
                FriendGroups_SaveToAltCache(accountIdentifier, friendAccountInfo.gameAccountInfo)
                if C_BattleNet.GetFriendNumGameAccounts then
                    local numAccounts = C_BattleNet.GetFriendNumGameAccounts(id)
                    if numAccounts and numAccounts > 1 then
                        for i = 1, numAccounts do
                            local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(id, i)
                            if gameAccountInfo then
                                FriendGroups_SaveToAltCache(accountIdentifier, gameAccountInfo)
                            end
                        end
                    end
                end
            end
        end

        local resolvedGroups = {}
        local parsedGroups = FriendGroups_GetPlayerGroups(noteText)
        
        for _, g in ipairs(parsedGroups) do table.insert(resolvedGroups, g) end

        if FriendGroups_SavedVars.add_favorite_group and favorite then
            table.insert(resolvedGroups, L["GROUP_FAVORITES"])
        end

        local akaName, akaClass, akaRealm = nil, nil, nil

        if FriendGroups_SavedVars.show_guildmates then
            local hasManualGuild = false
            if noteText ~= "" then
                for manualGuildName in string.gmatch(noteText, "<([^>]+)>") do
                    manualGuildName = string.match(manualGuildName, "^%s*(.-)%s*$")
                    if manualGuildName and #manualGuildName >= 2 then
                        local formattedGuildGroup = string.format(L["FORMAT_GUILD_TAG"], L["GROUP_GUILDMATES"], manualGuildName)
                        local alreadyExists = false
                        for _, g in ipairs(resolvedGroups) do
                            if g == formattedGuildGroup then alreadyExists = true break end
                        end
                        if not alreadyExists then
                            table.insert(resolvedGroups, formattedGuildGroup)
                            hasManualGuild = true
                        end
                    end
                end
            end
            
            local matchedGuild = nil
            local mainGuild = nil
            if buttonType == FRIENDS_BUTTON_TYPE_BNET then
                -- [[ AKA SOURCE: MANUAL MAIN ONLY ]]
                -- The "aka" label is driven solely by a manually-selected main below.
                -- The previous auto-detection (newest cached character by timestamp) was
                -- removed so an "aka" only appears once the user explicitly picks a main.
                if FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains and accountIdentifier and FriendGroups_SavedVars.manual_mains[accountIdentifier] then
                    local manualMainKey = FriendGroups_SavedVars.manual_mains[accountIdentifier]
                    if FriendGroups_SavedVars.alt_cache and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
                        for _, alt in ipairs(FriendGroups_SavedVars.alt_cache[accountIdentifier]) do
                            local currentKey = alt.charName .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")
                            if currentKey == manualMainKey or alt.key == manualMainKey then
                                akaName = alt.charName
                                akaClass = alt.class
                                akaRealm = alt.realm
                                -- Manual main trumps all: its guild defines the guild group,
                                -- regardless of which character the friend is logged in on.
                                if alt.guild and alt.guild ~= "" and alt.guild ~= "NONE" and alt.guild ~= "-" then
                                    mainGuild = alt.guild
                                end
                                break
                            end
                        end
                    end

                    -- Fall back to the synced seed if this box hasn't cached the main yet,
                    -- and keep the seed fresh from any local observation above.
                    if not mainGuild and FriendGroups_SavedVars.main_guild then
                        local seed = FriendGroups_SavedVars.main_guild[accountIdentifier]
                        if seed and seed ~= "" and seed ~= "NONE" and seed ~= "-" then
                            mainGuild = seed
                        end
                    end
                    if mainGuild then
                        if not FriendGroups_SavedVars.main_guild then FriendGroups_SavedVars.main_guild = {} end
                        FriendGroups_SavedVars.main_guild[accountIdentifier] = mainGuild
                    end
                end

                if not mainGuild and not hasManualGuild then
                    if isOnline and client == BNET_CLIENT_WOW and isRetail and charName ~= "" then
                        local friendAccountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(id)
                        if friendAccountInfo and friendAccountInfo.gameAccountInfo then
                            local rName = (type(friendAccountInfo.gameAccountInfo.realmName) == "string") and friendAccountInfo.gameAccountInfo.realmName or ""
                            local fullName = charName
                            if rName ~= "" then fullName = charName .. "-" .. FriendGroups_CleanRealmName(rName) end

                            if FriendGroups_LiveGuildSessionDict[fullName] or FriendGroups_LiveGuildSessionDict[charName] then
                                matchedGuild = FriendGroups_PlayerGuildName
                            end
                        end
                    end
                    
                    if not matchedGuild and accountIdentifier and FriendGroups_SavedVars.alt_cache and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
                        for _, alt in ipairs(FriendGroups_SavedVars.alt_cache[accountIdentifier]) do
                            if alt.guild and alt.guild ~= "" and alt.guild ~= "NONE" and alt.guild ~= "-" then
                                if FriendGroups_SavedVars.known_player_guilds and FriendGroups_SavedVars.known_player_guilds[alt.guild] then
                                    matchedGuild = alt.guild
                                    break
                                end
                            end
                            if FriendGroups_LiveGuildSessionDict[alt.key] or FriendGroups_LiveGuildSessionDict[alt.charName] then
                                matchedGuild = FriendGroups_PlayerGuildName
                                break
                            end
                        end
                    end
                end
            elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
                if not hasManualGuild and charName ~= "" then
                    if FriendGroups_LiveGuildSessionDict[charName] then
                        matchedGuild = FriendGroups_PlayerGuildName
                    end
                end
            end
            
            -- A manually-selected main's guild takes precedence over the heuristic match.
            local effectiveGuild = mainGuild or matchedGuild
            if effectiveGuild then
                local formattedGuildGroup = string.format(L["FORMAT_GUILD_TAG"], L["GROUP_GUILDMATES"], effectiveGuild)
                local alreadyExists = false
                for _, g in ipairs(resolvedGroups) do
                    if g == formattedGuildGroup then alreadyExists = true break end
                end
                if not alreadyExists then
                    table.insert(resolvedGroups, formattedGuildGroup)
                end
            end
        end

        -- ================================================================
        -- [[ OFFLINE TRACKER ]]
        -- With the tracker on, an offline contact is filed into EXACTLY ONE offline bucket
        -- and is removed from every other group, so the custom and guild groups above become
        -- "who is actually around" and the absent are parked below them. Previously these
        -- buckets were additive, which was tolerable while only a 30-day absence qualified
        -- (a handful of rows) but is not once the catch-all claims everyone offline: on a
        -- 200-contact roster every absent friend would be drawn twice.
        --
        -- [Favorites] is the one exemption. It is a pin rather than a group -- the whole
        -- point of it is that those contacts stay at the top where you put them -- so an
        -- offline favourite keeps its pin AND gains its offline bucket.
        --
        -- Both friend tiers qualify, not just Battle.net accounts. On 12.1 that is academic
        -- (both arrive through the Battle.net enumeration), but on 12.0.7 and Classic a
        -- C_FriendList character friend is a separate _WOW row, and leaving those out would
        -- half-sort the list: Battle.net friends would move to the offline block while
        -- character friends stayed scattered through the custom groups. They can never
        -- resolve a dated tier -- there is no lastOnlineTime on that API -- so they land in
        -- the catch-all, which is exactly what it is for.
        -- ================================================================
        -- Everything the contact resolved to BEFORE exclusive filing discards it. The alt
        -- tooltip reports the guild FriendGroups worked out for this person and reads it back
        -- out of the assignment cache, so without this an offline contact would silently lose
        -- their guild line: the LIST is exclusive, but the description of the person is not.
        local fullGroups = nil

        if FriendGroups_SavedVars.offline_tracker and statusText == "Offline" then
            local offlineGroup = L["GROUP_OFFLINE_0"]

            if buttonType == FRIENDS_BUTTON_TYPE_BNET then
                local friendAccountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(id)
                -- Typed explicitly. 12.1 publishes 0 for the entire title-friend tier rather
                -- than omitting the field, and the census confirmed it, so "> 0" is the real
                -- test for "datable" and nil is only the older shape.
                if friendAccountInfo and type(friendAccountInfo.lastOnlineTime) == "number"
                    and friendAccountInfo.lastOnlineTime > 0 then
                    local daysOffline = (time() - friendAccountInfo.lastOnlineTime) / 86400
                    if daysOffline >= 90 then offlineGroup = L["GROUP_OFFLINE_3"]
                    elseif daysOffline >= 60 then offlineGroup = L["GROUP_OFFLINE_2"]
                    elseif daysOffline >= 30 then offlineGroup = L["GROUP_OFFLINE_1"] end
                end
            end

            -- Rebuilt in place rather than replaced: this table is handed to the assignment
            -- cache below, so its identity is kept.
            local keepFavorite = false
            fullGroups = {}
            for _, g in ipairs(resolvedGroups) do
                fullGroups[#fullGroups + 1] = g
                if g == L["GROUP_FAVORITES"] then keepFavorite = true end
            end

            wipe(resolvedGroups)
            if keepFavorite then table.insert(resolvedGroups, L["GROUP_FAVORITES"]) end
            table.insert(resolvedGroups, offlineGroup)
        end

        -- Unreachable for an offline contact while the tracker is on -- the block above
        -- always leaves at least one group behind -- so [No Group] becomes an online-only
        -- bucket in that mode. That is the intended consequence of exclusive filing, not an
        -- oversight: an ungrouped absent friend is now described by their absence.
        if #resolvedGroups == 0 then table.insert(resolvedGroups, L["GROUP_NONE"]) end
        
        FriendGroups_AssignmentCache[cacheKey] = {
            noteText = noteText,
            statusText = statusText,
            favorite = favorite,
            charName = charName,
            isOnline = isOnline,
            altCacheCount = altCacheCount,
            guildSetting = FriendGroups_SavedVars.show_guildmates,
            offlineSetting = FriendGroups_SavedVars.offline_tracker,
            favSetting = FriendGroups_SavedVars.add_favorite_group,
            manualMain = manualMain,
            groups = resolvedGroups,
            -- Identical to `groups` unless exclusive offline filing dropped something; the
            -- alt tooltip reads this one so it can still describe a contact the list has
            -- moved into an offline bucket.
            allGroups = fullGroups or resolvedGroups,
            akaName = akaName,
            akaClass = akaClass,
            akaRealm = akaRealm
        }
        
        cache = FriendGroups_AssignmentCache[cacheKey]
    end

	-- [[ CACHE PRUNE SUPPORT ]]
    -- Mark this entry as live for the current rebuild generation. Entries for friends who are
    -- no longer present keep an older generation and are pruned at the end of FriendsListUpdate.
    cache.generation = FriendGroups_CacheGeneration
	
    if accountIdentifier then
        FriendGroups_ActiveAKA[accountIdentifier] = nil
        if cache.akaName then
            FriendGroups_ActiveAKA[accountIdentifier] = { name = cache.akaName, class = cache.akaClass, realm = cache.akaRealm }
        end
    end

    -- The filters depend only on the friend, not on the group, so resolve visibility once
    -- here and reuse it for every group below.
    local onlineVisible = false
    if isOnline then
        onlineVisible = FriendGroups_PassesOnlineFilters(statusText, client, isSameProject)
    end

    -- [[ UNIQUE ONLINE COUNTER ]] Resolved once per friend rather than once per group, so
    -- multi-group membership cannot inflate the total. Search is deliberately excluded:
    -- the counter reports the roster, not the current query.
    local onlineKey = nil
    if onlineVisible then
        onlineKey = FriendGroups_ResolveOnlineKey(buttonType, accountIdentifier, id, playerGuid)
        if onlineKey and not FriendGroups_OnlineKeys[onlineKey] then
            FriendGroups_OnlineKeys[onlineKey] = true
            FriendGroups_OnlineTotal = FriendGroups_OnlineTotal + 1
        end
    end

    for _, groupName in ipairs(cache.groups) do
        local addToTable = false

        if not groupsTotal[groupName] then
            groupsTotal[groupName] = FG_GetTable()
            groupsCount[groupName] = FG_GetTable()
            groupsCount[groupName].Total = 0
            groupsCount[groupName].Online = 0
            groupsCount[groupName].Raw = 0
            table.insert(groupsSorted, groupName)
        end

        -- Raw = every member of this group, ignoring all filters. It is the "/ total"
        -- denominator in the header; .Total/.Online only count filtered (visible) members.
        groupsCount[groupName].Raw = (groupsCount[groupName].Raw or 0) + 1

        -- A set, not a tally: a friend reachable through both friend lists resolves to one
        -- key, so they cannot be counted twice within the same group.
        if onlineKey then
            local groupSet = FriendGroups_OnlineByGroup[groupName]
            if not groupSet then
                groupSet = FG_GetTable()
                FriendGroups_OnlineByGroup[groupName] = groupSet
            end
            groupSet[onlineKey] = true
        end

        if isOnline then
            addToTable = onlineVisible
        else
            if not FriendGroups_SavedVars.hide_offline and ((FriendGroups_SavedVars.ingame_only and client == BNET_CLIENT_WOW) or not FriendGroups_SavedVars.ingame_only) then
                addToTable = true
            end
        end

        if searchValue ~= "" then
            addToTable = FriendGroups_Search(id, buttonType, passedAccountInfo)
        end

        if addToTable then
            groupsCount[groupName].Total = groupsCount[groupName].Total + 1
            if statusText ~= "Offline" then
                groupsCount[groupName].Online = groupsCount[groupName].Online + 1
            end
            
			local playerData = FG_GetTable()
            playerData.id = id
            playerData.buttonType = buttonType
            playerData.statusText = statusText

            -- [[ PRESENCE FLAGS (drive the primary sort tier) ]]
            -- isInGame: online AND active client is WoW (actively playing) -> top tier.
            -- isOnline: online in any client (WoW, app, mobile, other game) -> middle tier.
            -- Offline (neither flag) -> bottom tier.
            playerData.isOnline = isOnline
            playerData.isInGame = isOnline and (client == BNET_CLIENT_WOW)
            -- The account/character tier, resolved here because buttonType no longer carries
            -- it on 12.1. Consumed by tier 3 of FriendGroups_SortTableByStatus.
            playerData.isTitleFriend = isTitleFriend

            -- [[ ALPHABETICAL SORT KEY ]]
            -- BNet -> account identifier (BattleTag; its name prefix is the displayed bold name).
            -- WoW  -> character name. Lowercased for case-insensitive ordering. Consumed by the
            -- secondary sort in FriendGroups_SortTableByStatus.
            --
            -- titleSortName takes precedence and is set ONLY for 12.1 WoW-friend rows, whose
            -- accountIdentifier is a |K escape. Sorting on that escape ordered them by an
            -- opaque client id and, because "|" outranks every letter, parked the whole tier
            -- below everyone else -- an order with no relationship to what is on screen.
            --
            -- A WoW-friend never seen online has no readable name anywhere, so it still falls
            -- through to the escape. That is the honest floor, not an oversight: those rows
            -- keep today's behaviour until the friend logs in once.
            local sortName = charName
            if buttonType == FRIENDS_BUTTON_TYPE_BNET and accountIdentifier then
                sortName = titleSortName or accountIdentifier
            end

            -- [[ NICKNAME ELEVATION ]]
            -- Custom-nicknamed friends form the top subgroup within their presence tier
            -- (FriendGroups_SortTableByStatus tier 2) and sort by the nickname itself,
            -- so the nickname becomes the alphabetical key.
            local nick = accountIdentifier and FriendGroups_SavedVars.nicknames
                and FriendGroups_SavedVars.nicknames[accountIdentifier]
            if type(nick) == "string" and nick ~= "" then
                playerData.hasNickname = true
                sortName = nick
            else
                playerData.hasNickname = false
            end
            playerData.sortName = (sortName or ""):lower()

            table.insert(groupsTotal[groupName], playerData)
		end
    end
end

-- Set by /fg match only. When true the matcher reports the values it actually compared,
-- which is the one thing reading the source cannot tell you.
local FriendGroups_SearchDebug = false

-- ============================================================================
-- [[ NAME MATCHING FOR 12.1 WoW-FRIEND ROWS ]]
-- accountName for a 12.1 title friend is NOT text. It is a |K name escape -- six or seven
-- bytes like "|Kq2|k" that the CLIENT resolves when it draws them. SetText renders the real
-- name, tostring hands the escape to the chat frame which also renders it, and every string
-- comparison in Lua correctly fails against the six bytes actually present. Measured: a row
-- displaying "Backhawksleg-Nobundo" has #accountName == 6.
--
-- So the name cannot be matched in Lua at all, by us or by anyone. What CAN match it is
-- Blizzard's own C_BattleNet.SearchFriends, which resolves the escapes internally -- the same
-- call the Filter checkboxes already use, returning a plain array of friend indices in the
-- same index space as the friend index we iterate.
--
-- The result is UNIONED with our own matcher, never intersected: theirs sees names we cannot
-- read, ours sees notes, groups, nicknames, realms, classes and the alt cache that the server
-- knows nothing about. Either one is sufficient for a row to show.
--
-- Built ONCE per roster rebuild, never per friend and never per keystroke -- the standing
-- rule for this API. Rebuilds are already debounced behind the search box's 0.3s timer.
local FriendGroups_NameMatchSet = nil

-- Reported by /fg match so a failure says WHICH shape was tried.
local FriendGroups_NameMatchSource = "none"

local function FriendGroups_RebuildNameMatchSet()
    FriendGroups_NameMatchSet = nil
    FriendGroups_NameMatchSource = "none"
    if searchValue == "" then return end

    -- [[ SEARCH-INFO SHAPE, AND WHY THERE IS NO LONGER A FALLBACK ]]
    -- A bare { searchText = ... } returns nothing on 12.1 (measured), so the table is built
    -- the way Blizzard builds it. Their OnSearchEnterPressed reads:
    --
    --     local activeSearchInfo = self:BuildActiveSearchInfo()
    --     activeSearchInfo.searchText = text or ""
    --     local friendsData = C_BattleNet.SearchFriends(activeSearchInfo)
    --
    -- so the view's own builder is the ONLY accepted source. It carries every field this
    -- patch expects, including any added later, and it reflects the Status/Tags boxes exactly
    -- as Blizzard's search does.
    --
    -- A hand-composed table used to stand in when there was no view, on the theory that the
    -- shape was all that mattered. It was wrong twice over. It never returned a match when it
    -- was measured, and "no view" turned out to mean something quite different from what it
    -- was written for: on a live 12.1 client with the Social UI switched off there IS no view
    -- and the call is FORBIDDEN, so that branch existed only to produce an error report on
    -- every keystroke. Blizzard's own search on that client is the legacy list's, which never
    -- called this API at all.
    --
    -- Requiring the view therefore does double duty -- it is the only shape that works, and
    -- it is exactly the condition under which the call is allowed. Compat.SearchFriends still
    -- latches the forbidden case underneath, because "allowed" is the client's call and not
    -- ours to assume.
    local view = Compat.GetSocialUIFriendsView and Compat.GetSocialUIFriendsView()
    if not view or type(view.BuildActiveSearchInfo) ~= "function" then
        -- Not an error. The matcher's own comparisons still run; what is lost is Blizzard's
        -- verdict on names we cannot read, which on this client is only the |K accountName --
        -- and FriendGroups_SavedVars.wow_friend_names covers that from the other side.
        FriendGroups_NameMatchSource = "noview"
        return
    end

    local built, searchInfo = pcall(view.BuildActiveSearchInfo, view)
    if not built or type(searchInfo) ~= "table" then
        FriendGroups_NameMatchSource = "view:buildfailed"
        return
    end

    searchInfo.searchText = searchValue

    local result, reason = Compat.SearchFriends(searchInfo)
    if not result then
        FriendGroups_NameMatchSource = "view:" .. tostring(reason)
        return
    end
    FriendGroups_NameMatchSource = "view"

    local set = nil
    for _, friendIndex in ipairs(result) do
        set = set or {}
        set[friendIndex] = true
    end
    FriendGroups_NameMatchSet = set
end

function FriendGroups_Search(playerId, playerButtonType, passedAccountInfo)
    if searchValue == "" then
        if FriendGroups_SearchDebug then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  #%s EARLY-TRUE (searchValue empty)", tostring(playerId)))
        end
        return true
    end

    local characterName, bnetAccountName, battleTag, noteText, realmName, className, richPresence, regionSearchText, factionSearchText = "", "", "", "", "", "", "", "", ""
    local classMatch = false
    local altMatch = false
    local matchedGuildName = ""
    local hasManualGuild = false
    local searchLower = searchLowerValue
    local searchLen = #searchLower

    -- Blizzard's verdict on the NAME, which is the only thing that can read a |K escape.
    -- Tested first and short-circuits: when the server has already matched this friend there
    -- is nothing our own comparisons could add.
    if FriendGroups_NameMatchSet and playerButtonType == FRIENDS_BUTTON_TYPE_BNET
        and FriendGroups_NameMatchSet[playerId] then
        if FriendGroups_SearchDebug then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("  #%s NAME-MATCH (native)", tostring(playerId)))
        end
        return true
    end

    if playerButtonType == FRIENDS_BUTTON_TYPE_BNET then
        -- Fast Path: Use passed memory reference instead of querying the API
        local accountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(playerId)
        if accountInfo then
            -- [[ ACCOUNT-LEVEL FIELDS ]]
            -- These three live on accountInfo, NOT on gameAccountInfo, and they used to be
            -- read INSIDE the session guard below. A friend with no game session -- every
            -- offline 12.1 title friend -- therefore had its name, BattleTag and note left
            -- as "" and could not be matched by any search string, while the row on screen
            -- was displaying that exact name. For the title tier accountName IS the
            -- character name (see the title-friend branch in Platform_SocialUI), so this is
            -- the field that makes "Backhawksleg-Nobundo" searchable.
            --
            -- RULE: if it is on screen it has to be matchable. Anything read here must come
            -- from the same place the renderer reads it, and must not be gated on state the
            -- renderer does not require.
            bnetAccountName = (type(accountInfo.accountName) == "string") and accountInfo.accountName or ""
            battleTag = (type(accountInfo.battleTag) == "string") and accountInfo.battleTag or ""
            noteText = (type(accountInfo.note) == "string") and accountInfo.note or ""

            -- [[ SESSION-ONLY FIELDS ]]
            -- Absent whenever the friend is offline, and largely absent even when online
            -- since the 12.0.7 presence reduction, so the whole block is optional.
            local gameInfo = accountInfo.gameAccountInfo
            if gameInfo then
                characterName = (type(gameInfo.characterName) == "string") and gameInfo.characterName or ""
                realmName = (type(gameInfo.realmName) == "string") and gameInfo.realmName or ""
                className = (type(gameInfo.className) == "string") and gameInfo.className or ""
                richPresence = (type(gameInfo.richPresence) == "string") and gameInfo.richPresence or ""
                factionSearchText = (type(gameInfo.factionName) == "string") and gameInfo.factionName or ""

                local database = FriendGroups_GetRealmDatabase(gameInfo.regionID)

                if realmName ~= "" then
                    local cleanRealm = FriendGroups_CleanRealmName(realmName)
                    local data = database[cleanRealm]
                    if data and data.region then
                        regionSearchText = data.region
                    end
                end
            end
            
            -- [[ OFFLINE NAME RECOVERY ]]
            -- The live session is the only place a WoW-friend's name is plain text, so when it
            -- is gone fall back to what was recorded the last time they were online. This is
            -- what makes an OFFLINE 12.1 WoW friend findable by name at all -- accountName is
            -- a |K escape and matches nothing, which is the whole bug.
            if characterName == "" and type(FriendGroups_SavedVars.wow_friend_names) == "table" then
                local remembered = FriendGroups_SavedVars.wow_friend_names[accountInfo.bnetAccountID]
                if remembered then
                    characterName = remembered.name or ""
                    -- Only fills a gap; a live realm always wins over a remembered one.
                    if realmName == "" then realmName = remembered.realm or "" end
                end
            end

            local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
            if accountIdentifier and FriendGroups_SavedVars and type(FriendGroups_SavedVars.alt_cache) == "table" then
                local alts = FriendGroups_SavedVars.alt_cache[accountIdentifier]
                if alts then
                    for _, alt in ipairs(alts) do
                        local aName = (type(alt.searchName) == "string") and alt.searchName or (type(alt.charName) == "string" and alt.charName:lower() or "")
                        local aRealm = (type(alt.searchRealm) == "string") and alt.searchRealm or (type(alt.realm) == "string" and alt.realm:lower() or "")
                        local aClass = (type(alt.searchClass) == "string") and alt.searchClass or (type(alt.class) == "string" and alt.class:lower() or "")
                        local aZone = (type(alt.searchZone) == "string") and alt.searchZone or (type(alt.zone) == "string" and alt.zone:lower() or "")
                        
                        if (aName:find(searchLower, 1, true)) or 
                           (aRealm:find(searchLower, 1, true)) or 
                           (aZone:find(searchLower, 1, true)) or 
                           (aClass ~= "" and aClass:sub(1, searchLen) == searchLower) then
                            altMatch = true
                            break
                        end
                    end
                end
            end
            
            if FriendGroups_SavedVars.show_guildmates then
                if noteText ~= "" then
                    for manualGuildName in string.gmatch(noteText, "<([^>]+)>") do
                        manualGuildName = string.match(manualGuildName, "^%s*(.-)%s*$")
                        if manualGuildName and #manualGuildName >= 2 then
                            if manualGuildName:lower():find(searchLower, 1, true) then
                                matchedGuildName = manualGuildName
                            end
                            hasManualGuild = true
                        end
                    end
                end
                
                if not hasManualGuild then
                    -- gameInfo is now optional (this block used to sit inside a guard that
                    -- proved it), so the nil check is load-bearing: an offline friend would
                    -- otherwise index a nil table here on every search keystroke.
                    if gameInfo and gameInfo.isOnline and gameInfo.clientProgram == BNET_CLIENT_WOW and Compat.IsSameProject(gameInfo) then
                        local cName = characterName
                        local rName = realmName
                        if cName ~= "" then
                            local fullName = cName
                            if rName ~= "" then fullName = cName .. "-" .. FriendGroups_CleanRealmName(rName) end
                            
                            if FriendGroups_LiveGuildSessionDict[fullName] or FriendGroups_LiveGuildSessionDict[cName] then
                                matchedGuildName = FriendGroups_PlayerGuildName
                            end
                        end
                    end
                end
            end
        end
    elseif playerButtonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = passedAccountInfo or C_FriendList.GetFriendInfoByIndex(playerId)
        if info then
            characterName = (type(info.name) == "string") and info.name or ""
            noteText = (type(info.notes) == "string") and info.notes or ""
            className = (type(info.className) == "string") and info.className or ""
            factionSearchText = (type(playerFactionGroup) == "string") and playerFactionGroup or ""
            regionSearchText = "Local"
            
            if FriendGroups_SavedVars.show_guildmates then
                if noteText ~= "" then
                    for manualGuildName in string.gmatch(noteText, "<([^>]+)>") do
                        manualGuildName = string.match(manualGuildName, "^%s*(.-)%s*$")
                        if manualGuildName and #manualGuildName >= 2 then
                            if manualGuildName:lower():find(searchLower, 1, true) then
                                matchedGuildName = manualGuildName
                            end
                            hasManualGuild = true
                        end
                    end
                end
                
                if not hasManualGuild and characterName ~= "" then
                    if FriendGroups_LiveGuildSessionDict[characterName] then
                        matchedGuildName = FriendGroups_PlayerGuildName
                    end
                end
            end
        end
    end

    if FriendGroups_SearchDebug then
        -- Every value the comparison below actually sees. If the branch above never ran,
        -- these are all empty and the button-type line says why.
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "  #%s btype=%s(bnet=%s wow=%s) term=%q acct=%q char=%q realm=%q note=%q",
            tostring(playerId), tostring(playerButtonType),
            tostring(FRIENDS_BUTTON_TYPE_BNET), tostring(FRIENDS_BUTTON_TYPE_WOW),
            -- Pipes DOUBLED so the chat frame cannot resolve an escape while printing it.
            -- Without this the probe renders the name the client draws instead of the bytes
            -- the matcher compares -- which is precisely how this bug hid for three rounds.
            -- gsub returns TWO values, so each call is parenthesised: unparenthesised it
            -- would spill its match count into the next placeholder.
            tostring(searchLower), (tostring(bnetAccountName):gsub("|", "||")),
            (tostring(characterName):gsub("|", "||")),
            tostring(realmName), tostring(noteText)))

        -- The line above proves what the values LOOK like. This one proves what they DO.
        -- They can disagree: a 12.x secret value renders through tostring and SetText but
        -- reads as absent to string operations, which would make a name that is plainly on
        -- screen fail every comparison below while printing perfectly here.
        local okFind, findRes = pcall(function()
            return bnetAccountName:lower():find(searchLower, 1, true)
        end)
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "     find=%s%s | len=%d/%d | eq=%s | issecretvalue=%s secret=%s",
            okFind and "" or "THREW:", tostring(findRes),
            #bnetAccountName, #searchLower,
            tostring(bnetAccountName:lower() == searchLower),
            tostring(type(issecretvalue)),
            tostring(type(issecretvalue) == "function" and issecretvalue(bnetAccountName) or "n/a")))
    end

    if className ~= "" and className:lower():sub(1, searchLen) == searchLower then classMatch = true end

    -- "Name-Realm" as one term, which is how these rows are LABELLED and therefore how people
    -- type them. Matching the two halves separately can never satisfy a search that spans the
    -- hyphen, so the joined form is tested as well.
    local fullName = ""
    if characterName ~= "" and realmName ~= "" then
        fullName = characterName .. "-" .. realmName
    end

    if (bnetAccountName:lower():find(searchLower, 1, true)) or
       (fullName ~= "" and fullName:lower():find(searchLower, 1, true)) or
       (battleTag:lower():find(searchLower, 1, true)) or
       (characterName:lower():find(searchLower, 1, true)) or
       (noteText:lower():find(searchLower, 1, true)) or
       (realmName:lower():find(searchLower, 1, true)) or
       (richPresence:lower():find(searchLower, 1, true)) or 
       (regionSearchText:lower():find(searchLower, 1, true)) or 
       (factionSearchText:lower():find(searchLower, 1, true)) or 
       (matchedGuildName ~= "" and matchedGuildName:lower():find(searchLower, 1, true)) or
       classMatch or altMatch then
        return true
    end
    return false
end

function FriendGroups_AddDropDownNew(ownerRegion, rootDescription, contextData)
    if not contextData then return end
    -- Scope the injection to the contact list: these MENU_UNIT_*_FRIEND tags also fire from
    -- chat lines, unit frames and the glue screen, and FriendGroups' entries belong on the
    -- friends list only. Routed through Compat because on 12.1 the list the player is
    -- actually pointing at is SocialUIFrame.FriendsList -- FriendsListFrame is still present
    -- but permanently hidden, so testing it directly is false forever and the whole menu
    -- section silently disappears.
    if not Compat.IsContactListMouseOver() then
        return
    end

    local bnetfriend = false
    local accountInfo = nil
    local bnetIDAccount = contextData.bnetIDAccount
    local wowName = contextData.name

    if bnetIDAccount then
        bnetfriend = true
        accountInfo = C_BattleNet.GetAccountInfoByID(bnetIDAccount)
    elseif wowName then
        bnetfriend = false
        accountInfo = C_FriendList.GetFriendInfo(wowName)
    else
        return
    end

    if not accountInfo then return end

    local note = ""
    if bnetfriend then
        note = accountInfo.note
    else
        note = accountInfo.notes
    end

    local groups = FriendGroups_GetPlayerGroups(note)

    rootDescription:CreateDivider()
    rootDescription:CreateTitle(L["DROP_TITLE"])

    rootDescription:CreateButton(L["DROP_COPY_NAME"], function(data)
        local textToCopy = ""
        if data.bnetfriend then
            local info = C_BattleNet.GetAccountInfoByID(data.id)
            if info and info.gameAccountInfo and info.gameAccountInfo.characterName then
                local char = info.gameAccountInfo.characterName
                local realm = info.gameAccountInfo.realmName
                local richPresence = info.gameAccountInfo.richPresence
                local friendProject = info.gameAccountInfo.wowProjectID
                local myProject = WOW_PROJECT_ID

                if not realm or realm == "" then
                    realm = info.gameAccountInfo.realmDisplayName
                end
                
                if (not realm or realm == "") and richPresence and type(richPresence) == "string" then
                    local extraction = richPresence:match("%s%-%s(.+)")
                    if extraction then
                        realm = extraction
                    end
                end
                if (not realm or realm == "") and info.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
                    if friendProject == myProject then
                        realm = GetNormalizedRealmName()
                    end
                end

                if realm and realm ~= "" and type(realm) == "string" then
                    realm = realm:gsub("[%s%p]+", "") 
                    textToCopy = char .. "-" .. realm
                else
                    textToCopy = char
                end
            elseif info and info.battleTag and type(info.battleTag) == "string" then
                textToCopy = info.battleTag
            end
		else
            textToCopy = data.name
            if textToCopy and textToCopy ~= "" and type(textToCopy) == "string" and not string.find(textToCopy, "-") then
                local myRealm = GetNormalizedRealmName()
                if type(myRealm) == "string" and myRealm ~= "" then
                    textToCopy = textToCopy .. "-" .. myRealm:gsub("[%s%p]+", "")
                end
            end
        end
		
        if textToCopy and textToCopy ~= "" then
            local dialog = StaticPopup_Show("FRIENDGROUPS_COPY_POPUP")
            if dialog and dialog.EditBox then
                dialog.EditBox:SetText(textToCopy)
                dialog.EditBox:HighlightText()
                dialog.EditBox:SetFocus()
            end
        end
    end, { id = bnetIDAccount, name = wowName, bnetfriend = bnetfriend })

    if bnetfriend then
        rootDescription:CreateButton(L["DROP_COPY_BTAG"], function(data)
            local info = C_BattleNet.GetAccountInfoByID(data.id)
            if info and info.battleTag and type(info.battleTag) == "string" then
                local dialog = StaticPopup_Show("FRIENDGROUPS_COPY_POPUP")
                if dialog and dialog.EditBox then
                    dialog.EditBox:SetText(info.battleTag)
                    dialog.EditBox:HighlightText()
                    dialog.EditBox:SetFocus()
                end
            end
        end, { id = bnetIDAccount })
    end

    local accountIdentifier = accountInfo and (FriendGroups_AccountIdentifier(accountInfo))

    if accountIdentifier then
        -- Battle.net friends only: the nickname is stored in the Battle.net note, which
        -- WoW character friends do not have. Their note is a different field capped at
        -- 48 characters and truncated silently by the API, so it is not a viable store.
        if bnetfriend and bnetIDAccount then
            rootDescription:CreateButton(L["DROP_SET_NICKNAME"], function(data)
                StaticPopup_Show("FRIENDGROUPS_SET_NICKNAME", nil, nil, { id = data.id })
            end, { id = bnetIDAccount })
        end

        if FriendGroups_SavedVars and FriendGroups_SavedVars.show_known_alts ~= false then
            local mainSubMenu = rootDescription:CreateButton(L["DROP_SELECT_MAIN"])
            mainSubMenu:CreateButton(L["DROP_CLEAR_MAIN"], function(data)
                if FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains then
                    FriendGroups_SavedVars.manual_mains[data.accountIdentifier] = nil
                    if FriendGroups_SavedVars.main_guild then
                        FriendGroups_SavedVars.main_guild[data.accountIdentifier] = nil
                    end
                    FriendGroups_FriendsListUpdate(true)
                end
            end, { accountIdentifier = accountIdentifier })

            if FriendGroups_SavedVars.alt_cache and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
                local menuAlts = {}
                for _, altData in ipairs(FriendGroups_SavedVars.alt_cache[accountIdentifier]) do
                    table.insert(menuAlts, altData)
                end
                table.sort(menuAlts, function(a, b) return (a.charName or "") < (b.charName or "") end)

                for _, altData in ipairs(menuAlts) do
                    local engClass = ""
                    if altData.class and (LOCALIZED_CLASS_NAMES_MALE[altData.class] or RAID_CLASS_COLORS[altData.class]) then
                        engClass = altData.class
                    else
                        for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if altData.class == v then engClass = k break end end
                        if engClass == "" then for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if altData.class == v then engClass = k break end end end
                    end
                    local colorCode = FriendGroups_GetClassColorCode(engClass ~= "" and engClass or altData.class)
                    local displayLabel = colorCode .. altData.charName .. "-" .. altData.realm .. "|r"
                    local altUniqueKey = altData.charName .. "-" .. FriendGroups_CleanRealmName(altData.realm or "")

                    mainSubMenu:CreateButton(displayLabel, function(data)
                        if not FriendGroups_SavedVars.manual_mains then FriendGroups_SavedVars.manual_mains = {} end
                        FriendGroups_SavedVars.manual_mains[data.accountIdentifier] = data.altKey
                        FriendGroups_FriendsListUpdate(true)
                    end, { accountIdentifier = accountIdentifier, altKey = altUniqueKey })
                end
            end
        end
    end

    rootDescription:CreateButton(L["DROP_CREATE"], function(data)
        if data.bnetfriend then
            local info = C_BattleNet.GetAccountInfoByID(data.id)
            if info then
                StaticPopup_Show("FRIENDGROUPS_CREATE", nil, nil, { id = info.bnetAccountID, note = info.note, set = function(id, note)
                    if C_BattleNet and C_BattleNet.SetFriendNote then
                        C_BattleNet.SetFriendNote(id, note)
                    else
                        BNSetFriendNote(id, note)
                    end
                end })
            end
        else
            local info = C_FriendList.GetFriendInfo(data.name)
            if info then
                StaticPopup_Show("FRIENDGROUPS_CREATE", nil, nil, { name = data.name, note = info.notes, set = C_FriendList.SetFriendNotes })
            end
        end
    end, { id = bnetIDAccount, name = wowName, bnetfriend = bnetfriend })

    local add = rootDescription:CreateButton(L["DROP_ADD"])

	for _, group in ipairs(groupsSorted) do
        local isGuildGroup = string.find(group, L["GROUP_GUILDMATES"], 1, true)
        if not FriendGroups_HasValue(groups, group) and group ~= "" and group ~= L["GROUP_FAVORITES"] and group ~= L["GROUP_EMPTY"] and group ~= L["GROUP_NONE"]
           and not FriendGroups_IsOfflineGroup(group) and not isGuildGroup then
		   add:CreateButton(group, function(data)
                local newNote = FriendGroups_AddGroup(data.note, data.group)
                if data.bnetfriend then
                    if C_BattleNet and C_BattleNet.SetFriendNote then
                        C_BattleNet.SetFriendNote(data.id, newNote)
                    else
                        BNSetFriendNote(data.id, newNote)
                    end
                else
                    C_FriendList.SetFriendNotes(data.name, newNote)
                end
            end, { group = group, note = note, id = bnetIDAccount, name = wowName, bnetfriend = bnetfriend })
        end
    end

    -- The friend's MANUAL guild tags (<GuildName> in the note) — these can be removed.
    -- Auto-detected (roster) guild membership has no note tag and is not removable.
    local manualGuilds = {}
    if type(note) == "string" then
        for gname in string.gmatch(note, "<([^>]+)>") do
            gname = strtrim(gname)
            if gname ~= "" and not FriendGroups_HasValue(manualGuilds, gname) then
                manualGuilds[#manualGuilds + 1] = gname
            end
        end
    end

    -- [[ ADD TO GUILD GROUP ]] writes a manual <GuildName> tag (works for auto guild
    -- groups too). Lists guild groups the friend isn't already manually tagged in.
    local guildOptions = {}
    for _, group in ipairs(groupsSorted) do
        if string.find(group, L["GROUP_GUILDMATES"], 1, true) then
            local gname = string.match(group, "<(.-)>")
            if gname and gname ~= "" and not FriendGroups_HasValue(guildOptions, gname)
               and not FriendGroups_HasValue(manualGuilds, gname) then
                guildOptions[#guildOptions + 1] = gname
            end
        end
    end
    if #guildOptions > 0 then
        local addGuild = rootDescription:CreateButton(L["DROP_ADD_GUILD"])
        for _, gname in ipairs(guildOptions) do
            addGuild:CreateButton(gname, function(data)
                local newNote = FriendGroups_AddGuildTag(data.note, data.guildName)
                if data.bnetfriend then
                    if C_BattleNet and C_BattleNet.SetFriendNote then
                        C_BattleNet.SetFriendNote(data.id, newNote)
                    else
                        BNSetFriendNote(data.id, newNote)
                    end
                else
                    C_FriendList.SetFriendNotes(data.name, newNote)
                end
            end, { guildName = gname, note = note, id = bnetIDAccount, name = wowName, bnetfriend = bnetfriend })
        end
    end

    -- [[ REMOVE FROM GUILD GROUP ]] strips a manual <GuildName> tag from the note.
    if #manualGuilds > 0 then
        local removeGuild = rootDescription:CreateButton(L["DROP_REMOVE_GUILD"])
        for _, gname in ipairs(manualGuilds) do
            removeGuild:CreateButton(gname, function(data)
                local newNote = FriendGroups_RemoveGuildTag(data.note, data.guildName)
                if data.bnetfriend then
                    if C_BattleNet and C_BattleNet.SetFriendNote then
                        C_BattleNet.SetFriendNote(data.id, newNote)
                    else
                        BNSetFriendNote(data.id, newNote)
                    end
                else
                    C_FriendList.SetFriendNotes(data.name, newNote)
                end
            end, { guildName = gname, note = note, id = bnetIDAccount, name = wowName, bnetfriend = bnetfriend })
        end
    end

    -- [[ REMOVE FROM GROUP ]] only shown when the friend is in a removable group, so it
    -- is hidden for ungrouped (No Group) friends rather than wasting a menu row.
    local removableGroups = {}
    for _, group in ipairs(groupsSorted) do
        local isGuildGroup = string.find(group, L["GROUP_GUILDMATES"], 1, true)
        if FriendGroups_HasValue(groups, group)
           and group ~= L["GROUP_FAVORITES"] and not FriendGroups_IsOfflineGroup(group) and not isGuildGroup then
            removableGroups[#removableGroups + 1] = group
        end
    end
    if #removableGroups > 0 then
        local remove = rootDescription:CreateButton(L["DROP_REMOVE"])
        for _, group in ipairs(removableGroups) do
            remove:CreateButton(group, function(data)
                local newNote = FriendGroups_RemoveGroup(data.note, data.group)
                if data.bnetfriend then
                    if C_BattleNet and C_BattleNet.SetFriendNote then
                        C_BattleNet.SetFriendNote(data.id, newNote)
                    else
                        BNSetFriendNote(data.id, newNote)
                    end
                else
                    C_FriendList.SetFriendNotes(data.name, newNote)
                end
            end, { group = group, note = note, id = bnetIDAccount, name = wowName, bnetfriend = bnetfriend })
        end
    end
end

function FriendGroups_FrameFriendDividerTemplateHeaderClick(self, button, down)
    local frame = self
    if not frame.name then
        frame = self:GetParent()
    end

    if not frame or not frame.name then return end

    local groupName = frame.rawGroupName or frame.name:GetText()

    if groupName == "Search..." then
        if _G["FriendGroupsSearch"] then
            _G["FriendGroupsSearch"]:SetFocus()
        end
    elseif button == "RightButton" then
        if groupName then
            Compat.OpenContextMenu(self, function(ownerRegion, rootDescription)
                local displayTitle = frame.name:GetText() or groupName
                rootDescription:CreateTitle(displayTitle)
                
                local isGuildGroup = string.find(groupName, L["GROUP_GUILDMATES"], 1, true)
                local isSystemGroup = (groupName == L["GROUP_NONE"] or groupName == L["GROUP_FAVORITES"] or groupName == L["GROUP_EMPTY"] or groupName == "" or FriendGroups_IsOfflineGroup(groupName))

                -- [[ ORDERING: movable groups can be reordered manually ]]
                if not FriendGroups_IsFixedAnchor(groupName) then
                    local moveIdx = FriendGroups_MovableIndex[groupName]
                    local moveCount = #FriendGroups_MovableOrder

                    local moveUpBtn = rootDescription:CreateButton(L["MENU_MOVE_UP"], function()
                        FriendGroups_MoveGroup(groupName, -1)
                    end)
                    if not moveIdx or moveIdx <= 1 then moveUpBtn:SetEnabled(false) end

                    local moveDownBtn = rootDescription:CreateButton(L["MENU_MOVE_DOWN"], function()
                        FriendGroups_MoveGroup(groupName, 1)
                    end)
                    if not moveIdx or moveIdx >= moveCount then moveDownBtn:SetEnabled(false) end

                    if FriendGroups_SavedVars.group_order and FriendGroups_SavedVars.group_order[groupName] ~= nil then
                        rootDescription:CreateButton(L["MENU_RESET_POSITION"], function()
                            FriendGroups_ResetGroupPosition(groupName)
                        end)
                    end

                    rootDescription:CreateDivider()
                end

                -- [[ PRIMARY ACTION: invite the group's members to a party ]]
                -- Hidden for the virtual fixed anchors (No Group, Empty, Offline).
                if not FriendGroups_IsFixedAnchor(groupName) then
                    local inviteText = L["MENU_INVITE"]
                    local inviteDisabled = false
                    if groupsCount[groupName] and groupsCount[groupName].Total and groupsCount[groupName].Total > 40 then
                        inviteDisabled = true
                        inviteText = inviteText .. L["MENU_MAX_40"]
                    end
                    local inviteBtn = rootDescription:CreateButton(inviteText, function()
                        FriendGroups_InviteOrGroup(groupName, true)
                    end)
                    if inviteDisabled then inviteBtn:SetEnabled(false) end
                end

                -- Banner colour for any real group (incl. Favorites & Guild), but not
                -- the virtual fixed anchors.
                if not FriendGroups_IsFixedAnchor(groupName) then
                    rootDescription:CreateDivider()
                    rootDescription:CreateButton(L["MENU_SET_BANNER_COLOR"], function()
                        local originalHex = FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName] or nil
                        
                        local function OnColorColorPicked()
                            local r, g, b = ColorPickerFrame:GetColorRGB()
                            if not FriendGroups_SavedVars.banner_colors then
                                FriendGroups_SavedVars.banner_colors = {}
                            end
                            local hexColor = string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
                            FriendGroups_SavedVars.banner_colors[groupName] = hexColor
                            
                            -- Instant live refresh for visible frames while dragging the color picker
                            Compat.ForEachContactListFrame(function(f)
                                    if f.rawGroupName == groupName and f.solidBannerTexture then
                                        f.solidBannerTexture:SetColorTexture(r, g, b, 0.4)
                                        f.solidBannerTexture:Show()
                                    end
                                end)
                        end
                        
                        local function OnColorColorPickerCancelled()
                            if originalHex then
                                FriendGroups_SavedVars.banner_colors[groupName] = originalHex
                                local r = tonumber(string.sub(originalHex, 1, 2), 16) / 255
                                local g = tonumber(string.sub(originalHex, 3, 4), 16) / 255
                                local b = tonumber(string.sub(originalHex, 5, 6), 16) / 255
                                Compat.ForEachContactListFrame(function(f)
                                        if f.rawGroupName == groupName and f.solidBannerTexture then
                                            f.solidBannerTexture:SetColorTexture(r, g, b, 0.4)
                                            f.solidBannerTexture:Show()
                                        end
                                    end)
                            else
                                if FriendGroups_SavedVars.banner_colors then
                                    FriendGroups_SavedVars.banner_colors[groupName] = nil
                                end
                                Compat.ForEachContactListFrame(function(f)
                                        if f.rawGroupName == groupName and f.solidBannerTexture then
                                            f.solidBannerTexture:Hide()
                                        end
                                    end)
                            end
                            FriendGroups_FriendsListUpdate(true)
                        end
                        
                        local initR, initG, initB = 1, 1, 1
                        if originalHex then
                            initR = tonumber(string.sub(originalHex, 1, 2), 16) / 255
                            initG = tonumber(string.sub(originalHex, 3, 4), 16) / 255
                            initB = tonumber(string.sub(originalHex, 5, 6), 16) / 255
                        end

                        ColorPickerFrame:SetupColorPickerAndShow({
                            swatchFunc = OnColorColorPicked,
                            cancelFunc = OnColorColorPickerCancelled,
                            opacityFunc = nil,
                            hasOpacity = false,
                            r = initR, g = initG, b = initB
                        })
                    end)
                    
                    -- [[ HEADER FONT COLOUR ]]
                    -- A banner colour darkens the strip the label sits on, and the default
                    -- grey label can disappear against it. FriendGroups_HeaderFontRGB resolves
                    -- the rule: an explicit override wins, otherwise a banner implies white,
                    -- otherwise the header keeps whatever colour it had. Setting a banner
                    -- therefore fixes legibility without the user doing anything, and this
                    -- entry only exists for when they want a different colour.
                    rootDescription:CreateButton(L["MENU_SET_FONT_COLOR"], function()
                        local originalHex = FriendGroups_SavedVars.font_colors
                            and FriendGroups_SavedVars.font_colors[groupName] or nil

                        local function ApplyFontColor(r, g, b)
                            if not FriendGroups_SavedVars.font_colors then
                                FriendGroups_SavedVars.font_colors = {}
                            end
                            FriendGroups_SavedVars.font_colors[groupName] =
                                string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
                            -- Live preview, same walker the banner picker uses.
                            Compat.ForEachContactListFrame(function(f)
                                if f.rawGroupName == groupName and f.name then
                                    f.name:SetTextColor(r, g, b)
                                end
                            end)
                        end

                        local initR, initG, initB = 1, 1, 1
                        if originalHex and #originalHex >= 6 then
                            initR = (tonumber(originalHex:sub(1, 2), 16) or 255) / 255
                            initG = (tonumber(originalHex:sub(3, 4), 16) or 255) / 255
                            initB = (tonumber(originalHex:sub(5, 6), 16) or 255) / 255
                        end

                        ColorPickerFrame:SetupColorPickerAndShow({
                            swatchFunc = function()
                                ApplyFontColor(ColorPickerFrame:GetColorRGB())
                            end,
                            cancelFunc = function()
                                if FriendGroups_SavedVars.font_colors then
                                    FriendGroups_SavedVars.font_colors[groupName] = originalHex
                                end
                                FriendGroups_FriendsListUpdate(true)
                            end,
                            opacityFunc = nil,
                            hasOpacity = false,
                            r = initR, g = initG, b = initB
                        })
                    end)

                    if FriendGroups_SavedVars.font_colors and FriendGroups_SavedVars.font_colors[groupName] then
                        rootDescription:CreateButton(L["MENU_CLEAR_FONT_COLOR"], function()
                            FriendGroups_SavedVars.font_colors[groupName] = nil
                            FriendGroups_FriendsListUpdate(true)
                        end)
                    end

                    if FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName] then
                        rootDescription:CreateButton(L["MENU_CLEAR_BANNER_COLOR"], function()
                            FriendGroups_SavedVars.banner_colors[groupName] = nil
                            
                            -- Instant live refresh for visible frames. The label is put back
                            -- here as well as in the renderer: FriendGroups_FriendsListUpdate
                            -- QUEUES rather than runs while in combat, and without this the
                            -- banner would vanish while its white label stayed behind until
                            -- the fight ended. Skipped when a font override is set, which
                            -- outlives the banner and still owns the colour.
                            local keepsOverride = FriendGroups_SavedVars.font_colors
                                and FriendGroups_SavedVars.font_colors[groupName]
                            Compat.ForEachContactListFrame(function(f)
                                    if f.rawGroupName == groupName then
                                        if f.solidBannerTexture then
                                            f.solidBannerTexture:Hide()
                                        end
                                        if f.name and f.fgDefaultNameColor and not keepsOverride then
                                            local d = f.fgDefaultNameColor
                                            f.name:SetTextColor(d[1], d[2], d[3], d[4])
                                        end
                                    end
                                end)

                            FriendGroups_FriendsListUpdate(true)
                        end)
                    end
                end

                -- [[ IDENTITY EDIT + DESTRUCTIVE ACTION ]]
                -- Rename sits with the appearance edits; Remove is isolated below a divider
                -- and coloured red (via the locale string) to match the settings reset.
                if not isSystemGroup and not isGuildGroup then
                    rootDescription:CreateButton(L["MENU_RENAME"], function()
                        StaticPopup_Show("FRIENDGROUPS_RENAME", nil, nil, groupName)
                    end)

                    rootDescription:CreateDivider()
                    rootDescription:CreateButton(L["MENU_REMOVE"], function()
                        FriendGroups_InviteOrGroup(groupName, false)
                    end)
                end
            end)
        end
    else
        FriendGroups_FrameFriendDividerTemplateCollapseClick(self, button, down)
    end
end

function FriendGroups_GetFriendNote(id, buttonType)
	local noteText = ""

	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)

		if accountInfo then
			noteText = accountInfo.note
		end
	elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
		noteText = C_FriendList.GetFriendInfoByIndex(id) and C_FriendList.GetFriendInfoByIndex(id).notes
	end

	return noteText
end

function FriendGroups_GetFriendFavorite(id, buttonType)
	local isFavorite = false

	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)

		if accountInfo then
			isFavorite = accountInfo.isFavorite
		end
	end

	return isFavorite
end

function FriendGroups_SetGroupsCount()
	for groupName, groupData in pairs(groupsTotal) do
		if not groupsCount[groupName] then
			groupsCount[groupName] = {}
		end

		groupsCount[groupName].Total = 0
		groupsCount[groupName].Online = 0

		for _, playerData in ipairs(groupData) do
			local statusText = FriendGroups_GetStatusString(playerData)

			groupsCount[groupName].Total = groupsCount[groupName].Total + 1
			if statusText ~= "Offline" then
				groupsCount[groupName].Online = groupsCount[groupName].Online + 1
			end
		end
	end
end

-- ============================================================================
-- [[ FRIEND GROUPS FRAME (STATE) ]]
-- ============================================================================
FriendGroupsFrame = CreateFrame("Frame", "FriendGroupsFrame")
FriendGroupsFrame.selectionLocked = false

-- Note: We no longer need the global UIDropDownMenu templates or initialization 
-- functions here because we are using the modern inline MenuUtil API below.


-- Popups
StaticPopupDialogs["FRIENDGROUPS_CREATE"] = {
	text = L["POPUP_ENTER_NAME"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self)
		local parent = self:GetEditBox():GetParent()
		FriendGroups_Create(parent, parent.data)
		parent:Hide()
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		FriendGroups_Create(parent, parent.data)
		parent:Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopupDialogs["FRIENDGROUPS_RENAME"] = {
	text = L["POPUP_ENTER_NAME"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self)
		local parent = self:GetEditBox():GetParent()
		FriendGroups_Rename(parent, parent.data)
		parent:Hide()
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		FriendGroups_Rename(parent, parent.data)
		parent:Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

-- Resolve the edit box of a StaticPopup across both accessor styles used by this
-- addon's dialogs (.EditBox on the newer template, :GetEditBox() on the older one).
local function FriendGroups_PopupEditBox(dialog)
	if not dialog then return nil end
	if dialog.EditBox then return dialog.EditBox end
	if dialog.GetEditBox then return dialog:GetEditBox() end
	return nil
end

-- Write a nickname to the friend's Battle.net note -- the only place a nickname is
-- stored. An empty input removes the tag. The cache is updated straight away rather
-- than waiting for the next reconcile so the row repaints immediately.
--
-- A nickname that will not fit the note is REFUSED, not stored locally: note-is-truth
-- has no exceptions, and a nickname the Battle.net app could never show is exactly
-- the divergence this design exists to eliminate.
function FriendGroups_ApplyNickname(data, input)
	if not data or type(data.id) ~= "number" then return end
	if not Compat.CanSetBNetNote() then
		print(L["MSG_NICKNAME_NO_API"])
		return
	end

	local accountInfo = C_BattleNet.GetAccountInfoByID(data.id)
	if not accountInfo then return end

	-- Read the note LIVE. A note captured when the menu was built may already be
	-- stale (another client, or the Battle.net app, may have rewritten it since).
	local note = (type(accountInfo.note) == "string") and accountInfo.note or ""
	local nick = Compat.SanitizeNickname(input)
	local newNote = FriendGroups_SetNicknameTag(note, nick)

	if #newNote > Compat.BNET_NOTE_MAXBYTES then
		local label = accountInfo.accountName or accountInfo.battleTag or UNKNOWN
		print(string.format(L["MSG_NICKNAME_NOTE_TOO_LONG"], label))
		return
	end

	-- Prefer the account id reported by the API over the one captured when the menu was
	-- built, matching how FRIENDGROUPS_CREATE resolves its note setter.
	local writeID = (type(accountInfo.bnetAccountID) == "number") and accountInfo.bnetAccountID or data.id
	if not Compat.SetBNetNote(writeID, newNote) then return end

	local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
	if type(accountIdentifier) == "string" and accountIdentifier ~= "" then
		if not FriendGroups_SavedVars.nicknames then
			FriendGroups_SavedVars.nicknames = {}
		end
		FriendGroups_SavedVars.nicknames[accountIdentifier] = (nick ~= "") and nick or nil
	end

	FriendGroups_FriendsListUpdate(true)
end

-- [[ NEW POPUP: COPY TEXT ]] --
StaticPopupDialogs["FRIENDGROUPS_SET_NICKNAME"] = {
	text = L["POPUP_ENTER_NICKNAME"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 20,
	OnShow = function(self, data)
		-- Prefill from the NOTE, not the cache, so what is edited is what is actually
		-- stored -- including a tag typed by hand from the Battle.net app.
		local editBox = FriendGroups_PopupEditBox(self)
		if not editBox then return end
		local current = ""
		if data and type(data.id) == "number" then
			local accountInfo = C_BattleNet.GetAccountInfoByID(data.id)
			if accountInfo and type(accountInfo.note) == "string" then
				current = FriendGroups_GetNicknameTag(accountInfo.note)
			end
		end
		editBox:SetText(current)
		editBox:HighlightText()
		editBox:SetFocus()
	end,
	OnAccept = function(self, data)
		local editBox = FriendGroups_PopupEditBox(self)
		if editBox then
			FriendGroups_ApplyNickname(data, editBox:GetText())
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		FriendGroups_ApplyNickname(parent and parent.data, self:GetText())
		if parent then parent:Hide() end
	end,
	EditBoxOnEscapePressed = function(self)
		local parent = self:GetParent()
		if parent then parent:Hide() end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["FRIENDGROUPS_COPY_POPUP"] = {
	text = L["POPUP_COPY"],
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	preferredIndex = 3,
	OnShow = function(self)
        -- FIX: Use .EditBox (Capital E)
		if self.EditBox then
			self.EditBox:SetFocus()
			self.EditBox:HighlightText()
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
}

StaticPopupDialogs["FRIENDGROUPS_IMPORT"] = {
	text = L["POPUP_IMPORT"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3,
	OnShow = function(self)
		local eb = self:GetEditBox()
		if eb then
			eb:SetMaxLetters(0)   -- accept a large pasted backup
			eb:SetText("")
			eb:SetFocus()
		end
	end,
	OnAccept = function(self)
		FriendGroups_HandleImport(self:GetEditBox():GetText())
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		local text = self:GetText()
		parent:Hide()
		FriendGroups_HandleImport(text)
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
}

-- Show the export string in the copy dialog so the user can copy it to other accounts.
function FriendGroups_ShowExport()
	if not FriendGroups_Sync then return end
	local str = FriendGroups_Sync.Export()
	if not str or str == "" then return end
	local dialog = StaticPopup_Show("FRIENDGROUPS_COPY_POPUP")
	if dialog and dialog.EditBox then
		dialog.EditBox:SetMaxLetters(0)   -- a full backup can be large; no length cap
		dialog.EditBox:SetText(str)
		dialog.EditBox:HighlightText()
		dialog.EditBox:SetFocus()
	end
end

-- Apply a pasted export string and report the localized outcome.
function FriendGroups_HandleImport(text)
	if not text or text == "" or not FriendGroups_Sync then return end
	local ok, reason, ts = FriendGroups_Sync.Import(text)
	if ok then
		if ts and ts > 0 then
			print(string.format(L["MSG_IMPORT_OK_DATED"], date("%Y-%m-%d %H:%M", ts)))
		else
			print(L["MSG_IMPORT_OK"])
		end
	elseif reason == "CHECKSUM" then
		print(L["MSG_IMPORT_FAIL_CHECKSUM"])
	elseif reason == "PROTOCOL" then
		print(L["MSG_IMPORT_FAIL_PROTOCOL"])
	elseif reason == "LIBMISSING" then
		print(L["MSG_IMPORT_FAIL_LIBMISSING"])
	else
		print(L["MSG_IMPORT_FAIL_FORMAT"])
	end
end

--[[
	Functions
]] --

-- Returns true when the given cached alt is this account's manually-selected main.
-- Mirrors the dual-key comparison used by the tooltip/menu (raw alt.key OR the
-- recomputed charName-cleanRealm form) so a pinned main is always protected from the
-- recent-10 cap trim.
function FriendGroups_IsManualMain(accountIdentifier, alt)
    if not accountIdentifier or type(alt) ~= "table" then return false end
    if not (FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains) then return false end
    local mainKey = FriendGroups_SavedVars.manual_mains[accountIdentifier]
    if not mainKey then return false end
    if alt.key == mainKey then return true end
    local computedKey = (alt.charName or "") .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")
    return computedKey == mainKey
end

-- ============================================================================
-- [[ NICKNAME MIGRATION (SCHEMA 2) ]]
-- Before 13.0.1 nicknames lived only in FriendGroups_SavedVars.nicknames and were
-- never written to a note. Under the note-is-truth model that table is a cache, and
-- the reconcile pass would read every friend's tagless note and dutifully clear the
-- lot. So reconcile stays DISABLED until each existing nickname has been pushed into
-- its friend's note.
--
-- The push is user-initiated, never automatic: it writes to real, server-side,
-- cross-game data, and nicknames that do not fit are dropped (the note-is-truth
-- invariant holds with no exceptions -- there is no such thing as a nickname that
-- exists only locally). Declining simply leaves the old data untouched and re-prompts
-- next session; nothing is lost by saying no.
--
-- Writes are spread over timers rather than issued in a burst: this is the one code
-- path that can touch hundreds of notes, and hammering the server is not acceptable.
-- ============================================================================

local FG_NICKNAME_SCHEMA = 2
local FG_MIGRATE_WRITE_INTERVAL = 0.2

FriendGroups_NicknameMigrationRunning = false

-- Map every currently-visible Battle.net friend's account identifier to the numeric
-- account id and current note.
--
-- Returns map, trustworthy. Migration is DESTRUCTIVE -- a nickname whose account is
-- absent from this map is dropped -- so the map must be complete or not used at all.
-- `trustworthy` is false whenever any enumerated friend could not be fully resolved:
-- dropping someone's nickname because a field read as unavailable would be data loss
-- caused by an API quirk rather than by the note-is-truth rule. The caller stands the
-- whole migration down in that case, which loses nothing and re-prompts next session.
local function FriendGroups_BuildBNetNoteMap()
    if not (C_BattleNet and C_BattleNet.GetFriendAccountInfo) then return nil, false end
    local total = Compat.GetBNetFriendNum()
    if total <= 0 then return nil, false end

    local map, trustworthy = {}, true
    for i = 1, total do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        local accountIdentifier = accountInfo and (FriendGroups_AccountIdentifier(accountInfo))
        if type(accountIdentifier) ~= "string" or accountIdentifier == ""
            or type(accountInfo.bnetAccountID) ~= "number" then
            -- Enumerated but unresolvable, or resolvable but unwritable.
            trustworthy = false
        else
            map[accountIdentifier] = {
                id = accountInfo.bnetAccountID,
                note = (type(accountInfo.note) == "string") and accountInfo.note or "",
            }
        end
    end
    return map, trustworthy
end

-- Decide what the migration would actually do, without doing any of it.
-- Returns the queue of writes, how many nicknames would be dropped, and how many are
-- ALREADY correct in their note. That last count is the whole reason this is a separate
-- function: because the note lives on the Battle.net account, a nickname migrated on one
-- client is already present on every other one, so "nothing to write" is the normal,
-- successful outcome rather than a failure -- and restoring a backup on an account that
-- has already migrated is the case where EVERY nickname lands there.
-- Shared by the pre-check and the run itself so the two can never disagree.
local function FriendGroups_PlanNicknameMigration(noteMap, apply)
    local queue, dropped, skipped = {}, 0, 0
    for accountIdentifier, nick in pairs(FriendGroups_SavedVars.nicknames or {}) do
        local clean = Compat.SanitizeNickname(nick)
        local entry = noteMap[accountIdentifier]
        if clean == "" or not entry then
            -- No longer a friend, or an unusable nickname: it cannot live in a note,
            -- so under note-is-truth it does not exist.
            dropped = dropped + 1
            if apply then FriendGroups_SavedVars.nicknames[accountIdentifier] = nil end
        else
            local newNote = FriendGroups_SetNicknameTag(entry.note, clean)
            if #newNote > Compat.BNET_NOTE_MAXBYTES then
                dropped = dropped + 1
                if apply then FriendGroups_SavedVars.nicknames[accountIdentifier] = nil end
            elseif newNote == entry.note then
                skipped = skipped + 1
            else
                queue[#queue + 1] = { id = entry.id, note = newNote }
            end
        end
    end
    return queue, dropped, skipped
end

-- Mark the migration complete and hand control to the reconcile pass.
local function FriendGroups_FinishNicknameMigration(written, dropped, skipped)
    FriendGroups_NicknameMigrationRunning = false
    FriendGroups_SavedVars.nickname_schema = FG_NICKNAME_SCHEMA
    FriendGroups_NicknameSyncReady = true

    -- "0 written" reads as a failure, but when the notes already carry every tag it is
    -- success -- so report that state as its own outcome rather than a bare zero.
    if written == 0 and dropped == 0 and skipped > 0 then
        print(string.format(L["MSG_NICKNAME_MIGRATE_UPTODATE"], skipped))
    else
        print(string.format(L["MSG_NICKNAME_MIGRATE_DONE"], written))
        if dropped > 0 then
            print(string.format(L["MSG_NICKNAME_MIGRATE_DROPPED"], dropped))
        end
    end
    FriendGroups_FriendsListUpdate(true)
end

function FriendGroups_RunNicknameMigration()
    if FriendGroups_NicknameMigrationRunning then return end
    if not Compat.CanSetBNetNote() then
        print(L["MSG_NICKNAME_NO_API"])
        return
    end

    local noteMap, trustworthy = FriendGroups_BuildBNetNoteMap()
    if not noteMap or not trustworthy then
        -- Roster not populated, or not fully resolvable. Abort without stamping the
        -- schema and without dropping anything, so the prompt comes back next session
        -- with the friend list actually loaded.
        print(L["MSG_NICKNAME_MIGRATE_ABORT"])
        return
    end

    -- Re-planned against the LIVE roster rather than reusing the pre-check's plan: the
    -- note may have changed between the prompt appearing and the user accepting it.
    local queue, dropped, skipped = FriendGroups_PlanNicknameMigration(noteMap, true)

    if #queue == 0 then
        FriendGroups_FinishNicknameMigration(0, dropped, skipped)
        return
    end

    FriendGroups_NicknameMigrationRunning = true

    local index, written = 0, 0
    local function step()
        index = index + 1
        local item = queue[index]
        if not item then
            FriendGroups_FinishNicknameMigration(written, dropped, skipped)
            return
        end
        if Compat.SetBNetNote(item.id, item.note) then
            written = written + 1
        end
        C_Timer.After(FG_MIGRATE_WRITE_INTERVAL, step)
    end
    step()
end

StaticPopupDialogs["FRIENDGROUPS_NICKNAME_MIGRATE"] = {
    text = L["POPUP_NICKNAME_MIGRATE"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        FriendGroups_RunNicknameMigration()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3,
}

-- Decide, once per session, whether reconcile may run. Called after SavedVars exist.
function FriendGroups_InitNicknameSchema()
    if not FriendGroups_SavedVars then return end
    if not FriendGroups_SavedVars.nicknames then
        FriendGroups_SavedVars.nicknames = {}
    end

    if FriendGroups_SavedVars.nickname_schema == FG_NICKNAME_SCHEMA then
        FriendGroups_NicknameSyncReady = true
        return
    end

    -- Legacy schema. With nothing to migrate there is no decision to put to the
    -- user: stamp it and go.
    if next(FriendGroups_SavedVars.nicknames) == nil then
        FriendGroups_SavedVars.nickname_schema = FG_NICKNAME_SCHEMA
        FriendGroups_NicknameSyncReady = true
        return
    end

    -- Deferred so the prompt does not land in the middle of the loading screen, and so
    -- the Battle.net friend list has had a chance to populate.
    C_Timer.After(10, function()
        if FriendGroups_NicknameSyncReady or FriendGroups_NicknameMigrationRunning then return end

        -- Pre-check: only ask when there is something to decide. Restoring a backup on an
        -- account that has already migrated leaves every tag already in place (the notes
        -- live on the Battle.net account, so they came along for free), and prompting to
        -- "move" nicknames that are already there -- then reporting zero -- reads as a
        -- failure. Nothing is destructive in that case, so adopt it silently.
        local noteMap, trustworthy = FriendGroups_BuildBNetNoteMap()
        if noteMap and trustworthy then
            local queue, dropped = FriendGroups_PlanNicknameMigration(noteMap, false)
            if #queue == 0 and dropped == 0 then
                FriendGroups_SavedVars.nickname_schema = FG_NICKNAME_SCHEMA
                FriendGroups_NicknameSyncReady = true
                return
            end
            -- Count only what actually needs moving, so the prompt does not overstate.
            StaticPopup_Show("FRIENDGROUPS_NICKNAME_MIGRATE", #queue + dropped)
            return
        end

        -- Roster unusable: fall back to the raw count and let the run itself re-check.
        local pending = 0
        for _ in pairs(FriendGroups_SavedVars.nicknames) do pending = pending + 1 end
        StaticPopup_Show("FRIENDGROUPS_NICKNAME_MIGRATE", pending)
    end)
end

-- [[ CORE ACTIVATOR ]] --
EnableFriendGroups = function()
    if FriendGroups_Loaded then return end
    FriendGroups_Loaded = true
    
		if not FriendGroups_SavedVars then
        FriendGroups_SavedVars = {
            collapsed = {},
            hide_offline = false,
            colour_classes = true,
            show_class_icons = true,
            show_note = true,
            show_status = true,
            show_faction_icons = true,
            show_faction_color = true,
            show_game_icon = true,
            show_realm = true,            
            hide_high_level = true,       
            add_favorite_group = true,    
            gray_faction = false,
            show_mobile_afk = false,
            add_mobile_text = true,       
            ingame_only = false,
            ingame_retail = false,
            show_btag = false,
            show_retail = false,
            show_search = true,           
            hide_empty_groups = false,
            hide_afk = false,
            open_one_group = false,
            auto_accept_invite = true,
            auto_accept_sync = true,
            show_flags = true,
            offline_tracker = true,
            -- Off on a fresh install: a privacy mode that hides data by default would read as
            -- the addon being broken to everyone who is not streaming.
            streamer_mode = false,
            -- [[ FRESH-INSTALL SIZE DEFAULTS ]]
            -- Medium height, Wide panel, Small text.
            --
            -- Wide and Small pull the same way: the widest panel and the smallest rows show
            -- the most contacts at once and make the size controls obviously present, so a
            -- new user discovers them and dials back to taste rather than never finding them.
            --
            -- HEIGHT is the one axis that does NOT sit at its extreme. Width and font scale
            -- what the list can hold; height scales the panel whether or not there is
            -- anything to put in it, so Large on a small friends list opens a mostly empty
            -- window -- which reads as a broken addon rather than as a setting to adjust.
            --
            -- This table is the FRESH-INSTALL branch only. Existing users never reach it,
            -- so changing these cannot resize a list somebody has already set up.
            extra_height = 190,
            wide_list = true,
            width_normal = false,
            font_size = 1,
        }
    end
	
    -- [[ DEFAULTS MIGRATION FOR EXISTING USERS ]] --
    -- Row font scale. A FRESH install is seeded with 1 (Small) in the table above and so
    -- never reaches this line; only an UPGRADE arrives here with nil, and it is pinned to
    -- 2 (Medium) because that reproduces exactly how their rows have always looked. The
    -- new Small default is for new installs -- it is not a reason to shrink the text of
    -- somebody who never asked for it.
    --
    -- Width needs no equivalent: wide_list/width_normal have been written explicitly since
    -- they were introduced, so an existing user already carries their own choice.
    if FriendGroups_SavedVars.font_size == nil then
        FriendGroups_SavedVars.font_size = 2
    end
    -- Last-known names for 12.1 WoW-friend rows, keyed by bnetAccountID. Created here rather
    -- than only in the fresh-install table so an EXISTING profile gets it on upgrade too --
    -- without it every write site would need its own nil guard, and one missed guard would
    -- silently disable offline name search again.
    if type(FriendGroups_SavedVars.wow_friend_names) ~= "table" then
        FriendGroups_SavedVars.wow_friend_names = {}
    end
    if FriendGroups_SavedVars.show_flags == nil then
        FriendGroups_SavedVars.show_flags = true
    end
    if FriendGroups_SavedVars.show_class_icons == nil then
        FriendGroups_SavedVars.show_class_icons = true
    end
    if FriendGroups_SavedVars.show_note == nil then
        FriendGroups_SavedVars.show_note = true
    end
    if FriendGroups_SavedVars.show_status == nil then
        FriendGroups_SavedVars.show_status = true
    end
    if FriendGroups_SavedVars.show_game_icon == nil then
        FriendGroups_SavedVars.show_game_icon = true
    end
    if FriendGroups_SavedVars.show_faction_color == nil then
        -- Faction tint used to be tied to the faction icon; preserve existing look.
        FriendGroups_SavedVars.show_faction_color = (FriendGroups_SavedVars.show_faction_icons ~= false)
    end
    if FriendGroups_SavedVars.show_contact_cap == nil then
        FriendGroups_SavedVars.show_contact_cap = true
    end
    if FriendGroups_SavedVars.offline_tracker == nil then
        FriendGroups_SavedVars.offline_tracker = true
    end
    if FriendGroups_SavedVars.streamer_mode == nil then
        FriendGroups_SavedVars.streamer_mode = false
    end
    if FriendGroups_SavedVars.group_order == nil then
        FriendGroups_SavedVars.group_order = {}
    end
    if FriendGroups_SavedVars.main_guild == nil then
        FriendGroups_SavedVars.main_guild = {}
    end

    -- Nicknames moved into the friend note in 13.0.1. Decides whether the reconcile
    -- pass may run, or whether the one-time migration must be offered first.
    FriendGroups_InitNicknameSchema()

-- 1. Create Search Box
    FriendGroups_SearchBox = CreateFrame("EditBox", "FriendGroupsGlobalSearch", FriendsListFrame, "SearchBoxTemplate")
    FriendGroups_SearchBox:SetSize(20, 20)
    FriendGroups_SearchBox:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 15, -90)
    FriendGroups_SearchBox:SetPoint("TOPRIGHT", FriendsListFrame, "TOPRIGHT", -90, -90)
    FriendGroups_SearchBox:SetAutoFocus(false)
    FriendGroups_SearchBox.Instructions:SetText(L["SEARCH_PLACEHOLDER"])
    
    FriendGroups_SearchBox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(SEARCH, 1, 1, 1) 
        GameTooltip:AddLine(L["SEARCH_TOOLTIP"], nil, nil, nil, true) 
        GameTooltip:Show()
    end)

    FriendGroups_SearchBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    local FriendGroups_SearchDebounceTimer = nil
FriendGroups_SearchBox:SetScript("OnTextChanged", function(self)
    SearchBoxTemplate_OnTextChanged(self)
    local text = self:GetText()
    if text ~= searchValue then
        searchValue = text
        searchLowerValue = text:lower() -- Cache it here once!
        
        if FriendGroups_SearchDebounceTimer then
            FriendGroups_SearchDebounceTimer:Cancel()
        end
        FriendGroups_SearchDebounceTimer = C_Timer.NewTimer(0.3, function()
            FriendGroups_FriendsListUpdate(true)
            FriendGroups_SearchDebounceTimer = nil
        end)
    end
end)
    
    -- 2. Create Contact Text Tracker
    -- FriendsFont_Normal is the font the group headers' count fontstring inherits
    -- (FriendGroups.xml), so the counter reads as the grand total of that same column.
    FriendGroups_ContactText = FriendsListFrame:CreateFontString("FriendGroupsContactText", "OVERLAY", "FriendsFont_Normal")
    -- Fixed box rather than an auto-sized one: the online count is only 1-3 characters, so
    -- the text would otherwise shuffle as the number changes width and shrink the tooltip
    -- hover frame (anchored to these corners) down to a few pixels.
    FriendGroups_ContactText:SetWidth(40)
    FriendGroups_ContactText:SetJustifyH("RIGHT")
    -- Provisional placement only. FriendGroups_UpdateContactCap re-anchors this onto the
    -- group headers' count column once the list has been laid out and the column can
    -- actually be measured -- the two list backends place it differently.
    FriendGroups_ContactText:SetPoint("RIGHT", FriendsListFrame, "TOPRIGHT", -FG_COUNT_COLUMN_FALLBACK_INSET, FG_COUNT_COLUMN_Y)
	
	-- 3. Create Settings Button
    FriendGroupsGlobalSettings = CreateFrame("Button", "FriendGroupsGlobalSettings", FriendsListFrame)
    FriendGroupsGlobalSettings:SetSize(20, 20)
    FriendGroupsGlobalSettings:SetPoint("TOPRIGHT", FriendsListFrame, "TOPRIGHT", -9, -90)
    FriendGroupsGlobalSettings:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    FriendGroupsGlobalSettings:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	
    -- Published as a global so the same settings menu can be raised from more than one
    -- owner. The gear below is the legacy frame's entry point; on 12.1 the gear lives on
    -- a frame the player can no longer open, so Platform_SocialUI.lua nests this same
    -- generator under the Social UI's Battle.net bar menu instead.
    -- Signature is the standard menu generator contract: (ownerRegion, rootDescription).
    -- rootDescription may be a submenu description rather than a true root -- the two
    -- expose the same Create* API, so nesting the whole menu one level down just works.
    FriendGroups_BuildSettingsMenu = function(ownerRegion, rootDescription)
            -- Sections flagged submenu=true become flyouts (Size, Group Behaviour);
            -- Filter/Appearance stay flat in the root for live tweaking; everything
            -- past the isAdvancedStart marker collects into one "Advanced" flyout.
            -- Dividers separate root sections and the sub-sections inside Advanced.
            -- Addon identity first, at the ROOT. On 12.1 this menu is reached through the
            -- Social UI's hamburger, where nothing else says whose settings these are, so the
            -- version has to be the first thing visible rather than buried in Advanced.
            local fgVersion = C_AddOns and C_AddOns.GetAddOnMetadata
                and C_AddOns.GetAddOnMetadata(addonName, "Version")
            -- Menu titles render in Blizzard's gold font colour, which the Menu API gives no
            -- way to set. An embedded |cff escape overrides the font colour for the span it
            -- wraps, so the section headers retint with the rest of the addon. Returns the
            -- string untouched when nothing is themed, leaving Blizzard's gold to stand.
            rootDescription:CreateTitle(FriendGroups_AccentText(string.format(L["SETTINGS_VERSION"], fgVersion or "")))
            rootDescription:CreateDivider()

            local target = rootDescription
            local inAdvanced = false
            local firstRoot = true
            -- Sub-sections inside Advanced are separated by a rule, but the FIRST one must
            -- not carry a leading one: it used to sit under the version/backup block and read
            -- as a separator, and became an orphan at the top once the version moved to root.
            local firstAdvanced = true
            for _, item in ipairs(settingsMenuItems) do
                if item.condition and not item.condition() then
                    -- Item hidden this session (e.g. EllesmereUI not detected).
                elseif item.isAdvancedStart then
                    if not firstRoot then rootDescription:CreateDivider() end
                    target = rootDescription:CreateButton(L["SETTINGS_ADVANCED"])
                    inAdvanced = true
                    firstRoot = false
                elseif item.isBackupStamp then
                    -- Sits with the Export/Import buttons in the Profile Sync section rather
                    -- than at the top of Advanced, where it read as a stray line above the
                    -- unrelated Automation block.
                    local lastTs = FriendGroups_SavedVars and FriendGroups_SavedVars.last_export_time
                    if lastTs and lastTs > 0 then
                        target:CreateTitle(FriendGroups_AccentText(string.format(L["SETTINGS_LAST_BACKUP"], date("%Y-%m-%d %H:%M", lastTs))))
                    end
                elseif item.isSubTitle then
                    -- A heading INSIDE the current submenu. Distinct from isTitle, which
                    -- resets `target` back to the root: using isTitle here would silently
                    -- send every following item to the top level instead of into the
                    -- flyout it was written for.
                    target:CreateTitle(FriendGroups_AccentText(item.text))
                elseif item.isTitle and item.text ~= "" then
                    if inAdvanced then
                        -- sub-section header inside the Advanced flyout
                        if not firstAdvanced then target:CreateDivider() end
                        target:CreateTitle(FriendGroups_AccentText(item.text))
                        firstAdvanced = false
                    elseif item.submenu then
                        if not firstRoot then rootDescription:CreateDivider() end
                        target = rootDescription:CreateButton(item.text)
                        firstRoot = false
                    else
                        if not firstRoot then rootDescription:CreateDivider() end
                        target = rootDescription
                        target:CreateTitle(FriendGroups_AccentText(item.text))
                        firstRoot = false
                    end
                elseif item.isTitle then
                    target:CreateDivider()
                elseif item.notCheckable then
                    -- Standard buttons (like Reset or the backup actions)
                    local btn = target:CreateButton(item.text, function()
                        -- Run the function. (Modern menus auto-close on button clicks)
                        if item.func then item.func() end
                    end)
                    if item.tooltip and btn and btn.SetTooltip then
                        btn:SetTooltip(function(tooltip)
                            GameTooltip_SetTitle(tooltip, item.tooltipTitle or item.text)
                            for _, line in ipairs(item.tooltip) do
                                GameTooltip_AddNormalLine(tooltip, line, true)
                            end
                        end)
                    end
                else
                    -- Checkboxes — keep the menu/flyout open for live tweaking
                    local cb = target:CreateCheckbox(
                        item.text,
                        function() return item.checked() end,
                        function() item.func() end
                    )
                    if item.tooltip and cb and cb.SetTooltip then
                        cb:SetTooltip(function(tooltip)
                            GameTooltip_SetTitle(tooltip, item.tooltipTitle or item.text)
                            for _, line in ipairs(item.tooltip) do
                                GameTooltip_AddNormalLine(tooltip, line, true)
                            end
                        end)
                    end
                end
            end
    end

    FriendGroupsGlobalSettings:SetScript("OnClick", function(self)
        Compat.OpenContextMenu(self, FriendGroups_BuildSettingsMenu)
    end)

    FriendGroupsGlobalSettings:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["SETTINGS_TITLE"], 1, 1, 1)
        GameTooltip:Show()
    end)
    
    FriendGroupsGlobalSettings:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- 3. Apply Hooks
    -- [[ SECURE LIST REFRESH (12.2.2 TAINT FIX) ]]
    -- Overwriting the FriendsList_Update global permanently taints the variable: every
    -- secure Blizzard read of it (FriendsFrame_OnEvent, FriendsFrame_CheckBattlenetStatus --
    -- these fire on BNet status churn even with the panel closed) marks that execution as
    -- FriendGroups-tainted. In rated PvP that taint collides with secret values inside the
    -- chat pipeline (HistoryKeeper access IDs, ChatConfig header widths) and FriendGroups
    -- gets blamed for whispers failing to render. A post-hook leaves the global untouched:
    -- Blizzard's update runs securely first (its flat provider briefly occupies the
    -- ScrollBox), then in the SAME execution we re-assert the grouped provider -- nothing
    -- renders in between, so there is no visible flicker -- and schedule a coalesced rebuild.
    hooksecurefunc("FriendsList_Update", function()
        -- ScrollBox-only: re-assert our grouped provider after Blizzard's native
        -- update briefly swaps in its flat one (no ScrollBox on Classic clients).
        if Compat.HAS_SCROLLBOX then FriendGroups_ReassertGroupedProvider() end
        FriendGroups_RequestListUpdate()
    end)

    -- [[ EVENT DIET (12.2.2 PERF FIX) ]]
    -- With the global no longer overridden, Blizzard's native FriendsList_Update runs
    -- again -- and with the panel open it rebuilds its entire provider (one fresh
    -- C_BattleNet.GetFriendAccountInfo table per friend) on EVERY friend presence
    -- change and raid-roster event. On a large friends list in raid/M+ that meant
    -- constant GC churn, high memory use and stutter. Verified against 12.0.7 source:
    -- these two events' FriendsFrame_OnEvent branches call FriendsList_Update() and
    -- nothing else, registration happens once in FriendsFrame_OnLoad, and nothing
    -- re-registers on show/hide. The Dirty Roster Engine listens to the same events
    -- on its own frame and drives the coalesced refresh instead. The rare remaining
    -- triggers (invites, list size changes, OnShow, Battle.net status changes,
    -- periodic FRIENDLIST_UPDATE) still run the native update harmlessly.
    -- ScrollBox-only perf "event diet": Blizzard's native FriendsList_Update rebuilds
    -- its whole provider on these events; on Classic the native HybridScroll update is
    -- what we rely on, so leave them registered there.
    if Compat.HAS_SCROLLBOX then
        FriendsFrame:UnregisterEvent("BN_FRIEND_INFO_CHANGED")
        FriendsFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end
    
    -- ScrollBox-only: hooking Blizzard's per-button updater and the ScrollBox button
    -- mixin only makes sense where the list is a ScrollBox. On Classic our rendering
    -- is driven by FriendsFrameFriendsScrollFrame.update instead.
    if Compat.HAS_SCROLLBOX then
        hooksecurefunc("FriendsFrame_UpdateFriendButton", FriendGroups_FriendsListUpdateFriendButton)
        hooksecurefunc(FriendsListButtonMixin, "OnClick", FriendGroups_FriendsListButtonTemplateClick)
    end

    -- Unit right-click menu injection via the modern Menu API. Clients without it
    -- fall back to a UnitPopup hook (added in a later step).
    if Compat.HAS_MENU_API then
        Menu.ModifyMenu("MENU_UNIT_GLUE_FRIEND", FriendGroups_AddDropDownNew)
        Menu.ModifyMenu("MENU_UNIT_FRIEND", FriendGroups_AddDropDownNew)
        Menu.ModifyMenu("MENU_UNIT_FRIEND_OFFLINE", FriendGroups_AddDropDownNew)
        Menu.ModifyMenu("MENU_UNIT_BN_FRIEND", FriendGroups_AddDropDownNew)
        Menu.ModifyMenu("MENU_UNIT_BN_FRIEND_OFFLINE", FriendGroups_AddDropDownNew)
    end

    -- 4. Setup Scroll View
    SetupGroupedView()
    
	-- [[ HEIGHT DEFAULT: 190 (Medium) ]] --
    -- A fresh install is already seeded with 190 in the SavedVars table, so this line is
    -- reached only by an UPGRADE from a build old enough never to have written the field.
    -- Those users have expressed no preference, so they get the same default a new install
    -- gets; anyone who ever picked a height carries it explicitly and never lands here.
    -- Tested with `not`, not `== nil`, deliberately: 0 is Small and is truthy in Lua, so a
    -- user who chose Small is not silently resized on every login.
    if not FriendGroups_SavedVars.extra_height then
        FriendGroups_SavedVars.extra_height = 190
    end
    FriendGroups_UpdateSize()

    FriendGroups_UpdateContactCap()
    FriendGroups_FriendsListUpdate(true)
end

-- Both anti-flicker guards ask Compat for the panel rather than naming FriendsFrame, because
-- on 12.1 that frame is present but permanently hidden: IsMouseOver() is false forever, the
-- guard never holds, and the alt tooltip is torn down the instant the native one repaints.
-- Compat.GetContactListAnchor returns FriendsFrame on every other client, so retail and
-- Classic evaluate the identical expression.
hooksecurefunc(FriendsTooltip, "Hide", function(self)
    -- [[ ANTI-FLICKER FIX: Ignore hide command if mouse is still on the Friends List ]]
    local contactPanel = Compat.GetContactListAnchor()
    if contactPanel and contactPanel:IsMouseOver() then return end

    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
    FriendGroups_CurrentHoverAnchor = nil
end)

hooksecurefunc(GameTooltip, "Hide", function(self)
    -- [[ ANTI-FLICKER FIX: Protect against GameTooltip native hide collisions ]]
    local contactPanel = Compat.GetContactListAnchor()
    if contactPanel and contactPanel:IsMouseOver() then return end
    if CommunitiesFrame and CommunitiesFrame:IsMouseOver() then return end
    
    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
    FriendGroups_CurrentHoverAnchor = nil
end)

SetupGroupedView = function()
    if not Compat.HAS_SCROLLBOX then
        -- Classic (non-ScrollBox): drive the native HybridScrollFrame. We must also
        -- replace Blizzard's friends updater so ONLY our grouped render populates the
        -- frame -- otherwise the native updater runs too and its dynamic-height scroll
        -- state fights ours, crashing HybridScrollFrame_SetOffset on scroll. The
        -- .update handler re-renders the visible slice as the user scrolls.
        local scrollFrame = FriendsFrameFriendsScrollFrame
        if scrollFrame then
            -- Seat the native HybridScroll frame below our search box and fit it to
            -- the list area. FriendsListFrame exists on Classic (only its ScrollBox is
            -- absent), so anchor to it exactly as retail anchors its ScrollBox.
            scrollFrame:ClearAllPoints()
            scrollFrame:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 7, -115)
            scrollFrame:SetPoint("BOTTOMRIGHT", FriendsListFrame, "BOTTOMRIGHT", -28, 35)

            -- Bring the native scrollbar down to track the re-seated list. Seated with
            -- HybridScrollBarTemplate's native convention: the bar hangs off the frame's
            -- right edge, and the -16/+16 vertical insets are exactly the height of the
            -- up/down caret buttons (children of the bar, anchored to its ends), keeping
            -- the carets flush with the list's top and bottom.
            local scrollBar = _G.FriendsFrameFriendsScrollFrameScrollBar
            if scrollBar then
                scrollBar:ClearAllPoints()
                scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -16)
                scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 16)
            end

            if _G.FriendsFrame_UpdateFriends then
                _G.FriendsFrame_UpdateFriends = FriendGroups_FriendsListUpdate
            end
            scrollFrame.update = FriendGroups_FriendsListUpdate
        end

        -- First-load fill: the HybridScroll button pool is sized from the frame's
        -- height, which is only correct once the frame is actually shown (it is hidden
        -- at login). Re-run sizing on show so a Large list fills immediately instead of
        -- staying short until the size is toggled by hand.
        if FriendsFrame and not FriendsFrame.fgOnShowHooked then
            FriendsFrame.fgOnShowHooked = true
            FriendsFrame:HookScript("OnShow", function()
                if FriendGroups_UpdateSize then FriendGroups_UpdateSize() end
            end)
        end
        return
    end
    local view = CreateScrollBoxListLinearView()
    view:SetElementFactory(function(factory, elementData)
        local buttonType = elementData.buttonType;
        if buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
            factory("FriendGroupsFrameFriendDividerTemplate", FriendGroups_FriendsListUpdateDividerTemplate);
        elseif buttonType == FRIENDS_BUTTON_TYPE_INVITE_HEADER then
            factory("FriendsPendingInviteHeaderButtonTemplate",
                FriendGroups_FriendsFrameUpdateFriendInviteHeaderButton);
        elseif buttonType == FRIENDS_BUTTON_TYPE_INVITE then
            factory("FriendsFrameFriendInviteTemplate", FriendGroups_FriendsFrameUpdateFriendInviteButton);
        elseif buttonType == FRIENDS_BUTTON_TYPE_BNET or buttonType == FRIENDS_BUTTON_TYPE_WOW then
            -- 12.0 FIX: Switched from custom XML button to Blizzard's Native Secure Template
            -- This completely bypasses the Chat/Secret ID taint vector when clicking friends.
            factory("FriendsListButtonTemplate", FriendGroups_FriendsListUpdateFriendButton);
        else
            -- 12.2.2: Blizzard's native FriendsList_Update runs again (post-hook mode) and its
            -- provider can carry element types we never group (e.g. matchmaking party invites).
            -- Render those inert instead of forcing them through the friend-row initializer.
            factory("FriendGroupsFrameFriendDividerTemplate", FriendGroups_FriendsListUpdateInertTemplate);
        end
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(FriendsListFrame.ScrollBox, FriendsListFrame.ScrollBar, view);
end

-- Fixed left indent for group divider titles. Deliberately constant (does NOT
-- follow the class-icon toggle) so the group headers never shift position when
-- class icons are turned on/off.
local fgRowNameGutter = 38

-- Resolve an English class token ("MAGE") from a localized class name, or pass
-- through if it is already a token. Mirrors FriendGroups_GetClassColorCode.
local function FriendGroups_ResolveClassToken(name)
    if not name or name == "" then return nil end
    if RAID_CLASS_COLORS[name] then return name end
    for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if v == name then return k end end
    for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if v == name then return k end end
    return nil
end

-- Published for the platform renderers (file-local, so invisible to Platform_*.lua as a
-- global). The Social UI row builds its class icon from the token this resolves.
addonTable.State.ResolveClassToken = FriendGroups_ResolveClassToken

-- Best-effort class for a friend's account row when the live API reports none
-- (12.0.7 presence reduction: className/characterName are nil for most friends'
-- sessions). Tiers: exact alt-cache match on the current character when its name
-- is known -> the user's selected main for that friend (FriendGroups_ActiveAKA,
-- which is also the "aka [main]" the row displays) -> the most recently seen
-- cached alt. Returns a class name/token for FriendGroups_ResolveClassToken, or
-- nil. Display-only: invite gating and flavor detection never read this.
-- ============================================================================
-- [[ SELECTED MAIN'S CLASS ]]
-- The class of the character the user explicitly picked as this contact's main, or nil.
--
-- Exists so an OFFLINE contact can still show a class icon -- desaturated, to say plainly
-- that it describes their main rather than what they are playing right now -- instead of a
-- blank column. An offline row has no live class, so before this the icon slot sat empty
-- for exactly the contacts the user had gone to the trouble of identifying.
--
-- Read straight from manual_mains + alt_cache rather than through FriendGroups_ActiveAKA,
-- which is only populated inside the show_guildmates branch of FriendGroups_SetGroups: the
-- icon has nothing to do with guild grouping and must not vanish when that setting is off.
--
-- Deliberately NOT a general "best guess" -- the newest cached alt is not offered here. An
-- icon for a character the user never nominated would be a guess presented as a fact.
-- ============================================================================
function FriendGroups_LookupMainClass(accountIdentifier)
    if type(accountIdentifier) ~= "string" or accountIdentifier == "" then return nil end
    if type(FriendGroups_SavedVars) ~= "table" then return nil end

    local mains = FriendGroups_SavedVars.manual_mains
    local mainKey = (type(mains) == "table") and mains[accountIdentifier] or nil
    if not mainKey then return nil end

    local alts = (type(FriendGroups_SavedVars.alt_cache) == "table")
        and FriendGroups_SavedVars.alt_cache[accountIdentifier] or nil
    if type(alts) ~= "table" then return nil end

    for _, alt in ipairs(alts) do
        local currentKey = (alt.charName or "") .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")
        if currentKey == mainKey or alt.key == mainKey then
            if type(alt.class) == "string" and alt.class ~= "" then return alt.class end
            return nil
        end
    end
    return nil
end

function FriendGroups_LookupAccountClass(accountInfo, characterName, realmName)
    if not accountInfo then return nil end
    local key = FriendGroups_AccountIdentifier(accountInfo)
    if not key then return nil end

    local alts = FriendGroups_SavedVars and type(FriendGroups_SavedVars.alt_cache) == "table"
        and FriendGroups_SavedVars.alt_cache[key]

    -- 1. Exact match on the live character (name known, other fields degraded).
    if type(characterName) == "string" and characterName ~= "" and type(alts) == "table" then
        local cleanRealm = FriendGroups_CleanRealmName(realmName or "")
        for _, alt in ipairs(alts) do
            if alt.charName == characterName
                and (cleanRealm == "" or FriendGroups_CleanRealmName(alt.realm or "") == cleanRealm) then
                if type(alt.class) == "string" and alt.class ~= "" then return alt.class end
            end
        end
    end

    -- 2. Selected main: coherent with the "aka [main]" already shown on the row.
    local akaInfo = FriendGroups_ActiveAKA and FriendGroups_ActiveAKA[key]
    if akaInfo and type(akaInfo.class) == "string" and akaInfo.class ~= "" then
        return akaInfo.class
    end

    -- 3. Most recently seen cached alt.
    if type(alts) == "table" then
        local bestClass, bestTime
        for _, alt in ipairs(alts) do
            if type(alt.class) == "string" and alt.class ~= "" then
                local t = tonumber(alt.timestamp) or 0
                if not bestClass or t > bestTime then
                    bestClass, bestTime = alt.class, t
                end
            end
        end
        if bestClass then return bestClass end
    end

    return nil
end

-- Standard FriendGroups row layout:
--   * class icon of the friend's CURRENT character on the left, vertically
--     centered so it spans both text rows (like EllesmereUI);
--   * name/info indented a consistent amount to clear the icon;
--   * the online / AFK / DND status icon moved inline to just after the name
--     text (and any "aka [alt]" suffix, which is part of the name string).
-- Called at the end of the friend-button render, and re-invoked by the
-- EllesmereUI skin after it changes the row font (which alters name width).
function FriendGroups_ApplyRowLayout(button)
    if not button or not button.name then return end

    local rowH = (button:GetHeight() or 0) - 4
    local iconSize = (rowH > 0) and rowH or 16
    local showIcons = not (FriendGroups_SavedVars and FriendGroups_SavedVars.show_class_icons == false)
    local leftPad = showIcons and (iconSize + 8) or 6   -- left gutter (reserved for the class icon)

    -- Class icon (current character's class).
    if not button.fgClassIcon then
        button.fgClassIcon = button:CreateTexture(nil, "ARTWORK", nil, 2)
    end
    local icon = button.fgClassIcon
    local token = showIcons and FriendGroups_ResolveClassToken(button.fgClass)
    if token then
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", button, "LEFT", 4, 0)
        icon:SetSize(iconSize, iconSize)
        local atlas = GetClassAtlas and GetClassAtlas(token)
        if atlas then
            icon:SetTexCoord(0, 1, 0, 1)
            icon:SetAtlas(atlas)
        else
            icon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
            local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[token]
            if c then icon:SetTexCoord(c[1], c[2], c[3], c[4]) end
        end
        icon:Show()
    else
        icon:Hide()
    end

    -- Status icon sits at the START of the row (after the class icon, before the
    -- name), vertically centered across both text rows. The name/info column
    -- follows, truncating with "..." clear of the right-side icons.
    local STATUS_W = 16
    local showStatus = not (FriendGroups_SavedVars and FriendGroups_SavedVars.show_status == false)
    -- A visible favorite star claims the status slot even when the status icon is
    -- toggled off, so the star never overlaps the name text.
    local hasStar = button.Favorite and button.Favorite:IsShown()
    local nameLeft = leftPad + ((showStatus or hasStar) and (STATUS_W + 4) or 0)

    -- Game/client icon (the "W" etc.). When disabled, hide it and shift the faction
    -- icon / realm flag right into its vacated slot so the name/info can grow (the
    -- flag is anchored to the faction icon, so it follows automatically).
    local showGameIcon = not (FriendGroups_SavedVars and FriendGroups_SavedVars.show_game_icon == false)
    local gameIconW = 22
    if button.gameIcon then
        local gw = button.gameIcon:GetWidth()
        if gw and gw >= 1 then gameIconW = gw end
        if not showGameIcon then
            button.gameIcon:Hide()
            if button.facIcon and button.facIcon:IsShown() then
                button.facIcon:ClearAllPoints()
                button.facIcon:SetPoint("RIGHT", button.gameIcon, "RIGHT", 0, 0)
            elseif button.realmFlag and button.realmFlag:IsShown() then
                button.realmFlag:ClearAllPoints()
                button.realmFlag:SetPoint("RIGHT", button.gameIcon, "RIGHT", 0, 0)
            end
        end
    end

    -- Right reserve = invite button + margins, PLUS the game icon (when shown) and
    -- the faction icon / realm flag (only when shown). Toggling any of them off lets
    -- the name/info reclaim that width.
    local rightReserve = 31
    if showGameIcon then
        rightReserve = rightReserve + gameIconW + 2
    end
    if button.facIcon and button.facIcon:IsShown() then
        rightReserve = rightReserve + (button.facIcon:GetWidth() or 20) + 2
    end
    if button.realmFlag and button.realmFlag:IsShown() then
        rightReserve = rightReserve + (button.realmFlag:GetWidth() or 16) + 2
    end

    button.name:ClearAllPoints()
    button.name:SetPoint("TOPLEFT", button, "TOPLEFT", nameLeft, -4)
    button.name:SetPoint("TOPRIGHT", button, "TOPRIGHT", -rightReserve, -4)
    button.name:SetWordWrap(false)
    if button.info then
        button.info:ClearAllPoints()
        button.info:SetPoint("TOPLEFT", button.name, "BOTTOMLEFT", 0, -2)
        button.info:SetPoint("RIGHT", button.name, "RIGHT", 0, 0)
        button.info:SetWordWrap(false)
    end

    if button.status then
        if showStatus then
            button.status:ClearAllPoints()
            button.status:SetSize(STATUS_W, STATUS_W)
            -- "LEFT" anchors at the button's vertical middle -> centered across both rows.
            button.status:SetPoint("LEFT", button, "LEFT", leftPad, 0)
            button.status:Show()
        else
            button.status:Hide()
        end
    end

    -- Favorite star: corner badge over the status icon when status is shown, or
    -- centered in the reserved slot when the star is the slot's only occupant.
    -- Never derived from the name text (whose width used to push it off the row).
    if button.Favorite then
        button.Favorite:ClearAllPoints()
        button.Favorite:SetSize(14, 14)
        button.Favorite:SetDrawLayer("OVERLAY", 7)
        if showStatus then
            button.Favorite:SetPoint("CENTER", button, "LEFT", leftPad + STATUS_W - 3, 6)
        else
            button.Favorite:SetPoint("CENTER", button, "LEFT", leftPad + STATUS_W * 0.5, 0)
        end
    end
end

-- ============================================================================
-- [[ CHARACTER-FRIEND ROW PARITY (12.2.2b) ]]
-- ============================================================================
-- Faction lookup for character friends: C_FriendList exposes no faction field, but
-- the friend GUID resolves race -> faction through documented APIs. Positive results
-- are cached (faction is race-bound); unknowns (typically offline friends) are
-- retried because the data becomes available once they are online.
local FriendGroups_GuidFactionCache = {}
local function FriendGroups_GetWowFriendFaction(guid)
    if not guid then return nil end
    local cached = FriendGroups_GuidFactionCache[guid]
    if cached then return cached end
    local location = PlayerLocation and PlayerLocation.CreateFromGUID and PlayerLocation:CreateFromGUID(guid)
    local raceID = location and C_PlayerInfo.GetRace and C_PlayerInfo.GetRace(location)
    local factionInfo = raceID and C_CreatureInfo.GetFactionInfo and C_CreatureInfo.GetFactionInfo(raceID)
    local tag = factionInfo and factionInfo.groupTag
    if tag then FriendGroups_GuidFactionCache[guid] = tag end
    return tag
end

-- Reusable probe table so realm-flag lookups for character rows allocate nothing.
-- Character friends are always in the player's own region.
local FriendGroups_WowRealmProbe = {}

-- Travel-pass replacement for character rows. Blizzard's own OnClick resolves the
-- row id against the *BNet* friends list, so on a character row it would target
-- whichever unrelated BNet friend happens to share the index. Party invites are
-- unprotected API, so a plain script handles the character case.
local function FriendGroups_WowFriendInviteOnClick(self)
    local row = self:GetParent()
    if not (row and row.buttonType == FRIENDS_BUTTON_TYPE_WOW and row.id) then return end
    local finfo = C_FriendList.GetFriendInfoByIndex(row.id)
    if finfo and finfo.connected and finfo.name then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        Compat.InviteUnit(finfo.name)
    end
end

FriendGroups_FriendsListUpdateFriendButton = function(button, elementData)
    if not FriendGroups_Loaded then return end

    local isFriendFrame = false
    if button and button.GetParent and FriendsListFrame then
        local current = button:GetParent()
        for i = 1, 15 do
            if not current then break end
            if current == FriendsListFrame then isFriendFrame = true break end
            current = current.GetParent and current:GetParent()
        end
    end
    if not isFriendFrame then return end

    -- 12.2.2b: while Blizzard's transient flat provider occupies the ScrollBox (hook
    -- mode, rare native updates), skip rendering entirely -- the grouped provider is
    -- swapped back in the same execution and every visible row is re-initialized then,
    -- so painting flat data here is pure waste.
    if FriendGroups_ActiveProvider and FriendsListFrame.ScrollBox:GetDataProvider() ~= FriendGroups_ActiveProvider then return end

	local id = elementData.id;
	local buttonType = elementData.buttonType;
	button.buttonType = buttonType;
	button.id = id;
	button.fgClass = nil;   -- current character's class (localized); set below when online
	button.fgNote = nil;    -- raw server note for this friend
	if button.gameIcon then button.gameIcon:SetDesaturated(false); button.gameIcon:SetVertexColor(1, 1, 1) end

	if button.facIcon then button.facIcon:Hide() end
    if button.realmFlag then button.realmFlag:Hide() end 

	local nameText, nameColor, infoText, isFavoriteFriend, statusTexture;
	local hasTravelPassButton = false;
	local isCrossFactionInvite = false;
	local inviteFaction = nil;

	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(id);
		button.fgNote = info and info.notes;
		-- 12.2.2b: character-friend rows mirror the BNet row format -- class-coloured
		-- [Name] + level on line 1 (realm stripped), zone - realm on line 2. Cross-realm
		-- friends carry the realm in their name ("Name-Realm"); same-realm friends use
		-- the player's own realm so line 2 reads identically to a BNet row.
		local charName, charRealm = strsplit("-", info.name or "");
		if (info.connected) then
			button.background:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a);
			if (info.afk) then button.status:SetTexture(FRIENDS_TEXTURE_AFK);
			elseif (info.dnd) then button.status:SetTexture(FRIENDS_TEXTURE_DND);
			else button.status:SetTexture(FRIENDS_TEXTURE_ONLINE); end
			button.fgClass = info.className;

			-- Level suffix: identical rules to FriendGroups_GetBNetButtonNameText.
			local levelSuffix
			-- WoW character friends are on our own client, so gameInfo is nil and
			-- the comparison is against the host's own live cap.
			if (not info.level) or info.level == 0 or (FriendGroups_SavedVars.hide_high_level and Compat.IsMaxLevel(nil, info.level)) then
				levelSuffix = ""
			else
				levelSuffix = " " .. info.level
			end

			-- Bracketed, class-coloured character name -- the same treatment the
			-- character portion of a BNet row gets (class conveyed by colour, not text).
			local shownName = charName or info.name
			if FriendGroups_IsStreamerMode() then shownName = FriendGroups_MaskName(shownName) end
			local displayName = "[" .. shownName .. "]"
			if FriendGroups_SavedVars.colour_classes and info.className then
				displayName = FriendGroups_GetClassColorCode(info.className) .. displayName .. FONT_COLOR_CODE_CLOSE
			end

			nameText = displayName .. levelSuffix;
			-- Base colour matches BNet rows so the level suffix renders identically;
			-- the name itself is class-coloured inline above.
			nameColor = FRIENDS_BNET_NAME_COLOR;
			infoText = FriendGroups_GetOnlineInfoText(BNET_CLIENT_WOW, info.mobile, info.rafLinkType, info.area, charRealm or GetRealmName());
			
			-- Game icon: BNet rows show the client icon; character friends are by
			-- definition playing Retail WoW.
			C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium);
			button.gameIcon:SetAlpha(1);
			button.gameIcon:Show();

			local factionName = FriendGroups_GetWowFriendFaction(info.guid) or ""
			isCrossFactionInvite = factionName ~= "" and factionName ~= playerFactionGroup;
			inviteFaction = factionName;

			-- Faction-crested invite button, same as BNet rows (the shared tail applies
			-- the crest atlas; the OnClick swap below guards the BNet id collision).
			hasTravelPassButton = true;
			button.travelPassButton:Enable();

			local factionShown = false
			if FriendGroups_SavedVars.show_faction_icons and factionName ~= "" then
				if not button.facIcon then
					button.facIcon = button:CreateTexture("facIcon")
					button.facIcon:SetSize(button.gameIcon:GetWidth(), button.gameIcon:GetHeight())
				end
				button.facIcon:ClearAllPoints()
				button.facIcon:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
				button.facIcon:SetTexture(FriendGroups_GetFactionIcon(factionName))
				button.facIcon:Show()
				factionShown = true
			elseif button.facIcon then
				button.facIcon:Hide()
			end

			-- Faction row tint -- same toggle and colours as BNet rows.
			if FriendGroups_SavedVars.show_faction_color ~= false then
				if factionName == "Horde" then
					button.background:SetColorTexture(0.7, 0.2, 0.2, 0.2)
				elseif factionName == "Alliance" then
					button.background:SetColorTexture(0.2, 0.2, 0.7, 0.2)
				end
			end

			-- Realm flag -- same toggle, textures and anchoring as BNet rows.
			if FriendGroups_SavedVars.show_flags then
				if not button.realmFlag then
					button.realmFlag = button:CreateTexture("realmFlag")
					button.realmFlag:SetSize(button.gameIcon:GetWidth() * 0.75, button.gameIcon:GetHeight() * 0.75)
				end
				FriendGroups_WowRealmProbe.realmName = charRealm or GetRealmName()
				FriendGroups_WowRealmProbe.regionID = GetCurrentRegion()
				local flagTexture = FriendGroups_GetRealmInfo(FriendGroups_WowRealmProbe)
				if flagTexture then
					button.realmFlag:SetTexture(flagTexture)
					button.realmFlag:Show()
					button.realmFlag:ClearAllPoints()
					if factionShown then
						button.realmFlag:SetPoint("RIGHT", button.facIcon, "LEFT", -1, 0)
					else
						button.realmFlag:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
					end
				else
					button.realmFlag:Hide()
				end
			elseif button.realmFlag then
				button.realmFlag:Hide()
			end
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameText = charName or info.name;
			if FriendGroups_IsStreamerMode() then nameText = FriendGroups_MaskName(nameText) end
			nameColor = FRIENDS_GRAY_COLOR;
			infoText = FRIENDS_LIST_OFFLINE;
			-- Keep the realm visible for offline cross-realm friends (character names
			-- are only unique per realm), honouring the same show_realm toggle.
			if FriendGroups_SavedVars.show_realm and charRealm and charRealm ~= "" then
				infoText = infoText .. " - " .. charRealm
			end
			
			button.gameIcon:Show();
			C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium);
			button.gameIcon:SetAlpha(0.3);
		end
		-- 12.2.2b: summon button now docks on the game icon exactly like BNet rows
		-- (the icon yields to the summon button when a summon is available).
		button.summonButton:ClearAllPoints();
		button.summonButton:SetPoint("CENTER", button.gameIcon, "CENTER", 1, 0);
		FriendsFrame_SummonButton_Update(button.summonButton);
		if info.connected then
			local shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton);
			button.gameIcon:SetShown(not shouldShowSummonButton);
		end

	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id);
		if accountInfo then
			button.fgNote = accountInfo.note;
            -- [[ MASSIVE OPTIMIZATION: Pull localized API data inline instead of running a redundant global function search ]]
			nameText, nameColor, statusTexture = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
            
            local accountName = accountInfo.accountName
            isFavoriteFriend = accountInfo.isFavorite
            local battleTag = accountInfo.battleTag
            local canCoop = CanCooperateWithGameAccount(accountInfo)
            
            local client, characterName, class, level, timerunningSeasonID, realmName, factionName
            if accountInfo.gameAccountInfo then
                client = accountInfo.gameAccountInfo.clientProgram
                characterName = accountInfo.gameAccountInfo.characterName
                class = accountInfo.gameAccountInfo.className
                level = accountInfo.gameAccountInfo.characterLevel
                timerunningSeasonID = accountInfo.gameAccountInfo.timerunningSeasonID
                realmName = accountInfo.gameAccountInfo.realmName
                factionName = accountInfo.gameAccountInfo.factionName
            end

            -- 12.0.7 presence reduction: live className is nil for most friends'
            -- sessions. Recover the class from FriendGroups' own cached data so
            -- class colors and icons survive on the account row (display-only).
            if client == BNET_CLIENT_WOW and accountInfo.gameAccountInfo
                and accountInfo.gameAccountInfo.isOnline and (not class or class == "") then
                class = FriendGroups_LookupAccountClass(accountInfo, characterName, realmName)
            end

			if FriendGroups_SavedVars.show_mobile_afk and client == 'BSAp' then statusTexture = FRIENDS_TEXTURE_AFK end

			nameText = FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag, timerunningSeasonID, realmName, accountInfo.gameAccountInfo)
			button.status:SetTexture(statusTexture);
            
            factionName = factionName or ""
			isCrossFactionInvite = factionName ~= "" and factionName ~= playerFactionGroup;
			inviteFaction = factionName;

			if accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
				button.fgClass = (client == BNET_CLIENT_WOW) and class or nil;
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if FriendGroups_ShowRichPresenceOnly(client, accountInfo.gameAccountInfo.wowProjectID, factionName, accountInfo.gameAccountInfo.realmID, accountInfo.gameAccountInfo.areaName) then
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName, realmName);
				end

				C_Texture.SetTitleIconTexture(button.gameIcon, client, Enum.TitleIconVersion.Medium);
				local fadeIcon = (client == BNET_CLIENT_WOW) and not Compat.IsSameProject(accountInfo.gameAccountInfo);
				if fadeIcon then button.gameIcon:SetAlpha(0.6); else button.gameIcon:SetAlpha(1); end
					-- Retail gold vs Classic green: tint the client icon by the friend project.
					Compat.TintGameIcon(button.gameIcon, accountInfo.gameAccountInfo)

				local shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton);
				button.gameIcon:SetShown(not shouldShowSummonButton);

				hasTravelPassButton = true;
				local restriction = FriendsFrame_GetInviteRestriction(button.id);
				if restriction == INVITE_RESTRICTION_NONE then button.travelPassButton:Enable(); else button.travelPassButton:Disable(); end

                local factionShown = false
                if FriendGroups_SavedVars.show_faction_icons then
                    if not button.facIcon then
                        button.facIcon = button:CreateTexture("facIcon")
                        button.facIcon:SetSize(button.gameIcon:GetWidth(), button.gameIcon:GetHeight())
                    end

                    button.facIcon:ClearAllPoints()
                    button.facIcon:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
                    button.facIcon:SetTexture(FriendGroups_GetFactionIcon(factionName))
                    button.facIcon:Show()
                    factionShown = true
                else
                    if button.facIcon then button.facIcon:Hide() end
                end

                -- Faction row tint -- its own toggle, independent of the faction icon.
                if FriendGroups_SavedVars.show_faction_color ~= false then
                    if factionName == "Horde" then
                        button.background:SetColorTexture(0.7, 0.2, 0.2, 0.2)
                    elseif factionName == "Alliance" then
                        button.background:SetColorTexture(0.2, 0.2, 0.7, 0.2)
                    end
                end

                if FriendGroups_SavedVars.show_flags then
                    if not button.realmFlag then
                        button.realmFlag = button:CreateTexture("realmFlag")
                        button.realmFlag:SetSize(button.gameIcon:GetWidth() * 0.75, button.gameIcon:GetHeight() * 0.75)
                    end
                    
                    local flagTexture, _ = FriendGroups_GetRealmInfo(accountInfo.gameAccountInfo)

                    if flagTexture then
                        button.realmFlag:SetTexture(flagTexture)
                        button.realmFlag:Show()
                        button.realmFlag:ClearAllPoints()
                        
                        if factionShown then
                            button.realmFlag:SetPoint("RIGHT", button.facIcon, "LEFT", -1, 0)
                        else
                            button.realmFlag:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
                        end
                    else
                        button.realmFlag:Hide()
                    end
                else
                    if button.realmFlag then button.realmFlag:Hide() end
                end

			else
				button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
				infoText = FriendsFrame_GetLastOnlineText(accountInfo);
				
				button.gameIcon:Show();
				C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_APP, Enum.TitleIconVersion.Medium);
				button.gameIcon:SetAlpha(0.3);
			end

			if FriendGroups_SavedVars.add_mobile_text and infoText == '' and client == 'BSAp' then infoText = L["STATUS_MOBILE"] end

			button.summonButton:ClearAllPoints();
			button.summonButton:SetPoint("CENTER", button.gameIcon, "CENTER", 1, 0);
			FriendsFrame_SummonButton_Update(button.summonButton);
		end
	end

	-- 12.2.2b: swap the travel-pass OnClick per row type (see
	-- FriendGroups_WowFriendInviteOnClick) and restore Blizzard's handler whenever a
	-- recycled frame renders a BNet row again.
	if button.travelPassButton then
		local wantWowInvite = (buttonType == FRIENDS_BUTTON_TYPE_WOW)
		if button.fgTravelPassIsWow ~= wantWowInvite then
			button.fgTravelPassIsWow = wantWowInvite
			if not button.fgTravelPassOrigOnClick then
				button.fgTravelPassOrigOnClick = button.travelPassButton:GetScript("OnClick")
			end
			if wantWowInvite then
				button.travelPassButton:SetScript("OnClick", FriendGroups_WowFriendInviteOnClick)
			elseif button.fgTravelPassOrigOnClick then
				button.travelPassButton:SetScript("OnClick", button.fgTravelPassOrigOnClick)
			end
		end
	end

	if hasTravelPassButton then button.travelPassButton:Show(); else button.travelPassButton:Hide(); end

	-- selectionLocked replaces the old insecure nil-writes to FriendsFrame.selectedFriend:
	-- reading Blizzard's selection fields from addon code is taint-safe, writing them was not.
	-- The lock suppresses the highlight after open/close exactly like the old clear did.
	local selected = (not FriendGroupsFrame.selectionLocked) and (FriendsFrame.selectedFriendType == buttonType) and (FriendsFrame.selectedFriend == id);
	FriendsFrame_FriendButtonSetSelection(button, selected);

	if nameText then
		button.name:SetText(nameText);
		button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);

		-- [[ WIDE LIST: stretch the name fontstring into the extra horizontal room ]]
		-- The native name region has a fixed template width (it truncates with "..."), so
		-- widening the frame alone is not enough; the fontstring needs its own extra width
		-- to actually reveal long names + full "aka" suffixes. Capture the Blizzard width
		-- once, then grow or restore it to match the current setting.
		if not button.fgOrigNameWidth then
			local nw = button.name:GetWidth()
			if nw and nw > 0 then button.fgOrigNameWidth = nw end
		end
		if button.fgOrigNameWidth then
			if FriendGroups_IsWideList() then
				button.name:SetWidth(button.fgOrigNameWidth + FriendGroups_WideListExtra)
			else
				button.name:SetWidth(button.fgOrigNameWidth)
			end
		end

		if FriendGroups_SavedVars.show_note ~= false and type(button.fgNote) == "string" and button.fgNote ~= "" then
			-- Show the note field (includes any FG group/guild tags). The nickname tag is
			-- stripped: the row already renders the nickname as this friend's name, so
			-- leaving @[...] here would print it twice.
			local fgNoteClean = FriendGroups_NoteForDisplay(button.fgNote)
			if fgNoteClean and fgNoteClean ~= "" then
				infoText = (infoText and infoText ~= "") and (infoText .. "  " .. fgNoteClean) or fgNoteClean
			end
		end
		button.info:SetText(infoText);
		button:Show();
		-- Show/hide only -- FriendGroups_ApplyRowLayout seats the star as a fixed badge
		-- on the status slot (anchoring it after the name text let long names push it
		-- off the row).
		if isFavoriteFriend then
			button.Favorite:Show();
		else
			button.Favorite:Hide();
		end

		FriendGroups_ApplyRowLayout(button);
	else
		button:Hide();
	end
	
	if (FriendsTooltip.button == button) or (button:IsMouseMotionFocus()) then button:OnEnter() end

	if hasTravelPassButton and isCrossFactionInvite and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE) then
		local helpTipInfo = {
			text = CROSS_FACTION_INVITE_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
		};
		local crossFactionHelpTipInfo = helpTipInfo;
		local crossFactionHelpTipButton = button;
		HelpTip:Show(FriendsFrame, helpTipInfo, button.travelPassButton);
	end
	
	if hasTravelPassButton then
		-- Show the friend's faction crest on the invite button for BOTH same- and
		-- cross-faction friends (Blizzard only crests cross-faction; we crest either).
		if inviteFaction == "Horde" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-horde-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-horde-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-horde-disabled");
		elseif inviteFaction == "Alliance" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-alliance-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-alliance-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-alliance-disabled");
		else
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-default-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-default-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-default-disabled");
		end
	end

    if not button.fgAltTooltipHooked then
        button:HookScript("OnEnter", function(self)
            FriendGroups_ShowButtonAltTooltip(self)
        end)
        button:HookScript("OnLeave", function(self)
            if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
            FriendGroups_CurrentHoverAnchor = nil
        end)
        button.fgAltTooltipHooked = true
    end

	return nil;
end

local FriendGroups_UpdateQueued = false
local FriendGroups_UpdateTimer = nil
local FriendGroups_LastDataProvider = nil
local FriendGroups_LayoutPool = {}

local function FG_GetLayoutTable()
    local t = table.remove(FriendGroups_LayoutPool) or {}
    wipe(t)
    return t
end
local function FG_ReleaseLayoutTable(t)
    if type(t) == "table" then
        wipe(t)
        table.insert(FriendGroups_LayoutPool, t)
    end
end

-- Global entry point so the separate Sync module can trigger a full rebuild
-- (FriendGroups_FriendsListUpdate itself is a file-local upvalue).
function FriendGroups_RequestFullUpdate()
    -- Invalidate cached group assignments so imported mains/guilds/order recompute.
    if FriendGroups_AssignmentCache then wipe(FriendGroups_AssignmentCache) end
    if FriendGroups_FriendsListUpdate then
        FriendGroups_FriendsListUpdate(true)
    end
    -- Force the visible list to redraw now, so an import applies without needing a scroll.
    if FriendsListFrame and FriendsListFrame.ScrollBox then
        local sb = FriendsListFrame.ScrollBox
        if sb.FullUpdate then
            sb:FullUpdate(true)
        elseif sb.Update then
            sb:Update()
        end
    end
end

function FriendGroups_FriendsListUpdate(forceUpdate)
    -- GUARD: Only run if Enabled and Visible
    if not FriendGroups_Loaded then return end

    if InCombatLockdown() then
        FriendGroups_UpdateQueued = true
        return
    end

    -- Visibility guard routed through Compat: on 12.1 FriendsListFrame still exists but is
    -- permanently hidden, so testing it directly would block every update on that client.
    if (not Compat.IsContactListShown() and not forceUpdate) then return end

    -- Default to forcing an update if called from internal menus, clicks, or settings
    if forceUpdate == nil then forceUpdate = true end

    local socialUI = Compat.IsSocialUIActive()

    -- [[ MASSIVE OPTIMIZATION: IDLE GC CHURN PREVENTER ]]
    -- The shortcut below is only valid once there is something on screen to keep. On the
    -- Social UI path that means a grouped provider must already have been installed: the
    -- FIRST build can be deferred (opening the list in combat queues it to
    -- PLAYER_REGEN_ENABLED, which arrives with a clean roster), and taking the shortcut
    -- then would leave Blizzard's ungrouped provider in place with nothing to re-assert.
    local rosterUnchanged = (not forceUpdate) and (not FriendGroups_RosterDirty)
    if socialUI and not Compat.HasSocialUIProvider() then
        rosterUnchanged = false
    end

    if rosterUnchanged then
        -- Social UI: the rows are Blizzard's own cards, which refresh themselves from their
        -- own events, and the grouped provider is already installed -- nothing of ours to
        -- repaint in place. The legacy per-button pass below would walk a hidden frame.
        if socialUI then return end
        -- The roster structure hasn't changed. Just refresh the visible buttons (AFK timers, etc.)
        if FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox.ForEachFrame then
            FriendsListFrame.ScrollBox:ForEachFrame(function(frame)
                local elementData = frame:GetElementData()
                if elementData and (elementData.buttonType == FRIENDS_BUTTON_TYPE_BNET or elementData.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
                    FriendGroups_FriendsListUpdateFriendButton(frame, elementData)
                end
            end)
        elseif Compat.RefreshClassicVisible then
            -- MoP Classic: no ScrollBox -- re-render the visible HybridScroll rows in place.
            Compat.RefreshClassicVisible()
        end
        return
    end

    -- Clear the flag now that we are running a full validated rebuild
    FriendGroups_RosterDirty = false

    -- [[ CACHE PRUNE SUPPORT: advance the generation for this full rebuild. ]]
    -- Every currently-present friend gets re-stamped via FriendGroups_SetGroups below; entries
    -- left on an older generation belong to removed friends and are pruned at the end.
    FriendGroups_CacheGeneration = FriendGroups_CacheGeneration + 1

    local hideGroups = FriendGroups_SavedVars.hide_empty_groups or (searchValue ~= "")

    -- Release memory for previous tables
    for _, groupData in pairs(groupsTotal) do
        for _, playerData in ipairs(groupData) do FG_ReleaseTable(playerData) end
        FG_ReleaseTable(groupData)
    end
    for _, countData in pairs(groupsCount) do FG_ReleaseTable(countData) end
    for _, groupSet in pairs(FriendGroups_OnlineByGroup) do FG_ReleaseTable(groupSet) end
    wipe(groupsTotal)
    wipe(groupsCount)
    wipe(groupsSorted)

    -- Unique online counter: recounted from scratch on every rebuild. Safe to reset here
    -- because BN_FRIEND_INFO_CHANGED flags the roster dirty, so every online/offline
    -- transition forces a full pass rather than the fast visible-row refresh above.
    wipe(FriendGroups_OnlineByGroup)
    wipe(FriendGroups_OnlineKeys)
    wipe(FriendGroups_OnlineGuidKeys)
    FriendGroups_OnlineTotal = 0

    -- Ask Blizzard which friends match the search term BY NAME, before the pass that tests
    -- every friend. Once per rebuild: FriendGroups_Search then reads the answer per friend.
    FriendGroups_RebuildNameMatchSet()

    -- Parse natively in a single linear pass & pass refs down
    local numBNetTotal = C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
    for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo then
            -- This loop is the one guaranteed COMPLETE enumeration of Battle.net
            -- friends, so it is where the nickname cache is refreshed from the notes.
            -- Must run BEFORE FriendGroups_SetGroups, which reads the cache to build
            -- this friend's hasNickname flag and sort key.
            FriendGroups_ReconcileNickname(accountInfo)
            FriendGroups_SetGroups(i, FRIENDS_BUTTON_TYPE_BNET, accountInfo)
        end
    end

    local numWoWTotal = C_FriendList.GetNumFriends()
    for i = 1, numWoWTotal do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info then
            FriendGroups_SetGroups(i, FRIENDS_BUTTON_TYPE_WOW, info)
        end
    end

    -- Phase 1: establish the automatic hierarchy order, then record each group's auto index.
    table.sort(groupsSorted, FriendGroups_SortGroupsCustom)
    wipe(FriendGroups_AutoPos)
    for i = 1, #groupsSorted do
        FriendGroups_AutoPos[groupsSorted[i]] = i
    end

    -- Phase 2: apply any manual rank overrides on top of the automatic order.
    table.sort(groupsSorted, FriendGroups_SortGroupsByRank)

    -- Record the movable-group sequence (everything except the fixed system anchors) so the
    -- header chevrons and right-click menu can resolve neighbours and boundary state. Only
    -- groups that are actually SHOWN are included: with "hide empty groups" on, the hidden
    -- empties are skipped, so a move steps over them instead of silently swapping against a
    -- group that isn't on screen.
    wipe(FriendGroups_MovableOrder)
    wipe(FriendGroups_MovableIndex)
    for i = 1, #groupsSorted do
        local gName = groupsSorted[i]
        local shown = (not hideGroups) or (groupsTotal[gName] and #groupsTotal[gName] > 0)
        if shown and not FriendGroups_IsFixedAnchor(gName) then
            FriendGroups_MovableOrder[#FriendGroups_MovableOrder + 1] = gName
            FriendGroups_MovableIndex[gName] = #FriendGroups_MovableOrder
        end
    end

    local targetLayout = FG_GetTable()
    
    local numInvites = C_BattleNet.GetFriendNumInvites and C_BattleNet.GetFriendNumInvites() or BNGetNumFriendInvites()
    if (numInvites > 0) and not GetCVarBool("friendInvitesCollapsed") then
        for i = 1, numInvites do
            local inv = FG_GetLayoutTable()
            inv.id = i
            inv.buttonType = FRIENDS_BUTTON_TYPE_INVITE
            table.insert(targetLayout, inv)
        end
    end

    for _, groupName in ipairs(groupsSorted) do
        if (not hideGroups or (hideGroups and #groupsTotal[groupName] > 0)) then
            -- First sight of a group seeds its collapse state. Offline buckets start
            -- COLLAPSED: with exclusive filing the catch-all holds every absent contact,
            -- which on a typical roster is most of it, and opening the list onto a wall of
            -- people who are not there buries the ones who are. Every other group starts
            -- open, as before. Seeded rather than forced, so the value is written once and
            -- the user's own toggle owns it from then on.
            if FriendGroups_SavedVars.collapsed[groupName] == nil then
                FriendGroups_SavedVars.collapsed[groupName] = FriendGroups_IsOfflineGroup(groupName) and true or false
            end

            local div = FG_GetLayoutTable()
            div.buttonType = FRIENDS_BUTTON_TYPE_DIVIDER
            div.groupName = groupName
            table.insert(targetLayout, div)

            -- Social UI: collapse is a property of the tree node, not of the layout, so
            -- members are ALWAYS emitted there and the renderer seeds each header node's
            -- collapsed state from the same saved variable. Withholding them here would
            -- leave Blizzard's own collapse chevron toggling an empty subtree.
            if socialUI or not FriendGroups_SavedVars.collapsed[groupName] then
                table.sort(groupsTotal[groupName], FriendGroups_SortTableByStatus)
                for _, playerData in ipairs(groupsTotal[groupName]) do
                    if playerData.buttonType and playerData.id then
                        local p = FG_GetLayoutTable()
                        p.id = playerData.id
                        p.buttonType = playerData.buttonType
                        table.insert(targetLayout, p)
                    end
                end
            end
        end
    end

    if #targetLayout == 0 then
        local empty = FG_GetLayoutTable()
        empty.buttonType = FRIENDS_BUTTON_TYPE_DIVIDER
        empty.groupName = L["GROUP_EMPTY"]
        table.insert(targetLayout, empty)
    end

    if socialUI then
        -- Retail 12.1 path: the reachable contact list is SocialUIFrame.FriendsList, whose
        -- ScrollBox is driven by a TreeDataProvider. Checked BEFORE HAS_SCROLLBOX because
        -- that capability is still true on 12.1 -- the legacy FriendsListFrame and its
        -- ScrollBox both still exist, they are simply no longer reachable by the player.
        Compat.RenderSocialUIList(targetLayout)
        for _, element in ipairs(targetLayout) do FG_ReleaseLayoutTable(element) end
    elseif not Compat.HAS_SCROLLBOX then
        -- MoP Classic path: drive the native HybridScrollFrame directly from the
        -- freshly built layout, then return the pooled elements.
        Compat.RenderClassicList(targetLayout)
        for _, element in ipairs(targetLayout) do FG_ReleaseLayoutTable(element) end
    else
    local dataProvider = FriendsListFrame.ScrollBox:GetDataProvider()
    -- In post-hook mode Blizzard's native update owns the ScrollBox for a moment before we
    -- re-assert; treat its flat provider as "no provider" so we never diff against it and
    -- never recycle its element tables into our layout pool.
    if dataProvider and FriendGroups_ActiveProvider and dataProvider ~= FriendGroups_ActiveProvider then
        dataProvider = nil
    end
    if not dataProvider then
        dataProvider = CreateDataProvider()
        for _, elem in ipairs(targetLayout) do dataProvider:Insert(elem) end
        FriendGroups_ActiveProvider = dataProvider
        FriendsListFrame.ScrollBox:SetDataProvider(dataProvider, true)
    else
        local currentElements = FG_GetTable()
        for index, element in dataProvider:EnumerateEntireRange() do
            table.insert(currentElements, element)
        end
        
        local needsRebuild = false
        if #currentElements ~= #targetLayout then
            needsRebuild = true
        else
            for i = 1, #targetLayout do
                local cur = currentElements[i]
                local tar = targetLayout[i]
                if cur.buttonType ~= tar.buttonType or cur.id ~= tar.id or cur.groupName ~= tar.groupName then
                    needsRebuild = true
                    break
                end
            end
        end

        if needsRebuild then
            local savedScrollPercentage = FriendsListFrame.ScrollBox:GetScrollPercentage() or 0

            for _, element in ipairs(currentElements) do
                FG_ReleaseLayoutTable(element)
            end

            -- [[ O(n) REBUILD: populate a DETACHED provider, then swap it in a single time. ]]
            -- A provider that is not yet attached to the ScrollBox has no registered listeners,
            -- so per-element Insert triggers no layout/OnSizeChanged work. SetDataProvider then
            -- performs exactly one layout pass, instead of one pass per inserted element.
            local rebuiltProvider = CreateDataProvider()
            for _, elem in ipairs(targetLayout) do
                rebuiltProvider:Insert(elem)
            end
            FriendGroups_ActiveProvider = rebuiltProvider
            FriendsListFrame.ScrollBox:SetDataProvider(rebuiltProvider, true)

            if ScrollBoxConstants and ScrollBoxConstants.NoScrollInterpolation then
                FriendsListFrame.ScrollBox:SetScrollPercentage(savedScrollPercentage, ScrollBoxConstants.NoScrollInterpolation)
            else
                FriendsListFrame.ScrollBox:SetScrollPercentage(savedScrollPercentage)
            end
        else
            for _, element in ipairs(targetLayout) do
                FG_ReleaseLayoutTable(element)
            end

            if FriendsListFrame.ScrollBox.ForEachFrame then
                FriendsListFrame.ScrollBox:ForEachFrame(function(frame)
                    local elementData = frame:GetElementData()
                    if elementData and (elementData.buttonType == FRIENDS_BUTTON_TYPE_BNET or elementData.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
                        FriendGroups_FriendsListUpdateFriendButton(frame, elementData)
                    end
                end)
            end
        end
        
        FG_ReleaseTable(currentElements)
    end
    end

    FG_ReleaseTable(targetLayout)

    for groupName, _ in pairs(FriendGroups_SavedVars.collapsed) do
        if not groupsTotal[groupName] then
            FriendGroups_SavedVars.collapsed[groupName] = nil
        end
    end

    -- [[ CACHE PRUNE: drop assignment-cache entries for friends no longer present. ]]
    -- Setting an existing key to nil during pairs() traversal is safe in Lua (only adding new
    -- keys mid-traversal is not). This runs only on full rebuilds, after every present friend
    -- has been re-stamped with the current generation above.
    for cacheKey, entry in pairs(FriendGroups_AssignmentCache) do
        if entry.generation ~= FriendGroups_CacheGeneration then
            FriendGroups_AssignmentCache[cacheKey] = nil
        end
    end
    
    FriendGroups_UpdateContactCap() 
end

function FriendGroups_FilterTable(tableData, filterFunction)
	local returnTable = {}

	for key, value in pairs(tableData) do
		if filterFunction(value, key, tableData) then table.insert(returnTable, value) end
	end

	return returnTable
end

-- Resolve a friend's realm to its database entry (icon/region/classic tag). This is
-- the single realm-resolution path: region-scoped table pick, API realmName lookup,
-- then rich-presence parse. Shared by the realm-flags feature (GetRealmInfo below)
-- and the game-icon flavor tint (Compat.ResolveFriendFlavor), so both always agree.
function FriendGroups_GetRealmEntry(gameAccountInfo)
    if not gameAccountInfo then return nil end

    -- Secure String Verification up front
    local rawRealm = gameAccountInfo.realmName
    local safeRealm = (type(rawRealm) == "string") and rawRealm or ""

    local richPresence = gameAccountInfo.richPresence
    local safePresence = (type(richPresence) == "string") and richPresence or ""

    -- 1. Determine Region Database using API RegionID
    local database = FriendGroups_GetRealmDatabase(gameAccountInfo.regionID)

    -- 2. Standard Realm Lookup (Spaces & Punctuation stripped to match our normalized DB)
    if safeRealm ~= "" then
        local cleanRealm = safeRealm:gsub("[%s%p]+", "")
        local data = database[cleanRealm]

        if data then
            return data
        end
    end

    -- 3. Fallback: Parse Rich Presence for Classic or Hidden Realms
    if safePresence ~= "" then
        -- First try extracting the realm placed after the hyphen (standard API format)
        local extraction = safePresence:match("%s%-%s(.+)$")

        -- If no hyphen, use the full string (e.g. they are just logged into "Nightslayer" char screen)
        local cleanEx = (extraction or safePresence):gsub("[%s%p]+", "")

        local data = database[cleanEx]
        if data then
            return data
        end
    end

    return nil
end

function FriendGroups_GetRealmInfo(gameAccountInfo)
    local data = FriendGroups_GetRealmEntry(gameAccountInfo)
    if data then
        return "Interface\\AddOns\\FriendGroups\\Textures\\" .. data.icon, data.region
    end
    return nil, nil
end

-- Safe renderer for element types FriendGroups does not manage (they can only appear
-- while Blizzard's native flat provider transiently occupies the ScrollBox in post-hook
-- mode). Clears every recycled divider region so no stale group header shows through.
function FriendGroups_FriendsListUpdateInertTemplate(frame, elementData)
    frame.rawGroupName = nil
    if frame.name then frame.name:Hide() end
    if frame.info then frame.info:Hide() end
    if frame.collapseButton then frame.collapseButton:Hide() end
end

function FriendGroups_FriendsListUpdateDividerTemplate(frame, elementData)
    local groupName = elementData.groupName
    local groupOnline = groupsCount[groupName] and groupsCount[groupName]["Online"] or 0
    -- Denominator = raw group size (all members, unfiltered), not the filtered count.
    local groupTotal = groupsCount[groupName] and (groupsCount[groupName]["Raw"] or groupsCount[groupName]["Total"]) or 0

    if groupName and frame.name then
        frame.rawGroupName = groupName -- Store raw name for click handlers
        
        -- Cleanup any old search/settings items if they exist on this recycled frame
        if _G["FriendGroupsSearch"] and _G["FriendGroupsSearch"]:GetParent() == frame then
             _G["FriendGroupsSearch"]:Hide()
        end
        local settingsBtn = _G["FriendGroupsSettingsBtn"]
        if settingsBtn and settingsBtn:GetParent() == frame then 
            settingsBtn:Hide() 
        end
        
        -- Standard Header Setup
        frame.name:Show()
        
        local displayGroupName = groupName
        if groupName == L["GROUP_GUILDMATES"] and FriendGroups_PlayerGuildName and FriendGroups_PlayerGuildName ~= "" then
            displayGroupName = string.format(L["FORMAT_GUILD_TAG"], groupName, FriendGroups_PlayerGuildName)
        end
        frame.name:SetText(displayGroupName)

        -- [[ HEADER LABEL COLOUR, INCLUDING THE WAY BACK ]]
        -- An explicit override wins; a banner colour implies white, because the default is
        -- close to unreadable against a saturated strip. HeaderFontRGB returns nil for
        -- neither -- and nil has to mean "put it back", not "leave it alone".
        --
        -- Leaving it alone is what it used to mean, and clearing a banner colour therefore
        -- left the label white forever: this fontstring is on a POOLED frame, so "whatever
        -- the template drew" is only true the first time it is used. After one pass over a
        -- banner-tinted group it holds white, and skipping the call preserves that.
        --
        -- The default is CAPTURED rather than assumed, on the first pass over each frame --
        -- which is necessarily before any write of ours, since the capture sits above it. So
        -- the label returns to precisely the colour Blizzard's own template gave it, on any
        -- client, with no constant here to drift out of step with theirs.
        --
        -- Blizzard's own label never shows this bug because its template re-applies a font
        -- object on every recycle and a font object carries its colour. Ours has no template
        -- to recover from, so it must be written on every pass -- the same reasoning
        -- FG_ApplyHeaderCount records for the count fontstring beside it.
        if not frame.fgDefaultNameColor then
            local defR, defG, defB, defA = frame.name:GetTextColor()
            frame.fgDefaultNameColor = { defR or 1, defG or 0.82, defB or 0, defA or 1 }
        end

        local fontR, fontG, fontB = FriendGroups_HeaderFontRGB(groupName)
        if fontR then
            frame.name:SetTextColor(fontR, fontG, fontB)
        else
            local default = frame.fgDefaultNameColor
            frame.name:SetTextColor(default[1], default[2], default[3], default[4])
        end

        -- Left-align the group title to the same column where friend names begin
        -- (class-icon gutter factored in), instead of the template's centered width.
        frame.name:SetJustifyH("LEFT")
        frame.name:ClearAllPoints()
        -- LEFT, not TOPLEFT: paired with the RIGHT anchor below, both points now put the
        -- string's centre on the header's centre, so the label is centred in the banner at
        -- whatever height the header is. TOPLEFT here was also over-constraining the vertical
        -- axis against that RIGHT anchor -- top AND centre both pinned -- which is the kind of
        -- thing that resolves differently on a fontstring than on a frame.
        frame.name:SetPoint("LEFT", frame, "LEFT", fgRowNameGutter, 0)
        -- Extend to nearly the full usable width, reserving room only for the
        -- right-aligned online/total count. (Anchoring to frame.info is wrong:
        -- its fontstring box is ~226px wide, which squeezed the title to ellipses.)
        frame.name:SetPoint("RIGHT", frame, "RIGHT", -58, 0)

        frame.collapseButton:Show()
        if frame.info then frame.info:Show() end

        if groupName ~= L["GROUP_EMPTY"] then
            local groupInfo = string.format("%d/%d", groupOnline, groupTotal)
            
            -- [[ NEW: Hide the "0/" for Offline Virtual Groups ]]
            if FriendGroups_IsOfflineGroup(groupName) then
                groupInfo = tostring(groupTotal)
            end
            
            if frame.info then frame.info:SetText(groupInfo) end
            
            if FriendGroups_SavedVars.collapsed[groupName] then
                frame.collapseButton:SetNormalAtlas("Campaign_HeaderIcon_Closed")
            else
                frame.collapseButton:SetNormalAtlas("Campaign_HeaderIcon_Open")
            end
        else
            frame.collapseButton:Hide()
            if frame.info then frame.info:SetText("") end
        end

        frame:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
        frame:GetHighlightTexture():SetAlpha(0.2)

        if not frame.solidBannerTexture then
            frame.solidBannerTexture = frame:CreateTexture(nil, "BACKGROUND")
            frame.solidBannerTexture:SetAllPoints(frame)
        end

        if FriendGroups_SavedVars and FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName] then
            local hex = FriendGroups_SavedVars.banner_colors[groupName]
            local r = tonumber(string.sub(hex, 1, 2), 16) / 255
            local g = tonumber(string.sub(hex, 3, 4), 16) / 255
            local b = tonumber(string.sub(hex, 5, 6), 16) / 255
            frame.solidBannerTexture:SetColorTexture(r, g, b, 0.4)
            frame.solidBannerTexture:Show()
        else
            frame.solidBannerTexture:Hide()
        end

        if not frame.fgTooltipHooked then
            frame:HookScript("OnEnter", function(self)
                local hGroupName = self.rawGroupName or (self.name and self.name:GetText())
                if not hGroupName then return end
                
                local isGuildGroup = string.find(hGroupName, L["GROUP_GUILDMATES"], 1, true)
                local isSystemGroup = (hGroupName == L["GROUP_NONE"] or hGroupName == L["GROUP_FAVORITES"] or hGroupName == L["GROUP_EMPTY"] or hGroupName == "" or FriendGroups_IsOfflineGroup(hGroupName))

                -- Captured into locals, not called inline: a Lua call only expands to
                -- multiple values in the LAST argument position, so an inline
                -- FriendGroups_AccentRGB() anywhere before a trailing `true` would
                -- silently collapse to the red channel alone.
                local aR, aG, aB = FriendGroups_AccentRGB()

                if isGuildGroup then
                    local guildNameMatch = string.match(hGroupName, "<(.-)>")
                    if guildNameMatch then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(L["TOOLTIP_GUILD_GROUP_TITLE"], aR, aG, aB)
                        GameTooltip:AddLine(L["TOOLTIP_GUILD_GROUP_DESC_1"], 1, 1, 1, true)
                        GameTooltip:AddLine(string.format(L["TOOLTIP_GUILD_GROUP_DESC_2"], "<" .. guildNameMatch .. ">"), aR, aG, aB, true)
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine(L["TOOLTIP_GROUP_COLOR_PICKER_NOTE"], 0, 1, 0, true)
                        GameTooltip:Show()
                    end
                elseif not isSystemGroup then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L["TOOLTIP_CUSTOM_GROUP_TITLE"], aR, aG, aB)
                    GameTooltip:AddLine(string.format(L["TOOLTIP_CUSTOM_GROUP_DESC_1"], hGroupName), 1, 1, 1, true)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(L["TOOLTIP_GROUP_COLOR_PICKER_NOTE"], 0, 1, 0, true)
                    GameTooltip:Show()
                end
            end)
            frame:HookScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            frame.fgTooltipHooked = true
        end
    end
end

-- Banner colour a group's tooltip line is tinted with, matching the header banner the
-- user picked. Returns hasBanner=false for groups with no colour set, which fall back to
-- the default header gold and get no background strip.
local function FriendGroups_GetGroupBannerRGB(groupName)
    local hex = FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName]
    if type(hex) == "string" and #hex == 6 then
        local r = tonumber(string.sub(hex, 1, 2), 16)
        local g = tonumber(string.sub(hex, 3, 4), 16)
        local b = tonumber(string.sub(hex, 5, 6), 16)
        if r and g and b then
            return r / 255, g / 255, b / 255, true
        end
    end
    local r, g, b = FriendGroups_AccentRGB()
    return r, g, b, false
end

-- ============================================================================
-- [[ TOOLTIP GROUP BANNERS ]]
-- ============================================================================
-- GameTooltip has no per-line background, so the coloured strips behind the group rows
-- are pooled textures parented to it and anchored to each line's fontstring. They can
-- only be positioned after GameTooltip:Show() has laid the lines out, hence the two-pass
-- build in the OnEnter below. GameTooltip is shared with the rest of the UI, so every
-- strip is hidden again on OnHide or it would bleed through unrelated tooltips.
local FriendGroups_TooltipBanners = {}
local FriendGroups_TooltipBannerCount = 0
local FriendGroups_TooltipHeaderLine = nil
local FriendGroups_TooltipHeaderFont = nil

-- Undo everything we painted onto the shared tooltip: strips hidden, and the promoted
-- header line put back on the font it had. Without the font restore, the next tooltip to
-- reuse that recycled fontstring would render its line at header size. The original object
-- is captured rather than assumed to be GameTooltipText, so this restores correctly on
-- every flavour and even when another addon has restyled the tooltip's fonts.
local function FriendGroups_ResetTooltipStyling()
    for i = 1, FriendGroups_TooltipBannerCount do
        FriendGroups_TooltipBanners[i]:Hide()
    end
    FriendGroups_TooltipBannerCount = 0

    if FriendGroups_TooltipHeaderLine then
        if FriendGroups_TooltipHeaderFont then
            FriendGroups_TooltipHeaderLine:SetFontObject(FriendGroups_TooltipHeaderFont)
        end
        FriendGroups_TooltipHeaderLine = nil
        FriendGroups_TooltipHeaderFont = nil
    end
end

-- GameTooltip:SetText renders line 1 with GameTooltipHeaderText, but AddLine always uses
-- the smaller GameTooltipText. Promote a mid-tooltip line so a section header matches the
-- title's size.
-- SetFontObject also stamps that font object's own colour onto the line, throwing away
-- whatever AddLine was given, so the colour has to be re-applied afterwards or the header
-- silently reverts to the font's default white.
local function FriendGroups_PromoteTooltipHeaderLine(lineIndex, r, g, b)
    local line = _G["GameTooltipTextLeft" .. lineIndex]
    -- No header font on this client: leave the line at its normal size rather than error.
    if not line or not GameTooltipHeaderText then return end
    FriendGroups_TooltipHeaderFont = line:GetFontObject()
    line:SetFontObject(GameTooltipHeaderText)
    line:SetTextColor(r, g, b)
    FriendGroups_TooltipHeaderLine = line
end

local function FriendGroups_ShowTooltipBanner(lineIndex, r, g, b)
    local line = _G["GameTooltipTextLeft" .. lineIndex]
    if not line then return end

    FriendGroups_TooltipBannerCount = FriendGroups_TooltipBannerCount + 1
    local tex = FriendGroups_TooltipBanners[FriendGroups_TooltipBannerCount]
    if not tex then
        -- BORDER, not BACKGROUND: the tooltip's own backdrop occupies BACKGROUND, so a
        -- strip there would be fighting it for draw order. BORDER is above the backdrop
        -- and still below the ARTWORK-layer text.
        tex = GameTooltip:CreateTexture(nil, "BORDER")
        FriendGroups_TooltipBanners[FriendGroups_TooltipBannerCount] = tex
    end

    tex:ClearAllPoints()
    tex:SetPoint("LEFT", GameTooltip, "LEFT", 5, 0)
    tex:SetPoint("RIGHT", GameTooltip, "RIGHT", -5, 0)
    tex:SetPoint("TOP", line, "TOP", 0, 1)
    tex:SetPoint("BOTTOM", line, "BOTTOM", 0, -1)
    -- 0.4 alpha is the same tint the list's header banners use.
    tex:SetColorTexture(r, g, b, 0.4)
    tex:Show()
end

function FriendGroups_UpdateContactCap()
    if not FriendGroups_ContactText then return end

    -- Hardcoded server limits (as Blizzard API does not provide a query for maximums)
    local BNET_MAX_FRIENDS = 600
    local WOW_MAX_FRIENDS = 100

    -- Keep the counter sitting over the group headers' count column. Measured live so it
    -- follows whichever list backend is running and every width mode; skipped while the
    -- frames have no geometry, and only re-anchored when the column actually moves.
    local columnInset = FriendGroups_GetCountColumnInset()
    if columnInset and columnInset ~= FriendGroups_ContactTextInset then
        FriendGroups_ContactTextInset = columnInset
        FriendGroups_ContactText:ClearAllPoints()
        FriendGroups_ContactText:SetPoint("RIGHT", FriendsListFrame, "TOPRIGHT", -columnInset, FG_COUNT_COLUMN_Y)
    end

    -- Main text: unique online contacts. Gold to match the group totals it sits above and
    -- every other number in the UI. The cap warning lives in the tooltip now that this
    -- number no longer tracks the BNet limit.
    FriendGroups_ContactText:SetText(string.format(L["TEXT_ONLINE_COUNT"], FriendGroups_OnlineTotal))
    FriendGroups_ContactText:SetTextColor(FriendGroups_AccentRGB())

    FriendGroups_ContactText:Show()

    -- Lazy Load the invisible hover frame for the tooltip
    if not FriendGroups_ContactHoverFrame then
        FriendGroups_ContactHoverFrame = CreateFrame("Frame", "FriendGroupsContactHoverFrame", FriendsListFrame)
        FriendGroups_ContactHoverFrame:SetPoint("TOPLEFT", FriendGroups_ContactText, "TOPLEFT", 0, 0)
        FriendGroups_ContactHoverFrame:SetPoint("BOTTOMRIGHT", FriendGroups_ContactText, "BOTTOMRIGHT", 0, 0)

        -- Published as a global so both contact-list platforms raise the SAME tooltip. The
        -- legacy hover frame below is one caller; on 12.1 the counter lives on the Social
        -- UI's filter bar and calls this directly. Everything it reads -- groupsSorted,
        -- FriendGroups_OnlineByGroup, the guild name, the tooltip styling helpers -- is a
        -- file-local here, which is why it cannot simply be rebuilt on the other side.
        -- GameTooltip is shared with the entire game, so the minimum width set below has to
        -- be given back or every item and spell tooltip shown afterwards inherits it. Reset
        -- on OnHide rather than in our own OnLeave handlers: there are two callers already
        -- (the legacy hover frame and the Social UI counter) and a third would silently
        -- forget. Installed here, inside the one-time hover-frame construction.
        GameTooltip:HookScript("OnHide", function(tooltip)
            tooltip:SetMinimumWidth(0)
        end)

        FriendGroups_ShowContactTooltip = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetMinimumWidth(FG_CONTACT_TOOLTIP_MIN_WIDTH)

            -- House accent for this whole tooltip. Captured into locals because a Lua
            -- call only expands to multiple values in the LAST argument position, so an
            -- inline call before a trailing `true` would collapse to the red channel.
            local aR, aG, aB = FriendGroups_AccentRGB()

            -- [[ TOTAL ONLINE FRIENDS ]]
            -- Colour scheme for this whole tooltip, kept deliberately narrow: every header,
            -- row label and number is gold; only explanatory prose is white; and red is
            -- reserved for the at-cap warning so it still means something.
            GameTooltip:SetText(L["TOOLTIP_ONLINE_TITLE"], aR, aG, aB)
            -- Unwrapped: a single short sentence in every locale (the longest, frFR, is 66
            -- characters). Left to wrap it broke for one trailing word, which reads as a
            -- mistake rather than as a paragraph.
            GameTooltip:AddLine(L["TOOLTIP_ONLINE_FILTER_NOTE"], 1, 1, 1, false)
            GameTooltip:AddLine(" ")

            -- Pass 1: emit the rows and remember which line each banner belongs to. Group
            -- order mirrors the list on screen. Groups with nobody online are skipped,
            -- which also drops the offline-tracker groups for free.
            FriendGroups_ResetTooltipStyling()
            local pendingBanners = nil
            local shownGroups = 0
            for _, groupName in ipairs(groupsSorted) do
                local groupSet = FriendGroups_OnlineByGroup[groupName]
                local count = 0
                if groupSet then
                    for _ in pairs(groupSet) do count = count + 1 end
                end
                if count > 0 then
                    local displayGroupName = groupName
                    if groupName == L["GROUP_GUILDMATES"] and FriendGroups_PlayerGuildName and FriendGroups_PlayerGuildName ~= "" then
                        displayGroupName = string.format(L["FORMAT_GUILD_TAG"], groupName, FriendGroups_PlayerGuildName)
                    end
                    -- Gold name and count on a tinted strip, exactly like the list's
                    -- headers: the custom colour drives the background only.
                    local r, g, b, hasBanner = FriendGroups_GetGroupBannerRGB(groupName)
                    GameTooltip:AddDoubleLine(displayGroupName, string.format(L["TEXT_ONLINE_COUNT"], count), aR, aG, aB, aR, aG, aB)
                    if hasBanner then
                        pendingBanners = pendingBanners or {}
                        pendingBanners[#pendingBanners + 1] = { line = GameTooltip:NumLines(), r = r, g = g, b = b }
                    end
                    shownGroups = shownGroups + 1
                end
            end

            if shownGroups == 0 then
                GameTooltip:AddLine(L["TOOLTIP_ONLINE_NONE"], 1, 1, 1)
            else
                -- Sum row: sits directly under the groups it totals, so the breakdown
                -- reads as arithmetic. The note explains why the parts can exceed it.
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine(L["TOOLTIP_ONLINE_TOTAL_ROW"], string.format(L["TEXT_ONLINE_COUNT"], FriendGroups_OnlineTotal), aR, aG, aB, aR, aG, aB)
                GameTooltip:AddLine(L["TOOLTIP_ONLINE_UNIQUE_NOTE"], 1, 1, 1, true)
            end

            GameTooltip:AddLine(" ")

            -- [[ CONTACT LIMITS ]]
            GameTooltip:AddLine(L["TOOLTIP_CONTACT_TITLE"], aR, aG, aB)
            FriendGroups_PromoteTooltipHeaderLine(GameTooltip:NumLines(), aR, aG, aB)
            -- Unwrapped because this string carries its OWN break: every locale writes it as
            -- two sentences separated by \n, one per limit. Wrapping on top of an authored
            -- break turned two lines into four, each with a single word stranded on the
            -- second. If a translation ever outgrows the tooltip, the fix is another \n in
            -- the locale file, not re-enabling the wrap.
            GameTooltip:AddLine(L["TOOLTIP_CONTACT_DESC"], 1, 1, 1, false)
            GameTooltip:AddLine(" ")

            -- Dynamic values inside tooltip
            local bTotal = C_BattleNet and C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends() or 0
            local bInvites = C_BattleNet and C_BattleNet.GetFriendNumInvites and C_BattleNet.GetFriendNumInvites() or BNGetNumFriendInvites() or 0
            local wTotal = C_FriendList.GetNumFriends() or 0

            -- Pending invites hold a slot, so they count toward the cap.
            local bnetConsumed = bTotal + bInvites
            local atCap = (bnetConsumed >= BNET_MAX_FRIENDS)
            -- Values are gold like every other number here; the cap is the one case that
            -- overrides to red, which is the whole point of reserving the colour.
            local capR, capG, capB = aR, aG, aB
            if atCap then capR, capG, capB = 1, 0, 0 end

            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_BNET"], string.format(L["FORMAT_COUNT_OF_MAX"], bTotal, BNET_MAX_FRIENDS), aR, aG, aB, capR, capG, capB)
            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_INVITES"], string.format(L["FORMAT_NUMBER"], bInvites), aR, aG, aB, aR, aG, aB)
            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_WOW"], string.format(L["FORMAT_COUNT_OF_MAX"], wTotal, WOW_MAX_FRIENDS), aR, aG, aB, aR, aG, aB)
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_TOTAL"], string.format(L["FORMAT_NUMBER"], bTotal + wTotal), aR, aG, aB, aR, aG, aB)

            if atCap then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["TOOLTIP_CONTACT_AT_CAP"], 1, 0, 0, true)
            end

            GameTooltip:Show()

            -- Pass 2: Show() has now sized the tooltip and laid out its fontstrings, so the
            -- banner strips can be anchored to the rows they belong to.
            if pendingBanners then
                for i = 1, #pendingBanners do
                    local banner = pendingBanners[i]
                    FriendGroups_ShowTooltipBanner(banner.line, banner.r, banner.g, banner.b)
                end
            end
        end

        FriendGroups_ContactHoverFrame:SetScript("OnEnter", FriendGroups_ShowContactTooltip)

        FriendGroups_ContactHoverFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        -- GameTooltip is shared UI: undo our strips and font change whenever it closes, so
        -- neither can bleed into somebody else's tooltip.
        GameTooltip:HookScript("OnHide", FriendGroups_ResetTooltipStyling)
    end
end

function FriendGroups_FrameFriendDividerTemplateCollapseClick(self, button, down)
    -- FIX: Determine if 'self' is the Header (has .name) or the Button (needs .GetParent)
    local frame = self
    if not frame.name then
        frame = self:GetParent()
    end

    -- Safety check: If we still can't find the name, stop to prevent crash
    if not frame or not frame.name then return end

    local groupName = frame.rawGroupName or frame.name:GetText()
    
    if groupName then
        -- Toggle the collapsed state
        if FriendGroups_SavedVars.collapsed[groupName] then
            FriendGroups_SavedVars.collapsed[groupName] = false
        else
            FriendGroups_SavedVars.collapsed[groupName] = true
        end
        
        -- Handle "Open only one group" setting
        if FriendGroups_SavedVars.open_one_group and not FriendGroups_SavedVars.collapsed[groupName] then
            for key, _ in pairs(FriendGroups_SavedVars.collapsed) do
                if key ~= groupName then
                    FriendGroups_SavedVars.collapsed[key] = true
                end
            end
        end
        
        -- Refresh the list
        FriendGroups_FriendsListUpdate()
    end
end

FriendGroups_FriendsListButtonTemplateClick = function(self, button, down)
    if not FriendGroups_Loaded then return end 
    
    FriendGroupsFrame.selectionLocked = false
    
    C_Timer.After(0.05, function()
        FriendGroups_FriendsListUpdate()
    end)
end

function FriendGroups_FriendsFrameUpdateFriendInviteHeaderButton(button, elementData)
    local numInvites = C_BattleNet.GetFriendNumInvites and C_BattleNet.GetFriendNumInvites() or BNGetNumFriendInvites()
	button:SetFormattedText(FRIEND_REQUESTS, numInvites);
	local collapsed = GetCVarBool("friendInvitesCollapsed");
	if (collapsed) then
		button.DownArrow:Hide();
		button.RightArrow:Show();
	else
		button.DownArrow:Show();
		button.RightArrow:Hide();
	end
end

function FriendGroups_FriendsFrameUpdateFriendInviteButton(button, elementData)
	local id = elementData.id;
	button.buttonType = elementData.buttonType;
	button.id = id;

    local inviteID, accountName
    if C_BattleNet and C_BattleNet.GetFriendInviteInfo then
        local inviteInfo = C_BattleNet.GetFriendInviteInfo(id)
        if inviteInfo then
            inviteID = inviteInfo.inviteID
            accountName = inviteInfo.accountName
        end
    else
        inviteID, accountName = BNGetFriendInviteInfo(id)
    end

	button.Name:SetText(accountName);
	button.inviteID = inviteID;
	button.inviteIndex = button.id;
end

-- ============================================================================
-- [[ FRIENDGROUPS SECURE HOUSING PROXY ]]
-- ============================================================================
local FG_Osirisnz_HousingProxy = nil
local FG_Osirisnz_HookedButtons = {}

local function Osirisnz_ActuallyWorkingVisitHouse()
    if FG_Osirisnz_HousingProxy then return FG_Osirisnz_HousingProxy end
    if InCombatLockdown() then return nil end 

    -- CRITICAL: Uses SecureActionButtonTemplate AND SecureHandlerStateTemplate
    FG_Osirisnz_HousingProxy = CreateFrame("Button", "FriendGroups_Osirisnz_SecureHouseProxy", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate")
    FG_Osirisnz_HousingProxy:SetFrameStrata("DIALOG")
    FG_Osirisnz_HousingProxy:SetFrameLevel(9999)
    FG_Osirisnz_HousingProxy:Hide()
    FG_Osirisnz_HousingProxy:RegisterForClicks("AnyUp", "AnyDown")
    FG_Osirisnz_HousingProxy:SetAttribute("type", "visithouse")

    -- Securely hide on combat start without causing Lua taint
    RegisterStateDriver(FG_Osirisnz_HousingProxy, "combatstate", "[combat] combat; nocombat")
    FG_Osirisnz_HousingProxy:SetAttribute("_onstate-combatstate", [[
        if newstate == "combat" then
            self:Hide()
            self:ClearAllPoints()
        end
    ]])

    FG_Osirisnz_HousingProxy:SetScript("OnEnter", function(self)
        if self.nativeButton then
            self.nativeButton:LockHighlight()
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(HOUSING_VISIT_HOUSE or L["TOOLTIP_VISIT_HOUSE"], 1, 1, 1)
        GameTooltip:Show()
    end)

    FG_Osirisnz_HousingProxy:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:Hide()
        self:ClearAllPoints()
        if self.nativeButton then
            self.nativeButton:UnlockHighlight()
        end
        self.nativeButton = nil
    end)
    
    FG_Osirisnz_HousingProxy:SetScript("OnMouseDown", function(self)
        if self.nativeButton then self.nativeButton:SetButtonState("PUSHED") end
    end)
    
    FG_Osirisnz_HousingProxy:SetScript("OnMouseUp", function(self)
        if self.nativeButton then self.nativeButton:SetButtonState("NORMAL") end
    end)

    return FG_Osirisnz_HousingProxy
end

local function Osirisnz_OnHouseButtonEnter(nativeButton)
    if InCombatLockdown() then return end 

    local parentRow = nativeButton:GetParent()
    local houseInfo = parentRow and parentRow.houseInfo
    
    if not houseInfo or not houseInfo.neighborhoodGUID or not houseInfo.houseGUID then return end

    local proxy = Osirisnz_ActuallyWorkingVisitHouse()
    if not proxy then return end

    proxy:ClearAllPoints()
    proxy:SetAllPoints(nativeButton)

    proxy:SetAttribute("house-neighborhood-guid", houseInfo.neighborhoodGUID)
    proxy:SetAttribute("house-guid", houseInfo.houseGUID)
    proxy:SetAttribute("house-plot-id", houseInfo.plotID)

    proxy.nativeButton = nativeButton
    
    proxy:Show()
    if proxy:GetScript("OnEnter") then
        proxy:GetScript("OnEnter")(proxy)
    end
end

local function Osirisnz_InitHousingScrollBox()
    local houseFrame = _G.HouseListFrame
    if not houseFrame or not houseFrame.ScrollBox then return end

    houseFrame.ScrollBox:RegisterCallback("OnInitializedFrame", function(_, frame)
        local btn = frame.VisitHouseButton
        if btn and not FG_Osirisnz_HookedButtons[btn] then
            btn:HookScript("OnEnter", Osirisnz_OnHouseButtonEnter)
            FG_Osirisnz_HookedButtons[btn] = true
        end
    end)
end

-- ============================================================================
-- [[ MAIN INITIALIZATION ]]
-- ============================================================================
local frame = CreateFrame("frame", "FriendGroups")
Compat.RegisterEvents(frame, {
    "PLAYER_LOGIN",
    "PLAYER_ENTERING_WORLD",
    "ZONE_CHANGED_NEW_AREA",
    "ADDON_LOADED",
})

frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Intentionally silent on load (no login chat message)

    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if not FriendGroups_SavedVars then return end
        
        local myBattleTag = nil
        if C_BattleNet and C_BattleNet.GetAccountInfoByGUID then
            local accInfo = C_BattleNet.GetAccountInfoByGUID(UnitGUID("player"))
            if accInfo then myBattleTag = accInfo.battleTag end
        end
        FriendGroups_SavedVars.MyBattleTag = myBattleTag
        
    elseif event == "PLAYER_LOGIN" then
        if not FriendGroups_SavedVars then
            FriendGroups_SavedVars = {
                collapsed = {},
                hide_offline = false,
                colour_classes = true,
                show_class_icons = true,
                show_note = true,
                show_status = true,
                show_faction_icons = true,
                show_faction_color = true,
                show_game_icon = true,
                show_realm = true,
                hide_high_level = true, 
                add_favorite_group = true, 
                add_mobile_text = true, 
                show_search = true, 
                open_one_group = false,
                auto_accept_invite = false,
                auto_accept_sync = false,
                offline_tracker = true,
                streamer_mode = false,
                show_guildmates = true
            }
        end
        
        if FriendGroups_SavedVars.show_guildmates == nil then FriendGroups_SavedVars.show_guildmates = true end
        -- 12.2.2: the legacy list-refresh fallback was removed after the alpha; clear
        -- the orphaned saved variable so no tester stays silently on the old mode.
        FriendGroups_SavedVars.legacy_list_update = nil
        
        -- [[ MASTER WIPE WHEN TRACKING IS DISABLED ]]
        -- When alt tracking is enabled we intentionally retain every cached character
        -- indefinitely (no time-based expiry) so the known-alt history grows as complete
        -- as possible. Data only leaves the cache via the recent-10 cap, the manual purge
        -- button, or disabling tracking (the wipe below).
        if FriendGroups_SavedVars.show_known_alts == false then
            if FriendGroups_SavedVars.alt_cache then wipe(FriendGroups_SavedVars.alt_cache) end
            if FriendGroups_SavedVars.guid_index then wipe(FriendGroups_SavedVars.guid_index) end
        end

        EnableFriendGroups()

        -- 12.2.2 TAINT FIX: never write FriendsFrame.selectedFriend/-Type from addon code
        -- (insecure writes taint fields Blizzard's secure handlers read). selectionLocked
        -- alone now provides the "selection cleared on open/close" visual behaviour.
        FriendsFrame:HookScript("OnHide", function()
            FriendGroupsFrame.selectionLocked = true
        end)
        FriendsFrame:HookScript("OnShow", function()
            FriendGroupsFrame.selectionLocked = true
            FriendGroups_FriendsListUpdate(true)
        end)
        
        if C_AddOns.IsAddOnLoaded("Blizzard_HouseList") then Osirisnz_InitHousingScrollBox() end
        if C_AddOns.IsAddOnLoaded("Blizzard_Communities") then FriendGroups_InitCommunitiesHook() end

    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_HouseList" then
        Osirisnz_InitHousingScrollBox()
    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_Communities" then
        FriendGroups_InitCommunitiesHook()
    end
end)

-- ============================================================================
-- [[ AUTOMATION LOGIC ]]
-- Moved to Automation.lua, which fronts the interactive automations with the
-- countdown toast and arbitrates ownership with GLogger when both are running.
-- ============================================================================


-- ============================================================================
-- [[ KNOWN ALTS SPYGLASS ENGINE & STATIC PANEL ]]
-- ============================================================================

FriendGroups_SaveToAltCache = function(accountIdentifier, gameInfo)
    if FriendGroups_SavedVars and FriendGroups_SavedVars.show_known_alts == false then return end
    if not accountIdentifier or not gameInfo then return end
    if not gameInfo.isOnline or gameInfo.clientProgram ~= BNET_CLIENT_WOW then return end

    -- [[ FRESH-INSTALL GUARD ]]
    -- SetGroups can reach this writer during the very first list build, before the
    -- background tracker (BN_FRIEND_INFO_CHANGED) has lazily created alt_cache. Mirror
    -- the tracker's own guard so the table always exists before it is indexed below,
    -- preventing a nil-index on a fresh install with no saved cache yet.
    if not FriendGroups_SavedVars then return end
    if type(FriendGroups_SavedVars.alt_cache) ~= "table" then
        FriendGroups_SavedVars.alt_cache = {}
    end
    
    local charName = (type(gameInfo.characterName) == "string") and gameInfo.characterName or ""
    if charName == "" then return end
    
    local rawRealm = gameInfo.realmName
    if not rawRealm or rawRealm == "" then rawRealm = gameInfo.realmDisplayName end
    if (not rawRealm or rawRealm == "") and type(gameInfo.richPresence) == "string" then
        local extraction = gameInfo.richPresence:match("%s%-%s(.+)")
        if extraction then rawRealm = extraction end
    end
    if not rawRealm or rawRealm == "" then return end

    local displayRealm = (type(rawRealm) == "string") and rawRealm or ""
    local normalizedRealm = FriendGroups_CleanRealmName(displayRealm) 
    local uniqueKey = charName .. "-" .. normalizedRealm
    
    local class = (type(gameInfo.className) == "string") and gameInfo.className or ""
    local faction = (type(gameInfo.factionName) == "string") and gameInfo.factionName or ""
    local zone = (type(gameInfo.areaName) == "string") and gameInfo.areaName or L["UNKNOWN"]
    local level = tonumber(gameInfo.characterLevel) or 1
    local project = gameInfo.wowProjectID or WOW_PROJECT_MAINLINE

    local detectedGuild = nil
    if FriendGroups_LiveGuildSessionDict[uniqueKey] or FriendGroups_LiveGuildSessionDict[charName] then
        detectedGuild = FriendGroups_PlayerGuildName
    end
    
    if type(FriendGroups_SavedVars.alt_cache[accountIdentifier]) ~= "table" then
        FriendGroups_SavedVars.alt_cache[accountIdentifier] = {}
    end
    
    local altList = FriendGroups_SavedVars.alt_cache[accountIdentifier]
    local existingIndex = nil
    
    for i = 1, #altList do
        local existingRealm = altList[i].realm or ""
        local existingNorm = FriendGroups_CleanRealmName(existingRealm)
        local existingMigratedKey = altList[i].charName .. "-" .. existingNorm

        if altList[i].key == uniqueKey or existingMigratedKey == uniqueKey or altList[i].key == (charName .. "-") then
            existingIndex = i
            break
        end
    end
    
    if existingIndex then
        local existingAlt = altList[existingIndex]
        local dataChanged = false
        
        if existingAlt.level ~= level then existingAlt.level = level; dataChanged = true end
        if existingAlt.zone ~= zone then existingAlt.zone = zone; dataChanged = true end
        -- Never overwrite a known class with an empty one: on Classic the live API
        -- returns no class for retail-only classes (DH/Evoker), and clobbering here
        -- would destroy the real class imported from retail via Sync.
        if class ~= "" and existingAlt.class ~= class then existingAlt.class = class; dataChanged = true end
        if existingAlt.faction ~= faction then existingAlt.faction = faction; dataChanged = true end
        if existingAlt.realm ~= displayRealm then existingAlt.realm = displayRealm; dataChanged = true end
        if existingAlt.project ~= project then existingAlt.project = project; dataChanged = true end
        
        -- Pre-calculate and store search strings to prevent GC search stutter
        existingAlt.searchName = charName:lower()
        existingAlt.searchRealm = displayRealm:lower()
        existingAlt.searchClass = class:lower()
        existingAlt.searchZone = zone:lower()

        -- STRICT PRESERVATION: Only update if a valid guild was detected. Never overwrite with nil.
        if detectedGuild and existingAlt.guild ~= detectedGuild then 
            existingAlt.guild = detectedGuild; dataChanged = true 
        end
        
        if dataChanged then
            existingAlt.timestamp = time()
        end
    else
        table.insert(altList, 1, {
            key = uniqueKey,
            charName = charName,
            realm = displayRealm, 
            level = level,
            class = class,
            faction = faction,
            zone = zone,
            guild = detectedGuild,
            project = project,
            timestamp = time(),
            -- Pre-calculate and store search strings
            searchName = charName:lower(),
            searchRealm = displayRealm:lower(),
            searchClass = class:lower(),
            searchZone = zone:lower()
        })
        
        -- [[ RECENT-10 CAP (MAIN-PROTECTED) ]]
        -- Keep at most 10 cached characters. A manually-selected main counts as one of the
        -- 10 but must never be evicted, so drop the oldest NON-main entry (the list is
        -- newest-first) until the cap is met. The 'removed' guard prevents an infinite loop
        -- in the impossible case that no removable entry remains.
        while #altList > 10 do
            local removed = false
            for i = #altList, 1, -1 do
                if not FriendGroups_IsManualMain(accountIdentifier, altList[i]) then
                    table.remove(altList, i)
                    removed = true
                    break
                end
            end
            if not removed then break end
        end
    end
end

-- 2. The Silent Tracker (Catches background changes)
local FriendGroups_BNetIndexMap = {}

local function FriendGroups_UpdateBNetIndexMap()
    wipe(FriendGroups_BNetIndexMap)
    local numBNetTotal = C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
    for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo and accountInfo.bnetAccountID then
            FriendGroups_BNetIndexMap[accountInfo.bnetAccountID] = i
        end
    end
end

-- ============================================================================
-- [[ SECURE BACKGROUND TRACKER (STALE-SEAT PROTECTED) ]]
-- ============================================================================
local FriendGroups_AltTracker = CreateFrame("Frame")
FriendGroups_AltTracker:RegisterEvent("BN_FRIEND_INFO_CHANGED")
FriendGroups_AltTracker:SetScript("OnEvent", function(self, event, ...)
    -- [[ COMBAT CHURN GUARD ]]
    -- Skip background alt-caching while in combat. BN_FRIEND_INFO_CHANGED fires continuously in
    -- populated content; performing API lookups + SavedVars writes per event during combat is
    -- wasted work. No data is lost: the alt cache is rebuilt for every BNet friend on the next
    -- full list rebuild (FriendGroups_SetGroups -> FriendGroups_SaveToAltCache).
    if InCombatLockdown() then return end

    if not FriendGroups_SavedVars then return end
    if FriendGroups_SavedVars.show_known_alts == false then return end
    if type(FriendGroups_SavedVars.alt_cache) ~= "table" then FriendGroups_SavedVars.alt_cache = {} end

    local arg1 = ... 
    if not arg1 then return end
    
    -- Secure API Lookup by strict ID guarantees we never pull the wrong person's data
    local accountInfo = C_BattleNet.GetAccountInfoByID(arg1)
    if not accountInfo then 
        accountInfo = C_BattleNet.GetFriendAccountInfo(arg1) -- Legacy fallback just in case
    end
    if not accountInfo then return end
    
    local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
    if not accountIdentifier then return end

    -- Secure Path: Save only the verified primary game account attached to this strict ID.
    -- Multibox alts are safely handled synchronously during the UI rebuild, bypassing stale seat errors.
    if accountInfo.gameAccountInfo then
        FriendGroups_SaveToAltCache(accountIdentifier, accountInfo.gameAccountInfo)
    end
end)

-- 3. The Static Side-Panel Injector
-- FIX: Changed parent to UIParent and forced FrameStrata so it is impossible to hide behind the Guild window
local FriendGroupsAltTooltip = CreateFrame("GameTooltip", "FriendGroupsAltTooltip", UIParent, "GameTooltipTemplate")
FriendGroupsAltTooltip:SetFrameStrata("TOOLTIP")
FriendGroupsAltTooltip:SetFrameLevel(9999)

local FriendGroups_CurrentHoverCharKey = nil
local FriendGroups_CurrentHoverBNetID = nil
local FriendGroups_CurrentHoverAnchor = nil
-- Note for the currently hovered account, so tooltip refreshes/redraws (which
-- call DrawAltTooltip without a note) keep showing it instead of flickering off.
local FriendGroups_CurrentHoverNote = nil

-- Published because these are FILE-LOCALS and a Platform_* file assigning the name directly
-- would silently create a global instead, leaving the real hover state set forever.
--
-- Clearing matters more on 12.1 than it ever did before. The GameTooltip Show hook below
-- skips FriendsFrame, so on the legacy list a stale anchor was harmless; on 12.1 the anchor
-- is SocialUIFrame, which is NOT skipped, so an uncleared hover re-anchors every unrelated
-- tooltip in the game -- spells, items, units -- for the rest of the session.
addonTable.State.ClearHoverAnchor = function()
    FriendGroups_CurrentHoverAnchor = nil
    FriendGroups_CurrentHoverBNetID = nil
    FriendGroups_CurrentHoverCharKey = nil
    FriendGroups_CurrentHoverNote = nil
end

-- Raw BNet note (verbatim) for an account identifier (battleTag / accountName), so
-- the guild + communities alt tooltip shows the SAME note as the contact-list one.
-- accountIdentifier matches what the hover handlers store (the alt_cache key).
local function FriendGroups_GetNoteByAccount(accountIdentifier)
    if type(accountIdentifier) ~= "string" then return nil end
    local num = (C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum())
        or (BNGetNumFriends and BNGetNumFriends()) or 0
    for i = 1, num do
        local info = C_BattleNet.GetFriendAccountInfo(i)
        if info and (info.battleTag == accountIdentifier or info.accountName == accountIdentifier) then
            if type(info.note) == "string" and info.note ~= "" then return strtrim(info.note) end
            return nil
        end
    end
    return nil
end

-- Reverse lookup to instantly find your own private BNet friends in the Guild Roster
local function FriendGroups_FindBNetIDByCharKey(charKey)
    if not FriendGroups_SavedVars.alt_cache then return nil end
    for bnetID, alts in pairs(FriendGroups_SavedVars.alt_cache) do
        for _, alt in ipairs(alts) do
            if alt.key == charKey then
                return bnetID
            end
        end
    end
    return nil
end

local function FriendGroups_DrawAltTooltip(anchorFrame, accountIdentifier, charKey, baselineData, noteText)
    -- House accent for this panel. Captured into locals because a Lua call only
    -- expands to multiple values in the LAST argument position -- an inline call before
    -- a trailing `true` would collapse to the red channel alone.
    local aR, aG, aB = FriendGroups_AccentRGB()

    if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then
        FriendGroupsAltTooltip:Hide()
        return
    end

    -- Contextual UI Title Logic
    local hoverName = L["UNKNOWN"]
    if baselineData and baselineData.charName then
        hoverName = baselineData.charName
    elseif charKey then
        hoverName = strsplit("-", charKey)
    end
    
    -- [[ MASTER MERGE DICTIONARY ]]
    local masterDict = {}

    local function MergeIntoMaster(alt)
        if not alt or not alt.charName or not alt.realm then return end
        
        -- Force a universal, lowercase key to prevent case-sensitive splits
        local renderKey = string.lower(alt.charName .. "-" .. alt.realm:gsub("[%s%p]+", ""))
        
        if not masterDict[renderKey] then
            masterDict[renderKey] = {
                key = renderKey, charName = alt.charName, realm = alt.realm,
                class = alt.class, faction = alt.faction, level = alt.level,
                zone = alt.zone, guild = alt.guild, timestamp = alt.timestamp
            }
        else
            local existing = masterDict[renderKey]
            
            -- ALWAYS preserve a valid guild tag
            if alt.guild and alt.guild ~= "NONE" and alt.guild ~= "-" and alt.guild ~= "" then
                if not existing.guild or existing.guild == "NONE" or existing.guild == "-" or existing.guild == "" then
                    existing.guild = alt.guild
                end
            end

            -- Normal Timestamp Election for dynamic stats (Level, Zone)
            if (alt.timestamp or 0) > (existing.timestamp or 0) then
                existing.level = alt.level
                existing.zone = alt.zone
                existing.faction = alt.faction
                existing.timestamp = alt.timestamp
            end
        end
    end

    -- 1. PULL FROM LOCAL BNET CACHE
    if accountIdentifier and FriendGroups_SavedVars.alt_cache and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
        for _, alt in ipairs(FriendGroups_SavedVars.alt_cache[accountIdentifier]) do 
            MergeIntoMaster(alt) 
        end
    end

    -- 2. PULL FROM LIVE BASELINE DATA
    if baselineData then
        MergeIntoMaster(baselineData)
    end

    -- Flatten the merged dictionary back into a renderable array
    local alts = {}
    for _, alt in pairs(masterDict) do
        table.insert(alts, alt)
    end

    if #alts > 0 then
        -- SMART FALLBACK FIX: Heal missing name from cache
        if hoverName == L["UNKNOWN"] then
            local renderCharKey = string.lower(charKey or "")
            local foundHover = masterDict[renderCharKey]
            if foundHover and foundHover.charName and foundHover.charName ~= "" then
                hoverName = foundHover.charName
            elseif alts[1] and alts[1].charName and alts[1].charName ~= "" then
                hoverName = alts[1].charName
            end
        end

        -- Masked at the point of formatting, never at the point of resolution: hoverName is
        -- still the real name above (it keys the merge dictionary lookup), and every
        -- comparison in this panel continues to run against real values.
        local titleName = FriendGroups_IsStreamerMode() and FriendGroups_MaskName(hoverName) or hoverName

        local displayTitle = string.format(L["TOOLTIP_ALTS_PUBLIC_TITLE_FORMAT"], titleName)
        if #alts >= 10 and L["TOOLTIP_ALTS_TITLE_FORMAT_MAX"] then
            displayTitle = string.format(L["TOOLTIP_ALTS_TITLE_FORMAT_MAX"], titleName)
        end

        FriendGroupsAltTooltip:SetOwner(anchorFrame, "ANCHOR_NONE")

        if anchorFrame == FriendsFrame then
            FriendGroupsAltTooltip:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 2, 0)
        elseif CommunitiesFrame and CommunitiesFrame:IsShown() then
            FriendGroupsAltTooltip:SetPoint("TOPLEFT", CommunitiesFrame, "TOPRIGHT", 2, 0)
        else
            FriendGroupsAltTooltip:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 2, 0)
        end

        -- Secure Font Reset: Prevent recycled tooltip lines from staying permanently shrunk
        for i = 1, 99 do
            local line = _G["FriendGroupsAltTooltipTextLeft" .. i]
            if not line then break end
            
            local fontObj = (i == 1) and GameTooltipHeaderText or GameTooltipText
            if fontObj then
                -- Re-assign the FontObject natively. This clears any manual 6px SetFont overrides
                -- and fully restores the Blizzard font fallback chain for Cyrillic/Asian characters.
                line:SetFontObject(fontObj)
            end
        end

		FriendGroupsAltTooltip:ClearLines()
        FriendGroupsAltTooltip:AddLine(displayTitle, aR, aG, aB)

        -- ====================================================================
        -- [[ IDENTITY BLOCK ]]
        -- Fixed order, broadest identifier first: BattleTag (the account), nickname
        -- (what you call them), guild (auto before manual), then custom groups.
        -- Every line carries a localized prefix, and the note's raw DSL -- @[...],
        -- <...>, #... -- is decoded rather than printed: the panel shows what the
        -- note MEANS, the note field itself shows the syntax.
        -- ====================================================================

        -- Fall back to the stashed hover note so timer refreshes and the native
        -- FriendsTooltip:Show redraw (both call us without a note) don't drop the block.
        --
        -- Normalised HERE rather than at the call sites. This function is reached from
        -- seven of them across three surfaces (friends list, guild roster, communities)
        -- and they do not agree on what they pass: the friends list hands over an
        -- already-cleaned note, while the guild and communities paths read the raw note
        -- straight from the account. Stripping per-caller meant the guild panel leaked
        -- the raw @[...] tag as free text while the friends panel did not. Doing it once
        -- at the point of use makes every surface an exact mirror by construction --
        -- FriendGroups_NoteForDisplay is idempotent and nil-safe, so the already-clean
        -- callers are unaffected and no future caller can reintroduce the divergence.
        local showNote = FriendGroups_NoteForDisplay(noteText or FriendGroups_CurrentHoverNote)

        local idOK = accountIdentifier
            and type(accountIdentifier) == "string"
            and not (issecretvalue and issecretvalue(accountIdentifier))

        -- 1. BATTLETAG, in the familiar BNet blue. accountIdentifier is the BattleTag
        -- (Name#1234) when one exists; the '#' test keeps legacy accountName values
        -- from rendering as a junk line.
        if idOK and accountIdentifier:find("#") then
            local btagColor = FRIENDS_BNET_NAME_COLOR or BATTLENET_FONT_COLOR or CreateColor(0.510, 0.773, 1.0)
            -- A BattleTag is the single most identifying string this panel carries, so it is
            -- masked like a name -- the discriminator is dropped by the masker along with
            -- the realm half, leaving three characters of the tag's name portion.
            local shownTag = FriendGroups_IsStreamerMode() and FriendGroups_MaskName(accountIdentifier) or accountIdentifier
            FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_BATTLETAG"], shownTag),
                btagColor.r, btagColor.g, btagColor.b)
        end

        -- 2. NICKNAME, in its friendly form. Green matches the list row.
        if idOK and FriendGroups_SavedVars.nicknames then
            local nick = FriendGroups_SavedVars.nicknames[accountIdentifier]
            if type(nick) == "string" and nick ~= "" then
                FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_NICKNAME"], nick), 0, 1, 0)
            end
        end

        -- 3/4. GUILDS. Manual guilds are the <Name> tags the user typed into the note.
        -- The auto guild is whichever guild group the friend actually resolved into that
        -- ISN'T one of those -- read back from the assignment cache rather than
        -- re-derived here, so this line can never disagree with the group the friend is
        -- really filed under (that resolution blends live roster state, the selected
        -- main's guild and the alt cache, and duplicating it would drift).
        local manualGuilds, manualSet = {}, {}
        for gname in string.gmatch(showNote, "<([^>]+)>") do
            gname = strtrim(gname)
            if gname ~= "" and not manualSet[gname] then
                manualSet[gname] = true
                manualGuilds[#manualGuilds + 1] = gname
            end
        end

        local autoGuilds = {}
        if idOK then
            -- allGroups, not groups: an offline contact has been filed exclusively into an
            -- offline bucket by now, and reading the filtered list would drop the guild line
            -- for exactly the people whose guild is hardest to remember.
            local cached = FriendGroups_AssignmentCache[FRIENDS_BUTTON_TYPE_BNET .. "_" .. accountIdentifier]
            local cachedGroups = cached and (cached.allGroups or cached.groups)
            if cachedGroups then
                for _, g in ipairs(cachedGroups) do
                    if string.find(g, L["GROUP_GUILDMATES"], 1, true) then
                        local gname = g:match("<(.-)>")
                        if gname and gname ~= "" and not manualSet[gname] then
                            autoGuilds[#autoGuilds + 1] = gname
                        end
                    end
                end
            end
        end

        if #autoGuilds > 0 then
            FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_GUILD_AUTO"],
                table.concat(autoGuilds, ", ")), aR, aG, aB)
        end
        if #manualGuilds > 0 then
            FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_GUILD_MANUAL"],
                table.concat(manualGuilds, ", ")), aR, aG, aB)
        end

        -- 5. CUSTOM GROUPS -- the #Tags in the note. Parsed from the note rather than the
        -- resolved list so the system groups (Favorites, No Group, the Offline tiers) and
        -- the guild groups already shown above are excluded without special-casing each.
        local noteGroups = FriendGroups_GetPlayerGroups(showNote)
        if noteGroups and #noteGroups > 0 then
            FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_GROUP"],
                table.concat(noteGroups, ", ")), aR, aG, aB)
        end

        -- Anything the user typed that ISN'T a token still belongs to them, so it is kept
        -- rather than silently dropped by the decode above. Unlabelled: it is free text,
        -- not a field.
        local residual = showNote:gsub("<[^>]*>", "")
        residual = residual:gsub("#.*$", "")
        residual = strtrim(residual)
        if residual ~= "" then
            FriendGroupsAltTooltip:AddLine(residual, aR, aG, aB, true)
        end
	
        local sortedAlts = {}
        for _, alt in ipairs(alts) do table.insert(sortedAlts, alt) end
        
        table.sort(sortedAlts, function(a, b)
            local aIsMain = false
            local bIsMain = false
            if FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains and accountIdentifier then
                local manualMainKey = FriendGroups_SavedVars.manual_mains[accountIdentifier]
                local aKey = a.charName .. "-" .. FriendGroups_CleanRealmName(a.realm or "")
                local bKey = b.charName .. "-" .. FriendGroups_CleanRealmName(b.realm or "")
                if aKey == manualMainKey or a.key == manualMainKey then aIsMain = true end
                if bKey == manualMainKey or b.key == manualMainKey then bIsMain = true end
            end
            if aIsMain and not bIsMain then return true end
            if bIsMain and not aIsMain then return false end

            local timeA = a.timestamp or 0
            local timeB = b.timestamp or 0
            if timeA == timeB then
                if a.level == b.level then return a.charName < b.charName end
                return a.level > b.level
            end
            return timeA > timeB
        end)

        local rowCount = 0
        for _, alt in ipairs(sortedAlts) do
            if rowCount >= 10 then break end
            rowCount = rowCount + 1

            -- Create a custom 50% height gap instead of a full line
            FriendGroupsAltTooltip:AddLine(" ")
            local gapLine = _G["FriendGroupsAltTooltipTextLeft" .. FriendGroupsAltTooltip:NumLines()]
            if gapLine then
                -- Safely swap to a smaller native FontObject. 
                -- Avoids explicit SetFont calls that poison global objects.
                gapLine:SetFontObject("SystemFont_Tiny")
            end

            local engClass = ""
            if alt.class and (LOCALIZED_CLASS_NAMES_MALE[alt.class] or RAID_CLASS_COLORS[alt.class]) then
                engClass = alt.class
            else
                for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if alt.class == v then engClass = k break end end
                if engClass == "" then for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if alt.class == v then engClass = k break end end end
            end

            local classIconStr = Compat.ClassIconMarkup(engClass, 16)
            
            local nameColor = FriendGroups_GetClassColorCode(engClass ~= "" and engClass or alt.class)
            -- The alt roster is the densest identity block in the addon -- one contact's
            -- whole character list, each with a realm. Masking drops the realm with the
            -- name, so an entry reads "Kiw***" rather than "Kiw***-Nobundo".
            local coloredName
            if FriendGroups_IsStreamerMode() then
                coloredName = nameColor .. FriendGroups_MaskName(alt.charName) .. "|r"
            else
                coloredName = nameColor .. alt.charName .. (alt.realm ~= "" and ("-" .. alt.realm) or "") .. "|r"
            end

            local factionPath = FriendGroups_GetFactionIcon(alt.faction)
            local factionIconStr = factionPath ~= "" and ("|T" .. factionPath .. ":16|t") or ""

            local diff = time() - (alt.timestamp or time())
            if diff < 0 then diff = 0 end

            local timeStr = ""
            if diff < 60 then timeStr = L["TIME_JUST_NOW"]
            elseif diff < 3600 then timeStr = string.format(L["TIME_MINUTES_AGO"], math.floor(diff / 60))
            elseif diff < 86400 then timeStr = string.format(L["TIME_HOURS_AGO"], math.floor(diff / 3600))
            else timeStr = string.format(L["TIME_DAYS_AGO"], math.floor(diff / 86400)) end

            local isCurrentMain = false
            if FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains and accountIdentifier then
                local manualMainKey = FriendGroups_SavedVars.manual_mains[accountIdentifier]
                local currentKey = alt.charName .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")
                if currentKey == manualMainKey or alt.key == manualMainKey then isCurrentMain = true end
            end

            local leaderFlagStr = isCurrentMain and "|TInterface\\AddOns\\FriendGroups\\Textures\\check.tga:16|t " or ""
            local line1 = leaderFlagStr .. string.format(L["TOOLTIP_ALTS_FORMAT"], classIconStr, coloredName, factionIconStr, alt.level)
            
            if alt.guild and alt.guild ~= "NONE" and alt.guild ~= "-" and alt.guild ~= "" then
                if L["TOOLTIP_ALTS_GUILD_SUFFIX"] then
                    line1 = line1 .. string.format(L["TOOLTIP_ALTS_GUILD_SUFFIX"], alt.guild)
                end
            end

            local line2 = string.format(L["TOOLTIP_ALTS_SEEN"], alt.zone, timeStr)

            FriendGroupsAltTooltip:AddLine(line1, 1, 1, 1, false)
            FriendGroupsAltTooltip:AddLine(line2, 0.6, 0.6, 0.6, false)
        end

        FriendGroupsAltTooltip:Show()

        -- [[ DOCK FIX ]] Pin the native hover tooltip beneath the alt panel (friends + guild).
        FriendGroups_DockNativeTooltipBelowPanel(anchorFrame)
    else
        FriendGroupsAltTooltip:Hide()
        -- Panel suppressed (e.g. a guildmate who is not a BNet friend): keep the native
        -- roster tooltip parked where the panel would be so it does not jump sides as you
        -- scroll. No-op for the friends list and when no native tooltip is on screen.
        FriendGroups_DockNativeTooltipBelowPanel(anchorFrame)
    end
end

function FriendGroups_RefreshAltTooltip()
    if FriendGroups_CurrentHoverAnchor then
        FriendGroups_DrawAltTooltip(FriendGroups_CurrentHoverAnchor, FriendGroups_CurrentHoverBNetID, FriendGroups_CurrentHoverCharKey)
    end
end

-- [[ NATIVE TOOLTIP DOCK / PARK ]]
-- Keeps the native hover tooltip pinned to the Known Alts panel's slot so it never
-- overlaps the panel and never jumps sides while scrolling a roster.
--   * Panel shown  -> dock the native tooltip directly beneath the panel (with a
--                     bottom-of-screen overflow flip to grow upward instead).
--   * Panel hidden -> on the guild / communities roster only, park the native tooltip
--                     where the panel WOULD be (just right of the roster). This covers
--                     guildmates who are not BNet friends, whose panel is suppressed:
--                     without this the tooltip snaps back to Blizzard's default anchor
--                     and flicks between left and right row-to-row as you scroll.
-- anchorFrame mirrors the value the panel was (or would be) drawn against:
--   FriendsFrame -> FriendsTooltip (dedicated frame, friends list)
--   anything else -> GameTooltip   (shared global, guild / communities roster)
function FriendGroups_DockNativeTooltipBelowPanel(anchorFrame)
    if not FriendGroups_Loaded then return end
    if FriendGroups_SavedVars.show_known_alts == false then return end

    local native = (anchorFrame == FriendsFrame) and FriendsTooltip or GameTooltip

    -- Never move a tooltip that is not currently on screen for this hover.
    if not (native and native:IsShown()) then return end

    -- [[ PANEL HIDDEN: PARK ON THE RIGHT ]]
    if not (FriendGroupsAltTooltip and FriendGroupsAltTooltip:IsShown()) then
        -- Only the guild / communities roster suppresses the panel; the friends list
        -- always renders one, so we never reposition the dedicated FriendsTooltip here.
        if anchorFrame ~= FriendsFrame then
            local target = (CommunitiesFrame and CommunitiesFrame:IsShown()) and CommunitiesFrame or anchorFrame
            if target then
                native:ClearAllPoints()
                native:SetPoint("TOPLEFT", target, "TOPRIGHT", 2, 0)
            end
        end
        return
    end

    -- [[ PANEL SHOWN: DOCK BENEATH IT ]]
    local GAP = 4

    -- If the panel's rect is not yet resolvable this frame, fall back to a plain
    -- dock-beneath (the overflow flip simply re-evaluates on the next hover).
    local panelBottom = FriendGroupsAltTooltip:GetBottom()
    if not panelBottom then
        native:ClearAllPoints()
        native:SetPoint("TOPLEFT", FriendGroupsAltTooltip, "BOTTOMLEFT", 0, -GAP)
        return
    end

    -- Convert to absolute screen pixels to test for bottom-of-screen overflow.
    local panelBottomPx  = panelBottom * FriendGroupsAltTooltip:GetEffectiveScale()
    local nativeHeightPx = native:GetHeight() * native:GetEffectiveScale()
    local gapPx          = GAP * native:GetEffectiveScale()

    native:ClearAllPoints()
    if (panelBottomPx - nativeHeightPx - gapPx) < 0 then
        -- Not enough room below; grow upward from the panel's top edge instead.
        native:SetPoint("BOTTOMLEFT", FriendGroupsAltTooltip, "TOPLEFT", 0, GAP)
    else
        native:SetPoint("TOPLEFT", FriendGroupsAltTooltip, "BOTTOMLEFT", 0, -GAP)
    end
end

-- [[ GUILD / COMMUNITIES DOCK ENFORCER ]]
-- The guild & communities roster uses the shared global GameTooltip, which Blizzard
-- (and decorators such as Raider.IO) re-anchor on every Show as their data resolves.
-- A one-shot reposition at hover time is overwritten by the next Show, so we re-apply
-- the dock AFTER every GameTooltip Show -- but only while a guild/community roster row
-- is actively hovered. FriendGroups_CurrentHoverAnchor is the roster row owner during a
-- guild hover and is never FriendsFrame, so the friends list (dedicated FriendsTooltip)
-- and all unrelated GameTooltips are excluded. SetPoint/ClearAllPoints do not trigger
-- Show, so this never recurses.
hooksecurefunc(GameTooltip, "Show", function(self)
    if not FriendGroups_Loaded then return end
    if FriendGroups_SavedVars.show_known_alts == false then return end

    local anchor = FriendGroups_CurrentHoverAnchor
    if not anchor or anchor == FriendsFrame then return end

    -- [[ STALE-HOVER GUARD ]]
    -- Relying on every hover path to clear the anchor is what broke this: one that did not
    -- (the 12.1 card's HideTooltip) left the dock applying to every tooltip in the game.
    -- The anchor is now re-validated against reality on each Show, so a missed clear can
    -- never again leak past the frame it belongs to.
    --
    -- Both tests matter. IsShown alone still docks after the pointer has moved to an action
    -- bar with the list left open; IsMouseOver alone still docks when the list is hidden but
    -- the pointer happens to sit where it used to be.
    if type(anchor.IsShown) ~= "function" or not anchor:IsShown() then return end
    if type(anchor.IsMouseOver) == "function" and not anchor:IsMouseOver() then return end

    -- Keep the roster's native tooltip anchored to the panel's slot whether the panel is
    -- shown (BNet friend -> dock beneath) or suppressed (plain guildmate -> park on the
    -- right). Re-applied after every Show because Blizzard / Raider.IO re-anchor the
    -- shared GameTooltip as their data resolves.
    FriendGroups_DockNativeTooltipBelowPanel(anchor)
end)

-- [[ DIRECT BUTTON HANDLER ]]
function FriendGroups_ShowButtonAltTooltip(button)
    if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then FriendGroupsAltTooltip:Hide() return end

    -- [[ STREAMER MODE ]] Blizzard's own hover panel is suppressed, and only Blizzard's. It
    -- prints the account name, character, realm and note in full, and is built by a local
    -- function that cannot be reached to mask.
    --
    -- The FriendGroups panel below carries on: every name in it goes through the masker, and
    -- it is the whole reason to hover a row. Stated here as well as in the Social UI card
    -- hook so the legacy list and Classic suppress the same thing -- this is the one function
    -- every contact-row hover reaches.
    if FriendGroups_IsStreamerMode() then
        if GameTooltip then GameTooltip:Hide() end
        if FriendsTooltip then FriendsTooltip:Hide() end
    end

    if not button or not button.id then return end

    -- The panel the alt tooltip parks against, and the value FriendGroups_DockNativeTooltip-
    -- BelowPanel reads to decide which native tooltip is in play. On 12.1 this resolves to
    -- SocialUIFrame, which is what makes that function select the shared GameTooltip (the
    -- one the new card draws into) instead of the legacy FriendsTooltip. Everywhere else it
    -- returns FriendsFrame, so the existing behaviour is unchanged.
    FriendGroups_CurrentHoverAnchor = Compat.GetContactListAnchor()
    FriendGroups_CurrentHoverBNetID = nil
    FriendGroups_CurrentHoverCharKey = nil

    local baselineData = nil

    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if not accountInfo then return end

        local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
        if not accountIdentifier then return end

        FriendGroups_SaveToAltCache(accountIdentifier, accountInfo.gameAccountInfo)
        
        -- [[ MULTIBOX FIX: Automatically harvest all secondary open wow clients natively ]]
        if C_BattleNet.GetFriendNumGameAccounts then
            local numAccounts = C_BattleNet.GetFriendNumGameAccounts(button.id)
            if numAccounts and numAccounts > 1 then
                for i = 1, numAccounts do
                    local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(button.id, i)
                    if gameAccountInfo then
                        FriendGroups_SaveToAltCache(accountIdentifier, gameAccountInfo)
                    end
                end
            end
        end

        FriendGroups_CurrentHoverBNetID = accountIdentifier

        if accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.characterName then
            local rawRealm = accountInfo.gameAccountInfo.realmName
            if not rawRealm or rawRealm == "" then rawRealm = accountInfo.gameAccountInfo.realmDisplayName end
            if rawRealm and rawRealm ~= "" then
                local cName = accountInfo.gameAccountInfo.characterName
                local rName = rawRealm:gsub("[%s%p]+", "")
                FriendGroups_CurrentHoverCharKey = cName .. "-" .. rName
                
                baselineData = {
                    charName = cName,
                    realm = rawRealm,
                    class = accountInfo.gameAccountInfo.className or "",
                    faction = accountInfo.gameAccountInfo.factionName or "",
                    level = tonumber(accountInfo.gameAccountInfo.characterLevel) or 1,
                    zone = accountInfo.gameAccountInfo.areaName or L["UNKNOWN_ZONE"],
                    timestamp = time()
                }
            end
        end

        local fgNoteClean = nil
        if type(accountInfo.note) == "string" and accountInfo.note ~= "" then
            -- Nickname tag stripped: the tooltip header already carries the nickname.
            fgNoteClean = FriendGroups_NoteForDisplay(accountInfo.note)
            if fgNoteClean == "" then fgNoteClean = nil end
        end
        FriendGroups_CurrentHoverNote = fgNoteClean
        FriendGroups_DrawAltTooltip(FriendGroups_CurrentHoverAnchor or FriendsFrame, FriendGroups_CurrentHoverBNetID, FriendGroups_CurrentHoverCharKey, baselineData, fgNoteClean)
    end
end

hooksecurefunc(FriendsTooltip, "Show", function(self)
    if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then FriendGroupsAltTooltip:Hide() return end

    local button = self.button
    if not button or not button.id then return end

    FriendGroups_CurrentHoverAnchor = FriendsFrame
    FriendGroups_CurrentHoverBNetID = nil
    FriendGroups_CurrentHoverCharKey = nil

    local baselineData = nil

    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if not accountInfo then return end

        local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
        if not accountIdentifier then return end

        FriendGroups_SaveToAltCache(accountIdentifier, accountInfo.gameAccountInfo)
        
        -- [[ MULTIBOX FIX: Mirror of above ]]
        if C_BattleNet.GetFriendNumGameAccounts then
            local numAccounts = C_BattleNet.GetFriendNumGameAccounts(button.id)
            if numAccounts and numAccounts > 1 then
                for i = 1, numAccounts do
                    local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(button.id, i)
                    if gameAccountInfo then
                        FriendGroups_SaveToAltCache(accountIdentifier, gameAccountInfo)
                    end
                end
            end
        end

        FriendGroups_CurrentHoverBNetID = accountIdentifier

        if accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.characterName then
            local rawRealm = accountInfo.gameAccountInfo.realmName
            if not rawRealm or rawRealm == "" then rawRealm = accountInfo.gameAccountInfo.realmDisplayName end
            if rawRealm and rawRealm ~= "" then
                local cName = accountInfo.gameAccountInfo.characterName
                local rName = rawRealm:gsub("[%s%p]+", "")
                FriendGroups_CurrentHoverCharKey = cName .. "-" .. rName
                
                baselineData = {
                    charName = cName,
                    realm = rawRealm,
                    class = accountInfo.gameAccountInfo.className or "",
                    faction = accountInfo.gameAccountInfo.factionName or "",
                    level = tonumber(accountInfo.gameAccountInfo.characterLevel) or 1,
                    zone = accountInfo.gameAccountInfo.areaName or L["UNKNOWN_ZONE"],
                    timestamp = time()
                }
            end
        end

        FriendGroups_DrawAltTooltip(FriendGroups_CurrentHoverAnchor or FriendsFrame, FriendGroups_CurrentHoverBNetID, FriendGroups_CurrentHoverCharKey, baselineData)
    end
end)

FriendsFrame:HookScript("OnHide", function()
    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
    FriendGroups_CurrentHoverAnchor = nil
end)

local function FriendGroups_OnGuildRosterEnter(owner, memberInfo)
    -- [[ SECRET-SAFE HELPER ]]
    -- Returns the value only when it is present AND is not a 12.0 protected "secret value".
    -- It never reads the contents of a secret (issecretvalue is the only gate that is allowed).
    local function FG_PlainOrNil(v)
        if v == nil then return nil end
        if issecretvalue and issecretvalue(v) then return nil end
        return v
    end

    FriendGroups_CurrentHoverAnchor = owner

    local guid = memberInfo.guid
    local guidReadable = (guid ~= nil) and not (issecretvalue and issecretvalue(guid))
    local nameSecret = (issecretvalue and issecretvalue(memberInfo.name)) and true or false

    -- ========================================================================
    -- [[ SECRET PATH ]]
    -- The roster name is a protected secret in this context. We must NOT read it
    -- (no :find, no concat, no strsplit). Resolve identity via the GUID index that
    -- was harvested during normal (non-secret) hovers, and render purely from cache.
    -- ========================================================================
    if nameSecret then
        if type(FriendGroups_SavedVars.secret_telemetry) ~= "table" then
            FriendGroups_SavedVars.secret_telemetry = { hits = 0, resolved = 0, unresolved = 0, guid_secret = 0 }
        end
        local tel = FriendGroups_SavedVars.secret_telemetry
        tel.hits = (tel.hits or 0) + 1
        if not guidReadable then tel.guid_secret = (tel.guid_secret or 0) + 1 end

        local resolved = nil
        if guidReadable and type(FriendGroups_SavedVars.guid_index) == "table" then
            resolved = FriendGroups_SavedVars.guid_index[guid]
        end

        if resolved then
            tel.resolved = (tel.resolved or 0) + 1
            FriendGroups_CurrentHoverBNetID = resolved.account
            FriendGroups_CurrentHoverCharKey = resolved.key
            -- Mirror the contact-list tooltip: show this account's note here too.
            FriendGroups_CurrentHoverNote = FriendGroups_GetNoteByAccount(resolved.account)

            local baselineData = {
                charName  = resolved.charName,
                realm     = resolved.realm,
                class     = resolved.class or "",
                faction   = resolved.faction or "",
                level     = tonumber(FG_PlainOrNil(memberInfo.level)) or resolved.level or 1,
                zone      = FG_PlainOrNil(memberInfo.zoneName) or FG_PlainOrNil(memberInfo.zone) or resolved.zone or L["UNKNOWN_ZONE"],
                guild     = FriendGroups_PlayerGuildName,
                timestamp = time()
            }
            FriendGroups_DrawAltTooltip(owner, resolved.account, resolved.key, baselineData)
        else
            tel.unresolved = (tel.unresolved or 0) + 1
            FriendGroups_CurrentHoverBNetID = nil
            FriendGroups_CurrentHoverCharKey = nil
            FriendGroups_DrawAltTooltip(owner, nil, nil, nil)
        end
        return
    end

    -- ========================================================================
    -- [[ NORMAL PATH ]] (original behaviour, unchanged, plus GUID-index harvest)
    -- ========================================================================
    local rawName = memberInfo.name
    if rawName == nil then return end

    local charKey = rawName
    local cName, rName = rawName, GetNormalizedRealmName()
    if not rawName:find("-") then 
        charKey = rawName .. "-" .. rName
    else 
        cName, rName = strsplit("-", rawName)
        rName = rName:gsub("[%s%p]+", "")
        charKey = cName .. "-" .. rName 
    end

    FriendGroups_CurrentHoverBNetID = FriendGroups_FindBNetIDByCharKey(charKey)
    FriendGroups_CurrentHoverCharKey = charKey
    -- Mirror the contact-list tooltip: show this account's note here too.
    FriendGroups_CurrentHoverNote = FriendGroups_GetNoteByAccount(FriendGroups_CurrentHoverBNetID)

    local className, classFilename = "", ""
    if memberInfo.classID then 
        className, classFilename = GetClassInfo(memberInfo.classID) 
    end

    -- [[ FACTION FIX: Hybrid Approach (Communities API -> Native GUID API) ]]
    local factionFallback = ""
    if type(memberInfo.faction) == "number" then
        if memberInfo.faction == 0 then 
            factionFallback = "Horde"
        elseif memberInfo.faction == 1 then 
            factionFallback = "Alliance" 
        end
    end
    
    -- Fallback to Native GUID check if Communities data is missing
    if factionFallback == "" and guidReadable then
        local _, _, _, englishRace = GetPlayerInfoByGUID(guid)
        if englishRace then
            if englishRace == "Human" or englishRace == "Dwarf" or englishRace == "NightElf" or englishRace == "Gnome" or englishRace == "Draenei" or englishRace == "Worgen" or englishRace == "LightforgedDraenei" or englishRace == "VoidElf" or englishRace == "DarkIronDwarf" or englishRace == "KulTiran" or englishRace == "Mechagnome" or englishRace == "EarthenAlliance" then
                factionFallback = "Alliance"
            elseif englishRace == "Orc" or englishRace == "Scourge" or englishRace == "Tauren" or englishRace == "Troll" or englishRace == "BloodElf" or englishRace == "Goblin" or englishRace == "Nightborne" or englishRace == "HighmountainTauren" or englishRace == "MagharOrc" or englishRace == "ZandalariTroll" or englishRace == "Vulpera" or englishRace == "EarthenHorde" then
                factionFallback = "Horde"
            end
            -- Note: Neutral races (Pandaren/Dracthyr) safely bypass this to avoid assumptions.
            -- If their faction cannot be derived here, your BNet/Mesh Alt Cache will securely resolve it.
        end
    end

    local baselineData = {
        charName = cName,
        realm = rName,
        class = classFilename or className or "",
        faction = factionFallback, 
        level = tonumber(memberInfo.level) or 1,
        zone = memberInfo.zoneName or memberInfo.zone or L["UNKNOWN_ZONE"],
        guild = FriendGroups_PlayerGuildName, -- [[ FIX: Supply local guild explicitly ]]
        timestamp = time()
    }

    -- [[ GUID-INDEX HARVEST ]]
    -- Store a plain snapshot keyed by the readable GUID so a future hover in a secret
    -- context can resolve this character without ever reading the protected name.
    -- Only stored when we resolved a BNet owner, since the alt tooltip is BNet-cache backed.
    if guidReadable and FriendGroups_CurrentHoverBNetID then
        if type(FriendGroups_SavedVars.guid_index) ~= "table" then
            FriendGroups_SavedVars.guid_index = {}
        end
        FriendGroups_SavedVars.guid_index[guid] = {
            account   = FriendGroups_CurrentHoverBNetID,
            key       = charKey,
            charName  = cName,
            realm     = rName,
            class     = baselineData.class,
            faction   = factionFallback,
            level     = baselineData.level,
            zone      = baselineData.zone,
            timestamp = time()
        }
    end

    -- [[ BNET-ONLY GATE ]]
    -- The Known Alt panel is meaningful only for guild members who are also one of your
    -- Battle.net friends, since that is the only identity we track alts for. For a plain
    -- guildmate (no resolved BNet owner) suppress the panel instead of rendering a lone
    -- single-character window. Routing through DrawAltTooltip with nils hides it cleanly,
    -- mirroring the secret-path unresolved branch above.
    if not FriendGroups_CurrentHoverBNetID then
        FriendGroups_DrawAltTooltip(owner, nil, nil, nil)
        return
    end

    FriendGroups_DrawAltTooltip(owner, FriendGroups_CurrentHoverBNetID, charKey, baselineData)
end

function FriendGroups_InitCommunitiesHook()
    -- 1. Hook Standard Communities / Guild Roster Frame (Retail API)
    if CommunitiesFrame and not CommunitiesFrame.FG_HideHooked then
        CommunitiesFrame:HookScript("OnHide", function()
            if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
            FriendGroups_CurrentHoverAnchor = nil
        end)
        
        -- [[ NEW: Secure localized Tooltip Hook for Communities Roster (Replaces Global GameTooltip Hook) ]]
        if CommunitiesFrame.MemberList and CommunitiesFrame.MemberList.ScrollBox then
            CommunitiesFrame.MemberList.ScrollBox:RegisterCallback("OnInitializedFrame", function(_, frame)
                if not frame.FG_RosterTooltipHooked then
                    frame:HookScript("OnEnter", function(self)
                        if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then return end
                        if type(self.GetMemberInfo) ~= "function" then return end
                        
                        local success, memberInfo = pcall(self.GetMemberInfo, self)
                        if success and memberInfo and memberInfo.name then
                            FriendGroups_OnGuildRosterEnter(self, memberInfo)
                        end
                    end)
                    
                    frame:HookScript("OnLeave", function(self)
                        if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
                        FriendGroups_CurrentHoverAnchor = nil
                    end)
                    
                    frame.FG_RosterTooltipHooked = true
                end
            end)
        end
        CommunitiesFrame.FG_HideHooked = true
    end

    -- 2. Hook Legacy/Standalone Guild UI (Fallback Support)
    if GuildRosterContainer and GuildRosterContainer.ScrollBox and not GuildRosterContainer.FG_Hooked then
        GuildRosterContainer.ScrollBox:RegisterCallback("OnInitializedFrame", function(_, frame)
            if not frame.FG_RosterTooltipHooked then
                frame:HookScript("OnEnter", function(self)
                    if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then return end
                    if type(self.GetMemberInfo) ~= "function" then return end
                    
                    local success, memberInfo = pcall(self.GetMemberInfo, self)
                    if success and memberInfo and memberInfo.name then
                        FriendGroups_OnGuildRosterEnter(self, memberInfo)
                    end
                end)
                
                frame:HookScript("OnLeave", function(self)
                    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
                    FriendGroups_CurrentHoverAnchor = nil
                end)
                
                frame.FG_RosterTooltipHooked = true
            end
        end)
        GuildRosterContainer.FG_Hooked = true
    end
end

-- ============================================================================
-- [[ DIAGNOSTIC & TELEMETRY ENGINE ]]
-- ============================================================================
SLASH_FRIENDGROUPSDEBUG1 = "/fg"
SlashCmdList["FRIENDGROUPSDEBUG"] = function(msg)
    local command = msg and msg:lower():match("^%s*(%w+)")
    
    if command == "debug" then
        -- 1. Measure Memory Churn (Strictly restricted to FriendGroups)
        UpdateAddOnMemoryUsage()
        local memUsageKB = GetAddOnMemoryUsage(addonName) or GetAddOnMemoryUsage("FriendGroups") or 0
        local memUsageMB = memUsageKB / 1024

        -- 2. Measure Database Bloat
        local privateCount = 0

        if FriendGroups_SavedVars then
            if type(FriendGroups_SavedVars.alt_cache) == "table" then
                for _, alts in pairs(FriendGroups_SavedVars.alt_cache) do
                    privateCount = privateCount + #alts
                end
            end
        end

        -- 3. Output Telemetry Safely
        DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_HEADER"])
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_MEM_USAGE"], memUsageMB))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_DB_SIZE"], privateCount))

        -- Favorite-star diagnostics: whether the retail atlas exists on this client
        -- (else the ReputationStar fallback is in use) and whether the API reports
        -- any favorite flags at all -- the two prerequisites for stars to render.
        local favAtlas = (C_Texture and C_Texture.GetAtlasInfo
            and C_Texture.GetAtlasInfo("friendslist-favorite") ~= nil) or false
        local favCount = 0
        -- Was `C_BattleNet.GetFriendNum ... or 0` with no BNGetNumFriends fallback, so
        -- this loop never ran and the favorite count always reported 0.
        local numB = Compat.GetBNetFriendNum()
        for i = 1, numB do
            local a = C_BattleNet.GetFriendAccountInfo(i)
            if a and a.isFavorite then favCount = favCount + 1 end
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_FAV_ATLAS"], tostring(favAtlas)))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_FAV_COUNT"], favCount))

        -- [[ SECRET-VALUE TELEMETRY ]] Reports the secret-name fallback activity recorded at hover time.
        local guidIndexCount = 0
        if type(FriendGroups_SavedVars.guid_index) == "table" then
            for _ in pairs(FriendGroups_SavedVars.guid_index) do
                guidIndexCount = guidIndexCount + 1
            end
        end

        local tel = (type(FriendGroups_SavedVars.secret_telemetry) == "table") and FriendGroups_SavedVars.secret_telemetry or nil

        DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_SECRET_HEADER"])
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_GUID_INDEX"], guidIndexCount))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_SECRET_HITS"], (tel and tel.hits) or 0))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_SECRET_RESOLVED"], (tel and tel.resolved) or 0))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_SECRET_UNRESOLVED"], (tel and tel.unresolved) or 0))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_SECRET_GUID"], (tel and tel.guid_secret) or 0))
    elseif command == "proj" then
        -- [[ FLAVOR REPORT ]] Dumps what the client reports for WoW friends (project,
        -- realm fields, rich presence) plus the flavor verdict the game-icon tint
        -- derives from them and WHICH ladder tier decided it, so a mis-tinted icon is
        -- diagnosable in one command. Optional filter: /fg proj <name fragment>
        local filter = msg:match("^%s*%w+%s+(%S+)")
        filter = filter and filter:lower()
        local function P(v)
            if v ~= nil and issecretvalue and issecretvalue(v) then return "<secret>" end
            return tostring(v)
        end
        local num = (C_BattleNet and C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum())
            or (BNGetNumFriends and BNGetNumFriends()) or 0
        DEFAULT_CHAT_FRAME:AddMessage(string.format("FriendGroups flavor report -- me: %s, mainline: %s",
            tostring(WOW_PROJECT_ID), tostring(WOW_PROJECT_MAINLINE)))
        for i = 1, num do
            local a = C_BattleNet.GetFriendAccountInfo(i)
            local g = a and a.gameAccountInfo
            local n = a and (a.accountName or a.battleTag)
            if g and type(n) == "string" and g.clientProgram == (BNET_CLIENT_WOW or "WoW")
                and (not filter or n:lower():find(filter, 1, true)) then
                local isClassic, source = Compat.ResolveFriendFlavor(g)
                local verdict = (isClassic == nil) and "?" or (isClassic and "CLASSIC" or "RETAIL")
                DEFAULT_CHAT_FRAME:AddMessage(string.format("%s  proj=%s realm=%s region=%s rp=%s  -> %s (%s)",
                    n, P(g.wowProjectID), P(g.realmName), P(g.regionID), P(g.richPresence), verdict, tostring(source)))
            end
        end
    elseif command == "titles" then
        -- [[ TITLE-FRIEND FIELD CENSUS ]] Why a name that is plainly on screen does not
        -- match a search. Prints, per 12.1 title friend, every field the row could have
        -- been drawn from and every field the matcher reads, marking each as a plain
        -- value, nil, or a SECRET (which renders through SetText but reads as absent to
        -- any addon inspecting it -- see FG_Plain in Compat.lua).
        --
        -- Lives here rather than in a /run one-liner because the chat editbox truncates
        -- at 255 characters, which silently cut the equivalent script mid-statement.
        --
        -- The legacy columns matter: BNGetFriendInfo sometimes returns a plain copy of a
        -- field the modern table publishes as secret, and if it does, that is the fix.
        local function P(v)
            if v == nil then return "nil" end
            if issecretvalue and issecretvalue(v) then return "SECRET" end
            return type(v) .. "=" .. tostring(v)
        end
        local num = (BNGetNumFriends and BNGetNumFriends()) or 0
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "FriendGroups title-friend census -- %d BNet friends, IsTitleFriend=%s",
            num,
            (type(FriendsListUtil) == "table" and type(FriendsListUtil.IsTitleFriend) == "function")
                and "available" or "MISSING"))
        local shown = 0
        for i = 1, num do
            local a = C_BattleNet.GetFriendAccountInfo(i)
            -- Compat.IsTitleFriend already falls back to the friendLevel enum when
            -- FriendsListUtil is absent, so this reports on every client.
            if a and Compat.IsTitleFriend(a) then
                local g = a.gameAccountInfo
                local lAcct, lChar
                if type(BNGetFriendInfo) == "function" then
                    local ok, _, n2, _, _, c2 = pcall(BNGetFriendInfo, i)
                    if ok then lAcct, lChar = n2, c2 end
                end
                shown = shown + 1
                DEFAULT_CHAT_FRAME:AddMessage(string.format(
                    "#%d acct=%s tag=%s gi=%s char=%s realm=%s | legacyAcct=%s legacyChar=%s",
                    i, P(a.accountName), P(a.battleTag), g and "table" or "nil",
                    P(g and g.characterName), P(g and g.realmName), P(lAcct), P(lChar)))
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format("%d title friends reported.", shown))
    elseif command == "titlenames" then
        -- [[ CUSTOM TITLE-FRIEND NAME PROBE ]]
        -- 12.1 added C_BattleNet.GetCustomTitleFriendName / SetCustomTitleFriendName /
        -- AreTitleFriendCustomNamesEnabled. If the getter returns PLAIN TEXT it is the only
        -- readable name a title friend has while OFFLINE, and it closes two open problems at
        -- once: Streamer Mode masking them to a bare "***", and the roster sorting them by
        -- the opaque |K escape because there is no name to sort on.
        --
        -- Printed RAW with the pipe doubled. A |K escape renders as the friend's real name
        -- through AddMessage, so an unescaped probe makes an unreadable value look like text
        -- and answers the exact question being asked with a lie. Byte length is printed for
        -- the same reason: a six-byte "name" is an escape whatever it looks like.
        local function RAW(v)
            if v == nil then return "nil" end
            if issecretvalue and issecretvalue(v) then return "SECRET" end
            return (tostring(v):gsub("|", "||"))
        end

        local haveGetter = type(C_BattleNet) == "table"
            and type(C_BattleNet.GetCustomTitleFriendName) == "function"
        local enabled = "n/a"
        if type(C_BattleNet) == "table" and type(C_BattleNet.AreTitleFriendCustomNamesEnabled) == "function" then
            local ok, v = pcall(C_BattleNet.AreTitleFriendCustomNamesEnabled)
            enabled = ok and tostring(v) or "error"
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "FriendGroups custom title names -- getter=%s, enabled=%s",
            haveGetter and "present" or "MISSING", enabled))

        local num = (BNGetNumFriends and BNGetNumFriends()) or 0
        local reported, usable = 0, 0
        for i = 1, num do
            local a = C_BattleNet.GetFriendAccountInfo(i)
            if a and Compat.IsTitleFriend(a) then
                reported = reported + 1
                -- Tried with BOTH keys: the signature is undocumented, and the friend index
                -- and the bnetAccountID are both plausible arguments for it.
                local okID, byID = false, nil
                local okIndex, byIndex = false, nil
                if haveGetter then
                    okID, byID = pcall(C_BattleNet.GetCustomTitleFriendName, a.bnetAccountID)
                    okIndex, byIndex = pcall(C_BattleNet.GetCustomTitleFriendName, i)
                end

                -- "Usable" means what the masker needs: real text, sliceable, not an escape.
                local candidate = (okID and byID) or (okIndex and byIndex) or nil
                if type(candidate) == "string" and candidate ~= ""
                    and not candidate:find("|K", 1, true)
                    and not (issecretvalue and issecretvalue(candidate)) then
                    usable = usable + 1
                end

                DEFAULT_CHAT_FRAME:AddMessage(string.format(
                    "  #%d id=%s byID=%s(%d) byIndex=%s(%d) acctBytes=%d",
                    i, tostring(a.bnetAccountID),
                    RAW(okID and byID or nil), #tostring(okID and byID or ""),
                    RAW(okIndex and byIndex or nil), #tostring(okIndex and byIndex or ""),
                    #tostring(a.accountName or "")))
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "%d title friends, %d with a usable plain-text custom name.", reported, usable))
    elseif command == "font" then
        -- [[ ROW FONT PROBE ]] Why CJK and Cyrillic names render as tofu boxes in the list
        -- while Blizzard's own mouseover shows them correctly.
        --
        -- The suspicion is FG_ShrinkFont: it captures GetFont() once per region and re-applies
        -- the raw PATH. A path is a single file with no fallback list, so any glyph that file
        -- lacks becomes a box -- whereas a font OBJECT keeps Blizzard's fallback chain, which
        -- is exactly what FriendGroups_DrawAltTooltip already restores by hand with
        -- SetFontObject for "Cyrillic/Asian characters".
        --
        -- What settles it is the pair of columns below: `obj` versus `path`. A row showing
        -- boxes with obj=nil and a Latin-only path confirms the mechanism; boxes with an
        -- object still attached means the font is not the culprit and the search moves on.
        -- `high` marks the rows that actually contain non-ASCII, which are the only ones the
        -- question is about.
        local function Describe(fs)
            if not fs then return "none" end
            local obj = (type(fs.GetFontObject) == "function") and fs:GetFontObject() or nil
            local objName = obj and type(obj.GetName) == "function" and obj:GetName() or nil
            local path, size, flags = fs:GetFont()
            local file = type(path) == "string" and path:match("[^\\/]+$") or path
            return string.format("obj=%s file=%s size=%s flags=%s",
                tostring(objName or "nil"), tostring(file or "nil"),
                tostring(size and math.floor(size + 0.5) or "nil"), tostring(flags or ""))
        end

        -- Raw, with the pipe doubled: a |K escape renders as a real name through AddMessage,
        -- so an unescaped probe would make an unreadable value look like text.
        local function Sample(fs)
            if not fs or type(fs.GetText) ~= "function" then return "nil", false end
            local text = fs:GetText()
            if type(text) ~= "string" then return "nil", false end
            local high = text:find("[\128-\255]") ~= nil
            return (text:sub(1, 24):gsub("|", "||")), high
        end

        DEFAULT_CHAT_FRAME:AddMessage("FriendGroups row font probe:")
        local reference = _G["GameTooltipText"]
        if reference then
            DEFAULT_CHAT_FRAME:AddMessage("  reference GameTooltipText -> " .. Describe(reference))
        end

        local rows, highRows = 0, 0
        Compat.ForEachContactListFrame(function(frame)
            if type(frame) ~= "table" then return end
            -- Social UI cards expose FriendName; the legacy rows expose name.
            local nameString = frame.FriendName or frame.name
            if not nameString then return end
            if rows >= 12 then return end
            rows = rows + 1

            local sample, high = Sample(nameString)
            if high then highRows = highRows + 1 end

            DEFAULT_CHAT_FRAME:AddMessage(string.format("  [%s] %s", high and "high" or "ascii", sample))
            DEFAULT_CHAT_FRAME:AddMessage("      live    " .. Describe(nameString))

            -- The captured baseline FG_ShrinkFont re-applies on every recycle. If this holds a
            -- path rather than an object, every later pass re-states that path and the
            -- fallback chain never comes back, however the region started out.
            local base = frame.fgBaseFont and frame.fgBaseFont["FriendName"]
            if base then
                local file = type(base.font) == "string" and base.font:match("[^\\/]+$") or base.font
                DEFAULT_CHAT_FRAME:AddMessage(string.format("      capture file=%s size=%s flags=%s",
                    tostring(file or "nil"), tostring(base.size or "nil"), tostring(base.flags or "")))
            else
                DEFAULT_CHAT_FRAME:AddMessage("      capture none (FG_ShrinkFont has not run on this row)")
            end
        end)

        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "%d rows reported, %d containing non-ASCII.", rows, highRows))
    elseif command == "bar" then
        -- [[ BATTLE.NET BAR TREE ]] Names the frames on the bar so the copy button beside the
        -- BattleTag can be addressed by its real parentKey instead of guessed at by position.
        -- Anonymous frames are the norm here, so the parentKey is recovered by scanning the
        -- parent's own fields for the child -- that is what actually identifies it.
        local bar = SocialUIFrame and SocialUIFrame.BattleNetBar
        if not bar then
            DEFAULT_CHAT_FRAME:AddMessage("FriendGroups: no SocialUIFrame.BattleNetBar on this client.")
            return
        end

        local function KeyOf(parent, child)
            for k, v in pairs(parent) do
                if v == child and type(k) == "string" then return k end
            end
            return "?"
        end

        local function Walk(frame, depth)
            if depth > 3 then return end
            for _, child in ipairs({ frame:GetChildren() }) do
                DEFAULT_CHAT_FRAME:AddMessage(string.format(
                    "%s%s .%s %s shown=%s",
                    string.rep("  ", depth), child:GetObjectType(), KeyOf(frame, child),
                    child:GetName() or "(anon)", tostring(child:IsShown())))
                Walk(child, depth + 1)
            end
        end

        DEFAULT_CHAT_FRAME:AddMessage("FriendGroups Battle.net bar tree:")
        Walk(bar, 0)
    elseif command == "offline" then
        -- [[ OFFLINE-TRACKER CENSUS ]] Which bucket each offline contact lands in, and why.
        --
        -- Originally written to answer "why did no [Offline N Month] group appear", which it
        -- did: the tracker was switched off, nobody on the roster had been gone more than
        -- 1.5 days, and a third of the offline contacts reported lastOnlineTime=0. That last
        -- group is the title-friend tier -- no Battle.net account behind the row, so no
        -- account-level timestamp -- and it is now reported per row, because "0" and "not
        -- yet a month" produce the same catch-all bucket for entirely different reasons.
        --
        -- Every row now resolves to a real group name rather than a shorthand, so this
        -- reports what the list will actually show instead of a parallel description of it.
        local num = (BNGetNumFriends and BNGetNumFriends()) or 0
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "FriendGroups offline tracker -- setting=%s, %d BNet friends, now=%d",
            tostring(FriendGroups_SavedVars.offline_tracker), num, time()))

        local offlineSeen, withStamp, dated, titleTier = 0, 0, 0, 0
        for i = 1, num do
            local a = C_BattleNet.GetFriendAccountInfo(i)
            local g = a and a.gameAccountInfo
            if a and not (g and g.isOnline) then
                offlineSeen = offlineSeen + 1
                local lot = a.lastOnlineTime
                local shown
                if lot == nil then
                    shown = "nil"
                elseif issecretvalue and issecretvalue(lot) then
                    shown = "SECRET"
                else
                    shown = type(lot) .. "=" .. tostring(lot)
                end

                local isTitle = Compat.IsTitleFriend(a)
                if isTitle then titleTier = titleTier + 1 end

                -- Mirrors the resolution in FriendGroups_SetGroups exactly, including the
                -- catch-all, so the bucket printed here is the group the row is filed into.
                local days, bucket = nil, L["GROUP_OFFLINE_0"]
                if type(lot) == "number" and lot > 0 then
                    withStamp = withStamp + 1
                    days = (time() - lot) / 86400
                    if days >= 90 then bucket = L["GROUP_OFFLINE_3"]
                    elseif days >= 60 then bucket = L["GROUP_OFFLINE_2"]
                    elseif days >= 30 then bucket = L["GROUP_OFFLINE_1"] end
                    if days >= 30 then dated = dated + 1 end
                end

                DEFAULT_CHAT_FRAME:AddMessage(string.format(
                    "  #%d %s lastOnlineTime=%s days=%s -> %s",
                    i, isTitle and "title" or "acct", shown,
                    days and string.format("%.1f", days) or "n/a", bucket))
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "%d offline (%d title tier), %d with a usable timestamp, %d in a dated bucket, %d in %s.",
            offlineSeen, titleTier, withStamp, dated, offlineSeen - dated, L["GROUP_OFFLINE_0"]))
    elseif command == "streamer" then
        -- The settings menu is itself a list of the player's own preferences drawn over the
        -- contact list, so reaching for it is the one moment you would rather not be on
        -- camera. This is the same toggle, reachable without opening anything.
        FriendGroups_SavedVars.streamer_mode = not FriendGroups_SavedVars.streamer_mode
        FriendGroups_ApplyStreamerMode()
        print(FriendGroups_SavedVars.streamer_mode and L["MSG_STREAMER_ON"] or L["MSG_STREAMER_OFF"])
    elseif command == "match" then
        -- [[ MATCHER PROBE ]] /fg match <text>
        -- Calls FriendGroups_Search directly against every Battle.net friend with <text> as
        -- the live search term, and prints the verdict next to the account name the row is
        -- drawn from. This exists to separate the two halves of "a visible name will not
        -- match", which no amount of reading the source can tell apart:
        --
        --   verdict YES but the row is missing from the list  -> the PREDICATE is fine and
        --      something downstream (native search provider, renderer, bucketing) drops it.
        --   verdict NO                                        -> the predicate is at fault
        --      and the printed fields say which comparison failed.
        --
        -- Restores the previous search text before returning, so running it cannot leave the
        -- list filtered behind an empty search box.
        local probe = msg:match("^%s*%w+%s+(.+)$")
        probe = probe and probe:match("^%s*(.-)%s*$")
        if not probe or probe == "" then
            DEFAULT_CHAT_FRAME:AddMessage("Usage: /fg match <text>")
        else
            local State = addonTable.State
            local restore = State and State.GetSearchText and State.GetSearchText() or nil
            if State and State.SetSearchText then State.SetSearchText(probe) end

            -- Two chat lines per reported row, so this is the point past which the header
            -- lines -- the ones carrying the verdict -- start scrolling away.
            local FG_MATCH_PROBE_CAP = 15
            local num = (BNGetNumFriends and BNGetNumFriends()) or 0
            DEFAULT_CHAT_FRAME:AddMessage(string.format(
                "FriendGroups matcher probe -- term=%q searchValue=%q over %d BNet friends",
                probe, tostring(addonTable.State.GetSearchText and addonTable.State.GetSearchText()), num))

            -- The native name set is normally built by the roster pass, which this probe does
            -- not run -- so without this it stays nil and the one path under test is skipped.
            FriendGroups_RebuildNameMatchSet()
            local nativeCount, nativeList = 0, {}
            if FriendGroups_NameMatchSet then
                for idx in pairs(FriendGroups_NameMatchSet) do
                    nativeCount = nativeCount + 1
                    nativeList[#nativeList + 1] = tostring(idx)
                end
            end
            DEFAULT_CHAT_FRAME:AddMessage(string.format(
                "  SearchFriends: api=%s shape=%s set=%s matches=%d forbidden=%s [%s]",
                tostring(type(C_BattleNet) == "table" and type(C_BattleNet.SearchFriends)),
                tostring(FriendGroups_NameMatchSource),
                FriendGroups_NameMatchSet and "built" or "nil",
                nativeCount, tostring(Compat.IsSearchFriendsForbidden()),
                table.concat(nativeList, ",")))

            -- [[ WHICH ROWS TO REPORT ]]
            -- Title friends are the rows in question, and 12 unfiltered lines of detail would
            -- scroll the useful ones off the chat frame -- so they are preferred when the tier
            -- exists. It does NOT always exist: on a 12.1 client where the Social UI was
            -- walked back, Compat.IsTitleFriend answers false for everyone and this probe
            -- printed a header, no rows, and "complete" -- reading as "nothing is wrong" at
            -- the exact moment it was being asked what was wrong.
            --
            -- So the tier is COUNTED first and reported, and when there is none the whole list
            -- is walked instead under the same output cap. The count is the answer to "does
            -- this client have WoW Friends at all", which is worth a line of its own.
            local titleTierSeen = 0
            for i = 1, num do
                local a = C_BattleNet.GetFriendAccountInfo(i)
                if a and Compat.IsTitleFriend(a) then titleTierSeen = titleTierSeen + 1 end
            end
            local titleOnly = titleTierSeen > 0
            local cachedNames = 0
            if type(FriendGroups_SavedVars.wow_friend_names) == "table" then
                for _ in pairs(FriendGroups_SavedVars.wow_friend_names) do
                    cachedNames = cachedNames + 1
                end
            end
            DEFAULT_CHAT_FRAME:AddMessage(string.format(
                "  socialUI=%s titleTier=%d rememberedNames=%d -- reporting %s (cap %d)",
                tostring(Compat.IsSocialUIActive()), titleTierSeen, cachedNames,
                titleOnly and "title friends" or "ALL friends", FG_MATCH_PROBE_CAP))

            local reported = 0
            FriendGroups_SearchDebug = true
            for i = 1, num do
                local a = C_BattleNet.GetFriendAccountInfo(i)
                if a and reported < FG_MATCH_PROBE_CAP and ((not titleOnly) or Compat.IsTitleFriend(a)) then
                    reported = reported + 1
                    local ok, hit = pcall(FriendGroups_Search, i, FRIENDS_BUTTON_TYPE_BNET, a)
                    -- bnetAccountID is reported because the |K escape is very likely a
                    -- SESSION-SCOPED index into the client's name cache, which would make it
                    -- unsafe as a persistent key -- the same shape of bug as keying on a chat
                    -- lineID. If a last-known-name cache is needed, it keys on this instead.
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("#%d -> %s (bnetAccountID=%s online=%s)",
                        i, (not ok) and ("ERROR " .. tostring(hit)) or (hit and "YES" or "no"),
                        tostring(a.bnetAccountID),
                        tostring(a.gameAccountInfo and a.gameAccountInfo.isOnline)))
                end
            end
            FriendGroups_SearchDebug = false
            DEFAULT_CHAT_FRAME:AddMessage("Matcher probe complete.")

            if State and State.SetSearchText then State.SetSearchText(restore or "") end
        end
    elseif command == "portrait" then
        -- Every signal the legacy panel's portrait decision reads, printed rather than inferred.
        if Compat.ReportLegacyPortrait then
            Compat.ReportLegacyPortrait()
        else
            DEFAULT_CHAT_FRAME:AddMessage("FriendGroups: portrait probe is retail-only.")
        end
    elseif command == "mark" then
        -- Moves the Contacts-page mark in place and prints the offsets, so the ElvUI
        -- position can be dialled in without a reload per nudge. See ContactsMark.lua.
        if FriendGroupsContactsMark and FriendGroupsContactsMark.Command then
            FriendGroupsContactsMark.Command(msg)
        end
    elseif command == "automation" then
        -- Which addon owns each automation right now, and why nothing fired.
        if FriendGroups_ReportAutomation then FriendGroups_ReportAutomation() end
    elseif command == "toast" then
        -- Drives both countdown toasts without performing the game action.
        if FriendGroups_TestAutomationToast then FriendGroups_TestAutomationToast() end
    elseif command == "export" then
        FriendGroups_ShowExport()
    elseif command == "import" then
        StaticPopup_Show("FRIENDGROUPS_IMPORT")
    else
        DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_HELP"])
    end
end

-- ============================================================================
-- [[ OPEN-LIST UPDATE COALESCER ]]
-- ============================================================================
-- Collapses bursts of roster events (BN_FRIEND_INFO_CHANGED, FRIENDLIST_UPDATE, native idle
-- ticks) routed here by the Dirty Roster Engine (and, in legacy mode, the
-- FriendsList_Update override) into a single deferred refresh.
-- Schedules at most one timer per window, and only while the Friends list is actually visible.
-- The Dirty Roster Engine still flags changes regardless, so a hidden list rebuilds correctly
-- via OnShow the next time it is opened. All existing guards (combat, visibility, dirty) still
-- apply when the timer fires, so behaviour is identical to today aside from a sub-frame delay.
-- [[ GROUPED PROVIDER RE-ASSERT (12.2.2 TAINT FIX COMPANION) ]]
-- In post-hook mode Blizzard's native FriendsList_Update installs its own flat data
-- provider into the ScrollBox. This runs immediately afterwards, inside the same
-- execution, and swaps the last grouped provider back before anything is rendered --
-- the flat list never becomes visible and the scroll position is retained. The
-- coalesced rebuild that follows refreshes the grouped data itself.
function FriendGroups_ReassertGroupedProvider()
    if not FriendGroups_Loaded then return end
    if not (FriendsListFrame and FriendsListFrame.ScrollBox) then return end
    if not FriendGroups_ActiveProvider then return end
    if FriendsListFrame.ScrollBox:GetDataProvider() == FriendGroups_ActiveProvider then return end
    FriendsListFrame.ScrollBox:SetDataProvider(FriendGroups_ActiveProvider, true)
end

-- Published for the platform renderers. FriendGroups_FriendsListUpdate is a FILE-LOCAL
-- (forward-declared at the top of this file), so Platform_*.lua cannot see it -- a plain
-- global lookup there silently yields nil, which is exactly how the Social UI renderer's
-- deferred first build was lost. Exposed through State like GetPlayerGuildName rather than
-- promoted to a global, so the file's own encapsulation is unchanged.
addonTable.State.FriendsListUpdate = function(forceUpdate)
    return FriendGroups_FriendsListUpdate(forceUpdate)
end

local FriendGroups_UpdateThrottleTimer = nil
function FriendGroups_RequestListUpdate()
    -- Same reason as the guard in FriendGroups_FriendsListUpdate: on 12.1 the list the
    -- player is looking at is not FriendsListFrame, which is present but never shown.
    if not Compat.IsContactListShown() then return end
    if FriendGroups_UpdateThrottleTimer then return end
    FriendGroups_UpdateThrottleTimer = C_Timer.NewTimer(0.1, function()
        FriendGroups_UpdateThrottleTimer = nil
        FriendGroups_FriendsListUpdate(false)
    end)
end

-- ============================================================================
-- [[ COMBAT LOCKOUT QUEUE HANDLER ]]
-- ============================================================================
local FriendGroups_CombatQueueFrame = CreateFrame("Frame")
FriendGroups_CombatQueueFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
FriendGroups_CombatQueueFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        if FriendGroups_UpdateQueued then
            FriendGroups_UpdateQueued = false
            -- Combat has safely ended. Use the standard (non-forcing) update path so the
            -- visibility guard applies: if the Friends list is hidden this returns immediately
            -- (OnShow will rebuild it later); if it is shown it rebuilds once via the O(n) swap.
            FriendGroups_FriendsListUpdate(false)
        end
    end
end)

