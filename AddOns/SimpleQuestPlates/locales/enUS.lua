--=====================================================================================
-- RGX | Simple Quest Plates! - enUS.lua

-- Author: DonnieDice
-- Description: English localization
--=====================================================================================

local addonName, SQP = ...
SQP.L = SQP.L or {}

-- Default English strings
local L = {
    -- Options Panel
    ["OPTIONS_ENABLE"] = "Enable Simple Quest Plates",
    ["OPTIONS_DISPLAY"] = "Display Settings",
    ["OPTIONS_SCALE"] = "Icon Scale",
    ["OPTIONS_OFFSET_X"] = "Horizontal Offset",
    ["OPTIONS_OFFSET_Y"] = "Vertical Offset",
    ["OPTIONS_ANCHOR"] = "Icon Position",
    ["OPTIONS_TEST"] = "Test Detection",
    ["OPTIONS_RESET"] = "Reset All Settings",
    ["OPTIONS_RESET_FONT"] = "Reset Font Settings",
    ["OPTIONS_RESET_ICON"] = "Reset Icon Settings",
    ["OPTIONS_FONT_SIZE"] = "Font Size",
    ["OPTIONS_FONT_FAMILY"] = "Font Family",
    ["OPTIONS_GLOBAL_SCALE"] = "Global Scale",
    ["OPTIONS_FONT_OUTLINE"] = "Text Outline",
    ["OPTIONS_CUSTOM_COLORS"] = "Use Custom Colors",
    ["OPTIONS_COLORS"] = "Colors",
    ["OPTIONS_COLOR_KILL"] = "Kill Quests",
    ["OPTIONS_COLOR_ITEM"] = "Item Quests",
    ["OPTIONS_COLOR_PERCENT"] = "Progress Quests",
    ["OPTIONS_ICON_STYLE"] = "Icon Style",
    ["OPTIONS_ICON_TINT"] = "Enable Icon Tinting",
    ["OPTIONS_ICON_COLOR"] = "Icon Tint Color",
    ["OPTIONS_SIZE"] = "Size",
    ["OPTIONS_POSITION"] = "Position",
    
    -- Commands
    ["CMD_ENABLED"] = "is now |cff00ff00ENABLED|r",
    ["CMD_DISABLED"] = "is now |cffff0000DISABLED|r",
    ["CMD_VERSION"] = "Simple Quest Plates version: |cff58be81%s|r",
    ["CMD_SCALE_SET"] = "Icon scale set to: |cff58be81%.1f|r",
    ["CMD_SCALE_INVALID"] = "|cffff0000Invalid scale value. Use a number between 0.5 and 2.0|r",
    ["CMD_OFFSET_SET"] = "Icon offset set to: |cff58be81X=%d, Y=%d|r",
    ["CMD_OFFSET_INVALID"] = "|cffff0000Invalid offset values. Use numbers between -50 and 50|r",
    ["CMD_RESET"] = "|cff58be81All settings have been reset to defaults|r",
    ["CMD_STATUS"] = "|cff58be81Simple Quest Plates Status:|r",
    ["CMD_STATUS_STATE"] = "  State: %s",
    ["CMD_STATUS_SCALE"] = "  Scale: |cff58be81%.1f|r",
    ["CMD_STATUS_OFFSET"] = "  Offset: |cff58be81X=%d, Y=%d|r",
    ["CMD_STATUS_ANCHOR"] = "  Position: |cff58be81%s|r",
    ["CMD_HELP_HEADER"] = "|cff58be81Simple Quest Plates Commands:|r",
    ["CMD_HELP_ENABLE"] = "  |cfffff569/sqp on|r - Enable the addon",
    ["CMD_HELP_DISABLE"] = "  |cfffff569/sqp off|r - Disable the addon",
    ["CMD_HELP_SCALE"] = "  |cfffff569/sqp scale <0.5-2.0>|r - Set icon scale",
    ["CMD_HELP_OFFSET"] = "  |cfffff569/sqp offset <x> <y>|r - Set icon offset (-50 to 50)",
    ["CMD_HELP_OPTIONS"] = "  |cfffff569/sqp options|r - Open options panel",
    ["CMD_HELP_TEST"] = "  |cfffff569/sqp test|r - Test quest detection",
    ["CMD_HELP_STATUS"] = "  |cfffff569/sqp status|r - Show current settings",
    ["CMD_HELP_RESET"] = "  |cfffff569/sqp reset|r - Reset all settings",
    ["CMD_HELP_VERSION"] = "  |cfffff569/sqp version|r - Show addon version",
    ["CMD_HELP_HELP"] = "  |cfffff569/sqp help|r - Show this help menu",
    ["CMD_TEST"] = "Testing quest detection...",
    ["CMD_OPTIONS_OPENED"] = "Options panel opened",
    
    -- Quest Detection
    ["QUEST_PROGRESS_KILL"] = "Kill: %d/%d",
    ["QUEST_PROGRESS_ITEM"] = "Collect: %d/%d",
    ["QUEST_TEST_ACTIVE"] = "Active quest objectives found: %d",
    ["QUEST_TEST_NONE"] = "No active quest objectives found",
    ["TEST_FOUND_QUESTS"] = "Found %d units with quest objectives",
    ["TEST_NO_QUESTS"] = "No quest objectives found on visible nameplates",
    
    -- Messages
    ["MSG_LOADED"] = "v%s loaded successfully. Type |cfffff569/sqp help|r for commands.",
    ["MSG_DISCORD"] = "Join our Discord: |cff58be81discord.gg/N7kdKAHVVF|r",
}

-- Set English as default
for k, v in pairs(L) do
    SQP.L[k] = v
end