if GetLocale() ~= "zhCN" then return end

local L = select(2, ...).L

TAG_CLASS = ((U1PlayerClass=="DEATHKNIGHT" and "死骑") or (U1PlayerClass=="DEMONHUNTER" and "猎魔") or UnitClass("player")) .. "专用"
TAG_NOTAGS = "未分类"
TAG_ALL = "全部插件"

TAG_SOCIAL = "聊天社交"
TAG_AUCTION = "拍卖经营"
TAG_PVP = "PvP相关"
TAG_COMBAT = "战斗信息"
TAG_ENHANCEMENT = "界面增强"
TAG_ITEM = "物品装备"
TAG_MAP = "地图信息"
TAG_QUEST = "任务升级"
TAG_BOSSRAID = "副本团队"
TAG_PROFESSION = "专业技能"
TAG_UNITFRAME = "头像框架"
TAG_ACTIONBAR = "动作条"
TAG_CLASSALL = "职业相关"
TAG_COLLECTION = "成就收藏"
TAG_MISC = "五花八门"

U1REASON_INCOMPATIBLE = "不兼容"
U1REASON_DISABLED = "未启用"
U1REASON_INTERFACE_VERSION = "版本过期"
U1REASON_DEP_DISABLED = "依赖插件未启用"
U1REASON_DEP_CORRUPT = "依赖插件无法加载"
U1REASON_SHORT_DEP_CORRUPT = "依赖失败"
U1REASON_SHORT_DEP_DISABLED = "依赖未启用"
U1REASON_DEP_INTERFACE_VERSION = "依赖插件版本过期"
U1REASON_SHORT_DEP_INTERFACE_VERSION = "依赖过期"
U1REASON_DEP_MISSING = "依赖插件未安装"
U1REASON_SHORT_DEP_MISSING = "依赖未安装"
U1REASON_DEP_NOT_DEMAND_LOADED = "依赖插件无法按需加载"
U1REASON_SHORT_DEP_NOT_DEMAND_LOADED = "依赖非按需"

--- ===========================================================
-- 163UI.lua
--- ===========================================================
L["|cff1acd1c[EAC]|r- "] = "|cff1acd1c【网易有爱】|r- "
L["%|cff880303%[EAC%]%|r "] = "%|cff880303%[网易有爱%]%|r "
L["Load Now"] = "强制加载"
L["desc.Load Now"] = "说明`本插件会在满足条件时自动加载，如果现在就要加载请点击此按钮` `|cffff0000注意：有可能会出错|r"
L["Options"] = "设置选项"

L["Reload to completely disable %s."] = "停用%s需要重载界面"
L["AddOn |cffffd100%s|r"] = "插件-|cffffd100%s|r-"
L["%s loaded"] = "%s加载成功"
L["%s load failed, reason: "] = "%s加载失败, 原因："
L["unknown"] = "未知"
L["%s is current paused, the memory will not release until reload ui."] = "%s已暂停，彻底关闭需要重载界面。"
L["%s is no longer disabled."] = "%s不再停用"
L["%s is enabled, and will load on demand."] = "%s已启用, 需要时会自动加载"
L["%%s load failed, error loading dependency [%s]"] = "%%s加载失败，依赖插件[%s]无法加载"

--- ===========================================================
-- 163UIUI_V3.lua
--- ===========================================================
--- Quick Menu
L["AddOn: "] = "插件："
L["Quick Enable/Disable AddOn"] = "快速启用/停用插件"
L["Scale"] = "缩放"

--- AddOn Status on Tooltip
L["Loaded, reload to disable"] = "已加载,重启后停用"
L["|cff00D100Loaded|r"] = "|cff00D100已加载|r"
L["|cff00D100Missing|r"] = "|cffff0000未安装|r"
L["|cff00D100Disabled|r"] = "|cffA0A0A0未启用|r"
L["Enabled"] = "已启用"
L["Enabled, reloadui to load"] = "已启用,需重新加载"
L["|cffA0A0A0Deps Disabled|r"] = "|cffA0A0A0依赖插件未启用|r"
L["|cffff7f7fLoad Failed|r"] = "|cffff7f7f启用失败|r"
L["Module"] = "模块"
L["Version"] = "版本"

