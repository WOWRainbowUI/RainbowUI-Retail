-- FriendGroups core: roster pass, grouping, sorting, menus and the legacy list renderer.
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
-- GROUP_ROSTER_UPDATE refreshes rows without dirtying the roster (see OnEvent).
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
    -- Primary refresh driver: these events are unregistered from FriendsFrame (EnableFriendGroups).
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
local FriendGroups_FriendsListUpdateBody
local FriendGroups_FriendsListUpdateFriendButton
local FriendGroups_FriendsListButtonTemplateClick
local SetupGroupedView
local FriendGroups_SaveToAltCache
local FG_InstallSendMessageOverride

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

-- [[ HOUSE ACCENT ]] The addon's gold, resolved live through FriendGroupsEUISkin (loaded after
-- this file) so everything retints with the EllesmereUI skin, on every platform.
local FG_GOLD_R, FG_GOLD_G, FG_GOLD_B = 1, 0.82, 0

-- Claim the final width up front: GameTooltip wraps a line at the width it has when added,
-- and the prose is added before the rows that widen it.
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

-- [[ ROW FONT SCALE ]] 1 Small, 2 Medium (default), 3 Large. Anything else reads as Medium.
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

-- [[ ONLINE COUNTER PLACEMENT ]] Right-aligned to the headers' count column, measured from live
-- frames (FriendGroups_GetCountColumnInset). Insets: ScrollBox 20, Classic HybridScroll 10.
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
        local scrollFrame = Compat.GetClassicListFrame()
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

-- For renderers that own their search box. searchValue and searchLowerValue must change
-- together. Returns true only when the text changed.
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
    -- Width items: retail UI only (Compat.CAN_RESIZE_WIDTH); elsewhere the flags are never applied.
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

    -- [[ ROW FONT SCALE ]] Social UI only: nothing else uses FG_ShrinkFont. Still stored everywhere.
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

    -- SECTION 1: PRIVACY. First under the pointer: it is flipped right before going live.
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
        tooltip = { L["SET_INGAME_ONLY_TT"] },
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.ingame_only end,
        func = function()
            FriendGroups_SavedVars.ingame_only = not FriendGroups_SavedVars.ingame_only
            -- Clear the offline tracker too, or its headers draw over nothing. One-way, like Hide All Offline.
            if FriendGroups_SavedVars.ingame_only then
                FriendGroups_SavedVars.offline_tracker = false
            end
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
            StaticPopup_Show("FRIENDGROUPS_RELOAD")
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

    -- SECTION: CONTACT LIST. Classic only, off by default (Compat.UseOwnClassicList, CurseForge #55).
    -- Not in Sync's BOOL_FIELDS: it is a platform switch, not a preference.
    { text = L["SETTINGS_LIST"], notCheckable = true, isTitle = true,
      condition = function() return not Compat.HAS_SCROLLBOX end },
    {
        text = L["SET_OWN_LIST"],
        tooltip = { L["SET_OWN_LIST_TT_1"], L["SET_OWN_LIST_TT_2"] },
        condition = function() return not Compat.HAS_SCROLLBOX end,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.classic_own_list end,
        func = function()
            FriendGroups_SavedVars.classic_own_list = not FriendGroups_SavedVars.classic_own_list
            StaticPopup_Show("FRIENDGROUPS_RELOAD")
        end
    },

    -- SECTION: CHAT. Retail and Forever only (no secret values on Classic). See WHISPER WITHOUT
    -- TAINTING CHAT. Off by default.
    { text = L["SETTINGS_CHAT"], notCheckable = true, isTitle = true,
      condition = function() return Compat.IS_RETAIL_UI end },
    {
        text = L["SET_SAFE_WHISPER"],
        tooltip = { L["SET_SAFE_WHISPER_TT_1"], L["SET_SAFE_WHISPER_TT_2"] },
        condition = function() return Compat.IS_RETAIL_UI end,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.safe_whisper end,
        func = function()
            FriendGroups_SavedVars.safe_whisper = not FriendGroups_SavedVars.safe_whisper
            if FriendGroups_SavedVars.safe_whisper then
                FG_InstallSendMessageOverride()
            end
        end
    },

    -- SECTION: MINIMAP (see Minimap.lua)
    { text = L["SETTINGS_MINIMAP"], notCheckable = true, isTitle = true },
    {
        text = L["SET_COMPARTMENT"],
        tooltip = { L["SET_COMPARTMENT_TT"] },
        condition = function() return Compat.HAS_COMPARTMENT end,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_compartment end,
        func = function()
            FriendGroups_SavedVars.show_compartment = not FriendGroups_SavedVars.show_compartment
            FriendGroups_UpdateMinimapButton()
        end
    },
    {
        text = L["SET_MINIMAP_BUTTON"],
        tooltip = { L["SET_MINIMAP_BUTTON_TT"] },
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_minimap_button end,
        func = function()
            FriendGroups_SavedVars.show_minimap_button = not FriendGroups_SavedVars.show_minimap_button
            FriendGroups_UpdateMinimapButton()
        end
    },

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
        text = L["SET_AUTO_ACCEPT_FRIENDS_GUILD"],
        tooltip = { L["SET_AUTO_ACCEPT_FRIENDS_GUILD_TT"] },
        enabled = function() return FriendGroups_SavedVars.auto_accept_invite == true end,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_accept_friends_guild end,
        func = function()
            FriendGroups_SavedVars.auto_accept_friends_guild = not FriendGroups_SavedVars.auto_accept_friends_guild
        end
    },
    {
        text = L["SET_AUTO_PARTY_SYNC"],
        -- Hidden where Blizzard has Party Sync switched off (Forever); the saved value stays.
        condition = function() return Compat.IsPartySyncAvailable() end,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_accept_sync end,
        func = function()
            FriendGroups_SavedVars.auto_accept_sync = not FriendGroups_SavedVars.auto_accept_sync
            FriendGroups_FriendsListUpdate()
        end
    },
    -- Not settings: the toast makes auto-accept interruptible, and deferring to GLogger is the
    -- only way to avoid two prompts.

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
            -- Must cover every key in the fresh-install defaults and the nil-checks after
            -- them; diff the lists whenever a setting is added.
            FriendGroups_SavedVars.show_flags = true
            FriendGroups_SavedVars.show_contact_cap = true
            FriendGroups_SavedVars.hide_high_level = true
            FriendGroups_SavedVars.add_favorite_group = true
            FriendGroups_SavedVars.show_guildmates = true
            FriendGroups_SavedVars.show_mobile_afk = false
            FriendGroups_SavedVars.add_mobile_text = true
            FriendGroups_SavedVars.ingame_only = false
            FriendGroups_SavedVars.ingame_retail = false
            FriendGroups_SavedVars.show_retail = false
            FriendGroups_SavedVars.show_search = true
            FriendGroups_SavedVars.hide_empty_groups = false
            FriendGroups_SavedVars.hide_afk = false
            FriendGroups_SavedVars.open_one_group = false
            FriendGroups_SavedVars.auto_accept_invite = true
            FriendGroups_SavedVars.auto_accept_friends_guild = false
            FriendGroups_SavedVars.auto_accept_sync = true
            FriendGroups_SavedVars.offline_tracker = true
            FriendGroups_SavedVars.streamer_mode = false
            FriendGroups_SavedVars.safe_whisper = false
            FriendGroups_SavedVars.show_compartment = true
            FriendGroups_SavedVars.show_minimap_button = false
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
            -- A fresh install shows the retail/Forever reminder, so a reset does too.
            FriendGroups_SavedVars.forever_import_tip_off = nil
            FriendGroups_SavedVars.forever_export_tip_off = nil

            FriendGroups_UpdateSize()
            FriendGroups_UpdateContactCap()
            FriendGroups_UpdateMinimapButton()
            FriendGroups_FriendsListUpdate()

            print(L["MSG_RESET"])
            FriendGroups_ShowForeverImportTip()
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

-- A closure, because a string can't be shared by reference. Declared after the local it reads.
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
            local accountInfo = Compat.GetFriendAccountInfo(i)
            if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
                if accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
                    local bName = accountInfo.gameAccountInfo.characterName or ""
                    local bRealm = FriendGroups_CleanRealmName(accountInfo.gameAccountInfo.realmName or accountInfo.gameAccountInfo.realmDisplayName or "")
                    if Compat.IsForeverGame(accountInfo.gameAccountInfo) then bRealm = Compat.FOREVER_REALM end
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
            local name = (C_GuildInfo and C_GuildInfo.GetGuildRosterInfo) and C_GuildInfo.GetGuildRosterInfo(i)
                or (GetGuildRosterInfo and GetGuildRosterInfo(i))
            
            if name and type(name) == "string" then
                local baseName, realmName = strsplit("-", name)
                if baseName then
                    local targetRealm = realmName or myRealm
                    if Compat.IS_FOREVER then targetRealm = Compat.FOREVER_REALM end
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

