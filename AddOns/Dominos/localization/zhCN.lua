--[[
	Localization_zhCN.lua
	2008/12/4 Modified by xuxianhe@gmail.com
    Sep 9. 2012     yaroot##gmail#com
--]]

local AddonName = ...
local L = LibStub('AceLocale-3.0'):NewLocale(AddonName, 'zhCN')
if not L then return end

L.AlertsBarDisplayName = "警报"
L.AvailableProfiles = '可用配置'
L.BarDisplayName = "%s 条"
L.BindingEnterTip = '<Shift+左键> 进入绑定模式'
L.BindingExitTip = '<Shift+左键> 退出绑定模式'
L.CantDeleteCurrentProfile = '不能删除当前正在使用的配置'
L.ConfigDesc = '设置模式开关'
L.ConfigEnterTip = '<左键> 进入设置模式'
L.ConfigExitTip = '<左键> 退出设置模式'
L.ConfigMode = '设置模式'
L.ConfigModeHelp = '<拖动> 移动技能条(按住Alt键可以不粘附)。\n<右键> 进入设置。\n<中键> 或 <Shift+右键> 设置是否显示。'
L.CopyDesc = '从 <profile> 复制设置'
L.DeleteDesc = '删除 <profile>'
L.HideBar = '<中键或者Shift+右键> 隐藏'
L.HideFramesDesc = '隐藏 <frameList>'
L.InvalidProfile = '无效的配置 "%s"'
L.KeyboardMovementTip = "使用方向键调整位置。"
L.ListDesc = '列出所有配置'
L.PrintVersionDesc = '显示当前版本'
L.ProfileCopied = '已复制配置"%s"的设置到当前配置'
L.ProfileCreated = '建立新配置 "%s"'
L.ProfileDeleted = '删除配置 "%s"'
L.ProfileLoaded = '配置设置为 "%s"'
L.ProfileReset = '重置配置 "%s"'
L.QueueStatusBarDisplayName = "任务状态条"
L.ResetDesc = '返回默认设置'
L.RollBarDisplayName = "Rolls"
L.SaveDesc = '保存当前配置为 <profile>'
L.SetAlpha = '<滚轮> 设置透明度 (|cffffffff%d|r)'
L.SetAlphaDesc = '透明度 <frameList>'
L.SetColsDesc = '列 <frameList>'
L.SetDesc = '配置切换为 <profile>'
L.SetFadeDesc = '遮罩透明度 <frameList>'
L.SetPadDesc = '填充 <frameList>'
L.SetScaleDesc = '缩放 <frameList>'
L.SetSpacingDesc = '间隔 <frameList>'
L.ShowBar = '<中键或者Shift+右键> 显示'
L.ShowConfig = '<右键> 设置'
L.ShowFramesDesc = '显示 <frameList>'
L.Shown = "显示"
L.ShowOptionsTip = '<右键> 显示设置菜单'
L.TipRollBar = '在团队中显示物品掷点面板'
L.ToggleFramesDesc = '开关 <frameList>'
L.Updated = '升级到 v%s'
L.WrongBuildWarning = "You're running a %s version for %s on a %s server. Things may not work"

L.ActionBarDisplayName = "动作条 %d"

L.BagBarDisplayName = "背包"

L.ClassBarDisplayName = HUD_EDIT_MODE_STANCE_BAR_LABEL or "职业技能"

L.EncounterBarDisplayName = HUD_EDIT_MODE_ENCOUNTER_BAR_LABEL or "战斗条"

L.ExtraBarDisplayName = HUD_EDIT_MODE_EXTRA_ABILITIES_LABEL or "额外技能"


L.MenuBarDisplayName = "菜单"

L.PetBarDisplayName = HUD_EDIT_MODE_PET_ACTION_BAR_LABEL or "宠物动作条"

L.PossessBarDisplayName = HUD_EDIT_MODE_POSSESS_ACTION_BAR_LABEL or '载具'

L.ShowAlignmentGrid = "显示网格"

L.TalkingHeadBarDisplayName = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "对话特写头像"

L.TotemBarDisplayName = "图腾条"

L.VehicleBarDisplayName = HUD_EDIT_MODE_VEHICLE_LEAVE_BUTTON_LABEL or BINDING_NAME_VEHICLEEXIT

L.AlignmentGridSize = "网格密度"

L.AlignmentGridSizeTooltip = "屏幕上的网格线数量。数值越高，网格越细，方便动作条对齐。"

L.AddonName = "Dominos"

L.ActionBarButtonDisplayName = "多米诺动作条 %d 按钮 %d"
L.ActionBarsDesc = "设置动作条数量和每条按钮数，例如 8x12（最多共 168 个按钮）"
L.ActionBarsMigrated = "动作条现按暴雪的顺序排列。请检查各条，并移动位置不符的技能或快捷键。"
L.ActionPageRegion = "动作页 %d"
L.ActionPagesRegion = "动作页"
L.ActionsDesc = "打开动作书"
L.BarButton = "%s 按钮 %d"
L.BonusBarRegion = "额外动作条 %d"
L.GamepadDpadRegion = "方向键"
L.GamepadFaceRegion = "按钮"
L.GamepadPageRegion = "手柄页 %d"
L.GamepadStanceBarRegion = "手柄姿态条 %d"
L.GamepadStanceBarsRegion = "手柄姿态条"
L.NumBarsLimited = "已设为 %d 条，每条 %d 个按钮时的上限"
L.RegionSlotName = "%s 栏位 %d"
L.SavedVariablesNotMigrated = "设置更新失败，本次登录已停用。请到 %s 报告此错误。"
L.SavedVariablesTooNew = "设置来自更新版本，本次登录已停用。请更新到最新版。"
L.SlotName = "栏位 %d"
L.TotemSetHint = "右键切换图腾组合"
L.TotemSetRegion = "图腾组合 %d"
L.TotemsRegion = "图腾"
