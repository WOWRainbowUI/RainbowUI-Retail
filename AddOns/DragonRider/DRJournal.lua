local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

local function Print(...)
	local prefix = string.format("[PH] Dragon Rider" .. ":");
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

function DR.tooltip_OnEnter(frame, tooltip)
	GameTooltip:SetOwner(frame, "ANCHOR_TOP")
	GameTooltip_AddNormalLine(GameTooltip, tooltip);
	GameTooltip:Show();
end

function DR.tooltip_OnLeave()
	GameTooltip:Hide();
end

-- Using Blizz's globally accessible frame fade function causes taint with the map
-- So just add their own code in locally

local FrameFaderDriver;
local fadingFrames;
local deferredFadingFrames;

local function OnUpdate(self, elapsed)
	local isMoving = IsPlayerMoving();
	for frame, setting in pairs(fadingFrames) do
		local fadeOut = isMoving and (not setting.fadePredicate or setting.fadePredicate());
		frame:SetAlpha(DeltaLerp(frame:GetAlpha(), fadeOut and setting.minAlpha or setting.maxAlpha, .1, elapsed));
	end
end

local function MergeDeferredEvents()
	if deferredFadingFrames then
		for frame, setting in pairs(deferredFadingFrames) do
			fadingFrames[frame] = setting;
		end
		deferredFadingFrames = nil;
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_STARTED_MOVING" 
	or event == "PLAYER_STOPPED_MOVING" 
	or event == "PLAYER_IS_GLIDING_CHANGED" 
	or event == "PLAYER_IMPULSE_APPLIED" then
		MergeDeferredEvents();
	end
end

local function InitializeDriver()
	if not FrameFaderDriver then
		fadingFrames = {};

		FrameFaderDriver = CreateFrame("FRAME");
		FrameFaderDriver:SetScript("OnUpdate", OnUpdate);
		FrameFaderDriver:SetScript("OnEvent", OnEvent);
		FrameFaderDriver:RegisterEvent("PLAYER_STARTED_MOVING");
		FrameFaderDriver:RegisterEvent("PLAYER_STOPPED_MOVING");
		FrameFaderDriver:RegisterEvent("PLAYER_IS_GLIDING_CHANGED");
		FrameFaderDriver:RegisterEvent("PLAYER_IMPULSE_APPLIED");
	end
end

local function PackFadeData(minAlpha, maxAlpha, durationSec, fadePredicate)
	return { minAlpha = minAlpha or .5, maxAlpha = maxAlpha or 1, durationSec = durationSec or 1, fadePredicate = fadePredicate };
end

local function RemoveFrameInternal(frame)
	if fadingFrames then
		fadingFrames[frame] = nil;
	end
	if deferredFadingFrames then
		deferredFadingFrames[frame] = nil;
	end
end

local PlayerMovementFrameFader = {};

function PlayerMovementFrameFader.AddFrame(frame, minAlpha, maxAlpha, durationSec, fadePredicate)
	RemoveFrameInternal(frame);

	InitializeDriver();
	fadingFrames[frame] = PackFadeData(minAlpha, maxAlpha, durationSec, fadePredicate);
end

-- The fading won't take effect until the player stops or starts moving again
function PlayerMovementFrameFader.AddDeferredFrame(frame, minAlpha, maxAlpha, durationSec, fadePredicate)
	InitializeDriver();
	RemoveFrameInternal(frame);

	if not deferredFadingFrames then
		deferredFadingFrames = {};
	end
	deferredFadingFrames[frame] = PackFadeData(minAlpha, maxAlpha, durationSec, fadePredicate);
end

function PlayerMovementFrameFader.RemoveFrame(frame)
	local maxAlpha = fadingFrames and fadingFrames[frame] and fadingFrames[frame].maxAlpha;
	if maxAlpha then
		frame:SetAlpha(maxAlpha);
	end

	RemoveFrameInternal(frame, restoreAlpha);
end

local function SetupFade(self)
	local minAlpha = 0.5;
	local maxAlpha = 1.0;
	local duration = 0.5;
	local predicate = function() return not self:IsMouseOver(); end;
	PlayerMovementFrameFader.AddDeferredFrame(self, minAlpha, maxAlpha, duration, predicate);
end

local function CleanupFade(self)
	PlayerMovementFrameFader.RemoveFrame(self);
end

DR.mainFrame = CreateFrame("Frame", "DragonRiderMainFrame", UIParent, "PortraitFrameTemplate")
tinsert(UISpecialFrames, DR.mainFrame:GetName())
local DRportrait = DR.mainFrame.PortraitContainer.portrait
DRportrait:SetTexCoord(0.03, 1, 0.03, 1) -- centers the icon a little bit more, since there was a large gap in the top / left
DRportrait:SetTexture("Interface\\ICONS\\Ability_DragonRiding_Glyph01")

--DR.mainFrame.PortraitContainer.portrait:SetTexture("Interface\\AddOns\\Languages\\Languages_Icon_Small")
DR.mainFrame:SetTitle(L["DragonRider"])
DR.mainFrame:SetSize(550,525)
DR.mainFrame:SetPoint("CENTER", UIParent, "CENTER")
DR.mainFrame:SetMovable(true)
DR.mainFrame:SetClampedToScreen(true)
DR.mainFrame:SetScript("OnMouseDown", function(self, button)
	self:StartMoving();
end);
DR.mainFrame:SetScript("OnMouseUp", function(self, button)
	DR.mainFrame:StopMovingOrSizing();
end);
DR.mainFrame:SetFrameStrata("HIGH")
DR.mainFrame:Hide()
DR.mainFrame:SetScript("OnHide", function()
	PlaySound(74423);
end);

--[[
-- cool funni dragon portrait, maybe for something cool some day
DR.mainFrame.PortraitDragon = CreateFrame("Frame", nil, DR.mainFrame.PortraitContainer)
DR.mainFrame.PortraitDragon:SetPoint("CENTER", DR.mainFrame.PortraitContainer, "CENTER", 13, -22)
DR.mainFrame.PortraitDragon:SetSize(99, 81)
DR.mainFrame.PortraitDragon:SetFrameLevel(700)

DR.mainFrame.PortraitDragon.tex = DR.mainFrame.PortraitDragon:CreateTexture()
DR.mainFrame.PortraitDragon.tex:SetAllPoints()
DR.mainFrame.PortraitDragon.tex:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged")
DR.mainFrame.PortraitDragon.tex:SetTexCoord(1, 0, 0, 1)
--]]


DR.mainFrame.portraitTooltipThing = CreateFrame("Frame", nil, DR.mainFrame);
DR.mainFrame.portraitTooltipThing:SetAllPoints(DRportrait);

