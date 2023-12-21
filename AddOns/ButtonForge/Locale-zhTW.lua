--[[
    Author: Alternator (Massiner of Nathrezim)
    Translator: moripi
    Copyright 2010
    
    Notes: Primary locale (will be used if a particular locale is not loaded)

--]]


BFLocales["zhTW"] = {};
local Locale = BFLocales["zhTW"];

local Const = BFConst;

Locale["ScaleTooltip"] = "拖曳來縮放大小\n|c"..Const.LightBlue.."(點兩下還原成預設大小)|r";
Locale["ColsTooltip"] = "增加/減少按鈕直行";
Locale["RowsTooltip"] = "增加/減少按鈕橫列";
Locale["GridTooltip"] = "隱藏空按鈕\n";
Locale["TooltipsTooltip"] = "顯示滑鼠提示\n";
Locale["ButtonLockTooltip"] = "鎖定快捷列 (按住 'Shift' 拖曳移動按鈕圖示)\n";
Locale["HideVehicleTooltip"] = "在載具上時隱藏快捷列\n";
Locale["HideSpec1Tooltip"] = "第一專精時隱藏快捷列\n";
Locale["HideSpec2Tooltip"] = "第二專精時隱藏快捷列\n";
Locale["HideSpec3Tooltip"] = "第三專精時隱藏快捷列\n";
Locale["HideSpec4Tooltip"] = "第四專精時隱藏快捷列\n";
Locale["HideBonusBarTooltip"] = "有特殊快捷列時隱藏快捷列\n";
Locale["SendToBackTooltip"] = "快捷列置前";
Locale["SendToFrontTooltip"] = "快捷列置後";
Locale["VisibilityTooltip"] = "用巨集控制快捷列隱藏/顯示\n";
Locale["VisibilityEgTooltip"] = "例如 |c"..Const.LightBlue.."[combat] hide; show|r";		--Appended to the Visibility tooltip if no driver is set for that bar
Locale["KeyBindModeTooltip"] = "設定按鍵綁定";
Locale["LabelModeTooltip"] = "輸入/編輯快捷列標籤";
Locale["AdvancedToolsTooltip"] = "顯示/隱藏進階設定選項";
Locale["DestroyBarTooltip"] = "刪除快捷列";
Locale["CreateBarTooltip"] = "新增快捷列";
Locale["CreateBonusBarTooltip"] = "新增特殊快捷列\n|c"..Const.LightBlue.."(給專業、載具或特定戰鬥的特別技能使用)|r";
Locale["RightClickSelfCastTooltip"] = "右鍵點擊對自己施法\n"
Locale["ConfigureModePrimaryTooltip"] = "顯示/隱藏更多快捷列工具\n提示: |c"..Const.LightBlue.."可以拖曳到更多快捷列上使用|r";
Locale["ConfigureModeTooltip"] = "更多快捷列設定選項";
Locale["BonusActionTooltip"] = "特殊快捷列動作";
Locale["Shown"] = "|c"..Const.DarkOrange.."不隱藏|r";
Locale["Hidden"] = "|c"..Const.DarkOrange.."已隱藏|r";
Locale["Locked"] = "|c"..Const.DarkOrange.."已鎖定|r";
Locale["Unlocked"] = "|c"..Const.DarkOrange.."已解鎖|r";
Locale["Enabled"] = "|c"..Const.DarkOrange.."已啟用|r";
Locale["Disabled"] = "|c"..Const.DarkOrange.."已停用|r";
Locale["CancelPossessionTooltip"] = "取消所有權";
Locale["UpgradedChatMsg"] = "更多快捷列的儲存資料已升級到: ";
Locale["DisableAutoAlignmentTooltip"] = "拖曳時按住 'Shift' 來停用自動對齊";
Locale["GUIHidden"] = Locale["Hidden"].." (不會影響按鍵綁定)";

--Warning/error messages
Locale["CreateBonusBarError"] = "只能在更多快捷列的設定模式中使用。";
Locale["ActionFailedCombatLockdown"] = "更多快捷列: 戰鬥中無法執行這個動作。";	--Hopefully I don't need to go more specific on this one (it could be possible players missinterpret it as an error, I'll give it a trial run)
Locale["ProfileNotFound"] = "更多快捷列: 無法找到設定檔。";


--The following are used for slash commands (only use lower case for the values!)
Locale["SlashButtonForge1"] = "/buttonforge";	--these two identifiers probably shouldn't change for different locales, but if need be they can be
Locale["SlashButtonForge2"] = "/bufo";


