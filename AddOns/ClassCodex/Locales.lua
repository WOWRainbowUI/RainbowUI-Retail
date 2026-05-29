local _, ns = ...

-------------------------------------------------------------------------------
-- Localization init
--
-- ns.L is the global string table. Loaded next via the .toc:
--   1. Locales/enUS.lua  — always runs, populates every key with English
--   2. Locales/<X>.lua   — gated; the one matching GetLocale() overwrites
--                          translated keys; untranslated keys keep enUS
-- The __index fallback returns the key itself as a last-resort label. CI
-- ensures every consumer-referenced key exists in enUS, so this should
-- never fire in practice.
-------------------------------------------------------------------------------

local L = setmetatable({}, { __index = function(_, k) return k end })
ns.L = L

local locale = GetLocale()


-------------------------------------------------------------------------------
-- Simplified Chinese (zhCN)
-------------------------------------------------------------------------------
if locale == "zhCN" then

-- Tab labels
L["Guide"] = "指南"
L["Enchants & Gems"] = "附魔 & 宝石"
L["Enchants"] = "附魔"
L["Gems"] = "宝石"
L["Consumables"] = "消耗品"
L["Trinkets"] = "饰品"
L["Crafts"] = "制造"
L["BiS Gear"] = "最佳装备"
L["Best in Slot"] = "最佳装备"
L["About"] = "关于"
L["Enhancements"] = "强化"
L["View Talents"] = "查看天赋"

-- Section headers
L["Stat Priority"] = "属性优先级"
L["Talents"] = "天赋"
L["Rotation"] = "输出循环"

-- Context labels
L["Raid"] = "团本"
L["Dungeon"] = "地下城"
L["Delves"] = "地渊"
L["Crafting"] = "制造"

-- Rotation / stat contexts (Wowhead headings)
L["Single Target"] = "单体目标"
L["Multitarget"] = "多目标"
L["Opener"] = "起手"
L["AoE Opener"] = "AOE起手"
L["Single Target Opener"] = "单体目标起手"
L["Easy Mode"] = "简单模式"
L["Opener / Cooldowns"] = "起手 / 爆发"
L["Mythic+"] = "史诗钥石"
L["DPS Priority"] = "输出优先级"
L["Healing Priority"] = "治疗优先级"
-- L["General"] handled by the Settings section below ("常规").

-- Consumable labels
L["Flask"] = "药剂"
L["Combat Potion"] = "战斗药水"
L["Food"] = "食物"
L["Weapon Buff"] = "武器强化"
L["Augment Rune"] = "增强符文"

-- Gem labels
L["Primary"] = "主宝石"
L["Secondary"] = "副宝石"

-- Craft section headers
L["Early Crafts"] = "前期制造"
L["BiS Crafts"] = "最佳制造"

-- Talent build fallback
L["Build"] = "构建"

-- Empty / fallback states
L["Select a class and specialization above."] = "请在上方选择职业和专精。"
L["No data available for this spec."] = "该专精暂无数据。"
L["No builds available — check Wowhead for details."] = "暂无可用构建 - 请查看Wowhead了解详情。"
L["No builds for %s — check Wowhead."] = "%s暂无构建 - 请查看Wowhead。"
L["No rotation for %s — check Wowhead for details."] = "%s暂无输出循环 - 请查看Wowhead了解详情。"
L["No rotation for %s — check Wowhead."] = "%s暂无输出循环 - 请查看Wowhead。"

-- About panel
L["About Class Codex v%s"] = "关于 Class Codex v%s"
L["Stat priorities, talent builds, rotation guides, and gearing recommendations for your current spec.\n\nRecommendations are general guidelines. For precise results, sim your character with Raidbots."] = "为你当前专精提供属性优先级、天赋构建、输出循环指南和装备推荐。\n\n推荐仅供参考。如需精确结果，请使用Raidbots模拟你的角色。"
L["Links:"] = "链接："
L["Type /cc help for a list of commands."] = "输入 /cc help 查看命令列表。"
L["Supporters"] = "支持者"
L["Support on Patreon"] = "在 Patreon 上支持"
L["Class Codex is free and open to everyone. Supporters on Patreon help keep the data fresh and the project moving forward."] = "Class Codex 对所有人免费开放。Patreon 上的支持者帮助我们保持数据更新并推动项目前进。"
L["Be the first to support Class Codex!"] = "成为 Class Codex 的第一位支持者！"
L["Open Settings"] = "打开设置"
L["Open Compendium"] = "打开图鉴"

-- Tooltip
L["Stat Priority on Tooltips"] = "鼠标提示属性优先级"

