# BetterBags

## [v0.1.14-18-g975f2a5](https://github.com/Cidan/BetterBags/tree/975f2a5a6f8d8c735ff09a9eb1a8089ed1549d4b) (2024-03-21)
[Full Changelog](https://github.com/Cidan/BetterBags/compare/v0.1.14...975f2a5a6f8d8c735ff09a9eb1a8089ed1549d4b) [Previous Releases](https://github.com/Cidan/BetterBags/releases)

- Fixed missing reagent bank free space slot in retail.  
- removed debug code  
- Worked around a bug in Blizzard's free slot API for banks in classic.  
- Explicitly skip bags with nil invid's  
- fixed an error when loading the bank  
- Removed server call for getting free slot information  
- Added shortcircut for item loading loop.  
- Added loop for item loads.  
    Fixed bank prematurely showing before all item information is available.  
- Internal cleanup release.  
- skip keyring on free slot work  
- Removed free slot section constraints from gridview  
    Small possible fix to free slots in classic.  
- Fixed some tooltip issues  
- Stack.fix.7 (#297)  
    * Moved key bindings check to a delayed function call on addon enable, fixing the alert for missing key bindings.  
    * Fixed slots being redraw if a stack item was removed.  
    * (Internal) Item categories no longer set the category to the bag name when bag view is shown  
    * (Internal) Bag view now locally calculates the category name for each bag on render.  
    * (Internal) Fixed both list and one view for new rendering data  
    * (Internal) Removed first load code, added some comments.  
    * Complete rework of how free slots are counted, generated, and displayed.  
    * Free slots now render for all bag types.  
    * Added free slots tooltip on mouse over.  
    * Fixed an error that would happen if a bag type is full.  
- Stack.fix.4 (#287)  
    * Category functions that misbehave will no longer break all bag rendering.  
    * Fixed duplicate items in the bank when stacking.  
    * Added trade window to interaction event list.  
- Stack.fix.3 (#285)  
    * Rewrote item level draw logic to be cleaner and readable.  
    * Fixed bag view showing stack counts  
- Stack.fix.2 (#284)  
    * Fixed stack items not showing ilevel in some cases  
    * Fixed a bug where item change was still using itemID itemlinks instead of slot itemlinks.  
- Added parsed item link data to item info. (#283)  
    Generate a hash for each item at the data phase, used to figure out of items should stack or not.  
- The Stacking Update (#281)  
    * Items now stack by default when multiple stacks are present, i.e. arrows in Classic, stacks of potions, etc.  
    * Items now stack by default if they are the same item, even if they aren't stackable, i.e. bags, weapons, etc.  
    * Items now automatically unstack when visiting a vendor, bank, auction house, mailbox, etc.  
    * The backpack now opens automatically when visiting a vendor, bank, auction house, mailbox, etc.  
    * The only bag toggle that works for bags is now "Open All Bags". This is to work around several bugs in the Blizzard bag events for opening/closing bags.  
    * Players will now get a notification on load if there is no key bound to "Open All Bags".  
    * Fixed a few item load bugs due to the Blizzard API not sending complete information the first time you load the WoW client.  