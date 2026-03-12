-- deDE.lua (German)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "deDE")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Optionen können im Kampf nicht geöffnet werden."
L["MiniCC test command is unavailable."] = "Der MiniCC-Testbefehl ist nicht verfügbar."

-- Category Names
L["Action Bars"] = "Aktionsleisten"
L["Nameplates"] = "Namensplaketten"
L["Unit Frames"] = "Einheitenfenster"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "Sonstiges"

-- Group Headers
L["General"] = "Allgemein"
L["Typography (Cooldown Numbers)"] = "Typografie (Abklingzeit-Zahlen)"
L["Swipe Animation"] = "Wischanimation"
L["Stack Counters / Charges"] = "Stapelzähler / Aufladungen"
L["Maintenance"] = "Wartung"
L["Danger Zone"] = "Gefahrenzone"
L["Style"] = "Stil"
L["Positioning"] = "Positionierung"
L["CooldownManager Viewers"] = "CooldownManager-Anzeigen"
L["MiniCC Frame Types"] = "MiniCC-Rahmentypen"

-- Toggles & Settings
L["Enable %s"] = "%s aktivieren"
L["Toggle styling for this category."] = "Schaltet das Styling für diese Kategorie um."
L["Font Face"] = "Schriftart"
L["Font"] = "Schrift"
L["Size"] = "Größe"
L["Outline"] = "Umrandung"
L["Color"] = "Farbe"
L["Hide Numbers"] = "Zahlen ausblenden"
L["Compact Party / Raid Aura Text"] = "Kompakter Gruppen-/Schlachtzugs-Auratext"
L["Enable Party Aura Text"] = "Gruppen-Auratext aktivieren"
L["Enable Raid Aura Text"] = "Schlachtzugs-Auratext aktivieren"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Blendet den Text vollständig aus (nützlich, wenn du nur die Wischkante oder Stapel sehen willst)."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Zeigt gestalteten Countdown-Text auf den Buff- und Debuff-Symbolen des Blizzard CompactPartyFrame an. Wenn dies deaktiviert ist, wird der Auren-Countdowntext auf Gruppenfenstern ausgeblendet."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Zeigt gestalteten Countdown-Text auf den Buff- und Debuff-Symbolen des Blizzard CompactRaidFrame an. Wenn dies deaktiviert ist, wird der Auren-Countdowntext auf Schlachtzugsfenstern ausgeblendet."
L["Anchor Point"] = "Ankerpunkt"
L["Offset X"] = "Versatz X"
L["Offset Y"] = "Versatz Y"
L["Essential Viewer Size"] = "Größe der Essential-Anzeige"
L["Utility Viewer Size"] = "Größe der Utility-Anzeige"
L["Buff Icon Viewer Size"] = "Größe der Buffsymbol-Anzeige"
L["CC Text Size"] = "CC-Textgröße"
L["Nameplates Text Size"] = "Namensplaketten-Textgröße"
L["Portraits Text Size"] = "Porträt-Textgröße"
L["Alerts / Overlay Text Size"] = "Textgröße für Warnungen / Overlays"
L["Toggle Test Icons"] = "Testsymbole umschalten"
L["Show Swipe Edge"] = "Wischkante anzeigen"
L["Shows the white line indicating cooldown progress."] = "Zeigt die weiße Linie an, die den Fortschritt der Abklingzeit markiert."
L["Edge Thickness"] = "Kantendicke"
L["Scale of the swipe line (1.0 = Default)."] = "Skalierung der Wischlinie (1,0 = Standard)."
L["Customize Stack Text"] = "Stapeltext anpassen"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Übernimm die Kontrolle über den Aufladungszähler (z. B. 2 Aufladungen von Feuersbrunst)."
L["Reset %s"] = "%s zurücksetzen"
L["Revert this category to default settings."] = "Setzt diese Kategorie auf die Standardeinstellungen zurück."
L["Toggle MiniCC's built-in test icons using /minicc test."] = "Schalte die eingebauten Testsymbole von MiniCC mit /minicc test ein oder aus."

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
L["Factory Reset (All)"] = "Werkseinstellungen wiederherstellen (Alles)"
L["Resets the entire profile to default values and reloads the UI."] = "Setzt das gesamte Profil auf die Standardwerte zurück und lädt die Benutzeroberfläche neu."
L["Import / Export"] = "Import / Export"
L["PROFILE_IMPORT_EXPORT_DESC"] = "Exportiert das aktive AceDB-Profil als teilbare Zeichenfolge oder importiert eine Zeichenfolge, um die aktuellen Profileinstellungen zu ersetzen."
L["Export current profile"] = "Aktuelles Profil exportieren"
L["Generate export"] = "Export erzeugen"
L["Export code"] = "Exportcode"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "Erzeuge eine Exportzeichenfolge, klicke dann in dieses Feld und kopiere sie mit Strg+C."
L["Import profile"] = "Profil importieren"
L["Import code"] = "Importcode"
L["Paste an exported string here, then click Import."] = "Füge hier eine exportierte Zeichenfolge ein und klicke dann auf Importieren."
L["Import"] = "Importieren"
L["Importing will overwrite the current profile settings. Continue?"] = "Beim Import werden die aktuellen Profileinstellungen überschrieben. Fortfahren?"
L["Export string generated. Copy it with Ctrl+C."] = "Exportzeichenfolge erzeugt. Kopiere sie mit Strg+C."
L["Profile import completed."] = "Profilimport abgeschlossen."
L["No active profile available."] = "Kein aktives Profil verfügbar."
L["Failed to encode export string."] = "Exportzeichenfolge konnte nicht codiert werden."
L["Paste an import string first."] = "Füge zuerst eine Importzeichenfolge ein."
L["Invalid import string format."] = "Ungültiges Format der Importzeichenfolge."
L["Failed to decode import string."] = "Importzeichenfolge konnte nicht decodiert werden."
L["Failed to decompress import string."] = "Importzeichenfolge konnte nicht dekomprimiert werden."
L["Failed to deserialize import string."] = "Importzeichenfolge konnte nicht deserialisiert werden."