-- Settings headers
L["Tooltips"] = "鼠标提示"
L["General"] = "常规"
L["Floating Panel"] = "浮动面板"
L["Docked Panel"] = "停靠面板"
L["Panel"] = "面板"

-- Settings: checkbox labels
L["Stat Priority Ranks"] = "属性优先级排名"
L["Wowhead BiS on Tooltips"] = "鼠标提示Wowhead最佳装备信息"
L["Icy Veins BiS on Tooltips"] = "鼠标提示Icy Veins最佳装备信息"
L["BiS Source"] = "最佳装备来源"
L["Trinket Tier on Tooltips"] = "鼠标提示饰品等级"
L["Current Class Only"] = "仅当前职业"
L["Highlight Owned Gear"] = "高亮已拥有装备"
L["Minimap Button"] = "小地图按钮"
L["Login Message"] = "登录消息"
L["Show Stat Priority"] = "显示属性优先级"
L["Show Talents"] = "显示天赋"
L["Show Rotation"] = "显示输出循环"
L["Show Enchants"] = "显示附魔"
L["Show Gems"] = "显示宝石"
L["Show Consumables"] = "显示消耗品"
L["Show Trinkets"] = "显示饰品"
L["Show Crafts"] = "显示制造"
L["Show BiS Gear"] = "显示最佳装备"

-- Settings: tooltip descriptions
L["Show stat priority rank (#1, #2, #3) next to stat names on item tooltips."] = "在物品鼠标提示的属性名称旁显示属性优先级排名（#1、#2、#3）。"
L["Show which specs an item is Best in Slot for (Wowhead) on item tooltips."] = "在物品鼠标提示中显示该物品是哪些专精的最佳装备 (Wowhead)。"
L["Show which specs an item is Best in Slot for (Icy Veins) on item tooltips."] = "在物品鼠标提示中显示该物品是哪些专精的最佳装备 (Icy Veins)。"
L["Show trinket tier rankings and the tier badge on item tooltips."] = "在物品鼠标提示中显示饰品等级排名和等级标识。"
L["Only show BiS and trinket tier info for your current class on tooltips."] = "鼠标提示中仅显示当前职业的最佳装备和饰品等级信息。"
L["Tint BiS and Trinket rows with a subtle green background when you already own the item (bags, bank, reagent bank, warbank, or equipped). Applies to both the docked and floating panels."] = "当你已拥有物品（背包、银行、材料银行、战团银行或已装备）时，用淡绿色背景标记最佳装备和饰品行。同时适用于停靠面板和浮动面板。"
L["Show a minimap button for quick access. Left-click opens the Compendium, right-click opens Settings."] = "显示小地图按钮以快速访问。左键点击打开图鉴，右键点击打开设置。"
L["Print the 'Class Codex loaded — type /cc to open' message to chat when you log in or reload."] = "登录或重载界面时，在聊天框中显示 'Class Codex 已加载 — 输入 /cc 打开' 消息。"
L["Show the Stat Priority section when the panel is floating."] = "浮动面板中显示属性优先级部分。"
L["Show the Talents section when the panel is floating."] = "浮动面板中显示天赋部分。"
L["Show the Rotation section when the panel is floating."] = "浮动面板中显示输出循环部分。"
L["Show the Enchants section when the panel is floating."] = "浮动面板中显示附魔部分。"
L["Show the Gems section when the panel is floating."] = "浮动面板中显示宝石部分。"
L["Show the Consumables section when the panel is floating."] = "浮动面板中显示消耗品部分。"
L["Show the Trinkets section when the panel is floating."] = "浮动面板中显示饰品部分。"
L["Show the Crafts section when the panel is floating."] = "浮动面板中显示制造部分。"
L["Show the BiS Gear section when the panel is floating."] = "浮动面板中显示最佳装备部分。"
L["Show the Stat Priority section when the panel is docked."] = "停靠面板中显示属性优先级部分。"
L["Show the Talents section when the panel is docked."] = "停靠面板中显示天赋部分。"
L["Show the Rotation section when the panel is docked."] = "停靠面板中显示输出循环部分。"
L["Show the Enchants section when the panel is docked."] = "停靠面板中显示附魔部分。"
L["Show the Gems section when the panel is docked."] = "停靠面板中显示宝石部分。"
L["Show the Consumables section when the panel is docked."] = "停靠面板中显示消耗品部分。"
L["Show the Trinkets section when the panel is docked."] = "停靠面板中显示饰品部分。"
L["Show the Crafts section when the panel is docked."] = "停靠面板中显示制造部分。"
L["Show the BiS Gear section when the panel is docked."] = "停靠面板中显示最佳装备部分。"

