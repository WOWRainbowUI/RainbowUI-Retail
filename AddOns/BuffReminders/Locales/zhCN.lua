local _, BR = ... -- luacheck: ignore 211
BR.translatedLocales.zhCN = "简体中文"
if BR.locale ~= "zhCN" then
    return
end

local L = BR.L -- luacheck: ignore 211

-- Credit by neolhfs
-- Update: 电视卫士 (SGSwdzgr)

-- ============================================================================
-- CATEGORY LABELS
-- ============================================================================
L["Category.Raid"] = "团队增益"
L["Category.Presence"] = "特殊增益"
L["Category.Targeted"] = "指向性增益"
L["Category.Self"] = "自身增益"
L["Category.Pet"] = "宠物"
L["Category.Consumable"] = "消耗品"
L["Category.Utility"] = "实用功能"
L["Category.Custom"] = "自定义"
L["Category.Loadout"] = "配装方案"

-- Long form (used in Options section headers)
L["Category.RaidBuffs"] = "团队增益"
L["Category.TargetedBuffs"] = "指向性增益"
L["Category.Consumables"] = "消耗品"
L["Category.UtilityReminders"] = "实用功能提示"
L["Category.PresenceBuffs"] = "特殊增益"
L["Category.SelfBuffs"] = "专属增益"
L["Category.PetReminders"] = "宠物提示"
L["Category.CustomBuffs"] = "自定义增益"
L["Category.LoadoutReminders"] = "配装方案提示"

-- Category notes
L["Category.RaidNote"] = "（全小队或团队生效）"
L["Category.TargetedNote"] = "（施放于其他目标的增益）"
L["Category.ConsumableNote"] = "（药水、食物、符文、刀油）"
L["Category.UtilityNote"] = "（杂项与非增益类提示）"
L["Category.PresenceNote"] = "（至少需要一人）"
L["Category.SelfNote"] = "（仅对自己施放的增益）"
L["Category.PetNote"] = "（宠物召唤提示）"
L["Category.CustomNote"] = "（按法术ID追踪增益或高亮）"
L["Category.LoadoutNote"] = "（当装备或天赋与当前环境不匹配时提醒）"
L["Category.LoadoutTLXNote"] = "检测到 Talent Loadout Ex - 其方案将显示在天赋选择器中。"

-- Loadout reminders
L["Loadout.Add"] = "添加配装提示"
L["Loadout.Edit"] = "编辑配装提示"
L["Loadout.AddButton"] = "+ 添加配装提示"
L["Loadout.Empty"] = "暂无配装提示。请在下方添加。"
L["Loadout.Name"] = "名称"
L["Loadout.Expect"] = "预期要求"
L["Loadout.Applies"] = "应用于"
L["Loadout.Content"] = "内容环境"
L["Loadout.Requirement"] = "要求"
L["Loadout.EquipmentSet"] = "装备方案"
L["Loadout.TalentSpell"] = "天赋法术ID"
L["Loadout.NoSets"] = "未找到装备方案。请先在角色面板（装备管理器）中创建。"
L["Loadout.NoSetSelected"] = "请先选择一个装备方案。"
L["Loadout.NoLoadouts"] = "该专精暂无已保存的天赋方案。"
L["Loadout.NoLoadoutSelected"] = "请先选择一个天赋方案。"
L["Loadout.TLXTag"] = "|cff9d9d9d(Loadout Ex)|r"
L["Loadout.InvalidSpell"] = "该法术ID不存在。请使用天赋的法术ID。"
L["Loadout.CombatBlocked"] = "战斗中无法更换装备或天赋。"
L["Loadout.Instances"] = "%d 个副本"
L["Loadout.LimitRaids"] = "仅限特定团队副本"
L["Loadout.LimitDungeons"] = "仅限特定地下城"
L["Loadout.Scope.OpenWorld"] = "野外"
L["Loadout.Scope.Raid"] = "团队副本"
L["Loadout.Scope.Dungeon"] = "地下城"
L["Loadout.Scope.Delve"] = "地下堡"
L["Loadout.Scope.Arena"] = "竞技场"
L["Loadout.Scope.Battleground"] = "战场"
L["Loadout.SpecClass"] = "%s%s"
L["Loadout.Require.Gear"] = "装备方案"
L["Loadout.Require.Talent"] = "天赋"
L["Loadout.Require.Loadout"] = "天赋方案"
L["Loadout.Tag.Gear"] = "装备\n错误"
L["Loadout.Tag.Talent"] = "缺少\n天赋"
L["Loadout.Tag.Loadout"] = "方案\n错误"

-- ============================================================================
-- BUFF OVERLAY TEXT
-- ============================================================================
-- These must be kept very short (2-4 chars per line) to fit on small icons.
L["Overlay.NoDrPoison"] = "没有\n毒药"
L["Overlay.NoAura"] = "没有\n光环"
L["Overlay.NoStone"] = "没拿糖"
L["Overlay.NoSoulstone"] = "没有\n灵魂石"
L["Overlay.NoFaith"] = "没有\n道标"
L["Overlay.NoLight"] = "没有\n道标"
L["Overlay.NoES"] = "没有\n大地盾"
L["Overlay.NoSource"] = "没有\n魔力之源"
L["Overlay.NoScales"] = "没有\n龙鳞"
L["Overlay.NoLink"] = "没有\n共生"
L["Overlay.NoWeyrnstone"] = "没有\n军营石"
L["Overlay.NoTimeless"] = "没有\n超脱时间"
L["Overlay.NoAttune"] = "没有\n协调"
L["Overlay.NoFamiliar"] = "没有\n魔宠"
L["Overlay.DropWell"] = "拉糖"
L["Overlay.DropTable"] = "拉桌子"
L["Overlay.Repair"] = "修理\n装备"
L["Overlay.RepairLabel"] = "修理"
L["Overlay.NoGrim"] = "没有\n魔典"
L["Overlay.BurningRush"] = "爆燃冲刺"
L["Overlay.NoRite"] = "没有\n祭礼"
L["Overlay.ApplyPoison"] = "上毒药"
L["Overlay.NoForm"] = "没有\n形态"
L["Overlay.NoEL"] = "没有\n大地生命"
L["Overlay.NoFT"] = "没有\n火舌"
L["Overlay.NoTG"] = "没有\n唤潮护卫"
L["Overlay.NoWF"] = "没有\n风怒"
L["Overlay.NoSelfES"] = "自身没有\n大地盾"
L["Overlay.NoShield"] = "没有\n护盾"
L["Overlay.NoPet"] = "没有\n宠物"
L["Overlay.PassivePet"] = "宠物\n被动"
L["Overlay.WrongPet"] = "宠物\n错误"
L["Overlay.WrongStance"] = "姿态错误"
L["Overlay.WrongForm"] = "形态错误"
L["Overlay.NoRune"] = "没有\n符文"
L["Overlay.DKWrongRune"] = "符文\n错误"
L["Overlay.DKWrongRuneOH"] = "副手\n符文\n错误"
L["Overlay.NoFlask"] = "没有\n合剂"
L["Overlay.NoFood"] = "没有\n食物"
L["Overlay.NoMageFood"] = "没有\n面包"
L["Overlay.NoWeaponBuff"] = "没有\n武器增益"
L["Overlay.Buff"] = "补BUFF"
L["Overlay.MinutesFormat"] = "%d分"
L["Overlay.LessThanOneMinute"] = "<1分"
L["Overlay.SecondsFormat"] = "%d秒"

-- ============================================================================
-- CONSUMABLE STAT LABELS (icon overlays, keep very short)
-- ============================================================================
L["Label.Crit"] = "爆击"
L["Label.Haste"] = "急速"
L["Label.Versatility"] = "全能"
L["Label.Mastery"] = "精通"
L["Label.Stamina"] = "耐力"
L["Label.Healing"] = "治疗"
L["Label.Random"] = "随机"
L["Label.Speed"] = "加速"
L["Label.PvP"] = "PvP"
L["Label.Feast"] = "大餐"
L["Label.HasteShort"] = "急"
L["Label.VersatilityShort"] = "全"
L["Label.MasteryShort"] = "精"
L["Label.CritVers"] = "爆/全"
L["Label.MasteryCrit"] = "精/爆"
L["Label.MasteryVers"] = "精/全"
L["Label.MasteryHaste"] = "精/急"
L["Label.HasteCrit"] = "急/爆"
L["Label.HasteVers"] = "急/全"
L["Label.StaminaStr"] = "耐/力"
L["Label.StaminaAgi"] = "耐/敏"
L["Label.StaminaInt"] = "耐/智"
L["Label.HighPrimary"] = "高主属性"
L["Label.HighSecondary"] = "高副属性"
L["Label.MidPrimary"] = "中主属性"
L["Label.LowPrimary"] = "低主属性"
L["Label.LowSecondary"] = "低副属性"
L["Label.RevivePet"] = "复活宠物"
L["Label.Felguard"] = "恶魔卫士"
L["Badge.Hearty"] = "丰盛"
L["Badge.Fleeting"] = "飞逝"

-- ============================================================================
-- BUFF NAMES
-- ============================================================================
-- Raid
L["Buff.ArcaneIntellect"] = "奥术智慧"
L["Buff.BattleShout"] = "战斗怒吼"
L["Buff.BlessingOfTheBronze"] = "青铜龙的祝福"
L["Buff.MarkOfTheWild"] = "野性印记"
L["Buff.PowerWordFortitude"] = "真言术：韧"
L["Buff.Skyfury"] = "天怒"
-- Presence
L["Buff.AtrophicNumbingPoison"] = "萎缩/迟钝毒药"
L["Buff.DevotionAura"] = "虔诚光环"
L["Buff.Soulstone"] = "灵魂石"
-- Targeted
L["Buff.BeaconOfFaith"] = "信仰道标"
L["Buff.BeaconOfLight"] = "圣光道标"
L["Buff.BlisteringScales"] = "炽火龙鳞"
L["Buff.EarthShield"] = "大地之盾"
L["Buff.SourceOfMagic"] = "魔力之源"
L["Buff.SymbioticRelationship"] = "共生关系"
L["Buff.Timelessness"] = "超脱时间"
L["Buff.Weyrnstone"] = "军营石"
-- Self
L["Buff.ArcaneFamiliar"] = "奥术魔宠"
L["Buff.Attunement"] = "同调"
L["Buff.CreateSoulwell"] = "制造灵魂之井"
L["Buff.RefreshmentTable"] = "召唤餐桌"
L["Buff.RepairGear"] = "修理装备"
L["Buff.DruidForm"] = "德鲁伊形态"
L["Buff.GrimoireOfSacrifice"] = "牺牲魔典"
L["Buff.BurningRush"] = "爆燃冲刺"
L["Buff.RiteOfAdjuration"] = "恳求祭礼"
L["Buff.RiteOfSanctification"] = "圣言祭礼"
L["Buff.RoguePoisons"] = "潜行者毒药"
L["Buff.RuneforgeMH"] = "符文熔铸（主手）"
L["Buff.RuneforgeOH"] = "符文熔铸（副手）"
L["Buff.Shadowform"] = "暗影形态"
L["Buff.EarthlivingWeapon"] = "大地生命武器"
L["Buff.FlametongueWeapon"] = "火舌武器"
L["Buff.TidecallersGuard"] = "唤潮者的护卫"
L["Buff.WindfuryWeapon"] = "风怒武器"
L["Buff.EarthShieldSelf"] = "大地之盾（自己）"
L["Buff.WaterLightningShield"] = "水盾/闪电盾"
L["Buff.ShieldNoTalent"] = "护盾（无天赋）"
-- Pet
L["Buff.PetPassive"] = "宠物被动"
L["Buff.HunterPet"] = "猎人宠物"
L["Buff.UnholyGhoul"] = "食尸鬼"
L["Buff.WarlockDemon"] = "术士恶魔"
L["Buff.WaterElemental"] = "水元素"
L["Buff.WrongDemon"] = "恶魔不对"
L["Buff.WarriorStance"] = "战士姿态"
-- Consumable
L["Buff.AugmentRune"] = "强化符文"
L["Buff.Flask"] = "合剂"
L["Buff.DelveFood"] = "地下堡食物"
L["Buff.Food"] = "食物"
L["Buff.MageFood"] = "法师面包"
L["Buff.Healthstone"] = "治疗石"
L["Buff.Weapon"] = "武器"
L["Buff.WeaponOH"] = "副手武器"

