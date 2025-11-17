VUHDO_MAY_DEBUFF_ANIM = true;

local VUHDO_DEBUFF_ICONS = { };
local VUHDO_DEBUFF_ICONS_MAP = { };
local VUHDO_MAX_ANIMATION_SCALE = 2.0;

-- BURST CACHE ---------------------------------------------------

local _;

local floor = floor;
local max = max;
local GetTime = GetTime;
local pairs = pairs;
local twipe = table.wipe;
local huge = math.huge;

local _G = getfenv();

local VUHDO_getUnitButtons;
local VUHDO_getUnitButtonsSafe;
local VUHDO_getBarIconTimer
local VUHDO_getBarIconCounter;
local VUHDO_getBarIconFrame;
local VUHDO_getBarIcon;
local VUHDO_getBarIconName;
local VUHDO_getBarIconClockOrStub;
local VUHDO_getShieldPerc;
local VUHDO_backColor;
local VUHDO_updateHealthBarsFor;
local VUHDO_getBarIconFrameBackground;
local VUHDO_getBarIconButton;

local VUHDO_PANEL_SETUP;
local VUHDO_CONFIG;
local VUHDO_RAID;
local sCuDeStoredSettings;
local sMaxIcons;
local sIsName;
local sStaticConfig;
local VUHDO_DEBUFF_COLORS;
local sOriginalFrameLevels = { };
local sAnimatedDebuffs = { };
local sAnimationGroups = { };
local sAuraFrames = { };
local sDebuffOnUpdateAnimState = { };

local sEmpty = { };

