----------------------------------------------------------------------
-- 	Leatrix Plus 12.1.15 (28th October 2026)
----------------------------------------------------------------------

--	01:Functions 02:Locks,  03:Restart 40:Player
--	60:Events    62:Profile 70:Logout  80:Commands, 90:Panel

----------------------------------------------------------------------
-- 	Leatrix Plus
----------------------------------------------------------------------

	-- LeaPlusLC.NewPatch - TEMPORARY
	-- Disable taint logging for now because having it enabled causes fake errors to show up
	-- that will lead users to report and investigate problems that don't exist and are only
	-- caused by having taint logging enabled.  This will be removed as soon as it's safe.
	-- Hide event toasts (Frames) and Hide talking frame (Frames) have been updated to work
	-- around this but I don't want to change a lot of other code when this taint bug will
	-- likely be fixed anyway so better to just make sure it's off for now.
	SetCVar("taintLog", "0")

	-- Create global table
	_G.LeaPlusDB = _G.LeaPlusDB or {}

	-- Create locals
	local LeaPlusLC, LeaPlusCB, LeaConfigList, LeaLockList = {}, {}, {}, {}
	local GameLocale = GetLocale()
	local void

	-- Version
	LeaPlusLC["AddonVer"] = "12.1.15"

	-- Get locale table
	local void, Leatrix_Plus = ...
	local L = Leatrix_Plus.L

	-- Check Wow version is valid
	do
		local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
		if gametocversion and gametocversion < 120000 then
			-- Game client is not Midnight
			C_Timer.After(2, function()
				print(L["LEATRIX PLUS: WRONG VERSION INSTALLED!"])
			end)
			return
		end
		if gametocversion and gametocversion >= 120107 then -- 12.1.7
			LeaPlusLC.NewPatch = true
		end
	end

	-- Check for ElvUI
	if C_AddOns.IsAddOnLoaded("ElvUI") then LeaPlusLC.ElvUI = unpack(ElvUI) end

----------------------------------------------------------------------
--	L00: Leatrix Plus
----------------------------------------------------------------------

	-- Initialise variables
	LeaPlusLC["ShowErrorsFlag"] = 1
	LeaPlusLC["NumberOfPages"] = 9
	LeaPlusLC["MainPanelHeight"] = 370
	LeaPlusLC["RaidColors"] = RAID_CLASS_COLORS

	-- Create event frame
	local LpEvt = CreateFrame("FRAME")
	LpEvt:RegisterEvent("ADDON_LOADED")
	LpEvt:RegisterEvent("PLAYER_LOGIN")

	-- Set bindings translations
	_G.BINDING_NAME_LEATRIX_PLUS_GLOBAL_TOGGLE = L["Toggle panel"]
	_G.BINDING_NAME_LEATRIX_PLUS_GLOBAL_RARE = L["Announce rare"]
	_G.BINDING_NAME_LEATRIX_PLUS_GLOBAL_MOUNTSPECIAL = L["Mount special"]

----------------------------------------------------------------------
--	L01: Functions
----------------------------------------------------------------------

	-- Create a random global name that changes every time the addon loads
	function LeaPlusLC:CreateRandomName()
		local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		local name
		repeat
			local parts = {"F"} -- Start with a letter
			for i = 1, 16 do
				local n = math.random(#chars)
				parts[#parts + 1] = chars:sub(n, n)
			end
			name = table.concat(parts)
		until not _G[name] -- Make sure the name is not already in use
		return name
	end

	-- Print text
	function LeaPlusLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
	end

	-- Lock and unlock an item
	function LeaPlusLC:LockItem(item, lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

	-- Hide configuration panels
	function LeaPlusLC:HideConfigPanels()
		for k, v in pairs(LeaConfigList) do
			v:Hide()
		end
	end

	-- Create a close button without using a template
	function LeaPlusLC:CreateCloseButton(parent, w, h, anchor, x, y)
		local btn = CreateFrame("BUTTON", nil, parent)
		btn:SetSize(w, h)
		btn:SetPoint(anchor, x, y)
		btn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
		btn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
		btn:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
		return btn
	end

	-- Decline a shared quest if needed
	function LeaPlusLC:CheckIfQuestIsSharedAndShouldBeDeclined()
		if LeaPlusLC["NoSharedQuests"] == "On" then
			local npcName = UnitName("questnpc")
			if not canaccessvalue(npcName) then return end
			if npcName and UnitIsPlayer(npcName) then
				if UnitInParty(npcName) or UnitInRaid(npcName) then
					if not LeaPlusLC:FriendCheck(npcName) then
						DeclineQuest()
						return
					end
				end
			end
		end
	end

	-- Display on-screen message
	function LeaPlusLC:DisplayMessage(self)
		ActionStatus:DisplayMessage(self)
	end

	-- Show a single line prefilled editbox with copy functionality
	function LeaPlusLC:ShowSystemEditBox(word, focuschat)
		if not LeaPlusLC.FactoryEditBox then
			-- Create frame for first time
			local eFrame = CreateFrame("FRAME", nil, UIParent)
			LeaPlusLC.FactoryEditBox = eFrame
			eFrame:SetSize(700, 110)
			eFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
			eFrame:SetFrameStrata("FULLSCREEN_DIALOG")
			eFrame:SetFrameLevel(5000)
			eFrame:SetScript("OnMouseDown", function(self, btn)
				if btn == "RightButton" then
					eFrame:Hide()
				end
			end)
			-- Add background color
			eFrame.t = eFrame:CreateTexture(nil, "BACKGROUND")
			eFrame.t:SetAllPoints()
			eFrame.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)
			-- Add copy title
			eFrame.f = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
			eFrame.f:SetPoint("TOPLEFT", x, y)
			eFrame.f:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 12, -52)
			eFrame.f:SetWidth(676)
			eFrame.f:SetJustifyH("LEFT")
			eFrame.f:SetWordWrap(false)
			-- Add copy label
			eFrame.c = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
			eFrame.c:SetPoint("TOPLEFT", x, y)
			eFrame.c:SetText(L["Press CTRL/C to copy"])
			eFrame.c:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 12, -82)
			-- Add cancel label
			eFrame.x = eFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
			eFrame.x:SetPoint("TOPRIGHT", x, y)
			eFrame.x:SetText(L["Right-click to close"])
			eFrame.x:SetPoint("TOPRIGHT", eFrame, "TOPRIGHT", -12, -82)
			-- Create editbox
			eFrame.b = CreateFrame("EditBox", nil, eFrame, "InputBoxTemplate")
			eFrame.b:ClearAllPoints()
			eFrame.b:SetPoint("TOPLEFT", eFrame, "TOPLEFT", 16, -12)
			eFrame.b:SetSize(672, 24)
			eFrame.b:SetFontObject("GameFontNormalLarge")
			eFrame.b:SetTextColor(1.0, 1.0, 1.0, 1)
			eFrame.b:SetBlinkSpeed(0)
			eFrame.b:SetHitRectInsets(99, 99, 99, 99)
			eFrame.b:SetAutoFocus(true)
			eFrame.b:SetAltArrowKeyMode(true)
			-- Editbox texture
			eFrame.t = CreateFrame("FRAME", nil, eFrame.b, "BackdropTemplate")
			eFrame.t:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }})
			eFrame.t:SetPoint("LEFT", -6, 0)
			eFrame.t:SetWidth(eFrame.b:GetWidth() + 6)
			eFrame.t:SetHeight(eFrame.b:GetHeight())
			eFrame.t:SetBackdropColor(1.0, 1.0, 1.0, 0.3)
			-- Handler
			eFrame.b:SetScript("OnKeyDown", function(void, key)
				if key == "C" and (IsControlKeyDown() or IsMetaKeyDown()) then
					C_Timer.After(0.1, function()
						eFrame:Hide()
						LeaPlusLC:DisplayMessage(L["Copied to clipboard."], true)
						if LeaPlusLC.FactoryEditBoxFocusChat then
							local eBox = ChatFrameUtil.ChooseBoxForSend()
							ChatFrameUtil.ActivateChat(eBox)
						end
					end)
				end
			end)
			-- Prevent changes
			eFrame.b:SetScript("OnEscapePressed", function() eFrame:Hide() end)
			eFrame.b:SetScript("OnEnterPressed", eFrame.b.HighlightText)
			eFrame.b:SetScript("OnMouseDown", eFrame.b.ClearFocus)
			eFrame.b:SetScript("OnMouseUp", eFrame.b.HighlightText)
			eFrame.b:SetFocus(true)
			eFrame.b:HighlightText()
			eFrame:Show()
		end
		if focuschat then LeaPlusLC.FactoryEditBoxFocusChat = true else LeaPlusLC.FactoryEditBoxFocusChat = nil end
		LeaPlusLC.FactoryEditBox:Show()
		LeaPlusLC.FactoryEditBox.b:SetText(word)
		LeaPlusLC.FactoryEditBox.b:HighlightText()
		LeaPlusLC.FactoryEditBox.b:SetScript("OnChar", function() LeaPlusLC.FactoryEditBox.b:SetFocus(true) LeaPlusLC.FactoryEditBox.b:SetText(word) LeaPlusLC.FactoryEditBox.b:HighlightText() end)
		LeaPlusLC.FactoryEditBox.b:SetScript("OnKeyUp", function() LeaPlusLC.FactoryEditBox.b:SetFocus(true) LeaPlusLC.FactoryEditBox.b:SetText(word) LeaPlusLC.FactoryEditBox.b:HighlightText() end)
	end

	-- Load a string variable or set it to default if it's not set to "On" or "Off"
	function LeaPlusLC:LoadVarChk(var, def)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" and LeaPlusDB[var] == "On" or LeaPlusDB[var] == "Off" then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Load a numeric variable and set it to default if it's not within a given range
	function LeaPlusLC:LoadVarNum(var, def, valmin, valmax)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "number" and LeaPlusDB[var] >= valmin and LeaPlusDB[var] <= valmax then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Load an anchor point variable and set it to default if the anchor point is invalid
	function LeaPlusLC:LoadVarAnc(var, def)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" and LeaPlusDB[var] == "CENTER" or LeaPlusDB[var] == "TOP" or LeaPlusDB[var] == "BOTTOM" or LeaPlusDB[var] == "LEFT" or LeaPlusDB[var] == "RIGHT" or LeaPlusDB[var] == "TOPLEFT" or LeaPlusDB[var] == "TOPRIGHT" or LeaPlusDB[var] == "BOTTOMLEFT" or LeaPlusDB[var] == "BOTTOMRIGHT" then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Load a string variable and set it to default if it is not a string (used with minimap exclude list)
	function LeaPlusLC:LoadVarStr(var, def)
		if LeaPlusDB[var] and type(LeaPlusDB[var]) == "string" then
			LeaPlusLC[var] = LeaPlusDB[var]
		else
			LeaPlusLC[var] = def
			LeaPlusDB[var] = def
		end
	end

	-- Show tooltips for checkboxes
	function LeaPlusLC:TipSee()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = self:GetParent()
		if parent:GetParent() and parent:GetParent():GetObjectType() == "ScrollFrame" then
			-- Scrolling frame tooltips have different parent
			parent = self:GetParent():GetParent():GetParent():GetParent()
		end
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (parent:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Show tooltips for dropdown menu tooltips
	function LeaPlusLC:ShowDropTip()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = self:GetParent():GetParent():GetParent()
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (parent:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Show tooltips for configuration buttons and dropdown menus
	function LeaPlusLC:ShowTooltip()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = LeaPlusLC["PageF"]
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (LeaPlusLC["PageF"]:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Show tooltips for interface settings (not currently used)
	function LeaPlusLC:ShowFacetip()
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Create configuration button
	function LeaPlusLC:CfgBtn(name, parent)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaPlusCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50);
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50);

		CfgBtn.tiptext = L["Click to configure the settings for this option."]
		CfgBtn:SetScript("OnEnter", LeaPlusLC.ShowTooltip)
		CfgBtn:SetScript("OnLeave", GameTooltip_Hide)
	end

	-- Create a help button to the right of a fontstring
	function LeaPlusLC:CreateHelpButton(frame, panel, parent, tip)
		LeaPlusLC:CfgBtn(frame, panel)
		LeaPlusCB[frame]:ClearAllPoints()
		LeaPlusCB[frame]:SetPoint("LEFT", parent, "RIGHT", -parent:GetWidth() + parent:GetStringWidth(), 0)
		LeaPlusCB[frame]:SetSize(25, 25)
		LeaPlusCB[frame].t:SetTexture("Interface\\COMMON\\help-i.blp")
		LeaPlusCB[frame].t:SetTexCoord(0, 1, 0, 1)
		LeaPlusCB[frame].t:SetVertexColor(0.9, 0.8, 0.0)
		LeaPlusCB[frame]:SetHighlightTexture("Interface\\COMMON\\help-i.blp")
		LeaPlusCB[frame]:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
		LeaPlusCB[frame].tiptext = L[tip]
		LeaPlusCB[frame]:SetScript("OnEnter", LeaPlusLC.TipSee)
	end

	-- Show a footer
	function LeaPlusLC:MakeFT(frame, text, left, width, bottom)
		local footer = LeaPlusLC:MakeTx(frame, text, left, bottom)
		footer:SetWidth(width); footer:SetJustifyH("LEFT"); footer:SetWordWrap(true); footer:ClearAllPoints()
		footer:SetPoint("BOTTOMLEFT", left, bottom)
		return footer
	end

	-- Capitalise first character in a string
	function LeaPlusLC:CapFirst(str)
		return gsub(string.lower(str), "^%l", strupper)
	end

	-- Toggle Zygor addon
	function LeaPlusLC:ZygorToggle()
		if select(2, C_AddOns.GetAddOnInfo("ZygorGuidesViewer")) then
			if not C_AddOns.IsAddOnLoaded("ZygorGuidesViewer") then
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					C_AddOns.EnableAddOn("ZygorGuidesViewer")
					ReloadUI();
				end
			else
				C_AddOns.DisableAddOn("ZygorGuidesViewer")
				ReloadUI();
			end
		else
			-- Zygor cannot be found
			LeaPlusLC:Print("Zygor addon not found.");
		end
		return
	end

	-- Show memory usage stat
	function LeaPlusLC:ShowMemoryUsage(frame, anchor, x, y)

		-- Create frame
		local memframe = CreateFrame("FRAME", nil, frame)
		memframe:ClearAllPoints()
		memframe:SetPoint(anchor, x, y)
		memframe:SetWidth(100)
		memframe:SetHeight(20)

		-- Create labels
		local pretext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		pretext:SetPoint("TOPLEFT", 0, 0)
		pretext:SetText(L["Memory Usage"])

		local memtext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		memtext:SetPoint("TOPLEFT", 0, 0 - 30)

		-- Create stat
		local memstat = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		memstat:SetPoint("BOTTOMLEFT", memtext, "BOTTOMRIGHT")
		memstat:SetText("(calculating...)")

		-- Create update script
		local memtime = -1
		memframe:SetScript("OnUpdate", function(self, elapsed)
			if memtime > 2 or memtime == -1 then
				UpdateAddOnMemoryUsage();
				memtext = GetAddOnMemoryUsage("Leatrix_Plus")
				memtext = math.floor(memtext + .5) .. " KB"
				memstat:SetText(memtext);
				memtime = 0;
			end
			memtime = memtime + elapsed;
		end)

		-- Release memory
		LeaPlusLC.ShowMemoryUsage = nil

	end

	-- Check if player is in LFG queue
	function LeaPlusLC:IsInLFGQueue()
		if 	GetLFGMode(LE_LFG_CATEGORY_LFD) or
			GetLFGMode(LE_LFG_CATEGORY_LFR) or
			GetLFGMode(LE_LFG_CATEGORY_RF) or
			GetLFGMode(LE_LFG_CATEGORY_SCENARIO) or
			GetLFGMode(LE_LFG_CATEGORY_FLEXRAID) then
			return true
		end
	end

	-- Check if player is in combat
	function LeaPlusLC:PlayerInCombat()
		if (UnitAffectingCombat("player")) then
			LeaPlusLC:Print("You cannot do that in combat.")
			return true
		end
	end

	--  Hide panel and pages
	function LeaPlusLC:HideFrames()

		-- Hide option pages
		for i = 0, LeaPlusLC["NumberOfPages"] do
			if LeaPlusLC["Page"..i] then
				LeaPlusLC["Page"..i]:Hide();
			end;
		end

		-- Hide options panel
		LeaPlusLC["PageF"]:Hide();

	end

	-- Find out if Leatrix Plus is showing (main panel or config panel)
	function LeaPlusLC:IsPlusShowing()
		if LeaPlusLC["PageF"]:IsShown() then return true end
		for k, v in pairs(LeaConfigList) do
			if v:IsShown() then
				return true
			end
		end
	end

	-- Check if a name is in your friends list, guild or community (does not check realm as realm is unknown for some checks)
	function LeaPlusLC:FriendCheck(name, guid)

		-- Do nothing if name is empty (such as whispering from the Battle.net app)
		if not name then return end

		-- Update friends list
		C_FriendList.ShowFriends()

		-- Remove realm (since we have GUID checking)
		name = strsplit("-", name, 2)

		-- Check character friends
		for i = 1, C_FriendList.GetNumFriends() do
			-- Return true is character name matches and GUID matches if there is one (realm is not checked)
			local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
			local charFriendName = C_FriendList.GetFriendInfoByIndex(i).name
			charFriendName = strsplit("-", charFriendName, 2)
			if (name == charFriendName) and (guid and (guid == friendInfo.guid) or true) then
				return true
			end
		end

		-- Check Battle.net friends
		local numfriends = BNGetNumFriends()
		for i = 1, numfriends do
			local numtoons = C_BattleNet.GetFriendNumGameAccounts(i)
			for j = 1, numtoons do
				local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(i, j)
				local characterName = gameAccountInfo.characterName
				local client = gameAccountInfo.clientProgram
				if client == "WoW" and characterName == name then
					return true
				end
			end
		end

		-- Check guild members if guild is enabled (new members may need to press J to refresh roster)
		if LeaPlusLC["FriendlyGuild"] == "On" then
			local gCount = GetNumGuildMembers()
			for i = 1, gCount do
				local gName, void, void, void, void, void, void, void, gOnline, void, void, void, void, gMobile, void, void, gGUID = GetGuildRosterInfo(i)
				if gOnline and not gMobile then
					gName = strsplit("-", gName, 2)
					-- Return true if character name matches including GUID if there is one
					if (name == gName) and (guid and (guid == gGUID) or true) then
						return true
					end
				end
			end
		end

		-- Check communities if communities is enabled
		if LeaPlusLC["FriendlyCommunities"] == "On" then
			local communities = C_Club.GetSubscribedClubs()
			for void, community in pairs(communities) do
				if community.clubType == Enum.ClubType.Character then
					local cMemberIds = CommunitiesUtil.GetMemberIdsSortedByName(community.clubId)
					local cMembersInfo = CommunitiesUtil.GetMemberInfo(community.clubId, cMemberIds)
					for void, member in pairs(cMembersInfo) do
						if member and member.name and member.presence and member.presence ~= Enum.ClubMemberPresence.Offline and member.presence ~= Enum.ClubMemberPresence.OnlineMobile then
							local cName = strsplit("-", member.name, 2)
							-- Return true if character name matches including GUID if there is one
							if (name == cName) and (guid and member.guid and (guid == member.guid) or true) then
								return true
							end
						end
					end
				end
			end
		end

	end

----------------------------------------------------------------------
--	L02: Locks
----------------------------------------------------------------------

	-- Function to set lock state for configuration buttons
	function LeaPlusLC:LockOption(option, item, reloadreq)
		if reloadreq then
			-- Option change requires UI reload
			if LeaPlusLC[option] ~= LeaPlusDB[option] or LeaPlusLC[option] == "Off" then
				LeaPlusLC:LockItem(LeaPlusCB[item], true)
			else
				LeaPlusLC:LockItem(LeaPlusCB[item], false)
			end
		else
			-- Option change does not require UI reload
			if LeaPlusLC[option] == "Off" then
				LeaPlusLC:LockItem(LeaPlusCB[item], true)
			else
				LeaPlusLC:LockItem(LeaPlusCB[item], false)
			end
		end
	end

--	Set lock state for configuration buttons
	function LeaPlusLC:SetDim()
		LeaPlusLC:LockOption("AutomateQuests", "AutomateQuestsBtn", false)			-- Automate quests
		LeaPlusLC:LockOption("AutoAcceptRes", "AutoAcceptResBtn", false)			-- Accept resurrection
		LeaPlusLC:LockOption("AutoReleasePvP", "AutoReleasePvPBtn", false)			-- Release in PvP
		LeaPlusLC:LockOption("AutoSellJunk", "AutoSellJunkBtn", true)				-- Sell junk automatically
		LeaPlusLC:LockOption("AutoRepairGear", "AutoRepairBtn", false)				-- Repair automatically
		LeaPlusLC:LockOption("InviteFromWhisper", "InvWhisperBtn", false)			-- Invite from whispers
		LeaPlusLC:LockOption("NoChatButtons", "NoChatButtonsBtn", true)				-- Hide chat buttons
		LeaPlusLC:LockOption("FilterChatMessages", "FilterChatMessagesBtn", true)	-- Filter chat messages
		LeaPlusLC:LockOption("QuestFontChange", "QuestTextBtn", true)				-- Resize quest text
		LeaPlusLC:LockOption("MinimapModder", "ModMinimapBtn", true)				-- Enhance minimap
		LeaPlusLC:LockOption("TipModEnable", "MoveTooltipButton", true)				-- Enhance tooltip
		LeaPlusLC:LockOption("EnhanceDressup", "EnhanceDressupBtn", true)			-- Enhance dressup
		LeaPlusLC:LockOption("ShowBorders", "ModBordersBtn", true)					-- Show borders
		LeaPlusLC:LockOption("ShowPlayerChain", "ModPlayerChain", true)				-- Show player chain
		LeaPlusLC:LockOption("ShowInfoCards", "ShowInfoCardsBtn", true)				-- Show info cards
		LeaPlusLC:LockOption("ShowWowheadLinks", "ShowWowheadLinksBtn", true)		-- Show Wowhead links
		LeaPlusLC:LockOption("ManageWidgetTop", "ManageWidgetTopButton", true)		-- Manage widget top
		LeaPlusLC:LockOption("ClassColFrames", "ClassColFramesBtn", true)			-- Class colored frames
		LeaPlusLC:LockOption("SetWeatherDensity", "SetWeatherDensityBtn", false)	-- Set weather density
		LeaPlusLC:LockOption("MuteGameSounds", "MuteGameSoundsBtn", false)			-- Mute game sounds
		LeaPlusLC:LockOption("MuteMountSounds", "MuteMountSoundsBtn", false)		-- Mute mount sounds
		LeaPlusLC:LockOption("MuteCustomSounds", "MuteCustomSoundsBtn", false)		-- Mute custom sounds
		LeaPlusLC:LockOption("FasterLooting", "FasterLootingBtn", true)				-- Faster auto loot
		LeaPlusLC:LockOption("NoTransforms", "NoTransformsBtn", false)				-- Remove transforms
		LeaPlusLC:LockOption("SetEditModeLayout", "SetEditModeLayoutBtn", false)	-- Set edit mode layout
	end

----------------------------------------------------------------------
--	L03: Restarts
----------------------------------------------------------------------

	-- Set the reload button state
	function LeaPlusLC:ReloadCheck()

		-- Automation
		if	(LeaPlusLC["AutoSellJunk"]			~= LeaPlusDB["AutoSellJunk"])			-- Sell junk automatically

		-- Chat
		or	(LeaPlusLC["UseEasyChatResizing"]	~= LeaPlusDB["UseEasyChatResizing"])	-- Use easy resizing
		or	(LeaPlusLC["NoCombatLogTab"]		~= LeaPlusDB["NoCombatLogTab"])			-- Hide the combat log
		or	(LeaPlusLC["NoChatButtons"]			~= LeaPlusDB["NoChatButtons"])			-- Hide chat buttons
		or	(LeaPlusLC["NoSocialButton"]		~= LeaPlusDB["NoSocialButton"])			-- Hide social button
		or	(LeaPlusLC["UnclampChat"]			~= LeaPlusDB["UnclampChat"])			-- Unclamp chat frame
		or	(LeaPlusLC["MoveChatEditBoxToTop"]	~= LeaPlusDB["MoveChatEditBoxToTop"])	-- Move editbox to top
		or	(LeaPlusLC["MoreChatFontSizes"]		~= LeaPlusDB["MoreChatFontSizes"])		-- More chat font sizes
		or	(LeaPlusLC["NoStickyChat"]			~= LeaPlusDB["NoStickyChat"])			-- Disable sticky chat
		or	(LeaPlusLC["UseArrowKeysInChat"]	~= LeaPlusDB["UseArrowKeysInChat"])		-- Use arrow keys in chat
		or	(LeaPlusLC["NoChatFade"]			~= LeaPlusDB["NoChatFade"])				-- Disable chat fade
		or	(LeaPlusLC["RecentChatWindow"]		~= LeaPlusDB["RecentChatWindow"])		-- Recent chat window
		or	(LeaPlusLC["FilterChatMessages"]	~= LeaPlusDB["FilterChatMessages"])		-- Filter chat messages
		or	(LeaPlusLC["RestoreChatMessages"]	~= LeaPlusDB["RestoreChatMessages"])	-- Restore chat messages

		-- Text
		or	(LeaPlusLC["HideErrorMessages"]		~= LeaPlusDB["HideErrorMessages"])		-- Hide error messages
		or	(LeaPlusLC["NoHitIndicators"]		~= LeaPlusDB["NoHitIndicators"])		-- Hide portrait numbers
		or	(LeaPlusLC["HideZoneText"]			~= LeaPlusDB["HideZoneText"])			-- Hide zone text
		or	(LeaPlusLC["HideKeybindText"]		~= LeaPlusDB["HideKeybindText"])		-- Hide keybind text
		or	(LeaPlusLC["HideMacroText"]			~= LeaPlusDB["HideMacroText"])			-- Hide macro text

		or	(LeaPlusLC["QuestFontChange"]		~= LeaPlusDB["QuestFontChange"])		-- Resize quest text

		-- Interface
		or	(LeaPlusLC["MinimapModder"]			~= LeaPlusDB["MinimapModder"])			-- Enhance minimap
		or	(LeaPlusLC["SquareMinimap"]			~= LeaPlusDB["SquareMinimap"])			-- Square minimap
		or	(LeaPlusLC["HideMiniAddonMenu"]		~= LeaPlusDB["HideMiniAddonMenu"])		-- Hide addon menu
		or	(LeaPlusLC["UnclampMinimap"]		~= LeaPlusDB["UnclampMinimap"])			-- Unclamp minimap cluster
		or	(LeaPlusLC["MinimapButtonBag"]		~= LeaPlusDB["MinimapButtonBag"])		-- Minimap button bag
		or	(LeaPlusLC["MiniExcludeList"]		~= LeaPlusDB["MiniExcludeList"])		-- Minimap exclude list
		or	(LeaPlusLC["TipModEnable"]			~= LeaPlusDB["TipModEnable"])			-- Enhance tooltip
		or	(LeaPlusLC["TipNoHealthBar"]		~= LeaPlusDB["TipNoHealthBar"])			-- Tooltip hide health bar
		or	(LeaPlusLC["EnhanceDressup"]		~= LeaPlusDB["EnhanceDressup"])			-- Enhance dressup
		or	(LeaPlusLC["DressupMoreZoomOut"]	~= LeaPlusDB["DressupMoreZoomOut"])		-- Enhance dressup increase zoom out distance
		or	(LeaPlusLC["ShowVolume"]			~= LeaPlusDB["ShowVolume"])				-- Show volume slider
		or	(LeaPlusLC["DurabilityStatus"]		~= LeaPlusDB["DurabilityStatus"])		-- Show durability status
		or	(LeaPlusLC["ShowPetSaveBtn"]		~= LeaPlusDB["ShowPetSaveBtn"])			-- Show pet save button
		or	(LeaPlusLC["ShowRaidToggle"]		~= LeaPlusDB["ShowRaidToggle"])			-- Show raid button
		or	(LeaPlusLC["ShowTrainAllButton"]	~= LeaPlusDB["ShowTrainAllButton"])		-- Show train all button
		or	(LeaPlusLC["ShowBorders"]			~= LeaPlusDB["ShowBorders"])			-- Show borders
		or	(LeaPlusLC["ShowPlayerChain"]		~= LeaPlusDB["ShowPlayerChain"])		-- Show player chain
		or	(LeaPlusLC["ShowReadyTimer"]		~= LeaPlusDB["ShowReadyTimer"])			-- Show ready timer
		or	(LeaPlusLC["ShowRangeColoring"]		~= LeaPlusDB["ShowRangeColoring"])		-- Show range coloring
		or	(LeaPlusLC["ShowInfoCards"]			~= LeaPlusDB["ShowInfoCards"])			-- Show info cards
		or	(LeaPlusLC["ShowWowheadLinks"]		~= LeaPlusDB["ShowWowheadLinks"])		-- Show Wowhead links

		-- Frames
		or	(LeaPlusLC["ManageWidgetTop"]		~= LeaPlusDB["ManageWidgetTop"])		-- Manage widget top
		or	(LeaPlusLC["ClassColFrames"]		~= LeaPlusDB["ClassColFrames"])			-- Class colored frames

		or	(LeaPlusLC["NoAlerts"]				~= LeaPlusDB["NoAlerts"])				-- Hide alerts
		or	(LeaPlusLC["HideBodyguard"]			~= LeaPlusDB["HideBodyguard"])			-- Hide bodyguard gossip
		or	(LeaPlusLC["HideTalkingFrame"]		~= LeaPlusDB["HideTalkingFrame"])		-- Hide talking frame
		or	(LeaPlusLC["HideCleanupBtns"]		~= LeaPlusDB["HideCleanupBtns"])		-- Hide clean-up buttons
		or	(LeaPlusLC["HideBossBanner"]		~= LeaPlusDB["HideBossBanner"])			-- Hide boss banner
		or	(LeaPlusLC["HideEventToasts"]		~= LeaPlusDB["HideEventToasts"])		-- Hide event toasts
		or	(LeaPlusLC["NoClassBar"]			~= LeaPlusDB["NoClassBar"])				-- Hide stance bar
		or	(LeaPlusLC["NoRestedSleep"]			~= LeaPlusDB["NoRestedSleep"])			-- Hide rested sleep

		-- System
		or	(LeaPlusLC["NoRestedEmotes"]		~= LeaPlusDB["NoRestedEmotes"])			-- Silence rested emotes
		or	(LeaPlusLC["KeepAudioSynced"]		~= LeaPlusDB["KeepAudioSynced"])		-- Keep audio synced
		or	(LeaPlusLC["NoPetAutomation"]		~= LeaPlusDB["NoPetAutomation"])		-- Disable pet automation
		or	(LeaPlusLC["FasterLooting"]			~= LeaPlusDB["FasterLooting"])			-- Faster auto loot
		or	(LeaPlusLC["FasterMovieSkip"]		~= LeaPlusDB["FasterMovieSkip"])		-- Faster movie skip
		or	(LeaPlusLC["CombatPlates"]			~= LeaPlusDB["CombatPlates"])			-- Combat plates
		or	(LeaPlusLC["EasyItemDestroy"]		~= LeaPlusDB["EasyItemDestroy"])		-- Easy item destroy

		-- Settings
		or	(LeaPlusLC["AddonLanguage"]			~= LeaPlusDB["AddonLanguage"])			-- Addon language
		or	(LeaPlusLC["SimpleAddonListing"]	~= LeaPlusDB["SimpleAddonListing"])		-- Simple addon listing
		or	(LeaPlusLC["HideStarterTutorials"]	~= LeaPlusDB["HideStarterTutorials"])	-- Hide starter tutorials

		then
			-- Enable the reload button
			LeaPlusLC:LockItem(LeaPlusCB["ReloadUIButton"], false)
			LeaPlusCB["ReloadUIButton"].f:Show()
		else
			-- Disable the reload button
			LeaPlusLC:LockItem(LeaPlusCB["ReloadUIButton"], true)
			LeaPlusCB["ReloadUIButton"].f:Hide()
		end

	end

----------------------------------------------------------------------
--	L40: Player
----------------------------------------------------------------------

	function LeaPlusLC:Player()

		----------------------------------------------------------------------
		-- Show info cards
		----------------------------------------------------------------------

		if LeaPlusLC["ShowInfoCards"] == "On" then

			-- Watch for Ctrl being pressed and only then give the card's link box the keyboard so CTRL/C copies the link
			-- (made now, while loading, as setting it up is not allowed in combat after loading)
			do
				local watcher = CreateFrame("Frame", nil, UIParent)
				watcher:SetPropagateKeyboardInput(true)
				watcher:EnableKeyboard(true)
				watcher:SetScript("OnKeyDown", function(self, key)
					local card = LeaPlusLC.IDCard
					if not card or not card:IsShown() then
						-- No card showing, so every key goes to the game
						if not InCombatLockdown() and not self:GetPropagateKeyboardInput() then self:SetPropagateKeyboardInput(true) end
						return
					end
					-- Escape closes the card (and is kept from the game, outside combat)
					if not InCombatLockdown() then self:SetPropagateKeyboardInput(key ~= "ESCAPE") end
					if key == "ESCAPE" then
						local viewer = LeaPlusLC.IDViewer
						if viewer and viewer.scenePopup and viewer.scenePopup:IsShown() then viewer.scenePopup:Hide() elseif viewer and viewer.fullscreen then viewer:SetFullscreen(false) else card:Hide() end
						-- Let keys through to the game again straight after (never left blocked)
						C_Timer.After(0, function() if not InCombatLockdown() then self:SetPropagateKeyboardInput(true) end end)
						return
					end
					if (key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA") and card.url and not card.edit:HasFocus() then
						card.ctrlFocus = true
						card.edit:SetFocus()
						card.edit:HighlightText()
					end
				end)
			end

			-- Show the info card for whatever is under the mouse (arg1 is retry or upgrade when it runs itself again)
			local function ShowInfoCard(arg1, forceUnit)
				-- Secret values: the game can hide some values from addons (such as in combat, encounters and arenas)
				-- Anything that can be hidden is passed through Safe, which gives nil for a hidden value so it is left out
				local function IsSecret(v) return issecretvalue and issecretvalue(v) or false end
				local function Safe(...)
					local count = select("#", ...)
					if count == 1 then
						local v = ...
						if IsSecret(v) then return nil end
						return v
					end
					local values = {...}
					for i = 1, count do if IsSecret(values[i]) then values[i] = nil end end
					return unpack(values, 1, count)
				end
				-- Tables the game does not let addons read are left out too
				local function SafeTable(t)
					if type(t) == "table" and not IsSecret(t) and (not canaccesstable or canaccesstable(t)) then return t end
				end
				-- Auras: when auras are hidden, the game does not let addons read them at all (asking is an error), so check first
				local function AurasHidden()
					return C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret() or false
				end
				-- Get a buff or debuff by its index: gives the aura (nil if it is hidden), and true when there are no more to look at
				local function GetAura(unit, index, harmful)
					if AurasHidden() then return nil, true end
					if C_Secrets and C_Secrets.ShouldUnitAuraIndexBeSecret and C_Secrets.ShouldUnitAuraIndexBeSecret(unit, index, harmful and "HARMFUL" or "HELPFUL") then return nil, false end
					local aura
					if harmful then aura = C_UnitAuras.GetDebuffDataByIndex(unit, index) else aura = C_UnitAuras.GetBuffDataByIndex(unit, index) end
					if not aura then return nil, true end
					return SafeTable(aura), false
				end
				-- Size of one screen pixel (borders this thin stay sharp and do not vanish when frames are moved)
				local function OnePixel()
					local physicalHeight = select(2, GetPhysicalScreenSize())
					if not physicalHeight or physicalHeight == 0 then return 1 end
					return (768 / physicalHeight) / UIParent:GetEffectiveScale()
				end
				-- Round a size or offset to whole screen pixels
				local function PixelRound(v)
					local px = OnePixel()
					return math.floor(v / px + 0.5) * px
				end
				-- Line a frame up with the screen pixels (position and size) so thin borders are always drawn
				local function SnapToPixels(frame)
					local px = OnePixel()
					local left, bottom, width, height = frame:GetLeft(), frame:GetBottom(), frame:GetWidth(), frame:GetHeight()
					if not (left and bottom) then return end
					local function Round(v) return math.floor(v / px + 0.5) * px end
					frame:ClearAllPoints()
					frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", Round(left), Round(bottom))
					frame:SetSize(Round(width), Round(height))
				end
				-- Attach the model viewer to the right side of the card, and keep the card and viewer on the screen together
				local function AttachViewer()
					local card, viewer = LeaPlusLC.IDCard, LeaPlusLC.IDViewer
					if not card or not viewer then return end
					local gap = PixelRound(8)
					viewer:ClearAllPoints()
					if viewer.offscreen then
						-- Switched off with the checkbox: kept loaded but off the screen, so ticking the box shows it straight away
						viewer:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -4000, -4000)
						return
					end
					if viewer.fullscreen then
						-- Fullscreen: fill the whole screen (over the card)
						viewer:SetAllPoints(UIParent)
						return
					end
					viewer:SetPoint("BOTTOMLEFT", card, "BOTTOMRIGHT", gap, 0)
					if not viewer:IsShown() then return end
					-- Move the card if the viewer would go off the right or top of the screen
					local cardLeft, cardBottom = card:GetLeft(), card:GetBottom()
					if not cardLeft then return end
					local overRight = (cardLeft + card:GetWidth() + gap + viewer:GetWidth()) - UIParent:GetRight()
					local overTop = (cardBottom + viewer:GetHeight()) - UIParent:GetTop()
					if overRight > 0 or overTop > 0 then
						card:ClearAllPoints()
						card:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", math.max(0, cardLeft - math.max(0, overRight)), math.max(0, cardBottom - math.max(0, overTop)))
						SnapToPixels(card)
					end
				end
				-- Flat button in the ID card style (dark with an accent coloured border and text)
				local function FlatButton(parent, width, height, text)
					local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
					button:SetSize(width, height)
					button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
					button:SetBackdropColor(1, 1, 1, 0.05)
					button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
					button.label:SetPoint("CENTER", button, "CENTER", 0, 0)
					button.label:SetText(text)
					button:SetScript("OnEnter", function(self) self:SetBackdropColor(1, 1, 1, 0.14) end)
					button:SetScript("OnLeave", function(self) self:SetBackdropColor(1, 1, 1, 0.05) end)
					button:SetScript("OnMouseDown", function(self) self.label:SetPoint("CENTER", self, "CENTER", 1, -1) end)
					button:SetScript("OnMouseUp", function(self) self.label:SetPoint("CENTER", self, "CENTER", 0, 0) end)
					function button:SetAccent(r, g, b)
						self:SetBackdropBorderColor(r, g, b, 0.7)
						self.label:SetTextColor(r, g, b)
					end
					function button:SetLabel(newText) self.label:SetText(newText) end
					button:SetAccent(1, 0.82, 0)
					return button
				end
				-- Model viewer: a 3D model (players, NPCs and wearable items) with flavour text
				-- The model is only ever changed while the viewer is showing, and changes that need the model wait until it has loaded
				local viewerAnims = {0, 4, 5, 143, 119, 26, 25, 27, 28, 108, 120, 51, 124, 52, 125, 126, 62, 63, 41, 42, 43, 44, 132, 38, 14, 115, 193, 48, 110, 109, 134, 197, 0} -- Same as Enhance dressup
				local function ShowViewer(info)
					local card = LeaPlusLC.IDCard
					local view = info and info.view
					local viewer = LeaPlusLC.IDViewer
					if not view then if viewer then viewer:Hide() end return end
					if not viewer then
						viewer = CreateFrame("Frame", nil, card, "BackdropTemplate")
						viewer:Hide()
						viewer:SetSize(PixelRound(380), PixelRound(520))
						viewer:SetPoint("BOTTOMLEFT", card, "BOTTOMRIGHT", PixelRound(8), 0)
						viewer:SetFrameStrata("FULLSCREEN_DIALOG")
						viewer:SetFrameLevel(card:GetFrameLevel() + 50) -- Above the card and its buttons
						viewer:EnableMouse(true)
						viewer:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
						viewer:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
						-- Drawn into its own buffer, so 3D models open behind it (such as the character frame's model) cannot show through the model as a silhouette
						-- (set once here and left on, as turning it off again leaves the model blank)
						if viewer.SetIsFrameBuffer then viewer:SetIsFrameBuffer(true) end
						viewer.title = viewer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
						viewer.title:SetPoint("TOPLEFT", viewer, "TOPLEFT", 14, -14)
						viewer.title:SetPoint("RIGHT", viewer, "RIGHT", -110, 0)
						viewer.title:SetJustifyH("LEFT")
						viewer.title:SetWordWrap(false)
						-- Gear button (takes equipped items off and puts them back on)
						viewer.gear = FlatButton(viewer, 86, 22, L["Hide gear"])
						viewer.gear:SetPoint("TOPRIGHT", viewer, "TOPRIGHT", -10, -10)
						-- Fullscreen button (shows the viewer over the whole screen, Escape or the button again puts it back)
						viewer.full = FlatButton(viewer, 86, 22, L["Exit fullscreen"])
						local exitWidth = viewer.full.label:GetStringWidth()
						viewer.full:SetLabel(L["Fullscreen"])
						viewer.full:SetWidth(math.max(exitWidth, viewer.full.label:GetStringWidth()) + 20) -- Wide enough for both labels
						viewer.full:SetScript("OnClick", function() viewer:SetFullscreen(not viewer.fullscreen) end)
						-- Place the fullscreen button left of the gear button (or in the corner when there is no gear button), and keep the title clear of them
						function viewer:LayoutButtons()
							-- Fullscreen button on the far right, then the gear button (players and items), then the scene button (fullscreen only)
							self.full:ClearAllPoints()
							self.full:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -10)
							self.gear:ClearAllPoints()
							self.gear:SetPoint("RIGHT", self.full, "LEFT", -6, 0)
							local used = 10 + self.full:GetWidth() + (self.gear:IsShown() and (6 + self.gear:GetWidth()) or 0) + 14
							if self.sceneBtn then
								self.sceneBtn:ClearAllPoints()
								self.sceneBtn:SetPoint("RIGHT", self.gear:IsShown() and self.gear or self.full, "LEFT", -6, 0)
								if self.sceneBtn:IsShown() then used = used + 6 + self.sceneBtn:GetWidth() end
							end
							self.title:ClearAllPoints()
							self.title:SetPoint("TOPLEFT", self, "TOPLEFT", 14, -14)
							if self.fullscreen and self.sceneBtn then
								self.title:SetWidth(math.min(self.title.GetUnboundedStringWidth and self.title:GetUnboundedStringWidth() or self.title:GetStringWidth(), 320) + 2) -- Only as wide as the name (the flavour text follows it)
							else
								self.title:SetPoint("RIGHT", self, "RIGHT", -used, 0)
							end
						end
						viewer.gear:HookScript("OnShow", function() viewer:LayoutButtons() end)
						viewer.gear:HookScript("OnHide", function() viewer:LayoutButtons() end)
						-- Model area
						viewer.stage = viewer:CreateTexture(nil, "BORDER")
						viewer.stage:SetPoint("TOPLEFT", viewer, "TOPLEFT", 12, -42)
						viewer.stage:SetColorTexture(0, 0, 0, 0.45)
						-- Model frames: two dressing room models for players and items (one wearing gear, one without, so the gear button
						-- just swaps between them and nothing reloads or moves), and a plain model for NPCs and pets
						-- (creature models in a dressing room model can crash the game)
						viewer.dressModel = CreateFrame("DressUpModel", nil, viewer)
						viewer.nakedModel = CreateFrame("DressUpModel", nil, viewer)
						viewer.creatureModel = CreateFrame("PlayerModel", nil, viewer)
						viewer.dressModel.twin, viewer.nakedModel.twin = viewer.nakedModel, viewer.dressModel
						for void, model in ipairs({viewer.dressModel, viewer.nakedModel, viewer.creatureModel}) do
						if model.SetKeepModelOnHide then model:SetKeepModelOnHide(true) end -- Keep the model when it is hidden (for the gear swap)
						model:SetAllPoints(viewer.stage)
						model:EnableMouse(true)
						model:EnableMouseWheel(true)
						model:Hide()
						-- Run a function once the model has loaded (or straight away if it already has)
						function model:WhenLoaded(func)
							if self.loaded then C_Timer.After(0, function() if self.loaded and self:IsVisible() then func() end end) return end
							self.onLoaded = func
							C_Timer.After(0.3, function() -- In case the loaded event does not fire
								if self.onLoaded == func and self:IsVisible() then self.loaded = true self.onLoaded = nil func() end
							end)
						end
						model:SetScript("OnModelLoaded", function(self)
							self.loaded = true
							local func = self.onLoaded
							self.onLoaded = nil
							if func then C_Timer.After(0, function() if self.loaded and self:IsVisible() then func() end end) end -- Next frame, not in the middle of loading
						end)
						-- Left button turns, right button moves, middle button turns and tilts freely, mouse wheel zooms
						model:SetScript("OnMouseDown", function(self, btn)
							if btn == "LeftButton" then self.turning = GetCursorPosition() elseif btn == "RightButton" then self.panX, self.panY = GetCursorPosition() elseif btn == "MiddleButton" then self.freeX, self.freeY = GetCursorPosition() end
						end)
						model:SetScript("OnMouseUp", function(self, btn)
							if btn == "LeftButton" then self.turning = nil elseif btn == "RightButton" then self.panX, self.panY = nil, nil elseif btn == "MiddleButton" then self.freeX, self.freeY = nil, nil end
						end)
						model:SetScript("OnHide", function(self) self.turning, self.panX, self.panY, self.freeX, self.freeY = nil, nil, nil, nil, nil end)
						model:SetScript("OnUpdate", function(self, elapsed)
							if not self.loaded then return end
							local changed
							-- Smooth zoom (eases towards the zoom chosen with the mouse wheel by moving the model towards the camera)
							-- Camera distance functions are not used as they can crash the game while a model is loading
							local target = self.zoomTarget or 0
							if math.abs(target - (self.zoom or 0)) > 0.001 then
								self.zoom = (self.zoom or 0) + (target - (self.zoom or 0)) * math.min(1, elapsed * 10)
								self:SetPosition(self.zoom, self.offsetY or 0, self.offsetZ or 0)
								changed = true
							end
							if self.turning then
								local x = GetCursorPosition()
								self.facing = (self.facing or 0) + (x - self.turning) * 0.012
								self.turning = x
								self:SetFacing(self.facing)
								changed = true
							end
							if self.freeX then
								-- Middle button: left and right turns, up and down tilts
								local x, y = GetCursorPosition()
								self.facing = (self.facing or 0) + (x - self.freeX) * 0.012
								self.pitch = (self.pitch or 0) - (y - self.freeY) * 0.012
								self.freeX, self.freeY = x, y
								self:SetFacing(self.facing)
								if self.SetPitch then self:SetPitch(self.pitch) end
								changed = true
							end
							if self.panX then
								local x, y = GetCursorPosition()
								local step = 0.004 * math.max(0.3, 1 - (self.zoom or 0) * 0.3)
								self.offsetY = (self.offsetY or 0) + (x - self.panX) * step
								self.offsetZ = (self.offsetZ or 0) + (y - self.panY) * step
								self.panX, self.panY = x, y
								self:SetPosition(self.zoom or 0, self.offsetY, self.offsetZ)
								changed = true
							end
							-- Keep the other dressing room model (gear on or off) the same, so swapping gear does not move anything
							local twin = self.twin
							if changed and twin and twin.loaded then
								twin.facing, twin.pitch, twin.zoom, twin.zoomTarget, twin.offsetY, twin.offsetZ = self.facing, self.pitch, self.zoom, self.zoomTarget, self.offsetY, self.offsetZ
								twin:SetFacing(twin.facing or 0)
								if twin.SetPitch then twin:SetPitch(twin.pitch or 0) end
								twin:SetPosition(twin.zoom or 0, twin.offsetY or 0, twin.offsetZ or 0)
							end
						end)
						model:SetScript("OnMouseWheel", function(self, delta)
							if not self.loaded then return end
							self.zoomTarget = math.max(-1.5, math.min(2.5, (self.zoomTarget or 0) + delta * 0.3))
						end)
						end
						viewer.model = viewer.dressModel
						-- Controls button (pointing at it shows how to turn, move, tilt and zoom the model)
						viewer.hint = FlatButton(viewer, 70, 20, L["Controls"])
						viewer.hint:SetWidth(viewer.hint.label:GetStringWidth() + 20)
						viewer.hint:SetPoint("BOTTOMRIGHT", viewer.stage, "BOTTOMRIGHT", -10, 10)
						-- Controls popup (made the first time the button is pointed at)
						function viewer:ShowControls()
							local tip = self.controlsTip
							if not tip then
								tip = CreateFrame("Frame", nil, self, "BackdropTemplate")
								self.controlsTip = tip
								tip:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
								tip:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
								tip.heading = tip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
								tip.heading:SetPoint("TOPLEFT", tip, "TOPLEFT", 14, -12)
								tip.heading:SetText(L["Model controls"])
								local rows = {
									{L["Left-drag"], L["Turn"]},
									{L["Right-drag"], L["Move"]},
									{L["Middle-drag"], L["Turn and tilt"]},
									{L["Mouse wheel"], L["Zoom"]},
								}
								tip.keys, tip.actions = {}, {}
								local keyWidth, actionWidth = 0, 0
								for i, row in ipairs(rows) do
									local key = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
									key:SetPoint("TOPLEFT", tip, "TOPLEFT", 14, -36 - (i - 1) * 18)
									key:SetText(row[1])
									local action = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
									action:SetText(row[2])
									action:SetTextColor(0.8, 0.8, 0.8)
									tip.keys[i], tip.actions[i] = key, action
									keyWidth = math.max(keyWidth, key:GetStringWidth())
									actionWidth = math.max(actionWidth, action:GetStringWidth())
								end
								for i, action in ipairs(tip.actions) do
									action:SetPoint("LEFT", tip.keys[i], "LEFT", keyWidth + 18, 0)
								end
								tip:SetSize(math.max(tip.heading:GetStringWidth(), keyWidth + 18 + actionWidth) + 28, 36 + #rows * 18 + 6)
							end
							-- Colours follow the viewer (key names in the accent colour)
							local r, g, b = unpack(self.accent or {1, 0.82, 0})
							tip:SetBackdropBorderColor(r, g, b, 0.55)
							tip.heading:SetTextColor(r, g, b)
							for void, key in ipairs(tip.keys) do key:SetTextColor(r, g, b) end
							-- Above the button, lined up with its right edge
							tip:ClearAllPoints()
							tip:SetPoint("BOTTOMRIGHT", self.hint, "TOPRIGHT", 0, 6)
							tip:SetFrameLevel(self:GetFrameLevel() + 30)
							tip:Show()
						end
						local function HideControls() if viewer.controlsTip then viewer.controlsTip:Hide() end end
						viewer.hint:HookScript("OnEnter", function() viewer:ShowControls() end)
						viewer.hint:HookScript("OnLeave", HideControls)
						viewer.hint:HookScript("OnHide", HideControls)
						-- Waiting for a player (shown when they can no longer be found, the model loads when the mouse is over them again)
						viewer.waitText = viewer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
						viewer.waitText:SetPoint("LEFT", viewer.stage, "LEFT", 20, 0)
						viewer.waitText:SetPoint("RIGHT", viewer.stage, "RIGHT", -20, 0)
						viewer.waitText:SetWordWrap(true)
						viewer.waitText:Hide()
						viewer:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
						function viewer:CheckWaiting()
							if not self:IsShown() or self.waitGUID == nil then return end
							if not UnitExists("mouseover") then return end
							-- Match by GUID, or by name when the GUID cannot be read
							local guid = UnitGUID("mouseover")
							local match
							if guid and not (issecretvalue and issecretvalue(guid)) and self.waitGUID then
								match = guid == self.waitGUID
							else
								local name, realm = UnitName("mouseover")
								if name and not (issecretvalue and (issecretvalue(name) or (realm and issecretvalue(realm)))) then
									match = name == self.waitName or (realm and realm ~= "" and (name .. " " .. realm) == self.waitName)
								end
							end
							if match then
								local cardInfo = LeaPlusLC.IDCard and LeaPlusLC.IDCard.info
								if cardInfo and cardInfo.view and cardInfo.name == self.waitName then
									cardInfo.view.unit = "mouseover"
									cardInfo.view.fresh = true
									self.lastLoad = nil -- Load straight away
									cardInfo.openViewer = true
									ShowViewer(cardInfo)
									cardInfo.view.fresh = nil
									cardInfo.openViewer = nil
								end
							end
						end
						viewer:SetScript("OnEvent", function(self) self:CheckWaiting() end)
						-- Animation slider (same animations as Enhance dressup)
						-- Gear slot buttons (players and items): click one to take that piece off the model, click again to put it back on
						viewer.hiddenSlots, viewer.slotInfo, viewer.slotButtons = {}, {}, {}
						viewer.slotRow = CreateFrame("Frame", nil, viewer)
						viewer.slotRow:SetPoint("TOPLEFT", viewer.stage, "BOTTOMLEFT", 0, -8)
						viewer.slotRow:SetPoint("TOPRIGHT", viewer.stage, "BOTTOMRIGHT", 0, -8)
						viewer.slotRow:SetHeight(22)
						viewer.slotRow:Hide()
						local slotList = {{1, "HeadSlot"}, {3, "ShoulderSlot"}, {15, "BackSlot"}, {5, "ChestSlot"}, {4, "ShirtSlot"}, {19, "TabardSlot"}, {9, "WristSlot"}, {10, "HandsSlot"}, {6, "WaistSlot"}, {7, "LegsSlot"}, {8, "FeetSlot"}, {16, "MainHandSlot"}, {17, "SecondaryHandSlot"}, {18, "RangedSlot"}}
						for void, entry in ipairs(slotList) do
							local slotID, slotName = entry[1], entry[2]
							local ok, slotNumber, emptyTexture = pcall(GetInventorySlotInfo, slotName) -- Slots this game does not have are left out
							if ok and slotNumber then
								local button = CreateFrame("Button", nil, viewer.slotRow, "BackdropTemplate")
								button.slotID, button.slotName, button.emptyTexture = slotID, slotName, emptyTexture
								button.label = _G[strupper(slotName)] or slotName
								button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
								button:SetBackdropColor(0, 0, 0, 0.6)
								button:SetBackdropBorderColor(1, 1, 1, 0.15)
								button.icon = button:CreateTexture(nil, "ARTWORK")
								button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", OnePixel(), -OnePixel())
								button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -OnePixel(), OnePixel())
								button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
								button:SetScript("OnEnter", function(self)
									GameTooltip:SetOwner(self, "ANCHOR_TOP")
									GameTooltip:AddLine(self.label, 1, 1, 1)
									if not viewer.slotInfo[self.slotID] then
										GameTooltip:AddLine(L["Nothing to show in this slot"], 0.6, 0.6, 0.65)
									elseif viewer.gearOff then
										GameTooltip:AddLine(L["Click Show gear first"], 0.6, 0.6, 0.65)
									elseif viewer.hiddenSlots[self.slotID] then
										GameTooltip:AddLine(L["Click to show"], 0.6, 0.6, 0.65)
									else
										GameTooltip:AddLine(L["Click to hide"], 0.6, 0.6, 0.65)
									end
									GameTooltip:Show()
								end)
								button:SetScript("OnLeave", function() GameTooltip:Hide() end)
								button:SetScript("OnClick", function(self)
									local info = viewer.slotInfo[self.slotID]
									local model = viewer.dressModel
									if not info or viewer.gearOff or not model.loaded then return end
									if viewer.hiddenSlots[self.slotID] then
										-- Put it back on
										viewer.hiddenSlots[self.slotID] = nil
										if info.transmog and model.SetItemTransmogInfo then
											pcall(model.SetItemTransmogInfo, model, info.transmog, self.slotID)
										elseif info.link then
											pcall(model.TryOn, model, info.link, (self.slotID == 16 or self.slotID == 17) and strupper(self.slotName) or nil)
										end
									else
										-- Take it off
										viewer.hiddenSlots[self.slotID] = true
										pcall(model.UndressSlot, model, self.slotID)
									end
									viewer:UpdateSlots()
									if GameTooltip:IsOwned(self) then self:GetScript("OnEnter")(self) end
								end)
								tinsert(viewer.slotButtons, button)
							end
						end
						-- Show each button as worn, taken off or empty
						function viewer:UpdateSlots()
							local r, g, b = unpack(self.accent or {1, 0.82, 0})
							for void, button in ipairs(self.slotButtons) do
								local info = self.slotInfo[button.slotID]
								local hidden = self.hiddenSlots[button.slotID] and true or false
								local worn = info and not hidden and not self.gearOff
								button.icon:SetTexture((info and info.icon) or button.emptyTexture or 136528)
								button.icon:SetDesaturated(not worn)
								button.icon:SetAlpha(not info and 0.3 or worn and 1 or 0.45)
								if worn then button:SetBackdropBorderColor(r, g, b, 0.7) else button:SetBackdropBorderColor(1, 1, 1, 0.15) end
							end
						end
						-- Read what the model is wearing in each slot (so a piece can be put back on after it is taken off)
						function viewer:ReadSlots(model, unit)
							wipe(self.slotInfo)
							wipe(self.hiddenSlots)
							local GetIcon = (C_Item and C_Item.GetItemIconByID) or GetItemIcon
							for void, button in ipairs(self.slotButtons) do
								local slotID = button.slotID
								local info = {}
								if model.GetItemTransmogInfo then
									local ok, transmog = pcall(model.GetItemTransmogInfo, model, slotID)
									local appearanceID = ok and SafeTable(transmog) and Safe(transmog.appearanceID)
									if type(appearanceID) == "number" and appearanceID > 0 then
										info.transmog = transmog
										if C_TransmogCollection and C_TransmogCollection.GetSourceInfo then
											local source = SafeTable(C_TransmogCollection.GetSourceInfo(appearanceID))
											local itemID = source and Safe(source.itemID)
											if itemID and GetIcon then info.icon = Safe(GetIcon(itemID)) end
										end
									end
								end
								if unit and Safe(UnitExists(unit)) then
									info.link = Safe(GetInventoryItemLink(unit, slotID))
									if not info.icon then info.icon = Safe(GetInventoryItemTexture(unit, slotID)) end
								end
								if info.link and not info.icon and GetIcon then info.icon = Safe(GetIcon(info.link)) end
								if info.transmog or info.link then self.slotInfo[slotID] = info end
							end
							self:UpdateSlots()
						end
						-- A player the game has not drawn in the viewer before can report the model as loaded before their gear has arrived, so the slot
						-- buttons would stay empty until the key is pressed again: read them again a few times until something is found (up to 2 seconds)
						function viewer:RetrySlots(model, unit, loadID)
							local tries = 0
							local function Retry()
								if next(self.slotInfo) or self.loadID ~= loadID or not self:IsShown() or next(self.hiddenSlots) then return end
								tries = tries + 1
								self:ReadSlots(model, unit)
								if next(self.slotInfo) then self:ApplyInspectGear() self:CheckReveal() end
								if not next(self.slotInfo) and tries < 10 then C_Timer.After(0.2, Retry) end
							end
							C_Timer.After(0.2, Retry)
						end
						-- Other players: the game does not always put every weapon on the model (such as the main hand of a dual wielder) until
						-- they have been inspected, so the weapons read by the card's own inspect are put on the model and on the slot buttons
						function viewer:ApplyInspectGear()
							local view = self.view
							if not self:IsShown() or not view or view.mode ~= "unit" or not view.isPlayer or not view.guid then return end
							local gear = LeaPlusLC.IDGear and LeaPlusLC.IDGear[view.guid]
							local model = self.dressModel
							if not gear or not model.loaded then return end
							local GetIcon = (C_Item and C_Item.GetItemIconByID) or GetItemIcon
							-- Weapons are put straight into their own hand slot as appearances (trying them on makes the game treat the player
							-- as unable to dual wield, so a weapon in one hand pushes out the other)
							local weapons = {}
							if model.SetItemTransmogInfo then
								for void, slotID in ipairs({16, 17}) do
									if gear[slotID] then
										-- The weapon's look as shown on the player (such as a transmog), if the game gives it, otherwise the item's own look
										local look = gear.looks and SafeTable(gear.looks[slotID])
										local lookID = look and Safe(look.appearanceID)
										if type(lookID) == "number" and lookID > 0 then
											weapons[slotID] = look
										elseif C_TransmogCollection and C_TransmogCollection.GetItemInfo and ItemUtil and ItemUtil.CreateItemTransmogInfo then
											local ok, void, sourceID = pcall(C_TransmogCollection.GetItemInfo, gear[slotID])
											sourceID = ok and Safe(sourceID)
											if type(sourceID) == "number" and sourceID > 0 then
												local made, transmog = pcall(ItemUtil.CreateItemTransmogInfo, sourceID)
												if made and transmog then weapons[slotID] = transmog end
											end
										end
									end
								end
							end
							local function Wield()
								if self.view ~= view or not model.loaded then return end
								for void, slotID in ipairs({16, 17}) do
									if weapons[slotID] and not self.hiddenSlots[slotID] then pcall(model.SetItemTransmogInfo, model, weapons[slotID], slotID) end
								end
							end
							if weapons[16] or weapons[17] then
								Wield()
								C_Timer.After(0.3, Wield) -- Again a moment later in case the game was still dressing the model
							end
							-- Fill in the slot buttons (weapons use the same appearances, so clicking to put one back on keeps both showing)
							for void, button in ipairs(self.slotButtons) do
								local slotID = button.slotID
								local link, info = gear[slotID], self.slotInfo[slotID]
								if link and (not info or not info.link or weapons[slotID]) then
									info = info or {}
									info.link = link
									if weapons[slotID] then info.transmog = weapons[slotID] end
									if not info.icon and GetIcon then info.icon = Safe(GetIcon(link)) end
									self.slotInfo[slotID] = info
								end
							end
							self:UpdateSlots()
						end
						-- Other players whose model comes up without a main hand (such as a paired weapon shown in both hands, which the game only gives
						-- after an inspect) are kept hidden with a message until their inspect has come back, then shown complete (players who look
						-- complete straight away are shown at once)
						function viewer:HoldModel(guid)
							self.holdGUID = guid
							self.holdID = (self.holdID or 0) + 1
							local holdID = self.holdID
							self.dressModel:SetAlpha(0)
							self.nakedModel:SetAlpha(0)
							-- Keep waiting while the inspect is on the way (up to 6 seconds), or while its reply is waiting for the player to be pointed at again
							local started = GetTime()
							local function Check()
								if self.holdID ~= holdID then return end
								local wait = LeaPlusLC.IDTalentWait
								if wait and wait.guid == guid then
									self.waitText:SetFormattedText(L["Move your mouse over %s to show their model."], self.title:GetText() or "")
									self.waitText:Show()
									C_Timer.After(0.5, Check)
									return
								end
								local card = LeaPlusLC.IDCard
								local pending = card and card:IsShown() and (card.inspectGUID == guid or card.gearReadingGUID == guid)
								if pending and GetTime() - started < 6 then C_Timer.After(0.5, Check) return end
								self:RevealModel()
							end
							C_Timer.After(1, Check)
						end
						function viewer:RevealModel()
							if not self.holdGUID then return end
							self.holdGUID = nil
							self.holdID = (self.holdID or 0) + 1
							self.dressModel:SetAlpha(1)
							self.nakedModel:SetAlpha(1)
							if self.waitGUID == nil then self.waitText:Hide() end
						end
						-- Show the model once it has a main hand, once the inspect has finished, or once no inspect is on the way
						function viewer:CheckReveal()
							local guid = self.holdGUID
							if not guid then return end
							local view = self.view
							if not self:IsShown() or not view or view.guid ~= guid then self:RevealModel() return end
							local gear = LeaPlusLC.IDGear and LeaPlusLC.IDGear[guid]
							local card = LeaPlusLC.IDCard
							local wait = LeaPlusLC.IDTalentWait
							local pending = card and card:IsShown() and (card.inspectGUID == guid or card.gearReadingGUID == guid or (wait and wait.guid == guid))
							if self.slotInfo[16] or (gear and gear.complete) or not pending then
								local holdID = self.holdID
								C_Timer.After(0.1, function() if self.holdID == holdID then self:RevealModel() end end) -- Give the weapons a moment to be drawn
							else
								-- Still waiting, so say so
								if not (wait and wait.guid == guid) then self.waitText:SetText(RETRIEVING_DATA or SEARCH_LOADING_TEXT or "...") end
								self.waitText:Show()
							end
						end
						viewer:HookScript("OnHide", function(self) self:RevealModel() end)
						viewer.animLabel = viewer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
						viewer.animLabel:SetPoint("TOPLEFT", viewer.stage, "BOTTOMLEFT", 2, -14)
						viewer.animLabel:SetText(L["Animation"])
						LeaPlusLC["IDViewerAnim"] = 1 -- Not saved
						LeaPlusLC:MakeSL(viewer, "IDViewerAnim", "", 1, #viewerAnims - 1, 1, 0, 0, "%.0f")
						viewer.anim = LeaPlusCB["IDViewerAnim"]
						viewer.anim:ClearAllPoints()
						viewer.anim:SetPoint("LEFT", viewer.animLabel, "RIGHT", 12, 0)
						viewer.anim:SetScript("OnEnter", nil)
						viewer.anim:SetScript("OnLeave", nil)
						if viewer.anim.SetObeyStepOnDrag then viewer.anim:SetObeyStepOnDrag(true) end -- Move in whole steps while dragging
						viewer.anim:HookScript("OnValueChanged", function(self, setting)
							setting = math.floor(setting + 0.5)
							-- Only change the animation when the step changes (restarting it on every small movement makes it jerky)
							if setting == viewer.lastAnim then return end
							local model = viewer.model
							if model and model.loaded and model:IsVisible() and viewerAnims[setting] then
								viewer.lastAnim = setting
								model:SetAnimation(viewerAnims[setting])
							end
						end)
						-- Flavour text
						viewer.text = viewer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
						viewer.text:SetPoint("TOPLEFT", viewer.animLabel, "BOTTOMLEFT", 0, -14)
						viewer.text:SetPoint("RIGHT", viewer, "RIGHT", -14, 0)
						viewer.text:SetJustifyH("LEFT")
						viewer.text:SetWordWrap(true)
						viewer.text:SetTextColor(1, 0.82, 0)
						-- Keep the model area filling the frame above the slider and text
						function viewer:Layout()
							local full = self.fullscreen and self.sceneBtn
							-- Flavour text: on one line along the top in fullscreen, normal lines under the slider otherwise
							local raw = self.flavourRaw
							if raw then self.text:SetText(full and (raw:gsub("\n", "     ")) or raw) end
							local count = #self.slotButtons
							local gap = 2
							if full then
								-- Fullscreen: the gear slot buttons, a shorter animation slider and the flavour text go along the top, so the model area reaches the bottom
								self.stage:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -12, 12)
								self.stageBottom = 12
								local size = 22
								self.slotRow:ClearAllPoints()
								self.slotRow:SetSize(math.max(1, count * (size + gap) - gap), size)
								self.slotRow:SetPoint("RIGHT", self.sceneBtn, "LEFT", -20, 0)
								for i, button in ipairs(self.slotButtons) do
									button:SetSize(size, size)
									button:ClearAllPoints()
									button:SetPoint("LEFT", self.slotRow, "LEFT", (i - 1) * (size + gap), 0)
								end
								self.anim:SetWidth(120)
								self.anim:ClearAllPoints()
								self.anim:SetPoint("RIGHT", self.slotRow:IsShown() and self.slotRow or self.sceneBtn, "LEFT", -40, 0) -- Room for the number after the slider
								self.animLabel:ClearAllPoints()
								self.animLabel:SetPoint("RIGHT", self.anim, "LEFT", -10, 0)
								self.text:ClearAllPoints()
								self.text:SetPoint("LEFT", self.title, "RIGHT", 16, 0)
								self.text:SetPoint("RIGHT", self.animLabel, "LEFT", -20, 0)
								self.text:SetWordWrap(false)
								-- Controls button in the bottom-right corner of the model area
								self.hint:ClearAllPoints()
								self.hint:SetPoint("BOTTOMRIGHT", self.stage, "BOTTOMRIGHT", -10, 10)
							else
								-- Controls button in the bottom-right corner of the model area (same as fullscreen)
								self.hint:ClearAllPoints()
								self.hint:SetPoint("BOTTOMRIGHT", self.stage, "BOTTOMRIGHT", -10, 10)
								-- Normal: gear slot buttons, then the animation slider, then the flavour text, all under the model area
								self.slotRow:ClearAllPoints()
								self.slotRow:SetPoint("TOPLEFT", self.stage, "BOTTOMLEFT", 0, -8)
								self.slotRow:SetPoint("TOPRIGHT", self.stage, "BOTTOMRIGHT", 0, -8)
								self.slotRow:SetHeight(22)
								-- The label was attached to the slider in fullscreen, so free it first (the slider is then attached to the label)
								self.animLabel:ClearAllPoints()
								self.animLabel:SetPoint("TOPLEFT", self.stage, "BOTTOMLEFT", 2, -14)
								self.anim:ClearAllPoints()
								self.anim:SetPoint("LEFT", self.animLabel, "RIGHT", 12, 0)
								self.text:ClearAllPoints()
								self.text:SetPoint("TOPLEFT", self.animLabel, "BOTTOMLEFT", 0, -14)
								self.text:SetPoint("RIGHT", self, "RIGHT", -14, 0)
								self.text:SetWordWrap(true)
								local text = Safe(self.text:GetText())
								local textHeight = (text and text ~= "") and (self.text:GetStringHeight() + 14) or 0
								local slotsHeight = self.slotRow:IsShown() and 30 or 0
								self.stage:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -12, 44 + textHeight + slotsHeight)
								self.stageBottom = 44 + textHeight + slotsHeight
								-- Animation slider goes under the gear slot buttons when they are showing
								self.animLabel:ClearAllPoints()
								self.animLabel:SetPoint("TOPLEFT", slotsHeight > 0 and self.slotRow or self.stage, "BOTTOMLEFT", 2, -14)
								-- Gear slot buttons share the width of the row (centred)
								if count > 0 then
									local rowWidth = self:GetWidth() - 24
									local size = math.max(10, math.min(22, math.floor((rowWidth - gap * (count - 1)) / count)))
									local left = math.floor((rowWidth - (size * count + gap * (count - 1))) / 2)
									for i, button in ipairs(self.slotButtons) do
										button:SetSize(size, size)
										button:ClearAllPoints()
										button:SetPoint("LEFT", self.slotRow, "LEFT", left + (i - 1) * (size + gap), 0)
									end
								end
								self.anim:SetWidth(math.min(500, math.max(80, self:GetWidth() - 24 - self.animLabel:GetStringWidth() - 70)))
							end
							if self.LayoutScene then self:LayoutScene() end
						end
						viewer:SetScript("OnSizeChanged", function(self) self:Layout() end)
						-- Gear button
						viewer.gear:SetScript("OnClick", function()
							local from = viewer.model
							local to = from and from.twin
							if not (from and to and from.loaded and to.loaded) then return end
							viewer.gearOff = not viewer.gearOff
							-- Swap to the other model, with the same turn, position, zoom and animation (nothing reloads, so nothing moves)
							to.facing, to.pitch, to.zoom, to.zoomTarget, to.offsetY, to.offsetZ = from.facing, from.pitch, from.zoom, from.zoomTarget, from.offsetY, from.offsetZ
							to:Show()
							to:SetFacing(to.facing or 0)
							if to.SetPitch then to:SetPitch(to.pitch or 0) end
							to:SetPosition(to.zoom or 0, to.offsetY or 0, to.offsetZ or 0)
							local setting = math.floor(viewer.anim:GetValue() + 0.5)
							if viewerAnims[setting] then to:SetAnimation(viewerAnims[setting]) end
							from:Hide()
							viewer.model = to
							viewer.gear:SetLabel(viewer.gearOff and L["Show gear"] or L["Hide gear"])
							viewer:UpdateSlots()
						end)
						viewer:Layout()
						-- Fullscreen on or off (the same viewer is made to fill the screen, so the model, slider and gear buttons all keep working)
						function viewer:SetFullscreen(on)
							on = on and true or false
							if on == (self.fullscreen or false) then return end
							local card = LeaPlusLC.IDCard
							if on then
								self.normalWidth = self:GetWidth()
								self.fullscreen = true
								-- In fullscreen the viewer goes under the card's layer (so the card can be shown over it when pointing at the name)
								-- and the card waits off the screen (still open, so Escape, the keys and the model updates all work as normal)
								self:SetParent(UIParent)
								self:SetFrameStrata("FULLSCREEN")
								card.savedPoints = {}
								for i = 1, card:GetNumPoints() do card.savedPoints[i] = {card:GetPoint(i)} end
								self:HideCard()
							else
								self.fullscreen = nil
								self:EndHoverCard() -- In case the card is showing from the name
								-- Back on top of the card, and the card back where it was
								self:SetParent(card)
								self:SetFrameStrata("FULLSCREEN_DIALOG")
								self:SetFrameLevel(card:GetFrameLevel() + 50)
								if card.savedPoints and card.savedPoints[1] then
									card:ClearAllPoints()
									for void, point in ipairs(card.savedPoints) do card:SetPoint(unpack(point)) end
								end
								card.savedPoints = nil
								card:SetClampedToScreen(true)
								self:ClearAllPoints()
								self:SetSize(self.normalWidth or PixelRound(380), self.normalHeight or PixelRound(520))
							end
							if on then self.randomScene = nil end -- A new random loading screen each time
							self:SetBackdropColor(0.06, 0.06, 0.08, on and 1 or 0.96) -- Solid in fullscreen so nothing behind shows through
							self.full:SetLabel(on and L["Exit fullscreen"] or L["Fullscreen"])
							AttachViewer()
							self:Layout()
							if not on then
								-- Back to normal size: fit the height to the flavour text again (it was on one line in fullscreen)
								local text = Safe(self.text:GetText())
								self.normalHeight = PixelRound(42 + 380 + 44 + (self.slotRow:IsShown() and 30 or 0) + ((text and text ~= "") and (self.text:GetStringHeight() + 14) or 0))
								self:SetHeight(self.normalHeight)
								AttachViewer()
							end
							self:ApplyScene()
							self:ApplyLevels()
							self:LayoutButtons()
							self:HideJournalModels(on)
						end
						-- The game draws the collection journal's own 3D previews over the fullscreen viewer, so they are made see-through
						-- while fullscreen is open, then put back as they were (only their transparency is changed, nothing else on them)
						function viewer:HideJournalModels(hide)
							if hide then
								self.journalModels = self.journalModels or {}
								-- The mount preview, the pet card preview and the three battle pet slots
								local scenes = {
									MountJournal and MountJournal.MountDisplay and MountJournal.MountDisplay.ModelScene,
									PetJournalPetCard and PetJournalPetCard.modelScene,
								}
								local loadout = PetJournal and PetJournal.Loadout
								if loadout then
									for i = 1, 3 do
										local plate = loadout["Pet" .. i]
										if plate and plate.modelScene then tinsert(scenes, plate.modelScene) end
									end
								end
								for void, scene in pairs(scenes) do
									if scene and not (scene.IsForbidden and scene:IsForbidden()) and self.journalModels[scene] == nil then
										self.journalModels[scene] = scene:GetAlpha()
										scene:SetAlpha(0)
									end
								end
							elseif self.journalModels then
								for scene, alpha in pairs(self.journalModels) do scene:SetAlpha(alpha) end
								wipe(self.journalModels)
							end
						end
						-- Background scenes for fullscreen (plain colours, racial dressing room backgrounds and class talent backgrounds)
						-- Each picture is made of pieces: position and size of each piece in the picture, then its texture coordinates
						local loadLayout = {w = 1024, h = 768, fit = true, pieces = {{0, 0, 1024, 768, 0, 1, 0, 1}}} -- Loading screens (4:3, shown whole: fit = true, or topCrop = 0.27 to fill the area and crop the logo off)
						local wideLayout = {w = 1600, h = 900, pieces = {{0, 0, 1600, 900, 0, 1, 0, 1}}} -- Widescreen loading screens (the game stretches the whole picture across a widescreen, so it is shown at 16:9)
						local letterboxLayout = {w = 1600, h = 900, pieces = {{0, 0, 1600, 900, 0.157, 0.843, 0.157, 0.843}}} -- WoW Forever loading screens (16:9 with black bands painted across the top and bottom): the bands are cropped off and the sides are trimmed to match, so they fill the same 16:9 space as the other loading screens
						local logoLayout = {w = 1600, h = 900, pieces = {{0, 0, 1600, 900, 0.22, 0.78, 0.29, 0.85}}} -- Legion and Battle for Azeroth loading screens: the logo and the frame painted across the top and bottom are cropped off, and the sides are trimmed to match, so they fill the same 16:9 space
						-- Check a picture is in the game (by its file ID, or by trying to load it)
						local probe = viewer:CreateTexture(nil, "BACKGROUND")
						probe:Hide()
						local function FileExists(path)
							if GetFileIDFromPath then return GetFileIDFromPath(path) ~= nil end
							local loaded = probe:SetTexture(path)
							probe:SetTexture(nil)
							if loaded == false then return false end
							return true
						end
						local scenes, sceneByKey = {}, {}
						local function AddScene(scene)
							-- Some pictures have more than one possible file name, the first one in the game is used
							if scene.candidates then
								for void, base in ipairs(scene.candidates) do
									if FileExists(base) then scene.files = {base} break end
								end
								if not scene.files then return end
							end
							if scene.files and not FileExists(scene.files[1]) then return end -- Scenes this game does not have are left out
							tinsert(scenes, scene)
							if scene.key then sceneByKey[scene.key] = scene end
						end
						sceneByKey.random = {key = "random", name = L["Random"]} -- Not in the list: used when no scene has been chosen (a different loading screen each time fullscreen is opened)
						AddScene({key = "none", name = L["None"]})
						AddScene({header = L["Patterns"]})
						AddScene({key = "grey", name = L["Studio grey"], gradient = {0.10, 0.10, 0.11, 0.42, 0.42, 0.45}})
						AddScene({key = "night", name = L["Night sky"], gradient = {0.10, 0.16, 0.32, 0.01, 0.02, 0.06}})
						AddScene({key = "sunset", name = L["Sunset"], gradient = {0.85, 0.45, 0.20, 0.18, 0.06, 0.10}})
						-- Loading screens grouped by expansion (file names from the community listfile, only widescreen ones are used)
						-- Each entry: zone ID for the game's own zone name (or nil), English name, then the files to try in order
						-- A file marked wide, letterbox or logo is widescreen (letterbox and logo ones are cropped); any other file is a 4:3 one, and only its widescreen version (Wide on the end) is used if the game has one
						local function ExpansionName(number, english) return _G["EXPANSION_NAME" .. number] or L[english] end
						local function AddLoadingScreen(screen)
							local zoneName = screen[1] and GetRealZoneText and Safe(GetRealZoneText(screen[1]))
							if type(zoneName) ~= "string" or zoneName == "" then zoneName = L[screen[2]] end
							local base, files, layout = "Interface\\Glues\\LoadingScreens\\"
							for void, candidate in ipairs(screen[3]) do
								local file, kind = candidate[1], candidate[2]
								if kind == "wide" or kind == "letterbox" or kind == "logo" then
									if FileExists(base .. file) then files, layout = {base .. file}, kind == "letterbox" and letterboxLayout or kind == "logo" and logoLayout or wideLayout end
								elseif FileExists(base .. file .. "Wide") then
									files, layout = {base .. file .. "Wide"}, wideLayout
								end
								if files then break end
							end
							if files then AddScene({key = "load" .. screen[3][1][1], name = zoneName .. (screen[4] or ""), layout = layout, files = files, isLoad = true}) end
						end
						for void, group in ipairs({
							{L["WoW Forever"], {
								{1, "Kalimdor", {{"Camelot160\\Main\\loadscreen_camelot_kalimdor", "letterbox"}}},
								{0, "Eastern Kingdoms", {{"Camelot160\\Main\\loadscreen_camelot_easternkingdom", "letterbox"}}},
								{nil, "Dalaran", {{"Camelot160\\Main\\loadscreen_camelot_dalaran", "letterbox"}}},
								{nil, "Old Ironforge", {{"Camelot160\\Main\\loadscreen_camelot_oldironforge", "letterbox"}}},
								{nil, "Ruins of Lordaeron", {{"Camelot160\\Main\\loadscreen_camelot_ruinsoflordaeron", "letterbox"}}},
								{nil, "Zephras Isle", {{"Camelot160\\Main\\loadscreen_camelot_zephrasisle", "letterbox"}}},
								{nil, "Excavation", {{"Camelot160\\Main\\loadscreen_camelot_excavation", "letterbox"}}},
							}},
							{ExpansionName(6, "Legion"), {
								{nil, "Broken Isles", {{"LoadingScreen_BrokenIsles_Wide", "logo"}}},
								{nil, "Mardum", {{"loadingscreen_mardumwide", "logo"}}},
								{nil, "Death Knight Order Hall", {{"LoadScreen_DeathKnightOrderHall_wide", "logo"}}},
								{nil, "Demon Hunter Order Hall", {{"LoadingScreen_DemonHunterOrderHall_wide", "logo"}}},
								{nil, "Druid Order Hall", {{"LoadingScreen_DruidOrderHall_Wide", "logo"}}},
								{nil, "Hunter Order Hall", {{"LoadScreen_HunterOrderHall_wide", "logo"}}},
								{nil, "Monk Order Hall", {{"LoadScreen_MonkOrderHall_Wide_NoLOGO", "logo"}}},
								{nil, "Priest Order Hall", {{"LoadScreen_PriestOrderHall_wide", "logo"}}},
								{nil, "Warlock Order Hall", {{"LoadScreen_WarlockOrderHall_wide", "logo"}}},
								{nil, "Mage Artifact", {{"LoadScreen_MageArtifact", "logo"}}},
								{nil, "Shaman Artifact", {{"Loadingscreen_shamanartifact_wide", "logo"}}},
								{nil, "Niskara", {{"Loadingscreen_Niskara_wide", "logo"}}},
								{nil, "Light's Hope Chapel", {{"LoadingScreen_LightHopesChapel_wide", "logo"}}},
								{nil, "Eye of Azshara", {{"LoadScreen_NagaDungeon", "logo"}}},
								{nil, "Darkheart Thicket", {{"LoadingScreen_NightmareDungeon_wide", "logo"}}},
								{nil, "Neltharion's Lair", {{"LoadingScreen_NeltharionsLair_wide", "logo"}}},
								{nil, "Halls of Valor", {{"LoadingScreen_HallsofValor_wide", "logo"}}},
								{nil, "Helheim", {{"LoadingScreen_Helheimship_wide", "logo"}}},
								{nil, "Black Rook Hold", {{"LoadingScreen_BlackrookHold_wide", "logo"}}},
								{nil, "Vault of the Wardens", {{"LoadingScreen_VaultOfTheWardens_wide", "logo"}}},
								{nil, "Violet Hold", {{"Loadingscreen_VioletHold_wide", "logo"}}},
								{nil, "Court of Stars", {{"LoadScreen_SuramarCityDungeon", "logo"}}},
								{nil, "Suramar Catacombs", {{"LoadScreen_SuramarCatacombs_wide", "logo"}}},
								{nil, "Return to Karazhan", {{"LoadingScreen_ReturntoKarazhan", "logo"}}},
								{nil, "Cathedral of Eternal Night", {{"LoadScreen_TombOfSargerasDUNGEON_wide", "logo"}}},
								{nil, "The Emerald Nightmare", {{"LoadScreen_EmeraldNightmareRaid_wide", "logo"}}},
								{nil, "Emerald Dreamway", {{"LoadingScreen_EmeraldDreamway_wide", "logo"}}},
								{nil, "Trial of Valor", {{"LoadingScreen_TrialsofValor", "logo"}}},
								{nil, "The Nighthold", {{"LoadScreen_SuramarRaid", "logo"}}},
								{nil, "Tomb of Sargeras", {{"LoadScreen_TombOfSargerasRAID_wide", "logo"}}},
								{nil, "Argus", {{"LoadingScreen_Argus3", "logo"}}},
								{nil, "Krokuun", {{"LoadingScreen_Krokuun_wide", "logo"}}},
								{nil, "Mac'Aree", {{"LoadingScreen_MacAree_wide", "logo"}}},
								{nil, "Seat of the Triumvirate", {{"LoadingScreen_ArgusDungeon_Widescreen", "logo"}}},
								{nil, "Antorus, the Burning Throne", {{"LoadingScreen_ArgusRaid_Widescreen", "logo"}}},
								{nil, "Chromie's Scenario", {{"LoadScreen_ChromieScenario_wide", "logo"}}},
								{nil, "Black Rook Hold Arena", {{"LoadingScreen_BlackrookHoldArena_wide", "logo"}}},
								{nil, "Blade's Edge Arena", {{"LoadingScreen_BladesEdgeArena_wide", "logo"}}},
								{nil, "Nagrand Arena", {{"LoadingScreen_NagrandArena_wide", "logo"}}},
								{nil, "Val'sharah Arena", {{"LoadingScreen_ArenaValSharah_wide", "logo"}}},
								{529, "Arathi Basin", {{"Loadingscreen_ArathiBasinwinter", "logo"}}, " (winter)"},
							}},
							{ExpansionName(7, "Battle for Azeroth"), {
								{489, "Warsong Gulch", {{"loadscreen_warsonggulch_update_wide", "logo"}}},
								{529, "Arathi Basin", {{"loadingscreen_arathibasin_update_wide", "logo"}}},
							}},
						}) do
							AddScene({header = group[1]})
							for void, screen in ipairs(group[2]) do AddLoadingScreen(screen) end
						end
						-- Leave out headings with nothing under them
						for i = #scenes, 1, -1 do
							if scenes[i].header and (not scenes[i + 1] or scenes[i + 1].header) then tremove(scenes, i) end
						end
						-- Chosen scene (saved)
						if LeaPlusLC.IDViewerScene == nil then LeaPlusLC.IDViewerScene = LeaPlusDB and LeaPlusDB["IDViewerScene"] or "random" end
						-- Scene area: fills the model area, clipped to it, under the models
						viewer.sceneFrame = CreateFrame("Frame", nil, viewer)
						viewer.sceneFrame:SetAllPoints(viewer.stage)
						viewer.sceneFrame:SetClipsChildren(true)
						viewer.sceneFrame:Hide()
						viewer.sceneCanvas = CreateFrame("Frame", nil, viewer.sceneFrame)
						-- Softening: the picture is drawn several times, each slightly offset and blended evenly, which smooths out the blocks of low quality pictures
						local softOffsets = {{0, 0}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {-1, -1}, {1, -1}, {-1, 1}}
						viewer.sceneLayers = {}
						for k = 1, #softOffsets do
							viewer.sceneLayers[k] = {}
							for i = 1, 4 do viewer.sceneLayers[k][i] = viewer.sceneCanvas:CreateTexture(nil, "BACKGROUND", nil, k - 9) end -- Later copies on top
						end
						viewer.sceneDim = viewer.sceneCanvas:CreateTexture(nil, "OVERLAY")
						viewer.sceneDim:SetAllPoints(viewer.sceneCanvas)
						viewer.sceneDim:SetColorTexture(0, 0, 0, 1)
						viewer.sceneGradient = viewer.sceneFrame:CreateTexture(nil, "BACKGROUND")
						viewer.sceneGradient:SetAllPoints()
						viewer.sceneGradient:SetTexture("Interface\\Buttons\\WHITE8X8")
						-- Text in the model area is moved to its own layer so it stays above the scene and the models
						viewer.overlay = CreateFrame("Frame", nil, viewer)
						viewer.overlay:SetAllPoints(viewer)
						viewer.hint:SetParent(viewer.overlay)
						viewer.waitText:SetParent(viewer.overlay)
						-- Scene button (only shown in fullscreen)
						viewer.sceneBtn = FlatButton(viewer, 200, 22, "")
						viewer.sceneBtn.label:SetWidth(188)
						viewer.sceneBtn.label:SetWordWrap(false)
						viewer.sceneBtn:Hide()
						viewer.sceneBtn:SetScript("OnClick", function() viewer:ToggleScenePopup() end)
						viewer.sceneBtn:HookScript("OnShow", function() viewer:LayoutButtons() end)
						viewer.sceneBtn:HookScript("OnHide", function() viewer:LayoutButtons() end)
						-- Keep the layers in order: scene, then models, then text and buttons, then the scene list
						function viewer:ApplyLevels()
							local base = self:GetFrameLevel()
							self.sceneFrame:SetFrameLevel(base + 1)
							self.sceneCanvas:SetFrameLevel(base + 2)
							for void, model in ipairs({self.dressModel, self.nakedModel, self.creatureModel}) do model:SetFrameLevel(base + 5) end
							self.overlay:SetFrameLevel(base + 6)
							self.gear:SetFrameLevel(base + 7)
							self.full:SetFrameLevel(base + 7)
							self.sceneBtn:SetFrameLevel(base + 7)
							self.hint:SetFrameLevel(base + 7)
							if self.scenePopup then self.scenePopup:SetFrameLevel(base + 20) end
						end
						-- Size the scene picture to fill the model area (edges are cropped so nothing is stretched)
						function viewer:LayoutScene()
							local scene = self.currentScene
							if not scene or not scene.layout or not self.sceneFrame:IsShown() then return end
							local w, h = self:GetWidth() - 24, self:GetHeight() - 42 - (self.stageBottom or 44)
							if w <= 0 or h <= 0 then return end
							local layout = scene.layout
							local scale = math.min(w / layout.w, h / layout.h) -- Never zoomed in: the whole picture is always shown (dark bars where it does not reach)
							self.sceneCanvas:SetSize(layout.w * scale, layout.h * scale)
							self.sceneCanvas:ClearAllPoints()
							self.sceneCanvas:SetPoint("CENTER", self.sceneFrame, "CENTER", 0, 0)
							local spread = scene.soft and (scale * 0.75) or 0 -- About one picture pixel
							for k, layer in ipairs(self.sceneLayers) do
								local used = k == 1 or scene.soft
								for i, piece in ipairs(layer) do
									local spec = layout.pieces[i]
									if used and spec then
										piece:ClearAllPoints()
										piece:SetPoint("TOPLEFT", self.sceneCanvas, "TOPLEFT", spec[1] * scale + softOffsets[k][1] * spread, -spec[2] * scale + softOffsets[k][2] * spread)
										piece:SetSize(spec[3] * scale, spec[4] * scale)
									end
								end
							end
						end
						-- Show the chosen scene (fullscreen only)
						function viewer:ApplyScene()
							local scene = sceneByKey[self.previewKey or LeaPlusLC.IDViewerScene] or sceneByKey.random -- Hovered scene in the list, or the chosen one (a saved scene no longer in the list uses the default)
							local label = scene.name
							if scene.key == "random" then
								-- Pick a loading screen (a new one each time fullscreen is opened, or when Random is chosen again)
								if not self.randomScene then
									local choices = {}
									for void, entry in ipairs(scenes) do if entry.isLoad then tinsert(choices, entry) end end
									self.randomScene = choices[1] and choices[math.random(#choices)] or sceneByKey.none
								end
								scene = self.randomScene
								label = L["Random"] .. ": " .. scene.name
							end
							self.currentScene = scene
							self.sceneBtn:SetLabel(L["Scene"] .. ": " .. label)
							self.sceneBtn:SetShown(self.fullscreen and true or false)
							if not self.fullscreen and self.scenePopup then self.scenePopup:Hide() end
							local show = self.fullscreen and scene.key ~= "none"
							self.sceneFrame:SetShown(show and true or false)
							if not show then return end
							if scene.gradient then
								local g = scene.gradient
								self.sceneCanvas:Hide()
								self.sceneGradient:Show()
								self.sceneGradient:SetGradient("VERTICAL", CreateColor(g[1], g[2], g[3], 1), CreateColor(g[4], g[5], g[6], 1))
							else
								self.sceneGradient:Hide()
								self.sceneCanvas:Show()
								for k, layer in ipairs(self.sceneLayers) do
									local used = k == 1 or scene.soft
									for i, piece in ipairs(layer) do
										local spec = scene.layout.pieces[i]
										if used and spec then
											piece:SetTexture(scene.files[i], nil, nil, "TRILINEAR") -- Smooth filtering when the picture is enlarged
											piece:SetTexCoord(spec[5], spec[6], spec[7], spec[8])
											piece:SetAlpha(1 / k) -- Each copy blended in evenly with the ones under it
											piece:Show()
										else
											piece:Hide()
										end
									end
								end
								self.sceneDim:SetAlpha(scene.soft and 0.25 or 0) -- Softened pictures are darkened a little so the model stands out
								self:LayoutScene()
							end
						end
						-- Scene list (Leatrix's own list, not the game's dropdown menus)
						function viewer:ToggleScenePopup()
							local popup = self.scenePopup
							if popup and popup:IsShown() then popup:Hide() return end
							if not popup then
								popup = CreateFrame("Frame", nil, self, "BackdropTemplate")
								self.scenePopup = popup
								popup:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
								popup:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
								popup:SetBackdropBorderColor(1, 1, 1, 0.15)
								popup:EnableMouse(true)
								popup.rows = {}
								local rowHeight, colWidth = 18, 190
								local maxRows = math.max(10, math.floor((self:GetHeight() - 70) / rowHeight)) -- Columns nearly as tall as the screen, so the list is as narrow as possible
								local col, row, mostRows = 0, 0, 0
								for i, scene in ipairs(scenes) do
									-- Start a new column when this one is full (a heading always has at least one entry under it)
									if row >= maxRows or (scene.header and row >= maxRows - 1) then col, row = col + 1, 0 end
									if scene.header then
										local text = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
										text:SetPoint("TOPLEFT", popup, "TOPLEFT", 14 + col * colWidth, -13 - row * rowHeight)
										text:SetText(scene.header)
									else
										local button = CreateFrame("Button", nil, popup)
										button:SetSize(colWidth - 8, rowHeight)
										button:SetPoint("TOPLEFT", popup, "TOPLEFT", 8 + col * colWidth, -10 - row * rowHeight)
										button.selected = button:CreateTexture(nil, "BACKGROUND")
										button.selected:SetAllPoints()
										button.selected:SetColorTexture(1, 1, 1, 0.12)
										button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
										button:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.08)
										button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
										button.text:SetPoint("LEFT", button, "LEFT", 6, 0)
										button.text:SetPoint("RIGHT", button, "RIGHT", -4, 0)
										button.text:SetJustifyH("LEFT")
										button.text:SetWordWrap(false)
										button.text:SetText(scene.name)
										button.key = scene.key
										-- Pointing at a scene shows it straight away (pointing at Random shows another random loading screen)
										button:SetScript("OnEnter", function(self)
											if viewer.previewKey == self.key and self.key ~= "random" then return end
											viewer.previewKey = self.key
											if self.key == "random" then viewer.randomScene = nil end
											viewer:ApplyScene()
										end)
										-- Clicking keeps the scene being shown
										button:SetScript("OnClick", function(self)
											LeaPlusLC.IDViewerScene = self.key
											if LeaPlusDB then LeaPlusDB["IDViewerScene"] = self.key end
											popup.confirmed = true
											popup:Hide()
										end)
										tinsert(popup.rows, button)
									end
									row = row + 1
									mostRows = math.max(mostRows, row)
								end
								popup:SetSize((col + 1) * colWidth + 8, mostRows * rowHeight + 20)
								popup:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -36) -- Far right, just under the buttons
								-- Like the game's own menus, the list stays open until something else is clicked (or Escape is pressed)
								popup:RegisterEvent("GLOBAL_MOUSE_DOWN")
								popup:SetScript("OnEvent", function(self, event)
									if event == "GLOBAL_MOUSE_DOWN" and self:IsShown() and not self:IsMouseOver() and not viewer.sceneBtn:IsMouseOver() then self:Hide() end
								end)
								-- Scenes only change while pointing at the list: moving the pointer off it puts the chosen scene back (until one is clicked)
								popup:SetScript("OnUpdate", function(self)
									if viewer.previewKey and not self:IsMouseOver() then
										viewer.previewKey = nil
										viewer.randomScene = self.randomBefore
										viewer:ApplyScene()
									end
								end)
								-- Closing the list keeps a clicked scene, otherwise goes back to the scene that was showing before
								popup:SetScript("OnHide", function()
									if not popup.confirmed then viewer.randomScene = popup.randomBefore end
									popup.confirmed, popup.randomBefore = nil, nil
									viewer.previewKey = nil
									viewer:ApplyScene()
								end)
							end
							for void, button in ipairs(popup.rows) do button.selected:SetShown(button.key == LeaPlusLC.IDViewerScene or (button.key == "random" and not sceneByKey[LeaPlusLC.IDViewerScene])) end
							popup.confirmed, popup.randomBefore = nil, self.randomScene -- Remember the random loading screen in case nothing is clicked
							self:ApplyLevels()
							popup:Show()
						end
						viewer:ApplyLevels()
						-- Fullscreen: the card waits off the screen, and pointing at the name shows it just under the name
						function viewer:HideCard()
							local card = LeaPlusLC.IDCard
							card:SetClampedToScreen(false) -- Otherwise the game pulls it back onto the screen (into the bottom-left corner)
							card:ClearAllPoints()
							card:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -4000, -4000)
						end
						viewer.titleHover = CreateFrame("Frame", nil, viewer)
						viewer.titleHover:SetAllPoints(viewer.title)
						viewer.titleHover:EnableMouse(true)
						-- Highlight behind the name while pointing at it (fullscreen only, so it is clear the name shows the card)
						viewer.titleHover.highlight = viewer:CreateTexture(nil, "ARTWORK") -- On the viewer itself so it sits behind the name
						viewer.titleHover.highlight:SetPoint("TOPLEFT", viewer.titleHover, "TOPLEFT", -6, 4)
						viewer.titleHover.highlight:SetPoint("BOTTOMRIGHT", viewer.titleHover, "BOTTOMRIGHT", 6, -4)
						viewer.titleHover.highlight:SetColorTexture(1, 1, 1, 0.12)
						viewer.titleHover.highlight:Hide()
						-- The card shown from the name is for reading only: the buff list, close button, 3D model box, hints and clicks are all left out
						local function CardControls(card)
							return {card.close, card.modelCheck, card.modelCheck.label, card.hint, card.hint2, LeaPlusLC.AuraPicker}
						end
						local function PlainCard(card, plain)
							if plain then
								card.plainHidden = {}
								for i, control in ipairs(CardControls(card)) do
									if control and control:IsShown() then card.plainHidden[i] = true control:Hide() end
								end
							elseif card.plainHidden then
								for i, control in ipairs(CardControls(card)) do
									if control and card.plainHidden[i] then control:Show() end
								end
								card.plainHidden = nil
							end
							card:EnableMouse(not plain)
							card.edit:EnableMouse(not plain)
						end
						viewer.titleHover:SetScript("OnEnter", function()
							if not viewer.fullscreen or viewer.cardShowing then return end
							viewer.titleHover.highlight:Show()
							local card = LeaPlusLC.IDCard
							PlainCard(card, true)
							card:ClearAllPoints()
							card:SetPoint("TOPLEFT", viewer.title, "BOTTOMLEFT", 8, -20)
							card:SetClampedToScreen(true)
							card:Raise()
							viewer.cardShowing, viewer.cardAway = true, 0
						end)
						-- The card goes as soon as the pointer leaves the name (and everything on it comes back for when fullscreen ends)
						function viewer:EndHoverCard()
							if not self.cardShowing then return end
							self.cardShowing = nil
							self.titleHover.highlight:Hide()
							PlainCard(LeaPlusLC.IDCard, false)
							if self.fullscreen then self:HideCard() end
						end
						-- The card stays while the pointer is over the name or the card, and goes a short moment after it leaves both
						viewer.titleHover:SetScript("OnUpdate", function(self, elapsed)
							if not viewer.cardShowing then return end
							if self:IsMouseOver() or LeaPlusLC.IDCard:IsMouseOver() then
								viewer.cardAway = 0
							else
								viewer.cardAway = viewer.cardAway + elapsed
								if viewer.cardAway > 0.3 then viewer:EndHoverCard() end
							end
						end)
						viewer:HookScript("OnHide", function(self) if self.fullscreen then self:SetFullscreen(false) end end)
						viewer:LayoutButtons()
						LeaPlusLC.IDViewer = viewer
					end
					-- Nothing changes on the model unless the viewer is showing (or being opened now)
					if not info.openViewer and not viewer:IsShown() then return end
					-- Do not change models more than about three times a second (pressing the key quickly loads the last one)
					local now = GetTime()
					if viewer.lastLoad and now - viewer.lastLoad < 0.35 then
						viewer.pendingInfo = info
						info.openViewer = true
						if not viewer.pendingTimer then
							viewer.pendingTimer = true
							C_Timer.After(0.35 - (now - viewer.lastLoad), function()
								viewer.pendingTimer = nil
								local pending = viewer.pendingInfo
								viewer.pendingInfo = nil
								if pending and LeaPlusLC.IDCard and LeaPlusLC.IDCard:IsShown() and LeaPlusLC.IDCard.info == pending then ShowViewer(pending) end
							end)
						end
						return
					end
					viewer.lastLoad = now
					-- Choose the model frames (NPCs, pets and mounts use the plain model, players and items use the two dressing room models)
					local useCreature = (view.mode == "unit" and not view.isPlayer) or view.mode == "display"
					local models = useCreature and {viewer.creatureModel} or {viewer.dressModel, viewer.nakedModel}
					for void, other in ipairs(useCreature and {viewer.dressModel, viewer.nakedModel} or {viewer.creatureModel}) do
						other:Hide()
						other.loaded, other.onLoaded = false, nil
					end
					-- Find the unit again by its GUID (the mouse may have moved since the card was shown)
					local unit
					if view.mode == "unit" then
						if view.guid and issecretvalue and issecretvalue(view.guid) then view.guid = nil end
						-- Shown at the same moment as the card: use the card's own unit (searching again can fail for new characters)
						if view.fresh and view.unit and UnitExists(view.unit) then unit = view.unit end
						if not unit and view.guid then
							local tokens = {"mouseover", view.unit or "mouseover", "target", "focus", "targettarget", "pet", "party1", "party2", "party3", "party4"}
							for i = 1, 40 do tinsert(tokens, "nameplate" .. i) end
							if IsInRaid() then for i = 1, 40 do tinsert(tokens, "raid" .. i) end end
							for void, token in ipairs(tokens) do
								local tokenGUID = UnitExists(token) and UnitGUID(token)
								if tokenGUID and not (issecretvalue and issecretvalue(tokenGUID)) and tokenGUID == view.guid then unit = token break end
							end
						end
					end
					-- Show the viewer first, then load the model
					local r, g, b = unpack(info.color or {1, 0.82, 0})
					viewer:SetBackdropBorderColor(r, g, b, 0.55)
					viewer.gear:SetAccent(r, g, b)
					viewer.hint:SetAccent(r, g, b)
					viewer.accent = {r, g, b}
					viewer.title:SetText(info.name or "")
					if info.nameColor then viewer.title:SetTextColor(unpack(info.nameColor)) else viewer.title:SetTextColor(1, 1, 1) end
					viewer.flavourRaw = view.text or ""
					viewer.text:SetText(view.text or "")
					if info.offscreen ~= nil then viewer.offscreen = info.offscreen end
					viewer.slotRow:SetShown(not useCreature and viewer.dressModel.UndressSlot ~= nil) -- Gear slot buttons for players and items
					viewer:Show()
					do
						local text = view.text
						viewer.normalHeight = PixelRound(42 + 380 + 44 + (viewer.slotRow:IsShown() and 30 or 0) + ((text and text ~= "") and (viewer.text:GetStringHeight() + 14) or 0))
						if not viewer.fullscreen then viewer:SetHeight(viewer.normalHeight) end
					end
					AttachViewer()
					viewer:Layout()
					viewer.view = view
					viewer.gearOff = (view.mode == "item") -- Items are shown on your character with your own gear off
					viewer.gear:SetLabel(viewer.gearOff and L["Show gear"] or L["Hide gear"])
					viewer.gear:SetShown(not useCreature) -- NPCs and pets have no gear to change
					wipe(viewer.slotInfo) wipe(viewer.hiddenSlots) viewer:UpdateSlots() -- Filled in once the model has loaded
					viewer:LayoutButtons()
					viewer:RevealModel() -- Start from a shown model (it is hidden again below for players whose inspect is on the way)
					-- A player who cannot be found right now: wait until the mouse is over them again
					if view.mode == "unit" and not unit and not view.npcID then
						viewer.waitGUID = view.guid or false
						viewer.waitName = info.name
						for void, m in ipairs({viewer.dressModel, viewer.nakedModel, viewer.creatureModel}) do m:Hide() m.loaded = false end
						viewer.hint:Hide()
						viewer.gear:Hide()
						viewer.waitText:SetFormattedText(L["Move your mouse over %s to show their model."], info.name or "")
						viewer.waitText:Show()
						-- Also check a few times a second, as the game can be slow to register the character under the mouse
						if not viewer.waitTicker then
							viewer.waitTicker = C_Timer.NewTicker(0.2, function(ticker)
								if not viewer:IsShown() or viewer.waitGUID == nil then ticker:Cancel() viewer.waitTicker = nil return end
								viewer:CheckWaiting()
							end)
						end
						return
					end
					-- Cannot be seen (too far away, offline and so on): do not load a model (it can make the game pause), just say so
					if view.mode == "unit" and unit and not Safe(UnitIsVisible(unit)) then
						viewer.waitGUID = nil
						for void, m in ipairs({viewer.dressModel, viewer.nakedModel, viewer.creatureModel}) do m:Hide() m.loaded = false end
						viewer.hint:Hide()
						viewer.gear:Hide()
						viewer.waitText:SetFormattedText(L["No model is available for %s right now."], info.name or "")
						viewer.waitText:Show()
						return
					end
					viewer.waitGUID = nil
					viewer.waitText:Hide()
					viewer.hint:Show()
					if view.mode == "unit" and view.isPlayer and unit and view.guid and not Safe(UnitIsUnit(unit, "player")) then viewer:HoldModel(view.guid) end
					viewer.loadID = (viewer.loadID or 0) + 1 -- Changes from an earlier model are ignored
					local loadID = viewer.loadID
					viewer.lastAnim = nil
					-- The model shown first (items start with your gear off)
					local active = useCreature and viewer.creatureModel or (viewer.gearOff and viewer.nakedModel or viewer.dressModel)
					viewer.model = active
					for void, model in ipairs(models) do
						model.loaded, model.onLoaded = false, nil
						model.facing, model.zoom, model.zoomTarget, model.turning, model.panX, model.panY, model.offsetY, model.offsetZ = 0, 0, 0, nil, nil, nil, 0, 0
						model.pitch, model.freeX, model.freeY = 0, nil, nil
						local function Finish()
							if not model:IsVisible() or viewer.loadID ~= loadID then return end
							model:SetFacing(0)
							if model.SetPitch then model:SetPitch(0) end
							model:SetPosition(0, 0, 0)
							if model == viewer.nakedModel and model.Undress then model:Undress() end
							if view.mode == "item" and view.link then model:TryOn(view.link) end
							-- Both dressing room models are loaded while showing (safest), then the one not in use is hidden
							if model == viewer.dressModel then
								viewer:ReadSlots(model, (view.mode == "unit" and unit) or "player")
								if view.mode == "unit" and not next(viewer.slotInfo) then viewer:RetrySlots(model, unit, loadID) end
								viewer:ApplyInspectGear()
								viewer:CheckReveal()
							end
							if model ~= viewer.model then model:Hide() end
						end
						model:Show()
						if view.mode == "unit" and unit then
							model:SetUnit(unit, false, false) -- The form they are in now (such as a Dracthyr's visage form, drawn as their dragon form otherwise)
						elseif view.mode == "unit" then
							model:SetCreature(tonumber(view.npcID))
						elseif view.mode == "display" then
							model:SetDisplayInfo(view.displayID) -- Mounts and pets from the journals
						else
							model:SetUnit("player", false, PlayerUtil and PlayerUtil.ShouldUseNativeFormInModelScene and PlayerUtil.ShouldUseNativeFormInModelScene() or false) -- Your current form, the same as the dressing room
						end
						model:WhenLoaded(Finish)
					end
					viewer.anim:SetValue(1)
				end
				-- ID card: shows the icon, name, ID and Wowhead link for what is under the mouse
				local function ShowIDCard(info)
					-- Leave out anything the game hides, so the card never shows or measures a hidden value
					info.name, info.sub, info.note, info.id, info.url, info.icon, info.unit = Safe(info.name, info.sub, info.note, info.id, info.url, info.icon, info.unit)
					if info.view then
						local view = info.view
						view.text, view.icon, view.link, view.guid, view.npcID, view.unit, view.displayID = Safe(view.text, view.icon, view.link, view.guid, view.npcID, view.unit, view.displayID)
						if view.mode == "display" and type(view.displayID) ~= "number" then info.view = nil end -- No model to show
					end
					local card = LeaPlusLC.IDCard
					if not card then
						card = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
						card:Hide()
						card:SetSize(480, 140)
						card:SetPoint("TOP", UIParent, "BOTTOM", 0, UIParent:GetHeight() * 0.28) -- Lower part of the screen, above the action bars
						SnapToPixels(card)
						card:SetFrameStrata("FULLSCREEN_DIALOG")
						card:SetFrameLevel(5000)
						card:SetClampedToScreen(true)
						card:EnableMouse(true)
						card:SetScript("OnMouseDown", function(self, btn) if btn == "RightButton" then self:Hide() end end)
						card:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
						card:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
						-- Soft glow along the top in the accent colour
						card.glow = card:CreateTexture(nil, "BORDER")
						card.glow:SetPoint("TOPLEFT", card, "TOPLEFT", 1, -1)
						card.glow:SetPoint("TOPRIGHT", card, "TOPRIGHT", -1, -1)
						card.glow:SetHeight(70)
						card.glow:SetTexture("Interface\\Buttons\\WHITE8X8")
						-- Icon with a thin accent border
						card.iconBorder = card:CreateTexture(nil, "ARTWORK")
						card.iconBorder:SetSize(58, 58)
						card.iconBorder:SetPoint("TOPLEFT", card, "TOPLEFT", 20, -16)
						card.icon = card:CreateTexture(nil, "OVERLAY")
						card.icon:SetPoint("TOPLEFT", card.iconBorder, "TOPLEFT", 2, -2)
						card.icon:SetPoint("BOTTOMRIGHT", card.iconBorder, "BOTTOMRIGHT", -2, 2)
						-- 3D portrait for players and NPCs (a plain model framed on the face, over the flat portrait)
						card.portraitBg = card:CreateTexture(nil, "ARTWORK", nil, 2) -- Dark backdrop behind the 3D portrait (instead of the round flat portrait)
						card.portraitBg:SetAllPoints(card.icon)
						card.portraitBg:SetTexture("Interface\\Buttons\\WHITE8X8")
						card.portraitBg:SetGradient("VERTICAL", CreateColor(0.03, 0.03, 0.04, 1), CreateColor(0.14, 0.14, 0.17, 1))
						card.portraitBg:Hide()
						card.portrait = CreateFrame("PlayerModel", nil, card)
						card.portrait:SetAllPoints(card.icon)
						card.portrait:Hide()
						card.portrait:SetScript("OnModelLoaded", function(self)
							local id = self.loadID
							-- Frame the face on the next frame (never in the middle of loading)
							C_Timer.After(0, function()
								if self.loadID == id and self:IsVisible() then
									self:SetPortraitZoom(1)
									self:SetPosition(0, 0, 0)
									self:SetFacing(0)
								end
							end)
						end)
						-- Type (top right), name and details
						card.kind = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
						card.kind:SetPoint("TOPRIGHT", card, "TOPRIGHT", -36, -16)
						card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
						card.title:SetPoint("TOPLEFT", card.iconBorder, "TOPRIGHT", 14, -4)
						card.title:SetPoint("RIGHT", card.kind, "LEFT", -10, 0)
						card.title:SetJustifyH("LEFT")
						card.title:SetWordWrap(false)
						card.sub = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
						card.sub:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -8)
						card.sub:SetPoint("RIGHT", card, "RIGHT", -16, 0)
						card.sub:SetJustifyH("LEFT")
						card.sub:SetWordWrap(false)
						card.sub:SetTextColor(0.62, 0.62, 0.66)
						-- Details line (guild, item level, sell price, rewards and so on), it can wrap onto more lines
						card.detail = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
						card.detail:SetPoint("TOPLEFT", card.sub, "BOTTOMLEFT", 0, -6)
						card.detail:SetWidth(372)
						card.detail:SetJustifyH("LEFT")
						card.detail:SetWordWrap(true)
						card.detail:SetTextColor(0.78, 0.78, 0.82)
						card.talents = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
						card.talents:SetWidth(372)
						card.talents:SetJustifyH("LEFT")
						card.talents:SetWordWrap(false)
						-- Add a part to the details line (parts that arrive later, such as item level from an inspect, are added too)
						function card:AddDetail(text)
							if not text or text == "" then return end
							tinsert(self.detailParts, text)
							self.detail:SetText(table.concat(self.detailParts, "    "))
							self:Relayout()
						end
						-- Item level for other players has its own place in the details, so a waiting message can be shown there and replaced
						-- once the item level is read (nil removes it)
						function card:SetItemLevelDetail(text)
							if text == "" then text = nil end
							local index = self.itemLevelPart
							if index and self.detailParts[index] then
								if text then self.detailParts[index] = text else tremove(self.detailParts, index) self.itemLevelPart = nil end
							elseif text then
								tinsert(self.detailParts, text)
								self.itemLevelPart = #self.detailParts
							else
								return
							end
							self.detail:SetText(table.concat(self.detailParts, "    "))
							self:Relayout()
						end
						-- Place the lines, the link box and set the card height to fit the text
						function card:Relayout()
							local hasDetail = #self.detailParts > 0
							self.detail:SetShown(hasDetail)
							self.talents:ClearAllPoints()
							self.talents:SetPoint("TOPLEFT", hasDetail and self.detail or self.sub, "BOTTOMLEFT", 0, -6)
							self.talents:SetShown(self.talentsReserved)
							local textBottom = 20 + (self.title:GetStringHeight() or 20) + 8 + (self.sub:GetStringHeight() or 12)
							if hasDetail then textBottom = textBottom + 6 + (self.detail:GetStringHeight() or 12) end
							if self.talentsReserved then textBottom = textBottom + 6 + math.max(10, self.talents:GetStringHeight() or 10) end
							local contentBottom = math.max(74, textBottom)
							self.box:ClearAllPoints()
							self.box:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -(contentBottom + 14))
							self.box:SetPoint("RIGHT", self, "RIGHT", -16, 0)
							self:SetHeight(PixelRound(self.url and (contentBottom + 14 + 28 + 24) or (contentBottom + 26)))
						end
						-- Close button
						card.close = FlatButton(card, 22, 22, "X")
						card.close:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -10)
						card.close:SetScript("OnClick", function() card:Hide() end)
						-- Link box
						card.box = CreateFrame("Frame", nil, card, "BackdropTemplate")
						card.box:SetPoint("TOPLEFT", card, "TOPLEFT", 20, -88)
						card.box:SetPoint("RIGHT", card, "RIGHT", -16, 0)
						card.box:SetHeight(28)
						card.box:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
						card.box:SetBackdropColor(0, 0, 0, 0.6)
						card.box:SetBackdropBorderColor(1, 1, 1, 0.12)
						card.edit = CreateFrame("EditBox", nil, card.box)
						card.edit:SetPoint("TOPLEFT", card.box, "TOPLEFT", 10, 0)
						card.edit:SetPoint("BOTTOMRIGHT", card.box, "BOTTOMRIGHT", -10, 0)
						card.edit:SetFontObject("ChatFontNormal")
						card.edit:SetTextColor(0.82, 0.88, 1)
						card.edit:SetAutoFocus(false)
						card.edit:SetAltArrowKeyMode(true)
						if card.edit.SetHighlightColor then card.edit:SetHighlightColor(0, 0, 0, 0) end -- The link is selected (so CTRL/C copies it) but the selection is not shown
						-- The link box's own text (and its blinking cursor) is pushed out of sight, and the link is shown as plain text instead
						card.edit:SetTextInsets(5000, 0, 0, 0)
						card.edit:SetTextColor(0, 0, 0, 0)
						card.urlText = card.box:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
						card.urlText:SetPoint("LEFT", card.box, "LEFT", 10, 0)
						card.urlText:SetPoint("RIGHT", card.box, "RIGHT", -10, 0)
						card.urlText:SetJustifyH("LEFT")
						card.urlText:SetWordWrap(false)
						card.urlText:SetTextColor(0.82, 0.88, 1)
						-- Hints
						card.hint = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
						card.hint:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 22, 10) -- Same level as the right-click hint
						-- Checkbox to show or hide the model viewer (only shown for things with a 3D model, the choice is saved)
						card.modelCheck = CreateFrame("Button", nil, card, "BackdropTemplate")
						card.modelCheck:SetSize(PixelRound(11), PixelRound(11))
						card.modelCheck:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 22, 11)
						card.modelCheck:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
						card.modelCheck:SetBackdropColor(0, 0, 0, 0.6)
						card.modelCheck.tick = card.modelCheck:CreateTexture(nil, "OVERLAY")
						card.modelCheck.tick:SetPoint("TOPLEFT", card.modelCheck, "TOPLEFT", PixelRound(2), -PixelRound(2))
						card.modelCheck:SetHitRectInsets(-2, -80, -4, -4) -- The label can be clicked too
						card.modelCheck.tick:SetPoint("BOTTOMRIGHT", card.modelCheck, "BOTTOMRIGHT", -PixelRound(2), PixelRound(2))
						card.modelCheck.label = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
						card.modelCheck.label:SetPoint("LEFT", card.modelCheck, "RIGHT", 6, 0)
						card.modelCheck.label:SetText(L["3D model"])
						function card.modelCheck:Update()
							local on = LeaPlusLC.IDModelOn
							self.tick:SetShown(on)
							self.label:SetTextColor(on and 0.85 or 0.5, on and 0.85 or 0.5, on and 0.85 or 0.5)
						end
						card.modelCheck:SetScript("OnEnter", function(self) self.label:SetTextColor(1, 1, 1) end)
						card.modelCheck:SetScript("OnLeave", function(self) self:Update() end)
						card.modelCheck:SetScript("OnClick", function(self)
							LeaPlusLC.IDModelOn = not LeaPlusLC.IDModelOn
							if LeaPlusDB then LeaPlusDB["IDModelOn"] = LeaPlusLC.IDModelOn end
							self:Update()
							local viewer = LeaPlusLC.IDViewer
							if card.info then card.info.offscreen = not LeaPlusLC.IDModelOn end
							if viewer and viewer:IsShown() then
								-- Already loaded, so just move it on or off the screen
								viewer.offscreen = not LeaPlusLC.IDModelOn
								AttachViewer()
							elseif LeaPlusLC.IDModelOn and card.info and card.info.view then
								card.info.openViewer = true
								ShowViewer(card.info)
								card.info.openViewer = nil
							end
						end)
						card.hint2 = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
						card.hint2:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -18, 10)
						card.hint2:SetText(L["Right-click to close"])
						-- Keep the link unchanged and selected (CTRL/C copies it and closes the card)
						local function Reselect() card.edit:SetText(card.url or "") card.edit:HighlightText() end
						card.edit:SetScript("OnChar", Reselect)
						-- Put the link straight back if anything changes it (such as CTRL/X cutting it or pasting over it)
						card.edit:SetScript("OnTextChanged", function(self, userInput)
							if userInput and self:GetText() ~= (card.url or "") then Reselect() end
						end)
						local function IsCtrlKey(key) return key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" end
						card.edit:SetScript("OnKeyUp", function(self, key)
							Reselect()
							-- Letting go of Ctrl gives the keyboard back to the game (when Leatrix is watching for Ctrl)
							if card.ctrlFocus and IsCtrlKey(key) then card.ctrlFocus = nil self:ClearFocus() end
						end)
						-- Holding Ctrl gives the link box the keyboard so CTRL/C copies the link (the Ctrl watcher is made when Leatrix Plus loads)
						-- Clicking the link box does not take the keyboard (only holding Ctrl does), so the character can still be moved
						card.edit:SetScript("OnEditFocusGained", function(self)
							if not card.ctrlFocus then self:ClearFocus() end
						end)
						card.edit:SetScript("OnMouseUp", function(self) self:HighlightText() end)
						card.edit:SetScript("OnEnterPressed", function(self) self:HighlightText() end)
						card.edit:SetScript("OnEscapePressed", function() local viewer = LeaPlusLC.IDViewer if viewer and viewer.scenePopup and viewer.scenePopup:IsShown() then viewer.scenePopup:Hide() elseif viewer and viewer.fullscreen then viewer:SetFullscreen(false) else card:Hide() end end)
						card.edit:SetScript("OnKeyDown", function(self, key)
							if key == "C" and (IsControlKeyDown() or IsMetaKeyDown()) then
								card.hint:SetText("|cff40ff40" .. L["Copied to clipboard."] .. "|r")
								C_Timer.After(0.4, function() card:Hide() end)
								return
							end
							-- The link box has the keyboard, so pass the info card key binding through (shows whatever is now under the mouse)
							local combo = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. ((IsMetaKeyDown and IsMetaKeyDown()) and "META-" or "") .. key
							if LeaPlusLC["ShowInfoCards"] == "On" and LeaPlusLC["InfoCardKey"] ~= "" and combo == LeaPlusLC["InfoCardKey"] then
								ShowInfoCard()
								-- If no new card was shown (such as pointing at a mailbox), the link box still has the keyboard, so give it back now
								if card.ctrlFocus then card.ctrlFocus = nil self:ClearFocus() end
								return
							end
							-- Any other key (not Ctrl itself) gives the keyboard back so the next press reaches the game
							if card.ctrlFocus and not IsCtrlKey(key) and key ~= "LSHIFT" and key ~= "RSHIFT" and key ~= "LALT" and key ~= "RALT" then
								card.ctrlFocus = nil
								self:ClearFocus()
							end
						end)
						-- Fade in
						card.fade = card:CreateAnimationGroup()
						local fadeIn = card.fade:CreateAnimation("Alpha")
						fadeIn:SetFromAlpha(0)
						fadeIn:SetToAlpha(1)
						fadeIn:SetDuration(0.15)
						card:SetScript("OnShow", function() card.fade:Play() end)
						-- The link box only keeps the keyboard while Ctrl is held (letting go of Ctrl is not always seen by the link box, so check every frame)
						card:SetScript("OnUpdate", function(self)
							if self.ctrlFocus and not (IsControlKeyDown() or (IsMetaKeyDown and IsMetaKeyDown())) then
								self.ctrlFocus = nil
								if self.edit:HasFocus() then self.edit:ClearFocus() end
							end
						end)
						-- Closing the card always gives the keyboard back to the game
						card:SetScript("OnHide", function(self)
							local viewer = LeaPlusLC.IDViewer
							if viewer and viewer.fullscreen then viewer:SetFullscreen(false) end -- The viewer is not inside the card in fullscreen, so end fullscreen with the card
							self.ctrlFocus = nil
							if self.edit:HasFocus() then self.edit:ClearFocus() end
						end)
						LeaPlusLC.IDCard = card
					end
					-- Back to the normal lines (a card for a hidden aura uses its own lines, see ShowHiddenAuraCard)
					card.hiddenMode = nil
					card.title:Show()
					card.sub:Show()
					card.urlText:Show()
					card.edit:Show()
					if card.hiddenTitle then
						card.hiddenTitle:Hide()
						card.hiddenSub:Hide()
						card.hiddenUrlText:Hide()
					end
					-- Accent colour
					local r, g, b = unpack(info.color or {1, 0.82, 0})
					card.iconBorder:SetColorTexture(r, g, b, 0.9)
					card:SetBackdropBorderColor(r, g, b, 0.55)
					card.glow:SetVertexColor(1, 1, 1, 1)
					card.glow:SetGradient("VERTICAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 0.16))
					-- Icon or portrait
					card.icon:SetTexture(nil)
					-- (round portraits and class icons are cropped to the square inside the circle, to match the square 3D portrait)
					local function InnerSquare(left, right, top, bottom)
						local w, h = right - left, bottom - top
						return left + w * 0.15, right - w * 0.15, top + h * 0.15, bottom - h * 0.15
					end
					if info.unit and UnitExists(info.unit) then
						SetPortraitTexture(card.icon, info.unit)
						card.icon:SetTexCoord(InnerSquare(0, 1, 0, 1))
					elseif info.icon == "Interface\\TargetingFrame\\UI-Classes-Circles" and info.iconCoords then
						card.icon:SetTexture(info.icon)
						card.icon:SetTexCoord(InnerSquare(unpack(info.iconCoords)))
					else
						card.icon:SetTexture(info.icon or 134400)
						card.icon:SetTexCoord(unpack(info.iconCoords or {0.08, 0.92, 0.08, 0.92}))
					end
					-- Text
					card.kind:SetText(strupper(info.kind or ""))
					card.kind:SetTextColor(r, g, b)
					card.title:SetText(info.name or "")
					if info.nameColor then card.title:SetTextColor(unpack(info.nameColor)) else card.title:SetTextColor(1, 1, 1) end
					card.sub:SetText(info.sub or (L["ID"] .. " |cffffffff" .. tostring(info.id or "") .. "|r" .. (info.note and ("    " .. info.note) or "")))
					card.hint:SetText(L["Press CTRL/C to copy"])
					card.talents:SetText("")
					card.talentsReadID = (card.talentsReadID or 0) + 1 -- Stops talent reads for an earlier card from changing this one
					card.talentsReserved = info.talents and true or false
					card.detailParts = {}
					card.itemLevelPart = nil
					card.mythicShown = nil
					card.gearReadingGUID = nil
					LeaPlusLC.IDTalentWait = nil -- A reply kept for the last player is no longer needed
					card.detail:SetText("")
					for void, part in ipairs(info.details or {}) do if part and not IsSecret(part) and part ~= "" then tinsert(card.detailParts, part) end end
					card.detail:SetText(table.concat(card.detailParts, "    "))
					card.inspectGUID = nil
					-- Model viewer (only for things that can be shown as a 3D model, kept up to date while it is open)
					if info.view and info.view.mode == "icon" then info.view = nil end
					card.info = info
					card.close:SetAccent(r, g, b)
					-- Link (some cards, such as players on Forever, have no link)
					card.url = info.url
					card.edit:SetText(info.url or "")
					card.urlText:SetText(info.url or "")
					card.box:SetShown(info.url ~= nil)
					card.hint:SetShown(info.url ~= nil)
					-- Model viewer checkbox (the copy hint moves along to make room for it)
					card.modelCheck:SetShown(info.view ~= nil)
					card.modelCheck.label:SetShown(info.view ~= nil)
					card.modelCheck:SetBackdropBorderColor(r, g, b, 0.8)
					card.modelCheck.tick:SetColorTexture(r, g, b, 1)
					card.modelCheck:Update()
					card.hint:ClearAllPoints()
					if info.view then
						card.hint:SetPoint("LEFT", card.modelCheck.label, "RIGHT", 18, 0)
					else
						card.hint:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 22, 10)
					end
					card.hint2:Show()
					card:Relayout()
					card:Show()
					if not card.snapped then card.snapped = true SnapToPixels(card) end -- Line up with screen pixels when first shown
					-- 3D portrait (loaded now the card is showing, for players and NPCs)
					local portrait = card.portrait
					portrait.loadID = (portrait.loadID or 0) + 1
					-- (only for characters you can see: loading a model for someone far away can make the game pause)
					if info.unit and UnitExists(info.unit) and Safe(UnitIsVisible(info.unit)) and not (info.iconCoords) then
						portrait:Show()
						portrait:SetUnit(info.unit)
					elseif info.view and info.view.npcID and not info.view.isPlayer then
						portrait:Show()
						portrait:SetCreature(tonumber(info.view.npcID))
					else
						portrait:Hide()
					end
					-- With a 3D portrait, show a plain dark backdrop instead of the round flat portrait underneath
					card.icon:SetShown(not portrait:IsShown())
					card.portraitBg:SetShown(portrait:IsShown())
					if portrait:IsShown() then
						-- In case the loaded event does not fire (such as a model that was already loaded)
						local id = portrait.loadID
						C_Timer.After(0.3, function()
							if portrait.loadID == id and portrait:IsVisible() then
								portrait:SetPortraitZoom(1)
								portrait:SetPosition(0, 0, 0)
								portrait:SetFacing(0)
							end
						end)
					end
					-- Update the model viewer now the card is showing
					local viewer = LeaPlusLC.IDViewer
					if info.view then
						-- Things with a 3D model open the model viewer, loaded now while the mouse is still over them
						-- (off the screen when the 3D model box is unticked, so ticking it shows the model straight away)
						info.offscreen = not LeaPlusLC.IDModelOn
						info.openViewer = true
						info.view.fresh = true
						ShowViewer(info)
						info.view.fresh = nil
						info.openViewer = nil
					elseif viewer and viewer:IsShown() then
						viewer:Hide()
					end
					card:Raise()
					card.ctrlFocus = nil
					card.edit:ClearFocus() -- The keyboard stays with the game (holding Ctrl gives it to the link box)
					card.edit:HighlightText()
				end
				-- Card for a buff or debuff the game has hidden from addons (such as in combat or a PvP match)
				-- The hidden name, ID and link are never read, only passed straight to the game to show them. They use their own lines,
				-- as anything that has shown a hidden value stays hidden (and the normal lines are measured for the layout).
				-- The link cannot be copied, as the game does not let a link box show a hidden value.
				local function ShowHiddenAuraCard(auraID, auraName)
					-- Set up the card as normal with blank lines (these set the layout), then show the hidden values over them
					ShowIDCard({kind = L["Aura"], name = " ", sub = " ", url = " ", icon = 134400, color = {0.6, 0.6, 0.65}})
					local card = LeaPlusLC.IDCard
					if not card.hiddenTitle then
						card.hiddenTitle = card:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
						card.hiddenTitle:SetPoint("TOPLEFT", card.title, "TOPLEFT", 0, 0)
						card.hiddenTitle:SetPoint("RIGHT", card.title, "RIGHT", 0, 0)
						card.hiddenTitle:SetJustifyH("LEFT")
						card.hiddenTitle:SetWordWrap(false)
						card.hiddenTitle:SetTextColor(1, 1, 1)
						card.hiddenSub = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
						card.hiddenSub:SetPoint("TOPLEFT", card.sub, "TOPLEFT", 0, 0)
						card.hiddenSub:SetPoint("RIGHT", card.sub, "RIGHT", 0, 0)
						card.hiddenSub:SetJustifyH("LEFT")
						card.hiddenSub:SetWordWrap(false)
						card.hiddenSub:SetTextColor(0.62, 0.62, 0.66)
						card.hiddenUrlText = card.box:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
						card.hiddenUrlText:SetPoint("LEFT", card.urlText, "LEFT", 0, 0)
						card.hiddenUrlText:SetPoint("RIGHT", card.urlText, "RIGHT", 0, 0)
						card.hiddenUrlText:SetJustifyH("LEFT")
						card.hiddenUrlText:SetWordWrap(false)
						card.hiddenUrlText:SetTextColor(0.82, 0.88, 1)
					end
					-- Show the hidden values in place of the normal lines
					card.hiddenMode = true
					card.title:Hide()
					card.sub:Hide()
					card.urlText:Hide()
					card.edit:ClearFocus()
					card.edit:Hide()
					card.url = nil -- Nothing to copy (holding Ctrl does nothing)
					card.hint:SetText(L["The link cannot be copied right now"])
					card.hiddenTitle:SetText(auraName or "")
					card.hiddenSub:SetText(L["ID"] .. " |cffffffff" .. auraID .. "|r    |cff8a8a90" .. L["Details are hidden right now"] .. "|r")
					card.hiddenUrlText:SetText("https://" .. LeaPlusLC.WowheadLock .. "/spell=" .. auraID)
					card.hiddenTitle:Show()
					card.hiddenSub:Show()
					card.hiddenUrlText:Show()
				end
				local function SpellIcon(spellID)
					return (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(spellID)) or (GetSpellTexture and GetSpellTexture(spellID))
				end
				-- Flavour text helpers for the model viewer
				local function SpellText(spellID)
					local text = Safe((C_Spell and C_Spell.GetSpellDescription and C_Spell.GetSpellDescription(spellID)) or (GetSpellDescription and GetSpellDescription(spellID)))
					if type(text) == "string" and text ~= "" then return text end
				end
				local function TooltipLines(tooltip)
					local lines = {}
					local name = tooltip and tooltip.GetName and tooltip:GetName()
					if not name then return lines end
					for i = 1, tooltip:NumLines() do
						local line = _G[name .. "TextLeft" .. i]
						local text = line and line:GetText()
						text = Safe(text)
						if type(text) == "string" then tinsert(lines, (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))) end
					end
					return lines
				end
				local function ItemFlavour(tooltip)
					for void, text in ipairs(TooltipLines(tooltip)) do
						if text:find('^"') then return text end -- Flavour text is the quoted line
					end
				end
				local function NPCText(tooltip)
					local parts = {}
					local lines = TooltipLines(tooltip)
					if lines[2] and lines[2]:find("^<") then tinsert(parts, lines[2]) end -- Title such as <Innkeeper>
					local creatureType = Safe(UnitCreatureType("mouseover"))
					if type(creatureType) == "string" then tinsert(parts, creatureType) end
					if #parts > 0 then return table.concat(parts, "\n") end
				end
				local function PlayerText(unit)
					local parts = {}
					local guildName = Safe(GetGuildInfo(unit))
					if type(guildName) == "string" then tinsert(parts, "<" .. guildName .. ">") end
					local race = Safe(UnitRace(unit))
					if type(race) == "string" then tinsert(parts, race .. " " .. (Safe(UnitClass(unit)) or "")) end
					if #parts > 0 then return table.concat(parts, "\n") end
				end
				local function QuestText(questID)
					local objectives = SafeTable(C_QuestLog.GetQuestObjectives(questID))
					if not objectives then return end
					local parts = {}
					for void, objective in ipairs(objectives) do
						local text = SafeTable(objective) and Safe(objective.text)
						if type(text) == "string" and text ~= "" then tinsert(parts, text) end
					end
					if #parts > 0 then return table.concat(parts, "\n") end
				end
				-- Items that show on a character (only these open the model viewer)
				local hiddenSlots = {INVTYPE_AMMO = true, INVTYPE_FINGER = true, INVTYPE_NECK = true, INVTYPE_TRINKET = true, INVTYPE_RELIC = true, INVTYPE_BAG = true, INVTYPE_QUIVER = true, INVTYPE_NON_EQUIP = true, INVTYPE_NON_EQUIP_IGNORE = true, [""] = true}
				local function IsEquippable(itemLink)
					local dressable = (C_Item and C_Item.IsDressableItemByID) or IsDressableItem
					if dressable then
						local result = Safe(dressable(itemLink))
						if result ~= nil then return result end
					end
					local check = (C_Item and C_Item.IsEquippableItem) or IsEquippableItem
					if not (check and Safe(check(itemLink))) then return false end
					local GetInfoInstant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
					local equipLoc = GetInfoInstant and Safe(select(4, GetInfoInstant(itemLink)))
					return equipLoc ~= nil and not hiddenSlots[equipLoc]
				end
				local colorBuff, colorDebuff, colorSpell, colorQuest = {0.3, 0.9, 0.4}, {1, 0.35, 0.35}, {0.35, 0.65, 1}, {1, 0.82, 0}
				-- Forever uses surnames where other games use realm names (Forever is interface version 1.6x)
				local tocVersion = select(4, GetBuildInfo()) or 0
				local isForever = tocVersion >= 16000 and tocVersion < 20000
				-- Talent tree names for each class, left to right (Forever has one spec per class, so the game does not name the trees)
				local talentTreeNames = {
					WARRIOR = {L["Arms"], L["Fury"], L["Protection"]},
					PALADIN = {L["Holy"], L["Protection"], L["Retribution"]},
					HUNTER = {L["Beast Mastery"], L["Marksmanship"], L["Survival"]},
					ROGUE = {L["Assassination"], L["Combat"], L["Subtlety"]},
					PRIEST = {L["Discipline"], L["Holy"], L["Shadow"]},
					SHAMAN = {L["Elemental Combat"], L["Enhancement"], L["Restoration"]},
					MAGE = {L["Arcane"], L["Fire"], L["Frost"]},
					WARLOCK = {L["Affliction"], L["Demonology"], L["Destruction"]},
					DRUID = {L["Balance"], L["Feral Combat"], L["Restoration"]},
				}
				-- Talent summary: the talent trees with points in them, most points first (such as Frost 31   Arcane 20)
				-- Forever keeps the three trees side by side in one modern talent tree, so talents are grouped by
				-- their position (a new tree starts where the gap between columns is much wider than usual)
				local function TalentSummary(configID, classFile)
					if not configID or not C_Traits or not C_Traits.GetConfigInfo then return nil end
					local config = SafeTable(C_Traits.GetConfigInfo(configID))
					local treeIDs = config and SafeTable(config.treeIDs)
					if not treeIDs or not Safe(treeIDs[1]) then return nil end
					local nodes = {}
					for void, treeID in ipairs(treeIDs) do
						treeID = Safe(treeID)
						for void, nodeID in ipairs(treeID and SafeTable(C_Traits.GetTreeNodes(treeID)) or {}) do
							local node = SafeTable(C_Traits.GetNodeInfo(configID, Safe(nodeID)))
							if node and type(Safe(node.posX)) == "number" then tinsert(nodes, node) end
						end
					end
					-- Points per column (use purchased ranks, or active ranks if nothing was purchased, such as some inspect data)
					local function Columns(field)
						local columns, total = {}, 0
						for void, node in ipairs(nodes) do
							local points = Safe(node[field])
							if type(points) ~= "number" then points = 0 end
							columns[node.posX] = (columns[node.posX] or 0) + points
							total = total + points
						end
						return columns, total
					end
					local columns, total = Columns("ranksPurchased")
					if total == 0 then columns, total = Columns("activeRank") end
					local xs = {}
					for x in pairs(columns) do tinsert(xs, x) end
					table.sort(xs)
					if #xs == 0 then return nil end
					if total == 0 then return "|cff8a8a90" .. L["No talents"] .. "|r" end
					-- Split the columns into trees where the gap is much wider than the usual gap between columns
					local gaps = {}
					for i = 2, #xs do tinsert(gaps, xs[i] - xs[i - 1]) end
					table.sort(gaps)
					local usualGap = gaps[math.ceil(#gaps / 2)] or 0
					local trees = {{points = 0, order = 1}}
					for i, x in ipairs(xs) do
						if i > 1 and xs[i] - xs[i - 1] > usualGap * 1.5 then tinsert(trees, {points = 0, order = #trees + 1}) end
						trees[#trees].points = trees[#trees].points + columns[x]
					end
					-- Name the trees (left to right)
					local names = classFile and talentTreeNames[classFile]
					for i, tree in ipairs(trees) do
						tree.name = names and names[i] or (L["Tree"] .. " " .. i)
					end
					table.sort(trees, function(x, y) if x.points ~= y.points then return x.points > y.points end return x.order < y.order end)
					local parts = {}
					for i, tree in ipairs(trees) do
						if tree.points > 0 then tinsert(parts, (i == 1 and "|cffffffff" or "|cffa0a0a8") .. tree.name .. " " .. tree.points .. "|r") end
					end
					return table.concat(parts, "    ")
				end
				-- Retail talent summary: specialisation and hero talents (such as Retribution    Templar)
				-- Retail has a class tree, a spec tree and hero trees in one config, so the Forever column grouping does not work here
				local function Try(func, ...)
					if type(func) ~= "function" then return nil end
					local results = {pcall(func, ...)}
					if not results[1] then return nil end
					return Safe(unpack(results, 2, table.maxn(results)))
				end
				-- Find a player by their GUID (the mouse may have moved off them since the key was pressed)
				local function FindUnitByGUID(guid, first)
					if not guid then return nil end
					local tokens = {first or "mouseover", "mouseover", "target", "focus", "targettarget"}
					for i = 1, 4 do tinsert(tokens, "party" .. i) end
					if IsInRaid and IsInRaid() then for i = 1, 40 do tinsert(tokens, "raid" .. i) end end
					for i = 1, 40 do tinsert(tokens, "nameplate" .. i) end
					for void, token in ipairs(tokens) do
						if UnitExists(token) and Safe(UnitGUID(token)) == guid then return token end
					end
				end
				-- Debug: /ltp talentdebug shows in chat how the talents were read (type it again to turn it off, not saved)
				local function TalentDebug(...)
					if not LeaPlusLC.IDTalentDebug then return end
					local parts = {}
					for i = 1, select("#", ...) do parts[i] = tostring((select(i, ...))) end
					print("|cff00ff00Leatrix Plus talents:|r " .. table.concat(parts, "  "))
				end
				local function RetailTalentSummary(unit, configID, isPlayer, classID)
					-- Specialisation
					local GetSpec = (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization) or GetSpecialization
					local GetSpecInfo = (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo) or GetSpecializationInfo
					local specID
					if isPlayer then
						local index = Try(GetSpec)
						if type(index) == "number" and index > 0 then specID = Try(GetSpecInfo, index) end
					else
						if unit then specID = Try(GetInspectSpecialization, unit) end
						TalentDebug("unit:", unit, "spec from unit:", specID, "class:", classID)
						-- The spec is only ever read live from the player (nothing is remembered from earlier cards, and the inspected spec number the game gives without the player can be wrong)
					end
					local specName, specIcon
					if type(specID) == "number" and specID > 0 then
						local void
						void, specName, void, specIcon = Try(GetSpecializationInfoByID, specID)
						-- Low level characters have a starter spec with no name, so leave it out (and its icon)
						if type(specName) ~= "string" or specName == "" then specName, specIcon = nil, nil end
					end
					-- Hero talents (the active hero tree)
					local heroName
					if configID and C_Traits and C_Traits.GetSubTreeInfo then
						local subTreeIDs = {}
						if isPlayer and C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec then
							local active = Try(C_ClassTalents.GetActiveHeroTalentSpec)
							if active then tinsert(subTreeIDs, active) end
						end
						if #subTreeIDs == 0 and type(specID) == "number" and C_ClassTalents and C_ClassTalents.GetHeroTalentSpecsForClassSpec then
							for void, id in ipairs(SafeTable(Try(C_ClassTalents.GetHeroTalentSpecsForClassSpec, configID, specID)) or {}) do tinsert(subTreeIDs, id) end
						end
						-- No spec: find the hero trees in the talent data itself (they do not need the spec or the player)
						if #subTreeIDs == 0 and C_Traits.GetConfigInfo and C_Traits.GetTreeNodes and C_Traits.GetNodeInfo then
							local config = SafeTable(Try(C_Traits.GetConfigInfo, configID))
							local seen = {}
							for void, treeID in ipairs(config and SafeTable(config.treeIDs) or {}) do
								for void, nodeID in ipairs(SafeTable(Try(C_Traits.GetTreeNodes, Safe(treeID))) or {}) do
									local node = SafeTable(Try(C_Traits.GetNodeInfo, configID, Safe(nodeID)))
									local subTreeID = node and Safe(node.subTreeID)
									if subTreeID and not seen[subTreeID] then seen[subTreeID] = true tinsert(subTreeIDs, subTreeID) end
								end
							end
						end
						for void, subTreeID in ipairs(subTreeIDs) do
							local info = SafeTable(Try(C_Traits.GetSubTreeInfo, configID, Safe(subTreeID)))
							if info and Safe(info.isActive) and type(Safe(info.name)) == "string" then heroName = info.name break end
						end
						if not isPlayer then TalentDebug("hero trees found:", #subTreeIDs, "active hero:", heroName) end
					end
					if not specName and not heroName then return nil end
					local parts = {}
					if specName then tinsert(parts, (specIcon and ("|T" .. specIcon .. ":14:14:0:0|t ") or "") .. "|cffffffff" .. specName .. "|r") end
					if heroName then tinsert(parts, "|cffa0a0a8" .. heroName .. "|r") end
					return table.concat(parts, "    ")
				end
				-- Details for the card (each returns a list of short parts; anything the game hides or does not have is left out)
				local function NotSecret(v) return v ~= nil and not IsSecret(v) end
				local function Grey(text) return "|cff8a8a90" .. text .. "|r" end
				-- Money with gold, silver and copper icons
				local function CoinText(copper)
					-- Size the coin icons to the card's details text (the default size suits larger text, so the icons sit low)
					local card = LeaPlusLC.IDCard
					local fontSize = card and card.detail and select(2, card.detail:GetFont())
					fontSize = fontSize and math.floor(fontSize + 0.5) or nil
					if C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then return C_CurrencyInfo.GetCoinTextureString(copper, fontSize) end
					if GetCoinTextureString then return GetCoinTextureString(copper, fontSize) end
					local gold, silver, bronze = math.floor(copper / 10000), math.floor(copper % 10000 / 100), copper % 100
					local text = {}
					if gold > 0 then tinsert(text, gold .. "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t") end
					if silver > 0 then tinsert(text, silver .. "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t") end
					if bronze > 0 or #text == 0 then tinsert(text, bronze .. "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t") end
					return table.concat(text, " ")
				end
				-- Players: guild, relationship to you, PvP
				-- Mythic+ score for the current season, coloured like the game's own (nothing is shown for a score of 0 or if the game gives none)
				local function MythicScoreText(unit)
					if isForever or not unit or not (C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary) then return nil end
					local ok, summary = pcall(C_PlayerInfo.GetPlayerMythicPlusRatingSummary, unit)
					summary = ok and SafeTable(summary)
					local score = summary and Safe(summary.currentSeasonScore)
					if type(score) ~= "number" or score <= 0 then return nil end
					score = math.floor(score)
					local hex = "ffffff"
					if C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor then
						local okColor, color = pcall(C_ChallengeMode.GetDungeonScoreRarityColor, score)
						if okColor and color and color.GenerateHexColor then
							local okHex, text = pcall(color.GenerateHexColor, color)
							text = okHex and Safe(text)
							if type(text) == "string" and #text == 8 then hex = text:sub(3) end
						end
					end
					return (DUNGEON_SCORE or L["Mythic+ score"]) .. " |cff" .. hex .. score .. "|r"
				end
				local function PlayerDetails(unit, guid)
					local parts = {}
					unit, guid = Safe(unit, guid)
					local hasUnit = unit and UnitExists(unit)
					-- Guild
					if hasUnit then
						local guildName, rankName = Safe(GetGuildInfo(unit))
						if guildName and guildName ~= "" then tinsert(parts, "|cff40ff40" .. guildName .. "|r" .. (rankName and rankName ~= "" and (" " .. rankName) or "")) end
					end
					-- Relationship to you
					local relation = {}
					if hasUnit and not Safe(UnitIsUnit(unit, "player")) then -- Nothing to say about your own character
						if Safe(UnitInRaid(unit)) or Safe(UnitInParty(unit)) then tinsert(relation, L["In your group"]) end
						if UnitIsInMyGuild and Safe(UnitIsInMyGuild(unit)) then tinsert(relation, L["Guildmate"]) end
					end
					if guid and C_FriendList and C_FriendList.IsFriend and Safe(C_FriendList.IsFriend(guid)) then tinsert(relation, L["Friend"]) end
					if #relation > 0 then tinsert(parts, "|cff66bbff" .. table.concat(relation, ", ") .. "|r") end
					-- PvP
					if hasUnit then
						local pvp = {}
						if UnitIsPVPFreeForAll and Safe(UnitIsPVPFreeForAll(unit)) then tinsert(pvp, L["Free for all PvP"])
						elseif Safe(UnitIsPVP(unit)) then tinsert(pvp, L["PvP"]) end
						if UnitPVPRank and GetPVPRankInfo then
							local rank = Safe(UnitPVPRank(unit))
							if type(rank) == "number" and rank >= 5 then
								local rankName = Safe(GetPVPRankInfo(rank, unit))
								if rankName and rankName ~= "" then tinsert(pvp, rankName) end
							end
						end
						if #pvp > 0 then tinsert(parts, "|cffff6060" .. table.concat(pvp, ", ") .. "|r") end
					end
					return parts
				end
				-- Average item level of a unit's equipped gear (shirt and tabard are left out, a two-hand weapon counts twice)
				local function AverageItemLevel(unit, inspected)
					if Safe(UnitIsUnit(unit, "player")) and GetAverageItemLevel then
						local void, equipped = Safe(GetAverageItemLevel())
						if type(equipped) == "number" and equipped > 0 then
							-- Match the character sheet: never below the minimum item level, and always round down
							local minLevel = C_PaperDollInfo and C_PaperDollInfo.GetMinItemLevel and Safe(C_PaperDollInfo.GetMinItemLevel())
							if type(minLevel) == "number" and minLevel > equipped then equipped = minLevel end
							return math.floor(equipped)
						end
					end
					-- Other players on retail: use the game's own inspect item level (the same as the inspect window)
					-- Only after an inspect, as it gives the last inspected player's item level
					if inspected and C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
						local ok, level = pcall(C_PaperDollInfo.GetInspectItemLevel, unit)
						level = ok and Safe(level) or nil
						if type(level) == "number" and level > 0 then return math.floor(level) end
					end
					local total, count, mainHandTwoHand, offHand = 0, 0, false, false
					local GetInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
					local GetLevel = (C_Item and C_Item.GetDetailedItemLevelInfo) or GetDetailedItemLevelInfo
					for slot = 1, 18 do
						if slot ~= 4 then
							local link = Safe(GetInventoryItemLink(unit, slot))
							if link then
								local level = Safe(GetLevel and GetLevel(link) or select(4, GetInfo(link)))
								if type(level) == "number" and level > 0 then
									total, count = total + level, count + 1
									if slot == 16 and Safe(select(9, GetInfo(link))) == "INVTYPE_2HWEAPON" then mainHandTwoHand = level end
									if slot == 17 then offHand = true end
								end
							end
						end
					end
					if mainHandTwoHand and not offHand then total, count = total + mainHandTwoHand, count + 1 end
					if count == 0 then return nil end
					return math.floor(total / count)
				end
				-- Items: item level, binding, sell price, item set
				local function ItemDetails(itemLink, tooltip)
					local parts = {}
					local GetInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
					local void, itemLevel, sellPrice, bindType
					void, void, void, itemLevel, void, void, void, void, void, void, sellPrice, void, void, bindType = Safe(GetInfo(itemLink))
					local GetLevel = (C_Item and C_Item.GetDetailedItemLevelInfo) or GetDetailedItemLevelInfo
					itemLevel = (GetLevel and Safe(GetLevel(itemLink))) or itemLevel
					if type(itemLevel) == "number" and itemLevel > 0 then tinsert(parts, L["Item level"] .. " |cffffffff" .. itemLevel .. "|r") end
					-- Binding (soulbound if the tooltip says so, otherwise how it binds)
					local lines = TooltipLines(tooltip)
					local bound
					for void, text in ipairs(lines) do
						if text == ITEM_SOULBOUND or (ITEM_ACCOUNTBOUND and text == ITEM_ACCOUNTBOUND) then bound = text break end
					end
					if not bound then
						if bindType == 1 then bound = ITEM_BIND_ON_PICKUP
						elseif bindType == 2 then bound = ITEM_BIND_ON_EQUIP
						elseif bindType == 3 then bound = ITEM_BIND_ON_USE
						elseif bindType == 4 then bound = ITEM_BIND_QUEST end
					end
					if bound then tinsert(parts, bound) end
					-- Sell price
					if type(sellPrice) == "number" then
						if sellPrice > 0 then
							tinsert(parts, L["Sells for"] .. " " .. CoinText(sellPrice))
						else
							tinsert(parts, Grey(L["Cannot be sold"]))
						end
					end
					-- Item set (the tooltip line with the set name and pieces, such as "Battlegear of Might (2/8)")
					for void, text in ipairs(lines) do
						local setName, have, total = text:match("^(.-) %((%d+)/(%d+)%)$")
						if setName and setName ~= "" then
							tinsert(parts, "|cffffd100" .. L["Set"] .. ": " .. setName .. " (" .. have .. "/" .. total .. ")|r")
							break
						end
					end
					return parts
				end
				-- Spells: rank
				local function SpellDetails(spellID)
					local parts = {}
					local subtext = Safe((C_Spell and C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellID)) or (GetSpellSubtext and GetSpellSubtext(spellID)))
					if type(subtext) == "string" and subtext ~= "" then tinsert(parts, subtext) end
					return parts
				end
				-- Buffs and debuffs: who cast it
				local function AuraDetails(sourceUnit, spellID)
					local parts = {}
					sourceUnit = Safe(sourceUnit)
					-- For the buff frame, look up the caster from your own auras
					if not sourceUnit and spellID and C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID and not AurasHidden() then
						local aura = SafeTable(C_UnitAuras.GetPlayerAuraBySpellID(spellID))
						if aura then sourceUnit = Safe(aura.sourceUnit) end
					end
					if type(sourceUnit) ~= "string" or not UnitExists(sourceUnit) then return parts end
					if Safe(UnitIsUnit(sourceUnit, "player")) then
						tinsert(parts, L["Cast by"] .. " |cffffffff" .. L["You"] .. "|r")
					else
						local name = Safe(UnitName(sourceUnit))
						if name then
							local classFile = Safe(UnitIsPlayer(sourceUnit)) and Safe(select(2, UnitClass(sourceUnit)))
							local color = classFile and RAID_CLASS_COLORS[classFile]
							tinsert(parts, L["Cast by"] .. " " .. (color and string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, name) or ("|cffffffff" .. name .. "|r")))
						end
					end
					return parts
				end
				-- Quests: level (coloured by difficulty), complete, group or elite, rewards
				local function QuestDetails(questID)
					local parts = {}
					local index = C_QuestLog.GetLogIndexForQuestID and Safe(C_QuestLog.GetLogIndexForQuestID(questID))
					local info = index and SafeTable(C_QuestLog.GetInfo(index))
					local level = info and Safe(info.level)
					local suggestedGroup = info and Safe(info.suggestedGroup)
					if type(suggestedGroup) ~= "number" then suggestedGroup = 0 end
					if type(level) == "number" and level > 0 then
						local color = GetQuestDifficultyColor and GetQuestDifficultyColor(level)
						local text = L["Level"] .. " " .. level
						tinsert(parts, color and string.format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, text) or text)
					end
					if C_QuestLog.IsComplete and Safe(C_QuestLog.IsComplete(questID)) then tinsert(parts, "|cff40ff40" .. L["Complete"] .. "|r") end
					-- Group size, elite, dungeon and so on
					local tag = C_QuestLog.GetQuestTagInfo and SafeTable(C_QuestLog.GetQuestTagInfo(questID))
					local tagName = tag and Safe(tag.tagName)
					if type(tagName) == "string" and tagName ~= "" then
						tinsert(parts, "|cffff9020" .. tagName .. ((suggestedGroup > 1) and (" (" .. suggestedGroup .. ")") or "") .. "|r")
					elseif suggestedGroup > 1 then
						tinsert(parts, "|cffff9020" .. L["Group"] .. " (" .. suggestedGroup .. ")|r")
					end
					-- Rewards (money, experience, items and item choices)
					local rewards = {}
					local money = GetQuestLogRewardMoney and Safe(GetQuestLogRewardMoney(questID))
					if type(money) == "number" and money > 0 then tinsert(rewards, CoinText(money)) end
					local xp = GetQuestLogRewardXP and Safe(GetQuestLogRewardXP(questID))
					if type(xp) == "number" and xp > 0 then tinsert(rewards, xp .. " " .. L["XP"]) end
					local function ItemIcons(count, getInfo)
						local icons = {}
						count = Safe(count)
						for i = 1, type(count) == "number" and count or 0 do
							local void, texture, number = Safe(getInfo(i, questID))
							if texture then tinsert(icons, "|T" .. texture .. ":14:14|t" .. ((type(number) == "number" and number > 1) and ("x" .. number) or "")) end
						end
						return table.concat(icons, " ")
					end
					if GetNumQuestLogRewards and GetQuestLogRewardInfo then
						local icons = ItemIcons(GetNumQuestLogRewards(questID), GetQuestLogRewardInfo)
						if icons ~= "" then tinsert(rewards, icons) end
					end
					if GetNumQuestLogChoices and GetQuestLogChoiceInfo then
						local icons = ItemIcons(GetNumQuestLogChoices(questID), GetQuestLogChoiceInfo)
						if icons ~= "" then tinsert(rewards, L["Choose"] .. " " .. icons) end
					end
					if #rewards > 0 then tinsert(parts, L["Rewards"] .. ": " .. table.concat(rewards, "  ")) end
					return parts
				end
				-- Show the talent summary on the card (other players are inspected first)
				local function ShowPlayerTalents(unit)
					local card = LeaPlusLC.IDCard
					unit = Safe(unit)
					if not card or not unit or not UnitExists(unit) then return end
					-- Mythic+ score (another player's can come with their inspect, so it is asked for again then)
					if not card.mythicShown then
						local mythic = MythicScoreText(unit)
						if mythic then card:AddDetail(mythic) card.mythicShown = true end
					end
					local classFile = Safe(select(2, UnitClass(unit)))
					if Safe(UnitIsUnit(unit, "player")) then
						local activeConfigID = C_ClassTalents and C_ClassTalents.GetActiveConfigID and Safe(C_ClassTalents.GetActiveConfigID())
						if isForever then
							card.talents:SetText(TalentSummary(activeConfigID, classFile) or "")
						else
							card.talents:SetText(RetailTalentSummary(unit, activeConfigID, true) or "")
						end
						local itemLevel = AverageItemLevel("player")
						if itemLevel then card:AddDetail(L["Item level"] .. " |cffffffff" .. itemLevel .. "|r") end
						return
					end
					local guid = Safe(UnitGUID(unit))
					if not guid or not NotifyInspect or not CanInspect or not Safe(CanInspect(unit)) then return end
					if InspectFrame and InspectFrame:IsShown() then return end -- Do not disturb the inspect window
					card.inspectGUID = guid
					card.inspectClassFile = classFile
					card.inspectClassID = Safe(select(3, UnitClass(unit)))
					card.inspectUnit = unit
					card.inspectTime = GetTime() -- Each inspect starts with fresh gear for the model viewer
					card.talents:SetText("|cff8a8a90" .. L["Reading talents..."] .. "|r")
					card:SetItemLevelDetail("|cff8a8a90" .. L["Item level"] .. " ...|r") -- Shown until the inspect has come back
					if not LeaPlusLC.IDCardInspect then
						LeaPlusLC.IDCardInspect = CreateFrame("Frame")
						LeaPlusLC.IDCardInspect:SetScript("OnEvent", function(self, event, readyGUID)
							local c = LeaPlusLC.IDCard
							readyGUID = Safe(readyGUID)
							if not c or not c.inspectGUID or not readyGUID or readyGUID ~= c.inspectGUID then return end
							c.inspectGUID = nil
							LeaPlusLC.IDInspectPending = nil
							self:UnregisterEvent("INSPECT_READY")
							local inspectConfigID = Constants and Constants.TraitConsts and Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID or -1
							local classFile, classID, firstUnit = c.inspectClassFile, c.inspectClassID, c.inspectUnit
							-- Talents are only ever read live from the player, so the card needs to find them when the answer arrives
							-- They are read straight away and again shortly after (in case the game had not finished updating them), and the inspect data is only cleared after the last read
							-- If the player cannot be found when the answer arrives, the card does not keep looking for them
							c.talentsReadID = (c.talentsReadID or 0) + 1
							local readID = c.talentsReadID
							local delays = {0, 0.3, 1}
							local itemLevelDone = false
							local function ClearInspect()
								if ClearInspectPlayer and not LeaPlusLC.IDInspectPending and not (InspectFrame and InspectFrame:IsShown()) then ClearInspectPlayer() end
							end
							-- Stop if the card has been closed or is showing something else now
							local function CardChanged()
								return not c:IsShown() or c.talentsReadID ~= readID
							end
							-- Gear for the model viewer (the weapons, and how they look on the player such as a transmog or a paired weapon), read while
							-- the inspect data is there and kept after it is cleared, and the viewer is updated if it shows this player
							c.gearReadingGUID = readyGUID
							local function ReadGear(unit)
								LeaPlusLC.IDGear = LeaPlusLC.IDGear or {}
								local gear = LeaPlusLC.IDGear[readyGUID]
								if not gear or gear.inspectTime ~= c.inspectTime then gear = {inspectTime = c.inspectTime} LeaPlusLC.IDGear = {[readyGUID] = gear} end -- Only the player just inspected is kept
								local RequestLoad = C_Item and C_Item.RequestLoadItemDataByID
								local complete, newWeapon = true, false
								for slot = 1, 19 do
									local link = Safe(GetInventoryItemLink(unit, slot))
									if link then
										if not gear[slot] then
											gear[slot] = link
											if slot == 16 or slot == 17 then newWeapon = true end
										end
									else
										local itemID = GetInventoryItemID and Safe(GetInventoryItemID(unit, slot))
										if itemID then
											complete = false
											if RequestLoad then pcall(RequestLoad, itemID) end
										end
									end
								end
								if not gear.looks and C_TransmogCollection and C_TransmogCollection.GetInspectItemTransmogInfoList then
									local ok, looks = pcall(C_TransmogCollection.GetInspectItemTransmogInfoList)
									if ok and SafeTable(looks) and next(looks) then gear.looks = looks newWeapon = true end
								end
								if complete then gear.complete = true end
								local viewer = LeaPlusLC.IDViewer
								if viewer and (newWeapon or complete) then viewer:ApplyInspectGear() viewer:CheckReveal() end
							end
							-- The last read: use whatever gear could be read
							local function FinishGear()
								c.gearReadingGUID = nil
								local gear = LeaPlusLC.IDGear and LeaPlusLC.IDGear[readyGUID]
								if gear then gear.complete = true end
								local viewer = LeaPlusLC.IDViewer
								if viewer then viewer:ApplyInspectGear() viewer:CheckReveal() end
							end
							-- Read the talents from the player if they can be found (gives true when they were read)
							local function ReadLive()
								-- Find the player again (the pointer may have moved off them since the key was pressed)
								local foundUnit = FindUnitByGUID(readyGUID, firstUnit)
								if not foundUnit then return false end
								ReadGear(foundUnit)
								local text
								if isForever then
									text = TalentSummary(inspectConfigID, classFile)
								else
									text = RetailTalentSummary(foundUnit, inspectConfigID, false, classID)
								end
								c.talents:SetText(text or "")
								-- Average item level from the inspected gear (added once)
								if not itemLevelDone then
									itemLevelDone = true
									local itemLevel = AverageItemLevel(foundUnit, true)
									c:SetItemLevelDetail(itemLevel and (L["Item level"] .. " |cffffffff" .. itemLevel .. "|r") or nil)
								end
								if not c.mythicShown then
									local mythic = MythicScoreText(foundUnit)
									if mythic then c:AddDetail(mythic) c.mythicShown = true end
								end
								return true
							end
							local function ReadTalents(step)
								if CardChanged() then ClearInspect() return end
								if not ReadLive() and step == 1 then
									-- The player could not be found when the answer arrived (the pointer moved off them or they went out of range)
									-- The reply is kept, and the talents and item level are read as soon as the player can be found again (pointed at, targeted or their nameplate shown)
									local name = c.title:GetText() or ""
									c.talents:SetText("|cff8a8a90" .. string.format(L["Move your mouse over %s to show their talents."], name) .. "|r")
									if not itemLevelDone then c:SetItemLevelDetail("|cff8a8a90" .. string.format(L["Move your mouse over %s to show their item level."], name) .. "|r") end
									LeaPlusLC.IDTalentWait = {guid = readyGUID, resume = function() ReadTalents(1) end}
									c.gearReadingGUID = nil
									if LeaPlusLC.IDViewer then LeaPlusLC.IDViewer:CheckReveal() end
									if not LeaPlusLC.IDTalentWatch then
										local watch = CreateFrame("Frame")
										LeaPlusLC.IDTalentWatch = watch
										watch:SetScript("OnEvent", function()
											local wait, card = LeaPlusLC.IDTalentWait, LeaPlusLC.IDCard
											if not wait then return end
											if not card or not card:IsShown() then LeaPlusLC.IDTalentWait = nil return end
											if not FindUnitByGUID(wait.guid) then return end
											LeaPlusLC.IDTalentWait = nil
											wait.resume()
										end)
										watch:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
										watch:RegisterEvent("PLAYER_TARGET_CHANGED")
										watch:RegisterEvent("NAME_PLATE_UNIT_ADDED")
										watch:RegisterEvent("GROUP_ROSTER_UPDATE")
									end
									return
								end
								-- Read again shortly after while the player can still be found (a later read that cannot find them leaves the talents as they are)
								if step < #delays then
									C_Timer.After(delays[step + 1] - delays[step], function() ReadTalents(step + 1) end)
								else
									FinishGear()
									ClearInspect()
								end
							end
							ReadTalents(1)
						end)
					end
					LeaPlusLC.IDCardInspect:RegisterEvent("INSPECT_READY")
					-- Only ask the server once per player at a time (asking again quickly can be ignored, so the answer never comes)
					local pending = LeaPlusLC.IDInspectPending
					if not (pending and pending.guid == guid and GetTime() - pending.time < 4) then
						LeaPlusLC.IDInspectPending = {guid = guid, time = GetTime()}
						NotifyInspect(unit)
					end
					C_Timer.After(4, function()
						local c = LeaPlusLC.IDCard
						if c and c.inspectGUID == guid then
							c.inspectGUID = nil
							LeaPlusLC.IDCardInspect:UnregisterEvent("INSPECT_READY")
							c.talents:SetText("|cff8a8a90" .. L["Talents are not available right now."] .. "|r")
							c:SetItemLevelDetail(nil) -- No reply, so no item level
						end
					end)
				end
				-- Retries happen when a new player or creature has not finished loading (see the unknown tooltip below)
				if arg1 ~= "retry" and arg1 ~= "upgrade" then
					LeaPlusLC.IDRetries, LeaPlusLC.IDUpgrades = 0, 0
					-- Remember what was under the mouse when the key was pressed (retries only show a card for that, never for something else)
					LeaPlusLC.IDPressID = (LeaPlusLC.IDPressID or 0) + 1
					LeaPlusLC.IDPressFocus = GetMouseFoci and GetMouseFoci()[1] or nil
					LeaPlusLC.IDPressHadUnit = Safe(UnitExists("mouseover")) and true or false
					LeaPlusLC.IDPressGUID = Safe(UnitGUID("mouseover"))
					-- Whether the key was pressed on a unit at all (a mailbox, the ground and so on are not units)
					local tipData = GameTooltip:IsShown() and SafeTable(GameTooltip.GetTooltipData and GameTooltip:GetTooltipData())
					LeaPlusLC.IDPressOnUnit = LeaPlusLC.IDPressHadUnit or (tipData and Safe(tipData.type) == Enum.TooltipDataType.Unit) or false
				elseif arg1 == "retry" then
					-- The mouse has moved on to something else since the key was pressed, so give up (the key was not pressed for that)
					local focus = GetMouseFoci and GetMouseFoci()[1] or nil
					if focus ~= LeaPlusLC.IDPressFocus then LeaPlusLC.IDRetries = 0 return end
					if LeaPlusLC.IDPressHadUnit and not Safe(UnitExists("mouseover")) then LeaPlusLC.IDRetries = 0 return end
					local guid = Safe(UnitGUID("mouseover"))
					if LeaPlusLC.IDPressGUID and guid and guid ~= LeaPlusLC.IDPressGUID then LeaPlusLC.IDRetries = 0 return end
					-- The key was pressed on a unit the game was hiding, and the unit now under the mouse can be read, so it is a different unit
					if LeaPlusLC.IDPressHadUnit and not LeaPlusLC.IDPressGUID and guid then LeaPlusLC.IDRetries = 0 return end
					-- The key was not pressed on a unit (such as a mailbox), and the mouse is now over one, so it is a different thing
					if not LeaPlusLC.IDPressOnUnit and Safe(UnitExists("mouseover")) then LeaPlusLC.IDRetries = 0 return end
				end
				-- Model viewer option (on unless it has been switched off with the checkbox on the card)
				if LeaPlusLC.IDModelOn == nil then LeaPlusLC.IDModelOn = not (LeaPlusDB and LeaPlusDB["IDModelOn"] == false) end
				-- Find the unit frame under the mouse (used by the aura picker below)
				if LeaPlusLC.AuraPicker then LeaPlusLC.AuraPicker:Hide() end
				local pickerUnit
				if not forceUnit then -- Not when a player was given
					local mouseFocus = GetMouseFoci and GetMouseFoci()[1]
					while mouseFocus and not pickerUnit do
						if mouseFocus.IsForbidden and mouseFocus:IsForbidden() then break end
						local unit = Safe(mouseFocus.unit)
						if type(unit) == "string" and UnitExists(unit) then pickerUnit = unit end
						mouseFocus = mouseFocus:GetParent()
					end
				end
				if pickerUnit and LeaPlusLC.IDCard then LeaPlusLC.IDCard:Hide() end
				-- Show the card for what is under the mouse
				local function ShowCardForMouse()
					-- Show info card for tooltip
					if not LeaPlusLC.WowheadLock then
						-- Set Wowhead link prefix
						if GameLocale == "deDE" then LeaPlusLC.WowheadLock = "www.wowhead.com/de"
						elseif GameLocale == "esMX" then LeaPlusLC.WowheadLock = "www.wowhead.com/mx"
						elseif GameLocale == "esES" then LeaPlusLC.WowheadLock = "www.wowhead.com/es"
						elseif GameLocale == "frFR" then LeaPlusLC.WowheadLock = "www.wowhead.com/fr"
						elseif GameLocale == "itIT" then LeaPlusLC.WowheadLock = "www.wowhead.com/it"
						elseif GameLocale == "ptBR" then LeaPlusLC.WowheadLock = "www.wowhead.com/pt"
						elseif GameLocale == "ruRU" then LeaPlusLC.WowheadLock = "www.wowhead.com/ru"
						elseif GameLocale == "koKR" then LeaPlusLC.WowheadLock = "www.wowhead.com/ko"
						elseif GameLocale == "zhCN" then LeaPlusLC.WowheadLock = "www.wowhead.com/cn"
						elseif GameLocale == "zhTW" then LeaPlusLC.WowheadLock = "www.wowhead.com/tw"
						else							 LeaPlusLC.WowheadLock = "www.wowhead.com"
						end
					end
					if not LeaPlusLC.BlizzardLock then
						-- Set Blizzard link prefix (https://wowpedia.fandom.com/wiki/Localization) (region will be added by website automatically)
							if GameLocale == "deDE" then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/de-de/character/eu/" -- Germany
						elseif GameLocale == "frFR" then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/fr-fr/character/eu/" -- France
						elseif GameLocale == "itIT" then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/it-it/character/eu/" -- Italy
						elseif GameLocale == "ruRU" then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/ru-ru/character/eu/" -- Russia
						elseif GameLocale == "koKR" then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/ko-kr/character/kr/" -- Korea
						elseif GameLocale == "zhTW" then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/zh-tw/character/tw/" -- Tiawan
						elseif GameLocale == "esES" and GetCurrentRegion() == 1 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/es-es/character/us/" -- Spain (esES connected to US)
						elseif GameLocale == "esES" and GetCurrentRegion() == 3 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/es-es/character/eu/" -- Spain (esES connected to EU)
						elseif GameLocale == "esMX" and GetCurrentRegion() == 1 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/es-mx/character/us/" -- Mexico (esMX connected to US)
						elseif GameLocale == "esMX" and GetCurrentRegion() == 3 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/es-mx/character/eu/" -- Spain (esMX connected to EU)
						elseif GameLocale == "ptBR" and GetCurrentRegion() == 1 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/pt-br/character/us/" -- Brazil (ptBR connected to US)
						elseif GameLocale == "ptBR" and GetCurrentRegion() == 3 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/pt-br/character/eu/" -- Portugal (ptBR connected to US)
						elseif GameLocale == "enUS" and GetCurrentRegion() == 3 then LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/en-gb/character/eu/" -- UK (enUS connected to Europe)
						else 														 LeaPlusLC.BlizzardLock = "https://worldofwarcraft.com/en-us/character/us/" -- US (default)
						end
					end
					-- Player card (for the player under the mouse, or the player given to ShowInfoCard such as from the dressing room)
					local function ShowPlayerCard(unitFocus)
						-- Show armory link
						local name, realm = Safe(UnitName(unitFocus))
						local surname = isForever and realm or nil -- On Forever, the second name is the surname (and there is no armory link yet)
						local class = Safe(UnitClassBase(unitFocus))
						local color = class and RAID_CLASS_COLORS[class]
						if not color then return end
						if not realm then realm = Safe(GetNormalizedRealmName()) end
						if not (name and realm) then return end
						-- Debug
						-- local realm = "StrandoftheAncients" -- Debug
						-- Chinese armory not available
						if GameLocale == "zhCN" then return end
						-- Fix non-standard names
							if realm == "Area52" then realm = "Area-52"
						elseif realm == "AzjolNerub" then realm = "AzjolNerub"
						elseif realm == "Chantséternels" then realm = "Chants-Éternels"
						elseif realm == "ConfrérieduThorium" then realm = "Confrérie-du-Thorium"
						elseif realm == "ConseildesOmbres" then realm = "Conseil-des-Ombres"
						elseif realm == "CultedelaRivenoire" then realm = "Culte-de-la-Rive-noire"
						elseif realm == "DerRatvonDalaran" then realm = "Der-Rat-von-Dalaran"
						elseif realm == "DieewigeWacht" then realm = "Die-ewige-Wacht"
						elseif realm == "FestungderStürme" then realm = "Festung-der-Stürme"
						elseif realm == "KultderVerdammten" then realm = "Kult-der-Verdammten"
						elseif realm == "LaCroisadeécarlate" then realm = "La-Croisade-Écarlate"
						elseif realm == "MarécagedeZangar" then realm = "Marécage-de-Zangar"
						elseif realm == "Pozzodell'Eternità" then realm = "Pozzo-dellEternità"
						elseif realm == "Templenoir" then realm = "Temple-noir"
						elseif realm == "VanCleef" then realm = "Vancleef"
						elseif realm == "ZirkeldesCenarius" then realm = "Zirkel-des-Cenarius"
						-- Fix Russian names
						elseif realm == "СвежевательДуш" then realm = "Свежеватель-Душ"
						elseif realm == "СтражСмерти" then realm = "Страж-Смерти"
						elseif realm == "Ревущийфьорд" then realm = "Ревущий-фьорд"
						elseif realm == "ТкачСмерти" then realm = "Ткач-Смерти"
						elseif realm == "Борейскаятундра" then realm = "Борейская-тундра"
						elseif realm == "Ясеневыйлес" then realm = "Ясеневый-лес"
						elseif realm == "ПиратскаяБухта" then realm = "Пиратская-Бухта"
						elseif realm == "ВечнаяПесня" then realm = "Вечная-Песня"
						elseif realm == "ЧерныйШрам" then realm = "Черный-Шрам"
						elseif realm == "ВестникРока" then realm = "Вестник-Рока"
						-- Fix all other names
						else
							-- Realm name is not one of the above so fix it
							realm = realm:gsub("(%l[of])(%u)", "-%1-%2") -- Add hyphen after of if capital follows of (CavernsofTime becomes Cavernsof-Time)
							realm = realm:gsub("(ofthe)", "-of-the-") -- Replace ofthe with -of-the- (ShrineoftheDormantFlame becomes Shrine-of-the-DormantFlame)
							realm = realm:gsub("(%l)(%u)", "%1 %2") -- Add space before capital letters (CavernsofTime becomes Cavernsof Time)
							realm = realm:gsub(" ", "-") -- Replace space with hyphen (Cavernsof Time becomes Cavernsof-Time)
							realm = realm:gsub("'", "") -- Remove apostrophe
							realm = realm:gsub("[(]", "-") -- Replace opening parentheses with hyphen
							realm = realm:gsub("[)]", "") -- Remove closing parentheses
						end
						-- print(realm) -- Debug
						local armoryLink = LeaPlusLC.BlizzardLock .. strlower(realm) .. "/" .. strlower(name)
						realm = realm:gsub("-", " ") -- Replace hyphen with space
						local playerColor = {color.r, color.g, color.b}
						local playerLevel = Safe(UnitLevel(unitFocus))
						local playerName, realmText = name, realm
						if surname and surname ~= "" then playerName, realmText = name .. " " .. surname, Safe(GetRealmName()) or "" end
						local playerNote = realmText
						if type(playerLevel) == "number" and playerLevel > 0 then playerNote = L["Level"] .. " " .. playerLevel .. " " .. (Safe(UnitClass(unitFocus)) or "") .. "    " .. realmText end
						local unitGUID = Safe(UnitGUID(unitFocus))
						ShowIDCard({kind = L["Player"], name = playerName, sub = playerNote, url = not isForever and armoryLink or nil, unit = unitFocus, color = playerColor, nameColor = playerColor, view = {mode = "unit", isPlayer = true, unit = unitFocus, guid = unitGUID, text = PlayerText(unitFocus)}, talents = true, details = PlayerDetails(unitFocus, unitGUID)})
						ShowPlayerTalents(unitFocus)
					end
					-- A player was given, so show their card and nothing else
					if forceUnit then
						if Safe(UnitExists(forceUnit)) and Safe(UnitIsPlayer(forceUnit)) then ShowPlayerCard(forceUnit) end
						return
					end
					-- Mount journal, pet journal, toy box and achievements (most of these have no tooltip, so the frame under the mouse is used)
					-- Only values the game has stored on its own frames are read (nothing on them is changed, hooked or called), so nothing is tainted
					do
						local mountID, speciesID, petID, toyID, achievementID, abilityID
						local inMounts, inPets, inToys, inAchievements, inCategories
						local frame = GetMouseFoci and GetMouseFoci()[1]
						while frame do
							if frame.IsForbidden and frame:IsForbidden() then mountID, speciesID, toyID, achievementID, abilityID = nil, nil, nil, nil, nil break end
							-- What the frame under the mouse (or one of its parents) is showing
							if not (mountID or speciesID or toyID or achievementID or abilityID) then
								-- Battle pet abilities (checked first, as ability buttons also know their pet)
								local id = Safe(frame.abilityID)
								if type(id) == "number" and id > 0 then abilityID = id end
								id = Safe(frame.mountID)
								if not abilityID and type(id) == "number" and id > 0 then mountID = id end
								id = Safe(frame.speciesID)
								if not (abilityID or mountID) and type(id) == "number" and id > 0 then
									speciesID = id
									local guid = Safe(frame.petID)
									if type(guid) == "string" then petID = guid end
								end
								id = Safe(frame.itemID)
								if not (abilityID or mountID or speciesID) and type(id) == "number" and id > 0 then toyID = id end
								id = Safe(frame.achievementID)
								if type(id) ~= "number" and not Safe(frame.isHeader) then id = Safe(frame.id) end
								if not (abilityID or mountID or speciesID or toyID) and type(id) == "number" and id > 0 then achievementID = id end
							end
							-- Which window it is in
							if frame == MountJournal then inMounts = true
							elseif frame == PetJournal then inPets = true
							elseif frame == ToyBox then inToys = true
							elseif frame == AchievementFrame then inAchievements = true
							elseif AchievementFrameCategories and frame == AchievementFrameCategories then inCategories = true end
							frame = frame:GetParent()
						end
						-- Only use what belongs to the window it was found in
						if not inMounts then mountID = nil end
						if not inPets then speciesID, petID, abilityID = nil, nil, nil end
						if not inToys then toyID = nil end
						if not inAchievements or inCategories then achievementID = nil end
						-- Not over a mount or pet in the list, so use the one chosen in the journal (such as when pointing at its model)
						if inMounts and not mountID and MountJournal then
							local id = Safe(MountJournal.selectedMountID)
							if type(id) == "number" and id > 0 then mountID = id end
						end
						if inPets and not speciesID and not abilityID and PetJournalPetCard then
							local id = Safe(PetJournalPetCard.speciesID)
							if type(id) == "number" and id > 0 then
								speciesID = id
								local guid = Safe(PetJournalPetCard.petID)
								if type(guid) == "string" then petID = guid end
							end
						end
						local colorMount, colorPet, colorAchievement = {0.55, 0.8, 1}, {0.4, 0.9, 0.55}, {1, 0.82, 0}
						local function Collected(has) return has and ("|cff40ff40" .. L["Collected"] .. "|r") or Grey(L["Not collected"]) end
						-- Battle pet ability
						if abilityID and C_PetJournal and C_PetJournal.GetPetAbilityInfo then
							local name, icon, petType = Safe(C_PetJournal.GetPetAbilityInfo(abilityID))
							if name then
								local details = {}
								local typeName = petType and _G["BATTLE_PET_NAME_" .. petType]
								if type(typeName) == "string" then tinsert(details, typeName) end
								-- Cooldown and how many rounds it lasts
								if C_PetBattles and C_PetBattles.GetAbilityInfoByID then
									local void, void, void, cooldown, void, turns = Safe(C_PetBattles.GetAbilityInfoByID(abilityID))
									if type(cooldown) == "number" and cooldown > 0 then tinsert(details, L["Cooldown"] .. " |cffffffff" .. cooldown .. "|r " .. L["rounds"]) end
									if type(turns) == "number" and turns > 1 then tinsert(details, L["Lasts"] .. " |cffffffff" .. turns .. "|r " .. L["rounds"]) end
								end
								ShowIDCard({kind = L["Pet ability"], name = name, id = abilityID, url = "https://" .. LeaPlusLC.WowheadLock .. "/pet-ability=" .. abilityID, icon = icon, color = colorSpell, details = details})
								return
							end
						end
						-- Mount
						if mountID and C_MountJournal then
							local name, spellID, icon, void, void, void, void, isFactionSpecific, faction, void, isCollected = Safe(C_MountJournal.GetMountInfoByID(mountID))
							if name and spellID then
								local displayID, description, source = Safe(C_MountJournal.GetMountInfoExtraByID(mountID))
								if not displayID and C_MountJournal.GetMountAllCreatureDisplayInfoByID then
									-- Mounts with more than one look: use the first
									local displays = SafeTable(C_MountJournal.GetMountAllCreatureDisplayInfoByID(mountID))
									local first = displays and SafeTable(displays[1])
									displayID = first and Safe(first.creatureDisplayID)
								end
								local details = {Collected(isCollected)}
								if isFactionSpecific then
									if faction == 0 and FACTION_HORDE then tinsert(details, "|cffff6060" .. FACTION_HORDE .. "|r")
									elseif faction == 1 and FACTION_ALLIANCE then tinsert(details, "|cff66bbff" .. FACTION_ALLIANCE .. "|r") end
								end
								local text = {}
								if type(description) == "string" and description ~= "" then tinsert(text, description) end
								if type(source) == "string" and source ~= "" then tinsert(text, source) end
								ShowIDCard({kind = L["Mount"], name = name, id = spellID, note = L["Mount ID"] .. " |cffffffff" .. mountID .. "|r", url = "https://" .. LeaPlusLC.WowheadLock .. "/spell=" .. spellID, icon = icon, color = colorMount, view = {mode = "display", displayID = displayID, text = #text > 0 and table.concat(text, "\n\n") or nil}, details = details})
								return
							end
						end
						-- Pet
						if speciesID and C_PetJournal then
							local name, icon, petType, npcID, source, description, void, canBattle, isTradeable, void, void, displayID = Safe(C_PetJournal.GetPetInfoBySpeciesID(speciesID))
							if name then
								local details = {}
								local color = colorPet
								-- Your own pet: its look, level and quality
								if petID then
									local void, customName, level, void, void, ownDisplayID = Safe(C_PetJournal.GetPetInfoByPetID(petID))
									if type(ownDisplayID) == "number" and ownDisplayID > 0 then displayID = ownDisplayID end
									if type(level) == "number" and level > 0 then tinsert(details, L["Level"] .. " |cffffffff" .. level .. "|r") end
									if type(customName) == "string" and customName ~= "" then tinsert(details, "|cffffffff\"" .. customName .. "\"|r") end
									local rarity = Safe(select(5, C_PetJournal.GetPetStats(petID)))
									local qualityColor = type(rarity) == "number" and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[rarity - 1]
									if qualityColor then color = {qualityColor.r, qualityColor.g, qualityColor.b} end
								end
								local typeName = petType and _G["BATTLE_PET_NAME_" .. petType]
								if type(typeName) == "string" then tinsert(details, typeName) end
								local numCollected, limit = Safe(C_PetJournal.GetNumCollectedInfo(speciesID))
								if type(numCollected) == "number" and type(limit) == "number" then
									tinsert(details, numCollected > 0 and ("|cff40ff40" .. L["Collected"] .. " " .. numCollected .. "/" .. limit .. "|r") or Grey(L["Not collected"]))
								end
								if canBattle == false then tinsert(details, Grey(L["Cannot battle"])) end
								if isTradeable == false then tinsert(details, Grey(L["Cannot be traded"])) end
								local text = {}
								if type(description) == "string" and description ~= "" then tinsert(text, description) end
								if type(source) == "string" and source ~= "" then tinsert(text, source) end
								ShowIDCard({kind = L["Pet"], name = name, id = speciesID, url = (type(npcID) == "number" and npcID > 0) and ("https://" .. LeaPlusLC.WowheadLock .. "/npc=" .. npcID) or nil, icon = icon, color = color, nameColor = color, view = {mode = "display", displayID = displayID, text = #text > 0 and table.concat(text, "\n\n") or nil}, details = details})
								return
							end
						end
						-- Toy
						if toyID and C_ToyBox then
							local itemID, name, icon, void, void, quality = Safe(C_ToyBox.GetToyInfo(toyID))
							if itemID and name then
								local qualityColor = type(quality) == "number" and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
								local nameColor = qualityColor and {qualityColor.r, qualityColor.g, qualityColor.b} or {1, 1, 1}
								local details = {Collected(PlayerHasToy and Safe(PlayerHasToy(itemID)))}
								local link = C_ToyBox.GetToyLink and Safe(C_ToyBox.GetToyLink(itemID))
								if link then for void, part in ipairs(ItemDetails(link)) do tinsert(details, part) end end
								ShowIDCard({kind = L["Toy"], name = name, id = itemID, url = "https://" .. LeaPlusLC.WowheadLock .. "/item=" .. itemID, icon = icon, color = nameColor, nameColor = nameColor, details = details})
								return
							end
						end
						-- Achievement (and statistic)
						if achievementID and GetAchievementInfo then
							local id, name, points, completed, month, day, year, void, void, icon, rewardText, isGuild, void, void, isStatistic = Safe(GetAchievementInfo(achievementID))
							if id and name then
								local details = {}
								if type(points) == "number" and points > 0 then tinsert(details, L["Points"] .. " |cffffffff" .. points .. "|r") end
								if completed then
									local date = (FormatShortDate and day and month and year) and Safe(FormatShortDate(day, month, year)) or nil
									tinsert(details, "|cff40ff40" .. L["Complete"] .. (date and (" " .. date) or "") .. "|r")
								elseif not isStatistic then
									tinsert(details, Grey(L["Not complete"]))
								end
								if isGuild then tinsert(details, "|cff40ff40" .. L["Guild"] .. "|r") end
								if type(rewardText) == "string" and rewardText ~= "" then tinsert(details, "|cffffd100" .. rewardText .. "|r") end
								local kind = isStatistic and L["Statistic"] or L["Achievement"]
								ShowIDCard({kind = kind, name = name, id = id, url = "https://" .. LeaPlusLC.WowheadLock .. (isStatistic and "/statistic=" or "/achievement=") .. id, icon = icon, color = colorAchievement, details = details})
								return
							end
						end
					end
					-- Quest tracker (the list of quests under the minimap)
					local questID, questTitle
					do
						-- Modern tracker: look for a quest ID on the frame under the mouse or its parents
						local frame = GetMouseFoci and GetMouseFoci()[1]
						while frame and not questID do
							if frame.IsForbidden and frame:IsForbidden() then break end
							local id = Safe(frame.questID)
							if not id and Safe(frame.id) and frame.GetDebugName then
								local debugName = Safe(frame:GetDebugName())
								if type(debugName) == "string" and debugName:find("Quest") then id = Safe(frame.id) end
							end
							if type(id) == "number" then
								local title = Safe(C_QuestLog.GetTitleForQuestID(id))
								if title then questID, questTitle = id, title end
							end
							frame = frame:GetParent()
						end
						-- Classic tracker: find the hovered line and walk up to its quest title
						if not questID and QuestWatchFrame and QuestWatchFrame:IsShown() and QuestWatchFrame:IsMouseOver() then
							local hovered
							for i = 1, 50 do
								local watchLine = _G["QuestWatchLine" .. i]
								if not watchLine then break end
								if watchLine:IsShown() and watchLine:IsMouseOver() then hovered = i break end
							end
							if hovered then
								local titles = {}
								for i = 1, (Safe(C_QuestLog.GetNumQuestLogEntries()) or 0) do
									local info = SafeTable(C_QuestLog.GetInfo(i))
									local title, id = info and Safe(info.title), info and Safe(info.questID)
									if info and not Safe(info.isHeader) and type(title) == "string" and id then titles[title] = id end
								end
								for i = hovered, 1, -1 do
									local text = Safe(_G["QuestWatchLine" .. i]:GetText())
									if type(text) == "string" then
										text = strtrim((text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
										if titles[text] then questID, questTitle = titles[text], text break end
									end
								end
							end
						end
					end
					if questID then
						ShowIDCard({kind = L["Quest"], name = questTitle, id = questID, url = "https://" .. LeaPlusLC.WowheadLock .. "/quest=" .. questID, icon = "Interface\\Icons\\INV_Scroll_03", color = colorQuest, view = {mode = "icon", icon = "Interface\\Icons\\INV_Scroll_03", text = QuestText(questID)}, details = QuestDetails(questID)})
						return
					end
					-- ItemRefTooltip or GameTooltip
					local tooltip
					if ItemRefTooltip:IsMouseMotionFocus() then tooltip = ItemRefTooltip else tooltip = GameTooltip end
					-- Process tooltip
					if not tooltip:IsShown() then return end
					-- Buff or debuff (tooltip data, such as the buff frame)
					local tipData = SafeTable(tooltip.GetTooltipData and tooltip:GetTooltipData())
					if tipData and Safe(tipData.type) == Enum.TooltipDataType.UnitAura then
						local auraID = tipData.id
						if IsSecret(auraID) then
							-- Hidden by the game: show its name, ID and link without reading them
							local titleLine = _G[tooltip:GetName() .. "TextLeft1"]
							ShowHiddenAuraCard(auraID, titleLine and titleLine:GetText())
							return
						end
						if auraID then
							local auraName = Safe((C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(auraID)) or (GetSpellInfo and GetSpellInfo(auraID))) or Safe(GameTooltipTextLeft1:GetText()) or ""
							-- Debuff if the player or target has a debuff with this spell ID, otherwise buff
							local auraType = "Buff"
							for void, unit in ipairs({"player", "target"}) do
								if UnitExists(unit) then
									for i = 1, 40 do
										local aura, done = GetAura(unit, i, true)
										if done then break end
										if aura and Safe(aura.spellId) == auraID then auraType = "Debuff" break end
									end
								end
							end
							pickerUnit = nil -- Aura found so the aura picker is not needed
							ShowIDCard({kind = L[auraType], name = auraName, id = auraID, url = "https://" .. LeaPlusLC.WowheadLock .. "/spell=" .. auraID, icon = SpellIcon(auraID), color = auraType == "Debuff" and colorDebuff or colorBuff, view = {mode = "icon", icon = SpellIcon(auraID), text = SpellText(auraID)}, details = AuraDetails(nil, auraID)})
							return
						end
					end
					-- Item
					local itemLink = Safe(select(2, tooltip:GetItem()))
					if itemLink then
						local itemID = Safe(GetItemInfoFromHyperlink(itemLink))
						if itemID then
							local GetInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
							local itemName, void, itemQuality, void, void, void, void, void, void, itemIcon = Safe(GetInfo(itemLink))
							local qualityColor = itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemQuality]
							local nameColor = qualityColor and {qualityColor.r, qualityColor.g, qualityColor.b} or {1, 1, 1}
							itemIcon = itemIcon or (C_Item and C_Item.GetItemIconByID and Safe(C_Item.GetItemIconByID(itemID))) or (GetItemIcon and Safe(GetItemIcon(itemID)))
							ShowIDCard({kind = L["Item"], name = itemName or itemLink, id = itemID, url = "https://" .. LeaPlusLC.WowheadLock .. "/item=" .. itemID, icon = itemIcon, color = nameColor, nameColor = nameColor, view = {mode = IsEquippable(itemLink) and "item" or "icon", link = itemLink, icon = itemIcon, text = ItemFlavour(tooltip)}, details = ItemDetails(itemLink, tooltip)})
							return
						end
					end
					-- Spell
					local name, spellID = Safe(tooltip:GetSpell())
					if name and spellID then
						ShowIDCard({kind = L["Spell"], name = name, id = spellID, url = "https://" .. LeaPlusLC.WowheadLock .. "/spell=" .. spellID, icon = SpellIcon(spellID), color = colorSpell, view = {mode = "icon", icon = SpellIcon(spellID), text = SpellText(spellID)}, details = SpellDetails(spellID)})
						return
					end
					-- Buff or debuff (match the tooltip title against auras on likely units)
					if not WorldFrame:IsMouseMotionFocus() then
						local titleLine = _G[tooltip:GetName() .. "TextLeft1"]
						local auraTitle = titleLine and Safe(titleLine:GetText())
						if auraTitle then
							local auraUnits = {}
							local tipUnit = Safe(select(2, tooltip:GetUnit()))
							if tipUnit then tinsert(auraUnits, tipUnit) end
							for void, unit in ipairs({"player", "target", "focus", "pet", "party1", "party2", "party3", "party4"}) do tinsert(auraUnits, unit) end
							for void, unit in ipairs(auraUnits) do
								if UnitExists(unit) then
									for void, auraType in ipairs({"Buff", "Debuff"}) do
										for i = 1, 40 do
											local aura, done = GetAura(unit, i, auraType == "Debuff")
											if done then break end
											local auraName, auraID = aura and Safe(aura.name), aura and Safe(aura.spellId)
											if auraName and auraID and auraName == auraTitle then
												local auraIcon = Safe(aura.icon) or SpellIcon(auraID)
												pickerUnit = nil -- Aura found so the aura picker is not needed
												ShowIDCard({kind = L[auraType], name = auraName, id = auraID, url = "https://" .. LeaPlusLC.WowheadLock .. "/spell=" .. auraID, icon = auraIcon, color = auraType == "Debuff" and colorDebuff or colorBuff, view = {mode = "icon", icon = auraIcon, text = SpellText(auraID)}, details = AuraDetails(aura.sourceUnit, auraID)})
												return
											end
										end
									end
								end
							end
						end
					end
					-- NPC (the name can be hidden in combat, the card is still shown)
					local npcName = Safe(UnitName("mouseover"))
					local npcGuid = Safe(UnitGUID("mouseover"))
					if not npcGuid then
						-- The mouseover unit is not always set yet, so use the creature in the tooltip itself
						local unitData = SafeTable(tooltip.GetTooltipData and tooltip:GetTooltipData())
						local dataGUID = unitData and Safe(unitData.type) == Enum.TooltipDataType.Unit and Safe(unitData.guid)
						if type(dataGUID) == "string" and (dataGUID:find("^Creature%-") or dataGUID:find("^Vehicle%-") or dataGUID:find("^Pet%-")) then
							npcGuid = dataGUID
							if not npcName then
								local title = Safe(GameTooltipTextLeft1:GetText())
								if type(title) == "string" then npcName = title:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") end
							end
						end
					end
					if type(npcGuid) == "string" then
						local void, void, void, void, void, npcID = strsplit("-", npcGuid)
						if npcID then
							local reaction = Safe(UnitReaction("mouseover", "player"))
							local reactionColor = reaction and FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]
							local npcColor = reactionColor and {reactionColor.r, reactionColor.g, reactionColor.b} or {1, 0.82, 0}
							local npcLevel = Safe(UnitLevel("mouseover"))
							local npcNote
							if type(npcLevel) == "number" then
								if npcLevel > 0 then npcNote = L["Level"] .. " " .. npcLevel else npcNote = L["Level"] .. " ??" end
							end
							local classification = Safe(UnitClassification("mouseover"))
							if npcNote and (classification == "elite" or classification == "worldboss") then npcNote = npcNote .. " " .. L["Elite"] elseif npcNote and classification == "rareelite" then npcNote = npcNote .. " " .. L["Rare Elite"] elseif npcNote and classification == "rare" then npcNote = npcNote .. " " .. L["Rare"] end
							ShowIDCard({kind = L["NPC"], name = npcName or L["Name not available right now"], id = npcID, url = "https://" .. LeaPlusLC.WowheadLock .. "/npc=" .. npcID, unit = "mouseover", color = npcColor, nameColor = npcColor, note = npcNote, view = {mode = "unit", unit = "mouseover", guid = npcGuid, npcID = npcID, text = NPCText(tooltip)}})
							return
						end
					end
					-- Pet, player and unknown tooltip (this must be last)
					if not GameTooltipTextLeft1:GetText() then return end
					-- Show armory link for players outside zhCN
					local unitFocus
					if WorldFrame:IsMouseMotionFocus() then unitFocus = "mouseover" else unitFocus = Safe(select(2, GameTooltip:GetUnit())) end
					if not unitFocus and UnitExists("mouseover") then unitFocus = "mouseover" end
					if unitFocus and Safe(UnitIsPlayer(unitFocus)) then
						ShowPlayerCard(unitFocus)
						return
					end
					-- Unknown tooltip
					-- A new player or creature can take a moment to load, so try again a few times before giving up
					if (UnitExists("mouseover") or WorldFrame:IsMouseMotionFocus() or GameTooltip:GetUnit()) and (LeaPlusLC.IDRetries or 0) < 4 then
						LeaPlusLC.IDRetries = (LeaPlusLC.IDRetries or 0) + 1
						local pressID = LeaPlusLC.IDPressID
						C_Timer.After(0.15, function() if LeaPlusLC.IDPressID == pressID then ShowInfoCard("retry") end end) -- Not if the key has been pressed again since
						return
					end
					LeaPlusLC.IDRetries = 0
					-- A player the game has not finished loading as a unit: always show a player card using the player in the tooltip itself
					-- (fill in what is known now, then refresh the card once the game has loaded the player)
					local unitData = SafeTable(GameTooltip.GetTooltipData and GameTooltip:GetTooltipData())
					local dataGUID = unitData and Safe(unitData.type) == Enum.TooltipDataType.Unit and Safe(unitData.guid)
					if type(dataGUID) == "string" and dataGUID:find("^Player%-") then
						local localizedClass, classFile, playerName, playerRealm
						if GetPlayerInfoByGUID then
							local void
							localizedClass, classFile, void, void, void, playerName, playerRealm = Safe(GetPlayerInfoByGUID(dataGUID))
						end
						if not classFile and Safe(UnitGUID("mouseover")) == dataGUID then
							classFile, localizedClass = Safe(UnitClassBase("mouseover")), Safe(UnitClass("mouseover"))
						end
						local classColor = classFile and RAID_CLASS_COLORS[classFile]
						local playerColor = classColor and {classColor.r, classColor.g, classColor.b} or {0.6, 0.6, 0.65}
						-- Name (the tooltip title already includes the surname on Forever)
						local titleName = (Safe(GameTooltipTextLeft1:GetText()) or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
						local displayName, realmText = titleName, Safe(GetRealmName()) or ""
						if playerName and playerName ~= "" then
							displayName = playerName
							if isForever and playerRealm and playerRealm ~= "" then displayName = playerName .. " " .. playerRealm
							elseif playerRealm and playerRealm ~= "" then realmText = playerRealm end
						end
						if displayName == "" then displayName = L["Name not available right now"] end
						local armoryLink
						if not isForever and GameLocale ~= "zhCN" and playerName and playerName ~= "" then
							local realmSlug = ((playerRealm and playerRealm ~= "") and playerRealm or Safe(GetNormalizedRealmName()) or ""):gsub("(%l)(%u)", "%1-%2"):gsub("'", ""):gsub(" ", "-")
							armoryLink = LeaPlusLC.BlizzardLock .. strlower(realmSlug) .. "/" .. strlower(playerName)
						end
						local coords = classFile and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classFile]
						local subText = localizedClass and (localizedClass .. "    " .. realmText) or realmText
						ShowIDCard({kind = L["Player"], name = displayName, sub = subText, url = armoryLink, icon = coords and "Interface\\TargetingFrame\\UI-Classes-Circles" or 134400, iconCoords = coords, color = playerColor, nameColor = playerColor, view = {mode = "unit", isPlayer = true, guid = dataGUID}, details = PlayerDetails(nil, dataGUID)})
						-- Refresh the card shortly (twice at most) while the mouse is still over the same player, to get the full card
						if (LeaPlusLC.IDUpgrades or 0) < 2 then
							LeaPlusLC.IDUpgrades = (LeaPlusLC.IDUpgrades or 0) + 1
							C_Timer.After(0.4, function()
								if LeaPlusLC.IDCard and LeaPlusLC.IDCard:IsShown() and Safe(UnitGUID("mouseover")) == dataGUID then
									LeaPlusLC.IDRetries = 0
									ShowInfoCard("upgrade")
								end
							end)
						end
						return
					end
					-- Anything else is not known, so show nothing
				end
				ShowCardForMouse()
				-- Aura picker: list the buffs and debuffs of the hovered unit frame (addons cannot tell which aura icon is under the mouse)
				local function ShowAuraPicker()
					-- Collect auras (auras the game hides are left out)
					local auras = {}
					for void, auraType in ipairs({"Buff", "Debuff"}) do
						for i = 1, 40 do
							local aura, done = GetAura(pickerUnit, i, auraType == "Debuff")
							if done then break end
							local auraName, auraID, auraIcon = aura and Safe(aura.name), aura and Safe(aura.spellId), aura and Safe(aura.icon)
							if auraName and auraID and auraIcon then
								tinsert(auras, {auraType = auraType, name = auraName, spellID = auraID, icon = auraIcon, source = Safe(aura.sourceUnit)})
							end
						end
					end
					if #auras == 0 then return end
					-- Show the card for an aura and mark it in the list
					local picker
					local function ShowAuraLink(info)
						ShowIDCard({kind = L[info.auraType], name = info.name, id = info.spellID, url = "https://" .. LeaPlusLC.WowheadLock .. "/spell=" .. info.spellID, icon = info.icon, color = info.auraType == "Debuff" and colorDebuff or colorBuff, view = {mode = "icon", icon = info.icon, text = SpellText(info.spellID)}, details = AuraDetails(info.source, info.spellID)})
						if LeaPlusLC.AuraPicker then
							for void, row in ipairs(LeaPlusLC.AuraPicker.rows) do row.selected:SetShown(row.info == info) end
						end
					end
					-- If nothing else is showing (such as a buff icon), start with the first aura
					local startWithFirst = not LeaPlusLC.IDCard or not LeaPlusLC.IDCard:IsShown()
					if startWithFirst then ShowAuraLink(auras[1]) end
					local card = LeaPlusLC.IDCard
					-- Create the picker (a child of the card so it closes with it)
					local cols, rowHeight = 2, 26
					local colWidth = (480 - 24) / cols
					picker = LeaPlusLC.AuraPicker
					if not picker then
						picker = CreateFrame("Frame", nil, card, "BackdropTemplate")
						LeaPlusLC.AuraPicker = picker
						picker:SetPoint("BOTTOMLEFT", card, "TOPLEFT", 0, 6) -- Above the card so it does not cover the action bars
						picker:SetPoint("BOTTOMRIGHT", card, "TOPRIGHT", 0, 6)
						picker:EnableMouse(true)
						picker:SetScript("OnMouseDown", function(self, btn) if btn == "RightButton" then card:Hide() end end)
						picker:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = OnePixel()})
						picker:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
						picker:SetBackdropBorderColor(1, 1, 1, 0.12)
						picker.title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
						picker.title:SetPoint("TOPLEFT", picker, "TOPLEFT", 14, -10)
						picker.hint = picker:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
						picker.hint:SetPoint("TOPRIGHT", picker, "TOPRIGHT", -14, -12)
						picker.hint:SetText(L["Click a buff or debuff to show its link."])
						picker.rows = {}
					end
					-- Name (on Forever, players' second name is their surname)
					local pickerName, pickerSurname = Safe(UnitName(pickerUnit))
					if isForever and pickerName and pickerSurname and pickerSurname ~= "" and Safe(UnitIsPlayer(pickerUnit)) then pickerName = pickerName .. " " .. pickerSurname end
					picker.title:SetText(pickerName or "")
					-- Fill the rows
					for i, info in ipairs(auras) do
						local row = picker.rows[i]
						if not row then
							row = CreateFrame("Button", nil, picker)
							row:SetSize(colWidth - 4, rowHeight - 2)
							row.bg = row:CreateTexture(nil, "BACKGROUND")
							row.bg:SetAllPoints()
							row.bg:SetColorTexture(1, 1, 1, 0.03)
							row.selected = row:CreateTexture(nil, "BORDER")
							row.selected:SetAllPoints()
							row.selected:SetColorTexture(1, 1, 1, 0.1)
							row.icon = row:CreateTexture(nil, "ARTWORK")
							row.icon:SetSize(rowHeight - 6, rowHeight - 6)
							row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
							row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
							row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
							row.text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
							row.text:SetJustifyH("LEFT")
							row.text:SetWordWrap(false)
							row:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
							row:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.08)
							row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
							row:SetScript("OnClick", function(self, btn)
								if btn == "RightButton" then card:Hide() else ShowAuraLink(self.info) end
							end)
							picker.rows[i] = row
						end
						row.info = info
						row.icon:SetTexture(info.icon)
						if info.auraType == "Debuff" then row.text:SetTextColor(1, 0.45, 0.45) else row.text:SetTextColor(0.45, 1, 0.55) end
						row.text:SetText(info.name .. "  |cff8a8a90" .. info.spellID .. "|r")
						row.selected:SetShown(startWithFirst and i == 1)
						row:ClearAllPoints()
						row:SetPoint("TOPLEFT", picker, "TOPLEFT", 12 + ((i - 1) % cols) * colWidth, -34 - math.floor((i - 1) / cols) * rowHeight)
						row:Show()
					end
					for i = #auras + 1, #picker.rows do picker.rows[i]:Hide() end
					picker:SetHeight(34 + math.ceil(#auras / cols) * rowHeight + 10)
					picker:Show()
				end
				if pickerUnit then ShowAuraPicker() end
			end

			-- Hidden button that the key clicks (the key is bound to it in the addon code, no Bindings.xml entry needed)
			local InfoButton = CreateFrame("Button", "LeaPlusGlobalInfoButton", UIParent)
			InfoButton:Hide()
			InfoButton:RegisterForClicks("AnyDown")
			InfoButton:SetScript("OnClick", function()
				ShowInfoCard()
			end)

			-- Show the card for a player unit (used by the dressing room)
			LeaPlusLC.ShowInfoCardForUnit = function(unit) ShowInfoCard(nil, unit) end

			-- Create configuration panel
			local InfoCardPanel = LeaPlusLC:CreatePanel("Show info cards", "InfoCardPanel")

			-- Key section
			LeaPlusLC:MakeTx(InfoCardPanel, "Key", 16, -72)
			local keyText = LeaPlusLC:MakeWD(InfoCardPanel, "", 16, -92)
			keyText:SetWidth(530)

			local setBtn = LeaPlusLC:CreateButton("InfoCardSetKeyBtn", InfoCardPanel, "Set key", "TOPLEFT", 16, -116, 0, 25, true, "Click, then press the key you want to use.|n|nYou can include Shift, Ctrl or Alt.|n|nPress Escape to cancel.|n|nThis does not change your saved key bindings.  If the key already does something, it will go back to doing that when you clear the key or turn this option off.")
			local clearBtn = LeaPlusLC:CreateButton("InfoCardClearKeyBtn", InfoCardPanel, "Clear key", "TOPLEFT", 16, -116, 0, 25, true, "Click to remove the key.  Anything the key did before will work again.")
			clearBtn:ClearAllPoints()

			-- Make the set key button wide enough for both of its labels
			setBtn.f:SetText(L["Press a key"])
			local wideLabel = setBtn.f:GetStringWidth()
			setBtn.f:SetText(L["Set key"])
			setBtn:SetWidth(math.max(wideLabel, setBtn.f:GetStringWidth()) + 20)
			clearBtn:SetPoint("LEFT", setBtn, "RIGHT", 10, 0)

			-- How to use section
			LeaPlusLC:MakeTx(InfoCardPanel, "How to use", 16, -162)
			local howText = LeaPlusLC:MakeWD(InfoCardPanel, "Point at a player, NPC, item, spell, buff or quest and press the key.  A card will show its details and a link to it on Wowhead.|n|nWhile the card is showing, hold Ctrl and press C to copy the link, then paste it into your web browser.", 16, -182)
			howText:SetWidth(530)
			howText:SetWordWrap(true)
			howText:SetSpacing(2)

			-- Show the current key
			local function KeyName(key)
				return GetBindingText and GetBindingText(key) or key
			end

			local listening = false
			local applyPending = false

			-- Apply the keybind
			local function ApplyKey()
				if InCombatLockdown() then
					applyPending = true
					return
				end
				applyPending = false
				ClearOverrideBindings(InfoCardPanel)
				if LeaPlusLC["ShowInfoCards"] == "On" and LeaPlusLC["InfoCardKey"] ~= "" then
					SetOverrideBindingClick(InfoCardPanel, false, LeaPlusLC["InfoCardKey"], "LeaPlusGlobalInfoButton")
				end
			end

			local function Refresh()
				if listening then
					keyText:SetText(L["Press the key you want to use (Escape to cancel)."])
					setBtn:SetText(L["Press a key"])
					return
				end
				setBtn:SetText(L["Set key"])
				local text
				if LeaPlusLC["InfoCardKey"] ~= "" then
					text = L["Current key"] .. ": |cff00ff00" .. KeyName(LeaPlusLC["InfoCardKey"]) .. "|r"
					clearBtn:Enable()
				else
					text = L["Current key"] .. ": |cffff8080" .. L["None"] .. "|r"
					clearBtn:Disable()
				end
				keyText:SetText(text)
			end

			local function StopListening()
				listening = false
				setBtn:EnableKeyboard(false)
				Refresh()
			end

			-- Capture the next key pressed
			local modifierKeys = {LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true, LALT = true, RALT = true, LMETA = true, RMETA = true}

			setBtn:SetScript("OnKeyDown", function(self, key)
				if not listening then return end
				if modifierKeys[key] then return end
				if key == "ESCAPE" then
					StopListening()
					return
				end
				if InCombatLockdown() then
					StopListening()
					LeaPlusLC:Print("You cannot do that in combat.")
					return
				end
				local combo = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. (IsMetaKeyDown and IsMetaKeyDown() and "META-" or "") .. key
				local oldAction = GetBindingAction(combo)
				LeaPlusLC["InfoCardKey"] = combo
				ApplyKey()
				if oldAction and oldAction ~= "" then
					local oldName = _G["BINDING_NAME_" .. oldAction] or oldAction
					LeaPlusLC:Print(L["Key set to"] .. " " .. KeyName(combo) .. ".  " .. L["It normally does"] .. " " .. oldName .. ", " .. L["and will again when you clear the key."])
				else
					LeaPlusLC:Print(L["Key set to"] .. " " .. KeyName(combo) .. ".")
				end
				StopListening()
			end)

			-- Setting a key script turns keyboard input on by itself, so turn it off until the button is clicked
			setBtn:EnableKeyboard(false)

			setBtn:SetScript("OnClick", function()
				if InCombatLockdown() then
					LeaPlusLC:Print("You cannot do that in combat.")
					return
				end
				if listening then
					StopListening()
				else
					listening = true
					setBtn:EnableKeyboard(true)
					setBtn:SetPropagateKeyboardInput(false)
					Refresh()
				end
			end)

			clearBtn:SetScript("OnClick", function()
				if InCombatLockdown() then
					LeaPlusLC:Print("You cannot do that in combat.")
					return
				end
				LeaPlusLC["InfoCardKey"] = ""
				ApplyKey()
				Refresh()
			end)

			-- Turning the option on or off sets or removes the key
			LeaPlusCB["ShowInfoCards"]:HookScript("OnClick", ApplyKey)

			InfoCardPanel:HookScript("OnShow", Refresh)
			InfoCardPanel:HookScript("OnHide", function() if listening then StopListening() end end)
			InfoCardPanel:RegisterEvent("UPDATE_BINDINGS")
			InfoCardPanel:RegisterEvent("PLAYER_REGEN_DISABLED")
			InfoCardPanel:RegisterEvent("PLAYER_REGEN_ENABLED")
			InfoCardPanel:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_REGEN_DISABLED" then
					-- Entering combat, stop listening so key presses reach the game
					if listening then StopListening() end
				elseif event == "PLAYER_REGEN_ENABLED" then
					-- Set the key if it could not be set during combat
					if applyPending then ApplyKey() end
				elseif InfoCardPanel:IsShown() then
					Refresh()
				end
			end)

			-- Set the key now
			ApplyKey()

			-- Help and reset buttons hidden
			InfoCardPanel.h:Hide()
			InfoCardPanel.r:Hide()

			-- Back button handler
			InfoCardPanel.b:SetScript("OnClick", function()
				InfoCardPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Show configuration panel when options panel button is clicked
			LeaPlusCB["ShowInfoCardsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile (nothing to set)
				else
					InfoCardPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show range coloring
		----------------------------------------------------------------------

		if LeaPlusLC["ShowRangeColoring"] == "On" then

			-- Colors (red, green, blue, desaturate)
			local stateColors = {
				normal		= {1.0, 1.0, 1.0, false},	-- Usable
				range		= {1.0, 0.3, 0.1, true},	-- Out of range
				mana		= {0.1, 0.3, 1.0, true},	-- Not enough mana
				unusable	= {0.4, 0.4, 0.4, false},	-- Not usable
			}

			-- Upvalues
			local IsActionInRange, IsUsableAction, GetActionInfo, GetMacroInfo, GetMacroSpell = IsActionInRange, IsUsableAction, GetActionInfo, GetMacroInfo, GetMacroSpell
			local IsSpellUsable = C_Spell and C_Spell.IsSpellUsable or IsUsableSpell
			local hooksecurefunc, pairs, strsub, issecretvalue = hooksecurefunc, pairs, strsub, issecretvalue

			-- Function to check for secret values (secret values can never be compared or tested)
			local function IsSecret(a, b, c)
				if not issecretvalue then return false end
				return issecretvalue(a) or issecretvalue(b) or issecretvalue(c)
			end

			-- Button data is stored locally (nothing is written onto the game's action buttons)
			local iconStates = {}		-- Icon texture -> last applied state
			local hotkeyStates = {}		-- Hotkey text -> last applied state
			local actionButtons = {}	-- Button -> true if it is one of the game's action buttons (false if not)
			local petButtons = {}		-- Pet buttons

			-- Function to check if a button is one of the game's action buttons (read from the game's own list, then remembered)
			local function IsActionButton(button)
				local known = actionButtons[button]
				if known ~= nil then return known end
				local found = false
				ActionBarButtonEventsFrame:ForEachFrame(function(frame) if frame == button then found = true end end)
				actionButtons[button] = found
				return found
			end

			----------------------------------------------------------------------
			-- Coloring
			----------------------------------------------------------------------

			-- Function to color an icon
			local function SetIconState(icon, state)
				iconStates[icon] = state
				local c = stateColors[state]
				icon:SetVertexColor(c[1], c[2], c[3])
				icon:SetDesaturated(c[4])
			end

			-- Function to color a hotkey
			local function SetHotkeyState(hotkey, state)
				hotkeyStates[hotkey] = state
				local c = stateColors[state]
				hotkey:SetVertexColor(c[1], c[2], c[3])
			end

			-- Function to get the state of an action slot (second return is true if out of range)
			-- (returns nil if anything needed is a secret value so the button is left alone)
			local function GetActionState(slot)
				if not slot or IsSecret(slot) then return end
				local isUsable, notEnoughMana
				-- Macros with names starting with # use the macro spell for the mana check
				local actionType, id = GetActionInfo(slot)
				if not IsSecret(actionType, id) and actionType == "macro" then
					local name = GetMacroInfo(id)
					if name and not IsSecret(name) and strsub(name, 1, 1) == "#" then
						local spellID = GetMacroSpell(id)
						if spellID and not IsSecret(spellID) then
							isUsable, notEnoughMana = IsSpellUsable(spellID)
						end
					end
				end
				if isUsable == nil then
					isUsable, notEnoughMana = IsUsableAction(slot)
				end
				local inRange = IsActionInRange(slot)
				if IsSecret(isUsable, notEnoughMana, inRange) then return end
				local outOfRange = inRange == false
				if isUsable then
					return outOfRange and "range" or "normal", outOfRange
				elseif notEnoughMana then
					return "mana", outOfRange
				end
				return "unusable", outOfRange
			end

			-- Function to get the state of a pet action
			local function GetPetActionState(index)
				local void, void, void, void, void, void, spellID, checksRange, inRange = GetPetActionInfo(index)
				if IsSecret(spellID, checksRange, inRange) then return end
				local outOfRange = checksRange and not inRange
				local isUsable, notEnoughMana
				if spellID then
					isUsable, notEnoughMana = IsSpellUsable(spellID)
				else
					isUsable, notEnoughMana = GetPetActionSlotUsable(index), false
				end
				if IsSecret(isUsable, notEnoughMana) then return end
				if isUsable then
					return outOfRange and "range" or "normal"
				elseif notEnoughMana then
					return "mana"
				end
				return "unusable"
			end

			-- Function to color an action button (runs after the game colors it)
			local function UpdateActionButton(button)
				local state, outOfRange = GetActionState(button.action)
				if not state then return end
				SetIconState(button.icon, state)
				SetHotkeyState(button.HotKey, outOfRange and "range" or "normal")
			end

			-- Function to update range coloring when the game says the range has changed
			-- (only switches between usable and out of range, other states are left alone)
			local function UpdateRange(button, checksRange, inRange)
				if not (petButtons[button] or IsActionButton(button)) or IsSecret(checksRange, inRange) then return end
				local outOfRange = checksRange and not inRange
				local icon, hotkey = button.icon, button.HotKey
				local state = iconStates[icon]
				if state == "normal" and outOfRange then
					SetIconState(icon, "range")
				elseif state == "range" and not outOfRange then
					SetIconState(icon, "normal")
				end
				state = hotkeyStates[hotkey]
				if state == "normal" and outOfRange then
					SetHotkeyState(hotkey, "range")
				elseif state == "range" and not outOfRange then
					SetHotkeyState(hotkey, "normal")
				end
			end

			-- Function to color the pet bar
			local function UpdatePetBar(bar)
				if not PetHasActionBar() then return end
				for index, button in pairs(bar.actionButtons) do
					local icon = button.icon
					if icon:IsVisible() then
						local state = GetPetActionState(index)
						if state then
							SetIconState(icon, state)
						end
					end
				end
			end

			----------------------------------------------------------------------
			-- Setup
			----------------------------------------------------------------------

			-- Nothing is hooked onto the action buttons themselves (they are secure), only the game's shared functions and events are used,
			-- and the game's own attack flash is left alone

			-- Function to check if the game has colored an icon since it was last colored here (it colors a button when the button changes)
			local abs = math.abs
			local function IconWasReset(icon)
				local state = iconStates[icon]
				if not state then return true end
				local c = stateColors[state]
				local r, g, b = icon:GetVertexColor()
				if IsSecret(r, g, b) then return false end
				return abs(r - c[1]) > 0.01 or abs(g - c[2]) > 0.01 or abs(b - c[3]) > 0.01
			end

			-- Action buttons: the game updates a button's cooldown straight after it colors the button when the button changes, so the
			-- button is colored again after that (cooldowns also change on their own every global cooldown, so the button is only colored
			-- again if the game has actually changed its color, which is a single quick check)
			hooksecurefunc("ActionButton_UpdateCooldown", function(button)
				local icon = button.icon
				if icon and IconWasReset(icon) and IsActionButton(button) then UpdateActionButton(button) end
			end)

			-- Range changes are event driven (the game calls this from ACTION_RANGE_CHECK_UPDATE)
			hooksecurefunc("ActionButton_UpdateRangeIndicator", UpdateRange)

			-- Usable changes (such as running out of mana): the game colors the buttons for these slots, so they are colored again a moment later
			local usableFrame = CreateFrame("FRAME")
			local dirtySlots, usableQueued = {}, false
			local function UpdateDirtySlots()
				usableQueued = false
				ActionBarButtonEventsFrame:ForEachFrame(function(button)
					local slot = button.action
					if slot and not IsSecret(slot) and dirtySlots[slot] then UpdateActionButton(button) end
				end)
				wipe(dirtySlots)
			end
			usableFrame:RegisterEvent("ACTION_USABLE_CHANGED")
			usableFrame:SetScript("OnEvent", function(self, event, changes)
				if type(changes) ~= "table" or IsSecret(changes) then return end
				for void, change in ipairs(changes) do
					local slot = change.slot
					if slot and not IsSecret(slot) then dirtySlots[slot] = true end
				end
				if not usableQueued then
					usableQueued = true
					C_Timer.After(0, UpdateDirtySlots)
				end
			end)

			-- Pet bar: colored again a moment after the game updates it (when the pet bar changes or pet power changes)
			if PetActionBar and PetActionBar.actionButtons then
				for void, button in pairs(PetActionBar.actionButtons) do
					petButtons[button] = true
				end
				local petFrame = CreateFrame("FRAME")
				local petQueued = false
				local function UpdatePetLater()
					if petQueued then return end
					petQueued = true
					C_Timer.After(0, function()
						petQueued = false
						UpdatePetBar(PetActionBar)
					end)
				end
				petFrame:RegisterEvent("PET_BAR_UPDATE")
				petFrame:RegisterEvent("PET_BAR_UPDATE_USABLE")
				petFrame:RegisterEvent("PET_UI_UPDATE")
				petFrame:RegisterUnitEvent("UNIT_PET", "player")
				petFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "pet")
				petFrame:SetScript("OnEvent", UpdatePetLater)
			end

			-- Color everything once at startup
			C_Timer.After(1 / 30, function()
				ActionBarButtonEventsFrame:ForEachFrame(UpdateActionButton)
				if PetActionBar and PetActionBar.actionButtons then
					UpdatePetBar(PetActionBar)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Hide starter tutorials
		----------------------------------------------------------------------

		if LeaPlusLC["HideStarterTutorials"] == "On" then

			if C_PlayerInfo.IsPlayerNPERestricted() then

				local patterns = {"^Tutorial.-_Frame$", "^TutorialPointer", "^NPE_"}
				local hooked = {}
				local active = true

				-- Function to hide a tutorial frame while still in the new player experience
				local function HideIfActive(frame)
					if active then frame:Hide() end
				end

				-- Function to hook a frame so it hides whenever it shows
				local function SuppressFrame(obj)
					if hooked[obj] then return end
					hooked[obj] = true
					obj:HookScript("OnShow", HideIfActive)
					HideIfActive(obj)
				end

				-- Function to hide tutorial frames
				local function SuppressTutorialFrames()
					if not active then return end
					for name, obj in pairs(_G) do
						if type(name) == "string" and type(obj) == "table" then
							for void, pattern in ipairs(patterns) do
								if name:find(pattern) then
									-- Skip forbidden frames, then only hook actual frames
									if obj.IsForbidden and not obj:IsForbidden() and obj.IsObjectType and obj:IsObjectType("Frame") then
										SuppressFrame(obj)
										-- print("Tutorial frame blocked:", name) -- Debug
									end
									break
								end
							end
						end
					end
				end

				-- Function to hide pointer frames
				local function SuppressPointerFrames()
					if not active then return end
					local i = 1
					while _G["TutorialPointerFrame_" .. i] do
						local obj = _G["TutorialPointerFrame_" .. i]
						if obj.IsForbidden and not obj:IsForbidden() then
							SuppressFrame(obj)
						end
						i = i + 1
					end
				end

				-- Function to hook the pointer manager
				local function HookPointerManager()
					if TutorialPointerFrame and type(TutorialPointerFrame.Show) == "function" and not hooked.pointerManager then
						hooked.pointerManager = true
						hooksecurefunc(TutorialPointerFrame, "Show", SuppressPointerFrames)
					end
					SuppressPointerFrames()
				end

				-- Run when Blizzard addons are loaded
				EventUtil.ContinueOnAddOnLoaded("Blizzard_TutorialManager", function()
					SuppressTutorialFrames()
					HookPointerManager()
				end)
				EventUtil.ContinueOnAddOnLoaded("Blizzard_NewPlayerExperience", SuppressTutorialFrames)

				-- Stop hiding tutorials once the player leaves the new player experience
				local npeWatcher = CreateFrame("Frame")
				npeWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
				npeWatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
				npeWatcher:SetScript("OnEvent", function(self)
					if not C_PlayerInfo.IsPlayerNPERestricted() then
						active = false
						self:UnregisterAllEvents()
					end
				end)

			end

		end

		----------------------------------------------------------------------
		-- Simple addon list
		----------------------------------------------------------------------

		if LeaPlusLC["SimpleAddonListing"] == "On" then

			-- Strip Wow color codes
			local function StripColors(s) return (s or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") end

			-- Build, filter, sort and feed the list in one pass
			local function UpdateList()
				local provider   = CreateTreeDataProvider()
				local filter     = AddonList.SearchBox:GetText():lower()
				local groups     = {}

				for i = 1, C_AddOns.GetNumAddOns() do
					local name, title = C_AddOns.GetAddOnInfo(i)
					local group = C_AddOns.GetAddOnMetadata(i, "Group") or name
					local searchable = (StripColors(title or name) .. StripColors(group)):lower()

					if filter == "" or searchable:find(filter, 1, true) then
						groups[group] = groups[group] or {parent = {addonIndex = i}, children = {}}
						if name == group then
							groups[group].parent = {addonIndex = i}
						else
							table.insert(groups[group].children, {addonIndex = i})
						end
					end
				end

				-- Sort groups alphabetically (ignoring color codes)
				local sortedGroups = {}
				for g in pairs(groups) do table.insert(sortedGroups, g) end
				table.sort(sortedGroups, function(a, b) return StripColors(a):lower() < StripColors(b):lower() end)

				-- Insert sorted groups and their sorted children into the provider
				for void, gName in ipairs(sortedGroups) do
					local node = provider:Insert(groups[gName].parent)

					local ch = groups[gName].children
					table.sort(ch, function(a, b)
						local aT = StripColors(select(2, C_AddOns.GetAddOnInfo(a.addonIndex)) or ""):lower()
						local bT = StripColors(select(2, C_AddOns.GetAddOnInfo(b.addonIndex)) or ""):lower()
						return aT < bT
					end)

					for void, child in ipairs(ch) do node:Insert(child) end
				end

				AddonList.ScrollBox:SetDataProvider(provider, ScrollBoxConstants.RetainScrollPosition)
				AddonList.ScrollBox:Show()
			end

			AddonList.SearchBox:HookScript("OnTextChanged", UpdateList)
			hooksecurefunc("AddonList_Update", UpdateList)
			AddonList:HookScript("OnShow", function()
				AddonList.ScrollBox:Hide()
				C_Timer.After(0, UpdateList)
			end)

		end

		----------------------------------------------------------------------
		-- Set edit mode layout
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local LayoutPanel = LeaPlusLC:CreatePanel("Set edit mode layout", "LayoutPanel")

			local titleTX = LeaPlusLC:MakeTx(LayoutPanel, "Layout name", 16, -72)
			local LayoutBox = LeaPlusLC:CreateEditBox("LayoutBox", LayoutPanel, 500, 40, "TOPLEFT", 20, -92, "LayoutBox", "LayoutBox")

			LeaPlusLC:CreateHelpButton("EditModeLayoutNameHelpButton", LayoutPanel, titleTX, "If the edit mode layout name that you enter here exists, that layout will be applied when you login to any character on your account.")

			-- Apply the layout on login if it is not already active
			if LeaPlusLC["SetEditModeLayout"] == "On" then

				local function TryApplyLayout()
					local wanted = strtrim(tostring(LeaPlusLC["EditModeLayoutName"] or "")):lower()
					if wanted == "" then return true end
					if not EditModeManagerFrame or not EditModeManagerFrame.layoutInfo then return false end
					local layouts = EditModeManagerFrame:GetLayouts()
					if type(layouts) ~= "table" or #layouts == 0 then return false end
					local active = EditModeManagerFrame:GetActiveLayoutInfo()
					for index, layout in ipairs(layouts) do
						if layout.layoutName and layout.layoutName:lower() == wanted then
							if not (active and active.layoutName and active.layoutName:lower() == wanted) then
								C_EditMode.SetActiveLayout(index)
								LeaPlusLC:Print(L["Edit Mode layout"] .. " '" .. layout.layoutName .. "' " .. L["applied"])
							end
							return true
						end
					end
					return true
				end

				-- Layouts already loaded (e.g. after /reload)
				if not TryApplyLayout() then
					-- Cold login: wait until the layouts arrive, then apply once
					local f = CreateFrame("Frame")
					local done = false
					f:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
					f:SetScript("OnEvent", function(self)
						C_Timer.After(0, function()
							if done then return end
							if TryApplyLayout() then
								done = true
								self:UnregisterAllEvents()
							end
						end)
					end)
				end

			end

			-- Function to save the keyword
			local function SetEditModeName()
				local LayoutText = LayoutBox:GetText()
				if LayoutText and LayoutText ~= "" then
					LeaPlusLC["EditModeLayoutName"] = strtrim(LayoutBox:GetText())
				else
					LeaPlusLC["EditModeLayoutName"] = ""
				end
			end

			-- Save the keyword when it changes
			LayoutBox:SetScript("OnTextChanged", SetEditModeName)

			-- Refresh editbox with trimmed keyword when edit focus is lost (removes additional spaces)
			LayoutBox:SetScript("OnEditFocusLost", function()
				LayoutBox:SetText(LeaPlusLC["EditModeLayoutName"])
			end)

			-- Help button hidden
			LayoutPanel.h:Hide()

			-- Back button handler
			LayoutPanel.b:SetScript("OnClick", function()
				-- Save the keyword
				SetEditModeName()
				-- Show the options panel
				LayoutPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page8"]:Show()
				return
			end)

			-- Add reset button
			LayoutPanel.r:SetScript("OnClick", function()
				-- Reset the keyword to default
				LeaPlusLC["EditModeLayoutName"] = ""
				-- Set the editbox to default
				LayoutBox:SetText("")
				-- Save the keyword
				SetEditModeName()
				-- Refresh panel
				LayoutPanel:Hide(); LayoutPanel:Show()
			end)

			-- Ensure keyword is a string on startup
			LeaPlusLC["EditModeLayoutName"] = tostring(LeaPlusLC["EditModeLayoutName"] or "")

			-- Set editbox value when shown
			LayoutBox:HookScript("OnShow", function()
				LayoutBox:SetText(LeaPlusLC["EditModeLayoutName"])
			end)

			-- Configuration button handler
			LeaPlusCB["SetEditModeLayoutBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["EditModeLayoutName"] = "Main"
					LayoutBox:SetText(LeaPlusLC["EditModeLayoutName"])
					SetEditModeName()
				else
					-- Show panel
					LayoutPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Block requested invites (no reload required)
		----------------------------------------------------------------------

		do

			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function()
				if LeaPlusLC["NoRequestedInvites"] == "On" then
					local groupInvitePopUp = StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")
					if groupInvitePopUp and groupInvitePopUp.data then
						local void, name, guid = GetInviteConfirmationInfo(groupInvitePopUp.data)
						if LeaPlusLC:FriendCheck(name, guid) then
							return
						else
							-- If not a friend, decline
							RespondToInviteConfirmation(groupInvitePopUp.data, false)
							StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
						end
					end
				end
			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["NoRequestedInvites"] == "On" then
					frame:RegisterEvent("GROUP_INVITE_CONFIRMATION")
				else
					frame:UnregisterEvent("GROUP_INVITE_CONFIRMATION")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["NoRequestedInvites"] == "On" then SetEvent() end
			LeaPlusCB["NoRequestedInvites"]:HookScript("OnClick", SetEvent)

		end

		----------------------------------------------------------------------
		-- Block friend requests (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to decline friend requests
			local function DeclineReqs()
				if LeaPlusLC["NoFriendRequests"] == "On" then
					for i = BNGetNumFriendInvites(), 1, -1 do
						local inviteInfo = C_BattleNet.GetFriendInviteInfo(i)
						if inviteInfo.inviteID and inviteInfo.accountName then
							BNDeclineFriendInvite(inviteInfo.inviteID)
							C_Timer.After(0.1, function()
								LeaPlusLC:Print(L["A friend request from"] .. " " .. inviteInfo.accountName .. " " .. L["was automatically declined."])
							end)
						end
					end
				end
			end

			-- Event frame for incoming friend requests
			local DecEvt = CreateFrame("FRAME")
			DecEvt:SetScript("OnEvent", DeclineReqs)

			-- Function to register or unregister the event
			local function ControlEvent()
				if LeaPlusLC["NoFriendRequests"] == "On" then
					DecEvt:RegisterEvent("BN_FRIEND_INVITE_ADDED")
					DeclineReqs()
				else
					DecEvt:UnregisterEvent("BN_FRIEND_INVITE_ADDED")
				end
			end

			-- Set event status when option is clicked and on startup
			LeaPlusCB["NoFriendRequests"]:HookScript("OnClick", ControlEvent)
			ControlEvent()

		end

		----------------------------------------------------------------------
		--	Block duels (no reload required)
		----------------------------------------------------------------------

		do

			-- Handler for event
			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1)
				if not LeaPlusLC:FriendCheck(arg1) then
					CancelDuel()
					StaticPopup_Hide("DUEL_REQUESTED")
					return
				end
			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["NoDuelRequests"] == "On" then
					frame:RegisterEvent("DUEL_REQUESTED")
				else
					frame:UnregisterEvent("DUEL_REQUESTED")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["NoDuelRequests"] == "On" then SetEvent() end
			LeaPlusCB["NoDuelRequests"]:HookScript("OnClick", SetEvent)

		end

		----------------------------------------------------------------------
		--	Block pet battle duels (no reload required)
		----------------------------------------------------------------------

		do

			-- Handler for event
			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1)
				if not LeaPlusLC:FriendCheck(arg1) then
					C_PetBattles.CancelPVPDuel()
					return
				end
			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["NoPetDuels"] == "On" then
					frame:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
				else
					frame:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["NoPetDuels"] == "On" then SetEvent() end
			LeaPlusCB["NoPetDuels"]:HookScript("OnClick", SetEvent)

		end

		----------------------------------------------------------------------
		--	Queue from friends (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set option
			local function RoleFunc()
				if LeaPlusLC["AutoConfirmRole"] == "On" then
					LFDRoleCheckPopupAcceptButton:SetScript("OnShow", function()
						local leader, leaderGUID  = "", ""
						for i = 1, GetNumSubgroupMembers() do
							if UnitIsGroupLeader("party" .. i) then
								leader = UnitName("party" .. i)
								if not canaccessvalue(leader) then return end
								leaderGUID = UnitGUID("party" .. i)
								if not canaccessvalue(leaderGUID) then return end
								break
							end
						end
						if LeaPlusLC:FriendCheck(leader, leaderGUID) then
							LFDRoleCheckPopupAcceptButton:Click()
						end
					end)
				else
					LFDRoleCheckPopupAcceptButton:SetScript("OnShow", nil)
				end
			end

			-- Set option on startup if enabled and when option is clicked
			if LeaPlusLC["AutoConfirmRole"] == "On" then RoleFunc() end
			LeaPlusCB["AutoConfirmRole"]:HookScript("OnClick", RoleFunc)

		end

		----------------------------------------------------------------------
		--	Invite from whispers (no reload required)
		----------------------------------------------------------------------

		do

			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
				if not canaccessvalue(arg1) or not canaccessvalue(arg2) then return end
				if (not UnitExists("party1") or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and strlower(strtrim(arg1)) == strlower(LeaPlusLC["InvKey"]) then
					if not LeaPlusLC:IsInLFGQueue() then
						if event == "CHAT_MSG_WHISPER" then
							local void, void, void, void, void, void, void, void, void, guid = ...
							if LeaPlusLC:FriendCheck(arg2, guid) or LeaPlusLC["InviteFriendsOnly"] == "Off" then
								-- If whisper name is same realm, remove realm name
								local theWhisperName, theWhisperRealm = strsplit("-", arg2, 2)
								if theWhisperRealm then
									local void, theCharRealm = UnitFullName("player")
									if theCharRealm then
										if theWhisperRealm == theCharRealm then arg2 = theWhisperName end
									end
								end

								-- Invite whisper player
								C_PartyInfo.InviteUnit(arg2)
							end
						elseif event == "CHAT_MSG_BN_WHISPER" then
							local presenceID = select(11, ...)
							if presenceID and BNIsFriend(presenceID) then
								local index = BNGetFriendIndex(presenceID)
								if index then
									local accountInfo = C_BattleNet.GetFriendAccountInfo(index)
									local gameAccountInfo = accountInfo.gameAccountInfo
									local gameAccountID = gameAccountInfo.gameAccountID
									if gameAccountID then
										C_BattleNet.InviteFriend(gameAccountID)
									end
								end
							end
						end
					end
				end
				return
			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["InviteFromWhisper"] == "On" then
					frame:RegisterEvent("CHAT_MSG_WHISPER")
					frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
				else
					frame:UnregisterEvent("CHAT_MSG_WHISPER")
					frame:UnregisterEvent("CHAT_MSG_BN_WHISPER")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["InviteFromWhisper"] == "On" then SetEvent() end
			LeaPlusCB["InviteFromWhisper"]:HookScript("OnClick", SetEvent)

			-- Create configuration panel
			local InvPanel = LeaPlusLC:CreatePanel("Invite from whispers", "InvPanel")

			-- Add editbox
			LeaPlusLC:MakeTx(InvPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(InvPanel, "InviteFriendsOnly", "Restrict to friends", 16, -92, false, "If checked, group invites will only be sent to friends.|n|nIf unchecked, group invites will be sent to everyone.")

			LeaPlusLC:MakeTx(InvPanel, "Keyword", 356, -72)
			local KeyBox = LeaPlusLC:CreateEditBox("KeyBox", InvPanel, 140, 10, "TOPLEFT", 356, -92, "KeyBox", "KeyBox")

			-- Function to show the keyword in the option tooltip
			local function SetKeywordTip()
				LeaPlusCB["InviteFromWhisper"].tiptext = gsub(LeaPlusCB["InviteFromWhisper"].tiptext, "(|cffffffff)[^|]*(|r)",  "%1" .. LeaPlusLC["InvKey"] .. "%2")
			end

			-- Function to save the keyword
			local function SetInvKey()
				local keytext = KeyBox:GetText()
				if keytext and keytext ~= "" then
					LeaPlusLC["InvKey"] = strtrim(KeyBox:GetText())
				else
					LeaPlusLC["InvKey"] = "inv"
				end
				-- Show the keyword in the option tooltip
				SetKeywordTip()
			end

			-- Show the keyword in the option tooltip on startup
			SetKeywordTip()

			-- Save the keyword when it changes
			KeyBox:SetScript("OnTextChanged", SetInvKey)

			-- Refresh editbox with trimmed keyword when edit focus is lost (removes additional spaces)
			KeyBox:SetScript("OnEditFocusLost", function()
				KeyBox:SetText(LeaPlusLC["InvKey"])
			end)

			-- Help button hidden
			InvPanel.h:Hide()

			-- Back button handler
			InvPanel.b:SetScript("OnClick", function()
				-- Save the keyword
				SetInvKey()
				-- Show the options panel
				InvPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page2"]:Show()
				return
			end)

			-- Add reset button
			InvPanel.r:SetScript("OnClick", function()
				-- Settings
				LeaPlusLC["InviteFriendsOnly"] = "Off"
				-- Reset the keyword to default
				LeaPlusLC["InvKey"] = "inv"
				-- Set the editbox to default
				KeyBox:SetText("inv")
				-- Save the keyword
				SetInvKey()
				-- Refresh panel
				InvPanel:Hide(); InvPanel:Show()
			end)

			-- Ensure keyword is a string on startup
			LeaPlusLC["InvKey"] = tostring(LeaPlusLC["InvKey"]) or "inv"

			-- Set editbox value when shown
			KeyBox:HookScript("OnShow", function()
				KeyBox:SetText(LeaPlusLC["InvKey"])
			end)

			-- Configuration button handler
			LeaPlusCB["InvWhisperBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["InviteFriendsOnly"] = "On"
					LeaPlusLC["InvKey"] = "inv"
					KeyBox:SetText(LeaPlusLC["InvKey"])
					SetInvKey()
				else
					-- Show panel
					InvPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Party from friends (no reload required)
		----------------------------------------------------------------------

		do

			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1, ...)

				-- If a friend, accept if you're accepting friends and not queued
				local void, void, void, void, void, guid = ...
				if (LeaPlusLC["AcceptPartyFriends"] == "On" and LeaPlusLC:FriendCheck(arg1, guid)) then
					if not LeaPlusLC:IsInLFGQueue() then
						AcceptGroup()
						StaticPopup_ForEachShownDialog(function(self)
							if self.which == "PARTY_INVITE" then
								self.inviteAccepted = 1
								StaticPopup_Hide("PARTY_INVITE")
								return
							elseif self.which == "PARTY_INVITE_XREALM" then
								self.inviteAccepted = 1
								StaticPopup_Hide("PARTY_INVITE_XREALM")
								return
							end
						end)
						-- Confirm invite to party sync group request
						if QuestSessionManager.ConfirmInviteToGroupReceivedDialog.ButtonContainer.Confirm:IsShown() then
							QuestSessionManager.ConfirmInviteToGroupReceivedDialog.ButtonContainer.Confirm:Click()
						end
						return
					end
				end
				return

			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["AcceptPartyFriends"] == "On" then
					frame:RegisterEvent("PARTY_INVITE_REQUEST")
				else
					frame:UnregisterEvent("PARTY_INVITE_REQUEST")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["AcceptPartyFriends"] == "On" then SetEvent() end
			LeaPlusCB["AcceptPartyFriends"]:HookScript("OnClick", SetEvent)

		end
		----------------------------------------------------------------------
		--	Block party invites (no reload required)
		----------------------------------------------------------------------

		do

			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1, ...)
				-- If not a friend and you're blocking invites, decline
				local void, void, void, void, void, guid = ...
				if LeaPlusLC["NoPartyInvites"] == "On" then
					if LeaPlusLC:FriendCheck(arg1, guid) then
						return
					else
						DeclineGroup()
						StaticPopup_Hide("PARTY_INVITE")
						StaticPopup_Hide("PARTY_INVITE_XREALM")
						-- Decline invite to party sync group request
						if QuestSessionManager.ConfirmInviteToGroupReceivedDialog.ButtonContainer.Decline:IsShown() then
							QuestSessionManager.ConfirmInviteToGroupReceivedDialog.ButtonContainer.Decline:Click()
						end
						return
					end
				end
				return
			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["NoPartyInvites"] == "On" then
					frame:RegisterEvent("PARTY_INVITE_REQUEST")
				else
					frame:UnregisterEvent("PARTY_INVITE_REQUEST")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["NoPartyInvites"] == "On" then SetEvent() end
			LeaPlusCB["NoPartyInvites"]:HookScript("OnClick", SetEvent)

		end

		----------------------------------------------------------------------
		--	Automatic summon (no reload required)
		----------------------------------------------------------------------

		do

			-- Event function
			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1)
				if not UnitAffectingCombat("player") then
					local sName = C_SummonInfo.GetSummonConfirmSummoner()
					local sLocation = C_SummonInfo.GetSummonConfirmAreaName()
					LeaPlusLC:Print(L["The summon from"] .. " " .. sName .. " (" .. sLocation .. ") " .. L["will be automatically accepted in 10 seconds unless cancelled."])
					C_Timer.After(10, function()
						local sNameNew = C_SummonInfo.GetSummonConfirmSummoner()
						local sLocationNew = C_SummonInfo.GetSummonConfirmAreaName()
						if sName == sNameNew and sLocation == sLocationNew then
							-- Automatically accept summon after 10 seconds if summoner name and location have not changed
							C_SummonInfo.ConfirmSummon()
							StaticPopup_Hide("CONFIRM_SUMMON")
						end
					end)
				end
				return
			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["AutoAcceptSummon"] == "On" then
					frame:RegisterEvent("CONFIRM_SUMMON")
				else
					frame:UnregisterEvent("CONFIRM_SUMMON")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["AutoAcceptSummon"] == "On" then SetEvent() end
			LeaPlusCB["AutoAcceptSummon"]:HookScript("OnClick", SetEvent)

		end

		----------------------------------------------------------------------
		--	Disable loot warnings (no reload required)
		----------------------------------------------------------------------

		do

			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", function(self, event, arg1, arg2, ...)

				-- Disable warnings for attempting to roll Need or Disenchant on loot
				if event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL" then
					ConfirmLootRoll(arg1, arg2)
					StaticPopup_Hide("CONFIRM_LOOT_ROLL")
					return
				end

				-- Disable warning for attempting to loot a Bind on Pickup item
				if event == "LOOT_BIND_CONFIRM" then
					ConfirmLootSlot(arg1, arg2)
					StaticPopup_Hide("LOOT_BIND",...)
					return
				end

				-- Disable warning for attempting to vendor an item within its refund window
				if event == "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL" then
					SellCursorItem()
					return
				end

				-- Disable warning for attempting to mail an item within its refund window
				if event == "MAIL_LOCK_SEND_ITEMS" then
					RespondMailLockSendItem(arg1, true)
					return
				end

			end)

			-- Function to set event
			local function SetEvent()
				if LeaPlusLC["NoConfirmLoot"] == "On" then
					frame:RegisterEvent("CONFIRM_LOOT_ROLL")
					frame:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
					frame:RegisterEvent("LOOT_BIND_CONFIRM")
					frame:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
					frame:RegisterEvent("MAIL_LOCK_SEND_ITEMS")
				else
					frame:UnregisterEvent("CONFIRM_LOOT_ROLL")
					frame:UnregisterEvent("CONFIRM_DISENCHANT_ROLL")
					frame:UnregisterEvent("LOOT_BIND_CONFIRM")
					frame:UnregisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
					frame:UnregisterEvent("MAIL_LOCK_SEND_ITEMS")
				end
			end

			-- Set event on startup if enabled and when option is clicked
			if LeaPlusLC["NoConfirmLoot"] == "On" then SetEvent() end
			LeaPlusCB["NoConfirmLoot"]:HookScript("OnClick", SetEvent)

		end

		----------------------------------------------------------------------
		-- Mute mount sounds (no reload required)
		----------------------------------------------------------------------

		do

			-- Get mute table
			local mountTable = Leatrix_Plus["mountTable"]

			-- Give table file level scope (its used during logout and for wipe and admin commands)
			LeaPlusLC["mountTable"] = mountTable

			-- Load saved settings or set default values
			for k, v in pairs(mountTable) do
				if LeaPlusDB[k] and type(LeaPlusDB[k]) == "string" and LeaPlusDB[k] == "On" or LeaPlusDB[k] == "Off" then
					LeaPlusLC[k] = LeaPlusDB[k]
				else
					LeaPlusLC[k] = "Off"
					LeaPlusDB[k] = "Off"
				end
			end

			-- Create configuration panel
			local MountPanel = LeaPlusLC:CreatePanel("Mute mount sounds", "MountPanel")

			-- Add checkboxes
			LeaPlusLC:MakeTx(MountPanel, "Mounts", 16, -72)
			LeaPlusLC:MakeCB(MountPanel, "MuteAerials", "Aerials", 16, -92, false, "If checked, jet aerial units will be quieter.|n|nThis applies to Aerial Unit R-21X and Rustbolt Resistor.")
			LeaPlusLC:MakeCB(MountPanel, "MuteAirships", "Airships", 16, -112, false, "If checked, airships will be muted.|n|nThis applies to airship mounts and transports.")
			LeaPlusLC:MakeCB(MountPanel, "MuteBikes", "Bikes", 16, -132, false, "If checked, most of the bike mount sounds will be muted.")
			LeaPlusLC:MakeCB(MountPanel, "MuteBrooms", "Brooms", 16, -152, false, "If checked, broom mounts will be muted.")
			LeaPlusLC:MakeCB(MountPanel, "MuteDragonriding", "Dragonriding", 16, -172, false, "If checked, dragonriding mounts will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MuteFish", "Fish", 16, -192, false, "If checked, fish mounts will be quieter.|n|nThis applies to Wondrous Wavewhisker.")
			LeaPlusLC:MakeCB(MountPanel, "MuteFurlines", "Furlines", 16, -212, false, "If checked, furlines will be muted.")
			LeaPlusLC:MakeCB(MountPanel, "MuteGyrocopters", "Gyrocopters", 16, -232, false, "If checked, gyrocopters will be muted.|n|nThis applies to Mimiron's Head, Mecha-Mogul MK2 and other gyrocopter mounts.|n|nEnabling this option will also mute airplane gear shift sounds.")

			LeaPlusLC:MakeCB(MountPanel, "MuteHovercraft", "Hovercraft", 150, -92, false, "If checked, hovercraft will be quieter.|n|nThis applies to Xiwyllag ATV.")
			LeaPlusLC:MakeCB(MountPanel, "MuteLunarwing", "Lunarwing", 150, -112, false, "If checked, Archdruid's Lunarwing Form will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MuteMechSteps", "Mechsteps", 150, -132, false, "If checked, footsteps for mechanical mounts will be muted.")
			LeaPlusLC:MakeCB(MountPanel, "MuteStriders", "Mechstriders", 150, -152, false, "If checked, mechanostriders will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MuteMechsuits", "Mechsuits", 150, -172, false, "If checked, mechsuits will be quieter.|n|nThis applies to Felsteel Annihilator, Lightforged Warframe, Sky Golem and other mechsuits.")
			LeaPlusLC:MakeCB(MountPanel, "MuteOttuks", "Ottuks", 150, -192, false, "If checked, ottuks will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MutePanthers", "Panthers", 150, -212, false, "If checked, the jewelcrafting panther mounts will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MuteRabbits", "Rabbits", 150, -232, false, "If checked, divine rabbit mounts will be quieter.|n|nThis applies to Jade, Bright Foreseer.")

			LeaPlusLC:MakeCB(MountPanel, "MuteRazorwings", "Razorwings", 284, -92, false, "If checked, razorwings will be muted.")
			LeaPlusLC:MakeCB(MountPanel, "MuteRockets", "Rockets", 284, -112, false, "If checked, rockets will be muted.")
			LeaPlusLC:MakeCB(MountPanel, "MuteSoulEaters", "Soul Eaters", 284, -132, false, "If checked, Gladiator Soul Eater mounts will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MuteSoulseekers", "Soulseekers", 284, -152, false, "If checked, soulseekers will be quieter.|n|nThis applies to Corridor Creeper, Mawsworn Soulhunter and Bound Shadehound.")
			LeaPlusLC:MakeCB(MountPanel, "MuteTravelers", "Travelers", 284, -172, false, "If checked, traveling merchant greetings and farewells will be muted.|n|nThis applies to Traveler's Tundra Mammoth, Grand Expedition Yak and Mighty Caravan Brutosaur.")
			LeaPlusLC:MakeCB(MountPanel, "MuteUnicorns", "Unicorns", 284, -192, false, "If checked, unicorns will be quieter.|n|nThis applies to Lucid Nightmare, Wild Dreamrunner, Pureheart Courser and other unicorn mounts.")
			LeaPlusLC:MakeCB(MountPanel, "MuteZeppelins", "Zeppelins", 284, -212, false, "If checked, zeppelins will be muted.|n|nThis applies to zeppelin mounts and transports.")

			LeaPlusLC:MakeTx(MountPanel, "Specific", 418, -72)
			LeaPlusLC:MakeCB(MountPanel, "MuteBanLu", "Ban-Lu", 418, -92, false, "If checked, Ban-Lu will no longer talk to you.")
			LeaPlusLC:MakeCB(MountPanel, "MuteSoar", "Soar", 418, -112, false, "If checked, Soar (Dracthyr) will be quieter.")
			LeaPlusLC:MakeCB(MountPanel, "MuteTempest", "Tempest", 418, -132, false, "If checked, the Coldflame Tempest mount will be quieter.")

			-- Set click width for sounds checkboxes
			for k, v in pairs(mountTable) do
				LeaPlusCB[k].f:SetWidth(90)
				if LeaPlusCB[k].f:GetStringWidth() > 90 then
					LeaPlusCB[k]:SetHitRectInsets(0, -80, 0, 0)
				else
					LeaPlusCB[k]:SetHitRectInsets(0, -LeaPlusCB[k].f:GetStringWidth() + 4, 0, 0)
				end
			end

			-- Function to mute and unmute sounds
			local function SetupMute()
				for k, v in pairs(mountTable) do
					if LeaPlusLC["MuteMountSounds"] == "On" and LeaPlusLC[k] == "On" then
						for i, e in pairs(v) do
							local file, soundID = e:match("([^,]+)%#([^,]+)")
							MuteSoundFile(soundID)
						end
					else
						for i, e in pairs(v) do
							local file, soundID = e:match("([^,]+)%#([^,]+)")
							UnmuteSoundFile(soundID)
						end
					end
				end
			end

			-- Setup mute on startup if option is enabled
			if LeaPlusLC["MuteMountSounds"] == "On" then SetupMute() end

			-- Mute sounds when UNIT_FACTION is loaded (required for Soar)
			local delayMute = CreateFrame("FRAME")
			delayMute:RegisterEvent("UNIT_FACTION")
			delayMute:SetScript("OnEvent", function() if LeaPlusLC["MuteMountSounds"] == "On" then SetupMute() end end)

			-- Setup mute when options are clicked
			for k, v in pairs(mountTable) do
				LeaPlusCB[k]:HookScript("OnClick", SetupMute)
			end
			LeaPlusCB["MuteMountSounds"]:HookScript("OnClick", SetupMute)

			-- Help button hidden
			MountPanel.h:Hide()

			-- Back button handler
			MountPanel.b:SetScript("OnClick", function()
				MountPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
				return
			end)

			-- Reset button handler
			MountPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				for k, v in pairs(mountTable) do
					LeaPlusLC[k] = "Off"
				end
				SetupMute()

				-- Refresh panel
				MountPanel:Hide(); MountPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["MuteMountSoundsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					for k, v in pairs(mountTable) do
						LeaPlusLC[k] = "On"
					end
					SetupMute()
				else
					MountPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Mute game sounds (no reload required)
		----------------------------------------------------------------------

		do

			-- Get mute table
			local muteTable = Leatrix_Plus["muteTable"]

			-- Give table file level scope (its used during logout and for wipe and admin commands)
			LeaPlusLC["muteTable"] = muteTable

			-- Load saved settings or set default values
			for k, v in pairs(muteTable) do
				if LeaPlusDB[k] and type(LeaPlusDB[k]) == "string" and LeaPlusDB[k] == "On" or LeaPlusDB[k] == "Off" then
					LeaPlusLC[k] = LeaPlusDB[k]
				else
					LeaPlusLC[k] = "Off"
					LeaPlusDB[k] = "Off"
				end
			end

			-- Create configuration panel
			local SoundPanel = LeaPlusLC:CreatePanel("Mute game sounds", "SoundPanel")

			-- Add checkboxes
			LeaPlusLC:MakeTx(SoundPanel, "General", 16, -72)
			LeaPlusLC:MakeCB(SoundPanel, "MuteChimes", "Chimes", 16, -92, false, "If checked, clock hourly chimes will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteEvents", "Events", 16, -112, false, "If checked, holiday event sounds will be muted.|n|nThis applies to Headless Horseman.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteFizzle", "Fizzle", 16, -132, false, "If checked, the spell fizzle sounds will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteInterface", "Interface", 16, -152, false, "If checked, the interface button sound, the chat frame tab click sound and the game menu toggle sound will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteLogin", "Login", 16, -172, false, "If checked, login screen sounds will be muted when you logout of the game.|n|nNote that login screen sounds will not be muted when you initially launch the game.|n|nThey will only be muted when you logout of the game.  This includes manually logging out as well as being forcefully logged out by the game server for reasons such as being away for an extended period of time.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteReady", "Ready", 16, -192, false, "If checked, the ready check sound will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteSniffing", "Sniffing", 16, -212, false, "If checked, the worgen sniffing sounds will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteTrains", "Trains", 16, -232, false, "If checked, train sounds will be muted.")

			LeaPlusLC:MakeTx(SoundPanel, "General", 150, -72)
			LeaPlusLC:MakeCB(SoundPanel, "MuteVaults", "Vaults", 150, -92, false, "If checked, the mechanical guild vault idle sound will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteVigor", "Vigor", 150, -112, false, "If checked, the dragonriding vigor recharging sound will be muted.")

			LeaPlusLC:MakeTx(SoundPanel, "Pets", 150, -152)
			LeaPlusLC:MakeCB(SoundPanel, "MutePierre", "Pierre", 150, -172, false, "If checked, Pierre will be quieter.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteSunflower", "Sunflower", 150, -192, false, "If checked, the Singing Sunflower pet will be muted.")

			LeaPlusLC:MakeTx(SoundPanel, "Toys", 284, -72)
			LeaPlusLC:MakeCB(SoundPanel, "MuteAnima", "Anima", 284, -92, false, "If checked, the Experimental Anima Cell toy will be quieter.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteBalls", "Balls", 284, -112, false, "If checked, the Foot Ball sounds will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteHarp", "Harp", 284, -132, false, "If checked, the Fae Harp toy will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteMeerah", "Meerah", 284, -152, false, "If checked, Meerah's Jukebox wil be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MutePiccolo", "Piccolo", 284, -172, false, "If checked, Piccolo of the Flaming Fire wil be muted.|n|nNote that enabling this will also mute the harp sound of the warlock seduction spell.")

			LeaPlusLC:MakeTx(SoundPanel, "Combat", 284, -212)
			LeaPlusLC:MakeCB(SoundPanel, "MuteArena", "Arena", 284, -232, false, "If checked, arena announcers will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteBattleShouts", "Shouts", 284, -252, false, "If checked, your character will not shout and wail during combat.")

			LeaPlusLC:MakeTx(SoundPanel, "Misc", 418, -72)
			LeaPlusLC:MakeCB(SoundPanel, "MuteDucks", "Ducks", 418, -92, false, "If checked, duck greetings will be muted.|n|nUse this if you like to do your Valdrakken banking in peace.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteYawns", "Yawns", 418, -112, false, "If checked, yawns from hunter pet cats will be muted.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteDundun", "Dundun", 418, -132, false, "If checked, Dundun (Loa of Abundance) will be quieter.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteValeera", "Valeera", 418, -152, false, "If checked, Valeera (Midnight) will be quieter.")
			LeaPlusLC:MakeCB(SoundPanel, "MuteNanea", "Nanea", 418, -172, false, "If checked, Loa Speaker Nanea (Devout of Nalorakk) will be quieter.")

			-- Set click width for sounds checkboxes
			for k, v in pairs(muteTable) do
				LeaPlusCB[k].f:SetWidth(90)
				if LeaPlusCB[k].f:GetStringWidth() > 90 then
					LeaPlusCB[k]:SetHitRectInsets(0, -80, 0, 0)
				else
					LeaPlusCB[k]:SetHitRectInsets(0, -LeaPlusCB[k].f:GetStringWidth() + 4, 0, 0)
				end
			end

			-- Function to mute and unmute sounds
			local function SetupMute()
				for k, v in pairs(muteTable) do
					if LeaPlusLC["MuteGameSounds"] == "On" and LeaPlusLC[k] == "On" then
						for i, e in pairs(v) do
							local file, soundID = e:match("([^,]+)%#([^,]+)")
							MuteSoundFile(soundID)
						end
					else
						for i, e in pairs(v) do
							local file, soundID = e:match("([^,]+)%#([^,]+)")
							UnmuteSoundFile(soundID)
						end
					end
				end
			end

			-- Setup mute on startup if option is enabled
			if LeaPlusLC["MuteGameSounds"] == "On" then SetupMute() end

			-- Setup mute when options are clicked
			for k, v in pairs(muteTable) do
				LeaPlusCB[k]:HookScript("OnClick", SetupMute)
			end
			LeaPlusCB["MuteGameSounds"]:HookScript("OnClick", SetupMute)

			-- Help button hidden
			SoundPanel.h:Hide()

			-- Back button handler
			SoundPanel.b:SetScript("OnClick", function()
				SoundPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
				return
			end)

			-- Reset button handler
			SoundPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				for k, v in pairs(muteTable) do
					LeaPlusLC[k] = "Off"
				end
				SetupMute()

				-- Refresh panel
				SoundPanel:Hide(); SoundPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["MuteGameSoundsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					for k, v in pairs(muteTable) do
						LeaPlusLC[k] = "On"
					end
					LeaPlusLC["MuteReady"] = "Off"
					LeaPlusLC["MuteVigor"] = "Off"
					SetupMute()
				else
					SoundPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			----------------------------------------------------------------------
			-- Login setting
			----------------------------------------------------------------------

			-- Handle sounds that get muted or unmuted when logging out
			local muteLogoutTable = Leatrix_Plus["muteLogoutTable"]
			local logoutEvent = CreateFrame("FRAME")
			logoutEvent:RegisterEvent("PLAYER_LOGOUT")

			-- Mute or unmute sounds when logging out
			logoutEvent:SetScript("OnEvent", function()
				if LeaPlusLC["MuteGameSounds"] == "On" and LeaPlusLC["MuteLogin"] == "On" then
					-- Mute logout table sounds on logout
					for void, soundID in pairs(muteLogoutTable) do
						MuteSoundFile(soundID)
					end
				else
					-- Unmute logout table sounds on logout
					for void, soundID in pairs(muteLogoutTable) do
						UnmuteSoundFile(soundID)
					end
				end
			end)

			-- Unmute sounds when logging in
			for void, soundID in pairs(muteLogoutTable) do
				UnmuteSoundFile(soundID)
			end

		end

		----------------------------------------------------------------------
		-- Faster movie skip
		----------------------------------------------------------------------

		if LeaPlusLC["FasterMovieSkip"] == "On" then

			-- Allow space bar, escape key and enter key to cancel cinematic without confirmation
			CinematicFrame:HookScript("OnKeyDown", function(self, key)
				if key == "ESCAPE" then
					if CinematicFrame:IsShown() and CinematicFrame.closeDialog and CinematicFrameCloseDialogConfirmButton then
						CinematicFrameCloseDialog:Hide()
					end
				end
			end)
			CinematicFrame:HookScript("OnKeyUp", function(self, key)
				if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
					if CinematicFrame:IsShown() and CinematicFrame.closeDialog and CinematicFrameCloseDialogConfirmButton then
						CinematicFrameCloseDialogConfirmButton:Click()
					end
				end
			end)
			MovieFrame:HookScript("OnKeyUp", function(self, key)
				if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
					if MovieFrame.CloseDialog.Buttons.ConfirmButton then
						MovieFrame.CloseDialog.Buttons.ConfirmButton:Click()
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Wowhead Links
		----------------------------------------------------------------------

		if LeaPlusLC["ShowWowheadLinks"] == "On" then

			-- Create configuration panel
			local WowheadPanel = LeaPlusLC:CreatePanel("Show Wowhead links", "WowheadPanel")

			LeaPlusLC:MakeTx(WowheadPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(WowheadPanel, "WowheadLinkComments", "Links go directly to the comments section", 16, -92, false, "If checked, Wowhead links will go directly to the comments section.")

			-- Help button hidden
			WowheadPanel.h:Hide()

			-- Back button handler
			WowheadPanel.b:SetScript("OnClick", function()
				WowheadPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			WowheadPanel.r:SetScript("OnClick", function()

				-- Reset controls
				LeaPlusLC["WowheadLinkComments"] = "Off"

				-- Refresh configuration panel
				WowheadPanel:Hide(); WowheadPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["ShowWowheadLinksBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["WowheadLinkComments"] = "Off"
				else
					WowheadPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Get localised Wowhead URL
			local wowheadLoc
			if GameLocale == "deDE" then wowheadLoc = "de.wowhead.com"
			elseif GameLocale == "esMX" then wowheadLoc = "mx.wowhead.com"
			elseif GameLocale == "esES" then wowheadLoc = "es.wowhead.com"
			elseif GameLocale == "frFR" then wowheadLoc = "fr.wowhead.com"
			elseif GameLocale == "itIT" then wowheadLoc = "it.wowhead.com"
			elseif GameLocale == "ptBR" then wowheadLoc = "pt.wowhead.com"
			elseif GameLocale == "ruRU" then wowheadLoc = "ru.wowhead.com"
			elseif GameLocale == "koKR" then wowheadLoc = "ko.wowhead.com"
			elseif GameLocale == "zhCN" then wowheadLoc = "cn.wowhead.com"
			elseif GameLocale == "zhTW" then wowheadLoc = "tw.wowhead.com"
			else							 wowheadLoc = "wowhead.com"
			end

			----------------------------------------------------------------------
			-- Achievements frame
			----------------------------------------------------------------------

			-- Achievement link function
			EventUtil.ContinueOnAddOnLoaded("Blizzard_AchievementUI",function()

				-- Create editbox
				local aEB = CreateFrame("EditBox", nil, AchievementFrame)
				aEB:ClearAllPoints()
				aEB:SetPoint("BOTTOMRIGHT", -50, 1)
				aEB:SetHeight(16)
				aEB:SetFontObject("GameFontNormalSmall")
				aEB:SetBlinkSpeed(0)
				aEB:SetJustifyH("RIGHT")
				aEB:SetAutoFocus(false)
				aEB:EnableKeyboard(false)
				aEB:SetHitRectInsets(90, 0, 0, 0)
				aEB:SetScript("OnKeyDown", function() end)
				aEB:SetScript("OnMouseUp", function()
					if aEB:IsMouseOver() then
						aEB:HighlightText()
					else
						aEB:HighlightText(0, 0)
					end
				end)

				-- Create hidden font string (used for setting width of editbox)
				aEB.z = aEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
				aEB.z:Hide()

				-- Store last link in case editbox is cleared
				local lastAchievementLink

				-- Function to set editbox value
				local function SetAchievementFunc(self, achievementID)
					if achievementID then
						-- Set editbox text
						if LeaPlusLC["WowheadLinkComments"] == "On" then
							aEB:SetText("https://" .. wowheadLoc .. "/achievement=" .. achievementID .. "#comments")
						else
							aEB:SetText("https://" .. wowheadLoc .. "/achievement=" .. achievementID)
						end
						lastAchievementLink = aEB:GetText()
						-- Set hidden fontstring then resize editbox to match
						aEB.z:SetText(aEB:GetText())
						aEB:SetWidth(aEB.z:GetStringWidth() + 90)
						-- Get achievement title for tooltip
						local achievementLink = GetAchievementLink(achievementID)
						if achievementLink then
							aEB.tiptext = achievementLink:match("%[(.-)%]") .. "|n" .. L["Press CTRL/C to copy."]
						end
						-- Show the editbox
						aEB:Show()
					end
				end
				hooksecurefunc(AchievementTemplateMixin, "DisplayObjectives", SetAchievementFunc)
				hooksecurefunc("AchievementFrameComparisonTab_OnClick", function(self) aEB:Hide() end)

				-- Create tooltip
				aEB:HookScript("OnEnter", function()
					aEB:HighlightText()
					aEB:SetFocus()
					GameTooltip:SetOwner(aEB, "ANCHOR_TOP", 0, 10)
					GameTooltip:SetText(aEB.tiptext, nil, nil, nil, nil, true)
					GameTooltip:Show()
				end)

				aEB:HookScript("OnLeave", function()
					-- Set link text again if it's changed since it was set
					if aEB:GetText() ~= lastAchievementLink then aEB:SetText(lastAchievementLink) end
					aEB:HighlightText(0, 0)
					aEB:ClearFocus()
					GameTooltip:Hide()
				end)

			end)

			----------------------------------------------------------------------
			-- World map frame
			----------------------------------------------------------------------

			-- Hide the title text
			WorldMapFrameTitleText:Hide()

			-- Create editbox
			local mEB = CreateFrame("EditBox", nil, WorldMapFrame.BorderFrame)
			mEB:SetFrameLevel(501)
			mEB:ClearAllPoints()
			mEB:SetPoint("TOPLEFT", 100, -4)
			mEB:SetHeight(16)
			mEB:SetFontObject("GameFontNormal")
			mEB:SetBlinkSpeed(0)
			mEB:SetAutoFocus(false)
			mEB:EnableKeyboard(false)
			mEB:SetHitRectInsets(0, 90, 0, 0)
			mEB:SetScript("OnKeyDown", function() end)
			mEB:SetScript("OnMouseUp", function()
				if mEB:IsMouseOver() then
					mEB:HighlightText()
				else
					mEB:HighlightText(0, 0)
				end
			end)

			-- Create hidden font string (used for setting width of editbox)
			mEB.z = mEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			mEB.z:Hide()

			-- Function to set editbox value
			local function SetQuestInBox()
				local questID
				if QuestMapFrame.DetailsFrame:IsShown() then
					-- Get quest ID from currently showing quest in details panel
					questID = QuestMapFrame_GetDetailQuestID()
				else
					-- Get quest ID from currently selected quest on world map
					questID = C_SuperTrack.GetSuperTrackedQuestID()
				end
				if questID then
					-- Hide editbox if quest ID is invalid
					if questID == 0 then mEB:Hide() else mEB:Show() end
					-- Set editbox text
					if LeaPlusLC["WowheadLinkComments"] == "On" then
						mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID .. "#comments")
					else
						mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)
					end
					-- Set hidden fontstring then resize editbox to match
					mEB.z:SetText(mEB:GetText())
					mEB:SetWidth(mEB.z:GetStringWidth() + 90)
					-- Get quest title for tooltip
					local questLink = GetQuestLink(questID) or nil
					if questLink then
						mEB.tiptext = questLink:match("%[(.-)%]") .. "|n" .. L["Press CTRL/C to copy."]
					else
						mEB.tiptext = ""
						if mEB:IsMouseOver() and GameTooltip:IsShown() then GameTooltip:Hide() end
					end
				end
			end

			-- Set URL when super tracked quest changes and on startup
			mEB:RegisterEvent("SUPER_TRACKING_CHANGED")
			mEB:SetScript("OnEvent", SetQuestInBox)
			SetQuestInBox()

			-- Set URL when quest details frame is shown or hidden
			hooksecurefunc("QuestMapFrame_ShowQuestDetails", SetQuestInBox)
			hooksecurefunc("QuestMapFrame_CloseQuestDetails", SetQuestInBox)

			-- Create tooltip
			mEB:HookScript("OnEnter", function()
				mEB:HighlightText()
				mEB:SetFocus()
				GameTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
				GameTooltip:SetText(mEB.tiptext, nil, nil, nil, nil, true)
				GameTooltip:Show()
			end)

			mEB:HookScript("OnLeave", function()
				mEB:HighlightText(0, 0)
				mEB:ClearFocus()
				GameTooltip:Hide()
				SetQuestInBox()
			end)

			-- Set position for Leatrix Maps 'Simple map frame' setting.
			EventUtil.ContinueOnAddOnLoaded("Leatrix_Maps",function()
				if LeaMapsDB and LeaMapsDB["SimpleMapFrame"] and LeaMapsDB["SimpleMapFrame"] == "On" then
					mEB:ClearAllPoints()
					mEB:SetPoint("TOPLEFT", WorldMapFrame.ScrollContainer, "TOPLEFT", 170, -4)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Enhance dressup
		----------------------------------------------------------------------

		if LeaPlusLC["EnhanceDressup"] == "On" and not LeaLockList["EnhanceDressup"] then

			-- Create configuration panel
			local DressupPanel = LeaPlusLC:CreatePanel("Enhance dressup", "DressupPanel")

			LeaPlusLC:MakeTx(DressupPanel, "Dressing room", 16, -72)
			LeaPlusLC:MakeCB(DressupPanel, "DressupItemButtons", "Show item buttons", 16, -92, false, "If checked, item buttons will be shown in the dressing room.  You can click the item buttons to hide individual items on the model and click them again to show them.")
			LeaPlusLC:MakeCB(DressupPanel, "DressupAnimControl", "Show animation slider", 16, -112, false, "If checked, an animation slider will be shown in the dressing room.")

			LeaPlusLC:MakeTx(DressupPanel, "Transmogrify character preview", 16, -152)
			LeaPlusLC:MakeCB(DressupPanel, "DressupMoreZoomOut", "Increase zoom out distance", 16, -172, true, "If checked, you will be able to zoom out further with the transmogrify character preview.")
			LeaPlusLC:MakeCB(DressupPanel, "DressupTransmogAnim", "Show animation slider", 16, -192, false, "If checked, an animation slider will be shown in the transmogrify character preview.")

			LeaPlusLC:MakeTx(DressupPanel, "Zoom speed", 356, -72)
			LeaPlusLC:MakeSL(DressupPanel, "DressupFasterZoom", "Drag to set the character model zoom speed.", 1, 10, 1, 356, -92, "%.0f")

			-- Refresh zoom speed slider when changed
			LeaPlusCB["DressupFasterZoom"]:HookScript("OnValueChanged", function()
				LeaPlusCB["DressupFasterZoom"].f:SetFormattedText("%.0f%%", LeaPlusLC["DressupFasterZoom"] * 100)
			end)

			-- Set zoom speed when dressup model is zoomed (wardrobe is set in wardrobe section further down)
			DressUpFrame.ModelScene:SetScript("OnMouseWheel", function(self, delta)
				for i = 1, LeaPlusLC["DressupFasterZoom"] do
					if DressUpFrame.ModelScene.activeCamera then
						DressUpFrame.ModelScene.activeCamera:OnMouseWheel(delta)
					end
				end
			end)

			-- Set zoom speed when character frame model is zoomed
			CharacterModelScene:SetScript("OnMouseWheel", function(self, delta)
				for i = 1, LeaPlusLC["DressupFasterZoom"] do
					if CharacterModelScene.activeCamera then
						CharacterModelScene.activeCamera:OnMouseWheel(delta)
					end
				end
			end)

			-- Help button hidden
			DressupPanel.h:Hide()

			-- Back button handler
			DressupPanel.b:SetScript("OnClick", function()
				DressupPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			DressupPanel.r.tiptext = DressupPanel.r.tiptext .. "|n|n" .. L["Note that this will not reset settings that require a UI reload."]
			DressupPanel.r:SetScript("OnClick", function()

				-- Reset controls
				LeaPlusLC["DressupFasterZoom"] = 3

				-- Refresh configuration panel
				DressupPanel:Hide(); DressupPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["EnhanceDressupBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["DressupFasterZoom"] = 3
				else
					DressupPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			----------------------------------------------------------------------
			-- Item buttons
			----------------------------------------------------------------------

			-- Shared with the bottom buttons (further down)
			local DressupGear = {}

			-- Secret values: the game can hide some values from addons (such as in instances), so anything that could be hidden is checked first
			local function Safe(v)
				if issecretvalue and issecretvalue(v) then return nil end
				return v
			end

			-- The player model in the dressing room (nil when it shows something else, such as a mount)
			local function GetActor()
				return DressUpFrame.ModelScene:GetPlayerActor()
			end

			-- Give a button the same look as the item slots in the character sheet (the icon is btn.t)
			local function PaperDollButton(btn, size)
				btn:SetSize(size, size)
				local bg = btn:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints()
				bg:SetColorTexture(0, 0, 0, 0.7) -- Behind the icon (portraits are round, so this fills the corners)
				btn.t = btn:CreateTexture(nil, "BORDER")
				btn.t:SetAllPoints()
				btn:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
				local border = btn:GetNormalTexture()
				border:ClearAllPoints()
				border:SetSize(size * 64 / 37, size * 64 / 37)
				border:SetPoint("CENTER", 0, -size / 37)
				btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
				btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
			end

			-- Show a message in the dressing room, at the top of the model on a dark background, which fades out after a few seconds
			do
				local msgFrame = CreateFrame("Frame", nil, DressUpFrame)
				msgFrame:SetFrameStrata("HIGH")
				msgFrame:SetPoint("TOPLEFT", DressUpFrame, "TOPLEFT", 52, -68)
				msgFrame:SetPoint("TOPRIGHT", DressUpFrame, "TOPRIGHT", -54, -68)
				msgFrame:SetHeight(30)
				msgFrame:Hide()
				local bg = msgFrame:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints()
				bg:SetColorTexture(0, 0, 0, 0.75)
				local text = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				text:SetPoint("TOPLEFT", 6, -6)
				text:SetPoint("TOPRIGHT", -6, -6)
				text:SetJustifyH("CENTER")
				local fade = msgFrame:CreateAnimationGroup()
				local alpha = fade:CreateAnimation("Alpha")
				alpha:SetFromAlpha(1)
				alpha:SetToAlpha(0)
				alpha:SetStartDelay(3)
				alpha:SetDuration(0.5)
				fade:SetScript("OnFinished", function() msgFrame:Hide() end)
				function DressupGear.Message(message)
					text:SetText(message)
					msgFrame:SetHeight(text:GetStringHeight() + 12) -- Fits the text (long messages go over two lines)
					fade:Stop()
					msgFrame:SetAlpha(1)
					msgFrame:Show()
					fade:Play()
				end
				DressUpFrame:HookScript("OnHide", function() fade:Stop() msgFrame:Hide() end)
			end

			do

				local buttons, slotOrder = {}, {}
				local slotInfo, hiddenSlots, nudeSaved = {}, {}, {} -- Appearance in each slot (transmog info), slots taken off, slots to put back on after nude
				local mode -- What the model shows: me, target, myOutfitOnTarget or targetOutfitOnMe
				local nudeBtn -- The all items button at the bottom of the left column

				-- Set what the model shows (the bottom buttons show it)
				local function SetMode(newMode)
					mode = newMode
					if DressupGear.OnModeChanged then DressupGear.OnModeChanged() end
				end
				function DressupGear.GetMode() return mode end

				-- Slot buttons (slot name, icon shown when the game has no empty slot picture)
				local leftSlots = {{"HeadSlot", "INV_Misc_Desecrated_ClothHelm"}, {"ShoulderSlot", "INV_Misc_Desecrated_ClothShoulder"}, {"BackSlot", "INV_Misc_Cape_01"}, {"ChestSlot", "INV_Misc_Desecrated_ClothChest"}, {"ShirtSlot", "INV_Shirt_01"}, {"TabardSlot", "INV_Shirt_GuildTabard_01"}, {"WristSlot", "INV_Misc_Desecrated_ClothBracer"}}
				local rightSlots = {{"HandsSlot", "INV_Misc_Desecrated_ClothGlove"}, {"WaistSlot", "INV_Misc_Desecrated_ClothBelt"}, {"LegsSlot", "INV_Misc_Desecrated_ClothPants"}, {"FeetSlot", "INV_Misc_Desecrated_ClothBoots"}, {"MainHandSlot", "INV_Sword_01"}, {"SecondaryHandSlot", "INV_Shield_01"}}

				-- The appearance the model shows in a slot (nil if none, or if the game is hiding it)
				local function ModelAppearance(actor, slotID)
					local ok, transmog = pcall(actor.GetItemTransmogInfo, actor, slotID)
					if not ok or type(transmog) ~= "table" then return end
					local appearanceID = Safe(transmog.appearanceID)
					if type(appearanceID) == "number" and appearanceID > 0 then return transmog end
				end

				-- Put an appearance on the model (weapons go straight into their own hand, so a dual wielder keeps both)
				local function DressSlot(slotID)
					local actor, transmog = GetActor(), slotInfo[slotID]
					if not actor or not transmog then return end
					pcall(actor.SetItemTransmogInfo, actor, transmog, slotID, slotID ~= INVSLOT_MAINHAND)
				end

				-- Show each button as worn, taken off or empty
				local function UpdateSlots()
					for void, button in ipairs(buttons) do
						local transmog = slotInfo[button.slotID]
						local hidden = hiddenSlots[button.slotID]
						button.link = nil
						if transmog then
							local appearanceID = transmog.appearanceID
							if C_TransmogCollection.IsAppearanceHiddenVisual(appearanceID) then
								button.t:SetAtlas("transmog-icon-hidden")
							else
								local source = C_TransmogCollection.GetAppearanceSourceInfo(appearanceID)
								button.t:SetTexture(source and source.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
								button.link = source and source.itemLink
							end
						else
							button.t:SetTexture(button.emptyTexture)
						end
						button.t:SetDesaturated(hidden and true or false)
						button.t:SetAlpha(hidden and 0.45 or 1)
					end
					-- All items button: in colour with a red cross while anything is showing, grey once everything is off
					if nudeBtn then
						local anyShown = DressupGear.AnyShown()
						nudeBtn.t:SetDesaturated(not anyShown)
						nudeBtn.t:SetAlpha(anyShown and 1 or 0.45)
						nudeBtn.badge:SetShown(anyShown)
					end
				end

				-- Read what the model is wearing (slots taken off with the buttons stay taken off until something is put in them)
				local function Refresh()
					local actor = GetActor()
					if not actor then return end
					for void, slotID in ipairs(slotOrder) do
						local transmog = ModelAppearance(actor, slotID)
						if transmog then
							slotInfo[slotID] = transmog
							hiddenSlots[slotID] = nil
						elseif not hiddenSlots[slotID] then
							slotInfo[slotID] = nil
						end
					end
					UpdateSlots()
				end
				DressupGear.Refresh = Refresh

				-- Start again (the model has been reset or shows someone else)
				local function Reset(newMode)
					wipe(slotInfo) wipe(hiddenSlots) wipe(nudeSaved)
					SetMode(newMode)
					Refresh()
				end
				DressupGear.Reset = Reset

				-- Follow the model while the dressing room is open: a new model (opened or reset) starts again, and anything put on or taken off
				-- (such as an item tried on with Ctrl-click) shows on the buttons
				-- This is a light check a few times a second, rather than hooking the dressing room's own functions: on retail, a function hooked
				-- with hooksecurefunc can read as missing while the taint log is on, which breaks the dressing room itself
				local lastActor, ticker
				local function Check()
					local actor = GetActor()
					if actor ~= lastActor then
						lastActor = actor
						if actor then Reset("me") end
					elseif actor then
						Refresh()
					end
				end
				DressUpFrame:HookScript("OnShow", function()
					if ticker then ticker:Cancel() end
					lastActor = nil
					ticker = C_Timer.NewTicker(0.2, Check)
					Check()
				end)
				DressUpFrame:HookScript("OnHide", function()
					if ticker then ticker:Cancel() ticker = nil end
				end)

				-- The model changes when the dressing room shows me or the target (so it does not count as the dressing room being reset)
				function DressupGear.NoteActor() lastActor = GetActor() end

				----------------------------------------------------------------------
				-- Slot buttons
				----------------------------------------------------------------------

				local function SlotTip(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					if not (self.link and pcall(GameTooltip.SetHyperlink, GameTooltip, self.link)) then
						GameTooltip:SetText(self.label, 1, 1, 1)
					end
					if not slotInfo[self.slotID] then
						GameTooltip:AddLine(L["Nothing to show in this slot"], 0.6, 0.6, 0.65)
					elseif hiddenSlots[self.slotID] then
						GameTooltip:AddLine(L["Click to show"], 0.6, 0.6, 0.65)
					else
						GameTooltip:AddLine(L["Click to hide"], 0.6, 0.6, 0.65)
					end
					GameTooltip:Show()
				end

				-- A column for each set of slot buttons (down each side of the model, like the character sheet)
				-- The columns are inside the reset button, so they only show when the dressing room shows a character (not a mount or pet)
				local columns = {}
				local step = 33 -- Distance from one slot button to the next (the same spacing as the character sheet, scaled to these smaller buttons)
				local function MakeColumn(anchor, x, y)
					local column = CreateFrame("Frame", nil, DressUpFrameResetButton)
					column:SetFrameStrata("HIGH")
					column:SetPoint(anchor, DressUpFrame, anchor, x, y)
					column:SetWidth(38)
					column.count = 0
					tinsert(columns, column)
					return column
				end
				local leftColumn = MakeColumn("TOPLEFT", 8, -64)
				local rightColumn = MakeColumn("TOPRIGHT", -10, -64)

				-- The frame each slot sits in on the character sheet (with a tab towards the model), if this game has it
				local slotFrameFile = "Interface\\CharacterFrame\\Char-Paperdoll-Parts"
				local hasSlotFrames = GetFileIDFromPath and GetFileIDFromPath(slotFrameFile) and true or false
				local function AddSlotFrame(btn, column)
					if not hasSlotFrames then return end
					local frame = column:CreateTexture(nil, "BACKGROUND") -- On the column, so it is always behind every slot button
					frame:SetTexture(slotFrameFile)
					local scale = btn:GetWidth() / 37 -- The character sheet slots are 37 wide
					if column == leftColumn then
						frame:SetTexCoord(0.20703125, 0.39843750, 0.59375000, 0.93750000)
						frame:SetSize(49 * scale, 44 * scale)
						frame:SetPoint("TOPLEFT", btn, "TOPLEFT", -4 * scale, 0)
					else
						frame:SetTexCoord(0.00390625, 0.19921875, 0.59375000, 0.93750000)
						frame:SetSize(50 * scale, 44 * scale)
						frame:SetPoint("TOPRIGHT", btn, "TOPRIGHT", 4 * scale, 0)
					end
				end

				local function MakeSlotButton(entry, column)

					-- Slots this game does not have are left out
					local slotName, fallbackIcon = entry[1], entry[2]
					local ok, slotID, emptyTexture = pcall(C_PaperDollInfo.GetInventorySlotInfo, slotName)
					if not ok or not slotID then return end

					-- Create slot button
					local slotBtn = CreateFrame("Button", nil, column)
					slotBtn:SetFrameLevel(column:GetFrameLevel() + 2)
					PaperDollButton(slotBtn, 30)
					AddSlotFrame(slotBtn, column)
					slotBtn.slotID = slotID
					slotBtn.label = _G[strupper(slotName)] or slotName
					slotBtn.emptyTexture = emptyTexture or ("Interface\\Icons\\" .. fallbackIcon)
					slotBtn:SetPoint("TOP", column, "TOP", 0, -4 - step * column.count)
					column.count = column.count + 1
					column:SetHeight(8 + step * column.count - (step - 30))
					slotBtn:RegisterForClicks("LeftButtonUp")
					slotBtn:SetMotionScriptsWhileDisabled(true)

					-- Slot button click: take the item off, click again to put it back on
					slotBtn:SetScript("OnClick", function(self)
						local slot = self.slotID
						if not slotInfo[slot] then return end
						if hiddenSlots[slot] then
							hiddenSlots[slot] = nil
							DressSlot(slot)
						else
							hiddenSlots[slot] = true
							local actor = GetActor()
							if actor then pcall(actor.UndressSlot, actor, slot) end
						end
						UpdateSlots()
						if GameTooltip:IsOwned(self) then SlotTip(self) end
					end)

					-- Slot button tooltip
					slotBtn:SetScript("OnEnter", SlotTip)
					slotBtn:SetScript("OnLeave", GameTooltip_Hide)

					-- Add slot button to table
					tinsert(buttons, slotBtn)
					tinsert(slotOrder, slotID)

				end

				-- Show left column slot buttons
				for i, entry in ipairs(leftSlots) do
					MakeSlotButton(entry, leftColumn)
				end

				-- Show right column slot buttons
				for i, entry in ipairs(rightSlots) do
					MakeSlotButton(entry, rightColumn)
				end

				-- All items button (nude) at the bottom of the left column
				do
					local column = leftColumn
					nudeBtn = CreateFrame("Button", nil, column)
					nudeBtn:SetFrameLevel(column:GetFrameLevel() + 2)
					PaperDollButton(nudeBtn, 30)
					AddSlotFrame(nudeBtn, column)
					nudeBtn:SetPoint("TOP", column, "TOP", 0, -4 - step * column.count)
					column.count = column.count + 1
					column:SetHeight(8 + step * column.count - (step - 30))
					nudeBtn.t:SetTexture("Interface\\Icons\\INV_Shirt_01")

					-- Red cross in the corner while anything is on (click to take it all off)
					nudeBtn.badge = nudeBtn:CreateTexture(nil, "OVERLAY", nil, 2)
					nudeBtn.badge:SetSize(14, 14)
					nudeBtn.badge:SetPoint("BOTTOMRIGHT", nudeBtn, "BOTTOMRIGHT", 1, -1)
					nudeBtn.badge:SetAtlas("common-icon-redx")

					local function NudeTip(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:SetText(L["All items"], 1, 1, 1)
						if DressupGear.AnyShown() then
							GameTooltip:AddLine(L["Click to remove all items"], 0.6, 0.6, 0.65)
						else
							GameTooltip:AddLine(L["Click to put all items back on"], 0.6, 0.6, 0.65)
						end
						GameTooltip:Show()
					end
					nudeBtn:RegisterForClicks("LeftButtonUp")
					nudeBtn:SetScript("OnEnter", NudeTip)
					nudeBtn:SetScript("OnLeave", GameTooltip_Hide)
					nudeBtn:SetScript("OnClick", function(self)
						DressupGear.ToggleNude()
						if GameTooltip:IsOwned(self) then NudeTip(self) end
					end)
				end

				----------------------------------------------------------------------
				-- Nude (used by the nude button)
				----------------------------------------------------------------------

				-- Is anything still showing (true when nothing is known about the gear, so nude always takes everything off)
				function DressupGear.AnyShown()
					if not next(slotInfo) then return true end
					for slotID in pairs(slotInfo) do
						if not hiddenSlots[slotID] then return true end
					end
					return false
				end

				-- Take everything off, click again to put back on what was showing before
				function DressupGear.ToggleNude()
					local actor = GetActor()
					if not actor then return end
					if DressupGear.AnyShown() then
						wipe(nudeSaved)
						for slotID in pairs(slotInfo) do
							if not hiddenSlots[slotID] then nudeSaved[slotID] = true; hiddenSlots[slotID] = true end
						end
						pcall(actor.Undress, actor)
					else
						local all = not next(nudeSaved) -- Nothing remembered, so put everything back on
						for void, slotID in ipairs(slotOrder) do
							if slotInfo[slotID] and (all or nudeSaved[slotID]) then
								hiddenSlots[slotID] = nil
								DressSlot(slotID)
							end
						end
						wipe(nudeSaved)
					end
					UpdateSlots()
				end

				----------------------------------------------------------------------
				-- Outfits (my outfit on target, target outfit on me)
				----------------------------------------------------------------------

				-- Put a list of appearances on the model (in their own slots, so a dual wielder keeps both weapons)
				local function ApplyList(actor, list)
					for slotID, transmog in ipairs(list) do
						local appearanceID = type(transmog) == "table" and Safe(transmog.appearanceID)
						if type(appearanceID) == "number" and appearanceID > 0 then
							pcall(actor.SetItemTransmogInfo, actor, transmog, slotID, slotID ~= INVSLOT_MAINHAND)
						end
					end
				end

				-- Read the appearances a model is wearing (nil if the game is hiding them)
				local function ReadList(actor)
					local ok, list = pcall(actor.GetItemTransmogInfoList, actor)
					if not ok or type(list) ~= "table" then return end
					if (issecretvalue and issecretvalue(list)) or (canaccesstable and not canaccesstable(list)) then return end
					return list
				end

				-- Show my outfit on the target
				function DressupGear.MyOutfitOnTarget()
					local actor = GetActor()
					if not actor or not Safe(UnitIsPlayer("target")) then return end
					actor:SetModelByUnit("player", true, true)
					local list = ReadList(actor)
					actor:SetModelByUnit("target", true, true)
					C_Timer.After(0.01, function()
						actor = GetActor()
						if not actor or not Safe(UnitIsPlayer("target")) then return end
						actor:SetModelByUnit("target", true, true)
						if list then
							actor:Undress()
							ApplyList(actor, list)
						else
							DressupGear.Message(L["Their gear could not be read."])
						end
						Reset("myOutfitOnTarget")
						DressupGear.NoteActor()
						C_Timer.After(0.2, Refresh)
					end)
				end

				-- Show the target's outfit on me
				function DressupGear.TargetOutfitOnMe()
					local actor = GetActor()
					if not actor or not Safe(UnitIsPlayer("target")) then return end
					actor:SetModelByUnit("target", true, true)
					C_Timer.After(0.01, function()
						actor = GetActor()
						if not actor then return end
						local list = ReadList(actor)
						actor:SetModelByUnit("player", true, true)
						if list then
							actor:Undress()
							ApplyList(actor, list)
						else
							DressupGear.Message(L["Their gear could not be read."])
						end
						Reset("targetOutfitOnMe")
						DressupGear.NoteActor()
						C_Timer.After(0.2, Refresh)
					end)
				end

				-- Show me or the target
				function DressupGear.ShowUnit(unit, newMode)
					local actor = GetActor()
					if not actor then return end
					actor:SetModelByUnit(unit, true, true)
					C_Timer.After(0.1, function()
						actor = GetActor()
						if not actor then return end
						actor:SetModelByUnit(unit, true, true)
						Reset(newMode)
						DressupGear.NoteActor()
						C_Timer.After(0.2, Refresh)
					end)
				end

				-- The unit shown in the dressing room (nil if it cannot be found any more)
				function DressupGear.GetUnit()
					if mode == "target" or mode == "myOutfitOnTarget" then
						if Safe(UnitIsPlayer("target")) then return "target" end
						return
					end
					return "player"
				end

				-- Function to set item buttons
				local function ToggleItemButtons()
					-- The buttons are inside the columns, so showing or hiding the columns does the buttons too
					for i = 1, #columns do columns[i]:SetShown(LeaPlusLC["DressupItemButtons"] == "On" and columns[i].count > 0) end
				end

				-- Assign file level scope to function
				LeaPlusLC.ToggleItemButtons = ToggleItemButtons

				-- Set item buttons for option click, startup, reset click and preset click
				LeaPlusCB["DressupItemButtons"]:HookScript("OnClick", ToggleItemButtons)
				ToggleItemButtons()
				DressupPanel.r:HookScript("OnClick", function()
					LeaPlusLC["DressupItemButtons"] = "On"
					ToggleItemButtons()
					DressupPanel:Hide(); DressupPanel:Show()
				end)
				LeaPlusCB["EnhanceDressupBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						LeaPlusLC["DressupItemButtons"] = "On"
						ToggleItemButtons()
					end
				end)

				UpdateSlots()

			end

			----------------------------------------------------------------------
			-- Animation slider (must be before bottom row buttons)
			----------------------------------------------------------------------

			local animTable = {0, 4, 5, 143, 119, 26, 25, 27, 28, 108, 120, 51, 124, 52, 125, 126, 62, 63, 41, 42, 43, 44, 132, 38, 14, 115, 193, 48, 110, 109, 134, 197, 0}
			local lastSetting

			LeaPlusLC["DressupAnim"] = 0 -- Defined here since the setting is not saved
			LeaPlusLC:MakeSL(DressUpFrame, "DressupAnim", "", 1, #animTable - 1, 1, 356, -92, "%.0f")
			LeaPlusCB["DressupAnim"]:ClearAllPoints()
			LeaPlusCB["DressupAnim"]:SetPoint("BOTTOM", 20, 44) -- Above the bottom bar (the title goes to the left of it and the number to the right)
			LeaPlusCB["DressupAnim"]:SetParent(DressUpFrameResetButton) -- So it only shows with reset button
			LeaPlusCB["DressupAnim"]:SetWidth(150)
			LeaPlusCB["DressupAnim"]:SetFrameLevel(DressUpFrame.ModelScene:GetFrameLevel() + 5)
			LeaPlusCB["DressupAnim"]:HookScript("OnValueChanged", function(self, setting)
				local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
				setting = math.floor(setting + 0.5)
				if playerActor and setting ~= lastSetting then
					lastSetting = setting
					playerActor:SetAnimation(animTable[setting], 0, 1, 1)
					-- print(animTable[setting]) -- Debug
				end
			end)

			-- Title for the slider (part of the slider, so it hides with it)
			local animTitle = LeaPlusCB["DressupAnim"]:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			animTitle:SetPoint("RIGHT", LeaPlusCB["DressupAnim"], "LEFT", -8, 0)
			animTitle:SetText(L["Animation"])

			-- Function to show animation control
			local function SetAnimationSlider()
				if LeaPlusLC["DressupAnimControl"] == "On" then
					LeaPlusCB["DressupAnim"]:Show()
				else
					LeaPlusCB["DressupAnim"]:Hide()
				end
				LeaPlusCB["DressupAnim"]:SetValue(1)
			end

			-- Set animation control with option, startup, preset and reset
			LeaPlusCB["DressupAnimControl"]:HookScript("OnClick", SetAnimationSlider)
			SetAnimationSlider()
			LeaPlusCB["EnhanceDressupBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					LeaPlusLC["DressupAnimControl"] = "On"
					SetAnimationSlider()
				end
			end)
			DressupPanel.r:HookScript("OnClick", function()
				LeaPlusLC["DressupAnimControl"] = "On"
				SetAnimationSlider()
				DressupPanel:Hide(); DressupPanel:Show()
			end)

			-- Reset animation when dressup frame is shown and model is reset
			DressUpFrame:HookScript("OnShow", SetAnimationSlider)
			DressUpFrameResetButton:HookScript("OnClick", SetAnimationSlider)

			-- Skin slider for ElvUI
			if LeaPlusLC.ElvUI then
				_G.LeaPlusGlobalDressupAnim = LeaPlusCB["DressupAnim"]
				LeaPlusLC.ElvUI:GetModule("Skins"):HandleSliderFrame(_G.LeaPlusGlobalDressupAnim, false)
			end

			----------------------------------------------------------------------
			-- Bottom row buttons
			----------------------------------------------------------------------

			-- Function to modify a button tooltip
			local function SetButton(where, tip)
				where:HookScript("OnEnter", function()
					GameTooltip:SetOwner(where, "ANCHOR_NONE")
					GameTooltip:SetPoint("BOTTOM", where, "TOP", 0, 10)
					GameTooltip:SetText(L[tip], nil, nil, nil, nil, true)
				end)
				where:HookScript("OnLeave", GameTooltip_Hide)
			end

			SetButton(DressUpFrameCancelButton, "Close")
			SetButton(DressUpFrameResetButton, "Reset")
			SetButton(DressUpFrame.LinkButton, "Link outfit")

			-- Function to set the animation again after the model has changed
			local function ResetAnimation()
				C_Timer.After(0.2, function()
					local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
					if not playerActor then return end
					playerActor:SetAnimation(0)
					C_Timer.After(0.1, function()
						playerActor:SetAnimation(animTable[math.floor(LeaPlusCB["DressupAnim"]:GetValue() + 0.5)], 0, 1, 1)
					end)
				end)
			end

			-- Bottom bar: picture buttons in the same style as the slot buttons, then Reset and Close
			-- The bar is inside the reset button, so it only shows when the dressing room shows a character (not a mount or pet)
			local size, gap = 30, 6
			local mePics, targetPics, shades = {}, {}, {}
			local barLevel = DressUpFrame.ModelScene:GetFrameLevel() + 5 -- Above the model

			-- Grey out a button's pictures when it is disabled
			local function Shade(btn)
				local on = btn:IsEnabled()
				for void, pic in ipairs({btn.t, btn.badge}) do
					pic:SetDesaturated(not on)
					pic:SetAlpha(on and 1 or 0.45)
				end
			end

			-- Create a bar button (title and optional text for the tooltip, isMode for buttons that stay lit while the model shows that)
			local barCount = 0
			local function MakeBarButton(title, text, isMode)
				local btn = CreateFrame(isMode and "CheckButton" or "Button", nil, DressUpFrameResetButton)
				PaperDollButton(btn, size)
				if isMode then
					btn:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
					btn:GetCheckedTexture():SetBlendMode("ADD")
				end
				btn:SetFrameLevel(barLevel)
				btn:SetPoint("BOTTOMLEFT", DressUpFrame, "BOTTOMLEFT", 12 + barCount * (size + gap), 7)
				barCount = barCount + 1
				btn:SetMotionScriptsWhileDisabled(true) -- Tooltip shows while greyed out
				btn:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_NONE")
					GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
					GameTooltip:SetText(L[title], 1, 1, 1)
					if text then GameTooltip:AddLine(L[text], nil, nil, nil, true) end
					if self.why and not self:IsEnabled() then GameTooltip:AddLine(self.why, 1, 0.3, 0.3, true) end
					GameTooltip:Show()
				end)
				btn:SetScript("OnLeave", GameTooltip_Hide)
				-- Small round picture in the corner (whose gear is being worn)
				btn.badge = btn:CreateTexture(nil, "OVERLAY", nil, 2)
				btn.badge:SetSize(15, 15)
				btn.badge:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 3, -3)
				btn.badge:Hide()
				btn:SetScript("OnEnable", Shade)
				btn:SetScript("OnDisable", Shade)
				tinsert(shades, btn)
				return btn
			end

			-- Make a picture round (portraits)
			local circle = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
			local function MakeRound(btn, pic)
				local mask = btn:CreateMaskTexture()
				mask:SetTexture(circle, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
				mask:SetAllPoints(pic)
				pic:AddMaskTexture(mask)
			end

			-- Show a small portrait in the corner of a button (with a dark ring so it stands apart from the big picture)
			local function AddBadge(btn, list)
				local ring = btn:CreateTexture(nil, "OVERLAY", nil, 1)
				ring:SetTexture(circle)
				ring:SetVertexColor(0, 0, 0, 1)
				ring:SetSize(18, 18)
				ring:SetPoint("CENTER", btn.badge, "CENTER")
				MakeRound(btn, btn.badge)
				btn.badge:Show()
				tinsert(list, btn.badge)
			end

			-- Link: Blizzard's own button, given the same look (see below), so it comes first in the bar
			barCount = 1

			local meBtn = MakeBarButton("Show me", nil, true)
			tinsert(mePics, meBtn.t)

			local targetBtn = MakeBarButton("Show target", nil, true)
			tinsert(targetPics, targetBtn.t)

			local myGearBtn = MakeBarButton("Show my gear on target", nil, true)
			tinsert(targetPics, myGearBtn.t)
			AddBadge(myGearBtn, mePics)

			local theirGearBtn = MakeBarButton("Show target gear on me", nil, true)
			tinsert(mePics, theirGearBtn.t)
			AddBadge(theirGearBtn, targetPics)

			local infoBtn = MakeBarButton("Show info card", nil, false)
			infoBtn.t:SetTexture("Interface\\Icons\\INV_Misc_Note_02")

			-- Link, Reset and Close, given the same look as the other buttons
			-- These are Blizzard's own buttons, so they are only re-skinned (their red art is made see-through and pictures are laid
			-- over it): clicking them still runs Blizzard's own code (the link menu, including copying to the clipboard, stays Blizzard's),
			-- nothing is replaced and nothing is written onto them
			local skinParts = {}
			local function SkinBlizzardButton(btn, file, picSize, isAtlas)
				btn:SetText("")
				btn:SetSize(size, size)
				for void, region in ipairs({btn:GetRegions()}) do
					if region:IsObjectType("Texture") then region:SetAlpha(0) end -- Stays see-through when the game changes the art (pressed, disabled)
				end
				local parts = {}
				parts.bg = btn:CreateTexture(nil, "BACKGROUND", nil, 7)
				parts.bg:SetAllPoints()
				parts.bg:SetColorTexture(0, 0, 0, 0.7)
				parts.pic = btn:CreateTexture(nil, "BORDER")
				parts.pic:SetSize(picSize, picSize)
				parts.pic:SetPoint("CENTER")
				if isAtlas then parts.pic:SetAtlas(file) else parts.pic:SetTexture(file) end
				parts.border = btn:CreateTexture(nil, "ARTWORK")
				parts.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
				parts.border:SetSize(size * 64 / 37, size * 64 / 37)
				parts.border:SetPoint("CENTER", 0, -size / 37)
				parts.pushed = btn:CreateTexture(nil, "OVERLAY")
				parts.pushed:SetAllPoints()
				parts.pushed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
				parts.pushed:Hide()
				parts.glow = btn:CreateTexture(nil, "OVERLAY")
				parts.glow:SetAllPoints()
				parts.glow:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
				parts.glow:SetBlendMode("ADD")
				parts.glow:Hide()
				skinParts[btn] = parts
				btn:HookScript("OnEnter", function() parts.glow:Show() end)
				btn:HookScript("OnLeave", function() parts.glow:Hide() parts.pushed:Hide() end)
				btn:HookScript("OnMouseDown", function(self) if self:IsEnabled() then parts.pushed:Show() end end)
				btn:HookScript("OnMouseUp", function() parts.pushed:Hide() end)
				btn:SetFrameLevel(barLevel)
			end

			-- Link: a chain link (first in the bar)
			SkinBlizzardButton(DressUpFrame.LinkButton, "Interface\\Buttons\\UI-LinkProfession-Up", 22)
			DressUpFrame.LinkButton:ClearAllPoints()
			DressUpFrame.LinkButton:SetPoint("BOTTOMLEFT", DressUpFrame, "BOTTOMLEFT", 12, 7)

			-- Close: a red cross
			SkinBlizzardButton(DressUpFrameCancelButton, "common-icon-redx", 18, true)
			DressUpFrameCancelButton:ClearAllPoints()
			DressUpFrameCancelButton:SetPoint("BOTTOMRIGHT", DressUpFrame, "BOTTOMRIGHT", -12, 7)

			-- Reset: a circular arrow
			SkinBlizzardButton(DressUpFrameResetButton, "Interface\\Buttons\\UI-RefreshButton", 20)
			DressUpFrameResetButton:ClearAllPoints()
			DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -gap, 0)

			-- Grey background behind the bottom bar (the frame's own grey, raised to cover the bottom of the model area, as the bar
			-- buttons are taller than Blizzard's own buttons and the edge of the model area would otherwise run through them)
			do
				local barBg = CreateFrame("Frame", nil, DressUpFrameResetButton) -- Inside the reset button like the bar buttons, so it hides with them
				barBg:SetFrameLevel(barLevel - 1) -- Above the model, below the buttons
				barBg:SetPoint("LEFT", DressUpFrame.Inset or DressUpFrame, "LEFT", DressUpFrame.Inset and 0 or 4, 0)
				barBg:SetPoint("RIGHT", DressUpFrame.Inset or DressUpFrame, "RIGHT", DressUpFrame.Inset and 0 or -4, 0)
				barBg:SetPoint("BOTTOM", DressUpFrame, "BOTTOM", 0, 3)
				barBg:SetPoint("TOP", meBtn, "TOP", 0, 4)
				local tex = barBg:CreateTexture(nil, "BACKGROUND")
				tex:SetAllPoints()
				local frameBg = DressUpFrame.Bg
				local atlas = frameBg and frameBg.GetAtlas and frameBg:GetAtlas()
				if atlas then
					tex:SetAtlas(atlas)
					tex:SetHorizTile(frameBg:GetHorizTile())
					tex:SetVertTile(frameBg:GetVertTile())
				elseif frameBg and frameBg:GetTexture() then
					tex:SetTexture(frameBg:GetTexture(), frameBg:GetHorizTile() and "REPEAT" or nil, frameBg:GetVertTile() and "REPEAT" or nil)
					tex:SetHorizTile(frameBg:GetHorizTile())
					tex:SetVertTile(frameBg:GetVertTile())
				else
					tex:SetColorTexture(0.1, 0.1, 0.1, 1)
				end
				if frameBg then tex:SetVertexColor(frameBg:GetVertexColor()) end

				-- Border line along the top of the grey, copied from the bottom border of the model area (the inset), so it looks the
				-- same as the default line (the pieces keep their own positions, moved from the bottom of the inset to the top of the grey)
				local inset = DressUpFrame.Inset
				local source = inset and inset.NineSlice
				local keys = {"BottomLeftCorner", "BottomEdge", "BottomRightCorner"}
				if not (source and source.BottomEdge) then
					source = inset
					keys = {"InsetBorderBottomLeft", "InsetBorderBottom", "InsetBorderBottomRight"}
				end
				local copies = {}
				for void, key in ipairs(keys) do
					local piece = source and source[key]
					if piece and piece.GetTexture then
						local t = barBg:CreateTexture(nil, "BORDER")
						local pieceAtlas = piece.GetAtlas and piece:GetAtlas()
						if pieceAtlas then
							t:SetAtlas(pieceAtlas)
						else
							t:SetTexture(piece:GetTexture())
							t:SetTexCoord(piece:GetTexCoord())
						end
						t:SetHorizTile(piece:GetHorizTile())
						t:SetVertTile(piece:GetVertTile())
						t:SetVertexColor(piece:GetVertexColor())
						t:SetSize(piece:GetSize())
						copies[piece] = t
					end
				end
				if next(copies) then
					for piece, t in pairs(copies) do
						for i = 1, piece:GetNumPoints() do
							local point, relativeTo, relativePoint, x, y = piece:GetPoint(i)
							if copies[relativeTo] then
								-- Anchored to another piece, so anchor to its copy
								t:SetPoint(point, copies[relativeTo], relativePoint, x, y)
							else
								-- Anchored to the inset, so anchor to the top of the grey instead of the bottom of the inset
								t:SetPoint(point, barBg, (gsub(relativePoint, "BOTTOM", "TOP")), x, y)
							end
						end
					end
				else
					-- No border pieces found, so draw a plain line
					local line = barBg:CreateTexture(nil, "BORDER")
					line:SetColorTexture(0.35, 0.35, 0.35, 1)
					line:SetPoint("TOPLEFT"); line:SetPoint("TOPRIGHT")
					line:SetHeight(2)
				end
			end

			-- Update the buttons: pictures, greyed out ones and the one for what the model shows
			local modeButtons = {me = meBtn, target = targetBtn, myOutfitOnTarget = myGearBtn, targetOutfitOnMe = theirGearBtn}
			local function UpdateButtons()
				local hasTarget = Safe(UnitIsPlayer("target")) and true or false
				for void, pic in ipairs(mePics) do SetPortraitTexture(pic, "player") end
				for void, pic in ipairs(targetPics) do
					if hasTarget then SetPortraitTexture(pic, "target") else pic:SetTexture("Interface\\CharacterFrame\\TempPortrait") end
				end
				for void, btn in ipairs({targetBtn, myGearBtn, theirGearBtn}) do
					btn:SetEnabled(hasTarget)
					btn.why = L["Target a player to use this."]
				end
				infoBtn:SetEnabled(LeaPlusLC.ShowInfoCardForUnit ~= nil)
				if LeaPlusLC["ShowInfoCards"] == "On" then
					infoBtn.why = L["Reload your UI to use this."]
				else
					infoBtn.why = L["This needs Show info cards to be turned on in Leatrix Plus."]
				end
				local mode = DressupGear.GetMode()
				for key, btn in pairs(modeButtons) do btn:SetChecked(key == mode) end
				for void, btn in ipairs(shades) do Shade(btn) end
			end
			DressupGear.OnModeChanged = UpdateButtons

			-- Clicks (each then shows what the model really shows, as clicking a check button would otherwise flip it)
			meBtn:SetScript("OnClick", function()
				DressupGear.ShowUnit("player", "me")
				ResetAnimation()
				UpdateButtons()
			end)
			targetBtn:SetScript("OnClick", function()
				if Safe(UnitIsPlayer("target")) then
					DressupGear.ShowUnit("target", "target")
					ResetAnimation()
				end
				UpdateButtons()
			end)
			myGearBtn:SetScript("OnClick", function()
				DressupGear.MyOutfitOnTarget()
				ResetAnimation()
				UpdateButtons()
			end)
			theirGearBtn:SetScript("OnClick", function()
				DressupGear.TargetOutfitOnMe()
				ResetAnimation()
				UpdateButtons()
			end)
			infoBtn:SetScript("OnClick", function()
				if not LeaPlusLC.ShowInfoCardForUnit then return end
				local unit = DressupGear.GetUnit()
				if unit then
					LeaPlusLC.ShowInfoCardForUnit(unit)
				else
					DressupGear.Message(L["Target that player to show their info card."])
				end
			end)

			-- Only watch the target while the dressing room is open
			local watcher = CreateFrame("Frame")
			watcher:SetScript("OnEvent", UpdateButtons)
			DressUpFrame:HookScript("OnShow", function()
				watcher:RegisterEvent("PLAYER_TARGET_CHANGED")
				watcher:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player", "target")
				UpdateButtons()
			end)
			DressUpFrame:HookScript("OnHide", function() watcher:UnregisterAllEvents() end)
			UpdateButtons()

			-- Change player actor to player when reset button is clicked (needed because target button changes it)
			DressUpFrameResetButton:HookScript("OnClick", function()
				local playerActor = DressUpFrame.ModelScene:GetPlayerActor()
				if playerActor then playerActor:SetModelByUnit("player", true, true) end
				-- Start the slot buttons again (the game can reuse the same model, so the light check may not see the reset)
				C_Timer.After(0.1, function() DressupGear.Reset("me") DressupGear.NoteActor() end)
			end)

			----------------------------------------------------------------------
			-- Controls
			----------------------------------------------------------------------

			-- Hide controls for character frame
			CharacterModelScene.ControlFrame:HookScript("OnShow", function()
				CharacterModelScene.ControlFrame:Hide()
			end)

			-- Hide controls for dressing room
			DressUpFrame.ModelScene.ControlFrame:HookScript("OnShow", DressUpFrame.ModelScene.ControlFrame.Hide)

			-- Hide controls for shop
			ModelPreviewFrame.Display.ModelScene.ControlFrame:HookScript("OnShow", function()
				if StorePreviewFrame and StorePreviewFrame:IsShown() then
					ModelPreviewFrame.Display.ModelScene.ControlFrame:Hide()
				end
			end)

			-- Hide controls for mount journal
			EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections",function()
				MountJournal.MountDisplay.ModelScene.ControlFrame:HookScript("OnShow", function()
					MountJournal.MountDisplay.ModelScene.ControlFrame:Hide()
				end)
			end)

			-- Hide controls for housing dashboard
			EventUtil.ContinueOnAddOnLoaded("Blizzard_HousingDashboard", function()
				HousingDashboardFrame.CatalogContent.PreviewFrame.ModelSceneControls:HookScript("OnShow", function()
					HousingDashboardFrame.CatalogContent.PreviewFrame.ModelSceneControls:Hide()
				end)
			end)

			----------------------------------------------------------------------
			-- Wardrobe and inspect system
			----------------------------------------------------------------------

			-- Set zoom speed for mount and pet journal
			EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections",function()

				-- Set zoom speed for mount journal
				MountJournal.MountDisplay.ModelScene:SetScript("OnMouseWheel", function(self, delta)
					for i = 1, LeaPlusLC["DressupFasterZoom"] do
						if MountJournal.MountDisplay.ModelScene.activeCamera then
							MountJournal.MountDisplay.ModelScene.activeCamera:OnMouseWheel(delta)
						end
					end
				end)

				-- Set zoom speed for pet journal
				PetJournalPetCard.modelScene:SetScript("OnMouseWheel", function(self, delta)
					for i = 1, LeaPlusLC["DressupFasterZoom"] do
						if PetJournalPetCard.modelScene.activeCamera then
							PetJournalPetCard.modelScene.activeCamera:OnMouseWheel(delta)
						end
					end
				end)

			end)

			EventUtil.ContinueOnAddOnLoaded("Blizzard_Transmog",function()

				-- Hide positioning controls for wardrobe
				TransmogFrame.CharacterPreview.ModelScene.ControlFrame:HookScript("OnShow", TransmogFrame.CharacterPreview.ModelScene.ControlFrame.Hide)

				-- Set zoom speed for wardrobe
				TransmogFrame.CharacterPreview.ModelScene:SetScript("OnMouseWheel", function(self, delta)
					for i = 1, LeaPlusLC["DressupFasterZoom"] do
						if TransmogFrame.CharacterPreview.ModelScene.activeCamera then
							TransmogFrame.CharacterPreview.ModelScene.activeCamera:OnMouseWheel(delta)
						end
					end
				end)

				-- Increase zoom out distance
				if LeaPlusLC["DressupMoreZoomOut"] == "On" then
					hooksecurefunc(TransmogFrame.CharacterPreview.ModelScene, "TransitionToModelSceneID", function(self)
						local activeCamera = self:GetActiveCamera()
						if activeCamera then
							local currentZoom = activeCamera:GetZoomDistance()
							activeCamera:SetMaxZoomDistance(5)
							activeCamera:SetZoomDistance(currentZoom)
						end
					end)
				end

				----------------------------------------------------------------------
				-- Transmogrify animation slider
				----------------------------------------------------------------------

				do

					local transmogAnimTable = {0, 4, 5, 143, 119, 26, 25, 27, 28, 108, 120, 51, 124, 52, 125, 126, 62, 63, 41, 42, 43, 44, 132, 38, 14, 115, 193, 48, 110, 109, 134, 197, 0}
					local transmogLastSetting

					LeaPlusLC["TransmogAnim"] = 0 -- Defined here since the setting is not saved
					LeaPlusLC:MakeSL(TransmogFrame, "TransmogAnim", "", 1, #transmogAnimTable - 1, 1, 356, -92, "%.0f")
					LeaPlusCB["TransmogAnim"]:ClearAllPoints()
					LeaPlusCB["TransmogAnim"]:SetPoint("BOTTOM", 0, 6)
					LeaPlusCB["TransmogAnim"]:SetWidth(216)
					LeaPlusCB["TransmogAnim"]:SetFrameLevel(5)
					LeaPlusCB["TransmogAnim"]:HookScript("OnValueChanged", function(self, setting)
						local playerActor = TransmogFrame.CharacterPreview.ModelScene:GetPlayerActor()
						setting = math.floor(setting + 0.5)
						if playerActor and setting ~= lastSetting then
							lastSetting = setting
							playerActor:SetAnimation(transmogAnimTable[setting], 0, 1, 1)
						end
					end)

					-- Function to show animation control
					local function SetAnimationSlider()
						if LeaPlusLC["DressupTransmogAnim"] == "On" then
							LeaPlusCB["TransmogAnim"]:Show()
						else
							LeaPlusCB["TransmogAnim"]:Hide()
						end
						LeaPlusCB["TransmogAnim"]:SetValue(1)
					end

					-- Set animation control with option, startup, preset and reset
					LeaPlusCB["DressupTransmogAnim"]:HookScript("OnClick", SetAnimationSlider)
					SetAnimationSlider()
					LeaPlusCB["EnhanceDressupBtn"]:HookScript("OnClick", function()
						if IsShiftKeyDown() and IsControlKeyDown() then
							LeaPlusLC["DressupTransmogAnim"] = "On"
							SetAnimationSlider()
						end
					end)
					DressupPanel.r:HookScript("OnClick", function()
						LeaPlusLC["DressupTransmogAnim"] = "Off"
						SetAnimationSlider()
						DressupPanel:Hide(); DressupPanel:Show()
					end)

					-- Reset animation when slider is shown
					LeaPlusCB["TransmogAnim"]:HookScript("OnShow", SetAnimationSlider)

					-- Skin slider for ElvUI
					if LeaPlusLC.ElvUI then
						_G.LeaPlusGlobalTransmogAnim = LeaPlusCB["TransmogAnim"]
						LeaPlusLC.ElvUI:GetModule("Skins"):HandleSliderFrame(_G.LeaPlusGlobalTransmogAnim, false)
					end

				end

			end)

			-- Inspect System
			EventUtil.ContinueOnAddOnLoaded("Blizzard_InspectUI",function()
				-- Hide positioning controls
				InspectModelFrameControlFrame:HookScript("OnShow", InspectModelFrameControlFrame.Hide)
			end)

		end

		----------------------------------------------------------------------
		-- Automate gossip (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to skip gossip
			local function SkipGossip(skipAltKeyRequirement)
				if not skipAltKeyRequirement and not IsAltKeyDown() then return end
				local gossipInfoTable = C_GossipInfo.GetOptions()
				if gossipInfoTable[1] then
					if gossipInfoTable[1].gossipOptionID then
						C_GossipInfo.SelectOption(gossipInfoTable[1].gossipOptionID)
					else
						-- Some gossip options dont have a gossip option ID (such as Suspicious Noble NPCs in Court of Stars, Suramar)
						if GossipFrame and GossipFrame:IsShown() then GossipFrame:SelectGossipOption(1) end
					end
				end
			end

			-- Create gossip event frame
			local gossipFrame = CreateFrame("FRAME")

			-- Function to setup events
			local function SetupEvents()
				if LeaPlusLC["AutomateGossip"] == "On" then
					gossipFrame:RegisterEvent("GOSSIP_SHOW")
				else
					gossipFrame:UnregisterEvent("GOSSIP_SHOW")
				end
			end

			-- Setup events when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutomateGossip"]:HookScript("OnClick", SetupEvents)
			if LeaPlusLC["AutomateGossip"] == "On" then SetupEvents() end

			-- Event handler
			gossipFrame:SetScript("OnEvent", function()
				-- Special treatment for specific NPCs
				local npcGuid = UnitGUID("npc") or nil -- target does not work with soft targeting
				if npcGuid and canaccessvalue(npcGuid) then
					local void, void, void, void, void, npcID = strsplit("-", npcGuid)
					if npcID then
						-- Open rogue doors in Dalaran (Broken Isles) automatically
						if npcID == "96782"		-- Lucian Trias
						or npcID == "93188"		-- Mongar
						or npcID == "97004"		-- "Red" Jack Findle
						then
							SkipGossip()
							return
						end
						-- Skip gossip with no alt key requirement
						if npcID == "132969"	-- Katy Stampwhistle (toy)
						or npcID == "104201"	-- Katy Stampwhistle (npc)
						then
							SkipGossip(true) 	-- true means skip alt key requirement
							return
						end
					end
				end
				-- Process gossip
				local gossipOptions = C_GossipInfo.GetOptions()
				if gossipOptions and #gossipOptions == 1 and C_GossipInfo.GetNumAvailableQuests() == 0 and C_GossipInfo.GetNumActiveQuests() == 0 then
					SkipGossip()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Disable pet automation
		----------------------------------------------------------------------

		if LeaPlusLC["NoPetAutomation"] == "On" then

			-- Create frame to watch for combat
			local petCombat = CreateFrame("FRAME")
			local petTicker

			-- Function to dismiss pet
			local function DismissPetTimerFunc()
				if UnitAffectingCombat("player") then
					-- Player is in combat so cancel ticker and schedule it for when combat ends
					if petTicker then petTicker:Cancel() end
					petCombat:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					-- Player is not in combat so attempt to dismiss pet
					local summonedPet = C_PetJournal.GetSummonedPetGUID()
					if summonedPet then
						C_PetJournal.SummonPetByGUID(summonedPet)
					end
				end
			end

			hooksecurefunc(C_PetJournal, "SetPetLoadOutInfo", function()
				-- Cancel existing ticker if one already exists
				if petTicker then petTicker:Cancel() end
				-- Check for combat
				if UnitAffectingCombat("player") then
					-- Player is in combat so schedule ticker for when combat ends
					petCombat:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					-- Player is not in combat so run ticker now
					petTicker = C_Timer.NewTicker(0.5, DismissPetTimerFunc, 15)
				end
			end)

			-- Script for when combat ends
			petCombat:SetScript("OnEvent", function()
				-- Combat has ended so run ticker now
				petTicker = C_Timer.NewTicker(0.5, DismissPetTimerFunc, 15)
				petCombat:UnregisterEvent("PLAYER_REGEN_ENABLED")
			end)

		end

		----------------------------------------------------------------------
		--	Show pet save button
		----------------------------------------------------------------------

		if LeaPlusLC["ShowPetSaveBtn"] == "On" then

			EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections",function()

				-- Create panel
				local pFrame = CreateFrame("Frame", nil, PetJournal)
				pFrame:ClearAllPoints()
				pFrame:SetPoint("TOPLEFT", PetJournalLoadoutBorder, "TOPLEFT", 4, 40)
				pFrame:SetSize(PetJournalLoadoutBorder:GetWidth() -10, 16)
				pFrame:Hide()
				pFrame:SetFrameLevel(5000)

				-- Add background color
				pFrame.t = pFrame:CreateTexture(nil, "BACKGROUND")
				pFrame.t:SetAllPoints()
				pFrame.t:SetColorTexture(0.05, 0.05, 0.05, 0.7)

				-- Create editbox
				local petEB = CreateFrame("EditBox", nil, pFrame)
				petEB:SetAllPoints()
				petEB:SetTextInsets(2, 2, 2, 2)
				petEB:SetFontObject("GameFontNormal")
				petEB:SetTextColor(1.0, 1.0, 1.0, 1)
				petEB:SetBlinkSpeed(0)
				petEB:SetAltArrowKeyMode(true)

				-- Prevent changes
				petEB:SetScript("OnEscapePressed", function() pFrame:Hide() end)
				petEB:SetScript("OnEnterPressed", function() petEB:HighlightText() end)
				petEB:SetScript("OnMouseDown", function() petEB:ClearFocus() end)
				petEB:SetScript("OnMouseUp", function() petEB:HighlightText() end)

				-- Create tooltip
				petEB.tiptext = L["This command will assign your current pet team and selected abilities.|n|nPress CTRL/C to copy the command then paste it into a macro or chat window with CTRL/V."]
				petEB:HookScript("OnEnter", function()
					GameTooltip:SetOwner(petEB, "ANCHOR_TOP")
					GameTooltip:SetText(petEB.tiptext, nil, nil, nil, nil, true)
				end)
				petEB:HookScript("OnLeave", GameTooltip_Hide)

				-- Function to get pet data and build macro
				local function RefreshPets()
					-- Get pet data
					local p1, p1a, p1b, p1c = C_PetJournal.GetPetLoadOutInfo(1)
					local p2, p2a, p2b, p2c = C_PetJournal.GetPetLoadOutInfo(2)
					local p3, p3a, p3b, p3c = C_PetJournal.GetPetLoadOutInfo(3)
					if p1 and p1a and p1b and p1c and p2 and p2a and p2b and p2c and p3 and p3a and p3b and p3c then
						-- Build macro string and show it in editbox
						local comTeam = "/ltp team "
						comTeam = comTeam .. p1 .. ',' .. p1a .. ',' .. p1b .. ',' .. p1c .. ","
						comTeam = comTeam .. p2 .. ',' .. p2a .. ',' .. p2b .. ',' .. p2c .. ","
						comTeam = comTeam .. p3 .. ',' .. p3a .. ',' .. p3b .. ',' .. p3c
						petEB:SetText(comTeam)
						petEB:HighlightText()
						petEB:SetFocus()
					end
				end

				-- Prevent changes to editbox value
				petEB:SetScript("OnChar", RefreshPets)
				petEB:SetScript("OnKeyUp", RefreshPets)

				-- Refresh pet data when slots are changed
				hooksecurefunc(C_PetJournal, "SetPetLoadOutInfo", RefreshPets)

				-- Add macro button
				local macroBtn = LeaPlusLC:CreateButton("PetMacroBtn", _G["PetJournalLoadoutPet1"], "", "TOPRIGHT", 0, 0, 32, 32, false, "")
				macroBtn:SetFrameLevel(5000)
				macroBtn:SetNormalTexture("Interface\\BUTTONS\\AdventureGuideMicrobuttonAlert")
				macroBtn:SetScript("OnClick", function()
					if C_PetJournal.GetPetLoadOutInfo(1) and C_PetJournal.GetPetLoadOutInfo(2) and C_PetJournal.GetPetLoadOutInfo(3) then
						if pFrame:IsShown() then
							-- Frame is already showing so hide it
							pFrame:Hide()
						else
							-- Show macro panel
							pFrame:Show()
							RefreshPets()
						end
					else
						LeaPlusLC:Print("You need a battle pet team.")
					end
				end)
				macroBtn:HookScript("OnHide", function() pFrame:Hide() end)

			end)

		end

		----------------------------------------------------------------------
		--	Faster looting
		----------------------------------------------------------------------

		if LeaPlusLC["FasterLooting"] == "On" then


			-- Create configuration panel
			local FasterLootPanel = LeaPlusLC:CreatePanel("Faster auto loot", "FasterLootPanel")

			LeaPlusLC:MakeTx(FasterLootPanel, "Delay", 16, -72)
			LeaPlusLC:MakeSL(FasterLootPanel, "LeaPlusFasterLootDelay", "Drag to set the delay between looting items.|n|nLower is faster but may not always give the best results.|n|nIt's recommended that you leave this setting at 0.3 but feel free to try lower values if you wish.", 0.1, 0.3, 0.1, 16, -92, "%.1f")
			LeaPlusLC:MakeFT(FasterLootPanel, "The default delay setting is 0.3.  Lower is faster but may not always give the best results.  It's recommended that you leave this setting at 0.3.", 16, 510, 96)

			-- Help button hidden
			FasterLootPanel.h:Hide()

			-- Back button handler
			FasterLootPanel.b:SetScript("OnClick", function()
				FasterLootPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
				return
			end)

			-- Reset button handler
			FasterLootPanel.r:SetScript("OnClick", function()

				-- Reset slider
				LeaPlusLC["LeaPlusFasterLootDelay"] = 0.3

				-- Refresh side panel
				FasterLootPanel:Hide(); FasterLootPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["FasterLootingBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["LeaPlusFasterLootDelay"] = 0.3
					FasterLootPanel:Hide(); FasterLootPanel:Show()
				else
					FasterLootPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Time delay
			local tDelay = 0

			-- Fast loot function
			local function FastLoot()
				if GetTime() - tDelay >= LeaPlusLC["LeaPlusFasterLootDelay"] then
					tDelay = GetTime()
					if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
						if TSMDestroyBtn and TSMDestroyBtn:IsShown() and TSMDestroyBtn:GetButtonState() == "DISABLED" then tDelay = GetTime() return end
						for i = GetNumLootItems(), 1, -1 do
							LootSlot(i)
						end
						tDelay = GetTime()
					end
				end
			end

			-- Event frame
			local faster = CreateFrame("Frame")
			faster:RegisterEvent("LOOT_READY")
			faster:SetScript("OnEvent", FastLoot)

		end

		----------------------------------------------------------------------
		--	Hide event toasts
		----------------------------------------------------------------------

		if LeaPlusLC["HideEventToasts"] == "On" then

			-- Hide event toasts when shown except toasts with a close button (Torghast final scores)
			-- (a script hook is used rather than hooking the frame's Show function, as on retail a function hooked with hooksecurefunc
			-- can read as missing while the taint log is on, which stops the game showing toasts at all)
			local function HideCurrentToast()
				if EventToastManagerFrame.HideButton:IsShown() then return end
				local toast = EventToastManagerFrame.currentDisplayingToast
				if not toast then return end
				if IsInJailersTower() then
					-- Show floor summary
					local title = toast.Title:GetText() or nil
					if title and strfind(title, JAILERS_TOWER_SCENARIO_FLOOR) then
						-- Add right-click to close floor summary
						toast:SetScript("OnMouseDown", function(self, btn)
							if btn == "RightButton" then
								EventToastManagerFrame:CloseActiveToasts()
								return
							end
						end)
						return
					end
				end
				toast:OnAnimatedOut()
			end

			-- When the toast frame is shown, hide its toast, then check again next frame in case another toast was shown straight
			-- away (the frame stays shown for the next toast, so it is not shown again)
			local function HideToasts(tries)
				HideCurrentToast()
				if EventToastManagerFrame:IsShown() and tries < 10 then
					C_Timer.After(0, function() HideToasts(tries + 1) end)
				end
			end
			EventToastManagerFrame:HookScript("OnShow", function() HideToasts(0) end)

			-- Force zone text to show while EventToastManagerFrame is showing
			ZoneTextFrame:HookScript("OnEvent", function(self, event)
				if EventToastManagerFrame:IsShown() then
					if event == "ZONE_CHANGED_NEW_AREA" and not ZoneTextFrame:IsShown() then
						FadingFrame_Show(ZoneTextFrame)
					elseif event == "ZONE_CHANGED_INDOORS" and not SubZoneTextFrame:IsShown() then
						FadingFrame_Show(SubZoneTextFrame)
					end
				end
			end)

		end

		----------------------------------------------------------------------
		--	Hide boss banner
		----------------------------------------------------------------------

		if LeaPlusLC["HideBossBanner"] == "On" then
			BossBanner:UnregisterEvent("ENCOUNTER_LOOT_RECEIVED")
			BossBanner:UnregisterEvent("BOSS_KILL")
		end

		----------------------------------------------------------------------
		--	Hide clean-up buttons
		----------------------------------------------------------------------

		if LeaPlusLC["HideCleanupBtns"] == "On" and not LeaLockList["HideCleanupBtns"] then
			-- Hide backpack clean-up button and make item search box longer
			BagItemAutoSortButton:HookScript("OnShow", BagItemAutoSortButton.Hide)
			hooksecurefunc(ContainerFrame1, "SetSearchBoxPoint", function()
				if BagItemSearchBox:GetWidth() ~= 120 then
					BagItemSearchBox:SetWidth(120)
				end
			end)

			-- Hide bank frame clean-up button and make item search box longer
			BankPanel.AutoSortButton:HookScript("OnShow", BankPanel.AutoSortButton.Hide)
			BankItemSearchBox:ClearAllPoints()
			BankItemSearchBox:SetPoint("TOPRIGHT", BankFrame, "TOPRIGHT", -27, -33)
			BankItemSearchBox:SetWidth(120)
		end

		----------------------------------------------------------------------
		--	Hide talking frame
		----------------------------------------------------------------------

		if LeaPlusLC["HideTalkingFrame"] == "On" then

			-- Hide the talking head once the game has started it (a script hook is used rather than hooking its PlayCurrent function, as on
			-- retail a function hooked with hooksecurefunc can read as missing while the taint log is on, which stops talking heads entirely)
			TalkingHeadFrame:HookScript("OnEvent", function(self, event)
				if event == "TALKINGHEAD_REQUESTED" then
					self:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Automate quests (no reload required)
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local QuestPanel = LeaPlusLC:CreatePanel("Automate quests", "QuestPanel")

			LeaPlusLC:MakeTx(QuestPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(QuestPanel, "AutoQuestRegular", "Accept regular quests automatically", 16, -92, false, "If checked, regular quests will be accepted automatically.|n|nThis does not apply to daily or weekly quests.")
			LeaPlusLC:MakeCB(QuestPanel, "AutoQuestDaily", "Accept daily quests automatically", 16, -112, false, "If checked, daily quests will be accepted automatically.")
			LeaPlusLC:MakeCB(QuestPanel, "AutoQuestWeekly", "Accept weekly quests automatically", 16, -132, false, "If checked, weekly quests will be accepted automatically.")
			LeaPlusLC:MakeCB(QuestPanel, "AutoQuestCompleted", "Turn-in completed quests automatically", 16, -152, false, "If checked, completed quests will be turned-in automatically.")
			LeaPlusLC:MakeCB(QuestPanel, "AutoQuestShift", "Require override key for quest automation", 16, -172, false, "If checked, you will need to hold the override key down for quests to be automated.|n|nIf unchecked, holding the override key will prevent quests from being automated.")

			-- Add dropdown menu
			LeaPlusLC:CreateDropdown("AutoQuestKeyMenu", "Override key", 146, "TOPLEFT", QuestPanel, "TOPLEFT", 356, -92, false, {{L["SHIFT"], 1}, {L["ALT"], 2}, {L["CONTROL"], 3}, {L["CMD (MAC)"], 4}})

			-- Help button hidden
			QuestPanel.h:Hide()

			-- Back button handler
			QuestPanel.b:SetScript("OnClick", function()
				QuestPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page1"]:Show();
				return
			end)

			-- Reset button handler
			QuestPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["AutoQuestShift"] = "Off"
				LeaPlusLC["AutoQuestRegular"] = "On"
				LeaPlusLC["AutoQuestDaily"] = "On"
				LeaPlusLC["AutoQuestWeekly"] = "On"
				LeaPlusLC["AutoQuestCompleted"] = "On"
				LeaPlusLC["AutoQuestKeyMenu"] = 1

				-- Refresh panel
				QuestPanel:Hide(); QuestPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["AutomateQuestsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["AutoQuestShift"] = "Off"
					LeaPlusLC["AutoQuestRegular"] = "On"
					LeaPlusLC["AutoQuestDaily"] = "On"
					LeaPlusLC["AutoQuestWeekly"] = "On"
					LeaPlusLC["AutoQuestCompleted"] = "On"
					LeaPlusLC["AutoQuestKeyMenu"] = 1
				else
					QuestPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Function to determine if override key is being held
			local function IsOverrideKeyDown()
				if LeaPlusLC["AutoQuestKeyMenu"] == 1 and IsShiftKeyDown()
				or LeaPlusLC["AutoQuestKeyMenu"] == 2 and IsAltKeyDown()
				or LeaPlusLC["AutoQuestKeyMenu"] == 3 and IsControlKeyDown()
				or LeaPlusLC["AutoQuestKeyMenu"] == 4 and IsMetaKeyDown()
				then
					return true
				end
			end

			-- Funcion to ignore specific NPCs
			local function isNpcBlocked(actionType)
				local npcGuid = UnitGUID("npc") or nil -- npc works when cvar SoftTargetInteract set to 3 (was target)
				if npcGuid and canaccessvalue(npcGuid) then
					local void, void, void, void, void, npcID = strsplit("-", npcGuid)
					if npcID then
						-- Ignore specific NPCs for selecting, accepting and turning-in quests (required if automation has consequences)
						if npcID == "15192" 	-- Anachronos (Caverns of Time)
						or npcID == "119388" 	-- Chieftain Hatuun (Krokul Hovel, Krokuun)
						or npcID == "6566" 		-- Estelle Gendry (Heirloom Curator, Undercity)
						or npcID == "45400" 	-- Fiona's Caravan (Eastern Plaguelands)
						or npcID == "18166" 	-- Khadgar (Allegiance to Aldor/Scryer, Shattrath)
						or npcID == "55402" 	-- Korgol Crushskull (Darkmoon Faire, Pit Master)
						or npcID == "6294" 		-- Krom Stoutarm (Heirloom Curator, Ironforge)
						or npcID == "109227" 	-- Meliah Grayfeather (Tradewind Roost, Highmountain)
						or npcID == "99183" 	-- Renegade Ironworker (Tanaan Jungle, repeatable quest)
						or npcID == "114719" 	-- Trader Caelen (Obliterum Forge, Dalaran, Broken Isles)
						-- Seals of Fate
						or npcID == "111243" 	-- Archmage Lan'dalock (Seal quest, Dalaran)
						or npcID == "87391" 	-- Fate-Twister Seress (Seal quest, Stormshield)
						or npcID == "88570"		-- Fate-Twister Tiklal (Seal quest, Horde)
						or npcID == "142063" 	-- Tezran (Seal quest, Boralus Harbor, Alliance)
						or npcID == "141584" 	-- Zurvan (Seal quest, Dazar'alor, Horde)
						-- Wartime Donations (Alliance)
						or npcID == "142994" 	-- Brandal Darkbeard (Boralus)
						or npcID == "142995" 	-- Charlane (Boralus)
						or npcID == "142993" 	-- Chelsea Strand (Boralus)
						or npcID == "142998" 	-- Faella (Boralus)
						or npcID == "143004" 	-- Larold Kyne (Boralus)
						or npcID == "143005" 	-- Liao (Boralus)
						or npcID == "143007" 	-- Mae Wagglewand (Boralus)
						or npcID == "143008" 	-- Norber Togglesprocket (Boralus)
						or npcID == "142685" 	-- Paymaster Vauldren (Boralus)
						or npcID == "142700" 	-- Quartermaster Peregrin (Boralus)
						or npcID == "142997" 	-- Senedras (Boralus)
						-- Wartime Donations (Horde)
						or npcID == "142970" 	-- Kuma Longhoof (Dazar'alor)
						or npcID == "142969" 	-- Logarr (Dazar'alor)
						or npcID == "142973" 	-- Mai-Lu (Dazar'alor)
						or npcID == "142977" 	-- Meredith Swane (Dazar'alor)
						or npcID == "142981" 	-- Merill Redgrave (Dazar'alor)
						or npcID == "142157" 	-- Paymaster Grintooth (Dazar'alor)
						or npcID == "142158" 	-- Quartermaster Rauka (Dazar'alor)
						or npcID == "142975" 	-- Seamstress Vessa (Dazar'alor)
						or npcID == "142983" 	-- Swizzle Fizzcrank (Dazar'alor)
						or npcID == "142992" 	-- Uma'wi (Dazar'alor)
						or npcID == "142159" 	-- Zen'kin (Dazar'alor)
						-- Dragonflight
						or npcID == "193110" 	-- Khadin <Master Artisan> (Ohn'ahran Plains)
						then
							return true
						end
						-- Ignore specific NPCs for selecting quests only (only used for items that have no other purpose)
						if actionType == "Select" then
							if npcID == "87706" 	-- Gazmolf Futzwangler (Reputation quests, Nagrand, Draenor)
							or npcID == "70022" 	-- Ku'ma (Isle of Giants, Pandaria)
							or npcID == "12944" 	-- Lokhtos Darkbargainer (Thorium Brotherhood, Blackrock Depths)
							or npcID == "87393" 	-- Sallee Silverclamp (Reputation quests, Nagrand, Draenor)
							or npcID == "10307" 	-- Witch Doctor Mau'ari (E'Ko quests, Winterspring)
							then
								return true
							end
						end
					end
				end
			end

			-- Function to check if quest ID is blocked
			local function IsQuestIDBlocked(questID)
				if questID then
					if questID == 43923		-- Starlight Rose
					or questID == 43924		-- Leyblood
					or questID == 43925		-- Runescale Koi
					or questID == 71162		-- Waygate: Algeth'era (Thaelin Darkanvil, Dragonflight)
					or questID == 71165		-- Waygate: Eon's Fringe (Thaelin Darkanvil, Dragonflight)
					or questID == 71138		-- Waygate: Rusza'thar Reach (Thaelin Darkanvil, Dragonflight)
					or questID == 71178		-- Waygate: Shady Sanctuary (Thaelin Darkanvil, Dragonflight)
					or questID == 71157		-- Waygate: Skytop Observatory (Thaelin Darkanvil, Dragonflight)
					or questID == 71161		-- Waygate: Vakthros (Thaelin Darkanvil, Dragonflight)

					-- Khuri (The Dragon Isles) (Catch and Release quests) (don't select and accept quest if requirements aren't met including bank storage)
					or questID == 70199 and C_Item.GetItemCount(194730, true, true, true) < 20 -- Scalebelly Mackerel
					or questID == 70200 and C_Item.GetItemCount(194966, true, true, true) < 20 -- Thousandbite Piranha
					or questID == 70201 and C_Item.GetItemCount(194967, true, true, true) < 20 -- Aileron Seamoth
					or questID == 70202 and C_Item.GetItemCount(194968, true, true, true) < 20 -- Cerulean Spinefish
					or questID == 70203 and C_Item.GetItemCount(194969, true, true, true) < 20 -- Temporal Dragonhead
					or questID == 70935 and C_Item.GetItemCount(194970, true, true, true) < 20 -- Islefin Dorado

					then
						return true
					end
				end
			end

			-- Function to check if a required item is account-bound
			local function IsItemAccountBound(itemID)
				local tooltipData = C_TooltipInfo.GetItemByID(itemID)
				for row, line in ipairs(tooltipData.lines) do
					if tooltipData.lines[row] and tooltipData.lines[row].leftText and (tooltipData.lines[row].leftText == ITEM_BNETACCOUNTBOUND or tooltipData.lines[row].leftText == ITEM_BIND_TO_BNETACCOUNT or tooltipData.lines[row].leftText == ITEM_BIND_TO_ACCOUNT or tooltipData.lines[row].leftText == ITEM_ACCOUNTBOUND) then
						return true
					end
				end
			end

			-- Function to check if quest requires currency or a crafting reagent or required item is account-bound
			local function QuestRequiresCurrency()
				for i = 1, 6 do
					local progItem = _G["QuestProgressItem" ..i] or nil
					if progItem and progItem:IsShown() and progItem.type == "required" then
						if progItem.objectType == "currency" then
							-- Quest requires currency so do nothing
							return true
						elseif progItem.objectType == "item" then
							-- Quest requires an item
							local name, texture, numItems, void, void, itemID = GetQuestItemInfo("required", i)
							if name and itemID then
								local void, void, void, void, void, void, void, void, void, void, void, void, void, void, void, void, isCraftingReagent = C_Item.GetItemInfo(itemID)
								if isCraftingReagent or IsItemAccountBound(itemID) then
									-- Item is a crafting reagent or account-bound so do nothing
									return true
								end
							end
						end
					end
				end
			end

			-- Function to check if quest requires gold
			local function QuestRequiresGold()
				local goldRequiredAmount = GetQuestMoneyToGet()
				if goldRequiredAmount and goldRequiredAmount > 0 then
					return true
				end
			end

			-- Function to check if quest ID has requirements met
			local function DoesQuestHaveRequirementsMet(qID)
				if qID and qID ~= "" then

					if not qID then

					-- Scourgestones
					elseif qID == 62293 then
						-- Quest Darkened Scourgestones requires 25 Darkened Scourgestones
						if C_Item.GetItemCount(180720) >= 25 then return true end

					elseif qID == 62292 then
						-- Quest Pitch Black Scourgestones requires 25 Pitch Black Scourgestones
						if C_Item.GetItemCount(183200) >= 25 then return true end

					elseif qID == 10325 or qID == 10326 then
						-- Requires 10 More Marks of Kil'jaeden
						if C_Item.GetItemCount(29425) >= 10 then return true end

					elseif qID == 10655 or qID == 10828 then
						-- Requires 1 Marks of Sargeras (if more than 10, leave for More Marks of Sargeras)
						if C_Item.GetItemCount(30809) >= 1 and C_Item.GetItemCount(30809) < 10 then return true end

					elseif qID == 10654 or qID == 10827 then
						-- Requires 10 Marks of Sargeras
						if C_Item.GetItemCount(30809) >= 10 then return true end

					elseif qID == 10412 or qID == 10415 then
						-- Requires 10 Firewing Signets
						if C_Item.GetItemCount(29426) >= 10 then return true end

					elseif qID == 10659 or qID == 10822 then
						-- Requires 1 Sunfury Signet (if more than 10, leave for More Sunfury Signets)
						if C_Item.GetItemCount(30810) >= 1 and C_Item.GetItemCount(30810) < 10 then return true end

					elseif qID == 10658 or qID == 10823 then
						-- Requires 10 Sunfury Signets
						if C_Item.GetItemCount(30810) >= 10 then return true end

					else return true
					end
				end
			end

			-- Create event frame
			local qFrame = CreateFrame("FRAME")

			-- Function to setup events
			local function SetupEvents()
				if LeaPlusLC["AutomateQuests"] == "On" then
					qFrame:RegisterEvent("QUEST_DETAIL")
					qFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
					qFrame:RegisterEvent("QUEST_PROGRESS")
					qFrame:RegisterEvent("QUEST_COMPLETE")
					qFrame:RegisterEvent("QUEST_GREETING")
					qFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
					qFrame:RegisterEvent("GOSSIP_SHOW")
					qFrame:RegisterEvent("QUEST_FINISHED")
				else
					qFrame:UnregisterAllEvents()
				end
			end

			-- Setup events when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutomateQuests"]:HookScript("OnClick", SetupEvents)
			if LeaPlusLC["AutomateQuests"] == "On" then SetupEvents() end

			-- Store quest frequency values
			local regularQuest = Enum.QuestFrequency.Default
			local dailyQuest = Enum.QuestFrequency.Daily
			local weeklyQuest = Enum.QuestFrequency.Weekly

			-- Event handler
			qFrame:SetScript("OnEvent", function(self, event, arg1)

				-- Block shared quests if option is enabled
				if event == "QUEST_DETAIL" then
					LeaPlusLC:CheckIfQuestIsSharedAndShouldBeDeclined()
				end

				-- Clear progress items when quest interaction has ceased
				if event == "QUEST_FINISHED" then
					for i = 1, 6 do
						local progItem = _G["QuestProgressItem" ..i] or nil
						if progItem and progItem:IsShown() then
							progItem:Hide()
						end
					end
					return
				end

				-- Check for SHIFT key modifier
				if LeaPlusLC["AutoQuestShift"] == "On" and not IsOverrideKeyDown() then return
				elseif LeaPlusLC["AutoQuestShift"] == "Off" and IsOverrideKeyDown() then return
				end

				----------------------------------------------------------------------
				-- Accept quests automatically
				----------------------------------------------------------------------

				-- Accept quests with a quest detail window
				if event == "QUEST_DETAIL" then
					if LeaPlusLC["AutoQuestRegular"] == "On" or LeaPlusLC["AutoQuestDaily"] == "On" or LeaPlusLC["AutoQuestWeekly"] == "On" then
						-- Don't accept quests if option is not enabled
						if LeaPlusLC["AutoQuestRegular"] == "Off" and not QuestIsDaily() and not QuestIsWeekly() then return end
						-- Don't accept daily quests if option is not enabled
						if LeaPlusLC["AutoQuestDaily"] == "Off" and QuestIsDaily() then return end
						-- Don't accept weekly quests if option is not enabled
						if LeaPlusLC["AutoQuestWeekly"] == "Off" and QuestIsWeekly() then return end
						-- Don't accept blocked quests
						if isNpcBlocked("Accept") then return end
						-- Accept quest
						if QuestGetAutoAccept() then
							-- Quest has already been accepted by Wow so close the quest detail window
							CloseQuest()
						else
							-- Quest has not been accepted by Wow so accept it
							AcceptQuest()
							--HideUIPanel(QuestFrame)
						end
					end
				end

				-- Accept quests which require confirmation (such as sharing escort quests)
				if event == "QUEST_ACCEPT_CONFIRM" then
					if LeaPlusLC["AutoQuestRegular"] == "On" then
						ConfirmAcceptQuest()
						StaticPopup_Hide("QUEST_ACCEPT")
					end
				end

				----------------------------------------------------------------------
				-- Turn-in quests automatically
				----------------------------------------------------------------------

				-- Turn-in progression quests
				if event == "QUEST_PROGRESS" and IsQuestCompletable() then
					if LeaPlusLC["AutoQuestCompleted"] == "On" then
						-- Don't continue quests for blocked NPCs
						if isNpcBlocked("Complete") then return end
						-- Don't continue if quest requires currency
						if QuestRequiresCurrency() then return end
						-- Don't continue if quest requires gold
						if QuestRequiresGold() then return end
						-- Continue quest
						CompleteQuest()
					end
				end

				-- Turn in completed quests if only one reward item is being offered
				if event == "QUEST_COMPLETE" then
					if LeaPlusLC["AutoQuestCompleted"] == "On" then
						-- Don't complete quests for blocked NPCs
						if isNpcBlocked("Complete") then return end
						-- Don't complete if quest requires currency
						if QuestRequiresCurrency() then return end
						-- Don't complete if quest requires gold
						if QuestRequiresGold() then return end
						-- Complete quest
						if GetNumQuestChoices() <= 1 then
							GetQuestReward(GetNumQuestChoices())
						end
					end
				end

				-- Show quest dialog for quests that use the objective tracker (it will be completed automatically)
				if event == "QUEST_AUTOCOMPLETE" then
					if LeaPlusLC["AutoQuestCompleted"] == "On" then
						local index = C_QuestLog.GetLogIndexForQuestID(arg1)
						local info = C_QuestLog.GetInfo(index)
						if info and info.isAutoComplete then
							local questID = C_QuestLog.GetQuestIDForLogIndex(index)
							C_QuestLog.SetSelectedQuest(questID)
							ShowQuestComplete(C_QuestLog.GetSelectedQuest())
						end
					end
				end

				----------------------------------------------------------------------
				-- Select quests automatically
				----------------------------------------------------------------------

				if event == "GOSSIP_SHOW" or event == "QUEST_GREETING" then

					-- Select quests
					if UnitExists("npc") or QuestFrameGreetingPanel:IsShown() then

						-- Do nothing if there is a gossip option with a color code (such as skip ahead)
						local gossipInfoTable = C_GossipInfo.GetOptions()
						for i = 1, #gossipInfoTable do
							local nameText = gossipInfoTable[i].name
							if nameText then
								if string.find(strupper(nameText), "|C") or string.find(strupper(nameText), "<")then
									if not string.find(nameText, "FF0008E8") then -- Purple text such as Darkmoon Faire daily quests
										return
									end
								end
							end
						end

						-- Don't select quests for blocked NPCs
						if isNpcBlocked("Select") then return end

						-- Select quests
						if event == "QUEST_GREETING" then
							-- Select quest greeting completed quests
							if LeaPlusLC["AutoQuestCompleted"] == "On" then
								for i = 1, GetNumActiveQuests() do
									local title, isComplete = GetActiveTitle(i)
									if title and isComplete then
										return SelectActiveQuest(i)
									end
								end
							end
							-- Select quest greeting available quests
							if LeaPlusLC["AutoQuestRegular"] == "On" or LeaPlusLC["AutoQuestDaily"] == "On" or LeaPlusLC["AutoQuestWeekly"] == "On" then
								for i = 1, GetNumAvailableQuests() do
									local title, isComplete = GetAvailableTitle(i)
									if title and not isComplete then
										local isTrivial, frequency, isRepeatable, isLegendary = GetAvailableQuestInfo(i)
										if frequency ~= regularQuest or LeaPlusLC["AutoQuestRegular"] == "On" then
											if frequency ~= dailyQuest or LeaPlusLC["AutoQuestDaily"] == "On" then
												if frequency ~= weeklyQuest or LeaPlusLC["AutoQuestWeekly"] == "On" then
													return SelectAvailableQuest(i)
												end
											end
										end
									end
								end
							end
						else
							-- Select gossip completed quests
							if LeaPlusLC["AutoQuestCompleted"] == "On" then
								local gossipQuests = C_GossipInfo.GetActiveQuests()
								for titleIndex, questInfo in ipairs(gossipQuests) do
									if questInfo.title and questInfo.isComplete then
										if questInfo.questID then
											return C_GossipInfo.SelectActiveQuest(questInfo.questID)
										end
									end
								end
							end
							-- Select gossip available quests
							if LeaPlusLC["AutoQuestRegular"] == "On" or LeaPlusLC["AutoQuestDaily"] == "On" or LeaPlusLC["AutoQuestWeekly"] == "On" then
								local GossipQuests = C_GossipInfo.GetAvailableQuests()
								for titleIndex, questInfo in ipairs(GossipQuests) do
									if questInfo.frequency ~= regularQuest or LeaPlusLC["AutoQuestRegular"] == "On" then
										if questInfo.frequency ~= dailyQuest or LeaPlusLC["AutoQuestDaily"] == "On" then
											if questInfo.frequency ~= weeklyQuest or LeaPlusLC["AutoQuestWeekly"] == "On" then
												if questInfo.questID and not IsQuestIDBlocked(questInfo.questID) and DoesQuestHaveRequirementsMet(questInfo.questID) then
													return C_GossipInfo.SelectAvailableQuest(questInfo.questID)
												end
											end
										end
									end
								end
							end
						end
					end
				end

			end)

		end

		----------------------------------------------------------------------
		-- Hide bogyguard gossip
		----------------------------------------------------------------------

		if LeaPlusLC["HideBodyguard"] == "On" then
			local gFrame = CreateFrame("FRAME")
			gFrame:RegisterEvent("GOSSIP_SHOW")

			local bodyNames = {}
			for i, v in pairs({--[[Delvar Ironfist]] 1733, --[[Tormmok]] 1736, --[[Talonpriest Ishaal]] 1737, --[[Defender Illona]] 1738, --[[Vivianne]] 1739, --[[Aeda Brightdawn]] 1740, --[[Leorajh]] 1741}) do
				local reputationInfo = C_GossipInfo.GetFriendshipReputation(v)
				bodyNames[reputationInfo.name] = true
			end

			gFrame:SetScript("OnEvent", function()
				-- Do nothing if shift is being held
				if IsShiftKeyDown() then return end
				local name = UnitName("target") or nil
				if not canaccessvalue(name) then return end
				if bodyNames[name] then
					-- Close gossip window if it's for a cooperating (active) bodyguard
					-- If you open a gossip window prior to the bodyguard (or hold shift), it will not close
					-- and will need to be closed manually.
					if UnitCanCooperate("target", "player") then
						C_GossipInfo.CloseGossip()
					end
				end
			end)
		end

		----------------------------------------------------------------------
		--	Sell junk automatically
		----------------------------------------------------------------------

		if LeaPlusLC["AutoSellJunk"] == "On" then

			-- Hide the sell all junk items button
			MerchantSellAllJunkButton:HookScript("OnShow", function() MerchantSellAllJunkButton:Hide() end)

			-- Create sell junk banner
			local StartMsg = CreateFrame("FRAME", nil, MerchantFrame)
			StartMsg:ClearAllPoints()
			StartMsg:SetPoint("BOTTOMLEFT", 4, 4)
			StartMsg:SetSize(160, 22)
			StartMsg:SetToplevel(true)
			StartMsg:Hide()

			StartMsg.s = StartMsg:CreateTexture(nil, "BACKGROUND")
			StartMsg.s:SetAllPoints()
			StartMsg.s:SetColorTexture(0.1, 0.1, 0.1, 1.0)

			StartMsg.f = StartMsg:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			StartMsg.f:SetAllPoints();
			StartMsg.f:SetText(L["SELLING JUNK"])

			-- Declarations
			local IterationCount, totalPrice = 500, 0
			local SellJunkTicker

			-- Create custom NewTicker function (from Wrath)
			local function LeaPlusNewTicker(duration, callback, iterations)
				local ticker = setmetatable({}, TickerMetatable)
				ticker._remainingIterations = iterations
				ticker._callback = function()
					if (not ticker._cancelled) then
						callback(ticker)
						--Make sure we weren't cancelled during the callback
						if (not ticker._cancelled) then
							if (ticker._remainingIterations) then
								ticker._remainingIterations = ticker._remainingIterations - 1
							end
							if (not ticker._remainingIterations or ticker._remainingIterations > 0) then
								C_Timer.After(duration, ticker._callback)
							end
						end
					end
				end
				C_Timer.After(duration, ticker._callback)
				return ticker
			end

			-- Create configuration panel
			local SellJunkFrame = LeaPlusLC:CreatePanel("Sell junk automatically", "SellJunkFrame")
			LeaPlusLC:MakeTx(SellJunkFrame, "Settings", 16, -72)
			LeaPlusLC:MakeCB(SellJunkFrame, "AutoSellShowSummary", "Show vendor summary in chat", 16, -92, false, "If checked, a vendor summary will be shown in chat when junk is automatically sold.")
			LeaPlusLC:MakeCB(SellJunkFrame, "AutoSellNoKeeperTahult", "Exclude Keeper Ta'hult's pet items", 16, -112, false, L["If checked, the following junk items required to purchase pets from Keeper Ta'hult in Oribos will not be sold automatically."] .. L["|cff889D9D|n"] .. L["|n- A Frayed Knot|n- Dark Iron Baby Booties|n- Ground Gear|n- Large Slimy Bone|n- Rabbits Foot|n- Robbles Wobbly Staff|n- Rotting Bear Carcass|n- The Stoppable Force|n- Very Unlucky Rock"] .. "|r")
			LeaPlusLC:MakeCB(SellJunkFrame, "AutoSellNoGreyGear", "Exclude all unbound grey gear", 16, -132, false, L["If checked, grey gear that is not soulbound to your character will not be sold.|n|nUse this setting if you plan to sell grey gear in the auction house."])

			-- Help button hidden
			SellJunkFrame.h:Hide()

			-- Back button handler
			SellJunkFrame.b:SetScript("OnClick", function()
				SellJunkFrame:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page1"]:Show();
				return
			end)

			-- Reset button handler
			SellJunkFrame.r.tiptext = SellJunkFrame.r.tiptext .. "|n|n" .. L["Note that this will not reset your exclusions list."]
			SellJunkFrame.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["AutoSellShowSummary"] = "On"
				LeaPlusLC["AutoSellNoKeeperTahult"] = "On"
				LeaPlusLC["AutoSellNoGreyGear"] = "Off"

				-- Refresh panel
				SellJunkFrame:Hide(); SellJunkFrame:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["AutoSellJunkBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["AutoSellShowSummary"] = "On"
					LeaPlusLC["AutoSellNoKeeperTahult"] = "On"
					LeaPlusLC["AutoSellNoGreyGear"] = "Off"
				else
					SellJunkFrame:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Function to stop selling
			local function StopSelling()
				if SellJunkTicker then SellJunkTicker._cancelled = true; end
				StartMsg:Hide()
				SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
				SellJunkFrame:UnregisterEvent("UI_ERROR_MESSAGE")
			end

			-- Create excluded box
			local titleTX = LeaPlusLC:MakeTx(SellJunkFrame, "Exclusions", 356, -72)
			titleTX:SetWidth(200)
			titleTX:SetWordWrap(false)
			titleTX:SetJustifyH("LEFT")

			-- Show help button for exclusions
			LeaPlusLC:CreateHelpButton("SellJunkExcludeHelpButton", SellJunkFrame, titleTX, "Enter item IDs separated by commas.  Item IDs can be found in item tooltips while this panel is showing.|n|nJunk items entered here will not be sold automatically.|n|nWhite items entered here will be sold automatically.|n|nThe editbox tooltip will show you more information about the items you have entered.")

			local eb = CreateFrame("Frame", nil, SellJunkFrame, "BackdropTemplate")
			eb:SetSize(200, LeaPlusLC.MainPanelHeight - 180)
			eb:SetPoint("TOPLEFT", 350, -92)
			eb:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
				edgeSize = 16,
				insets = {left = 8, right = 6, top = 8, bottom = 8},
			})
			eb:SetBackdropBorderColor(1.0, 0.85, 0.0, 0.5)

			eb.scroll = CreateFrame("ScrollFrame", nil, eb, "LeaPlusSellJunkScrollFrameTemplate")
			eb.scroll:SetPoint("TOPLEFT", eb, 12, -10)
			eb.scroll:SetPoint("BOTTOMRIGHT", eb, -30, 10)
			eb.scroll:SetPanExtent(16)

			-- Create character count
			eb.scroll.CharCount = eb.scroll:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			eb.scroll.CharCount:Hide()

			eb.Text = eb.scroll.EditBox
			eb.Text:SetWidth(150)
			eb.Text:SetPoint("TOPLEFT", eb.scroll)
			eb.Text:SetPoint("BOTTOMRIGHT", eb.scroll, -12, 0)
			eb.Text:SetMaxLetters(2000)
			eb.Text:SetFontObject(GameFontNormalLarge)
			eb.Text:SetAutoFocus(false)
			eb.scroll:SetScrollChild(eb.Text)

			-- Set focus on the editbox text when clicking the editbox
			eb:SetScript("OnMouseDown", function()
				eb.Text:SetFocus()
				eb.Text:SetCursorPosition(eb.Text:GetMaxLetters())
			end)

			-- Function to create whitelist
			local whiteList = {}
			local function UpdateWhiteList()
				wipe(whiteList)

				-- Keeper Ta'hult's pet items
				if LeaPlusLC["AutoSellNoKeeperTahult"] == "On" then

					-- Debug
					-- whiteList[2219] = "Small White Shield"
					-- whiteList[1820] = "Wooden Maul"
					-- whiteList[1796] = "Rawhide Boots"
					-- whiteList[2783] = "Shoddy Blunderbuss"

					-- Ruby Baubleworm
					whiteList[36812] = "Ground Gear"
					whiteList[62072] = "Robbles Wobbly Staff"
					whiteList[67410] = "Very Unlucky Rock"

					-- Topaz Baubleworm
					whiteList[11406] = "Rotting Bear Carcass"
					whiteList[11944] = "Dark Iron Baby Booties"
					whiteList[25402] = "The Stoppable Force"

					-- Turquoise Baubleworm
					whiteList[3300] = "Rabbits Foot"
					whiteList[3670] = "Large Slimy Bone"
					whiteList[6150] = "A Frayed Knot"

				end

				-- These items cannot be sold but the game thinks they can be
				-- https://www.wowhead.com/items/quest/min-level:1/max-level:1/quality:0?filter=64;3;1

				-- Continued Waygate Exploration
				whiteList[200590] = "Carefully Rolled Message"
				whiteList[200593] = "Sealed Expedition Note"
				whiteList[200594] = "Thaelin's Second Favorite Comb"
				whiteList[200595] = "Odorous Parchment"
				whiteList[200596] = "Letter from Thaelin Darkanvil"

				-- Dirty Old Satchel
				whiteList[200592] = "Dirty Old Satchel"
				whiteList[200606] = "Previously Owned Map"

				-- Rock Buddy (item cannot be sold but sell price is reported as 1)
				whiteList[228431] = "Rock Buddy"

				-- End of whitelist

				local whiteString = eb.Text:GetText()
				if whiteString and whiteString ~= "" then
					whiteString = whiteString:gsub("[^,%d]", "")
					local tList = {strsplit(",", whiteString)}
					for i = 1, #tList do
						if tList[i] then
							tList[i] = tonumber(tList[i])
							if tList[i] then
								whiteList[tList[i]] = true
							end
						end
					end
				end

				LeaPlusLC["AutoSellExcludeList"] = whiteString
				eb.Text:SetText(LeaPlusLC["AutoSellExcludeList"])

			end

			-- Save the excluded list when it changes and at startup
			eb.Text:SetScript("OnTextChanged", UpdateWhiteList)
			eb.Text:SetText(LeaPlusLC["AutoSellExcludeList"])
			UpdateWhiteList()

			-- Create whitelist on startup and option, reset or preset is clicked
			UpdateWhiteList()
			LeaPlusCB["AutoSellNoKeeperTahult"]:HookScript("OnClick", UpdateWhiteList)
			SellJunkFrame.r:HookScript("OnClick", UpdateWhiteList)
			LeaPlusCB["AutoSellJunkBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile (just the whitelist part)
					UpdateWhiteList()
				end
			end)

			-- Editbox tooltip
			local tipPrefix = ""

			-- Function to make tooltip string
			local function MakeTooltipString()

				local keepMsg = ""
				local sellMsg = ""
				local dupMsg = ""
				local novalueMsg = ""
				local incompatMsg = ""

				local tipString = eb.Text:GetText()
				if tipString and tipString ~= "" then
					tipString = tipString:gsub("[^,%d]", "")
					local tipList = {strsplit(",", tipString)}
					for i = 1, #tipList do
						if tipList[i] then
							tipList[i] = tonumber(tipList[i])
							if tipList[i] and tipList[i] > 0 and tipList[i] < 999999999 then
								local void, tLink, Rarity, void, void, void, void, void, void, void, ItemPrice = C_Item.GetItemInfo(tipList[i])
								if tLink and tLink ~= "" then
									local linkCol = string.sub(tLink, 1, 7)
									if linkCol then
										local linkName = tLink:match("%[(.-)%]")
										if linkName and ItemPrice then
											if ItemPrice > 0 then
												if Rarity == 0 then
													-- Junk item
													if string.find(keepMsg, "%(" .. tipList[i] .. "%)") then
														-- Duplicate (ID appears more than once in list)
														dupMsg = dupMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
													else
														-- Add junk item to keep list
														keepMsg = keepMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
													end
												elseif Rarity == 1 then
													-- White item
													if string.find(sellMsg, "%(" .. tipList[i] .. "%)") then
														-- Duplicate (ID appears more than once in list)
														dupMsg = dupMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
													else
														-- Add non-junk item to sell list
														sellMsg = sellMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
													end
												else
													-- Incompatible item (not junk or white)
													if string.find(incompatMsg, "%(" .. tipList[i] .. "%)") then
														-- Duplicate (ID appears more than once in list)
														dupMsg = dupMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
													else
														-- Add item to incompatible list
														incompatMsg = incompatMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
													end
												end
											else
												-- Item has no sell price so cannot be sold
												if string.find(novalueMsg, "%(" .. tipList[i] .. "%)") then
													-- Duplicate (ID appears more than once in list)
													dupMsg = dupMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
												else
													-- Add item to cannot be sold list
													novalueMsg = novalueMsg .. linkCol .. linkName .. " (" .. tipList[i] .. ")" .. "|r|n"
												end
											end
										end
									end
								end
							end
						end
					end
				end

				if keepMsg ~= "" then keepMsg = "|n" .. L["Keep"] .. "|n" .. keepMsg end
				if sellMsg ~= "" then sellMsg = "|n" .. L["Sell"] .. "|n" .. sellMsg end
				if dupMsg ~= "" then dupMsg = "|n" .. L["Duplicates"] .. "|n" .. dupMsg end
				if novalueMsg ~= "" then novalueMsg = "|n" .. L["Cannot be sold"] .. "|n" .. novalueMsg end
				if incompatMsg ~= "" then incompatMsg = "|n" .. L["Incompatible"] .. "|n" .. incompatMsg end

				eb.tiptext = L["Exclusions"] .. "|n" .. keepMsg .. sellMsg .. dupMsg .. novalueMsg .. incompatMsg
				eb.Text.tiptext = L["Exclusions"] .. "|n" .. keepMsg .. sellMsg .. dupMsg .. novalueMsg .. incompatMsg
				if eb.tiptext == L["Exclusions"] .. "|n" then eb.tiptext = eb.tiptext .. "|n" .. L["Nothing to see here."] end
				if eb.Text.tiptext == L["Exclusions"] .. "|n" then eb.Text.tiptext = "-" end

				if GameTooltip:IsShown() then
					if eb:IsMouseOver() or eb.Text:IsMouseOver() then
						GameTooltip:SetText(eb.tiptext, nil, nil, nil, nil, false)
					end
				end

			end

			eb.Text:HookScript("OnTextChanged", MakeTooltipString)
			eb.Text:HookScript("OnTextChanged", function()
				C_Timer.After(0.1, function()
					MakeTooltipString()
				end)
			end)

			-- Show the button tooltip for the editbox
			eb:SetScript("OnEnter", MakeTooltipString)
			eb:HookScript("OnEnter", LeaPlusLC.TipSee)
			eb:HookScript("OnEnter", function() GameTooltip:SetText(eb.tiptext, nil, nil, nil, nil, false) end)
			eb:SetScript("OnLeave", GameTooltip_Hide)
			eb.Text:SetScript("OnEnter", MakeTooltipString)
			eb.Text:HookScript("OnEnter", LeaPlusLC.ShowDropTip)
			eb.Text:HookScript("OnEnter", function() GameTooltip:SetText(eb.tiptext, nil, nil, nil, nil, false) end)
			eb.Text:SetScript("OnLeave", GameTooltip_Hide)

			-- Show item ID in item tooltips while configuration panel is showing
			TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self)
				if self ~= GameTooltip then return end
				if SellJunkFrame:IsShown() then
					local void, itemLink = self:GetItem()
					if itemLink then
						local itemID = GetItemInfoFromHyperlink(itemLink)
						if itemID then self:AddLine(L["Item ID"] .. ": " .. itemID) end
					end
				end
			end)

			-- Vendor function
			local function SellJunkFunc()

				-- Variables
				local SoldCount, Rarity, ItemPrice = 0, 0, 0
				local CurrentItemLink, classID, void
				local itemTypeWeapon = Enum.ItemClass.Weapon
				local itemTypeArmor = Enum.ItemClass.Armor

				-- Traverse bags and sell grey items
				for BagID = 0, 5 do
					for BagSlot = 1, C_Container.GetContainerNumSlots(BagID) do
						CurrentItemLink = C_Container.GetContainerItemLink(BagID, BagSlot)
						if CurrentItemLink then
							void, void, Rarity, void, void, void, void, void, void, void, ItemPrice, classID = C_Item.GetItemInfo(CurrentItemLink)
							-- Don't sell whitelisted items
							local itemID = GetItemInfoFromHyperlink(CurrentItemLink)
							if itemID and whiteList[itemID] then
								if Rarity == 0 then
									-- Junk item to keep
									Rarity = 20
									ItemPrice = 0
								elseif Rarity == 1 then
									-- White item to sell
									Rarity = 0
								end
							end
							-- Exclude grey gear
							if Rarity == 0 and classID and (classID == itemTypeWeapon or classID == itemTypeArmor) then -- Weapon or armor
								local isSoulBound = C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(BagID, BagSlot))
								-- local isWarboundUntilEquipped = C_Item.IsBoundToAccountUntilEquip(ItemLocation:CreateFromBagAndSlot(BagID, BagSlot))
								if not isSoulBound then
									-- Item is not soulbound (soulbound gear cannot be sold to others)
									if LeaPlusLC["AutoSellNoGreyGear"] == "On" then
										-- Exclude all grey gear is checked so do not sell
										Rarity = 20
										ItemPrice = 0
									end
								end
							end
							-- Continue
							local cInfo = C_Container.GetContainerItemInfo(BagID, BagSlot)
							local itemCount = cInfo.stackCount
							if Rarity == 0 and ItemPrice ~= 0 then
								SoldCount = SoldCount + 1
								if MerchantFrame:IsShown() then
									-- If merchant frame is open, vendor the item
									C_Container.UseContainerItem(BagID, BagSlot)
									-- Perform actions on first iteration
									if SellJunkTicker._remainingIterations == IterationCount then
										-- Calculate total price
										totalPrice = totalPrice + (ItemPrice * itemCount)
									end
								else
									-- If merchant frame is not open, stop selling
									StopSelling()
									return
								end
							end
						end
					end
				end

				-- Stop selling if no items were sold for this iteration or iteration limit was reached
				if SoldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then
					StopSelling()
					if totalPrice > 0 and LeaPlusLC["AutoSellShowSummary"] == "On" then
						LeaPlusLC:Print(L["Sold junk for"] .. " " .. C_CurrencyInfo.GetCoinText(totalPrice) .. ".")
					end
				end

			end

			-- Event handler
			SellJunkFrame:RegisterEvent("MERCHANT_SHOW")
			SellJunkFrame:RegisterEvent("MERCHANT_CLOSED")
			SellJunkFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
				if event == "MERCHANT_SHOW" then
					-- Check for vendors that refuse to buy items
					SellJunkFrame:RegisterEvent("UI_ERROR_MESSAGE")
					-- Reset variable
					totalPrice = 0
					-- Do nothing if shift key is held down
					if IsShiftKeyDown() then return end
					-- Cancel existing ticker if present
					if SellJunkTicker then SellJunkTicker._cancelled = true; end
					-- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
					SellJunkTicker = LeaPlusNewTicker(0.2, SellJunkFunc, IterationCount)
					SellJunkFrame:RegisterEvent("ITEM_LOCKED")
				elseif event == "ITEM_LOCKED" then
					StartMsg:Show()
					SellJunkFrame:UnregisterEvent("ITEM_LOCKED")
				elseif event == "MERCHANT_CLOSED" then
					-- If merchant frame is closed, stop selling
					StopSelling()
				elseif event == "UI_ERROR_MESSAGE" then
					if arg2 and (arg2 == ERR_VENDOR_DOESNT_BUY or arg2 == ERR_TOO_MUCH_GOLD) then
						-- Vendor refuses to buy items or player at gold limit
						StopSelling()
					end
				end
			end)

		end

		----------------------------------------------------------------------
		--	Repair automatically (no reload required)
		----------------------------------------------------------------------

		do

			-- Repair when suitable merchant frame is shown
			local function RepairFunc()
				if IsShiftKeyDown() then return end
				if CanMerchantRepair() then -- If merchant is capable of repair
					-- Process repair
					local RepairCost, CanRepair = GetRepairAllCost()
					if CanRepair then -- If merchant is offering repair
						if LeaPlusLC["AutoRepairGuildFunds"] == "On" and IsInGuild() then
							-- Guilded character and guild repair option is enabled
							if CanGuildBankRepair() then
								-- Character has permission to repair so try guild funds but fallback on character funds (if daily gold limit is reached)
								RepairAllItems(1)
								RepairAllItems()
							else
								-- Character does not have permission to repair so use character funds
								RepairAllItems()
							end
						else
							-- Unguilded character or guild repair option is disabled
							RepairAllItems()
						end
						-- Show cost summary
						if LeaPlusLC["AutoRepairShowSummary"] == "On" then
							LeaPlusLC:Print(L["Repaired for"] .. " " .. C_CurrencyInfo.GetCoinText(RepairCost) .. ".")
						end
					end
				end
			end

			-- Create event frame
			local RepairFrame = CreateFrame("FRAME")

			-- Function to setup event
			local function SetupEvent()
				if LeaPlusLC["AutoRepairGear"] == "On" then
					RepairFrame:RegisterEvent("MERCHANT_SHOW")
				else
					RepairFrame:UnregisterEvent("MERCHANT_SHOW")
				end
			end

			-- Setup event when option is clicked and on startup (if option is enabled)
			LeaPlusCB["AutoRepairGear"]:HookScript("OnClick", SetupEvent)
			if LeaPlusLC["AutoRepairGear"] == "On" then SetupEvent() end

			-- Event handler
			RepairFrame:SetScript("OnEvent", RepairFunc)

			-- Create configuration panel
			local RepairPanel = LeaPlusLC:CreatePanel("Repair automatically", "RepairPanel")

			LeaPlusLC:MakeTx(RepairPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(RepairPanel, "AutoRepairGuildFunds", "Repair using guild funds if available", 16, -92, false, "If checked, repair costs will be taken from guild funds for characters that are guilded and have permission to repair.")
			LeaPlusLC:MakeCB(RepairPanel, "AutoRepairShowSummary", "Show repair summary in chat", 16, -112, false, "If checked, a repair summary will be shown in chat when your gear is automatically repaired.")

			-- Help button hidden
			RepairPanel.h:Hide()

			-- Back button handler
			RepairPanel.b:SetScript("OnClick", function()
				RepairPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page1"]:Show();
				return
			end)

			-- Reset button handler
			RepairPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["AutoRepairGuildFunds"] = "On"
				LeaPlusLC["AutoRepairShowSummary"] = "On"

				-- Refresh panel
				RepairPanel:Hide(); RepairPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["AutoRepairBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["AutoRepairGuildFunds"] = "On"
					LeaPlusLC["AutoRepairShowSummary"] = "On"
				else
					RepairPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Hide the combat log
		----------------------------------------------------------------------

		if LeaPlusLC["NoCombatLogTab"] == "On" and not LeaLockList["NoCombatLogTab"] then

			-- Function to setup the combat log tab
			local function SetupCombatLogTab()
				ChatFrame2Tab:EnableMouse(false)
				ChatFrame2Tab:SetText(" ") -- Needs to be something for chat settings to function
				ChatFrame2Tab:SetScale(0.01)
				ChatFrame2Tab:SetWidth(0.01)
				ChatFrame2Tab:SetHeight(0.01)
			end

			local frame = CreateFrame("FRAME")
			frame:SetScript("OnEvent", SetupCombatLogTab)

			-- Ensure combat log is docked
			if ChatFrame2.isDocked then
				-- Set combat log attributes when chat windows are updated
				frame:RegisterEvent("UPDATE_CHAT_WINDOWS")
				-- Set combat log tab placement when tabs are assigned by the client
				hooksecurefunc("FCF_SetTabPosition", function()
					ChatFrame2Tab:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "BOTTOMRIGHT", 0, 0)
				end)
				SetupCombatLogTab()
			else
				-- If combat log is undocked, do nothing but show warning
				C_Timer.After(1, function()
					LeaPlusLC:Print("Combat log cannot be hidden while undocked.")
				end)
			end

		end

		----------------------------------------------------------------------
		--	Show player chain
		----------------------------------------------------------------------

		if LeaPlusLC["ShowPlayerChain"] == "On" and not LeaLockList["ShowPlayerChain"] then

			-- Ensure chain doesnt clip through pet portrait and rune frame
			PetPortrait:GetParent():SetFrameLevel(4)
			RuneFrame:SetFrameLevel(4)

			-- Create chain texture
			local playerChain = PlayerFrame.PlayerFrameContainer:CreateTexture(nil, "OVERLAY")
			playerChain:SetTexCoord(1, 0, 0, 1)

			-- Create configuration panel
			local ChainPanel = LeaPlusLC:CreatePanel("Show player chain", "ChainPanel")

			-- Add dropdown menu
			LeaPlusLC:CreateDropdown("PlayerChainMenu", "Chain style", 146, "TOPLEFT", ChainPanel, "TOPLEFT", 16, -92, false, {{L["ELITE"], 1}, {L["BOSS"], 2}, {L["RARE"], 3}})

			-- Set chain style
			local function SetChainStyle()
				-- Get dropdown menu value
				local chain = LeaPlusLC["PlayerChainMenu"] -- Numeric value
				-- Set chain style according to value
				if chain == 1 then -- Elite (Gold)
					playerChain:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold", true)
					playerChain:ClearAllPoints()
					playerChain:SetPoint("TOPLEFT", 8, -9)
					playerChain:SetVertexColor(1, 1, 1, 1)
				elseif chain == 2 then -- Boss (Gold Winged)
					playerChain:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged", true)
					playerChain:ClearAllPoints()
					playerChain:SetPoint("TOPLEFT", -11, -8)
					playerChain:SetVertexColor(1, 1, 1, 1)
				elseif chain == 3 then -- Rare (Silver)
					playerChain:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Silver", true)
					playerChain:ClearAllPoints()
					playerChain:SetPoint("TOPLEFT", 8, -9)
					playerChain:SetVertexColor(1, 1, 1, 1)
				end
			end

			-- Set style when dropdown menu is updated and on startup
			LeaPlusCB["PlayerChainMenu"]:RegisterCallback("OnMenuClose", SetChainStyle)
			SetChainStyle()

			-- Help button hidden
			ChainPanel.h:Hide()

			-- Back button handler
			ChainPanel.b:SetScript("OnClick", function()
				ChainPanel:Hide();
				LeaPlusLC["PageF"]:Show()
				LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			ChainPanel.r:SetScript("OnClick", function()
				LeaPlusLC["PlayerChainMenu"] = 1
				ChainPanel:Hide(); ChainPanel:Show()
				SetChainStyle()
			end)

			-- Show the panel when the configuration button is clicked
			LeaPlusCB["ModPlayerChain"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					LeaPlusLC["PlayerChainMenu"] = 1
					SetChainStyle()
				else
					LeaPlusLC:HideFrames()
					ChainPanel:Show()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show raid frame toggle button
		----------------------------------------------------------------------

		if LeaPlusLC["ShowRaidToggle"] == "On" and not LeaLockList["ShowRaidToggle"] then

			-- Check to make sure raid toggle button exists
			if CompactRaidFrameManagerDisplayFrameHiddenModeToggle then

				-- Move the button (function runs after PLAYER_ENTERING_WORLD and PARTY_LEADER_CHANGED)
				hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", function()
					if CompactRaidFrameManager and CompactRaidFrameManagerDisplayFrameHiddenModeToggle then
						local void, void, void, void, y = CompactRaidFrameManager:GetPoint()
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetWidth(40)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:ClearAllPoints()
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, y + 32)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetParent(UIParent)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetHitRectInsets(0, 0, 0, 0)
					end
				end)

			end

		end

		----------------------------------------------------------------------
		-- Hide portrait numbers
		----------------------------------------------------------------------

		if LeaPlusLC["NoHitIndicators"] == "On" and not LeaLockList["NoHitIndicators"] then
			PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HitIndicator:Hide()
			hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
		end

		----------------------------------------------------------------------
		-- Class colored frames
		----------------------------------------------------------------------

		if LeaPlusLC["ClassColFrames"] == "On" and not LeaLockList["ClassColFrames"] then

			-- Create background frame for player frame
			local PlayFN = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain:CreateTexture(nil, "BACKGROUND")
			PlayFN:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Type", true)
			PlayFN:SetTexCoord(1, 0, 0, 1)
			PlayFN:ClearAllPoints()
			PlayFN:SetPoint("TOPLEFT", 75, -25)

			local c = LeaPlusLC["RaidColors"][select(2, UnitClass("player"))]
			if c then PlayFN:SetVertexColor(c.r, c.g, c.b) end

			-- Create color function for target and focus frames
			local function TargetFrameCol()
				if UnitIsPlayer("target") then
					local void, target = UnitClass("target")
					if canaccessvalue(target) then
						local c = LeaPlusLC["RaidColors"][target]
						if c then TargetFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(c.r, c.g, c.b) end
					end
				end
				if UnitIsPlayer("focus") then
					local void, focus = UnitClass("focus")
					if canaccessvalue(focus) then
						local c = LeaPlusLC["RaidColors"][focus]
						if c then FocusFrame.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(c.r, c.g, c.b) end
					end
				end
			end

			local ColTar = CreateFrame("FRAME")
			ColTar:SetScript("OnEvent", TargetFrameCol) -- Events are registered if target option is enabled

			-- Refresh color if focus frame size changes
			if FocusFrame_SetSmallSize then
				hooksecurefunc(FocusFrame, "SetSmallSize", function()
					if LeaPlusLC["ClassColTarget"] == "On" then
						TargetFrameCol()
					end
				end)
			end

			-- Create configuration panel
			local ClassFrame = LeaPlusLC:CreatePanel("Class colored frames", "ClassFrame")

			LeaPlusLC:MakeTx(ClassFrame, "Settings", 16, -72)
			LeaPlusLC:MakeCB(ClassFrame, "ClassColPlayer", "Show player frame in class color", 16, -92, false, "If checked, the player frame background will be shown in class color.")
			LeaPlusLC:MakeCB(ClassFrame, "ClassColTarget", "Show target frame and focus frame in class color", 16, -112, false, "If checked, the target frame background and focus frame background will be shown in class color.")

			-- Help button hidden
			ClassFrame.h:Hide()

			-- Back button handler
			ClassFrame.b:SetScript("OnClick", function()
				ClassFrame:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page6"]:Show()
				return
			end)

			-- Function to set class colored frames
			local function SetClassColFrames()
				-- Player frame
				if LeaPlusLC["ClassColPlayer"] == "On" then
					PlayFN:Show()
				else
					PlayFN:Hide()
				end
				-- Target and focus frames
				if LeaPlusLC["ClassColTarget"] == "On" then
					ColTar:RegisterEvent("GROUP_ROSTER_UPDATE")
					ColTar:RegisterEvent("PLAYER_TARGET_CHANGED")
					ColTar:RegisterEvent("PLAYER_FOCUS_CHANGED")
					ColTar:RegisterEvent("UNIT_FACTION")
					TargetFrameCol()
				else
					ColTar:UnregisterAllEvents()
					TargetFrame.CheckFaction(TargetFrame) -- Reset target frame colors
					TargetFrame.CheckFaction(FocusFrame) -- Reset focus frame colors
				end
			end

			-- Run function when options are clicked and on startup
			LeaPlusCB["ClassColPlayer"]:HookScript("OnClick", SetClassColFrames)
			LeaPlusCB["ClassColTarget"]:HookScript("OnClick", SetClassColFrames)
			SetClassColFrames()

			-- Reset button handler
			ClassFrame.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["ClassColPlayer"] = "On"
				LeaPlusLC["ClassColTarget"] = "On"

				-- Update colors and refresh configuration panel
				SetClassColFrames()
				ClassFrame:Hide(); ClassFrame:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["ClassColFramesBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["ClassColPlayer"] = "On"
					LeaPlusLC["ClassColTarget"] = "On"
					SetClassColFrames()
				else
					ClassFrame:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Quest text size
		----------------------------------------------------------------------

		if LeaPlusLC["QuestFontChange"] == "On" then

			-- Create configuration panel
			local QuestTextPanel = LeaPlusLC:CreatePanel("Resize quest text", "QuestTextPanel")

			LeaPlusLC:MakeTx(QuestTextPanel, "Text size", 16, -72)
			LeaPlusLC:MakeSL(QuestTextPanel, "LeaPlusQuestFontSize", "Drag to set the font size of quest text.", 10, 30, 1, 16, -92, "%.0f")

			-- Function to update the font size
			local function QuestSizeUpdate()
				local a, b, c = QuestFont:GetFont()
				QuestTitleFont:SetFont(a, LeaPlusLC["LeaPlusQuestFontSize"] + 3, c)
				QuestFont:SetFont(a, LeaPlusLC["LeaPlusQuestFontSize"] + 1, c)
				local d, e, f = QuestFontNormalSmall:GetFont()
				QuestFontNormalSmall:SetFont(d, LeaPlusLC["LeaPlusQuestFontSize"], f)
			end

			-- Set text size when slider changes and on startup
			LeaPlusCB["LeaPlusQuestFontSize"]:HookScript("OnValueChanged", QuestSizeUpdate)
			QuestSizeUpdate()

			-- Help button hidden
			QuestTextPanel.h:Hide()

			-- Back button handler
			QuestTextPanel.b:SetScript("OnClick", function()
				QuestTextPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page4"]:Show()
				return
			end)

			-- Reset button handler
			QuestTextPanel.r:SetScript("OnClick", function()

				-- Reset slider
				LeaPlusLC["LeaPlusQuestFontSize"] = 12
				QuestSizeUpdate()

				-- Refresh side panel
				QuestTextPanel:Hide(); QuestTextPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["QuestTextBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["LeaPlusQuestFontSize"] = 18
					QuestSizeUpdate()
				else
					QuestTextPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Show durability status
		----------------------------------------------------------------------

		if LeaPlusLC["DurabilityStatus"] == "On" then

			-- Create durability button
			local cButton = CreateFrame("BUTTON", nil, PaperDollFrame)
			cButton:ClearAllPoints()
			cButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", -2, -1)
			cButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
			cButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			cButton:SetSize(32, 32)

			-- Create durability tables
			local Slots = {"HeadSlot", "ShoulderSlot", "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot"}
			local SlotsFriendly = {INVTYPE_HEAD, INVTYPE_SHOULDER, INVTYPE_CHEST, INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND}

			-- Show durability status in tooltip or status line (tip or status)
			local function ShowDuraStats(where)

				local duravaltotal, duramaxtotal, durapercent = 0, 0, 0
				local valcol, id, duraval, duramax

				if where == "tip" then
					-- Creare layout
					GameTooltip:AddLine("|cffffffff")
					GameTooltip:AddLine("|cffffffff")
					GameTooltip:AddLine("|cffffffff")
					_G["GameTooltipTextLeft1"]:SetText("|cffffffff"); _G["GameTooltipTextRight1"]:SetText("|cffffffff")
					_G["GameTooltipTextLeft2"]:SetText("|cffffffff"); _G["GameTooltipTextRight2"]:SetText("|cffffffff")
					_G["GameTooltipTextLeft3"]:SetText("|cffffffff"); _G["GameTooltipTextRight3"]:SetText("|cffffffff")
				end

				local validItems = false

				-- Traverse equipment slots
				for k, slotName in ipairs(Slots) do
					if C_PaperDollInfo.GetInventorySlotInfo(slotName) then
						id = C_PaperDollInfo.GetInventorySlotInfo(slotName)
						duraval, duramax = GetInventoryItemDurability(id)
						if duraval ~= nil then

							-- At least one item has durability stat
							validItems = true

							-- Add to tooltip
							if where == "tip" then
								durapercent = tonumber(format("%.0f", duraval / duramax * 100))
								valcol = (durapercent >= 80 and "|cff00FF00") or (durapercent >= 60 and "|cff99FF00") or (durapercent >= 40 and "|cffFFFF00") or (durapercent >= 20 and "|cffFF9900") or (durapercent >= 0 and "|cffFF2000") or ("|cffFFFFFF")
								_G["GameTooltipTextLeft1"]:SetText(L["Durability"])
								_G["GameTooltipTextLeft2"]:SetText(_G["GameTooltipTextLeft2"]:GetText() .. SlotsFriendly[k] .. "|n")
								_G["GameTooltipTextRight2"]:SetText(_G["GameTooltipTextRight2"]:GetText() ..  valcol .. durapercent .. "%" .. "|r|n")
							end

							duravaltotal = duravaltotal + duraval
							duramaxtotal = duramaxtotal + duramax
						end
					end
				end
				if duravaltotal > 0 and duramaxtotal > 0 then
					durapercent = duravaltotal / duramaxtotal * 100
				else
					durapercent = 0
				end

				if where == "tip" then

					if validItems == true then
						-- Show overall durability in the tooltip
						if durapercent >= 80 then valcol = "|cff00FF00"	elseif durapercent >= 60 then valcol = "|cff99FF00"	elseif durapercent >= 40 then valcol = "|cffFFFF00"	elseif durapercent >= 20 then valcol = "|cffFF9900"	elseif durapercent >= 0 then valcol = "|cffFF2000" else return end
						_G["GameTooltipTextLeft3"]:SetText(L["Overall"] .. " " .. valcol)
						_G["GameTooltipTextRight3"]:SetText(valcol .. string.format("%.0f", durapercent) .. "%")

						-- Show lines of the tooltip
						GameTooltipTextLeft1:Show(); GameTooltipTextRight1:Show()
						GameTooltipTextLeft2:Show(); GameTooltipTextRight2:Show()
						GameTooltipTextLeft3:Show(); GameTooltipTextRight3:Show()
						GameTooltipTextRight2:SetJustifyH"RIGHT";
						GameTooltipTextRight3:SetJustifyH"RIGHT";
						GameTooltip:Show()
					else
						-- No items have durability stat
						GameTooltip:ClearLines()
						GameTooltip:AddLine("" .. L["Durability"],1.0, 0.85, 0.0)
						GameTooltip:AddLine("" .. L["No items with durability equipped."], 1, 1, 1)
						GameTooltip:Show()
					end

				elseif where == "status" then
					if validItems == true then
						-- Show simple status line instead
						if tonumber(durapercent) >= 0 then -- Ensure character has some durability items equipped
							LeaPlusLC:Print(L["You have"] .. " " .. string.format("%.0f", durapercent) .. "%" .. " " .. L["durability"] .. ".")
						end
					end

				end
			end

			-- Hover over the durability button to show the durability tooltip
			cButton:SetScript("OnEnter", function()
				GameTooltip:SetOwner(cButton, "ANCHOR_RIGHT")
				GameTooltip:SetMinimumWidth(0) -- Needed due to MoP mage reset specialisation and choose frost
				ShowDuraStats("tip")
			end)
			cButton:SetScript("OnLeave", GameTooltip_Hide)

			-- Create frame to watch events
			local DeathDura = CreateFrame("FRAME")
			DeathDura:RegisterEvent("PLAYER_DEAD")
			DeathDura:SetScript("OnEvent", function(self, event)
				ShowDuraStats("status")
				DeathDura:UnregisterEvent("PLAYER_DEAD")
				C_Timer.After(2, function()
					DeathDura:RegisterEvent("PLAYER_DEAD")
				end)
			end)

			hooksecurefunc("AcceptResurrect", function()
				-- Player has ressed without releasing
				ShowDuraStats("status")
			end)

		end

		----------------------------------------------------------------------
		--	Hide zone text
		----------------------------------------------------------------------

		if LeaPlusLC["HideZoneText"] == "On" then
			ZoneTextFrame:SetScript("OnShow", ZoneTextFrame.Hide);
			SubZoneTextFrame:SetScript("OnShow", SubZoneTextFrame.Hide);
		end

		----------------------------------------------------------------------
		--	Disable sticky chat
		----------------------------------------------------------------------

		if LeaPlusLC["NoStickyChat"] == "On" and not LeaLockList["NoStickyChat"] then
			-- These taint if set to anything other than nil
			ChatTypeInfo.WHISPER.sticky = nil
			ChatTypeInfo.BN_WHISPER.sticky = nil
			ChatTypeInfo.CHANNEL.sticky = nil
		end

		----------------------------------------------------------------------
		--	Hide stance bar
		----------------------------------------------------------------------

		if LeaPlusLC["NoClassBar"] == "On" and not LeaLockList["NoClassBar"] then
			local stancebar = CreateFrame("FRAME", nil, UIParent)
			stancebar:Hide()
			StanceBar:UnregisterAllEvents()
			StanceBar:SetParent(stancebar)
		end

		----------------------------------------------------------------------
		--	Disable chat fade
		----------------------------------------------------------------------

		if LeaPlusLC["NoChatFade"] == "On" and not LeaLockList["NoChatFade"] then
			-- Process normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i]:SetFading(false)
				end
			end
			-- Process temporary frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf]:SetFading(false)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Use easy chat frame resizing
		----------------------------------------------------------------------

		if LeaPlusLC["UseEasyChatResizing"] == "On" and not LeaLockList["UseEasyChatResizing"] then
			ChatFrame1Tab:HookScript("OnMouseDown", function(self,arg1)
				if arg1 == "LeftButton" then
					if select(8, GetChatWindowInfo(1)) then
						ChatFrame1:StartSizing("TOP")
					end
				end
			end)
			ChatFrame1Tab:SetScript("OnMouseUp", function(self,arg1)
				if arg1 == "LeftButton" then
					ChatFrame1:StopMovingOrSizing()
					FCF_SavePositionAndDimensions(ChatFrame1)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Hide error messages
		----------------------------------------------------------------------

		if LeaPlusLC["HideErrorMessages"] == "On" then

			--	Error message events
			local OrigErrHandler = UIErrorsFrame:GetScript('OnEvent')
			UIErrorsFrame:SetScript('OnEvent', function (self, event, id, err, ...)
				if event == "UI_ERROR_MESSAGE" then
					-- Hide error messages
					if LeaPlusLC["ShowErrorsFlag"] == 1 then
						if 	err == ERR_INV_FULL or
							err == ERR_QUEST_LOG_FULL or
							err == ERR_RAID_GROUP_ONLY	or
							err == ERR_PARTY_LFG_BOOT_LIMIT or
							err == ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE or
							err == ERR_PARTY_LFG_BOOT_IN_COMBAT or
							err == ERR_PARTY_LFG_BOOT_IN_PROGRESS or
							err == ERR_PARTY_LFG_BOOT_LOOT_ROLLS or
							err == ERR_PARTY_LFG_TELEPORT_IN_COMBAT or
							err == ERR_PET_SPELL_DEAD or
							err == ERR_PLAYER_DEAD or
							err == SPELL_FAILED_TARGET_NO_POCKETS or
							err == ERR_ALREADY_PICKPOCKETED or
							err:find(format(ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S, ".+")) then
								return OrigErrHandler(self, event, id, err, ...)
						end
					else
						return OrigErrHandler(self, event, id, err, ...)
					end
				elseif event == 'UI_INFO_MESSAGE'  then
					-- Show information messages
					return OrigErrHandler(self, event, id, err, ...)
				end
			end)

			-- Hide ping system errors
			UIParent:UnregisterEvent("PING_SYSTEM_ERROR")

		end

		----------------------------------------------------------------------
		-- Easy item destroy
		----------------------------------------------------------------------

		if LeaPlusLC["EasyItemDestroy"] == "On" then

			-- Get the type "DELETE" into the field to confirm text
			local TypeDeleteLine = gsub(DELETE_GOOD_ITEM, "[\r\n]", "@")
			local void, TypeDeleteLine = strsplit("@", TypeDeleteLine, 2)

			-- Add hyperlinks to regular item destroy
			-- Taint previously in Midnight: Enter Stockade, loot junk, go vendor with transmog items Lisbeth Schneider 58.2 67.0 Stormwind, auto sell, close and shift reopen
			StaticPopupDialogs["DELETE_ITEM"].OnHyperlinkEnter = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkEnter
			StaticPopupDialogs["DELETE_ITEM"].OnHyperlinkLeave = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkLeave
			StaticPopupDialogs["DELETE_QUEST_ITEM"].OnHyperlinkEnter = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkEnter
			StaticPopupDialogs["DELETE_QUEST_ITEM"].OnHyperlinkLeave = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkLeave
			StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"].OnHyperlinkEnter = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkEnter
			StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"].OnHyperlinkLeave = StaticPopupDialogs["DELETE_GOOD_ITEM"].OnHyperlinkLeave

			-- Hide editbox and set item link
			local easyDelFrame = CreateFrame("FRAME")
			easyDelFrame:RegisterEvent("DELETE_ITEM_CONFIRM")
			easyDelFrame:SetScript("OnEvent", function()
				if StaticPopup1EditBox:IsShown() then
					-- Item requires player to type delete so hide editbox and show link
					StaticPopup1EditBox:Hide()
					StaticPopup1Button1:Enable()
					local link = select(3, GetCursorInfo())
					if link then
						-- Custom link for battle pets
						local linkType, linkOptions, name = LinkUtil.ExtractLink(link)
						if linkType == "battlepet" then
							local speciesID, level, breedQuality = strsplit(":", linkOptions)
							local qualityColor = BAG_ITEM_QUALITY_COLORS[tonumber(breedQuality)]
							link = qualityColor:WrapTextInColorCode(name .. " (" .. L["Level"] .. " " .. level .. ")")
						end
						StaticPopup1Text:SetText(gsub(StaticPopup1Text:GetText(), gsub(TypeDeleteLine, "@", ""), "") .. link)
					end
				else
					-- Item does not require player to type delete so just show item link
					StaticPopup1:SetHeight(StaticPopup1:GetHeight() + 40)
					StaticPopup1EditBox:Hide()
					StaticPopup1Button1:Enable()
					local link = select(3, GetCursorInfo())
					if link then
						-- Custom link for battle pets
						local linkType, linkOptions, name = LinkUtil.ExtractLink(link)
						if linkType == "battlepet" then
							local speciesID, level, breedQuality = strsplit(":", linkOptions)
							local qualityColor = BAG_ITEM_QUALITY_COLORS[tonumber(breedQuality)]
							link = qualityColor:WrapTextInColorCode(name .. " (" .. L["Level"] .. " " .. level .. ")")
						end
						StaticPopup1Text:SetText(gsub(StaticPopup1Text:GetText(), gsub(TypeDeleteLine, "@", ""), "") .. "|n|n" .. link .. "|n|n")
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Unclamp chat frame
		----------------------------------------------------------------------

		if LeaPlusLC["UnclampChat"] == "On" and not LeaLockList["UnclampChat"] then

			-- Process normal and existing chat frames on startup
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i]:SetClampedToScreen(false)
					_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0)
				end
			end

			-- Process new chat frames and combat log
			hooksecurefunc("FloatingChatFrame_UpdateBackgroundAnchors", function(self)
				self:SetClampRectInsets(0, 0, 0, 0)
			end)

			-- Process temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf]:SetClampRectInsets(0, 0, 0, 0)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Keep audio synced
		----------------------------------------------------------------------

		if LeaPlusLC["KeepAudioSynced"] == "On" then

			SetCVar("Sound_OutputDriverIndex", "0")
			local event = CreateFrame("FRAME")
			event:RegisterEvent("VOICE_CHAT_OUTPUT_DEVICES_UPDATED")
			event:SetScript("OnEvent", function()
				if not CinematicFrame:IsShown() and not MovieFrame:IsShown() then -- Dont restart sound system during cinematic
					SetCVar("Sound_OutputDriverIndex", "0")
					Sound_GameSystem_RestartSoundSystem()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Mute custom sounds (no reload required)
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local MuteCustomPanel = LeaPlusLC:CreatePanel("Mute custom sounds", "MuteCustomPanel")

			local titleTX = LeaPlusLC:MakeTx(MuteCustomPanel, "Editor", 16, -72)
			titleTX:SetWidth(534)
			titleTX:SetWordWrap(false)
			titleTX:SetJustifyH("LEFT")

			-- Show help button for title
			LeaPlusLC:CreateHelpButton("MuteGameSoundsCustomHelpButton", MuteCustomPanel, titleTX, "Enter sound file IDs separated by comma then click the Mute button.|n|nIf you wish, you can enter a brief note for each file ID but do not include numbers in your notes.|n|nFor example, you can enter 'DevAura 569679, RetAura 568744' to mute the Devotion Aura and Retribution Aura spells.|n|nUse Leatrix Sounds to find, test and play sound file IDs.")

			-- Add large editbox
			local eb = CreateFrame("Frame", nil, MuteCustomPanel, "BackdropTemplate")
			eb:SetSize(548, LeaPlusLC.MainPanelHeight - 180)
			eb:SetPoint("TOPLEFT", 10, -92)
			eb:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
				edgeSize = 16,
				insets = { left = 8, right = 6, top = 8, bottom = 8 },
			})
			eb:SetBackdropBorderColor(1.0, 0.85, 0.0, 0.5)

			eb.scroll = CreateFrame("ScrollFrame", nil, eb, "LeaPlusMuteCustomSoundsScrollFrameTemplate")
			eb.scroll:SetPoint("TOPLEFT", eb, 12, -10)
			eb.scroll:SetPoint("BOTTOMRIGHT", eb, -30, 10)
			eb.scroll:SetPanExtent(16)

			-- Create character count
			eb.scroll.CharCount = eb.scroll:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			eb.scroll.CharCount:Hide()

			eb.Text = eb.scroll.EditBox
			eb.Text:SetWidth(494)
			eb.Text:SetHeight(230)
			eb.Text:SetPoint("TOPLEFT", eb.scroll)
			eb.Text:SetPoint("BOTTOMRIGHT", eb.scroll, -12, 0)
			eb.Text:SetMaxLetters(2000)
			eb.Text:SetFontObject(GameFontNormalLarge)
			eb.Text:SetAutoFocus(false)
			eb.scroll:SetScrollChild(eb.Text)

			-- Set focus on the editbox text when clicking the editbox
			eb:SetScript("OnMouseDown", function()
				eb.Text:SetFocus()
				eb.Text:SetCursorPosition(eb.Text:GetMaxLetters())
			end)

			-- Function to save the custom sound list
			local function SaveString(self, userInput)
				local keytext = eb.Text:GetText()
				if keytext and keytext ~= "" then
					LeaPlusLC["MuteCustomList"] = strtrim(eb.Text:GetText())
				else
					LeaPlusLC["MuteCustomList"] = ""
				end
			end

			-- Save the custom sound list when it changes and at startup
			eb.Text:SetScript("OnTextChanged", SaveString)
			eb.Text:SetText(LeaPlusLC["MuteCustomList"])
			SaveString()

			-- Help button hidden
			MuteCustomPanel.h:Hide()

			-- Back button handler
			MuteCustomPanel.b:SetScript("OnClick", function()
				MuteCustomPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
				return
			end)

			-- Reset button hidden
			MuteCustomPanel.r:Hide()

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["MuteCustomSoundsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["MuteCustomList"] = "Devotion Aura 569679, Retribution Aura 568744"
					eb.Text:SetText(LeaPlusLC["MuteCustomList"])
				else
					MuteCustomPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Function to mute custom sound list
			local function MuteCustomListFunc(unmute, userInput)
				-- local mutedebug = true -- Debug
				local counter = 0
				local muteString = LeaPlusLC["MuteCustomList"]
				if muteString and muteString ~= "" then
					muteString = muteString:gsub("%s", ",")
					muteString = muteString:gsub("[\n]", ",")
					muteString = muteString:gsub("[^,%d]", "")
					if mutedebug then print(muteString) end
					local tList = {strsplit(",", muteString)}
					if mutedebug then ChatFrame1:Clear() end
					for i = 1, #tList do
						if tList[i] then
							tList[i] = tonumber(tList[i])
							if tList[i] and tList[i] < 20000000 then
								if mutedebug then print(tList[i]) end
								if unmute then
									UnmuteSoundFile(tList[i])
								else
									MuteSoundFile(tList[i])
								end
								counter = counter + 1
							end
						end
					end
					if userInput then
						if unmute then
							if counter == 1 then
								LeaPlusLC:Print(L["Unmuted"] .. " " .. counter .. " " .. L["sound"] .. ".")
							else
								LeaPlusLC:Print(L["Unmuted"] .. " " .. counter .. " " .. L["sounds"] .. ".")
							end
						else
							if counter == 1 then
								LeaPlusLC:Print(L["Muted"] .. " " .. counter .. " " .. L["sound"] .. ".")
							else
								LeaPlusLC:Print(L["Muted"] .. " " .. counter .. " " .. L["sounds"] .. ".")
							end
						end
					end
				end
			end

			-- Mute custom list on startup if option is enabled
			if LeaPlusLC["MuteCustomSounds"] == "On" then
				MuteCustomListFunc()
			end

			-- Mute or unmute when option is clicked
			LeaPlusCB["MuteCustomSounds"]:HookScript("OnClick", function()
				if LeaPlusLC["MuteCustomSounds"] == "On" then
					MuteCustomListFunc(false, false)
				else
					MuteCustomListFunc(true, false)
				end
			end)

			-- Add mute button
			local MuteCustomNowButton = LeaPlusLC:CreateButton("MuteCustomNowButton", MuteCustomPanel, "Mute", "BOTTOMLEFT", 16, 53, 0, 25, true, "Click to mute sounds in the list.")
			LeaPlusCB["MuteCustomNowButton"]:SetScript("OnClick", function() MuteCustomListFunc(false, true) end)

			-- Add unmute button
			local UnmuteCustomNowButton = LeaPlusLC:CreateButton("UnmuteCustomNowButton", MuteCustomPanel, "Unmute", "BOTTOMLEFT", 16, 53, 0, 25, true, "Click to unmute sounds in the list.")
			LeaPlusCB["UnmuteCustomNowButton"]:ClearAllPoints()
			LeaPlusCB["UnmuteCustomNowButton"]:SetPoint("LEFT", MuteCustomNowButton, "RIGHT", 10, 0)
			LeaPlusCB["UnmuteCustomNowButton"]:SetScript("OnClick", function() MuteCustomListFunc(true, true) end)

			----------------------------------------------------------------------
			-- Sound finder
			----------------------------------------------------------------------

			do

				-- Create configuration panel
				local SoundFinderPanel = LeaPlusLC:CreatePanel("Mute custom sounds", "SoundFinderPanel")

				-- Locals
				local SoundMax = 9000000
				local lo, hi, mid, found
				local history = {}
				local queue = {}
				local playHandle
				local queueTotal, queueDone = 0, 0
				local restarted, restartWhenDone, allMuted
				local foundText = ""

				-- Add sound finder button to the mute custom sounds panel (left of the back to main menu button)
				local MuteCustomFindButton = LeaPlusLC:CreateButton("MuteCustomFindButton", MuteCustomPanel, "Sound Finder", "BOTTOMLEFT", 16, 53, 0, 25, true, "Click to toggle the sound finder.")
				LeaPlusCB["MuteCustomFindButton"]:ClearAllPoints()
				LeaPlusCB["MuteCustomFindButton"]:SetPoint("RIGHT", MuteCustomPanel.b, "LEFT", -10, 0)
				LeaPlusCB["MuteCustomFindButton"]:SetScript("OnClick", function()
					SoundFinderPanel:Show(); MuteCustomPanel:Hide()
					return
				end)

				-- Add second sound finder button to the sound finder panel (same position as the first one)
				local MuteCustomFindButton2 = LeaPlusLC:CreateButton("MuteCustomFindButton2", SoundFinderPanel, "Sound Finder", "BOTTOMLEFT", 16, 53, 0, 25, true, "Click to toggle the sound finder.")
				LeaPlusCB["MuteCustomFindButton2"]:ClearAllPoints()
				LeaPlusCB["MuteCustomFindButton2"]:SetPoint("RIGHT", SoundFinderPanel.b, "LEFT", -10, 0)
				LeaPlusCB["MuteCustomFindButton2"]:SetScript("OnClick", function()
					SoundFinderPanel:Hide(); MuteCustomPanel:Show()
					return
				end)

				-- Panel contents
				local titleTX = LeaPlusLC:MakeTx(SoundFinderPanel, "Sound finder", 16, -72)
				LeaPlusLC:CreateHelpButton("SoundFinderHelpButton", SoundFinderPanel, titleTX, "The sound finder lets you find the file ID of a sound that is playing in game.|n|nPlay the sound you want to find and click the start button.  Each step mutes half of the remaining sound files.  Click the heard button if you can still hear the sound or the silent button if you cannot.|n|nFor sound effects (such as an ability or emote), play the sound again after each step.  For music or ambience, click the sound system restart button after each step.|n|nWhen the sound file is found, its ID is shown in the editbox on the right so that you can copy it.")

				local status = LeaPlusLC:MakeWD(SoundFinderPanel, "", 16, -96)
				local prompt = LeaPlusLC:MakeWD(SoundFinderPanel, "", 16, -116)

				-- Step progress bar (gold gradient fill with a border, a spark at the fill edge and a shine that sweeps across the fill)
				local bar = CreateFrame("StatusBar", nil, SoundFinderPanel)
				bar:SetSize(538, 22)
				bar:SetPoint("TOPLEFT", 16, -140)
				bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
				bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0.85, 0.45, 0, 1), CreateColor(1, 0.9, 0.3, 1))
				bar:SetMinMaxValues(0, 1)
				bar:SetValue(0)
				bar.value, bar.target = 0, 0

				bar.bg = bar:CreateTexture(nil, "BACKGROUND")
				bar.bg:SetAllPoints()
				bar.bg:SetColorTexture(0, 0, 0, 0.6)

				-- Border
				bar.border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
				bar.border:SetPoint("TOPLEFT", -4, 4)
				bar.border:SetPoint("BOTTOMRIGHT", 4, -4)
				bar.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12})
				bar.border:SetBackdropBorderColor(1, 0.82, 0, 0.8)
				bar.border:SetFrameLevel(bar:GetFrameLevel() + 3)

				-- Shine (clipped to the filled part of the bar)
				bar.clip = CreateFrame("Frame", nil, bar)
				bar.clip:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPLEFT")
				bar.clip:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT")
				bar.clip:SetClipsChildren(true)
				bar.shineL = bar.clip:CreateTexture(nil, "OVERLAY")
				bar.shineL:SetTexture("Interface\\Buttons\\WHITE8X8")
				bar.shineL:SetSize(30, 22)
				bar.shineL:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, 0.45))
				bar.shineR = bar.clip:CreateTexture(nil, "OVERLAY")
				bar.shineR:SetTexture("Interface\\Buttons\\WHITE8X8")
				bar.shineR:SetSize(30, 22)
				bar.shineR:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.45), CreateColor(1, 1, 1, 0))
				bar.shineR:SetPoint("LEFT", bar.shineL, "RIGHT")
				bar.shineX = -60

				-- Spark at the edge of the fill
				bar.spark = bar:CreateTexture(nil, "OVERLAY")
				bar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
				bar.spark:SetBlendMode("ADD")
				bar.spark:SetSize(24, 44)
				bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

				bar.text = bar.border:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				bar.text:SetPoint("CENTER")

				-- Animate the bar (fill slides to the new value and the shine sweeps across)
				bar:SetScript("OnUpdate", function(self, elapsed)
					-- Slide fill towards target
					if self.value ~= self.target then
						local step = elapsed * 2
						if math.abs(self.target - self.value) <= step then self.value = self.target
						elseif self.target > self.value then self.value = self.value + step
						else self.value = self.value - step end
						self:SetValue(self.value)
					end
					-- Spark only shows while the bar is part filled
					self.spark:SetShown(self.value > 0 and self.value < 1)
					-- Sweep the shine across the fill
					self.shineX = self.shineX + elapsed * 160
					if self.shineX > 538 + 200 then self.shineX = -60 end
					self.shineL:SetPoint("LEFT", self.clip, "LEFT", self.shineX, 0)
				end)

				-- Start, heard it and silent buttons
				local startBtn = LeaPlusLC:CreateButton("SoundFinderStartButton", SoundFinderPanel, "Start", "TOPLEFT", 16, -170, 0, 25, true, "Click to start a new search.")
				local heardBtn = LeaPlusLC:CreateButton("SoundFinderHeardButton", SoundFinderPanel, "Heard it", "TOPLEFT", 0, 0, 0, 25, true, "Click if you can still hear the sound.")
				heardBtn:ClearAllPoints(); heardBtn:SetPoint("LEFT", startBtn, "RIGHT", 10, 0)
				local silentBtn = LeaPlusLC:CreateButton("SoundFinderSilentButton", SoundFinderPanel, "Silent", "TOPLEFT", 0, 0, 0, 25, true, "Click if you can no longer hear the sound.")
				silentBtn:ClearAllPoints(); silentBtn:SetPoint("LEFT", heardBtn, "RIGHT", 10, 0)
				local undoBtn = LeaPlusLC:CreateButton("SoundFinderUndoButton", SoundFinderPanel, "Undo", "TOPLEFT", 0, 0, 0, 25, true, "Click to undo your last heard it or silent answer.")
				undoBtn:ClearAllPoints(); undoBtn:SetPoint("LEFT", silentBtn, "RIGHT", 10, 0)

				-- Add icons to the start, heard it and silent buttons (button text is moved right to make room)
				for i, v in pairs({{startBtn, "common-search-magnifyingglass"}, {heardBtn, "lootroll-icon-checkmark"}, {silentBtn, "auctionhouse-ui-filter-redx"}, {undoBtn, "common-icon-undo"}}) do
					local btn, atlas = v[1], v[2]
					btn.icon = btn:CreateTexture(nil, "OVERLAY")
					btn.icon:SetSize(14, 14)
					btn.icon:SetPoint("LEFT", 8, 0)
					btn.icon:SetAtlas(atlas)
					btn:SetWidth(btn:GetWidth() + 16)
					btn:GetFontString():ClearAllPoints()
					btn:GetFontString():SetPoint("CENTER", 8, 0)
				end

				-- Function to create a small icon button
				local function MakeIconButton(atlas, tip)
					local btn = CreateFrame("Button", nil, SoundFinderPanel)
					btn:SetSize(24, 24)
					btn.icon = btn:CreateTexture(nil, "ARTWORK")
					btn.icon:SetAllPoints()
					btn.icon:SetAtlas(atlas)
					btn.icon:SetVertexColor(1, 0.82, 0)
					btn.tiptext = L[tip]
					btn:SetScript("OnEnter", function(self)
						self.icon:SetVertexColor(1, 1, 1)
						LeaPlusLC.TipSee(self)
					end)
					btn:SetScript("OnLeave", function(self)
						self.icon:SetVertexColor(1, 0.82, 0)
						GameTooltip:Hide()
					end)
					btn:SetScript("OnMouseDown", function(self) self.icon:SetPoint("TOPLEFT", 1, -1); self.icon:SetPoint("BOTTOMRIGHT", 1, -1) end)
					btn:SetScript("OnMouseUp", function(self) self.icon:SetAllPoints() end)
					return btn
				end

				-- Restart sound system, mute all and unmute all buttons (right side of the button row)
				local unmuteAllBtn = MakeIconButton("voicechat-icon-speaker", "Click to unmute every sound file in the game.  This ends the current search and also unmutes sounds muted by Leatrix Plus or other addons (reload your UI to restore them).")
				unmuteAllBtn:SetPoint("TOPRIGHT", -16, -170)
				local muteAllBtn = MakeIconButton("voicechat-icon-speaker-mute", "Click to mute every sound file in the game.  This ends the current search and sounds stay muted when the panel is closed.")
				muteAllBtn:SetPoint("RIGHT", unmuteAllBtn, "LEFT", -8, 0)
				local restartBtn = MakeIconButton("UI-RefreshButton", "Click to restart the sound system.  Use this after each step if you are looking for music or ambience (sounds that are already playing are not muted until the sound system is restarted).")
				restartBtn:SetPoint("RIGHT", muteAllBtn, "LEFT", -8, 0)

				-- Sound file ID editbox (read only, text is highlighted so it can be copied) and play button (top right above the progress bar)
				local playBtn = LeaPlusLC:CreateButton("SoundFinderPlayButton", SoundFinderPanel, "Play", "TOPRIGHT", -16, -108, 0, 25, true, "Click to play the sound file that was found.")
				local idBox = LeaPlusLC:CreateEditBox("SoundFinderIDBox", SoundFinderPanel, 116, 10, "TOPLEFT", 0, 0, "SoundFinderIDBox", "SoundFinderIDBox")
				idBox:ClearAllPoints(); idBox:SetPoint("RIGHT", playBtn, "LEFT", -10, 0)
				local idTitle = LeaPlusLC:MakeTx(SoundFinderPanel, "Sound file ID", 0, 0)
				idTitle:ClearAllPoints()
				idTitle:SetPoint("TOPLEFT", idBox, "TOPLEFT", -4, 16)
				idBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
				idBox:SetScript("OnMouseUp", function(self) self:HighlightText() end)
				idBox:SetScript("OnTextChanged", function(self, userInput)
					if userInput then
						self:SetText(foundText)
						self:HighlightText()
					end
				end)

				-- Function to update the step progress bar (steps answered and steps left)
				local function UpdateBar()
					local done, total = 0, math.ceil(math.log(SoundMax) / math.log(2))
					if lo then
						done = #history - 1
						if found then total = done else total = done + math.ceil(math.log(hi - lo + 1) / math.log(2)) end
					end
					bar.target = total > 0 and done / total or 0
					bar.text:SetText(L["Step"] .. " " .. done .. " / " .. total)
				end

				-- Function to update the panel
				local function UpdatePanel()
					UpdateBar()
					local busy = #queue > 0
					if busy then
						status:SetText(L["Please wait..."] .. " |cffffffff" .. math.floor(queueDone / queueTotal * 100) .. "%")
						prompt:SetText("")
					elseif found then
						foundText = tostring(lo)
						idBox:SetText(foundText)
						status:SetText(L["Sound file found"] .. ": |cffffffff" .. foundText)
						prompt:SetText(L["Click Play to check it."])
					elseif lo then
						status:SetText(L["Searching"] .. " |cffffffff" .. lo .. " - " .. hi .. "|r (" .. (hi - lo + 1) .. ")")
						prompt:SetText(L["Can you still hear the sound?"])
					else
						status:SetText(L["Play the sound you want to find."])
						prompt:SetText(L["Then click Start."])
					end
					LeaPlusLC:LockItem(startBtn, busy)
					LeaPlusLC:LockItem(heardBtn, busy or not lo or found)
					LeaPlusLC:LockItem(silentBtn, busy or not lo or found)
					LeaPlusLC:LockItem(undoBtn, busy or not lo or #history < 2)
					LeaPlusLC:LockItem(restartBtn, busy)
					LeaPlusLC:LockItem(muteAllBtn, busy)
					LeaPlusLC:LockItem(unmuteAllBtn, busy)
					LeaPlusLC:LockItem(playBtn, foundText == "")
					LeaPlusLC:LockItem(idBox, foundText == "")
				end

				-- Worker frame to mute and unmute sound files in small chunks each frame (prevents the game from freezing)
				local worker = CreateFrame("FRAME")
				worker:Hide()
				worker:SetScript("OnUpdate", function()
					local stopTime = debugprofilestop() + 8
					while queue[1] and debugprofilestop() < stopTime do
						local job = queue[1]
						local func = job.mute and MuteSoundFile or UnmuteSoundFile
						local last = math.min(job.first + 4999, job.last)
						for i = job.first, last do
							func(i)
						end
						queueDone = queueDone + last - job.first + 1
						job.first = last + 1
						if job.first > job.last then tremove(queue, 1) end
					end
					if not queue[1] then
						-- Queue finished (restart sound system if it was restarted during a search that has now been closed)
						worker:Hide()
						queueTotal, queueDone = 0, 0
						if restartWhenDone then
							restartWhenDone = false
							Sound_GameSystem_RestartSoundSystem()
						end
					end
					if SoundFinderPanel:IsShown() then UpdatePanel() end
				end)

				-- Function to queue a range of sound files to mute or unmute
				local function SetMuted(first, last, mute)
					tinsert(queue, {first = first, last = last, mute = mute})
					queueTotal = queueTotal + last - first + 1
					worker:Show()
				end

				-- Function to reverse all steps (unmutes everything the finder muted)
				local function ResetSteps()
					for i = #history, 1, -1 do
						local entry = history[i]
						if entry.first then SetMuted(entry.first, entry.last, not entry.mute) end
					end
					wipe(history)
					lo, hi, mid, found = nil, nil, nil, false
				end

				-- Restart button
				restartBtn:SetScript("OnClick", function()
					restarted = true
					Sound_GameSystem_RestartSoundSystem()
				end)

				-- Mute all button (ends the search without reversing it as everything is muted anyway)
				muteAllBtn:SetScript("OnClick", function()
					wipe(history)
					lo, hi, mid, found = nil, nil, nil, false
					allMuted = true
					SetMuted(1, SoundMax, true)
					UpdatePanel()
				end)

				-- Unmute all button (ends the search without reversing it as everything is unmuted anyway)
				unmuteAllBtn:SetScript("OnClick", function()
					wipe(history)
					lo, hi, mid, found = nil, nil, nil, false
					allMuted = false
					SetMuted(1, SoundMax, false)
					UpdatePanel()
				end)

				-- Start button (mute the upper half of all sound files)
				startBtn:SetScript("OnClick", function()
					ResetSteps()
					foundText = ""
					idBox:SetText("")
					lo, hi, found = 1, SoundMax, false
					mid = math.floor((lo + hi) / 2)
					if allMuted then
						-- Everything is muted so unmute the lower half instead
						tinsert(history, {first = lo, last = mid, mute = false})
						SetMuted(lo, mid, false)
					else
						tinsert(history, {first = mid + 1, last = hi, mute = true})
						SetMuted(mid + 1, hi, true)
					end
					UpdatePanel()
				end)

				-- Heard it button (sound is in the lower half so mute the upper half of that)
				heardBtn:SetScript("OnClick", function()
					local entry = {lo = lo, hi = hi, mid = mid}
					hi = mid
					if lo == hi then
						found = true
					else
						mid = math.floor((lo + hi) / 2)
						entry.first, entry.last, entry.mute = mid + 1, hi, true
						SetMuted(mid + 1, hi, true)
					end
					tinsert(history, entry)
					UpdatePanel()
				end)

				-- Silent button (sound is in the muted upper half so unmute the lower half of that)
				silentBtn:SetScript("OnClick", function()
					local entry = {lo = lo, hi = hi, mid = mid}
					lo = mid + 1
					if lo == hi then
						found = true
						entry.first, entry.last, entry.mute = lo, lo, false
					else
						mid = math.floor((lo + hi) / 2)
						entry.first, entry.last, entry.mute = lo, mid, false
					end
					SetMuted(entry.first, entry.last, false)
					tinsert(history, entry)
					UpdatePanel()
				end)

				-- Undo button (reverses the last heard it or silent answer)
				undoBtn:SetScript("OnClick", function()
					if #history < 2 then return end
					local entry = tremove(history)
					if entry.first then SetMuted(entry.first, entry.last, not entry.mute) end
					lo, hi, mid = entry.lo, entry.hi, entry.mid
					if found then
						found = false
						foundText = ""
						idBox:SetText("")
						if playHandle then StopSound(playHandle); playHandle = nil end
					end
					UpdatePanel()
				end)

				-- Play button
				playBtn:SetScript("OnClick", function()
					idBox:ClearFocus()
					local soundID = tonumber(foundText)
					if not soundID then return end
					if playHandle then StopSound(playHandle) end
					local willPlay
					willPlay, playHandle = PlaySoundFile(soundID, "Master")
					if not willPlay then LeaPlusLC:Print(L["Sound file could not be played"] .. ": |cffffffff" .. foundText) end
				end)

				-- Bubbles that float up the panel (they rise faster while sound files are being muted)
				local bubbles = {}
				local bubbleTop, bubbleBottom = LeaPlusLC.MainPanelHeight - 68, 48
				for i = 1, 24 do
					local b = SoundFinderPanel:CreateTexture(nil, "BORDER", nil, 7)
					b:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
					b:SetVertexColor(0.6, 0.85, 1)
					bubbles[i] = b
				end

				-- Function to send a bubble back to the bottom of the panel
				local function ResetBubble(b, anywhere)
					b.size = math.random(4, 14)
					b.x = math.random(12, 556 - b.size)
					b.y = anywhere and math.random(bubbleBottom, bubbleTop) or bubbleBottom - b.size
					b.speed = math.random(12, 32)
					b.wobble = math.random(2, 6)
					b.phase = math.random() * 6.28
					b:SetSize(b.size, b.size)
				end
				for i, b in ipairs(bubbles) do ResetBubble(b, true) end

				-- Move bubbles each frame
				SoundFinderPanel:SetScript("OnUpdate", function(self, elapsed)
					local boost = #queue > 0 and 3 or 1
					for i, b in ipairs(bubbles) do
						b.y = b.y + b.speed * boost * elapsed
						if b.y > bubbleTop then ResetBubble(b) end
						b.phase = b.phase + elapsed * 2
						-- Fade in at the bottom and out at the top
						local alpha = 0.3
						local height = b.y - bubbleBottom
						if height < 20 then alpha = alpha * math.max(height, 0) / 20 elseif b.y > bubbleTop - 40 then alpha = alpha * (bubbleTop - b.y) / 40 end
						b:SetAlpha(alpha)
						b:SetPoint("BOTTOMLEFT", b.x + math.sin(b.phase) * b.wobble, b.y)
					end
				end)

				-- Update panel when shown
				SoundFinderPanel:HookScript("OnShow", UpdatePanel)

				-- Unmute everything the finder muted when the panel is hidden (continues in the background)
				SoundFinderPanel:SetScript("OnHide", function()
					ResetSteps()
					if restarted then restartWhenDone = true; restarted = false end
					if playHandle then StopSound(playHandle); playHandle = nil end
				end)

				-- Help button hidden
				SoundFinderPanel.h:Hide()

				-- Reset button hidden
				SoundFinderPanel.r:Hide()

				-- Back button handler
				SoundFinderPanel.b:SetScript("OnClick", function()
					SoundFinderPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
					return
				end)

			end

			----------------------------------------------------------------------
			-- Rest of things
			----------------------------------------------------------------------

			-- Add play sound file editbox
			local willPlay, musicHandle
			local MuteCustomSoundsStopButton = LeaPlusLC:CreateButton("MuteCustomSoundsStopButton", MuteCustomPanel, "Stop", "TOPRIGHT", -18, -66, 0, 25, true, "")
			MuteCustomSoundsStopButton:SetScript("OnClick", function()
				if musicHandle then StopSound(musicHandle) end
			end)

			local MuteCustomSoundsPlayButton = LeaPlusLC:CreateButton("MuteCustomSoundsPlayButton", MuteCustomPanel, "Play", "TOPRIGHT", -18, -66, 0, 25, true, "")
			MuteCustomSoundsPlayButton:ClearAllPoints()
			MuteCustomSoundsPlayButton:SetPoint("RIGHT", MuteCustomSoundsStopButton, "LEFT", -10, 0)

			local MuteCustomSoundsSoundBox = LeaPlusLC:CreateEditBox("MuteCustomSoundsSoundBox", eb, 80, 8, "TOPRIGHT", -10, 20, "PlaySoundBox", "PlaySoundBox")
			MuteCustomSoundsSoundBox:SetNumeric(true)
			MuteCustomSoundsSoundBox:ClearAllPoints()
			MuteCustomSoundsSoundBox:SetPoint("RIGHT", MuteCustomSoundsPlayButton, "LEFT", -10, 0)
			MuteCustomSoundsPlayButton:SetScript("OnClick", function()
				MuteCustomSoundsSoundBox:GetText()
				if musicHandle then StopSound(musicHandle) end
				willPlay, musicHandle = PlaySoundFile(MuteCustomSoundsSoundBox:GetText(), "Master")
			end)

			-- Add mousewheel support to the editbox
			MuteCustomSoundsSoundBox:SetScript("OnMouseWheel", function(self, delta)
				local endSound = tonumber(MuteCustomSoundsSoundBox:GetText())
				if endSound then
					if delta == 1 then endSound = endSound + 1 else endSound = endSound - 1 end
					if endSound < 1 then endSound = 1 elseif endSound >= 10000000 then endSound = 10000000 end
					MuteCustomSoundsSoundBox:SetText(endSound)
					MuteCustomSoundsPlayButton:Click()
				end
			end)

			local titlePlayer = LeaPlusLC:MakeTx(MuteCustomPanel, "Player", 16, -72)
			titlePlayer:ClearAllPoints()
			titlePlayer:SetPoint("TOPLEFT", MuteCustomSoundsSoundBox, "TOPLEFT", -4, 16)
			LeaPlusLC:CreateHelpButton("MuteGameSoundsCustomPlayHelpButton", MuteCustomPanel, titlePlayer, "If you want to listen to a sound file, enter the sound file ID into the editbox and click the play button.|n|nYou can scroll the mousewheel over the editbox to play neighbouring sound files.")
		end

		----------------------------------------------------------------------
		-- Hide rested sleep
		----------------------------------------------------------------------

		if LeaPlusLC["NoRestedSleep"] == "On" and not LeaLockList["NoRestedSleep"] then
			PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop.RestTexture:SetTexture("")
		end

		----------------------------------------------------------------------
		-- Block shared quests (no reload needed)
		----------------------------------------------------------------------

		do

			local eFrame = CreateFrame("FRAME")
			eFrame:SetScript("OnEvent", LeaPlusLC.CheckIfQuestIsSharedAndShouldBeDeclined)

			-- Function to set event
			local function SetSharedQuestsFunc()
				if LeaPlusLC["NoSharedQuests"] == "On" then
					eFrame:RegisterEvent("QUEST_DETAIL")
				else
					eFrame:UnregisterEvent("QUEST_DETAIL")
				end
			end

			-- Set event when option is clicked and on startup
			LeaPlusCB["NoSharedQuests"]:HookScript("OnClick", SetSharedQuestsFunc)
			SetSharedQuestsFunc()

		end

		----------------------------------------------------------------------
		-- Restore chat messages
		----------------------------------------------------------------------

		if LeaPlusLC["RestoreChatMessages"] == "On" and not LeaLockList["RestoreChatMessages"] then

			local historyFrame = CreateFrame("FRAME")
			historyFrame:RegisterEvent("PLAYER_LOGIN")
			historyFrame:RegisterEvent("PLAYER_LOGOUT")

			local FCF_IsChatWindowIndexActive = FCF_IsChatWindowIndexActive
			local GetMessageInfo = GetMessageInfo
			local GetNumMessages = GetNumMessages

			-- Save chat messages on logout
			historyFrame:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_LOGOUT" then
					local name, realm = UnitFullName("player")
					if not realm then realm = GetNormalizedRealmName() end
					if name and realm then
						LeaPlusDB["ChatHistoryName"] = name .. "-" .. realm
						LeaPlusDB["ChatHistoryTime"] = GetServerTime()
						for i = 1, 50 do
							if i ~= 2 and _G["ChatFrame" .. i] then
								if FCF_IsChatWindowIndexActive(i) then
									LeaPlusDB["ChatHistory" .. i] = {}
									local chtfrm = _G["ChatFrame" .. i]
									local NumMsg = chtfrm:GetNumMessages()
									local StartMsg = 1
									if NumMsg > 256 then StartMsg = NumMsg - 255 end
									for iMsg = StartMsg, NumMsg do
										local chatMessage, r, g, b, chatTypeID = chtfrm:GetMessageInfo(iMsg)
										if chatMessage and canaccessvalue(chatMessage) then
											if r and g and b then
												local colorCode = RGBToColorCode(r, g, b)
												chatMessage = colorCode .. chatMessage
											end
											tinsert(LeaPlusDB["ChatHistory" .. i], chatMessage)
										end
									end
								end
							end
						end
					end
				end
			end)

			-- Restore chat messages on login
			local name, realm = UnitFullName("player")
			if not realm then realm = GetNormalizedRealmName() end
			if name and realm then
				if LeaPlusDB["ChatHistoryName"] and LeaPlusDB["ChatHistoryTime"] then
					local timeDiff = GetServerTime() - LeaPlusDB["ChatHistoryTime"]
					if LeaPlusDB["ChatHistoryName"] == name .. "-" .. realm and timeDiff and timeDiff < 10 then -- reload must be done within 15 seconds

						-- Store chat messages from current session and clear chat
						for i = 1, 50 do
							if i ~= 2 and _G["ChatFrame" .. i] and FCF_IsChatWindowIndexActive(i) then
								LeaPlusDB["ChatTemp" .. i] = {}
								local chtfrm = _G["ChatFrame" .. i]
								local NumMsg = chtfrm:GetNumMessages()
								for iMsg = 1, NumMsg do
									local chatMessage, r, g, b, chatTypeID = chtfrm:GetMessageInfo(iMsg)
									if chatMessage and canaccessvalue(chatMessage) then
										if r and g and b then
											local colorCode = RGBToColorCode(r, g, b)
											chatMessage = colorCode .. chatMessage
										end
										tinsert(LeaPlusDB["ChatTemp" .. i], chatMessage)
									end
								end
								chtfrm:Clear()
							end
						end

						-- Restore chat messages from previous session
						for i = 1, 50 do
							if i ~= 2 and _G["ChatFrame" .. i] and LeaPlusDB["ChatHistory" .. i] and FCF_IsChatWindowIndexActive(i) then
								LeaPlusDB["ChatHistory" .. i .. "Count"] = 0
								-- Add previous session messages to chat
								for k = 1, #LeaPlusDB["ChatHistory" .. i] do
									if LeaPlusDB["ChatHistory" .. i][k] ~= string.match(LeaPlusDB["ChatHistory" .. i][k], "|cffffd800" .. L["Restored"] .. " " .. ".*" .. " " .. L["message"] .. ".*.|r") then
										_G["ChatFrame" .. i]:AddMessage(LeaPlusDB["ChatHistory" .. i][k])
										LeaPlusDB["ChatHistory" .. i .. "Count"] = LeaPlusDB["ChatHistory" .. i .. "Count"] + 1
									end
								end
								-- Show how many messages were restored
								if LeaPlusDB["ChatHistory" .. i .. "Count"] == 1 then
									_G["ChatFrame" .. i]:AddMessage("|cffffd800" .. L["Restored"] .. " " .. LeaPlusDB["ChatHistory" .. i .. "Count"] .. " " .. L["message from previous session"] .. ".|r")
								else
									_G["ChatFrame" .. i]:AddMessage("|cffffd800" .. L["Restored"] .. " " .. LeaPlusDB["ChatHistory" .. i .. "Count"] .. " " .. L["messages from previous session"] .. ".|r")
								end
							else
								-- No messages to restore
								LeaPlusDB["ChatHistory" .. i] = nil
							end
						end

						-- Restore chat messages from this session
						for i = 1, 50 do
							if i ~= 2 and _G["ChatFrame" .. i] and LeaPlusDB["ChatTemp" .. i] and FCF_IsChatWindowIndexActive(i) then
								for k = 1, #LeaPlusDB["ChatTemp" .. i] do
									_G["ChatFrame" .. i]:AddMessage(LeaPlusDB["ChatTemp" .. i][k])
								end
							end
						end

					end
				end
			end

		else

			-- Option is disabled so clear any messages from saved variables
			LeaPlusDB["ChatHistoryName"] = nil
			LeaPlusDB["ChatHistoryTime"] = nil
			for i = 1, 50 do
				LeaPlusDB["ChatHistory" .. i] = nil
				LeaPlusDB["ChatTemp" .. i] = nil
				LeaPlusDB["ChatHistory" .. i .. "Count"] = nil
			end

		end

		----------------------------------------------------------------------
		--	More chat font sizes
		----------------------------------------------------------------------

		if LeaPlusLC["MoreChatFontSizes"] == "On" and not LeaLockList["MoreChatFontSizes"] then

			local extraSizes = {22, 26, 28, 30, 32, 34, 36, 38, 40}

			Menu.ModifyMenu("MENU_FCF_TAB", function(owner, rootDescription)
				local chatFrame = FCF_GetChatFrameByID(owner:GetID())
				if not chatFrame then return end

				-- Find Blizzard's font size submenu (it contains a radio for the first chat font size)
				local fontMenu
				for void, element in rootDescription:EnumerateElementDescriptions() do
					for void, child in element:EnumerateElementDescriptions() do
						if child.IsRadio and child:IsRadio() and child:GetData() == CHAT_FONT_HEIGHTS[1] then
							fontMenu = element
							break
						end
					end
					if fontMenu then break end
				end
				if not fontMenu then return end

				-- Tick the size in use (font height is checked for secrets before it is compared)
				local function IsSelected(size)
					local void, height = chatFrame:GetFont()
					if not height or (issecretvalue and issecretvalue(height)) then return false end
					return math.floor(height + 0.5) == size
				end

				-- Set and save the font size the same way Blizzard's own options do
				local function SetSelected(size)
					FCF_SetChatWindowFontSize(nil, chatFrame, size)
				end

				-- Insert each extra size in order, skipping any size Blizzard already has
				for void, size in ipairs(extraSizes) do
					local index, exists = 1, false
					for i, child in fontMenu:EnumerateElementDescriptions() do
						local data = child:GetData()
						if data == size then exists = true; break end
						if type(data) == "number" and data < size then index = i + 1 end
					end
					if not exists then
						fontMenu:Insert(MenuUtil.CreateRadio(format(FONT_SIZE_TEMPLATE, size), IsSelected, SetSelected, size), index)
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Enhance minimap
		----------------------------------------------------------------------

		if LeaPlusLC["MinimapModder"] == "On" and not LeaLockList["MinimapModder"] then

			-- Set minimap shape (need to do this first)
			if LeaPlusLC["SquareMinimap"] == "On" then
				-- Square minimap is enabled so use square shape
				_G.GetMinimapShape = function() return "SQUARE" end
			else
				-- Square minimap is disabled so use round shape
				_G.GetMinimapShape = function() return "ROUND" end
			end

			local miniFrame = CreateFrame("FRAME")
			local LibDBIconStub = LibStub("LibDBIcon-1.0")
			if LeaPlusLC["SquareMinimap"] == "On" then
				LibDBIconStub:SetButtonRadius(0.165)
			else
				LibDBIconStub:SetButtonRadius(1)
			end

			----------------------------------------------------------------------
			-- Button test mode
			----------------------------------------------------------------------

			-- Create a ton of minimap buttons for test purposes
			local useMinimapButtonTestMode = false
			if useMinimapButtonTestMode then
				local numberOfTestButtons = 50
				local miniTable = {}
				for i = 1, numberOfTestButtons do
					miniTable[i] = LibStub("LibDataBroker-1.1"):NewDataObject("Leatrix_Plus" .. i, {
						type = "data source",
						text = "Test Addon " .. i,
						icon = "Interface\\HELPFRAME\\ReportLagIcon-Movement",
						OnClick = function(self, btn)
							LeaPlusGlobalMiniBtnClickFunc(btn)
						end,
						OnTooltipShow = function(tooltip)
							if not tooltip or not tooltip.AddLine then return end
							tooltip:AddLine("Test Addon " .. i)
						end,
					})
					miniTable[i].minimapPos = i * 50
				end
				for i = 1, numberOfTestButtons do
					LibStub("LibDBIcon-1.0", true):Register("Leatrix_Plus" .. i, miniTable[i], miniTable[i])
				end
			end

			----------------------------------------------------------------------
			-- Configuration panel
			----------------------------------------------------------------------

			-- Create configuration panel
			local SideMinimap = LeaPlusLC:CreatePanel("Enhance minimap", "SideMinimap")

			-- Add checkboxes
			LeaPlusLC:MakeTx(SideMinimap, "Settings", 16, -72)
			LeaPlusLC:MakeCB(SideMinimap, "HideMiniAddonButtons", "Hide addon buttons", 16, -92, false, "If checked, addon buttons will be hidden while the pointer is not over the minimap.")
			LeaPlusLC:MakeCB(SideMinimap, "MinimapButtonBag", "Minimap button bag", 16, -112, true, "If checked, minimap buttons for addons will be collected and placed in a bag which you can toggle by right-clicking the minimap.|n|nThis setting will help you declutter the minimap without the need to install a separate addon to do that.")
			LeaPlusLC:MakeCB(SideMinimap, "SquareMinimap", "Square minimap", 16, -132, true, "If checked, the minimap shape will be square.|n|nMinimap rotation (a setting in Edit Mode) is not recommended with a square minimap.")
			LeaPlusLC:MakeCB(SideMinimap, "HideMiniAddonMenu", "Hide addon menu", 16, -152, true, "If checked, the addon menu will be hidden.|n|nThe addon menu appears as a number in the corner of the minimap if you have any addons installed which make use of it.")
			LeaPlusLC:MakeCB(SideMinimap, "UnclampMinimap", "Unclamp minimap cluster", 16, -172, true, "If checked, you will be able to drag the minimap cluster to the edge of the screen using Edit Mode.|n|nWhile positioning the minimap with Edit Mode, you may need to disable Snap to position the minimap precisely.")

			-- Add excluded button
			local MiniExcludedButton = LeaPlusLC:CreateButton("MiniExcludedButton", SideMinimap, "Buttons", "TOPLEFT", 16, -72, 0, 25, true, "Click to toggle the addon buttons editor.")
			LeaPlusCB["MiniExcludedButton"]:ClearAllPoints()
			LeaPlusCB["MiniExcludedButton"]:SetPoint("LEFT", SideMinimap.r, "RIGHT", 10, 0)

			-- Set exclude button visibility
			local function SetExcludeButtonsFunc()
				if LeaPlusLC["HideMiniAddonButtons"] == "On" or LeaPlusLC["MinimapButtonBag"] == "On" then
					LeaPlusLC:LockItem(LeaPlusCB["MiniExcludedButton"], false)
				else
					LeaPlusLC:LockItem(LeaPlusCB["MiniExcludedButton"], true)
				end
			end
			LeaPlusCB["HideMiniAddonButtons"]:HookScript("OnClick", SetExcludeButtonsFunc)
			SetExcludeButtonsFunc()

			-- Add effects dropdown
			LeaPlusLC:CreateDropdown("MinimapEffect", "Visual effect", 150, "TOPLEFT", SideMinimap, "TOPLEFT", 356, -92, false, {{L["None"], 1}, {L["Arcane"], 2}, {L["Rune"], 3}, {L["Vortex"], 4}, {L["Inferno"], 5}, {L["Snow"], 6}, {L["Storm"], 7}, {L["Corona"], 8}, {L["Aurora"], 9}, {L["Starfield"], 10}, {L["Chronometer"], 11}, {L["Heartbeat"], 12}, {L["Fireworks"], 13}, {L["Crystals"], 14}, {L["Neon"], 15}, {L["Marquee"], 16}, {L["Glitch"], 17}, {L["Lava"], 18}, {L["Fuse"], 19}, {L["Rain"], 20}, {L["Prism"], 21}, {L["Candy"], 22}, {L["Rainbow"], 23}, {L["Fireflies"], 24}, {L["Synthwave"], 25}, {L["Collider"], 26}, {L["Bubbles"], 27}, {L["Acid"], 28}, {L["Shadow"], 29}, {L["Radar"], 30}, {L["Tesla"], 31}, {L["Meteor"], 32}, {L["Tube"], 33}})

			LeaPlusLC:MakeTx(SideMinimap, "Border width", 356, -132)
			LeaPlusLC:MakeSL(SideMinimap, "MinimapBorderWidth", "Drag to set the square minimap border width.", 1, 10, 1, 356, -142, "%.0f")

			LeaPlusLC:MakeTx(SideMinimap, "Cluster scale", 356, -182)
			LeaPlusLC:MakeSL(SideMinimap, "MiniClusterScale", "Drag to set the cluster scale.", 0.5, 2, 0.1, 356, -192, "%.2f")

			----------------------------------------------------------------------
			-- Hide addon menu
			----------------------------------------------------------------------

			if LeaPlusLC["HideMiniAddonMenu"] == "On" then

				-- Hide compartment menu when it is shown and on startup
				AddonCompartmentFrame:HookScript("OnShow", AddonCompartmentFrame.Hide)
				AddonCompartmentFrame:Hide()

			end

			----------------------------------------------------------------------
			-- Unclamp minimap cluster
			----------------------------------------------------------------------

			if LeaPlusLC["UnclampMinimap"] == "On" then
				MinimapCluster:SetClampedToScreen(false)
			end

			----------------------------------------------------------------------
			-- Addon buttons editor
			----------------------------------------------------------------------

			do

				-- Create configuration panel
				local ExcludedButtonsPanel = LeaPlusLC:CreatePanel("Enhance minimap", "ExcludedButtonsPanel")
				local boxWidth = 272

				-- Add second excluded button
				local MiniExcludedButton2 = LeaPlusLC:CreateButton("MiniExcludedButton2", ExcludedButtonsPanel, "Buttons", "TOPLEFT", 16, -72, 0, 25, true, "Click to toggle the addon buttons editor.")
				LeaPlusCB["MiniExcludedButton2"]:ClearAllPoints()
				LeaPlusCB["MiniExcludedButton2"]:SetPoint("LEFT", ExcludedButtonsPanel.r, "RIGHT", 10, 0)
				LeaPlusCB["MiniExcludedButton2"]:SetScript("OnClick", function()
					ExcludedButtonsPanel:Hide(); SideMinimap:Show()
					return
				end)

				-- Add large editbox
				local titleTX = LeaPlusLC:MakeTx(ExcludedButtonsPanel, "Editor", 16, -72)
				titleTX:SetWidth(boxWidth - 14) -- 534
				titleTX:SetWordWrap(false)
				titleTX:SetJustifyH("LEFT")

				-- Add help button
				LeaPlusLC:CreateHelpButton("MinimapButtonsAvailableHelpButton", ExcludedButtonsPanel, titleTX, "If you use the 'Hide addon buttons' or 'Minimap button bag' settings but you want some addon buttons to remain visible around the minimap, enter the button names into the editbox below separated by commas.|n|nChanges will require a UI reload to take effect.")

				local eb = CreateFrame("Frame", nil, ExcludedButtonsPanel, "BackdropTemplate")
				eb:SetSize(boxWidth, LeaPlusLC.MainPanelHeight - 180) -- 548
				eb:SetPoint("TOPLEFT", 10, -92)
				eb:SetBackdrop({
					bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
					edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
					edgeSize = 16,
					insets = { left = 8, right = 6, top = 8, bottom = 8 },
				})
				eb:SetBackdropBorderColor(1.0, 0.85, 0.0, 0.5)

				eb.scroll = CreateFrame("ScrollFrame", nil, eb, "LeaPlusEnhanceMinimapExcludeButtonsScrollFrameTemplate")
				eb.scroll:SetPoint("TOPLEFT", eb, 12, -10)
				eb.scroll:SetPoint("BOTTOMRIGHT", eb, -30, 10)
				eb.scroll:SetPanExtent(16)

				-- Create character count
				eb.scroll.CharCount = eb.scroll:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				eb.scroll.CharCount:Hide()

				eb.Text = eb.scroll.EditBox
				eb.Text:SetWidth(boxWidth - 54) -- 494
				eb.Text:SetHeight(230)
				eb.Text:SetPoint("TOPLEFT", eb.scroll)
				eb.Text:SetPoint("BOTTOMRIGHT", eb.scroll, -12, 0)
				eb.Text:SetMaxLetters(1200)
				eb.Text:SetFontObject(GameFontNormalLarge)
				eb.Text:SetAutoFocus(false)
				eb.scroll:SetScrollChild(eb.Text)

				-- Set focus on the editbox text when clicking the editbox
				eb:SetScript("OnMouseDown", function()
					eb.Text:SetFocus()
					eb.Text:SetCursorPosition(eb.Text:GetMaxLetters())
				end)

				-- Debug
				-- eb.Text:SetText("Leatrix_Plus\nLeatrix_Maps\nBugSack\nLeatrix_Plus\nLeatrix_Maps\nBugSack\nLeatrix_Plus\nLeatrix_Maps\nBugSack\nLeatrix_Plus\nLeatrix_Maps\nBugSack\nLeatrix_Plus\nLeatrix_Maps\nBugSack")

				-- Function to save the excluded list
				local function SaveString(self, userInput)
					local keytext = eb.Text:GetText()
					if keytext and keytext ~= "" then
						LeaPlusLC["MiniExcludeList"] = strtrim(eb.Text:GetText())
					else
						LeaPlusLC["MiniExcludeList"] = ""
					end
					if userInput then
						LeaPlusLC:ReloadCheck()
					end
				end

				-- Save the excluded list when it changes and at startup
				eb.Text:SetScript("OnTextChanged", SaveString)
				eb.Text:SetText(LeaPlusLC["MiniExcludeList"])
				SaveString()

				-- Add large editbox for available addons
				local titleAbTX = LeaPlusLC:MakeTx(ExcludedButtonsPanel, "Available button names", boxWidth + 20, -72)
				titleAbTX:SetWidth(boxWidth - 14)
				titleAbTX:SetWordWrap(false)
				titleAbTX:SetJustifyH("LEFT")

				-- Add help button
				LeaPlusLC:CreateHelpButton("MinimapButtonsAvailableHelpButton", ExcludedButtonsPanel, titleAbTX, "This is a list of available addon button names.  You can use this list to copy and paste button names that you want into the editor.|n|nThis listing is automatically generated and cannot be edited.")

				local ab = CreateFrame("Frame", nil, ExcludedButtonsPanel, "BackdropTemplate")
				ab:SetSize(boxWidth, LeaPlusLC.MainPanelHeight - 180) -- 548
				ab:SetPoint("TOPLEFT", 286, -92)
				ab:SetBackdrop({
					bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
					edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
					edgeSize = 16,
					insets = { left = 8, right = 6, top = 8, bottom = 8 },
				})
				ab:SetBackdropBorderColor(1.0, 0.85, 0.0, 0.5)
				ab:SetBackdropColor(0, 0, 0, 0.5)

				ab.scroll = CreateFrame("ScrollFrame", nil, ab, "LeaPlusEnhanceMinimapExcludeButtonsScrollFrameTemplate")
				ab.scroll:SetPoint("TOPLEFT", ab, 12, -10)
				ab.scroll:SetPoint("BOTTOMRIGHT", ab, -30, 10)
				ab.scroll:SetPanExtent(16)

				-- Create character count
				ab.scroll.CharCount = ab.scroll:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				ab.scroll.CharCount:Hide()

				ab.Text = ab.scroll.EditBox
				ab.Text:SetWidth(boxWidth - 54) -- 494
				ab.Text:SetHeight(230)
				ab.Text:SetPoint("TOPLEFT", ab.scroll)
				ab.Text:SetPoint("BOTTOMRIGHT", ab.scroll, -12, 0)
				ab.Text:SetMaxLetters(1200)
				ab.Text:SetFontObject(GameFontNormalLarge)
				ab.Text:SetAutoFocus(false)
				ab.scroll:SetScrollChild(ab.Text)

				-- Set focus on the editbox text when clicking the editbox
				ab:SetScript("OnMouseDown", function()
					ab.Text:SetFocus()
					ab.Text:SetCursorPosition(ab.Text:GetMaxLetters())
				end)

				-- Function to make string with list of buttons
				local function MakeAddonString()
					local msg = ""
					local numAddons = C_AddOns.GetNumAddOns()
					local buttons = LibDBIconStub:GetButtonList()
					table.sort(buttons)
					for i = 1, #buttons do
						local button = LibDBIconStub:GetMinimapButton(buttons[i])
						local buttonName = buttons[i]
						msg = msg .. buttonName .. ",|n|n"
					end
					if msg ~= "" then
					else
						msg = L["No supported addons."]
					end
					ab.Text:SetText(msg)
				end

				ab.Text:HookScript("OnShow", MakeAddonString)
				ab.Text:HookScript("OnTextChanged", function(self, userInput)
					if userInput then MakeAddonString() end
				end)

				-- Hide help button
				ExcludedButtonsPanel.h:Hide()

				-- Back button handler
				ExcludedButtonsPanel.b:SetScript("OnClick", function()
					ExcludedButtonsPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
					return
				end)

				-- Reset button handler
				ExcludedButtonsPanel.r:SetScript("OnClick", function()

					-- Reset controls
					LeaPlusLC["MiniExcludeList"] = ""
					eb.Text:SetText(LeaPlusLC["MiniExcludeList"])

					-- Refresh configuration panel
					ExcludedButtonsPanel:Hide(); ExcludedButtonsPanel:Show()
					LeaPlusLC:ReloadCheck()

				end)

				-- Show configuration panal when options panel button is clicked
				LeaPlusCB["MiniExcludedButton"]:SetScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaPlusLC["MiniExcludeList"] = "BugSack, Leatrix_Plus"
						LeaPlusLC:ReloadCheck()
					else
						ExcludedButtonsPanel:Show()
						SideMinimap:Hide()
					end
				end)

			end

			----------------------------------------------------------------------
			-- Minimap cluster scale
			----------------------------------------------------------------------

			-- Function to set the minimap cluster scale
			local function SetClusterScale()
				MinimapCluster:SetScale(LeaPlusLC["MiniClusterScale"])
				-- Set slider formatted text
				LeaPlusCB["MiniClusterScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["MiniClusterScale"] * 100)
			end

			-- Set minimap scale when slider is changed and on startup
			LeaPlusCB["MiniClusterScale"]:HookScript("OnValueChanged", SetClusterScale)
			SetClusterScale()

			----------------------------------------------------------------------
			-- Minimap effects
			----------------------------------------------------------------------

			do

				local square = LeaPlusLC["SquareMinimap"] == "On"
				local TAU = math.pi * 2
				local sin, cos, abs, max, floor, atan2 = math.sin, math.cos, math.abs, math.max, math.floor, math.atan2
				local DOT = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
				local WHITE = "Interface\\Buttons\\WHITE8X8"

				-- Function to get a point at angle a (0 is right, anticlockwise) on the minimap edge, d pixels outside it
				local function EdgeAt(a, d)
					local half = Minimap:GetWidth() / 2 + (d or 0)
					local x, y = cos(a), sin(a)
					if square then
						local m = max(abs(x), abs(y))
						return x / m * half, y / m * half
					end
					return x * half, y * half
				end

				-- Function to get a point at position t (0 to 1, evenly spaced around the edge) on the minimap edge, d pixels outside it
				local function EdgeT(t, d)
					local half = Minimap:GetWidth() / 2 + (d or 0)
					t = t % 1
					if not square then
						return cos(t * TAU) * half, sin(t * TAU) * half
					end
					local s = (t * 4 + 0.5) % 4
					local side = floor(s)
					local p = (s - side) * 2 - 1
					if side == 0 then return half, p * half
					elseif side == 1 then return -p * half, half
					elseif side == 2 then return -half, -p * half
					else return p * half, -half end
				end

				-- Function to create a texture
				local function Tex(parent, file, layer, sub, r, g, b, a)
					local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub or 0)
					t:SetTexture(file)
					t:SetBlendMode("ADD")
					t:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
					return t
				end

				-- Function to create a glow around the minimap edge
				local function MakeGlow(parent, size, r, g, b, a, spread)
					local p = {}
					if not square then
						spread = spread or 0.15
						for k = 1, 6 do
							local t = Tex(parent, DOT, "BACKGROUND", 0, r, g, b, a * 0.3)
							t:SetPoint("CENTER")
							p[k] = t
						end
						p.Layout = function()
							local w = Minimap:GetWidth()
							for k = 1, 6 do local s = w * (1 + spread * k / 6); p[k]:SetSize(s, s) end
						end
					else
						local c = 16 * size
						local function Piece(file, l, rr, tt, bb) local t = Tex(parent, "Interface\\Common\\" .. file, "BACKGROUND", 0, r, g, b, a); t:SetTexCoord(l, rr, tt, bb); return t end
						local tl = Piece("GlowBorder-Corner", 0, 1, 0, 1); tl:SetSize(c, c); tl:SetPoint("TOPLEFT", -c / 2, c / 2)
						local tr = Piece("GlowBorder-Corner", 1, 0, 0, 1); tr:SetSize(c, c); tr:SetPoint("TOPRIGHT", c / 2, c / 2)
						local bl = Piece("GlowBorder-Corner", 0, 1, 1, 0); bl:SetSize(c, c); bl:SetPoint("BOTTOMLEFT", -c / 2, -c / 2)
						local br = Piece("GlowBorder-Corner", 1, 0, 1, 0); br:SetSize(c, c); br:SetPoint("BOTTOMRIGHT", c / 2, -c / 2)
						local top = Piece("GlowBorder-Top", 0, 1, 0, 1); top:SetPoint("TOPLEFT", tl, "TOPRIGHT"); top:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT")
						local bottom = Piece("GlowBorder-Top", 0, 1, 1, 0); bottom:SetPoint("TOPLEFT", bl, "TOPRIGHT"); bottom:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT")
						local left = Piece("GlowBorder-Left", 0, 1, 0, 1); left:SetPoint("TOPLEFT", tl, "BOTTOMLEFT"); left:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT")
						local right = Piece("GlowBorder-Left", 1, 0, 0, 1); right:SetPoint("TOPLEFT", tr, "BOTTOMLEFT"); right:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
						-- Pieces in order around the edge (used for colour flow)
						p = {right, tr, top, tl, left, bl, bottom, br}
					end
					return p
				end

				-- Function to create an animation group (added to the effect so it starts and stops with it)
				local function Group(e, region, looping)
					local ag = region:CreateAnimationGroup()
					ag:SetLooping(looping or "REPEAT")
					tinsert(e.groups, ag)
					return ag
				end

				-- Function to create an animation
				local function Anim(ag, kind, duration, order, delay)
					local an = ag:CreateAnimation(kind)
					an:SetDuration(duration)
					an:SetOrder(order or 1)
					if delay then an:SetStartDelay(delay) end
					return an
				end

				-- Function to convert a hue (0 to 1) to a soft colour
				local function Hue(h)
					h = (h % 1) * 6
					local i, f = floor(h), h - floor(h)
					local r, g, b
					if i == 0 then r, g, b = 1, f, 0 elseif i == 1 then r, g, b = 1 - f, 1, 0 elseif i == 2 then r, g, b = 0, 1, f
					elseif i == 3 then r, g, b = 0, 1 - f, 1 elseif i == 4 then r, g, b = f, 0, 1 else r, g, b = 1, 0, 1 - f end
					return 0.3 + 0.7 * r, 0.3 + 0.7 * g, 0.3 + 0.7 * b
				end

				-- Function to get the outward direction (angle) at position t on the edge
				local function EdgeNormal(t)
					if not square then return (t % 1) * TAU end
					local x, y = EdgeT(t, 0)
					if abs(abs(x) - abs(y)) < 3 then return atan2(y, x) end -- Corner
					if abs(x) > abs(y) then return x > 0 and 0 or math.pi end
					return y > 0 and TAU / 4 or -TAU / 4
				end

				-- Helpers passed to each effect
				local helpers = {square = square, Tex = Tex, Anim = Anim, Group = Group, MakeGlow = MakeGlow, EdgeAt = EdgeAt, EdgeT = EdgeT, EdgeNormal = EdgeNormal, Hue = Hue}

				-- Function to get an effect (the effects are only loaded the first time an effect other than None is selected)
				local effects, effectList
				local function GetEffect(index)
					if index == 1 then return end -- None
					if not effectList then
						effectList = Leatrix_Plus.LoadMinimapEffects()
						effects = {}
					end
					if not effects[index] and effectList[index] then
						local e = {groups = {}, build = effectList[index], gen = 0}
						-- Front layer (above the minimap) and back layer (behind the minimap)
						e.frame = CreateFrame("Frame", nil, Minimap); e.frame:SetAllPoints(); e.frame:SetFrameLevel(Minimap:GetFrameLevel() + 2); e.frame:Hide()
						e.back = CreateFrame("Frame", nil, Minimap); e.back:SetAllPoints(); e.back:SetFrameLevel(max(Minimap:GetFrameLevel() - 1, 0)); e.back:Hide()
						effects[index] = e
					end
					return effects[index]
				end

				-- Function to start an effect (built the first time it is selected)
				local function StartEffect(e)
					if not e.built then e.build(e, helpers); e.built = true end
					if e.Layout then e.Layout() end
					e.frame:Show(); e.back:Show()
					for i = 1, #e.groups do e.groups[i]:Play() end
					if e.OnStart then e.OnStart() end
				end

				-- Function to stop an effect
				local function StopEffect(e)
					e.gen = e.gen + 1
					if e.OnStop then e.OnStop() end
					for i = 1, #e.groups do e.groups[i]:Stop() end
					e.frame:Hide(); e.back:Hide()
				end

				-- Function to show the selected effect (does nothing if the selected effect is already showing)
				local current, currentIndex = nil, 1
				local function SetMinimapEffect()
					local index = LeaPlusLC["MinimapEffect"]
					if index == currentIndex then return end
					currentIndex = index
					if current then StopEffect(current); current = nil end
					local e = GetEffect(index)
					if e then StartEffect(e); current = e end
				end

				-- Set effect when the dropdown menu is closed and on startup
				LeaPlusCB["MinimapEffect"]:RegisterCallback("OnMenuClose", SetMinimapEffect)
				SetMinimapEffect()

				-- Rebuild the effect positions if the minimap size changes
				Minimap:HookScript("OnSizeChanged", function()
					if current then StopEffect(current); StartEffect(current) end
				end)

				-- Assign file level scope (used in reset)
				LeaPlusLC.SetMinimapEffect = SetMinimapEffect

			end

			----------------------------------------------------------------------
			-- Minimap button bag
			----------------------------------------------------------------------

			if LeaPlusLC["MinimapButtonBag"] == "On" then

				-- Lock out hide minimap buttons
				LeaPlusLC:LockItem(LeaPlusCB["HideMiniAddonButtons"], true)
				LeaPlusCB["HideMiniAddonButtons"].tiptext = LeaPlusCB["HideMiniAddonButtons"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot be used with Minimap button bag."]

				-- Create button frame
				local bFrame = CreateFrame("FRAME", nil, UIParent)
				bFrame:ClearAllPoints()
				bFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 4, 4)
				bFrame:SetClampedToScreen(true)
				bFrame:Hide()

				-- Set top level to ensure button frame shows on top of frames such as the main action bar
				bFrame:SetToplevel(true)

				-- Set button frame scale to match minimap cluster scale
				bFrame:SetScale(MinimapCluster:GetScale())
				MinimapCluster:HookScript("OnSizeChanged", function()
					bFrame:SetScale(MinimapCluster:GetScale())
				end)

				LeaPlusLC.bFrame = bFrame -- Used in LibDBIcon callback
				_G["LeaPlusGlobalMinimapCombinedButtonFrame"] = bFrame -- For third party addons

				-- Hide button frame automatically
				local ButtonFrameTicker
				bFrame:HookScript("OnShow", function()
					if ButtonFrameTicker then ButtonFrameTicker:Cancel() end
					ButtonFrameTicker = C_Timer.NewTicker(2, function()
						if not bFrame:IsMouseOver() and not Minimap:IsMouseOver() then
							bFrame:Hide()
							if ButtonFrameTicker then ButtonFrameTicker:Cancel() end
						end
					end, 15)
				end)

				-- Position LibDBIcon tooltips when shown
				LibDBIconTooltip:HookScript("OnShow", function()
					GameTooltip:Hide()
					LibDBIconTooltip:ClearAllPoints()
					if bFrame:GetPoint() == "BOTTOMLEFT" then
						LibDBIconTooltip:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -6)
					else
						LibDBIconTooltip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -6)
					end
				end)

				-- Function to position GameTooltip below the minimap
				local function SetButtonTooltip()
					GameTooltip:ClearAllPoints()
					if bFrame:GetPoint() == "BOTTOMLEFT" then
						GameTooltip:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -6)
					else
						GameTooltip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -6)
					end
				end

				LeaPlusLC.SetButtonTooltip = SetButtonTooltip -- Used in LibDBIcon callback

				-- Hide existing LibDBIcon icons
				local buttons = LibDBIconStub:GetButtonList()
				for i = 1, #buttons do
					local button = LibDBIconStub:GetMinimapButton(buttons[i])
					local buttonName = strlower(buttons[i])
					if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
						button:Hide()
						button:SetScript("OnShow", function() if not bFrame:IsShown() then button:Hide() end end)
						-- Create background texture
						local bFrameBg = button:CreateTexture(nil, "BACKGROUND")
						bFrameBg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
						bFrameBg:SetPoint("CENTER")
						bFrameBg:SetSize(30, 30)
						bFrameBg:SetVertexColor(0, 0, 0, 0.5)
					end
					-- Move GameTooltip to below the minimap in case the button uses it
					button:HookScript("OnEnter", SetButtonTooltip)
					-- Special case for MoveAny because it doesn't have button.db
					if buttonName == "moveany" then
						button.db = button.db or {}
						if not button.db.hide then button.db.hide = false end
					end
				end

				-- Hide new LibDBIcon icons
				-- LibDBIcon_IconCreated: Done in LibDBIcon callback function

				-- Create minimap button bag frame
				local mbtn = CreateFrame("Frame", nil, Minimap)
				mbtn:ClearAllPoints()
				mbtn:SetAllPoints()
				mbtn:EnableMouse(true)
				mbtn:SetPassThroughButtons("LeftButton", "MiddleButton")
				mbtn:SetPropagateMouseMotion(true)
				mbtn:Show()

				-- Toggle button frame
				mbtn:SetScript("OnMouseUp", function(frame, button)
					if button == "LeftButton" or button == "RightButton" then
						if bFrame:IsShown() then
							bFrame:Hide()
						else bFrame:Show()
							-- Position button frame
							local side
							local m = Minimap:GetCenter()
							local b = Minimap:GetEffectiveScale()
							local w = GetScreenWidth()
							local s = UIParent:GetEffectiveScale()
							bFrame:ClearAllPoints()
							if m * b > (w * s / 2) then
								side = "Right"
								bFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -10, -0)
							else
								side = "Left"
								bFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMRIGHT", 10, 0)
							end
							-- Show button frame
							local x, y, row, col = 0, 0, 0, 0
							local buttons = LibDBIconStub:GetButtonList()
							-- Sort the button table
							table.sort(buttons, function(a, b)
								if string.find(a, "LeaPlusCustomIcon_") then
									a = string.gsub(a, "LeaPlusCustomIcon_", "")
								end
								if string.find(b, "LeaPlusCustomIcon_") then
									b = string.gsub(b, "LeaPlusCustomIcon_", "")
								end
								return a:lower() < b:lower()
							end)
							-- Calculate buttons per row
							local buttonsPerRow
							local totalButtons = #buttons
								if totalButtons > 36 then buttonsPerRow = 10
							elseif totalButtons > 32 then buttonsPerRow = 9
							elseif totalButtons > 28 then buttonsPerRow = 8
							elseif totalButtons > 24 then buttonsPerRow = 7
							elseif totalButtons > 20 then buttonsPerRow = 6
							elseif totalButtons > 16 then buttonsPerRow = 5
							elseif totalButtons > 12 then buttonsPerRow = 4
							elseif totalButtons > 8 then buttonsPerRow = 3
							elseif totalButtons > 4 then buttonsPerRow = 2
							else
								buttonsPerRow = 1
							end
							-- Build button grid
							for i = 1, totalButtons do
								local buttonName = strlower(buttons[i])
								if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
									local button = LibDBIconStub:GetMinimapButton(buttons[i])
									if button.db then
										if buttonName == "armory" then button.db.hide = false end -- Armory addon sets hidden to true
										if not button.db.hide then
											button:SetParent(bFrame)
											button:ClearAllPoints()
											if side == "Left" then
												-- Minimap is on left side of screen
												button:SetPoint("TOPLEFT", bFrame, "TOPLEFT", x, y)
												col = col + 1; if col >= buttonsPerRow then col = 0; row = row + 1; x = 0; y = y - 30 else x = x + 30 end
											else
												-- Minimap is on right side of screen (changed from TOPRIGHT to TOPLEFT and x - 30 to x + 30 to make sorting work)
												button:SetPoint("TOPLEFT", bFrame, "TOPLEFT", x, y)
												col = col + 1; if col >= buttonsPerRow then col = 0; row = row + 1; x = 0; y = y - 30 else x = x + 30 end
											end
											if totalButtons <= buttonsPerRow then
												bFrame:SetWidth(totalButtons * 30)
											else
												bFrame:SetWidth(buttonsPerRow * 30)
											end
											local void, void, void, void, e = button:GetPoint()
											bFrame:SetHeight(0 - e + 30)
											LibDBIconStub:Show(buttons[i])
										end
									end
								end
							end
						end
					end
				end)

			end

			----------------------------------------------------------------------
			-- Square minimap
			----------------------------------------------------------------------

			if LeaPlusLC["SquareMinimap"] == "On" then

				-- Set button layout
				AddonCompartmentFrame:SetFrameLevel(4)

				-- Debug
				-- AddonCompartmentFrame:SetText("56")

				-- Create black border around map
				local miniBorder = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
				miniBorder:SetAlpha(1)

				-- Adjust border width using slider control
				local function SetMinimapBorderWidth()
					miniBorder:ClearAllPoints()
					miniBorder:SetPoint("TOPLEFT", -LeaPlusLC["MinimapBorderWidth"], LeaPlusLC["MinimapBorderWidth"])
					miniBorder:SetPoint("BOTTOMRIGHT", LeaPlusLC["MinimapBorderWidth"], -LeaPlusLC["MinimapBorderWidth"])
					miniBorder:SetBackdrop({
						edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
						edgeSize = LeaPlusLC["MinimapBorderWidth"],
					})
				end

				-- Set border width when slider is changed and on startup
				LeaPlusCB["MinimapBorderWidth"]:HookScript("OnValueChanged", SetMinimapBorderWidth)
				SetMinimapBorderWidth()

				-- Set minimap position (local setting = MinimapCluster:GetSettingValueBool(Enum.EditModeMinimapSetting.HeaderUnderneath))
				Minimap:ClearAllPoints()
				Minimap:SetPoint("CENTER", MinimapCluster, "TOP", 14, -124)

				-- Hide the default compass border
				MinimapCompassTexture:Hide()

				-- Mask texture
				Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')

				-- Keep the square look (rotation, FarmHud and other addons can change the mask or show the rings)
				local SQUARE_MASK = "Interface\\ChatFrame\\ChatFrameBackground"
				local applyingMask = false

				-- Hide the compass rings and apply the square mask
				local function ApplySquareLook()
					MinimapCompassTexture:Hide()
					if MinimapCompassTextureUnderlay then MinimapCompassTextureUnderlay:Hide() end
					applyingMask = true
					Minimap:SetMaskTexture(SQUARE_MASK)
					applyingMask = false
				end

				-- Apply the square look now and again after Blizzard's own code has finished running
				local function ReapplySquare()
					ApplySquareLook()
					C_Timer.After(0, ApplySquareLook)
				end

				-- Put the square mask back if anything changes it
				hooksecurefunc(Minimap, "SetMaskTexture", function()
					if not applyingMask then ApplySquareLook() end
				end)

				-- Keep the rings hidden if anything shows them
				hooksecurefunc(MinimapCompassTexture, "Show", ApplySquareLook)
				if MinimapCompassTextureUnderlay then
					hooksecurefunc(MinimapCompassTextureUnderlay, "Show", ApplySquareLook)
				end

				-- Reapply the square look on loading screens and when minimap rotation is toggled
				local squareWatcher = CreateFrame("Frame")
				squareWatcher:RegisterEvent("CVAR_UPDATE")
				squareWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
				squareWatcher:SetScript("OnEvent", function(self, event, cvar)
					if event == "PLAYER_ENTERING_WORLD" or (cvar and strlower(cvar) == "rotateminimap") then
						ReapplySquare()
					end
				end)
				ReapplySquare()

				-- Fix textures
				Minimap:SetArchBlobRingScalar(0)
				Minimap:SetArchBlobRingAlpha(0)
				Minimap:SetQuestBlobRingScalar(0)
				Minimap:SetQuestBlobRingAlpha(0)

				-- Zoom in button
				miniFrame.ClearAllPoints(Minimap.ZoomIn)
				Minimap.ZoomIn:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 0, 0)

				miniFrame.ClearAllPoints(Minimap.ZoomOut)
				Minimap.ZoomOut:SetPoint("RIGHT", Minimap.ZoomIn, "LEFT", -6, 0)

				-- Expansion button
				ExpansionLandingPageMinimapButton.border = ExpansionLandingPageMinimapButton:CreateTexture(nil, "OVERLAY")
				ExpansionLandingPageMinimapButton.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
				ExpansionLandingPageMinimapButton.border:SetSize(52, 52)
				ExpansionLandingPageMinimapButton.border:SetPoint("TOPLEFT", 0, 0)

				ExpansionLandingPageMinimapButton.background = ExpansionLandingPageMinimapButton:CreateTexture(nil, "BACKGROUND")
				ExpansionLandingPageMinimapButton.background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
				ExpansionLandingPageMinimapButton.background:SetAllPoints()
				ExpansionLandingPageMinimapButton:SetHitRectInsets(-0.2, 0.2, 0, 0)

				miniFrame.SetSize(ExpansionLandingPageMinimapButton, 30, 30)
				hooksecurefunc(ExpansionLandingPageMinimapButton, "SetSize", function()
					miniFrame.SetSize(ExpansionLandingPageMinimapButton, 30, 30)
				end)

				-- Set expansion button on startup (needed for Dragonflight button)
				miniFrame.ClearAllPoints(ExpansionLandingPageMinimapButton)
				ExpansionLandingPageMinimapButton:SetPoint("TOPLEFT", MinimapBackdrop, "TOPLEFT", -7, -150)
				ExpansionLandingPageMinimapButton.LoopingGlow:SetAtlas("Mage-ArcaneCharge-CircleGlow", true)

				-- Set expansion button when icon is updated (needed for Shadowlands button)
				hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIcon", function()
					miniFrame.ClearAllPoints(ExpansionLandingPageMinimapButton)
					ExpansionLandingPageMinimapButton:SetPoint("TOPLEFT", MinimapBackdrop, "TOPLEFT", -7, -150)
					ExpansionLandingPageMinimapButton.LoopingGlow:SetAtlas("Mage-ArcaneCharge-CircleGlow", true)
				end)

				ExpansionLandingPageMinimapButton.AlertBG:ClearAllPoints()
				ExpansionLandingPageMinimapButton.AlertBG:SetPoint("RIGHT", ExpansionLandingPageMinimapButton, "CENTER", -4, 0)
				ExpansionLandingPageMinimapButton.AlertText:ClearAllPoints()
				ExpansionLandingPageMinimapButton.AlertText:SetPoint("RIGHT", ExpansionLandingPageMinimapButton, "LEFT", -8, 0)
				ExpansionLandingPageMinimapButton:SetHitRectInsets(0, 0, 0, 0)

				-- Setup hybrid minimap when available
				EventUtil.ContinueOnAddOnLoaded("Blizzard_HybridMinimap",function()
					HybridMinimap.MapCanvas:SetUseMaskTexture(false)
					HybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8")
					HybridMinimap.MapCanvas:SetUseMaskTexture(true)
				end)

			else

				-- Square minimap is disabled so disable border width slider
				LeaPlusLC:LockItem(LeaPlusCB["MinimapBorderWidth"], true)
				LeaPlusCB["MinimapBorderWidth"].tiptext = LeaPlusCB["MinimapBorderWidth"].tiptext .. "|cff00AAFF|n|n" .. L["This slider requires 'Square minimap' to be enabled."] .. "|r"

			end

			----------------------------------------------------------------------
			-- Replace non-standard buttons
			----------------------------------------------------------------------

			-- Replace non-standard buttons for addons that don't use the standard LibDBIcon library
			do

				-- Make LibDBIcon buttons for addons that don't use LibDBIcon
				local CustomAddonTable = {}
				LeaPlusDB["CustomAddonButtons"] = LeaPlusDB["CustomAddonButtons"] or {}

				-- Function to create a LibDBIcon button
				local function CreateBadButton(name)

					-- Get non-standard button texture
					local finalTex = "Interface\\HELPFRAME\\HelpIcon-KnowledgeBase"

					if _G[name .. "Icon"] then
						if _G[name .. "Icon"]:GetObjectType() == "Texture" then
							local gTex = _G[name .. "Icon"]:GetTexture()
							if gTex then
								finalTex = gTex
							end
						end
					else
						for i = 1, select('#', _G[name]:GetRegions()) do
							local region = select(i, _G[name]:GetRegions())
							if region.GetTexture then
								local x, y = region:GetSize()
								if x and x < 30 then
									finalTex = region:GetTexture()
								end
							end
						end
					end

					if not finalTex then finalTex = "Interface\\HELPFRAME\\HelpIcon-KnowledgeBase" end

					-- Function to anchor the tooltip to the custom button or the minimap
					local function ReanchorTooltip(tip, myButton)
						tip:ClearAllPoints()
						if LeaPlusLC["MinimapButtonBag"] == "On" then
							if LeaPlusLC.bFrame and LeaPlusLC.bFrame:GetPoint() == "BOTTOMLEFT" then
								tip:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -6)
							else
								tip:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -6)
							end
						else
							if Minimap:GetCenter() * Minimap:GetEffectiveScale() > (GetScreenWidth() * UIParent:GetEffectiveScale() / 2) then
								tip:SetPoint("TOPRIGHT", myButton, "BOTTOMRIGHT", 0, -6)
							else
								tip:SetPoint("TOPLEFT", myButton, "BOTTOMLEFT", 0, -6)
							end
						end
					end

					local zeroButton = LibStub("LibDataBroker-1.1"):NewDataObject("LeaPlusCustomIcon_" .. name, {
						type = "data source",
						text = name,
						icon = finalTex,
						OnClick = function(self, btn)
							if _G[name] then
								if string.find(name, "LibDBIcon") then
									-- It's a fake LibDBIcon
									local mouseUp = _G[name]:GetScript("OnMouseUp")
									if mouseUp then
										mouseUp(self, btn)
									end
								else
									-- It's a genuine LibDBIcon
									local clickUp = _G[name]:GetScript("OnClick")
									if clickUp then
										_G[name]:Click(btn)
									end
								end
							end
						end,
					})
					LeaPlusDB["CustomAddonButtons"][name] = LeaPlusDB["CustomAddonButtons"][name] or {}
					LeaPlusDB["CustomAddonButtons"][name].hide = false
					CustomAddonTable[name] = name
					local icon = LibStub("LibDBIcon-1.0", true)
					icon:Register("LeaPlusCustomIcon_" .. name, zeroButton, LeaPlusDB["CustomAddonButtons"][name])
					-- Custom buttons
					if name == "AllTheThings-Minimap" then
						-- AllTheThings
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton.icon:SetTexture("Interface\\AddOns\\AllTheThings\\assets\\logo_tiny")
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
							ReanchorTooltip(GameTooltip, myButton)
						end)
						myButton:HookScript("OnLeave", function()
							_G[name]:GetScript("OnLeave")()
						end)
					elseif name == "OOMinimapButton" then
						-- OmniumObservator
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
						end)
						myButton:HookScript("OnLeave", function()
							_G[name]:GetScript("OnLeave")()
						end)
					elseif name == "LibDBIcon10_WoWtility" then
						-- Wowtility
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton.icon:SetTexture("Interface\\AddOns\\WoWtility\\WoWtility.blp")
						myButton:SetScript("OnClick", function(self, btn) LibDBIcon10_WoWtility:Click(btn) end)
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
						end)
						myButton:HookScript("OnLeave", function()
							_G[name]:GetScript("OnLeave")()
						end)
					elseif name == "AltoholicMinimapButton" then
						-- Altoholic
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton.icon:SetTexture("Interface\\Icons\\INV_Drink_13")
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
							ReanchorTooltip(AddonFactory_Tooltip, myButton)
						end)
						myButton:HookScript("OnLeave", function()
							_G[name]:GetScript("OnLeave")()
						end)
					elseif name == "WIM3MinimapButton" then
						-- WIM
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
							GameTooltip:SetOwner(myButton, "ANCHOR_TOP")
							GameTooltip:AddLine(name)
							GameTooltip:Show()
							ReanchorTooltip(GameTooltip, myButton)
						end)
						myButton:HookScript("OnLeave", function()
							_G["WIM3MinimapButton"]:GetScript("OnLeave")()
							GameTooltip:Hide()
						end)
					elseif name == "ZygorGuidesViewerMapIcon" then
						-- Zygor (uses LibDBIcon10_LeaPlusCustomIcon_ZygorGuidesViewerMapIcon)
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton.icon:SetTexture("Interface\\AddOns\\ZygorGuidesViewer\\Skins\\minimap-icon.tga")
						hooksecurefunc(myButton.icon, "UpdateCoord", function()
							myButton.icon:SetTexCoord(0, 0.5, 0, 0.25)
						end)
						myButton.icon:SetTexCoord(0, 0.5, 0, 0.25)
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
							ReanchorTooltip(GameTooltip, myButton)
						end)
						myButton:HookScript("OnLeave", function()
							GameTooltip:Hide()
						end)
						if ZGV_Notification_Entry_Template_Mixin then
							-- Fix notification system entry height
							hooksecurefunc(ZGV_Notification_Entry_Template_Mixin, "UpdateHeight", function(self)
								self:Show()
								local height = 46
								if ZGV and ZGV.db and ZGV.db.profile and ZGV.db.profile.nc_size and ZGV.db.profile.nc_size == 1 then height = 36 end
								height = height + (self.time:IsVisible() and self.time:GetStringHeight()+0 or 0)
								height = height + (self.title:IsVisible() and self.title:GetStringHeight()+3 or 0)
								height = height + (self.text:IsVisible() and self.text:GetStringHeight()+3 or 0)
								height = height + (self.SpecialButton and self.SpecialButton:IsVisible() and self.SpecialButton:GetHeight()+8 or 0)
								if (self.single or self.special) then height = max(height,25) end
								self:SetHeight(height)
								self:Hide()
							end)
						end
					elseif name == "BtWQuestsMinimapButton"				-- BtWQuests
						or name == "TomCats-MinimapButton"				-- TomCat's Tours
						or name == "TomCats-LoveIsInTheAirMinimapButton2023"
						or name == "TomCats-LunarFestivalMinimapButton2023"
						or name == "LibDBIcon10_MethodRaidTools"		-- Method Raid Tools
						or name == "wlMinimapButton"					-- Wowhead Looter (part of Wowhead client)
						or name == "CLN_MinimapButton"					-- Chatty Little NPC
						then
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton:HookScript("OnEnter", function()
							_G[name]:GetScript("OnEnter")(_G[name], true)
							ReanchorTooltip(GameTooltip, myButton)
						end)
						myButton:HookScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					else
						-- Unknown custom buttons
						local myButton = LibStub("LibDBIcon-1.0"):GetMinimapButton("LeaPlusCustomIcon_" .. name)
						myButton:HookScript("OnEnter", function()
							GameTooltip:SetOwner(myButton, "ANCHOR_TOP")
							GameTooltip:AddLine(name)
							GameTooltip:AddLine(L["This is a custom button.  Please ask the addon author to use the standard LibDBIcon library instead."], 1, 1, 1, true)
							GameTooltip:Show()
							ReanchorTooltip(GameTooltip, myButton)
						end)
						myButton:HookScript("OnLeave", function()
							GameTooltip:Hide()
						end)
					end
				end

				-- Create LibDBIcon buttons for these addons that have LibDBIcon prefixes
				local customButtonTable = {
					"LibDBIcon10_MethodRaidTools", -- Method Raid Tools
					"LibDBIcon10_WoWtility", -- Wowtility
				}

				-- Do not create LibDBIcon buttons for these special case buttons
				local BypassButtonTable = {
					"SexyMapZoneTextButton", -- SexyMap
					"Narci_MinimapButton", -- Narcissus
				}

				-- Some buttons have less than 3 regions.  These need to be manually defined below.
				local LowRegionCountButtons = {
					"AllTheThings-Minimap", -- AllTheThings
					"OOMinimapButton", -- OmniumObservator
				}

				-- Function to loop through minimap children to find non-standard addon buttons
				local function MakeButtons()
					local temp = {Minimap:GetChildren()}
					for i = 1, #temp do
						if temp[i] then
							local btn = temp[i]
							local name = btn:GetName()
							local btype = btn:GetObjectType()
							if name and btype == "Button" and not CustomAddonTable[name] and (btn:GetNumRegions() >= 3 or table.contains(LowRegionCountButtons, name)) and not issecurevariable(name) and btn:IsShown() then
								if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), strlower("##" .. name)) then
									if not string.find(name, "LibDBIcon") and not table.contains(BypassButtonTable, name) or table.contains(customButtonTable, name) then
										CreateBadButton(name)
										btn:Hide()
										btn:SetScript("OnShow", function() btn:Hide() end)
									end
								end
							end
						end
					end
				end

				-- Run the function a few times on startup
				C_Timer.NewTicker(2, MakeButtons, 8)
				C_Timer.After(0.1, MakeButtons)

			end

			----------------------------------------------------------------------
			-- Hide addon buttons
			----------------------------------------------------------------------

			if LeaPlusLC["MinimapButtonBag"] == "Off" then

				-- Function to set button state
				local function SetHideButtons()
					if LeaPlusLC["HideMiniAddonButtons"] == "On" then
						-- Hide existing buttons
						local buttons = LibDBIconStub:GetButtonList()
						for i = 1, #buttons do
							local buttonName = strlower(buttons[i])
							if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
								LibDBIconStub:ShowOnEnter(buttons[i], true)
							end
						end
						-- Hide new buttons
						-- LibDBIcon_IconCreated: Done in LibDBIcon callback function
					else
						-- Show existing buttons
						local buttons = LibDBIconStub:GetButtonList()
						for i = 1, #buttons do
							local buttonName = strlower(buttons[i])
							if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
								LibDBIconStub:ShowOnEnter(buttons[i], false)
							end
						end
						-- Show new buttons
						-- LibDBIcon_IconCreated: Done in LibDBIcon callback function
					end
				end

				-- Assign file level scope (it's used in reset and preset)
				LeaPlusLC.SetHideButtons = SetHideButtons

				-- Set buttons when option is clicked and on startup
				LeaPlusCB["HideMiniAddonButtons"]:HookScript("OnClick", SetHideButtons)
				SetHideButtons()

			end

			----------------------------------------------------------------------
			-- Buttons
			----------------------------------------------------------------------

			-- Hide help button
			SideMinimap.h:Hide()

			-- Back button handler
			SideMinimap.b:SetScript("OnClick", function()
				SideMinimap:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			SideMinimap.r.tiptext = SideMinimap.r.tiptext .. "|n|n" .. L["Note that this will not reset settings that require a UI reload."]
			SideMinimap.r:HookScript("OnClick", function()
				LeaPlusLC["MinimapEffect"] = 1; LeaPlusLC.SetMinimapEffect()
				LeaPlusLC["HideMiniAddonButtons"] = "On"; if LeaPlusLC.SetHideButtons then LeaPlusLC:SetHideButtons() end
				LeaPlusLC["MiniClusterScale"] = 1; SetClusterScale()
				LeaPlusLC["MinimapBorderWidth"] = 3
				-- Refresh panel
				SideMinimap:Hide(); SideMinimap:Show()
			end)

			-- Configuration button handler
			LeaPlusCB["ModMinimapBtn"]:HookScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaPlusLC["MinimapEffect"] = 3; LeaPlusLC.SetMinimapEffect()
						LeaPlusLC["HideMiniAddonButtons"] = "On"; if LeaPlusLC.SetHideButtons then LeaPlusLC:SetHideButtons() end
						LeaPlusLC["HideMiniAddonMenu"] = "On"
						LeaPlusLC["MiniClusterScale"] = 1; SetClusterScale()
						LeaPlusLC["UnclampMinimap"] = "On"
						LeaPlusLC["MinimapBorderWidth"] = 3
						LeaPlusLC:ReloadCheck() -- Special reload check
					else
						-- Show configuration panel
						SideMinimap:Show()
						LeaPlusLC:HideFrames()
					end
				end
			end)

			-- LibDBIcon callback (search LibDBIcon_IconCreated to find calls to this)
			LibDBIconStub.RegisterCallback(miniFrame, "LibDBIcon_IconCreated", function(self, button, name)

				-- Minimap button bag: Hide new LibDBIcon icons
				if LeaPlusLC["MinimapButtonBag"] == "On" then
					--C_Timer.After(0.1, function() -- Removed for now
						local buttonName = strlower(name)

						-- Special case for MoveAny because it doesn't have button.db
						if buttonName == "moveany" then
							button.db = button.db or {}
							if not button.db.hide then button.db.hide = false end
						end

						if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
							if button.db and not button.db.hide then
								button:Hide()
								button:SetScript("OnShow", function() if not LeaPlusLC.bFrame:IsShown() then button:Hide() end end)
							end
							-- Create background texture
							local bFrameBg = button:CreateTexture(nil, "BACKGROUND")
							bFrameBg:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
							bFrameBg:SetPoint("CENTER")
							bFrameBg:SetSize(30, 30)
							bFrameBg:SetVertexColor(0, 0, 0, 0.5)
						end
						-- Move GameTooltip to below the minimap in case the button uses it
						button:HookScript("OnEnter", LeaPlusLC.SetButtonTooltip)
					--end)
				end

				-- Hide addon buttons: Hide new LibDBIcon icons
				if LeaPlusLC["MinimapButtonBag"] == "Off" then
					local buttonName = strlower(name)
					if LeaPlusLC["HideMiniAddonButtons"] == "On" then
						-- Hide addon buttons is enabled
						if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
							LibDBIconStub:ShowOnEnter(name, true)
						end
					else
						-- Hide addon buttons is disabled
						if not strfind(strlower(LeaPlusDB["MiniExcludeList"]), buttonName) then
							LibDBIconStub:ShowOnEnter(name, false)
						end
					end
				end

			end)

		end

		----------------------------------------------------------------------
		-- Show ready timer
		----------------------------------------------------------------------

		if LeaPlusLC["ShowReadyTimer"] == "On" then


			-- Dungeons and Raids
			do

				-- Declare variables
				local duration, barTime = 40, -1
				local t = duration

				-- Create status bar below dungeon ready popup
				local bar = CreateFrame("StatusBar", nil, LFGDungeonReadyPopup)
				bar:SetPoint("TOPLEFT", LFGDungeonReadyPopup, "BOTTOMLEFT", 0, -5)
				bar:SetPoint("TOPRIGHT", LFGDungeonReadyPopup, "BOTTOMRIGHT", 0, -5)
				bar:SetHeight(5)
				bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
				bar:SetStatusBarColor(1.0, 0.85, 0.0)
				bar:SetMinMaxValues(0, duration)

				-- Create status bar text
				local text = bar:CreateFontString(nil, "ARTWORK")
				text:SetFontObject("GameFontNormalLarge")
				text:SetTextColor(1.0, 0.85, 0.0)
				text:SetPoint("TOP", 0, -10)

				-- Update bar as timer counts down
				bar:SetScript("OnUpdate", function(self, elapsed)
					t = t - elapsed
					if barTime >= 1 or barTime == -1 then
						self:SetValue(t)
						text:SetText(SecondsToTime(floor(t + 0.5)))
						barTime = 0
					end
					barTime = barTime + elapsed
				end)

				-- Show frame when dungeon ready frame shows
				local frame = CreateFrame("FRAME")
				frame:RegisterEvent("LFG_PROPOSAL_SHOW")
				frame:RegisterEvent("LFG_PROPOSAL_FAILED")
				frame:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
				frame:SetScript("OnEvent", function(self, event)
					if event == "LFG_PROPOSAL_SHOW" then
						t = duration
						barTime = -1
						bar:Show()
						-- Hide existing timer bars (such as BigWigs)
						local children = {LFGDungeonReadyPopup:GetChildren()}
						if children then
							for i, child in ipairs(children) do
								if child ~= bar then
									local objType = child:GetObjectType()
									if objType and objType == "StatusBar" then
										child:Hide()
									end
								end
							end
						end
					else
						bar:Hide()
					end
				end)

			end

			-- Player vs Player
			do

				-- Declare variables
				local t, barTime = -1, -1

				-- Create status bar below dungeon ready popup
				local bar = CreateFrame("StatusBar", nil, PVPReadyDialog)
				bar:SetPoint("TOPLEFT", PVPReadyDialog, "BOTTOMLEFT", 0, -5)
				bar:SetPoint("TOPRIGHT", PVPReadyDialog, "BOTTOMRIGHT", 0, -5)
				bar:SetHeight(5)
				bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
				bar:SetStatusBarColor(1.0, 0.85, 0.0)

				-- Create status bar text
				local text = bar:CreateFontString(nil, "ARTWORK")
				text:SetFontObject("GameFontNormalLarge")
				text:SetTextColor(1.0, 0.85, 0.0)
				text:SetPoint("TOP", 0, -10)

				-- Update bar as timer counts down
				bar:SetScript("OnUpdate", function(self, elapsed)
					t = t - elapsed
					if barTime >= 1 or barTime == -1 then
						self:SetValue(t)
						text:SetText(SecondsToTime(floor(t + 0.5)))
						barTime = 0
					end
					barTime = barTime + elapsed
				end)

				-- Show frame when PvP ready frame shows
				hooksecurefunc("PVPReadyDialog_Display", function(self, id)
					t = GetBattlefieldPortExpiration(id) + 1
					-- t = 89; -- debug
					if t and t > 1 then
						bar:SetMinMaxValues(0, t)
						barTime = -1
						bar:Show()
					else
						bar:Hide()
					end
				end)

				PVPReadyDialog:HookScript("OnHide", function()
					bar:Hide()
				end)

				-- Debug
				-- C_Timer.After(2, function() PVPReadyDialog_Display(PVPReadyDialog, 1, "Warsong Gulch", 0, "BATTLEGROUND", "", "DAMAGER"); bar:Show() end)

			end

		end

		----------------------------------------------------------------------
		-- Remove transforms (no reload required)
		----------------------------------------------------------------------

		do

			local transTable = {

				-- Single spell IDs
				["TransAqir"] = {318452}, -- Aqir Egg Cluster
				["TransAtomic"] = {399502}, -- Atomically Recalibrator toy
				["TransAtomGoblin"] = {1215363}, -- Atomically Regoblinator toy
				["TransBlight"] = {290224}, -- Detoxified Blight Grenade
				["TransLantern"] = {44212}, -- Weighted Jack-o'-Lantern
				["TransWitch"] = {279509}, -- Lucille's Sewing Needle (witch)
				["TransTurkey"] = {61781}, -- Turkey (Pilgrim's Bounty)
				["TransCursedPickaxe"] = {454405}, -- Cursed Pickaxe (weapon)

				-- Noblegarden: Noblegarden Bunny
				["TransNobleBunny"] = {
					--[[Noblegarden Bunny]] 61734,
					--[[Rabbit Costume]] 61716,
				},

				-- Spraybots
				["TransSpraybots"] = {
					--[[Paintbot Orange]] 301892,
					--[[Paintbot Blue]] 301893,
					--[[Paintbot Green]] 301894,
				},

				-- Hallowed Wand costumes
				["TransHallowed"] = {
					--[[Abomination]] 172010,
					--[[CancelBanshee]] 218132,
					--[[Bat]] 191703, 24732,
					--[[Gargoyle]] 191210,
					--[[Geist]] 172015,
					--[[Ghost]] 24735, 24736, 191698, 191700,
					--[[Ghoul]] 172008,
					--[[Leper Gnome]] 24712, 24713, 191701,
					--[[Nerubian]] 191211,
					--[[Ninja]] 24710, 24711, 191686, 191688,
					--[[Pirate]] 24708, 24709, 173958, 173959, 191682, 191683,
					--[[Skeleton]] 24723, 191702,
					--[[Slime]] 172003,
					--[[Spider]] 172020,
					--[[Wight]] 191208,
					--[[Wisp]] 24740,
				},

				-- Crafting professions
				["TransBlacksmithing"] 	= {--[[Blacksmithing: Suited for Smithing]] 388658,},
				["TransJewelcrafting"] 	= {--[[Jewelcrafting: An Eye For Shine]] 394015,},
				["TransTailoring"] 		= {--[[Tailoring: Wrapped Up In Weaving]] 391312,},
				["TransEngineering"] 	= {--[[Engineering: Ready To Build]] 394007,},
				["TransEnchanting"] 	= {--[[Enchanting: A Looker's Charm]] 394008,},
				["TransAlchemy"] 		= {--[[Alchemy: Spark of Madness]] 394003,},
				["TransInscription"] 	= {--[[Inscription: Artist's Duds]] 394016,},
				["TransLeatherworking"] = {--[[Leatherworking: Sculpting Leather Finery]] 394001,},

				-- Gathering professions
				["TransHerbalism"] 		= 	{--[[Herbalism: A Cultivator's Colors]] 394005,},
				["TransMining"] 		= 	{--[[Mining: Rockin' Mining Gear]] 394006,},
				["TransSkinning"] 		= 	{--[[Skinning: Dressed To Kill]] 394011,},

				-- Secondary professions
				["TransCooking"] 		= {--[[Cooking: What's Cookin', Good Lookin'?]] 391775,},
				["TransFishing"] 		= {--[[Fishing: Fishing For Attention 394009 - Handled separately]]},

				-- Noggenfogger Elixir
				["TransNoggenfogger"] = {
					--[[You feel light]] 16593, 1223630,
					--[[You feel smaller]] 16595, 1223629,
				},

				-- Reflecting Prism
				["TransReflectingPrism"] = {
					--[[Prismatic Reflection]] 163267,
				},

			}

			-- Give table file level scope (its used during logout and for admin command)
			LeaPlusLC["transTable"] = transTable

			-- Create local table for storing spell IDs that need to be removed
			local cTable = {}

			-- Load saved settings or set default values
			for k, v in pairs(transTable) do
				if LeaPlusDB[k] and type(LeaPlusDB[k]) == "string" and LeaPlusDB[k] == "On" or LeaPlusDB[k] == "Off" then
					LeaPlusLC[k] = LeaPlusDB[k]
				else
					LeaPlusLC[k] = "Off"
					LeaPlusDB[k] = "Off"
				end
			end

			-- Create scrolling configuration panel
			local transPanel = LeaPlusLC:CreatePanel("Remove transforms", "transPanel", true)

			-- Initialise row count
			local row = -1

			-- Add checkboxes
			row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Crafting professions", 16, -((row - 1) * 20) - 2)
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransBlacksmithing", "Blacksmithing", 16, -((row - 1) * 20) - 2, false, "If checked, the Suited for Smithing transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransJewelcrafting", "Jewelcrafting", 16, -((row - 1) * 20) - 2, false, "If checked, the An Eye For Shine transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransTailoring", "Tailoring", 16, -((row - 1) * 20) - 2, false, "If checked, the Wrapped Up In Weaving transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransEngineering", "Engineering", 16, -((row - 1) * 20) - 2, false, "If checked, the Ready To Build transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransEnchanting", "Enchanting", 16, -((row - 1) * 20) - 2, false, "If checked, the A Looker's Charm transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransAlchemy", "Alchemy", 16, -((row - 1) * 20) - 2, false, "If checked, the Spark of Madness transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransInscription", "Inscription", 16, -((row - 1) * 20) - 2, false, "If checked, the Artist's Duds transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransLeatherworking", "Leatherworking", 16, -((row - 1) * 20) - 2, false, "If checked, the Sculpting Leather Finery transform will be removed when applied.")

			row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Gathering professions", 16, -((row - 1) * 20) - 2)
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransHerbalism", "Herbalism", 16, -((row - 1) * 20) - 2, false, "If checked, the A Cultivator's Colors transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransMining", "Mining", 16, -((row - 1) * 20) - 2, false, "If checked, the Rockin' Mining Gear transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransSkinning", "Skinning", 16, -((row - 1) * 20) - 2, false, "If checked, the Dressed To Kill transform will be removed when applied.")

			row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Secondary professions", 16, -((row - 1) * 20) - 2)
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransCooking", "Cooking", 16, -((row - 1) * 20) - 2, false, "If checked, the What's Cookin', Good Lookin' transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransFishing", "Fishing", 16, -((row - 1) * 20) - 2, false, "If checked, the Fishing For Attention transform will be removed when applied.")

			row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Toys", 16, -((row - 1) * 20) - 2)
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransAqir", "Aqir Egg Cluster", 16, -((row - 1) * 20) - 2, false, "If checked, the Aqir Egg Cluster transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransAtomic", "Atomic Recalibrator", 16, -((row - 1)* 20) -2, false, "If checked, the Atomic Recalibrator transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransAtomGoblin", "Atomic Regoblinator", 16, -((row - 1)* 20) -2, false, "If checked, the Atomic Regoblinator transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransBlight", "Detoxified Blight Grenade", 16, -((row - 1) * 20) - 2, false, "If checked, the Detoxified Blight Grenade transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransWitch", "Lucille's Sewing Needle", 16, -((row - 1) * 20) - 2, false, "If checked, the Lucille's Sewing Needle transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransSpraybots", "Spraybots", 16, -((row - 1) * 20) - 2, false, "If checked, the Spraybot transforms will be removed when applied.")

			row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Events", 16,  -(row - 1) * 20 - 2)
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransHallowed", "Hallow's End: Hallowed Wand", 16,  -((row - 1) * 20) - 2, false, "If checked, the Hallowed Wand transforms will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransLantern", "Hallow's End: Weighted Jack-o'-Lantern", 16,  -((row - 1) * 20) - 2, false, "If checked, the Weighted Jack-o'-Lantern transform will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransNobleBunny", "Noblegarden: Noblegarden Bunny", 16,  -((row - 1) * 20) - 2, false, "If checked, the Noblegarden bunny transforms will be removed when applied.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransTurkey", "Pilgrim's Bounty: Turkey Shooter", 16,  -((row - 1) * 20) - 2, false, "If checked, the Turkey Shooter transform will be removed when applied.")

			row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Items", 16,  -(row - 1) * 20 - 2)
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransCursedPickaxe", "Cursed Pickaxe", 16,  -((row - 1) * 20) - 2, false, "If checked, the Cursed Pickaxe transform will be removed when applied.|n|nYou can mute the associated sounds with the mute game sounds combat shouts option.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransNoggenfogger", "Noggenfogger Elixir", 16,  -((row - 1) * 20) - 2, false, "If checked, the slow fall and shrink effects of Noggenfogger Elixir will be removed when applied while keeping the skeleton transform intact.")
			row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "TransReflectingPrism", "Reflecting Prism", 16,  -((row - 1) * 20) - 2, false, "If checked, the Reflecting Prism transform will be removed when applied.")

			-- Debug
			-- RemoveCommentToEnableDebug = true
			if RemoveCommentToEnableDebug then
				row = row + 2; LeaPlusLC:MakeTx(transPanel.scrollChild, "Debug", 16,  -(row - 1) * 20 - 2)
				row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "CancelDevotion", "Devotion Aura", 16, -((row - 1) * 20) - 2, false, "")
				transTable["CancelDevotion"] = {465}
				LeaPlusLC["CancelDevotion"] = "On"

				row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "CancelStealth", "Stealth", 16, -((row - 1) * 20) - 2, false, "")
				transTable["CancelStealth"] = {115191} -- Old: 1784
				LeaPlusLC["CancelStealth"] = "On"

				row = row + 1; LeaPlusLC:MakeCB(transPanel.scrollChild, "CancelIntel", "Intellect", 16, -((row - 1) * 20) - 2, false, "")
				transTable["CancelIntel"] = {1459}
				LeaPlusLC["CancelIntel"] = "On"
			end

			-- Function to populate cTable with spell IDs for settings that are enabled
			local function UpdateList()
				for k, v in pairs(transTable) do
					for j, spellID in pairs(v) do
						if LeaPlusLC[k] == "On" then
							cTable[spellID] = true
						else
							cTable[spellID] = nil
						end
					end
				end
			end

			-- Populate cTable on startup
			UpdateList()

			-- Special exception for fishing (loot frame remains open after fishing channeling stops and buff is removed if combat starts)
			local fishEvent = CreateFrame("FRAME")
			fishEvent:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
			fishEvent:SetScript("OnEvent", function(self, event, unit, void, spellID)
				if LeaPlusLC["NoTransforms"] == "On" and LeaPlusLC["TransFishing"] == "On" and canaccessvalue(spellID) and spellID == 131476 then -- Fishing
					if not C_Secrets.ShouldAurasBeSecret() then
						for i = 1, 40 do
							local BuffData = C_UnitAuras.GetBuffDataByIndex("player", i)
							if BuffData then
								local spellID = BuffData.spellId
								if spellID and canaccessvalue(spellID) and spellID == 394009 and not UnitAffectingCombat("player") then -- Fishing For Attention
									CancelUnitBuff("player", i)
								end
							end
						end
					end
				end
			end)
			LeaPlusCB["TransFishing"]:HookScript("OnClick", function() fishEvent:GetScript("OnEvent")("", "", "", "", 131476) end)

			-- Create frame for events
			local spellFrame = CreateFrame("FRAME")
			local fisherTicker, castingSpellID

			spellFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

			-- Function to cancel buffs
			local function eventFunc()
				if not C_Secrets.ShouldAurasBeSecret() then
					for i = 1, 40 do
						local BuffData = C_UnitAuras.GetBuffDataByIndex("player", i)
						if BuffData then
							local spellID = BuffData.spellId
							if spellID and canaccessvalue(spellID) and cTable[spellID] then
								if not UnitAffectingCombat("player") then
									CancelUnitBuff("player", i)
								end
							end
						end
					end
				end
			end

			-- Check for buffs
			spellFrame:SetScript("OnEvent", function(self, event, unit, updatedAuras)
				if event == "UNIT_AURA" then
					if updatedAuras then
						if canaccessvalue(updatedAuras.isFullUpdate) and updatedAuras.isFullUpdate then
							eventFunc()
						elseif canaccessvalue(updatedAuras.addedAuras) and updatedAuras.addedAuras then
							for void, aura in ipairs(updatedAuras.addedAuras) do
								if aura.spellId and canaccessvalue(aura.spellId) and cTable[aura.spellId] then
									eventFunc()
								end
							end
						end
					end
				elseif event == "PLAYER_REGEN_ENABLED" then

					-- Traverse buffs (will only run spell was found in cTable previously)
					if not C_Secrets.ShouldAurasBeSecret() then
						for i = 1, 40 do
							local BuffData = C_UnitAuras.GetBuffDataByIndex("player", i)
							if BuffData then
								local spellID = BuffData.spellId
								if spellID and canaccessvalue(spellID) and cTable[spellID] then
									CancelUnitBuff("player", i)
								end
							end
						end
					end
				end
			end)

			-- Function to set event
			local function SetTransformFunc()
				if LeaPlusLC["NoTransforms"] == "On" then
					eventFunc()
					spellFrame:RegisterUnitEvent("UNIT_AURA", "player")
					spellFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					spellFrame:UnregisterEvent("UNIT_AURA")
					spellFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
				end
			end

			-- Run set event function when option is clicked and on startup
			LeaPlusCB["NoTransforms"]:HookScript("OnClick", SetTransformFunc)
			if LeaPlusLC["NoTransforms"] == "On" then SetTransformFunc() end

			-- Set click width for checkboxes and run update when checkboxes are clicked
			for k, v in pairs(transTable) do
				--[[LeaPlusCB[k].f:SetWidth(80)
				if LeaPlusCB[k].f:GetStringWidth() > 80 then
					LeaPlusCB[k]:SetHitRectInsets(0, -70, 0, 0)
				else
					LeaPlusCB[k]:SetHitRectInsets(0, -LeaPlusCB[k].f:GetStringWidth() + 4, 0, 0)
				end]]
				LeaPlusCB[k]:HookScript("OnClick", function()
					UpdateList()
					eventFunc()
				end)
			end

			-- Help button hidden
			transPanel.h:Hide()

			-- Back button handler
			transPanel.b:SetScript("OnClick", function()
				transPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
				return
			end)

			-- Reset button handler
			transPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				for k, v in pairs(transTable) do
					LeaPlusLC[k] = "Off"
				end
				UpdateList()
				eventFunc()

				-- Refresh panel
				transPanel:Hide(); transPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["NoTransformsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					for k, v in pairs(transTable) do
						LeaPlusLC[k] = "On"
					end
					UpdateList()
					eventFunc()
				else
					transPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show train all button
		----------------------------------------------------------------------

		if LeaPlusLC["ShowTrainAllButton"] == "On" then

			-- Function to create train all button
			EventUtil.ContinueOnAddOnLoaded("Blizzard_TrainerUI",function()

				----------------------------------------------------------------------
				--	Train All button
				----------------------------------------------------------------------

				-- Create train all button
				LeaPlusLC:CreateButton("TrainAllButton", ClassTrainerFrame, "Train All", "BOTTOMLEFT", 344, 54, 0, 22, false, "")
				LeaPlusCB["TrainAllButton"]:ClearAllPoints()
				LeaPlusCB["TrainAllButton"]:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT", -1, 0)

				local gap = ClassTrainerFrame:GetWidth() - ClassTrainerFrameMoneyBg:GetWidth() - ClassTrainerTrainButton:GetWidth() - 13
				if LeaPlusCB["TrainAllButton"]:GetWidth() > gap then
					LeaPlusCB["TrainAllButton"]:GetFontString():SetWordWrap(false)
					LeaPlusCB["TrainAllButton"]:SetWidth(gap)
					LeaPlusCB["TrainAllButton"]:GetFontString():SetWidth(gap - 8)
				end

				-- Give button global scope (useful for compatibility with other addons and essential for ElvUI)
				_G.LeaPlusGlobalTrainAllButton = LeaPlusCB["TrainAllButton"]

				-- Button tooltip
				LeaPlusCB["TrainAllButton"]:SetScript("OnEnter", function(self)
					-- Get number of available skills and total cost
					local count, cost = 0, 0
					for i = 1, GetNumTrainerServices() do
						local void, isAvail = GetTrainerServiceInfo(i)
						if isAvail and isAvail == "available" then
							count = count + 1
							cost = cost + GetTrainerServiceCost(i)
						end
					end
					-- Show tooltip
					if count > 0 then
						GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 4)
						GameTooltip:ClearLines()
						if count > 1 then
							GameTooltip:AddLine(L["Train"] .. " " .. count .. " " .. L["skills for"] .. " " .. C_CurrencyInfo.GetCoinTextureString(cost))
						else
							GameTooltip:AddLine(L["Train"] .. " " .. count .. " " .. L["skill for"] .. " " .. C_CurrencyInfo.GetCoinTextureString(cost))
						end
						GameTooltip:Show()
					end
				end)

				-- Button click handler
				LeaPlusCB["TrainAllButton"]:SetScript("OnClick",function(self)
					for i = 1, GetNumTrainerServices() do
						local void, isAvail = GetTrainerServiceInfo(i)
						if isAvail and isAvail == "available" then
							BuyTrainerService(i)
						end
					end
				end)

				-- Enable button only when skills are available
				local skillsAvailable
				hooksecurefunc("ClassTrainerFrame_Update", function()
					skillsAvailable = false
					for i = 1, GetNumTrainerServices() do
						local void, isAvail = GetTrainerServiceInfo(i)
						if isAvail and isAvail == "available" then
							skillsAvailable = true
						end
					end
					LeaPlusCB["TrainAllButton"]:SetEnabled(skillsAvailable)
					-- Refresh tooltip
					if LeaPlusCB["TrainAllButton"]:IsMouseOver() and skillsAvailable then
						LeaPlusCB["TrainAllButton"]:GetScript("OnEnter")(LeaPlusCB["TrainAllButton"])
					end
				end)

				----------------------------------------------------------------------
				--	ElvUI fixes
				----------------------------------------------------------------------

				-- ElvUI fixes
				if LeaPlusLC.ElvUI then
					local E = LeaPlusLC.ElvUI
					if E.private.skins.blizzard.enable and E.private.skins.blizzard.trainer then
						LeaPlusCB["TrainAllButton"]:ClearAllPoints()
						LeaPlusCB["TrainAllButton"]:SetPoint("RIGHT", ClassTrainerTrainButton, "LEFT", -6, 0)
						E:GetModule("Skins"):HandleButton(_G.LeaPlusGlobalTrainAllButton)
						if LeaPlusCB["TrainAllButton"]:GetWidth() > gap then
							LeaPlusCB["TrainAllButton"]:GetFontString():SetWordWrap(false)
							LeaPlusCB["TrainAllButton"]:SetWidth(gap - 5)
							LeaPlusCB["TrainAllButton"]:GetFontString():SetWidth(gap - 8)
						end
					end
				end

			end)

		end

		----------------------------------------------------------------------
		-- Filter chat messages
		----------------------------------------------------------------------

		if LeaPlusLC["FilterChatMessages"] == "On" then

			-- Load LibChatAnims
			Leatrix_Plus:LeaPlusLCA()

			-- Create configuration panel
			local ChatFilterPanel = LeaPlusLC:CreatePanel("Filter chat messages", "ChatFilterPanel")

			LeaPlusLC:MakeTx(ChatFilterPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(ChatFilterPanel, "BlockSpellLinks", "Block spell links during combat", 16, -92, false, "If checked, messages containing spell links will be blocked while you are in combat.|n|nThis is useful for blocking spell interrupt spam.|n|nThis applies to the say, party, raid, instance, emote and yell channels.")
			LeaPlusLC:MakeCB(ChatFilterPanel, "BlockDrunkenSpam", "Block drunken spam", 16, -112, false, "If checked, drunken messages will be blocked unless they apply to your character.|n|nThis applies to the system channel.")
			LeaPlusLC:MakeCB(ChatFilterPanel, "BlockDuelSpam", "Block duel spam", 16, -132, false, "If checked, duel victory and retreat messages will be blocked unless your character took part in the duel.|n|nThis applies to the system channel.")
			LeaPlusLC:MakeCB(ChatFilterPanel, "BlockAngelisSinny", "Block Angelis and Sinny spam", 16, -152, false, "If checked, messages from Angelis and Sinny (part of Bondable Val'kyr Diadem and Bondable Sinstone toys) will be blocked.|n|nThis applies to the monster whisper channel.")

			-- Lock block drunken spam option for zhTW
			if GameLocale == "zhTW" then
				LeaPlusLC:LockItem(LeaPlusCB["BlockDrunkenSpam"], true)
				LeaPlusLC["BlockDrunkenSpam"] = "Off"
				LeaPlusDB["BlockDrunkenSpam"] = "Off"
				LeaPlusCB["BlockDrunkenSpam"].tiptext = LeaPlusCB["BlockDrunkenSpam"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot use this with your locale."]
			end

			-- Help button hidden
			ChatFilterPanel.h:Hide()

			-- Back button handler
			ChatFilterPanel.b:SetScript("OnClick", function()
				ChatFilterPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page3"]:Show()
				return
			end)

			local charName = GetUnitName("player")
			local charRealm = GetNormalizedRealmName()
			local nameRealm = charName .. "%%-" .. charRealm

			-- Localise Angelis and Sinny spam
				if GameLocale == "frFR" then L["Sinny"] = "Stèlon"		; L["Angelis"] = "Angélis"
			elseif GameLocale == "ptBR" then L["Sinny"] = "Pecadito"	; L["Angelis"] = "Ângelis"
			elseif GameLocale == "ruRU" then L["Sinny"] = "Грешок"		; L["Angelis"] = "Ангелис"
			elseif GameLocale == "koKR" then L["Sinny"] = "죄악이"			; L["Angelis"] = "안젤리스"
			elseif GameLocale == "zhTW" then L["Sinny"] = "罪罪"			; L["Angelis"] = "安吉莉丝"
			elseif GameLocale == "zhCN" then L["Sinny"] = "罪罪"			; L["Angelis"] = "安吉莉丝"
			elseif GameLocale == "deDE" then L["Sinny"] = "Sündi"
			elseif GameLocale == "esES" then L["Sinny"] = "Pecadín"
			elseif GameLocale == "esMX" then L["Sinny"] = "Pecadín"
			elseif GameLocale == "itIT" then L["Sinny"] = "Peccatello"
			end

			-- Chat filter
			local function ChatFilterFunc(self, event, msg, sender)
				-- Block duel spam
				if LeaPlusLC["BlockDuelSpam"] == "On" then
					-- Block duel messages unless you are part of the duel
					if msg:match(DUEL_WINNER_KNOCKOUT:gsub("%%1$s", "%.+"):gsub("%%2$s", "%.+")) or msg:match(DUEL_WINNER_RETREAT:gsub("%%1$s", "%.+"):gsub("%%2$s", "%.+")) then
						-- Player has defeated player in a duel.
						if msg:match(DUEL_WINNER_KNOCKOUT:gsub("%%1$s", charName):gsub("%%2$s", "%.+")) then return false end
						if msg:match(DUEL_WINNER_KNOCKOUT:gsub("%%1$s", nameRealm):gsub("%%2$s", "%.+")) then return false end
						if msg:match(DUEL_WINNER_KNOCKOUT:gsub("%%1$s", "%.+"):gsub("%%2$s", charName)) then return false end
						if msg:match(DUEL_WINNER_KNOCKOUT:gsub("%%1$s", "%.+"):gsub("%%2$s", nameRealm)) then return false end
						-- Player has fled from player in a duel.
						if msg:match(DUEL_WINNER_RETREAT:gsub("%%1$s", charName):gsub("%%2$s", "%.+")) then return false end
						if msg:match(DUEL_WINNER_RETREAT:gsub("%%1$s", nameRealm):gsub("%%2$s", "%.+")) then return false end
						if msg:match(DUEL_WINNER_RETREAT:gsub("%%1$s", "%.+"):gsub("%%2$s", charName)) then return false end
						if msg:match(DUEL_WINNER_RETREAT:gsub("%%1$s", "%.+"):gsub("%%2$s", nameRealm)) then return false end
						-- Block all duel messages not involving player
						return true
					end
				end
				-- Block spell links
				if LeaPlusLC["BlockSpellLinks"] == "On" and UnitAffectingCombat("player") then
					if msg:find("|Hspell") then return true end
				end
				-- Block drunken spam
				if LeaPlusLC["BlockDrunkenSpam"] == "On" then
					for i = 1, 4 do
						local drunk1 = _G["DRUNK_MESSAGE_ITEM_OTHER"..i]:gsub("%%s", "%s-")
						local drunk2 = _G["DRUNK_MESSAGE_OTHER"..i]:gsub("%%s", "%s-")
						if msg:match(drunk1) or msg:match(drunk2) then
							return true
						end
					end
				end
				-- Block Angelis and Sinny spam
				if LeaPlusLC["BlockAngelisSinny"] == "On" then
					if sender then
						if sender == L["Angelis"] or sender == L["Sinny"] then
							return true
						end
					end
				end
			end

			-- Enable or disable chat filter settings
			local function SetChatFilter()
				if LeaPlusLC["BlockSpellLinks"] == "On" then
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_SAY", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_PARTY", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_RAID", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_EMOTE", ChatFilterFunc)
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_YELL", ChatFilterFunc)
				else
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_SAY", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_PARTY", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_PARTY_LEADER", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_RAID", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_RAID_LEADER", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_EMOTE", ChatFilterFunc)
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_YELL", ChatFilterFunc)
				end
				if LeaPlusLC["BlockDrunkenSpam"] == "On" or LeaPlusLC["BlockDuelSpam"] == "On" then
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_SYSTEM", ChatFilterFunc)
				else
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_SYSTEM", ChatFilterFunc)
				end
				if LeaPlusLC["BlockAngelisSinny"] == "On" then
					ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_MONSTER_WHISPER", ChatFilterFunc)
				else
					ChatFrameUtil.RemoveMessageEventFilter("CHAT_MSG_MONSTER_WHISPER", ChatFilterFunc)
				end
			end

			-- Set chat filter when settings are clicked and on startup
			LeaPlusCB["BlockSpellLinks"]:HookScript("OnClick", SetChatFilter)
			LeaPlusCB["BlockDrunkenSpam"]:HookScript("OnClick", SetChatFilter)
			LeaPlusCB["BlockDuelSpam"]:HookScript("OnClick", SetChatFilter)
			LeaPlusCB["BlockAngelisSinny"]:HookScript("OnClick", SetChatFilter)
			SetChatFilter()

			-- Reset button handler
			ChatFilterPanel.r:SetScript("OnClick", function()

				-- Reset controls
				LeaPlusLC["BlockSpellLinks"] = "Off"
				LeaPlusLC["BlockDrunkenSpam"] = "Off"
				LeaPlusLC["BlockDuelSpam"] = "Off"
				LeaPlusLC["BlockAngelisSinny"] = "Off"
				SetChatFilter()

				-- Refresh configuration panel
				ChatFilterPanel:Hide(); ChatFilterPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["FilterChatMessagesBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["BlockSpellLinks"] = "On"
					LeaPlusLC["BlockDrunkenSpam"] = "On"
					LeaPlusLC["BlockDuelSpam"] = "On"
					LeaPlusLC["BlockAngelisSinny"] = "On"
					SetChatFilter()
				else
					ChatFilterPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Automatically accept resurrection requests (no reload required)
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local AcceptResPanel = LeaPlusLC:CreatePanel("Accept resurrection", "AcceptResPanel")

			LeaPlusLC:MakeTx(AcceptResPanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(AcceptResPanel, "AutoResNoCombat", "Exclude combat resurrection", 16, -92, false, "If checked, resurrection requests will not be automatically accepted if the player resurrecting you is in combat.")
			LeaPlusLC:MakeCB(AcceptResPanel, "AutoResNoAfterlife", "Exclude afterlife resurrection", 16, -112, false, "If checked, resurrection requests will not be automatically accepted if the player resurrecting you is dead and in the afterlife.")

			-- Help button hidden
			AcceptResPanel.h:Hide()

			-- Back button handler
			AcceptResPanel.b:SetScript("OnClick", function()
				AcceptResPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page1"]:Show();
				return
			end)

			-- Reset button handler
			AcceptResPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["AutoResNoCombat"] = "On"
				LeaPlusLC["AutoResNoAfterlife"] = "Off"

				-- Refresh panel
				AcceptResPanel:Hide(); AcceptResPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["AutoAcceptResBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["AutoResNoCombat"] = "On"
					LeaPlusLC["AutoResNoAfterlife"] = "Off"
				else
					AcceptResPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Function to set resurrect event
			local function SetResEvent()
				if LeaPlusLC["AutoAcceptRes"] == "On" then
					AcceptResPanel:RegisterEvent("RESURRECT_REQUEST")
				else
					AcceptResPanel:UnregisterEvent("RESURRECT_REQUEST")
				end
			end

			-- Run function when option is clicked and on startup if option is enabled
			LeaPlusCB["AutoAcceptRes"]:HookScript("OnClick", SetResEvent)
			if LeaPlusLC["AutoAcceptRes"] == "On" then SetResEvent() end

			-- Handle event
			AcceptResPanel:SetScript("OnEvent", function(self, event, arg1)
				if event == "RESURRECT_REQUEST" then

					-- Exclude afterlife resurrection (such as a holy priest with the Afterlife talent)
					if LeaPlusLC["AutoResNoAfterlife"] == "On" and UnitIsDead(arg1) then return end

					-- Exclude pylon and brazier requests
					local pylonLoc

					-- Exclude Failure Detection Pylon
					pylonLoc = "Failure Detection Pylon"
					if 	   GameLocale == "zhCN" then pylonLoc = "故障检测晶塔"
					elseif GameLocale == "zhTW" then pylonLoc = "滅團偵測水晶塔"
					elseif GameLocale == "ruRU" then pylonLoc = "Пилон для обнаружения проблем"
					elseif GameLocale == "koKR" then pylonLoc = "고장 감지 변환기"
					elseif GameLocale == "esMX" then pylonLoc = "Pilón detector de errores"
					elseif GameLocale == "ptBR" then pylonLoc = "Pilar Detector de Falhas"
					elseif GameLocale == "deDE" then pylonLoc = "Fehlschlagdetektorpylon"
					elseif GameLocale == "esES" then pylonLoc = "Pilón detector de errores"
					elseif GameLocale == "frFR" then pylonLoc = "Pylône de détection des échecs"
					elseif GameLocale == "itIT" then pylonLoc = "Pilone d'Individuazione Fallimenti"
					end
					if arg1 == pylonLoc then return	end

					-- Exclude Brazier of Awakening
					pylonLoc = "Brazier of Awakening"
					if 	   GameLocale == "zhCN" then pylonLoc = "觉醒火盆"
					elseif GameLocale == "zhTW" then pylonLoc = "覺醒火盆"
					elseif GameLocale == "ruRU" then pylonLoc = "Жаровня пробуждения"
					elseif GameLocale == "koKR" then pylonLoc = "각성의 화로"
					elseif GameLocale == "esMX" then pylonLoc = "Blandón del Despertar"
					elseif GameLocale == "ptBR" then pylonLoc = "Braseiro do Despertar"
					elseif GameLocale == "deDE" then pylonLoc = "Kohlenbecken des Erwachens"
					elseif GameLocale == "esES" then pylonLoc = "Blandón de Despertar"
					elseif GameLocale == "frFR" then pylonLoc = "Brasero de l'Éveil"
					elseif GameLocale == "itIT" then pylonLoc = "Braciere del Risveglio"
					end
					if arg1 == pylonLoc then return	end

					-- Manage other resurrection requests
					if not UnitAffectingCombat(arg1) or LeaPlusLC["AutoResNoCombat"] == "Off" then
						AcceptResurrect()
						StaticPopup_Hide("RESURRECT_NO_TIMER")
					end
					return

				end
			end)

		end

		----------------------------------------------------------------------
		-- Hide keybind text
		----------------------------------------------------------------------

		if LeaPlusLC["HideKeybindText"] == "On" and not LeaLockList["HideKeybindText"] then

			-- Hide bind text
			for i = 1, 12 do
				_G["ActionButton"..i.."HotKey"]:SetAlpha(0) -- Main bar
				_G["MultiBarBottomRightButton"..i.."HotKey"]:SetAlpha(0) -- Bottom right bar
				_G["MultiBarBottomLeftButton"..i.."HotKey"]:SetAlpha(0) -- Bottom left bar
				_G["MultiBarRightButton"..i.."HotKey"]:SetAlpha(0) -- Right bar
				_G["MultiBarLeftButton"..i.."HotKey"]:SetAlpha(0) -- Left bar
				_G["MultiBar5Button" .. i .. "HotKey"]:SetAlpha(0) -- Dragonflight new bars
				_G["MultiBar6Button" .. i .. "HotKey"]:SetAlpha(0) -- Dragonflight new bars
				_G["MultiBar7Button" .. i .. "HotKey"]:SetAlpha(0) -- Dragonflight new bars
			end

		end

		----------------------------------------------------------------------
		-- Hide macro text
		----------------------------------------------------------------------

		if LeaPlusLC["HideMacroText"] == "On" and not LeaLockList["HideMacroText"] then

			-- Hide marco text
			for i = 1, 12 do
				_G["ActionButton"..i.."Name"]:SetAlpha(0) -- Main bar
				_G["MultiBarBottomRightButton"..i.."Name"]:SetAlpha(0) -- Bottom right bar
				_G["MultiBarBottomLeftButton"..i.."Name"]:SetAlpha(0) -- Bottom left bar
				_G["MultiBarRightButton"..i.."Name"]:SetAlpha(0) -- Right bar
				_G["MultiBarLeftButton"..i.."Name"]:SetAlpha(0) -- Left bar
				_G["MultiBar5Button" .. i .. "Name"]:SetAlpha(0) -- Dragonflight new bars
				_G["MultiBar6Button" .. i .. "Name"]:SetAlpha(0) -- Dragonflight new bars
				_G["MultiBar7Button" .. i .. "Name"]:SetAlpha(0) -- Dragonflight new bars
			end

		end

		----------------------------------------------------------------------
		-- Automatically release in battlegrounds
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local ReleasePanel = LeaPlusLC:CreatePanel("Release in PvP", "ReleasePanel")

			LeaPlusLC:MakeTx(ReleasePanel, "Settings", 16, -72)
			LeaPlusLC:MakeCB(ReleasePanel, "AutoReleaseNoAlterac", "Exclude Alterac Valley", 16, -92, false, "If checked, you will not release automatically in Alterac Valley.")
			LeaPlusLC:MakeCB(ReleasePanel, "AutoReleaseNoWintergsp", "Exclude Wintergrasp", 16, -112, false, "If checked, you will not release automatically in Wintergrasp.")
			LeaPlusLC:MakeCB(ReleasePanel, "AutoReleaseNoTolBarad", "Exclude Tol Barad (PvP)", 16, -132, false, "If checked, you will not release automatically in Tol Barad (PvP).")
			LeaPlusLC:MakeCB(ReleasePanel, "AutoReleaseNoAshran", "Exclude Ashran", 16, -152, false, "If checked, you will not release automatically in Ashran.")
			-- Debug -- LeaPlusLC:MakeCB(ReleasePanel, "AutoReleaseNoStormwind", "Exclude Stormwind (debug)", 16, -172, false, "If checked, you will not release automatically in Stormwind.")

			LeaPlusLC:MakeTx(ReleasePanel, "Delay", 356, -72)
			LeaPlusLC:MakeSL(ReleasePanel, "AutoReleaseDelay", "Drag to set the number of milliseconds before you are automatically released.|n|nYou can hold down shift as the timer is ending to cancel the automatic release.", 0, 3000, 100, 356, -92, "%.0f")

			-- Help button hidden
			ReleasePanel.h:Hide()

			-- Back button handler
			ReleasePanel.b:SetScript("OnClick", function()
				ReleasePanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page1"]:Show();
				return
			end)

			-- Reset button handler
			ReleasePanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["AutoReleaseNoAlterac"] = "Off"
				LeaPlusLC["AutoReleaseNoWintergsp"] = "Off"
				LeaPlusLC["AutoReleaseNoTolBarad"] = "Off"
				LeaPlusLC["AutoReleaseNoAshran"] = "Off"
				LeaPlusLC["AutoReleaseDelay"] = 0

				-- Refresh panel
				ReleasePanel:Hide(); ReleasePanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["AutoReleasePvPBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["AutoReleaseNoAlterac"] = "Off"
					LeaPlusLC["AutoReleaseNoWintergsp"] = "Off"
					LeaPlusLC["AutoReleaseNoTolBarad"] = "Off"
					LeaPlusLC["AutoReleaseNoAshran"] = "Off"
					LeaPlusLC["AutoReleaseDelay"] = 0
				else
					ReleasePanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Release in battlegrounds
			hooksecurefunc("StaticPopup_Show", function(sType)
				if sType and sType == "DEATH" and LeaPlusLC["AutoReleasePvP"] == "On" then
					if C_DeathInfo.GetSelfResurrectOptions() and #C_DeathInfo.GetSelfResurrectOptions() > 0 then return end
					local InstStat, InstType = IsInInstance()
					-- if not CommentOutToRemoveDebugOnlyMode then InstStat = true; InstType = "pvp" end -- (DEBUG ONLY)
					if InstStat and InstType == "pvp" then
						-- Exclude specific maps
						local mapID = C_Map.GetBestMapForUnit("player") or nil
						if mapID then
							if mapID == 91 and LeaPlusLC["AutoReleaseNoAlterac"] == "On" then return end -- Alterac Valley
							if mapID == 1537 and LeaPlusLC["AutoReleaseNoAlterac"] == "On" then return end -- Alterac Valley
							if mapID == 1334 and LeaPlusLC["AutoReleaseNoWintergsp"] == "On" then return end -- Wintergrasp (instanced)
							if mapID == 1478 and LeaPlusLC["AutoReleaseNoAshran"] == "On" then return end -- Ashran (instanced)
							-- if mapID == 84 then return end -- Exclude Stormwind (DEBUG ONLY)
						end
						-- Release automatically in PvP
						local delay = LeaPlusLC["AutoReleaseDelay"] / 1000
						C_Timer.After(delay, function()
							local dialog = StaticPopup_Visible("DEATH")
							if dialog then
								if IsShiftKeyDown() then
									LeaPlusLC:DisplayMessage(L["Automatic Release Cancelled"], true)
								else
									StaticPopup_OnClick(_G[dialog], 1)
								end
							end
						end)
					end
					local areaID = C_Map.GetBestMapForUnit("player") or 0
					if areaID == 123 and LeaPlusLC["AutoReleaseNoWintergsp"] == "Off" -- Wintergrasp
					or areaID == 244 and LeaPlusLC["AutoReleaseNoTolBarad"] == "Off" -- Tol Barad (PvP)
					or areaID == 588 and LeaPlusLC["AutoReleaseNoAshran"] == "Off" -- Ashran
					or areaID == 622 and LeaPlusLC["AutoReleaseNoAshran"] == "Off" -- Stormshield
					or areaID == 624 and LeaPlusLC["AutoReleaseNoAshran"] == "Off" -- Warspear
					-- or areaID == 84 -- Stormwind (DEBUG ONLY)
					then
						-- Release automatically in world zones
						local delay = LeaPlusLC["AutoReleaseDelay"] / 1000
						C_Timer.After(delay, function()
							local dialog = StaticPopup_Visible("DEATH")
							if dialog then
								if IsShiftKeyDown() then
									LeaPlusLC:DisplayMessage(L["Automatic Release Cancelled"], true)
								else
									StaticPopup_OnClick(_G[dialog], 1)
								end
							end
						end)
					end
				end
			end)

		end

		----------------------------------------------------------------------
		--	Sync from friends (no reload required)
		----------------------------------------------------------------------

		do

			hooksecurefunc(QuestSessionManager.StartDialog, "Show", function(self)
				if LeaPlusLC["SyncFromFriends"] == "On" then
					local details = C_QuestSession.GetSessionBeginDetails()
					if details then
						for index, unit in ipairs({"player", "party1", "party2", "party3", "party4",}) do
							local guid = UnitGUID(unit)
							if guid == details.guid then
								local requesterName = UnitName(unit)
								if not canaccessvalue(requesterName) then return end
								if requesterName and LeaPlusLC:FriendCheck(requesterName, guid) then
									self.ButtonContainer.Confirm:Click()
								end
								return
							end
						end
					end
				end
			end)

		end

		----------------------------------------------------------------------
		--	Set weather density (no reload required)
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local weatherPanel = LeaPlusLC:CreatePanel("Set weather density", "weatherPanel")
			LeaPlusLC:MakeTx(weatherPanel, "Settings", 16, -72)
			LeaPlusLC:MakeSL(weatherPanel, "WeatherLevel", "Drag to set the density of weather effects.", 0, 3, 1, 16, -92, "%.0f")

			local weatherSliderTable = {L["Off"], L["Low"], L["Medium"], L["High"]}

			-- Function to set the weather density
			local function SetWeatherFunc()
				LeaPlusCB["WeatherLevel"].f:SetText(LeaPlusLC["WeatherLevel"] .. "  (" .. weatherSliderTable[LeaPlusLC["WeatherLevel"] + 1] .. ")")
				if LeaPlusLC["SetWeatherDensity"] == "On" then
					SetCVar("WeatherDensity", LeaPlusLC["WeatherLevel"])
					SetCVar("RAIDweatherDensity", LeaPlusLC["WeatherLevel"])
				else
					SetCVar("WeatherDensity", "3")
					SetCVar("RAIDweatherDensity", "3")
				end
			end

			-- Set weather density when options are clicked and on startup if option is enabled
			LeaPlusCB["SetWeatherDensity"]:HookScript("OnClick", SetWeatherFunc)
			LeaPlusCB["WeatherLevel"]:HookScript("OnValueChanged", SetWeatherFunc)
			if LeaPlusLC["SetWeatherDensity"] == "On" then SetWeatherFunc() end

			-- Prevent weather density from being changed when particle density is changed
			hooksecurefunc("SetCVar", function(setting, value)
				if setting and LeaPlusLC["SetWeatherDensity"] == "On" then
					if setting == "graphicsParticleDensity" then
						if GetCVar("WeatherDensity") ~= LeaPlusLC["WeatherLevel"] then
							C_Timer.After(0.1, function()
								SetCVar("WeatherDensity", LeaPlusLC["WeatherLevel"])
							end)
						end
					elseif setting == "raidGraphicsParticleDensity" then
						if GetCVar("RAIDweatherDensity") ~= LeaPlusLC["WeatherLevel"] then
							C_Timer.After(0.1, function()
								SetCVar("RAIDweatherDensity", LeaPlusLC["WeatherLevel"])
							end)
						end
					end
				end
			end)

			-- Help button hidden
			weatherPanel.h:Hide()

			-- Back button handler
			weatherPanel.b:SetScript("OnClick", function()
				weatherPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page7"]:Show()
				return
			end)

			-- Reset button handler
			weatherPanel.r:SetScript("OnClick", function()

				-- Reset slider
				LeaPlusLC["WeatherLevel"] = 3

				-- Refresh side panel
				weatherPanel:Hide(); weatherPanel:Show()

			end)

			-- Show configuration panal when options panel button is clicked
			LeaPlusCB["SetWeatherDensityBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["WeatherLevel"] = 0
					SetWeatherFunc()
				else
					weatherPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

		end

		----------------------------------------------------------------------
		--	Remove raid restrictions (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set raid restrictions
			local function SetRaidFunc()
				if LeaPlusLC["NoRaidRestrictions"] == "On" then
					SetAllowLowLevelRaid(true)
				else
					SetAllowLowLevelRaid(false)
				end
			end

			-- Run function when option is clicked and on startup (if enabled)
			LeaPlusCB["NoRaidRestrictions"]:HookScript("OnClick", SetRaidFunc)
			if LeaPlusLC["NoRaidRestrictions"] == "On" then SetRaidFunc() end

		end

		----------------------------------------------------------------------
		-- Disable screen glow (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set screen glow
			local function SetGlow()
				if LeaPlusLC["NoScreenGlow"] == "On" then
					SetCVar("ffxGlow", "0")
				else
					SetCVar("ffxGlow", "1")
				end
			end

			-- Set screen glow on startup and when option is clicked (if enabled)
			LeaPlusCB["NoScreenGlow"]:HookScript("OnClick", SetGlow)
			if LeaPlusLC["NoScreenGlow"] == "On" then SetGlow() end

		end

		----------------------------------------------------------------------
		-- Disable screen effects (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set screen effects
			local function SetEffects()
				if LeaPlusLC["NoScreenEffects"] == "On" then
					SetCVar("ffxDeath", "0")
					SetCVar("ffxNether", "0")
					SetCVar("ffxVenari", "0")
					SetCVar("ffxLingeringVenari", "0")
				else
					SetCVar("ffxDeath", "1")
					SetCVar("ffxNether", "1")
					SetCVar("ffxVenari", "1")
					SetCVar("ffxLingeringVenari", "1")
				end
			end

			-- Set screen effects when option is clicked and on startup (if enabled)
			LeaPlusCB["NoScreenEffects"]:HookScript("OnClick", SetEffects)
			if LeaPlusLC["NoScreenEffects"] == "On" then SetEffects() end

		end

		----------------------------------------------------------------------
		--	Max camera zoom (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set camera zoom
			local function SetZoom()
				if LeaPlusLC["MaxCameraZoom"] == "On" then
					SetCVar("cameraDistanceMaxZoomFactor", 2.6)
				else
					SetCVar("cameraDistanceMaxZoomFactor", 1.9)
				end
			end

			-- Set camera zoom when option is clicked and on startup (if enabled)
			LeaPlusCB["MaxCameraZoom"]:HookScript("OnClick", SetZoom)
			if LeaPlusLC["MaxCameraZoom"] == "On" then SetZoom() end

		end

		----------------------------------------------------------------------
		-- Universal group chat color (no reload required)
		----------------------------------------------------------------------

		do

			-- Function to set chat colors
			local function SetCol()
				if LeaPlusLC["UnivGroupColor"] == "On" then
					ChangeChatColor("RAID", 0.67, 0.67, 1)
					ChangeChatColor("RAID_LEADER", 0.46, 0.78, 1)
					ChangeChatColor("INSTANCE_CHAT", 0.67, 0.67, 1)
					ChangeChatColor("INSTANCE_CHAT_LEADER", 0.46, 0.78, 1)
				else
					ChangeChatColor("RAID", 1, 0.50, 0)
					ChangeChatColor("RAID_LEADER", 1, 0.28, 0.04)
					ChangeChatColor("INSTANCE_CHAT", 1, 0.50, 0)
					ChangeChatColor("INSTANCE_CHAT_LEADER", 1, 0.28, 0.04)
				end
			end

			-- Set chat colors when option is clicked and on startup (if enabled)
			LeaPlusCB["UnivGroupColor"]:HookScript("OnClick", SetCol)
			if LeaPlusLC["UnivGroupColor"] == "On" then	SetCol() end

		end

		----------------------------------------------------------------------
		-- Minimap button (no reload required)
		----------------------------------------------------------------------

		do

			-- Minimap button click function
			local function MiniBtnClickFunc(arg1, arg2)

				if arg1 == "Leatrix_Plus" then arg1 = "LeftButton" end -- Needed for compartment menu clicks

				-- Prevent options panel from showing if Blizzard Store is showing
				if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
				-- Left button down
				if arg1 == "LeftButton" or arg2 and arg2 == "LeftButton" then

					-- Control key toggles target tracking
					if IsControlKeyDown() and not IsShiftKeyDown() and not IsAltKeyDown() then
						for i = 1, C_Minimap.GetNumTrackingTypes() do
							local trackingInfo = C_Minimap.GetTrackingInfo(i)
							if trackingInfo.name and trackingInfo.name == MINIMAP_TRACKING_TARGET then
								if trackingInfo.active then
									C_Minimap.SetTracking(i, false)
									LeaPlusLC:DisplayMessage(L["Target Tracking Disabled"], true)
								else
									C_Minimap.SetTracking(i, true)
									LeaPlusLC:DisplayMessage(L["Target Tracking Enabled"], true)
								end
							end
						end
						return
					end

					-- Shift key toggles music
					if IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() then
						Sound_ToggleMusic()
						return
					end

					-- Control key and alt key toggles Zygor addon
					if IsControlKeyDown() and IsAltKeyDown() and not IsShiftKeyDown() then
						LeaPlusLC:ZygorToggle()
						return
					end

					-- Alt key toggles error messages
					if IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown() then
						if LeaPlusDB["HideErrorMessages"] == "On" then -- Checks global
							if LeaPlusLC["ShowErrorsFlag"] == 1 then
								LeaPlusLC["ShowErrorsFlag"] = 0
								LeaPlusLC:DisplayMessage(L["Error messages will be shown"], true)
							else
								LeaPlusLC["ShowErrorsFlag"] = 1
								LeaPlusLC:DisplayMessage(L["Error messages will be hidden"], true)
							end
							return
						end
						return
					end

					-- Control key and shift key toggles maximised window mode
					if IsControlKeyDown() and IsShiftKeyDown() and not IsAltKeyDown() then
						if LeaPlusLC:PlayerInCombat() then
							return
						else
							SetCVar("gxMaximize", tostring(1 - GetCVar("gxMaximize")))
							UpdateWindow()
						end
						return
					end

					-- No modifier key toggles the options panel
					if LeaPlusLC:IsPlusShowing() then
						LeaPlusLC:HideFrames()
						LeaPlusLC:HideConfigPanels()
					else
						LeaPlusLC:HideFrames()
						LeaPlusLC["PageF"]:Show()
					end
					LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
				end

				-- Right button down
				if arg1 == "RightButton" or arg2 and arg2 == "RightButton" then

					-- No modifier key toggles the options panel
					if LeaPlusLC:IsPlusShowing() then
						LeaPlusLC:HideFrames()
						LeaPlusLC:HideConfigPanels()
					else
						LeaPlusLC:HideFrames()
						LeaPlusLC["PageF"]:Show()
					end
					LeaPlusLC["Page" .. LeaPlusLC["LeaStartPage"]]:Show()

				end

			end

			-- Assign global scope for function (it's used in TOC)
			_G.LeaPlusGlobalMiniBtnClickFunc = MiniBtnClickFunc

			-- Create minimap button using LibDBIcon
			local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("Leatrix_Plus", {
				type = "data source",
				text = "Leatrix Plus",
				icon = "Interface\\HELPFRAME\\ReportLagIcon-Movement",
				OnClick = function(self, btn)
					MiniBtnClickFunc(btn)
				end,
				OnTooltipShow = function(tooltip)
					if not tooltip or not tooltip.AddLine then return end
					tooltip:AddLine("Leatrix Plus")
				end,
			})

			local icon = LibStub("LibDBIcon-1.0", true)
			icon:Register("Leatrix_Plus", miniButton, LeaPlusDB)

			-- Function to toggle LibDBIcon
			local function SetLibDBIconFunc()
				if LeaPlusLC["ShowMinimapIcon"] == "On" then
					LeaPlusDB["hide"] = false
					icon:Show("Leatrix_Plus")
				else
					LeaPlusDB["hide"] = true
					icon:Hide("Leatrix_Plus")
				end
			end

			-- Set LibDBIcon when option is clicked and on startup
			LeaPlusCB["ShowMinimapIcon"]:HookScript("OnClick", SetLibDBIconFunc)
			SetLibDBIconFunc()

		end

		----------------------------------------------------------------------
		-- Show volume control on character frame
		----------------------------------------------------------------------

		if LeaPlusLC["ShowVolume"] == "On" then

			-- Function to update master volume
			local function MasterVolUpdate()
				if LeaPlusLC["ShowVolume"] == "On" then
					-- Set the volume
					SetCVar("Sound_MasterVolume", LeaPlusLC["LeaPlusMaxVol"]);
					-- Format the slider text
					LeaPlusCB["LeaPlusMaxVol"].f:SetFormattedText("%.0f", LeaPlusLC["LeaPlusMaxVol"] * 20)
				end
			end

			-- Create slider control
			LeaPlusLC["LeaPlusMaxVol"] = tonumber(GetCVar("Sound_MasterVolume"))
			LeaPlusLC:MakeSL(CharacterModelScene, "LeaPlusMaxVol", "",	0, 1, 0.05, -34, -328, "%.2f")
			LeaPlusCB["LeaPlusMaxVol"]:SetWidth(64)

			-- Set slider control value when shown
			LeaPlusCB["LeaPlusMaxVol"]:SetScript("OnShow", function()
				LeaPlusCB["LeaPlusMaxVol"]:SetValue(GetCVar("Sound_MasterVolume"))
			end)

			-- Update volume when slider control is changed
			LeaPlusCB["LeaPlusMaxVol"]:HookScript("OnValueChanged", function()
				if IsMouseButtonDown("RightButton") and IsShiftKeyDown() then
					-- Dual layout is active so don't adjust slider
					LeaPlusCB["LeaPlusMaxVol"].f:SetFormattedText("%.0f", LeaPlusLC["LeaPlusMaxVol"] * 20)
					LeaPlusCB["LeaPlusMaxVol"]:Hide()
					LeaPlusCB["LeaPlusMaxVol"]:Show()
					return
				else
					-- Set sound level and refresh slider
					MasterVolUpdate()
				end
			end)

			-- Dual layout
			local function SetVolumePlacement()
				if LeaPlusLC["ShowVolumeInFrame"] == "On" then
					LeaPlusCB["LeaPlusMaxVol"]:ClearAllPoints();
					LeaPlusCB["LeaPlusMaxVol"]:SetPoint("TOPLEFT", 72, -276)
				else
					LeaPlusCB["LeaPlusMaxVol"]:ClearAllPoints();
					LeaPlusCB["LeaPlusMaxVol"]:SetPoint("TOPLEFT", -34, -328)
				end
			end

			LeaPlusCB["LeaPlusMaxVol"]:SetScript('OnMouseDown', function(self, btn)
				if btn == "RightButton" and IsShiftKeyDown() then
					if LeaPlusLC["ShowVolumeInFrame"] == "On" then LeaPlusLC["ShowVolumeInFrame"] = "Off" else LeaPlusLC["ShowVolumeInFrame"] = "On" end
					SetVolumePlacement();
				end
			end)

			CharacterModelScene:HookScript("OnShow",function()
				SetVolumePlacement()
			end)

			-- ElvUI skin for slider control
			if LeaPlusLC.ElvUI then
				_G.LeaPlusGlobalVolumeButton = LeaPlusCB["LeaPlusMaxVol"]
				LeaPlusLC.ElvUI:GetModule("Skins"):HandleSliderFrame(_G.LeaPlusGlobalVolumeButton, false)
			end

		end

		----------------------------------------------------------------------
		--	Use arrow keys in chat
		----------------------------------------------------------------------

		if LeaPlusLC["UseArrowKeysInChat"] == "On" and not LeaLockList["UseArrowKeysInChat"] then
			-- Enable arrow keys for normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
				end
			end
			-- Enable arrow keys for temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf .. "EditBox"]:SetAltArrowKeyMode(false)
				end
			end)
		end

		----------------------------------------------------------------------
		-- Hide social button
		----------------------------------------------------------------------

		if LeaPlusLC["NoSocialButton"] == "On" and not LeaLockList["NoSocialButton"] then
			-- Create hidden frame to store social button
			local tframe = CreateFrame("FRAME")
			tframe:Hide()
			QuickJoinToastButton:SetParent(tframe)
		end

		----------------------------------------------------------------------
		-- L43: Manage widget top
		----------------------------------------------------------------------

		if LeaPlusLC["ManageWidgetTop"] == "On" and not LeaLockList["ManageWidgetTop"] then

			-- Create and manage container for UIWidgetTopCenterContainerFrame
			local topCenterHolder = CreateFrame("Frame", nil, UIParent)
			topCenterHolder:SetPoint("TOP", UIParent, "TOP", 0, -15)
			topCenterHolder:SetSize(10, 58)

			local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
			topCenterContainer:ClearAllPoints()
			topCenterContainer:SetPoint('CENTER', topCenterHolder)

			hooksecurefunc(topCenterContainer, 'SetPoint', function(self, void, b)
				if b and (b ~= topCenterHolder) then
					-- Reset parent if it changes from topCenterHolder
					self:ClearAllPoints()
					self:SetPoint('CENTER', topCenterHolder)
					self:SetParent(topCenterHolder)
				end
			end)

			-- Allow widget frame to be moved
			topCenterHolder:SetMovable(true)
			topCenterHolder:SetUserPlaced(true)
			topCenterHolder:SetDontSavePosition(true)
			topCenterHolder:SetClampedToScreen(false)

			-- Set widget frame position at startup
			topCenterHolder:ClearAllPoints()
			topCenterHolder:SetPoint(LeaPlusLC["WidgetTopA"], UIParent, LeaPlusLC["WidgetTopR"], LeaPlusLC["WidgetTopX"], LeaPlusLC["WidgetTopY"])
			topCenterHolder:SetScale(LeaPlusLC["WidgetTopScale"])
			UIWidgetTopCenterContainerFrame:SetScale(LeaPlusLC["WidgetTopScale"])

			-- Create drag frame
			local dragframe = CreateFrame("FRAME", nil, nil, "BackdropTemplate")
			dragframe:SetPoint("CENTER", topCenterHolder, "CENTER", 0, 1)
			dragframe:SetBackdropColor(0.0, 0.5, 1.0)
			dragframe:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = false, tileSize = 0, edgeSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0}})
			dragframe:SetToplevel(true)
			dragframe:Hide()
			dragframe:SetScale(LeaPlusLC["WidgetTopScale"])

			dragframe.t = dragframe:CreateTexture()
			dragframe.t:SetAllPoints()
			dragframe.t:SetColorTexture(0.0, 1.0, 0.0, 0.5)
			dragframe.t:SetAlpha(0.5)

			dragframe.f = dragframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
			dragframe.f:SetPoint('CENTER', 0, 0)
			dragframe.f:SetText(L["Widget Top"])

			-- Click handler
			dragframe:SetScript("OnMouseDown", function(self, btn)
				-- Start dragging if left clicked
				if btn == "LeftButton" then
					topCenterHolder:StartMoving()
				end
			end)

			dragframe:SetScript("OnMouseUp", function()
				-- Save frame position
				topCenterHolder:StopMovingOrSizing()
				LeaPlusLC["WidgetTopA"], void, LeaPlusLC["WidgetTopR"], LeaPlusLC["WidgetTopX"], LeaPlusLC["WidgetTopY"] = topCenterHolder:GetPoint()
				topCenterHolder:SetMovable(true)
				topCenterHolder:ClearAllPoints()
				topCenterHolder:SetPoint(LeaPlusLC["WidgetTopA"], UIParent, LeaPlusLC["WidgetTopR"], LeaPlusLC["WidgetTopX"], LeaPlusLC["WidgetTopY"])
			end)

			-- Snap-to-grid
			do
				local frame, grid = dragframe, 10
				local w, h = 0, 60
				local xpos, ypos, scale, uiscale
				frame:RegisterForDrag("RightButton")
				frame:HookScript("OnDragStart", function()
					frame:SetScript("OnUpdate", function()
						scale, uiscale = frame:GetScale(), UIParent:GetScale()
						xpos, ypos = GetCursorPosition()
						xpos = floor((xpos / scale / uiscale) / grid) * grid - w / 2
						ypos = ceil((ypos / scale / uiscale) / grid) * grid + h / 2
						topCenterHolder:ClearAllPoints()
						topCenterHolder:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", xpos, ypos)
					end)
				end)
				frame:HookScript("OnDragStop", function()
					frame:SetScript("OnUpdate", nil)
					frame:GetScript("OnMouseUp")()
				end)
			end

			-- Create configuration panel
			local WidgetTopPanel = LeaPlusLC:CreatePanel("Manage widget top", "WidgetTopPanel")

			-- Create Titan Panel screen adjust warning
			local titanFrame = CreateFrame("FRAME", nil, WidgetTopPanel)
			titanFrame:SetAllPoints()
			titanFrame:Hide()
			LeaPlusLC:MakeTx(titanFrame, "Warning", 16, -172)
			titanFrame.txt = LeaPlusLC:MakeWD(titanFrame, "Titan Panel frame adjustment needs to be disabled.", 16, -192, 500)
			titanFrame.txt:SetWordWrap(false)
			titanFrame.txt:SetWidth(520)
			titanFrame.btn = LeaPlusLC:CreateButton("fixTitanBtn", titanFrame, "Okay, disable frame adjustment for me", "TOPLEFT", 16, -212, 0, 25, true, "Click to disable Titan Panel frame adjustment.  Your UI will be reloaded.")
			titanFrame.btn:SetScript("OnClick", function()
				if C_AddOns.IsAddOnLoaded("Titan") and TitanPlayerSettings and TitanPlayerSettings.Adjust and TitanPlayerSettings.Adjust.UIWidgetTopCenterContainerFrame and TitanPlayerSettings.Adjust.UIWidgetTopCenterContainerFrame.adjust then
					TitanPlayerSettings.Adjust.UIWidgetTopCenterContainerFrame.adjust = false
					ReloadUI()
				end
			end)

			LeaPlusLC:MakeTx(WidgetTopPanel, "Scale", 16, -72)
			LeaPlusLC:MakeSL(WidgetTopPanel, "WidgetTopScale", "Drag to set the widget top scale.", 0.5, 2, 0.05, 16, -92, "%.2f")

			-- Set scale when slider is changed
			LeaPlusCB["WidgetTopScale"]:HookScript("OnValueChanged", function()
				topCenterHolder:SetScale(LeaPlusLC["WidgetTopScale"])
				UIWidgetTopCenterContainerFrame:SetScale(LeaPlusLC["WidgetTopScale"])
				dragframe:SetScale(LeaPlusLC["WidgetTopScale"])
				-- Show formatted slider value
				LeaPlusCB["WidgetTopScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["WidgetTopScale"] * 100)
			end)

			-- Hide frame alignment grid with panel
			WidgetTopPanel:HookScript("OnHide", function()
				LeaPlusLC.grid:Hide()
			end)

			-- Toggle grid button
			local WidgetTopToggleGridButton = LeaPlusLC:CreateButton("WidgetTopToggleGridButton", WidgetTopPanel, "Toggle Grid", "TOPLEFT", 16, -72, 0, 25, true, "Click to toggle the frame alignment grid.")
			LeaPlusCB["WidgetTopToggleGridButton"]:ClearAllPoints()
			LeaPlusCB["WidgetTopToggleGridButton"]:SetPoint("LEFT", WidgetTopPanel.h, "RIGHT", 10, 0)
			LeaPlusCB["WidgetTopToggleGridButton"]:SetScript("OnClick", function()
				if LeaPlusLC.grid:IsShown() then LeaPlusLC.grid:Hide() else LeaPlusLC.grid:Show() end
			end)
			WidgetTopPanel:HookScript("OnHide", function()
				if LeaPlusLC.grid then LeaPlusLC.grid:Hide() end
			end)

			-- Help button tooltip
			WidgetTopPanel.h.tiptext = L["Drag the frame overlay with the left button to position it freely or with the right button to position it using snap-to-grid."]

			-- Back button handler
			WidgetTopPanel.b:SetScript("OnClick", function()
				WidgetTopPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page6"]:Show()
				return
			end)

			-- Reset button handler
			WidgetTopPanel.r:SetScript("OnClick", function()

				-- Reset position and scale
				LeaPlusLC["WidgetTopA"] = "TOP"
				LeaPlusLC["WidgetTopR"] = "TOP"
				LeaPlusLC["WidgetTopX"] = 0
				LeaPlusLC["WidgetTopY"] = -15
				LeaPlusLC["WidgetTopScale"] = 1
				topCenterHolder:ClearAllPoints()
				topCenterHolder:SetPoint(LeaPlusLC["WidgetTopA"], UIParent, LeaPlusLC["WidgetTopR"], LeaPlusLC["WidgetTopX"], LeaPlusLC["WidgetTopY"])

				-- Refresh configuration panel
				WidgetTopPanel:Hide(); WidgetTopPanel:Show()
				dragframe:Show()

				-- Show frame alignment grid
				LeaPlusLC.grid:Show()

			end)

			-- Show configuration panel when options panel button is clicked
			LeaPlusCB["ManageWidgetTopButton"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["WidgetTopA"] = "CENTER"
					LeaPlusLC["WidgetTopR"] = "CENTER"
					LeaPlusLC["WidgetTopX"] = 0
					LeaPlusLC["WidgetTopY"] = -160
					LeaPlusLC["WidgetTopScale"] = 1.25
					topCenterHolder:ClearAllPoints()
					topCenterHolder:SetPoint(LeaPlusLC["WidgetTopA"], UIParent, LeaPlusLC["WidgetTopR"], LeaPlusLC["WidgetTopX"], LeaPlusLC["WidgetTopY"])
					topCenterHolder:SetScale(LeaPlusLC["WidgetTopScale"])
					UIWidgetTopCenterContainerFrame:SetScale(LeaPlusLC["WidgetTopScale"])
				else
					-- Show Titan Panel frame adjustment warning if Titan Panel is installed with frame adjustment widget enabled
					if C_AddOns.IsAddOnLoaded("Titan") and TitanPlayerSettings and TitanPlayerSettings.Adjust and TitanPlayerSettings.Adjust.UIWidgetTopCenterContainerFrame and TitanPlayerSettings.Adjust.UIWidgetTopCenterContainerFrame.adjust then
						titanFrame:Show()
					end

					-- Find out if the UI has a non-standard scale
					if GetCVar("useuiscale") == "1" then
						LeaPlusLC["gscale"] = GetCVar("uiscale")
					else
						LeaPlusLC["gscale"] = 1
					end

					-- Set drag frame size according to UI scale
					dragframe:SetWidth(160 * LeaPlusLC["gscale"])
					dragframe:SetHeight(79 * LeaPlusLC["gscale"])

					-- Show configuration panel
					WidgetTopPanel:Show()
					LeaPlusLC:HideFrames()
					dragframe:Show()

					-- Show frame alignment grid
					LeaPlusLC.grid:Show()
				end
			end)

			-- Hide drag frame when configuration panel is closed
			WidgetTopPanel:HookScript("OnHide", function() dragframe:Hide() end)

		end

		----------------------------------------------------------------------
		-- Hide chat buttons
		----------------------------------------------------------------------

		if LeaPlusLC["NoChatButtons"] == "On" and not LeaLockList["NoChatButtons"] then

			-- Create hidden frame to store unwanted frames (more efficient than creating functions)
			local tframe = CreateFrame("FRAME")
			tframe:Hide()

			-- Function to enable mouse scrolling with CTRL and SHIFT key modifiers
			local function AddMouseScroll(chtfrm)
				if _G[chtfrm] then
					_G[chtfrm]:SetScript("OnMouseWheel", function(self, direction)
						if direction == 1 then
							if IsControlKeyDown() then
								self:ScrollToTop()
							elseif IsShiftKeyDown() then
								self:PageUp()
							else
								self:ScrollUp()
							end
						else
							if IsControlKeyDown() then
								self:ScrollToBottom()
							elseif IsShiftKeyDown() then
								self:PageDown()
							else
								self:ScrollDown()
							end
						end
					end)
					_G[chtfrm]:EnableMouseWheel(true)
				end
			end

			-- Function to hide chat buttons
			local function HideButtons(chtfrm)
				_G[chtfrm .. "ButtonFrameMinimizeButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameMinimizeButton"]:Hide();
				_G[chtfrm .. "ButtonFrame"]:SetSize(0.1,0.1)
				_G[chtfrm].ScrollBar:SetParent(tframe)
				_G[chtfrm].ScrollBar:Hide()
			end

			-- Function to highlight chat tabs and click to scroll to bottom
			local function HighlightTabs(chtfrm)

				-- Hide bottom button
				_G[chtfrm].ScrollToBottomButton:SetSize(0.1, 0.1) -- Positions it away

				-- Remove click from the bottom button
				_G[chtfrm].ScrollToBottomButton:SetScript("OnClick", nil)

				-- Remove textures
				_G[chtfrm].ScrollToBottomButton:SetNormalTexture("")
				_G[chtfrm].ScrollToBottomButton:SetHighlightTexture("")
				_G[chtfrm].ScrollToBottomButton:SetPushedTexture("")
				_G[chtfrm].ScrollToBottomButton:SetDisabledTexture("")

				-- Always scroll to bottom when clicking a tab
				_G[chtfrm .. "Tab"]:HookScript("OnClick", function(self,arg1)
					if arg1 == "LeftButton" then
						_G[chtfrm]:ScrollToBottom()
					end
				end)

				-- Create new bottom button under tab
				_G[chtfrm .. "Tab"].newglow = _G[chtfrm .. "Tab"]:CreateTexture(nil, "BACKGROUND")
				_G[chtfrm .. "Tab"].newglow:ClearAllPoints()
				_G[chtfrm .. "Tab"].newglow:SetAllPoints()
				_G[chtfrm .. "Tab"].newglow:SetTexture("Interface\\ChatFrame\\ChatFrameTab-NewMessage")
				_G[chtfrm .. "Tab"].newglow:SetVertexColor(0.6, 0.6, 1, 0.7)
				_G[chtfrm .. "Tab"].newglow:SetBlendMode("ADD")
				_G[chtfrm .. "Tab"].newglow:Hide()

				-- Show new bottom button when old one glows
				_G[chtfrm].ScrollToBottomButton.Flash:HookScript("OnShow", function(self,arg1)
					_G[chtfrm .. "Tab"].newglow:Show()
				end)

				_G[chtfrm].ScrollToBottomButton.Flash:HookScript("OnHide", function(self,arg1)
					_G[chtfrm .. "Tab"].newglow:Hide()
				end)

			end

			-- Set options for normal and existing chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					AddMouseScroll("ChatFrame" .. i)
					HideButtons("ChatFrame" .. i)
					HighlightTabs("ChatFrame" .. i)
				end
			end

			-- Do the functions above for temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType)
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then

					-- Set options for temporary frame
					AddMouseScroll(cf)
					HideButtons(cf)
					HighlightTabs(cf)

					-- Create new bottom button under tab
					_G[cf .. "Tab"].newglow = _G[cf .. "Tab"]:CreateTexture(nil, "BACKGROUND")
					_G[cf .. "Tab"].newglow:ClearAllPoints()
					_G[cf .. "Tab"].newglow:SetAllPoints()
					_G[cf .. "Tab"].newglow:SetTexture("Interface\\ChatFrame\\ChatFrameTab-NewMessage")
					_G[cf .. "Tab"].newglow:SetVertexColor(0.6, 0.6, 1, 1)
					_G[cf .. "Tab"].newglow:SetBlendMode("ADD")
					_G[cf .. "Tab"].newglow:Hide()

					-- Show new bottom button when old one glows
					_G[cf].ScrollToBottomButton.Flash:HookScript("OnShow", function(self,arg1)
						_G[cf .. "Tab"].newglow:Show()
					end)

					_G[cf].ScrollToBottomButton.Flash:HookScript("OnHide", function(self,arg1)
						_G[cf .. "Tab"].newglow:Hide()
					end)

				end
			end)

			-- Hide text to speech button
			TextToSpeechButton:SetParent(tframe)

			-- Move voice chat and chat menu buttons inside the chat frame
			ChatFrameChannelButton:ClearAllPoints()
			ChatFrameChannelButton:SetPoint("TOPRIGHT", ChatFrame1Background, "TOPRIGHT", 1, -3)
			ChatFrameChannelButton:SetSize(26,25)

			ChatFrameToggleVoiceDeafenButton:ClearAllPoints()
			ChatFrameToggleVoiceDeafenButton:SetPoint("TOP", ChatFrameChannelButton, "BOTTOM", 0, -2)
			ChatFrameToggleVoiceDeafenButton:SetSize(26,25)

			ChatFrameToggleVoiceMuteButton:ClearAllPoints()
			ChatFrameToggleVoiceMuteButton:SetPoint("TOP", ChatFrameToggleVoiceDeafenButton, "BOTTOM", 0, -2)
			ChatFrameToggleVoiceMuteButton:SetSize(26,25)

			ChatFrameMenuButton:ClearAllPoints()
			ChatFrameMenuButton:SetPoint("BOTTOMRIGHT", ChatFrame1Background, "BOTTOMRIGHT", 3, 18)
			ChatFrameMenuButton:SetSize(29,29)

			-- Function to set voice chat and chat menu buttons
			local function SetChatButtonFrameButtons()
				if LeaPlusLC["ShowVoiceButtons"] == "On" then
					-- Show voice chat buttons
					ChatFrameChannelButton:SetParent(UIParent)
					ChatFrameToggleVoiceDeafenButton:SetParent(UIParent)
					ChatFrameToggleVoiceMuteButton:SetParent(UIParent)
				else
					-- Hide voice chat buttons
					ChatFrameChannelButton:SetParent(tframe)
					ChatFrameToggleVoiceDeafenButton:SetParent(tframe)
					ChatFrameToggleVoiceMuteButton:SetParent(tframe)
				end
				if LeaPlusLC["ShowChatMenuButton"] == "On" then
					-- Show chat menu button
					ChatFrameMenuButton:SetParent(UIParent)
				else
					-- Hide chat menu button
					ChatFrameMenuButton:SetParent(tframe)
				end
			end

			-- Create configuration panel
			local HideChatButtonsPanel = LeaPlusLC:CreatePanel("Hide chat buttons", "HideChatButtonsPanel")

			-- Add checkboxes
			LeaPlusLC:MakeTx(HideChatButtonsPanel, "General", 16, -72)
			LeaPlusLC:MakeCB(HideChatButtonsPanel, "ShowVoiceButtons", "Show voice chat buttons", 16, -92, false, "If checked, voice chat buttons will be shown.")
			LeaPlusLC:MakeCB(HideChatButtonsPanel, "ShowChatMenuButton", "Show chat menu button", 16, -112, false, "If checked, the chat menu button will be shown.")

			-- Help button hidden
			HideChatButtonsPanel.h:Hide()

			-- Back button handler
			HideChatButtonsPanel.b:SetScript("OnClick", function()
				HideChatButtonsPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page3"]:Show()
				return
			end)

			-- Reset button handler
			HideChatButtonsPanel.r:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["ShowVoiceButtons"] = "Off"
				LeaPlusLC["ShowChatMenuButton"] = "Off"

				-- Refresh panel
				SetChatButtonFrameButtons()
				HideChatButtonsPanel:Hide(); HideChatButtonsPanel:Show()

			end)

			-- Show panal when options panel button is clicked
			LeaPlusCB["NoChatButtonsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["ShowVoiceButtons"] = "On"
					LeaPlusLC["ShowChatMenuButton"] = "Off"
					SetChatButtonFrameButtons()
				else
					HideChatButtonsPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Run function when options are clicked and on startup
			LeaPlusCB["ShowVoiceButtons"]:HookScript("OnClick", SetChatButtonFrameButtons)
			LeaPlusCB["ShowChatMenuButton"]:HookScript("OnClick", SetChatButtonFrameButtons)
			SetChatButtonFrameButtons()

		end

		----------------------------------------------------------------------
		-- Recent chat window
		----------------------------------------------------------------------

		if LeaPlusLC["RecentChatWindow"] == "On" and not LeaLockList["RecentChatWindow"] then

			-- Create recent chat frame
			local editFrame = CreateFrame("ScrollFrame", nil, UIParent, "LeaPlusRecentChatScrollFrameTemplate")

			-- Set frame parameters
			editFrame:ClearAllPoints()
			editFrame:SetPoint("BOTTOM", 0, 130)
			editFrame:SetSize(600, LeaPlusLC["RecentChatSize"])
			editFrame:SetFrameStrata("MEDIUM")
			editFrame:SetToplevel(true)
			editFrame:Hide()

			-- Add background color
			editFrame.t = editFrame:CreateTexture(nil, "BACKGROUND")
			editFrame.t:SetAllPoints()
			editFrame.t:SetColorTexture(0.00, 0.00, 0.0, 0.6)

			-- Create title bar
			local titleFrame = CreateFrame("Frame", nil, editFrame)
			titleFrame:ClearAllPoints()
			titleFrame:SetPoint("TOP", 0, 24)
			titleFrame:SetSize(600, 24)
			titleFrame:SetFrameStrata("MEDIUM")
			titleFrame:SetToplevel(true)
			titleFrame:SetHitRectInsets(-6, -6, -6, -6)
			titleFrame.t = titleFrame:CreateTexture(nil, "BACKGROUND")
			titleFrame.t:SetAllPoints()
			titleFrame.t:SetColorTexture(0.00, 0.00, 0.0, 0.8)

			-- Add message count
			titleFrame.m = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			titleFrame.m:SetPoint("LEFT", 4, 0)
			titleFrame.m:SetText(L["Messages"] .. ": 0")
			titleFrame.m:SetFont(titleFrame.m:GetFont(), 16, nil)

			-- Add right-click to close message
			titleFrame.x = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			titleFrame.x:SetPoint("RIGHT", -4, 0)
			titleFrame.x:SetText(L["Drag to size"] .. " | " .. L["Right-click to close"])
			titleFrame.x:SetFont(titleFrame.x:GetFont(), 16, nil)
			titleFrame.x:SetWidth(600 - titleFrame.m:GetStringWidth() - 30)
			titleFrame.x:SetWordWrap(false)
			titleFrame.x:SetJustifyH("RIGHT")

			-- Drag to resize
			editFrame:SetResizable(true)
			editFrame:SetResizeBounds(600, 170, 600, 560)

			titleFrame:HookScript("OnMouseDown", function(self, btn)
				if btn == "LeftButton" then
					editFrame:StartSizing("TOP")
				end
			end)
			titleFrame:HookScript("OnMouseUp", function(self, btn)
				if btn == "LeftButton" then
					editFrame:StopMovingOrSizing()
					LeaPlusLC["RecentChatSize"] = editFrame:GetHeight()
				elseif btn == "MiddleButton" then
					-- Reset frame size
					LeaPlusLC["RecentChatSize"] = 170
					editFrame:SetSize(600, LeaPlusLC["RecentChatSize"])
					editFrame:ClearAllPoints()
					editFrame:SetPoint("BOTTOM", 0, 130)
				end
			end)

			-- Create character count
			editFrame.CharCount = editFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			editFrame.CharCount:Hide()

			-- Create editbox
			local editBox = editFrame.EditBox
			editBox:SetAltArrowKeyMode(false)
			editBox:SetTextInsets(4, 4, 4, 4)
			editBox:SetWidth(editFrame:GetWidth() - 30)
			editBox:SetSecurityDisablePaste()
			editBox:SetMaxLetters(0)

			editFrame:SetScrollChild(editBox)

			-- Manage focus
			editBox:HookScript("OnEditFocusLost", function()
				if titleFrame:IsMouseOver() and IsMouseButtonDown("LeftButton") then
					editBox:SetFocus()
				end
			end)

			-- Close frame with right-click of editframe or editbox
			local function CloseRecentChatWindow()
				editBox:SetText("")
				editBox:ClearFocus()
				editFrame:Hide()
			end

			editFrame:SetScript("OnMouseDown", function(self, btn)
				if btn == "RightButton" then CloseRecentChatWindow() end
			end)

			editBox:SetScript("OnMouseDown", function(self, btn)
				if btn == "RightButton" then CloseRecentChatWindow() end
			end)

			titleFrame:HookScript("OnMouseDown", function(self, btn)
				if btn == "RightButton" then CloseRecentChatWindow() end
			end)

			-- Disable text changes while still allowing editing controls to work
			editBox:EnableKeyboard(false)
			editBox:SetScript("OnKeyDown", function() end)

			-- Populate recent chat frame with chat messages
			local function ShowChatbox(chtfrm)
				editBox:SetText("")
				local NumMsg = chtfrm:GetNumMessages()
				local StartMsg = 1
				if NumMsg > 256 then StartMsg = NumMsg - 255 end
				local totalMsgCount = 0
				for iMsg = StartMsg, NumMsg do
					local chatMessage, r, g, b, chatTypeID = chtfrm:GetMessageInfo(iMsg)
					if chatMessage and canaccessvalue(chatMessage) then

						-- Handle Battle.net messages
						if string.match(chatMessage, "k:(%d+):(%d+):BN_WHISPER:")
						or string.match(chatMessage, "k:(%d+):(%d+):BN_INLINE_TOAST_ALERT:")
						or string.match(chatMessage, "k:(%d+):(%d+):BN_INLINE_TOAST_BROADCAST:")
						then
							local ctype
							if string.match(chatMessage, "k:(%d+):(%d+):BN_WHISPER:") then
								ctype = "BN_WHISPER"
							elseif string.match(chatMessage, "k:(%d+):(%d+):BN_INLINE_TOAST_ALERT:") then
								ctype = "BN_INLINE_TOAST_ALERT"
							elseif string.match(chatMessage, "k:(%d+):(%d+):BN_INLINE_TOAST_BROADCAST:") then
								ctype = "BN_INLINE_TOAST_BROADCAST"
							end
							local id = tonumber(string.match(chatMessage, "k:(%d+):%d+:" .. ctype .. ":"))
							local totalBNFriends = BNGetNumFriends()
							for friendIndex = 1, totalBNFriends do
								local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex)
								local bnetAccountID = accountInfo.bnetAccountID
								local battleTag = accountInfo.battleTag
								if id == bnetAccountID then
									battleTag = strsplit("#", battleTag)
									chatMessage = chatMessage:gsub("(|HBNplayer%S-|k)(%d-)(:%S-" .. ctype .. "%S-|h)%[(%S-)%](|?h?)(:?)", "[" .. battleTag .. "]:")
								end
							end
						end

						-- Handle colors
						if r and g and b then
							local colorCode = RGBToColorCode(r, g, b)
							chatMessage = colorCode .. chatMessage
						end

						chatMessage = gsub(chatMessage, "|T.-|t", "") -- Remove textures
						chatMessage = gsub(chatMessage, "|A.-|a", "") -- Remove atlases
						editBox:Insert(chatMessage .. "|r|n")

					end
					totalMsgCount = totalMsgCount + 1
				end
				titleFrame.m:SetText(L["Messages"] .. ": " .. totalMsgCount)
				editFrame:SetVerticalScroll(0)
				editFrame.ScrollBar:ScrollToEnd()
				editFrame:Show()
				editBox:ClearFocus()
			end

			-- Hook normal chat frame tab clicks
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					_G["ChatFrame" .. i .. "Tab"]:HookScript("OnClick", function()
						if IsControlKeyDown() then
							editBox:SetFont(_G["ChatFrame" .. i]:GetFont())
							editFrame:SetPanExtent(select(2, _G["ChatFrame" .. i]:GetFont()))
							ShowChatbox(_G["ChatFrame" .. i])
						end
					end)
				end
			end

			-- Hook temporary chat frame tab clicks
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf .. "Tab"]:HookScript("OnClick", function()
						if IsControlKeyDown() then
							editBox:SetFont(_G[cf]:GetFont())
							editFrame:SetPanExtent(select(2, _G[cf]:GetFont()))
							ShowChatbox(_G[cf])
						end
					end)
				end
			end)

			-- Add entry to chat menu to show recent chat window
			Menu.ModifyMenu("MENU_FCF_TAB", function(self, rootDescription, contextData)
				rootDescription:CreateDivider()
				rootDescription:CreateTitle(L["Leatrix Plus"])
				local recentChatButton = rootDescription:CreateButton(L["Recent chat window"], function()
					local currentChatFrame = FCF_GetCurrentChatFrame()
					editBox:SetFont(currentChatFrame:GetFont())
					editFrame:SetPanExtent(select(2, currentChatFrame:GetFont()))
					ShowChatbox(currentChatFrame)
				end)
			end)

		end

		----------------------------------------------------------------------
		--	Hide alerts
		----------------------------------------------------------------------

		if LeaPlusLC["NoAlerts"] == "On" then
			hooksecurefunc(AlertFrame, "RegisterEvent", function(self, event)
				AlertFrame:UnregisterEvent(event)
			end)
			AlertFrame:UnregisterAllEvents()
			EventRegistry:UnregisterFrameEvent("NEW_HOUSING_ITEM_ACQUIRED")
		end

		----------------------------------------------------------------------
		-- Combat plates
		----------------------------------------------------------------------

		if LeaPlusLC["CombatPlates"] == "On" then

			-- Toggle nameplates with combat
			local f = CreateFrame("Frame")
			f:RegisterEvent("PLAYER_REGEN_DISABLED")
			f:RegisterEvent("PLAYER_REGEN_ENABLED")
			f:SetScript("OnEvent", function(self, event)
				SetCVar("nameplateShowEnemies", event == "PLAYER_REGEN_DISABLED" and 1 or 0)
			end)

			-- Run combat check on startup
			SetCVar("nameplateShowEnemies", UnitAffectingCombat("player") and 1 or 0)

		end

		----------------------------------------------------------------------
		-- Enhance tooltip
		----------------------------------------------------------------------

		if LeaPlusLC["TipModEnable"] == "On" and not LeaLockList["TipModEnable"] then

			-- Enable mouse hover events for world frame (required for hide tooltips, cursor anchor and maybe other addons)
			WorldFrame:EnableMouseMotion(true)

			----------------------------------------------------------------------
			--	Position the tooltip
			----------------------------------------------------------------------

			-- Position general tooltip
			hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
				if LeaPlusLC["TooltipAnchorMenu"] ~= 1 then
					if (not tooltip or not parent) then
						return
					end
					if WorldFrame:IsMouseMotionFocus() then
						if LeaPlusLC["TooltipAnchorMenu"] == 2 then
							tooltip:SetOwner(parent, "ANCHOR_CURSOR")
							return
						elseif LeaPlusLC["TooltipAnchorMenu"] == 3 then
							tooltip:SetOwner(parent, "ANCHOR_CURSOR_LEFT", LeaPlusLC["TipCursorX"], LeaPlusLC["TipCursorY"])
							return
						elseif LeaPlusLC["TooltipAnchorMenu"] == 4 then
							tooltip:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", LeaPlusLC["TipCursorX"], LeaPlusLC["TipCursorY"])
							return
						end
					end
				end
			end)

			----------------------------------------------------------------------
			--	Tooltip Configuration
			----------------------------------------------------------------------

			local LT = {}

			-- Create locale specific level string
			LT["LevelLocale"] = strtrim(strtrim(string.gsub(TOOLTIP_UNIT_LEVEL, "%%s", "")))
			if GameLocale == "ruRU" then
				LT["LevelLocale"] = "-ro уровня"
			end

			---------------------------------------------------------------------------------------------------------
			-- Tooltip movement settings
			---------------------------------------------------------------------------------------------------------

			-- Create tooltip customisation side panel
			local SideTip = LeaPlusLC:CreatePanel("Enhance tooltip", "SideTip")

			-- Add controls
			LeaPlusLC:MakeTx(SideTip, "Settings", 16, -72)
			LeaPlusLC:MakeCB(SideTip, "TipShowRank", "Show guild ranks for your guild", 16, -92, false, "If checked, guild ranks will be shown for players in your guild.")
			LeaPlusLC:MakeCB(SideTip, "TipShowOtherRank", "Show guild ranks for other guilds", 16, -112, false, "If checked, guild ranks will be shown for players who are not in your guild.")
			LeaPlusLC:MakeCB(SideTip, "TipShowTarget", "Show the unit's target", 16, -132, false, "If checked, unit targets will be shown.")
			LeaPlusLC:MakeCB(SideTip, "TipBackSimple", "Color the backdrops based on faction", 16, -152, false, "If checked, backdrops will be tinted blue (friendly) or red (hostile).")
			LeaPlusLC:MakeCB(SideTip, "TipNoHealthBar", "Hide the health bar", 16, -172, true, "If checked, the health bar will not be shown.")

			-- Show restrictions to tooltips in Midnight
			LeaPlusCB["TipShowRank"].tiptext = LeaPlusCB["TipShowRank"].tiptext .. "|n|n" .. L["This setting does not apply during instanced combat encounters."]
			LeaPlusCB["TipShowOtherRank"].tiptext = LeaPlusCB["TipShowOtherRank"].tiptext .. "|n|n" .. L["This setting does not apply during instanced combat encounters."]
			LeaPlusCB["TipShowTarget"].tiptext = LeaPlusCB["TipShowTarget"].tiptext .. "|n|n" .. L["This setting does not apply during instanced combat encounters."]
			LeaPlusCB["TipBackSimple"].tiptext = LeaPlusCB["TipBackSimple"].tiptext .. "|n|n" .. L["This setting does not apply during instanced combat encounters."]

			LeaPlusLC:MakeTx(SideTip, "Hide tooltips", 16, -212)
			LeaPlusLC:MakeCB(SideTip, "TipHideInCombat", "Hide tooltips for world units during combat", 16, -232, false, "If checked, tooltips for world units will be hidden during combat.")
			LeaPlusLC:MakeCB(SideTip, "TipHideShiftOverride", "Show tooltips with shift key", 16, -252, false, "If checked, you can hold shift while tooltips are hidden to show them temporarily.")

			-- Handle show tooltips with shift key lock
			local function SetTipHideShiftOverrideFunc()
				if LeaPlusLC["TipHideInCombat"] == "On" then
					LeaPlusLC:LockItem(LeaPlusCB["TipHideShiftOverride"], false)
				else
					LeaPlusLC:LockItem(LeaPlusCB["TipHideShiftOverride"], true)
				end
			end

			LeaPlusCB["TipHideInCombat"]:HookScript("OnClick", SetTipHideShiftOverrideFunc)
			SetTipHideShiftOverrideFunc()

			LeaPlusLC:CreateDropdown("TooltipAnchorMenu", "Anchor", 146, "TOPLEFT", SideTip, "TOPLEFT", 356, -92, false, {{L["None"], 1}, {L["Cursor"], 2}, {L["Cursor Left"], 3}, {L["Cursor Right"], 4}})

			local XOffsetHeading = LeaPlusLC:MakeTx(SideTip, "X Offset", 356, -132)
			LeaPlusLC:MakeSL(SideTip, "TipCursorX", "Drag to set the cursor X offset.", -128, 128, 1, 356, -152, "%.0f")

			local YOffsetHeading = LeaPlusLC:MakeTx(SideTip, "Y Offset", 356, -182)
			LeaPlusLC:MakeSL(SideTip, "TipCursorY", "Drag to set the cursor Y offset.", -128, 128, 1, 356, -202, "%.0f")

			LeaPlusLC:MakeTx(SideTip, "Scale", 356, -232)
			LeaPlusLC:MakeSL(SideTip, "LeaPlusTipSize", "Drag to set the tooltip scale.", 0.50, 2.00, 0.05, 356, -252, "%.2f")

			-- Function to enable or disable anchor controls
			local function SetAnchorControls()
				-- Set the X and Y sliders
				if LeaPlusLC["TooltipAnchorMenu"] == 1 or LeaPlusLC["TooltipAnchorMenu"] == 2 then
					-- Dropdown is set to none or cursor so disable X and Y offset sliders
					LeaPlusLC:LockItem(LeaPlusCB["TipCursorX"], true)
					LeaPlusLC:LockItem(LeaPlusCB["TipCursorY"], true)
					XOffsetHeading:SetAlpha(0.3)
					YOffsetHeading:SetAlpha(0.3)
					LeaPlusCB["TipCursorX"]:SetScript("OnEnter", nil)
					LeaPlusCB["TipCursorY"]:SetScript("OnEnter", nil)
				else
					-- Dropdown is set to cursor left or cursor right so enable X and Y offset sliders
					LeaPlusLC:LockItem(LeaPlusCB["TipCursorX"], false)
					LeaPlusLC:LockItem(LeaPlusCB["TipCursorY"], false)
					XOffsetHeading:SetAlpha(1.0)
					YOffsetHeading:SetAlpha(1.0)
					LeaPlusCB["TipCursorX"]:SetScript("OnEnter", LeaPlusLC.TipSee)
					LeaPlusCB["TipCursorY"]:SetScript("OnEnter", LeaPlusLC.TipSee)
				end
			end

			-- Set controls when dropdown menu is changed and on startup
			LeaPlusCB["TooltipAnchorMenu"]:RegisterCallback("OnMenuClose", function()
				if not UnitAffectingCombat("player") then
					SetAnchorControls()
				end
			end)
			SetAnchorControls()

			-- Help button hidden
			SideTip.h:Hide()

			-- Back button handler
			SideTip.b:SetScript("OnClick", function()
				SideTip:Hide()
				LeaPlusLC["PageF"]:Show()
				LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			SideTip.r.tiptext = SideTip.r.tiptext .. "|n|n" .. L["Note that this will not reset settings that require a UI reload."]
			SideTip.r:SetScript("OnClick", function()
				LeaPlusLC["TipShowRank"] = "On"
				LeaPlusLC["TipShowOtherRank"] = "Off"
				LeaPlusLC["TipShowTarget"] = "On"
				LeaPlusLC["TipBackSimple"] = "Off"
				LeaPlusLC["TipHideInCombat"] = "Off"; SetTipHideShiftOverrideFunc()
				LeaPlusLC["TipHideShiftOverride"] = "On"
				LeaPlusLC["LeaPlusTipSize"] = 1.00
				LeaPlusLC["TooltipAnchorMenu"] = 1
				LeaPlusLC["TipCursorX"] = 0
				LeaPlusLC["TipCursorY"] = 0
				SetAnchorControls()
				LeaPlusLC:SetTipScale()
				SideTip:Hide(); SideTip:Show()
			end)

			--	Move the tooltip
			LeaPlusCB["MoveTooltipButton"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["TipShowRank"] = "On"
					LeaPlusLC["TipShowOtherRank"] = "Off"
					LeaPlusLC["TipShowTarget"] = "On"
					LeaPlusLC["TipBackSimple"] = "On"
					LeaPlusLC["TipHideInCombat"] = "Off"; SetTipHideShiftOverrideFunc()
					LeaPlusLC["TipHideShiftOverride"] = "On"
					LeaPlusLC["LeaPlusTipSize"] = 1.25
					LeaPlusLC["TooltipAnchorMenu"] = 1
					LeaPlusLC["TipCursorX"] = 0
					LeaPlusLC["TipCursorY"] = 0
					SetAnchorControls()
					LeaPlusLC:SetTipScale()
					LeaPlusLC:SetDim()
					LeaPlusLC:ReloadCheck()
					SideTip:Show(); SideTip:Hide() -- Needed to update tooltip scale
					LeaPlusLC["PageF"]:Hide(); LeaPlusLC["PageF"]:Show()
				else
					-- Show tooltip configuration panel
					LeaPlusLC:HideFrames()
					SideTip:Show()
				end
			end)

			-- Hide health bar
			if LeaPlusLC["TipNoHealthBar"] == "On" then
				GameTooltipStatusBarTexture:SetTexture("")
			end

			---------------------------------------------------------------------------------------------------------
			-- Tooltip scale settings
			---------------------------------------------------------------------------------------------------------

			-- Function to set the tooltip scale
			local function SetTipScale()

				-- General tooltip
				if GameTooltip then GameTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Friends
				if FriendsTooltip then FriendsTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- AutoCompleteBox
				if AutoCompleteBox then AutoCompleteBox:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Reputation
				if ReputationParagonTooltip then ReputationParagonTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Pet battles and battle pets
				if PetBattlePrimaryAbilityTooltip then PetBattlePrimaryAbilityTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if PetBattlePrimaryUnitTooltip then PetBattlePrimaryUnitTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if BattlePetTooltip then BattlePetTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if FloatingBattlePetTooltip then FloatingBattlePetTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if FloatingPetBattleAbilityTooltip then FloatingPetBattleAbilityTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Garrison
				if FloatingGarrisonFollowerTooltip then FloatingGarrisonFollowerTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if FloatingGarrisonFollowerAbilityTooltip then FloatingGarrisonFollowerAbilityTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if FloatingGarrisonMissionTooltip then FloatingGarrisonMissionTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if FloatingGarrisonShipyardFollowerTooltip then FloatingGarrisonShipyardFollowerTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Order Hall
				if GarrisonFollowerMissionAbilityWithoutCountersTooltip then GarrisonFollowerMissionAbilityWithoutCountersTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if GarrisonFollowerAbilityWithoutCountersTooltip then GarrisonFollowerAbilityWithoutCountersTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Items (links, comparisons)
				if ItemRefTooltip then ItemRefTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if ItemRefShoppingTooltip1 then ItemRefShoppingTooltip1:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if ItemRefShoppingTooltip2 then ItemRefShoppingTooltip2:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if ShoppingTooltip1 then ShoppingTooltip1:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if ShoppingTooltip2 then ShoppingTooltip2:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- World map (story)
				if QuestScrollFrame.WarCampaignTooltip then	QuestScrollFrame.WarCampaignTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end
				if QuestScrollFrame.StoryTooltip then
					QuestScrollFrame.StoryTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					QuestScrollFrame.StoryTooltip:SetFrameStrata("TOOLTIP")
				end

				-- Minimap (PVP queue status)
				if QueueStatusFrame then QueueStatusFrame:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Embedded item tooltip (as used in PVP UI)
				if EmbeddedItemTooltip then EmbeddedItemTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Nameplate tooltip
				if NamePlateTooltip then NamePlateTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- LibDBIcon
				if LibDBIconTooltip then LibDBIconTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"]) end

				-- Total RP 3
				if C_AddOns.IsAddOnLoaded("totalRP3") and TRP3_MainTooltip and TRP3_CharacterTooltip then
					TRP3_MainTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					TRP3_CharacterTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end

				-- Altoholic
				if AddonFactory_Tooltip then
					AddonFactory_Tooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end

				-- Set slider formatted text
				LeaPlusCB["LeaPlusTipSize"].f:SetFormattedText("%.0f%%", LeaPlusLC["LeaPlusTipSize"] * 100)

			end

			-- Give function a file level scope
			LeaPlusLC.SetTipScale = SetTipScale

			-- Set tooltip scale when slider or checkbox changes and on startup
			LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetTipScale)
			SetTipScale()

			----------------------------------------------------------------------
			-- Character customisation (dragonriding customisation, barbershop)
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_CharacterCustomize",function()

				-- Function to set tooltip scale
				local function SetCharCustomiseScale()
					if CharCustomizeNoHeaderTooltip then
						CharCustomizeNoHeaderTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					end
				end

				-- Set tooltip scale when slider changes and on startup
				LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetCharCustomiseScale)
				SetCharCustomiseScale()

			end)

			----------------------------------------------------------------------
			-- Contribution frame
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_Contribution",function()

				-- Function to set tooltip scale
				local function SetContributionTipScale()
					ContributionBuffTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end

				-- Set tooltip scale when slider changes and on startup
				LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetContributionTipScale)
				SetContributionTipScale()

			end)

			----------------------------------------------------------------------
			-- Pet Journal tooltips
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections",function()

				-- Function to set tooltip scale
				local function SetPetJournalTipScale()
					PetJournalPrimaryAbilityTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end

				-- Set tooltip scale when slider changes and on startup
				LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetPetJournalTipScale)
				SetPetJournalTipScale()

			end)

			----------------------------------------------------------------------
			-- Encounter Journal tooltips
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_EncounterJournal",function()

				-- Function to set tooltip scale
				local function SetEncounterJournalTipScale()
					EncounterJournalTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end

				-- Set tooltip scale when slider changes and on startup
				LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetEncounterJournalTipScale)
				SetEncounterJournalTipScale()

			end)

			----------------------------------------------------------------------
			-- Blizzard Settings tooltip
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_Settings",function()

				-- Set tooltip scale when tooltip is shown
				SettingsTooltip:HookScript("OnShow", function()
					SettingsTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"] * UIParent:GetScale())
				end)

			end)

			----------------------------------------------------------------------
			-- Perks program tooltip (trading post)
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_PerksProgram",function()

				-- Set tooltip scale
				PerksProgramTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])

			end)

			----------------------------------------------------------------------
			-- Death Recap frame tooltips
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_DeathRecap",function()

				-- Simple fix to prevent mousing over units behind the frame
				DeathRecapFrame:EnableMouse(true)

			end)

			----------------------------------------------------------------------
			-- Garrison tooltips
			----------------------------------------------------------------------

			EventUtil.ContinueOnAddOnLoaded("Blizzard_GarrisonUI",function()

				-- Function to set tooltip scale
				local function SetGarrisonTipScale()
					GarrisonFollowerTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonFollowerAbilityTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonMissionMechanicTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonMissionMechanicFollowerCounterTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonBuildingFrame.BuildingLevelTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonBonusAreaTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonShipyardMapMissionTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					GarrisonShipyardFollowerTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end

				-- Set tooltip scale when slider changes and on startup
				LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetGarrisonTipScale)
				SetGarrisonTipScale()

			end)

			---------------------------------------------------------------------------------------------------------
			-- Other tooltip code
			---------------------------------------------------------------------------------------------------------

			-- Remove the right-click for frame settings instruction (UNIT_POPUP_RIGHT_CLICK)
			hooksecurefunc("UnitFrame_UpdateTooltip", function(self)
				GameTooltip_SetDefaultAnchor(GameTooltip, self)
				GameTooltip:SetUnit(self.unit, true)
				GameTooltip:Show()
			end)

			-- Function to return a value only if it can be accessed (secret values return nil)
			local function Safe(value)
				if canaccessvalue(value) then return value end
			end

			-- Function to convert a color table to a color code
			local function ColorCode(col)
				return string.format("|cff%02x%02x%02x", col.r * 255, col.g * 255, col.b * 255)
			end

			-- Level string
			local LevelString, LevelString2
			if GameLocale == "ruRU" then
				-- Level string for ruRU
				LevelString = "уровня"
				LevelString2 = "уровень"
			else
				-- Level string for all other locales
				LevelString = string.lower(TOOLTIP_UNIT_LEVEL:gsub("%%s",".+"))
			end

			-- Tag locale (code construction from tiplang)
			local ttYou, ttLevel, ttBoss, ttElite, ttRare, ttRareElite, ttRareBoss, ttTarget
			if 		GameLocale == "zhCN" then 	ttYou = "您"		; ttLevel = "等级"		; ttBoss = "首领"	; ttElite = "精英"	; ttRare = "精良"	; ttRareElite = "精良 精英"		; ttRareBoss = "精良 首领"		; ttTarget = "目标"
			elseif 	GameLocale == "zhTW" then 	ttYou = "您"		; ttLevel = "等級"		; ttBoss = "首領"	; ttElite = "精英"	; ttRare = "精良"	; ttRareElite = "精良 精英"		; ttRareBoss = "精良 首領"		; ttTarget = "目標"
			elseif 	GameLocale == "ruRU" then 	ttYou = "ВЫ"	; ttLevel = "Уровень"	; ttBoss = "босс"	; ttElite = "элита"	; ttRare = "Редкое"	; ttRareElite = "Редкое элита"	; ttRareBoss = "Редкое босс"	; ttTarget = "Цель"
			elseif 	GameLocale == "koKR" then 	ttYou = "당신"	; ttLevel = "레벨"		; ttBoss = "우두머리"	; ttElite = "정예"	; ttRare = "희귀"	; ttRareElite = "희귀 정예"		; ttRareBoss = "희귀 우두머리"		; ttTarget = "대상"
			elseif 	GameLocale == "esMX" then 	ttYou = "TÚ"	; ttLevel = "Nivel"		; ttBoss = "Jefe"	; ttElite = "Élite"	; ttRare = "Raro"	; ttRareElite = "Raro Élite"	; ttRareBoss = "Raro Jefe"		; ttTarget = "Objetivo"
			elseif 	GameLocale == "ptBR" then 	ttYou = "VOCÊ"	; ttLevel = "Nível"		; ttBoss = "Chefe"	; ttElite = "Elite"	; ttRare = "Raro"	; ttRareElite = "Raro Elite"	; ttRareBoss = "Raro Chefe"		; ttTarget = "Alvo"
			elseif 	GameLocale == "deDE" then 	ttYou = "SIE"	; ttLevel = "Stufe"		; ttBoss = "Boss"	; ttElite = "Elite"	; ttRare = "Selten"	; ttRareElite = "Selten Elite"	; ttRareBoss = "Selten Boss"	; ttTarget = "Ziel"
			elseif 	GameLocale == "esES" then	ttYou = "TÚ"	; ttLevel = "Nivel"		; ttBoss = "Jefe"	; ttElite = "Élite"	; ttRare = "Raro"	; ttRareElite = "Raro Élite"	; ttRareBoss = "Raro Jefe"		; ttTarget = "Objetivo"
			elseif 	GameLocale == "frFR" then 	ttYou = "TOI"	; ttLevel = "Niveau"	; ttBoss = "Boss"	; ttElite = "Élite"	; ttRare = "Rare"	; ttRareElite = "Rare Élite"	; ttRareBoss = "Rare Boss"		; ttTarget = "Cible"
			elseif 	GameLocale == "itIT" then 	ttYou = "TU"	; ttLevel = "Livello"	; ttBoss = "Boss"	; ttElite = "Élite"	; ttRare = "Raro"	; ttRareElite = "Raro Élite"	; ttRareBoss = "Raro Boss"		; ttTarget = "Bersaglio"
			else 								ttYou = "YOU"	; ttLevel = "Level"		; ttBoss = "Boss"	; ttElite = "Elite"	; ttRare = "Rare"	; ttRareElite = "Rare Elite"	; ttRareBoss = "Rare Boss"		; ttTarget = "Target"
			end

			-- Function to find the level line (lines with secret text are skipped)
			local function FindLevelLine(first)
				for i = first, math.min(GameTooltip:NumLines(), first + 3) do
					local text = Safe(_G["GameTooltipTextLeft" .. i]:GetText())
					if text then
						local lower = string.lower(text)
						if lower:find(LevelString) or (LevelString2 and lower:find(LevelString2)) then
							return i, text
						end
					end
				end
			end

			-- Function to get level text (colored by difficulty if required)
			local function GetLevelText(unit, level, realLevel, useColor)

				-- Level ?? units
				if level == -1 then
					if GameLocale == "ruRU" then
						return "|cffff3333??-ro " .. ttLevel .. "|r"
					else
						return "|cffff3333" .. ttLevel .. " ??|r"
					end
				end

				-- Show real level if different (such as level scaling)
				local realText = ""
				if not useColor and realLevel and realLevel ~= level then
					realText = " (" .. realLevel .. ")"
				end

				-- Construct level text
				local levelText
				if GameLocale == "ruRU" then
					levelText = level .. realText .. LT["LevelLocale"]
				else
					levelText = LT["LevelLocale"] .. " " .. level .. realText
				end

				-- Color level by difficulty
				if useColor then
					levelText = ColorCode(GetDifficultyColor(C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit))) .. levelText .. "|r"
				end

				return levelText

			end

			-- Show tooltip
			local function ShowTip(self)

				-- Required for Dragonflight (or not self:IsTooltipType(Enum.TooltipDataType.Unit))
				if self ~= GameTooltip then return end

				-- Do nothing if CTRL, SHIFT and ALT are being held
				if IsControlKeyDown() and IsAltKeyDown() and IsShiftKeyDown() then
					return
				end

				-- Hide tooltips for world units during combat
				if WorldFrame:IsMouseMotionFocus() then
					if LeaPlusLC["TipHideInCombat"] == "On" and UnitAffectingCombat("player") then
						if not IsShiftKeyDown() or LeaPlusLC["TipHideShiftOverride"] == "Off" then
							GameTooltip:Hide()
							return
						end
					end
				end

				-- Get unit (secret unit tokens cannot be used so try the unit frame token instead)
				local unit
				if WorldFrame:IsMouseMotionFocus() then
					unit = "mouseover"
				else
					unit = select(2, GameTooltip:GetUnit())
					if not canaccessvalue(unit) then
						local owner = GameTooltip:GetOwner()
						unit = owner and not owner:IsForbidden() and Safe(owner.unit)
					end
				end
				if type(unit) ~= "string" or not UnitExists(unit) then return end

				-- Quit if unit is a wild pet
				if UnitIsWildBattlePet(unit) then return end

				-- Get unit information (reaction is nil if the unit is out of range so treat it as friendly)
				local name, realm = UnitName(unit)
				local isPlayer = UnitIsPlayer(unit)
				local playerControl = UnitPlayerControlled(unit)
				local reaction = UnitReaction(unit, "player") or 5
				local level = UnitEffectiveLevel(unit)
				local realLevel = UnitLevel(unit)
				local isDead = UnitIsDeadOrGhost(unit)
				local className, class = UnitClass(unit)
				className, class = Safe(className), Safe(class)
				local classCol = class and LeaPlusLC["RaidColors"][class]

				----------------------------------------------------------------------
				-- Name line
				----------------------------------------------------------------------

				local r, g, b
				if isPlayer then

					-- Show player name with title and realm
					local nameText = UnitPVPName(unit)
					if not nameText or (canaccessvalue(nameText) and nameText == "") then nameText = name end -- Some units (Demolition Fan, 237523) return empty strings for UnitPVPName
					realm = Safe(realm)
					if nameText and realm and realm ~= "" then nameText = nameText .. " - " .. realm end
					if nameText then GameTooltipTextLeft1:SetText(nameText) end

					-- Show player name in class color
					if classCol then r, g, b = classCol.r, classCol.g, classCol.b end

				elseif playerControl or reaction > 4 then

					-- Show friendly and player controlled units in green or blue depending on PvP status
					if Safe(UnitIsPVP(unit)) then
						r, g, b = 0, 1, 0
					else
						r, g, b = 0, 0.67, 1
					end

				elseif reaction < 4 then

					-- Show hostile mobs in brighter red (alive) and steel blue (tap denied)
					if UnitIsTapDenied(unit) then
						r, g, b = 0.53, 0.73, 0.73
					else
						r, g, b = 1, 0.2, 0.2
					end

				end

				-- Show dead units in grey
				if isDead then r, g, b = 0.53, 0.53, 0.53 end

				-- Set name color (the name text is not touched so secret names are fine)
				if r then GameTooltipTextLeft1:SetTextColor(r, g, b) end

				----------------------------------------------------------------------
				-- Player guild and information lines
				----------------------------------------------------------------------

				if isPlayer then

					-- Show guild line
					local guildName, guildRank, void, guildRealm = GetGuildInfo(unit)
					if guildName then
						guildRealm = Safe(guildRealm)
						if guildRealm and guildRealm ~= "" then guildName = guildName .. "-" .. guildRealm end -- Show guild realm if different
						local showRank
						if UnitIsInMyGuild(unit) then
							showRank = LeaPlusLC["TipShowRank"] == "On"
						else
							showRank = LeaPlusLC["TipShowOtherRank"] == "On"
						end
						if showRank and guildRank then
							GameTooltipTextLeft2:SetText(guildName .. " - " .. guildRank)
						else
							GameTooltipTextLeft2:SetText(guildName)
						end
						GameTooltipTextLeft2:SetTextColor(0.67, 0.67, 1)
					end

					-- Show information line (level, race and class)
					local infoLine, infoOld
					if className and level then infoLine, infoOld = FindLevelLine(guildName and 3 or 2) end
					if infoLine then

						-- Keep Blizzard information line if it shows a different race (such as disguised players)
						local race = Safe(UnitRace(unit))
						local keepLine = race and not infoOld:find(race, 1, true)

						-- Level and race
						local infoText = GetLevelText(unit, level, realLevel, reaction < 5)
						if race then
							if GameLocale == "ruRU" then
								infoText = race .. ", " .. infoText
							else
								infoText = infoText .. " " .. race
							end
						end

						-- Show specialisation line in class color or show class on information line if there is no specialisation line (such as Akunda the Nimble in Vol'dun)
						local specLine = infoLine < GameTooltip:NumLines() and _G["GameTooltipTextLeft" .. (infoLine + 1)]
						local specText = specLine and Safe(specLine:GetText())
						if specText and specText:find(className, 1, true) then
							if classCol then specLine:SetTextColor(classCol.r, classCol.g, classCol.b) end
						elseif classCol then
							infoText = infoText .. " " .. ColorCode(classCol) .. className .. "|r"
						else
							infoText = infoText .. " " .. className
						end

						-- Show information line
						if not keepLine then _G["GameTooltipTextLeft" .. infoLine]:SetText(infoText) end

					end

				end

				----------------------------------------------------------------------
				-- Mob level in color (neutral or lower)
				----------------------------------------------------------------------

				if not isPlayer and not playerControl and reaction < 5 and level and UnitCanAttack(unit, "player") then

					local mobLine, mobText = FindLevelLine(2)
					if mobLine then

						-- Rare, elite and boss mobs
						local isBoss = mobText:find(ttBoss, 1, true)
						local special = UnitClassification(unit)
						if special == "elite" then
							special = isBoss and "(" .. ttBoss .. ")" or "(" .. ttElite .. ")"
						elseif special == "rare" then
							special = "|c00e066ff(" .. ttRare .. ")"
						elseif special == "rareelite" then
							special = isBoss and "|c00e066ff(" .. ttRareBoss .. ")" or "|c00e066ff(" .. ttRareElite .. ")"
						elseif special == "worldboss" or (special == "normal" and level == -1 and isBoss) then
							special = "(" .. ttBoss .. ")"
						else
							special = ""
						end

						-- Show mob info line
						_G["GameTooltipTextLeft" .. mobLine]:SetText(GetLevelText(unit, level, nil, true) .. " " .. special)

					end

				end

				----------------------------------------------------------------------
				-- Backdrop color
				----------------------------------------------------------------------

				if LeaPlusLC["TipBackSimple"] == "On" then
					local faction = UnitFactionGroup(unit)
					if faction and faction ~= UnitFactionGroup("player") and UnitCanAttack("player", unit) and not isDead then
						-- Hostile faction
						GameTooltip.NineSlice:SetCenterColor(0.5, 0.0, 0.0)
					else
						-- Friendly faction
						GameTooltip.NineSlice:SetCenterColor(0.0, 0.0, 0.5)
					end
				end

				----------------------------------------------------------------------
				--	Show target
				----------------------------------------------------------------------

				if LeaPlusLC["TipShowTarget"] == "On" then

					local targetUnit = unit .. "target"
					if UnitExists(targetUnit) then

						-- Get target name (this can be secret)
						local target = UnitName(targetUnit)

						if C_Secrets.CanCompareUnitTokens(targetUnit, "player") and Safe(UnitIsUnit(targetUnit, "player")) then
							-- If target is you, set target to YOU
							target = "|c12ff4400" .. ttYou
						elseif UnitIsPlayer(targetUnit) then
							-- If it's not you, but it's a player, show target in class color
							local targetClass = Safe(UnitClassBase(targetUnit))
							local targetCol = targetClass and LeaPlusLC["RaidColors"][targetClass]
							if targetCol and target then target = ColorCode(targetCol) .. target end
						end

						-- Add target line (text is set separately as it can be secret)
						if target then
							GameTooltip:AddLine(" ")
							_G["GameTooltipTextLeft" .. GameTooltip:NumLines()]:SetText(ttTarget .. ": " .. target)
						end

					end

				end

			end

			TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, ShowTip)

		end

		----------------------------------------------------------------------
		--	Move chat editbox to top
		----------------------------------------------------------------------

		if LeaPlusLC["MoveChatEditBoxToTop"] == "On" and not LeaLockList["MoveChatEditBoxToTop"] then

			-- Set options for normal chat frames
			for i = 1, 50 do
				if _G["ChatFrame" .. i] then
					-- Position the editbox
					_G["ChatFrame" .. i .. "EditBox"]:ClearAllPoints()
					_G["ChatFrame" .. i .. "EditBox"]:SetPoint("TOP", _G["ChatFrame" .. i], "TOP", 0, 0)
					_G["ChatFrame" .. i .. "EditBox"]:SetPoint("LEFT", _G["ChatFrame" .. i], "LEFT", 0, 0)
					_G["ChatFrame" .. i .. "EditBox"]:SetPoint("RIGHT", _G["ChatFrame" .. i], "RIGHT", 0, 0)
				end
			end

			-- Do the functions above for other chat frames (pet battles, whispers, etc)
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					-- Position the editbox
					_G[cf .. "EditBox"]:ClearAllPoints()
					_G[cf .. "EditBox"]:SetPoint("TOP", cf, "TOP", 0, 0)
					_G[cf .. "EditBox"]:SetPoint("LEFT", cf, "LEFT", 0, 0)
					_G[cf .. "EditBox"]:SetPoint("RIGHT", cf, "RIGHT", 0, 0)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show borders
		----------------------------------------------------------------------

		if LeaPlusLC["ShowBorders"] == "On" then

			-- Create border textures
			local BordTop = WorldFrame:CreateTexture(nil, "ARTWORK"); BordTop:SetColorTexture(0, 0, 0, 1); BordTop:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0); BordTop:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
			local BordBot = WorldFrame:CreateTexture(nil, "ARTWORK"); BordBot:SetColorTexture(0, 0, 0, 1); BordBot:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0); BordBot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
			local BordLeft = WorldFrame:CreateTexture(nil, "ARTWORK"); BordLeft:SetColorTexture(0, 0, 0, 1); BordLeft:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0); BordLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
			local BordRight = WorldFrame:CreateTexture(nil, "ARTWORK"); BordRight:SetColorTexture(0, 0, 0, 1); BordRight:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0); BordRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)

			-- Create border configuration panel
			local bordersPanel = LeaPlusLC:CreatePanel("Show borders", "bordersPanel")

			-- Function to set border parameters
			local function RefreshBorders()

				-- Set border size and transparency
				BordTop:SetHeight(LeaPlusLC["BordersTop"]); BordTop:SetAlpha(1 - LeaPlusLC["BordersAlpha"])
				BordBot:SetHeight(LeaPlusLC["BordersBottom"]); BordBot:SetAlpha(1 - LeaPlusLC["BordersAlpha"])
				BordLeft:SetWidth(LeaPlusLC["BordersLeft"]); BordLeft:SetAlpha(1 - LeaPlusLC["BordersAlpha"])
				BordRight:SetWidth(LeaPlusLC["BordersRight"]); BordRight:SetAlpha(1 - LeaPlusLC["BordersAlpha"])

				-- Show formatted slider value
				LeaPlusCB["BordersAlpha"].f:SetFormattedText("%.0f%%", LeaPlusLC["BordersAlpha"] * 100)

			end

			-- Create slider controls
			LeaPlusLC:MakeTx(bordersPanel, "Top", 16, -72)
			LeaPlusLC:MakeSL(bordersPanel, "BordersTop", "Drag to set the size of the top border.", 0, 300, 5, 16, -92, "%.0f")
			LeaPlusCB["BordersTop"]:HookScript("OnValueChanged", RefreshBorders)

			LeaPlusLC:MakeTx(bordersPanel, "Bottom", 16, -132)
			LeaPlusLC:MakeSL(bordersPanel, "BordersBottom", "Drag to set the size of the bottom border.", 0, 300, 5, 16, -152, "%.0f")
			LeaPlusCB["BordersBottom"]:HookScript("OnValueChanged", RefreshBorders)

			LeaPlusLC:MakeTx(bordersPanel, "Left", 186, -72)
			LeaPlusLC:MakeSL(bordersPanel, "BordersLeft", "Drag to set the size of the left border.", 0, 300, 5, 186, -92, "%.0f")
			LeaPlusCB["BordersLeft"]:HookScript("OnValueChanged", RefreshBorders)

			LeaPlusLC:MakeTx(bordersPanel, "Right", 186, -132)
			LeaPlusLC:MakeSL(bordersPanel, "BordersRight", "Drag to set the size of the right border.", 0, 300, 5, 186, -152, "%.0f")
			LeaPlusCB["BordersRight"]:HookScript("OnValueChanged", RefreshBorders)

			LeaPlusLC:MakeTx(bordersPanel, "Transparency", 356, -132)
			LeaPlusLC:MakeSL(bordersPanel, "BordersAlpha", "Drag to set the transparency of the borders.", 0, 0.9, 0.1, 356, -152, "%.1f")
			LeaPlusCB["BordersAlpha"]:HookScript("OnValueChanged", RefreshBorders)

			-- Help button hidden
			bordersPanel.h:Hide()

			-- Back button handler
			bordersPanel.b:SetScript("OnClick", function()
				bordersPanel:Hide()
				LeaPlusLC["PageF"]:Show()
				LeaPlusLC["Page5"]:Show()
				return
			end)

			-- Reset button handler
			bordersPanel.r:SetScript("OnClick", function()
				LeaPlusLC["BordersTop"] = 0
				LeaPlusLC["BordersBottom"] = 0
				LeaPlusLC["BordersLeft"] = 0
				LeaPlusLC["BordersRight"] = 0
				LeaPlusLC["BordersAlpha"] = 0
				bordersPanel:Hide(); bordersPanel:Show()
				RefreshBorders()
			end)

			-- Configuration button handler
			LeaPlusCB["ModBordersBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaPlusLC["BordersTop"] = 0
					LeaPlusLC["BordersBottom"] = 0
					LeaPlusLC["BordersLeft"] = 0
					LeaPlusLC["BordersRight"] = 0
					LeaPlusLC["BordersAlpha"] = 0.7
					RefreshBorders()
				else
					bordersPanel:Show()
					LeaPlusLC:HideFrames()
				end
			end)

			-- Set borders on startup
			RefreshBorders()

			-- Hide borders when cinematic is shown
			hooksecurefunc(CinematicFrame, "Hide", function()
				BordTop:Show(); BordBot:Show(); BordLeft:Show(); BordRight:Show()
			end)
			hooksecurefunc(CinematicFrame, "Show", function()
				BordTop:Hide(); BordBot:Hide(); BordLeft:Hide(); BordRight:Hide()
			end)

		end

		----------------------------------------------------------------------
		-- Silence rested emotes
		----------------------------------------------------------------------

		-- Manage emotes
		if LeaPlusLC["NoRestedEmotes"] == "On" then

			-- Zone table 		English					, French					, German					, Italian						, Russian					, S Chinese	, Spanish					, T Chinese	,
			local zonetable = {	"The Halfhill Market"	, "Marché de Micolline"		, "Der Halbhügelmarkt"		, "Il Mercato di Mezzocolle"	, "Рынок Полугорья"			, "半山市集"	, "El Mercado del Alcor"	, "半丘市集"	,
								"The Grim Guzzler"		, "Le Sinistre écluseur"	, "Zum Grimmigen Säufer"	, "Torvo Beone"					, "Трактир Угрюмый обжора"	, "黑铁酒吧"	, "Tragapenas"				, "黑鐵酒吧"	,
								"The Summer Terrace"	, "La terrasse Estivale"	, "Die Sommerterrasse"		, "Terrazza Estiva"				, "Летняя терраса"			, "夏之台"	, "El Bancal del Verano"	, "夏日露臺"	,
			}

			-- Function to set rested state
			local function UpdateEmoteSound()

				-- Find character's current zone
				local szone = GetSubZoneText() or "None"

				-- Find out if emote sounds are disabled or enabled
				local emoset = GetCVar("Sound_EnableEmoteSounds")

				if IsResting() then
					-- Character is resting so silence emotes
					if emoset ~= "0" then
						SetCVar("Sound_EnableEmoteSounds", "0")
					end
					return
				end

				-- Traverse zone table and silence emotes if character is in a designated zone
				for k, v in next, zonetable do
					if szone == zonetable[k] then
						if emoset ~= "0" then
							SetCVar("Sound_EnableEmoteSounds", "0")
						end
						return
					end
				end

				-- Silence emotes if character is in a pet battle
				if C_PetBattles.IsInBattle() then
					if emoset ~= "0" then
						SetCVar("Sound_EnableEmoteSounds", "0")
					end
					return
				end

				-- If the above didn't return, emote sounds should be enabled
				if emoset ~= "1" then
					SetCVar("Sound_EnableEmoteSounds", "1")
				end
				return

			end

			-- Set emote sound when pet battles start and end
			hooksecurefunc("PetBattleFrame_Display", UpdateEmoteSound)
			hooksecurefunc("PetBattleFrame_Remove",	UpdateEmoteSound)

			-- Set emote sound when rest state or zone changes
			local RestEvent = CreateFrame("FRAME")
			RestEvent:RegisterEvent("PLAYER_UPDATE_RESTING")
            RestEvent:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			RestEvent:RegisterEvent("ZONE_CHANGED")
			RestEvent:RegisterEvent("ZONE_CHANGED_INDOORS")
			RestEvent:SetScript("OnEvent", UpdateEmoteSound)

			-- Set sound setting at startup
			UpdateEmoteSound()

		end

		----------------------------------------------------------------------
		-- Flares (world markers)
		----------------------------------------------------------------------

		do
			local raidTable = {L["Flare: Square"], L["Flare: Triangle"], L["Flare: Diamond"], L["Flare: Cross"], L["Flare: Star"], L["Flare: Circle"], L["Flare: Moon"], L["Flare: Skull"], L["Flare: Clear all"]}
			for i = 1, 9 do
				_G["BINDING_NAME_CLICK " .. "LeaPlusGlobalFlare" .. i ..":LeftButton"] = raidTable[i]
				local btn = CreateFrame("Button", "LeaPlusGlobalFlare" .. i, nil, "SecureActionButtonTemplate")
				btn:SetAttribute("type", "macro")
				if i == 9 then
					btn:SetAttribute("macrotext", "/clearworldmarker 1\n/clearworldmarker 2\n/clearworldmarker 3\n/clearworldmarker 4\n/clearworldmarker 5\n/clearworldmarker 6\n/clearworldmarker 7\n/clearworldmarker 8")
				else
					btn:SetAttribute("macrotext", "/clearworldmarker " .. i .. "\n/worldmarker " .. i)
				end
				btn:RegisterForClicks("AnyUp", "AnyDown")
			end
		end

		----------------------------------------------------------------------
		-- Frame alignment grid
		----------------------------------------------------------------------

		do

			-- Create frame alignment grid
			local grid = CreateFrame('FRAME')
			LeaPlusLC.grid = grid
			grid:Hide()
			grid:SetAllPoints(UIParent)
			local w, h = GetScreenWidth() * UIParent:GetEffectiveScale(), GetScreenHeight() * UIParent:GetEffectiveScale()
			local ratio = w / h
			local sqsize = w / 20
			local wline = floor(sqsize - (sqsize % 2))
			local hline = floor(sqsize / ratio - ((sqsize / ratio) % 2))
			-- Plot vertical lines
			for i = 0, wline do
				local t = LeaPlusLC.grid:CreateTexture(nil, 'BACKGROUND')
				if i == wline / 2 then t:SetColorTexture(1, 0, 0, 0.5) else t:SetColorTexture(0, 0, 0, 0.5) end
				t:SetPoint('TOPLEFT', grid, 'TOPLEFT', i * w / wline - 1, 0)
				t:SetPoint('BOTTOMRIGHT', grid, 'BOTTOMLEFT', i * w / wline + 1, 0)
			end
			-- Plot horizontal lines
			for i = 0, hline do
				local t = LeaPlusLC.grid:CreateTexture(nil, 'BACKGROUND')
				if i == hline / 2 then	t:SetColorTexture(1, 0, 0, 0.5) else t:SetColorTexture(0, 0, 0, 0.5) end
				t:SetPoint('TOPLEFT', grid, 'TOPLEFT', 0, -i * h / hline + 1)
				t:SetPoint('BOTTOMRIGHT', grid, 'TOPRIGHT', 0, -i * h / hline - 1)
			end

		end

		----------------------------------------------------------------------
		-- Media player
		----------------------------------------------------------------------

		function LeaPlusLC:MediaFunc()

			-- Create tables for list data
			local ListData, playlist = {}, {}
			local scrollFrame, willPlay, musicHandle, ZonePage, LastPlayed, LastFolder, TempFolder, HeadingOfClickedTrack, LastMusicHandle
			local numButtons = math.floor((LeaPlusLC.MainPanelHeight - 110) / 16) - 1
			local uframe = CreateFrame("FRAME")

			-- These categories will not appear in random track selections
			local randomBannedList = {L["Narration"], L["Cinematics"]}

			-- Remove the duplicate number some tracks have after the file ID (path#fileid#2 becomes path#fileid)
			local function StripDup(track)
				return (track:gsub("^(.-#%d+)#%d+$", "%1"))
			end

			-- Get media table
			local ZoneList = Leatrix_Plus["ZoneList"]

			-- Show relevant list items
			local function UpdateList()
				local offset = max(0, floor(scrollFrame:GetVerticalScroll() + 0.5))
				for i, button in ipairs(scrollFrame.buttons) do
					local index = offset + i
					if index <= #ListData then
						-- Show zone listing or track listing (store the full list entry on the button)
						button.item = ListData[index]
						local label = ListData[index].zone or ListData[index]
						-- Hide the duplicate number some tracks have after the file ID (path#fileid#2 shows as path#fileid)
						if type(ListData[index]) == "string" then label = StripDup(label) end
						button:SetText(label)
						-- Set width of highlight texture
						if button:GetTextWidth() > 290 then
							button.t:SetSize(290, 16)
						else
							button.t:SetSize(button:GetTextWidth(), 16)
						end
						-- Show the button
						button:Show()
						-- Hide highlight bar texture by default
						button.s:Hide()
						-- Hide highlight bar if the button is a heading
						if strfind(button:GetText(), "|c") then button.t:Hide() end
						-- Show last played track highlight bar texture
						if LastPlayed == button.item then
							local HeadingOfCurrentFolder = ListData[1]
							if HeadingOfCurrentFolder == HeadingOfClickedTrack then
								button.s:Show()
							end
						end
						-- Show last played folder highlight bar texture
						if LastFolder == button:GetText() then
							button.s:Show()
						end
						-- Set width of highlight bar
						if button:GetTextWidth() > 290 then
							button.s:SetSize(290, 16)
						else
							button.s:SetSize(button:GetTextWidth(), 16)
						end
						-- Limit click to label width
						local bWidth = button:GetFontString():GetStringWidth() or 0
						if bWidth > 290 then bWidth = 290 end
						button:SetHitRectInsets(0, 454 - bWidth, 0, 0)
						-- Disable label click movement
						button:SetPushedTextOffset(0, 0)
						-- Disable word wrap and set width
						button:GetFontString():SetWidth(290)
						button:GetFontString():SetWordWrap(false)
					else
						button:Hide()
					end
				end

				local bRoll = ((36 + (LeaPlusLC.MainPanelHeight - 370)) / 16) + 16
				scrollFrame.child:SetSize(200, #ListData + (math.floor(bRoll * 15)))

			end

			-- Give function file level scope (it's used in SetPlusScale to set the highlight bar scale)
			LeaPlusLC.UpdateList = UpdateList

			-- Right-button click to go back
			local function BackClick()
				-- Return to the current zone list (back button)
				if type(ListData[1]) == "string" then
					-- Strip the color code from the list data
					local nocol = string.gsub(ListData[1], "|cffffd800", "")
					-- Strip the zone
					local backzone = strsplit(":", nocol, 2)
					-- Don't go back if random or search category is being shown
					if backzone == L["Random"] or backzone == L["Search"] then return end
					-- Show the tracklist continent
					if ZoneList[backzone] then ListData = ZoneList[backzone] end
					UpdateList()
					scrollFrame:SetVerticalScroll(ZonePage or 0)
				end
			end

			-- Function to make navigation menu buttons
			local function MakeButton(where, y)
				local mbtn = CreateFrame("Button", nil, LeaPlusLC["Page9"])
				mbtn:Show()
				mbtn:SetAlpha(1.0)
				mbtn:SetPoint("TOPLEFT", 146, y)

				-- Create hover texture
				mbtn.t = mbtn:CreateTexture(nil, "BACKGROUND")
				mbtn.t:SetColorTexture(0.3, 0.3, 0.00, 0.8)
				mbtn.t:SetAlpha(0.7)
				mbtn.t:SetAllPoints()
				mbtn.t:Hide()

				-- Create highlight texture
				mbtn.s = mbtn:CreateTexture(nil, "BACKGROUND")
				mbtn.s:SetColorTexture(0.3, 0.3, 0.00, 0.8)
				mbtn.s:SetAlpha(1.0)
				mbtn.s:SetAllPoints()
				mbtn.s:Hide()

				-- Create fontstring
				mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				mbtn.f:SetPoint('LEFT', 1, 0)
				mbtn.f:SetText(L[where])

				mbtn:SetScript("OnEnter", function()
					mbtn.t:Show()
				end)

				mbtn:SetScript("OnLeave", function()
					mbtn.t:Hide()
				end)

				-- Set button size when shown
				mbtn:SetScript("OnShow", function()
					mbtn:SetSize(mbtn.f:GetStringWidth() + 1, 16)
				end)

				mbtn:SetScript("OnClick", function()
					-- Show zone listing for clicked item
					ListData = ZoneList[where]
					UpdateList()
				end)

				return mbtn, mbtn.s

			end

			-- Create a table for each button
			local conbtn = {}
			for q, w in pairs(ZoneList) do
				conbtn[q] = {}
			end

			-- Create buttons
			local function MakeButtonNow(title, anchor)
				conbtn[title], conbtn[title].s = MakeButton(title, height)
				conbtn[title]:ClearAllPoints()
				if title == L["Zones"] then
					-- Set first button position
					conbtn[title]:SetPoint("TOPLEFT", LeaPlusLC["Page9"], "TOPLEFT", 145, -70)
				elseif anchor then
					-- Set subsequent button positions
					conbtn[title]:SetPoint("TOPLEFT", conbtn[anchor], "BOTTOMLEFT", 0, 0)
					conbtn[title].f:SetText(L[title])
				end
			end

			MakeButtonNow(L["Zones"])
			MakeButtonNow(L["Dungeons"], L["Zones"])
			MakeButtonNow(L["Various"], L["Dungeons"])
			MakeButtonNow(L["Movies"], L["Various"])
			MakeButtonNow(L["Random"], L["Movies"])
			MakeButtonNow(L["Search"]) -- Positioned when search editbox is created

			-- Show button highlight for clicked button
			for q, w in pairs(ZoneList) do
				if type(w) == "string" and conbtn[w] then
					conbtn[w]:HookScript("OnClick", function()
						-- Hide all button highlights
						for k, v in pairs(ZoneList) do
							if type(v) == "string" and conbtn[v] then
								conbtn[v].s:Hide()
							end
						end
						-- Show clicked button highlight
						conbtn[w].s:Show()
						LeaPlusDB["MusicContinent"] = w
						scrollFrame:SetVerticalScroll(0)
						-- Set TempFolder for listings without folders
						if w == L["Random"] then TempFolder = L["Random"] end
						if w == L["Search"] then TempFolder = L["Search"] end
					end)
				end
			end

			-- Create scroll bar
			scrollFrame = CreateFrame("ScrollFrame", nil, LeaPlusLC["Page9"], "ScrollFrameTemplate")
			scrollFrame:SetPoint("TOPLEFT", 0, -32)
			scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)
			scrollFrame:SetPanExtent(1)
			scrollFrame:SetScript("OnVerticalScroll", UpdateList)

			-- Create the scroll child
			scrollFrame.child = CreateFrame("Frame", nil, scrollFrame)
			scrollFrame:SetScrollChild(scrollFrame.child)

			-- Add stop button
			local stopBtn = LeaPlusLC:CreateButton("StopMusicBtn", LeaPlusLC["Page9"], "Stop", "BOTTOMLEFT", 146, 53, 0, 25, true, "")
			stopBtn:Hide(); stopBtn:Show()
			LeaPlusLC:LockItem(stopBtn, true)
			stopBtn:SetScript("OnClick", function()
				-- Unregister loading screen event and cancel the track monitor first so stopping doesn't start the next track
				uframe:UnregisterEvent("LOADING_SCREEN_DISABLED")
				if LeaPlusLC.TrackTimer then LeaPlusLC.TrackTimer:Cancel() end
				LastMusicHandle = nil
				if musicHandle then
					StopSound(musicHandle)
					musicHandle = nil
					-- Hide highlight bars
					LastPlayed = ""
					LastFolder = ""
					UpdateList()
				end
				-- Lock button
				LeaPlusLC:LockItem(stopBtn, true)
			end)

			-- Store currently playing track number
			local tracknumber = 1

			-- Count tracks in a row that failed to start (stops the player looping forever if nothing can play)
			local failedTracks = 0

			-- Forward declaration so the track monitor can move on to the next track
			local PlayTrack

			-- Function to play the next track in the playlist
			local function PlayNextTrack()
				-- Playlist is at the end (last entry repeats the first track), restart from first track
				if tracknumber >= #playlist then tracknumber = 1 end
				PlayTrack()
			end

			-- Function to play a track and show the static highlight bar
			function PlayTrack()
				if not playlist[tracknumber] then return end
				-- Stop the previous track and its monitor (clear the handle first so stopping it doesn't trigger the next track)
				if LeaPlusLC.TrackTimer then LeaPlusLC.TrackTimer:Cancel() end
				local oldHandle = musicHandle
				musicHandle, LastMusicHandle = nil, nil
				if oldHandle then StopSound(oldHandle) end
				-- Play music file (entries are path#filedataid)
				local file, soundID = playlist[tracknumber]:match("^(.-)#(%d+)")
				willPlay, musicHandle = PlaySoundFile(tonumber(soundID) or soundID, "Master")
				if willPlay and musicHandle then
					-- Watch the track and play the next one when it stops playing
					failedTracks = 0
					local thisHandle, ticker = musicHandle
					ticker = C_Timer.NewTicker(1, function()
						-- Another track has started since this one so stop watching
						if musicHandle ~= thisHandle then ticker:Cancel() return end
						if not C_Sound.IsPlaying(thisHandle) then
							-- Track has finished
							ticker:Cancel()
							PlayNextTrack()
						end
					end)
					LeaPlusLC.TrackTimer = ticker
				else
					-- Track could not be played so try the next one (give up after a full pass of the playlist)
					failedTracks = failedTracks + 1
					if failedTracks < #playlist then
						LeaPlusLC.TrackTimer = C_Timer.NewTimer(1, PlayNextTrack)
					end
				end
				-- Store its handle for later use
				LastMusicHandle = musicHandle
				LastPlayed = playlist[tracknumber]
				tracknumber = tracknumber + 1
				-- Show static highlight bar
				for index = 1, numButtons do
					local button = scrollFrame.buttons[index]
					local item = button:IsShown() and button.item
					if type(item) == "string" and item:match("^(.-)#(%d+)") then
						if item == LastPlayed and LastFolder == TempFolder then
							button.s:Show()
						else
							button.s:Hide()
						end
					end
				end
			end

			-- Create editbox for search
			local sBox = LeaPlusLC:CreateEditBox("MusicSearchBox", LeaPlusLC["Page9"], 78, 10, "TOPLEFT", 150, -(LeaPlusLC.MainPanelHeight - 110), "MusicSearchBox", "MusicSearchBox")
			sBox:SetMaxLetters(50)

			-- Position search button above editbox
			conbtn[L["Search"]]:ClearAllPoints()
			conbtn[L["Search"]]:SetPoint("BOTTOMLEFT", sBox, "TOPLEFT", -4, 0)

			-- Set initial search data
			for q, w in pairs(ZoneList) do
				if conbtn[w] then
					conbtn[w]:HookScript("OnClick", function()
						if w == L["Search"] then
							ListData[1] = "|cffffd800" .. L["Search"]
							if #ListData == 1 then
								ListData[2] = "|cffffffaa{" .. L["enter zone or track name"] .. "}"
							end
							UpdateList()
						else
							sBox:ClearFocus()
						end
					end)
				end
			end

			-- Function to show search results
			local function ShowSearchResults()
				-- Get search words (lower case and matched as plain text, so pattern characters don't need escaping)
				local searchText = strtrim(strlower(sBox:GetText() or ""))
				-- Wipe the track listing
				wipe(ListData)
				-- Set the track list heading
				ListData[1] = "|cffffd800" .. L["Search"]
				-- Show the subheading only if no search results are being shown
				if searchText == "" then
					ListData[2] = "|cffffffaa{" .. L["enter zone or track name"] .. "}"
				else
					ListData[2] = ""
					-- Up to five search words
					local words = {}
					for word in searchText:gmatch("%S+") do
						if #words < 5 then words[#words + 1] = word end
					end
					-- Traverse music listing and populate ListData
					local hash = {}
					local trackCount = 0
					for i, e in ipairs(ZoneList) do
						local entries = ZoneList[e]
						if entries then
							for a, b in ipairs(entries) do
								if type(b) == "table" and b.tracks then
									-- Lower the zone and category once per entry (not once per track and word)
									local zoneLower, categoryLower = strlower(b.zone), strlower(b.category)
									-- Words found in the zone or category match every track in it, so only the rest are checked per track
									local trackWords = {}
									for w = 1, #words do
										if not strfind(zoneLower, words[w], 1, true) and not strfind(categoryLower, words[w], 1, true) then
											trackWords[#trackWords + 1] = words[w]
										end
									end
									for k, v in ipairs(b.tracks) do
										if strfind(v, "#", 1, true) or strfind(v, "|r", 1, true) then
											local match = true
											if #trackWords > 0 then
												local vLower = strlower(v)
												for w = 1, #trackWords do
													if not strfind(vLower, trackWords[w], 1, true) then match = false break end
												end
											end
											if match then
												-- Show category
												if not hash[b.category] then
													tinsert(ListData, "|cffffffff")
													if b.category == e then
														-- No category so just show ZoneList entry (such as Various)
														tinsert(ListData, "|cffffd800" .. e)
													else
														-- Category exists so show that
														tinsert(ListData, "|cffffd800" .. e .. ": " .. b.category)
													end
													hash[b.category] = true
												end
												-- Show track (only once if it appears more than once in the same entry)
												local dupKey = "|Cffffffaa" .. b.zone .. " |r" .. StripDup(v)
												if not hash[dupKey] then
													tinsert(ListData, "|Cffffffaa" .. b.zone .. " |r" .. v)
													trackCount = trackCount + 1
													hash[dupKey] = true
												end
											end
										end
									end
								end
							end
						end
					end

					-- Set results tag
					if trackCount == 1 then
						ListData[2] = "|cffffffaa{" .. trackCount .. " " .. L["result"] .. "}"
					else
						ListData[2] = "|cffffffaa{" .. trackCount .. " " .. L["results"] .. "}"
					end
				end
				-- Refresh the track listing
				UpdateList()
				-- Set track listing to top
				scrollFrame:SetVerticalScroll(0)
			end

			-- Search runs once typing pauses (not on every key press)
			local searchTimer
			local function SearchSoon()
				if searchTimer then searchTimer:Cancel() end
				searchTimer = C_Timer.NewTimer(0.25, function()
					searchTimer = nil
					ShowSearchResults()
				end)
			end

			-- Populate ListData when editbox is changed by user
			sBox:HookScript("OnTextChanged", function(self, userInput)
				if userInput then
					-- Show search page
					conbtn[L["Search"]]:Click()
					-- If search results are currently playing, stop playback since search results will be changed
					if LastFolder == L["Search"] then stopBtn:Click() end
					-- Show search results when typing pauses
					SearchSoon()
				end
			end)

			-- Populate ListData when editbox enter key is pressed
			sBox:HookScript("OnEnterPressed", function()
				-- Cancel any waiting search and search now
				if searchTimer then searchTimer:Cancel(); searchTimer = nil end
				-- Show search page
				conbtn[L["Search"]]:Click()
				-- If search results are currently playing, stop playback since search results will be changed
				if LastFolder == L["Search"] then stopBtn:Click() end
				-- Show search results
				ShowSearchResults()
			end)

			-- Function to get random argument for random track listing
			local function GetRandomArgument(...)
				return (select(random(select("#", ...)), ...))
			end

			-- Function to show random track listing
			local function ShowRandomList()
				-- If random track is currently playing, stop playback since random track list will be changed
				if LastFolder == L["Random"] then
					stopBtn:Click()
				end
				-- Wipe the track listing for random
				wipe(ListData)
				-- Set the track list heading
				ListData[1] = "|cffffd800" .. L["Random"]
				ListData[2] = "|Cffffffaa{" .. L["click here for new selection"] .. "}" -- Must be capital |C
				ListData[3] = "|cffffd800"
				ListData[4] = "|cffffd800" .. L["Selection of music tracks"] -- Must be lower case |c
				-- Populate list data until it contains desired number of tracks
				while #ListData < 50 do
					-- Get random category
					local rCategory = GetRandomArgument(L["Zones"], L["Dungeons"], L["Various"])
					-- Get random zone within category
					local rZone = random(1, #ZoneList[rCategory])
					-- Get random track within zone
					local rTrack = ZoneList[rCategory][rZone].tracks[random(1, #ZoneList[rCategory][rZone].tracks)]
					-- Insert track into ListData if it's not a duplicate or on the banned list
					-- Check the track isn't already listed (ignoring any duplicate number)
					local alreadyListed = false
					if rTrack and rTrack ~= "" and strfind(rTrack, "#") then
						local rKey = "|Cffffffaa" .. ZoneList[rCategory][rZone].zone .. " |r" .. StripDup(rTrack)
						for n = 5, #ListData do
							if StripDup(ListData[n]) == rKey then alreadyListed = true break end
						end
					end
					if rTrack and rTrack ~= "" and strfind(rTrack, "#") and not alreadyListed then
						if not table.contains(randomBannedList, L[ZoneList[rCategory][rZone].zone]) and not table.contains(randomBannedList, rTrack) then
							tinsert(ListData, "|Cffffffaa" .. ZoneList[rCategory][rZone].zone .. " |r" .. rTrack)
						end
					end
				end
				-- Refresh the track listing
				UpdateList()
				-- Set track listing to top
				scrollFrame:SetVerticalScroll(0)
			end

			-- Show random track listing on startup when random button is clicked
			for q, w in pairs(ZoneList) do
				if conbtn[w] then
					conbtn[w]:HookScript("OnClick", function()
						if w == L["Random"] then
							-- Generate initial playlist for first run
							if #ListData == 0 then
								ShowRandomList()
							end
						end
					end)
				end
			end

			-- Create list items
			scrollFrame.buttons = {}
			for i = 1, numButtons do
				scrollFrame.buttons[i] = CreateFrame("Button", nil, LeaPlusLC["Page9"])
				local button = scrollFrame.buttons[i]

				button:SetSize(470 - 14, 16)
				button:SetNormalFontObject("GameFontHighlightLeft")
				button:SetPoint("TOPLEFT", 246, -62+ -(i - 1) * 16 - 8)

				-- Create highlight bar texture
				button.t = button:CreateTexture(nil, "BACKGROUND")
				button.t:SetPoint("TOPLEFT", button, 0, 0)
				button.t:SetSize(516, 16)

				button.t:SetColorTexture(0.3, 0.3, 0.0, 0.8)
				button.t:SetAlpha(0.7)
				button.t:Hide()

				-- Create last playing highlight bar texture
				button.s = button:CreateTexture(nil, "BACKGROUND")
				button.s:SetPoint("TOPLEFT", button, 0, 0)
				button.s:SetSize(516, 16)

				button.s:SetColorTexture(0.3, 0.4, 0.00, 0.6)
				button.s:Hide()

				button:SetScript("OnEnter", function()
					-- Highlight links only
					if not string.match(button:GetText() or "", "|c") then
						button.t:Show()
					end
				end)

				button:SetScript("OnLeave", function()
					button.t:Hide()
				end)

				button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

				-- Handler for restarting the player after a loading screen (track endings are watched in PlayTrack)
				uframe:SetScript("OnEvent", function(self, event)
					if event == "LOADING_SCREEN_DISABLED" then
						-- Restart player if it stopped between tracks during loading screen
						if playlist and tracknumber and playlist[tracknumber] and not willPlay and not musicHandle then
							tracknumber = tracknumber - 1
							C_Timer.After(0.1, PlayTrack)
						end
					end
				end)

				-- Click handler for track, zone and back button
				button:SetScript("OnClick", function(self, btn)
					if btn == "LeftButton" then
						-- Remove focus from search box
						sBox:ClearFocus()
						-- Get clicked list entry (full entry, including any hidden duplicate number)
						local item = type(self.item) == "string" and self.item or self:GetText()
						-- Do nothing if its a blank line or informational heading
						if not item or strfind(item, "|c") then return end
						if item == "|Cffffffaa{" .. L["click here for new selection"] .. "}" then -- must be capital |C
							-- Create new random track listing
							ShowRandomList()
							return
						elseif strfind(item, "#") then
							-- Enable sound if required
							if GetCVar("Sound_EnableAllSound") == "0" then SetCVar("Sound_EnableAllSound", "1") end
							-- Disable music if it's currently enabled
							if GetCVar("Sound_EnableMusic") == "1" then	SetCVar("Sound_EnableMusic", "0") end
							-- Add all tracks to playlist
							wipe(playlist)
							local StartItem = 0
							-- Get item clicked row number
							for index = 1, #ListData do
								if ListData[index] == item then StartItem = index end
							end
							-- Add all items from clicked item onwards to playlist
							for index = StartItem, #ListData do
								local item = ListData[index]
								if item then
									if strfind(item, "#") then
										tinsert(playlist, item)
									end
								end
							end
							-- Add all items up to clicked item to playlist
							for index = 1, StartItem do
								local item = ListData[index]
								if item then
									if strfind(item, "#") then
										tinsert(playlist, item)
									end
								end
							end
							-- Enable the stop button
							LeaPlusLC:LockItem(stopBtn, false)
							-- Set Temp Folder to Random if track is in Random
							if ListData[1] == "|cffffd800" .. L["Random"] then TempFolder = L["Random"] end
							-- Set Temp Folder to Search if track is in Search
							if ListData[1] == "|cffffd800" .. L["Search"] then TempFolder = L["Search"] end
							-- Store information about the track we are about to play
							tracknumber = 1
							LastPlayed = item
							LastFolder = TempFolder
							HeadingOfClickedTrack = ListData[1]
							-- Play first track
							PlayTrack()
							-- Restart the player if a loading screen stops it between tracks
							uframe:RegisterEvent("LOADING_SCREEN_DISABLED")
							return
						elseif strfind(item, "|r") then
							-- A movie was clicked
							if not LeaPlusLC.MovieFinishedIsHooked then
								-- Workaround for movie frame hiding media player
								MovieFrame:HookScript("OnMovieFinished", function(self)
									if LeaPlusLC.MoviePlaying then
										LeaPlusLC.MoviePlaying = false
										if not LeaPlusLC["PageF"]:IsShown() then
											LeaPlusLC:HideFrames()
											LeaPlusLC["PageF"]:Show()
											LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
										end
									end
								end)
								LeaPlusLC.MovieFinishedIsHooked = true
							end
							local movieName, movieID = item:match("([^,]+)%|r([^,]+)")
							movieID = strtrim(movieID, "()")
							if IsMoviePlayable(movieID) then
								stopBtn:Click()
								LeaPlusLC.MoviePlaying = true
								MovieFrame_PlayMovie(MovieFrame, movieID)
							else
								LeaPlusLC:Print("Movie not playable.")
							end
							return
						else
							-- A zone was clicked so show track listing
							ZonePage = scrollFrame:GetVerticalScroll()
							-- Find the track listing for the clicked zone
							for q, w in pairs(ZoneList) do
								for k, v in pairs(ZoneList[w]) do
									if item == v.zone then
										-- Show track listing
										TempFolder = item
										LeaPlusDB["MusicZone"] = item
										ListData = v.tracks
										UpdateList()
										-- Hide hover highlight if track under pointer is a heading
										if strfind(scrollFrame.buttons[i]:GetText(), "|c") then
											scrollFrame.buttons[i].t:Hide()
										end
										-- Show top of track list
										scrollFrame:SetVerticalScroll(0)
										return
									end
								end
							end
						end
					elseif btn == "RightButton" then
						-- Back button was clicked
						BackClick()
					end
				end)

			end

			-- Right-click to go back (from anywhere on the main content area of the panel)
			LeaPlusLC["PageF"]:HookScript("OnMouseUp", function(self, btn)
				if LeaPlusLC["Page9"]:IsShown() and LeaPlusLC["Page9"]:IsMouseOver(0, 0, 0, -440) == false and LeaPlusLC["Page9"]:IsMouseOver(-(LeaPlusLC.MainPanelHeight - 47), 0, 0, 0) == false then
					if btn == "RightButton" then
						BackClick()
					end
				end
			end)

			-- Set zone listing on startup
			if LeaPlusDB["MusicContinent"] and LeaPlusDB["MusicContinent"] ~= "" then
				-- Saved music continent exists
				if conbtn[LeaPlusDB["MusicContinent"]] then
					-- Saved continent is valid button so click it
					conbtn[LeaPlusDB["MusicContinent"]]:Click()
				else
					-- Saved continent is not valid button so click default button
					conbtn[L["Zones"]]:Click()
				end
			else
				-- Saved music continent does not exist so click default button
				conbtn[L["Zones"]]:Click()
			end
			UpdateList()

			-- Manage events
			LeaPlusLC["Page9"]:RegisterEvent("PLAYER_LOGOUT")
			LeaPlusLC["Page9"]:RegisterEvent("UI_SCALE_CHANGED")
			LeaPlusLC["Page9"]:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_LOGOUT" then
					-- Stop playing at reload or logout
					if musicHandle then
						StopSound(musicHandle)
					end
				elseif event == "UI_SCALE_CHANGED" then
					-- Refresh list
					UpdateList()
				end
			end)

		end

		-- Run on startup
		LeaPlusLC:MediaFunc()

		-- Release memory
		LeaPlusLC.MediaFunc = nil

		----------------------------------------------------------------------
		-- Panel alpha
		----------------------------------------------------------------------

		do

			-- Function to set panel alpha
			local function SetPlusAlpha()
				-- Set panel alpha
				LeaPlusLC["PageF"].t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
				-- Show formatted value
				LeaPlusCB["PlusPanelAlpha"].f:SetFormattedText("%.0f%%", LeaPlusLC["PlusPanelAlpha"] * 100)
			end

			-- Set alpha on startup
			SetPlusAlpha()

			-- Set alpha after changing slider
			LeaPlusCB["PlusPanelAlpha"]:HookScript("OnValueChanged", SetPlusAlpha)

		end

		----------------------------------------------------------------------
		-- Panel scale
		----------------------------------------------------------------------

		do

			-- Function to set panel scale
			local function SetPlusScale()
				-- Reset panel position
				LeaPlusLC["MainPanelA"], LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				if LeaPlusLC["PageF"]:IsShown() then
					LeaPlusLC["PageF"]:Hide()
					LeaPlusLC["PageF"]:Show()
				end
				-- Set panel scale
				LeaPlusLC["PageF"]:SetScale(LeaPlusLC["PlusPanelScale"])
				-- Update music player highlight bar scale
				LeaPlusLC:UpdateList()
			end

			-- Set scale on startup
			LeaPlusLC["PageF"]:SetScale(LeaPlusLC["PlusPanelScale"])

			-- Set scale and reset panel position after changing slider
			LeaPlusCB["PlusPanelScale"]:HookScript("OnMouseUp", SetPlusScale)
			LeaPlusCB["PlusPanelScale"]:HookScript("OnMouseWheel", SetPlusScale)

			-- Show formatted slider value
			LeaPlusCB["PlusPanelScale"]:HookScript("OnValueChanged", function()
				LeaPlusCB["PlusPanelScale"].f:SetFormattedText("%.0f%%", LeaPlusLC["PlusPanelScale"] * 100)
			end)

		end

		----------------------------------------------------------------------
		-- Create panel in game options panel
		----------------------------------------------------------------------

		do

			local interPanel = CreateFrame("FRAME")
			interPanel.name = "Leatrix Plus"

			local maintitle = LeaPlusLC:MakeTx(interPanel, "Leatrix Plus", 0, 0)
			maintitle:SetFont(maintitle:GetFont(), 72)
			maintitle:ClearAllPoints()
			maintitle:SetPoint("TOP", 0, -72)

			local expTitle = LeaPlusLC:MakeTx(interPanel, "Shadowlands", 0, 0)
			expTitle:SetFont(expTitle:GetFont(), 32)
			expTitle:ClearAllPoints()
			expTitle:SetPoint("TOP", 0, -152)

			local subTitle = LeaPlusLC:MakeTx(interPanel, "curseforge.com/wow/addons/leatrix-plus", 0, 0)
			subTitle:SetFont(subTitle:GetFont(), 20)
			subTitle:ClearAllPoints()
			subTitle:SetPoint("BOTTOM", 0, 72)

			local slashTitle = LeaPlusLC:MakeTx(interPanel, "/ltp", 0, 0)
			slashTitle:SetFont(slashTitle:GetFont(), 72)
			slashTitle:ClearAllPoints()
			slashTitle:SetPoint("BOTTOM", subTitle, "TOP", 0, 40)
			slashTitle:SetScript("OnMouseUp", function(self, button)
				if button == "LeftButton" then
					SlashCmdList["Leatrix_Plus"]("")
				end
			end)
			slashTitle:SetScript("OnEnter", function()
				slashTitle.r,  slashTitle.g, slashTitle.b = slashTitle:GetTextColor()
				slashTitle:SetTextColor(1, 1, 0)
			end)
			slashTitle:SetScript("OnLeave", function()
				slashTitle:SetTextColor(slashTitle.r, slashTitle.g, slashTitle.b)
			end)

			local pTex = interPanel:CreateTexture(nil, "BACKGROUND")
			pTex:SetAllPoints()
			pTex:SetTexture("Interface\\GLUES\\Models\\UI_MainMenu\\swordgradient2")
			pTex:SetAlpha(0.2)
			pTex:SetTexCoord(0, 1, 1, 0)

			expTitle:SetText(L["Midnight"])

			local category = Settings.RegisterCanvasLayoutCategory(interPanel, L["Leatrix Plus"])
			Settings.RegisterAddOnCategory(category)

		end

		----------------------------------------------------------------------
		-- Final code for Player
		----------------------------------------------------------------------

		-- Show first run message
		if not LeaPlusDB["FirstRunMessageSeen"] then
			C_Timer.After(1, function()
				LeaPlusLC:Print(L["Enter"] .. " |cff00ff00" .. "/ltp" .. "|r " .. L["or click the minimap button to open Leatrix Plus."])
				LeaPlusDB["FirstRunMessageSeen"] = true
			end)
		end

		-- Register logout event to save settings
		LpEvt:RegisterEvent("PLAYER_LOGOUT")

		-- Update addon memory usage (speeds up initial value)
		UpdateAddOnMemoryUsage()

		-- Release memory
		LeaPlusLC.Player = nil

	end

----------------------------------------------------------------------
-- 	L60: Default events
----------------------------------------------------------------------

	local function eventHandler(self, event, arg1, arg2, ...)

		----------------------------------------------------------------------
		-- L62: Profile events
		----------------------------------------------------------------------

		if event == "ADDON_LOADED" then
			if arg1 == "Leatrix_Plus" then

				-- Replace old var names with new ones
				local function UpdateVars(oldvar, newvar)
					if LeaPlusDB[oldvar] and not LeaPlusDB[newvar] then LeaPlusDB[newvar] = LeaPlusDB[oldvar]; LeaPlusDB[oldvar] = nil end
				end

				UpdateVars("SetChatFontSize", "MoreChatFontSizes")			-- 12.1.15 (18th October 2026)

				-- Automation
				LeaPlusLC:LoadVarChk("AutomateQuests", "Off")				-- Automate quests
				LeaPlusLC:LoadVarChk("AutoQuestShift", "Off")				-- Automate quests requires shift
				LeaPlusLC:LoadVarChk("AutoQuestRegular", "On")				-- Accept regular quests
				LeaPlusLC:LoadVarChk("AutoQuestDaily", "On")				-- Accept daily quests
				LeaPlusLC:LoadVarChk("AutoQuestWeekly", "On")				-- Accept weekly quests
				LeaPlusLC:LoadVarChk("AutoQuestCompleted", "On")			-- Turn-in completed quests
				LeaPlusLC:LoadVarNum("AutoQuestKeyMenu", 1, 1, 4)			-- Automate quests override key
				LeaPlusLC:LoadVarChk("AutomateGossip", "Off")				-- Automate gossip
				LeaPlusLC:LoadVarChk("AutoAcceptSummon", "Off")				-- Accept summon
				LeaPlusLC:LoadVarChk("AutoAcceptRes", "Off")				-- Accept resurrection
				LeaPlusLC:LoadVarChk("AutoResNoCombat", "On")				-- Accept resurrection exclude combat
				LeaPlusLC:LoadVarChk("AutoResNoAfterlife", "Off")			-- Accept resurrection exclude afterlife
				LeaPlusLC:LoadVarChk("AutoReleasePvP", "Off")				-- Release in PvP
				LeaPlusLC:LoadVarChk("AutoReleaseNoAlterac", "Off")			-- Release in PvP Exclude Alterac Valley
				LeaPlusLC:LoadVarChk("AutoReleaseNoWintergsp", "Off")		-- Release in PvP Exclude Wintergrasp
				LeaPlusLC:LoadVarChk("AutoReleaseNoTolBarad", "Off")		-- Release in PvP Exclude Tol Barad (PvP)
				LeaPlusLC:LoadVarChk("AutoReleaseNoAshran", "Off")			-- Release in PvP Exclude Ashran
				LeaPlusLC:LoadVarNum("AutoReleaseDelay", 0, 0, 3000)		-- Release in PvP Delay

				LeaPlusLC:LoadVarChk("AutoSellJunk", "Off")					-- Sell junk automatically
				LeaPlusLC:LoadVarChk("AutoSellShowSummary", "On")			-- Sell junk summary in chat
				LeaPlusLC:LoadVarChk("AutoSellNoKeeperTahult", "On")		-- Sell junk exclude Keeper Ta'hult
				LeaPlusLC:LoadVarChk("AutoSellNoGreyGear", "Off")			-- Sell junk exclude all grey gear
				LeaPlusLC:LoadVarStr("AutoSellExcludeList", "")				-- Sell junk exclude list
				LeaPlusLC:LoadVarChk("AutoRepairGear", "Off")				-- Repair automatically
				LeaPlusLC:LoadVarChk("AutoRepairGuildFunds", "On")			-- Repair using guild funds
				LeaPlusLC:LoadVarChk("AutoRepairShowSummary", "On")			-- Repair show summary in chat

				-- Social
				LeaPlusLC:LoadVarChk("NoDuelRequests", "Off")				-- Block duels
				LeaPlusLC:LoadVarChk("NoPetDuels", "Off")					-- Block pet battle duels
				LeaPlusLC:LoadVarChk("NoPartyInvites", "Off")				-- Block party invites
				LeaPlusLC:LoadVarChk("NoRequestedInvites", "Off")			-- Block requested invites
				LeaPlusLC:LoadVarChk("NoFriendRequests", "Off")				-- Block friend requests
				LeaPlusLC:LoadVarChk("NoSharedQuests", "Off")				-- Block shared quests

				LeaPlusLC:LoadVarChk("AcceptPartyFriends", "Off")			-- Party from friends
				LeaPlusLC:LoadVarChk("SyncFromFriends", "Off")				-- Sync from friends
				LeaPlusLC:LoadVarChk("AutoConfirmRole", "Off")				-- Queue from friends
				LeaPlusLC:LoadVarChk("InviteFromWhisper", "Off")			-- Invite from whispers
				LeaPlusLC:LoadVarChk("InviteFriendsOnly", "Off")			-- Restrict invites to friends
				LeaPlusLC["InvKey"]	= LeaPlusDB["InvKey"] or "inv"			-- Invite from whisper keyword
				LeaPlusLC:LoadVarChk("FriendlyCommunities", "Off")			-- Friendly communities
				LeaPlusLC:LoadVarChk("FriendlyGuild", "On")					-- Friendly guild

				-- Chat
				LeaPlusLC:LoadVarChk("UseEasyChatResizing", "Off")			-- Use easy resizing
				LeaPlusLC:LoadVarChk("NoCombatLogTab", "Off")				-- Hide the combat log
				LeaPlusLC:LoadVarChk("NoChatButtons", "Off")				-- Hide chat buttons
				LeaPlusLC:LoadVarChk("ShowVoiceButtons", "Off")				-- Show voice buttons
				LeaPlusLC:LoadVarChk("ShowChatMenuButton", "Off")			-- Show chat menu button
				LeaPlusLC:LoadVarChk("NoSocialButton", "Off")				-- Hide social button
				LeaPlusLC:LoadVarChk("UnclampChat", "Off")					-- Unclamp chat frame
				LeaPlusLC:LoadVarChk("MoveChatEditBoxToTop", "Off")			-- Move editbox to top
				LeaPlusLC:LoadVarChk("MoreChatFontSizes", "Off")			-- More chat font sizes

				LeaPlusLC:LoadVarChk("NoStickyChat", "Off")					-- Disable sticky chat
				LeaPlusLC:LoadVarChk("UseArrowKeysInChat", "Off")			-- Use arrow keys in chat
				LeaPlusLC:LoadVarChk("NoChatFade", "Off")					-- Disable chat fade
				LeaPlusLC:LoadVarChk("UnivGroupColor", "Off")				-- Universal group color
				LeaPlusLC:LoadVarChk("RecentChatWindow", "Off")				-- Recent chat window
				LeaPlusLC:LoadVarNum("RecentChatSize", 170, 170, 600)		-- Recent chat size
				LeaPlusLC:LoadVarChk("FilterChatMessages", "Off")			-- Filter chat messages
				LeaPlusLC:LoadVarChk("BlockSpellLinks", "Off")				-- Block spell links
				LeaPlusLC:LoadVarChk("BlockDrunkenSpam", "Off")				-- Block drunken spam
				LeaPlusLC:LoadVarChk("BlockDuelSpam", "Off")				-- Block duel spam
				LeaPlusLC:LoadVarChk("BlockAngelisSinny", "Off")			-- Block Angelis and Sinny spam
				LeaPlusLC:LoadVarChk("RestoreChatMessages", "Off")			-- Restore chat messages

				-- Text
				LeaPlusLC:LoadVarChk("HideErrorMessages", "Off")			-- Hide error messages
				LeaPlusLC:LoadVarChk("NoHitIndicators", "Off")				-- Hide portrait numbers
				LeaPlusLC:LoadVarChk("HideZoneText", "Off")					-- Hide zone text
				LeaPlusLC:LoadVarChk("HideKeybindText", "Off")				-- Hide keybind text
				LeaPlusLC:LoadVarChk("HideMacroText", "Off")				-- Hide macro text

				LeaPlusLC:LoadVarChk("QuestFontChange", "Off")				-- Resize quest text
				LeaPlusLC:LoadVarNum("LeaPlusQuestFontSize", 12, 10, 30)	-- Quest text slider

				-- Interface
				LeaPlusLC:LoadVarChk("MinimapModder", "Off")				-- Enhance minimap
				LeaPlusLC:LoadVarChk("SquareMinimap", "On")					-- Square minimap
				LeaPlusLC:LoadVarChk("HideMiniAddonMenu", "On")				-- Hide addon menu
				LeaPlusLC:LoadVarChk("UnclampMinimap", "Off")				-- Unclamp minimap cluster
				LeaPlusLC:LoadVarChk("MinimapButtonBag", "Off")				-- Minimap button bag
				LeaPlusLC:LoadVarStr("MiniExcludeList", "")					-- Minimap exclude list
				LeaPlusLC:LoadVarChk("HideMiniAddonButtons", "On")			-- Hide addon buttons
				LeaPlusLC:LoadVarNum("MinimapBorderWidth", 3, 1, 10)		-- Minimap border width
				LeaPlusLC:LoadVarNum("MiniClusterScale", 1, 0.5, 2)			-- Minimap cluster scale
				LeaPlusLC:LoadVarNum("MinimapEffect", 1, 1, 33)				-- Minimap effect

				LeaPlusLC:LoadVarChk("TipModEnable", "Off")					-- Enhance tooltip
				LeaPlusLC:LoadVarChk("TipShowRank", "On")					-- Show rank for your guild
				LeaPlusLC:LoadVarChk("TipShowOtherRank", "Off")				-- Show rank for other guilds
				LeaPlusLC:LoadVarChk("TipShowTarget", "On")					-- Show target
				LeaPlusLC:LoadVarChk("TipBackSimple", "Off")				-- Color backdrops
				LeaPlusLC:LoadVarChk("TipHideInCombat", "Off")				-- Hide tooltips during combat
				LeaPlusLC:LoadVarChk("TipHideShiftOverride", "On")			-- Hide tooltips shift override
				LeaPlusLC:LoadVarChk("TipNoHealthBar", "Off")				-- Hide health bar
				LeaPlusLC:LoadVarNum("LeaPlusTipSize", 1.00, 0.50, 2.00)	-- Tooltip scale slider
				LeaPlusLC:LoadVarNum("TooltipAnchorMenu", 1, 1, 4)			-- Tooltip anchor menu
				LeaPlusLC:LoadVarNum("TipCursorX", 0, -128, 128)			-- Tooltip cursor X offset
				LeaPlusLC:LoadVarNum("TipCursorY", 0, -128, 128)			-- Tooltip cursor Y offset

				LeaPlusLC:LoadVarChk("EnhanceDressup", "Off")				-- Enhance dressup
				LeaPlusLC:LoadVarChk("DressupItemButtons", "On")			-- Dressup item buttons
				LeaPlusLC:LoadVarChk("DressupAnimControl", "On")			-- Dressup animation control
				LeaPlusLC:LoadVarChk("DressupMoreZoomOut", "Off")			-- Dressup increase zoom out distance
				LeaPlusLC:LoadVarChk("DressupTransmogAnim", "Off")			-- Dressup show transmogrify animation control
				LeaPlusLC:LoadVarNum("DressupFasterZoom", 3, 1, 10)			-- Dressup zoom speed
				LeaPlusLC:LoadVarChk("ShowVolume", "Off")					-- Show volume slider
				LeaPlusLC:LoadVarChk("ShowVolumeInFrame", "Off")			-- Volume slider dual layout

				LeaPlusLC:LoadVarChk("DurabilityStatus", "Off")				-- Show durability status
				LeaPlusLC:LoadVarChk("ShowPetSaveBtn", "Off")				-- Show pet save button
				LeaPlusLC:LoadVarChk("ShowRaidToggle", "Off")				-- Show raid button
				LeaPlusLC:LoadVarChk("ShowTrainAllButton", "Off")			-- Show train all button
				LeaPlusLC:LoadVarChk("ShowBorders", "Off")					-- Show borders
				LeaPlusLC:LoadVarNum("BordersTop", 0, 0, 300)				-- Top border
				LeaPlusLC:LoadVarNum("BordersBottom", 0, 0, 300)			-- Bottom border
				LeaPlusLC:LoadVarNum("BordersLeft", 0, 0, 300)				-- Left border
				LeaPlusLC:LoadVarNum("BordersRight", 0, 0, 300)				-- Right border
				LeaPlusLC:LoadVarNum("BordersAlpha", 0, 0, 0.9)				-- Border alpha
				LeaPlusLC:LoadVarChk("ShowPlayerChain", "Off")				-- Show player chain
				LeaPlusLC:LoadVarNum("PlayerChainMenu", 1, 1, 3)			-- Player chain dropdown value
				LeaPlusLC:LoadVarChk("ShowReadyTimer", "Off")				-- Show ready timer
				LeaPlusLC:LoadVarChk("ShowRangeColoring", "Off")			-- Show range coloring
				LeaPlusLC:LoadVarChk("ShowInfoCards", "Off")				-- Show info cards
				LeaPlusLC:LoadVarStr("InfoCardKey", "")						-- Info card key
				LeaPlusLC:LoadVarChk("ShowWowheadLinks", "Off")				-- Show Wowhead links
				LeaPlusLC:LoadVarChk("WowheadLinkComments", "Off")			-- Show Wowhead links to comments

				-- Frames
				LeaPlusLC:LoadVarChk("ManageWidgetTop", "Off")				-- Manage widget top
				LeaPlusLC:LoadVarAnc("WidgetTopA", "TOP")					-- Manage widget top anchor
				LeaPlusLC:LoadVarAnc("WidgetTopR", "TOP")					-- Manage widget top relative
				LeaPlusLC:LoadVarNum("WidgetTopX", 0, -5000, 5000)			-- Manage widget top position X
				LeaPlusLC:LoadVarNum("WidgetTopY", -15, -5000, 5000)		-- Manage widget top position Y
				LeaPlusLC:LoadVarNum("WidgetTopScale", 1, 0.5, 2)			-- Manage widget top scale

				LeaPlusLC:LoadVarChk("ClassColFrames", "Off")				-- Class colored frames
				LeaPlusLC:LoadVarChk("ClassColPlayer", "On")				-- Class colored player frame
				LeaPlusLC:LoadVarChk("ClassColTarget", "On")				-- Class colored target frame

				LeaPlusLC:LoadVarChk("NoAlerts", "Off")						-- Hide alerts
				LeaPlusLC:LoadVarChk("HideBodyguard", "Off")				-- Hide bodyguard window
				LeaPlusLC:LoadVarChk("HideTalkingFrame", "Off")				-- Hide talking frame
				LeaPlusLC:LoadVarChk("HideCleanupBtns", "Off")				-- Hide clean-up buttons
				LeaPlusLC:LoadVarChk("HideBossBanner", "Off")				-- Hide boss banner
				LeaPlusLC:LoadVarChk("HideEventToasts", "Off")				-- Hide event toasts
				LeaPlusLC:LoadVarChk("NoClassBar", "Off")					-- Hide stance bar
				LeaPlusLC:LoadVarChk("NoRestedSleep", "Off")				-- Hide rested sleep

				-- System
				LeaPlusLC:LoadVarChk("NoScreenGlow", "Off")					-- Disable screen glow
				LeaPlusLC:LoadVarChk("NoScreenEffects", "Off")				-- Disable screen effects
				LeaPlusLC:LoadVarChk("SetWeatherDensity", "Off")			-- Set weather density
				LeaPlusLC:LoadVarNum("WeatherLevel", 3, 0, 3)				-- Weather density level
				LeaPlusLC:LoadVarChk("MaxCameraZoom", "Off")				-- Max camera zoom

				LeaPlusLC:LoadVarChk("NoRestedEmotes", "Off")				-- Silence rested emotes
				LeaPlusLC:LoadVarChk("KeepAudioSynced", "Off")				-- Keep audio synced
				LeaPlusLC:LoadVarChk("MuteGameSounds", "Off")				-- Mute game sounds
				LeaPlusLC:LoadVarChk("MuteMountSounds", "Off")				-- Mute mount sounds
				LeaPlusLC:LoadVarChk("MuteCustomSounds", "Off")				-- Mute custom sounds
				LeaPlusLC:LoadVarStr("MuteCustomList", "")					-- Mute custom sounds list

				LeaPlusLC:LoadVarChk("NoPetAutomation", "Off")				-- Disable pet automation
				LeaPlusLC:LoadVarChk("NoRaidRestrictions", "Off")			-- Remove raid restrictions
				LeaPlusLC:LoadVarChk("NoConfirmLoot", "Off")				-- Disable loot warnings
				LeaPlusLC:LoadVarChk("FasterLooting", "Off")				-- Faster auto loot
				LeaPlusLC:LoadVarNum("LeaPlusFasterLootDelay", 0.3, 0.1, 0.3)	-- Faster auto loot delay

				LeaPlusLC:LoadVarChk("FasterMovieSkip", "Off")				-- Faster movie skip
				LeaPlusLC:LoadVarChk("CombatPlates", "Off")					-- Combat plates
				LeaPlusLC:LoadVarChk("EasyItemDestroy", "Off")				-- Easy item destroy
				LeaPlusLC:LoadVarChk("NoTransforms", "Off")					-- Remove transforms

				-- Settings
				LeaPlusLC:LoadVarNum("AddonLanguage", 1, 1, 12)				-- Addon language
				LeaPlusLC:LoadVarChk("ShowMinimapIcon", "On")				-- Show minimap button
				LeaPlusLC:LoadVarChk("SetEditModeLayout", "Off")			-- Set edit mode layout
				LeaPlusLC["EditModeLayoutName"]	= LeaPlusDB["EditModeLayoutName"] or ""			-- Edit mode layout name
				LeaPlusLC:LoadVarChk("SimpleAddonListing", "Off")			-- Simple addon listing
				LeaPlusLC:LoadVarChk("HideStarterTutorials", "Off")			-- Hide starter tutorials

				LeaPlusLC:LoadVarNum("PlusPanelScale", 1, 1, 2)				-- Panel scale
				LeaPlusLC:LoadVarNum("PlusPanelAlpha", 0, 0, 1)				-- Panel alpha

				-- Panel position
				LeaPlusLC:LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
				LeaPlusLC:LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
				LeaPlusLC:LoadVarNum("MainPanelX", 0, -5000, 5000)			-- Panel X axis
				LeaPlusLC:LoadVarNum("MainPanelY", 0, -5000, 5000)			-- Panel Y axis

				-- Start page
				LeaPlusLC:LoadVarNum("LeaStartPage", 0, 0, LeaPlusLC["NumberOfPages"])

				-- Lock conflicting options
				do

					-- Function to disable and lock an option and add a note to the tooltip
					local function Lock(option, reason, optmodule)
						LeaLockList[option] = LeaPlusLC[option]
						LeaPlusLC:LockItem(LeaPlusCB[option], true)
						LeaPlusCB[option].tiptext = LeaPlusCB[option].tiptext .. "|n|n|cff00AAFF" .. L[reason]
						if optmodule then
							LeaPlusCB[option].tiptext = LeaPlusCB[option].tiptext .. " " .. L[optmodule] .. " " .. L["module"]
						end
						LeaPlusCB[option].tiptext = LeaPlusCB[option].tiptext .. "."
						-- Remove hover from configuration button if there is one
						local temp = {LeaPlusCB[option]:GetChildren()}
						if temp and temp[1] and temp[1].t and temp[1].t:GetTexture() == 311225 then
							temp[1]:SetHighlightTexture(0)
							temp[1]:SetScript("OnEnter", nil)
						end
					end

					-- Disable items that conflict with Easy Frames
					if C_AddOns.IsAddOnLoaded("EasyFrames") then
						Lock("ClassColFrames", L["Cannot be used with Easy Frames"]) -- Class colored frames
					end

					-- Disable items that conflict with Glass
					if C_AddOns.IsAddOnLoaded("Glass") then
						local reason = L["Cannot be used with Glass"]
						Lock("UseEasyChatResizing", reason) -- Use easy resizing
						Lock("NoCombatLogTab", reason) -- Hide the combat log
						Lock("NoChatButtons", reason) -- Hide chat buttons
						Lock("NoSocialButton", reason) -- Hide social button
						Lock("UnclampChat", reason) -- Unclamp chat frame
						Lock("MoveChatEditBoxToTop", reason) -- Move editbox to top
						Lock("MoreChatFontSizes", reason) -- More chat font sizes
						Lock("NoChatFade", reason) --  Disable chat fade
						Lock("RecentChatWindow", reason) -- Recent chat window
					end

					-- Disable items that conflict with ElvUI
					if LeaPlusLC.ElvUI then
						local E = LeaPlusLC.ElvUI
						if E and E.private then

							local reason = L["Cannot be used with ElvUI"]

							-- Chat
							if E.private.chat.enable then
								Lock("UseEasyChatResizing", reason, "Chat") -- Use easy resizing
								Lock("NoCombatLogTab", reason, "Chat") -- Hide the combat log
								Lock("NoChatButtons", reason, "Chat") -- Hide chat buttons
								Lock("NoSocialButton", reason, "Chat") -- Hide social button
								Lock("UnclampChat", reason, "Chat") -- Unclamp chat frame
								Lock("MoreChatFontSizes", reason, "Chat") -- More chat font sizes
								Lock("NoStickyChat", reason, "Chat") -- Disable sticky chat
								Lock("UseArrowKeysInChat", reason, "Chat") -- Use arrow keys in chat
								Lock("NoChatFade", reason, "Chat") -- Disable chat fade
								Lock("RestoreChatMessages", reason, "Chat") -- Restore chat messages (E.db.chat.chatHistory)
							end

							-- Minimap
							if E.private.general.minimap.enable then
								Lock("MinimapModder", reason, "Minimap") -- Enhance minimap
							end

							-- UnitFrames
							if E.private.unitframe.enable then
								Lock("ShowRaidToggle", reason, "UnitFrames") -- Show raid button
							end

							-- ActionBars
							if E.private.actionbar.enable then
								Lock("NoClassBar", reason, "ActionBars") -- Hide stance bar
								Lock("HideKeybindText", reason, "ActionBars") -- Hide keybind text
								Lock("HideMacroText", reason, "ActionBars") -- Hide macro text
							end

							-- Bags
							if E.private.bags.enable then
								Lock("HideCleanupBtns", reason, "Bags") -- Hide clean-up buttons
							end

							-- Tooltip
							if E.private.tooltip.enable then
								Lock("TipModEnable", reason, "Tooltip") -- Enhance tooltip
							end

							-- UnitFrames: Disabled Blizzard: Player
							if E.private.unitframe.disabledBlizzardFrames.player then
								Lock("ShowPlayerChain", reason, "UnitFrames (Disabled Blizzard Frames Player)") -- Show player chain
								Lock("NoHitIndicators", reason, "UnitFrames (Disabled Blizzard Frames Player)") -- Hide portrait numbers
								Lock("NoRestedSleep", reason, "UnitFrames (Disabled Blizzard Frames Player)") -- Hide rested sleep
							end

							-- UnitFrames: Disabled Blizzard: Player, Target or Focus
							if E.private.unitframe.disabledBlizzardFrames.player or E.private.unitframe.disabledBlizzardFrames.target or E.private.unitframe.disabledBlizzardFrames.focus then
								Lock("ClassColFrames", reason, "UnitFrames (Disabled Blizzard Frames Player, Target and Focus)") -- Class-colored frames
							end

							-- Base
							do
								Lock("ManageWidgetTop", reason) -- Manage widget top
							end

						end

						C_AddOns.EnableAddOn("Leatrix_Plus")
					end

				end

				-- Lock options currently not compatible with the next expansion (LeaPlusLC.DF)
				local function LockDF(option, reason)
					LeaPlusLC[option] = "Off"
					LeaPlusDB[option] = "Off"
					LeaPlusLC:LockItem(LeaPlusCB[option], true)
					if reason then
						LeaPlusCB[option].tiptext = LeaPlusCB[option].tiptext .. "|n|n|cff00AAFF" .. L[reason]
					end
				end

				if LeaPlusLC.NewPatch then
					-- Disable bag automation (enter Stockade, go vendor with transmog items Lisbeth Schneider 58.2 67.0 Stormwind, auto sell, close and shift reopen)
					-- LockDF("ManageControl", "You can manage this with Edit Mode now.")
				end

				-- Run other startup items
				LeaPlusLC:SetDim()

			end
			return
		end

		if event == "PLAYER_LOGIN" then
			LeaPlusLC:Player()
			collectgarbage()
			return
		end

		-- Save locals back to globals on logout
		if event == "PLAYER_LOGOUT" then

			-- Run the logout function without wipe flag
			LeaPlusLC:PlayerLogout(false)

			-- Automation
			LeaPlusDB["AutomateQuests"]			= LeaPlusLC["AutomateQuests"]
			LeaPlusDB["AutoQuestShift"]			= LeaPlusLC["AutoQuestShift"]
			LeaPlusDB["AutoQuestRegular"]		= LeaPlusLC["AutoQuestRegular"]
			LeaPlusDB["AutoQuestDaily"]			= LeaPlusLC["AutoQuestDaily"]
			LeaPlusDB["AutoQuestWeekly"]		= LeaPlusLC["AutoQuestWeekly"]
			LeaPlusDB["AutoQuestCompleted"]		= LeaPlusLC["AutoQuestCompleted"]
			LeaPlusDB["AutoQuestKeyMenu"]		= LeaPlusLC["AutoQuestKeyMenu"]
			LeaPlusDB["AutomateGossip"]			= LeaPlusLC["AutomateGossip"]
			LeaPlusDB["AutoAcceptSummon"] 		= LeaPlusLC["AutoAcceptSummon"]
			LeaPlusDB["AutoAcceptRes"] 			= LeaPlusLC["AutoAcceptRes"]
			LeaPlusDB["AutoResNoCombat"] 		= LeaPlusLC["AutoResNoCombat"]
			LeaPlusDB["AutoResNoAfterlife"] 	= LeaPlusLC["AutoResNoAfterlife"]
			LeaPlusDB["AutoReleasePvP"] 		= LeaPlusLC["AutoReleasePvP"]
			LeaPlusDB["AutoReleaseNoAlterac"] 	= LeaPlusLC["AutoReleaseNoAlterac"]
			LeaPlusDB["AutoReleaseNoWintergsp"] = LeaPlusLC["AutoReleaseNoWintergsp"]
			LeaPlusDB["AutoReleaseNoTolBarad"] 	= LeaPlusLC["AutoReleaseNoTolBarad"]
			LeaPlusDB["AutoReleaseNoAshran"] 	= LeaPlusLC["AutoReleaseNoAshran"]
			LeaPlusDB["AutoReleaseDelay"] 		= LeaPlusLC["AutoReleaseDelay"]

			LeaPlusDB["AutoSellJunk"] 			= LeaPlusLC["AutoSellJunk"]
			LeaPlusDB["AutoSellShowSummary"] 	= LeaPlusLC["AutoSellShowSummary"]
			LeaPlusDB["AutoSellNoKeeperTahult"] = LeaPlusLC["AutoSellNoKeeperTahult"]
			LeaPlusDB["AutoSellNoGreyGear"] 	= LeaPlusLC["AutoSellNoGreyGear"]
			LeaPlusDB["AutoSellExcludeList"] 	= LeaPlusLC["AutoSellExcludeList"]
			LeaPlusDB["AutoRepairGear"] 		= LeaPlusLC["AutoRepairGear"]
			LeaPlusDB["AutoRepairGuildFunds"] 	= LeaPlusLC["AutoRepairGuildFunds"]
			LeaPlusDB["AutoRepairShowSummary"] 	= LeaPlusLC["AutoRepairShowSummary"]

			-- Social
			LeaPlusDB["NoDuelRequests"] 		= LeaPlusLC["NoDuelRequests"]
			LeaPlusDB["NoPetDuels"] 			= LeaPlusLC["NoPetDuels"]
			LeaPlusDB["NoPartyInvites"]			= LeaPlusLC["NoPartyInvites"]
			LeaPlusDB["NoRequestedInvites"]		= LeaPlusLC["NoRequestedInvites"]
			LeaPlusDB["NoFriendRequests"]		= LeaPlusLC["NoFriendRequests"]
			LeaPlusDB["NoSharedQuests"]			= LeaPlusLC["NoSharedQuests"]

			LeaPlusDB["AcceptPartyFriends"]		= LeaPlusLC["AcceptPartyFriends"]
			LeaPlusDB["SyncFromFriends"]		= LeaPlusLC["SyncFromFriends"]
			LeaPlusDB["AutoConfirmRole"]		= LeaPlusLC["AutoConfirmRole"]
			LeaPlusDB["InviteFromWhisper"]		= LeaPlusLC["InviteFromWhisper"]
			LeaPlusDB["InviteFriendsOnly"]		= LeaPlusLC["InviteFriendsOnly"]
			LeaPlusDB["InvKey"]					= LeaPlusLC["InvKey"]
			LeaPlusDB["FriendlyCommunities"]	= LeaPlusLC["FriendlyCommunities"]
			LeaPlusDB["FriendlyGuild"]			= LeaPlusLC["FriendlyGuild"]

			-- Chat
			LeaPlusDB["UseEasyChatResizing"]	= LeaPlusLC["UseEasyChatResizing"]
			LeaPlusDB["NoCombatLogTab"]			= LeaPlusLC["NoCombatLogTab"]
			LeaPlusDB["NoChatButtons"]			= LeaPlusLC["NoChatButtons"]
			LeaPlusDB["ShowVoiceButtons"]		= LeaPlusLC["ShowVoiceButtons"]
			LeaPlusDB["ShowChatMenuButton"]		= LeaPlusLC["ShowChatMenuButton"]
			LeaPlusDB["NoSocialButton"]			= LeaPlusLC["NoSocialButton"]
			LeaPlusDB["UnclampChat"]			= LeaPlusLC["UnclampChat"]
			LeaPlusDB["MoveChatEditBoxToTop"]	= LeaPlusLC["MoveChatEditBoxToTop"]
			LeaPlusDB["MoreChatFontSizes"]		= LeaPlusLC["MoreChatFontSizes"]

			LeaPlusDB["NoStickyChat"] 			= LeaPlusLC["NoStickyChat"]
			LeaPlusDB["UseArrowKeysInChat"]		= LeaPlusLC["UseArrowKeysInChat"]
			LeaPlusDB["NoChatFade"]				= LeaPlusLC["NoChatFade"]
			LeaPlusDB["UnivGroupColor"]			= LeaPlusLC["UnivGroupColor"]
			LeaPlusDB["RecentChatWindow"]		= LeaPlusLC["RecentChatWindow"]
			LeaPlusDB["RecentChatSize"]			= LeaPlusLC["RecentChatSize"]
			LeaPlusDB["FilterChatMessages"]		= LeaPlusLC["FilterChatMessages"]
			LeaPlusDB["BlockSpellLinks"]		= LeaPlusLC["BlockSpellLinks"]
			LeaPlusDB["BlockDrunkenSpam"]		= LeaPlusLC["BlockDrunkenSpam"]
			LeaPlusDB["BlockDuelSpam"]			= LeaPlusLC["BlockDuelSpam"]
			LeaPlusDB["BlockAngelisSinny"]		= LeaPlusLC["BlockAngelisSinny"]
			LeaPlusDB["RestoreChatMessages"]	= LeaPlusLC["RestoreChatMessages"]

			-- Text
			LeaPlusDB["HideErrorMessages"]		= LeaPlusLC["HideErrorMessages"]
			LeaPlusDB["NoHitIndicators"]		= LeaPlusLC["NoHitIndicators"]
			LeaPlusDB["HideZoneText"] 			= LeaPlusLC["HideZoneText"]
			LeaPlusDB["HideKeybindText"] 		= LeaPlusLC["HideKeybindText"]
			LeaPlusDB["HideMacroText"] 			= LeaPlusLC["HideMacroText"]

			LeaPlusDB["QuestFontChange"] 		= LeaPlusLC["QuestFontChange"]
			LeaPlusDB["LeaPlusQuestFontSize"]	= LeaPlusLC["LeaPlusQuestFontSize"]

			-- Interface
			LeaPlusDB["MinimapModder"]			= LeaPlusLC["MinimapModder"]
			LeaPlusDB["SquareMinimap"]			= LeaPlusLC["SquareMinimap"]
			LeaPlusDB["HideMiniAddonMenu"]		= LeaPlusLC["HideMiniAddonMenu"]
			LeaPlusDB["UnclampMinimap"]			= LeaPlusLC["UnclampMinimap"]
			LeaPlusDB["MinimapButtonBag"]		= LeaPlusLC["MinimapButtonBag"]
			LeaPlusDB["MiniExcludeList"] 		= LeaPlusLC["MiniExcludeList"]
			LeaPlusDB["HideMiniAddonButtons"]	= LeaPlusLC["HideMiniAddonButtons"]
			LeaPlusDB["MinimapBorderWidth"]		= LeaPlusLC["MinimapBorderWidth"]
			LeaPlusDB["MiniClusterScale"]		= LeaPlusLC["MiniClusterScale"]
			LeaPlusDB["MinimapEffect"]			= LeaPlusLC["MinimapEffect"]

			LeaPlusDB["TipModEnable"]			= LeaPlusLC["TipModEnable"]
			LeaPlusDB["TipShowRank"]			= LeaPlusLC["TipShowRank"]
			LeaPlusDB["TipShowOtherRank"]		= LeaPlusLC["TipShowOtherRank"]
			LeaPlusDB["TipShowTarget"]			= LeaPlusLC["TipShowTarget"]
			LeaPlusDB["TipBackSimple"]			= LeaPlusLC["TipBackSimple"]
			LeaPlusDB["TipHideInCombat"]		= LeaPlusLC["TipHideInCombat"]
			LeaPlusDB["TipHideShiftOverride"]	= LeaPlusLC["TipHideShiftOverride"]
			LeaPlusDB["TipNoHealthBar"]			= LeaPlusLC["TipNoHealthBar"]
			LeaPlusDB["LeaPlusTipSize"]			= LeaPlusLC["LeaPlusTipSize"]
			LeaPlusDB["TooltipAnchorMenu"]		= LeaPlusLC["TooltipAnchorMenu"]
			LeaPlusDB["TipCursorX"]				= LeaPlusLC["TipCursorX"]
			LeaPlusDB["TipCursorY"]				= LeaPlusLC["TipCursorY"]

			LeaPlusDB["EnhanceDressup"]			= LeaPlusLC["EnhanceDressup"]
			LeaPlusDB["DressupItemButtons"]		= LeaPlusLC["DressupItemButtons"]
			LeaPlusDB["DressupAnimControl"]		= LeaPlusLC["DressupAnimControl"]
			LeaPlusDB["DressupMoreZoomOut"]		= LeaPlusLC["DressupMoreZoomOut"]
			LeaPlusDB["DressupTransmogAnim"]	= LeaPlusLC["DressupTransmogAnim"]
			LeaPlusDB["DressupFasterZoom"]		= LeaPlusLC["DressupFasterZoom"]
			LeaPlusDB["ShowVolume"] 			= LeaPlusLC["ShowVolume"]
			LeaPlusDB["ShowVolumeInFrame"] 		= LeaPlusLC["ShowVolumeInFrame"]

			LeaPlusDB["DurabilityStatus"]		= LeaPlusLC["DurabilityStatus"]
			LeaPlusDB["ShowPetSaveBtn"]			= LeaPlusLC["ShowPetSaveBtn"]
			LeaPlusDB["ShowRaidToggle"]			= LeaPlusLC["ShowRaidToggle"]
			LeaPlusDB["ShowTrainAllButton"]		= LeaPlusLC["ShowTrainAllButton"]
			LeaPlusDB["ShowBorders"]			= LeaPlusLC["ShowBorders"]
			LeaPlusDB["BordersTop"]				= LeaPlusLC["BordersTop"]
			LeaPlusDB["BordersBottom"]			= LeaPlusLC["BordersBottom"]
			LeaPlusDB["BordersLeft"]			= LeaPlusLC["BordersLeft"]
			LeaPlusDB["BordersRight"]			= LeaPlusLC["BordersRight"]
			LeaPlusDB["BordersAlpha"]			= LeaPlusLC["BordersAlpha"]
			LeaPlusDB["ShowPlayerChain"]		= LeaPlusLC["ShowPlayerChain"]
			LeaPlusDB["PlayerChainMenu"]		= LeaPlusLC["PlayerChainMenu"]
			LeaPlusDB["ShowReadyTimer"]			= LeaPlusLC["ShowReadyTimer"]
			LeaPlusDB["ShowRangeColoring"]		= LeaPlusLC["ShowRangeColoring"]
			LeaPlusDB["ShowInfoCards"]			= LeaPlusLC["ShowInfoCards"]
			LeaPlusDB["InfoCardKey"]			= LeaPlusLC["InfoCardKey"]
			LeaPlusDB["ShowWowheadLinks"]		= LeaPlusLC["ShowWowheadLinks"]
			LeaPlusDB["WowheadLinkComments"]	= LeaPlusLC["WowheadLinkComments"]

			-- Frames
			LeaPlusDB["ManageWidgetTop"]		= LeaPlusLC["ManageWidgetTop"]
			LeaPlusDB["WidgetTopA"]				= LeaPlusLC["WidgetTopA"]
			LeaPlusDB["WidgetTopR"]				= LeaPlusLC["WidgetTopR"]
			LeaPlusDB["WidgetTopX"]				= LeaPlusLC["WidgetTopX"]
			LeaPlusDB["WidgetTopY"]				= LeaPlusLC["WidgetTopY"]
			LeaPlusDB["WidgetTopScale"]			= LeaPlusLC["WidgetTopScale"]

			LeaPlusDB["ClassColFrames"]			= LeaPlusLC["ClassColFrames"]
			LeaPlusDB["ClassColPlayer"]			= LeaPlusLC["ClassColPlayer"]
			LeaPlusDB["ClassColTarget"]			= LeaPlusLC["ClassColTarget"]

			LeaPlusDB["NoAlerts"]				= LeaPlusLC["NoAlerts"]
			LeaPlusDB["HideBodyguard"]			= LeaPlusLC["HideBodyguard"]
			LeaPlusDB["HideTalkingFrame"]		= LeaPlusLC["HideTalkingFrame"]
			LeaPlusDB["HideCleanupBtns"]		= LeaPlusLC["HideCleanupBtns"]
			LeaPlusDB["HideBossBanner"]			= LeaPlusLC["HideBossBanner"]
			LeaPlusDB["HideEventToasts"]		= LeaPlusLC["HideEventToasts"]
			LeaPlusDB["NoClassBar"]				= LeaPlusLC["NoClassBar"]
			LeaPlusDB["NoRestedSleep"]			= LeaPlusLC["NoRestedSleep"]

			-- System
			LeaPlusDB["NoScreenGlow"] 			= LeaPlusLC["NoScreenGlow"]
			LeaPlusDB["NoScreenEffects"] 		= LeaPlusLC["NoScreenEffects"]
			LeaPlusDB["SetWeatherDensity"] 		= LeaPlusLC["SetWeatherDensity"]
			LeaPlusDB["WeatherLevel"] 			= LeaPlusLC["WeatherLevel"]
			LeaPlusDB["MaxCameraZoom"] 			= LeaPlusLC["MaxCameraZoom"]

			LeaPlusDB["NoRestedEmotes"]			= LeaPlusLC["NoRestedEmotes"]
			LeaPlusDB["KeepAudioSynced"]		= LeaPlusLC["KeepAudioSynced"]
			LeaPlusDB["MuteGameSounds"]			= LeaPlusLC["MuteGameSounds"]
			LeaPlusDB["MuteMountSounds"]		= LeaPlusLC["MuteMountSounds"]
			LeaPlusDB["MuteCustomSounds"]		= LeaPlusLC["MuteCustomSounds"]
			LeaPlusDB["MuteCustomList"]			= LeaPlusLC["MuteCustomList"]

			LeaPlusDB["NoPetAutomation"]		= LeaPlusLC["NoPetAutomation"]
			LeaPlusDB["NoRaidRestrictions"]		= LeaPlusLC["NoRaidRestrictions"]
			LeaPlusDB["NoConfirmLoot"] 			= LeaPlusLC["NoConfirmLoot"]
			LeaPlusDB["FasterLooting"] 			= LeaPlusLC["FasterLooting"]
			LeaPlusDB["LeaPlusFasterLootDelay"] = LeaPlusLC["LeaPlusFasterLootDelay"]

			LeaPlusDB["FasterMovieSkip"] 		= LeaPlusLC["FasterMovieSkip"]
			LeaPlusDB["CombatPlates"]			= LeaPlusLC["CombatPlates"]
			LeaPlusDB["EasyItemDestroy"]		= LeaPlusLC["EasyItemDestroy"]
			LeaPlusDB["NoTransforms"] 			= LeaPlusLC["NoTransforms"]

			-- Settings
			LeaPlusDB["AddonLanguage"] 			= LeaPlusLC["AddonLanguage"]
			LeaPlusDB["ShowMinimapIcon"] 		= LeaPlusLC["ShowMinimapIcon"]
			LeaPlusDB["SetEditModeLayout"] 		= LeaPlusLC["SetEditModeLayout"]
			LeaPlusDB["EditModeLayoutName"] 	= LeaPlusLC["EditModeLayoutName"]
			LeaPlusDB["SimpleAddonListing"] 	= LeaPlusLC["SimpleAddonListing"]
			LeaPlusDB["HideStarterTutorials"] 	= LeaPlusLC["HideStarterTutorials"]

			LeaPlusDB["PlusPanelScale"] 		= LeaPlusLC["PlusPanelScale"]
			LeaPlusDB["PlusPanelAlpha"] 		= LeaPlusLC["PlusPanelAlpha"]

			-- Panel position
			LeaPlusDB["MainPanelA"]				= LeaPlusLC["MainPanelA"]
			LeaPlusDB["MainPanelR"]				= LeaPlusLC["MainPanelR"]
			LeaPlusDB["MainPanelX"]				= LeaPlusLC["MainPanelX"]
			LeaPlusDB["MainPanelY"]				= LeaPlusLC["MainPanelY"]

			-- Start page
			LeaPlusDB["LeaStartPage"]			= LeaPlusLC["LeaStartPage"]

			-- Mute game sounds (LeaPlusLC["MuteGameSounds"])
			for k, v in pairs(LeaPlusLC["muteTable"]) do
				LeaPlusDB[k] = LeaPlusLC[k]
			end

			-- Mute mount sounds (LeaPlusLC["MuteMountSounds"])
			for k, v in pairs(LeaPlusLC["mountTable"]) do
				LeaPlusDB[k] = LeaPlusLC[k]
			end

			-- Remove transforms (LeaPlusLC["NoTransforms"])
			for k, v in pairs(LeaPlusLC["transTable"]) do
				LeaPlusDB[k] = LeaPlusLC[k]
			end

		end

	end

--	Register event handler
	LpEvt:SetScript("OnEvent", eventHandler)

----------------------------------------------------------------------
--	L70: Player logout
----------------------------------------------------------------------

	-- Player Logout
	function LeaPlusLC:PlayerLogout(wipe)

		----------------------------------------------------------------------
		-- Restore default values for options that do not require reloads
		----------------------------------------------------------------------

		-- Disable screen glow (LeaPlusLC["NoScreenGlow"])
		if wipe then

			-- Disable screen glow (LeaPlusLC["NoScreenGlow"])
			SetCVar("ffxGlow", "1")

			-- Disable screen effects (LeaPlusLC["NoScreenEffects"])
			SetCVar("ffxDeath", "1")
			SetCVar("ffxNether", "1")
			SetCVar("ffxVenari", "1")
			SetCVar("ffxLingeringVenari", "1")

			-- Set weather density (LeaPlusLC["SetWeatherDensity"])
			SetCVar("WeatherDensity", "3")
			SetCVar("RAIDweatherDensity", "3")

			-- Remove raid restrictions (LeaPlusLC["NoRaidRestrictions"])
			SetAllowLowLevelRaid(false)

			-- Max camera zoom (LeaPlusLC["MaxCameraZoom"])
			SetCVar("cameraDistanceMaxZoomFactor", 1.9)

			-- Universal group color (LeaPlusLC["UnivGroupColor"])
			ChangeChatColor("RAID", 1, 0.50, 0)
			ChangeChatColor("RAID_LEADER", 1, 0.28, 0.04)
			ChangeChatColor("INSTANCE_CHAT", 1, 0.50, 0)
			ChangeChatColor("INSTANCE_CHAT_LEADER", 1, 0.28, 0.04)

			-- Mute game sounds (LeaPlusLC["MuteGameSounds"])
			for k, v in pairs(LeaPlusLC["muteTable"]) do
				for i, e in pairs(v) do
					local file, soundID = e:match("([^,]+)%#([^,]+)")
					UnmuteSoundFile(soundID)
				end
			end

			-- Mute mount sounds (LeaPlusLC["MuteMountSounds"])
			for k, v in pairs(LeaPlusLC["mountTable"]) do
				for i, e in pairs(v) do
					local file, soundID = e:match("([^,]+)%#([^,]+)")
					UnmuteSoundFile(soundID)
				end
			end

		end

		----------------------------------------------------------------------
		-- Restore default values for options that require reloads
		----------------------------------------------------------------------

		-- Silence rested emotes
		if LeaPlusDB["NoRestedEmotes"] == "On" then
			if wipe or (not wipe and LeaPlusLC["NoRestedEmotes"] == "Off") then
				SetCVar("Sound_EnableEmoteSounds", "1")
			end
		end

	end

----------------------------------------------------------------------
-- 	Options panel functions
----------------------------------------------------------------------

	-- Function to add textures to panels
	function LeaPlusLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
		local ft = parent:CreateTexture(nil, "BORDER")
		ft:SetTexture(tex)
		ft:SetSize(width, height)
		ft:SetPoint(anchor)
		ft:SetVertexColor(r ,g, b, alp)
		if name == "MainTexture" then
			ft:SetTexCoord(0.09, 1, 0, 1);
		end
	end

	-- Create a configuration panel
	function LeaPlusLC:CreatePanel(title, globref, scrolling)

		-- Create the panel
		local Side = CreateFrame("Frame", LeaPlusLC:CreateRandomName(), UIParent)

		-- Make it a system frame
		table.insert(UISpecialFrames, Side:GetName())

		-- Store it in the configuration panel table
		tinsert(LeaConfigList, Side)

		-- Set frame parameters
		Side:Hide();
		Side:SetSize(570, LeaPlusLC.MainPanelHeight)
		Side:SetClampedToScreen(true)
		Side:SetClampRectInsets(500, -500, -300, 300)
		Side:SetFrameStrata("FULLSCREEN_DIALOG")

		-- Set the background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add a close Button
		Side.c = LeaPlusLC:CreateCloseButton(Side, 30, 30, "TOPRIGHT", 0, 0)
		Side.c:SetScript("OnClick", function() Side:Hide() end)

		-- Add reset, help and back buttons
		Side.r = LeaPlusLC:CreateButton("ResetButton", Side, "Reset", "BOTTOMLEFT", 16, 53, 0, 25, true, "Click to reset the settings on this page.")
		Side.h = LeaPlusLC:CreateButton("HelpButton", Side, "Help", "BOTTOMLEFT", 76, 53, 0, 25, true, "No help is available for this page.")
		Side.b = LeaPlusLC:CreateButton("BackButton", Side, "Back to Main Menu", "BOTTOMRIGHT", -16, 53, 0, 25, true, "Click to return to the main menu.")

		-- Reposition help button so it doesn't overlap reset button
		Side.h:ClearAllPoints()
		Side.h:SetPoint("LEFT", Side.r, "RIGHT", 10, 0)

		-- Remove the click texture from the help button
		Side.h:SetPushedTextOffset(0, 0)

		-- Add a reload button and syncronise it with the main panel reload button
		local reloadb = LeaPlusLC:CreateButton("ConfigReload", Side, "Reload", "BOTTOMRIGHT", -16, 10, 0, 25, true, LeaPlusCB["ReloadUIButton"].tiptext)
		LeaPlusLC:LockItem(reloadb,true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32);
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(LeaPlusCB["ReloadUIButton"].f:GetText())
		reloadb.f:Hide()

		LeaPlusCB["ReloadUIButton"]:HookScript("OnEnable", function()
			LeaPlusLC:LockItem(reloadb, false)
			reloadb.f:Show()
		end)

		LeaPlusCB["ReloadUIButton"]:HookScript("OnDisable", function()
			LeaPlusLC:LockItem(reloadb, true)
			reloadb.f:Hide()
		end)

		-- Set textures
		LeaPlusLC:CreateBar("FootTexture", Side, 570, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaPlusLC:CreateBar("MainTexture", Side, 570, LeaPlusLC.MainPanelHeight - 47, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Allow movement
		Side:EnableMouse(true)
		Side:SetMovable(true)
		Side:RegisterForDrag("LeftButton")
		Side:SetScript("OnDragStart", Side.StartMoving)
		Side:SetScript("OnDragStop", function ()
			Side:StopMovingOrSizing();
			Side:SetUserPlaced(false);
			-- Save panel position
			LeaPlusLC["MainPanelA"], void, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = Side:GetPoint()
		end)

		-- Set panel attributes when shown
		Side:SetScript("OnShow", function()
			Side:ClearAllPoints()
			Side:SetPoint(LeaPlusLC["MainPanelA"], UIParent, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"])
			Side:SetScale(LeaPlusLC["PlusPanelScale"])
			Side.t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
		end)

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 16, -16);
		Side.f:SetText(L[title])

		-- Add description
		Side.v = Side:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Side.v:SetHeight(32);
		Side.v:SetPoint('TOPLEFT', Side.f, 'BOTTOMLEFT', 0, -8);
		Side.v:SetPoint('RIGHT', Side, -32, 0)
		Side.v:SetJustifyH('LEFT'); Side.v:SetJustifyV('TOP');
		Side.v:SetText(L["Configuration Panel"])

		-- Prevent options panel from showing while side panel is showing
		LeaPlusLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaPlusLC["PageF"]:Hide(); end
		end)

		-- Create scroll frame if needed
		if scrolling then

			-- Create backdrop
			Side.backFrame = CreateFrame("FRAME", nil, Side, "BackdropTemplate")
			Side.backFrame:SetSize(Side:GetSize())
			Side.backFrame:SetPoint("TOPLEFT", 16, -68)
			Side.backFrame:SetPoint("BOTTOMRIGHT", -16, 98)
			Side.backFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
			Side.backFrame:SetBackdropColor(0, 0, 1, 0.5)

			-- Create scroll frame
			Side.scrollFrame = CreateFrame("ScrollFrame", nil, Side.backFrame, "LeaPlusConfigurationPanelScrollFrameTemplate")
			Side.scrollChild = CreateFrame("Frame", nil, Side.scrollFrame)

			Side.scrollChild:SetSize(1, 1)
			Side.scrollFrame:SetScrollChild(Side.scrollChild)
			Side.scrollFrame:SetPoint("TOPLEFT", -8, -6)
			Side.scrollFrame:SetPoint("BOTTOMRIGHT", -29, 6)
			Side.scrollFrame:SetPanExtent(20)

			-- Set scroll list to top when shown
			Side.scrollFrame:HookScript("OnShow", function()
				Side.scrollFrame:SetVerticalScroll(0)
			end)

			-- Add scroll for more message
			local footMessage = LeaPlusLC:MakeTx(Side, "(scroll the list for more)", 16, 0)
			footMessage:ClearAllPoints()
			footMessage:SetPoint("TOPRIGHT", Side.scrollFrame, "TOPRIGHT", 28, 24)

			-- Give child a file level scope (it's used in LeaPlusLC.TipSee)
			LeaPlusLC[globref .. "ScrollChild"] = Side.scrollChild

		end

		-- Return the frame
		return Side

	end

	-- Define subheadings
	function LeaPlusLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		return text
	end

	-- Define text
	function LeaPlusLC:MakeWD(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		text:SetJustifyH"LEFT";
		return text
	end

	-- Create a slider control (uses standard template)
	function LeaPlusLC:MakeSL(frame, field, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", nil, frame, "LeaPlusConfigurationPanelSliderTemplate") -- Old is UISliderTemplate
		LeaPlusCB[field] = Slider
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0)
		Slider.tiptext = L[caption]
		Slider:SetScript("OnEnter", LeaPlusLC.TipSee)
		Slider:SetScript("OnLeave", GameTooltip_Hide)

		-- Create slider label
		Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
		Slider.f:SetFontObject('GameFontHighlight')
		Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
		Slider.f:SetFormattedText("%.2f", Slider:GetValue())

		-- Process mousewheel scrolling
		Slider:SetScript("OnMouseWheel", function(self, arg1)
			if Slider:IsEnabled() then
				local step = step * arg1
				local value = self:GetValue()
				if step > 0 then
					self:SetValue(min(value + step, high))
				else
					self:SetValue(max(value + step, low))
				end
			end
		end)

		-- Process value changed
		Slider:SetScript("OnValueChanged", function(self, value)
			local value = floor((value - low) / step + 0.5) * step + low
			Slider.f:SetFormattedText(form, value)
			LeaPlusLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaPlusLC[field])
		end)

	end

	-- Create a checkbox control (uses standard template)
	function LeaPlusLC:MakeCB(parent, field, caption, x, y, reload, tip, tipstyle)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaPlusCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)
		Cbox:SetScript("OnEnter", LeaPlusLC.TipSee)
		Cbox:SetScript("OnLeave", GameTooltip_Hide)

		-- Add label and tooltip
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 20, 0)
		if reload then
			-- Checkbox requires UI reload
			Cbox.f:SetText(L[caption] .. "*")
			Cbox.tiptext = L[tip] .. "|n|n* " .. L["Requires UI reload."]
		else
			-- Checkbox does not require UI reload
			Cbox.f:SetText(L[caption])
			Cbox.tiptext = L[tip]
		end

		-- Set label parameters
		Cbox.f:SetJustifyH("LEFT")
		Cbox.f:SetWordWrap(false)

		-- Set maximum label width
		if parent:GetParent() == LeaPlusLC["PageF"] then
			-- Main panel checkbox labels
			if Cbox.f:GetWidth() > 152 then
				Cbox.f:SetWidth(152)
				LeaPlusLC["TruncatedLabelsList"] = LeaPlusLC["TruncatedLabelsList"] or {}
				LeaPlusLC["TruncatedLabelsList"][Cbox.f] = L[caption]
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 152 then
				Cbox:SetHitRectInsets(0, -142, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		else
			-- Configuration panel checkbox labels (other checkboxes either have custom functions or blank labels)
			if Cbox.f:GetWidth() > 302 then
				Cbox.f:SetWidth(302)
				LeaPlusLC["TruncatedLabelsList"] = LeaPlusLC["TruncatedLabelsList"] or {}
				LeaPlusLC["TruncatedLabelsList"][Cbox.f] = L[caption]
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 302 then
				Cbox:SetHitRectInsets(0, -292, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		end

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			if LeaPlusLC[field] == "On" then
				self:SetChecked(true)
			else
				self:SetChecked(false)
			end
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() then
				LeaPlusLC[field] = "On"
			else
				LeaPlusLC[field] = "Off"
			end
			LeaPlusLC:SetDim(); -- Lock invalid options
			LeaPlusLC:ReloadCheck(); -- Show reload button if needed
		end)
	end

	-- Create an editbox (uses standard template)
	function LeaPlusLC:CreateEditBox(frame, parent, width, maxchars, anchor, x, y, tab, shifttab)

		-- Create editbox
        local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
		LeaPlusCB[frame] = eb
		eb:SetPoint(anchor, x, y)
		eb:SetWidth(width)
		eb:SetHeight(24)
		eb:SetFontObject("GameFontNormal")
		eb:SetTextColor(1.0, 1.0, 1.0)
		eb:SetAutoFocus(false)
		eb:SetMaxLetters(maxchars)
		eb:SetScript("OnEscapePressed", eb.ClearFocus)
		eb:SetScript("OnEnterPressed", eb.ClearFocus)

		-- Add editbox border and backdrop
		eb.f = CreateFrame("FRAME", nil, eb, "BackdropTemplate")
		eb.f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 16, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }})
		eb.f:SetPoint("LEFT", -6, 0)
		eb.f:SetWidth(eb:GetWidth()+6)
		eb.f:SetHeight(eb:GetHeight())
		eb.f:SetBackdropColor(1.0, 1.0, 1.0, 0.3)

		-- Move onto next editbox when tab key is pressed
		eb:SetScript("OnTabPressed", function(self)
			self:ClearFocus()
			if IsShiftKeyDown() then
				LeaPlusCB[shifttab]:SetFocus()
			else
				LeaPlusCB[tab]:SetFocus()
			end
		end)

		return eb

	end

	-- Create a standard button (using standard button template)
	function LeaPlusLC:CreateButton(name, frame, label, anchor, x, y, width, height, reskin, tip, naked)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaPlusCB[name] = mbtn
		mbtn:SetSize(width, height)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetHitRectInsets(0, 0, 0, 0)
		mbtn:SetText(L[label])

		-- Create fontstring so the button can be sized correctly
		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetText(L[label])
		if width > 0 then
			-- Button should have static width
			mbtn:SetWidth(width)
		else
			-- Button should have variable width
			mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)
		end

		-- Tooltip handler
		mbtn.tiptext = L[tip]
		mbtn:SetScript("OnEnter", LeaPlusLC.TipSee)
		mbtn:SetScript("OnLeave", GameTooltip_Hide)

		-- Texture the button
		if reskin then

			-- Set skinned button textures
			if not naked then
				mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus.blp")
				mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
			end
			mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus.blp")
			mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

			-- Hide the default textures
			mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
			mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		end

		return mbtn
	end

	-- Create a dropdown menu (using standard dropdown template)
	function LeaPlusLC:CreateDropdown(frame, label, width, anchor, parent, relative, x, y, reload, items)

		local RadioDropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		LeaPlusCB[frame] = RadioDropdown
		RadioDropdown:SetPoint(anchor, parent, relative, x, y)

		local function IsSelected(value)
			return value == LeaPlusLC[frame]
		end

		local function SetSelected(value)
			LeaPlusLC[frame] = value
		end

		MenuUtil.CreateRadioMenu(RadioDropdown, IsSelected, SetSelected, unpack(items))

		local lf = RadioDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal"); lf:SetPoint("TOPLEFT", RadioDropdown, 0, 20); lf:SetPoint("TOPRIGHT", RadioDropdown, -5, 20); lf:SetJustifyH("LEFT"); lf:SetText(L[label])

		-- Cycle through the options with the mousewheel while the menu is closed (scroll down for the next option, up for the previous one)
		RadioDropdown:EnableMouseWheel(true)

		-- Apply the new option in the same way as choosing it from the menu (runs anything hooked to the menu closing)
		RadioDropdown:HookScript("OnMouseWheel", function(self)
			self:TriggerEvent(DropdownButtonMixin.Event.OnMenuClose, self)
		end)

		-- Cycle through the options with the mousewheel while the menu is open (an invisible layer over the menu takes the mousewheel but lets clicks through)
		local wheel
		RadioDropdown:RegisterCallback("OnMenuOpen", function()
			local menu = RadioDropdown.menu
			if not menu then return end
			if not wheel then
				wheel = CreateFrame("Frame", nil, UIParent)
				wheel:EnableMouse(false)
				wheel:EnableMouseWheel(true)
				wheel:SetScript("OnMouseWheel", function(self, delta)
					-- Find the current option and step to the next or previous one (stops at either end)
					local index = 1
					for i = 1, #items do
						if items[i][2] == LeaPlusLC[frame] then index = i; break end
					end
					index = index + (delta < 0 and 1 or -1)
					if index < 1 or index > #items then return end
					LeaPlusLC[frame] = items[index][2]
					-- Move the tick in the open menu, update the dropdown text and apply the option
					if RadioDropdown.menu then RadioDropdown.menu:ReinitializeAll() end
					RadioDropdown:SignalUpdate()
					RadioDropdown:TriggerEvent(DropdownButtonMixin.Event.OnMenuClose, RadioDropdown)
				end)
			end
			wheel:SetAllPoints(menu)
			wheel:SetFrameStrata(menu:GetFrameStrata())
			wheel:SetFrameLevel(menu:GetFrameLevel() + 50)
			wheel:Show()
		end)

		-- Hide the layer when the menu really closes (the mousewheel also signals the menu closing so options apply, but without a menu)
		RadioDropdown:RegisterCallback("OnMenuClose", function(owner, dropdown, menu)
			if menu and wheel then wheel:Hide() end
			if reload then
				LeaPlusLC:ReloadCheck()
			end
		end)

	end

----------------------------------------------------------------------
-- 	Create main options panel frame
----------------------------------------------------------------------

	function LeaPlusLC:CreateMainPanel()

		-- Create the panel
		local PageF = CreateFrame("Frame", LeaPlusLC:CreateRandomName(), UIParent);

		-- Make it a system frame
		table.insert(UISpecialFrames, PageF:GetName())

		-- Set frame parameters
		LeaPlusLC["PageF"] = PageF
		PageF:SetSize(570, LeaPlusLC.MainPanelHeight)
		PageF:Hide();
		PageF:SetFrameStrata("FULLSCREEN_DIALOG")
		PageF:SetClampedToScreen(true)
		PageF:SetClampRectInsets(500, -500, -300, 300)
		PageF:EnableMouse(true)
		PageF:SetMovable(true)
		PageF:RegisterForDrag("LeftButton")
		PageF:SetScript("OnDragStart", PageF.StartMoving)
		PageF:SetScript("OnDragStop", function ()
			PageF:StopMovingOrSizing();
			PageF:SetUserPlaced(false);
			-- Save panel position
			LeaPlusLC["MainPanelA"], void, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = PageF:GetPoint()
		end)

		-- Add background color
		PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
		PageF.t:SetAllPoints()
		PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add textures
		LeaPlusLC:CreateBar("FootTexture", PageF, 570, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaPlusLC:CreateBar("MainTexture", PageF, 440, LeaPlusLC.MainPanelHeight - 47, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaPlusLC:CreateBar("MenuTexture", PageF, 130, LeaPlusLC.MainPanelHeight - 47, "TOPLEFT", 0.7, 0.7, 0.7, 0.7, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Set panel position when shown
		PageF:SetScript("OnShow", function()
			PageF:ClearAllPoints()
			PageF:SetPoint(LeaPlusLC["MainPanelA"], UIParent, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"])
		end)

		-- Add main title (shown above menu in the corner)
		PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		PageF.mt:SetPoint('TOPLEFT', 16, -16)
		PageF.mt:SetText("Leatrix Plus")

		-- Add version text (shown underneath main title)
		PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		PageF.v:SetHeight(32);
		PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8);
		PageF.v:SetPoint('RIGHT', PageF, -32, 0)
		PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP');
		PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Version"] .. " " .. LeaPlusLC["AddonVer"])

		-- Add reload UI Button
		local reloadb = LeaPlusLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMRIGHT", -16, 10, 0, 25, true, "Your UI needs to be reloaded for some of the changes to take effect.|n|nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect.")
		LeaPlusLC:LockItem(reloadb,true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32);
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(L["Your UI needs to be reloaded."])
		reloadb.f:Hide()

		-- Add close Button (LeaPlusLC.DF: Using custom template)
		local CloseB = LeaPlusLC:CreateCloseButton(PageF, 30, 30, "TOPRIGHT", 0, 0)
		CloseB:SetScript("OnClick", LeaPlusLC.HideFrames)

		-- Release memory
		LeaPlusLC.CreateMainPanel = nil

	end

	LeaPlusLC:CreateMainPanel();

----------------------------------------------------------------------
-- 	L80: Commands
----------------------------------------------------------------------

	-- Slash command function
	function LeaPlusLC:SlashFunc(str)
		if str and str ~= "" then
			-- Get parameters in lower case with duplicate spaces removed
			local str, arg1, arg2, arg3 = strsplit(" ", string.lower(str:gsub("%s+", " ")))
			-- Traverse parameters
			if str == "wipe" then
				-- Wipe settings
				LeaPlusLC:PlayerLogout(true) -- Run logout function with wipe parameter
				wipe(LeaPlusDB)
				LpEvt:UnregisterAllEvents(); -- Don't save any settings
				ReloadUI();
			elseif str == "talentdebug" then
				-- Show in chat how the info card reads talents (not saved)
				LeaPlusLC.IDTalentDebug = not LeaPlusLC.IDTalentDebug
				LeaPlusLC:Print("Info card talent debug " .. (LeaPlusLC.IDTalentDebug and "on" or "off") .. ".")
				return
			elseif str == "nosave" then
				-- Prevent Leatrix Plus from overwriting LeaPlusDB at next logout
				LpEvt:UnregisterEvent("PLAYER_LOGOUT")
				LeaPlusLC:Print("Leatrix Plus will not overwrite LeaPlusDB at next logout.")
				return
			elseif str == "reset" then
				-- Reset panel positions
				LeaPlusLC["MainPanelA"], LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				LeaPlusLC["PlusPanelScale"] = 1
				LeaPlusLC["PlusPanelAlpha"] = 0
				LeaPlusLC["PageF"]:SetScale(1)
				LeaPlusLC["PageF"].t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
				-- Refresh panels
				LeaPlusLC["PageF"]:ClearAllPoints()
				LeaPlusLC["PageF"]:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				-- Reset currently showing configuration panel
				for k, v in pairs(LeaConfigList) do
					if v:IsShown() then
						v:ClearAllPoints()
						v:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						v:SetScale(1)
						v.t:SetAlpha(1 - LeaPlusLC["PlusPanelAlpha"])
					end
				end
				-- Refresh Leatrix Plus settings menu only
				if LeaPlusLC["Page8"]:IsShown() then
					LeaPlusLC["Page8"]:Hide()
					LeaPlusLC["Page8"]:Show()
				end
			elseif str == "hk" then
				-- Print lifetime honorable kills
				local chagmsg = L["Lifetime honorable kills"]
				local ltphk = GetStatistic(588)
				if ltphk == "--" then ltphk = "0" end
				chagmsg = chagmsg .. ": |cffffffff" .. ltphk
				LeaPlusLC:Print(chagmsg)
				return
			elseif str == "taint" then
				-- Set taint log level
				if arg1 and arg1 ~= "" then
					arg1 = tonumber(arg1)
					if arg1 and arg1 >= 0 and arg1 <= 2 then
						if arg1 == 0 then
							-- Disable taint log
							ConsoleExec("taintLog 0")
							LeaPlusLC:Print("Taint level: Disabled (0).")
						elseif arg1 == 1 then
							-- Basic taint log
							ConsoleExec("taintLog 1")
							LeaPlusLC:Print("Taint level: Basic (1).")
						elseif arg1 == 2 then
							-- Full taint log
							ConsoleExec("taintLog 2")
							LeaPlusLC:Print("Taint level: Full (2).")
						end
					else
						LeaPlusLC:Print("Invalid taint level.")
					end
				else
					-- Show current taint level
					local taintCurrent = GetCVar("taintLog")
					if taintCurrent == "0" then
						LeaPlusLC:Print("Taint level: Disabled (0).")
					elseif taintCurrent == "1" then
						LeaPlusLC:Print("Taint level: Basic (1).")
					elseif taintCurrent == "2" then
						LeaPlusLC:Print("Taint level: Full (2).")
					end
				end
				return
			elseif str == "quest" then
				-- Show quest completed status
				if arg1 and arg1 ~= "" then
					if arg1 == "wipe" then
						-- Wipe quest log
						for i = 1, C_QuestLog.GetNumQuestLogEntries() do
							C_QuestLog.SetSelectedQuest(C_QuestLog.GetInfo(i).questID)
							C_QuestLog.SetAbandonQuest()
							C_QuestLog.AbandonQuest()
						end
						LeaPlusLC:Print(L["Quest log wiped."])
						return
					elseif arg1 == "clone" and GetNumSubgroupMembers(1) > 0 then
						-- Share all quests
						local i = 0
						C_Timer.NewTicker(0.3, function()
							i = i + 1
							local selectedQuest = C_QuestLog.GetInfo(i)
							if selectedQuest then
								C_QuestLog.SetSelectedQuest(selectedQuest.questID)
								local title = C_QuestLog.GetTitleForQuestID(selectedQuest.questID)
								if title then
									print(title)
									if C_QuestLog.IsPushableQuest(selectedQuest.questID) then
										QuestLogPushQuest(i)
									else
										LeaPlusLC:Print(L["Not applicable."])
									end
								end
							end
						end, C_QuestLog.GetNumQuestLogEntries())
						return
					elseif tonumber(arg1) and tonumber(arg1) < 999999999 then
						-- Show quest information
						LeaPlusLC.LoadQuestEventFrame = LeaPlusLC.LoadQuestEventFrame or CreateFrame("FRAME")
						LeaPlusLC.LoadQuestEventFrame:SetScript("OnEvent", function(self, event, questID, success)
							if tonumber(questID) == tonumber(arg1) then
								LeaPlusLC.LoadQuestEventFrame:UnregisterEvent("QUEST_DATA_LOAD_RESULT")
								local tempGetQuestInfo = C_QuestLog.GetTitleForQuestID
								local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(arg1)
								local questTitle = C_TaskQuest.GetQuestInfoByQuestID(arg1) or tempGetQuestInfo(arg1)
								if questTitle then
									if success then
										if questCompleted then
											LeaPlusLC:Print(questTitle .. " (" .. arg1 .. "):" .. "|cffffffff " .. L["Completed."])
										else
											LeaPlusLC:Print(questTitle .. " (" .. arg1 .. "):" .. "|cffffffff " .. L["Not completed."])
										end
									else
										LeaPlusLC:Print(questTitle .. " (" .. arg1 .. "):" .. "|cffffffff " .. L["Error retrieving quest."])
									end
								else
									LeaPlusLC:Print("Invalid quest ID.")
									return
								end
							end
						end)
						LeaPlusLC.LoadQuestEventFrame:RegisterEvent("QUEST_DATA_LOAD_RESULT")
						C_QuestLog.RequestLoadQuestByID(arg1)
					else
						LeaPlusLC:Print("Invalid quest ID.")
					end
				else
					LeaPlusLC:Print("Missing quest ID.")
				end
				return
			elseif str == "gstaff" then
				-- Buy 10 x Rough Wooden Staff from Larana Drome in Scribes' Sacellum, Dalaran, Northrend (used for testing)
				local npcName = UnitName("target")
				local npcGuid = UnitGUID("target") or nil
				local errmsg = "Requires you to be interacting with Larana Drome.  She can be found at Scribes' Sacellum, Dalaran, Northrend."
				if npcName and npcGuid then
					local void, void, void, void, void, npcID = strsplit("-", npcGuid)
					if npcID and npcID == "28723" then
						local id, ida, idb = 0, GetMerchantItemID(5), GetMerchantItemID(6)
						if ida == 1515 then id = 5 elseif idb == 1515 then id = 6 end
						if id > 0 then
							for k = 1, 10 do
								BuyMerchantItem(id)
							end
						end
					else
						LeaPlusLC:Print(errmsg)
					end
				else
					LeaPlusLC:Print(errmsg)
				end
				return
			elseif str == "rest" then
				-- Show rested bubbles
				LeaPlusLC:Print(L["Rested bubbles"] .. ": |cffffffff" .. (math.floor(20 * (GetXPExhaustion() or 0) / UnitXPMax("player") + 0.5)))
				return
			elseif str == "zygor" then
				-- Toggle Zygor addon
				LeaPlusLC:ZygorToggle()
				return
			elseif str == "mountid" then
				-- Get mount ID by mount name
				if not arg1 or arg1 == "" then LeaPlusLC:Print("Missing mount name.") return end
				local mounts = C_MountJournal.GetMountIDs()
				local mountSuccess = false
				for i = 1, #mounts do
					local creatureName, spellID, icon, active, isUsable, sourceType = C_MountJournal.GetMountInfoByID(mounts[i])
					if strfind(strlower(creatureName), strlower(arg1)) then
						LeaPlusLC:Print(creatureName .. ": |cffffffff" .. mounts[i] .. "|r")
						mountSuccess = true
					end
				end
				if not mountSuccess then LeaPlusLC:Print("Mount not found.") end
				return
			elseif str == "petid" then
				-- Get pet ID by pet name
				if not arg1 or arg1 == "" then LeaPlusLC:Print("Missing pet name.") return end
				local numPets = C_PetJournal.GetNumPets()
				local petSuccess = false
				for i = 1, numPets do
					local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, creatureID, sourceText, description, isWildPet, canBattle, tradable, unique = C_PetJournal.GetPetInfoByIndex(i, false)
					if strfind(strlower(name), strlower(arg1)) then
						if isOwned then
							LeaPlusLC:Print(name .. ": |cffffffff" .. petID .. " |cff00ff00(" .. level .. ")|r")
							petSuccess = true
						elseif not petSuccess then
							LeaPlusLC:Print("You do not own this pet.  Only owned pets can be searched.")
							return
						end
					end
				end
				if not petSuccess then
					LeaPlusLC:Print("Pet not found.  Only owned pets that are currently showing in the journal can be searched.")
				end
				return
			elseif str == "tooltip" then
				-- Print tooltip frame name
				pcall(function()
					local enumf = EnumerateFrames()
					while enumf do
						if (enumf:GetObjectType() == "GameTooltip" or strfind((enumf:GetName() or ""):lower(),"tip")) and enumf:IsVisible() and enumf:GetPoint() then
							print(enumf:GetName())
						end
						enumf = EnumerateFrames(enumf)
					end
					collectgarbage()
					return
				end)
			elseif str == "soil" then
				-- Enable dark soil and jelly deposit scanning
				if not LeaPlusLC["DarkScriptlEnabled"] then
					GameTooltip:HookScript("OnUpdate", function()
						local a = _G["GameTooltipTextLeft1"]:GetText() or ""
						if a == "Dark Soil" or a == "Jelly Deposit" or a == "Gersahl Shrub" then
							C_Sound.PlaySound(8959, "Master")
						end
					end)
					-- Add Friendly Alpaca spawn locations to Uldum map
					if TomTom then
						for void, v in next, ({{15,62},{24,9},{28,49},{30,29},{39,10},{42,70},{46,48},{53,19},{55,69},{63,53},{63,14},{70,39},{76,68}}) do
							TomTom:AddWaypoint(1527, v[1]/100, v[2]/100, {title = "Friendly Alpaca"})
						end
					end
					LeaPlusLC["DarkScriptlEnabled"] = true
					LeaPlusLC:Print("Dark Soil scanning activated.  Reload UI to exit.")
				else
					LeaPlusLC:Print("Dark Soil scanning is already activated.  You only need to run this once.  Reload UI to exit.")
				end
				return
			elseif str == "rsnd" then
				-- Restart sound system
				if LeaPlusCB["StopMusicBtn"] then LeaPlusCB["StopMusicBtn"]:Click() end
				Sound_GameSystem_RestartSoundSystem()
				LeaPlusLC:Print("Sound system restarted.")
				return
			elseif str == "event" then
				-- List events (used for debug)
				LeaPlusLC["DbF"] = LeaPlusLC["DbF"] or CreateFrame("FRAME")
				if not LeaPlusLC["DbF"]:GetScript("OnEvent") then
					LeaPlusLC:Print("Tracing started.")
					LeaPlusLC["DbF"]:RegisterAllEvents()
					LeaPlusLC["DbF"]:SetScript("OnEvent", function(self, event)
						if event == "ACTIONBAR_UPDATE_COOLDOWN"
						or event == "BAG_UPDATE_COOLDOWN"
						or event == "CHAT_MSG_TRADESKILLS"
						or event == "COMBAT_LOG_EVENT_UNFILTERED"
						or event == "CURSOR_CHANGED"
						or event == "ITEM_DATA_LOAD_RESULT"
						or event == "SPELL_UPDATE_COOLDOWN"
						or event == "SPELL_UPDATE_USABLE"
						or event == "UNIT_POWER_FREQUENT"
						or event == "UPDATE_INVENTORY_DURABILITY"
						or event == "UPDATE_SHAPESHIFT_COOLDOWN"
						or event == "UPDATE_UI_WIDGET"
						or event == "WORLD_CURSOR_TOOLTIP_UPDATE"
						then return
						else
							print(event)
						end
					end)
				else
					LeaPlusLC["DbF"]:UnregisterAllEvents()
					LeaPlusLC["DbF"]:SetScript("OnEvent", nil)
					LeaPlusLC:Print("Tracing stopped.")
				end
				return
			elseif str == "game" then
				-- Show game build
				local version, build, gdate, tocversion = GetBuildInfo()
				LeaPlusLC:Print(L["World of Warcraft"] .. ": |cffffffff" .. version .. "." .. build .. " (" .. gdate .. ") (" .. tocversion .. ")")
				return
			elseif str == "config" then
				-- Show maximum camera distance
				LeaPlusLC:Print(L["Camera distance"] .. ": |cffffffff" .. GetCVar("cameraDistanceMaxZoomFactor"))
				-- Show screen effects
				LeaPlusLC:Print(L["Shaders"] .. ": |cffffffff" .. GetCVar("ffxGlow") .. ", " .. GetCVar("ffxDeath") .. ", " .. GetCVar("ffxNether"))
				-- Show particle density
				LeaPlusLC:Print(L["Particle density"] .. ": |cffffffff" .. GetCVar("particleDensity"))
				LeaPlusLC:Print(L["Weather density"] .. ": |cffffffff" .. GetCVar("weatherDensity"))
				LeaPlusLC:Print(L["Field of view"] .. ": |cffffffff" .. GetCVar("camerafov"))
				-- Show config
				LeaPlusLC:Print("SynchroniseConfig: |cffffffff" .. GetCVar("synchronizeConfig"))
				-- Show raid restrictions
				local unRaid = GetAllowLowLevelRaid()
				if unRaid and unRaid == true then
					LeaPlusLC:Print("GetAllowLowLevelRaid: |cffffffff" .. "True")
				else
					LeaPlusLC:Print("GetAllowLowLevelRaid: |cffffffff" .. "False")
				end
				return
			elseif str == "tipcol" then
				-- Show default tooltip title color
				if GameTooltipTextLeft1:IsShown() then
					local r, g, b, a = GameTooltipTextLeft1:GetTextColor()
					r = r <= 1 and r >= 0 and r or 0
					g = g <= 1 and g >= 0 and g or 0
					b = b <= 1 and b >= 0 and b or 0
					LeaPlusLC:Print(L["Tooltip title color"] .. ": " .. strupper(string.format("%02x%02x%02x", r * 255, g * 255, b * 255) .. "."))
				else
					LeaPlusLC:Print("No tooltip showing.")
				end
				return
			elseif str == "list" then
				-- Enumerate frames
				local frame = EnumerateFrames()
				while frame do
					if not frame:IsAnchoringSecret() then
						if (frame:IsVisible() and frame:IsMouseOver()) then
							LeaPlusLC:Print(frame:GetName() or string.format("[Unnamed Frame: %s]", tostring(frame)))
						end
					else
						LeaPlusLC:Print(L["[Secret frame: SECRET FRAME]"])
					end
					frame = EnumerateFrames(frame)
				end
				return
			elseif str == "nohelp" then
				-- Set most help plates to seen
				for i = 1, 100 do
					SetCVarBitfield("closedInfoFrames", i, true)
				end
				return
			elseif str == "grid" then
				-- Toggle frame alignment grid
				if LeaPlusLC.grid:IsShown() then LeaPlusLC.grid:Hide() else LeaPlusLC.grid:Show() end
				return
			elseif str == "chk" then
				-- List truncated checkbox labels
				if LeaPlusLC["TruncatedLabelsList"] then
					for i, v in pairs(LeaPlusLC["TruncatedLabelsList"]) do
						LeaPlusLC:Print(LeaPlusLC["TruncatedLabelsList"][i])
					end
				else
					LeaPlusLC:Print("Checkbox labels are Ok.")
				end
				return
			elseif str == "cv" then
				-- Print and set console variable setting
				if arg1 and arg1 ~= "" then
					if GetCVar(arg1) then
						if arg2 and arg2 ~= ""  then
							if tonumber(arg2) then
								SetCVar(arg1, arg2)
							else
								LeaPlusLC:Print("Value must be a number.")
								return
							end
						end
						LeaPlusLC:Print(arg1 .. ": |cffffffff" .. GetCVar(arg1))
					else
						LeaPlusLC:Print("Invalid console variable.")
					end
				else
					LeaPlusLC:Print("Missing console variable.")
				end
				return
			elseif str == "torch" or str == "t" then
				-- Torch toggle
				if tonumber(GetCVar("gamma")) ~= 1.0 then
					SetCVar("gamma", 1.0)
					LeaPlusLC:DisplayMessage(L["Torch Off"], true)
				else
					SetCVar("gamma", 1.3)
					LeaPlusLC:DisplayMessage(L["Torch On"], true)
				end
				return
			elseif str == "play" then
				-- Play sound ID
				if arg1 and arg1 ~= "" then
					if tonumber(arg1) then
						-- Stop last played sound ID
						if LeaPlusLC.SNDcanitHandle then
							StopSound(LeaPlusLC.SNDcanitHandle)
						end
						-- Play sound ID
						LeaPlusLC.SNDcanitPlay, LeaPlusLC.SNDcanitHandle = C_Sound.PlaySound(arg1, "Master", false, false)
						if not LeaPlusLC.SNDcanitPlay then LeaPlusLC:Print(L["Invalid sound ID"] .. ": |cffffffff" .. arg1) end
					else
						LeaPlusLC:Print(L["Invalid sound ID"] .. ": |cffffffff" .. arg1)
					end
				else
					LeaPlusLC:Print("Missing sound ID.")
				end
				return
			elseif str == "stop" then
				-- Stop last played sound ID
				if LeaPlusLC.SNDcanitHandle then
					StopSound(LeaPlusLC.SNDcanitHandle)
				end
				return
			elseif str == "team" then
				-- Assign battle pet team
				local p1, s1p1, s1p2, s1p3, p2, s2p1, s2p2, s2p3, p3, s3p1, s3p2, s3p3 = strsplit(",", arg1 or "", 12)
				if p1 and s1p1 and s1p2 and s1p3 and p2 and s2p1 and s2p2 and s2p3 and p3 and s3p1 and s3p2 and s3p3 then
					if LeaPlusLC:PlayerInCombat() then
						return
					else
						-- Ensure all 3 slots are unlocked
						for i = 1, 3 do
							local void, void, void, void, isLocked = C_PetJournal.GetPetLoadOutInfo(i)
							if isLocked and isLocked == true then
								LeaPlusLC:Print("All 3 battle pet slots need to be unlocked.")
								return
							end
						end
						-- Assign pets
						C_PetJournal.SetPetLoadOutInfo(1, p1)
						C_PetJournal.SetAbility(1, 1, s1p1)
						C_PetJournal.SetAbility(1, 2, s1p2)
						C_PetJournal.SetAbility(1, 3, s1p3)
						C_PetJournal.SetPetLoadOutInfo(2, p2)
						C_PetJournal.SetAbility(2, 1, s2p1)
						C_PetJournal.SetAbility(2, 2, s2p2)
						C_PetJournal.SetAbility(2, 3, s2p3)
						C_PetJournal.SetPetLoadOutInfo(3, p3)
						C_PetJournal.SetAbility(3, 1, s3p1)
						C_PetJournal.SetAbility(3, 2, s3p2)
						C_PetJournal.SetAbility(3, 3, s3p3)
						if PetJournal and PetJournal:IsShown() then
							PetJournal_UpdatePetLoadOut()
						end
					end
				else
					LeaPlusLC:Print("Invalid battle pet team parameter.")
				end
				return
			elseif str == "wipecds" then
				-- Wipe cooldowns
				LeaPlusDB["Cooldowns"] = nil
				ReloadUI()
				return
			elseif str == "tipchat" then
				-- Print tooltip contents in chat
				local numLines = GameTooltip:NumLines()
				if numLines then
					for i = 1, numLines do
						print(_G["GameTooltipTextLeft" .. i]:GetText() or "")
					end
				end
				return
			elseif str == "tiplang" then
				-- Tooltip tag locale code constructor
				local msg = ""
				msg = msg .. 'if GameLocale == "' .. GameLocale .. '" then '
				msg = msg .. 'ttLevel = "' .. LEVEL .. '"; '
				msg = msg .. 'ttBoss = "' .. BOSS .. '"; '
				msg = msg .. 'ttElite = "' .. ELITE .. '"; '
				msg = msg .. 'ttRare = "' .. ITEM_QUALITY3_DESC .. '"; '
				msg = msg .. 'ttRareElite = "' .. ITEM_QUALITY3_DESC .. " " .. ELITE .. '"; '
				msg = msg .. 'ttRareBoss = "' .. ITEM_QUALITY3_DESC .. " " .. BOSS .. '"; '
				msg = msg .. 'ttTarget = "' .. TARGET .. '"; '
				msg = msg .. "end"
				print(msg)
				return
			elseif str == "con" then
				-- Show the developer console
				ConsoleSetFontHeight(28)
				DeveloperConsole:Toggle(true)
				return
			elseif str == "movietime" then
				-- Show movie length
				if not LeaPlusLC.movieTimeLoaded then
					hooksecurefunc(MovieFrame, "Show", function()
						LeaPlusLC.startMovieTime = GetTime()
					end)
					hooksecurefunc(MovieFrame, "Hide", function()
						LeaPlusLC.endMovieTime = GetTime()
						local ttime = LeaPlusLC.endMovieTime - LeaPlusLC.startMovieTime
						print(string.format("%0.0f", ttime))
					end)
					LeaPlusLC.movieTimeLoaded = true
					LeaPlusLC:Print("MovieTime loaded.")
				else
					LeaPlusLC:Print("MovieTime is already loaded.")
				end
				return
			elseif str == "movie" then
				-- Playback movie by ID
				arg1 = tonumber(arg1)
				if arg1 and arg1 ~= "" then
					-- Play movie by ID
					if IsMoviePlayable(arg1) then
						MovieFrame_PlayMovie(MovieFrame, arg1)
					else
						LeaPlusLC:Print("Movie not playable.")
					end
				else
					-- List playable movie IDs
					local count = 0
					for i = 1, 5000 do
						if IsMoviePlayable(i) then
							print(i)
							count = count + 1
						end
					end
					LeaPlusLC:Print("Total movies: |cffffffff" .. count)
				end
				return
			elseif str == "cin" then
				-- Play opening cinematic (only works if character has never gained XP) (used for testing)
				OpeningCinematic()
				return
			elseif str == "skit" then
				-- Play a test sound kit
				C_Sound.PlaySound("1020", "Master", false, true)
				return
			elseif str == "dup" then
				-- Print music track duplicates
				local mask, found, badidfound = false, false, false
				for i, e in pairs(Leatrix_Plus["ZoneList"]) do
					if Leatrix_Plus["ZoneList"][e] then
						for a, b in pairs(Leatrix_Plus["ZoneList"][e]) do
							local same = {}
							if b.tracks then
								for k, v in pairs(b.tracks) do
									-- Check for bad sound IDs
									if not strfind(v, "|c") then
										if not v:match("([^,]+)%#([^,]+)%#([^,]+)") then
											local temFile, temSoundID = v:match("([^,]+)%#([^,]+)")
											if temSoundID then
												local temPlay, temHandle = C_Sound.PlaySound(temSoundID, "Master", false, true)
												if temHandle then StopSound(temHandle) end
												temPlay, temHandle = C_Sound.PlaySound(temSoundID, "Master", false, true)
												if not temPlay and not temHandle then
													print("|cffff5400" .. L["Bad ID"] .. ": |r" .. e, v)
													badidfound = true
												else
													if temHandle then StopSound(temHandle) end
												end
											end
										end
										-- Check for duplicate IDs
										if table.contains(same, v) and mask == false then
											mask = true
											found = true
											print("|cffec51ff" .. L["Dup ID"] .. ": |r" .. e, v)
										end
										tinsert(same, v)
										mask = false
									end
								end
							end
						end
					end
				end
				if badidfound == false then
					LeaPlusLC:Print("No bad sound IDs found.")
				end
				if found == false then
					LeaPlusLC:Print("No media duplicates found.")
				end
				Sound_GameSystem_RestartSoundSystem()
				collectgarbage()
				return
			elseif str == "enigma" then
				-- Enigma
				if not LeaPlusLC.enimgaFrame then
					local selectedBtn
					local bt = {}
					local eData = {
						{[9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [20]=1, [23]=1, [24]=1, [25]=1, [26]=1, [27]=1, [30]=1, [37]=1, [38]=1, [39]=1, [40]=1, [41]=2, "L4, U2, R4, U2, L4",},
						{[9]=1, [11]=1, [12]=1, [13]=1, [16]=1, [18]=1, [20]=1, [23]=1, [24]=1, [25]=1, [27]=1, [34]=1, [41]=2, "U4, L2, D2, L2, U2",},
						{[9]=1, [10]=1, [11]=1, [12]=1, [19]=1, [25]=1, [26]=1, [32]=1, [39]=1, [40]=1, [41]=2, "L2, U2, R1, U2, L3",},
						{[9]=1, [10]=1, [11]=1, [18]=1, [23]=1, [24]=1, [25]=1, [30]=1, [37]=1, [38]=1, [39]=1, [40]=1, [41]=2, "L4, U2, R2, U2, L2",},
						{[9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [16]=1, [23]=1, [25]=1, [26]=1, [27]=1, [30]=1, [32]=1, [34]=1, [37]=1, [38]=1, [39]=1, [41]=2, "U2, L2, D2, L2, U4, R4",},
						{[12]=1,[13]=1, [18]=1, [19]=1, [25]=1, [32]=1, [33]=1, [40]=1, [41]=2, "L1, U1, L1, U2, R1, U1, R1",},
						{[9]=1, [11]=1, [12]=1, [13]=1, [16]=1, [18]=1, [20]=1, [23]=1, [25]=1, [27]=1, [30]=1, [31]=1, [32]=1, [34]=1, [41]=2, "U4, L2, D3, L2, U3",},
						{[9]=1, [10]=1, [17]=1, [24]=1, [25]=1, [32]=1, [33]=1, [40]=1, [41]=2, "L1, U1, L1, U1, L1, U2, L1",},
						{[9]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [27]=1, [34]=1, [41]=2, "U3, L4, U1",},
						{[9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [16]=1, [23]=1, [24]=1, [25]=1, [26]=1, [33]=1, [40]=1, [41]=2, "L1, U2, L3, U2, R4",},
						{[9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [16]=1, [23]=1, [30]=1, [37]=1, [38]=1, [39]=1, [40]=1, [41]=2, "L4, U4, R4",},
						{[11]=1,[12]=1, [13]=1, [18]=1, [23]=1, [24]=1, [25]=1, [30]=1, [37]=1, [38]=1, [39]=1, [40]=1, [41]=2, "L4, U2, R2, U2, R2",},
						{[13]=1,[20]=1, [23]=1, [24]=1, [25]=1, [26]=1, [27]=1, [30]=1, [37]=1, [38]=1, [39]=1, [40]=1, [41]=2, "L4, U2, R4, U2",},
					}
					-- Create frame
					local eFrame = CreateFrame("Frame", nil, UIParent)
					eFrame:SetPoint("TOP", 0, 0)
					eFrame:SetSize(1222, 134)
					eFrame.b = eFrame:CreateTexture(nil, "BACKGROUND")
					eFrame.b:SetAllPoints()
					eFrame.b:SetColorTexture(0, 0, 0, 1)
					eFrame:SetFrameStrata("FULLSCREEN_DIALOG")
					eFrame:SetScale(0.9)
					eFrame:SetToplevel(true)
					eFrame:EnableMouse(true)
					LeaPlusLC.enimgaFrame = eFrame

					-- Right-click to exit
					eFrame:SetScript("OnMouseDown", function(self, btn)
						if btn == "RightButton" then
							eFrame:Hide()
						end
					end)

					-- Create title fontstring
					eFrame.f = eFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
					eFrame.f:SetPoint("BOTTOMLEFT", 10, 10)
					eFrame.f:SetText(L["Choose an Enigma pattern"])
					eFrame.f:SetFont(eFrame.f:GetFont(), 24, nil)

					-- Create close fontstring
					eFrame.x = eFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
					eFrame.x:SetPoint("BOTTOMRIGHT", -10, 10)
					eFrame.x:SetText(L["Right-click to close"])
					eFrame.x:SetFont(eFrame.f:GetFont(), 24, nil)

					-- Create buttons
					for eBtn = 1, #eData do
						local b = CreateFrame("Button", nil, eFrame)
						tinsert(bt, b)
						b:SetSize(94, 94)
						b:SetPoint("TOPLEFT", ((eBtn - 1) % 13) * 94, -2)

						-- Button highlight bar
						b.line = b:CreateTexture(nil, "ARTWORK")
						b.line:SetTexture("Interface\\PLAYERFRAME\\DruidLunarBarHorizontal")
						b.line:SetSize(84, 6)
						b.line:SetPoint("BOTTOM", 0, -4)
						b.line:Hide()

						-- Button textures
						for row = 0, 7 - 1 do
							for col = 0, 7 - 1 do
								local t = b:CreateTexture(nil, "ARTWORK")
								t:SetSize(12, 12)
								t:SetPoint("TOPLEFT", 5 + col * 12, - 5 - row * 12)
								local c = eData[eBtn][row * 7 + col + 1]
								-- Do nothing if element is the solution
								if c and strfind(c, ",") then c = nil end
								-- Color textures
								if c == 2 then
									-- Starting block
									t:SetColorTexture(0, 1, 0)
								elseif c then
									-- Path
									t:SetColorTexture(1, 1, 1)
								else
									-- Background
									t:SetColorTexture(.4, .4, .9)
								end
							end
						end

						-- Button scripts
						b:SetScript("OnEnter", function()
							bt[eBtn].line:Show()
						end)

						b:SetScript("OnLeave", function()
							if b ~= selectedBtn then bt[eBtn].line:Hide() end
						end)

						b:SetScript("OnMouseDown", function(self, btn)
							if btn == "RightButton" then
								-- Right-click to exit
								eFrame:Hide()
								return
							else
								-- Deselect all buttons
								for test = 1, #bt do
									bt[test].line:Hide()
								end
								-- Select current button
								bt[eBtn].line:Show()
								selectedBtn = b
								C_Sound.PlaySound(115, "Master", false, true)
								-- Print button data
								eFrame.f:SetText(L["Enigma"] .. " " .. eBtn .. ": |cffffffff" .. eData[eBtn][#eData[eBtn]])
							end
						end)

					end
				else
					-- Toggle frame
					if LeaPlusLC.enimgaFrame:IsShown() then
						LeaPlusLC.enimgaFrame:Hide()
					else
						LeaPlusLC.enimgaFrame:Show()
					end
				end
				return
			elseif str == "showinst" then
				-- List instance IDs for currently selected Encounter Journal expansion filter dropdown
				for i = 1, 5000 do
					local instanceID, name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceByIndex(i, false)
					if instanceID then print(instanceID, name) end
				end
				for i = 1, 5000 do
					local instanceID, name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = EJ_GetInstanceByIndex(i, true)
					if instanceID then print(instanceID, name) end
				end
				return
			elseif str == "exit" then
				-- Exit a vehicle
				VehicleExit()
				return
			elseif str == "pos" then
				-- Map POI code builder
				local mapID = C_Map.GetBestMapForUnit("player") or nil
				local mapName = C_Map.GetMapInfo(mapID).name or nil
				local mapRects = {}
				local tempVec2D = CreateVector2D(0, 0)
				local void
				-- Get player map position
				tempVec2D.x, tempVec2D.y = UnitPosition("player")
				if not tempVec2D.x then return end
				local mapRect = mapRects[mapID]
				if not mapRect then
					mapRect = {}
					void, mapRect[1] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
					void, mapRect[2] = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
					mapRect[2]:Subtract(mapRect[1])
					mapRects[mapID] = mapRect
				end
				tempVec2D:Subtract(mapRects[mapID][1])
				local pX, pY = tempVec2D.y/mapRects[mapID][2].y, tempVec2D.x/mapRects[mapID][2].x
				pX = string.format("%0.1f", 100 * pX)
				pY = string.format("%0.1f", 100 * pY)
				if mapID and mapName and pX and pY then
					ChatFrame1:Clear()
					local dnType, dnTex = "Dungeon", "dnTex"
					if arg1 == "raid" then dnType, dnTex = "Raid", "rdTex" end
					if arg1 == "portal" then dnType = "Portal" end
					print('[' .. mapID .. '] =  --[[' .. mapName .. ']] {{"Dungeon", ' .. pX .. ', ' .. pY .. ', L[' .. '"Name"' .. '], L[' .. '"' .. dnType .. '"' .. ']},},')
				end
				return
			elseif str == "mapref" then
				-- Print map reveal structure code
				if not WorldMapFrame:IsShown() then
					LeaPlusLC:Print("Open the map first!")
					return
				end
				ChatFrame1:Clear()
				local msg = ""
				local mapID = WorldMapFrame.mapID
				local mapName = C_Map.GetMapInfo(mapID).name
				local mapArt = C_Map.GetMapArtID(mapID)
				msg = msg .. "--[[" .. mapName .. "]] [" .. mapArt .. "] = {"
				local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID);
				if exploredMapTextures then
					for i, exploredTextureInfo in ipairs(exploredMapTextures) do
						local twidth = exploredTextureInfo.textureWidth or 0
						if twidth > 0 then
							local theight = exploredTextureInfo.textureHeight or 0
							local offsetx = exploredTextureInfo.offsetX
							local offsety = exploredTextureInfo.offsetY
							local filedataIDS = exploredTextureInfo.fileDataIDs
							msg = msg .. "[" .. '"' .. twidth .. ":" .. theight .. ":" .. offsetx .. ":" .. offsety .. '"' .. "] = " .. '"'
							for fileData = 1, #filedataIDS do
								msg = msg .. filedataIDS[fileData]
								if fileData < #filedataIDS then
									msg = msg .. ", "
								else
									msg = msg .. '",'
									if i < #exploredMapTextures then
										msg = msg .. " "
									end
								end
							end
						end
					end
					msg = msg .. "},"
					print(msg)
				end
				return
			elseif str == "map" then
				-- Set map by ID, print currently showing map ID or print character map ID
				if not arg1 then
					-- Print map ID
					if WorldMapFrame:IsShown() then
						-- Show world map ID
						local mapID = WorldMapFrame.mapID or nil
						local artID = C_Map.GetMapArtID(mapID) or nil
						local mapName = C_Map.GetMapInfo(mapID).name or nil
						if mapID and artID and mapName then
							LeaPlusLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (map)")
						end
					else
						-- Show character map ID
						local mapID = C_Map.GetBestMapForUnit("player") or nil
						local artID = C_Map.GetMapArtID(mapID) or nil
						local mapName = C_Map.GetMapInfo(mapID).name or nil
						if mapID and artID and mapName then
							LeaPlusLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (player)")
						end
					end
					return
				elseif not tonumber(arg1) or not C_Map.GetMapInfo(arg1) then
					-- Invalid map ID
					LeaPlusLC:Print("Invalid map ID.")
				else
					-- Set map by ID
					WorldMapFrame:SetMapID(tonumber(arg1))
				end
				return
			elseif str == "cls" then
				-- Clear chat frame
				ChatFrame1:Clear()
				return
			elseif str == "al" then
				-- Enable auto loot
				SetCVar("autoLootDefault", "1")
				LeaPlusLC:Print("Auto loot is now enabled.")
				return
			elseif str == "realm" then
				-- Show list of connected realms
				local titleRealm = GetRealmName()
				local userRealm = GetNormalizedRealmName()
				local connectedServers = C_AutoComplete.GetAutoCompleteRealms()
				if titleRealm and userRealm and connectedServers then
					LeaPlusLC:Print(L["Connections for"] .. "|cffffffff " .. titleRealm)
					if #connectedServers > 0 then
						local count = 1
						for i = 1, #connectedServers do
							if userRealm ~= connectedServers[i] then
								LeaPlusLC:Print(count .. ".  " .. connectedServers[i])
								count = count + 1
							end
						end
					else
						LeaPlusLC:Print("None")
					end
				end
				return
			elseif str == "deletelooms" then
				-- Delete heirlooms from bags
				for bag = 0, 4 do
					for slot = 1, C_Container.GetContainerNumSlots(bag) do
						local name = C_Container.GetContainerItemLink(bag, slot)
						if name and string.find(name, "00ccff") then
							print(name)
							PickupContainerItem(bag, slot)
							DeleteCursorItem()
						end
					end
				end
				return
			elseif str == "help" then
				-- Help panel
				if not LeaPlusLC.HelpFrame then
					local frame = CreateFrame("FRAME", nil, UIParent)
					frame:SetSize(570, 360); frame:SetFrameStrata("FULLSCREEN_DIALOG"); frame:SetFrameLevel(100)
					frame.tex = frame:CreateTexture(nil, "BACKGROUND"); frame.tex:SetAllPoints(); frame.tex:SetColorTexture(0.05, 0.05, 0.05, 0.9)
					frame.close = LeaPlusLC:CreateCloseButton(frame, 30, 30, "TOPRIGHT", 0, 0)
					frame.close:SetScript("OnClick", function() frame:Hide() end)
					frame:ClearAllPoints(); frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					frame:SetClampedToScreen(true)
					frame:SetClampRectInsets(450, -450, -300, 300)
					frame:EnableMouse(true)
					frame:SetMovable(true)
					frame:RegisterForDrag("LeftButton")
					frame:SetScript("OnDragStart", frame.StartMoving)
					frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() frame:SetUserPlaced(false) end)
					frame:Hide()
					LeaPlusLC:CreateBar("HelpPanelMainTexture", frame, 570, 360, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
					-- Panel contents
					local col1, col2, color1 = 10, 120, "|cffffffaa"
					LeaPlusLC:MakeTx(frame, "Leatrix Plus Help", col1, -10)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp|r", col1, -30)
					LeaPlusLC:MakeWD(frame, "Toggle opttions panel.", col2, -30)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp reset", col1, -50)
					LeaPlusLC:MakeWD(frame, "Reset addon panel position and scale.", col2, -50)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp wipe", col1, -70)
					LeaPlusLC:MakeWD(frame, "Wipe all addon settings (reloads UI).", col2, -70)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp realm", col1, -90)
					LeaPlusLC:MakeWD(frame, "Show realms connected to yours.", col2, -90)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp rest", col1, -110)
					LeaPlusLC:MakeWD(frame, "Show number of rested XP bubbles remaining.", col2, -110)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp quest <id>", col1, -130)
					LeaPlusLC:MakeWD(frame, "Show quest completion status for <quest id>.", col2, -130)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp quest wipe", col1, -150)
					LeaPlusLC:MakeWD(frame, "Wipe your quest log.", col2, -150)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp hk", col1, -170)
					LeaPlusLC:MakeWD(frame, "Show your lifetime honorable kills.", col2, -170)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp grid", col1, -190)
					LeaPlusLC:MakeWD(frame, "Toggle a frame alignment grid.", col2, -190)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp zygor", col1, -210)
					LeaPlusLC:MakeWD(frame, "Toggle the Zygor addon (reloads UI).", col2, -210)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp movie <id>", col1, -230)
					LeaPlusLC:MakeWD(frame, "Play a movie by its ID.", col2, -230)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp enigma", col1, -250)
					LeaPlusLC:MakeWD(frame, "Toggle the Enigmatic quest solver.", col2, -250)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp rsnd", col1, -270)
					LeaPlusLC:MakeWD(frame, "Restart the sound system.", col2, -270)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp ra", col1, -290)
					LeaPlusLC:MakeWD(frame, "Announce target in General chat channel (useful for rares).", col2, -290)
					LeaPlusLC:MakeWD(frame, color1 .. "/ltp con", col1, -310)
					LeaPlusLC:MakeWD(frame, "Launch the developer console with a large font.", col2, -310)
					LeaPlusLC:MakeWD(frame, color1 .. "/rl", col1, -330)
					LeaPlusLC:MakeWD(frame, "Reload the UI.", col2, -330)
					LeaPlusLC.HelpFrame = frame
					_G["LeaPlusGlobalHelpPanel"] = frame
					table.insert(UISpecialFrames, "LeaPlusGlobalHelpPanel")
				end
				if LeaPlusLC.HelpFrame:IsShown() then LeaPlusLC.HelpFrame:Hide() else LeaPlusLC.HelpFrame:Show() end
				return
			elseif str == "who" then
				-- Print out who list URLs
				ChatFrame1:Clear()
				local realmName = gsub(GetRealmName(), " ", "-")
				for i = 1,C_FriendList.GetNumWhoResults() do
					local p = C_FriendList.GetWhoInfo(i)
					if not string.find(p.fullName, "-") then
						print("https://worldofwarcraft.com/en-gb/character/eu/" .. realmName .. "/" .. p.fullName .. "/collections/pets")
					end
				end
				return
			elseif str == "ra" then
				-- Announce target name and map pin link in General chat channel
				if C_ChatInfo.InChatMessagingLockdown() then
					LeaPlusLC:Print("Chat messages are restricted right now.")
					return
				end
				local genChannel
				if GameLocale == "deDE" 	then genChannel = "Allgemein"
				elseif GameLocale == "esMX" then genChannel = "General"
				elseif GameLocale == "esES" then genChannel = "General"
				elseif GameLocale == "frFR" then genChannel = "Général"
				elseif GameLocale == "itIT" then genChannel = "Generale"
				elseif GameLocale == "ptBR" then genChannel = "Geral"
				elseif GameLocale == "ruRU" then genChannel = "Общий"
				elseif GameLocale == "koKR" then genChannel = "공개"
				elseif GameLocale == "zhCN" then genChannel = "综合"
				elseif GameLocale == "zhTW" then genChannel = "綜合"
				else							 genChannel = "General"
				end
				-- genChannel = "Crazy" -- Uncomment for debug
				if genChannel then
					local index = GetChannelName(genChannel)
					if index and index > 0 then
						local mapID = C_Map.GetBestMapForUnit("player")
						if C_Map.CanSetUserWaypointOnMap(mapID) then
							local pos = C_Map.GetPlayerMapPosition(mapID, "player")
							if pos.x and pos.x ~= "0" and pos.y and pos.y ~= "0" then
								local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
								if mapPoint then
									-- Store original pin if there is one
									local currentPin = C_Map.GetUserWaypointHyperlink()
									-- Set map pin and get the link
									C_Map.SetUserWaypoint(mapPoint)
									local myPin = C_Map.GetUserWaypointHyperlink()
									-- Put original pin back if there was one
									if currentPin then
										C_Timer.After(0.1, function()
											local oldPin = C_Map.GetUserWaypointFromHyperlink(currentPin)
											C_Map.SetUserWaypoint(oldPin)
										end)
									end
									-- Announce in chat
									if myPin then
										-- Get unit classification (elite, rare, rare elite or boss)
										local unitType, unitTag = UnitClassification("target"), ""
										if unitType then
											if unitType == "rare" or unitType == "rareelite" then unitTag = "(" .. L["Rare"] .. ") " elseif unitType == "worldboss" then unitTag = "(" .. L["Boss"] .. ") " end
										end
										C_ChatInfo.SendChatMessage(format("%%t " .. unitTag, " ") .. " " .. myPin, "CHANNEL", nil, index)
--										C_ChatInfo.SendChatMessage(format("%%t " .. unitTag, " ") .. " " .. myPin, "WHISPER", nil, GetUnitName("player")) -- Debug
										C_Map.ClearUserWaypoint()
									else
										LeaPlusLC:Print("Invalid target.")
									end
								else
									LeaPlusLC:Print("Cannot announce in this zone.")
								end
							else
								LeaPlusLC:Print("Cannot announce in this zone.")
							end
						else
							LeaPlusLC:Print("Cannot announce in this zone.")
						end
					else
						LeaPlusLC:Print("Cannot find General chat channel.")
					end
				end
				return
			elseif str == "ach" then
				-- Set Instance Achievement Tracker window properties
				if AchievementTracker then
					AchievementTracker:SetScale(1.4)
					AchievementTracker:SetClampRectInsets(500, -500, -10, 300)
					table.insert(UISpecialFrames, "AchievementTracker")
					LeaPlusLC:Print("IAT scale set and window can now be closed with escape.")
				end
				return
			elseif str == "blanchy" then
				-- Sound alert when Dead Blanchy emotes nearby
				LeaPlusLC.BlanchyFrame = LeaPlusLC.BlanchyFrame or CreateFrame("FRAME")
				if LeaPlusLC.BlanchyFrame:IsEventRegistered("CHAT_MSG_MONSTER_EMOTE") then
					C_Map.ClearUserWaypoint()
					LeaPlusLC.BlanchyFrame:UnregisterEvent("CHAT_MSG_MONSTER_EMOTE")
					LeaPlusLC:Print("Dead Blanchy alert disabled.")
				else
					C_Map.SetUserWaypoint(UiMapPoint.CreateFromVector2D(1525, CreateVector2D(63.1/100, 43.0/100)))
					LeaPlusLC.BlanchyFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
					LeaPlusLC:Print("Dead Blanchy alert active.  Spawn point has been pinned to the Revendreth map.  An alert will sound 20 times when Blanchy emotes nearby.")
				end
				LeaPlusLC.BlanchyFrame:SetScript("OnEvent", function(self, event, void, pname)
					if pname == L["Dead Blanchy"] then
						C_Timer.NewTicker(1, function()	C_Sound.PlaySound(8959, "Master") end, 20)
					end
				end)
				return
			elseif str == "perf" then
				-- Average FPS during combat
				local fTab = {}
				if not LeaPlusLC.perf then
					LeaPlusLC.perf = CreateFrame("FRAME")
				end
				local fFrm = LeaPlusLC.perf
				local k, startTime = 0, 0
				if fFrm:IsEventRegistered("PLAYER_REGEN_DISABLED") then
					fFrm:UnregisterAllEvents()
					fFrm:SetScript("OnUpdate", nil)
					LeaPlusLC:Print("PERF unloaded.")
				else
					fFrm:RegisterEvent("PLAYER_REGEN_DISABLED")
					fFrm:RegisterEvent("PLAYER_REGEN_ENABLED")
					LeaPlusLC:Print("Waiting for combat to start...")
				end
				fFrm:SetScript("OnEvent", function(self, event)
					if event == "PLAYER_REGEN_DISABLED" then
						LeaPlusLC:Print("Monitoring FPS during combat...")
						fFrm:SetScript("OnUpdate", function()
							k = k + 1
							fTab[k] = GetFramerate()
						end)
						startTime = GetTime()
					else
						fFrm:SetScript("OnUpdate", nil)
						local tSum = 0
						for i = 1, #fTab do
							tSum = tSum + fTab[i]
						end
						local timeTaken = string.format("%.0f", GetTime() - startTime)
						if tSum > 0 then
							LeaPlusLC:Print("Average FPS for " .. timeTaken .. " seconds of combat: " .. string.format("%.0f", tSum / #fTab))
						end
					end
				end)
				return
			elseif str == "col" then
				-- Convert color values
				LeaPlusLC:Print("|n")
				local r, g, b = tonumber(arg1), tonumber(arg2), tonumber(arg3)
				if r and g and b then
					-- RGB source
					LeaPlusLC:Print("Source: |cffffffff" .. r .. " " .. g .. " " .. b .. " ")
					-- RGB to Hex
					if r > 1 and g > 1 and b > 1 then
						-- RGB to Hex
						LeaPlusLC:Print("Hex: |cffffffff" .. strupper(string.format("%02x%02x%02x", r, g, b)) .. " (from RGB)")
					else
						-- Wow to Hex
						LeaPlusLC:Print("Hex: |cffffffff" .. strupper(string.format("%02x%02x%02x", r * 255, g * 255, b * 255)) .. " (from Wow)")
						-- Wow to RGB
						local rwow = string.format("%.0f", r * 255)
						local gwow = string.format("%.0f", g * 255)
						local bwow = string.format("%.0f", b * 255)
						if rwow ~= "0.0" and gwow ~= "0.0" and bwow ~= "0.0" then
							LeaPlusLC:Print("RGB: |cffffffff" .. rwow .. " " .. gwow .. " " .. bwow .. " (from Wow)")
						end
					end
					-- RGB to Wow
					local rwow = string.format("%.1f", r / 255)
					local gwow = string.format("%.1f", g / 255)
					local bwow = string.format("%.1f", b / 255)
					if rwow ~= "0.0" and gwow ~= "0.0" and bwow ~= "0.0" then
						LeaPlusLC:Print("Wow: |cffffffff" .. rwow .. " " .. gwow .. " " .. bwow)
					end
					LeaPlusLC:Print("|n")
				elseif arg1 and strlen(arg1) == 6 and strmatch(arg1,"%x") and arg2 == nil and arg3 == nil then
					-- Hex source
					local rhex, ghex, bhex = string.sub(arg1, 1, 2), string.sub(arg1, 3, 4), string.sub(arg1, 5, 6)
					if strmatch(rhex,"%x") and strmatch(ghex,"%x") and strmatch(bhex,"%x") then
						LeaPlusLC:Print("Source: |cffffffff" .. strupper(arg1))
						LeaPlusLC:Print("Wow: |cffffffff" .. string.format("%.1f", tonumber(rhex, 16) / 255) ..  "  " .. string.format("%.1f", tonumber(ghex, 16) / 255) .. "  " .. string.format("%.1f", tonumber(bhex, 16) / 255))
						LeaPlusLC:Print("RGB: |cffffffff" .. tonumber(rhex, 16) .. "  " .. tonumber(ghex, 16) .. "  " .. tonumber(bhex, 16))
					else
						LeaPlusLC:Print("Invalid arguments.")
					end
					LeaPlusLC:Print("|n")
				else
					LeaPlusLC:Print("Invalid arguments.")
				end
				return
			elseif str == "click" then
				-- Click a button so a user can test if it is allowed (optional number of times to click)
				local mouseFoci = GetMouseFoci()
				if mouseFoci then
					local frame = mouseFoci[#mouseFoci]
					local ftype = frame:GetObjectType()
					if frame and ftype and ftype == "Button" then
						if arg1 and tonumber(arg1) > 1 and tonumber(arg1) < 1000 then
							for i =1, tonumber(arg1) do C_Timer.After(0.1 * i, function() frame:Click() end) end
						else
							frame:Click()
						end
					else
						LeaPlusLC:Print("Hover the pointer over a button.")
					end
					return
				end
			elseif str == "frame" then
				-- Print frame name under mouse
				local mouseFoci = GetMouseFoci()
				if mouseFoci then
					local frame = mouseFoci[#mouseFoci]
					local ftype = frame:GetObjectType()
					if frame and ftype then
						local fname = frame:GetName()
						local issecure, tainted = issecurevariable(fname)
						if issecure then issecure = "Yes" else issecure = "No" end
						if tainted then tainted = "Yes" else tainted = "No" end
						if fname then
							LeaPlusLC:Print("Name: |cffffffff" .. fname)
							LeaPlusLC:Print("Type: |cffffffff" .. ftype)
							LeaPlusLC:Print("Secure: |cffffffff" .. issecure)
							LeaPlusLC:Print("Tainted: |cffffffff" .. tainted)
						end
					end
				end
				return
			elseif str == "arrow" then
				-- Arrow (left: drag, shift/ctrl: rotate, mouseup: loc, pointer must be on arrow stem)
				local f = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
				f:SetSize(64, 64)
				f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				f:SetFrameLevel(500)
				f:SetParent(WorldMapFrame.ScrollContainer)
				f:SetScale(0.6)

				f.t = f:CreateTexture(nil, "ARTWORK")
				f.t:SetAtlas("Garr_LevelUpgradeArrow")
				f.t:SetAllPoints()

				f.f = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				f.f:SetText("0.0")

				local x = 0
				f:SetScript("OnUpdate", function()
					if IsShiftKeyDown() then
						x = x + 0.01
						if x > 6.3 then x = 0 end
						f.t:SetRotation(x)
						f.f:SetFormattedText("%.1f", x)
					elseif IsControlKeyDown() then
						x = x - 0.01
						if x < 0 then x = 6.3 end
						f.t:SetRotation(x)
						f.f:SetFormattedText("%.1f", x)
					end
					-- Print coordinates when mouse is in right place
					local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
					if x and y and x > 0 and y > 0 then
						if MouseIsOver(f, -31, 31, 31, -31) then
							ChatFrame1:Clear()
							print(('{"Arrow", ' .. floor(x * 1000 + 0.5) / 10) .. ',', (floor(y * 1000 + 0.5) / 10) .. ', L["Step 1"], L["Start here."], arTex, nil, nil, nil, nil, nil, ' .. f.f:GetText() .. "},")
							PlaySoundFile(567412, "Master", false, true)
						end
					end
				end)

				f:SetMovable(true)
				f:SetScript("OnMouseDown", function(self, btn)
					if btn == "LeftButton" then
						f:StartMoving()
					end
				end)

				f:SetScript("OnMouseUp", function()
					f:StopMovingOrSizing()
					--ChatFrame1:Clear()
					--local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
					--if x and y and x > 0 and y > 0 and MouseIsOver(f) then
					--	print(('{"Arrow", ' .. floor(x * 1000 + 0.5) / 10) .. ',', (floor(y * 1000 + 0.5) / 10) .. ', L["Step 1"], L["Start here."], ' .. f.f:GetText() .. "},")
					--end
				end)
				return
			elseif str == "dis" then
				-- Disband group
				if not LeaPlusLC:IsInLFGQueue() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
					local x = GetNumGroupMembers() or 0
					for i = x, 1, -1 do
						if GetNumGroupMembers() > 0 then
							local name = GetRaidRosterInfo(i)
							if name and name ~= UnitName("player") then
								C_PartyInfo.UninviteUnit(name)
							end
						end
					end
				else
					LeaPlusLC:Print("You cannot do that while in group finder.")
				end
				return
			elseif str == "reinv" then
				-- Disband and reinvite raid
				if not LeaPlusLC:IsInLFGQueue() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
					if UnitIsGroupLeader("player") then
						-- Disband
						local groupNames = {}
						local x = GetNumGroupMembers() or 0
						for i = x, 1, -1 do
							if GetNumGroupMembers() > 0 then
								local name = GetRaidRosterInfo(i)
								if name and name ~= UnitName("player") then
									C_PartyInfo.UninviteUnit(name)
									tinsert(groupNames, name)
								end
							end
						end
						-- Reinvite
						C_Timer.After(0.1, function()
							for k, v in pairs(groupNames) do
								C_PartyInfo.InviteUnit(v)
							end
						end)
					else
						LeaPlusLC:Print("You need to be group leader.")
					end
				else
					LeaPlusLC:Print("You cannot do that while in group finder.")
				end
				return
			elseif str == "limit" then
				-- Sound Limit
				if not LeaPlusLC.MuteFrame then
					-- Panel frame
					local frame = CreateFrame("FRAME", nil, UIParent)
					frame:SetSize(294, 86); frame:SetFrameStrata("FULLSCREEN_DIALOG"); frame:SetFrameLevel(100); frame:SetScale(2)
					frame.tex = frame:CreateTexture(nil, "BACKGROUND"); frame.tex:SetAllPoints(); frame.tex:SetColorTexture(0.05, 0.05, 0.05, 0.9)
					frame.close = LeaPlusLC:CreateCloseButton(frame, 30, 30, "TOPRIGHT", 0, 0)
					frame.close:SetScript("OnClick", function() frame:Hide() end)
					frame:ClearAllPoints(); frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					frame:SetClampedToScreen(true)
					frame:EnableMouse(true)
					frame:SetMovable(true)
					frame:RegisterForDrag("LeftButton")
					frame:SetScript("OnDragStart", frame.StartMoving)
					frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() frame:SetUserPlaced(false) end)
					frame:Hide()
					LeaPlusLC:CreateBar("MutePanelMainTexture", frame, 294, 86, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
					-- Panel contents
					LeaPlusLC:MakeTx(frame, "Sound Limit", 16, -12)
					local endBox = LeaPlusLC:CreateEditBox("SoundEndBox", frame, 116, 10, "TOPLEFT", 16, -32, "SoundEndBox", "SoundEndBox")
					endBox:SetText(9000000)
					endBox:SetScript("OnMouseWheel", function(self, delta)
						local endSound = tonumber(endBox:GetText())
						if endSound then
							if delta == 1 then endSound = endSound + LeaPlusLC.SoundByte else endSound = endSound - LeaPlusLC.SoundByte end
							if endSound < 1 then endSound = 1 elseif endSound >= 9000000 then endSound = 9000000 end
							endBox:SetText(endSound)
						else
							endSound = 100000
							endBox:SetText(endSound)
						end
					end)
					-- Set limit button
					frame.btn = LeaPlusLC:CreateButton("muteRangeButton", frame, "SET LIMIT", "TOPLEFT", 16, -72, 0, 25, true, "Click to set the sound file limit.  Use the mousewheel on the editbox along with the step buttons below to adjust the sound limit.  Acceptable range is from 1 to 9000000.  Sound files higher than this limit will be muted.")
					frame.btn:ClearAllPoints()
					frame.btn:SetPoint("LEFT", endBox, "RIGHT", 10, 0)
					frame.btn:SetScript("OnClick", function()
						local endSound = tonumber(endBox:GetText())
						if endSound then
							if endSound > 9000000 then endSound = 9000000 endBox:SetText(endSound) end
							frame.btn:SetText("WAIT")
							C_Timer.After(0.1, function()
								for i = 1, 9000000 do
									MuteSoundFile(i)
								end
								for i = 1, endSound do
									UnmuteSoundFile(i)
								end
								Sound_GameSystem_RestartSoundSystem()
								frame.btn:SetText("SET LIMIT")
							end)
						else
							frame.btn:SetText("INVALID")
							frame.btn:EnableMouse(false)
							C_Timer.After(2, function()
								frame.btn:SetText("SET LIMIT")
								frame.btn:EnableMouse(true)
							end)
						end
					end)
					-- Mute all button
					frame.MuteAllBtn = LeaPlusLC:CreateButton("muteMuteAllButton", frame, "MUTE ALL", "TOPLEFT", 16, -92, 0, 25, true, "Click to mute every sound in the game.")
					frame.MuteAllBtn:SetScale(0.5)
					frame.MuteAllBtn:ClearAllPoints()
					frame.MuteAllBtn:SetPoint("TOPLEFT", frame.btn, "TOPRIGHT", 20, 0)
					frame.MuteAllBtn:SetScript("OnClick", function()
						frame.MuteAllBtn:SetText("WAIT")
						C_Timer.After(0.1, function()
							for i = 1, 9000000 do
								MuteSoundFile(i)
							end
							Sound_GameSystem_RestartSoundSystem()
							frame.MuteAllBtn:SetText("MUTE ALL")
						end)
						return
					end)
					-- Unmute all button
					frame.UnmuteAllBtn = LeaPlusLC:CreateButton("muteUnmuteAllButton", frame, "UNMUTE ALL", "TOPLEFT", 16, -92, 0, 25, true, "Click to unmute every sound in the game.")
					frame.UnmuteAllBtn:SetScale(0.5)
					frame.UnmuteAllBtn:ClearAllPoints()
					frame.UnmuteAllBtn:SetPoint("TOPLEFT", frame.MuteAllBtn, "BOTTOMLEFT", 0, -10)
					frame.UnmuteAllBtn:SetScript("OnClick", function()
						frame.UnmuteAllBtn:SetText("WAIT")
						C_Timer.After(0.1, function()
							for i = 1, 9000000 do
								UnmuteSoundFile(i)
							end
							Sound_GameSystem_RestartSoundSystem()
							frame.UnmuteAllBtn:SetText("UNMUTE ALL")
						end)
						return
					end)
					-- Step buttons
					frame.millionBtn = LeaPlusLC:CreateButton("SoundMillionButton", frame, "1000000", "TOPLEFT", 26, -122, 0, 25, true, "Set the editbox step value to 1000000.")
					frame.millionBtn:SetScale(0.5)

					frame.hundredThousandBtn = LeaPlusLC:CreateButton("SoundHundredThousandButton", frame, "100000", "TOPLEFT", 16, -112, 0, 25, true, "Set the editbox step value to 100000.")
					frame.hundredThousandBtn:ClearAllPoints()
					frame.hundredThousandBtn:SetPoint("LEFT", frame.millionBtn, "RIGHT", 10, 0)
					frame.hundredThousandBtn:SetScale(0.5)

					frame.tenThousandBtn = LeaPlusLC:CreateButton("SoundTenThousandButton", frame, "10000", "TOPLEFT", 16, -112, 0, 25, true, "Set the editbox step value to 10000.")
					frame.tenThousandBtn:ClearAllPoints()
					frame.tenThousandBtn:SetPoint("LEFT", frame.hundredThousandBtn, "RIGHT", 10, 0)
					frame.tenThousandBtn:SetScale(0.5)

					frame.thousandBtn = LeaPlusLC:CreateButton("SoundThousandButton", frame, "1000", "TOPLEFT", 16, -112, 0, 25, true, "Set the editbox step value to 1000.")
					frame.thousandBtn:ClearAllPoints()
					frame.thousandBtn:SetPoint("LEFT", frame.tenThousandBtn, "RIGHT", 10, 0)
					frame.thousandBtn:SetScale(0.5)

					frame.hundredBtn = LeaPlusLC:CreateButton("SoundHundredButton", frame, "100", "TOPLEFT", 16, -112, 0, 25, true, "Set the editbox step value to 100.")
					frame.hundredBtn:ClearAllPoints()
					frame.hundredBtn:SetPoint("LEFT", frame.thousandBtn, "RIGHT", 10, 0)
					frame.hundredBtn:SetScale(0.5)

					frame.tenBtn = LeaPlusLC:CreateButton("SoundTenButton", frame, "10", "TOPLEFT", 16, -112, 0, 25, true, "Set the editbox step value to 10.")
					frame.tenBtn:ClearAllPoints()
					frame.tenBtn:SetPoint("LEFT", frame.hundredBtn, "RIGHT", 10, 0)
					frame.tenBtn:SetScale(0.5)

					frame.oneBtn = LeaPlusLC:CreateButton("SoundTenButton", frame, "1", "TOPLEFT", 16, -112, 0, 25, true, "Set the editbox step value to 1.")
					frame.oneBtn:ClearAllPoints()
					frame.oneBtn:SetPoint("LEFT", frame.tenBtn, "RIGHT", 10, 0)
					frame.oneBtn:SetScale(0.5)

					local function DimAllBoxes()
						frame.millionBtn:SetAlpha(0.3)
						frame.hundredThousandBtn:SetAlpha(0.3)
						frame.tenThousandBtn:SetAlpha(0.3)
						frame.thousandBtn:SetAlpha(0.3)
						frame.hundredBtn:SetAlpha(0.3)
						frame.tenBtn:SetAlpha(0.3)
						frame.oneBtn:SetAlpha(0.3)
					end

					LeaPlusLC.SoundByte = 1000000
					DimAllBoxes()
					frame.millionBtn:SetAlpha(1)

					-- Step button handlers
					frame.millionBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 1000000
						DimAllBoxes()
						frame.millionBtn:SetAlpha(1)
					end)

					frame.hundredThousandBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 100000
						DimAllBoxes()
						frame.hundredThousandBtn:SetAlpha(1)
					end)

					frame.tenThousandBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 10000
						DimAllBoxes()
						frame.tenThousandBtn:SetAlpha(1)
					end)

					frame.thousandBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 1000
						DimAllBoxes()
						frame.thousandBtn:SetAlpha(1)
					end)

					frame.hundredBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 100
						DimAllBoxes()
						frame.hundredBtn:SetAlpha(1)
					end)

					frame.tenBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 10
						DimAllBoxes()
						frame.tenBtn:SetAlpha(1)
					end)

					frame.oneBtn:SetScript("OnClick", function()
						LeaPlusLC.SoundByte = 1
						DimAllBoxes()
						frame.oneBtn:SetAlpha(1)
					end)

					-- Final code
					LeaPlusLC.MuteFrame = frame
					_G["LeaPlusGlobalMutePanel"] = frame
					table.insert(UISpecialFrames, "LeaPlusGlobalMutePanel")
				end
				if LeaPlusLC.MuteFrame:IsShown() then LeaPlusLC.MuteFrame:Hide() else LeaPlusLC.MuteFrame:Show() end
				return
			elseif str == "tz" then
				-- Tazavesh Helper
				if arg1 and arg ~= "" then
					-- Aggramar's Vault
					if not string.find(arg1, "o") or not string.find(arg1, "y") or not string.find(arg1, "p") or not string.find(arg1, "b") then
						LeaPlusLC:Print("Valid letters are O (Orange), Y (Yellow), P (Purple), B (Blue).")
						return
					end
					arg1 = arg1:gsub("%w", {["o"] = "ORANGE,", ["y"] = "YELLOW,", ["p"] = "PURPLE,", ["b"] = "BLUE,"})
					local a, b, c, d = arg1:match("([^,]+),([^,]+),([^,]+),([^,]+)")
					if a and b and c and d then
						local chatDestination
						if IsInRaid() then
							return
						elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
							chatDestination = "INSTANCE_CHAT"
						elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
							chatDestination = "PARTY"
						end
						LeaPlusLC:Print("Letters need to be in clockwise order as they appear.")
						C_ChatInfo.SendChatMessage("Quickly take orbs to these positions and click.", chatDestination)
						C_ChatInfo.SendChatMessage(a .. ": Front left of boss (north)", chatDestination)
						C_ChatInfo.SendChatMessage(b .. ": Front right of boss (east)", chatDestination)
						C_ChatInfo.SendChatMessage(d .. ": Back left of boss (west)", chatDestination)
						C_ChatInfo.SendChatMessage(c .. ": Back right of boss (south)", chatDestination)
					end
					return
				end
				-- Myza's Oasis
				local target
				if not C_Secrets.ShouldAurasBeSecret() then
					for i = 1, 40 do
						local DebuffData = C_UnitAuras.GetDebuffDataByIndex("player", i)
						if DebuffData then
							local spellID = DebuffData.spellId
							if spellID then
								if spellID == 352125 or spellID == 358911 or spellID == 358912 then
									target = "Xy'ghana"
								elseif spellID == 352127 or spellID == 358905 or spellID == 358906 then
									target = "Xy'aqida"
								elseif spellID == 352128 or spellID == 358907 or spellID == 358908 then
									target = "Xy'tadir"
								elseif spellID == 352129 or spellID == 358915 or spellID == 358916 then
									target = "Xy'nara"
								elseif spellID == 352130 or spellID == 358900 or spellID == 358901 then
									target = "Xy'mal"
								elseif spellID == 352131 or spellID == 358917 or spellID == 358918 then
									target = "Xy'jahid"
								elseif spellID == 352132 or spellID == 358903 or spellID == 358904 then
									target = "Xy'kitaab"
								elseif spellID == 352133 or spellID == 358913 or spellID == 358914 then
									target = "Xy'har"
								elseif spellID == 352134 or spellID == 358909 or spellID == 358910 then
									target = "Xy'zaro"
								-- elseif spellID == 15007 then target = "Ghost" -- Resurrection sickness (debug)
								end
							end
						end
					end
					if target and target ~= "" then
						LeaPlusLC:ShowSystemEditBox("/tar" .. " " .. target, true)
						LeaPlusLC.FactoryEditBox.f:SetText(L["Myza's Oasis"] .. ": " .. target)
					end
				end
				return
			elseif str == "mem" or str == "m" then
				-- Show addon panel with memory usage
				if LeaPlusLC.ShowMemoryUsage then
					LeaPlusLC:ShowMemoryUsage(LeaPlusLC["Page8"], "TOPLEFT", 146, -262)
				end
				-- Prevent options panel from showing if Blizzard Store is showing
				if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
				-- Toggle the options panel if game options panel is not showing
				if LeaPlusLC:IsPlusShowing() then
					LeaPlusLC:HideFrames()
					LeaPlusLC:HideConfigPanels()
				else
					LeaPlusLC:HideFrames()
					LeaPlusLC["PageF"]:Show()
				end
				LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
				return
			elseif str == "gossinfo" then
				-- Print gossip frame information
				if GossipFrame:IsShown() then
					local npcName = UnitName("npc")
					local npcGuid = UnitGUID("npc") or nil
					if npcName and npcGuid then
						local void, void, void, void, void, npcID = strsplit("-", npcGuid)
						if npcID then
							LeaPlusLC:Print(npcName .. ": |cffffffff" .. npcID)
						end
					end
					LeaPlusLC:Print("Available quests: |cffffffff" .. C_GossipInfo.GetNumAvailableQuests())
					LeaPlusLC:Print("Active quests: |cffffffff" .. C_GossipInfo.GetNumActiveQuests())
					local gossipInfoTable = C_GossipInfo.GetOptions()
					if gossipInfoTable and gossipInfoTable[1] and gossipInfoTable[1].name then
						LeaPlusLC:Print("Gossip count: |cffffffff" .. #gossipInfoTable)
						LeaPlusLC:Print("Gossip name: |cffffffff" .. gossipInfoTable[1].name)
					else
						LeaPlusLC:Print("Gossip info: |cffffffff" .. "Nil")
					end
					if GossipTitleButton1 and GossipTitleButton1:GetText() then
						LeaPlusLC:Print("First option: |cffffffff" .. GossipTitleButton1:GetText())
					end
					-- LeaPlusLC:Print("Gossip text: |cffffffff" .. GetGossipText())
					if not IsShiftKeyDown() then
						SelectGossipOption(1)
					end
				else
					LeaPlusLC:Print("Gossip frame not open.")
				end
				return
			elseif str == "traits" then
				-- Set dragonriding traits
				if C_AddOns.IsAddOnLoaded("Blizzard_GenericTraitUI") and GenericTraitFrame:IsShown() then
					local c = C_Traits.GetConfigIDBySystemID(1)
					for count = 1, 10 do
						for i, n in ipairs(C_Traits.GetTreeNodes(672)) do
							local f = C_Traits.GetNodeInfo(c, n)
							if #f.entryIDs < 2 then
								-- One trait only
								C_Traits.PurchaseRank(c, n)
							else
								-- Two trait choices
								C_Traits.SetSelection(c, n, f.entryIDs[2]) -- 1 for left-side trait, 2 for right-side trait
							end
						end
					end
					-- Save changes
					C_Traits.CommitConfig(c)
					-- Reload to clear everything
					ReloadUI()
				else
					LeaPlusLC:Print("Open the dragonriding trait frame first!")
				end
				return
			elseif str == "talents" or str == "tal" then
				-- Ensure the talents window is loaded
				if not PlayerSpellsFrame then
					LeaPlusLC:Print("Open the talents window first.")
					return
				end
				-- Get player class
				local void, class = UnitClass("player")
				local importStream
				if class == "PALADIN" then
					importStream = ExportUtil.MakeImportDataStream("BIEAomTTpSA9oX6huYLb5nP3r3iWSi2BSIlkIlWLRCJkIBAAIAAAAAAAgikkkQiQCRgWiAAAAABBA")
				elseif class == "WARLOCK" then
					importStream = ExportUtil.MakeImportDataStream("BsQAj5LiEN4VXhSin5RcWeAUgoIhIJSCBBkSSSCFQS0SSItkEEAAAAAAAAAAAAIEaJJJA")
				elseif class == "PRIEST" then
					importStream = ExportUtil.MakeImportDataStream("BEQA/KVNHBYFUG61hTBXiMbcYCAAAAAAAokCCkQEJhkkkSUSoEAAAAAl0IkEJgSSSSQISCBlAA")
				else
					return
				end
				-- Delete the loadout called Mine
				local activeSpecID = C_SpecializationInfo.GetSpecialization()
				local specID = C_SpecializationInfo.GetSpecializationInfo(activeSpecID)
				local configs = C_ClassTalents.GetConfigIDsBySpecID(specID)
				for void, configID in ipairs(configs) do
					local configInfo = C_Traits.GetConfigInfo(configID)
					if configInfo.name == "Mine" then
						C_ClassTalents.DeleteConfig(configID)
					end
				end
				-- Create a new loadout called Mine
				local headerValid, serializationVersion, specID, treeHash = PlayerSpellsFrame.TalentsFrame:ReadLoadoutHeader(importStream)

				local treeInfo = PlayerSpellsFrame.TalentsFrame:GetTreeInfo()
				local configID = PlayerSpellsFrame.TalentsFrame:GetConfigID()

				local loadoutContent = PlayerSpellsFrame.TalentsFrame:ReadLoadoutContent(importStream, treeInfo.ID)
				local loadoutEntryInfo = PlayerSpellsFrame.TalentsFrame:ConvertToImportLoadoutEntryInfo(configID, treeInfo.ID, loadoutContent)

				local newConfigHasPurchasedRanks = #loadoutEntryInfo > 0
				local configInfo = C_Traits.GetConfigInfo(configID)
				local success, errorString = C_ClassTalents.ImportLoadout(configID, loadoutEntryInfo, "Mine")
				PlayerSpellsFrame.TalentsFrame:OnTraitConfigCreateStarted(newConfigHasPurchasedRanks)
				-- Add reload button
				if not LeaPlusLC.TalentsReloadButton then
					local reloadButton = LeaPlusLC:CreateButton("TalentsReloadButton", PlayerSpellsFrame.TalentsFrame, ">>> RELOAD <<<", "BOTTOM", 0, 10, 200, 45, true, "")
					reloadButton:ClearAllPoints()
					reloadButton:SetPoint("LEFT", PlayerSpellsFrame.TalentsFrame.ResetButton, "RIGHT", 60, -4)
					reloadButton:SetScript("OnClick", ReloadUI)
					reloadButton:Hide(); reloadButton:Show()
					LeaPlusLC.TalentsReloadButton = reloadButton
				end
				return
			elseif str == "svars" then
				-- Print saved variables
				LeaPlusLC:Print(L["Saved Variables"] .. "|n")
				LeaPlusLC:Print(L["The following list shows option label, setting name and currently saved value.  Enable |cffffffffIncrease chat history|r (chat) and |cffffffffRecent chat window|r (chat) to make it easier."] .. "|n")
				LeaPlusLC:Print(L["Modifying saved variables must start with |cffffffff/ltp nosave|r to prevent your changes from being reverted during reload or logout."] .. "|n")
				LeaPlusLC:Print(L['Syntax is |cffffffff/run LeaPlusDB[' .. '"' .. 'setting name' .. '"' .. '] = ' .. '"' .. 'value' .. '" |r(case sensitive).'])
				LeaPlusLC:Print(L["When done, |cffffffff/reload|r to save your changes."] .. "|n")
				-- Checkboxes
				LeaPlusLC:Print(L["Checkboxes"] .. "|n")
				LeaPlusLC:Print(L["Checkboxes can be set to On or Off."] .. "|n")
				for key, value in pairs(LeaPlusDB) do
					if LeaPlusCB[key] and LeaPlusCB[key].f then
						if LeaPlusCB[key]:GetObjectType() ~= "Slider" and LeaPlusCB[key]:GetObjectType() ~= "Button" then
							LeaPlusLC:Print(string.gsub(LeaPlusCB[key].f:GetText(), "%*$", "") .. ": |cffffffff" .. key .. "|r |cff1eff0c(" .. value .. ")|r")
						end
					end
				end
				-- Sliders
				LeaPlusLC:Print("|n" .. L["Sliders"] .. "|n")
				LeaPlusLC:Print(L["Sliders can be set to a numeric value which must be in the range supported by the slider."] .. "|n")
				for key, value in pairs(LeaPlusDB) do
					if LeaPlusCB[key] and LeaPlusCB[key].f then
						if LeaPlusCB[key]:GetObjectType() == "Slider" then
							LeaPlusLC:Print("Slider: " .. "|cffffffff" .. key .. "|r |cff1eff0c(" .. value .. ")|r" .. " (" .. string.gsub(LeaPlusCB[key].f:GetText(), "%*$", "") .. ")" )
						end
					end
				end
				-- Dropdowns
				LeaPlusLC:Print("|n" .. L["Dropdowns"] .. "|n")
				LeaPlusLC:Print(L["Dropdowns can be set to a numeric value which must be in the range supported by the dropdown."] .. "|n")
				for key, value in pairs(LeaPlusDB) do
					if LeaPlusCB[key] and LeaPlusCB[key]:GetObjectType() == "Button" and LeaPlusLC[key] then
						LeaPlusLC:Print("Dropdown: " .. "|cffffffff" .. key .. "|r |cff1eff0c(" .. value .. ")|r")
					end
				end
				return
			elseif str == "tags" then
				-- Print open menu tags (such as dropdown menus)
				Menu.PrintOpenMenuTags()
				return
			elseif str == "editmode" then
				-- Open Edit Mode (useful for new player experience)
				if not LeaPlusLC:PlayerInCombat() then
					RunScript('ShowUIPanel(EditModeManagerFrame)')
				end
				return
			elseif str == "taintmap" then
				-- TaintMap
				if LeaPlusLC.TaintMap then
					LeaPlusLC.TaintMap:Cancel()
					LeaPlusLC.TaintMap = nil
					LeaPlusLC:Print("TaintMap stopped.")
					return
				end
				LeaPlusLC.TaintMap = C_Timer.NewTicker(1, function()
					for k,v in pairs(WorldMapFrame) do
						local ok, who = issecurevariable(WorldMapFrame, k)
						if not ok then
							print("Tainted:", k, "by", who or "unknown")
						end
					end
				end)
				LeaPlusLC:Print("TaintMap started.")
				return
			elseif str == "forced" then
				-- Enable all addon restrictions
				-- Example: /run ChatFrame1:SetMaxLines(4096) and whisper yourself
				SetCVar("addonMapRestrictionsForced", "1")
				SetCVar("addonChatRestrictionsForced", "1")
				SetCVar("addonCombatRestrictionsForced", "1")
				SetCVar("addonPvPMatchRestrictionsForced", "1")
				SetCVar("addonEncounterRestrictionsForced", "1")
				SetCVar("addonChallengeModeRestrictionsForced", "1")
				LeaPlusLC:Print("Addon restrictions are now enforced.")
				return
			elseif str == "unforced" then
				-- Remove all addon restrictions
				SetCVar("addonMapRestrictionsForced", "0")
				SetCVar("addonChatRestrictionsForced", "0")
				SetCVar("addonCombatRestrictionsForced", "0")
				SetCVar("addonPvPMatchRestrictionsForced", "0")
				SetCVar("addonEncounterRestrictionsForced", "0")
				SetCVar("addonChallengeModeRestrictionsForced", "0")
				LeaPlusLC:Print("Addon restrictions are no longer enforced.")
				return
			elseif str == "checkglobal" then
				-- Print global frame names created by the addon
				local c = 0
				for k, v in pairs(_G) do
					if type(k) == "string" and type(v) == "table" then
						local void, a = issecurevariable(k)
						if a == "Leatrix_Plus" then
							c = c + 1
							print(k)
						end
					end
				end
				print(c,"global tables/frames")
				return
			elseif str == "admin" then
				-- Preset profile (used for testing)
				LpEvt:UnregisterAllEvents()						-- Prevent changes
				wipe(LeaPlusDB)									-- Wipe settings
				LeaPlusLC:PlayerLogout(true)					-- Reset permanent settings
				-- Automation
				LeaPlusDB["AutomateQuests"] = "On"				-- Automate quests
				LeaPlusDB["AutoQuestShift"] = "Off"				-- Automate quests requires shift
				LeaPlusDB["AutoQuestRegular"] = "On"			-- Accept regular quests
				LeaPlusDB["AutoQuestDaily"] = "On"				-- Accept daily quests
				LeaPlusDB["AutoQuestWeekly"] = "On"				-- Accept weekly quests
				LeaPlusDB["AutoQuestCompleted"] = "On"			-- Turn-in completed quests
				LeaPlusDB["AutoQuestKeyMenu"] = 1				-- Automate quests override key
				LeaPlusDB["AutomateGossip"] = "On"				-- Automate gossip
				LeaPlusDB["AutoAcceptSummon"] = "On"			-- Accept summon
				LeaPlusDB["AutoAcceptRes"] = "On"				-- Accept resurrection
				LeaPlusDB["AutoReleasePvP"] = "On"				-- Release in PvP
				LeaPlusDB["AutoSellJunk"] = "On"				-- Sell junk automatically
				LeaPlusDB["AutoSellExcludeList"] = ""			-- Sell junk exclusions list
				LeaPlusDB["AutoRepairGear"] = "On"				-- Repair automatically

				-- Social
				LeaPlusDB["NoDuelRequests"] = "On"				-- Block duels
				LeaPlusDB["NoPetDuels"] = "On"					-- Block pet battle duels
				LeaPlusDB["NoPartyInvites"] = "Off"				-- Block party invites
				LeaPlusDB["NoRequestedInvites"] = "Off"			-- Block requested invites
				LeaPlusDB["NoFriendRequests"] = "Off"			-- Block friend requests
				LeaPlusDB["NoSharedQuests"] = "Off"				-- Block shared quests

				LeaPlusDB["AcceptPartyFriends"] = "On"			-- Party from friends
				LeaPlusDB["SyncFromFriends"] = "On"				-- Sync from friends
				LeaPlusDB["AutoConfirmRole"] = "On"				-- Queue from friends
				LeaPlusDB["InviteFromWhisper"] = "On"			-- Invite from whispers
				LeaPlusDB["InviteFriendsOnly"] = "On"			-- Restrict invites to friends
				LeaPlusDB["FriendlyCommunities"] = "On"			-- Friendly communities
				LeaPlusDB["FriendlyGuild"] = "On"				-- Friendly guild

				-- Chat
				LeaPlusDB["UseEasyChatResizing"] = "On"			-- Use easy resizing
				LeaPlusDB["NoCombatLogTab"] = "On"				-- Hide the combat log
				LeaPlusDB["NoChatButtons"] = "On"				-- Hide chat buttons
				LeaPlusDB["ShowVoiceButtons"] = "On"			-- Show voice buttons
				LeaPlusDB["ShowChatMenuButton"] = "Off"			-- Show chat menu button
				LeaPlusDB["NoSocialButton"] = "On"				-- Hide social button
				LeaPlusDB["UnclampChat"] = "On"					-- Unclamp chat frame
				LeaPlusDB["MoveChatEditBoxToTop"] = "On"		-- Move editbox to top
				LeaPlusDB["MoreChatFontSizes"] = "On"			-- More chat font sizes

				LeaPlusDB["NoStickyChat"] = "On"				-- Disable sticky chat
				LeaPlusDB["UseArrowKeysInChat"] = "On"			-- Use arrow keys in chat
				LeaPlusDB["NoChatFade"] = "On"					-- Disable chat fade
				LeaPlusDB["UnivGroupColor"] = "On"				-- Universal group color
				LeaPlusDB["RecentChatWindow"] = "On"			-- Recent chat window
				LeaPlusDB["RecentChatSize"] = 170				-- Recent chat size
				LeaPlusDB["FilterChatMessages"] = "On"			-- Filter chat messages
				LeaPlusDB["BlockSpellLinks"] = "On"				-- Block spell links
				LeaPlusDB["BlockDrunkenSpam"] = "On"			-- Block drunken spam
				LeaPlusDB["BlockDuelSpam"] = "On"				-- Block duel spam
				LeaPlusDB["BlockAngelisSinny"] = "On"			-- Block Angelis and Sinny spam
				LeaPlusDB["RestoreChatMessages"] = "On"			-- Restore chat messages

				-- Text
				LeaPlusDB["HideErrorMessages"] = "On"			-- Hide error messages
				LeaPlusDB["NoHitIndicators"] = "On"				-- Hide portrait numbers
				LeaPlusDB["HideKeybindText"] = "On"				-- Hide keybind text
				LeaPlusDB["HideMacroText"] = "On"				-- Hide macro text

				LeaPlusDB["QuestFontChange"] = "On"				-- Resize quest text
				LeaPlusDB["LeaPlusQuestFontSize"] = 18			-- Quest font size

				-- Interface
				LeaPlusDB["MinimapModder"] = "On"				-- Enhance minimap
				LeaPlusDB["SquareMinimap"] = "On"				-- Square minimap
				LeaPlusDB["HideMiniAddonMenu"] = "On"			-- Hide addon menu
				LeaPlusDB["UnclampMinimap"] = "On"				-- Unclamp minimap cluster
				LeaPlusDB["MinimapButtonBag"] = "On"			-- Minimap button bag
				LeaPlusDB["MiniExcludeList"] = "BugSack, Leatrix_Plus" -- Excluded addon list
				LeaPlusDB["MinimapBorderWidth"] = 3				-- Minimap border width
				LeaPlusDB["MiniClusterScale"] = 1				-- Minimap cluster scale
				LeaPlusDB["MinimapEffect"] = 1					-- Minimap effect

				LeaPlusDB["TipModEnable"] = "On"				-- Enhance tooltip
				LeaPlusDB["TipBackSimple"] = "On"				-- Color backdrops
				LeaPlusDB["LeaPlusTipSize"] = 1.25				-- Tooltip scale slider
				LeaPlusDB["TooltipAnchorMenu"] = 1				-- Tooltip anchor
				LeaPlusDB["TipCursorX"] = 0						-- X offset
				LeaPlusDB["TipCursorY"] = 0						-- Y offset
				LeaPlusDB["EnhanceDressup"] = "On"				-- Enhance dressup
				LeaPlusDB["DressupMoreZoomOut"] = "Off"			-- Enhance dressup increase zoom out distance
				LeaPlusDB["DressupTransmogAnim"] = "Off"		-- Enhance dressup transmogrify animation control
				LeaPlusDB["DressupFasterZoom"] = 3				-- Dressup zoom speed
				LeaPlusDB["ShowVolume"] = "On"					-- Show volume slider
				LeaPlusDB["DurabilityStatus"] = "On"			-- Show durability status
				LeaPlusDB["ShowPetSaveBtn"] = "On"				-- Show pet save button
				LeaPlusDB["ShowRaidToggle"] = "On"				-- Show raid toggle button
				LeaPlusDB["ShowTrainAllButton"] = "On"			-- Show train all button
				LeaPlusDB["ShowBorders"] = "On"					-- Show borders
				LeaPlusDB["ShowPlayerChain"] = "On"				-- Show player chain
				LeaPlusDB["PlayerChainMenu"] = 1				-- Player chain style
				LeaPlusDB["ShowReadyTimer"] = "On"				-- Show ready timer
				LeaPlusDB["ShowRangeColoring"] = "On"			-- Show range coloring
				LeaPlusDB["ShowInfoCards"] = "On"				-- Show info cards
				LeaPlusDB["InfoCardKey"] = "CTRL-A"				-- Info card key
				LeaPlusDB["ShowWowheadLinks"] = "On"			-- Show Wowhead links
				LeaPlusDB["WowheadLinkComments"] = "On"			-- Show Wowhead links to comments

				-- Interface: Manage frames
				LeaPlusDB["ManageWidgetTop"] = "On"				-- Manage widget top
				LeaPlusDB["WidgetTopA"] = "TOP"					-- Manage widget top anchor
				LeaPlusDB["WidgetTopR"] = "TOP"					-- Manage widget top relative
				LeaPlusDB["WidgetTopX"] = 0						-- Manage widget top position X
				LeaPlusDB["WidgetTopY"] = -432					-- Manage widget top position Y
				LeaPlusDB["WidgetTopScale"] = 1.25				-- Manage widget top scale

				LeaPlusDB["ClassColFrames"] = "On"				-- Class colored frames

				LeaPlusDB["NoAlerts"] = "On"					-- Hide alerts
				LeaPlusDB["HideBodyguard"] = "On"				-- Hide bodyguard window
				LeaPlusDB["HideTalkingFrame"] = "On"			-- Hide talking frame
				LeaPlusDB["HideCleanupBtns"] = "On"				-- Hide cleanup buttons
				LeaPlusDB["HideBossBanner"] = "On"				-- Hide boss banner
				LeaPlusDB["HideEventToasts"] = "On"				-- Hide event toasts
				LeaPlusDB["NoClassBar"] = "On"					-- Hide stance bar
				LeaPlusDB["NoRestedSleep"] = "On"				-- Hide rested sleep

				-- System
				LeaPlusDB["NoScreenGlow"] = "On"				-- Disable screen glow
				LeaPlusDB["NoScreenEffects"] = "On"				-- Disable screen effects
				LeaPlusDB["SetWeatherDensity"] = "On"			-- Set weather density
				LeaPlusDB["WeatherLevel"] = 0					-- Weather density level
				LeaPlusDB["MaxCameraZoom"] = "On"				-- Max camera zoom
				LeaPlusDB["NoRestedEmotes"] = "On"				-- Silence rested emotes
				LeaPlusDB["KeepAudioSynced"] = "On"				-- Keep audio synced
				LeaPlusDB["MuteGameSounds"] = "On"				-- Mute game sounds
				LeaPlusDB["MuteMountSounds"] = "On"				-- Mute mount sounds
				LeaPlusDB["MuteCustomSounds"] = "On"			-- Mute custom sounds
				LeaPlusDB["MuteCustomList"] = ""				-- Mute custom sounds list

				LeaPlusDB["NoPetAutomation"] = "On"				-- Disable pet automation
				LeaPlusDB["NoRaidRestrictions"] = "On"			-- Remove raid restrictions
				LeaPlusDB["NoConfirmLoot"] = "On"				-- Disable loot warnings
				LeaPlusDB["FasterLooting"] = "On"				-- Faster auto loot
				LeaPlusDB["LeaPlusFasterLootDelay"] = 0.3		-- Faster loot delay

				LeaPlusDB["FasterMovieSkip"] = "On"				-- Faster movie skip
				LeaPlusDB["CombatPlates"] = "On"				-- Combat plates
				LeaPlusDB["EasyItemDestroy"] = "On"				-- Easy item destroy
				LeaPlusDB["NoTransforms"] = "On"				-- Remove transforms

				LeaPlusDB["SetEditModeLayout"] = "On"			-- Set edit mode layout
				LeaPlusDB["EditModeLayoutName"] = "Main"		-- Edit mode layout name
				LeaPlusDB["SimpleAddonListing"] = "On"			-- Simple addon listing
				LeaPlusDB["HideStarterTutorials"] = "On"		-- Hide starter tutorials

				-- Mute game sounds (LeaPlusLC["MuteGameSounds"])
				for k, v in pairs(LeaPlusLC["muteTable"]) do
					LeaPlusDB[k] = "On"
				end
				LeaPlusDB["MuteReady"] = "Off"	-- Mute ready check
				LeaPlusDB["MuteVigor"] = "Off"	-- Mute vigor

				-- Mute mount sounds (LeaPlusLC["MuteMountSounds"])
				for k, v in pairs(LeaPlusLC["mountTable"]) do
					LeaPlusDB[k] = "On"
				end

				-- Remove transforms (LeaPlusLC["NoTransforms"])
				for k, v in pairs(LeaPlusLC["transTable"]) do
					LeaPlusDB[k] = "On"
				end

				-- Set chat font sizes
				for i = 1, 50 do if _G["ChatFrame" .. i] then FCF_SetChatWindowFontSize(self, _G["ChatFrame" .. i], 18) end end

				-- Reload
				ReloadUI()
			else
				LeaPlusLC:Print("Invalid parameter.")
			end
			return
		else
			-- Prevent options panel from showing if Blizzard Store is showing
			if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
			-- Toggle the options panel if game options panel is not showing
			if LeaPlusLC:IsPlusShowing() then
				LeaPlusLC:HideFrames()
				LeaPlusLC:HideConfigPanels()
			else
				LeaPlusLC:HideFrames()
				LeaPlusLC["PageF"]:Show()
			end
			LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
		end
	end

	-- Slash command for global function
	_G.SLASH_Leatrix_Plus1 = "/ltp"
	_G.SLASH_Leatrix_Plus2 = "/leaplus"

	SlashCmdList["Leatrix_Plus"] = function(self)
		-- Run slash command function
		LeaPlusLC:SlashFunc(self)
	end

	-- Slash command for UI reload
	_G.SLASH_LEATRIX_PLUS_RL1 = "/rl"
	SlashCmdList["LEATRIX_PLUS_RL"] = function()
		ReloadUI()
	end

----------------------------------------------------------------------
-- 	L90: Create options panel pages (no content yet)
----------------------------------------------------------------------

	-- Function to add menu button
	function LeaPlusLC:MakeMN(name, text, parent, anchor, x, y, width, height)

		local mbtn = CreateFrame("Button", nil, parent)
		LeaPlusLC[name] = mbtn
		mbtn:Show();
		mbtn:SetSize(width, height)
		mbtn:SetAlpha(1.0)
		mbtn:SetPoint(anchor, x, y)

		mbtn.t = mbtn:CreateTexture(nil, "BACKGROUND")
		mbtn.t:SetAllPoints()
		mbtn.t:SetColorTexture(0.3, 0.3, 0.00, 0.8)
		mbtn.t:SetAlpha(0.7)
		mbtn.t:Hide()

		mbtn.s = mbtn:CreateTexture(nil, "BACKGROUND")
		mbtn.s:SetAllPoints()
		mbtn.s:SetColorTexture(0.3, 0.3, 0.00, 0.8)
		mbtn.s:Hide()

		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetPoint('LEFT', 16, 0)
		mbtn.f:SetText(L[text])

		mbtn:SetScript("OnEnter", function()
			mbtn.t:Show()
		end)

		mbtn:SetScript("OnLeave", function()
			mbtn.t:Hide()
		end)

		return mbtn, mbtn.s

	end

	-- Function to create individual options panel pages
	function LeaPlusLC:MakePage(name, title, menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)

		-- Create frame
		local oPage = CreateFrame("Frame", nil, LeaPlusLC["PageF"])
		LeaPlusLC[name] = oPage
		oPage:SetAllPoints(LeaPlusLC["PageF"])
		oPage:Hide()

		-- Add page title
		oPage.s = oPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		oPage.s:SetPoint('TOPLEFT', 146, -16)
		oPage.s:SetText(L[title])

		-- Add menu item if needed
		if menu then
			LeaPlusLC[menu], LeaPlusLC[menu .. ".s"] = LeaPlusLC:MakeMN(menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)
			LeaPlusLC[name]:SetScript("OnShow", function() LeaPlusLC[menu .. ".s"]:Show(); end)
			LeaPlusLC[name]:SetScript("OnHide", function() LeaPlusLC[menu .. ".s"]:Hide(); end)
		end

		return oPage

	end

	-- Create options pages
	LeaPlusLC["Page0"] = LeaPlusLC:MakePage("Page0", "Home"			, "LeaPlusNav0", "Home"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -72, 112, 20)
	LeaPlusLC["Page1"] = LeaPlusLC:MakePage("Page1", "Automation"	, "LeaPlusNav1", "Automation"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -112, 112, 20)
	LeaPlusLC["Page2"] = LeaPlusLC:MakePage("Page2", "Social"		, "LeaPlusNav2", "Social"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -132, 112, 20)
	LeaPlusLC["Page3"] = LeaPlusLC:MakePage("Page3", "Chat"			, "LeaPlusNav3", "Chat"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -152, 112, 20)
	LeaPlusLC["Page4"] = LeaPlusLC:MakePage("Page4", "Text"			, "LeaPlusNav4", "Text"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -172, 112, 20)
	LeaPlusLC["Page5"] = LeaPlusLC:MakePage("Page5", "Interface"	, "LeaPlusNav5", "Interface"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -192, 112, 20)
	LeaPlusLC["Page6"] = LeaPlusLC:MakePage("Page6", "Frames"		, "LeaPlusNav6", "Frames"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -212, 112, 20)
	LeaPlusLC["Page7"] = LeaPlusLC:MakePage("Page7", "System"		, "LeaPlusNav7", "System"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -232, 112, 20)
	LeaPlusLC["Page8"] = LeaPlusLC:MakePage("Page8", "Settings"		, "LeaPlusNav8", "Settings"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -272, 112, 20)
	LeaPlusLC["Page9"] = LeaPlusLC:MakePage("Page9", "Media"		, "LeaPlusNav9", "Media"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -292, 112, 20)

	-- Page navigation mechanism
	for i = 0, LeaPlusLC["NumberOfPages"] do
		LeaPlusLC["LeaPlusNav"..i]:SetScript("OnClick", function()
			LeaPlusLC:HideFrames()
			LeaPlusLC["PageF"]:Show()
			LeaPlusLC["Page"..i]:Show()
			LeaPlusLC["LeaStartPage"] = i
		end)
	end

	----------------------------------------------------------------------
	-- 	Options search
	----------------------------------------------------------------------

	do

		local PageF = LeaPlusLC["PageF"]
		local numPages = LeaPlusLC["NumberOfPages"]
		local rowHeight = 20
		local cogTip = L["Click to configure the settings for this option."]

		----------------------------------------------------------------------
		-- Results page
		----------------------------------------------------------------------

		local results = CreateFrame("Frame", nil, PageF)
		results:SetAllPoints(PageF)
		results:Hide()

		-- Page title and result count
		results.s = results:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		results.s:SetPoint("TOPLEFT", 146, -16)
		results.s:SetText(L["Search results"])

		results.c = results:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		results.c:SetPoint("TOPLEFT", PageF.v, "TOPLEFT", 130, 0)
		results.c:SetJustifyH("LEFT")

		-- Hide results when any options page is shown
		for i = 0, numPages do
			if LeaPlusLC["Page" .. i] then
				LeaPlusLC["Page" .. i]:HookScript("OnShow", function() results:Hide() end)
			end
		end

		-- Scrolling list (same style as the scrolling configuration panels)
		local backFrame = CreateFrame("Frame", nil, results, "BackdropTemplate")
		backFrame:SetPoint("TOPLEFT", 146, -68)
		backFrame:SetPoint("BOTTOMRIGHT", -16, 58)
		backFrame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		backFrame:SetBackdropColor(0, 0, 1, 0.5)

		-- Scroll frame is inset so the links and their highlight stay inside the darker box
		local scrollFrame = CreateFrame("ScrollFrame", nil, backFrame, "LeaPlusConfigurationPanelScrollFrameTemplate")
		local scrollChild = CreateFrame("Frame", nil, scrollFrame)
		scrollChild:SetSize(1, 1)
		scrollFrame:SetScrollChild(scrollChild)
		scrollFrame:SetPoint("TOPLEFT", 6, -6)
		scrollFrame:SetPoint("BOTTOMRIGHT", -29, 6)
		scrollFrame:SetPanExtent(rowHeight)

		-- Scroll for more message (only shown when the list is longer than the panel)
		local moreMessage = LeaPlusLC:MakeTx(results, "(scroll the list for more)", 16, 0)
		moreMessage:ClearAllPoints()
		moreMessage:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 28, 24)
		moreMessage:Hide()

		----------------------------------------------------------------------
		-- Search index (options on the main pages and settings in the configuration panels)
		----------------------------------------------------------------------

		local index, otherPanels

		-- Remove color codes, line breaks and reload asterisks, and make lower case
		local function Clean(text)
			text = (text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|n", " "):gsub("%*", "")
			return strtrim(string.lower(text))
		end

		-- Find the configuration button (cogwheel) for an option (created by CfgBtn as a child of the checkbox)
		local function FindCog(cb)
			for i, child in ipairs({cb:GetChildren()}) do
				if child:GetObjectType() == "Button" and child.t and child.tiptext == cogTip then
					return child
				end
			end
		end

		-- Find the label above a dropdown (created by CreateDropdown 20 pixels above it)
		local function DropdownLabel(dd)
			for i, region in ipairs({dd:GetRegions()}) do
				if region:GetObjectType() == "FontString" then
					local point, relativeTo, relativePoint, x, y = region:GetPoint(1)
					if relativeTo == dd and y == 20 then return region:GetText() end
				end
			end
		end

		-- Find the heading just above a slider (slider captions are used for their tooltips)
		local function SliderLabel(slider)
			local _, _, _, sx, sy = slider:GetPoint()
			if not sx or not sy then return end
			local best, bestGap
			for i, region in ipairs({slider:GetParent():GetRegions()}) do
				if region:GetObjectType() == "FontString" then
					local _, _, _, x, y = region:GetPoint(1)
					if x == sx and y and y > sy and y - sy <= 30 and (not bestGap or y - sy < bestGap) then
						best, bestGap = region:GetText(), y - sy
					end
				end
			end
			return best
		end

		local function BuildIndex()
			index, otherPanels = {}, {}

			local pageOf, isPanel = {}, {}
			for i = 1, numPages do
				if LeaPlusLC["Page" .. i] then pageOf[LeaPlusLC["Page" .. i]] = i end
			end
			for i, panel in ipairs(LeaConfigList) do isPanel[panel] = true end

			-- Find the configuration panel a control is in (controls can be inside a scroll frame)
			local function PanelOf(frame)
				local p = frame:GetParent()
				while p do
					if isPanel[p] then return p end
					p = p:GetParent()
				end
			end

			local byTitle, subsByPanel = {}, {}

			for field, w in pairs(LeaPlusCB) do
				if type(w) == "table" and w.GetObjectType then
					local objType = w:GetObjectType()
					local page = pageOf[w:GetParent()]
					if page then
						-- Option on a main page
						if objType == "CheckButton" and w.f then
							local _, _, _, x, y = w:GetPoint()
							local label = w.f:GetText() or ""
							local entry = {cb = w, cog = FindCog(w), field = field, page = page, x = x or 0, y = y or 0, label = label, pageName = LeaPlusLC["Page" .. page].s:GetText(), text = Clean(label .. " " .. (w.tiptext or "")), subs = {}}
							index[#index + 1] = entry
							byTitle[Clean(label)] = entry
						end
					else
						-- Setting in a configuration panel
						local panel = PanelOf(w)
						if panel then
							local label, isCheck
							if objType == "CheckButton" and w.f then
								label, isCheck = w.f:GetText(), true
							elseif objType == "Slider" then
								label = SliderLabel(w) or w.tiptext
							elseif objType == "DropdownButton" then
								label = DropdownLabel(w)
							end
							if label and strtrim(label) ~= "" then
								local _, _, _, x, y = w:GetPoint()
								subsByPanel[panel] = subsByPanel[panel] or {}
								tinsert(subsByPanel[panel], {target = w, panel = panel, field = isCheck and field or nil, label = label, tiptext = w.tiptext, x = x or 0, y = y or 0, text = Clean(label .. " " .. (w.tiptext or ""))})
							end
						end
					end
				end
			end

			-- Sort options in the same order as the pages (page, then column, then top to bottom)
			table.sort(index, function(a, b)
				if a.page ~= b.page then return a.page < b.page end
				if a.x ~= b.x then return a.x < b.x end
				return a.y > b.y
			end)

			-- Link each configuration panel to the option with the same name (others go under Other settings)
			for panel, subs in pairs(subsByPanel) do
				table.sort(subs, function(a, b)
					if a.y ~= b.y then return a.y > b.y end
					return a.x < b.x
				end)
				local title = panel.f and panel.f:GetText() or ""
				local parent = byTitle[Clean(title)]
				for i, sub in ipairs(subs) do sub.parent = parent end
				if parent then
					parent.subs = subs
				else
					otherPanels[#otherPanels + 1] = {panel = panel, label = title, subs = subs}
				end
			end
			table.sort(otherPanels, function(a, b) return a.label < b.label end)
		end

		----------------------------------------------------------------------
		-- Highlight an option or setting after jumping to it
		----------------------------------------------------------------------

		local flash = CreateFrame("Frame", nil, PageF)
		flash:Hide()
		flash.t = flash:CreateTexture(nil, "OVERLAY")
		flash.t:SetAllPoints()
		flash.t:SetColorTexture(1, 0.82, 0, 0.35)
		flash.t:SetBlendMode("ADD")

		local flashAnim = flash:CreateAnimationGroup()
		for i, v in ipairs({{0, 1, 0.2}, {1, 0, 0.4}, {0, 1, 0.2}, {1, 0, 0.8}}) do
			local a = flashAnim:CreateAnimation("Alpha")
			a:SetFromAlpha(v[1])
			a:SetToAlpha(v[2])
			a:SetDuration(v[3])
			a:SetOrder(i)
		end
		flashAnim:SetScript("OnFinished", function() flash:Hide() end)

		-- Flash a control (holder is the panel it's shown on)
		local function Flash(target, holder)
			flash:SetParent(holder)
			flash:SetFrameStrata(holder:GetFrameStrata())
			flash:ClearAllPoints()
			local objType = target:GetObjectType()
			if objType == "CheckButton" and target.f then
				-- Checkbox and its label
				flash:SetPoint("TOPLEFT", target, "TOPLEFT", -2, 0)
				flash:SetPoint("BOTTOMLEFT", target, "BOTTOMLEFT", -2, 0)
				flash:SetWidth(28 + math.min(target.f:GetStringWidth(), target.f:GetWidth()))
			elseif objType == "Slider" then
				-- Slider and its value
				flash:SetPoint("TOPLEFT", target, "TOPLEFT", -4, 4)
				flash:SetPoint("BOTTOMLEFT", target, "BOTTOMLEFT", -4, -4)
				flash:SetWidth(target:GetWidth() + 8 + (target.f and target.f:GetStringWidth() + 12 or 0))
			else
				-- Dropdown and its label above
				flash:SetPoint("TOPLEFT", target, "TOPLEFT", -4, 22)
				flash:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", 4, -4)
			end
			flash:SetFrameLevel(target:GetFrameLevel() + 5)
			flash:Show()
			flashAnim:Stop()
			flashAnim:Play()
		end

		-- Open an options page (used by the headings)
		local function ShowPage(page)
			LeaPlusLC:HideFrames()
			PageF:Show()
			LeaPlusLC["Page" .. page]:Show()
			LeaPlusLC["LeaStartPage"] = page
		end

		-- Open the page an option is on and highlight it
		local function ShowOption(entry)
			ShowPage(entry.page)
			Flash(entry.cb, PageF)
		end

		-- Open a configuration panel directly (used when a panel has no matching option)
		local function ShowPanel(panel)
			LeaPlusLC:HideFrames()
			LeaPlusLC:HideConfigPanels()
			panel:Show()
		end

		-- Open the configuration panel a setting is in and highlight it
		local function ShowSub(sub)
			local parent = sub.parent
			local cog = parent and parent.cog
			if cog then
				if cog:IsEnabled() and parent.cb:IsEnabled() then
					-- Use the real cogwheel so the panel is set up as normal
					GameTooltip:Hide()
					cog:Click()
				else
					-- Cogwheel is locked (option is off or needs a reload) so show the option instead
					ShowOption(parent)
					return
				end
			else
				ShowPanel(sub.panel)
			end
			if sub.panel:IsShown() then Flash(sub.target, sub.panel) end
		end

		----------------------------------------------------------------------
		-- Result list (page headings, options, and configuration panel settings underneath)
		----------------------------------------------------------------------

		local rows = {}

		local function GetRow(n)
			if rows[n] then return rows[n] end

			local row = CreateFrame("Button", nil, scrollChild)
			row:SetHeight(rowHeight)
			row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(n - 1) * rowHeight)
			row:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -(n - 1) * rowHeight)

			row.hl = row:CreateTexture(nil, "BACKGROUND")
			row.hl:SetAllPoints()
			row.hl:SetColorTexture(0.3, 0.3, 0.00, 0.5)
			row.hl:Hide()

			-- Page heading
			row.h = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			row.h:SetPoint("LEFT", 8, 0)
			row.h:SetJustifyH("LEFT")

			-- Enabled status (fixed width column on the right)
			row.e = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			row.e:SetPoint("RIGHT", -8, 0)
			row.e:SetWidth(28)
			row.e:SetJustifyH("CENTER")

			-- Option or setting name (indent is set when the row is used)
			row.f = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			row.f:SetJustifyH("LEFT")
			row.f:SetWordWrap(false)

			row:SetScript("OnEnter", function(self)
				self.hl:Show()
				if self.tiptext then LeaPlusLC.TipSee(self) end
			end)
			row:SetScript("OnLeave", function(self)
				self.hl:Hide()
				GameTooltip:Hide()
			end)
			row:SetScript("OnClick", function(self)
				if self.kind == "option" then
					ShowOption(self.data)
				elseif self.kind == "sub" then
					ShowSub(self.data)
				elseif self.kind == "panel" then
					ShowPanel(self.data.panel)
				elseif self.kind == "heading" and self.page then
					ShowPage(self.page)
				end
			end)

			rows[n] = row
			return row
		end

		-- Set the indent of a row's name
		local function SetIndent(row, indent)
			row.f:ClearAllPoints()
			row.f:SetPoint("LEFT", indent, 0)
			row.f:SetPoint("RIGHT", row.e, "LEFT", -8, 0)
		end

		-- Show the On or Off status for a setting
		local function SetStatus(row, field)
			if not field then row.e:Hide() return end
			if LeaPlusLC[field] == "On" then
				row.e:SetText(L["On"])
				row.e:SetTextColor(0.2, 1, 0.2)
			else
				row.e:SetText(L["Off"])
				row.e:SetTextColor(0.5, 0.5, 0.5)
			end
			row.e:Show()
		end

		----------------------------------------------------------------------
		-- Show search results
		----------------------------------------------------------------------

		local function ShowResults(query)

			if not index then BuildIndex() end

			-- Every word typed must appear in the name or tooltip
			local words = {}
			for word in string.lower(query):gmatch("%S+") do words[#words + 1] = word end

			local function Matches(text)
				for i, word in ipairs(words) do
					if not text:find(word, 1, true) then return false end
				end
				return true
			end

			-- Build the list
			local items, count, lastHeading = {}, 0, nil
			local function AddHeading(key, name, page)
				if key ~= lastHeading then
					items[#items + 1] = {kind = "heading", name = name, page = page}
					lastHeading = key
				end
			end

			-- Options and their configuration panel settings
			for i, entry in ipairs(index) do
				local optionMatch = Matches(entry.text)
				local subs = {}
				for j, sub in ipairs(entry.subs) do
					if Matches(sub.text) then subs[#subs + 1] = sub end
				end
				if optionMatch or #subs > 0 then
					AddHeading(entry.page, entry.pageName, entry.page)
					items[#items + 1] = {kind = "option", data = entry}
					if optionMatch then count = count + 1 end
					for j, sub in ipairs(subs) do
						items[#items + 1] = {kind = "sub", data = sub}
						count = count + 1
					end
				end
			end

			-- Configuration panels without a matching option
			for i, group in ipairs(otherPanels) do
				local subs = {}
				for j, sub in ipairs(group.subs) do
					if Matches(sub.text) then subs[#subs + 1] = sub end
				end
				if #subs > 0 then
					AddHeading("other", L["Other settings"])
					items[#items + 1] = {kind = "panel", data = group}
					for j, sub in ipairs(subs) do
						items[#items + 1] = {kind = "sub", data = sub}
						count = count + 1
					end
				end
			end

			-- Show the list
			for i, item in ipairs(items) do
				local row = GetRow(i)
				row.kind, row.data, row.page, row.tiptext = item.kind, item.data, nil, nil
				row.h:Hide()
				row.f:Hide()
				row.e:Hide()
				if item.kind == "heading" then
					row.page = item.page
					row.h:SetText(item.name)
					row.h:Show()
				elseif item.kind == "option" then
					SetIndent(row, 20)
					row.f:SetText(item.data.label)
					row.f:SetTextColor(1, 1, 1)
					row.f:Show()
					row.tiptext = item.data.cb.tiptext
					SetStatus(row, item.data.field)
				elseif item.kind == "panel" then
					SetIndent(row, 20)
					row.f:SetText(item.data.label)
					row.f:SetTextColor(1, 1, 1)
					row.f:Show()
				elseif item.kind == "sub" then
					SetIndent(row, 36)
					row.f:SetText(item.data.label)
					row.f:SetTextColor(0.6, 0.6, 0.6)
					row.f:Show()
					row.tiptext = item.data.tiptext
					SetStatus(row, item.data.field)
				end
				row:Show()
			end
			for i = #items + 1, #rows do
				rows[i]:Hide()
				rows[i].kind, rows[i].data, rows[i].page = nil, nil, nil
			end

			-- Size the list and scroll to the top
			scrollChild:SetWidth(scrollFrame:GetWidth())
			scrollChild:SetHeight(math.max(#items * rowHeight, 1))
			scrollFrame:SetVerticalScroll(0)
			moreMessage:SetShown(#items * rowHeight > scrollFrame:GetHeight())

			-- Result count (options and settings that matched, not context rows)
			if count == 0 then
				results.c:SetText(L["No options found."])
			elseif count == 1 then
				results.c:SetText(L["1 option found."])
			else
				results.c:SetFormattedText(L["%d options found."], count)
			end

		end

		----------------------------------------------------------------------
		-- Search box (top right of the panel)
		----------------------------------------------------------------------

		local eb = LeaPlusLC:CreateEditBox("OptionsSearchBox", PageF, 180, 40, "TOPRIGHT", -36, -12, "OptionsSearchBox", "OptionsSearchBox")
		eb:SetHeight(25)
		eb:SetFontObject("GameFontHighlight")
		eb:SetTextInsets(8, 22, 0, 0)

		-- Remove the default editbox art
		eb.f:Hide()
		for i, key in pairs({"Left", "Middle", "Mid", "Right"}) do
			if eb[key] then eb[key]:SetAlpha(0) end
		end

		-- Translucent inset that blends with the panel (dark fill and a faint outline)
		eb.bg = eb:CreateTexture(nil, "BACKGROUND")
		eb.bg:SetAllPoints()
		eb.bg:SetColorTexture(0, 0, 0, 0.35)

		-- Outline (1 pixel lines around the box)
		eb.edges = {}
		local function MakeEdge(p1, p2, horizontal)
			local edge = eb:CreateTexture(nil, "BORDER")
			edge:SetPoint(p1, eb, p1)
			edge:SetPoint(p2, eb, p2)
			if PixelUtil then
				if horizontal then PixelUtil.SetHeight(edge, 1) else PixelUtil.SetWidth(edge, 1) end
			else
				if horizontal then edge:SetHeight(1) else edge:SetWidth(1) end
			end
			eb.edges[#eb.edges + 1] = edge
		end
		MakeEdge("TOPLEFT", "TOPRIGHT", true)
		MakeEdge("BOTTOMLEFT", "BOTTOMRIGHT", true)
		MakeEdge("TOPLEFT", "BOTTOMLEFT", false)
		MakeEdge("TOPRIGHT", "BOTTOMRIGHT", false)

		-- Set outline color
		local function SetEdgeColor(r, g, b, a)
			for i, edge in pairs(eb.edges) do edge:SetColorTexture(r, g, b, a) end
		end

		-- Placeholder text
		eb.ph = eb:CreateFontString(nil, "ARTWORK", "GameFontDisable")
		eb.ph:SetPoint("LEFT", 8, 0)
		eb.ph:SetText(L["Search options"])

		-- Clear button (cross on the right, shown when there is text)
		eb.clear = CreateFrame("Button", nil, eb)
		eb.clear:SetSize(14, 14)
		eb.clear:SetPoint("RIGHT", -6, 0)
		eb.clear.t = eb.clear:CreateTexture(nil, "ARTWORK")
		eb.clear.t:SetAllPoints()
		eb.clear.t:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
		eb.clear.t:SetAlpha(0.5)
		eb.clear:SetScript("OnEnter", function(self) self.t:SetAlpha(1) end)
		eb.clear:SetScript("OnLeave", function(self) self.t:SetAlpha(0.5) end)
		eb.clear:Hide()

		-- Update placeholder, clear button and outline (gold while typing, lighter on hover)
		local function UpdateBox()
			local empty = eb:GetText() == ""
			eb.ph:SetShown(empty and not eb:HasFocus())
			eb.clear:SetShown(not empty)
			if eb:HasFocus() then
				SetEdgeColor(1, 0.82, 0, 0.5)
			elseif eb:IsMouseOver() then
				SetEdgeColor(1, 1, 1, 0.3)
			else
				SetEdgeColor(1, 1, 1, 0.15)
			end
		end
		eb:HookScript("OnEditFocusGained", UpdateBox)
		eb:HookScript("OnEditFocusLost", UpdateBox)
		eb:HookScript("OnEnter", UpdateBox)
		eb:HookScript("OnLeave", UpdateBox)

		-- Return to the last options page
		local function ShowLastPage()
			results:Hide()
			local page = LeaPlusLC["Page" .. (LeaPlusLC["LeaStartPage"] or 0)]
			if page then page:Show() end
		end

		-- Clear the search and return to the last page
		local function ClearSearch()
			eb:SetText("")
			eb:ClearFocus()
			ShowLastPage()
			UpdateBox()
		end
		eb.clear:SetScript("OnClick", ClearSearch)

		-- Search as you type
		eb:SetScript("OnTextChanged", function(self, userInput)
			UpdateBox()
			if not userInput then return end
			local query = strtrim(self:GetText())
			if query == "" then
				ShowLastPage()
			else
				for i = 0, numPages do
					if LeaPlusLC["Page" .. i] then LeaPlusLC["Page" .. i]:Hide() end
				end
				results:Show()
				ShowResults(query)
			end
		end)

		-- Escape clears the search, enter takes focus off the editbox
		eb:SetScript("OnEscapePressed", ClearSearch)
		eb:SetScript("OnEnterPressed", eb.ClearFocus)

		-- Clear the search when the panel is closed or another page is chosen (index is rebuilt next time)
		PageF:HookScript("OnHide", function()
			results:Hide()
			eb:SetText("")
			eb:ClearFocus()
			UpdateBox()
			index = nil
		end)

		UpdateBox()

	end

	-- Use a variable to contain the page number (makes it easier to move options around)
	local pg;

----------------------------------------------------------------------
-- 	LC0: Welcome
----------------------------------------------------------------------

	pg = "Page0"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Welcome to Leatrix Plus.", 146, -72)
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "To begin, choose an options page.", 146, -92)

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Support", 146, -132);
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "curseforge.com/wow/addons/leatrix-plus", 146, -152)

----------------------------------------------------------------------
-- 	LC1: Automation
----------------------------------------------------------------------

	pg = "Page1"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Character"					, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutomateQuests"			,	"Automate quests"				,	146, -92, 	false,	"If checked, quests will be selected, accepted and turned-in automatically.|n|nQuests which require gold, currency, a crafting reagent or an account-bound item will not be turned-in automatically.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutomateGossip"			,	"Automate gossip"				,	146, -112, 	false,	"If checked, you can hold down the alt key while opening a gossip window to automatically select a single gossip option.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptSummon"			,	"Accept summon"					, 	146, -132, 	false,	"If checked, summon requests will be accepted automatically unless you are in combat.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptRes"				,	"Accept resurrection"			, 	146, -152, 	false,	"If checked, resurrection requests will be accepted automatically.|n|nResurrection requests from a Brazier of Awakening or a Failure Detection Pylon will not be accepted automatically.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoReleasePvP"			,	"Release in PvP"				, 	146, -172, 	false,	"If checked, you will release automatically after you die in Ashran, Tol Barad (PvP), Wintergrasp or any battleground.|n|nYou will not release automatically if you have the ability to self-resurrect (soulstone, reincarnation, etc).")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Vendors"					, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoSellJunk"				,	"Sell junk automatically"		,	340, -92, 	true,	"If checked, all grey items in your bags will be sold automatically when you visit a merchant.|n|nYou can hold the shift key down when you talk to a merchant to override this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoRepairGear"			, 	"Repair automatically"			,	340, -112, 	false,	"If checked, your gear will be repaired automatically when you visit a suitable merchant.|n|nYou can hold the shift key down when you talk to a merchant to override this setting.")

	LeaPlusLC:CfgBtn("AutomateQuestsBtn", LeaPlusCB["AutomateQuests"])
	LeaPlusLC:CfgBtn("AutoAcceptResBtn", LeaPlusCB["AutoAcceptRes"])
	LeaPlusLC:CfgBtn("AutoReleasePvPBtn", LeaPlusCB["AutoReleasePvP"])
	LeaPlusLC:CfgBtn("AutoSellJunkBtn", LeaPlusCB["AutoSellJunk"])
	LeaPlusLC:CfgBtn("AutoRepairBtn", LeaPlusCB["AutoRepairGear"])

----------------------------------------------------------------------
-- 	LC2: Social
----------------------------------------------------------------------

	pg = "Page2"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Blocks"					, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoDuelRequests"			, 	"Block duels"					,	146, -92, 	false,	"If checked, duel requests will be blocked unless the player requesting the duel is a friend.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoPetDuels"				, 	"Block pet battle duels"		,	146, -112, 	false,	"If checked, pet battle duel requests will be blocked unless the player requesting the duel is a friend.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoPartyInvites"			, 	"Block party invites"			, 	146, -132, 	false,	"If checked, party invitations will be blocked unless the player inviting you is a friend.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoRequestedInvites"		, 	"Block requested invites"		, 	146, -152, 	false,	"If checked, requests to invite a player to your group will be declined unless the player requesting to join is a friend.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoFriendRequests"			, 	"Block friend requests"			, 	146, -172, 	false,	"If checked, BattleTag and Real ID friend requests will be automatically declined.|n|nEnabling this option will automatically decline any pending requests.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoSharedQuests"			, 	"Block shared quests"			, 	146, -192, 	false,	"If checked, shared quests will be declined unless the player sharing the quest is a friend.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Groups"					, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AcceptPartyFriends"		, 	"Party from friends"			, 	340, -92, 	false,	"If checked, party invitations from friends will be automatically accepted unless you are queued in Dungeon Finder.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "SyncFromFriends"			, 	"Sync from friends"				,	340, -112, 	false,	"If checked, party sync requests from friends will be automatically accepted.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoConfirmRole"			, 	"Queue from friends"			,	340, -132, 	false,	"If checked, requests initiated by your party leader to join the Dungeon Finder queue will be automatically accepted if the party leader is a friend.|n|nThis option requires that you have selected a role for your character in the Dungeon Finder window.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "InviteFromWhisper"			,   "Invite from whispers"			,	340, -152,	false,	L["If checked, a group invite will be sent to anyone who whispers you with a set keyword as long as you are ungrouped, group leader or raid assistant and not queued for a dungeon or raid.|n|nFriends who message the keyword using Battle.net will not be sent a group invite if they are appearing offline.  They need to either change their online status or use character whispers."] .. "|n|n" .. L["Keyword"] .. ": |cffffffff" .. "dummy" .. "|r")

	-- Show footer
	local FriendlyGuildFooter = LeaPlusLC:MakeFT(LeaPlusLC[pg], "For all of the social options above, you can treat guild members and members of your communities as friends too.", 146, 380, 96)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FriendlyGuild"				, 	"Guild"							, 	146, -282, 	false,	"If checked, members of your guild will be treated as friends for all of the options on this page.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FriendlyCommunities"		, 	"Communities"					, 	340, -282, 	false,	"If checked, members of your communities will be treated as friends for all of the options on this page.")

	if LeaPlusCB["FriendlyGuild"].f:GetStringWidth() > 90 then
		LeaPlusCB["FriendlyGuild"].f:SetWidth(90)
	end
	if LeaPlusCB["FriendlyCommunities"].f:GetStringWidth() > 90 then
		LeaPlusCB["FriendlyCommunities"].f:SetWidth(90)
	end

	LeaPlusCB["FriendlyGuild"]:ClearAllPoints()
	LeaPlusCB["FriendlyGuild"]:SetPoint("TOPLEFT", FriendlyGuildFooter, "BOTTOMLEFT", 0, -10)
	LeaPlusCB["FriendlyCommunities"]:ClearAllPoints()
	LeaPlusCB["FriendlyCommunities"]:SetPoint("LEFT", LeaPlusCB["FriendlyGuild"], "RIGHT", LeaPlusCB["FriendlyGuild"].f:GetWidth() + 6, 0)

	LeaPlusLC:CfgBtn("InvWhisperBtn", LeaPlusCB["InviteFromWhisper"])

----------------------------------------------------------------------
-- 	LC3: Chat
----------------------------------------------------------------------

	pg = "Page3"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Chat Frame"				, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UseEasyChatResizing"		,	"Use easy resizing"				,	146, -92,	true,	"If checked, dragging the General chat tab will expand the chat frame upwards.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoCombatLogTab" 			, 	"Hide the combat log"			, 	146, -112, 	true,	"If checked, the combat log will be hidden.|n|nThe combat log must be docked in order for this option to work.|n|nIf the combat log is undocked, you can dock it by dragging the tab (and reloading your UI) or by resetting the chat windows (from the chat menu).")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoChatButtons"				,	"Hide chat buttons"				,	146, -132,	true,	"If checked, chat frame buttons will be hidden.|n|nClicking chat tabs will automatically show the latest messages.|n|nUse the mouse wheel to scroll through the chat history.  Hold down SHIFT for page jump or CTRL to jump to the top or bottom of the chat history.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoSocialButton"			,	"Hide social button"			,	146, -152,	true,	"If checked, the social button and quick-join notification will be hidden.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UnclampChat"				,	"Unclamp chat frame"			,	146, -172,	true,	"If checked, you will be able to drag the chat frame to the edge of the screen.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MoveChatEditBoxToTop" 		, 	"Move editbox to top"			,	146, -192, 	true,	"If checked, the editbox will be moved to the top of the chat frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MoreChatFontSizes"		 	, 	"More chat font sizes"			,	146, -212, 	true,	"If checked, additional chat font sizes will be available in the chat font size menu.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Mechanics"					, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoStickyChat"				, 	"Disable sticky chat"			,	340, -92,	true,	"If checked, sticky chat will be disabled.|n|nNote that this does not apply to temporary chat windows.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UseArrowKeysInChat"		, 	"Use arrow keys in chat"		, 	340, -112, 	true,	"If checked, you can press the arrow keys to move the insertion point left and right in the chat frame.|n|nIf unchecked, the arrow keys will use the default keybind setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoChatFade"				, 	"Disable chat fade"				, 	340, -132, 	true,	"If checked, chat text will not fade out after a time period.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UnivGroupColor"			,	"Universal group color"			,	340, -152,	false,	"If checked, raid chat and instance chat will both be colored blue (to match the default party chat color).")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "RecentChatWindow"			,	"Recent chat window"			, 	340, -172, 	true,	"If checked, you can hold down the control key and click a chat tab to view recent chat in a copy-friendly window.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FilterChatMessages"		, 	"Filter chat messages"			,	340, -192, 	true,	"If checked, you can block spell links, drunken spam and duel spam.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "RestoreChatMessages"		, 	"Restore chat messages"			,	340, -212, 	true,	"If checked, recent chat will be restored when you reload your interface.")

	LeaPlusLC:CfgBtn("NoChatButtonsBtn", LeaPlusCB["NoChatButtons"])
	LeaPlusLC:CfgBtn("FilterChatMessagesBtn", LeaPlusCB["FilterChatMessages"])

----------------------------------------------------------------------
-- 	LC4: Text
----------------------------------------------------------------------

	pg = "Page4"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Visibility"				, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideErrorMessages"			, 	"Hide error messages"			,	146, -92, 	true,	"If checked, most error messages (such as 'Not enough rage') will not be shown.  Some important errors are excluded.|n|nIf you have the minimap button enabled, you can hold down the alt key and click it to toggle error messages without affecting this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoHitIndicators"			, 	"Hide portrait numbers"			,	146, -112, 	true,	"If checked, damage and healing numbers in the player and pet portrait frames will be hidden.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideZoneText"				,	"Hide zone text"				,	146, -132, 	true,	"If checked, zone text will not be shown (eg. 'Ironforge').")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideKeybindText"			,	"Hide keybind text"				,	146, -152, 	true,	"If checked, keybind text will not be shown on action buttons.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideMacroText"				,	"Hide macro text"				,	146, -172, 	true,	"If checked, macro text will not be shown on action buttons.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Text Size"					, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "QuestFontChange"			,	"Resize quest text"				, 	340, -92, 	true,	"If checked, you will be able to change the font size of quest text.|n|nEnabling this option will also change the text size of other frames which inherit the same font (such as the Dungeon Finder frame).")

	LeaPlusLC:CfgBtn("QuestTextBtn", LeaPlusCB["QuestFontChange"])

----------------------------------------------------------------------
-- 	LC5: Interface
----------------------------------------------------------------------

	pg = "Page5"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Enhancements"				, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MinimapModder"				,	"Enhance minimap"				, 	146, -92, 	true,	"If checked, you will be able to customise the minimap.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "TipModEnable"				,	"Enhance tooltip"				,	146, -112, 	true,	"If checked, the tooltip will be color coded and you will be able to modify the tooltip layout and scale.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "EnhanceDressup"			, 	"Enhance dressup"				,	146, -132, 	true,	"If checked, gear toggle buttons will be added to the dressup frame and model positioning controls will be removed.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Extras"					, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowVolume"				, 	"Show volume slider"			, 	340, -92, 	true,	"If checked, a master volume slider will be shown in the character frame.|n|nThe volume slider can be placed in either of two locations in the character frame.  To toggle between them, hold the shift key down and right-click the slider.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "DurabilityStatus"			, 	"Show durability status"		, 	340, -112, 	true,	"If checked, a button will be added to the character frame which will show your equipped item durability when you hover the pointer over it.|n|nIn addition, an overall percentage will be shown in the chat frame when you die.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowPetSaveBtn"			, 	"Show pet save button"			, 	340, -132, 	true,	"If checked, you will be able to save your current battle pet team (including abilities) to a single command.|n|nA button will be added to the Pet Journal.  Clicking the button will toggle showing the assignment command for your current team.  Pressing CTRL/C will copy the command to memory.|n|nYou can then paste the command (with CTRL/V) into the chat window or a macro to instantly assign your team.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowRaidToggle"			, 	"Show raid button"				,	340, -152, 	true,	"If checked, the button to toggle the raid container frame will be shown just above the raid management frame (left side of the screen) instead of in the raid management frame itself.|n|nThis allows you to toggle the raid container frame without needing to open the raid management frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowTrainAllButton"		, 	"Show train all button"			,	340, -172, 	true,	"If checked, a button will be added to the skill trainer frame which will allow you to train all available skills instantly.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowBorders"				,	"Show borders"					,	340, -192, 	true,	"If checked, you will be able to show customisable borders around the edges of the screen.|n|nThe borders are placed on top of the game world but under the UI so you can place UI elements over them.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowPlayerChain"			, 	"Show player chain"				,	340, -212, 	true,	"If checked, you will be able to show a rare, elite or rare elite chain around the player frame.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowReadyTimer"			, 	"Show ready timer"				,	340, -232, 	true,	"If checked, a timer will be shown under the dungeon ready frame and the PvP encounter ready frame so that you know how long you have left to click the enter button.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowRangeColoring"			, 	"Show range coloring"			, 	340, -252, 	true,	"If checked, action button icons will be colored red for out of range and blue for not enough mana.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowInfoCards"				, 	"Show info cards"				, 	340, -272, 	true,	"If checked, you can point at almost anything and press a key to show an information card, model preview and a link to Wowhead.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowWowheadLinks"			, 	"Show Wowhead links"			, 	340, -292, 	true,	"If checked, Wowhead links will be shown in the world map frame and the achievements frame.")

	LeaPlusLC:CfgBtn("ModMinimapBtn", LeaPlusCB["MinimapModder"])
	LeaPlusLC:CfgBtn("MoveTooltipButton", LeaPlusCB["TipModEnable"])
	LeaPlusLC:CfgBtn("EnhanceDressupBtn", LeaPlusCB["EnhanceDressup"])
	LeaPlusLC:CfgBtn("ModBordersBtn", LeaPlusCB["ShowBorders"])
	LeaPlusLC:CfgBtn("ModPlayerChain", LeaPlusCB["ShowPlayerChain"])
	LeaPlusLC:CfgBtn("ShowInfoCardsBtn", LeaPlusCB["ShowInfoCards"])
	LeaPlusLC:CfgBtn("ShowWowheadLinksBtn", LeaPlusCB["ShowWowheadLinks"])

----------------------------------------------------------------------
-- 	LC6: Frames
----------------------------------------------------------------------

	pg = "Page6"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Features"					, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ManageWidgetTop"			,	"Manage widget top"				, 	146, -92, 	true,	"If checked, you will be able to change the position and scale of the widget top frame.|n|nThe widget top frame is commonly used for showing PvP scores and tracking objectives.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ClassColFrames"			, 	"Class colored frames"			,	146, -112, 	true,	"If checked, class coloring will be used in the player frame, target frame and focus frame.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Visibility"				, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoAlerts"					,	"Hide alerts"					, 	340, -92, 	true,	"If checked, alert frames will not be shown.|n|nAlert frames are toast frames used for things like achievement earned, loot won, new recipe learned, new mount collected, etc.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideBodyguard"				, 	"Hide bodyguard gossip"			, 	340, -112, 	true,	"If checked, the gossip window will not be shown when you talk to an active garrison bodyguard.|n|nYou can hold the shift key down when you talk to a bodyguard to override this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideTalkingFrame"			, 	"Hide talking frame"			, 	340, -132, 	true,	"If checked, the talking frame will not be shown.|n|nThe talking frame normally appears in the lower portion of the screen when certain NPCs communicate with you.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideCleanupBtns"			, 	"Hide clean-up buttons"			, 	340, -152, 	true,	"If checked, the backpack clean-up button and the bank frame clean-up button will not be shown.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideBossBanner"			, 	"Hide boss banner"				, 	340, -172, 	true,	"If checked, the boss banner will not be shown.|n|nThe boss banner appears when a boss is defeated.  It shows the name of the boss and the loot that was distributed.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideEventToasts"			, 	"Hide event toasts"				, 	340, -192, 	true,	"If checked, event toasts will not be shown.|n|nEvent toasts are used for encounter objectives, level-ups, pet battle rewards, etc.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoClassBar"				,	"Hide stance bar"				, 	340, -212, 	true,	"If checked, the stance bar will not be shown.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoRestedSleep"				,	"Hide rested sleep"				, 	340, -232, 	true,	"If checked, the player frame rested sleep animation will not be shown.")

	LeaPlusLC:CfgBtn("ManageWidgetTopButton", LeaPlusCB["ManageWidgetTop"])
	LeaPlusLC:CfgBtn("ClassColFramesBtn", LeaPlusCB["ClassColFrames"])

----------------------------------------------------------------------
-- 	LC7: System
----------------------------------------------------------------------

	pg = "Page7"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Graphics and Sound"		, 	146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoScreenGlow"				, 	"Disable screen glow"			, 	146, -92, 	false,	"If checked, the screen glow will be disabled.|n|nEnabling this option will also disable the drunken haze effect.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoScreenEffects"			, 	"Disable screen effects"		, 	146, -112, 	false,	"If checked, the grey screen of death, the netherworld effect and the Cloak of Ven'ari effect will be disabled.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "SetWeatherDensity"			, 	"Set weather density"			, 	146, -132, 	false,	"If checked, you will be able to set the density of weather effects.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MaxCameraZoom"				, 	"Max camera zoom"				, 	146, -152, 	false,	"If checked, you will be able to zoom out to a greater distance.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoRestedEmotes"			, 	"Silence rested emotes"			,	146, -172, 	true,	"If checked, emote sounds will be silenced while your character is:|n|n- resting|n- in a pet battle|n- at the Halfhill Market|n- at the Grim Guzzler|n|nEmote sounds will be enabled when none of the above apply.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "KeepAudioSynced"			, 	"Keep audio synced"				,	146, -192, 	true,	"If checked, when you change the audio output device in your operating system, the game audio output device will change automatically as long as a cinematic is not playing at the time.|n|nFor this to work, the game audio output device will be set to system default.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MuteGameSounds"			, 	"Mute game sounds"				,	146, -212, 	false,	"If checked, you will be able to mute a selection of game sounds.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MuteMountSounds"			, 	"Mute mount sounds"				,	146, -232, 	false,	"If checked, you will be able to mute a selection of mount sounds.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MuteCustomSounds"			, 	"Mute custom sounds"			,	146, -252, 	false,	"If checked, you will be able to mute your own choice of sounds.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Game Options"				, 	340, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoPetAutomation"			, 	"Disable pet automation"		, 	340, -92, 	true, 	"If checked, battle pets which are automatically summoned will be dismissed within a few seconds.|n|nThis includes dragging a pet onto the first team slot in the pet journal and entering a battle pet team save command.|n|nNote that pets which are automatically summoned during combat will be dismissed when combat ends.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoRaidRestrictions"		, 	"Remove raid restrictions"		,	340, -112, 	false,	"If checked, converting a party group to a raid group will succeed even if there are low level characters in the group.|n|nEveryone in the group needs to have Leatrix Plus installed with this option enabled.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoConfirmLoot"				, 	"Disable loot warnings"			,	340, -132, 	false,	"If checked, confirmations will no longer appear when you choose a loot roll option or attempt to sell or mail a tradable item.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FasterLooting"				, 	"Faster auto loot"				,	340, -152, 	true,	"If checked, the amount of time it takes to auto loot creatures will be significantly reduced.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FasterMovieSkip"			, 	"Faster movie skip"				,	340, -172, 	true,	"If checked, you will be able to cancel movies without being prompted for confirmation.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "CombatPlates"				, 	"Combat plates"					,	340, -192, 	true,	"If checked, enemy nameplates will be shown during combat and hidden when combat ends.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "EasyItemDestroy"			, 	"Easy item destroy"				,	340, -212, 	true,	"If checked, you will no longer need to type delete when destroying a superior quality item.|n|nIn addition, item links will be shown in all item destroy confirmation windows.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoTransforms"				, 	"Remove transforms"				, 	340, -232, 	false, 	"If checked, you will be able to have certain transforms removed automatically when they are applied to your character.|n|nYou can choose the transforms in the configuration panel.|n|nExamples include Weighted Jack-o'-Lantern and Hallowed Wand.|n|nTransforms applied during combat will be removed when combat ends.")

	LeaPlusLC:CfgBtn("SetWeatherDensityBtn", LeaPlusCB["SetWeatherDensity"])
	LeaPlusLC:CfgBtn("MuteGameSoundsBtn", LeaPlusCB["MuteGameSounds"])
	LeaPlusLC:CfgBtn("MuteMountSoundsBtn", LeaPlusCB["MuteMountSounds"])
	LeaPlusLC:CfgBtn("MuteCustomSoundsBtn", LeaPlusCB["MuteCustomSounds"])
	LeaPlusLC:CfgBtn("FasterLootingBtn", LeaPlusCB["FasterLooting"])
	LeaPlusLC:CfgBtn("NoTransformsBtn", LeaPlusCB["NoTransforms"])

----------------------------------------------------------------------
-- 	LC8: Settings
----------------------------------------------------------------------

	pg = "Page8"

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Addon"						, 146, -72)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowMinimapIcon"			, "Show minimap button"				, 146, -92,		false,	"If checked, a minimap button will be available.|n|nClick - Toggle options panel.|n|nSHIFT-click - Toggle music.|n|nCTRL-click - Toggle minimap target tracking.|n|nALT-click - Toggle errors (if enabled).|n|nCTRL/SHIFT-click - Toggle windowed mode.|n|nCTRL/ALT-click - Toggle Zygor (if installed).")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Miscellaneous"				, 146, -132)
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "SetEditModeLayout"			, "Set edit mode layout"			, 146, -152,	false,	"If checked, you can specify an edit mode layout that will always be applied when you login to any character.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "SimpleAddonListing"		, "Simple addon listing"			, 146, -172,	true,	"If checked, the addon listing will be shown in alphabetical order without categories.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideStarterTutorials"		, "Hide starter tutorials"			, 146, -192,	true,	"If checked, the Exile's Reach banner tutorials will be hidden.")

	LeaPlusLC:CreateDropdown("AddonLanguage", "Language", 146, "TOPLEFT", LeaPlusLC[pg], "TOPLEFT", 340, -92, true, {{L["Automatic"], 1}, {L["English"], 2}, {L["Deutsch"], 3}, {L["Español (EU)"], 4}, {L["Español (AL)"], 5}, {L["Français"], 6}, {L["Italiano"], 7}, {L["Português"], 8}, {L["Русский"], 9}, {L["한국어"], 10}, {L["简体中文"], 11}, {L["繁體中文"], 12}})

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Scale", 340, -142)
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "PlusPanelScale", "Drag to set the scale of the Leatrix Plus panel.", 1, 2, 0.1, 340, -162, "%.1f")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Transparency", 340, -202)
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "PlusPanelAlpha", "Drag to set the transparency of the Leatrix Plus panel.", 0, 1, 0.1, 340, -222, "%.1f")

	LeaPlusLC:CfgBtn("SetEditModeLayoutBtn", LeaPlusCB["SetEditModeLayout"])