-- ============================================================================
-- BUFF GROUP DISPLAY NAMES
-- ============================================================================
L["Group.Beacons"] = "圣光道标"
L["Group.DKRunes"] = "DK符文"
L["Group.ShamanImbues"] = "萨满武器注能"
L["Group.PaladinRites"] = "圣骑士祭礼"
L["Group.Pets"] = "宠物"
L["Group.ShamanShields"] = "萨满护盾"
L["Group.Flask"] = "合剂"
L["Group.Food"] = "食物"
L["Group.DelveFood"] = "地下堡食物"
L["Group.Healthstone"] = "治疗石"
L["Group.AugmentRune"] = "强化符文"
L["Group.WeaponBuff"] = "武器增益"

-- ============================================================================
-- BUFF INFO TOOLTIPS
-- ============================================================================
L["Tooltip.MayShowExtraIcon"] = "可能显示额外图标"
L["Tooltip.MayShowExtraIcon.Desc"] = "在施放此法术之前，该提示可能会与水盾/闪电盾提示同时出现。因为系统无法确定你是想对自己施放大地盾，还是想给队友施放大地盾的同时给自己施放水盾/闪电盾。"
L["Tooltip.InstanceEntryReminder"] = "副本进本提示"
L["Tooltip.InstanceEntryReminder.Desc"] = "进入地下城时会短暂显示放置灵魂之井的提示。施放法术或30秒后将消失。"
L["Tooltip.MageFood"] = "仅限治疗专精"
L["Tooltip.MageFood.Desc"] = "仅在你使用治疗专精时显示"
L["BuffTooltip.ProvidedBy"] = "由%s提供"

-- ============================================================================
-- GLOW TYPE NAMES
-- ============================================================================
L["Glow.Pixel"] = "像素"
L["Glow.AutoCast"] = "自动施放"
L["Glow.Border"] = "边框"
L["Glow.Proc"] = "触发"

-- ============================================================================
-- CORE
-- ============================================================================
L["Core.Any"] = "任意"

-- ============================================================================
-- PROFILES
-- ============================================================================
L["Profile.SwitchQueued"] = "脱离战斗后将切换配置文件。"
L["Profile.Switched"] = "已切换至配置文件 '%s'。"

-- ============================================================================
-- MOVERS
-- ============================================================================
L["Mover.SetPosition"] = "设置位置"
L["Mover.AnchorFrame"] = "锚点框体"
L["Mover.AnchorPoint"] = "锚点位置"
L["Mover.NoneScreenCenter"] = "无（屏幕中心）"
L["Mover.Apply"] = "应用"
L["Mover.BuffAnchor"] = "增益锚点"
L["Mover.DragTooltip"] = "拖动以调整位置\n点击以打开/关闭坐标编辑器"
L["Mover.MainEmpty"] = "主界面（空）"
L["Mover.MainAll"] = "主界面（全部）"
L["Mover.Detached"] = "已分离"

-- ============================================================================
-- DISPLAY
-- ============================================================================
L["Display.FramesLocked"] = "框体已锁定。"
L["Display.FramesUnlocked"] = "框体已解锁。"
L["Display.MinimapHidden"] = "小地图图标已隐藏。"
L["Display.MinimapShown"] = "小地图图标已显示。"
L["Display.DebugEnabled"] = "调试模式已启用。再次输入 |cFFFFD100/br debug|r 将其关闭。"
L["Display.DebugDisabled"] = "调试模式已禁用。"
L["Display.Description"] = "一目了然地查看所有缺失的增益。"
L["Display.OpenOptions"] = "打开选项"
L["Display.SlashCommands"] = "斜杠命令: /br, /br lock, /br unlock, /br test, /br minimap, /br snooze"
L["Display.MinimapLeftClick"] = "|cFFCFCFCF左键点击|r: 选项"
L["Display.MinimapRightClick"] = "|cFFCFCFCF右键点击|r: 测试模式"
L["Display.LoginFirstInstall"] = "感谢安装！输入 |cFFFFD100/br unlock|r 来移动增益显示，或者使用 |cFFFFD100/br|r 选项面板底部的按钮。"

-- ============================================================================
-- OPTIONS: NAVIGATION LABELS
-- ============================================================================
L["Tab.DisplayBehavior"] = "显示与行为"

-- Sidebar groups
L["Sidebar.AddonSettings"] = "插件设置"
L["Sidebar.Buffs"] = "增益"
L["Sidebar.Appearance"] = "外观"
L["Sidebar.Display"] = "显示"
L["Sidebar.Alerts"] = "警报"

-- Externals (present-based display)
L["Externals.Title"] = "外部增益"
L["Externals.Defensives"] = "外部减伤"
L["Externals.GroupBuffs"] = "团队增益"
L["Externals.Movement"] = "移动加速"
L["Externals.Aggro"] = "仇恨转移"
L["Externals.Augmentation"] = "增效"
L["Externals.Appearance"] = "外观"

-- Page titles
L["Page.General"] = "常规"
L["Page.Defaults"] = "默认值"
L["Page.Visibility"] = "可见性"
L["Page.ChatRequests"] = "聊天频道请求"
L["Page.Layout"] = "布局"
L["Page.Categories"] = "类别"
L["Page.Profiles"] = "配置文件"
L["Page.Reminders"] = "提示项"
L["Page.CustomAnchors"] = "自定义锚点"

-- Per-category page section headers
L["Section.Tracking"] = "追踪"
L["Section.TrackingOverrides"] = "追踪覆盖规则"
L["Section.TrackingOverrides.Desc"] = "在特定情况下收窄追踪模式。保持在“默认”则始终使用上方的模式。当多个条件同时满足时（例如练级时处于战斗中），最严格的规则生效。"
L["DisabledReason.PvPDisabled"] = "此类别在PvP中已被完全隐藏（详见“可见性”页面）。"

-- ============================================================================
-- OPTIONS: SOUND ALERTS
-- ============================================================================
L["Options.Sound.Preview"] = "预览"
L["Options.Preview"] = "预览"

-- ============================================================================
-- OPTIONS: GLOBAL DEFAULTS
-- ============================================================================
L["Options.GlobalDefaults"] = "全局默认值"
L["Options.GlobalDefaults.Note"] = "（应用于所有类别，除非被自定义外观覆盖）"
L["Options.Default"] = "默认"
L["Options.Text"] = "文本"
L["Options.Text.Note"] = "（字体大小和颜色可按类别单独覆盖；字体、描边和位置始终全局生效）"
L["Options.Font"] = "字体"
L["Options.TextOutline"] = "描边"
L["Options.TextOutline.None"] = "无"
L["Options.TextOutline.Outline"] = "描边"
L["Options.TextOutline.Thick"] = "粗描边"
L["Options.TextOutline.Monochrome"] = "单色"
L["Options.TextOutline.OutlineMono"] = "描边 + 单色"
L["Options.TextOutline.ThickMono"] = "粗描边 + 单色"

-- ============================================================================
-- OPTIONS: GLOW SETTINGS
-- ============================================================================
L["Options.GlowReminderIcons.Title"] = "提示图标发光"
L["Options.GlowReminderIcons.CpuWarning"] = "发光动画会在屏幕上的每个图标上逐帧渲染，因此会消耗更多CPU。如果图标长时间显示（例如战斗中不需要补的增益），该消耗将持续存在。因此默认处于禁用状态。"
L["Options.GlowKind.Expiring"] = "即将过期"
L["Options.GlowKind.Missing"] = "缺失"
L["Options.ExpiringGlow"] = "即将过期发光"
L["Options.ExpiringGlow.Desc"] = "当增益仍存在但即将耗尽时，使图标发光。"
L["Options.MissingGlow"] = "缺失发光"
L["Options.MissingGlow.Desc"] = "当增益完全缺失时，使图标发光。"
L["Options.GlowSettings.Expiring"] = "发光设置 - 即将过期"
L["Options.GlowSettings.Missing"] = "发光设置 - 缺失"
L["Options.Glow.Enabled"] = "启用"
L["Options.Threshold"] = "阈值"
L["Options.GlowMissingPets"] = "缺失宠物发光"
L["Options.Expiration"] = "过期"
L["Options.Glow"] = "发光"
L["Options.UseCustomColor"] = "使用自定义颜色"
L["Options.UseCustomColor.Desc"] = "启用后会降低触发发光的饱和度并更改颜色。\n可能看起来不如默认触发发光清晰。"
L["Options.ExpirationReminder"] = "过期提示"
L["Options.Timing"] = "计时"
L["Options.UseDefaultThreshold"] = "使用默认阈值"
L["Options.UseDefaultThreshold.Desc"] =
    "勾选后，该类别将继承“默认值”页面中的全局过期阈值。\n取消勾选可为该类别单独设置阈值。"
L["Options.PreKeyThreshold"] = "插钥匙前阈值"
L["Options.PreKeyThreshold.Desc"] = "在史诗地下城（0层）中，插入钥石前使用更长的过期提醒阈值。\n有助于确保插钥匙前你的增益时间充足。"

-- Glow params
L["Options.Glow.Type"] = "类型:"
L["Options.Glow.Size"] = "大小:"
L["Options.Glow.Duration"] = "持续时间"
L["Options.Glow.Frequency"] = "频率"
L["Options.Glow.Length"] = "长度"
L["Options.Glow.Lines"] = "线条"
L["Options.Glow.Particles"] = "粒子"
L["Options.Glow.Scale"] = "缩放比例"
L["Options.Glow.Speed"] = "速度"
L["Options.Glow.StartAnimation"] = "起始动画"
L["Options.Glow.XOffset"] = "X轴偏移"
L["Options.Glow.YOffset"] = "Y轴偏移"

-- ============================================================================
-- OPTIONS: CONTENT VISIBILITY
-- ============================================================================
L["Options.HidePvPMatchStart"] = "PvP比赛开始时隐藏"
L["Options.HidePvPMatchStart.Title"] = "PvP比赛开始时隐藏"
L["Options.HidePvPMatchStart.Desc"] = "PvP比赛开始后（准备阶段结束）隐藏此类别。"
L["Options.ReadyCheckOnly"] = "仅在就位确认时显示"
L["Options.ReadyCheckOnly.Desc"] = "仅在就位确认发起后的15秒内显示此类别中的增益。"
L["Options.Visibility"] = "显示条件"

