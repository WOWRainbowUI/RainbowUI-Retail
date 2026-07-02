--[[
	FriendGroups - FULL ORIGINAL CODE + SECURE ARCHITECTURE
    - Uses the exact original logic for groups, menus, and sorting.
    - Adds "Lazy Loading" to prevent VisitHouse() taint.
    - Adds Safety Shield to the House List.
]] --
local addonName, addonTable = ...
local L = addonTable.L or {}

-- [[ STATE MANAGEMENT ]] --
local FriendGroups_Loaded = false 

-- ============================================================================
-- [[ DIRTY ROSTER ENGINE (IDLE GC CHURN PREVENTER) ]]
-- ============================================================================
local FriendGroups_RosterDirty = true
local fgRosterEventFrame = CreateFrame("Frame")
fgRosterEventFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED")
fgRosterEventFrame:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
fgRosterEventFrame:RegisterEvent("BN_FRIEND_INVITE_ADDED")
fgRosterEventFrame:RegisterEvent("BN_FRIEND_INVITE_REMOVED")
fgRosterEventFrame:RegisterEvent("FRIENDLIST_UPDATE")
fgRosterEventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
fgRosterEventFrame:SetScript("OnEvent", function(self, event, ...)
    FriendGroups_RosterDirty = true
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

local playerRealmID = GetRealmID();
local playerFactionGroup = UnitFactionGroup("player");
local INVITE_RESTRICTION_NONE = 9
local groupsTotal = {}
local groupsSorted = {}
local groupsCount = {}
local expansionMaxLevel = {}
local searchBoxInit = false
local currentExpansionMaxLevel, FriendGroups_Menu, FriendGroupsFrame, searchOpened
local searchValue = ""
local FriendGroups_SearchBox

-- Data for the Custom Menu
local FriendGroups_ClickedData = {}

local settingsMenuItems = {
    -- SECTION 0: SIZE
    { text = L["SETTINGS_SIZE"], notCheckable = true, isTitle = true, submenu = true },
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
    { text = "", isTitle = true },
    {
        text = L["SET_WIDTH_NARROW"],
        checked = function() return not FriendGroups_SavedVars.wide_list end,
        func = function()
            FriendGroups_SavedVars.wide_list = false
            FriendGroups_UpdateSize()
            FriendGroups_FriendsListUpdate(true)
        end
    },
    {
        text = L["SET_WIDTH_WIDE"],
        checked = function() return FriendGroups_SavedVars.wide_list end,
        func = function()
            FriendGroups_SavedVars.wide_list = true
            FriendGroups_UpdateSize()
            FriendGroups_FriendsListUpdate(true)
        end
    },

    -- SECTION 1: FILTERS
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
        text = L["SET_RETAIL_ONLY"],
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
        text = L["SET_SHOW_FLAGS"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_flags end,
        func = function()
            FriendGroups_SavedVars.show_flags = not FriendGroups_SavedVars.show_flags
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
        text = L["SET_CLASS_COLOR"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.colour_classes end,
        func = function()
            FriendGroups_SavedVars.colour_classes = not FriendGroups_SavedVars.colour_classes
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
        text = L["SET_GRAY_FACTION"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.gray_faction end,
        func = function()
            FriendGroups_SavedVars.gray_faction = not FriendGroups_SavedVars.gray_faction
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_SHOW_BTAG"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.show_btag end,
        func = function()
            FriendGroups_SavedVars.show_btag = not FriendGroups_SavedVars.show_btag
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
    { text = L["SET_SPIRIT_HEADER"], notCheckable = true, isTitle = true },
    {
        text = L["SET_SPIRIT_RES"],
        leftPadding = 16,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_accept_res end,
        func = function()
            FriendGroups_SavedVars.auto_accept_res = not FriendGroups_SavedVars.auto_accept_res
            if FriendGroups_SavedVars.auto_accept_res then
                FriendGroups_SavedVars.auto_release = false -- Prevent conflicts
            end
            FriendGroups_FriendsListUpdate()
        end
    },
    {
        text = L["SET_SPIRIT_RELEASE"],
        leftPadding = 16,
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_release end,
        func = function()
            FriendGroups_SavedVars.auto_release = not FriendGroups_SavedVars.auto_release
            if FriendGroups_SavedVars.auto_release then
                FriendGroups_SavedVars.auto_accept_res = false -- Prevent conflicts
            end
            FriendGroups_FriendsListUpdate()
        end
    },
    
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
    {
        text = L["SETTINGS_EXPORT"],
        notCheckable = true,
        tooltip = { L["TOOLTIP_EXPORT_1"], L["TOOLTIP_EXPORT_2"] },
        func = function() FriendGroups_ShowExport() end
    },
    {
        text = L["SETTINGS_IMPORT"],
        notCheckable = true,
        tooltip = { L["TOOLTIP_IMPORT_1"], L["TOOLTIP_IMPORT_2"] },
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
            FriendGroups_SavedVars.show_faction_icons = true
            FriendGroups_SavedVars.show_realm = true
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
            FriendGroups_SavedVars.auto_accept_res = false
            FriendGroups_SavedVars.auto_release = false
            FriendGroups_SavedVars.offline_tracker = true
            FriendGroups_SavedVars.show_known_alts = true
            FriendGroups_SavedVars.extra_height = 380
            FriendGroups_SavedVars.wide_list = false
            FriendGroups_SavedVars.collapsed = {}
            FriendGroups_SavedVars.group_order = {}
            
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

currentExpansionMaxLevel = GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion() or GetMaxLevelForExpansionLevel and GetMaxLevelForExpansionLevel(GetExpansionLevel()) or 80

-- ============================================================================
-- [[ GUILD CACHE ENGINE (OPTIMIZED: LAZY HEARTBEAT & FINGERPRINTING) ]]
-- ============================================================================
local FriendGroups_GuildCacheDirty = true
local FriendGroups_PlayerGuildName = ""
local FriendGroups_LiveGuildSessionDict = {} -- [[ NEW: Fast O(1) Memory-Safe Lookup ]]

local fgGuildEventFrame = CreateFrame("Frame")
fgGuildEventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
fgGuildEventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
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
    local extraWidth = FriendGroups_SavedVars.wide_list and FriendGroups_WideListExtra or 0

    -- 3. Apply
    FriendsFrame:SetHeight(FriendGroups_OriginalHeight + extra)
    FriendsListFrame:SetHeight(FriendGroupsList_OriginalHeight + extra)
    FriendsFrame:SetWidth(FriendGroups_OriginalWidth + extraWidth)
    FriendsListFrame:SetWidth(FriendGroupsList_OriginalWidth + extraWidth)

    -- 4. Re-anchor ScrollBox to fill the new space
    FriendsListFrame.ScrollBox:ClearAllPoints()
    FriendsListFrame.ScrollBox:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 7, -115)
    FriendsListFrame.ScrollBox:SetPoint("BOTTOMRIGHT", FriendsListFrame, "BOTTOMRIGHT", -28, 35)
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
                    
                    -- Strictly verify they are online and playing Retail WoW to prevent silent API fails
                    if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW and gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE then
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
                        C_PartyInfo.InviteUnit(charName)
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

function FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag, timerunningSeasonID, realmName)
	local nameText

	-- set up player name and character name
	local accountIdentifier = battleTag or accountName
	if FriendGroups_SavedVars and FriendGroups_SavedVars.nicknames and accountIdentifier and FriendGroups_SavedVars.nicknames[accountIdentifier] then
		nameText = "|cFF00FF00" .. FriendGroups_SavedVars.nicknames[accountIdentifier] .. "|r"
	elseif accountName then
		if FriendGroups_SavedVars.show_btag and battleTag then
			nameText = FriendGroups_SplitBattleTag(battleTag)
		else
			nameText = accountName
		end
	else
		nameText = UNKNOWN
	end

	-- append character name
	if characterName then
		if timerunningSeasonID then
			characterName = TimerunningUtil.AddSmallIcon(characterName)
		end

		local levelSuffix
		if (not level) or (FriendGroups_SavedVars.hide_high_level and level == currentExpansionMaxLevel) or level == 0 then
			levelSuffix = ""
		else
			levelSuffix = " " .. level
		end

        -- [[ NEW: Separate AKA string generation (Outside of Suffix Brackets) ]]
        local akaText = ""
        local accountIdentifier = battleTag or accountName
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
                local akaFormattedName = "[" .. akaInfo.name .. "]"
                
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
					nameText = "|CFF949694" .. nameText .. " [" .. characterName .. "]" .. levelSuffix .. "|r"
				elseif FriendGroups_SavedVars.colour_classes then
					local nameColor = FriendGroups_GetClassColorCode(class)
					nameText = nameText .. " " .. nameColor .. "[" .. characterName .. "]" .. FONT_COLOR_CODE_CLOSE .. levelSuffix
				else
					nameText = nameText .. " [" .. characterName .. "]" .. FONT_COLOR_CODE_CLOSE .. levelSuffix
				end
			end
		else
			if ENABLE_COLORBLIND_MODE == "1" then
				characterName = characterName
			end
			nameText = nameText .. " " .. FRIENDS_OTHER_NAME_COLOR_CODE .. "[" .. characterName .. "]" .. FONT_COLOR_CODE_CLOSE .. levelSuffix
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

			canCoop = CanCooperateWithGameAccount(accountInfo)
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

	-- 2. Battle.net friends before WoW (in-game) friends within the same tier
	local typeA = (playerA.buttonType == FRIENDS_BUTTON_TYPE_BNET) and 1 or 2
	local typeB = (playerB.buttonType == FRIENDS_BUTTON_TYPE_BNET) and 1 or 2
	if typeA ~= typeB then
		return typeA < typeB
	end

	-- 3. Alphabetical by display name
	local nameA = playerA.sortName or ""
	local nameB = playerB.sortName or ""
	if nameA ~= nameB then
		return nameA < nameB
	end

	-- 4. Deterministic backstop (unique per friend within the same tier/type)
	return (playerA.id or 0) < (playerB.id or 0)
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
		or groupName == L["GROUP_OFFLINE_1"]
		or groupName == L["GROUP_OFFLINE_2"]
		or groupName == L["GROUP_OFFLINE_3"]
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

function FriendGroups_SetGroups(id, buttonType, passedAccountInfo)
    local noteText = ""
    local statusText = "Offline"
    local favorite = false
    local charName, client, isOnline, isRetail, accountIdentifier = "", "", false, false, nil
    local altCacheCount = 0

    -- Inline state resolution to completely bypass redundant API table allocations
    if buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local friendAccountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(id)
        if friendAccountInfo then
            noteText = friendAccountInfo.note or ""
            favorite = friendAccountInfo.isFavorite
            accountIdentifier = friendAccountInfo.battleTag or friendAccountInfo.accountName

            local gameAccountInfo = friendAccountInfo.gameAccountInfo
            if gameAccountInfo then
                isOnline = gameAccountInfo.isOnline
                client = gameAccountInfo.clientProgram
                isRetail = (gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE)
                charName = (type(gameAccountInfo.characterName) == "string") and gameAccountInfo.characterName or ""

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
        end
    elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = passedAccountInfo or C_FriendList.GetFriendInfoByIndex(id)
        if info then
            noteText = info.notes or ""
            isOnline = info.connected
            client = BNET_CLIENT_WOW
            charName = (type(info.name) == "string") and info.name or ""

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

        if FriendGroups_SavedVars.offline_tracker and buttonType == FRIENDS_BUTTON_TYPE_BNET and statusText == "Offline" then
            local friendAccountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(id)
            if friendAccountInfo and friendAccountInfo.lastOnlineTime and friendAccountInfo.lastOnlineTime > 0 then
                local daysOffline = (time() - friendAccountInfo.lastOnlineTime) / 86400
                if daysOffline >= 90 then table.insert(resolvedGroups, L["GROUP_OFFLINE_3"])
                elseif daysOffline >= 60 then table.insert(resolvedGroups, L["GROUP_OFFLINE_2"])
                elseif daysOffline >= 30 then table.insert(resolvedGroups, L["GROUP_OFFLINE_1"]) end
            end
        end

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

    for _, groupName in ipairs(cache.groups) do
        local addToTable = false

        if not groupsTotal[groupName] then
            groupsTotal[groupName] = FG_GetTable()
            groupsCount[groupName] = FG_GetTable()
            groupsCount[groupName].Total = 0
            groupsCount[groupName].Online = 0
            table.insert(groupsSorted, groupName)
        end

        if isOnline then
            if (FriendGroups_SavedVars.hide_afk and statusText ~= "AFK" and statusText ~= "AFKMobile") or not FriendGroups_SavedVars.hide_afk then
                if (FriendGroups_SavedVars.ingame_only and client == BNET_CLIENT_WOW) or not FriendGroups_SavedVars.ingame_only then
                    if FriendGroups_SavedVars.show_retail and client == BNET_CLIENT_WOW then
                        if isRetail then addToTable = true end
                    else
                        addToTable = true
                    end
                end
            end
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

            -- [[ ALPHABETICAL SORT KEY ]]
            -- BNet -> account identifier (BattleTag; its name prefix is the displayed bold name).
            -- WoW  -> character name. Lowercased for case-insensitive ordering. Consumed by the
            -- secondary sort in FriendGroups_SortTableByStatus.
            local sortName = charName
            if buttonType == FRIENDS_BUTTON_TYPE_BNET and accountIdentifier then
                sortName = accountIdentifier
            end
            playerData.sortName = (sortName or ""):lower()

            table.insert(groupsTotal[groupName], playerData)
		end
    end
end

function FriendGroups_Search(playerId, playerButtonType, passedAccountInfo)
    if searchValue == "" then return true end

    local characterName, bnetAccountName, battleTag, noteText, realmName, className, richPresence, regionSearchText, factionSearchText = "", "", "", "", "", "", "", "", ""
    local classMatch = false
    local altMatch = false
    local matchedGuildName = ""
    local hasManualGuild = false
    local searchLower = searchLowerValue
    local searchLen = #searchLower

    if playerButtonType == FRIENDS_BUTTON_TYPE_BNET then
        -- Fast Path: Use passed memory reference instead of querying the API
        local accountInfo = passedAccountInfo or C_BattleNet.GetFriendAccountInfo(playerId)
        if accountInfo and accountInfo.gameAccountInfo then
            bnetAccountName = (type(accountInfo.accountName) == "string") and accountInfo.accountName or ""
            battleTag = (type(accountInfo.battleTag) == "string") and accountInfo.battleTag or ""
            noteText = (type(accountInfo.note) == "string") and accountInfo.note or ""
            characterName = (type(accountInfo.gameAccountInfo.characterName) == "string") and accountInfo.gameAccountInfo.characterName or ""
            realmName = (type(accountInfo.gameAccountInfo.realmName) == "string") and accountInfo.gameAccountInfo.realmName or ""
            className = (type(accountInfo.gameAccountInfo.className) == "string") and accountInfo.gameAccountInfo.className or ""
            richPresence = (type(accountInfo.gameAccountInfo.richPresence) == "string") and accountInfo.gameAccountInfo.richPresence or ""
            factionSearchText = (type(accountInfo.gameAccountInfo.factionName) == "string") and accountInfo.gameAccountInfo.factionName or ""

            local rid = accountInfo.gameAccountInfo.regionID
            local database = (rid == 3) and FriendGroups_RealmDataEU or FriendGroups_RealmData
            
            if realmName ~= "" then
                local cleanRealm = FriendGroups_CleanRealmName(realmName)
                local data = database[cleanRealm]
                if data and data.region then
                    regionSearchText = data.region
                end
            end
            
            local accountIdentifier = accountInfo.battleTag or accountInfo.accountName
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
                    if accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and accountInfo.gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE then
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

    if className ~= "" and className:lower():sub(1, searchLen) == searchLower then classMatch = true end

    if (bnetAccountName:lower():find(searchLower, 1, true)) or 
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
    if not FriendsListFrame or not FriendsListFrame:IsMouseOver() then
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

    local accountIdentifier = accountInfo and (accountInfo.battleTag or accountInfo.accountName)

    if accountIdentifier then
        rootDescription:CreateButton(L["DROP_SET_NICKNAME"], function(data)
            StaticPopup_Show("FRIENDGROUPS_SET_NICKNAME", nil, nil, { accountIdentifier = data.accountIdentifier })
        end, { accountIdentifier = accountIdentifier })

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
           and group ~= L["GROUP_OFFLINE_1"] and group ~= L["GROUP_OFFLINE_2"] and group ~= L["GROUP_OFFLINE_3"] and not isGuildGroup then
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
           and group ~= L["GROUP_FAVORITES"] and group ~= L["GROUP_OFFLINE_1"] and group ~= L["GROUP_OFFLINE_2"] and group ~= L["GROUP_OFFLINE_3"] and not isGuildGroup then
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
            MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                local displayTitle = frame.name:GetText() or groupName
                rootDescription:CreateTitle(displayTitle)
                
                local isGuildGroup = string.find(groupName, L["GROUP_GUILDMATES"], 1, true)
                local isSystemGroup = (groupName == L["GROUP_NONE"] or groupName == L["GROUP_FAVORITES"] or groupName == L["GROUP_EMPTY"] or groupName == "" or groupName == L["GROUP_OFFLINE_1"] or groupName == L["GROUP_OFFLINE_2"] or groupName == L["GROUP_OFFLINE_3"])

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
                            if FriendsListFrame and FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox.ForEachFrame then
                                FriendsListFrame.ScrollBox:ForEachFrame(function(f)
                                    if f.rawGroupName == groupName and f.solidBannerTexture then
                                        f.solidBannerTexture:SetColorTexture(r, g, b, 0.4)
                                        f.solidBannerTexture:Show()
                                    end
                                end)
                            end
                        end
                        
                        local function OnColorColorPickerCancelled()
                            if originalHex then
                                FriendGroups_SavedVars.banner_colors[groupName] = originalHex
                                local r = tonumber(string.sub(originalHex, 1, 2), 16) / 255
                                local g = tonumber(string.sub(originalHex, 3, 4), 16) / 255
                                local b = tonumber(string.sub(originalHex, 5, 6), 16) / 255
                                if FriendsListFrame and FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox.ForEachFrame then
                                    FriendsListFrame.ScrollBox:ForEachFrame(function(f)
                                        if f.rawGroupName == groupName and f.solidBannerTexture then
                                            f.solidBannerTexture:SetColorTexture(r, g, b, 0.4)
                                            f.solidBannerTexture:Show()
                                        end
                                    end)
                                end
                            else
                                if FriendGroups_SavedVars.banner_colors then
                                    FriendGroups_SavedVars.banner_colors[groupName] = nil
                                end
                                if FriendsListFrame and FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox.ForEachFrame then
                                    FriendsListFrame.ScrollBox:ForEachFrame(function(f)
                                        if f.rawGroupName == groupName and f.solidBannerTexture then
                                            f.solidBannerTexture:Hide()
                                        end
                                    end)
                                end
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
                    
                    if FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName] then
                        rootDescription:CreateButton(L["MENU_CLEAR_BANNER_COLOR"], function()
                            FriendGroups_SavedVars.banner_colors[groupName] = nil
                            
                            -- Instant live refresh for visible frames
                            if FriendsListFrame and FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox.ForEachFrame then
                                FriendsListFrame.ScrollBox:ForEachFrame(function(f)
                                    if f.rawGroupName == groupName and f.solidBannerTexture then
                                        f.solidBannerTexture:Hide()
                                    end
                                end)
                            end
                            
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

-- [[ NEW POPUP: COPY TEXT ]] --
StaticPopupDialogs["FRIENDGROUPS_SET_NICKNAME"] = {
	text = L["POPUP_ENTER_NICKNAME"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 20,
	OnAccept = function(self, data)
		local input = self:GetEditBox():GetText()
		if not FriendGroups_SavedVars.nicknames then
			FriendGroups_SavedVars.nicknames = {}
		end
		if input == "" then
			FriendGroups_SavedVars.nicknames[data.accountIdentifier] = nil
		else
			FriendGroups_SavedVars.nicknames[data.accountIdentifier] = input
		end
		FriendGroups_FriendsListUpdate(true)
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		local input = self:GetText()
		if not FriendGroups_SavedVars.nicknames then
			FriendGroups_SavedVars.nicknames = {}
		end
		if input == "" then
			FriendGroups_SavedVars.nicknames[parent.data.accountIdentifier] = nil
		else
			FriendGroups_SavedVars.nicknames[parent.data.accountIdentifier] = input
		end
		FriendGroups_FriendsListUpdate(true)
		parent:Hide()
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

-- [[ CORE ACTIVATOR ]] --
EnableFriendGroups = function()
    if FriendGroups_Loaded then return end
    FriendGroups_Loaded = true
    
		if not FriendGroups_SavedVars then
        FriendGroups_SavedVars = {
            collapsed = {},
            hide_offline = false,         
            colour_classes = true,        
            show_faction_icons = true,    
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
            auto_accept_res = false,
            show_flags = true,
            offline_tracker = true,
            wide_list = false
        }
    end
	
    -- [[ DEFAULTS MIGRATION FOR EXISTING USERS ]] --
    if FriendGroups_SavedVars.show_flags == nil then
        FriendGroups_SavedVars.show_flags = true
    end
    if FriendGroups_SavedVars.show_contact_cap == nil then
        FriendGroups_SavedVars.show_contact_cap = true
    end
    if FriendGroups_SavedVars.offline_tracker == nil then
        FriendGroups_SavedVars.offline_tracker = true
    end
    if FriendGroups_SavedVars.group_order == nil then
        FriendGroups_SavedVars.group_order = {}
    end
    if FriendGroups_SavedVars.main_guild == nil then
        FriendGroups_SavedVars.main_guild = {}
    end

-- 1. Create Search Box
    FriendGroups_SearchBox = CreateFrame("EditBox", "FriendGroupsGlobalSearch", FriendsListFrame, "SearchBoxTemplate")
    FriendGroups_SearchBox:SetSize(20, 20)
    FriendGroups_SearchBox:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 15, -85) 
    FriendGroups_SearchBox:SetPoint("TOPRIGHT", FriendsListFrame, "TOPRIGHT", -90, -85)
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
    FriendGroups_ContactText = FriendsListFrame:CreateFontString("FriendGroupsContactText", "OVERLAY", "GameFontNormalSmall")
    FriendGroups_ContactText:SetPoint("LEFT", FriendGroups_SearchBox, "RIGHT", 8, 0)
	
	-- 3. Create Settings Button
    FriendGroupsGlobalSettings = CreateFrame("Button", "FriendGroupsGlobalSettings", FriendsListFrame)
    FriendGroupsGlobalSettings:SetSize(20, 20)
    FriendGroupsGlobalSettings:SetPoint("TOPRIGHT", FriendsListFrame, "TOPRIGHT", -9, -85)
    FriendGroupsGlobalSettings:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    FriendGroupsGlobalSettings:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	
    FriendGroupsGlobalSettings:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
            -- Sections flagged submenu=true become flyouts (Size, Group Behaviour);
            -- Filter/Appearance stay flat in the root for live tweaking; everything
            -- past the isAdvancedStart marker collects into one "Advanced" flyout.
            -- Dividers separate root sections and the sub-sections inside Advanced.
            local target = rootDescription
            local inAdvanced = false
            local firstRoot = true
            for _, item in ipairs(settingsMenuItems) do
                if item.isAdvancedStart then
                    if not firstRoot then rootDescription:CreateDivider() end
                    target = rootDescription:CreateButton(L["SETTINGS_ADVANCED"])
                    local ver = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version")
                    target:CreateTitle(string.format(L["SETTINGS_VERSION"], ver or ""))
                    local lastTs = FriendGroups_SavedVars and FriendGroups_SavedVars.last_export_time
                    if lastTs and lastTs > 0 then
                        target:CreateTitle(string.format(L["SETTINGS_LAST_BACKUP"], date("%Y-%m-%d %H:%M", lastTs)))
                    end
                    inAdvanced = true
                    firstRoot = false
                elseif item.isTitle and item.text ~= "" then
                    if inAdvanced then
                        -- sub-section header inside the Advanced flyout
                        target:CreateDivider()
                        target:CreateTitle(item.text)
                    elseif item.submenu then
                        if not firstRoot then rootDescription:CreateDivider() end
                        target = rootDescription:CreateButton(item.text)
                        firstRoot = false
                    else
                        if not firstRoot then rootDescription:CreateDivider() end
                        target = rootDescription
                        target:CreateTitle(item.text)
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
        end)
    end)
    
    FriendGroupsGlobalSettings:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["SETTINGS_TITLE"], 1, 1, 1)
        GameTooltip:Show()
    end)
    
    FriendGroupsGlobalSettings:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- 3. Apply Hooks
    -- [[ OVERWRITE NATIVE LIST UPDATE TO PREVENT SCROLL JUMPING DESYNC ]]
    local original_FriendsList_Update = FriendsList_Update
	FriendsList_Update = function()
        -- Route through the coalescer so bursts of roster events collapse into one refresh.
        -- (Still relies on the Dirty Roster Engine; visibility + combat guards apply at fire time.)
        FriendGroups_RequestListUpdate()
    end
    
    hooksecurefunc("FriendsFrame_UpdateFriendButton", FriendGroups_FriendsListUpdateFriendButton)
    Menu.ModifyMenu("MENU_UNIT_GLUE_FRIEND", FriendGroups_AddDropDownNew)
    Menu.ModifyMenu("MENU_UNIT_FRIEND", FriendGroups_AddDropDownNew)
    Menu.ModifyMenu("MENU_UNIT_FRIEND_OFFLINE", FriendGroups_AddDropDownNew)
    Menu.ModifyMenu("MENU_UNIT_BN_FRIEND", FriendGroups_AddDropDownNew)
    Menu.ModifyMenu("MENU_UNIT_BN_FRIEND_OFFLINE", FriendGroups_AddDropDownNew)
    hooksecurefunc(FriendsListButtonMixin, "OnClick", FriendGroups_FriendsListButtonTemplateClick)

    -- 4. Setup Scroll View
    SetupGroupedView()
    
	-- [[ UPDATED DEFAULT: Set to 380 (Large) ]] --
    if not FriendGroups_SavedVars.extra_height then
        FriendGroups_SavedVars.extra_height = 380
    end
    FriendGroups_UpdateSize()

    FriendGroups_UpdateContactCap()
    FriendGroups_FriendsListUpdate(true)
end

hooksecurefunc(FriendsTooltip, "Hide", function(self)
    -- [[ ANTI-FLICKER FIX: Ignore hide command if mouse is still on the Friends List ]]
    if FriendsFrame and FriendsFrame:IsMouseOver() then return end
    
    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
    FriendGroups_CurrentHoverAnchor = nil
end)

hooksecurefunc(GameTooltip, "Hide", function(self)
    -- [[ ANTI-FLICKER FIX: Protect against GameTooltip native hide collisions ]]
    if FriendsFrame and FriendsFrame:IsMouseOver() then return end
    if CommunitiesFrame and CommunitiesFrame:IsMouseOver() then return end
    
    if FriendGroupsAltTooltip then FriendGroupsAltTooltip:Hide() end
    FriendGroups_CurrentHoverAnchor = nil
end)

SetupGroupedView = function()
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
        else
            -- 12.0 FIX: Switched from custom XML button to Blizzard's Native Secure Template
            -- This completely bypasses the Chat/Secret ID taint vector when clicking friends.
            factory("FriendsListButtonTemplate", FriendGroups_FriendsListUpdateFriendButton);
        end
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(FriendsListFrame.ScrollBox, FriendsListFrame.ScrollBar, view);
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

	local id = elementData.id;
	local buttonType = elementData.buttonType;
	button.buttonType = buttonType;
	button.id = id;

	if button.facIcon then button.facIcon:Hide() end
    if button.realmFlag then button.realmFlag:Hide() end 

	local nameText, nameColor, infoText, isFavoriteFriend, statusTexture;
	local hasTravelPassButton = false;
	local isCrossFactionInvite = false;
	local inviteFaction = nil;

	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(id);
		if (info.connected) then
			button.background:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a);
			if (info.afk) then button.status:SetTexture(FRIENDS_TEXTURE_AFK);
			elseif (info.dnd) then button.status:SetTexture(FRIENDS_TEXTURE_DND);
			else button.status:SetTexture(FRIENDS_TEXTURE_ONLINE); end
			nameText = info.name .. ", " .. format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className);
			nameColor = FRIENDS_WOW_NAME_COLOR;
			infoText = FriendGroups_GetOnlineInfoText(BNET_CLIENT_WOW, info.mobile, info.rafLinkType, info.area);
			
			button.gameIcon:Hide();
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameText = info.name;
			nameColor = FRIENDS_GRAY_COLOR;
			infoText = FRIENDS_LIST_OFFLINE;
			
			button.gameIcon:Show();
			C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium);
			button.gameIcon:SetAlpha(0.3);
		end
		button.summonButton:ClearAllPoints();
		button.summonButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, -1);
		FriendsFrame_SummonButton_Update(button.summonButton);

	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id);
		if accountInfo then
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

			if FriendGroups_SavedVars.show_mobile_afk and client == 'BSAp' then statusTexture = FRIENDS_TEXTURE_AFK end

			nameText = FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag, timerunningSeasonID, realmName)
			button.status:SetTexture(statusTexture);
            
            factionName = factionName or ""
			isCrossFactionInvite = factionName ~= "" and factionName ~= playerFactionGroup;
			inviteFaction = factionName;

			if accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if FriendGroups_ShowRichPresenceOnly(client, accountInfo.gameAccountInfo.wowProjectID, factionName, accountInfo.gameAccountInfo.realmID, accountInfo.gameAccountInfo.areaName) then
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = FriendGroups_GetOnlineInfoText(client, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName, realmName);
				end

				C_Texture.SetTitleIconTexture(button.gameIcon, client, Enum.TitleIconVersion.Medium);
				local fadeIcon = (client == BNET_CLIENT_WOW) and (accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID);
				if fadeIcon then button.gameIcon:SetAlpha(0.6); else button.gameIcon:SetAlpha(1); end

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

                    if factionName == "Horde" then
                        button.background:SetColorTexture(0.7, 0.2, 0.2, 0.2)
                    elseif factionName == "Alliance" then
                        button.background:SetColorTexture(0.2, 0.2, 0.7, 0.2)
                    end
                else
                    if button.facIcon then button.facIcon:Hide() end
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

	if hasTravelPassButton then button.travelPassButton:Show(); else button.travelPassButton:Hide(); end

	local selected = (FriendsFrame.selectedFriendType == buttonType) and (FriendsFrame.selectedFriend == id);
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
			if FriendGroups_SavedVars.wide_list then
				button.name:SetWidth(button.fgOrigNameWidth + FriendGroups_WideListExtra)
			else
				button.name:SetWidth(button.fgOrigNameWidth)
			end
		end

		button.info:SetText(infoText);
		button:Show();
		if isFavoriteFriend then
			button.Favorite:Show();
			button.Favorite:ClearAllPoints()
			button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0);
		else
			button.Favorite:Hide();
		end
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
		if isCrossFactionInvite and inviteFaction == "Horde" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-horde-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-horde-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-horde-disabled");
		elseif isCrossFactionInvite and inviteFaction == "Alliance" then
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

    if (not FriendsListFrame:IsShown() and not forceUpdate) then return end

    -- Default to forcing an update if called from internal menus, clicks, or settings
    if forceUpdate == nil then forceUpdate = true end

    -- [[ MASSIVE OPTIMIZATION: IDLE GC CHURN PREVENTER ]]
    if not forceUpdate and not FriendGroups_RosterDirty then
        -- The roster structure hasn't changed. Just refresh the visible buttons (AFK timers, etc.)
        if FriendsListFrame.ScrollBox.ForEachFrame then
            FriendsListFrame.ScrollBox:ForEachFrame(function(frame)
                local elementData = frame:GetElementData()
                if elementData and (elementData.buttonType == FRIENDS_BUTTON_TYPE_BNET or elementData.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
                    FriendGroups_FriendsListUpdateFriendButton(frame, elementData)
                end
            end)
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
    wipe(groupsTotal)
    wipe(groupsCount) 
    wipe(groupsSorted)

    -- Parse natively in a single linear pass & pass refs down
    local numBNetTotal = C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends()
    for i = 1, numBNetTotal do
        local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
        if accountInfo then
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
            if FriendGroups_SavedVars.collapsed[groupName] == nil then
                FriendGroups_SavedVars.collapsed[groupName] = false
            end

            local div = FG_GetLayoutTable()
            div.buttonType = FRIENDS_BUTTON_TYPE_DIVIDER
            div.groupName = groupName
            table.insert(targetLayout, div)

            if not FriendGroups_SavedVars.collapsed[groupName] then
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

    local dataProvider = FriendsListFrame.ScrollBox:GetDataProvider()
    if not dataProvider then
        dataProvider = CreateDataProvider()
        for _, elem in ipairs(targetLayout) do dataProvider:Insert(elem) end
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

function FriendGroups_GetRealmInfo(gameAccountInfo)
    if not gameAccountInfo then return nil, nil end

    -- Secure String Verification up front
    local rawRealm = gameAccountInfo.realmName
    local safeRealm = (type(rawRealm) == "string") and rawRealm or ""
    
    local richPresence = gameAccountInfo.richPresence
    local safePresence = (type(richPresence) == "string") and richPresence or ""

    -- 1. Determine Region Database using API RegionID
    local rid = gameAccountInfo.regionID
    local database = FriendGroups_RealmData -- Default Region 1 (US/Oceanic)
    
    if rid == 3 then 
        database = FriendGroups_RealmDataEU 
    elseif rid == 2 or rid == 4 or rid == 5 then 
        database = FriendGroups_RealmDataAsia
    end

    -- 2. Standard Realm Lookup (Spaces & Punctuation stripped to match our normalized DB)
    if safeRealm ~= "" then
        local cleanRealm = safeRealm:gsub("[%s%p]+", "")
        local data = database[cleanRealm]
        
        if data then
            return "Interface\\AddOns\\FriendGroups\\Textures\\" .. data.icon, data.region
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
            return "Interface\\AddOns\\FriendGroups\\Textures\\" .. data.icon, data.region
        end
    end

    return nil, nil
end

function FriendGroups_FriendsListUpdateDividerTemplate(frame, elementData)
    local groupName = elementData.groupName
    local groupOnline = groupsCount[groupName] and groupsCount[groupName]["Online"] or 0
    local groupTotal = groupsCount[groupName] and groupsCount[groupName]["Total"] or 0

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
        
        frame.collapseButton:Show()
        if frame.info then frame.info:Show() end

        if groupName ~= L["GROUP_EMPTY"] then
            local groupInfo = string.format("%d/%d", groupOnline, groupTotal)
            
            -- [[ NEW: Hide the "0/" for Offline Virtual Groups ]]
            if groupName == L["GROUP_OFFLINE_1"] or groupName == L["GROUP_OFFLINE_2"] or groupName == L["GROUP_OFFLINE_3"] then
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
                local isSystemGroup = (hGroupName == L["GROUP_NONE"] or hGroupName == L["GROUP_FAVORITES"] or hGroupName == L["GROUP_EMPTY"] or hGroupName == "" or hGroupName == L["GROUP_OFFLINE_1"] or hGroupName == L["GROUP_OFFLINE_2"] or hGroupName == L["GROUP_OFFLINE_3"])

                if isGuildGroup then
                    local guildNameMatch = string.match(hGroupName, "<(.-)>")
                    if guildNameMatch then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(L["TOOLTIP_GUILD_GROUP_TITLE"], 1, 0.82, 0)
                        GameTooltip:AddLine(L["TOOLTIP_GUILD_GROUP_DESC_1"], 1, 1, 1, true)
                        GameTooltip:AddLine(string.format(L["TOOLTIP_GUILD_GROUP_DESC_2"], "<" .. guildNameMatch .. ">"), 1, 0.82, 0, true)
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine(L["TOOLTIP_GROUP_COLOR_PICKER_NOTE"], 0, 1, 0, true)
                        GameTooltip:Show()
                    end
                elseif not isSystemGroup then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(L["TOOLTIP_CUSTOM_GROUP_TITLE"], 1, 0.82, 0)
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

function FriendGroups_UpdateContactCap()
    if not FriendGroups_ContactText then return end
    
    -- Hardcoded server limits (as Blizzard API does not provide a query for maximums)
    local BNET_MAX_FRIENDS = 600
    local WOW_MAX_FRIENDS = 100

    local numBNetTotal = C_BattleNet and C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends() or 0
    local numBNetInvites = C_BattleNet and C_BattleNet.GetFriendNumInvites and C_BattleNet.GetFriendNumInvites() or BNGetNumFriendInvites() or 0
    local bnetConsumed = numBNetTotal + numBNetInvites

    -- Main text: Strict BNet Tracker
    FriendGroups_ContactText:SetText(string.format(L["TEXT_BNET_CONTACTS"], bnetConsumed, BNET_MAX_FRIENDS))
    
    -- Turn RED if at or over the BNet cap, otherwise White
    if bnetConsumed >= BNET_MAX_FRIENDS then
        FriendGroups_ContactText:SetTextColor(1, 0, 0) 
    else
        FriendGroups_ContactText:SetTextColor(1, 1, 1) 
    end
    
    FriendGroups_ContactText:Show()

    -- Lazy Load the invisible hover frame for the tooltip
    if not FriendGroups_ContactHoverFrame then
        FriendGroups_ContactHoverFrame = CreateFrame("Frame", "FriendGroupsContactHoverFrame", FriendsListFrame)
        FriendGroups_ContactHoverFrame:SetPoint("TOPLEFT", FriendGroups_ContactText, "TOPLEFT", 0, 0)
        FriendGroups_ContactHoverFrame:SetPoint("BOTTOMRIGHT", FriendGroups_ContactText, "BOTTOMRIGHT", 0, 0)
        
        FriendGroups_ContactHoverFrame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["TOOLTIP_CONTACT_TITLE"], 1, 1, 1)
            GameTooltip:AddLine(L["TOOLTIP_CONTACT_DESC"], nil, nil, nil, true)
            GameTooltip:AddLine(" ")
            
            -- Dynamic values inside tooltip
            local bTotal = C_BattleNet and C_BattleNet.GetFriendNum and C_BattleNet.GetFriendNum() or BNGetNumFriends() or 0
            local bInvites = C_BattleNet and C_BattleNet.GetFriendNumInvites and C_BattleNet.GetFriendNumInvites() or BNGetNumFriendInvites() or 0
            local wTotal = C_FriendList.GetNumFriends() or 0
            
            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_BNET"], string.format("%d / %d", bTotal, BNET_MAX_FRIENDS), 1, 1, 1)
            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_INVITES"], string.format("%d %s", bInvites, L["TOOLTIP_CONTACT_INV_DESC"]), 1, 1, 1, 1, 0.5, 0)
            GameTooltip:AddDoubleLine(L["TOOLTIP_CONTACT_WOW"], string.format("%d / %d", wTotal, WOW_MAX_FRIENDS), 1, 1, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(string.format(L["TOOLTIP_CONTACT_TOTAL"], bTotal + wTotal), 1, 0.82, 0)
            
            GameTooltip:Show()
        end)
        
        FriendGroups_ContactHoverFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
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
        GameTooltip:SetText(HOUSING_VISIT_HOUSE or "Visit House", 1, 1, 1)
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
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("ADDON_LOADED")

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
                show_faction_icons = true, 
                show_realm = true, 
                hide_high_level = true, 
                add_favorite_group = true, 
                add_mobile_text = true, 
                show_search = true, 
                open_one_group = false,
                auto_accept_invite = false, 
                auto_accept_sync = false,
                offline_tracker = true,
                show_guildmates = true
            }
        end
        
        if FriendGroups_SavedVars.show_guildmates == nil then FriendGroups_SavedVars.show_guildmates = true end
        
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

        FriendsFrame:HookScript("OnHide", function()
            FriendsFrame.selectedFriend = nil
            FriendsFrame.selectedFriendType = nil
            FriendGroupsFrame.selectionLocked = true
        end)
        FriendsFrame:HookScript("OnShow", function()
            FriendsFrame.selectedFriend = nil
            FriendsFrame.selectedFriendType = nil
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
-- ============================================================================

local function FG_IsPlayerBusy()
    if InCombatLockdown() then return true end
    
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        if instanceType == "pvp" or instanceType == "arena" then return true end
        if instanceType == "party" and C_ChallengeMode and C_ChallengeMode.IsChallengeModeActive() then return true end
        if IsEncounterInProgress() then return true end
    end
    
    return false
end

local FriendGroups_Automation = CreateFrame("Frame")
FriendGroups_Automation:RegisterEvent("PARTY_INVITE_REQUEST")
FriendGroups_Automation:RegisterEvent("RESURRECT_REQUEST")
FriendGroups_Automation:RegisterEvent("PLAYER_DEAD")

pcall(function()
    FriendGroups_Automation:RegisterEvent("QUEST_SESSION_CREATED")
end)

FriendGroups_Automation:SetScript("OnEvent", function(self, event, ...)
    -- 1. Auto Accept Group Invites
    if event == "PARTY_INVITE_REQUEST" then
        if FG_IsPlayerBusy() then return end 
        
        local inviterName = ...
        if FriendGroups_SavedVars and FriendGroups_SavedVars.auto_accept_invite then
            if L["MSG_AUTO_INVITE"] then
                DEFAULT_CHAT_FRAME:AddMessage(string.format(L["MSG_AUTO_INVITE"], inviterName or "Unknown"))
            end
            
            -- Removed Timer wrapper to preserve secure hardware event payload
            local success = pcall(AcceptGroup)
            if success then
                StaticPopup_Hide("PARTY_INVITE")
                StaticPopup_Hide("PARTY_INVITE_XREALM")
            else
                if L["MSG_AUTO_ACCEPT_FAILED"] then
                    DEFAULT_CHAT_FRAME:AddMessage(L["MSG_AUTO_ACCEPT_FAILED"])
                end
            end
        end

    -- 2. Auto Accept Resurrection
    elseif event == "RESURRECT_REQUEST" then
        local inviterName = ...
        if FriendGroups_SavedVars and FriendGroups_SavedVars.auto_accept_res then
            if L["MSG_AUTO_RES"] then
                DEFAULT_CHAT_FRAME:AddMessage(string.format(L["MSG_AUTO_RES"], inviterName or "Unknown"))
            end
            
            -- Removed Timer wrapper to preserve secure hardware event payload
            local success = pcall(AcceptResurrect)
            if success then
                StaticPopup_Hide("RESURRECT")
            else
                if L["MSG_AUTO_ACCEPT_FAILED"] then
                    DEFAULT_CHAT_FRAME:AddMessage(L["MSG_AUTO_ACCEPT_FAILED"])
                end
            end
        end
        
    -- 3. Auto Release Spirit
    elseif event == "PLAYER_DEAD" then
        if FriendGroups_SavedVars and FriendGroups_SavedVars.auto_release then
            if L["MSG_AUTO_RELEASE"] then
                DEFAULT_CHAT_FRAME:AddMessage(L["MSG_AUTO_RELEASE"])
            end

            local selfResOptions = C_DeathInfo.GetSelfResurrectOptions()
            if not selfResOptions or #selfResOptions == 0 then 
                local success = pcall(RepopMe)
                if not success then
                    if L["MSG_AUTO_RELEASE_FAILED"] then
                        DEFAULT_CHAT_FRAME:AddMessage(L["MSG_AUTO_RELEASE_FAILED"])
                    end
                end
            end
        end
        
    -- 4. Auto Accept Party Sync
    elseif event == "QUEST_SESSION_CREATED" then
        if FriendGroups_SavedVars and FriendGroups_SavedVars.auto_accept_sync then
            if UnitIsGroupLeader("player") then return end
            if InCombatLockdown() then return end
            
            local leaderName = "Party Leader"
            if IsInGroup() then
                for i = 1, 4 do
                    local unit = "party"..i
                    if UnitIsGroupLeader(unit) then
                        leaderName = UnitName(unit) or leaderName
                        break
                    end
                end
            end

            if L["MSG_AUTO_SYNC"] then
                DEFAULT_CHAT_FRAME:AddMessage(string.format(L["MSG_AUTO_SYNC"], leaderName))
            end

            if C_QuestSession and C_QuestSession.SendSessionBeginResponse then
                C_QuestSession.SendSessionBeginResponse(true)
            end
        end
    end
end)

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
        if existingAlt.class ~= class then existingAlt.class = class; dataChanged = true end
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
    
    local accountIdentifier = accountInfo.battleTag or accountInfo.accountName
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

local function FriendGroups_DrawAltTooltip(anchorFrame, accountIdentifier, charKey, baselineData)
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

        local displayTitle = string.format(L["TOOLTIP_ALTS_PUBLIC_TITLE_FORMAT"], hoverName)
        if #alts >= 10 and L["TOOLTIP_ALTS_TITLE_FORMAT_MAX"] then
            displayTitle = string.format(L["TOOLTIP_ALTS_TITLE_FORMAT_MAX"], hoverName)
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
        FriendGroupsAltTooltip:AddLine(displayTitle, 1, 0.82, 0)

        -- [[ BNET SUBTITLE ]] Show the owning Battle.net BattleTag in the familiar BNet blue.
        -- accountIdentifier is the BattleTag (Name#1234) when one exists; the '#' test keeps
        -- legacy accountName values from rendering as a junk subtitle.
        if accountIdentifier
           and not (issecretvalue and issecretvalue(accountIdentifier))
           and type(accountIdentifier) == "string"
           and accountIdentifier:find("#") then
            local btagColor = FRIENDS_BNET_NAME_COLOR or BATTLENET_FONT_COLOR or CreateColor(0.510, 0.773, 1.0)
            FriendGroupsAltTooltip:AddLine(accountIdentifier, btagColor.r, btagColor.g, btagColor.b)
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

            local classIconStr = ""
            if engClass ~= "" then
                local atlas = GetClassAtlas(engClass)
                if atlas then classIconStr = "|A:" .. atlas .. ":16:16|a" else classIconStr = "|A:classicon-" .. string.lower(engClass) .. ":16:16|a" end
            end
            
            local nameColor = FriendGroups_GetClassColorCode(engClass ~= "" and engClass or alt.class)
            local coloredName = nameColor .. alt.charName .. (alt.realm ~= "" and ("-" .. alt.realm) or "") .. "|r"

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

    -- Keep the roster's native tooltip anchored to the panel's slot whether the panel is
    -- shown (BNet friend -> dock beneath) or suppressed (plain guildmate -> park on the
    -- right). Re-applied after every Show because Blizzard / Raider.IO re-anchor the
    -- shared GameTooltip as their data resolves.
    FriendGroups_DockNativeTooltipBelowPanel(anchor)
end)

-- [[ DIRECT BUTTON HANDLER ]]
function FriendGroups_ShowButtonAltTooltip(button)
    if not FriendGroups_Loaded or FriendGroups_SavedVars.show_known_alts == false then FriendGroupsAltTooltip:Hide() return end

    if not button or not button.id then return end

    FriendGroups_CurrentHoverAnchor = FriendsFrame
    FriendGroups_CurrentHoverBNetID = nil
    FriendGroups_CurrentHoverCharKey = nil

    local baselineData = nil

    if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
        if not accountInfo then return end

        local accountIdentifier = accountInfo.battleTag or accountInfo.accountName
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

        FriendGroups_DrawAltTooltip(FriendsFrame, FriendGroups_CurrentHoverBNetID, FriendGroups_CurrentHoverCharKey, baselineData)
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

        local accountIdentifier = accountInfo.battleTag or accountInfo.accountName
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

        FriendGroups_DrawAltTooltip(FriendsFrame, FriendGroups_CurrentHoverBNetID, FriendGroups_CurrentHoverCharKey, baselineData)
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
        DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_HEADER"] or "Debug Header Missing")
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_MEM_USAGE"] or "Mem: %.2f", memUsageMB))
        DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_DB_SIZE"] or "Database Profiles: %d (Private BNet Cache)", privateCount))

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
    elseif command == "export" then
        FriendGroups_ShowExport()
    elseif command == "import" then
        StaticPopup_Show("FRIENDGROUPS_IMPORT")
    else
        DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_HELP"] or "Type /fg debug")
    end
end

-- ============================================================================
-- [[ OPEN-LIST UPDATE COALESCER ]]
-- ============================================================================
-- Collapses bursts of roster events (BN_FRIEND_INFO_CHANGED, FRIENDLIST_UPDATE, native idle
-- ticks) that route through the FriendsList_Update override into a single deferred refresh.
-- Schedules at most one timer per window, and only while the Friends list is actually visible.
-- The Dirty Roster Engine still flags changes regardless, so a hidden list rebuilds correctly
-- via OnShow the next time it is opened. All existing guards (combat, visibility, dirty) still
-- apply when the timer fires, so behaviour is identical to today aside from a sub-frame delay.
local FriendGroups_UpdateThrottleTimer = nil
function FriendGroups_RequestListUpdate()
    if not (FriendsListFrame and FriendsListFrame:IsShown()) then return end
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