local function AddTimerunnerLines(tooltip)
	tooltip:AddLine("|A:timerunning-glues-icon:0:0:0:0|a |cFFFFF569"..L["TimerunningStatistics"] .. "|r", 1, 1, 1, 1, true);

	if not DragonRider_DB or not DragonRider_DB.Timerunner or not DragonRider_DB.Timerunner[2] then return end

	local entries = {
		{ key = "Creature_Demonfly",   value = DragonRider_DB.Timerunner[2].Demonfly },
		{ key = "Creature_Darkglare",  value = DragonRider_DB.Timerunner[2].Darkglare },
		{ key = "Creature_FelSpreader",value = DragonRider_DB.Timerunner[2].FelSpreader },
		{ key = "Creature_Felbat",     value = DragonRider_DB.Timerunner[2].Felbat },
		{ key = "Creature_Felbomber",  value = DragonRider_DB.Timerunner[2].Felbomber },
		{ key = "Creature_Skyterror",  value = DragonRider_DB.Timerunner[2].Skyterror },
		{ key = "Creature_EyeOfGreed", value = DragonRider_DB.Timerunner[2].EyeOfGreed },
	}

	local needsRefresh = false

	for _, entry in ipairs(entries) do
		if entry.value then
			local name = L[entry.key]
			if name and name ~= "" and (name ~= "Unknown NPC" and name ~= UNKNOWN) then
				tooltip:AddDoubleLine(
					"|A:timerunning-infographic-bullet:0:0:0:0|a "..name..": ",
					entry.value,
					1, 1, 1,
					1, 1, 1
				)
			else
				tooltip:AddLine("|A:timerunning-infographic-bullet:0:0:0:0|a ".."...", 1, 0, 0, 1, true);
				needsRefresh = true
			end
		end
	end

	-- divider
	tooltip:AddLine(" ")
	tooltip:AddAtlas("Adventure-MissionEnd-Line", {
	width = 225,
	height = 12,
	anchor = Enum.TooltipTextureAnchor.LeftTop,
	region = Enum.TooltipTextureRelativeRegion.LeftLine,
	verticalOffset = 0,
	margin = { left = 8, right = 8, top = 0, bottom = 0 },
	texCoords = { left = 0, right = 1, top = 0, bottom = 1 },
	vertexColor = { r = 1, g = 1, b = 1, a = 1 },
	});

	-- Skyriding Bronze Gained
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(3252)
	if currencyInfo then
		local currencyName = currencyInfo.name or L["Unknown"]
		local bronzeValue = DragonRider_DB.Timerunner[2].Bronze or 0
		tooltip:AddDoubleLine(
			string.format("|A:timerunning-infographic-bullet:0:0:0:0|a "..L["SkyridingCurrencyGained"], currencyName),
			bronzeValue,
			1, 1, 1,
			1, 1, 1
		)
	end

	if needsRefresh and tooltip.RefreshDataNextUpdate then
		tooltip:RefreshDataNextUpdate()
	end
end


DR.mainFrame.portraitTooltipThing:SetScript("OnEnter", function(self)
	local SeasonID = PlayerGetTimerunningSeasonID()
	if not SeasonID then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	AddTimerunnerLines(GameTooltip)
	GameTooltip:Show()
end)

DR.mainFrame.portraitTooltipThing:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)


function DR.mainFrame.CreateDragonRiderFlipbook()
	if not DR or not DR.mainFrame or not DRportrait then
		return
	end

	local frame = CreateFrame("Frame", nil, DR.mainFrame)
	frame:SetSize(100, 100)
	frame:SetPoint("CENTER", DRportrait, "CENTER", 10, -10)
	frame:SetFrameLevel(800) -- yes really it has to be this high

	local tex = frame:CreateTexture()
	tex:SetAllPoints(frame)
	tex:SetAtlas("timerunning-fx-cornerswoop-flipbook")
	frame.tex = tex


	local animGroup = frame:CreateAnimationGroup()
	frame.animGroup = animGroup
	animGroup:SetLooping("REPEAT")
	animGroup:SetToFinalAlpha(true)

	local flipAnim = animGroup:CreateAnimation("FlipBook")
	flipAnim:SetChildKey("tex")
	flipAnim:SetDuration(2)
	flipAnim:SetOrder(1)
	flipAnim:SetFlipBookRows(7)
	flipAnim:SetFlipBookColumns(9)
	flipAnim:SetFlipBookFrames(63)
	flipAnim:SetFlipBookFrameWidth(0)
	flipAnim:SetFlipBookFrameHeight(0)

	frame:SetScript("OnShow", function(self) self.animGroup:Play() end)
	frame:SetScript("OnHide", function(self) self.animGroup:Stop() end)

	DR.mainFrame.TimerunningFlipbook = frame
end


function DR.mainFrame.CreateDragonRiderFlipbookRotated()
	if not DR or not DR.mainFrame or not DRportrait then
		return
	end

	local frame = CreateFrame("Frame", nil, DR.mainFrame)
	frame:SetSize(60, 60)
	frame:SetPoint("CENTER", DRportrait, "CENTER", 0, 0)
	frame:SetFrameLevel(800)

	local tex = frame:CreateTexture()
	tex:SetAllPoints(frame)
	tex:SetAtlas("timerunning-fx-cornerswoop-flipbook")
	tex:SetRotation(math.pi)
	frame.tex = tex


	local animGroup = frame:CreateAnimationGroup()
	frame.animGroup = animGroup
	animGroup:SetLooping("REPEAT")
	animGroup:SetToFinalAlpha(true)

	local flipAnim = animGroup:CreateAnimation("FlipBook")
	flipAnim:SetChildKey("tex")
	flipAnim:SetDuration(1.5)
	flipAnim:SetOrder(15) -- makes it so it isn't as obvious a repeat
	flipAnim:SetFlipBookRows(7)
	flipAnim:SetFlipBookColumns(9)
	flipAnim:SetFlipBookFrames(63)
	flipAnim:SetFlipBookFrameWidth(0)
	flipAnim:SetFlipBookFrameHeight(0)

	frame:SetScript("OnShow", function(self) self.animGroup:Play() end)
	frame:SetScript("OnHide", function(self) self.animGroup:Stop() end)

	DR.mainFrame.TimerunningFlipbook = frame
end

