-- Auto-accept behaviours and the countdown toast for group invites and Party Sync.
-- Blizzard's dialog stays up during the countdown; see FG_HideBlizzardPopup for its dismissal.

local addonName, addonTable = ...
local L = addonTable.L
local Compat = addonTable.Compat

-- ============================================================================
-- [[ BRAND ]]
-- ============================================================================

-- FriendGroups mint #33FF99, matching the chat prefix; not a class colour.
local FG_R, FG_G, FG_B = 0.20, 1.00, 0.60

-- The addon's own logo, the same file the TOC declares as its IconTexture.
local FG_LOGO = "Interface\\AddOns\\FriendGroups\\Textures\\fg"

-- Paths, not fileIDs, so they resolve on every flavor.
local FG_ICON_INVITE = "Interface\\Icons\\INV_Misc_GroupNeedMore"
local FG_ICON_SYNC   = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend"

-- BackdropTemplate only where BackdropTemplateMixin exists; else native SetBackdrop.
local FG_BACKDROP_TEMPLATE = (type(BackdropTemplateMixin) == "table") and "BackdropTemplate" or nil

-- From GameFontNormal: koKR/zhCN/zhTW have no FRIZQT__.TTF. May be nil (FG_ToastFontString).
local FG_FONT = (GameFontNormal and type(GameFontNormal.GetFont) == "function" and GameFontNormal:GetFont())
	or STANDARD_TEXT_FONT

-- ============================================================================
-- [[ SAFETY PRIMITIVES ]]
-- ============================================================================

-- 12.0 may deliver a player name as a secret value. Formatting or comparing one
-- taints the execution path, so an unusable name is reported as nil and callers
-- fall back to the anonymous body string instead of trying to render it.
local function FG_PlainName(name)
	if type(name) ~= "string" then return nil end
	if type(issecretvalue) == "function" and issecretvalue(name) then return nil end
	if name == "" then return nil end
	return name
end

local function FG_Announce(message)
	if type(message) ~= "string" then return end
	if not DEFAULT_CHAT_FRAME then return end
	DEFAULT_CHAT_FRAME:AddMessage(message)
end