-- [[ WIDTH MODE READERS ]] Every width read goes through these; where width can't change they
-- report 0, so imported retail flags stay inert. SavedVars guarded (row renderer runs early).

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
    -- Narrow 0 / Normal half / Wide full; wide_list wins over width_normal.
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
        -- Classic: top up the HybridScroll button pool for the new height, next frame (once the
        -- anchored height has updated).
        local sf = Compat.GetClassicListFrame()
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
        local accountInfo = Compat.GetFriendAccountInfo(i)
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
                local friendAccountInfo = Compat.GetFriendAccountInfo(id)
                if friendAccountInfo and friendAccountInfo.gameAccountInfo then
                    local gameAccountInfo = friendAccountInfo.gameAccountInfo
                    
                    -- Only invite BNet friends whose live WoW session is on OUR project;
                    -- cross-project accounts cannot be grouped and would silently fail.
                    if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and Compat.IsSameProject(gameAccountInfo) then
                        local gameAccountID = gameAccountInfo.gameAccountID
                        if gameAccountID then
                            C_Timer.After(inviteDelay, function()
                                C_BattleNet.InviteFriend(gameAccountID)
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
            local friendAccountInfo = Compat.GetFriendAccountInfo(i)
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

-- [[ NOTE GRAMMAR ]] @[Nickname] <Guild> free text #Group1#Group2. The note is the only store;
-- sv.nicknames is a cache. Delimiters are wire format, never localized. "@[" not "@": real notes
-- contain stray @, and brackets allow spaces.

local FG_NICKNAME_PATTERN = "@%[([^%]]*)%]"

-- Memoized per note string, flushed like FriendGroups_NoteCache.
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

-- Replace, don't append (idempotent). Tag goes first: Battle.net apps truncate the note.
-- Callers check the result against Compat.BNET_NOTE_MAXBYTES.
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

-- [[ NICKNAME RECONCILE ]] Destructive: a tagless note clears the cache. So only enumerated
-- accounts are touched, an unreadable note means unknown (never delete), and nothing runs
-- before FriendGroups_NicknameSyncReady. Removed friends are left alone.

-- Header label colour: override, else white on a banner, else nil (keep the default).
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

-- The key every per-contact cache uses. Not `battleTag or accountName`: 12.1 title friends
-- report battleTag as "" (truthy), which filed them all under one key.
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

	-- Separate from 12.1's native Edit Name on purpose: mirroring them made the two stores fight.

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

function FriendGroups_GetClassColorCode(class, returnTable)
	if not class then
		return returnTable and FRIENDS_GRAY_COLOR or
			string.format("|cFF%02x%02x%02x", FRIENDS_GRAY_COLOR.r * 255, FRIENDS_GRAY_COLOR.g * 255,
				FRIENDS_GRAY_COLOR.b * 255)
	end

	local color = Compat.ClassColor(Compat.ClassToken(class)) or FRIENDS_GRAY_COLOR
	if returnTable then
		return color
	else
		return string.format("|cFF%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
	end
end

FriendGroups_ActiveAKA = {}

-- [[ STREAMER MODE ]] Display only: never written back, search matches real values, whisper and
-- invite use real names. Reveal min(3, half) CHARACTERS (UTF-8), at least one: a fixed three
-- unmasks short CJK names.

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

	-- A |K escape has no meaningful prefix; never slice it.
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

-- [[ SESSION NAME MAP ]] Names seen this session by bnetAccountID (a session id), preferred over
-- the persisted wow_friend_names, which remains the fallback for friends not seen yet.
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

-- On 12.1 accountName is a Kstring for every friend. Mask the first plain-text candidate:
-- battleTag, characterName (online only), then a remembered name.
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

-- Forced rebuild: a display-only change never dirties the roster.
function FriendGroups_ApplyStreamerMode()
	FriendGroups_FriendsListUpdate(true)
	if Compat and type(Compat.RefreshOwnBattleTag) == "function" then
		Compat.RefreshOwnBattleTag()
	end
end

-- gameInfo picks the level cap for hide-max-level (fails open). canCoop is unused but keeps the
-- 21-value tuple positions from FriendGroups_GetFriendInfoById.
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
			-- battleTag FIRST: on 12.1 accountName is a Kstring for every contact, so masking
			-- it directly would print "***" for the whole list. The tag's name half is real
			-- text and survives the friend going offline, which characterName does not.
			nameText = FriendGroups_MaskFirstPlain(battleTag, accountName, characterName)
		else
			nameText = accountName
		end
	else
		nameText = UNKNOWN
	end

	-- append character name
	if characterName then
		-- Raw characterName for the aka comparison; only the display copy gets icons or masking.
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
            -- On-main test compares name AND realm (same name on another realm is not the main).
            local onMainCharacter = (akaInfo.name == characterName)
            -- Forever alts are stored under FOREVER_REALM, never the live shard name.
            local liveRealm = (gameInfo and Compat.IsForeverGame(gameInfo)) and Compat.FOREVER_REALM or realmName
            if onMainCharacter and akaInfo.realm and liveRealm and liveRealm ~= "" then
                onMainCharacter = (FriendGroups_CleanRealmName(akaInfo.realm) == FriendGroups_CleanRealmName(liveRealm))
            end
            if akaInfo.name and not onMainCharacter then
                local akaDisplayName = akaInfo.name
                if streamerMode then
                    akaDisplayName = FriendGroups_MaskName(akaDisplayName)
                end
                local akaFormattedName = "[" .. akaDisplayName .. "]"

                -- Apply class color strictly to the name inside the AKA brackets
                if FriendGroups_SavedVars.colour_classes and akaInfo.class then
                    akaFormattedName = FriendGroups_GetClassColorCode(akaInfo.class) .. akaFormattedName .. FONT_COLOR_CODE_CLOSE
                end
                
                if L["FORMAT_AKA_DISPLAY"] then
                    akaText = string.format(L["FORMAT_AKA_DISPLAY"], akaFormattedName)
                end
            end
        end

		if client == BNET_CLIENT_WOW then
			if characterName ~= "" and level ~= 0 then
				if FriendGroups_SavedVars.colour_classes then
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
		locationText = locationText .. " - " .. Compat.DisplayRealmName(realmText)
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
		local accountInfo = Compat.GetFriendAccountInfo(id)
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

			if Compat.IS_RETAIL_UI then
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
			zoneName = zoneName .. " - " .. Compat.DisplayRealmName(realmName)
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
		local friendAccountInfo = Compat.GetFriendAccountInfo(playerData.id)

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


-- [[ BATTLE.NET CLIENT CLASSIFICATION ]] Sort, in-a-game filter and presence flags must agree.
-- Denylist the two app clients (App, BSAp): new games add codes. Unwrap secrets first (unknown is
-- never a game); BNET_CLIENT_WOW has a fallback, not defined on every flavor.
local FG_BNET_APP_CLIENTS = { App = true, BSAp = true }

local function FG_PlainClient(client)
	if client == nil then return nil end
	if issecretvalue and issecretvalue(client) then return nil end
	if type(client) ~= "string" or client == "" then return nil end
	return client
end

-- The WoW client code, resolved defensively (see above).
local function FG_WowClient()
	return BNET_CLIENT_WOW or "WoW"
end

-- True when the friend is in World of Warcraft itself.
function FriendGroups_IsWowClient(client)
	return FG_PlainClient(client) == FG_WowClient()
end

-- True when the friend is in ANY Blizzard game, WoW included. False for the Battle.net
-- desktop and mobile apps, and for a client we could not read.
function FriendGroups_IsGameClient(client)
	local plain = FG_PlainClient(client)
	if not plain then return false end
	return not FG_BNET_APP_CLIENTS[plain]
end

-- True when the friend is in a Blizzard game that is NOT WoW. This is the tier the
-- presence sort inserts between "in WoW" and "signed in to the app".
function FriendGroups_IsOtherGameClient(client)
	local plain = FG_PlainClient(client)
	if not plain then return false end
	if plain == FG_WowClient() then return false end
	return not FG_BNET_APP_CLIENTS[plain]
end
function FriendGroups_SortTableByStatus(playerA, playerB)
	if not playerA then
		playerA = {}
	end

	if not playerB then
		playerB = {}
	end

	-- 1. Presence tier: WoW, another game, app/mobile only, offline. Split by client, not status
	-- text (only WoW gets "InGame"); same predicate as the in-a-game filter.
	local rankA = playerA.isInGame and 1
		or (playerA.isInOtherGame and 2)
		or (playerA.isOnline and 3)
		or 4
	local rankB = playerB.isInGame and 1
		or (playerB.isInOtherGame and 2)
		or (playerB.isOnline and 3)
		or 4
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

	-- 3. Battle.net friends before WoW friends. On 12.1 both arrive as BNET rows, so use
	-- isTitleFriend from the roster pass; buttonType still serves 12.0.7 and Classic.
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

-- [[ OFFLINE TRACKER GROUPS ]] Ranked buckets, shortest absence first. Rank 1 is the catch-all
-- (undatable: title friends, character friends). Built once from L (loaded before this file);
-- missing keys are skipped.
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

-- Display label: the auto guild group's key is bare L["GROUP_GUILDMATES"], with the guild name
-- added at draw time. Every user-facing group name goes through this.
local function FriendGroups_GroupDisplayName(groupName)
	if groupName == L["GROUP_GUILDMATES"]
		and FriendGroups_PlayerGuildName and FriendGroups_PlayerGuildName ~= "" then
		return string.format(L["FORMAT_GUILD_TAG"], groupName, FriendGroups_PlayerGuildName)
	end
	return groupName
end

-- [[ MANUAL GROUP ORDER ENGINE ]] Optional ranks in group_order; unranked groups keep their
-- automatic position. Fixed system anchors never move.
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

-- Same-percentage restore fires no scroll event, so nudge and restore to re-acquire rows.
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

	-- Dense integer ranks: each click moves exactly one place, and exports never collide.
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

-- Drag-and-drop counterpart of MoveGroup. targetSlot is an insertion slot in the current order
-- (#order + 1 = last); removing first shifts later slots, handled below.
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

	-- [[ OFFLINE BLOCK ]] Pinned at the bottom, below [No Group], in rank order, ranked on the key:
	-- string-sorting localized names put it mid-list and the catch-all below the 3+ month bucket.
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

-- [[ UNIQUE ONLINE COUNTER ]] Distinct online contacts: keyed per friend, and a BNet friend also
-- on the character list is matched by their character's GUID (FriendGroups_ResolveOnlineKey).
local FriendGroups_OnlineKeys = {}      -- [identityKey] = true, every unique online contact
local FriendGroups_OnlineByGroup = {}   -- [groupName] = { [identityKey] = true }
local FriendGroups_OnlineGuidKeys = {}  -- [playerGuid] = identityKey, online BNet characters
local FriendGroups_OnlineTotal = 0
-- [bucket] = { count, info }; one game per unique contact, so the counts sum to the total.
local FriendGroups_OnlineByGame = {}

-- Fields Compat's icon and bucket helpers read; copied so no API table is held past the pass.
local FG_GAME_INFO_FIELDS = { "clientProgram", "subIcon", "wowProjectID", "realmName", "realmID", "regionID", "richPresence" }

local function FriendGroups_TallyGame(gameInfo)
    local bucket = Compat.GameBucket(gameInfo)
    local entry = FriendGroups_OnlineByGame[bucket]
    if not entry then
        local info = { clientProgram = FG_WowClient(), wowProjectID = WOW_PROJECT_ID }
        if gameInfo then
            info = {}
            for _, field in ipairs(FG_GAME_INFO_FIELDS) do info[field] = gameInfo[field] end
        end
        entry = { count = 0, info = info }
        FriendGroups_OnlineByGame[bucket] = entry
    end
    entry.count = entry.count + 1
end

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
    -- In a game = any Blizzard game; it removes the app clients. Same-game narrowing is show_retail.
    if FriendGroups_SavedVars.ingame_only and not FriendGroups_IsGameClient(client) then
        return false
    end
    -- Same game as this client, for every client, not just WoW (removes other games and the apps).
    if FriendGroups_SavedVars.show_retail and not isSameProject then
        return false
    end
    return true
end

-- Requires the BNet list to be walked before the WoW list.
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
    -- 12.1 title tier, which shares the BNet enumeration; false on 12.0.7 and Classic.
    local isTitleFriend = false
    -- GUID of the character this friend is logged into; links the BNet and WoW friend
    -- lists together for the unique online counter. Nil when offline or not in WoW.
    local playerGuid = nil
    local tallyGameInfo = nil

    -- Inline state resolution to completely bypass redundant API table allocations
    if buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local friendAccountInfo = passedAccountInfo or Compat.GetFriendAccountInfo(id)
        if friendAccountInfo then
            noteText = friendAccountInfo.note or ""
            favorite = friendAccountInfo.isFavorite
            accountIdentifier = FriendGroups_AccountIdentifier(friendAccountInfo)

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            if gameAccountInfo then
                tallyGameInfo = gameAccountInfo
                isOnline = gameAccountInfo.isOnline
                client = gameAccountInfo.clientProgram
                -- Guild auto-detect matches against our own roster, so Forever compares with itself.
                isRetail = (gameAccountInfo.wowProjectID == (Compat.IS_FOREVER and WOW_PROJECT_ID or WOW_PROJECT_MAINLINE))
                -- Same-project drives the "show only <this client>'s friends" filter:
                -- retail-identical (self == mainline) and correct on Classic (self == Classic).
                isSameProject = Compat.IsSameProject(gameAccountInfo)
                charName = (type(gameAccountInfo.characterName) == "string") and gameAccountInfo.characterName or ""

                -- [[ LAST-KNOWN NAME CAPTURE ]] Plain-text name while online, for offline search. Keyed on
                -- bnetAccountID, never the session-scoped |K escape. Not gated on the title tier, which can be
                -- absent; FG_IsMaskable is the real test.
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
                    -- Shared predicate, so status text and presence flags agree.
                    if FriendGroups_IsWowClient(client) then statusText = statusText .. "InGame" end
                end
            end
            
            if accountIdentifier and FriendGroups_SavedVars and type(FriendGroups_SavedVars.alt_cache) == "table" and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
                altCacheCount = #FriendGroups_SavedVars.alt_cache[accountIdentifier]
            end

            -- Outside the session block: the remembered name matters most with no session.
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
            -- Via FG_WowClient: the global may be missing on Classic, which would drop character friends.
            client = FG_WowClient()
            -- A C_FriendList friend is on your realm, so always the same project.
            isSameProject = true
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
            local friendAccountInfo = passedAccountInfo or Compat.GetFriendAccountInfo(id)
            -- Title friends have no BattleTag: caching their alts would file strangers together.
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
                        local friendAccountInfo = passedAccountInfo or Compat.GetFriendAccountInfo(id)
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

        -- [[ OFFLINE TRACKER ]] Exclusive: an offline contact sits in one bucket only. [Favorites] is
        -- exempt (a pin). Both friend tiers qualify. fullGroups keeps the pre-filing groups so the alt
        -- tooltip still shows the guild.
        local fullGroups = nil

        if FriendGroups_SavedVars.offline_tracker and statusText == "Offline" then
            local offlineGroup = L["GROUP_OFFLINE_0"]

            if buttonType == FRIENDS_BUTTON_TYPE_BNET then
                local friendAccountInfo = passedAccountInfo or Compat.GetFriendAccountInfo(id)
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

        -- With the tracker on, [No Group] is online-only by design.
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
            FriendGroups_TallyGame(tallyGameInfo)
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
            -- The in-a-game filter removes every offline contact.
            if not FriendGroups_SavedVars.hide_offline and not FriendGroups_SavedVars.ingame_only then
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

            -- [[ PRESENCE FLAGS ]] isInGame (WoW) tier 1, isInOtherGame tier 2, isOnline tier 3, none 4.
            -- Not exclusive on purpose: the sort reads them in order.
            playerData.isOnline = isOnline
            playerData.isInGame = isOnline and FriendGroups_IsWowClient(client)
            playerData.isInOtherGame = isOnline and FriendGroups_IsOtherGameClient(client)
            -- The account/character tier, resolved here because buttonType no longer carries
            -- it on 12.1. Consumed by tier 3 of FriendGroups_SortTableByStatus.
            playerData.isTitleFriend = isTitleFriend

            -- [[ ALPHABETICAL SORT KEY ]] BattleTag or character name, lowercased. titleSortName wins for
            -- 12.1 title rows, whose identifier is a |K escape ("|" sorts after every letter).
            local sortName = charName
            if buttonType == FRIENDS_BUTTON_TYPE_BNET and accountIdentifier then
                sortName = titleSortName or accountIdentifier
            end

            -- [[ NICKNAME ELEVATION ]] Nicknamed friends sort first in their tier, by nickname.
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

-- [[ NAME MATCHING FOR 12.1 WoW-FRIEND ROWS ]] Their names are |K escapes Lua can't compare;
-- SearchFriends can. Unioned with our matcher, never intersected. Once per rebuild, never per
-- keystroke.
local FriendGroups_NameMatchSet = nil

-- Reported by /fg match so a failure says WHICH shape was tried.
local FriendGroups_NameMatchSource = "none"

local function FriendGroups_RebuildNameMatchSet()
    FriendGroups_NameMatchSet = nil
    FriendGroups_NameMatchSource = "none"
    if searchValue == "" then return end

    -- Only the view's own BuildActiveSearchInfo shape returns matches; a bare { searchText }
    -- comes back empty. Having a view does NOT mean the call is allowed (Forever has one and
    -- forbids it): Compat.SearchFriends decides that.
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
        local accountInfo = passedAccountInfo or Compat.GetFriendAccountInfo(playerId)
        if accountInfo then
            -- [[ ACCOUNT-LEVEL FIELDS ]] Read outside the session guard: offline title friends showed a
            -- name that couldn't be searched. Anything on screen must be matchable.
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

                local data = FriendGroups_GetRealmEntry(gameInfo)
                if data and data.region then
                    regionSearchText = data.region
                end
                -- Forever rows read "PvP", not the shard, so the words people type must match.
                if Compat.IsForeverGame(gameInfo) then
                    local code = Compat.ParseForeverShard(realmName) or Compat.ParseForeverPresence(richPresence)
                    regionSearchText = regionSearchText .. " " .. (L["FOREVER"] or "Forever")
                        .. " " .. (Compat.ForeverRulesetLabel(code) or "")
                end
            end
            
            -- [[ OFFLINE NAME RECOVERY ]] Fall back to the name recorded while online.
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
            -- Pipes doubled so chat prints the bytes, not the resolved name. gsub returns two values,
            -- hence the parentheses.
            tostring(searchLower), (tostring(bnetAccountName):gsub("|", "||")),
            (tostring(characterName):gsub("|", "||")),
            tostring(realmName), tostring(noteText)))

        -- Secret values print fine but fail string ops; this checks behaviour, not looks.
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

-- [[ WHISPER WITHOUT TAINTING CHAT ]] Opt-in (safe_whisper), retail and Forever. Only set the
-- chat box's chatType/tellTarget; the player's Enter opens it securely. Never call UpdateHeader,
-- OpenChat, ActivateChat, SetFocus, Show or Hide on a chat box from here.
local function FG_CanPrimeWhisper()
    return Compat.IS_RETAIL_UI
        and type(ChatFrameUtil) == "table"
        and type(ChatFrameUtil.ChooseBoxForSend) == "function"
        and type(ChatFrameUtil.GetActiveWindow) == "function"
        and type(ChatFrameUtil.GetChatFocusOverride) == "function"
end

-- The capability above plus the player's opt-in. Read live, so the checkbox takes effect
-- on the next menu or click without a reload.
local function FG_IsSafeWhisperOn()
    return FG_CanPrimeWhisper()
        and type(FriendGroups_SavedVars) == "table"
        and FriendGroups_SavedVars.safe_whisper == true
end

-- chatType is "WHISPER" or "BN_WHISPER" -- chat type identifiers, not display text.
-- accountInfo is optional and only feeds the streamer-mode mask.
local function FG_PrimeWhisper(chatType, target, accountInfo)
    -- SetAttribute refuses a secret argument from tainted code (SecretArguments =
    -- "AllowedWhenUntainted"), so a withheld name cannot be primed at all. Tested first:
    -- anything else done to a secret here would raise as well.
    if issecretvalue and issecretvalue(target) then
        print(L["MSG_WHISPER_UNAVAILABLE"])
        return
    end
    if type(target) ~= "string" or target == "" then return end

    -- An open box or a focus override takes the next Enter, so don't prime.
    if ChatFrameUtil.GetActiveWindow() ~= nil or ChatFrameUtil.GetChatFocusOverride() ~= nil then
        print(L["MSG_WHISPER_CLOSE_CHAT"])
        return
    end

    local editBox = ChatFrameUtil.ChooseBoxForSend()
    if not editBox then return end
    editBox:SetChatType(chatType)
    editBox:SetTellTarget(target)

    local shownName = target
    if FriendGroups_IsStreamerMode() then
        shownName = FriendGroups_StreamerName(target, accountInfo)
    end
    print(string.format(L["MSG_WHISPER_PRESS_ENTER"], shownName))
end

-- Mirrors UnitPopupWhisperButtonMixin:OnClick: the same Battle.net test, the same
-- human-unit gate and the same target, primed instead of sent.
local function FG_PrimeWhisperFromContext(contextData)
    local unit = contextData.unit
    if unit and not UnitIsHumanPlayer(unit) then return end

    local bnetIDAccount = contextData.bnetIDAccount
    local isBNetAccount = bnetIDAccount
    if not isBNetAccount and contextData.playerLocation then
        isBNetAccount = contextData.playerLocation:IsBattleNetGUID()
    end

    if isBNetAccount then
        local accountInfo
        if FriendGroups_IsStreamerMode() and type(bnetIDAccount) == "number"
           and not (issecretvalue and issecretvalue(bnetIDAccount)) then
            accountInfo = C_BattleNet.GetAccountInfoByID(bnetIDAccount)
        end
        FG_PrimeWhisper("BN_WHISPER", contextData.name, accountInfo)
    else
        local target = contextData.name
        if type(UnitPopupSharedUtil) == "table" and type(UnitPopupSharedUtil.GetFullPlayerName) == "function" then
            target = UnitPopupSharedUtil.GetFullPlayerName(contextData)
        end
        FG_PrimeWhisper("WHISPER", target, nil)
    end
end

-- Replaces the responder on Blizzard's own Whisper item in a menu opened from this list.
-- Found by its label, Blizzard's WHISPER string (UnitPopupWhisperButtonMixin:GetText);
-- if it is not there the menu is left exactly as Blizzard built it.
local function FG_ClaimWhisperButton(rootDescription, contextData)
    if not FG_IsSafeWhisperOn() then return end
    if type(WHISPER) ~= "string" then return end
    if type(MenuUtil) ~= "table" or type(MenuUtil.GetElementText) ~= "function" then return end
    if type(rootDescription.EnumerateElementDescriptions) ~= "function" then return end

    for _, elementDescription in rootDescription:EnumerateElementDescriptions() do
        local text = MenuUtil.GetElementText(elementDescription)
        if not (issecretvalue and issecretvalue(text)) and text == WHISPER then
            elementDescription:SetResponder(function()
                FG_PrimeWhisperFromContext(contextData)
            end)
            return
        end
    end
end

-- Replacement Send Message OnClick, installed when the setting is first on; off, it hands
-- every click to Blizzard's captured handler.
local FG_BlizzardSendMessageOnClick

local function FG_SendMessageButton_OnClick(self, ...)
    if not FG_IsSafeWhisperOn() then
        if FG_BlizzardSendMessageOnClick then
            FG_BlizzardSendMessageOnClick(self, ...)
        end
        return
    end

    local friendType = FriendsFrame.selectedFriendType
    local friendIndex = FriendsFrame.selectedFriend
    if type(friendIndex) ~= "number" then return end

    if friendType == FRIENDS_BUTTON_TYPE_WOW then
        local info = C_FriendList.GetFriendInfoByIndex(friendIndex)
        if info and info.name then
            FG_PrimeWhisper("WHISPER", info.name, nil)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end
    elseif friendType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = Compat.GetFriendAccountInfo(friendIndex)
        if accountInfo then
            FG_PrimeWhisper("BN_WHISPER", accountInfo.accountName, accountInfo)
        end
    end
end

-- Blizzard's handler reads FriendsFrame.selectedFriend, which our rows write. Installed once,
-- only after the player opts in.
FG_InstallSendMessageOverride = function()
    if FG_BlizzardSendMessageOnClick then return end
    if not FG_CanPrimeWhisper() or not FriendsFrameSendMessageButton then return end
    FG_BlizzardSendMessageOnClick = FriendsFrameSendMessageButton:GetScript("OnClick")
    FriendsFrameSendMessageButton:SetScript("OnClick", FG_SendMessageButton_OnClick)
end

-- For Sync.Apply: restoring safe_whisper must install the override too. Install-only.
addonTable.State.InstallSendMessageOverride = FG_InstallSendMessageOverride

-- Tick = your selected main (Select Main menu, panel header); person = online now. Both drawn
-- by FriendGroups/tools/make-status-icons.lua. The blank samples the tick's transparent corner.
local FG_SELECTED_MAIN_ICON = "Interface\\AddOns\\FriendGroups\\Textures\\selected_main.tga"
local FG_ONLINE_NOW_ICON = "Interface\\AddOns\\FriendGroups\\Textures\\online_now.tga"
local MENU_TICK = "|T" .. FG_SELECTED_MAIN_ICON .. ":14|t "
local MENU_TICK_BLANK = "|T" .. FG_SELECTED_MAIN_ICON .. ":14:14:0:0:32:32:0:1:0:1|t "

function FriendGroups_AddDropDownNew(ownerRegion, rootDescription, contextData)
    if not contextData then return end
    -- Only on the contact list (the tags fire elsewhere too), via Compat: FriendsListFrame is hidden on 12.1.
    if not Compat.IsContactListMouseOver() then
        return
    end

    -- Before any early return below, so Whisper is claimed even when the rest of the
    -- FriendGroups section cannot be built.
    FG_ClaimWhisperButton(rootDescription, contextData)

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

                -- Forever has no realm in a name: "/w First Last" is the whole address.
                if Compat.IsForeverGame(info.gameAccountInfo) then
                    textToCopy = char
                elseif realm and realm ~= "" and type(realm) == "string" then
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
            if Compat.IS_FOREVER and type(textToCopy) == "string" then
                textToCopy = strsplit("-", textToCopy)
            elseif textToCopy and textToCopy ~= "" and type(textToCopy) == "string" and not string.find(textToCopy, "-") then
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
            local selectedMainKey = FriendGroups_SavedVars.manual_mains and FriendGroups_SavedVars.manual_mains[accountIdentifier]
            local mainSubMenu = rootDescription:CreateButton(L["DROP_SELECT_MAIN"])
            local clearMain = mainSubMenu:CreateButton(MENU_TICK_BLANK .. L["DROP_CLEAR_MAIN"], function(data)
                if FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains then
                    FriendGroups_SavedVars.manual_mains[data.accountIdentifier] = nil
                    if FriendGroups_SavedVars.main_guild then
                        FriendGroups_SavedVars.main_guild[data.accountIdentifier] = nil
                    end
                    FriendGroups_FriendsListUpdate(true)
                end
            end, { accountIdentifier = accountIdentifier })
            clearMain:SetEnabled(selectedMainKey ~= nil)

            if FriendGroups_SavedVars.alt_cache and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
                local menuAlts = {}
                for _, altData in ipairs(FriendGroups_SavedVars.alt_cache[accountIdentifier]) do
                    table.insert(menuAlts, altData)
                end
                table.sort(menuAlts, function(a, b) return (a.charName or "") < (b.charName or "") end)

                for _, altData in ipairs(menuAlts) do
                    local engClass = Compat.ClassToken(altData.class) or ""
                    local colorCode = FriendGroups_GetClassColorCode(engClass ~= "" and engClass or altData.class)
                    local displayLabel = colorCode .. FriendGroups_AltDisplayName(altData) .. "|r"
                    if altData.realm == Compat.FOREVER_REALM then
                        displayLabel = displayLabel .. " (" .. Compat.ForeverLabel(altData.ruleset) .. ")"
                    end
                    local altUniqueKey = altData.charName .. "-" .. FriendGroups_CleanRealmName(altData.realm or "")
                    displayLabel = ((altUniqueKey == selectedMainKey) and MENU_TICK or MENU_TICK_BLANK) .. displayLabel

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

    -- The friend's MANUAL guild tags (<GuildName> in the note). These can be removed.
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

                    -- [[ ABSOLUTE DESTINATIONS ]] Any position in one menu open, via FriendGroups_MoveGroupToIndex
                    -- (insertion slots, owns the off-by-one). Hidden with only one movable group.
                    if moveIdx and moveCount > 1 then
                        local moveTo = rootDescription:CreateButton(L["MENU_MOVE_TO"])

                        local moveTopBtn = moveTo:CreateButton(L["MENU_MOVE_TOP"], function()
                            FriendGroups_MoveGroupToIndex(groupName, 1)
                        end)
                        if moveIdx <= 1 then moveTopBtn:SetEnabled(false) end

                        local moveBottomBtn = moveTo:CreateButton(L["MENU_MOVE_BOTTOM"], function()
                            FriendGroups_MoveGroupToIndex(groupName, moveCount + 1)
                        end)
                        if moveIdx >= moveCount then moveBottomBtn:SetEnabled(false) end

                        -- Skip the group's own slot and the one after it: both are no-ops.
                        local addedDivider = false
                        for slot = 1, moveCount do
                            if slot ~= moveIdx and slot ~= moveIdx + 1 then
                                if not addedDivider then
                                    moveTo:CreateDivider()
                                    addedDivider = true
                                end
                                local targetGroup = FriendGroups_MovableOrder[slot]
                                moveTo:CreateButton(
                                    string.format(L["MENU_MOVE_BEFORE"], FriendGroups_GroupDisplayName(targetGroup)),
                                    function()
                                        FriendGroups_MoveGroupToIndex(groupName, slot)
                                    end)
                            end
                        end

                        -- Type-guarded: the Platform_Menu polyfill has no SetScrollMode.
                        if type(moveTo.SetScrollMode) == "function" then
                            local FG_MENU_ROW_HEIGHT = 20
                            local FG_MENU_MAX_ROWS = 20
                            moveTo:SetScrollMode(FG_MENU_ROW_HEIGHT * FG_MENU_MAX_ROWS)
                        end
                    end

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
                    
                    -- [[ HEADER FONT COLOUR ]] Banners already imply white (FriendGroups_HeaderFontRGB); this is
                    -- for choosing a different colour.
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
                            
                            -- Live refresh here too: in combat the rebuild is queued, which would leave a white label on
                            -- no banner. Skipped while a font override owns the colour.
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
		local accountInfo = Compat.GetFriendAccountInfo(id)

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
		local accountInfo = Compat.GetFriendAccountInfo(id)

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

-- Nicknames live only in the note; empty input removes the tag. Too long for the note means
-- refused, never stored locally.
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

-- Same dual-key test as the tooltip and menu, so a pinned main survives the 10-alt trim.
function FriendGroups_IsManualMain(accountIdentifier, alt)
    if not accountIdentifier or type(alt) ~= "table" then return false end
    if not (FriendGroups_SavedVars and FriendGroups_SavedVars.manual_mains) then return false end
    local mainKey = FriendGroups_SavedVars.manual_mains[accountIdentifier]
    if not mainKey then return false end
    if alt.key == mainKey then return true end
    local computedKey = (alt.charName or "") .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")
    return computedKey == mainKey
end

-- [[ NICKNAME MIGRATION (SCHEMA 2) ]] Pre-13.0.1 nicknames must be pushed into notes before
-- reconcile runs, or it clears them. User-confirmed, rate-limited, drops what doesn't fit.

local FG_NICKNAME_SCHEMA = 2
local FG_MIGRATE_WRITE_INTERVAL = 0.2

FriendGroups_NicknameMigrationRunning = false

-- Identifier -> account id and note. Migration drops nicknames missing from the map, so
-- `trustworthy` is false if any friend failed to resolve, and the caller stands down.
local function FriendGroups_BuildBNetNoteMap()
    if not (C_BattleNet and C_BattleNet.GetFriendAccountInfo) then return nil, false end
    local total = Compat.GetBNetFriendNum()
    if total <= 0 then return nil, false end

    local map, trustworthy = {}, true
    for i = 1, total do
        local accountInfo = Compat.GetFriendAccountInfo(i)
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

-- Dry run: writes, drops, and already-correct count ("nothing to write" is normal: notes are
-- account-wide). Shared by the pre-check and the run.
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

-- Shared reload prompt (EUI skin, Classic own list); here because EllesmereSkin is retail-only.
StaticPopupDialogs["FRIENDGROUPS_RELOAD"] = {
    text = L["RELOAD_PROMPT"],
    button1 = YES,
    button2 = NO,
    OnAccept = function() ReloadUI() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Login reminder to carry the setup between retail and Forever: "export here" on retail,
-- "import here" on Forever. Our own frame, not a StaticPopup: it needs a checkbox, and
-- children added to Blizzard's shared popup frames outlive us.
local FG_ForeverTip

local FG_TIP_MODES = {
    forever = { text = "POPUP_FOREVER_IMPORT_TIP", off = "forever_import_tip_off" },
    retail = { text = "POPUP_RETAIL_EXPORT_TIP", off = "forever_export_tip_off" },
}

local function FG_TipMode()
    if Compat.IS_FOREVER then return FG_TIP_MODES.forever end
    if Compat.IS_MAINLINE then return FG_TIP_MODES.retail end
    return nil
end

local function FG_BuildForeverTip(mode)
    local f = CreateFrame("Frame", "FriendGroupsForeverTip", UIParent, "BackdropTemplate")
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetPoint("TOP", UIParent, "TOP", 0, -135)
    f:SetWidth(420)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    local text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    text:SetPoint("TOP", 0, -24)
    text:SetWidth(370)
    text:SetJustifyH("CENTER")
    text:SetText(string.format(L[mode.text], L["SETTINGS_PROFILE"], L["SETTINGS_EXPORT"], L["SETTINGS_IMPORT"]))

    local check = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    local label = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    label:SetText(L["POPUP_DONT_SHOW_AGAIN"])
    local rowWidth = 24 + 4 + label:GetStringWidth()
    check:SetPoint("TOPLEFT", text, "BOTTOM", -rowWidth / 2, -12)

    local ok = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    ok:SetSize(128, 22)
    ok:SetPoint("BOTTOM", 0, 18)
    ok:SetText(OKAY)
    ok:SetScript("OnClick", function()
        if check:GetChecked() and type(FriendGroups_SavedVars) == "table" then
            FriendGroups_SavedVars[mode.off] = true
        end
        f:Hide()
    end)

    f:SetHeight(24 + text:GetStringHeight() + 12 + 24 + 12 + 22 + 18)
    f.fgCheck = check
    f:Hide()
    return f
end

-- Every retail or Forever login until "Don't show this again" is ticked on that client.
function FriendGroups_ShowForeverImportTip()
    local mode = FG_TipMode()
    if not mode or type(FriendGroups_SavedVars) ~= "table" then return end
    if FriendGroups_SavedVars[mode.off] then return end
    FG_ForeverTip = FG_ForeverTip or FG_BuildForeverTip(mode)
    FG_ForeverTip.fgCheck:SetChecked(false)
    FG_ForeverTip:Show()
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

        -- Only prompt when there is something to write; already-migrated accounts adopt silently.
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
            show_guildmates = true,
            show_mobile_afk = false,
            add_mobile_text = true,       
            ingame_only = false,
            ingame_retail = false,
            show_retail = false,
            show_search = true,           
            hide_empty_groups = false,
            hide_afk = false,
            open_one_group = false,
            auto_accept_invite = true,
            auto_accept_friends_guild = false,
            auto_accept_sync = true,
            show_flags = true,
            offline_tracker = true,
            -- Off on a fresh install: a privacy mode that hides data by default would read as
            -- the addon being broken to everyone who is not streaming.
            streamer_mode = false,
            -- Off on a fresh install: Whisper opens chat in one click, as it always has.
            safe_whisper = false,
            -- The compartment is the way in; the minimap button is opt-in.
            show_compartment = true,
            show_minimap_button = false,
            -- Compatibility switch, not a preference: kept out of Reset to Default and Sync.lua
            -- so neither can put a Classic Raid tab back to being blocked in combat.
            classic_own_list = false,
            -- Medium height (not Large: an empty tall panel looks broken), Wide, Small text.
            -- Only a fresh install reads this table; Reset to Default must match it.
            extra_height = 190,
            wide_list = true,
            width_normal = false,
            font_size = 1,
        }
    end
	
    -- [[ DEFAULTS MIGRATION ]] Upgrades get font scale 2 (their current look); new installs get 1.
    if FriendGroups_SavedVars.font_size == nil then
        FriendGroups_SavedVars.font_size = 2
    end
    -- Created on upgrade too, so write sites need no nil guard.
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
    -- New in 13.0.51. Upgrades from 13.0.5 land here too, where priming was always on: they
    -- are returned to one-click Whisper like everyone else and can opt back in.
    if FriendGroups_SavedVars.safe_whisper == nil then
        FriendGroups_SavedVars.safe_whisper = false
    end
    if FriendGroups_SavedVars.show_compartment == nil then
        FriendGroups_SavedVars.show_compartment = true
    end
    if FriendGroups_SavedVars.show_minimap_button == nil then
        FriendGroups_SavedVars.show_minimap_button = false
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
	
    -- Global so the Social UI can nest it under the Battle.net bar menu. rootDescription may be a
    -- submenu; both expose the same Create* API.
    FriendGroups_BuildSettingsMenu = function(ownerRegion, rootDescription)
            -- submenu=true sections fly out; Filter/Appearance stay flat; after isAdvancedStart, Advanced.
            -- Version first at the root: via the Social UI hamburger nothing else names the addon.
            local fgVersion = C_AddOns and C_AddOns.GetAddOnMetadata
                and C_AddOns.GetAddOnMetadata(addonName, "Version")
            -- Menu titles are gold with no API to change it; a |cff span retints them.
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
                    -- Heading inside the submenu; isTitle would reset target to the root.
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
                    -- Checkboxes keep the menu or flyout open for live tweaking
                    local cb = target:CreateCheckbox(
                        item.text,
                        function() return item.checked() end,
                        function() item.func() end
                    )
                    if item.enabled and cb and cb.SetEnabled then
                        cb:SetEnabled(item.enabled)
                    end
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
	-- [[ SECURE LIST REFRESH ]] Post-hook, never overwrite FriendsList_Update: the overwrite tainted
	-- every secure read (12.2.2). Put our provider back in the same execution, then coalesce.
    hooksecurefunc("FriendsList_Update", function()
        -- ScrollBox-only: re-assert our grouped provider after Blizzard's native
        -- update briefly swaps in its flat one (no ScrollBox on Classic clients).
        if Compat.HAS_SCROLLBOX then FriendGroups_ReassertGroupedProvider() end
        -- Classic own-list: Blizzard's update re-derives Send Message's enabled state from
        -- its own selection, so put ours back in the same execution.
        if Compat.UseOwnClassicList() then Compat.UpdateClassicSendMessageButton() end
        FriendGroups_RequestListUpdate()
    end)

    -- [[ EVENT DIET ]] FriendsList_Update rebuilt everything on these events; the roster engine
    -- handles them instead. Registered once at OnLoad, never re-registered. ScrollBox clients only.
    if Compat.HAS_SCROLLBOX then
        FriendsFrame:UnregisterEvent("BN_FRIEND_INFO_CHANGED")
        FriendsFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
    end
    
    -- ScrollBox only; Classic renders through the HybridScrollFrame's .update.
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

    -- Arena-Safe Whispers: Send Message takes the priming path only for a player who has
    -- opted in. See WHISPER WITHOUT TAINTING CHAT.
    if FriendGroups_SavedVars.safe_whisper then
        FG_InstallSendMessageOverride()
    end

    -- Classic own-list: Blizzard's Send Message reads the selection fields this path
    -- deliberately stops writing, so the button follows FriendGroups' selection instead.
    -- Same chat calls Blizzard makes; see OWN-LIST SELECTION AND CLICKS in Platform_Render.
    if Compat.UseOwnClassicList() then
        Compat.InstallClassicSendMessageOverride()
    end

    -- 4. Setup Scroll View
    SetupGroupedView()
    
	-- [[ HEIGHT DEFAULT: 190 ]] Only very old upgrades reach this. `not`, not `== nil`: 0 is Small.
    if not FriendGroups_SavedVars.extra_height then
        FriendGroups_SavedVars.extra_height = 190
    end
    FriendGroups_UpdateSize()

    FriendGroups_UpdateContactCap()
    FriendGroups_FriendsListUpdate(true)
end

-- Ask Compat for the panel: FriendsFrame is hidden on 12.1, so its IsMouseOver is always false.
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

-- Re-size the Classic pool on show: its height is only right once the frame is visible.
local function FG_HookClassicSizeOnShow()
    if not FriendsFrame or FriendsFrame.fgOnShowHooked then return end
    FriendsFrame.fgOnShowHooked = true
    FriendsFrame:HookScript("OnShow", function()
        if FriendGroups_UpdateSize then FriendGroups_UpdateSize() end
    end)
end

-- Our own HybridScrollFrame on Classic; Blizzard's list is left alone and hidden, so every field
-- FriendsFrame_OnShow reads stays untainted.
local function FG_SetupOwnClassicList()
    local list = _G.FriendGroupsClassicList
    if not list then return end

    local native = FriendsFrameFriendsScrollFrame
    if native then
        native:Hide()
        -- Blizzard never calls Show() on that frame in the Classic source, so this is
        -- belt and braces rather than a known re-show. Hiding is pure widget state and
        -- carries no taint, so re-asserting it costs nothing.
        if FriendsListFrame and not native.fgOwnListHidden then
            native.fgOwnListHidden = true
            FriendsListFrame:HookScript("OnShow", function() native:Hide() end)
        end
    end

    -- -16/+16 = the caret heights, so the carets sit flush with the list.
    local bar = list.scrollBar
    if bar then
        bar:ClearAllPoints()
        bar:SetPoint("TOPLEFT", list, "TOPRIGHT", 0, -16)
        bar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT", 0, 16)

        -- Blizzard's own two tweaks from FriendsFrame_OnLoad: no track art, bar stays when short.
        if bar.trackBG then bar.trackBG:Hide() end
        bar.doNotHide = true
    end

    -- Our own pool: Blizzard built its eleven buttons in its OnLoad, ours starts empty.
    -- FriendGroups_UpdateSize tops it up again (deferred) once the frame has its final
    -- height, but the list has to be able to paint before that lands.
    if HybridScrollFrame_CreateButtons then
        HybridScrollFrame_CreateButtons(list, "FriendsFrameButtonTemplate")
    end

    -- Re-render the visible slice as the user scrolls; HybridScrollFrame_SetOffset calls
    -- this whenever the top element changes. Our frame, our field.
    list.update = FriendGroups_FriendsListUpdate
    list:Show()
end

SetupGroupedView = function()
    if not Compat.HAS_SCROLLBOX then
        if Compat.UseOwnClassicList() then
            FG_SetupOwnClassicList()
            FG_HookClassicSizeOnShow()
            return
        end
        -- Legacy Classic path: replace Blizzard's updater, or its dynamic-height state crashes
        -- HybridScrollFrame_SetOffset. Taints the Raid tab in combat (#55) until the own list is default.
        local scrollFrame = FriendsFrameFriendsScrollFrame
        if scrollFrame then
            -- Seat the native HybridScroll frame below our search box and fit it to
            -- the list area. FriendsListFrame exists on Classic (only its ScrollBox is
            -- absent), so anchor to it exactly as retail anchors its ScrollBox.
            scrollFrame:ClearAllPoints()
            scrollFrame:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 7, -115)
            scrollFrame:SetPoint("BOTTOMRIGHT", FriendsListFrame, "BOTTOMRIGHT", -28, 35)

            -- -16/+16 = the caret heights, so the carets sit flush with the list.
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

        FG_HookClassicSizeOnShow()
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
            -- Blizzard's own template. Its OnClick is Blizzard's, but it reads the button.id
            -- our initializer writes, so everything a click on this row starts runs under
            -- FriendGroups' taint. Chat is kept out of that by WHISPER WITHOUT TAINTING CHAT.
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
    return Compat.ClassToken(name)
end

-- Published for the platform renderers (file-local, so invisible to Platform_*.lua as a
-- global). The Social UI row builds its class icon from the token this resolves.
addonTable.State.ResolveClassToken = FriendGroups_ResolveClassToken

-- The cached alt record of the user's selected main for this contact, or nil.
-- Reads manual_mains directly: FriendGroups_ActiveAKA is only filled when show_guildmates is on.
local function FG_FindMainAlt(accountIdentifier)
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
        if currentKey == mainKey or alt.key == mainKey then return alt end
    end
    return nil
end

-- Selected main's class for an OFFLINE row (drawn greyed), or nil. Never the newest alt:
-- that would be a guess about a character the user never nominated.
function FriendGroups_LookupMainClass(accountIdentifier)
    local alt = FG_FindMainAlt(accountIdentifier)
    if alt and type(alt.class) == "string" and alt.class ~= "" then return alt.class end
    return nil
end

-- Project a cached alt was seen on; records predating the project field are nil unless Forever.
local function FG_AltProject(alt)
    local project = tonumber(alt.project)
    if project and project > 0 then return project end
    if alt.realm == Compat.FOREVER_REALM then return Compat.FOREVER_PROJECT end
    return nil
end

-- Whether a cached alt could be the character this live session is on. Without it a retail
-- main's class (Evoker) was drawn on a Forever session.
local function FG_AltFitsSession(alt, gameInfo)
    local altProject = FG_AltProject(alt)
    if Compat.IsForeverGame(gameInfo) then return altProject == Compat.FOREVER_PROJECT end
    if altProject == Compat.FOREVER_PROJECT then return false end
    if altProject == nil then return true end

    local pid = gameInfo and gameInfo.wowProjectID
    if issecretvalue and issecretvalue(pid) then pid = nil end
    if type(pid) == "number" and pid > 0 then return altProject == pid end

    local isClassic, source = Compat.ResolveFriendFlavor(gameInfo)
    if source == "default" or isClassic == nil then return true end
    local mainline = WOW_PROJECT_MAINLINE or 1
    if isClassic then return altProject ~= mainline end
    return altProject == mainline
end

-- Class for an ONLINE row whose session reports none (12.0.7 presence reduction). Returns
-- class, guessed: guessed is true unless the live character itself matched, and the row greys
-- the icon. Steps 2-3 only consider alts from the session's own game. Display-only.
function FriendGroups_LookupAccountClass(accountInfo, characterName, realmName)
    if not accountInfo then return nil end
    local key = FriendGroups_AccountIdentifier(accountInfo)
    if not key then return nil end

    local alts = FriendGroups_SavedVars and type(FriendGroups_SavedVars.alt_cache) == "table"
        and FriendGroups_SavedVars.alt_cache[key]
    local gameInfo = accountInfo.gameAccountInfo

    -- 1. Exact match on the live character (name known, other fields degraded).
    if type(characterName) == "string" and characterName ~= "" and type(alts) == "table" then
        if Compat.ParseForeverShard(realmName) then realmName = Compat.FOREVER_REALM end
        local cleanRealm = FriendGroups_CleanRealmName(realmName or "")
        for _, alt in ipairs(alts) do
            if alt.charName == characterName
                and (cleanRealm == "" or FriendGroups_CleanRealmName(alt.realm or "") == cleanRealm) then
                if type(alt.class) == "string" and alt.class ~= "" then return alt.class, false end
            end
        end
    end

    -- 2. Selected main, when it is from the game they are playing.
    local mainAlt = FG_FindMainAlt(key)
    if mainAlt and type(mainAlt.class) == "string" and mainAlt.class ~= ""
        and FG_AltFitsSession(mainAlt, gameInfo) then
        return mainAlt.class, true
    end

    -- 3. Most recently seen cached alt from that game.
    if type(alts) == "table" then
        local bestClass, bestTime
        for _, alt in ipairs(alts) do
            if type(alt.class) == "string" and alt.class ~= "" and FG_AltFitsSession(alt, gameInfo) then
                local t = tonumber(alt.timestamp) or 0
                if not bestClass or t > bestTime then
                    bestClass, bestTime = alt.class, t
                end
            end
        end
        if bestClass then return bestClass, true end
    end

    return nil
end

-- Row layout: class icon of the current character on the left across both rows, text indented,
-- status icon inline after the name. Re-run by the EUI skin after font changes.
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
        -- Always re-stated: pooled rows would otherwise keep a previous friend's grey.
        icon:SetDesaturated(button.fgClassGuessed and true or false)
        icon:SetAlpha(button.fgClassGuessed and 0.6 or 1)
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

-- [[ CHARACTER-FRIEND ROW PARITY ]] Faction from the friend GUID's race. Hits cached; misses
-- (usually offline) retried.
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

-- Blizzard's travel pass resolves the id against the BNet list, wrong for character rows.
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

    -- Blizzard's flat provider is swapped out again in the same execution; skip it.
    if FriendGroups_ActiveProvider and FriendsListFrame.ScrollBox:GetDataProvider() ~= FriendGroups_ActiveProvider then return end

	local id = elementData.id;
	local buttonType = elementData.buttonType;
	button.buttonType = buttonType;
	button.id = id;
	button.fgClass = nil;   -- current character's class (localized); set below when online
	button.fgClassGuessed = nil;
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
		-- Nil after a removal: the reasserted provider still holds the old indices
		-- until the queued rebuild runs.
		if not info then return end
		button.fgNote = info.notes;
		-- Same-realm friends have no "-Realm" suffix; line 2 falls back to our realm.
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
		local accountInfo = Compat.GetFriendAccountInfo(id);
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
            local classGuessed
            if client == BNET_CLIENT_WOW and accountInfo.gameAccountInfo
                and accountInfo.gameAccountInfo.isOnline and (not class or class == "") then
                class, classGuessed = FriendGroups_LookupAccountClass(accountInfo, characterName, realmName)
            end

			if FriendGroups_SavedVars.show_mobile_afk and client == 'BSAp' then statusTexture = FRIENDS_TEXTURE_AFK end

			nameText = FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag, timerunningSeasonID, realmName, accountInfo.gameAccountInfo)
			button.status:SetTexture(statusTexture);
            
            local isForeverFriend = Compat.IsForeverGame(accountInfo.gameAccountInfo)
            if isForeverFriend and (not factionName or factionName == "") then
                factionName = FriendGroups_ForeverFaction(accountInfo)
            end
            factionName = factionName or ""
			isCrossFactionInvite = factionName ~= "" and factionName ~= playerFactionGroup;
			inviteFaction = factionName;

			if accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
				button.fgClass = (client == BNET_CLIENT_WOW) and class or nil;
				button.fgClassGuessed = button.fgClass and classGuessed or nil;
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if isForeverFriend then
					-- Same "Zone - Forever Normal" line on every client.
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType,
						Compat.ForeverLocation(accountInfo.gameAccountInfo, FriendGroups_SavedVars.show_realm));
				elseif FriendGroups_ShowRichPresenceOnly(client, accountInfo.gameAccountInfo.wowProjectID, factionName, accountInfo.gameAccountInfo.realmID, accountInfo.gameAccountInfo.areaName) then
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName, realmName);
				end

				Compat.SetGameIcon(button.gameIcon, accountInfo.gameAccountInfo)
				-- Full brightness for every online game, other projects included.
				button.gameIcon:SetAlpha(1);

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
                    
                    local flagTexture, _ = FriendGroups_GetRealmInfo(accountInfo.gameAccountInfo, FriendGroups_AccountIdentifier(accountInfo))

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

		-- The template name width is fixed; widening the frame alone still truncates.
		-- Capture Blizzard's width once, then grow or restore it.
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
    return addonTable.Perf.Time("fg.rebuild", FriendGroups_FriendsListUpdateBody, forceUpdate)
