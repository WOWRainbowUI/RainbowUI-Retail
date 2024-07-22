--[[	LOIHLoot
------------------------------------------------------------------------

Gives players option to create Wishlists from raid drops. For guild
officers addon also gives option to synchronize data from all raid
members to give them idea what bosses should be focused lootwise for
maximum chance of getting upgrades.

------------------------------------------------------------------------

Following text is/has been correct for 6.0-6.1:

Personal loot gives as much loot as Group loot in the long run (calculated
using Binomial probability, assuming same drop chance for all loot methods
until confirmed otherwise by Blizzard). Napkin math supports the theory of,
unless you are min-maxing your raids progress and loot distribution (usually
dps > tanks > healers) or riging the raid composition in favor of you getting
the loot you want (30 person pug raid, and you are the only hunter in the raid
and hoping for weapon to drop), Personal loot is better loot method at the
start of the new raid tier or difficulty when everyone need loot from (almost)
all of the bosses.

This should be accurate while half or more of players in the raid need loot
from the boss and even beyond that point if the raid composition is heavily
unbalanced and stacked players who want same item(s). Unless you are in real
cutting edge raiding guild doing multiple mixed runs before Mythic raids open,
you should at least consider running few first weeks with Personal loot to
maximize the loot potential of your group.

N.B.: You running the raids for few weeks doesn't give you enough data to do
any real statistics with few dozen boss kills compared to hundreds of thousands
to millions of boss kills Blizzard records per week.

------------------------------------------------------------------------

For 6.2 Personal loot WILL yield more loot than Group loot:

- http://eu.battle.net/wow/en/blog/19162236?page=1#1
	"First, rather than treating loot chances independently for each player —
	sometimes yielding only one or even zero items for a group — we’ll use a
	system similar to Group Loot to determine how many items a boss will award
	based on eligible group size. As a result, groups will receive a much more
	predictable number of drops when they defeat a boss. In addition, set items
	will reliably drop in Personal Loot, just like they do in Group Loot today.
	The end result is that groups using Personal Loot will acquire their 2- and
	4-piece set bonuses at around the same time as groups using Group Loot
	acquire theirs.

	We’re also increasing the overall rate of reward for Personal Loot, giving
	players more items overall to offset the fact that Personal Loot rewards
	can’t be distributed among group members. We know that finding that one
	awesome specific trinket to round out your gear set can be difficult with
	Personal Loot, and this should help increase your odds."

- http://us.battle.net/wow/en/forum/topic/17346368401?page=1#20
	"- More items will drop on average for a raid using 6.2 Personal Loot than
	would have dropped using 6.0/6.1 Personal Loot.

	- More items will drop on average for a raid using 6.2 Personal Loot than
	would drop for that raid using any form of Group Loot (Master, Need/Greed,
	etc.)."

You should use Personal loot always unless you are min-maxing progress and loot
distribution, funneling loot to someone or your raid is almost fully geared.

------------------------------------------------------------------------

For 8.0 Personal loot is the ONLY loot method for groups
	- Said by Ion Hazzikostas (aka "Watcher") in BfA Q&A

------------------------------------------------------------------------
MEMO for future features:

BOSS_KILL
	1951 -- encounterID (DungeonEncounterID)
	Flotsam -- name

SPELL_CONFIRMATION_PROMT
	227131 -- spellID
	1 -- confirmType
	"" -- text
	180 -- timeout
	1273 -- currencyID
	1 -- currencyCost
	14 -- difficultyID

SPELL_CONFIRMATION_TIMEOUT
	227131 -- spellID
	1 -- confirmType

BonusRollFrame = {
	currencyID = 1273,
	difficultyID = 14,
	encounterID = 1795,
	instanceID = 822,
	spellID = 227131
}

GetCurrencyInfo(1273)
	[name] = "Seal of Broken Fate",
	[amount] = 6,
	[texture] = 1604167,
	[earnedThisWeek] = 0,
	[weeklyMax] = 0,
	[totalMax] = 6,
	[isDiscovered] = true,
	[rarity] = 1

GetDifficultyInfo(14)
	[name] = "Normal",
	[groupType] = "raid",
	[isHeroic] = false,
	[isChallengeMode] = false,
	[displayHeroic] = false,
	[displayMythic] = false,
	[toggleDifficultyID] = false

EJ_GetEncounterInfo(1795)
	[name] = "Flotsam",
	[description] = "Flotsam emerged from the ocean depths to sate his hunger. The first to cross his path were the swamp murlocs of Shipwreck Cove, which Flotsam devoured by the dozens. Despite consuming most of their tr"...+209,
	[encounterID] = 1795,
	[rootSectionID] = 13841,
	[link] = "|cff66bbff|Hjournal:1:1795:0|h[Flotsam]|h|r",
	[instanceID] = 822

EJ_GetInstanceInfo(822)
	[name] = "Broken Isles",
	[description] = "This area once stood as the cradle of elven civilization, centered around the ancient elven capital of Suramar, until the Sundering tore the land apart. While the power of the Nightwell preserved the "...+311,
	[bgImage] = 1411842,
	[icon] = 1411854,
	[loreImage] = 1411848,
	[buttonImage] = 1411866,
	[dungeonAreaMapID] = 0,
	[link] = "|cff66bbff|Hjournal:0:822:14|h[Broken Isles]|h|r",
	[shouldDisplayDifficulty] = false

GetSpellInfo(227131)
	[name] = "7.0 Raid World Boss - Bonus Roll Prompt",
	[rank] = nil,
	[icon] = 136243,
	[castTime] = 0,
	[minRange] = 0,
	[maxRange] = 50000,
	[spellId] = 227131

]]--

local ADDON_NAME, private = ...
LOIHLOOT_GLOBAL_PRIVATE = private
local L = private.L
local cfg, db, LOIHLootFrame

local _G = _G
local C_ChatInfo = C_ChatInfo
local C_GuildInfo = C_GuildInfo
local C_Timer = C_Timer
local math = math

-- Private constants
private.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
private.description = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Notes")
private.LIST_BUTTON_HEIGHT = 23		-- actually 25, but with a y-offset shrinking by 2

--	Local variables
local _commType = "RAID"		-- Channel used for AddonMessages
local _latestTier = 0			-- InstanceID of the raid tier you want to be open on start (usually the latest), leave empty for all tiers being collapsed on start.
local _lastSync = L.NEVER		-- Timestamp of the last SyncRequest
local _raidCount = 0			-- Players in raid group
local _syncReplies = 0			-- SyncReplies from raid group
local _syncLock = false			-- Is Sync-button disabled?
local SyncTable = {}			-- Sync-data list
local SyncNames = {}			-- Sync-names list if 'namesPerBoss' is enabled
local filteredList = {}			-- Filtered list
local openHeaders = {}			-- Open headers
local _syncStatus = ""			-- Status of Sync-data
local syncedRoster = {}			-- Table to keep track of Synced people, 0 = unsynced, 1 = no reply, 2 = synced
local currentRoster = {}		-- Helper table to keep track of roster changes
local normalDifficultyID = Enum.ItemCreationContext.RaidNormal	-- difficultyID for normal because LFR is higher than normal difficulty, LFR = 4, N = 3, H = 5, M = 6

local ignoredInstaces = {		-- Ignored instanceIDs when populating Raids-table
	-- World Bosses
	[322] = true, -- MoP
	[557] = true, -- WoD
	[822] = true, -- Legion
	[1028] = true, -- BfA
	[1192] = true, -- SL
	[1205] = true, -- DF

	-- Other
	[959] = true, -- Invasion Points (Legion)
}
local RaidInstanceOrder = {}	-- Get instances in right order in the main view
local Raids = {}				-- Populated with RaidIDs and BossIDs later

local itemLinks = {}			-- Store itemLinks for fewer function calls
local bossNames = {}			-- Store raid boss names here for fewer function calls
local cfgDefaults = {
	debugmode = false,			-- Debug printing
	namesPerBoss = false,		-- Store names of those players who need loot from bosses
}
local charDefaults = {
	main = {},
	off = {},
	vanity = {}
}

-- Custom Textures
local emptyTex = "Interface\\AddOns\\LOIHLoot\\Tex\\EMPTY.tga"
local checkTex = "Interface\\AddOns\\LOIHLoot\\Tex\\CHECK.tga"
local upTex = "Interface\\AddOns\\LOIHLoot\\Tex\\UP.tga"
local downTex = "Interface\\AddOns\\LOIHLoot\\Tex\\DOWN.tga"
local highlightTex = "Interface\\AddOns\\LOIHLoot\\Tex\\HIGHLIGHT.tga"
local normalFontColor = { 1, .82, 0 } -- R, G, B of GameFontNormal
local highPercentColor = { 0, 1, 0 } -- R, G, B of High wishlist boss

