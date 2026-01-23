local MAJOR, MINOR = "EZBlizzardUiPopups", 2
local EZBUP = LibStub:NewLibrary(MAJOR, MINOR)
if not EZBUP then
    -- A newer version is already loaded
    return
end

local XITK = LibStub("XamInsightToolKit")
local EZBUP_DATA = LibStub("EZBlizzardUiPopups_Data")

local _, _, _, tocversion = GetBuildInfo()

local DEFAULT_CAMERAID = 82
local DEFAULT_ANIMKIT = 0
local DEFAULT_ANIMATION = 60
local MIN_SPEACH_DURATION = 3

local EZBlizzUiPop_WoWRetail = tocversion >= 110000

function EZBUP.PlayNPCRandomSound(creatureID, channel, playSound)
	if playSound then
		local soundFileIDBank = EZBUP_DATA.SoundFileIDBank[creatureID] and EZBUP_DATA.SoundFileIDBank[creatureID].soundQuotes
		return XITK.PlayRandomSound(soundFileIDBank, channel, playSound)
	end
	return nil
end

-- TOASTS - Thanks to Tuhljin from Overachiever !
-----------

--local function alertOnClick(self, ...)
local function EZBlizzUiPop_AlertFrame_OnClick(self, ...)
		if (self.onClick) then
		if (AlertFrame_OnClick(self, ...)) then  return;  end -- Handle right-clicking to hide the frame.
		self.onClick(self, ...)
	elseif (self.onClick == false) then
		AlertFrame_OnClick(self, ...)
	else
		AchievementAlertFrame_OnClick(self, ...)
	end
end

