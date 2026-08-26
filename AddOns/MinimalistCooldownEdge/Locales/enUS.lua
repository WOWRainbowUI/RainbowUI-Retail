-- enUS.lua (Default Locale)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "enUS", true)
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras owns countdown threshold colours. Configure them in MiniAuras > Misc > Countdown Colours."
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% = transparent, 100% = full dark. Replaces the MyDRs Cooldown Swipe Alpha setting while this category is enabled; 100% matches the swipe MyDRs draws itself."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% = transparent, 100% = full dark. Applies to every MiniAuras module group; 80% matches the swipe MiniAuras draws itself."
L["SHACKLED_SWIPE_ALPHA_DESC"] = "0% = transparent, 100% = full dark. Shackled draws a plain Blizzard-default swipe, so this simply re-shades it."

-- Core
L["MiniAuras test command is unavailable."] = true
L["MyDRs test command is unavailable."] = true
L["Toggle MyDRs' built-in test icons using /mydrs test."] = true
L["sArena slash command is unavailable."] = true

-- Category Names
L["Action Bars"] = true
L["Nameplates"] = true
L["Unit Frames"] = true
L["Player Auras"] = true
L["Party / Raid Frames"] = true
L["CooldownManager"] = true
L["CooldownManagerCentered"] = true
L["HealerCC"] = true
L["MiniAuras"] = true
L["MyDRs"] = true
L["sArena"] = true
L["TellMeWhen"] = true
L["Shackled"] = true
L["Profiles"] = true
L["ShinyAuras"] = true
L["Dominos"] = true
L["ElvUI"] = true

-- Group Headers
L["General"] = true
L["Typography (Cooldown Numbers)"] = true
L["Swipe Animation"] = true
L["Swipe Edge"] = true
L["Stack Counters / Charges"] = true
L["Maintenance"] = true
L["Danger Zone"] = true
L["Style"] = true
L["Positioning"] = true
L["CooldownManager Viewers"] = true
L["MiniAuras Frame Types"] = true
L["MiniAuras Module Groups"] = true
L["sArena Cooldown Types"] = true
L["Aura Targets"] = true
L["Buff Styling"] = true
L["Debuff Styling"] = true
L["External Defensive Buffs Styling"] = true

-- Toggles & Settings
L["Enable %s"] = true
L["Toggle styling for this category."] = true
L["Style Buffs"] = true
L["Style Debuffs"] = true
L["Style External Defensive Buffs"] = true
L["Style Blizzard's default player buff buttons."] = true
L["Style Blizzard's default player debuff buttons."] = true
L["Style Blizzard's external defensive buff buttons."] = true
L["Font Face"] = true
L["Font"] = true
L["Size"] = true
L["Outline"] = true
L["Color"] = true
L["Hide Numbers"] = true
L["Timer Inside Icon"] = true
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = true
L["Hide Swipe"] = true
L["Only Mine (Timer Text)"] = true
L["Aura Visibility"] = true
L["Only My Debuffs"] = true
L["Only My Buffs"] = true
L["Disable fading/blinking"] = true
L["Compact Party / Raid Aura Text"] = true
L["Enable Party Aura Text"] = true
L["Enable Raid Aura Text"] = true
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = true
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = true
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = true
L["Hide the swipe animation for this frame group (countdown text still shows)."] = true
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = true
L["UNITFRAME_ONLY_MINE_DESC"] = "Only show cooldown timer text on auras cast by you. MiniCE's WoW 12.1 target/focus containers use Blizzard's Player filter; compatible addon and legacy frames use their group metadata or the large-aura fallback."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Hide debuffs cast by other players on the target and focus frames. MiniCE owns these aura containers on WoW 12.1, so Blizzard's own debuff filter no longer reaches them."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Hide buffs cast by other players on the target and focus frames. MiniCE owns these aura containers on WoW 12.1, so Blizzard's own buff filter no longer reaches them."
L["Cast Bar"] = true
L["Reposition Cast Bar"] = true
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Anchor the target and focus cast bars below the last buff/debuff row. MiniCE owns these aura containers on WoW 12.1, so Blizzard's cast bar otherwise stays pinned to the frame and overlaps them."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = true
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = true
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = true
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = true
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = true
L["Anchor Point"] = true
L["Offset X"] = true
L["Offset Y"] = true
L["Buff / Debuff Size"] = true
L["Defensive Buff Size"] = true
L["Use Buff Color"] = true
L["Buff Color"] = true
L["Essential Viewer"] = true
L["Utility Viewer"] = true
L["Buff Icon Viewer"] = true
L["Essential Viewer Size"] = true
L["Utility Viewer Size"] = true
L["Buff Icon Viewer Size"] = true
L["Essential Viewer Stack Size"] = true
L["Utility Viewer Stack Size"] = true
L["Buff Icon Viewer Stack Size"] = true
L["CC Text Size"] = true
L["CC Frames Text Size"] = true
L["CC / Friendly Frames Text Size"] = true
L["Raid Frame Auras Text Size"] = true
L["Class Icon Text Size"] = true
L["DR Cooldown Text Size"] = true
L["Nameplates Text Size"] = true
L["Portraits Text Size"] = true
L["Alerts / Overlay Text Size"] = true
L["Alerts / Trackers / Custom Auras Text Size"] = true
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
L["Reverse Swipe"] = true
L["Reverse the swipe direction so the shade fills in the opposite direction."] = true
L["Customize Stack Text"] = true
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = true
L["Hide Charge Timers"] = true
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = true
L["Hide Stack Text"] = true
L["Hide stacks and charges entirely."] = true
L["Reset %s"] = true
L["Revert this category to default settings."] = true
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = true
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = true
L["Applies to MiniAuras CC module (enemy crowd controls)."] = true
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = true
L["Applies to the MiniAuras Raid Frame Auras module."] = true
L["Applies to MiniAuras portrait icons."] = true
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = true
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
L["Top"] = true
L["Bottom"] = true
L["Left"] = true
L["Right"] = true

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
L["Import string is too large."] = true
L["Import profile contains invalid data."] = true
L["Failed to apply imported profile."] = true

