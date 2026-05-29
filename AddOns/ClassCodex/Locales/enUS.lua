local _, ns = ...
local L = ns.L

-------------------------------------------------------------------------------
-- English (enUS) source of truth
--
-- Always loaded; populates every key with its English value. Per-locale files
-- load after this and overwrite where translated. Untranslated keys fall
-- through to the English values defined here.
-------------------------------------------------------------------------------


-- Tab labels
L["tab.guide"] = "Guide"
L["tab.enchants_gems"] = "Enchants & Gems"
L["tab.enchants"] = "Enchants"
L["tab.gems"] = "Gems"
L["tab.consumables"] = "Consumables"
L["tab.trinkets"] = "Trinkets"
L["tab.crafts"] = "Crafts"
L["tab.bis_gear"] = "BiS Gear"
L["tab.best_in_slot"] = "Best in Slot"
L["tab.about"] = "About"
L["tab.enhancements"] = "Enhancements"
L["talent_pane.view_talents"] = "View Talents"

-- Section headers
L["section.stat_priority"] = "Stat Priority"
L["section.talents"] = "Talents"
L["section.rotation"] = "Rotation"

-- Context labels
L["context.raid"] = "Raid"
L["context.dungeon"] = "Dungeon"
L["context.delves"] = "Delves"
L["context.crafting"] = "Crafting"

-- Rotation / stat contexts (Wowhead headings)
L["rotation.single_target"] = "Single Target"
L["rotation.multitarget"] = "Multitarget"
L["rotation.opener"] = "Opener"
L["rotation.aoe_opener"] = "AoE Opener"
L["rotation.single_target_opener"] = "Single Target Opener"
L["rotation.easy_mode"] = "Easy Mode"
L["rotation.opener_cooldowns"] = "Opener / Cooldowns"
L["context.mythic_plus"] = "Mythic+"
L["rotation.dps_priority"] = "DPS Priority"
L["rotation.healing_priority"] = "Healing Priority"
-- L["settings.header.general"] handled by the Settings section below ("Geral").

-- Consumable labels
L["consumable.flask"] = "Flask"
L["consumable.combat_potion"] = "Combat Potion"
L["consumable.food"] = "Food"
L["consumable.weapon_buff"] = "Weapon Buff"
L["consumable.augment_rune"] = "Augment Rune"

-- Gem labels
L["gem.primary"] = "Primary"
L["gem.secondary"] = "Secondary"

-- Craft section headers
L["craft.early"] = "Early Crafts"
L["craft.bis"] = "BiS Crafts"

-- Talent build fallback
L["talent.build"] = "Build"

-- Empty / fallback states
L["empty.select_class_spec"] = "Select a class and specialization above."
L["empty.no_data"] = "No data available for this spec."
L["empty.no_builds_details"] = "No builds available — check Wowhead for details."
L["empty.no_builds_for"] = "No builds for %s — check Wowhead."
L["empty.no_rotation_for_details"] = "No rotation for %s — check Wowhead for details."
L["empty.no_rotation_for"] = "No rotation for %s — check Wowhead."

-- About panel
L["about.title"] = "About Class Codex v%s"
L["about.description"] = "Stat priorities, talent builds, rotation guides, and gearing recommendations for your current spec.\\n\\nRecommendations are general guidelines. For precise results, sim your character with Raidbots."
L["about.links"] = "Links:"
L["about.help_hint"] = "Type /cc help for a list of commands."
L["about.supporters"] = "Supporters"
L["about.support_patreon"] = "Support on Patreon"
L["about.free_message"] = "Class Codex is free and open to everyone. Supporters on Patreon help keep the data fresh and the project moving forward."
L["about.be_first_supporter"] = "Be the first to support Class Codex!"
L["compendium.open_settings"] = "Open Settings"
L["compendium.open_compendium"] = "Open Compendium"

-- Tooltip
L["settings.label.stat_priority_on_tooltips"] = "Stat Priority on Tooltips"

-- Settings headers
L["settings.header.tooltips"] = "Tooltips"
L["settings.header.general"] = "General"
L["settings.header.floating_panel"] = "Floating Panel"
L["settings.header.docked_panel"] = "Docked Panel"
L["settings.header.panel"] = "Panel"

