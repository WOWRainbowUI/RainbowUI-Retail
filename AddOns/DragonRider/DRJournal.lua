local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

local function Print(...)
	local prefix = string.format("[PH] Dragon Rider" .. ":");
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
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

function DR.CalculateScore(data)
	local charKey = UnitName("player") .. " - " .. GetRealmName()
	local scoreRaw = C_CurrencyInfo.GetCurrencyInfo(data.currencyID).quantity;
	local scorePersonal = (scoreRaw and scoreRaw > 0) and (scoreRaw / 1000) or nil;
	local scoreValue = scorePersonal;

	if not DragonRider_DB.raceData then
		DragonRider_DB.raceData = {};
	end
	if not DragonRider_DB.raceData["Account"] then
		DragonRider_DB.raceData["Account"] = {};
	end

	if scoreValue then
		if not DragonRider_DB.raceData["Account"][data.currencyID] then
			DragonRider_DB.raceData["Account"][data.currencyID] = { score = scoreValue, character = charKey };
		elseif scoreValue < DragonRider_DB.raceData["Account"][data.currencyID].score then
			DragonRider_DB.raceData["Account"][data.currencyID].score = scoreValue;
			DragonRider_DB.raceData["Account"][data.currencyID].character = charKey;
		end
	end

	local aBest = "------";
	local aChar = "------";
	if DragonRider_DB.raceData["Account"][data.currencyID] then
		aBest = DragonRider_DB.raceData["Account"][data.currencyID].score;
		aChar = DragonRider_DB.raceData["Account"][data.currencyID].character;
		if DragonRider_DB.useAccountData then
			scoreValue = aBest;
		end
	end

	local medalValue = "";
	if scoreValue then
		if data.goldTime and scoreValue < data.goldTime then
			medalValue = "|A:challenges-medal-small-gold:15:15|a";
		elseif data.silverTime and scoreValue < data.silverTime then
			medalValue = "|A:challenges-medal-small-silver:15:15|a";
		else
			medalValue = "|A:challenges-medal-small-bronze:15:15|a";
		end
	end

	local scoreValueF = "------";
	if scoreValue then
		scoreValueF = string.format("%.3f", scoreValue);
		if medalValue ~= "" then
			scoreValueF = medalValue .. scoreValueF;
			if DragonRider_DB.useAccountData and aChar ~= charKey then
				scoreValueF = scoreValueF .. "*";
			end
		end
	end

	local pBestFormat = scorePersonal or "------";
	if type(pBestFormat) == "number" and data.goldTime and pBestFormat > data.goldTime then
		pBestFormat = RED_FONT_COLOR:WrapTextInColorCode(tostring(pBestFormat));
	end
	
	local aBestFormat = aBest
	if type(aBestFormat) == "number" and data.goldTime and aBestFormat > data.goldTime then
		aBestFormat = RED_FONT_COLOR:WrapTextInColorCode(tostring(aBestFormat));
	end

	return scoreValueF, pBestFormat, aBestFormat, aChar;
end

DR.selectedZoneMapID = nil;
DR.searchQuery = "";

function DR.GetZoneDataList()
	local dataList = {};
	local searchLower = string.lower(DR.searchQuery);

	for _, continentData in ipairs(DR.RaceData) do
		local mapID = continentData.zone;
		local zoneName = C_Map.GetMapInfo(mapID).name or UNKNOWN;
		
		if DR.searchQuery == "" or string.find(string.lower(zoneName), searchLower) then
			table.insert(dataList, {
				isHeader = true,
				text = zoneName,
				mapID = mapID
			});
		end
	end
	return dataList;
end

DR.pendingNameRefresh = false;