-- ============================================================================
-- OPTIONS: HEALTHSTONE & REPAIR
-- ============================================================================
L["Options.Healthstone.LowStock"] = "治疗石不足警告"
L["Options.Healthstone.LowStock.Desc"] = "当有治疗石但数量较少时显示警告。不管此设置如何，没有治疗石（0个）时都会被追踪。"
L["Options.Healthstone.Threshold"] = "警告阈值"
L["Options.Healthstone.Threshold.Desc"] = "当治疗石等于或低于此数量时显示不足警告。\n\n|cffffcc001:|r 仅在刚好有1个时警告。\n|cffffcc002:|r 有1个或2个时警告。"
L["Options.Repair.Threshold"] = "警告阈值（耐久度低于）"
L["Options.Repair.Threshold.Desc"] = "当身上任意已装备物品的耐久度低于此百分比时显示修理提示。"
L["Options.RepairHideInCombat"] = "战斗中隐藏"
L["Options.RepairHideInCombat.Desc"] = "在战斗中隐藏修理提示。战斗中无法找商人修理，因此仅在脱战后提示。"

-- ============================================================================
-- OPTIONS: SOULSTONE
-- ============================================================================
L["Options.Soulstone.HideCooldown"] = "冷却时隐藏（术士）"
L["Options.Soulstone.HideCooldown.Desc"] = "启用后，当灵魂石法术处于冷却中时，不会向术士显示提示。仅适用于术士。"
L["Options.Soulstone.PinnedTarget"] = "始终施放于"
L["Tooltip.PinNotInGroup"] = "(不在队伍中)"

-- ============================================================================
-- OPTIONS: FREE CONSUMABLES
-- ============================================================================
L["Options.FreeConsumables"] = "免费消耗品"
L["Options.FreeConsumables.Note"] = "（治疗石、永久强化符文）"
L["Options.FreeConsumables.Override"] = "覆盖内容过滤"
L["Options.FreeConsumables.Override.Desc"] = "勾选后，免费消耗品将使用下方独立的内容类型设置。\n\n取消勾选后，它们将遵循与其他消耗品相同的内容过滤规则。"

-- ============================================================================
-- OPTIONS: ICONS
-- ============================================================================
L["Options.Icons"] = "图标"
L["Options.ShowText"] = "在图标上显示文本"
L["Options.ShowText.Desc"] =
    "在此类别的增益图标上显示层数或缺失文本覆盖。即将过期的倒计时时间始终保持可见。"
L["Options.ShowMissingCountOnly"] = "仅显示缺失数量"
L["Options.ShowMissingCountOnly.Desc"] = "仅显示缺失增益的数量（例如：”1“），而不是完整的分数形式（例如：”19/20“）。"
L["Options.ShowBuffReminderText"] = "显示“补BUFF”提示文本"
L["Options.Size"] = "大小"

-- ============================================================================
-- OPTIONS: TEXT POSITIONS
-- ============================================================================
L["Options.TextPositions"] = "文本"
L["Options.TextPositions.Zone"] = "位置"
L["Options.TextPositions.OffsetX.Short"] = "X轴"
L["Options.TextPositions.OffsetY.Short"] = "Y轴"
L["Options.TextPositions.MainText"] = "主文本"
L["Options.TextPositions.MainText.Note"] = "图标上大号文本的位置——如 17/20 计数、倒计时以及“没有合剂”等标签。"
L["Options.TextPositions.StackCount"] = "层数"
L["Options.TextPositions.StatLabel"] = "属性标签"
L["Options.TextPositions.Badge"] = "品质标签 (H / F / C)"
L["Options.TextPositions.Vertical.Above"] = "顶部上方"
L["Options.TextPositions.Vertical.InsideTop"] = "内部顶部"
L["Options.TextPositions.Vertical.InsideMiddle"] = "内部居中"
L["Options.TextPositions.Vertical.InsideBottom"] = "内部底部"
L["Options.TextPositions.Vertical.Below"] = "底部下方"
L["Options.TextPositions.Align.Left"] = "靠左"
L["Options.TextPositions.Align.Center"] = "居中"
L["Options.TextPositions.Align.Right"] = "靠右"

-- ============================================================================
-- OPTIONS: CLICK TO CAST
-- ============================================================================
L["Options.ClickToCast"] = "点击施法"
L["Options.ClickToCast.DescFull"] = "你可以点击增益图标来施放对应的法术（仅限非战斗状态）。只对你的角色可施放的法术有效。"
L["Options.HoverHighlight"] = "悬停高亮"
L["Options.HoverHighlight.Desc"] = "将鼠标悬停在可点击的增益图标上时，显示微弱的高亮效果。"
L["Options.RequestBuffInChat"] = "在聊天频道中请求缺失的增益"



L["Options.ChatRequest.Cooldown.Hint"] = "请求未显示在聊天中？把它关掉。"
L["Options.ChatRequest.ResetAll"] = "重置全部"

-- Chat request messages
L["ChatRequest.intellect"] = "来个智力"
L["ChatRequest.attackPower"] = "来个攻强"
L["ChatRequest.bronze"] = "来个龙BUFF"
L["ChatRequest.versatility"] = "来个爪子"
L["ChatRequest.stamina"] = "来个耐力"
L["ChatRequest.skyfury"] = "来个天怒"
L["ChatRequest.atrophicNumbingPoison"] = "补下毒药"
L["ChatRequest.devotionAura"] = "来个虔诚光环"
L["ChatRequest.soulstone"] = "绑下灵魂石"
L["ChatRequest.healthstone"] = "来个糖"
L["ChatRequest.mageFood"] = "来个面包"

-- ============================================================================
-- OPTIONS: PET
-- ============================================================================
L["Options.PetSpecIcon"] = "悬停时显示猎人宠物专精图标"
L["Options.PetSpecIcon.Title"] = "悬停时宠物专精图标"
L["Options.PetSpecIcon.Desc"] = "鼠标悬停时，宠物图标将变为对应的专精技能（狡诈、狂野、坚韧）。"


L["Options.Behavior"] = "行为"
L["Options.PetPassiveCombat"] = "仅在战斗中提示被动宠物"
L["Options.PetPassiveCombat.Desc"] = "仅在战斗中显示被动宠物提示。禁用时则始终显示。"
L["Options.FelDomination"] = "召唤前使用邪能统御"
L["Options.FelDomination.Title"] = "邪能统御"
L["Options.FelDomination.Desc"] = "通过点击施法召唤恶魔前自动施放邪能统御。如果邪能统御在冷却中，则正常召唤。需要点出邪能统御天赋。"

-- ============================================================================
-- OPTIONS: PET DISPLAY
-- ============================================================================
L["Options.PetDisplay"] = "宠物显示"
L["Options.PetDisplay.Generic"] = "通用图标"
L["Options.PetDisplay.GenericDesc"] = "单一的默认“无宠物”图标"
L["Options.PetDisplay.Summon"] = "召唤法术"
L["Options.PetDisplay.SummonDesc"] = "将每个召唤宠物法术显示为单独的图标"
L["Options.PetDisplay.Mode"] = "宠物显示模式"
L["Options.PetDisplay.Mode.Desc"] = "设置缺失宠物提示的显示方式。"
L["Options.PetLabels"] = "宠物标签"
L["Options.PetLabels.Desc"] = "在每个图标下方显示宠物名称和专精。"
L["Options.PetLabels.SizePct"] = "尺寸占比 %"

-- ============================================================================
-- OPTIONS: CONSUMABLE DISPLAY
-- ============================================================================
L["Options.ConsumableBadgeOnSubIcons.Disabled"] = "仅在“子图标”显示模式下可用。"
L["Options.HideConsumableLabels"] = "隐藏属性标签"
L["Options.HideConsumableLabels.Title"] = "隐藏消耗品属性标签"
L["Options.HideConsumableLabels.Desc"] =
    "隐藏消耗品图标左上角显示的小型属性标签（例如“高主”、“低副”）。"
L["Options.ItemDisplay"] = "物品显示"
L["Options.ItemDisplay.IconOnly"] = "仅图标"
L["Options.ItemDisplay.IconOnlyDesc"] = "显示数量最多的物品"
L["Options.ItemDisplay.Expanded"] = "展开"
L["Options.ItemDisplay.ExpandedDesc"] = "将每个物品变体显示为全尺寸图标"
L["Options.ItemDisplay.Mode"] = "消耗品物品显示"
L["Options.ItemDisplay.Mode.Desc"] = "设置具有多个变体的消耗品物品（例如各种合剂类型）的显示方式。"
L["Options.SubIconSide.Bottom"] = "底部"
L["Options.SubIconSide.Top"] = "顶部"
L["Options.SubIconSide.Left"] = "左侧"
L["Options.SubIconSide.Right"] = "右侧"
L["Options.ShowWithoutItems"] = "背包中没有也显示"
L["Options.ShowWithoutItems.Title"] = "没有物品也显示"
L["Options.ShowWithoutItems.Desc"] = "启用后，即使背包中没有该物品，也会显示消耗品提示。禁用后，仅显示实际拥有的消耗品。"
L["Options.ShowWithoutItemsReadyCheckOnly"] = "仅在就位确认时"
L["Options.ShowWithoutItemsReadyCheckOnly.Title"] = "仅在就位确认时显示缺失物品"
L["Options.ShowWithoutItemsReadyCheckOnly.Desc"] = "启用后，背包中未拥有的消耗品仅在就位确认期间显示。这非常适合作为开打前去补充物品的快速提醒。"
L["Options.DelveFoodOnly"] = "在地下堡中仅显示地下堡食物"
L["Options.DelveFoodOnly.Desc"] = "在地下堡中隐藏除地下堡食物外的所有消耗品提示。"
L["Options.HideLegacyConsumables"] = "隐藏旧版本消耗品"
L["Options.HideLegacyConsumables.Title"] = "隐藏旧版本消耗品"
L["Options.HideLegacyConsumables.Desc"] = "启用后，来自旧资料片的食物、合剂和符文将从动作按钮中过滤掉。如果你还在为了时光漫游、单刷旧团本或给低装等小号使用旧版消耗品，请禁用此项。"

-- ============================================================================
-- OPTIONS: DK RUNEFORGE PREFERENCES
-- ============================================================================
L["Options.RuneMainHand"] = "主手"
L["Options.RuneOffHand"] = "副手"
L["Options.RuneTwoHanded"] = "双手"
L["Options.RuneDualWield"] = "双持"

-- ============================================================================
-- OPTIONS: ROGUE POISON PREFERENCES
-- ============================================================================
L["Options.RoguePoisonNote"] = "选择要涂抹的毒药及其优先级顺序（最上方优先级最高）。被禁用的毒药永远不会被施放，也不会触发提示。"
L["Options.PoisonLethal"] = "致命"
L["Options.PoisonNonLethal"] = "非致命"
L["Options.PoisonMoveUp"] = "提高优先级"
L["Options.PoisonMoveDown"] = "降低优先级"
L["Options.PoisonReset"] = "重置为默认"

-- ============================================================================
-- OPTIONS: BUFF SETTINGS GEAR ICONS
-- ============================================================================
L["Options.BronzeHideInCombat"] = "战斗中隐藏"
L["Options.BronzeHideInCombat.Desc"] = "在战斗中隐藏青铜龙的祝福提示。这个增益没那么关键，你通常不会想在战斗中途去补它。"
L["Options.DruidIgnoreTravelForm"] = "在旅行途中忽略"
L["Options.DruidIgnoreTravelForm.Desc"] = "在处于旅行形态（陆地、水生、飞行或坐骑形态）或骑乘坐骑时隐藏形态错误提示，以免在跑路时打扰你。"
L["Options.DelveFoodTimer"] = "30秒后自动隐藏"
L["Options.DelveFoodTimer.Desc"] = "启用后，地下堡食物提示会在进入地下堡后显示30秒，然后自动隐藏。禁用后，只要你在地下堡中且缺少该增益，提示就会一直显示。"

