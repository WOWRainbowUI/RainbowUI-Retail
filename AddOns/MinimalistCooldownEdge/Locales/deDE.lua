-- deDE.lua (German)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "deDE")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras verwaltet die Schwellenfarben des Countdowns. Konfiguriere sie unter MiniAuras > Misc > Countdown Colours."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0 % = transparent, 100 % = vollständig dunkel. Gilt für alle MiniAuras-Modulgruppen; 80 % entspricht der Wischanimation von MiniAuras selbst."

-- Core
L["MiniAuras test command is unavailable."] = "Der MiniAuras-Testbefehl ist nicht verfügbar."

-- Category Names
L["Action Bars"] = "Aktionsleisten"
L["Nameplates"] = "Namensplaketten"
L["Unit Frames"] = "Einheitenfenster"
L["Party / Raid Frames"] = "Gruppen-/Schlachtzugsfenster"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "MiniAuras-Rahmentypen"

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
L["Essential Viewer Stack Size"] = "Stackgröße der Essential-Anzeige"
L["Utility Viewer Stack Size"] = "Stackgröße der Utility-Anzeige"
L["Buff Icon Viewer Stack Size"] = "Stackgröße der Buffsymbol-Anzeige"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "Schalte die eingebauten Testsymbole von MiniAuras mit /miniauras test ein oder aus."

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
L["Top"] = "Oben"
L["Bottom"] = "Unten"
L["Left"] = "Links"
L["Right"] = "Rechts"

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
L["Retired"] = "Eingestellt"

-- General Dashboard
L["Enable categories styling"] = "Kategoriestyling aktivieren"
L["LIVE_CONTROLS_DESC"] = "Änderungen werden sofort übernommen. Lass für ein aufgeräumtes Setup nur die Kategorien aktiviert, die du wirklich nutzt."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Gruppen-/Schlachtzugsfenster aktivieren dient als Hauptschalter für diese Kategorie. Schlachtzugs-Auratext aktivieren erweitert dasselbe Styling auf Blizzard-Schlachtzugsfenster."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "Die Unterstützung für Gruppen-/Schlachtzugsfenster wurde eingestellt. Seit Blizzard Patch 12.0.5 hookt oder gestaltet MiniCE kompakte Gruppen- und Schlachtzugsfenster nicht mehr."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "Neues Addon in Entwicklung: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras ist jetzt auf CurseForge verfügbar. Es bleibt von MiniCE getrennt, weil es eigene Overlay-Frames verwendet, anstatt Blizzards vorhandene Symbole zu stylen, wodurch es besser als eigenständiges Addon funktioniert."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Kopiere diesen Link, um die CurseForge-Projektseite in deinem Browser zu öffnen."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "Kopiere diesen Link, um Raid Frame Auras auf CurseForge zu öffnen."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Kopiere diesen Link, um weitere Projekte von Anahkas auf CurseForge anzusehen."

