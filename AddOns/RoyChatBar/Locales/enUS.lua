local addonName, ns = ...
local L = ns.L
if GetLocale() == "zhCN" then return end

L["聊天设置"] = "Chat Settings"
L["快捷聊天条"] = "Chat Bar"
L["更新记录"] = "Changelog"
L["启用功能"] = "Enable"
L["世"] = "W"
L["大脚世界频道"] = "Dajiao World Channel"
L["说"] = "S"
L["说话频道"] = "Say"
L["喊"] = "Y"
L["大喊频道"] = "Yell"
L["队"] = "P"
L["队伍频道"] = "Party"
L["会"] = "G"
L["公会频道"] = "Guild"
L["本"] = "I"
L["副本频道"] = "Instance / Raid"
L["骰"] = "R"
L["投掷骰子和拾取记录"] = "Random Roll / Loot History"
L["宏"] = "M"
L["宏界面"] = "Macro"
L["备"] = "RC"
L["就位确认和倒数计时"] = "Ready Check / Countdown"
L["倒计时时长"] = "Countdown Duration"
L["退"] = "LR"
L["退出队伍和重置副本"] = "Leave Party / Reset Instance"
L["RL"] = "RL"
L["重载界面和重置伤害"] = "Reload UI / Reset Damage Meter"
L["点击模式"] = "Click Mode"
L["单击重载"] = "Single Click"
L["双击重载"] = "Double Click"
L["左键：世界频道\n右键：进出频道"] = "L: World channel\nR: Join / Leave"
L["已加入世界频道"] = "Joined world channel"
L["已离开世界频道"] = "Left world channel"
L["你不在世界频道，右键点击以加入"] = "Not in world channel. Right-click to join."
L["大喊"] = "Yell"
L["队伍"] = "Party"
L["公会"] = "Guild"
L["左键：副本团队\n右键：团队通知"] = "L: Instance / Raid\nR: Raid Warning"
L["左键：投掷点数\n右键：掷骰记录"] = "L: Random Roll\nR: Loot History"
L["左键：就位确认\n右键：倒数计时"] = "L: Ready Check\nR: Countdown"
L["左键：退出队伍\n右键：重置副本"] = "L: Leave\nR: Reset"
L["左键：重载界面\n右键：重置伤害"] = "L: Reload\nR: Reset Meter"
L["TAB切换频道"] = "TAB Channel Switch"
L["频道名简写"] = "Short Channel Name"
L["聊天条渐隐"] = "Chat Bar Fade"
L["显示"] = "Show"
L["渐隐"] = "Fade"
L["渐隐-战斗显示"] = "Fade (Show in Combat)"
L["淡入时间"] = "Fade In Duration"
L["框体渐隐淡入动画时长"] = "Fade-in animation duration"
L["淡出时间"] = "Fade Out Duration"
L["框体渐隐淡出动画时长"] = "Fade-out animation duration"
L["配置调整"] = "Layout Settings"
L["显示模式"] = "Display Mode"
L["文本"] = "Text"
L["文本大小"] = "Font Size"
L["色块"] = "Square"
L["色块长度"] = "Square Width"
L["色块高度"] = "Square Height"
L["排列方向"] = "Layout Direction"
L["横向"] = "Horizontal"
L["纵向"] = "Vertical"
L["调整间距"] = "Spacing"
L["定位模式"] = "Anchor Mode"
L["定位到屏幕"] = "Screen"
L["定位到聊天框"] = "Chat Frame"
L["水平移动"] = "Position X"
L["垂直移动"] = "Position Y"
L["changelog"] = [[
[2026.8.14] v1.9.5
- Fixed certain errors when cycling channels with TAB
- Fixed certain errors with anchor mode

[2026.8.12] v1.9.4
- Update toc for 12.1

[2026.6.17] v1.9.3
- Update toc for 12.0.7

[2026.6.8] v1.9.2
- Restored Short Channel Name feature
- Added Chat Bar Fade feature

[2026.5.31] v1.9.1
- Reordered TOC file entries
- Added Traditional Chinese localization

[2026.5.31] v1.9
- Full addon restructure
- Added countdown cancel: right-click to start, right-click again to stop
- Added reload click mode: optional double-click to reload, prevents accidental triggers
- Removed channel name abbreviation feature
- Added localization support

[2026.4.22] v1.8.1
- Update toc for 12.0.5

[2026.3.19] v1.8
- Fixed an issue where rejoining the world channel after leaving would not work when using the default chat frame
- Redesigned the addon settings panel

[2026.2.22] v1.7
- Fixed chat bar disappearing when switching chat tabs while anchored to the default chat frame
- Added changelog to the addon's main settings page

[2026.2.14] v1.6
- Split the "Dice" and "Macro" buttons into separate buttons
- Updated "Dice" button: left-click to random roll, right-click to open Loot History
- Added Reset Damage Meter to "RL" button right-click

[2026.1.31] v1.5
- Fixed chat bar texture path

[2026.1.29] v1.4
- Added countdown duration slider (3-10 seconds)
- Updated "Dice" button: left-click opens Macro interface, right-click to random roll
- Added Chat Frame anchor mode: when enabled, the chat bar follows the chat frame in Edit Mode; X/Y values are relative offsets in this mode (default chat frame only)

[2026.1.26] v1.3
- Fixed a combat error caused by channel name abbreviations

[2026.1.23] v1.2
- Added channel name abbreviations
- Added TAB channel cycling
- Adjusted chat bar drag boundaries

[2026.1.22] v1.1
- Renamed addon, Update toc for 12.0

[2026.1.15] v1.0
- Initial release
]]