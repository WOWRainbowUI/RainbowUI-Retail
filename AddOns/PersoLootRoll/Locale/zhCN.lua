local Name, Addon = ...
local Locale = Addon.Locale
local lang = "zhCN"

-- Chat messages
local L = {lang = lang}
setmetatable(L, Locale.MT)
Locale[lang] = L

-- Messages
L["MSG_BID_1"] = "请问你要 %s 吗？"
L["MSG_BID_2"] = "如果你不要 %s，可以给我吗？"
L["MSG_BID_3"] = "如果你不要 %s 的话我也可以用。"
L["MSG_BID_4"] = "如果 %s 对你没用的话，可以给我。"
L["MSG_BID_5"] = "请问 %s 可以给我吗？"
L["MSG_HER"] = "她"
L["MSG_HIM"] = "他"
L["MSG_ITEM"] = "物品"
L["MSG_NEED"] = "要,是,求"
L["MSG_PASS"] = "不"
L["MSG_ROLL"] = "roll,要"
L["MSG_ROLL_ANSWER_AMBIGUOUS"] = "我正要送出多件物品，请将想要的物品链接发给我。"
L["MSG_ROLL_ANSWER_BID"] = "好的，我已经记下了你对 %s 的出价。"
L["MSG_ROLL_ANSWER_NO"] = "抱歉，你无法再对该物品出价。"
L["MSG_ROLL_ANSWER_NO_OTHER"] = "抱歉，我已经给别人了。"
L["MSG_ROLL_ANSWER_NO_SELF"] = "抱歉，我也有需求。"
L["MSG_ROLL_ANSWER_NOT_ELIGIBLE"] = "抱歉，你没有获得该物品的条件。"
L["MSG_ROLL_ANSWER_NOT_TRADABLE"] = "抱歉，这件物品无法交易。"
L["MSG_ROLL_ANSWER_STARTED"] = "好的，我会开启这件物品的竞拍。"
L["MSG_ROLL_ANSWER_YES"] = "可以给你，来跟我交易。"
L["MSG_ROLL_ANSWER_YES_MASTERLOOT"] = "可以给你，请与 <%s> 交易。"
L["MSG_ROLL_DISENCHANT"] = "<%s> 将分解 %s -> 与我交易！"
L["MSG_ROLL_DISENCHANT_MASTERLOOT"] = " <%s> 将分解 %s，由 <%s> 拾取 -> 与他交易！"
L["MSG_ROLL_DISENCHANT_MASTERLOOT_OWN"] = "<%s> 会分解他拾取的 %s！"
L["MSG_ROLL_DISENCHANT_WHISPER"] = "你被指定来分解 %s，请与我交易。"
L["MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT"] = "你被指定来分解 %s，由 <%s> 拾取，请与他交易。"
L["MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_OWN"] = "你被指定来分解由拾取的 %s！"
L["MSG_ROLL_START"] = "开始分配 %s -> 要的密我，或 /roll %d！"
L["MSG_ROLL_START_CONCISE"] = "%s 有人要吗？"
L["MSG_ROLL_START_MASTERLOOT"] = "开始分配 %s，由 <%s> 拾取 -> 要的密我，或 /roll %d！"
L["MSG_ROLL_WINNER"] = "<%s> 已贏得 %s -> 来跟我交易！"
L["MSG_ROLL_WINNER_CONCISE"] = "%s 跟我交易！"
L["MSG_ROLL_WINNER_MASTERLOOT"] = "<%s> 已赢得 %s，由 <%s> 拾取 -> 请与他交易！"
L["MSG_ROLL_WINNER_MASTERLOOT_OWN"] = "<%s> 赢得了由他自己拾取的 %s！"
L["MSG_ROLL_WINNER_WHISPER"] = "你已贏得 %s！来跟我交易。"
L["MSG_ROLL_WINNER_WHISPER_CONCISE"] = "来跟我交易。"
L["MSG_ROLL_WINNER_WHISPER_MASTERLOOT"] = "你已赢得 %s，由 <%s> 拾取！请与他交易。"
L["MSG_ROLL_WINNER_WHISPER_MASTERLOOT_OWN"] = "你赢得了自己拾取的 %s！"


-- Addon
local L = LibStub("AceLocale-3.0"):NewLocale(Name, lang, lang == Locale.FALLBACK)
if not L then return end

L["ACTION"] = "操作"
L["ACTIONS"] = "操作"
L["ADVERTISE"] = "在聊天频道发布通知"
L["ANSWER"] = "回复"
L["ASK"] = "请求"
L["AWARD"] = "分配"
L["AWARD_LOOT"] = "分配战利品"
L["AWARD_RANDOMLY"] = "随机分配战利品"
L["BID"] = "出价"
L["COMMUNITY_GROUP"] = "社区队伍"
L["COMMUNITY_MEMBER"] = "社区成员"
L["CONFIRM"] = "确认"
L["DISABLED"] = "禁用"
L["DOWN"] = "下"
L["ENABLED"] = "启用"
L["EQUIPPED"] = "已装备物品"
L["GET_FROM"] = "来自"
L["GIVE_AWAY"] = "赠送"
L["GIVE_TO"] = "送给"
L["GUILD_MASTER"] = "公会会长"
L["GUILD_OFFICER"] = "公会官员"
L["HIDE"] = "隐藏"
L["HIDE_ALL"] = "全部隐藏"
L["ITEM"] = "物品"
L["ITEM_LEVEL"] = "物品等级"
L["KEEP"] = "保留"
L["LEFT"] = "左"
L["MASTERLOOTER"] = "战利品分配者"
L["MESSAGE"] = "消息"
L["ML"] = "分配者"
L["OPEN_ROLLS"] = "开启竞拍窗口"
L["OWNER"] = "拾取者"
L["PLAYER"] = "玩家"
L["PRIVATE"] = "不公开"
L["PUBLIC"] = "公开"
L["RAID_ASSISTANT"] = "团队助理"
L["RAID_LEADER"] = "团队领袖"
L["RESTART"] = "重新开始"
L["RIGHT"] = "右"
L["RINGS"] = "戒指"
L["ROLL"] = "点数"
L["ROLLS"] = "竞拍列表"
L["SECONDS"] = "%d秒"
L["SET_ANCHOR"] = "设置锚点：向 %s 及 %s 增长"
L["SHOW"] = "显示"
L["SHOW_ALL"] = "全部显示"
L["SHOW_HIDE"] = "显示/隐藏"
L["TRADE"] = "交易"
L["TRINKETS"] = "饰品"
L["UP"] = "上"
L["VERSION_NOTICE"] = "有新版本插件可用，请更新插件以保证跟其他人的兼容性，才不会错过任何战利品！"
L["VOTE"] = "投票"
L["VOTE_WITHDRAW"] = "撤回"
L["VOTES"] = "投票结果"
L["WAIT"] = "等待"
L["WINNER"] = "获胜者"
L["WON"] = "获胜"
L["YOUR_BID"] = "您的出价"

