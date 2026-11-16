--[[
	Localization_zhCN.lua
	2008/12/4 Modified by xuxianhe@gmail.com
    Sep 9. 2012 yaroot##gmail#com
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Dominos-Config', 'zhCN')
if not L then return end

L.ActionBarBehavior = "动作条行为"
L.ActionButtonLookAndFeel = "动作按钮外观"
L.BagBarShowBags = "显示背包"
L.BagBarShowKeyRing = "显示钥匙扣"
L.Bar = '动作条 %d'
L.ClickThrough = '允许穿透点击'
L.CopyProfile = '复制配置...'
L.EnterBindingMode = '绑定按键...'
L.EnterConfigMode = '进入设置模式'
L.ExtraBarShowBlizzardTexture = '显示暴雪材质'
L.FadedOpacity = '透明度'
L.FrameStrata = "框体层级"
L.FrameStrata_MEDIUM = "中"
L.FrameLevel = "框体级别"
L.Layout = '布局'
L.LinkedOpacity = '粘附动作条继承透明度'
L.Modifiers = '功能键翻页'
L.Padding = '边距'
L.Paging = "翻页"
L.PossessBar = '载具'
L.PossessBarDesc = "在某些情况下控制敌人时将哪个动作条用来显示特殊动作"
L.Profiles = '配置管理'
L.QuickPaging = '快速翻页'
L.RCUPlayer = '自己'
L.ResetProfile = '重置配置...'
L.RightClickUnit = '右键点击'
L.RowOffset = "列偏移"
L.RowSpacing = "行间距"
L.Scale = '缩放'
L.Set = '选中'
L.ShowBindingText = '显示按键绑定文字'
L.ShowCountText = "显示数量文字"
L.ShowEquippedItemBorders = '显示已装备物品边框'
L.ShowInOverrideUI = '载具界面'
L.ShowInPetBattleUI = '宠物战斗界面'
L.ShowMacroText = '显示宏名称'
L.ShowMinimapButton = '显示小地图按钮'
L.ShowOverrideUI = '使用默认载具界面'
L.ShowOverrideUIDesc = "当驾驶载具等情况下显示暴雪覆盖UI"
L.ShowSpellAnimations = "显示技能动画"
L.ShowSpellGlows = "显示技能高亮"
L.ShowStates = '显示隐藏条件'
L.ShowTooltips = '显示鼠标提示'
L.Spacing = '按钮间隔'
L.State_HARM = '敌对目标'
L.State_HELP = '友方目标'
L.State_NOTARGET = '无目标'
L.State_SHIELD = "持盾"
L.StickyBars = '粘附动作条'
L.ThemeActionButtons = '启用动作条主题 (需要重载界面)'
L.ThemeActionButtonsDesc = "启用时，对动作按钮应用一些自定义样式，未启用时，保持不变"
L.Visibility = '可见性' --NOUSE

-- derived translations
L.State_ALTSHIFT = strjoin('-', ALT_KEY_TEXT, SHIFT_KEY_TEXT)
L.State_CTRLALT = strjoin('-', CTRL_KEY_TEXT, ALT_KEY_TEXT)
L.State_CTRLALTSHIFT = strjoin('-', CTRL_KEY_TEXT, ALT_KEY_TEXT, SHIFT_KEY_TEXT)
L.State_CTRLSHIFT = strjoin('-', CTRL_KEY_TEXT, SHIFT_KEY_TEXT)

L.State_META = IsMacClient() and 'Command 键' or 'Meta 键'

L.Width = '宽'
L.Height = '高'
L.Font = '字体'
L.Texture = '材质'

L.ActionBarNumber = "动作条 %d"

L.Advanced = '高级'



L.Colors = "颜色"


L.Delete = '删除'



L.FadeOut = "淡出"


L.FrameStrata_BACKGROUND = "底"

L.FrameStrata_LOW = LOW

L.FrameStrata_HIGH = HIGH

L.General = '通用'


L.None = NONE

L.Opacity = '鼠标悬停透明度'

L.RCUFocus = '焦点'

L.Save = '新建'

L.ShowEmptyButtons = '显示空按钮'



L.FadedOpacityTooltip = "鼠标未移至动作条上时的透明度，以正常不透明度的百分比表示。显示条件中指定的不透明度优先应用。"

L.MouseoverFading = "鼠标指向淡入淡出"

L.LayoutDirection = "排列方向"

L.Appearance = "外观"

L.Style = "样式"

L.Content = "内容"

L.Behavior = "行为"

L.DrawOrder = "绘制顺序"

L.Preset = "预设"

L.ShowAlways = "始终显示"

L.ShowInCombat = "战斗中显示"

L.ShowOutOfCombat = "非战斗时显示"

L.ShowWithTarget = "有目标时"

L.ShowInCombatOrWithTarget = "战斗中或有目标时"

L.ShowCustom = "自定义"

L.ShowNever = "从不显示"

L.ShowNotMounted = "未骑乘坐骑时"

L.NumButtons = "按钮数量"

L.NumColumns = "列数"

L.PagingDefault = "默认"

L.State_DRAGONRIDING = "驭龙术"

L.CustomConditions = "宏条件式"

L.FadeInDelay = "淡入延迟（毫秒）"

L.FadeInTime = "淡入时间（毫秒）"

L.FadeOutDelay = "淡出延迟（毫秒）"

L.FadeOutTime = "淡出时间（毫秒）"

L.LayoutRightDown = "左上"

L.LayoutLeftDown = "右上"

L.LayoutRightUp = "左下"

L.LayoutLeftUp = "右下"

L.ShowStatesDescription = "输入结果为 show、hide 或 0 到 100 不透明度数值的宏条件式。例如：[combat]100;50"

L.ActionBarSize = "动作条大小"
L.ActionBarSizeCustom = "自定义（%dx%d）"
L.ActionBarSizeDesc = "更改动作条布局"
L.ActionBarSizeValue = "%dx%d"
L.ActionBook = "动作书"
L.BarInState = "%s（%s）"
L.BarState = "%s：%s"
L.Border = "边框"
L.BorderSize = "边框大小"
L.FontOutline = "字体描边"
L.FontOutline_OUTLINE = "细"
L.FontOutline_THICKOUTLINE = "粗"
L.FontSize = "字体大小"
L.ManageActions = "管理动作…"
L.PagingClear = "清除"
L.PagingUnavailable = "%s（不可用）"
L.PagingUnset = "未设置"
L.ShowTotemRecall = "显示图腾召回"
L.ShowWithSpellbook = "打开法术书时显示"