-- Settings: checkbox labels
L["settings.label.stat_priority_ranks"] = "Stat Priority Ranks"
L["settings.label.wowhead_bis"] = "Wowhead BiS on Tooltips"
L["settings.label.icy_veins_bis"] = "Icy Veins BiS on Tooltips"
L["settings.label.bis_source"] = "BiS Source"
L["settings.label.trinket_tier"] = "Trinket Tier on Tooltips"
L["settings.label.current_class_only"] = "Current Class Only"
L["settings.label.highlight_owned"] = "Highlight Owned Gear"
L["settings.label.minimap_button"] = "Minimap Button"
L["settings.label.login_message"] = "Login Message"
L["settings.label.show_stat_priority"] = "Show Stat Priority"
L["settings.label.show_talents"] = "Show Talents"
L["settings.label.show_rotation"] = "Show Rotation"
L["settings.label.show_enchants"] = "Show Enchants"
L["settings.label.show_gems"] = "Show Gems"
L["settings.label.show_consumables"] = "Show Consumables"
L["settings.label.show_trinkets"] = "Show Trinkets"
L["settings.label.show_crafts"] = "Show Crafts"
L["settings.label.show_bis_gear"] = "Show BiS Gear"

-- Settings: tooltip descriptions
L["settings.tooltip.stat_priority_ranks"] = "Show stat priority rank (#1, #2, #3) next to stat names on item tooltips."
L["settings.tooltip.wowhead_bis"] = "Show which specs an item is Best in Slot for (Wowhead) on item tooltips."
L["settings.tooltip.icy_veins_bis"] = "Show which specs an item is Best in Slot for (Icy Veins) on item tooltips."
L["settings.tooltip.trinket_tier"] = "Show trinket tier rankings and the tier badge on item tooltips."
L["settings.tooltip.current_class_only"] = "Only show BiS and trinket tier info for your current class on tooltips."
L["settings.tooltip.highlight_owned"] = "Tint BiS and Trinket rows with a subtle green background when you already own the item (bags, bank, reagent bank, warbank, or equipped). Applies to both the docked and floating panels."
L["settings.tooltip.minimap_button"] = "Show a minimap button for quick access. Left-click opens the Compendium, right-click opens Settings."
L["settings.tooltip.login_message"] = "Print the 'Class Codex loaded — type /cc to open' message to chat when you log in or reload."
L["settings.tooltip.float_show_stat_priority"] = "Show the Stat Priority section when the panel is floating."
L["settings.tooltip.float_show_talents"] = "Show the Talents section when the panel is floating."
L["settings.tooltip.float_show_rotation"] = "Show the Rotation section when the panel is floating."
L["settings.tooltip.float_show_enchants"] = "Show the Enchants section when the panel is floating."
L["settings.tooltip.float_show_gems"] = "Show the Gems section when the panel is floating."
L["settings.tooltip.float_show_consumables"] = "Show the Consumables section when the panel is floating."
L["settings.tooltip.float_show_trinkets"] = "Show the Trinkets section when the panel is floating."
L["settings.tooltip.float_show_crafts"] = "Show the Crafts section when the panel is floating."
L["settings.tooltip.float_show_bis_gear"] = "Show the BiS Gear section when the panel is floating."
L["settings.tooltip.dock_show_stat_priority"] = "Show the Stat Priority section when the panel is docked."
L["settings.tooltip.dock_show_talents"] = "Show the Talents section when the panel is docked."
L["settings.tooltip.dock_show_rotation"] = "Show the Rotation section when the panel is docked."
L["settings.tooltip.dock_show_enchants"] = "Show the Enchants section when the panel is docked."
L["settings.tooltip.dock_show_gems"] = "Show the Gems section when the panel is docked."
L["settings.tooltip.dock_show_consumables"] = "Show the Consumables section when the panel is docked."
L["settings.tooltip.dock_show_trinkets"] = "Show the Trinkets section when the panel is docked."
L["settings.tooltip.dock_show_crafts"] = "Show the Crafts section when the panel is docked."
L["settings.tooltip.dock_show_bis_gear"] = "Show the BiS Gear section when the panel is docked."

-- Chat messages
L["chat.loaded"] = "loaded — type |cff00ccff/cc|r to open"
L["chat.switched_to"] = "Switched to %s (detected)"
L["chat.mode_docked"] = "Docked"
L["chat.mode_floating"] = "Floating"
L["chat.mode_reset"] = "Reset"
L["chat.compendium_not_available"] = "Compendium not available."
L["chat.minimap_shown"] = "Minimap button shown"
L["chat.minimap_hidden"] = "Minimap button hidden"
L["chat.minimap_not_available"] = "Minimap button not available"
L["chat.unknown_command"] = "Unknown command. Type /cc help"
L["chat.settings_registration_failed"] = "Settings registration failed: %s"
L["chat.compendium_data_not_loaded"] = "Compendium data not loaded."

