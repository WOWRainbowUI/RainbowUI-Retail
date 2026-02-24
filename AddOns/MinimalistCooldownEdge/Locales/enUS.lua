-- enUS.lua (Default Locale)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "enUS", true)
if not L then return end

-- Core
L["Cannot open options in combat."] = true

-- Category Names
L["Action Bars"] = true
L["Nameplates"] = true
L["Unit Frames"] = true
L["CD Manager & Others"] = true

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
L["Clear Debug Log"] = true
L["Clears the saved debug log data."] = true
L["Debug log cleared."] = true

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Customize cooldowns on your main action bars, including Bartender4, Dominos, and ElvUI bars."
L["NAMEPLATE_DESC"] = "Style cooldowns displayed on enemy and friendly nameplates (Plater, KuiNameplates, etc.)."
L["UNITFRAME_DESC"] = "Adjust cooldown styling on player, target, and focus unit frames."
L["GLOBAL_DESC"] = "Catch-all for cooldowns that don't belong to other categories (bags, menus, misc addons)."