end

function FriendGroups_FriendsListUpdateBody(forceUpdate)
    -- GUARD: Only run if Enabled and Visible
    if not FriendGroups_Loaded then return end

    if InCombatLockdown() then
        addonTable.Perf.Count("rebuild.combat")
        FriendGroups_UpdateQueued = true
        return
    end

    -- Visibility guard routed through Compat: on 12.1 FriendsListFrame still exists but is
    -- permanently hidden, so testing it directly would block every update on that client.
    if (not Compat.IsContactListShown() and not forceUpdate) then return end

    -- Default to forcing an update if called from internal menus, clicks, or settings
    if forceUpdate == nil then forceUpdate = true end

    local socialUI = Compat.IsSocialUIActive()

    -- The roster shortcut needs a grouped provider on screen; a combat-deferred first build has none.
    local rosterUnchanged = (not forceUpdate) and (not FriendGroups_RosterDirty)
    if socialUI and not Compat.HasSocialUIProvider() then
        rosterUnchanged = false
    end

    if rosterUnchanged then
        addonTable.Perf.Count("rebuild.unchanged")
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
    wipe(FriendGroups_OnlineByGame)
    wipe(FriendGroups_OnlineKeys)
    wipe(FriendGroups_OnlineGuidKeys)
    FriendGroups_OnlineTotal = 0

    -- Ask Blizzard which friends match the search term BY NAME, before the pass that tests
    -- every friend. Once per rebuild: FriendGroups_Search then reads the answer per friend.
    FriendGroups_RebuildNameMatchSet()

    -- Parse natively in a single linear pass & pass refs down
    local numBNetTotal = C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
    for i = 1, numBNetTotal do
        local accountInfo = Compat.GetFriendAccountInfo(i)
        if accountInfo then
            -- The one complete BNet enumeration: refresh nicknames here, before FriendGroups_SetGroups.
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

    -- Movable order of SHOWN groups only, so moves step over hidden empty groups.
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
            -- First sight seeds collapse: offline buckets start collapsed, others open. User owns it after.
            if FriendGroups_SavedVars.collapsed[groupName] == nil then
                FriendGroups_SavedVars.collapsed[groupName] = FriendGroups_IsOfflineGroup(groupName) and true or false
            end

            local div = FG_GetLayoutTable()
            div.buttonType = FRIENDS_BUTTON_TYPE_DIVIDER
            div.groupName = groupName
            table.insert(targetLayout, div)

            -- Social UI: always emit members; collapse is on the tree node.
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
        -- Before HAS_SCROLLBOX, which is still true on 12.1.
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

            -- [[ O(n) REBUILD ]] Fill a detached provider (no listeners), then one SetDataProvider.
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

    -- [[ CACHE PRUNE ]] Nil-ing keys during pairs() is safe. Full rebuilds only.
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

