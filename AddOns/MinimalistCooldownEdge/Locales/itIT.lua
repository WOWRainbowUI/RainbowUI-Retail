-- itIT.lua (Italian)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "itIT")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras gestisce i colori di soglia del conto alla rovescia. Configurali in MiniAuras > Misc > Countdown Colours."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% = trasparente, 100% = completamente scuro. Si applica a tutti i gruppi di moduli di MiniAuras; l'80% corrisponde allo swipe disegnato da MiniAuras."

-- Core
L["MiniAuras test command is unavailable."] = "Il comando di test di MiniAuras non è disponibile."

-- Category Names
L["Action Bars"] = "Barre d'azione"
L["Nameplates"] = "Targhette dei nomi"
L["Unit Frames"] = "Riquadri unità"
L["Party / Raid Frames"] = "Riquadri gruppo/incursione"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "Tipi di riquadro di MiniAuras"

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
L["Essential Viewer Stack Size"] = "Dimensione accumuli visualizzatore Essential"
L["Utility Viewer Stack Size"] = "Dimensione accumuli visualizzatore Utility"
L["Buff Icon Viewer Stack Size"] = "Dimensione accumuli visualizzatore icone benefici"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "Attiva o disattiva le icone di test integrate di MiniAuras con /miniauras test."

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
L["Top"] = "Alto"
L["Bottom"] = "Basso"
L["Left"] = "Sinistra"
L["Right"] = "Destra"

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
L["Retired"] = "Ritirato"

-- General Dashboard
L["Enable categories styling"] = "Abilita stile categorie"
L["LIVE_CONTROLS_DESC"] = "Le modifiche si applicano subito. Tieni attive solo le categorie che usi davvero per una configurazione più pulita."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Abilita riquadri gruppo/incursione funge da interruttore principale per questa categoria. Abilita testo aure dell'incursione estende lo stesso stile ai riquadri incursione di Blizzard."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "Il supporto ai riquadri gruppo/incursione è stato ritirato. Dal patch Blizzard 12.0.5, MiniCE non aggancia né modifica più i riquadri compatti di gruppo e incursione."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "Nuovo addon in sviluppo: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras è ora disponibile su CurseForge. Rimane separato da MiniCE perché usa propri frame in overlay invece di modificare le icone Blizzard esistenti, quindi funziona meglio come addon autonomo."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copia questo link per aprire la pagina del progetto su CurseForge nel tuo browser."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "Copia questo link per aprire Raid Frame Auras su CurseForge."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copia questo link per vedere altri progetti di Anahkas su CurseForge."

-- Help
L["Help & Support"] = "Aiuto e supporto"
L["Project"] = "Progetto"
L["Useful Addons"] = "Addon utili"
L["Support & Feedback"] = "Supporto e feedback"
L["MCE_HELP_INTRO"] = "Link rapidi al progetto e un paio di addon che vale la pena provare."
L["HELP_SUPPORT_DESC"] = "Suggerimenti e feedback sono sempre benvenuti.\n\nSe trovi un bug o hai un'idea per una funzione, sentiti libero di lasciare un commento o un messaggio privato su CurseForge."
L["HELP_COMPANION_DESC"] = "Addon essenziali che si abbinano bene a MiniCE."
L["HELP_MINIAURAS_DESC"] = "Suite di visualizzazione per aure personalizzate, controlli, tempi di recupero e PvP. MiniCE può anche personalizzarne il testo."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "Copia questo link per aprire la pagina di MiniAuras su CurseForge nel tuo browser."
L["HELP_PVPTAB_DESC"] = "Fa sì che TAB selezioni solo i giocatori in PvP. Ottimo per arene e campi di battaglia."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copia questo link per aprire Smart PvP Tab Targeting su CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Attiva o disattiva le categorie principali dei cooldown da un solo punto."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Questa azione non può essere annullata. Il tuo profilo verrà completamente ripristinato e l'interfaccia verrà ricaricata."
L["MAINTENANCE_DESC"] = "Ripristina questa categoria ai valori di fabbrica. Le altre categorie non vengono toccate."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Stilizza i cooldown sulle tue barre d'azione."
L["NAMEPLATE_DESC"] = "Stilizza i cooldown sulle targhette nemiche e alleate."
L["UNITFRAME_DESC"] = "Stilizza i cooldown delle aure sui riquadri di bersaglio, focus e altri riquadri unità supportati."
L["COOLDOWNMANAGER_DESC"] = "Stilizza i cooldown delle icone di CooldownManager."
L["MINIAURAS_DESC"] = "Stilizza le icone di cooldown di MiniAuras."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Colori dinamici del testo"
L["Color by Remaining Time"] = "Colore in base al tempo restante"
L["Dynamically colors the countdown text based on how much time is left."] = "Colora dinamicamente il testo del conto alla rovescia in base al tempo restante."
L["DYNAMIC_COLORS_DESC"] = "Cambia il colore del testo in base alla durata residua del cooldown. Quando è attivo, sostituisce il colore statico sopra."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Le soglie di tempo rimanente possono essere consentite o bloccate per ogni categoria MiniCE attiva. La gestione della durata resta sicura anche al cambio di mezzanotte quando Blizzard espone valori nascosti."
L["Expiring Soon"] = "In scadenza"
L["Short Duration"] = "Durata breve"
L["Long Duration"] = "Durata lunga"
L["Threshold (seconds)"] = "Soglia (secondi)"
L["Default Color"] = "Colore predefinito"
L["Color used when the remaining time exceeds all thresholds."] = "Colore usato quando il tempo restante supera tutte le soglie."

