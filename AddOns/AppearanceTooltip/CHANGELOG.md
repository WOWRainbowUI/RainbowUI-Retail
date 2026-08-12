# AppearanceTooltip

## [v84](https://github.com/kemayo/wow-appearancetooltip/tree/v84) (2026-08-09)
[Full Changelog](https://github.com/kemayo/wow-appearancetooltip/compare/v83...v84) [Previous Releases](https://github.com/kemayo/wow-appearancetooltip/releases)

- Update TOC for 12.1.0, 2.5.6  
- Stop relying on the deprecated GetInventorySlotInfo global  
    12.1 moved this into C\_PaperDollInfo.  
- Remove two expressions that did nothing  
    The length check on the SilverDragon loot buttons read as a guard against an  
    empty list, but zero is true in Lua, so it always passed. The ipairs below  
    already handles an empty table. known\_any was set and never read.  
- A set with no appearances could error in the sets list  
    Dividing the collected count by a total of zero gives a nan, which ColorGradient  
    then feeds to select as an index and errors on. Because this runs from the  
    scroll box update, it could repeat for as long as the list is open.  
- Set tokens with difficulty variants put a link where an itemID was wanted  
    When a token resolved to a variant, the item we display was stored as a bare  
    link rather than an itemID, which the model and journal calls further down  
    don't accept. It now keeps the itemID and moves the preview cache onto the  
    link. Caching on the link is also more accurate for normal items, because the  
    same itemID can have a different appearance depending on its bonuses.  
- Scrolling down over a preview could fail to rotate the model  
    The scroll-up button was given RegisterForClicks("AnyDown", "AnyUp") when the  
    spin option was fixed, but the scroll-down button kept the default of  
    LeftButtonUp. A mousewheel binding has no matching release, so the down button  
    could never see its click.  
- Previews could stay on screen for the previously hovered item  
    The modifier-key check returned before it hid anything, so the model stayed up  
    when you moved to a different item without the key held. The mount, pet and  
    decor branches could also stop partway when the model data was missing, which  
    left the last preview in place. Both cases now use a shared hidePreview, which  
    also stops the positioner and spinner running against a hidden frame.  
- Centralize a lot of overlay hiding logic  
    Make immediate refreshes from the config work  
- Set overlay wasn't stripping the trailing separator  
- Disabling merchant overlays would leave overlays in place until refresh  
    Well, it'd remove the very first overlay...  
- Abandon earlier with IsRectValid in a way that allows retries  
    Follow-up to bf84c3cb1bbd6c6794771ef0729fb5c43cce52da  
- Actions: use the luacheck action instead of installing it from luarocks  
    The lint job ran apt-get install with no apt-get update ahead of it, which  
    fails whenever the runner image package index is stale.  
    lunarmodules/luacheck@v1 replaces those three steps and runs the same  
    luacheck . --no-color -q. Updates the checkout action from v2 to v7, which  
    was still running a node version GitHub is retiring; nothing in that range  
    affects a push-triggered workflow. Pins the packager to v2 rather than  
    master, so an upstream change can no longer land in a release without  
    warning; v2 is the maintained major tag, so fixes within the v2 line still  
    arrive.  
