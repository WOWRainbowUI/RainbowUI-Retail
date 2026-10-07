--[[
	FriendGroups - Platform_Render.lua
	============================================================================
	Classic (HybridScroll) list renderer. Loaded after Compat.lua, before
	FriendGroups.lua.

	On retail the friends list is a ScrollBox and FriendGroups.lua drives it with
	its native DataProvider path; this file returns immediately and is inert.

	On MoP Classic there is no ScrollBox: the list is the native
	FriendsFrameFriendsScrollFrame HybridScrollFrame, whose friend buttons are a
	structurally different template. This module renders those native buttons.
	The per-button and header renderers are salvaged from the tested-on-5.5.x
	2.0.0 build; their only edits are:
	  - file-local state they used (playerFactionGroup / INVITE_RESTRICTION_NONE /
	    groupsCount) is read from addonTable.State, which FriendGroups.lua exposes,
	  - the two functions are file-locals here so they never collide with retail's
	    own FriendGroups_FriendsListUpdateFriendButton.

	API compliance: MoP Classic 5.5.4. Every retail-era helper is presence-guarded
	with a Classic fallback (as in the 2.0.0 build).
]] --

local addonName, addonTable = ...
local Compat = addonTable.Compat
local L = addonTable.L

-- Retail uses its native ScrollBox path; this module is Classic-only.
if Compat.HAS_SCROLLBOX then return end

-- Shared state exposed by FriendGroups.lua (tables shared by reference; scalars
-- are load-time constants). FriendGroups.lua loads AFTER this file, so capturing
-- addonTable.State now would pin nil; it is bound lazily at first render instead.
local State

-- Cross-faction help-tip carriers (retail-era; the guarded block below is skipped
-- on MoP where LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE does not exist).
local crossFactionHelpTipInfo, crossFactionHelpTipButton

local RenderFriendButton
local RenderHeader

-- Fallback English class-name -> token map. Cross-project (retail) friends can be
-- playing classes the MoP client doesn't localize (Demon Hunter / Evoker); without
-- this they resolve to no token and show no class icon.
local FG_ENGLISH_CLASS_TOKENS = {
	["Warrior"] = "WARRIOR", ["Paladin"] = "PALADIN", ["Hunter"] = "HUNTER",
	["Rogue"] = "ROGUE", ["Priest"] = "PRIEST", ["Death Knight"] = "DEATHKNIGHT",
	["Shaman"] = "SHAMAN", ["Mage"] = "MAGE", ["Warlock"] = "WARLOCK",
	["Monk"] = "MONK", ["Druid"] = "DRUID", ["Demon Hunter"] = "DEMONHUNTER",
	["Evoker"] = "EVOKER",
}

-- Older clients ship incomplete class data for classes outside their expansion:
-- MoP lacks Demon Hunter / Evoker entirely; BC Anniversary 2.5.6 additionally has
-- no LOCALIZED_CLASS_NAMES entry for Death Knight / Monk (probed 2026-07: class
-- colors and circle coords ARE present there, only the names are absent). Register
-- token, localized name and class color for whatever is missing so cross-project
-- friends on those classes resolve to a token everywhere the shared name tables
-- are walked (this file's resolver + the core ones in FriendGroups.lua). Existing
-- entries are never overwritten, so each call is a no-op where the client has data.
-- Where the client ships no class ICON, LayoutRow leaves the icon hidden -- the
-- name color still conveys class.
local function FG_RegisterMissingClass(token, name, r, g, b)
	if LOCALIZED_CLASS_NAMES_MALE and not LOCALIZED_CLASS_NAMES_MALE[token] then
		LOCALIZED_CLASS_NAMES_MALE[token] = name
	end
	if LOCALIZED_CLASS_NAMES_FEMALE and not LOCALIZED_CLASS_NAMES_FEMALE[token] then
		LOCALIZED_CLASS_NAMES_FEMALE[token] = name
	end
	if RAID_CLASS_COLORS and not RAID_CLASS_COLORS[token] then
		RAID_CLASS_COLORS[token] = CreateColor and CreateColor(r, g, b) or { r = r, g = g, b = b }
	end
end
-- Localized class name from the client's OWN class database (documented
-- C_CreatureInfo.GetClassInfo(classID) -> ClassInfo.className). Authoritative and
-- in the client's language, so the reverse name->token lookups below match the
-- localized className the API actually reports on a non-English client -- a
-- hardcoded English name would never match there. Falls back to the addon's own
-- localized CLASS_* key (defined in every locale file) if the query is
-- unavailable; never a hardcoded name. classIDs are stable game constants
-- (Death Knight 6, Monk 10, Demon Hunter 12, Evoker 13).
local function FG_ClassName(classID, fallbackKey)
	if C_CreatureInfo and type(C_CreatureInfo.GetClassInfo) == "function" then
		local info = C_CreatureInfo.GetClassInfo(classID)
		if info and type(info.className) == "string" and info.className ~= "" then
			return info.className
		end
	end
	return L[fallbackKey]
end

FG_RegisterMissingClass("DEMONHUNTER", FG_ClassName(12, "CLASS_DEMONHUNTER"), 0.64, 0.19, 0.79)
FG_RegisterMissingClass("EVOKER", FG_ClassName(13, "CLASS_EVOKER"), 0.20, 0.58, 0.50)
FG_RegisterMissingClass("DEATHKNIGHT", FG_ClassName(6, "CLASS_DEATHKNIGHT"), 0.77, 0.12, 0.23)
FG_RegisterMissingClass("MONK", FG_ClassName(10, "CLASS_MONK"), 0.00, 1.00, 0.59)

-- Row fonts, one visible step BELOW retail's 12/10 metrics. Classic's friends frame
-- is narrower than retail's, so text at retail's own sizes still reads oversized and
-- truncates; 11px names / 9px info sit right in the frame. Derived font objects only
-- (safe to size explicitly -- shared font objects are never touched).
local FG_NAME_SIZE, FG_INFO_SIZE = 11, 9
local FG_NAME_FONT, FG_INFO_FONT
do
	local function DeriveFont(globalName, base, size)
		if not (base and CreateFont) then return nil end
		local f = CreateFont(globalName)
		f:CopyFontObject(base)
		local path, _, flags = f:GetFont()
		if not path then return nil end
		f:SetFont(path, size, flags or "")
		return f
	end
	FG_NAME_FONT = DeriveFont("FriendGroupsClassicNameFont", FriendsFont_Normal or GameFontNormal, FG_NAME_SIZE)
	FG_INFO_FONT = DeriveFont("FriendGroupsClassicInfoFont", FriendsFont_Small or GameFontNormalSmall, FG_INFO_SIZE)
end

-- Favorite-star art, probed once. Retail's row template ships .Favorite with the
-- friendslist-favorite atlas; MoP may not have that atlas. C_Texture.GetAtlasInfo
-- (documented on 5.5.4) decides: atlas present -> identical retail star; absent ->
-- the ReputationStar sheet (ships on 5.5), cropping its top-left star quadrant.
local FG_FAV_ATLAS_OK = nil
local function FG_ApplyFavoriteArt(tex)
	if FG_FAV_ATLAS_OK == nil then
		FG_FAV_ATLAS_OK = (C_Texture and C_Texture.GetAtlasInfo
			and C_Texture.GetAtlasInfo("friendslist-favorite") ~= nil) or false
	end
	if FG_FAV_ATLAS_OK and tex.SetAtlas then
		tex:SetAtlas("friendslist-favorite")
		tex:SetTexCoord(0, 1, 0, 1)
	else
		tex:SetTexture("Interface\\Common\\ReputationStar")
		tex:SetTexCoord(0, 0.5, 0, 0.5)
	end
end

-- Bundled square class icons for the retail-only classes MoP ships no atlas for.
local FG_BUNDLED_CLASS_TEX = {
	DEMONHUNTER = "Interface\\AddOns\\FriendGroups\\Textures\\classicon_demonhunter",
	EVOKER = "Interface\\AddOns\\FriendGroups\\Textures\\classicon_evoker",
}

