---@class addonTableCoolinator
local addonTable = select(2, ...)
local Locales = {
  enUS = {},
  frFR = {},
  deDE = {},
  ruRU = {},
  ptBR = {},
  esES = {},
  esMX = {},
  zhTW = {},
  zhCN = {},
  koKR = {},
  itIT = {},
}

COOLINATOR_LOCALES = Locales

local L = Locales.enUS

L["COOLINATOR"] = "Coolinator"
L["SLASH_DESIGN"] = "design"
L["IMPORTED_X"] = "Imported \"%s\""

L["CUSTOMISE_COOLINATOR"] = "Customise Coolinator"
L["CUSTOMISE_COOLINATOR_X"] = "Customise Coolinator: %s"
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
L["JOIN_THE_DISCORD"] = "Join the Discord"
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
L["BY_PLUSMOUSE"] = "by plusmouse"
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
L["DONATE"] = "Donate"
L["LINK"] = "Link"
L["VERSION_COLON_X"] = "Version: %s"
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
L["OPEN_OPTIONS"] = "Open Options"
L["GENERAL"] = "General"
L["TEXTURES"] = "Textures"
L["ENABLE"] = "Enable"
L["DESIGNER"] = "Designer"
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
L["CLOSE_DESIGNER"] = "Close Designer"
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
L["BEHAVIOUR"] = "Behaviour"
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
L["SHOW_KEYBINDINGS"] = "Show keybindings"
L["MOUSE_BUTTON_X"] = "M%s"
L["FONT"] = "Font"
L["SHOW_OUTLINE"] = "Show outline"
L["SHOW_SHADOW"] = "Show shadow"
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
L["FONT_SIZE"] = "Font size"
L["SHOW_TOOLTIPS"] = "Show tooltips"
L["VISIBLE"] = "Visible"
L["SHOW_FRACTIONS"] = "Show fractions"
L["TEXTS"] = "Texts"
L["SHOW_ICON"] = "Show icon"
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
L["USE_MASQUE"] = "Use Masque"
L["AUTO_SIZE"] = "Auto-size"
L["ALIGN_X"] = "Align %s"
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
L["SAVE_ANCHOR"] = "Save anchor"
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
L["NAME"] = "Name"
L["DURATION"] = "Duration"
L["NAME"] = "Name"
L["VALUE"] = "Value"
L["ARCANE_FLURRY"] = "Arcane Flurry"
L["COUNT"] = "Count"
L["KEYBINDING"] = "Keybinding"
L["START"] = "Start"

L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
L["PROFILES"] = "Profiles"
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"

L["ADD"] = "Add"
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Choose a new design name"
L["INVALID_DESIGN_NAME"] = "Invalid design name"
L["ICON"] = "Icon"
L["GROUP"] = "Group"
L["BAR"] = "Bar"
L["BARS"] = "Bars"
L["AURA"] = "Aura"
L["AURA_BAR"] = "Aura Bar"
L["ABILITY"] = "Ability"
L["ABILITY_CHARGE"] = "Ability Charge"
L["ABILITY_CHARGES"] = "Ability Charges"
L["ABILITY_BAR"] = "Ability Bar"
L["CHARGES"] = "Charges"
L["CAST"] = "Cast"
L["CAST_BAR"] = "Cast Bar"
L["COOLDOWN"] = "Cooldown"
L["ICICLES"] = "Icicles"
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
L["UNLEARNED"] = "Unlearned"
L["ADD_ID"] = "Add ID"
L["ITEM"] = "Item"
L["CLASS"] = "Class"
L["INSERT"] = "Insert"
L["CHOOSE_AURA"] = "Choose Aura"
L["CHOOSE_ABILITY"] = "Choose Ability"
L["CHOOSE_POTION_EFFECT"] = "Choose Potion Effect"
L["CHOOSE_ITEM"] = "Choose Item"
L["CHOOSE_EQUIPMENT"] = "Choose Equipment"
L["EQUIPMENT"] = "Equipment"
L["POTION_EFFECT"] = "Potion Effect"
L["STACK"] = "Stack"
L["SPACER"] = "Spacer"
L["NOTHING_IN_SLOT"] = "Nothing in slot"
L["TOP_LEFT"] = "Top Left"
L["TOP_RIGHT"] = "Top Right"
L["BOTTOM_LEFT"] = "Bottom Left"
L["BOTTOM_RIGHT"] = "Bottom Right"
L["TOP"] = "Top"
L["BOTTOM"] = "Bottom"
L["LEFT"] = "Left"
L["RIGHT"] = "Right"
L["PARENT"] = "Parent"
L["GROW_FROM"] = "Grow from"
L["STYLE"] = "Style"
L["BLIZZARD"] = "Blizzard"
L["SQUARE"] = "Square"
L["REVERSE"] = "Reverse"
L["SWIPE_COLOR"] = "Swipe color"
L["CENTER_HORIZONTAL"] = "Center Horizontal"
L["CENTER_VERTICAL"] = "Center Vertical"

L["LAYOUT"] = "Layout"
L["TRANSPARENCY"] = "Transparency"
L["PADDING"] = "Padding"
L["VERTICAL"] = "Vertical"
L["HORIZONTAL"] = "Horizontal"
L["WIDTH"] = "Width"
L["HEIGHT"] = "Height"
L["NONE"] = "None"
L["SCALE"] = "Scale"
L["BORDER"] = "Border"
L["BORDER_COLOR"] = "Border color"
L["READY_BORDER_COLOR"] = "Ready border color"
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
L["CHARGED_BORDER_COLOR"] = "Charged border color"
L["CHARGED_FOREGROUND_COLOR"] = "Charged foreground color"
L["FOREGROUND"] = "Foreground"
L["FOREGROUND_COLOR"] = "Foreground color"
L["BACKGROUND"] = "Background"
L["BACKGROUND_COLOR"] = "Background color"
L["SELECT_GROUP"] = "Select Group"
L["INSERT"] = "Insert"
L["THRESHOLDS"] = "Thresholds"
L["SAFE"] = "Safe"
L["WARNING"] = "Warning"
L["DANGER"] = "Danger"
L["SAFE_COLOR"] = "Safe color"
L["SAFE_COLOR_FADED"] = "Safe color faded"
L["WARNING_COLOR"] = "Warning color"
L["WARNING_COLOR_FADED"] = "Warning color faded"
L["DANGER_COLOR"] = "Danger color"
L["DANGER_COLOR_FADED"] = "Danger color faded"
L["COLOR"] = "Color"
L["WIDTH_RESTRICTION"] = "Width restriction"
L["COLORS"] = "Colors"
L["SHOW_ICON"] = "Show icon"
L["SHOW_TOOLTIPS"] = "Show tooltips"
L["ICON_POSITION"] = "Icon position"
L["LEFT"] = "Left"
L["RIGHT"] = "Right"
L["CENTER"] = "Center"
L["TOP"] = "Top"
L["BOTTOM"] = "Bottom"
L["ALIGNMENT"] = "Alignment"
L["SHOW_SWIPE"] = "Show swipe"
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
L["CASTING"] = "Casting"
L["CHANNELING"] = "Channeling"
L["INTERRUPTED"] = "Interrupted"
L["UNINTERRUPTABLE"] = "Uninterruptable"
L["COMPLETED"] = "Completed"
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
L["HIDE_WHEN_READY"] = "Hide when ready"
L["DISPLAY"] = "Display"
L["ELAPSED"] = "Elapsed"
L["REMAINING"] = "Remaining"
L["TOTAL"] = "Total"
L["USE_PERCENTAGE"] = "Use percentage"
L["NOTHING"] = "Nothing"
L["DESATURATE"] = "Desaturate"
L["HIDE"] = "Hide"
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
L["WHEN_READY"] = "When ready"
L["PIXEL_GLOW"] = "Pixel Glow"
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
L["FLASH_GLOW"] = "Flash Glow"
L["STATIC_GLOW"] = "Static Glow"
L["GLOW_COLOR"] = "Glow color"
L["REVERSE_GLOW"] = "Reverse glow"
L["SHOW_PANDEMIC"] = "Show pandemic"
L["WHEN_ACTIVE"] = "When active"
L["WHEN_INACTIVE"] = "When inactive"
L["ACTIVE"] = "Active"
L["RANGE_CHECKING"] = "Range checking"

L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."

L["OPTIONS"] = "Options"
L["DELETE"] = "Delete"

L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"

L["SLASH_RESET"] = "reset"
L["SLASH_DESIGN"] = "design"
L["SLASH_REGEN"] = "regen"
L["SLASH_CHANGE_DESIGN"] = "changedesign"
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
L["SLASH_CHANGE_DESIGN_HELP"] = "Change currently used design to the name specified"
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
L["SLASH_HELP"] = "Open the Coolinator settings."
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
L["MISSING_DESIGN_X"] = "Missing design \"%s\""
L["CANNOT_CHANGE_DESIGN_DUE_TO_RESTRICTIONS"] = "Cannot change design due to restrictions"

L["EXPORT"] = "Export"
L["IMPORT"] = "Import"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"

L["WHAT_TO_EXPORT"] = "What to export?"
L["DESIGN"] = "Design"
L["PROFILE"] = "Profile"

L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
L["OVERWRITE"] = "Overwrite"
L["MAKE_NEW"] = "Make new"
L["INVALID_IMPORT"] = "Invalid import"
L["NEW_DESIGN"] = "New Design"

L["ESSENTIAL"] = "Essential"
L["DEFAULT"] = "Default"
L["UTILITY"] = "Utility"
L["AURAS"] = "Auras"
L["PRESET"] = "Preset"
L["AURA_BARS"] = "Auras Bars"
L["CREATE_PRESET"] = "Create Preset"
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
L["ENTER_PRESET_NAME"] = "Enter preset name:"
L["DETACH_PRESET"] = "Detach Preset"
L["NONE_SET"] = "None set"

L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
L["VISIBILITY"] = "Visibility"
L["CUSTOM"] = "Custom"
L["COMBAT"] = "Combat"
L["MOUNT"] = "Mount"
L["TARGET"] = "Target"
L["LOCATION"] = "Location"
L["IN_COMBAT"] = "In Combat"
L["OUT_OF_COMBAT"] = "Out of Combat"
L["ON_MOUNT"] = "On Mount"
L["OFF_MOUNT"] = "Off Mount"
L["SKYRIDING_ZONE"] = "Skyriding Zone"
L["HAS_TARGET"] = "Has Target"
L["NO_TARGET"] = "No Target"
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
L["RESTED"] = "Rested"
L["WORLD"] = "World"
L["DUNGEON"] = "Dungeon"
L["RAID"] = "Raid"
L["PVP"] = "PvP"
L["DELVE"] = "Delve"
L["ACTION"] = "Action"
L["SITUATION"] = "Situation"
L["SHOW"] = "Show"
L["HIDE"] = "Hide"
L["FADE"] = "Fade"

L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"

local L = Locales.frFR
--[[Translation missing --]]
L["ABILITY"] = "Ability"
--[[Translation missing --]]
L["ABILITY_BAR"] = "Ability Bar"
--[[Translation missing --]]
L["ABILITY_CHARGE"] = "Ability Charge"
--[[Translation missing --]]
L["ABILITY_CHARGES"] = "Ability Charges"
--[[Translation missing --]]
L["ACTION"] = "Action"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
--[[Translation missing --]]
L["ADD"] = "Add"
--[[Translation missing --]]
L["ALIGN_X"] = "Align %s"
--[[Translation missing --]]
L["ALIGNMENT"] = "Alignment"
--[[Translation missing --]]
L["ARCANE_FLURRY"] = "Arcane Flurry"
--[[Translation missing --]]
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
--[[Translation missing --]]
L["AURA"] = "Aura"
--[[Translation missing --]]
L["AURA_BAR"] = "Aura Bar"
--[[Translation missing --]]
L["AURA_BARS"] = "Auras Bars"
--[[Translation missing --]]
L["AURAS"] = "Auras"
--[[Translation missing --]]
L["AUTO_SIZE"] = "Auto-size"
--[[Translation missing --]]
L["BACKGROUND"] = "Background"
--[[Translation missing --]]
L["BACKGROUND_COLOR"] = "Background color"
--[[Translation missing --]]
L["BAR"] = "Bar"
--[[Translation missing --]]
L["BARS"] = "Bars"
--[[Translation missing --]]
L["BEHAVIOUR"] = "Behaviour"
--[[Translation missing --]]
L["BLIZZARD"] = "Blizzard"
--[[Translation missing --]]
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Blizzard CDM aura icons/bars are missing, so Coolinator will malfunction. A reload is required"
--[[Translation missing --]]
L["BORDER"] = "Border"
--[[Translation missing --]]
L["BORDER_COLOR"] = "Border color"
--[[Translation missing --]]
L["BOTTOM"] = "Bottom"
--[[Translation missing --]]
L["BOTTOM_LEFT"] = "Bottom Left"
--[[Translation missing --]]
L["BOTTOM_RIGHT"] = "Bottom Right"
--[[Translation missing --]]
L["BY_PLUSMOUSE"] = "by plusmouse"
--[[Translation missing --]]
L["CAST"] = "Cast"
--[[Translation missing --]]
L["CAST_BAR"] = "Cast Bar"
--[[Translation missing --]]
L["CASTING"] = "Casting"
--[[Translation missing --]]
L["CENTER"] = "Center"
--[[Translation missing --]]
L["CENTER_HORIZONTAL"] = "Center Horizontal"
--[[Translation missing --]]
L["CENTER_VERTICAL"] = "Center Vertical"
--[[Translation missing --]]
L["CHANNELING"] = "Channeling"
--[[Translation missing --]]
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Choose a new design name"
--[[Translation missing --]]
L["CHOOSE_ABILITY"] = "Choose Ability"
--[[Translation missing --]]
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
--[[Translation missing --]]
L["CHOOSE_AURA"] = "Choose Aura"
--[[Translation missing --]]
L["CHOOSE_EQUIPMENT"] = "Choose Equipment"
--[[Translation missing --]]
L["CHOOSE_ITEM"] = "Choose Item"
--[[Translation missing --]]
L["CHOOSE_POTION_EFFECT"] = "Choose Potion Effect"
--[[Translation missing --]]
L["CLASS"] = "Class"
--[[Translation missing --]]
L["CLOSE_DESIGNER"] = "Close Designer"
--[[Translation missing --]]
L["COLOR"] = "Color"
--[[Translation missing --]]
L["COLORS"] = "Colors"
--[[Translation missing --]]
L["COMBAT"] = "Combat"
--[[Translation missing --]]
L["COMPLETED"] = "Completed"
--[[Translation missing --]]
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"
--[[Translation missing --]]
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
--[[Translation missing --]]
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
--[[Translation missing --]]
L["COOLDOWN"] = "Cooldown"
--[[Translation missing --]]
L["COOLINATOR"] = "Coolinator"
--[[Translation missing --]]
L["COUNT"] = "Count"
--[[Translation missing --]]
L["CREATE_PRESET"] = "Create Preset"
--[[Translation missing --]]
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
--[[Translation missing --]]
L["CUSTOM"] = "Custom"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR"] = "Customise Coolinator"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR_X"] = "Customise Coolinator: %s"
--[[Translation missing --]]
L["DANGER"] = "Danger"
--[[Translation missing --]]
L["DANGER_COLOR"] = "Danger color"
--[[Translation missing --]]
L["DANGER_COLOR_FADED"] = "Danger color faded"
--[[Translation missing --]]
L["DEFAULT"] = "Default"
--[[Translation missing --]]
L["DELETE"] = "Delete"
--[[Translation missing --]]
L["DELVE"] = "Delve"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
--[[Translation missing --]]
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
--[[Translation missing --]]
L["DESIGN"] = "Design"
--[[Translation missing --]]
L["DESIGNER"] = "Designer"
--[[Translation missing --]]
L["DETACH_PRESET"] = "Detach Preset"
--[[Translation missing --]]
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
--[[Translation missing --]]
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
--[[Translation missing --]]
L["DISPLAY"] = "Display"
--[[Translation missing --]]
L["DONATE"] = "Donate"
--[[Translation missing --]]
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Due to aura bars changing a reload is required for Coolinator function"
--[[Translation missing --]]
L["DUNGEON"] = "Dungeon"
--[[Translation missing --]]
L["DURATION"] = "Duration"
--[[Translation missing --]]
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
--[[Translation missing --]]
L["ELAPSED"] = "Elapsed"
--[[Translation missing --]]
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
--[[Translation missing --]]
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
--[[Translation missing --]]
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
--[[Translation missing --]]
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
--[[Translation missing --]]
L["ENABLE"] = "Enable"
--[[Translation missing --]]
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
--[[Translation missing --]]
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_PRESET_NAME"] = "Enter preset name:"
--[[Translation missing --]]
L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
--[[Translation missing --]]
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
--[[Translation missing --]]
L["EQUIPMENT"] = "Equipment"
--[[Translation missing --]]
L["ESSENTIAL"] = "Essential"
--[[Translation missing --]]
L["EXPORT"] = "Export"
--[[Translation missing --]]
L["FADE"] = "Fade"
--[[Translation missing --]]
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
--[[Translation missing --]]
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
--[[Translation missing --]]
L["FONT"] = "Font"
--[[Translation missing --]]
L["FONT_SIZE"] = "Font size"
--[[Translation missing --]]
L["FOREGROUND"] = "Foreground"
--[[Translation missing --]]
L["FOREGROUND_COLOR"] = "Foreground color"
--[[Translation missing --]]
L["GENERAL"] = "General"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
--[[Translation missing --]]
L["GROUP"] = "Group"
--[[Translation missing --]]
L["GROW_FROM"] = "Grow from"
--[[Translation missing --]]
L["HAS_TARGET"] = "Has Target"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
--[[Translation missing --]]
L["HEIGHT"] = "Height"
--[[Translation missing --]]
L["HIDE"] = "Hide"
--[[Translation missing --]]
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
--[[Translation missing --]]
L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
--[[Translation missing --]]
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
--[[Translation missing --]]
L["HIDE_WHEN_READY"] = "Hide when ready"
--[[Translation missing --]]
L["HORIZONTAL"] = "Horizontal"
--[[Translation missing --]]
L["ICICLES"] = "Icicles"
--[[Translation missing --]]
L["ICON"] = "Icon"
--[[Translation missing --]]
L["ICON_POSITION"] = "Icon position"
--[[Translation missing --]]
L["IMPORT"] = "Import"
--[[Translation missing --]]
L["IMPORTED_X"] = "Imported \"%s\""
--[[Translation missing --]]
L["IN_COMBAT"] = "In Combat"
--[[Translation missing --]]
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
--[[Translation missing --]]
L["INSERT"] = "Insert"
--[[Translation missing --]]
L["INTERRUPTED"] = "Interrupted"
--[[Translation missing --]]
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
--[[Translation missing --]]
L["INVALID_DESIGN_NAME"] = "Invalid design name"
--[[Translation missing --]]
L["INVALID_IMPORT"] = "Invalid import"
--[[Translation missing --]]
L["ITEM"] = "Item"
--[[Translation missing --]]
L["JOIN_THE_DISCORD"] = "Join the Discord"
--[[Translation missing --]]
L["KEYBINDING"] = "Keybinding"
--[[Translation missing --]]
L["LAYOUT"] = "Layout"
--[[Translation missing --]]
L["LEFT"] = "Left"
--[[Translation missing --]]
L["LINK"] = "Link"
--[[Translation missing --]]
L["LOCATION"] = "Location"
--[[Translation missing --]]
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
--[[Translation missing --]]
L["MAKE_NEW"] = "Make new"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
--[[Translation missing --]]
L["MOUNT"] = "Mount"
--[[Translation missing --]]
L["MOUSE_BUTTON_X"] = "M%s"
--[[Translation missing --]]
L["NAME"] = "Name"
--[[Translation missing --]]
L["NEW_DESIGN"] = "New Design"
--[[Translation missing --]]
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
--[[Translation missing --]]
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
--[[Translation missing --]]
L["NO_TARGET"] = "No Target"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
--[[Translation missing --]]
L["NONE"] = "None"
--[[Translation missing --]]
L["NONE_SET"] = "None set"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
--[[Translation missing --]]
L["NOTHING_IN_SLOT"] = "Nothing in slot"
--[[Translation missing --]]
L["OFF_MOUNT"] = "Off Mount"
--[[Translation missing --]]
L["ON_MOUNT"] = "On Mount"
--[[Translation missing --]]
L["OPEN_OPTIONS"] = "Open Options"
--[[Translation missing --]]
L["OPTIONS"] = "Options"
--[[Translation missing --]]
L["OUT_OF_COMBAT"] = "Out of Combat"
--[[Translation missing --]]
L["OVERWRITE"] = "Overwrite"
--[[Translation missing --]]
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
--[[Translation missing --]]
L["PADDING"] = "Padding"
--[[Translation missing --]]
L["PARENT"] = "Parent"
--[[Translation missing --]]
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
--[[Translation missing --]]
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Please reload to get Coolinator working. Reason (%s)"
--[[Translation missing --]]
L["POTION_EFFECT"] = "Potion Effect"
--[[Translation missing --]]
L["PRESET"] = "Preset"
--[[Translation missing --]]
L["PROFILE"] = "Profile"
--[[Translation missing --]]
L["PROFILES"] = "Profiles"
--[[Translation missing --]]
L["PVP"] = "PvP"
--[[Translation missing --]]
L["RAID"] = "Raid"
--[[Translation missing --]]
L["READY_BORDER_COLOR"] = "Ready border color"
--[[Translation missing --]]
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
--[[Translation missing --]]
L["REMAINING"] = "Remaining"
--[[Translation missing --]]
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
--[[Translation missing --]]
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
--[[Translation missing --]]
L["REVERSE"] = "Reverse"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
--[[Translation missing --]]
L["RIGHT"] = "Right"
--[[Translation missing --]]
L["SAFE"] = "Safe"
--[[Translation missing --]]
L["SAFE_COLOR"] = "Safe color"
--[[Translation missing --]]
L["SAFE_COLOR_FADED"] = "Safe color faded"
--[[Translation missing --]]
L["SAVE_ANCHOR"] = "Save anchor"
--[[Translation missing --]]
L["SCALE"] = "Scale"
--[[Translation missing --]]
L["SELECT_GROUP"] = "Select Group"
--[[Translation missing --]]
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."
--[[Translation missing --]]
L["SHOW"] = "Show"
--[[Translation missing --]]
L["SHOW_FRACTIONS"] = "Show fractions"
--[[Translation missing --]]
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
--[[Translation missing --]]
L["SHOW_ICON"] = "Show icon"
--[[Translation missing --]]
L["SHOW_KEYBINDINGS"] = "Show keybindings"
--[[Translation missing --]]
L["SHOW_OUTLINE"] = "Show outline"
--[[Translation missing --]]
L["SHOW_SHADOW"] = "Show shadow"
--[[Translation missing --]]
L["SHOW_SWIPE"] = "Show swipe"
--[[Translation missing --]]
L["SHOW_TOOLTIPS"] = "Show tooltips"
--[[Translation missing --]]
L["SITUATION"] = "Situation"
--[[Translation missing --]]
L["SKYRIDING_ZONE"] = "Skyriding Zone"
--[[Translation missing --]]
L["SLASH_DESIGN"] = "design"
--[[Translation missing --]]
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
--[[Translation missing --]]
L["SLASH_HELP"] = "Open the Coolinator settings."
--[[Translation missing --]]
L["SLASH_REGEN"] = "regen"
--[[Translation missing --]]
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
--[[Translation missing --]]
L["SLASH_RESET"] = "reset"
--[[Translation missing --]]
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
--[[Translation missing --]]
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
--[[Translation missing --]]
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"
--[[Translation missing --]]
L["SQUARE"] = "Square"
--[[Translation missing --]]
L["STACK"] = "Stack"
--[[Translation missing --]]
L["START"] = "Start"
--[[Translation missing --]]
L["STYLE"] = "Style"
--[[Translation missing --]]
L["SWIPE_COLOR"] = "Swipe color"
--[[Translation missing --]]
L["TARGET"] = "Target"
--[[Translation missing --]]
L["TEXTS"] = "Texts"
--[[Translation missing --]]
L["TEXTURES"] = "Textures"
--[[Translation missing --]]
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"
--[[Translation missing --]]
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
--[[Translation missing --]]
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
--[[Translation missing --]]
L["THRESHOLDS"] = "Thresholds"
--[[Translation missing --]]
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
--[[Translation missing --]]
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
--[[Translation missing --]]
L["TOP"] = "Top"
--[[Translation missing --]]
L["TOP_LEFT"] = "Top Left"
--[[Translation missing --]]
L["TOP_RIGHT"] = "Top Right"
--[[Translation missing --]]
L["TOTAL"] = "Total"
--[[Translation missing --]]
L["TRANSPARENCY"] = "Transparency"
--[[Translation missing --]]
L["UNINTERRUPTABLE"] = "Uninterruptable"
--[[Translation missing --]]
L["UNLEARNED"] = "Unlearned"
--[[Translation missing --]]
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
--[[Translation missing --]]
L["USE_MASQUE"] = "Use Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
--[[Translation missing --]]
L["UTILITY"] = "Utility"
--[[Translation missing --]]
L["VALUE"] = "Value"
--[[Translation missing --]]
L["VERSION_COLON_X"] = "Version: %s"
--[[Translation missing --]]
L["VERTICAL"] = "Vertical"
--[[Translation missing --]]
L["VISIBILITY"] = "Visibility"
--[[Translation missing --]]
L["VISIBLE"] = "Visible"
--[[Translation missing --]]
L["WARNING"] = "Warning"
--[[Translation missing --]]
L["WARNING_COLOR"] = "Warning color"
--[[Translation missing --]]
L["WARNING_COLOR_FADED"] = "Warning color faded"
--[[Translation missing --]]
L["WHAT_TO_EXPORT"] = "What to export?"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
--[[Translation missing --]]
L["WIDTH"] = "Width"
--[[Translation missing --]]
L["WIDTH_RESTRICTION"] = "Width restriction"
--[[Translation missing --]]
L["WORLD"] = "World"


