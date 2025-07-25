local AddOnName, Engine = ...;
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale(AddOnName, "zhCN", false, false);
if not L then return end

L['Modules'] = "模块";
L['Left-Click'] = "左键单击";
L['Right-Click'] = "右键单击";
L['k'] = true; -- short for 1000
L['M'] = true; -- short for 1000000
L['B'] = true; -- short for 1000000000
L['L'] = "本地"; -- For the local ping
L['W'] = "世界"; -- For the world ping

-- General
L["Positioning"] = "位置";
L['Bar Position'] = "条位置";
L['Top'] = "顶部";
L['Bottom'] = "底部";
L['Bar Color'] = "条颜色";
L['Use Class Color for Bar'] = "条使用职业颜色";
L["Miscellaneous"] = "杂项";
L['Hide Bar in combat'] = "战斗中隐藏";
L["Hide when in flight"] = true;
L['Bar Padding'] = "条填充";
L['Module Spacing'] = "模块间距";
L['Bar Margin'] = "条形边距";
L["Leftmost and rightmost margin of the bar modules"] = true; -- Need translation
L['Hide order hall bar'] = "隐藏职业大厅条";
L['Use ElvUI for tooltips'] = "使用ElvUI作為工具提示";
L["Lock Bar"] = true;
L["Lock the bar in place"] = true;
L["Lock the bar to prevent dragging"] = true;
L["Makes the bar span the entire screen width"] = true;
L["Position the bar at the top or bottom of the screen"] = true;
L["X Offset"] = true;
L["Y Offset"] = true;
L["Horizontal position of the bar"] = true;
L["Vertical position of the bar"] = true;
L["Behavior"] = true;
L["Spacing"] = true;

-- Positioning Options
L['Positioning Options'] = "位置选项";
L['Horizontal Position'] = "水平位置";
L['Bar Width'] = "条宽度";
L['Left'] = "左";
L['Center'] = "中";
L['Right'] = "右";

-- Media
L['Font'] = "字体";
L['Small Font Size'] = "小字体大小";
L['Text Style'] = "文字风格";

-- Text Colors
L["Colors"] = "颜色";
L['Text Colors'] = "文字颜色";
L['Normal'] = "正常";
L['Inactive'] = "非活动状态";
L["Use Class Color for Text"] = "文字使用职业颜色";
L["Only the alpha can be set with the color picker"] = "只能用拾色器设置透明度";
L['Use Class Colors for Hover'] = "鼠标悬停使用职业颜色";
L['Hover'] = "鼠标悬停";

-------------------- MODULES ---------------------------

L['Micromenu'] = "微型菜单";
L['Show Social Tooltips'] = "显示社交提示";
L['Main Menu Icon Right Spacing'] = "主菜单图标右间距";
L['Icon Spacing'] = "图标间距";
L["Hide BNet App Friends"] = true;
L['Open Guild Page'] = "打开工会页面";
L['No Tag'] = "无标签";
L['Whisper BNet'] = "密语战网";
L['Whisper Character'] = "密语角色";
L['Hide Social Text'] = "隐藏社交文字";
L['Social Text Offset'] = "社會文字偏移";
L["GMOTD in Tooltip"] = "提示每日公会信息";
L["Modifier for friend invite"] = "好友邀请";
L['Show/Hide Buttons'] = "显示/隐藏按钮";
L['Show Menu Button'] = "显示菜单按钮";
L['Show Chat Button'] = "显示聊天按钮";
L['Show Guild Button'] = "显示公会按钮";
L['Show Social Button'] = "显示好友列表按钮";
L['Show Character Button'] = "显示角色信息按钮";
L['Show Spellbook Button'] = "显示法术书和技能按钮";
L['Show Talents Button'] = "显示专精和天赋按钮";
L['Show Achievements Button'] = "显示成就按钮";
L['Show Quests Button'] = "显示任务日志按钮";
L['Show LFG Button'] = "显示地下城和团队副本按钮";
L['Show Journal Button'] = "显示冒险指南按钮";
L['Show PVP Button'] = "显示PVP按钮";
L['Show Pets Button'] = "显示藏品按钮";
L['Show Shop Button'] = "显示商城按钮";
L['Show Help Button'] = "显示帮助按钮";
L['No Info'] = "暂无信息";
L['Classic'] = "经典怀旧服";
L['Alliance'] = "联盟";
L['Horde'] = "部落";
L["Hide Friends Playing Other Games"] = "隐藏其他游戏好友"; 

L['Durability Warning Threshold'] = "耐久性警告閾值";
L['Show Item Level'] = "顯示物品等級";
L['Show Coordinates'] = "顯示坐標";