-- Classic override of Compat.ClassIconMarkup: MoP has no "classicon-*" atlas, so use
-- the round UI-Classes-Circles texture (correct on MoP) for standard classes and the
-- bundled square TGAs for Demon Hunter / Evoker.
function Compat.ClassIconMarkup(engClass, size)
	if not engClass or engClass == "" then return "" end
	size = size or 16
	local bundled = FG_BUNDLED_CLASS_TEX[engClass]
	if bundled then
		-- 2px smaller so the full-bleed circle matches the padded round class icons.
		return "|T" .. bundled .. ":" .. (size - 2) .. ":" .. (size - 2) .. "|t"
	end
	local c = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[engClass]
	if c then
		return string.format("|TInterface\\TargetingFrame\\UI-Classes-Circles:%d:%d:0:0:256:256:%d:%d:%d:%d|t",
			size, size, c[1] * 256, c[2] * 256, c[3] * 256, c[4] * 256)
	end
	return ""
end

-- Resolve an English class token ("MAGE") from a localized class name.
local function ResolveClassToken(name)
	if not name or name == "" then return nil end
	if RAID_CLASS_COLORS[name] then return name end
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if v == name then return k end end
	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if v == name then return k end end
	return FG_ENGLISH_CLASS_TOKENS[name]
end

-- Look up a friend's class from the alt cache (populated from retail via Sync/import)
-- when the live MoP API can't provide it (returns nil for retail-only classes like
-- Demon Hunter / Evoker). Matches the friend's CURRENT character by name + realm.
local function FG_LookupCachedClass(accountInfo, charName, realmName)
	if not charName or charName == "" then return nil end
	if not FriendGroups_SavedVars or type(FriendGroups_SavedVars.alt_cache) ~= "table" then return nil end
	local key = accountInfo and (accountInfo.battleTag or accountInfo.accountName)
	local alts = key and FriendGroups_SavedVars.alt_cache[key]
	if type(alts) ~= "table" then return nil end
	local cleanRealm = FriendGroups_CleanRealmName(realmName or "")
	for _, alt in ipairs(alts) do
		if alt.charName == charName and (cleanRealm == "" or FriendGroups_CleanRealmName(alt.realm or "") == cleanRealm) then
			if type(alt.class) == "string" and alt.class ~= "" then return alt.class end
		end
	end
	return nil
end

-- Lay out a friend row as [class icon][status][name / info], honoring the
-- Show Class Icons / Show Status toggles. Mirrors retail's FriendGroups_ApplyRowLayout
-- but against MoP's native button regions. RenderFriendButton stashes button.fgClass.
local function LayoutRow(button)
	local x = 4
	local rowH = (button:GetHeight() or 0) - 4
	local iconSize = (rowH > 0) and rowH or 16

	local showIcon = not (FriendGroups_SavedVars and FriendGroups_SavedVars.show_class_icons == false)
	if not button.fgClassIcon then
		button.fgClassIcon = button:CreateTexture(nil, "ARTWORK", nil, 2)
	end
	local token = showIcon and ResolveClassToken(button.fgClass)
	-- Round class icons: MoP's UI-Classes-Circles + CLASS_ICON_TCOORDS render the correct
	-- class (the square "classicon-*" atlas does not exist on MoP). Retail-only classes
	-- MoP has no coords for (Demon Hunter / Evoker) use the bundled square TGAs, which the
	-- circular mask above renders round to match.
	local bundled = token and FG_BUNDLED_CLASS_TEX[token]
	local tcoord = (not bundled) and token and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[token]
	if bundled or tcoord then
		button.fgClassIcon:ClearAllPoints()
		if bundled then
			-- The bundled TGA is a full-bleed circle; the round class-circle icons have a
			-- little transparent padding, so render 2px smaller and centered to match.
			button.fgClassIcon:SetSize(iconSize - 3, iconSize - 3)
			button.fgClassIcon:SetPoint("LEFT", button, "LEFT", x + 1, 0)
			button.fgClassIcon:SetTexture(bundled)
			button.fgClassIcon:SetTexCoord(0, 1, 0, 1)
		else
			button.fgClassIcon:SetSize(iconSize, iconSize)
			button.fgClassIcon:SetPoint("LEFT", button, "LEFT", x, 0)
			button.fgClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			button.fgClassIcon:SetTexCoord(tcoord[1], tcoord[2], tcoord[3], tcoord[4])
		end
		button.fgClassIcon:Show()
		x = x + iconSize + 4
	else
		button.fgClassIcon:Hide()
	end

	local showStatus = not (FriendGroups_SavedVars and FriendGroups_SavedVars.show_status == false)
	local hasStar = button.Favorite and button.Favorite:IsShown()
	local statusX = nil
	if button.status then
		if showStatus then
			button.status:ClearAllPoints()
			button.status:SetPoint("LEFT", button, "LEFT", x, 0)
			button.status:SetSize(16, 16)
			button.status:Show()
			statusX = x
			x = x + 20
		else
			button.status:Hide()
		end
	end

	-- A visible favorite star claims the status slot even when the status icon is
	-- toggled off (retail parity), so the star never overlaps the name text.
	local starSlotX = statusX
	if not statusX and hasStar then
		starSlotX = x
		x = x + 20
	end

	-- Right reserve (retail parity: FriendGroups_ApplyRowLayout): invite button +
	-- margins, PLUS the game icon (when enabled) and the faction icon / realm flag
	-- (only when shown). Anchoring the text's right edge here is what produces the
	-- "..." truncation; toggling any element off lets the text reclaim that width.
	local showGameIcon = not (FriendGroups_SavedVars and FriendGroups_SavedVars.show_game_icon == false)
	local gameIconW = 22
	if button.gameIcon then
		local gw = button.gameIcon:GetWidth()
		if gw and gw >= 1 then gameIconW = gw end
	end
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

	if button.name then
		button.name:ClearAllPoints()
		button.name:SetJustifyH("LEFT")
		button.name:SetPoint("TOPLEFT", button, "TOPLEFT", x, -5)
		button.name:SetPoint("TOPRIGHT", button, "TOPRIGHT", -rightReserve, -5)
		button.name:SetWordWrap(false)
		-- Retail-parity font step-down via our derived font objects (see top of file).
		if FG_NAME_FONT then button.name:SetFontObject(FG_NAME_FONT) end
		if button.info then
			if FG_INFO_FONT then button.info:SetFontObject(FG_INFO_FONT) end
			button.info:ClearAllPoints()
			button.info:SetPoint("TOPLEFT", button.name, "BOTTOMLEFT", 0, -2)
			button.info:SetPoint("RIGHT", button.name, "RIGHT", 0, 0)
			button.info:SetJustifyH("LEFT")
			button.info:SetWordWrap(false)
			button.info:SetTextColor(0.486, 0.518, 0.541)
			button.info:Show()
		end
	end

	-- Favorite star: corner badge over the status icon when status is shown, or
	-- centered in the reserved slot when the star is the slot's only occupant.
	-- Never derived from the name text.
	if button.Favorite and starSlotX then
		button.Favorite:ClearAllPoints()
		button.Favorite:SetSize(14, 14)
		button.Favorite:SetDrawLayer("OVERLAY", 7)
		if statusX then
			button.Favorite:SetPoint("CENTER", button, "LEFT", statusX + 13, 6)
		else
			button.Favorite:SetPoint("CENTER", button, "LEFT", starSlotX + 8, 0)
		end
	end
end