function DR.mainFrame.CreateFadeIcon()
	if not DR or not DR.mainFrame or not DRportrait then
		return
	end

	local frame = CreateFrame("Frame", "FadeIconExample", DR.mainFrame)
	frame:SetSize(60, 60)
	frame:SetPoint("CENTER", DRportrait, "CENTER", 0, 0)
	frame:SetFrameLevel(800)

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints(frame)
	tex:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\TimerunningIcon")
	frame.tex = tex

	local ag = tex:CreateAnimationGroup()
	ag:SetLooping("NONE")

	-- step 1 - delay at alpha 0
	local hold = ag:CreateAnimation("Alpha")
	hold:SetFromAlpha(0)
	hold:SetToAlpha(0)
	hold:SetDuration(5.0) -- hold faded
	hold:SetOrder(1)

	-- step 2 - fade in
	local fadeIn = ag:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(0)
	fadeIn:SetToAlpha(1)
	fadeIn:SetDuration(.5)
	fadeIn:SetOrder(2)

	-- step 3 - fade out
	local fadeOut = ag:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0)
	fadeOut:SetDuration(3.5)
	fadeOut:SetOrder(3)

	-- when finished, restart
	ag:SetScript("OnFinished", function(self)
		self:Play()
	end)

	ag:Play()

	return frame
end



function DR.mainFrame.width()
	return DR.mainFrame:GetWidth();
end

local function disp_time(seconds)
	local time
	if seconds then
		time = string.format(SecondsToTime(seconds))
	end

	return time
end


function DR.mainFrame.multiplayerRace_TT()
	local zonesPOICombo = {
		[2022] = 7261, -- Waking Shores
		[2023] = 7262, -- Ohn'ahran Plains
		[2024] = 7263, -- Azure Span
		[2025] = 7264, -- Thaldraszus
	};
	local tooltipInfo;
	local activeMapID;
	local activePOI;
	local activePOI_X;
	local activePOI_Y;
	for k, v in pairs(zonesPOICombo) do
		if C_AreaPoiInfo.GetAreaPOIInfo(k, v) ~= nil then
			activeMapID = k;
			activePOI = v;
			activePOI_X = C_AreaPoiInfo.GetAreaPOIInfo(k, v).position.x
			activePOI_Y = C_AreaPoiInfo.GetAreaPOIInfo(k, v).position.y
			local timeConverted = disp_time(C_AreaPoiInfo.GetAreaPOISecondsLeft(v));
			tooltipInfo = C_AreaPoiInfo.GetAreaPOIInfo(k, v).name;

			tooltipInfo = tooltipInfo .. "\n" ..C_AreaPoiInfo.GetAreaPOIInfo(k, v).description;
			if timeConverted ~= nil then
				tooltipInfo = tooltipInfo .. "\n" .. timeConverted;
			end
		end
	end
	return activeMapID, activePOI, activePOI_X, activePOI_Y, tooltipInfo;
end
 
DR.mainFrame:SetResizable(true);
DR.mainFrame:SetResizeBounds(365,424,992,534)
DR.mainFrame.resizeButton = CreateFrame("Button", nil, DR.mainFrame)
DR.mainFrame.resizeButton:SetSize(18, 18)
DR.mainFrame.resizeButton:SetPoint("BOTTOMRIGHT")
DR.mainFrame.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
DR.mainFrame.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
DR.mainFrame.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
DR.mainFrame.resizeButton:SetParent(DR.mainFrame)
DR.mainFrame.resizeButton:SetFrameLevel(5)
 
DR.mainFrame.resizeButton:SetScript("OnMouseDown", function(self, button)
	DR.mainFrame:StartSizing("BOTTOMRIGHT")
	--DR.mainFrame:SetUserPlaced(true)
end)
 
DR.mainFrame.resizeButton:SetScript("OnMouseUp", function(self, button)
	local width, height = DR.mainFrame:GetSize()
	if DragonRider_DB.mainFrameSize == nil then
		DragonRider_DB.mainFrameSize = {}
	end
	DragonRider_DB.mainFrameSize.width = width
	DragonRider_DB.mainFrameSize.height = height
	DR.mainFrame:StopMovingOrSizing()
end)

DR.mainFrame.ScrollBorder = CreateFrame("Frame", nil, DR.mainFrame, "InsetFrameTemplate3")
local ScrollBorder = DR.mainFrame.ScrollBorder;
ScrollBorder:SetWidth(210);
ScrollBorder:SetPoint("TOPLEFT", DR.mainFrame, "TOPLEFT", 2, -85);
ScrollBorder:SetPoint("BOTTOMRIGHT", DR.mainFrame, "BOTTOMRIGHT", -3, 4);

DR.mainFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, DR.mainFrame, "ScrollFrameTemplate")
DR.mainFrame.ScrollFrame:SetPoint("TOPLEFT", ScrollBorder, "TOPLEFT", 3, -3.5)
DR.mainFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", ScrollBorder, "BOTTOMRIGHT", -2, 2)
DR.mainFrame.ScrollFrame.ScrollBar:ClearAllPoints()
DR.mainFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", DR.mainFrame.ScrollFrame, "TOPRIGHT", -12, -18)
DR.mainFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", DR.mainFrame.ScrollFrame, "BOTTOMRIGHT", -7, 16)


DR.mainFrame.ScrollFrame.child = CreateFrame("Frame", nil, DR.mainFrame.ScrollFrame)
DR.mainFrame.ScrollFrame:SetScrollChild(DR.mainFrame.ScrollFrame.child)
DR.mainFrame.ScrollFrame.child:SetWidth(DR.mainFrame:GetWidth()-18)
DR.mainFrame.ScrollFrame.child:SetHeight(1)



function DR.mainFrame.Tab_OnClick(self)

	PanelTemplates_SetTab(self:GetParent(), self:GetID())

	local scrollChild = DR.mainFrame.ScrollFrame:GetScrollChild()
	if (scrollChild) then
		scrollChild:Hide();
	end

	DR.mainFrame.ScrollFrame:SetScrollChild(self.content)
	self.content:Show()
	PlaySound(841)

end

function DR.mainFrame.SetTabs(frame,numTabs, ...)
	frame.numTabs = numTabs

	local contents = {};
	local frameName = frame:GetName()

	for i = 1, numTabs do

		DR.mainFrame.TabButtonTest = CreateFrame("Button", frameName .. "Tab" .. i, frame, "PanelTabButtonTemplate")
		DR.mainFrame.TabButtonTest:SetID(i)
		DR.mainFrame.TabButtonTest:SetText(select(i, ...))
		DR.mainFrame.TabButtonTest:SetScript("OnClick", DR.mainFrame.Tab_OnClick)

		DR.mainFrame.TabButtonTest.content = CreateFrame("Frame", nil, DR.mainFrame.ScrollFrame)
		DR.mainFrame.TabButtonTest.content:SetSize(334, 10)
		DR.mainFrame.TabButtonTest.content:Hide()

		table.insert(contents, DR.mainFrame.TabButtonTest.content)

		if (i == 1) then
			DR.mainFrame.TabButtonTest:SetPoint("TOPLEFT", DR.mainFrame, "BOTTOMLEFT", 11,2);
		else
			DR.mainFrame.TabButtonTest:SetPoint("TOPLEFT", _G[frameName .. "Tab" .. (i-1)] , "TOPRIGHT", 3, 0);
		end

		
	end


	DR.mainFrame.Tab_OnClick(_G[frameName .. "Tab1"])

	return unpack(contents);