-- Chat messages
L["loaded — type |cff00ccff/cc|r to open"] = "已加载 — 输入 |cff00ccff/cc|r 打开"
L["Switched to %s (detected)"] = "已切换至%s（自动检测）"
L["Docked"] = "已停靠"
L["Floating"] = "浮动"
L["Reset"] = "已重置"
L["Compendium not available."] = "图鉴不可用。"
L["Minimap button shown"] = "小地图按钮已显示"
L["Minimap button hidden"] = "小地图按钮已隐藏"
L["Minimap button not available"] = "小地图按钮不可用"
L["Unknown command. Type /cc help"] = "未知命令。输入 /cc help 查看帮助"
L["Settings registration failed: %s"] = "设置注册失败：%s"
L["Compendium data not loaded."] = "图鉴数据未加载。"

-- Stat Targets / DR (character pane tooltip extras)
L["Stat Targets"] = "属性目标"
L["Show Stat Targets"] = "显示属性目标"
L["Stat Priority Source Line"] = "属性优先级来源行"
L["Stat priority"] = "属性优先级"
L["Show the Stat Targets section (live bars vs Archon empirical targets) on the Stats tab when the panel is docked."] = "面板停靠时,在属性标签上显示属性目标部分(实时条形图与 Archon 实测目标对比)。"
L["Show the Stat Targets section (live bars vs Archon empirical targets) on the Stats tab when the panel is floating."] = "面板浮动时,在属性标签上显示属性目标部分(实时条形图与 Archon 实测目标对比)。"
L["Stat targets can't be computed in combat — values update after combat ends."] = "战斗中无法计算属性目标 — 战斗结束后数值会更新。"
L["alt"] = "变体"
L["alt %d"] = "变体 %d"

-- Tooltip / data source labels
L["Source Display"] = "来源显示"
L["How to display data sources (Wowhead, Icy Veins) on item tooltips."] = "如何在物品提示中显示数据来源(Wowhead、Icy Veins)。"
L["When to show a footer line on item tooltips noting which hero / context the displayed ranks come from. 'Only when different' surfaces the line only when the resolved hero diverges from the one you're currently playing — useful as a quiet reminder that a pin or panel selection has drifted from in-game state."] = "何时在物品提示底部显示来源行,标明所显示的优先级来自哪个英雄天赋 / 情境。'仅当不同'仅在解析的英雄天赋与您当前所玩的不同时显示。"
L["Always"] = "始终"
L["Off"] = "关闭"
L["Only when different"] = "仅当不同"
L["Both"] = "两者"
L["Icons"] = "图标"
L["Labels"] = "标签"
L["Wowhead"] = "Wowhead"
L["Archon"] = "Archon"

-- Encounter context labels
L["M+ Dungeons"] = "史诗钥石地下城"
L["Raid Bosses (Heroic)"] = "团本头目(英雄)"
L["Raid Bosses (Mythic)"] = "团本头目(史诗)"