local function EZBlizzUiPop_AlertFrame_SetUp(frame, AchievementInfo)
	frame.onClick = AchievementInfo.onClick
	frame:SetScript("OnClick", EZBlizzUiPop_AlertFrame_OnClick)
	
	local displayName = frame.Name;
	local shieldPoints = frame.Shield.Points;
	local shieldIcon = frame.Shield.Icon;
	local unlocked = frame.Unlocked;

	unlocked:SetPoint("TOP", 7, -23);

	displayName:SetText(AchievementInfo.name or "");

	AchievementShield_SetPoints(AchievementInfo.points or 0, shieldPoints, GameFontNormal, GameFontNormalSmall);
	if ( AchievementInfo.isGuildAch ) then
		local guildName = frame.GuildName;
		local guildBorder = frame.GuildBorder;
		local guildBanner = frame.GuildBanner;
		shieldPoints:Show();
		shieldIcon:Show();
		frame:SetHeight(104);
		local background = frame.Background;
		local iconBorder = frame.Icon.Overlay;
		if EZBlizzUiPop_WoWRetail then
			background:SetAtlas("ui-achievement-guild-background", TextureKitConstants.UseAtlasSize);
			iconBorder:SetAtlas("ui-achievement-guild-iconframe", TextureKitConstants.UseAtlasSize);
			iconBorder:SetPoint("CENTER", 0, 0);
			frame.Icon:SetPoint("TOPLEFT", 0, -25);
			frame.Icon.Texture:SetPoint("CENTER", -1, -2);
			frame.Shield:SetPoint("TOPRIGHT", -12, -25);
			shieldPoints:SetPoint("CENTER", 2, -2);
			unlocked:SetPoint("TOP", 0, -38);
			frame.glow:SetAtlas("ui-achievement-guild-glow", TextureKitConstants.UseAtlasSize);
			frame.shine:SetAtlas("ui-achievement-guild-shine", TextureKitConstants.UseAtlasSize);
		else -- not Retail
			frame.oldCheevo = nil
			background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			background:SetTexCoord(0.00195313, 0.62890625, 0.00195313, 0.19140625);
			background:SetPoint("TOPLEFT", -2, 2);
			background:SetPoint("BOTTOMRIGHT", 8, 8);
			iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			iconBorder:SetTexCoord(0.25976563,0.40820313,0.50000000,0.64453125);
			iconBorder:SetPoint("CENTER", 0, 1);
			frame.Icon:SetPoint("TOPLEFT", -26, 2);
			displayName:SetPoint("BOTTOMLEFT", 79, 37);
			displayName:SetPoint("BOTTOMRIGHT", -79, 37);
			frame.Shield:SetPoint("TOPRIGHT", -15, -28);
			shieldPoints:SetPoint("CENTER", 7, 5);
			shieldIcon:SetTexCoord(0, 0.5, 0.5, 1);
			unlocked:SetPoint("TOP", -1, -36);
			frame.glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			frame.glow:SetTexCoord(0.00195313, 0.74804688, 0.19531250, 0.49609375);
			frame.shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Guild");
			frame.shine:SetTexCoord(0.75195313, 0.91601563, 0.19531250, 0.35937500);
		end
		shieldPoints:SetVertexColor(0, 1, 0);
		unlocked:SetText(AchievementInfo.toptext or GUILD_ACHIEVEMENT_UNLOCKED);
		guildName:Show();
		guildBanner:Show();
		guildBorder:Show();
		frame.shine:SetPoint("BOTTOMLEFT", 0, 16);
		guildName:SetText(GetGuildInfo("player"));
		SetSmallGuildTabardTextures("player", nil, guildBanner, guildBorder);
	else
		shieldPoints:Show();
		shieldIcon:Show();
		local background = frame.Background;
		local iconBorder = frame.Icon.Overlay;
		if EZBlizzUiPop_WoWRetail then
			frame:SetHeight(101);
			background:SetAtlas("ui-achievement-alert-background", TextureKitConstants.UseAtlasSize);
			iconBorder:SetAtlas("ui-achievement-iconframe", TextureKitConstants.UseAtlasSize);
			iconBorder:SetPoint("CENTER", -1, 1);
			frame.Icon:SetPoint("TOPLEFT", -4, -15);
			frame.Shield:SetPoint("TOPRIGHT", -8, -15);
			shieldPoints:SetPoint("CENTER", 2, -2);
			frame.glow:SetAtlas("ui-achievement-glow-glow", TextureKitConstants.UseAtlasSize);
			frame.shine:SetAtlas("ui-achievement-glow-shine", TextureKitConstants.UseAtlasSize);
		else -- not Retail
			frame.oldCheevo = nil
			frame:SetHeight(88);
			background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background");
			background:SetTexCoord(0, 0.605, 0, 0.703);
			background:SetPoint("TOPLEFT", 0, 0);
			background:SetPoint("BOTTOMRIGHT", 0, 0);
			iconBorder:SetTexture("Interface\\AchievementFrame\\UI-Achievement-IconFrame");
			iconBorder:SetTexCoord(0, 0.5625, 0, 0.5625);
			iconBorder:SetPoint("CENTER", -1, 2);
			frame.Icon:SetPoint("TOPLEFT", -26, 16);
			displayName:SetPoint("BOTTOMLEFT", 72, 36);
			displayName:SetPoint("BOTTOMRIGHT", -60, 36);
			frame.Shield:SetPoint("TOPRIGHT", -10, -13);
			shieldPoints:SetPoint("CENTER", 7, 2);
			shieldIcon:SetTexCoord(0, 0.5, 0, 0.45);
			frame.glow:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow");
			frame.glow:SetTexCoord(0, 0.78125, 0, 0.66796875);
			frame.shine:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Glow");
			frame.shine:SetTexCoord(0.78125, 0.912109375, 0, 0.28125);
		end
		shieldPoints:SetVertexColor(1, 1, 1);
		unlocked:SetPoint("TOP", 7, -23);
		unlocked:SetText(AchievementInfo.toptext or ACHIEVEMENT_UNLOCKED);
		frame.GuildName:Hide();
		frame.GuildBorder:Hide();
		frame.GuildBanner:Hide();
		frame.shine:SetPoint("BOTTOMLEFT", 0, 8);

		-- Center all text horizontally if the achievement has been earned and there's no points display
		if (AchievementInfo.alreadyEarned or AchievementInfo.points == 0) then
			if EZBlizzUiPop_WoWRetail then
				unlocked:SetPoint("TOP", 27, -23);
			else -- not Retail
				unlocked:SetPoint("TOP", 15, -23);
				--displayName:SetPoint("TOP", unlocked, "BOTTOM", 0, -10);
			end
		end
	end

	shieldPoints:SetShown(not AchievementInfo.alreadyEarned);
	shieldIcon:SetShown(not AchievementInfo.alreadyEarned);

	if ( AchievementInfo.points == 0 ) then
		if EZBlizzUiPop_WoWRetail then
			--shieldIcon:SetAtlas("UI-Achievement-Shield-NoPoints", TextureKitConstants.UseAtlasSize);
			shieldPoints:Hide()
			shieldIcon:Hide()
		else -- not Retail
			shieldIcon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
		end
	else
		if EZBlizzUiPop_WoWRetail then
			--shieldIcon:SetAtlas("ui-achievement-shield-2", TextureKitConstants.UseAtlasSize);
			if AchievementInfo.isGuildAch then
				shieldIcon:SetAtlas("ui-achievement-shield-2", TextureKitConstants.UseAtlasSize)
			else
				shieldIcon:SetAtlas("ui-achievement-shield-1", TextureKitConstants.UseAtlasSize)
			end
		else -- not Retail
			shieldIcon:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
		end
	end

	frame.Icon.Texture:SetTexture(AchievementInfo.icon or 236376);

	frame.id = AchievementInfo.achievementID or "EZBlizzUiPop"
	return true;