end

local content1 = DR.mainFrame.SetTabs(DR.mainFrame, 1, L["Score"])
--[[
-- for now, disable, as this hasn't been accessible for a while. maybe one day
--local content1, content2, content3 = DR.mainFrame.SetTabs(DR.mainFrame, 3, L["Score"], L["Guide"], L["Settings"])

DragonRiderMainFrameTab2:SetEnabled(false)
DragonRiderMainFrameTab3:SetEnabled(false)

DragonRiderMainFrameTab2.Text:SetTextColor(.5,.5,.5)
DragonRiderMainFrameTab3.Text:SetTextColor(.5,.5,.5)

DragonRiderMainFrameTab2:SetScript("OnEnter", function(self)
	DR.tooltip_OnEnter(self, L["ComingSoon"])
end);
DragonRiderMainFrameTab2:SetScript("OnLeave", DR.tooltip_OnLeave);

DragonRiderMainFrameTab3:SetScript("OnEnter", function(self)
	DR.tooltip_OnEnter(self, L["ComingSoon"])
end);
DragonRiderMainFrameTab3:SetScript("OnLeave", DR.tooltip_OnLeave);
]]


function DR.mainFrame.UpdatePopulation()
	for i = 1, #DR.RaceData do
		DR.mainFrame.PopulationData(i);
	end
end

DR.mainFrame.accountAll_Checkbox = CreateFrame("CheckButton", nil, DR.mainFrame, "UICheckButtonTemplate");
DR.mainFrame.accountAll_Checkbox:SetPoint("TOPLEFT", DR.mainFrame, "TOPLEFT", 55, -25);
DR.mainFrame.accountAll_Checkbox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		PlaySound(856);
		DragonRider_DB.useAccountData = true;
		DR.mainFrame.UpdatePopulation()
	else
		PlaySound(857);
		DragonRider_DB.useAccountData = false;
		DR.mainFrame.UpdatePopulation()
	end
end);
DR.mainFrame.accountAll_Checkbox.text = DR.mainFrame.accountAll_Checkbox:CreateFontString()
DR.mainFrame.accountAll_Checkbox.text:SetFont(STANDARD_TEXT_FONT, 11)
DR.mainFrame.accountAll_Checkbox.text:SetPoint("LEFT", DR.mainFrame.accountAll_Checkbox, "RIGHT", 0, 0)
DR.mainFrame.accountAll_Checkbox.text:SetText(L["UseAccountScores"])
DR.mainFrame.accountAll_Checkbox.text:SetScript("OnEnter", function(self)
	DR.tooltip_OnEnter(self, L["UseAccountScoresTT"])
end);
DR.mainFrame.accountAll_Checkbox.text:SetScript("OnLeave", DR.tooltip_OnLeave);
DR.mainFrame.accountAll_Checkbox:SetScript("OnEnter", function(self)
	DR.tooltip_OnEnter(self, L["UseAccountScoresTT"])
end);
DR.mainFrame.accountAll_Checkbox:SetScript("OnLeave", DR.tooltip_OnLeave);

DR.mainFrame.backgroundTex = DR.mainFrame.ScrollFrame:CreateTexture()
DR.mainFrame.backgroundTex:SetAllPoints(DR.mainFrame.ScrollFrame)
DR.mainFrame.backgroundTex:SetAtlas("Dragonflight-Landingpage-Background")
--DR.mainFrame.backgroundTex:SetAtlas("dragonriding-talents-background")


DR.mainFrame.backdropInfo = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 8,
	edgeSize = 8,
	insets = { left = 1, right = 1, top = 1, bottom = 1 },
};

DR.TooltipScan = CreateFrame("GameTooltip", "DragonRiderTooltipScanner", UIParent, "GameTooltipTemplate")

DR.QuestTitleFromID = setmetatable({}, { __index = function(t, id)
	DR.TooltipScan:SetOwner(UIParent, "ANCHOR_NONE")
	if id ~= nil then
		DR.TooltipScan:SetHyperlink("quest:"..id)
	end
	local title = DragonRiderTooltipScannerTextLeft1:GetText()
	DR.TooltipScan:Hide()
	if title and title ~= RETRIEVING_DATA then
		t[id] = title
		return title
	end
end })

DR.mainFrame.isPopulated = false;

