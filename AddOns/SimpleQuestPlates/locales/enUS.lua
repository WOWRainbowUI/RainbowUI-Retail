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
    ["OPTIONS_ENABLE"] = "Enable",
    ["OPTIONS_DISABLE"] = "Disable",
    ["OPTIONS_DISPLAY"] = "Display Settings",
    ["OPTIONS_GENERAL"] = "General Settings",
    ["OPTIONS_ADDON_STATE"] = "Addon State",
    ["OPTIONS_DEBUG"] = "Enable Debug Mode",
    ["OPTIONS_CHAT_MESSAGES"] = "Show Chat Messages",
    ["OPTIONS_COMBAT"] = "Combat Settings",
    ["OPTIONS_HIDE_COMBAT"] = "Hide Icons in Combat",
    ["OPTIONS_HIDE_INSTANCE"] = "Hide Icons in Instances",
    ["OPTIONS_SCALE"] = "Icon Scale",
    ["OPTIONS_OFFSET_X"] = "Horizontal Offset",
    ["OPTIONS_OFFSET_Y"] = "Vertical Offset",
    ["OPTIONS_ICON_POSITION"] = "Icon Position",
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
    ["OPTIONS_TEXT_COLORS"] = "Quest Text Colors",
    ["OPTIONS_FONT_SETTINGS"] = "Font Settings",
    ["OPTIONS_OUTLINE_WIDTH"] = "Outline Width",
    ["OPTIONS_COLOR_KILL"] = "Kill Quests",
    ["OPTIONS_COLOR_ITEM"] = "Item Quests",
    ["OPTIONS_COLOR_PERCENT"] = "Progress Quests",
    ["OPTIONS_COLOR_OUTLINE"] = "Outline Color",
    ["OPTIONS_ICON_STYLE"] = "Icon Style",
    ["OPTIONS_ICON_TINT"] = "Enable Icon Tinting",
    ["OPTIONS_ICON_COLOR"] = "Icon Tint Color",
    ["OPTIONS_ICON_TINT_MAIN"] = "Enable Main Icon Tinting",
    ["OPTIONS_ICON_COLOR_MAIN"] = "Main Icon Tint Color",
    ["OPTIONS_ICON_TINT_QUEST"] = "Enable Quest Icon Tinting",
    ["OPTIONS_ICON_COLOR_QUEST"] = "Quest Icon Tint Color",
    ["OPTIONS_SHOW_KILL_ICON"] = "Show Kill Icon",
    ["OPTIONS_SHOW_LOOT_ICON"] = "Show Loot Icon",
    ["OPTIONS_QUEST_TYPE_ICONS"] = "Quest Type Icons",
    ["OPTIONS_ICON_OFFSETS"] = "Quest Type Icon Offsets",
    ["OPTIONS_ANIMATE_ICON"] = "Animate Main Icon",
    ["OPTIONS_RESET_MAIN_ICON"] = "Reset Main Icon Settings",
    ["OPTIONS_RESET_QUEST_ICONS"] = "Reset Quest Icon Settings",
    ["OPTIONS_KILL_ICON_OFFSET_X"] = "Kill X",
    ["OPTIONS_KILL_ICON_OFFSET_Y"] = "Kill Y",
    ["OPTIONS_LOOT_ICON_OFFSET_X"] = "Loot X",
    ["OPTIONS_LOOT_ICON_OFFSET_Y"] = "Loot Y",
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
    ["CMD_HELP_ANCHOR"] = "  |cfffff569/sqp anchor <LEFT|RIGHT>|r - Set icon anchor side",
    ["CMD_HELP_OPTIONS"] = "  |cfffff569/sqp options|r - Open options panel",
    ["CMD_HELP_TEST"] = "  |cfffff569/sqp test|r - Test quest detection",
    ["CMD_HELP_STATUS"] = "  |cfffff569/sqp status|r - Show current settings",
    ["CMD_HELP_RESET"] = "  |cfffff569/sqp reset|r - Reset all settings",
    ["CMD_HELP_VERSION"] = "  |cfffff569/sqp version|r - Show addon version",
    ["CMD_HELP_HELP"] = "  |cfffff569/sqp help|r - Show this help menu",
    ["CMD_TEST"] = "Testing quest detection...",
    ["CMD_OPTIONS_OPENED"] = "Options panel opened",
    ["TEST_SCANNING"] = "Testing quest detection...",
    
    -- Quest Detection
    ["QUEST_PROGRESS_KILL"] = "Kill: %d/%d",
    ["QUEST_PROGRESS_ITEM"] = "Collect: %d/%d",
    ["QUEST_TEST_ACTIVE"] = "Active quest objectives found: %d",
    ["QUEST_TEST_NONE"] = "No active quest objectives found",
    ["TEST_FOUND_QUESTS"] = "Found %d units with quest objectives",
    ["TEST_NO_QUESTS"] = "No quest objectives found on visible nameplates",
    
    -- Messages
    ["MSG_LOADED"] = "v%s loaded successfully. Type |cfffff569/sqp help|r for commands.",
    ["MSG_LOADED_LINE1"] = "Loaded successfully. Type |cfffff569/sqp help|r for commands.",
    ["MSG_LOADED_LINE2"] = "|cffffff00Version:|r |cff8080ff%s|r",
    ["MSG_DISCORD"] = "Join our Discord: |cff58be81discord.gg/N7kdKAHVVF|r",
    ["COMMUNITY_MESSAGE"] = "Join our Discord: |cff58be81discord.gg/N7kdKAHVVF|r",
    ["SETTINGS_RESET"] = "|cff58be81All settings have been reset to defaults|r",
    ["SETTINGS_SCALE_SET"] = "Icon scale set to: |cff58be81%.1f|r",
    ["SETTINGS_OFFSET_SET"] = "Icon offset set to: |cff58be81X=%d, Y=%d|r",
    ["SETTINGS_ANCHOR_SET"] = "Anchor set to: |cff58be81%s|r",
    ["ERROR_INVALID_SCALE"] = "|cffff0000Invalid scale value. Use a number between 0.5 and 2.0|r",
    ["ERROR_INVALID_OFFSET"] = "|cffff0000Invalid offset values. Use numbers between -50 and 50|r",
    ["ERROR_INVALID_ANCHOR"] = "|cffff0000Invalid anchor. Use LEFT or RIGHT|r",
    ["ERROR_UNKNOWN_COMMAND"] = "|cffff0000Unknown command. Type /sqp help|r",
    ["ERROR_COMBAT_LOCKDOWN"] = "Cannot open options during combat.",
    ["STATUS_HEADER"] = "|cff58be81Simple Quest Plates Status:|r",
    ["STATUS_STATUS"] = "  State: %s",
    ["STATUS_ENABLED"] = "|cff00ff00ENABLED|r",
    ["STATUS_DISABLED"] = "|cffff0000DISABLED|r",
    ["STATUS_VERSION"] = "Simple Quest Plates version: |cff58be81%s|r",
    ["STATUS_SCALE"] = "  Scale: |cff58be81%.1f|r",
    ["STATUS_OFFSET"] = "  Offset: |cff58be81X=%d, Y=%d|r",
    ["STATUS_ANCHOR"] = "  Position: |cff58be81%s|r",
    ["ADDON_ENABLED"] = "is now |cff00ff00ENABLED|r",
    ["ADDON_DISABLED"] = "is now |cffff0000DISABLED|r",
	
	-- 自行加入
	-- Core
	["PANEL_NAME"] = "|TInterface\\AddOns\\SimpleQuestPlates\\images\\icon:0|t |cff58be81S|r|cffffffffimple|r |cff58be81Q|r|cffffffffuest|r |cff58be81P|r|cfffffffflates|r|cff58be81!|r",
	["RESET_CONFIRM"] = "|cff58be81Simple Quest Plates!|r\n\nAre you sure you want to reset all settings to defaults?",	
	
}