--This BoolTable is used to allow more than one value for true or false, in this case the keys should be changed to be suitable for the locale (as many or few as desired)
--The keys are matched against user input to see if the user specified true or false (or nil)... e.g. if the user typed in 'y' then the below table would map to true. (only use lower case)
Locale.BoolTable = {};
Locale.BoolTable["yes"] 	= true;
Locale.BoolTable["no"] 		= false;

Locale.BoolTable["true"] 	= true;
Locale.BoolTable["false"] 	= false;

Locale.BoolTable["y"] 		= true;
Locale.BoolTable["n"] 		= false;

Locale.BoolTable["on"] 		= true;
Locale.BoolTable["off"] 	= false;

Locale.BoolTable["1"] 		= true;
Locale.BoolTable["0"] 		= false;

Locale.BoolTable["toggle"]	= "toggle";

--Instructions for using the slash commands
Locale["SlashHelpFormatted"]	=
	"ButtonForge 更多快捷列用法:\n"..
	"可用的指令: |c"..Const.LightBlue.."/buttonforge|r, |c"..Const.LightBlue.."/bufo|r\n"..
	"可用的參數:\n"..
	"|c"..Const.LightBlue.."-bar <快捷列名稱>|r (要套用更改的快捷列名稱，或是用逗號分隔多個快捷列名稱，沒有指定的話會套用到全部的快捷列)\n"..
	"|c"..Const.LightBlue.."-list|r\n"..
	"|c"..Const.LightBlue.."-rename <新名稱>|r\n"..
	"|c"..Const.LightBlue.."-rows <數字>|r\n"..
	"|c"..Const.LightBlue.."-cols <數字>|r\n"..
	"|c"..Const.LightBlue.."-scale <數字>|r (1 是預設縮放大小)\n"..
	"|c"..Const.LightBlue.."-gap <數字>|r (2 是預設間距)\n"..
	"|c"..Const.LightBlue.."-coords <left> <top>|r\n"..
	"|c"..Const.LightBlue.."-tooltips <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-emptybuttons <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-lockbuttons <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-flyout <up/down/left/right>|r\n"..
	"|c"..Const.LightBlue.."-macrotext <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-keybindtext <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec1 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec2 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec3 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidespec4 <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidevehicle <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hideoverridebar <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-hidepetbattle <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-vismacro <控制顯示的巨集>|r\n"..
	"|c"..Const.LightBlue.."-gui <on/off/toggle>|r (off = 隱藏快捷列但不停用按鍵綁定)\n"..
	"|c"..Const.LightBlue.."-alpha <不透明度>|r (0 - 1, 1 是完全不透明)\n"..
	"|c"..Const.LightBlue.."-enabled <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-info|r\n"..
	"|c"..Const.LightBlue.."-technicalinfo|r\n"..
	"|c"..Const.LightBlue.."-createbar <快捷列名稱>|r\n"..
	"|c"..Const.LightBlue.."-destroybar <快捷列名稱>|r\n"..
	"|c"..Const.LightBlue.."-saveprofile <設定檔名稱>|r\n"..
	"|c"..Const.LightBlue.."-loadprofile <設定檔名稱>|r\n"..
	"|c"..Const.LightBlue.."-loadprofiletemplate <設定檔名稱>|r\n"..
	"|c"..Const.LightBlue.."-undoprofile|r\n"..
	"|c"..Const.LightBlue.."-deleteprofile <設定檔名稱>|r\n"..
	"|c"..Const.LightBlue.."-listprofiles|r\n"..	
	"|c"..Const.LightBlue.."-macrocheckdelay <數字>|r (預設值是 5 秒) \n"..
	"|c"..Const.LightBlue.."-removemissingmacros <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-forceoffcastonkeydown <on/off/toggle>|r (下次登入時才會套用，已移除。)\n"..
	"|c"..Const.LightBlue.."-usecollectionsfavoritemountbutton <on/off/toggle>|r\n"..
	"|c"..Const.LightBlue.."-where|r\n"..
	"|c"..Const.LightBlue.."-quests|r\n"..
	"|c"..Const.LightBlue.."-globalsettings|r\n"..
	"範例:\n"..
	"|c"..Const.LightBlue.."/bufo -bar Mounts -tooltips off -emptybuttons off -scale 0.75|r\n"..
	"|c"..Const.LightBlue.."/bufo -macrotext off|r\n"..
	"|c"..Const.LightBlue.."/bufo -createbar MyNewBar -coords 800, 200 -rows 10 -cols 1|r\n"..
	"|c"..Const.LightBlue.."/bufo -bar MyNewBar -info|r";
	