end

function ToastFakeAchievement(addon, playSound, delay, AchievementInfo)
  if AchievementFrame_LoadUI then
	  if (IsKioskModeEnabled and IsKioskModeEnabled()) then
		return
	  end
	  if ( not AchievementFrame ) then
		AchievementFrame_LoadUI()
	  end

	  if (not addon.AlertSystem) then
		addon.AlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("AchievementAlertFrameTemplate", EZBlizzUiPop_AlertFrame_SetUp, delay, math.huge)
	  end
	  addon.AlertSystem:AddAlert(AchievementInfo)

	  if (playSound) then XITK.PlaySound(12891) end -- UI_Alert_AchievementGained
  end
end

function EZBUP.ToastFakeAchievement(addon, playSound, delay, idNumber, name, points, icon, isGuildAch, toptext, alreadyEarned, onClick)
	local AchievementInfo = {}
	AchievementInfo.achievementID = idNumber
	AchievementInfo.name          = name
	AchievementInfo.points        = tonumber(points) or 0
	AchievementInfo.icon          = icon
	AchievementInfo.isGuildAch    = isGuildAch
	AchievementInfo.toptext       = toptext
	AchievementInfo.alreadyEarned = alreadyEarned
	AchievementInfo.onClick       = onClick
	ToastFakeAchievement(addon, playSound, delay, AchievementInfo)
end

-- NPC dialog pop-up
-----------

local modelAnimationLoop = 2

local function EstimateSpeechDuration(text)
    local words = 0
    for _ in string.gmatch(text, "%S+") do
        words = words + 1
    end

    local commas = select(2, string.gsub(text, ",", ""))
    local dots = select(2, string.gsub(text, "[%.:;]", ""))
    local pauses = commas * 0.25 + dots * 0.6

    return (words / 2.5) + pauses
end