-- Loadout Dock
L["Loadout Dock"] = "配置坞"
L["Show Loadout Dock"] = "显示配置坞"
L["Floating widget that shows the active talent loadout name. Click to switch to any saved Blizzard loadout or Class Codex recommendation."] = "显示当前天赋配置名称的浮动小部件。点击可切换到任何已保存的暴雪配置或 Class Codex 推荐配置。"
L["Click to switch loadouts."] = "点击切换配置。"
L["Right-click for options."] = "右键查看选项。"
L["Cannot switch loadouts in combat."] = "战斗中无法切换配置。"
L["No loadouts available"] = "无可用配置"
L["No talent builds available."] = "无可用天赋构筑。"
L["No Archon builds available."] = "无可用 Archon 构筑。"
L["Pick a build"] = "选择构筑"
L["Custom build"] = "自定义构筑"
L["Saved Loadouts"] = "已保存的配置"
L["Show Saved Loadouts in menu"] = "在菜单中显示已保存的配置"
L["Show Wowhead recommendations in menu"] = "在菜单中显示 Wowhead 推荐"
L["Show Archon recommendations in menu"] = "在菜单中显示 Archon 推荐"
L["Include your Blizzard saved talent loadouts in the dock's click menu."] = "将您已保存的暴雪天赋配置加入配置坞的点击菜单。"
L["Include the Wowhead-sourced recommended builds in the dock's click menu."] = "将来自 Wowhead 的推荐构筑加入配置坞的点击菜单。"
L["Include the Archon per-encounter recommended builds in the dock's click menu."] = "将 Archon 按头目推荐的构筑加入配置坞的点击菜单。"
L["Show spec icon"] = "显示专精图标"
L["Show your active specialization's icon next to the loadout name."] = "在配置名称旁显示当前专精的图标。"
L["Show hero talent icon"] = "显示英雄天赋图标"
L["Show your active hero talent's icon next to the loadout name."] = "在配置名称旁显示当前英雄天赋的图标。"
L["Show border"] = "显示边框"
L["Draw a thin border around the loadout dock. Off for a borderless minimal look."] = "在配置坞周围绘制细边框。关闭以获得简约外观。"
L["Background opacity"] = "背景不透明度"
L["Translucency of the loadout dock's background plate. 0 = invisible, 100 = solid."] = "配置坞背景板的透明度。0 = 完全透明,100 = 不透明。"
L["Width"] = "宽度"
L["Width of the loadout dock in pixels. Ignored when Auto-fit width is on."] = "配置坞的宽度(像素)。开启自适应宽度时此设置被忽略。"
L["Auto-fit width"] = "自适应宽度"
L["Resize the dock automatically to fit the active loadout name. Overrides the Width slider when enabled."] = "自动调整配置坞大小以适应当前配置名称。开启时覆盖宽度滑块。"
L["Scale"] = "缩放"
L["Scale of the loadout dock. Grows the font, icons, and height proportionally."] = "配置坞的缩放。字体、图标和高度按比例增大。"
L["Content alignment"] = "内容对齐"
L["Where the dock's icons + label sit when the dock is wider than the content."] = "当配置坞宽于内容时,图标和标签的位置。"
L["Center"] = "居中"
L["Left"] = "靠左"
L["Right"] = "靠右"
L["Hide in combat"] = "战斗中隐藏"
L["Hide the loadout dock entirely during combat. Talent swaps fail in combat anyway, so this just removes the visual noise."] = "战斗中完全隐藏配置坞。反正战斗中无法切换天赋,这只是移除视觉干扰。"
L["Lock dock position"] = "锁定配置坞位置"
L["Prevent the loadout dock from being dragged. Toggle off to reposition, then re-enable to keep it from moving accidentally."] = "防止配置坞被拖动。关闭以重新定位,完成后重新开启以避免意外移动。"
L["Lock position"] = "锁定位置"
L["Unlock position"] = "解锁位置"
L["Position locked - unlock in Settings"] = "位置已锁定 - 在设置中解锁"

-- PvP
L["PvP"] = "PvP"
L["Arena"] = "竞技场"
L["Battleground"] = "战场"
L["Honor Talents"] = "荣誉天赋"
L["Honor talents apply in War Mode or PvP instances."] = "荣誉天赋在战争模式或 PvP 副本中生效。"
L["No PvP builds available."] = "暂无 PvP 构筑。"
L["No PvP gear data for this spec yet."] = "暂无该专精的 PvP 装备数据。"
L["No PvP enchants for this spec yet."] = "暂无该专精的 PvP 附魔数据。"
L["No PvP enchant/gem data for this spec yet."] = "暂无该专精的 PvP 附魔/宝石数据。"
L["No PvP stat priority for this spec yet."] = "暂无该专精的 PvP 属性优先级。"
L["No PvP stat targets for this spec yet."] = "暂无该专精的 PvP 属性目标。"

-- Talent Pane / Character Pane Button
L["Talent Pane"] = "天赋面板"
L["Show Class Codex on talent frame"] = "在天赋窗口显示 Class Codex"
L["Show the Class Codex build picker on the Blizzard talent frame. Disable to hide it entirely."] = "在暴雪天赋窗口显示 Class Codex 构筑选择器。关闭以完全隐藏。"
L["Character Pane Button"] = "角色面板按钮"
L["Click to toggle panel"] = "点击切换面板"
L["Lock Button Position"] = "锁定按钮位置"
L["Prevent the gear button from being moved by Shift-drag on the character pane."] = "防止角色面板上的装备按钮被 Shift-拖动移动。"
L["Shift-drag to move - Shift+Right-click to reset"] = "Shift-拖动以移动 - Shift+右键以重置"
L["Horizontal Offset"] = "水平偏移"
L["Horizontal offset (pixels) from the character pane top-right corner."] = "相对于角色面板右上角的水平偏移(像素)。"
L["Vertical Offset"] = "垂直偏移"
L["Vertical offset (pixels) from the character pane top-right corner."] = "相对于角色面板右上角的垂直偏移(像素)。"

-- Footer
L["Today"] = "今天"
L["Yesterday"] = "昨天"
L["%d days ago"] = "%d 天前"
L["Last refreshed: %s"] = "上次更新：%s"
L["Data refreshes daily. Update Class Codex to get the latest."] = "数据每日更新。请更新 Class Codex 以获取最新内容。"


-------------------------------------------------------------------------------
-- Traditional Chinese (zhTW)
-------------------------------------------------------------------------------
elseif locale == "zhTW" then

