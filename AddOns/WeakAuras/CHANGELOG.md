# [5.12.6](https://github.com/WeakAuras/WeakAuras2/tree/5.12.6) (2024-04-02)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/5.12.5...5.12.6)

## Highlights

 - Added DBM_TimerUpdateIcon event listener
- Faction Reputation trigger rework
- More Cataclysm updates
- Bug fixes 

## Commits

Artemis (1):

- Add DBM_TimerUpdateIcon event listener (#4916)

Boneshock (2):

- Faction Reputation trigger rework (#4968)
- Hide boolean types in text replacements tooltips

InfusOnWoW (5):

- Update Atlas File List from wago.tools
- Fix lua error for OnHide Animations in certain cases
- Cast Trigger: Fix Spell ID/names being invisible
- No global names for WeakAurasDisplayButtons and WeakAurasImportButtons
- Update Atlas File List from wago.tools

Leon Solis III (1):

- Add GitHub Actions workflows for Release Notifications (#4952)

Stanzilla (4):

- Fix typo in docs and add more globals
- CI: Tweaks to release notifications
- CI: Use my forked cat action
- Workflow tweaks

dependabot[bot] (1):

- Bump tsickert/discord-webhook from 5.4.0 to 5.5.0

emptyrivers (2):

- add a label to bool property changes (#4969)
- invite users to try Bisector when reporting issues

mrbuds (7):

- Revert "No global names for WeakAurasDisplayButtons and WeakAurasImportButtons" as it break login on Cataclysm, fixes #4976
- add eclipseDirection to power trigger
- Add Eclipse power type for Cataclysm
- Classic: use model_fileId instead of model_path
- Remove ResizeBounds workaround
- Fix SpinBox offsets on Cataclysm
- Fix profiling window on classic_era/wotlk/cata

