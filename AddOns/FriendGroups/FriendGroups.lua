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

-- [[ FORWARD DECLARATIONS ]] --
local EnableFriendGroups
local FriendGroups_FriendsListUpdate
local FriendGroups_FriendsListUpdateFriendButton
local FriendGroups_FriendsListButtonTemplateClick

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
local friendsListEmpty = false
local searchBoxInit = false
local lastFriendsListEmptyWarning = 0
local currentExpansionMaxLevel, FriendGroups_Menu, FriendGroupsFrame, searchOpened
local searchValue = ""
local FriendGroups_SearchBox

-- Data for the Custom Menu
local FriendGroups_ClickedData = {}

local groupMenuItems = {
    { text = "",         notCheckable = true, isTitle = true },
    {
        text = L["MENU_RENAME"],
        notCheckable = true,
        func = function(self, groupName)
            StaticPopup_Show("FRIENDGROUPS_RENAME", nil, nil, groupName)
        end
    },
    {
        text = L["MENU_REMOVE"],
        notCheckable = true,
        func = function(self, groupName)
            FriendGroups_InviteOrGroup(groupName, false)
        end
    },
    {
        text = L["MENU_INVITE"],
        notCheckable = true,
        func = function(self, groupName)
            FriendGroups_InviteOrGroup(groupName, true)
        end
    },
}

