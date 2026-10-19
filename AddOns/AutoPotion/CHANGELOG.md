# Auto Potion

## [4.0.0](https://github.com/ollidiemaus/AutoPotion/tree/4.0.0) (2026-10-18)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.17.2...4.0.0) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Refresh only open settings pages' previews and build debug messages only in debug mode  
    A macro rebuild leaves the Current Priority preview of hidden settings pages alone; each page still refreshes its preview in OnShow, and an open page keeps following bag changes. The log calls that concatenate their message now check ham.debug first, so with debugging off an update builds no strings; with it on the messages are unchanged. The fake client can now close the settings panel, take slash commands and count icon lookups.  
- Rebuild on gear changes only for tinker slots, and register only events the client knows  
    PLAYER\_EQUIPMENT\_CHANGED is registered on Retail only, where tinkers exist, and asks for a  
    macro update only when the changed slot is a tinker slot (head, wrist, gun; Trinket 2 too in  
    debug mode). A gear-set swap that touches no tinker slot no longer rebuilds the macros, and one  
    that does still rebuilds once. TRAIT\_CONFIG\_UPDATED is registered where  
    C\_EventUtils.IsEventValid says the client has it instead of by flavor flag, so Classic Era  
    now listens for it as well.  
    The fake client knows each flavor's valid events (tests/fake/events/, generated from the  
    client's API docs by update.sh there), rejects registering or firing any other, offers  
    C\_EventUtils.IsEventValid, can change gear (Client:equip) and counts C\_Item.GetItemCount  
    calls so tests can tell a rebuild happened.  
    Closes #145  
- Follow bag changes once they settle and only the player's own pet  
    The macros are now requested on BAG\_UPDATE\_DELAYED instead of 3 seconds after the first  
    BAG\_UPDATE, so a looted or used-up item reaches them the frame after the bags settle, and a  
    burst of bag updates still leads to one rebuild. UNIT\_PET is registered for the player only,  
    so group members summoning or dismissing pets cause no work.  
    The fake client records unit filters from RegisterUnitEvent and delivers unit events  
    accordingly; addToBags fires BAG\_UPDATE\_DELAYED, changeBagsOverFrames models a burst over  
    several frames and learnSpell fires SPELLS\_CHANGED.  
    Closes #144  
- Show the shared Current Priority preview on the Food, Drink, Bandage and Mana Potion pages  
    The four pages drop their copies of the preview code and fill the shared preview row with the  
    items of their list that are in the bags (PreviewRow:showItemsInBags). So their icons come from  
    C\_Item.GetItemIconByID and show with an empty item cache, sit at the position of their index  
    with no overlaps when the list grows or shrinks, and show the tooltip of the entry they hold now  
    through handlers set once. The scroll content always leaves room for the row below the title.  
    Tests cover each page on Retail, Classic Era and Forever. Refs #143.  
- Show the main page's Current Priority preview with real icons and no overlaps  
    The preview is now a shared row (FrameXML/PreviewRow.lua) that the other settings pages can  
    reuse. Each icon's position comes from its index in the combined list, spells first, then  
    items, so reused and new icon frames line up the same way and none lands on another. Item  
    icons come from C\_Item.GetItemIconByID, which doesn't wait for the item cache; the tinker keeps  
    its inventory texture. Icon frames get their tooltip handlers once and show the entry they hold  
    now, and they are created without the stray UIParent template argument.  
    The fake client gains an item cache that can start empty, anchor offsets for the preview icons  
    and hovering them for their tooltip. Refs #142.  
- Write macros only when their text changes and report full macro slots  
    All five macros, standard or MegaMacro-managed, go through one writer that  
    remembers the text it last wrote and skips unchanged writes, so a rebuild no  
    longer makes the action bars refresh for nothing. A missing macro is created  
    with its body in one call; when the general macro slots are full, the player  
    is told once per session for each macro that didn't fit instead of the  
    CreateMacro error being swallowed. The pcall around macro writes is gone, so  
    other macro API errors reach the error handler.  
    The fake client gains a configurable general macro limit, GetNumMacros,  
    injectable macro API errors, a stub MegaMacro addon, and keeps the macros  
    across a /reload.  
    Closes #141  
- Reset to Default resets every box and macro at once, in combat too  
    Reset rewrote the settings but rebuilt only the AutoPotion macro, directly, so in combat the  
    rewrite was a blocked action and the other macros kept their old settings until a reload. The  
    Food page's box kept its old state, and grouped healing spells were re-read by one member's id.  
    Every settings check box now registers how it reads its state; Reset re-reads them all,  
    refreshes the previews and requests the macro update through ham.requestMacroUpdate().  
    Closes #140  
- Request macro updates through one combat-safe, coalesced entry point  
    Settings pages, login and every event now call ham.requestMacroUpdate().  
    Requests in the same frame lead to one rebuild on the next frame; a  
    request made in combat waits for PLAYER\_REGEN\_ENABLED. This replaces the  
    pages' direct macro rebuilds, the separate rebuild on PLAYER\_LOGIN and  
    the timed combat retries, so opening a page or ticking a box in combat  
    is no longer blocked and login writes each macro once.  
    The "Current Priority" previews refresh through ham.refreshPreviews(),  
    which makes no protected calls and so still updates at once in combat.  
    Events dispatch through a table keyed by event name.  
    Part of #139.  
- Keep settings across reload, login and upgrades  
    Unticking Cavedweller's Delight stayed unticked after a reload, but the  
    macro used it again: the lazily built options turned a stored false into  
    true. One loader on the addon's own ADDON\_LOADED now adds missing keys at  
    their defaults without touching stored values, and ham.refreshOptions  
    rebuilds ham.options from HAMDB after loading and after every setter and  
    Reset. All code reads settings from ham.options.  
    Saved settings carry a version. Old settings without the healing-spell  
    list keep everything and get the default list instead of being wiped, and  
    settings from a newer version are left as they are.  
    The fake client gains /reload (saved variables carried into a fresh  
    session) and settings-page helpers. tests/settings\_test.lua checks that  
    every box on every page keeps its state and its effect on the macros  
    through a reload, on Retail, Classic Era and Forever.  
    Closes #138  
- Add agent docs for the issue tracker and the domain docs  
- Batch independent wow.py lookups in the /update-addon skill  
- Add a headless test suite that runs the addon in a fake WoW client  
    tests/run.sh loads AutoPotion the way the game does (TOC order, XML  
    includes, the addon vararg, the vendored libraries) into a fake client for  
    Retail, Classic Era and Forever, logs in, and checks what the player and  
    client see: no Lua errors, the five macros for a given set of bags, no  
    blocked actions, and no globals beyond the addon's own. It needs LuaJIT  
    (brew install luajit), and .pkgmeta keeps tests/ out of the package.  
- Stop leaking the RemoveFromList and ARTWORK globals  
    RemoveFromList is now ham.removeFromList. The Items heading on the Retail  
    settings page passed its draw layer as the name, which created a global  
    named ARTWORK.  
