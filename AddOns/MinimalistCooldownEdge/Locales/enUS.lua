-- enUS.lua (Default Locale)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "enUS", true)
if not L then return end

-- Core
L["Cannot open options in combat."] = true
L["MiniCC test command is unavailable."] = true

-- Category Names
L["Action Bars"] = true
L["Nameplates"] = true
L["Unit Frames"] = true
L["CooldownManager"] = true
L["MiniCC"] = true
L["Others"] = true

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

-- Toggles & Settings
L["Enable %s"] = true
L["Toggle styling for this category."] = true
L["Font Face"] = true
L["Font"] = true
L["Size"] = true
L["Outline"] = true
L["Color"] = true
L["Hide Numbers"] = true
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = true
L["Anchor Point"] = true
L["Offset X"] = true
L["Offset Y"] = true
L["Essential Viewer Size"] = true
L["Utility Viewer Size"] = true
L["Buff Icon Viewer Size"] = true
L["CC Text Size"] = true
L["Nameplates Text Size"] = true
L["Portraits Text Size"] = true
L["Alerts / Overlay Text Size"] = true
L["Toggle Test Icons"] = true
L["Show Swipe Edge"] = true
L["Shows the white line indicating cooldown progress."] = true
L["Edge Thickness"] = true
L["Scale of the swipe line (1.0 = Default)."] = true
L["Customize Stack Text"] = true
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = true
L["Reset %s"] = true
L["Revert this category to default settings."] = true
L["Toggle MiniCC's built-in test icons using /minicc test."] = true

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
L["ACTIONBAR_DESC"] = "Customize cooldowns on your main action bars, including Bartender4, Dominos, and ElvUI bars."
L["NAMEPLATE_DESC"] = "Style cooldowns displayed on enemy and friendly nameplates (Plater, KuiNameplates, etc.)."
L["UNITFRAME_DESC"] = "Adjust cooldown styling on player, target, and focus unit frames."
L["COOLDOWNMANAGER_DESC"] = "Shared icon styling for CooldownManager viewers. Countdown text size can be set independently for Essential, Utility, and Buff Icon viewers."
L["MINICC_DESC"] = "Dedicated styling for MiniCC cooldown icons. Supports MiniCC crowd control icons, nameplates, portraits, and overlay-style modules when MiniCC is loaded."
L["OTHERS_DESC"] = "Catch-all for cooldowns that don't belong to other categories (bags, menus, misc addons)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = true
L["Color by Remaining Time"] = true
L["Dynamically colors the countdown text based on how much time is left."] = true
L["DYNAMIC_COLORS_DESC"] = "Changes the text color based on the remaining cooldown duration. Overrides the static color above when enabled."
L["Expiring Soon"] = true
L["Short Duration"] = true
L["Long Duration"] = true
L["Beyond Thresholds"] = true
L["Threshold (seconds)"] = true
L["Default Color"] = true
L["Color used when the remaining time exceeds all thresholds."] = true

-- 自行加入
L["MiniCE"] = true
L["MinimalistCooldownEdge"] = true
