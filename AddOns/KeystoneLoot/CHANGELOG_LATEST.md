## Bugfixes
- auto-sync spec filter with current character spec on login and spec change
The class/spec filter was only initialized once on first install via DB
migration. If the player changed specs in-game or logged in after having
previously selected a different spec in the addon, the filter would remain
stale and items exclusive to the current spec would not appear.
For example, item 193718 (Restoration Druid trinket from Algeth'ar Academy)
was not visible when the stored specId did not match 105, even though the
item data was correct.
Changes:
- Register ACTIVE_TALENT_GROUP_CHANGED event to detect in-game spec changes
- Add SyncSpecFilter() that updates filters.classId and filters.specId to
  match the player's current class/spec at login and on every spec change
- Only syncs when the saved classId matches the current character's class,
  so manually browsing another class's loot is not disrupted
- Also fix item 193718 missing Balance/Feral/Guardian Druid specs

## Other Changes
- Merge pull request [#48](https://github.com/Wolkenschutz/KeystoneLoot/pull/48) by [Edulynch](https://github.com/Edulynch) from Edulynch/fix/auto-sync-spec-filter

## Other Changes
- Update data files
