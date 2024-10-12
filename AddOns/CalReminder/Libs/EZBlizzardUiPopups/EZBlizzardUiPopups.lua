local _, _, _, tocversion = GetBuildInfo()

local EZBlizzUiPop_WoWRetail = tocversion >= 110000
function EZBlizzUiPop_GetMouseFocus()
	local frame = nil
	if EZBlizzUiPop_WoWRetail then
		local region = GetMouseFoci()
		frame = region[1]
	else
		frame = GetMouseFocus()
	end
	return frame
end

if (not EZBlizzardUiPopupsTooltip) then
	CreateFrame("GameTooltip", "EZBlizzardUiPopupsTooltip", UIParent, "GameTooltipTemplate")
	EZBlizzardUiPopupsTooltip:SetFrameStrata("TOOLTIP")
	EZBlizzardUiPopupsTooltip:Hide()
else
	return
end

local willPlay, soundHandle

function EZBlizzUiPop_PlaySound(soundID)
	if soundID then
		PlaySound(soundID, "master")
	end
end

function EZBlizzUiPop_PlaySoundFileId(soundFileId, channel, playSound)
	if playSound then
		if soundHandle then
			StopSound(soundHandle)
		end
		willPlay, soundHandle = PlaySoundFile(soundFileId, channel)
	end
	return soundHandle
end

function EZBlizzUiPop_PlayRandomSound(soundFileIdBank, channel, playSound)
	if playSound then
		local nbSounds = #soundFileIdBank
		if nbSounds > 0 then
			local sound = math.random(1, nbSounds)
			return Deadpool_PlaySoundFileId(soundFileIdBank[sound], channel, playSound)
		end
	end
	return nil
end

function EZBlizzUiPop_PlayNPCRandomSound(npc, channel, playSound)
	if playSound then
		local soundFileIdBank = EZBlizzUiPop_npcModels[npc] and EZBlizzUiPop_npcModels[npc].soundQuotes
		return EZBlizzUiPop_PlayRandomSound(soundFileIdBank, channel, playSound)
	end
	return nil
end

-- Tip by Gello - Hyjal
-- takes an npcID and returns the name of the npc
function EZBlizzUiPop_GetNameFromNpcID(npcID)
	local name = ""
	
	EZBlizzardUiPopupsTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	EZBlizzardUiPopupsTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
	
	local line = _G[("EZBlizzardUiPopupsTooltipTextLeft%d"):format(1)]
	if line and line:GetText() then
		name = line:GetText()
	end
	
	return name
end

-- TOASTS - Thanks to Tuhljin from Overachiever !
-----------

--local function alertOnClick(self, ...)
function EZBlizzUiPop_AlertFrame_OnClick(self, ...)
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

local function ToastFakeAchievement(addon, playSound, delay, AchievementInfo)
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

	  if (playSound) then EZBlizzUiPop_PlaySound(12891) end -- UI_Alert_AchievementGained
  end
end

function EZBlizzUiPop_ToastFakeAchievement(addon, playSound, delay, idNumber, name, points, icon, isGuildAch, toptext, alreadyEarned, onClick)
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

function EZBlizzUiPop_ToastFakeAchievementNew(addon, name, baseID, playSound, delay, toptext, onClick, icon, newEarn)
	EZBlizzUiPop_ToastFakeAchievement(addon, playSound, delay, idNumber, name, points, icon, isGuildAch, toptext, not newEarn, onClick)
end

-- NPC dialog pop-up
-----------

local modelAnimationLoop = 2

if not EZBlizzUiPop_npcModels then
	EZBlizzUiPop_npcModels = {}
end

