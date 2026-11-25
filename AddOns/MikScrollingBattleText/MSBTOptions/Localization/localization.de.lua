
if (GetLocale() ~= "deDE") then return end

local L = MikSBT.translations



L.MSG_NEW_PROFILE					= "Neues Profil"
L.MSG_PROFILE_ALREADY_EXISTS		= "Profil existiert bereits."
L.MSG_INVALID_PROFILE_NAME			= "Ungültiger Profilname."
L.MSG_NEW_SCROLL_AREA				= "Neuer Scroll-Bereich"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Name für Scroll-Bereich existiert bereits."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Ungültiger Name für Scroll-Bereich."
L.MSG_ACKNOWLEDGE_TEXT				= "Bist du sicher, dass du diese Aktion durchführen willst?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Normal"
L.MSG_DISPLAY_QUALITY				= "Zeige Benachrichtigungen für Gegenstände dieser Qualtität."
L.MSG_ITEM_QUALITIES				= "Gegenstandsqualitäten"
L.MSG_ITEMS							= "Gegenstände"
L.MSG_ITEM_ALREADY_EXISTS			= "Gegenstandsname exisiert bereits."
L.MSG_INVALID_ITEM_NAME				= "Ungültiger Gegenstandsname."
L.MSG_CLASSIC_DESIGN				= "Klassisch"
L.MSG_FOREVER_DESIGN				= "Forever"
L.MSG_DESIGN_ASK_RELOAD				= "Das Optionsfenster des Spiels zeigt das neue Design erst nach dem Neuladen der Oberfläche. Jetzt neu laden?"

obj = L.WINDOW
obj.subtitle = "Optionen \194\183 %s"
obj.groupDisplay = "Anzeige"
obj.groupEvents = "Ereignisse"
obj.groupMore = "Weiteres"
obj.incoming = "Eingehend"
obj.incomingHint = "Was andere dir antun: Schaden, Heilung, Fehlschläge."
obj.outgoing = "Ausgehend"
obj.outgoingHint = "Was du anderen antust: Schaden, Heilung, Fehlschläge."
obj.pet = "Begleiter"
obj.petHint = "Was dein Begleiter tut und was ihm angetan wird."
obj.notifications = "Benachrichtigungen"
obj.notificationsHint = "Stärkungen, Schwächungen, Ressourcen, Procs und andere Hinweise."
obj.changes = "Änderungen"
obj.changesHint = "Jede seit dem Login geänderte Einstellung. Einzeln oder alle rückgängig machen."
obj.changesCount = "Änderungen seit Login: %d"
obj.noChanges = "Keine Änderungen seit Login."
obj.cancel = "Abbrechen"
obj.cancelTooltip = "Stellt die Einstellungen vom Öffnen oder vom letzten Übernehmen wieder her und schließt das Fenster."
obj.apply = "Übernehmen"
obj.applyTooltip = "Behält die Änderungen. Abbrechen kehrt ab jetzt zu diesem Stand zurück."
obj.undo = "Zurück"
obj.undoTooltip = "Setzt diese Einstellung auf ihren Wert beim Login zurück."
obj.undoSelectedProfileTooltip = "Wählt das Profil vom Login und stellt es wieder her, falls es gelöscht wurde."
obj.designSwitchPending = "Übernimm oder verwirf deine Änderungen, bevor du das Optionsdesign wechselst."
obj.applyAndSwitch = "Übernehmen und wechseln"
obj.discardAndSwitch = "Verwerfen und wechseln"
obj.undoAll = "Alles zurück"
obj.undoAllTooltip = "Setzt jede Einstellung auf ihren Wert beim Login zurück."
obj.allOn = "Alle an"
obj.allOnTooltip = "Schaltet jedes Ereignis dieser Seite ein."
obj.allOff = "Alle aus"
obj.allOffTooltip = "Schaltet jedes Ereignis dieser Seite aus."
obj.columnOn = "An"
obj.columnEvent = "Ereignis"
obj.columnPreview = "Vorschau"
obj.columnArea = "Bereich"
obj.color = "Farbe"
obj.sampleName = "Jemand"
obj.sampleSkill = "Fähigkeit"
obj.sampleItem = "Trank"
obj.sampleMoney = "1 Gold 23 Silber"
obj.columnSound = "Sound"
obj.headerMelee = "Nahkampf"
obj.headerRanged = "Fernkampf"
obj.headerSpells = "Zauber"
obj.headerHealing = "Heilung"
obj.headerOther = "Weiteres"
obj.resources = "Ressourcen"
obj.resourcesTooltip = "Wählt, welche Ressourcen \"Resource Gains\" anzeigt."
obj.font = "Schrift"
obj.fontTooltip = "Zurück zur Schrift dieses Ereignisses."
obj.scrollAreasHint = "Wo der Text erscheint und wie er sich bewegt. Einen Bereich in der Skizze ziehen, um ihn zu verschieben."
obj.onScreen = "Auf dem Bildschirm einstellen"
obj.onScreenTooltip = "Blendet dieses Fenster aus und verschiebt die Scroll-Bereiche auf dem Spielbildschirm."
obj.resizeTooltip = "Ziehen, um das Fenster zu vergrößern oder zu verkleinern. Rechtsklick stellt die Größe zurück."

obj = L.WINDOW
obj.fontsColors = "Schriften & Farben"
obj.fontsColorsHint = "Schriften, Teileffekte und Farben, die Ereignisse und Scroll-Bereiche erben."
obj.search = "Ereignissuche"
obj.searchTooltip = "Einen Teil eines Ereignisnamens eingeben, um passende Ereignisse aller Kategorien aufzulisten."
obj.searchHint = "Ereignisse aller Kategorien, deren Name den Suchtext enthält."
obj.edit = "Bearbeiten"
obj.add = "Hinzufügen"
obj.currentProfile = "Aktuelles Profil: %s"
obj.soundsHint = "Ereignis-Sounds einschalten und eigene Sounddateien hinzufügen."
obj.profileHint = "Profile kopieren, zurücksetzen, löschen, exportieren und importieren."
obj.noSounds = "Noch keine eigenen Sounds."
obj.remove = "Entfernen"
obj.removeTooltip = "Entfernt diesen Sound aus deinen gespeicherten Sounds. Bis zum nächsten Neuladen bleibt er wählbar und abspielbar, hier und in anderen Addons; erneutes Hinzufügen ersetzt ihn in MSBT."
obj.resetProfile = "Profil zurücksetzen"
obj.blizzardOnMe = "Text über mir"
obj.blizzardOnTarget = "Text auf Ziel"
obj.blizzardIncomingTooltip = "Blizzards Text für das, was andere dir antun: Schaden, Heilung, Fehlschläge."
obj.blizzardNotificationsTooltip = "Alles andere, was Blizzards Text an deiner Spielfigur zeigt, etwa Auren, Kampfbeginn und Zugewinne."
obj.blizzardNumbers = "Zahlen"
obj.blizzardNumbersTooltip = "Blizzards Schadens- und Heilungszahlen über deinen Zielen."



