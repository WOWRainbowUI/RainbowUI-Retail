local _, DR = ...

local L = {}
DR.L = L
local defaultsTable = DR.defaultsTable

local function defaultFunc(L, key)
 -- If this function was called, we have no localization for this key.
 -- We could complain loudly to allow localizers to see the error of their ways, 
 -- but, for now, just return the key as its own localization. This allows you to—avoid writing the default localization out explicitly.
 return key;
end
setmetatable(L, {__index=defaultFunc});

local LOCALE = GetLocale()

local NPC_KEYS = {
	Creature_Demonfly = 238717,
	Creature_Darkglare = 238786,
	Creature_FelSpreader = 238865,
	Creature_Felbat = 244780,
	Creature_Felbomber = 239089,
	Creature_Skyterror = 238713,
	Creature_EyeOfGreed = 244782,
};
local NPCNameCache = {};
local hiddenTip;

local function FetchNPCNameByID(npcID)
	local link = string.format("unit:Creature-0-0-0-0-%d-0000000000", npcID);

	if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
		local tooltipData = C_TooltipInfo.GetHyperlink(link);
		if tooltipData and tooltipData.lines and tooltipData.lines[1] then
			return tooltipData.lines[1].leftText;
		end
	else
		if not hiddenTip then
			hiddenTip = CreateFrame("GameTooltip", "DR_HiddenTooltip", UIParent, "GameTooltipTemplate");
			hiddenTip:SetOwner(UIParent, "ANCHOR_NONE");
		end
		hiddenTip:SetHyperlink(link);
		return DR_HiddenTooltipTextLeft1:GetText();
	end
end

local function GetNPCNameByID(npcID)
	if NPCNameCache[npcID] then
		return NPCNameCache[npcID];
	end
	local name = FetchNPCNameByID(npcID);
	if name then
		NPCNameCache[npcID] = name;
	end
	return name;
end

local function PreloadNPCNames()
	for key, npcID in pairs(NPC_KEYS) do
		local name = GetNPCNameByID(npcID);
		if name then
			L[key] = name;
		else
			L[key] = "Unknown NPC";
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		PreloadNPCNames()
		self:UnregisterEvent("PLAYER_LOGIN") 
	end
end)