-- ============================================================================
-- OPTIONS: LAYOUT
-- ============================================================================
L["Options.Layout"] = "布局"
L["Options.SplitFrame"] = "分离为独立框体"
L["Options.SplitFrame.Desc"] = "将此类别中的增益显示在可独立移动的单独框体中。"
L["Options.DisplayOrder"] = "堆叠顺序"
L["Options.DisplayOrder.Note"] = "整合框体中各类别的自上而下排列顺序。已分离的类别位于独立的框体中，不参与此排序。"

-- Layout page
L["Layout.DetachedIcons"] = "已独立图标"
L["Layout.NoDetached"] =
    '暂无独立图标。可在“提示项”页面的增益设置面板中分离增益（“独立框体”）。'
L["Layout.FrameNotFound"] = "该框体当前在游戏中不存在。\n一旦对应的插件创建了该框体，它就会出现在锚点下拉菜单中。"

-- Buff panel
L["BuffPanel.SettingsLink"] = "设置"
L["BuffRow.SettingsLink.Tooltip"] = "该增益的声音警报、显示模式及分离选项。"
L["BuffRow.Extras"] = "选项"
L["BuffRow.Option.Poisons"] = "毒药"
L["BuffRow.Option.Runeforge"] = "符文熔铸"
L["BuffRow.Glyph.Sound"] = "声音警报"
L["BuffRow.Glyph.Detached"] = "独立图标"
L["BuffRow.Glyph.Detached.Desc"] = "该图标可在屏幕上自由放置。可在该增益的“设置”或“布局”页面中管理。"
L["BuffRow.Glyph.New"] = "新增增益"
L["BuffRow.Glyph.New.Desc"] = "在最近的更新中添加。"
L["BuffPanel.EditOption"] = "编辑 %s"
L["BuffPanel.Show"] = "显示"
L["BuffPanel.MageFoodContent"] = "显示地点"
L["BuffPanel.MageFoodContent.All"] = "所有副本"
L["BuffPanel.MageFoodContent.Dungeon"] = "仅地下城"
L["BuffPanel.MageFoodContent.Raid"] = "仅团队副本"
L["BuffPanel.Sound"] = "声音"
L["BuffPanel.Sound.None"] = "无"
L["BuffPanel.Detached"] = "独立框体 (分离)"
L["BuffPanel.Detached.Desc"] = "将此增益从其所属类别中拆分出来，放入可独立定位的框体中。\n可在“布局”页面或通过解锁框体来调整位置。"


L["DisabledReason.NotDetached"] = "该增益未被分离 - 它位于其所属类别的框体内部。"
L["DisabledReason.CasterAlways"] = '仅在就位确认模式下适用。请先将“显示”切回就位确认。'

-- Detached Icons
L["DetachedIcons.Reattach"] = "恢复至所属类别"
L["DetachedIcons.ResetPos"] = "重置位置"

-- ============================================================================
-- OPTIONS: APPEARANCE
-- ============================================================================
L["Options.Appearance"] = "外观"
L["Options.Override"] = "覆盖"
L["Options.Override.Inherited"] = "继承自默认值"
L["Options.Override.Overriding"] = "已覆盖默认值"
L["Options.Override.Appearance.Desc"] = "为该类别覆盖全局外观默认值。\n关闭时，下方的各项控件将显示继承自“默认值”页面的数值。"
L["Options.Override.Glow.Desc"] = "为该类别覆盖全局发光设置。\n关闭时，下方的各项控件将显示继承自“默认值”页面的数值。"
L["Options.Customize"] = "自定义"
L["Options.ResetPosition"] = "重置位置"
L["Options.MasqueNote"] = "缩放和边框设置由Masque管理。"

-- ============================================================================
-- OPTIONS: SETTINGS TAB
-- ============================================================================
L["Options.ShowLoginMessages"] = "显示登录信息"
L["Options.ShowMinimapButton"] = "显示小地图按钮"

-- Hide when section
L["Options.HideWhen"] = "隐藏条件"
L["Options.HideWhen.Alone"] = "单人时"
L["Options.HideWhen.Alone.Title"] = "单人时隐藏"
L["Options.HideWhen.Alone.Desc"] = "不在小队或团队中时，隐藏所有增益提示"
L["Options.HideWhen.Resting"] = "休息时"
L["Options.HideWhen.Resting.Title"] = "休息时隐藏"
L["Options.HideWhen.Resting.Desc"] = "在旅店或主城时隐藏增益提示。"
L["Options.HideWhen.Combat"] = "战斗中"
L["Options.HideWhen.Expiring"] = "战斗中不提示即将过期"
L["Options.HideWhen.Expiring.Title"] = "战斗中不提示即将过期的增益"
L["Options.HideWhen.Expiring.Desc"] = "在战斗中不会显示即将过期的增益，仅显示完全缺失的增益"
L["Options.HideWhen.Vehicle"] = "载具中"
L["Options.HideWhen.Vehicle.Title"] = "载具中隐藏"
L["Options.HideWhen.Vehicle.Desc"] = "使用任务载具时隐藏所有增益提示。即使禁用，团队和特殊增益仍会显示"
L["Options.HideWhen.Mounted"] = "乘骑坐骑时"
L["Options.HideWhen.Mounted.Title"] = "乘骑坐骑时隐藏"
L["Options.HideWhen.Mounted.Desc"] = "乘骑坐骑时隐藏所有增益提示。优先级高于类别特定的坐骑隐藏设置"
L["Options.HideWhen.Legacy"] = "旧资料片副本"
L["Options.HideWhen.Legacy.Title"] = "在旧资料片副本中隐藏"
L["Options.HideWhen.Legacy.Desc"] = "在激活传承战利品模式的旧资料片副本中隐藏所有增益提示"
L["Options.HideWhen.Leveling"] = "练级时"
L["Options.HideWhen.Leveling.Title"] = "练级时隐藏"
L["Options.HideWhen.Leveling.Desc"] = "未满级时隐藏所有增益提示"

-- ============================================================================
-- OPTIONS: BUFF TRACKING MODE
-- ============================================================================
L["Options.BuffTracking"] = "增益追踪"
L["Options.BuffTracking.All"] = "所有增益，所有玩家"
L["Options.BuffTracking.All.Desc"] = "显示所有职业的团队和特殊增益，并追踪整个队伍的覆盖情况。"
L["Options.BuffTracking.MyBuffs"] = "仅我的增益，所有玩家"
L["Options.BuffTracking.MyBuffs.Desc"] = "仅显示你的职业能提供的增益，但会追踪整个队伍的覆盖情况。"
L["Options.BuffTracking.OnlyMine"] = "仅我需要的增益"
L["Options.BuffTracking.SelfOnly"] = "仅我的增益，仅限自身"
L["Options.BuffTracking.SelfOnly.Desc"] = "仅显示你的职业能提供的增益，且仅检查自身是否拥有。不计算团队数量，不包含你对他人施放的增益。"
L["Options.BuffTracking.Smart"] = "智能"
L["Options.BuffTracking.Smart.Desc"] = "对你的职业提供的增益追踪整个队伍，对其他职业的增益仅检查自身。"
L["Options.BuffTracking.Mode"] = "增益追踪模式"
L["Options.BuffTracking.Mode.Desc"] = "控制显示哪些团队和特殊增益，以及是追踪整个队伍还是仅追踪自身。"
L["Options.BuffTracking.Override.Default"] = "默认（使用上方的模式）"
L["Options.BuffTracking.Override.OutsideInstances"] = "地下城与团队副本外"
L["Options.BuffTracking.Override.OutsideInstances.Desc"] = "在野外使用的追踪模式。在地下城、团队副本、场景战役和PvP中仍将使用上方选定的模式。"
L["Options.BuffTracking.Override.Combat"] = "战斗中"
L["Options.BuffTracking.Override.Combat.Desc"] = "在战斗中使用的追踪模式。例如，切换为“仅我的增益”可在脱战时保留其他职业增益提示以便喊话补BUFF，但在开打后自动隐藏。"
L["Options.BuffTracking.Override.Leveling"] = "练级期间"
L["Options.BuffTracking.Override.Leveling.Desc"] = "未满级时使用的追踪模式。达到满级后，将自动恢复使用上方选定的模式。"

-- ============================================================================
-- OPTIONS: PROFILES TAB
-- ============================================================================
L["Options.ActiveProfile"] = "当前配置文件"
L["Options.ActiveProfile.Desc"] = "在已保存的设置之间切换。每个角色可以使用不同的配置文件。"
L["Options.SelectProfile"] = "选择配置文件"
L["Options.Profile"] = "配置文件"
L["Options.CopyFrom"] = "复制自"
L["Options.Delete"] = "删除"
L["Options.PerSpecProfiles"] = "按专精配置文件"
L["Options.PerSpecProfiles.Desc"] = "切换专精时自动切换配置文件。"
L["Options.PerSpecProfiles.Enable"] = "启用按专精配置文件"

-- ============================================================================
-- OPTIONS: IMPORT/EXPORT
-- ============================================================================
L["Options.ExportSettings"] = "导出设置"
L["Options.ExportSettings.Desc"] = "复制下方字符串以分享你的设置。"
L["Options.ImportSettings"] = "导入设置"
L["Options.ImportSettings.DescPlain"] = "在下方粘贴设置字符串。"
L["Options.ImportSettings.Overwrite"] = "将覆盖当前激活的配置文件。"
L["Options.Export"] = "导出"
L["Options.Import"] = "导入"
L["Options.ImportSuccess"] = "设置导入成功！"
L["Options.FailedExport"] = "导出失败"
L["Options.UnknownError"] = "未知错误"

-- ============================================================================
-- OPTIONS: DIALOGS
-- ============================================================================
L["Dialog.Cancel"] = "取消"
L["Dialog.DeleteCustomBuff"] = '是否删除自定义增益 "%s"？'
L["Dialog.DeleteLoadout"] = '是否删除配装方案提示 "%s"？'
L["Dialog.ResetProfile"] = "是否将当前配置文件重置为默认值？\n\n当前配置文件的所有自定义设置将被删除并重载UI。"
L["Dialog.Reset"] = "重置"
L["Dialog.ReloadPrompt"] = "设置导入成功！\n是否重载UI以应用更改？"
L["Dialog.Reload"] = "重载"
L["Dialog.NewProfilePrompt"] = "请输入新配置文件的名称："
L["Dialog.Create"] = "创建"
L["Dialog.DiscordPrompt"] = "加入 BuffReminders 的 Discord 社区！\n复制下方链接 (Ctrl+C)："
L["Dialog.KofiPrompt"] = "感谢支持 BuffReminders！\n复制下方链接 (Ctrl+C)："
L["Dialog.Close"] = "关闭"

-- ============================================================================
-- OPTIONS: TEST / LOCK
-- ============================================================================
L["Options.LockUnlock"] = "锁定 / 解锁"
L["Options.LockUnlock.Desc"] = "解锁后将显示锚点手柄，以便调整增益框体的位置。"
L["Options.TestAppearance"] = "测试图标外观"
L["Options.TestAppearance.Desc"] = "使用模拟数据显示选定的增益以预览外观。"
L["Options.Test"] = "测试"
L["Options.StopTest"] = "停止测试"
L["Options.AnchorHint"] = "点击锚点以更新其对齐位置或坐标"
L["Options.Lock"] = "锁定"
L["Options.Unlock"] = "解锁"