function DR.mainFrame.WorldQuestHandler()
	local WorldQuestPlacement = 1
	for k, v in pairs(DR.WorldQuestIDs) do
		if C_TaskQuest.IsActive(v) == true then
			WorldQuestPlacement = WorldQuestPlacement +1
			if not DR.mainFrame["WorldQuestList_"..v] then
				DR.mainFrame["WorldQuestList_"..v] = CreateFrame("Button", nil, DR.mainFrame);
				DR.mainFrame["WorldQuestList_"..v].texlower = DR.mainFrame["WorldQuestList_"..v]:CreateTexture(nil, "OVERLAY", nil, 0);
				DR.mainFrame["WorldQuestList_"..v].texlower:SetPoint("CENTER", DR.mainFrame["WorldQuestList_"..v],"CENTER", 0,0);
				DR.mainFrame["WorldQuestList_"..v].texlower:SetSize(35,35);
				DR.mainFrame["WorldQuestList_"..v].texmiddle = DR.mainFrame["WorldQuestList_"..v]:CreateTexture(nil, "OVERLAY", nil, 1);
				DR.mainFrame["WorldQuestList_"..v].texmiddle:SetAllPoints(DR.mainFrame["WorldQuestList_"..v]);
				DR.mainFrame["WorldQuestList_"..v].texupper = DR.mainFrame["WorldQuestList_"..v]:CreateTexture(nil, "OVERLAY", nil, 2);
				DR.mainFrame["WorldQuestList_"..v].texupper:SetPoint("CENTER", DR.mainFrame["WorldQuestList_"..v],"CENTER", 5,-5);
				DR.mainFrame["WorldQuestList_"..v].texupper:SetSize(16,16);
			end
			--DR.mainFrame["WorldQuestList_"..v].tex:SetTexture(DR.ZoneIcons[C_Map.GetMapInfo(C_TaskQuest.GetQuestZoneID(v)).mapID])
			DR.mainFrame["WorldQuestList_"..v].texlower:SetAtlas("UI-QuestPoi-QuestNumber");
			DR.mainFrame["WorldQuestList_"..v].texupper:SetAtlas("worldquest-icon-race");
			DR.mainFrame["WorldQuestList_"..v].texmiddle:SetTexture(DR.ZoneIcons[C_Map.GetMapInfo(C_TaskQuest.GetQuestZoneID(v)).mapID])
			DR.mainFrame["WorldQuestList_"..v]:SetPoint("TOPLEFT", DR.mainFrame, "TOPLEFT", 25*WorldQuestPlacement-40, -57);
			--DR.mainFrame["WorldQuestList_"..v]:SetParent(content1)
			DR.mainFrame["WorldQuestList_"..v]:SetSize(20,20);
		end

		if DR.mainFrame["WorldQuestList_"..v] and C_QuestLog.IsQuestFlaggedCompleted(v) then

			if DR.mainFrame["WorldQuestList_"..v]:IsShown() then
				DR.mainFrame["WorldQuestList_"..v]:Hide()
			end
		end
		if DR.mainFrame["WorldQuestList_"..v] and C_TaskQuest.IsActive(v) == true then
			DR.mainFrame["WorldQuestList_"..v].texlower:SetAtlas("UI-QuestPoi-QuestNumber");
			DR.mainFrame["WorldQuestList_"..v].texupper:SetAtlas("worldquest-icon-race");
			DR.mainFrame["WorldQuestList_"..v].texmiddle:SetTexture(DR.ZoneIcons[C_Map.GetMapInfo(C_TaskQuest.GetQuestZoneID(v)).mapID])
			DR.mainFrame["WorldQuestList_"..v]:SetPoint("TOPLEFT", DR.mainFrame, "TOPLEFT", 25*WorldQuestPlacement-40, -57);

			DR.mainFrame["WorldQuestList_"..v]:SetScript("OnEnter", function(self)

				DR.mainFrame["WorldQuestList_"..v]:SetScript("OnMouseDown", function(self)
					DR.mainFrame["WorldQuestList_"..v].texmiddle:SetTexCoord(-.07,1.07,-.07,1.07)
				end);

				DR.mainFrame["WorldQuestList_"..v]:SetScript("OnMouseUp", function(self)
					DR.mainFrame["WorldQuestList_"..v].texmiddle:SetTexCoord(0,1,0,1)
				end);

				DR.mainFrame["WorldQuestList_"..v]:SetScript("OnClick", function(self)
					if not UnitAffectingCombat("player") then
						C_Map.OpenWorldMap(C_TaskQuest.GetQuestZoneID(v));
					end
					QuestUtil.TrackWorldQuest(v, 1)
					C_SuperTrack.SetSuperTrackedQuestID(v);
					PlaySound(170270);
				end);

				DR.mainFrame["WorldQuestList_"..v]:SetScript("OnUpdate", function(self)
					local taskInfo = ""

					if C_TaskQuest.GetQuestZoneID(v) then
						if C_Map.GetMapInfo(C_TaskQuest.GetQuestZoneID(v)).name then
							taskInfo = taskInfo .. C_Map.GetMapInfo(C_TaskQuest.GetQuestZoneID(v)).name;
						end
					end
					if C_TaskQuest.GetQuestInfoByQuestID(v) then
						taskInfo = taskInfo .. "\n" .. C_TaskQuest.GetQuestInfoByQuestID(v);
					end
					if disp_time(C_TaskQuest.GetQuestTimeLeftSeconds(v)) then
						taskInfo = taskInfo .. "\n" .. disp_time(C_TaskQuest.GetQuestTimeLeftSeconds(v));
					end
					DR.tooltip_OnEnter(self, taskInfo);
				end);

			end);
			DR.mainFrame["WorldQuestList_"..v]:SetScript("OnLeave", function(self)
				DR.tooltip_OnLeave();

				DR.mainFrame["WorldQuestList_"..v]:SetScript("OnUpdate", nil);

			end);
		end
	end
end

DR.mainFrame:RegisterEvent("QUEST_REMOVED")
DR.mainFrame:SetScript("OnEvent", DR.mainFrame.WorldQuestHandler)

DR.mainFrame.OpenTalentsButton = CreateFrame("Button", nil, DR.mainFrame, "SharedButtonTemplate")
DR.mainFrame.OpenTalentsButton:SetPoint("TOPRIGHT", DR.mainFrame, "TOPRIGHT", -5, -25);
DR.mainFrame.OpenTalentsButton:SetSize(180, 26);
DR.mainFrame.OpenTalentsButton:SetText(L["DragonridingTalents"]);
DR.mainFrame.OpenTalentsButton:SetScript("OnClick", function(self)
	GenericTraitUI_LoadUI();
	GenericTraitFrame:SetConfigIDBySystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
	GenericTraitFrame:SetTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
	ToggleFrame(GenericTraitFrame);
end);
DR.mainFrame.OpenTalentsButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip:AddLine(L["OpenDragonridingTalents"], 1, 1, 1);
	GameTooltip:Show();
end);
DR.mainFrame.OpenTalentsButton:SetScript("OnLeave", function()
	GameTooltip:Hide();
end);

