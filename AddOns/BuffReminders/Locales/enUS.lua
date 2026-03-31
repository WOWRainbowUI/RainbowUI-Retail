local _, BR = ...

-- ============================================================================
-- LOCALIZATION (English - Default)
-- ============================================================================
-- This file defines all user-facing strings for BuffReminders.
-- Keys use PascalCase dot notation: "Section.SubSection.Key"
-- Missing translations fall back to English automatically.

-- English strings (used as fallback for missing translations)
local english = {}

-- L reads from the main table first, falls back to english table
local L = setmetatable({}, {
    __index = english,
})
BR.L = L

-- ============================================================================
-- CATEGORY LABELS
-- ============================================================================
english["Category.Raid"] = "Raid"
english["Category.Presence"] = "Presence"
english["Category.Targeted"] = "Targeted"
english["Category.Self"] = "Self"
english["Category.Pet"] = "Pet"
english["Category.Consumable"] = "Consumable"
english["Category.Custom"] = "Custom"

-- Long form (used in Options section headers)
english["Category.RaidBuffs"] = "Raid Buffs"
english["Category.TargetedBuffs"] = "Targeted Buffs"
english["Category.Consumables"] = "Consumables"
english["Category.PresenceBuffs"] = "Presence Buffs"
english["Category.SelfBuffs"] = "Self Buffs"
english["Category.PetReminders"] = "Pet Reminders"
english["Category.CustomBuffs"] = "Custom Buffs"

-- Category notes
english["Category.RaidNote"] = "(for the whole group)"
english["Category.TargetedNote"] = "(buffs on someone else)"
english["Category.ConsumableNote"] = "(flasks, food, runes, oils)"
english["Category.PresenceNote"] = "(at least 1 person needs)"
english["Category.SelfNote"] = "(buffs strictly on yourself)"
english["Category.PetNote"] = "(pet summon reminders)"
english["Category.CustomNote"] = "(track any buff/glow by spell ID)"

-- ============================================================================
-- BUFF OVERLAY TEXT
-- ============================================================================
-- These must be kept very short (2-4 chars per line) to fit on small icons.
english["Overlay.NoDrPoison"] = "NO\nDR\nPOISON"
english["Overlay.NoAura"] = "NO\nAURA"
english["Overlay.NoStone"] = "NO\nSTONE"
english["Overlay.NoFaith"] = "NO\nFAITH"
english["Overlay.NoLight"] = "NO\nLIGHT"
english["Overlay.NoES"] = "NO\nES"
english["Overlay.NoSource"] = "NO\nSOURCE"
english["Overlay.NoScales"] = "NO\nSCALES"
english["Overlay.NoLink"] = "NO\nLINK"
english["Overlay.NoAttune"] = "NO\nATTUNE"
english["Overlay.NoFamiliar"] = "NO\nFAMILIAR"
english["Overlay.DropWell"] = "DROP\nWELL"
english["Overlay.NoGrim"] = "NO\nGRIM"
english["Overlay.NoRite"] = "NO\nRITE"
english["Overlay.ApplyPoison"] = "APPLY\nPOISON"
english["Overlay.NoForm"] = "NO\nFORM"
english["Overlay.NoEL"] = "NO\nEL"
english["Overlay.NoFT"] = "NO\nFT"
english["Overlay.NoTG"] = "NO\nTG"
english["Overlay.NoWF"] = "NO\nWF"
english["Overlay.NoSelfES"] = "NO\nSELF ES"
english["Overlay.NoShield"] = "NO\nSHIELD"
english["Overlay.NoPet"] = "NO\nPET"
english["Overlay.PassivePet"] = "PASSIVE\nPET"
english["Overlay.WrongPet"] = "WRONG\nPET"
english["Overlay.NoRune"] = "NO\nRUNE"
english["Overlay.NoFlask"] = "NO\nFLASK"
english["Overlay.NoFood"] = "NO\nFOOD"
english["Overlay.NoWeaponBuff"] = "NO\nWEAPON\nBUFF"
english["Overlay.Buff"] = "BUFF!"
english["Overlay.MinutesFormat"] = "%dm"
english["Overlay.LessThanOneMinute"] = "<1m"
english["Overlay.SecondsFormat"] = "%ds"

