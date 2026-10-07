-- $Id$ 
-- DE Translation, thanks to snj & JokerGermany, IsabelGarcia, pas06
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "deDE", false)

if not L then return end

-- Header
L["Accountant Classic"] = "Accountant Classic"
L["A basic tool to track your monetary incomings and outgoings within WoW."] = "Ein einfaches Hilfsprogramm, um deine Ein- und Ausgaben in WoW zu überwachen."
L[ [=[Left-Click to open Accountant Classic.
Right-Click for Accountant Classic options.
Left-click and drag to move this button.]=] ] = [=[Linke Maustaste drücken, um Accountant Classic zu öffnen.
Rechte Maustaste drücken, um die Accountant-Classic-Optionen anzuzeigen.
Linke Maustaste gedrückt halten und ziehen, um diese Schaltfläche zu verschieben.]=]
L[ [=[Left-click and drag to move this button.
Right-Click to open Accountant Classic.]=] ] = [=[Rechtsklick, um Accountant Classic zu öffnen.
Linke Maustaste gedrückt halten und ziehen, um diese Schaltfläche zu verschieben.]=]
L["Total Incomings"] = "Gesamteinnahmen"
L["Total Outgoings"] = "Gesamtausgaben"
L["Net Profit / Loss"] = "Nettoertrag / -verlust"
L["Net Loss"] = "Nettoverlust"
L["Net Profit"] = "Nettoertrag"
L["Source"] = "Quelle"
L["Incomings"] = "Einnahmen"
L["Outgoings"] = "Ausgaben"
L["Week Start"] = "Wochenbeginn"
L["Sum Total"] = "Gesamtsumme"
L["Character"] = "Charakter"
L["Money"] = "Geld"
L["Updated"] = "Aktualisiert"

-- Section Labels
L["Quest Rewards"] = "Questbelohnungen"
L["Merchants"] = "Händler"
L["Trade Window"] = "Handelsfenster"
L["Mail"] = "Post"
L["Training Costs"] = "Ausbildungskosten"
L["Taxi Fares"] = "Reisekosten"
L["Unknown"] = "Unbekannt"
L["Repair Costs"] = "Reparaturkosten"
L["LFD, LFR and Scen."] = "Dungeon-, SZ-Browser u. Szenario"

-- Buttons
L["Reset"] = "Zurücksetzen"
L["Options"] = "Optionen"
L["Exit"] = "Beenden"

-- Tabs' name
L["This Session"] = "Diese Sitzung"
L["Today"] = "Heute"
L["Prv. Day"] = "Vorh. Tag"
L["This Week"] = "Diese Woche"
L["Prv. Week"] = "Vorh. Woche"
L["This Month"] = "Dieser Monat"
L["Prv. Month"] = "Vorh. Monat"
L["This Year"] = "Dieses Jahr"
L["Prv. Year"] = "Vorh. Jahr"
L["Total"] = "Gesamt"
L["All Chars"] = "Alle Chars"