--- AddOn Tooltip
L["Loading addons while in combat is not recommended.\n"] = "不建议在战斗中加载插件。\n"
L["Author"] = "作者"
L["Credits"] = "修改"
L["Folder"] = "目录"
L["Total"] = "全部"
L["Memory"] = "内存"
L["Status"] = "状态"
L["|cff00D100LoD|r"] = "|cff00D100按需载入|r"
L["Reason"] = "原因"
L["Depends"] = "依赖"
L["Individual AddOn"] = "单体插件"
L["Package AddOn"] = "网易有爱整合版"

--- Tags panel and Tags tooltip
L["No Loaded Addons"] = "没有已加载的插件"
L["  All AddOns  "] = "　有爱整合　"

--- Top Panel
L["EAC Options"] = "有爱设置"
L["OP"] = "设置"
L["ReloadUI"] = "重载界面"
L["RL"] = "重载"
L["MemoryGC"] = "回收内存"
L["GC"] = "内存"
L["Profiles"] = "方案管理"
L["PF"] = "方案"
L["Memory Garbage Collect"] = "回收内存"
L["desc.GC"] = "强制回收空闲的内存, 除了确定插件内存的稳定值外, 并没有太大用处."
L["Save addons status and control panel settings, and share the profile among characters."] = "将已启用的插件列表等保存为方案，例如任务模式、副本模式等，亦可以在多个角色之间共用。"
L["Show Ease Addon Controller's option page. Click again to return to the previous selected addon."] = "直接显示网易有爱控制台的介绍和配置项，再次点击则返回之前选中的插件"
L["Quick Menu"] = "快捷设置"
L["Show frequently used toggle options, in a dropdown menu."] = "一些常用的选项，以下拉菜单方式列出，可迅速进行设置。"
L["Please DOUBLE click to confirm"] = "请双击按钮（防止误操作）"
L["Operations require reloading: "] = "以下操作需要重载界面："
L["|cffff0000Disable|r - "] = "|cffff0000停用|r - "
L["Modified - "] = "配置改动 - "

--- Central Panel
L["Load All"] = "全部加载"
L["short.LoadAll"] = "全开"
L["Load all addons in the above list"] = "加载当前显示的所有插件"
L["The game may freeze for a little while."] = "注意：加载时可能会稍微卡顿，请安心等待。"
L["Disable All"] = "全部停用"
L["short.DisableAll"] = "全关"
L["Disable all addons in the above list"] = "停用当前显示的所有插件"
L["UI reloading is required to really disable addons."] = "停用后请手动重载界面"
L["Hint"] = "说明"
L["Show or hide the loaded addons in the above list"] = "显示当前分类下已启用的插件"
L["Disabled"] = "未启用"
L["Show or hide the disabled addons in the above list"] = "显示当前分类下未启用的插件"
L["|cff00ff00 %d|r Enabled"] = "已启用|cff00ff00 %d|r"
L["|cffAAAAAA %d|r Disabled"] = "未启用|cffAAAAAA %d|r"
L["All of selected addons are loaded."] = "全部插件加载完毕."

--- Right panel
L["AddOn Options"] = "插件选项"
L["AddOn Notes"] = "插件介绍"
L["AddOn Introduction"] = "插件说明"
L["Category: "] = "插件分类："
L["AddOns Installed: "] = "已安装插件数："

--- Events Scripts Creating Frames
L["Search AddOns"] = "搜索插件及选项"
L["desc.SEARCH1"] = "输入汉字或英文进行检索，只有一个结果时可按回车选定。"
L["desc.SEARCH2"] = "可以搜索插件名、目录名、选项中的文本，所有含有搜索文本的插件都会被显示出来，匹配的文本会被高亮显示。"
L["desc.SEARCH3"] = false
L["help.SEARCH"] = "这里可以输入汉字或者英文进行搜索，例如'|cffffd200对比|r'或者'|cffffd200Grid|r'。不但能查询插件名称，还能查询插件的选项！"