-- Help
L["Help & Support"] = "Hilfe & Support"
L["Project"] = "Projekt"
L["Useful Addons"] = "Nützliche Addons"
L["Support & Feedback"] = "Support & Feedback"
L["MCE_HELP_INTRO"] = "Schnelle Projektlinks und ein paar Addons, die einen Blick wert sind."
L["HELP_SUPPORT_DESC"] = "Vorschläge und Feedback sind jederzeit willkommen.\n\nWenn du einen Fehler findest oder eine Funktionsidee hast, kannst du gerne einen Kommentar oder eine private Nachricht auf CurseForge hinterlassen."
L["HELP_COMPANION_DESC"] = "Saubere Begleit-Addons, die gut zu MiniCE passen."
L["HELP_MINIAURAS_DESC"] = "Anpassbare Aura-, Kontroll-, Abklingzeit- und PvP-Anzeigen. MiniCE kann auch die Abklingzeittexte gestalten."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "Kopiere diesen Link, um die MiniAuras-Seite auf CurseForge in deinem Browser zu öffnen."
L["HELP_PVPTAB_DESC"] = "Sorgt dafür, dass TAB im PvP nur Spieler anvisiert. Ideal für Arenen und Schlachtfelder."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Kopiere diesen Link, um Smart PvP Tab Targeting auf CurseForge zu öffnen."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Schalte deine wichtigsten Abklingzeit-Kategorien an einem Ort um."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Diese Aktion kann nicht rückgängig gemacht werden. Dein Profil wird vollständig zurückgesetzt und die UI neu geladen."
L["MAINTENANCE_DESC"] = "Setzt diese Kategorie auf die Werkseinstellungen zurück. Andere Kategorien bleiben unverändert."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Gestalte Abklingzeiten auf deinen Aktionsleisten."
L["NAMEPLATE_DESC"] = "Gestalte Abklingzeiten auf feindlichen und freundlichen Namensplaketten."
L["UNITFRAME_DESC"] = "Gestalte Aura-Abklingzeiten auf Ziel-, Fokus- und unterstützten Einheitenfenstern."
L["COOLDOWNMANAGER_DESC"] = "Gestalte Symbol-Abklingzeiten von CooldownManager."
L["MINIAURAS_DESC"] = "Gestalte Abklingzeitsymbole von MiniAuras."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Dynamische Textfarben"
L["Color by Remaining Time"] = "Nach verbleibender Zeit färben"
L["Dynamically colors the countdown text based on how much time is left."] = "Färbt den Countdown-Text dynamisch danach, wie viel Zeit noch verbleibt."
L["DYNAMIC_COLORS_DESC"] = "Ändert die Textfarbe abhängig von der verbleibenden Abklingzeit. Überschreibt die statische Farbe oben, wenn aktiviert."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Restzeit-Schwellenwerte können pro aktiver MiniCE-Kategorie erlaubt oder blockiert werden. Die Dauerbehandlung bleibt auch beim Datumswechsel um Mitternacht stabil, wenn Blizzard versteckte Werte liefert."
L["Expiring Soon"] = "Läuft bald ab"
L["Short Duration"] = "Kurze Dauer"
L["Long Duration"] = "Lange Dauer"
L["Threshold (seconds)"] = "Schwellenwert (Sekunden)"
L["Default Color"] = "Standardfarbe"
L["Color used when the remaining time exceeds all thresholds."] = "Farbe, die verwendet wird, wenn die verbleibende Zeit alle Schwellenwerte überschreitet."

-- Abbreviation
L["Abbreviate Above"] = "Abkürzen ab"
L["Abbreviate Above (seconds)"] = "Abkürzen ab (Sekunden)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Abklingzeit-Zahlen über diesem Schwellenwert werden abgekürzt (z.B. 5m statt 300)."
L["ABBREV_THRESHOLD_DESC"] = "Bestimmt, ab wann Abklingzeit-Zahlen in Kurzformat angezeigt werden. Timer über diesem Wert zeigen verkürzte Werte wie 5m oder 1h."

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0 % = transparent, 100 % = vollständig dunkel. Ersetzt die MyDRs-Einstellung Cooldown Swipe Alpha, solange diese Kategorie aktiviert ist; 100 % entspricht der Wischanimation, die MyDRs selbst zeichnet."
L["MyDRs test command is unavailable."] = "Der MyDRs-Testbefehl ist nicht verfügbar."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "Schalte die eingebauten Testsymbole von MyDRs mit /mydrs test ein oder aus."
L["sArena slash command is unavailable."] = "Der sArena-Slash-Befehl ist nicht verfügbar."

-- Category Names
L["Player Auras"] = "Spieler-Auren"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "Profile"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "Wischkante"
L["MiniAuras Module Groups"] = "MiniAuras-Modulgruppen"
L["sArena Cooldown Types"] = "sArena-Abklingzeittypen"
L["Aura Targets"] = "Aura-Ziele"
L["Buff Styling"] = "Buff-Styling"
L["Debuff Styling"] = "Debuff-Styling"
L["External Defensive Buffs Styling"] = "Styling externer Verteidigungsbuffs"