local L = Locales.deDE
L["ABILITY"] = "Fähigkeit"
L["ABILITY_BAR"] = "Fähigkeitsleiste"
--[[Translation missing --]]
L["ABILITY_CHARGE"] = "Ability Charge"
--[[Translation missing --]]
L["ABILITY_CHARGES"] = "Ability Charges"
--[[Translation missing --]]
L["ACTION"] = "Action"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
L["ADD"] = "hinzufügen"
--[[Translation missing --]]
L["ALIGN_X"] = "Align %s"
L["ALIGNMENT"] = "Ausrichtung"
--[[Translation missing --]]
L["ARCANE_FLURRY"] = "Arcane Flurry"
--[[Translation missing --]]
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
L["AURA"] = "Aura"
L["AURA_BAR"] = "Aurenleiste"
--[[Translation missing --]]
L["AURA_BARS"] = "Auras Bars"
--[[Translation missing --]]
L["AURAS"] = "Auras"
L["AUTO_SIZE"] = "Autoskalierung"
L["BACKGROUND"] = "Hintergrund"
L["BACKGROUND_COLOR"] = "Hintergrundfarbe"
L["BAR"] = "Leiste"
L["BARS"] = "Leisten"
L["BEHAVIOUR"] = "Verhalten"
L["BLIZZARD"] = "Blizzard"
--[[Translation missing --]]
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Blizzard CDM aura icons/bars are missing, so Coolinator will malfunction. A reload is required"
L["BORDER"] = "Umrandung"
L["BORDER_COLOR"] = "Umrandungsfarbe"
L["BOTTOM"] = "Unten"
L["BOTTOM_LEFT"] = "Unten Lins"
L["BOTTOM_RIGHT"] = "Unten Rechts"
L["BY_PLUSMOUSE"] = "von PLUSMOUSE"
--[[Translation missing --]]
L["CAST"] = "Cast"
--[[Translation missing --]]
L["CAST_BAR"] = "Cast Bar"
--[[Translation missing --]]
L["CASTING"] = "Casting"
L["CENTER"] = "Mittig"
--[[Translation missing --]]
L["CENTER_HORIZONTAL"] = "Center Horizontal"
--[[Translation missing --]]
L["CENTER_VERTICAL"] = "Center Vertical"
--[[Translation missing --]]
L["CHANNELING"] = "Channeling"
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Wähle einen neuen Designnamen aus"
L["CHOOSE_ABILITY"] = "Wähle Fähigkeit"
--[[Translation missing --]]
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
L["CHOOSE_AURA"] = "Wähle Aura"
L["CHOOSE_EQUIPMENT"] = "Wähle Ausrüstungsgegenstand"
L["CHOOSE_ITEM"] = "Wähle Gegenstand"
L["CHOOSE_POTION_EFFECT"] = "Wähle Trankeffekt"
L["CLASS"] = "Klasse"
--[[Translation missing --]]
L["CLOSE_DESIGNER"] = "Close Designer"
L["COLOR"] = "Farbe"
--[[Translation missing --]]
L["COLORS"] = "Colors"
--[[Translation missing --]]
L["COMBAT"] = "Combat"
--[[Translation missing --]]
L["COMPLETED"] = "Completed"
--[[Translation missing --]]
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"
--[[Translation missing --]]
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
L["CONFIRM_DELETE_PROFILE_X"] = "Bestätige Löschung Profil %s"
L["COOLDOWN"] = "Abklingzeit"
L["COOLINATOR"] = "Coolinator"
--[[Translation missing --]]
L["COUNT"] = "Count"
--[[Translation missing --]]
L["CREATE_PRESET"] = "Create Preset"
L["CTRL_C_TO_COPY"] = "Strg+C zum kopieren"
--[[Translation missing --]]
L["CUSTOM"] = "Custom"
L["CUSTOMISE_COOLINATOR"] = "Bearbeite Coolinator"
L["CUSTOMISE_COOLINATOR_X"] = "Bearbeite Coolinator %s"
--[[Translation missing --]]
L["DANGER"] = "Danger"
--[[Translation missing --]]
L["DANGER_COLOR"] = "Danger color"
--[[Translation missing --]]
L["DANGER_COLOR_FADED"] = "Danger color faded"
--[[Translation missing --]]
L["DEFAULT"] = "Default"
--[[Translation missing --]]
L["DELETE"] = "Delete"
--[[Translation missing --]]
L["DELVE"] = "Delve"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
--[[Translation missing --]]
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
L["DESIGN"] = "Design"
--[[Translation missing --]]
L["DESIGNER"] = "Designer"
--[[Translation missing --]]
L["DETACH_PRESET"] = "Detach Preset"
--[[Translation missing --]]
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
--[[Translation missing --]]
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
--[[Translation missing --]]
L["DISPLAY"] = "Display"
--[[Translation missing --]]
L["DONATE"] = "Donate"
--[[Translation missing --]]
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Due to aura bars changing a reload is required for Coolinator function"
--[[Translation missing --]]
L["DUNGEON"] = "Dungeon"
--[[Translation missing --]]
L["DURATION"] = "Duration"
--[[Translation missing --]]
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
--[[Translation missing --]]
L["ELAPSED"] = "Elapsed"
--[[Translation missing --]]
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
--[[Translation missing --]]
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
--[[Translation missing --]]
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
--[[Translation missing --]]
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
--[[Translation missing --]]
L["ENABLE"] = "Enable"
--[[Translation missing --]]
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
--[[Translation missing --]]
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_PRESET_NAME"] = "Enter preset name:"
--[[Translation missing --]]
L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
--[[Translation missing --]]
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
--[[Translation missing --]]
L["EQUIPMENT"] = "Equipment"
--[[Translation missing --]]
L["ESSENTIAL"] = "Essential"
--[[Translation missing --]]
L["EXPORT"] = "Export"
--[[Translation missing --]]
L["FADE"] = "Fade"
--[[Translation missing --]]
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
--[[Translation missing --]]
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
--[[Translation missing --]]
L["FONT"] = "Font"
--[[Translation missing --]]
L["FONT_SIZE"] = "Font size"
--[[Translation missing --]]
L["FOREGROUND"] = "Foreground"
--[[Translation missing --]]
L["FOREGROUND_COLOR"] = "Foreground color"
--[[Translation missing --]]
L["GENERAL"] = "General"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
--[[Translation missing --]]
L["GROUP"] = "Group"
--[[Translation missing --]]
L["GROW_FROM"] = "Grow from"
--[[Translation missing --]]
L["HAS_TARGET"] = "Has Target"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
--[[Translation missing --]]
L["HEIGHT"] = "Height"
--[[Translation missing --]]
L["HIDE"] = "Hide"
--[[Translation missing --]]
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
--[[Translation missing --]]
L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
--[[Translation missing --]]
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
--[[Translation missing --]]
L["HIDE_WHEN_READY"] = "Hide when ready"
--[[Translation missing --]]
L["HORIZONTAL"] = "Horizontal"
--[[Translation missing --]]
L["ICICLES"] = "Icicles"
--[[Translation missing --]]
L["ICON"] = "Icon"
--[[Translation missing --]]
L["ICON_POSITION"] = "Icon position"
--[[Translation missing --]]
L["IMPORT"] = "Import"
--[[Translation missing --]]
L["IMPORTED_X"] = "Imported \"%s\""
--[[Translation missing --]]
L["IN_COMBAT"] = "In Combat"
--[[Translation missing --]]
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
--[[Translation missing --]]
L["INSERT"] = "Insert"
--[[Translation missing --]]
L["INTERRUPTED"] = "Interrupted"
--[[Translation missing --]]
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
--[[Translation missing --]]
L["INVALID_DESIGN_NAME"] = "Invalid design name"
--[[Translation missing --]]
L["INVALID_IMPORT"] = "Invalid import"
--[[Translation missing --]]
L["ITEM"] = "Item"
--[[Translation missing --]]
L["JOIN_THE_DISCORD"] = "Join the Discord"
--[[Translation missing --]]
L["KEYBINDING"] = "Keybinding"
--[[Translation missing --]]
L["LAYOUT"] = "Layout"
--[[Translation missing --]]
L["LEFT"] = "Left"
--[[Translation missing --]]
L["LINK"] = "Link"
--[[Translation missing --]]
L["LOCATION"] = "Location"
--[[Translation missing --]]
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
--[[Translation missing --]]
L["MAKE_NEW"] = "Make new"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
--[[Translation missing --]]
L["MOUNT"] = "Mount"
--[[Translation missing --]]
L["MOUSE_BUTTON_X"] = "M%s"
--[[Translation missing --]]
L["NAME"] = "Name"
--[[Translation missing --]]
L["NEW_DESIGN"] = "New Design"
--[[Translation missing --]]
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
--[[Translation missing --]]
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
--[[Translation missing --]]
L["NO_TARGET"] = "No Target"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
--[[Translation missing --]]
L["NONE"] = "None"
--[[Translation missing --]]
L["NONE_SET"] = "None set"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
--[[Translation missing --]]
L["NOTHING_IN_SLOT"] = "Nothing in slot"
--[[Translation missing --]]
L["OFF_MOUNT"] = "Off Mount"
--[[Translation missing --]]
L["ON_MOUNT"] = "On Mount"
--[[Translation missing --]]
L["OPEN_OPTIONS"] = "Open Options"
--[[Translation missing --]]
L["OPTIONS"] = "Options"
--[[Translation missing --]]
L["OUT_OF_COMBAT"] = "Out of Combat"
--[[Translation missing --]]
L["OVERWRITE"] = "Overwrite"
--[[Translation missing --]]
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
--[[Translation missing --]]
L["PADDING"] = "Padding"
--[[Translation missing --]]
L["PARENT"] = "Parent"
--[[Translation missing --]]
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
--[[Translation missing --]]
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Please reload to get Coolinator working. Reason (%s)"
--[[Translation missing --]]
L["POTION_EFFECT"] = "Potion Effect"
--[[Translation missing --]]
L["PRESET"] = "Preset"
--[[Translation missing --]]
L["PROFILE"] = "Profile"
--[[Translation missing --]]
L["PROFILES"] = "Profiles"
--[[Translation missing --]]
L["PVP"] = "PvP"
--[[Translation missing --]]
L["RAID"] = "Raid"
--[[Translation missing --]]
L["READY_BORDER_COLOR"] = "Ready border color"
--[[Translation missing --]]
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
--[[Translation missing --]]
L["REMAINING"] = "Remaining"
--[[Translation missing --]]
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
--[[Translation missing --]]
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
--[[Translation missing --]]
L["REVERSE"] = "Reverse"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
--[[Translation missing --]]
L["RIGHT"] = "Right"
--[[Translation missing --]]
L["SAFE"] = "Safe"
--[[Translation missing --]]
L["SAFE_COLOR"] = "Safe color"
--[[Translation missing --]]
L["SAFE_COLOR_FADED"] = "Safe color faded"
--[[Translation missing --]]
L["SAVE_ANCHOR"] = "Save anchor"
--[[Translation missing --]]
L["SCALE"] = "Scale"
--[[Translation missing --]]
L["SELECT_GROUP"] = "Select Group"
--[[Translation missing --]]
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."
--[[Translation missing --]]
L["SHOW"] = "Show"
--[[Translation missing --]]
L["SHOW_FRACTIONS"] = "Show fractions"
--[[Translation missing --]]
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
--[[Translation missing --]]
L["SHOW_ICON"] = "Show icon"
--[[Translation missing --]]
L["SHOW_KEYBINDINGS"] = "Show keybindings"
--[[Translation missing --]]
L["SHOW_OUTLINE"] = "Show outline"
--[[Translation missing --]]
L["SHOW_SHADOW"] = "Show shadow"
--[[Translation missing --]]
L["SHOW_SWIPE"] = "Show swipe"
--[[Translation missing --]]
L["SHOW_TOOLTIPS"] = "Show tooltips"
--[[Translation missing --]]
L["SITUATION"] = "Situation"
--[[Translation missing --]]
L["SKYRIDING_ZONE"] = "Skyriding Zone"
--[[Translation missing --]]
L["SLASH_DESIGN"] = "design"
--[[Translation missing --]]
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
--[[Translation missing --]]
L["SLASH_HELP"] = "Open the Coolinator settings."
--[[Translation missing --]]
L["SLASH_REGEN"] = "regen"
--[[Translation missing --]]
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
--[[Translation missing --]]
L["SLASH_RESET"] = "reset"
--[[Translation missing --]]
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
--[[Translation missing --]]
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
--[[Translation missing --]]
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"
--[[Translation missing --]]
L["SQUARE"] = "Square"
--[[Translation missing --]]
L["STACK"] = "Stack"
--[[Translation missing --]]
L["START"] = "Start"
--[[Translation missing --]]
L["STYLE"] = "Style"
--[[Translation missing --]]
L["SWIPE_COLOR"] = "Swipe color"
--[[Translation missing --]]
L["TARGET"] = "Target"
--[[Translation missing --]]
L["TEXTS"] = "Texts"
--[[Translation missing --]]
L["TEXTURES"] = "Textures"
--[[Translation missing --]]
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"
--[[Translation missing --]]
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
--[[Translation missing --]]
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
--[[Translation missing --]]
L["THRESHOLDS"] = "Thresholds"
--[[Translation missing --]]
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
--[[Translation missing --]]
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
--[[Translation missing --]]
L["TOP"] = "Top"
--[[Translation missing --]]
L["TOP_LEFT"] = "Top Left"
--[[Translation missing --]]
L["TOP_RIGHT"] = "Top Right"
--[[Translation missing --]]
L["TOTAL"] = "Total"
--[[Translation missing --]]
L["TRANSPARENCY"] = "Transparency"
--[[Translation missing --]]
L["UNINTERRUPTABLE"] = "Uninterruptable"
--[[Translation missing --]]
L["UNLEARNED"] = "Unlearned"
--[[Translation missing --]]
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
--[[Translation missing --]]
L["USE_MASQUE"] = "Use Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
--[[Translation missing --]]
L["UTILITY"] = "Utility"
--[[Translation missing --]]
L["VALUE"] = "Value"
--[[Translation missing --]]
L["VERSION_COLON_X"] = "Version: %s"
--[[Translation missing --]]
L["VERTICAL"] = "Vertical"
--[[Translation missing --]]
L["VISIBILITY"] = "Visibility"
--[[Translation missing --]]
L["VISIBLE"] = "Visible"
--[[Translation missing --]]
L["WARNING"] = "Warning"
--[[Translation missing --]]
L["WARNING_COLOR"] = "Warning color"
--[[Translation missing --]]
L["WARNING_COLOR_FADED"] = "Warning color faded"
--[[Translation missing --]]
L["WHAT_TO_EXPORT"] = "What to export?"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
--[[Translation missing --]]
L["WIDTH"] = "Width"
--[[Translation missing --]]
L["WIDTH_RESTRICTION"] = "Width restriction"
--[[Translation missing --]]
L["WORLD"] = "World"