-- Abbreviation
L["Abbreviate Above"] = "Abbrevia sopra"
L["Abbreviate Above (seconds)"] = "Abbrevia sopra (secondi)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "I numeri di recupero sopra questa soglia verranno abbreviati (es. 5m invece di 300)."
L["ABBREV_THRESHOLD_DESC"] = "Controlla quando i numeri di recupero passano al formato abbreviato. I timer sopra questa soglia mostrano valori abbreviati come 5m o 1h."

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% = trasparente, 100% = completamente scuro. Sostituisce l'impostazione Cooldown Swipe Alpha di MyDRs mentre questa categoria è attiva; 100% corrisponde allo swipe disegnato da MyDRs stesso."
L["MyDRs test command is unavailable."] = "Il comando di test di MyDRs non è disponibile."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "Attiva o disattiva le icone di test integrate di MyDRs con /mydrs test."
L["sArena slash command is unavailable."] = "Il comando slash di sArena non è disponibile."

-- Category Names
L["Player Auras"] = "Aure del giocatore"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "Profili"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "Bordo di scorrimento"
L["MiniAuras Module Groups"] = "Gruppi di moduli MiniAuras"
L["sArena Cooldown Types"] = "Tipi di cooldown sArena"
L["Aura Targets"] = "Bersagli aure"
L["Buff Styling"] = "Stile benefici"
L["Debuff Styling"] = "Stile penalità"
L["External Defensive Buffs Styling"] = "Stile benefici difensivi esterni"