EZBlizzUiPop_npcModels["BAINE"]                 = { ["CreatureId"] = 36648,  ["CameraId"] = 141,  ["animation"] = 60, ["soundQuotes"] = { 2416552, 2416540, 2416542, 2416543 } } -- or animation 65 ?
EZBlizzUiPop_npcModels["SYLVANAS"]              = { ["CreatureId"] = 177114, ["CameraId"] = 84,   ["animation"] = 60, ["soundQuotes"] = { 1801002, 1801005, 1800995, 561301 } }
EZBlizzUiPop_npcModels["ANDUIN"]                = { ["CreatureId"] = 230055, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 5725623, 5725624, 5725625, 5725634, 5725619, 5725620, 5725630 } }
EZBlizzUiPop_npcModels["ALLIANCE_GUILD_HERALD"] = { ["CreatureId"] = 49587,  ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 552227, 552221 } }
EZBlizzUiPop_npcModels["VARIAN"]                = { ["CreatureId"] = 29611,  ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 563552, 563519, 563537, 563479 } }
EZBlizzUiPop_npcModels["HEMET"]                 = { ["CreatureId"] = 191205, ["CameraId"] = 90,   ["animation"] = 60, ["soundQuotes"] = { 1486698, 1486699, 1486701, 1486702, 1486703, 1486704 } }
EZBlizzUiPop_npcModels["RAVERHOLDT"]            = { ["CreatureId"] = 229150, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 1388284, 1388286, 1388282 } }
EZBlizzUiPop_npcModels["UTHER"]                 = { ["CreatureId"] = 166619, ["CameraId"] = 1079, ["animation"] = 60, ["soundQuotes"] = { 3597128, 3597129, 563239 } }
EZBlizzUiPop_npcModels["VELEN"]                 = { ["CreatureId"] = 210670, ["CameraId"] = 106,  ["animation"] = 60, ["soundQuotes"] = { 1055403, 1055404, 1055405, 1055406, 1055399, 1055400, 1055402 } }
EZBlizzUiPop_npcModels["NOBUNDO"]               = { ["CreatureId"] = 212343, ["CameraId"] = 268,  ["animation"] = 60, ["soundQuotes"] = { 1373762, 1373763, 1373756, 1373757, 1373758, 1373759 } }
EZBlizzUiPop_npcModels["KHADGAR"]               = { ["CreatureId"] = 193459, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 4639084, 4639095, 4639096, 4639097, 4639090 } }
EZBlizzUiPop_npcModels["CHOGALL"]               = { ["CreatureId"] = 81822,  ["CameraId"] = 815,  ["animation"] = 60, ["soundQuotes"] = { 546172, 546153, 546103, 546166 } }
EZBlizzUiPop_npcModels["CHEN"]                  = { ["CreatureId"] = 209704, ["CameraId"] = 144,  ["animation"] = 60, ["soundQuotes"] = { 634292, 634296, 634290, 634294 } }
EZBlizzUiPop_npcModels["MALFURION"]             = { ["CreatureId"] = 193211, ["CameraId"] = 575,  ["animation"] = 60, ["soundQuotes"] = { 2468393, 2468394, 2468396, 2468397 } }
EZBlizzUiPop_npcModels["ILLIDAN"]               = { ["CreatureId"] = 22917,  ["CameraId"] = 296,  ["animation"] = 65, ["soundQuotes"] = { 552503, 552514, 1689235, 1689238, 1689239, 1689240, 1689241, 1699667 } }
EZBlizzUiPop_npcModels["LICH_KING"]             = { ["CreatureId"] = 36597,  ["CameraId"] = 88,   ["animation"] = 60, ["soundQuotes"] = { 554123, 554181, 553997, 554089, 554172, 554085 } }
EZBlizzUiPop_npcModels["HORDE_GUILD_HERALD"]    = { ["CreatureId"] = 49590,  ["CameraId"] = 141,  ["animation"] = 60, ["soundQuotes"] = { 557802, 557807, 557801, 557804, 557800, 557809, 557799, 557806, 557814 } }
EZBlizzUiPop_npcModels["THRALL"]                = { ["CreatureId"] = 229321, ["CameraId"] = 109,  ["animation"] = 60, ["soundQuotes"] = { 5758117, 5758118, 5758119, 5758114, 5758115, 5758116, 2922115 } }
EZBlizzUiPop_npcModels["GALLYWIX"]              = { ["CreatureId"] = 101605, ["CameraId"] = 114,  ["animation"] = 51, ["soundQuotes"] = { 1860609, 1860611, 1860613, 1860622, 1860626 } }
EZBlizzUiPop_npcModels["SHANDRIS"]              = { ["CreatureId"] = 205067, ["CameraId"] = 109,  ["animation"] = 60, ["soundQuotes"] = { 5482269, 4288146, 4288143 } }
EZBlizzUiPop_npcModels["SHAW"]                  = { ["CreatureId"] = 198884, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 1388445, 1388442, 1388449, 1388451 } }
EZBlizzUiPop_npcModels["GAMON"]                 = { ["CreatureId"] = 158588, ["CameraId"] = 126,  ["animation"] = 60, ["soundQuotes"] = { 897314, 897322, 897324 } }
EZBlizzUiPop_npcModels["REXXAR"]                = { ["CreatureId"] = 203683, ["CameraId"] = 142,  ["animation"] = 60, ["soundQuotes"] = { 2011278, 2011283, 2011276, 2011282 } }
EZBlizzUiPop_npcModels["VALEERA"]               = { ["CreatureId"] = 229128, ["CameraId"] = 84,   ["animation"] = 60, ["soundQuotes"] = { 1388604, 1388606, 1388608 } }
EZBlizzUiPop_npcModels["JAINA"]                 = { ["CreatureId"] = 216168, ["CameraId"] = 84,   ["animation"] = 60, ["soundQuotes"] = { 2012996, 2012998, 2012999, 2013000, 2013002, 5828671, 5828672, 2012993, 2012994 } }
EZBlizzUiPop_npcModels["HAMUUL"]                = { ["CreatureId"] = 208649, ["CameraId"] = 126,  ["animation"] = 60, ["soundQuotes"] = { 1388273, 1388275, 1388276, 1388278 } }
EZBlizzUiPop_npcModels["SAURFANG"]              = { ["CreatureId"] = 156180, ["CameraId"] = 109,  ["animation"] = 60, ["soundQuotes"] = { 2012223, 2012224, 2012212, 2012213, 2012214, 2012216, 2012217, 2012226 } }
EZBlizzUiPop_npcModels["KANRETHAD"]             = { ["CreatureId"] = 118927, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 1581925, 1581926, 1581927 } }
EZBlizzUiPop_npcModels["GARROSH"]               = { ["CreatureId"] = 143425, ["CameraId"] = 86,   ["animation"] = 60, ["soundQuotes"] = { 549620, 896000, 896028, 896036 } }
EZBlizzUiPop_npcModels["LIADRIN"]               = { ["CreatureId"] = 226656, ["CameraId"] = 120,  ["animation"] = 60, ["soundQuotes"] = { 1388292, 1388295, 1388297, 1388298 } }
EZBlizzUiPop_npcModels["FAOL"]                  = { ["CreatureId"] = 186182, ["CameraId"] = 130,  ["animation"] = 60, ["soundQuotes"] = { 1388191, 1388193, 1388189, 1388196 } }
EZBlizzUiPop_npcModels["KAELTHAS"]              = { ["CreatureId"] = 179475, ["CameraId"] = 119,  ["animation"] = 60, ["soundQuotes"] = { 3620551, 3620554, 558296 } }
EZBlizzUiPop_npcModels["BOLVAR"]                = { ["CreatureId"] = 164079, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 3698917, 3698918, 3698920, 3698921, 3698922, 3698912, 3698913, 3698914 } }
EZBlizzUiPop_npcModels["TURALYON"]              = { ["CreatureId"] = 223205, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 4659345, 4659349, 4659346, 4659338 } }
EZBlizzUiPop_npcModels["ALLERIA"]               = { ["CreatureId"] = 230062, ["CameraId"] = 120,  ["animation"] = 60, ["soundQuotes"] = { 5725989, 5725999, 5725985, 5725991, 5726000 } }
EZBlizzUiPop_npcModels["AZURATHEL"]             = { ["CreatureId"] = 181056, ["CameraId"] = 146,  ["animation"] = 60, ["soundQuotes"] = { 4659468, 4659471, 4659467 } }
EZBlizzUiPop_npcModels["CINDRETHRESH"]          = { ["CreatureId"] = 181055, ["CameraId"] = 146,  ["animation"] = 60, ["soundQuotes"] = { 4661200, 4661197, 4661198, 4661203 } }
EZBlizzUiPop_npcModels["DINAIRE"]               = { ["CreatureId"] = 206533, ["CameraId"] = 82,   ["animation"] = 60, ["soundQuotes"] = { 5725530, 5725538, 5725546, 5725413 } }
EZBlizzUiPop_npcModels["VEREESA"]               = { ["CreatureId"] = 30115,  ["CameraId"] = 120,  ["animation"] = 60, ["soundQuotes"] = { 1388723, 1388707, 1388710, 1388737 } }