local L = Locales.ruRU
L["ABILITY"] = "Способность"
L["ABILITY_BAR"] = "Панель способностей"
L["ABILITY_CHARGE"] = "Перезарядка способности"
L["ABILITY_CHARGES"] = "Перезарядка способностей"
L["ACTION"] = "Действие"
L["ACTIVE"] = "Активный"
L["ADD"] = "Добавить"
L["ALIGN_X"] = "Выравнивание %s"
L["ALIGNMENT"] = "Выравнивание"
L["ARCANE_FLURRY"] = "Тайный шквал"
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Вы уверены, что хотите удалить сохраненные привязки?"
L["AURA"] = "Аура"
L["AURA_BAR"] = "Полоса аур"
L["AURA_BARS"] = "Полосы аур"
L["AURAS"] = "Ауры"
L["AUTO_SIZE"] = "Автоматический размер"
L["BACKGROUND"] = "Фон"
L["BACKGROUND_COLOR"] = "Цвет фона"
L["BAR"] = "Панель"
L["BARS"] = "Панели"
L["BEHAVIOUR"] = "Поведение"
L["BLIZZARD"] = "Blizzard"
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Значки/полосы ауры Blizzard CDM отсутствуют, поэтому Coolinator будет работать некорректно. Требуется перезагрузка"
L["BORDER"] = "Рамка"
L["BORDER_COLOR"] = "Цвет рамки"
L["BOTTOM"] = "Вниз"
L["BOTTOM_LEFT"] = "Внизу слева"
L["BOTTOM_RIGHT"] = "Внизу справа"
L["BY_PLUSMOUSE"] = "от plusmouse"
L["CAST"] = "Применение заклинания"
L["CAST_BAR"] = "Панель применение заклинания"
L["CASTING"] = "Применять заклинание"
L["CENTER"] = "Центр"
L["CENTER_HORIZONTAL"] = "Центрировать по горизонтали"
L["CENTER_VERTICAL"] = "Центрировать по вертикали"
L["CHANNELING"] = "Направление"
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Выберите новое название дизайна"
L["CHOOSE_ABILITY"] = "Выберите Способность"
L["CHOOSE_AN_ANCHOR_NAME"] = "Выберите имя привязки:"
L["CHOOSE_AURA"] = "Выберите Ауру"
L["CHOOSE_EQUIPMENT"] = "Выберите Снаряжение"
L["CHOOSE_ITEM"] = "Выберите Предмет"
L["CHOOSE_POTION_EFFECT"] = "Выберите Зелье"
L["CLASS"] = "Класс"
L["CLOSE_DESIGNER"] = "Закрыть конструктор"
L["COLOR"] = "Цвет"
L["COLORS"] = "Цвета"
L["COMBAT"] = "Бой"
L["COMPLETED"] = "Завершено"
L["CONFIRM_DELETE_DESIGN_X"] = "Вы уверены, что хотите удалить стиль \"%s\"?"
L["CONFIRM_DELETE_PRESET_X"] = "Вы уверены, что хотите удалить шаблон \"%s\"? Это повлияет на ВСЕ стили."
L["CONFIRM_DELETE_PROFILE_X"] = "Вы уверены, что хотите удалить профиль \"%s\"?"
L["COOLDOWN"] = "Время перезарядки"
L["COOLINATOR"] = "Coolinator"
L["COUNT"] = "Счёт"
L["CREATE_PRESET"] = "Создать шаблон"
L["CTRL_C_TO_COPY"] = "Ctrl + C для копирования"
L["CUSTOM"] = "Пользовательский"
L["CUSTOMISE_COOLINATOR"] = "Настройка Coolinator"
L["CUSTOMISE_COOLINATOR_X"] = "Настройка Coolinator: %s"
L["DANGER"] = "Опасность"
L["DANGER_COLOR"] = "Цвет опасности"
L["DANGER_COLOR_FADED"] = "Блеклый цвет опасности"
L["DEFAULT"] = "По умолчанию"
L["DELETE"] = "Удалить"
L["DELVE"] = "Углубиться"
L["DESATURATE"] = "Обесцветить"
L["DESATURATE_ON_COOLDOWN"] = "Обесцвечивается при перезарядке"
L["DESIGN"] = "Дизайн"
L["DESIGNER"] = "Конструктор"
L["DETACH_PRESET"] = "Отсоединить шаблон"
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Разработка занимает огромное количество времени|r"
L["DISCORD_DESCRIPTION"] = "Обновления, предложения и поддержка"
L["DISPLAY"] = "Индикация"
L["DONATE"] = "Пожертвовать"
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Для изменения панелей аур Coolinator требуется перезагрузка"
L["DUNGEON"] = "Подземелье"
L["DURATION"] = "Продолжительность"
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Редактируйте значки и полосы на экране, нажимая на них"
L["ELAPSED"] = "Истекать"
L["EMPOWERED_STAGE_1"] = "Усиленная стадия 1"
L["EMPOWERED_STAGE_2"] = "Усиленная стадия 2"
L["EMPOWERED_STAGE_3"] = "Усиленная стадия 3"
L["EMPOWERED_STAGE_HOLD"] = "Усиленная стадия удержания"
L["ENABLE"] = "Включить"
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Включить, если строки выходят за границы шрифта"
L["ENTER_DESIGN_NAME"] = "Введите имя профиля:"
L["ENTER_PRESET_NAME"] = "Введите имя шаблона:"
L["ENTER_PROFILE_NAME"] = "Введите Имя профиля:"
L["ENTER_THE_NEW_DESIGN_NAME"] = "Введите новое название дизайна"
L["ENTER_THE_NEW_PROFILE_NAME"] = "Введите новое имя профиля"
L["EQUIPMENT"] = "Снаряжение"
L["ESSENTIAL"] = "Существенный"
L["EXPORT"] = "Экспорт"
L["FADE"] = "Выцветать"
L["FADE_OUT_OF_COMBAT"] = "Выцветать вне боя"
L["FADE_WHEN_MOUNTED"] = "Выцветать на транспорте"
L["FLASH_GLOW"] = "Вспышка свечения"
L["FONT"] = "Шрифт"
L["FONT_SIZE"] = "Размер шрифта"
L["FOREGROUND"] = "Передний план"
L["FOREGROUND_COLOR"] = "Цвет переднего плана"
L["GENERAL"] = "Общее"
L["GLOW_COLOR"] = "Цвет свечения"
L["GROUP"] = "Группа"
L["GROW_FROM"] = "Рост"
L["HAS_TARGET"] = "Имеет цель"
L["HAS_TARGET_ASSIST"] = "Есть цель (Асист)"
L["HAS_TARGET_ATTACK"] = "Есть цель (Атака)"
L["HEIGHT"] = "Высота"
L["HIDE"] = "Скрыть"
L["HIDE_ON_COOLDOWN"] = "Скрыть на время перезарядки"
L["HIDE_OUT_OF_COMBAT"] = "Скрыть вне боя"
L["HIDE_WHEN_MOUNTED"] = "Скрыть на транспорте"
L["HIDE_WHEN_READY"] = "Скрыть при готовности"
L["HORIZONTAL"] = "Горизонтальное"
L["ICICLES"] = "Сосулька"
L["ICON"] = "Иконка"
L["ICON_POSITION"] = "Положение иконки"
L["IMPORT"] = "Импорт"
L["IMPORTED_X"] = "Импортированный \"%s\""
L["IN_COMBAT"] = "В бою"
L["INCOMPATIBLE_WIDGET_TYPE"] = "Несовместимый тип виджета"
L["INSERT"] = "Вставить"
L["INTERRUPTED"] = "Прерывание"
L["INVALID_ANCHOR_NAME"] = "Недопустимое имя привязки"
L["INVALID_DESIGN_NAME"] = "Недопустимое название дизайна"
L["INVALID_IMPORT"] = "Недопустимый импорт"
L["ITEM"] = "Предмет"
L["JOIN_THE_DISCORD"] = "Присоединиться к Discord"
L["KEYBINDING"] = "Привязка клавиш"
L["LAYOUT"] = "Расположение"
L["LEFT"] = "Слева"
L["LINK"] = "Ссылка"
L["LOCATION"] = "Местоположение"
L["MAELSTROM_WEAPON"] = "Оружие водоворота"
L["MAKE_NEW"] = "Создать новый"
L["MARCHING_ANTS_GLOW"] = "Свечение \"марширующих муравьёв\""
L["MOUNT"] = "Транспорт"
L["MOUSE_BUTTON_X"] = "M%s"
L["NAME"] = "Название"
L["NEW_DESIGN"] = "Новый стиль"
L["NEW_PROFILE_BLANK"] = "Новый профиль (пустой)"
L["NEW_PROFILE_CLONE"] = "Новый профиль (клонированный текущий)"
L["NO_TARGET"] = "Нет цели"
L["NO_TARGET_ASSIST"] = "Нет цели (Ассист)"
L["NO_TARGET_ATTACK"] = "Нет цели (Атака)"
L["NONE"] = "Нет"
L["NONE_SET"] = "Не установлено"
L["NOTHING"] = "Ничего"
L["NOTHING_IN_SLOT"] = "В слоте ничего нет"
L["OFF_MOUNT"] = "Без транспорта"
L["ON_MOUNT"] = "На транспорте"
L["OPEN_OPTIONS"] = "Открыть настройки"
L["OPTIONS"] = "Настройки"
L["OUT_OF_COMBAT"] = "Вне боя"
L["OVERWRITE"] = "Перезаписать"
L["OVERWRITE_CURRENT_PROFILE"] = "Перезаписать текущий профиль?"
L["PADDING"] = "Заполнение"
L["PARENT"] = "Родитель"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Вставьте сюда вашу строку импорта"
L["PIXEL_GLOW"] = "Пиксельное свечение"
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Пожалуйста, перезагрузите, чтобы Coolinator заработал. Причина (%s)"
L["POTION_EFFECT"] = "Эффект Зелья"
L["PRESET"] = "Шаблон"
L["PROFILE"] = "Профиль"
L["PROFILES"] = "Профили"
L["PVP"] = "PvP"
L["RAID"] = "Рейд"
L["READY_BORDER_COLOR"] = "Цвет рамки при готовности"
L["READY_FOREGROUND_COLOR"] = "Цвет готовности переднего плана"
L["REMAINING"] = "Оставшийся "
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Удалить интервалы между скрытыми значками"
L["RESET_SAVED_ANCHORS"] = "Сбросить сохраненные привязки"
L["REVERSE"] = "Реверс"
L["REVERSE_GLOW"] = "Обратное свечение"
L["RIGHT"] = "Справа"
L["SAFE"] = "Безопасный"
L["SAFE_COLOR"] = "Безопасный цвет"
L["SAFE_COLOR_FADED"] = "Блеклый безопасный цвет"
L["SAVE_ANCHOR"] = "Сохранить привязку"
L["SCALE"] = "Масштаб"
L["SELECT_GROUP"] = "Выберите группу"
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Для изменения настроек, требуется перезагрузка."
L["SHOW"] = "Показывать"
L["SHOW_FRACTIONS"] = "Показывать доли"
L["SHOW_GCD_SWIPE"] = "Показывать взмах GCD"
L["SHOW_ICON"] = "Показать иконку"
L["SHOW_KEYBINDINGS"] = "Показывать привязки клавиш"
L["SHOW_OUTLINE"] = "Показать контур"
L["SHOW_SHADOW"] = "Показать тень"
L["SHOW_SWIPE"] = "Показать взмах"
L["SHOW_TOOLTIPS"] = "Показывать всплывающие подсказки"
L["SITUATION"] = "Ситуация"
L["SKYRIDING_ZONE"] = "Зона скайрайдинга"
L["SLASH_DESIGN"] = "Стиль"
L["SLASH_DESIGN_HELP"] = "Вход в режим Coolinator Designer / выход из него"
L["SLASH_HELP"] = "Открыть настройки Coolinator"
L["SLASH_REGEN"] = "Активный"
L["SLASH_REGEN_HELP"] = "Начните заново работу над текущим персонажем и его дизайном"
L["SLASH_RESET"] = "Сброс"
L["SLASH_RESET_HELP"] = "Сбросьте все настройки Coolinator и перезагрузите"
L["SLASH_UNKNOWN_COMMAND"] = "Неизвестная команда '%s'"
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Несоответствие данных о специализации в Blizzard CDM"
L["SQUARE"] = "Квадратный"
L["STACK"] = "Стопка"
L["START"] = "Запустить"
L["STYLE"] = "Стиль"
L["SWIPE_COLOR"] = "Цвет взмаха"
L["TARGET"] = "Цель"
L["TEXTS"] = "Тексты"
L["TEXTURES"] = "Текстуры"
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Спасибо, что пользуетесь Coolinator. Подумайте о том, чтобы сделать пожертвование в поддержку разработки"
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "Это название стиля уже существует"
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "Это имя профиля уже существует"
L["THRESHOLDS"] = "Предел"
L["TIP_OF_THE_SPEAR"] = "Наконечник копья"
L["TO_OPEN_OPTIONS_X"] = "Доступ к настройкам с помощью /cooli"
L["TOP"] = "Вверх"
L["TOP_LEFT"] = "Вверху слева"
L["TOP_RIGHT"] = "Вверху справа"
L["TOTAL"] = "Итог"
L["TRANSPARENCY"] = "Прозрачность"
L["UNINTERRUPTABLE"] = "Бесперебойный"
L["UNLEARNED"] = "Необученный"
L["USE_BLIZZARD_WIDGETS"] = "Используйте виджеты Blizzard (без оформления)"
L["USE_MASQUE"] = "Использовать Masque"
L["USE_PERCENTAGE"] = "Использовать процент"
L["UTILITY"] = "Утилита"
L["VALUE"] = "Полезность"
L["VERSION_COLON_X"] = "Версия: %s"
L["VERTICAL"] = "Вертикальное"
L["VISIBILITY"] = "Видимость"
L["VISIBLE"] = "Видимость"
L["WARNING"] = "Предупреждение"
L["WARNING_COLOR"] = "Предупреждающий цвет"
L["WARNING_COLOR_FADED"] = "Блеклый предупреждающий цвет"
L["WHAT_TO_EXPORT"] = "Что экспортировать?"
L["WHEN_ACTIVE"] = "Когда активен"
L["WHEN_INACTIVE"] = "Когда в неактивном состоянии"
L["WHEN_ON_COOLDOWN"] = "Когда на перезарядке"
L["WHEN_READY"] = "Когда готов"
L["WIDTH"] = "Ширина"
L["WIDTH_RESTRICTION"] = "Ограничение по ширине"
L["WORLD"] = "Мир"


