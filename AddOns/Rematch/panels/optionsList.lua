local _,rematch = ...
local L = rematch.localization
local C = rematch.constants

--[[ Option format:

	[1] = type of option: "check" "radio" "header" "widget" or "spacer"

	"check"
	[2] = the settings[var] of the optn ("FastPetCard", "ClickPetCard", etc)
	[3] = the name of the option as displayed ("Faster pet cards", "Click for pet cards", etc)
	[4] = the tooltip text of the option
	[5] = the settings[var] that the option is dependant upon ("AutoLoadTargetOnly" would have "AutoLoad" here)
	[6] = name of optionFunc to run when clicked, or true if it's named after the setting
	[7] = boolean whether this setting's optionFunc should run on login

	"radio"
	[2] = the shared settings[var] of the option
	[3] = the name of the option as displayed ("Minimized Standalone" "Maximized Standalone")
	[4] = the tooltip text of the option
	[5] = the value (number) to assign to the shared settings[var]

	"header"
	[2] = text to display in header
	[3] = header index (number, see below)

	"widget"
	[2] = name of widget (parentKey of childframe to RematchOptionPanel)

	Header indexes: These numbers are "keys" to the header (expanded in settings.ExpandedOptHeaders).
	If changing headers, make sure not to reuse an index. It's ok if they're missing or if
	they're out of order. The index is merely for a permanent expanded handle.
		0 = All Options
		1 = Targeting Options
		2 = Standalone Window Options
		3 = Appearance Options
		4 = Pet Card & Notes Options
		5 = Leveling Queue Options
		6 = Miscellaneous Options
		7 = Preferred Window Mode
		8 = Pet Filters
		9 = Toolbar Options
		10 = Team Options
		11 = Confirmation Options
		12 = Debugging Options
		13 = Team Win Record Options
		14 = List Behavior Options
		15 = Help Options
		16 = Ability Tooltip Options
		17 = Notes Options
		18 = Breed Options
		19 = Leveling Queue Options
		20 = About
		21 = Random Pet Options
		22 = Icon Legend
]]