function DR.GetRaceDataList()
	local dataList = {};
	local searchLower = string.lower(DR.searchQuery);
	
	DR.pendingNameRefresh = false;
	
	local difficultyOrder = {
		{key = "normal", name = L["Normal"]},
		{key = "advanced", name = L["Advanced"]},
		{key = "reverse", name = L["Reverse"]},
		{key = "challenge", name = L["Challenge"]},
		{key = "reversechallenge", name = L["ReverseChallenge"]},
		{key = "storm", name = L["Storm"]},
	};

	for _, continentData in ipairs(DR.RaceData) do
		local mapID = continentData.zone;
		local zoneName = C_Map.GetMapInfo(mapID).name or UNKNOWN;
		
		if (DR.searchQuery ~= "" or mapID == DR.selectedZoneMapID) then
			for _, raceInfo in ipairs(continentData.races) do
				
				local questTitle = DR.QuestTitleFromID[raceInfo.questID];
				if not questTitle then
					DR.pendingNameRefresh = true;
				end
				
				local questName = questTitle or "...";
				local questNameLower = string.lower(questName);
				local zoneNameLower = string.lower(zoneName);
				
				if DR.searchQuery == "" or string.find(questNameLower, searchLower) or string.find(zoneNameLower, searchLower) then
					
					table.insert(dataList, {
						isSubHeader = true,
						text = questName,
						mapID = mapID,
						mapPOI = raceInfo.mapPOI
					});

					for _, diff in ipairs(difficultyOrder) do
						local diffData = raceInfo[diff.key];
						if diffData then
							table.insert(dataList, {
								type = "difficulty",
								name = diff.name,
								currencyID = diffData.currencyID,
								silverTime = diffData.silverTime,
								goldTime = diffData.goldTime
							});
						end
					end
				end
			end
		end
	end
	
	return dataList;
end

DR.mainFrame = CreateFrame("Frame", "DragonRiderMainFrame", UIParent, "PortraitFrameTemplate")
tinsert(UISpecialFrames, DR.mainFrame:GetName())
local DRportrait = DR.mainFrame.PortraitContainer.portrait
DRportrait:SetTexCoord(0.03, 1, 0.03, 1) -- centers the icon a little bit more, since there was a large gap in the top / left
DRportrait:SetTexture("Interface\\ICONS\\Ability_DragonRiding_Glyph01")

local DragonRiderPortraitMixin = {};

DragonRiderPortraitMixin.SoundFileList = {
	4621637, 4621639, 4621641, 4621643, 4621645,
	4621647, 4621649, 4621651, 4621653, 4621655,
	4621657, 4621659, 4621661, 4621663, 4621665,
	4621667, 4621669,
};

function DragonRiderPortraitMixin:OnLoad()
	self.clickCount = 0;
	self.clickThreshold = 10;
	self.timeFrame = 0.2;
	self.lastClickTime = 0;
	self:RegisterForClicks("AnyDown", "AnyUp");
end

function DragonRiderPortraitMixin:OnClick(button, down)
	if button == "RightButton" then
		if not down and DR.ToggleChangelog then
			DR.ToggleChangelog();
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end
	end

	if button then
		if not down then
			self.Icon:SetTexCoord(0.03, 1, 0.03, 1);
		else
			self.Icon:SetTexCoord(0.05, 0.98, 0.05, 0.98);
		end

		if down then return; end

		local currentTime = GetTime();
		if currentTime - self.lastClickTime > self.timeFrame then
			self:ResetClicks();
		end

		self.clickCount = self.clickCount + 1;
		self.lastClickTime = currentTime;

		if self.clickCount >= self.clickThreshold then
			self:ResetClicks();
			self:PlaySecretSound();
		end
	end
end

function DragonRiderPortraitMixin:ResetClicks()
	self.clickCount = 0;
end