-- Forever character name -> region ("US"/"AU"/"EU"), learned from the alt cache. Names are
-- unique across a Forever region, so retail can flag a Forever friend it has seen there.
local FG_ForeverRegionByName = {}

-- Faction for a reduced Forever session (Blizzard sends none): the one faction all of the
-- account's known Forever characters share, else nil. Never a guess between two sides.
function FriendGroups_ForeverFaction(accountInfo)
    local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
    local cache = accountIdentifier and FriendGroups_SavedVars and FriendGroups_SavedVars.alt_cache
    local alts = type(cache) == "table" and cache[accountIdentifier]
    if type(alts) ~= "table" then return nil end
    local faction
    for _, alt in ipairs(alts) do
        if alt.realm == Compat.FOREVER_REALM and type(alt.faction) == "string" and alt.faction ~= "" then
            if faction and faction ~= alt.faction then return nil end
            faction = alt.faction
        end
    end
    return faction
end

-- Presence-reduced sessions name no character: fall back to the region of the account's
-- most recently seen Forever alt.
local function FG_ForeverAccountRegion(accountIdentifier)
    local cache = accountIdentifier and FriendGroups_SavedVars and FriendGroups_SavedVars.alt_cache
    local alts = type(cache) == "table" and cache[accountIdentifier]
    if type(alts) ~= "table" then return nil end
    local best, bestTime
    for _, alt in ipairs(alts) do
        if alt.realm == Compat.FOREVER_REALM and alt.region then
            local t = tonumber(alt.timestamp) or 0
            if not best or t > bestTime then best, bestTime = alt.region, t end
        end
    end
    return best