-- Commands
L["HELP"] = [=[开始战利品的竞拍或对他们出价（/PersoLootRoll 或 /plr）。
用法：
/plr: 开启竞拍窗口
/plr help: 列出帮助信息
/plr roll [物品]* (<拾取者> <超时>): 开始一个或多个物品的竞拍
/plr bid [物品] (<拾取者> <出价>): 出价竞拍其他玩家拾取的物品
/plr trade (<玩家>): 交易给指定玩家或当前目标
/plr test: 开始一个测试竞拍（只有您自己能看见）
/plr options: 开启选项界面
/plr config: 通过命令行更改设置
/plr debug: 切换调试模式

说明: [..] = 物品连接, * = 一个或多个物品, (..) = 可选的]=]
L["USAGE_BID"] = "使用：/plr bid [物品] (<拾取者> <出价>)"
L["USAGE_ROLL"] = "使用：/plr roll [物品]* (<拾取者> <超时>)"

-- Errors
L["ERROR_CMD_UNKNOWN"] = "未知命令“%s”"
L["ERROR_COLLECTION_FILTERS_DISABLED"] = "所有战利品过滤器均已禁用，如果您想竞拍缺少的物品，请确保启用了相应的过滤器。"
L["ERROR_ITEM_NOT_TRADABLE"] = "您无法交易该物品。"
L["ERROR_NOT_IN_GROUP"] = "您不在小队或团队中。"
L["ERROR_NOT_MASTERLOOTER_OTHER_OWNER"] = "您需要成为战利品分配者才能为其他玩家拾取的物品创建竞拍。"
L["ERROR_NOT_MASTERLOOTER_TIMEOUT"] = "当您不是战利品分配者时，您无法改变竞拍超时时间。"
L["ERROR_OPT_MASTERLOOT_EXPORT_FAILED"] = "导出战利品分配者设置到 <%s> 失败！"
L["ERROR_PLAYER_NOT_FOUND"] = "无法找到玩家 %q。"
L["ERROR_ROLL_BID_IMPOSSIBLE_OTHER"] = "%s 已发送了对 %s 的出价，但现在不允许这样做。"
L["ERROR_ROLL_BID_IMPOSSIBLE_SELF"] = "您现在对该物品出价 。"
L["ERROR_ROLL_BID_UNKNOWN_OTHER"] = "%s 发送了对 %s 的无效出价。"
L["ERROR_ROLL_BID_UNKNOWN_SELF"] = "无效的出价。"
L["ERROR_ROLL_STATUS_NOT_0"] = "此竞拍已经开始或结束。"
L["ERROR_ROLL_STATUS_NOT_1"] = "未进行此竞拍。"
L["ERROR_ROLL_UNKNOWN"] = "此竞拍不存在。"
L["ERROR_ROLL_VOTE_IMPOSSIBLE_OTHER"] = "%s 已经发送了 %s 的投票，但现在不允许这样做。"
L["ERROR_ROLL_VOTE_IMPOSSIBLE_SELF"] = "您现在无法对该物品进行投票。"

-- GUI
L["DIALOG_MASTERLOOT_ASK"] = "<%s> 想成为您的战利品分配者。"
L["DIALOG_OPT_MASTERLOOT_LOAD"] = "将使用公会/社区信息中储存的设置替换您当前的战利品分配设置，您确定要继续吗？"
L["DIALOG_OPT_MASTERLOOT_SAVE"] = "将使用您当前的战利品分配设置替换公会/社区信息中储存的设置，您确定要继续吗？"
L["DIALOG_ROLL_CANCEL"] = "您想要取消竞拍吗？"
L["DIALOG_ROLL_RESTART"] = "您想要重新开始竞拍吗？"
L["DIALOG_ROLL_WHISPER_ASK"] = "如果想通过自动密语功能向其他玩家请求战利品，您可以在“消息”选项中设置密语内容。"
L["FILTER"] = "过滤器"
L["FILTER_ALL"] = "所有玩家"
L["FILTER_ALL_DESC"] = "包括所有玩家的竞拍，并非只有您拾取的物品或您感兴趣的物品。"
L["FILTER_AWARDED"] = "已赢得"
L["FILTER_AWARDED_DESC"] = "包括其他人赢得的竞拍。"
L["FILTER_DONE"] = "已结束"
L["FILTER_DONE_DESC"] = "包括已经结束的竞拍。"
L["FILTER_HIDDEN"] = "已隐藏"
L["FILTER_HIDDEN_DESC"] = "包括已取消、处理中、已放弃和已隐藏的竞拍。"
L["FILTER_TRADED"] = "已交易"
L["FILTER_TRADED_DESC"] = "包括物品已被交易的竞拍。"
L["MENU_MASTERLOOT_SEARCH"] = "搜索队伍中的战利品分配者"
L["MENU_MASTERLOOT_SETTINGS"] = "战利品分配者设置"
L["MENU_MASTERLOOT_START"] = "成为战利品分配者"
L["TIP_ADDON_MISSING"] = "缺少插件："
L["TIP_ADDON_VERSIONS"] = "插件版本："
L["TIP_CHAT_TO_TRADE"] = "请在交易前先询问拾取者"
L["TIP_COMP_ADDON_USERS"] = "使用兼容插件的用户："
L["TIP_ENABLE_WHISPER_ASK"] = "提示：右键点击启用战利品可以自动询问"
L["TIP_MASTERLOOT"] = "队长分配已启用"
L["TIP_MASTERLOOT_INFO"] = [=[|cffffff78战利品分配者:|r %s
|cffffff78竞拍时间:|r %d秒（每件物品 + %d秒）
|cffffff78委员会:|r %s
|cffffff78竞拍结果:|r %s
|cffffff78投票结果:|r %s]=]
L["TIP_MASTERLOOT_START"] = "成为或寻找战利品分配者"
L["TIP_MASTERLOOT_STOP"] = "移除战利品分配者"
L["TIP_MASTERLOOTING"] = "队伍内的战利品分配者（%d）："
L["TIP_MINIMAP_ICON"] = [=[|cffffff00左鍵点击:|r 切换战利品分配界面
|cffffff00右键点击:|r 打开设置界面]=]
L["TIP_SUPPRESS_CHAT"] = "|cffffff78提示:|r 您可以通过按住 Shift 键单击“出价/放弃”来隐藏相应的聊天信息。"
L["TIP_TEST"] = "测试战利品分配"
L["TIP_VOTES"] = "投票来自："