function DragonRiderPortraitMixin:PlaySecretSound()
	local sound = self.SoundFileList[math.random(1, #self.SoundFileList)];
	PlaySoundFile(sound, "SFX");
end

local portraitButton = CreateFrame("Button", nil, DR.mainFrame.PortraitContainer);
portraitButton:SetAllPoints(DRportrait);
portraitButton.Icon = DRportrait;
portraitButton:EnableMouse(true);

DR.mainFrame.portraitButton = portraitButton;

local glowFrame = CreateFrame("Frame", nil, DR.mainFrame.PortraitContainer);
glowFrame:SetPoint("CENTER", DRportrait, "CENTER");
glowFrame:SetSize(85, 85);
glowFrame:SetFrameLevel(800);

glowFrame.Glow = glowFrame:CreateTexture();
glowFrame.Glow:SetAllPoints(glowFrame);
glowFrame.Glow:SetTexture(136477); -- interface/minimap/ui-minimap-zoombutton-highlight.blp
glowFrame.Glow:SetBlendMode("ADD");
glowFrame.Glow:SetVertexColor(1, 1, 1, 1);
glowFrame.Glow:Hide();

glowFrame.PulseAnim = glowFrame.Glow:CreateAnimationGroup();
glowFrame.PulseAnim:SetLooping("BOUNCE");
local alphaAnim = glowFrame.PulseAnim:CreateAnimation("Alpha");
alphaAnim:SetFromAlpha(0.2);
alphaAnim:SetToAlpha(1.0);
alphaAnim:SetDuration(0.75);

DR.mainFrame.portraitButton.Glow = glowFrame.Glow;
DR.mainFrame.portraitButton.PulseAnim = glowFrame.PulseAnim;

FrameUtil.SpecializeFrameWithMixins(portraitButton, DragonRiderPortraitMixin);
portraitButton:OnLoad();
portraitButton:SetScript("OnClick", portraitButton.OnClick);
portraitButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	GameTooltip:SetText(ITEM_READABLE, 0.4, 0.8, 1);
	GameTooltip:Show();
end);
portraitButton:SetScript("OnLeave", function()
	GameTooltip:Hide();
end);

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

local function UpdatePortraitTooltip(self)
	local SeasonID = PlayerGetTimerunningSeasonID()
	if SeasonID or IsShiftKeyDown() then
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		AddTimerunnerLines(GameTooltip)
		GameTooltip:Show()
	else
		GameTooltip:Hide()
	end
end


DR.mainFrame.portraitTooltipThing:SetScript("OnEvent", function(self, event)
	if event == "MODIFIER_STATE_CHANGED" and self:IsMouseOver() then
		UpdatePortraitTooltip(self)
	end
end)

DR.mainFrame.portraitTooltipThing:SetScript("OnEnter", function(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	UpdatePortraitTooltip(self)
end)

DR.mainFrame.portraitTooltipThing:SetScript("OnLeave", function(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
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

function DR.mainFrame.Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	for i = 1, self:GetParent().numTabs do
		local tab = _G[self:GetParent():GetName() .. "Tab" .. i];
		if tab and tab.content then
			tab.content:Hide();
		end
	end

	if self.content then
		self.content:Show();
	end
	PlaySound(841);
end

function DR.mainFrame.SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;
	local contents = {};
	local frameName = frame:GetName();

	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName .. "Tab" .. i, frame, "PanelTabButtonTemplate");
		tab:SetID(i);
		tab:SetText(select(i, ...));
		tab:SetScript("OnClick", DR.mainFrame.Tab_OnClick);

		tab.content = CreateFrame("Frame", nil, frame);
		tab.content:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -65);
		tab.content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 26);
		tab.content:Hide();

		table.insert(contents, tab.content);

		if (i == 1) then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 11, 2);
		else
			tab:SetPoint("TOPLEFT", _G[frameName .. "Tab" .. (i-1)] , "TOPRIGHT", 3, 0);
		end
	end

	DR.mainFrame.Tab_OnClick(_G[frameName .. "Tab1"]);
	return unpack(contents);
end

local content1, content2 = DR.mainFrame.SetTabs(DR.mainFrame, 2, L["Score"], L["Settings"])

local settingsTabButton = _G[DR.mainFrame:GetName() .. "Tab2"]

if settingsTabButton then
	settingsTabButton:SetScript("OnClick", function()
		if DR.SettingsCategoryID and not UnitAffectingCombat("player") then
			Settings.OpenToCategory(DR.SettingsCategoryID)
		end
	end)
end

DR.mainFrame.Bg:Hide();

DR.mainFrame.backgroundTex = DR.mainFrame:CreateTexture(nil, "BACKGROUND", nil, 0);
DR.mainFrame.backgroundTex:SetPoint("TOPLEFT", 2, -2);
DR.mainFrame.backgroundTex:SetPoint("BOTTOMRIGHT", -2, 2);
DR.mainFrame.backgroundTex:SetAtlas("Dragonflight-Landingpage-Background");

local searchBox = CreateFrame("EditBox", "DragonRiderSearchBox", content1, "SearchBoxTemplate");
searchBox:SetPoint("TOPLEFT", 15, -15);
searchBox:SetSize(145, 20);
searchBox:SetAutoFocus(false);
searchBox:SetScript("OnTextChanged", function(self)
	SearchBoxTemplate_OnTextChanged(self);
	DR.searchQuery = self:GetText();
	DR.mainFrame.UpdatePopulation();
end);

