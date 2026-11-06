# WIM

## [3.19.0](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.19.0) (2026-11-05)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.18.2...3.19.0) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Fix Modern Skin on Forever. Frame is thicker so points need to be offset for the difference.  
- Add modern skin notifications and localization updates for various languages.  
- Add version tooltip to main options category.  
- Add options categoryMap for easy reference to option subcategories using Settings.OpenToCategory()  
- Fix: add fallback global string for LATER.  
- Fix: Options for modern skinning had defaults hardcoded instead of referencing the default table.  
- Merge branch 'alpha'  
- TOC update  
- Merge pull request #300 from Gogo1951:menu-review-fixes  
    Conversation menu: follow-ups from #294 review  
- Grow the conversation menu toward the screen center from every launcher.  
    Adds Menu:AnchorTo(owner, placement), which picks the corner with  
    GetMenuGrowthAnchor and applies the menu skin's edgeOffsets for that  
    corner. The minimap button hangs the menu off its corner, the addon  
    compartment places it beside the dropdown row, and data broker launchers  
    drop it above or below the button. A launcher in the top-right quadrant  
    gets the same placement as before.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
- Move conversation menu options to Appearance > Interface > Conversation Menu.  
    Sort Menu by Activity, Show Recent Whispers, Include All Characters and  
    Show Hints now live with Menu Skin and Unified Menu instead of on the root  
    page. The root page keeps Show WIM Tooltips under a "Tooltips" header.  
    Saved variable keys are unchanged.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
