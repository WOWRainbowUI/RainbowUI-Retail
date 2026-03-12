-- itIT.lua (Italian)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "itIT")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Impossibile aprire le opzioni in combattimento."
L["MiniCC test command is unavailable."] = "Il comando di test di MiniCC non è disponibile."

-- Category Names
L["Action Bars"] = "Barre d'azione"
L["Nameplates"] = "Targhette dei nomi"
L["Unit Frames"] = "Riquadri unità"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "Altro"

-- Group Headers
L["General"] = "Generale"
L["Typography (Cooldown Numbers)"] = "Tipografia (numeri di ricarica)"
L["Swipe Animation"] = "Animazione di scorrimento"
L["Stack Counters / Charges"] = "Contatori accumuli / cariche"
L["Maintenance"] = "Manutenzione"
L["Danger Zone"] = "Zona di pericolo"
L["Style"] = "Stile"
L["Positioning"] = "Posizionamento"
L["CooldownManager Viewers"] = "Visualizzatori di CooldownManager"
L["MiniCC Frame Types"] = "Tipi di riquadro di MiniCC"

-- Toggles & Settings
L["Enable %s"] = "Abilita %s"
L["Toggle styling for this category."] = "Attiva o disattiva lo stile per questa categoria."
L["Font Face"] = "Carattere"
L["Font"] = "Carattere"
L["Size"] = "Dimensione"
L["Outline"] = "Contorno"
L["Color"] = "Colore"
L["Hide Numbers"] = "Nascondi numeri"
L["Compact Party / Raid Aura Text"] = "Testo aure compatte di gruppo/incursione"
L["Enable Party Aura Text"] = "Abilita testo aure del gruppo"
L["Enable Raid Aura Text"] = "Abilita testo aure dell'incursione"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Nasconde completamente il testo (utile se vuoi solo il bordo di scorrimento o gli accumuli)."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Mostra testo del conto alla rovescia stilizzato sulle icone di benefici e penalità di Blizzard CompactPartyFrame. Disattivandolo si nasconde il testo delle aure nei riquadri del gruppo."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Mostra testo del conto alla rovescia stilizzato sulle icone di benefici e penalità di Blizzard CompactRaidFrame. Disattivandolo si nasconde il testo delle aure nei riquadri dell'incursione."
L["Anchor Point"] = "Punto di ancoraggio"
L["Offset X"] = "Scostamento X"
L["Offset Y"] = "Scostamento Y"
L["Essential Viewer Size"] = "Dimensione visualizzatore Essential"
L["Utility Viewer Size"] = "Dimensione visualizzatore Utility"
L["Buff Icon Viewer Size"] = "Dimensione visualizzatore icone benefici"
L["CC Text Size"] = "Dimensione testo CC"
L["Nameplates Text Size"] = "Dimensione testo targhette"
L["Portraits Text Size"] = "Dimensione testo ritratti"
L["Alerts / Overlay Text Size"] = "Dimensione testo avvisi / overlay"
L["Toggle Test Icons"] = "Attiva o disattiva icone di test"
L["Show Swipe Edge"] = "Mostra bordo di scorrimento"
L["Shows the white line indicating cooldown progress."] = "Mostra la linea bianca che indica l'avanzamento della ricarica."
L["Edge Thickness"] = "Spessore del bordo"
L["Scale of the swipe line (1.0 = Default)."] = "Scala della linea di scorrimento (1.0 = predefinito)."
L["Customize Stack Text"] = "Personalizza testo accumuli"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Prendi il controllo del contatore cariche (ad es. 2 cariche di Conflagrazione)."
L["Reset %s"] = "Reimposta %s"
L["Revert this category to default settings."] = "Ripristina questa categoria alle impostazioni predefinite."
L["Toggle MiniCC's built-in test icons using /minicc test."] = "Attiva o disattiva le icone di test integrate di MiniCC con /minicc test."

-- Outline Values
L["None"] = "Nessuno"
L["Thick"] = "Spesso"
L["Mono"] = "Mono"

-- Anchor Point Values
L["Bottom Right"] = "In basso a destra"
L["Bottom Left"] = "In basso a sinistra"
L["Top Right"] = "In alto a destra"
L["Top Left"] = "In alto a sinistra"
L["Center"] = "Centro"

-- General Tab
L["Factory Reset (All)"] = "Ripristino di fabbrica (tutto)"
L["Resets the entire profile to default values and reloads the UI."] = "Ripristina l'intero profilo ai valori predefiniti e ricarica l'interfaccia."
L["Import / Export"] = "Importa / Esporta"
L["PROFILE_IMPORT_EXPORT_DESC"] = "Esporta il profilo AceDB attivo come stringa condivisibile oppure importa una stringa per sostituire le impostazioni attuali del profilo."
L["Export current profile"] = "Esporta profilo attuale"
L["Generate export"] = "Genera esportazione"
L["Export code"] = "Codice di esportazione"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "Genera una stringa di esportazione, poi fai clic in questo riquadro e copiala con Ctrl+C."
L["Import profile"] = "Importa profilo"
L["Import code"] = "Codice di importazione"
L["Paste an exported string here, then click Import."] = "Incolla qui una stringa esportata, poi fai clic su Importa."
L["Import"] = "Importa"
L["Importing will overwrite the current profile settings. Continue?"] = "L'importazione sovrascriverà le impostazioni attuali del profilo. Continuare?"
L["Export string generated. Copy it with Ctrl+C."] = "Stringa di esportazione generata. Copiala con Ctrl+C."
L["Profile import completed."] = "Importazione del profilo completata."
L["No active profile available."] = "Nessun profilo attivo disponibile."
L["Failed to encode export string."] = "Impossibile codificare la stringa di esportazione."
L["Paste an import string first."] = "Incolla prima una stringa di importazione."
L["Invalid import string format."] = "Formato della stringa di importazione non valido."
L["Failed to decode import string."] = "Impossibile decodificare la stringa di importazione."
L["Failed to decompress import string."] = "Impossibile decomprimere la stringa di importazione."
L["Failed to deserialize import string."] = "Impossibile deserializzare la stringa di importazione."