local settingsMenuItems = {
    -- SECTION 0: SIZE
    { text = L["SETTINGS_SIZE"], notCheckable = true, isTitle = true },
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

    -- SECTION 1: FILTERS
    { text = L["SETTINGS_FILTER"],    notCheckable = true, isTitle = true },
    {
        text = L["SET_HIDE_OFFLINE"],
        keepShownOnClick = true, 
        checked = function() return FriendGroups_SavedVars.hide_offline end,
        func = function()
            FriendGroups_SavedVars.hide_offline = not FriendGroups_SavedVars.hide_offline
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
    -- [[ MOVED HERE: Mobile AFK ]] --
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
    { text = L["SETTINGS_BEHAVIOR"], notCheckable = true, isTitle = true },
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
        text = L["SET_COLLAPSE"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.open_one_group end,
        func = function()
            FriendGroups_SavedVars.open_one_group = not FriendGroups_SavedVars.open_one_group
            FriendGroups_FriendsListUpdate()
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
        text = L["SET_AUTO_PARTY_SYNC"],
        keepShownOnClick = true,
        checked = function() return FriendGroups_SavedVars.auto_accept_sync end,
        func = function()
            FriendGroups_SavedVars.auto_accept_sync = not FriendGroups_SavedVars.auto_accept_sync
            FriendGroups_FriendsListUpdate()
        end
    },

    -- SECTION 5: RESET
    { text = "", notCheckable = true, isTitle = true },
    {
        text = L["SETTINGS_RESET"],
        notCheckable = true,
        func = function()
            CloseDropDownMenus()
            -- 1. Reset all variables to the default
            FriendGroups_SavedVars.hide_offline = true
            FriendGroups_SavedVars.colour_classes = true
            FriendGroups_SavedVars.show_faction_icons = true
            FriendGroups_SavedVars.show_realm = true
            FriendGroups_SavedVars.hide_high_level = true
            FriendGroups_SavedVars.add_favorite_group = true
            
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
            
            FriendGroups_SavedVars.extra_height = 380 
            FriendGroups_SavedVars.collapsed = {}
            
            -- Apply Reset
            FriendGroups_UpdateSize()
            FriendGroups_FriendsListUpdate()
            
            print(L["MSG_RESET"])
        end
    },
}

--[[
	Init Values
]] --

-- Expansion Max Level
expansionMaxLevel[LE_EXPANSION_CLASSIC] = 60
expansionMaxLevel[LE_EXPANSION_BURNING_CRUSADE] = 70
expansionMaxLevel[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = 80
expansionMaxLevel[LE_EXPANSION_CATACLYSM] = 85
expansionMaxLevel[LE_EXPANSION_MISTS_OF_PANDARIA] = 90
expansionMaxLevel[LE_EXPANSION_WARLORDS_OF_DRAENOR] = 100
expansionMaxLevel[LE_EXPANSION_LEGION] = 110
expansionMaxLevel[LE_EXPANSION_BATTLE_FOR_AZEROTH] = 120
expansionMaxLevel[LE_EXPANSION_SHADOWLANDS] = 60
expansionMaxLevel[LE_EXPANSION_DRAGONFLIGHT] = 70
expansionMaxLevel[LE_EXPANSION_WAR_WITHIN] = 80
expansionMaxLevel[LE_EXPANSION_WAR_WITHIN + 1] = 90 -- Midnight Pre-Patch Support

currentExpansionMaxLevel = expansionMaxLevel[GetExpansionLevel()]

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

function FriendGroups_UpdateSize()
    -- 1. Store the original Blizzard defaults the very first time we run
    if not FriendGroups_OriginalHeight then
        FriendGroups_OriginalHeight = FriendsFrame:GetHeight()
        FriendGroupsList_OriginalHeight = FriendsListFrame:GetHeight()
    end

    -- 2. Determine target height based on saved variable
    local extra = FriendGroups_SavedVars.extra_height or 0

    -- 3. Apply
    FriendsFrame:SetHeight(FriendGroups_OriginalHeight + extra)
    FriendsListFrame:SetHeight(FriendGroupsList_OriginalHeight + extra)

    -- 4. Re-anchor ScrollBox to fill the new space
    FriendsListFrame.ScrollBox:ClearAllPoints()
    FriendsListFrame.ScrollBox:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 7, -115)
    FriendsListFrame.ScrollBox:SetPoint("BOTTOMRIGHT", FriendsListFrame, "BOTTOMRIGHT", -26, 35)
end

function FriendGroups_Rename(self, oldGroup)
	local input = self:GetEditBox():GetText()
    
    -- Safety Check
	if input == "" or not oldGroup then
		return
	end

	local groups = {}
	for i = 1, BNGetNumFriends() do
		local presenceID = C_BattleNet.GetFriendAccountInfo(i).bnetAccountID
		local noteText = C_BattleNet.GetFriendAccountInfo(i).note
		local note = FriendGroups_NoteAndGroups(noteText, groups)
		if groups[oldGroup] then
			groups[oldGroup] = nil
			groups[input] = true
			note = FriendGroups_CreateNote(note, groups)
			BNSetFriendNote(presenceID, note)
		end
	end
	for i = 1, C_FriendList.GetNumFriends() do
		local note = C_FriendList.GetFriendInfoByIndex(i).notes
		local name = C_FriendList.GetFriendInfoByIndex(i).name
		note = FriendGroups_NoteAndGroups(note, groups)

		if groups[oldGroup] then
			groups[oldGroup] = nil
			groups[input] = true
			note = FriendGroups_CreateNote(note, groups)
			C_FriendList.SetFriendNotes(name, note)
		end
	end
	FriendGroups_FriendsListUpdate()
end

function FriendGroups_InviteOrGroup(groupName, invite)
	local groups = {}

	for i = 1, BNGetNumFriends() do
		local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(i)
		local gameAccountInfo = friendAccountInfo.gameAccountInfo
		local presenceID = friendAccountInfo.bnetAccountID
		local noteText = friendAccountInfo.note
		local note = FriendGroups_NoteAndGroups(noteText, groups)
		if groups[groupName] then
			if invite and gameAccountInfo and gameAccountInfo.gameAccountID then
				BNInviteFriend(gameAccountInfo.gameAccountID)
			elseif not invite then
				groups[groupName] = nil
				note = FriendGroups_CreateNote(note, groups)
				BNSetFriendNote(presenceID, note)
			end
		end
	end
	for i = 1, C_FriendList.GetNumFriends() do
		local friend_info = C_FriendList.GetFriendInfoByIndex(i)
		local name = friend_info.name
		local connected = friend_info.connected
		local noteText = friend_info.notes
		local note = FriendGroups_NoteAndGroups(noteText, groups)

		if groups[groupName] then
			if invite and connected then
				C_PartyInfo.InviteUnit(name)
			elseif not invite then
				groups[groupName] = nil
				note = FriendGroups_CreateNote(note, groups)
				C_FriendList.SetFriendNotes(name, note)
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
	if not note then
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

function FriendGroups_AddDropDownNew(ownerRegion, rootDescription, contextData)
	local bnetfriend = nil
	local note = ""

	if contextData.which == "BN_FRIEND" or contextData.which == "BN_FRIEND_OFFLINE" then
		bnetfriend = true
	else
		bnetfriend = false
	end

	local accountInfo = FriendGroups_GetInfoByName(contextData.name, bnetfriend)
	
	if accountInfo then
	
		if bnetfriend then
			note = accountInfo.note
		else
			note = accountInfo.notes
		end

		local groups = FriendGroups_GetPlayerGroups(note)

		rootDescription:CreateDivider()
		rootDescription:CreateTitle(L["DROP_TITLE"])

		-- [[ OPTION 1: Copy Name-Realm ]] --
		rootDescription:CreateButton(L["DROP_COPY_NAME"], function(data)
			local textToCopy = ""
			if data.bnetfriend then
				local info = C_BattleNet.GetAccountInfoByID(accountInfo.bnetAccountID)
				if info and info.gameAccountInfo and info.gameAccountInfo.characterName then
					local char = info.gameAccountInfo.characterName
					local realm = info.gameAccountInfo.realmName
					local richPresence = info.gameAccountInfo.richPresence
					local friendProject = info.gameAccountInfo.wowProjectID
					local myProject = WOW_PROJECT_ID

					-- 1. Try standard realm display name
					if not realm or realm == "" then
						realm = info.gameAccountInfo.realmDisplayName
					end

					-- 2. Try parsing Rich Presence (Critical for Classic friends viewed from Retail)
					if (not realm or realm == "") and richPresence then
						local extraction = richPresence:match("%s%-%s(.+)")
						if extraction then
							realm = extraction
						end
					end

					-- 3. Fallback: Use Player's Realm ONLY if they are on the SAME Project
					if (not realm or realm == "") and info.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
						if friendProject == myProject then
							realm = GetRealmName()
						end
					end

					if realm and realm ~= "" then
						realm = realm:gsub("%s+", "") 
						textToCopy = char .. "-" .. realm
					else
						textToCopy = char
					end
				elseif info and info.battleTag then
					-- Fallback to BTag if no character found (e.g. Offline)
					textToCopy = info.battleTag
				end
			else
				-- Standard WoW Friend
				textToCopy = contextData.name
				if textToCopy and textToCopy ~= "" and not string.find(textToCopy, "-") then
					local myRealm = GetRealmName()
					if myRealm then
						textToCopy = textToCopy .. "-" .. myRealm:gsub("%s+", "")
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
		end, { name = contextData.name, bnetfriend = bnetfriend })

		-- [[ OPTION 2: Copy BattleTag (NEW) ]] --
		if bnetfriend then
			rootDescription:CreateButton(L["DROP_COPY_BTAG"], function(data)
				local info = C_BattleNet.GetAccountInfoByID(accountInfo.bnetAccountID)
				if info and info.battleTag then
					local dialog = StaticPopup_Show("FRIENDGROUPS_COPY_POPUP")
					if dialog and dialog.EditBox then
						dialog.EditBox:SetText(info.battleTag)
						dialog.EditBox:HighlightText()
						dialog.EditBox:SetFocus()
					end
				end
			end)
		end

		-- [[ OPTION 3: Create New Group ]] --
		rootDescription:CreateButton(L["DROP_CREATE"], function(data)
			FriendGroups_CreateNewGroup(data.name, data.bnetfriend)
		end, { name = contextData.name, bnetfriend = bnetfriend })

		-- [[ OPTION 4: Add to Group ]] --
		local add = rootDescription:CreateButton(L["DROP_ADD"])

		for _, group in ipairs(groupsSorted) do
			if not FriendGroups_HasValue(groups, group) and not (group == "") and not (group == L["GROUP_FAVORITES"]) and not (group == L["GROUP_EMPTY"]) and not (group == L["GROUP_NONE"]) then
				add:CreateButton(group, function(data)
					local note = data.note
					local group = data.group

					note = FriendGroups_AddGroup(note, group)
					if bnetfriend then
						BNSetFriendNote(accountInfo.bnetAccountID, note)
					else
						C_FriendList.SetFriendNotes(contextData.name, note)
					end
				end, { group = group, note = note })
			end
		end

		-- [[ OPTION 5: Remove from Group ]] --
		local remove = rootDescription:CreateButton(L["DROP_REMOVE"])

		for _, group in ipairs(groupsSorted) do
			if FriendGroups_HasValue(groups, group) then
				remove:CreateButton(group, function(data)
					note = FriendGroups_RemoveGroup(data.note, data.group)
					if bnetfriend then
						BNSetFriendNote(accountInfo.bnetAccountID, note)
					else
						C_FriendList.SetFriendNotes(contextData.name, note)
					end
				end, { group = group, note = note })
			end
		end
	end
end

function FriendGroups_GetInfoByName(name, bnetfriend)
	if bnetfriend then
		local accountID = 0
		for i = 1, BNGetNumFriends() do
			local acc = C_BattleNet.GetFriendAccountInfo(i)
			if acc.accountName == name then
				accountID = acc.bnetAccountID
			end
		end

		return C_BattleNet.GetAccountInfoByID(accountID)
	else
		local info = C_FriendList.GetFriendInfo(name)
		return info
	end
end

function FriendGroups_CreateNewGroup(name, bnetfriend)
	if bnetfriend then
		local accountInfo = FriendGroups_GetInfoByName(name, bnetfriend)
		StaticPopup_Show("FRIENDGROUPS_CREATE", nil, nil,
			{ id = accountInfo.bnetAccountID, note = accountInfo.note, set = BNSetFriendNote })
	else
		local FriendInfo = C_FriendList.GetFriendInfo(name)
		StaticPopup_Show("FRIENDGROUPS_CREATE", nil, nil,
			{ name = name, note = FriendInfo.notes, set = C_FriendList.SetFriendNotes })
	end
end

function FriendGroups_SplitBattleTag(battleTag)
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

function FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag,
											timerunningSeasonID, realmName)
	local nameText

	-- set up player name and character name
	if accountName then
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

		local characterNameSuffix
		if (not level) or (FriendGroups_SavedVars.hide_high_level and level == currentExpansionMaxLevel) or level == 0 then
			characterNameSuffix = ""
		else
			characterNameSuffix = " | " .. level
		end

		if client == BNET_CLIENT_WOW then
			if characterName ~= "" and level ~= 0 then
				if not canCoop and FriendGroups_SavedVars.gray_faction then
					nameText = "|CFF949694" .. nameText .. " " .. "[" .. characterName .. characterNameSuffix ..
						"}" .. "|r"
				elseif FriendGroups_SavedVars.colour_classes then
					local nameColor = FriendGroups_GetClassColorCode(class)
					nameText = nameText ..
						" " .. nameColor .. "[" .. characterName .. characterNameSuffix .. "]" .. FONT_COLOR_CODE_CLOSE
				else
					nameText = nameText .. " " .. "[" .. characterName .. characterNameSuffix ..
						"]" .. FONT_COLOR_CODE_CLOSE
				end
			end
		else
			if ENABLE_COLORBLIND_MODE == "1" then
				characterName = characterName
			end
			local characterNameAndLevel = characterName .. characterNameSuffix
			nameText = nameText ..
				" " .. FRIENDS_OTHER_NAME_COLOR_CODE .. "[" .. characterNameAndLevel .. "]" .. FONT_COLOR_CODE_CLOSE
		end
	end

	return nameText
