-- enUS.lua (Default Locale)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "enUS", true)
if not L then return end

-- Core
L["Cannot open options in combat."] = true

-- Category Names
L["Action Bars"] = true
L["Nameplates"] = true
L["Unit Frames"] = true
L["CooldownManager"] = true
L["Others"] = true

-- Group Headers
L["General"] = true
L["State"] = true
L["Typography (Cooldown Numbers)"] = true
L["Swipe Animation"] = true
L["Stack Counters / Charges"] = true
L["Maintenance"] = true
L["Performance & Detection"] = true
L["Danger Zone"] = true
L["Style"] = true
L["Positioning"] = true
L["CooldownManager Viewers"] = true

-- Toggles & Settings
L["Enable %s"] = true
L["Toggle styling for this category."] = true
L["Font Face"] = true
L["Game Default"] = true
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
L["Show Swipe Edge"] = true
L["Shows the white line indicating cooldown progress."] = true
L["Edge Thickness"] = true
L["Scale of the swipe line (1.0 = Default)."] = true
L["Customize Stack Text"] = true
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = true
L["Reset %s"] = true
L["Revert this category to default settings."] = true

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
L["Scan Depth"] = true
L["How deep the addon looks into UI frames to find cooldowns."] = true
L["Factory Reset (All)"] = true
L["Resets the entire profile to default values and reloads the UI."] = true

-- Banner
L["BANNER_DESC"] = "Minimalist configuration for your cooldowns. Select a category on the left to begin."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Efficient (Default UI)\n|cfffff56910 - 15|r : Moderate (Bartender, Dominos)\n|cffffa500> 15|r : Heavy (ElvUI, Complex frames)"

-- Chat Messages
L["%s settings reset."] = true
L["Profile reset. Reloading UI..."] = true
L["Global Scan Depth changed. A /reload is recommended."] = true

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"
L["Category Status"] = true

-- Tools
L["Tools"] = true
L["Force Refresh"] = true
L["Force a full rescan of all cooldown frames."] = true
L["Full refresh completed."] = true

-- Links
L["Links"] = true
L["LINKS_DESC"] = "Useful project links for updates, changelogs, and downloads."
L["CurseForge URL"] = true
L["Copy this link to open the CurseForge project page in your browser."] = true
L["Developer Page"] = true
L["Copy this link to view other projects from Anahkas on CurseForge."] = true

-- Help
L["Help"] = true
L["Project Information"] = true
L["Development Status"] = true
L["HELP_ABOUT_DESC"] = "MinimalistCooldownEdge is a lightweight cooldown styling addon focused on clarity, performance, and a clean interface."
L["HELP_DEVELOPMENT_DESC"] = "This addon is still actively being developed and improved over time."
L["HELP_FEEDBACK_DESC"] = "Suggestions, feedback, and reviews are very welcome and help shape future improvements."

-- Quick Toggles Dashboard
L["Quick Toggles"] = true
L["QUICK_TOGGLES_DESC"] = "Enable or disable categories at a glance. Changes apply instantly."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "This action cannot be undone. Your profile will be completely reset and the UI will reload."
L["MAINTENANCE_DESC"] = "Revert this category to factory defaults. Other categories are not affected."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Customize cooldowns on your main action bars, including Bartender4, Dominos, and ElvUI bars."
L["NAMEPLATE_DESC"] = "Style cooldowns displayed on enemy and friendly nameplates (Plater, KuiNameplates, etc.)."
L["UNITFRAME_DESC"] = "Adjust cooldown styling on player, target, and focus unit frames."
L["COOLDOWNMANAGER_DESC"] = "Shared icon styling for CooldownManager viewers. Countdown text size can be set independently for Essential, Utility, and Buff Icon viewers."
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
