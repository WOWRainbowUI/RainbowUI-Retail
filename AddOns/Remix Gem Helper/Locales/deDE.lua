---@class RemixGemHelperPrivate
local Private = select(2, ...)
Private.Locales = Private.Locales or {}

Private.Locales["deDE"] = {
    --isEditing = true,

    -- CloakTooltip.lua
    ["Rank"] = "Rang",

    -- Core.lua
    ["Socketed"] = "Gesockelt",
    ["In Bag"] = "Im Rucksack",
    ["In Bag Item!"] = "Im Rucksack, Gesockelt!",
    ["Uncollected"] = "Nicht gesammelt",
    ["Scrappable Items"] = "Verschrottbare Items",
    ["NOTHING TO SCRAP"] = "NICHTS ZUM VERSCHROTTEN",
    ["Resocket Gems"] = "Edelsteine wieder Sockeln",
    ["Toggle the %s UI"] = "Ein-/Ausschalten der %s UI", -- %s is the Addon name and needs to be included!
    ["Search Gems"] = "Suche Edelstein",
    ["Unowned"] = "Unbekannt",
    ["Show Unowned Gems in the List."] = "Unbekannte Edelsteine anzeigen.",
    ["Primordial"] = "Urzeitlich",
    ["Show Primordial Gems in the List."] = "Urzeitliche Steine anzeigen.",
    ["Open, Use and Combine"] = "Öffnen, Benutzen und Kombinieren",
    ["NOTHING TO USE"] = "NICHTS ZUM BENUTZEN",
    ["HelpText"] =
        "|A:newplayertutorial-icon-mouse-leftbutton:16:16|a Klicke einen Edelstein in der Liste zum Sockeln und Entsockeln.\n" ..
        "'Im Rucksack, Gesockelt!' oder 'Gesockelt' bedeutet, dass du den Edelstein Entsockelts.\n" ..
        "'Im Rucksack' bedeutet, dass der Edelstein im Rucksack ist und bereit um gesockelt zu werden.\n\n" ..
        "Wenn du mit dem Mauszeiger über einen Edelstein fährst, der 'Gesockelt' ist, wird der Gegenstand im Charakterfenster hervorgehoben.\n" ..
        "Du kannst die Dropdown-Liste oder die Suchleiste oben verwenden, um die Liste zu filtern.\n" ..
        "Dieses Addon fügt auch den aktuellen Rang und die Werte des Mantels im Tooltip des Mantels hinzu.\n" ..
        "Oben rechts in deinem Charakterfenster sollte ein Symbol zu sehen sein, mit dem du dieses Frame ein- oder ausblenden kannst.\n" ..
        "Unter der Edelsteinliste sollten sich anklickbare Buttons befinden, um schnell Truhen zu öffnen oder Edelsteine zu kombinieren\n\n" ..
        "Und um dieses Hilfe Fenster loszuwerden, klick einfach mit gedrückter Umschalttaste auf das Symbol..\nViel Spaß!",

    -- UIElements.lua
    ["You don't have a valid free Slot for this Gem"] = "Sie haben keinen gültigen freien Slot für diesen Edelstein",
}