-- ============================================================================
-- BUFF GROUP DISPLAY NAMES
-- ============================================================================
english["Group.Beacons"] = "Beacons"
english["Group.ShamanImbues"] = "Shaman Imbues"
english["Group.PaladinRites"] = "Paladin Rites"
english["Group.Pets"] = "Pets"
english["Group.ShamanShields"] = "Shaman Shields"
english["Group.Flask"] = "Flask"
english["Group.Food"] = "Food"
english["Group.DelveFood"] = "Delve Food"
english["Group.Healthstone"] = "Healthstone"
english["Group.AugmentRune"] = "Augment Rune"
english["Group.WeaponBuff"] = "Weapon Buff"

-- ============================================================================
-- BUFF INFO TOOLTIPS
-- ============================================================================
english["Tooltip.MayShowExtraIcon"] = "May Show Extra Icon"
english["Tooltip.MayShowExtraIcon.Desc"] =
    "Until you cast this, you might see both this and the Water/Lightning Shield reminder. I can't tell if you want Earth Shield on yourself, or Earth Shield on an ally + Water/Lightning Shield on yourself."
english["Tooltip.InstanceEntryReminder"] = "Instance Entry Reminder"
english["Tooltip.InstanceEntryReminder.Desc"] =
    "Briefly shown when entering a dungeon as a reminder to drop a Soulwell. Dismissed after casting or after 30 seconds."
english["Tooltip.DelvesOnly"] = "Delves Only"
english["Tooltip.DelvesOnly.Desc"] =
    "Briefly shown when entering a delve as a reminder to eat Valeera's food. Disappears after 30 seconds or when the buff is detected."

-- ============================================================================
-- GLOW TYPE NAMES
-- ============================================================================
english["Glow.Pixel"] = "Pixel"
english["Glow.AutoCast"] = "AutoCast"
english["Glow.Border"] = "Border"
english["Glow.Proc"] = "Proc"

-- ============================================================================
-- CORE
-- ============================================================================
english["Core.Any"] = "Any"

-- ============================================================================
-- PROFILES
-- ============================================================================
english["Profile.SwitchQueued"] = "Profile switch queued until combat ends."
english["Profile.Switched"] = "Switched to profile '%s'."

-- ============================================================================
-- MOVERS
-- ============================================================================
english["Mover.SetPosition"] = "Set Position"
english["Mover.AnchorFrame"] = "Anchor Frame"
english["Mover.AnchorPoint"] = "Anchor Point"
english["Mover.NoneScreenCenter"] = "None (Screen Center)"
english["Mover.Apply"] = "Apply"
english["Mover.BuffAnchor"] = "Buff Anchor"
english["Mover.DragTooltip"] = "Drag to reposition\nClick to toggle coordinate editor"
english["Mover.MainEmpty"] = "Main (empty)"
english["Mover.MainAll"] = "Main (all)"

-- ============================================================================
-- DISPLAY
-- ============================================================================
english["Display.FramesLocked"] = "Frames locked."
english["Display.FramesUnlocked"] = "Frames unlocked."
english["Display.MinimapHidden"] = "Minimap icon hidden."
english["Display.MinimapShown"] = "Minimap icon shown."
english["Display.Description"] = "Track missing buffs at a glance."
english["Display.OpenOptions"] = "Open Options"
english["Display.SlashCommands"] = "Slash commands: /br, /br lock, /br unlock, /br test, /br minimap"
english["Display.MinimapLeftClick"] = "|cFFCFCFCFLeft click|r: Options"
english["Display.MinimapRightClick"] = "|cFFCFCFCFRight click|r: Test mode"
english["Display.DismissConsumables"] = "Hide consumable reminders until next loading screen"

-- ============================================================================
-- OPTIONS: TAB LABELS
-- ============================================================================
english["Tab.Buffs"] = "Buffs"
english["Tab.DisplayBehavior"] = "Display/Behavior"
english["Tab.Settings"] = "Settings"
english["Tab.Profiles"] = "Profiles"