-- Settings: character pane button
L["settings.header.character_pane_button"] = "Character Pane Button"
L["settings.label.lock_button_position"] = "Lock Button Position"
L["settings.tooltip.lock_button_position"] = "Prevent the gear button from being moved by Shift-drag on the character pane."
L["settings.label.horizontal_offset"] = "Horizontal Offset"
L["settings.label.vertical_offset"] = "Vertical Offset"
L["settings.tooltip.horizontal_offset"] = "Horizontal offset (pixels) from the character pane top-right corner."
L["settings.tooltip.vertical_offset"] = "Vertical offset (pixels) from the character pane top-right corner."
L["settings.label.reset_position"] = "Reset Position"
L["settings.tooltip.reset_position"] = "Restore the gear button to its default position."
L["character_pane.click_to_toggle"] = "Click to toggle panel"
L["character_pane.shift_drag_hint"] = "Shift-drag to move - Shift+Right-click to reset"
L["character_pane.position_locked"] = "Position locked - unlock in Settings"

-- PvP
L["pvp.label"] = "PvP"
L["pvp.arena"] = "Arena"
L["pvp.battleground"] = "Battleground"
L["pvp.honor_talents"] = "Honor Talents"
L["pvp.honor_talents_apply"] = "Honor talents apply in War Mode or PvP instances."
L["pvp.no_builds"] = "No PvP builds available."
L["pvp.no_gear_data"] = "No PvP gear data for this spec yet."
L["pvp.no_enchants"] = "No PvP enchants for this spec yet."
L["pvp.no_enchant_gem_data"] = "No PvP enchant/gem data for this spec yet."
L["pvp.no_stat_priority"] = "No PvP stat priority for this spec yet."
L["pvp.no_stat_targets"] = "No PvP stat targets for this spec yet."

-- Stat Targets / DR (character pane tooltip extras)
L["section.stat_targets"] = "Stat Targets"
L["settings.label.show_stat_targets"] = "Show Stat Targets"
L["settings.label.stat_priority_source_line"] = "Stat Priority Source Line"
L["tooltip.stat_priority_footer"] = "Stat priority"
L["settings.tooltip.dock_show_stat_targets"] = "Show the Stat Targets section (live bars vs Archon empirical targets) on the Stats tab when the panel is docked."
L["settings.tooltip.float_show_stat_targets"] = "Show the Stat Targets section (live bars vs Archon empirical targets) on the Stats tab when the panel is floating."
L["stat_targets.combat_warning"] = "Stat targets can't be computed in combat — values update after combat ends."
L["loadout.alt"] = "alt"
L["loadout.alt_n"] = "alt %d"

-- Tooltip / data source labels
L["settings.label.source_display"] = "Source Display"
L["settings.tooltip.source_display"] = "How to display data sources (Wowhead, Icy Veins) on item tooltips."
L["settings.tooltip.bis_source"] = "When to show a footer line on item tooltips noting which hero / context the displayed ranks come from. 'Only when different' surfaces the line only when the resolved hero diverges from the one you're currently playing — useful as a quiet reminder that a pin or panel selection has drifted from in-game state."
L["settings.value.always"] = "Always"
L["settings.value.off"] = "Off"
L["settings.value.only_when_different"] = "Only when different"
L["settings.value.both"] = "Both"
L["settings.value.icons"] = "Icons"
L["settings.value.labels"] = "Labels"
L["settings.value.wowhead"] = "Wowhead"
L["settings.value.archon"] = "Archon"

-- Encounter context labels
L["context.mplus_dungeons"] = "M+ Dungeons"
L["context.raid_heroic"] = "Raid Bosses (Heroic)"
L["context.raid_mythic"] = "Raid Bosses (Mythic)"