local scantip = CreateFrame("GameTooltip", ADDON_NAME.."ScanningTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

------------------------------------------------------------------------
--	Local functions
------------------------------------------------------------------------

local function Debug(text, ...)
	if not cfg or not cfg.debugmode then return end

	if text then
		if text:match("%%[dfqsx%d%.]") then
			(DEBUG_CHAT_FRAME or (ChatFrame3:IsShown() and ChatFrame3 or ChatFrame4)):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. format(text, ...))
		else
			(DEBUG_CHAT_FRAME or (ChatFrame3:IsShown() and ChatFrame3 or ChatFrame4)):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end

local function Print(text, ...)
	if text then
		if text:match("%%[dfqs%d%.]") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. format(text, ...))
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end

local function initDB(db, defaults) -- This function copies values from one table into another:
	if type(db) ~= "table" then db = {} end
	if type(defaults) ~= "table" then return db end
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			db[k] = initDB(db[k], v)
		elseif type(v) ~= type(db[k]) then
			db[k] = v
		end
	end
	return db
end

local function _RGBToHex(r, g, b)
	r = r <= 255 and r >= 0 and r or 0
	g = g <= 255 and g >= 0 and g or 0
	b = b <= 255 and b >= 0 and b or 0
	return format("%02x%02x%02x", r, g, b)
end

local function _CheckLink(link) -- Return itemID and difficultyID from itemLink
	if not link then -- No link given
		return
	elseif itemLinks[link] and itemLinks[link].id ~= nil then -- Check if we have scanned this item already
		return itemLinks[link].id, itemLinks[link].difficulty
	end

	--item:itemID:enchantID:gemID1:gemID2:gemID3:gemID4:suffixID:uniqueID:linkLevel:specializationID:upgradeTypeID:instanceDifficultyID:numBonusIDs
	local _, itemID, _, _, _, _, _, _, _, _, _, _, difficultyID = strsplit(":", link)
	itemID = tonumber(itemID)
	difficultyID = tonumber(difficultyID)
	itemLinks[link] = { id = itemID, difficulty = difficultyID } -- Add to table for faster access later

	return itemID, difficultyID
end

local function _IsOfficer() -- Check if Player can speak on Officer chat
	local playerRank = C_GuildInfo.GetGuildRankOrder("player")
	local _, _, _, officerChat_Speak = C_GuildInfo.GuildControlGetRankFlags(playerRank)

	return officerChat_Speak == true
end

local function _TimeStamp() -- Generate timestamps
	local timeTable = date("*t")
	return format("%02d:%02d %d.%d.%d", timeTable.hour, timeTable.min, timeTable.day, timeTable.month, timeTable.year)
end