local zoneScroll = CreateFrame("Frame", nil, content1, "WowScrollBoxList");
zoneScroll:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -5, -5);
zoneScroll:SetPoint("BOTTOMRIGHT", content1, "BOTTOMLEFT", 160, 0);

local zoneScrollBar = CreateFrame("EventFrame", nil, content1, "MinimalScrollBar");
zoneScrollBar:SetPoint("TOPLEFT", zoneScroll, "TOPRIGHT", 10, 0);
zoneScrollBar:SetPoint("BOTTOMLEFT", zoneScroll, "BOTTOMRIGHT", 10, 0);

local zoneScrollBg = content1:CreateTexture(nil, "BACKGROUND", nil, -2);
zoneScrollBg:SetPoint("TOPLEFT", zoneScroll, "TOPLEFT", -10, 2);
zoneScrollBg:SetPoint("BOTTOMRIGHT", zoneScrollBar, "BOTTOMRIGHT", -15, -2);
zoneScrollBg:SetAtlas("GO-bg-Group");
zoneScrollBg:SetTextureSliceMargins(10, 10, 10, 10);
zoneScrollBg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched);
zoneScrollBg:SetAlpha(.5);

local zoneDP = CreateDataProvider();
local zoneView = CreateScrollBoxListLinearView();
zoneView:SetElementExtent(30);

zoneView:SetElementInitializer("Button", function(row, data)
	if not row.isInitialized then
		row.bg = row:CreateTexture(nil, "BACKGROUND");
		row.bg:SetAllPoints();
		row.bg:SetTexCoord(0, 1, 0, 1);
		row.bg:SetAtlas("QuestLog-tab");
		
		row.highlight = row:CreateTexture(nil, "HIGHLIGHT");
		row.highlight:SetAllPoints();
		row.highlight:SetColorTexture(1, 1, 1, 0.1);

		row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		row.title:SetPoint("LEFT", row, "LEFT", 10, 0);
		row.isInitialized = true;
	end

	row.title:SetText(data.text);
	
	if DR.selectedZoneMapID == data.mapID and DR.searchQuery == "" then
		row.title:SetTextColor(1, 0.82, 0);
		row.bg:SetVertexColor(1, 1, 1, 1);
	else
		row.title:SetTextColor(0.8, 0.8, 0.8);
		row.bg:SetVertexColor(0.6, 0.6, 0.6, 0.5);
	end

	row:SetScript("OnClick", function()
		DR.selectedZoneMapID = data.mapID;
		DR.searchQuery = "";
		searchBox:SetText("");
		DR.mainFrame.UpdatePopulation();
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end);
end);

ScrollUtil.InitScrollBoxListWithScrollBar(zoneScroll, zoneScrollBar, zoneView);
zoneScroll:SetDataProvider(zoneDP);

local raceScroll = CreateFrame("Frame", nil, content1, "WowScrollBoxList");
raceScroll:SetPoint("TOPLEFT", zoneScrollBar, "TOPRIGHT", 10, 0);
raceScroll:SetPoint("BOTTOMRIGHT", content1, "BOTTOMRIGHT", -20, 5);

local raceScrollBar = CreateFrame("EventFrame", nil, content1, "MinimalScrollBar");
raceScrollBar:SetPoint("TOPLEFT", raceScroll, "TOPRIGHT", 10, 0);
raceScrollBar:SetPoint("BOTTOMLEFT", raceScroll, "BOTTOMRIGHT", 10, 0);

local raceScrollBg = content1:CreateTexture(nil, "BACKGROUND", nil, -2);
raceScrollBg:SetPoint("TOPLEFT", raceScroll, "TOPLEFT", -5, 2);
raceScrollBg:SetPoint("BOTTOMRIGHT", raceScrollBar, "BOTTOMRIGHT", -15, -2);
raceScrollBg:SetAtlas("GO-bg-Group");
raceScrollBg:SetTextureSliceMargins(10, 10, 10, 10);
raceScrollBg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched);
raceScrollBg:SetAlpha(.5);

local raceDP = CreateDataProvider();
local raceView = CreateScrollBoxListLinearView();

