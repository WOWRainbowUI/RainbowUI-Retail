--[[
	localization.tw.lua
	zhTW (convert from zhCN)
		xuxianhe@gmail.com
        yaroot##gmail#com
		
	
	2020/5/7 New translations by 彩虹ui https://www.facebook.com/rainbowui/
	2019/10/5 New translations by Kal.L
	Triditional Chinese 繁體中文
]]

local L = LibStub('AceLocale-3.0'):NewLocale('Dominos-Config', 'zhTW')
if not L then return end

L.ActionBarBehavior = "快捷列行為"
L.ActionButtonLookAndFeel = "快捷列按鈕外觀"
L.BagBarShowBags = "顯示更換背包欄位"
L.BagBarShowKeyRing = "顯示鑰匙圈"
L.Bar = "快捷列 %d"
L.BarSettings = "%s 設定"
L.ClickThrough = "啟用點擊穿透"
L.CommandKey = '指令'
L.ConfirmCopyProfile = "是否要將 %s 的內容複製到目前的設定檔?"
L.ConfirmDeleteProfile = "是否要刪除設定檔 %s?"
L.ConfirmResetProfile = "是否確定要重置設定檔?"
L.Copy = "複製"
L.CopyProfile = "複製設定檔..."
L.CreateProfile = "建立設定檔..."
L.DisableMenuButtons = "停用按鈕"
L.EnterBindingMode = "設定快捷鍵..."
L.EnterConfigMode = "設定快捷列..."
L.EnterName = "輸入名稱"
L.ExtraBarShowBlizzardTexture = "顯示暴雪預設材質"
L.FadedOpacity = "淡出透明度"
L.FrameStrata = "框架層級"
L.FrameStrata_MEDIUM = "中"
L.FrameLevel = "框架層數"
L.Layout = "外觀"
L.LinkedOpacity = "吸附的快捷列繼承相同的透明度"
L.LockActionButtons = "鎖定快捷列按鈕圖示"
L.MetaKey = 'Meta鍵'
L.Modifiers = "輔助鍵"
-- L.None = _G.NONE
L.OneBag = "只顯示一個背包圖示"
-- L.Opacity = _G.OPACITY
L.OutOfCombat = "非戰鬥中"
L.Padding = "內距"
L.Paging = "切換"
L.PossessBar = "載具/操控列使用"
L.PossessBarDesc = "在某些首領戰中和操控敵人時，要在哪個快捷列上要顯示特殊技能。"
L.Profiles = "設定檔"
L.ProfilesPanelDesc = "管理儲存的快捷列版面配置"
L.QuickMoveKey = "快速移動鍵"
L.QuickPaging = "快速切換"
L.RCUPlayer = "自己"
L.RCUToT = "目標的目標"
L.ResetProfile = "重置設定檔..."
L.RightClickUnit = "右鍵點擊的目標是"
-- L.Save = _G.SAVE
L.Scale = "縮放大小"
L.SelfcastKey = "自我施法鍵"
L.Set = "設定"
L.ShowBindingText = "顯示快捷鍵文字"
L.ShowCountText = "顯示物品數量文字"
L.ShowEquippedItemBorders = "已裝備的物品顯示邊框"
L.ShowInOverrideUI = "在載具上時要顯示"
L.ShowInPetBattleUI = "寵物戰鬥時要顯示"
L.ShowKeyring = "顯示鑰匙圈"
L.ShowMacroText = "顯示巨集文字"
L.ShowMinimapButton = "顯示小地圖按鈕"
L.ShowOverrideUI = "使用遊戲內建的載具介面"
L.ShowOverrideUIDesc = "駕駛車輛或其他相關情況時，顯示暴雪預設的載具介面。"
L.ShowStates = "顯示條件 - 可輸入巨集指令，例如:\n [combat][harm,nodead]show;hide"
L.ShowTooltips = "顯示浮動提示資訊"
L.ShowTooltipsCombat = "戰鬥中顯示浮動提示資訊"
L.Spacing = "間距"
L.State_HARM = "敵方"
L.State_HELP = "友方"
L.State_NOTARGET = "沒有目標"
L.State_SHIELD = "已裝備盾牌"
L.StickyBars = "磁吸式對齊"
L.Targeting = "目標為"
L.ThemeActionButtons = "套用達美樂的按鈕外觀主題 (需要重新載入)"
L.ThemeActionButtonsDesc = "啟用時，會對快捷列按鈕套用一些自訂的樣式調整。停用時則保持原樣。"
L.Visibility = "顯示/隱藏"

if IsMacClient() then
    L.State_META = 'CMD鍵'
else
    L.State_META = 'Meta鍵'
end

L.ParentAddonName = "達美樂快捷列 "
L.Width = '寬度'
L.Height = '高度'
L.Font = '字體'
L.Texture = '材質'

L.ActionBarNumber = "快捷列 %d"

L.ActionButtonColoring = "快捷列按鈕著色"

L.ActionStates_oom = "法力不足"

L.ActionStates_oor = "超出範圍"

L.ActionStates_unusable = "無法使用"

L.Advanced = "進階"


L.Color = COLOR

L.Colors = COLOR



L.Delete = _G.DELETE

L.Desaturate = "去飽和度"


L.Enable = ENABLE


L.FadeOut = "淡出"


L.FrameStrata_BACKGROUND = "背景"

L.FrameStrata_LOW = LOW

L.FrameStrata_HIGH = HIGH

L.General = "一般"


L.RCUFocus = "專注目標"

L.RowOffset = "橫列縮排"

L.RowSpacing = "橫列間距"

L.ShowEmptyButtons = "顯示空按鈕"

L.ShowSpellGlows = "顯示法術發光"

L.ShowSpellAnimations = "顯示法術動畫"



L.FadedOpacityTooltip = "滑鼠未移至快捷列上時的透明度，以一般透明度的百分比表示。顯示條件中指定的透明度優先套用。"

L.MouseoverFading = "滑鼠指向淡入淡出"

L.LayoutDirection = "排列方向"

L.Appearance = "外觀"

L.Style = "樣式"

L.Content = "內容"

L.Behavior = "行為"

L.DrawOrder = "繪製順序"

L.Preset = "預設"

L.ShowAlways = "總是顯示"

L.ShowInCombat = "戰鬥中顯示"

L.ShowOutOfCombat = "非戰鬥時顯示"

L.ShowWithTarget = "有目標時"

L.ShowInCombatOrWithTarget = "戰鬥中或有目標時"

L.ShowCustom = "自訂"

L.ShowNever = "永不顯示"

L.ShowNotMounted = "未騎乘坐騎時"

L.NumButtons = "按鈕數量"

L.NumColumns = "列數"

L.PagingDefault = "預設"

L.State_DRAGONRIDING = "飛龍騎術"

L.CustomConditions = "巨集條件式"

L.FadeInDelay = "淡入延遲（毫秒）"

L.FadeInTime = "淡入時間（毫秒）"

L.FadeOutDelay = "淡出延遲（毫秒）"

L.FadeOutTime = "淡出時間（毫秒）"

L.LayoutRightDown = "左上"

L.LayoutLeftDown = "右上"

L.LayoutRightUp = "左下"

L.LayoutLeftUp = "右下"

L.ShowStatesDescription = "輸入結果為 show、hide 或 0 到 100 透明度數值的巨集條件式。例如：[combat]100;50"