-- Toggles & Settings
L["Style Buffs"] = "Stilizza benefici"
L["Style Debuffs"] = "Stilizza penalità"
L["Style External Defensive Buffs"] = "Stilizza benefici difensivi esterni"
L["Style Blizzard's default player buff buttons."] = "Stilizza le icone di benefici predefinite del giocatore di Blizzard."
L["Style Blizzard's default player debuff buttons."] = "Stilizza le icone di penalità predefinite del giocatore di Blizzard."
L["Style Blizzard's external defensive buff buttons."] = "Stilizza le icone di benefici difensivi esterni di Blizzard."
L["Timer Inside Icon"] = "Timer dentro l'icona"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Posiziona il timer dell'aura al centro dell'icona invece della posizione esterna predefinita di Blizzard."
L["Hide Swipe"] = "Nascondi scorrimento"
L["Only Mine (Timer Text)"] = "Solo le mie (testo timer)"
L["Aura Visibility"] = "Visibilità aure"
L["Only My Debuffs"] = "Solo le mie penalità"
L["Only My Buffs"] = "Solo i miei benefici"
L["Disable fading/blinking"] = "Disattiva dissolvenza/lampeggio"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "Attiva il testo del conto alla rovescia stilizzato su Riquadri gruppo/incursione. Se disattivato, lo stile del testo aure di gruppo e incursione viene completamente spento."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Applica il testo del conto alla rovescia stilizzato anche alle icone di benefici e penalità di Blizzard CompactRaidFrame. Richiede che Riquadri gruppo/incursione sia attivato."
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "Nasconde l'animazione di scorrimento per questo gruppo di riquadri (il testo del conto alla rovescia resta visibile)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "Mostra il testo del timer di cooldown solo sulle tue aure. Usa l'euristica di Blizzard per le aure grandi invece di un controllo diretto su sourceUnit."
L["UNITFRAME_ONLY_MINE_DESC"] = "Mostra il testo del timer solo sulle aure lanciate da te. I contenitori bersaglio/focus di MiniCE per WoW 12.1 usano il filtro Giocatore di Blizzard; i riquadri di addon compatibili e legacy usano i loro metadati di gruppo o il fallback per aure grandi."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Nasconde le penalità lanciate da altri giocatori sui riquadri bersaglio e focus. MiniCE gestisce questi contenitori di aure su WoW 12.1, quindi il filtro penalità di Blizzard non li raggiunge più."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Nasconde i benefici lanciati da altri giocatori sui riquadri bersaglio e focus. MiniCE gestisce questi contenitori di aure su WoW 12.1, quindi il filtro benefici di Blizzard non li raggiunge più."
L["Cast Bar"] = "Barra di lancio"
L["Reposition Cast Bar"] = "Riposiziona la barra di lancio"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Ancora le barre di lancio di bersaglio e focus sotto l'ultima riga di benefici/penalità. MiniCE gestisce questi contenitori di aure su WoW 12.1; altrimenti la barra di Blizzard resta attaccata al riquadro e le sovrappone."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "Mantiene le icone delle aure del giocatore completamente opache quando stanno per scadere."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "Usa un colore beneficio dedicato invece dei colori soglia del tempo rimanente quando uno slot di CooldownManager mostra temporaneamente la durata di un'aura."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "Applicato mentre lo slot mostra la durata dell'aura. Quando l'aura termina e lo slot torna al tempo di cooldown, i colori soglia riprendono."
L["Buff / Debuff Size"] = "Dimensione benefici/penalità"
L["Defensive Buff Size"] = "Dimensione beneficio difensivo"
L["Use Buff Color"] = "Usa colore beneficio"
L["Buff Color"] = "Colore beneficio"
L["Essential Viewer"] = "Visualizzatore Essential"
L["Utility Viewer"] = "Visualizzatore Utility"
L["Buff Icon Viewer"] = "Visualizzatore icone benefici"
L["CC Frames Text Size"] = "Dimensione testo riquadri CC"
L["CC / Friendly Frames Text Size"] = "Dimensione testo CC / riquadri alleati"
L["Raid Frame Auras Text Size"] = "Dimensione testo aure riquadri incursione"
L["Class Icon Text Size"] = "Dimensione testo icona classe"
L["DR Cooldown Text Size"] = "Dimensione testo cooldown DR"
L["Alerts / Trackers / Custom Auras Text Size"] = "Dimensione testo avvisi/tracker/aure personalizzate"
L["Trinket / Racial Text Size"] = "Dimensione testo ninnolo/razziale"
L["Show Test Frames"] = "Mostra riquadri di test"
L["Hide Test Frames"] = "Nascondi riquadri di test"
L["Show Swipe Animation"] = "Mostra animazione di scorrimento"
L["Shows the dark overlay that sweeps during a cooldown."] = "Mostra la sovrapposizione scura che scorre durante un cooldown."
L["Swipe Shade Alpha"] = "Opacità dell'ombra di scorrimento"
L["0% = transparent, 100% = full dark."] = "0% = trasparente, 100% = completamente scuro."
L["Reverse Swipe"] = "Inverti scorrimento"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "Inverte la direzione dello scorrimento in modo che l'ombra si riempia nella direzione opposta."
L["Hide Charge Timers"] = "Nascondi timer cariche"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "Nasconde i timer mentre le cariche si ricaricano (mostra il timer solo quando tutte le cariche sono esaurite)."
L["Hide Stack Text"] = "Nascondi testo accumuli"
L["Hide stacks and charges entirely."] = "Nasconde completamente accumuli e cariche."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "Le impostazioni di testo di MiniAuras sono raggruppate per famiglia di moduli, così i widget simili condividono la stessa dimensione del conto alla rovescia."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "Si applica al modulo CC di MiniAuras (controlli di massa nemici)."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "Si applica ai moduli CC, Friendly CDs e Friendly Indicators di MiniAuras."
L["Applies to the MiniAuras Raid Frame Auras module."] = "Si applica al modulo Raid Frame Auras di MiniAuras."
L["Applies to MiniAuras portrait icons."] = "Si applica alle icone dei ritratti di MiniAuras."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "Si applica ai moduli Alerts, Healer CC, Kick Timer, Precognition, Trinkets e Custom Auras di MiniAuras."
L["Show sArena test frames using /sarena test."] = "Mostra i riquadri di test di sArena con /sarena test."
L["Hide sArena test frames using /sarena hide."] = "Nasconde i riquadri di test di sArena con /sarena hide."