-- Banner
L["BANNER_DESC"] = "Minimalistische Konfiguration für deine Abklingzeiten. Wähle links eine Kategorie, um zu beginnen."

-- Chat Messages
L["%s settings reset."] = "%s Einstellungen zurückgesetzt."
L["Profile reset. Reloading UI..."] = "Profil zurückgesetzt. UI wird neu geladen..."

-- Status Indicators
L["ON"] = "AN"
L["OFF"] = "AUS"

-- General Dashboard
L["Enable categories styling"] = "Kategoriestyling aktivieren"
L["LIVE_CONTROLS_DESC"] = "Änderungen werden sofort übernommen. Lass für ein aufgeräumtes Setup nur die Kategorien aktiviert, die du wirklich nutzt."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Zeigt gestalteten Countdown-Text auf den Buff- und Debuff-Symbolen von Blizzard CompactPartyFrame und CompactRaidFrame an. Gruppe und Schlachtzug lassen sich getrennt ein- oder ausschalten. Dies ist unabhängig von Sonstiges."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Kopiere diesen Link, um die CurseForge-Projektseite in deinem Browser zu öffnen."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Kopiere diesen Link, um weitere Projekte von Anahkas auf CurseForge anzusehen."

-- Help
L["Help & Support"] = "Hilfe & Support"
L["Project"] = "Projekt"
L["Useful Addons"] = "Nützliche Addons"
L["Support & Feedback"] = "Support & Feedback"
L["MCE_HELP_INTRO"] = "Schnelle Projektlinks und ein paar Addons, die einen Blick wert sind."
L["HELP_SUPPORT_DESC"] = "Vorschläge und Feedback sind jederzeit willkommen.\n\nWenn du einen Fehler findest oder eine Funktionsidee hast, kannst du gerne einen Kommentar oder eine private Nachricht auf CurseForge hinterlassen."
L["HELP_COMPANION_DESC"] = "Saubere Begleit-Addons, die gut zu MiniCE passen."
L["HELP_MINICC_DESC"] = "Kompakter CC-Tracker. MiniCE kann auch dessen Text gestalten."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "Kopiere diesen Link, um die MiniCC-Seite auf CurseForge in deinem Browser zu öffnen."
L["HELP_PVPTAB_DESC"] = "Sorgt dafür, dass TAB im PvP nur Spieler anvisiert. Ideal für Arenen und Schlachtfelder."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Kopiere diesen Link, um Smart PvP Tab Targeting auf CurseForge zu öffnen."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Schalte deine wichtigsten Abklingzeit-Kategorien an einem Ort um."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Diese Aktion kann nicht rückgängig gemacht werden. Dein Profil wird vollständig zurückgesetzt und die UI neu geladen."
L["MAINTENANCE_DESC"] = "Setzt diese Kategorie auf die Werkseinstellungen zurück. Andere Kategorien bleiben unverändert."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Passe Abklingzeiten auf deinen Hauptaktionsleisten an, einschließlich Bartender4, Dominos und ElvUI."
L["NAMEPLATE_DESC"] = "Stilisiere Abklingzeiten auf feindlichen und freundlichen Namensplaketten (Plater, KuiNameplates usw.)."
L["UNITFRAME_DESC"] = "Passe das Abklingzeit-Styling auf Spieler-, Ziel- und Fokus-Einheitenfenstern an."
L["COOLDOWNMANAGER_DESC"] = "Gemeinsames Symbol-Styling für CooldownManager-Anzeigen. Die Größe des Countdown-Texts kann für Essential-, Utility- und Buffsymbol-Anzeigen separat festgelegt werden."
L["MINICC_DESC"] = "Eigenständiges Styling für MiniCC-Abklingzeitsymbole. Unterstützt bei geladenem MiniCC dessen CC-Symbole, Namensplaketten, Porträts und Overlay-Module."
L["OTHERS_DESC"] = "Auffangkategorie für Abklingzeiten, die zu keiner anderen Kategorie gehören (Taschen, Menüs, sonstige Addons)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Dynamische Textfarben"
L["Color by Remaining Time"] = "Nach verbleibender Zeit färben"
L["Dynamically colors the countdown text based on how much time is left."] = "Färbt den Countdown-Text dynamisch danach, wie viel Zeit noch verbleibt."
L["DYNAMIC_COLORS_DESC"] = "Ändert die Textfarbe abhängig von der verbleibenden Abklingzeit. Überschreibt die statische Farbe oben, wenn aktiviert."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Wendet dieselben Restzeit-Schwellen auf jede aktivierte MiniCE-Kategorie an, einschließlich des Auren-Texts für kompakte Gruppen-/Schlachtzugsfenster. Die Dauerbehandlung bleibt auch beim Datumswechsel um Mitternacht stabil, wenn Blizzard versteckte Werte liefert."
L["Expiring Soon"] = "Läuft bald ab"
L["Short Duration"] = "Kurze Dauer"
L["Long Duration"] = "Lange Dauer"
L["Beyond Thresholds"] = "Über den Schwellenwerten"
L["Threshold (seconds)"] = "Schwellenwert (Sekunden)"
L["Default Color"] = "Standardfarbe"
L["Color used when the remaining time exceeds all thresholds."] = "Farbe, die verwendet wird, wenn die verbleibende Zeit alle Schwellenwerte überschreitet."

-- Abbreviation
L["Abbreviate Above"] = "Abkürzen ab"
L["Abbreviate Above (seconds)"] = "Abkürzen ab (Sekunden)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Abklingzeit-Zahlen über diesem Schwellenwert werden abgekürzt (z.B. 5m statt 300)."
L["ABBREV_THRESHOLD_DESC"] = "Bestimmt, ab wann Abklingzeit-Zahlen in Kurzformat angezeigt werden. Timer über diesem Wert zeigen verkürzte Werte wie 5m oder 1h."
