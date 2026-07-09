# BliZzi Party Tools 4.1.5

* **Changed:** all locales updated, every setting is now translated in every supported language
* **Added:** right-click on the minimap button toggles move mode for all movable frames (Interrupt Tracker, Keystone List, Party CDs standalone window)
* **Removed:** floating Lock button below the unlocked Interrupt Tracker
* **Fixed:** target-cast externals (Ironbark, Life Cocoon, Blessings) are recognized more reliably: talent and cooldown state now rule out impossible candidates instead of blocking the detection
* **Fixed:** members without any spec data get their spec-bound icons as soon as a spec-exclusive spell is seen (Ironbark proves Resto); previously the detection ran but had no icon to glow
* **Fixed:** Hunter Survival of the Fittest no longer glows the Aspect of the Turtle icon in busy fights (combat flag churn faked Turtle evidence; wrong attributions also no longer cascade)
* **Added:** Wago App support (addon ID in the TOC, updates via the Wago installer)
* **Added:** WagoUI pack profile API (UI packs can export, import and switch BliZzi profiles)
* **Fixed:** Dark Ranger Smoke Screen proc (3s Survival of the Fittest from Exhilaration) no longer consumes a tracked SotF charge

---

# BliZzi Party Tools 4.1.4

* **Fixed:** Party Cooldowns corrects stale spec data via the group role (a Windwalker who switched to Mistweaver kept showing Touch of Karma instead of Life Cocoon)
* **Added:** minimap tooltip lists your party members and whether they broadcast spec data (LibSpec); shown in parties only, not in raids
* **Fixed:** multi-charge cooldowns no longer snowball to impossible recharge times when used back to back (Evoker Obsidian Scales showed 0 charges and 800s+)
* **Performance:** Party Cooldowns no longer re-checks auras it already rejected (97% of all aura lookups were repeat misses; combat CPU cost drops sharply)
* **Fixed:** Life Cocoon cast on another player now glows in instances (absorb evidence picks it among multiple external candidates)
* **Fixed:** Frost Mage Ice Cold aura detection in instances (spell DB reports no category flag, forced BIG)

---

# BliZzi Party Tools 4.1.3