local function SetupAnimations(model, animKit, animIntro, animLoop, lineDuration)
	if ( animKit == nil ) then
		return
	end
	if( animKit ~= model.animKit ) then
		model:StopAnimKit()
		model.animKit = nil
	end

	if ( animKit > 0 ) then
		model.animKit = animKit
	-- If intro is 0 (stand) we are assuming that is no-op and skipping to loop.
	elseif (animIntro > 0) then
		model.animIntro = animIntro
		model.animLoop = animLoop
	else
		model.animLoop = animLoop
	end

	if (model.animKit) then
		model:PlayAnimKit(model.animKit, true)
		model:SetScript("OnAnimFinished", nil)
		model.shouldLoop = false
	elseif (model.animIntro) then
		model:SetAnimation(model.animIntro, 0)
		model.shouldLoop = true
		model:SetScript("OnAnimFinished", model.IdleAnim)
	else
		model:SetAnimation(model.animLoop, 0)
		model.shouldLoop = true
		model:SetScript("OnAnimFinished", model.IdleAnim)
	end

	model.lineAnimDone = false
	if (lineDuration and model.shouldLoop) then
		if (lineDuration > 1.5) then
			C_Timer.After(lineDuration - 1.5, function()
					model.animLoop = 0
				end)
		end
	end
end

local modelAnimationLoopIterration = 0
local function EZBlizzUiPop_TalkingHeadFrame_Play(creatureID, name, text, animation)
	local frame = TalkingHeadFrame
	local model = frame.MainFrame.Model

	local textSpeechDuration = EstimateSpeechDuration(text)
	frame:Show()
	
	local cameraID = EZBUP_DATA.CreaturexCameraID[creatureID] and EZBUP_DATA.CreaturexCameraID[creatureID].cameraID
	model.uiCameraID = cameraID  or DEFAULT_CAMERAID
	
	Model_ApplyUICamera(model, 0)
	local OnModelLoaded = model.OnModelLoaded
	model:SetScript("OnModelLoaded", function()
		if cameraID then
			Model_ApplyUICamera(model, model.uiCameraID)
		else
			model:SetCamera(0)
			model:SetPortraitZoom(.95)
			C_Timer.After(0, function()
				model:SetPortraitZoom(.9)
			end)
		end
		SetupAnimations(model, DEFAULT_ANIMKIT, animation, animation, textSpeechDuration)
		model:SetScript("OnModelLoaded", OnModelLoaded)
	end)
	
	model:ClearModel()
	if EZBUP_DATA.CreaturexCameraID[creatureID] and EZBUP_DATA.CreaturexCameraID[creatureID].displayInfo then
		model:SetDisplayInfo(EZBUP_DATA.CreaturexCameraID[creatureID].displayInfo)
	else
		model:SetCreature(creatureID)
	end

	TalkingHeadFrame:Reset(text, name)
	TalkingHeadFrame:FadeinFrames()
	C_Timer.After(math.max(textSpeechDuration, MIN_SPEACH_DURATION), function()
		TalkingHeadFrame:Close()
	end)
end

local function EZBlizzUiPop_npcDialogShow(creatureID, text, overlayFrameTemplate)
	local frame = nil
	if creatureID and text then
		--if ( not TalkingHeadFrame ) then
		--	TalkingHead_LoadUI()
		--end

		frame = TalkingHeadFrame
		if frame then
			if overlayFrameTemplate then
				if not EZBlizzUiPop_OverlayFrame then
					local overlayFrame = CreateFrame("Frame", "EZBlizzUiPop_OverlayFrame", frame, overlayFrameTemplate)
					overlayFrame:SetParent(frame)
					overlayFrame:SetAllPoints(frame)
					overlayFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
					overlayFrame:SetScript("OnEvent", function()
						EZBlizzUiPop_OverlayFrame:Hide()
					end)

					hooksecurefunc(frame, "FadeinFrames", function()
						EZBlizzUiPop_OverlayFrame.Fadein:Play()
					end)
					hooksecurefunc(frame, "FadeoutFrames", function()
						EZBlizzUiPop_OverlayFrame.Close:Play()
					end)
				else
					EZBlizzUiPop_OverlayFrame:Show()
				end
			end

			EZBlizzUiPop_TalkingHeadFrame_Play(
				creatureID,
				XITK.GetNameFromNpcID(creatureID),
				text,
				DEFAULT_ANIMATION)
		end
	end
	return frame
end