- Merge pull request #294 from Gogo1951:feature/recent-whispers-alpha  
    feat: recent whispers in the launcher menu (port of #279 to alpha)  
- Merge branch 'alpha' into feature/recent-whispers-alpha  
- Skin Defaults: Set default message window skin to cutout to show transparency behind scrolling message frame.  
- TOC: Assigned chat category. #299  
- Merge branch 'alpha' into pr/Gogo1951/294  
- Apply skin offsets to location of conversation menu anchor points when being shown.  
- Temporarily disable conversation menu header  
- Fix conversation dynamic sizing in group mode.  
- Add option to show or hide shortcut hints in conversation menu.  
- Add option to enable "Open on Hover" on Minimap Icon.  
- When showing on hover, alow a click to close the menu instead of waiting for it to timeout.  
- Recent whispers in the launcher menu, ported to alpha  
    Port of PR #279 (persistent history for the Whispers menu) onto alpha's  
    new menu, settings and history archive, plus follow-up behaviour.  
    Whispers menu  
    - Lists recent conversations from saved history below open windows, from  
      every character on the account, so they survive a reload, relog or  
      character change. On by default (db.minimap.recentWhispers).  
    - List rules: open windows and history ranked together by the last message  
      either way; the 5 most recent always shown, anyone further down only if  
      chatted within 10 minutes, or with unread messages / window on screen;  
      30 rows at most. Hiding a row never closes the window.  
    - Clicking an entry opens the window (BattleTags open as Battle.net  
      whispers, offline friends included); the X hides an entry until the next  
      whisper. Other-realm names are qualified as Name-Realm (not on Forever,  
      where history is keyed by ruleset).  
    - Class colours and the Battle.net icon/blue, following "Colorize names".  
      Names stay at full opacity; only the status dot dims.  
    - Header with add-on name and version ("Dev" for an unpackaged copy) and a  
      footer of launcher hints. Opens on hover beside the minimap button,  
      anchored to its lower-left; a click pins it.  
    - Shift + Middle-Click opens Options from the minimap button, add-on  
      compartment and data broker. The minimap button drags without Shift.  
    History  
    - Whisper windows preview the conversation with that person from every  
      character, merged by time (Preview Count still applies).  
    - The History Viewer opens on the realm-wide view and colours names by the  
      class saved with the conversation.  
    - Whispers record the other player's class, from the GUID in both  
      directions; windows learn the class from outgoing whispers too.  
    - Fix: the age-limit cleanup ran at login before the background loader and  
      removed every other character's still-empty slot, so their history never  
      loaded that session. Slots with archived history are now kept.  
    Strings added to all locales.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
- Update translations for added phrases.  
- Separate out the message window skin from the menu skin. Add options to select menu skin from appearance settings.  
- remove old skinning from chat engine.  
- Credit update  
- Lua check correction  
- Lua check corrections  
- Menu has been enhanced with more skinning control.  
- Add trap to ensure `utils.skin.getAtlasInfo` gets the correct parameters  
- Add support for slice data in fallback atlases.  
- WIM Menu integrates better with the addon compartment.  
- Fix menu mouseover check if no anchor points exist.  
- Don't close message windows when settings panel is opened.  
- Era clients are missing high resolution texture art for red buttons. Conditionally use supplied assets for era clients.  
- add utility to check if an atlas image is a 2x asset  
- Merge branch 'master' into alpha  
- Adjust `from` placement to utilize the extra space from the compact portrait.  
- Regression fix: cut out the hole for the class icon so the background doesn't bleed through when applying alpha to the window.  
- Move table utilities into the `utilits.table` namespace.  
- Add new compact modern theme  
- add a spread table utility  
- when fitting text to a bounded box, the minimum font size has been reduced to 6.  
- apply chrome layout on skin application instead of on build.  
- When registering a skin, if schema is v2, it will inherit from the default modern skin.  
- utilize the code skinner instead of a modern overlay for class icons. Added new high res class and client art for the modern theme.  
- don't package psd files  
- consolidate fall back images for metal frame and red buttons into custom atlases. Apply and simplify History and Filter viewers.  
- When applying textures to buttons, perform actions against the individual textures itself instead of the frame.  
- feat: implement modern skin layouts and refactor texture application methods. Removed the lite chrome creation. There are two new NineSliceLayouts: WIMModernSkinMessageWindow and WIMModernSkinStandardFrame which also include fallback Atlas definitions. This opens the ability to skin the frame as well.  
- Fix: linting error  
- Added skinning utilites and added a smart texture applicator which will allow a texture string, atlas to table to be set.  
- utils: organize logically for easier reference.  
- skinner: separate out hardcoded skinning to close button  
- Add realm determination for Forever game rules in History module  
- Move isForever check into WIM.lua  
- Changed situational options indent value for Forever. Tabs spanned larger then panel.  
- update translation dictionary  
- Move modern-skin settings relating to the message window into the skin selection subcategory. Modern skin related settings will be hidden when a class skin is selected.  
- have ui.Header return a control just like the other factory functions.  
- fix: update user formatting to use utils.FormatUserName in getWhisperWindowByUser function  
- Merge branch 'master' into alpha  
- Merge branch 'alpha' of https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger into alpha  
- Fix: If using regional unique names, don't strip out spaces our of a player's name.  
- Fix: If using regional unique names, don't strip out spaces our of a player's name.  
- Modern Skin: continued migration of hard coded widget (`from` and `char_info`) skinning into skin table, and redefining relative points, simplifying the layout.  
- Fix: slash commands entered in a WIM window weren't being processed correctly. #284  
- Move RPProfile related default options into the RPProfile module.  
- Refactor UISnapshot of skin info.  
- Merge branch 'alpha' of https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger into alpha  
- Move history and menu theming from modern skin into the classic default skin eliminating the need for the old UI assets. #281  
- Refactor skin checks to use schema\_version for modern skin validation across multiple modules.  
- Add schema\_version to WIM Classic and Modern skins for versioning consistency. Existing skins will default to version 1.  
- ModernSkin: Moving hard coded widget manipulation into skin data file. (history & shortcutbar so far).  
- ModernSkin: Moving hard coded widget manipulation into skin data file. (history & shortcutbar so far).  
- Fix: Raise window when detaching from tab group.  
- Fix: The drag handle for tabs would disappear prematurely due to frame lag preventing the tab from being dragged correctly and causing some unexpected behaviors.  
- Fix: When detached from a tab group, the message window would not get positioned to where it was dragged to. Detaching window from tab group positioning incorrectly. #283  
- Add a second parameter to `NextTick` which defines the minimum amount of milliseconds to wait before firing. Defaults to `0`.  
- Default skin on retail is "WIM Modern" where as class flavors defaults to "WIM Classic".  
- Fix: dropdown menus weren't sending item data to defined checked and click functions. #285  
- Fix: Apply window opacity to modern skin. #280  
- Add helper function `dump` to `utils.debug`  
- Expand chat types to include all types of whispers (ex: 'SMART WHISPER') when processing slash commands inside a WIM message window.  
- Fix error when holding shift over secondary WIM windows (History, Filters, etc). The message window resizer would try to attach to it causing an error.  
- Refactored Toolbox to Utilities and scoped the exposed tools under WIM.utils.*  
- Update debug slash command description. Pipes in string must be escaped otherwise they are decoded by the client.  
- Move history maintenance code from WIM.lua into the history module itself.  
- Refactor initialization by calling OnInitialized to all modules (whether enabled or not) and by also adding a new OnBeforeInitialized event.  
- Add CallModuleFunctionAll to send events to modules even though they are disabled.  
- CI: Fix typo  
- CI: Revert back to default alpha names.  
- CI: include project revision in file name  
- CI: Change file names for alphas to use the date instead of last tag version.  
- CI: Gate alpha builds from the alpha branch. Tags will publish betas and releases.  
- Build and lint the alpha branch in CI  
    Pushes to alpha now package as alpha builds and pull requests against  
    it get the luacheck run.  
- Round the Edit Mode size sliders and drop the Default prefix from their labels  
    The History Viewer and filter editor panels measured the live frame  
    until a slider was first moved, and a scaled frame measures as a  
    fraction, so the value label printed 700.0000. The measurement is now  
    rounded at the source and every slider row rounds its value label by  
    default; the scale slider keeps its percent formatter. The message  
    window sliders reuse the Width and Height strings, since they resize  
    open windows immediately rather than only setting a default, and the  
    two orphaned keys leave all ten locale files. The Placement & Size  
    fallback sliders for clients without Edit Mode follow suit.  
    Copied over from the machine-local testing branch.  
- Key the suppression filter like the window store and predict the pop-up  
    The chat-frame filter looked the sender up under a realm-qualified key  
    while the whisper handler stored the window under the ambiguated name,  
    because realm stripping compared the event's spaceless realm against  
    the client's spaced one. On any multi-word realm the lookup missed and  
    Show Only in WIM never hid a same-realm whisper. Realm comparison now  
    ignores spaces and hyphens, which also repairs the AFK, DND, system and  
    toast lookups. The shown-once gate becomes a prediction: suppress when  
    the window has been shown or the state's Pop Up on Receive rule (minus  
    the per-type Never Pop Up) would show it, so the first message of a  
    conversation no longer leaks into the chat frame. Same change across  
    the chat types, channels and communities; tooltip and locales re-keyed.  
    Copied over from the machine-local testing branch.  