function EZBlizzUiPop_npcDialog(npc, text, overlayFrameTemplate)
	local frame = nil
	if EZBlizzUiPop_npcModels[npc] then
		frame = EZBlizzUiPop_npcDialogShow(npc, text, overlayFrameTemplate)
	end
	return frame
end

function EZBlizzUiPop_npcDialogShow(npc, text, overlayFrameTemplate)
	local frame = nil
	if text then
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

			local model = frame.MainFrame.Model
			model:ClearModel()
			model:SetCreature(EZBlizzUiPop_npcModels[npc]["CreatureId"])
			--model:SetDisplayInfo(EZBlizzUiPop_npcModels[npc]["CreatureId"])
			EZBlizzUiPop_TalkingHeadFrame_Play(EZBlizzUiPop_npcModels[npc]["CameraId"], EZBlizzUiPop_GetNameFromNpcID(EZBlizzUiPop_npcModels[npc]["CreatureId"]), text, EZBlizzUiPop_npcModels[npc]["animation"])
		end
	end
	return frame
end

local modelAnimationLoopIterration = 0
function EZBlizzUiPop_TalkingHeadFrame_Play(cameraId, name, text, animation)
	local frame = TalkingHeadFrame
	local model = frame.MainFrame.Model
	
	local textFormatted = string.format(text)
	frame:Show()
	model.uiCameraID = cameraId
	Model_ApplyUICamera(model, model.uiCameraID)
	model:SetScript("OnModelLoaded", function()
		Model_ApplyUICamera(model, model.uiCameraID)
		if model.currentAnimation ~= animation then
			model:SetAnimation(animation)
			model.currentAnimation = animation
		end
	end)

	TalkingHeadFrame:Reset(textFormatted, name)
	TalkingHeadFrame:FadeinFrames()
	C_Timer.After(0.1, function()
		model:SetAnimation(animation)
		model.currentAnimation = animation
		model:SetScript("OnAnimFinished", function()
			model.currentAnimation = nil
			modelAnimationLoopIterration = modelAnimationLoopIterration + 1
			if modelAnimationLoopIterration < modelAnimationLoop then
				model:SetAnimation(animation)
				model.currentAnimation = animation
			else
				model:SetAnimation(0)
				model.currentAnimation = 0
				model:SetScript("OnAnimFinished", nil)
				modelAnimationLoopIterration = 0
			end
		end)
	end)
	C_Timer.After(10, function()
		TalkingHeadFrame:Close()
	end)