-- Tab labels
L["Guide"] = "指南"
L["Enchants & Gems"] = "附魔與寶石"
L["Enchants"] = "附魔"
L["Gems"] = "寶石"
L["Consumables"] = "消耗品"
L["Trinkets"] = "飾品"
L["Crafts"] = "製造"
L["BiS Gear"] = "最佳裝備"
L["Best in Slot"] = "最佳裝備"
L["About"] = "關於"
L["Enhancements"] = "強化"
L["View Talents"] = "查看天賦"

-- Section headers
L["Stat Priority"] = "屬性優先順序"
L["Talents"] = "天賦"
L["Rotation"] = "輸出循環"

-- Context labels
L["Raid"] = "團隊副本"
L["Dungeon"] = "地城"
L["Delves"] = "探究"
L["Crafting"] = "製造"

-- Rotation / stat contexts (Wowhead headings)
L["Single Target"] = "單目標"
L["Multitarget"] = "多目標"
L["Opener"] = "起手"
L["AoE Opener"] = "AoE起手"
L["Single Target Opener"] = "單目標起手"
L["Easy Mode"] = "簡易模式"
L["Opener / Cooldowns"] = "起手 / 冷卻"
L["Mythic+"] = "傳奇+"
L["DPS Priority"] = "輸出優先順序"
L["Healing Priority"] = "治療優先順序"
-- L["General"] handled by the Settings section below ("一般").

-- Consumable labels
L["Flask"] = "藥劑"
L["Combat Potion"] = "戰鬥藥水"
L["Food"] = "食物"
L["Weapon Buff"] = "武器強化"
L["Augment Rune"] = "增強符文"

-- Gem labels
L["Primary"] = "主寶石"
L["Secondary"] = "副寶石"

-- Craft section headers
L["Early Crafts"] = "前期製作"
L["BiS Crafts"] = "最佳製作"

-- Talent build fallback
L["Build"] = "配置"

-- Empty / fallback states
L["Select a class and specialization above."] = "請在上方選擇職業和專精。"
L["No data available for this spec."] = "此專精暫無資料。"
L["No builds available — check Wowhead for details."] = "暫無可用配置 — 請查看 Wowhead 了解詳情。"
L["No builds for %s — check Wowhead."] = "%s 暫無配置 — 請查看 Wowhead。"
L["No rotation for %s — check Wowhead for details."] = "%s 暫無輸出循環 — 請查看 Wowhead 了解詳情。"
L["No rotation for %s — check Wowhead."] = "%s 暫無輸出循環 — 請查看 Wowhead。"

-- About panel
L["About Class Codex v%s"] = "關於 Class Codex v%s"
L["Stat priorities, talent builds, rotation guides, and gearing recommendations for your current spec.\n\nRecommendations are general guidelines. For precise results, sim your character with Raidbots."] = "為你目前的專精提供屬性優先順序、天賦配置、輸出循環指南與裝備建議。\n\n建議僅供參考。如需精確結果，請使用 Raidbots 模擬你的角色。"
L["Links:"] = "連結："
L["Type /cc help for a list of commands."] = "輸入 /cc help 查看指令清單。"
L["Supporters"] = "支持者"
L["Support on Patreon"] = "在 Patreon 上支持"
L["Class Codex is free and open to everyone. Supporters on Patreon help keep the data fresh and the project moving forward."] = "Class Codex 對所有人免費開放。Patreon 上的支持者幫助我們保持資料更新並推動專案進步。"
L["Be the first to support Class Codex!"] = "成為 Class Codex 的第一位支持者！"
L["Open Settings"] = "開啟設定"
L["Open Compendium"] = "開啟綱要"

-- Tooltip
L["Stat Priority on Tooltips"] = "浮動提示屬性優先級"

-- Settings headers
L["Tooltips"] = "浮動提示"
L["General"] = "通用"
L["Floating Panel"] = "浮動面板"
L["Docked Panel"] = "停靠面板"
L["Panel"] = "面板"

-- Settings: checkbox labels
L["Stat Priority Ranks"] = "屬性優先排名"
L["Wowhead BiS on Tooltips"] = "Wowhead 最佳裝備資訊"
L["Icy Veins BiS on Tooltips"] = "Icy Veins 最佳裝備資訊"
L["BiS Source"] = "最佳裝備來源"
L["Trinket Tier on Tooltips"] = "浮動提示飾品等級"
L["Current Class Only"] = "僅目前職業"
L["Highlight Owned Gear"] = "標記已擁有裝備"
L["Minimap Button"] = "小地圖按鈕"
L["Login Message"] = "登入訊息"
L["Show Stat Priority"] = "顯示屬性優先順序"
L["Show Talents"] = "顯示天賦"
L["Show Rotation"] = "顯示輸出循環"
L["Show Enchants"] = "顯示附魔"
L["Show Gems"] = "顯示寶石"
L["Show Consumables"] = "顯示消耗品"
L["Show Trinkets"] = "顯示飾品"
L["Show Crafts"] = "顯示製造"
L["Show BiS Gear"] = "顯示最佳裝備"