- Restore the packager version keyword in WIM.lua  
    The modernization merge pinned version to a 3.18.0 literal where  
    master reads @project-version@, so every alpha built from this branch  
    would have announced 3.18.0. The TOC already carries the keyword; the  
    Lua side matches it again.  
- Simplify two negated comparisons that fail luacheck  
    The community slash toggles wrote their flags as not (x ~= false) and  
    not (x == true), which luacheck 1.2 reports as warning 581 and the CI  
    step treats as a failure. Both become the direct comparison with the  
    same result.  
- Merge pull request #278 from Mojo-OG/modernization  
    Modernization: history storage fix (#251), 12.x fixes, native options UI, Modern skin  
- Skip the history archive notice on a fresh install  
    The notice keyed off the schema stamp being absent, which is also true  
    of a brand-new profile with nothing to convert. It now prints only when  
    legacy history was actually queued for conversion.  
    Copied over from the machine-local testing branch.  
- Add locale entries for the new settings and Edit Mode strings  
    Every new page, section, row and tooltip has an enUS entry, and the  
    strings the classic window owned but nothing reads any more are  
    removed. The nine other locales carry machine translations, each marked  
    on its line as a placeholder until a native speaker can confirm or  
    correct it.  
    Copied over from the machine-local testing branch.  
- Rebuild the settings pages on the native panel and migrate settings once  
    The category is reorganised into fifteen pages under Conversations,  
    Windows, Appearance, Notifications, Privacy and History, with lists and  
    grids drawn the way the panel draws its own, one-row sound controls, a  
    WIM Modern Skin page, folder mirrors so search reaches nested pages, and  
    a type-to-confirm dialog for the account-wide history wipe. The  
    defaults are re-baselined (Modern skin, multi-line input, native input  
    colors) and Migrate.lua runs a one-time schema 1 pass over profiles  
    written by earlier releases.  
    Copied over from the machine-local testing branch.  
- Retire the classic options window  
    The native settings panel is now the only options UI, so the classic  
    window, its toolkit, the style toggle and the chat modules' classic  
    pages go away, along with the alias stub that was never wired up and  
    its unused WIM3\_Alias saved variable. Pop-up rules resolve through one  
    shared GetPopRuleSet helper, and chat windows remember whether they  
    were ever shown so a suppressed window does not swallow its first line.  
    Copied over from the machine-local testing branch.  
- Move message window placement and sizing into Edit Mode  
    Message windows, the History Viewer and the filter editor register with  
    the client's Edit Mode as a WIM group in the advanced options, each with  
    its own ghost, size sliders and saved position. Windows now move and  
    size by cursor delta instead of StartMoving, which fixes the jump on a  
    still click and keeps the grip through focus loss. The filter editor  
    becomes sizable, and User Level filters are purged with a notice.  
    Copied over from the machine-local testing branch.  
- Add /wim forcelockdown to exercise the chat lockdown anywhere  
    Flips the addonChatRestrictionsForced CVar so deferral and replay can  
    be tested in the open world instead of inside a rated match. The CVar  
    does not persist across sessions.  
- Clear a reported player's window on PLAYER\_REPORT\_SUBMITTED  
    Matches what the default chat frames do after a report. Saved history  
    is left alone. The event does not exist on classic clients so the  
    registration goes through pcall.  
- Scrub |K protected strings before persisting history  
    |K tokens are session scoped and read back as garbage in later  
    sessions, so they are replaced with a placeholder before the record is  
    saved.  
- Existence gate retail chat APIs so classic clients load clean  
    Community channel colors and names fall back through the legacy  
    ChatFrame globals to a plain gold default, CLUB\_MESSAGE\_ADDED registers  
    through pcall on clients without Communities, and the two legacy slash  
    hooks are gated individually since a client can have one without the  
    other.  
- Guard the remaining secret value edges  
    debugstack itself returns a secret when secure code is on the stack, so  
    the escape handler and skin registration check before matching on it.  
    GetColoredNameByChatEvent can be handed secret args by addons that  
    replace it, the SendChatMessage hook member-checks C\_ChatInfo before  
    attaching, and CanAccessValue plus ScrubSecretValues wrap the new  
    client predicates with safe fallbacks.  
- Tell the user when the chat lockdown blocks a send and keep their text  
    Every refusal site now raises a throttled notice instead of failing  
    silently. The command splitter no longer clears the edit box when the  
    send was refused, the split sender re-checks the lockdown inside its  
    timer paced closure so chunks stop cleanly mid run, and the handoff to  
    the native edit box is refused during the lockdown instead of eating  
    the typed line.  
- Wake the replay drain from ADDON\_RESTRICTION\_STATE\_CHANGED  
    The event fires after the chat restriction deactivates, so deferred  
    messages replay the moment a lockdown ends instead of on the next poll.  
    The 1 Hz ticker stays as a fallback but only exists on clients that  
    have secret values at all.  
- Harden the deferred chat queue and its replay drain  
    Rehydration now goes through pcall and drops a line whose text or sender  
    cannot be recovered instead of replaying blank strings, counting each  
    drop and telling the user once when the drain finishes. Channel events  
    whose channel name was secret are dropped since they cannot be routed.  
    The queue dedupes by line id so a message re-injected by another addon  
    does not replay twice, caps at 500 entries, and replayed events keep the  
    original argument shape with nils preserved. The write-only  
    ChatLineHasSecrets table is gone.  
- Let the default UI build its own reply headers  
    When WIM does not intercept a reply there is no need to assemble the  
    header by hand. Writing attributes on the native edit box from addon  
    code is another taint path, and the default UI already does this itself.  
- Insert links through a secure post-hook and drop the tainting chat overrides  
    Replacing ChatFrameUtil.GetActiveWindow and SetLastTellTarget taints the  
    chat edit box slots permanently. The InsertLink post-hook only feeds a WIM  
    edit box when no native box claimed the link, skips secret text, and the  
    tab advance no longer writes Blizzard's last tell target.  
- Merge branch 'master' of upstream into modernization  
    Upstream's SetWidgetFont fix resolves the font from the skin for  
    both calls; this branch already carries the same change from the  
    skin engine port, so the merge keeps the existing lines.  
- Localization for the new strings  
    Every locale covers the new say toggle, chat color, and filter  
    editor strings. The translations are Google Translate placeholders,  
    marked as such in the files, pending review by native speakers.  
    Copied over from the machine-local testing branch.  
- The filter editor wears the Modern skin  
    The dialog takes the chat window frame with its title band, modern  
    dropdowns and checkboxes, the search-band name field, an inset  
    pattern well with the slim scrollbar, and its own background and  
    cut-out settings; it re-dresses live on skin swaps. Copied over  
    from the machine-local testing branch after in-game testing on  
    retail and classic era.  
- Modern options: chat colors, filter editor settings, dialog fixes  
    Adds the Chat Colors toggles that color the message being typed by  
    its chat type, the filter editor's background settings, a gate on  
    the In-line whisper button once the setting is already set, and a  
    bug-report url box that fits the classic dialog. Copied over from  
    the machine-local testing branch after in-game testing on retail  
    and classic era.  
- Message splitting fixes and a say output toggle  
    Chat-type slash commands split like plain sends, chunks fill to the  
    length cap exactly, long bursts pace past the server throttle, and  
    the say window gains a shortcut-bar toggle for say, yell, or emote  
    that also consumes typed prefixes. Copied over from the machine-local  
    testing branch after in-game testing on retail and classic era.  
- Menu styling and Modern skin paint fixes  
    Modern menus style every level through the menu-acquired callback  
    and take retail's bottom inset; the minimap menu draws one plate  
    across both sections; cut-out strips and the classic era portraits  
    paint correctly on first show. Copied over from the machine-local  
    testing branch after in-game testing on retail and classic era.  
- Use the game api when the dropdown library is not packaged  
    On classic flavors the compat shim now registers a stub whose  
    lookups fall back to the WoW globals when LibDropDownMenu is not  
    packaged, so a plain source checkout still gets working dropdowns.  
    Copied over from the machine-local testing branch after in-game  
    testing on retail and classic era.  
    Co-authored-by: anon1231823 <anon1231823@users.noreply.github.com>  
- Restore the search bar anchors in a safe order  
    In the native search style the clear button anchors to the box,  
    while the box's saved anchor targets the clear button. Restoring the  
    box first therefore created an anchor cycle and a SetPoint error  
    when switching back to a classic skin. The clear button's anchors  
    now restore first.  
- Style submenus as they spawn  
    Submenus open as sibling frames after the client's hover-intent  
    delay, so the open-time walk never saw them. Each row hover now  
    schedules staggered re-walks of the menus' shared parent, catching a  
    submenu at any depth when it appears; the walk is idempotent so the  
    repeats cost nothing. The portrait paints also write debug-log  
    traces, to pin a transient sizing issue.  
- Use the retail menu and dropdown art on classic flavors  
    Classic clients paint classic-styled variants of the menu atlas  
    members, so the character selector, filter dropdown, and context  
    menus looked out of place next to the Modern skin. A per-texture  
    rename hook remaps them to the retail members, normalizing every  
    observed state name convention. The pieces whose classic pixels  
    differ from retail's (the dropdown holder, all six arrow states, and  
    the menu plate) paint from shipped copies of the retail art, at the  
    retail size and anchor. Menus get a measured bottom margin, and  
    /wim snapmenu can capture dropdown menus.  
