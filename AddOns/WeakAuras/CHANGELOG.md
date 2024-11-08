# [5.17.5](https://github.com/WeakAuras/WeakAuras2/tree/5.17.5) (2024-11-06)

[Full Changelog](https://github.com/WeakAuras/WeakAuras2/compare/5.17.4...5.17.5)

## Highlights

- cataclysm classic: fixed spec load option dropdown ordering
- custom code: aura_env.saved no longer wipes on update if user accepts "display" category
  - 🚨 note - since most people don't fiddle with the defaults when updating auras, this effectively meant that aura_env.saved was always wiped on update.
    It's possible that some authors of custom code have come to rely on this to not have to fixup old saved data with custom code updates, please fix your code if so!
- other minor fixes

## Commits

InfusOnWoW (4):

- BT2: Treat Auras with expirationTime == 0 as having an unknown time
- Temporary Enchants: Use WEAPON_ENCHANGT_CHANGED on retail
- Update Atlas File List from wago.tools
- Update Discord List

Stanzilla (1):

- Update WeakAurasModelPaths from wago.tools

Zachary Smith (1):

- New Mage Spell Alerts (#5523)

dependabot[bot] (1):

- Bump cbrgm/mastodon-github-action from 2.1.8 to 2.1.9

emptyrivers (1):

- fix recurseDiff ignore algorithm

mrbuds (2):

- bump minitalent minor
- Rename WeakAurasMiniTalent widget file for retail from DF to TWW

nullKomplex (4):

- Sort Specializations on the user's end.
- Allow Multiselect Load Options to use a sort order.
- Remove Cataclysm Classic offset on specializations.
- Allow the Select Talent button to close the MiniTalent pane.

