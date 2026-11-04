
	----------------------------------------------------------------------
	-- 	Leatrix Maps 12.1.16 (3rd November 2026)
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
	LeaMapsLC["AddonVer"] = "12.1.16"

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

	-- Set bindings translations
	_G.BINDING_NAME_LEATRIX_MAPS_GLOBAL_TOGGLE = L["Toggle panel"]

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
		function popup:SetColors(bgR, bgG, bgB, borderR, borderG, borderB, hlR, hlG, hlB, rowFunc)
			list:SetBackdropColor(bgR, bgG, bgB, 0.97)
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
						searchBg:SetColorTexture(color[1], color[2], color[3], 1)
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
					footer:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer, "BOTTOMLEFT", 0, 0)
					footer:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", 0, 0)
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
				for i = 1, #edgeTextures do
					local out = (i == 5 and 1 or 6 - i) * px -- Edge 1 pixel out, shadow 2 to 5 pixels out
					local tex = edgeTextures[i]
					tex:ClearAllPoints()
					tex:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", -out, out)
					tex:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", out, -out)
				end
			end

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
					bgBottom = CreateColor(theme.bgBottom[1], theme.bgBottom[2], theme.bgBottom[3], 1)
					bgTop = CreateColor(theme.bgTop[1], theme.bgTop[2], theme.bgTop[3], 1)
				end
				local topR, topG, topB = bgTop:GetRGB()
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
					entry.box:SetVertexColor(ar, ag, ab, 0.6)
					entry.color = {ar * boost, ag * boost, ab * boost}
					if not entry.box:IsShown() then entry.icon:SetVertexColor(unpack(entry.color)) end
				end
				-- Quest search box (title bar color, a little lighter while typing)
				mapTheme.searchNormal = {topR + 0.04, topG + 0.04, topB + 0.04}
				mapTheme.searchFocused = {topR + 0.10, topG + 0.10, topB + 0.10}
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
					mapTheme.popup:SetColors(topR, topG, topB, ar, ag, ab, hr + (1 - hr) * 0.3, hg + (1 - hg) * 0.3, hb + (1 - hb) * 0.3, theme.rainbow and RainbowRowColor or nil)
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
			LeaMapsLC:CreateDropdown("MapTheme", "Map Theme", 146, "TOPLEFT", simplePanel, "TOPLEFT", 16, -152, false, {{L["Classic"], 1}, {L["Warm"], 2}, {L["Charcoal"], 3}, {L["Class Color"], 4}, {L["Alliance"], 6}, {L["Horde"], 7}, {L["Green"], 10}, {L["Teal"], 9}, {L["Purple"], 8}, {L["Pink"], 5}, {L["Rainbow"], 11}})
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
			LeaMapsLC:MakeCB(battleFrame, "BattleCenterOnPlayer", "Center map on player", 16, -112, false, "If checked, the battlefield map will stay centered on your location as long as you are not in a dungeon.|n|nYou can hold shift while panning the map to temporarily prevent it from centering.")

			LeaMapsLC:MakeSL(battleFrame, "BattleGroupIconSize", "Group Icons", "Drag to set the group icon size.", 8, 32, 1, 206, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattlePlayerArrowSize", "Player Arrow", "Drag to set the player arrow size.", 12, 48, 1, 36, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapOpacity", "Map Opacity", "Drag to set the battlefield map opacity.", 0.1, 1, 0.1, 36, -232, "%.0f")

			-- Add preview texture
			local prevIcon = battleFrame:CreateTexture(nil, "ARTWORK")
			prevIcon:SetPoint("CENTER", battleFrame, "TOPLEFT", 400, -182)
			prevIcon:SetTexture("Interface\\MINIMAP\\partyraidblipsv2")
			prevIcon:SetTexCoord(0.015625, 0.3125, 0.03125, 0.59375)
			prevIcon:SetSize(19, 18)
			prevIcon:SetVertexColor(0.78, 0.61, 0.43, 1)

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
			-- Center map on player
			----------------------------------------------------------------------

			do

				local cTime = -1

				-- Function to update map
				local function cUpdate(self, elapsed)
					if cTime > 2 or cTime == -1 then
						if BattlefieldMapFrame.ScrollContainer:IsPanning() then return end
						if IsShiftKeyDown() then cTime = -2000 return end
						local position = C_Map.GetPlayerMapPosition(BattlefieldMapFrame.mapID, "player")
						if position then
							local x, y = position.x, position.y
							if x then
								local minX, maxX, minY, maxY = BattlefieldMapFrame.ScrollContainer:CalculateScrollExtentsAtScale(BattlefieldMapFrame.ScrollContainer:GetCanvasScale())
								local cx = Clamp(x, minX, maxX)
								local cy = Clamp(y, minY, maxY)
								BattlefieldMapFrame.ScrollContainer:SetPanTarget(cx, cy)
							end
							cTime = 0
						end
					end
					cTime = cTime + elapsed
				end

				-- Create frame for update
				local cFrame = CreateFrame("FRAME", nil, BattlefieldMapFrame)

				-- Function to set update state
				local function SetUpdateFunc()
					cTime = -1
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						cFrame:SetScript("OnUpdate", cUpdate)
					else
						cFrame:SetScript("OnUpdate", nil)
					end
				end

				-- Set update state when option is clicked and on startup
				LeaMapsCB["BattleCenterOnPlayer"]:HookScript("OnClick", SetUpdateFunc)
				SetUpdateFunc()

				-- Hook reset button click
				battleFrame.r:HookScript("OnClick", function()
					LeaMapsLC["BattleCenterOnPlayer"] = "Off"
					SetUpdateFunc()
					battleFrame:Hide(); battleFrame:Show()
				end)

				-- Hook configuration panel for preset profile
				LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaMapsLC["BattleCenterOnPlayer"] = "On"
						SetUpdateFunc()
						if battleFrame:IsShown() then battleFrame:Hide(); battleFrame:Show(); end
					end
				end)

				-- Update location immediately or after a very short delay
				local function SetCenterNow()
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						if IsShiftKeyDown() then cTime = -2000 else	cTime = -1 end
					end
				end
				local function SetCenterSoon()
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						if IsShiftKeyDown() then cTime = -2000 else	cTime = 1.7 end
					end
				end

				BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseUp", SetCenterSoon)
				BattlefieldMapFrame:HookScript("OnShow", SetCenterNow)
				BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseWheel", SetCenterSoon)

			end

			----------------------------------------------------------------------
			-- Map opacity
			----------------------------------------------------------------------

			local function DoMapOpacity()
				LeaMapsCB["BattleMapOpacity"].f:SetFormattedText("%.0f%%", LeaMapsLC["BattleMapOpacity"] * 100)
				BattlefieldMapOptions.opacity = 1 - LeaMapsLC["BattleMapOpacity"]
				BattlefieldMapFrame:RefreshAlpha()
			end

			-- Set opacity when slider is changed and on startup
			LeaMapsCB["BattleMapOpacity"]:HookScript("OnValueChanged", DoMapOpacity)
			DoMapOpacity()

			----------------------------------------------------------------------
			-- Player arrow
			----------------------------------------------------------------------

			-- Function to set player arrow size
			local function SetPlayerArrow()
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("player", LeaMapsLC["BattlePlayerArrowSize"])
				BattlefieldMapFrame.groupMembersDataProvider.pin:SynchronizePinSizes()
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
				prevIcon:SetSize(LeaMapsLC["BattleGroupIconSize"], LeaMapsLC["BattleGroupIconSize"])
			end

			-- Set group icons when option is changed and on startup
			LeaMapsCB["BattleGroupIconSize"]:HookScript("OnValueChanged", SetIconSize)
			FixGroupPin()

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

			local SetMapPositionFunc -- Defined below
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

			WorldMapFrame:SetClampedToScreen(true)

			-- Function to set map position (not while the map frame cannot be changed)
			SetMapPositionFunc = function()
				if not LeaMapsLC:CanChangeMap() then return end
				WorldMapFrame:ClearAllPoints()
				if not WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetClampRectInsets(600, -600, -64, 470)
					WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
				else
					WorldMapFrame:SetClampRectInsets(900, -900, -64, 700)
					WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
				end
			end

			-- Set map position when map size is toggled, map size is changed and on startup
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", SetMapPositionFunc)
			hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", SetMapPositionFunc) -- Needed when maximising the map
			SetMapPositionFunc()

			-- Function to set map movement clickable area (not while the map frame cannot be changed)
			local function SetMapHitRect()
				if not LeaMapsLC:CanChangeMap() then return end
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

			-- Set map movement clickable area on startup and when setting is changed
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

			-- Create table to store revealed overlays
			local overlayTextures = {}
			local bfoverlayTextures = {}

			-- Texture pools for revealed overlays (one per exploration pin and owned by Leatrix Maps so Blizzard code never
			-- reads them, the pin is only the parent so the textures move and hide with the map)
			local revealPools = {}
			local function ResetRevealTexture(pool, texture)
				texture:SetVertexColor(1, 1, 1, 1)
				texture:Hide()
				texture:ClearAllPoints()
			end
			local function GetRevealPool(pin)
				local pool = revealPools[pin]
				if not pool then
					pool = CreateTexturePool(pin, "ARTWORK", -1, nil, ResetRevealTexture)
					revealPools[pin] = pool
				end
				return pool
			end

			-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
			local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)

				-- Remove existing textures
				local pool = GetRevealPool(pin)
				pool:ReleaseAll()

				overlayTextures = {}
				local mapID = WorldMapFrame.mapID; if not mapID then return end
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

				-- Get the sizes
				local layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[layerIndex]
				if not layerInfo then return end
				local TILE_SIZE_WIDTH = layerInfo.tileWidth
				local TILE_SIZE_HEIGHT = layerInfo.tileHeight

				-- Get the map type (needed to make sure only zone maps are tinted)
				local mapType = C_Map.GetMapInfo(mapID).mapType
				if not mapType then mapType = 0 end

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
								local texture = pool:Acquire()
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
								texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
								texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
								texture:SetDrawLayer("ARTWORK", -1)
								texture:Show()
								if LeaMapsLC["RevTint"] == "On" and mapType == 3 then
									texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
								end
								tinsert(overlayTextures, texture)
							end
						end
					end
				end
			end

			-- Show overlays on startup
			for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
			end

			-- Repeat refresh overlays function for Battlefield map
			local function bfMapExplorationPin_RefreshOverlays(pin, fullUpdate)

				-- Remove existing textures
				local pool = GetRevealPool(pin)
				pool:ReleaseAll()

				bfoverlayTextures = {}
				local mapID = BattlefieldMapFrame.mapID; if not mapID then return end
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

				-- Get the sizes
				local layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[layerIndex]
				if not layerInfo then return end
				local TILE_SIZE_WIDTH = layerInfo.tileWidth
				local TILE_SIZE_HEIGHT = layerInfo.tileHeight

				-- Get the map type (needed to make sure only zone maps are tinted)
				local mapType = C_Map.GetMapInfo(mapID).mapType
				if not mapType then mapType = 0 end

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
								local texture = pool:Acquire()
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
								texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
								texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
								texture:SetDrawLayer("ARTWORK", -1)
								texture:Show()
								if LeaMapsLC["RevTint"] == "On" and mapType == 3 then
									texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
								end
								tinsert(bfoverlayTextures, texture)
							end
						end
					end
				end
			end

			for pin in BattlefieldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				hooksecurefunc(pin, "RefreshOverlays", bfMapExplorationPin_RefreshOverlays)
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
				if LeaMapsLC["RevTint"] == "On" then
					-- Enable tint
					for i = 1, #overlayTextures  do
						overlayTextures[i]:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
					end
					for i = 1, #bfoverlayTextures do
						bfoverlayTextures[i]:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
					end
					-- Enable controls
					LeaMapsCB["tintRed"]:Enable(); LeaMapsCB["tintRed"]:SetAlpha(1.0)
					LeaMapsCB["tintGreen"]:Enable(); LeaMapsCB["tintGreen"]:SetAlpha(1.0)
					LeaMapsCB["tintBlue"]:Enable(); LeaMapsCB["tintBlue"]:SetAlpha(1.0)
					LeaMapsCB["tintAlpha"]:Enable(); LeaMapsCB["tintAlpha"]:SetAlpha(1.0)
					prvTitle:SetAlpha(1.0); tintFrame.preview:SetAlpha(1.0)
				else
					-- Disable tint
					for i = 1, #overlayTextures  do
						overlayTextures[i]:SetVertexColor(1, 1, 1)
						overlayTextures[i]:SetAlpha(1.0)
					end
					for i = 1, #bfoverlayTextures  do
						bfoverlayTextures[i]:SetVertexColor(1, 1, 1)
						bfoverlayTextures[i]:SetAlpha(1.0)
					end
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
--[[
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
--]]
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
				-- Wipe all settings
				SetCVar("mapFade", "1")
				wipe(LeaMapsDB)
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
				LeaMapsLC:Print("wipe - Wipe addon settings")
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
				LeaMapsDB["BattleCenterOnPlayer"] = "On"
				LeaMapsDB["BattleGroupIconSize"] = 8
				LeaMapsDB["BattlePlayerArrowSize"] = 12
				LeaMapsDB["BattleMapOpacity"] = 1
				LeaMapsDB["BattleMapA"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapR"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapX"] = -47
				LeaMapsDB["BattleMapY"] = 83

				LeaMapsDB["ShowMinimapIcon"] = "On"
				LeaMapsDB["minimapPos"] = 204 -- LeaMapsDB

				ReloadUI()
			elseif str == "help" then
				-- Show available commands
				LeaMapsLC:Print("Leatrix Maps" .. "|n")
				LeaMapsLC:Print(L["Version"] .. " " .. LeaMapsLC["AddonVer"] .. "|n|n")
				LeaMapsLC:Print("/ltm reset - Reset the panel position.")
				LeaMapsLC:Print("/ltm wipe - Wipe all settings and reload.")
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
			LeaMapsLC:LoadVarChk("UnlockMap", "On")					-- Unlock map frame
			LeaMapsLC:LoadVarChk("EnableMovement", "On")				-- Enable frame movement
			LeaMapsLC:LoadVarChk("ScaleWorldMap", "Off")				-- Scale the map
			LeaMapsLC:LoadVarNum("MapScale", 1.2, 0.5, 2)				-- Map scale
			LeaMapsLC:LoadVarNum("MaxMapScale", 1.0, 0.5, 2)			-- Maximised map scale
			LeaMapsLC:LoadVarChk("HideBlackoutFrame", "On")				-- Hide blackout frame
			LeaMapsLC:LoadVarChk("ShowZoneMenu", "On")					-- Show zone menus
			LeaMapsLC:LoadVarNum("MapTheme", 1, 1, 11)					-- Map theme
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
			LeaMapsLC:LoadVarChk("BattleCenterOnPlayer", "Off")			-- Center map on player
			LeaMapsLC:LoadVarNum("BattleGroupIconSize", 8, 8, 32)		-- Battlefield group icon size
			LeaMapsLC:LoadVarNum("BattlePlayerArrowSize", 12, 12, 48)	-- Battlefield player arrow size
			LeaMapsLC:LoadVarNum("BattleMapOpacity", 1, 0.1, 1)			-- Battlefield map opacity
			LeaMapsLC:LoadVarAnc("BattleMapA", "BOTTOMRIGHT")			-- Battlefield map anchor
			LeaMapsLC:LoadVarAnc("BattleMapR", "BOTTOMRIGHT")			-- Battlefield map relative
			LeaMapsLC:LoadVarNum("BattleMapX", -47, -5000, 5000)		-- Battlefield map X axis
			LeaMapsLC:LoadVarNum("BattleMapY", 83, -5000, 5000)			-- Battlefield map Y axis

			LeaMapsLC:LoadVarChk("ShowMinimapIcon", "Off") -- 保留自訂預設

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
			LeaMapsDB["BattleCenterOnPlayer"] = LeaMapsLC["BattleCenterOnPlayer"]
			LeaMapsDB["BattleGroupIconSize"] = LeaMapsLC["BattleGroupIconSize"]
			LeaMapsDB["BattlePlayerArrowSize"] = LeaMapsLC["BattlePlayerArrowSize"]
			LeaMapsDB["BattleMapOpacity"] = LeaMapsLC["BattleMapOpacity"]
			LeaMapsDB["BattleMapA"] = LeaMapsLC["BattleMapA"]
			LeaMapsDB["BattleMapR"] = LeaMapsLC["BattleMapR"]
			LeaMapsDB["BattleMapX"] = LeaMapsLC["BattleMapX"]
			LeaMapsDB["BattleMapY"] = LeaMapsLC["BattleMapY"]

			LeaMapsDB["ShowMinimapIcon"] = LeaMapsLC["ShowMinimapIcon"]

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

	LeaMapsLC:CfgBtn("SimpleMapFrameBtn", LeaMapsCB["SimpleMapFrame"])
	LeaMapsLC:CfgBtn("ScaleWorldMapBtn", LeaMapsCB["ScaleWorldMap"])
	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
	LeaMapsLC:CfgBtn("UnlockMapBtn", LeaMapsCB["UnlockMap"])
	LeaMapsLC:CfgBtn("ShowCoordsBtn", LeaMapsCB["ShowCoords"])
	LeaMapsLC:CfgBtn("EnhanceBattleMapBtn", LeaMapsCB["EnhanceBattleMap"])