--- GameMenu Button and Minimap Button
L["Ease AddOn"] = "网易有爱"
L["Ease Addon Controller"] = "网易有爱"
L["Open Ease Addon Controller's main panel"] = "显示网易有爱插件控制台主界面"
L["An advanced in-game addon control center, which combines Categoring, Searching, Loading and Setting of wow addons all together."] = "    网易有爱（163UI）是网易游戏频道隆重推出的新一代整合插件。其设计理念是兼顾整合插件的易用性和单体插件的灵活性，同时适合普通和高级用户群体。|n|n    功能上，网易有爱实现了任意插件的随需加载，并可先进入游戏再逐一加载插件，此为全球首创。此外还有标签分类、拼音检索、界面缩排等特色功能。"
L["Right click to open quick menu."] = "鼠标右键点击可打开快捷设置"

--- Controls
L["Requires an UI reload"] = "需要重新加载界面"
L["Please input a number between |cffffd200%s|r and |cffffd200%s|r"] = "请输入 |cffffd200%s|r ~ |cffffd200%s|r 之间的数字"

--- CfgEAC.lua
L["CFG.desc"] = "插件控制台是网易有爱整合插件的核心组件，您目前使用的是控制台的单体版，它可以和Curse的插件更新器强强联手，为您提供插件分类/检索/即时加载等功能。如果你难以忍受更新Curse的网络难题，可以尝试一下网易有爱整合插件，其理念就是单体插件+大师调优，满足多种用户的需求。网址 http://wowui.w.163.com/163ui"
L["CFG.author"] = "|cffcd1a1c[网易原创]|r"
L["Ease Addon Controller Options"] = "网易有爱控制台选项"
L["Show Minimap Button"] = "显示小地图按钮"
L["Main Panel Scale"] = "控制台缩放比例"
L["Main Panel Opacity"] = "控制台透明度"
L["Show AddOns Folder Name"] = "显示插件英文名"
L["Hint`Show addon folder name instead of the Title in the toc file."] = "说明`选中显示插件目录的名字，适合中高级用户快速选择所需插件。"
L["Sort AddOns by Memory Usage"] = "按插件所用内存排序"
L["Hint`Sort the addons by their memory usages instead of name order."] = "说明`选中则按插件(包括子模块)所占内存大小进行排序，否则按插件名称排序。"
L["Panel Tile Settings"] = "插件列表按钮设置"
L["Are you sure to reset these settings, and start an UI reload?"] = "即将重置这些选项并重载界面，是否确定？"
L["AddOn Tile Width"] = "插件按钮宽度"
L["AddOn Tile Height"] = "插件按钮高度"
L["AddOn Tile Margin"] = "插件按钮间隔"

--- ===========================================================
-- Profiles.lua ProfilesUI.lua
--- ===========================================================
L["Before Load Profile"] = "加载之前"
L["Before Logout"] = "登出之前"
L["Before Restore"] = "重置之前"
L["After Login"] = "登入之后"

L["Current addon enable states will be lost, are you SURE?"] = "当前的插件控制台的设置将丢弃，您确定吗？"
L["Are you sure to delete this profile?"] = "您确定要删除此方案吗？"
L["Ease Addon Controller Profiles"] = "网易有爱插件配置方案"
L["Saved"] = "方案列表"
L["Auto"] = "自动保存"
L["EAC will automatically save profiles before logout, after login, or loading another profile."] = "角色登出、加载方案之前，会自动保存当前设置"
L["Create Profile"] = "新建方案"
L["Restore Default"] = "恢复默认"
L["Profile: "] = "方案: "
L["AddOns: "] = "插件数: "
L["Today"] = "今天"
L["AddOn States"] = "插件状态"
L["AddOn Options"] = "插件配置"
L["In addition of saving addon enable/disable states, also save the options shown in the EAC panel."] = "选中此项则会保存/加载有爱插件控制台里的所有设置项"
L["Rename"] = "改名"
L["Unnamed"] = "未命名"
L["Load"] = "加载"
L["Delete"] = "删除"
L["Save"] = "保存"
L["New profile name: "] = "新建方案名称："
L["Change profile name: "] = "修改方案名称："