end

-- The single realm resolution path (table, realmName, rich presence), shared by realm flags
-- and the game-icon tint so they agree.
function FriendGroups_GetRealmEntry(gameAccountInfo, accountIdentifier)
    if not gameAccountInfo then return nil end

    -- Before the realm tables: a shard name is not a realm, and must not fall through.
    if Compat.IsForeverGame(gameAccountInfo) then
        local _, region = Compat.ForeverInfo(gameAccountInfo)
        if not region and type(gameAccountInfo.characterName) == "string" then
            region = FG_ForeverRegionByName[gameAccountInfo.characterName]
        end
        if not region then region = FG_ForeverAccountRegion(accountIdentifier) end
        return Compat.ForeverRealmEntry(region)
    end

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

function FriendGroups_GetRealmInfo(gameAccountInfo, accountIdentifier)
    local data = FriendGroups_GetRealmEntry(gameAccountInfo, accountIdentifier)
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
    -- Draggable-header contract, see Platform_Drag.lua. This frame comes out of the SAME
    -- pool the group headers use, so leaving the flag or the drag registration behind would
    -- make a blank row answer to a drag it can no longer resolve a group for.
    frame.fgIsHeader = nil
    Compat.DetachHeaderDrag(frame)
    if frame.name then frame.name:Hide() end
    if frame.info then frame.info:Hide() end
    if frame.collapseButton then frame.collapseButton:Hide() end