-- Loadout Dock
L["settings.header.loadout_dock"] = "Loadout Dock"
L["settings.label.show_loadout_dock"] = "Show Loadout Dock"
L["settings.tooltip.show_loadout_dock"] = "Floating widget that shows the active talent loadout name. Click to switch to any saved Blizzard loadout or Class Codex recommendation."
L["loadout_dock.click_to_switch"] = "Click to switch loadouts."
L["loadout_dock.right_click_options"] = "Right-click for options."
L["loadout_dock.cannot_switch_combat"] = "Cannot switch loadouts in combat."
L["loadout_dock.no_loadouts"] = "No loadouts available"
L["loadout_dock.no_talent_builds"] = "No talent builds available."
L["loadout_dock.no_archon_builds"] = "No Archon builds available."
L["loadout_dock.pick_a_build"] = "Pick a build"
L["loadout_dock.custom_build"] = "Custom build"
L["loadout_dock.saved_loadouts"] = "Saved Loadouts"
L["settings.label.dock_show_saved"] = "Show Saved Loadouts in menu"
L["settings.label.dock_show_wowhead"] = "Show Wowhead recommendations in menu"
L["settings.label.dock_show_archon"] = "Show Archon recommendations in menu"
L["settings.tooltip.dock_show_saved"] = "Include your Blizzard saved talent loadouts in the dock's click menu."
L["settings.tooltip.dock_show_wowhead"] = "Include the Wowhead-sourced recommended builds in the dock's click menu."
L["settings.tooltip.dock_show_archon"] = "Include the Archon per-encounter recommended builds in the dock's click menu."
L["settings.label.dock_show_spec_icon"] = "Show spec icon"
L["settings.tooltip.dock_show_spec_icon"] = "Show your active specialization's icon next to the loadout name."
L["settings.label.dock_show_hero_icon"] = "Show hero talent icon"
L["settings.tooltip.dock_show_hero_icon"] = "Show your active hero talent's icon next to the loadout name."
L["settings.label.dock_show_border"] = "Show border"
L["settings.tooltip.dock_show_border"] = "Draw a thin border around the loadout dock. Off for a borderless minimal look."
L["settings.label.dock_opacity"] = "Background opacity"
L["settings.tooltip.dock_opacity"] = "Translucency of the loadout dock's background plate. 0 = invisible, 100 = solid."
L["settings.label.dock_width"] = "Width"
L["settings.tooltip.dock_width"] = "Width of the loadout dock in pixels. Ignored when Auto-fit width is on."
L["settings.label.dock_auto_width"] = "Auto-fit width"
L["settings.tooltip.dock_auto_width"] = "Resize the dock automatically to fit the active loadout name. Overrides the Width slider when enabled."
L["settings.label.dock_scale"] = "Scale"
L["settings.tooltip.dock_scale"] = "Scale of the loadout dock. Grows the font, icons, and height proportionally."
L["settings.label.dock_alignment"] = "Content alignment"
L["settings.tooltip.dock_alignment"] = "Where the dock's icons + label sit when the dock is wider than the content."
L["settings.value.center"] = "Center"
L["settings.value.left"] = "Left"
L["settings.value.right"] = "Right"
L["settings.label.dock_hide_in_combat"] = "Hide in combat"
L["settings.tooltip.dock_hide_in_combat"] = "Hide the loadout dock entirely during combat. Talent swaps fail in combat anyway, so this just removes the visual noise."
L["settings.label.dock_lock_position"] = "Lock dock position"
L["settings.tooltip.dock_lock_position"] = "Prevent the loadout dock from being dragged. Toggle off to reposition, then re-enable to keep it from moving accidentally."
L["loadout_dock.lock_position"] = "Lock position"
L["loadout_dock.unlock_position"] = "Unlock position"

-- Talent Pane integration
L["settings.header.talent_pane"] = "Talent Pane"
L["settings.label.talent_pane_show"] = "Show Class Codex on talent frame"
L["settings.tooltip.talent_pane_show"] = "Show the Class Codex build picker on the Blizzard talent frame. Disable to hide it entirely."
L["settings.header.unit_menus"] = "Unit Menus"
L["settings.label.unit_menu_enabled"] = "Add View Talents to right-click unit menus"
L["settings.tooltip.unit_menu_enabled"] = "Adds 'View Talents' to the right-click menu on raid, party, and unit frames. Disable if you see 'AddOn tried to call protected function' errors after right-clicking — this is a known Blizzard bug."
L["chat.blizzard_bug_notice"] = "|cff66ccff[Class Codex]|r The '%s' error you just saw is a known Blizzard bug, not a Class Codex bug. Disable 'Add View Talents to right-click unit menus' in Class Codex settings to stop it."

-- Footer
L["footer.today"] = "Today"
L["footer.yesterday"] = "Yesterday"
L["footer.days_ago"] = "%d days ago"
L["footer.last_refreshed"] = "Last refreshed: %s"
L["footer.data_refresh_hint"] = "Data refreshes daily. Update Class Codex to get the latest."
