---@class RemixGemHelperPrivate
local Private = select(2, ...)
Private.Locales = Private.Locales or {}

Private.Locales["enUS"] = {
    --isEditing = true,

    -- CloakTooltip.lua
    ["Rank"] = "Rank",

    -- Core.lua
    ["Socketed"] = "Socketed",
    ["In Bag"] = "In Bag",
    ["In Bag Item!"] = "In Bag Item!",
    ["Uncollected"] = "Uncollected",
    ["Scrappable Items"] = "Scrappable Items",
    ["NOTHING TO SCRAP"] = "NOTHING TO SCRAP",
    ["Resocket Gems"] = "Resocket Gems",
    ["Toggle the %s UI"] = "Toggle the %s UI", -- %s is the Addon name and needs to be included!
    ["Search Gems"] = "Search Gems",
    ["Unowned"] = "Unowned",
    ["Show Unowned Gems in the List."] = "Show Unowned Gems in the List.",
    ["Primordial"] = "Primordial",
    ["Show Primordial Gems in the List."] = "Show Primordial Gems in the List.",
    ["Open, Use and Combine"] = "Open, Use and Combine",
    ["NOTHING TO USE"] = "NOTHING TO USE",
    ["HelpText"] =
        "|A:newplayertutorial-icon-mouse-leftbutton:16:16|a Click a Gem in this list to Socket or Unsocket.\n" ..
        "'In Bag Item' or 'Socketed' indicates that you unsocket it.\n" ..
        "'In Bag' indicates that the Gem is in your bag and ready to be socketed.\n\n" ..
        "When hovering over a Gem that is 'Socketed' you will see the item highlighted in your character panel.\n" ..
        "You can use the dropdown or the search bar at the top to filter your list.\n" ..
        "This Addon also adds the current Rank and stats of your cloak inside the cloak tooltip.\n" ..
        "You should see an icon in the top right of your character frame which can be used to hide or show this frame.\n" ..
        "Below the Gem list you should have some clickable buttons to quickly open Chests or combine Gems\n\n" ..
        "And to get rid of this frame simply shift click it.\nHave fun!",

    -- UIElements.lua
    ["You don't have a valid free Slot for this Gem"] = "You don't have a valid free Slot for this Gem",
}