end

--[[ Loading models
local model = CreateFrame('PlayerModel', nil, UIParent)
model:SetPoint("BOTTOMLEFT")
model:SetWidth(5)
model:SetHeight(5)
for index,value in pairs(EZBlizzUiPop_npcModels) do
	if not EZBlizzUiPop_npcModels[index]["loaded"] then
		model:SetCreature(EZBlizzUiPop_npcModels[index]["CreatureId"])
		--model:SetDisplayInfo(EZBlizzUiPop_npcModels[index]["CreatureId"])
		model:ClearModel()
		EZBlizzUiPop_npcModels[index]["loaded"] = true
	end
end
model:Hide()
--]]

--[[
function testModels(cam) --/run testModels()
	local imageSize = 120
	local numRows, numCols = 7, 16
	local i = 1
	for k, v in pairs(EZBlizzUiPop_npcModels) do
		local x = math.floor((i - 1) / numCols)
		local y = ((i - 1) % numCols)
		
		local totopModel = CreateFrame("PlayerModel", "", UIParent)
		totopModel:SetPoint("TOPLEFT", y*imageSize, -x*imageSize)
		totopModel:SetWidth(imageSize)
		totopModel:SetHeight(imageSize)
		totopModel:SetCreature(v.CreatureId)
		totopModel.uiCameraID = cam or v.CameraId
		--C_Timer.After(0.1 * i, function()
			Model_ApplyUICamera(totopModel, totopModel.uiCameraID)
		--end)
		totopModel:SetScript("OnModelLoaded", function()
            Model_ApplyUICamera(totopModel, totopModel.uiCameraID)
			totopModel:SetAnimation(v.animation)
        end)
		local fontstring = totopModel:CreateFontString("", "ARTWORK", "GameTooltipText")
		fontstring:SetTextColor(1, 1, 1, 1.0)
		fontstring:SetText(k)
		fontstring:SetPoint("BOTTOM", 0, 10)
		
		fontstring = totopModel:CreateFontString("", "ARTWORK", "GameTooltipText")
		fontstring:SetTextColor(1, 1, 1, 1.0)
		fontstring:SetText(cam or v.CameraId)
		fontstring:SetPoint("BOTTOM", 0, 0)
		totopModel:SetAnimation(v.animation)
		totopModel:SetAttribute("animation", v.animation)
		totopModel:SetScript("OnAnimFinished", function()
			totopModel:SetAnimation(totopModel:GetAttribute("animation"))
		end)
		i = i + 1
	end
end

function testModels2() --/run testModels2()
	local imageSize = 120
	local numRows, numCols = 7, 16
	for k, v in pairs(EZBlizzUiPop_npcModels) do
		
		local totopModel = v.model
		--totopModel:SetCreature(v.CreatureId)
		--totopModel:RefreshCamera()
		--totopModel.uiCameraID = v.CameraId
		Model_ApplyUICamera(totopModel, totopModel.uiCameraID)
	end
end
--]]