obj = L.TABS
obj["general"]		= { label="Allgemein", tooltip="Allgemeine Optionen anzeigen."}
obj["scrollAreas"]	= { label="Scroll-Bereiche", tooltip="Optionen für das Erstellen, Löschen, und Konfigurieren der Scroll-Bereiche anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["events"]		= { label="Ereignisse", tooltip="Optionen für eingehende, ausgehende und benachrichtigende Ereignisse anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["lootAlerts"]	= { label="Plündernachrichten", tooltip="Optionen für die Plünderbenachrichtigung anzeigen."}



obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Mik's Scrolling Battle Text aktivieren", tooltip="MSBT aktivieren."}
obj["disableMSBTInGroup"]		= { label="MSBT in Gruppen deaktivieren", tooltip="MSBT automatisch in Gruppe oder Schlachtzug deaktivieren."}
obj["stickyCrits"]				= { label="Sticky-Krits", tooltip="Bei kritischen Treffern den 'Sticky'-Stil verwenden."}
obj["colorPartialEffects"]		= { label="Teileffekte einfärben", tooltip="Fügt den Teileffekten festgelegte Farben hinzu."}
obj["crushing"]					= { label="Schmetternde Stöße", tooltip="Zeigt den Anhang bei schmetternden Treffern an."}
obj["glancing"]					= { label="Streifende Treffer", tooltip="Zeigt den Anhang bei streifenden Treffern an."}
obj["absorb"]					= { label="Teilweise absorbiert", tooltip="Zeigt die zum Teil absobierte Menge an."}
obj["block"]					= { label="Teilweise geblockt", tooltip="Zeigt die zum Teil geblockte Menge an."}
obj["resist"]					= { label="Teilweise widerstanden", tooltip="Zeigt die zum Teil widerstandene Menge an."}
obj["vulnerability"]			= { label="Verwundbarkeitsboni", tooltip="Zeigt die Menge der Verwundbarkeitsboni an."}
obj["overheal"]					= { label="Überheilung", tooltip="Zeigt die Menge der Überheilung an."}
obj["overkill"]					= { label="Über Tod", tooltip="Zeigt die Menge des Schadens über Tod an."}
obj["colorUnitNames"]			= { label="Farbige Namen", tooltip="Färbt die Namen in Klassenfarbe ein."}
obj["colorClassEntry"]			= { tooltip="Aktiviert Farbe für diese Klasse."}
obj["enableScrollArea"]			= { tooltip="Scroll-Bereich aktivieren."}
obj["mergePetScrollArea"]		= { label="Mit %s zusammenführen", shortLabel="Zusammenführen", tooltip="Zeigt die Ereignisse dieses Begleiterbereichs unter %s an, wenn der Begleiterbereich deaktiviert ist."}
obj["inheritField"]				= { label="Übernehmen", tooltip="Übernimmt die eingegebenen Werte.\n\nHacken entfernen, um zu überschreiben."}
obj["inheritValue"]				= { label="Erben", tooltip="Erbt den Wert der übergeordneten Einstellung.\n\nHaken entfernen, um ihn zu überschreiben."}
obj["hideSkillIcons"]			= { label="Symbole verstecken", tooltip="Keine Symbole in diesem Scroll-Bereich anzeigen."}
obj["stickyEvent"]				= { label="Sticky-Stil verwenden", tooltip="Ereignis immer im 'Sticky'-Stil anzeigen."}
obj["enableTrigger"]			= { tooltip="Auslöser aktivieren."}
obj["allPowerGains"]			= { label="ALLE Regenerationen", tooltip="Zeigt alle Ressourcenregenerationen einschließlich derjenigen, die nicht im Kampflog gemeldet werden.\n\nWARNUNG: Diese Einstellung führt zu viel Spam, da sie alle Grenzwerte und Drosselfunktionen ignoriert.\n\nNICHT EMPFOHLEN."}
obj["abbreviateSkills"]			= { label="Fähigkeiten abkürzen", tooltip="Fähigkeiten abkürzen (nur Englisch).\n\nDies kann von jedem Ereignis mit dem %sl Code überschrieben werden."}
obj["mergeSwings"]				= { label="Schwünge verbinden", tooltip="Verbindet normale Meleetreffer, die in einer kurzen Zeitspanne erfolgen."}
obj["hideSkills"]				= { label="Fähigkeiten verstecken", tooltip="Keine Fähigkeitsnamen für eingehende und ausgehende Ereignisse anzeigen.\n\nDu gibst ein wenig Anpassungsmöglichkeit auf Ereignisebene auf, da der Ereigniscode %s nun ignoriert wird."}
obj["hideNames"]				= { label="Namen verstecken", tooltip="Keine Namen für eingehende und ausgehende Ereignisse anzeigen.\n\nDu gibst ein wenig Anpassungsmöglichkeit auf Ereignisebene auf, da der Ereigniscode %n nun ignoriert wird."}
obj["hideFullOverheals"]		= { label="Überheilungen verstecken", tooltip="Heilungen, die eine effektive Heilung von null haben, werden nicht angezeigt."}
obj["hideMergeTrailer"]			= { label="Verbinden-Anhang verstecken", tooltip="Der Anhang, der die Anzahl der miteinander verbundenen Treffer und Krits am Ende jedes Ereignisses darstellt, wird nicht angezeigt."}
obj["lootedItems"]				= { label="Geplünderte Gegenstände", tooltip="Zeigt Benachrichtigungen, wenn Gegenstände geplündert wurden."}
obj["moneyGains"]				= { label="Gold erhalten", tooltip="Zeigt Benachrichtigungen, wenn Gold erhalten wurde."}
obj["alwaysShowQuestItems"]		= { label="Questgegenstände immer anzeigen", tooltip="Questgegenstände immer anzeigen, unabhängig der ausgewählten Qualitäten."}
obj["enableIcons"]				= { label="Fähigkeitssymbole aktivieren", tooltip="Zeigt, wenn möglich, Symbole für Ereignisse an."}



obj = L.DROPDOWNS
obj["profile"]				= { label="Aktuelles Profil:", tooltip="Legt das aktuelle Profil fest."}
obj["normalFont"]			= { label="Schrift - Normal:", tooltip="Legt die Schriftart für nicht-kritische Treffer."}
obj["critFont"]				= { label="Schrift - Kritisch:", tooltip="Legt die Schriftart für kritische Treffer."}
obj["normalOutline"]		= { label="Kontur - Normal:", tooltip="Legt die Kontur für nicht-kritische Treffer."}
obj["critOutline"]			= { label="Kontur - Kritisch:", tooltip="Legt die Kontur für kritische Treffer."}
obj["scrollArea"]			= { label="Scroll-Bereich:", tooltip="Wählt den zu konfigurierenden Scroll-Bereich aus."}
obj["animationStyle"]		= { label="Animationen:", tooltip="Der Animationsstil für Nicht-'Sticky'-Animationen in dem Scroll-Bereich."}
obj["stickyAnimationStyle"]	= { label="Sticky Animationen:", tooltip="Der Animationsstil für 'Sticky'-Animationen in dem Scroll-Bereich."}
obj["direction"]			= { label="Richtung:", tooltip="Die Richtung der Animation."}
obj["behavior"]				= { label="Verhalten:", tooltip="Das Verhalten der Animation."}
obj["textAlign"]			= { label="Text ausrichten:", tooltip="Die Ausrichtung des Textes für die Animation."}
obj["iconAlign"]			= { label="Symbol ausrichten:", tooltip="Die Ausrichtung des Symbols für die Animation."}
obj["eventCategory"]		= { label="Ereigniskategorie:", tooltip="Die Kategorie der zu konfigurienden Ereignisse."}
obj["outputScrollArea"]		= { label="Scroll-Bereich:", tooltip="Den Scroll-Bereich für die Textausgabe auswählen."}
obj["optionsDesign"]		= { label="Optionen-Design:", tooltip="Wählt das Optionsfenster, das /msbt öffnet."}



obj = L.BUTTONS
obj["copyProfile"]				= { label="Kopieren", tooltip="Kopiert das aktuelle Profil auf ein neues Profil, dessen Namen du selbst bestimmst."}
obj["resetProfile"]				= { label="Zurücksetzen", tooltip="Setzt das Profil auf die Standardeinstellungen zurück."}
obj["deleteProfile"]			= { label="Löschen", tooltip="Löscht das Profil."}
obj["masterFont"]				= { label="Master Schrift", tooltip="Erlaubt dir die Master Schrift festzulegen, welche bei allen Scroll-Bereichen und Ereignissen übernommen wird, sofern sie nicht überschrieben wird."}
obj["partialEffects"]			= { label="Partielle Effekte", tooltip="Erlaubt dir festzulegen, welche partiellen Effekte angezeigt werden sollen, ob sie eingefärbt werden sollen, und wenn ja in welcher Farbe."}
obj["damageColors"]				= { label="Schaden Farben", tooltip="Legt die Farben für die einzelnen Schadensarten fest."}
obj["classColors"]				= { label="Klassen Farben", tooltip="Erlaubt dir festzulegen, ob die Namen nach Klassenfarbe eingefärbt werden sollen oder welche Farbe für jede Klasse verwendet werden soll." }
obj["inputOkay"]				= { label=OKAY, tooltip="Eingaben übernehmen."}
obj["inputCancel"]				= { label=CANCEL, tooltip="Eingaben zurücksetzen."}
obj["genericSave"]				= { label=SAVE, tooltip="Speichert die Änderungen."}
obj["genericCancel"]			= { label=CANCEL, tooltip="Setzt die Änderungen zurück."}
obj["addScrollArea"]			= { label="Neuer Scroll-Bereich", tooltip="Einen neuen Scroll-Bereich auswählen, dem Ereignisse und Auslöser zugewiesen werden können."}
obj["configScrollAreas"]		= { label="Scroll-Bereiche konfigurieren", tooltip="Konfiguriert die normalen und Sticky-Styles, Text-Ausrichtung, Scroll Weite/Höhe und Position der Scroll-Bereiche."}
obj["editScrollAreaName"]		= { tooltip="Klicken, um den Namen des Scroll-Bereichs zu bearbeiten."}
obj["scrollAreaFontSettings"]	= { tooltip="Klicken, um die Schrifteinstellungen des Scroll-Bereichs zu bearbeiten, welche von allen Ereignissen dieses Bereichs übernommen werden, sofern sie nicht überschrieben werden."}
obj["deleteScrollArea"]			= { tooltip="Klicken, um den Scroll-Bereich zu löschen."}
obj["scrollAreasPreview"]		= { label="Vorschau", tooltip="Eine Vorschau auf die Änderungen."}
obj["toggleAll"]				= { label="Alle umschalten", tooltip="Die Aktivierung aller Ereignisse in der ausgewählten Kategorie umschalten."}
obj["moveAll"]					= { label="Alle verschieben", tooltip="Verschiebt alle Ereignisse in der ausgewählten Kategorie zu dem ausgewählten Scroll-Bereich."}
obj["eventFontSettings"]		= { tooltip="Klicken, um die Schrifteinstellungen für dieses Ereignis zu bearbeiten."}
obj["eventSettings"]			= { tooltip="Klicken, um die Ereigniseinstellungen wie Scroll-Bereich, Text, Sound, etc. zu bearbeiten."}
obj["itemsAllowed"]				= { label="Gegenstände erlauben", tooltip="Festgelegte Gegenstände unabhängig der Gegenstandsqualität immer anzeigen."}
obj["itemExclusions"]			= { label="Gegenstände ignorieren", tooltip="Verhindert, dass festgelegte Gegenstände angezeigt werden."}
obj["addItem"]					= { label="Gegenstand hinzufügen", tooltip="Neuen Gegenstand zur Liste hinzufügen."}
obj["deleteItem"]				= { tooltip="Klicken, um Gegenstand zu entfernen."}



obj = L.EDITBOXES
obj["copyProfile"]		= { label="Neuer Profilname:", tooltip="Der Name des neuen Profils auf den das eben gewählte Profil kopiert werden soll."}
obj["partialEffect"]	= { tooltip="Der Trailer, der angehängt wird wenn der Partielle Effekte erscheint."}
obj["scrollAreaName"]	= { label="Neuen Scroll-Bereich-Namen eingeben:", tooltip="Neuer Name für den Scroll-Bereich."}
obj["xOffset"]			= { label="X-Achse:", tooltip="Die X-Achse des ausgewählten Scroll-Bereichs."}
obj["yOffset"]			= { label="Y-Achse:", tooltip="Die Y-Achse des ausgewählten Scroll-Bereichs."}
obj["eventMessage"]		= { label="Ausgabenachricht eingeben:", tooltip="Die Nachricht die angezeigt wird, wenn das Ereignis auftritt."}
obj["iconSkill"]		= { label="Fähigkeitssymbol:", tooltip="Der Name oder Spell-ID des Zaubers mit dem Symbol das angezeigt wird, wenn das Ereignis auftritt.\n\nMSBT wird versuchen, automatisch ein Symbol auszuwählen, wenn keines festgelegt wurde.\n\nNOTIZ: Eine Spell-ID muss anstatt einem Namen benutzt werden, wenn die Fähigkeit nicht im Zauberbuch für die Klasse, die gespielt wird, während das Ereignis auftritt, ist. Die meisten Datenbanken wie z.B. Wowhead Dir dabei helfen."}
obj["itemName"]			= { label="Gegenstandsname:", tooltip="Name des Gegenstandes, der hinzugefügt werden soll."}


obj = L.SLIDERS
obj["animationSpeed"]		= { label="Animationsgeschwindigkeit", tooltip="Die Master-Geschwindigkeit der Animation."}
obj["normalFontSize"]		= { label="Normale Schriftgröße", tooltip="Die Schriftgröße für nicht-kritische Treffer."}
obj["normalFontOpacity"]	= { label="Normale Transparenz", tooltip="Die Schrifttransparenz für nicht-kritische Treffer."}
obj["critFontSize"]			= { label="Kritische Schriftgröße", tooltip="Die Schriftgröße für kritische Treffer."}
obj["critFontOpacity"]		= { label="Kritische Transparenz", tooltip="Die Schrifttransparenz für kritische Treffer."}
obj["scrollHeight"]			= { label="Scroll-Höhe", tooltip="Die Höhe des Scroll-Bereichs."}
obj["scrollWidth"]			= { label="Scroll-Weite", tooltip="Die Weite des Scroll-Bereichs."}
obj["scrollAnimationSpeed"]	= { label="Geschwindigkeit", tooltip="Die Geschwindigkeit der Animation des Scroll-Bereichs."}
obj["dotThrottleTime"]		= { label="DoTs drosseln", tooltip="Die Nummer in Sekunden, die DoTs gedrosselt werden sollen."}
obj["hotThrottleTime"]		= { label="HoTs drosseln", tooltip="Die Nummer in Sekunden, die HoTs gedrosselt werden sollen."}
obj["powerThrottleTime"]	= { label="Energie drosseln", tooltip="Die Nummer in Sekunden, die Energieänderungen gedrosselt werden sollen."}


obj = L.EVENT_CATEGORIES
obj[1] = "Eingehend Spieler"
obj[2] = "Eingehend Begleiter"
obj[3] = "Ausgehend Spieler"
obj[4] = "Ausgehend Begleiter"
obj[5] = "Benachrichtigung"



obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Menge des erhaltenen Schadens.\n"
obj["HEALING_TAKEN"]		= "%a - Menge der erhaltenen Heilung.\n"
obj["DAMAGE_DONE"]			= "%a - Menge des Schadens.\n"
obj["HEALING_DONE"]			= "%a - Geheilte Menge.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Menge des absobierten Schadens.\n"
obj["AURA_AMOUNT"]			= "%a - Menge der Stapel für eine Aura.\n"
obj["SHADOW_ORBS_AMOUNT"]	= "%a - Menge der Schattenkugeln, die du hast.\n"
obj["HONOR_AMOUNT"]			= "%a - Menge der Ehre.\n"
obj["REP_AMOUNT"]			= "%a - Menge des Rufs.\n"
obj["ITEM_AMOUNT"]			= "%a - Menge des geplünderten Gegenstands.\n"
obj["SKILL_AMOUNT"]			= "%a - Menge der Punkte, die du in der Fähigkeit hast.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Menge der erhaltenen Erfahrung.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Menge des partiellen Effekts.\n"
obj["ATTACKER_NAME"]		= "%n - Name des Angreifers.\n"
obj["HEALER_NAME"]			= "%n - Name des Heilers.\n"
obj["ATTACKED_NAME"]		= "%n - Name der angegriffenen Einheit.\n"
obj["HEALED_NAME"]			= "%n - Name der geheilten Einheit.\n"
obj["BUFFED_NAME"]			= "%n - Name der gebufften Einheit.\n"
obj["UNIT_KILLED"]			= "%n - Name der getöteten Einheit.\n"
obj["SKILL_NAME"]			= "%s - Name der Fähigkeit.\n"
obj["SPELL_NAME"]			= "%s - Name des Zaubers.\n"
obj["DEBUFF_NAME"]			= "%s - Name des Debuffs.\n"
obj["BUFF_NAME"]			= "%s - Name des Buffs\n"
obj["ITEM_BUFF_NAME"]		= "%s - Name des Gegenstands-Buffs.\n"
obj["ITEM_COOLDOWN_NAME"]	= "%e - Name des Gegenstands, dessen Abklingzeit beendet ist.\n"
obj["EXTRA_ATTACKS"]		= "%s - Name der Fähigkeit, die Extraangriffe gewährt.\n"
obj["SKILL_LONG"]			= "%sl - Lange Form von %s. Wird benutzt, um Abkürzungen für das Ereignis zu überschreiben.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Art des erhaltenen Schadens.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Art des angerichteten Schadens.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Name der Schadensquelle (Fallen, Ertrinken, Lava, usw.).\n"
obj["FACTION_NAME"]			= "%e - Name der Fraktion.\n"
obj["EMOTE_TEXT"]			= "%e - Der Text der Geste.\n"
obj["MONEY_TEXT"]			= "%e - Der Text des erhaltenen Geldes.\n"
obj["ITEM_NAME"]			= "%e - Der Name des geplünderten Gegenstands.\n"
obj["TOTAL_ITEMS"]			= "%t - Gesamte Anzahl der geplünderten Gegenstände im Inventar."



obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert eingehende Melee-Treffer."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert eingehende Melee-Krits."}
obj["INCOMING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert eingehende Melee-Fehlschläge."}
obj["INCOMING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert eingehendes Melee-Ausweichen."}
obj["INCOMING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert eingehendes Melee-Parieren."}
obj["INCOMING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert eingehendes Melee-Blocken."}
obj["INCOMING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert eingehende Melee-Abwehr."}
obj["INCOMING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert eingehenden, absorbierten Meleeschaden."}
obj["INCOMING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert eingehenden Meleeschaden, gegen den du immun bist."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert eingehende Fähigkeitstreffer."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert eingehende Fähigkeitskrits."}
obj["INCOMING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert eingehenden Fähigkeitsschaden über Zeit."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert eingehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert eingehenden Schaden durch Schadensschilde."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert eingehenden, kritischen Schaden durch Schadensschilde."}
obj["INCOMING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert eingehende Fähigkeits-Fehlschläge."}
obj["INCOMING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert eingehendes Fähigkeits-Ausweichen."}
obj["INCOMING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert eingehendes Fähigkeits-Parieren."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert eingehendes Fähigkeits-Blocken."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert eingehende Fähigkeits-Abwehr."}
obj["INCOMING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert eingehendes Widerstehen von Fähigkeiten."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert eingehenden, absorbierten Fähigkeitsschaden."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert eingehenden Fähigkeitsschaden, gegen den du immun bist."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Fähigkeit: Reflektieren", tooltip="Aktiviert eingehende Reflektionen von Fähigkeitsschaden."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert eingehende Fähigkeitsunterbrechungen."}
obj["INCOMING_HEAL"]						= { label="Heilung", tooltip="Aktiviert eingehende Heilungen."}
obj["INCOMING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert eingehende, kritische Heilungen."}
obj["INCOMING_HOT"]							= { label="HoT", tooltip="Aktiviert eingehende Heilungen über Zeit."}
obj["INCOMING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert eingehende, kritische Heilungen über Zeit."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Umwelt-Schaden", tooltip="Aktiviert Umwelt-Schaden (Fallen, Ertrinken, Lava, usw.)."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert für Begleiter eingehende Melee-Treffer."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert für Begleiter eingehende Melee-Krits."}
obj["PET_INCOMING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert für Begleiter eingehende Melee-Fehlschläge."}
obj["PET_INCOMING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert für Begleiter eingehendes Melee-Ausweichen."}
obj["PET_INCOMING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert für Begleiter eingehendes Melee-Parieren."}
obj["PET_INCOMING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert für Begleiter eingehendes Melee-Blocken."}
obj["PET_INCOMING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert für Begleiter eingehende Melee-Abwehr."}
obj["PET_INCOMING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert für Begleiter eingehenden, absorbierten Meleeschaden."}
obj["PET_INCOMING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert eingehenden Meleeschaden, gegen den dein Begleiter immun ist."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert für Begleiter eingehende Fähigkeitstreffer."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert für Begleiter eingehende Fähigkeitskrits."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert für Begleiter eingehenden Fähigkeitsschaden über Zeit."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert für Begleiter eingehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert für Begleiter eingehenden Schaden durch Schadensschilde."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert für Begleiter eingehenden, kritischen Schaden durch Schadensschilde."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert für Begleiter eingehende Fähigkeits-Fehlschläge."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Ausweichen."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Parieren."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Blocken."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert für Begleiter eingehende Fähigkeits-Abwehr."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert für Begleiter eingehendes Widerstehen von Fähigkeiten."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert für Begleiter eingehenden, absorbierten Fähigkeitsschaden."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert eingehenden Fähigkeitsschaden, gegen den dein Begleiter immun ist."}
obj["PET_INCOMING_HEAL"]						= { label="Heilung", tooltip="Aktiviert für Begleiter eingehende Heilungen."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert für Begleiter eingehende, kritische Heilungen."}
obj["PET_INCOMING_HOT"]							= { label="HoT", tooltip="Aktiviert für Begleiter eingehende Heilungen über Zeit."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert für Begleiter eingehende, kritische Heilungen über Zeit."}



obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert ausgehende Melee-Treffer."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert ausgehende Melee-Krits."}
obj["OUTGOING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert ausgehende Melee-Fehlschläge."}
obj["OUTGOING_RANGED_DAMAGE"] = {
	label = "Fernkampf: Treffer",
	tooltip = "Zeigt Treffer mit automatischen Fernkampfangriffen und Zauberstäben.",
}
obj["OUTGOING_RANGED_DAMAGE_CRIT"] = {
	label = "Fernkampf: Krit",
	tooltip = "Zeigt kritische Treffer mit automatischen Fernkampfangriffen und Zauberstäben.",
}
obj["OUTGOING_RANGED_MISS"] = {
	label = "Fernkampf: Fehlschlag",
	tooltip = "Zeigt Fehlschläge mit automatischen Fernkampfangriffen und Zauberstäben.",
}
obj["OUTGOING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert ausgehendes Melee-Ausweichen."}
obj["OUTGOING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert ausgehendess Melee-Parieren."}
obj["OUTGOING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert ausgehendes Melee-Blocken."}
obj["OUTGOING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert ausgehende Melee-Abwehr."}
obj["OUTGOING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert ausgehenden, absorbierten Meleeschaden."}
obj["OUTGOING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert ausgehenden Meleeschaden, gegen den der Feind immun ist."}
obj["OUTGOING_EVADE"]						= { label="Melee: Entkommen", tooltip="Aktiviert ausgehendes Melee-Entkommen."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert ausgehende Fähigkeitstreffer."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert ausgehende Fähigkeitskrits."}
obj["OUTGOING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert ausgehenden Fähigkeitsschaden über Zeit."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert ausgehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert ausgehenden Schaden durch Schadensschilde."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert ausgehenden, kritischen Schaden durch Schadensschilde."}
obj["OUTGOING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert ausgehende Fähigkeits-Fehlschläge."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert ausgehendes Fähigkeits-Ausweichen."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert ausgehendes Fähigkeits-Parieren."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert ausgehendes Fähigkeits-Blocken."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert ausgehende Fähigkeits-Abwehr."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert ausgehendes Widerstehen von Fähigkeiten."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert ausgehenden, absorbierten Fähigkeitsschaden."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert ausgehenden Fähigkeitsschaden, gegen den der Feind immun ist."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Fähigkeit: Reflektieren", tooltip="Aktiviert Reflektionen von Fähigkeitsschaden, der zu dir zurückgeworfen wird."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert ausgehende Fähigkeitsunterbrechungen."}
obj["OUTGOING_SPELL_EVADE"]					= { label="Fähigkeit: Entkommen", tooltip="Aktiviert ausgehendes Fähigkeits-Entkommen."}
obj["OUTGOING_HEAL"]						= { label="Heilung", tooltip="Aktiviert ausgehende Heilungen."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert ausgehende, kritische Heilungen."}
obj["OUTGOING_HOT"]							= { label="HoT", tooltip="Aktiviert ausgehende Heilungen über Zeit."}
obj["OUTGOING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert ausgehende, kritische Heilungen über Zeit."}
obj["OUTGOING_DISPEL"]						= { label="Dispel", tooltip="Aktiviert ausgehende Entzauberungen."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert von Begleiter ausgehende Melee-Treffer."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert von Begleiter ausgehende Melee-Krits."}
obj["PET_OUTGOING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert von Begleiter ausgehende Melee-Fehlschläge."}
obj["PET_OUTGOING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert von Begleiter ausgehendes Melee-Ausweichen."}
obj["PET_OUTGOING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert von Begleiter ausgehendes Melee-Parieren."}
obj["PET_OUTGOING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert von Begleiter ausgehendes Melee-Blocken."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert von Begleiter ausgehende Melee-Abwehr."}
obj["PET_OUTGOING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert von Begleiter ausgehenden, absorbierten Meleeschaden."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert von Begleiter ausgehenden Meleeschaden, gegen den der Feind immun ist."}
obj["PET_OUTGOING_EVADE"]						= { label="Melee: Entkommen", tooltip="Aktiviert von Begleiter ausgehendes Melee-Entkommen."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitstreffer."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitskrits."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert von Begleiter ausgehenden Fähigkeitsschaden über Zeit."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT Kritisch", tooltip="Aktiviert von Begleiter ausgehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert ausgehenden Schaden durch Schadensschilde des Begleiters."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert ausgehenden, kritischen Schaden durch Schadensschilde des Begleiters."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert von Begleiter ausgehende Fähigkeits-Fehlschläge."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Ausweichen."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Parieren."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Blocken."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert von Begleiter ausgehende Fähigkeits-Abwehr."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert von Begleiter ausgehendes Widerstehen von Fähigkeiten."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert von Begleiter ausgehenden, absorbierten Fähigkeitsschaden."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert von Begleiter ausgehenden Fähigkeitsschaden, gegen den der Feind immun ist."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitsunterbrechungen."}
obj["PET_OUTGOING_HEAL"]						= { label="Heilung", tooltip="Aktiviert von Begleiter ausgehende Heilungen."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert von Begleiter ausgehende, kritische Heilungen."}
obj["PET_OUTGOING_HOT"]							= { label="HoT", tooltip="Aktiviert von Begleiter ausgehende Heilungen über Zeit."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert von Begleiter ausgehende, kritische Heilungen über Zeit."}
obj["PET_OUTGOING_DISPEL"]						= { label="Dispel", tooltip="Aktiviert von Begleiter ausgehende Entzauberungen."}



obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuffs", tooltip="Aktiviert Debuffs, wenn du betroffen bist."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Debuff-Stapel", tooltip="Aktiviert Debuff-Stapel, wenn du betroffen bist."}
obj["NOTIFICATION_BUFF"]				= { label="Buffs", tooltip="Aktiviert Buffs, die du erhälst."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Buff-Stacks", tooltip="Aktiviert Buff-Stapel, die du erhälst."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Gegenstands-Buffs", tooltip="Aktiviert Buffs, die ein Gegenstand erhält."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Debuff verblasst", tooltip="Aktiviert Debuffs, die von dir verblassen."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Buff verblasst", tooltip="Aktiviert Buffs, die von dir verblassen."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Gegenstands-Buff verblasst", tooltip="Aktiviert Gegenstands-Buffs, die von dir verblassen."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Kampfeintritt", tooltip="Aktiviert, wenn du in den Kampf eintrittst."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Kampfaustritt", tooltip="Aktiviert, wenn du in den Kampf verlässt."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Ehre erhalten", tooltip="Aktiviert, wenn du Ehre erhälst."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Ruf erhalten", tooltip="Aktiviert, wenn du Ruf erhälst."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Ruf verloren", tooltip="Aktiviert, wenn du Ruf verlierst."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Skillpunkt erhalten", tooltip="Aktiviert, wenn du einen Skillpunkt erhälst."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Erfahrung erhalten", tooltip="Aktiviert, wenn du Erfahrung erhälst."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Todesstoß Spieler", tooltip="Aktiviert, wenn du einen Todesstoß bei einem Spieler anbringst."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Todesstoß NPC", tooltip="Aktiviert, wenn du einen Todesstoß bei einem NPC anbringst."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Extraattacken", tooltip="Aktiviert, wenn du Extraattacken durch Windzorn, Schwertspezialisierung usw. erhälst."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Feind erhält Buff", tooltip="Aktiviert, wenn dein aktuelles, feindliches Ziel einen Buff erhält."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Monster Emotes", tooltip="Aktiviert Emotes, die dein aktuelles Ziel sagt."}



obj = L.OUTLINES
obj[1] = "Kein"
obj[2] = "Dünn"
obj[3] = "Dick"
obj[4] = "Monochrom"
obj[5] = "Monochrom + Dünn"
obj[6] = "Monochrom + Dick"

obj = L.TEXT_ALIGNS
obj[1] = "Links"
obj[2] = "Zentriert"
obj[3] = "Rechts"





obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Gewinkelt"
obj["Horizontal"]	= "Horizontale"
obj["Parabola"]		= "Parabel"
obj["Straight"]		= "Gerade"
obj["Static"]		= "Statisch"
obj["Pow"]			= "Pow"

obj["Alternate"]	= "Alternativ"
obj["Left"]			= "Links"
obj["Right"]		= "Rechts"
obj["Up"]			= "Aufwärts"
obj["Down"]			= "Abwärts"

obj["AngleUp"]		= "Winkel aufwärts"
obj["AngleDown"]	= "Winkel abwärts"
obj["GrowUp"]		= "Wachsen aufwärts"
obj["GrowDown"]		= "Wachsen abwärts"
obj["CurvedLeft"]	= "Gerundet Links"
obj["CurvedRight"]	= "Gerundet Rechts"
obj["Jiggle"]		= "Rütteln"
obj["Normal"]		= "Normal"

L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Ungültiger Sound-Name."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Sound-Name existiert bereits."
L.MSG_INVALID_SOUND_FILE			= "Sound muss eine .ogg Datei sein."
L.CHECKBOXES["enableSounds"]				= { label="Sounds aktivieren", tooltip="Sounds abspielen, die Ereignissen und Auslösern zugewiesen wurden."}
L.DROPDOWNS["sound"]				= { label="Sound:", tooltip="Wählt den Sound aus, der abgespielt werden soll, wenn das Ereignis erscheint."}
L.BUTTONS["addCustomSound"]			= { label="Sound hinzufügen", tooltip="Fügt einen benutzerdefinierten Sound zu der Liste der verfügbaren Sounds.\n\nWARNUNG: Die Datei muss in dem Ziel-Verzeichnis existieren, *BEVOR* WoW gestartet wurde.\n\nEs wird empfohlen, die Datei in den MikScrollingBattleText\\Sounds Ordner zu kopieren um Fehler zu vermeiden."}
L.BUTTONS["customSound"]				= { tooltip="Klicken, um eine benutzerdefinierte Sound-Datei auszuwählen." }
L.BUTTONS["playSound"]				= { label="Abspielen", tooltip="Klicken, um den ausgewählten Sound abzuspielen."}
L.BUTTONS["reloadDesign"]			= { label="Neu laden", tooltip="Das Optionsfenster des Spiels zeigt das gewählte Design erst nach dem Neuladen der Oberfläche."}
L.EDITBOXES["customSoundName"]	= { label="Sound Name:", tooltip="Der Name wird benutzt um den Sound zu identifizieren.\n\nBeispiel: Mein Sound"}
L.EDITBOXES["customSoundPath"]	= { label="Sound Pfad:", tooltip="Der Pfad zu der Sound Datei.\n\nNOTIZ: Wenn die Datei in dem empfohlenen MikScrollingBattleText\\Sounds Ordner ist, muss nur der Dateiname hier eingegeben werden anstatt der ganze Pfad.\n\nBeispiel: mySound.ogg "}
L.EDITBOXES["soundFile"]		= { label="Sound-Dateiname:", tooltip="Der Name der Sound Datei zum Abspielen wenn das Ereignis erscheint."}

-- Recent feature translations (2026-11-13).
L.POPUP_CONFIRM_TITLE = "Aktion bestätigen"
L.AURA_TRACKING_TITLE = "Eigene Auren stehen oben. Zum Ausblenden das Häkchen entfernen."
L.AURA_TRACKING_INPUT = "Zauber-ID oder Name der Aura"
L.AURA_TRACKING_ADD = "Aura hinzufügen"
L.AURA_TRACKING_HELP = "Der genaue angezeigte Name blendet Erhalt und Ablauf aller Ränge " ..
    "aus. Eine Zauber-ID betrifft nur diese ID. Namen genau prüfen. Wenn " ..
    "unterstützt, verbergen Namensregeln auch geschützten Aurentext und " ..
    "Symbole. Alle so geprüften geschützten Auren bleiben stumm. " ..
    "ID-Regeln benötigen eine lesbare Zauber-ID. Erneut anhaken, um die " ..
    "Aura anzuzeigen."
L.AURA_TRACKING_ALL_RANKS = "alle Ränge"
L.AURA_TRACKING_CHECKBOX = "Meldungen beim Erhalt und Ablauf dieser Aura anzeigen."
L.AURA_TRACKING_REMOVE = "Diese Regel entfernen und die Aura wieder normal verfolgen."
L.AURA_TRACKING_UNKNOWN = "Unbekannte Aura"
L.AURA_TRACKING_INVALID = "Eine gültige Zauber-ID oder den genauen angezeigten Namen eingeben."
L.RESOURCE_CHECKBOX_TITLE = "Ressourcen"
L.RESOURCE_CHECKBOX_HELP = "Zuwachs dieser Ressource anzeigen, wenn Klasse, Spezialisierung oder" ..
    " Gestalt sie verwendet."
L.RESOURCE_CHECKBOX_SOUND = "Ressourcentöne bleiben stumm, wenn verborgene Ressourcentypen " ..
    "gefiltert werden müssen."
L.RESOURCE_COMBO_POINT = "Combopunkt"
L.MSG_SOUND_PLAYBACK_FAILED = "Ton konnte nicht abgespielt werden. Dateipfad prüfen und WoW nach " ..
    "dem Hinzufügen neuer Audiodateien neu starten."
L.MSG_INVALID_SOUND_FILE = "Der Ton muss eine .mp3- oder .ogg-Datei sein."
L.LANGUAGE_CURRENT = "Aktuelle Spielsprache: %s (%s)"
L.LANGUAGE_INFO = "MSBT verwendet die Spielsprache. Für eine andere Sprache die " ..
    "Spieleinstellungen in Battle.net ändern und WoW neu starten."
L.RESET_BLIZZARD_INFO = "Blizzards Text für direkten, regelmäßigen und Begleiterschaden " ..
    "wiederherstellen. Dies aktiviert Blizzards Schadenstext und " ..
    "deaktiviert MSBT. Beide Optionen lassen sich unter Allgemein ändern."
L.MSG_BLIZZARD_TEXT_RESTORED = "Blizzards Kampftext wurde wiederhergestellt."

L.TABS.profile.label = "Profile"
L.TABS.profile.tooltip = "Profile verwalten und wechseln."
L.TABS.sounds.label = "Töne"
L.TABS.sounds.tooltip = "Ereignistöne einstellen und eigene Audiodateien hinzufügen."
L.TABS.language.label = "Sprache"
L.TABS.language.tooltip = "Aktuelle Spielsprache und Spracheinstellungen von MSBT anzeigen."
L.TABS.resetBlizzardSCT.label = "Blizzard-Kampftext zurücksetzen"
L.TABS.resetBlizzardSCT.tooltip = "Blizzards Schadenstext aktivieren und MSBT deaktivieren."

L.CHECKBOXES.enableMSBT.label = "Mik's Scrolling Battle Text aktivieren"
L.CHECKBOXES.enableMSBT.tooltip = "MSBT aktivieren und sämtlichen Blizzard-Kampftext deaktivieren."
L.CHECKBOXES.enableBlizzardDamage.label = "Blizzard-Kampftext aktivieren"
L.CHECKBOXES.enableBlizzardDamage.tooltip = "Blizzards Kampftext mit den unten gewählten Kategorien aktivieren."
L.CHECKBOXES.disableIncoming.label = "Eingehenden Text deaktivieren"
L.CHECKBOXES.disableIncoming.tooltip = "Eingehenden Schaden und Heilung für dieses System ausblenden."
L.CHECKBOXES.disableOutgoing.label = "Ausgehenden Text deaktivieren"
L.CHECKBOXES.disableOutgoing.tooltip = "Ausgehenden Schaden und Heilung für dieses System ausblenden."
L.CHECKBOXES.disableNotifications.label = "Benachrichtigungen deaktivieren"
L.CHECKBOXES.disableNotifications.tooltip = "Stärkungszauber, Kampfmeldungen und andere Hinweise dieses Systems " ..
    "ausblenden."
L.CHECKBOXES.enableNames.label = "Fähigkeitsnamen anzeigen"
L.CHECKBOXES.enableNames.tooltip = "Fähigkeitsnamen bei eingehenden und ausgehenden Ereignissen " ..
    "anzeigen."
L.CHECKBOXES.lowHealthSound.label = "Ton bei wenig Gesundheit"
L.CHECKBOXES.lowHealthSound.tooltip = "Warnsignal bei wenig Gesundheit abspielen, höchstens alle 10 " ..
    "Sekunden. Die Textwarnung bleibt auch ohne Häkchen sichtbar."
L.CHECKBOXES.lowManaSound.label = "Ton bei wenig Mana"
L.CHECKBOXES.lowManaSound.tooltip = "Warnsignal bei wenig Mana abspielen, höchstens alle 10 Sekunden. Die" ..
    " Textwarnung bleibt auch ohne Häkchen sichtbar."
L.CHECKBOXES.shortenNumbers.label = "Zahlen abkürzen"
L.CHECKBOXES.shortenNumbers.tooltip = "Zahlen abgekürzt anzeigen, etwa 32765 als 33k."
L.CHECKBOXES.groupNumbers.label = "Tausender gruppieren"
L.CHECKBOXES.groupNumbers.tooltip = "Zahlen mit Tausendertrennzeichen anzeigen, etwa 32765 als 32,765."
L.CHECKBOXES.stackSimilarHits.label = "Ähnliche Treffer zusammenfassen"
L.CHECKBOXES.stackSimilarHits.tooltip = "Bei wiederholten Treffern derselben Fähigkeit die Treffer- oder " ..
    "kritische Trefferzahl anhängen. Einzelne Treffer erhalten keinen " ..
    "Zähler."
L.CHECKBOXES.currencyGains.label = "Währungsgewinne"
L.CHECKBOXES.currencyGains.tooltip = "Meldungen für erhaltene Währung anzeigen."

L.BUTTONS.resetBlizzardSCT.label = "Blizzard-Kampftext zurücksetzen"
L.BUTTONS.resetBlizzardSCT.tooltip = "Blizzards Kampftexteinstellungen wiederherstellen und deren " ..
    "Überschreiben durch MSBT beenden."

L.NOTIFICATION_EVENTS.NOTIFICATION_RESOURCE_GAIN.label = "Ressourcenzuwachs"
L.NOTIFICATION_EVENTS.NOTIFICATION_RESOURCE_GAIN.tooltip = "Von Fähigkeiten und Effekten gemeldeten Ressourcenzuwachs anzeigen."
L.NOTIFICATION_EVENTS.NOTIFICATION_ITEM_COOLDOWN.label = "Gegenstand bereit"
L.NOTIFICATION_EVENTS.NOTIFICATION_ITEM_COOLDOWN.tooltip = "Melden, wenn die Abklingzeit eines benutzten Schmuckstücks oder " ..
    "Tranks endet."
L.NOTIFICATION_EVENTS.NOTIFICATION_CROWD_CONTROL.label = "Kontrolleffekte"
L.NOTIFICATION_EVENTS.NOTIFICATION_CROWD_CONTROL.tooltip = "Kontrolleffekte und Unterbrechungen anzeigen."
L.NOTIFICATION_EVENTS.NOTIFICATION_PROC.label = "Fähigkeitsauslösungen"
L.NOTIFICATION_EVENTS.NOTIFICATION_PROC.tooltip = "Hervorgehobene ausgelöste Fähigkeiten anzeigen."
L.NOTIFICATION_EVENTS.NOTIFICATION_REACTIVE.label = "Reaktive Fähigkeiten"
L.NOTIFICATION_EVENTS.NOTIFICATION_REACTIVE.tooltip = "Fähigkeiten anzeigen, die im Kampf verfügbar werden."
L.NOTIFICATION_EVENTS.NOTIFICATION_PC_KILLING_BLOW.label = "Todesstöße gegen Spieler"
L.NOTIFICATION_EVENTS.NOTIFICATION_PC_KILLING_BLOW.tooltip = "Todesstöße gegen feindliche Spieler melden."
L.NOTIFICATION_EVENTS.NOTIFICATION_NPC_KILLING_BLOW.label = "Todesstöße gegen NPCs"
L.NOTIFICATION_EVENTS.NOTIFICATION_NPC_KILLING_BLOW.tooltip = "Todesstöße gegen NPCs und Ziele unbekannten Typs anzeigen."

L.INCOMING_PLAYER_EVENTS.SELF_HEAL.label = "Selbstheilung"
L.INCOMING_PLAYER_EVENTS.SELF_HEAL.tooltip = "Heilung an dir selbst anzeigen."
L.INCOMING_PLAYER_EVENTS.SELF_HEAL_CRIT.label = "Kritische Selbstheilung"
L.INCOMING_PLAYER_EVENTS.SELF_HEAL_CRIT.tooltip = "Kritische Heilung an dir selbst anzeigen."
L.INCOMING_PLAYER_EVENTS.SELF_HOT.label = "Regelmäßige Selbstheilung"
L.INCOMING_PLAYER_EVENTS.SELF_HOT.tooltip = "Heilung über Zeit an dir selbst anzeigen."
L.INCOMING_PLAYER_EVENTS.SELF_HOT_CRIT.label = "Kritische regelmäßige Selbstheilung"
L.INCOMING_PLAYER_EVENTS.SELF_HOT_CRIT.tooltip = "Kritische Heilung über Zeit an dir selbst anzeigen."

L.PROFILE_TRANSFER.exportTitle = "Profil exportieren"
L.PROFILE_TRANSFER.importTitle = "Profil importieren"
L.PROFILE_TRANSFER.export = "Exportieren"
L.PROFILE_TRANSFER.import = "Importieren"
L.PROFILE_TRANSFER.close = "Schließen"
L.PROFILE_TRANSFER.selectAll = "Alles auswählen"
L.PROFILE_TRANSFER.name = "2. Neues Profil benennen"
L.PROFILE_TRANSFER.copy = "Kopieren (Strg+C)"
L.PROFILE_TRANSFER.exportLabel = "Profilzeichenfolge"
L.PROFILE_TRANSFER.importLabel = "1. Profilzeichenfolge einfügen"
L.PROFILE_TRANSFER.importAction = "Profil importieren"
L.PROFILE_TRANSFER.pasteHint = "Hier klicken und die Profilzeichenfolge mit Strg+V einfügen."
L.PROFILE_TRANSFER.exportHelp = "Die ausgewählte Profilzeichenfolge mit Strg+C kopieren."
L.PROFILE_TRANSFER.importHelp = "Eine Profilzeichenfolge einfügen und einen neuen Namen vergeben. Der" ..
    " Import erstellt und aktiviert das neue Profil."
L.PROFILE_TRANSFER.mediaNote = "Eigene Schrift- und Audiodateien müssen separat installiert werden. " ..
    "Einstellungen und Zauber können je nach Spielversion oder Sprache " ..
    "abweichen."
L.PROFILE_TRANSFER.imported = "Profil importiert: %s"
L.PROFILE_TRANSFER.compatibility = "Dieses Profil stammt aus einer anderen Spielversion oder Sprache. " ..
    "Zaubereinstellungen, Auslöser, Schriften und Töne prüfen."
L.PROFILE_TRANSFER.errors.INVALID_NAME = "Einen Profilnamen mit 1–64 Zeichen eingeben."
L.PROFILE_TRANSFER.errors.PROFILE_EXISTS = "Dieses Profil existiert bereits. Einen anderen Namen wählen."
L.PROFILE_TRANSFER.errors.INVALID_TEXT = "Ungültige oder beschädigte Profilzeichenfolge. Den vollständigen " ..
    "Export kopieren."
L.PROFILE_TRANSFER.errors.INVALID_DATA = "Das Profil enthält ungültige oder nicht unterstützte Einstellungen."
L.PROFILE_TRANSFER.errors.TOO_LARGE = "Das Profil überschreitet die unterstützte Übertragungsgröße."
L.PROFILE_TRANSFER.errors.IN_COMBAT = "Mit dem Import warten, bis der Kampf beendet ist."
L.EVENT_CODES.RESOURCE_AMOUNT = "%a - Menge der erhaltenen Ressource.\n"
L.EVENT_CODES.RESOURCE_NAME = "%p - Name der Ressource.\n"
