-- enUS.lua (Default Locale)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "enUS", true)
if not L then return end

-- Core
L["Cannot open options in combat."] = true
L["MiniCC test command is unavailable."] = true
L["sArena slash command is unavailable."] = true

-- Category Names
L["Action Bars"] = true
L["Nameplates"] = true
L["Unit Frames"] = true
L["Party / Raid Frames"] = true
L["CooldownManager"] = true
L["MiniCC"] = true
L["sArena"] = true
L["TellMeWhen"] = true
L["Profiles"] = true

-- Group Headers
L["General"] = true
L["Typography (Cooldown Numbers)"] = true
L["Swipe Animation"] = true
L["Stack Counters / Charges"] = true
L["Maintenance"] = true
L["Danger Zone"] = true
L["Style"] = true
L["Positioning"] = true
L["CooldownManager Viewers"] = true
L["MiniCC Frame Types"] = true
L["sArena Cooldown Types"] = true

-- Toggles & Settings
L["Enable %s"] = true
L["Toggle styling for this category."] = true
L["Font Face"] = true
L["Font"] = true
L["Size"] = true
L["Outline"] = true
L["Color"] = true
L["Hide Numbers"] = true
L["Only Mine"] = true
L["Compact Party / Raid Aura Text"] = true
L["Enable Party Aura Text"] = true
L["Enable Raid Aura Text"] = true
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = true
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = true
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = true
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = true
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = true
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = true
L["Anchor Point"] = true
L["Offset X"] = true
L["Offset Y"] = true
L["Buff / Debuff Size"] = true
L["Defensive Buff Size"] = true
L["Essential Viewer Size"] = true
L["Utility Viewer Size"] = true
L["Buff Icon Viewer Size"] = true
L["CC Text Size"] = true
L["Class Icon Text Size"] = true
L["DR Cooldown Text Size"] = true
L["Nameplates Text Size"] = true
L["Portraits Text Size"] = true
L["Alerts / Overlay Text Size"] = true
L["Trinket / Racial Text Size"] = true
L["Toggle Test Icons"] = true
L["Show Test Frames"] = true
L["Hide Test Frames"] = true
L["Show Swipe Animation"] = true
L["Shows the dark overlay that sweeps during a cooldown."] = true
L["Show Swipe Edge"] = true
L["Shows the white line indicating cooldown progress."] = true
L["Edge Thickness"] = true
L["Scale of the swipe line (1.0 = Default)."] = true
L["Swipe Shade Alpha"] = true
L["0% = transparent, 100% = full dark."] = true
L["Customize Stack Text"] = true
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = true
L["Hide Charge Timers"] = true
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = true
L["Hide Stack Text"] = true
L["Hide stacks and charges entirely."] = true
L["Reset %s"] = true
L["Revert this category to default settings."] = true
L["Toggle MiniCC's built-in test icons using /minicc test."] = true
L["Show sArena test frames using /sarena test."] = true
L["Hide sArena test frames using /sarena hide."] = true

-- Outline Values
L["None"] = true
L["Thick"] = true
L["Mono"] = true

-- Anchor Point Values
L["Bottom Right"] = true
L["Bottom Left"] = true
L["Top Right"] = true
L["Top Left"] = true
L["Center"] = true

-- General Tab
L["Factory Reset (All)"] = true
L["Resets the entire profile to default values and reloads the UI."] = true
L["Import / Export"] = true
L["PROFILE_IMPORT_EXPORT_DESC"] = "Export the active AceDB profile to a shareable string, or import a string to replace the current profile settings."
L["Export current profile"] = true
L["Generate export"] = true
L["Export code"] = true
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = true
L["Import profile"] = true
L["Import code"] = true
L["Paste an exported string here, then click Import."] = true
L["Import"] = true
L["Importing will overwrite the current profile settings. Continue?"] = true
L["Export string generated. Copy it with Ctrl+C."] = true
L["Profile import completed."] = true
L["No active profile available."] = true
L["Failed to encode export string."] = true
L["Paste an import string first."] = true
L["Invalid import string format."] = true
L["Failed to decode import string."] = true
L["Failed to decompress import string."] = true
L["Failed to deserialize import string."] = true