-- ============================================================================
-- [[ PER-FRIEND ROW ]]
-- ============================================================================
RenderFriendButton = function(button, elementData)
	if elementData then
		button.id = elementData.id
		button.buttonType = elementData.buttonType
	end

	local id = button.id
	local buttonType = button.buttonType

	-- Safety check: If we have no ID (e.g., empty row), stop to prevent crash
	if not id then return end

	button.fgClass = nil
	button.fgNote = nil
	if button.facIcon then button.facIcon:Hide() end
	if button.realmFlag then button.realmFlag:Hide() end
	if button.gameIcon then button.gameIcon:SetDesaturated(false); button.gameIcon:SetVertexColor(1, 1, 1) end

	local nameText, nameColor, infoText, isFavoriteFriend, statusTexture
	local hasTravelPassButton = false
	local isCrossFactionInvite = false
	local inviteFaction = nil
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(id)
		button.fgClass = info and info.className
		button.fgNote = info and info.notes

		if (info and info.connected) then
			button.background:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g,
				FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a)
			if (info.afk) then
				button.status:SetTexture(FRIENDS_TEXTURE_AFK)
			elseif (info.dnd) then
				button.status:SetTexture(FRIENDS_TEXTURE_DND)
			else
				button.status:SetTexture(FRIENDS_TEXTURE_ONLINE)
			end

			nameText = info.name .. ", " .. format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className)
			nameColor = FRIENDS_WOW_NAME_COLOR
			infoText = FriendGroups_GetOnlineInfoText(BNET_CLIENT_WOW, info.mobile, info.rafLinkType, info.area)
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g,
				FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a)
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE)
			nameText = info and info.name or UNKNOWN
			nameColor = FRIENDS_GRAY_COLOR
			infoText = FRIENDS_LIST_OFFLINE
		end
		button.gameIcon:Hide()
		button.summonButton:ClearAllPoints()
		button.summonButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, -1)
		if FriendsFrame_SummonButton_Update then
			FriendsFrame_SummonButton_Update(button.summonButton)
		end
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)

		if accountInfo then
			-- Compatibility: Retail has helper, Classic needs manual extraction
			if FriendsFrame_GetBNetAccountNameAndStatus then
				nameText, nameColor, statusTexture = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo)
			else
				-- MoP Classic Fallback logic
				nameText = accountInfo.accountName
				nameColor = FRIENDS_BNET_NAME_COLOR or { r = 0.510, g = 0.773, b = 1.0 } -- Default Blue

				if accountInfo.gameAccountInfo.isOnline then
					if accountInfo.isAFK or accountInfo.gameAccountInfo.isGameAFK then
						statusTexture = FRIENDS_TEXTURE_AFK
					elseif accountInfo.isDND or accountInfo.gameAccountInfo.isGameBusy then
						statusTexture = FRIENDS_TEXTURE_DND
					else
						statusTexture = FRIENDS_TEXTURE_ONLINE
					end
				else
					statusTexture = FRIENDS_TEXTURE_OFFLINE
				end
			end

			local accountName, characterName, class, level, _, _,
			_, client, canCoop, _, _,
			_, isGameAFK, isDND, isGameBusy, mobile, zoneName, gameText, battleTag, factionName, timerunningSeasonID =
				FriendGroups_GetFriendInfoById(button.id)

			button.fgClass = class
			-- Live API returns nil class for retail-only classes (Demon Hunter / Evoker)
			-- on MoP. Fall back to the alt cache (from retail via Sync/import), which has
			-- the real class for this friend's current character.
			if (not class or class == "") and accountInfo.gameAccountInfo then
				local cached = FG_LookupCachedClass(accountInfo, characterName, accountInfo.gameAccountInfo.realmName)
				if cached then button.fgClass = cached end
			end
			-- 12.0.7 presence reduction: sessions often publish no characterName
			-- either, so the exact-match lookup above cannot fire. Fall through to
			-- the shared account-level tiers (selected main -> most recent alt).
			-- Guarded: the global is defined by FriendGroups.lua, which loads after
			-- this file (call happens at render time, so it exists by then).
			if (not button.fgClass or button.fgClass == "") and FriendGroups_LookupAccountClass
				and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
				button.fgClass = FriendGroups_LookupAccountClass(accountInfo, characterName,
					accountInfo.gameAccountInfo.realmName)
			end
			button.fgNote = accountInfo.note

			if FriendGroups_SavedVars.show_mobile_afk and client == 'BSAp' then
				statusTexture = FRIENDS_TEXTURE_AFK
			end

			-- Use button.fgClass (live class, or the alt-cache fallback for DH/Evoker) so
			-- the name is class-colored even when the live API returns no class.
			nameText = FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, button.fgClass, level,
				battleTag, timerunningSeasonID, nil, accountInfo.gameAccountInfo)

			isFavoriteFriend = accountInfo.isFavorite

			button.status:SetTexture(statusTexture)

			-- Read faction live: the load-time capture can be nil before the player
			-- entity is known, which would flag every friend as cross-faction.
			isCrossFactionInvite = accountInfo.gameAccountInfo.factionName ~= UnitFactionGroup("player")
			inviteFaction = accountInfo.gameAccountInfo.factionName

			if accountInfo.gameAccountInfo.isOnline then
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g,
					FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a)

				if FriendGroups_ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID, accountInfo.gameAccountInfo.areaName) then
					infoText = FriendGroups_GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram,
						accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType,
						accountInfo.gameAccountInfo.richPresence)
				else
					infoText = FriendGroups_GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram,
						accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType,
						accountInfo.gameAccountInfo.areaName, accountInfo.gameAccountInfo.realmName)
				end

				-- Cross-project friends carry the realm inside rich presence ("Zone - Realm").
				-- Honor Show Realm Names by dropping the trailing " - Realm" segment when off
				-- (the API realmName is empty for other-project friends, so match the string).
				if not FriendGroups_SavedVars.show_realm and type(infoText) == "string" and infoText ~= "" then
					local cut, pos = nil, 1
					while true do
						local a = infoText:find(" - ", pos, true)
						if not a then break end
						cut = a
						pos = a + 3
					end
					if cut then infoText = infoText:sub(1, cut - 1) end
				end

				-- [[ FIX: C_Texture Crash Prevention ]]
				if C_Texture and C_Texture.SetTitleIconTexture then
					C_Texture.SetTitleIconTexture(button.gameIcon, accountInfo.gameAccountInfo.clientProgram, Enum.TitleIconVersion.Medium)
				elseif BNet_GetClientTexture then
					-- Classic Fallback
					button.gameIcon:SetTexture(BNet_GetClientTexture(accountInfo.gameAccountInfo.clientProgram))
				end

				local fadeIcon = (accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and
					not Compat.IsSameProject(accountInfo.gameAccountInfo)
				if fadeIcon then
					button.gameIcon:SetAlpha(0.6)
				else
					button.gameIcon:SetAlpha(1)
				end
				-- Retail gold vs Classic green: tint the client icon by the friend project.
				Compat.TintGameIcon(button.gameIcon, accountInfo.gameAccountInfo)

				-- Compatibility: Only run if the function exists
				local shouldShowSummonButton = false
				if FriendsFrame_ShouldShowSummonButton then
					shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton)
				end
				local showGameIcon = not (FriendGroups_SavedVars.show_game_icon == false)
				button.gameIcon:SetShown(showGameIcon and not shouldShowSummonButton)

				-- travel pass
				hasTravelPassButton = true
				-- Compatibility: FriendsFrame_GetInviteRestriction might not exist in all versions
				local restriction = State.INVITE_RESTRICTION_NONE
				if FriendsFrame_GetInviteRestriction then
					restriction = FriendsFrame_GetInviteRestriction(button.id)
				end

				if restriction == State.INVITE_RESTRICTION_NONE then
					button.travelPassButton:Enable()
				else
					button.travelPassButton:Disable()
				end

				if FriendGroups_SavedVars.show_faction_icons then
					if not button.facIcon then
						button.facIcon = button:CreateTexture("facIcon")
						button.facIcon:SetWidth(button.gameIcon:GetWidth())
						button.facIcon:SetHeight(button.gameIcon:GetHeight())
					end
					button.facIcon:ClearAllPoints()
					if showGameIcon then
						button.facIcon:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
					else
						-- Game icon hidden: slide the faction icon into its slot so there is no gap.
						button.facIcon:SetPoint("RIGHT", button.gameIcon, "RIGHT", 0, 0)
					end
					button.facIcon:SetTexture(FriendGroups_GetFactionIcon(accountInfo.gameAccountInfo.factionName))
					button.facIcon:Show()
				else
					if button.facIcon then
						button.facIcon:Hide()
					end
				end

				-- Faction row tint -- its own toggle, independent of the faction icon.
				if FriendGroups_SavedVars.show_faction_color ~= false then
					if accountInfo.gameAccountInfo.factionName == "Horde" then
						button.background:SetColorTexture(0.7, 0.2, 0.2, 0.2)
					elseif accountInfo.gameAccountInfo.factionName == "Alliance" then
						button.background:SetColorTexture(0.2, 0.2, 0.7, 0.2)
					end
				end

				-- Realm flag (retail-parity): resolve the friend's realm -> flag texture.
				if FriendGroups_SavedVars.show_flags then
					if not button.realmFlag then
						button.realmFlag = button:CreateTexture("realmFlag")
						button.realmFlag:SetSize(button.gameIcon:GetWidth() * 0.75, button.gameIcon:GetHeight() * 0.75)
					end
					local flagTexture = FriendGroups_GetRealmInfo(accountInfo.gameAccountInfo)
					if flagTexture then
						button.realmFlag:SetTexture(flagTexture)
						button.realmFlag:Show()
						button.realmFlag:ClearAllPoints()
						if button.facIcon and button.facIcon:IsShown() then
							button.realmFlag:SetPoint("RIGHT", button.facIcon, "LEFT", -1, 0)
						elseif showGameIcon then
							button.realmFlag:SetPoint("RIGHT", button.gameIcon, "LEFT", 0, 0)
						else
							-- Both game + faction icons hidden: fill the slot so no gap remains.
							button.realmFlag:SetPoint("RIGHT", button.gameIcon, "RIGHT", 0, 0)
						end
					else
						button.realmFlag:Hide()
					end
				elseif button.realmFlag then
					button.realmFlag:Hide()
				end
			else
				button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g,
					FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a)
				button.gameIcon:Hide()
				-- Compatibility: Classic might lack this helper function
				if FriendsFrame_GetLastOnlineText then
					infoText = FriendsFrame_GetLastOnlineText(accountInfo)
				else
					infoText = FRIENDS_LIST_OFFLINE or "Offline"
				end
			end

			if FriendGroups_SavedVars.add_mobile_text and infoText == '' and client == 'BSAp' then
				infoText = L["STATUS_MOBILE"]
			end

			button.summonButton:ClearAllPoints()
			button.summonButton:SetPoint("CENTER", button.gameIcon, "CENTER", 1, 0)
			if FriendsFrame_SummonButton_Update then
				FriendsFrame_SummonButton_Update(button.summonButton)
			end
		end
	end

	if hasTravelPassButton then
		button.travelPassButton:Show()
	else
		button.travelPassButton:Hide()
	end

	-- Selection: ours on the own-list path, Blizzard's fields on the legacy one. Reading
	-- their fields is harmless, it is writing them that taints; the own list simply never
	-- writes them, so it has to keep its own answer. See OWN-LIST SELECTION AND CLICKS.
	local selected
	if Compat.UseOwnClassicList() then
		local selType, selId = Compat.GetClassicSelection()
		selected = (selType == buttonType) and (selId == id)
	else
		selected = (FriendsFrame.selectedFriendType == buttonType) and (FriendsFrame.selectedFriend == id)
	end

	-- [[ FIX: Compatibility Selection Logic ]]
	if FriendsFrame_FriendButtonSetSelection then
		FriendsFrame_FriendButtonSetSelection(button, selected)
	else
		-- Classic Fallback: Manual Highlight
		if selected then
			button:LockHighlight()
		else
			button:UnlockHighlight()
		end
	end

	-- finish setting up button if it's not a header
	if nameText then
		button.name:SetText(nameText)
		button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)

		-- Append the friend's note to the info line when Show Note is enabled.
		if FriendGroups_SavedVars.show_note ~= false and type(button.fgNote) == "string" and button.fgNote ~= "" then
			-- Nickname tag stripped: the row already shows it as the friend's name.
			local noteClean = FriendGroups_NoteForDisplay(button.fgNote)
			if noteClean ~= "" then
				infoText = (infoText and infoText ~= "") and (infoText .. "  " .. noteClean) or noteClean
			end
		end
		button.info:SetText(infoText)
		button:Show()

		-- Favorite star: create if the native template lacks one, and (re)assign its
		-- art exactly once per button -- a native template texture may exist but carry
		-- no valid art on MoP, so the assignment must run for pre-existing textures too.
		if not button.Favorite then
			button.Favorite = button:CreateTexture(nil, "OVERLAY")
		end
		if not button.fgFavoriteArtSet then
			FG_ApplyFavoriteArt(button.Favorite)
			button.fgFavoriteArtSet = true
		end

		-- Show/hide only -- LayoutRow seats the star as a fixed badge on the status
		-- slot (anchoring after the name text let long names push it off the row).
		if isFavoriteFriend then
			button.Favorite:Show()
		else
			button.Favorite:Hide()
		end
	else
		button:Hide()
	end

	-- update the tooltip if hovering over a button
	-- [[ FIX: Compatibility Focus Check ]]
	local isFocused = false
	if button.IsMouseMotionFocus then
		isFocused = button:IsMouseMotionFocus()
	elseif GetMouseFocus then
		isFocused = (GetMouseFocus() == button)
	end

	-- On the own-list path FriendsTooltip.button is deliberately never written, so the
	-- pointer is the only thing that can say whether this row is the hovered one. That is
	-- also all Blizzard's field was standing in for here.
	local refreshTooltip = isFocused
	if not Compat.UseOwnClassicList() then
		refreshTooltip = refreshTooltip or (FriendsTooltip.button == button)
	end

	if refreshTooltip then
		-- [[ FIX: Safe OnEnter Call for Classic ]] --
		if button.OnEnter then
			button:OnEnter()
		elseif button:GetScript("OnEnter") then
			button:GetScript("OnEnter")(button)
		end
	end

	-- show cross faction helptip on first online cross faction friend
	-- [[ FIX: Added check for LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE ]] --
	if HelpTip and hasTravelPassButton and isCrossFactionInvite and LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE) then
		local helpTipInfo = {
			text = CROSS_FACTION_INVITE_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
		}
		crossFactionHelpTipInfo = helpTipInfo
		crossFactionHelpTipButton = button
		HelpTip:Show(FriendsFrame, helpTipInfo, button.travelPassButton)
	end

	-- Known Alts panel hover hooks (retail parity; retail installs the identical block
	-- in its ScrollBox renderer). Without the OnLeave hook the panel gets stuck: the
	-- FriendsTooltip "Hide" hook's anti-flicker guard swallows the hide while the mouse
	-- is anywhere over FriendsFrame, and nothing else ever dismisses it on Classic.
	-- Installed once per pooled button; safe across recycling into header rows because
	-- FriendGroups_ShowButtonAltTooltip no-ops for non-BNet button types.
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

	-- update invite button atlas to show faction for cross faction players, or reset to default for same faction players
	if hasTravelPassButton then
		-- [[ FIX: Check if NormalTexture exists (Retail) vs Classic ]] --
		if button.travelPassButton.NormalTexture then
			if isCrossFactionInvite and inviteFaction == "Horde" then
				button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-horde-normal")
				button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-horde-pressed")
				button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-horde-disabled")
			elseif isCrossFactionInvite and inviteFaction == "Alliance" then
				button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-alliance-normal")
				button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-alliance-pressed")
				button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-alliance-disabled")
			else
				button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-default-normal")
				button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-default-pressed")
				button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-default-disabled")
			end
		else
			-- [[ CLASSIC FALLBACK ]] --
			button.travelPassButton:SetEnabled(true)
		end
	end

	return nil