end

function FriendGroups_GetPlayerGroups(note)
	if note then
		local groups = {}
		local formattedNote = string.match(note, "#.*")

		if formattedNote then
			for s in string.gmatch(formattedNote, "[^#]+") do
				table.insert(groups, s)
			end
		end

		return groups
	else
		return {}
	end
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
		-- If they are not in wow or in a different version of wow, always show rich presence only
		return true;
	elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= playerFactionGroup) or (realmID ~= playerRealmID)) then
		-- If we are both in wow classic and our factions or realms don't match, show rich presence only
		return true;
	else
		-- Otherwise show more detailed info about them

		-- Plunderstorm
		if (client == BNET_CLIENT_WOW) and (wowProjectID == WOW_PROJECT_ID) and not areaName then
			return true;
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
	else
		_, accountName, _, _, characterName, bnetAccountId, client,
		isOnline, lastOnline, isAFK, isDND, _, _, _, _, wowProjectID, _, _,
		_, mobile = BNetAccountInfo(id)


		if isOnline then
			_, _, _, realmName, _, factionName, _, class, _, zoneName, level,
			gameText, _, _, _, _, _, isGameAFK, isGameBusy, _,
			wowProjectID, mobile = BNGetGameAccountInfo(bnetAccountId)
		end

		canCoop = CanCooperateWithGameAccount(bnetAccountId)
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
	if (factionGroup and factionGroup ~= "Neutral") then
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
	local statusSort = {}

	statusSort["OnlineInGame"] = 1
	statusSort["DNDInGame"] = 2
	statusSort["AFKInGame"] = 3
	statusSort["Online"] = 4
	statusSort["OnlineMobile"] = 5
	statusSort["DND"] = 6
	statusSort["AFK"] = 7
	statusSort["AFKMobile"] = 8
	statusSort["Offline"] = 9

	if not playerA then
		playerA = {}
		playerA.statusText = "Offline"
	end

	if not playerB then
		playerB = {}
		playerB.statusText = "Offline"
	end

	return statusSort[playerA.statusText] < statusSort[playerB.statusText]
end

function FriendGroups_SortGroupsCustom(groupA, groupB)
	if groupA == L["GROUP_FAVORITES"] then
		return true
	end

	if groupA == L["GROUP_NONE"] then
		return false
	end

	if groupB == L["GROUP_NONE"] then
		return true
	end

	if groupB == L["GROUP_FAVORITES"] then
		return false
	end

	return groupA < groupB
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