-- Options-Home
L["OPT_ACTIONS_WINDOW"] = "显示操作窗口"
L["OPT_ACTIONS_WINDOW_DESC"] = "当有待处理的操作时显示操作窗口，例如：当你赢得了一件物品但还需要交易某人才能得到它时。"
L["OPT_ACTIONS_WINDOW_MOVE"] = "移动"
L["OPT_ACTIONS_WINDOW_MOVE_DESC"] = "移动操作窗口。"
L["OPT_ACTIVE_GROUPS"] = "根据队伍类型激活"
L["OPT_ACTIVE_GROUPS_DESC"] = [=[仅当您在下列类型中的队伍里时才激活：

|cffffff78公会队伍:|r 队伍里 %d%% 及以上的成员来自于同一公会。
|cffffff78社区队伍:|r 队伍里 %d%% 及以上的成员来自于同一社区。]=]
L["OPT_ALLOW_DISENCHANT"] = "允许“分解”出价"
L["OPT_ALLOW_DISENCHANT_DESC"] = "允许其他人对你拾取的物品选择“分解”。"
L["OPT_AUTHOR"] = "|cffffff00作者:|r Shrugal (EU-Mal'Ganis)"
L["OPT_AWARD_SELF"] = "自行选择由您自己拾取的物品的获胜者"
L["OPT_AWARD_SELF_DESC"] = "自行选择谁可以得到您拾取的战利品，而非让插件随机选择。当您是战利品分配者时，始终启用此功能。"
L["OPT_BID_PUBLIC"] = "公开出价"
L["OPT_BID_PUBLIC_DESC"] = "你的出价是公开的，所有使用此插件的人都可以看见 。"
L["OPT_CHILL_MODE"] = "冷漠模式 "
L["OPT_CHILL_MODE_DESC"] = [=[“冷漠模式”的目的是为了消除分享战利品的压力，即使这意味着将花费更长时间。如果您启用了“冷漠模式”，那么将会发生以下改变：

|cffffff781.|r 只有当您决定要分享您拾取的战利品时，对它们的竞拍才会开始，所以您有足够的时间来做出选择，其他使用此插件的用户在您做出决定之前，也不会看到它们。
|cffffff782.|r 当竞拍您拾取的战利品时，竞拍时间是原来的两倍。如果您决定自行选择竞拍的获胜者（参见下一个选项），那么竞拍将没有时间限制。
|cffffff783.|r 对于队伍里未使用此插件的用户，对其拾取的战利品的竞拍也将保持开启，直到您决定是否需要它们。

|cffff0000重要:|r 对于队伍里其他使用此插件的、但未启用“冷漠模式”的用户，对其拾取的战利品的竞拍时间与原来一致。所以如果您希望“冷漠模式”可以正确运行，请确保队伍里其他使用此插件的用户也开启了“冷漠模式”。]=]
L["OPT_COLLECTIONS"] = "无论其他规则如何，始终显示这些集合中缺少的可收集物品。"
L["OPT_DISENCHANT"] = "分解 "
L["OPT_DISENCHANT_DESC"] = "如果你已学习“附魔”专业且物品拾取者允许，则可对你无法使用的物品选择“分解”。"
L["OPT_DONT_SHARE"] = "不分享战利品"
L["OPT_DONT_SHARE_DESC"] = "不竞拍其他人拾取的战利品也不分享您自己拾取的，插件将会拒绝对您拾取的战利品的请求（如果启用的话），但您仍可成为战利品分配者和战利品委员会成员。"
L["OPT_ENABLE"] = "启用"
L["OPT_ENABLE_DESC"] = "启用或禁用此插件"
L["OPT_ENABLE_MODULE_DESC"] = "启用或禁用此模块 "
L["OPT_ILVL_THRESHOLD"] = "物品等级阈值"
L["OPT_ILVL_THRESHOLD_DESC"] = [=[基于您已装备或背包中同部位物品的物品等级来忽略物品。

|cffffff78负数:|r 物品等级可以比已拥有物品低多少。
|cffffff78正数:|r 物品等级必须比已拥有物品高多少。]=]
L["OPT_ILVL_THRESHOLD_DOUBLE"] = "双倍阈值"
L["OPT_ILVL_THRESHOLD_DOUBLE_DESC"] = "由于触发效果等因素使得一些物品的价值差异很大，所以对于这些物品，其物品等级的阈值应该是正常情况下的两倍。"
L["OPT_ILVL_THRESHOLD_RINGS"] = "戒指双倍阈值"
L["OPT_ILVL_THRESHOLD_RINGS_DESC"] = "戒指由于缺少主属性使得它们的价值差异很大，所以其物品等级的阈值应该是正常情况下的两倍。"
L["OPT_ILVL_THRESHOLD_TRINKETS"] = "饰品双倍阈值"
L["OPT_ILVL_THRESHOLD_TRINKETS_DESC"] = "饰品的触发效果使得不同饰品的价值差异很大，所以其物品等级的阈值应该是正常情况下的两倍。"
L["OPT_INFO"] = "信息"
L["OPT_INFO_DESC"] = "关于此插件的一些信息。"
L["OPT_ITEM_FILTER"] = "物品过滤"
L["OPT_ITEM_FILTER_DESC"] = "更改您想要竞拍的物品。"
L["OPT_ITEM_FILTER_ENABLE"] = "启用附加规则"
L["OPT_ITEM_FILTER_ENABLE_DESC"] = "您无法使用或发送到小号的物品将始终被过滤掉。 在下面，您可以设置物品必须满足的附加条件，符合条件的物品将会按顺序显示给您。"
L["OPT_LVL_THRESHOLD"] = "角色等级阈值"
L["OPT_LVL_THRESHOLD_DESC"] = "忽略要求角色等级高于当前角色等级多少的物品， 设为 -1 可禁用此过滤器。"
L["OPT_MINIMAP_ICON"] = "显示小地图图标"
L["OPT_MINIMAP_ICON_DESC"] = "显示或隐藏小地图图标"
L["OPT_MISSING_PETS"] = "缺少的宠物"
L["OPT_MISSING_TRANSMOG"] = "缺少的幻化外观"
L["OPT_MISSING_TRANSMOG_ITEM"] = "检查幻化物品"
L["OPT_MISSING_TRANSMOG_ITEM_DESC"] = "检查您是否收集了特定物品，而不仅仅是此物品的外观。"
L["OPT_ONLY_MASTERLOOT"] = "仅队长分配"
L["OPT_ONLY_MASTERLOOT_DESC"] = "仅当队长分配时才激活此插件（例如跟您的公会一起）"
L["OPT_PAWN"] = "校验“Pawn”"
L["OPT_PAWN_DESC"] = "仅竞拍“Pawn”插件认为有提升的物品。"
L["OPT_ROLL_FRAMES"] = "显示竞拍框架"
L["OPT_ROLL_FRAMES_DESC"] = "当有人拾取了您可能感兴趣的战利品时显示竞拍框架，这样您就可以参与竞拍了。"
L["OPT_ROLLS_WINDOW"] = "显示竞拍窗口"
L["OPT_ROLLS_WINDOW_DESC"] = "当有人拾取了您可能感兴趣的战利品时，总是显示竞拍窗口（所有竞拍都在上面）。当您是战利品分配者时，此功能始终启用。"
L["OPT_SPECS"] = "专精"
L["OPT_SPECS_DESC"] = "仅为这些职业专精建议战利品。"
L["OPT_TRANSLATION"] = "|cffffd100翻译:|r Jat#5355 (CN)"
L["OPT_TRANSMOG"] = "检查幻化外观"
L["OPT_TRANSMOG_DESC"] = "竞拍您还未拥有该外观的物品。"
L["OPT_UI"] = "用户界面"
L["OPT_UI_DESC"] = "根据自己的喜好设置%s的外观。"
L["OPT_VERSION"] = "|cffffd100版本:|r %s"