-- ============================================================================
-- OPTIONS: GLOBAL DEFAULTS
-- ============================================================================
english["Options.GlobalDefaults"] = "Global Defaults"
english["Options.GlobalDefaults.Note"] = "(All categories inherit these unless overridden with a custom appearance)"
english["Options.Default"] = "Default"
english["Options.Font"] = "Font"

-- ============================================================================
-- OPTIONS: GLOW SETTINGS
-- ============================================================================
english["Options.GlowReminderIcons"] = "Glow reminder icons"
english["Options.GlowReminderIcons.Title"] = "Glow Reminder Icons"
english["Options.GlowReminderIcons.Desc"] =
    "Add a glow effect to all visible reminder icons, including missing and expiring buffs."
english["Options.Threshold"] = "Threshold"
english["Options.GlowMissingPets"] = "Glow missing pets"
english["Options.CustomGlowStyle"] = "Custom glow style"
english["Options.Expiration"] = "Expiration"
english["Options.Glow"] = "Glow"
english["Options.UseCustomColor"] = "Use Custom Color"
english["Options.UseCustomColor.Desc"] =
    "When enabled, the proc glow is desaturated and recolored.\nThis looks less vibrant than the default proc glow."
english["Options.ExpirationReminder"] = "Expiration Reminder"
english["Options.GlowSettings"] = "Glow Settings"

-- Glow params
english["Options.Glow.Type"] = "Type:"
english["Options.Glow.Size"] = "Size:"
english["Options.Glow.Duration"] = "Duration"
english["Options.Glow.Frequency"] = "Frequency"
english["Options.Glow.Length"] = "Length"
english["Options.Glow.Lines"] = "Lines"
english["Options.Glow.Particles"] = "Particles"
english["Options.Glow.Scale"] = "Scale"
english["Options.Glow.Speed"] = "Speed"
english["Options.Glow.StartAnimation"] = "Start Animation"
english["Options.Glow.XOffset"] = "X Offset"
english["Options.Glow.YOffset"] = "Y Offset"

-- ============================================================================
-- OPTIONS: CONTENT VISIBILITY
-- ============================================================================
english["Options.HidePvPMatchStart"] = "Hide when PvP match starts"
english["Options.HidePvPMatchStart.Title"] = "Hide When PvP Match Starts"
english["Options.HidePvPMatchStart.Desc"] = "Hide this category once a PvP match begins (after prep phase ends)."
english["Options.ReadyCheckOnly"] = "Show only on ready check"
english["Options.ReadyCheckOnly.Desc"] = "Only show this category's buffs for 15 seconds after a ready check starts"
english["Options.Visibility"] = "Visibility"
english["Options.PerCategoryCustomization"] = "Per-Category Customization"

-- ============================================================================
-- OPTIONS: HEALTHSTONE
-- ============================================================================
english["Options.Healthstone"] = "Healthstone"
english["Options.Healthstone.ReadyCheckOnly"] = "Ready check only"
english["Options.Healthstone.ReadyCheckWarlock"] = "Ready check + warlock always"
english["Options.Healthstone.AlwaysShow"] = "Always show"
english["Options.Healthstone.Visibility"] = "Healthstone visibility"
english["Options.Healthstone.Visibility.Desc"] =
    "Controls when the healthstone reminder appears.\n\n|cffffcc00Ready check only:|r Only during ready checks (15s window).\n|cffffcc00Ready check + warlock always:|r Warlocks always see it; others only on ready check.\n|cffffcc00Always show:|r Visible whenever you're in matching content."
english["Options.Healthstone.WarlockAlwaysDesc"] = "Warlocks always see the reminder; other classes only on ready check"
english["Options.Healthstone.ReadyCheckDesc"] = "Show for 15 seconds after a ready check starts"
english["Options.Healthstone.AlwaysDesc"] = "Show whenever the content type matches"

