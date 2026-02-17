-- deDE.lua (German)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "deDE")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Optionen können im Kampf nicht geöffnet werden."

-- Category Names
L["Action Bars"] = "Aktionsleisten"
L["Nameplates"] = "Namensplaketten"
L["Unit Frames"] = "Einheitenfenster"
L["CD Manager & Others"] = "CD-Manager & Andere"

-- Group Headers
L["General"] = "Allgemein"
L["State"] = "Status"
L["Typography (Cooldown Numbers)"] = "Typografie (Abklingzeit-Zahlen)"
L["Swipe Animation"] = "Wischanimation"
L["Stack Counters / Charges"] = "Stapelzähler / Aufladungen"
L["Maintenance"] = "Wartung"
L["Performance & Detection"] = "Leistung & Erkennung"
L["Danger Zone"] = "Gefahrenzone"
L["Style"] = "Stil"
L["Positioning"] = "Positionierung"

-- Toggles & Settings
L["Enable %s"] = "%s aktivieren"
L["Toggle styling for this category."] = "Stilisierung für diese Kategorie umschalten."
L["Font Face"] = "Schriftart"
L["Game Default"] = "Spiel Standard"
L["Font"] = "Schrift"
L["Size"] = "Größe"
L["Outline"] = "Umriss"
L["Color"] = "Farbe"
L["Hide Numbers"] = "Zahlen ausblenden"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Text vollständig ausblenden (nützlich wenn nur die Wischkante oder Stapel gewünscht)."
L["Anchor Point"] = "Ankerpunkt"
L["Offset X"] = "Versatz X"
L["Offset Y"] = "Versatz Y"
L["Show Swipe Edge"] = "Wischkante anzeigen"
L["Shows the white line indicating cooldown progress."] = "Zeigt die weiße Linie an, die den Abklingzeit-Fortschritt anzeigt."
L["Edge Thickness"] = "Kantendicke"
L["Scale of the swipe line (1.0 = Default)."] = "Skalierung der Wischlinie (1,0 = Standard)."
L["Customize Stack Text"] = "Stapeltext anpassen"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Übernimm die Kontrolle über den Aufladungszähler (z.B. 2 Stapel Verbrennen)."
L["Reset %s"] = "%s zurücksetzen"
L["Revert this category to default settings."] = "Diese Kategorie auf Standardeinstellungen zurücksetzen."

-- Outline Values
L["None"] = "Keine"
L["Thick"] = "Dick"
L["Mono"] = "Mono"

-- Anchor Point Values
L["Bottom Right"] = "Unten rechts"
L["Bottom Left"] = "Unten links"
L["Top Right"] = "Oben rechts"
L["Top Left"] = "Oben links"
L["Center"] = "Mitte"

-- General Tab
L["Scan Depth"] = "Scantiefe"
L["How deep the addon looks into UI frames to find cooldowns."] = "Wie tief das Addon in UI-Fenster schaut, um Abklingzeiten zu finden."
L["Factory Reset (All)"] = "Werksreset (Alle)"
L["Resets the entire profile to default values and reloads the UI."] = "Setzt das gesamte Profil auf Standardwerte zurück und lädt die Benutzeroberfläche neu."

-- Banner
L["BANNER_DESC"] = "Minimalistische Konfiguration für deine Abklingzeiten. Wähle links eine Kategorie, um zu beginnen."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Effizient (Standard-UI)\n|cfffff56910 - 15|r : Moderat (Bartender, Dominos)\n|cffffa500> 15|r : Schwer (ElvUI, komplexe Fenster)"

-- Chat Messages
L["%s settings reset."] = "%s Einstellungen zurückgesetzt."
L["Profile reset. Reloading UI..."] = "Profil zurückgesetzt. UI wird neu geladen..."
L["Global Scan Depth changed. A /reload is recommended."] = "Globale Scantiefe geändert. Ein /reload wird empfohlen."
