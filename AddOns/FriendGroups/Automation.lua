--[[
	FriendGroups - Automation.lua
	============================================================================
	Every "accept this for me" behaviour, plus the countdown toast that fronts
	the two interactive ones (group invite, Party Sync).

	Design rules:
	  - Blizzard's own dialog stays on screen alongside the toast for the whole
	    countdown, and is dismissed once the request is resolved -- see
	    FG_HideBlizzardPopup for why that dismissal has to be explicit.
	  - AcceptGroup / DeclineGroup / SendSessionBeginResponse are not protected,
	    so the toast and its timer are safe to run at any time. What gates the
	    toast is FriendGroups' own busy rule (FG_IsPlayerBusy), unchanged from
	    the pre-toast behaviour.
	  - Nothing here assumes an API exists. Every global and namespace member is
	    type-checked before use, and events are registered through
	    Compat.RegisterEvents so a flavor that lacks one simply skips it.

	API compliance:
	  - Retail   : WoW Midnight 12.0.7 (Interface 120007)
	  - Classic  : MoP Classic 5.5.4, BC Anniversary 2.5.6, Classic Era 1.15.x
	    On the Classic flavors C_QuestSession does not exist, so the Party Sync
	    toast is never built there; the invite toast is flavor-neutral.
]] --

local addonName, addonTable = ...
local L = addonTable.L
local Compat = addonTable.Compat

-- ============================================================================
-- [[ BRAND ]]
-- ============================================================================