L['Master Volume'] = "主音量";
L["Volume step"] = "音量调节";

L['Time Format'] = "时间格式";
L['Use Server Time'] = "使用服务器时间";
L['New Event!'] = "新事件!";
L['Local Time'] = "本地时间";
L['Realm Time'] = "服务器时间";
L['Open Calendar'] = "打开日历";
L['Open Clock'] = "打开时钟";
L['Hide Event Text'] = "隐藏事件文字";

L['Travel'] = "传送";
L['Port Options'] = "传送选项";
L['Ready'] = "就绪";
L['Travel Cooldowns'] = "传送冷却";
L['Change Port Option'] = "更改传送选项";

L["Registered characters"] = true;
L['Show Free Bag Space'] = true;
L['Show Other Realms'] = true;
L['Always Show Silver and Copper'] = "始终显示银币和铜币";
L['Shorten Gold'] = "金钱缩写";
L['Toggle Bags'] = "切换背包";
L['Session Total'] = "汇总";
L['Daily Total'] = true;
L['Gold rounded values'] = true;

L['Show XP Bar Below Max Level'] = "未满级时显示经验条";
L['Use Class Colors for XP Bar'] = "经验条使用职业颜色";
L['Show Tooltips'] = "显示提示";
L['Text on Right'] = "文字在右侧";
L['Currency Select'] = "选择货币";
L['First Currency'] = "第一种货币";
L['Second Currency'] = "第二种货币";
L['Third Currency'] = "第三种货币";
L['Rested'] = "精力充沛";

L['Show World Ping'] = "显示世界延迟";
L['Number of Addons To Show'] = "显示插件的数量";
L['Addons to Show in Tooltip'] = "在提示中显示的插件";
L['Show All Addons in Tooltip with Shift'] = "按住SHIFT键在提示中显示所有插件";
L['Memory Usage'] = "内存占用";
L['Garbage Collect'] = "垃圾收集";
L['Cleaned'] = "已清理";

L['Use Class Colors'] = "使用职业颜色";
L['Cooldowns'] = "冷却";
L['Toggle Profession Frame'] = '顯示職業框架';
L['Toggle Profession Spellbook'] = '表演專業拼寫本';

L['Set Specialization'] = "设置专精";
L['Set Loadout'] = true; -- Translation needed
L['Set Loot Specialization'] = "设置拾取专精";
L['Current Specialization'] = "当前专精";
L['Current Loot Specialization'] = "当前拾取专精";
L['Talent Minimum Width'] = "天赋最小宽度";
L['Open Artifact'] = "打开神器";
L['Remaining'] = "剩余";
L['Available Ranks'] = "神器等级";
L['Artifact Knowledge'] = "神器知识";

-- Travel (Translation needed)
L['Hearthstone'] = true;
L['M+ Teleports'] = true;
L['Only show current season'] = true;
L["Mythic+ Teleports"] = true;
L['Show Mythic+ Teleports'] = true;
L['Use Random Hearthstone'] = true;
L['Empty Hearthstones List'] = "If you see an empty list, /reload your UI a few seconds after the initial loading (Blizzard is loading items informations asynchronously so that's the only solution for now)."
L['Hearthstones Select'] = true;
L['Hearthstones Select Desc'] = "Select which hearthstones to use (be careful if you select multiple hearthstones, you might want to check the 'Hearthstones Select' option)";

L["Classic"] = true;
L["Burning Crusade"] = true;
L["Wrath of the Lich King"] = true;
L["Cataclysm"] = true;
L["Mists of Pandaria"] = true;
L["Warlords of Draenor"] = true;
L["Legion"] = true;
L["Battle for Azeroth"] = true;
L["Shadowlands"] = true;
L["Dragonflight"] = true;
L["The War Within"] = true;
L["Current season"] = true;

-- Profile Import/Export
L["Profile Sharing"] = true;

L["Invalid import string"] = true;
L["Failed to decode import string"] = true;
L["Failed to decompress import string"] = true;
L["Failed to deserialize import string"] = true;
L["Invalid profile format"] = true;
L["Profile imported successfully as"] = true;

L["Copy the export string below:"] = true;
L["Paste the import string below:"] = true;
L["Import or export your profiles to share them with other players."] = true;
L["Profile Import/Export"] = true;
L["Export Profile"] = true;
L["Export your current profile settings"] = true;
L["Import Profile"] = true;
L["Import a profile from another player"] = true;

-- Changelog
L["%month%-%day%-%year%"] = "%year%年%month%月%day%日";
L["Version"] = "版本";
L["Important"] = "重要";
L["New"] = "新增";
L["Improvment"] = "改善";
L["Changelog"] = "更新记录";