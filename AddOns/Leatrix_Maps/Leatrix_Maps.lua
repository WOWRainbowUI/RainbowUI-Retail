
	----------------------------------------------------------------------
	-- 	Leatrix Maps 12.1.17 (11th November 2026)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Leatrix_Maps.blp (256x128) texture coordinates (left, right, top, bottom):
	-- Button: 0.5, 1, 0, 0.25 | Button highlight: 0, 0.5, 0, 0.25 | White close cross: 0, 0.125, 0.25, 0.5 | Red close cross: 0, 0.25, 0.5, 1
	-- Maximise: 0.25, 0.5, 0.5, 1 | Restore: 0.5, 0.75, 0.5, 1

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaConfigList, LeaLockList = {}, {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "12.1.17"

	-- Get locale table
	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	-- Check Wow version is valid
	do
		local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
		if gametocversion and gametocversion < 120000 then
			-- Game client is not Midnight
			C_Timer.After(2, function()
				print(L["LEATRIX MAPS: WRONG VERSION INSTALLED!"])
			end)
			return
		end
		if gametocversion and gametocversion >= 120107 then -- 12.1.7
			LeaMapsLC.NewPatch = true
		end
	end

	-- Check for addons
	if C_AddOns.IsAddOnLoaded("ElvUI") then LeaMapsLC.ElvUI = unpack(ElvUI) end

	-- Create a random global name that changes every time the addon loads
	function LeaMapsLC:CreateRandomName()
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

	-- Create a dropdown menu (the standard dropdown button but it opens a pop-up list instead of the game's menu, see
	-- LeaMapsLC:CreatePopupList for why)
	function LeaMapsLC:CreateDropdown(frame, label, width, anchor, parent, relative, x, y, reload, items)

		local dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		LeaMapsCB[frame] = dropdown
		dropdown:SetPoint(anchor, parent, relative, x, y)
		dropdown:SetWidth(width)

		local lf = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal"); lf:SetPoint("TOPLEFT", dropdown, 0, 20); lf:SetPoint("TOPRIGHT", dropdown, -5, 20); lf:SetJustifyH("LEFT"); lf:SetText(L[label])

		-- List entries
		local entries = {}
		for i = 1, #items do
			entries[i] = {name = items[i][1], value = items[i][2]}
		end

		-- Function to show the current option on the button
		local function UpdateText()
			for i = 1, #entries do
				if entries[i].value == LeaMapsLC[frame] then
					dropdown:OverrideText(entries[i].name)
					return
				end
			end
			dropdown:OverrideText("")
		end

		-- Function to apply an option (runs dropdown.onChange if it's set)
		local function SetValue(value)
			LeaMapsLC[frame] = value
			UpdateText()
			if dropdown.onChange then dropdown.onChange(value) end
			if reload then
				LeaMapsLC:ReloadCheck()
			end
		end

		local popup = LeaMapsLC:CreatePopupList(parent)

		local function IsCurrent(entry)
			return entry.value == LeaMapsLC[frame]
		end

		local function Choose(entry)
			SetValue(entry.value)
		end

		-- Function to step to the next or previous option (scroll down for the next option, up for the previous one, stops at either end)
		local function Step(delta)
			local index = 1
			for i = 1, #entries do
				if entries[i].value == LeaMapsLC[frame] then index = i; break end
			end
			index = index + (delta < 0 and 1 or -1)
			if index < 1 or index > #entries then return end
			SetValue(entries[index].value)
			popup:Refresh()
		end

		-- Open or close the list when the button is clicked
		dropdown:HookScript("OnMouseDown", function(self, button)
			if button ~= "LeftButton" or not self:IsEnabled() then return end
			popup:Toggle(self, entries, IsCurrent, Choose, "TOPLEFT", "BOTTOMLEFT", 0, -2, Step)
		end)

		-- Cycle through the options with the mousewheel over the button (the open list does the same)
		dropdown:EnableMouseWheel(true)
		dropdown:HookScript("OnMouseWheel", function(self, delta)
			if self:IsEnabled() then Step(delta) end
		end)

		-- Show the current option when the button is shown
		dropdown:HookScript("OnShow", UpdateText)
		UpdateText()

	end

	----------------------------------------------------------------------
	-- Pop-up lists
	----------------------------------------------------------------------

	-- The game's menus keep their state on the menu frame and the world map reads the frame under the pointer every
	-- frame, so menu entries made by an addon spread taint into the map's own code. Lists shown over the map use these
	-- pop-up lists instead. They are frames of our own, so the map never reads anything the addon wrote.

	function LeaMapsLC:CreatePopupList(parent)

		local rowHeight, rowsPerColumn, columnWidth = 20, 25, 180
		local rows = {}
		local owner, entries, isChecked, onClick, onWheel
		local highlightColor -- Row highlight color (set with popup:SetColors)
		local rowColorFunc -- Optional function giving each row its own highlight color (set with popup:SetColors)

		local list = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		list:SetFrameStrata("FULLSCREEN_DIALOG")
		list:SetClampedToScreen(true)
		list:EnableMouse(true)
		list:EnableMouseWheel(true)
		-- Mousewheel runs the wheel function if there is one (and stops the map zooming under the list)
		list:SetScript("OnMouseWheel", function(self, delta)
			if onWheel then onWheel(delta) end
		end)
		list:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
		list:SetBackdropColor(0.05, 0.05, 0.05, 0.95)

		-- Border (four lines sized in whole screen pixels when the list opens, so it's the same width all the way round)
		local borderLines = {}
		for i = 1, 4 do
			borderLines[i] = list:CreateTexture(nil, "BORDER")
			borderLines[i]:SetTexture("Interface\\Buttons\\WHITE8X8")
			borderLines[i]:SetVertexColor(0.3, 0.3, 0.3, 1)
		end

		-- Function to set the border lines to 1 screen pixel
		local function SetBorderPixels()
			local scale = list:GetEffectiveScale()
			if issecretvalue and issecretvalue(scale) then return end -- Frame scales can be secret in combat
			local px = PixelUtil and PixelUtil.GetNearestPixelSize(1, scale, 1) or 1
			local top, bottom, left, right = borderLines[1], borderLines[2], borderLines[3], borderLines[4]
			top:ClearAllPoints(); top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT"); top:SetHeight(px)
			bottom:ClearAllPoints(); bottom:SetPoint("BOTTOMLEFT"); bottom:SetPoint("BOTTOMRIGHT"); bottom:SetHeight(px)
			left:ClearAllPoints(); left:SetPoint("TOPLEFT", 0, -px); left:SetPoint("BOTTOMLEFT", 0, px); left:SetWidth(px)
			right:ClearAllPoints(); right:SetPoint("TOPRIGHT", 0, -px); right:SetPoint("BOTTOMRIGHT", 0, px); right:SetWidth(px)
		end
		list:Hide()

		-- Close the list when clicking anywhere else (only watched while the list is showing)
		list:SetScript("OnShow", function(self) self:RegisterEvent("GLOBAL_MOUSE_DOWN") end)
		list:SetScript("OnHide", function(self) self:UnregisterEvent("GLOBAL_MOUSE_DOWN") end)
		list:SetScript("OnEvent", function(self)
			if not self:IsMouseOver() and not (owner and owner:IsMouseOver()) then
				self:Hide()
			end
		end)

		-- Function to show a row as checked or not
		local function SetRowCheck(row)
			if isChecked(row.entry) then
				row.Check:Show()
				row.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
			else
				row.Check:Hide()
				row.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
			end
		end

		-- Function to get a row (rows are created when first needed and reused)
		local function GetRow(index)
			local row = rows[index]
			if not row then
				row = CreateFrame("Button", nil, list)
				row:SetSize(columnWidth, rowHeight)
				row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
				if highlightColor then row:GetHighlightTexture():SetVertexColor(highlightColor[1], highlightColor[2], highlightColor[3]) end
				row.Check = row:CreateTexture(nil, "ARTWORK")
				row.Check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
				row.Check:SetSize(16, 16)
				row.Check:SetPoint("LEFT", 4, 0)
				row.Text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
				row.Text:SetPoint("LEFT", 22, 0)
				row.Text:SetPoint("RIGHT", -4, 0)
				row.Text:SetJustifyH("LEFT")
				row.Text:SetWordWrap(false)
				row:SetScript("OnClick", function(self)
					-- The click function returns true to keep the list open (such as for checkboxes)
					if onClick(self.entry) then
						for i = 1, #entries do SetRowCheck(rows[i]) end
					else
						list:Hide()
					end
				end)
				rows[index] = row
			end
			return row
		end

		local popup = {}

		-- Close the list
		function popup:Close()
			list:Hide()
		end

		-- Set the list colors (background, border and row highlight, used by the map theme)
		-- (rowFunc is optional, it is called with the row number and row count and returns a highlight color for that row)
		function popup:SetColors(bgR, bgG, bgB, borderR, borderG, borderB, hlR, hlG, hlB, rowFunc, bgA)
			list:SetBackdropColor(bgR, bgG, bgB, bgA or 0.97)
			for i = 1, #borderLines do borderLines[i]:SetVertexColor(borderR, borderG, borderB, 1) end
			highlightColor = {hlR, hlG, hlB}
			rowColorFunc = rowFunc
			for i = 1, #rows do
				rows[i]:GetHighlightTexture():SetVertexColor(hlR, hlG, hlB)
			end
		end

		-- The list frame (so the map theme can add textures to it)
		popup.frame = list

		-- Update the checks in the open list
		function popup:Refresh()
			if not list:IsShown() then return end
			for i = 1, #entries do SetRowCheck(rows[i]) end
		end

		-- Show the list next to a button (long lists are split into columns)
		function popup:Open(button, items, checkedFunc, clickFunc, point, relativePoint, x, y, wheelFunc)
			local count = #items
			if count == 0 then return end
			owner, entries, isChecked, onClick, onWheel = button, items, checkedFunc, clickFunc, wheelFunc
			local columns = math.ceil(count / rowsPerColumn)
			local perColumn = math.ceil(count / columns)
			for i = 1, count do
				local row = GetRow(i)
				if rowColorFunc then
					row:GetHighlightTexture():SetVertexColor(rowColorFunc(i, count))
				elseif highlightColor then
					row:GetHighlightTexture():SetVertexColor(highlightColor[1], highlightColor[2], highlightColor[3])
				end
				row.entry = items[i]
				row.Text:SetText(items[i].name)
				SetRowCheck(row)
				row:ClearAllPoints()
				row:SetPoint("TOPLEFT", list, "TOPLEFT", 8 + math.floor((i - 1) / perColumn) * columnWidth, -8 - ((i - 1) % perColumn) * rowHeight)
				row:Show()
			end
			for i = count + 1, #rows do
				rows[i]:Hide()
				rows[i].entry = nil
			end
			list:SetSize(columns * columnWidth + 16, perColumn * rowHeight + 16)
			list:ClearAllPoints()
			list:SetPoint(point, button, relativePoint, x, y)
			list:SetFrameLevel(button:GetFrameLevel() + 20)
			SetBorderPixels()
			list:Show()
		end

		-- Open the list for a button or close it if it's already open for that button
		function popup:Toggle(button, ...)
			if list:IsShown() and owner == button then
				list:Hide()
			else
				self:Open(button, ...)
			end
		end

		return popup

	end

	----------------------------------------------------------------------
	-- L00: Leatrix Maps
	----------------------------------------------------------------------

	-- Main function
	function LeaMapsLC:MainFunc()

		-- Load Battlefield addon
		if not C_AddOns.IsAddOnLoaded("Blizzard_BattlefieldMap") then
			LoadAddOnWithErrorHandling("Blizzard_BattlefieldMap")
		end

		-- Get player faction
		local playerFaction = UnitFactionGroup("player")

		-- Remove blackout frame
		if LeaMapsLC["HideBlackoutFrame"] == "On" then
			WorldMapFrame.BlackoutFrame:SetAlpha(0)
			WorldMapFrame.BlackoutFrame:EnableMouse(false)
		end

		-- Hide the world map tutorial button
		WorldMapFrame.BorderFrame.Tutorial:HookScript("OnShow", WorldMapFrame.BorderFrame.Tutorial.Hide)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)

		----------------------------------------------------------------------
		-- Simple map frame
		----------------------------------------------------------------------

		-- Map theme (simple map frame only, ApplyMapTheme is set when the simple map frame is created)
		-- mapTheme holds the parts the theme colors (title bar, buttons, menus, lists, coordinates background)
		local ApplyMapTheme, mapTheme = nil, {}

		if LeaMapsLC["SimpleMapFrame"] == "On" and not LeaLockList["SimpleMapFrame"] then

			-- Function to check if a frame can be changed (protected frames cannot be changed during combat)
			local function CanChange(frame)
				return not InCombatLockdown() or not frame:IsProtected()
			end

			-- Function to hide a frame or texture permanently
			local function HideFrame(frame)
				frame:SetAlpha(0)
				if frame:IsObjectType("Frame") then
					if CanChange(frame) then
						frame:Hide()
						frame:EnableMouse(false)
					end
					frame:HookScript("OnShow", function()
						if CanChange(frame) then frame:Hide() else frame:SetAlpha(0) end
					end)
				end
			end

			----------------------------------------------------------------------
			-- Hide map elements
			----------------------------------------------------------------------

			-- Hide border, portrait, title and maximise button (but not close button)
			for i, v in pairs({WorldMapFrame.BorderFrame:GetRegions()}) do
				HideFrame(v)
			end
			for i, v in pairs({WorldMapFrame.BorderFrame:GetChildren()}) do
				if v ~= WorldMapFrame.BorderFrame.CloseButton and v ~= WorldMapFrame.BorderFrame.MaximizeMinimizeFrame then
					HideFrame(v)
				end
			end

			-- Hide border background (the game moves it from the border frame to the map frame)
			HideFrame(WorldMapFrame.BorderFrame.Bg)

			-- Hide navigation bar
			HideFrame(WorldMapFrame.NavBar)

			----------------------------------------------------------------------
			-- Create map frame
			----------------------------------------------------------------------

			local frameLevel = math.min(WorldMapFrame:GetFrameLevel() + 2000, 9000)

			-- Create border (covers the map and the quest log when it's shown)
			local borderFrame = CreateFrame("Frame", nil, WorldMapFrame, "BackdropTemplate")
			borderFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel())
			borderFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
			borderFrame:SetBackdropColor(0, 0, 0, 0.9)

			-- Create black edge with a soft drop shadow around the border (sized in whole screen pixels in SetPixelEdges)
			-- (the shadow layers stack so the shadow fades out naturally from the edge)
			local edgeTextures = {}
			for i = 1, 5 do
				local tex = borderFrame:CreateTexture(nil, "BACKGROUND", nil, -8 + i)
				tex:SetTexture("Interface\\Buttons\\WHITE8X8")
				if i == 5 then tex:SetVertexColor(0, 0, 0, 1) else tex:SetVertexColor(0, 0, 0, 0.12) end
				edgeTextures[i] = tex
			end

			-- Create title bar (uses the space left by the navigation bar)
			local titleFrame = CreateFrame("Frame", nil, WorldMapFrame)
			titleFrame:SetFrameStrata("HIGH")
			titleFrame:SetFrameLevel(frameLevel)
			titleFrame:SetHeight(22)

			-- Assign file level scope to title bar (needed for Unlock map frame)
			LeaMapsCB["MapTitleFrame"] = titleFrame

			local titleTexture = titleFrame:CreateTexture(nil, "BACKGROUND")
			titleTexture:SetAllPoints()
			titleTexture:SetTexture("Interface\\Buttons\\WHITE8X8") -- Colors are set by the map theme
			mapTheme.titleBar = titleFrame
			mapTheme.titleTexture = titleTexture

			-- Create frame for title bar text
			local titleTextFrame = CreateFrame("Frame", nil, titleFrame)
			titleTextFrame:SetAllPoints()
			titleTextFrame:SetFrameLevel(frameLevel + 2)

			-- Create map title (centered over the map, positioned in the layout function)
			local titleText = titleTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			titleText:SetPoint("CENTER")
			titleText:SetWordWrap(false)

			-- Assign file level scope to map title (needed for Show zone menus)
			LeaMapsCB["MapTitleText"] = titleText

			-- Create quest count
			local questCount = titleTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			questCount:SetPoint("LEFT", 8, 0)

			-- Assign file level scope to quest count (needed for Show zone menus)
			LeaMapsCB["MapQuestCount"] = questCount

			----------------------------------------------------------------------
			-- Title bar buttons
			----------------------------------------------------------------------

			-- Set button sizes to fit the title bar
			WorldMapFrame.BorderFrame.CloseButton:SetSize(20, 20)
			WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:SetSize(20, 20)

			-- Function to replace button art with a white icon (the button still works as normal)
			-- The icon and hover box colors are set by the map theme (the icon turns white on hover)
			mapTheme.buttons = {}
			local function SetButtonIcon(button, file, left, right, top, bottom)
				for i, v in pairs({button:GetNormalTexture(), button:GetPushedTexture(), button:GetHighlightTexture(), button:GetDisabledTexture()}) do
					v:SetAlpha(0)
				end
				-- Hover background
				local box = button:CreateTexture(nil, "BACKGROUND")
				box:SetAllPoints()
				box:SetTexture("Interface\\Buttons\\WHITE8X8")
				box:Hide()
				-- Icon
				local icon = button:CreateTexture(nil, "OVERLAY")
				icon:SetTexture("Interface\\AddOns\\Leatrix_Maps\\" .. file)
				if left then icon:SetTexCoord(left, right, top, bottom) end
				icon:SetAllPoints()
				local entry = {box = box, icon = icon, color = {0.8, 0.8, 0.8}}
				icon:SetVertexColor(unpack(entry.color))
				mapTheme.buttons[#mapTheme.buttons + 1] = entry
				button:HookScript("OnEnter", function()
					box:Show()
					icon:SetVertexColor(1, 1, 1)
				end)
				button:HookScript("OnLeave", function()
					box:Hide()
					icon:SetVertexColor(unpack(entry.color))
				end)
			end

			-- Set button icons (the close cross, maximise and restore icons are in Leatrix_Maps.blp)
			SetButtonIcon(WorldMapFrame.BorderFrame.CloseButton, "Leatrix_Maps.blp", 0, 0.125, 0.25, 0.5)
			SetButtonIcon(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, "Leatrix_Maps.blp", 0.25, 0.5, 0.5, 1)
			SetButtonIcon(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton, "Leatrix_Maps.blp", 0.5, 0.75, 0.5, 1)

			-- Restyle quest search box to match the title bar (flat dark box filling the gap between the gold lines)
			local searchBox = QuestScrollFrame.SearchBox
			if searchBox then

				-- Hide the default rounded box art (alpha is never changed by Blizzard)
				for i, key in pairs({"Left", "Middle", "Mid", "Right"}) do
					if searchBox[key] then searchBox[key]:SetAlpha(0) end
				end

				-- Background (fills the title bar gap without covering the gold lines)
				local searchBg = searchBox:CreateTexture(nil, "BACKGROUND")
				searchBg:SetPoint("TOPLEFT", -4, -1)
				searchBg:SetPoint("BOTTOMRIGHT", 0, 0)

				-- Set background color (slightly lighter while typing, colors are set by the map theme)
				local function SetSearchBg(focused)
					local color = focused and mapTheme.searchFocused or mapTheme.searchNormal
					if color then
						searchBg:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
					elseif focused then
						searchBg:SetColorTexture(0.19, 0.18, 0.17, 1)
					else
						searchBg:SetColorTexture(0.13, 0.12, 0.11, 1)
					end
				end
				SetSearchBg(false)
				searchBox:HookScript("OnEditFocusGained", function() SetSearchBg(true) end)
				searchBox:HookScript("OnEditFocusLost", function() SetSearchBg(false) end)
				mapTheme.SetSearchBg = function() SetSearchBg(searchBox:HasFocus()) end

			end

			----------------------------------------------------------------------
			-- Map title bar and quest count
			----------------------------------------------------------------------

			-- Function to set map title
			local function SetMapTitle()
				local mapID = WorldMapFrame.mapID
				if mapID then
					local mapInfo = C_Map.GetMapInfo(mapID)
					if mapInfo then
						titleText:SetText(mapInfo.name)
					end
				end
			end

			-- Set map title when map is changed
			hooksecurefunc(WorldMapFrame, "OnMapChanged", SetMapTitle)

			-- Function to set quest count
			local function SetQuestCount()
				local numQuests = 0
				for i = 1, C_QuestLog.GetNumQuestLogEntries() do
					local info = C_QuestLog.GetInfo(i)
					if info and not info.isHeader and not info.isHidden and not info.isTask and not info.isBounty then
						numQuests = numQuests + 1
					end
				end
				local maxQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
				if numQuests > maxQuests then
					questCount:SetFormattedText("%s%d|r/%d", RED_FONT_COLOR_CODE, numQuests, maxQuests)
				else
					questCount:SetFormattedText("%s%d|r/%d", "|cffffffff", numQuests, maxQuests)
				end
			end

			----------------------------------------------------------------------
			-- Map frame layout
			----------------------------------------------------------------------

			local detailsHeight, detailsScrollHeight

			-- Function to set the border and its edge in whole screen pixels (so the edge is the same width all the way
			-- round at any map scale or UI scale). The border is 1 pixel bigger than the map, then 1 pixel of black edge
			-- and 4 pixels of shadow.
			local edgeQuestWidth = 0
			local function SetPixelEdges()
				local scale = borderFrame:GetEffectiveScale()
				if issecretvalue and issecretvalue(scale) then return end -- Frame scales can be secret in combat
				local px = PixelUtil and PixelUtil.GetNearestPixelSize(1, scale, 1) or 1
				borderFrame:ClearAllPoints()
				borderFrame:SetPoint("TOPLEFT", titleFrame, "TOPLEFT", -px, px)
				local footer = mapTheme.footerFrame
				if footer and WorldMapFrame:IsMaximized() then
					-- Maximised map fills the screen so the coordinates footer goes inside the bottom of the map
					footer:ClearAllPoints()
					-- (it stops short of the quest log toggle button in the bottom right corner so the button can be seen and
					-- clicked, the button is only looked at, never changed)
					local gap = 0
					local toggle = WorldMapFrame.SidePanelToggle
					if not toggle then
						for void, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
							if frame.OpenButton and frame.CloseButton then toggle = frame break end
						end
					end
					if toggle and toggle:IsShown() then
						local width = toggle:GetWidth()
						gap = (width and not (issecretvalue and issecretvalue(width)) and width or 32) + 4
					end
					footer:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer, "BOTTOMLEFT", 0, 0)
					footer:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", -gap, 0)
					mapTheme.PlaceCoords(true)
					borderFrame:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", edgeQuestWidth + px, -px)
				elseif footer then
					-- Coordinates footer under the map and quest log (the border goes round it)
					footer:ClearAllPoints()
					footer:SetPoint("TOPLEFT", WorldMapFrame.ScrollContainer, "BOTTOMLEFT", 0, 0)
					footer:SetPoint("TOPRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", edgeQuestWidth, 0)
					mapTheme.PlaceCoords(false)
					borderFrame:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", px, -px)
				else
					borderFrame:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", edgeQuestWidth + px, -px)
				end
				local pads = mapTheme.pads -- Casing round the border (Retro TV and Handheld themes), left, right, top and bottom
				local pl, pr, pt, pb = 0, 0, 0, 0
				if pads then pl, pr, pt, pb = pads[1], pads[2], pads[3], pads[4] end
				for i = 1, #edgeTextures do
					local out = (i == 5 and 1 or 6 - i) * px -- Edge 1 pixel out, shadow 2 to 5 pixels out
					local tex = edgeTextures[i]
					tex:ClearAllPoints()
					tex:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -out - pl, out + pt)
					tex:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", out + pr, -out - pb)
				end
				-- Glass theme rim is 1 screen pixel wide
				if mapTheme.SizeGlassRim then mapTheme.SizeGlassRim(px) end
				-- Clickable area for themes with a casing
				if LeaMapsLC.SetCasingHitRect then LeaMapsLC.SetCasingHitRect() end
			end

			-- Map frame clickable area for themes with a casing (Retro TV and Handheld). The casing is outside the map frame,
			-- so while one of those themes is used the clickable area is made to match the border plus the casing (plus the
			-- Unlock map frame grab area when frame movement is on), so clicking the casing doesn't click the game world.
			-- Other themes keep the normal clickable area (Unlock map frame sets it, or it's put back to what it was). It's
			-- not changed while the map frame can't be changed (in combat when it's protected), it's set again when combat
			-- ends. It's set now and once more on the next frame, after the game has finished laying out the map.
			local casingHitSet, casingHitQueued, casingHitSaved
			local function SetCasingHitRectNow()
				local pads = mapTheme.pads
				if not pads then
					-- Not a casing theme, put the normal clickable area back if a casing theme changed it
					if casingHitSet and LeaMapsLC:CanChangeMap() then
						casingHitSet = nil
						if LeaMapsLC.RestoreMapHitRect then
							LeaMapsLC.RestoreMapHitRect()
						elseif casingHitSaved then
							WorldMapFrame:SetHitRectInsets(casingHitSaved[1], casingHitSaved[2], casingHitSaved[3], casingHitSaved[4])
						else
							WorldMapFrame:SetHitRectInsets(0, 0, 0, 0)
						end
					end
					return
				end
				if not LeaMapsLC:CanChangeMap() then return end
				local mL, mR, mT, mB = WorldMapFrame:GetLeft(), WorldMapFrame:GetRight(), WorldMapFrame:GetTop(), WorldMapFrame:GetBottom()
				local bL, bR, bT, bB = borderFrame:GetLeft(), borderFrame:GetRight(), borderFrame:GetTop(), borderFrame:GetBottom()
				if not (mL and mR and mT and mB and bL and bR and bT and bB) then return end
				if issecretvalue then
					for void, v in ipairs({mL, mR, mT, mB, bL, bR, bT, bB}) do
						if issecretvalue(v) then return end -- Can be secret in combat
					end
				end
				-- Keep the clickable area from before the first change (used to put it back if Unlock map frame is off)
				if not casingHitSaved and not LeaMapsLC.RestoreMapHitRect then
					local l, r, t, b = WorldMapFrame:GetHitRectInsets()
					if l and not (issecretvalue and (issecretvalue(l) or issecretvalue(r) or issecretvalue(t) or issecretvalue(b))) then
						casingHitSaved = {l, r, t, b}
					end
				end
				local grab = (LeaMapsLC["UnlockMap"] == "On" and LeaMapsLC["EnableMovement"] == "On") and 10 or 0
				WorldMapFrame:SetHitRectInsets(bL - mL - grab - pads[1], mR - bR - grab - pads[2], mT - bT - grab - pads[3], bB - mB - grab - pads[4])
				casingHitSet = true
			end
			local function CasingHitQueued()
				casingHitQueued = nil
				SetCasingHitRectNow()
			end
			LeaMapsLC.SetCasingHitRect = function()
				SetCasingHitRectNow()
				if not casingHitQueued then
					casingHitQueued = true
					C_Timer.After(0, CasingHitQueued)
				end
			end
			-- Set it again when combat ends (in case it couldn't be changed during combat)
			LeaMapsLC:AddMapLock(function(lock)
				if not lock then LeaMapsLC.SetCasingHitRect() end
			end)

			-- Make an edge function available to code that changes the map scale. It sets the edge now and once more on
			-- the next frame, after the game has finished laying out the scaled map. Only one next-frame pass is queued
			-- at a time.
			local edgeQueued
			local function EdgeQueued()
				edgeQueued = nil
				SetPixelEdges()
			end
			LeaMapsLC.RefreshMapLines = function()
				SetPixelEdges()
				if not edgeQueued then
					edgeQueued = true
					C_Timer.After(0, EdgeQueued)
				end
			end

			-- Update the edge when the UI scale or resolution changes
			local edgeEvents = CreateFrame("Frame")
			edgeEvents:RegisterEvent("UI_SCALE_CHANGED")
			edgeEvents:RegisterEvent("DISPLAY_SIZE_CHANGED")
			edgeEvents:SetScript("OnEvent", function() LeaMapsLC.RefreshMapLines() end)

			-- Function to set map frame layout
			local function SetFrameLayout()

				-- Get quest log width (if it's shown)
				local questWidth = 0
				if QuestMapFrame:IsShown() then questWidth = WorldMapFrame.questLogWidth end

				-- Set title bar and border to cover the map and quest log
				titleFrame:ClearAllPoints()
				titleFrame:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer, "TOPLEFT", 0, 0)
				titleFrame:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "TOPRIGHT", questWidth, 0)
				edgeQuestWidth = questWidth
				SetPixelEdges()

				-- Center map title over the map (the quest log part of the title bar is used by the search box)
				titleText:ClearAllPoints()
				titleText:SetPoint("CENTER", titleFrame, "CENTER", -questWidth / 2, 0)

				-- Move filter button inside the map (it's anchored to the navigation bar which is hidden)
				local filterButton = WorldMapFrame.WorldMapTrackingOptionsButton
				if filterButton and CanChange(filterButton) then
					filterButton:ClearAllPoints()
					filterButton:SetPoint("TOPRIGHT", WorldMapFrame.ScrollContainer, "TOPRIGHT", -4, -2)
				end

				-- Move close button to the right of the title bar
				local closeButton = WorldMapFrame.BorderFrame.CloseButton
				if CanChange(closeButton) then
					closeButton:ClearAllPoints()
					closeButton:SetPoint("RIGHT", titleFrame, "RIGHT", -2, 0)
					closeButton:SetFrameLevel(frameLevel + 5)
				end

				-- Show maximise button in the title bar (it's anchored to the left of the close button)
				local maxButton = WorldMapFrame.BorderFrame.MaximizeMinimizeFrame
				if CanChange(maxButton) then
					maxButton:ClearAllPoints()
					maxButton:SetPoint("RIGHT", closeButton, "LEFT", -2, 0)
					maxButton:SetFrameLevel(frameLevel + 6)
					for i, v in pairs({maxButton:GetChildren()}) do
						v:SetFrameLevel(frameLevel + 7)
					end
				end

				if QuestMapFrame:IsShown() and CanChange(QuestScrollFrame) then

					-- Move quest list under the title bar (so it's the same height as the map)
					QuestScrollFrame:ClearAllPoints()
					QuestScrollFrame:SetPoint("TOPLEFT", QuestScrollFrame:GetParent(), "TOPLEFT", 0, -50)
					QuestScrollFrame:SetPoint("BOTTOMRIGHT", QuestScrollFrame:GetParent(), "BOTTOMRIGHT", 0, 0)

					-- Move map legend and events under the title bar too (the same as the quest list, their own title then sits
					-- behind the title bar instead of poking out above the map frame)
					local contents = QuestMapFrame.ContentsAnchor
					if contents then
						for void, frame in ipairs({QuestMapFrame.MapLegend, QuestMapFrame.EventsFrame}) do
							if frame and CanChange(frame) then
								frame:ClearAllPoints()
								frame:SetPoint("TOPLEFT", contents, "TOPLEFT", 0, -50)
								frame:SetPoint("BOTTOMRIGHT", contents, "BOTTOMRIGHT", -22, 0)
							end
						end
					end

					-- Move quest details under the title bar and shorten it so the bottom stays in place
					local detailsFrame = QuestMapFrame.DetailsFrame
					if CanChange(detailsFrame) and CanChange(detailsFrame.ScrollFrame) then
						if not detailsHeight then
							-- Frame sizes can be secret in combat (they are not stored then and are read again next time)
							local height, scrollHeight = detailsFrame:GetHeight(), detailsFrame.ScrollFrame:GetHeight()
							if not (issecretvalue and (issecretvalue(height) or issecretvalue(scrollHeight))) then
								detailsHeight, detailsScrollHeight = height, scrollHeight
							end
						end
						if detailsHeight then
							detailsFrame:ClearAllPoints()
							detailsFrame:SetPoint("TOPRIGHT", detailsFrame:GetParent(), "TOPRIGHT", 0, -47)
							detailsFrame:SetHeight(detailsHeight - 46)
							detailsFrame.ScrollFrame:SetHeight(detailsScrollHeight - 46)
							detailsFrame.Bg:SetPoint("BOTTOMLEFT", detailsFrame, "BOTTOMLEFT", 0, 0)
							detailsFrame.Bg:SetPoint("BOTTOMRIGHT", detailsFrame, "BOTTOMRIGHT", 0, 0)
						end
					end

					-- Move quest settings button to the left of the close button
					local settingsButton = QuestScrollFrame.SettingsDropdown
					if CanChange(settingsButton) and CanChange(maxButton) then
						settingsButton:ClearAllPoints()
						settingsButton:SetPoint("RIGHT", maxButton, "LEFT", -2, 0)
						settingsButton:SetFrameLevel(frameLevel + 5)
					end

					-- Move quest search box into the title bar (from the left of the quest log to the settings button)
					local searchBox = QuestScrollFrame.SearchBox
					if searchBox and CanChange(searchBox) and CanChange(settingsButton) then
						searchBox:ClearAllPoints()
						searchBox:SetPoint("LEFT", titleFrame, "RIGHT", -questWidth + 10, 1)
						searchBox:SetPoint("RIGHT", settingsButton, "LEFT", -6, 1)
						searchBox:SetHeight(17)
						searchBox:SetFrameLevel(frameLevel + 5)
					end

				end

			end

			-- Set map frame layout when map is shown, quest log is toggled and on startup
			WorldMapFrame:HookScript("OnShow", function()
				SetQuestCount()
				SetFrameLayout()
			end)
			hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", SetFrameLayout)
			QuestMapFrame:HookScript("OnShow", SetFrameLayout)
			QuestMapFrame:HookScript("OnHide", SetFrameLayout)
			SetFrameLayout()
			SetQuestCount()

			-- Set quest count when quest log is updated and set map after combat
			local mapEvents = CreateFrame("Frame")
			mapEvents:RegisterEvent("QUEST_LOG_UPDATE")
			mapEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
			mapEvents:SetScript("OnEvent", function(self, event)
				if event == "QUEST_LOG_UPDATE" then
					SetQuestCount()
				elseif event == "PLAYER_REGEN_ENABLED" then
					if WorldMapFrame:IsShown() then SetFrameLayout() end
				end
			end)

			----------------------------------------------------------------------
			-- Map theme
			----------------------------------------------------------------------

			-- Map themes (the theme colors the title bar and coordinates background, the edge is black). The accent color is
			-- used for the title bar buttons and zone lists, the hover color for the zone menus.
			-- Themes with a base color (color = {r, g, b}) all use the same recipe as Class color: a dark wash of the color on
			-- the title bar and the color itself for the accents, so they look like a matching set.
			-- Theme numbers are saved, so new themes are added at the end (the dropdown sets the order they are listed in).
			local mapThemes = {
				-- 1: Classic (neutral black with a muted gold accent)
				{bgBottom = {0.04, 0.04, 0.04}, bgTop = {0.09, 0.09, 0.09}, accent = {0.45, 0.37, 0.20}, hover = {1, 1, 1, 0.12}},
				-- 2: Warm (dark brown with a bronze accent)
				{bgBottom = {0.06, 0.04, 0.02}, bgTop = {0.12, 0.08, 0.045}, accent = {0.55, 0.42, 0.22}, hover = {1, 0.85, 0.6, 0.14}},
				-- 3: Charcoal (cool slate)
				{bgBottom = {0.05, 0.05, 0.06}, bgTop = {0.13, 0.13, 0.15}, accent = {0.32, 0.36, 0.42}, hover = {0.75, 0.85, 1, 0.14}},
				-- 4: Class color (base color is the player's class color, filled in when the theme is applied)
				{classColor = true},
				-- 5: Pink
				{color = {1, 0.35, 0.70}},
				-- 6: Alliance
				{color = {0.25, 0.50, 1}},
				-- 7: Horde
				{color = {0.90, 0.15, 0.10}},
				-- 8: Purple
				{color = {0.60, 0.30, 1}},
				-- 9: Teal
				{color = {0.10, 0.80, 0.75}},
				-- 10: Green
				{color = {0.30, 0.85, 0.25}},
				-- 11: Rainbow (dark rainbow from left to right, violet accent to match the right-hand end)
				{rainbow = true, bgBottom = {0.04, 0.04, 0.04}, bgTop = {0.09, 0.09, 0.09}, accent = {0.65, 0.40, 1}, hover = {1, 1, 1, 0.15}},
				-- Themes 13 to 15 have the same numbers as in the other game versions (12 is a theme those versions have).
				-- 13: Glass (see-through frosted title bar and coordinates background with a bright rim and a light reflection,
				-- the game world shows through behind them, the map itself stays solid). bgBottom and bgTop have an alpha
				-- value, icon and box are the title bar button colors, list is the zone list and dungeon level menu colors
				-- (background, border and background alpha), search is the quest search box colors (normal and typing).
				[13] = {glass = true, bgBottom = {0.10, 0.12, 0.16, 0.50}, bgTop = {0.32, 0.37, 0.45, 0.40},
				accent = {0.85, 0.90, 1}, hover = {1, 1, 1, 0.18}, icon = {0.90, 0.94, 1}, box = {1, 1, 1, 0.22},
				list = {0.08, 0.10, 0.14, 0.75, 0.82, 0.92, 0.82}, search = {{0, 0, 0, 0.35}, {0, 0, 0, 0.55}}},
				-- 14: Handheld (the map is the screen of a chunky games handheld held sideways: a rounded charcoal black plastic
				-- body, a dark screen surround with a red power light, a D-pad on the left, A and B buttons and speaker holes
				-- on the right). pads is the body size on the left, right, top and bottom.
				[14] = {handheld = true, pads = {96, 96, 18, 30}, bgBottom = {0.07, 0.07, 0.09}, bgTop = {0.12, 0.115, 0.15}, accent = {0.80, 0.45, 0.70}, hover = {0.90, 0.55, 0.80, 0.20}, icon = {0.88, 0.85, 0.94},
				list = {0.12, 0.11, 0.15, 0.62, 0.58, 0.72, 0.97}},
				-- 15: Retro TV (the map is the screen of an old wooden TV: a wood casing with a dark bezel, a side panel with
				-- two knobs, a speaker grille and a power light, and scanlines, a dark vignette and a glass glare on the
				-- screen). pads is the casing size on the left, right, top and bottom.
				[15] = {tv = true, pads = {12, 62, 12, 16}, bgBottom = {0.04, 0.04, 0.04}, bgTop = {0.08, 0.08, 0.08}, accent = {0.80, 0.62, 0.30}, hover = {1, 0.85, 0.55, 0.15},
				list = {0.16, 0.10, 0.05, 0.80, 0.62, 0.30, 0.97}},
			}

			-- Rainbow colors (left to right) and how dark they are drawn so the text stays readable
			local rainbowColors = {{1, 0.15, 0.15}, {1, 0.55, 0.10}, {1, 0.90, 0.15}, {0.25, 0.90, 0.30}, {0.20, 0.50, 1}, {0.65, 0.35, 1}}
			local rainbowShade = 0.30

			-- Function to get the rainbow for a bar (created the first time the rainbow theme is used)
			-- (inset keeps the rainbow inside a border, such as the zone list's 1 pixel border)
			local function GetRainbow(bar, inset)
				if bar.leaRainbow then return bar.leaRainbow end
				inset = inset or 0
				local rainbow = {}
				local count = #rainbowColors - 1
				for i = 1, count do
					local seg = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
					seg:SetTexture("Interface\\Buttons\\WHITE8X8")
					local c1, c2 = rainbowColors[i], rainbowColors[i + 1]
					seg:SetGradient("HORIZONTAL", CreateColor(c1[1] * rainbowShade, c1[2] * rainbowShade, c1[3] * rainbowShade, 1), CreateColor(c2[1] * rainbowShade, c2[2] * rainbowShade, c2[3] * rainbowShade, 1))
					if i == 1 then
						seg:SetPoint("TOPLEFT", inset, -inset); seg:SetPoint("BOTTOMLEFT", inset, inset)
					else
						seg:SetPoint("TOPLEFT", rainbow[i - 1], "TOPRIGHT"); seg:SetPoint("BOTTOMLEFT", rainbow[i - 1], "BOTTOMRIGHT")
					end
					if i == count then
						seg:SetPoint("TOPRIGHT", -inset, -inset); seg:SetPoint("BOTTOMRIGHT", -inset, inset)
					end
					rainbow[i] = seg
				end
				-- Shade the bottom of the bar like the other themes
				local shade = bar:CreateTexture(nil, "BACKGROUND", nil, 2)
				shade:SetPoint("TOPLEFT", inset, -inset); shade:SetPoint("BOTTOMRIGHT", -inset, inset)
				shade:SetTexture("Interface\\Buttons\\WHITE8X8")
				shade:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.45), CreateColor(0, 0, 0, 0))
				rainbow.shade = shade
				-- Keep the segments evenly spaced when the bar changes size (the last one fills the rest)
				local function SetWidths()
					local barWidth = bar:GetWidth()
					if issecretvalue and issecretvalue(barWidth) then return end -- Frame sizes can be secret in combat
					local width = (barWidth - inset * 2) / count
					for i = 1, count - 1 do rainbow[i]:SetWidth(width) end
				end
				bar:HookScript("OnSizeChanged", SetWidths)
				SetWidths()
				bar.leaRainbow = rainbow
				return rainbow
			end

			-- Function to get the rainbow color for a list row (rows run through the rainbow from top to bottom)
			local function RainbowRowColor(index, count)
				local pos = count > 1 and (index - 1) / (count - 1) * (#rainbowColors - 1) or 0
				local i = math.min(math.floor(pos) + 1, #rainbowColors - 1)
				local f = pos - (i - 1)
				local c1, c2 = rainbowColors[i], rainbowColors[i + 1]
				return c1[1] + (c2[1] - c1[1]) * f, c1[2] + (c2[2] - c1[2]) * f, c1[3] + (c2[3] - c1[3]) * f
			end

			-- Function to show or hide the rainbow on a bar
			local function SetRainbow(bar, show, inset)
				if not show and not bar.leaRainbow then return end
				local rainbow = GetRainbow(bar, inset)
				for i = 1, #rainbow do
					if show then rainbow[i]:Show() else rainbow[i]:Hide() end
				end
				if show then rainbow.shade:Show() else rainbow.shade:Hide() end
			end

			-- Glass theme parts (a 1 pixel rim round the frame and a light reflection on the top of the title bar, created
			-- the first time the theme is used)
			local glassRim, glassSheen, glassPx = nil, nil, 1

			-- Function to set the rim to 1 screen pixel (runs from SetPixelEdges)
			local function SizeGlassRim(px)
				glassPx = px
				if not glassRim then return end
				local top, bottom, left, right = glassRim[1], glassRim[2], glassRim[3], glassRim[4]
				top:ClearAllPoints(); top:SetPoint("TOPLEFT", borderFrame); top:SetPoint("TOPRIGHT", borderFrame); top:SetHeight(px)
				bottom:ClearAllPoints(); bottom:SetPoint("BOTTOMLEFT", borderFrame); bottom:SetPoint("BOTTOMRIGHT", borderFrame); bottom:SetHeight(px)
				left:ClearAllPoints(); left:SetPoint("TOPLEFT", borderFrame, 0, -px); left:SetPoint("BOTTOMLEFT", borderFrame, 0, px); left:SetWidth(px)
				right:ClearAllPoints(); right:SetPoint("TOPRIGHT", borderFrame, 0, -px); right:SetPoint("BOTTOMRIGHT", borderFrame, 0, px); right:SetWidth(px)
			end
			mapTheme.SizeGlassRim = SizeGlassRim

			-- Function to show or hide the Glass theme (the frame background, edge and shadow are removed so the game world
			-- shows through the see-through title bar and coordinates background)
			local function SetGlass(show)
				if show and not glassRim then
					glassRim = {}
					for i = 1, 4 do
						glassRim[i] = borderFrame:CreateTexture(nil, "BORDER")
						glassRim[i]:SetTexture("Interface\\Buttons\\WHITE8X8")
						glassRim[i]:SetVertexColor(1, 1, 1, 0.55)
					end
					SizeGlassRim(glassPx)
					glassSheen = titleFrame:CreateTexture(nil, "BACKGROUND", nil, 4)
					glassSheen:SetTexture("Interface\\Buttons\\WHITE8X8")
					glassSheen:SetPoint("TOPLEFT"); glassSheen:SetPoint("TOPRIGHT")
					glassSheen:SetHeight(11)
					glassSheen:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, 0.12))
				end
				if glassRim then
					for i = 1, 4 do glassRim[i]:SetShown(show) end
					glassSheen:SetShown(show)
				end
				borderFrame:SetBackdropColor(0, 0, 0, show and 0 or 0.9)
				-- The Blizzard theme hides the edge and shadow for its own art
				if not mapTheme.blizzard then
					for i = 1, #edgeTextures do edgeTextures[i]:SetShown(not show) end
				end
			end

			-- Retro TV theme (created the first time the theme is used). The casing, bezel, knobs, grille and power light are
			-- textures on the border frame (the lowest part of the map frame, so the map and bars always draw above them).
			-- The scanlines, vignette and glare are on a frame of our own over the map (it takes no mouse clicks).
			local tvParts, tvScreen, tvScanlines = nil, nil, {}
			local tvPowerRing, tvPowerPointer, tvLight, tvGlow -- Power knob ring and pointer, power light and its glow
			local tvHoldRing, tvHoldPointer -- Vertical hold knob ring and pointer
			local tvWhite = "Interface\\Buttons\\WHITE8X8"

			-- Function to create a texture on the border frame
			local function TVTexture(layer, sublevel, r, g, b, a)
				local t = borderFrame:CreateTexture(nil, layer, nil, sublevel)
				t:SetTexture(tvWhite)
				t:SetVertexColor(r, g, b, a)
				tvParts[#tvParts + 1] = t
				return t
			end

			-- Function to make a texture round (square if the game's round mask is not in the client)
			local function MakeRound(t)
				if not borderFrame.CreateMaskTexture then return end
				local mask = borderFrame:CreateMaskTexture()
				mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
				mask:SetAllPoints(t)
				t:AddMaskTexture(mask)
			end

			-- Function to create a knob (dark ring, metal face, center cap and a pointer at an angle in degrees)
			local function CreateKnob(y, angle)
				local ring = TVTexture("ARTWORK", 0, 0.10, 0.07, 0.05, 1)
				ring:SetSize(36, 36)
				ring:SetPoint("CENTER", borderFrame, "TOPRIGHT", 36, y)
				MakeRound(ring)
				local face = TVTexture("ARTWORK", 1, 1, 1, 1, 1)
				face:SetSize(30, 30)
				face:SetPoint("CENTER", ring)
				face:SetGradient("VERTICAL", CreateColor(0.28, 0.26, 0.23, 1), CreateColor(0.68, 0.64, 0.57, 1))
				MakeRound(face)
				local cap = TVTexture("ARTWORK", 2, 0.20, 0.18, 0.16, 1)
				cap:SetSize(10, 10)
				cap:SetPoint("CENTER", ring)
				MakeRound(cap)
				local pointer = borderFrame:CreateLine(nil, "ARTWORK", nil, 3)
				pointer:SetThickness(2)
				pointer:SetColorTexture(0.95, 0.92, 0.85, 1)
				local rad = math.rad(angle)
				pointer:SetStartPoint("CENTER", ring, math.cos(rad) * 5, math.sin(rad) * 5)
				pointer:SetEndPoint("CENTER", ring, math.cos(rad) * 13, math.sin(rad) * 13)
				tvParts[#tvParts + 1] = pointer
				return ring, pointer
			end

			-- Function to lay out the scanlines (one line every 3 units down the screen, more are made if the map gets taller)
			local function LayoutScanlines()
				if not tvScreen or not tvScreen:IsShown() then return end
				local h = tvScreen:GetHeight()
				if not h or (issecretvalue and issecretvalue(h)) or h <= 0 then return end
				local count = math.floor(h / 3)
				for i = 1, count do
					local line = tvScanlines[i]
					if not line then
						line = tvScreen:CreateTexture(nil, "ARTWORK")
						line:SetTexture(tvWhite)
						line:SetVertexColor(0, 0, 0, 0.13)
						line:SetPoint("TOPLEFT", 0, -3 * i)
						line:SetPoint("TOPRIGHT", 0, -3 * i)
						line:SetHeight(1)
						tvScanlines[i] = line
					end
					line:Show()
				end
				for i = count + 1, #tvScanlines do tvScanlines[i]:Hide() end
			end

			-- Power knob (the top knob turns the TV off and on like an old TV: turning it off squeezes the picture into a
			-- bright line, then into a dot that fades away, turning it on draws the dot out into a line that opens up into
			-- the picture). The map stays open. While the TV is off the screen is covered by a frame of our own which takes
			-- the mouse, so nothing on the dark screen can be clicked by mistake. The TV is always on when the map is opened.
			-- The animation runs in an OnUpdate that is only set while it plays (about half a second).
			local tvPower, tvPowerParts, tvPowerButton, tvPowerHighlight
			local tvPowerOn, tvPowerAnim, tvPowerTime, tvPowerResetting = true, nil, 0, false

			-- Function to ease a value from 0 to 1 (fast at the start, slow at the end)
			local function PowerEase(f) return 1 - (1 - f) * (1 - f) end

			-- Function to set the knob pointer and power light for on or off
			local function SetPowerKnob(on)
				local rad = math.rad(on and 120 or 210)
				tvPowerPointer:SetStartPoint("CENTER", tvPowerRing, math.cos(rad) * 5, math.sin(rad) * 5)
				tvPowerPointer:SetEndPoint("CENTER", tvPowerRing, math.cos(rad) * 13, math.sin(rad) * 13)
				if on then tvLight:SetVertexColor(1, 0.30, 0.15, 1) else tvLight:SetVertexColor(0.25, 0.08, 0.05, 1) end
				tvGlow:SetAlpha(on and 1 or 0)
			end

			-- Function to draw the screen cover (bg: dark screen, cv: height of the dark top and bottom, ch: width of the
			-- dark left and right, bw, bh and ba: size and alpha of the bright band in the middle, ds and da: size and alpha
			-- of the bright dot in the middle)
			local function PowerDraw(bg, cv, ch, bw, bh, ba, ds, da)
				local p = tvPowerParts
				p.bg:SetShown(bg)
				p.top:SetShown(cv > 0); p.bottom:SetShown(cv > 0)
				if cv > 0 then p.top:SetHeight(cv); p.bottom:SetHeight(cv) end
				p.left:SetShown(ch > 0); p.right:SetShown(ch > 0)
				if ch > 0 then p.left:SetWidth(ch); p.right:SetWidth(ch) end
				p.band:SetShown(ba > 0)
				if ba > 0 then p.band:SetSize(math.max(bw, 1), math.max(bh, 1)); p.band:SetAlpha(ba) end
				p.dot:SetShown(da > 0); p.glow:SetShown(da > 0)
				if da > 0 then p.dot:SetSize(ds, ds); p.dot:SetAlpha(da); p.glow:SetAlpha(da * 0.6) end
			end

			-- Function to play the animation (runs every frame while it plays)
			local function PowerUpdate(self, elapsed)
				tvPowerTime = tvPowerTime + elapsed
				local t = tvPowerTime
				local w, h = self:GetWidth(), self:GetHeight()
				if not w or not h or (issecretvalue and (issecretvalue(w) or issecretvalue(h))) then
					w, h, t = 0, 0, 99 -- Size can't be read so skip to the end
				end
				if tvPowerAnim == "off" then
					if t < 0.15 then
						-- Picture squeezes into a bright line
						local f = PowerEase(t / 0.15)
						local gap = h * (1 - f) + 2 * f
						PowerDraw(false, (h - gap) / 2, 0, w, gap, 0.85 * f, 0, 0)
					elseif t < 0.30 then
						-- Line shrinks to a dot
						local f = PowerEase((t - 0.15) / 0.15)
						local bw = w * (1 - f) + 6 * f
						PowerDraw(false, (h - 2) / 2, (w - bw) / 2, bw, 2, 1, 0, 0)
					elseif t < 0.65 then
						-- Dot fades away
						local f = (t - 0.30) / 0.35
						PowerDraw(true, 0, 0, 0, 0, 0, 7 - 3 * f, 1 - f)
					else
						PowerDraw(true, 0, 0, 0, 0, 0, 0, 0)
						tvPowerAnim = nil
						self:SetScript("OnUpdate", nil)
					end
				elseif tvPowerAnim == "on" then
					if t < 0.12 then
						-- Dot lights up
						PowerDraw(true, 0, 0, 0, 0, 0, 7, t / 0.12)
					elseif t < 0.26 then
						-- Dot draws out into a line
						local f = PowerEase((t - 0.12) / 0.14)
						PowerDraw(true, 0, 0, 6 + (w - 6) * f, 2, 1, 0, 0)
					elseif t < 0.44 then
						-- Line opens up into the picture
						local f = PowerEase((t - 0.26) / 0.18)
						local gap = 2 + (h - 2) * f
						PowerDraw(false, (h - gap) / 2, 0, w, gap, 0.9 - 0.55 * f, 0, 0)
					elseif t < 0.60 then
						-- Bright picture settles down
						PowerDraw(false, 0, 0, w, h, 0.35 * (1 - (t - 0.44) / 0.16), 0, 0)
					else
						tvPowerAnim = nil
						self:SetScript("OnUpdate", nil)
						self:Hide()
					end
				end
			end

			-- Power knob sounds (game sound files, each is the file ID, when it starts and, if it's a long one, when it fades
			-- out, in seconds from the click). Off: knob click, a tube shutting down and static fading with the dot. On: knob
			-- click, a small spark as the tube warms up and a burst of radio static as the picture opens up.
			local tvPowerSounds = {
				off = {{567407, 0}, {566159, 0.02, 0.40}, {569693, 0.12, 0.40}},		-- uchatscrollbutton, collectortubeshutdown, uni_fx_radiostatic_01
				on = {{567407, 0}, {2428610, 0.05}, {568039, 0.24, 0.75}},		-- uchatscrollbutton, fx_spark_cast_small_01, uni_fx_radiostatic_02
			}

			-- Function to play one power knob sound (fades it out after stopAfter seconds if it's a long one)
			local function PlayPowerSound(fileID, stopAfter)
				local willPlay, handle = PlaySoundFile(fileID, "Master")
				if willPlay and handle and stopAfter then
					C_Timer.After(stopAfter, function() StopSound(handle, 250) end)
				end
			end

			-- Function to play the power knob sounds for turning the TV on or off
			local function PlayPowerSounds(on)
				for void, sound in ipairs(tvPowerSounds[on and "on" or "off"]) do
					local fileID, start, stop = sound[1], sound[2], sound[3]
					if start > 0 then
						C_Timer.After(start, function() PlayPowerSound(fileID, stop and stop - start) end)
					else
						PlayPowerSound(fileID, stop)
					end
				end
			end

			-- Function to turn the TV off or on (a turn of the knob is ignored while the last one is still playing)
			local function TogglePower()
				if tvPowerAnim then return end
				tvPowerOn = not tvPowerOn
				SetPowerKnob(tvPowerOn)
				PlayPowerSounds(tvPowerOn)
				tvPowerAnim = tvPowerOn and "on" or "off"
				tvPowerTime = 0
				tvPower:Show()
				tvPower:SetScript("OnUpdate", PowerUpdate)
				PowerUpdate(tvPower, 0)
			end

			-- Function to turn the TV back on straight away (when the map is closed or the theme is changed)
			local function ResetPower()
				if not tvPower or tvPowerResetting then return end
				tvPowerResetting = true
				tvPowerOn, tvPowerAnim = true, nil
				tvPower:SetScript("OnUpdate", nil)
				tvPower:Hide()
				SetPowerKnob(true)
				tvPowerResetting = false
			end

			-- Function to create the screen cover and the knob button
			local function CreatePower()
				-- Screen cover (over the whole screen inside the bezel: title bar, map, quest log and coordinates)
				tvPower = CreateFrame("Frame", nil, WorldMapFrame)
				tvPower:SetFrameStrata("HIGH")
				tvPower:SetFrameLevel(math.min(frameLevel + 20, 10000))
				tvPower:SetAllPoints(borderFrame)
				tvPower:EnableMouse(true)
				tvPower:Hide()
				local function PowerTexture(layer, sublevel, r, g, b)
					local t = tvPower:CreateTexture(nil, layer, nil, sublevel)
					t:SetTexture(tvWhite)
					t:SetVertexColor(r, g, b, 1)
					return t
				end
				local function PowerRound(t)
					if not tvPower.CreateMaskTexture then return end
					local mask = tvPower:CreateMaskTexture()
					mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
					mask:SetAllPoints(t)
					t:AddMaskTexture(mask)
				end
				local p = {}
				p.bg = PowerTexture("BACKGROUND", 0, 0.015, 0.015, 0.02)
				p.bg:SetAllPoints()
				p.top = PowerTexture("BORDER", 0, 0.015, 0.015, 0.02)
				p.top:SetPoint("TOPLEFT"); p.top:SetPoint("TOPRIGHT")
				p.bottom = PowerTexture("BORDER", 0, 0.015, 0.015, 0.02)
				p.bottom:SetPoint("BOTTOMLEFT"); p.bottom:SetPoint("BOTTOMRIGHT")
				p.left = PowerTexture("BORDER", 0, 0.015, 0.015, 0.02)
				p.left:SetPoint("TOPLEFT"); p.left:SetPoint("BOTTOMLEFT")
				p.right = PowerTexture("BORDER", 0, 0.015, 0.015, 0.02)
				p.right:SetPoint("TOPRIGHT"); p.right:SetPoint("BOTTOMRIGHT")
				p.band = PowerTexture("ARTWORK", 0, 0.85, 0.92, 1)
				p.band:SetPoint("CENTER")
				p.glow = PowerTexture("OVERLAY", 0, 0.75, 0.85, 1)
				p.glow:SetSize(26, 26)
				p.glow:SetPoint("CENTER")
				PowerRound(p.glow)
				p.dot = PowerTexture("OVERLAY", 1, 1, 1, 1)
				p.dot:SetPoint("CENTER")
				PowerRound(p.dot)
				tvPowerParts = p
				-- Closing the map turns the TV back on for next time
				tvPower:SetScript("OnHide", ResetPower)
				-- Knob button (over the top knob, the knob lights up a little when the pointer is over it)
				tvPowerHighlight = TVTexture("ARTWORK", 4, 1, 1, 1, 0.18)
				tvPowerHighlight:SetSize(30, 30)
				tvPowerHighlight:SetPoint("CENTER", tvPowerRing)
				MakeRound(tvPowerHighlight)
				tvPowerButton = CreateFrame("Button", nil, borderFrame)
				tvPowerButton:SetSize(36, 36)
				tvPowerButton:SetPoint("CENTER", tvPowerRing)
				tvPowerButton:SetFrameStrata("HIGH")
				tvPowerButton:SetFrameLevel(math.min(frameLevel + 20, 10000))
				tvPowerButton:RegisterForClicks("LeftButtonUp")
				tvPowerButton:SetScript("OnClick", TogglePower)
				tvPowerButton:SetScript("OnEnter", function() tvPowerHighlight:SetAlpha(1) end)
				tvPowerButton:SetScript("OnLeave", function() tvPowerHighlight:SetAlpha(0) end)
				tvPowerHighlight:SetAlpha(0)
				tvParts[#tvParts + 1] = tvPowerButton
			end

			-- Vertical hold knob (the second knob, just for fun: the picture loses its vertical hold for a moment, so the
			-- dark bar between frames rolls down the screen three times, slowing down until the picture catches, with
			-- tearing lines and a flicker). It's drawn on a frame of our own over the screen which takes no mouse clicks.
			-- The animation runs in an OnUpdate that is only set while it plays.
			local tvHold, tvHoldParts, tvHoldButton, tvHoldHighlight
			local tvHoldTime, tvHoldTear, tvHoldLength = 0, 0, 1.4

			-- Function to set a knob pointer to an angle in degrees
			local function SetKnobAngle(ring, pointer, angle)
				local rad = math.rad(angle)
				pointer:SetStartPoint("CENTER", ring, math.cos(rad) * 5, math.sin(rad) * 5)
				pointer:SetEndPoint("CENTER", ring, math.cos(rad) * 13, math.sin(rad) * 13)
			end

			-- Function to play the animation (runs every frame while it plays)
			local function HoldUpdate(self, elapsed)
				tvHoldTime = tvHoldTime + elapsed
				local t = tvHoldTime
				local h = self:GetHeight()
				if t >= tvHoldLength or not h or (issecretvalue and issecretvalue(h)) then
					self:Hide() -- OnHide puts everything back
					return
				end
				local p = tvHoldParts
				-- Rolling bar (three rolls, slowing down, it ends just above the top of the screen so it's out of sight)
				local k = 1 - t / tvHoldLength
				local rolls = 3 * (1 - k * k * k)
				local barH = h * 0.22
				local y = (rolls % 1) * (h + barH) - barH
				p.barTop:ClearAllPoints()
				p.barTop:SetPoint("TOPLEFT", p.holder, "TOPLEFT", 0, -y)
				p.barTop:SetPoint("TOPRIGHT", p.holder, "TOPRIGHT", 0, -y)
				p.barTop:SetHeight(barH / 2)
				p.barBottom:SetHeight(barH / 2)
				-- Flicker (fades away as the picture catches)
				p.flicker:SetAlpha(math.random() * 0.07 * k)
				-- Tearing lines (new ones every few frames, fewer as the picture catches)
				tvHoldTear = tvHoldTear - elapsed
				if tvHoldTear <= 0 then
					tvHoldTear = 0.04
					for i = 1, #p.tears do
						local tear = p.tears[i]
						if math.random() < 0.75 * k then
							tear:ClearAllPoints()
							local ty = math.random() * h
							tear:SetPoint("TOPLEFT", p.holder, "TOPLEFT", 0, -ty)
							tear:SetPoint("TOPRIGHT", p.holder, "TOPRIGHT", 0, -ty)
							tear:SetHeight(math.random(1, 3))
							if math.random() < 0.5 then
								tear:SetVertexColor(1, 1, 1, 0.10 + math.random() * 0.15)
							else
								tear:SetVertexColor(0, 0, 0, 0.35)
							end
							tear:Show()
						else
							tear:Hide()
						end
					end
				end
			end

			-- Function to start the animation (not while the TV is off, turning on or off, or already rolling)
			local function StartHold()
				if not tvPowerOn or tvPowerAnim or tvHold:IsShown() then return end
				SetKnobAngle(tvHoldRing, tvHoldPointer, 75)
				-- Knob click and a short burst of static (uchatscrollbutton, uni_fx_radiostatic_03)
				PlayPowerSound(567407)
				C_Timer.After(0.02, function() PlayPowerSound(568977, 1.1) end)
				tvHoldTime, tvHoldTear = 0, 0
				tvHold:Show()
				tvHold:SetScript("OnUpdate", HoldUpdate)
				HoldUpdate(tvHold, 0) -- First frame straight away so nothing shows unplaced
			end

			-- Function to create the vertical hold effect and the knob button
			local function CreateHold()
				-- Effect frame over the whole screen inside the bezel (just below the power cover), its children are
				-- clipped to the screen so the rolling bar does not show outside it
				tvHold = CreateFrame("Frame", nil, WorldMapFrame)
				tvHold:SetFrameStrata("HIGH")
				tvHold:SetFrameLevel(math.min(frameLevel + 19, 10000))
				tvHold:SetAllPoints(borderFrame)
				tvHold:EnableMouse(false)
				tvHold:SetClipsChildren(true)
				tvHold:Hide()
				local p = {}
				p.holder = CreateFrame("Frame", nil, tvHold)
				p.holder:SetAllPoints()
				p.holder:EnableMouse(false)
				local function HoldTexture(layer)
					local t = p.holder:CreateTexture(nil, layer)
					t:SetTexture(tvWhite)
					return t
				end
				-- Rolling bar (dark in the middle, fading out at the top and bottom)
				local dark, clear = CreateColor(0, 0, 0, 0.85), CreateColor(0, 0, 0, 0)
				p.barTop = HoldTexture("ARTWORK")
				p.barTop:SetGradient("VERTICAL", dark, clear)
				p.barBottom = HoldTexture("ARTWORK")
				p.barBottom:SetPoint("TOPLEFT", p.barTop, "BOTTOMLEFT")
				p.barBottom:SetPoint("TOPRIGHT", p.barTop, "BOTTOMRIGHT")
				p.barBottom:SetGradient("VERTICAL", clear, dark)
				-- Flicker over the whole screen
				p.flicker = HoldTexture("BORDER")
				p.flicker:SetAllPoints()
				p.flicker:SetVertexColor(1, 1, 1, 1)
				p.flicker:SetAlpha(0)
				-- Tearing lines
				p.tears = {}
				for i = 1, 6 do
					p.tears[i] = HoldTexture("OVERLAY")
					p.tears[i]:Hide()
				end
				tvHoldParts = p
				-- Put everything back when it ends, the map is closed or the theme is changed
				tvHold:SetScript("OnHide", function(self)
					self:SetScript("OnUpdate", nil)
					SetKnobAngle(tvHoldRing, tvHoldPointer, 30)
				end)
				-- Knob button (over the second knob, the knob lights up a little when the pointer is over it)
				tvHoldHighlight = TVTexture("ARTWORK", 4, 1, 1, 1, 0.18)
				tvHoldHighlight:SetSize(30, 30)
				tvHoldHighlight:SetPoint("CENTER", tvHoldRing)
				MakeRound(tvHoldHighlight)
				tvHoldHighlight:SetAlpha(0)
				tvHoldButton = CreateFrame("Button", nil, borderFrame)
				tvHoldButton:SetSize(36, 36)
				tvHoldButton:SetPoint("CENTER", tvHoldRing)
				tvHoldButton:SetFrameStrata("HIGH")
				tvHoldButton:SetFrameLevel(math.min(frameLevel + 20, 10000))
				tvHoldButton:RegisterForClicks("LeftButtonUp")
				tvHoldButton:SetScript("OnClick", StartHold)
				tvHoldButton:SetScript("OnEnter", function() tvHoldHighlight:SetAlpha(1) end)
				tvHoldButton:SetScript("OnLeave", function() tvHoldHighlight:SetAlpha(0) end)
				tvParts[#tvParts + 1] = tvHoldButton
			end

			-- Function to create the TV
			local function CreateTV()
				tvParts = {}
				local pl, pr, pt, pb = 12, 62, 12, 16 -- Same as the theme casing size
				-- Wood casing (wood color, the game's frame background for grain and a darker bottom)
				local wood = TVTexture("BACKGROUND", -2, 0.40, 0.24, 0.12, 1)
				wood:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -pl, pt)
				wood:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", pr, -pb)
				local grain = TVTexture("BACKGROUND", -1, 0.55, 0.35, 0.18, 0.55)
				grain:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", "REPEAT", "REPEAT")
				grain:SetHorizTile(true)
				grain:SetVertTile(true)
				grain:SetAllPoints(wood)
				local shade = TVTexture("BACKGROUND", 0, 1, 1, 1, 1)
				shade:SetAllPoints(wood)
				shade:SetGradient("VERTICAL", CreateColor(0, 0, 0, 0.35), CreateColor(1, 0.9, 0.7, 0.06))
				-- Bevel (light top and left edge, dark bottom and right edge)
				local bevelTop = TVTexture("BACKGROUND", 1, 1, 0.85, 0.65, 0.30)
				bevelTop:SetPoint("TOPLEFT", wood); bevelTop:SetPoint("TOPRIGHT", wood); bevelTop:SetHeight(2)
				local bevelLeft = TVTexture("BACKGROUND", 1, 1, 0.85, 0.65, 0.20)
				bevelLeft:SetPoint("TOPLEFT", wood); bevelLeft:SetPoint("BOTTOMLEFT", wood); bevelLeft:SetWidth(2)
				local bevelBottom = TVTexture("BACKGROUND", 1, 0, 0, 0, 0.45)
				bevelBottom:SetPoint("BOTTOMLEFT", wood); bevelBottom:SetPoint("BOTTOMRIGHT", wood); bevelBottom:SetHeight(2)
				local bevelRight = TVTexture("BACKGROUND", 1, 0, 0, 0, 0.35)
				bevelRight:SetPoint("TOPRIGHT", wood); bevelRight:SetPoint("BOTTOMRIGHT", wood); bevelRight:SetWidth(2)
				-- Dark bezel round the screen (the map, bars and quest log draw over the middle of it)
				local bezel = TVTexture("BORDER", -8, 0.05, 0.05, 0.05, 1)
				bezel:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -5, 5)
				bezel:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", 5, -5)
				local bezelLip = TVTexture("BORDER", -7, 0.20, 0.18, 0.16, 1)
				bezelLip:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -2, 2)
				bezelLip:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", 2, -2)
				local bezelInner = TVTexture("BORDER", -6, 0, 0, 0, 1)
				bezelInner:SetAllPoints(borderFrame)
				-- Side panel (a darker inset strip with two knobs, a speaker grille and a power light). The knobs and grille
				-- start well down the panel so the map tabs at the top right (room for at least four) do not cover them
				local panel = TVTexture("BORDER", -8, 0, 0, 0, 0.25)
				panel:SetPoint("TOPLEFT", borderFrame, "TOPRIGHT", 12, -2)
				panel:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", pr - 2, 2)
				tvPowerRing, tvPowerPointer = CreateKnob(-282, 120)
				tvHoldRing, tvHoldPointer = CreateKnob(-330, 30)
				for i = 1, 12 do
					local slat = TVTexture("ARTWORK", 0, 0.07, 0.05, 0.03, 0.85)
					slat:SetSize(34, 2)
					slat:SetPoint("TOP", borderFrame, "TOPRIGHT", 36, -364 - (i - 1) * 6)
					local slatLight = TVTexture("ARTWORK", 0, 1, 0.85, 0.65, 0.12)
					slatLight:SetSize(34, 1)
					slatLight:SetPoint("TOP", slat, "BOTTOM", 0, 0)
				end
				local glow = TVTexture("ARTWORK", 0, 1, 0.25, 0.10, 0.35)
				glow:SetSize(16, 16)
				glow:SetPoint("CENTER", borderFrame, "BOTTOMRIGHT", 36, 18)
				MakeRound(glow)
				local light = TVTexture("ARTWORK", 1, 1, 0.30, 0.15, 1)
				light:SetSize(7, 7)
				light:SetPoint("CENTER", glow)
				MakeRound(light)
				tvLight, tvGlow = light, glow
				-- Screen effects over the map (scanlines, a dark vignette round the edges and a glare at the top)
				tvScreen = CreateFrame("Frame", nil, WorldMapFrame)
				tvScreen:SetAllPoints(WorldMapFrame.ScrollContainer)
				tvScreen:SetFrameLevel(WorldMapFrame.ScrollContainer:GetFrameLevel() + 100)
				tvScreen:EnableMouse(false)
				local function Edge(point1, point2, size, horizontal, fromStart)
					local t = tvScreen:CreateTexture(nil, "BORDER")
					t:SetTexture(tvWhite)
					t:SetPoint(point1); t:SetPoint(point2)
					if horizontal then t:SetWidth(size) else t:SetHeight(size) end
					local dark, clear = CreateColor(0, 0, 0, 0.45), CreateColor(0, 0, 0, 0)
					if fromStart then t:SetGradient(horizontal and "HORIZONTAL" or "VERTICAL", dark, clear) else t:SetGradient(horizontal and "HORIZONTAL" or "VERTICAL", clear, dark) end
				end
				Edge("TOPLEFT", "TOPRIGHT", 30, false, false)
				Edge("BOTTOMLEFT", "BOTTOMRIGHT", 30, false, true)
				Edge("TOPLEFT", "BOTTOMLEFT", 30, true, true)
				Edge("TOPRIGHT", "BOTTOMRIGHT", 30, true, false)
				local glare = tvScreen:CreateTexture(nil, "OVERLAY")
				glare:SetTexture(tvWhite)
				glare:SetPoint("TOPLEFT"); glare:SetPoint("TOPRIGHT")
				glare:SetHeight(70)
				glare:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, 0.07))
				tvScreen:SetScript("OnSizeChanged", LayoutScanlines)
				tvScreen:SetScript("OnShow", LayoutScanlines)
				-- Power knob and vertical hold knob
				CreatePower()
				CreateHold()
			end

			-- Function to show or hide the Retro TV theme
			local function SetTV(show)
				if show and not tvParts then CreateTV() end
				if not tvParts then return end
				if not show then ResetPower(); tvHold:Hide() end
				for i = 1, #tvParts do tvParts[i]:SetShown(show) end
				tvScreen:SetShown(show)
				if show then LayoutScanlines() end
			end

			-- Handheld theme (created the first time the theme is used). Everything is drawn on the border frame (the lowest
			-- part of the map frame, so the map and bars always draw above it). Round corners and buttons use the game's round
			-- mask (see MakeRound). The rectangle edge and shadow are hidden as they would show square corners.
			local hhParts
			local hhWhite = "Interface\\Buttons\\WHITE8X8"

			-- Function to create a texture on the border frame
			local function HHTexture(layer, sublevel, r, g, b, a)
				local t = borderFrame:CreateTexture(nil, layer, nil, sublevel)
				t:SetTexture(hhWhite)
				t:SetVertexColor(r, g, b, a)
				hhParts[#hhParts + 1] = t
				return t
			end

			-- Function to create a round texture centered on a point of the border frame
			local function HHDisc(layer, sublevel, size, r, g, b, a, point, x, y)
				local t = HHTexture(layer, sublevel, r, g, b, a)
				t:SetSize(size, size)
				t:SetPoint("CENTER", borderFrame, point, x, y)
				MakeRound(t)
				return t
			end

			-- Function to create a rectangle with round corners round the border (l, r, t and b are how far it goes past the
			-- border on each side, rad is the corner size, dy moves it down). It's two rectangles and four round corners, so
			-- it must be fully opaque (the parts overlap).
			local function HHRoundRect(layer, sublevel, cr, cg, cb, l, r, t, b, rad, dy)
				dy = dy or 0
				local tall = HHTexture(layer, sublevel, cr, cg, cb, 1)
				tall:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -l + rad, t + dy)
				tall:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", r - rad, -b + dy)
				local wide = HHTexture(layer, sublevel, cr, cg, cb, 1)
				wide:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -l, t - rad + dy)
				wide:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", r, -b + rad + dy)
				HHDisc(layer, sublevel, rad * 2, cr, cg, cb, 1, "TOPLEFT", -l + rad, t - rad + dy)
				HHDisc(layer, sublevel, rad * 2, cr, cg, cb, 1, "TOPRIGHT", r - rad, t - rad + dy)
				HHDisc(layer, sublevel, rad * 2, cr, cg, cb, 1, "BOTTOMLEFT", -l + rad, -b + rad + dy)
				HHDisc(layer, sublevel, rad * 2, cr, cg, cb, 1, "BOTTOMRIGHT", r - rad, -b + rad + dy)
			end

			-- Function to create a rectangle centered on a point of the border frame
			local function HHRect(layer, sublevel, w, h, r, g, b, a, point, x, y)
				local t = HHTexture(layer, sublevel, r, g, b, a)
				t:SetSize(w, h)
				t:SetPoint("CENTER", borderFrame, point, x, y)
				return t
			end

			-- Function to create text on the border frame
			local function HHText(text, r, g, b, point, x, y)
				local fs = borderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
				fs:SetText(text)
				fs:SetTextColor(r, g, b)
				fs:SetShadowColor(0, 0, 0, 0)
				fs:SetPoint("CENTER", borderFrame, point, x, y)
				hhParts[#hhParts + 1] = fs
				return fs
			end

			-- Handheld power and gem match (like the knobs on the Retro TV theme, the select button is a power switch and the
			-- start button starts a gem matching game). Turning the power off fades the screen out like an old handheld
			-- screen, the picture lingers faintly for a moment, and the power light goes out. Turning it on plays a boot
			-- sequence like a 90s disc console (our own emblem and sounds from the game): the screen fades to white, four
			-- colored diamonds glide in and lock together into the emblem with a shimmer and the name appears, then it cuts
			-- to black with the emblem small and the product name, and fades into the map. The buttons are frames of our own
			-- over the drawn buttons, the screen cover is a frame of our own over the screen (it takes the mouse while the
			-- power is off, so nothing on the dark screen can be clicked by mistake). The animations run in an OnUpdate that
			-- is only set while they play. The power is always on when the map is opened.
			local hhLed, hhLedGlow -- Power light and its glow
			local hhScreen, hhPowerOn, hhPowerAnim, hhPowerTime, hhResetting = nil, true, nil, 0, false
			local hhBootSounds = {} -- Boot sounds that have played this time
			local GemMusic -- Defined below (gem game music, the power switch turns it off and on)

			-- Function to create a button frame over a drawn button (onDown and onUp run when it's pressed and let go, onUp
			-- also runs if it's hidden while held, onEnter and onLeave run when the pointer goes over it and off it, onLeave
			-- also runs if it's hidden)
			local function HHButton(point, x, y, w, h, onDown, onUp, onEnter, onLeave)
				local button = CreateFrame("Button", nil, borderFrame)
				button:SetSize(w, h)
				button:SetPoint("CENTER", borderFrame, point, x, y)
				button:SetFrameStrata("HIGH")
				button:SetFrameLevel(math.min(frameLevel + 20, 10000))
				button:EnableMouse(true)
				local held
				button:SetScript("OnMouseDown", function(self, mouseButton)
					if mouseButton ~= "LeftButton" or held then return end
					held = true
					onDown()
				end)
				local function LetGo()
					if not held then return end
					held = nil
					onUp()
				end
				button:SetScript("OnMouseUp", LetGo)
				button:SetScript("OnHide", function()
					LetGo()
					onLeave()
				end)
				button:SetScript("OnEnter", onEnter)
				button:SetScript("OnLeave", onLeave)
				hhParts[#hhParts + 1] = button
				return button
			end

			-- Function to set the power light for on or off
			local function HHSetLed(on)
				if on then hhLed:SetVertexColor(1, 0.25, 0.25, 1) else hhLed:SetVertexColor(0.25, 0.06, 0.06, 1) end
				hhLedGlow:SetAlpha(on and 1 or 0)
			end

			-- Boot sounds (file ID, when it plays and when it fades out, in seconds): two airy swells building up as the
			-- diamonds glide in (fx_ghostly_swells01 and 03), two glassy chime clusters cascading as they lock together
			-- (fx_chimemult_01 and 04) with a magic chime sparkle after them (amb_flavorkit_valsharah_chime_magic_01), and a
			-- single soft chime as it cuts to black (fx_chimesingle_03)
			local HHBootSoundList = {
				{795741, 0.1, 1.4}, {795745, 0.6, 1.0},
				{1514311, 1.3, 1.6}, {1514314, 1.45, 1.4}, {1250608, 1.6, 1.4},
				{1514320, 3.0, 1.2},
			}

			-- Boot emblem diamonds (direction they glide in from, and color: magenta, purple, teal, slate)
			local hhPieceDirs = {{0, 1, 0.86, 0.25, 0.66}, {1, 0, 0.56, 0.36, 0.95}, {0, -1, 0.20, 0.74, 0.74}, {-1, 0, 0.30, 0.30, 0.38}}

			-- Function to ease a value from 0 to 1 (fast at the start, slow at the end)
			local function HHEase(f) return 1 - (1 - f) * (1 - f) end

			-- Function to place the four emblem diamonds (scale is the size, spread is 0 when locked together and 1 when far
			-- out, alpha is how visible they are, y moves the emblem up). Each diamond is a thick line at 45 degrees, which
			-- draws a square standing on its corner.
			local function HHPlacePieces(scale, spread, alpha, y)
				local side = 26 * scale
				local gap = (side + 4) / math.sqrt(2) -- Distance from the middle to each diamond when they're locked together
				local half = side / 2 * 0.7071
				for i = 1, 4 do
					local piece = hhScreen.boot.pieces[i]
					local dir = hhPieceDirs[i]
					local cx, cy = dir[1] * (gap + spread * 110), dir[2] * (gap + spread * 110) + y
					piece:SetThickness(side)
					piece:SetStartPoint("CENTER", hhScreen.holder, cx - half, cy - half)
					piece:SetEndPoint("CENTER", hhScreen.holder, cx + half, cy + half)
					piece:SetAlpha(alpha)
				end
			end

			-- Function to play the power animation (runs every frame while it plays)
			local function HHPowerUpdate(self, elapsed)
				hhPowerTime = hhPowerTime + elapsed
				local t = hhPowerTime
				if hhPowerAnim == "off" then
					if t < 0.35 then
						-- Screen fades out quickly
						local f = t / 0.35
						self.dark:SetAlpha(0.88 * (1 - (1 - f) * (1 - f)))
					elseif t < 0.95 then
						-- The picture lingers faintly, then it's gone
						self.dark:SetAlpha(0.88 + 0.12 * (t - 0.35) / 0.6)
					else
						self.dark:SetAlpha(1)
						hhPowerAnim = nil
						self:SetScript("OnUpdate", nil)
					end
				elseif hhPowerAnim == "on" then
					-- Boot sounds (each plays once at its time and fades out after a while, see HHBootSoundList)
					for i = 1, #HHBootSoundList do
						local sound = HHBootSoundList[i]
						if t >= sound[2] and not hhBootSounds[i] then
							hhBootSounds[i] = true
							PlayPowerSound(sound[1], sound[3])
						end
					end
					local p = self.boot
					if t < 0.4 then
						-- Screen 1: the dark screen fades to white
						p.white:SetAlpha(t / 0.4)
						HHPlacePieces(1, 1, 0, 14)
						p.word:SetAlpha(0); p.sub:SetAlpha(0); p.flash:SetAlpha(0)
					elseif t < 1.3 then
						-- The four diamonds glide in from each side
						p.white:SetAlpha(1)
						local f = HHEase((t - 0.4) / 0.9)
						HHPlacePieces(1, 1 - f, f, 14)
					elseif t < 1.8 then
						-- They lock together with a flash and the name fades in underneath
						HHPlacePieces(1, 0, 1, 14)
						p.flash:SetAlpha(math.max(0, 0.7 * (1 - (t - 1.3) / 0.3)))
						local f = (t - 1.3) / 0.5
						p.word:SetAlpha(f); p.sub:SetAlpha(f)
					elseif t < 2.6 then
						-- Hold
						p.flash:SetAlpha(0)
						p.word:SetAlpha(1); p.sub:SetAlpha(1)
					elseif t < 3.0 then
						-- Fade to black
						local f = (t - 2.6) / 0.4
						p.white:SetAlpha(1 - f)
						HHPlacePieces(1, 0, 1 - f, 14)
						p.word:SetAlpha(1 - f); p.sub:SetAlpha(1 - f)
					elseif t < 3.4 then
						-- Screen 2: the emblem small with the product name on black
						local f = (t - 3.0) / 0.4
						p.white:SetAlpha(0); p.word:SetAlpha(0); p.sub:SetAlpha(0)
						HHPlacePieces(0.6, 0, f, 24)
						p.name:SetAlpha(f); p.licence:SetAlpha(f)
					elseif t < 4.3 then
						-- Hold
						HHPlacePieces(0.6, 0, 1, 24)
						p.name:SetAlpha(1); p.licence:SetAlpha(1)
					elseif t < 4.8 then
						-- Everything fades away to show the map
						local f = (t - 4.3) / 0.5
						self.dark:SetAlpha(1 - f)
						HHPlacePieces(0.6, 0, 1 - f, 24)
						p.name:SetAlpha(1 - f); p.licence:SetAlpha(1 - f)
					else
						hhPowerAnim = nil
						self:SetScript("OnUpdate", nil)
						self:Hide()
					end
				end
			end

			-- Function to turn the power off or on (a press is ignored while the last one is still playing)
			local function HHTogglePower()
				if hhPowerAnim then return end
				hhPowerOn = not hhPowerOn
				PlayPowerSound(567407) -- uchatscrollbutton
				if not hhPowerOn then PlayPowerSound(3749039, 1.0) end -- Power off sound (ui_adventures_fast_forward_deactivated)
				if GemMusic then GemMusic() end
				HHSetLed(hhPowerOn)
				hhPowerTime = 0
				wipe(hhBootSounds)
				hhPowerAnim = hhPowerOn and "on" or "off"
				hhScreen.dark:SetAlpha(hhPowerOn and 1 or 0)
				local p = hhScreen.boot
				p.white:SetAlpha(0); p.flash:SetAlpha(0); p.word:SetAlpha(0); p.sub:SetAlpha(0); p.name:SetAlpha(0); p.licence:SetAlpha(0)
				for i = 1, 4 do p.pieces[i]:SetAlpha(0) end
				hhScreen:Show()
				hhScreen:SetScript("OnUpdate", HHPowerUpdate)
				HHPowerUpdate(hhScreen, 0)
			end

			-- Function to turn the power back on straight away (when the map is closed or the theme is changed)
			local function HHResetPower()
				if not hhScreen or hhResetting then return end
				hhResetting = true
				hhPowerOn, hhPowerAnim = true, nil
				hhScreen:SetScript("OnUpdate", nil)
				hhScreen:Hide()
				HHSetLed(true)
				hhResetting = false
				if GemMusic then GemMusic() end
			end

			-- Gem match (a match 3 game over the map: start deals a new board, swap two gems next to each other to make a
			-- line of 3 or more of the same gem, matched gems clear, the gems above fall down, new gems drop in from the top
			-- and chain reactions score more). Drag a gem towards a gem next to it, or click a gem and then a gem next to it,
			-- to swap them, or move the highlight with
			-- the D-pad, press A to pick up a gem and press a direction to swap it that way (B puts it down). A swap that
			-- makes no line swaps back. If no swap can make a line, the game is over. Start hides the game and shows it
			-- again where it was left (closing the map or changing the theme hides it too), reset starts a new game, and the
			-- best score is saved with the addon settings. The gems are
			-- the game's gem icons on colored tiles. The board is a frame of our own over the map which takes the mouse while
			-- it's showing, so the map underneath isn't clicked by mistake. The animations run in an OnUpdate that is only
			-- set while gems are moving.
			local gems -- Board frame

			-- Function to check if the handheld screen is covered by the gem board or the power screen (the points of
			-- interest use it so their tooltips and clicks don't come through the board)
			LeaMapsLC.IsMapCovered = function()
				return (gems and gems:IsVisible()) or (hhScreen and hhScreen:IsVisible()) or false
			end
			local gemSize = 8 -- Squares across and down
			local gemIcons = { -- Icon and tile color of each kind of gem
				{"Interface\\Icons\\INV_Misc_Gem_Ruby_02", 0.85, 0.15, 0.18},
				{"Interface\\Icons\\INV_Misc_Gem_Sapphire_02", 0.15, 0.35, 0.90},
				{"Interface\\Icons\\INV_Misc_Gem_Emerald_02", 0.15, 0.70, 0.25},
				{"Interface\\Icons\\INV_Misc_Gem_Topaz_02", 0.95, 0.65, 0.10},
				{"Interface\\Icons\\INV_Misc_Gem_Amethyst_02", 0.60, 0.25, 0.85},
				{"Interface\\Icons\\INV_Misc_Gem_Diamond_02", 0.85, 0.88, 0.95},
			}
			-- Match sound: every match shatters like crystal (fx_uni_crystal_shatter_01, it fades out after 0.35 seconds so it
			-- doesn't go on too long). Chains and lines of 4 or more also get a word with its own bigger sound (see gemWords).
			local gemShatter = 568269
			local gemBoard, gemTiles = {}, {} -- Kind of gem on each square, tile for each square ([column][row], row 1 at the top)
			local gemCell = 40 -- Size of a square
			local gemState -- nil (no game), "play" (waiting for a move) or "busy" (gems are moving)
			local gemScore, gemCombo = 0, 0
			local gemBestAtStart, gemNewBest, gemRecordDone = 0, false, false -- Best score when the game started, new best to celebrate, new best celebrated
			local gemCursorC, gemCursorR, gemPickC, gemPickR = 1, 1, nil, nil -- D-pad highlight, gem picked up
			local gemAnim, gemAnimTime, gemAnimLength, gemAnimDone -- Animation playing ("move" or "clear"), time, length, function to run after it
			local gemMatched = {} -- Squares in matched lines (column * 100 + row)
			-- Special gems ([column][row]: "flame", "star" or "cube", a hypercube's kind on the board is 0 so it never makes a
			-- line) and special gem state (runs: the lines found, swapA and swapB: the two squares of the move, forced: a
			-- hypercube set the squares to clear, preBlasts: its effect, newBoard: a fresh board after the chain ends)
			local gemSpecial, gemX = {}, {runs = {}}
			local gemDirs = {U = {0, -1}, D = {0, 1}, L = {-1, 0}, R = {1, 0}}
			local GemResolve -- Defined below

			-- Function to check if the gem on a square is in a line of 3 or more
			local function GemLineAt(c, r)
				local k = gemBoard[c][r]
				if k == 0 then return false end -- A hypercube never makes a line
				local n, i = 1, c - 1
				while i >= 1 and gemBoard[i][r] == k do n = n + 1; i = i - 1 end
				i = c + 1
				while i <= gemSize and gemBoard[i][r] == k do n = n + 1; i = i + 1 end
				if n >= 3 then return true end
				n, i = 1, r - 1
				while i >= 1 and gemBoard[c][i] == k do n = n + 1; i = i - 1 end
				i = r + 1
				while i <= gemSize and gemBoard[c][i] == k do n = n + 1; i = i + 1 end
				return n >= 3
			end

			-- Function to swap two gems on the board (data only)
			local function GemSwapData(c1, r1, c2, r2)
				gemBoard[c1][r1], gemBoard[c2][r2] = gemBoard[c2][r2], gemBoard[c1][r1]
			end

			-- Function to check if any swap can make a line
			local function GemHasMove()
				-- A hypercube can always be swapped
				for c = 1, gemSize do
					for r = 1, gemSize do
						if gemSpecial[c] and gemSpecial[c][r] == "cube" then return true end
					end
				end
				for c = 1, gemSize do
					for r = 1, gemSize do
						for void, d in ipairs({{1, 0}, {0, 1}}) do
							local c2, r2 = c + d[1], r + d[2]
							if c2 <= gemSize and r2 <= gemSize then
								GemSwapData(c, r, c2, r2)
								local found = GemLineAt(c, r) or GemLineAt(c2, r2)
								GemSwapData(c, r, c2, r2)
								if found then return true end
							end
						end
					end
				end
				return false
			end

			-- Function to find every square in a line of 3 or more (returns how many)
			local function GemFindMatches()
				wipe(gemMatched)
				wipe(gemX.runs)
				local count = 0
				for pass = 1, 2 do -- Rows, then columns
					for a = 1, gemSize do
						local b = 1
						while b <= gemSize do
							local c, r = pass == 1 and b or a, pass == 1 and a or b
							local k, e = gemBoard[c][r], b
							while e + 1 <= gemSize and gemBoard[pass == 1 and e + 1 or a][pass == 1 and a or e + 1] == k do e = e + 1 end
							if e - b + 1 >= 3 and k ~= 0 then
								-- Each line is kept (its squares and whether it's a row) to make special gems from
								local run = {horiz = pass == 1}
								gemX.runs[#gemX.runs + 1] = run
								for s = b, e do run[#run + 1] = pass == 1 and s * 100 + a or a * 100 + s end
								for s = b, e do
									local key = pass == 1 and s * 100 + a or a * 100 + s
									if not gemMatched[key] then
										gemMatched[key] = true
										count = count + 1
									end
								end
							end
							b = e + 1
						end
					end
				end
				return count
			end

			-- Function to make special gems from the lines just found (5 in a line makes a hypercube, an L or T shape makes a
			-- star gem, 4 in a line makes a flame gem). The special gem goes on the square that was moved if it's in the
			-- line, otherwise in the middle of the line, and that square isn't cleared. Returns what was made.
			gemX.Make = function()
				local made, used, inRow, inCol = {}, {}, {}, {}
				local function Pick(run)
					for void, key in ipairs({gemX.swapA or 0, gemX.swapB or 0}) do
						for i = 1, #run do
							if run[i] == key and not gemSpecial[math.floor(key / 100)][key % 100] then return key end
						end
					end
					local mid = run[math.ceil(#run / 2)]
					for i = 0, #run - 1 do
						local key = run[(math.ceil(#run / 2) - 1 + i) % #run + 1]
						if not gemSpecial[math.floor(key / 100)][key % 100] then return key end
					end
					return mid
				end
				for void, run in ipairs(gemX.runs) do
					for i = 1, #run do
						if run.horiz then inRow[run[i]] = run else inCol[run[i]] = run end
					end
				end
				for void, run in ipairs(gemX.runs) do
					if #run >= 5 then made[#made + 1] = {Pick(run), "cube"}; used[run] = true end
				end
				for key, rowRun in pairs(inRow) do
					local colRun = inCol[key]
					if colRun and not used[rowRun] and not used[colRun] and not gemSpecial[math.floor(key / 100)][key % 100] then
						made[#made + 1] = {key, "star"}
						used[rowRun], used[colRun] = true, true
					end
				end
				for void, run in ipairs(gemX.runs) do
					if #run == 4 and not used[run] then made[#made + 1] = {Pick(run), "flame"}; used[run] = true end
				end
				for void, m in ipairs(made) do
					local c, r = math.floor(m[1] / 100), m[1] % 100
					gemMatched[m[1]] = nil
					gemSpecial[c][r] = m[2]
					if m[2] == "cube" then gemBoard[c][r] = 0 end
				end
				return made
			end

			-- Function to set off the special gems in the squares being cleared (a flame gem clears the 3 x 3 round it, a star
			-- gem clears its row and column, a hypercube caught in one clears every gem of a random kind). Special gems
			-- caught in a blast go off too. Returns the blasts (for the effects).
			gemX.Detonate = function()
				local blasts, queue, done = {}, {}, {}
				for key in pairs(gemMatched) do
					if gemSpecial[math.floor(key / 100)][key % 100] then queue[#queue + 1] = key end
				end
				local function Hit(c, r)
					if c < 1 or c > gemSize or r < 1 or r > gemSize then return end
					local key = c * 100 + r
					if not gemMatched[key] then
						gemMatched[key] = true
						if gemSpecial[c][r] then queue[#queue + 1] = key end
					end
				end
				local i = 1
				while i <= #queue do
					local key = queue[i]
					i = i + 1
					if not done[key] then
						done[key] = true
						local c, r = math.floor(key / 100), key % 100
						local kind = gemSpecial[c][r]
						local blast = {kind = kind, c = c, r = r}
						if kind == "flame" then
							for dc = -1, 1 do for dr = -1, 1 do Hit(c + dc, r + dr) end end
						elseif kind == "star" then
							for s = 1, gemSize do Hit(s, r); Hit(c, s) end
						elseif kind == "cube" then
							blast.color = math.random(#gemIcons)
							for cc = 1, gemSize do
								for rr = 1, gemSize do
									if gemBoard[cc][rr] == blast.color then Hit(cc, rr) end
								end
							end
						end
						blasts[#blasts + 1] = blast
					end
				end
				return blasts
			end

			-- Function to fill the board with no lines and at least one swap that makes a line
			local function GemFill()
				for c = 1, gemSize do gemSpecial[c] = {} end -- No special gems on a new board
				repeat
					for c = 1, gemSize do
						gemBoard[c] = gemBoard[c] or {}
						for r = 1, gemSize do
							local k
							repeat
								k = math.random(#gemIcons)
							until not ((c > 2 and gemBoard[c - 1][r] == k and gemBoard[c - 2][r] == k) or (r > 2 and gemBoard[c][r - 1] == k and gemBoard[c][r - 2] == k))
							gemBoard[c][r] = k
						end
					end
				until GemHasMove()
			end

			-- Function to show how many hints are left on the hint button's label (just HINT when there's no game)
			LeaMapsLC.GemHintLabel = function()
				if hhParts and hhParts.hintLabel then
					local left = gems and gemState and gemState ~= "over" and gems.hints
					hhParts.hintLabel:SetText(left and (L["HINT"] .. " " .. left) or L["HINT"])
				end
			end

			-- Function to show the score
			local function GemScoreText()
				local best = LeaMapsLC["GemBest"] or 0
				if gemScore > best then
					LeaMapsLC["GemBest"], best = gemScore, gemScore
					-- Beating a best score from before this game is celebrated once
					if gemBestAtStart > 0 and not gemRecordDone then gemRecordDone, gemNewBest = true, true end
				end
				gems.score:SetFormattedText("%s: %d     %s: %d", L["Score"], gemScore, L["Best"], best) -- The level is on the level bar
				-- Level bar (fills up with the gems cleared on this level, with the level and how far along it is on it)
				local need = 24 + 12 * (gems.level or 1)
				local have = math.min(need, gems.levelGems or 0)
				local fillWidth = math.max(1, (gemSize * gemCell - 2) * have / need)
				gems.bar.fill:SetWidth(fillWidth)
				-- The light sweeps the whole fill at the same speed whatever its width (restarted when the fill changes)
				if gems.bar.sweepWidth ~= math.floor(fillWidth) then
					gems.bar.sweepWidth = math.floor(fillWidth)
					gems.bar.sweep:Stop()
					if fillWidth > 20 then
						gems.bar.sweepMove:SetOffset(fillWidth + 70, 0)
						gems.bar.sweepMove:SetDuration(0.8 + (fillWidth + 70) / 220)
						gems.bar.sweep:Play()
					end
				end
				gems.bar.text:SetFormattedText("%s %d     %d / %d", L["Level"], gems.level or 1, have, need)
				LeaMapsLC.GemHintLabel()
			end

			-- Function to show a message in the middle of the board (nothing hides it)
			local function GemMessage(message, hint)
				gems.message:SetText(message or "")
				gems.hint:SetText(hint or "")
			end

			-- Function to place a tile's gem (it can be moved away from its square, made smaller and faded)
			local function GemPlaceArt(tile)
				tile.art:ClearAllPoints()
				tile.art:SetPoint("CENTER", tile, "CENTER", tile.ox, tile.oy)
				local s = math.max(1, (gemCell - 4) * tile.scale)
				tile.art:SetSize(s, s)
				tile.art:SetAlpha(tile.alpha)
			end

			-- Function to show the gem on a tile's square
			local function GemShow(tile)
				local kind = gemBoard[tile.c][tile.r]
				if kind == 0 then
					-- Hypercube (a brilliant shard on a white tile)
					tile.icon:SetTexture("Interface\\Icons\\INV_Enchant_ShardBrilliantLarge")
					tile.icon:SetDesaturated(false)
					tile.icon:SetVertexColor(1, 1, 1)
					tile.bg:SetColorTexture(0.90, 0.90, 1, 0.45)
				else
					-- (a flame gem is a fireball and a star gem a burst of holy light, both turned completely into the gem's
					-- color, so the shape shows what it is and the color shows what it matches)
					local g = gemIcons[kind]
					local special = gemSpecial[tile.c] and gemSpecial[tile.c][tile.r]
					if special == "flame" or special == "star" then
						tile.icon:SetTexture(special == "flame" and "Interface\\Icons\\Spell_Fire_Fireball02" or "Interface\\Icons\\Spell_Holy_HolyBolt")
						tile.icon:SetDesaturated(true)
						local boost = 1 / math.max(g[2], g[3], g[4], 0.01)
						tile.icon:SetVertexColor(math.min(1, g[2] * boost * 1.1), math.min(1, g[3] * boost * 1.1), math.min(1, g[4] * boost * 1.1))
						tile.bg:SetColorTexture(g[2], g[3], g[4], 0.55)
					else
						tile.icon:SetTexture(g[1])
						tile.icon:SetDesaturated(false)
						tile.icon:SetVertexColor(1, 1, 1)
						tile.bg:SetColorTexture(g[2], g[3], g[4], 0.40)
					end
				end
				if gems.SpecialLook then gems.SpecialLook(tile, gemSpecial[tile.c] and gemSpecial[tile.c][tile.r]) end
				tile.ox, tile.oy, tile.scale, tile.alpha = 0, 0, 1, 1
				GemPlaceArt(tile)
			end

			-- Function to show every gem
			local function GemShowAll()
				for c = 1, gemSize do
					for r = 1, gemSize do GemShow(gemTiles[c][r]) end
				end
			end

			-- Function to set the tile edges (gold for the gem picked up, white for the D-pad highlight)
			local function GemEdges()
				for c = 1, gemSize do
					for r = 1, gemSize do
						local edge = gemTiles[c][r].edge
						if gemPickC == c and gemPickR == r then
							edge:SetColorTexture(1, 0.82, 0, 1)
						elseif gemState == "play" and gems.dpadActive and gemCursorC == c and gemCursorR == r then
							edge:SetColorTexture(1, 1, 1, 0.85)
						else
							edge:SetColorTexture(0, 0, 0, 0)
						end
					end
				end
			end

			-- Function to fit the board to the map (runs for a new game and when the map changes size)
			local function GemLayout()
				gems:Fit()
				local w, h = gems:GetWidth(), gems:GetHeight()
				if not w or not h or (issecretvalue and (issecretvalue(w) or issecretvalue(h))) then return false end
				gemCell = math.floor(math.min((w - 30) / gemSize, (h - 104) / gemSize)) -- Room above for the score and level bar, below for the coordinates
				if gemCell < 16 then return false end
				gems.grid:SetSize(gemSize * gemCell, gemSize * gemCell)
				for c = 1, gemSize do
					for r = 1, gemSize do
						local tile = gemTiles[c][r]
						tile:SetSize(gemCell, gemCell)
						tile:ClearAllPoints()
						tile:SetPoint("TOPLEFT", gems.grid, "TOPLEFT", (c - 1) * gemCell, -(r - 1) * gemCell)
						GemPlaceArt(tile)
					end
				end
				-- Background glow and stars fit the board and the screen
				-- (the rings are ovals that fit inside the screen, so nothing spills over the console)
				for i = 1, #gems.glows do
					local dx, dy = w / 2 * gems.glows[i].size, h / 2 * gems.glows[i].size
					gems.glows[i]:ClearAllPoints()
					gems.glows[i]:SetPoint("TOPLEFT", gems, "CENTER", -dx, dy)
					gems.glows[i]:SetPoint("BOTTOMRIGHT", gems, "CENTER", dx, -dy)
				end
				for i = 1, #gems.stars do
					local s = gems.stars[i]
					s:ClearAllPoints()
					s:SetPoint("CENTER", gems, "TOPLEFT", w * s.fx, -h * s.fy)
				end
				if gems.level then GemScoreText() end
				return true
			end

			-- Function to run the animation (runs every frame while gems are moving)
			local function GemUpdate(self, elapsed)
				gemAnimTime = gemAnimTime + elapsed
				local f = math.min(gemAnimTime / gemAnimLength, 1)
				if gemAnim == "move" then
					-- Gems slide from where they started to their squares
					local e = f * f * (3 - 2 * f)
					for c = 1, gemSize do
						for r = 1, gemSize do
							local tile = gemTiles[c][r]
							if tile.sx then
								tile.ox, tile.oy = tile.sx * (1 - e), tile.sy * (1 - e)
								GemPlaceArt(tile)
								if f >= 1 then tile.sx, tile.sy = nil, nil end
							end
						end
					end
				elseif gemAnim == "clear" then
					-- Matched gems shrink and fade away
					for key in pairs(gemMatched) do
						local tile = gemTiles[math.floor(key / 100)][key % 100]
						tile.scale, tile.alpha = 1 - 0.6 * f, 1 - f
						GemPlaceArt(tile)
					end
				end
				if f < 1 then return end
				self:SetScript("OnUpdate", nil)
				local done = gemAnimDone
				gemAnim, gemAnimDone = nil, nil
				if done then done() end
			end

			-- Function to start an animation (done runs when it ends)
			local function GemPlay(kind, length, done)
				gemAnim, gemAnimTime, gemAnimLength, gemAnimDone = kind, 0, length, done
				gems:SetScript("OnUpdate", GemUpdate)
				GemUpdate(gems, 0)
			end

			-- Function to drop every gem in from above the board (for a new board or a shuffle)
			local function GemDropAll(done)
				GemShowAll()
				for c = 1, gemSize do
					for r = 1, gemSize do
						local tile = gemTiles[c][r]
						tile.sx, tile.sy = 0, gemSize * gemCell
					end
				end
				GemPlay("move", 0.45, done)
			end

			-- Function to let gems fall into the gaps left by matched gems, with new gems dropping in from the top
			local function GemCollapse()
				for c = 1, gemSize do
					local write = gemSize
					for r = gemSize, 1, -1 do
						if not gemMatched[c * 100 + r] then
							if write ~= r then
								gemBoard[c][write] = gemBoard[c][r]
								gemSpecial[c][write] = gemSpecial[c][r]
								gemTiles[c][write].fall = (write - r) * gemCell
							end
							write = write - 1
						end
					end
					-- New gems for the squares left at the top, they start above the board
					for r = write, 1, -1 do
						gemBoard[c][r] = math.random(#gemIcons)
						gemSpecial[c][r] = nil
						gemTiles[c][r].fall = write * gemCell
					end
				end
				for c = 1, gemSize do
					for r = 1, gemSize do
						local tile = gemTiles[c][r]
						GemShow(tile)
						if tile.fall then
							tile.sx, tile.sy, tile.fall = 0, tile.fall, nil
						end
					end
				end
				GemPlay("move", 0.25, GemResolve)
			end

			-- Celebrations (the better the move, the bigger the show: sparkles in the gem's color fly out of every cleared gem
			-- and the points float up from the line, a chain or a line of 4 or more slams a word into the middle with its own
			-- sound, a starburst and a ring of sparkles, and flashes and shakes the board). They're drawn on a frame
			-- of our own over the board which takes no mouse clicks, and run in an OnUpdate that is only set while they play.
			local gemFxParts, gemSparkSpare, gemTextSpare = {}, {}, {} -- Sparkles and points playing, spare sparkles, spare points
			local gemShake, gemShakeRate, gemFlash, gemBannerTime = 0, 0, 0, nil
			local gemWords = { -- Word, color and sound for each level of move (each sound is bigger than the last)
				{L["Nice!"], 0.60, 0.85, 1, 1138111}, -- ui_loot_toast_lesser_item_won_01
				{L["Great!"], 0.45, 1, 0.45, 2174248}, -- ui_80_azeriteloot_toast
				{L["Awesome!"], 1, 0.85, 0.20, 642829}, -- ui_epicloot_toast_01
				{L["Amazing!"], 1, 0.55, 0.15, 1130983}, -- ui_raid_loot_banner_01
				{L["Incredible!"], 1, 0.35, 0.85, 4906957}, -- ui_tradingpost_purchasecelebration_01
			}

			-- Function to put the board back in its place (after it has been shaking)
			local function GemGridHome(x, y)
				gems.grid:ClearAllPoints()
				gems.grid:SetPoint("CENTER", gems, "CENTER", x or 0, (y or 0) - 6)
			end

			-- Function to run the celebrations (runs every frame while they play)
			local function GemFxUpdate(self, elapsed)
				-- Sparkles fly out and fall, points float up, both fade away
				local i = 1
				while i <= #gemFxParts do
					local p = gemFxParts[i]
					p.age = p.age + elapsed
					if p.age >= p.life then
						p.region:Hide()
						p.spare[#p.spare + 1] = p
						gemFxParts[i] = gemFxParts[#gemFxParts]
						gemFxParts[#gemFxParts] = nil
					else
						local f = p.age / p.life
						p.x, p.y = p.x + p.vx * elapsed, p.y + p.vy * elapsed
						if p.isText then
							p.region:SetAlpha(f < 0.6 and 1 or (1 - f) / 0.4)
						else
							p.vy = p.vy - 260 * elapsed
							local s = p.size * (1 - 0.5 * f)
							p.region:SetSize(s, s)
							p.region:SetAlpha(1 - f)
						end
						p.region:ClearAllPoints()
						p.region:SetPoint("CENTER", gems.grid, "TOPLEFT", p.x, p.y)
						i = i + 1
					end
				end
				-- Flash fades away
				if gemFlash > 0 then
					gemFlash = math.max(0, gemFlash - elapsed * 2)
					self.flash:SetAlpha(gemFlash)
				end
				-- Shake dies down
				if gemShake > 0 then
					gemShake = math.max(0, gemShake - gemShakeRate * elapsed)
					if gemShake > 0 then
						GemGridHome((math.random() * 2 - 1) * gemShake, (math.random() * 2 - 1) * gemShake)
					else
						GemGridHome()
					end
				end
				-- Word slams in from big, overshoots, bounces back and settles, a starburst flares out behind it, then it floats
				-- up and fades away
				if gemBannerTime then
					gemBannerTime = gemBannerTime + elapsed
					local t = gemBannerTime
					if t >= 1.15 then
						gemBannerTime = nil
						self.banner:Hide()
						self.burst:Hide()
					else
						local s
						if t < 0.12 then s = 2.4 - 1.55 * (t / 0.12)
						elseif t < 0.22 then s = 0.85 + 0.27 * ((t - 0.12) / 0.10)
						elseif t < 0.30 then s = 1.12 - 0.12 * ((t - 0.22) / 0.08)
						else s = 1 end
						self.banner:SetScale(s)
						self.banner:SetAlpha(t < 0.08 and t / 0.08 or (t > 0.8 and 1 - (t - 0.8) / 0.35 or 1))
						local rise = t > 0.8 and (t - 0.8) / 0.35 * 18 or 0
						self.banner:ClearAllPoints()
						self.banner:SetPoint("CENTER", gems.grid, "CENTER", 0, rise / s) -- Offsets are scaled with the word
						if t < 0.45 then
							local f = t / 0.45
							local size = 40 + 260 * f
							self.burst:SetSize(size, size)
							self.burst:SetAlpha(0.9 * (1 - f))
							self.burst:Show()
						else
							self.burst:Hide()
						end
					end
				end
				-- Hint glows pulse and fade (they go as soon as a move is made)
				if gems.fx.hintTime then
					gems.fx.hintTime = gems.fx.hintTime + elapsed
					if gems.fx.hintTime >= 1.5 or gemState ~= "play" then
						gems.fx.hintTime = nil
						gems.fx.hint[1]:Hide()
						gems.fx.hint[2]:Hide()
					else
						local a = (0.35 + 0.35 * math.sin(gems.fx.hintTime * 10)) * (1 - gems.fx.hintTime / 3)
						gems.fx.hint[1]:SetAlpha(a)
						gems.fx.hint[2]:SetAlpha(a)
					end
				end
				if #gemFxParts == 0 and gemFlash <= 0 and gemShake <= 0 and not gemBannerTime and not gems.fx.hintTime then
					self:SetScript("OnUpdate", nil)
				end
			end

			-- Function to add a sparkle flying out from a point on the board (spare sparkles are reused)
			local function GemSpark(x, y, r, g, b)
				local p = table.remove(gemSparkSpare)
				if not p then
					p = {spare = gemSparkSpare}
					p.region = gems.fx:CreateTexture(nil, "OVERLAY")
					p.region:SetTexture("Interface\\Cooldown\\star4")
					p.region:SetBlendMode("ADD")
				end
				local angle, speed = math.random() * 2 * math.pi, 60 + math.random() * 110
				p.x, p.y, p.vx, p.vy = x, y, math.cos(angle) * speed, math.sin(angle) * speed + 40
				p.age, p.life, p.size = 0, 0.5 + math.random() * 0.3, 10 + math.random(8)
				p.region:SetVertexColor(r, g, b, 1)
				p.region:SetSize(p.size, p.size)
				p.region:Show()
				gemFxParts[#gemFxParts + 1] = p
			end

			-- Function to add points floating up from a point on the board (spare ones are reused)
			-- Function to add text floating up from a point on the board, such as points (spare ones are reused)
			local function GemText(x, y, text, r, g, b, speed, life)
				local p = table.remove(gemTextSpare)
				if not p then
					p = {spare = gemTextSpare, isText = true}
					p.region = gems.fx:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
					local font, size = p.region:GetFont()
					if font then p.region:SetFont(font, 18, "OUTLINE") end
				end
				p.region:SetText(text)
				p.region:SetTextColor(r, g, b)
				p.x, p.y, p.vx, p.vy, p.age, p.life = x, y, 0, speed, 0, life
				p.region:SetAlpha(1)
				p.region:Show()
				gemFxParts[#gemFxParts + 1] = p
				gems.fx:SetScript("OnUpdate", GemFxUpdate)
			end

			-- Function to show a word in the middle of the board with its starburst and a ring of sparkles (sound is played
			-- separately)
			local function GemBanner(word, r, g, b, sparks)
				gems.fx.levelWord = nil
				gems.fx.bannerText:SetText(word)
				gems.fx.bannerText:SetTextColor(r, g, b)
				gems.fx.burst:SetVertexColor(r, g, b, 1)
				gems.fx.banner:SetScale(2.4)
				gems.fx.banner:SetAlpha(0)
				gems.fx.banner:Show()
				gemBannerTime = 0
				local cx, cy = gemSize * gemCell / 2, -gemSize * gemCell / 2
				for s = 1, sparks do GemSpark(cx, cy, r, g, b) end
				gems.fx:SetScript("OnUpdate", GemFxUpdate)
			end

			-- Function to celebrate a match (count is how many gems cleared, combo is how far into a chain it is)
			local function GemCelebrate(count, combo)
				local big = combo >= 3 or count >= 5
				local sumX, sumY, n = 0, 0, 0
				for key in pairs(gemMatched) do
					local c, r = math.floor(key / 100), key % 100
					local x, y = (c - 0.5) * gemCell, -(r - 0.5) * gemCell
					local g = gemIcons[gemBoard[c][r]] or {nil, 1, 1, 1} -- (a hypercube's sparkles are white)
					for s = 1, big and 7 or 4 do GemSpark(x, y, g[2], g[3], g[4]) end
					sumX, sumY, n = sumX + x, sumY + y, n + 1
				end
				-- Points (gold for a chain, white otherwise)
				if combo >= 2 then
					GemText(sumX / n, sumY / n, "+" .. count * 10 * combo * (gems.level or 1), 1, 0.85, 0.2, 45, 0.9)
				else
					GemText(sumX / n, sumY / n, "+" .. count * 10 * combo * (gems.level or 1), 1, 1, 1, 45, 0.9)
				end
				-- Combo counter for a chain (under the middle of the board, it grows with the chain)
				if combo >= 2 then
					GemText(gemSize * gemCell / 2, -gemSize * gemCell / 2 - 46, string.format(L["Combo x%d!"], combo), 1, 0.75 + math.min(combo, 6) * 0.04, 0.2, 14, 1.2)
				end
				-- Word, flash and shake for a chain or a line of 4 or more (bigger for better moves)
				local level = combo >= 2 and math.min(combo - 1, #gemWords) or 0
				if count >= 5 then level = math.max(level, 3) elseif count >= 4 then level = math.max(level, 1) end
				if level > 0 then
					local w = gemWords[level]
					-- (a level up word stays until it's finished)
					if not gems.levelUp:IsShown() then GemBanner(w[1], w[2], w[3], w[4], 8 + 3 * level) end
					PlayPowerSound(w[5], 1.6) -- The word's own sound
					gemFlash = math.max(gemFlash, 0.12 + 0.06 * level)
					gemShake = math.max(gemShake, 2 + 1.5 * level)
					gemShakeRate = gemShake / 0.35
				end
				gems.fx:SetScript("OnUpdate", GemFxUpdate)
			end

			-- Function to stop the celebrations straight away (when the game ends)
			local function GemFxStop()
				if not gems or not gems.fx then return end
				gems.fx:SetScript("OnUpdate", nil)
				for i = #gemFxParts, 1, -1 do
					local p = gemFxParts[i]
					p.region:Hide()
					p.spare[#p.spare + 1] = p
					gemFxParts[i] = nil
				end
				gemShake, gemFlash, gemBannerTime = 0, 0, nil
				gems.fx.flash:SetAlpha(0)
				gems.fx.banner:Hide()
				gems.fx.burst:Hide()
				gems.fx.hintTime = nil
				gems.fx.hint[1]:Hide()
				gems.fx.hint[2]:Hide()
				gems.levelUp:Hide()
				GemGridHome()
			end

			-- Function to clear any lines (chain reactions score more), shuffle if no swap can make a line, or wait for a move
			GemResolve = function()
				local count, made, blasts
				if gemX.forced then
					-- A hypercube chose the squares to clear
					gemX.forced = nil
					wipe(gemX.runs)
					count = 1
				else
					count = GemFindMatches()
				end
				if count > 0 then
					-- New special gems from the lines, then special gems being cleared go off
					made = gemX.Make()
					blasts = gemX.Detonate()
					if gemX.preBlasts then
						for i = #gemX.preBlasts, 1, -1 do table.insert(blasts, 1, gemX.preBlasts[i]) end
						gemX.preBlasts = nil
					end
					count = 0
					for key in pairs(gemMatched) do count = count + 1 end
					gemCombo = gemCombo + 1
					gemScore = gemScore + count * 10 * gemCombo * gems.level
					-- Clearing gems fills the level bar, a full bar is the next level (each level needs 12 more gems than
					-- the last, and points are multiplied by the level)
					gems.levelGems = gems.levelGems + count
					local levelUp
					if gems.levelGems >= 24 + 12 * gems.level then
						gems.levelGems = gems.levelGems - (24 + 12 * gems.level)
						gems.level = gems.level + 1
						gems.hints = math.min(3, (gems.hints or 0) + 1) -- Each level up gives a hint back (up to 3)
						gemX.newBoard = true -- A fresh board rains in when the chain ends
						levelUp = true
					end
					GemScoreText()
					GemCelebrate(count, gemCombo)
					gems.SpecialFx(made, blasts)
					if gemNewBest then
						-- New best score (ui_challengemode_newrecord)
						gemNewBest = false
						PlayPowerSound(774376)
						GemBanner(L["New best!"], 1, 0.82, 0, 20)
					end
					if levelUp then
						-- Level up (the biggest show: a big LEVEL UP logo pops in over spinning golden rays with a burst of
						-- light, a ring of sparkles, a bright flash and a shake, with the artifact forge final trait unlocked
						-- sound, ui_72_artifact_forge_final_trait_unlocked)
						PlayPowerSound(1600378, 2.5)
						gems.levelUp:Play(gems.level)
						local cx, cy = gemSize * gemCell / 2, -gemSize * gemCell / 2
						for s = 1, 36 do GemSpark(cx, cy, 1, 0.85, 0.3) end
						gems.fx:SetScript("OnUpdate", GemFxUpdate)
						gems.bar.flash:Play()
						GemMusic() -- The new level's ambience
						gems:SetLevelColors(gems.level) -- And its colors
						gemFlash = math.max(gemFlash, 0.5)
						gemShake = math.max(gemShake, 7)
						gemShakeRate = gemShake / 0.45
					end
					PlayPowerSound(gemShatter, 0.35) -- Cut short with a quick fade
					GemPlay("clear", 0.22, GemCollapse)
					return
				end
				gemCombo = 0
				gemX.swapA, gemX.swapB = nil, nil
				if gemX.newBoard then
					-- Level up: the old board shatters away and a fresh one rains in
					gemX.newBoard = nil
					gems.NewBoard()
					return
				end
				if not GemHasMove() then
					-- No swap can make a line, so the game is over (the board dims and stays to look at, start or reset
					-- plays again, ui_garrison_mission_complete_missionfail_stinger)
					gemState = "over"
					gemPickC, gemPickR = nil, nil
					GemEdges()
					gems.grid:SetAlpha(0.45)
					GemMessage(L["No more moves!"], string.format(L["Final score %d - press gemfall or reset to play again"], gemScore))
					PlayPowerSound(1068445)
					GemMusic()
					return
				end
				gemState = "play"
				GemEdges()
				gems:Idle()
			end

			-- Function to swap two gems next to each other (it swaps back if it makes no line). A hypercube swapped with a
			-- gem clears every gem of that kind, two hypercubes swapped together clear the whole board.
			local function GemSwap(c1, r1, c2, r2)
				gemState = "busy"
				gems:Idle() -- Stops the auto hint timer
				gemX.swapA, gemX.swapB = c2 * 100 + r2, c1 * 100 + r1
				gemPickC, gemPickR = nil, nil
				GemEdges()
				PlayPowerSound(567407) -- uchatscrollbutton
				local function Slide()
					GemSwapData(c1, r1, c2, r2)
					gemSpecial[c1][r1], gemSpecial[c2][r2] = gemSpecial[c2][r2], gemSpecial[c1][r1]
					local t1, t2 = gemTiles[c1][r1], gemTiles[c2][r2]
					GemShow(t1); GemShow(t2)
					t1.sx, t1.sy = (c2 - c1) * gemCell, -(r2 - r1) * gemCell
					t2.sx, t2.sy = (c1 - c2) * gemCell, -(r1 - r2) * gemCell
				end
				Slide()
				GemPlay("move", 0.15, function()
					local a, b = gemSpecial[c1][r1], gemSpecial[c2][r2]
					if a == "cube" or b == "cube" then
						gemCombo = 0
						wipe(gemMatched)
						local blast
						if a == "cube" and b == "cube" then
							for c = 1, gemSize do for r = 1, gemSize do gemMatched[c * 100 + r] = true end end
							blast = {kind = "cube", c = c2, r = r2, all = true}
						else
							local cc, cr, oc, orow = c1, r1, c2, r2
							if b == "cube" then cc, cr, oc, orow = c2, r2, c1, r1 end
							local color = gemBoard[oc][orow]
							gemMatched[cc * 100 + cr] = true
							for c = 1, gemSize do
								for r = 1, gemSize do
									if gemBoard[c][r] == color then gemMatched[c * 100 + r] = true end
								end
							end
							blast = {kind = "cube", c = cc, r = cr, color = color}
						end
						if a == "cube" then gemSpecial[c1][r1] = nil end -- Used up
						if b == "cube" then gemSpecial[c2][r2] = nil end
						gemX.forced, gemX.preBlasts = true, {blast}
						GemResolve()
					elseif GemLineAt(c1, r1) or GemLineAt(c2, r2) then
						gemCombo = 0
						GemResolve()
					else
						Slide()
						gemX.swapA, gemX.swapB = nil, nil
						GemPlay("move", 0.15, function()
							gemState = "play"
							GemEdges()
							gems:Idle()
						end)
					end
				end)
			end

			-- Function for clicking a gem or pressing A on it (pick it up, put it down, or swap it with the gem picked up)
			local function GemClick(c, r)
				if gemState ~= "play" then return end
				gemCursorC, gemCursorR = c, r
				if gemPickC == c and gemPickR == r then
					gemPickC, gemPickR = nil, nil
				elseif gemPickC and math.abs(gemPickC - c) + math.abs(gemPickR - r) == 1 then
					GemSwap(gemPickC, gemPickR, c, r)
					return
				else
					gemPickC, gemPickR = c, r
				end
				GemEdges()
			end

			-- Function to swap a gem by dragging it (the gem swaps with the one next to it in the direction it was dragged)
			local function GemDrag(c, r, key)
				if gemState ~= "play" then return end
				local d = gemDirs[key]
				local c2, r2 = c + d[1], r + d[2]
				if c2 < 1 or c2 > gemSize or r2 < 1 or r2 > gemSize then return end
				gemCursorC, gemCursorR = c2, r2
				GemSwap(c, r, c2, r2)
			end

			-- Function for the D-pad (moves the highlight, or swaps the gem picked up that way)
			local function GemDpad(key)
				if gemState ~= "play" then return end
				gems.dpadActive = true
				local d = gemDirs[key]
				if gemPickC then
					local c2, r2 = gemPickC + d[1], gemPickR + d[2]
					if c2 >= 1 and c2 <= gemSize and r2 >= 1 and r2 <= gemSize then
						gemCursorC, gemCursorR = c2, r2
						GemSwap(gemPickC, gemPickR, c2, r2)
					end
					return
				end
				gemCursorC = math.max(1, math.min(gemSize, gemCursorC + d[1]))
				gemCursorR = math.max(1, math.min(gemSize, gemCursorR + d[2]))
				GemEdges()
			end

			-- Function for the A button (shows a hint, or while playing with the D-pad picks up, puts down or swaps the
			-- highlighted gem)
			local function GemButtonA()
				if not gems or not gems:IsVisible() then return end
				if gems.dpadActive or gemPickC then
					GemClick(gemCursorC, gemCursorR)
				elseif gemState == "play" and (gems.hints or 0) > 0 then
					-- Hint: the two gems of a random possible move pulse with a gold glow for a moment (mapping), there are 3
					-- hints in each game and each level up gives one back (up to 3), with none left the button just clicks
					if gems.ShowHint() then
						gems.hints = gems.hints - 1
						LeaMapsLC.GemHintLabel()
						PlayPowerSound(567416)
						gems:Idle()
					end
				end
			end

			-- Ambience while the gem game is on the screen (Crystalsong Forest's soft crystal hum from the game,
			-- crystalsongforestdaynight, no music). It plays on the sound effects channel, so it uses the effects volume and the
			-- zone music carries on as normal, and it repeats with no gap: the first time it plays, a ticker watches for it to
			-- end (if the game can say whether a sound is still playing) to learn how long it is, then each copy starts just
			-- before the last one ends and the last one fades out under it. The ticker only runs until the length is known,
			-- after that a timer starts each copy. It fades out when the game is hidden, the map is closed or the power is
			-- turned off.
			-- Each level has its own ambience, always the same one for that level: level 1 to 50 go through the list below
			-- (calm forests and glades first, then coasts, jungles and marshes, then snow, cities and stranger places, and
			-- the darkest and most dramatic last), levels 51 to 100 go back through it from 50 to 1, then it starts again
			-- (101 is level 1's ambience, and so on). Moving up a level fades the old ambience out under the new one.
			local gemAmbiences = {
				594384, 594486, 538990, 539058, 594528, 594456, 539131, 539108, 539056, 539128,
				594345, 594540, 539047, 538994, 594546, 594513, 539048, 539125, 594561, 594570,
				539001, 538999, 594471, 594381, 539097, 539092, 539084, 539103, 594396, 594447,
				594351, 594342, 594573, 594408, 539013, 539023, 594504, 594465, 594489, 594366,
				594450, 594480, 594360, 594423, 594333, 594552, 594510, 539073, 594372, 539011,
				lengths = {}, -- How long each ambience is (learned the first time it plays)
			}
			gemAmbiences.For = function(level)
				local count = #gemAmbiences
				local i = (level - 1) % (count * 2)
				if i < count then return gemAmbiences[i + 1] end
				return gemAmbiences[count * 2 - i]
			end
			local gemAmbHandle, gemAmbStart, gemAmbTicker, gemAmbTimer
			local GemAmbPlay
			local function GemAmbWatch()
				if gemAmbHandle and not C_Sound.IsPlaying(gemAmbHandle) then
					-- It has ended, so now its length is known
					gemAmbiences.lengths[gemAmbiences.playing] = GetTime() - gemAmbStart
					gemAmbTicker:Cancel()
					gemAmbTicker, gemAmbHandle = nil, nil
					GemAmbPlay()
				end
			end
			GemAmbPlay = function()
				local id = gemAmbiences.For(gems and gems.level or 1)
				local changed = gemAmbHandle and id ~= gemAmbiences.playing -- A new level's ambience
				local willPlay, handle = PlaySoundFile(id, "SFX")
				if not willPlay then return end
				local last = gemAmbHandle
				gemAmbHandle, gemAmbStart, gemAmbiences.playing = handle, GetTime(), id
				if last then StopSound(last, changed and 1500 or 600) end -- The last copy fades out under the new one
				local length = gemAmbiences.lengths[id]
				if length and length > 2 then
					gemAmbTimer = C_Timer.NewTimer(length - 0.6, GemAmbPlay)
				elseif not length and C_Sound and C_Sound.IsPlaying then
					gemAmbTicker = C_Timer.NewTicker(0.05, GemAmbWatch)
				end
			end
			local gemAmbOn = false
			GemMusic = function()
				-- Turning the power off hides the game (it's kept, gemfall carries on where you were once the power is back
				-- on). The board stays under the screen while it fades to black so the map doesn't show through, then it's
				-- hidden.
				if not hhPowerOn and gems and gems:IsShown() and not gems.powerHide then
					gems.powerHide = true
					C_Timer.After(1, function()
						gems.powerHide = nil
						if not hhPowerOn then gems:Hide() end
					end)
				end
				LeaMapsLC.GemHintLabel()
				local want = gems and gems:IsVisible() and hhPowerOn and gemState ~= nil and gemState ~= "over"
				if want and gemAmbOn and gemAmbiences.For(gems.level or 1) ~= gemAmbiences.playing then
					-- Level changed (or a new game), so the ambience changes to the new level's
					if gemAmbTicker then gemAmbTicker:Cancel() end
					if gemAmbTimer then gemAmbTimer:Cancel() end
					gemAmbTicker, gemAmbTimer = nil, nil
					GemAmbPlay()
				elseif want and not gemAmbOn then
					gemAmbOn = true
					GemAmbPlay()
				elseif not want and gemAmbOn then
					gemAmbOn = false
					if gemAmbTicker then gemAmbTicker:Cancel() end
					if gemAmbTimer then gemAmbTimer:Cancel() end
					if gemAmbHandle then StopSound(gemAmbHandle, 800) end
					gemAmbTicker, gemAmbTimer, gemAmbHandle = nil, nil, nil
				end
			end

			-- Function to start a new game (a new board and the score back to 0, the best score is kept)
			local function GemNew()
				gems:SetScript("OnUpdate", nil)
				gemAnim, gemAnimDone = nil, nil
				GemFxStop()
				gems:Show() -- Shown first so its size can be read
				if not GemLayout() then
					gemState = nil
					gems:Hide()
					return
				end
				GemFill()
				gems.grid:SetAlpha(1)
				gemScore, gemCombo, gemCursorC, gemCursorR, gemPickC, gemPickR = 0, 0, 1, 1, nil, nil
				gems.dpadActive = false
				gems.level, gems.levelGems, gems.hints = 1, 0, 3
				gems:SetLevelColors(1)
				gemBestAtStart, gemNewBest, gemRecordDone = LeaMapsLC["GemBest"] or 0, false, false
				GemScoreText()
				GemMessage()
				gemState = "busy"
				GemMusic()
				GemDropAll(function()
					gemState = "play"
					GemEdges()
					gems:Idle()
				end)
			end

			-- Function for the start button (hides the game, or shows it again where it was left, or starts a new game if
			-- there isn't one or the game is over, not while the power is off or turning on or off). A hidden game is paused, gems that were
			-- moving carry on when it's shown again.
			local function GemStart()
				PlayPowerSound(567481) -- iuiinterfacebuttona
				if not hhPowerOn or hhPowerAnim then return end
				if gems and gems.fadeOut:IsPlaying() then
					-- Pressed again while it's fading out, so it fades back in
					gems.fadeOut:Stop()
					gems:SetAlpha(1)
					gems.fadeIn:Play()
				elseif not gemState or (gemState == "over" and gems:IsShown()) then
					GemNew()
				elseif gems:IsShown() then
					gems.fadeOut:Play() -- Fades out, then it's hidden
				else
					gems:Show()
					GemLayout()
					GemScoreText()
					GemEdges()
				end
			end

			-- Function for the reset button (starts a new game, not while the power is off or turning on or off)
			-- (a game being played asks first: a box on the board asks to start a new game, yes or no, only yes starts it,
			-- the game is shown if it was hidden so the box can be seen)
			local function GemReset()
				PlayPowerSound(567407) -- uchatscrollbutton
				if not hhPowerOn or hhPowerAnim then return end
				if gems and gemState and gemState ~= "over" then
					if gems.confirm:IsShown() then return end -- Already asking (yes has to be clicked)
					if not gems:IsShown() then
						gems:Show()
						GemLayout()
						GemScoreText()
						GemEdges()
					end
					gems.help:Hide()
					gems.confirm:Show()
					return
				end
				GemNew()
			end

			-- Function to create the board
			local function CreateGems()
				gems = CreateFrame("Frame", nil, WorldMapFrame)
				gems:SetFrameStrata("HIGH")
				gems:SetFrameLevel(math.min(frameLevel + 17, 10000))
				gems:SetAllPoints(WorldMapFrame.ScrollContainer)
				-- The game screen leaves the bottom right corner open so the quest log toggle button there can be seen and
				-- clicked: the screen stops short of the button's column, and a strip of our own (the cap) covers that
				-- column above the button with the background colors it would have there. The button is only looked at.
				gems.cap = CreateFrame("Frame", nil, gems)
				gems.cap:EnableMouse(true)
				gems.cap:Hide()
				gems.cap.back = gems.cap:CreateTexture(nil, "BACKGROUND")
				gems.cap.back:SetTexture(hhWhite)
				gems.cap.back:SetAllPoints()
				function gems:Fit()
					local container = WorldMapFrame.ScrollContainer
					local toggle = WorldMapFrame.SidePanelToggle
					if not toggle then
						for void, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
							if frame.OpenButton and frame.CloseButton then toggle = frame break end
						end
					end
					local gap, tall = 0, 0
					if toggle and toggle:IsShown() then
						local w, h = toggle:GetSize()
						if w and h and not (issecretvalue and (issecretvalue(w) or issecretvalue(h))) then
							gap, tall = w + 2, h + 2
						else
							gap, tall = 34, 34
						end
					end
					if gap ~= self.fitGap then
						self.fitGap = gap
						self:ClearAllPoints()
						self:SetPoint("TOPLEFT", container, "TOPLEFT")
						self:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -gap, 0)
					end
					if gap > 0 then
						self.cap:ClearAllPoints()
						self.cap:SetPoint("TOPLEFT", self, "TOPRIGHT")
						self.cap:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, tall)
						-- Background colors at the top and bottom of the cap (it ends above the button)
						local full = container:GetHeight()
						local f = 1
						if full and not (issecretvalue and issecretvalue(full)) and full > tall then f = (full - tall) / full end
						local top, bottom = self.palette and self.palette.top or {0.09, 0.06, 0.17}, self.palette and self.palette.bottom or {0.02, 0.02, 0.05}
						local tr, tg, tb, br, bg, bb = top[1], top[2], top[3], bottom[1], bottom[2], bottom[3]
						self.cap.back:SetGradient("VERTICAL", CreateColor(tr + (br - tr) * f, tg + (bg - tg) * f, tb + (bb - tb) * f, 1), CreateColor(tr, tg, tb, 1))
						self.cap:Show()
					else
						self.cap:Hide()
					end
				end
				gems:EnableMouse(true)
				gems:Hide()
				-- Game screen background (covers the map: deep indigo fading to near black, a soft violet glow behind the
				-- board made of faint rings that light up one after another from the outside in, slowly and over and over,
				-- and a scatter of faint stars that twinkle). The movement uses animation groups, which the game runs itself,
				-- so there's no OnUpdate.
				local back = gems:CreateTexture(nil, "BACKGROUND", nil, 0)
				back:SetTexture(hhWhite)
				back:SetGradient("VERTICAL", CreateColor(0.02, 0.02, 0.05, 1), CreateColor(0.09, 0.06, 0.17, 1))
				back:SetAllPoints()
				-- Board (in the middle, a little below the score, gems dropping in from above are clipped to it)
				gems.grid = CreateFrame("Frame", nil, gems)
				gems.grid:SetPoint("CENTER", 0, -6)
				gems.grid:SetSize(1, 1)
				gems.grid:SetClipsChildren(true)
				for i, size in ipairs({1.0, 0.86, 0.72, 0.58, 0.44}) do -- Size of each ring as a fraction of the screen
					local glow = gems:CreateTexture(nil, "BACKGROUND", nil, i)
					glow:SetTexture(hhWhite)
					glow:SetBlendMode("ADD") -- Adds a little light (a dark color added is a faint glow)
					glow:SetVertexColor(0.07, 0.04, 0.13, 1)
					glow:SetAlpha(0.3)
					-- Each ring brightens and fades over 3 seconds, a little after the ring outside it, every 7 seconds
					local ripple = glow:CreateAnimationGroup()
					ripple:SetLooping("REPEAT")
					local up = ripple:CreateAnimation("Alpha")
					up:SetFromAlpha(0.3)
					up:SetToAlpha(1)
					up:SetDuration(1.5)
					up:SetStartDelay((i - 1) * 0.55)
					up:SetSmoothing("IN_OUT")
					up:SetOrder(1)
					local down = ripple:CreateAnimation("Alpha")
					down:SetFromAlpha(1)
					down:SetToAlpha(0.3)
					down:SetDuration(1.5)
					down:SetEndDelay(4 - (i - 1) * 0.55)
					down:SetSmoothing("IN_OUT")
					down:SetOrder(2)
					ripple:Play()
					glow:SetPoint("TOPLEFT", gems.grid, "CENTER", 0, 0)
					glow:SetPoint("BOTTOMRIGHT", gems.grid, "CENTER", 0, 0)
					glow.size = size
					if gems.CreateMaskTexture then -- Round (the mask is made on the same frame as the glow)
						local mask = gems:CreateMaskTexture()
						mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
						mask:SetAllPoints(glow)
						glow:AddMaskTexture(mask)
					end
					gems.glows = gems.glows or {}
					gems.glows[i] = glow
				end
				for void, star in ipairs({{0.06, 0.12, 9}, {0.14, 0.78, 7}, {0.09, 0.46, 6}, {0.92, 0.18, 8}, {0.86, 0.64, 6}, {0.95, 0.88, 9}, {0.22, 0.93, 5}, {0.78, 0.07, 5}, {0.04, 0.95, 7}, {0.97, 0.42, 5}, {0.18, 0.26, 5}, {0.12, 0.62, 8}, {0.83, 0.34, 6}, {0.90, 0.76, 5}, {0.30, 0.05, 6}, {0.70, 0.95, 6}}) do
					local s = gems:CreateTexture(nil, "BACKGROUND", nil, 4)
					s:SetTexture("Interface\\Cooldown\\star4")
					s:SetBlendMode("ADD")
					s:SetVertexColor(0.75, 0.70, 1, 0.35)
					s:SetSize(star[3] * 2, star[3] * 2)
					s.fx, s.fy = star[1], star[2]
					-- Twinkle (each star dims and shrinks then brightens and grows again, at its own speed)
					local twinkle = s:CreateAnimationGroup()
					twinkle:SetLooping("BOUNCE")
					local speed = 0.9 + (void * 7 % 5) * 0.35
					local fade = twinkle:CreateAnimation("Alpha")
					fade:SetFromAlpha(1)
					fade:SetToAlpha(0.1)
					fade:SetDuration(speed)
					fade:SetSmoothing("IN_OUT")
					local shrink = twinkle:CreateAnimation("Scale")
					shrink:SetScale(0.45, 0.45)
					shrink:SetDuration(speed)
					shrink:SetSmoothing("IN_OUT")
					twinkle:Play()
					gems.stars = gems.stars or {}
					gems.stars[#gems.stars + 1] = s
				end
				-- Dark panel behind the gems with a faint edge
				local edge = gems:CreateTexture(nil, "BORDER", nil, 0)
				edge:SetTexture(hhWhite)
				edge:SetVertexColor(0.40, 0.32, 0.60, 0.55)
				edge:SetPoint("TOPLEFT", gems.grid, "TOPLEFT", -5, 5)
				edge:SetPoint("BOTTOMRIGHT", gems.grid, "BOTTOMRIGHT", 5, -5)
				local panel = gems:CreateTexture(nil, "BORDER", nil, 1)
				panel:SetTexture(hhWhite)
				panel:SetVertexColor(0.03, 0.025, 0.06, 0.95)
				panel:SetPoint("TOPLEFT", gems.grid, "TOPLEFT", -4, 4)
				panel:SetPoint("BOTTOMRIGHT", gems.grid, "BOTTOMRIGHT", 4, -4)
				-- Each level has its own colors for the background, glow rings, stars and panel edge (always the same colors
				-- for the same level: level 1 is violet and each level after it moves round the color wheel by the golden
				-- angle, so neighbouring levels always look clearly different and no two levels look the same). The
				-- animations stay the same, only the colors change, when you level up or start a game.
				function gems:SetLevelColors(level)
					local hue = (0.712 + ((level or 1) - 1) * 0.618034) % 1
					local function HSV(s, v)
						local i = math.floor(hue * 6)
						local f = hue * 6 - i
						local p, q, w = v * (1 - s), v * (1 - s * f), v * (1 - s * (1 - f))
						i = i % 6
						if i == 0 then return v, w, p elseif i == 1 then return q, v, p elseif i == 2 then return p, v, w
						elseif i == 3 then return p, q, v elseif i == 4 then return w, p, v else return v, p, q end
					end
					local tr, tg, tb = HSV(0.65, 0.17)
					local br, bg, bb = HSV(0.60, 0.05)
					self.palette = {top = {tr, tg, tb}, bottom = {br, bg, bb}}
					back:SetGradient("VERTICAL", CreateColor(br, bg, bb, 1), CreateColor(tr, tg, tb, 1))
					local rr, rg, rb = HSV(0.69, 0.13)
					for i = 1, #self.glows do self.glows[i]:SetVertexColor(rr, rg, rb, 1) end
					local sr, sg, sb = HSV(0.30, 1)
					for i = 1, #self.stars do self.stars[i]:SetVertexColor(sr, sg, sb, 0.35) end
					local er, eg, eb = HSV(0.47, 0.60)
					edge:SetVertexColor(er, eg, eb, 0.55)
					if self.Fit then self:Fit() end -- The cap by the quest log toggle matches the background
				end
				-- Celebrations (over the board and not clipped to it so sparkles can fly outside it, takes no mouse clicks):
				-- a flash over the board and a word in the middle
				gems.fx = CreateFrame("Frame", nil, gems)
				gems.fx:SetAllPoints()
				gems.fx:SetFrameLevel(gems.grid:GetFrameLevel() + 30)
				gems.fx:EnableMouse(false)
				gems.fx.flash = gems.fx:CreateTexture(nil, "BACKGROUND")
				gems.fx.flash:SetTexture(hhWhite)
				gems.fx.flash:SetBlendMode("ADD")
				gems.fx.flash:SetAllPoints(gems.grid)
				gems.fx.flash:SetAlpha(0)
				gems.fx.hint = {}
				for i = 1, 2 do
					gems.fx.hint[i] = gems.fx:CreateTexture(nil, "ARTWORK")
					gems.fx.hint[i]:SetTexture(hhWhite)
					gems.fx.hint[i]:SetBlendMode("ADD")
					gems.fx.hint[i]:SetVertexColor(1, 0.85, 0.35, 1)
					gems.fx.hint[i]:Hide()
				end
				gems.fx.burst = gems.fx:CreateTexture(nil, "ARTWORK")
				gems.fx.burst:SetTexture("Interface\\Cooldown\\starburst")
				gems.fx.burst:SetBlendMode("ADD")
				gems.fx.burst:SetPoint("CENTER", gems.grid, "CENTER")
				gems.fx.burst:Hide()
				-- Level up logo (LEVEL UP in big gold letters with the new level under it, over golden rays that spin and a
				-- burst of light: it pops in big, settles, holds, then fades away, all animation groups)
				gems.levelUp = CreateFrame("Frame", nil, gems)
				gems.levelUp:SetSize(320, 140)
				gems.levelUp:SetPoint("CENTER", gems.grid, "CENTER", 0, 0)
				gems.levelUp:SetFrameLevel(gems.fx:GetFrameLevel() + 3)
				gems.levelUp:Hide()
				local rays = gems.levelUp:CreateTexture(nil, "BACKGROUND")
				rays:SetTexture("Interface\\Cooldown\\starburst")
				rays:SetBlendMode("ADD")
				rays:SetVertexColor(1, 0.80, 0.25, 0.9)
				rays:SetSize(420, 420)
				rays:SetPoint("CENTER")
				local spin = rays:CreateAnimationGroup()
				spin:SetLooping("REPEAT")
				local turn = spin:CreateAnimation("Rotation")
				turn:SetDegrees(-360)
				turn:SetDuration(6)
				local burst = gems.levelUp:CreateTexture(nil, "BORDER")
				burst:SetTexture("Interface\\Cooldown\\star4")
				burst:SetBlendMode("ADD")
				burst:SetVertexColor(1, 0.95, 0.70, 1)
				burst:SetSize(90, 90)
				burst:SetPoint("CENTER")
				burst:SetAlpha(0)
				local bang = burst:CreateAnimationGroup()
				local grow = bang:CreateAnimation("Scale")
				grow:SetScale(5, 5)
				grow:SetDuration(0.5)
				grow:SetSmoothing("OUT")
				local bangFade = bang:CreateAnimation("Alpha")
				bangFade:SetFromAlpha(1)
				bangFade:SetToAlpha(0)
				bangFade:SetDuration(0.5)
				local title = gems.levelUp:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
				title:SetPoint("CENTER", 0, 14)
				local titleFont = title:GetFont()
				if titleFont then title:SetFont(titleFont, 52, "THICKOUTLINE") end
				title:SetTextColor(1, 0.84, 0.15)
				title:SetShadowOffset(3, -3)
				title:SetText(L["LEVEL UP!"])
				local sub = gems.levelUp:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
				sub:SetPoint("TOP", title, "BOTTOM", 0, -6)
				local subFont = sub:GetFont()
				if subFont then sub:SetFont(subFont, 26, "OUTLINE") end
				sub:SetTextColor(0.55, 0.90, 1)
				local show = gems.levelUp:CreateAnimationGroup()
				local fadeIn = show:CreateAnimation("Alpha")
				fadeIn:SetFromAlpha(0)
				fadeIn:SetToAlpha(1)
				fadeIn:SetDuration(0.12)
				fadeIn:SetOrder(1)
				local pop = show:CreateAnimation("Scale")
				pop:SetScale(1.3, 1.3)
				pop:SetDuration(0.16)
				pop:SetSmoothing("OUT")
				pop:SetOrder(1)
				local settle = show:CreateAnimation("Scale")
				settle:SetScale(1 / 1.3, 1 / 1.3)
				settle:SetDuration(0.18)
				settle:SetSmoothing("IN_OUT")
				settle:SetOrder(2)
				local fadeOut = show:CreateAnimation("Alpha")
				fadeOut:SetFromAlpha(1)
				fadeOut:SetToAlpha(0)
				fadeOut:SetStartDelay(1.5)
				fadeOut:SetDuration(0.5)
				fadeOut:SetOrder(3)
				show:SetScript("OnFinished", function()
					spin:Stop()
					gems.levelUp:Hide()
				end)
				function gems.levelUp:Play(level)
					sub:SetFormattedText(L["Level %d"], level)
					self:Show()
					show:Stop()
					bang:Stop()
					spin:Play()
					bang:Play()
					show:Play()
				end
				gems.levelUp:SetScript("OnHide", function()
					show:Stop()
					bang:Stop()
					spin:Stop()
				end)
				gems.fx.banner = CreateFrame("Frame", nil, gems.fx)
				gems.fx.banner:SetSize(1, 1)
				gems.fx.banner:SetPoint("CENTER", gems.grid, "CENTER")
				gems.fx.banner:Hide()
				gems.fx.bannerText = gems.fx.banner:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
				local bannerFont = gems.fx.bannerText:GetFont()
				if bannerFont then gems.fx.bannerText:SetFont(bannerFont, 36, "THICKOUTLINE") end
				gems.fx.bannerText:SetPoint("CENTER")
				local back = gems.grid:CreateTexture(nil, "BACKGROUND")
				back:SetTexture(hhWhite)
				back:SetVertexColor(0.08, 0.07, 0.10, 0.85)
				back:SetAllPoints()
				-- Tiles (an edge for the highlight, and the gem: a colored tile with the gem icon, lighter when the pointer
				-- is over it)
				for c = 1, gemSize do
					gemTiles[c] = {}
					for r = 1, gemSize do
						local tile = CreateFrame("Button", nil, gems.grid)
						tile.c, tile.r = c, r
						tile.ox, tile.oy, tile.scale, tile.alpha = 0, 0, 1, 1
						tile.edge = tile:CreateTexture(nil, "BACKGROUND")
						tile.edge:SetPoint("TOPLEFT", 1, -1)
						tile.edge:SetPoint("BOTTOMRIGHT", -1, 1)
						tile.edge:SetColorTexture(0, 0, 0, 0)
						tile.art = CreateFrame("Frame", nil, tile)
						tile.bg = tile.art:CreateTexture(nil, "BORDER")
						tile.bg:SetAllPoints()
						tile.icon = tile.art:CreateTexture(nil, "ARTWORK")
						tile.icon:SetPoint("TOPLEFT", 3, -3)
						tile.icon:SetPoint("BOTTOMRIGHT", -3, 3)
						tile.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
						tile.hover = tile.art:CreateTexture(nil, "OVERLAY")
						tile.hover:SetAllPoints()
						tile.hover:SetColorTexture(1, 1, 1, 0.15)
						tile.hover:Hide()
						tile:SetScript("OnEnter", function(self) self.hover:Show() end)
						tile:SetScript("OnLeave", function(self) self.hover:Hide() end)
						-- Click a gem and then a gem next to it to swap them, or drag a gem towards the gem to swap it with.
						-- Dragging uses the game's drag start (it fires once when the mouse moves a little while held), the
						-- direction is from where the mouse was pressed, and the click that follows the drag is ignored.
						tile:RegisterForDrag("LeftButton")
						tile:SetScript("OnMouseDown", function(self, button)
							if button ~= "LeftButton" then return end
							self.downX, self.downY = GetCursorPosition()
							self.dragged = nil
							gems.dpadActive = false -- Playing with the mouse
						end)
						tile:SetScript("OnDragStart", function(self)
							if not self.downX then return end
							local x, y = GetCursorPosition()
							local dx, dy = x - self.downX, y - self.downY
							if dx == 0 and dy == 0 then return end
							self.dragged = true
							gemPickC, gemPickR = nil, nil
							local key
							if math.abs(dx) > math.abs(dy) then key = dx > 0 and "R" or "L" else key = dy > 0 and "U" or "D" end
							GemDrag(self.c, self.r, key)
						end)
						tile:SetScript("OnClick", function(self)
							if self.dragged then
								self.dragged = nil
								return
							end
							GemClick(self.c, self.r)
						end)
						gemTiles[c][r] = tile
					end
				end
				-- Special gem looks (made to stand out: the tile gets a bright colored frame and its whole square glows and
				-- gently pulses, two big bursts of light spin round it in opposite directions). Flame gems are fiery orange and yellow, star gems gold and white with a spinning star on top, and
				-- hypercubes have red, green and blue bursts that make a rainbow. All animation groups, made the first time a
				-- tile shows a special gem and only playing while it does.
				gems.SpecialLook = function(tile, special)
					if not special and not tile.looks then return end
					if not tile.looks then
						local looks = {anims = {}}
						tile.looks = looks
						local function Spin(region, degrees, seconds)
							local group = region:CreateAnimationGroup()
							group:SetLooping("REPEAT")
							local turn = group:CreateAnimation("Rotation")
							turn:SetDegrees(degrees)
							turn:SetDuration(seconds)
							looks.anims[#looks.anims + 1] = group
						end
						local function Pulse(region, low, seconds)
							local group = region:CreateAnimationGroup()
							group:SetLooping("BOUNCE")
							local fade = group:CreateAnimation("Alpha")
							fade:SetFromAlpha(1)
							fade:SetToAlpha(low)
							fade:SetDuration(seconds)
							fade:SetSmoothing("IN_OUT")
							looks.anims[#looks.anims + 1] = group
						end
						-- Bright frame round the square (it shows round the edge and lights up the see-through tile)
						looks.frame = tile.art:CreateTexture(nil, "BORDER", nil, -2)
						looks.frame:SetTexture(hhWhite)
						looks.frame:SetPoint("TOPLEFT", -2, 2)
						looks.frame:SetPoint("BOTTOMRIGHT", 2, -2)
						Pulse(looks.frame, 0.85, 0.9) -- (only a gentle pulse)
						-- Glow over the square, under the gem
						looks.aura = tile.art:CreateTexture(nil, "BORDER", nil, 2)
						looks.aura:SetTexture(hhWhite)
						looks.aura:SetBlendMode("ADD")
						looks.aura:SetAllPoints()
						Pulse(looks.aura, 0.6, 0.9)
						-- Bursts of light spinning round the gem (three for a hypercube)
						looks.bursts = {}
						for i = 1, 3 do
							local burst = tile.art:CreateTexture(nil, "BORDER", nil, 3)
							burst:SetTexture("Interface\\Cooldown\\starburst")
							burst:SetBlendMode("ADD")
							local out = 10 + i * 4
							burst:SetPoint("TOPLEFT", -out, out)
							burst:SetPoint("BOTTOMRIGHT", out, -out)
							Spin(burst, i == 2 and 360 or -360, 2.5 + i)
							looks.bursts[i] = burst
						end
						-- Badge in the bottom right corner (fireball for a flame gem, holy light for a star gem)
						looks.badge = tile.art:CreateTexture(nil, "OVERLAY", nil, 2)
						looks.badge:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						looks.badge:SetPoint("BOTTOMRIGHT", -1, 1)
						looks.badge:SetPoint("TOPLEFT", tile.art, "CENTER", 0, 0)
						looks.badgeEdge = tile.art:CreateTexture(nil, "OVERLAY", nil, 1)
						looks.badgeEdge:SetTexture(hhWhite)
						looks.badgeEdge:SetVertexColor(0, 0, 0, 1)
						looks.badgeEdge:SetPoint("TOPLEFT", looks.badge, "TOPLEFT", -1, 1)
						looks.badgeEdge:SetPoint("BOTTOMRIGHT", looks.badge, "BOTTOMRIGHT", 1, -1)
						-- Spinning star on top (star gems)
						looks.star = tile.art:CreateTexture(nil, "OVERLAY", nil, -1)
						looks.star:SetTexture("Interface\\Cooldown\\star4")
						looks.star:SetBlendMode("ADD")
						looks.star:SetPoint("TOPLEFT", -8, 8)
						looks.star:SetPoint("BOTTOMRIGHT", 8, -8)
						Spin(looks.star, 360, 2.5)
						Pulse(looks.star, 0.5, 0.35)
					end
					local looks = tile.looks
					local colors = {
						flame = {frame = {1, 0.45, 0.05}, aura = {1, 0.40, 0.05}, bursts = {{1, 0.35, 0}, {1, 0.80, 0.10}}},
						star = {frame = {1, 0.90, 0.40}, aura = {1, 0.90, 0.50}, bursts = {{1, 0.85, 0.30}, {1, 1, 0.85}}},
						cube = {frame = {0.85, 0.75, 1}, aura = {0.70, 0.55, 1}, bursts = {{1, 0.15, 0.15}, {0.15, 1, 0.25}, {0.25, 0.40, 1}}},
					}
					local set = colors[special]
					-- The frame is the gem's color for flame and star gems (so you can see which color they match)
					local g = gemIcons[gemBoard[tile.c][tile.r]]
					if set and g and special ~= "cube" then set = {frame = {g[2], g[3], g[4]}, aura = set.aura, bursts = set.bursts} end
					looks.badge:Hide()
					looks.badgeEdge:Hide()
					if set and g and special ~= "cube" then
						-- Bursts in the gem's color too (a bright and a pale shade)
						set.bursts = {{g[2], g[3], g[4]}, {0.5 + g[2] * 0.5, 0.5 + g[3] * 0.5, 0.5 + g[4] * 0.5}}
						set.aura = {g[2], g[3], g[4]}
					end
					looks.frame:SetShown(set ~= nil)
					looks.aura:SetShown(set ~= nil)
					looks.star:SetShown(special == "star")
					for i = 1, 3 do looks.bursts[i]:SetShown(set ~= nil and set.bursts[i] ~= nil) end
					if set then
						looks.frame:SetVertexColor(set.frame[1], set.frame[2], set.frame[3], 1)
						looks.aura:SetVertexColor(set.aura[1], set.aura[2], set.aura[3], 0.6)
						for i = 1, #set.bursts do looks.bursts[i]:SetVertexColor(set.bursts[i][1], set.bursts[i][2], set.bursts[i][3], 1) end
						looks.star:SetVertexColor(1, 1, 0.9, 1)
					end
					for i = 1, #looks.anims do
						if set then
							if not looks.anims[i]:IsPlaying() then looks.anims[i]:Play() end
						else
							looks.anims[i]:Stop()
						end
					end
				end

				-- Light beams across the board for star gems (a few are made and reused, they flash and fade with an
				-- animation group)
				gems.beams = {}
				local function Beam()
					for i = 1, #gems.beams do
						if not gems.beams[i]:IsShown() then return gems.beams[i] end
					end
					local beam = gems.fx:CreateTexture(nil, "ARTWORK", nil, 1)
					beam:SetTexture(hhWhite)
					beam:SetBlendMode("ADD")
					beam:Hide()
					beam.flash = beam:CreateAnimationGroup()
					local fade = beam.flash:CreateAnimation("Alpha")
					fade:SetFromAlpha(1)
					fade:SetToAlpha(0)
					fade:SetDuration(0.5)
					fade:SetSmoothing("IN")
					beam.flash:SetScript("OnFinished", function() beam:Hide() end)
					gems.beams[#gems.beams + 1] = beam
					return beam
				end

				-- Function to show the special gem effects: a burst of sparkles and a word for each special gem made, a
				-- fireball for a flame gem going off, beams of light along the row and column for a star gem, lightning to
				-- every gem a hypercube clears (one sound for each kind of effect)
				gems.SpecialFx = function(made, blasts)
					local played = {}
					local function Sound(id, cut)
						if played[id] then return end
						played[id] = true
						PlayPowerSound(id, cut)
					end
					local names = {flame = {L["Flame Gem!"], 1, 0.5, 0.1}, star = {L["Star Gem!"], 1, 0.9, 0.4}, cube = {L["Hypercube!"], 0.8, 0.65, 1}}
					for void, m in ipairs(made or {}) do
						local c, r = math.floor(m[1] / 100), m[1] % 100
						local x, y = (c - 0.5) * gemCell, -(r - 0.5) * gemCell
						local n = names[m[2]]
						for s = 1, 14 do GemSpark(x, y, n[2], n[3], n[4]) end
						GemText(x, y + 10, n[1], n[2], n[3], n[4], 30, 1.1)
						GemShow(gemTiles[c][r])
						Sound(m[2] == "cube" and 569771 or 569631, 1.2) -- holyimpactddhigh or arcanemissileimpact1a
					end
					for void, b in ipairs(blasts or {}) do
						local x, y = (b.c - 0.5) * gemCell, -(b.r - 0.5) * gemCell
						if b.kind == "flame" then
							for s = 1, 22 do GemSpark(x, y, 1, 0.35 + math.random() * 0.35, 0.05) end
							gemFlash = math.max(gemFlash, 0.35)
							gemShake = math.max(gemShake, 6)
							gemShakeRate = gemShake / 0.4
							Sound(568461, 1.4) -- fireballimpacta
						elseif b.kind == "star" then
							local size = gemSize * gemCell
							local across, down = Beam(), Beam()
							across:ClearAllPoints()
							across:SetPoint("LEFT", gems.grid, "TOPLEFT", 0, y)
							across:SetSize(size, gemCell * 0.6)
							down:ClearAllPoints()
							down:SetPoint("TOP", gems.grid, "TOPLEFT", x, 0)
							down:SetSize(gemCell * 0.6, size)
							for void, beam in ipairs({across, down}) do
								beam:SetVertexColor(1, 0.92, 0.55, 1)
								beam:Show()
								beam.flash:Stop()
								beam.flash:Play()
							end
							for s = 1, gemSize do
								GemSpark((s - 0.5) * gemCell, y, 1, 0.9, 0.5)
								GemSpark(x, -(s - 0.5) * gemCell, 1, 0.9, 0.5)
							end
							gemFlash = math.max(gemFlash, 0.3)
							gemShake = math.max(gemShake, 5)
							gemShakeRate = gemShake / 0.4
							Sound(568516, 1.4) -- lightningboltimpact
						elseif b.kind == "cube" then
							for key in pairs(gemMatched) do
								local c, r = math.floor(key / 100), key % 100
								if b.all or gemBoard[c][r] == b.color then
									for s = 1, 3 do GemSpark((c - 0.5) * gemCell, -(r - 0.5) * gemCell, 0.75, 0.85, 1) end
								end
							end
							for s = 1, 20 do GemSpark(x, y, 0.85, 0.7, 1) end
							gemFlash = math.max(gemFlash, b.all and 0.8 or 0.5)
							gemShake = math.max(gemShake, b.all and 10 or 7)
							gemShakeRate = gemShake / 0.5
							Sound(568678, 1.6) -- arcaneexplosion
							C_Timer.After(0.05, function() PlayPowerSound(566735, 1.4) end) -- blastedlandslightningbolt
						end
					end
					gems.fx:SetScript("OnUpdate", GemFxUpdate)
				end

				-- Function for a level up's fresh board (every gem shatters with sparkles in its color, then a new board
				-- rains in, special gems are lost)
				gems.NewBoard = function()
					gemState = "busy"
					wipe(gemMatched)
					for c = 1, gemSize do
						for r = 1, gemSize do
							gemMatched[c * 100 + r] = true
							local g = gemIcons[gemBoard[c][r]] or {nil, 1, 1, 1}
							GemSpark((c - 0.5) * gemCell, -(r - 0.5) * gemCell, g[2], g[3], g[4])
						end
					end
					gems.fx:SetScript("OnUpdate", GemFxUpdate)
					PlayPowerSound(568678, 1.2) -- arcaneexplosion
					GemPlay("clear", 0.4, function()
						GemFill()
						GemDropAll(function()
							gemState = "play"
							GemEdges()
							gems:Idle()
						end)
					end)
				end

				-- Function to find a possible move and make its two gems pulse with a gold glow for a moment (returns false
				-- if there's none). A hypercube next to any gem is always a possible move.
				gems.ShowHint = function()
					local moves = {}
					for c = 1, gemSize do
						for r = 1, gemSize do
							for void, d in ipairs({{1, 0}, {0, 1}}) do
								local c2, r2 = c + d[1], r + d[2]
								if c2 <= gemSize and r2 <= gemSize then
									if gemSpecial[c][r] == "cube" or gemSpecial[c2][r2] == "cube" then
										moves[#moves + 1] = {c, r, c2, r2}
									elseif gemBoard[c][r] ~= gemBoard[c2][r2] then
										GemSwapData(c, r, c2, r2)
										local found = GemLineAt(c, r) or GemLineAt(c2, r2)
										GemSwapData(c, r, c2, r2)
										if found then moves[#moves + 1] = {c, r, c2, r2} end
									end
								end
							end
						end
					end
					if #moves == 0 then return false end
					local m = moves[math.random(#moves)]
					gems.fx.hint[1]:SetAllPoints(gemTiles[m[1]][m[2]])
					gems.fx.hint[2]:SetAllPoints(gemTiles[m[3]][m[4]])
					gems.fx.hint[1]:Show()
					gems.fx.hint[2]:Show()
					gems.fx.hintTime = 0
					gems.fx:SetScript("OnUpdate", GemFxUpdate)
					return true
				end

				-- Auto hint: after 12 seconds with no move, a possible move glows on its own (it doesn't use up a hint, and it
				-- glows again every 12 seconds until a move is made). It's a one-off timer, started again after each move.
				function gems:Idle()
					if self.idleTimer then self.idleTimer:Cancel() end
					self.idleTimer = nil
					if gemState == "play" and self:IsVisible() then
						self.idleTimer = C_Timer.NewTimer(12, function()
							self.idleTimer = nil
							if gemState == "play" and self:IsVisible() and not self.help:IsShown() and not self.confirm:IsShown() then
								self.ShowHint()
								self:Idle()
							end
						end)
					end
				end

				-- Idle shimmer: every few seconds a random gem catches the light with a little glint (an animation group
				-- that moves the glint to another gem each time it repeats)
				local glint = gems.fx:CreateTexture(nil, "OVERLAY", nil, 7) -- (on the effects frame so it shows over the gems)
				glint:SetTexture("Interface\\Cooldown\\star4")
				glint:SetBlendMode("ADD")
				glint:SetVertexColor(1, 1, 1, 0.9)
				glint:SetAlpha(0)
				local shimmer = glint:CreateAnimationGroup()
				shimmer:SetLooping("REPEAT")
				local glintIn = shimmer:CreateAnimation("Alpha")
				glintIn:SetFromAlpha(0)
				glintIn:SetToAlpha(1)
				glintIn:SetDuration(0.25)
				glintIn:SetOrder(1)
				local glintGrow = shimmer:CreateAnimation("Scale")
				glintGrow:SetScale(1.6, 1.6)
				glintGrow:SetDuration(0.25)
				glintGrow:SetOrder(1)
				local glintOut = shimmer:CreateAnimation("Alpha")
				glintOut:SetFromAlpha(1)
				glintOut:SetToAlpha(0)
				glintOut:SetDuration(0.35)
				glintOut:SetEndDelay(2.4)
				glintOut:SetOrder(2)
				local glintShrink = shimmer:CreateAnimation("Scale")
				glintShrink:SetScale(1 / 1.6, 1 / 1.6)
				glintShrink:SetDuration(0.35)
				glintShrink:SetOrder(2)
				local function MoveGlint()
					local tile = gemTiles[math.random(gemSize)][math.random(gemSize)]
					glint:ClearAllPoints()
					glint:SetPoint("CENTER", tile, "CENTER", gemCell * 0.18, gemCell * 0.18)
					glint:SetSize(gemCell * 0.5, gemCell * 0.5)
					glint:SetShown(gemState == "play")
				end
				shimmer:SetScript("OnLoop", MoveGlint)
				MoveGlint()
				shimmer:Play()

				-- Score, and a message in the middle (when the board is shuffled)
				gems.score = gems:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				gems.score:SetPoint("TOPLEFT", 10, -8)
				gems.score:SetTextColor(0.78, 0.74, 0.92)
				-- Level bar (above the board, as wide as it, with a bright edge, a glowing fill that gently pulses, the level and
				-- how many gems of how many are cleared written on it, and a flash when you level up, all animation groups)
				gems.bar = CreateFrame("Frame", nil, gems)
				gems.bar:SetPoint("BOTTOMLEFT", gems.grid, "TOPLEFT", 0, 9)
				gems.bar:SetPoint("BOTTOMRIGHT", gems.grid, "TOPRIGHT", 0, 9)
				gems.bar:SetHeight(22)
				gems.bar:SetFrameLevel(gems.grid:GetFrameLevel() + 1)
				local barEdge = gems.bar:CreateTexture(nil, "BACKGROUND", nil, 0)
				barEdge:SetTexture(hhWhite)
				barEdge:SetVertexColor(0.62, 0.50, 0.95, 1)
				barEdge:SetAllPoints()
				local barBack = gems.bar:CreateTexture(nil, "BACKGROUND", nil, 1)
				barBack:SetTexture(hhWhite)
				barBack:SetVertexColor(0.05, 0.04, 0.09, 1)
				barBack:SetPoint("TOPLEFT", 1, -1)
				barBack:SetPoint("BOTTOMRIGHT", -1, 1)
				gems.bar.fill = gems.bar:CreateTexture(nil, "BORDER")
				gems.bar.fill:SetTexture(hhWhite)
				gems.bar.fill:SetGradient("HORIZONTAL", CreateColor(0.62, 0.28, 1, 1), CreateColor(0.35, 0.90, 1, 1))
				gems.bar.fill:SetPoint("TOPLEFT", 1, -1)
				gems.bar.fill:SetPoint("BOTTOMLEFT", 1, 1)
				gems.bar.fill:SetWidth(1)
				-- A band of light sweeps along the fill over and over (like a copy progress bar), it's kept inside the fill by
				-- a frame that clips it, and the sweep's length and speed are set to the fill's width (see GemScoreText)
				gems.bar.clip = CreateFrame("Frame", nil, gems.bar)
				gems.bar.clip:SetPoint("TOPLEFT", gems.bar.fill, "TOPLEFT")
				gems.bar.clip:SetPoint("BOTTOMRIGHT", gems.bar.fill, "BOTTOMRIGHT")
				gems.bar.clip:SetClipsChildren(true)
				local sweepFrame = CreateFrame("Frame", nil, gems.bar.clip)
				sweepFrame:SetSize(70, 22)
				sweepFrame:SetPoint("RIGHT", gems.bar.clip, "LEFT", 0, 0) -- Starts just before the fill
				for i = 1, 2 do
					local half = sweepFrame:CreateTexture(nil, "ARTWORK")
					half:SetTexture(hhWhite)
					half:SetBlendMode("ADD")
					half:SetSize(35, 22)
					if i == 1 then
						half:SetPoint("LEFT")
						half:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, 0.55))
					else
						half:SetPoint("RIGHT")
						half:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.55), CreateColor(1, 1, 1, 0))
					end
				end
				gems.bar.sweep = sweepFrame:CreateAnimationGroup()
				gems.bar.sweep:SetLooping("REPEAT")
				gems.bar.sweepMove = gems.bar.sweep:CreateAnimation("Translation")
				gems.bar.sweepMove:SetSmoothing("IN_OUT")
				gems.bar.sweepMove:SetEndDelay(2) -- Pause between sweeps
				local barFlash = gems.bar:CreateTexture(nil, "ARTWORK", nil, 1)
				barFlash:SetTexture(hhWhite)
				barFlash:SetBlendMode("ADD")
				barFlash:SetAllPoints()
				barFlash:SetAlpha(0)
				gems.bar.flash = barFlash:CreateAnimationGroup()
				local flashUp = gems.bar.flash:CreateAnimation("Alpha")
				flashUp:SetFromAlpha(0)
				flashUp:SetToAlpha(1)
				flashUp:SetDuration(0.12)
				flashUp:SetOrder(1)
				local flashDown = gems.bar.flash:CreateAnimation("Alpha")
				flashDown:SetFromAlpha(1)
				flashDown:SetToAlpha(0)
				flashDown:SetDuration(0.7)
				flashDown:SetSmoothing("OUT")
				flashDown:SetOrder(2)
				gems.bar.text = gems.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				gems.bar.text:SetPoint("CENTER", 0, 0)
				local barFont = gems.bar.text:GetFont()
				if barFont then gems.bar.text:SetFont(barFont, 13, "OUTLINE") end
				gems.message = gems:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
				gems.message:SetPoint("CENTER", 0, 12)
				gems.hint = gems:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				gems.hint:SetPoint("TOP", gems.message, "BOTTOM", 0, -8)
				-- Help (a round ? button in the top right corner shows or hides a panel over the board explaining the game,
				-- the board can't be played while it shows)
				gems.help = CreateFrame("Frame", nil, gems)
				-- (it covers the level bar and stops above the map's coordinates so its edge shows all the way round)
				gems.help:SetPoint("TOPLEFT", gems, "TOPLEFT", 16, -28)
				gems.help:SetPoint("BOTTOMRIGHT", gems, "BOTTOMRIGHT", -16, 32)
				gems.help:SetFrameLevel(gems.fx:GetFrameLevel() + 5)
				gems.help:EnableMouse(true)
				gems.help:Hide()
				local helpEdge = gems.help:CreateTexture(nil, "BACKGROUND", nil, 0)
				helpEdge:SetTexture(hhWhite)
				helpEdge:SetVertexColor(0.40, 0.32, 0.60, 0.8)
				helpEdge:SetAllPoints()
				helpEdge:Hide() -- No border
				local helpBack = gems.help:CreateTexture(nil, "BACKGROUND", nil, 1)
				helpBack:SetTexture(hhWhite)
				helpBack:SetGradient("VERTICAL", CreateColor(0.03, 0.025, 0.06, 0.97), CreateColor(0.08, 0.06, 0.15, 0.97))
				helpBack:SetAllPoints()
				local helpTitle = gems.help:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				helpTitle:SetPoint("TOP", 0, -14)
				local helpTitleFont = helpTitle:GetFont()
				if helpTitleFont then helpTitle:SetFont(helpTitleFont, 22, "") end
				helpTitle:SetText(L["How to play Gemfall"])
				-- Help pages (one topic on each page: a big heading, a picture that shows it, and a few short lines, with
				-- arrow buttons and the mouse wheel to go between pages and the page number between the arrows)
				local G = function(n) return gemIcons[n][1] end -- Picture of a gem kind
				local fireball, holy, shard = "Interface\\Icons\\Spell_Fire_Fireball02", "Interface\\Icons\\Spell_Holy_HolyBolt", "Interface\\Icons\\INV_Enchant_ShardBrilliantLarge"
				-- Each page: heading, picture (rows of icons, "=" is an arrow, the colors are tile colors), text
				local helpPages = {
					{L["Match gems"], {{G(1), G(1), G(1)}}, {1, 1, 1},
						L["Swap two gems side by side to make a line of 3 or more of the same color."] .. "\n\n" .. L["Drag a gem onto its neighbour, or click one gem then the other."]},
					{L["Score big"], {{G(2), G(2), G(2), G(2)}}, {2, 2, 2, 2},
						L["Longer lines score more."] .. "\n\n" .. L["When falling gems make more lines, that's a chain. Chains score more each time and show a word."]},
					{L["Flame gem"], {{G(1), G(1), G(1), G(1), "=", fireball}}, {1, 1, 1, 1, 0, 1},
						L["Line up 4 gems of the same color to make a Flame gem of that color."] .. "\n\n" .. L["Match it with gems of its color and it explodes, clearing the gems round it."]},
					{L["Star gem"], {{G(3), "", ""}, {G(3), "", ""}, {G(3), G(3), G(3)}, {"", "=", holy}}, {3, 0, 0, 3, 0, 0, 3, 3, 3, 0, 0, 3},
						L["Match 5 gems of the same color in an L or T shape to make a Star gem of that color."] .. "\n\n" .. L["Match it with gems of its color and it clears its whole row and column."]},
					{L["Hypercube"], {{G(4), G(4), G(4), G(4), G(4), "=", shard}}, {4, 4, 4, 4, 4, 0, -1},
						L["Line up 5 gems of the same color to make a Hypercube."] .. "\n\n" .. L["Swap it with any gem next to it and every gem of that color is cleared. Two Hypercubes together clear the board."]},
					{L["Level up"], {{"art:arrow"}}, {0},
						L["Clearing gems fills the bar above the board. A full bar takes you up a level."] .. "\n\n" .. L["Each level scores more, shatters the board for a fresh one, and has its own colors and sound."]},
					{L["Hints"], {{"btn:hint"}}, {0},
						L["Press Hint to light up a possible move. You get 3 each game, and each level up gives one back."] .. "\n\n" .. L["Stuck? Wait a few seconds and a move lights up for free."]},
					{L["Buttons"], quad = {
						{"btn:gemfall", L["Shows or hides the game. A hidden game is paused."]},
						{"btn:reset", L["Starts a new game. It asks first."]},
						{"btn:power", L["Turns the console off. Your game is kept."]},
						{"btn:help", L["Opens this help."]},
					}},
					{L["Saving"], {}, {},
						L["Your game carries on after a reload or logging out."] .. "\n\n" .. L["Your best score is kept. The game ends when there are no moves left."]},
				}
				-- Console buttons as they look on the console (color, letter on the button, name under it)
				local helpButtons = {
					["btn:gemfall"] = {0.20, 0.52, 0.26, "", L["GEMFALL"]},
					["btn:reset"] = {0.20, 0.36, 0.62, "", L["RESET"]},
					["btn:power"] = {0.58, 0.15, 0.15, "", L["POWER"]},
					["btn:hint"] = {0.74, 0.40, 0.64, "A", L["HINT"]},
					["btn:help"] = {0.30, 0.22, 0.48, "?", L["Help"]},
				}
				local helpPage = 1
				local helpArea = CreateFrame("Frame", nil, gems.help)
				helpArea:SetPoint("TOPLEFT", 26, -52)
				helpArea:SetPoint("BOTTOMRIGHT", -26, 50)
				-- (the heading, picture and text are a block in the middle of the page, up and down and side to side)
				local block = CreateFrame("Frame", nil, helpArea)
				block:SetPoint("LEFT")
				block:SetPoint("RIGHT")
				block:SetHeight(1)
				local pageHead = block:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				pageHead:SetPoint("TOP", 0, 0)
				local pageHeadFont = pageHead:GetFont()
				if pageHeadFont then pageHead:SetFont(pageHeadFont, 26, "") end
				local picture = CreateFrame("Frame", nil, block)
				picture:SetPoint("TOP", pageHead, "BOTTOM", 0, -16)
				local pictureIcons = {}
				-- Level up picture: a green arrow pointing up (a gradient shaft and a chevron head with a soft green glow
				-- behind it), it gently floats up and fades in over and over (animation group)
				local arrowArt = CreateFrame("Frame", nil, picture)
				arrowArt:SetSize(44, 44)
				arrowArt:Hide()
				local arrowGlow = arrowArt:CreateTexture(nil, "BACKGROUND")
				arrowGlow:SetTexture("Interface\\Cooldown\\starburst")
				arrowGlow:SetBlendMode("ADD")
				arrowGlow:SetVertexColor(0.30, 1, 0.35, 0.55)
				arrowGlow:SetPoint("CENTER", 0, 2)
				arrowGlow:SetSize(84, 84)
				local shaft = arrowArt:CreateTexture(nil, "ARTWORK")
				shaft:SetTexture(hhWhite)
				shaft:SetGradient("VERTICAL", CreateColor(0.05, 0.45, 0.10, 1), CreateColor(0.35, 1, 0.40, 1))
				shaft:SetSize(12, 26)
				shaft:SetPoint("BOTTOM", 0, 2)
				for side = -1, 1, 2 do
					local wing = arrowArt:CreateTexture(nil, "ARTWORK", nil, 1)
					wing:SetTexture(hhWhite)
					wing:SetVertexColor(0.35, 1, 0.40, 1)
					wing:SetSize(10, 26)
					wing:SetPoint("TOP", side * 4, -2)
					if wing.SetRotation then wing:SetRotation(side * math.rad(40)) end
				end
				local float = arrowArt:CreateAnimationGroup()
				float:SetLooping("REPEAT")
				local rise = float:CreateAnimation("Translation")
				rise:SetOffset(0, 8)
				rise:SetDuration(1.1)
				rise:SetSmoothing("OUT")
				local fadeUp = float:CreateAnimation("Alpha")
				fadeUp:SetFromAlpha(0.35)
				fadeUp:SetToAlpha(1)
				fadeUp:SetDuration(1.1)
				local pageText = block:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				pageText:SetPoint("TOP", picture, "BOTTOM", 0, -18)
				pageText:SetPoint("LEFT", 10, 0)
				pageText:SetPoint("RIGHT", -10, 0)
				local pageTextFont = pageText:GetFont()
				if pageTextFont then pageText:SetFont(pageTextFont, 19, "") end
				pageText:SetJustifyH("CENTER")
				pageText:SetJustifyV("TOP")
				pageText:SetSpacing(3)
				-- Buttons page: a button in each quarter of the page with its name and what it does under it
				local quadHead = helpArea:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				quadHead:SetPoint("TOP", 0, -6)
				if pageHeadFont then quadHead:SetFont(pageHeadFont, 26, "") end
				local quadArea = CreateFrame("Frame", nil, helpArea)
				quadArea:SetPoint("TOPLEFT", 0, -44)
				quadArea:SetPoint("BOTTOMRIGHT")
				local quads = {}
				for i = 1, 4 do
					local q = CreateFrame("Frame", nil, quadArea)
					local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
					q:SetPoint("TOPLEFT", quadArea, col == 0 and "TOPLEFT" or "TOP", 0, 0)
					q:SetPoint("BOTTOMRIGHT", quadArea, col == 0 and "BOTTOM" or "BOTTOMRIGHT", 0, 0)
					q:ClearAllPoints()
					q:SetPoint(row == 0 and (col == 0 and "TOPLEFT" or "TOPRIGHT") or (col == 0 and "BOTTOMLEFT" or "BOTTOMRIGHT"))
					q.col, q.row = col, row
					q.disc = q:CreateTexture(nil, "ARTWORK")
					q.disc:SetTexture(hhWhite)
					q.disc:SetSize(64, 64)
					if q.CreateMaskTexture then
						local mask = q:CreateMaskTexture()
						mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
						mask:SetAllPoints(q.disc)
						q.disc:AddMaskTexture(mask)
					end
					q.letter = q:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
					q.letter:SetPoint("CENTER", q.disc, "CENTER")
					q.name = q:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
					local nameFont = q.name:GetFont()
					if nameFont then q.name:SetFont(nameFont, 20, "") end
					q.name:SetPoint("TOP", q.disc, "BOTTOM", 0, -10)
					q.text = q:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
					if pageTextFont then q.text:SetFont(pageTextFont, 17, "") end
					q.text:SetPoint("TOP", q.name, "BOTTOM", 0, -6)
					q.text:SetJustifyH("CENTER")
					q.text:SetSpacing(2)
					quads[i] = q
				end
				-- Function to size the quarters to the page (each is half as wide and half as tall)
				local function SizeQuads()
					local w, h = quadArea:GetWidth(), quadArea:GetHeight()
					if not w or not h or (issecretvalue and (issecretvalue(w) or issecretvalue(h))) or w < 10 then return end
					for i, q in ipairs(quads) do
						q:SetSize(w / 2, h / 2)
						q.text:SetWidth(w / 2 - 30)
						-- The button, name and text sit together in the middle of the quarter
						local height = 64 + 10 + q.name:GetStringHeight() + 6 + q.text:GetStringHeight()
						q.disc:ClearAllPoints()
						q.disc:SetPoint("TOP", q, "TOP", 0, -(h / 2 - height) / 2)
					end
				end
				quadArea:SetScript("OnSizeChanged", SizeQuads)
				local pageNumber = gems.help:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				pageNumber:SetPoint("BOTTOM", 0, 20)
				-- Function to show a page
				local function ShowPage(page)
					helpPage = math.max(1, math.min(#helpPages, page))
					local p = helpPages[helpPage]
					-- The buttons page has its own layout
					arrowArt:Hide()
					block:SetShown(not p.quad)
					quadHead:SetShown(p.quad ~= nil)
					quadArea:SetShown(p.quad ~= nil)
					pageNumber:SetFormattedText("%d / %d", helpPage, #helpPages)
					gems.help.prev:SetEnabled(helpPage > 1)
					gems.help.next:SetEnabled(helpPage < #helpPages)
					if p.quad then
						quadHead:SetText(p[1])
						for i, q in ipairs(quads) do
							local b = helpButtons[p.quad[i][1]]
							q.disc:SetVertexColor(b[1], b[2], b[3], 1)
							q.letter:SetText(b[4])
							q.name:SetText(b[5])
							q.text:SetText(p.quad[i][2])
						end
						SizeQuads()
						return
					end
					pageHead:SetText(p[1])
					local size, gap, n = 44, 4, 0
					local rows, cols = #p[2], 0
					for r = 1, rows do cols = math.max(cols, #p[2][r]) end
					local buttons = p[2][1] and p[2][1][1] and helpButtons[p[2][1][1]]
					if buttons then gap = 34 end -- (buttons are spread out with their names under them)
					local picHeight = rows > 0 and (rows * size + (rows - 1) * gap + (buttons and 18 or 0)) or 1
					picture:SetSize(math.max(1, cols * size + (cols - 1) * gap), picHeight)
					for r = 1, rows do
						for c = 1, #p[2][r] do
							n = n + 1
							local cell = pictureIcons[n]
							if not cell then
								cell = {bg = picture:CreateTexture(nil, "BORDER"), icon = picture:CreateTexture(nil, "ARTWORK"), arrow = picture:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge"), badge = picture:CreateTexture(nil, "OVERLAY")}
								cell.bg:SetTexture(hhWhite)
								cell.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
								cell.badge:SetTexCoord(0.08, 0.92, 0.08, 0.92)
								cell.disc = picture:CreateTexture(nil, "ARTWORK", nil, 1)
								cell.disc:SetTexture(hhWhite)
								if picture.CreateMaskTexture then
									local mask = picture:CreateMaskTexture()
									mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
									mask:SetAllPoints(cell.disc)
									cell.disc:AddMaskTexture(mask)
								end
								cell.letter = picture:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
								cell.label = picture:CreateFontString(nil, "OVERLAY", "GameFontNormal")
								cell.arrow:SetText(">")
								pictureIcons[n] = cell
							end
							local x, y = (c - 1) * (size + gap), -(r - 1) * (size + gap)
							local what, color = p[2][r][c], p[3][n]
							cell.bg:ClearAllPoints()
							cell.bg:SetPoint("TOPLEFT", x, y)
							cell.bg:SetSize(size, size)
							cell.icon:ClearAllPoints()
							cell.icon:SetPoint("TOPLEFT", x + 4, y - 4)
							cell.icon:SetSize(size - 8, size - 8)
							cell.arrow:ClearAllPoints()
							cell.arrow:SetPoint("CENTER", picture, "TOPLEFT", x + size / 2, y - size / 2)
							cell.arrow:SetShown(what == "=")
							cell.icon:SetShown(what ~= "=" and what ~= "")
							cell.bg:SetShown(what ~= "=" and what ~= "" and color ~= 0)
							-- (a flame or star gem shows its gem picture with the fireball or holy light badge in the corner)
							local special = what == fireball or what == holy
							cell.badge:ClearAllPoints()
							cell.badge:SetPoint("BOTTOMRIGHT", picture, "TOPLEFT", x + size - 2, y - size + 2)
							cell.badge:SetSize(size / 2, size / 2)
							cell.badge:Hide()
							-- Level up arrow picture
							if what == "art:arrow" then
								arrowArt:ClearAllPoints()
								arrowArt:SetPoint("TOPLEFT", x, y)
								arrowArt:Show()
								float:Play()
								cell.icon:Hide()
								cell.bg:Hide()
							end
							-- Console button picture
							local button = helpButtons[what]
							cell.disc:SetShown(button ~= nil)
							cell.letter:SetShown(button ~= nil)
							cell.label:SetShown(button ~= nil)
							if button then
								cell.disc:ClearAllPoints()
								cell.disc:SetPoint("TOPLEFT", x, y)
								cell.disc:SetSize(size, size)
								cell.disc:SetVertexColor(button[1], button[2], button[3], 1)
								cell.letter:ClearAllPoints()
								cell.letter:SetPoint("CENTER", cell.disc, "CENTER")
								cell.letter:SetText(button[4])
								cell.label:ClearAllPoints()
								cell.label:SetPoint("TOP", cell.disc, "BOTTOM", 0, -6)
								cell.label:SetText(button[5])
								cell.icon:Hide()
								cell.bg:Hide()
							end
							if what ~= "=" and what ~= "" and not button and what ~= "art:arrow" then
								cell.icon:SetTexture(what)
								cell.icon:SetDesaturated(special)
								if special then
									local g = gemIcons[color]
									local boost = 1 / math.max(g[2], g[3], g[4], 0.01)
									cell.icon:SetVertexColor(math.min(1, g[2] * boost * 1.1), math.min(1, g[3] * boost * 1.1), math.min(1, g[4] * boost * 1.1))
								else
									cell.icon:SetVertexColor(1, 1, 1)
								end
							end
							if color and color > 0 then
								local g = gemIcons[color]
								-- (a special gem's tile is solid, a normal gem's see-through)
								local solid = what == fireball or what == holy
								cell.bg:SetVertexColor(g[2], g[3], g[4], solid and 0.55 or 0.40)
							elseif color == -1 then
								cell.bg:SetVertexColor(0.90, 0.90, 1, 0.45) -- Hypercube tile
							end
						end
					end
					for i = n + 1, #pictureIcons do
						pictureIcons[i].bg:Hide()
						pictureIcons[i].icon:Hide()
						pictureIcons[i].arrow:Hide()
						pictureIcons[i].badge:Hide()
						pictureIcons[i].disc:Hide()
						pictureIcons[i].letter:Hide()
						pictureIcons[i].label:Hide()
					end
					pageText:SetText(p[4])
					-- Center the block on the page
					local height = pageHead:GetStringHeight() + 16 + picHeight + 18 + pageText:GetStringHeight()
					block:SetHeight(height)
					block:ClearAllPoints()
					block:SetPoint("LEFT", helpArea, "LEFT")
					block:SetPoint("RIGHT", helpArea, "RIGHT")
					pageNumber:SetFormattedText("%d / %d", helpPage, #helpPages)
					gems.help.prev:SetEnabled(helpPage > 1)
					gems.help.next:SetEnabled(helpPage < #helpPages)
				end
				-- Arrow buttons (previous and next page)
				for void, side in ipairs({{"prev", "Prev", -60, -1}, {"next", "Next", 60, 1}}) do
					local button = CreateFrame("Button", nil, gems.help)
					button:SetSize(32, 32)
					button:SetPoint("BOTTOM", side[3], 12)
					button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. side[2] .. "Page-Up")
					button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. side[2] .. "Page-Down")
					button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-" .. side[2] .. "Page-Disabled")
					button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
					button:SetScript("OnClick", function()
						PlayPowerSound(567407) -- uchatscrollbutton
						ShowPage(helpPage + side[4])
					end)
					gems.help[side[1]] = button
				end
				gems.help:EnableMouseWheel(true)
				gems.help:SetScript("OnMouseWheel", function(self, delta) ShowPage(helpPage - delta) end)
				gems.help:SetScript("OnShow", function() ShowPage(1) end) -- Starts at the first page each time
				-- Reset confirmation (a box in the middle of the board asking to start a new game, with yes and no buttons,
				-- the board can't be played while it shows)
				gems.confirm = CreateFrame("Frame", nil, gems)
				gems.confirm:SetSize(300, 116)
				gems.confirm:SetPoint("CENTER", gems.grid, "CENTER", 0, 0)
				gems.confirm:SetFrameLevel(gems.help:GetFrameLevel() + 1)
				gems.confirm:EnableMouse(true)
				gems.confirm:Hide()
				local confirmEdge = gems.confirm:CreateTexture(nil, "BACKGROUND", nil, 0)
				confirmEdge:SetTexture(hhWhite)
				confirmEdge:SetVertexColor(0.62, 0.50, 0.95, 1)
				confirmEdge:SetAllPoints()
				local confirmBack = gems.confirm:CreateTexture(nil, "BACKGROUND", nil, 1)
				confirmBack:SetTexture(hhWhite)
				confirmBack:SetGradient("VERTICAL", CreateColor(0.03, 0.025, 0.06, 0.98), CreateColor(0.10, 0.07, 0.18, 0.98))
				confirmBack:SetPoint("TOPLEFT", 1, -1)
				confirmBack:SetPoint("BOTTOMRIGHT", -1, 1)
				local confirmTitle = gems.confirm:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				confirmTitle:SetPoint("TOP", 0, -16)
				confirmTitle:SetText(L["Start a new game?"])
				local confirmText = gems.confirm:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				confirmText:SetPoint("TOP", confirmTitle, "BOTTOM", 0, -8)
				confirmText:SetText(L["Your score and level will be lost."])
				local function ConfirmButton(label, x, action)
					local button = CreateFrame("Button", nil, gems.confirm)
					button:SetSize(96, 26)
					button:SetPoint("BOTTOM", x, 14)
					local back = button:CreateTexture(nil, "BACKGROUND")
					back:SetTexture(hhWhite)
					back:SetVertexColor(0.30, 0.22, 0.48, 1)
					back:SetAllPoints()
					local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
					text:SetPoint("CENTER")
					text:SetText(label)
					button:SetScript("OnEnter", function() back:SetVertexColor(0.42, 0.32, 0.66, 1) end)
					button:SetScript("OnLeave", function() back:SetVertexColor(0.30, 0.22, 0.48, 1) end)
					button:SetScript("OnClick", function()
						PlayPowerSound(567481) -- iuiinterfacebuttona
						gems.confirm:Hide()
						action()
					end)
				end
				ConfirmButton(L["Yes"], -56, function() GemNew() end)
				ConfirmButton(L["No"], 56, function() end)
				gems.helpButton = CreateFrame("Button", nil, gems)
				gems.helpButton:SetSize(20, 20)
				gems.helpButton:SetPoint("TOPRIGHT", gems, "TOPRIGHT", -10, -5)
				gems.helpButton:SetFrameLevel(gems.help:GetFrameLevel() + 2)
				local helpDisc = gems.helpButton:CreateTexture(nil, "BACKGROUND")
				helpDisc:SetTexture(hhWhite)
				helpDisc:SetVertexColor(0.30, 0.22, 0.48, 1)
				helpDisc:SetAllPoints()
				if gems.helpButton.CreateMaskTexture then
					local mask = gems.helpButton:CreateMaskTexture()
					mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
					mask:SetAllPoints(helpDisc)
					helpDisc:AddMaskTexture(mask)
				end
				local helpMark = gems.helpButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				helpMark:SetPoint("CENTER", 0, 0)
				helpMark:SetText("?")
				gems.helpButton:SetScript("OnEnter", function() helpDisc:SetVertexColor(0.42, 0.32, 0.66, 1) end)
				gems.helpButton:SetScript("OnLeave", function() helpDisc:SetVertexColor(0.30, 0.22, 0.48, 1) end)
				gems.helpButton:SetScript("OnClick", function()
					PlayPowerSound(567407) -- uchatscrollbutton
					gems.help:SetShown(not gems.help:IsShown())
				end)
				-- Hide the game when the map is closed, fit the board again when the map changes size
				-- The game fades in when it's shown and fades out when the gemfall button hides it (animation groups, so
				-- there's no OnUpdate)
				gems.fadeIn = gems:CreateAnimationGroup()
				local fadeIn = gems.fadeIn:CreateAnimation("Alpha")
				fadeIn:SetFromAlpha(0)
				fadeIn:SetToAlpha(1)
				fadeIn:SetDuration(0.3)
				fadeIn:SetSmoothing("OUT")
				gems.fadeOut = gems:CreateAnimationGroup()
				gems.fadeOut:SetToFinalAlpha(true)
				local fadeOut = gems.fadeOut:CreateAnimation("Alpha")
				fadeOut:SetFromAlpha(1)
				fadeOut:SetToAlpha(0)
				fadeOut:SetDuration(0.3)
				fadeOut:SetSmoothing("IN")
				gems.fadeOut:SetScript("OnFinished", function()
					gems:Hide()
					gems:SetAlpha(1)
				end)
				gems:SetScript("OnHide", function(self)
					self:Hide() -- Stays hidden when the map is opened again
					self:Idle() -- Stops the auto hint timer
					self.help:Hide()
					self.confirm:Hide()
					self.levelUp:Hide()
					self.fadeIn:Stop()
					self.fadeOut:Stop()
					self:SetAlpha(1)
					GemMusic()
				end)
				gems:SetScript("OnShow", function(self)
					self.fadeIn:Play()
					self:Idle()
					GemMusic()
				end)
				gems:SetScript("OnSizeChanged", function() if gemState then GemLayout() end end)
				gems:SetLevelColors(1)
				-- Carry on with a game that was saved when the UI was last reloaded or you logged out (it's checked first: 64
				-- gems with no lines and at least one move, a game that doesn't check out is dropped). It stays hidden until
				-- the gemfall button is pressed.
				local board, score, best, shown, level, levelGems, hints, specials = string.match(LeaMapsLC["GemGame"] or "", "^(%d+):(%d+):(%d+):(%d):?(%d*):?(%d*):?(%d*):?(%d*)$")
				if specials and #specials ~= gemSize * gemSize then specials = nil end
				LeaMapsLC["GemGame"] = ""
				if board and #board == gemSize * gemSize then
					local names = {"flame", "star", "cube"}
					for c = 1, gemSize do
						gemBoard[c] = gemBoard[c] or {}
						gemSpecial[c] = {}
						for r = 1, gemSize do
							local i = (c - 1) * gemSize + r
							local k = tonumber(strsub(board, i, i))
							local s = specials and names[tonumber(strsub(specials, i, i))]
							gemSpecial[c][r] = s
							if k == 0 and s == "cube" then gemBoard[c][r] = 0 else gemBoard[c][r] = gemIcons[k] and k or nil end
							if not gemBoard[c][r] or (s == "cube" and k ~= 0) then board = nil end
						end
					end
					if board and GemFindMatches() == 0 and GemHasMove() then
						gemScore, gemCombo, gemCursorC, gemCursorR, gemPickC, gemPickR = tonumber(score), 0, 1, 1, nil, nil
						gemBestAtStart, gemNewBest = tonumber(best), false
						gemRecordDone = gemBestAtStart > 0 and gemScore > gemBestAtStart
						gems.dpadActive = false
						gems.level, gems.levelGems = math.max(1, tonumber(level) or 1), tonumber(levelGems) or 0
						gems.hints = math.min(3, tonumber(hints) or 3)
						gems:SetLevelColors(gems.level)
						gems.grid:SetAlpha(1)
						GemMessage()
						GemShowAll()
						gemState = "play" -- Stays hidden until the gemfall button is pressed
					end
				end
			end

			-- Function to get the game to save when the UI is reloaded or you log out (empty if there's no game to carry on:
			-- none started or no more moves, a game that was never loaded this session is kept)
			LeaMapsLC.GemSaveText = function()
				if not gems then return LeaMapsLC["GemGame"] or "" end
				if gemState ~= "play" then return "" end
				local digits = {}
				for c = 1, gemSize do
					for r = 1, gemSize do digits[#digits + 1] = gemBoard[c][r] end
				end
				local specials, codes = {}, {flame = 1, star = 2, cube = 3}
				for c = 1, gemSize do
					for r = 1, gemSize do specials[#specials + 1] = codes[gemSpecial[c][r]] or 0 end
				end
				return table.concat(digits) .. ":" .. gemScore .. ":" .. gemBestAtStart .. ":" .. (gems:IsShown() and "1" or "0") .. ":" .. gems.level .. ":" .. gems.levelGems .. ":" .. gems.hints .. ":" .. table.concat(specials)
			end

			-- Function to create the screen cover and the gem board
			local function CreateHandheldScreen()
				-- Screen cover for the power (over the whole screen inside the surround, takes the mouse while it shows,
				-- its children are clipped to the screen so the logo can slide in from above it)
				hhScreen = CreateFrame("Frame", nil, WorldMapFrame)
				hhScreen:SetFrameStrata("HIGH")
				hhScreen:SetFrameLevel(math.min(frameLevel + 20, 10000))
				hhScreen:SetAllPoints(borderFrame)
				hhScreen:EnableMouse(true)
				hhScreen:SetClipsChildren(true)
				hhScreen:Hide()
				hhScreen.dark = hhScreen:CreateTexture(nil, "BACKGROUND")
				hhScreen.dark:SetTexture(hhWhite)
				hhScreen.dark:SetVertexColor(0.06, 0.065, 0.07, 1)
				hhScreen.dark:SetAllPoints()
				hhScreen.holder = CreateFrame("Frame", nil, hhScreen)
				hhScreen.holder:SetAllPoints()
				-- Boot screen parts (white screen, the four emblem diamonds, a flash, the name on the white screen, and the
				-- product name and licence line on the black screen)
				local p = {}
				p.white = hhScreen:CreateTexture(nil, "BACKGROUND", nil, 1)
				p.white:SetTexture(hhWhite)
				p.white:SetVertexColor(0.97, 0.97, 0.98, 1)
				p.white:SetAllPoints()
				p.white:SetAlpha(0)
				p.pieces = {}
				for i = 1, 4 do
					local dir = hhPieceDirs[i]
					local piece = hhScreen.holder:CreateLine(nil, "ARTWORK")
					piece:SetColorTexture(dir[3], dir[4], dir[5], 1)
					piece:SetAlpha(0)
					p.pieces[i] = piece
				end
				p.flash = hhScreen.holder:CreateTexture(nil, "OVERLAY")
				p.flash:SetTexture(hhWhite)
				p.flash:SetVertexColor(1, 1, 1, 1)
				p.flash:SetAllPoints()
				p.flash:SetAlpha(0)
				local function BootText(size, r, g, b, y, text)
					local fs = hhScreen.holder:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
					local font = fs:GetFont()
					if font then fs:SetFont(font, size, "") end
					fs:SetTextColor(r, g, b)
					fs:SetShadowColor(0, 0, 0, 0)
					fs:SetPoint("CENTER", hhScreen.holder, "CENTER", 0, y)
					fs:SetText(text)
					fs:SetAlpha(0)
					return fs
				end
				p.word = BootText(28, 0.24, 0.12, 0.30, -52, "LEATRIX")
				p.sub = BootText(10, 0.40, 0.32, 0.46, -74, L["POCKET ENTERTAINMENT"])
				p.name = BootText(18, 0.85, 0.85, 0.90, -30, L["LEATRIX POCKET MAP"])
				p.licence = BootText(9, 0.55, 0.55, 0.60, -52, L["Licensed for use in Azeroth"])
				hhScreen.boot = p
				hhScreen:SetScript("OnHide", HHResetPower)
				-- Gem board
				CreateGems()
			end

			-- Function to create the handheld
			local function CreateHandheld()
				hhParts = {}
				local pl, pr, pt, pb = 96, 96, 18, 30 -- Same as the theme body size
				-- Body (charcoal black like the black editions of real handhelds, a darker copy a little lower shows as the
				-- thickness of the plastic, a faint gloss line along the top)
				HHRoundRect("BACKGROUND", -2, 0.04, 0.04, 0.05, pl, pr, pt, pb, 40, -4)
				HHRoundRect("BACKGROUND", -1, 0.13, 0.13, 0.15, pl, pr, pt, pb, 40)
				local shine = HHTexture("BACKGROUND", 1, 1, 1, 1, 0.14)
				shine:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -pl + 40, pt)
				shine:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", pr - 40, pt)
				shine:SetHeight(2)
				-- Screen surround (glossy near black, round corners, the map and bars draw over the middle of it) and the name
				-- under the screen
				HHRoundRect("BACKGROUND", 0, 0.05, 0.05, 0.06, 12, 12, 10, 22, 8)
				HHText("LEATRIX  ·  POCKET MAP", 0.42, 0.42, 0.47, "BOTTOM", 0, -12)
				-- Red power light on the left of the screen
				hhLedGlow = HHDisc("ARTWORK", 0, 14, 1, 0.20, 0.20, 0.35, "LEFT", -6, 0)
				hhLed = HHDisc("ARTWORK", 1, 7, 1, 0.25, 0.25, 1, "LEFT", -6, 0)
				-- D-pad (with a darker copy below for depth and a dimple in the middle)
				local dx, dy = -54, 24
				HHRect("ARTWORK", 0, 20, 60, 0.01, 0.01, 0.01, 1, "LEFT", dx, dy - 3)
				HHRect("ARTWORK", 0, 60, 20, 0.01, 0.01, 0.01, 1, "LEFT", dx, dy - 3)
				HHRect("ARTWORK", 1, 20, 60, 0.06, 0.06, 0.07, 1, "LEFT", dx, dy)
				HHRect("ARTWORK", 1, 60, 20, 0.06, 0.06, 0.07, 1, "LEFT", dx, dy)
				HHDisc("ARTWORK", 2, 12, 0.11, 0.11, 0.12, 1, "LEFT", dx, dy)
				-- D-pad arms (each arm lights up a little when the pointer is over it and darkens while it's held, with a soft
				-- click, uchatscrollbutton, and moves the highlight or swaps the gem picked up in the gem game)
				for void, arm in ipairs({{"U", 0, 20}, {"D", 0, -20}, {"L", -20, 0}, {"R", 20, 0}}) do
					local key, ax, ay = arm[1], dx + arm[2], dy + arm[3]
					local glow = borderFrame:CreateTexture(nil, "ARTWORK", nil, 2)
					glow:SetTexture(hhWhite)
					glow:SetVertexColor(1, 1, 1, 0.14)
					glow:SetSize(20, 20)
					glow:SetPoint("CENTER", borderFrame, "LEFT", ax, ay)
					glow:Hide()
					local shade = borderFrame:CreateTexture(nil, "ARTWORK", nil, 3)
					shade:SetTexture(hhWhite)
					shade:SetVertexColor(0, 0, 0, 0.6)
					shade:SetSize(20, 20)
					shade:SetPoint("CENTER", borderFrame, "LEFT", ax, ay)
					shade:Hide()
					HHButton("LEFT", ax, ay, 20, 20, function()
						shade:Show()
						PlayPowerSound(567407)
						GemDpad(key)
					end, function() shade:Hide() end, function() glow:Show() end, function() glow:Hide() end)
				end
				-- A button under the gemfall button with a label underneath (with a darker copy below for depth, it lights up a little when the pointer is
				-- over it, presses down and darkens while it's held, with a click, iuiinterfacebuttona, and shows a hint in the
				-- gem game)
				local faceTop, faceBottom = CreateColor(0.74, 0.40, 0.64, 1), CreateColor(0.48, 0.17, 0.40, 1)
				local heldTop, heldBottom = CreateColor(0.58, 0.28, 0.50, 1), CreateColor(0.38, 0.12, 0.31, 1)
				for void, button in ipairs({{"A", "RIGHT", 54, -30, 567481, GemButtonA, L["HINT"]}}) do
					local key, point, x, y, sound, action = button[1], button[2], button[3], button[4], button[5], button[6]
					local labelText = HHText(button[7], 0.42, 0.42, 0.47, point, x, y - 22)
					local labelFont = labelText:GetFont()
					if labelFont then labelText:SetFont(labelFont, 8, "") end
					if key == "A" then
						hhParts.hintLabel = labelText -- Shows how many hints are left
						if LeaMapsLC.GemHintLabel then LeaMapsLC.GemHintLabel() end
					end
					HHDisc("ARTWORK", 0, 30, 0.18, 0.05, 0.14, 1, point, x, y - 3)
					local face = HHDisc("ARTWORK", 1, 30, 1, 1, 1, 1, point, x, y)
					face:SetGradient("VERTICAL", faceBottom, faceTop)
					local glow = borderFrame:CreateTexture(nil, "ARTWORK", nil, 2)
					glow:SetTexture(hhWhite)
					glow:SetVertexColor(1, 1, 1, 0.16)
					glow:SetAllPoints(face)
					MakeRound(glow)
					glow:Hide()
					local letter = HHText(key, 0.96, 0.86, 0.93, point, x, y)
					local function Press(down)
						local py = down and y - 2 or y
						face:ClearAllPoints(); face:SetPoint("CENTER", borderFrame, point, x, py)
						letter:ClearAllPoints(); letter:SetPoint("CENTER", borderFrame, point, x, py)
						if down then face:SetGradient("VERTICAL", heldBottom, heldTop) else face:SetGradient("VERTICAL", faceBottom, faceTop) end
					end
					HHButton(point, x, y, 30, 30, function()
						Press(true)
						PlayPowerSound(sound)
						action()
					end, function() Press(false) end, function() glow:Show() end, function() glow:Hide() end)
				end
				-- Big round buttons in the bottom corners of the body (each one has a darker copy below for depth and a small
				-- label, lights up a little when the pointer is over it, and presses down and darkens while it's held): power in
				-- the bottom left corner (dark red), gemfall (starts the gem game) on the right side (green) and reset in the bottom right corner (blue)
				local function HHBigButton(point, x, y, label, top, bottom, heldTop, heldBottom, action)
					HHDisc("ARTWORK", 0, 30, 0.02, 0.02, 0.03, 1, point, x, y - 3)
					local face = HHDisc("ARTWORK", 1, 30, 1, 1, 1, 1, point, x, y)
					face:SetGradient("VERTICAL", bottom, top)
					local glow = borderFrame:CreateTexture(nil, "ARTWORK", nil, 2)
					glow:SetTexture(hhWhite)
					glow:SetVertexColor(1, 1, 1, 0.16)
					glow:SetAllPoints(face)
					MakeRound(glow)
					glow:Hide()
					local labelText = HHText(label, 0.42, 0.42, 0.47, point, x, y - 22)
					local font = labelText:GetFont()
					if font then labelText:SetFont(font, 8, "") end
					local function Press(down)
						local py = down and y - 2 or y
						face:ClearAllPoints()
						face:SetPoint("CENTER", borderFrame, point, x, py)
						if down then face:SetGradient("VERTICAL", heldBottom, heldTop) else face:SetGradient("VERTICAL", bottom, top) end
					end
					HHButton(point, x, y, 30, 30, function()
						Press(true)
						action()
					end, function() Press(false) end, function() glow:Show() end, function() glow:Hide() end)
				end
				local redTop, redBottom = CreateColor(0.58, 0.15, 0.15, 1), CreateColor(0.30, 0.06, 0.06, 1)
				local redHeldTop, redHeldBottom = CreateColor(0.44, 0.10, 0.10, 1), CreateColor(0.22, 0.04, 0.04, 1)
				local greenTop, greenBottom = CreateColor(0.20, 0.52, 0.26, 1), CreateColor(0.08, 0.27, 0.12, 1)
				local greenHeldTop, greenHeldBottom = CreateColor(0.14, 0.40, 0.19, 1), CreateColor(0.05, 0.20, 0.08, 1)
				local blueTop, blueBottom = CreateColor(0.20, 0.36, 0.62, 1), CreateColor(0.08, 0.17, 0.34, 1)
				local blueHeldTop, blueHeldBottom = CreateColor(0.14, 0.27, 0.48, 1), CreateColor(0.05, 0.12, 0.26, 1)
				HHBigButton("BOTTOMLEFT", -60, 24, L["POWER"], redTop, redBottom, redHeldTop, redHeldBottom, HHTogglePower)
				HHBigButton("RIGHT", 54, 34, L["GEMFALL"], greenTop, greenBottom, greenHeldTop, greenHeldBottom, GemStart)
				HHBigButton("BOTTOMRIGHT", 54, 10, L["RESET"], blueTop, blueBottom, blueHeldTop, blueHeldBottom, GemReset)
				-- Speaker holes (a grid of small holes at an angle)
				local angle = math.rad(25)
				for row = 1, 4 do
					for col = 1, 3 do
						local lx, ly = (col - 2) * 9, (row - 2.5) * -9
						local x = 64 + lx * math.cos(angle) - ly * math.sin(angle)
						local y = -118 + lx * math.sin(angle) + ly * math.cos(angle)
						HHDisc("ARTWORK", 0, 5, 0.03, 0.03, 0.04, 1, "RIGHT", x, y)
					end
				end
				-- Screen cover and gem board
				CreateHandheldScreen()
			end

			-- Function to show or hide the Handheld theme
			local function SetHandheld(show)
				if show and not hhParts then CreateHandheld() end
				if hhParts then
					if not show then
						HHResetPower()
						if gems then gems:Hide() end
					end
					for i = 1, #hhParts do hhParts[i]:SetShown(show) end
				end
				if show then
					for i = 1, #edgeTextures do edgeTextures[i]:Hide() end
				end
			end

			-- Function to apply the map theme (runs on startup and when the theme is changed, no reload needed)
			ApplyMapTheme = function()
				local theme = mapThemes[LeaMapsLC["MapTheme"]] or mapThemes[1]
				local ar, ag, ab, hr, hg, hb, ha, bgBottom, bgTop
				local r, g, b
				if theme.classColor then
					local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))] or NORMAL_FONT_COLOR
					r, g, b = color.r, color.g, color.b
				elseif theme.color then
					r, g, b = theme.color[1], theme.color[2], theme.color[3]
				end
				if r then
					-- Base color recipe (dark wash on the title bar, the color itself for the accents)
					ar, ag, ab = r * 0.85, g * 0.85, b * 0.85
					hr, hg, hb, ha = r, g, b, 0.22
					bgBottom, bgTop = CreateColor(r * 0.10, g * 0.10, b * 0.10, 1), CreateColor(r * 0.20, g * 0.20, b * 0.20, 1)
				else
					ar, ag, ab = theme.accent[1], theme.accent[2], theme.accent[3]
					hr, hg, hb, ha = theme.hover[1], theme.hover[2], theme.hover[3], theme.hover[4]
					bgBottom = CreateColor(theme.bgBottom[1], theme.bgBottom[2], theme.bgBottom[3], theme.bgBottom[4] or 1)
					bgTop = CreateColor(theme.bgTop[1], theme.bgTop[2], theme.bgTop[3], theme.bgTop[4] or 1)
				end
				local topR, topG, topB = bgTop:GetRGB()
				-- Casing size (Retro TV and Handheld themes), then lay out the edge and shadow round it
				mapTheme.pads = theme.pads
				SetPixelEdges()
				-- Glass theme rim, reflection and see-through frame
				SetGlass(theme.glass == true)
				-- Handheld theme body, screen surround and buttons
				SetHandheld(theme.handheld == true)
				-- Retro TV theme casing, panel and screen effects
				SetTV(theme.tv == true)
				-- Title bar and coordinates background
				mapTheme.titleTexture:SetGradient("VERTICAL", bgBottom, bgTop)
				SetRainbow(mapTheme.titleBar, theme.rainbow)
				if mapTheme.footer then
					mapTheme.footerTexture:SetGradient("VERTICAL", bgBottom, bgTop)
					SetRainbow(mapTheme.footer, theme.rainbow)
				end
				-- Title bar buttons (icon in a bright accent color, hover box in the accent color with a white icon)
				local brightest = math.max(ar, ag, ab)
				local boost = brightest > 0 and 1 / brightest or 1 -- Brighten so the strongest channel is full (keeps the hue)
				for i, entry in ipairs(mapTheme.buttons) do
					if theme.box then entry.box:SetVertexColor(theme.box[1], theme.box[2], theme.box[3], theme.box[4]) else entry.box:SetVertexColor(ar, ag, ab, 0.6) end
					entry.color = theme.icon and {theme.icon[1], theme.icon[2], theme.icon[3]} or {ar * boost, ag * boost, ab * boost}
					if not entry.box:IsShown() then entry.icon:SetVertexColor(unpack(entry.color)) end
				end
				-- Quest search box (title bar color, a little lighter while typing)
				if theme.search then
					mapTheme.searchNormal, mapTheme.searchFocused = theme.search[1], theme.search[2]
				else
					mapTheme.searchNormal = {topR + 0.04, topG + 0.04, topB + 0.04}
					mapTheme.searchFocused = {topR + 0.10, topG + 0.10, topB + 0.10}
				end
				if mapTheme.SetSearchBg then mapTheme.SetSearchBg() end
				-- Zone menu hover
				if mapTheme.menuButtons then
					for i, button in ipairs(mapTheme.menuButtons) do
						button.Hover:SetColorTexture(hr, hg, hb, ha)
					end
				end
				-- Zone menu lists (title bar color, accent border and a highlight tinted with the hover color)
				-- (Rainbow gives the list the same rainbow as the title bar and each row its own rainbow highlight color)
				if mapTheme.popup then
					if theme.list then
						-- Themes with their own list colors (Glass has a see-through list)
						local c = theme.list
						mapTheme.popup:SetColors(c[1], c[2], c[3], c[4], c[5], c[6], 1, 1, 1, nil, c[7])
					else
						mapTheme.popup:SetColors(topR, topG, topB, ar, ag, ab, hr + (1 - hr) * 0.3, hg + (1 - hg) * 0.3, hb + (1 - hb) * 0.3, theme.rainbow and RainbowRowColor or nil)
					end
					SetRainbow(mapTheme.popup.frame, theme.rainbow)
				end
			end

			-- Set theme on startup (the theme dropdown sets it when changed)
			ApplyMapTheme()

			----------------------------------------------------------------------
			-- Configuration panel
			----------------------------------------------------------------------

			-- Create configuration panel
			local simplePanel = LeaMapsLC:CreatePanel("Use simple map frame", "simplePanel")

			-- Add controls
			LeaMapsLC:MakeTx(simplePanel, "Settings", 16, -72)
			LeaMapsLC:MakeCB(simplePanel, "ShowZoneMenu", "Show zone menus", 16, -92, false, "If checked, continent and zone menus will be shown in the map title bar.|n|nThe menus cannot be used in combat.")

			-- Map theme dropdown (applies straight away)
			LeaMapsLC:CreateDropdown("MapTheme", "Map Theme", 146, "TOPLEFT", simplePanel, "TOPLEFT", 16, -152, false, {{L["Classic"], 1}, {L["Warm"], 2}, {L["Charcoal"], 3}, {L["Class Color"], 4}, {L["Alliance"], 6}, {L["Horde"], 7}, {L["Green"], 10}, {L["Teal"], 9}, {L["Purple"], 8}, {L["Pink"], 5}, {L["Rainbow"], 11}, {L["Glass"], 13}, {L["Games"], 14}, {L["Retro TV"], 15}})
			LeaMapsCB["MapTheme"].onChange = ApplyMapTheme

			-- Back to Main Menu button click
			simplePanel.b:HookScript("OnClick", function()
				simplePanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			simplePanel.r:HookScript("OnClick", function()
				LeaMapsLC["ShowZoneMenu"] = "On"
				LeaMapsLC["MapTheme"] = 1
				ApplyMapTheme()
				if LeaMapsLC.SetZoneMenus then LeaMapsLC.SetZoneMenus() end
				simplePanel:Hide(); simplePanel:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["SimpleMapFrameBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["ShowZoneMenu"] = "On"
					if LeaMapsLC.SetZoneMenus then LeaMapsLC.SetZoneMenus() end
					LeaMapsLC["MapTheme"] = 1
					ApplyMapTheme()
					if simplePanel:IsShown() then simplePanel:Hide(); simplePanel:Show(); end
				else
					simplePanel:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show zone menus (simple map frame only)
		----------------------------------------------------------------------

		if LeaMapsLC["SimpleMapFrame"] == "On" and not LeaLockList["SimpleMapFrame"] then

			-- The menus can be turned on and off at any time, including in combat (they only use frames of our own).
			-- Nothing is created until the menus are turned on for the first time.

			local zoneMenusReady, updateZoneMenus

			local function SetupZoneMenus()

				-- Maps are changed with C_Map.OpenWorldMap which fires WORLD_MAP_OPEN. Blizzard's own event handler then changes
				-- the map in secure code so the map is never tainted (calling WorldMapFrame:SetMapID from here would taint it).
				-- C_Map.OpenWorldMap cannot be used in combat so the menus are disabled during combat.

				local continents, continentByID, continentByName = {}, {}, {}
				local selectedContinent, selectedZone, listsBuilt

				-- Create menu holder (in the title bar after the quest count, the map title is hidden while the menus show)
				local titleFrame, titleText = LeaMapsCB["MapTitleFrame"], LeaMapsCB["MapTitleText"]
				local holder = CreateFrame("Frame", nil, titleFrame)
				holder:SetHeight(20)
				holder:SetPoint("LEFT", LeaMapsCB["MapQuestCount"], "RIGHT", 4, 0)
				holder:SetFrameLevel(titleFrame:GetFrameLevel() + 3)
				holder:Hide()

				-- Function to create a divider line (separates the quest count and the menus)
				local function CreateDivider()
					local divider = holder:CreateTexture(nil, "ARTWORK")
					divider:SetColorTexture(0.4, 0.4, 0.4, 1)
					divider:SetSize(1, 12)
					return divider
				end

				-- Function to create a title bar menu button (map name, highlighted on hover)
				local function CreateMenuButton()
					local button = CreateFrame("Button", nil, holder)
					button:SetHeight(20)
					button.Hover = button:CreateTexture(nil, "BACKGROUND")
					button.Hover:SetAllPoints()
					button.Hover:SetColorTexture(1, 1, 1, 0.2)
					button.Hover:Hide()
					button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
					button.Text:SetPoint("LEFT", 6, 0)
					button.Text:SetWordWrap(false)
					button.Text:SetJustifyH("LEFT")
					button:SetScript("OnEnter", function(self)
						if self:IsEnabled() then self.Hover:Show() end
					end)
					button:SetScript("OnLeave", function(self)
						self.Hover:Hide()
					end)
					button:SetScript("OnDisable", function(self)
						self.Hover:Hide()
						self.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
					end)
					button:SetScript("OnEnable", function(self)
						self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
					end)
					return button
				end

				-- Function to set a button's text and fit the button to it (or to a fixed width if given, long names are cut short)
				local function SetButtonText(button, text, fixedWidth)
					button.Text:SetWidth(0)
					button.Text:SetText(text)
					local width = fixedWidth or math.min(button.Text:GetStringWidth(), 200)
					button.Text:SetWidth(width)
					button:SetWidth(width + 12)
				end

				-- Continent menu width (fits the longest continent name so the zone menu stays in the same place)
				local contWidth

				-- Create continent and zone menus (quest count | continent | zone)
				local contDivider = CreateDivider()
				contDivider:SetPoint("LEFT", holder, "LEFT", 4, 0)

				local contMenu = CreateMenuButton()
				contMenu:SetPoint("LEFT", contDivider, "RIGHT", 4, 0)

				local zoneDivider = CreateDivider()
				zoneDivider:SetPoint("LEFT", contMenu, "RIGHT", 4, 0)

				local zoneMenu = CreateMenuButton()
				zoneMenu:SetPoint("LEFT", zoneDivider, "RIGHT", 4, 0)

				-- Give the menu buttons the theme hover color
				mapTheme.menuButtons = {contMenu, zoneMenu}

				-- Function to sort entries by name
				local function SortByName(a, b) return a.name < b.name end

				-- Function to create a list entry (the first zone in each list is the continent itself)
				local function CreateEntry(mapID, name)
					local entry = {mapID = mapID, name = name, zoneByID = {}, zoneByName = {}}
					entry.zones = {{mapID = mapID, name = name}}
					return entry
				end

				-- Function to build the continent and zone lists (done once, the first time the map is shown)
				local function BuildLists()
					listsBuilt = true

					-- Continents (top-level continents in Cosmic and Azeroth, duplicate names keep the one with the most zones)
					local children = {}
					for i, rootID in ipairs({946, 947}) do
						local list = C_Map.GetMapChildrenInfo(rootID)
						if list then
							for j, info in ipairs(list) do
								if info.mapID ~= 947 and (info.mapType == Enum.UIMapType.Continent or info.mapType == Enum.UIMapType.World) then
									children[#children + 1] = info
								end
							end
						end
					end
					do
						for i, info in ipairs(children) do
							local entry = CreateEntry(info.mapID, info.name)
							local zones = C_Map.GetMapChildrenInfo(info.mapID, Enum.UIMapType.Zone)
							if zones then
								local list = {}
								for j, zoneInfo in ipairs(zones) do
									-- Duplicate zone names (such as phased versions) keep the lowest map ID
									local existing = entry.zoneByName[zoneInfo.name]
									if not existing then
										local zone = {mapID = zoneInfo.mapID, name = zoneInfo.name}
										list[#list + 1] = zone
										entry.zoneByName[zoneInfo.name] = zone
										entry.zoneByID[zoneInfo.mapID] = zone
									elseif zoneInfo.mapID < existing.mapID then
										entry.zoneByID[existing.mapID] = nil
										existing.mapID = zoneInfo.mapID
										entry.zoneByID[zoneInfo.mapID] = existing
									end
								end
								table.sort(list, SortByName)
								for j = 1, #list do
									entry.zones[#entry.zones + 1] = list[j]
								end
							end
							if #entry.zones > 1 then
								local existing = continentByName[info.name]
								if not existing or #entry.zones > #existing.zones then
									continentByName[info.name] = entry
								end
							end
						end
					end
					for name, entry in pairs(continentByName) do
						continents[#continents + 1] = entry
						continentByID[entry.mapID] = entry
					end
					table.sort(continents, SortByName)

					-- Azeroth and Cosmic go at the end (they have no zones)
					for i, mapID in ipairs({947, 946}) do
						local info = C_Map.GetMapInfo(mapID)
						if info then
							local entry = CreateEntry(mapID, info.name)
							continents[#continents + 1] = entry
							continentByID[mapID] = entry
						end
					end

				end

				-- Function to find the continent and zone for a map (walks up the map parents)
				local function FindSelection(mapID)
					local below
					for i = 1, 20 do
						local info = mapID and C_Map.GetMapInfo(mapID)
						if not info then return end
						local continent = continentByID[mapID] or ((info.mapType == Enum.UIMapType.Continent or info.mapType == Enum.UIMapType.World) and continentByName[info.name])
						if continent then
							local zone = below and (continent.zoneByID[below.mapID] or continent.zoneByName[below.name]) or continent.zones[1]
							return continent, zone
						end
						below = info
						mapID = info.parentMapID
					end
				end

				-- Function to change the map (taint-free, not available in combat)
				local function OpenMap(mapID)
					if InCombatLockdown() then return end
					if mapID and mapID ~= WorldMapFrame:GetMapID() then
						C_Map.OpenWorldMap(mapID)
					end
				end

				-- Continent and zone lists (see LeaMapsLC:CreatePopupList, colors are set by the map theme)
				local popup = LeaMapsLC:CreatePopupList(WorldMapFrame)
				mapTheme.popup = popup
				if ApplyMapTheme then ApplyMapTheme() end
				local function IsCurrentContinent(entry) return entry == selectedContinent end
				local function IsCurrentZone(entry) return entry == selectedZone end
				local function ChooseMap(entry) OpenMap(entry.mapID) end

				-- Open or close the lists when the menu buttons are clicked
				contMenu:SetScript("OnClick", function(self)
					if InCombatLockdown() then return end
					popup:Toggle(self, continents, IsCurrentContinent, ChooseMap, "TOPLEFT", "BOTTOMLEFT", 0, -2)
				end)

				zoneMenu:SetScript("OnClick", function(self)
					if InCombatLockdown() or not selectedContinent then return end
					popup:Toggle(self, selectedContinent.zones, IsCurrentZone, ChooseMap, "TOPLEFT", "BOTTOMLEFT", 0, -2)
				end)

				-- Function to enable or disable the menus (they are disabled in combat)
				local function SetMenusEnabled(inCombat)
					if inCombat then popup:Close() end
					contMenu:SetEnabled(not inCombat)
					zoneMenu:SetEnabled(not inCombat)
				end

				-- Function to update the menus to match the map that is showing
				local function HideMenus()
					popup:Close()
					holder:Hide()
					titleText:SetAlpha(1)
				end

				local function UpdateMenus()
					-- Menus turned off
					if LeaMapsLC["ShowZoneMenu"] ~= "On" then
						HideMenus()
						return
					end
					-- Build lists the first time they are needed while the map is showing
					if not listsBuilt then
						if not WorldMapFrame:IsShown() then return end
						BuildLists()
					end
					selectedContinent, selectedZone = FindSelection(WorldMapFrame:GetMapID())
					if not selectedContinent then
						HideMenus()
						return
					end

					-- Continent menu, then the zone menu if the continent has zones (it says Zones while the continent map shows)
					popup:Close()
					if not contWidth then
						contWidth = 0
						for i = 1, #continents do
							contMenu.Text:SetWidth(0)
							contMenu.Text:SetText(continents[i].name)
							contWidth = math.max(contWidth, contMenu.Text:GetStringWidth())
						end
						contWidth = math.min(math.ceil(contWidth), 200)
					end
					SetButtonText(contMenu, selectedContinent.name, contWidth)
					if #selectedContinent.zones > 1 then
						if selectedZone and selectedZone ~= selectedContinent.zones[1] then
							SetButtonText(zoneMenu, selectedZone.name)
						else
							SetButtonText(zoneMenu, L["Zones"])
						end
						zoneDivider:Show()
						zoneMenu:Show()
						holder:SetWidth(9 + contMenu:GetWidth() + 9 + zoneMenu:GetWidth())
					else
						zoneDivider:Hide()
						zoneMenu:Hide()
						holder:SetWidth(9 + contMenu:GetWidth())
					end

					-- Show the menus in place of the map title
					titleText:SetAlpha(0)
					holder:Show()
					SetMenusEnabled(InCombatLockdown())
				end

				-- Update menus when the map changes (runs after Blizzard's code has finished)
				hooksecurefunc(WorldMapFrame, "OnMapChanged", UpdateMenus)

				-- Update menus when the map is shown
				WorldMapFrame:HookScript("OnShow", UpdateMenus)

				-- Disable menus during combat
				holder:RegisterEvent("PLAYER_REGEN_DISABLED")
				holder:RegisterEvent("PLAYER_REGEN_ENABLED")
				holder:SetScript("OnEvent", function(self, event)
					SetMenusEnabled(event == "PLAYER_REGEN_DISABLED")
				end)

				updateZoneMenus = UpdateMenus

			end

			-- Function to turn the menus on or off
			local function SetZoneMenus()
				if LeaMapsLC["ShowZoneMenu"] == "On" and not zoneMenusReady then
					zoneMenusReady = true
					SetupZoneMenus()
				end
				if updateZoneMenus then updateZoneMenus() end
			end

			-- Set menus when the option is clicked (and from the panel reset button) and on startup
			LeaMapsCB["ShowZoneMenu"]:HookScript("OnClick", SetZoneMenus)
			LeaMapsLC.SetZoneMenus = SetZoneMenus
			SetZoneMenus()

		end

		----------------------------------------------------------------------
		-- Hide filter reset button
		----------------------------------------------------------------------

		if LeaMapsLC["NoFilterResetBtn"] == "On" then
			-- Create hidden frame
			local hiddenFrame = CreateFrame("FRAME")
			hiddenFrame:Hide()
			-- Parent reset button to hidden frame
			for i, v in pairs({WorldMapFrame:GetChildren()}) do
				if v.ResetButton then
					v.ResetButton:SetParent(hiddenFrame)
				end
				if v.FilterCounter then
					v.FilterCounter:HookScript("OnShow", function() v.FilterCounter:Hide() end)
					v.FilterCounterBanner:HookScript("OnShow", function() v.FilterCounterBanner:Hide() end)
				end
			end
		end

		----------------------------------------------------------------------
		-- Scale the map
		----------------------------------------------------------------------

		if LeaMapsLC["ScaleWorldMap"] == "On" then

			-- Create configuration panel
			local scalePanel = LeaMapsLC:CreatePanel("Scale the map", "scalePanel")

			-- Add controls
			LeaMapsLC:MakeTx(scalePanel, "Scale", 16, -72)
			LeaMapsLC:MakeSL(scalePanel, "MapScale", "Windowed", "Drag to set the scale for the windowed map.", 0.5, 2, 0.05, 36, -112, "%.1f")
			LeaMapsLC:MakeSL(scalePanel, "MaxMapScale", "Maximised", "Drag to set the scale for the maximised map.", 0.5, 2, 0.05, 206, -112, "%.1f")

			-- Function to set map frame scale
			local function SetMapScale()
				LeaMapsCB["MapScale"].f:SetFormattedText("%.0f%%", LeaMapsLC["MapScale"] * 100)
				LeaMapsCB["MaxMapScale"].f:SetFormattedText("%.0f%%", LeaMapsLC["MaxMapScale"] * 100)
				-- Do not change scale if the map frame cannot be changed (scale controls are locked then)
				if not LeaMapsLC:CanChangeMap() then return end
				if not WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				else
					WorldMapFrame:SetScale(LeaMapsLC["MaxMapScale"])
				end
				if LeaMapsLC.RefreshMapLines then LeaMapsLC.RefreshMapLines() end
			end

			-- Set scale properties when controls are changed and on startup
			LeaMapsCB["MapScale"]:HookScript("OnValueChanged", SetMapScale)
			LeaMapsCB["MaxMapScale"]:HookScript("OnValueChanged", SetMapScale)
			SetMapScale()

			-- Set scale when map size is toggled
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", SetMapScale)

			-- Lock scale controls while the map frame cannot be changed
			LeaMapsLC:AddMapLock(function(lock)
				LeaMapsLC:LockItem(LeaMapsCB["MapScale"], lock)
				LeaMapsLC:LockItem(LeaMapsCB["MaxMapScale"], lock)
				LeaMapsLC:LockItem(scalePanel.r, lock)
			end)

			-- Back to Main Menu button click
			scalePanel.b:HookScript("OnClick", function()
				scalePanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			scalePanel.r:HookScript("OnClick", function()
				if not LeaMapsLC:CanChangeMap() then return end
				-- Reset map scale
				LeaMapsLC["MapScale"] = 1.0
				LeaMapsLC["MaxMapScale"] = 1.0
				SetMapScale()
				-- Refresh panel
				scalePanel:Hide(); scalePanel:Show()
			end)

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["ScaleWorldMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile (not while the map frame cannot be changed)
					if LeaMapsLC:CanChangeMap() then
						LeaMapsLC["MapScale"] = 1.0
						LeaMapsLC["MaxMapScale"] = 0.9
						SetMapScale()
						if scalePanel:IsShown() then scalePanel:Hide(); scalePanel:Show(); end
					end
				else
					scalePanel:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Enhance battlefield map
		----------------------------------------------------------------------

		if LeaMapsLC["EnhanceBattleMap"] == "On" then

			-- Show teammates (only set if it's off, Blizzard's code reads this setting)
			if not BattlefieldMapOptions.showPlayers then BattlefieldMapOptions.showPlayers = true end

			-- Create configuraton panel
			local battleFrame = LeaMapsLC:CreatePanel("Enhance battlefield map", "battleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(battleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(battleFrame, "UnlockBattlefield", "Unlock battlefield map", 16, -92, false, "If checked, you can move the battlefield map by dragging any of its borders.")

			LeaMapsLC:MakeSL(battleFrame, "BattlePlayerArrowSize", "Player Arrow", "Drag to set the player arrow size.", 12, 48, 1, 36, -142, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleGroupIconSize", "Group Icons", "Drag to set the group icon size.", 8, 32, 1, 36, -202, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapOpacity", "Map Opacity", "Drag to set the battlefield map opacity.", 0.1, 1, 0.1, 36, -262, "%.0f")

			----------------------------------------------------------------------
			-- Preview
			----------------------------------------------------------------------

			-- The preview is made only of frames and textures of our own. The battlefield map is only read
			-- (map ID and zoom level) and nothing is written to it. The preview shows your current zone at the
			-- battlefield map zoom level with the player arrow, a few group icons and the map opacity.

			LeaMapsLC:MakeTx(battleFrame, "Preview", 244, -72)

			local pvWidth, pvHeight = 210, 190
			local pv = CreateFrame("Frame", nil, battleFrame)
			pv:SetPoint("TOPLEFT", battleFrame, "TOPLEFT", 244, -92)
			pv:SetSize(pvWidth, pvHeight)
			pv:SetClipsChildren(true)

			-- Checkered background so the map opacity can be seen
			do
				local square = 19
				local cols, rows = ceil(pvWidth / square), ceil(pvHeight / square)
				for row = 1, rows do
					for col = 1, cols do
						local t = pv:CreateTexture(nil, "BACKGROUND", nil, -8)
						t:SetSize(square, square)
						t:SetPoint("TOPLEFT", pv, "TOPLEFT", (col - 1) * square, -(row - 1) * square)
						if (row + col) % 2 == 0 then t:SetColorTexture(0.22, 0.22, 0.22, 1) else t:SetColorTexture(0.14, 0.14, 0.14, 1) end
					end
				end
			end

			-- Map canvas (holds the map tiles, scaled to the battlefield map zoom level)
			local pvCanvas = CreateFrame("Frame", nil, pv)
			pvCanvas:SetPoint("TOPLEFT")
			pvCanvas:SetSize(1, 1)
			local pvTiles = {}

			-- Icons (on their own frame above the map so they keep full opacity like the real map)
			local pvIcons = CreateFrame("Frame", nil, pv)
			pvIcons:SetAllPoints()
			pvIcons:SetFrameLevel(pvCanvas:GetFrameLevel() + 2)

			local pvArrow = pvIcons:CreateTexture(nil, "OVERLAY", nil, 2)
			pvArrow:SetAtlas("UI-WorldMapArrow")

			-- Group icons (offsets are from the player arrow, colors are class colors)
			local pvGroup = {}
			local pvGroupInfo = {
				{-38,  22, 0.78, 0.61, 0.43},	-- Warrior
				{ 34,  30, 0.25, 0.78, 0.92},	-- Mage
				{ 26, -36, 0.96, 0.55, 0.73},	-- Paladin
				{-30, -30, 1.00, 1.00, 1.00},	-- Priest
			}
			for i = 1, #pvGroupInfo do
				local t = pvIcons:CreateTexture(nil, "OVERLAY", nil, 1)
				t:SetTexture("Interface\\MINIMAP\\partyraidblipsv2")
				t:SetTexCoord(0.015625, 0.3125, 0.03125, 0.59375)
				t:SetVertexColor(pvGroupInfo[i][3], pvGroupInfo[i][4], pvGroupInfo[i][5], 1)
				pvGroup[i] = t
			end

			-- Thin border around the preview
			do
				local b = CreateFrame("Frame", nil, battleFrame, "BackdropTemplate")
				b:SetPoint("TOPLEFT", pv, "TOPLEFT", -1, 1)
				b:SetPoint("BOTTOMRIGHT", pv, "BOTTOMRIGHT", 1, -1)
				b:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
				b:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
				b:SetFrameLevel(pvIcons:GetFrameLevel() + 1)
			end

			local pvArrowX, pvArrowY = pvWidth / 2, pvHeight / 2

			-- Function to position the player arrow and group icons and set their sizes
			local function UpdatePreviewIcons()
				local arrowSize = LeaMapsLC["BattlePlayerArrowSize"]
				pvArrow:SetSize(arrowSize, arrowSize)
				pvArrow:ClearAllPoints()
				pvArrow:SetPoint("CENTER", pv, "TOPLEFT", pvArrowX, -pvArrowY)
				local iconSize = LeaMapsLC["BattleGroupIconSize"]
				for i = 1, #pvGroup do
					local t = pvGroup[i]
					t:SetSize(iconSize, iconSize)
					t:ClearAllPoints()
					t:SetPoint("CENTER", pv, "TOPLEFT", pvArrowX + pvGroupInfo[i][1], -(pvArrowY - pvGroupInfo[i][2]))
				end
			end

			-- Function to set the preview map opacity
			local function UpdatePreviewOpacity()
				pvCanvas:SetAlpha(LeaMapsLC["BattleMapOpacity"])
			end

			-- Function to draw your current zone in the preview (centered on you where possible)
			local function UpdatePreviewMap()
				for i = 1, #pvTiles do pvTiles[i]:Hide() end
				pvArrowX, pvArrowY = pvWidth / 2, pvHeight / 2
				local mapID = BattlefieldMapFrame:GetMapID() or C_Map.GetBestMapForUnit("player")
				local layers = mapID and C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[1]
				local textures = layerInfo and C_Map.GetMapArtLayerTextures(mapID, 1)
				if not textures then UpdatePreviewIcons() return end

				-- Use the battlefield map zoom level if it's showing this zone (read only), otherwise fit the zone into the preview
				local layerW, layerH = layerInfo.layerWidth, layerInfo.layerHeight
				local scale
				if BattlefieldMapFrame:IsShown() and BattlefieldMapFrame:GetMapID() == mapID then
					scale = BattlefieldMapFrame.ScrollContainer:GetCanvasScale()
				end
				if not scale or scale <= 0 or scale >= 1 then scale = min(pvWidth / layerW, pvHeight / layerH) end
				pvCanvas:SetScale(scale)
				pvCanvas:SetSize(layerW, layerH)

				-- Draw map tiles
				local tileW, tileH = layerInfo.tileWidth, layerInfo.tileHeight
				local cols, rows = ceil(layerW / tileW), ceil(layerH / tileH)
				local index = 0
				for row = 1, rows do
					for col = 1, cols do
						local fileID = textures[(row - 1) * cols + col]
						if fileID then
							index = index + 1
							local t = pvTiles[index]
							if not t then
								t = pvCanvas:CreateTexture(nil, "BACKGROUND")
								pvTiles[index] = t
							end
							t:SetSize(tileW, tileH)
							t:ClearAllPoints()
							t:SetPoint("TOPLEFT", pvCanvas, "TOPLEFT", (col - 1) * tileW, -(row - 1) * tileH)
							t:SetTexture(fileID, nil, nil, "TRILINEAR")
							t:Show()
						end
					end
				end

				-- Center the map on you (clamped so the map fills the preview where possible)
				local px, py = 0.5, 0.5
				local position = C_Map.GetPlayerMapPosition(mapID, "player")
				if position then
					local x, y = position:GetXY()
					if x and y and not (issecretvalue and (issecretvalue(x) or issecretvalue(y))) then px, py = x, y end
				end
				local viewW, viewH = pvWidth / scale, pvHeight / scale -- Preview size in map units
				local ox, oy
				if layerW > viewW then ox = Clamp(viewW / 2 - px * layerW, viewW - layerW, 0) else ox = (viewW - layerW) / 2 end
				if layerH > viewH then oy = Clamp(viewH / 2 - py * layerH, viewH - layerH, 0) else oy = (viewH - layerH) / 2 end
				pvCanvas:ClearAllPoints()
				pvCanvas:SetPoint("TOPLEFT", pv, "TOPLEFT", ox, -oy)

				-- Player arrow position in the preview
				pvArrowX, pvArrowY = (ox + px * layerW) * scale, (oy + py * layerH) * scale
				UpdatePreviewIcons()
			end

			-- Keep the preview map up to date while the panel is showing (only then)
			local pvTicker
			pv:SetScript("OnShow", function()
				UpdatePreviewMap()
				UpdatePreviewOpacity()
				if not pvTicker then pvTicker = C_Timer.NewTicker(0.5, UpdatePreviewMap) end
			end)
			pv:SetScript("OnHide", function()
				if pvTicker then pvTicker:Cancel(); pvTicker = nil end
			end)

			-- Hide battlefield tab button
			hooksecurefunc(BattlefieldMapTab, "Show", function() BattlefieldMapTab:Hide() end)

			-- Fix tab frame strata so it matches the battlefield map frame
			BattlefieldMapTab:SetFrameStrata(BattlefieldMapFrame:GetFrameStrata())

			-- Make battlefield map movable
			BattlefieldMapFrame:SetMovable(true)
			BattlefieldMapFrame:SetUserPlaced(true)
			BattlefieldMapFrame:SetDontSavePosition(true)
			BattlefieldMapFrame:SetClampedToScreen(true)

			-- Set battleifeld map position at startup
			BattlefieldMapFrame:ClearAllPoints()
			BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])

			-- Unlock battlefield map frame
			local eFrame = CreateFrame("Frame", nil, BattlefieldMapFrame.ScrollContainer)
			eFrame:SetPoint("TOPLEFT", 0, 0)
			eFrame:SetPoint("BOTTOMRIGHT", 0, 0)
			eFrame:SetFrameLevel(BattlefieldMapFrame:GetFrameLevel() - 1)
			eFrame:SetHitRectInsets(-15, -15, -15, -15)
			eFrame:SetAlpha(0)
			eFrame:EnableMouse(true)
			eFrame:RegisterForDrag("LeftButton")
			eFrame:SetScript("OnMouseDown", function()
				if LeaMapsLC["UnlockBattlefield"] == "On" then
					BattlefieldMapFrame:StartMoving()
				end
			end)
			eFrame:SetScript("OnMouseUp", function()
				-- Save frame positions
				BattlefieldMapFrame:StopMovingOrSizing()
				LeaMapsLC["BattleMapA"], void, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = BattlefieldMapFrame:GetPoint()
				BattlefieldMapFrame:SetMovable(true)
				BattlefieldMapFrame:ClearAllPoints()
				BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])
			end)

			-- Enable unlock border only when unlock is enabled
			local function SetUnlockBorder()
				if LeaMapsLC["UnlockBattlefield"] == "On" then
					eFrame:Show()
				else
					eFrame:Hide()
				end
			end

			-- Set unlock border when option is clicked and on startup
			LeaMapsCB["UnlockBattlefield"]:HookScript("OnClick", SetUnlockBorder)
			SetUnlockBorder()

			-- Toggle battlefield map frame with configuration panel
			battleFrame:HookScript("OnShow", function()
				if BattlefieldMapFrame:IsShown() then LeaMapsLC.BFMapWasShown = true else LeaMapsLC.BFMapWasShown = false end
				BattlefieldMapFrame:Show()
			end)
			battleFrame:HookScript("OnHide", function()
				if not LeaMapsLC.BFMapWasShown then BattlefieldMapFrame:Hide() end
			end)

			----------------------------------------------------------------------
			-- Map opacity
			----------------------------------------------------------------------

			local function DoMapOpacity()
				LeaMapsCB["BattleMapOpacity"].f:SetFormattedText("%.0f%%", LeaMapsLC["BattleMapOpacity"] * 100)
				BattlefieldMapOptions.opacity = 1 - LeaMapsLC["BattleMapOpacity"]
				BattlefieldMapFrame:RefreshAlpha()
				UpdatePreviewOpacity()
			end

			-- Set opacity when slider is changed and on startup
			LeaMapsCB["BattleMapOpacity"]:HookScript("OnValueChanged", DoMapOpacity)
			DoMapOpacity()

			----------------------------------------------------------------------
			-- Player arrow
			----------------------------------------------------------------------

			-- Function to set player arrow size
			local function SetPlayerArrow()
				LeaMapsCB["BattlePlayerArrowSize"].f:SetText(LeaMapsLC["BattlePlayerArrowSize"] .. " (" .. string.format("%.0f%%", LeaMapsLC["BattlePlayerArrowSize"] / 12 * 100) .. ")")
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("player", LeaMapsLC["BattlePlayerArrowSize"])
				BattlefieldMapFrame.groupMembersDataProvider.pin:SynchronizePinSizes()
				UpdatePreviewIcons()
			end

			-- Set player arrow when option is changed and on startup
			LeaMapsCB["BattlePlayerArrowSize"]:HookScript("OnValueChanged", SetPlayerArrow)
			SetPlayerArrow()

			----------------------------------------------------------------------
			-- Group icons
			----------------------------------------------------------------------

			-- Function to set group icons
			local function FixGroupPin()

				-- Icons should be under the player arrow
				BattlefieldMapFrame.groupMembersDataProvider.pin:SetPinSubLevel("party", 0)
				BattlefieldMapFrame.groupMembersDataProvider.pin:SetPinSubLevel("raid", 0)

				-- Icon size
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("party", LeaMapsLC["BattleGroupIconSize"])
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("raid", LeaMapsLC["BattleGroupIconSize"])
				BattlefieldMapFrame.groupMembersDataProvider.pin:SynchronizePinSizes()

			end

			-- Function to refresh size slider and update battlefield map
			local function SetIconSize()
				LeaMapsCB["BattleGroupIconSize"].f:SetText(LeaMapsLC["BattleGroupIconSize"] .. " (" .. string.format("%.0f%%", LeaMapsLC["BattleGroupIconSize"] / 8 * 100) .. ")")
				FixGroupPin()
				UpdatePreviewIcons()
			end

			-- Set group icons when option is changed and on startup
			LeaMapsCB["BattleGroupIconSize"]:HookScript("OnValueChanged", SetIconSize)
			SetIconSize()

			----------------------------------------------------------------------
			-- Rest of configuration panel
			----------------------------------------------------------------------

			-- Back to Main Menu button click
			battleFrame.b:HookScript("OnClick", function()
				battleFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			battleFrame.r:HookScript("OnClick", function()
				LeaMapsLC["UnlockBattlefield"] = "On"
				LeaMapsLC["BattleGroupIconSize"] = 8
				LeaMapsLC["BattlePlayerArrowSize"] = 12
				LeaMapsLC["BattleMapOpacity"] = 1
				LeaMapsLC["BattleMapA"], LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = "BOTTOMRIGHT", "BOTTOMRIGHT", -47, 83
				BattlefieldMapFrame:ClearAllPoints()
				BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])
				SetIconSize()
				SetPlayerArrow()
				DoMapOpacity()
				SetUnlockBorder()
				battleFrame:Hide(); battleFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["UnlockBattlefield"] = "On"
					LeaMapsLC["BattleGroupIconSize"] = 8
					LeaMapsLC["BattlePlayerArrowSize"] = 12
					LeaMapsLC["BattleMapOpacity"] = 1
					LeaMapsLC["BattleMapA"], LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = "BOTTOMRIGHT", "BOTTOMRIGHT", -47, 83
					BattlefieldMapFrame:ClearAllPoints()
					BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])
					SetIconSize()
					SetPlayerArrow()
					DoMapOpacity()
					SetUnlockBorder()
					if battleFrame:IsShown() then battleFrame:Hide(); battleFrame:Show(); end
				else
					battleFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Hide town and city icons
		----------------------------------------------------------------------

		if LeaMapsLC["HideTownCity"] == "On" then
			hooksecurefunc(BaseMapPoiPinMixin, "OnAcquired", function(self)
				local wmapID = WorldMapFrame.mapID
				if wmapID then
					local minfo = C_Map.GetMapInfo(wmapID)
					if minfo then
						local mType = minfo.mapType
						if mType then
							if mType == 1 or mType == 2 then
								-- Map type is world or continent
								if self.Texture and self.Texture:GetTexture() == 136441 then
									local a, b, c, d, e, f, g, h = self.Texture:GetTexCoord()
									if a == 0.35546875 and b == 0.001953125 and c == 0.35546875 and d == 0.03515625 and e == 0.421875 and f == 0.001953125 and g == 0.421875 and h == 0.03515625 then
										-- Hide home icons
										self:Hide()
									elseif a == 0.28515625 and b == 0.107421875 and c == 0.28515625 and d == 0.140625 and e == 0.3515625 and f == 0.107421875 and g == 0.3515625 and h == 0.140625 then
										-- Hide faction icons
										self:Hide()
										-- Hide city icons
									elseif a == 0.42578125 and b == 0.107421875 and c == 0.42578125 and d == 0.140625 and e == 0.4921875 and f == 0.107421875 and g == 0.4921875 and h == 0.140625 then
										self:Hide()
									end
								end
							end
						end
					end
				end
			end)
		end

		----------------------------------------------------------------------
		-- Show coordinates
		----------------------------------------------------------------------

		-- Find the game's coordinates panel (if it can't be found, such as after a game update, the option does nothing
		-- rather than stopping the rest of the addon from loading)
		local coordsPanel
		for void, frame in ipairs(WorldMapFrame.overlayFrames or {}) do
			if frame.PlayerCoords and frame.CursorCoords then coordsPanel = frame; break end
		end

		if LeaMapsLC["ShowCoords"] == "On" and coordsPanel then

			-- Enable built-in coordinates
			SetCVar("worldMapShowPlayerCoords", "1")
			SetCVar("worldMapShowCursorCoords", "1")

			local coords = coordsPanel
			local canvas = WorldMapFrame:GetCanvasContainer()

			coords.PlayerCoords:SetParent(canvas)
			coords.PlayerCoords:ClearAllPoints()
			coords.PlayerCoords:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", 40, 2)
			coords.PlayerCoords.Label:SetFont(coords.PlayerCoords.Label:GetFont(), 14, "OUTLINE")
			coords.PlayerCoords:SetFrameLevel(10)

			coords.CursorCoords:SetParent(canvas)
			coords.CursorCoords:ClearAllPoints()
			coords.CursorCoords:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -80, 2)
			coords.CursorCoords.Label:SetFont(coords.CursorCoords.Label:GetFont(), 14, "OUTLINE")
			coords.CursorCoords:SetFrameLevel(10)

			if coords.CrosshairCoords then
				coords.CrosshairCoords:SetParent(canvas)
				coords.CrosshairCoords:ClearAllPoints()
				coords.CrosshairCoords:SetPoint("BOTTOM", canvas, "BOTTOM", -32, 2)
				coords.CrosshairCoords.Label:SetFont(coords.CrosshairCoords.Label:GetFont(), 14, "OUTLINE")
				coords.CrosshairCoords:SetFrameLevel(10)
			end

			-- Create background frame
			local cFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
			cFrame:SetSize(WorldMapFrame:GetWidth(), 17)
			cFrame:SetPoint("BOTTOMLEFT", 17)
			cFrame:SetPoint("BOTTOMRIGHT", 0)

			-- Background (on its own frame so the rainbow theme can add to it)
			cFrame.back = CreateFrame("Frame", nil, cFrame)
			cFrame.back:SetAllPoints()
			cFrame.t = cFrame.back:CreateTexture(nil, "BACKGROUND")
			cFrame.t:SetAllPoints()
			cFrame.t:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			cFrame.t:SetVertexColor(0, 0, 0, 0.5)

			-- Simple map frame: the coordinates sit in a footer under the map (so the bar does not cover anything on the
			-- map), the same width as the title bar and colored by the map theme (the footer is placed in SetPixelEdges)
			if ApplyMapTheme then
				cFrame:SetParent(WorldMapFrame)
				cFrame:ClearAllPoints()
				cFrame:SetHeight(20)
				cFrame:SetFrameStrata(mapTheme.titleBar:GetFrameStrata())
				cFrame:SetFrameLevel(mapTheme.titleBar:GetFrameLevel())
				cFrame.t:SetTexture("Interface\\Buttons\\WHITE8X8")
				cFrame.t:SetVertexColor(1, 1, 1, 1)
				mapTheme.footerFrame = cFrame
				mapTheme.footer = cFrame.back
				mapTheme.footerTexture = cFrame.t

				-- Function to move the coordinates into the footer (same places along the map as before, in the footer which
				-- is under the map, or inside the bottom of the map when the map is maximised)
				local function MoveCoords(frame, point, relativePoint, x, y)
					if not frame then return end
					frame:SetParent(cFrame)
					frame:ClearAllPoints()
					frame:SetPoint(point, canvas, relativePoint, x, y)
					frame:SetFrameLevel(cFrame:GetFrameLevel() + 2)
				end
				mapTheme.PlaceCoords = function(inside)
					local y = inside and 16 or -4
					MoveCoords(coords.PlayerCoords, "TOPLEFT", "BOTTOMLEFT", 40, y)
					MoveCoords(coords.CursorCoords, "TOPRIGHT", "BOTTOMRIGHT", -80, y)
					MoveCoords(coords.CrosshairCoords, "TOP", "BOTTOM", -32, y)
				end
				mapTheme.PlaceCoords(false)

				ApplyMapTheme()
				LeaMapsLC.RefreshMapLines()
			end

			-- Disable coordinates if option is turned off
			cFrame:RegisterEvent("PLAYER_LOGOUT")
			cFrame:SetScript("OnEvent", function()
				if LeaMapsLC["ShowCoords"] == "Off" then
					SetCVar("worldMapShowPlayerCoords", "0")
					SetCVar("worldMapShowCursorCoords", "0")
				end
			end)

			-- Create configuration panel
			local cPanel = LeaMapsLC:CreatePanel("Show coordinates", "cPanel")

			-- Add controls
			LeaMapsLC:MakeTx(cPanel, "Settings", 16, -72)
			LeaMapsLC:MakeCB(cPanel, "CoordsBackground", "Show background", 16, -92, false, "If checked, coordinates will have a dark background texture.")

			-- Function to apply settings
			local function SetCoordFunc()
				if LeaMapsLC["CoordsBackground"] == "On" then
					cFrame.back:Show()
				else
					cFrame.back:Hide()
				end
			end

			-- Set coordinates settings when options are clicked and on startup
			LeaMapsCB["CoordsBackground"]:HookScript("OnClick", SetCoordFunc)
			SetCoordFunc()

			-- Back to Main Menu button click
			cPanel.b:HookScript("OnClick", function()
				cPanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			cPanel.r:HookScript("OnClick", function()
				LeaMapsLC["CoordsBackground"] = "On"
				SetCoordFunc()
				cPanel:Hide(); cPanel:Show()
			end)

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["ShowCoordsBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["CoordsBackground"] = "On"
					SetCoordFunc()
					if cPanel:IsShown() then cPanel:Hide(); cPanel:Show(); end
				else
					cPanel:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Unlock map frame
		----------------------------------------------------------------------

		if LeaMapsLC["UnlockMap"] == "On" then

			-- Create configuration panel
			local scaleFrame = LeaMapsLC:CreatePanel("Unlock map frame", "scaleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(scaleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(scaleFrame, "EnableMovement", "Allow frame movement", 16, -92, false, "If checked, you will be able to move the frame by dragging the border.")

			----------------------------------------------------------------------
			-- Allow map frame movement
			----------------------------------------------------------------------

			local SetMapPositionFunc, ClampMapPosition -- Defined below
			local mapMoving

			-- Function to check if the map frame has a position on screen (it can be missing or secret)
			local function MapHasRect()
				local left = WorldMapFrame:GetLeft()
				if issecretvalue and issecretvalue(left) then return false end
				return left ~= nil
			end

			-- Function to check if map frame position values can be saved (they can be missing or secret)
			local function IsValidMapPoint(a, r, x, y)
				if issecretvalue and (issecretvalue(a) or issecretvalue(r) or issecretvalue(x) or issecretvalue(y)) then return false end
				return type(a) == "string" and type(r) == "string" and type(x) == "number" and type(y) == "number"
			end

			-- Function to start moving the map frame (not while the map frame cannot be changed)
			local function StartMapMove()
				if LeaMapsLC["EnableMovement"] ~= "On" or not LeaMapsLC:CanChangeMap() then return end
				WorldMapFrame:StartMoving()
				-- Another addon's frames anchored to the map frame can leave it with no position when moving starts so
				-- stop moving and put the map frame back at its saved position
				if not MapHasRect() then
					WorldMapFrame:StopMovingOrSizing()
					WorldMapFrame:SetUserPlaced(false)
					SetMapPositionFunc()
					return
				end
				mapMoving = true
			end

			-- Function to stop moving the map frame and save its position
			local function StopMapMove()
				if not mapMoving or not LeaMapsLC:CanChangeMap() then return end
				mapMoving = nil
				WorldMapFrame:StopMovingOrSizing()
				WorldMapFrame:SetUserPlaced(false)
				ClampMapPosition()
				-- Save map frame position (if it's not valid, put the map frame back at its saved position)
				local a, void, r, x, y = WorldMapFrame:GetPoint()
				if not IsValidMapPoint(a, r, x, y) then
					SetMapPositionFunc()
					return
				end
				if WorldMapFrame:IsMaximized() then
					LeaMapsLC["MaxMapPosA"], LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"] = a, r, x, y
				else
					LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = a, r, x, y
				end
			end

			-- Enable movement
			WorldMapFrame:SetMovable(true)
			WorldMapFrame:RegisterForDrag("LeftButton")
			WorldMapFrame:HookScript("OnDragStart", StartMapMove)
			WorldMapFrame:HookScript("OnDragStop", StopMapMove)

			-- Stop moving the map frame when combat starts (combat lockdown starts after this event and another addon
			-- may make the map frame protected during it)
			local moveEvents = CreateFrame("Frame")
			moveEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
			moveEvents:SetScript("OnEvent", StopMapMove)

			-- Allow map to be moved by the title bar (needed for simple map frame)
			if LeaMapsCB["MapTitleFrame"] then
				LeaMapsCB["MapTitleFrame"]:EnableMouse(true)
				LeaMapsCB["MapTitleFrame"]:RegisterForDrag("LeftButton")
				LeaMapsCB["MapTitleFrame"]:SetScript("OnDragStart", StartMapMove)
				LeaMapsCB["MapTitleFrame"]:SetScript("OnDragStop", StopMapMove)
			end

			-- The game's clamp to screen is not used. Its single clamp area cannot let the map go far off the top and far
			-- off the bottom at the same time (when it is set up to, the map jumps when it is clicked and gets stuck), so the
			-- map can be dragged freely and is moved back on the screen when it is dropped (see ClampMapPosition).
			WorldMapFrame:SetClampedToScreen(false)

			-- Function to move the map frame back if too much of it is off the screen. The map can go off any side of the
			-- screen until about 100 screen pixels of it are left on the screen (if the map is moved off the top,
			-- the title bar can be off the screen, Reset in the configuration panel brings it back).
			local mapKeepPixels = 100
			ClampMapPosition = function()
				if not LeaMapsLC:CanChangeMap() then return end
				local left, right, top, bottom = WorldMapFrame:GetLeft(), WorldMapFrame:GetRight(), WorldMapFrame:GetTop(), WorldMapFrame:GetBottom()
				local scale, uiScale = WorldMapFrame:GetEffectiveScale(), UIParent:GetEffectiveScale()
				local screenW, screenH = UIParent:GetSize()
				for void, v in ipairs({left, right, top, bottom, scale, uiScale, screenW, screenH}) do
					if issecretvalue and issecretvalue(v) then return end -- Can be secret in combat
				end
				if not left or not top or not scale or scale <= 0 then return end
				-- Screen size in map frame units
				screenW, screenH = screenW * uiScale / scale, screenH * uiScale / scale
				-- Amount to keep on the screen in map frame units (768 units at scale 1 is the screen height)
				local physHeight = GetPhysicalScreenSize and select(2, GetPhysicalScreenSize())
				local keep = 300
				if physHeight and physHeight > 0 then keep = mapKeepPixels * 768 / physHeight / scale end
				local width, height = right - left, top - bottom
				local offX, offY = math.max(0, width - keep), math.max(0, height - keep) -- How far it can go off each side
				local dx, dy = 0, 0
				if left < -offX then dx = -offX - left elseif right > screenW + offX then dx = screenW + offX - right end
				if top > screenH + offY then dy = screenH + offY - top elseif bottom < -offY then dy = -offY - bottom end
				if dx == 0 and dy == 0 then return end
				if WorldMapFrame:GetNumPoints() ~= 1 then return end
				local a, rel, r, x, y = WorldMapFrame:GetPoint()
				if not IsValidMapPoint(a, r, x, y) then return end
				WorldMapFrame:SetPoint(a, rel, r, x + dx, y + dy)
			end

			-- Function to set map position (not while the map frame cannot be changed)
			SetMapPositionFunc = function()
				if not LeaMapsLC:CanChangeMap() then return end
				WorldMapFrame:ClearAllPoints()
				if not WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
				else
					WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
				end
				ClampMapPosition()
			end

			-- Set map position when map size is toggled, map size is changed and on startup
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", SetMapPositionFunc)
			hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", SetMapPositionFunc) -- Needed when maximising the map
			SetMapPositionFunc()

			-- Function to set map movement clickable area (not while the map frame cannot be changed, themes with a casing
			-- set their own clickable area which includes the casing and the grab area)
			local function SetMapHitRect()
				if not LeaMapsLC:CanChangeMap() then return end
				if mapTheme.pads and LeaMapsLC.SetCasingHitRect then LeaMapsLC.SetCasingHitRect() return end
				if LeaMapsLC["EnableMovement"] == "On" then
					WorldMapFrame:SetHitRectInsets(-10, -10, -10, -10)
				else
					if LeaMapsLC["SimpleMapFrame"] == "On" then
						WorldMapFrame:SetHitRectInsets(0, 0, 44, 0)
					else
						WorldMapFrame:SetHitRectInsets(0, 0, 0, 0)
					end
				end
			end

			-- Set map movement clickable area on startup and when setting is changed (themes with a casing use it to put
			-- the normal clickable area back when another theme is chosen)
			LeaMapsLC.RestoreMapHitRect = SetMapHitRect
			SetMapHitRect()
			LeaMapsCB["EnableMovement"]:HookScript("OnClick", SetMapHitRect)

			-- Lock map movement controls while the map frame cannot be changed
			LeaMapsLC:AddMapLock(function(lock)
				LeaMapsLC:LockItem(LeaMapsCB["EnableMovement"], lock)
				LeaMapsLC:LockItem(scaleFrame.r, lock)
			end)

			----------------------------------------------------------------------
			-- Panel button handlers
			----------------------------------------------------------------------

			-- Back to Main Menu button click
			scaleFrame.b:HookScript("OnClick", function()
				scaleFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			scaleFrame.r:HookScript("OnClick", function()
				if not LeaMapsLC:CanChangeMap() then return end
				-- Reset map position
				LeaMapsLC["EnableMovement"] = "On"
				LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = "TOPLEFT", "TOPLEFT", 16, -94
				LeaMapsLC["MaxMapPosA"], LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"] = "CENTER", "CENTER", 0, 0
				WorldMapFrame:ClearAllPoints()
				if WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
				else
					WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
				end
				-- Refresh panel
				scaleFrame:Hide(); scaleFrame:Show()
			end)

			-- Assign file level scope to reset button (needed for Remove map border)
			LeaMapsCB["UnlockMapPanelResetButton"] = scaleFrame.r

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["UnlockMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["EnableMovement"] = "On"
					if scaleFrame:IsShown() then scaleFrame:Hide(); scaleFrame:Show(); end
				else
					scaleFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

			-- Fix for World Quest Tracker to set map window centralised to disabled
			EventUtil.ContinueOnAddOnLoaded("WorldQuestTracker", function()
				if WQTrackerDB and WQTrackerDB.profiles and WQTrackerDB.profiles.Default and WQTrackerDB.profiles.Default.map_frame_anchor and WQTrackerDB.profiles.Default.map_frame_anchor == "center" then
					WQTrackerDB.profiles.Default.map_frame_anchor = "left"
				end
			end)

		end

		----------------------------------------------------------------------
		-- Disable map fade while moving
		----------------------------------------------------------------------

		-- Function to set map fade
		local function SetMapFade()
			if LeaMapsLC["NoMapFade"] == "On" then
				SetCVar("mapFade", "0")
			else
				SetCVar("mapFade", "1")
			end
		end

		-- Set map fade when option is clicked and on startup
		LeaMapsCB["NoMapFade"]:HookScript("OnClick", SetMapFade)
		SetMapFade()

		----------------------------------------------------------------------
		-- Disable map emote when opening the map
		----------------------------------------------------------------------

		-- The map performs the reading emote in its OnShow script so it is cancelled straight after (this only runs when
		-- the map is shown, unlike a hook on C_ChatInfo.PerformEmote which would run for every emote)
		WorldMapFrame:HookScript("OnShow", function()
			if LeaMapsLC["NoMapEmote"] == "On" then
				C_ChatInfo.CancelEmote()
			end
		end)

		----------------------------------------------------------------------
		-- Show additional icons
		----------------------------------------------------------------------

		if LeaMapsLC["ShowIcons"] == "On" then

			-- Get table from file
			local PinData = Leatrix_Maps["Icons"]

			-- Create table
			local LeaMix = CreateFromMixins(MapCanvasDataProviderMixin)

			function LeaMix:RefreshAllData()

				-- Remove all pins created by Leatrix Maps
				self:GetMap():RemoveAllPinsByTemplate("LeaMapsGlobalPinTemplate")

				-- Show new pins if option is enabled
				do

					-- Make new pins
					local pMapID = WorldMapFrame.mapID
					if PinData[pMapID] then
						local count = #PinData[pMapID]
						for i = 1, count do

							-- Do nothing if pinInfo has no entry for zone we are looking at
							local pinInfo = PinData[pMapID][i]
							if not pinInfo then return nil end

							local myPOI = {}

							-- Portal - Horde
							if pinInfo[1] == "PortalH" and playerFaction == "Horde" then
								myPOI["atlasName"] = "TaxiNode_Continent_Horde"
								if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then myPOI["atlasName"] = nil end -- Do nothing if first quest not completed
								if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then myPOI["atlasName"] = nil end -- Do nothing if second quest is completed

							-- Portal - Alliance
							elseif pinInfo[1] == "PortalA" and playerFaction == "Alliance" then
								myPOI["atlasName"] = "TaxiNode_Continent_Alliance"
								if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then myPOI["atlasName"] = nil end -- Do nothing if first quest not completed
								if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then myPOI["atlasName"] = nil end -- Do nothing if second quest is completed

							-- Portal - Neutral
							elseif pinInfo[1] == "PortalN" then
								myPOI["atlasName"] = "TaxiNode_Continent_Neutral"
								if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then myPOI["atlasName"] = nil end -- Do nothing if first quest not completed
								if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then myPOI["atlasName"] = nil end -- Do nothing if second quest is completed

							-- Chest
							elseif pinInfo[1] == "Chest" then
								myPOI["atlasName"] = "ChallengeMode-icon-chest"

							-- Arrow
							elseif pinInfo[1] == "Arrow" then
								myPOI["atlasName"] = "Garr_LevelUpgradeArrow"
								myPOI["journalID"] = pinInfo[7]

							-- Taxi - Neutral (as used in Korthia for Flayedwing Transporter)
							elseif pinInfo[1] == "TaxiN" then
								myPOI["atlasName"] = "warfront-neutralhero-gold"

							end

							-- Mandatory fields
							myPOI["position"] = CreateVector2D(pinInfo[2] / 100, pinInfo[3] / 100)
							myPOI["name"] = pinInfo[4]
							myPOI["description"] = pinInfo[5]

							-- Acquire the pin if it has a texture
							if myPOI["atlasName"] then
								local pin = self:GetMap():AcquirePin("LeaMapsGlobalPinTemplate", myPOI)
								pin.Texture:SetRotation(0)
								pin.HighlightTexture:SetRotation(0)
								if pinInfo[1] == "Arrow" then
									pin.Texture:SetRotation(pinInfo[6])
									pin.HighlightTexture:SetRotation(pinInfo[6])
								elseif pinInfo[1] == "TaxiN" then
									pin:SetSize(28, 28)
									pin.Texture:SetSize(28, 28)
									pin.HighlightTexture:SetSize(28, 28)
								end
							end

						end
					end

				end

			end

			_G.LeaMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")
			_G.LeaMapsGlobalPinMixin.SetPassThroughButtons = function() end

			function LeaMapsGlobalPinMixin:OnAcquired(myInfo)
				BaseMapPoiPinMixin.OnAcquired(self, myInfo)
				self.journalID = myInfo.journalID
			end

			WorldMapFrame:AddDataProvider(LeaMix)

		end

		----------------------------------------------------------------------
		-- Show unexplored areas
		----------------------------------------------------------------------

		if LeaMapsLC["RevealMap"] == "On" then

			-- Dont reveal garrisons for player faction
			if playerFaction == "Alliance" then
				-- Remove Alliance garrison texture
				Leatrix_Maps["Reveal"][556]["223:279:194:0"] = string.gsub(Leatrix_Maps["Reveal"][556]["223:279:194:0"], "1037663", "")
			elseif playerFaction == "Horde" then
				-- Remove Horde garrison texture
				Leatrix_Maps["Reveal"][542]["267:257:336:327"] = string.gsub(Leatrix_Maps["Reveal"][542]["267:257:336:327"], "1003342", "")
			end

			-- Overlays are textures of our own created on the map exploration pins (world map and battlefield map).
			-- Blizzard's texture pools, texture load groups and pin fields are never changed, so the map's own code
			-- never reads anything the addon wrote. Overlays are drawn after Blizzard's RefreshOverlays and hidden
			-- after Blizzard's RemoveAllData (both post-hooks).

			local revealState = setmetatable({}, {__mode = "k"}) -- Per pin state, keyed by pin (never stored on the pin)

			-- Function to get the state for a pin
			local function GetRevealState(pin)
				local state = revealState[pin]
				if not state then
					state = {textures = {}, numActive = 0, tinted = false}
					revealState[pin] = state
				end
				return state
			end

			-- Function to hide all overlays on a pin (textures are kept for reuse)
			local function ReleaseOverlays(pin)
				local state = revealState[pin]
				if not state then return end
				local textures = state.textures
				for i = 1, state.numActive do
					local texture = textures[i]
					texture:Hide()
					texture:ClearAllPoints()
					texture:SetTexture(nil)
				end
				state.numActive = 0
			end

			-- Function to get an overlay texture (created once, reused after that)
			local function AcquireOverlay(pin, state)
				local index = state.numActive + 1
				local texture = state.textures[index]
				if not texture then
					texture = pin:CreateTexture(nil, "ARTWORK", nil, -1)
					state.textures[index] = texture
				end
				state.numActive = index
				return texture
			end

			-- Function to set the tint of a pin's overlays (only zone maps are tinted)
			local function ApplyTint(state)
				local r, g, b, a = 1, 1, 1, 1
				if state.tinted and LeaMapsLC["RevTint"] == "On" then
					r, g, b, a = LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"]
				end
				local textures = state.textures
				for i = 1, state.numActive do
					textures[i]:SetVertexColor(r, g, b, a)
				end
			end

			-- Function to show overlays for unexplored areas (runs after Blizzard_SharedMapDataProviders\MapExplorationDataProvider RefreshOverlays)
			local function RefreshOverlays(pin)

				-- Remove existing overlays
				ReleaseOverlays(pin)

				local map = pin:GetMap(); if not map then return end
				local mapID = map:GetMapID(); if not mapID then return end
				local artID = C_Map.GetMapArtID(mapID); if not artID or not Leatrix_Maps["Reveal"][artID] then return end
				local LeaMapsZone = Leatrix_Maps["Reveal"][artID]

				-- Store already explored tiles in a table so they can be ignored
				local TileExists = {}
				local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
				if exploredMapTextures then
					for i, exploredTextureInfo in ipairs(exploredMapTextures) do
						local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
						TileExists[key] = true
					end
				end

				-- Get the sizes (layer index is kept locally, the pin's own layerIndex is never written)
				local layerIndex = map:GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[layerIndex]
				if not layerInfo then return end
				local TILE_SIZE_WIDTH = layerInfo.tileWidth
				local TILE_SIZE_HEIGHT = layerInfo.tileHeight

				-- Get the map type (needed to make sure only zone maps are tinted)
				local mapInfo = C_Map.GetMapInfo(mapID)
				local state = GetRevealState(pin)
				state.tinted = mapInfo and mapInfo.mapType == 3 or false

				-- Show textures if they are in database and have not been explored
				for key, files in pairs(LeaMapsZone) do
					if not TileExists[key] then
						local width, height, offsetX, offsetY = strsplit(":", key)
						local fileDataIDs = { strsplit(",", files) }
						local numTexturesWide = ceil(width/TILE_SIZE_WIDTH)
						local numTexturesTall = ceil(height/TILE_SIZE_HEIGHT)
						local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
						for j = 1, numTexturesTall do
							if ( j < numTexturesTall ) then
								texturePixelHeight = TILE_SIZE_HEIGHT
								textureFileHeight = TILE_SIZE_HEIGHT
							else
								texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
								if ( texturePixelHeight == 0 ) then
									texturePixelHeight = TILE_SIZE_HEIGHT
								end
								textureFileHeight = 16
								while(textureFileHeight < texturePixelHeight) do
									textureFileHeight = textureFileHeight * 2
								end
							end
							for k = 1, numTexturesWide do
								local texture = AcquireOverlay(pin, state)
								if ( k < numTexturesWide ) then
									texturePixelWidth = TILE_SIZE_WIDTH
									textureFileWidth = TILE_SIZE_WIDTH
								else
									texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
									if ( texturePixelWidth == 0 ) then
										texturePixelWidth = TILE_SIZE_WIDTH
									end
									textureFileWidth = 16
									while(textureFileWidth < texturePixelWidth) do
										textureFileWidth = textureFileWidth * 2
									end
								end
								texture:SetSize(texturePixelWidth, texturePixelHeight)
								texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
								texture:SetPoint("TOPLEFT", pin, "TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
								texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
								texture:SetDrawLayer("ARTWORK", -1)
								texture:Show()
							end
						end
					end
				end

				-- Set tint
				ApplyTint(state)

			end

			-- Function to hook a map exploration pin (post-hooks only)
			local function SetupRevealPin(pin)
				if pin.RemoveAllData then hooksecurefunc(pin, "RemoveAllData", ReleaseOverlays) end
				hooksecurefunc(pin, "RefreshOverlays", RefreshOverlays)
				-- Draw now if the map is already showing (such as the battlefield map)
				local map = pin:GetMap()
				if map and map:IsShown() then RefreshOverlays(pin) end
			end

			-- Hook the world map and battlefield map exploration pins
			for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				SetupRevealPin(pin)
			end
			if BattlefieldMapFrame then
				for pin in BattlefieldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
					SetupRevealPin(pin)
				end
			end

			-- Create tint frame
			local tintFrame = LeaMapsLC:CreatePanel("Show unexplored areas", "tintFrame")

			-- Add controls
			LeaMapsLC:MakeTx(tintFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(tintFrame, "RevTint", "Tint unexplored areas", 16, -92, false, "If checked, unexplored areas will be tinted.")
			LeaMapsLC:MakeSL(tintFrame, "tintRed", "Red", "Drag to set the amount of red.", 0, 1, 0.1, 36, -142, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintGreen", "Green", "Drag to set the amount of green.", 0, 1, 0.1, 36, -202, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintBlue", "Blue", "Drag to set the amount of blue.", 0, 1, 0.1, 206, -142, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintAlpha", "Opacity", "Drag to set the opacity.", 0.1, 1, 0.1, 206, -202, "%.1f")

			-- Add preview color block
			local prvTitle = LeaMapsLC:MakeWD(tintFrame, "Preview", 386, -130); prvTitle:Hide()
			tintFrame.preview = tintFrame:CreateTexture(nil, "ARTWORK")
			tintFrame.preview:SetSize(50, 50)
			tintFrame.preview:SetPoint("TOPLEFT", prvTitle, "TOPLEFT", 0, -20)

			-- Function to set tint color
			local function SetTintCol()
				tintFrame.preview:SetColorTexture(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
				-- Set slider values
				LeaMapsCB["tintRed"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintRed"] * 100)
				LeaMapsCB["tintGreen"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintGreen"] * 100)
				LeaMapsCB["tintBlue"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintBlue"] * 100)
				LeaMapsCB["tintAlpha"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintAlpha"] * 100)
				-- Set tint
				for pin, state in pairs(revealState) do
					ApplyTint(state)
				end
				if LeaMapsLC["RevTint"] == "On" then
					-- Enable controls
					LeaMapsCB["tintRed"]:Enable(); LeaMapsCB["tintRed"]:SetAlpha(1.0)
					LeaMapsCB["tintGreen"]:Enable(); LeaMapsCB["tintGreen"]:SetAlpha(1.0)
					LeaMapsCB["tintBlue"]:Enable(); LeaMapsCB["tintBlue"]:SetAlpha(1.0)
					LeaMapsCB["tintAlpha"]:Enable(); LeaMapsCB["tintAlpha"]:SetAlpha(1.0)
					prvTitle:SetAlpha(1.0); tintFrame.preview:SetAlpha(1.0)
				else
					-- Disable controls
					LeaMapsCB["tintRed"]:Disable(); LeaMapsCB["tintRed"]:SetAlpha(0.3)
					LeaMapsCB["tintGreen"]:Disable(); LeaMapsCB["tintGreen"]:SetAlpha(0.3)
					LeaMapsCB["tintBlue"]:Disable(); LeaMapsCB["tintBlue"]:SetAlpha(0.3)
					LeaMapsCB["tintAlpha"]:Disable(); LeaMapsCB["tintAlpha"]:SetAlpha(0.3)
					prvTitle:SetAlpha(0.3); tintFrame.preview:SetAlpha(0.3)
				end
			end

			-- Set tint properties when controls are changed and on startup
			LeaMapsCB["RevTint"]:HookScript("OnClick", SetTintCol)
			LeaMapsCB["tintRed"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintRed"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintGreen"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintGreen"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintBlue"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintBlue"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintAlpha"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintAlpha"]:HookScript("OnValueChanged", SetTintCol)
			SetTintCol()

			-- Back to Main Menu button click
			tintFrame.b:HookScript("OnClick", function()
				tintFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			tintFrame.r:HookScript("OnClick", function()
				LeaMapsLC["RevTint"] = "On"
				LeaMapsLC["tintRed"] = 0.6
				LeaMapsLC["tintGreen"] = 0.6
				LeaMapsLC["tintBlue"] = 1
				LeaMapsLC["tintAlpha"] = 1
				SetTintCol()
				tintFrame:Hide(); tintFrame:Show()
			end)

			-- Show tint configuration panel when configuration button is clicked
			LeaMapsCB["RevTintBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["RevTint"] = "On"
					LeaMapsLC["tintRed"] = 0.6
					LeaMapsLC["tintGreen"] = 0.6
					LeaMapsLC["tintBlue"] = 1
					LeaMapsLC["tintAlpha"] = 1
					SetTintCol()
					if tintFrame:IsShown() then tintFrame:Hide(); tintFrame:Show(); end
				else
					tintFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Set keybindings (no reload required)
		----------------------------------------------------------------------

		do

			-- Create configuration panel
			local KeyPanel = LeaMapsLC:CreatePanel("Set keybindings", "KeyPanel")

			-- Hidden buttons that the keys click (the keys are bound to them in the addon code so the game keybindings menu is not tainted)
			local function MakeKeyButton(name, func)
				local btn = CreateFrame("Button", name, UIParent)
				btn:Hide()
				btn:RegisterForClicks("AnyDown")
				btn:SetScript("OnClick", func)
			end

			MakeKeyButton("LeaMapsGlobalKeyToggle", function() SlashCmdList["Leatrix_Maps"]("") end)

			-- Keys (var is the saved setting, button is the button the key clicks)
			local actions = {
				{var = "KeyBindToggle", button = "LeaMapsGlobalKeyToggle", label = "Toggle panel", tip = "Open or close the Leatrix Maps options panel."},
			}

			-- Headings and rows
			LeaMapsLC:MakeTx(KeyPanel, "Leatrix Maps", 16, -72)
			local rowPos = {{16, -92}}

			local function KeyName(key)
				return GetBindingText and GetBindingText(key) or key
			end

			local listening -- Index of the row waiting for a key
			local applyPending = false

			-- Apply the keys
			local function ApplyKeys()
				if InCombatLockdown() then
					applyPending = true
					return
				end
				applyPending = false
				ClearOverrideBindings(KeyPanel)
				if LeaMapsLC["SetKeybindings"] == "On" then
					for i = 1, #actions do
						local key = LeaMapsLC[actions[i].var]
						if key ~= "" then
							SetOverrideBindingClick(KeyPanel, false, key, actions[i].button, "LeftButton")
						end
					end
				end
			end

			-- Show the keys
			local function Refresh()
				for i = 1, #actions do
					local btn = actions[i].btn
					if listening == i then
						btn:SetText(L["Press a key"])
					elseif LeaMapsLC[actions[i].var] ~= "" then
						btn:SetText("|cff00ff00" .. KeyName(LeaMapsLC[actions[i].var]) .. "|r")
					else
						btn:SetText("|cff808080" .. L["None"] .. "|r")
					end
				end
			end

			local function StopListening()
				if listening then
					actions[listening].btn:EnableKeyboard(false)
					listening = nil
				end
				Refresh()
			end

			local modifierKeys = {LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true, LALT = true, RALT = true, LMETA = true, RMETA = true}

			-- Create the rows
			for i = 1, #actions do
				local action = actions[i]
				local x, y = rowPos[i][1], rowPos[i][2]

				local label = LeaMapsLC:MakeWD(KeyPanel, action.label, x, y, 130)
				label:SetWordWrap(false)

				local btn = LeaMapsLC:CreateButton("KeyBind" .. i .. "Btn", KeyPanel, "None", "TOPLEFT", x + 136, y + 4, 20, action.tip)
				btn:SetWidth(120)
				btn.tiptext = L[action.tip] .. "|n|n" .. L["Click, then press a key (you can include Shift, Ctrl or Alt).  Press Escape to cancel or right-click to remove the key."]
				btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
				action.btn = btn

				-- Capture the next key pressed
				btn:SetScript("OnKeyDown", function(self, key)
					if listening ~= i then return end
					if modifierKeys[key] then return end
					if key == "ESCAPE" then
						StopListening()
						return
					end
					if InCombatLockdown() then
						StopListening()
						LeaMapsLC:Print("You cannot do that in combat.")
						return
					end
					local combo = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. (IsMetaKeyDown and IsMetaKeyDown() and "META-" or "") .. key
					-- Take the key from any other row that uses it
					for j = 1, #actions do
						if j ~= i and LeaMapsLC[actions[j].var] == combo then
							LeaMapsLC[actions[j].var] = ""
						end
					end
					LeaMapsLC[action.var] = combo
					ApplyKeys()
					StopListening()
				end)

				-- Setting a key script turns keyboard input on by itself, so turn it off until the button is clicked
				btn:EnableKeyboard(false)

				btn:SetScript("OnClick", function(self, mouseButton)
					if InCombatLockdown() then
						StopListening()
						LeaMapsLC:Print("You cannot do that in combat.")
						return
					end
					if mouseButton == "RightButton" then
						-- Remove the key
						StopListening()
						LeaMapsLC[action.var] = ""
						ApplyKeys()
						Refresh()
						return
					end
					if listening == i then
						StopListening()
					else
						StopListening()
						listening = i
						btn:EnableKeyboard(true)
						btn:SetPropagateKeyboardInput(false)
						Refresh()
					end
				end)
			end

			-- Turning the option on or off sets or removes the keys
			LeaMapsCB["SetKeybindings"]:HookScript("OnClick", ApplyKeys)

			KeyPanel:HookScript("OnShow", Refresh)
			KeyPanel:HookScript("OnHide", StopListening)
			KeyPanel:RegisterEvent("PLAYER_REGEN_DISABLED")
			KeyPanel:RegisterEvent("PLAYER_REGEN_ENABLED")
			KeyPanel:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_REGEN_DISABLED" then
					-- Entering combat, stop listening so key presses reach the game
					if listening then StopListening() end
				elseif event == "PLAYER_REGEN_ENABLED" then
					-- Set the keys if they could not be set during combat
					if applyPending then ApplyKeys() end
				end
			end)

			-- Set the keys once startup has finished
			C_Timer.After(0, ApplyKeys)

			-- Back to Main Menu button click
			KeyPanel.b:HookScript("OnClick", function()
				KeyPanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			KeyPanel.r:HookScript("OnClick", function()
				if InCombatLockdown() then
					LeaMapsLC:Print("You cannot do that in combat.")
					return
				end
				StopListening()
				for i = 1, #actions do
					LeaMapsLC[actions[i].var] = ""
				end
				ApplyKeys()
				Refresh()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["SetKeybindingsBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					StopListening()
					LeaMapsLC["KeyBindToggle"] = "CTRL-D"
					ApplyKeys()
					Refresh()
				else
					KeyPanel:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show minimap icon
		----------------------------------------------------------------------

		do

			-- Minimap button click function
			local function MiniBtnClickFunc(arg1)
				-- No modifier key toggles the options panel
				if LeaMapsLC:IsMapsShowing() then
					LeaMapsLC["PageF"]:Hide()
					LeaMapsLC:HideConfigPanels()
				else
					LeaMapsLC["PageF"]:Show()
				end
			end

			-- Assign global scope for function (it's used in TOC)
			_G.LeaMapsGlobalMiniBtnClickFunc = MiniBtnClickFunc

			-- Create minimap button using LibDBIcon
			local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("Leatrix_Maps", {
				type = "data source",
				text = "Leatrix Maps",
				icon = "Interface\\HELPFRAME\\HelpIcon-Bug",
				OnClick = function(self, btn)
					MiniBtnClickFunc(btn)
				end,
				OnTooltipShow = function(tooltip)
					if not tooltip or not tooltip.AddLine then return end
					tooltip:AddLine("Leatrix Maps")
				end,
			})

			local icon = LibStub("LibDBIcon-1.0", true)
			icon:Register("Leatrix_Maps", miniButton, LeaMapsDB)

			-- Function to toggle LibDBIcon
			local function SetLibDBIconFunc()
				if LeaMapsLC["ShowMinimapIcon"] == "On" then
					LeaMapsDB["hide"] = false
					icon:Show("Leatrix_Maps")
				else
					LeaMapsDB["hide"] = true
					icon:Hide("Leatrix_Maps")
				end
			end

			-- Set LibDBIcon when option is clicked and on startup
			LeaMapsCB["ShowMinimapIcon"]:HookScript("OnClick", SetLibDBIconFunc)
			SetLibDBIconFunc()

		end

		----------------------------------------------------------------------
		-- Show memory usage
		----------------------------------------------------------------------

		do

			-- Show memory usage stat
			local function ShowMemoryUsage(frame, anchor, x, y)

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
						UpdateAddOnMemoryUsage()
						memtext = GetAddOnMemoryUsage("Leatrix_Maps")
						memtext = math.floor(memtext + .5) .. " KB"
						memstat:SetText(memtext)
						memtime = 0
					end
					memtime = memtime + elapsed
				end)

			end

			-- ShowMemoryUsage(LeaMapsLC["PageF"], "TOPLEFT", 16, -282)

		end

		----------------------------------------------------------------------
		-- Create panel in game options panel
		----------------------------------------------------------------------

		do

			local interPanel = CreateFrame("FRAME")
			interPanel.name = "Leatrix Maps"

			local maintitle = LeaMapsLC:MakeTx(interPanel, "Leatrix Maps", 0, 0)
			maintitle:SetFont(maintitle:GetFont(), 72)
			maintitle:ClearAllPoints()
			maintitle:SetPoint("TOP", 0, -72)

			local expTitle = LeaMapsLC:MakeTx(interPanel, "Shadowlands", 0, 0)
			expTitle:SetFont(expTitle:GetFont(), 32)
			expTitle:ClearAllPoints()
			expTitle:SetPoint("TOP", 0, -152)

			local subTitle = LeaMapsLC:MakeTx(interPanel, "curseforge.com/wow/addons/leatrix-maps", 0, 0)
			subTitle:SetFont(subTitle:GetFont(), 20)
			subTitle:ClearAllPoints()
			subTitle:SetPoint("BOTTOM", 0, 72)

			local slashTitle = LeaMapsLC:MakeTx(interPanel, "/ltm", 0, 0)
			slashTitle:SetFont(slashTitle:GetFont(), 72)
			slashTitle:ClearAllPoints()
			slashTitle:SetPoint("BOTTOM", subTitle, "TOP", 0, 40)
			slashTitle:SetScript("OnMouseUp", function(self, button)
				if button == "LeftButton" then
					SlashCmdList["Leatrix_Maps"]("")
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
			local category = Settings.RegisterCanvasLayoutCategory(interPanel, "Leatrix Maps")
			Settings.RegisterAddOnCategory(category)

		end

		----------------------------------------------------------------------
		-- Final code
		----------------------------------------------------------------------

		-- Hide the battlefield map tab because it's shown even when enhance battlefield map is disabled
		BattlefieldMapTab:Hide()

		-- Show first run message
		if not LeaMapsDB["FirstRunMessageSeen"] then
			C_Timer.After(1, function()
				LeaMapsLC:Print(L["Enter"] .. " |cff00ff00" .. "/ltm" .. "|r " .. L["or click the minimap button to open Leatrix Maps."])
				LeaMapsDB["FirstRunMessageSeen"] = true
			end)
		end

		-- Release memory
		LeaMapsLC.MainFunc = nil

	end

	----------------------------------------------------------------------
	-- L10: Functions
	----------------------------------------------------------------------

	-- Function to add textures to panels
	function LeaMapsLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
		local ft = parent:CreateTexture(nil, "BORDER")
		ft:SetTexture(tex)
		ft:SetSize(width, height)
		ft:SetPoint(anchor)
		ft:SetVertexColor(r ,g, b, alp)
		if name == "MainTexture" then
			ft:SetTexCoord(0.09, 1, 0, 1)
		end
	end

	-- Create a configuration panel
	function LeaMapsLC:CreatePanel(title, globref)

		-- Create the panel
		local Side = CreateFrame("Frame", LeaMapsLC:CreateRandomName(), UIParent)

		-- Make it a system frame
		table.insert(UISpecialFrames, Side:GetName())

		-- Store it in the configuration panel table
		tinsert(LeaConfigList, Side)

		-- Set frame parameters
		Side:Hide()
		Side:SetSize(470, 400)
		Side:SetClampedToScreen(true)
		Side:SetFrameStrata("FULLSCREEN_DIALOG")
		Side:SetFrameLevel(20)

		-- Set the background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add a close Button (LeaMapsLC: Custom template)
		Side.c = LeaMapsLC:CreateCloseButton(Side, 30, 30, "TOPRIGHT", 0, 0)
		Side.c:SetScript("OnClick", function() Side:Hide() end)

		-- Add reset, help and back buttons
		Side.r = LeaMapsLC:CreateButton("ResetButton", Side, "Reset", "BOTTOMLEFT", 16, 60, 25, "Click to reset the settings on this page.")
		Side.b = LeaMapsLC:CreateButton("BackButton", Side, "Back to Main Menu", "BOTTOMRIGHT", -16, 60, 25, "Click to return to the main menu.")

		-- Add a reload button and synchronise it with the main panel reload button
		local reloadb = LeaMapsLC:CreateButton("ConfigReload", Side, "Reload", "BOTTOMRIGHT", -16, 10, 25, LeaMapsCB["ReloadUIButton"].tiptext)
		LeaMapsLC:LockItem(reloadb, true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32)
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(LeaMapsCB["ReloadUIButton"].f:GetText())
		reloadb.f:Hide()

		LeaMapsCB["ReloadUIButton"]:HookScript("OnEnable", function()
			LeaMapsLC:LockItem(reloadb, false)
			reloadb.f:Show()
		end)

		LeaMapsCB["ReloadUIButton"]:HookScript("OnDisable", function()
			LeaMapsLC:LockItem(reloadb, true)
			reloadb.f:Hide()
		end)

		-- Add reset map layout button (once, it's on the main panel)
		if not LeaMapsCB["ResetMapLayoutButton"] then
			local resetMapBtn = LeaMapsLC:CreateButton("ResetMapLayoutButton", LeaMapsLC["PageF"], "Reset map layout", "BOTTOMLEFT", 16, 10, 25, "Click to reset the map position and scale to the game default.")
			resetMapBtn:SetScript("OnClick", function()
				-- Do nothing if the map frame cannot be changed (the button is locked then)
				if not LeaMapsLC:CanChangeMap() then return end
				-- Reset saved map position and scale
				LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = "TOPLEFT", "TOPLEFT", 16, -94
				LeaMapsLC["MaxMapPosA"], LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"] = "CENTER", "CENTER", 0, 0
				LeaMapsLC["MapScale"] = 1.0
				LeaMapsLC["MaxMapScale"] = 1.0
				-- Apply them now
				WorldMapFrame:SetScale(1)
				if LeaMapsLC["UnlockMap"] == "On" then
					WorldMapFrame:ClearAllPoints()
					if WorldMapFrame:IsMaximized() then
						WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
					else
						WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
					end
				end
			end)
			-- Lock the button while the map frame cannot be changed
			LeaMapsLC:AddMapLock(function(lock)
				LeaMapsLC:LockItem(resetMapBtn, lock)
			end)
		end

		-- Set textures
		LeaMapsLC:CreateBar("FootTexture", Side, 470, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaMapsLC:CreateBar("MainTexture", Side, 470, 383, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Allow movement
		Side:EnableMouse(true)
		Side:SetMovable(true)
		Side:RegisterForDrag("LeftButton")
		Side:SetScript("OnDragStart", Side.StartMoving)
		Side:SetScript("OnDragStop", function ()
			Side:StopMovingOrSizing()
			Side:SetUserPlaced(false)
			-- Save panel position
			LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = Side:GetPoint()
		end)

		-- Set panel attributes when shown
		Side:SetScript("OnShow", function()
			Side:ClearAllPoints()
			Side:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
		end)

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 16, -16)
		Side.f:SetText(L[title])

		-- Add description
		Side.v = Side:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Side.v:SetHeight(32)
		Side.v:SetPoint('TOPLEFT', Side.f, 'BOTTOMLEFT', 0, -8)
		Side.v:SetPoint('RIGHT', Side, -32, 0)
		Side.v:SetJustifyH('LEFT'); Side.v:SetJustifyV('TOP')
		Side.v:SetText(L["Configuration Panel"])

		-- Prevent options panel from showing while side panel is showing
		LeaMapsLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaMapsLC["PageF"]:Hide(); end
		end)

		-- Return the frame
		return Side

	end

	-- Hide configuration panels
	function LeaMapsLC:HideConfigPanels()
		for k, v in pairs(LeaConfigList) do
			v:Hide()
		end
	end

	-- Create a close button without using a template
	function LeaMapsLC:CreateCloseButton(parent, w, h, anchor, x, y)
		local btn = CreateFrame("BUTTON", nil, parent)
		btn:SetSize(w, h)
		btn:SetPoint(anchor, x, y)
		btn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
		btn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		btn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
		btn:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
		return btn
	end

	-- Find out if Leatrix Maps is showing (main panel or config panel)
	function LeaMapsLC:IsMapsShowing()
		if LeaMapsLC["PageF"]:IsShown() then return true end
		for k, v in pairs(LeaConfigList) do
			if v:IsShown() then
				return true
			end
		end
	end

	-- Load a string variable or set it to default if it's not set to "On" or "Off"
	function LeaMapsLC:LoadVarChk(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "On" or LeaMapsDB[var] == "Off" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load a numeric variable and set it to default if it's not within a given range
	function LeaMapsLC:LoadVarNum(var, def, valmin, valmax)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "number" and LeaMapsDB[var] >= valmin and LeaMapsDB[var] <= valmax then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load an anchor point variable and set it to default if the anchor point is invalid
	function LeaMapsLC:LoadVarAnc(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "CENTER" or LeaMapsDB[var] == "TOP" or LeaMapsDB[var] == "BOTTOM" or LeaMapsDB[var] == "LEFT" or LeaMapsDB[var] == "RIGHT" or LeaMapsDB[var] == "TOPLEFT" or LeaMapsDB[var] == "TOPRIGHT" or LeaMapsDB[var] == "BOTTOMLEFT" or LeaMapsDB[var] == "BOTTOMRIGHT" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Show tooltips for checkboxes
	function LeaMapsLC:TipSee()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = self:GetParent()
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
	function LeaMapsLC:ShowTooltip()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = LeaMapsLC["PageF"]
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (LeaMapsLC["PageF"]:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Print text
	function LeaMapsLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
	end

	-- Check if player is in combat
	function LeaMapsLC:PlayerInCombat()
		if UnitAffectingCombat("player") then
			LeaMapsLC:Print("You cannot do that in combat.")
			return true
		end
	end

	-- Lock and unlock an item
	function LeaMapsLC:LockItem(item, lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

	----------------------------------------------------------------------
	-- Map frame protection
	----------------------------------------------------------------------

	-- Another addon can make the map frame protected (such as by giving it a secure child frame) and protected frames
	-- cannot be moved or scaled during combat. Actions that move or scale the map frame are not done while it cannot be
	-- changed and the controls for them are locked until it can be changed again.

	local mapLockFuncs = {}

	-- Function to check if the map frame can be moved or scaled
	function LeaMapsLC:CanChangeMap()
		return not InCombatLockdown() or not WorldMapFrame:IsProtected()
	end

	-- Function to lock or unlock controls that move or scale the map frame
	local function SetMapLocks(lock)
		for i = 1, #mapLockFuncs do
			mapLockFuncs[i](lock)
		end
	end

	-- Function to add a function that locks or unlocks controls (it's run now and when combat starts or ends)
	function LeaMapsLC:AddMapLock(func)
		tinsert(mapLockFuncs, func)
		func(not LeaMapsLC:CanChangeMap())
	end

	-- Set control locks when combat starts and ends
	local mapLockEvents = CreateFrame("Frame")
	mapLockEvents:RegisterEvent("PLAYER_REGEN_DISABLED")
	mapLockEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
	mapLockEvents:SetScript("OnEvent", function(self, event)
		if #mapLockFuncs == 0 then return end
		if event == "PLAYER_REGEN_DISABLED" then
			-- Combat lockdown starts after this event so lock now if the map frame is protected and check again on the
			-- next frame (another addon may make the map frame protected during this event)
			if WorldMapFrame:IsProtected() then SetMapLocks(true) end
			C_Timer.After(0, function() SetMapLocks(not LeaMapsLC:CanChangeMap()) end)
		else
			SetMapLocks(not LeaMapsLC:CanChangeMap())
		end
	end)

	-- Function to set lock state for configuration buttons
	function LeaMapsLC:LockOption(option, item, reloadreq)
		if reloadreq then
			-- Option requires UI reload
			if LeaMapsLC[option] ~= LeaMapsDB[option] or LeaMapsLC[option] == "Off" then
				LeaMapsLC:LockItem(LeaMapsCB[item], true)
			else
				LeaMapsLC:LockItem(LeaMapsCB[item], false)
			end

		else
			-- Option does not require UI reload
			if LeaMapsLC[option] == "Off" then
				LeaMapsLC:LockItem(LeaMapsCB[item], true)
			else
				LeaMapsLC:LockItem(LeaMapsCB[item], false)
			end
		end
	end

	-- Set lock state for configuration buttons
	function LeaMapsLC:SetDim()
		LeaMapsLC:LockOption("SimpleMapFrame", "SimpleMapFrameBtn", true)		-- Use simple map frame
		LeaMapsLC:LockOption("ScaleWorldMap", "ScaleWorldMapBtn", true) 		-- Scale the map
		LeaMapsLC:LockOption("RevealMap", "RevTintBtn", true)					-- Shiw unexplored areas
		LeaMapsLC:LockOption("UnlockMap", "UnlockMapBtn", true)					-- Unlock map frame
		LeaMapsLC:LockOption("ShowCoords", "ShowCoordsBtn", true)				-- Show coordinates
		LeaMapsLC:LockOption("EnhanceBattleMap", "EnhanceBattleMapBtn", true) 	-- Enhance battlefield map
		LeaMapsLC:LockOption("SetKeybindings", "SetKeybindingsBtn", false) -- Set keybindings
	end

	-- Create a standard button
	function LeaMapsLC:CreateButton(name, frame, label, anchor, x, y, height, tip, naked)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaMapsCB[name] = mbtn
		mbtn:SetHeight(height)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetHitRectInsets(0, 0, 0, 0)
		mbtn:SetText(L[label])

		-- Create fontstring and set button width based on it
		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetText(L[label])
		mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)

		-- Tooltip handler
		mbtn.tiptext = L[tip]
		mbtn:SetScript("OnEnter", LeaMapsLC.TipSee)
		mbtn:SetScript("OnLeave", GameTooltip_Hide)

		-- Set skinned button textures
		if not naked then
			mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
			mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 0.25)
		end
		mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 0.25)

		-- Hide the default textures
		mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		return mbtn
	end

	-- Set reload button status
	function LeaMapsLC:ReloadCheck()
		if	(LeaMapsLC["SimpleMapFrame"] ~= LeaMapsDB["SimpleMapFrame"])			-- Simple map frame
		or	(LeaMapsLC["UnlockMap"] ~= LeaMapsDB["UnlockMap"])						-- Unlock map
		or	(LeaMapsLC["ScaleWorldMap"] ~= LeaMapsDB["ScaleWorldMap"])				-- Scale the map
		or	(LeaMapsLC["HideBlackoutFrame"] ~= LeaMapsDB["HideBlackoutFrame"])		-- Hide blackout frame
		or	(LeaMapsLC["AddonLanguage"] ~= LeaMapsDB["AddonLanguage"])					-- Addon language
		or	(LeaMapsLC["RevealMap"] ~= LeaMapsDB["RevealMap"])						-- Show unexplored areas
		or	(LeaMapsLC["ShowCoords"] ~= LeaMapsDB["ShowCoords"])					-- Show coordinates
		or	(LeaMapsLC["ShowIcons"] ~= LeaMapsDB["ShowIcons"])						-- Show additional icons
		or	(LeaMapsLC["HideTownCity"] ~= LeaMapsDB["HideTownCity"])				-- Hide town and city icons
		or	(LeaMapsLC["EnhanceBattleMap"] ~= LeaMapsDB["EnhanceBattleMap"])		-- Enhance battlefield map
		or	(LeaMapsLC["NoFilterResetBtn"] ~= LeaMapsDB["NoFilterResetBtn"])		-- Hide filte reset button
		then
			-- Enable the reload button
			LeaMapsLC:LockItem(LeaMapsCB["ReloadUIButton"], false)
			LeaMapsCB["ReloadUIButton"].f:Show()
		else
			-- Disable the reload button
			LeaMapsLC:LockItem(LeaMapsCB["ReloadUIButton"], true)
			LeaMapsCB["ReloadUIButton"].f:Hide()
		end
	end

	-- Create a subheading
	function LeaMapsLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		return text
	end

	-- Create text
	function LeaMapsLC:MakeWD(frame, title, x, y, width)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetJustifyH("LEFT")
		text:SetText(L[title])
		if width then text:SetWidth(width) end
		return text
	end

	-- Create a checkbox control
	function LeaMapsLC:MakeCB(parent, field, caption, x, y, reload, tip)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaMapsCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)
		Cbox:SetScript("OnEnter", LeaMapsLC.TipSee)
		Cbox:SetScript("OnLeave", GameTooltip_Hide)

		-- Add label and tooltip
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 24, 0)
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
		if parent == LeaMapsLC["PageF"] then
			-- Main panel checkbox labels
			if Cbox.f:GetWidth() > 172 then
				Cbox.f:SetWidth(172)
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 172 then
				Cbox:SetHitRectInsets(0, -162, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		else
			-- Configuration panel checkbox labels (other checkboxes either have custom functions or blank labels)
			if Cbox.f:GetWidth() > 322 then
				Cbox.f:SetWidth(322)
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 322 then
				Cbox:SetHitRectInsets(0, -312, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		end

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			if LeaMapsLC[field] == "On" then
				self:SetChecked(true)
			else
				self:SetChecked(false)
			end
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() then
				LeaMapsLC[field] = "On"
			else
				LeaMapsLC[field] = "Off"
			end
			LeaMapsLC:SetDim() -- Lock invalid options
			LeaMapsLC:ReloadCheck()
		end)
	end

	-- Create configuration button
	function LeaMapsLC:CfgBtn(name, parent)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaMapsCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50)
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50)

		CfgBtn.tiptext = L["Click to configure the settings for this option."]
		CfgBtn:SetScript("OnEnter", LeaMapsLC.ShowTooltip)
		CfgBtn:SetScript("OnLeave", GameTooltip_Hide)
	end

	-- Create a slider control
	function LeaMapsLC:MakeSL(frame, field, label, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", nil, frame, "LeaMapsConfigurationPanelSliderTemplate") -- Old is UISliderTemplate
		LeaMapsCB[field] = Slider
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0)
		Slider.tiptext = L[caption]
		Slider:SetScript("OnEnter", LeaMapsLC.TipSee)
		Slider:SetScript("OnLeave", GameTooltip_Hide)

		-- Set label
		Slider.label = Slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		Slider.label:SetPoint("TOP", Slider, "TOP", 0, 12)
		Slider.label:SetText(L[label])

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
			LeaMapsLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaMapsLC[field])
		end)

	end

	----------------------------------------------------------------------
	-- L20: Commands
	----------------------------------------------------------------------

	-- Slash command function
	local function SlashFunc(str)
		local str, arg1, arg2, arg3 = strsplit(" ", string.lower(str:gsub("%s+", " ")))
		if str and str ~= "" then
			-- Traverse parameters
			if str == "reset" then
				-- Reset the configuration panel position
				LeaMapsLC["MainPanelA"], LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				if LeaMapsLC["PageF"]:IsShown() then LeaMapsLC["PageF"]:Hide() LeaMapsLC["PageF"]:Show() end
				return
			elseif str == "wipe" then
				-- Keep Set keybindings (enabled status and key) unless wipe all is used
				local keepOn, keepToggle
				if arg1 ~= "all" then
					keepOn, keepToggle = LeaMapsLC["SetKeybindings"], LeaMapsLC["KeyBindToggle"]
				end
				-- Wipe all settings
				SetCVar("mapFade", "1")
				wipe(LeaMapsDB)
				-- Keep the gem game (best score and the game in progress, with its score and level) unless wipe all is used
				if arg1 ~= "all" then
					LeaMapsDB["GemBest"] = LeaMapsLC["GemBest"]
					LeaMapsDB["GemGame"] = LeaMapsLC.GemSaveText and LeaMapsLC.GemSaveText() or LeaMapsLC["GemGame"]
				end
				-- Put back Set keybindings
				if keepOn then
					LeaMapsDB["SetKeybindings"] = keepOn
					LeaMapsDB["KeyBindToggle"] = keepToggle
				end
				LeaMapsLC["NoSaveSettings"] = true
				ReloadUI()
			elseif str == "nosave" then
				-- Prevent Leatrix Maps from overwriting LeaMapsDB at next logout
				LeaMapsLC.EventFrame:UnregisterEvent("PLAYER_LOGOUT")
				LeaMapsLC:Print("Leatrix Maps will not overwrite LeaMapsDB at next logout.")
				return
			elseif str == "debug" then
				-- Toggle debug mode
				if LeaMapsLC["DebugMode"] then
					LeaMapsLC["DebugMode"] = nil
					if GetCVar("showDungeonEntrancesOnMap") ~= "0" then
						SetCVar("showDungeonEntrancesOnMap", "0")
					end
					LeaMapsLC:Print(L["Debug"] .. "|cffffffff " .. L["disabled"] .. "|r.")
				else
					LeaMapsLC["DebugMode"] = true
					LeaMapsLC:Print(L["Debug"] .. "|cffffffff " .. L["enabled"] .. "|r.")
				end
				return
			elseif str == "setmap" then
				-- Set map to map ID
				arg1 = tonumber(arg1)
				if arg1 and arg1 > 0 and arg1 < 99999 and C_Map.GetMapArtLayers(arg1) then
					WorldMapFrame:SetMapID(arg1)
				else
					LeaMapsLC:Print("Invalid map ID.")
				end
				return
			elseif str == "hadmin" then
				-- Show admin commands
				LeaMapsLC:Print("reset - Reset panel position")
				LeaMapsLC:Print("wipe - Wipe addon settings except Set keybindings")
				LeaMapsLC:Print("wipe all - Wipe all addon settings")
				LeaMapsLC:Print("debug - Lets you enable dungeon icons in world map settings")
				LeaMapsLC:Print("setmap <id> - Show map ID <id>")
				LeaMapsLC:Print("admin - Load admin profile")
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
							LeaMapsLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (map)")
						end
					else
						-- Show character map ID
						local mapID = C_Map.GetBestMapForUnit("player") or nil
						local artID = C_Map.GetMapArtID(mapID) or nil
						local mapName = C_Map.GetMapInfo(mapID).name or nil
						if mapID and artID and mapName then
							LeaMapsLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (player)")
						end
					end
					return
				elseif not tonumber(arg1) or not C_Map.GetMapInfo(arg1) then
					-- Invalid map ID
					LeaMapsLC:Print("Invalid map ID.")
				else
					-- Set map by ID
					WorldMapFrame:SetMapID(tonumber(arg1))
				end
				return
			elseif str == "admin" then
				-- Preset profile (reload required)
				LeaMapsLC["NoSaveSettings"] = true
				wipe(LeaMapsDB)
				-- Keep the gem game (best score and the game in progress, with its score and level)
				LeaMapsDB["GemBest"] = LeaMapsLC["GemBest"]
				LeaMapsDB["GemGame"] = LeaMapsLC.GemSaveText and LeaMapsLC.GemSaveText() or LeaMapsLC["GemGame"]

				-- Mechanics
				LeaMapsDB["SimpleMapFrame"] = "On"
				LeaMapsDB["UnlockMap"] = "On"
				LeaMapsDB["EnableMovement"] = "On"
				LeaMapsDB["ScaleWorldMap"] = "Off"
				LeaMapsDB["MapScale"] = 1.0
				LeaMapsDB["MaxMapScale"] = 0.9
				LeaMapsDB["HideBlackoutFrame"] = "On"
				LeaMapsDB["ShowZoneMenu"] = "On"
				LeaMapsDB["MapTheme"] = 1
				LeaMapsDB["AddonLanguage"] = 1
				LeaMapsDB["NoMapFade"] = "On"
				LeaMapsDB["NoMapEmote"] = "On"
				LeaMapsDB["NoFilterResetBtn"] = "On"

				LeaMapsDB["MapPosA"] = "TOPLEFT"
				LeaMapsDB["MapPosR"] = "TOPLEFT"
				LeaMapsDB["MapPosX"] = 16
				LeaMapsDB["MapPosY"] = -94
				LeaMapsDB["MaxMapPosA"] = "CENTER"
				LeaMapsDB["MaxMapPosR"] = "CENTER"
				LeaMapsDB["MaxMapPosX"] = 0
				LeaMapsDB["MaxMapPosY"] = 0

				-- Elements
				LeaMapsDB["RevealMap"] = "On"
				LeaMapsDB["RevTint"] = "On"
				LeaMapsDB["tintRed"] = 0.6
				LeaMapsDB["tintGreen"] = 0.6
				LeaMapsDB["tintBlue"] = 1.0
				LeaMapsDB["tintAlpha"] = 1.0
				LeaMapsDB["ShowIcons"] = "On"
				LeaMapsDB["ShowCoords"] = "On"
				LeaMapsDB["CoordsBackground"] = "On"
				LeaMapsDB["HideTownCity"] = "On"

				-- More
				LeaMapsDB["EnhanceBattleMap"] = "On"
				LeaMapsDB["UnlockBattlefield"] = "On"
				LeaMapsDB["BattleGroupIconSize"] = 8
				LeaMapsDB["BattlePlayerArrowSize"] = 12
				LeaMapsDB["BattleMapOpacity"] = 1
				LeaMapsDB["BattleMapA"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapR"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapX"] = -47
				LeaMapsDB["BattleMapY"] = 83

				LeaMapsDB["ShowMinimapIcon"] = "On"
				LeaMapsDB["SetKeybindings"] = "On"
				LeaMapsDB["KeyBindToggle"] = "CTRL-D"
				LeaMapsDB["minimapPos"] = 204 -- LeaMapsDB

				ReloadUI()
			elseif str == "help" then
				-- Show available commands
				LeaMapsLC:Print("Leatrix Maps" .. "|n")
				LeaMapsLC:Print(L["Version"] .. " " .. LeaMapsLC["AddonVer"] .. "|n|n")
				LeaMapsLC:Print("/ltm reset - Reset the panel position.")
				LeaMapsLC:Print("/ltm wipe - Wipe all settings except Set keybindings and reload.")
				LeaMapsLC:Print("/ltm wipe all - Wipe all settings including Set keybindings and reload.")
				LeaMapsLC:Print("/ltm help - Show this information.")
				return
			else
				-- Invalid command entered
				LeaMapsLC:Print("Invalid command.  Enter /ltm help for help.")
				return
			end
		else
			-- Prevent options panel from showing if Blizzard Store is showing
			if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
			-- Toggle the options panel if game options panel is not showing
			if LeaMapsLC:IsMapsShowing() then
				LeaMapsLC["PageF"]:Hide()
				LeaMapsLC:HideConfigPanels()
			else
				LeaMapsLC["PageF"]:Show()
			end
		end
	end

	-- Add slash commands
	_G.SLASH_Leatrix_Maps1 = "/ltm"
	_G.SLASH_Leatrix_Maps2 = "/leamaps"

	SlashCmdList["Leatrix_Maps"] = function(self)
		-- Run slash command function
		SlashFunc(self)
	end

	----------------------------------------------------------------------
	-- L30: Events
	----------------------------------------------------------------------

	-- Create event frame
	local eFrame = CreateFrame("FRAME")
	LeaMapsLC.EventFrame = eFrame -- Used with nosave command
	eFrame:RegisterEvent("ADDON_LOADED")
	eFrame:RegisterEvent("PLAYER_LOGIN")
	eFrame:RegisterEvent("PLAYER_LOGOUT")
	eFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	eFrame:RegisterEvent("ADDON_ACTION_BLOCKED")
	eFrame:SetScript("OnEvent", function(self, event, arg1, arg2)

		if event == "ADDON_LOADED" and arg1 == "Leatrix_Maps" then
			-- Load settings or set defaults
			LeaMapsLC:LoadVarChk("SimpleMapFrame", "On")				-- Simple map frame
			LeaMapsLC:LoadVarChk("UnlockMap", "Off")					-- Unlock map frame
			LeaMapsLC:LoadVarChk("EnableMovement", "On")				-- Enable frame movement
			LeaMapsLC:LoadVarChk("ScaleWorldMap", "Off")				-- Scale the map
			LeaMapsLC:LoadVarNum("MapScale", 1.0, 0.5, 2)				-- Map scale
			LeaMapsLC:LoadVarNum("MaxMapScale", 1.0, 0.5, 2)			-- Maximised map scale
			LeaMapsLC:LoadVarChk("HideBlackoutFrame", "On")				-- Hide blackout frame
			LeaMapsLC:LoadVarChk("ShowZoneMenu", "On")					-- Show zone menus
			LeaMapsLC:LoadVarNum("MapTheme", 1, 1, 15)					-- Map theme
			LeaMapsLC:LoadVarNum("GemBest", 0, 0, 999999999)			-- Handheld theme gem game best score
			LeaMapsLC["GemGame"] = type(LeaMapsDB["GemGame"]) == "string" and LeaMapsDB["GemGame"] or ""	-- Handheld theme gem game in progress
			LeaMapsLC:LoadVarNum("AddonLanguage", 1, 1, 12)				-- Addon language
			LeaMapsLC:LoadVarChk("NoMapFade", "On")						-- Disable map fade
			LeaMapsLC:LoadVarChk("NoMapEmote", "On")					-- Disable map emote
			LeaMapsLC:LoadVarChk("NoFilterResetBtn", "On")				-- Hide filter reset button

			LeaMapsLC:LoadVarAnc("MapPosA", "TOPLEFT")					-- Windowed map anchor
			LeaMapsLC:LoadVarAnc("MapPosR", "TOPLEFT")					-- Windowed map relative
			LeaMapsLC:LoadVarNum("MapPosX", 16, -5000, 5000)			-- Windowed map X
			LeaMapsLC:LoadVarNum("MapPosY", -94, -5000, 5000)			-- Windowed map Y
			LeaMapsLC:LoadVarAnc("MaxMapPosA", "CENTER")				-- Maximised map anchor
			LeaMapsLC:LoadVarAnc("MaxMapPosR", "CENTER")				-- Maximised map relative
			LeaMapsLC:LoadVarNum("MaxMapPosX", 0, -5000, 5000)			-- Maximised map X
			LeaMapsLC:LoadVarNum("MaxMapPosY", 0, -5000, 5000)			-- Maximised map Y

			-- Elements
			LeaMapsLC:LoadVarChk("RevealMap", "On")						-- Show unexplored areas
			LeaMapsLC:LoadVarChk("RevTint", "On")						-- Tint revealed unexplored areas
			LeaMapsLC:LoadVarNum("tintRed", 0.6, 0, 1)					-- Tint red
			LeaMapsLC:LoadVarNum("tintGreen", 0.6, 0, 1)				-- Tint green
			LeaMapsLC:LoadVarNum("tintBlue", 1, 0, 1)					-- Tint blue
			LeaMapsLC:LoadVarNum("tintAlpha", 1, 0, 1)					-- Tint transparency
			LeaMapsLC:LoadVarChk("ShowIcons", "On")						-- Show additional icons
			LeaMapsLC:LoadVarChk("ShowCoords", "On")					-- Show coordinates
			LeaMapsLC:LoadVarChk("CoordsBackground", "On")				-- Coordinates background
			LeaMapsLC:LoadVarChk("HideTownCity", "On")					-- Hide town and city icons

			-- More
			LeaMapsLC:LoadVarChk("EnhanceBattleMap", "Off")				-- Enhance battlefield map
			LeaMapsLC:LoadVarChk("UnlockBattlefield", "On")				-- Unlock battlefield map
			LeaMapsLC:LoadVarNum("BattleGroupIconSize", 8, 8, 32)		-- Battlefield group icon size
			LeaMapsLC:LoadVarNum("BattlePlayerArrowSize", 12, 12, 48)	-- Battlefield player arrow size
			LeaMapsLC:LoadVarNum("BattleMapOpacity", 1, 0.1, 1)			-- Battlefield map opacity
			LeaMapsLC:LoadVarAnc("BattleMapA", "BOTTOMRIGHT")			-- Battlefield map anchor
			LeaMapsLC:LoadVarAnc("BattleMapR", "BOTTOMRIGHT")			-- Battlefield map relative
			LeaMapsLC:LoadVarNum("BattleMapX", -47, -5000, 5000)		-- Battlefield map X axis
			LeaMapsLC:LoadVarNum("BattleMapY", 83, -5000, 5000)			-- Battlefield map Y axis

			LeaMapsLC:LoadVarChk("ShowMinimapIcon", "On")				-- Show minimap button
			LeaMapsLC:LoadVarChk("SetKeybindings", "Off")				-- Set keybindings
			if type(LeaMapsDB["KeyBindToggle"]) == "string" then		-- Set keybindings toggle panel
				LeaMapsLC["KeyBindToggle"] = LeaMapsDB["KeyBindToggle"]
			else
				LeaMapsLC["KeyBindToggle"] = ""
				LeaMapsDB["KeyBindToggle"] = ""
			end

			-- Panel
			LeaMapsLC:LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
			LeaMapsLC:LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
			LeaMapsLC:LoadVarNum("MainPanelX", 0, -5000, 5000)			-- Panel X axis
			LeaMapsLC:LoadVarNum("MainPanelY", 0, -5000, 5000)			-- Panel Y axis

			LeaMapsLC:SetDim()

			-- Set initial minimum button position
			if not LeaMapsDB["minimapPos"] then
				LeaMapsDB["minimapPos"] = 204
			end

			-- Lock conflicting options
			do

				-- Function to disable and lock an option and add a note to the tooltip
				local function Lock(option, reason, optmodule)
					LeaLockList[option] = LeaMapsLC[option]
					LeaMapsLC:LockItem(LeaMapsCB[option], true)
					LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. "|n|n|cff00AAFF" .. L[reason]
					if optmodule then
						LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. " " .. L[optmodule] .. " " .. L["module"]
					end
					LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. "."
					-- Remove hover from configuration button if there is one
					local temp = {LeaMapsCB[option]:GetChildren()}
					if temp and temp[1] and temp[1].t and temp[1].t:GetTexture() == "Interface\\WorldMap\\Gear_64.png" then
						temp[1]:SetHighlightTexture(0)
						temp[1]:SetScript("OnEnter", nil)
					end
				end

				-- Disable items that conflict with ElvUI
				if LeaMapsLC.ElvUI then
					local E, S = LeaMapsLC.ElvUI
					local reason = L["Cannot be used with ElvUI"]
					if E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap then
						Lock("SimpleMapFrame", reason, "Skins: World Map") -- Use simple map frame
					end
					C_AddOns.EnableAddOn("Leatrix_Maps")
				end
			end

		elseif event == "PLAYER_LOGIN" then
			-- Run main function
			LeaMapsLC:MainFunc()

		elseif event == "PLAYER_LOGOUT" and not LeaMapsLC["NoSaveSettings"] then
			-- Mechanics
			LeaMapsDB["SimpleMapFrame"] = LeaMapsLC["SimpleMapFrame"]
			LeaMapsDB["UnlockMap"] = LeaMapsLC["UnlockMap"]
			LeaMapsDB["EnableMovement"] = LeaMapsLC["EnableMovement"]
			LeaMapsDB["ScaleWorldMap"] = LeaMapsLC["ScaleWorldMap"]
			LeaMapsDB["MapScale"] = LeaMapsLC["MapScale"]
			LeaMapsDB["MaxMapScale"] = LeaMapsLC["MaxMapScale"]
			LeaMapsDB["HideBlackoutFrame"] = LeaMapsLC["HideBlackoutFrame"]
			LeaMapsDB["ShowZoneMenu"] = LeaMapsLC["ShowZoneMenu"]
			LeaMapsDB["AddonLanguage"] = LeaMapsLC["AddonLanguage"]
			LeaMapsDB["MapTheme"] = LeaMapsLC["MapTheme"]
			LeaMapsDB["GemBest"] = LeaMapsLC["GemBest"]
			LeaMapsDB["GemGame"] = LeaMapsLC.GemSaveText and LeaMapsLC.GemSaveText() or LeaMapsLC["GemGame"] or ""
			LeaMapsDB["NoMapFade"] = LeaMapsLC["NoMapFade"]
			LeaMapsDB["NoMapEmote"] = LeaMapsLC["NoMapEmote"]
			LeaMapsDB["NoFilterResetBtn"] = LeaMapsLC["NoFilterResetBtn"]

			LeaMapsDB["MapPosA"] = LeaMapsLC["MapPosA"]
			LeaMapsDB["MapPosR"] = LeaMapsLC["MapPosR"]
			LeaMapsDB["MapPosX"] = LeaMapsLC["MapPosX"]
			LeaMapsDB["MapPosY"] = LeaMapsLC["MapPosY"]
			LeaMapsDB["MaxMapPosA"] = LeaMapsLC["MaxMapPosA"]
			LeaMapsDB["MaxMapPosR"] = LeaMapsLC["MaxMapPosR"]
			LeaMapsDB["MaxMapPosX"] = LeaMapsLC["MaxMapPosX"]
			LeaMapsDB["MaxMapPosY"] = LeaMapsLC["MaxMapPosY"]

			-- Elements
			LeaMapsDB["RevealMap"] = LeaMapsLC["RevealMap"]
			LeaMapsDB["RevTint"] = LeaMapsLC["RevTint"]
			LeaMapsDB["tintRed"] = LeaMapsLC["tintRed"]
			LeaMapsDB["tintGreen"] = LeaMapsLC["tintGreen"]
			LeaMapsDB["tintBlue"] = LeaMapsLC["tintBlue"]
			LeaMapsDB["tintAlpha"] = LeaMapsLC["tintAlpha"]
			LeaMapsDB["ShowIcons"] = LeaMapsLC["ShowIcons"]
			LeaMapsDB["ShowCoords"] = LeaMapsLC["ShowCoords"]
			LeaMapsDB["CoordsBackground"] = LeaMapsLC["CoordsBackground"]
			LeaMapsDB["HideTownCity"] = LeaMapsLC["HideTownCity"]

			-- More
			LeaMapsDB["EnhanceBattleMap"] = LeaMapsLC["EnhanceBattleMap"]
			LeaMapsDB["UnlockBattlefield"] = LeaMapsLC["UnlockBattlefield"]
			LeaMapsDB["BattleGroupIconSize"] = LeaMapsLC["BattleGroupIconSize"]
			LeaMapsDB["BattlePlayerArrowSize"] = LeaMapsLC["BattlePlayerArrowSize"]
			LeaMapsDB["BattleMapOpacity"] = LeaMapsLC["BattleMapOpacity"]
			LeaMapsDB["BattleMapA"] = LeaMapsLC["BattleMapA"]
			LeaMapsDB["BattleMapR"] = LeaMapsLC["BattleMapR"]
			LeaMapsDB["BattleMapX"] = LeaMapsLC["BattleMapX"]
			LeaMapsDB["BattleMapY"] = LeaMapsLC["BattleMapY"]

			LeaMapsDB["ShowMinimapIcon"] = LeaMapsLC["ShowMinimapIcon"]
			LeaMapsDB["SetKeybindings"] = LeaMapsLC["SetKeybindings"]
			LeaMapsDB["KeyBindToggle"] = LeaMapsLC["KeyBindToggle"]

			-- Panel
			LeaMapsDB["MainPanelA"] = LeaMapsLC["MainPanelA"]
			LeaMapsDB["MainPanelR"] = LeaMapsLC["MainPanelR"]
			LeaMapsDB["MainPanelX"] = LeaMapsLC["MainPanelX"]
			LeaMapsDB["MainPanelY"] = LeaMapsLC["MainPanelY"]

		end
	end)

	----------------------------------------------------------------------
	-- L40: Panel
	----------------------------------------------------------------------

	-- Create the panel
	local PageF = CreateFrame("Frame", LeaMapsLC:CreateRandomName(), UIParent)

	-- Make it a system frame
	table.insert(UISpecialFrames, PageF:GetName())

	-- Set frame parameters
	LeaMapsLC["PageF"] = PageF
	PageF:SetSize(470, 400)
	PageF:Hide()
	PageF:SetFrameStrata("FULLSCREEN_DIALOG")
	PageF:SetFrameLevel(20)
	PageF:SetClampedToScreen(true)
	PageF:EnableMouse(true)
	PageF:SetMovable(true)
	PageF:RegisterForDrag("LeftButton")
	PageF:SetScript("OnDragStart", PageF.StartMoving)
	PageF:SetScript("OnDragStop", function()
		PageF:StopMovingOrSizing()
		PageF:SetUserPlaced(false)
		-- Save panel position
		LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = PageF:GetPoint()
	end)

	-- Add background color
	PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
	PageF.t:SetAllPoints()
	PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	local MainTexture = PageF:CreateTexture(nil, "BORDER")
	MainTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	MainTexture:SetSize(470, 383)
	MainTexture:SetPoint("TOPRIGHT")
	MainTexture:SetVertexColor(0.7, 0.7, 0.7, 0.7)
	MainTexture:SetTexCoord(0.09, 1, 0, 1)

	local FootTexture = PageF:CreateTexture(nil, "BORDER")
	FootTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	FootTexture:SetSize(470, 48)
	FootTexture:SetPoint("BOTTOM")
	FootTexture:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	-- Set panel position when shown
	PageF:SetScript("OnShow", function()
		PageF:ClearAllPoints()
		PageF:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
	end)

	-- Add main title
	PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	PageF.mt:SetPoint('TOPLEFT', 16, -16)
	PageF.mt:SetText("Leatrix Maps")

	-- Add version text
	PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	PageF.v:SetHeight(32)
	PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8)
	PageF.v:SetPoint('RIGHT', PageF, -32, 0)
	PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP')
	PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Version"] .. " " .. LeaMapsLC["AddonVer"])

	-- Add reload UI Button
	local reloadb = LeaMapsLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMRIGHT", -16, 10, 25, "Your UI needs to be reloaded for some of the changes to take effect.|n|nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect.")
	LeaMapsLC:LockItem(reloadb, true)
	reloadb:SetScript("OnClick", ReloadUI)

	reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	reloadb.f:SetHeight(32)
	reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
	reloadb.f:SetText(L["Your UI needs to be reloaded."])
	reloadb.f:Hide()

	-- Add close Button (LeaMapsLC: Custom template)
	local CloseB = LeaMapsLC:CreateCloseButton(PageF, 30, 30, "TOPRIGHT", 0, 0)
	CloseB:SetScript("OnClick", function() PageF:Hide() end)

	-- Add content
	LeaMapsLC:MakeTx(PageF, "System", 16, -72)
	LeaMapsLC:MakeCB(PageF, "SimpleMapFrame", "Use simple map frame", 16, -92, true, "If checked, the map will use a simple frame with a compact title bar.")
	LeaMapsLC:MakeCB(PageF, "UnlockMap", "Unlock map frame", 16, -112, true, "If checked, you will be able to move the map.|n|nThe map position will be saved separately for the maximised and windowed maps.")
	LeaMapsLC:MakeCB(PageF, "ScaleWorldMap", "Scale the map", 16, -132, true, "If checked, you will be able to scale the map.")
	LeaMapsLC:MakeCB(PageF, "HideBlackoutFrame", "Hide blackout frame", 16, -152, true, "If checked, the blackout frame will be hidden.")

	LeaMapsLC:CreateDropdown("AddonLanguage", "Language", 146, "TOPLEFT", PageF, "TOPLEFT", 16, -212, true, {{L["Automatic"], 1}, {L["English"], 2}, {L["Deutsch"], 3}, {L["Español (EU)"], 4}, {L["Español (AL)"], 5}, {L["Français"], 6}, {L["Italiano"], 7}, {L["Português"], 8}, {L["Русский"], 9}, {L["한국어"], 10}, {L["简体中文"], 11}, {L["繁體中文"], 12}})

	LeaMapsLC:MakeTx(PageF, "Elements", 225, -72)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Show unexplored areas", 225, -92, true, "If checked, unexplored areas of the map will be shown on the world map and the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 225, -112, true, "If checked, coordinates will be shown.")
	LeaMapsLC:MakeCB(PageF, "ShowIcons", "Show additional icons", 225, -132, true, "If checked, additional icons (such as portals) will be shown.")
	LeaMapsLC:MakeCB(PageF, "HideTownCity", "Hide town and city icons", 225, -152, true, "If checked, town and city icons will not be shown on the continent maps.")

	LeaMapsLC:MakeTx(PageF, "More", 225, -192)
	LeaMapsLC:MakeCB(PageF, "EnhanceBattleMap", "Enhance battlefield map", 225, -212, true, "If checked, you will be able to customise the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "NoMapFade", "Disable map fade", 225, -232, false, "If checked, the map will not fade while your character is moving.")
	LeaMapsLC:MakeCB(PageF, "NoMapEmote", "Disable reading emote", 225, -252, false, "If checked, your character will not perform the reading emote when you open the map.")
	LeaMapsLC:MakeCB(PageF, "NoFilterResetBtn", "Hide filter reset button", 225, -272, true, "If checked, the world map filter reset button will be hidden.")
	LeaMapsLC:MakeCB(PageF, "ShowMinimapIcon", "Show minimap button", 225, -292, false, "If checked, the minimap button will be shown.")
	LeaMapsLC:MakeCB(PageF, "SetKeybindings", "Set keybindings", 225, -312, false, "If checked, you can set a key to toggle the Leatrix Maps options panel.")

	LeaMapsLC:CfgBtn("SimpleMapFrameBtn", LeaMapsCB["SimpleMapFrame"])
	LeaMapsLC:CfgBtn("ScaleWorldMapBtn", LeaMapsCB["ScaleWorldMap"])
	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
	LeaMapsLC:CfgBtn("UnlockMapBtn", LeaMapsCB["UnlockMap"])
	LeaMapsLC:CfgBtn("ShowCoordsBtn", LeaMapsCB["ShowCoords"])
	LeaMapsLC:CfgBtn("EnhanceBattleMapBtn", LeaMapsCB["EnhanceBattleMap"])
	LeaMapsLC:CfgBtn("SetKeybindingsBtn", LeaMapsCB["SetKeybindings"])