-- Options
L["Accountant Classic Options"] = "Accountant-Classic-Optionen"
L["Show minimap button"] = "Minikartenbutton zeigen"
L["Show money"] = "Geld zeigen"
L["Show money on minimap button's tooltip"] = "Gold im Tooltip des Minikartenbuttons anzeigen"
L["Show session info"] = "Sitzungsinfo zeigen"
L["Show session info on minimap button's tooltip"] = "Sitzungsinformationen im Tooltip des Minikartenbuttons anzeigen"
L["Show money on screen"] = "Geld am Bildschirm zeigen"
L["Reset position"] = "Position zurücksetzen"
L["Reset money frame's position"] = "Position des Geldfensters zurücksetzen"
L["Minimap Button Settings"] = "Einstellungen Minikartenbutton"
L["Minimap Button Position"] = "Position Minikartenbutton"
L["Start of Week"] = "Beginn der Woche"
L["Done"] = "Fertig"
L["Display Instruction Tips"] = "Einführungstipps anzeigen"
L["Toggle whether to display minimap button or floating money frame's operation tips."] = "Aktiviert/Deaktiviert die Anzeige von Bedienungstipps im Tooltip der Minikartenschaltfläche und des frei beweglichen Geldfensters."
L["Select the character to be removed:"] = "Wähle den Charakter, der entfernt werden soll:"
L["The selected character's Accountant Classic data will be removed."] = "Die Accountant-Classic-Daten des ausgewählten Charakters werden entfernt."
L["|cffffffff\"%s - %s|cffffffff\" character's Accountant Classic data has been removed."] = "|cffffffffDie Accountant-Classic-Daten für den Charakter \"%s - %s|cffffffff\" wurden gelöscht."
L["Select the date format:"] = "Wähle das Datumsformat aus:"
L["Date format showing in \"All Chars\" and \"Week\" tabs"] = "Datumsformat in den Reitern 'Alle Chars' und 'Woche'."
L["Show net income / expanse on LDB"] = "Zeigt Nettoeinnahmen / Ausgaben im LDB an"
L["Show current session's net income / expanse instead of total money on LDB"] = "Die Nettoeinnahmen/-ausgaben der aktuellen Sitzung anstatt des Gesamtgolds auf dem LDB  zeigen"
L["Show all realms' characters info"] = "Informationen von Charakteren auf allen Realms zeigen"
L["Enable to show all characters' money info from all realms. Disable to only show current realm's character info."] = "Aktiviere diese Option, um die Geldinformationen von Charakteren auf allen Realms zu zeigen. Deaktiviere diese Option, damit nur Informationen von Charakteren auf dem momentanen Realm gezeigt werden."
L["Track location of incoming / outgoing money"] = "Den Ort, an dem Einnahmen/Ausgaben stattfanden, aufzeichnen"
L["Enable to track the location of each incoming / outgoing money and also show the breakdown info while mouse hover each of the expenditure."] = "Aktiviere diese Option, um den Ort jeder Einnahme/Ausgabe aufzuzeichnen. Diese Informationen werden angezeigt, wenn du mit der Maus über die Einträge in den Spalten Einnahmen und Ausgaben fährst."
L["Also track subzone info"] = "Unterzoneninfo ebenfalls aufzeichen"
L["Enable to also track on the subzone info. For example: Suramar - Sanctum of Order"] = "Aktiviere diese Option, um die Unterzone ebenfalls aufzuzeichnen. Z.B.: Suramar – Sanktum der Ordnung"
L["Converts a number into a localized string, grouping digits as required."] = "Eine Zahl in eine lokalisierte Zeichenketten umwandeln, Ziffern werden gruppiert."
L["Accountant Classic Frame's Scale"] = "Skalierung des Accountant-Classic-Fensters"
L["Accountant Classic Frame's Transparency"] = "Transparenz des Accountant-Classic-Fensters"
L["Accountant Classic Floating Info's Scale"] = "Skalierung der frei beweglichen Accountant-Classic-Info"
L["Accountant Classic Floating Info's Transparency"] = "Transparenz der frei beweglichen Accountant-Classic-Info"
L["LDB Display Settings"] = "LDB-Anzeigeeinstellungen"
L["LDB Display Type"] = "LDB-Anzeigetyp"
L["Data type to be displayed on LDB"] = "Der anzuzeigende Datentyp auf dem LDB"
L["General and Data Display Format Settings"] = "Allgemeine Einstellungen und Formateinstellungen anzuzeigender Daten"
L["Main Frame's Scale and Alpha Settings"] = "Einstellungen Skalierung und Transparenz des Hauptfensters"
L["Onscreen Actionbar's Scale and Alpha Settings"] = "Einstellungen Skalierung und Transparenz der Aktionsleiste auf dem Bildschirm"
L["Character Data's Removal"] = "Löschung von Charakterdaten"
L["Profile Options"] = "Profiloptionen"
L["Scale and Transparency"] = "Skalierung und Transparenz"
L["Remember character selected"] = "Ausgewählten Charakter merken"
L["Remember the latest character selection in dropdown menu."] = "Merkt sich den zuletzt gewählten Charakter aus dem Auswahlmenü."
L["Show all factions' characters info"] = "Zeigt alle Charaktere der Fraktionen an"
L["Enable to show all characters' money info from all factions. Disable to only show all characters' info from current faction."] = "Aktiviere diese Option, um die Geldinformationen aller Charaktere von allen Fraktionen anzuzeigen. Deaktiviere diese Option, um nur die Informationen aller Charaktere der aktuellen Fraktion anzuzeigen."
L["Enhanced Tracking Options"] = "Erweiterte Verfolgungsoptionen"
L["All Factions"] = "Alle Fraktionen"
L["All Servers"] = "Alle Realms"

-- Misc
L["Are you sure you want to reset the \"%s\" data?"] = "Bist du sicher, dass Du die Daten \"%s\" zurücksetzen willst?"
L["New Accountant Classic profile created for %s"] = "Neues Accountant-Classic-Profil für %s erstellt"
L["Loaded Accountant Classic Profile for %s"] = "Accountant-Classic-Profil für %s geladen"
L["Accountant Classic loaded."] = "Accountant Classic gestartet."
L["g "] = "g "
L["s "] = "s "
L["c"] = "k"
L["About"] = "Über"
L["Show All Characters"] = "Alle Charaktere zeigen"
L["Show all characters' incoming and outgoing data."] = "Zeigt Einnahmen und Ausgaben aller Charaktere"

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) Gold"
L["(%d+) Silver"] = "(%d+) Silber"
L["(%d+) Copper"] = "(%d+) Kupfer"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Accountant Classic umschalten"
