﻿
	----------------------------------------------------------------------
	-- 	Leatrix Maps 11.2.06 (3rd September 2025)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaConfigList = {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "11.2.06"

	-- Get locale table
	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	-- Check Wow version is valid
	do
		local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
		if gametocversion and gametocversion < 110000 then
			-- Game client is Wow Classic
			C_Timer.After(2, function()
				print(L["LEATRIX MAPS: THIS IS FOR THE WAR WITHIN ONLY!"])
			end)
			return
		end
		if gametocversion and gametocversion >= 110100 then -- 11.1.0
			LeaMapsLC.NewPatch = true
		end
	end

	-- Check for addons
	if C_AddOns.IsAddOnLoaded("ElvUI") then LeaMapsLC.ElvUI = unpack(ElvUI) end

	-- Set bindings translations
	_G.BINDING_NAME_LEATRIX_MAPS_GLOBAL_TOGGLE = L["Toggle panel"]

	----------------------------------------------------------------------
	-- L00: Leatrix Maps
	----------------------------------------------------------------------

	-- Main function
	function LeaMapsLC:MainFunc()

		-- Base taint: No longer an issue and zoom settings are removed now anyway
		-- Have a keystone in your bag, open the world map, navigate to a zone with a world boss quest
		-- (such as Zereth Mortis), shift-click on the world boss icon 4 times to toggle quest tracking off
		-- and on twice, click the objective tracker icon for the world quest to open group finder.  The 3 zoom
		-- settings cause base taint due to setting global values (remember zoom, increase zoom and center map
		-- on player).

		-- Group finder dungeon title taint: No longer an issue
		-- Follow base taint then click back, click dungeons and click start group.  This taint happens because
		-- the dungeon title is protected.  This is mitigated by preventing Wow from setting the dungeon title
		-- but only if the user has 2FA enabled.  Without 2FA, users cannot set the dungeon title so Wow has to
		-- do it for them which means the taint fix cannot be applied.
		-- Appears fixed as setting the dungeon title no longer causes taint.

		-- Report player taint: Still an issue
		-- Follow base taint and group finder taint then use report player.

		-- Editing mode taint: No longer an issue
		-- Follow base taint and group finder taint but edit the group after listing it and toggle the opposite
		-- faction checkbox.  This is mitigated by locking the checkbox in editing mode.
		-- Appears fixed as toggling the checkbox no longer causes taint.

		-- Scale map taint: No longer an issue
		-- Appears fixed as replacing WorldMapFrame.ScrollContainer.GetCursorPosition is no longer needed.

		-- Command taint: Still an issue
		-- Enter /ltm map 150 during combat and click a boss button.

		-- Load Battlefield addon
		if not C_AddOns.IsAddOnLoaded("Blizzard_BattlefieldMap") then
			UIParentLoadAddOn("Blizzard_BattlefieldMap")
		end

		-- Get player faction
		local playerFaction = UnitFactionGroup("player")

		-- Remove blackout frame
		if LeaMapsLC["UseDefaultMap"] == "Off" then
			WorldMapFrame.BlackoutFrame:SetAlpha(0)
			WorldMapFrame.BlackoutFrame:EnableMouse(false)
		end

		-- Hide the world map tutorial button
		WorldMapFrame.BorderFrame.Tutorial:HookScript("OnShow", WorldMapFrame.BorderFrame.Tutorial.Hide)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)

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

		if LeaMapsLC["ScaleWorldMap"] == "On" and LeaMapsLC["UseDefaultMap"] == "Off" then

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
				if not WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				else
					if LeaMapsLC["UseDefaultMap"] == "Off" then
						WorldMapFrame:SetScale(LeaMapsLC["MaxMapScale"])
					else
						WorldMapFrame:SetScale(1)
					end
				end
			end

			-- Set scale properties when controls are changed and on startup
			LeaMapsCB["MapScale"]:HookScript("OnValueChanged", SetMapScale)
			LeaMapsCB["MaxMapScale"]:HookScript("OnValueChanged", SetMapScale)
			SetMapScale()

			-- Set scale when map size is toggled
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", SetMapScale)

			-- Back to Main Menu button click
			scalePanel.b:HookScript("OnClick", function()
				scalePanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			scalePanel.r:HookScript("OnClick", function()
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
					-- Preset profile
					LeaMapsLC["MapScale"] = 1.0
					LeaMapsLC["MaxMapScale"] = 0.9
					SetMapScale()
					if scalePanel:IsShown() then scalePanel:Hide(); scalePanel:Show(); end
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

			-- Show teammates
			BattlefieldMapOptions.showPlayers = true

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
				BattlefieldMapFrame.groupMembersDataProvider.pin.SetAppearanceField("party", "sublevel", 0)
				BattlefieldMapFrame.groupMembersDataProvider.pin.SetAppearanceField("raid", "sublevel", 0)

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

		do

			-- Create background frame
			local cFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
			cFrame:SetSize(WorldMapFrame:GetWidth(), 17)
			cFrame:SetPoint("BOTTOMLEFT", 17)
			cFrame:SetPoint("BOTTOMRIGHT", 0)

			cFrame.t = cFrame:CreateTexture(nil, "BACKGROUND")
			cFrame.t:SetAllPoints()
			cFrame.t:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			cFrame.t:SetVertexColor(0, 0, 0, 0.5)

			-- Create cursor coordinates frame
			local cCursor = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
			cCursor:SetSize(200, 16)
			cCursor:SetParent(cFrame)
			cCursor:ClearAllPoints()
			cCursor:SetPoint("BOTTOMLEFT", 152, 1)
			cCursor.x = cCursor:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			cCursor.x:SetJustifyH"LEFT"
			cCursor.x:SetAllPoints()
			cCursor.x:SetText(L["Cursor"] .. ": 88.8, 88.8")
			cCursor:SetWidth(cCursor.x:GetStringWidth() + 50)

			-- Create player coordinates frame
			local cPlayer = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
			cPlayer:SetSize(200, 16)
			cPlayer:SetParent(cFrame)
			cPlayer:ClearAllPoints()
			cPlayer:SetPoint("BOTTOMRIGHT", -132, 1)
			cPlayer.x = cPlayer:CreateFontString(nil, "ARTWORK", "GameFontNormal")
			cPlayer.x:SetJustifyH"LEFT"
			cPlayer.x:SetAllPoints()
			cPlayer.x:SetText(L["Player"] .. ": 88.8, 88.8")
			cPlayer:SetWidth(cPlayer.x:GetStringWidth() + 50)

			-- Update timer
			local cPlayerTime = -1

			-- Update function
			cPlayer:SetScript("OnUpdate", function(self, elapsed)
				if cPlayerTime > 0.1 or cPlayerTime == -1 then
					-- Cursor coordinates
					local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
					if x and y and x > 0 and y > 0 and MouseIsOver(WorldMapFrame.ScrollContainer) then
						cCursor.x:SetFormattedText("%s: %.1f, %.1f", L["Cursor"], ((floor(x * 1000 + 0.5)) / 10), ((floor(y * 1000 + 0.5)) / 10))
					else
						cCursor.x:SetFormattedText("%s:", L["Cursor"])
					end
				end
				if cPlayerTime > 0.2 or cPlayerTime == -1 then
					-- Player coordinates
					local mapID = C_Map.GetBestMapForUnit("player")
					if not mapID then
						cPlayer.x:SetFormattedText("%s:", L["Player"])
						return
					end
					local position = C_Map.GetPlayerMapPosition(mapID,"player")
					if position and position.x ~= 0 and position.y ~= 0 then
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], position.x * 100, position.y * 100)
					else
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], 0, 0)
					end
					cPlayerTime = 0
				end
				cPlayerTime = cPlayerTime + elapsed
			end)

			-- Function to show or hide coordinates frames
			local function SetupCoords()
				if LeaMapsLC["ShowCoords"] == "On" then	cFrame:Show() else cFrame:Hide() end
			end

			LeaMapsCB["ShowCoords"]:HookScript("OnClick", SetupCoords)
			SetupCoords()

			-- Create configuration panel
			local cPanel = LeaMapsLC:CreatePanel("Show coordinates", "cPanel")

			-- Add controls
			LeaMapsLC:MakeTx(cPanel, "Settings", 16, -72)
			LeaMapsLC:MakeCB(cPanel, "CoordsLargeFont", "Use large font", 16, -92, false, "If checked, coordinates will use a large font.")
			LeaMapsLC:MakeCB(cPanel, "CoordsBackground", "Show background", 16, -112, false, "If checked, coordinates will have a dark background texture.")

			-- Function to apply settings
			local function SetCoordFunc()
				if LeaMapsLC["CoordsLargeFont"] == "On" then
					cCursor.x:SetFont(cCursor.x:GetFont(), 16)
					cPlayer.x:SetFont(cPlayer.x:GetFont(), 16)
				else
					cCursor.x:SetFont(cCursor.x:GetFont(), 12)
					cPlayer.x:SetFont(cPlayer.x:GetFont(), 12)
				end
				if LeaMapsLC["CoordsBackground"] == "On" then
					cFrame.t:Show()
				else
					cFrame.t:Hide()
				end
			end

			-- Set coordinates settings when options are clicked and on startup
			LeaMapsCB["CoordsLargeFont"]:HookScript("OnClick", SetCoordFunc)
			LeaMapsCB["CoordsBackground"]:HookScript("OnClick", SetCoordFunc)
			SetCoordFunc()

			-- Back to Main Menu button click
			cPanel.b:HookScript("OnClick", function()
				cPanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			cPanel.r:HookScript("OnClick", function()
				LeaMapsLC["CoordsLargeFont"] = "Off"
				LeaMapsLC["CoordsBackground"] = "On"
				SetCoordFunc()
				cPanel:Hide(); cPanel:Show()
			end)

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["ShowCoordsBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["CoordsLargeFont"] = "On"
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
		-- Unlock map frame (must be before Remove map border)
		----------------------------------------------------------------------

		if LeaMapsLC["UnlockMap"] == "On" and LeaMapsLC["UseDefaultMap"] == "Off" then

			-- Create configuration panel
			local scaleFrame = LeaMapsLC:CreatePanel("Unlock map frame", "scaleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(scaleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(scaleFrame, "EnableMovement", "Allow frame movement", 16, -92, false, "If checked, you will be able to move the frame by dragging the border.")

			----------------------------------------------------------------------
			-- Allow map frame movement
			----------------------------------------------------------------------

			-- Remove frame management
			C_Timer.After(0.1, function() -- Needed to apply settings properly (else game menu wont open with escape and opening map alongside character frame resets map position)
				WorldMapFrame:SetAttribute("UIPanelLayout-area", nil)
				WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
				WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
			end)

			-- Enable movement
			WorldMapFrame:SetMovable(true)
			WorldMapFrame:RegisterForDrag("LeftButton")
			WorldMapFrame:SetScript("OnDragStart", function()
				if LeaMapsLC["EnableMovement"] == "On" then
					WorldMapFrame:StartMoving()
				end
			end)
			WorldMapFrame:SetScript("OnDragStop", function()
				WorldMapFrame:StopMovingOrSizing()
				WorldMapFrame:SetUserPlaced(false)
				-- Save map frame position
				if WorldMapFrame:IsMaximized() then
					LeaMapsLC["MaxMapPosA"], void, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"] = WorldMapFrame:GetPoint()
				else
					LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
				end
			end)

			WorldMapFrame:SetClampedToScreen(true)

			-- Function to set map position
			local function SetMapPositionFunc()
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

		hooksecurefunc("DoEmote", function(emote)
			if emote == "READ" and WorldMapFrame:IsShown() then
				if LeaMapsLC["NoMapEmote"] == "On" then
					CancelEmote()
				end
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
			local tex = {}

			-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
			local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)

				-- Remove existing textures
				for k, v in pairs(tex) do
					v:SetVertexColor(1, 1, 1, 1)
				end
				wipe(tex)

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
				pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[pin.layerIndex]
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
								local texture = pin.overlayTexturePool:Acquire()
								tinsert(tex, texture)
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
								if fullUpdate then
									pin.textureLoadGroup:AddTexture(texture)
								end
								if LeaMapsLC["RevTint"] == "On" and mapType == 3 then
									texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
								end
								tinsert(overlayTextures, texture)
							end
						end
					end
				end
			end

			-- Reset texture color and alpha
			local function TexturePool_ResetVertexColor(pool, texture)
				texture:SetVertexColor(1, 1, 1)
				texture:SetAlpha(1)
				return TexturePool_HideAndClearAnchors(pool, texture)
			end

			-- Show overlays on startup
			for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
				pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
			end

			local bftex = {}

			-- Repeat refresh overlays function for Battlefield map
			local function bfMapExplorationPin_RefreshOverlays(pin, fullUpdate)

				-- Remove existing textures
				for k, v in pairs(bftex) do
					v:SetVertexColor(1, 1, 1, 1)
				end
				wipe(bftex)

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
				pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[pin.layerIndex]
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
								local texture = pin.overlayTexturePool:Acquire()
								tinsert(bftex, texture)
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
								if fullUpdate then
									pin.textureLoadGroup:AddTexture(texture)
								end
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
				pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
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

			-- Add tint unexplored areas checkbox to world map filter menu
			do

				-- Define essential functions
				local function IsSelected()
					return LeaMapsLC["RevTint"] == "On"
				end

				local function SetSelected()
					if LeaMapsLC["RevTint"] == "On" then
						LeaMapsLC["RevTint"] = "Off"
					else
						LeaMapsLC["RevTint"] = "On"
					end
					SetTintCol()
					if LeaMapsCB["RevTint"]:IsShown() then LeaMapsCB["RevTint"]:Hide(); LeaMapsCB["RevTint"]:Show() end
				end

				-- Create checkbox entry
				local button = MenuUtil.CreateCheckbox(L["Tint unexplored areas"], IsSelected, SetSelected)

				-- Add tooltip
				-- local function OnTooltipShow(tooltipFrame, elementDescription)
				-- 	GameTooltip_SetTitle(tooltipFrame, L["If checked, unexplored areas will be tinted."])
				-- end
				-- button:SetTooltip(OnTooltipShow)

				-- Insert button to menu
				Menu.ModifyMenu("MENU_WORLD_MAP_TRACKING", function(ownerRegion, rootDescription, contextData)
					rootDescription:CreateDivider()
					rootDescription:CreateTitle(L["Leatrix Maps"])
					rootDescription:Insert(button)
				end)

			end

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

			----------------------------------------------------------------------
			-- Use default map
			----------------------------------------------------------------------

			if LeaMapsLC["UseDefaultMap"] == "On" then
				-- Lock some incompatible options
				LeaMapsLC:LockItem(LeaMapsCB["UnlockMap"], true)
				LeaMapsCB["UnlockMap"].tiptext = LeaMapsCB["UnlockMap"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot be used with Use default map."]

				LeaMapsLC:LockItem(LeaMapsCB["ScaleWorldMap"], true)
				LeaMapsCB["ScaleWorldMap"].tiptext = LeaMapsCB["ScaleWorldMap"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot be used with Use default map."]
			end

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

			local subTitle = LeaMapsLC:MakeTx(interPanel, "www.leatrix.com", 0, 0)
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

			expTitle:SetText(L["The War Within"])
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
		local Side = CreateFrame("Frame", nil, UIParent)

		-- Make it a system frame
		_G["LeaMapsGlobalPanel_" .. globref] = Side
		table.insert(UISpecialFrames, "LeaMapsGlobalPanel_" .. globref)

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
		LeaMapsLC:LockOption("ScaleWorldMap", "ScaleWorldMapBtn", true) 		-- Scale the map
		LeaMapsLC:LockOption("RevealMap", "RevTintBtn", true)					-- Shiw unexplored areas
		LeaMapsLC:LockOption("UnlockMap", "UnlockMapBtn", true)					-- Unlock map frame
		LeaMapsLC:LockOption("ShowCoords", "ShowCoordsBtn", false)				-- Show coordinates
		LeaMapsLC:LockOption("EnhanceBattleMap", "EnhanceBattleMapBtn", true) 	-- Enhance battlefield map
		-- Ensure locked but enabled options remain locked
		if LeaMapsLC["UseDefaultMap"] == "On" then
			LeaMapsCB["UnlockMapBtn"]:Disable()
			LeaMapsCB["ScaleWorldMapBtn"]:Disable()
		end
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
			mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
		end
		mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

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
		if	(LeaMapsLC["UnlockMap"] ~= LeaMapsDB["UnlockMap"])					-- Unlock map
		or	(LeaMapsLC["UseDefaultMap"] ~= LeaMapsDB["UseDefaultMap"])			-- Use default map
		or	(LeaMapsLC["ScaleWorldMap"] ~= LeaMapsDB["ScaleWorldMap"])			-- Scale the map
		or	(LeaMapsLC["RevealMap"] ~= LeaMapsDB["RevealMap"])					-- Show unexplored areas
		or	(LeaMapsLC["ShowIcons"] ~= LeaMapsDB["ShowIcons"])					-- Show additional icons
		or	(LeaMapsLC["HideTownCity"] ~= LeaMapsDB["HideTownCity"])			-- Hide town and city icons
		or	(LeaMapsLC["EnhanceBattleMap"] ~= LeaMapsDB["EnhanceBattleMap"])	-- Enhance battlefield map
		or	(LeaMapsLC["NoFilterResetBtn"] ~= LeaMapsDB["NoFilterResetBtn"])	-- Hide filte reset button
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
		local Slider = CreateFrame("Slider", nil, frame, "UISliderTemplate")
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
				LeaMapsDB["UnlockMap"] = "On"
				LeaMapsDB["EnableMovement"] = "On"
				LeaMapsDB["UseDefaultMap"] = "Off"
				LeaMapsDB["ScaleWorldMap"] = "Off"
				LeaMapsDB["MapScale"] = 1.0
				LeaMapsDB["MaxMapScale"] = 0.9
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
				LeaMapsDB["CoordsLargeFont"] = "On"
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
			LeaMapsLC:LoadVarChk("UnlockMap", "Off")					-- Unlock map frame
			LeaMapsLC:LoadVarChk("EnableMovement", "On")				-- Enable frame movement
			LeaMapsLC:LoadVarChk("UseDefaultMap", "Off")				-- Use default map
			LeaMapsLC:LoadVarChk("ScaleWorldMap", "Off")				-- Scale the map
			LeaMapsLC:LoadVarNum("MapScale", 1.0, 0.5, 2)				-- Map scale
			LeaMapsLC:LoadVarNum("MaxMapScale", 1.0, 0.5, 2)			-- Maximised map scale
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
			LeaMapsLC:LoadVarChk("CoordsLargeFont", "Off")				-- Coordinates large font
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

			LeaMapsLC:LoadVarChk("ShowMinimapIcon", "On")				-- Show minimap button

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

			-- Lock options currently not compatible with Dragonflight (LeaMapsLC.DF)
			local function LockDF(option, reason)
				LeaMapsLC[option] = "Off"
				LeaMapsDB[option] = "Off"
				LeaMapsLC:LockItem(LeaMapsCB[option], true)
				if reason then
					LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. "|n|n|cff00AAFF" .. L[reason]
				end
			end

			if LeaMapsLC.NewPatch then
			else
				-- LockDF("NoMapTabs", "This is for game patch 11.1.0.")
			end

		elseif event == "PLAYER_LOGIN" then
			-- Run main function
			LeaMapsLC:MainFunc()

		elseif event == "PLAYER_LOGOUT" and not LeaMapsLC["NoSaveSettings"] then
			-- Mechanics
			LeaMapsDB["UnlockMap"] = LeaMapsLC["UnlockMap"]
			LeaMapsDB["EnableMovement"] = LeaMapsLC["EnableMovement"]
			LeaMapsDB["UseDefaultMap"] = LeaMapsLC["UseDefaultMap"]
			LeaMapsDB["ScaleWorldMap"] = LeaMapsLC["ScaleWorldMap"]
			LeaMapsDB["MapScale"] = LeaMapsLC["MapScale"]
			LeaMapsDB["MaxMapScale"] = LeaMapsLC["MaxMapScale"]
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
			LeaMapsDB["CoordsLargeFont"] = LeaMapsLC["CoordsLargeFont"]
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
	local PageF = CreateFrame("Frame", nil, UIParent)

	-- Make it a system frame
	_G["LeaMapsGlobalPanel"] = PageF
	table.insert(UISpecialFrames, "LeaMapsGlobalPanel")

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
	LeaMapsLC:MakeCB(PageF, "UnlockMap", "Unlock map frame", 16, -92, true, "If checked, you will be able to move the map.|n|nThe map position will be saved separately for the maximised and windowed maps.")
	LeaMapsLC:MakeCB(PageF, "UseDefaultMap", "Use default map", 16, -112, true, "If checked, the default fullscreen map will be used for the maximised map.|n|nNote that enabling this option will lock out some of the other options.")
	LeaMapsLC:MakeCB(PageF, "ScaleWorldMap", "Scale the map", 16, -132, true, "If checked, you will be able to scale the map.")

	LeaMapsLC:MakeTx(PageF, "Elements", 225, -72)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Show unexplored areas", 225, -92, true, "If checked, unexplored areas of the map will be shown on the world map and the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 225, -112, false, "If checked, coordinates will be shown.")
	LeaMapsLC:MakeCB(PageF, "ShowIcons", "Show additional icons", 225, -132, true, "If checked, additional icons (such as portals) will be shown.")
	LeaMapsLC:MakeCB(PageF, "HideTownCity", "Hide town and city icons", 225, -152, true, "If checked, town and city icons will not be shown on the continent maps.")

	LeaMapsLC:MakeTx(PageF, "More", 225, -192)
	LeaMapsLC:MakeCB(PageF, "EnhanceBattleMap", "Enhance battlefield map", 225, -212, true, "If checked, you will be able to customise the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "NoMapFade", "Disable map fade", 225, -232, false, "If checked, the map will not fade while your character is moving.")
	LeaMapsLC:MakeCB(PageF, "NoMapEmote", "Disable reading emote", 225, -252, false, "If checked, your character will not perform the reading emote when you open the map.")
	LeaMapsLC:MakeCB(PageF, "NoFilterResetBtn", "Hide filter reset button", 225, -272, true, "If checked, the world map filter reset button will be hidden.")
	LeaMapsLC:MakeCB(PageF, "ShowMinimapIcon", "Show minimap button", 225, -292, false, "If checked, the minimap button will be shown.")

	LeaMapsLC:CfgBtn("ScaleWorldMapBtn", LeaMapsCB["ScaleWorldMap"])
	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
	LeaMapsLC:CfgBtn("UnlockMapBtn", LeaMapsCB["UnlockMap"])
	LeaMapsLC:CfgBtn("ShowCoordsBtn", LeaMapsCB["ShowCoords"])
	LeaMapsLC:CfgBtn("EnhanceBattleMapBtn", LeaMapsCB["EnhanceBattleMap"])