function VUHDO_customDebuffIconsInitLocalOverrides()

	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getBarIconTimer = _G["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = _G["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconFrame = _G["VUHDO_getBarIconFrame"];
	VUHDO_getBarIcon = _G["VUHDO_getBarIcon"];
	VUHDO_getBarIconName = _G["VUHDO_getBarIconName"];
	VUHDO_getBarIconClockOrStub = _G["VUHDO_getBarIconClockOrStub"];
	VUHDO_getShieldPerc = _G["VUHDO_getShieldPerc"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_backColor = _G["VUHDO_backColor"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];
	VUHDO_getBarIconFrameBackground = _G["VUHDO_getBarIconFrameBackground"];
	VUHDO_getBarIconButton = _G["VUHDO_getBarIconButton"];

	VUHDO_updateHealthBarsFor = _G["VUHDO_deferUpdateHealthBarsFor"];

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_RAID = _G["VUHDO_RAID"];

	sCuDeStoredSettings = VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"];
	sMaxIcons = VUHDO_CONFIG["CUSTOM_DEBUFF"]["max_num"];

	if (sMaxIcons < 1) then -- Damit das Bouquet item "Letzter Debuff" funktioniert
		sMaxIcons = 1;
	end

	sIsName = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isName"];

	sStaticConfig = {
		["isStaticConfig"] = true,
		["animate"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["animate"],
		["timer"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["timer"],
		["isStacks"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isStacks"],
		["isAliveTime"] = false,
		["isFullDuration"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isFullDuration"],
		["isMine"] = true,
		["isOthers"] = true,
		["isBarGlow"] = false,
		["isIconGlow"] = false,
		["isClock"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isClock"],
	};

	VUHDO_DEBUFF_COLORS = {
		[1] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF1"],
		[2] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF2"],
		[3] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF3"],
		[4] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF4"],
		[6] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF6"],
		[8] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF8"],
		[9] = VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF9"],
	};

	return;

end

----------------------------------------------------



--
local tBlacklistModi;
local function VUHDO_areBlacklistModifiersPressed()

	if not VUHDO_CONFIG or not VUHDO_CONFIG["CUSTOM_DEBUFF"] then
		return IsAltKeyDown() and IsControlKeyDown() and IsShiftKeyDown();
	end

	tBlacklistModi = VUHDO_CONFIG["CUSTOM_DEBUFF"]["blacklistModi"] or "ALT-CTRL-SHIFT";

	if tBlacklistModi == "OFF" then
		return false;
	elseif tBlacklistModi == "ALT-CTRL-SHIFT" then
		return IsAltKeyDown() and IsControlKeyDown() and IsShiftKeyDown();
	elseif tBlacklistModi == "ALT-SHIFT" then
		return IsAltKeyDown() and IsShiftKeyDown() and not IsControlKeyDown();
	elseif tBlacklistModi == "ALT-CTRL" then
		return IsAltKeyDown() and IsControlKeyDown() and not IsShiftKeyDown();
	elseif tBlacklistModi == "CTRL-SHIFT" then
		return IsControlKeyDown() and IsShiftKeyDown() and not IsAltKeyDown();
	elseif tBlacklistModi == "SHIFT" then
		return IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown();
	elseif tBlacklistModi == "CTRL" then
		return IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown();
	elseif tBlacklistModi == "ALT" then
		return IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown();
	end

	return false;

end



--
local VUHDO_DEBUFF_GLOBAL_HANDLER_FRAME = CreateFrame("Frame");
VUHDO_DEBUFF_GLOBAL_HANDLER_FRAME:RegisterEvent("GLOBAL_MOUSE_DOWN");
VUHDO_DEBUFF_GLOBAL_HANDLER_FRAME:SetScript("OnEvent", function(self, anEvent, aButton)

	if anEvent == "GLOBAL_MOUSE_DOWN" and aButton == "RightButton" and VUHDO_areBlacklistModifiersPressed() then
		local tFrame;

		for tUnit, _ in pairs(VUHDO_RAID) do
			local tButtons = VUHDO_getUnitButtonsSafe(tUnit);

			for _, tButton in pairs(tButtons) do
				for tSlot = 40, 40 + sMaxIcons - 1 do
					tFrame = VUHDO_getBarIconFrame(tButton, tSlot);

					if tFrame and tFrame["debuffInfo"] and tFrame["debuffSpellId"] and tFrame["debuffInstanceId"] and tFrame:IsMouseOver() then
						VUHDO_addDebuffToBlacklist(tFrame);

						return;
					end
				end
			end
		end
	end

end);



--
do
	local tShouldAnimate;
	local tAnimGroup;
	local tAnimationKey;
	local tButtonName;
	local tExistingAnimGroup;
	function VUHDO_shouldDebuffAnimate(aButton, anIconIndex, tAuraInstanceId, tTimeStamp, tActualAliveTime)

		tButtonName = aButton:GetName();
		tAnimationKey = tButtonName .. "_" .. anIconIndex;

		if not sAuraFrames[tAuraInstanceId] then
			sAuraFrames[tAuraInstanceId] = { };
		end

		tShouldAnimate = false;

		for tFrameKey, _ in pairs(sAuraFrames[tAuraInstanceId]) do
			if tFrameKey ~= tAnimationKey then
				tExistingAnimGroup = sAnimationGroups[tFrameKey];

				if tExistingAnimGroup and tExistingAnimGroup:IsPlaying() then
					tShouldAnimate = true;

					break;
				end

				if sDebuffOnUpdateAnimState[tFrameKey] then
					tShouldAnimate = true;

					break;
				end
			end
		end

		if not tShouldAnimate and not sAnimatedDebuffs[tAuraInstanceId] then
			if not tTimeStamp or tTimeStamp <= 0 or (tTimeStamp > 0 and tActualAliveTime < 0.05) then
				tShouldAnimate = true;
			end
		end

		if tShouldAnimate then
			if not sAnimatedDebuffs[tAuraInstanceId] then
				sAnimatedDebuffs[tAuraInstanceId] = true;
			end

			for tOtherAuraId, tFrameKeys in pairs(sAuraFrames) do
				if tOtherAuraId ~= tAuraInstanceId and tFrameKeys[tAnimationKey] then
					tFrameKeys[tAnimationKey] = nil;
				end
			end

			sAuraFrames[tAuraInstanceId][tAnimationKey] = true;

			if VUHDO_CONFIG["USE_ANIMATION_GROUPS"] then
				tAnimGroup = VUHDO_createDebuffIconAnimation(aButton, anIconIndex, tAuraInstanceId);
			else
				tAnimGroup = VUHDO_createDebuffIconOnUpdateAnimation(aButton, anIconIndex, tAuraInstanceId);
			end

			return tAnimGroup;
		end

		return nil;

	end
end



--
do
	local tCuDeStoConfig;
	local tBarIcon;
	local tBarIconTimer;
	local tBarIconFrame;
	local tBarIconCounter;
	local tBarIconButton;
	local tBarIconName;
	local tBarIconFrameBackground;
	local tIsAnim;
	local tIsBarGlow;
	local tIsIconGlow;
	local tTimeStamp;
	local tActualAliveTime;
	local tAliveTime;
	local tName;
	local tRemain;
	local tShieldPerc;
	local tStacks;
	local tAuraInstanceId;
	local tCurChosenInfo;
	local tType;
	local tIsPlaying;
	local tClock;
	local tStarted;
	local tClockDuration;
	local tMinDuration;
	local tR;
	local tG;
	local tB;
	local tA;
	local tBackdropInfo = {
		["edgeFile"] = "Interface\\Buttons\\WHITE8X8",
		["edgeSize"] = 4,
		["insets"] = {
			["left"] = 0,
			["right"] = 0,
			["top"] = 0,
			["bottom"] = 0,
		},
	};
	local tAnimGroup;
	local tAnimationKey;
	local tLookedUpAnimGroup;
	local tButtonName;
	function VUHDO_animateDebuffIcon(aButton, anIconInfo, aNow, anIconIndex, anIsInit, aUnit)

		tTimeStamp = anIconInfo[2];
		tName = anIconInfo[3];
		tStacks = anIconInfo[5];
		tMinDuration = anIconInfo[6];
		tAuraInstanceId = anIconInfo[8];

		tCuDeStoConfig = sCuDeStoredSettings[tName] or sCuDeStoredSettings[tostring(anIconInfo[7])] or sStaticConfig;

		if tCuDeStoConfig["isStaticConfig"] and
			(VUHDO_DEBUFF_BLACKLIST[tName] or VUHDO_DEBUFF_BLACKLIST[tostring(anIconInfo[7])]) then
			VUHDO_removeDebuffIcon(aUnit, tAuraInstanceId);

			return;
		end

		tBarIcon = VUHDO_getBarIcon(aButton, anIconIndex);
		tBarIconTimer = VUHDO_getBarIconTimer(aButton, anIconIndex);
		tBarIconFrame = VUHDO_getBarIconFrame(aButton, anIconIndex);
		tBarIconCounter = VUHDO_getBarIconCounter(aButton, anIconIndex);
		tBarIconButton = VUHDO_getBarIconButton(aButton, anIconIndex);
		tBarIconName = VUHDO_getBarIconName(aButton, anIconIndex);
		tBarIconFrameBackground = VUHDO_getBarIconFrameBackground(aButton, anIconIndex);

		tIsAnim = tCuDeStoConfig["animate"] and VUHDO_MAY_DEBUFF_ANIM;
		tIsBarGlow = tCuDeStoConfig["isBarGlow"];
		tIsIconGlow = tCuDeStoConfig["isIconGlow"];
		tActualAliveTime = (tTimeStamp and tTimeStamp > 0) and (aNow - tTimeStamp) or 0;
		tAliveTime = anIsInit and 0 or tActualAliveTime;

		if not (anIsInit and tTimeStamp == -1) then
			tRemain = (anIconInfo[4] or aNow - 1) - aNow;
		else
			tRemain = 0;
		end

		if tCuDeStoConfig["timer"] then
			if tCuDeStoConfig["isAliveTime"] then
				tBarIconTimer:SetText(tAliveTime < 99.5 and floor(tAliveTime + 0.5) or ">>");
			else
				if anIsInit and tTimeStamp == -1 then
					tBarIconTimer:SetText("");
				else
					if tRemain >= 0 and (tRemain < 10 or tCuDeStoConfig["isFullDuration"]) then
						tBarIconTimer:SetText(tRemain > 100 and ">>" or floor(tRemain));
					else
						tBarIconTimer:SetText("");
					end
				end
			end
		end

		if tCuDeStoConfig["isClock"] then
			tClock = VUHDO_getBarIconClockOrStub(aButton, anIconIndex, tCuDeStoConfig["isClock"]);

			if tRemain and tRemain > 0 and tMinDuration and tMinDuration > 0 then
				tStarted = floor(10 * (aNow - tMinDuration + tRemain) + 0.5) * 0.1;
				tClockDuration = tClock:GetCooldownDuration() * 0.001;
				tMinDuration = max(tMinDuration, 0.1);

				if tMinDuration > 0 and
					(tClock:GetAlpha() == 0 or (tClock:GetAttribute("started") or tStarted) ~= tStarted or
					(tClock:IsVisible() and (tMinDuration > tClockDuration or tMinDuration < 0.1))) then
					tClock:SetCooldown(tStarted, tMinDuration);
					tClock:SetAttribute("started", tStarted);

					tClock:SetAlpha(1);
				end
			else
				tClock:SetAlpha(0);
			end
		else
			tClock = VUHDO_getBarIconClockOrStub(aButton, anIconIndex, false);

			tClock:SetAlpha(0);
		end

		tShieldPerc = VUHDO_getShieldPerc(aUnit, tName);
		tStacks = tShieldPerc ~= 0 and tShieldPerc or tStacks or 0;

		tBarIconCounter:SetText((tCuDeStoConfig["isStacks"] and tStacks > 1) and tStacks or "");

		if anIsInit then
			tBarIcon:SetTexture(anIconInfo[1]);
			VUHDO_PixelUtil.ApplySettings(tBarIcon);

			if sIsName then
				tBarIconName:SetText(tName);
				tBarIconName:SetAlpha(1);
			end

			tBarIconFrame:SetAlpha(1);

			if tIsAnim then
				tAnimGroup = VUHDO_shouldDebuffAnimate(aButton, anIconIndex, tAuraInstanceId, tTimeStamp, tActualAliveTime);
			else
				tAnimGroup = nil;
			end

			if tIsBarGlow then
				VUHDO_LibCustomGlow.PixelGlow_Start(
					aButton,
					tCuDeStoConfig["barGlowColor"] and {
						tCuDeStoConfig["barGlowColor"]["R"],
						tCuDeStoConfig["barGlowColor"]["G"],
						tCuDeStoConfig["barGlowColor"]["B"],
						tCuDeStoConfig["barGlowColor"]["O"]
					} or {
						VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["R"],
						VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["G"],
						VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["B"],
						VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_BAR_GLOW"]["O"]
					},
					14,                             -- number of particles
					0.3,                            -- frequency
					8,                              -- length
					2,                              -- thickness
					0,                              -- x offset
					0,                              -- y offset
					false,                          -- border
					VUHDO_CUSTOM_GLOW_CUDE_FRAME_KEY
				);
			end

			if tIsIconGlow then
				if tIsAnim and tAnimGroup then
					if not tAnimGroup["iconGlowSettings"] then
						tAnimGroup["iconGlowSettings"] = {
							["button"] = tBarIconButton,
							["color"] = tCuDeStoConfig["iconGlowColor"] and {
								tCuDeStoConfig["iconGlowColor"]["R"],
								tCuDeStoConfig["iconGlowColor"]["G"],
								tCuDeStoConfig["iconGlowColor"]["B"],
								tCuDeStoConfig["iconGlowColor"]["O"]
							} or {
								VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["R"],
								VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["G"],
								VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["B"],
								VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["O"]
							}
						};
					end
				else
					VUHDO_LibCustomGlow.PixelGlow_Start(
						tBarIconButton,
						tCuDeStoConfig["iconGlowColor"] and {
							tCuDeStoConfig["iconGlowColor"]["R"],
							tCuDeStoConfig["iconGlowColor"]["G"],
							tCuDeStoConfig["iconGlowColor"]["B"],
							tCuDeStoConfig["iconGlowColor"]["O"]
						} or {
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["R"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["G"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["B"],
							VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]["O"]
						},
						8,                                           -- number of particles
						0.3,                                         -- frequency
						6,                                           -- length
						2,                                           -- thickness
						0,                                           -- x offset
						0,                                           -- y offset
						false,                                       -- border
						VUHDO_CUSTOM_GLOW_CUDE_ICON_KEY
					);
				end
			end

			if tIsAnim and tAnimGroup and VUHDO_CONFIG["USE_ANIMATION_GROUPS"] and not tAnimGroup:IsPlaying() then
				tAnimGroup:Play();
			end
		elseif tBarIcon:GetTexture() ~= anIconInfo[1] then
			tBarIcon:SetTexture(anIconInfo[1]);
			VUHDO_PixelUtil.ApplySettings(tBarIcon);

			tBarIconFrame:SetAlpha(1);

			VUHDO_updateHealthBarsFor(aUnit, VUHDO_UPDATE_RANGE);
		end

		if tBarIconFrame and tBarIconFrame:GetAlpha() == 0 and tBarIconFrame["debuffInfo"] == tName and tBarIconFrame["debuffInstanceId"] == tAuraInstanceId then
			tBarIconFrame:SetAlpha(1);
		end

		tAuraInstanceId = tBarIconFrame["debuffInstanceId"];

		tCurChosenInfo = VUHDO_getDebuffCurChosenInfo()[aUnit] and VUHDO_getDebuffCurChosenInfo()[aUnit][tAuraInstanceId];
		tType = tCurChosenInfo and tCurChosenInfo[1];

		if not tAnimGroup and tIsAnim then
			tButtonName = aButton:GetName();
			tAnimationKey = tButtonName .. "_" .. anIconIndex;

			if VUHDO_CONFIG["USE_ANIMATION_GROUPS"] then
				tLookedUpAnimGroup = sAnimationGroups[tAnimationKey];

				if tLookedUpAnimGroup and tLookedUpAnimGroup:IsPlaying() then
					tAnimGroup = tLookedUpAnimGroup;
				end
			else
				tAnimGroup = sDebuffOnUpdateAnimState[tAnimationKey];
			end
		end

		if tType and tType > 0 and VUHDO_DEBUFF_COLORS[tType] and VUHDO_DEBUFF_COLORS[tType]["useBorder"] then
			if VUHDO_CONFIG["USE_ANIMATION_GROUPS"] then
				tIsPlaying = tAnimGroup and tAnimGroup:IsPlaying();
			else
				tIsPlaying = tAnimGroup ~= nil;
			end

			if tIsAnim and tAnimGroup and tIsPlaying then
				tBarIcon:SetTexCoord(0, 1, 0, 1);

				if tBarIconFrameBackground then
					tBarIconFrameBackground:SetBackdropBorderColor(0, 0, 0, 0);
				end
			else
				tBarIcon:SetTexCoord(.08, .92, .08, .92);

				if tBarIconFrameBackground then
					if not tBarIconFrameBackground:GetBackdrop() then
						VUHDO_PixelUtil.ApplyBackdrop(tBarIconFrameBackground, tBackdropInfo);
					end

					tR, tG, tB, tA = VUHDO_backColor(VUHDO_DEBUFF_COLORS[tType]);
					tBarIconFrameBackground:SetBackdropBorderColor(tR, tG, tB, tA);

					tBarIconFrameBackground["originalBorderColor"] = {tR, tG, tB, tA};

					tBarIconFrameBackground:SetAlpha(1);
					tBarIconFrameBackground:Show();
				end
			end
		else
			tBarIcon:SetTexCoord(0, 1, 0, 1);

			if tBarIconFrameBackground then
				if tBarIconFrameBackground:GetBackdrop() then
					tBarIconFrameBackground:SetBackdrop(nil);
				end
			end
		end

		if sIsName and tAliveTime > 2 then
			tBarIconName:SetAlpha(0);
		end

		return;

	end
end



--
do
	local tIconButton;
	local tAnimKey;
	function VUHDO_onAnimationPlay(self)

		tAnimKey = self["animKey"];

		if not tAnimKey then
			return;
		end

		tIconButton = self:GetParent();

		if tIconButton then
			sOriginalFrameLevels[tAnimKey] = tIconButton:GetFrameLevel();

			VUHDO_PixelUtil.SetFrameLevel(tIconButton, sOriginalFrameLevels[tAnimKey] + 10);
		end

		return;

	end
end



--
do
	local tIconButton;
	local tBarIconFrameBackground;
	local tAnimKey;
	local tGlowSettings;
	local tButton;
	local tSuccess;
	local tIconTexture;
	function VUHDO_onAnimationFinished(self)

		tAnimKey = self["animKey"];

		if not tAnimKey then
			return;
		end

		tIconButton = self:GetParent();

		if tIconButton then
			VUHDO_PixelUtil.SetScale(tIconButton, 1);

			if self["iconGlowSettings"] then
				tGlowSettings = self["iconGlowSettings"];

				if tGlowSettings["button"] and tGlowSettings["color"] then
					VUHDO_LibCustomGlow.PixelGlow_Start(
						tGlowSettings["button"],
						tGlowSettings["color"],
						8,                                           -- number of particles
						0.3,                                         -- frequency
						6,                                           -- length
						2,                                           -- thickness
						0,                                           -- x offset
						0,                                           -- y offset
						false,                                       -- border
						VUHDO_CUSTOM_GLOW_CUDE_ICON_KEY
					);
				end
				self["iconGlowSettings"] = nil;
			end

			if sOriginalFrameLevels[tAnimKey] then
				VUHDO_PixelUtil.SetFrameLevel(tIconButton, sOriginalFrameLevels[tAnimKey]);
			end

			tBarIconFrameBackground = tIconButton;

			if tBarIconFrameBackground and tBarIconFrameBackground:GetBackdrop() then
				if tBarIconFrameBackground["originalBorderColor"] then
					tBarIconFrameBackground:SetBackdropBorderColor(tBarIconFrameBackground["originalBorderColor"][1], tBarIconFrameBackground["originalBorderColor"][2], tBarIconFrameBackground["originalBorderColor"][3], tBarIconFrameBackground["originalBorderColor"][4]);
				end

				if self["iconIndex"] then
					tButton = tIconButton:GetParent():GetParent();

					if tButton then
						tSuccess, tIconTexture = pcall(VUHDO_getBarIcon, tButton, self["iconIndex"]);

						if tSuccess and tIconTexture and tIconTexture.SetTexCoord then
							tIconTexture:SetTexCoord(.08, .92, .08, .92);
						end
					end
				end
			end
		end

		return;

	end
end



--
do
	local tState;
	local tProgress;
	local tAnimKey;
	local tBarIconFrameBackground;
	local tGlowSettings;
	local tButton;
	local tSuccess;
	local tIconTexture;
	local tR;
	local tG;
	local tB;
	local tA;
	function VUHDO_onDebuffIconAnimationUpdate(self, elapsed)

		tAnimKey = self["animKey"];

		if not tAnimKey then
			return;
		end

		tState = sDebuffOnUpdateAnimState[tAnimKey];

		if not tState then
			return;
		end

		tState["elapsed"] = tState["elapsed"] + elapsed;

		if tState["elapsed"] < 0.1 then
			tState["scale"] = 1.0;
		elseif tState["elapsed"] < 0.6 then
			tProgress = (tState["elapsed"] - 0.1) / 0.5;
			tState["scale"] = 1.0 + (tProgress * (VUHDO_MAX_ANIMATION_SCALE - 1.0));
		elseif tState["elapsed"] < 1.1 then
			tProgress = (tState["elapsed"] - 0.6) / 0.5;
			tState["scale"] = VUHDO_MAX_ANIMATION_SCALE - (tProgress * (VUHDO_MAX_ANIMATION_SCALE - 1.0));
		else
			tState["scale"] = 1.0;

			VUHDO_PixelUtil.SetScale(self, 1.0);

			if tState["frameLevel"] then
				VUHDO_PixelUtil.SetFrameLevel(self, tState["frameLevel"]);
			end

			if tState["iconGlowSettings"] then
				tGlowSettings = tState["iconGlowSettings"];

				if tGlowSettings["button"] and tGlowSettings["color"] then
					VUHDO_LibCustomGlow.PixelGlow_Start(
						tGlowSettings["button"],
						tGlowSettings["color"],
						8,
						0.3,
						6,
						2,
						0,
						0,
						false,
						VUHDO_CUSTOM_GLOW_CUDE_ICON_KEY
					);
				end

				tState["iconGlowSettings"] = nil;
			end

			if tState["barIconButton"] and tState["iconIndex"] then
				tBarIconFrameBackground = tState["barIconButton"];

				if tBarIconFrameBackground and tBarIconFrameBackground:GetBackdrop() then
					if tBarIconFrameBackground["originalBorderColor"] then
						tBarIconFrameBackground:SetBackdropBorderColor(tBarIconFrameBackground["originalBorderColor"][1], tBarIconFrameBackground["originalBorderColor"][2], tBarIconFrameBackground["originalBorderColor"][3], tBarIconFrameBackground["originalBorderColor"][4]);
					end

					tButton = tBarIconFrameBackground:GetParent():GetParent();

					if tButton then
						tSuccess, tIconTexture = pcall(VUHDO_getBarIcon, tButton, tState["iconIndex"]);

						if tSuccess and tIconTexture and tIconTexture.SetTexCoord then
							tIconTexture:SetTexCoord(.08, .92, .08, .92);
						end
					end
				end
			end

			self:SetScript("OnUpdate", nil);

			sDebuffOnUpdateAnimState[tAnimKey] = nil;

			if sAuraFrames[tState["auraInstanceId"]] then
				sAuraFrames[tState["auraInstanceId"]][tAnimKey] = nil;
			end

			return;
		end

		VUHDO_PixelUtil.SetScale(self, tState["scale"]);

		if tState["scale"] > 1.0 and not tState["raised"] then
			if not tState["frameLevel"] then
				tState["frameLevel"] = self:GetFrameLevel();
			end

			VUHDO_PixelUtil.SetFrameLevel(self, tState["frameLevel"] + 10);

			tState["raised"] = true;
		elseif tState["scale"] == 1.0 and tState["raised"] then
			if tState["frameLevel"] then
				VUHDO_PixelUtil.SetFrameLevel(self, tState["frameLevel"]);
			end

			tState["raised"] = false;
		end

		return;

	end
end



--
do
	local tBarIconButton;
	local tAnimationKey;
	local tAnimState;
	function VUHDO_createDebuffIconOnUpdateAnimation(aButton, anIconIndex, anAuraInstanceId)

		tBarIconButton = VUHDO_getBarIconButton(aButton, anIconIndex);

		if not tBarIconButton then
			return nil;
		end

		tAnimationKey = aButton:GetName() .. "_" .. anIconIndex;

		tAnimState = {
			["elapsed"] = 0,
			["scale"] = 1.0,
			["raised"] = false,
			["frameLevel"] = nil,
			["auraInstanceId"] = anAuraInstanceId,
			["barIconButton"] = tBarIconButton,
			["iconIndex"] = anIconIndex,
		};

		sDebuffOnUpdateAnimState[tAnimationKey] = tAnimState;

		tBarIconButton["animKey"] = tAnimationKey;
		tBarIconButton:SetScript("OnUpdate", VUHDO_onDebuffIconAnimationUpdate);

		return tAnimState;

	end
end



--
do
	local tBarIconButton;
	local tAnimationKey;
	local tAnimGroup;
	local tScaleAnimOut;
	local tScaleAnimIn;
	function VUHDO_createDebuffIconAnimation(aButton, anIconIndex, anAuraInstanceId)

		tBarIconButton = VUHDO_getBarIconButton(aButton, anIconIndex);

		if not tBarIconButton then
			return;
		end

		tAnimationKey = aButton:GetName() .. "_" .. anIconIndex;
		tAnimGroup = sAnimationGroups[tAnimationKey];

		if not tAnimGroup then
			tAnimGroup = tBarIconButton:CreateAnimationGroup();

			tAnimGroup:SetLooping("NONE");

			tScaleAnimOut = tAnimGroup:CreateAnimation("Scale");

			tScaleAnimOut:SetChildKey("I");
			tScaleAnimOut:SetOrigin("BOTTOMRIGHT", 0, 0);
			tScaleAnimOut:SetScaleFrom(1, 1);
			tScaleAnimOut:SetScaleTo(VUHDO_MAX_ANIMATION_SCALE, VUHDO_MAX_ANIMATION_SCALE);
			tScaleAnimOut:SetDuration(0.5);
			tScaleAnimOut:SetSmoothing("NONE");
			tScaleAnimOut:SetOrder(1);

			tScaleAnimIn = tAnimGroup:CreateAnimation("Scale");

			tScaleAnimIn:SetChildKey("I");
			tScaleAnimIn:SetOrigin("BOTTOMRIGHT", 0, 0);
			tScaleAnimIn:SetScaleFrom(VUHDO_MAX_ANIMATION_SCALE - 1.0, VUHDO_MAX_ANIMATION_SCALE - 1.0);
			tScaleAnimIn:SetScaleTo(0.5, 0.5);
			tScaleAnimIn:SetDuration(0.5);
			tScaleAnimIn:SetSmoothing("NONE");
			tScaleAnimIn:SetOrder(2);

			tAnimGroup:SetScript("OnPlay", VUHDO_onAnimationPlay);
			tAnimGroup:SetScript("OnFinished", VUHDO_onAnimationFinished);

			tAnimGroup["iconIndex"] = anIconIndex;
			tAnimGroup["animKey"] = tAnimationKey;

			sAnimationGroups[tAnimationKey] = tAnimGroup;
		end

		return tAnimGroup;

	end
end



--
do
	local tAnimationKey;
	local tAnimGroup;
	local tBarIconButton;
	function VUHDO_cleanupDebuffIconAnimation(aButton, anIconIndex)

		tAnimationKey = aButton:GetName() .. "_" .. anIconIndex;
		tAnimGroup = sAnimationGroups[tAnimationKey];

		if tAnimGroup then
			tAnimGroup:Stop();

			tBarIconButton = VUHDO_getBarIconButton(aButton, anIconIndex);

			if tBarIconButton then
			VUHDO_PixelUtil.SetScale(tBarIconButton, 1);

				if sOriginalFrameLevels[tAnimationKey] then
					VUHDO_PixelUtil.SetFrameLevel(tBarIconButton, sOriginalFrameLevels[tAnimationKey]);
				end
			end

			sAnimationGroups[tAnimationKey] = nil;
			sOriginalFrameLevels[tAnimationKey] = nil;
		end

		if sDebuffOnUpdateAnimState[tAnimationKey] then
			tBarIconButton = VUHDO_getBarIconButton(aButton, anIconIndex);

			if tBarIconButton then
				tBarIconButton:SetScript("OnUpdate", nil);

				VUHDO_PixelUtil.SetScale(tBarIconButton, 1);
			end

			sDebuffOnUpdateAnimState[tAnimationKey] = nil;
		end

		return;

	end
end



--
do
	local tNow;
	function VUHDO_updateAllDebuffIcons(anIsFrequent)

		tNow = GetTime();

		for tUnit, tAllDebuffInfos in pairs(VUHDO_DEBUFF_ICONS) do
			for tIndex, tDebuffInfo in pairs(tAllDebuffInfos) do
				if not anIsFrequent or tDebuffInfo[2] + 1.21 >= tNow then
					for _, tButton in pairs(VUHDO_getUnitButtonsSafe(tUnit)) do
						VUHDO_animateDebuffIcon(tButton, tDebuffInfo, tNow, tIndex + 39, false, tUnit);
					end
				end
			end
		end

		return;

	end
end



--
do
	local tNow;
	local tUnitDebuffInfos;
	function VUHDO_updateUnitDebuffIcons(aUnit, anIsFrequent)

		if not aUnit or not VUHDO_DEBUFF_ICONS then
			return;
		end

		tNow = GetTime();

		tUnitDebuffInfos = VUHDO_DEBUFF_ICONS[aUnit];

		if tUnitDebuffInfos then
			for tIndex, tDebuffInfo in pairs(tUnitDebuffInfos) do
				if not anIsFrequent or tDebuffInfo[2] + 1.21 >= tNow then
					for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
						VUHDO_animateDebuffIcon(tButton, tDebuffInfo, tNow, tIndex + 39, false, aUnit);
					end
				end
			end
		end

		return;

	end
end



--
function VUHDO_deferUpdateAllDebuffIcons(anIsFrequent, aPriority)

	if not VUHDO_DEBUFF_ICONS then
		return;
	end

	for tUnit, _ in pairs(VUHDO_DEBUFF_ICONS) do
		VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_DEBUFF_ICONS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, tUnit, anIsFrequent);
	end

	return;

end



--
do
	local tExistingSlot;
	local tOldest;
	local tSlot;
	local tTimestamp;
	local tIconInfoOld;
	local tIconInfoNew;
	local tFrame;
	function VUHDO_addDebuffIcon(aUnit, anIcon, aName, anExpiry, aStacks, aDuration, anIsBuff, aSpellId, anAuraInstanceId)

		if not VUHDO_DEBUFF_ICONS[aUnit] then
			VUHDO_DEBUFF_ICONS[aUnit] = { };
		end

		if not VUHDO_DEBUFF_ICONS_MAP[aUnit] then
			VUHDO_DEBUFF_ICONS_MAP[aUnit] = { };
		end

		tExistingSlot = VUHDO_DEBUFF_ICONS_MAP[aUnit][anAuraInstanceId];

		if tExistingSlot then
			VUHDO_updateDebuffIcon(aUnit, anIcon, aName, anExpiry, aStacks, aDuration, anIsBuff, aSpellId, anAuraInstanceId);

			return;
		end

		tOldest = huge;
		tSlot = 1;

		for tCnt = 1, sMaxIcons do
			if not VUHDO_DEBUFF_ICONS[aUnit][tCnt] then
				tSlot = tCnt;

				break;
			else
				tTimestamp = VUHDO_DEBUFF_ICONS[aUnit][tCnt][2];

				if tTimestamp > 0 and tTimestamp < tOldest then
					tOldest = tTimestamp;
					tSlot = tCnt;
				end
			end
		end

		tIconInfoOld = VUHDO_DEBUFF_ICONS[aUnit][tSlot];

		if tIconInfoOld then
			VUHDO_DEBUFF_ICONS_MAP[aUnit][tIconInfoOld[8]] = nil;

			VUHDO_releasePooledIconArray(tIconInfoOld);
		end

		tIconInfoNew = VUHDO_getPooledIconArray();

		-- 1 = icon, 2 = timestamp, 3 = name, 4 = expiration time, 5 = stacks, 6 = duration, 7 = spell ID, 8 = aura instance ID
		tIconInfoNew[1], tIconInfoNew[2], tIconInfoNew[3], tIconInfoNew[4], tIconInfoNew[5],
		tIconInfoNew[6], tIconInfoNew[7], tIconInfoNew[8] =
			anIcon, -1, aName, anExpiry, aStacks,
			aDuration, aSpellId, anAuraInstanceId;

		VUHDO_DEBUFF_ICONS[aUnit][tSlot] = tIconInfoNew;
		VUHDO_DEBUFF_ICONS_MAP[aUnit][anAuraInstanceId] = tSlot;

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			tFrame = VUHDO_getBarIconFrame(tButton, tSlot + 39);

			if tFrame then
				tFrame["debuffInfo"], tFrame["debuffSpellId"], tFrame["isBuff"], tFrame["debuffInstanceId"] = aName, aSpellId, anIsBuff, anAuraInstanceId;

				VUHDO_animateDebuffIcon(tButton, tIconInfoNew, GetTime(), tSlot + 39, true, aUnit);
				end
		end

		tIconInfoNew[2] = GetTime();

		VUHDO_updateHealthBarsFor(aUnit, VUHDO_UPDATE_RANGE);

		return;

	end
end



--
do
	local tSlot;
	local tIconInfo;
	local tFrame;
	function VUHDO_updateDebuffIcon(aUnit, anIcon, aName, anExpiry, aStacks, aDuration, anIsBuff, aSpellId, anAuraInstanceId)

		if not VUHDO_DEBUFF_ICONS[aUnit] then
			VUHDO_DEBUFF_ICONS[aUnit] = { };
		end

		if not VUHDO_DEBUFF_ICONS_MAP[aUnit] then
			VUHDO_DEBUFF_ICONS_MAP[aUnit] = { };
		end

		tSlot = VUHDO_DEBUFF_ICONS_MAP[aUnit][anAuraInstanceId];

		if tSlot then
			tIconInfo = VUHDO_DEBUFF_ICONS[aUnit][tSlot];

			tIconInfo[1], tIconInfo[3], tIconInfo[4], tIconInfo[5], tIconInfo[6], tIconInfo[7], tIconInfo[8] =
				anIcon, aName, anExpiry, aStacks, aDuration, aSpellId, anAuraInstanceId;

			for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
				tFrame = VUHDO_getBarIconFrame(tButton, tSlot + 39);

				tFrame["debuffInfo"], tFrame["debuffSpellId"], tFrame["isBuff"], tFrame["debuffInstanceId"] = aName, aSpellId, anIsBuff, anAuraInstanceId;
			end
		else
			VUHDO_addDebuffIcon(aUnit, anIcon, aName, anExpiry, aStacks, aDuration, anIsBuff, aSpellId, anAuraInstanceId);
		end

		return;

	end
end



--
do
	local tSlot;
	local tIconArray;
	local tAllButtons;
	local tFrame;
	local tAnimKey;
	local tAnimGroup;
	function VUHDO_removeDebuffIcon(aUnit, anAuraInstanceId)

		if not VUHDO_DEBUFF_ICONS[aUnit] then
			return;
		end

		tSlot = VUHDO_DEBUFF_ICONS_MAP[aUnit] and VUHDO_DEBUFF_ICONS_MAP[aUnit][anAuraInstanceId];

		if not tSlot then
			return;
		end

		tIconArray = VUHDO_DEBUFF_ICONS[aUnit][tSlot];

		if not tIconArray then
			return;
		end

		tAllButtons = VUHDO_getUnitButtons(aUnit);

		if tAllButtons then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_LibCustomGlow.PixelGlow_Stop(tButton, VUHDO_CUSTOM_GLOW_CUDE_FRAME_KEY);

				VUHDO_cleanupDebuffIconAnimation(tButton, tSlot + 39);

				tFrame = VUHDO_getBarIconFrame(tButton, tSlot + 39);

				if tFrame then
					tAnimKey = tButton:GetName() .. "_" .. (tSlot + 39);
					tAnimGroup = sAnimationGroups[tAnimKey];

					if not (tAnimGroup and tAnimGroup:IsPlaying()) and not sDebuffOnUpdateAnimState[tAnimKey] then
						VUHDO_LibCustomGlow.PixelGlow_Stop(VUHDO_getBarIconButton(tButton, tSlot + 39), VUHDO_CUSTOM_GLOW_CUDE_ICON_KEY);
					end

					if sAuraFrames[anAuraInstanceId] then
						sAuraFrames[anAuraInstanceId][tAnimKey] = nil;
					end

					tFrame:SetAlpha(0);

					tFrame["debuffInfo"] = nil;
					tFrame["debuffSpellId"] = nil;
					tFrame["isBuff"] = nil;
					tFrame["debuffInstanceId"] = nil;
				end
			end
		end

		VUHDO_DEBUFF_ICONS[aUnit][tSlot] = nil;
		VUHDO_DEBUFF_ICONS_MAP[aUnit][anAuraInstanceId] = nil;
		sAnimatedDebuffs[anAuraInstanceId] = nil;
		sAuraFrames[anAuraInstanceId] = nil;

		VUHDO_releasePooledIconArray(tIconArray);

		return;

	end
end



--
do
	local tFrame;
	local tAllButtons;
	local tAnimKey;
	local tAnimGroup;
	function VUHDO_removeAllDebuffIcons(aUnit)

		tAllButtons = VUHDO_getUnitButtons(aUnit);

		if not tAllButtons then
			return;
		end

		for _, tButton in pairs(tAllButtons) do
			VUHDO_LibCustomGlow.PixelGlow_Stop(tButton, VUHDO_CUSTOM_GLOW_CUDE_FRAME_KEY);

			for tCnt = 40, 39 + sMaxIcons do
				tFrame = VUHDO_getBarIconFrame(tButton, tCnt);

				if tFrame then
					tAnimKey = tButton:GetName() .. "_" .. tCnt;
					tAnimGroup = sAnimationGroups[tAnimKey];

					if not (tAnimGroup and tAnimGroup:IsPlaying()) and not sDebuffOnUpdateAnimState[tAnimKey] then
						VUHDO_LibCustomGlow.PixelGlow_Stop(VUHDO_getBarIconButton(tButton, tCnt), VUHDO_CUSTOM_GLOW_CUDE_ICON_KEY);
					end

					tFrame:SetAlpha(0);

					tFrame["debuffInfo"] = nil;
					tFrame["debuffSpellId"] = nil;
					tFrame["isBuff"] = nil;
					tFrame["debuffInstanceId"] = nil;
				end
			end
		end

		if VUHDO_DEBUFF_ICONS[aUnit] then
			for tCnt, tIconArray in pairs(VUHDO_DEBUFF_ICONS[aUnit]) do
				VUHDO_releasePooledIconArray(tIconArray);

				VUHDO_DEBUFF_ICONS[aUnit][tCnt] = nil;
			end
		end

		if VUHDO_DEBUFF_ICONS_MAP[aUnit] then
			twipe(VUHDO_DEBUFF_ICONS_MAP[aUnit]);
		end

		VUHDO_updateBouquetsForEvent(aUnit, 29);

		return;

	end
end



--
do
	local tDebuffInfo;
	local tCurrInfo;
	function VUHDO_getLatestCustomDebuff(aUnit)

		tDebuffInfo = sEmpty;

		for tCnt = 1, sMaxIcons do
			tCurrInfo = (VUHDO_DEBUFF_ICONS[aUnit] or sEmpty)[tCnt];

			if tCurrInfo and tCurrInfo[2] > (tDebuffInfo[2] or 0) then
				tDebuffInfo = tCurrInfo;
			end
		end

		return tDebuffInfo[1], tDebuffInfo[4], tDebuffInfo[5], tDebuffInfo[6];

	end
end



--
function VUHDO_getDebuffIcons()

	return VUHDO_DEBUFF_ICONS;

end



--
function VUHDO_getDebuffIconsMap()

	return VUHDO_DEBUFF_ICONS_MAP;

end



--
function VUHDO_animHelp()

	VUHDO_Msg("|cffFFD100--- Animation Commands ---|r");

	VUHDO_Msg("|cffFFA500** Current Status:|r");

	if VUHDO_CONFIG["USE_ANIMATION_GROUPS"] then
		VUHDO_Msg("  |cffB0E0E6Animation Method:|r |cff00ff00AnimationGroup API|r");
	else
		VUHDO_Msg("  |cffB0E0E6Animation Method:|r |cffff0000OnUpdate Script|r");
	end

	VUHDO_Msg("|cffFFA500** Available Commands:|r");
	VUHDO_Msg("  |cffB0E0E6/vd anim test [N]|r - Create N test frames (default 5, max 40)");
	VUHDO_Msg("  |cffB0E0E6/vd anim hide|r - Remove test frames");
	VUHDO_Msg("  |cffB0E0E6/vd anim on|r - Enable AnimationGroup API");
	VUHDO_Msg("  |cffB0E0E6/vd anim off|r - Disable AnimationGroup API (use OnUpdate)");
	VUHDO_Msg("  |cffB0E0E6/vd anim|r - Show this help");

	VUHDO_Msg("|cffFFD100--- End of Animation Commands ---|r");

	return;

end



--
local sTestAnimFrames = { };
local sTestAnimGroups = { };
local sTestOriginalFrameLevels = { };
local sTestOnUpdateFrames = { };
local sTestOnUpdateAnimState = { };
local sTestLabels = { };



--
local tState;
local tProgress;
local function VUHDO_onTestAnimationUpdate(self, elapsed)

	tState = sTestOnUpdateAnimState[self["testKey"]];

	if not tState then
		return;
	end

	tState["elapsed"] = tState["elapsed"] + elapsed;

	if tState["elapsed"] < 0.1 then
		tState["scale"] = 1.0;
	elseif tState["elapsed"] < 0.6 then
		tProgress = (tState["elapsed"] - 0.1) / 0.5;
		tState["scale"] = 1.0 + (tProgress * (VUHDO_MAX_ANIMATION_SCALE - 1.0));
	elseif tState["elapsed"] < 1.1 then
		tProgress = (tState["elapsed"] - 0.6) / 0.5;
		tState["scale"] = VUHDO_MAX_ANIMATION_SCALE - (tProgress * (VUHDO_MAX_ANIMATION_SCALE - 1.0));
	else
		tState["elapsed"] = 0;
		tState["scale"] = 1.0;
	end

	VUHDO_PixelUtil.SetScale(self, tState["scale"]);

	if tState["scale"] > 1.0 and not tState["raised"] then
		if not tState["frameLevel"] then
			tState["frameLevel"] = self:GetFrameLevel();
		end

		VUHDO_PixelUtil.SetFrameLevel(self, tState["frameLevel"] + 10);

		tState["raised"] = true;
	elseif tState["scale"] == 1.0 and tState["raised"] then
		if tState["frameLevel"] then
			VUHDO_PixelUtil.SetFrameLevel(self, tState["frameLevel"]);
		end

		tState["raised"] = false;
	end

	return;

end



--
local tIconButton;
local tAnimKey;
local function VUHDO_onTestAnimationPlay(self)

	tAnimKey = self["animKey"];

	if not tAnimKey then
		return;
	end

	tIconButton = self:GetParent();

	if tIconButton then
		sTestOriginalFrameLevels[tAnimKey] = tIconButton:GetFrameLevel();

		VUHDO_PixelUtil.SetFrameLevel(tIconButton, sTestOriginalFrameLevels[tAnimKey] + 10);
	end

	return;

end



--
local tIconButton;
local tAnimKey;
local function VUHDO_onTestAnimationFinished(self)

	tAnimKey = self["animKey"];

	if not tAnimKey then
		return;
	end

	tIconButton = self:GetParent();

	if tIconButton then
		VUHDO_PixelUtil.SetScale(tIconButton, 1);

		if sTestOriginalFrameLevels[tAnimKey] then
			VUHDO_PixelUtil.SetFrameLevel(tIconButton, sTestOriginalFrameLevels[tAnimKey]);
		end
	end

	if self:IsPlaying() then
		return;
	end

	self:Play();

	return;

end



--
local tTestFrame;
local tTestTexture;
local tTestButton;
local tRow;
local tCol;
local tXOffset;
local tYOffset;
local tFrameSize;
local tSpacing;
local tColumns;
local tTestAnimGroup;
local tTestAnimKey;
local tCount;
local tNumRows;
local tRowHeight;
local tOnUpdateLabelY;
local tAnimGroupLabelY;
local tScaleAnimOut;
local tScaleAnimIn;
function VUHDO_animTest(aCount)

	tCount = aCount or 5;
	tCount = max(1, min(40, tCount));

	VUHDO_Msg("|cffFFD100--- Animation Performance Test ---|r");

	VUHDO_Msg("|cffFFA500** Test Configuration:|r");
	VUHDO_Msg("  |cffB0E0E6Animation Scale:|r " .. VUHDO_MAX_ANIMATION_SCALE .. "x");
	VUHDO_Msg("  |cffB0E0E6Smoothing:|r Linear (NONE)");
	VUHDO_Msg("  |cffB0E0E6Test Frames:|r " .. tCount .. " per method (" .. (tCount * 2) .. " total)");

	VUHDO_Msg("|cffFFA500** Creating Test Frames:|r");
	VUHDO_Msg("  Spawning " .. tCount .. " OnUpdate frames (top row).");
	VUHDO_Msg("  Spawning " .. tCount .. " AnimationGroup frames (bottom row).");

	tFrameSize = 48;
	tSpacing = 10;
	tColumns = 5;

	tNumRows = floor((tCount - 1) / tColumns) + 1;
	tRowHeight = tFrameSize + tSpacing;

	if not sTestLabels["onUpdate"] then
		sTestLabels["onUpdate"] = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		sTestLabels["onUpdate"]:SetText("|cffB0E0E6OnUpdate Script|r");
	end

	tOnUpdateLabelY = 60 + (tNumRows * tRowHeight) / 2 + 20;

	VUHDO_PixelUtil.SetPoint(sTestLabels["onUpdate"], "CENTER", UIParent, "CENTER", 0, tOnUpdateLabelY);
	sTestLabels["onUpdate"]:Show();

	if not sTestLabels["animGroup"] then
		sTestLabels["animGroup"] = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		sTestLabels["animGroup"]:SetText("|cffB0E0E6AnimationGroup API|r");
	end

	tAnimGroupLabelY = -60 - (tNumRows * tRowHeight) / 2 - 10;

	VUHDO_PixelUtil.SetPoint(sTestLabels["animGroup"], "CENTER", UIParent, "CENTER", 0, tAnimGroupLabelY);
	sTestLabels["animGroup"]:Show();

	for tIndex = 1, tCount do
		tRow = floor((tIndex - 1) / tColumns);
		tCol = (tIndex - 1) % tColumns;

		tXOffset = (tCol - (tColumns - 1) / 2) * (tFrameSize + tSpacing);

		if not sTestOnUpdateFrames[tIndex] then
			sTestOnUpdateFrames[tIndex] = CreateFrame("Frame", "VuhDoAnimTestOnUpdateFrame" .. tIndex, UIParent, "BackdropTemplate");

			tTestFrame = sTestOnUpdateFrames[tIndex];

			VUHDO_PixelUtil.SetFrameStrata(tTestFrame, "HIGH");
			tTestFrame:SetMovable(true);
			VUHDO_PixelUtil.EnableMouse(tTestFrame, true);
			tTestFrame:RegisterForDrag("LeftButton");

			tTestFrame:SetScript("OnDragStart", tTestFrame.StartMoving);
			tTestFrame:SetScript("OnDragStop", tTestFrame.StopMovingOrSizing);

			tTestTexture = tTestFrame:CreateTexture(nil, "ARTWORK");

			tTestTexture:SetAllPoints(tTestFrame);
			tTestTexture:SetTexture("Interface\\Icons\\Spell_Nature_Lightning");
			VUHDO_PixelUtil.ApplySettings(tTestTexture);

			tTestFrame["texture"] = tTestTexture;
			tTestFrame["testKey"] = "VuhDoAnimTestOnUpdateFrame" .. tIndex;

			tTestFrame:SetScript("OnUpdate", VUHDO_onTestAnimationUpdate);
		end

		tTestFrame = sTestOnUpdateFrames[tIndex];

		tYOffset = 60 - (tRow * (tFrameSize + tSpacing));

		sTestOnUpdateAnimState[tTestFrame["testKey"]] = {
			["elapsed"] = 0,
			["scale"] = 1.0,
			["raised"] = false,
			["frameLevel"] = nil,
		};

		VUHDO_PixelUtil.SetPoint(tTestFrame, "CENTER", UIParent, "CENTER", tXOffset, tYOffset);
		VUHDO_PixelUtil.SetSize(tTestFrame, tFrameSize, tFrameSize);

		VUHDO_PixelUtil.ApplyBackdrop(tTestFrame, {
			["edgeFile"] = "Interface\\Buttons\\WHITE8X8",
			["edgeSize"] = 4,
			["insets"] = {
				["left"] = 0,
				["right"] = 0,
				["top"] = 0,
				["bottom"] = 0,
			},
		});

		tTestFrame:SetBackdropBorderColor(0.1, 0.5, 0.8, 1);

		tTestFrame["texture"]:SetTexCoord(.08, .92, .08, .92);

		tTestFrame:Show();

		if not sTestAnimFrames[tIndex] then
			sTestAnimFrames[tIndex] = CreateFrame("Frame", "VuhDoAnimTestFrame" .. tIndex, UIParent, "BackdropTemplate");

			tTestFrame = sTestAnimFrames[tIndex];

			VUHDO_PixelUtil.SetFrameStrata(tTestFrame, "HIGH");
			tTestFrame:SetMovable(true);
			VUHDO_PixelUtil.EnableMouse(tTestFrame, true);
			tTestFrame:RegisterForDrag("LeftButton");

			tTestFrame:SetScript("OnDragStart", tTestFrame.StartMoving);
			tTestFrame:SetScript("OnDragStop", tTestFrame.StopMovingOrSizing);

			tTestTexture = tTestFrame:CreateTexture(nil, "ARTWORK");

			tTestTexture:SetAllPoints(tTestFrame);
			tTestTexture:SetTexture("Interface\\Icons\\Spell_Shadow_CurseOfTounges");
			VUHDO_PixelUtil.ApplySettings(tTestTexture);

			tTestFrame["texture"] = tTestTexture;
		end

		tTestFrame = sTestAnimFrames[tIndex];

		tYOffset = -60 - (tRow * (tFrameSize + tSpacing));

		VUHDO_PixelUtil.SetPoint(tTestFrame, "CENTER", UIParent, "CENTER", tXOffset, tYOffset);
		VUHDO_PixelUtil.SetSize(tTestFrame, tFrameSize, tFrameSize);

		VUHDO_PixelUtil.ApplyBackdrop(tTestFrame, {
			["edgeFile"] = "Interface\\Buttons\\WHITE8X8",
			["edgeSize"] = 4,
			["insets"] = {
				["left"] = 0,
				["right"] = 0,
				["top"] = 0,
				["bottom"] = 0,
			},
		});

		tTestFrame:SetBackdropBorderColor(0.8, 0.1, 0.1, 1);

		tTestFrame["texture"]:SetTexCoord(.08, .92, .08, .92);

		tTestAnimKey = "VuhDoAnimTestFrame" .. tIndex;
		tTestAnimGroup = sTestAnimGroups[tTestAnimKey];

		if not tTestAnimGroup then
			tTestButton = tTestFrame;

			tTestAnimGroup = tTestButton:CreateAnimationGroup();

			tTestAnimGroup:SetLooping("NONE");

			tScaleAnimOut = tTestAnimGroup:CreateAnimation("Scale");

			tScaleAnimOut:SetChildKey("texture");
			tScaleAnimOut:SetOrigin("BOTTOMRIGHT", 0, 0);
			tScaleAnimOut:SetScaleFrom(1, 1);
			tScaleAnimOut:SetScaleTo(VUHDO_MAX_ANIMATION_SCALE, VUHDO_MAX_ANIMATION_SCALE);
			tScaleAnimOut:SetDuration(0.5);
			tScaleAnimOut:SetStartDelay(0.1);
			tScaleAnimOut:SetSmoothing("NONE");
			tScaleAnimOut:SetOrder(1);

			tScaleAnimIn = tTestAnimGroup:CreateAnimation("Scale");

			tScaleAnimIn:SetChildKey("texture");
			tScaleAnimIn:SetOrigin("BOTTOMRIGHT", 0, 0);
			tScaleAnimIn:SetScaleFrom(VUHDO_MAX_ANIMATION_SCALE - 1.0, VUHDO_MAX_ANIMATION_SCALE - 1.0);
			tScaleAnimIn:SetScaleTo(0.5, 0.5);
			tScaleAnimIn:SetDuration(0.5);
			tScaleAnimIn:SetSmoothing("NONE");
			tScaleAnimIn:SetOrder(2);

			tTestAnimGroup:SetScript("OnPlay", VUHDO_onTestAnimationPlay);
			tTestAnimGroup:SetScript("OnFinished", VUHDO_onTestAnimationFinished);

			tTestAnimGroup["animKey"] = tTestAnimKey;

			sTestAnimGroups[tTestAnimKey] = tTestAnimGroup;
		end

		tTestFrame:Show();

		if not tTestAnimGroup:IsPlaying() then
			tTestAnimGroup:Play();
		end
	end

	VUHDO_Msg("  Use '/vd anim hide' to remove test frames.");
	VUHDO_Msg("|cffFFD100--- End of Animation Performance Test ---|r");

	return;

end



--
local tVisibleCount;
local tTestAnimGroup;
function VUHDO_animHideTestFrames()

	tVisibleCount = 0;

	for tIndex, tFrame in pairs(sTestOnUpdateFrames) do
		if tFrame then
			if tFrame:IsShown() then
				tVisibleCount = tVisibleCount + 1;
			end

			tFrame:SetScript("OnUpdate", nil);

			sTestOnUpdateAnimState[tFrame["testKey"]] = nil;

			VUHDO_PixelUtil.SetScale(tFrame, 1);

			tFrame:Hide();

			tFrame:SetScript("OnDragStart", nil);
			tFrame:SetScript("OnDragStop", nil);

			tFrame:SetMovable(false);
			VUHDO_PixelUtil.EnableMouse(tFrame, false);

			tFrame:UnregisterAllEvents();
			tFrame:SetParent(nil);

			sTestOnUpdateFrames[tIndex] = nil;
		end
	end

	for tIndex, tFrame in pairs(sTestAnimFrames) do
		if tFrame then
			if tFrame:IsShown() then
				tVisibleCount = tVisibleCount + 1;
			end

			tTestAnimGroup = sTestAnimGroups["VuhDoAnimTestFrame" .. tIndex];

			if tTestAnimGroup then
				tTestAnimGroup:Stop();

				sTestAnimGroups["VuhDoAnimTestFrame" .. tIndex] = nil;
			end

			VUHDO_PixelUtil.SetScale(tFrame, 1);

			sTestOriginalFrameLevels["VuhDoAnimTestFrame" .. tIndex] = nil;

			tFrame:Hide();

			tFrame:SetScript("OnDragStart", nil);
			tFrame:SetScript("OnDragStop", nil);

			tFrame:SetMovable(false);
			VUHDO_PixelUtil.EnableMouse(tFrame, false);

			tFrame:UnregisterAllEvents();
			tFrame:SetParent(nil);

			sTestAnimFrames[tIndex] = nil;
		end
	end

	if sTestLabels["onUpdate"] then
		sTestLabels["onUpdate"]:Hide();
	end

	if sTestLabels["animGroup"] then
		sTestLabels["animGroup"]:Hide();
	end

	if tVisibleCount > 0 then
		VUHDO_Msg("|cffFFD100--- Animation Test Frames Hidden ---|r");

		VUHDO_Msg("  |cffB0E0E6Action:|r " .. tVisibleCount .. " test frame" .. (tVisibleCount == 1 and "" or "s") .. " hidden and cleaned up");
		VUHDO_Msg("  |cffB0E0E6Note:|r Use '/vd anim' to show them again");

		VUHDO_Msg("|cffFFD100--- End of Animation Test Frames ---|r");
	else
		VUHDO_Msg("|cffFFD100--- Animation Test Frames ---|r");

		VUHDO_Msg("  |cffB0E0E6Status:|r No test frames were found to clean up");

		VUHDO_Msg("|cffFFD100--- End of Animation Test Frames ---|r");
	end

	return;

end