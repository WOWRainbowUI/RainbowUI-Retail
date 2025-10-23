Decursive 2.7.30
================


Decursive 2.7.30 (2025-10-22)
-----------------------------

- Fix compatibility with Classic and MoP (Thanks Blizzard for telling me that
  GetNumUnspentTalents and GetNumTalentTabs API are unsupported in this version of World of Warcraft,
  but you know, the nil check worked just fine...).

- Fix Decursive's MUFs not showing for players between level 10 and 15. That's
  the positive consequence of the breakage above — 🎵always look on the bright side of life 🎵.

- Do not attempt to move the MUFs when in combat and drop it where it is if the
  user happened to be in the process of moving it while entering combat...

- ToC updates


**New Way to support Decursive:** If you are an [ADA/Cardano](https://cardano.org) holder you can
delegate your stake to my pool: [anfra.io](https://anfra.io)


Decursive 2.7.29 (2025-07-21)
-----------------------------

- Compatible with MoP

- ToC updates


Decursive 2.7.28 (2025-05-08)
-----------------------------

- TOC updates.


Decursive 2.7.27 (2025-03-17)
-----------------------------

- Enable role detection in non-retail versions of WoW.

- Fix unit sorting when using the "player" placeholder.

- Widen the populate list UI.

- Improve and fix class locals initialization where the female version was
  always selected in WoW retail.

- Fix Lua error forwarding in WoW retail.

- TOC updates.


Decursive 2.7.25 (2025-01-06)
-----------------------------

- Fix: Player's character was ignored in priority list if other non-present
  player names appeared before.

- New "Player" entry in the populate priority list GUI to add the currently
  playing character (useful when using the same profile on different
  characters).

- TOC updates.


Decursive 2.7.24 (2024-11-01)
-----------------------------

- Detect Void Rift in TWW and allow it to be cured by the 1st registered spell ([issue #30](https://github.com/2072/Decursive/issues/30)).

- Fix potential initialization issue.


Decursive 2.7.23 (2024-10-04)
-----------------------------

- Fix pet's spells addition by name in the custom spell interface.

- WoW classic: fix Lua errors with pet's spells

- Fix Improved Detox detection for Mistweaver monks.

- WoW Cataclysm 4.4.1 (current PTR): fix Lua error due to API change.


Decursive 2.7.22 (2024-08-16)
-----------------------------

- Fix Cooldown related Lua error in WoW 11


Decursive 2.7.21 (2024-08-06)
-----------------------------

- Fix many compatibility issues with WoW 11 (Cooldown issue and various Lua errors).

- Fix Evoker's spells priorities.

- Add Remove Greater Curse for mages in WoW Classic SoD.

- Fix bug introduced in 2.7.20 for spells set up to only work on the player (or
  all other units but the player), they had become unusable.

- Mark this version as incompatible with WotLK (This version of WoW classic is still being used in China - Players from China need to stick with Decursive 2.7.17 when playing WotLK).


Decursive 2.7.20 (2024-07-19)
-----------------------------

- Compatible with The War Within Beta.

- Cataclysm: Devour Magic (Felhunter) actually can't remove magic effects on friendly units

- Cataclysm: Fix Priest Dispel Magic capabilities detection: Dispel Magic only
  works on the player unless they are Holy

- TOC updates


Decursive 2.7.19 (2024-05-10)
-----------------------------

- Cataclysm: fix Druid Nature's Cure talent detection.

- Show a checkbox in the main option panel when the MUF's handle was hidden
  using the /dcr related command to make it easily visible again.

- TOC update for 10.2.7


Decursive 2.7.18 (2024-05-02)
-----------------------------

- Cataclysm compatibility update.
 There might be some other necessary fixes, update [issue #23](https://github.com/2072/Decursive/issues/23)
 on GitHub if you find anything.

- Fix expired version false alert in Retail.

- Update TOC for classic.


Decursive 2.7.17 (2024-03-21)
-----------------------------

- Fix spell detection for 10.2.6.
  Thanks to Jardragon901 and Meivyn for their help in fixing this!


Decursive 2.7.16 (2024-02-19)
-----------------------------

- Work on [issue #20](https://github.com/2072/Decursive/issues/20):

Since 10.2.5, Blizzard deprecated some long standing optimized APIs to get
buffs and debuffs from units and replaced them with new APIs that have the
downside effect of 'garbage-leaking' memory every time they are called (for
Lua devs, they create a new table each time they return data on a
buff/debuff and we cannot provide them with a table to use...).

This release of Decursive completely fixes memory usage when the "Show stealth status"
option is used (on by default) which was the main cause of the huge memory usage
increase since 10.2.5.

However, memory usage is still increased compared to before WoW 10.2.5 was
released when some units have ongoing debuffs, fixing this is complicated
because it touches the core of Decursive written more than 10 years ago.

Thus, new settings were added in the Micro Unit Frames performance options to control
the global periodic unit rescan which is the main culprit regarding this
increased memory usage and may in fact no longer be necessary for Decursive to work:
- `Debuff periodic full scan`
- `Periodic scan debuf report`

We need to test if we can go without this periodic rescan, you can set the
setting to 0 in order to disable it completely or increase the delay between
scans to a high value (10s) and enable the `Periodic scan debug reporting`
options. This will create a debug report that will pop out after a fight if
the scan function detected something that was not detected by the event system.

This periodic rescan may still be required by some very specific debuffs but
I'm not sure that this is the case anymore.

Note that if you did not notice anything performance-wize since 10.2.5 with
Decursive, you can ignore the above.

WoW classic and WoTLK are not affected by this issue (yet)


Decursive 2.7.15 (2024-01-21)
-----------------------------

- Fix Lua error when bleed default keywords are empty.

- Fix bleed effect keywords defaults detection for non ASCII locals.
Users should check if the defaults are correct, if they are not please open a
new issue: Open the option panel (`/decursive` in chat), and head to
 `curingoptions` -> `Bleed effects management` to check the default keywords.

- TOC update for 10.2.5


Decursive 2.7.14 (2023-12-18)
-----------------------------

- Fix spell detection in classic versions of WoW when "Show all spells ranks"
  option is not checked in WoW's spell book UI.

- The blacklist can now be disabled completely by setting the "Seconds on the
  Blacklist" option to 0.

- Fix problem with Decursive' message frame preventing the new Pinging WoW
  feature to work when clicking through this invisible frame.

- Support for improved purify talent which is now required for priests to be
  able to cure diseases with Purify (WoW Retail).


Decursive 2.7.12 (2023-11-08)
-----------------------------

- TOC update for Retail


Decursive 2.7.11 (2023-10-22)
-----------------------------

- TOC update for Wrath


Decursive 2.7.10 (2023-09-12)
-----------------------------

- Add support for Bleed Effects detection:
    - Decursive scans the debuffs with no type for particular keywords ('Physical' and 'Bleed' by default) in their description.
    - The debuffs are automatically added to a list the user can edit under the curing options
      (it is recommanded to review this list for non-English locales).

Many thanks to Teelolws for prototyping this solution and to Xadras for their
suggestions and follow-ups about the user editable list. Their contributions
made this solution possible.

Report any problem found with this new feature in [issue #248 on wowace.com](https://www.wowace.com/projects/decursive/issues/248).

- Decursive will remember the priority of types when the associated spells
  disappear as long as the user does not change the priorities.
  The default priorities are displayed in blue instead of green.
  As it is today active spells will always be put on top whenever the user
  changes the settings and lost abilities will be put at the end keeping their
  former order.

- Some layout changes in the MUFs option panel to make it more comfy.

- WoW Classic: Fix detection of Dispel Magic Rank 2 for Priests.



Decursive 2.7.9.3 (2023-07-16)
------------------------------

- Fix Improved Purify Spirit talent detection for resto shamans.

- Remove new DF shaman spells from Classic versions

- TOC updates


Decursive 2.7.9.2 (2023-05-30)
------------------------------

- TOC update for WoW 10.1 with icon support

- Shamans (Dragonflight):
   - Add cleansing totem support.
   - Fix Purify Spirit to only cure curses when Improved Purify Spirit talent is not detected.


Decursive 2.7.9.1 (2023-04-02)
------------------------------

- TOC Updates

- WotLK:Fix GetItemCooldown() Lua error

- WoW 10.1.0 (PTR): Fix GetAddOnMetadata Lua error


Decursive 2.7.9 (2023-02-25)
----------------------------

- Add support for by-specialization-profiles thanks to libDualSpec-1.0.

- Keep specific curing order for each class specialization (instead of just for each class).

- Add an option to hide Decursive's MUFs in raids.

- Decursive text anchor can be moved again.

- Do not report errors thrown in libraries embedded by Decursive on systems using '/' as directory separator.




***
For older versions changes, see OldChangelog.txt


[ticket]: https://www.wowace.com/projects/decursive/issues
[GithubReleases]: https://github.com/2072/Decursive/releases
[BigwigsPackager]: https://github.com/BigWigsMods/packager