function FriendGroups_SetGroups(id, buttonType)
	local noteText = FriendGroups_GetFriendNote(id, buttonType)
	local groups = FriendGroups_GetPlayerGroups(noteText)
	local statusText = FriendGroups_GetStatusString({ id = id, buttonType = buttonType })
	local favorite = FriendGroups_GetFriendFavorite(id, buttonType)

	if FriendGroups_SavedVars.add_favorite_group and favorite then
		table.insert(groups, L["GROUP_FAVORITES"])
	end

	if next(groups) == nil then
		table.insert(groups, L["GROUP_NONE"])
	end

	for _, groupName in ipairs(groups) do
		local isOnline, client, isRetail
		local addToTable = false

		if not groupsTotal[groupName] then
			groupsTotal[groupName] = {}
			groupsCount[groupName] = {}
			groupsCount[groupName].Total = 0
			groupsCount[groupName].Online = 0
			table.insert(groupsSorted, groupName)
		end

		if buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(id)
			if not friendAccountInfo then
				friendsListEmpty = true
			else
				isOnline = friendAccountInfo.gameAccountInfo.isOnline
				client = friendAccountInfo.gameAccountInfo.clientProgram
				isRetail = (friendAccountInfo.gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE)
			end
		elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
			isOnline = C_FriendList.GetFriendInfoByIndex(id).connected
			client = BNET_CLIENT_WOW
		end

		if isOnline then
			if (FriendGroups_SavedVars.hide_afk and statusText ~= "AFK" and statusText ~= "AFKMobile") or not FriendGroups_SavedVars.hide_afk then
				if (FriendGroups_SavedVars.ingame_only and client == BNET_CLIENT_WOW) or not FriendGroups_SavedVars.ingame_only then
					if FriendGroups_SavedVars.show_retail and client == BNET_CLIENT_WOW then
						if isRetail then
							addToTable = true
						end
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

        -- FIX: Always allow search logic since search is always on
		if searchValue ~= "" then
			addToTable = FriendGroups_Search(id, buttonType)
		end

		if addToTable then
			groupsCount[groupName].Total = groupsCount[groupName].Total + 1
			if statusText ~= "Offline" then
				groupsCount[groupName].Online = groupsCount[groupName].Online + 1
			end
			table.insert(groupsTotal[groupName], { id = id, buttonType = buttonType, statusText = statusText })
		end
	end
end

--[[ 
    FriendGroups_Menu (Right-Click on Group Header)
    - Creates the missing frame responsible for the error.
]] --
FriendGroups_Menu = CreateFrame("Frame", "FriendGroups_Menu")
FriendGroups_Menu.displayMode = "MENU"
FriendGroups_Menu.initialize = function(self, level)
    if level ~= 1 then return end
    
    -- The group name is passed as the "Value" in ToggleDropDownMenu
    local groupName = UIDROPDOWNMENU_MENU_VALUE
    
    if not groupName then return end

    -- 1. Add the Group Name as the Title
    local titleInfo = UIDropDownMenu_CreateInfo()
    titleInfo.text = groupName
    titleInfo.isTitle = true
    titleInfo.notCheckable = true
    UIDropDownMenu_AddButton(titleInfo, level)

    -- 2. Add the Action Buttons (Rename, Remove, Invite)
    -- We skip the first item in 'groupMenuItems' because it was a blank title placeholder
    for i = 2, #groupMenuItems do
        local item = groupMenuItems[i]
        local info = UIDropDownMenu_CreateInfo()
        info.text = item.text
        info.notCheckable = true
        info.func = item.func
        info.arg1 = groupName -- Pass the name to the function (clickedgroup)
        UIDropDownMenu_AddButton(info, level)
    end
end

--[[
	FriendGroups_SettingsMenu (Cogwheel Click)
]] --
local FriendGroups_SettingsMenu = CreateFrame("Frame", "FriendGroups_SettingsMenu")
FriendGroups_SettingsMenu.displayMode = "MENU"
FriendGroups_SettingsMenu.initialize = function(self, level)
    if level ~= 1 then return end
    
    for _, items in ipairs(settingsMenuItems) do
        local info = UIDropDownMenu_CreateInfo()
        for prop, value in pairs(items) do
            info[prop] = value
        end
        UIDropDownMenu_AddButton(info, level)
    end
end


--[[
	FriendGroupsFrame
]] --
FriendGroupsFrame = CreateFrame("Frame", "FriendGroupsFrame")
FriendGroupsFrame.displayMode = "MENU"
FriendGroupsFrame.info = {}
FriendGroupsFrame.UncheckHack = function(dropdownbutton)
	_G[dropdownbutton:GetName() .. "Check"]:Hide()
end
FriendGroupsFrame.HideMenu = function()
	if UIDROPDOWNMENU_OPEN_MENU == FriendGroupsFrame then
		CloseDropDownMenus()
	end
end
FriendGroupsFrame.initialize = function(self, level)
    -- This was used for the old system. Keeping empty structure to prevent Lua errors if something calls it.
end

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

--[[
	Functions
]] --

-- [[ CORE ACTIVATOR ]] --
EnableFriendGroups = function()
    if FriendGroups_Loaded then return end
    FriendGroups_Loaded = true
    
    if not FriendGroups_SavedVars then
        FriendGroups_SavedVars = {
            collapsed = {},
            hide_offline = true,          
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
            show_flags = true
        }
    end

    if FriendGroups_SavedVars.show_flags == nil then
        FriendGroups_SavedVars.show_flags = true
    end

    -- 1. Create Search Box
    FriendGroups_SearchBox = CreateFrame("EditBox", "FriendGroupsGlobalSearch", FriendsListFrame, "SearchBoxTemplate")
    FriendGroups_SearchBox:SetSize(200, 20)
    FriendGroups_SearchBox:SetPoint("TOPLEFT", FriendsListFrame, "TOPLEFT", 15, -85) 
    FriendGroups_SearchBox:SetPoint("TOPRIGHT", FriendsListFrame, "TOPRIGHT", -35, -85) 
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

    FriendGroups_SearchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        local text = self:GetText()
        if text ~= searchValue then
            searchValue = text
            FriendGroups_FriendsListUpdate(true)
        end
    end)

    -- 2. Create Settings Button
    local settingsBtn = CreateFrame("Button", "FriendGroupsGlobalSettings", FriendGroups_SearchBox)
    settingsBtn:SetSize(20, 20)
    settingsBtn:SetPoint("LEFT", FriendGroups_SearchBox, "RIGHT", 5, 0)
    settingsBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    settingsBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    
    settingsBtn:SetScript("OnClick", function()
        ToggleDropDownMenu(1, nil, FriendGroups_SettingsMenu, "cursor", 0, 0)
    end)
    
    settingsBtn:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["SETTINGS_TITLE"] or "Settings", 1, 1, 1)
        GameTooltip:Show()
    end)
    settingsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- 3. Apply Hooks
    hooksecurefunc("FriendsList_Update", FriendGroups_FriendsListUpdate)
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

    FriendGroups_FriendsListUpdate(true)
