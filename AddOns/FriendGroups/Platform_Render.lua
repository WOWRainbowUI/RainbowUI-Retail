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

	local selected = (FriendsFrame.selectedFriendType == buttonType) and (FriendsFrame.selectedFriend == id)

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
			local noteClean = strtrim(button.fgNote)
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

	if (FriendsTooltip.button == button) or isFocused then
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
-- [[ HYBRIDSCROLL DRIVER ]]
-- Renders the visible slice of `layout` (the array FriendGroups_FriendsListUpdate
-- builds) into the native MoP button pool. Called for the initial build and, via
-- FriendsFrameFriendsScrollFrame.update, on every scroll.
-- ============================================================================
function Compat.RenderClassicList(layout)
	-- Bind shared state on first use (FriendGroups.lua has loaded by render time).
	-- RenderHeader / RenderFriendButton share this upvalue, so they see it too.
	State = State or addonTable.State

	local scrollFrame = FriendsFrameFriendsScrollFrame
	if not scrollFrame then return end
	local buttons = scrollFrame.buttons
	if not buttons then return end

	-- Force uniform fixed-height scrolling. The native friends list installs a
	-- dynamic-height callback (scrollFrame.dynamic) for variable-height rows; our
	-- rows are a uniform 34px. Left set, HybridScrollFrame_SetOffset calls it and
	-- it returns nil at large scroll offsets -> math.floor(nil) crash. Clearing it
	-- routes SetOffset through the fixed-height path (element = offset/buttonHeight).
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

				-- Reset recycled buttons to native click handlers
				button:SetScript("OnClick", FriendsFrameFriendButton_OnClick)
				button:SetScript("OnMouseDown", FriendsFrameFriendButton_OnMouseDown)

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
	local scrollFrame = FriendsFrameFriendsScrollFrame
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