end

function FriendGroups_FriendsListUpdateDividerTemplate(frame, elementData)
    local groupName = elementData.groupName
    local groupOnline = groupsCount[groupName] and groupsCount[groupName]["Online"] or 0
    -- Denominator = raw group size (all members, unfiltered), not the filtered count.
    local groupTotal = groupsCount[groupName] and (groupsCount[groupName]["Raw"] or groupsCount[groupName]["Total"]) or 0

    -- Drag contract, re-stated every pass: pooled frames come back as non-headers.
    frame.fgIsHeader = nil
    Compat.AttachHeaderDrag(frame, groupName)

    if groupName and frame.name then
        frame.rawGroupName = groupName -- Store raw name for click handlers
        frame.fgIsHeader = true

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
        
        frame.name:SetText(FriendGroups_GroupDisplayName(groupName))

        -- Pooled label: always write a colour, and nil means restore the default captured on first use.
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
        -- LEFT, paired with RIGHT below, centres the label vertically at any header height.
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

                -- Locals: a call expands to multiple values only in the last argument position.
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

-- [[ TOOLTIP GROUP BANNERS ]] Pooled textures anchored to line fontstrings, placed after Show()
-- (hence two passes). Hidden on OnHide: GameTooltip is shared.
local FriendGroups_TooltipBanners = {}
local FriendGroups_TooltipBannerCount = 0
local FriendGroups_TooltipHeaders = {}   -- { line, font } per promoted header
local FriendGroups_TooltipGameIcons = {}
local FriendGroups_TooltipGameIconCount = 0
-- Inline blank the size of a game icon: reserves the gap the pooled icon texture sits in.
local FG_TOOLTIP_GAME_ICON_SIZE = 14
local FG_TOOLTIP_GAME_ICON_GAP = "|TInterface\\Common\\spacer:" .. FG_TOOLTIP_GAME_ICON_SIZE .. ":" .. FG_TOOLTIP_GAME_ICON_SIZE .. "|t"

-- Undo our styling of the shared tooltip, restoring the captured header font.
local function FriendGroups_ResetTooltipStyling()
    for i = 1, FriendGroups_TooltipBannerCount do
        FriendGroups_TooltipBanners[i]:Hide()
    end
    FriendGroups_TooltipBannerCount = 0

    for i = 1, FriendGroups_TooltipGameIconCount do
        FriendGroups_TooltipGameIcons[i]:Hide()
    end
    FriendGroups_TooltipGameIconCount = 0

    -- Newest first: a line promoted twice gets its original font back last.
    for i = #FriendGroups_TooltipHeaders, 1, -1 do
        local header = FriendGroups_TooltipHeaders[i]
        if header.font then header.line:SetFontObject(header.font) end
        FriendGroups_TooltipHeaders[i] = nil
    end
end