end

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
            factory("FriendGroupsFriendsListButtonTemplate", FriendGroups_FriendsListUpdateFriendButton);
        end
    end);
    ScrollUtil.InitScrollBoxListWithScrollBar(FriendsListFrame.ScrollBox, FriendsListFrame.ScrollBar, view);
end

-- [[ HELPER: Scans Text to find Realm & Region ]] --
function FriendGroups_GetRealmInfo(gameAccountInfo)
    if not gameAccountInfo then return nil, nil end

    local rawRealm = gameAccountInfo.realmName
    local richPresence = gameAccountInfo.richPresence or ""
    
    -- 1. Create a "Clean Blob" of text (remove all spaces & punctuation)
    -- This turns "AFK - Elwynn Forest - Nightslayer" into "AFKElwynnForestNightslayer"
    local cleanBlob = (richPresence .. (rawRealm or "")):gsub("%p", ""):gsub("%s+", "") 

    -- 2. Priority Scan for Manual Classic Names (The "Ghosts")
    local classicPriority = {
        ["Nightslayer"] = { icon="FlagUS.tga", region="US" },
        ["Dreamscythe"] = { icon="FlagUS.tga", region="US" },
        ["Doomhowl"] = { icon="FlagUS.tga", region="US" },
        ["Maladath"] = { icon="FlagAU.tga", region="Oceania" },
        ["Shadowstrike"] = { icon="FlagAU.tga", region="Oceania" },
        ["Penance"] = { icon="FlagAU.tga", region="Oceania" },
        ["DefiasPillager"] = { icon="FlagUS.tga", region="US" },
        ["SkullRock"] = { icon="FlagUS.tga", region="US" },
        ["CrusaderStrike"] = { icon="FlagUS.tga", region="US" },
        ["LivingFlame"] = { icon="FlagUS.tga", region="US" },
        ["WildGrowth"] = { icon="FlagUS.tga", region="US" },
        ["LoneWolf"] = { icon="FlagUS.tga", region="US" },
        ["LavaLash"] = { icon="FlagUS.tga", region="US" },
        ["ChaosBolt"] = { icon="FlagUS.tga", region="US" },
        ["Thunderstrike"] = { icon="FlagGB.tga", region="EU" },
        ["Spineshatter"] = { icon="FlagGB.tga", region="EU" },
        ["Soulseeker"] = { icon="FlagGB.tga", region="EU" }
    }

    -- If the blob contains a known Classic name, return immediately.
    for name, data in pairs(classicPriority) do
        if cleanBlob:find(name, 1, true) then
            return "Interface\\AddOns\\FriendGroups\\Textures\\" .. data.icon, data.region
        end
    end

    -- 3. Standard Retail Check (Using Realms.lua DB)
    if rawRealm and rawRealm ~= "" and rawRealm ~= "WoW Classic" and rawRealm ~= "World of Warcraft Classic" then
        local cleanRealm = rawRealm:gsub("%s+", "") -- Remove spaces
        local data = FriendGroups_RealmData[cleanRealm] or (FriendGroups_RealmDataEU and FriendGroups_RealmDataEU[cleanRealm])
        
        if data then
            return "Interface\\AddOns\\FriendGroups\\Textures\\" .. data.icon, data.region
        end
    end

    -- 4. Last Resort: Extraction from Rich Presence dash
    local extraction = richPresence:match("%s%-%s(.+)$")
    if extraction then
        local cleanEx = extraction:gsub("%s+", "")
        local data = FriendGroups_RealmData[cleanEx] or (FriendGroups_RealmDataEU and FriendGroups_RealmDataEU[cleanEx])
        if data then
            return "Interface\\AddOns\\FriendGroups\\Textures\\" .. data.icon, data.region
        end
    end

    return nil, nil
end