- Fix a client crash restoring the search box font  
    A box whose font was set by file path reports its own anonymous font object, and restoring through that object creates an inheritance cycle the client resolves by infinite recursion. The saved state now records the font file properties and restores through SetFont.  
- Ship the 2x corner-button art for classic flavors  
    Classic flavors resolve the RedButton names to the 1x sheet, so the  
    corner buttons upscaled blurry; clients without the portrait panel  
    art now paint shipped copies of the retail 2x pieces. The classic  
    pass resets the state textures' coordinates, since setting a texture  
    file does not clear the shipped art's coordinate window.  
- Cut-out strips show pictures as one continuous image  
    Non-tiling backgrounds painted the whole image into each cut-out strip, squashed four times. Each strip now windows to the part of the image under it. This affected retail and classic alike.  
- Slim scrollbars and button gating in the options lists on classic flavors  
    Options lists hide whatever scrollbar the scroll template attached  
    and drive a slim slider built from the minimal scrollbar art, on any  
    client without the portrait panel art. The Classic Options button's  
    modern-only lock is also enforced as the row initializes, since some  
    clients ignore the modify predicate on button rows.  
- Snapshots: client capability probes and delayed capture  
    Dumps record a client block (atlas, file, layout, and API probes),  
    skin state, and per-window paint state, so flavor issues can be  
    isolated from data instead of screenshots. Probes run isolated and  
    record their errors, and GetAtlasInfo is called outside the addon  
    environment so it resolves its mixins. /wim snap delay <seconds>  
    arms a capture that fires on its own, for states that appear while  
    the hands are busy reproducing them.  
