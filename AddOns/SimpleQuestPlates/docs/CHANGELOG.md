# Changelog

## v1.8.4
- Tab reorganization: Font settings moved into General tab (right column); Colors and Task Icons tabs dissolved; Kill, Loot, Percent each get their own tab with all relevant controls (visibility, color, tint, size, offsets).
- Add "Show Percent Icon" toggle to Percent tab, parity with Kill and Loot.
- Fix: percentIconSize slider now actually controls the font size of the "%" (and "75%") text — was hardcoded to fontSize+4.
- Fix: preview animation (Animate Main Icon) no longer blocked by IsShown guard — tickers now fire unconditionally and are cleaned up by OnHide; OnShow restarts the animation when the panel becomes visible.
- Update defaults to tuned in-game values: offsetX=12, offsetY=3, scale=1.1, no outline, killIconOffsetX=2, killIconOffsetY=15, lootIconOffsetX=-38, lootIconOffsetY=16, percentIconOffsetX=-17, killIconSize/lootIconSize=14, percentIconSize=8, animateQuestIcons=true.
- Restore About tab content: description box, key features list, slash commands reference, RGX community link.
- Main Icon tab now includes tinting controls in the right column.

## v1.8.3
- Shrink options panel header (60px, smaller logo/title) and preview container (148px) to free ~90px of body space, preventing tab content from overflowing the bottom of the panel.
- Reduce tab bar height and inter-section gaps to further maximise body content area.
- Fix default percent icon offset to X=8, Y=3 (was X=10, Y=0).

## v1.8.2
- Fix percent quest preview: now correctly shows jellybean + number + "%" in icon mode, and floating "75%" in text mode.
- Fix preview animation: replace unreliable AnimationGroup with C_Timer ticker so "Animate Main Icon" visibly pulses in the options panel preview.
- Add individual size sliders for Kill, Loot, and Percent task icons (8–40px each) in the Task Icons tab — no longer tied to global scale.
- Extend task icon offset range from ±30 to ±80 to allow positioning further from the nameplate.
- Restyle icon display mode toggle: replace "Show Icon Background" checkbox with explicit "Icon" / "Text" style buttons.
- Fix percent quest not respecting icon/text style toggle — jellybean now shows/hides correctly for percent quests.
- Fix default percent icon X offset overlapping the progress value — default shifted to +10.
- Reduce outline layer opacity default to 70% and use a narrower font size (fontSize−2) to prevent thick black bleed obscuring text.
- Preview reflects individual task icon sizes and updated offsets in real time.

## v1.8.1
- Fix ghost quests on old characters causing fake nameplate objectives: skip hidden quest log entries (isHidden) in all quest scanning loops.

## v1.8.0
- Add inline ↺ reset buttons next to every slider and color control; remove large section-level reset buttons.
- Decouple "Show Icon Background" from task icons — kill/loot mini icons now show/hide independently via their own toggles.
- Add "Outline Opacity" slider (0–100%) for granular outline intensity control without changing the outline mode.
- Rename "Quest Icons" tab to "Task Icons" throughout the options panel.
- Preview auto-switches to the relevant quest type when adjusting kill/loot/percent color or offset settings.
- Fix animate main icon in preview — now uses a more dramatic fade (1.0→0.15) so it's clearly visible.
- Add activateKillMode / activateLootMode helpers on preview frame for consistent mode switching.
- Compact About tab — removed verbose description box and standalone community section.

## v1.7.9
- Fix "Enable" button label in General tab was showing full addon name instead of just "Enable".

## v1.7.8
- Redesign options panel into 6 tabs: General, Font, Colors (new), Main Icon, Quest Icons, About.
- Move all color/tinting settings into dedicated Colors tab — clears overflow from Main Icon and Quest Icons tabs.
- Change font outline selector from three buttons to a slider (None / Normal / Thick); default changed from Thick to Normal.
- Add "Animate Quest Icons" toggle in Quest Icons tab (pulsing animation on kill/loot mini-icons).
- Fix Reset buttons overflowing the panel frame across all tabs.
- Fix quest-icon offset sliders overflowing right edge of panel.

## v1.7.6
- Fix "Show Icon Background" preview: toggling back on now correctly restores the sample number text (was stuck showing "5/8"/"2/5").
- Merge RGX Mods content into About tab; remove standalone RGX Mods tab.

## v1.7.5
- Add "Show Icon Background" toggle in Main Icon settings: when disabled, hides the jellybean icon and shows fraction text (e.g. "4/8" for kill quests, "2/5" for item quests) matching the percent quest style.
- Mini quest-type icons (sword/bag) also hide when icon background is disabled.

## v1.7.4
- Fix quest icon texture sublevel (7→1) so count text always renders on top in all WoW builds.
- Fix quest-complete animation (qmark) sublevel (0→7) so it flashes visibly on top of the icon.
- Fix options preview: kill/loot mini-icon sublevels now match in-game nameplate rendering (sublevel 1).
- Add Enable/Disable toggle to General options tab.
- Add missing defaults for showMessages, fontFamily, outlineWidth — Reset All Settings no longer breaks these.
- Remove dead fontColor default (was never applied to any rendered element).

## v1.7.3
- Fix percent icon live preview not switching to "% Quest" mode when offset sliders are moved — the preview now auto-switches so the "%" position updates are visible in real time.

## v1.7.2
- Fix percent icon X/Y offset sliders not moving the "%" text in the live preview.

## v1.7.1
- Fix `/sqp` slash command causing an error when typed during combat (combat lockdown).
- Fix percentage quest display showing "%" stacked on top of the number — now shows combined (e.g. "37%").
- Add X/Y offset controls for the percent icon in the Quest Icons settings tab.

## v1.7.0
- Add outline color setting for quest text (nameplates + preview).
- Fix settings reset to fully restore defaults and refresh classic nameplate scans.
- Improve classic tooltip matching for quest objectives (Questie formatting).
- Add toggles for kill/loot quest type icons.
- Fix outline color to apply with normal/thick outline widths.
- Make DEBUG prefix brackets white in chat messages.
- Fix outline color so "no outline" doesn't show colored shadows and thick outlines don't show black shadowing.
- Split icon options into Main Icon and Quest Icons tabs (removed advanced toggle).
- Separate icon tinting for main icon vs quest type icons.
- Fix outline rendering so outline color no longer bleeds into font color.
- Improve classic quest matching when quest IDs are missing in the log.
- Add classic-safe fallbacks for kill/loot icons.
- Use the hostile cursor attack icon for kill quests.
- Improve classic tooltip parsing by checking all objective lines.
- Simplify classic detection: tooltip objective lines + quest log matching (no item caching).
- Use quest-related unit flags as a fallback when objective text matching fails.
- Refresh quest plates on target/mouseover and add a short delayed rescan after plate show.
- Refine retail tooltip parsing to use quest line types and ignore non-player objectives.
- Make tooltip count parsing tolerant of whitespace and reuse objective parsing helper.
- Use C_TooltipInfo when available (including Classic modern clients) and scan both tooltip columns.
- Make chat prefix brackets white.
- Add kill/loot icon offset settings and percent icon for progress quests.
- Apply icon tinting to kill/loot icons and percent symbol.
- Compact quest type icon offset controls to save space in options.
- Add optional quest icon pulse animation toggle.
- Fix outline color visibility by moving outline text above the icon layer.