-- ============================================================================
-- OPTIONS: FREE CONSUMABLES
-- ============================================================================
english["Options.FreeConsumables"] = "Free Consumables"
english["Options.FreeConsumables.Note"] = "(healthstones, permanent augment runes)"
english["Options.FreeConsumables.Override"] = "Override content filters"
english["Options.FreeConsumables.Override.Desc"] =
    "When checked, free consumables use their own content type visibility settings below.\n\nWhen unchecked, they follow the same content filters as other consumables."

-- ============================================================================
-- OPTIONS: ICONS
-- ============================================================================
english["Options.Icons"] = "Icons"
english["Options.ShowText"] = "Show text on icons"
english["Options.ShowText.Desc"] = "Display count or missing text overlays on buff icons for this category"
english["Options.ShowMissingCountOnly"] = "Show missing count only"
english["Options.ShowMissingCountOnly.Desc"] =
    'Show only the number of missing buffs (e.g., "1") instead of the full count (e.g., "19/20")'
english["Options.ShowBuffReminderText"] = 'Show "BUFF!" reminder text'
english["Options.BuffTextOffsetX"] = '"BUFF!" X'
english["Options.BuffTextOffsetY"] = '"BUFF!" Y'
english["Options.Size"] = "Size"

-- ============================================================================
-- OPTIONS: CLICK TO CAST
-- ============================================================================
english["Options.ClickToCast"] = "Click to cast"
english["Options.ClickToCast.DescFull"] =
    "Make buff icons clickable to cast the corresponding spell (out of combat only). Only works for spells your character can cast."
english["Options.HoverHighlight"] = "Hover highlight"
english["Options.HoverHighlight.Desc"] = "Show a subtle highlight when hovering over clickable buff icons."

-- ============================================================================
-- OPTIONS: PET
-- ============================================================================
english["Options.PetSpecIcon"] = "Show hunter pet spec icon on hover"
english["Options.PetSpecIcon.Title"] = "Pet spec icon on hover"
english["Options.PetSpecIcon.Desc"] =
    "Swap the pet icon to its specialization ability (Cunning, Ferocity, Tenacity) when hovering."
english["Options.ShowItemTooltips"] = "Show item tooltips"
english["Options.ShowItemTooltips.Desc"] = "When hovering over a consumable icon, show its item tooltip."
english["Options.Behavior"] = "Behavior"
english["Options.PetPassiveCombat"] = "Pet passive only in combat"
english["Options.PetPassiveCombat.Desc"] =
    "Only show the passive pet reminder while in combat. When disabled, the reminder is always shown."
english["Options.FelDomination"] = "Use Fel Domination before summoning"
english["Options.FelDomination.Title"] = "Fel Domination"
english["Options.FelDomination.Desc"] =
    "Automatically cast Fel Domination before summoning a demon via click-to-cast. If Fel Domination is on cooldown, the summon proceeds normally. Requires the Fel Domination talent."

-- ============================================================================
-- OPTIONS: PET DISPLAY
-- ============================================================================
english["Options.PetDisplay"] = "Pet display"
english["Options.PetDisplay.Generic"] = "Generic icon"
english["Options.PetDisplay.GenericDesc"] = "A single generic 'NO PET' icon"
english["Options.PetDisplay.Summon"] = "Summon spells"
english["Options.PetDisplay.SummonDesc"] = "Each pet summon spell as its own icon"
english["Options.PetDisplay.Mode"] = "Pet display mode"
english["Options.PetDisplay.Mode.Desc"] = "How missing pet reminders are displayed."
english["Options.PetLabels"] = "Pet labels"
english["Options.PetLabels.Desc"] = "Show pet name and specialization below each icon."
english["Options.PetLabels.SizePct"] = "Size %"

-- ============================================================================
-- OPTIONS: CONSUMABLE DISPLAY
-- ============================================================================
english["Options.ConsumableTextScale"] = "Text scale"
english["Options.ConsumableTextScale.Title"] = "Consumable text scale"
english["Options.ConsumableTextScale.Desc"] =
    "Font size for item counts and quality (R1/R2/R3) labels as a percentage of icon size."