- Build the Modern frame from shipped retail art on classic era  
    Classic era lacks the portrait nine-slice layouts, so the frame is  
    built from the addon's copies of the retail metal pieces, drawn at  
    the geometry retail uses. Message windows use the portrait corner  
    and the History Viewer the plain one. The portrait paint stays era  
    specific: era samples masks through the masked texture's own  
    coordinates, so the class icon repaints from the per-class icon file  
    at full coordinates. Switching back to a classic skin restores the  
    icon's texture, coordinates, and size, with the chrome hidden before  
    the teardown so the repaint cannot route through the themed path.  
- Keep the bug-report URL box inside narrow dialogs  
    The edit box is clamped to the dialog width on show.  
- Fail with a message when the packaged libraries are missing  
    A source checkout without the Libs folder now prints one chat line and stops loading instead of erroring on every event.  
- Offer only background art that exists on this client  
    Background pickers skip entries whose files are missing on this client. A saved key whose art is gone falls back to Rock, then to the clear fill.  
- Size dialog text rows to their text; guard the alert icon  
    Bug report and credits rows measure their wrapped text instead of using fixed heights, so long locales are not clipped. Clients without the retail alert icon keep the standard dialog icon.  
- Localize the slash command feedback  
    The community focus and channel repair confirmations, the /wim style  
    usage line, and the queued-options notice were hardcoded English, so  
    translators could never reach them. They now go through the locale  
    table, with draft translations for all ten locales in each file's  
    existing style; corrections from native speakers are welcome.  
    The debug-level feedback and the /wim snap help stay English on  
    purpose: their output feeds bug reports and DEBUGGING.md, which are  
    English.  
    Also fixed while in the files: the frFR string for a blocked message  
    said "Afficher une alerte", and the esES strata list showed the  
    English word Tooltip.  