local L = Locales.ptBR
--[[Translation missing --]]
L["ABILITY"] = "Ability"
--[[Translation missing --]]
L["ABILITY_BAR"] = "Ability Bar"
--[[Translation missing --]]
L["ABILITY_CHARGE"] = "Ability Charge"
--[[Translation missing --]]
L["ABILITY_CHARGES"] = "Ability Charges"
--[[Translation missing --]]
L["ACTION"] = "Action"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
--[[Translation missing --]]
L["ADD"] = "Add"
--[[Translation missing --]]
L["ALIGN_X"] = "Align %s"
--[[Translation missing --]]
L["ALIGNMENT"] = "Alignment"
--[[Translation missing --]]
L["ARCANE_FLURRY"] = "Arcane Flurry"
--[[Translation missing --]]
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
--[[Translation missing --]]
L["AURA"] = "Aura"
--[[Translation missing --]]
L["AURA_BAR"] = "Aura Bar"
--[[Translation missing --]]
L["AURA_BARS"] = "Auras Bars"
--[[Translation missing --]]
L["AURAS"] = "Auras"
--[[Translation missing --]]
L["AUTO_SIZE"] = "Auto-size"
--[[Translation missing --]]
L["BACKGROUND"] = "Background"
--[[Translation missing --]]
L["BACKGROUND_COLOR"] = "Background color"
--[[Translation missing --]]
L["BAR"] = "Bar"
--[[Translation missing --]]
L["BARS"] = "Bars"
--[[Translation missing --]]
L["BEHAVIOUR"] = "Behaviour"
--[[Translation missing --]]
L["BLIZZARD"] = "Blizzard"
--[[Translation missing --]]
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Blizzard CDM aura icons/bars are missing, so Coolinator will malfunction. A reload is required"
--[[Translation missing --]]
L["BORDER"] = "Border"
--[[Translation missing --]]
L["BORDER_COLOR"] = "Border color"
--[[Translation missing --]]
L["BOTTOM"] = "Bottom"
--[[Translation missing --]]
L["BOTTOM_LEFT"] = "Bottom Left"
--[[Translation missing --]]
L["BOTTOM_RIGHT"] = "Bottom Right"
--[[Translation missing --]]
L["BY_PLUSMOUSE"] = "by plusmouse"
--[[Translation missing --]]
L["CAST"] = "Cast"
--[[Translation missing --]]
L["CAST_BAR"] = "Cast Bar"
--[[Translation missing --]]
L["CASTING"] = "Casting"
--[[Translation missing --]]
L["CENTER"] = "Center"
--[[Translation missing --]]
L["CENTER_HORIZONTAL"] = "Center Horizontal"
--[[Translation missing --]]
L["CENTER_VERTICAL"] = "Center Vertical"
--[[Translation missing --]]
L["CHANNELING"] = "Channeling"
--[[Translation missing --]]
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Choose a new design name"
--[[Translation missing --]]
L["CHOOSE_ABILITY"] = "Choose Ability"
--[[Translation missing --]]
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
--[[Translation missing --]]
L["CHOOSE_AURA"] = "Choose Aura"
--[[Translation missing --]]
L["CHOOSE_EQUIPMENT"] = "Choose Equipment"
--[[Translation missing --]]
L["CHOOSE_ITEM"] = "Choose Item"
--[[Translation missing --]]
L["CHOOSE_POTION_EFFECT"] = "Choose Potion Effect"
--[[Translation missing --]]
L["CLASS"] = "Class"
--[[Translation missing --]]
L["CLOSE_DESIGNER"] = "Close Designer"
--[[Translation missing --]]
L["COLOR"] = "Color"
--[[Translation missing --]]
L["COLORS"] = "Colors"
--[[Translation missing --]]
L["COMBAT"] = "Combat"
--[[Translation missing --]]
L["COMPLETED"] = "Completed"
--[[Translation missing --]]
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"
--[[Translation missing --]]
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
--[[Translation missing --]]
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
--[[Translation missing --]]
L["COOLDOWN"] = "Cooldown"
--[[Translation missing --]]
L["COOLINATOR"] = "Coolinator"
--[[Translation missing --]]
L["COUNT"] = "Count"
--[[Translation missing --]]
L["CREATE_PRESET"] = "Create Preset"
--[[Translation missing --]]
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
--[[Translation missing --]]
L["CUSTOM"] = "Custom"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR"] = "Customise Coolinator"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR_X"] = "Customise Coolinator: %s"
--[[Translation missing --]]
L["DANGER"] = "Danger"
--[[Translation missing --]]
L["DANGER_COLOR"] = "Danger color"
--[[Translation missing --]]
L["DANGER_COLOR_FADED"] = "Danger color faded"
--[[Translation missing --]]
L["DEFAULT"] = "Default"
--[[Translation missing --]]
L["DELETE"] = "Delete"
--[[Translation missing --]]
L["DELVE"] = "Delve"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
--[[Translation missing --]]
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
--[[Translation missing --]]
L["DESIGN"] = "Design"
--[[Translation missing --]]
L["DESIGNER"] = "Designer"
--[[Translation missing --]]
L["DETACH_PRESET"] = "Detach Preset"
--[[Translation missing --]]
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
--[[Translation missing --]]
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
--[[Translation missing --]]
L["DISPLAY"] = "Display"
--[[Translation missing --]]
L["DONATE"] = "Donate"
--[[Translation missing --]]
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Due to aura bars changing a reload is required for Coolinator function"
--[[Translation missing --]]
L["DUNGEON"] = "Dungeon"
--[[Translation missing --]]
L["DURATION"] = "Duration"
--[[Translation missing --]]
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
--[[Translation missing --]]
L["ELAPSED"] = "Elapsed"
--[[Translation missing --]]
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
--[[Translation missing --]]
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
--[[Translation missing --]]
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
--[[Translation missing --]]
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
--[[Translation missing --]]
L["ENABLE"] = "Enable"
--[[Translation missing --]]
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
--[[Translation missing --]]
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_PRESET_NAME"] = "Enter preset name:"
--[[Translation missing --]]
L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
--[[Translation missing --]]
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
--[[Translation missing --]]
L["EQUIPMENT"] = "Equipment"
--[[Translation missing --]]
L["ESSENTIAL"] = "Essential"
--[[Translation missing --]]
L["EXPORT"] = "Export"
--[[Translation missing --]]
L["FADE"] = "Fade"
--[[Translation missing --]]
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
--[[Translation missing --]]
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
--[[Translation missing --]]
L["FONT"] = "Font"
--[[Translation missing --]]
L["FONT_SIZE"] = "Font size"
--[[Translation missing --]]
L["FOREGROUND"] = "Foreground"
--[[Translation missing --]]
L["FOREGROUND_COLOR"] = "Foreground color"
--[[Translation missing --]]
L["GENERAL"] = "General"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
--[[Translation missing --]]
L["GROUP"] = "Group"
--[[Translation missing --]]
L["GROW_FROM"] = "Grow from"
--[[Translation missing --]]
L["HAS_TARGET"] = "Has Target"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
--[[Translation missing --]]
L["HEIGHT"] = "Height"
--[[Translation missing --]]
L["HIDE"] = "Hide"
--[[Translation missing --]]
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
--[[Translation missing --]]
L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
--[[Translation missing --]]
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
--[[Translation missing --]]
L["HIDE_WHEN_READY"] = "Hide when ready"
--[[Translation missing --]]
L["HORIZONTAL"] = "Horizontal"
--[[Translation missing --]]
L["ICICLES"] = "Icicles"
--[[Translation missing --]]
L["ICON"] = "Icon"
--[[Translation missing --]]
L["ICON_POSITION"] = "Icon position"
--[[Translation missing --]]
L["IMPORT"] = "Import"
--[[Translation missing --]]
L["IMPORTED_X"] = "Imported \"%s\""
--[[Translation missing --]]
L["IN_COMBAT"] = "In Combat"
--[[Translation missing --]]
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
--[[Translation missing --]]
L["INSERT"] = "Insert"
--[[Translation missing --]]
L["INTERRUPTED"] = "Interrupted"
--[[Translation missing --]]
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
--[[Translation missing --]]
L["INVALID_DESIGN_NAME"] = "Invalid design name"
--[[Translation missing --]]
L["INVALID_IMPORT"] = "Invalid import"
--[[Translation missing --]]
L["ITEM"] = "Item"
--[[Translation missing --]]
L["JOIN_THE_DISCORD"] = "Join the Discord"
--[[Translation missing --]]
L["KEYBINDING"] = "Keybinding"
--[[Translation missing --]]
L["LAYOUT"] = "Layout"
--[[Translation missing --]]
L["LEFT"] = "Left"
--[[Translation missing --]]
L["LINK"] = "Link"
--[[Translation missing --]]
L["LOCATION"] = "Location"
--[[Translation missing --]]
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
--[[Translation missing --]]
L["MAKE_NEW"] = "Make new"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
--[[Translation missing --]]
L["MOUNT"] = "Mount"
--[[Translation missing --]]
L["MOUSE_BUTTON_X"] = "M%s"
--[[Translation missing --]]
L["NAME"] = "Name"
--[[Translation missing --]]
L["NEW_DESIGN"] = "New Design"
--[[Translation missing --]]
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
--[[Translation missing --]]
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
--[[Translation missing --]]
L["NO_TARGET"] = "No Target"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
--[[Translation missing --]]
L["NONE"] = "None"
--[[Translation missing --]]
L["NONE_SET"] = "None set"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
--[[Translation missing --]]
L["NOTHING_IN_SLOT"] = "Nothing in slot"
--[[Translation missing --]]
L["OFF_MOUNT"] = "Off Mount"
--[[Translation missing --]]
L["ON_MOUNT"] = "On Mount"
--[[Translation missing --]]
L["OPEN_OPTIONS"] = "Open Options"
--[[Translation missing --]]
L["OPTIONS"] = "Options"
--[[Translation missing --]]
L["OUT_OF_COMBAT"] = "Out of Combat"
--[[Translation missing --]]
L["OVERWRITE"] = "Overwrite"
--[[Translation missing --]]
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
--[[Translation missing --]]
L["PADDING"] = "Padding"
--[[Translation missing --]]
L["PARENT"] = "Parent"
--[[Translation missing --]]
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
--[[Translation missing --]]
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Please reload to get Coolinator working. Reason (%s)"
--[[Translation missing --]]
L["POTION_EFFECT"] = "Potion Effect"
--[[Translation missing --]]
L["PRESET"] = "Preset"
--[[Translation missing --]]
L["PROFILE"] = "Profile"
--[[Translation missing --]]
L["PROFILES"] = "Profiles"
--[[Translation missing --]]
L["PVP"] = "PvP"
--[[Translation missing --]]
L["RAID"] = "Raid"
--[[Translation missing --]]
L["READY_BORDER_COLOR"] = "Ready border color"
--[[Translation missing --]]
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
--[[Translation missing --]]
L["REMAINING"] = "Remaining"
--[[Translation missing --]]
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
--[[Translation missing --]]
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
--[[Translation missing --]]
L["REVERSE"] = "Reverse"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
--[[Translation missing --]]
L["RIGHT"] = "Right"
--[[Translation missing --]]
L["SAFE"] = "Safe"
--[[Translation missing --]]
L["SAFE_COLOR"] = "Safe color"
--[[Translation missing --]]
L["SAFE_COLOR_FADED"] = "Safe color faded"
--[[Translation missing --]]
L["SAVE_ANCHOR"] = "Save anchor"
--[[Translation missing --]]
L["SCALE"] = "Scale"
--[[Translation missing --]]
L["SELECT_GROUP"] = "Select Group"
--[[Translation missing --]]
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."
--[[Translation missing --]]
L["SHOW"] = "Show"
--[[Translation missing --]]
L["SHOW_FRACTIONS"] = "Show fractions"
--[[Translation missing --]]
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
--[[Translation missing --]]
L["SHOW_ICON"] = "Show icon"
--[[Translation missing --]]
L["SHOW_KEYBINDINGS"] = "Show keybindings"
--[[Translation missing --]]
L["SHOW_OUTLINE"] = "Show outline"
--[[Translation missing --]]
L["SHOW_SHADOW"] = "Show shadow"
--[[Translation missing --]]
L["SHOW_SWIPE"] = "Show swipe"
--[[Translation missing --]]
L["SHOW_TOOLTIPS"] = "Show tooltips"
--[[Translation missing --]]
L["SITUATION"] = "Situation"
--[[Translation missing --]]
L["SKYRIDING_ZONE"] = "Skyriding Zone"
--[[Translation missing --]]
L["SLASH_DESIGN"] = "design"
--[[Translation missing --]]
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
--[[Translation missing --]]
L["SLASH_HELP"] = "Open the Coolinator settings."
--[[Translation missing --]]
L["SLASH_REGEN"] = "regen"
--[[Translation missing --]]
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
--[[Translation missing --]]
L["SLASH_RESET"] = "reset"
--[[Translation missing --]]
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
--[[Translation missing --]]
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
--[[Translation missing --]]
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"
--[[Translation missing --]]
L["SQUARE"] = "Square"
--[[Translation missing --]]
L["STACK"] = "Stack"
--[[Translation missing --]]
L["START"] = "Start"
--[[Translation missing --]]
L["STYLE"] = "Style"
--[[Translation missing --]]
L["SWIPE_COLOR"] = "Swipe color"
--[[Translation missing --]]
L["TARGET"] = "Target"
--[[Translation missing --]]
L["TEXTS"] = "Texts"
--[[Translation missing --]]
L["TEXTURES"] = "Textures"
--[[Translation missing --]]
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"
--[[Translation missing --]]
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
--[[Translation missing --]]
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
--[[Translation missing --]]
L["THRESHOLDS"] = "Thresholds"
--[[Translation missing --]]
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
--[[Translation missing --]]
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
--[[Translation missing --]]
L["TOP"] = "Top"
--[[Translation missing --]]
L["TOP_LEFT"] = "Top Left"
--[[Translation missing --]]
L["TOP_RIGHT"] = "Top Right"
--[[Translation missing --]]
L["TOTAL"] = "Total"
--[[Translation missing --]]
L["TRANSPARENCY"] = "Transparency"
--[[Translation missing --]]
L["UNINTERRUPTABLE"] = "Uninterruptable"
--[[Translation missing --]]
L["UNLEARNED"] = "Unlearned"
--[[Translation missing --]]
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
--[[Translation missing --]]
L["USE_MASQUE"] = "Use Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
--[[Translation missing --]]
L["UTILITY"] = "Utility"
--[[Translation missing --]]
L["VALUE"] = "Value"
--[[Translation missing --]]
L["VERSION_COLON_X"] = "Version: %s"
--[[Translation missing --]]
L["VERTICAL"] = "Vertical"
--[[Translation missing --]]
L["VISIBILITY"] = "Visibility"
--[[Translation missing --]]
L["VISIBLE"] = "Visible"
--[[Translation missing --]]
L["WARNING"] = "Warning"
--[[Translation missing --]]
L["WARNING_COLOR"] = "Warning color"
--[[Translation missing --]]
L["WARNING_COLOR_FADED"] = "Warning color faded"
--[[Translation missing --]]
L["WHAT_TO_EXPORT"] = "What to export?"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
--[[Translation missing --]]
L["WIDTH"] = "Width"
--[[Translation missing --]]
L["WIDTH_RESTRICTION"] = "Width restriction"
--[[Translation missing --]]
L["WORLD"] = "World"


local L = Locales.esES
--[[Translation missing --]]
L["ABILITY"] = "Ability"
--[[Translation missing --]]
L["ABILITY_BAR"] = "Ability Bar"
--[[Translation missing --]]
L["ABILITY_CHARGE"] = "Ability Charge"
--[[Translation missing --]]
L["ABILITY_CHARGES"] = "Ability Charges"
--[[Translation missing --]]
L["ACTION"] = "Action"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
--[[Translation missing --]]
L["ADD"] = "Add"
--[[Translation missing --]]
L["ALIGN_X"] = "Align %s"
--[[Translation missing --]]
L["ALIGNMENT"] = "Alignment"
--[[Translation missing --]]
L["ARCANE_FLURRY"] = "Arcane Flurry"
--[[Translation missing --]]
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
--[[Translation missing --]]
L["AURA"] = "Aura"
--[[Translation missing --]]
L["AURA_BAR"] = "Aura Bar"
--[[Translation missing --]]
L["AURA_BARS"] = "Auras Bars"
--[[Translation missing --]]
L["AURAS"] = "Auras"
--[[Translation missing --]]
L["AUTO_SIZE"] = "Auto-size"
--[[Translation missing --]]
L["BACKGROUND"] = "Background"
--[[Translation missing --]]
L["BACKGROUND_COLOR"] = "Background color"
--[[Translation missing --]]
L["BAR"] = "Bar"
--[[Translation missing --]]
L["BARS"] = "Bars"
--[[Translation missing --]]
L["BEHAVIOUR"] = "Behaviour"
--[[Translation missing --]]
L["BLIZZARD"] = "Blizzard"
--[[Translation missing --]]
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Blizzard CDM aura icons/bars are missing, so Coolinator will malfunction. A reload is required"
--[[Translation missing --]]
L["BORDER"] = "Border"
--[[Translation missing --]]
L["BORDER_COLOR"] = "Border color"
--[[Translation missing --]]
L["BOTTOM"] = "Bottom"
--[[Translation missing --]]
L["BOTTOM_LEFT"] = "Bottom Left"
--[[Translation missing --]]
L["BOTTOM_RIGHT"] = "Bottom Right"
--[[Translation missing --]]
L["BY_PLUSMOUSE"] = "by plusmouse"
--[[Translation missing --]]
L["CAST"] = "Cast"
--[[Translation missing --]]
L["CAST_BAR"] = "Cast Bar"
--[[Translation missing --]]
L["CASTING"] = "Casting"
--[[Translation missing --]]
L["CENTER"] = "Center"
--[[Translation missing --]]
L["CENTER_HORIZONTAL"] = "Center Horizontal"
--[[Translation missing --]]
L["CENTER_VERTICAL"] = "Center Vertical"
--[[Translation missing --]]
L["CHANNELING"] = "Channeling"
--[[Translation missing --]]
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Choose a new design name"
--[[Translation missing --]]
L["CHOOSE_ABILITY"] = "Choose Ability"
--[[Translation missing --]]
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
--[[Translation missing --]]
L["CHOOSE_AURA"] = "Choose Aura"
--[[Translation missing --]]
L["CHOOSE_EQUIPMENT"] = "Choose Equipment"
--[[Translation missing --]]
L["CHOOSE_ITEM"] = "Choose Item"
--[[Translation missing --]]
L["CHOOSE_POTION_EFFECT"] = "Choose Potion Effect"
--[[Translation missing --]]
L["CLASS"] = "Class"
--[[Translation missing --]]
L["CLOSE_DESIGNER"] = "Close Designer"
--[[Translation missing --]]
L["COLOR"] = "Color"
--[[Translation missing --]]
L["COLORS"] = "Colors"
--[[Translation missing --]]
L["COMBAT"] = "Combat"
--[[Translation missing --]]
L["COMPLETED"] = "Completed"
--[[Translation missing --]]
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"
--[[Translation missing --]]
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
--[[Translation missing --]]
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
--[[Translation missing --]]
L["COOLDOWN"] = "Cooldown"
--[[Translation missing --]]
L["COOLINATOR"] = "Coolinator"
--[[Translation missing --]]
L["COUNT"] = "Count"
--[[Translation missing --]]
L["CREATE_PRESET"] = "Create Preset"
--[[Translation missing --]]
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
--[[Translation missing --]]
L["CUSTOM"] = "Custom"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR"] = "Customise Coolinator"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR_X"] = "Customise Coolinator: %s"
--[[Translation missing --]]
L["DANGER"] = "Danger"
--[[Translation missing --]]
L["DANGER_COLOR"] = "Danger color"
--[[Translation missing --]]
L["DANGER_COLOR_FADED"] = "Danger color faded"
--[[Translation missing --]]
L["DEFAULT"] = "Default"
--[[Translation missing --]]
L["DELETE"] = "Delete"
--[[Translation missing --]]
L["DELVE"] = "Delve"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
--[[Translation missing --]]
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
--[[Translation missing --]]
L["DESIGN"] = "Design"
--[[Translation missing --]]
L["DESIGNER"] = "Designer"
--[[Translation missing --]]
L["DETACH_PRESET"] = "Detach Preset"
--[[Translation missing --]]
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
--[[Translation missing --]]
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
--[[Translation missing --]]
L["DISPLAY"] = "Display"
--[[Translation missing --]]
L["DONATE"] = "Donate"
--[[Translation missing --]]
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Due to aura bars changing a reload is required for Coolinator function"
--[[Translation missing --]]
L["DUNGEON"] = "Dungeon"
--[[Translation missing --]]
L["DURATION"] = "Duration"
--[[Translation missing --]]
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
--[[Translation missing --]]
L["ELAPSED"] = "Elapsed"
--[[Translation missing --]]
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
--[[Translation missing --]]
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
--[[Translation missing --]]
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
--[[Translation missing --]]
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
--[[Translation missing --]]
L["ENABLE"] = "Enable"
--[[Translation missing --]]
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
--[[Translation missing --]]
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_PRESET_NAME"] = "Enter preset name:"
--[[Translation missing --]]
L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
--[[Translation missing --]]
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
--[[Translation missing --]]
L["EQUIPMENT"] = "Equipment"
--[[Translation missing --]]
L["ESSENTIAL"] = "Essential"
--[[Translation missing --]]
L["EXPORT"] = "Export"
--[[Translation missing --]]
L["FADE"] = "Fade"
--[[Translation missing --]]
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
--[[Translation missing --]]
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
--[[Translation missing --]]
L["FONT"] = "Font"
--[[Translation missing --]]
L["FONT_SIZE"] = "Font size"
--[[Translation missing --]]
L["FOREGROUND"] = "Foreground"
--[[Translation missing --]]
L["FOREGROUND_COLOR"] = "Foreground color"
--[[Translation missing --]]
L["GENERAL"] = "General"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
--[[Translation missing --]]
L["GROUP"] = "Group"
--[[Translation missing --]]
L["GROW_FROM"] = "Grow from"
--[[Translation missing --]]
L["HAS_TARGET"] = "Has Target"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
--[[Translation missing --]]
L["HEIGHT"] = "Height"
--[[Translation missing --]]
L["HIDE"] = "Hide"
--[[Translation missing --]]
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
--[[Translation missing --]]
L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
--[[Translation missing --]]
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
--[[Translation missing --]]
L["HIDE_WHEN_READY"] = "Hide when ready"
--[[Translation missing --]]
L["HORIZONTAL"] = "Horizontal"
--[[Translation missing --]]
L["ICICLES"] = "Icicles"
--[[Translation missing --]]
L["ICON"] = "Icon"
--[[Translation missing --]]
L["ICON_POSITION"] = "Icon position"
--[[Translation missing --]]
L["IMPORT"] = "Import"
--[[Translation missing --]]
L["IMPORTED_X"] = "Imported \"%s\""
--[[Translation missing --]]
L["IN_COMBAT"] = "In Combat"
--[[Translation missing --]]
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
--[[Translation missing --]]
L["INSERT"] = "Insert"
--[[Translation missing --]]
L["INTERRUPTED"] = "Interrupted"
--[[Translation missing --]]
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
--[[Translation missing --]]
L["INVALID_DESIGN_NAME"] = "Invalid design name"
--[[Translation missing --]]
L["INVALID_IMPORT"] = "Invalid import"
--[[Translation missing --]]
L["ITEM"] = "Item"
--[[Translation missing --]]
L["JOIN_THE_DISCORD"] = "Join the Discord"
--[[Translation missing --]]
L["KEYBINDING"] = "Keybinding"
--[[Translation missing --]]
L["LAYOUT"] = "Layout"
--[[Translation missing --]]
L["LEFT"] = "Left"
--[[Translation missing --]]
L["LINK"] = "Link"
--[[Translation missing --]]
L["LOCATION"] = "Location"
--[[Translation missing --]]
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
--[[Translation missing --]]
L["MAKE_NEW"] = "Make new"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
--[[Translation missing --]]
L["MOUNT"] = "Mount"
--[[Translation missing --]]
L["MOUSE_BUTTON_X"] = "M%s"
--[[Translation missing --]]
L["NAME"] = "Name"
--[[Translation missing --]]
L["NEW_DESIGN"] = "New Design"
--[[Translation missing --]]
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
--[[Translation missing --]]
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
--[[Translation missing --]]
L["NO_TARGET"] = "No Target"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
--[[Translation missing --]]
L["NONE"] = "None"
--[[Translation missing --]]
L["NONE_SET"] = "None set"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
--[[Translation missing --]]
L["NOTHING_IN_SLOT"] = "Nothing in slot"
--[[Translation missing --]]
L["OFF_MOUNT"] = "Off Mount"
--[[Translation missing --]]
L["ON_MOUNT"] = "On Mount"
--[[Translation missing --]]
L["OPEN_OPTIONS"] = "Open Options"
--[[Translation missing --]]
L["OPTIONS"] = "Options"
--[[Translation missing --]]
L["OUT_OF_COMBAT"] = "Out of Combat"
--[[Translation missing --]]
L["OVERWRITE"] = "Overwrite"
--[[Translation missing --]]
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
--[[Translation missing --]]
L["PADDING"] = "Padding"
--[[Translation missing --]]
L["PARENT"] = "Parent"
--[[Translation missing --]]
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
--[[Translation missing --]]
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Please reload to get Coolinator working. Reason (%s)"
--[[Translation missing --]]
L["POTION_EFFECT"] = "Potion Effect"
--[[Translation missing --]]
L["PRESET"] = "Preset"
--[[Translation missing --]]
L["PROFILE"] = "Profile"
--[[Translation missing --]]
L["PROFILES"] = "Profiles"
--[[Translation missing --]]
L["PVP"] = "PvP"
--[[Translation missing --]]
L["RAID"] = "Raid"
--[[Translation missing --]]
L["READY_BORDER_COLOR"] = "Ready border color"
--[[Translation missing --]]
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
--[[Translation missing --]]
L["REMAINING"] = "Remaining"
--[[Translation missing --]]
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
--[[Translation missing --]]
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
--[[Translation missing --]]
L["REVERSE"] = "Reverse"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
--[[Translation missing --]]
L["RIGHT"] = "Right"
--[[Translation missing --]]
L["SAFE"] = "Safe"
--[[Translation missing --]]
L["SAFE_COLOR"] = "Safe color"
--[[Translation missing --]]
L["SAFE_COLOR_FADED"] = "Safe color faded"
--[[Translation missing --]]
L["SAVE_ANCHOR"] = "Save anchor"
--[[Translation missing --]]
L["SCALE"] = "Scale"
--[[Translation missing --]]
L["SELECT_GROUP"] = "Select Group"
--[[Translation missing --]]
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."
--[[Translation missing --]]
L["SHOW"] = "Show"
--[[Translation missing --]]
L["SHOW_FRACTIONS"] = "Show fractions"
--[[Translation missing --]]
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
--[[Translation missing --]]
L["SHOW_ICON"] = "Show icon"
--[[Translation missing --]]
L["SHOW_KEYBINDINGS"] = "Show keybindings"
--[[Translation missing --]]
L["SHOW_OUTLINE"] = "Show outline"
--[[Translation missing --]]
L["SHOW_SHADOW"] = "Show shadow"
--[[Translation missing --]]
L["SHOW_SWIPE"] = "Show swipe"
--[[Translation missing --]]
L["SHOW_TOOLTIPS"] = "Show tooltips"
--[[Translation missing --]]
L["SITUATION"] = "Situation"
--[[Translation missing --]]
L["SKYRIDING_ZONE"] = "Skyriding Zone"
--[[Translation missing --]]
L["SLASH_DESIGN"] = "design"
--[[Translation missing --]]
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
--[[Translation missing --]]
L["SLASH_HELP"] = "Open the Coolinator settings."
--[[Translation missing --]]
L["SLASH_REGEN"] = "regen"
--[[Translation missing --]]
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
--[[Translation missing --]]
L["SLASH_RESET"] = "reset"
--[[Translation missing --]]
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
--[[Translation missing --]]
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
--[[Translation missing --]]
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"
--[[Translation missing --]]
L["SQUARE"] = "Square"
--[[Translation missing --]]
L["STACK"] = "Stack"
--[[Translation missing --]]
L["START"] = "Start"
--[[Translation missing --]]
L["STYLE"] = "Style"
--[[Translation missing --]]
L["SWIPE_COLOR"] = "Swipe color"
--[[Translation missing --]]
L["TARGET"] = "Target"
--[[Translation missing --]]
L["TEXTS"] = "Texts"
--[[Translation missing --]]
L["TEXTURES"] = "Textures"
--[[Translation missing --]]
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"
--[[Translation missing --]]
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
--[[Translation missing --]]
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
--[[Translation missing --]]
L["THRESHOLDS"] = "Thresholds"
--[[Translation missing --]]
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
--[[Translation missing --]]
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
--[[Translation missing --]]
L["TOP"] = "Top"
--[[Translation missing --]]
L["TOP_LEFT"] = "Top Left"
--[[Translation missing --]]
L["TOP_RIGHT"] = "Top Right"
--[[Translation missing --]]
L["TOTAL"] = "Total"
--[[Translation missing --]]
L["TRANSPARENCY"] = "Transparency"
--[[Translation missing --]]
L["UNINTERRUPTABLE"] = "Uninterruptable"
--[[Translation missing --]]
L["UNLEARNED"] = "Unlearned"
--[[Translation missing --]]
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
--[[Translation missing --]]
L["USE_MASQUE"] = "Use Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
--[[Translation missing --]]
L["UTILITY"] = "Utility"
--[[Translation missing --]]
L["VALUE"] = "Value"
--[[Translation missing --]]
L["VERSION_COLON_X"] = "Version: %s"
--[[Translation missing --]]
L["VERTICAL"] = "Vertical"
--[[Translation missing --]]
L["VISIBILITY"] = "Visibility"
--[[Translation missing --]]
L["VISIBLE"] = "Visible"
--[[Translation missing --]]
L["WARNING"] = "Warning"
--[[Translation missing --]]
L["WARNING_COLOR"] = "Warning color"
--[[Translation missing --]]
L["WARNING_COLOR_FADED"] = "Warning color faded"
--[[Translation missing --]]
L["WHAT_TO_EXPORT"] = "What to export?"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
--[[Translation missing --]]
L["WIDTH"] = "Width"
--[[Translation missing --]]
L["WIDTH_RESTRICTION"] = "Width restriction"
--[[Translation missing --]]
L["WORLD"] = "World"