-- ============================================================================
-- OPTIONS: CUSTOM BUFF DIALOG
-- ============================================================================
L["CustomBuff.Edit"] = "编辑自定义增益"
L["CustomBuff.EditShort"] = "编辑"
L["CustomBuff.Add"] = "添加自定义增益"
L["CustomBuff.AddButton"] = "+ 添加自定义增益"
L["CustomBuff.Empty"] = "暂无自定义增益。请在下方添加。"
L["CustomBuff.RestrictedNote"] = "在战斗、首领战和大秘境中隐藏——魔兽API在这些环境下限制了光环读取。动作条发光检测在战斗中依然有效。"
L["CustomBuff.SpellIDs"] = "法术ID:"
L["CustomBuff.Lookup"] = "查找"
L["CustomBuff.AddSpellID"] = "+ 添加法术ID"
L["CustomBuff.Name"] = "名称:"
L["CustomBuff.LineBreakHint"] = "（使用 \\n 换行）"
L["CustomBuff.Appearance"] = "外观"
L["CustomBuff.BuffTracking"] = "增益追踪"
L["CustomBuff.Requirements"] = "要求"
L["CustomBuff.ShowIn"] = "显示位置"
L["CustomBuff.ClickAction"] = "点击动作"

-- Custom buff mode toggles
L["CustomBuff.WhenActive"] = "激活时"
L["CustomBuff.WhenMissing"] = "缺失时"
L["CustomBuff.OnlyIfSpellKnown"] = "仅当掌握法术时"

-- Custom buff class dropdown
L["Class.Any"] = "任意"
L["Class.DeathKnight"] = "死亡骑士"
L["Class.DemonHunter"] = "恶魔猎手"
L["Class.Druid"] = "德鲁伊"
L["Class.Evoker"] = "唤魔师"
L["Class.Hunter"] = "猎人"
L["Class.Mage"] = "法师"
L["Class.Monk"] = "武僧"
L["Class.Paladin"] = "圣骑士"
L["Class.Priest"] = "牧师"
L["Class.Rogue"] = "潜行者"
L["Class.Shaman"] = "萨满祭司"
L["Class.Warlock"] = "术士"
L["Class.Warrior"] = "战士"

-- Custom buff fields
L["CustomBuff.Spec"] = "专精:"
L["CustomBuff.Class"] = "职业:"
L["CustomBuff.RequireItem.EquippedBags"] = "已装备/背包中"
L["CustomBuff.RequireItem.Equipped"] = "已装备"
L["CustomBuff.RequireItem.InBags"] = "背包中"
L["CustomBuff.RequireItem.Hint"] = "物品ID - 缺失时隐藏"
L["CustomBuff.ItemCooldown"] = "冷却："
L["CustomBuff.ItemCooldown.Any"] = "任意"
L["CustomBuff.ItemCooldown.OffCooldown"] = "冷却完毕"
L["CustomBuff.ItemCooldown.OnCooldown"] = "冷却中"

-- Bar glow options
L["CustomBuff.BarGlow.WhenGlowing"] = "发光时检测"
L["CustomBuff.BarGlow.WhenNotGlowing"] = "不发光时检测"
L["CustomBuff.BarGlow.Disabled"] = "禁用"
L["CustomBuff.BarGlow"] = "动作条发光:"
L["CustomBuff.BarGlow.Title"] = "动作条发光替代检测"
L["CustomBuff.BarGlow.Desc"] = "在史诗钥石/PvP/战斗中由于增益API受限，使用动作条法术发光作为替代检测方法。若仅追踪增益是否存在，请禁用此项。"

-- Ready check / level
L["CustomBuff.ReadyCheckOnly"] = "仅就位确认时"
L["CustomBuff.Level"] = "等级:"
L["CustomBuff.Level.Any"] = "任意等级"
L["CustomBuff.Level.Max"] = "仅满级"
L["CustomBuff.Level.BelowMax"] = "未满级"

-- Click action
L["CustomBuff.Action.None"] = "无"
L["CustomBuff.Action.Spell"] = "法术"
L["CustomBuff.Action.Item"] = "物品"
L["CustomBuff.Action.Macro"] = "宏"
L["CustomBuff.Action.OnClick"] = "点击时:"
L["CustomBuff.Action.Title"] = "点击动作"
L["CustomBuff.Action.Desc"] = "设置点击此增益图标时的动作。法术会施放法术，物品会使用物品，宏会执行宏。"
L["CustomBuff.Action.MacroHint"] = "例：/use item:12345\n/use 13"

-- Save/Cancel/Delete
L["CustomBuff.Save"] = "保存"

-- Custom buff status
L["CustomBuff.InvalidID"] = "无效ID"
L["CustomBuff.NotFound"] = "未找到"
L["CustomBuff.NotFoundRetry"] = "未找到 (重试)"
L["CustomBuff.Error"] = "错误:"

-- ============================================================================
-- OPTIONS: DISCORD & KO-FI
-- ============================================================================
L["Options.JoinDiscord"] = "加入 Discord"
L["Options.JoinDiscord.Title"] = "点击获取邀请链接"
L["Options.JoinDiscord.Desc"] = "有反馈、功能建议或遇到BUG？\n欢迎加入 Discord！"
L["Options.SupportKofi"] = "在 Ko-fi 上赞助"
L["Options.SupportKofi.Title"] = "点击获取链接"
L["Options.SupportKofi.Desc"] = "喜欢使用 BuffReminders 吗？\n欢迎在 Ko-fi 上赞助支持后续开发！"

-- ============================================================================
-- OPTIONS: CUSTOM ANCHOR FRAMES
-- ============================================================================
L["Options.CustomAnchorFrames.Desc"] = "在锚点下拉菜单中添加全局框体名称（例：MyAddon_PlayerFrame）。\n游戏中不存在的框体会自动跳过。"
L["Options.Add"] = "添加"
L["Options.New"] = "新建"
L["Options.ResetToDefaults"] = "重置为默认值"

-- ============================================================================
-- OPTIONS: MISC
-- ============================================================================
L["Options.Off"] = "关闭"
L["Options.Always"] = "始终"
L["Options.ReadyCheck"] = "就位确认"
L["Options.Min"] = "分钟"

-- ============================================================================
-- COMPONENTS (UI/Components.lua)
-- ============================================================================
-- Content filter tooltip
L["Content.ClickToFilter"] = "点击以按 %s 难度过滤"

-- Mover labels
L["Mover.AnchorGrowth"] = "锚点 \194\183 增长方向 %s"
L["Mover.AnchorGrowthFrame"] = "锚点 \194\183 增长方向 %s \194\183 > %s"

-- Pet labels
L["Pet.SpiritBeast"] = "灵魂兽"

-- Appearance grid labels
L["Appearance.Width"] = "宽度"
L["Appearance.Height"] = "高度"
L["Appearance.Zoom"] = "缩放"
L["Appearance.Border"] = "边框"
L["Appearance.Spacing"] = "间距"
L["Appearance.Alpha"] = "透明度"
L["Appearance.Text"] = "字体大小"

-- Slider tooltip
L["Component.AdjustValue"] = "调整数值"
L["Component.AdjustValue.Desc"] = "点击输入或使用鼠标滚轮。"
L["Component.AdjustValue.ClickHint"] = "点击数字以输入具体数值"

-- Scope tag for globally-stored controls on category pages
L["Options.GlobalTag"] = "全局"
L["Options.GlobalTag.Title"] = "全局生效"
L["Options.GlobalTag.Desc"] =
    "此设置为整个插件全局保存。\n在此修改将影响所有类别，而不仅仅是当前类别。"

-- Disabled-control explanations
L["Component.DisabledReason.Title"] = "为何此项被禁用？"
L["DisabledReason.GrowDirection"] =
    '增长方向需要该类别处于独立框体中。\n请先在“布局”部分启用“分离为独立框体”。'
L["DisabledReason.ResetPosition"] =
    '仅已分离的类别才拥有独立位置。\n请先启用“分离为独立框体”。'
L["DisabledReason.OverrideSection"] = '请先开启该部分顶部的“覆盖”选项。'
L["DisabledReason.CombatOverride"] =
    '上方已开启“战斗中隐藏”，战斗中将不显示任何提示，因此该覆盖规则不会生效。\n取消勾选后方可使用战斗追踪覆盖规则。'
L["DisabledReason.LevelingOverride"] =
    '上方已开启“练级时隐藏”，练级期间将不显示任何提示，因此该覆盖规则不会生效。\n取消勾选后方可使用练级追踪覆盖规则。'
L["DisabledReason.ExpiringInCombat"] =
    '已开启“战斗中隐藏”，战斗中所有提示都将被隐藏。'
L["DisabledReason.HealthstoneThreshold"] = '请先启用“治疗石不足警告”。'
L["DisabledReason.UseDefaultThreshold"] = '取消勾选“使用默认阈值”以设置类别专属数值。'

-- Direction labels
L["Direction.Left"] = "左侧"
L["Direction.Center"] = "中心"
L["Direction.Right"] = "右侧"
L["Direction.Up"] = "上方"
L["Direction.Down"] = "下方"
L["Direction.Label"] = "方向"

-- Content visibility
L["Content.ShowIn"] = "显示条件:"

-- Content toggle definitions
L["Content.OpenWorld"] = "野外"
L["Content.Housing"] = "家园"
L["Content.Scenarios"] = "场景战役（地下堡、托加斯特等）"
L["Content.Dungeons"] = "地下城（含大秘境）"
L["Content.Raids"] = "团队副本"
L["Content.PvP"] = "PvP（竞技场与战场）"

-- Scenario difficulty
L["Content.Delves"] = "地下堡"
L["Content.OtherScenarios"] = "其他场景战役（托加斯特等）"

-- Dungeon difficulty
L["Content.NormalDungeons"] = "普通地下城"
L["Content.HeroicDungeons"] = "英雄地下城"
L["Content.MythicDungeons"] = "史诗地下城"
L["Content.MythicPlus"] = "史诗钥石地下城"
L["Content.TimewalkingDungeons"] = "时光漫游地下城"
L["Content.FollowerDungeons"] = "追随者地下城"

-- Raid difficulty
L["Content.LFR"] = "随机团队"
L["Content.NormalRaids"] = "普通团队副本"
L["Content.HeroicRaids"] = "英雄团队副本"
L["Content.MythicRaids"] = "史诗团队副本"

-- PvP types
L["Content.Arena"] = "竞技场"
L["Content.Battlegrounds"] = "战场"
L["Loadout.EquipFailed"] = "无法穿上装备套装，请确认套装中的每件装备都在背包里。"

L["Loadout.OpenTalentsFailed"] = "无法打开天赋窗口，请手动打开以修正提醒。"

L["Loadout.Require.TalentOption"] = "天赋或已知法术"

L["Overlay.Duplicate"] = "重复"

L["Overlay.NoGem"] = "没有\n宝石"

L["Overlay.Reagents"] = "材料\n不足"

L["Overlay.ReagentLabel"] = "材料"

L["Overlay.Ammo"] = "弹药\n不足"

L["Overlay.AmmoLabel"] = "弹药"

L["Overlay.EquipAmmo"] = "装备\n弹药"

L["Overlay.DriveBy"] = "增益\n目标"

L["Overlay.NoTracking"] = "没有\n跟踪"