- Key class colors by the client's localized class names  
    The class table was keyed by addon translations, so any locale without  
    them lost class colors in windows and user lists. The keys now come  
    from LOCALIZED\_CLASS\_NAMES\_MALE and FEMALE, which hold the same strings  
    the friends, guild, who, and Battle.net APIs return, so every locale  
    resolves with no translation work. Hand-translated keys are kept as  
    extra entries so older saved data still matches.  
    Fixed along the way: Evoker joins the class list and the filter menu,  
    female entries carry the talent table, and untranslated locales no  
    longer create junk WarriorF-style keys.  
- Fixes from classic testing  
    Three fixes reported against the PR branch on classic clients. The  
    bug-report popup now finds the edit box under its new capitalized key  
    on GameDialog clients, with the old key as a fallback. The classic  
    dropdown polyfill had a trailing space in its template name, so list  
    frames failed to create on older clients; the space is upstream's, but  
    it is removed here. The options-style chat messages now go through the  
    locale table instead of hardcoded English.  
    Co-authored-by: Mojo-OG <57604549+Mojo-OG@users.noreply.github.com>  
- Localization: cover every locale for the new strings  
    Full translation pass over the strings this branch adds: the modern  
    options panel, the Modern skin settings, roleplay profiles, the History  
    Viewer filters, and the diagnostics text. enUS lists the new keys and  
    the other ten locales carry translations in each file's existing style.  
    Co-authored-by: Mojo-OG <57604549+Mojo-OG@users.noreply.github.com>  