FriendGroups_FriendsListUpdateFriendButton = function(button, elementData)
    if not FriendGroups_Loaded then return end

    -- Safe Parent Check
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
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameText = info.name;
			nameColor = FRIENDS_GRAY_COLOR;
			infoText = FRIENDS_LIST_OFFLINE;
		end
		button.gameIcon:Hide();
		button.summonButton:ClearAllPoints();
		button.summonButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, -1);
		FriendsFrame_SummonButton_Update(button.summonButton);

	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id);
		if accountInfo then
			nameText, nameColor, statusTexture = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
			local accountName, characterName, class, level, _, _, _, client, canCoop, _, _, _, isGameAFK, isDND, isGameBusy, mobile, zoneName, gameText, battleTag, factionName, timerunningSeasonID = FriendGroups_GetFriendInfoById(button.id)

			if FriendGroups_SavedVars.show_mobile_afk and client == 'BSAp' then statusTexture = FRIENDS_TEXTURE_AFK end

			nameText = FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag, timerunningSeasonID, realmName)
			isFavoriteFriend = accountInfo.isFavorite;
			button.status:SetTexture(statusTexture);
			isCrossFactionInvite = accountInfo.gameAccountInfo.factionName ~= playerFactionGroup;
			inviteFaction = accountInfo.gameAccountInfo.factionName;

			if accountInfo.gameAccountInfo.isOnline then
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if FriendGroups_ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID, accountInfo.gameAccountInfo.areaName) then
					infoText = FriendGroups_GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = FriendGroups_GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName, accountInfo.gameAccountInfo.realmName);
				end

				C_Texture.SetTitleIconTexture(button.gameIcon, accountInfo.gameAccountInfo.clientProgram, Enum.TitleIconVersion.Medium);
				local fadeIcon = (accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID);
				if fadeIcon then button.gameIcon:SetAlpha(0.6); else button.gameIcon:SetAlpha(1); end

				local shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton);
				button.gameIcon:SetShown(not shouldShowSummonButton);

				hasTravelPassButton = true;
				local restriction = FriendsFrame_GetInviteRestriction(button.id);
				if restriction == INVITE_RESTRICTION_NONE then button.travelPassButton:Enable(); else button.travelPassButton:Disable(); end

                -- [[ 1. REALM FLAG LOGIC (Uses Helper) ]] --
                local flagShown = false
                if FriendGroups_SavedVars.show_flags then
                    if not button.realmFlag then
                        button.realmFlag = button:CreateTexture("realmFlag")
                        button.realmFlag:SetSize(button.gameIcon:GetWidth(), button.gameIcon:GetHeight())
                    end
                    
                    -- Use the Helper to get the correct icon and region
                    local flagTexture, _ = FriendGroups_GetRealmInfo(accountInfo.gameAccountInfo)

                    if flagTexture then
                        button.realmFlag:SetTexture(flagTexture)
                        button.realmFlag:Show()
                        button.realmFlag:ClearAllPoints()
                        button.realmFlag:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
                        flagShown = true
                    else
                        button.realmFlag:Hide()
                    end
                else
                     if button.realmFlag then button.realmFlag:Hide() end
                end

                -- [[ 2. FACTION ICON LOGIC ]] --
                if FriendGroups_SavedVars.show_faction_icons then
                    if not button.facIcon then
                        button.facIcon = button:CreateTexture("facIcon");
                        button.facIcon:SetWidth(button.gameIcon:GetWidth())
                        button.facIcon:SetHeight(button.gameIcon:GetHeight())
                    end
                    button.facIcon:ClearAllPoints();
                    
                    if flagShown then
                        button.facIcon:SetPoint("RIGHT", button.realmFlag, "LEFT", 0, 0);
                    else
                        button.facIcon:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0);
                    end
                    
                    button.facIcon:SetTexture(FriendGroups_GetFactionIcon(accountInfo.gameAccountInfo.factionName));
                    button.facIcon:Show()

                    if accountInfo.gameAccountInfo.factionName == "Horde" then
                        button.background:SetColorTexture(0.7, 0.2, 0.2, 0.2);
                    elseif accountInfo.gameAccountInfo.factionName == "Alliance" then
                        button.background:SetColorTexture(0.2, 0.2, 0.7, 0.2);
                    end
                else
                    if button.facIcon then button.facIcon:Hide() end
                end

			else
				button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
				button.gameIcon:Hide();
				infoText = FriendsFrame_GetLastOnlineText(accountInfo);
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
		crossFactionHelpTipInfo = helpTipInfo;
		crossFactionHelpTipButton = button;
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

	return nil;
end