-- Banner
L["BANNER_DESC"] = "Minimalist configuration for your cooldowns. Select a category on the left to begin."

-- Chat Messages
L["%s settings reset."] = true
L["Profile reset. Reloading UI..."] = true

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"

-- General Dashboard
L["Enable categories styling"] = true
L["LIVE_CONTROLS_DESC"] = "Changes apply instantly. Keep only the categories you actively use enabled for a cleaner setup."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Enable Party / Raid Frames acts as the master switch for this category. Enable Raid Aura Text extends the same styling to Blizzard raid frames."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = true
L["Copy this link to view other projects from Anahkas on CurseForge."] = true

-- Help
L["Help & Support"] = true
L["Project"] = true
L["Useful Addons"] = true
L["Support & Feedback"] = true
L["MCE_HELP_INTRO"] = "Quick project links and a couple of addons worth trying."
L["HELP_SUPPORT_DESC"] = "Suggestions and feedback are always welcome.\n\nIf you find a bug or have a feature idea, feel free to leave a comment or private message on CurseForge."
L["HELP_COMPANION_DESC"] = "Clean picks that pair well with MiniCE."
L["HELP_MINICC_DESC"] = "Compact CC tracker. MiniCE can style its text too."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = true
L["HELP_PVPTAB_DESC"] = "Makes TAB target players only in PvP. Great for arenas and battlegrounds."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = true

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Toggle your main cooldown categories from one place."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "This action cannot be undone. Your profile will be completely reset and the UI will reload."
L["MAINTENANCE_DESC"] = "Revert this category to factory defaults. Other categories are not affected."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Customize cooldowns on your main action bars, including Bartender4 and Dominos."
L["NAMEPLATE_DESC"] = "Style cooldowns displayed on enemy and friendly nameplates (Plater, KuiNameplates, etc.)."
L["UNITFRAME_DESC"] = "Adjust cooldown styling on player, target, and focus unit frames."
L["COOLDOWNMANAGER_DESC"] = "Shared icon styling for CooldownManager viewers. Countdown text size can be set independently for Essential, Utility, and Buff Icon viewers."
L["MINICC_DESC"] = "Dedicated styling for MiniCC cooldown icons. Supports MiniCC crowd control icons, nameplates, portraits, and overlay-style modules when MiniCC is loaded."
L["SARENA_DESC"] = "Dedicated styling for sArena_Reloaded cooldown timers. Supports class icon, DR, and trinket/racial cooldown text when sArena_Reloaded is loaded."
L["TELLMEWHEN_DESC"] = "Dedicated styling for TellMeWhen cooldown sweeps. Supports TellMeWhen icon cooldown and charge cooldown frames when TellMeWhen is loaded."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = true
L["Color by Remaining Time"] = true
L["Dynamically colors the countdown text based on how much time is left."] = true
L["DYNAMIC_COLORS_DESC"] = "Changes the text color based on the remaining cooldown duration. Overrides the static color above when enabled."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Remaining-time thresholds can be allowed or blocked per MiniCE category, including Compact Party / Raid aura text. Midnight-safe duration handling is used when Blizzard exposes secret values."
L["Allow Threshold Colors"] = true
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = true
L["Behavior"] = true
L["Expiring Soon"] = true
L["Short Duration"] = true
L["Long Duration"] = true
L["Advanced Threshold Settings"] = true
L["Threshold Colors"] = true
L["THRESHOLD_COLORS_DESC"] = "Each band defines the cutoff and color used for that remaining-time range."
L["Threshold (seconds)"] = true
L["Threshold Transition Offset"] = true
L["Moves the start of each next color band. Negative values switch slightly earlier."] = true
L["Beyond Thresholds Color"] = true
L["Default Color"] = true
L["Color used when the remaining time exceeds all thresholds."] = true

-- Abbreviation
L["Abbreviate Above"] = true
L["Abbreviate Above (seconds)"] = true
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = true
L["ABBREV_THRESHOLD_DESC"] = "Controls when cooldown numbers switch to abbreviated format. Timers above this threshold display shortened values like 5m or 1h."

-- 自行加入
L["MiniCE"] = true
L["MinimalistCooldownEdge"] = true