rematch.optionsList = {
	-- All Options
	--{type="header", group=0, text=L["All Options"]},
	-- Targeting Options
	{type="header", group=1, text=L["Interaction Options"]},
	{type="widget", group=1, text=L["On Target"], parentKey="InteractOnTargetWidget"},
	{type="widget", group=1, text=L["On Mouseover"], parentKey="InteractOnMouseoverWidget"},
	{type="widget", group=1, text=L["On Soft Interact"], parentKey="InteractOnSoftInteractWidget"},
	{type="check", group=1, text=L["Always Interact"], var="InteractAlways", tooltip=L["The default behavior is to perform the target or mouseover interaction once until you interact with another NPC with a saved team. Check this to always interact with NPCs that have a saved team not already loaded."]},
	{type="check", group=1, text=L["Prefer Uninjured Teams"], var="InteractPreferUninjured", tooltip=L["When you interact with an NPC that has more than one team saved to it, choose the team with no injured pets instead of the topmost team for the target. On Prompt To Load and Show Window options where you can choose which team to load before loading, start with the healthiest team."]},
	{type="check", group=1, text=L["Show Window After Loading"], var="InteractShowAfterLoad", tooltip=L["When a team is loaded from an interaction (target or mouseover) and the Rematch window is not on screen, summon the standalone Rematch window."]},
	{type="check", group=1, text=L["Only When Any Pets Injured"], var="InteractOnlyWhenInjured", dependency="InteractShowAfterLoad", tooltip=L["If a team is loaded but no pets are injured, don't summon the Rematch window."]},

	-- Standalone Window Options
	{type="header", group=2, text=L["Standalone Window Options"]},
	{type="widget", group=2, text=L["Anchor To"], parentKey="AnchorWidget"},
	{type="widget", group=2, text=L["Tab Anchor"], parentKey="PanelTabAnchorWidget"},
	{type="check", group=2, text=L["Prefer Minimized Window"], var="PreferMinimized", tooltip=L["When the window is automatically summoned such as from an Interact Option or Safari Hat Reminder, summon the window in minimized mode."]},
	{type="widget", group=2, text=L["Use Custom Scale"], parentKey="UseCustomScaleWidget"},
	{type="check", group=2, text=L["Keep Window On Screen"], var="LockWindow", tooltip=L["Don't hide the standalone window when the ESCape key is pressed or most other times it would hide, such as going to the game menu."]},
	{type="check", group=2, text=L["Even For Pet Battles"], var="StayForBattle", dependency="LockWindow", tooltip=L["Keep the standalone window on the screen even when you enter pet battles."]},
	{type="check", group=2, text=L["Even Across Sessions"], var="StayOnLogout", dependency="LockWindow", tooltip=L["If the standalone window was on screen when logging out, automatically summon it on next login."]},
	{type="check", group=2, text=L["Don't Minimize With ESC Key"], var="LockDrawer", tooltip=L["Don't minimize the standalone window when the ESCape key (or game menu key) is pressed."]},
	{type="check", group=2, text=L["Don't Minimize With Panel Tabs"], var="DontMinTabToggle", tooltip=L["Don't let the Pets, Teams, Queue or Options tabs minimize the standalone window."]},
	{type="check", group=2, text=L["Lower Window Behind UI"], var="LowerStrata", func="LowerStrata", tooltip=L["Push the standalone window back behind other parts of the UI so other parts of the UI can appear ontop."]},
	{type="check", group=2, text=L["Show Pets Tab While Minimized"], var="PreferPetsTab", tooltip=L["When the window has a Pets tab and is minimized, drop the Targets tab and keep the Pets tab visible."] },
	{type="check", group=2, text=L["Show Window After Battle"], var="ShowAfterBattle", tooltip=L["Show the standalone Rematch window after leaving a pet battle."]},
	{type="check", group=2, text=L["But Not After PVP Battle"], var="ShowAfterPVEOnly", dependency="ShowAfterBattle", tooltip=L["Since pets don't remain injured in PVP battles, don't show the window when leaving a PVP battle."]},

	-- Appearance Options
	{type="header", group=3, text=L["Appearance Options"]},
	{type="check", group=3, text=L["Compact Pet List"], var="CompactPetList", func="CompactPetList", tooltip=L["Display more pets in the pet list by using a more compact view of each pet."]},
    {type="check", group=3, text=L["Compact Team List"], var="CompactTeamList", func="CompactTeamList", tooltip=L["Display more teams in the team list by using a more compact view of each team."]},
	{type="check", group=3, text=L["Compact Target List"], var="CompactTargetList", func="CompactTargetList", tooltip=L["Display more targets in the target list by using a more compact view of each target."]},
	{type="check", group=3, text=L["Compact Queue List"], var="CompactQueueList", func="CompactQueueList", tooltip=L["Display more pets in the queue by using a more compact view of each pet."]},
	{type="check", group=3, text=L["Hide Level At Max Level"], var="HideLevelBubbles", update=true, tooltip=L["If a pet is level 25, don't show its level on the pet icon."]},
	{type="check", group=3, text=L["Hide Rarity Borders"], var="HideRarityBorders", update=true, tooltip=L["Don't color the icon border for pets you own in the same color as its rarity."]},
	{type="check", group=3, text=L["Show Ability Numbers"], var="ShowAbilityNumbers", update=true, tooltip=L["In the ability flyout, show the numbers 1 and 2 to help with the common notation such as \"Pet Name 122\" to know which abilities to use."]},
	{type="check", group=3, text=L["On Loaded Abilities Too"], var="ShowAbilityNumbersLoaded", dependency="ShowAbilityNumbers", update=true, tooltip=L["In addition to the flyouts, show the numbers 1 and 2 on loaded abilities."]},
	{type="check", group=3, text=L["Color Pet Names By Rarity"], var="ColorPetNames", update=true, tooltip=L["Make the names of pets you own the same color as its rarity. Blue for rare, green for uncommon, etc."]},
	{type="check", group=3, text=L["Color Team Names By Group"], var="ColorTeamNames", update=true, tooltip=L["Make team names colored the same as the colors you've chosen for the groups they belong to."]},
	{type="check", group=3, text=L["Color Targets By Expansion"], var="ColorTargetNames", update=true, tooltip=L["Make notable target names colored after the expansion the target is from."]},

	-- Behavior Options
	{type="header", group=14, text=L["Behavior Options"]},
	--{type="widget", group=14, parentKey="MousewheelSpeedWidget"}, -- Mousewheel Scroll Speed:
	{type="widget", group=14, text=L["Card Speed"], parentKey="CardBehaviorWidget", tooltip=L["Choose how quickly you prefer the pet card and notes to be shown when you mouseover a pet or notes button."]}, -- Card Behavior:
	{type="widget", group=14, text=L["Tooltip Speed"], parentKey="TooltipBehaviorWidget"}, -- Tooltip Behavior
	{type="check", group=14, text=L["Collapse Lists With ESC Key"], var="CollapseOnEsc", tooltip=L["When the ESCape key (or game menu key) is pressed, collapse any expanded list--such as this options list, teams or targets."]},

	-- Toolbar Options
	{type="header", group=9, text=L["Toolbar Options"]},
	{type="check", group=9, text=L["Reverse Toolbar Buttons"], var="ReverseToolbar", func="ConfigureToolbar", tooltip=L["Reverse the order of the toolbar buttons (Revive Battle Pets, Battle Pet Bandages, Safari Hat, etc)."]},
	{type="check", group=9, text=L["Hide On Toolbar Right Click"], var="ToolbarDismiss", tooltip=L["When a toolbar button is used with a right click, dismiss the Rematch window after performing its action."]},
	{type="check", group=9, text=L["Safari Hat Reminder"], var="SafariHatShine", update=true, tooltip=L["When a pet is laoded below max level, draw attention to the Safari Hat button, including summoning the window if it's not on screen."]},
	{type="check", group=9, text=L["Display Unique Pets Total"], var="DisplayUniqueTotal", update=true, tooltip=L["Instead of Total Pets in the collections button at the topleft, display a total of Unique Pets."]},
	{type="check", group=9, text=L["Always Use Pet Satchel"], var="AlwaysUsePetSatchel", func="ConfigureToolbar", tooltip=L["Rather than displaying all toolbar buttons in larger views of the addon, always use the Pet Satchel button to cycle through infrequently used toolbar buttons."]},

	-- Pet Filter Options
	{type="header", group=8, text=L["Pet Filter Options"]},
	{type="check", group=8, text=L["Use Level In Strong Vs Filter"], var="StrongVsLevel", func="UpdateFilters", tooltip=L["When doing a Strong Vs filter, take the level of the pet into account. If a pet is not high enough level to use a Strong Vs ability, do not list the pet.\n\n\124cffffffffNote:\124r A Strong Vs filter is sometimes useful for identifying pets you want to level or capture. This option will hide those pets while the Strong Vs filter is active."]},
	{type="check", group=8, text=L["Reset Filters On Login"], var="ResetFilters", tooltip=L["When logging in, start with all pets listed and no filters active."]},
	{type="check", group=8, text=L["Reset Sort With Filters"], var="ResetSortWithFilters", update=true, tooltip=L["When clearing filters, also reset the sort back to the default: Sort by Name, Favorites First."]},
	{type="check", group=8, text=L["Don't Reset Search With Filters"], var="ResetExceptSearch", update=true, tooltip=L["When manually clearing filters, don't clear the search box too.\n\nSome actions, such as logging in or Find Similar, will always clear search regardless of this setting."]},
	{type="check", group=8, text=L["Sort By Chosen Name"], var="SortByNickname", func="UpdateFilters", tooltip=L["When pets are sorted by name, sort them by the name given with the Rename option instead of their original name."]},
	{type="check", group=8, text=L["Sort New Pets To Top"], var="StickyNewPets", func="UpdateFilters", tooltip=L["When you learn new pets, temporarily sort them to the top of the pet list until you next close Rematch or choose Reset All from the filter menu."]},
	{type="check", group=8, text=L["Hide Non-Battle Pets"], var="HideNonBattlePets", func="UpdateFilters", tooltip=L["Only list pets that can battle. Do not list pets like balloons, squires and other companion pets that cannot battle."]},
	{type="check", group=8, text=L["Allow Hidden Pets"], var="AllowHiddenPets", func="UpdateHiddenPetFilter", tooltip=L["Allow the ability to hide specific pet species in the pet list with a 'Hide Pet' in the list's right-click menu.\n\nYou can view pets you've hidden from the Other -> Hidden Pets filter."]},
	{type="check", group=8, text=L["Export Simple Pet List"], var="ExportSimplePetList", func="ExportSimplePetList", tooltip=L["When exporting pets from the Export Pets filter menu item, only export a list of pets without details."]},
	{type="check", group=8, text=L["Don't Sort By Relevance"], var="DontSortByRelevance", func="UpdateFilters", tooltip=L["When searching for pets by name, don't sort the results by relevance.\n\nWhen sorted by relevance, pets with the search term in their name are listed first, followed by term in notes, then abilities."]},

	-- Breed Options
	{type="header", group=18, text=L["Breed Options"]},
	{type="widget", group=18, text=L["Breed Source"], parentKey="BreedSourceWidget"}, -- Breed Source:
	{type="widget", group=18, text=L["Breed Format"], parentKey="BreedFormatWidget"}, -- Breed Format:
	{type="check", group=18, text=L["Hide Breed In Lists"], var="HideBreedsLists", update=true, tooltip=L["Hide the breeds displayed in lists. Breeds will still be visible in pet cards."]},
	{type="check", group=18, text=L["Hide Breed In Pet Slots"], var="HideBreedsLoadouts", update=true, tooltip=L["Hide the breeds displayed on pet slots. Breeds will still be visible in pet cards."]},

	-- Pet Card Options
	{type="header", group=4, text=L["Pet Card Options"]},
	{type="widget", group=4, text=L["Card Background"], parentKey="CardBackWidget"}, -- Card Background:
	{type="widget", group=4, text=L["Flip Modifier Key"], parentKey="FlipKeyWidget"}, -- Flip Modifier Key:
	{type="check", group=4, text=L["Don't Flip On Mouseover"], var="PetCardNoMouseoverFlip", tooltip=L["When you mouseover the pet icon or type icon at the top of the pet card, don't flip to the back of the card. Instead, flip the card only by clicking the pet or type icon at the top of the pet card; or by the flip modifier key if defined."]},
	{type="check", group=4, text=L["Allow Pet Cards To Be Pinned"], var="PetCardCanPin", func="UpdatePetCardPin", tooltip=L["When dragging a pet card to another part of the screen, pin the card so all future pet cards display in the same spot, until the pet card is moved again or the unpin button is clicked."]},
	{type="check", group=4, text=L["Always Show Health Bar"], var="PetCardAlwaysShowHPBar", func="UpdatePetCard", tooltip=L["On the pet card, always display the health bar if a pet can battle and has health. While unchecked, the health bar is only displayed for injured pets."]},
	{type="check", group=4, text=L["Always Show HP/XP Bar Text"], var="PetCardAlwaysShowHPXPText", func="UpdatePetCard", tooltip=L["On the pet card health and experience bars, keep the status text always visible instead of requiring a mouseover to view."]},
	{type="check", group=4, text=L["Always Hide Possible Breeds"], var="PetCardHidePossibleBreeds", func="UpdatePetCard", tooltip=L["When the pet card is not minimized, rather than list possible breeds across the bottom of the pet card, always put the list of possible breeds in the tooltip of the pet's breed stat button.\n\nNote: For uncollected pets that don't have a breed, this means possible breeds will not be visible."]},
	{type="check", group=4, text=L["Always Use Collected Stat"], var="PetCardCompactCollected", func="UpdatePetCard", tooltip=L["When the pet card is not minimized, rather than list collected versions of a pet across the bottom of the pet card, use a collected button alongside other stats to display collected totals. Mouseover of the button will display the list of collected versions of the pet."]},
	{type="check", group=4, text=L["Show Expansion On Front"], var="PetCardShowExpansionStat", func="UpdatePetCard", tooltip=L["Instead of displaying the expansion the pet is from on the back of the pet card, display it on the front alongside other stats."]},
	--{type="check", group=4, text=L["Show Strongest Vs Stat"], var="ShowStrongestVsStat", func="UpdatePetCard", tooltip=L["On the pet card display the top three pet types the pet is strongest against, based on its abilities."]},
	{type="check", group=4, text=L["Show Species IDs Stat"], var="ShowSpeciesID", func="UpdatePetCard", tooltip=L["Display the numerical speciesID as a stat on pet cards."]},
	{type="check", group=4, text=L["Alternate Lore Font"], var="BoringLoreFont", func="UpdatePetCard", tooltip=L["Use a more modern-looking font for lore text on the back of the pet card."]},
	{type="check", group=4, text=L["Use Pet Cards In Battle"], var="PetCardInBattle", tooltip=L["Use the pet card on the unit frames during a pet battle instead of the default tooltip."]},
	{type="check", group=4, text=L["Use Pet Cards For Links"], var="PetCardForLinks", tooltip=L["Use the pet card when viewing a link of a pet someone else sent you instead of the default link."]},

	-- Notes Options
	{type="header", group=17, text=L["Notes Options"]},
	{type="check", group=17, text=L["Keep Notes On Screen"], var="KeepNotesOnScreen", tooltip=L["Don't hide notes when changing tabs or closing Rematch."]},
	{type="check", group=17, text=L["Even When Escape Pressed"], var="NotesNoEsc", dependency="KeepNotesOnScreen", tooltip=L["Also don't hide notes when ESCape key is pressed."]},
	{type="check", group=17, text=L["Show Notes When Teams Load"], var="ShowNotesOnLoad", tooltip=L["When a team with notes is loaded, display the notes for the team."]},
	{type="check", group=17, text=L["Show Notes In Battle"], var="ShowNotesInBattle", tooltip=L["If the loaded team has notes, display and lock the notes when you enter a pet battle."]},
	{type="check", group=17, text=L["Only Once Per Team"], var="ShowNotesOnce", dependency="ShowNotesInBattle", tooltip=L["Only display notes automatically the first time entering battle, until another team is loaded."]},
	{type="widget", group=17, text=L["Notes Size"], parentKey="NotesFontWidget"}, -- Notes Size:

	-- Ability Tooltip Options
	{type="header", group=16, text=L["Ability Tooltip Options"]},
	{type="widget", group=16, text=L["Ability Background"], parentKey="AbilityBackWidget"},
	{type="check", group=16, text=L["Show Ability IDs"], var="ShowAbilityID", tooltip=L["Show the ability ID for the ability being viewed in the ability tooltip."]},

	-- Team Options
	{type="header", group=10, text=L["Team Options"]},
	{type="check", group=10, text=L["Load Healthiest Pets"], var="LoadHealthiest", tooltip=L["When a team loads, if any pet is injured or dead and there's another version with more health \124cffffffffand identical stats\124r, load the healthier version.\n\nPets in the leveling queue are exempt from this option.\n\n\124cffffffffNote:\124r This is only when a team loads. It will not automatically swap in healthier pets when you leave battle."] },
	{type="check", group=10, text=L["Allow Any Version"], var="LoadHealthiestAny", dependency="LoadHealthiest", tooltip=L["Instead of choosing only the healthiest pet with identical stats, choose the healthiest version of the pet regardless of stats."], "LoadHealthiest" },
	{type="check", group=10, text=L["After Battles Or Heals Too"], var="LoadHealthiestAfterBattle", dependency="LoadHealthiest", tooltip=L["Also load healthiest pets after leaving a pet battle or using Revive Battle Pets or Battle Pet Bandage."], "LoadHealthiest"},
	{type="check", group=10, text=L["Show Create New Group Tab"], var="ShowNewGroupTab", func="ShowNewGroupTab", tooltip=L["When space permits, add a button at the bottom of team tabs to create a new group."]},
	{type="check", group=10, text=L["Always Show Team Tabs"], var="AlwaysTeamTabs", func="AlwaysTeamTabs", tooltip=L["Show team tabs along the right side of the window even if you're not on the teams panel."]},
	{type="check", group=10, text=L["Never Show Team Tabs"], var="NeverTeamTabs", func="NeverTeamTabs", tooltip=L["Never show team tabs along the right side of the window even if you're on the teams panel."]},
	{type="check", group=10, text=L["Display Where Teams Dragged"], var="EchoTeamDrag", tooltip=L["When a team is dragged to another group, print in the chat window where the team was moved to."]},
	{type="check", group=10, text=L["Enable Dragging To Move Teams"], var="EnableDrag", tooltip=L["Allow moving teams or groups by dragging them. When this is unchecked you can still move a team or group from its right-click menu."]},
	{type="check", group=10, text=L["Require Click To Drag Teams"], var="ClickToDrag", dependency="EnableDrag", tooltip=L["When dragging teams or groups to move them, release of the mouse button at the end of the drag will not move the team or group. A separate click is needed."]},
	{type="check", group=10, text=L["Prioritize Breed On Import"], var="PrioritizeBreedOnImport", tooltip=L["When importing or receiving teams, fill the team with the best matched breed as the first priority instead of the highest level."]},
	{type="check", group=10, text=L["Remember Import Override"], var="ImportRememberOverride", tooltip=L["Rather than resetting to 'Create a new copy' everytime a team is imported and another team shares the same name, remember the last-chosen option without resetting."]},

	-- Random Pet Options
	{type="header", group=21, text=L["Random Pet Options"]},
	{type="widget", group=21, text=L["Random Pet Rules"], parentKey="RandomPetRulesWidget"},
	{type="check", group=21, text=L["Pick Aggressive Counters"], var="PickAggressiveCounters", tooltip=L["When using a Load Random Pets button for random pets to counter a target, prefer pets with more Strong attacks over pets that are Tough vs opponent attacks."]},
	{type="check", group=21, text=L["Random Abilities Too"], var="RandomAbilitiesToo", tooltip=L["For random pets, choose random abilities too."] },
	{type="check", group=21, text=L["Warn For Pets Below Max Level"], var="WarnWhenRandomNot25", tooltip=L["Show a warning dialog when a random pet is chosen below level 25. (This is recommended if you're doing Family Familiar achievements with random pets.)\n\nWhen possible, random pets will be from a pool of your max-level pets. However, depending on your collected pets and the other random pet options you've chosen, the random pool may include pets not at max level."]},

    -- Team Win Record Options
    {type="header", group=13, text=L["Team Win Record Options"]},
    {type="check", group=13, text=L["Hide Win Record Text"], var="HideWinRecord", update=true, tooltip=L["Hide the win record displayed to the right of each team.\n\nYou can still manually edit a team's win record from its right-click menu and automatic tracking (if enabled) will continue if win records are hidden."]},
	{type="check", group=13, text=L["Auto Track Win Record"], var="AutoWinRecord", func="AutoWinRecord", tooltip=L["At the end of each battle, automatically record whether the loaded team won or lost.\n\nForfeits always count as a loss.\n\nYou can still manually update a team's win record at any time from its right-click menu."]},
    {type="check", group=13, text=L["For PVP Battles Only"], var="AutoWinRecordPVPOnly", dependency="AutoWinRecord", tooltip=L["Automatically track whether the loaded team won or lost only in a PVP battle and never for a PVE battle."]},
    {type="check", group=13, text=L["Display Win-Loss Instead"], var="AlternateWinRecord", func="AlternateWinRecord", tooltip=L["Instead of displaying the win percentage of a team to the right of the team list, display the total number of wins and losses in the format win-loss.\n\nTeam tabs that are sorted by win record will sort by total wins also."]},

	-- Leveling Queue Options
	{type="header", group=19, text=L["Leveling Queue Options"]},
	{type="check", group=19, text=L["Show Extra Preferences Button"], var="ShowLoadedTeamPreferences", update=true, tooltip=L["When a leveling slot is loaded, show a preferences button above the loadout panel where pets are slotted, in addition to the one always shown at the top of the queue panel."]},
	{type="check", group=19, text=L["Sort Queue By Pet Name Too"], var="QueueSortByNameToo", tooltip=L["When the queue is sorted, sort pets by name also. Otherwise, pets will try to stay in the order they were added to the queue or moved."]},
	{type="check", group=19, text=L["Hide Leveling Pet Toast"], var="HidePetToast", tooltip=L["Don't display the popup 'toast' when a new pet is automatically loaded from the leveling queue."]},
	{type="check", group=19, text=L["Add Fill Queue More Option"], var="ShowFillQueueMore", tooltip=L["In addition to a 'More' button added to the Fill Queue dialog, add a Fill Queue More option to the Queue menu."]},
	{type="check", group=19, text=L["Prefer Living Pets"], var="QueueSkipDead", func="ProcessQueue", tooltip=L["When loading pets from the queue, skip dead pets and load living ones first."]},
	{type="check", group=19, text=L["And At Full Health"], var="QueuePreferFullHP", func="ProcessQueue", dependency="QueueSkipDead", tooltip=L["Also prefer uninjured pets when loading pets from the queue."]},
	{type="check", group=19, text=L["Double Click To Send To Top"], var="QueueDoubleClick", tooltip=L["When a pet in the queue panel is double clicked, send it to the top of the queue instead of summoning it."]},
	{type="check", group=19, text=L["Add Imported Pets To Queue"], var="QueueAutoImport", tooltip=L["When importing a team, automatically add any chosen pets to the leveling queue if they're below level 25."]},
	{type="check", group=19, text=L["Automatically Level New Pets"], var="QueueAutoLearn", tooltip=L["When you capture or learn a pet that can level, automatically add it to the leveling queue."]},
	{type="check", group=19, text=L["Only Pets Without One At 25"], var="QueueAutoLearnOnly", dependency="QueueAutoLearn", tooltip=L["Only automatically add pets to the queue when you don't have a version already at 25 or in the queue."]},
	{type="check", group=19, text=L["Only Rare Pets"], var="QueueAutoLearnRare", dependency="QueueAutoLearn", tooltip=L["Only automatically add rare pets to the leveling queue."]},
	{type="check", group=19, text=L["Random Pet When Queue Empty"], var="QueueRandomWhenEmpty", tooltip=L["When the queue is empty and a team loads with leveling slots, load a random high-level pet in the leveling slots."]},

	-- Confirmation Options
	{type="header", group=11, text=L["Confirmation Options"]},
	{type="check", group=11, text=L["Don't Ask When Hiding Pets"], var="DontConfirmHidePets", tooltip=L["Don't ask for confirmation when hiding a pet.\n\nYou can view hidden pets in the 'Other' pet filter."]},
	{type="check", group=11, text=L["Don't Ask When Caging Pets"], var="DontConfirmCaging", tooltip=L["If the pet doesn't belong to any teams, don't ask for confirmation when putting a pet in a cage."]},
	{type="check", group=11, text=L["Don't Ask When Deleting Teams"], var="DontConfirmDeleteTeams", tooltip=L["Don't ask for confirmation when deleting a team."]},
	{type="check", group=11, text=L["Don't Ask When Deleting Notes"], var="DontConfirmDeleteNotes", tooltip=L["Don't ask for confirmation when deleting notes from a pet or team."]},
	{type="check", group=11, text=L["Don't Ask When Filling Queue"], var="DontConfirmFillQueue", tooltip=L["Don't ask for confirmation when filling the queue from the Queue menu."]},
	{type="check", group=11, text=L["Don't Ask To Stop Active Sort"], var="DontConfirmActiveSort", tooltip=L["Don't ask to stop the Active Sort in the queue when moving a pet within the queue while it's enabled. Always turn off active sort."]},
	{type="check", group=11, text=L["Don't Ask For Queue Removal"], var="DontConfirmRemoveQueue", tooltip=L["Don't ask for confirmation when removing a pet from the leveling queue."]},
	{type="check", group=11, text=L["Don't Warn About Missing Pets"], var="DontWarnMissing", tooltip=L["Don't display a popup when a team loads and a pet within the team can't be found."]},
	{type="check", group=11, text=L["Don't Remind About Backups"], var="NoBackupReminder", tooltip=L["Don't show a popup offering to backup teams every once in a while. Generally, the popup appears sometime after the number of teams increases by 50."]},

	-- Miscellaneous Options
	{type="header", group=6, text=L["Miscellaneous Options"]},
	{type="check", group=6, text=L["Use Default Journal"], var="UseDefaultJournal", func="UseDefaultJournal", tooltip=L["Turn off Rematch integration with the default pet journal.\n\nYou can still use Rematch in its standalone window, accessed via key binding, /rematch command or from the Minimap button if enabled in options."]},
	{type="check", group=6, text=L["Keep Companion"], var="KeepCompanion", tooltip=L["After a team is loaded, summon back the companion that was at your side before the load; or dismiss the pet if you had none summoned."]},
	{type="check", group=6, text=L["Use Minimap Button"], var="UseMinimapButton", func="UseMinimapButton", tooltip=L["Place a button on the minimap to toggle Rematch and load favorite teams."]},
	{type="check", group=6, text=L["No Summon On Double Click"], var="NoSummonOnDblClick", tooltip=L["Do nothing when pets within Rematch are double-clicked. The normal behavior of double click throughout Rematch is to summon or dismiss the pet."]},
	{type="check", group=6, text=L["Disable Sharing"], var="DisableShare", tooltip=L["Disable the Send button and also block any incoming pets sent by others. Import and Export still work."]},

	-- Help Options
	{type="header", group=15, text=L["Help Options"]},
	{type="check", group=15, text=L["Hide Extra Help"], var="HideMenuHelp", func="UpdatePetCard", tooltip=L["Hide the informational \"Help\" items found in menus, pet cards, dialogs and elsewhere."]},
	{type="check", group=15, text=L["Hide Descriptive Tooltips"], var="HideTooltips", tooltip=L["Hide tooltips that describe what a button does."]},
	{type="check", group=15, text=L["Hide Toolbar Tooltips"], var="HideToolbarTooltips", tooltip=L["Hide tooltips for the toolbar buttons."]},
	{type="check", group=15, text=L["Hide Option Tooltips"], var="HideOptionTooltips", tooltip=L["Hide tooltips for options like the one you're reading now."]},
	{type="check", group=15, text=L["Hide Truncated Tooltips"], var="HideTruncatedTooltips", tooltip=L["Hide tooltips for team or target names when they're truncated (such as Sully \"The Pickle\" McL... instead of Sully \"The Pickle\" McLeary)."]},

	-- About Rematch
	{type="header", group=20, text=L["About Rematch"]},
	{type="widget", group=20, text=L["All Options Troubleshoot Export Reset"], parentKey="OptionsManagementWidget"},
	{type="text", group=20, text=L["Version "]..(C_AddOns.GetAddOnMetadata("Rematch","Version") or "")},
	-- {type="text", group=20, text=rematch.utils:GetBadgeAsText(12,16,true).."\124cffb0b0b0 "..L["Target or pet is in a team"]},
	-- {type="text", group=20, text=rematch.utils:GetBadgeAsText(11,16,true).."\124cffb0b0b0 "..L["Pet is in the leveling queue"]},
	-- {type="text", group=20, text=rematch.utils:GetBadgeAsText(13,16,true).."\124cffb0b0b0 "..L["Team or pet has notes"]},
	-- {type="text", group=20, text=rematch.utils:GetBadgeAsText(27,16,true).."\124cffb0b0b0 "..L["Team has at least one target"]},
	-- {type="text", group=20, text=rematch.utils:GetBadgeAsText(14,16,true).."\124cffb0b0b0 "..L["Team or group has preferences"]},

}

