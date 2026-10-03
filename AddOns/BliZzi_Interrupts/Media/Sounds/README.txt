BliZzi Party Tools - your own sound files
=========================================

  1. Put your .ogg or .mp3 file in THIS folder.
     Give it a short name without spaces, for example sonar.ogg
     (custom_sonar.ogg works just as well).
  2. RESTART the game completely. World of Warcraft only looks for new
     files while it starts up - /reload is not enough.
  3. In the addon settings: Interrupts -> Sounds -> Own Sound Files,
     type sonar into "Add sound".

You hear the sound once when it is added - that is the confirmation
that the right file was found. If nothing plays, nothing was found.

The sound is then called "sonar" in every sound list of the addon: kick
success, failed kick and the external cooldown alerts. As many files as
you like.

Why type the name at all? World of Warcraft gives addons no way to see
what is inside a folder. It can only be asked whether one exact file
exists. So the addon needs to be told the name once - after that it
remembers.

Rules
-----
  - .ogg and .mp3 both work. .wav does not.
  - The file must sit directly in this folder, not in a subfolder.
  - Avoid spaces and special characters in the file name.
  - Keep it short. An interrupt sound that runs longer than a second or
    two will still be playing when the next kick happens.
  - Removing an entry from the list does not delete the file.

Not hearing anything?
---------------------
  /bitsound add sonar     does the same as the settings box and says
                          straight away whether the file was found
  /bitsound               lists everything you have added
  /bitsound test sonar    plays it
  /bitsound remove sonar  takes it off the list

  - "no such file" means the name or the extension does not match, or
    the game was not restarted after the file was copied in.
  - Added but silent? Then it is the setting, not the file - pick the
    sound in the dropdowns under Interrupts, Sounds.


BliZzi Party Tools - eigene Sounddateien
========================================

  1. Deine .ogg- oder .mp3-Datei in DIESEN Ordner legen.
     Kurzer Name ohne Leerzeichen, zum Beispiel sonar.ogg
     (custom_sonar.ogg geht genauso).
  2. Das Spiel komplett NEU STARTEN. WoW sucht nur beim Start nach neuen
     Dateien - ein /reload reicht nicht.
  3. In den Addon-Einstellungen: Interrupts -> Sounds -> Eigene
     Sounddateien, dort sonar bei "Sound hinzufuegen" eintragen.

Beim Hinzufuegen hoerst du den Sound einmal - das ist die Bestaetigung,
dass die richtige Datei gefunden wurde. Kommt nichts, wurde nichts
gefunden.

Der Sound heisst danach "sonar" in allen Soundlisten des Addons: Kick
erfolgreich, Kick fehlgeschlagen und die External-Cooldown-Hinweise.
Beliebig viele Dateien.

Warum ueberhaupt den Namen eintippen? WoW gibt Addons keine
Moeglichkeit, in einen Ordner zu schauen. Man kann nur fragen, ob eine
ganz bestimmte Datei existiert. Das Addon muss den Namen also einmal
erfahren - danach merkt es ihn sich.

Regeln
------
  - .ogg und .mp3 funktionieren beide. .wav nicht.
  - Die Datei muss direkt in diesem Ordner liegen, nicht in einem
    Unterordner.
  - Leerzeichen und Sonderzeichen im Dateinamen vermeiden.
  - Kurz halten. Ein Interrupt-Sound, der laenger als ein bis zwei
    Sekunden dauert, laeuft beim naechsten Kick noch.
  - Ein Eintrag aus der Liste zu entfernen loescht die Datei nicht.

Kein Ton?
---------
  /bitsound add sonar     macht dasselbe wie das Eingabefeld und sagt
                          sofort, ob die Datei gefunden wurde
  /bitsound               listet alles Hinzugefuegte
  /bitsound test sonar    spielt es ab
  /bitsound remove sonar  nimmt es aus der Liste

  - "no such file" heisst: Name oder Endung passen nicht, oder das Spiel
    wurde nach dem Kopieren nicht neu gestartet.
  - Hinzugefuegt, aber stumm? Dann liegt es an der Einstellung, nicht an
    der Datei - den Sound in den Auswahlfeldern unter Interrupts, Sounds
    waehlen.