FriendGroups_FriendsListUpdate = function(forceUpdate)
    -- GUARD: Only run if Enabled
    if not FriendGroups_Loaded then return end

	local numBNetTotal, numBNetOnline, numBNetFavorite, numBNetFavoriteOnline = BNGetNumFriends()
	local numBNetOffline = numBNetTotal - numBNetOnline
	local numBNetFavoriteOffline = numBNetFavorite - numBNetFavoriteOnline
	local numWoWTotal = C_FriendList.GetNumFriends()
	local numWoWOnline = C_FriendList.GetNumOnlineFriends()
	local numWoWOffline = numWoWTotal - numWoWOnline
	local retainScrollPosition = not forceUpdate
    
    -- FIX: Always assume search is enabled for filtering empty groups
	local hideGroups = FriendGroups_SavedVars.hide_empty_groups or
		(searchValue ~= "")

	local dataProvider = CreateDataProvider()

	if (not FriendsListFrame:IsShown() and not forceUpdate) then
		return
	end

	wipe(groupsTotal)
	wipe(groupsSorted)

	-- invites
	local numInvites = BNGetNumFriendInvites()
	if (numInvites > 0) then
		if (not GetCVarBool("friendInvitesCollapsed")) then
			for i = 1, numInvites do
				dataProvider:Insert({ id = i, buttonType = FRIENDS_BUTTON_TYPE_INVITE })
			end
		end
	end

	local bnetFriendIndex = 0;
	-- favorite friends, online and offline
	for i = 1, numBNetFavorite do
		bnetFriendIndex = bnetFriendIndex + 1;
		FriendGroups_SetGroups(bnetFriendIndex, FRIENDS_BUTTON_TYPE_BNET)
	end

	-- online Battlenet friends
	for i = 1, numBNetOnline - numBNetFavoriteOnline do
		bnetFriendIndex = bnetFriendIndex + 1
		FriendGroups_SetGroups(bnetFriendIndex, FRIENDS_BUTTON_TYPE_BNET)
	end
	-- online WoW friends
	for i = 1, numWoWOnline do
		FriendGroups_SetGroups(i, FRIENDS_BUTTON_TYPE_WOW)
	end

	-- offline Battlenet friends
	for i = 1, numBNetOffline - numBNetFavoriteOffline do
		bnetFriendIndex = bnetFriendIndex + 1
		FriendGroups_SetGroups(bnetFriendIndex, FRIENDS_BUTTON_TYPE_BNET)
	end
	-- offline WoW friends
	for i = 1, numWoWOffline do
		FriendGroups_SetGroups(i + numWoWOnline, FRIENDS_BUTTON_TYPE_WOW)
	end

	table.sort(groupsSorted, FriendGroups_SortGroupsCustom)

	for _, groupName in ipairs(groupsSorted) do
		if (not hideGroups or (hideGroups and #groupsTotal[groupName] > 0)) then
            -- [[ CHANGE START: Set default to FALSE (Expanded) ]] --
			if FriendGroups_SavedVars.collapsed[groupName] == nil then
				FriendGroups_SavedVars.collapsed[groupName] = false
			end
            -- [[ CHANGE END ]] --

			dataProvider:Insert({ buttonType = FRIENDS_BUTTON_TYPE_DIVIDER, groupName = groupName })

			if not FriendGroups_SavedVars.collapsed[groupName] then
                -- FIX: Removed "Sort by Status" logic block here
				for _, playerData in ipairs(groupsTotal[groupName]) do
					if playerData.buttonType and playerData.id then
						dataProvider:Insert({ id = playerData.id, buttonType = playerData.buttonType })
					end
				end
			end
		end
	end

	-- Empty fallback
	if dataProvider:GetSize() == 0 or (dataProvider:GetSize() == 1) then
		dataProvider:Insert({ buttonType = FRIENDS_BUTTON_TYPE_DIVIDER, groupName = L["GROUP_EMPTY"] })
	end

	-- Prevent the game from auto-selecting the first friend
	-- If the selection is locked (user hasn't clicked yet), force clear it.
	if FriendGroupsFrame.selectionLocked then
		FriendsFrame.selectedFriend = nil
		FriendsFrame.selectedFriendType = nil
	elseif not retainScrollPosition then
		FriendsFrame.selectedFriend = nil
		FriendsFrame.selectedFriendType = nil
	end

	FriendsListFrame.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition)

	-- Double ensure after setting provider to catch any auto-select artifacts
	if FriendGroupsFrame.selectionLocked then
		FriendsFrame.selectedFriend = nil
		FriendsFrame.selectedFriendType = nil
	elseif not retainScrollPosition then
		FriendsFrame.selectedFriend = nil
		FriendsFrame.selectedFriendType = nil
	end

	-- Cleanup
	for groupName, _ in pairs(FriendGroups_SavedVars.collapsed) do
		if not groupsTotal[groupName] then
			FriendGroups_SavedVars.collapsed[groupName] = nil
		end
	end

	if friendsListEmpty and (lastFriendsListEmptyWarning + 60) <= (math.floor(GetTime() + 0.5)) then
		lastFriendsListEmptyWarning = math.floor(GetTime() + 0.5)
		print(L["MSG_BUG_WARNING"])
	end
end

function FriendGroups_FilterTable(tableData, filterFunction)
	local returnTable = {}

	for key, value in pairs(tableData) do
		if filterFunction(value, key, tableData) then table.insert(returnTable, value) end
	end

	return returnTable
end

function FriendGroups_ToggleSearch(searchBox, frame)
    -- If the user has the search mode open, do NOT hide the box 
    -- even if the text is currently empty.
    if searchOpened then return end

    if searchValue == "" then
        searchBox:Hide()
        frame.name:Show()
    end
end

function FriendGroups_Search(playerId, playerButtonType)
    if searchValue == "" then return true end

    local characterName = ""
    local bnetAccountName = "" 
    local battleTag = ""
    local noteText = ""
    local realmName = ""
    local className = "" 
    local richPresence = ""
    local classMatch = false
    local returnValue = false

    local searchLower = searchValue:lower()
    local searchLen = #searchLower

    if playerButtonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = C_FriendList.GetFriendInfoByIndex(playerId);
        if info then
            characterName = info.name or ""
            noteText = info.notes or ""
            className = info.className or ""
        end
    elseif playerButtonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountInfo = C_BattleNet.GetFriendAccountInfo(playerId);
        if accountInfo then
            bnetAccountName = accountInfo.accountName or ""
            battleTag = accountInfo.battleTag or ""
            noteText = accountInfo.note or ""
            
            if accountInfo.gameAccountInfo then
                characterName = accountInfo.gameAccountInfo.characterName or ""
                realmName = accountInfo.gameAccountInfo.realmName or ""
                className = accountInfo.gameAccountInfo.className or ""
                richPresence = accountInfo.gameAccountInfo.richPresence or ""
            end
        end
    end

    -- [[ CLASS SEARCH: Starts With Only ]] --
    -- Prevents "Hunter" from finding "Demon Hunter"
    if className and className ~= "" then
        local cLower = className:lower()
        local cNoSpace = cLower:gsub(" ", "")
        
        if cLower:sub(1, searchLen) == searchLower then 
            classMatch = true 
        elseif cNoSpace:sub(1, searchLen) == searchLower then
            classMatch = true
        end
    end

    -- [[ GENERAL SEARCH ]] --
    -- Searches: Name, BTag, Note, Realm Name (e.g. "Frostmourne"), and Rich Presence (e.g. "Nightslayer")
    if (bnetAccountName:lower():find(searchLower, 1, true)) or 
       (battleTag:lower():find(searchLower, 1, true)) or 
       (characterName:lower():find(searchLower, 1, true)) or
       (noteText:lower():find(searchLower, 1, true)) or
       (realmName:lower():find(searchLower, 1, true)) or
       (richPresence:lower():find(searchLower, 1, true)) or 
       classMatch then
        returnValue = true
    end

    return returnValue
end

function FriendGroups_FriendsListUpdateDividerTemplate(frame, elementData)
    local groupName = elementData.groupName
    local groupOnline = groupsCount[groupName] and groupsCount[groupName]["Online"] or 0
    local groupTotal = groupsCount[groupName] and groupsCount[groupName]["Total"] or 0

    if groupName and frame.name then
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
        frame.name:SetText(groupName)
        frame.collapseButton:Show()
        if frame.info then frame.info:Show() end

        if groupName ~= L["GROUP_EMPTY"] then
            local groupInfo = string.format("%d/%d", groupOnline, groupTotal)
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

    local groupName = frame.name:GetText()
    
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

function FriendGroups_FrameFriendDividerTemplateHeaderClick(self, button, down)
    local groupName = self and self:GetParent() and self:GetParent().name and self:GetParent().name:GetText() or
        self.name and self.name:GetText()

    -- Focus the search box if the user clicks the search bar area
    if groupName == "Search..." then
        if _G["FriendGroupsSearch"] then
            _G["FriendGroupsSearch"]:SetFocus()
        end
    elseif button == "RightButton" then
        -- [[ CHANGE START ]] --
        -- Fix: Pass 'groupName' as the value, not 'self'
        if groupName then
            ToggleDropDownMenu(1, groupName, FriendGroups_Menu, "cursor", 0, 0)
        end
        -- [[ CHANGE END ]] --
    else
        FriendGroups_FrameFriendDividerTemplateCollapseClick(self, button, down)
    end
end

FriendGroups_FriendsListButtonTemplateClick = function(self, button, down)
    if not FriendGroups_Loaded then return end -- Let Blizzard handle click if disabled
    
    if button == "LeftButton" and IsShiftKeyDown() then
        -- Handle Shift+Click for Custom Menu (Prevents Taint)
        local id = self.id
        local buttonType = self.buttonType
        local name = nil
        local bnetfriend = false

        if buttonType == FRIENDS_BUTTON_TYPE_WOW then
            local info = C_FriendList.GetFriendInfoByIndex(id)
            if info then name = info.name end
        elseif buttonType == FRIENDS_BUTTON_TYPE_BNET then
            local info = C_BattleNet.GetFriendAccountInfo(id)
            if info then 
                name = info.accountName 
                bnetfriend = true
            end
        end

        if name then
            FriendGroups_ClickedData = { name = name, bnetfriend = bnetfriend, id = id }
            ToggleDropDownMenu(1, nil, FriendGroups_ContextDropdown, "cursor", 0, 0)
        end
        
        return -- Stop here so we don't select the friend in the UI
    end

    -- Normal Click Behavior (Standard Selection)
    FriendGroupsFrame.selectionLocked = false
	FriendGroups_FriendsListUpdate()
end

function FriendGroups_FriendsFrameUpdateFriendInviteHeaderButton(button, elementData)
	button:SetFormattedText(FRIEND_REQUESTS, BNGetNumFriendInvites());
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

	local inviteID, accountName = BNGetFriendInviteInfo(id);
	button.Name:SetText(accountName);
	button.inviteID = inviteID;
	button.inviteIndex = button.id;
end

-- [[ MAIN INITIALIZATION ]] --
local frame = CreateFrame("frame", "FriendGroups")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:RegisterEvent("QUEST_SESSION_CREATED")

frame:SetScript("OnEvent", function(self, event, arg1, ...)
if event == "ADDON_LOADED" and arg1 == addonName then
        local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Unknown"
        Print(string.format(L["MSG_WELCOME"], version))
        
        -- [[[ DELETE OR COMMENT OUT THIS LINE ]]] --
        -- self:UnregisterEvent("ADDON_LOADED") 
        -- [[[ END CHANGE ]]] --

    elseif event == "PARTY_INVITE_REQUEST" then
        if FriendGroups_SavedVars and FriendGroups_SavedVars.auto_accept_invite then
            AcceptGroup()
            StaticPopup_Hide("PARTY_INVITE")
            StaticPopup_Hide("PARTY_INVITE_REQUEST")
            StaticPopup_Hide("PARTY_INVITE_XREALM")
        end

    -- [[ SMART FIX: Auto Accept Party Sync ]] --
    elseif event == "QUEST_SESSION_CREATED" then
        if FriendGroups_SavedVars and FriendGroups_SavedVars.auto_accept_sync then
            
            -- DEFINITION: A recursive function that tries to click, catches crashes, and retries.
            local function AttemptSyncAccept()
                -- 1. Stop if the dialog is gone (User closed it, or we already accepted)
                if not (QuestSessionManager and QuestSessionManager.StartDialog and QuestSessionManager.StartDialog:IsShown()) then
                    return 
                end

                -- 2. "Protected Call" (pcall). This wraps the click in a safety bubble.
                -- success = true if it clicked okay. 
                -- success = false if Blizzard's code crashed (nil table error).
                local success, err = pcall(function()
                    QuestSessionManager.StartDialog:Confirm()
                end)

                if success then
                    -- It worked! Clean up the UI.
                    QuestSessionManager.StartDialog:Hide()
                else
                    -- It crashed (Race Condition). 
                    -- We ignore the crash and try again in 0.5 seconds.
                    C_Timer.After(0.5, AttemptSyncAccept)
                end
            end

            -- START the loop
            AttemptSyncAccept()
        end

    elseif event == "PLAYER_LOGIN" then
        -- Default Saved Vars
        if not FriendGroups_SavedVars then
            FriendGroups_SavedVars = { collapsed = {}, hide_offline = true, colour_classes = true, show_faction_icons = true, show_realm = true, hide_high_level = true, add_favorite_group = true, add_mobile_text = true, show_search = true, auto_accept_invite = false, housing_mode_active = false, auto_accept_sync = false }
        end

        -- 1. Capture the current mode
        local isHousingMode = FriendGroups_SavedVars.housing_mode_active

        -- 2. AUTO-RESET: Immediately flip the saved var to false.
        if isHousingMode then
            FriendGroups_SavedVars.housing_mode_active = false
        end

        if isHousingMode then
            -- [[ SAFE MODE (HOUSING) ACTIVE ]] --
            local masterBtn = CreateFrame("Button", "FriendGroupsMasterControl", FriendsListFrame, "UIPanelButtonTemplate")
            
            masterBtn:SetFrameStrata("FULLSCREEN_DIALOG") 
            masterBtn:SetFrameLevel(9999)                 
            
            masterBtn:SetSize(374, 28)
            masterBtn:SetPoint("TOP", FriendsListFrame, "TOP", 0, -57)
            
            masterBtn:SetText("|cff3AFF00" .. L["RELOAD_BTN_TEXT"] .. "|r")
            
            masterBtn:SetScript("OnClick", function()
                ReloadUI()
            end)

            masterBtn:SetScript("OnEnter", function(s) 
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["RELOAD_TOOLTIP_TITLE"])
                GameTooltip:AddLine(L["RELOAD_TOOLTIP_DESC"], 1, 1, 1)
                GameTooltip:Show()
            end)
            masterBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            Print(L["SAFE_MODE_WARNING"])
        else
            -- [[ NORMAL MODE ]] --
            EnableFriendGroups()
        end

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
    end
    
-- [[ HOUSING SAFETY SHIELD ]] --
    if event == "ADDON_LOADED" and arg1 == "Blizzard_HouseList" then
        if FriendGroups_Loaded then
            local w = CreateFrame("Frame", nil, HouseListFrame)
            w:SetFrameStrata("DIALOG")
            w:SetAllPoints(HouseListFrame)
            w:EnableMouse(true)
            
            local bg = w:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0, 0, 0, 0.9)
            
            local msg = w:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            msg:SetPoint("CENTER", 0, 30)
            msg:SetText(L["SHIELD_MSG"])
            
            local b = CreateFrame("Button", nil, w, "UIPanelButtonTemplate")
            b:SetSize(200, 30)
            b:SetPoint("CENTER", 0, -50)
            b:SetText(L["SHIELD_BTN_TEXT"])
            b:SetScript("OnClick", function()
                FriendGroups_SavedVars.housing_mode_active = true
                ReloadUI()
            end)
        end
    end
end)

