# [5.17.0](https://github.com/WeakAuras/WeakAuras2/tree/5.17.0) (2024-08-25)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/5.16.1...5.17.0)

## Highlights

 - Performance improvemsn
- Bug fixes
- Add Bleed type via LibDispel 

## Commits

InfusOnWoW (9):

- Item Count: Add support for reagent/account bank api
- Fix lua errors with progressSources after trigger moving
- Zone Names/Zone Ids, etc: Add - for negation
- BT2: Enable hostility check for group units too
- Spell Triggers: Handle spell names similar to before
- BT2: Add Bleed type via LibDispel
- Options: Allow or searching via " or " and "|"
- Options: Update shape shift combobox if the shape shift data changed
- Totem Trigger: Implement an icon check

emptyrivers (6):

- upgrade cachebuild priority if building & there's a cache miss
- more improvements to spell cache thread
- defer snapshots out of login process
- make spellCache a background task
- supercharge dynFrame
- improve build advertisement

mrbuds (2):

- Fix issue with talent load option showing wrong hero talents in tree
- Workaround C_Reputation.GetFactionDataByIndex returning nil when it shouldn't