end

-- ============================================================================
-- [[ GROUP HEADER ROW ]]
-- ============================================================================
RenderHeader = function(button, elementData)
	local groupName = elementData.groupName
	local groupOnline = State.groupsCount[groupName] and State.groupsCount[groupName]["Online"] or 0
	-- Denominator = raw group size (all members, unfiltered), not the filtered count.
	local groupTotal = State.groupsCount[groupName] and (State.groupsCount[groupName]["Raw"] or State.groupsCount[groupName]["Total"]) or 0

	-- Ensure Header-specific data
	button.id = 0
	button.buttonType = FRIENDS_BUTTON_TYPE_DIVIDER

	-- Draggable-header contract, see Platform_Drag.lua. rawGroupName is what retail's
	-- handlers already read; on Classic they had been falling through to button.name's
	-- text, which happens to agree because this renderer draws the bare group name. Drag
	-- and drop cannot rely on that coincidence, so the raw key is stamped explicitly, and
	-- RenderClassicList clears both again when this pooled button comes back as a friend.
	button.rawGroupName = groupName
	button.fgIsHeader = true
	Compat.AttachHeaderDrag(button, groupName)

	button:SetScript("OnMouseDown", nil)
	button:SetScript("OnClick", FriendGroups_FrameFriendDividerTemplateHeaderClick)

	-- 1. Setup Group Name (Aligned Left)
	button.name:Show()
	button.name:ClearAllPoints()
	button.name:SetJustifyH("LEFT")
	button.name:SetPoint("LEFT", button, "LEFT", 25, 0)
	-- Retail-parity font: headers use the 12px derived name font (matches the retail
	-- divider template in FriendGroups.xml, which inherits FriendsFont_Normal).
	if FG_NAME_FONT then button.name:SetFontObject(FG_NAME_FONT) end
	button.name:SetText(groupName)
	button.name:SetTextColor(1.0, 0.82, 0, 1.0)

	-- 2. Setup Counts (Force Same Line - Aligned Right)
	local infoText = string.format("%d/%d", groupOnline, groupTotal)
	if button.info then
		button.info:Show()
		button.info:ClearAllPoints()
		button.info:SetJustifyH("RIGHT")
		if FG_NAME_FONT then button.info:SetFontObject(FG_NAME_FONT) end
		button.info:SetPoint("RIGHT", button, "RIGHT", -10, 0)
		button.info:SetText(infoText)
		button.info:SetTextColor(1.0, 0.82, 0, 1.0)
	end

	-- 3. Handle Collapse Arrow
	if not button.collapseButton then
		button.collapseButton = CreateFrame("Button", nil, button)
		button.collapseButton:SetSize(16, 16)
		button.collapseButton:SetPoint("LEFT", button, "LEFT", 5, 0)
	end
	button.collapseButton:SetScript("OnClick", function() FriendGroups_FrameFriendDividerTemplateCollapseClick(button) end)
	button.collapseButton:Show()

	if FriendGroups_SavedVars.collapsed[groupName] then
		button.collapseButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP")
	else
		button.collapseButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
	end

	-- 4. Visual Cleanup -- hide every per-friend element so a header recycled from a
	-- friend row never leaves a class icon / realm flag / faction icon stuck behind.
	if button.gameIcon then button.gameIcon:Hide() end
	if button.status then button.status:Hide() end
	if button.travelPassButton then button.travelPassButton:Hide() end
	if button.Favorite then button.Favorite:Hide() end
	if button.facIcon then button.facIcon:Hide() end
	if button.fgClassIcon then button.fgClassIcon:Hide() end
	if button.realmFlag then button.realmFlag:Hide() end
	-- Group banner color (right-click header -> Set Banner Color), else the default tint.
	local hex = FriendGroups_SavedVars.banner_colors and FriendGroups_SavedVars.banner_colors[groupName]
	if type(hex) == "string" and #hex >= 6 then
		local r = (tonumber(hex:sub(1, 2), 16) or 0) / 255
		local g = (tonumber(hex:sub(3, 4), 16) or 0) / 255
		local b = (tonumber(hex:sub(5, 6), 16) or 0) / 255
		button.background:SetColorTexture(r, g, b, 0.4)
	else
		button.background:SetColorTexture(0, 0, 0, 0.2)
	end

	button:UnlockHighlight()
	button:Show()