raceView:SetElementExtentCalculator(function(dataIndex, data)
	if data.isSubHeader then
		return 28;
	end
	return 20;
end);

raceView:SetElementInitializer("Button", function(row, data)
	if not row.isInitialized then
		row.bg = row:CreateTexture(nil, "BACKGROUND");
		row.bg:SetAllPoints();
		
		row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal");
		row.scoreText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
		
		row.isInitialized = true;
	end

	row.bg:Hide();
	row.scoreText:Hide();
	row:SetScript("OnEnter", nil);
	row:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	row:SetScript("OnClick", nil);
	row:EnableMouse(true);

	if data.isSubHeader then
		row.title:SetPoint("LEFT", row, "LEFT", 10, 0);
		row.title:SetText(data.text);
		row.title:SetFontObject("GameFontNormal");
		row.title:SetTextColor(0.4, 0.8, 1);
		
		row.bg:SetTexCoord(0, 1, 0, 1);
		row.bg:SetAtlas("CreditsScreen-Highlight");
		row.bg:Show();
		
		row:SetScript("OnClick", function()
			if not UnitAffectingCombat("player") and data.mapID then
				C_Map.OpenWorldMap(data.mapID);
			end
			if data.mapPOI then
				C_SuperTrack.SetSuperTrackedMapPin(0, data.mapPOI);
				PlaySound(170270);
			end
		end);

		row:SetScript("OnEnter", function(self)
			local questName = data.text or "";
			local trackedTooltip = "|A:Waypoint-MapPin-Tracked:15:15|a " .. (VOICE_CHAT_CHANNEL_INACTIVE_TOOLTIP_INSTRUCTIONS);
			
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(questName, 0.4, 0.8, 1);
			GameTooltip:AddLine(trackedTooltip, 1, 0.82, 0);
			GameTooltip:Show();
		end)

	elseif data.type == "difficulty" then
		row.title:SetPoint("LEFT", row, "LEFT", 25, 0);
		row.title:SetText(data.name)
		row.title:SetFontObject("GameFontHighlightSmall");
		row.title:SetTextColor(0.8, 0.8, 0.8);
		
		row.scoreText:Show();
		row.scoreText:SetPoint("RIGHT", row, "RIGHT", -10, 0);

		local scoreValueF, pBest, aBest, aChar = DR.CalculateScore(data);
		row.scoreText:SetText(scoreValueF);

		row:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP");
			GameTooltip:AddDoubleLine(L["PersonalBest"], pBest, 1, 1, 1, 1, 1, 1);
			GameTooltip:AddDoubleLine(L["AccountBest"], aBest, 1, 1, 1, 1, 1, 1);
			GameTooltip:AddDoubleLine(L["BestCharacter"], aChar, 1, 1, 1, 1, 1, 1);
			GameTooltip:AddDoubleLine(L["GoldTime"], data.goldTime or "------", 1, 1, 1, 1, 1, 1);
			GameTooltip:AddDoubleLine(L["SilverTime"], data.silverTime or "------", 1, 1, 1, 1, 1, 1);
			GameTooltip:Show();
		end);
	end
end);

ScrollUtil.InitScrollBoxListWithScrollBar(raceScroll, raceScrollBar, raceView);
raceScroll:SetDataProvider(raceDP);

function DR.mainFrame.UpdatePopulation()
	if not DR.selectedZoneMapID and DR.RaceData[1] then
		DR.selectedZoneMapID = DR.RaceData[1].zone;
	end

	local zoneData = DR.GetZoneDataList();
	local currentZoneScroll = zoneScroll:GetScrollPercentage() or 0;
	zoneDP:Flush();
	zoneDP:InsertTable(zoneData);
	zoneScroll:SetScrollPercentage(currentZoneScroll);

	local raceData = DR.GetRaceDataList();
	local currentRaceScroll = raceScroll:GetScrollPercentage() or 0;
	raceDP:Flush();
	raceDP:InsertTable(raceData);
	raceScroll:SetScrollPercentage(currentRaceScroll);
	
	--sometimes names aren't loaded, i don't request them all in 1 go like before
	if DR.pendingNameRefresh then
		if not DR.nameRefreshTimer then
			DR.nameRefreshTimer = C_Timer.NewTimer(0.5, function()
				DR.nameRefreshTimer = nil;
				if DR.mainFrame:IsShown() then
					DR.mainFrame.UpdatePopulation();
				end
			end)
		end
	end