-- Options-Masterloot
L["OPT_MASTERLOOT"] = "战利品分配者"
L["OPT_MASTERLOOT_APPROVAL"] = "批准"
L["OPT_MASTERLOOT_APPROVAL_ACCEPT"] = "自动接受战利品分配者"
L["OPT_MASTERLOOT_APPROVAL_ACCEPT_DESC"] = "自动接受这些玩家想成为战利品分配者的请求。"
L["OPT_MASTERLOOT_APPROVAL_ALLOW"] = "允许成为战利品分配者"
L["OPT_MASTERLOOT_APPROVAL_ALLOW_ALL"] = "允许所有人"
L["OPT_MASTERLOOT_APPROVAL_ALLOW_ALL_DESC"] = "|cffff0000警告:|r 这会允许每个人都能成为您的战利品分配者，并可能骗取您的战利品！只有您自己明确知道自己在做什么的情况下才应该启用它。"
L["OPT_MASTERLOOT_APPROVAL_ALLOW_DESC"] = [=[选择谁可以请求成为您的的战利品分配者，当有人发送请求时，您会收到一条确认信息，您可以选择是否同意。

|cffffff00公会队伍:|r 队伍中 %d%% 及以上的成员是来自于一个公会。]=]
L["OPT_MASTERLOOT_APPROVAL_DESC"] = "您可以在此决定谁可以成为您的战利品分配者。"
L["OPT_MASTERLOOT_APPROVAL_WHITELIST"] = "战利品分配者白名单"
L["OPT_MASTERLOOT_APPROVAL_WHITELIST_DESC"] = "如果您想要特定玩家成为您的战利品分配者，请输入他们的名字，并用空格或半角逗号分隔。"
L["OPT_MASTERLOOT_AWARD"] = "分配中"
L["OPT_MASTERLOOT_BIDS_AND_VOTES"] = "出价与投票"
L["OPT_MASTERLOOT_CLUB"] = "公会/社区"
L["OPT_MASTERLOOT_CLUB_DESC"] = "选择要从哪个公会/社区来导入/导出设置。"
L["OPT_MASTERLOOT_COUNCIL"] = "委员会"
L["OPT_MASTERLOOT_COUNCIL_CLUB_RANK"] = "公会/社区级别"
L["OPT_MASTERLOOT_COUNCIL_CLUB_RANK_DESC"] = "除了上面选项所选择的玩家以外，该公会/社区此级别以上的成员也会进入委员会。"
L["OPT_MASTERLOOT_COUNCIL_DESC"] = "在您战利品委员会内的玩家可以投票表决谁可以得到战利品。"
L["OPT_MASTERLOOT_COUNCIL_ROLES"] = "队伍角色"
L["OPT_MASTERLOOT_COUNCIL_ROLES_DESC"] = "哪些玩家会自动成为委员会的成员。"
L["OPT_MASTERLOOT_COUNCIL_WHITELIST"] = "委员会白名单"
L["OPT_MASTERLOOT_COUNCIL_WHITELIST_DESC"] = "您也可以选择特定的玩家进入您的委员会，用空格或半角逗号分隔他们的名字。"
L["OPT_MASTERLOOT_DESC"] = "当您或其他人成为战利品分配者，所有战利品都将由此人分发，您会收到您赢得了其他人的物品或其他人赢得了您的物品的通知，然后您可以同相应的人交易物品。"
L["OPT_MASTERLOOT_EXPORT_DONE"] = "战利品分配设置成功导出到 <%s>。"
L["OPT_MASTERLOOT_EXPORT_GUILD_ONLY"] = "请手动替换社区信息为此内容，自动替换仅适用于公会。"
L["OPT_MASTERLOOT_EXPORT_NO_PRIV"] = "您没有权限修改公会信息，您可以请求公会会长来修改它。"
L["OPT_MASTERLOOT_EXPORT_WINDOW"] = "导出战利品分配设置"
L["OPT_MASTERLOOT_LOAD"] = "载入"
L["OPT_MASTERLOOT_LOAD_DESC"] = "从公会/社区的说明中载入战利品分配设置。"
L["OPT_MASTERLOOT_RULES"] = "规则"
L["OPT_MASTERLOOT_RULES_ALLOW_DISENCHANT_DESC"] = "允许队伍成员在战利品分配时选择“分解”"
L["OPT_MASTERLOOT_RULES_ALLOW_KEEP"] = "允许保留战利品"
L["OPT_MASTERLOOT_RULES_ALLOW_KEEP_DESC"] = "允许战利品拾取者保留物品，只有在他们选择不保留的情况下才将其给别人。"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD"] = "自动分配战利品"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_DESC"] = "让插件自动决定谁应该获得战利品，基于委员会投票、出价和装等等因素。"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT"] = "自动分配时间（基础）"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT_DESC"] = "在自动分配战利品之前等待的基础时间，让您有时间收集投票或自己决定。"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT_PER_ITEM"] = "自动分配时间（每项物品）"
L["OPT_MASTERLOOT_RULES_AUTO_AWARD_TIMEOUT_PER_ITEM_DESC"] = "每掉落一件物品，都将此时间加入到基础时间中"
L["OPT_MASTERLOOT_RULES_BID_PUBLIC"] = "公开出价"
L["OPT_MASTERLOOT_RULES_BID_PUBLIC_DESC"] = "您可以公开出价，这样每个人都可以看到出价人和竞拍物品。"
L["OPT_MASTERLOOT_RULES_DESC"] = "当您是战利品分配者时，这些选项适用于所有人。"
L["OPT_MASTERLOOT_RULES_DISENCHANTER"] = "分解者"
L["OPT_MASTERLOOT_RULES_DISENCHANTER_DESC"] = "将无人想要的战利品给这些玩家以分解，用空格或半角逗号分隔多个名字。"
L["OPT_MASTERLOOT_RULES_GREED_ANSWERS"] = "自订“贪婪”的回答"
L["OPT_MASTERLOOT_RULES_GREED_ANSWERS_DESC"] = [=[当战利品分配选择“贪婪”时，您可依据优先级最多指定9个自定义回答。您还可以插入“%s”本身让其优先级降低到先前回答之下。使用半角逗号分隔多条回答。

当分配战利品时，您可以通过右键点击“贪婪”按钮来查阅。]=]
L["OPT_MASTERLOOT_RULES_NEED_ANSWERS"] = "自订“需求”的回答"
L["OPT_MASTERLOOT_RULES_NEED_ANSWERS_DESC"] = [=[当战利品分配选择“需求”时，您可依据优先级最多指定9个自定义回答。您还可以插入“%s”本身让其优先级降低到先前回答之下。使用半角逗号分隔多条回答。

当分配战利品时，您可以通过右键点击“需求”按钮来查阅。]=]
L["OPT_MASTERLOOT_RULES_START_ALL"] = "开启所有人都可以参与的竞拍"
L["OPT_MASTERLOOT_RULES_START_ALL_DESC"] = "开启所有人都可以参与的竞拍，包括没有安装这个插件的队伍成员。"
L["OPT_MASTERLOOT_RULES_START_LIMIT"] = "竞拍运行上限"
L["OPT_MASTERLOOT_RULES_START_LIMIT_DESC"] = "允许同时进行的竞拍数量。当同时进行的竞拍数达到此值时，新的竞拍将会进入到队列中，即使您选择了手动开始竞拍。只有某一个正在进行的竞拍结束了，后续的竞拍才会依次自动开始。设为 0 来禁用。"
L["OPT_MASTERLOOT_RULES_START_MANUALLY"] = "手动开启竞拍"
L["OPT_MASTERLOOT_RULES_START_MANUALLY_DESC"] = "不自动开启新的竞拍，而是通过竞拍窗口手动开启。"
L["OPT_MASTERLOOT_RULES_START_WHISPER"] = "通过密语竞拍"
L["OPT_MASTERLOOT_RULES_START_WHISPER_DESC"] = "允许没有安装此插件的队伍成员通过密语向你发送物品链接和文字“%s”来开启竞拍。"
L["OPT_MASTERLOOT_RULES_TIMEOUT_BASE"] = "竞拍时间（基础）"
L["OPT_MASTERLOOT_RULES_TIMEOUT_BASE_DESC"] = "竞拍的基础持续时间，无论掉落了多少物品。"
L["OPT_MASTERLOOT_RULES_TIMEOUT_PER_ITEM"] = "竞拍时间（每项物品）"
L["OPT_MASTERLOOT_RULES_TIMEOUT_PER_ITEM_DESC"] = "每掉落一件物品，此时间都会加入到基础竞拍时间中。"
L["OPT_MASTERLOOT_RULES_VOTE_PUBLIC"] = "公开投票"
L["OPT_MASTERLOOT_RULES_VOTE_PUBLIC_DESC"] = "您可以公开委员会的投票，让每个人都能看到某人获得的票数。"
L["OPT_MASTERLOOT_SAVE"] = "储存"
L["OPT_MASTERLOOT_SAVE_DESC"] = "储存您当前的战利品分配设置到此公会/社区的说明中。"