if LOCALE == "enUS" then
	-- The EU English game client also
	-- uses the US English locale code.
	L["Vigor"] = "Vigor"
	L["Speedometer"] = "Speedometer"
	L["ToggleModelsName"] = "Show Vigor Models"
	L["ToggleModelsTT"] = "Display the swirling model effect on the vigor bubbles."
	L["SpeedPosPointName"] = "Speedometer Position"
	L["SpeedPosPointTT"] = "Adjusts where the speedometer is anchored to relative to the vigor bar."
	L["Top"] = "Top"
	L["Bottom"] = "Bottom"
	L["Left"] = "Left"
	L["Right"] = "Right"
	L["SpeedPosXName"] = "Speedometer Horizontal Position"
	L["SpeedPosXTT"] = "Adjust the horizontal position of the speedometer."
	L["SpeedPosYName"] = "Speedometer Vertical Position"
	L["SpeedPosYTT"] = "Adjust the vertical position of the speedometer."
	L["SpeedScaleName"] = "Speedometer Scale"
	L["SpeedScaleTT"] = "Adjust the scale of the speedometer."
	L["Large"] = "Large"
	L["Small"] = "Small"
	L["Units"] = "Speedometer Units Text" -- Changed in 11.2.7
	L["UnitsTT"] = "Change the units displayed on the speedometer.\n(Mechanically 1 metre = 1 yard)"
	L["UnitsColor"] = "Speedometer Units Text Color" -- Changed in 11.2.7
	L["UnitYards"] = "yds/s"
	L["Yards"] = "Yards"
	L["UnitMiles"] = "mph"
	L["Miles"] = "Miles"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Metres"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "Kilometres"
	L["UnitPercent"] = "%"
	L["Percent"] = "Percentage"
	L["SpeedTextScale"] = "Speedometer Text Size"
	L["SpeedTextScaleTT"] = "Adjust the size of the text on the speedometer."
	L["Version"] = "Version %s"
	L["ResetAllSettings"] = "Reset all Dragon Rider settings"
	L["ResetAllSettingsTT"] = "Resets all settings specifically for this addon. This will include the custom color values."
	L["ResetAllSettingsConfirm"] = "Are you sure you want to reset the settings for Dragon Rider?"
	L["Low"] = "Low"
	L["High"] = "High"
	L["ProgressBar"] = "Speedometer" -- Deprecated
	L["ProgressBarColor"] = "Speedometer Color" -- Deprecated
	L["ColorPickerLowProgTT"] = "Choose a custom color for the low speed values of the speedometer. This occurs when the player is not gaining any vigor." -- Deprecated
	L["ColorPickerMidProgTT"] = "Choose a custom color for the vigor speed values of the speedometer. This occurs when the player is gaining vigor within standard speed range." -- Deprecated
	L["ColorPickerHighProgTT"] = "Choose a custom color for the high speed values of the speedometer. This occurs when the player is gaining vigor, but is above the standard speed range." -- Deprecated
	L["ColorPickerLowTextTT"] = "Choose a custom color for the low speed values of the speedometer text. This occurs when the player is not gaining any vigor." -- Deprecated
	L["ColorPickerMidTextTT"] = "Choose a custom color for the vigor speed values of the speedometer text. This occurs when the player is gaining vigor within standard speed range." -- Deprecated
	L["ColorPickerHighTextTT"] = "Choose a custom color for the high speed values of the speedometer text. This occurs when the player is gaining vigor, but is above the standard speed range." -- Deprecated
	L["DragonridingTalents"] = "Skyriding Skills and Unlocks" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Skyriding Skills and Unlocks" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Open Skyriding Skills and Unlocks." -- Changed in 11.2.7
	L["SideArtName"] = "Side Art"
	L["SideArtTT"] = "Toggle the art on the sides of the main Vigor bar."
	L["BugfixesName"] = "Bugfixes" -- Deprecated
	L["BugfixesTT"] = "Experimental bug fix attempts for when default Blizzard frames aren't working as intended." -- Deprecated
	L["BugfixHideVigor"] = "Force Hide Vigor" -- Deprecated
	L["BugfixHideVigorTT"] = "Force hide the vigor bar when dismounted, and re-show when mounted on a skyriding mount." -- Deprecated
	L["FadeSpeedometer"] = "Fade Speedometer" -- Deprecated
	L["FadeSpeedometerTT"] = "Toggle fading the Speedometer when not gliding." -- Deprecated
	L["ShowVigorTooltip"] = "Show Vigor Tooltip"
	L["ShowVigorTooltipTT"] = "Toggle the tooltip that displays upon the Vigor bar."
	L["FadeVigor"] = "Fade Vigor"
	L["FadeVigorTT"] = "Toggle fading the Vigor bar when not gliding and while at full Vigor."
	L["LightningRush"] = "Show Static Charge Orbs" -- Changed in 11.2.7
	L["LightningRushTT"] = "Toggle the Static Charge orbs which are used by the Lightning Rush ability." -- Changed in 11.2.7
	L["DynamicFOV"] = "Dynamic FOV"
	L["DynamicFOVTT"] = "Enables adjustment of camera field of view based on gliding speed."
	L["Normal"] = "Normal"
	L["Advanced"] = "Advanced"
	L["Reverse"] = "Reverse"
	L["Challenge"] = "Challenge"
	L["ReverseChallenge"] = "Reverse Challenge"
	L["Storm"] = "Storm"
	L["COMMAND_help"] = "help"
	L["COMMAND_journal"] = "journal"
	L["COMMAND_listcommands"] = "A list of commands:"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "Dragon Rider"
	L["RightClick_TT_Line"] = "Right-Click: Open Settings"
	L["LeftClick_TT_Line"] = "Left-Click: Open Journal"
	L["SlashCommands_TT_Line"] = "'/dragonrider' for additional commands"
	L["Score"] = "Score"
	L["Guide"] = "Guide"
	L["Settings"] = "Settings"
	L["ComingSoon"] = "Coming Soon"
	L["UseAccountScores"] = "Use Account Scores"
	L["UseAccountScoresTT"] = "This will display your top account race scores instead of your character's scores. Account scores are indicated with an asterisk (*)."
	L["PersonalBest"] = "Personal Best: "
	L["AccountBest"] = "Account Best: "
	L["BestCharacter"] = "Best Character: "
	L["GoldTime"] = "Gold Time: "
	L["SilverTime"] = "Silver Time: "
	--L["SetMapPin_TT"] = "Click to set Map Pin"
	L["MuteVigorSound_Settings"] = "Mute Vigor Sound"
	L["MuteVigorSound_SettingsTT"] = "Toggle the sound that plays when the skyriding mount naturally gains a stack of vigor."
	L["SpeedometerTheme"] = "Speedometer Theme"
	L["SpeedometerThemeTT"] = "Customize the Speedometer theme."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimalist"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Timerunning Statistics"
	L["SkyridingCurrencyGained"] = "Skyriding %s Gained:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Show Speedometer"
	L["ToggleSpeedometerTT"] = "Toggle the Speedometer display."
	L["SpeedometerWidthName"] = "Speedometer Width" 
	L["SpeedometerWidthTT"] = "Adjust the width of the Speedometer frame."
	L["SpeedometerHeightName"] = "Speedometer Height"
	L["SpeedometerHeightTT"] = "Adjust the height of the Speedometer frame."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Requires closing the settings and landing for this to take effect.\n\nIncompatible with the \"Motion Sickness\" setting."
	L["DynamicFOVNewTT"] = "Enables adjustment of camera field of view based on gliding and D.R.I.V.E. speed."
	L["StaticChargeOffset"] = "Static Charge Offset"
	L["StaticChargeSpacing"] = "Static Charge Spacing"
	L["StaticChargeWidth"] = "Static Charge Width"
	L["StaticChargeHeight"] = "Static Charge Height"
	L["StaticChargeWidthTT"] = "Adjust the width of Static Charges."
	L["StaticChargeHeightTT"] = "Adjust the height of Static Charges."
	L["StaticChargeSpacingTT"] = "Adjust the spacing of Static Charges."
	L["StaticChargeOffsetTT"] = "Adjust the offset of Static Charges."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "Speedometer Low Speed Color"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Pick a color for speeds displayed on the Speedometer bar when slow."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Speedometer Recharge Speed Color"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Pick a color for speeds displayed on the Speedometer bar when Skyriding Charges recover at an accelerated rate (indicated by the Thrill of the Skies buff)."
	L["SpeedometerBar_Over_ColorPicker"] = "Speedometer Over Speed Color"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Pick a color for speeds displayed on the Speedometer bar when above the maximum natural gliding speed (indicated by the 2nd tick at 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Speedometer Text Low Speed Color"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Pick a color for speeds displayed by the Speedometer text when slow."
	L["SpeedometerText_Recharge_ColorPicker"] = "Speedometer Text Recharge Speed Color"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Pick a color for speeds displayed by the Speedometer text when Skyriding Charges recover at an accelerated rate (indicated by the Thrill of the Skies buff)."
	L["SpeedometerText_Over_ColorPicker"] = "Speedometer Text Over Speed Color"
	L["SpeedometerText_Over_ColorPickerTT"] = "Pick a color for speeds displayed by the Speedometer text when above the maximum natural gliding speed (indicated by the 2nd tick at 65%)."
	L["SpeedometerCover_ColorPicker"] = "Speedometer Cover Color"
	L["SpeedometerCover_ColorPickerTT"] = "Pick a color for the Speedometer Cover."
	L["SpeedometerTick_ColorPicker"] = "Speedometer Tick Color"
	L["SpeedometerTick_ColorPickerTT"] = "Pick a color for the Speedometer Ticks. These are the two lines at 60% and 65% speed."
	L["SpeedometerTopper_ColorPicker"] = "Speedometer Top Color"
	L["SpeedometerTopper_ColorPickerTT"] = "Pick a color for the Speedometer Top texture."
	L["SpeedometerFooter_ColorPicker"] = "Speedometer Bottom Color"
	L["SpeedometerFooter_ColorPickerTT"] = "Pick a color for the Speedometer Bottom texture."
	L["SpeedometerBackground_ColorPicker"] = "Speedometer Background Color"
	L["SpeedometerBackground_ColorPickerTT"] = "Pick a color for the Speedometer Background."
	L["SpeedometerSpark_ColorPicker"] = "Speedometer Spark Color" -- NYI
	L["SpeedometerSpark_ColorPickerTT"] = "Pick a color for the Speedometer Spark. This is the texture at the very edge of the current progress bar value." -- NYI

	-- New Vigor Bar Settings
	L["VigorTheme"] = "Vigor Theme"
	L["VigorThemeTT"] = "Customize the Vigor bar theme."
	L["VigorPosXName"] = "Vigor Horizontal Position" -- NYI
	L["VigorPosXNameTT"] = "Adjust the horizontal position of the Vigor bars." -- NYI
	L["VigorPosYName"] = "Vigor Vertical Position"
	L["VigorPosYNameTT"] = "Adjust the vertical position of the Vigor bar relative to the default UI."
	L["VigorBarWidthName"] = "Vigor Charge Width"
	L["VigorBarWidthNameTT"] = "Adjust the width of each Vigor charge."
	L["VigorBarHeightName"] = "Vigor Charge Height"
	L["VigorBarHeightNameTT"] = "Adjust the height of each Vigor charge."
	L["VigorBarSpacingName"] = "Vigor Charge Spacing"
	L["VigorBarSpacingNameTT"] = "Adjust the spacing between each Vigor charge."
	L["VigorBarOrientationName"] = "Vigor Charge Orientation"
	L["VigorBarOrientationNameTT"] = "Controls the layout direction of the Vigor bar."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Vigor Charge Growth Direction"
	L["VigorBarDirectionNameTT"] = "Controls which way the Vigor charge grows."
	L["Direction_DownRight"] = "Top-to-Bottom / Left-to-Right"
	L["Direction_UpLeft"] = "Bottom-to-Top / Right-to-Left"
	L["VigorWrapName"] = "Vigor Charge Limit"
	L["VigorWrapNameTT"] = "Set how many charges appear before wrapping to a new row or column."
	L["VigorBarFillDirectionName"] = "Vigor Charge Fill Direction"
	L["VigorBarFillDirectionNameTT"] = "Controls the direction individual charges fill up."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Fill Spark Thickness" -- NYI
	L["VigorSparkThicknessNameTT"] = "Adjust the width of the recharging spark effect." -- NYI
	L["ToggleFlashFullName"] = "Flash on Full"
	L["ToggleFlashFullNameTT"] = "Toggle the flash animation when a charge becomes full."
	L["ToggleFlashProgressName"] = "Flash on Progress"
	L["ToggleFlashProgressNameTT"] = "Toggle the pulsing animation when a charge is recharging."
	L["ModelThemeName"] = "Vigor Model Theme"
	L["ModelThemeNameTT"] = "Changes the visual effect for the Vigor models."
	L["SideArtStyleName"] = "Side Art Theme"
	L["SideArtStyleNameTT"] = "Changes the theme of the side art."
	L["SideArtPosX"] = "Side Art Horizontal Position"
	L["SideArtPosXTT"] = "Adjust the horizontal position of the side art."
	L["SideArtPosY"] = "Side Art Vertical Position"
	L["SideArtPosYTT"] = "Adjust the vertical position of the side art."
	L["SideArtRot"] = "Side Art Rotation"
	L["SideArtRotTT"] = "Adjust the rotation of the Side Art textures."
	L["SideArtScale"] = "Side Art Scale"
	L["SideArtScaleTT"] = "Adjust the size of the Side Art textures."
	L["DesaturatedOptionTT"] = "Some options are desaturated, allowing them to be colored better by the color picker options. Options which are not desaturated are best viewed with the color picker set to white (#FFFFFF)."
	
	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Vigor Full Color"
	L["VigorBar_Full_ColorPickerTT"] = "Pick a color for the Skyriding Charge when full."
	L["VigorBar_Empty_ColorPicker"] = "Vigor Empty Color"
	L["VigorBar_Empty_ColorPickerTT"] = "Pick a color for the Skyriding Charge when empty."
	L["VigorBar_Progress_ColorPicker"] = "Vigor Recharge Color"
	L["VigorBar_Progress_ColorPickerTT"] = "Pick a color for when the Skyriding Charge is recovering."
	L["VigorBarCover_ColorPicker"] = "Vigor Cover Color"
	L["VigorBarCover_ColorPickerTT"] = "Pick a color for Skyriding Charge Cover."
	L["VigorBarBackground_ColorPicker"] = "Vigor Background Color"
	L["VigorBarBackground_ColorPickerTT"] = "Pick a color for the Skyriding Charge Background."
	L["VigorBarSpark_ColorPicker"] = "Vigor Spark Color"
	L["VigorBarSpark_ColorPickerTT"] = "Pick a color for the Skyriding Charge spark. This is the texture at the very edge of the current progress bar value."
	L["VigorBarFlash_ColorPicker"] = "Vigor Flash Color"
	L["VigorBarFlash_ColorPickerTT"] = "Pick a color for Skyriding Charge flash upon reaching full or while recharging."
	L["VigorBarDecor_ColorPicker"] = "Vigor Side Art Color"
	L["VigorBarDecor_ColorPickerTT"] = "Pick a color for Side Art on the Vigor Bar."

	-- Additional Toggles
	L["ToggleTopper"] = "Show Speedometer Top"
	L["ToggleTopperTT"] = "Toggle the Speedometer Top texture."
	L["ToggleFooter"] = "Show Speedometer Bottom"
	L["ToggleFooterTT"] = "Toggle the Speedometer Bottom texture."
	L["ToggleVigor"] = "Show Vigor Bars"
	L["ToggleVigorTT"] = "Toggle the 6 Vigor bars associated with the spell charges for Surge Forward and Skyward Ascent."
	
	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Gold"
	L["ThemeAlgari_Bronze"] = "Algari - Bronze"
	L["ThemeAlgari_Dark"] = "Algari - Dark"
	L["ThemeAlgari_Silver"] = "Algari - Silver"
	L["ThemeDefault_Desaturated"] = "Default - Desaturated"
	L["ThemeAlgari_Desaturated"] = "Algari - Desaturated"
	L["ThemeGryphon_Desaturated"] = "Gryphon - Desaturated"
	L["ThemeWyvern_Desaturated"] = "Wyvern - Desaturated"
	L["ThemeDragon_Desaturated"] = "Dragon - Desaturated"
	
	-- Model Themes
	L["ModelTheme_Wind"] = "Wind"
	L["ModelTheme_Lightning"] = "Lightning"
	L["ModelTheme_FireForm"] = "Fire Form"
	L["ModelTheme_ArcaneForm"] = "Arcane Form"
	L["ModelTheme_FrostForm"] = "Frost Form"
	L["ModelTheme_HolyForm"] = "Holy Form"
	L["ModelTheme_NatureForm"] = "Nature Form"
	L["ModelTheme_ShadowForm"] = "Shadow Form"

	-- TOC translations
	L["DR_Title"] = "Dragon Rider"
	L["DR_Notes"] = "Displays a speedometer paired with the vigor bar and some other dragonriding-related options."


return end


if LOCALE == "zhCN" then
	-- Simplified Chinese translations go here
	-- Provided by 枫聖御雷 (https://legacy.curseforge.com/wow/addons/dragon-rider#c33)
	L["Vigor"] = "精力"
	L["Speedometer"] = "速度计"
	L["ToggleModelsName"] = "显示精力模型"
	L["ToggleModelsTT"] = "显示精力泡泡上的旋转模型效果。"
	L["SpeedPosPointName"] = "速度计位置"
	L["SpeedPosPointTT"] = "调整速度计相对于精力条的固定位置。"
	L["Top"] = "顶部"
	L["Bottom"] = "底部"
	L["Left"] = "左边"
	L["Right"] = "右边"
	L["SpeedPosXName"] = "速度计水平位置"
	L["SpeedPosXTT"] = "调整速度计的水平位置。"
	L["SpeedPosYName"] = "速度计垂直位置"
	L["SpeedPosYTT"] = "调整速度计的垂直位置。"
	L["SpeedScaleName"] = "速度计刻度"
	L["SpeedScaleTT"] = "调整速度计的刻度。"
	L["Large"] = "大的"
	L["Small"] = "小的"
	L["Units"] = "速度单位文字" -- Changed in 11.2.7
	L["UnitsTT"] = "更改速度计上显示的单位。\n（机械上 1 米 = 1 码）"
	L["UnitsColor"] = "速度单位文字颜色" -- Changed in 11.2.7
	L["UnitYards"] = "码/秒"
	L["Yards"] = "码数"
	L["UnitMiles"] = "英里/小时"
	L["Miles"] = "英里"
	L["UnitMeters"] = "米/秒"
	L["Meters"] = "米"
	L["UnitKilometers"] = "公里/小时"
	L["Kilometers"] = "公里"
	L["UnitPercent"] = "%"
	L["Percent"] = "百分比"
	L["SpeedTextScale"] = "速度计文字大小"
	L["SpeedTextScaleTT"] = "调整速度计上文字的大小。"
	L["Version"] = "版本 %s"
	L["ResetAllSettings"] = "重置所有龙骑士设置"
	L["ResetAllSettingsTT"] = "专门为此插件重置所有设置。 这将包括自定义颜色值。"
	L["ResetAllSettingsConfirm"] = "您确定要重置《龙骑士》的设置吗？"
	L["Low"] = "低"
	L["High"] = "高"
	L["ProgressBar"] = "速度计" -- Deprecated
	L["ProgressBarColor"] = "速度计颜色" -- Deprecated
	L["ColorPickerLowProgTT"] = "为速度计的低速值选择自定义颜色。 当玩家没有获得任何精力时就会发生这种情况。" -- Deprecated
	L["ColorPickerMidProgTT"] = "为速度计的精力速度值标准时选择自定义颜色。 当玩家在标准速度范围内获得精力时，就会发生这种情况。" -- Deprecated
	L["ColorPickerHighProgTT"] = "为速度计的高速值选择自定义颜色。 当玩家精力充沛但速度高于标准速度范围时，就会发生这种情况。" -- Deprecated
	L["ColorPickerLowTextTT"] = "为速度计的低速度值选择自定义颜色。 当玩家没有获得任何精力时就会发生这种情况。" -- Deprecated
	L["ColorPickerMidTextTT"] = "为速度计的精力速度值选择自定义颜色。 当玩家在标准速度范围内获得精力时，就会发生这种情况。" -- Deprecated
	L["ColorPickerHighTextTT"] = "为速度计的高速值选择自定义颜色。 当玩家精力充沛但速度高于标准速度范围时，就会发生这种情况。" -- Deprecated
	L["DragonridingTalents"] = "龙骑天赋" -- translated 11.0 -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "打开龙骑天赋窗口" -- translated 11.0 -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "打开龙骑天赋窗口。" -- translated 11.0 -- Changed in 11.2.7
	L["SideArtName"] = "侧面美化"
	L["SideArtTT"] = "切换主精力条两侧的美化。"
	L["BugfixesName"] = "Bug修复"
	L["BugfixesTT"] = "当默认暴雪框架未按预期工作时尝试进行实验性错误修复。"
	L["BugfixHideVigor"] = "强制隐藏精力条"
	L["BugfixHideVigorTT"] = "下坐骑时强制隐藏精力条，骑上驭空术飞行坐骑时重新显示。" -- translated 11.0
	L["FadeSpeedometer"] = "淡出速度计"
	L["FadeSpeedometerTT"] = "在不滑行时切换速度计的淡出。"
	L["ShowVigorTooltip"] = "显示精力条上鼠标提示"
	L["ShowVigorTooltipTT"] = "切换精力条上鼠标提示的显示。"
	L["FadeVigor"] = "淡出精力条"
	L["FadeVigorTT"] = "在不滑翔和充满精力时切换精力条的淡出。"
	L["LightningRush"] = "闪电冲刺显示" -- Changed in 11.2.7
	L["LightningRushTT"] = "切换用于“闪电冲击”技能的静电充能球体。" -- Changed in 11.2.7
	L["DynamicFOV"] = "动态视野"
	L["DynamicFOVTT"] = "能够根据飞行速度调整镜头视野。"
	L["Normal"] = "普通" -- translated (https://legacy.curseforge.com/wow/addons/dragon-rider#c43)
	L["Advanced"] = "进阶" -- translated
	L["Reverse"] = "反向" -- translated
	L["Challenge"] = "挑战" -- translated
	L["ReverseChallenge"] = "反向挑战" -- translated
	L["Storm"] = "风暴之速" -- translated
	L["COMMAND_help"] = "帮助"
	L["COMMAND_journal"] = "日志"
	L["COMMAND_listcommands"] = "命令列表:"
	L["COMMAND_dragonrider"] = "龙骑士"
	L["DragonRider"] = "龙骑手"
	L["RightClick_TT_Line"] = "右键点击：打开设置"
	L["LeftClick_TT_Line"] = "左键点击：打开日志"
	L["SlashCommands_TT_Line"] = "'/龙骑士' 以获取更多命令"
	L["Score"] = "得分"
	L["Guide"] = "指南"
	L["Settings"] = "设置"
	L["ComingSoon"] = "即将推出"
	L["UseAccountScores"] = "使用账号分数" -- translated
	L["UseAccountScoresTT"] = "这将显示您账号中最高的得分，而不是您当前角色的得分。账号得分用星号 (*) 表示。" -- translated
	L["PersonalBest"] = "个人最佳: "
	L["AccountBest"] = "账号最佳: " -- translated
	L["BestCharacter"] = "最佳角色: "
	L["GoldTime"] = "金牌时间: "
	L["SilverTime"] = "银牌时间: "
	L["MuteVigorSound_Settings"] = "静音精力音效" -- translated
	L["MuteVigorSound_SettingsTT"] = "切换驭空术坐骑获得精力时播放的声音。"  -- translated 11.0
	L["SpeedometerTheme"] = "速度计主题"
	L["SpeedometerThemeTT"] = "自定义速度计主题。"
	L["Algari"] = "阿加驭雷者"
	L["Default"] = DEFAULT
	L["Minimalist"] = "简单" -- (last updated https://github.com/nanjuekaien1/DragonRider-zhCN/blob/main/zhCN.lua)
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	--non-official translations
	L["TimerunningStatistics"] = "时光奔跑统计"
	L["SkyridingCurrencyGained"] = "获得天空骑行 %s："

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "显示速度表"
	L["ToggleSpeedometerTT"] = "切换显示速度表。"
	L["SpeedometerWidthName"] = "速度表宽度"
	L["SpeedometerWidthTT"] = "设置速度表框架宽度。"
	L["SpeedometerHeightName"] = "速度表高度"
	L["SpeedometerHeightTT"] = "设置速度表框架高度。"
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "需要关闭设置并着陆后才能生效。\n\n与“动态眩晕”选项不兼容."
	L["DynamicFOVNewTT"] = "根据滑翔和 D.R.I.V.E. 速度调整相机视野。"
	L["StaticChargeOffset"] = "静电充能偏移"
	L["StaticChargeSpacing"] = "静电充能间距"
	L["StaticChargeSize"] = "静电充能大小"
	L["StaticChargeWidth"] = "静电充能宽度"
	L["StaticChargeHeight"] = "静电充能高度"
	L["StaticChargeWidthTT"] = "调整静电充能的宽度。"
	L["StaticChargeHeightTT"] = "调整静电充能的高度。"
	L["StaticChargeSpacingTT"] = "调整静电充能的间距。"
	L["StaticChargeOffsetTT"] = "调整静电充能的偏移。"
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "慢速颜色"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "选择慢速值的颜色。"
	L["SpeedometerBar_Recharge_ColorPicker"] = "充能颜色"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "选择充能速度增加时的颜色（“天雷之力”效果）。"
	L["SpeedometerBar_Over_ColorPicker"] = "超速颜色"
	L["SpeedometerBar_Over_ColorPickerTT"] = "选择超过自然最大值的颜色（65%显示）。"
	L["SpeedometerText_Slow_ColorPicker"] = "慢速文字颜色"
	L["SpeedometerText_Slow_ColorPickerTT"] = "选择慢速文字的颜色。"
	L["SpeedometerText_Recharge_ColorPicker"] = "充能文字颜色"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "选择充能文字的颜色。"
	L["SpeedometerText_Over_ColorPicker"] = "超速文字颜色"
	L["SpeedometerText_Over_ColorPickerTT"] = "选择超速文字的颜色。"
	L["SpeedometerCover_ColorPicker"] = "速度表覆盖颜色"
	L["SpeedometerCover_ColorPickerTT"] = "选择覆盖颜色。"
	L["SpeedometerTick_ColorPicker"] = "刻度线颜色"
	L["SpeedometerTick_ColorPickerTT"] = "选择60%和65%刻度线颜色。"
	L["SpeedometerTopper_ColorPicker"] = "顶部装饰颜色"
	L["SpeedometerTopper_ColorPickerTT"] = "选择顶部装饰颜色。"
	L["SpeedometerFooter_ColorPicker"] = "底部装饰颜色"
	L["SpeedometerFooter_ColorPickerTT"] = "选择底部装饰颜色。"
	L["SpeedometerBackground_ColorPicker"] = "背景颜色"
	L["SpeedometerBackground_ColorPickerTT"] = "选择速度表背景颜色。"
	L["SpeedometerSpark_ColorPicker"] = "火花颜色"
	L["SpeedometerSpark_ColorPickerTT"] = "选择速度表末端火花颜色。"

	-- New Vigor Bar Settings
	L["VigorTheme"] = "活力主题"
	L["VigorThemeTT"] = "设置活力面板主题。"
	L["VigorPosXName"] = "活力面板X位置"
	L["VigorPosXNameTT"] = "设置活力面板水平位置。"
	L["VigorPosYName"] = "活力面板Y位置"
	L["VigorPosYNameTT"] = "设置活力面板垂直位置。"
	L["VigorBarWidthName"] = "活力格宽度"
	L["VigorBarWidthNameTT"] = "设置每个活力格的宽度。"
	L["VigorBarHeightName"] = "活力格高度"
	L["VigorBarHeightNameTT"] = "设置每个活力格的高度。"
	L["VigorBarSpacingName"] = "格间距"
	L["VigorBarSpacingNameTT"] = "设置活力格之间的间距。"
	L["VigorBarOrientationName"] = "活力面板方向"
	L["VigorBarOrientationNameTT"] = "设置面板整体方向。"
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "格子排列方向"
	L["VigorBarDirectionNameTT"] = "设置活力格排列方向。"
	L["Direction_DownRight"] = "从上到下 / 从左到右"
	L["Direction_UpLeft"] = "从下到上 / 从右到左"
	L["VigorWrapName"] = "每行/列格数"
	L["VigorWrapNameTT"] = "设置每行或每列显示的格数。"
	L["VigorBarFillDirectionName"] = "格填充方向"
	L["VigorBarFillDirectionNameTT"] = "设置格内部填充方向。"
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "火花厚度"
	L["VigorSparkThicknessNameTT"] = "设置活力格火花厚度。"
	L["ToggleFlashFullName"] = "满格闪烁"
	L["ToggleFlashFullNameTT"] = "格满时启用闪烁。"
	L["ToggleFlashProgressName"] = "恢复格脉动"
	L["ToggleFlashProgressNameTT"] = "格恢复中时启用脉动效果。"
	L["ModelThemeName"] = "模型主题"
	L["ModelThemeNameTT"] = "更改活力模型主题。"
	L["SideArtStyleName"] = "侧边装饰主题"
	L["SideArtStyleNameTT"] = "更改侧边装饰风格。"
	L["SideArtPosX"] = "侧边装饰X位置"
	L["SideArtPosXTT"] = "设置侧边装饰水平位置。"
	L["SideArtPosY"] = "侧边装饰Y位置"
	L["SideArtPosYTT"] = "设置侧边装饰垂直位置。"
	L["SideArtRot"] = "侧边装饰旋转"
	L["SideArtRotTT"] = "设置侧边装饰旋转角度。"
	L["SideArtScale"] = "侧边装饰缩放"
	L["SideArtScaleTT"] = "设置侧边装饰大小。"
	L["DesaturatedOptionTT"] = "部分选项被去饱和，这可使颜色选择器更好地应用颜色。未去饱和的选项在颜色选择器设为白色 (#FFFFFF) 时视觉效果最佳。"

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "满格颜色"
	L["VigorBar_Full_ColorPickerTT"] = "选择满格颜色。"
	L["VigorBar_Empty_ColorPicker"] = "空格颜色"
	L["VigorBar_Empty_ColorPickerTT"] = "选择空格颜色。"
	L["VigorBar_Progress_ColorPicker"] = "恢复格颜色"
	L["VigorBar_Progress_ColorPickerTT"] = "选择恢复格颜色。"
	L["VigorBarCover_ColorPicker"] = "格覆盖颜色"
	L["VigorBarCover_ColorPickerTT"] = "选择格覆盖颜色。"
	L["VigorBarBackground_ColorPicker"] = "背景颜色"
	L["VigorBarBackground_ColorPickerTT"] = "选择活力格背景颜色。"
	L["VigorBarSpark_ColorPicker"] = "火花颜色"
	L["VigorBarSpark_ColorPickerTT"] = "选择活力格火花颜色。"
	L["VigorBarFlash_ColorPicker"] = "闪烁颜色"
	L["VigorBarFlash_ColorPickerTT"] = "选择恢复或满格时闪烁颜色。"
	L["VigorBarDecor_ColorPicker"] = "装饰颜色"
	L["VigorBarDecor_ColorPickerTT"] = "选择侧边装饰颜色。"

	-- Additional Toggles
	L["ToggleTopper"] = "显示顶部装饰"
	L["ToggleTopperTT"] = "显示速度表顶部装饰。"
	L["ToggleFooter"] = "显示底部装饰"
	L["ToggleFooterTT"] = "显示速度表底部装饰。"
	L["ToggleVigor"] = "显示活力面板"
	L["ToggleVigorTT"] = "显示6格活力面板。"
	
	-- Themes
	L["ThemeAlgari_Gold"] = "阿加里 - 金色"
	L["ThemeAlgari_Bronze"] = "阿加里 - 青铜"
	L["ThemeAlgari_Dark"] = "阿加里 - 深色"
	L["ThemeAlgari_Silver"] = "阿加里 - 银色"
	L["ThemeDefault_Desaturated"] = "默认 - 去饱和"
	L["ThemeAlgari_Desaturated"] = "阿加里 - 去饱和"
	L["ThemeGryphon_Desaturated"] = "狮鹫 - 去饱和"
	L["ThemeWyvern_Desaturated"] = "双足飞龙 - 去饱和"
	L["ThemeDragon_Desaturated"] = "巨龙 - 去饱和"

	-- Model Themes
	L["ModelTheme_Wind"] = "风"
	L["ModelTheme_Lightning"] = "闪电"
	L["ModelTheme_FireForm"] = "火焰形态"
	L["ModelTheme_ArcaneForm"] = "奥术形态"
	L["ModelTheme_FrostForm"] = "冰霜形态"
	L["ModelTheme_HolyForm"] = "神圣形态"
	L["ModelTheme_NatureForm"] = "自然形态"
	L["ModelTheme_ShadowForm"] = "暗影形态"

	-- TOC translations
	L["DR_Title"] = "Dragon Rider: 龙骑士"
	L["DR_Notes"] = "显示与活力条和其他一些与龙骑术相关的选项配对的速度计。"


return end

if LOCALE == "zhTW" then
	-- Traditional Chinese translations go here
	L["Vigor"] = "活力"
	L["Speedometer"] = "速度條"
	L["ToggleModelsName"] = "顯示活力動畫"
	L["ToggleModelsTT"] = "顯示活力氣泡上的旋轉動畫效果。"
	L["SpeedPosPointName"] = "速度條位置"
	L["SpeedPosPointTT"] = "調整速度計相對於活力條的固定位置。"
	L["Top"] = "上"
	L["Bottom"] = "下"
	L["Left"] = "左"
	L["Right"] = "右"
	L["SpeedPosXName"] = "速度條水平位置"
	L["SpeedPosXTT"] = "調整速度條的水平位置。"
	L["SpeedPosYName"] = "速度條垂直位置"
	L["SpeedPosYTT"] = "調整速度條的垂直位置。"
	L["SpeedScaleName"] = "速度條刻度"
	L["SpeedScaleTT"] = "調整速度條的刻度。"
	L["Large"] = "大的"
	L["Small"] = "小的"
	L["Units"] = "速度單位文字" -- Changed in 11.2.7
	L["UnitsTT"] = "更改車速表上顯示的單位。\n（機械上 1 米 = 1 碼）"
	L["UnitsColor"] = "速度單位文字顏色" -- Changed in 11.2.7
	L["UnitYards"] = "碼/秒"
	L["Yards"] = "碼數"
	L["UnitMiles"] = "英里/小時"
	L["Miles"] = "英里"
	L["UnitMeters"] = "米/秒"
	L["Meters"] = "米"
	L["UnitKilometers"] = "公里/小時"
	L["Kilometers"] = "公里"
	L["UnitPercent"] = "%"
	L["Percent"] = "百分比"
	L["SpeedTextScale"] = "速度條文字大小"
	L["SpeedTextScaleTT"] = "調整速度條上文字的大小。"
	L["Version"] = "版本 %s"
	L["ResetAllSettings"] = "重置所有飛行速度條的設定"
	L["ResetAllSettingsTT"] = "重置此插件的所有設定，包含自訂顏色。"
	L["ResetAllSettingsConfirm"] = "是否確定要重置飛行速度條的設定?"
	L["Low"] = "低的"
	L["High"] = "高的"
	L["ProgressBar"] = "速度條"
	L["ProgressBarColor"] = "速度條顏色"
	L["ColorPickerLowProgTT"] = "為速度條的低速值選擇自訂顏色。當玩家沒有獲得任何活力時會顯示。"
	L["ColorPickerMidProgTT"] = "為速度條的活力速度值選擇自訂顏色。當玩家在標準速度範圍內獲得活力時會顯示。"
	L["ColorPickerHighProgTT"] = "為速度條的高速值選擇自訂顏色。當玩家精力充沛但速度高於標準速度範圍時會顯示。"
	L["ColorPickerLowTextTT"] = "為速度條的低速度值選擇自訂顏色。當玩家沒有獲得任何活力時會顯示。"
	L["ColorPickerMidTextTT"] = "為速度條的活力速度值選擇自訂顏色。當玩家在標準速度範圍內獲得活力時會顯示。"
	L["ColorPickerHighTextTT"] = "為速度值的高速值選擇自訂顏色。當玩家精力充沛但速度高於標準速度範圍時會顯示。"
	L["DragonridingTalents"] = "天空騎術天賦"
	L["OpenDragonridingTalents"] = "打開天空騎術天賦"
	L["OpenDragonridingTalentsTT"] = "打開天空騎術天賦視窗。"
	L["SideArtName"] = "兩側的美術圖案"
	L["SideArtTT"] = "切換主活力條兩側的美術圖案。"
	L["BugfixesName"] = "Bug 修正"
	L["BugfixesTT"] = "當預設暴雪框架未如預期工作時嘗試進行實驗性錯誤修復。"
	L["BugfixHideVigor"] = "強制隱藏活力"
	L["BugfixHideVigorTT"] = "下坐騎時強制隱藏活力條，在天空騎術坐騎上時重新顯示。"
	L["FadeSpeedometer"] = "淡出速度條"
	L["FadeSpeedometerTT"] = "沒有滑翔時淡出速度條。"
	L["ShowVigorTooltip"] = "顯示活力浮動提示資訊"
	L["ShowVigorTooltipTT"] = "顯示活力條的浮動提示資訊。"
	L["FadeVigor"] = "淡出活力"
	L["FadeVigorTT"] = "沒有滑翔而且活力全滿時淡出活力條。"
	L["LightningRush"] = "靜電荷球"
	L["LightningRushTT"] = "切換為靜電充能光環所製作的自訂框架，這些光環是由阿爾加風暴飛騎的閃電衝刺技能所使用的。"
	L["DynamicFOV"] = "動態視野"
	L["DynamicFOVTT"] = "啟用根據滑翔速度調整相機視野。"	
	L["Normal"] = "普通"
	L["Advanced"] = "進階"
	L["Reverse"] = "逆向"
	L["Challenge"] = "挑戰"
	L["ReverseChallenge"] = "逆向挑戰"
	L["Storm"] = "風暴"
	L["COMMAND_help"] = "說明"
	L["COMMAND_journal"] = "日誌"
	L["COMMAND_listcommands"] = "可使用的指令:"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "飛行速度條"
	L["RightClick_TT_Line"] = "右鍵: 打開設定"
	L["LeftClick_TT_Line"] = "左鍵: 打開日誌"
	L["SlashCommands_TT_Line"] = "輸入 '/dragonrider' 查看更多指令"
	L["Score"] = "分數"
	L["Guide"] = "指南"
	L["Settings"] = "設定"
	L["ComingSoon"] = "即將推出"
	L["UseAccountScores"] = "使用帳號分數"
	L["UseAccountScoresTT"] = "將會顯示帳號中的最高分，而不是當前角色的分數。帳號分數會加上星號(*)。"
	L["PersonalBest"] = "個人最佳: "
	L["AccountBest"] = "帳號最佳: "
	L["BestCharacter"] = "最佳角色: "
	L["GoldTime"] = "金牌時間: "
	L["SilverTime"] = "銀牌時間: "
	L["MuteVigorSound_Settings"] = "靜音活力音效"
	L["MuteVigorSound_SettingsTT"] = "切換飛龍坐騎自然獲得活力格數時播放的音效。"
	L["SpeedometerTheme"] = "速度條主題"
	L["SpeedometerThemeTT"] = "自訂速度條主題。"
	L["Algari"] = "阿爾加"
	L["Default"] = DEFAULT
	L["Minimalist"] = "極簡主義"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "時光奔跑統計"
	L["SkyridingCurrencyGained"] = "獲得天空騎乘 %s："

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "顯示速度表"
	L["ToggleSpeedometerTT"] = "切換顯示速度表。"
	L["SpeedometerWidthName"] = "速度表寬度"
	L["SpeedometerWidthTT"] = "設定速度表框架寬度。"
	L["SpeedometerHeightName"] = "速度表高度"
	L["SpeedometerHeightTT"] = "設定速度表框架高度。"
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "需要關閉設定並著陸後才會生效。\n\n與「畫面暈眩」設定不相容。"
	L["DynamicFOVNewTT"] = "依據滑翔與 D.R.I.V.E. 速度調整相機視野。"
	L["StaticChargeOffset"] = "静电充能偏移"
	L["StaticChargeSpacing"] = "静电充能间距"
	L["StaticChargeSize"] = "静电充能大小"
	L["StaticChargeWidth"] = "靜電能量寬度"
	L["StaticChargeHeight"] = "靜電能量高度"
	L["StaticChargeWidthTT"] = "調整靜電能量的寬度。"
	L["StaticChargeHeightTT"] = "調整靜電能量的高度。"
	L["StaticChargeSpacingTT"] = "調整靜電能量的間距。"
	L["StaticChargeOffsetTT"] = "調整靜電能量的偏移。"
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "慢速顏色"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "選擇慢速值的顏色。"
	L["SpeedometerBar_Recharge_ColorPicker"] = "充能顏色"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "選擇充能速度增加時的顏色（「天雷之力」效果）。"
	L["SpeedometerBar_Over_ColorPicker"] = "超速顏色"
	L["SpeedometerBar_Over_ColorPickerTT"] = "選擇超過自然最大值的顏色（65%顯示）。"
	L["SpeedometerText_Slow_ColorPicker"] = "慢速文字顏色"
	L["SpeedometerText_Slow_ColorPickerTT"] = "選擇慢速文字的顏色。"
	L["SpeedometerText_Recharge_ColorPicker"] = "充能文字顏色"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "選擇充能文字的顏色。"
	L["SpeedometerText_Over_ColorPicker"] = "超速文字顏色"
	L["SpeedometerText_Over_ColorPickerTT"] = "選擇超速文字的顏色。"
	L["SpeedometerCover_ColorPicker"] = "速度表覆蓋顏色"
	L["SpeedometerCover_ColorPickerTT"] = "選擇覆蓋顏色。"
	L["SpeedometerTick_ColorPicker"] = "刻度線顏色"
	L["SpeedometerTick_ColorPickerTT"] = "選擇60%和65%刻度線顏色。"
	L["SpeedometerTopper_ColorPicker"] = "頂部裝飾顏色"
	L["SpeedometerTopper_ColorPickerTT"] = "選擇頂部裝飾顏色。"
	L["SpeedometerFooter_ColorPicker"] = "底部裝飾顏色"
	L["SpeedometerFooter_ColorPickerTT"] = "選擇底部裝飾顏色。"
	L["SpeedometerBackground_ColorPicker"] = "背景顏色"
	L["SpeedometerBackground_ColorPickerTT"] = "選擇速度表背景顏色。"
	L["SpeedometerSpark_ColorPicker"] = "火花顏色"
	L["SpeedometerSpark_ColorPickerTT"] = "選擇速度表末端火花顏色。"

	-- New Vigor Bar Settings
	L["VigorTheme"] = "活力主題"
	L["VigorThemeTT"] = "設定活力面板主題。"
	L["VigorPosXName"] = "活力面板X位置"
	L["VigorPosXNameTT"] = "設定活力面板水平位置。"
	L["VigorPosYName"] = "活力面板Y位置"
	L["VigorPosYNameTT"] = "設定活力面板垂直位置。"
	L["VigorBarWidthName"] = "活力格寬度"
	L["VigorBarWidthNameTT"] = "設定每個活力格的寬度。"
	L["VigorBarHeightName"] = "活力格高度"
	L["VigorBarHeightNameTT"] = "設定每個活力格的高度。"
	L["VigorBarSpacingName"] = "格間距"
	L["VigorBarSpacingNameTT"] = "設定活力格之間的間距。"
	L["VigorBarOrientationName"] = "活力面板方向"
	L["VigorBarOrientationNameTT"] = "設定面板整體方向。"
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "格子排列方向"
	L["VigorBarDirectionNameTT"] = "設定活力格排列方向。"
	L["Direction_DownRight"] = "由上往下 / 由左往右"
	L["Direction_UpLeft"] = "由下往上 / 由右往左"
	L["VigorWrapName"] = "每行/列格數"
	L["VigorWrapNameTT"] = "設定每行或每列顯示的格數。"
	L["VigorBarFillDirectionName"] = "格填充方向"
	L["VigorBarFillDirectionNameTT"] = "設定格內部填充方向。"
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "火花厚度"
	L["VigorSparkThicknessNameTT"] = "設定活力格火花厚度。"
	L["ToggleFlashFullName"] = "滿格閃爍"
	L["ToggleFlashFullNameTT"] = "格滿時啟用閃爍。"
	L["ToggleFlashProgressName"] = "恢復格脈動"
	L["ToggleFlashProgressNameTT"] = "格恢復中時啟用脈動效果。"
	L["ModelThemeName"] = "模型主題"
	L["ModelThemeNameTT"] = "更改活力模型主題。"
	L["SideArtStyleName"] = "側邊裝飾主題"
	L["SideArtStyleNameTT"] = "更改側邊裝飾風格。"
	L["SideArtPosX"] = "側邊裝飾X位置"
	L["SideArtPosXTT"] = "設定側邊裝飾水平位置。"
	L["SideArtPosY"] = "側邊裝飾Y位置"
	L["SideArtPosYTT"] = "設定側邊裝飾垂直位置。"
	L["SideArtRot"] = "側邊裝飾旋轉"
	L["SideArtRotTT"] = "設定側邊裝飾旋轉角度。"
	L["SideArtScale"] = "側邊裝飾縮放"
	L["SideArtScaleTT"] = "設定側邊裝飾大小。"
	L["DesaturatedOptionTT"] = "部分選項已降低飽和度，使其更容易被色彩選擇器著色。未降低飽和度的選項在將色彩選擇器設為白色 (#FFFFFF) 時效果最佳。"

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "滿格顏色"
	L["VigorBar_Full_ColorPickerTT"] = "選擇滿格顏色。"
	L["VigorBar_Empty_ColorPicker"] = "空格顏色"
	L["VigorBar_Empty_ColorPickerTT"] = "選擇空格顏色。"
	L["VigorBar_Progress_ColorPicker"] = "恢復格顏色"
	L["VigorBar_Progress_ColorPickerTT"] = "選擇恢復格顏色。"
	L["VigorBarCover_ColorPicker"] = "格覆蓋顏色"
	L["VigorBarCover_ColorPickerTT"] = "選擇格覆蓋顏色。"
	L["VigorBarBackground_ColorPicker"] = "背景顏色"
	L["VigorBarBackground_ColorPickerTT"] = "選擇活力格背景顏色。"
	L["VigorBarSpark_ColorPicker"] = "火花顏色"
	L["VigorBarSpark_ColorPickerTT"] = "選擇活力格火花顏色。"
	L["VigorBarFlash_ColorPicker"] = "閃爍顏色"
	L["VigorBarFlash_ColorPickerTT"] = "選擇恢復或滿格時閃爍顏色。"
	L["VigorBarDecor_ColorPicker"] = "裝飾顏色"
	L["VigorBarDecor_ColorPickerTT"] = "選擇側邊裝飾顏色。"

	-- Additional Toggles
	L["ToggleTopper"] = "顯示頂部裝飾"
	L["ToggleTopperTT"] = "顯示速度表頂部裝飾。"
	L["ToggleFooter"] = "顯示底部裝飾"
	L["ToggleFooterTT"] = "顯示速度表底部裝飾。"
	L["ToggleVigor"] = "顯示活力面板"
	L["ToggleVigorTT"] = "顯示6格活力面板。"
	
	-- Themes
	L["ThemeAlgari_Gold"] = "阿加里 - 金色"
	L["ThemeAlgari_Bronze"] = "阿加里 - 青銅"
	L["ThemeAlgari_Dark"] = "阿加里 - 深色"
	L["ThemeAlgari_Silver"] = "阿加里 - 銀色"
	L["ThemeDefault_Desaturated"] = "預設 - 降低飽和度"
	L["ThemeAlgari_Desaturated"] = "阿加里 - 降低飽和度"
	L["ThemeGryphon_Desaturated"] = "獅鷲 - 降低飽和度"
	L["ThemeWyvern_Desaturated"] = "雙足飛龍 - 降低飽和度"
	L["ThemeDragon_Desaturated"] = "巨龍 - 降低飽和度"

	-- Model Themes
	L["ModelTheme_Wind"] = "風"
	L["ModelTheme_Lightning"] = "閃電"
	L["ModelTheme_FireForm"] = "火焰形態"
	L["ModelTheme_ArcaneForm"] = "祕法形態"
	L["ModelTheme_FrostForm"] = "冰霜形態"
	L["ModelTheme_HolyForm"] = "神聖形態"
	L["ModelTheme_NatureForm"] = "自然形態"
	L["ModelTheme_ShadowForm"] = "暗影形態"


	-- TOC translations
	L["DR_Title"] = "飛行速度條"
	L["DR_Notes"] = "顯示與活力條和其他一些與龍騎術相關的選項配對的速度計。"


return end