-- Toggles & Settings
L["Style Buffs"] = "Buffs stylen"
L["Style Debuffs"] = "Debuffs stylen"
L["Style External Defensive Buffs"] = "Externe Verteidigungsbuffs stylen"
L["Style Blizzard's default player buff buttons."] = "Stylt die standardmäßigen Blizzard-Buffsymbole des Spielers."
L["Style Blizzard's default player debuff buttons."] = "Stylt die standardmäßigen Blizzard-Debuffsymbole des Spielers."
L["Style Blizzard's external defensive buff buttons."] = "Stylt die externen Verteidigungsbuff-Symbole von Blizzard."
L["Timer Inside Icon"] = "Timer im Symbol"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Platziert den Aura-Timer in der Mitte des Symbols statt an Blizzards Standardposition außerhalb."
L["Hide Swipe"] = "Wischen ausblenden"
L["Only Mine (Timer Text)"] = "Nur meine (Timer-Text)"
L["Aura Visibility"] = "Aura-Sichtbarkeit"
L["Only My Debuffs"] = "Nur meine Debuffs"
L["Only My Buffs"] = "Nur meine Buffs"
L["Disable fading/blinking"] = "Ein-/Ausblenden und Blinken deaktivieren"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "Aktiviert gestalteten Countdown-Text auf Gruppen-/Schlachtzugsfenstern. Wenn deaktiviert, wird das Styling für Gruppen- und Schlachtzugs-Auratext vollständig abgeschaltet."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Wendet gestalteten Countdown-Text auch auf die Buff- und Debuff-Symbole von Blizzard CompactRaidFrame an. Erfordert, dass Gruppen-/Schlachtzugsfenster aktiviert ist."
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "Blendet die Wischanimation für diese Rahmengruppe aus (Countdown-Text bleibt sichtbar)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "Zeigt Abklingzeit-Timer-Text nur auf deinen eigenen Auren. Nutzt Blizzards Heuristik für große Auren statt einer direkten sourceUnit-Prüfung."
L["UNITFRAME_ONLY_MINE_DESC"] = "Zeigt Timer-Text nur auf Auren, die du selbst gewirkt hast. MiniCEs Ziel-/Fokus-Container für WoW 12.1 nutzen Blizzards Spielerfilter; kompatible Addon- und ältere Fenster nutzen ihre Gruppenmetadaten oder den Große-Auren-Fallback."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Blendet Debuffs aus, die von anderen Spielern auf den Ziel- und Fokusfenstern gewirkt wurden. MiniCE verwaltet diese Aura-Container unter WoW 12.1, sodass Blizzards eigener Debuff-Filter sie nicht mehr erreicht."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Blendet Buffs aus, die von anderen Spielern auf den Ziel- und Fokusfenstern gewirkt wurden. MiniCE verwaltet diese Aura-Container unter WoW 12.1, sodass Blizzards eigener Buff-Filter sie nicht mehr erreicht."
L["Cast Bar"] = "Zauberleiste"
L["Reposition Cast Bar"] = "Zauberleiste neu positionieren"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Verankert die Zauberleisten von Ziel und Fokus unter der letzten Buff-/Debuff-Reihe. MiniCE verwaltet diese Aura-Container unter WoW 12.1; andernfalls bleibt Blizzards Zauberleiste am Fenster kleben und überlappt sie."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "Hält Aura-Symbole des Spielers vollständig deckend, wenn sie kurz vor dem Ablaufen stehen."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "Verwendet eine eigene Buff-Farbe, wenn ein CooldownManager-Slot vorübergehend die Aura-Zeit anzeigt, statt der Restzeit-Schwellenfarben."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "Wird angewendet, solange der Slot die Aura-Dauer anzeigt. Wenn die Aura endet und der Slot wieder zur Abklingzeit wechselt, gelten wieder die Schwellenfarben."
L["Buff / Debuff Size"] = "Größe Buff / Debuff"
L["Defensive Buff Size"] = "Größe Verteidigungsbuff"
L["Use Buff Color"] = "Buff-Farbe verwenden"
L["Buff Color"] = "Buff-Farbe"
L["Essential Viewer"] = "Essential-Anzeige"
L["Utility Viewer"] = "Utility-Anzeige"
L["Buff Icon Viewer"] = "Buffsymbol-Anzeige"
L["CC Frames Text Size"] = "CC-Fenster-Textgröße"
L["CC / Friendly Frames Text Size"] = "Textgröße CC / freundliche Fenster"
L["Raid Frame Auras Text Size"] = "Textgröße Schlachtzugsfenster-Auren"
L["Class Icon Text Size"] = "Textgröße Klassensymbol"
L["DR Cooldown Text Size"] = "Textgröße DR-Abklingzeit"
L["Alerts / Trackers / Custom Auras Text Size"] = "Textgröße Warnungen / Tracker / benutzerdefinierte Auren"
L["Trinket / Racial Text Size"] = "Textgröße Schmuckstück / Rasse"
L["Show Test Frames"] = "Testfenster anzeigen"
L["Hide Test Frames"] = "Testfenster ausblenden"
L["Show Swipe Animation"] = "Wischanimation anzeigen"
L["Shows the dark overlay that sweeps during a cooldown."] = "Zeigt die dunkle Überlagerung an, die während einer Abklingzeit durchläuft."
L["Swipe Shade Alpha"] = "Deckkraft der Wischabdunklung"
L["0% = transparent, 100% = full dark."] = "0 % = transparent, 100 % = vollständig dunkel."
L["Reverse Swipe"] = "Wischrichtung umkehren"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "Kehrt die Wischrichtung um, sodass sich die Abdunklung in die entgegengesetzte Richtung füllt."
L["Hide Charge Timers"] = "Ladungstimer ausblenden"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "Blendet Timer aus, während Aufladungen sich erneuern (zeigt Timer nur, wenn alle Aufladungen verbraucht sind)."
L["Hide Stack Text"] = "Stapeltext ausblenden"
L["Hide stacks and charges entirely."] = "Blendet Stapel und Aufladungen vollständig aus."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "Die Text-Einstellungen von MiniAuras sind nach Modulfamilie gruppiert, sodass ähnliche Widgets dieselbe Countdown-Größe teilen."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "Gilt für das MiniAuras-CC-Modul (gegnerische Kontrolleffekte)."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "Gilt für die MiniAuras-Module CC, Friendly CDs und Friendly Indicators."
L["Applies to the MiniAuras Raid Frame Auras module."] = "Gilt für das MiniAuras-Modul Raid Frame Auras."
L["Applies to MiniAuras portrait icons."] = "Gilt für die Porträtsymbole von MiniAuras."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "Gilt für die MiniAuras-Module Alerts, Healer CC, Kick Timer, Precognition, Trinkets und Custom Auras."
L["Show sArena test frames using /sarena test."] = "Zeigt die sArena-Testfenster mit /sarena test."
L["Hide sArena test frames using /sarena hide."] = "Blendet die sArena-Testfenster mit /sarena hide aus."