-- FriendGroups mint, #33FF99. This is the literal colour every FriendGroups
-- chat line already carries (260+ occurrences across the locale files), and is
-- deliberately NOT RAID_CLASS_COLORS.MONK (#00FF96): the toast has to match the
-- addon's own prefix, which must not drift if Blizzard ever retunes a class
-- colour.
local FG_R, FG_G, FG_B = 0.20, 1.00, 0.60

-- The addon's own logo, the same file the TOC declares as its IconTexture.
local FG_LOGO = "Interface\\AddOns\\FriendGroups\\Textures\\fg"

-- Toast subject icons, by path rather than fileID so they resolve identically on
-- retail and Classic. The invite icon (fileID 134149) is a base-game icon present
-- on every supported flavor; the Party Sync icon (fileID 442272) is Cataclysm-era,
-- which is no constraint since Party Sync itself is retail-only.
local FG_ICON_INVITE = "Interface\\Icons\\INV_Misc_GroupNeedMore"
local FG_ICON_SYNC   = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend"

-- BackdropTemplate ships on every flavor this addon supports, but the template
-- is only resolvable by name where BackdropTemplateMixin exists. Where it does
-- not, the frame keeps the pre-9.0 native SetBackdrop, which is what the
-- type-checked helpers below call. No version number is consulted.
local FG_BACKDROP_TEMPLATE = (type(BackdropTemplateMixin) == "table") and "BackdropTemplate" or nil

-- Font path taken from the client's own GameFontNormal, so it is locale-correct
-- by construction: the koKR/zhCN/zhTW clients do not ship FRIZQT__.TTF, and a
-- hardcoded Western font path would render their text blank. STANDARD_TEXT_FONT
-- is the documented locale-aware fallback. May still end up nil, which
-- FG_ToastFontString handles.
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

-- ============================================================================
-- [[ FEATURE REGISTRY ]]
-- The four automations that a companion addon might also implement. Everything
-- downstream -- arbitration, the published claim, the diagnostic -- keys off
-- this one table so a fifth feature is a single entry, not a sweep.
-- ============================================================================

local FG_FEATURE_SAVEDVAR = {
	invite  = "auto_accept_invite",
	sync    = "auto_accept_sync",
	res     = "auto_accept_res",
	release = "auto_release",
}

-- Display order for the /fg automation report, and the localized label each
-- feature reports under (reusing the settings-menu labels the user already sees).
local FG_FEATURE_ORDER = { "invite", "sync", "res", "release" }
local FG_FEATURE_LABEL = {
	invite  = "SET_AUTO_ACCEPT",
	sync    = "SET_AUTO_PARTY_SYNC",
	res     = "SET_SPIRIT_RES",
	release = "SET_SPIRIT_RELEASE",
}

local function FG_FeatureEnabled(feature)
	local key = FG_FEATURE_SAVEDVAR[feature]
	if not key then return false end
	return FriendGroups_SavedVars ~= nil and FriendGroups_SavedVars[key] == true
end

-- ============================================================================
-- [[ CROSS-ADDON ARBITRATION ]]
-- GLogger implements the same four automations. Run side by side both would
-- answer the same invite, so exactly one has to own each feature.
--
-- FriendGroups is always the one that yields: it can read GLogger's state but
-- cannot change it, so a fixed precedence (GLogger wins) is the only scheme
-- that can be enforced from this side alone. Deliberately not user-toggleable --
-- an override could not silence GLogger, only add a second prompt on top of it.
--
-- Resolution ladder, most authoritative first:
--   1. A published claim table (the forward contract -- see the claim this file
--      publishes below). If a companion addon publishes one it is believed
--      outright, including when it says a feature is OFF.
--   2..4. Introspection: addon loaded -> AceAddon object -> module enabled.
--   5. GLogger's own GetUIState, which merges its per-character override over
--      its global setting -- the same value its handlers read.
-- Evaluated per event rather than cached, so toggling either addon's setting
-- mid-session takes effect on the very next invite. Every step is type-checked
-- and pcall-wrapped: a GLogger that has not finished initialising, or one that
-- has renamed something, reads as "not active" and FriendGroups takes the
-- invite rather than erroring.
-- ============================================================================

local GLOGGER_ADDON  = "GLogger"
local GLOGGER_MODULE = "AutoInvite"
local GLOGGER_STATE_KEY = {
	invite  = "UIAutoAcceptInvites",
	sync    = "UIAutoAcceptSync",
	res     = "UIAutoAcceptRes",
	release = "UIAutoRelease",
}

-- Named frames belonging to a companion addon's own countdown toast. Checked
-- immediately before ours is shown, as a last-ditch guarantee that two toasts
-- can never stack even if every tier of the ladder above has been defeated by a
-- rename. A frame name is the one thing that does not quietly change.
--
-- One entry per companion toast, not per companion addon: GLogger fronts group
-- invites and Party Sync with two separately named frames, and listing only the
-- invite one would leave the Party Sync toasts free to overlap.
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

-- Marks the stack slots companion toasts are occupying, so ours is never placed
-- on top of one.
--
-- GLogger tags each of its toasts with the slot it currently holds, so reading
-- that field is exact. Merely COUNTING the visible ones is not: with GLogger
-- showing its invite toast in slot 0 and its Party Sync toast in slot 1, closing
-- the invite one leaves a count of 1, which would reserve slot 0 and send ours to
-- slot 1 -- straight onto the Party Sync toast still on screen.
--
-- A companion toast that exposes no slot falls back to reserving the next free
-- one, which is the old counting behaviour and still correct for a single toast.
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
	features = { invite = true, sync = true, res = true, release = true },
	IsActive = function(feature)
		return FG_ShouldHandle(feature)
	end,
}

-- ============================================================================
-- [[ BUSY RULE ]]
-- Unchanged from the pre-toast behaviour: FriendGroups does not auto-accept a
-- group invite while the player is in combat, in a rated/instanced PvP match,
-- inside an active Mythic+ run, or mid-encounter. Evaluated once, when the
-- invite arrives -- a toast already on screen has a visible countdown, a hover
-- pause and a Decline button, so it is not the unattended accept this guards.
-- ============================================================================

