local _, L = ...; -- Let's use the private table passed to every .lua 

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
            hiddenTip = CreateFrame("GameTooltip", "MyHiddenTooltip", UIParent, "GameTooltipTemplate");
            hiddenTip:SetOwner(UIParent, "ANCHOR_NONE");
        end
        hiddenTip:SetHyperlink(link);
        return MyHiddenTooltipTextLeft1:GetText();
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

PreloadNPCNames()


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
	L["Units"] = "Speedometer Text"
	L["UnitsTT"] = "Change the units displayed on the speedometer.\n(Mechanically 1 metre = 1 yard)"
	L["UnitsColor"] = "Speedometer Text Color"
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
	L["ProgressBar"] = "Speedometer"
	L["ProgressBarColor"] = "Speedometer Color"
	L["ColorPickerLowProgTT"] = "Choose a custom color for the low speed values of the speedometer. This occurs when the player is not gaining any vigor."
	L["ColorPickerMidProgTT"] = "Choose a custom color for the vigor speed values of the speedometer. This occurs when the player is gaining vigor within standard speed range."
	L["ColorPickerHighProgTT"] = "Choose a custom color for the high speed values of the speedometer. This occurs when the player is gaining vigor, but is above the standard speed range."
	L["ColorPickerLowTextTT"] = "Choose a custom color for the low speed values of the speedometer text. This occurs when the player is not gaining any vigor."
	L["ColorPickerMidTextTT"] = "Choose a custom color for the vigor speed values of the speedometer text. This occurs when the player is gaining vigor within standard speed range."
	L["ColorPickerHighTextTT"] = "Choose a custom color for the high speed values of the speedometer text. This occurs when the player is gaining vigor, but is above the standard speed range."
	L["DragonridingTalents"] = "Skyriding Talents"
	L["OpenDragonridingTalents"] = "Open Skyriding Talents"
	L["OpenDragonridingTalentsTT"] = "Open Skyriding Talents Window."
	L["SideArtName"] = "Side Art"
	L["SideArtTT"] = "Toggle the art on the sides of the main Vigor bar."
	L["BugfixesName"] = "Bugfixes"
	L["BugfixesTT"] = "Experimental bug fix attempts for when default Blizzard frames aren't working as intended."
	L["BugfixHideVigor"] = "Force Hide Vigor"
	L["BugfixHideVigorTT"] = "Force hide the vigor bar when dismounted, and re-show when mounted on a skyriding mount."
	L["FadeSpeedometer"] = "Fade Speedometer"
	L["FadeSpeedometerTT"] = "Toggle fading the Speedometer when not gliding."
	L["ShowVigorTooltip"] = "Show Vigor Tooltip"
	L["ShowVigorTooltipTT"] = "Toggle the tooltip that displays upon the Vigor bar."
	L["FadeVigor"] = "Fade Vigor"
	L["FadeVigorTT"] = "Toggle fading the Vigor bar when not gliding and while at full Vigor."
	L["LightningRush"] = "Static Charge Orbs"
	L["LightningRushTT"] = "Toggle custom frames made for Static Charge auras which are used by the Algarian Stormrider's Lightning Rush ability."
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
	L["Units"] = "速度计文本"
	L["UnitsTT"] = "更改速度计上显示的单位。\n（机械上 1 米 = 1 码）"
	L["UnitsColor"] = "速度计文字颜色"
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
	L["ProgressBar"] = "速度计"
	L["ProgressBarColor"] = "速度计颜色"
	L["ColorPickerLowProgTT"] = "为速度计的低速值选择自定义颜色。 当玩家没有获得任何精力时就会发生这种情况。"
	L["ColorPickerMidProgTT"] = "为速度计的精力速度值标准时选择自定义颜色。 当玩家在标准速度范围内获得精力时，就会发生这种情况。"
	L["ColorPickerHighProgTT"] = "为速度计的高速值选择自定义颜色。 当玩家精力充沛但速度高于标准速度范围时，就会发生这种情况。"
	L["ColorPickerLowTextTT"] = "为速度计的低速度值选择自定义颜色。 当玩家没有获得任何精力时就会发生这种情况。"
	L["ColorPickerMidTextTT"] = "为速度计的精力速度值选择自定义颜色。 当玩家在标准速度范围内获得精力时，就会发生这种情况。"
	L["ColorPickerHighTextTT"] = "为速度计的高速值选择自定义颜色。 当玩家精力充沛但速度高于标准速度范围时，就会发生这种情况。"
	L["DragonridingTalents"] = "驭空术天赋" -- translated 11.0
	L["OpenDragonridingTalents"] = "打开驭空术天赋" -- translated 11.0
	L["OpenDragonridingTalentsTT"] = "打开驭空术天赋窗口。" -- translated 11.0
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
	L["LightningRush"] = "静电荷球"
	L["LightningRushTT"] = "切换为阿加驭雷者“奔雷疾冲”技能使用的静电光环制作的自定义框架。"
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
	L["Units"] = "速度條文字"
	L["UnitsTT"] = "更改速度條上顯示的單位。\n（機械上 1 米 = 1 碼）"
	L["UnitsColor"] = "速度條文字顏色"
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

return end