-- Settings: tooltip descriptions
L["Show stat priority rank (#1, #2, #3) next to stat names on item tooltips."] = "在物品浮動提示的屬性名稱旁顯示優先排名（#1、#2、#3）。"
L["Show which specs an item is Best in Slot for (Wowhead) on item tooltips."] = "在物品浮動提示中顯示該物品是哪些專精的最佳裝備 (Wowhead)。"
L["Show which specs an item is Best in Slot for (Icy Veins) on item tooltips."] = "在物品浮動提示中顯示該物品是哪些專精的最佳裝備 (Icy Veins)。"
L["Show trinket tier rankings and the tier badge on item tooltips."] = "在物品浮動提示中顯示飾品等級排名與等級標誌。"
L["Only show BiS and trinket tier info for your current class on tooltips."] = "浮動提示中僅顯示目前職業的最佳裝備與飾品等級資訊。"
L["Tint BiS and Trinket rows with a subtle green background when you already own the item (bags, bank, reagent bank, warbank, or equipped). Applies to both the docked and floating panels."] = "當你已擁有物品（背包、銀行、材料銀行、戰隊銀行或已裝備）時，以淡綠色背景標記最佳裝備與飾品列。同時適用於停靠和浮動面板。"
L["Show a minimap button for quick access. Left-click opens the Compendium, right-click opens Settings."] = "顯示小地圖按鈕以快速存取。左鍵開啟綱要，右鍵開啟設定。"
L["Print the 'Class Codex loaded — type /cc to open' message to chat when you log in or reload."] = "登入或重新載入介面時，在聊天視窗顯示 'Class Codex 已載入 — 輸入 /cc 開啟' 訊息。"
L["Show the Stat Priority section when the panel is floating."] = "浮動面板中顯示屬性優先順序區段。"
L["Show the Talents section when the panel is floating."] = "浮動面板中顯示天賦區段。"
L["Show the Rotation section when the panel is floating."] = "浮動面板中顯示輸出循環區段。"
L["Show the Enchants section when the panel is floating."] = "浮動面板中顯示附魔區段。"
L["Show the Gems section when the panel is floating."] = "浮動面板中顯示寶石區段。"
L["Show the Consumables section when the panel is floating."] = "浮動面板中顯示消耗品區段。"
L["Show the Trinkets section when the panel is floating."] = "浮動面板中顯示飾品區段。"
L["Show the Crafts section when the panel is floating."] = "浮動面板中顯示製造區段。"
L["Show the BiS Gear section when the panel is floating."] = "浮動面板中顯示最佳裝備區段。"
L["Show the Stat Priority section when the panel is docked."] = "停靠面板中顯示屬性優先順序區段。"
L["Show the Talents section when the panel is docked."] = "停靠面板中顯示天賦區段。"
L["Show the Rotation section when the panel is docked."] = "停靠面板中顯示輸出循環區段。"
L["Show the Enchants section when the panel is docked."] = "停靠面板中顯示附魔區段。"
L["Show the Gems section when the panel is docked."] = "停靠面板中顯示寶石區段。"
L["Show the Consumables section when the panel is docked."] = "停靠面板中顯示消耗品區段。"
L["Show the Trinkets section when the panel is docked."] = "停靠面板中顯示飾品區段。"
L["Show the Crafts section when the panel is docked."] = "停靠面板中顯示製造區段。"
L["Show the BiS Gear section when the panel is docked."] = "停靠面板中顯示最佳裝備區段。"

-- Chat messages
L["loaded — type |cff00ccff/cc|r to open"] = "已載入 — 輸入 |cff00ccff/cc|r 開啟"
L["Switched to %s (detected)"] = "已切換至%s（自動偵測）"
L["Docked"] = "已停靠"
L["Floating"] = "浮動"
L["Reset"] = "已重置"
L["Compendium not available."] = "綱要無法使用。"
L["Minimap button shown"] = "小地圖按鈕已顯示"
L["Minimap button hidden"] = "小地圖按鈕已隱藏"
L["Minimap button not available"] = "小地圖按鈕無法使用"
L["Unknown command. Type /cc help"] = "未知指令。輸入 /cc help 查看說明"
L["Settings registration failed: %s"] = "設定註冊失敗：%s"
L["Compendium data not loaded."] = "綱要資料未載入。"