english["Options.ItemDisplay"] = "Item display"
english["Options.ItemDisplay.IconOnly"] = "Icon only"
english["Options.ItemDisplay.IconOnlyDesc"] = "Shows the item with the highest count"
english["Options.ItemDisplay.SubIcons"] = "Sub-icons"
english["Options.ItemDisplay.SubIconsDesc"] = "Small clickable item variants below each icon"
english["Options.ItemDisplay.Expanded"] = "Expanded"
english["Options.ItemDisplay.ExpandedDesc"] = "Each item variant as a full-sized icon"
english["Options.ItemDisplay.Mode"] = "Consumable item display"
english["Options.ItemDisplay.Mode.Desc"] =
    "How consumable items with multiple variants (e.g. different flask types) are displayed."
english["Options.SubIconSide"] = "Side"
english["Options.SubIconSide.Bottom"] = "Bottom"
english["Options.SubIconSide.Top"] = "Top"
english["Options.SubIconSide.Left"] = "Left"
english["Options.SubIconSide.Right"] = "Right"
english["Options.ShowWithoutItems"] = "Show when not in bags"
english["Options.ShowWithoutItems.Title"] = "Show consumables without items"
english["Options.ShowWithoutItems.Desc"] =
    "When enabled, consumable reminders are shown even if you don't have the item in your bags. When disabled, only consumables you actually carry are shown."
english["Options.DelveFoodOnly"] = "Only delve food in delves"
english["Options.DelveFoodOnly.Desc"] = "When inside a delve, hide all consumable reminders except delve food."

-- ============================================================================
-- OPTIONS: LAYOUT
-- ============================================================================
english["Options.Layout"] = "Layout"
english["Options.Priority"] = "Priority"
english["Options.Priority.Desc"] =
    "Controls the order of this category in the combined frame. Lower values are displayed first."
english["Options.SplitFrame"] = "Split into separate frame"
english["Options.SplitFrame.Desc"] = "Display this category's buffs in a separate, independently movable frame"
english["Options.DisplayPriority"] = "Display Priority"

-- ============================================================================
-- OPTIONS: APPEARANCE
-- ============================================================================
english["Options.CustomAppearance"] = "Use custom appearance"
english["Options.CustomAppearance.Desc"] =
    "When disabled, this category inherits appearance settings from Global Defaults. Grow direction requires splitting into a separate frame."
english["Options.Customize"] = "Customize"
english["Options.ResetPosition"] = "Reset Position"
english["Options.MasqueNote"] = "Zoom and Border settings are managed by Masque"

-- ============================================================================
-- OPTIONS: SETTINGS TAB
-- ============================================================================
english["Options.ShowLoginMessages"] = "Show login messages"
english["Options.ShowMinimapButton"] = "Show minimap button"
english["Options.ShowOnlyInGroup"] = "Show only in group/raid"

-- Hide when section
english["Options.HideWhen"] = "Hide when:"
english["Options.HideWhen.Resting"] = "Resting"
english["Options.HideWhen.Resting.Title"] = "Hide while resting"
english["Options.HideWhen.Resting.Desc"] = "Hide buff reminders while in inns or capital cities"
english["Options.HideWhen.Combat"] = "In combat"
english["Options.HideWhen.Expiring"] = "Expiring in combat"
english["Options.HideWhen.Expiring.Title"] = "Hide expiring buffs in combat"
english["Options.HideWhen.Expiring.Desc"] =
    "During combat, hide buffs that are expiring soon and only show completely missing ones"
english["Options.HideWhen.Vehicle"] = "In vehicle"
english["Options.HideWhen.Vehicle.Title"] = "Hide in vehicle"
english["Options.HideWhen.Vehicle.Desc"] =
    "Hide all buff reminders while in a quest vehicle. When disabled, raid and presence buffs still show"
english["Options.HideWhen.Mounted"] = "While mounted"
english["Options.HideWhen.Mounted.Title"] = "Hide while mounted"
english["Options.HideWhen.Mounted.Desc"] =
    "Hide all buff reminders while mounted. Overrides the per-category pet mount hiding setting"