-- Promote a line to header size. SetFontObject resets the colour, so re-apply it.
local function FriendGroups_PromoteTooltipHeaderLine(lineIndex, r, g, b)
    local line = _G["GameTooltipTextLeft" .. lineIndex]
    -- No header font on this client: leave the line at its normal size rather than error.
    if not line or not GameTooltipHeaderText then return end
    FriendGroups_TooltipHeaders[#FriendGroups_TooltipHeaders + 1] = { line = line, font = line:GetFontObject() }
    line:SetFontObject(GameTooltipHeaderText)
    line:SetTextColor(r, g, b)
end

-- Places a game icon in the gap FG_TOOLTIP_GAME_ICON_GAP left at the start of the line.
local function FriendGroups_ShowTooltipGameIcon(lineIndex, bucket, info)
    local line = _G["GameTooltipTextLeft" .. lineIndex]
    if not line then return end

    FriendGroups_TooltipGameIconCount = FriendGroups_TooltipGameIconCount + 1
    local tex = FriendGroups_TooltipGameIcons[FriendGroups_TooltipGameIconCount]
    if not tex then
        tex = GameTooltip:CreateTexture(nil, "ARTWORK")
        tex:SetSize(FG_TOOLTIP_GAME_ICON_SIZE, FG_TOOLTIP_GAME_ICON_SIZE)
        FriendGroups_TooltipGameIcons[FriendGroups_TooltipGameIconCount] = tex
    end

    tex:ClearAllPoints()
    tex:SetPoint("LEFT", line, "LEFT", 0, 0)
    tex:SetTexCoord(0, 1, 0, 1)
    if bucket == "?" then
        tex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        tex:SetDesaturated(false)
        tex:SetVertexColor(1, 1, 1)
    elseif bucket == "App" then
        Compat.SetGameIcon(tex, { clientProgram = BNET_CLIENT_APP or "App" })
    else
        Compat.SetGameIcon(tex, info)
    end
    tex:Show()
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

        -- Global so both platforms raise the same tooltip. Min width reset on OnHide, because
        -- GameTooltip is shared and there are several callers.
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

            -- [[ TOTAL ONLINE FRIENDS ]] Gold for headers, labels and numbers, white prose, red only at cap.
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
                    local displayGroupName = FriendGroups_GroupDisplayName(groupName)
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

            -- [[ ONLINE BY GAME ]] Icons are placed after Show(), like the banners.
            local games = {}
            for bucket, entry in pairs(FriendGroups_OnlineByGame) do
                games[#games + 1] = { bucket = bucket, entry = entry, rank = Compat.GameBucketRank(bucket), label = Compat.GameLabel(bucket) }
            end
            table.sort(games, function(a, b)
                if a.rank ~= b.rank then return a.rank < b.rank end
                if a.entry.count ~= b.entry.count then return a.entry.count > b.entry.count end
                return (a.label or a.bucket) < (b.label or b.bucket)
            end)
            local pendingGameIcons = nil
            if #games > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["TOOLTIP_GAMES_TITLE"], aR, aG, aB)
                FriendGroups_PromoteTooltipHeaderLine(GameTooltip:NumLines(), aR, aG, aB)
                pendingGameIcons = {}
                for _, game in ipairs(games) do
                    local left = FG_TOOLTIP_GAME_ICON_GAP .. (game.label and (" " .. game.label) or "")
                    GameTooltip:AddDoubleLine(left, string.format(L["TEXT_ONLINE_COUNT"], game.entry.count), aR, aG, aB, aR, aG, aB)
                    pendingGameIcons[#pendingGameIcons + 1] = { line = GameTooltip:NumLines(), bucket = game.bucket, info = game.entry.info }
                end
            end

            GameTooltip:AddLine(" ")

            -- [[ CONTACT LIMITS ]]
            GameTooltip:AddLine(L["TOOLTIP_CONTACT_TITLE"], aR, aG, aB)
            FriendGroups_PromoteTooltipHeaderLine(GameTooltip:NumLines(), aR, aG, aB)
            -- No wrap: the string carries its own \n. Too long? Add another \n in the locale.
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
            if pendingGameIcons then
                for _, icon in ipairs(pendingGameIcons) do
                    FriendGroups_ShowTooltipGameIcon(icon.line, icon.bucket, icon.info)
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

    local inviteID, accountName = Compat.GetFriendInviteInfo(id)

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
        -- Nil on a fresh install: EnableFriendGroups owns the one fresh-defaults table.
        if FriendGroups_SavedVars then
            if FriendGroups_SavedVars.show_guildmates == nil then FriendGroups_SavedVars.show_guildmates = true end
            -- 12.2.2: the legacy list-refresh fallback was removed after the alpha; clear
            -- the orphaned saved variable so no tester stays silently on the old mode.
            FriendGroups_SavedVars.legacy_list_update = nil

            -- The alt cache has no time-based expiry; disabling tracking is what empties it.
            if FriendGroups_SavedVars.show_known_alts == false then
                if FriendGroups_SavedVars.alt_cache then wipe(FriendGroups_SavedVars.alt_cache) end
                if FriendGroups_SavedVars.guid_index then wipe(FriendGroups_SavedVars.guid_index) end
            end
            FriendGroups_NormalizeForeverAlts()
        end

        EnableFriendGroups()
        -- After EnableFriendGroups: a fresh install has no SavedVars until it runs.
        C_Timer.After(8, FriendGroups_ShowForeverImportTip)

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

-- [[ AUTOMATION LOGIC ]] Lives in Automation.lua.


-- ============================================================================
-- [[ KNOWN ALTS SPYGLASS ENGINE & STATIC PANEL ]]
-- ============================================================================

FriendGroups_SaveToAltCache = function(accountIdentifier, gameInfo)
    if FriendGroups_SavedVars and FriendGroups_SavedVars.show_known_alts == false then return end
    if not accountIdentifier or not gameInfo then return end
    if not gameInfo.isOnline or gameInfo.clientProgram ~= BNET_CLIENT_WOW then return end

    -- [[ FRESH-INSTALL GUARD ]] Can run before alt_cache exists.
    if not FriendGroups_SavedVars then return end
    if type(FriendGroups_SavedVars.alt_cache) ~= "table" then
        FriendGroups_SavedVars.alt_cache = {}
    end
    
    local charName = (type(gameInfo.characterName) == "string") and gameInfo.characterName or ""
    if charName == "" then return end
    
    local isForever = Compat.IsForeverGame(gameInfo)
    local ruleset, region, presenceZone
    local rawRealm
    if isForever then
        -- One key per Forever character whatever the shard; ruleset and region are display.
        rawRealm = Compat.FOREVER_REALM
        ruleset, region, presenceZone = Compat.ForeverInfo(gameInfo)
    else
        rawRealm = gameInfo.realmName
        if not rawRealm or rawRealm == "" then rawRealm = gameInfo.realmDisplayName end
        if (not rawRealm or rawRealm == "") and type(gameInfo.richPresence) == "string" then
            local extraction = gameInfo.richPresence:match("%s%-%s(.+)")
            if extraction then rawRealm = extraction end
        end
    end
    if not rawRealm or rawRealm == "" then return end

    local displayRealm = (type(rawRealm) == "string") and rawRealm or ""
    local normalizedRealm = FriendGroups_CleanRealmName(displayRealm)
    local uniqueKey = charName .. "-" .. normalizedRealm

    local class = (type(gameInfo.className) == "string") and gameInfo.className or ""
    local faction = (type(gameInfo.factionName) == "string") and gameInfo.factionName or ""
    local zone = (type(gameInfo.areaName) == "string") and gameInfo.areaName or presenceZone or L["UNKNOWN"]
    local level = tonumber(gameInfo.characterLevel) or 1
    local project = isForever and Compat.FOREVER_PROJECT or (gameInfo.wowProjectID or WOW_PROJECT_MAINLINE)
    if isForever and region then FG_ForeverRegionByName[charName] = region end

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
        if isForever then existingAlt.key = uniqueKey end
        -- Only ever filled in: retail knows the ruleset but not the region.
        if ruleset and existingAlt.ruleset ~= ruleset then existingAlt.ruleset = ruleset; dataChanged = true end
        if region and existingAlt.region ~= region then existingAlt.region = region; dataChanged = true end
        
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
            ruleset = ruleset,
            region = region,
            timestamp = time(),
            -- Pre-calculate and store search strings
            searchName = charName:lower(),
            searchRealm = displayRealm:lower(),
            searchClass = class:lower(),
            searchZone = zone:lower()
        })
        
        -- [[ RECENT-10 CAP ]] Drop the oldest non-main; a manual main is never evicted.
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

-- Older builds keyed one Forever character two ways: by shard (seen on Forever) and by
-- the rich-presence tail "PvP - Durotar" (seen on retail). Rewrites both to the single
-- Forever key and merges them. Runs at login and after every import.
local function FG_ForeverRecordInfo(alt)
    local realm = type(alt.realm) == "string" and alt.realm or ""
    local ruleset, region = Compat.ParseForeverShard(realm)
    if ruleset then return true, ruleset, region, nil end
    if alt.project ~= Compat.FOREVER_PROJECT and realm ~= Compat.FOREVER_REALM then return false end
    if realm == Compat.FOREVER_REALM or realm == "" then return true end
    local word, zone = realm:match("^(.-)%s%-%s(.+)$")
    return true, Compat.ForeverRulesetCode(word or realm), nil, zone
end

local function FG_MergeAlt(into, from)
    if (tonumber(from.timestamp) or 0) > (tonumber(into.timestamp) or 0) then
        into.level, into.zone, into.faction, into.timestamp = from.level, from.zone, from.faction, from.timestamp
    end
    if (not into.class or into.class == "") and from.class and from.class ~= "" then into.class = from.class end
    into.guild = into.guild or from.guild
    into.ruleset = into.ruleset or from.ruleset
    into.region = into.region or from.region
end

-- "Name-Realm", or just "First Last" for a Forever alt: Forever names carry no realm, and
-- its ruleset belongs on the "Last seen" line (FriendGroups_AltSeenPlace), never in colour.
function FriendGroups_AltDisplayName(alt)
    local name = alt.charName or ""
    if alt.realm == Compat.FOREVER_REALM then return name end
    return name .. ((alt.realm and alt.realm ~= "") and ("-" .. alt.realm) or "")
end

-- Where an alt was last seen: "Zone", or "Zone (Forever Normal)" for a Forever alt.
function FriendGroups_AltSeenPlace(alt)
    local zone = alt.zone or L["UNKNOWN_ZONE"] or ""
    if alt.realm ~= Compat.FOREVER_REALM then return zone end
    return zone .. " (" .. Compat.ForeverLabel(alt.ruleset) .. ")"
end

function FriendGroups_NormalizeForeverAlts()
    local sv = FriendGroups_SavedVars
    if type(sv) ~= "table" or type(sv.alt_cache) ~= "table" then return end
    local mains = type(sv.manual_mains) == "table" and sv.manual_mains or nil

    for account, list in pairs(sv.alt_cache) do
        if type(list) == "table" then
            local byKey = {}
            local i = 1
            while i <= #list do
                local alt = list[i]
                local isForever, ruleset, region, zone = false
                if type(alt) == "table" and type(alt.charName) == "string" and alt.charName ~= "" then
                    isForever, ruleset, region, zone = FG_ForeverRecordInfo(alt)
                end
                local merged = false
                if isForever then
                    local newKey = alt.charName .. "-" .. Compat.FOREVER_REALM
                    local oldComputed = alt.charName .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")
                    if mains and (mains[account] == alt.key or mains[account] == oldComputed) then
                        mains[account] = newKey
                    end
                    alt.key, alt.realm, alt.project = newKey, Compat.FOREVER_REALM, Compat.FOREVER_PROJECT
                    alt.ruleset = alt.ruleset or ruleset
                    alt.region = alt.region or region
                    if zone and (not alt.zone or alt.zone == "" or alt.zone == L["UNKNOWN"]) then alt.zone = zone end
                    alt.searchRealm = Compat.FOREVER_REALM:lower()
                    alt.searchZone = (alt.zone or ""):lower()
                    local first = byKey[newKey]
                    if first then
                        FG_MergeAlt(first, alt)
                        table.remove(list, i)
                        merged = true
                    else
                        byKey[newKey] = alt
                    end
                end
                if not merged then i = i + 1 end
            end
            for _, alt in pairs(byKey) do
                if alt.region then FG_ForeverRegionByName[alt.charName] = alt.region end
            end
        end
    end

    if type(sv.guid_index) == "table" then
        for _, entry in pairs(sv.guid_index) do
            if type(entry) == "table" and type(entry.charName) == "string"
                and Compat.ParseForeverShard(entry.realm) then
                entry.realm = Compat.FOREVER_REALM
                entry.key = entry.charName .. "-" .. Compat.FOREVER_REALM
            end
        end
    end
end

-- 2. The Silent Tracker (Catches background changes)
local FriendGroups_BNetIndexMap = {}

local function FriendGroups_UpdateBNetIndexMap()
    wipe(FriendGroups_BNetIndexMap)
    local numBNetTotal = C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
    for i = 1, numBNetTotal do
        local accountInfo = Compat.GetFriendAccountInfo(i)
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
    -- [[ COMBAT CHURN GUARD ]] Skip in combat; the next full rebuild re-caches every friend.
    if InCombatLockdown() then return end

    if not FriendGroups_SavedVars then return end
    if FriendGroups_SavedVars.show_known_alts == false then return end
    if type(FriendGroups_SavedVars.alt_cache) ~= "table" then FriendGroups_SavedVars.alt_cache = {} end

    local arg1 = ... 
    if not arg1 then return end
    
    -- Secure API Lookup by strict ID guarantees we never pull the wrong person's data
    local accountInfo = C_BattleNet.GetAccountInfoByID(arg1)
    if not accountInfo then 
        accountInfo = Compat.GetFriendAccountInfo(arg1) -- Legacy fallback just in case
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

-- File-locals, so Platform_* clears through here. On 12.1 a stale anchor (SocialUIFrame) docks
-- every game tooltip to the list.
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
        local info = Compat.GetFriendAccountInfo(i)
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

        -- A live Forever baseline still carries its shard; fold it into the stored key.
        local realm, ruleset, region = alt.realm, alt.ruleset, alt.region
        local shardRuleset, shardRegion = Compat.ParseForeverShard(realm)
        if shardRuleset then
            realm, ruleset, region = Compat.FOREVER_REALM, ruleset or shardRuleset, region or shardRegion
        end

        -- Force a universal, lowercase key to prevent case-sensitive splits
        local renderKey = string.lower(alt.charName .. "-" .. realm:gsub("[%s%p]+", ""))

        if not masterDict[renderKey] then
            masterDict[renderKey] = {
                key = renderKey, charName = alt.charName, realm = realm,
                class = alt.class, faction = alt.faction, level = alt.level,
                zone = alt.zone, guild = alt.guild, timestamp = alt.timestamp,
                ruleset = ruleset, region = region
            }
        else
            local existing = masterDict[renderKey]
            existing.ruleset = existing.ruleset or ruleset
            existing.region = existing.region or region

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

        -- Flagged after the shard fold above, so a live Forever record finds its stored entry.
        if alt.isLive then masterDict[renderKey].isLive = true end
    end

    -- 1. PULL FROM LOCAL BNET CACHE
    if accountIdentifier and FriendGroups_SavedVars.alt_cache and FriendGroups_SavedVars.alt_cache[accountIdentifier] then
        for _, alt in ipairs(FriendGroups_SavedVars.alt_cache[accountIdentifier]) do 
            MergeIntoMaster(alt) 
        end
    end

    -- 2. PULL FROM LIVE BASELINE DATA (plus any other multibox clients)
    if baselineData then
        MergeIntoMaster(baselineData)
        for _, extra in ipairs(baselineData.alsoLive or {}) do MergeIntoMaster(extra) end
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

        -- [[ IDENTITY BLOCK ]] BattleTag, nickname, guild (auto then manual), groups. The note's grammar
        -- is decoded, never printed.

        -- Falls back to the stashed hover note. Cleaned here, not per caller: callers pass raw or clean
        -- notes, and NoteForDisplay is idempotent.
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

        -- 3/4. GUILDS. Manual = <Name> tags; auto = the resolved guild group read from the assignment
        -- cache, never re-derived.
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
	
        -- [[ SECTIONS ]] Selected Main, then Online Now, then the rest by recency. A section
        -- header appears only when Selected Main or Online Now exists, else the plain list.
        local manualMainKey = (FriendGroups_SavedVars.manual_mains and accountIdentifier)
            and FriendGroups_SavedVars.manual_mains[accountIdentifier] or nil
        local function IsSelectedMain(alt)
            if not manualMainKey then return false end
            return alt.key == manualMainKey
                or (alt.charName .. "-" .. FriendGroups_CleanRealmName(alt.realm or "")) == manualMainKey
        end
        local function ByRecency(a, b)
            local timeA = a.timestamp or 0
            local timeB = b.timestamp or 0
            if timeA == timeB then
                if a.level == b.level then return a.charName < b.charName end
                return (a.level or 0) > (b.level or 0)
            end
            return timeA > timeB
        end

        local mainAlt, liveAlts, otherAlts = nil, {}, {}
        for _, alt in ipairs(alts) do
            if not mainAlt and IsSelectedMain(alt) then
                mainAlt = alt
            elseif alt.isLive then
                liveAlts[#liveAlts + 1] = alt
            else
                otherAlts[#otherAlts + 1] = alt
            end
        end
        table.sort(liveAlts, ByRecency)
        table.sort(otherAlts, ByRecency)

        local function TimeAgo(timestamp)
            if timestamp and timestamp <= 0 then return L["UNKNOWN"] end
            local diff = time() - (timestamp or time())
            if diff < 0 then diff = 0 end
            if diff < 60 then return L["TIME_JUST_NOW"] end
            local n, one, many
            if diff < 3600 then n, one, many = math.floor(diff / 60), "TIME_ONE_MINUTE_AGO", "TIME_MINUTES_AGO"
            elseif diff < 86400 then n, one, many = math.floor(diff / 3600), "TIME_ONE_HOUR_AGO", "TIME_HOURS_AGO"
            else n, one, many = math.floor(diff / 86400), "TIME_ONE_DAY_AGO", "TIME_DAYS_AGO" end
            if n == 1 then return L[one] end
            return string.format(L[many], n)
        end

        local MAIN_ICON = "|T" .. FG_SELECTED_MAIN_ICON .. ":16|t "
        local ONLINE_ICON = "|T" .. FG_ONLINE_NOW_ICON .. ":16|t "
        local rowCount = 0

        local function AddAltRow(alt, header)
            rowCount = rowCount + 1

            -- Half-height gap via a smaller FontObject; SetFont here would poison the shared font.
            FriendGroupsAltTooltip:AddLine(" ")
            local gapLine = _G["FriendGroupsAltTooltipTextLeft" .. FriendGroupsAltTooltip:NumLines()]
            if gapLine then gapLine:SetFontObject("SystemFont_Tiny") end

            if header then FriendGroupsAltTooltip:AddLine(header, aR, aG, aB, false) end

            local engClass = Compat.ClassToken(alt.class) or ""
            local classIconStr = Compat.ClassIconMarkup(engClass, 16)
            local nameColor = FriendGroups_GetClassColorCode(engClass ~= "" and engClass or alt.class)
            -- Masking drops the realm with the name: "Kiw***", never "Kiw***-Nobundo".
            local coloredName
            if FriendGroups_IsStreamerMode() then
                coloredName = nameColor .. FriendGroups_MaskName(alt.charName) .. "|r"
            else
                coloredName = nameColor .. FriendGroups_AltDisplayName(alt) .. "|r"
            end

            local factionPath = FriendGroups_GetFactionIcon(alt.faction)
            local factionIconStr = factionPath ~= "" and ("|T" .. factionPath .. ":16|t") or ""

            local line1 = string.format(L["TOOLTIP_ALTS_FORMAT"], classIconStr, coloredName, factionIconStr, alt.level)
            if alt.guild and alt.guild ~= "NONE" and alt.guild ~= "-" and alt.guild ~= "" then
                if L["TOOLTIP_ALTS_GUILD_SUFFIX"] then
                    line1 = line1 .. string.format(L["TOOLTIP_ALTS_GUILD_SUFFIX"], alt.guild)
                end
            end
            FriendGroupsAltTooltip:AddLine(line1, 1, 1, 1, false)

            if alt.isLive then
                FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_ALTS_ONLINE"], FriendGroups_AltSeenPlace(alt)), 1, 1, 1, false)
            else
                FriendGroupsAltTooltip:AddLine(string.format(L["TOOLTIP_ALTS_SEEN"], FriendGroups_AltSeenPlace(alt), TimeAgo(alt.timestamp)), 0.6, 0.6, 0.6, false)
            end
        end

        if mainAlt then AddAltRow(mainAlt, MAIN_ICON .. L["TOOLTIP_ALTS_SELECTED_MAIN"]) end
        for i, alt in ipairs(liveAlts) do
            AddAltRow(alt, (i == 1) and (ONLINE_ICON .. L["TOOLTIP_ALTS_ONLINE_NOW"]) or nil)
        end
        local sectioned = (mainAlt ~= nil) or (#liveAlts > 0)
        for i, alt in ipairs(otherAlts) do
            if rowCount >= 10 then break end
            AddAltRow(alt, (i == 1 and sectioned) and L["TOOLTIP_ALTS_OTHER"] or nil)
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

-- [[ NATIVE TOOLTIP DOCK / PARK ]] Panel shown: dock the native tooltip beneath it (flip up at
-- the screen bottom). Hidden, on rosters: park it where the panel would be.
-- FriendsFrame anchor means FriendsTooltip; anything else means GameTooltip.
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

-- [[ GUILD / COMMUNITIES DOCK ENFORCER ]] Others re-anchor GameTooltip on every Show, so re-dock
-- after each Show while a roster row is hovered. SetPoint doesn't trigger Show (no recursion).
hooksecurefunc(GameTooltip, "Show", function(self)
    if not FriendGroups_Loaded then return end
    if FriendGroups_SavedVars.show_known_alts == false then return end

    local anchor = FriendGroups_CurrentHoverAnchor
    if not anchor or anchor == FriendsFrame then return end

    -- [[ STALE-HOVER GUARD ]] Re-validate the anchor every Show: needs both IsShown and IsMouseOver.
    if type(anchor.IsShown) ~= "function" or not anchor:IsShown() then return end
    if type(anchor.IsMouseOver) == "function" and not anchor:IsMouseOver() then return end

    -- Re-applied after every Show.
    FriendGroups_DockNativeTooltipBelowPanel(anchor)
end)

-- [[ LIVE ALT RECORDS ]]
-- Record for the character a game account is on, or nil with no character. isLive stays off
-- unless the account reads online, so an offline friend's leftover name never shows as online.
local function FriendGroups_LiveAltRecord(gameAccountInfo)
    if not gameAccountInfo or (gameAccountInfo.characterName or "") == "" then return nil end
    local rawRealm = gameAccountInfo.realmName
    if not rawRealm or rawRealm == "" then rawRealm = gameAccountInfo.realmDisplayName end
    -- Retail never gets a Forever friend's realm name; the character is still current.
    local isForever = Compat.IsForeverGame(gameAccountInfo)
    if isForever then rawRealm = Compat.FOREVER_REALM end
    if not rawRealm or rawRealm == "" then return nil end

    local online = gameAccountInfo.isOnline
    if issecretvalue and issecretvalue(online) then online = nil end

    local cName = gameAccountInfo.characterName
    local record = {
        charName = cName,
        realm = rawRealm,
        class = gameAccountInfo.className or "",
        faction = gameAccountInfo.factionName or "",
        level = tonumber(gameAccountInfo.characterLevel) or 1,
        zone = gameAccountInfo.areaName or L["UNKNOWN_ZONE"],
        timestamp = time(),
        isLive = (online ~= false),
    }
    if isForever then
        record.ruleset, record.region = Compat.ForeverInfo(gameAccountInfo)
    end
    local rName = isForever and Compat.FOREVER_REALM or (rawRealm:gsub("[%s%p]+", ""))
    return record, cName .. "-" .. rName
end

-- Saves every game account on a BNet friend to the alt cache and returns the hovered
-- character's live record (other multibox clients ride in .alsoLive) and its key.
local function FriendGroups_BNetHoverBaseline(friendIndex, accountInfo, accountIdentifier)
    FriendGroups_SaveToAltCache(accountIdentifier, accountInfo.gameAccountInfo)
    local baseline, charKey = FriendGroups_LiveAltRecord(accountInfo.gameAccountInfo)

    if C_BattleNet.GetFriendNumGameAccounts then
        local numAccounts = C_BattleNet.GetFriendNumGameAccounts(friendIndex)
        if numAccounts and numAccounts > 1 then
            for i = 1, numAccounts do
                local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, i)
                if gameAccountInfo then
                    FriendGroups_SaveToAltCache(accountIdentifier, gameAccountInfo)
                    local extra = baseline and FriendGroups_LiveAltRecord(gameAccountInfo)
                    if extra and extra.isLive then
                        baseline.alsoLive = baseline.alsoLive or {}
                        table.insert(baseline.alsoLive, extra)
                    end
                end
            end
        end
    end
    return baseline, charKey
end

-- [[ DIRECT BUTTON HANDLER ]]
function FriendGroups_ShowButtonAltTooltip(button)
    if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then FriendGroupsAltTooltip:Hide() return end

    -- [[ STREAMER MODE ]] Hide only Blizzard's panel (it shows everything, unmaskable); our masked
    -- alt panel stays. Every contact-row hover reaches this function.
    if FriendGroups_IsStreamerMode() then
        if GameTooltip then GameTooltip:Hide() end
        if FriendsTooltip then FriendsTooltip:Hide() end
    end

    if not button or not button.id then return end

    -- Contact window: SocialUIFrame on 12.1 (selects GameTooltip), else FriendsFrame.
    FriendGroups_CurrentHoverAnchor = Compat.GetContactListAnchor()
    FriendGroups_CurrentHoverBNetID = nil
    FriendGroups_CurrentHoverCharKey = nil

    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = Compat.GetFriendAccountInfo(button.id)
        if not accountInfo then return end

        local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
        if not accountIdentifier then return end

        local baselineData, liveKey = FriendGroups_BNetHoverBaseline(button.id, accountInfo, accountIdentifier)
        FriendGroups_CurrentHoverBNetID = accountIdentifier
        FriendGroups_CurrentHoverCharKey = liveKey

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

    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = Compat.GetFriendAccountInfo(button.id)
        if not accountInfo then return end

        local accountIdentifier = FriendGroups_AccountIdentifier(accountInfo)
        if not accountIdentifier then return end

        local baselineData, liveKey = FriendGroups_BNetHoverBaseline(button.id, accountInfo, accountIdentifier)
        FriendGroups_CurrentHoverBNetID = accountIdentifier
        FriendGroups_CurrentHoverCharKey = liveKey

        FriendGroups_DrawAltTooltip(FriendGroups_CurrentHoverAnchor or FriendsFrame, FriendGroups_CurrentHoverBNetID, FriendGroups_CurrentHoverCharKey, baselineData)
    end
end)

FriendsFrame:HookScript("OnHide", function()
    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
    FriendGroups_CurrentHoverAnchor = nil
end)

-- In game per the roster's ClubMemberPresence: true, false, or nil when unreadable, which
-- keeps the old behaviour. OnlineMobile is the chat app, not the game. /fgprobe roster checks it.
local function FG_RosterInGame(memberInfo)
    local presence = memberInfo.presence
    local P = Enum and Enum.ClubMemberPresence
    if presence == nil or not P or (issecretvalue and issecretvalue(presence)) then return nil end
    return presence == P.Online or presence == P.Away or presence == P.Busy
end

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

    -- Offline members get timestamp 0 so the roster's stale zone never reads as "Just now".
    local inGame = FG_RosterInGame(memberInfo)

    local guid = memberInfo.guid
    local guidReadable = (guid ~= nil) and not (issecretvalue and issecretvalue(guid))
    local nameSecret = (issecretvalue and issecretvalue(memberInfo.name)) and true or false

    -- [[ SECRET PATH ]] The roster name is secret here: never read it. Resolve via the GUID index.
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
                timestamp = (inGame == false) and 0 or time(),
                isLive    = (inGame == true),
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
    -- Forever names never contain a hyphen; the suffix, if any, is a hidden shard.
    if Compat.IS_FOREVER then
        cName = strsplit("-", rawName)
        rName = Compat.FOREVER_REALM
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
        timestamp = (inGame == false) and 0 or time(),
        isLive = (inGame == true),
    }

    -- [[ GUID-INDEX HARVEST ]] Plain snapshot by GUID for later secret-context hovers (BNet owners only).
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

    -- [[ BNET-ONLY GATE ]] No BNet owner, no alt panel.
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
        -- [[ FLAVOR REPORT ]] /fg proj [name]: project, realm fields, rich presence, verdict and tier.
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
        -- [[ TITLE-FRIEND FIELD CENSUS ]] Each field as plain, nil or SECRET, legacy columns included.
        -- Here, not /run: the edit box truncates at 255 characters.
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
        -- [[ CUSTOM TITLE-FRIEND NAME PROBE ]] Raw with pipes doubled and byte lengths: a |K escape
        -- prints as the real name otherwise.
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
        -- [[ ROW FONT PROBE ]] Per row: the file the name uses now, and the file its own font
        -- object picks for the same text. Samples show what each script resolves to, on a shown
        -- and a hidden string. Battle.net names are |K escapes, so GetText reads ASCII.
        local function FileOf(path)
            return type(path) == "string" and (path:match("[^\/]+$") or path) or tostring(path)
        end

        local function Resolve(parent, object, text)
            if not (parent and object and parent.CreateFontString) then return "n/a" end
            parent.fgFontProbe = parent.fgFontProbe or parent:CreateFontString(nil, "OVERLAY")
            local fs = parent.fgFontProbe
            fs:SetAlpha(0)
            fs:SetFontObject(object)
            fs:SetText(text)
            local path = fs:GetFont()
            fs:SetText("")
            return FileOf(path)
        end

        local SAMPLES = {
            { "ascii", "Abc" }, { "latin", "\195\184\195\169" }, { "cyrillic", "\208\150\208\190" },
            { "hangul", "\234\176\128" }, { "cjk", "\228\184\173" },
        }
        local hidden = _G["FriendGroups_FontProbeFrame"] or CreateFrame("Frame", "FriendGroups_FontProbeFrame", UIParent)
        hidden:Hide()

        -- Kept in SavedVariables too, so the output survives a reload. Replaced on every run.
        local saved = {}
        FriendGroups_SavedVars.font_probe = saved
        local function Say(msg)
            DEFAULT_CHAT_FRAME:AddMessage(msg)
            saved[#saved + 1] = (msg:gsub("|", "||"))
        end
        Say("FriendGroups row font probe (name, live file, object's file):")
        local rows, sampled = 0, false
        Compat.ForEachContactListFrame(function(frame)
            if type(frame) ~= "table" then return end
            local nameString = frame.FriendName or frame.name
            local raw = nameString and nameString:GetText()
            if type(raw) ~= "string" or raw == "" then return end
            local base = frame.fgBaseFont and frame.fgBaseFont["FriendName"]
            local object = (base and base.object)
                or (type(nameString.GetFontObject) == "function" and nameString:GetFontObject()) or nil
            if not sampled and object then
                sampled = true
                local objName = type(object.GetName) == "function" and object:GetName() or "?"
                Say("  object " .. tostring(objName))
                for _, s in ipairs(SAMPLES) do
                    Say(string.format("  sample %s: shown=%s hidden=%s",
                        s[1], Resolve(frame, object, s[2]), Resolve(hidden, object, s[2])))
                end
            end
            rows = rows + 1
            local tag = (raw:find("|K", 1, true) and "K" or "") .. (raw:find("[\128-\255]") and "8" or "")
            Say(string.format("  [%s] %s|r  live=%s  object=%s",
                tag, raw, FileOf((nameString:GetFont())), Resolve(frame, object, raw)))
        end)
        Say(string.format("%d rows. K = Battle.net ||K name, 8 = non-ASCII text. Saved; /reload to write it.", rows))
    elseif command == "bar" then
        -- [[ BATTLE.NET BAR TREE ]] Recovers parentKeys by scanning each parent's fields.
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
        -- [[ OFFLINE-TRACKER CENSUS ]] Which bucket each offline contact lands in, and why
        -- (lastOnlineTime 0 = title friend).
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
        -- [[ MATCHER PROBE ]] /fg match <text>: FriendGroups_Search verdict per friend. YES but missing =
        -- downstream drop; NO = predicate. Restores the search text afterwards.
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

            -- Prefer title friends; when the tier is absent, walk everyone (same output cap).
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
                    -- bnetAccountID: the |K escape is probably session-scoped.
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
    elseif command == "perf" then
        addonTable.Perf.Slash(msg:match("^%s*%w+%s*(.-)%s*$"))
    else
        DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_HELP"])
    end
end

addonTable.Perf.AddContext(function()
    local sv = type(FriendGroups_SavedVars) == "table" and FriendGroups_SavedVars or {}
    local collapsed = 0
    if type(sv.collapsed) == "table" then
        for _, v in pairs(sv.collapsed) do
            if v then collapsed = collapsed + 1 end
        end
    end
    return string.format("Settings: font step %s, note %s, class icons %s, hide offline %s, collapsed groups %d",
        tostring(FriendGroups_GetFontScale()), tostring(sv.show_note), tostring(sv.show_class_icons),
        tostring(sv.hide_offline), collapsed)
end)

-- [[ OPEN-LIST UPDATE COALESCER ]] / [[ GROUPED PROVIDER RE-ASSERT ]] Put the grouped provider
-- back in the same execution after Blizzard's FriendsList_Update installs its flat one.
function FriendGroups_ReassertGroupedProvider()
    if not FriendGroups_Loaded then return end
    if not (FriendsListFrame and FriendsListFrame.ScrollBox) then return end
    if not FriendGroups_ActiveProvider then return end
    if FriendsListFrame.ScrollBox:GetDataProvider() == FriendGroups_ActiveProvider then return end
    FriendsListFrame.ScrollBox:SetDataProvider(FriendGroups_ActiveProvider, true)
end

-- Via State: FriendGroups_FriendsListUpdate is a file-local.
addonTable.State.FriendsListUpdate = function(forceUpdate)
    return FriendGroups_FriendsListUpdate(forceUpdate)
end

local FriendGroups_UpdateThrottleTimer = nil
function FriendGroups_RequestListUpdate()
    -- Same reason as the guard in FriendGroups_FriendsListUpdate: on 12.1 the list the
    -- player is looking at is not FriendsListFrame, which is present but never shown.
    if not Compat.IsContactListShown() then return end
    addonTable.Perf.Count("request")
    if FriendGroups_UpdateThrottleTimer then return end
    addonTable.Perf.Count("request.timer")
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