-- Stat Targets / DR (character pane tooltip extras)
L["Stat Targets"] = "屬性目標"
L["Show Stat Targets"] = "顯示屬性目標"
L["Stat Priority Source Line"] = "屬性優先順序來源行"
L["Stat priority"] = "屬性優先順序"
L["Show the Stat Targets section (live bars vs Archon empirical targets) on the Stats tab when the panel is docked."] = "面板停靠時,在屬性分頁顯示屬性目標區段(即時條形圖對比 Archon 實測目標)。"
L["Show the Stat Targets section (live bars vs Archon empirical targets) on the Stats tab when the panel is floating."] = "面板浮動時,在屬性分頁顯示屬性目標區段(即時條形圖對比 Archon 實測目標)。"
L["Stat targets can't be computed in combat — values update after combat ends."] = "戰鬥中無法計算屬性目標 — 戰鬥結束後數值會更新。"
L["alt"] = "替代"
L["alt %d"] = "替代 %d"

-- Tooltip / data source labels
L["Source Display"] = "來源顯示"
L["How to display data sources (Wowhead, Icy Veins) on item tooltips."] = "如何在物品提示中顯示資料來源(Wowhead、Icy Veins)。"
L["When to show a footer line on item tooltips noting which hero / context the displayed ranks come from. 'Only when different' surfaces the line only when the resolved hero diverges from the one you're currently playing — useful as a quiet reminder that a pin or panel selection has drifted from in-game state."] = "何時在物品提示底部顯示來源行,標明所顯示的優先順序來自哪個英雄天賦 / 情境。「僅在不同時」僅當解析的英雄天賦與您目前所玩的不同時顯示。"
L["Always"] = "總是"
L["Off"] = "關閉"
L["Only when different"] = "僅在不同時"
L["Both"] = "兩者"
L["Icons"] = "圖示"
L["Labels"] = "標籤"
L["Wowhead"] = "Wowhead"
L["Archon"] = "Archon"

-- Encounter context labels
L["M+ Dungeons"] = "傳奇鑰石地下城"
L["Raid Bosses (Heroic)"] = "團隊副本首領(英雄)"
L["Raid Bosses (Mythic)"] = "團隊副本首領(神話)"

-- Loadout Dock
L["Loadout Dock"] = "配置塢"
L["Show Loadout Dock"] = "顯示配置塢"
L["Floating widget that shows the active talent loadout name. Click to switch to any saved Blizzard loadout or Class Codex recommendation."] = "顯示目前天賦配置名稱的浮動小工具。點擊以切換至任何已儲存的暴雪配置或 Class Codex 推薦配置。"
L["Click to switch loadouts."] = "點擊以切換配置。"
L["Right-click for options."] = "右鍵以查看選項。"
L["Cannot switch loadouts in combat."] = "戰鬥中無法切換配置。"
L["No loadouts available"] = "無可用配置"
L["No talent builds available."] = "無可用天賦組合。"
L["No Archon builds available."] = "無可用 Archon 組合。"
L["Pick a build"] = "選擇組合"
L["Custom build"] = "自訂組合"
L["Saved Loadouts"] = "已儲存的配置"
L["Show Saved Loadouts in menu"] = "在選單中顯示已儲存的配置"
L["Show Wowhead recommendations in menu"] = "在選單中顯示 Wowhead 推薦"
L["Show Archon recommendations in menu"] = "在選單中顯示 Archon 推薦"
L["Include your Blizzard saved talent loadouts in the dock's click menu."] = "將您已儲存的暴雪天賦配置加入配置塢的點擊選單。"
L["Include the Wowhead-sourced recommended builds in the dock's click menu."] = "將來自 Wowhead 的推薦組合加入配置塢的點擊選單。"
L["Include the Archon per-encounter recommended builds in the dock's click menu."] = "將 Archon 各首領推薦的組合加入配置塢的點擊選單。"
L["Show spec icon"] = "顯示專精圖示"
L["Show your active specialization's icon next to the loadout name."] = "在配置名稱旁顯示目前專精的圖示。"
L["Show hero talent icon"] = "顯示英雄天賦圖示"
L["Show your active hero talent's icon next to the loadout name."] = "在配置名稱旁顯示目前英雄天賦的圖示。"
L["Show border"] = "顯示邊框"
L["Draw a thin border around the loadout dock. Off for a borderless minimal look."] = "在配置塢周圍繪製細邊框。關閉以獲得簡約外觀。"
L["Background opacity"] = "背景不透明度"
L["Translucency of the loadout dock's background plate. 0 = invisible, 100 = solid."] = "配置塢背景板的透明度。0 = 完全透明,100 = 不透明。"
L["Width"] = "寬度"
L["Width of the loadout dock in pixels. Ignored when Auto-fit width is on."] = "配置塢的寬度(像素)。開啟自適應寬度時此設定會被忽略。"
L["Auto-fit width"] = "自適應寬度"
L["Resize the dock automatically to fit the active loadout name. Overrides the Width slider when enabled."] = "自動調整配置塢大小以符合目前配置名稱。開啟時會覆蓋寬度滑桿。"
L["Scale"] = "縮放"
L["Scale of the loadout dock. Grows the font, icons, and height proportionally."] = "配置塢的縮放。字型、圖示和高度按比例放大。"
L["Content alignment"] = "內容對齊"
L["Where the dock's icons + label sit when the dock is wider than the content."] = "當配置塢寬於內容時,圖示和標籤的位置。"
L["Center"] = "中央"
L["Left"] = "靠左"
L["Right"] = "靠右"
L["Hide in combat"] = "戰鬥中隱藏"
L["Hide the loadout dock entirely during combat. Talent swaps fail in combat anyway, so this just removes the visual noise."] = "戰鬥中完全隱藏配置塢。反正戰鬥中無法切換天賦,這只是移除視覺干擾。"
L["Lock dock position"] = "鎖定配置塢位置"
L["Prevent the loadout dock from being dragged. Toggle off to reposition, then re-enable to keep it from moving accidentally."] = "防止配置塢被拖動。關閉以重新定位,完成後重新開啟以避免意外移動。"
L["Lock position"] = "鎖定位置"
L["Unlock position"] = "解除鎖定位置"
L["Position locked - unlock in Settings"] = "位置已鎖定 - 在設定中解除鎖定"