end

-- ============================================================================
-- [[ OWN-LIST SELECTION AND CLICKS (Classic own-list path only) ]]
--
-- Blizzard's row handler calls FriendsFrame_SelectFriend, which writes
-- FriendsFrame.selectedFriendType. FriendsList_Update reads that field on every window
-- open, so one click on a row taints the execution that ends in RaidFrame:Show() and the
-- Raid tab stops opening in combat. So on the own-list path the rows are ours and the
-- selection is ours.
--
-- Only the TYPE is kept here. The index is read back from the client (BNGetSelectedFriend
-- / C_FriendList.GetSelectedFriend), which is exactly what Blizzard does with its own
-- field pair, and for the same reason: list indices shift as friends come and go, and the
-- client is the thing that keeps its own selection pointing at the same person. Those
-- setters and getters are C functions, so nothing addon-written travels with them.
-- ============================================================================

local FG_SelectedType
local FG_SelectedIndex

-- type, index of the selected row, or nil when nothing is selected. Mirrors Blizzard's
-- FriendsList_Update: type from the addon's own state, index from the client.
--
-- FG_SelectedIndex is a fallback, not a second source of truth. C_FriendList.SetSelectedFriend
-- is documented for Classic with no protection flag, but BNSetSelectedFriend is a legacy
-- global with no generated docs at all, and Blizzard only ever calls it from its own secure
-- row handler. If some client refuses it from addon code, the getter would report nothing and
-- the list would lose its highlight and its Send Message button. The clicked index covers
-- that: it can go stale as friends come and go, which is exactly why the client's own answer
-- is preferred whenever it gives one.
function Compat.GetClassicSelection()
	if FG_SelectedType == FRIENDS_BUTTON_TYPE_WOW then
		local id = C_FriendList and C_FriendList.GetSelectedFriend and C_FriendList.GetSelectedFriend()
		if id and id > 0 then return FG_SelectedType, id end
	elseif FG_SelectedType == FRIENDS_BUTTON_TYPE_BNET then
		local id = BNGetSelectedFriend and BNGetSelectedFriend()
		if id and id > 0 then return FG_SelectedType, id end
	else
		return nil, nil
	end
	if FG_SelectedIndex then return FG_SelectedType, FG_SelectedIndex end
	return nil, nil
end

-- Whisperable, nil-safe. Blizzard's FriendsList_CanWhisperFriend indexes the friend list
-- without guarding the result, which errors on a stale index -- and an index held across a
-- friend going offline is exactly what this path has to survive.
local function FG_CanWhisperSelection(buttonType, id)
	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		return true
	elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList and C_FriendList.GetFriendInfoByIndex and C_FriendList.GetFriendInfoByIndex(id)
		return (info and info.connected) and true or false
	end
	return false
end

-- Send Message follows the addon's selection, the way Blizzard's follows its own.
function Compat.UpdateClassicSendMessageButton()
	local button = FriendsFrameSendMessageButton
	if not button then return end
	local buttonType, id = Compat.GetClassicSelection()
	local enabled = (buttonType ~= nil) and FG_CanWhisperSelection(buttonType, id)
	if button.SetEnabled then
		button:SetEnabled(enabled)
	elseif enabled then
		button:Enable()
	else
		button:Disable()
	end
end

-- Select a row. Sound and ordering match Blizzard's FriendsFrameFriendButton_OnClick.
-- Record the selection and hand it to the client. Shared by the click path and the
-- first-row seed so both leave the same state behind, fallback index included.
local function FG_ApplySelection(buttonType, id)
	FG_SelectedType = buttonType
	FG_SelectedIndex = id
	if buttonType == FRIENDS_BUTTON_TYPE_WOW then
		if C_FriendList and C_FriendList.SetSelectedFriend then C_FriendList.SetSelectedFriend(id) end
	elseif buttonType == FRIENDS_BUTTON_TYPE_BNET then
		if BNSetSelectedFriend then BNSetSelectedFriend(id) end
	end
end

function Compat.SetClassicSelection(buttonType, id)
	if not buttonType or not id then return end
	FG_ApplySelection(buttonType, id)
	Compat.UpdateClassicSendMessageButton()
	Compat.RefreshClassicVisible()
end