end


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

DR.mainFrame.accountAll_Checkbox = CreateFrame("CheckButton", nil, DR.mainFrame, "UICheckButtonTemplate");
DR.mainFrame.accountAll_Checkbox:SetPoint("TOPLEFT", DR.mainFrame, "TOPLEFT", 55, -25);
DR.mainFrame.accountAll_Checkbox:SetScript("OnShow", function(self)
	self:SetChecked(DragonRider_DB and DragonRider_DB.useAccountData or false);
end)
DR.mainFrame.accountAll_Checkbox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		PlaySound(856);
		DragonRider_DB.useAccountData = true;
		DR.mainFrame.UpdatePopulation();
	else
		PlaySound(857);
		DragonRider_DB.useAccountData = false;
		DR.mainFrame.UpdatePopulation();
	end
end);
DR.mainFrame.accountAll_Checkbox.text = DR.mainFrame.accountAll_Checkbox:CreateFontString()
DR.mainFrame.accountAll_Checkbox.text:SetFont(STANDARD_TEXT_FONT, 11)
DR.mainFrame.accountAll_Checkbox.text:SetPoint("LEFT", DR.mainFrame.accountAll_Checkbox, "RIGHT", 0, 0)
DR.mainFrame.accountAll_Checkbox.text:SetText(L["UseAccountScores"])
DR.mainFrame.accountAll_Checkbox.text:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip_AddNormalLine(GameTooltip, L["UseAccountScoresTT"]);
	GameTooltip:Show();
end);
DR.mainFrame.accountAll_Checkbox.text:SetScript("OnLeave", function() GameTooltip:Hide(); end);

DR.mainFrame.accountAll_Checkbox:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip_AddNormalLine(GameTooltip, L["UseAccountScoresTT"]);
	GameTooltip:Show();
end);
DR.mainFrame.accountAll_Checkbox:SetScript("OnLeave", function() GameTooltip:Hide(); end);

--DR.mainFrame.backgroundTex = DR.mainFrame.ScrollFrame:CreateTexture()
--DR.mainFrame.backgroundTex:SetAllPoints(DR.mainFrame.ScrollFrame)
--DR.mainFrame.backgroundTex:SetAtlas("Dragonflight-Landingpage-Background")
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
				
				local mask = DR.mainFrame["WorldQuestList_"..v]:CreateMaskTexture();
				mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
				mask:SetAllPoints(DR.mainFrame["WorldQuestList_"..v].texmiddle);
				DR.mainFrame["WorldQuestList_"..v].texmiddle:AddMaskTexture(mask);

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
					
					GameTooltip:SetOwner(self, "ANCHOR_TOP");
					GameTooltip_AddNormalLine(GameTooltip, taskInfo);
					GameTooltip:Show();
				end);

			end);
			DR.mainFrame["WorldQuestList_"..v]:SetScript("OnLeave", function(self)
				GameTooltip:Hide();
				self:SetScript("OnUpdate", nil);
			end);
		end
	end
end

DR.mainFrame:RegisterEvent("QUEST_REMOVED")
DR.mainFrame:SetScript("OnEvent", DR.mainFrame.WorldQuestHandler)

DR.mainFrame.OpenTalentsButton = CreateFrame("Button", nil, DR.mainFrame);
DR.mainFrame.OpenTalentsButton:SetPoint("TOPRIGHT", DR.mainFrame, "TOPRIGHT", -10, -25);
DR.mainFrame.OpenTalentsButton:SetSize(30, 30);

DR.mainFrame.OpenTalentsButton.Icon = DR.mainFrame.OpenTalentsButton:CreateTexture(nil, "ARTWORK");
DR.mainFrame.OpenTalentsButton.Icon:SetAllPoints();
DR.mainFrame.OpenTalentsButton.Icon:SetTexture("Interface\\ICONS\\Ability_DragonRiding_Glyph01");

DR.mainFrame.OpenTalentsButton:SetNormalAtlas("UI-HUD-ActionBar-IconFrame");
DR.mainFrame.OpenTalentsButton:SetPushedAtlas("UI-HUD-ActionBar-IconFrame-Down");
DR.mainFrame.OpenTalentsButton:SetHighlightAtlas("UI-HUD-ActionBar-IconFrame-Mouseover");