local L = Locales.esMX
--[[Translation missing --]]
L["ABILITY"] = "Ability"
--[[Translation missing --]]
L["ABILITY_BAR"] = "Ability Bar"
--[[Translation missing --]]
L["ABILITY_CHARGE"] = "Ability Charge"
--[[Translation missing --]]
L["ABILITY_CHARGES"] = "Ability Charges"
--[[Translation missing --]]
L["ACTION"] = "Action"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
--[[Translation missing --]]
L["ADD"] = "Add"
--[[Translation missing --]]
L["ALIGN_X"] = "Align %s"
--[[Translation missing --]]
L["ALIGNMENT"] = "Alignment"
--[[Translation missing --]]
L["ARCANE_FLURRY"] = "Arcane Flurry"
--[[Translation missing --]]
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
--[[Translation missing --]]
L["AURA"] = "Aura"
--[[Translation missing --]]
L["AURA_BAR"] = "Aura Bar"
--[[Translation missing --]]
L["AURA_BARS"] = "Auras Bars"
--[[Translation missing --]]
L["AURAS"] = "Auras"
--[[Translation missing --]]
L["AUTO_SIZE"] = "Auto-size"
--[[Translation missing --]]
L["BACKGROUND"] = "Background"
--[[Translation missing --]]
L["BACKGROUND_COLOR"] = "Background color"
--[[Translation missing --]]
L["BAR"] = "Bar"
--[[Translation missing --]]
L["BARS"] = "Bars"
--[[Translation missing --]]
L["BEHAVIOUR"] = "Behaviour"
--[[Translation missing --]]
L["BLIZZARD"] = "Blizzard"
--[[Translation missing --]]
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Blizzard CDM aura icons/bars are missing, so Coolinator will malfunction. A reload is required"
--[[Translation missing --]]
L["BORDER"] = "Border"
--[[Translation missing --]]
L["BORDER_COLOR"] = "Border color"
--[[Translation missing --]]
L["BOTTOM"] = "Bottom"
--[[Translation missing --]]
L["BOTTOM_LEFT"] = "Bottom Left"
--[[Translation missing --]]
L["BOTTOM_RIGHT"] = "Bottom Right"
--[[Translation missing --]]
L["BY_PLUSMOUSE"] = "by plusmouse"
--[[Translation missing --]]
L["CAST"] = "Cast"
--[[Translation missing --]]
L["CAST_BAR"] = "Cast Bar"
--[[Translation missing --]]
L["CASTING"] = "Casting"
--[[Translation missing --]]
L["CENTER"] = "Center"
--[[Translation missing --]]
L["CENTER_HORIZONTAL"] = "Center Horizontal"
--[[Translation missing --]]
L["CENTER_VERTICAL"] = "Center Vertical"
--[[Translation missing --]]
L["CHANNELING"] = "Channeling"
--[[Translation missing --]]
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Choose a new design name"
--[[Translation missing --]]
L["CHOOSE_ABILITY"] = "Choose Ability"
--[[Translation missing --]]
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
--[[Translation missing --]]
L["CHOOSE_AURA"] = "Choose Aura"
--[[Translation missing --]]
L["CHOOSE_EQUIPMENT"] = "Choose Equipment"
--[[Translation missing --]]
L["CHOOSE_ITEM"] = "Choose Item"
--[[Translation missing --]]
L["CHOOSE_POTION_EFFECT"] = "Choose Potion Effect"
--[[Translation missing --]]
L["CLASS"] = "Class"
--[[Translation missing --]]
L["CLOSE_DESIGNER"] = "Close Designer"
--[[Translation missing --]]
L["COLOR"] = "Color"
--[[Translation missing --]]
L["COLORS"] = "Colors"
--[[Translation missing --]]
L["COMBAT"] = "Combat"
--[[Translation missing --]]
L["COMPLETED"] = "Completed"
--[[Translation missing --]]
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"
--[[Translation missing --]]
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
--[[Translation missing --]]
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
--[[Translation missing --]]
L["COOLDOWN"] = "Cooldown"
--[[Translation missing --]]
L["COOLINATOR"] = "Coolinator"
--[[Translation missing --]]
L["COUNT"] = "Count"
--[[Translation missing --]]
L["CREATE_PRESET"] = "Create Preset"
--[[Translation missing --]]
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
--[[Translation missing --]]
L["CUSTOM"] = "Custom"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR"] = "Customise Coolinator"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR_X"] = "Customise Coolinator: %s"
--[[Translation missing --]]
L["DANGER"] = "Danger"
--[[Translation missing --]]
L["DANGER_COLOR"] = "Danger color"
--[[Translation missing --]]
L["DANGER_COLOR_FADED"] = "Danger color faded"
--[[Translation missing --]]
L["DEFAULT"] = "Default"
--[[Translation missing --]]
L["DELETE"] = "Delete"
--[[Translation missing --]]
L["DELVE"] = "Delve"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
--[[Translation missing --]]
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
--[[Translation missing --]]
L["DESIGN"] = "Design"
--[[Translation missing --]]
L["DESIGNER"] = "Designer"
--[[Translation missing --]]
L["DETACH_PRESET"] = "Detach Preset"
--[[Translation missing --]]
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
--[[Translation missing --]]
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
--[[Translation missing --]]
L["DISPLAY"] = "Display"
--[[Translation missing --]]
L["DONATE"] = "Donate"
--[[Translation missing --]]
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Due to aura bars changing a reload is required for Coolinator function"
--[[Translation missing --]]
L["DUNGEON"] = "Dungeon"
--[[Translation missing --]]
L["DURATION"] = "Duration"
--[[Translation missing --]]
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
--[[Translation missing --]]
L["ELAPSED"] = "Elapsed"
--[[Translation missing --]]
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
--[[Translation missing --]]
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
--[[Translation missing --]]
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
--[[Translation missing --]]
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
--[[Translation missing --]]
L["ENABLE"] = "Enable"
--[[Translation missing --]]
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
--[[Translation missing --]]
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_PRESET_NAME"] = "Enter preset name:"
--[[Translation missing --]]
L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
--[[Translation missing --]]
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
--[[Translation missing --]]
L["EQUIPMENT"] = "Equipment"
--[[Translation missing --]]
L["ESSENTIAL"] = "Essential"
--[[Translation missing --]]
L["EXPORT"] = "Export"
--[[Translation missing --]]
L["FADE"] = "Fade"
--[[Translation missing --]]
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
--[[Translation missing --]]
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
--[[Translation missing --]]
L["FONT"] = "Font"
--[[Translation missing --]]
L["FONT_SIZE"] = "Font size"
--[[Translation missing --]]
L["FOREGROUND"] = "Foreground"
--[[Translation missing --]]
L["FOREGROUND_COLOR"] = "Foreground color"
--[[Translation missing --]]
L["GENERAL"] = "General"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
--[[Translation missing --]]
L["GROUP"] = "Group"
--[[Translation missing --]]
L["GROW_FROM"] = "Grow from"
--[[Translation missing --]]
L["HAS_TARGET"] = "Has Target"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
--[[Translation missing --]]
L["HEIGHT"] = "Height"
--[[Translation missing --]]
L["HIDE"] = "Hide"
--[[Translation missing --]]
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
--[[Translation missing --]]
L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
--[[Translation missing --]]
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
--[[Translation missing --]]
L["HIDE_WHEN_READY"] = "Hide when ready"
--[[Translation missing --]]
L["HORIZONTAL"] = "Horizontal"
--[[Translation missing --]]
L["ICICLES"] = "Icicles"
--[[Translation missing --]]
L["ICON"] = "Icon"
--[[Translation missing --]]
L["ICON_POSITION"] = "Icon position"
--[[Translation missing --]]
L["IMPORT"] = "Import"
--[[Translation missing --]]
L["IMPORTED_X"] = "Imported \"%s\""
--[[Translation missing --]]
L["IN_COMBAT"] = "In Combat"
--[[Translation missing --]]
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
--[[Translation missing --]]
L["INSERT"] = "Insert"
--[[Translation missing --]]
L["INTERRUPTED"] = "Interrupted"
--[[Translation missing --]]
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
--[[Translation missing --]]
L["INVALID_DESIGN_NAME"] = "Invalid design name"
--[[Translation missing --]]
L["INVALID_IMPORT"] = "Invalid import"
--[[Translation missing --]]
L["ITEM"] = "Item"
--[[Translation missing --]]
L["JOIN_THE_DISCORD"] = "Join the Discord"
--[[Translation missing --]]
L["KEYBINDING"] = "Keybinding"
--[[Translation missing --]]
L["LAYOUT"] = "Layout"
--[[Translation missing --]]
L["LEFT"] = "Left"
--[[Translation missing --]]
L["LINK"] = "Link"
--[[Translation missing --]]
L["LOCATION"] = "Location"
--[[Translation missing --]]
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
--[[Translation missing --]]
L["MAKE_NEW"] = "Make new"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
--[[Translation missing --]]
L["MOUNT"] = "Mount"
--[[Translation missing --]]
L["MOUSE_BUTTON_X"] = "M%s"
--[[Translation missing --]]
L["NAME"] = "Name"
--[[Translation missing --]]
L["NEW_DESIGN"] = "New Design"
--[[Translation missing --]]
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
--[[Translation missing --]]
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
--[[Translation missing --]]
L["NO_TARGET"] = "No Target"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
--[[Translation missing --]]
L["NONE"] = "None"
--[[Translation missing --]]
L["NONE_SET"] = "None set"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
--[[Translation missing --]]
L["NOTHING_IN_SLOT"] = "Nothing in slot"
--[[Translation missing --]]
L["OFF_MOUNT"] = "Off Mount"
--[[Translation missing --]]
L["ON_MOUNT"] = "On Mount"
--[[Translation missing --]]
L["OPEN_OPTIONS"] = "Open Options"
--[[Translation missing --]]
L["OPTIONS"] = "Options"
--[[Translation missing --]]
L["OUT_OF_COMBAT"] = "Out of Combat"
--[[Translation missing --]]
L["OVERWRITE"] = "Overwrite"
--[[Translation missing --]]
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
--[[Translation missing --]]
L["PADDING"] = "Padding"
--[[Translation missing --]]
L["PARENT"] = "Parent"
--[[Translation missing --]]
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
--[[Translation missing --]]
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Please reload to get Coolinator working. Reason (%s)"
--[[Translation missing --]]
L["POTION_EFFECT"] = "Potion Effect"
--[[Translation missing --]]
L["PRESET"] = "Preset"
--[[Translation missing --]]
L["PROFILE"] = "Profile"
--[[Translation missing --]]
L["PROFILES"] = "Profiles"
--[[Translation missing --]]
L["PVP"] = "PvP"
--[[Translation missing --]]
L["RAID"] = "Raid"
--[[Translation missing --]]
L["READY_BORDER_COLOR"] = "Ready border color"
--[[Translation missing --]]
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
--[[Translation missing --]]
L["REMAINING"] = "Remaining"
--[[Translation missing --]]
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
--[[Translation missing --]]
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
--[[Translation missing --]]
L["REVERSE"] = "Reverse"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
--[[Translation missing --]]
L["RIGHT"] = "Right"
--[[Translation missing --]]
L["SAFE"] = "Safe"
--[[Translation missing --]]
L["SAFE_COLOR"] = "Safe color"
--[[Translation missing --]]
L["SAFE_COLOR_FADED"] = "Safe color faded"
--[[Translation missing --]]
L["SAVE_ANCHOR"] = "Save anchor"
--[[Translation missing --]]
L["SCALE"] = "Scale"
--[[Translation missing --]]
L["SELECT_GROUP"] = "Select Group"
--[[Translation missing --]]
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."
--[[Translation missing --]]
L["SHOW"] = "Show"
--[[Translation missing --]]
L["SHOW_FRACTIONS"] = "Show fractions"
--[[Translation missing --]]
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
--[[Translation missing --]]
L["SHOW_ICON"] = "Show icon"
--[[Translation missing --]]
L["SHOW_KEYBINDINGS"] = "Show keybindings"
--[[Translation missing --]]
L["SHOW_OUTLINE"] = "Show outline"
--[[Translation missing --]]
L["SHOW_SHADOW"] = "Show shadow"
--[[Translation missing --]]
L["SHOW_SWIPE"] = "Show swipe"
--[[Translation missing --]]
L["SHOW_TOOLTIPS"] = "Show tooltips"
--[[Translation missing --]]
L["SITUATION"] = "Situation"
--[[Translation missing --]]
L["SKYRIDING_ZONE"] = "Skyriding Zone"
--[[Translation missing --]]
L["SLASH_DESIGN"] = "design"
--[[Translation missing --]]
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
--[[Translation missing --]]
L["SLASH_HELP"] = "Open the Coolinator settings."
--[[Translation missing --]]
L["SLASH_REGEN"] = "regen"
--[[Translation missing --]]
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
--[[Translation missing --]]
L["SLASH_RESET"] = "reset"
--[[Translation missing --]]
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
--[[Translation missing --]]
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
--[[Translation missing --]]
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"
--[[Translation missing --]]
L["SQUARE"] = "Square"
--[[Translation missing --]]
L["STACK"] = "Stack"
--[[Translation missing --]]
L["START"] = "Start"
--[[Translation missing --]]
L["STYLE"] = "Style"
--[[Translation missing --]]
L["SWIPE_COLOR"] = "Swipe color"
--[[Translation missing --]]
L["TARGET"] = "Target"
--[[Translation missing --]]
L["TEXTS"] = "Texts"
--[[Translation missing --]]
L["TEXTURES"] = "Textures"
--[[Translation missing --]]
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"
--[[Translation missing --]]
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
--[[Translation missing --]]
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
--[[Translation missing --]]
L["THRESHOLDS"] = "Thresholds"
--[[Translation missing --]]
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
--[[Translation missing --]]
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
--[[Translation missing --]]
L["TOP"] = "Top"
--[[Translation missing --]]
L["TOP_LEFT"] = "Top Left"
--[[Translation missing --]]
L["TOP_RIGHT"] = "Top Right"
--[[Translation missing --]]
L["TOTAL"] = "Total"
--[[Translation missing --]]
L["TRANSPARENCY"] = "Transparency"
--[[Translation missing --]]
L["UNINTERRUPTABLE"] = "Uninterruptable"
--[[Translation missing --]]
L["UNLEARNED"] = "Unlearned"
--[[Translation missing --]]
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
--[[Translation missing --]]
L["USE_MASQUE"] = "Use Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
--[[Translation missing --]]
L["UTILITY"] = "Utility"
--[[Translation missing --]]
L["VALUE"] = "Value"
--[[Translation missing --]]
L["VERSION_COLON_X"] = "Version: %s"
--[[Translation missing --]]
L["VERTICAL"] = "Vertical"
--[[Translation missing --]]
L["VISIBILITY"] = "Visibility"
--[[Translation missing --]]
L["VISIBLE"] = "Visible"
--[[Translation missing --]]
L["WARNING"] = "Warning"
--[[Translation missing --]]
L["WARNING_COLOR"] = "Warning color"
--[[Translation missing --]]
L["WARNING_COLOR_FADED"] = "Warning color faded"
--[[Translation missing --]]
L["WHAT_TO_EXPORT"] = "What to export?"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
--[[Translation missing --]]
L["WIDTH"] = "Width"
--[[Translation missing --]]
L["WIDTH_RESTRICTION"] = "Width restriction"
--[[Translation missing --]]
L["WORLD"] = "World"