english["Options.HideWhen.Legacy"] = "In legacy instances"
english["Options.HideWhen.Legacy.Title"] = "Hide in legacy instances"
english["Options.HideWhen.Legacy.Desc"] =
    "Hide all buff reminders in trivially old instances (where legacy loot is enabled)"

-- ============================================================================
-- OPTIONS: BUFF TRACKING MODE
-- ============================================================================
english["Options.BuffTracking"] = "Buff tracking"
english["Options.BuffTracking.All"] = "All buffs, all players"
english["Options.BuffTracking.All.Desc"] =
    "Show all raid and presence buffs for every class, tracking full group coverage."
english["Options.BuffTracking.MyBuffs"] = "Only my buffs, all players"
english["Options.BuffTracking.MyBuffs.Desc"] =
    "Only show buffs your class can provide. Still tracks full group coverage."
english["Options.BuffTracking.OnlyMine"] = "Only buffs I need"
english["Options.BuffTracking.OnlyMine.Desc"] =
    "Show all buff types, but only check whether you personally have them. No group counts."
english["Options.BuffTracking.Smart"] = "Smart"
english["Options.BuffTracking.Smart.Desc"] =
    "Buffs your class provides track full group coverage. Other class buffs only check you personally."
english["Options.BuffTracking.Mode"] = "Buff tracking mode"
english["Options.BuffTracking.Mode.Desc"] =
    "Controls which raid and presence buffs are shown, and whether they track the full group or only you."

-- ============================================================================
-- OPTIONS: PROFILES TAB
-- ============================================================================
english["Options.ActiveProfile"] = "Active Profile"
english["Options.ActiveProfile.Desc"] =
    "Switch between saved configurations. Each character can use a different profile."
english["Options.SelectProfile"] = "Select a profile"
english["Options.Profile"] = "Profile"
english["Options.CopyFrom"] = "Copy From"
english["Options.Delete"] = "Delete"
english["Options.PerSpecProfiles"] = "Per-Specialization Profiles"
english["Options.PerSpecProfiles.Desc"] = "Automatically switch profiles when you change specialization."
english["Options.PerSpecProfiles.Enable"] = "Enable per-specialization profiles"

-- ============================================================================
-- OPTIONS: IMPORT/EXPORT
-- ============================================================================
english["Options.ExportSettings"] = "Export Settings"
english["Options.ExportSettings.Desc"] = "Copy the string below to share your settings with others."
english["Options.ImportSettings"] = "Import Settings"
english["Options.ImportSettings.DescPlain"] = "Paste a settings string below."
english["Options.ImportSettings.Overwrite"] = "This will overwrite the active profile."
english["Options.Export"] = "Export"
english["Options.Import"] = "Import"
english["Options.ImportSuccess"] = "Settings imported successfully!"
english["Options.FailedExport"] = "Failed to export"
english["Options.UnknownError"] = "Unknown error"

-- ============================================================================
-- OPTIONS: DIALOGS
-- ============================================================================
english["Dialog.Cancel"] = "Cancel"
english["Dialog.DeleteCustomBuff"] = 'Delete custom buff "%s"?'
english["Dialog.ResetProfile"] =
    "Reset the active profile to defaults?\n\nThis will erase all customizations\nin the current profile and reload the UI."
english["Dialog.Reset"] = "Reset"
english["Dialog.ReloadPrompt"] = "Settings imported successfully!\nReload UI to apply changes?"
english["Dialog.Reload"] = "Reload"
english["Dialog.NewProfilePrompt"] = "Enter a name for the new profile:"
english["Dialog.Create"] = "Create"
english["Dialog.DiscordPrompt"] = "Join the BuffReminders Discord!\nCopy the URL below (Ctrl+C):"
english["Dialog.Close"] = "Close"

-- ============================================================================
-- OPTIONS: TEST / LOCK
-- ============================================================================
english["Options.LockUnlock"] = "Lock / Unlock"
english["Options.LockUnlock.Desc"] = "Unlock to show anchor handles for repositioning buff frames."
english["Options.TestAppearance"] = "Test icon's appearance"
english["Options.TestAppearance.Desc"] =
    "Shows your selected buffs with fake values so you can preview their appearance."