DR.mainFrame.OpenTalentsButton:SetScript("OnClick", function(self)
	GenericTraitUI_LoadUI();
	GenericTraitFrame:SetConfigIDBySystemID(Constants.MountDynamicFlightConsts.TRAIT_SYSTEM_ID);
	GenericTraitFrame:SetTreeID(Constants.MountDynamicFlightConsts.TREE_ID);
	ToggleFrame(GenericTraitFrame);
end);

DR.mainFrame.OpenTalentsButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(L["DragonridingTalents"], 1, 1, 1);
	GameTooltip:AddLine(L["OpenDragonridingTalents"], nil, nil, nil, true);
	GameTooltip:Show();
end)

DR.mainFrame.OpenTalentsButton:SetScript("OnLeave", function()
	GameTooltip:Hide();
end)

DR.mainFrame.multiplayerRace = CreateFrame("Button", nil, DR.mainFrame);
DR.mainFrame.multiplayerRace:SetPoint("RIGHT", DR.mainFrame.OpenTalentsButton, "LEFT", -10, 0);
DR.mainFrame.multiplayerRace:SetSize(25,25);
DR.mainFrame.multiplayerRace.tex = DR.mainFrame.multiplayerRace:CreateTexture();
DR.mainFrame.multiplayerRace.tex:SetAllPoints(DR.mainFrame.multiplayerRace);
DR.mainFrame.multiplayerRace.tex:SetAtlas("racing");

DR.mainFrame.multiplayerRace:SetScript("OnEnter", function(self)
	local activeMapID, activePOI, activePOI_X, activePOI_Y, tooltipInfo = DR.mainFrame.multiplayerRace_TT();
	GameTooltip:SetOwner(self, "ANCHOR_TOP");
	GameTooltip_AddNormalLine(GameTooltip, tooltipInfo);
	GameTooltip:Show();

	DR.mainFrame.multiplayerRace:SetScript("OnUpdate", function(self)
		local _, _, _, _, info = DR.mainFrame.multiplayerRace_TT();
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip_AddNormalLine(GameTooltip, info);
		GameTooltip:Show();
	end);
end);

DR.mainFrame.multiplayerRace:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
	self:SetScript("OnUpdate", nil);
end);

DR.mainFrame.multiplayerRace:SetScript("OnClick", function(self)
	local activeMapID, activePOI, activePOI_X, activePOI_Y, tooltipInfo = DR.mainFrame.multiplayerRace_TT();
	if not UnitAffectingCombat("player") then
		C_Map.OpenWorldMap(activeMapID);
	end
	C_SuperTrack.SetSuperTrackedMapPin(0, activePOI);
	PlaySound(170270);
end);

DR.mainFrame.resizeFrames = {};

function DR.mainFrame.Script_OnShow()
	PlaySound(74421);
	DR.mainFrame.UpdatePopulation();
	DR.mainFrame.WorldQuestHandler();
	if DragonRider_DB.mainFrameSize ~= nil then
		DR.mainFrame:SetSize(DragonRider_DB.mainFrameSize.width, DragonRider_DB.mainFrameSize.height);
	end
end

DR.mainFrame:SetScript("OnShow", DR.mainFrame.Script_OnShow);
DR.mainFrame:HookScript("OnShow", function(self)
	SetupFade(self);
	if DragonRider_DB and not DragonRider_DB.hasSeenChangelog then
		DR.mainFrame.portraitButton.Glow:Show();
		DR.mainFrame.portraitButton.PulseAnim:Play();
	else
		if DR.mainFrame.portraitButton.Glow then
			DR.mainFrame.portraitButton.Glow:Hide();
			DR.mainFrame.portraitButton.PulseAnim:Stop();
		end
	end
end);
DR.mainFrame:SetScript("OnHide", function()
	PlaySound(74423);
	if DR.HideChangelog then
		DR.HideChangelog();
	end
end);
DR.mainFrame:HookScript("OnHide", CleanupFade);

local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");

loader:SetScript("OnEvent", function(self, event, addonName)
	if addonName == "DragonRider" then
		DR.mainFrame.UpdatePopulation();
	end
end);