-- Blizzard opens its list with the first friend selected (FriendsList_Update: "set to
-- first in list if no friend"). Same here, so the list never opens with no highlight and
-- a dead Send Message button, and so a selection lost to a friend going offline is
-- replaced rather than left dangling.
function Compat.EnsureClassicSelection(layout)
	if not layout then return end
	local buttonType = Compat.GetClassicSelection()
	if buttonType then return end
	for i = 1, #layout do
		local elementData = layout[i]
		local rowType = elementData and elementData.buttonType
		if rowType == FRIENDS_BUTTON_TYPE_BNET or rowType == FRIENDS_BUTTON_TYPE_WOW then
			-- No RefreshClassicVisible here: this runs from inside the render that is about
			-- to draw the rows anyway.
			FG_ApplySelection(rowType, elementData.id)
			Compat.UpdateClassicSendMessageButton()
			return
		end
	end
end

-- Row click. Left selects, right opens the unit menu. Both branches mirror Blizzard's
-- FriendsFrameFriendButton_OnClick, including the arguments it hands the menu, because
-- those are what carry FriendGroups' own injected entries (Menu.ModifyMenu on the
-- MENU_UNIT_BN_FRIEND / MENU_UNIT_FRIEND tags UnitPopup_OpenMenu raises from there).
function Compat.ClassicRowOnClick(button, mouseButton)
	local buttonType, id = button.buttonType, button.id
	if not buttonType or not id then return end

	if mouseButton == "LeftButton" then
		if PlaySound and SOUNDKIT then PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end
		Compat.SetClassicSelection(buttonType, id)

		-- Friends of Friends parity: with that window open, clicking another Battle.net
		-- friend switches it to them.
		if FriendsFriendsFrame and FriendsFriendsFrame:IsShown()
			and buttonType == FRIENDS_BUTTON_TYPE_BNET and BNGetFriendInfo then
			local bnetIDAccount = BNGetFriendInfo(id)
			if bnetIDAccount and bnetIDAccount ~= FriendsFriendsFrame.bnetIDAccount
				and FriendsFriendsFrame_Show then
				FriendsFriendsFrame_Show(bnetIDAccount)
			end
		end
	elseif mouseButton == "RightButton" then
		if PlaySound and SOUNDKIT then PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end
		if buttonType == FRIENDS_BUTTON_TYPE_BNET then
			if not BNGetFriendInfo or not FriendsFrame_ShowBNDropdown then return end
			local bnetIDAccount, accountName, battleTag, isBattleTag, characterName,
				bnetIDGameAccount, client, isOnline = BNGetFriendInfo(id)
			FriendsFrame_ShowBNDropdown(accountName, isOnline, nil, nil, nil, 1, bnetIDAccount,
				nil, nil, nil, nil)
		else
			if not FriendsFrame_ShowDropdown then return end
			local info = C_FriendList and C_FriendList.GetFriendInfoByIndex
				and C_FriendList.GetFriendInfoByIndex(id)
			if not info then return end
			FriendsFrame_ShowDropdown(info.name, info.connected, nil, nil, nil, 1, nil, nil,
				nil, nil, nil, info.guid)
		end
	end
end

-- Blizzard's Send Message reads its own selection fields, so it has to be replaced
-- alongside the rows. Same calls it makes (ChatFrameUtil.SendTell / SendBNetTell): Classic
-- has no secret values, so the chat taint the retail priming path exists to avoid is
-- harmless here, and the button keeps working in one click.
function Compat.ClassicSendMessageOnClick()
	local buttonType, id = Compat.GetClassicSelection()
	if not buttonType then return end

	local util = ChatFrameUtil
	if buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList and C_FriendList.GetFriendInfoByIndex
			and C_FriendList.GetFriendInfoByIndex(id)
		local name = info and info.name
		if not name then return end
		local send = (util and util.SendTell) or _G.ChatFrame_SendTell
		if not send then return end
		send(name)
		-- Blizzard plays this on the WoW branch only, and not for a Battle.net whisper.
		-- Mirrored rather than tidied: the point of this path is that nothing the player
		-- can see or hear changes.
		if PlaySound and SOUNDKIT then PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end
	elseif buttonType == FRIENDS_BUTTON_TYPE_BNET then
		if not BNGetFriendInfo then return end
		local _, tokenizedName = BNGetFriendInfo(id)
		local send = (util and util.SendBNetTell) or _G.ChatFrame_SendBNetTell
		if not send or not tokenizedName then return end
		send(tokenizedName)
	end
end

-- ============================================================================
-- [[ ELVUI ADAPTER (Classic own-list path only) ]]
--
-- ElvUI styles the Classic friends list by global name -- the eleven
-- FriendsFrameFriendsScrollFrameButtonN rows and that frame's scrollbar
-- (ElvUI/Game/TBC/Skins/Friends.lua). Those names belong to Blizzard's list, so once the
-- addon draws its own, ElvUI's work lands on a frame nobody can see. This puts the same
-- treatment on our frame instead: strip the scrollbar border art, hand the bar to ElvUI's
-- own HandleScrollBar, and give each row ElvUI's highlight texture and flattened summon
-- button. Rows past the eleventh get it too, which they never did on Blizzard's frame.
--
-- Only ever touches frames FriendGroups created. Calling an ElvUI helper on a Blizzard
-- frame from here would taint it, which is the thing this whole path exists to avoid.
--
-- Respects the player's own ElvUI switches (blizzard.enable and blizzard.friends): a skin
-- they turned off must stay off. Nothing is cached as "not applicable" -- ElvUI initialises
-- on its own schedule, so an early call simply returns and the next render tries again.
-- ============================================================================

function Compat.SkinClassicListForElvUI()
	local list = _G.FriendGroupsClassicList
	if not list then return end

	local suite = _G.ElvUI
	if type(suite) ~= "table" then return end
	local E = suite[1]
	if type(E) ~= "table" or type(E.private) ~= "table" or type(E.GetModule) ~= "function" then
		return
	end

	local blizzard = E.private.skins and E.private.skins.blizzard
	if not (blizzard and blizzard.enable and blizzard.friends) then return end

	local ok, S = pcall(E.GetModule, E, "Skins")
	if not ok or type(S) ~= "table" then return end

	if not list.fgElvSkinned then
		list.fgElvSkinned = true
		if type(list.StripTextures) == "function" then pcall(list.StripTextures, list) end
		if list.scrollBar and type(S.HandleScrollBar) == "function" then
			pcall(S.HandleScrollBar, S, list.scrollBar)
		end
	end

	local buttons = list.buttons
	if not buttons then return end

	local highlightTexture = E.Media and E.Media.Textures and E.Media.Textures.Highlight
	for i = 1, #buttons do
		local button = buttons[i]
		if button and not button.fgElvSkinned then
			button.fgElvSkinned = true
			if button.highlight and highlightTexture then
				button.highlight:SetTexture(highlightTexture)
				button.highlight:SetAlpha(0.3)
			end
			local summon = button.summonButton
			if summon then
				if type(summon.StyleButton) == "function" then pcall(summon.StyleButton, summon) end
				local normal = summon.GetNormalTexture and summon:GetNormalTexture()
				if normal then normal:SetAlpha(0) end
			end
		end
	end
end

-- ============================================================================
-- [[ OWN-LIST ROW TOOLTIP (Classic own-list path only) ]]
--
-- The last taint source on the open path. Blizzard's FriendsFrameTooltip_Show ends with
--   tooltip.button = self
-- and Blizzard's own row renderer reads FriendsTooltip.button once per row on every window
-- open (FriendsFrame_UpdateFriendButton, "update the tooltip if hovering over a button").
-- That single write is enough to taint the execution that ends in RaidFrame:Show(), so
-- hovering a row would keep the Raid tab broken in combat even with the rows and selection
-- already ours. A decoy button object does not help: taint attaches to the field, not to
-- the value in it.
--
-- So this is Blizzard's function with that one line left out. Everything else it does is
-- safe: it draws into Blizzard's own FriendsTooltip frame, and Blizzard's
-- FriendsFrameTooltip_SetLine writes only tooltip.height and tooltip.maxWidth, which
-- nothing on the open path reads.
--
-- Blizzard's frame rather than one of our own, deliberately: addons that hook
-- FriendsTooltip:Show keep working, which on Classic means Raider.IO (MoP and Era builds;
-- there is no TBC one) and anything else that decorates the friend tooltip.
--
-- tooltip.hasBroadcast is deliberately NOT set. Blizzard's FriendsTooltip OnUpdate runs
--   if self.hasBroadcast then FriendsFrameTooltip_Show(self.button) end
-- and with .button left nil that would error every frame. All that is lost is the re-layout
-- of a broadcast line while the pointer sits still, which Blizzard added for alternate
-- alphabets; it is rebuilt on the next hover.
--
-- Mirrored from the live Classic source (FriendsFrame.lua, FriendsFrameTooltip_Show). If
-- Blizzard changes the tooltip's content, this has to follow.
-- ============================================================================

local FG_TOOLTIP_ONE_YEAR = 12 * 30 * 24 * 60 * 60

