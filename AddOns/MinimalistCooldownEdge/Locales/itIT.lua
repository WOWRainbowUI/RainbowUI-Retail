-- itIT.lua (Italian)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "itIT")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Impossibile aprire le opzioni in combattimento."

-- Category Names
L["Action Bars"] = "Barre d'azione"
L["Nameplates"] = "Targhette"
L["Unit Frames"] = "Riquadri unità"
L["CD Manager & Others"] = "Gestore CD e Altri"

-- Group Headers
L["General"] = "Generale"
L["State"] = "Stato"
L["Typography (Cooldown Numbers)"] = "Tipografia (Numeri di ricarica)"
L["Swipe Animation"] = "Animazione di scorrimento"
L["Stack Counters / Charges"] = "Contatori di accumulo / Cariche"
L["Maintenance"] = "Manutenzione"
L["Performance & Detection"] = "Prestazioni e Rilevamento"
L["Danger Zone"] = "Zona di pericolo"
L["Style"] = "Stile"
L["Positioning"] = "Posizionamento"

-- Toggles & Settings
L["Enable %s"] = "Abilita %s"
L["Toggle styling for this category."] = "Attiva/disattiva lo stile per questa categoria."
L["Font Face"] = "Tipo di carattere"
L["Game Default"] = "Font del gioco"
L["Font"] = "Carattere"
L["Size"] = "Dimensione"
L["Outline"] = "Contorno"
L["Color"] = "Colore"
L["Hide Numbers"] = "Nascondi numeri"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Nasconde completamente il testo (utile se desideri solo il bordo di scorrimento o gli accumuli)."
L["Anchor Point"] = "Punto di ancoraggio"
L["Offset X"] = "Scostamento X"
L["Offset Y"] = "Scostamento Y"
L["Show Swipe Edge"] = "Mostra bordo di scorrimento"
L["Shows the white line indicating cooldown progress."] = "Mostra la linea bianca che indica l'avanzamento della ricarica."
L["Edge Thickness"] = "Spessore del bordo"
L["Scale of the swipe line (1.0 = Default)."] = "Scala della linea di scorrimento (1.0 = Predefinito)."
L["Customize Stack Text"] = "Personalizza testo accumulo"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Prendi il controllo del contatore cariche (es.: 2 accumuli di Conflagrazione)."
L["Reset %s"] = "Reimposta %s"
L["Revert this category to default settings."] = "Ripristina questa categoria alle impostazioni predefinite."

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
L["Scan Depth"] = "Profondità di scansione"
L["How deep the addon looks into UI frames to find cooldowns."] = "Quanto in profondità l'addon cerca nei riquadri dell'interfaccia per trovare le ricariche."
L["Factory Reset (All)"] = "Ripristino di fabbrica (Tutto)"
L["Resets the entire profile to default values and reloads the UI."] = "Reimposta l'intero profilo ai valori predefiniti e ricarica l'interfaccia."

-- Banner
L["BANNER_DESC"] = "Configurazione minimalista per le tue ricariche. Seleziona una categoria a sinistra per iniziare."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Efficiente (UI predefinita)\n|cfffff56910 - 15|r : Moderato (Bartender, Dominos)\n|cffffa500> 15|r : Pesante (ElvUI, Riquadri complessi)"

-- Chat Messages
L["%s settings reset."] = "Impostazioni di %s reimpostate."
L["Profile reset. Reloading UI..."] = "Profilo reimpostato. Ricaricamento interfaccia..."
L["Global Scan Depth changed. A /reload is recommended."] = "Profondità di scansione globale modificata. Si raccomanda un /reload."