english["Options.Test"] = "Test"
english["Options.StopTest"] = "Stop Test"
english["Options.AnchorHint"] = "Click an anchor to update its anchor point or coordinates"
english["Options.Lock"] = "Lock"
english["Options.Unlock"] = "Unlock"

-- ============================================================================
-- OPTIONS: CUSTOM BUFF MODAL
-- ============================================================================
english["CustomBuff.Edit"] = "Edit Custom Buff"
english["CustomBuff.Add"] = "Add Custom Buff"
english["CustomBuff.AddButton"] = "+ Add Custom Buff"
english["CustomBuff.SpellIDs"] = "Spell IDs:"
english["CustomBuff.Lookup"] = "Lookup"
english["CustomBuff.AddSpellID"] = "+ Add Spell ID"
english["CustomBuff.Name"] = "Name:"
english["CustomBuff.Text"] = "Text:"
english["CustomBuff.LineBreakHint"] = "(use \\n for line break)"
english["CustomBuff.Appearance"] = "APPEARANCE"
english["CustomBuff.Conditions"] = "CONDITIONS"
english["CustomBuff.ShowIn"] = "SHOW IN"
english["CustomBuff.ClickAction"] = "CLICK ACTION"
english["CustomBuff.SettingsMovedNote"] = "Visibility and ready check settings moved to each buff's edit menu."

-- Custom buff mode toggles
english["CustomBuff.WhenActive"] = "When active"
english["CustomBuff.WhenMissing"] = "When missing"
english["CustomBuff.OnlyIfSpellKnown"] = "Only if spell known"

-- Custom buff class dropdown
english["Class.Any"] = "Any"
english["Class.DeathKnight"] = "Death Knight"
english["Class.DemonHunter"] = "Demon Hunter"
english["Class.Druid"] = "Druid"
english["Class.Evoker"] = "Evoker"
english["Class.Hunter"] = "Hunter"
english["Class.Mage"] = "Mage"
english["Class.Monk"] = "Monk"
english["Class.Paladin"] = "Paladin"
english["Class.Priest"] = "Priest"
english["Class.Rogue"] = "Rogue"
english["Class.Shaman"] = "Shaman"
english["Class.Warlock"] = "Warlock"
english["Class.Warrior"] = "Warrior"

-- Custom buff fields
english["CustomBuff.Spec"] = "Spec:"
english["CustomBuff.Class"] = "Class:"
english["CustomBuff.RequireItem"] = "Require item:"
english["CustomBuff.RequireItem.EquippedBags"] = "Equipped/Bags"
english["CustomBuff.RequireItem.Equipped"] = "Equipped"
english["CustomBuff.RequireItem.InBags"] = "In bags"
english["CustomBuff.RequireItem.Hint"] = "item ID — hide if not found"

-- Bar glow options
english["CustomBuff.BarGlow.WhenGlowing"] = "Detect when glowing"
english["CustomBuff.BarGlow.WhenNotGlowing"] = "Detect when not glowing"
english["CustomBuff.BarGlow.Disabled"] = "Disabled"
english["CustomBuff.BarGlow"] = "Bar glow:"
english["CustomBuff.BarGlow.Title"] = "Action bar glow fallback"
english["CustomBuff.BarGlow.Desc"] =
    "Fallback detection using action bar spell glows during M+/PvP/combat when buff API is restricted. Disable if you only want buff presence tracking."

-- Ready check / level
english["CustomBuff.ReadyCheckOnly"] = "Only on ready check"
english["CustomBuff.Level"] = "Level:"
english["CustomBuff.Level.Any"] = "Any level"
english["CustomBuff.Level.Max"] = "Max level only"
english["CustomBuff.Level.BelowMax"] = "Below max level"