L["Overlay.SleepingBag"] = "睡\n袋"

L["Overlay.CampSit"] = "工具"

L["Overlay.CampKit"] = "营地"

L["Overlay.NoImbue"] = "没有\n灌注"

L["Overlay.FeedPet"] = "喂食\n宠物"

L["Overlay.WrongAura"] = "错误\n光环"

L["Overlay.NoAspect"] = "没有\n型态"

L["Overlay.NoArmor"] = "没有\n护甲"

L["Overlay.NoRighteousFury"] = "没有\n怒气"

L["Overlay.NoInnerFire"] = "没有\n心灵\n之火"

L["Overlay.NoThorns"] = "没有\n荆棘术"

L["Overlay.NoOath"] = "没有\n誓言"

L["Label.Imp"] = "小鬼"

L["Label.Voidwalker"] = "虚空行者"

L["Label.Felhunter"] = "地狱猎犬"

L["Label.Sayaad"] = "萨亚德"

L["Label.Succubus"] = "魅魔"

L["Label.Ghoul"] = "食尸鬼"

L["Label.WaterElemental"] = "水元素"

L["Badge.Cauldron"] = "C"

L["Buff.DivineSpirit"] = "神圣灵魂"

L["Buff.ShadowProtection"] = "暗影防护"

L["Buff.LowReagents"] = "材料不足"

L["Buff.LowAmmo"] = "弹药不足"

L["Buff.DriveByBuffs"] = "枪弹增益"

L["Buff.Tracking"] = "追踪中"

L["Buff.SleepingBag"] = "舒适的睡袋"

L["Buff.Camp"] = "营地增益"

L["Buff.RockbiterWeapon"] = "石化武器"

L["Buff.FrostbrandWeapon"] = "冰封武器"

L["Buff.PetHappiness"] = "宠物快乐值"

L["Buff.PaladinAura"] = "圣骑士光环"

L["Buff.PaladinBlessing"] = "圣骑士祝福"

L["Buff.HunterAspect"] = "猎人形态"

L["Buff.TrueshotAura"] = "强击光环"

L["Buff.MageArmor"] = "霜/冰/魔甲术"

L["Buff.RighteousFury"] = "正义之怒"

L["Buff.InnerFire"] = "心灵之火"

L["Buff.LightningShield"] = "闪电盾"

L["Buff.ShamanImbue"] = "武器灌注"

L["Buff.WarlockArmor"] = "恶魔皮肤/护甲"

L["Buff.Thorns"] = "荆棘术"

L["Buff.OathOfLight"] = "誓言之光"

L["Buff.ManaGem"] = "法力宝石"

L["Tooltip.PaladinDuplicate"] = "重复检查"

L["Tooltip.PaladinAuraDuplicate.Desc"] = "当其他圣骑士已经给你相同类型的光环时，会发出警告。如果该光环行有备用光环，则会提示你选择备用光环。"

L["Tooltip.DriveBy.Desc"] = "在非战斗状态下，当目标是队伍外的友方玩家且缺少你提供的增益效果时，会显示此资讯。点击即可施放最适合的增益效果。"

L["Tooltip.SleepingBag.Desc"] = "仅在等级低於最高等级时显示。在战斗中、城市和旅馆中隐藏。会在「休息充足」效果结束前发出警告。在睡袋中休息时，图示会倒数显示下一层「休息充足」效果的持续时间。当「休息充足」效果达到3层时，会倒数计时显示下次刷新时间。"

L["Tooltip.TankOnly"] = "坦克检查"

L["Tooltip.RighteousFuryTank.Desc"] = "仅在您担任坦克角色（或主坦克）时显示。若要永远显示，请在设定中将“显示”设为“永远”。"

L["Tooltip.TankHint"] = "(坦克)"

L["Tooltip.TankTarget"] = "坦克目标"

L["Tooltip.ThornsTank.Desc"] = "组队时，它会检查你的坦克（坦克角色或主坦克），点击即可对他们施放荆棘术。单人或没有坦克时，它会检查你。"

L["Display.SnoozeChat.Loading"] = "%s: 已暂停提醒，直到下一个登入画面。输入 /br snooze 可再次显示所有提醒。"

L["Display.SnoozeChat.Rest"] = "%s: 提醒已自动暂停，直到您离开此休息区域。输入 /br snooze 可再次显示所有提醒。"

L["Display.UnsnoozeChat"] = "暂停提醒再次显示。"

L["Display.LoginSnooze"] = "消耗品关闭按钮现在是右键点击: 右键点选消耗品可暂停其提醒，或输入 |cFFFFD100/br snooze|r。"

L["Display.LoginCasterName"] = "外部增益现在可以显示施放者。请到 |cFFFFD100/br|r > 类别 > 外部增益启用。"

L["Externals.NoneTracked"] = "首先在「增益」>「外来增益」页面上追踪至少一个增益。"

L["Externals.Sound"] = "声音警报"

L["Externals.Sound.Tooltip"] = "您追踪的每个增益效果落在您身上时都会播放此声音。选择「无」以保持静音。|n若要为某个增益效果提供自己的声音，请将指标放在其行末尾的标志上。|n首领战斗期间的更改会在战斗结束时生效。"

L["Externals.Sound.Hint"] = "每个增益都可以从其所在行覆盖此设定。"

L["Externals.Sound.Link"] = "声音"

L["Externals.Sound.Silent"] = "静音"

L["Externals.Sound.Change"] = "点击以更改它。"

L["Externals.Sound.Plays"] = "当这个增益效果落在你身上时，游戏播放%s。"

L["Externals.Sound.Silenced"] = "此增益效果不发出任何声音。"

L["Externals.Sound.SilentByDefault"] = "对於共享声音来说，这个增益效果太频繁了。覆盖它以添加一个。"

L["Externals.Sound.NoAlert"] = "未设定声音警报。点选可赋予该增益其自己的声音。"

L["Externals.Sound.Override.Desc"] = "为这个增益赋予自己的声音。当此功能关闭时，增益会播放页面的声音警报。"

L["DisabledReason.SoundOverride"] = "开启「覆盖」来选择该增益效果的声音。"

L["Externals.SelectAll"] = "全部"

L["Externals.SelectAll.Tooltip"] = "追踪该群组中的每个增益。"

L["Externals.SelectNone"] = "无"

L["Externals.SelectNone.Tooltip"] = "停止追踪该群组中的每个增益。"

L["Externals.PersonalDefensives"] = "在你的防御"

L["Externals.GroupDefensives"] = "群体防御"

L["Externals.MinorGroupDefensives"] = "小群体防御"

L["Externals.Boosts"] = "伤害 & 法力"

L["Externals.Countdown"] = "倒计时"

L["Externals.ShowSwipe"] = "显示持续时间转圈"

L["Externals.ShowSwipe.Desc"] = "在图示上扫一条黑色的线。当增益耗尽时，转圈会露出图示。"

L["Externals.ShowTooltips"] = "显示工具提示"

L["Externals.ShowTooltips.Desc"] = "当滑鼠位於图示上时显示游戏的增益工具提示。这些图示不需要点击，只需要移动滑鼠。"

L["Externals.CasterName"] = "施放者名称"

L["Externals.CasterName.Desc"] = "在图标旁以职业颜色显示增益施放者。"

L["Externals.CasterNameOff"] = "请先选择施放者名称的显示位置。"

L["Externals.Sound.Claimed"] = "%s 已经为此法术ID播放一个声音。"

L["Externals.Custom"] = "你的增益"

L["Externals.Custom.SpellID"] = "法术ID"

L["Externals.Custom.Name"] = "名字"

L["Externals.Custom.Add"] = "添加"

L["Externals.Custom.Edit"] = "编辑"

L["Externals.Custom.Delete"] = "删除此增益"

L["Externals.Custom.Empty"] = "你自己还没有增益。"

L["Externals.Custom.SpellIDs"] = "法术ID"

L["Externals.Custom.RemoveID"] = "移除此法术ID"

L["Externals.Custom.Hint"] = "使用增益工具提示中的光环ID，而不是技能ID。逗号将多个ID组合到一个图示中。"

L["Externals.Custom.Unknown"] = "未知ID %d"

L["Externals.Custom.AlreadyIn"] = "已存在於 %s"

L["Externals.Custom.RowTooltip"] = "法术ID: %s"

L["Externals.Custom.Grab"] = "我的增益"

L["Externals.Custom.GrabTitle"] = "现在你身上有增益"

L["Externals.Custom.Grab.Tooltip"] = "请从你的增益中挑选现在没有条目涵盖的。您选择的那个将填满该栏位。"

L["Externals.Custom.GrabEmpty"] = "你身上没有新的增益。游戏在战斗、首领战和传奇钥石运行中隐藏了你的增益。"

L["Externals.Custom.GrabMore"] = "还有 %d 个"

L["Options.AppliesEverywhere"] = "应用于所有类别，各类别无法覆盖。"

L["Options.SlugOutline"] = "平滑外框"

L["Options.SlugOutline.Desc"] = "使用客户端的Slug文字渲染器绘制外框。边缘更平滑，但外框可能看起来稍微粗一点。"

L["Options.ExpirationWarning"] = "剩余时间低于此值时提醒"

L["Options.ExpirationWarning.Note"] = "持续时间较短的增益效果会更早发出警告，警告时间与其持续时间成正比。滑鼠悬停可查看范例。"

L["Options.ExpirationWarning.Desc"] = "持续时间较长的增益效果会在此阶段发出警告。持续时间较短的增益效果会在其持续时间的一部分时间发出警告（请参阅「进阶」部分）。持续时间为 5 分钟或更短的增益效果仅在消失时显示警告。自订增益效果的持续时间由其自行决定。"

L["Options.ExpirationAdvanced"] = "进阶"

L["Options.ExpirationShare"] = "共享持续时间"

L["Options.ExpirationShare.Note"] = "当增益效果剩余约 %d%% 时发出警告，但结束以前绝不会超过 %s 秒。"

L["Options.ExpirationShare.Example"] = "%s 增益: %s."

L["Options.ExpirationShare.Formula"] = "警告时间 = 分(%d%% x 持续时间，%s)，向下取整到整分钟"

L["Options.ExpirationShare.Off"] = "过期警告已关闭。"

L["Options.ExpirationPreview.Header"] = "警告时间根据增益持续时间:"

L["Options.ExpirationPreview.OrMore"] = "%s 或更多"

L["Options.Override.Expiration.Desc"] = "设置此类别的提醒时间。关闭时使用默认值页面的时间。"

L["Options.Reagent.Threshold"] = "低於多少警告"

L["Options.Reagent.Threshold.Desc"] = "当你携带的用於你所掌握的法术的材料数量少於多少数量时发出警告。"

L["Options.Reagent.RestedOnly"] = "只有在休息区域"

L["Options.Reagent.RestedOnly.Desc"] = "只在旅馆和城市发出警告，那里有商人出售材料。\n\n如果 |cffffcc00当休息时隐藏|r 是启用的，此警告从不显示。"

L["Options.Camp.LightFire"] = "提醒放置篝火"

L["Options.Camp.LightFire.Desc"] = "如果附近没有篝火，当你携带可用的篝火工具包和至少一件营地设施时，提醒会显示「营地」。点击放置最合适的工具包，然後点击地面。"

L["Options.Ammo.Threshold"] = "猎人 (堆叠)"

L["Options.Ammo.Threshold.Desc"] = "警告猎人装备的弹药数量不得低於此数量（每组 200 发）。"