-- Options-Messages
L["OPT_CUSTOM_MESSAGES"] = "自订消息"
L["OPT_CUSTOM_MESSAGES_DEFAULT"] = "默认语言（%s）"
L["OPT_CUSTOM_MESSAGES_DEFAULT_DESC"] = "当密语对象使用%s或未使用您服务器的默认语言（%s）时，将使用这些消息。"
L["OPT_CUSTOM_MESSAGES_DESC"] = "您可以通过在中间添加数字和$符号来对占位符（|cffffff78%s|r和|cffffff78%d|r）重新排序，例如可以用|cffffff78%2$s|r替换|cffffff78%s|r来把占位符放到第二位，详见鼠标提示。"
L["OPT_CUSTOM_MESSAGES_LOCALIZED"] = "服务器默认语言（%s）"
L["OPT_CUSTOM_MESSAGES_LOCALIZED_DESC"] = "当密语对象使用您服务器的默认语言（%s）时，将使用这些消息。"
L["OPT_ECHO"] = "聊天信息"
L["OPT_ECHO_DEBUG"] = "调试"
L["OPT_ECHO_DESC"] = [=[您希望插件在聊天中显示多少信息？

|cffffff78无:|r 不在聊天中显示信息。
|cffffff78错误:|r 只显示错误信息。
|cffffff78信息:|r 你可能需要采取行动的信息。
|cffffff78详细:|r 获知插件所做的任何事情。
|cffffff78调试:|r 同详细一样，再加上调试信息。]=]
L["OPT_ECHO_ERROR"] = "错误"
L["OPT_ECHO_INFO"] = "信息 "
L["OPT_ECHO_NONE"] = "无"
L["OPT_ECHO_VERBOSE"] = "详细"
L["OPT_GROUPCHAT"] = "队伍聊天"
L["OPT_GROUPCHAT_ANNOUNCE"] = "通告战利品竞拍及获胜者"
L["OPT_GROUPCHAT_ANNOUNCE_DESC"] = "在队伍聊天中通告战利品竞拍以及获胜者。"
L["OPT_GROUPCHAT_CONCISE"] = "使通知尽量简洁"
L["OPT_GROUPCHAT_CONCISE_DESC"] = [=[当BOSS只掉落一件物品时，使用更简洁的通知（例如在5人副本中）。

插件将在聊天中发布物品链接，队伍成员可以回复类似“%s”、“%s”或“+”之类的内容来竞拍它们。]=]
L["OPT_GROUPCHAT_DESC"] = "更改插件是否要将消息发送到队伍聊天中。"
L["OPT_GROUPCHAT_GROUP_TYPE"] = "根据队伍类型通告"
L["OPT_GROUPCHAT_GROUP_TYPE_DESC"] = [=[只有当您在以下类型的队伍中时才发送消息。

|cffffff78公会队伍:|r 队伍中 %d%% 及以上的人员来自于同一公会。
|cffffff78社区队伍:|r 队伍中 %d%% 及以上的人员来自于同一魔兽社区。]=]
L["OPT_GROUPCHAT_ROLL"] = "在聊天中竞拍战利品"
L["OPT_GROUPCHAT_ROLL_DESC"] = "竞拍您想要的战利品（/roll）如果其他人在队伍聊天中贴出了它的物品链接。"
L["OPT_MESSAGES"] = "消息"
L["OPT_MSG_BID"] = "请求战利品：变体 %d"
L["OPT_MSG_BID_DESC"] = "1：物品连接"
L["OPT_MSG_ROLL_ANSWER_AMBIGUOUS"] = "回复：发给我物品链接"
L["OPT_MSG_ROLL_ANSWER_AMBIGUOUS_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_BID"] = "回复：出价已记录"
L["OPT_MSG_ROLL_ANSWER_BID_DESC"] = "1：物品连接"
L["OPT_MSG_ROLL_ANSWER_NO_OTHER"] = "回复：我已经给別人了"
L["OPT_MSG_ROLL_ANSWER_NO_OTHER_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_NO_SELF"] = "回复：我也有需求"
L["OPT_MSG_ROLL_ANSWER_NO_SELF_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_NOT_TRADABLE"] = "回复：这件物品无法交易"
L["OPT_MSG_ROLL_ANSWER_NOT_TRADABLE_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_STARTED"] = "回复：我已为你开启一项竞拍"
L["OPT_MSG_ROLL_ANSWER_STARTED_DESC"] = "当是战利品分配者时，如果没有安装此插件通过密语我们来开始一项竞拍，以此消息回复。"
L["OPT_MSG_ROLL_ANSWER_YES"] = "回复：你可以得到它"
L["OPT_MSG_ROLL_ANSWER_YES_DESC"] = ""
L["OPT_MSG_ROLL_ANSWER_YES_MASTERLOOT"] = "回复：你可以得到它（作为战利品分配者）"
L["OPT_MSG_ROLL_ANSWER_YES_MASTERLOOT_DESC"] = "1：物品拾取者"
L["OPT_MSG_ROLL_DISENCHANT"] = "通告分解者"
L["OPT_MSG_ROLL_DISENCHANT_DESC"] = [=[1：分解者
2：物品链接]=]
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT"] = "通告分解者（作为物品分配者） "
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT_DESC"] = [=[1：分解者
2：物品链接
3：物品拾取者
4：他/她]=]
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT_OWN"] = "通告物品拾取者分解了他拾取的物品（作为战利品分配者）"
L["OPT_MSG_ROLL_DISENCHANT_MASTERLOOT_OWN_DESC"] = [=[1：物品拥有者
2：物品链接]=]
L["OPT_MSG_ROLL_DISENCHANT_WHISPER"] = "与分解者密语"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_DESC"] = "1：物品链接"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT"] = "与分解者密语（作为战利品分配者）"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_DESC"] = [=[1：物品链接
2：物品拾取者
3：他/她]=]
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_OWN"] = "与物品拾取者密语来分解他拾取的物品（作为战利品分配者）"
L["OPT_MSG_ROLL_DISENCHANT_WHISPER_MASTERLOOT_OWN_DESC"] = "1：物品链接"
L["OPT_MSG_ROLL_START"] = "宣布新的竞拍"
L["OPT_MSG_ROLL_START_CONCISE"] = "宣布新的竞拍（简要）"
L["OPT_MSG_ROLL_START_CONCISE_DESC"] = "1：物品链接"
L["OPT_MSG_ROLL_START_DESC"] = [=[1：物品链接
2：掷出点数]=]
L["OPT_MSG_ROLL_START_MASTERLOOT"] = "宣布新的竞拍（作为战利品分配者）"
L["OPT_MSG_ROLL_START_MASTERLOOT_DESC"] = [=[1：物品链接
2：物品拾取者
3：掷出点数]=]
L["OPT_MSG_ROLL_WINNER"] = "宣布竞拍获胜者"
L["OPT_MSG_ROLL_WINNER_CONCISE"] = "宣布竞拍获胜者（简要）"
L["OPT_MSG_ROLL_WINNER_CONCISE_DESC"] = "1：获胜者"
L["OPT_MSG_ROLL_WINNER_DESC"] = [=[1：获胜者
2：物品链接]=]
L["OPT_MSG_ROLL_WINNER_MASTERLOOT"] = "宣布竞拍获胜者（作为战利品分配者）"
L["OPT_MSG_ROLL_WINNER_MASTERLOOT_DESC"] = [=[1：获胜者
2：物品链接
3：物品拾取者
4：他/她]=]
L["OPT_MSG_ROLL_WINNER_MASTERLOOT_OWN"] = "宣布物品拾取者保留他拾取的物品（作为战利品分配者）"
L["OPT_MSG_ROLL_WINNER_MASTERLOOT_OWN_DESC"] = [=[1：物品拾取者
2：物品链接]=]
L["OPT_MSG_ROLL_WINNER_WHISPER"] = "与竞拍获胜者密语"
L["OPT_MSG_ROLL_WINNER_WHISPER_CONCISE"] = "与竞拍获胜者密语（简要）"
L["OPT_MSG_ROLL_WINNER_WHISPER_CONCISE_DESC"] = ""
L["OPT_MSG_ROLL_WINNER_WHISPER_DESC"] = "1：物品链接"
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT"] = "与竞拍获胜者密语（作为战利品分配者）"
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT_DESC"] = [=[1：物品链接
2：物品拾取者
3：他/她]=]
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT_OWN"] = "与物品拾取者密语，让他保留拾取的物品（作为战利品分配者）"
L["OPT_MSG_ROLL_WINNER_WHISPER_MASTERLOOT_OWN_DESC"] = "1：物品链接"
L["OPT_SHOULD_CHAT"] = "启用/禁用"
L["OPT_SHOULD_CHAT_DESC"] = "决定插件何时向小队/团队频道发布消息并密语其他玩家。"
L["OPT_WHISPER"] = "密语聊天"
L["OPT_WHISPER_ANSWER"] = "回复请求"
L["OPT_WHISPER_ANSWER_DESC"] = "让插件自动回复您的队伍成员关于您拾取物品的密语。"
L["OPT_WHISPER_ASK"] = "请求战利品"
L["OPT_WHISPER_ASK_DESC"] = "当其他人拾取了您想要的战利品时向他们密语。"
L["OPT_WHISPER_ASK_VARIANTS"] = "开启随机请求"
L["OPT_WHISPER_ASK_VARIANTS_DESC"] = "当请求战利品时，随机选择不同的内容（见下面）以减少重复。"
L["OPT_WHISPER_DESC"] = "更改插件是否向其他玩家密语并回复其他人的消息。"
L["OPT_WHISPER_GROUP"] = "根据队伍类型密语"
L["OPT_WHISPER_GROUP_DESC"] = "如果其他人拾取了您想要的战利品，根据您当前所处的队伍类型来决定是否向其他人密语。"
L["OPT_WHISPER_GROUP_TYPE"] = "根据队伍类型请求"
L["OPT_WHISPER_GROUP_TYPE_DESC"] = [=[只有当您处于以下类型的队伍时才请求战利品。

|cffffff78公会队伍:|r 队伍里 %d%% 及以上的成员来自于同一公会。
|cffffff78社区队伍:|r 队伍里 %d%% 及以上的成员来自于同一魔兽社区。]=]
L["OPT_WHISPER_SUPPRESS"] = "阻止请求"
L["OPT_WHISPER_SUPPRESS_DESC"] = "当您赠送战利品时，阻止来自符合条件的玩家发送的密语消息。"
L["OPT_WHISPER_TARGET"] = "根据目标类型请求"
L["OPT_WHISPER_TARGET_DESC"] = "根据目标是否在您的公会、魔兽社区或好友名单上来决定是否请求战利品。"