-- Import / Export
L["Import string is too large."] = "Die Importzeichenfolge ist zu groß."
L["Import profile contains invalid data."] = "Das importierte Profil enthält ungültige Daten."
L["Failed to apply imported profile."] = "Das importierte Profil konnte nicht angewendet werden."

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "Einige Änderungen erfordern ein Neuladen der Benutzeroberfläche, um vollständig wirksam zu werden.\n\nOberfläche jetzt neu laden?"

-- Addon Integrations
L["Addon Integrations"] = "Addon-Integrationen"
L["ADDON_INTEGRATIONS_DESC"] = "Aktiviert oder deaktiviert optionale Addon-Brücken, die externe Abklingzeiten in MiniCE-Kategorien einbinden."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "Leitet die Abklingzeiten von ShinyAuras über die Kategorie Einheitenfenster. Deaktiviere dies, wenn ShinyAuras seine nativen Countdowns unverändert behalten soll."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "Leitet unterstützte Dominos-Aktionsleisten-Abklingzeiten über die Kategorie Aktionsleisten. Deaktiviere dies, wenn Dominos sein natives Abklingzeit-Styling unverändert behalten soll."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "Leitet unterstützte Bartender4-Aktionsleisten-Abklingzeiten über die Kategorie Aktionsleisten. Deaktiviere dies, wenn Bartender4 sein natives Abklingzeit-Styling unverändert behalten soll."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "Leitet unterstützte Abklingzeiten von ElvUI-Aktionsleisten, Einheitenfenstern und Namensplaketten über MiniCE-Kategorien. Deaktiviere dies, wenn ElvUI sein natives Abklingzeit-Styling unverändert behalten soll."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered stylt außerdem %s. Dies kann einen geringen Leistungsaufwand verursachen. Deaktiviere die CMC-Timerschriftarten, wenn MiniCE der alleinige Verwalter dieser Anzeige-Timer bleiben soll."