local function _WishlistOnEnter(button, ...) -- EJ Wishlist-buttons OnEnter-script
	local subTable, tooltipTitleText
	if button:GetID() == 1 then
		subTable = "main"
		tooltipTitleText = L.MAINTOOLTIP
	elseif button:GetID() == 2 then
		subTable = "off"
		tooltipTitleText = L.OFFTOOLTIP
	elseif button:GetID() == 3 then
		subTable = "vanity"
		tooltipTitleText = L.VANITYTOOLTIP
	else
		Debug("OnEnter: No subTable")
		return
	end

	local itemID, difficultyID = _CheckLink(button:GetParent():GetParent().link)

	if db[subTable][itemID] and db[subTable][itemID].difficulty == difficultyID then -- Remove
		button.tooltipText = format("|cffffcc00"..tooltipTitleText.."|r\n%s", L.TOOLTIP_WISHLIST_REM)
	elseif db[subTable][itemID] and db[subTable][itemID].difficulty > difficultyID then -- Downgrade
		button.tooltipText = format("|cffffcc00"..tooltipTitleText.."|r\n%s", L.TOOLTIP_WISHLIST_HIGHER)
	elseif db[subTable][itemID] and db[subTable][itemID].difficulty < difficultyID then -- Upgrade
		button.tooltipText = format("|cffffcc00"..tooltipTitleText.."|r\n%s", L.TOOLTIP_WISHLIST_LOWER)
	else -- Add
		button.tooltipText = format("|cffffcc00"..tooltipTitleText.."|r\n%s", L.TOOLTIP_WISHLIST_ADD)
	end

	GameTooltip:SetOwner(button, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOM", button, "TOP", 0, 5)
	GameTooltip:SetText(button.tooltipText, 1, 1, 1)
end

local function _WishlistOnLeave(button, ...) -- EJ Wishlist-buttons OnLeave-script
	GameTooltip:Hide()
end

local function _WishlistOnClick(button, ...) -- EJ Wishlist-buttons OnClick-script
	Debug("Click:", button:GetParent():GetParent().itemID, button:GetParent():GetParent().link, button:GetParent():GetParent().encounterID)
	
	local subTable = button:GetID() == 1 and "main" or button:GetID() == 2 and "off" or button:GetID() == 3 and "vanity" or false
	local itemID, difficultyID = _CheckLink(button:GetParent():GetParent().link)

	Debug("> ID:", button:GetID(), tostring(subTable))
	if not (itemID and difficultyID and subTable) then return end

	if db[subTable][itemID] and db[subTable][itemID].difficulty == difficultyID then -- Remove
		Debug("Remove:", itemID, difficultyID)

		db[subTable][itemID] = nil
	elseif db[subTable][itemID] and db[subTable][itemID].difficulty > difficultyID then -- Downgrade
		Debug("Downgrade:", itemID, db[subTable][itemID].difficulty, ">", difficultyID)

		db[subTable][itemID].difficulty = difficultyID
	elseif db[subTable][itemID] and db[subTable][itemID].difficulty < difficultyID then -- Upgrade
		Debug("Upgrade:", itemID, db[subTable][itemID].difficulty, "<", difficultyID)

		db[subTable][itemID].difficulty = difficultyID
	else -- Add
		Debug("Add:", itemID, difficultyID)

		db[subTable][itemID] = { difficulty = difficultyID, encounter = button:GetParent():GetParent().encounterID }
		if subTable == "main" then -- Don't allow same item to be on both MS and OS lists
			db.off[itemID] = nil
			button:GetParent():GetParent().LOIHLoot.off:SetNormalTexture(emptyTex)
		elseif subTable == "off" then
			db.main[itemID] = nil
			button:GetParent():GetParent().LOIHLoot.main:SetNormalTexture(emptyTex)
		end
	end

	_WishlistOnEnter(button, ...)
end

local buttonCount = 0
local function _CreateButtons(button) -- Create small Wishlist-buttons to EJ's loot view
	Debug("Button Factory running", buttonCount + 1)

	--for i = 1, 8 do
		--local button = _G["EncounterJournalEncounterFrameInfoLootScrollFrameButton"..i]
		if button and not button.LOIHLoot then
			buttonCount = buttonCount + 1
			local container = CreateFrame("Frame", "LOIHLootButtons"..buttonCount, button)
			container:SetSize(37, 16)
			container:SetPoint("TOPRIGHT", -5, -5)

			local vanityButton = CreateFrame("Button", "$parentVanity", container)
			vanityButton:SetSize(16, 16)
			vanityButton:SetNormalTexture(emptyTex)
			vanityButton:SetHighlightTexture(highlightTex, "BLEND")
			vanityButton:ClearAllPoints()
			vanityButton:SetPoint("RIGHT")
			vanityButton:SetID(3)
			vanityButton:SetScript("OnClick", _WishlistOnClick)
			vanityButton:SetScript("OnEnter", _WishlistOnEnter)
			vanityButton:SetScript("OnLeave", _WishlistOnLeave)

			container.vanity = vanityButton

			local offButton = CreateFrame("Button", "$parentOff", container)
			offButton:SetSize(16, 16)
			offButton:SetNormalTexture(emptyTex)
			offButton:SetHighlightTexture(highlightTex, "BLEND")
			offButton:ClearAllPoints()
			offButton:SetPoint("RIGHT")
			offButton:SetID(2)
			offButton:SetScript("OnClick", _WishlistOnClick)
			offButton:SetScript("OnEnter", _WishlistOnEnter)
			offButton:SetScript("OnLeave", _WishlistOnLeave)

			container.off = offButton

			local mainButton = CreateFrame("Button", "$parentMain", container)
			mainButton:SetSize(16, 16)
			mainButton:SetNormalTexture(emptyTex)
			mainButton:SetHighlightTexture(highlightTex, "BLEND")
			mainButton:ClearAllPoints()
			mainButton:SetPoint("RIGHT", offButton, "LEFT", -5, 0)
			mainButton:SetID(1)
			mainButton:SetScript("OnClick", _WishlistOnClick)
			mainButton:SetScript("OnEnter", _WishlistOnEnter)
			mainButton:SetScript("OnLeave", _WishlistOnLeave)

			container.main = mainButton

			button.LOIHLoot = container
		end
	--end
end

local function _PopulateRaids() -- Populate Raids-table from EJ
	Debug("Populate Raids-table")

	local tiers = EJ_GetNumTiers()
	--for i = 1, tiers do
		--EJ_SelectTier(i)
		EJ_SelectTier(tiers) -- Only populate with the newest expansion data.

		local index = 1
		local instanceID = EJ_GetInstanceByIndex(index, true)
		while instanceID do
			if not ignoredInstaces[instanceID] then
				RaidInstanceOrder[#RaidInstanceOrder + 1] = instanceID
				Raids[instanceID] = Raids[instanceID] or {}
				if instanceID > _latestTier then
					_latestTier = instanceID
				end

				EJ_SelectInstance(instanceID)
				--local instanceName = EJ_GetInstanceInfo()
				local EJIndex = 1
				local bossName, _, bossID = EJ_GetEncounterInfoByIndex(EJIndex)
				while bossName do
					Raids[instanceID][#Raids[instanceID] + 1] = bossID

					EJIndex = EJIndex + 1
					bossName, _, bossID = EJ_GetEncounterInfoByIndex(EJIndex)
				end
			end

			index = index + 1
			instanceID = EJ_GetInstanceByIndex(index, true)
		end
	--end

	if _latestTier > 0 then
		openHeaders[EJ_GetInstanceInfo(_latestTier)] = true
		private.FilterList()
		private.Frame_UpdateList()
	end
end

local _CheckGear, _CheckBags
do -- _CheckGear() - Checks equipment for items on wishlist
	local throttling

	local function DelayedCheck()
		for i = 1, 17 do -- Skip the shirt (4) and tabard (18)
			if i ~= 4 then
				local itemID, difficultyID = _CheckLink(GetInventoryItemLink("Player", i))

				for subTable in pairs(db) do
					--if db[subTable][itemID] and db[subTable][itemID].difficulty <= difficultyID then -- Item found, upgrade or remove from wishlist
					if db[subTable][itemID] then
						if db[subTable][itemID].difficulty <= difficultyID then -- Item found, upgrade or remove from wishlist
							if difficultyID >= Enum.ItemCreationContext.RaidMythic then -- Mythic or something went wrong (>= 6)
								Debug("Remove by Equiped:", itemID, difficultyID, subTable)

								db[subTable][itemID] = nil
							elseif difficultyID == Enum.ItemCreationContext.RaidFinder then -- LFR (is between normal and heroic, drop down to normal) (== 4)
								Debug("Upgraded by Equiped:", itemID, difficultyID, normalDifficultyID, subTable)

								db[subTable][itemID].difficulty = normalDifficultyID
							elseif difficultyID == normalDifficultyID then -- Normal difficulty (LFR is between normal and heroic for some reason, skip LFR) (== 3)
								Debug("Upgraded by Equiped:", itemID, difficultyID, Enum.ItemCreationContext.RaidHeroic, subTable)

								db[subTable][itemID].difficulty = Enum.ItemCreationContext.RaidHeroic
							else -- Heroic (5)
								Debug("Upgraded by Equiped:", itemID, difficultyID, Enum.ItemCreationContext.RaidMythic, subTable)

								db[subTable][itemID].difficulty = Enum.ItemCreationContext.RaidMythic
							end
						elseif db[subTable][itemID].difficulty > Enum.ItemCreationContext.RaidMythic then -- Bugged item, shouldn't exist (> 6)
							Debug("Remove BUGGED by Equiped:", itemID, difficultyID, subTable)

							db[subTable][itemID] = nil
						end
					end
				end
			end
		end

		private:PLAYER_ENTERING_WORLD() -- Update Wishlist on BonusRollFrame

		throttling = nil
	end

	function _CheckGear()
		if not throttling then
			Debug("Check Gear")

			C_Timer.After(0.5, DelayedCheck)
			throttling = true
		end
	end
end

do -- _CheckBags() - Checks inventory for items on wishlist
	local throttling

	local function DelayedCheck()
		local bag, slot = 0, 0
		for bag = 0, NUM_BAG_SLOTS do
			local numSlots
			if C_Container then
				numSlots = C_Container.GetContainerNumSlots(bag)
			else
				numSlots = GetContainerNumSlots(bag)
			end
			for slot = 1, numSlots do
				local itemLink
				if C_Container then
					itemLink = C_Container.GetContainerItemLink(bag, slot)
				else
					itemLink = GetContainerItemLink(bag, slot)
				end
				local itemID, difficultyID = _CheckLink(itemLink)

				for subTable in pairs(db) do
					--if db[subTable][itemID] and db[subTable][itemID].difficulty <= difficultyID then -- Item found, upgrade or remove from wishlist
					if db[subTable][itemID] then
						if db[subTable][itemID].difficulty <= difficultyID then -- Item found, upgrade or remove from wishlist
							if difficultyID >= Enum.ItemCreationContext.RaidMythic then -- Mythic or something went wrong (>= 6)
								Debug("Remove by Bags:", itemID, difficultyID, subTable)

								db[subTable][itemID] = nil
							elseif difficultyID == Enum.ItemCreationContext.RaidFinder then -- LFR (is between normal and heroic, drop down to normal) (== 4)
								Debug("Upgraded by Bags:", itemID, difficultyID, normalDifficultyID, subTable)

								db[subTable][itemID].difficulty = normalDifficultyID
							elseif difficultyID == normalDifficultyID then -- Normal difficulty (LFR is between normal and heroic for some reason, skip LFR) (== 3)
								Debug("Upgraded by Bags:", itemID, difficultyID, Enum.ItemCreationContext.RaidHeroic, subTable)

								db[subTable][itemID].difficulty = Enum.ItemCreationContext.RaidHeroic
							else -- Heroic (5)
								Debug("Upgraded by Bags:", itemID, difficultyID, Enum.ItemCreationContext.RaidMythic, subTable)

								db[subTable][itemID].difficulty = Enum.ItemCreationContext.RaidMythic
							end
						elseif db[subTable][itemID].difficulty > Enum.ItemCreationContext.RaidMythic then -- Bugged item, shouldn't exist (> 6)
							Debug("Remove BUGGED by Bags:", itemID, difficultyID, subTable)

							db[subTable][itemID] = nil
						end
					end
				end
			end
		end

		private:PLAYER_ENTERING_WORLD() -- Update Wishlist on BonusRollFrame

		throttling = nil
	end

	function _CheckBags()
		if not throttling then
			Debug("Check Bags")

			C_Timer.After(0.5, DelayedCheck)
			throttling = true
		end
	end
end

local function _GetBossName(bossID)
	if not bossID then -- No ID given
		return
	elseif bossNames[bossID] and bossNames[bossID] ~= nil then -- Check if we have scanned this boss already
		return bossNames[bossID]
	end

	bossNames[bossID] = EJ_GetEncounterInfo(bossID)

	return bossNames[bossID]
end

local function _SyncLine() -- Form the "Last sync"-line for textelement
	local difficultyName = L.UNKNOWN
	if private.difficultyID == DifficultyUtil.ID.PrimaryRaidNormal then 	-- Normal Raid (14)
		difficultyName = PLAYER_DIFFICULTY1
	elseif private.difficultyID == DifficultyUtil.ID.PrimaryRaidHeroic then -- Heroic Raid (15)
		difficultyName = PLAYER_DIFFICULTY2
	elseif private.difficultyID == DifficultyUtil.ID.PrimaryRaidMythic then -- Mythic Raid (16)
		difficultyName = PLAYER_DIFFICULTY6
	end

	if _lastSync == L.NEVER then
		return format(L.SHORT_SYNC_LINE, _lastSync)
	end

	return format(L.SYNC_LINE, difficultyName, _lastSync, _syncReplies, math.max(_raidCount, _syncReplies))
end

local function _SendSyncRequest(difficulty) -- Send SyncRequest to raid
	Debug("> Sending SyncRequest:", difficulty)
	if not difficulty then return end

	for k in pairs(syncedRoster) do
		syncedRoster[k] = 1 -- Kilroy was here at the time of sync
	end

	local err = C_ChatInfo.SendAddonMessage(ADDON_NAME, "SyncRequest-"..difficulty, _commType)

	Debug(">>> Success:", err)
end

local function _ProcessReply(sender, data) -- Process received SyncReplies
	Debug("Process SyncReply", sender, data)
	_syncReplies = _syncReplies + 1
	if syncedRoster[sender] then
		Debug(">>Found", sender)
		syncedRoster[sender] = 2 -- Synced
	else
		Debug(">>!Found", sender)
	end
	private.Frame_SetDescriptionText("%s\n\n%s", _SyncLine(), L.SENDING_SYNC)
	if data == "" then return end

	local subTable
	for i, subData in pairs({ strsplit("#", data) }) do
		if i == 1 then
			subTable = "main"
		elseif i == 2 then
			subTable = "off"
		elseif i == 3 then
			subTable = "vanity"
		end

		for _, encounter in pairs({ strsplit(":", subData) }) do
			encounter = tonumber(encounter)
			if encounter then
				if not SyncTable[subTable][encounter] then
					SyncTable[subTable][encounter] = 1
				else
					SyncTable[subTable][encounter] = SyncTable[subTable][encounter] + 1
				end

				if cfg.namesPerBoss then -- Save player names per boss
					if not SyncNames[encounter] then
						SyncNames[encounter] = {}
					end
					SyncNames[encounter][sender] = true
				end

				Debug("-", encounter, sender)
			end
		end
	end

	if cfg.debugmode then -- DEBUG
		for k, v in pairs(SyncTable) do
			for i, d in pairs(v) do
				if k then
					Debug("#", k, i, d)
				end
			end
		end
	end

	_syncStatus = GREEN_FONT_COLOR_CODE .. L.SYNCSTATUS_OK .. FONT_COLOR_CODE_CLOSE
	LOIHLootFrame.SyncText:SetText(_syncStatus)
	private.FilterList()
	private.Frame_UpdateList()
end

local function _SyncReply(difficulty) -- Send SyncReply
	local function _contains(table, element)
		for _, v in pairs(table) do
			if v == element then
				Debug(">> _contains", element)
				return true
			end
		end
		Debug(">> !_contains", element)
		return false
	end

	local function EnableButton()
		_syncLock = false
		private.Frame_UpdateButtons()
	end

	if not difficulty then return end
	Debug("> Sending SyncReply", difficulty)

	if not _syncLock then -- Locking Sync-button to prevent spam
		_syncLock = true
		LOIHLootFrame.SyncButton:Disable()
		C_Timer.After(15, EnableButton)
	end

	_lastSync = _TimeStamp()
	_syncReplies = 0
	_raidCount = GetNumGroupMembers()
	wipe(SyncTable)
	SyncTable = initDB(SyncTable, charDefaults)
	wipe(SyncNames)

	LOIHLootFrame.selectedID = nil -- Deselect previous selection since we are going to change the bottom text anyway
	private.Frame_SetDescriptionText("%s\n\n%s", _SyncLine(), L.SENDING_SYNC)
	private.FilterList()
	private.Frame_UpdateList()

	local dataMain, dataOff, dataVanity = {}, {}, {}

	for subTable, tableData in pairs(db) do
		for itemID, itemData in pairs(tableData) do
			Debug(">>>", subTable, itemID, type(itemData) == "table" and itemData.difficulty or type(itemData))
			if itemData and itemData.difficulty <= tonumber(difficulty) then
				Debug("+", subTable, itemData.encounter, itemData.difficulty)
				if subTable == "main" then
					if not _contains(dataMain, itemData.encounter) then
						dataMain[#dataMain + 1] = itemData.encounter
					end
				elseif subTable == "off" then
					if not _contains(dataOff, itemData.encounter) then
						dataOff[#dataOff + 1] = itemData.encounter
					end
				elseif subTable == "vanity" then
					if not _contains(dataVanity, itemData.encounter) then
						dataVanity[#dataVanity + 1] = itemData.encounter
					end
				end
			end
		end
	end

	local replyMain = strjoin(":", unpack(dataMain))
	local replyOff = strjoin(":", unpack(dataOff))
	local replyVanity = strjoin(":", unpack(dataVanity))
	Debug("+++\n", replyMain, "\n", replyOff, "\n", replyVanity, "\n", "(".._syncReplies.."/".._raidCount..")")
	local reply = replyMain .. "#" .. replyOff .. "#" .. replyVanity
	local err = C_ChatInfo.SendAddonMessage(ADDON_NAME, "SyncReply-"..(reply or ""), _commType)

	Debug(">>> Success:", err)
end

local function _Reset() -- Reset Character's wishlist and SyncTable
	_syncReplies = 0
	_raidCount = 0
	wipe(SyncTable)
	wipe(SyncNames)
	wipe(db)
	db = initDB(db, charDefaults)

	wipe(filteredList)
	private.FilterList()
	private.Frame_UpdateList()
	LOIHLootFrame.selectedID = nil -- Deselect previous selection since we are going to change the bottom text anyway
	private.Frame_SetDescriptionText(L.PRT_RESET_DONE)

	Print(L.PRT_RESET_DONE)
end

local function _CheckVanityItems(itemClassID, itemSubClassID)
	local vanityItem = false

	if itemClassID == Enum.ItemClass.Miscellaneous then -- Miscellaneous (15)
		if itemSubClassID == Enum.ItemMiscellaneousSubclass.Mount then -- Mount (5)
			vanityItem = true
		elseif itemSubClassID == Enum.ItemMiscellaneousSubclass.CompanionPet then -- Companion Pets (2)
			vanityItem = true
		end
	elseif itemClassID == Enum.ItemClass.Consumable then -- Consumable (0)
		if itemSubClassID == 8 then -- Other (8) - Enum.ItemConsumableSubclass.Other returns 7 (wrong) instead of 8 (right)
			vanityItem = true
		end
	end

	return vanityItem
end

local function HookEJUpdate(self, ...) -- Hook EJ Update for wishlist-buttons
	EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox:ForEachFrame(function(button)
		if not button.LOIHLoot then -- Create Buttons on demand
			_CreateButtons(button)
		end

		if button.CanIMogItOverlay then
			button.LOIHLoot:SetPoint("TOPRIGHT", -20, -5)
		else
			button.LOIHLoot:SetPoint("TOPRIGHT", -5, -5)
		end

		if EJ_InstanceIsRaid() and button.itemID then
			-- In 10.0 Blizzard added these "Very Rare" sub-title buttons to the loot lists
			-- They don't have button.itemID on them so it is easy to tell them apart from buttons with items

			local _, difficultyID = _CheckLink(button.link) -- Update is spammy as hell when Loot-tab is open, but hopefully the itemLinks-table helps
			difficultyID = difficultyID or 0

			local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = C_Item.GetItemInfo(button.itemID)

			if _CheckVanityItems(itemClassID, itemSubClassID) then -- Vanity
				button.LOIHLoot.main:Hide()
				button.LOIHLoot.off:Hide()
				button.LOIHLoot.vanity:Show()
				if db.vanity[button.itemID] then -- Item
					if db.vanity[button.itemID].difficulty == normalDifficultyID and difficultyID == Enum.ItemCreationContext.RaidFinder then -- Normal in DB, LFR in view
						button.LOIHLoot.vanity:SetNormalTexture(downTex)
					elseif db.vanity[button.itemID].difficulty == Enum.ItemCreationContext.RaidFinder and difficultyID == normalDifficultyID then -- LFR in DB, Normal in view
						button.LOIHLoot.vanity:SetNormalTexture(upTex)
					elseif db.vanity[button.itemID].difficulty == difficultyID then -- This difficulty
						button.LOIHLoot.vanity:SetNormalTexture(checkTex)
					elseif db.vanity[button.itemID].difficulty > difficultyID then -- Higher difficulty
						button.LOIHLoot.vanity:SetNormalTexture(downTex)
					elseif db.vanity[button.itemID].difficulty < difficultyID then -- Lower difficulty
						button.LOIHLoot.vanity:SetNormalTexture(upTex)
					end
				else -- No Item
					button.LOIHLoot.vanity:SetNormalTexture(emptyTex)
				end
			else -- MS / OS
				button.LOIHLoot.main:Show()
				button.LOIHLoot.off:Show()
				button.LOIHLoot.vanity:Hide()

				if db.main[button.itemID] then -- Item
					if db.main[button.itemID].difficulty == normalDifficultyID and difficultyID == Enum.ItemCreationContext.RaidFinder then -- Normal in DB, LFR in view
						button.LOIHLoot.main:SetNormalTexture(downTex)
					elseif db.main[button.itemID].difficulty == Enum.ItemCreationContext.RaidFinder and difficultyID == normalDifficultyID then -- LFR in DB, Normal in view
						button.LOIHLoot.main:SetNormalTexture(upTex)
					elseif db.main[button.itemID].difficulty == difficultyID then -- This difficulty
						button.LOIHLoot.main:SetNormalTexture(checkTex)
					elseif db.main[button.itemID].difficulty > difficultyID then -- Higher difficulty
						button.LOIHLoot.main:SetNormalTexture(downTex)
					elseif db.main[button.itemID].difficulty < difficultyID then -- Lower difficulty
						button.LOIHLoot.main:SetNormalTexture(upTex)
					end
				else -- No Item
					button.LOIHLoot.main:SetNormalTexture(emptyTex)
				end

				if db.off[button.itemID] then -- Item
					if db.off[button.itemID].difficulty == normalDifficultyID and difficultyID == Enum.ItemCreationContext.RaidFinder then -- Normal in DB, LFR in view
						button.LOIHLoot.off:SetNormalTexture(downTex)
					elseif db.off[button.itemID].difficulty == Enum.ItemCreationContext.RaidFinder and difficultyID == normalDifficultyID then -- LFR in DB, Normal in view
						button.LOIHLoot.off:SetNormalTexture(upTex)
					elseif db.off[button.itemID].difficulty == difficultyID then -- This difficulty
						button.LOIHLoot.off:SetNormalTexture(checkTex)
					elseif db.off[button.itemID].difficulty > difficultyID then -- Higher difficulty
						button.LOIHLoot.off:SetNormalTexture(downTex)
					elseif db.off[button.itemID].difficulty < difficultyID then -- Lower difficulty
						button.LOIHLoot.off:SetNormalTexture(upTex)
					end
				else -- No Item
					button.LOIHLoot.off:SetNormalTexture(emptyTex)
				end
			end
		else -- Hide buttons in non-raid instances
			button.LOIHLoot.main:Hide()
			button.LOIHLoot.off:Hide()
			button.LOIHLoot.vanity:Hide()
		end

	end)
end

local function ShowWishlistOnBonusRoll(spellID, difficultyID) -- Show Wishlist on BonusRollFrame
	local instanceID, encounterID = GetJournalInfoForSpellConfirmation(spellID)
	instanceID = instanceID or BonusRollFrame.instanceID
	encounterID = encounterID or BonusRollFrame.encounterID
	difficultyID = difficultyID or BonusRollFrame.difficultyID or GetBonusRollEncounterJournalLinkDifficulty() or DifficultyUtil.ID.PrimaryRaidNormal -- difficultyID or fall back to "Normal" (14)

	if not instanceID or not encounterID or not Raids[instanceID] then -- Only show Wishlist for stuff that is listed in the addon
		Debug("ShowWishlistOnBonusRoll -> Exit", instanceID, encounterID, difficultyID, Raids[instanceID] and "OK" or "NOT")

		LOIHLootFrame.BonusText:SetText("")
		LOIHLootFrame.BonusText:Hide()
		return
	end

	Debug("ShowWishlistOnBonusRoll:", instanceID, encounterID, difficultyID)

	local itemDifficulty
	if difficultyID == DifficultyUtil.ID.PrimaryRaidNormal then 	-- Normal Raid (14)
		itemDifficulty = normalDifficultyID -- (3)
	elseif difficultyID == DifficultyUtil.ID.PrimaryRaidHeroic then -- Heroic Raid (15)
		itemDifficulty = Enum.ItemCreationContext.RaidHeroic -- (5)
	elseif difficultyID == DifficultyUtil.ID.PrimaryRaidMythic then -- Mythic Raid (16)
		itemDifficulty = Enum.ItemCreationContext.RaidMythic -- (6)
	elseif difficultyID == DifficultyUtil.ID.PrimaryRaidLFR then -- LFR (17)
		itemDifficulty = Enum.ItemCreationContext.RaidFinder -- (4)
	end

	local mainCount, offCount, vanityCount = 0, 0, 0
	for subTable, tableData in pairs(db) do
		for itemID, itemData in pairs(tableData) do
			if itemData and (
				(itemDifficulty == Enum.ItemCreationContext.RaidFinder and itemData.difficulty == Enum.ItemCreationContext.RaidFinder) or	-- Drop == LFR		List == LFR
				(itemDifficulty == normalDifficultyID and itemData.difficulty <= Enum.ItemCreationContext.RaidFinder) or	-- Drop == Normal	List <= LFR (LFR or Normal)
				(itemDifficulty >= Enum.ItemCreationContext.RaidHeroic and itemData.difficulty <= itemDifficulty))							-- Drop >= Heroic	List >= Heroic (Heroic or Mythic)
			then
				if itemData.encounter == encounterID then
					Debug("!!!", itemID, itemData.encounter, itemData.difficulty, subTable)
					if subTable == "main" then
						mainCount = mainCount + 1
					elseif subTable == "off" then
						offCount = offCount + 1
					elseif subTable == "vanity" then
						vanityCount = vanityCount + 1
					end
				end
			end
		end
	end

	local mainStr, offStr, vanityStr
	if mainCount > 0 then
		mainStr = GREEN_FONT_COLOR_CODE .. mainCount .. FONT_COLOR_CODE_CLOSE
	else
		mainStr = tostring(mainCount)
	end
	if offCount > 0 then
		offStr = GREEN_FONT_COLOR_CODE .. offCount .. FONT_COLOR_CODE_CLOSE
	else
		offStr = tostring(offCount)
	end
	if vanityCount > 0 then
		vanityStr = GREEN_FONT_COLOR_CODE .. vanityCount .. FONT_COLOR_CODE_CLOSE
	else
		vanityStr = tostring(vanityCount)
	end

	LOIHLootFrame.BonusText:SetFormattedText("%s\n%s / %s / %s", NORMAL_FONT_COLOR_CODE .. L.WISHLIST .. FONT_COLOR_CODE_CLOSE, mainStr, offStr, vanityStr)
	LOIHLootFrame.BonusText:Show()
end

local function _CheckForBonusRolls(event) -- From UIParent.lua, check if there are BonusRolls going on
	local spellConfirmations = GetSpellConfirmationPromptsInfo()

	for i, spellConfirmation in ipairs(spellConfirmations) do
		--spellConfirmation.spellID
		--spellConfirmation.confirmType
		--spellConfirmation.text
		--spellConfirmation.duration
		--spellConfirmation.currencyID
		--spellConfirmation.currencyCost
		if spellConfirmation.spellID then
			if spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL then
				Debug("SPELL_CONFIRMATION_PROMT on", event, spellConfirmation.spellID)
				ShowWishlistOnBonusRoll(spellConfirmation.spellID)
			end
		end
	end
end

local function stripColors(str) -- Strip color-codes from strings
	local str = str or ""
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|r", "")
	return str
end

local function colorIndependentSort(a, b) -- Sort function to sort things based on the string content without color-codes
	return stripColors(a) < stripColors(b)
end

------------------------------------------------------------------------
--	Initialization functions
------------------------------------------------------------------------

function private:ADDON_LOADED(addon)
	if addon == ADDON_NAME then
		if C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
			LOIHLootFrame:UnregisterEvent("ADDON_LOADED")

			Debug("Blizzard_EncounterJournal pre-loaded")

			--_CreateButtons() -- Create Buttons on demand
			_PopulateRaids()

			EncounterJournalEncounterFrameInfo.LootContainer:HookScript("OnUpdate", HookEJUpdate)
		end

		LOIHLootDB = initDB(LOIHLootDB, cfgDefaults)
		LOIHLootCharDB = initDB(LOIHLootCharDB, charDefaults)
		cfg = LOIHLootDB
		db = LOIHLootCharDB

		for k, v in pairs(db) do -- Check data in CharDB
			if not charDefaults[k] then -- Data from the old version in the DB, try to move it to the new main table to prevent errors
				if type(db[k]) == "table" then
					db.main[k] = db.main[k] or {}
					for i, j in pairs(v) do
						db.main[k][i] = db.main[k][i] or j
					end
				else -- number, string, boolean, etc
					db.main[k] = db.main[k] or v
				end
				db[k] = nil -- Unset the OG blast from the past
			end
		end

		if IsLoggedIn() then
			private:PLAYER_LOGIN()
		end
	elseif addon == "Blizzard_EncounterJournal" then
		Debug("Blizzard_EncounterJournal loaded")

		if C_AddOns.IsAddOnLoaded(ADDON_NAME) then
			LOIHLootFrame:UnregisterEvent("ADDON_LOADED")

			Debug("Blizzard_EncounterJournal post-loaded")
		end

		--_CreateButtons() -- Create Buttons on demand
		_PopulateRaids()

		EncounterJournalEncounterFrameInfo.LootContainer:HookScript("OnUpdate", HookEJUpdate)
	else return end
end

function private:PLAYER_LOGIN()
	LOIHLootFrame:UnregisterEvent("PLAYER_LOGIN")

	local _, playerClass = UnitClass("player")
	private.playerClass = playerClass

	-- Clean up list on login.
	_CheckGear()
	_CheckBags()
	private.GROUP_ROSTER_UPDATE()

	-- Register prefix and  events
	C_ChatInfo.RegisterAddonMessagePrefix(ADDON_NAME)
	LOIHLootFrame:RegisterEvent("CHAT_MSG_ADDON")
	LOIHLootFrame:RegisterEvent("ITEM_PUSH")
	LOIHLootFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	LOIHLootFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	LOIHLootFrame:RegisterEvent("SPELL_CONFIRMATION_PROMPT") -- BonusRoll
	LOIHLootFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- BonusRoll
end

function private:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if channel ~= _commType or prefix ~= ADDON_NAME then return end
	Debug("CHAT_MSG_ADDON")

	sender = Ambiguate(sender, "none")

	local command, data = strsplit("-", message)
	if command == "SyncRequest" then
		Debug("< Received SyncRequest:", data)
		_SyncReply(data)
	elseif command == "SyncReply" then
		Debug("< Received SyncReply:", sender, data)
		_ProcessReply(sender, data)
	elseif command == "VersionRequest" then
		Debug("< Received VersionRequest:", sender, data)

		local err = C_ChatInfo.SendAddonMessage(ADDON_NAME, "VersionReply-"..(private.version or ""), _commType)

		Debug(">>> Success:", err)
	elseif command == "VersionReply" then
		Debug("< Received VersionReply:", sender, data)
	end
end

function private:ITEM_PUSH()
	-- Fired when an item is pushed onto the "inventory-stack". For instance when you manufacture something with your trade skills or picks something up.
	if IsInRaid() then
		_CheckBags()
		_CheckForBonusRolls("ITEM_PUSH") -- Update Wishlist on BonusRoll if we loot something
	end
end

function private:PLAYER_EQUIPMENT_CHANGED()
	-- This event is fired when the players gear changes.
	if IsInRaid() then
		_CheckGear()
	end
end

do -- GROUP_ROSTER_UPDATE
	local throttling

	local function DelayedUpdate()
		throttling = nil
		Debug("GROUP_ROSTER_UPDATE")
		if cfg.debugmode then
			if IsInRaid() then
				_commType = "RAID"
			else
				_commType = "GUILD"
				local name = UnitName("player")
				syncedRoster[name] = syncedRoster[name] or 0
				currentRoster[name] = true
			end
		end

		private.Frame_UpdateButtons()

		local cC, sC = 0, 0
		local changed = false
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if name and online then -- Exists and is online
				Debug("> Online", name)
				currentRoster[name] = true
				cC = cC + 1

				if not syncedRoster[name] then
					syncedRoster[name] = 0 -- Not synced (new to the group)
					changed = true
				end
			elseif name then
				Debug("> Offline", name)
			end
		end

		for k in pairs(syncedRoster) do
			sC = sC + 1
			if not currentRoster[k] then
				if syncedRoster[k] == 2 then -- Removed player was synced with reply
					changed = true
				end
				syncedRoster[k] = nil
				sC = sC - 1
			end
		end
		wipe(currentRoster)

		Debug("> Current:", cC, " - Synced:", sC, " - Num:", GetNumGroupMembers())

		if not IsInRaid() then -- Solo, no sync
			_syncStatus = RED_FONT_COLOR_CODE .. L.SYNCSTATUS_MISSING .. FONT_COLOR_CODE_CLOSE
		elseif changed then -- Roster changed since last sync
			_syncStatus = ORANGE_FONT_COLOR_CODE .. L.SYNCSTATUS_INCOMPLETE .. FONT_COLOR_CODE_CLOSE
		end
		LOIHLootFrame.SyncText:SetText(_syncStatus)
	end

	local function ThrottleUpdate() -- Throttle GROUP_ROSTER_UPDATE to 1/1sec or lower
		if not throttling then
			throttling = true
			C_Timer.After(0.5, DelayedUpdate)
		end
	end

	private.GROUP_ROSTER_UPDATE = ThrottleUpdate
end

function private:SPELL_CONFIRMATION_PROMPT(spellID, confirmType, ...) -- Add Wishlist to the BonusRollFrame
	if confirmType ~= LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL then return end -- Check if this is BonusRoll, value == 1
	local text, duration, currencyID, currencyCost, difficultyID = ...
	Debug("SPELL_CONFIRMATION_PROMT", spellID, difficultyID)

	ShowWishlistOnBonusRoll(spellID, difficultyID)
end

function private:PLAYER_ENTERING_WORLD()
	_CheckForBonusRolls("PLAYER_ENTERING_WORLD")
end

------------------------------------------------------------------------
--	LOIHLootFrame UI functions
------------------------------------------------------------------------

function private.Frame_SetDescriptionText(pattern, ...) -- Set text to bottom element
	LOIHLootFrame.TextScrollFrame:Show()
	LOIHLootFrame.TextBox:SetFormattedText(pattern, ...)
	--LOIHLootFrame.TextScrollFrame.ScrollBar:SetValue(0)
	LOIHLootFrame.TextScrollFrame.ScrollBar:ScrollToBegin() -- 10.1 Removes some old ScrollBar templates
	LOIHLootFrame.TextScrollFrame:UpdateScrollChildRect()
end

function private.Frame_UpdateButtons() -- Update button states and highlight locks
	if IsInRaid() and (_IsOfficer or UnitIsGroupLeader("Player")) and not _syncLock then
		LOIHLootFrame.SyncButton:Enable()
	else
		LOIHLootFrame.SyncButton:Disable()
	end
end

function private.FilterList() -- Filter list items
	Debug("FilterList")

	wipe(filteredList)

	for i = 1, #RaidInstanceOrder do -- Now we have the right order for the instances, populate the list for the main view
		local bossIDs = Raids[RaidInstanceOrder[i]] -- instanceID
		local instanceName = EJ_GetInstanceInfo(RaidInstanceOrder[i]) -- instanceID
		
		filteredList[#filteredList + 1] = instanceName

		if openHeaders[instanceName] then
			for j = 1, #bossIDs do -- Encounters are listed with proper indexes so we can just iterate through them
				filteredList[#filteredList + 1] = bossIDs[j] -- encounterID
			end
		end
	end
end

function private.Frame_UpdateList(self, ...) -- Update list
	Debug("Update", ...)

	local scrollFrame = LOIHLootFrame.ScrollFrame
	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local buttons = scrollFrame.buttons

	for i = 1, #buttons do
		local index = i + offset
		local button = buttons[i]
		button:Hide()
		if index <= #filteredList then
			button:SetID(index)
			if type(filteredList[index]) == "string" then
				button.header.text:SetText(filteredList[index])
				if openHeaders[filteredList[index]] then
					button.header.expandIcon:SetTexCoord(0.5625, 1, 0, 0.4375) -- minus sign
					button.header.main:SetText(L.SHORT_MAINSPEC)
					button.header.off:SetText(L.SHORT_OFFSPEC)
					button.header.vanity:SetText(L.SHORT_VANITY)
				else
					button.header.expandIcon:SetTexCoord(0, 0.4375, 0, 0.4375) -- plus sign
					button.header.main:SetText("")
					button.header.off:SetText("")
					button.header.vanity:SetText("")
				end
				button.detail:Hide()
				button.header:Show()
			else
				local mainCount, offCount, vanityCount = 0, 0, 0
				local mainPercent, offPercent, vanityPercent = 0, 0, 0
				local mR, mG, mB = normalFontColor[1], normalFontColor[2], normalFontColor[3]
				local oR, oG, oB = normalFontColor[1], normalFontColor[2], normalFontColor[3]
				if SyncTable.main then
					mainCount = SyncTable.main[filteredList[index]] or 0
					mainPercent = _syncReplies > 0 and math.floor(mainCount / _syncReplies * 100 + .5) or 0
					--mainPercent = math.random(0, 100) -- Debug
					mR = (mainPercent * highPercentColor[1] + (100 - mainPercent) * normalFontColor[1]) / 100
					mG = (mainPercent * highPercentColor[2] + (100 - mainPercent) * normalFontColor[2]) / 100
					mB = (mainPercent * highPercentColor[3] + (100 - mainPercent) * normalFontColor[3]) / 100
				end
				if SyncTable.off then
					offCount = SyncTable.off[filteredList[index]] or 0
					offPercent = _syncReplies > 0 and math.floor(offCount / _syncReplies * 100 + .5) or 0
					--offPercent = math.random(0, 100) -- Debug
					oR = (offPercent * highPercentColor[1] + (100 - offPercent) * normalFontColor[1]) / 100
					oG = (offPercent * highPercentColor[2] + (100 - offPercent) * normalFontColor[2]) / 100
					oB = (offPercent * highPercentColor[3] + (100 - offPercent) * normalFontColor[3]) / 100
				end
				if SyncTable.vanity then
					vanityCount = SyncTable.vanity[filteredList[index]] or 0
					vanityPercent = _syncReplies > 0 and math.floor(vanityCount / _syncReplies * 100 + .5) or 0
				end
				local totalCount = _syncReplies or 0
				local mainColorString = _RGBToHex(255 * mR, 255 * mG, 255 * mB)
				local offColorString = _RGBToHex(255 * oR, 255 * oG, 255 * oB)
				button.detail.text:SetText(_GetBossName(filteredList[index]))
				button.detail.main:SetFormattedText("|cff%s%d/%d\n(%d%%)|r", mainColorString, mainCount, totalCount, mainPercent)
				button.detail.off:SetFormattedText("|cff%s%d/%d\n(%d%%)|r", offColorString, offCount, totalCount, offPercent)
				button.detail.vanity:SetFormattedText("%d/%d\n(%d%%)", vanityCount, totalCount, vanityPercent)
				button.header:Hide()
				button.detail:Show()

				if LOIHLootFrame.selectedID == filteredList[index] then
					button.detail:LockHighlight()
				else
					button.detail:UnlockHighlight()
				end
			end
			button:Show()
		end
	end

	HybridScrollFrame_Update(scrollFrame, (private.LIST_BUTTON_HEIGHT * #filteredList), private.LIST_BUTTON_HEIGHT)
end

function private.HeaderOnClick(self) -- Click Header on list
	Debug("HeaderOnClick", self:GetID(), filteredList[self:GetID()])

	openHeaders[filteredList[self:GetID()]] = not openHeaders[filteredList[self:GetID()]]
	private.FilterList()
	private.Frame_UpdateList()
end	

function private.ButtonOnClick(self) -- Click Boss' name on list
	Debug("ButtonOnClick", self:GetID(), filteredList[self:GetID()])

	local index = filteredList[self:GetID()]
	if LOIHLootFrame.selectedID ~= index then
		Debug("- selected ID changed:", index)

		local bossName = self.detail.text:GetText() or L.UNKNOWN

		local mainCount, offCount, vanityCount = 0, 0, 0
		local mainPercent, offPercent, vanityPercent = 0, 0, 0
		if SyncTable.main then
			mainCount = SyncTable.main[index] or 0
			mainPercent = _syncReplies > 0 and math.floor(mainCount / _syncReplies * 100 + .5) or 0
		end
		if SyncTable.off then
			offCount = SyncTable.off[index] or 0
			offPercent = _syncReplies > 0 and math.floor(offCount / _syncReplies * 100 + .5) or 0
		end
		if SyncTable.vanity then
			vanityCount = SyncTable.vanity[index] or 0
			vanityPercent = _syncReplies > 0 and math.floor(vanityCount / _syncReplies * 100 + .5) or 0
		end

		local mainText = format("%s:\n     %d / %d (%d%%)", L.LONG_MAINSPEC, mainCount, _syncReplies, mainPercent)
		local offText = format("%s:\n     %d / %d (%d%%)", L.LONG_OFFSPEC, offCount, _syncReplies, offPercent)
		local vanityText = format("%s:\n     %d / %d (%d%%)", L.LONG_VANITY, vanityCount, _syncReplies, vanityPercent)

		if cfg.namesPerBoss then -- Separate players into lists based on whether or not they need loot from this boss
			local needLoot, dontNeedLoot, tNames = "-", "-", {}

			if SyncNames[index] then -- Players who need loot
				for k in pairs(SyncNames[index]) do
					local _, classFilename = UnitClass(k)
					local colorStr = RAID_CLASS_COLORS[classFilename].colorStr or "ffffffff"
					tNames[#tNames + 1] = "|c" .. colorStr .. k .. "|r"
				end
				if #tNames > 0 then
					sort(tNames, colorIndependentSort)
					needLoot = strjoin(",", unpack(tNames))
				end
			end

			wipe(tNames)
			for k in pairs(syncedRoster) do -- Players who don't need loot
				if not SyncNames[index] or not SyncNames[index][k] then
					local _, classFilename = UnitClass(k)
					local colorStr = RAID_CLASS_COLORS[classFilename].colorStr or "ffffffff"
					tNames[#tNames + 1] = "|c" .. colorStr .. k .. "|r"
				end
			end
			if #tNames > 0 then
				sort(tNames, colorIndependentSort)
				dontNeedLoot = strjoin(",", unpack(tNames))
			end

			private.Frame_SetDescriptionText("%s\n\n%s%s%s\n%s\n%s\n%s\n\n%s\n %s\n%s\n %s", _SyncLine(), HIGHLIGHT_FONT_COLOR_CODE, bossName, FONT_COLOR_CODE_CLOSE, mainText, offText, vanityText, L.NEED_LOOT_FROM_BOSS, needLoot, L.DONT_NEED_LOOT_FROM_BOSS, dontNeedLoot)
		else
			private.Frame_SetDescriptionText("%s\n\n%s%s%s\n%s\n%s\n%s", _SyncLine(), HIGHLIGHT_FONT_COLOR_CODE, bossName, FONT_COLOR_CODE_CLOSE, mainText, offText, vanityText)
		end

		LOIHLootFrame.selectedID = index
		private.Frame_UpdateList()
	end
end

function private.Frame_SyncButtonOnClick(self) -- Send SyncRequest
	local function EnableButton()
		_syncLock = false
		private.Frame_UpdateButtons()
		private.Frame_SetDescriptionText(_SyncLine())
	end

	private.Frame_SetDescriptionText("%s\n\n%s", _SyncLine(), L.SENDING_SYNC)
	_syncLock = true
	LOIHLootFrame.SyncButton:Disable()
	C_Timer.After(15, EnableButton)

	private.difficultyID = GetRaidDifficultyID()
	_raidCount = GetNumGroupMembers()

	if private.difficultyID == DifficultyUtil.ID.PrimaryRaidNormal then 	-- Normal Raid (14)
		_SendSyncRequest(normalDifficultyID) -- (3)
	elseif private.difficultyID == DifficultyUtil.ID.PrimaryRaidHeroic then -- Heroic Raid (15)
		_SendSyncRequest(Enum.ItemCreationContext.RaidHeroic) -- (5)
	elseif private.difficultyID == DifficultyUtil.ID.PrimaryRaidMythic then -- Mythic Raid (16)
		_SendSyncRequest(Enum.ItemCreationContext.RaidMythic) -- (6)
	else
		Print(L.PRT_UNKOWN_DIFFICULTY)
	end
end

function private.Frame_OnVerticalScroll(self, arg1)
	-- Under some circumstances, when the OnVerticalScroll handler calls the
	-- scrollbar:SetValue function, the scrollbar calls back into the
	-- OnVerticalScroll handler itself, although in this nexted call arg1 is
	-- set to nil and does not call itself further.  As a result though, the
	-- default implementation of the OnVerticalScroll handler in
	-- UIPanelTemplates.lua will sometimes enable the scroll arrow buttons
	-- when it shouldn't.  This code below works around this by getting the
	-- current scrollbar value after passing it arg1 (so arg1 is thereafter
	-- ignored).  It also accommodates rounding errors in the min/max
	-- positions for robustness.  Note that for some reason we cannot use
	-- greater and less than comparisons in the script in the XML file itself,
	-- which is why this is in its own function here.
	local scrollbar = self.ScrollBar
	scrollbar:SetValue(arg1)
	local min, max = scrollbar:GetMinMaxValues()
	local scroll = scrollbar:GetValue()
	if scroll < (min + 0.1) then
		scrollbar.ScrollUpButton:Disable()
	else
		scrollbar.ScrollUpButton:Enable()
	end
	if scroll > (max - 0.1) then
		scrollbar.ScrollDownButton:Disable()
	else
		scrollbar.ScrollDownButton:Enable()
	end
end

------------------------------------------------------------------------
--	OnEvent handler
------------------------------------------------------------------------

function private.OnEvent(self, event, ...)
	return private[event] and private[event](private, ...)
end

------------------------------------------------------------------------
--	OnLoad function
------------------------------------------------------------------------

function private.OnLoad(self)
	-- Record our frame pointer for later
	LOIHLootFrame = self

	-- Register for player events
	LOIHLootFrame:RegisterEvent("ADDON_LOADED")
	LOIHLootFrame:RegisterEvent("PLAYER_LOGIN")

	-- Make sure the newest raid tier is open
	if _latestTier then
		--openHeaders[EJ_GetInstanceInfo(_latestTier)] = true
	end

	-- Fill HybridScrollFrame
	private.FilterList()

	-- Set Sync Status Text
	_syncStatus = RED_FONT_COLOR_CODE .. L.SYNCSTATUS_MISSING .. FONT_COLOR_CODE_CLOSE
	LOIHLootFrame.SyncText:SetText(_syncStatus)
end

------------------------------------------------------------------------
--	Slash command function
------------------------------------------------------------------------

SLASH_LOIHLOOT1 = "/loihloot"
SLASH_LOIHLOOT2 = "/lloot"
SLASH_LOIHLOOT3 = private.SLASH_COMMAND

local SlashHandlers = {
	[L.CMD_SHOW] = function()
		ShowUIPanel(LOIHLootFrame)
	end,
	[L.CMD_HIDE] = function()
		HideUIPanel(LOIHLootFrame)
	end,
	[L.CMD_RESET] = function(params)
		if params == "all" then
			wipe(db)
			db = initDB(db, charDefaults)
			ReloadUI()
		else
			_Reset()
		end
	end,
	[L.CMD_STATUS] = function()
		UpdateAddOnMemoryUsage()
		Print(L.PRT_STATUS, ADDON_NAME, GetAddOnMemoryUsage(ADDON_NAME) + 0.5)
	end,
	[L.CMD_DEBUGON] = function()
		cfg.debugmode = true
		if not IsInRaid() then
			_commType = "GUILD"
			LOIHLootFrame.SyncButton:Enable()
		end
		local name = UnitName("player")
		syncedRoster[name] = syncedRoster[name] or 0
		Print(L.PRT_DEBUG_TRUE, ADDON_NAME)
	end,
	[L.CMD_DEBUGOFF] = function()
		cfg.debugmode = false
		_commType = "RAID"
		private.Frame_UpdateButtons()
		Print(L.PRT_DEBUG_FALSE, ADDON_NAME)
	end,
	[L.CMD_SAVENAMES] = function()
		cfg.namesPerBoss = not cfg.namesPerBoss
		Print(L.PRT_SAVENAMES, cfg.namesPerBoss and "|cff00ff00" .. L.ENABLED .. "|r" or "|cffff0000" .. L.DISABLED .. "|r")
		if not cfg.namesPerBoss then
			wipe(SyncNames)
		end
	end,
	--[[[L.CMD_DUMP] = function(params) -- 'bossdump' as default, this is hidden command
		if not params or params == "" then
			Print("InstanceID? Try 'EJ_GetInstanceInfo()'")
			return
		end

		Print("Open EJ if you get empty \"table\"!")
		Print("["..params.."]", "=", "{", "-- "..EJ_GetInstanceInfo(tonumber(params)))
		local index = 1

		repeat
			local name, _, encounterID = EJ_GetEncounterInfoByIndex(index, tonumber(params))
			if name then
				Print("   ", encounterID..",", "-- "..name)
				index = index + 1
			end
		until not name

		Print("},")
	end,]]--
	["roster"] = function() -- Check SyncStatus from roster
		local testNoSync, testNoReply, testGaveReply, testError = 0, 0, 0, 0

		for _, v in pairs(syncedRoster) do
			if v == 0 then
				testNoSync = testNoSync + 1
			elseif v == 1 then
				testNoReply = testNoReply + 1
			elseif v == 2 then
				testGaveReply = testGaveReply + 1
			else
				testError = testError + 1
			end
		end

		Print("Roster\n   - NotSyncedYet:", testNoSync, "\n   - NoReply:", testNoReply, "\n   - Replied:", testGaveReply, "\n   - Error:", testError, "\n   - GroupSize:", GetNumGroupMembers())
	end,
	["version"] = function() -- Check Versions of group members
		local err = C_ChatInfo.SendAddonMessage(ADDON_NAME, "VersionRequest-"..(private.version or ""), _commType)

		Debug(">>> Success:", err)
	end,
	--[[["tiers"] = function() -- Extract setIDs of Tier-sets
		local _getClass = function(itemID)
			local classResult
			scantip:SetHyperlink("item:"..itemID)
			for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
				local text = _G[ADDON_NAME.."ScanningTooltipTextLeft"..i]:GetText()
				if text and text ~= "" then
					classResult = strmatch(text, gsub("Classes: %s", "%%s", "(.+)"))
					if classResult and classResult ~= "" and classResult ~= nil then
						--Print("%d - %s", i, classResult)

						break
					end
				end
			end

			return classResult and classResult or "UNKNOWN"
		end

		local classTable = {}
		for c = 1, GetNumClasses() do
			local classDisplayName, classTag, classID = GetClassInfo(c)
			classTable[classDisplayName] = classTag
		end

		local tiers = {}
		local itemSets = C_LootJournal.GetFilteredItemSets()
		local tierCount = 0

		--Print("itemSets:", #itemSets)
		for i = 1, #itemSets do
			local setName = itemSets[i].name
			local setID = itemSets[i].setID
			local itemLevel = itemSets[i].itemLevel
			local items = C_LootJournal.GetItemSetItems(itemSets[i].setID)

			--Print("items:", #items)
			for j = 1, #items do
				local itemID = items[j].itemID

				if itemID and itemID > 0 then
					local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemID)
					if itemRarity == LE_ITEM_QUALITY_EPIC and itemLevel >= 875 and not tiers[setID] and not TierSets[setID] then
						local class = classTable[_getClass(itemID)] or "UNKNOWN"
						tiers[setID] = { setName, class }
						tierCount = tierCount + 1
					end
				end
			end
		end

		Print("---")
		for setID, data in pairs(tiers) do
			Print("   ", "["..setID.."]", "=", "\""..data[2].."\",", "-- "..data[1])
		end
		Print("---", tierCount, tierCount == GetNumClasses() and "OK!" or "Error?")
	end,]]--
}

SlashCmdList["LOIHLOOT"] = function(text)
	if not C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then -- Load EJ if it isn't loaded yet, otherwise the LOIHLootFrame will have empty list until we load EJ
		local loaded, reason = C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
		
		if not loaded then
  			Print(ADDON_LOAD_FAILED, "Blizzard_EncounterJournal", _G["ADDON_" .. reason] or reason)
		end
	end

	if not text or text == "" then
		return ToggleFrame(LOIHLootFrame)
	end

	local command, params = strsplit(" ", text, 2)
	if SlashHandlers[command] then
		SlashHandlers[command](params)
	else
		Print(ADDON_NAME.." "..private.version)
		Print(L.CMD_LIST, L.CMD_SHOW, L.CMD_HIDE, L.CMD_RESET, L.CMD_STATUS, L.CMD_HELP)
		for i = 1, #L.HELP_TEXT do
			Print(L.HELP_TEXT[i])
		end
	end
end

------------------------------------------------------------------------
--	Blizzard options panel functions
------------------------------------------------------------------------

do
	local Options = CreateFrame("Frame", "privateOptions", InterfaceOptionsFramePanelContainer)
	Options.name = L["LOIHLoot"]
	private.OptionsPanel = Options
	-- InterfaceOptions_AddCategory(Options)
	local category = Settings.RegisterCanvasLayoutCategory(Options, Options.name)
	category.ID = Options.name
	Settings.RegisterAddOnCategory(category)

	Options:Hide()
	Options:SetScript("OnShow", function(self)
		local Title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		Title:SetPoint("TOPLEFT", 16, -16)
		Title:SetText(L["LOIHLOOT"])

		local Version = self:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		Version:SetPoint("BOTTOMLEFT", Title, "BOTTOMRIGHT", 16, 0)
		Version:SetPoint("RIGHT", -24, 0)
		Version:SetJustifyH("RIGHT")
		Version:SetText(GAME_VERSION_LABEL .. ": " .. HIGHLIGHT_FONT_COLOR_CODE .. private.version)

		local SubText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		SubText:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8)
		SubText:SetPoint("TOPRIGHT", Version, "BOTTOMRIGHT", 0, -8)
		SubText:SetJustifyH("LEFT")
		SubText:SetText(private.description)

		local helpText = ""
		local slash = private.SLASH_COMMAND or "/loihloot"
		for i = 1, #L.HELP_TEXT do
			local command, description = strmatch(L.HELP_TEXT[i], "%- (%S+) %- (.+)")
			if command and description then
				helpText = format("%s\n\n%s%s %s|r\n%s", helpText, NORMAL_FONT_COLOR_CODE, slash, command, description)
			else
				helpText = helpText .. "\n\n" .. gsub(L.HELP_TEXT[i], " /([^%s,]+)", NORMAL_FONT_COLOR_CODE .. " /%1|r")
			end
		end
		helpText = helpText .. "\n\n\n" .. L.REMINDER
		helpText = strsub(helpText, 3)

		local HelpText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		HelpText:SetPoint("TOPLEFT", SubText, "BOTTOMLEFT", 0, -24)
		HelpText:SetPoint("BOTTOMRIGHT", -24, 16)
		HelpText:SetJustifyH("LEFT")
		HelpText:SetJustifyV("TOP")
		HelpText:SetText(helpText)

		self:SetScript("OnShow", nil)
	end)
end

-- EOF