function DR.mainFrame.PopulationData(continentIndex)
	local realmKey = GetRealmName()
	local charKey = UnitName("player") .. " - " .. realmKey
	DR.mainFrame.WorldQuestHandler()

	local continentData = DR.RaceData[continentIndex]
	if not continentData or not continentData.races then return end
	local mapID = continentData.zone

	-- a list of difficulty keys in the order they appear in the UI columns
	local difficultyOrder = {"normal", "advanced", "reverse", "challenge", "reversechallenge", "storm"}

	for raceIndex, raceInfo in ipairs(continentData.races) do
		-- handle the race name label and tracker button (the row header)
		do
			local questName = DR.QuestTitleFromID[raceInfo.questID]
			local mapPOI = raceInfo.mapPOI
			local courseLabelName = "Course"..continentIndex.."_"..raceIndex
			local courseTrackerName = "CourseTracker"..continentIndex.."_"..raceIndex

			if not DR.mainFrame[courseLabelName] then
				-- create the race name label
				DR.mainFrame[courseLabelName] = content1:CreateFontString()
				DR.mainFrame[courseLabelName]:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..continentIndex], "TOPLEFT", 10, -15*raceIndex-20)
				DR.mainFrame[courseLabelName]:SetFont(STANDARD_TEXT_FONT, 11)
				DR.mainFrame[courseLabelName]:SetParent(DR.mainFrame["backFrame"..continentIndex])

				if mapPOI then
					local trackedTooltip = (questName or "") .. "\n" .. "|A:Waypoint-MapPin-Tracked:15:15|a" ..VOICE_CHAT_CHANNEL_INACTIVE_TOOLTIP_INSTRUCTIONS
					DR.mainFrame[courseTrackerName] = CreateFrame("Button", nil, DR.mainFrame["backFrame"..continentIndex])
					DR.mainFrame[courseTrackerName]:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..continentIndex], "TOPLEFT", 10, -15*raceIndex-20)
					DR.mainFrame[courseTrackerName]:SetSize(120, 15)
					DR.mainFrame[courseTrackerName]:EnableMouse(true)
					DR.mainFrame[courseTrackerName]:SetFrameLevel(5)
					DR.mainFrame[courseTrackerName]:SetScript("OnEnter", function(self)
						self:SetScript("OnClick", function(self, button, down)

							if not UnitAffectingCombat("player") then
								C_Map.OpenWorldMap(mapID);
							end
							C_SuperTrack.SetSuperTrackedMapPin(0, mapPOI)
							PlaySound(170270)
						end)
						DR.tooltip_OnEnter(self, trackedTooltip)
					end)
					DR.mainFrame[courseTrackerName]:SetScript("OnLeave", DR.tooltip_OnLeave)
				end

				-- adjust container height on creation
				if raceIndex > 1 then
					DR.mainFrame["backFrame"..continentIndex]:SetHeight(DR.mainFrame["backFrame"..continentIndex]:GetHeight()+15)
				end
			end
			-- update text
			DR.mainFrame[courseLabelName]:SetText(questName or "[PH] Loading...")
		end

		-- handle the score cells for each difficulty
		for colIndex, difficultyKey in ipairs(difficultyOrder) do
			local difficultyData = raceInfo[difficultyKey]
			
			-- generate a unique name for the score font string for this cell
			local scoreFrameName = "ScoreFrame_"..continentIndex.."_"..raceIndex.."_"..colIndex
			local scoreFrame = DR.mainFrame[scoreFrameName]

			if not scoreFrame then
				scoreFrame = content1:CreateFontString(nil, nil, "GameFontNormal")
				scoreFrame:SetFont(STANDARD_TEXT_FONT, 11)
				scoreFrame:SetPoint("TOPLEFT", DR.mainFrame.resizeFrames["middleFrame_"..colIndex..continentIndex], "TOPLEFT", 0, -15*raceIndex-20)
				scoreFrame:SetParent(DR.mainFrame["backFrame"..continentIndex])
				scoreFrame:SetScript("OnLeave", DR.tooltip_OnLeave)
				DR.mainFrame[scoreFrameName] = scoreFrame
			end
			
			-- logic for score calculation and display
			local scoreValueF = ""
			if difficultyData then
				scoreValueF = "------"
			end
			local medalValue = ""

			if difficultyData then
				local currencyID = difficultyData.currencyID
				local silverTime = difficultyData.silverTime
				local goldTime = difficultyData.goldTime

				local medalBronze = "|A:challenges-medal-small-bronze:15:15|a"
				local medalSilver = "|A:challenges-medal-small-silver:15:15|a"
				local medalGold = "|A:challenges-medal-small-gold:15:15|a"
			
				-- purge old data from SVs that is now in DRRaceData.lua
				if silverTime ~= nil then
					if DragonRider_DB.raceDataCollector and DragonRider_DB.raceDataCollector[currencyID] then
						DragonRider_DB.raceDataCollector[currencyID] = nil
					end
				end

				-- calculate scores
				local scoreValue, scorePersonal
				local scoreRaw = C_CurrencyInfo.GetCurrencyInfo(currencyID).quantity
				if scoreRaw and scoreRaw > 0 then
					scorePersonal = scoreRaw / 1000
				end
				scoreValue = scorePersonal
				
				-- handle SVs for account-wide bests
				if DragonRider_DB.raceData == nil then DragonRider_DB.raceData = {} end
				if DragonRider_DB.raceData["Account"] == nil then DragonRider_DB.raceData["Account"] = {} end

				if scoreValue then
					if DragonRider_DB.raceData["Account"][currencyID] == nil then
						DragonRider_DB.raceData["Account"][currencyID] = { score = scoreValue, character = charKey }
					elseif scoreValue < DragonRider_DB.raceData["Account"][currencyID]["score"] then
						DragonRider_DB.raceData["Account"][currencyID]["score"] = scoreValue
						DragonRider_DB.raceData["Account"][currencyID]["character"] = charKey
					end
				end
				
				if DragonRider_DB.useAccountData and DragonRider_DB.raceData["Account"][currencyID] then
					scoreValue = DragonRider_DB.raceData["Account"][currencyID].score
				end
				
				-- determine medal
				if scoreValue and goldTime and scoreValue < goldTime then
					medalValue = medalGold
				elseif scoreValue and silverTime and scoreValue < silverTime then
					medalValue = medalSilver
				elseif scoreValue then
					medalValue = medalBronze
				end
				
				-- format display string
				if scoreValue then
					scoreValueF = string.format("%.3f", scoreValue)
					if medalValue ~= "" then
						scoreValueF = medalValue .. scoreValueF
						if DragonRider_DB.useAccountData and DragonRider_DB.raceData["Account"][currencyID] and DragonRider_DB.raceData["Account"][currencyID].character ~= charKey then
							scoreValueF = scoreValueF .. "*"
						end
					end
				end

				-- set tooltip script
				scoreFrame:SetScript("OnEnter", function(self)
					local accountBestScore, accountBestChar
					if DragonRider_DB.raceData["Account"] and DragonRider_DB.raceData["Account"][currencyID] then
						accountBestScore = DragonRider_DB.raceData["Account"][currencyID].score
						accountBestChar = DragonRider_DB.raceData["Account"][currencyID].character
					end

					local pBest = scorePersonal or "------"
					local aBest = accountBestScore or "------"

					if type(pBest) == "number" and goldTime and pBest > goldTime then
						pBest = RED_FONT_COLOR:WrapTextInColorCode(tostring(pBest))
					end
					if type(aBest) == "number" and goldTime and aBest > goldTime then
						aBest = RED_FONT_COLOR:WrapTextInColorCode(tostring(aBest))
					end
				
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					GameTooltip:AddDoubleLine(L["PersonalBest"], pBest, 1, 1, 1, 1, 1, 1)
					GameTooltip:AddDoubleLine(L["AccountBest"], aBest, 1, 1, 1, 1, 1, 1)
					GameTooltip:AddDoubleLine(L["BestCharacter"], accountBestChar or "------", 1, 1, 1, 1, 1, 1)
					GameTooltip:AddDoubleLine(L["GoldTime"], goldTime or "------", 1, 1, 1, 1, 1, 1)
					GameTooltip:AddDoubleLine(L["SilverTime"], silverTime or "------", 1, 1, 1, 1, 1, 1)
					GameTooltip:Show()
				end)
			else
				-- if no difficulty data, ensure tooltip is cleared
				scoreFrame:SetScript("OnEnter", nil)
			end
			
			scoreFrame:SetText(scoreValueF)
			scoreFrame:SetTextColor(1,1,1)
		end
	end