Locale["SlashCommandRequired"]		= "<COMMANDA> 也需要指定 <COMMANDB>";
Locale["SlashCommandIncompatible"]	= "<COMMANDA> 和 <COMMANDB> 不能一起使用";
Locale["SlashCommandAlone"]			= "<COMMANDA> 不能和其他指令一起使用";
Locale["SlashListBarWithLabel"]		= "- <INDEX> (<LABEL>) |c"..Const.LightBlue.." 例如: /bufo -bar <LABEL> -info";
Locale["SlashListBarWithIndex"]		= "- <INDEX> (沒有設定文字標籤的話改用索引值) |c"..Const.LightBlue.." 例如: /bufo -bar <INDEX> -info"
Locale["SlashListBarNotFound"]      = "無效的快捷列名稱或索引值: <LABEL>";

Locale["SlashBarNameRequired"]		=
[[ButtonForge slash command failed:
You must specify -bar if using any of the following commands: -rows, -cols, -coords, -rename, -info
]];

Locale["SlashCreateBarRule"]		=
[[ButtonForge slash command failed:
-createbar cannot be used with -bar
]];

Locale["SlashCreateBarFailed"]		=
[[ButtonForge slash command failed:
-createbar failed to create a new bar
]];

Locale["SlashDestroyBarRule"]		=
[[ButtonForge slash command failed:
-destroybar cannot be used with other commands
]];

Locale["SlashAlphaRule"]			=
[[ButtonForge slash command failed:
-alpha value must be in the range of 0.0 - 1.0
]];

Locale["SlashGlobalSettingsRule"]		=
[[ButtonForge slash command failed:
-globalsettings cannot be used with other commands
]];

Locale["SlashCommandNotRecognised"]	=
[[ButtonForge slash command failed:
Command not recognised: ]];

Locale["SlashParamsInvalid"] =
[[ButtonForge slash command failed:
Invalid params for command: ]];




--Used when displaying info for the Bar via the slash command /bufo -info
Locale["InfoLabel"] = "標籤";
Locale["InfoRowsCols"] = "列、行";
Locale["InfoScale"] = "縮放大小";
Locale["InfoCoords"] = "坐標";
Locale["InfoTooltips"] = "滑鼠提示";
Locale["InfoEmptyGrid"] = "空按鈕";
Locale["InfoLock"] = "鎖定按鈕";
Locale["InfoHSpec1"] = "專精 1 顯示";
Locale["InfoHSpec2"] = "專精 2 顯示";
Locale["InfoHSpec3"] = "專精 3 顯示";
Locale["InfoHSpec4"] = "專精 4 顯示";
Locale["InfoHVehicle"] = "在載具上時顯示";
Locale["InfoHBonusBar5"] = "有特殊快捷列時顯示";
Locale["InfoHPetBattle"] = "寵物對戰時顯示";
Locale["InfoVisibilityMacro"] = "用巨集控制顯示";
Locale["InfoGUI"] = "GUI";
Locale["InfoAlpha"] = "透明度";
Locale["InfoMacroText"] = "巨集標籤";
Locale["InfoKeybindText"] = "按鍵綁定標籤";
Locale["InfoEnabled"] = "快捷列";
Locale["InfoGap"] = "按鈕間距";
Locale["InfoMacroCheckDelay"] = "巨集檢查延遲";
Locale["InfoUseCollectionsFavoriteMountButton"] = "使用收藏中最愛的坐騎按鈕";
Locale["InfoRemoveMissingMacros"] = "移除缺少的巨集";
Locale["InfoForceOffCastOnKeyDown"] = "按下按鍵時強制關閉施法";
Locale["InfoButtonFrameName"] = "按鈕框架已命名";

-- Header for the profiles list
Locale["BFProfiles"] = "更多快捷列設定檔";

Locale["SavedProfile"] = "更多快捷列已儲存設定檔";
Locale["LoadedProfile"] = "更多快捷列已載入設定檔";
Locale["LoadedProfileTemplate"] = "更多快捷列已載入設定檔範本";
Locale["UndoneProfile"] = "更多快捷列已還原設定檔";
Locale["DeletedProfile"] = "更多快捷列已刪除設定檔";

Locale["BindInCombat"] = "戰鬥中無法更新按鍵綁定"
Locale["BindPressKey"] = "按下要設定給這個按鈕的按鍵"
Locale["BindSuccess"] = "按鍵綁定成功"

Locale["Button Forge"] = "更多快捷列"