--[[
local camIds = {82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 110, 110, 111, 111, 111, 112, 112, 112, 113, 113, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 268, 268, 269, 269, 1060, 1061, 1080, 1081, 1082, 1083, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1226, 1227, 1236, 1237, 1238, 1239, 1240, 1241, 1371, 1372, 1373, 1374, 1439, 1440, 1672, 1672, 1672, 1672, 1673, 1673, 1673, 1673, 1676, 1677, 1678, 1679, 1807, 1807, 1808, 1808, 1809, 1809, 1810, 1810}
local cam
local testingModels = {}
local creatureId = 166619
local imageSize = 120
local animation = 60
local numRows, numCols = 7, 16

for i, v in ipairs(camIds) do
	if cam then v = cam; cam = cam + 1 end
	local x = math.floor((i - 1) / numCols)
    local y = ((i - 1) % numCols)
	
	local totopModel = CreateFrame("PlayerModel", "", UIParent)
	testingModels[i] = totopModel
	totopModel:SetPoint("TOPLEFT", y*imageSize, -x*imageSize)
	totopModel:SetWidth(imageSize)
	totopModel:SetHeight(imageSize)
	totopModel:SetCreature(creatureId)
	--totopModel:SetDisplayInfo(creatureId)
	totopModel:RefreshCamera()
	totopModel.cameraId = v
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

function testModels3(creature) --/run testModels3("BAINE")
	for i, v in ipairs(testingModels) do
		v:SetCreature(EZBlizzUiPop_npcModels[creature].CreatureId)
		v:RefreshCamera()
		Model_ApplyUICamera(v, v.cameraId)
	end
end

--]]

--[[

	local totopModel = CreateFrame("PlayerModel", "", UIParent)
	totopModel:SetPoint("CENTER", 0, 0)
	totopModel:SetWidth(200)
	totopModel:SetHeight(200)
	totopModel:SetCreature(107574)
	totopModel:SetCamDistanceScale(1.5)
	totopModel:SetPortraitZoom(1)
	totopModel:SetRotation(-0.3)

--]]
