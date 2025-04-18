-- luacheck: no max line length
-- luacheck: globals LibStub

local L = LibStub("AceLocale-3.0"):NewLocale("NameplateCooldowns", "zhCN");
L = L or {} -- luacheck: ignore
--@non-debug@
L["anchor-point:bottom"] = "下方"
L["anchor-point:bottomleft"] = "左下"
L["anchor-point:bottomright"] = "右下"
L["anchor-point:center"] = "中间"
L["anchor-point:left"] = "左"
L["anchor-point:right"] = "右"
L["anchor-point:top"] = "上方"
L["anchor-point:topleft"] = "左上"
L["anchor-point:topright"] = "右上"
L["anchor-point:x-offset"] = "X偏移"
L["anchor-point:y-offset"] = "Y偏移"
L["chat:addon-is-disabled-note"] = "请注意: 这个插件已被停用，你可以在设置页面 (/nc) 中启用。"
L["chat:default-spell-is-added-to-ignore-list"] = "预设法术已加入忽略列表: %s，将不会显示这个法术的冷却时间。"
L["chat:enable-only-for-target-nameplate"] = "只在当前目标的血条上显示技能冷却"
L["chat:print-updated-spells"] = "%s: 你的冷却: %s 秒，新的冷却: %s 秒"
L["Click on icon to enable/disable tracking"] = "点击图标启用/禁用跟踪"
L["Copy"] = "复制"
L["Copy other profile to current profile:"] = "复制其他配置文件至当前配置文件："
L["Current profile: [%s]"] = "当前配置文件：[%s]"
L["Data from '%s' has been successfully copied to '%s'"] = "从 '%s' 的数据已被成功复制到 '%s'"
L["Delete"] = "删除"
L["Delete profile:"] = "删除配置文件"
L["Filters"] = "过滤器"
L["filters.instance-types"] = "设置在不同地域下是否显示冷却"
L["Font:"] = "字体："
L["General"] = "综合"
L["general.sort-mode"] = "排序方式:"
L["Icon size"] = "图标大小"
L["Icon X-coord offset"] = "图标的X坐标偏移"
L["Icon Y-coord offset"] = "图标的Y坐标偏移"
L["icon-grow-direction:down"] = "向下"
L["icon-grow-direction:left"] = "向左"
L["icon-grow-direction:right"] = "向右"
L["icon-grow-direction:up"] = "向上"
L["instance-type:arena"] = "竞技场"
L["instance-type:none"] = "野外"
L["instance-type:party"] = "5人地下城"
L["instance-type:pvp"] = "战场"
--[[Translation missing --]]
L["instance-type:pvp_bg_40ppl"] = "Epic Battlegrounds"
L["instance-type:raid"] = "团队副本"
L["instance-type:scenario"] = "场景战役"
L["instance-type:unknown"] = "未知地域(某些任务场景)"
L["MISC"] = "杂项"
L["msg:question:import-existing-spells"] = [=[NameplateCooldowns
你的某些法术冷却已更新，是否要应用更新?]=]
L["New spell has been added: %s"] = "新的法术已添加：%s"
L["Options are not available in combat!"] = "选项在战斗中不可用！"
L["options:borders:show-blizz-borders"] = "在图标周围显示暴雪原生边框"
--[[Translation missing --]]
L["options:building-cache"] = [=[Loading spells info (%s%%)...
Some functions may be unavailable]=]
L["options:category:borders"] = "边框"
L["options:category:spells"] = "法术"
L["options:category:text"] = "文字"
L["options:general:anchor-point"] = "锚点"
L["options:general:anchor-point-to-parent"] = "锚点（相对于上一级框架）"
L["options:general:enable-only-for-target-nameplate"] = "只在当前目标的姓名板上显示技能冷却"
L["options:general:full-opacity-always"] = "图标总是完全不透明"
L["options:general:full-opacity-always:tooltip"] = "如果启用此选项，图标将总是完全不透明。如果不启用，图标的透明度和血条一样。"
L["options:general:icon-grow-direction"] = "图标生长方向"
L["options:general:ignore-nameplate-scale"] = "忽略姓名板缩放"
L["options:general:ignore-nameplate-scale:tooltip"] = "如果启用此选项，图标大小将不随着姓名板缩放变化（例如，你的目标的姓名板变大）"
L["options:general:inverse-logic"] = "逻辑取反"
L["options:general:inverse-logic:tooltip"] = "当玩家可以施放特定法术时显示图标"
L["options:general:show-cd-on-allies"] = "在友方的姓名板上显示冷却"
L["options:general:show-cooldown-animation"] = "启用冷却动画"
L["options:general:show-cooldown-animation:tooltip"] = "在冷却图标上显示旋转动画"
L["options:general:show-cooldown-tooltip"] = "显示冷却提示"
L["options:general:show-inactive-cd"] = "显示不活跃的冷却"
L["options:general:show-inactive-cd:tooltip"] = "注意：你将无法看到所有可用的冷却！你只能看到敌方已经施放过的技能冷却！"
L["options:general:space-between-icons"] = "图标间距(px)"
L["options:general:test-mode"] = "测试模式"
L["options:profiles"] = "配置"
L["options:spells:add-new-spell"] = "添加新的法术 (名称或ID):"
L["options:spells:add-spell"] = "添加法术"
L["options:spells:click-to-select-spell"] = "点击以选择法术"
--[[Translation missing --]]
L["options:spells:click-to-select-spell:test-mode"] = "You can't edit spells in test mode"
L["options:spells:cooldown-time"] = "冷却时间"
L["options:spells:custom-cooldown"] = "自定义冷却"
L["options:spells:custom-cooldown-value"] = "冷却（秒）"
L["options:spells:delete-all-spells"] = "删除所有法术"
L["options:spells:delete-all-spells-confirmation"] = "确定要删除所有法术?"
L["options:spells:delete-spell"] = "删除法术"
L["options:spells:disable-all-spells"] = "禁用所有法术"
L["options:spells:enable-all-spells"] = "启用所有法术"
L["options:spells:enable-tracking-of-this-spell"] = "开始追踪这个法术"
L["options:spells:icon-glow"] = "高亮图标已被禁用"
L["options:spells:icon-glow-always"] = "图标高亮，当法术冷却中"
L["options:spells:icon-glow-threshold"] = "图标高亮，当剩余时间小于"
L["options:spells:please-push-once-more"] = "请再按一次"
L["options:spells:track-only-this-spellid"] = [=[只追踪这些法术ID
(使用逗号分隔)]=]
L["options:text:anchor-point"] = "锚点"
L["options:text:anchor-to-icon"] = "到图标的锚点"
L["options:text:color"] = "文字颜色"
L["options:text:font"] = "字体"
L["options:text:font-scale"] = "字体缩放"
L["options:text:font-size"] = "字体大小"
L["options:timer-text:scale-font-size"] = "根据图标大小缩放字体大小"
L["Profile '%s' has been successfully deleted"] = "配置文件 '%s' 已成功删除"
L["Show border around interrupts"] = "为打断技能显示边框"
L["Show border around trinkets"] = "为饰品显示边框"
L["Unknown spell: %s"] = "未知的法术：%s"
L["Value must be a number"] = "值必须是数字"

--@end-non-debug@