-- Click action
english["CustomBuff.Action.None"] = "None"
english["CustomBuff.Action.Spell"] = "Spell"
english["CustomBuff.Action.Item"] = "Item"
english["CustomBuff.Action.Macro"] = "Macro"
english["CustomBuff.Action.OnClick"] = "On click:"
english["CustomBuff.Action.Title"] = "Click action"
english["CustomBuff.Action.Desc"] =
    "What happens when you click this buff icon. Spell casts a spell, Item uses an item, Macro runs a macro command."
english["CustomBuff.Action.MacroHint"] = "e.g. /use item:12345\\n/use 13"

-- Save/Cancel/Delete
english["CustomBuff.Save"] = "Save"
english["CustomBuff.ValidateError"] = "Please validate at least one spell ID"

-- Custom buff tooltip
english["CustomBuff.Tooltip.Title"] = "Custom Buff"
english["CustomBuff.Tooltip.Desc"] = "Right-click to edit or delete"

-- Custom buff status
english["CustomBuff.InvalidID"] = "Invalid ID"
english["CustomBuff.NotFound"] = "Not found"
english["CustomBuff.NotFoundRetry"] = "Not found (try again)"
english["CustomBuff.Error"] = "Error:"

-- ============================================================================
-- OPTIONS: DISCORD
-- ============================================================================
english["Options.JoinDiscord"] = "Join Discord"
english["Options.JoinDiscord.Title"] = "Click for invite link"
english["Options.JoinDiscord.Desc"] = "Got feedback, feature requests, or bug reports?\nJoin the Discord!"

-- ============================================================================
-- OPTIONS: CUSTOM ANCHOR FRAMES
-- ============================================================================
english["Options.CustomAnchorFrames"] = "Custom Anchor Frames"
english["Options.CustomAnchorFrames.Desc"] =
    "Add global frame names to the anchor dropdown (e.g. MyAddon_PlayerFrame). \nFrames that don't exist in-game are silently skipped."
english["Options.Add"] = "Add"
english["Options.New"] = "New"
english["Options.ResetToDefaults"] = "Reset to Defaults"

-- ============================================================================
-- OPTIONS: MISC
-- ============================================================================
english["Options.Off"] = "Off"
english["Options.Always"] = "Always"
english["Options.ReadyCheck"] = "Ready check"
english["Options.Min"] = "min"

-- ============================================================================
-- COMPONENTS (UI/Components.lua)
-- ============================================================================
-- Slider tooltip
english["Component.AdjustValue"] = "Adjust value"
english["Component.AdjustValue.Desc"] = "Click to type or use mouse wheel"

-- Direction labels
english["Direction.Left"] = "Left"
english["Direction.Center"] = "Center"
english["Direction.Right"] = "Right"
english["Direction.Up"] = "Up"
english["Direction.Down"] = "Down"
english["Direction.Label"] = "Direction"

-- Content visibility
english["Content.ShowIn"] = "Show in:"

-- Content toggle definitions
english["Content.OpenWorld"] = "Open World"
english["Content.Housing"] = "Housing"
english["Content.Scenarios"] = "Scenarios (Delves, Torghast, etc.)"
english["Content.Dungeons"] = "Dungeons (including M+)"
english["Content.Raids"] = "Raids"
english["Content.PvP"] = "PvP (Arena & Battlegrounds)"

-- Scenario difficulty
english["Content.Delves"] = "Delves"
english["Content.OtherScenarios"] = "Other Scenarios (Torghast, etc.)"

-- Dungeon difficulty
english["Content.NormalDungeons"] = "Normal Dungeons"
english["Content.HeroicDungeons"] = "Heroic Dungeons"
english["Content.MythicDungeons"] = "Mythic Dungeons"
english["Content.MythicPlus"] = "Mythic+ Keystones"
english["Content.TimewalkingDungeons"] = "Timewalking Dungeons"
english["Content.FollowerDungeons"] = "Follower Dungeons"

-- Raid difficulty
english["Content.LFR"] = "Looking for Raid"
english["Content.NormalRaids"] = "Normal Raids"
english["Content.HeroicRaids"] = "Heroic Raids"
english["Content.MythicRaids"] = "Mythic Raids"

-- PvP types
english["Content.Arena"] = "Arena"
english["Content.Battlegrounds"] = "Battlegrounds"