-- Help
L["HELP_ARENADR_DESC"] = "Verfolgt gegnerische diminishing Returns direkt auf Namensplaketten in der Arena."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "Kopiere diesen Link, um ArenaDR Nameplates auf CurseForge zu öffnen."

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames ist aktiv. Daher wurde MiniCE-Styling für Einheitenfenster deaktiviert, um mögliche Konflikte zu vermeiden. Ein eigener BetterBlizzFrames-Adapter folgt in Kürze."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates ist aktiv. Daher wurde MiniCE-Styling für Namensplaketten deaktiviert, um mögliche Konflikte zu vermeiden."
L["PLAYERAURA_DESC"] = "Gestalte die Buff- und Debuff-Abklingzeiten des Blizzard-Spielers."
L["HEALERCC_DESC"] = "Gestalte freundliche und gegnerische HealerCC-Warnungs-Abklingzeiten."
L["MYDRS_DESC"] = "Gestalte die Symbol-Abklingzeiten der diminishing Returns von MyDRs. MyDRs behält seine eigene DR-Statusanzeige (50 % / IMM)."
L["SARENA_DESC"] = "Gestalte die Abklingzeit-Timer von sArena_Reloaded."
L["TELLMEWHEN_DESC"] = "Gestalte den Abklingzeit-Text und die Wischkanten von TellMeWhen."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "Timer-Sichtbarkeit, Timer-Text, Abdunklungsrichtung und GCD-Anzeige bleiben weiterhin von TellMeWhen gesteuert. Sichtbarkeit und Dicke der Wischkante werden hier gesteuert."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Skaliert die Wischkante von TellMeWhen, wenn MiniCE sie aktiviert hat."

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "Schwellenfarben erlauben"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "Erlaubt es den globalen Schwellenwerten von \"Nach verbleibender Zeit färben\", die statische Textfarbe dieser Kategorie zu überschreiben."
L["Behavior"] = "Verhalten"
L["Advanced Threshold Settings"] = "Erweiterte Schwellenwert-Einstellungen"
L["Threshold Colors"] = "Schwellenfarben"
L["THRESHOLD_COLORS_DESC"] = "Jeder Bereich legt den Grenzwert und die Farbe für diese Restzeitspanne fest."
L["Threshold Transition Offset"] = "Übergangsversatz der Schwellenwerte"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "Verschiebt den Beginn jedes nächsten Farbbereichs. Negative Werte wechseln etwas früher."
L["Beyond Thresholds Color"] = "Farbe über den Schwellenwerten"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "Zehntel anzeigen unter (Sekunden)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "Abklingzeit-Zahlen unter diesem Schwellenwert zeigen eine Dezimalstelle (z. B. 8,7). Auf 0 setzen zum Deaktivieren."

-- Performance Warning
L["PERF_WARNING_DESC"] = "Diese Funktion kann die Leistung beeinträchtigen und FPS-Einbrüche verursachen. Nur auf leistungsstarken Systemen verwenden."

-- Font Options
L["Game Default"] = "Spielstandard"