local L = Locales.zhTW
L["ABILITY"] = "技能"
L["ABILITY_BAR"] = "技能量條"
L["ABILITY_CHARGE"] = "技能充能"
L["ABILITY_CHARGES"] = "技能充能層數"
L["ACTION"] = "動作"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
L["ADD"] = "新增"
L["ALIGN_X"] = "對齊%s"
L["ALIGNMENT"] = "對齊方式"
L["ARCANE_FLURRY"] = "秘法亂舞"
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "確認要清除定位點嗎？"
L["AURA"] = "光環"
L["AURA_BAR"] = "光環量條"
L["AURA_BARS"] = "光環量條"
L["AURAS"] = "光環"
L["AUTO_SIZE"] = "自動縮放"
L["BACKGROUND"] = "背景"
L["BACKGROUND_COLOR"] = "背景顏色"
L["BAR"] = "量條"
L["BARS"] = "量條"
L["BEHAVIOUR"] = "行為"
L["BLIZZARD"] = "暴雪"
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "暴雪內建冷卻管理器光環圖示/量條消失了，所以 Coolinator 將出現異常，需重新載入介面。"
L["BORDER"] = "邊框"
L["BORDER_COLOR"] = "邊框顏色"
L["BOTTOM"] = "下方"
L["BOTTOM_LEFT"] = "左下"
L["BOTTOM_RIGHT"] = "右下"
L["BY_PLUSMOUSE"] = "作者：plusmouse"
L["CAST"] = "施法"
L["CAST_BAR"] = "施法條"
L["CASTING"] = "施放中"
L["CENTER"] = "置中"
L["CENTER_HORIZONTAL"] = "水平置中"
L["CENTER_VERTICAL"] = "垂直置中"
L["CHANNELING"] = "引導中"
L["CHOOSE_A_NEW_DESIGN_NAME"] = "輸入新設計名稱"
L["CHOOSE_ABILITY"] = "選擇技能"
L["CHOOSE_AN_ANCHOR_NAME"] = "選擇定位點名稱："
L["CHOOSE_AURA"] = "選擇光環"
L["CHOOSE_EQUIPMENT"] = "選擇裝備"
L["CHOOSE_ITEM"] = "選擇物品"
L["CHOOSE_POTION_EFFECT"] = "選擇藥水效果"
L["CLASS"] = "職業"
L["CLOSE_DESIGNER"] = "關閉設計模式"
L["COLOR"] = "顏色"
L["COLORS"] = "顏色"
L["COMBAT"] = "戰鬥"
L["COMPLETED"] = "已完成"
L["CONFIRM_DELETE_DESIGN_X"] = "您確定要刪除設計\"%s\"嗎？"
L["CONFIRM_DELETE_PRESET_X"] = "您確定要刪除預設\"%s\"嗎？這將會影響所有設計。"
L["CONFIRM_DELETE_PROFILE_X"] = "確定要刪除設定檔『%s』嗎？"
L["COOLDOWN"] = "冷卻"
L["COOLINATOR"] = "Coolinator"
L["COUNT"] = "總數"
L["CREATE_PRESET"] = "建立預設"
L["CTRL_C_TO_COPY"] = "Ctrl+C 複製"
L["CUSTOM"] = "自訂"
L["CUSTOMISE_COOLINATOR"] = "自訂 Coolinator"
L["CUSTOMISE_COOLINATOR_X"] = "自訂 Coolinator：%s"
L["DANGER"] = "危險"
L["DANGER_COLOR"] = "危險顏色"
L["DANGER_COLOR_FADED"] = "危險顏色（淡）"
L["DEFAULT"] = "預設值"
L["DELETE"] = "刪除"
L["DELVE"] = "探究"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
L["DESATURATE_ON_COOLDOWN"] = "冷卻時變灰 "
L["DESIGN"] = "設計"
L["DESIGNER"] = "設計模式"
L["DETACH_PRESET"] = "拆開預設"
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4開發插件需要大量的時間|r"
L["DISCORD_DESCRIPTION"] = "更新、功能建議與支持"
L["DISPLAY"] = "顯示"
L["DONATE"] = "贊助"
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "由於光環量條的更動，重載介面才能讓 Coolinator 正常運作"
L["DUNGEON"] = "地城"
L["DURATION"] = "持續時間"
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "點擊畫面上的圖示和量條即可進行編輯"
L["ELAPSED"] = "經過時間"
L["EMPOWERED_STAGE_1"] = "聚能階段1"
L["EMPOWERED_STAGE_2"] = "聚能階段2"
L["EMPOWERED_STAGE_3"] = "聚能階段3"
L["EMPOWERED_STAGE_HOLD"] = "聚能中"
L["ENABLE"] = "啟用"
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "字型缺字時啟用"
L["ENTER_DESIGN_NAME"] = "輸入設計名稱："
L["ENTER_PRESET_NAME"] = "輸入預設名稱："
L["ENTER_PROFILE_NAME"] = "輸入設定檔名稱："
L["ENTER_THE_NEW_DESIGN_NAME"] = "輸入新設計名稱"
L["ENTER_THE_NEW_PROFILE_NAME"] = "輸入新設定檔名稱"
L["EQUIPMENT"] = "裝備"
L["ESSENTIAL"] = "核心"
L["EXPORT"] = "匯出"
L["FADE"] = "淡出"
L["FADE_OUT_OF_COMBAT"] = "非戰鬥時淡出"
L["FADE_WHEN_MOUNTED"] = "騎乘坐騎時淡出"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
L["FONT"] = "字型"
L["FONT_SIZE"] = "字型大小"
L["FOREGROUND"] = "前景"
L["FOREGROUND_COLOR"] = "前景顏色"
L["GENERAL"] = "一般"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
L["GROUP"] = "群組"
L["GROW_FROM"] = "增長方向"
L["HAS_TARGET"] = "有目標時"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
L["HEIGHT"] = "高度"
L["HIDE"] = "隱藏"
L["HIDE_ON_COOLDOWN"] = "冷卻時隱藏"
L["HIDE_OUT_OF_COMBAT"] = "非戰鬥時隱藏"
L["HIDE_WHEN_MOUNTED"] = "騎乘坐騎時隱藏"
L["HIDE_WHEN_READY"] = "準備就緒時隱藏"
L["HORIZONTAL"] = "水平"
L["ICICLES"] = "冰柱"
L["ICON"] = "圖示"
L["ICON_POSITION"] = "圖示位置"
L["IMPORT"] = "匯入"
L["IMPORTED_X"] = "已匯入\"%s\""
L["IN_COMBAT"] = "戰鬥中"
L["INCOMPATIBLE_WIDGET_TYPE"] = "不相容的元件類型"
L["INSERT"] = "插入"
L["INTERRUPTED"] = "被中斷"
L["INVALID_ANCHOR_NAME"] = "無效的定位點名稱"
L["INVALID_DESIGN_NAME"] = "無效的設計名稱"
L["INVALID_IMPORT"] = "無效的匯入字串"
L["ITEM"] = "道具"
L["JOIN_THE_DISCORD"] = "加入 Discord"
L["KEYBINDING"] = "按鍵綁定"
L["LAYOUT"] = "佈局"
L["LEFT"] = "左"
L["LINK"] = "連結"
L["LOCATION"] = "位置"
L["MAELSTROM_WEAPON"] = "漩渦武器"
L["MAKE_NEW"] = "新建"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
L["MOUNT"] = "坐騎"
L["MOUSE_BUTTON_X"] = "M%s"
L["NAME"] = "名稱"
L["NEW_DESIGN"] = "新設計"
L["NEW_PROFILE_BLANK"] = "新設定（空白）"
L["NEW_PROFILE_CLONE"] = "新設定（複製目前）"
L["NO_TARGET"] = "無目標"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
L["NONE"] = "無"
L["NONE_SET"] = "未設定"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
L["NOTHING_IN_SLOT"] = "格子為空"
L["OFF_MOUNT"] = "不在坐騎上"
L["ON_MOUNT"] = "騎乘坐騎中"
L["OPEN_OPTIONS"] = "打開選項"
L["OPTIONS"] = "選項"
L["OUT_OF_COMBAT"] = "非戰鬥時"
L["OVERWRITE"] = "覆寫"
L["OVERWRITE_CURRENT_PROFILE"] = "覆寫目前的設定？"
L["PADDING"] = "間距"
L["PARENT"] = "上層"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "在這裡貼上您的匯入字串"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "請重載您的介面以確保 Coolinator 順利運行。理由：(%s)"
L["POTION_EFFECT"] = "藥水效果"
L["PRESET"] = "預設"
L["PROFILE"] = "設定檔"
L["PROFILES"] = "設定檔"
L["PVP"] = "PvP"
L["RAID"] = "團隊副本"
L["READY_BORDER_COLOR"] = "準備就緒的邊框顏色"
L["READY_FOREGROUND_COLOR"] = "準備就緒的前景顏色"
L["REMAINING"] = "剩餘"
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "圖示隱藏時不佔位"
L["RESET_SAVED_ANCHORS"] = "重置已儲存的定位點"
L["REVERSE"] = "反轉"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
L["RIGHT"] = "右"
L["SAFE"] = "安全"
L["SAFE_COLOR"] = "安全顏色"
L["SAFE_COLOR_FADED"] = "安全顏色（淡）"
L["SAVE_ANCHOR"] = "儲存定位點"
L["SCALE"] = "縮放"
L["SELECT_GROUP"] = "選擇群組"
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "設定已修改完成，需要重載介面。"
L["SHOW"] = "顯示"
L["SHOW_FRACTIONS"] = "顯示小數"
L["SHOW_GCD_SWIPE"] = "顯示公共冷卻動畫"
L["SHOW_ICON"] = "顯示圖示"
L["SHOW_KEYBINDINGS"] = "顯示快捷鍵"
L["SHOW_OUTLINE"] = "顯示邊框"
L["SHOW_SHADOW"] = "顯示陰影"
L["SHOW_SWIPE"] = "顯示過渡動畫"
L["SHOW_TOOLTIPS"] = "顯示提示訊息"
L["SITUATION"] = "狀態"
L["SKYRIDING_ZONE"] = "天空騎術區域"
L["SLASH_DESIGN"] = "設計"
L["SLASH_DESIGN_HELP"] = "進入/退出 Coolinator 設計模式"
L["SLASH_HELP"] = "打開 Coolinator 設定。"
L["SLASH_REGEN"] = "重新"
L["SLASH_REGEN_HELP"] = "在目前角色上套用你的設計重新開始"
L["SLASH_RESET"] = "重置"
L["SLASH_RESET_HELP"] = "重置所有 Coolinator 的設定檔，然後重新載入。"
L["SLASH_UNKNOWN_COMMAND"] = "未知指令 '%s'"
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "暴雪冷卻管理器中的專精資料不符"
L["SQUARE"] = "方形"
L["STACK"] = "疊層 "
L["START"] = "起始"
L["STYLE"] = "樣式"
L["SWIPE_COLOR"] = "過渡動畫顏色"
L["TARGET"] = "目標"
L["TEXTS"] = "文字"
L["TEXTURES"] = "材質"
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "感謝使用 Coolinator。請考慮贊助以支持開發"
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "設計名稱已存在"
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "設置檔名稱已存在"
L["THRESHOLDS"] = "閾值"
L["TIP_OF_THE_SPEAR"] = "長矛之尖"
L["TO_OPEN_OPTIONS_X"] = "輸入 /cooli 打開設定"
L["TOP"] = "上"
L["TOP_LEFT"] = "左上"
L["TOP_RIGHT"] = "右上"
L["TOTAL"] = "總數"
L["TRANSPARENCY"] = "透明度"
L["UNINTERRUPTABLE"] = "無法中斷"
L["UNLEARNED"] = "未習得"
L["USE_BLIZZARD_WIDGETS"] = "使用暴雪元件（無樣式）"
L["USE_MASQUE"] = "使用 Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
L["UTILITY"] = "通用"
L["VALUE"] = "數值"
L["VERSION_COLON_X"] = "版本：%s"
L["VERTICAL"] = "垂直"
L["VISIBILITY"] = "可見度"
L["VISIBLE"] = "可見"
L["WARNING"] = "警告"
L["WARNING_COLOR"] = "警告顏色"
L["WARNING_COLOR_FADED"] = "警告顏色（淡）"
L["WHAT_TO_EXPORT"] = "匯出什麼？"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
L["WIDTH"] = "寬度"
L["WIDTH_RESTRICTION"] = "寬度限制"
L["WORLD"] = "世界"


local L = Locales.zhCN
L["ABILITY"] = "技能"
L["ABILITY_BAR"] = "技能栏"
L["ABILITY_CHARGE"] = "技能充能"
L["ABILITY_CHARGES"] = "技能充能层数"
L["ACTION"] = "动作"
L["ACTIVE"] = "激活"
L["ADD"] = "添加"
L["ALIGN_X"] = "对齐 %s"
L["ALIGNMENT"] = "对齐方式"
L["ARCANE_FLURRY"] = "奥术飓风"
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "确定要清除已保存的锚点吗？"
L["AURA"] = "光环"
L["AURA_BAR"] = "光环栏"
L["AURA_BARS"] = "光环栏"
L["AURAS"] = "光环"
L["AUTO_SIZE"] = "自动大小"
L["BACKGROUND"] = "背景"
L["BACKGROUND_COLOR"] = "背景颜色"
L["BAR"] = "栏"
L["BARS"] = "状态栏"
L["BEHAVIOUR"] = "行为"
L["BLIZZARD"] = "暴雪"
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "暴雪冷却管理器的光环图标或状态栏丢失，Coolinator 将出现异常，需重载界面。"
L["BORDER"] = "边框"
L["BORDER_COLOR"] = "边框颜色"
L["BOTTOM"] = "底部"
L["BOTTOM_LEFT"] = "左下"
L["BOTTOM_RIGHT"] = "右下"
L["BY_PLUSMOUSE"] = "作者：plusmouse"
L["CAST"] = "施法"
L["CAST_BAR"] = "施法条"
L["CASTING"] = "正在施放"
L["CENTER"] = "居中"
L["CENTER_HORIZONTAL"] = "水平居中"
L["CENTER_VERTICAL"] = "垂直居中"
L["CHANNELING"] = "正在引导"
L["CHOOSE_A_NEW_DESIGN_NAME"] = "输入新方案名称"
L["CHOOSE_ABILITY"] = "选择技能"
L["CHOOSE_AN_ANCHOR_NAME"] = "选择锚点名称："
L["CHOOSE_AURA"] = "选择光环"
L["CHOOSE_EQUIPMENT"] = "选择装备"
L["CHOOSE_ITEM"] = "选择物品"
L["CHOOSE_POTION_EFFECT"] = "选择药水效果"
L["CLASS"] = "职业"
L["CLOSE_DESIGNER"] = "关闭设计"
L["COLOR"] = "颜色"
L["COLORS"] = "颜色"
L["COMBAT"] = "战斗"
L["COMPLETED"] = "已完成"
L["CONFIRM_DELETE_DESIGN_X"] = "确定要删除设计“%s”吗？"
L["CONFIRM_DELETE_PRESET_X"] = "确定要删除预设“%s”吗？此操作将影响所有设计方案。"
L["CONFIRM_DELETE_PROFILE_X"] = "确定要删除配置“%s”吗？"
L["COOLDOWN"] = "冷却"
L["COOLINATOR"] = "Coolinator"
L["COUNT"] = "次数"
L["CREATE_PRESET"] = "创建预设"
L["CTRL_C_TO_COPY"] = "Ctrl+C 复制"
L["CUSTOM"] = "自定义"
L["CUSTOMISE_COOLINATOR"] = "自定义 Coolinator"
L["CUSTOMISE_COOLINATOR_X"] = "自定义 Coolinator：%s"
L["DANGER"] = "危险"
L["DANGER_COLOR"] = "危险颜色"
L["DANGER_COLOR_FADED"] = "危险颜色（淡化）"
L["DEFAULT"] = "默认"
L["DELETE"] = "删除"
L["DELVE"] = "地下堡"
L["DESATURATE"] = "褪色"
L["DESATURATE_ON_COOLDOWN"] = "冷却时去色"
L["DESIGN"] = "方案"
L["DESIGNER"] = "设计模式"
L["DETACH_PRESET"] = "分离预设"
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4开发耗时巨大|r"
L["DISCORD_DESCRIPTION"] = "更新、功能建议与支持"
L["DISPLAY"] = "显示"
L["DONATE"] = "赞助"
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "由于光环栏变更，需重载才能使 Coolinator 正常工作"
L["DUNGEON"] = "地下城"
L["DURATION"] = "持续时间"
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "点击屏幕上的图标和状态栏即可编辑"
L["ELAPSED"] = "已用时间"
L["EMPOWERED_STAGE_1"] = "蓄力阶段1"
L["EMPOWERED_STAGE_2"] = "蓄力阶段2"
L["EMPOWERED_STAGE_3"] = "蓄力阶段3"
L["EMPOWERED_STAGE_HOLD"] = "蓄力阶段持续"
L["ENABLE"] = "启用"
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "字体缺字时启用"
L["ENTER_DESIGN_NAME"] = "输入配置文件名称："
L["ENTER_PRESET_NAME"] = "输入预设名称："
L["ENTER_PROFILE_NAME"] = "输入配置名称："
L["ENTER_THE_NEW_DESIGN_NAME"] = "输入新方案名称"
L["ENTER_THE_NEW_PROFILE_NAME"] = "输入新配置名称"
L["EQUIPMENT"] = "装备"
L["ESSENTIAL"] = "核心"
L["EXPORT"] = "导出"
L["FADE"] = "淡出"
L["FADE_OUT_OF_COMBAT"] = "非战斗时淡出"
L["FADE_WHEN_MOUNTED"] = "骑乘时淡出"
L["FLASH_GLOW"] = "闪烁发光"
L["FONT"] = "字体"
L["FONT_SIZE"] = "字体大小"
L["FOREGROUND"] = "前景"
L["FOREGROUND_COLOR"] = "前景颜色"
L["GENERAL"] = "常规"
L["GLOW_COLOR"] = "发光颜色"
L["GROUP"] = "组"
L["GROW_FROM"] = "增长方向"
L["HAS_TARGET"] = "有目标"
L["HAS_TARGET_ASSIST"] = "有目标（辅助）"
L["HAS_TARGET_ATTACK"] = "有目标（攻击）"
L["HEIGHT"] = "高度"
L["HIDE"] = "隐藏"
L["HIDE_ON_COOLDOWN"] = "冷却时隐藏"
L["HIDE_OUT_OF_COMBAT"] = "非战斗时隐藏"
L["HIDE_WHEN_MOUNTED"] = "骑乘时隐藏"
L["HIDE_WHEN_READY"] = "就绪时隐藏"
L["HORIZONTAL"] = "水平"
L["ICICLES"] = "冰刺"
L["ICON"] = "图标"
L["ICON_POSITION"] = "图标位置"
L["IMPORT"] = "导入"
L["IMPORTED_X"] = "已导入“%s”"
L["IN_COMBAT"] = "战斗中"
L["INCOMPATIBLE_WIDGET_TYPE"] = "不兼容的控件类型"
L["INSERT"] = "插入"
L["INTERRUPTED"] = "被打断"
L["INVALID_ANCHOR_NAME"] = "无效的锚点名称"
L["INVALID_DESIGN_NAME"] = "无效的方案名称"
L["INVALID_IMPORT"] = "无效的导入字符串"
L["ITEM"] = "物品"
L["JOIN_THE_DISCORD"] = "加入 Discord"
L["KEYBINDING"] = "快捷键"
L["LAYOUT"] = "布局"
L["LEFT"] = "左"
L["LINK"] = "链接"
L["LOCATION"] = "位置"
L["MAELSTROM_WEAPON"] = "漩涡武器"
L["MAKE_NEW"] = "新建"
L["MARCHING_ANTS_GLOW"] = "行军蚁发光"
L["MOUNT"] = "坐骑"
L["MOUSE_BUTTON_X"] = "M%s"
L["NAME"] = "名称"
L["NEW_DESIGN"] = "新建方案"
L["NEW_PROFILE_BLANK"] = "新建配置（空白）"
L["NEW_PROFILE_CLONE"] = "新建配置（复制当前）"
L["NO_TARGET"] = "没有目标"
L["NO_TARGET_ASSIST"] = "无目标（辅助）"
L["NO_TARGET_ATTACK"] = "无目标（攻击）"
L["NONE"] = "无"
L["NONE_SET"] = "未设置"
L["NOTHING"] = "无"
L["NOTHING_IN_SLOT"] = "格子为空"
L["OFF_MOUNT"] = "非骑乘"
L["ON_MOUNT"] = "骑乘中"
L["OPEN_OPTIONS"] = "打开设置"
L["OPTIONS"] = "设置"
L["OUT_OF_COMBAT"] = "非战斗"
L["OVERWRITE"] = "覆盖"
L["OVERWRITE_CURRENT_PROFILE"] = "覆盖当前配置？"
L["PADDING"] = "间距"
L["PARENT"] = "父级"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "在此粘贴导入字符串"
L["PIXEL_GLOW"] = "像素发光"
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "请重载界面以使 Coolinator 正常工作。原因（%s）"
L["POTION_EFFECT"] = "药水效果"
L["PRESET"] = "预设"
L["PROFILE"] = "配置"
L["PROFILES"] = "配置"
L["PVP"] = "PvP"
L["RAID"] = "团队"
L["READY_BORDER_COLOR"] = "就绪边框颜色"
L["READY_FOREGROUND_COLOR"] = "就绪前景色"
L["REMAINING"] = "剩余"
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "移除隐藏图标的间距"
L["RESET_SAVED_ANCHORS"] = "重置已保存的锚点"
L["REVERSE"] = "反向"
L["REVERSE_GLOW"] = "反向发光"
L["RIGHT"] = "右"
L["SAFE"] = "安全"
L["SAFE_COLOR"] = "安全颜色"
L["SAFE_COLOR_FADED"] = "安全颜色（淡化）"
L["SAVE_ANCHOR"] = "保存锚点"
L["SCALE"] = "缩放"
L["SELECT_GROUP"] = "选择组"
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "设置已更改，需重载界面。"
L["SHOW"] = "显示"
L["SHOW_FRACTIONS"] = "显示分数"
L["SHOW_GCD_SWIPE"] = "显示公共冷却动画"
L["SHOW_ICON"] = "显示图标"
L["SHOW_KEYBINDINGS"] = "显示快捷键"
L["SHOW_OUTLINE"] = "显示轮廓"
L["SHOW_SHADOW"] = "显示阴影"
L["SHOW_SWIPE"] = "显示动画"
L["SHOW_TOOLTIPS"] = "显示提示信息"
L["SITUATION"] = "状态"
L["SKYRIDING_ZONE"] = "驭空术区域"
L["SLASH_DESIGN"] = "设计"
L["SLASH_DESIGN_HELP"] = "进入/退出 Coolinator 设计模式"
L["SLASH_HELP"] = "打开 Coolinator 设置。"
L["SLASH_REGEN"] = "重载"
L["SLASH_REGEN_HELP"] = "在当前角色上使用你的方案重新开始"
L["SLASH_RESET"] = "重置"
L["SLASH_RESET_HELP"] = "重置所有 Coolinator 设置，然后重载。"
L["SLASH_UNKNOWN_COMMAND"] = "未知命令 “%s”"
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "暴雪冷却管理器中专精数据不匹配"
L["SQUARE"] = "方形"
L["STACK"] = "堆叠"
L["START"] = "开始"
L["STYLE"] = "样式"
L["SWIPE_COLOR"] = "滑动颜色"
L["TARGET"] = "目标"
L["TEXTS"] = "文本"
L["TEXTURES"] = "材质"
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "感谢使用Coolinator，请考虑赞助以支持开发"
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "该方案名称已存在"
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "该配置名称已存在"
L["THRESHOLDS"] = "阈值"
L["TIP_OF_THE_SPEAR"] = "利矛之刃"
L["TO_OPEN_OPTIONS_X"] = "输入 /cooli 打开设置"
L["TOP"] = "顶部"
L["TOP_LEFT"] = "左上"
L["TOP_RIGHT"] = "右上"
L["TOTAL"] = "总计"
L["TRANSPARENCY"] = "透明度"
L["UNINTERRUPTABLE"] = "不能打断"
L["UNLEARNED"] = "未学习"
L["USE_BLIZZARD_WIDGETS"] = "使用暴雪控件（无样式）"
L["USE_MASQUE"] = "使用 Masque"
L["USE_PERCENTAGE"] = "使用百分比"
L["UTILITY"] = "通用"
L["VALUE"] = "数值"
L["VERSION_COLON_X"] = "版本：%s"
L["VERTICAL"] = "垂直"
L["VISIBILITY"] = "可见性"
L["VISIBLE"] = "可见"
L["WARNING"] = "警告"
L["WARNING_COLOR"] = "警告颜色"
L["WARNING_COLOR_FADED"] = "警告颜色（淡化）"
L["WHAT_TO_EXPORT"] = "导出什么？"
L["WHEN_ACTIVE"] = "激活时"
L["WHEN_INACTIVE"] = "未激活时"
L["WHEN_ON_COOLDOWN"] = "冷却中时"
L["WHEN_READY"] = "就绪时"
L["WIDTH"] = "宽度"
L["WIDTH_RESTRICTION"] = "宽度限制"
L["WORLD"] = "世界"