- Localization  
- Docs, credits, and a cleanup pass  
    DEBUGGING.md covers the snapshot tool next to the debug log and which  
    fits which kind of problem; the bug-report template walks through  
    both. The build stamp uses the packager keyword, so releases carry it  
    without extra tooling. Removes a development-only input probe, some  
    leftover troubleshooting comments, and a dead caret workaround. The  
    skin settings page is titled Modern Skin to match the engine's terms.  
    Credits Avraelore (Moon Guard) for the modern skin and options work.  
- Options: use the native color and preview constructions  
    Color swatches are rebuilt the way the Accessibility colors page  
    builds them: a grouped panel of ColorOverrideTemplate rows with  
    ColorSwatchTemplate swatches. Preview areas sit on the  
    options\_frame\_child plate the nameplate preview uses. Also fixes  
    pooled rows occasionally blanking a panel: a stale holder pointer  
    could hide one still on screen.  
- Fix the invisible caret and dead scrolling in wrap mode  
    This took several rounds; the churn theories all failed first. The  
    cause: extra vertical text insets make a multi-line box recalculate  
    its layout every frame. OnCursorChanged then fires continuously, and  
    the cursor-follow undoes every wheel scroll one frame later. Keep the  
    box at zero vertical insets, carry the spacing in the viewport  
    margins, and follow only real cursor moves. Switching live back to a  
    classic skin also restores cleanly now: input box draw order, header  
    geometry, the menu backdrop, and the roleplay identity comes off  
    classic frames.  
- Merge remote-tracking branch 'upstream/master' into modernization  
- Input row: character counter and an optional wrap mode  
    The counter shows the message length against the send caps (255, 800  
    for Battle.net) and how many messages the splitter will really send.  
    The splitter now also breaks words longer than the limit instead of  
    sending them oversized. Wrap mode turns the box multi-line inside a  
    scrolling viewport and grows the row downward; the window takes on  
    the extra height, so the message area never moves. Getting the growth  
    stable took several passes.  
- Diagnostics: /wim snap dumps live widget state  
    Writes the rectangles, anchors, atlases, texture coordinates, and  
    fonts of everything WIM styles into a per-character SavedVariable,  
    with a screenshot of the same moment. Skin problems can then be  
    compared number by number against the native frames they copy,  
    instead of being judged from screenshots. Every capture records which  
    build produced it; the packager stamps BuildInfo.lua.  
- Roleplay profiles on whisper windows; native HV loader  
    Whisper windows can show the partner's roleplay identity from Total  
    RP 3 or any Mary Sue Protocol addon: names, titles, race, class,  
    color, and portrait. Each field is opted into through a multiselect,  
    and every field falls back to the default when it has no data. A  
    shortcut opens the partner's profile in the installed viewer. Reads  
    go through public APIs on WIM's own timer; hooking the addons'  
    callback registries taints their dispatch (found out the hard way).  
    The History Viewer's loading bar becomes the standard cast bar under  
    the modern skin, and the themed header now fits and wraps instead of  
    overflowing.  