-- Plugins-EPGP
L["EPGP"] = "EPGP（贡献点/装备点）制度"
L["EPGP_CREDIT_GP"] = "将 %dGP 计入 <%s>（获得了 %s）。"
L["EPGP_EP"] = "EP（贡献点）"
L["EPGP_ERROR_CREDIT_GP_FAILED"] = "将 %dGP 计入 <%s> 失败（获得了 %s）！"
L["EPGP_GP"] = "GP（装备点）"
L["EPGP_OPT_AWARD_BEFORE"] = "奖励优先级"
L["EPGP_OPT_AWARD_BEFORE_DESC"] = "选择在确定获胜者的时候，应使用哪种方法来结合EPGP的PR值。"
L["EPGP_OPT_BID_WEIGHTS"] = "GP权重"
L["EPGP_OPT_BID_WEIGHTS_DESC"] = "为不同的出价分配相应的权重，获胜者得到的GP将乘以该值，可以是0或负数。"
L["EPGP_OPT_DESC"] = "当处于队长分配模式时，使用EPGP制度进行战利品分发。这包括根据玩家的PR值来显示和排序，以及在获得战利品时记入GP。"
L["EPGP_OPT_ONLY_GUILD_RAID"] = "仅限于公会活动 "
L["EPGP_OPT_ONLY_GUILD_RAID_DESC"] = "仅在团队中且该团队至少有 %d%% 的成员来自您公会时才激活。"
L["EPGP_OPT_WARNING_NO_ADDON"] = "|cffff0000警告:|r 您需要安装并激活“EPGP Next”插件才能使用此模块。"
L["EPGP_OPT_WARNING_NO_OFFICER"] = "|cffff0000警告:|r 您没有修改官员备注的权限，当您是战利品分配者时，EPGP无法将GP归入战利品 。"
L["EPGP_PR"] = "PR（优先权）"