L["Options.Ammo.Shots"] = "其他 (射击)"

L["Options.Ammo.Shots.Desc"] = "战士和盗贼使用弓箭或枪械。以下警告指出他们只能射击这麽多次。"

L["Tooltip.TargetLine"] = "施放在: %s"

L["Tooltip.Next"] = "下一个:"

L["Options.FreeConsumables.Follows"] = "遵循上方的显示场合过滤条件。"

L["Options.IconStyle"] = "图示样式"

L["Options.IconStyle.Desc"] = "现代: 扁平的方形边框。其他选项: 游戏中的圆形动作按钮边框。不用於外部或消耗品按钮。"

L["Options.IconStyle.Modern"] = "现代"

L["Options.IconStyle.Blizzard"] = "暴雪"

L["Options.IconStyle.Forever"] = "永恒"

L["DisabledReason.IconStyleMasque"] = "Masque 可以设定图示样式。若要使用此功能，请在 Masque 中停用 BuffReminders 群组。"

L["DisabledReason.IconStyleNoArt"] = "此游戏用户端缺少按钮图示。图示风格保持现代风格。"

L["Options.ShowTextToggle"] = "显示"

L["Options.MainText.Desc"] = "在图标上显示主要文字，例如 17/20 的数量或「没有宠物」标签。位置由默认值页面设置，过期倒计时始终显示。"

L["Options.TextPositions.Offset"] = "偏移"

L["Options.TextPositions.Size"] = "大小"

L["Options.TextSizes.Note"] = "自动将文字保持为基础大小。设定一个值以调整文字本身的大小（以图示的百分比表示）。"

L["Options.Interaction"] = "交互"

L["Options.TextOverlays"] = "文字与叠加效果"

L["Options.ItemFilters"] = "物品"

L["Options.Direction.Default"] = "默认"

L["Options.Direction.Desc"] = "此框架图标的排列方向。「默认」会遵循默认值页面的方向。"

L["Options.ClickToCast.Custom.Desc"] = "使该类别图示在右键选单和悬停高亮显示时可点选。即使此功能关闭，具有自订点击操作的增益效果仍可点击。"

L["Options.RightClickMenu"] = "右键点击: 暂停和设定选单"

L["Options.RightClickMenu.Desc"] = "右键点击需要点击多次才能打开的提醒图示，即可开启选单。此选单可以暂停提醒、暂停其所属类别或暂停所有提醒，并开启提醒的设定。此选单仅在非战斗状态下可用。如果此选项关闭，则右键单击与左键单击的功能相同。"

L["Options.SubIconReveal"] = "显示替代的"

L["Options.SubIconReveal.Desc"] = "某些提醒会显示替代方案的小图示。例如：背包中的其他消耗品、其他祝福、其他追踪功能、营地功能，以及团队或单人版本的团队增益效果。启用「悬停时」後，当游标停留在提醒图示上时，这些图示就会显示。点击图示即可使用对应的替代方案。点选操作需要在提醒类别（「类别」标签页）中启用「点击施放」选项。如果「点击施放」选项关闭，消耗品图示会显示您的物品，但无法点击，其他替代方案也不会显示。"

L["Options.SubIconReveal.Hover"] = "悬停时"

L["Options.SubIconReveal.Always"] = "永远"

L["Options.Snooze.Note"] = "暂停提醒会持续到下一个登入画面出现，或直到你离开开始设定提醒的城市或旅馆。输入 |cFFFFD100/br snooze|r 可暂停所有提醒，再次输入即可显示提醒。"

L["Options.RequestBuffInChat.Tooltip"] = "点选你职业无法施放的缺失增益，向你的队友请求帮助。"

L["ChatRequests.PageNote"] = "点选你职业无法施放的缺失增益，即可在聊天框中请求获得该增益。"

L["Options.ChatRequest.Wait"] = "请求之间等待 5 秒"

L["Options.ChatRequest.Wait.Desc"] = "阻止双击发送垃圾讯息。"

L["ChatRequests.Messages"] = "讯息"

L["ChatRequests.Restore"] = "恢复: %s"

L["DisabledReason.ChatRequestsOff"] = "请求停用时也关闭。"

L["DisabledReason.NoCustomMessages"] = "无自订讯息。"

L["ChatRequest.shadowProtection"] = "请补上暗影防护增益"

L["ChatRequest.thorns"] = "请给我荆棘术"

L["ChatRequest.paladinBlessing"] = "请给我%s"

L["Options.ShowDescriptionTooltips"] = "显示提示讯息"

L["Options.ShowDescriptionTooltips.Desc"] = "当滑鼠悬停在提示图示上时，显示点击所用法术或物品的工具提示。如果点选请求队伍获得增益效果，工具提示会显示增益效果及其提供者。战斗中不显示工具提示。"

L["Options.TooltipModifier"] = "提示键"

L["Options.TooltipModifier.Desc"] = "选取某个按键後，增益效果和物品的提示讯息仅在按住该按键时显示。您可以先将滑鼠指标指向图标，然後再按下按键。您可以在「预设设定」页面的「互动」部分启用提示讯息。"

L["Options.TooltipModifier.None"] = "无"

L["Menu.Snooze"] = "暂停 %s"

L["Menu.SnoozeAll"] = "暂停所有提醒"

L["Menu.AllReminders"] = "全部提醒"

L["Menu.Settings"] = "设定..."

L["Options.PetLabels.Classes"] = "显示标签的职业"

L["Options.PetLabels.Classes.Desc"] = "只在勾选职业的宠物上显示宠物标签。"

L["Options.ConsumableTextScale"] = "基础大小"

L["Options.ConsumableTextScale.Title"] = "基础文字大小"

L["Options.ConsumableTextScale.Desc"] = "堆叠计数、属性标签和标志的字体大小，以图示大小的百分比表示。三者中的每一个都可以覆盖下面的。"

L["Options.ConsumableBadgeOnSubIcons"] = "在子图示上显示品质标记"

L["Options.ConsumableBadgeOnSubIcons.Title"] = "品质标记在子图示上"

L["Options.ItemDisplay.SubIcons"] = "子图示"

L["Options.ItemDisplay.SubIconsDesc"] = "其他项目以小图示的形式显示在主图示旁。\"显示替代的\" 在「预设值」页面上设定它们何时显示。"

L["Options.SubIconSide"] = "替代方向"

L["Options.SubIconSide.Desc"] = "选择替代图示要显示在提醒图示的哪一侧。"

L["Options.PreferReusableRunes"] = "偏好可重复使用的增强符文"

L["Options.PreferReusableRunes.Title"] = "偏好可重复使用的增强符文"

L["Options.PreferReusableRunes.Desc"] = "如果您有可重复使用的增强符文，仅显示该符文。如果没有，显示其他符文。"

L["Options.PlaceAtPlayer"] = "将大餐和药锅放在脚下"

L["Options.PlaceAtPlayer.Desc"] = "点击大餐或药锅图标会将它放在您的位置。关闭此选项时，必须在地面上选择放置位置。"

L["Options.PoisonMainHand"] = "主手"

L["Options.PoisonOffHand"] = "副手"

L["Options.SearchReminders"] = "搜寻提醒"

L["Options.SearchReminders.Desc"] = "按名称、法术名称或职业名称寻找提醒。"

L["Options.SearchCount"] = "%d 找到"

L["Options.SearchEmpty"] = "没有找到与此搜寻相符的提醒。"

L["BuffPanel.ShamanImbue"] = "点击施放"

L["BuffPanel.ShamanImbue.Desc"] = "在你学会之前，点击会依序施放风怒、火舌和石化。"

L["BuffPanel.DriveBy.AllowPvP"] = "允许 PvP 标记的目标"

L["BuffPanel.DriveBy.AllowPvP.Desc"] = "给已开启 PvP 模式的玩家加增益效果也会使你被标记为 PvP 玩家。关闭此功能後，除非你也被标记为 PvP 玩家，否则其他已标记的玩家将被忽略。"

L["BuffPanel.DriveBy.Greeting"] = "问候"

L["BuffPanel.DriveBy.Greeting.Desc"] = "增益效果生效後，你可以密语或使用表情动作与该玩家互动，每位玩家每局限一次。战斗中不可使用。\n\n{name} = 玩家名字，{spell} = 增益。"

L["BuffPanel.DriveBy.Greeting.None"] = "没什麽"

L["BuffPanel.DriveBy.Greeting.Whisper"] = "密语"

L["BuffPanel.DriveBy.Greeting.Emote"] = "表情"

L["BuffPanel.DriveBy.Whisper"] = "文字"

L["BuffPanel.DriveBy.Emote"] = "表情"

L["BuffPanel.DriveBy.Emote.Wave"] = "挥手"

L["BuffPanel.DriveBy.Emote.Hello"] = "问好"

L["BuffPanel.DriveBy.Emote.Bow"] = "鞠躬"

L["BuffPanel.DriveBy.Emote.Salute"] = "敬礼"

L["BuffPanel.DriveBy.Emote.Smile"] = "微笑"

L["BuffPanel.DriveBy.Emote.Cheer"] = "欢呼"

L["BuffPanel.DriveBy.Emote.Custom"] = "自订表情..."

L["DriveBy.WhisperDefault"] = "使用{spell}强化你，祝你玩得开心！"

L["DriveBy.EmoteDefault"] = "使用{spell}强化{name}。祝你玩得开心！"

L["BuffPanel.WarlockDemon.Warn"] = "当不同的恶魔出现时发出警告"

L["BuffPanel.WarlockDemon.Warn.Desc"] = "当前召唤的恶魔不在此内容允许的恶魔之列时，显示「错误的恶魔」提醒。"

L["BuffPanel.WarlockDemon.Hint"] = "点击恶魔以允许召唤，可同时允许多个。清空某一行时，该内容将允许所有恶魔。"

L["BuffPanel.WarlockDemon.World"] = "世界"

L["BuffPanel.WarlockDemon.Dungeon"] = "地下城"

L["BuffPanel.WarlockDemon.Dungeon.Desc"] = "还涵盖场景和探究。"

L["BuffPanel.WarlockDemon.Raid"] = "团队"

L["BuffPanel.WarlockDemon.Felguard"] = "如果有天赋的话，恶魔学识总是会召唤恶魔守卫。"

L["BuffPanel.WarriorStance.Hint"] = "点击姿势即可按内容启用。未学习的姿势不计入在内。空白行不显示任何提示。"

L["BuffPanel.DruidForm.Hint"] = "点击型态即可按内容启用它们。未学习的型态不计​​入。空白行不显示任何提醒。"

L["BuffPanel.DruidForm.Caster"] = "施放者 (无型态)"

L["BuffPanel.PaladinBlessing.Hint"] = "每个职业的主要祝福。如果其他圣骑士给予祝福，则由你提供备用祝福。"

L["BuffPanel.Blessing.Give"] = "给予"

L["BuffPanel.Blessing.IfTaken"] = "如果收到"

L["BuffPanel.Blessing.InGive"] = "在给予"

L["BuffPanel.Blessing.InBackup"] = "在如果收到"

L["BuffPanel.Blessing.NotLearnedShort"] = "尚未学会"

L["BuffPanel.Blessing.Clear"] = "清除"

L["BuffPanel.Blessing.MainTip"] = "你把这个给每个%s。"

L["BuffPanel.Blessing.BackupTip"] = "如果其他圣骑士提供 %s，则使用这个。"

L["BuffPanel.Blessing.NotLearned"] = "尚未学会。你给予 %s 替代。"

