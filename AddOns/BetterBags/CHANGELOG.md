# BetterBags

## [v0.1.25](https://github.com/Cidan/BetterBags/tree/v0.1.25) (2024-04-08)
[Full Changelog](https://github.com/Cidan/BetterBags/compare/v0.1.24...v0.1.25) [Previous Releases](https://github.com/Cidan/BetterBags/releases)

- deleting items from ephemeral categories will correctly use the merged category list.  
- Fixed a check on ephemeral categories on wipe.  
- Ephemeral categories can now be toggled on and off.  
- Ephemeral categories show up on the category list.  
- categories created by the API are now ephemeral by default  
- Bucket timers no longer poll for new messages.  
    Bucket timers now reset when additional events come in during the bucket period.  