end

DR.mainFrame.resizeFrames = {}

function DR.mainFrame.DoPopulationStuff()
	-- loop over the DR.RaceData table
	for k, zoneData in ipairs(DR.RaceData) do
		-- get map name from the zoneID in the new data structure
		local MapName = C_Map.GetMapInfo(zoneData.zone).name
		local oneLess = k-1

		if k == 1 then
			DR.mainFrame["backFrame"..k] = CreateFrame("Frame", nil, content1, "BackdropTemplate");
			DR.mainFrame["backFrame"..k]:SetPoint("TOPLEFT", content1, "TOPLEFT", 0, -5);
			DR.mainFrame["backFrame"..k]:SetPoint("TOPRIGHT", DR.mainFrame, "TOPRIGHT", -18, -5);
			DR.mainFrame["titleText"..k] = content1:CreateFontString();
			DR.mainFrame["titleText"..k]:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..k], "TOPLEFT", 10, -5);
			DR.mainFrame["titleText"..k]:SetParent(DR.mainFrame["backFrame"..k])
		else
			DR.mainFrame["backFrame"..k] = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..oneLess], "BackdropTemplate");
			DR.mainFrame["backFrame"..k]:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..oneLess], "BOTTOMLEFT", 0, -10);
			DR.mainFrame["backFrame"..k]:SetPoint("TOPRIGHT", DR.mainFrame["backFrame"..oneLess], "BOTTOMRIGHT", 0, -10);
			DR.mainFrame["titleText"..k] = content1:CreateFontString();
			DR.mainFrame["titleText"..k]:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..k], "TOPLEFT", 10, -5);
			DR.mainFrame["titleText"..k]:SetParent(DR.mainFrame["backFrame"..k])
		end

		DR.mainFrame["backFrame"..k]:SetHeight(65);
		DR.mainFrame["backFrame"..k]:SetBackdrop(DR.mainFrame.backdropInfo);
		DR.mainFrame["backFrame"..k]:SetBackdropColor(0,0,0,.5);

		DR.mainFrame["titleText"..k]:SetFont(STANDARD_TEXT_FONT, 11);
		DR.mainFrame["titleText"..k]:SetText(MapName);
		DR.mainFrame["titleText"..k]:SetTextColor(YELLOW_FONT_COLOR:GetRGBA());

		local leftFrame = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		leftFrame:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..k], "TOPLEFT", 0, -1);
		leftFrame:SetPoint("TOPRIGHT", DR.mainFrame["backFrame"..k], "TOPRIGHT", 0, -1);
		leftFrame:SetHeight(15);
		leftFrame.tex = leftFrame:CreateTexture()
		leftFrame.tex:SetAllPoints(leftFrame)
		--leftFrame.tex:SetColorTexture(1,1,1,.2)

		local middleFrame_1 = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		middleFrame_1:SetPoint("TOP", DR.mainFrame["backFrame"..k], "TOP", -85, 0);
		middleFrame_1:SetWidth(50)
		middleFrame_1:SetHeight(15)
		middleFrame_1.tex = middleFrame_1:CreateTexture()
		middleFrame_1.tex:SetAllPoints(middleFrame_1)
		--middleFrame_1.tex:SetColorTexture(1,0,0,.2)

		local middleFrame_2 = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		middleFrame_2:SetPoint("TOP", DR.mainFrame["backFrame"..k], "TOP", 0, 0);
		middleFrame_2:SetWidth(50)
		middleFrame_2:SetHeight(15)
		middleFrame_2.tex = middleFrame_2:CreateTexture()
		middleFrame_2.tex:SetAllPoints(middleFrame_2)
		--middleFrame_2.tex:SetColorTexture(1,0,1,.2)

		local middleFrame_3 = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		middleFrame_3:SetPoint("TOP", DR.mainFrame["backFrame"..k], "TOP", 0, 0);
		middleFrame_3:SetWidth(50)
		middleFrame_3:SetHeight(15)
		middleFrame_3.tex = middleFrame_3:CreateTexture()
		middleFrame_3.tex:SetAllPoints(middleFrame_3)
		--middleFrame_3.tex:SetColorTexture(0,0,1,.2)

		local middleFrame_4 = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		middleFrame_4:SetPoint("TOP", DR.mainFrame["backFrame"..k], "TOP", 0, 0);
		middleFrame_4:SetWidth(50)
		middleFrame_4:SetHeight(15)
		middleFrame_4.tex = middleFrame_4:CreateTexture()
		middleFrame_4.tex:SetAllPoints(middleFrame_4)
		--middleFrame_4.tex:SetColorTexture(0,1,1,.2)

		local middleFrame_5 = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		middleFrame_5:SetPoint("TOP", DR.mainFrame["backFrame"..k], "TOP", 0, 0);
		middleFrame_5:SetWidth(50)
		middleFrame_5:SetHeight(15)
		middleFrame_5.tex = middleFrame_5:CreateTexture()
		middleFrame_5.tex:SetAllPoints(middleFrame_5)
		--middleFrame_5.tex:SetColorTexture(0,0,0,.2)

		local middleFrame_6 = CreateFrame("Frame", nil, DR.mainFrame["backFrame"..k] )
		middleFrame_6:SetPoint("TOPLEFT", DR.mainFrame["backFrame"..k], "TOP", 0, -1);
		middleFrame_6:SetPoint("TOPRIGHT", DR.mainFrame["backFrame"..k], "TOPRIGHT", 0, -1);
		middleFrame_6:SetHeight(15);
		middleFrame_6.tex = middleFrame_6:CreateTexture()
		middleFrame_6.tex:SetAllPoints(middleFrame_6)
		--middleFrame_6.tex:SetColorTexture(1,1,0,.2)


		leftFrame:SetPoint("TOPRIGHT", middleFrame_1, "TOPLEFT", 0, 0);
		middleFrame_6:SetPoint("TOPLEFT", middleFrame_5, "TOPRIGHT", 0, 0);
		middleFrame_2:SetPoint("TOPLEFT", middleFrame_1, "TOPRIGHT", 0, 0);
		middleFrame_3:SetPoint("TOPLEFT", middleFrame_2, "TOPRIGHT", 0, 0);
		middleFrame_4:SetPoint("TOPLEFT", middleFrame_3, "TOPRIGHT", 0, 0);
		middleFrame_5:SetPoint("TOPLEFT", middleFrame_4, "TOPRIGHT", 0, 0);
		middleFrame_6:SetPoint("TOPLEFT", middleFrame_5, "TOPRIGHT", 0, 0);

		DR.mainFrame.resizeFrames["middleFrame_1"..k] = middleFrame_1
		DR.mainFrame.resizeFrames["middleFrame_2"..k] = middleFrame_2
		DR.mainFrame.resizeFrames["middleFrame_3"..k] = middleFrame_3
		DR.mainFrame.resizeFrames["middleFrame_4"..k] = middleFrame_4
		DR.mainFrame.resizeFrames["middleFrame_5"..k] = middleFrame_5
		DR.mainFrame.resizeFrames["middleFrame_6"..k] = middleFrame_6




		local normalText = content1:CreateFontString();
		normalText:SetFont(STANDARD_TEXT_FONT, 11);
		normalText:SetPoint("TOPLEFT", middleFrame_1, "TOPLEFT", 0, -5);
		normalText:SetText(L["Normal"]);
		normalText:SetParent(DR.mainFrame["backFrame"..k]);
		normalText:SetSize(65,30)
		normalText:SetJustifyH("LEFT")
		normalText:SetJustifyV("TOP")

		local advancedText = content1:CreateFontString();
		advancedText:SetFont(STANDARD_TEXT_FONT, 11);
		advancedText:SetPoint("TOPLEFT", middleFrame_2, "TOPLEFT", 0, -5);
		advancedText:SetText(L["Advanced"]);
		advancedText:SetParent(DR.mainFrame["backFrame"..k]);
		advancedText:SetSize(65,30)
		advancedText:SetJustifyH("LEFT")
		advancedText:SetJustifyV("TOP")

		local reverseText = content1:CreateFontString();
		reverseText:SetFont(STANDARD_TEXT_FONT, 11);
		reverseText:SetPoint("TOPLEFT", middleFrame_3, "TOPLEFT", 0, -5);
		reverseText:SetText(L["Reverse"]);
		reverseText:SetParent(DR.mainFrame["backFrame"..k]);
		reverseText:SetSize(65,30)
		reverseText:SetJustifyH("LEFT")
		reverseText:SetJustifyV("TOP")

		local challengeText = content1:CreateFontString();
		challengeText:SetFont(STANDARD_TEXT_FONT, 11);
		challengeText:SetPoint("TOPLEFT", middleFrame_4, "TOPLEFT", 0, -5);
		challengeText:SetText(L["Challenge"]);
		challengeText:SetParent(DR.mainFrame["backFrame"..k]);
		challengeText:SetSize(65,30)
		challengeText:SetJustifyH("LEFT")
		challengeText:SetJustifyV("TOP")

		local reverseChallText = content1:CreateFontString();
		reverseChallText:SetFont(STANDARD_TEXT_FONT, 11);
		reverseChallText:SetPoint("TOPLEFT", middleFrame_5, "TOPLEFT", 0, -5);
		reverseChallText:SetText(L["ReverseChallenge"]);
		reverseChallText:SetParent(DR.mainFrame["backFrame"..k]);
		reverseChallText:SetSize(65,30)
		reverseChallText:SetJustifyH("LEFT")
		reverseChallText:SetJustifyV("TOP")

		local stormText = content1:CreateFontString();
		stormText:SetFont(STANDARD_TEXT_FONT, 11);
		stormText:SetPoint("TOPLEFT", middleFrame_6, "TOPLEFT", 0, -5);
		stormText:SetText(L["Storm"]);
		stormText:SetParent(DR.mainFrame["backFrame"..k]);
		stormText:SetSize(65,30)
		stormText:SetJustifyH("LEFT")
		stormText:SetJustifyV("TOP")

		DR.mainFrame.multiplayerRace = CreateFrame("Button", nil, DR.mainFrame)
		DR.mainFrame.multiplayerRace:SetPoint("RIGHT", DR.mainFrame.OpenTalentsButton, "LEFT", -10, 0);
		DR.mainFrame.multiplayerRace:SetParent(DR.mainFrame)
		DR.mainFrame.multiplayerRace:SetSize(25,25)
		DR.mainFrame.multiplayerRace.tex = DR.mainFrame.multiplayerRace:CreateTexture()
		DR.mainFrame.multiplayerRace.tex:SetAllPoints(DR.mainFrame.multiplayerRace)
		DR.mainFrame.multiplayerRace.tex:SetAtlas("racing")

		DR.mainFrame.multiplayerRace:SetScript("OnEnter", function(self)
			local activeMapID, activePOI, activePOI_X, activePOI_Y, tooltipInfo = DR.mainFrame.multiplayerRace_TT()
			DR.tooltip_OnEnter(self, tooltipInfo)

			DR.mainFrame.multiplayerRace:SetScript("OnUpdate", function(self)
				local activeMapID, activePOI, activePOI_X, activePOI_Y, tooltipInfo = DR.mainFrame.multiplayerRace_TT()
				DR.tooltip_OnEnter(self, tooltipInfo)
			end);

		end);
		DR.mainFrame.multiplayerRace:SetScript("OnLeave", function(self)
			DR.tooltip_OnLeave();
			DR.mainFrame.multiplayerRace:SetScript("OnUpdate", nil)
		end);

		DR.mainFrame.multiplayerRace:SetScript("OnClick", function(self)
			local activeMapID, activePOI, activePOI_X, activePOI_Y, tooltipInfo = DR.mainFrame.multiplayerRace_TT()
			if not UnitAffectingCombat("player") then
				C_Map.OpenWorldMap(activeMapID);
			end
			C_SuperTrack.SetSuperTrackedMapPin(0, activePOI)
			PlaySound(170270);
		end);


		DR.mainFrame.PopulationData(k)

	end
	DR.mainFrame.isPopulated = true;

end


function DR.mainFrame.Script_OnSizeChanged()
	local width = DR.mainFrame:GetWidth()
	for k, v in pairs(DR.mainFrame.resizeFrames) do
		DR.mainFrame.resizeFrames[k]:SetWidth(width*.115)
	end
end

function DR.mainFrame.Script_OnShow()
	PlaySound(74421);
	DR.mainFrame.Script_OnSizeChanged()
	DR.mainFrame.UpdatePopulation()
	if DragonRider_DB.mainFrameSize ~= nil then
		DR.mainFrame:SetSize(DragonRider_DB.mainFrameSize.width, DragonRider_DB.mainFrameSize.height);
	end
end

DR.mainFrame:SetScript("OnSizeChanged", DR.mainFrame.Script_OnSizeChanged)
DR.mainFrame:SetScript("OnShow", DR.mainFrame.Script_OnShow)
DR.mainFrame:HookScript("OnShow", SetupFade);
DR.mainFrame:HookScript("OnHide", CleanupFade);