-- Import / Export
L["Import string is too large."] = "La stringa di importazione è troppo grande."
L["Import profile contains invalid data."] = "Il profilo importato contiene dati non validi."
L["Failed to apply imported profile."] = "Impossibile applicare il profilo importato."

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "Alcune modifiche richiedono il ricaricamento dell'interfaccia per essere applicate completamente.\n\nRicaricare l'interfaccia ora?"

-- Addon Integrations
L["Addon Integrations"] = "Integrazioni addon"
L["ADDON_INTEGRATIONS_DESC"] = "Attiva o disattiva i collegamenti opzionali con altri addon che instradano i cooldown esterni verso le categorie di MiniCE."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "Instrada i cooldown di ShinyAuras attraverso la categoria Riquadri unità. Disattiva questa opzione se vuoi che ShinyAuras mantenga i suoi conti alla rovescia nativi inalterati."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "Instrada i cooldown supportati delle barre d'azione di Dominos attraverso la categoria Barre d'azione. Disattiva questa opzione se vuoi che Dominos mantenga il suo stile di cooldown nativo inalterato."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "Instrada i cooldown supportati delle barre d'azione di Bartender4 attraverso la categoria Barre d'azione. Disattiva questa opzione se vuoi che Bartender4 mantenga il suo stile di cooldown nativo inalterato."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "Instrada i cooldown supportati di barre d'azione, riquadri unità e targhette di ElvUI attraverso le categorie di MiniCE. Disattiva questa opzione se vuoi che ElvUI mantenga il suo stile di cooldown nativo inalterato."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered stilizza anche %s. Questo potrebbe comportare un piccolo costo prestazionale. Disattiva i font timer di CMC se vuoi che MiniCE resti l'unico responsabile dei timer di quei visualizzatori."

-- Help
L["HELP_ARENADR_DESC"] = "Traccia le riduzioni progressive nemiche direttamente sulle targhette in Arena."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "Copia questo link per aprire ArenaDR Nameplates su CurseForge."

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames è attivo, quindi lo stile dei riquadri unità di MiniCE è stato disattivato per evitare possibili conflitti. Un adattatore dedicato per BetterBlizzFrames arriverà presto."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates è attivo, quindi lo stile delle barre dei nomi di MiniCE è stato disattivato per evitare possibili conflitti."
L["PLAYERAURA_DESC"] = "Stilizza i cooldown di benefici e penalità del giocatore di Blizzard."
L["HEALERCC_DESC"] = "Stilizza i cooldown degli avvisi HealerCC alleati e nemici."
L["MYDRS_DESC"] = "Stilizza le icone di cooldown delle riduzioni progressive di MyDRs. MyDRs mantiene la propria etichetta di stato DR (50% / IMM)."
L["SARENA_DESC"] = "Stilizza i timer di cooldown di sArena_Reloaded."
L["TELLMEWHEN_DESC"] = "Stilizza il testo di cooldown e i bordi di scorrimento di TellMeWhen."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "Visibilità del timer, testo del timer, direzione dell'ombreggiatura e visualizzazione del GCD restano controllati da TellMeWhen. La visibilità e lo spessore del bordo di scorrimento sono controllati qui."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Scala il bordo di scorrimento di TellMeWhen quando MiniCE lo ha attivato."

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "Consenti colori soglia"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "Consente alle soglie globali di \"Colore in base al tempo restante\" di sovrascrivere il colore statico del testo di questa categoria."
L["Behavior"] = "Comportamento"
L["Advanced Threshold Settings"] = "Impostazioni avanzate delle soglie"
L["Threshold Colors"] = "Colori soglia"
L["THRESHOLD_COLORS_DESC"] = "Ogni fascia definisce il limite e il colore usati per quell'intervallo di tempo rimanente."
L["Threshold Transition Offset"] = "Scostamento di transizione soglia"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "Sposta l'inizio di ciascuna fascia di colore successiva. Valori negativi anticipano leggermente il cambio."
L["Beyond Thresholds Color"] = "Colore oltre le soglie"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "Mostra decimi sotto (secondi)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "I numeri di recupero sotto questa soglia mostreranno una cifra decimale (es. 8.7). Imposta 0 per disattivare."

-- Performance Warning
L["PERF_WARNING_DESC"] = "Questa funzione potrebbe influire sulle prestazioni e causare cali di FPS. Usala solo su configurazioni potenti."

-- Font Options
L["Game Default"] = "Predefinito di gioco"