- Add the Modern skin  
    Message windows use the standard metal nine-slice: a gold title band,  
    a recessed message well (cut-out mode leaves the well clear to the  
    world), a circled class portrait, the native search-box border on the  
    input row, and the standard red corner X. Menus use the chamfered  
    context-menu panel, and right-click opens a real player menu. The  
    classic options lock while a modern-only skin is active, because that  
    page cannot offer the skin and could lose the selection.  
- Skin engine: modernOnly skins, tab text, reskin on LoadSkin  
    Skins can declare themselves modernOnly: the classic dropdown never  
    offers them, but still shows an active selection honestly. Tab strips  
    restyle on every LoadSkin, tab\_strip.text stops being dead data, and  
    the saved skin name repairs itself across 3.17.2's title  
    localization.  
- Rebuild the options inside the native Settings panel  
    WIM registers under Options > AddOns with every page redone on native  
    rows. Content without a native control (the formatting preview, the  
    font browser, color swatches, the filter and channel lists) sits in  
    custom element rows the list pools. Both UIs bind the same keys and  
    notify each other, so they stay in step while both are open.  
    db.modernOptions picks which UI the entry points open; the classic  
    window stays available.  
- Port the #80 skin engine changes onto this branch  
    Upstream merged #80 after this branch split off, so it is applied by  
    hand here. Fonts resolve from an object, an SML name, or a path.  
    LoadSkin takes an immutable flag and fires OnSkinLoaded. The menu and  
    the chat user list restyle live. A missing saved skin falls back to  
    the default.  
- Fix the shortcut bar location tooltip (#271)  
    The file-scope buttons table is the type-keyed registry, not a button  
    list. Indexing it with a number returned nil and the SendWho callback  
    errored.  
- History Viewer: filter on conversation size and activity  
    Relative dates now always prune the list. Closing the viewer from one  
    of its own confirmations no longer reopens it.  
- History Viewer: clickable sections, sorting, date filters  
    The Battle.net Friends header and the letter buckets now toggle their  
    sections like user rows do. Names sort case-insensitively. The date  
    menu gets relative filters (today, this week) that also narrow the  
    list. Also stops the Window Behavior label overflowing the options  
    page.  
- Fix refused community sends; fix more 12.1 breakage  
    The client refuses to send to a community channel until its stream has  
    been focused. Finding this took several debug captures. WIM now  
    focuses each stream when its subscription arrives and stops once the  
    client takes over. /wim focusstreams turns the pass off for  
    comparison. /wim channelrepair (off by default) re-adds channels when  
    the focus arrives too late.  
    Also for 12.1: MouseIsOver is gone (the widget method replaces it),  
    channel restore now verifies membership instead of trusting the add  
    call (the ids form registers a junk channel named after the club id),  
    and community windows resurrect under their proper names.  
- Persist a leveled debug log to disk  
    /wim debug 1 records WIM's diagnostics. /wim debug 2 adds a raw trace  
    of every chat event with its arguments. The log needs to survive  
    logout, because that is where the interesting failures happen: lines  
    get millisecond timestamps and land in a bounded per-character  
    SavedVariable. Also carries the archive conversion glue.  
- Move history into a serialized account archive  
    The account-wide history table causes the corruption in #251: when the  
    saved file reloads, Lua's per-chunk constant limit fails on large  
    tables. Store each conversation as one serialized string instead, and  
    decode it in a sandbox when needed. Old data converts on first login.  
    This replaces an earlier attempt that split history into a companion  
    addon. Clearing history also removes the archive and the legacy  
    tables.  
- Guard focus and interception during combat lockdown  
    Focusing the edit box or updating the intercepted chat header touches  
    Blizzard's secure frames, which throws in combat on current clients.  
    Stand down until combat ends.  