* **Added:** selective export/import: Profiles/Modules modes with multi-select (ship chosen profiles, or share one or more modules' settings)
* **Added:** module strings pasted into the profile import are detected and ask for confirmation instead of overwriting the whole profile
* **Added:** single-profile exports import under the name you enter (spec assignments follow the rename)
* **Changed:** Import/Export window redesigned, follows the settings theme (Default/Alliance/Horde)
* **Fixed:** Frost Mage Ice Cold now tracked (cast/aura ID mix-up)
* **Fixed:** Mage Alter Time no longer glows as Ice Block (wrong category flag)
* **Changed:** Mirror Image and Greater Invisibility are no longer tracked (not reliably detectable)
* **Added:** Keystone List supports the Midnight Season 2 dungeons (patch 12.1) including their teleports; the test layout previews the new rotation

---

# BliZzi Party Tools 4.1.2

* **Added:** Interrupt Tracker settings preview — a live mirror of your configured bar (texture, colours, sizes, border), pinned at the top while you scroll; click any part (icon, name, CD, title, marker — dimmed if turned off) to jump straight to its settings
* **Changed:** Party Cooldowns tracks defensives only — offensive CDs disabled (no longer reliably detectable since recent patches)
* **Changed:** Divine Hymn, Guardian Spirit and Spell Reflection are no longer tracked — not reliably detectable (IMPORTANT-only / target-cast attribution)

---

# BliZzi Party Tools 4.1.1

* **Added:** NDui party/raid frames as an anchor source (Interrupt Tracker, PI Caller, Party Cooldowns)
* **Added:** Interrupt Tracker independent icon size — the icon can be larger than the bar and overhang it (Size & Font → Icon Size)
* **Added:** Interrupt Tracker icon gap — horizontal spacing between the icon and the bar (Size & Font → Icon Gap)
* **Added:** Interrupt Tracker "Show raid markers" toggle — turn the interrupted mob's marker on/off (shown only when the spell icon is enabled, since the marker rides the icon)
* **Removed:** Interrupt Tracker Display Mode setting — the tracker is standalone-only now (the attached modes couldn't work with the interrupt history); anyone who had an attached mode is moved back to the window automatically
* **Removed:** Interrupt Tracker "Anchor to unit frames" setting — superseded by Free Anchor (pick any frame with the mouse + X/Y offset)
* **Fixed:** spell tooltip on hover over the interrupt icon works again (it was suppressed after the Announce removal)
* **Fixed:** failed interrupt now shows the red countdown number again (the red feedback had been turned off during the rework, leaving the number blank on a wasted kick)
* **Changed:** hovering your interrupt icon during the success overlay shows the *interrupted* spell's tooltip (matching the icon). In instances where the enemy spell is hidden by the game, no tooltip is shown there instead of the mismatched "your own kick" one
* **Fixed:** bar contents no longer shift ~1px (e.g. the player name) on the first setting change after login — the bars are now pixel-snapped to the final frame scale at load

---

# BliZzi Party Tools 4.1.0

* **Added:** Interrupt Tracker "Free Anchor" — pin the window to any on-screen frame with a mouse picker, plus X/Y offset sliders
* **Added:** minimap tooltip shows each module's status at a glance (Active / Idle / Hidden / Deactivated)
* **Added:** one-time update notice explaining the reworked interrupt tracker
* **Fixed:** teammate bar names now respect the "Use class color (names)" toggle
* **Fixed:** raid marker now sits on the correct side when the interrupt icon is on the right
* **Fixed:** Death Knight Anti-Magic Shell vs Icebound Fortitude mix-up
* **Fixed:** Windwalker Touch of Karma now tracked (was filtered out by a talent gate and mis-flagged)
* **Fixed:** Paladin Blessing of Protection / Sacrifice now tracked when two Paladins are in the group
* **Removed:** Blessing of Freedom tracking — not reliably detectable (generic "important" aura flag only)
* **Removed:** non-functional Announce options
* **Performance:** no interrupt processing in any zone the tracker isn't shown in (e.g. a raid with "Show in Raid" off) — the cast watchers fully unregister there

---

# BliZzi Party Tools 4.0.15-alpha

* **Added:** Interrupt history — who interrupted which spell + target marker
* **Added:** Interrupt Tracker enable/disable toggle
* **Added:** localized addon-list descriptions (de/fr/es/ru/ko/zh)
* **Fixed:** Hunter Survival of the Fittest vs Aspect of the Turtle mix-up
* **Removed:** Kick Rotation
* **Changed:** green flash on a confirmed interrupt
* **Performance:** no interrupt processing while solo
* **Note:** history list, not a cooldown tracker

---

# BliZzi Party Tools 4.0.14

* **Fixed:** Party CDs — Brewmaster Monk Fortifying Brew now uses its correct 6-minute base cooldown (was showing 2 minutes); the Expeditious Fortification reduction is applied at the correct Brewmaster value
* **Fixed:** Party CDs — Guardian Druid Barkskin now uses its correct shorter cooldown and gains the extra Ursoc's Endurance duration
* **Fixed:** Party CDs — Feral Druid Berserk and Enhancement Shaman Ascendance now account for their cooldown-reduction talents
* **Added:** Party CDs — Hunter Roar of Sacrifice is now tracked (external defensive)
* **Fixed:** Party CDs — Windwalker Monk Touch of Karma now shows the correct cooldown and duration (it was being shortened / extended by talents that actually affect a different ability)
* **Fixed:** Party CDs — corrected talent cooldown / duration attributions on Protection Warrior Shield Wall, Fury Warrior Enraged Regeneration, Restoration Shaman Ascendance, and Marksmanship Hunter Trueshot

---

# BliZzi Party Tools 4.0.13

* **Fixed (hopefully — I'm a vibe coding pro!):** after patch 12.0.7 the game suddenly flagged literally EVERY buff as 'important' (yep, even your food), so Party Cooldowns lit up random spells on every class. I vibe-coded at the IMPORTANT flag until the glows calmed down — fingers crossed it stays fixed! BIG / EXTERNAL defensives and cast-detected cooldowns were never affected
* **Added:** clicking the Twitch / Discord links opens a small copy box with the URL — Ctrl+C (or Ctrl+X) copies and closes it. The Twitch box also notes you're welcome to drop by the stream for questions / feedback (German & English)
* **Fixed:** profile Import/Export — the status/bundle hint now appears below the profile string box instead of overlapping it

---

# BliZzi Party Tools 4.0.12

* **Added:** Traditional Chinese (zhTW / Taiwan) localization — fixes garbled text on Taiwan clients, whose font lacks Simplified-only glyphs
* **Added:** Keystone List — themed info banner when joining a Group Finder dungeon group (title, dungeon, category, leader, comment). Auto-fades; toggle in settings, position it via Test Layout (movable placeholder showing your own keystone)
* **Added:** VuhDo and EllesmereUI party frames as anchor sources (Interrupt Tracker, PI Caller, Party Cooldowns)
* **Added:** Interrupt Tracker display mode "Attached Bars" — each member's full interrupt bar anchored to their unit frame; width matches the frame by default or a custom width (above / below / overlay)
* **Added:** Interrupt Tracker Standalone Window can anchor to the party-frame container ("Anchor to unit frames") so the whole bar block travels with your unit frames
* **Added:** Interrupt Tracker "Show Icon" toggle — hide the spell icon column so the bars span their full width; Icon Position is only offered while the icon is shown
* **Added:** Interrupt Tracker frame-layer (strata) setting — pick Background / Low / Medium / High / Dialog so it sits behind or in front of other UI. Applies to standalone and attached modes; the default Medium keeps attached bars auto-layered just below the unit-frame name
* **Changed:** minimum interrupt Bar Height lowered to 2px
* **Fixed:** attached interrupt icons no longer show a class-default interrupt for your own character on specs that don't have one (e.g. Silence on Disc/Holy Priest) — now matches the standalone window
* **Fixed:** Paladin Party CDs — Blessing of Sacrifice CD is now spec-aware (Holy 105s, Prot/Ret 60s with the talent); Spellwarding is offered for every spec and replaces BoP when talented; Prot's extra -15% CDR on Divine Shield / BoP / Spellwarding is applied; Sentinel and Avenging Crusader durations corrected
* **Added:** Divine Protection (Holy) is tracked again in Party CDs
* **Note:** more fixes for missing Party Cooldown tracking are still to come — will follow as time permits

---

# BliZzi Party Tools 4.0.10

* **Fixed:** Mistweaver Monk no longer shown with an interrupt spell (the spec has none)
* **Added:** "Hide out of combat" option — hides the display while you're not in combat
* **Changed:** lower CPU usage — event watchers and the update tick now go idle when the module isn't needed in the current context (e.g. a raid with the raid display off)

---

# BliZzi Party Tools 4.0.9

* **Added:** Settings search — type in the sidebar box to live-filter settings; click a result's page banner to jump to that page
* **Added:** Local-player cooldowns + charges now persist across /reload (re-seeded from Blizzard's API instead of resetting to ready/full)
* **Added:** Party CD glow now clears immediately when a buff is cancelled / dispelled early, instead of pulsing for the full duration
* **Added:** Ret Paladin Divine Protection (403876) tracked (glow-less to avoid flag-twin conflicts)
* **Added:** `/bitpcd charges` diagnostic command
* **Fixed:** phantom Survival of the Fittest charge when casting Aspect of the Turtle / Feign Death within its first 2s (flag-twin event-order race)
* **Fixed:** Fiery Brand charges no longer flicker / drain / stick from Burning Alive spreads — the recharge timer ticks down monotonically and restores correctly
* **Fixed:** Enraged Regeneration only shows when the talent is picked; duration modifier corrected
* **Fixed:** Touch of Karma now detected via its self-buff aura
* **Fixed:** Survival of the Fittest base duration corrected to 6s (8s with Lone Survivor)

---

# BliZzi Party Tools 4.0.8

* **Fixed:** Warrior Avatar / Spell Reflection glow attribution — tentative now prefers longer-duration buffs and reads `aura.spellId` as a positive-ID fast path when available
* **Fixed:** Spell Reflection duration corrected from 8s to 5s (matches tooltip)
* **Added:** Spec-level CD modifier mechanism — Protection Warriors now get Spell Reflection's correct 20s baseline (vs 25s for Arms/Fury)

---

# BliZzi Party Tools 4.0.7

* **Added:** Korean (한국어) localization
* **Added:** Mich's RaidFrames support as a unit-frame provider (Interrupt Tracker, PI Caller, Party CDs)
* **Added:** Spell Reflection (Warrior) tracked in Party CDs
* **Added:** Alter Time (Mage) now detects both spec-variant cast IDs
* **Added:** Chrabbyw (Arms Warrior) to test mode roster
* **Fixed:** Party CDs multi-charge spells (Blur, Survival of the Fittest, etc.) no longer get stuck at 0 charges from spurious aura-refresh events
* **Fixed:** Party CDs Split Offensive/Defensive no longer applies in Standalone Window mode
* **Fixed:** Fiery Brand icon no longer flashes when "Show own cooldowns" is disabled

---

# BliZzi Party Tools 4.0.6

* **Fixed:** Pala Blessing of Freedom now glows correctly when cast (flag-twin pool with disabled Avenging Wrath was blocking attribution)
* **Fixed:** phantom Rebuke CD ticking on a nearby Pala when the local player kicked (event-order race between INTERRUPTED and SUCCEEDED)
* **Changed:** Party CD classifier handles `1+N` mixed candidate buckets with eager non-disabled attribution + duration-probe verification
* **Changed:** Interrupt candidate-attribution loop deferred 50ms with persistent `_lastOwnKickTime` + player-precedence in `CorrelateSignals`

---

# BliZzi Party Tools 4.0.5

* **Changed:** addon renamed to "BliZzi Party Tools" across all UI surfaces (folder + SavedVariables unchanged)
* **Added:** Settings window theme — Auto / Alliance / Horde / Default with faction crest on title bar
* **Fixed:** local-player CD sync no longer throws "compare secret number" in taint-heavy encounters
* **Added:** TOC Notes line so the in-game addon list shows a hover summary

---

# BliZzi Party Tools 4.0.4

* **Changed:** addon renamed to "BliZzi Party Tools" (folder + SavedVariables unchanged)
* **Added:** local-player CD sync via `C_Spell.GetSpellCooldown` — pulls our tracker in when dynamic talent CDR fires
* **Added:** talent-modifier coverage for 25+ spells (Combustion, Shield Wall, Ascendance, Berserk, Mirror Image, Ironbark, etc.)
* **Changed:** Party CDs use optimistic charge detection when LibSpec talent data is blocked (M+)
* **Fixed:** Keystone List teleport row-vs-DB race — clicking a row now ports to the dungeon shown on that row
* **Fixed:** Custom Names nickname edits refresh Interrupt Tracker, Party CDs, and Keystone List live
* **Fixed:** own-nickname display for Party CDs and Keystone List (Name-Realm vs short-name mismatch)

---

# BliZzi Party Tools 4.0.3

* **Added:** Party CDs Standalone Frame mode — single movable container, one row per member, class-coloured names
* **Added:** Devourer DH (spec 1480) support — Blur + Void Metamorphosis
* **Added:** Vengeance DH Metamorphosis tracking with duration narrowing vs Pala BoF
* **Changed:** Vanish / Shadowmeld / Stoneform set to "Currently not trackable" pending detection path
* **Fixed:** Party CDs spell filter tab-switch overlay leak
* **Fixed:** Party CDs standalone-frame position persistence across /reload
* **Added:** Custom Names per-feature Apply-To dropdown (Interrupt Tracker / Party CDs / Keystone List)
* **Fixed:** Custom Names changes refresh all three features live
* **Changed:** Keystone List Test Layout converted from button to toggle
* **Changed:** Settings frame-mode and anchor-mode controls hide based on active mode

---

# BliZzi Party Tools 4.0.2

* **Added:** Party CDs Split Offensive / Defensive — separate anchors for DEF and OFF spells
* **Added:** Fiery Brand tracking with Burning Alive spread + Down in Flames talent support
* **Added:** flag-key override mechanism (`notBig` / `notExternal` / `notImportant`) for runtime-flag mismatches
* **Changed:** spec-gated entries show optimistically until LibSpec data arrives (M+ comm-blocked path)
* **Added:** `/bitpcd auras` and `/bitpcd flags` diagnostic dumps

---

# BliZzi Party Tools 4.0.1

* **Added:** Party CDs custom borders — Border Texture + Border Color pickers
* **Added:** Party CDs Spell Filter — class-sorted Def / Off / Racial tabs with tooltips
* **Added:** Party CDs max-icons-per-line wrap for TOP/BOTTOM anchors
* **Added:** Keystone List teleport cast indicator (green progress fill)
* **Changed:** Settings colors merged into one "Colors" section
* **Fixed:** Druid Balance offensives (Celestial Alignment / Chosen of Elune) track correctly in M+
* **Added:** Druid Improved Barkskin extends glow duration to 12s when talented
* **Changed:** Settings sidebar icons removed for cleaner text-only menu
* **Added:** localization for new strings across de_DE / fr_FR / es_ES / ru_RU / zh_CN

---

# BliZzi Interrupts 4.0.0

* **Added:** Party Cooldowns full rebuild — auto-attaches to ElvUI / Cell / Grid2 / EnhanceQoL / Danders / SUF / Blizzard frames
* **Added:** multi-charge tracking with live charge-count badge for talented spells
* **Added:** talent-aware cooldowns (flat-seconds + percentage scalars) via LibSpecialization
* **Added:** Feign Death tracking via `UnitIsFeignDeath` flag transitions
* **Changed:** Settings panel reworked into six logical sections with live-apply (no /reload)
* **Removed:** M+ Tools feature (pull timers can't start during an active encounter)