-- Roll
L["BID_CHAT"] = "正在向 %s 请求 %s。-> %s"
L["BID_MAX_WHISPERS"] = "不会向 %s 请求 %s，因为您队伍中的 %d 个玩家已经询问过。-> %s"
L["BID_NO_CHAT"] = "无法请求或竞拍 %s。"
L["BID_NO_CHAT_ADDONS"] = "由于所有人都使用了拾取插件，所以不会通告 %s 的竞拍。"
L["BID_NO_CHAT_ANNOUNCE"] = "由于禁用了队伍通知，所以不会通告 %s 的竞拍。"
L["BID_NO_CHAT_ASK"] = "由于密语请求已被禁用，所以不会向 %s 请求 %s。-> %s"
L["BID_NO_CHAT_CLUB"] = "由于 %s 来自您的社区，所以不会向他请求 %s。-> %s"
L["BID_NO_CHAT_DND"] = "由于 %s 已启用勿扰，所以不会向他请求 %s。-> %s"
L["BID_NO_CHAT_FRIEND"] = "由于 %s 是您的好友，所以不会向他请求 %s。-> %s"
L["BID_NO_CHAT_GRP"] = "由于在“%s”队伍中，所以不会通告 %s 的竞拍。"
L["BID_NO_CHAT_GRP_ASK"] = "由于在“%s”队伍中，所以不会向 %s 请求 %s。-> %s"
L["BID_NO_CHAT_GUILD"] = "由于 %s 来自您的公会，所以不会向他请求 %s。-> %s"
L["BID_NO_CHAT_OTHER"] = "由于 %s 来自随机队伍，所以不会向他请求 %s。-> %s"
L["BID_NO_CHAT_SELF"] = "不会向 %s 请求 %s，因为是您自己拾取的。-> %s"
L["BID_NO_CHAT_TRACKING"] = "由于 %s 也使用了拾取插件，所以不会向他请求 %s。-> %s"
L["BID_PASS"] = "已放弃 %s，由 %s 拾取。"
L["BID_START"] = "正在以 %q 出价竞拍 %s，由 %s 拾取。"
L["MASTERLOOTER_OTHER"] = "%s 现在是您的战利品分配者。"
L["MASTERLOOTER_REJECT"] = "%s 想成为您的战利品分配者，但需要在“战利品分配”选项中被允许。"
L["MASTERLOOTER_SELF"] = "您现在是战利品分配者。"
L["ROLL_AWARD_BIDS"] = "出价"
L["ROLL_AWARD_RANDOM"] = "随机选择"
L["ROLL_AWARD_ROLLS"] = "点数大小"
L["ROLL_AWARD_VOTES"] = "投票结果"
L["ROLL_AWARDED"] = "已分配"
L["ROLL_AWARDING"] = "分配中"
L["ROLL_CANCEL"] = "取消竞拍 %s，由 %s 拾取。"
L["ROLL_END"] = "结束竞拍 %s，由 %s 拾取。"
L["ROLL_IGNORING_BID"] = "已忽略 %s 对 %s 的出价，因为您之前已经说过了 -> 出价：%s 或 %s。"
L["ROLL_LIST_EMPTY"] = "有效的竞拍会在此显示"
L["ROLL_START"] = "开始竞拍 %s，由 %s 拾取。"
L["ROLL_STATUS_0"] = "处理中"
L["ROLL_STATUS_1"] = "执行中"
L["ROLL_STATUS_-1"] = "已取消"
L["ROLL_STATUS_2"] = "已完成"
L["ROLL_TRADED"] = "已交易"
L["ROLL_WHISPER_SUPPRESSED"] = "%s 对 %s 出价 -> %s / %s。"
L["ROLL_WINNER_MASTERLOOT"] = "%s 赢得了 %s，由 %s 拾取。"
L["ROLL_WINNER_OTHER"] = "%s 赢得了您拾取的 %s。-> %s"
L["ROLL_WINNER_OWN"] = "您赢得了自己拾取的 %s。"
L["ROLL_WINNER_SELF"] = "您已赢得 %s，由 %s 拾取。-> %s"
L["TRADE_CANCEL"] = "取消与 %s 的交易。"
L["TRADE_START"] = "开始与 %s 交易。"

-- Globals
_G["LOOT_ROLL_INELIGIBLE_REASONPLR_NO_ADDON"] = "物品拾取者没有使用 PersoLootRoll 插件。"
_G["LOOT_ROLL_INELIGIBLE_REASONPLR_NO_DISENCHANT"] = "物品拾取者不允许“分解”出价。"
_G["LOOT_ROLL_INELIGIBLE_REASONPLR_NOT_ENCHANTER"] = "您的角色未学习“附魔”专业。"


-- Other
L["ID"] = ID
L["ITEMS"] = ITEMS
L["LEVEL"] = LEVEL
L["STATUS"] = STATUS
L["TARGET"] = TARGET
L["ROLL_BID_1"] = NEED
L["ROLL_BID_2"] = GREED
L["ROLL_BID_3"] = ROLL_DISENCHANT
L["ROLL_BID_4"] = PASS
L[""] = ""