L["BuffPanel.Blessing.NotLearnedNone"] = "尚未学会。已略过。"

L["BuffPanel.Blessing.None"] = "无祝福"

L["BuffPanel.Blessing.None.Desc"] = "此职业没有提醒。"

L["BuffPanel.Blessing.AddBackup"] = "新增备用"

L["BuffPanel.Blessing.ClickToChange"] = "点击更改。"

L["BuffPanel.Blessing.ResetRow"] = "重置回预设"

L["BuffPanel.Blessing.SelfOnlyNote"] = "仅圣骑士职业适用。"

L["DisabledReason.BlessingDefaults"] = "所有职业都使用其预设值。"

L["BuffPanel.BlessSelfOnly"] = "只有祝福我自己"

L["BuffPanel.BlessSelfOnly.Desc"] = "只检查并祝福自己"

L["BuffPanel.Tracking.Scope"] = "追踪"

L["BuffPanel.Tracking.Scope.Desc"] = "此提醒功能提供追踪功能。一次只能启用一个追踪功能。如果已启用任何追踪功能，则此提醒将被隐藏。"

L["BuffPanel.Tracking.Scope.Gathering"] = "只限采集"

L["BuffPanel.Tracking.Scope.All"] = "全部追踪"

L["BuffPanel.GroupCast"] = "自动群体版本 (使用材料)"

L["BuffPanel.GroupCast.Desc"] = "如果你的队伍中有足够多的成员没有增益效果且在有效范围内，并且你拥有所需的材料，则左键点击会对你施放群体版本。否则，会施放单体版本。将滑鼠悬停在图示上即可选择另一种施法版本。"

L["BuffPanel.GroupCast.Blessing.Desc"] = "如果一个职业中有足够多的成员缺少相同的祝福，点击即可施放更强大的版本（需要王者印记）。只有当你将该祝福赋予整个职业时才会发生这种情况。"

L["BuffPanel.GroupCastMin"] = "群体版本在"

L["BuffPanel.GroupCastMin.Suffix"] = " 缺少"

L["BuffPanel.GroupCastMin.Desc"] = "队伍中或某职业中，有多少成员没有该增益效果，点击即可施放群体版本的增益效果：对於强效祝福，则需满足此条件。所有增益效果适用相同数值。"

L["BuffPanel.PaladinAura.Hint"] = "每个内容只能使用一个主要光环。如果其他圣骑士使用了该光环，则使用备用光环。空行可以接受任何光环。抗性光环在生效期间始终有效。"

L["BuffPanel.PaladinAura.Run"] = "运行"

L["BuffPanel.PaladinAura.InRun"] = "在运行"

L["BuffPanel.PaladinAura.MainTip"] = "你在 %s 内容中运行此光环。"

L["BuffPanel.PaladinAura.NotLearned"] = "尚未学会。你使用 %s 替代。"

L["BuffPanel.PaladinAura.None"] = "无光环"

L["BuffPanel.PaladinAura.None.Desc"] = "任何光环都算。"

L["DisabledReason.AuraDefaults"] = "所有内容行均使用其预设值。"

L["BuffPanel.ThornsRequest"] = "坦克可以请求荆棘"

L["BuffPanel.ThornsRequest.Desc"] = "如果你担任坦克，且队伍中有德鲁伊（6级以上），则会显示你缺少荆棘效果。点击即可在聊天框中请求效果。需要在「聊天请求」页面启用「在聊天中请求缺少的增益效果」选项。"

L["BuffPanel.RighteousFuryShow"] = "显示"

L["BuffPanel.RighteousFuryShow.Tank"] = "担任坦克时"

L["BuffPanel.RighteousFuryShow.Always"] = "永远"

L["BuffPanel.RighteousFuryShow.Desc"] = "担任坦克时：仅限坦克职业或主坦克标记。永远：单人或组队均可。"

L["BuffPanel.MageArmor"] = "施放"

L["BuffPanel.MageArmor.Mage"] = "魔甲术"

L["BuffPanel.MageArmor.Ice"] = "霜/冰甲术"

L["BuffPanel.MageArmor.Desc"] = "图示上显示护甲，点击即可施放。任何护甲都符合要求。如果您还未学习这件护甲，则使用其他护甲。"

L["Options.Override.Interaction.Desc"] = "覆写此类别的全域互动设定。\n关闭时，下面的控制项会显示从「预设值」页面继承的值。"

L["Options.Override.Externals.Desc"] = "覆盖这些图标的全局外观默认值。\n关闭时，下方的图标控件显示从默认值页面继承的值。方向、文字与鼠标提示始终单独设置。"

L["Options.Override.OpenDefaults"] = "打开"

L["Options.Language"] = "语言"

L["Options.Language.Auto"] = "自动（游戏语言）"

L["Options.Language.Desc"] = "插件文字的语言。自动会使用游戏语言，尚未翻译的文字则显示英文。"

L["Language.enUS"] = "English"

L["Options.BuffTracking.OnlyMine.Desc"] = "显示所有类型的增益，但仅检查自身是否拥有。不显示团体数量统计。"

L["Dialog.ReloadLanguage"] = "重新加载界面后才会应用新的语言。\n现在重新加载吗？"

L["CustomBuff.Text"] = "叠加文字"

L["CustomBuff.Tab.Buff"] = "增益"

L["CustomBuff.Tab.Rules"] = "规则"

L["CustomBuff.Tab.Click"] = "点击"

L["CustomBuff.Section.Track"] = "法术"

L["CustomBuff.Section.ShowIcon"] = "显示"

L["CustomBuff.Section.Who"] = "角色"

L["CustomBuff.Section.Item"] = "需要物品"

L["CustomBuff.Section.Where"] = "显示的地方"

L["CustomBuff.Section.OnClick"] = "点击动作"

L["CustomBuff.NamePlaceholder"] = "命名此提醒器"

L["CustomBuff.NoSpellYet"] = "尚未有法术 - 在下方新增一个ID"

L["CustomBuff.ShowWhen"] = "显示"

L["CustomBuff.Expiration.Disabled"] = "过期警告仅适用於您缺失时显示的增益"

L["CustomBuff.RequireItem"] = "物品ID"

L["CustomBuff.RequireItem.Mode"] = "地点"

L["CustomBuff.RequireItem.Disabled"] = "请先设定一个物品ID。"

L["CustomBuff.Content"] = "内容"

L["CustomBuff.Action.SpellID"] = "法术ID"

L["CustomBuff.Action.ItemID"] = "物品ID"

L["CustomBuff.Action.MacroText"] = "巨集"

L["CustomBuff.Action.SpellHint"] = "这可能与被追踪的法术不同。追踪此增益并施放技能。"

L["CustomBuff.ValidateError"] = "加入一个有效的法术ID进行储存。"

L["CustomBuff.Share.Export"] = "导出"

L["CustomBuff.Share.ExportTitle"] = "导出自订增益"

L["CustomBuff.Share.ExportDesc"] = "复制下面的字串并将其交给其他玩家。"

L["CustomBuff.Share.Import"] = "导入"

L["CustomBuff.Share.ImportTitle"] = "导入自订增益"

L["CustomBuff.Share.ImportDesc"] = "在下面贴上自订增益字串。导入会新增一个新条目。"

L["CustomBuff.Share.Invalid"] = "这不是自订增益的字串。"

L["CustomBuff.Share.ImportDisabled"] = "请先贴上一个自订增益字串。"

L["CustomBuff.Share.MacroWarning"] = "点击此增益即可运行上面的巨集。仅从您信任的来源汇入它。"

L["CustomBuff.Share.Spells"] = "法术:"

L["CustomBuff.Share.Runs"] = "点击运行:"

L["Options.CustomAnchorFrames.PickNote"] = "您使用“挑选”按钮选择的每一框架都会落在此处，因此只需单击一下即可。"

L["Options.Auto"] = "自动"

L["Content.ClickToToggleVisibility"] = "点击切换 %s 的可视性"

L["DimensionLink.Link"] = "宽度和高度连动"

L["DimensionLink.Unlink"] = "取消宽度和高度的连动"

L["DimensionLink.Desc"] = "连动後，更改其中一个会同时更新两个。"

L["Mover.Role.Player"] = "玩家框架"

L["Mover.Role.Target"] = "目标框架"

L["Mover.Role.Focus"] = "焦点框架"

L["Mover.Role.Pet"] = "宠物框架"

L["Mover.Role.Party"] = "队伍框架"

L["Mover.Role.Raid"] = "团队框架"

L["Mover.Role.Boss"] = "首领框架"

L["Mover.Frame.Minimap"] = "小地图"

L["Mover.Frame.ObjectiveTracker"] = "目标追踪器"

L["Mover.PickFrame"] = "挑选"

L["Mover.PickHint"] = "指向一个框架并点击它。右键或按Esc键取消。"

L["Mover.PickNone"] = "鼠标下没有框架"

L["Mover.Frame.EssentialCooldowns"] = "基本冷却时间"

L["Mover.Frame.UtilityCooldowns"] = "功能冷却时间"

L["Mover.Frame.TrackedBuffIcons"] = "追踪增益图示"

L["Mover.Frame.TrackedBuffBars"] = "追踪增益条"

L["Mover.AnchorHidden"] = "(隐藏)"

L["Mover.AnchorNotFound"] = "(未找到)"

L["Content.AnyDungeon"] = "地下城"

L["Content.Raids40"] = "40人团队副本"

L["Content.Raids20"] = "20人团队副本"

L["Options.ConsumableBadgeOnSubIcons.Desc"] = "在每个子图标上也显示食物品质字母（例如“丰”代表丰盛，“飞”代表飞逝），而不仅在主图标上显示。"

L["Options.BuffReminderText"] = "「增益！」文字"

L["DisabledReason.ShowWithoutItems"] = "请先启用「不在背包中时也显示」。"

L["DisabledReason.PetLabelsOff"] = "请先选择「宠物标签」的位置。"

L["DisabledReason.OverrideRow"] = "请先勾选此行的「覆盖」。"

L["Dialog.DeleteProfile"] = "确定要删除配置文件“%s”吗？此操作无法撤销。"


L["Overlay.NoSacrifice"] = "未献祭"

L["Buff.DemonicSacrifice"] = "恶魔牺牲"

L["BuffPanel.ShowSharedWithHealthstone"] = "治疗石也使用此设定。"

L["BuffPanel.Show.ReadyCheck"] = "只在准备确认时"

L["BuffPanel.Show.ReadyCheck.Desc"] = "所有人只在准备确认期间看见提醒。"

L["BuffPanel.Show.ReadyCheckSolo"] = "准备确认及单人时"

L["BuffPanel.Show.ReadyCheckSolo.Desc"] = "所有人在准备确认期间看见提醒；术士在单人时也会看见。"

L["BuffPanel.Show.Caster"] = "术士一律显示"

L["BuffPanel.Show.Caster.Desc"] = "术士在所有场合都会看见提醒，其他人只在准备确认期间看见。"

L["BuffPanel.Show.Always"] = "所有人一律显示"

L["BuffPanel.Show.Always.Desc"] = "所有人在所有场合都会看见提醒。"

L["Externals.AppearanceNote"] = "战斗中所做的更改会在离开战斗后立即生效。解锁框架即可拖动整行。"

L["BuffReminders"] = "增益提醒"
L["|cffffffffBuff|r|cffffcc00Reminders|r"] = "|cffffffff增益|r|cffffcc00提醒|r"