function EZBUP.npcDialog(creatureID, text, overlayFrameTemplate)
	local frame
	local npcName = XITK.GetNameFromNpcID(creatureID)
	if npcName and npcName ~= "" then
		frame = EZBlizzUiPop_npcDialogShow(creatureID, text, overlayFrameTemplate)
	else
		C_Timer.After(1, function()
			frame = EZBlizzUiPop_npcDialogShow(creatureID, text, overlayFrameTemplate)
		end)
	end
	return frame
end


--[[
local frameSaveTalkingHeadInfo = CreateFrame("Frame")
frameSaveTalkingHeadInfo:RegisterEvent("TALKINGHEAD_REQUESTED")

frameSaveTalkingHeadInfo:SetScript("OnEvent", function(self, event)
    if event == "TALKINGHEAD_REQUESTED" then
        -- Get all values returned by Blizzard's API
		
        local displayInfo, cameraID, _, _, _, _, name = C_TalkingHead.GetCurrentLineInfo()
		local animKit, animIntro, animLoop = C_TalkingHead.GetCurrentLineAnimationInfo()
        if not displayInfo or not name then return end  -- safeguard

        -- Initialize storage table
        if not SaveTalkingHeadInfo then SaveTalkingHeadInfo = {} end

        -- Get the current zone
        local zone = GetZoneText() or "Unknown"

        -- Unique key combining name + zone
        --local nameID = name.." - "..zone

        -- Store info
		SaveTalkingHeadInfo = nil -- Replace with SavedVariable from active addon
		if not SaveTalkingHeadInfo then
			SaveTalkingHeadInfo = {}
		end
		if not SaveTalkingHeadInfo.SaveTalkingHeadInfo then
			SaveTalkingHeadInfo.SaveTalkingHeadInfo = {}
		end
		
		local key = displayInfo
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key] = {}
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key].zone = zone
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key].cameraID = cameraID
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key].name = name
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key].animKit = animKit
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key].animIntro = animIntro
		SaveTalkingHeadInfo.SaveTalkingHeadInfo[key].animLoop = animLoop
		
		local prefix = name .. " - "

		for key, _ in pairs(SaveTalkingHeadInfo.SaveTalkingHeadInfo) do
			if type(key) == "string" and key:sub(1, #prefix) == prefix then
				SaveTalkingHeadInfo.SaveTalkingHeadInfo[key] = nil
				print(key .. " deleted.")
			end
		end

        print("Saved Talking Head:", name, zone, cameraID)
    end
end)
--]]

--[[
function testModels(cam) --/run testModels()
	local imageSize = 120
	local numRows, numCols = 7, 16
	local i = 1
	for k, v in pairs(EZBUP_DATA.SoundFileIDBank) do
		local x = math.floor((i - 1) / numCols)
		local y = ((i - 1) % numCols)
		
		local totopModel = CreateFrame("PlayerModel", "", UIParent)
		totopModel:SetPoint("TOPLEFT", y*imageSize, -x*imageSize)
		totopModel:SetWidth(imageSize)
		totopModel:SetHeight(imageSize)
		totopModel:ClearModel()
		totopModel:SetCreature(k)
		totopModel.uiCameraID = cam or (EZBUP_DATA.CreaturexCameraID[k] and EZBUP_DATA.CreaturexCameraID[k].cameraID) or DEFAULT_CAMERAID
		--C_Timer.After(0.1 * i, function()
			Model_ApplyUICamera(totopModel, totopModel.uiCameraID)
		--end)
		totopModel:SetScript("OnModelLoaded", function()
            Model_ApplyUICamera(totopModel, totopModel.uiCameraID)
			totopModel:SetAnimation(DEFAULT_ANIMATION)
        end)
		local fontstring = totopModel:CreateFontString("", "ARTWORK", "GameTooltipText")
		fontstring:SetTextColor(1, 1, 1, 1.0)
		fontstring:SetText(k)
		fontstring:SetPoint("BOTTOM", 0, 10)
		
		fontstring = totopModel:CreateFontString("", "ARTWORK", "GameTooltipText")
		fontstring:SetTextColor(1, 1, 1, 1.0)
		fontstring:SetText(cam or DEFAULT_CAMERAID)
		fontstring:SetPoint("BOTTOM", 0, 0)
		totopModel:SetAnimation(DEFAULT_ANIMATION)
		totopModel:SetAttribute("animation", DEFAULT_ANIMATION)
		totopModel:SetScript("OnAnimFinished", function()
			totopModel:SetAnimation(totopModel:GetAttribute("animation"))
		end)
		v.model = totopModel
		i = i + 1
	end
end

function testModels2() --/run testModels2()
	local imageSize = 120
	local numRows, numCols = 7, 16
	for k, v in pairs(EZBUP_DATA.SoundFileIDBank) do
		if v.model then
			local totopModel = v.model
			totopModel:ClearModel()
			--totopModel:SetCreaturek)
			--totopModel:RefreshCamera()
			--totopModel.uiCameraID = (EZBUP_DATA.CreaturexCameraID[k] and EZBUP_DATA.CreaturexCameraID[k].cameraID) or DEFAULT_CAMERAID
			Model_ApplyUICamera(totopModel, totopModel.uiCameraID)
		end
	end
end
--]]