-- PvP
L["PvP"] = "PvP"
L["Arena"] = "競技場"
L["Battleground"] = "戰場"
L["Honor Talents"] = "榮譽天賦"
L["Honor talents apply in War Mode or PvP instances."] = "榮譽天賦於戰爭模式或 PvP 副本中生效。"
L["No PvP builds available."] = "目前沒有 PvP 配置。"
L["No PvP gear data for this spec yet."] = "目前沒有此專精的 PvP 裝備資料。"
L["No PvP enchants for this spec yet."] = "目前沒有此專精的 PvP 附魔資料。"
L["No PvP enchant/gem data for this spec yet."] = "目前沒有此專精的 PvP 附魔/寶石資料。"
L["No PvP stat priority for this spec yet."] = "目前沒有此專精的 PvP 屬性優先順序。"
L["No PvP stat targets for this spec yet."] = "目前沒有此專精的 PvP 屬性目標。"

-- Talent Pane / Character Pane Button
L["Talent Pane"] = "天賦面板"
L["Show Class Codex on talent frame"] = "在天賦視窗顯示 Class Codex"
L["Show the Class Codex build picker on the Blizzard talent frame. Disable to hide it entirely."] = "在暴雪天賦視窗顯示 Class Codex 組合選擇器。關閉以完全隱藏。"
L["Character Pane Button"] = "角色面板按鈕"
L["Click to toggle panel"] = "點擊以切換面板"
L["Lock Button Position"] = "鎖定按鈕位置"
L["Prevent the gear button from being moved by Shift-drag on the character pane."] = "防止角色面板上的裝備按鈕被 Shift-拖動移動。"
L["Shift-drag to move - Shift+Right-click to reset"] = "Shift-拖動以移動 - Shift+右鍵以重置"
L["Horizontal Offset"] = "水平偏移"
L["Horizontal offset (pixels) from the character pane top-right corner."] = "相對於角色面板右上角的水平偏移(像素)。"
L["Vertical Offset"] = "垂直偏移"
L["Vertical offset (pixels) from the character pane top-right corner."] = "相對於角色面板右上角的垂直偏移(像素)。"

-- Footer
L["Today"] = "今天"
L["Yesterday"] = "昨天"
L["%d days ago"] = "%d 天前"
L["Last refreshed: %s"] = "上次更新：%s"
L["Data refreshes daily. Update Class Codex to get the latest."] = "資料每日更新。請更新 Class Codex 以取得最新內容。"

-- 自行加入
L["Class Codex"] = "職業寶典"
L["Left-click to open Compendium"] = "左鍵：開啟寶典"
L["Right-click to open Settings"] = "右鍵：設定選項"
L["Dock to Character Frame"] = "固定至角色框架"
L["Float (detach)"] = "浮動（分離）"
L["Right-click to configure sections"] = "右鍵點擊以設定區塊"

end -- locale