-- C_AddOns is the modern namespace; the bare globals remain the documented entry
-- points on the older Classic clients. Resolved once, never assumed.
local FG_IsAddOnLoaded = (C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function")
	and C_AddOns.IsAddOnLoaded
	or (type(IsAddOnLoaded) == "function" and IsAddOnLoaded or nil)

local FG_GetAddOnMetadata = (C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function")
	and C_AddOns.GetAddOnMetadata
	or (type(GetAddOnMetadata) == "function" and GetAddOnMetadata or nil)

-- [[ FEATURE REGISTRY ]] Arbitration, claim and diagnostic all key off this table.

local FG_FEATURE_SAVEDVAR = {
	invite  = "auto_accept_invite",
	sync    = "auto_accept_sync",
}

-- Display order for the /fg automation report, and the localized label each
-- feature reports under (reusing the settings-menu labels the user already sees).
local FG_FEATURE_ORDER = { "invite", "sync" }
local FG_FEATURE_LABEL = {
	invite  = "SET_AUTO_ACCEPT",
	sync    = "SET_AUTO_PARTY_SYNC",
}

local function FG_FeatureEnabled(feature)
	local key = FG_FEATURE_SAVEDVAR[feature]
	if not key then return false end
	return FriendGroups_SavedVars ~= nil and FriendGroups_SavedVars[key] == true
end

-- [[ CROSS-ADDON ARBITRATION ]] GLogger always wins: we can read its state, not change it.
-- Ladder: published claim, then addon/AceAddon/module checks, then GetUIState. Evaluated per
-- event, pcall-wrapped; anything unreadable counts as "GLogger not active".

local GLOGGER_ADDON  = "GLogger"
local GLOGGER_MODULE = "AutoInvite"
-- Only the features FriendGroups still implements need arbitrating. GLogger's res
-- and release settings are no longer anyone's business but its own.
local GLOGGER_STATE_KEY = {
	invite  = "UIAutoAcceptInvites",
	sync    = "UIAutoAcceptSync",
}

-- Last-ditch stacking guard, one entry per companion toast frame (GLogger has two).
local FG_EXTERNAL_TOAST_FRAMES = { "GLoggerInviteToast", "GLoggerSyncToast" }

local function FG_ExternalToastShown(index)
	local frame = _G[FG_EXTERNAL_TOAST_FRAMES[index]]
	if type(frame) ~= "table" then return nil end
	if type(frame.IsShown) ~= "function" or not frame:IsShown() then return nil end
	return frame
end

local function FG_ExternalToastVisible()
	for i = 1, #FG_EXTERNAL_TOAST_FRAMES do
		if FG_ExternalToastShown(i) then return true end
	end
	return false
end

-- Reserve the slots companion toasts report holding; counting them misplaces ours when they
-- close out of order. A toast with no slot reserves the next free one.
local function FG_ReserveExternalSlots(occupied)
	local fallback = 0
	for i = 1, #FG_EXTERNAL_TOAST_FRAMES do
		local frame = FG_ExternalToastShown(i)
		if frame then
			if type(frame.ToastSlot) == "number" then
				occupied[frame.ToastSlot] = true
			else
				while occupied[fallback] do fallback = fallback + 1 end
				occupied[fallback] = true
			end
		end
	end
end

-- Returns the name of the companion addon currently owning `feature`, or nil.
local function FG_ExternalOwner(feature)
	if not GLOGGER_STATE_KEY[feature] then return nil end

	-- Tier 1: published claim. Authoritative in both directions -- a claim that
	-- does not list this feature means that addon does not handle it.
	local claim = _G.GLogger_Automation_Claim
	if type(claim) == "table" then
		local features = claim.features
		if type(features) ~= "table" or not features[feature] then return nil end
		if type(claim.IsActive) ~= "function" then return GLOGGER_ADDON end
		local ok, active = pcall(claim.IsActive, feature)
		if ok and active then return GLOGGER_ADDON end
		return nil
	end

	-- Tier 2: is it even loaded?
	if type(FG_IsAddOnLoaded) ~= "function" then return nil end
	local okLoaded, loaded = pcall(FG_IsAddOnLoaded, GLOGGER_ADDON)
	if not okLoaded or not loaded then return nil end

	-- Tier 3: the AceAddon object. LibStub is a table with a __call metamethod,
	-- and the trailing true is its silent flag (returns nil instead of erroring).
	local libStub = _G.LibStub
	if type(libStub) ~= "table" then return nil end
	local okAce, ace = pcall(libStub, "AceAddon-3.0", true)
	if not okAce or type(ace) ~= "table" or type(ace.GetAddon) ~= "function" then return nil end
	local okAddon, glogger = pcall(ace.GetAddon, ace, GLOGGER_ADDON, true)
	if not okAddon or type(glogger) ~= "table" then return nil end

	-- Tier 4: the module that owns these handlers. Absent or disabled means
	-- nothing over there is listening, whatever the settings say.
	if type(glogger.GetModule) == "function" then
		local okMod, module = pcall(glogger.GetModule, glogger, GLOGGER_MODULE, true)
		if not okMod or type(module) ~= "table" then return nil end
		if type(module.IsEnabled) == "function" then
			local okEnabled, enabled = pcall(module.IsEnabled, module)
			if not okEnabled or not enabled then return nil end
		end
	end

	-- Tier 5: the live setting, per-character override included.
	if type(glogger.GetUIState) ~= "function" then return nil end
	local okState, active = pcall(glogger.GetUIState, glogger, GLOGGER_STATE_KEY[feature])
	if okState and active == true then return GLOGGER_ADDON end
	return nil
end

-- True when FriendGroups should act on `feature` itself.
local function FG_ShouldHandle(feature)
	if not FG_FeatureEnabled(feature) then return false end
	if FG_ExternalOwner(feature) then return false end
	return true
end

-- Whichever addon owns the feature right now, for the diagnostic report.
local function FG_FeatureOwner(feature)
	local external = FG_ExternalOwner(feature)
	if external then return external end
	if FG_FeatureEnabled(feature) then return addonName end
	return nil
end

-- The other half of the contract: FriendGroups publishes what IT owns, so a
-- future companion addon can defer to us by reading one table instead of
-- introspecting our internals. Nothing reads this today.
_G.FriendGroups_Automation_Claim = {
	addon    = addonName,
	version  = FG_GetAddOnMetadata and FG_GetAddOnMetadata(addonName, "Version") or nil,
	priority = 50,
	-- res and release are stated as FALSE rather than dropped. A companion addon reading
	-- this table gets an explicit "FriendGroups will never handle this" instead of a nil
	-- it has to interpret, and the contract keeps the same shape it published before.
	features = { invite = true, sync = true, res = false, release = false },
	IsActive = function(feature)
		return FG_ShouldHandle(feature)
	end,
}

-- [[ BUSY RULE ]] No auto-accept in combat, PvP, active M+ or an encounter; checked on arrival.

local function FG_IsPlayerBusy()
	if InCombatLockdown() then return true end

	local inInstance, instanceType = IsInInstance()
	if inInstance then
		if instanceType == "pvp" or instanceType == "arena" then return true end
		-- Check the method, not just the namespace: Classic has C_ChallengeMode
		-- without IsChallengeModeActive.
		if instanceType == "party"
			and type(C_ChallengeMode) == "table"
			and type(C_ChallengeMode.IsChallengeModeActive) == "function"
			and C_ChallengeMode.IsChallengeModeActive() then
			return true
		end
		if C_InstanceEncounter.IsEncounterInProgress() then return true end
	end

	return false
end

-- Fails closed: an inviter we cannot identify (missing or secret GUID) is not trusted.
local function FG_IsTrustedInviter(guid)
	if type(guid) ~= "string" then return false end
	if type(issecretvalue) == "function" and issecretvalue(guid) then return false end
	if guid == "" then return false end

	if C_BattleNet and type(C_BattleNet.GetGameAccountInfoByGUID) == "function" then
		local ok, info = pcall(C_BattleNet.GetGameAccountInfoByGUID, guid)
		if ok and info then return true end
	end
	if C_FriendList and type(C_FriendList.IsFriend) == "function" then
		local ok, isFriend = pcall(C_FriendList.IsFriend, guid)
		if ok and isFriend then return true end
	end
	if type(IsGuildMember) == "function" then
		local ok, isMember = pcall(IsGuildMember, guid)
		if ok and isMember then return true end
	end
	return false
end

local function FG_InviterAllowed(guid)
	if not (FriendGroups_SavedVars and FriendGroups_SavedVars.auto_accept_friends_guild) then
		return true
	end
	return FG_IsTrustedInviter(guid)
end

-- [[ COUNTDOWN TOAST ]] Hover pauses the countdown; left alone it runs out and accepts.

local TOAST_WIDTH, TOAST_HEIGHT = 380, 148
local TOAST_DURATION = 5.0
local TOAST_BAR_INSET = 24
local TOAST_STACK_GAP = 12

-- Every toast this file builds, in creation order, for stack placement.
local FG_ToastRegistry = {}

local function FG_ApplyBackdrop(frame, bgR, bgG, bgB, bgA, borderAlpha)
	if type(frame.SetBackdrop) ~= "function" then return end
	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropColor(bgR, bgG, bgB, bgA)
	frame:SetBackdropBorderColor(FG_R, FG_G, FG_B, borderAlpha)
end

-- Inherits GameFontNormal, then overrides size; no path means the inherited font stands.
local function FG_ToastFontString(parent, size, flags)
	local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	if FG_FONT then
		fontString:SetFont(FG_FONT, size, flags)
	end
	return fontString
end

local function FG_ToastButton(parent, width, height, text)
	local button = CreateFrame("Button", nil, parent, FG_BACKDROP_TEMPLATE)
	button:SetSize(width, height)
	FG_ApplyBackdrop(button, 0.12, 0.12, 0.12, 1, 0.55)

	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetPoint("TOPLEFT", 4, -4)
	highlight:SetPoint("BOTTOMRIGHT", -4, 4)
	highlight:SetColorTexture(FG_R, FG_G, FG_B, 0.16)

	local label = FG_ToastFontString(button, 12, "")
	label:SetPoint("CENTER", 0, 0)
	label:SetTextColor(1, 1, 1)
	label:SetText(text)

	button:SetScript("OnMouseDown", function()
		label:ClearAllPoints()
		label:SetPoint("CENTER", 1, -1)
	end)
	button:SetScript("OnMouseUp", function()
		label:ClearAllPoints()
		label:SetPoint("CENTER", 0, 0)
	end)

	return button
end

-- Scale animations use SetScaleFrom/SetScaleTo on every supported flavor; the
-- capability is probed rather than assumed, and a client without it simply gets
-- the fade with no zoom.
local function FG_AddScale(group, fromScale, toScale, duration)
	local scale = group:CreateAnimation("Scale")
	if type(scale.SetScaleFrom) ~= "function" or type(scale.SetScaleTo) ~= "function" then
		return
	end
	scale:SetScaleFrom(fromScale, fromScale)
	scale:SetScaleTo(toScale, toScale)
	scale:SetDuration(duration)
	scale:SetSmoothing("OUT")
	scale:SetOrder(1)
	scale:SetOrigin("CENTER", 0, 0)
end

-- iconTexture is the subject icon; the FriendGroups logo is the brand mark in
-- the corner. onResolve(accepted, context) performs the actual game action.
local function FG_CreateToast(globalName, iconTexture, titleKey, onResolve)
	local toast = CreateFrame("Frame", globalName, UIParent, FG_BACKDROP_TEMPLATE)
	toast:SetSize(TOAST_WIDTH, TOAST_HEIGHT)
	toast:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	toast:SetFrameStrata("DIALOG")
	toast:SetToplevel(true)
	toast:SetClampedToScreen(true)
	toast:EnableMouse(true)
	toast:Hide()

	FG_ApplyBackdrop(toast, 0.05, 0.05, 0.05, 0.92, 1)

	local glow = toast:CreateTexture(nil, "BACKGROUND")
	glow:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	glow:SetBlendMode("ADD")
	glow:SetVertexColor(FG_R, FG_G, FG_B, 0.6)
	glow:SetSize(60, 60)

	local icon = toast:CreateTexture(nil, "ARTWORK")
	icon:SetSize(48, 48)
	icon:SetPoint("TOPLEFT", toast, "TOPLEFT", 14, -16)
	icon:SetTexture(iconTexture)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	glow:SetPoint("CENTER", icon, "CENTER", 0, 0)

	local title = FG_ToastFontString(toast, 15, "OUTLINE")
	title:SetTextColor(FG_R, FG_G, FG_B)
	title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -2)
	title:SetPoint("RIGHT", toast, "RIGHT", -16, 0)
	title:SetJustifyH("LEFT")
	title:SetText(L[titleKey])

	local body = FG_ToastFontString(toast, 12, "")
	body:SetTextColor(0.9, 0.9, 0.9)
	body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	body:SetPoint("RIGHT", toast, "RIGHT", -16, 0)
	body:SetJustifyH("LEFT")
	toast.Body = body

	-- Single owner of the pause state. Hovering swaps the live number for the
	-- paused notice; OnUpdate overwrites it with the number again on the first
	-- frame after the mouse leaves, so there is nothing to restore here.
	local function SetHovered(state)
		toast.isHovered = state
		if state and toast.timerActive and not toast.isClosing then
			toast.Countdown:SetText(L["TOAST_PAUSED"])
		end
	end

	-- Any mouse-enabled child steals OnLeave from the toast, which would resume
	-- the countdown while the player is reaching for a button. Every such child
	-- drives the same hover state so the pause survives the hand-off.
	local function TrackHover(frame)
		frame:HookScript("OnEnter", function() SetHovered(true) end)
		frame:HookScript("OnLeave", function() SetHovered(false) end)
	end

	local btnAccept = FG_ToastButton(toast, 110, 26, L["TOAST_ACCEPT"])
	btnAccept:SetPoint("BOTTOMLEFT", toast, "BOTTOMLEFT", 14, 18)
	btnAccept:SetScript("OnClick", function() toast:Resolve(true) end)
	TrackHover(btnAccept)

	local btnDecline = FG_ToastButton(toast, 110, 26, L["TOAST_DECLINE"])
	btnDecline:SetPoint("LEFT", btnAccept, "RIGHT", 8, 0)
	btnDecline:SetScript("OnClick", function() toast:Resolve(false) end)
	TrackHover(btnDecline)

	-- Anchored up from the buttons rather than down from the body, so the live
	-- number stays at a fixed height whether or not a long name or a verbose
	-- locale wraps the line above it onto two lines.
	local countdown = FG_ToastFontString(toast, 13, "OUTLINE")
	countdown:SetTextColor(FG_R, FG_G, FG_B)
	countdown:SetPoint("BOTTOMLEFT", btnAccept, "TOPLEFT", 0, 10)
	countdown:SetPoint("RIGHT", toast, "RIGHT", -16, 0)
	countdown:SetJustifyH("LEFT")
	toast.Countdown = countdown

	local fullWidth = TOAST_WIDTH - TOAST_BAR_INSET
	toast.CountdownFullWidth = fullWidth
	local bar = toast:CreateTexture(nil, "OVERLAY")
	bar:SetColorTexture(FG_R, FG_G, FG_B, 0.8)
	bar:SetHeight(3)
	bar:SetPoint("BOTTOMLEFT", toast, "BOTTOMLEFT", 12, 8)
	bar:SetWidth(fullWidth)
	toast.CountdownBar = bar

	-- The FriendGroups logo. Not mouse-enabled, so it cannot interfere with the
	-- hover pause.
	local brand = toast:CreateTexture(nil, "OVERLAY")
	brand:SetSize(20, 20)
	brand:SetPoint("BOTTOMRIGHT", toast, "BOTTOMRIGHT", -12, 16)
	brand:SetTexture(FG_LOGO)
	brand:SetAlpha(0.8)

	local pulse = glow:CreateAnimationGroup()
	pulse:SetLooping("REPEAT")
	local pOut = pulse:CreateAnimation("Alpha")
	pOut:SetFromAlpha(0.6) pOut:SetToAlpha(0.15) pOut:SetDuration(1.0) pOut:SetSmoothing("IN_OUT") pOut:SetOrder(1)
	local pIn = pulse:CreateAnimation("Alpha")
	pIn:SetFromAlpha(0.15) pIn:SetToAlpha(0.6) pIn:SetDuration(1.0) pIn:SetSmoothing("IN_OUT") pIn:SetOrder(2)
	toast.IconPulse = pulse

	toast.Entrance = toast:CreateAnimationGroup()
	local eFade = toast.Entrance:CreateAnimation("Alpha")
	eFade:SetFromAlpha(0) eFade:SetToAlpha(1) eFade:SetDuration(0.25) eFade:SetSmoothing("OUT") eFade:SetOrder(1)
	FG_AddScale(toast.Entrance, 1.12, 1.0, 0.25)

	toast.Exit = toast:CreateAnimationGroup()
	local xFade = toast.Exit:CreateAnimation("Alpha")
	xFade:SetFromAlpha(1) xFade:SetToAlpha(0) xFade:SetDuration(0.4) xFade:SetSmoothing("OUT") xFade:SetOrder(1)
	toast.Exit:SetScript("OnFinished", function()
		toast:Hide()
		toast.isClosing = false
		toast.timerActive = false
	end)

	toast:SetScript("OnEnter", function() SetHovered(true) end)
	toast:SetScript("OnLeave", function() SetHovered(false) end)

	toast:SetScript("OnUpdate", function(self, elapsed)
		if not self.timerActive or self.isHovered or self.isClosing then return end
		self.elapsed = (self.elapsed or 0) + (elapsed or 0)
		local duration = self.duration or TOAST_DURATION
		local remaining = duration - self.elapsed
		if remaining <= 0 then
			self.Countdown:SetText(string.format(L["TOAST_COUNTDOWN"], 0))
			self:Resolve(true)
			return
		end
		self.Countdown:SetText(string.format(L["TOAST_COUNTDOWN"], remaining))
		self.CountdownBar:SetWidth(math.max(1, self.CountdownFullWidth * (remaining / duration)))
	end)

	-- Slots are claimed, not counted (out-of-order closes collide). Companion toasts take the
	-- lowest slots, matching GLogger's own downward stacking.
	function toast:Reanchor()
		local occupied = {}
		FG_ReserveExternalSlots(occupied)
		for i = 1, #FG_ToastRegistry do
			local other = FG_ToastRegistry[i]
			if other ~= self and other:IsShown() and other.ToastSlot then
				occupied[other.ToastSlot] = true
			end
		end

		local slot = 0
		while occupied[slot] do
			slot = slot + 1
		end
		self.ToastSlot = slot

		self:ClearAllPoints()
		self:SetPoint("CENTER", UIParent, "CENTER", 0, -slot * (TOAST_HEIGHT + TOAST_STACK_GAP))
	end

	-- context = { name = <resolved player name or nil>, testMode = <bool> }
	function toast:Present(context)
		context = context or {}
		self.Entrance:Stop()
		self.Exit:Stop()

		self.Context = context

		if context.name then
			self.Body:SetText(string.format(L[self.BodyKey], context.name))
		else
			self.Body:SetText(L[self.BodyUnknownKey])
		end

		self.isClosing = false
		self.isHovered = false
		self.elapsed = 0
		self.duration = TOAST_DURATION
		self.timerActive = true
		self.Countdown:SetText(string.format(L["TOAST_COUNTDOWN"], TOAST_DURATION))
		self.CountdownBar:SetWidth(self.CountdownFullWidth)

		self:Reanchor()
		self:SetAlpha(1)
		self:Show()
		self.Entrance:Play()
		self.IconPulse:Play()
	end

	-- Closes the toast without touching the request. Used when it was already
	-- resolved elsewhere, so there is nothing left to accept or decline.
	function toast:Dismiss()
		if not self:IsShown() or self.isClosing then return end
		self.isClosing = true
		self.timerActive = false
		self.Context = nil
		self.Entrance:Stop()
		self.IconPulse:Stop()
		self:SetAlpha(1)
		self.Exit:Play()
	end

	function toast:Resolve(accepted)
		if not self:IsShown() or self.isClosing then return end
		self.timerActive = false

		local context = self.Context or {}
		self.Context = nil

		-- Test mode drives the whole widget end to end without performing the
		-- game action, so it stays safe to run with a genuine request pending.
		if not context.testMode then
			onResolve(accepted, context)
		end

		self:Dismiss()
	end

	FG_ToastRegistry[#FG_ToastRegistry + 1] = toast
	return toast
end

-- ============================================================================
-- [[ GAME ACTIONS ]]
-- ============================================================================

-- AcceptGroup() from code leaves PARTY_INVITE up (only its button hides it), so hide it.
-- Its OnHide fires a harmless second DeclineGroup. MUST run after the accept/decline, or
-- the OnHide decline kills the invite first.
local function FG_HideBlizzardPopup(which)
	if type(StaticPopup_Hide) ~= "function" then return end
	pcall(StaticPopup_Hide, which)
end

-- On failure the dialog stays up: it is the player's only way to answer by hand.
local function FG_AcceptInvite(inviter)
	FG_Announce(string.format(L["MSG_AUTO_INVITE"], inviter or L["UNKNOWN"]))
	if type(AcceptGroup) ~= "function" then return end
	if pcall(AcceptGroup) then
		FG_HideBlizzardPopup("PARTY_INVITE")
	else
		FG_Announce(L["MSG_AUTO_ACCEPT_FAILED"])
	end
end

local function FG_DeclineInvite(inviter)
	FG_Announce(string.format(L["MSG_AUTO_INVITE_DECLINED"], inviter or L["UNKNOWN"]))
	if type(DeclineGroup) ~= "function" then return end
	if pcall(DeclineGroup) then
		FG_HideBlizzardPopup("PARTY_INVITE")
	end
end

local function FG_SendSyncResponse(accepted)
	if not C_QuestSession or type(C_QuestSession.SendSessionBeginResponse) ~= "function" then
		return false
	end
	return pcall(C_QuestSession.SendSessionBeginResponse, accepted)
end

local function FG_AcceptSync(leader)
	FG_Announce(string.format(L["MSG_AUTO_SYNC"], leader or L["UNKNOWN"]))
	if not FG_SendSyncResponse(true) then
		FG_Announce(L["MSG_AUTO_ACCEPT_FAILED"])
	end
end

local function FG_DeclineSync(leader)
	FG_Announce(string.format(L["MSG_AUTO_SYNC_DECLINED"], leader or L["UNKNOWN"]))
	FG_SendSyncResponse(false)
end

-- Party Sync is a party-only feature, so only the four party slots are scanned.
-- Returns nil when the leader cannot be named, which selects the anonymous body.
local function FG_PartyLeaderName()
	if not IsInGroup() then return nil end
	for i = 1, 4 do
		local unit = "party" .. i
		if UnitExists(unit) and UnitIsGroupLeader(unit) then
			return FG_PlainName(UnitName(unit))
		end
	end
	return nil
end

-- ============================================================================
-- [[ TOAST INSTANCES ]]
-- ============================================================================

local InviteToast = FG_CreateToast("FriendGroupsInviteToast", FG_ICON_INVITE, "TOAST_INVITE_TITLE",
	function(accepted, context)
		if accepted then
			FG_AcceptInvite(context.name)
		else
			FG_DeclineInvite(context.name)
		end
	end)
InviteToast.BodyKey = "TOAST_INVITE_BODY"
InviteToast.BodyUnknownKey = "TOAST_INVITE_BODY_UNKNOWN"

local SyncToast = FG_CreateToast("FriendGroupsSyncToast", FG_ICON_SYNC, "TOAST_SYNC_TITLE",
	function(accepted, context)
		if accepted then
			FG_AcceptSync(context.name)
		else
			FG_DeclineSync(context.name)
		end
	end)
SyncToast.BodyKey = "TOAST_SYNC_BODY"
SyncToast.BodyUnknownKey = "TOAST_SYNC_BODY_UNKNOWN"

-- [[ EVENT ROUTING ]] Compat.RegisterEvents skips events the client lacks (QUEST_SESSION_*).

local FriendGroups_Automation = CreateFrame("Frame")
Compat.RegisterEvents(FriendGroups_Automation, {
	"PARTY_INVITE_REQUEST",
	"PARTY_INVITE_CANCEL",
	"GROUP_JOINED",
	"QUEST_SESSION_CREATED",
	"QUEST_SESSION_JOINED",
	"QUEST_SESSION_DESTROYED",
})

FriendGroups_Automation:SetScript("OnEvent", function(self, event, ...)
	-- 1. Auto Accept Group Invites
	if event == "PARTY_INVITE_REQUEST" then
		if not FG_ShouldHandle("invite") then return end
		if FG_IsPlayerBusy() then return end

		local inviter = FG_PlainName((...))
		-- Arg 7 is inviterGUID. A refused inviter gets no decline: Blizzard's popup stays up.
		if not FG_InviterAllowed((select(7, ...))) then
			FG_Announce(string.format(L["MSG_AUTO_INVITE_NOT_TRUSTED"], inviter or L["UNKNOWN"]))
			return
		end

		if FG_ExternalToastVisible() then return end
		InviteToast:Present({ name = inviter })

	-- Both close the countdown if the invite is resolved somewhere other than on
	-- the toast: PARTY_INVITE_CANCEL covers a withdrawn or expired invite and a
	-- decline through Blizzard's popup, GROUP_JOINED covers an accept through it.
	elseif event == "PARTY_INVITE_CANCEL" or event == "GROUP_JOINED" then
		InviteToast:Dismiss()

	-- 2. Auto Accept Party Sync
	elseif event == "QUEST_SESSION_CREATED" then
		if not FG_ShouldHandle("sync") then return end
		if UnitIsGroupLeader("player") then return end
		if InCombatLockdown() then return end

		-- Last-ditch guard: a companion toast up means arbitration was defeated by a rename.
		if FG_ExternalToastVisible() then return end
		SyncToast:Present({ name = FG_PartyLeaderName() })

	-- The session resolved without us: either it started (we are in it) or it
	-- was torn down. Either way the countdown has nothing left to answer.
	elseif event == "QUEST_SESSION_JOINED" or event == "QUEST_SESSION_DESTROYED" then
		SyncToast:Dismiss()
	end
end)

-- [[ DIAGNOSTICS ]] For the /fg slash handler.

-- Prints which addon owns each automation, so "why did nothing pop up" is one
-- command rather than a support thread.
function FriendGroups_ReportAutomation()
	FG_Announce(L["DEBUG_AUTOMATION_HEADER"])
	for i = 1, #FG_FEATURE_ORDER do
		local feature = FG_FEATURE_ORDER[i]
		local owner = FG_FeatureOwner(feature)
		FG_Announce(string.format(
			L["DEBUG_AUTOMATION_LINE"],
			L[FG_FEATURE_LABEL[feature]],
			owner or L["DEBUG_AUTOMATION_OFF"]
		))
	end
end

-- Drives both toasts end to end against the player's own name. Test mode makes
-- Resolve skip the game action, so this is safe to run with a real invite
-- pending: nothing is accepted or declined on the player's behalf.
function FriendGroups_TestAutomationToast()
	local name = FG_PlainName(UnitName("player"))
	InviteToast:Present({ name = name, testMode = true })
	SyncToast:Present({ name = name, testMode = true })
end