--[[
local camIDs = {82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 110, 110, 111, 111, 111, 112, 112, 112, 113, 113, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 268, 268, 269, 269, 1060, 1061, 1080, 1081, 1082, 1083, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1226, 1227, 1236, 1237, 1238, 1239, 1240, 1241, 1371, 1372, 1373, 1374, 1439, 1440, 1672, 1672, 1672, 1672, 1673, 1673, 1673, 1673, 1676, 1677, 1678, 1679, 1807, 1807, 1808, 1808, 1809, 1809, 1810, 1810}
local cam
local testingModels = {}
local creatureID = 166619
local imageSize = 120
local animation = DEFAULT_CAMERAIDDEFAULT_ANIMATION
local numRows, numCols = 7, 16

for i, v in ipairs(camIDs) do
	if cam then v = cam; cam = cam + 1 end
	local x = math.floor((i - 1) / numCols)
    local y = ((i - 1) % numCols)
	
	local totopModel = CreateFrame("PlayerModel", "", UIParent)
	testingModels[i] = totopModel
	totopModel:SetPoint("TOPLEFT", y*imageSize, -x*imageSize)
	totopModel:SetWidth(imageSize)
	totopModel:SetHeight(imageSize)
	totopModel:ClearModel()
	totopModel:SetCreature(creatureID)
	totopModel:RefreshCamera()
	totopModel.cameraID = v
	Model_ApplyUICamera(totopModel, v)
	totopModel:SetScript("OnModelLoaded", function()
		Model_ApplyUICamera(totopModel, v)
		totopModel:SetAnimation(animation)
	end)
	local fontstring = totopModel:CreateFontString("", "ARTWORK", "GameTooltipText")
	fontstring:SetTextColor(1, 1, 1, 1.0)
	fontstring:SetText(v)
	fontstring:SetPoint("BOTTOM", 0, 0)
	totopModel:SetAnimation(animation)
	totopModel:SetAttribute("animation", animation)
	totopModel:SetScript("OnAnimFinished", function()
		totopModel:SetAnimation(totopModel:GetAttribute("animation"))
	end)
	--animation = animation + 1
end

function testModels3(creatureID) --/run testModels3(193211)
	for i, v in ipairs(testingModels) do
		v:ClearModel()
		v:SetCreature(creatureID)
		v:RefreshCamera()
		Model_ApplyUICamera(v, v.cameraID)
	end
end

--]]

--[[

	local totopModel = CreateFrame("PlayerModel", "", UIParent)
	totopModel:SetPoint("CENTER", 0, 0)
	totopModel:SetWidth(200)
	totopModel:SetHeight(200)
	totopModel:ClearModel()
	totopModel:SetCreature(107574)
	totopModel:SetCamDistanceScale(1.5)
	totopModel:SetPortraitZoom(1)
	totopModel:SetRotation(-0.3)

--]]

-- /run LibStub("EZBlizzardUiPopups").npcDialog(140877, "Test")