-- Blizzard's ShowRichPresenceOnly is a file local, so it is repeated here. Player realm
-- and faction are read live rather than captured: Blizzard caches them on login events,
-- and a cached nil faction is exactly the bug the Classic renderer already had once.
local function FG_ShowRichPresenceOnly(client, wowProjectID, faction, realmID)
	if client ~= BNET_CLIENT_WOW or wowProjectID ~= WOW_PROJECT_ID then
		return true
	end
	local playerFaction = UnitFactionGroup("player")
	local playerRealmID = GetNativeRealmID and GetNativeRealmID()
	if faction ~= playerFaction or realmID ~= playerRealmID then
		return true
	end
	return false
end

-- Raider.IO decorates the friend tooltip by hooking FriendsTooltip:Show and reading
-- .button to work out who the row is. With that field left nil it bails, so the profile is
-- requested directly through its documented API instead (ShowProfile draws on the tooltip
-- it is handed and shows it). Entirely optional: no Raider.IO, nothing happens.
local function FG_AddRaiderIOProfile(name, realm)
	if not name or name == "" then return end
	local RIO = _G.RaiderIO
	if type(RIO) ~= "table" or type(RIO.ShowProfile) ~= "function" then return end
	if not GameTooltip or not FriendsTooltip then return end
	GameTooltip:SetOwner(FriendsTooltip, "ANCHOR_BOTTOMRIGHT", -FriendsTooltip:GetWidth(), -4)
	local ok, drawn = pcall(RIO.ShowProfile, GameTooltip, name, realm)
	if not ok or not drawn then GameTooltip:Hide() end
end

function Compat.ShowClassicRowTooltip(button)
	if not button or button.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then return end

	local tooltip = FriendsTooltip
	local SetLine = FriendsFrameTooltip_SetLine
	local id = button.id
	if not tooltip or type(SetLine) ~= "function" or not id then return end

	local wowInfoTemplate = NORMAL_FONT_COLOR_CODE .. FRIENDS_LIST_ZONE .. "|r%1$s|n"
		.. NORMAL_FONT_COLOR_CODE .. FRIENDS_LIST_REALM .. "|r%2$s"
	local anchor, text
	local numGameAccounts = 0
	local isOnline = false
	local battleTag = ""
	-- Raider.IO's subject, filled in by whichever branch knows a WoW character.
	local rioName, rioRealm

	tooltip.height = 0
	tooltip.maxWidth = 0

	if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local bnetIDAccount, accountName, isBattleTag, _characterName, bnetIDGameAccount,
			_client, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend, broadcastTime
		bnetIDAccount, accountName, battleTag, isBattleTag, _characterName, bnetIDGameAccount,
			_client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend,
			broadcastTime = BNGetFriendInfo(id)

		anchor = SetLine(FriendsTooltipHeader, nil, accountName or UNKNOWN)

		if bnetIDGameAccount then
			local _hasFocus, characterName, client, realmName, realmID, faction, race, class,
				_guild, zoneName, level, gameText, _broadcast, _broadcastTime, _canSoR,
				_toonID, _isGameAFK, _isGameBusy, _guid, _wowProjectIDUnused, wowProjectID,
				realmDisplayName = BNGetGameAccountInfo(bnetIDGameAccount)
			level = level or ""
			race = race or ""
			class = class or ""

			if FG_ShowRichPresenceOnly(client, wowProjectID, faction, realmID) then
				if isOnline then
					characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ""
				end
				SetLine(FriendsTooltipGameAccount1Name, nil, characterName)
				anchor = SetLine(FriendsTooltipGameAccount1Info, nil, gameText, -4)
			else
				if CanCooperateWithGameAccount(bnetIDGameAccount) then
					text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, characterName, level, race, class)
				else
					text = string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE,
						characterName .. CANNOT_COOPERATE_LABEL, level, race, class)
				end
				SetLine(FriendsTooltipGameAccount1Name, nil, text)
				anchor = SetLine(FriendsTooltipGameAccount1Info, nil,
					string.format(wowInfoTemplate, zoneName, realmDisplayName), -4)
				rioName, rioRealm = characterName, realmName
			end
		else
			FriendsTooltipGameAccount1Info:Hide()
			FriendsTooltipGameAccount1Name:Hide()
		end

		if noteText and noteText ~= "" then
			FriendsTooltipNoteIcon:Show()
			anchor = SetLine(FriendsTooltipNoteText, anchor, noteText, -8)
		else
			FriendsTooltipNoteIcon:Hide()
			FriendsTooltipNoteText:Hide()
		end

		if broadcastText and broadcastText ~= "" then
			FriendsTooltipBroadcastIcon:Show()
			if broadcastTime and time() - broadcastTime < FG_TOOLTIP_ONE_YEAR then
				broadcastText = broadcastText .. "|n" .. FRIENDS_BROADCAST_TIME_COLOR_CODE
					.. string.format(BNET_BROADCAST_SENT_TIME,
						FriendsFrame_GetLastOnline(broadcastTime) .. FONT_COLOR_CODE_CLOSE)
			end
			anchor = SetLine(FriendsTooltipBroadcastText, anchor, broadcastText, -8)
		else
			FriendsTooltipBroadcastIcon:Hide()
			FriendsTooltipBroadcastText:Hide()
		end

		if isOnline then
			FriendsTooltipHeader:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g,
				FRIENDS_BNET_NAME_COLOR.b)
			FriendsTooltipLastOnline:Hide()
			numGameAccounts = BNGetNumFriendGameAccounts(id)
		else
			FriendsTooltipHeader:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g,
				FRIENDS_GRAY_COLOR.b)
			if not lastOnline or lastOnline == 0 or time() - lastOnline >= FG_TOOLTIP_ONE_YEAR then
				text = FRIENDS_LIST_OFFLINE
			else
				text = string.format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline))
			end
			anchor = SetLine(FriendsTooltipLastOnline, anchor, text, -4)
		end
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(id)
		if not info then return end
		anchor = SetLine(FriendsTooltipHeader, nil, info.name)
		if info.connected then
			FriendsTooltipHeader:SetTextColor(FRIENDS_WOW_NAME_COLOR.r, FRIENDS_WOW_NAME_COLOR.g,
				FRIENDS_WOW_NAME_COLOR.b)
			SetLine(FriendsTooltipGameAccount1Name, nil,
				string.format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className))
			anchor = SetLine(FriendsTooltipGameAccount1Info, nil, info.area)
		else
			FriendsTooltipHeader:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g,
				FRIENDS_GRAY_COLOR.b)
			FriendsTooltipGameAccount1Name:Hide()
			FriendsTooltipGameAccount1Info:Hide()
		end
		if info.notes then
			FriendsTooltipNoteIcon:Show()
			anchor = SetLine(FriendsTooltipNoteText, anchor, info.notes, -8)
		else
			FriendsTooltipNoteIcon:Hide()
			FriendsTooltipNoteText:Hide()
		end
		FriendsTooltipBroadcastIcon:Hide()
		FriendsTooltipBroadcastText:Hide()
		FriendsTooltipLastOnline:Hide()
		-- WoW friends are same-realm on Classic, so the row's name is enough and the realm
		-- is left for Raider.IO to default to the player's.
		rioName = info.name
	end

	-- Other game accounts, capped and then blanked out to the cap, exactly as Blizzard does.
	local gameAccountIndex = 1
	local characterNameString, gameAccountInfoString
	if numGameAccounts > 1 then
		local headerSet = false
		local playerRealmName = GetRealmName()
		local playerFactionGroup = UnitFactionGroup("player")
		for i = 1, numGameAccounts do
			local hasFocus, characterName, client, realmName, _realmID, faction, race, class,
				_guild, zoneName, level, gameText, _broadcast, _broadcastTime, _canSoR,
				_toonID, _isGameAFK, _isGameBusy, _guid, _unused, wowProjectID =
				BNGetFriendGameAccountInfo(id, i)
			if not hasFocus and client ~= BNET_CLIENT_APP and client ~= BNET_CLIENT_CLNT then
				if not headerSet then
					SetLine(FriendsTooltipOtherGameAccounts, anchor, nil, -8)
					headerSet = true
				end
				gameAccountIndex = gameAccountIndex + 1
				if gameAccountIndex > FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS then
					break
				end
				characterNameString = _G["FriendsTooltipGameAccount" .. gameAccountIndex .. "Name"]
				gameAccountInfoString = _G["FriendsTooltipGameAccount" .. gameAccountIndex .. "Info"]
				text = BNet_GetClientEmbeddedAtlas(client, 18) .. " "
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					if realmName == playerRealmName and faction == playerFactionGroup then
						text = text .. string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE,
							characterName, level, race, class)
					else
						text = text .. string.format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE,
							characterName .. CANNOT_COOPERATE_LABEL, level, race, class)
					end
					gameText = zoneName
				else
					if isOnline then
						characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or ""
					end
					text = text .. characterName
				end
				SetLine(characterNameString, nil, text)
				SetLine(gameAccountInfoString, nil, gameText)
			end
		end
		if not headerSet then
			FriendsTooltipOtherGameAccounts:Hide()
		end
	else
		FriendsTooltipOtherGameAccounts:Hide()
	end
	for i = gameAccountIndex + 1, FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS do
		_G["FriendsTooltipGameAccount" .. i .. "Name"]:Hide()
		_G["FriendsTooltipGameAccount" .. i .. "Info"]:Hide()
	end
	if numGameAccounts > FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS then
		SetLine(FriendsTooltipGameAccountMany, nil,
			string.format(FRIENDS_TOOLTIP_TOO_MANY_CHARACTERS,
				numGameAccounts - FRIENDS_TOOLTIP_MAX_GAME_ACCOUNTS), 0)
	else
		FriendsTooltipGameAccountMany:Hide()
	end

	-- Blizzard's tail, minus `tooltip.button = self`. ClearAllPoints first because this
	-- anchors to a different row each time; anchoring and sizing are widget state and
	-- carry no taint.
	tooltip:ClearAllPoints()
	tooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 36, 0)
	tooltip:SetHeight(tooltip.height + FRIENDS_TOOLTIP_MARGIN_WIDTH)
	tooltip:SetWidth(min(FRIENDS_TOOLTIP_MAX_WIDTH, tooltip.maxWidth + FRIENDS_TOOLTIP_MARGIN_WIDTH))
	tooltip:Show()

	FG_AddRaiderIOProfile(rioName, rioRealm)