local L = Locales.koKR
L["ABILITY"] = "능력"
L["ABILITY_BAR"] = "능력 바"
L["ABILITY_CHARGE"] = "기술 충전 횟수"
L["ABILITY_CHARGES"] = "기술 충전 횟수"
L["ACTION"] = "행동"
L["ACTIVE"] = "활성화"
L["ADD"] = "추가"
L["ALIGN_X"] = "정렬 %s"
L["ALIGNMENT"] = "정렬"
L["ARCANE_FLURRY"] = "비전 질풍"
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "저장된 고정점을 모두 지우시겠습니까?"
L["AURA"] = "오라"
L["AURA_BAR"] = "오라 바"
L["AURA_BARS"] = "오라 바"
L["AURAS"] = "오라"
L["AUTO_SIZE"] = "자동 크기 조절"
L["BACKGROUND"] = "배경"
L["BACKGROUND_COLOR"] = "배경 색상"
L["BAR"] = "바"
L["BARS"] = "바"
L["BEHAVIOUR"] = "동작"
L["BLIZZARD"] = "블리자드"
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "블리자드 CDM의 오라 아이콘/바가 표시되지 않아 Coolinator가 제대로 작동하지 않습니다. 재로딩이 필요합니다."
L["BORDER"] = "테두리"
L["BORDER_COLOR"] = "테두리 색상"
L["BOTTOM"] = "아래"
L["BOTTOM_LEFT"] = "왼쪽 아래"
L["BOTTOM_RIGHT"] = "오른쪽 아래"
L["BY_PLUSMOUSE"] = "제작: plusmouse"
L["CAST"] = "시전"
L["CAST_BAR"] = "시전 바"
L["CASTING"] = "시전중"
L["CENTER"] = "가운데"
L["CENTER_HORIZONTAL"] = "수평 가운데"
L["CENTER_VERTICAL"] = "수직 가운데"
L["CHANNELING"] = "정신집중"
L["CHOOSE_A_NEW_DESIGN_NAME"] = "새 디자인 이름 선택"
L["CHOOSE_ABILITY"] = "능력 선택"
L["CHOOSE_AN_ANCHOR_NAME"] = "선택된 고정점 이름"
L["CHOOSE_AURA"] = "오라 선택"
L["CHOOSE_EQUIPMENT"] = "장비 선택"
L["CHOOSE_ITEM"] = "아이템 선택"
L["CHOOSE_POTION_EFFECT"] = "물약 효과 선택"
L["CLASS"] = "직업"
L["CLOSE_DESIGNER"] = "디자이너 닫기"
L["COLOR"] = "색상"
L["COLORS"] = "색상"
L["COMBAT"] = "전투"
L["COMPLETED"] = "완료"
L["CONFIRM_DELETE_DESIGN_X"] = "\"%s\" 디자인을 삭제 하시겠습니까?"
L["CONFIRM_DELETE_PRESET_X"] = "\"%s\" 프리셋을 삭제하시겠습니까? 이 작업은 모든 디자인에 영향을 줍니다."
L["CONFIRM_DELETE_PROFILE_X"] = "프로필 \\\"%s\\\"을(를) 삭제하시겠습니까?"
L["COOLDOWN"] = "재사용 대기시간"
L["COOLINATOR"] = "Coolinator"
L["COUNT"] = "개수"
L["CREATE_PRESET"] = "프리셋 생성"
L["CTRL_C_TO_COPY"] = "Ctrl+C로 복사"
L["CUSTOM"] = "사용자 지정"
L["CUSTOMISE_COOLINATOR"] = "Coolinator 사용자 지정"
L["CUSTOMISE_COOLINATOR_X"] = "Coolinator 사용자 지정: %s"
L["DANGER"] = "위험"
L["DANGER_COLOR"] = "위험 색상"
L["DANGER_COLOR_FADED"] = "위험 색상 (흐림)"
L["DEFAULT"] = "기본값"
L["DELETE"] = "삭제"
L["DELVE"] = "구렁"
L["DESATURATE"] = "흑백처리"
L["DESATURATE_ON_COOLDOWN"] = "재사용대기중 흑백처리"
L["DESIGN"] = "디자인"
L["DESIGNER"] = "디자인"
L["DETACH_PRESET"] = "프리셋 연결 해제"
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4개발에는 엄청난 시간이 듭니다|r"
L["DISCORD_DESCRIPTION"] = "업데이트, 기능 제안 및 지원"
L["DISPLAY"] = "표시"
L["DONATE"] = "후원"
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "오라 바 변경으로 Coolinator 작동을 위해 다시 불러와야 합니다"
L["DUNGEON"] = "던전"
L["DURATION"] = "지속시간"
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "화면의 아이콘과 바를 클릭해 편집하세요"
L["ELAPSED"] = "경과 시간"
L["EMPOWERED_STAGE_1"] = "강화 1단계"
L["EMPOWERED_STAGE_2"] = "강화 2단계"
L["EMPOWERED_STAGE_3"] = "강화 3단계"
L["EMPOWERED_STAGE_HOLD"] = "강화 단계 유지"
L["ENABLE"] = "사용"
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "텍스트가 글꼴 영역을 벗어날 경우 사용"
L["ENTER_DESIGN_NAME"] = "프로필 이름 입력:"
L["ENTER_PRESET_NAME"] = "프리셋 이름 입력:"
L["ENTER_PROFILE_NAME"] = "프로필 이름 입력:"
L["ENTER_THE_NEW_DESIGN_NAME"] = "새 디자인 이름 입력"
L["ENTER_THE_NEW_PROFILE_NAME"] = "새 프로필 이름 입력"
L["EQUIPMENT"] = "장비"
L["ESSENTIAL"] = "에센셜"
L["EXPORT"] = "내보내기"
L["FADE"] = "페이드"
L["FADE_OUT_OF_COMBAT"] = "전투시 페이드 아웃"
L["FADE_WHEN_MOUNTED"] = "탑승시 페이드"
L["FLASH_GLOW"] = "점멸 강조"
L["FONT"] = "글꼴"
L["FONT_SIZE"] = "글꼴 크기"
L["FOREGROUND"] = "전경"
L["FOREGROUND_COLOR"] = "전경 색상"
L["GENERAL"] = "일반"
L["GLOW_COLOR"] = "강조 색상"
L["GROUP"] = "그룹"
L["GROW_FROM"] = "확장 시작점"
L["HAS_TARGET"] = "대상 지정시"
L["HAS_TARGET_ASSIST"] = "대상 지정시 (주시)"
L["HAS_TARGET_ATTACK"] = "대상 지정시 (공격)"
L["HEIGHT"] = "높이"
L["HIDE"] = "숨기기"
L["HIDE_ON_COOLDOWN"] = "재사용대기시간 숨기기"
L["HIDE_OUT_OF_COMBAT"] = "전투시 숨기기"
L["HIDE_WHEN_MOUNTED"] = "탑승시 숨기기"
L["HIDE_WHEN_READY"] = "대시상태시 숨기기"
L["HORIZONTAL"] = "가로"
L["ICICLES"] = "고드름"
L["ICON"] = "아이콘"
L["ICON_POSITION"] = "아이콘 위치"
L["IMPORT"] = "가져오기"
L["IMPORTED_X"] = "\"%s\"를 가져옴"
L["IN_COMBAT"] = "전투중"
L["INCOMPATIBLE_WIDGET_TYPE"] = "호환되지 않는 위젯 유형"
L["INSERT"] = "삽입"
L["INTERRUPTED"] = "차단됨"
L["INVALID_ANCHOR_NAME"] = "잘못된 고정점 이름"
L["INVALID_DESIGN_NAME"] = "잘못된 디자인 이름"
L["INVALID_IMPORT"] = "잘못된 가져오기"
L["ITEM"] = "아이템"
L["JOIN_THE_DISCORD"] = "디스코드 참여"
L["KEYBINDING"] = "단축키"
L["LAYOUT"] = "배치"
L["LEFT"] = "왼쪽"
L["LINK"] = "링크"
L["LOCATION"] = "위치"
L["MAELSTROM_WEAPON"] = "소용돌이 치는 무기"
L["MAKE_NEW"] = "새로 만들기"
L["MARCHING_ANTS_GLOW"] = "움직이는 점선 강조"
L["MOUNT"] = "탑승"
L["MOUSE_BUTTON_X"] = "M%s"
L["NAME"] = "이름"
L["NEW_DESIGN"] = "새 디자인"
L["NEW_PROFILE_BLANK"] = "새 프로필 (빈)"
L["NEW_PROFILE_CLONE"] = "새 프로필 (현재 복제)"
L["NO_TARGET"] = "대상 없음"
L["NO_TARGET_ASSIST"] = "대상 없음 (주시)"
L["NO_TARGET_ATTACK"] = "대상 없음 (공격)"
L["NONE"] = "없음"
L["NONE_SET"] = "미설정"
L["NOTHING"] = "없음"
L["NOTHING_IN_SLOT"] = "슬롯 비어 있음"
L["OFF_MOUNT"] = "탈것 하차"
L["ON_MOUNT"] = "탑승중"
L["OPEN_OPTIONS"] = "설정 열기"
L["OPTIONS"] = "설정"
L["OUT_OF_COMBAT"] = "전투에서 벗어남"
L["OVERWRITE"] = "덮어쓰기"
L["OVERWRITE_CURRENT_PROFILE"] = "현재 프로필을 덮어쓸까요?"
L["PADDING"] = "여백"
L["PARENT"] = "상위"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "가져오기 문자열을 여기에 붙여넣으세요"
L["PIXEL_GLOW"] = "픽셀 강조"
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Coolinator 작동을 위해 다시 불러오세요. 사유 (%s)"
L["POTION_EFFECT"] = "물약 효과"
L["PRESET"] = "프리셋"
L["PROFILE"] = "프로필"
L["PROFILES"] = "프로필"
L["PVP"] = "PvP"
L["RAID"] = "레이드"
L["READY_BORDER_COLOR"] = "준비상태 테두리 색상"
L["READY_FOREGROUND_COLOR"] = "대기상태 전경 색상"
L["REMAINING"] = "남은시간"
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "숨겨진 아이콘을 위한 여백 제거"
L["RESET_SAVED_ANCHORS"] = "저장된 고정점 재설정"
L["REVERSE"] = "반전"
L["REVERSE_GLOW"] = "강조 반전"
L["RIGHT"] = "오른쪽"
L["SAFE"] = "안전"
L["SAFE_COLOR"] = "안전 색상"
L["SAFE_COLOR_FADED"] = "안전 색상 (흐림)"
L["SAVE_ANCHOR"] = "고정점 저장"
L["SCALE"] = "배율"
L["SELECT_GROUP"] = "그룹 선택"
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "설정이 변경되었습니다. UI를 새로고침해야 합니다."
L["SHOW"] = "표시"
L["SHOW_FRACTIONS"] = "소수 표시"
L["SHOW_GCD_SWIPE"] = "전역 재사용 대기시간 효과 표시"
L["SHOW_ICON"] = "아이콘 표시"
L["SHOW_KEYBINDINGS"] = "단축키 표시"
L["SHOW_OUTLINE"] = "아웃라인 표시"
L["SHOW_SHADOW"] = "그림자 표시"
L["SHOW_SWIPE"] = "효과 표시"
L["SHOW_TOOLTIPS"] = "툴팁 표시"
L["SITUATION"] = "상황"
L["SKYRIDING_ZONE"] = "하늘비행 지역"
L["SLASH_DESIGN"] = "design"
L["SLASH_DESIGN_HELP"] = "Coolinator 디자이너 모드 진입/종료"
L["SLASH_HELP"] = "Coolinator 설정을 엽니다."
L["SLASH_REGEN"] = "regen"
L["SLASH_REGEN_HELP"] = "현재 캐릭터에서 디자인을 새로 시작합니다"
L["SLASH_RESET"] = "reset"
L["SLASH_RESET_HELP"] = "모든 Coolinator 설정을 초기화한 뒤 다시 불러옵니다."
L["SLASH_UNKNOWN_COMMAND"] = "알 수 없는 명령어 '%s'"
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "블리자드 CDM의 전문화 데이터 불일치"
L["SQUARE"] = "사각형"
L["STACK"] = "중첩"
L["START"] = "시작"
L["STYLE"] = "스타일"
L["SWIPE_COLOR"] = "효과 색상"
L["TARGET"] = "대상"
L["TEXTS"] = "텍스트"
L["TEXTURES"] = "텍스처"
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Coolinator를 사용해 주셔서 감사합니다. 개발 지원을 위해 후원을 고려해 주세요"
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "이미 존재하는 스타일 이름입니다"
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "이미 존재하는 프로필 이름입니다"
L["THRESHOLDS"] = "임계값"
L["TIP_OF_THE_SPEAR"] = "창끝"
L["TO_OPEN_OPTIONS_X"] = "/cooli 로 설정 열기"
L["TOP"] = "위"
L["TOP_LEFT"] = "왼쪽 위"
L["TOP_RIGHT"] = "오른쪽 위"
L["TOTAL"] = "전체"
L["TRANSPARENCY"] = "투명도"
L["UNINTERRUPTABLE"] = "차단 불가"
L["UNLEARNED"] = "미습득"
L["USE_BLIZZARD_WIDGETS"] = "블리자드 위젯 사용 (스타일 없음)"
L["USE_MASQUE"] = "Masque 사용"
L["USE_PERCENTAGE"] = "퍼센트 사용"
L["UTILITY"] = "유틸리티"
L["VALUE"] = "값"
L["VERSION_COLON_X"] = "버전: %s"
L["VERTICAL"] = "세로"
L["VISIBILITY"] = "표시 여부"
L["VISIBLE"] = "표시"
L["WARNING"] = "경고"
L["WARNING_COLOR"] = "경고 색상"
L["WARNING_COLOR_FADED"] = "경고 색상 (흐림)"
L["WHAT_TO_EXPORT"] = "무엇을 내보낼까요?"
L["WHEN_ACTIVE"] = "활성화시"
L["WHEN_INACTIVE"] = "비활성화시"
L["WHEN_ON_COOLDOWN"] = "재사용 대기중일때"
L["WHEN_READY"] = "준비 상태일때"
L["WIDTH"] = "너비"
L["WIDTH_RESTRICTION"] = "너비 제한"
L["WORLD"] = "월드"