-- Banner
L["BANNER_DESC"] = "Configurazione minimalista per i tuoi cooldown. Seleziona una categoria a sinistra per iniziare."

-- Chat Messages
L["%s settings reset."] = "Impostazioni di %s ripristinate."
L["Profile reset. Reloading UI..."] = "Profilo ripristinato. Ricaricamento dell'interfaccia..."

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"

-- General Dashboard
L["Enable categories styling"] = "Abilita stile categorie"
L["LIVE_CONTROLS_DESC"] = "Le modifiche si applicano subito. Tieni attive solo le categorie che usi davvero per una configurazione più pulita."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Mostra testo del conto alla rovescia stilizzato sulle icone di benefici e penalità di Blizzard CompactPartyFrame e CompactRaidFrame. Gruppo e incursione possono essere attivati separatamente. Questa opzione è indipendente da Altro."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copia questo link per aprire la pagina del progetto su CurseForge nel tuo browser."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copia questo link per vedere altri progetti di Anahkas su CurseForge."

-- Help
L["Help & Support"] = "Aiuto e supporto"
L["Project"] = "Progetto"
L["Useful Addons"] = "Addon utili"
L["Support & Feedback"] = "Supporto e feedback"
L["MCE_HELP_INTRO"] = "Link rapidi al progetto e un paio di addon che vale la pena provare."
L["HELP_SUPPORT_DESC"] = "Suggerimenti e feedback sono sempre benvenuti.\n\nSe trovi un bug o hai un'idea per una funzione, sentiti libero di lasciare un commento o un messaggio privato su CurseForge."
L["HELP_COMPANION_DESC"] = "Addon essenziali che si abbinano bene a MiniCE."
L["HELP_MINICC_DESC"] = "Tracciatore CC compatto. MiniCE può stilizzare anche il suo testo."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "Copia questo link per aprire la pagina di MiniCC su CurseForge nel tuo browser."
L["HELP_PVPTAB_DESC"] = "Fa sì che TAB selezioni solo i giocatori in PvP. Ottimo per arene e campi di battaglia."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copia questo link per aprire Smart PvP Tab Targeting su CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Attiva o disattiva le categorie principali dei cooldown da un solo punto."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Questa azione non può essere annullata. Il tuo profilo verrà completamente ripristinato e l'interfaccia verrà ricaricata."
L["MAINTENANCE_DESC"] = "Ripristina questa categoria ai valori di fabbrica. Le altre categorie non vengono toccate."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Personalizza i cooldown sulle tue barre d'azione principali, incluse Bartender4, Dominos ed ElvUI."
L["NAMEPLATE_DESC"] = "Stilizza i cooldown mostrati sulle targhette nemiche e alleate (Plater, KuiNameplates, ecc.)."
L["UNITFRAME_DESC"] = "Regola lo stile dei cooldown sui riquadri di giocatore, bersaglio e focus."
L["COOLDOWNMANAGER_DESC"] = "Stile icone condiviso per i visualizzatori di CooldownManager. La dimensione del testo del conto alla rovescia può essere impostata separatamente per i visualizzatori Essential, Utility e delle icone benefici."
L["MINICC_DESC"] = "Stile dedicato per le icone di cooldown di MiniCC. Supporta le icone di controllo di MiniCC, le targhette, i ritratti e i moduli in stile overlay quando MiniCC è caricato."
L["OTHERS_DESC"] = "Categoria jolly per i cooldown che non appartengono ad altre categorie (borse, menu, addon vari)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Colori dinamici del testo"
L["Color by Remaining Time"] = "Colore in base al tempo restante"
L["Dynamically colors the countdown text based on how much time is left."] = "Colora dinamicamente il testo del conto alla rovescia in base al tempo restante."
L["DYNAMIC_COLORS_DESC"] = "Cambia il colore del testo in base alla durata residua del cooldown. Quando è attivo, sostituisce il colore statico sopra."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Applica le stesse soglie di tempo rimanente a tutte le categorie MiniCE abilitate, incluso il testo delle aure compatte di gruppo/incursione. La gestione della durata resta sicura anche al cambio di mezzanotte quando Blizzard espone valori nascosti."
L["Expiring Soon"] = "In scadenza"
L["Short Duration"] = "Durata breve"
L["Long Duration"] = "Durata lunga"
L["Beyond Thresholds"] = "Oltre le soglie"
L["Threshold (seconds)"] = "Soglia (secondi)"
L["Default Color"] = "Colore predefinito"
L["Color used when the remaining time exceeds all thresholds."] = "Colore usato quando il tempo restante supera tutte le soglie."

-- Abbreviation
L["Abbreviate Above"] = "Abbrevia sopra"
L["Abbreviate Above (seconds)"] = "Abbrevia sopra (secondi)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "I numeri di recupero sopra questa soglia verranno abbreviati (es. 5m invece di 300)."
L["ABBREV_THRESHOLD_DESC"] = "Controlla quando i numeri di recupero passano al formato abbreviato. I timer sopra questa soglia mostrano valori abbreviati come 5m o 1h."