end

-- Blizzard's row OnLeave writes FriendsTooltip.button = nil, which taints the field just as
-- surely as writing a frame into it. Hiding is enough on its own.
function Compat.HideClassicRowTooltip()
	if FriendsTooltip then FriendsTooltip:Hide() end
end

function Compat.InstallClassicSendMessageOverride()
	local button = FriendsFrameSendMessageButton
	if not button or button.fgOwnListSendMessage then return end
	button.fgOwnListSendMessage = true
	button:SetScript("OnClick", Compat.ClassicSendMessageOnClick)
	Compat.UpdateClassicSendMessageButton()
end

-- ============================================================================
-- [[ HYBRIDSCROLL DRIVER ]]
-- Renders the visible slice of `layout` (the array FriendGroups_FriendsListUpdate
-- builds) into the HybridScroll button pool Compat.GetClassicListFrame hands back --
-- FriendGroups' own list, or Blizzard's on the legacy path. Called for the initial
-- build and, via that frame's .update field, on every scroll.
-- ============================================================================
function Compat.RenderClassicList(layout)
	-- Bind shared state on first use (FriendGroups.lua has loaded by render time).
	-- RenderHeader / RenderFriendButton share this upvalue, so they see it too.
	State = State or addonTable.State

	local scrollFrame = Compat.GetClassicListFrame()
	if not scrollFrame then return end
	local buttons = scrollFrame.buttons
	if not buttons then return end

	-- Own-list path only: seed the selection from the first friend row when there is none,
	-- which is what Blizzard's own update does. Runs before the rows are drawn so the
	-- highlight is right on the first paint.
	if Compat.UseOwnClassicList() then
		Compat.EnsureClassicSelection(layout)
		-- Cheap and idempotent: per-frame and per-row flags mean this is a handful of
		-- table lookups once everything has been styled, and it is the one place that
		-- reliably sees rows the size setting added later.
		Compat.SkinClassicListForElvUI()
	end

	-- Force uniform fixed-height scrolling. Blizzard's friends list installs a
	-- dynamic-height callback (scrollFrame.dynamic) for variable-height rows; our
	-- rows are a uniform 34px. Left set, HybridScrollFrame_SetOffset calls it and
	-- it returns nil at large scroll offsets -> math.floor(nil) crash. Clearing it
	-- routes SetOffset through the fixed-height path (element = offset/buttonHeight).
	--
	-- Only Blizzard's frame ever has one; ours is created without it, so on the own-list
	-- path this is a no-op write to our own field rather than a write to theirs.
	scrollFrame.dynamic = nil

	local offset = HybridScrollFrame_GetOffset(scrollFrame)
	local numButtons = #buttons
	local dataSize = #layout

	local totalHeight = dataSize * 34
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight())

	for i = 1, numButtons do
		local button = buttons[i]
		local index = i + offset
		if index <= dataSize then
			local elementData = layout[index]
			button.index = index
			button:SetHeight(34)

			if elementData.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
				RenderHeader(button, elementData)
			else
				-- 1. Restore standard IDs
				button.id = elementData.id
				button.buttonType = elementData.buttonType

				-- This pool is shared with the group headers, so the drag registration has
				-- to come off here. A button left registered for drag swallows the click
				-- that selects a friend as soon as the pointer moves a couple of pixels --
				-- which is the whole point of the registration on a header, and a silent
				-- regression on a friend row.
				button.rawGroupName = nil
				button.fgIsHeader = nil
				Compat.DetachHeaderDrag(button)

				-- Reset recycled buttons to the click handler for the list in force. The
				-- pool is shared with group headers, which install their own, so this has
				-- to be re-applied on every render.
				--
				-- Blizzard's handler is only correct on the legacy path: it calls
				-- FriendsFrame_SelectFriend, which writes FriendsFrame.selectedFriendType,
				-- the field FriendsList_Update reads on every window open.
				if Compat.UseOwnClassicList() then
					button:SetScript("OnClick", Compat.ClassicRowOnClick)

					-- Hover too: Blizzard's OnEnter is FriendsFrameTooltip_Show, which
					-- writes FriendsTooltip.button, and its OnLeave writes that field back
					-- to nil. Both taint it. See OWN-LIST ROW TOOLTIP.
					--
					-- ONCE per button, unlike OnClick above. HookScript works by wrapping
					-- whatever script is installed and setting the wrapper, so a SetScript
					-- on every render would throw away the alt-tooltip hooks that
					-- RenderFriendButton adds a few lines further down -- and it only adds
					-- them once. The header renderer never touches these two, so setting
					-- them once is enough.
					if not button.fgOwnListHoverScripts then
						button.fgOwnListHoverScripts = true
						button:SetScript("OnEnter", Compat.ShowClassicRowTooltip)
						button:SetScript("OnLeave", Compat.HideClassicRowTooltip)
					end
				else
					button:SetScript("OnClick", FriendsFrameFriendButton_OnClick)
				end
				-- Cleared, not restored: there is no FriendsFrameFriendButton_OnMouseDown
				-- on any Classic client, so the call this replaces was already setting nil.
				button:SetScript("OnMouseDown", nil)

				-- 2. Hide Header-only elements
				if button.collapseButton then button.collapseButton:Hide() end
				if button.info then button.info:Hide() end

				-- 3. Standard render call
				RenderFriendButton(button, elementData)

				-- 4. Row layout: class icon + status + name/info
				LayoutRow(button)
			end
			button:Show()
		else
			button:Hide()
		end
	end
end

-- Lightweight idle refresh -- the Classic counterpart of retail's
-- ScrollBox:ForEachFrame fast path in FriendGroups_FriendsListUpdate. Re-renders
-- the currently visible friend rows in place from their stamped id/buttonType
-- (AFK timers, status flips) without rebuilding the layout. Header rows carry
-- FRIENDS_BUTTON_TYPE_DIVIDER and are skipped, exactly like the retail path.
function Compat.RefreshClassicVisible()
	State = State or addonTable.State
	local scrollFrame = Compat.GetClassicListFrame()
	local buttons = scrollFrame and scrollFrame.buttons
	if not buttons then return end
	for i = 1, #buttons do
		local button = buttons[i]
		if button:IsShown() and button.id
			and (button.buttonType == FRIENDS_BUTTON_TYPE_BNET or button.buttonType == FRIENDS_BUTTON_TYPE_WOW) then
			RenderFriendButton(button)
			LayoutRow(button)
		end
	end
end