-- Banner
L["BANNER_DESC"] = "Minimalist configuration for your cooldowns. Select a category on the left to begin."

-- Chat Messages
L["%s settings reset."] = true
L["Profile reset. Reloading UI..."] = true
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = true

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"
L["Retired"] = "Retired"

-- General Dashboard
L["Enable categories styling"] = true
L["Addon Integrations"] = true
L["LIVE_CONTROLS_DESC"] = "Changes apply instantly. Keep only the categories you actively use enabled for a cleaner setup."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Enable Party / Raid Frames acts as the master switch for this category. Enable Raid Aura Text extends the same styling to Blizzard raid frames."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "Party / Raid Frames support has been retired. Since Blizzard Patch 12.0.5, MiniCE no longer hooks or styles compact party and raid frames."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "New addon in development: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras is now available on CurseForge. It stays separate from MiniCE because it uses its own overlay frames instead of styling Blizzard's existing icons, which makes it a better fit as a standalone addon."
L["ADDON_INTEGRATIONS_DESC"] = "Enable or disable optional addon bridges that route external cooldowns into MiniCE categories."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = true
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = true
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = true
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = true
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = true

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = true
L["Copy this link to open Raid Frame Auras on CurseForge."] = true
L["Copy this link to view other projects from Anahkas on CurseForge."] = true

-- Help
L["Help & Support"] = true
L["Project"] = true
L["Useful Addons"] = true
L["Support & Feedback"] = true
L["MCE_HELP_INTRO"] = "Quick project links and a couple of addons worth trying."
L["HELP_SUPPORT_DESC"] = "Suggestions and feedback are always welcome.\n\nIf you find a bug or have a feature idea, feel free to leave a comment or private message on CurseForge."
L["HELP_COMPANION_DESC"] = "Clean picks that pair well with MiniCE."
L["HELP_MINIAURAS_DESC"] = "Custom aura, crowd-control, cooldown, and PvP display suite. MiniCE can style its cooldown text too."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = true
L["HELP_PVPTAB_DESC"] = "Makes TAB target players only in PvP. Great for arenas and battlegrounds."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = true
L["HELP_ARENADR_DESC"] = "Tracks enemy diminishing returns directly on nameplates in Arena."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = true

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Toggle your main cooldown categories from one place."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "This action cannot be undone. Your profile will be completely reset and the UI will reload."
L["MAINTENANCE_DESC"] = "Revert this category to factory defaults. Other categories are not affected."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Style cooldowns on your action bars."
L["NAMEPLATE_DESC"] = "Style cooldowns on enemy and friendly nameplates."
L["UNITFRAME_DESC"] = "Style aura cooldowns on target, focus, and supported unit frames."
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames is active, so MiniCE's Unit Frames styling has been disabled to prevent possible conflicts. A dedicated BetterBlizzFrames adapter is coming soon."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates is active, so MiniCE's Nameplates styling has been disabled to prevent possible conflicts."
L["PLAYERAURA_DESC"] = "Style Blizzard player buff and debuff cooldowns."
L["COOLDOWNMANAGER_DESC"] = "Style CooldownManager icon cooldowns."
L["HEALERCC_DESC"] = "Style friendly and enemy HealerCC alert cooldowns."
L["MINIAURAS_DESC"] = "Style MiniAuras cooldown icons."
L["MYDRS_DESC"] = "Style MyDRs diminishing-returns icon cooldowns. MyDRs keeps its own DR state label (50% / IMM)."
L["SARENA_DESC"] = "Style sArena_Reloaded cooldown timers."
L["TELLMEWHEN_DESC"] = "Style TellMeWhen cooldown text and swipe edges."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "Timer visibility, timer text, shading direction, and GCD display remain controlled by TellMeWhen. Swipe edge visibility and thickness are controlled here."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Scales the TellMeWhen swipe edge when MiniCE has enabled it."
L["SHACKLED_DESC"] = "Style Shackled's enemy CC-tracker icon cooldowns. Shackled draws its own remaining-time text; MiniCE takes over its font, size, color, and swipe."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = true
L["Color by Remaining Time"] = true
L["Dynamically colors the countdown text based on how much time is left."] = true
L["DYNAMIC_COLORS_DESC"] = "Changes the text color based on the remaining cooldown duration. Overrides the static color above when enabled."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Remaining-time thresholds can be allowed or blocked per active MiniCE category. Midnight-safe duration handling is used when Blizzard exposes secret values."
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
L["Show Tenths Below (seconds)"] = true
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = true
L["ABBREV_THRESHOLD_DESC"] = "Controls when cooldown numbers switch to abbreviated format. Timers above this threshold display shortened values like 5m or 1h."

-- Performance Warning
L["PERF_WARNING_DESC"] = "This feature may impact performance and cause FPS drops. Use only on strong setups."

-- Font Options
L["Game Default"] = true