local L = Locales.itIT
--[[Translation missing --]]
L["ABILITY"] = "Ability"
--[[Translation missing --]]
L["ABILITY_BAR"] = "Ability Bar"
--[[Translation missing --]]
L["ABILITY_CHARGE"] = "Ability Charge"
--[[Translation missing --]]
L["ABILITY_CHARGES"] = "Ability Charges"
--[[Translation missing --]]
L["ACTION"] = "Action"
--[[Translation missing --]]
L["ACTIVE"] = "Active"
--[[Translation missing --]]
L["ADD"] = "Add"
--[[Translation missing --]]
L["ALIGN_X"] = "Align %s"
--[[Translation missing --]]
L["ALIGNMENT"] = "Alignment"
--[[Translation missing --]]
L["ARCANE_FLURRY"] = "Arcane Flurry"
--[[Translation missing --]]
L["ARE_YOU_SURE_CLEAR_ANCHORS"] = "Are you sure you want to clear your saved anchors?"
--[[Translation missing --]]
L["AURA"] = "Aura"
--[[Translation missing --]]
L["AURA_BAR"] = "Aura Bar"
--[[Translation missing --]]
L["AURA_BARS"] = "Auras Bars"
--[[Translation missing --]]
L["AURAS"] = "Auras"
--[[Translation missing --]]
L["AUTO_SIZE"] = "Auto-size"
--[[Translation missing --]]
L["BACKGROUND"] = "Background"
--[[Translation missing --]]
L["BACKGROUND_COLOR"] = "Background color"
--[[Translation missing --]]
L["BAR"] = "Bar"
--[[Translation missing --]]
L["BARS"] = "Bars"
--[[Translation missing --]]
L["BEHAVIOUR"] = "Behaviour"
--[[Translation missing --]]
L["BLIZZARD"] = "Blizzard"
--[[Translation missing --]]
L["BLIZZARD_CDM_IS_MISSING_ICONS_SO_RELOAD_REQUIRED"] = "Blizzard CDM aura icons/bars are missing, so Coolinator will malfunction. A reload is required"
--[[Translation missing --]]
L["BORDER"] = "Border"
--[[Translation missing --]]
L["BORDER_COLOR"] = "Border color"
--[[Translation missing --]]
L["BOTTOM"] = "Bottom"
--[[Translation missing --]]
L["BOTTOM_LEFT"] = "Bottom Left"
--[[Translation missing --]]
L["BOTTOM_RIGHT"] = "Bottom Right"
--[[Translation missing --]]
L["BY_PLUSMOUSE"] = "by plusmouse"
--[[Translation missing --]]
L["CAST"] = "Cast"
--[[Translation missing --]]
L["CAST_BAR"] = "Cast Bar"
--[[Translation missing --]]
L["CASTING"] = "Casting"
--[[Translation missing --]]
L["CENTER"] = "Center"
--[[Translation missing --]]
L["CENTER_HORIZONTAL"] = "Center Horizontal"
--[[Translation missing --]]
L["CENTER_VERTICAL"] = "Center Vertical"
--[[Translation missing --]]
L["CHANNELING"] = "Channeling"
--[[Translation missing --]]
L["CHOOSE_A_NEW_DESIGN_NAME"] = "Choose a new design name"
--[[Translation missing --]]
L["CHOOSE_ABILITY"] = "Choose Ability"
--[[Translation missing --]]
L["CHOOSE_AN_ANCHOR_NAME"] = "Choose an anchor name:"
--[[Translation missing --]]
L["CHOOSE_AURA"] = "Choose Aura"
--[[Translation missing --]]
L["CHOOSE_EQUIPMENT"] = "Choose Equipment"
--[[Translation missing --]]
L["CHOOSE_ITEM"] = "Choose Item"
--[[Translation missing --]]
L["CHOOSE_POTION_EFFECT"] = "Choose Potion Effect"
--[[Translation missing --]]
L["CLASS"] = "Class"
--[[Translation missing --]]
L["CLOSE_DESIGNER"] = "Close Designer"
--[[Translation missing --]]
L["COLOR"] = "Color"
--[[Translation missing --]]
L["COLORS"] = "Colors"
--[[Translation missing --]]
L["COMBAT"] = "Combat"
--[[Translation missing --]]
L["COMPLETED"] = "Completed"
--[[Translation missing --]]
L["CONFIRM_DELETE_DESIGN_X"] = "Are you sure you want to delete design \"%s\"?"
--[[Translation missing --]]
L["CONFIRM_DELETE_PRESET_X"] = "Are you sure you want to delete preset \"%s\"? This will affect ALL designs."
--[[Translation missing --]]
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
--[[Translation missing --]]
L["COOLDOWN"] = "Cooldown"
--[[Translation missing --]]
L["COOLINATOR"] = "Coolinator"
--[[Translation missing --]]
L["COUNT"] = "Count"
--[[Translation missing --]]
L["CREATE_PRESET"] = "Create Preset"
--[[Translation missing --]]
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
--[[Translation missing --]]
L["CUSTOM"] = "Custom"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR"] = "Customise Coolinator"
--[[Translation missing --]]
L["CUSTOMISE_COOLINATOR_X"] = "Customise Coolinator: %s"
--[[Translation missing --]]
L["DANGER"] = "Danger"
--[[Translation missing --]]
L["DANGER_COLOR"] = "Danger color"
--[[Translation missing --]]
L["DANGER_COLOR_FADED"] = "Danger color faded"
--[[Translation missing --]]
L["DEFAULT"] = "Default"
--[[Translation missing --]]
L["DELETE"] = "Delete"
--[[Translation missing --]]
L["DELVE"] = "Delve"
--[[Translation missing --]]
L["DESATURATE"] = "Desaturate"
--[[Translation missing --]]
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on cooldown"
--[[Translation missing --]]
L["DESIGN"] = "Design"
--[[Translation missing --]]
L["DESIGNER"] = "Designer"
--[[Translation missing --]]
L["DETACH_PRESET"] = "Detach Preset"
--[[Translation missing --]]
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
--[[Translation missing --]]
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
--[[Translation missing --]]
L["DISPLAY"] = "Display"
--[[Translation missing --]]
L["DONATE"] = "Donate"
--[[Translation missing --]]
L["DUE_TO_AURA_BARS_CHANGING_RELOAD_REQUIRED"] = "Due to aura bars changing a reload is required for Coolinator function"
--[[Translation missing --]]
L["DUNGEON"] = "Dungeon"
--[[Translation missing --]]
L["DURATION"] = "Duration"
--[[Translation missing --]]
L["EDIT_THE_ICONS_AND_BARS_ONSCREEN"] = "Edit the icons and bars onscreen by clicking on them"
--[[Translation missing --]]
L["ELAPSED"] = "Elapsed"
--[[Translation missing --]]
L["EMPOWERED_STAGE_1"] = "Empowered stage 1"
--[[Translation missing --]]
L["EMPOWERED_STAGE_2"] = "Empowered stage 2"
--[[Translation missing --]]
L["EMPOWERED_STAGE_3"] = "Empowered stage 3"
--[[Translation missing --]]
L["EMPOWERED_STAGE_HOLD"] = "Empowered stage hold"
--[[Translation missing --]]
L["ENABLE"] = "Enable"
--[[Translation missing --]]
L["ENABLE_IF_LINES_FALLING_OFF_FONT"] = "Enable if lines falling off font"
--[[Translation missing --]]
L["ENTER_DESIGN_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_PRESET_NAME"] = "Enter preset name:"
--[[Translation missing --]]
L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
--[[Translation missing --]]
L["ENTER_THE_NEW_DESIGN_NAME"] = "Enter the new design name"
--[[Translation missing --]]
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
--[[Translation missing --]]
L["EQUIPMENT"] = "Equipment"
--[[Translation missing --]]
L["ESSENTIAL"] = "Essential"
--[[Translation missing --]]
L["EXPORT"] = "Export"
--[[Translation missing --]]
L["FADE"] = "Fade"
--[[Translation missing --]]
L["FADE_OUT_OF_COMBAT"] = "Fade out of combat"
--[[Translation missing --]]
L["FADE_WHEN_MOUNTED"] = "Fade when mounted"
--[[Translation missing --]]
L["FLASH_GLOW"] = "Flash Glow"
--[[Translation missing --]]
L["FONT"] = "Font"
--[[Translation missing --]]
L["FONT_SIZE"] = "Font size"
--[[Translation missing --]]
L["FOREGROUND"] = "Foreground"
--[[Translation missing --]]
L["FOREGROUND_COLOR"] = "Foreground color"
--[[Translation missing --]]
L["GENERAL"] = "General"
--[[Translation missing --]]
L["GLOW_COLOR"] = "Glow color"
--[[Translation missing --]]
L["GROUP"] = "Group"
--[[Translation missing --]]
L["GROW_FROM"] = "Grow from"
--[[Translation missing --]]
L["HAS_TARGET"] = "Has Target"
--[[Translation missing --]]
L["HAS_TARGET_ASSIST"] = "Has Target (Assist)"
--[[Translation missing --]]
L["HAS_TARGET_ATTACK"] = "Has Target (Attack)"
--[[Translation missing --]]
L["HEIGHT"] = "Height"
--[[Translation missing --]]
L["HIDE"] = "Hide"
--[[Translation missing --]]
L["HIDE_ON_COOLDOWN"] = "Hide on cooldown"
--[[Translation missing --]]
L["HIDE_OUT_OF_COMBAT"] = "Hide out of combat"
--[[Translation missing --]]
L["HIDE_WHEN_MOUNTED"] = "Hide when mounted"
--[[Translation missing --]]
L["HIDE_WHEN_READY"] = "Hide when ready"
--[[Translation missing --]]
L["HORIZONTAL"] = "Horizontal"
--[[Translation missing --]]
L["ICICLES"] = "Icicles"
--[[Translation missing --]]
L["ICON"] = "Icon"
--[[Translation missing --]]
L["ICON_POSITION"] = "Icon position"
--[[Translation missing --]]
L["IMPORT"] = "Import"
--[[Translation missing --]]
L["IMPORTED_X"] = "Imported \"%s\""
--[[Translation missing --]]
L["IN_COMBAT"] = "In Combat"
--[[Translation missing --]]
L["INCOMPATIBLE_WIDGET_TYPE"] = "Incompatible widget type"
--[[Translation missing --]]
L["INSERT"] = "Insert"
--[[Translation missing --]]
L["INTERRUPTED"] = "Interrupted"
--[[Translation missing --]]
L["INVALID_ANCHOR_NAME"] = "Invalid anchor name"
--[[Translation missing --]]
L["INVALID_DESIGN_NAME"] = "Invalid design name"
--[[Translation missing --]]
L["INVALID_IMPORT"] = "Invalid import"
--[[Translation missing --]]
L["ITEM"] = "Item"
--[[Translation missing --]]
L["JOIN_THE_DISCORD"] = "Join the Discord"
--[[Translation missing --]]
L["KEYBINDING"] = "Keybinding"
--[[Translation missing --]]
L["LAYOUT"] = "Layout"
--[[Translation missing --]]
L["LEFT"] = "Left"
--[[Translation missing --]]
L["LINK"] = "Link"
--[[Translation missing --]]
L["LOCATION"] = "Location"
--[[Translation missing --]]
L["MAELSTROM_WEAPON"] = "Maelstrom Weapon"
--[[Translation missing --]]
L["MAKE_NEW"] = "Make new"
--[[Translation missing --]]
L["MARCHING_ANTS_GLOW"] = "Marching Ants Glow"
--[[Translation missing --]]
L["MOUNT"] = "Mount"
--[[Translation missing --]]
L["MOUSE_BUTTON_X"] = "M%s"
--[[Translation missing --]]
L["NAME"] = "Name"
--[[Translation missing --]]
L["NEW_DESIGN"] = "New Design"
--[[Translation missing --]]
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
--[[Translation missing --]]
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
--[[Translation missing --]]
L["NO_TARGET"] = "No Target"
--[[Translation missing --]]
L["NO_TARGET_ASSIST"] = "No Target (Assist)"
--[[Translation missing --]]
L["NO_TARGET_ATTACK"] = "No Target (Attack)"
--[[Translation missing --]]
L["NONE"] = "None"
--[[Translation missing --]]
L["NONE_SET"] = "None set"
--[[Translation missing --]]
L["NOTHING"] = "Nothing"
--[[Translation missing --]]
L["NOTHING_IN_SLOT"] = "Nothing in slot"
--[[Translation missing --]]
L["OFF_MOUNT"] = "Off Mount"
--[[Translation missing --]]
L["ON_MOUNT"] = "On Mount"
--[[Translation missing --]]
L["OPEN_OPTIONS"] = "Open Options"
--[[Translation missing --]]
L["OPTIONS"] = "Options"
--[[Translation missing --]]
L["OUT_OF_COMBAT"] = "Out of Combat"
--[[Translation missing --]]
L["OVERWRITE"] = "Overwrite"
--[[Translation missing --]]
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
--[[Translation missing --]]
L["PADDING"] = "Padding"
--[[Translation missing --]]
L["PARENT"] = "Parent"
--[[Translation missing --]]
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"
--[[Translation missing --]]
L["PIXEL_GLOW"] = "Pixel Glow"
--[[Translation missing --]]
L["PLEASE_RELOAD_TO_GET_COOLINATOR_WORKING_REASON_X"] = "Please reload to get Coolinator working. Reason (%s)"
--[[Translation missing --]]
L["POTION_EFFECT"] = "Potion Effect"
--[[Translation missing --]]
L["PRESET"] = "Preset"
--[[Translation missing --]]
L["PROFILE"] = "Profile"
--[[Translation missing --]]
L["PROFILES"] = "Profiles"
--[[Translation missing --]]
L["PVP"] = "PvP"
--[[Translation missing --]]
L["RAID"] = "Raid"
--[[Translation missing --]]
L["READY_BORDER_COLOR"] = "Ready border color"
--[[Translation missing --]]
L["READY_FOREGROUND_COLOR"] = "Ready foreground color"
--[[Translation missing --]]
L["REMAINING"] = "Remaining"
--[[Translation missing --]]
L["REMOVE_SPACING_FOR_HIDDEN_ICONS"] = "Remove spacing for hidden icons"
--[[Translation missing --]]
L["RESET_SAVED_ANCHORS"] = "Reset saved anchors"
--[[Translation missing --]]
L["REVERSE"] = "Reverse"
--[[Translation missing --]]
L["REVERSE_GLOW"] = "Reverse glow"
--[[Translation missing --]]
L["RIGHT"] = "Right"
--[[Translation missing --]]
L["SAFE"] = "Safe"
--[[Translation missing --]]
L["SAFE_COLOR"] = "Safe color"
--[[Translation missing --]]
L["SAFE_COLOR_FADED"] = "Safe color faded"
--[[Translation missing --]]
L["SAVE_ANCHOR"] = "Save anchor"
--[[Translation missing --]]
L["SCALE"] = "Scale"
--[[Translation missing --]]
L["SELECT_GROUP"] = "Select Group"
--[[Translation missing --]]
L["SETTING_CHANGED_THAT_REQUIRES_A_RELOAD"] = "Setting changed that requires a reload."
--[[Translation missing --]]
L["SHOW"] = "Show"
--[[Translation missing --]]
L["SHOW_FRACTIONS"] = "Show fractions"
--[[Translation missing --]]
L["SHOW_GCD_SWIPE"] = "Show GCD swipe"
--[[Translation missing --]]
L["SHOW_ICON"] = "Show icon"
--[[Translation missing --]]
L["SHOW_KEYBINDINGS"] = "Show keybindings"
--[[Translation missing --]]
L["SHOW_OUTLINE"] = "Show outline"
--[[Translation missing --]]
L["SHOW_SHADOW"] = "Show shadow"
--[[Translation missing --]]
L["SHOW_SWIPE"] = "Show swipe"
--[[Translation missing --]]
L["SHOW_TOOLTIPS"] = "Show tooltips"
--[[Translation missing --]]
L["SITUATION"] = "Situation"
--[[Translation missing --]]
L["SKYRIDING_ZONE"] = "Skyriding Zone"
--[[Translation missing --]]
L["SLASH_DESIGN"] = "design"
--[[Translation missing --]]
L["SLASH_DESIGN_HELP"] = "Enter/Leave Coolinator Designer mode"
--[[Translation missing --]]
L["SLASH_HELP"] = "Open the Coolinator settings."
--[[Translation missing --]]
L["SLASH_REGEN"] = "regen"
--[[Translation missing --]]
L["SLASH_REGEN_HELP"] = "Start afresh on the current character with your design"
--[[Translation missing --]]
L["SLASH_RESET"] = "reset"
--[[Translation missing --]]
L["SLASH_RESET_HELP"] = "Reset all Coolinator settings, then reload."
--[[Translation missing --]]
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"
--[[Translation missing --]]
L["SPEC_MISMATCH_IN_BLIZZARD_CDM"] = "Specialization data mismatch in Blizzard CDM"
--[[Translation missing --]]
L["SQUARE"] = "Square"
--[[Translation missing --]]
L["STACK"] = "Stack"
--[[Translation missing --]]
L["START"] = "Start"
--[[Translation missing --]]
L["STYLE"] = "Style"
--[[Translation missing --]]
L["SWIPE_COLOR"] = "Swipe color"
--[[Translation missing --]]
L["TARGET"] = "Target"
--[[Translation missing --]]
L["TEXTS"] = "Texts"
--[[Translation missing --]]
L["TEXTURES"] = "Textures"
--[[Translation missing --]]
L["THANKS_FOR_USING_COOLINATOR_DONATE"] = "Thanks for using Coolinator. Consider donating to support development"
--[[Translation missing --]]
L["THAT_DESIGN_NAME_ALREADY_EXISTS"] = "That design name already exists"
--[[Translation missing --]]
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
--[[Translation missing --]]
L["THRESHOLDS"] = "Thresholds"
--[[Translation missing --]]
L["TIP_OF_THE_SPEAR"] = "Tip of the Spear"
--[[Translation missing --]]
L["TO_OPEN_OPTIONS_X"] = "Access options with /cooli"
--[[Translation missing --]]
L["TOP"] = "Top"
--[[Translation missing --]]
L["TOP_LEFT"] = "Top Left"
--[[Translation missing --]]
L["TOP_RIGHT"] = "Top Right"
--[[Translation missing --]]
L["TOTAL"] = "Total"
--[[Translation missing --]]
L["TRANSPARENCY"] = "Transparency"
--[[Translation missing --]]
L["UNINTERRUPTABLE"] = "Uninterruptable"
--[[Translation missing --]]
L["UNLEARNED"] = "Unlearned"
--[[Translation missing --]]
L["USE_BLIZZARD_WIDGETS"] = "Use Blizzard widgets (no styling)"
--[[Translation missing --]]
L["USE_MASQUE"] = "Use Masque"
--[[Translation missing --]]
L["USE_PERCENTAGE"] = "Use percentage"
--[[Translation missing --]]
L["UTILITY"] = "Utility"
--[[Translation missing --]]
L["VALUE"] = "Value"
--[[Translation missing --]]
L["VERSION_COLON_X"] = "Version: %s"
--[[Translation missing --]]
L["VERTICAL"] = "Vertical"
--[[Translation missing --]]
L["VISIBILITY"] = "Visibility"
--[[Translation missing --]]
L["VISIBLE"] = "Visible"
--[[Translation missing --]]
L["WARNING"] = "Warning"
--[[Translation missing --]]
L["WARNING_COLOR"] = "Warning color"
--[[Translation missing --]]
L["WARNING_COLOR_FADED"] = "Warning color faded"
--[[Translation missing --]]
L["WHAT_TO_EXPORT"] = "What to export?"
--[[Translation missing --]]
L["WHEN_ACTIVE"] = "When active"
--[[Translation missing --]]
L["WHEN_INACTIVE"] = "When inactive"
--[[Translation missing --]]
L["WHEN_ON_COOLDOWN"] = "When on cooldown"
--[[Translation missing --]]
L["WHEN_READY"] = "When ready"
--[[Translation missing --]]
L["WIDTH"] = "Width"
--[[Translation missing --]]
L["WIDTH_RESTRICTION"] = "Width restriction"
--[[Translation missing --]]
L["WORLD"] = "World"