-- Set English as default
for k, v in pairs(L) do
    SQP.L[k] = v
end

L["SimpleQuestPlates"] = "SimpleQuestPlates"
L["Global"] = "Global"
L["Target Name"] = "Target Name"

-- RainbowUI: updated options display strings.
L["Always"] = "Always"
L["Animate Main Icon"] = "Animate Main Icon"
L["Animate Main Icons"] = "Animate Main Icons"
L["Animate every main quest icon. When off, Kill, Loot and Percent use their individual switches."] = "Animate every main quest icon. When off, Kill, Loot and Percent use their individual switches."
L["Animate main icon"] = "Animate main icon"
L["Animate task icons"] = "Animate task icons"
L["Animate when"] = "Animate when"
L["Animation"] = "Animation"
L["Applies to the small quest markers on kill, loot, and percent plates."] = "Applies to the small quest markers on kill, loot, and percent plates."
L["Background style"] = "Background style"
L["Blizzard contains Classic, coins, medals and badges. RGX contains bundled addon logos. Background selection preserves Text Mode. Unavailable atlases show the SQP logo."] = "Blizzard contains Classic, coins, medals and badges. RGX contains bundled addon logos. Background selection preserves Text Mode. Unavailable atlases show the SQP logo."
L["Chat Messages"] = "Chat Messages"
L["Chip: Artifact gold medallion"] = "Chip: Artifact gold medallion"
L["Chip: Coin (copper)"] = "Chip: Coin (copper)"
L["Chip: Coin (gold)"] = "Chip: Coin (gold)"
L["Chip: Coin (silver)"] = "Chip: Coin (silver)"
L["Chip: Gold ring 2"] = "Chip: Gold ring 2"
L["Chip: Gold ring 3"] = "Chip: Gold ring 3"
L["Chip: Guild achievement badge"] = "Chip: Guild achievement badge"
L["Chip: Medal (bronze)"] = "Chip: Medal (bronze)"
L["Chip: Medal (gold)"] = "Chip: Medal (gold)"
L["Chip: Medal (silver)"] = "Chip: Medal (silver)"
L["Chip: Titan disc"] = "Chip: Titan disc"
L["Classic (default)"] = "Classic (default)"
L["Client-native coin chip"] = "Client-native coin chip"
L["Coin"] = "Coin"
L["Combat"] = "Combat"
L["Count Color"] = "Count Color"
L["Counts only, no backgrounds"] = "Counts only, no backgrounds"
L["Display"] = "Display"
L["Display toggle: show or hide the percent sign on quest nameplates."] = "Display toggle: show or hide the percent sign on quest nameplates."
L["Enable all animations"] = "Enable all animations"
L["Enable quest toast: the question-mark pop that plays when you target a mob with a quest icon."] = "Enable quest toast: the question-mark pop that plays when you target a mob with a quest icon."
L["Floating quest icons"] = "Floating quest icons"
L["Font"] = "Font"
L["General"] = "General"
L["Global Animation"] = "Global Animation"
L["Global Placement"] = "Global Placement"
L["Global Scale"] = "Global Scale"
L["Global intensity"] = "Global intensity"
L["Global scale"] = "Global scale"
L["Hide in Combat"] = "Hide in Combat"
L["Hide in Instances"] = "Hide in Instances"
L["Horizontal Offset"] = "Horizontal Offset"
L["Icon Position"] = "Icon Position"
L["Icon Style"] = "Icon Style"
L["Intensity"] = "Intensity"
L["Intensity: %d%%"] = "Intensity: %d%%"
L["Kill"] = "Kill"
L["Kill Animation"] = "Kill Animation"
L["Kill Main Icon"] = "Kill Main Icon"
L["Kill Nameplate"] = "Kill Nameplate"
L["Kill Task Icon"] = "Kill Task Icon"
L["Left Side"] = "Left Side"
L["Left-click opens options. Drag to move. Ctrl-right-click hides it."] = "Left-click opens options. Drag to move. Ctrl-right-click hides it."
L["Loot"] = "Loot"
L["Loot Animation"] = "Loot Animation"
L["Loot Main Icon"] = "Loot Main Icon"
L["Loot Nameplate"] = "Loot Nameplate"
L["Loot Task Icon"] = "Loot Task Icon"
L["Main anchor offset X"] = "Main anchor offset X"
L["Main anchor offset Y"] = "Main anchor offset Y"
L["Minimap Icon"] = "Minimap Icon"
L["Nameplate Side"] = "Nameplate Side"
L["Nameplate side"] = "Nameplate side"
L["No Combat"] = "No Combat"
L["Objective Animation"] = "Objective Animation"
L["Offset X"] = "Offset X"
L["Offset Y"] = "Offset Y"
L["One place for all nameplate animation behavior."] = "One place for all nameplate animation behavior."
L["Per-Objective Placement"] = "Per-Objective Placement"
L["Percent"] = "Percent"
L["Percent Animation"] = "Percent Animation"
L["Percent Main Icon"] = "Percent Main Icon"
L["Percent Nameplate"] = "Percent Nameplate"
L["Percent Task Icon"] = "Percent Task Icon"
L["Pick this quest type's background: Classic icon or the Forever level-frame style."] = "Pick this quest type's background: Classic icon or the Forever level-frame style."
L["Play the main, kill, loot and percent pulses in phase."] = "Play the main, kill, loot and percent pulses in phase."
L["Preview Toast"] = "Preview Toast"
L["Profiles"] = "Profiles"
L["Profiles need the RGX-Framework beta. Enable its beta channel in your addon manager."] = "Profiles need the RGX-Framework beta. Enable its beta channel in your addon manager."
L["Pulse the small kill, loot and percent task icons on plates."] = "Pulse the small kill, loot and percent task icons on plates."
L["Quest Toast"] = "Quest Toast"
L["Reset All Animation Settings"] = "Reset All Animation Settings"
L["Reset All Settings"] = "Reset All Settings"
L["Right Side"] = "Right Side"
L["Scale"] = "Scale"
L["Show on nameplates"] = "Show on nameplates"
L["Show toast animation"] = "Show toast animation"
L["Size"] = "Size"
L["Sync icon animations"] = "Sync icon animations"
L["Task Icons"] = "Task Icons"
L["Text Mode"] = "Text Mode"
L["Tint Main Icon"] = "Tint Main Icon"
L["Toast Duration"] = "Toast Duration"
L["Toast Height"] = "Toast Height"
L["Toast Size"] = "Toast Size"
L["Use global intensity for all icons"] = "Use global intensity for all icons"
L["Use global override"] = "Use global override"
L["Use objective ratio text. Forever keeps its frame; Classic shows bare text."] = "Use objective ratio text. Forever keeps its frame; Classic shows bare text."
L["Use objective ratio text. Forever keeps its frame; Classic shows bare text. Unticking inherits Global text formatting."] = "Use objective ratio text. Forever keeps its frame; Classic shows bare text. Unticking inherits Global text formatting."
L["Vertical Offset"] = "Vertical Offset"
L["When checked, the global intensity below drives every icon. When off, Kill, Loot and Percent use their individual intensity sliders."] = "When checked, the global intensity below drives every icon. When off, Kill, Loot and Percent use their individual intensity sliders."
L["|cff58be81Background Style|r"] = "|cff58be81Background Style|r"
L["|cff58be81Main Icon|r"] = "|cff58be81Main Icon|r"
L["|cff58be81Task Icons|r"] = "|cff58be81Task Icons|r"
L["|cff58be81Toast Animation|r"] = "|cff58be81Toast Animation|r"
L["|cff9a9a9aPreview — SQP disabled|r"] = "|cff9a9a9aPreview — SQP disabled|r"
L["|cff9a9a9aPreview — |r|cff58be81"] = "|cff9a9a9aPreview — |r|cff58be81"
L["|cffbc6fa8Animation Controls|r"] = "|cffbc6fa8Animation Controls|r"
L["|cffbc6fa8Layout & Position|r"] = "|cffbc6fa8Layout & Position|r"
L["|cffbc6fa8Nameplate Style|r"] = "|cffbc6fa8Nameplate Style|r"