local function FG_IsPlayerBusy()
	if InCombatLockdown() then return true end

	local inInstance, instanceType = IsInInstance()
	if inInstance then
		if instanceType == "pvp" or instanceType == "arena" then return true end
		-- Carried over from the pre-toast code, but with the METHOD checked and not
		-- just the namespace: C_ChallengeMode.IsChallengeModeActive is a modern
		-- addition, so a client exposing the namespace without this member would
		-- have errored here and taken auto-accept down with it.
		if instanceType == "party"
			and type(C_ChallengeMode) == "table"
			and type(C_ChallengeMode.IsChallengeModeActive) == "function"
			and C_ChallengeMode.IsChallengeModeActive() then
			return true
		end
		if IsEncounterInProgress() then return true end
	end

	return false
end

-- ============================================================================
-- [[ COUNTDOWN TOAST ]]
-- One widget, two instances (group invite, Party Sync), so both read as the
-- same control. Hovering pauses the countdown, which makes the timer an
-- attention window rather than a deadline: left alone it runs out and accepts.
-- ============================================================================

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

-- Inherits GameFontNormal so the region always carries a valid, locale-correct
-- font, then overrides only size and outline. If no font path resolved at all the
-- override is skipped and the inherited font stands: worst case the text is the
-- default size, never blank.
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

	-- Stack downward from centre when something else is already up, so a second
	-- toast (or a companion addon's) is never hidden behind the first.
	--
	-- Slots are CLAIMED, not counted. Counting the shown toasts collides whenever
	-- they close out of order: with two up in slots 0 and 1, closing the one in
	-- slot 0 leaves a count of 1, and the next toast would be sent to slot 1 --
	-- directly onto the one still showing.
	--
	-- Companion toasts take the lowest slots. They are positioned by their own
	-- addon and cannot be moved from here, and GLogger stacks its own downward
	-- from centre in exactly this order, so reserving the bottom of the range for
	-- them is what keeps the two addons interleaved rather than overlapping.
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

-- Dismiss one of Blizzard's own request dialogs after we have answered it.
--
-- This deliberately re-introduces a call the 12.2.2 taint pass removed. That pass
-- recorded the premise "Blizzard's own secure handlers dismiss the invite popups
-- once the invite resolves", and that premise is FALSE for a programmatic accept:
-- the PARTY_INVITE dialog is dismissed by its own Accept BUTTON being clicked
-- (StaticPopup hides a dialog whose button was pressed), not by any event. No
-- PARTY_INVITE_CANCEL fires for the player's own accept, so calling AcceptGroup()
-- from addon code leaves the dialog stranded on screen over a group already
-- joined. Explicitly hiding it is the only way to clear it.
--
-- PARTY_INVITE's OnHide fires DeclineGroup() unless Blizzard's own Accept button
-- set dialog.inviteAccepted, so hiding it here fires a second DeclineGroup(). That
-- is harmless in both directions: after AcceptGroup() the invite has already been
-- consumed server-side, and after DeclineGroup() it is a repeat of what just
-- happened. Setting inviteAccepted to suppress it would mean WRITING to a pooled
-- Blizzard frame, which is strictly more taint than calling the function, so it is
-- not done.
--
-- ORDER IS LOAD-BEARING: this must run AFTER the accept/decline. Hiding first
-- would fire the OnHide DeclineGroup() and kill the invite before we answered it.
local function FG_HideBlizzardPopup(which)
	if type(StaticPopup_Hide) ~= "function" then return end
	pcall(StaticPopup_Hide, which)
end

-- On failure the dialog is deliberately LEFT UP: it is the player's only way to
-- answer the invite by hand, and MSG_AUTO_ACCEPT_FAILED tells them to do exactly
-- that. Hiding it would take the button away and make the advice impossible to
-- follow. Same reasoning on every path below.
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

-- ============================================================================
-- [[ EVENT ROUTING ]]
-- QUEST_SESSION_* is retail-era and absent on the Classic flavors;
-- Compat.RegisterEvents validates every name against the running client and
-- registers exactly the supported subset.
-- ============================================================================

local FriendGroups_Automation = CreateFrame("Frame")
Compat.RegisterEvents(FriendGroups_Automation, {
	"PARTY_INVITE_REQUEST",
	"PARTY_INVITE_CANCEL",
	"GROUP_JOINED",
	"RESURRECT_REQUEST",
	"PLAYER_DEAD",
	"QUEST_SESSION_CREATED",
	"QUEST_SESSION_JOINED",
	"QUEST_SESSION_DESTROYED",
})

FriendGroups_Automation:SetScript("OnEvent", function(self, event, ...)
	-- 1. Auto Accept Group Invites
	if event == "PARTY_INVITE_REQUEST" then
		if not FG_ShouldHandle("invite") then return end
		if FG_IsPlayerBusy() then return end

		if FG_ExternalToastVisible() then return end
		InviteToast:Present({ name = FG_PlainName(...) })

	-- Both close the countdown if the invite is resolved somewhere other than on
	-- the toast: PARTY_INVITE_CANCEL covers a withdrawn or expired invite and a
	-- decline through Blizzard's popup, GROUP_JOINED covers an accept through it.
	elseif event == "PARTY_INVITE_CANCEL" or event == "GROUP_JOINED" then
		InviteToast:Dismiss()

	-- 2. Auto Accept Resurrection
	elseif event == "RESURRECT_REQUEST" then
		if not FG_ShouldHandle("res") then return end

		local rezzer = FG_PlainName(...)
		FG_Announce(string.format(L["MSG_AUTO_RES"], rezzer or L["UNKNOWN"]))

		-- Not wrapped in a timer, to preserve the secure hardware event payload.
		-- The resurrect dialog is dismissed by its own button in exactly the same
		-- way PARTY_INVITE is, so a programmatic accept strands it too.
		if type(AcceptResurrect) == "function" then
			if pcall(AcceptResurrect) then
				FG_HideBlizzardPopup("RESURRECT")
			else
				FG_Announce(L["MSG_AUTO_ACCEPT_FAILED"])
			end
		end

	-- 3. Auto Release Spirit
	elseif event == "PLAYER_DEAD" then
		if not FG_ShouldHandle("release") then return end

		FG_Announce(L["MSG_AUTO_RELEASE"])

		-- Guarded: confirmed present on retail/MoP/BC Anniversary, but a client
		-- without it must not error on every death with auto-release enabled.
		local selfResOptions = C_DeathInfo and type(C_DeathInfo.GetSelfResurrectOptions) == "function"
			and C_DeathInfo.GetSelfResurrectOptions()
		if not selfResOptions or #selfResOptions == 0 then
			if type(RepopMe) == "function" and not pcall(RepopMe) then
				FG_Announce(L["MSG_AUTO_RELEASE_FAILED"])
			end
		end

	-- 4. Auto Accept Party Sync
	elseif event == "QUEST_SESSION_CREATED" then
		if not FG_ShouldHandle("sync") then return end
		if UnitIsGroupLeader("player") then return end
		if InCombatLockdown() then return end

		-- Same last-ditch guard the invite path carries. Arbitration should already
		-- have stood us down if GLogger owns Party Sync, so reaching this with a
		-- companion toast up means the ladder was defeated by a rename; one missed
		-- auto-accept is a better failure than two countdowns for one session.
		if FG_ExternalToastVisible() then return end
		SyncToast:Present({ name = FG_PartyLeaderName() })

	-- The session resolved without us: either it started (we are in it) or it
	-- was torn down. Either way the countdown has nothing left to answer.
	elseif event == "QUEST_SESSION_JOINED" or event == "QUEST_SESSION_DESTROYED" then
		SyncToast:Dismiss()
	end
end)

-- ============================================================================
-- [[ DIAGNOSTICS ]]
-- Exposed for the /fg slash handler in FriendGroups.lua.
-- ============================================================================

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
