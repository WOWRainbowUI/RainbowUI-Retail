local _, BR = ... -- luacheck: ignore 211
if GetLocale() ~= "itIT" then
    return
end

local L = BR.L -- luacheck: ignore 211

-- ============================================================================
-- CATEGORY LABELS
-- ============================================================================
L["Category.Raid"] = "Raid"
L["Category.Presence"] = "Presenza"
L["Category.Targeted"] = "Mirati"
L["Category.Self"] = "Personali"
L["Category.Pet"] = "Pet"
L["Category.Consumable"] = "Consumabili"
L["Category.Custom"] = "Personalizzati"

-- Long form (used in Options section headers)
L["Category.RaidBuffs"] = "Buff del Raid"
L["Category.TargetedBuffs"] = "Buff Mirati"
L["Category.Consumables"] = "Consumabili"
L["Category.PresenceBuffs"] = "Buff di Presenza"
L["Category.SelfBuffs"] = "Buff Personali"
L["Category.PetReminders"] = "Promemoria Pet"
L["Category.CustomBuffs"] = "Buff Personalizzati"

-- Category notes
L["Category.RaidNote"] = "(per tutto il gruppo)"
L["Category.TargetedNote"] = "(buff su qualcun altro)"
L["Category.ConsumableNote"] = "(fiale, cibo, rune, olii)"
L["Category.PresenceNote"] = "(almeno 1 persona necessita)"
L["Category.SelfNote"] = "(buff solo su di te)"
L["Category.PetNote"] = "(promemoria evocazione pet)"
L["Category.CustomNote"] = "(traccia qualsiasi buff/bagliore per ID incantesimo)"

-- ============================================================================
-- BUFF OVERLAY TEXT
-- ============================================================================
L["Overlay.NoDrPoison"] = "NO\nVEL\nLET"
L["Overlay.NoAura"] = "NO\nAURA"
L["Overlay.NoStone"] = "NO\nPIETRA"
L["Overlay.NoSoulstone"] = "NO\nPIETRA\nANIMA"
L["Overlay.NoFaith"] = "NO\nFEDE"
L["Overlay.NoLight"] = "NO\nLUCE"
L["Overlay.NoES"] = "NO\nES"
L["Overlay.NoSource"] = "NO\nFONTE"
L["Overlay.NoScales"] = "NO\nSCAGLIE"
L["Overlay.NoLink"] = "NO\nLEGAME"
L["Overlay.NoAttune"] = "NO\nSINT"
L["Overlay.NoFamiliar"] = "NO\nFAM"
L["Overlay.DropWell"] = "CREA\nPOZZO"
L["Overlay.NoGrim"] = "NO\nGRIM"
L["Overlay.BurningRush"] = "RUSH"
L["Overlay.NoRite"] = "NO\nRITO"
L["Overlay.ApplyPoison"] = "METTI\nVELENO"
L["Overlay.NoForm"] = "NO\nFORMA"
L["Overlay.NoEL"] = "NO\nEL"
L["Overlay.NoFT"] = "NO\nFT"
L["Overlay.NoTG"] = "NO\nTG"
L["Overlay.NoWF"] = "NO\nWF"
L["Overlay.NoSelfES"] = "NO\nES\nPERS"
L["Overlay.NoShield"] = "NO\nSCUDO"
L["Overlay.NoPet"] = "NO\nPET"
L["Overlay.PassivePet"] = "PET\nPASSIVO"
L["Overlay.WrongPet"] = "PET\nERRATO"
L["Overlay.NoRune"] = "NO\nRUNA"
L["Overlay.DKWrongRune"] = "RUNA\nERRATA"
L["Overlay.DKWrongRuneOH"] = "RUNA\nMS\nERRATA"
L["Overlay.NoFlask"] = "NO\nFIALA"
L["Overlay.NoFood"] = "NO\nCIBO"
L["Overlay.NoWeaponBuff"] = "NO\nBUFF\nARMA"
L["Overlay.Buff"] = "BUFF!"
L["Overlay.MinutesFormat"] = "%dm"
L["Overlay.LessThanOneMinute"] = "<1m"
L["Overlay.SecondsFormat"] = "%ds"

-- ============================================================================
-- CONSUMABLE STAT LABELS (icon overlays, keep very short)
-- ============================================================================
L["Label.Crit"] = "Crit"
L["Label.Haste"] = "Cel"
L["Label.Versatility"] = "Vers"
L["Label.Mastery"] = "Maes"
L["Label.Stamina"] = "Res"
L["Label.Healing"] = "Cura"
L["Label.Random"] = "Cas"
L["Label.Speed"] = "Vel"
L["Label.PvP"] = "PvP"
L["Label.Feast"] = "Banch"
L["Label.HasteShort"] = "C"
L["Label.VersatilityShort"] = "V"
L["Label.MasteryShort"] = "M"
L["Label.CritVers"] = "Crit/V"
L["Label.MasteryCrit"] = "M/Crit"
L["Label.MasteryVers"] = "M/V"
L["Label.MasteryHaste"] = "M/C"
L["Label.HasteCrit"] = "C/Crit"
L["Label.HasteVers"] = "C/V"
L["Label.StaminaStr"] = "Res/For"
L["Label.StaminaAgi"] = "Res/Agi"
L["Label.StaminaInt"] = "Res/Int"
L["Label.HighPrimary"] = "Al 1º"
L["Label.HighSecondary"] = "Al 2º"
L["Label.MidPrimary"] = "Me 1º"
L["Label.LowPrimary"] = "Ba 1º"
L["Label.LowSecondary"] = "Ba 2º"
L["Label.RevivePet"] = "Risorgi anim."
L["Label.Felguard"] = "Vilguardia"
L["Badge.Hearty"] = "H"
L["Badge.Fleeting"] = "F"

-- ============================================================================
-- BUFF NAMES
-- ============================================================================
L["Buff.ArcaneFamiliar"] = "Famiglio Arcano"
L["Buff.ArcaneIntellect"] = "Intelletto Arcano"
L["Buff.AtrophicNumbingPoison"] = "Veleno Atrofizzante/Intorpidente"
L["Buff.Attunement"] = "Sintonia"
L["Buff.AugmentRune"] = "Runa di Potenziamento"
L["Buff.BattleShout"] = "Urlo di Battaglia"
L["Buff.BeaconOfFaith"] = "Faro di Fede"
L["Buff.BeaconOfLight"] = "Faro di Luce"
L["Buff.BlessingOfTheBronze"] = "Benedizione del Bronzo"
L["Buff.BlisteringScales"] = "Scaglie Ustionanti"
L["Buff.BurningRush"] = "Impeto Ustionante"
L["Buff.CreateSoulwell"] = "Crea Pozzo delle Anime"
L["Buff.DelveFood"] = "Cibo delle Scorribande"
L["Buff.DevotionAura"] = "Aura di Devozione"
L["Buff.EarthShield"] = "Scudo di Terra"
L["Buff.EarthShieldSelf"] = "Scudo di Terra (Se Stesso)"
L["Buff.EarthlivingWeapon"] = "Arma Terraviva"
L["Buff.FlametongueWeapon"] = "Arma Linguadifuoco"
L["Buff.Flask"] = "Fiala"
L["Buff.Food"] = "Cibo"
L["Buff.GrimoireOfSacrifice"] = "Grimorio del Sacrificio"
L["Buff.Healthstone"] = "Pietra della Salute"
L["Buff.HunterPet"] = "Pet del Cacciatore"
L["Buff.MarkOfTheWild"] = "Marchio del Selvaggio"
L["Buff.PetPassive"] = "Pet Passivo"
L["Buff.PowerWordFortitude"] = "Parola del Potere: Tempra"
L["Buff.RiteOfAdjuration"] = "Rito di Scongiuro"
L["Buff.RiteOfSanctification"] = "Rito di Santificazione"
L["Buff.RoguePoisons"] = "Veleni del Ladro"
L["Buff.RuneforgeMH"] = "Runeforgiatura (Mano Principale)"
L["Buff.RuneforgeOH"] = "Runeforgiatura (Mano Secondaria)"
L["Buff.Shadowform"] = "Forma d'Ombra"
L["Buff.ShieldNoTalent"] = "Scudo (Nessun Talento)"
L["Buff.Skyfury"] = "Furia Celeste"
L["Buff.Soulstone"] = "Pietra dell'Anima"
L["Buff.SourceOfMagic"] = "Fonte di Magia"
L["Buff.SymbioticRelationship"] = "Relazione Simbiotica"
L["Buff.TidecallersGuard"] = "Guardia dell'Evocamaree"
L["Buff.UnholyGhoul"] = "Ghoul Empio"
L["Buff.WarlockDemon"] = "Demone dello Stregone"
L["Buff.WaterElemental"] = "Elementale d'Acqua"
L["Buff.WaterLightningShield"] = "Scudo d'Acqua/di Fulmini"
L["Buff.Weapon"] = "Arma"
L["Buff.WeaponOH"] = "Arma (Sec.)"
L["Buff.WindfuryWeapon"] = "Arma Furiaventosa"
L["Buff.WrongDemon"] = "Demone Sbagliato"

-- ============================================================================
-- BUFF GROUP DISPLAY NAMES
-- ============================================================================
L["Group.Beacons"] = "Fari"
L["Group.DKRunes"] = "Runeforgiature"
L["Group.ShamanImbues"] = "Imbevimenti Sciamanici"
L["Group.PaladinRites"] = "Riti del Paladino"
L["Group.Pets"] = "Pet"
L["Group.ShamanShields"] = "Scudi Sciamanici"
L["Group.Flask"] = "Fiala"
L["Group.Food"] = "Cibo"
L["Group.DelveFood"] = "Cibo delle Scorribande"
L["Group.Healthstone"] = "Pietra della Salute"
L["Group.AugmentRune"] = "Runa di Potenziamento"
L["Group.WeaponBuff"] = "Potenziamento Arma"

-- ============================================================================
-- BUFF INFO TOOLTIPS
-- ============================================================================
L["Tooltip.MayShowExtraIcon"] = "Potrebbe mostrare un'icona aggiuntiva"
L["Tooltip.MayShowExtraIcon.Desc"] =
    "Finché non lanci questo, potresti vedere sia questo che il promemoria per Scudo d'Acqua/Fulmineo. Non posso sapere se vuoi Scudo di Terra su te stesso, o Scudo di Terra su un alleato + Scudo d'Acqua/Fulmineo su di te."
L["Tooltip.InstanceEntryReminder"] = "Promemoria all'ingresso dell'istanza"
L["Tooltip.InstanceEntryReminder.Desc"] =
    "Mostrato brevemente all'ingresso di una spedizione come promemoria per piazzare un Pozzo delle Anime. Scompare dopo il lancio o dopo 30 secondi."

-- ============================================================================
-- GLOW TYPE NAMES
-- ============================================================================
L["Glow.Pixel"] = "Pixel"
L["Glow.AutoCast"] = "AutoCast"
L["Glow.Border"] = "Bordo"
L["Glow.Proc"] = "Proc"

-- ============================================================================
-- CORE
-- ============================================================================
L["Core.Any"] = "Qualsiasi"

-- ============================================================================
-- PROFILES
-- ============================================================================
L["Profile.SwitchQueued"] = "Cambio profilo in coda fino alla fine del combattimento."
L["Profile.Switched"] = "Profilo cambiato a '%s'."

-- ============================================================================
-- MOVERS
-- ============================================================================
L["Mover.SetPosition"] = "Imposta Posizione"
L["Mover.AnchorFrame"] = "Frame di Ancoraggio"
L["Mover.AnchorPoint"] = "Punto di Ancoraggio"
L["Mover.NoneScreenCenter"] = "Nessuno (Centro Schermo)"
L["Mover.Apply"] = "Applica"
L["Mover.BuffAnchor"] = "Ancora Buff"
L["Mover.DragTooltip"] = "Trascina per riposizionare\nClicca per aprire l'editor coordinate"
L["Mover.MainEmpty"] = "Principale (vuoto)"
L["Mover.MainAll"] = "Principale (tutti)"
L["Mover.Detached"] = "Separato"

-- ============================================================================
-- DISPLAY
-- ============================================================================
L["Display.FramesLocked"] = "Frame bloccati."
L["Display.FramesUnlocked"] = "Frame sbloccati."
L["Display.MinimapHidden"] = "Icona minimappa nascosta."
L["Display.MinimapShown"] = "Icona minimappa mostrata."
L["Display.Description"] = "Controlla i buff mancanti a colpo d'occhio."
L["Display.OpenOptions"] = "Apri Opzioni"
L["Display.SlashCommands"] = "Comandi: /br, /br lock, /br unlock, /br test, /br minimap"
L["Display.MinimapLeftClick"] = "|cFFCFCFCFClick sinistro|r: Opzioni"
L["Display.MinimapRightClick"] = "|cFFCFCFCFClick destro|r: Modalità test"
L["Display.DismissConsumables"] = "Nascondi promemoria consumabili fino alla prossima schermata di caricamento"
L["Display.LoginFirstInstall"] =
    "Grazie per l'installazione! Digita |cFFFFD100/br unlock|r per spostare il display dei buff, oppure usa il pulsante in fondo al pannello opzioni di |cFFFFD100/br|r."

-- ============================================================================
-- OPTIONS: TAB LABELS
-- ============================================================================
L["Tab.Buffs"] = "Buff"
L["Tab.DisplayBehavior"] = "Visualizzazione"
L["Tab.Settings"] = "Impostazioni"
L["Tab.Profiles"] = "Profili"
L["Tab.Sounds"] = "Suoni"

-- ============================================================================
-- OPTIONS: SOUND ALERTS
-- ============================================================================
L["Options.Sound.NoAlerts"] = "Nessun avviso sonoro configurato."
L["Options.Sound.AddAlert"] = "Aggiungi avviso sonoro"
L["Options.Sound.Title"] = "Aggiungi avviso sonoro"
L["Options.Sound.EditTitle"] = "Modifica avviso sonoro"
L["Options.Sound.SelectBuff"] = "Seleziona beneficio"
L["Options.Sound.SelectSound"] = "Seleziona suono"
L["Options.Sound.Preview"] = "Anteprima"
L["Options.Sound.Save"] = "Salva"
L["Options.Sound.NoBuffs"] = "Tutti i benefici hanno già dei suoni."

-- ============================================================================
-- OPTIONS: GLOBAL DEFAULTS
-- ============================================================================
L["Options.GlobalDefaults"] = "Predefiniti Globali"
L["Options.GlobalDefaults.Note"] =
    "(Tutte le categorie ereditano questi valori a meno che non venga usato un aspetto personalizzato)"
L["Options.Default"] = "Predefinito"
L["Options.Font"] = "Carattere"

-- ============================================================================
-- OPTIONS: GLOW SETTINGS
-- ============================================================================
L["Options.GlowReminderIcons"] = "Bagliore icone promemoria"
L["Options.GlowReminderIcons.Title"] = "Bagliore Icone Promemoria"
L["Options.GlowReminderIcons.Desc"] =
    "Aggiunge un effetto bagliore alle icone promemoria. Personalizza per configurare indipendentemente i bagliori per buff in scadenza e mancanti."
L["Options.GlowKind.Expiring"] = "In Scadenza"
L["Options.GlowKind.Missing"] = "Mancante"
L["Options.GlowSettings.Expiring"] = "Impostazioni Bagliore — In Scadenza"
L["Options.GlowSettings.Missing"] = "Impostazioni Bagliore — Mancante"
L["Options.Glow.Enabled"] = "Abilitato"
L["Options.Threshold"] = "Soglia"
L["Options.GlowMissingPets"] = "Bagliore pet mancanti"
L["Options.CustomGlowStyle"] = "Stile bagliore personalizzato"
L["Options.Expiration"] = "Scadenza"
L["Options.Glow"] = "Bagliore"
L["Options.UseCustomColor"] = "Usa Colore Personalizzato"
L["Options.UseCustomColor.Desc"] =
    "Se abilitato, il bagliore proc viene desaturato e ricolorato.\nQuesto appare meno vivace del bagliore proc predefinito."
L["Options.ExpirationReminder"] = "Promemoria Scadenza"

-- Glow params
L["Options.Glow.Type"] = "Tipo:"
L["Options.Glow.Size"] = "Dimensione:"
L["Options.Glow.Duration"] = "Durata"
L["Options.Glow.Frequency"] = "Frequenza"
L["Options.Glow.Length"] = "Lunghezza"
L["Options.Glow.Lines"] = "Linee"
L["Options.Glow.Particles"] = "Particelle"
L["Options.Glow.Scale"] = "Scala"
L["Options.Glow.Speed"] = "Velocità"
L["Options.Glow.StartAnimation"] = "Animazione Iniziale"
L["Options.Glow.XOffset"] = "Offset X"
L["Options.Glow.YOffset"] = "Offset Y"

-- ============================================================================
-- OPTIONS: CONTENT VISIBILITY
-- ============================================================================
L["Options.HidePvPMatchStart"] = "Nascondi all'inizio della partita PvP"
L["Options.HidePvPMatchStart.Title"] = "Nascondi all'Inizio della Partita PvP"
L["Options.HidePvPMatchStart.Desc"] =
    "Nascondi questa categoria una volta che una partita PvP inizia (dopo la fase di preparazione)."
L["Options.ReadyCheckOnly"] = "Mostra solo al controllo prontezza"
L["Options.ReadyCheckOnly.Desc"] =
    "Mostra i buff di questa categoria solo per 15 secondi dopo l'inizio di un controllo prontezza"
L["Options.Visibility"] = "Visibilità"
L["Options.PerCategoryCustomization"] = "Personalizzazione per Categoria"
L["Options.DetachIcon"] = "Separa"
L["Options.DetachIcon.Desc"] = "Sposta questa icona in un frame posizionabile indipendentemente"

-- ============================================================================
-- OPTIONS: HEALTHSTONE
-- ============================================================================
L["Options.Healthstone.ReadyCheckOnly"] = "Solo controllo prontezza"
L["Options.Healthstone.ReadyCheckWarlock"] = "Controllo prontezza + stregone sempre"
L["Options.Healthstone.AlwaysShow"] = "Mostra sempre"
L["Options.Healthstone.Visibility"] = "Visibilità Pietra della Salute"
L["Options.Healthstone.Visibility.Desc"] =
    "Controlla quando appare il promemoria Pietra della Salute.\n\n|cffffcc00Solo controllo prontezza:|r Solo durante i controlli prontezza (finestra di 15s).\n|cffffcc00Controllo prontezza + stregone sempre:|r Gli stregoni lo vedono sempre; gli altri solo al controllo prontezza.\n|cffffcc00Mostra sempre:|r Visibile quando sei nel contenuto corrispondente."
L["Options.Healthstone.WarlockAlwaysDesc"] =
    "Gli stregoni vedono sempre il promemoria; le altre classi solo al controllo prontezza"
L["Options.Healthstone.ReadyCheckDesc"] = "Mostra per 15 secondi dopo l'inizio di un controllo prontezza"
L["Options.Healthstone.AlwaysDesc"] = "Mostra ogni volta che il tipo di contenuto corrisponde"
L["Options.Healthstone.LowStock"] = "Avvisa quando poche"
L["Options.Healthstone.LowStock.Desc"] =
    "Mostra un avviso quando hai pietre della salute ma non abbastanza. Le pietre mancanti (0) vengono sempre tracciate indipendentemente da questa impostazione."
L["Options.Healthstone.Threshold"] = "Avvisa quando ne hai"
L["Options.Healthstone.Threshold.Desc"] =
    "Mostra un avviso scorte basse quando hai questo numero di pietre della salute o meno.\n\n|cffffcc001:|r Avvisa quando ne hai esattamente 1.\n|cffffcc002:|r Avvisa quando ne hai 1 o 2."

-- ============================================================================
-- OPTIONS: SOULSTONE
-- ============================================================================
L["Options.Soulstone.Visibility"] = "Visibilità Pietra dell'Anima"
L["Options.Soulstone.Visibility.Desc"] =
    "Controlla quando appare il promemoria pietra dell'anima.\n\n|cffffcc00Solo controllo prontezza:|r Solo durante i controlli prontezza (predefinito).\n|cffffcc00Controllo prontezza + stregone sempre:|r Gli stregoni lo vedono sempre; gli altri solo al controllo prontezza.\n|cffffcc00Mostra sempre:|r Visibile quando la categoria presenza è visibile."
L["Options.Soulstone.ReadyCheckOnly"] = "Solo controllo prontezza"
L["Options.Soulstone.ReadyCheckWarlock"] = "Controllo prontezza + stregone sempre"
L["Options.Soulstone.AlwaysShow"] = "Mostra sempre"
L["Options.Soulstone.ReadyCheckDesc"] = "Mostra per 15 secondi dopo l'inizio di un controllo prontezza"
L["Options.Soulstone.WarlockAlwaysDesc"] = "Gli stregoni lo vedono sempre; le altre classi solo al controllo prontezza"
L["Options.Soulstone.AlwaysDesc"] = "Mostra quando la categoria presenza è visibile"
L["Options.Soulstone.HideCooldown"] = "Nascondi durante il recupero (stregone)"
L["Options.Soulstone.HideCooldown.Desc"] =
    "Se abilitato, gli stregoni non vedranno il promemoria pietra dell'anima mentre l'incantesimo è in recupero. Si applica solo agli stregoni."

-- ============================================================================
-- OPTIONS: FREE CONSUMABLES
-- ============================================================================
L["Options.FreeConsumables"] = "Consumabili Gratuiti"
L["Options.FreeConsumables.Note"] = "(pietre della salute, rune di potenziamento permanenti)"
L["Options.FreeConsumables.Override"] = "Ignora filtri contenuto"
L["Options.FreeConsumables.Override.Desc"] =
    "Se selezionato, i consumabili gratuiti usano le proprie impostazioni di visibilità per tipo di contenuto qui sotto.\n\nSe deselezionato, seguono gli stessi filtri contenuto degli altri consumabili."

-- ============================================================================
-- OPTIONS: ICONS
-- ============================================================================
L["Options.Icons"] = "Icone"
L["Options.ShowText"] = "Mostra testo sulle icone"
L["Options.ShowText.Desc"] = "Mostra il conteggio o il testo di assenza sulle icone buff per questa categoria"
L["Options.ShowMissingCountOnly"] = "Mostra solo il conteggio mancanti"
L["Options.ShowMissingCountOnly.Desc"] =
    'Mostra solo il numero di buff mancanti (es. "1") invece del conteggio completo (es. "19/20")'
L["Options.ShowBuffReminderText"] = 'Mostra testo promemoria "BUFF!"'
L["Options.BuffTextOffsetX"] = '"BUFF!" X'
L["Options.BuffTextOffsetY"] = '"BUFF!" Y'
L["Options.Size"] = "Dimensione"

-- ============================================================================
-- OPTIONS: CLICK TO CAST
-- ============================================================================
L["Options.ClickToCast"] = "Clicca per lanciare"
L["Options.ClickToCast.DescFull"] =
    "Rendi le icone buff cliccabili per lanciare l'incantesimo corrispondente (solo fuori dal combattimento). Funziona solo per gli incantesimi che il tuo personaggio può lanciare."
L["Options.HoverHighlight"] = "Evidenziazione al passaggio"
L["Options.HoverHighlight.Desc"] =
    "Mostra una leggera evidenziazione al passaggio del mouse sulle icone buff cliccabili."

-- ============================================================================
-- OPTIONS: PET
-- ============================================================================
L["Options.PetSpecIcon"] = "Mostra icona spec pet al passaggio del mouse"
L["Options.PetSpecIcon.Title"] = "Icona spec pet al passaggio"
L["Options.PetSpecIcon.Desc"] =
    "Cambia l'icona del pet con la sua abilità di specializzazione (Astuzia, Ferocia, Tenacia) al passaggio del mouse."
L["Options.ShowItemTooltips"] = "Mostra tooltip oggetti"
L["Options.ShowItemTooltips.Desc"] = "Al passaggio del mouse su un'icona consumabile, mostra il tooltip dell'oggetto."
L["Options.Behavior"] = "Comportamento"
L["Options.PetPassiveCombat"] = "Pet passivo solo in combattimento"
L["Options.PetPassiveCombat.Desc"] =
    "Mostra il promemoria pet passivo solo durante il combattimento. Se disabilitato, il promemoria è sempre visibile."
L["Options.FelDomination"] = "Usa Dominazione Vile prima dell'evocazione"
L["Options.FelDomination.Title"] = "Dominazione Vile"
L["Options.FelDomination.Desc"] =
    "Lancia automaticamente Dominazione Vile prima di evocare un demone tramite click-to-cast. Se Dominazione Vile è in recupero, l'evocazione procede normalmente. Richiede il talento Dominazione Vile."

-- ============================================================================
-- OPTIONS: PET DISPLAY
-- ============================================================================
L["Options.PetDisplay"] = "Visualizzazione pet"
L["Options.PetDisplay.Generic"] = "Icona generica"
L["Options.PetDisplay.GenericDesc"] = "Una singola icona generica 'NO PET'"
L["Options.PetDisplay.Summon"] = "Incantesimi di evocazione"
L["Options.PetDisplay.SummonDesc"] = "Ogni incantesimo di evocazione pet come icona separata"
L["Options.PetDisplay.Mode"] = "Modalità visualizzazione pet"
L["Options.PetDisplay.Mode.Desc"] = "Come vengono visualizzati i promemoria per pet mancanti."
L["Options.PetLabels"] = "Etichette pet"
L["Options.PetLabels.Desc"] = "Mostra il nome del pet e la specializzazione sotto ogni icona."
L["Options.PetLabels.SizePct"] = "Dimensione %"

-- ============================================================================
-- OPTIONS: CONSUMABLE DISPLAY
-- ============================================================================
L["Options.ConsumableTextScale"] = "Scala testo"
L["Options.ConsumableTextScale.Title"] = "Scala testo consumabili"
L["Options.ConsumableTextScale.Desc"] =
    "Dimensione del carattere per i conteggi degli oggetti e le etichette di qualità (R1/R2/R3) in percentuale rispetto alla dimensione dell'icona."
L["Options.ItemDisplay"] = "Visualizzazione oggetti"
L["Options.ItemDisplay.IconOnly"] = "Solo icona"
L["Options.ItemDisplay.IconOnlyDesc"] = "Mostra l'oggetto con il conteggio più alto"
L["Options.ItemDisplay.SubIcons"] = "Sotto-icone"
L["Options.ItemDisplay.SubIconsDesc"] = "Piccole varianti oggetto cliccabili sotto ogni icona"
L["Options.ItemDisplay.Expanded"] = "Espanso"
L["Options.ItemDisplay.ExpandedDesc"] = "Ogni variante oggetto come icona a dimensione piena"
L["Options.ItemDisplay.Mode"] = "Visualizzazione oggetti consumabili"
L["Options.ItemDisplay.Mode.Desc"] =
    "Come vengono visualizzati gli oggetti consumabili con varianti multiple (es. diversi tipi di fiala)."
L["Options.SubIconSide"] = "Lato"
L["Options.SubIconSide.Bottom"] = "Basso"
L["Options.SubIconSide.Top"] = "Alto"
L["Options.SubIconSide.Left"] = "Sinistra"
L["Options.SubIconSide.Right"] = "Destra"
L["Options.ShowWithoutItems"] = "Mostra senza oggetto in borsa"
L["Options.ShowWithoutItems.Title"] = "Mostra consumabili senza oggetti"
L["Options.ShowWithoutItems.Desc"] =
    "Se abilitato, i promemoria consumabili vengono mostrati anche se non hai l'oggetto nelle borse. Se disabilitato, vengono mostrati solo i consumabili che hai effettivamente con te."
L["Options.ShowWithoutItemsReadyCheckOnly"] = "Solo al ready check"
L["Options.ShowWithoutItemsReadyCheckOnly.Title"] = "Mostra oggetti mancanti solo al ready check"
L["Options.ShowWithoutItemsReadyCheckOnly.Desc"] =
    "Se abilitato, i consumabili non nelle borse vengono mostrati solo durante un ready check. Utile per ricordarti di rifornirti prima di un pull."
L["Options.DelveFoodOnly"] = "Solo cibo scorribande nelle scorribande"
L["Options.DelveFoodOnly.Desc"] =
    "Quando sei in una scorribanda, nascondi tutti i promemoria consumabili tranne il cibo delle scorribande."

-- ============================================================================
-- OPTIONS: DK RUNEFORGE PREFERENCES
-- ============================================================================
L["Options.RuneforgePreferences"] = "Preferenze Rune"
L["Options.RuneforgeNote"] =
    "Seleziona le rune previste per ogni specializzazione. Viene mostrato un promemoria quando viene applicata quella sbagliata o nessuna."
L["Options.RuneMainHand"] = "Mano Principale"
L["Options.RuneOffHand"] = "Mano Secondaria"
L["Options.RuneTwoHanded"] = "Due Mani"
L["Options.RuneDualWield"] = "Doppia Impugnatura"

-- ============================================================================
-- OPTIONS: BUFF SETTINGS GEAR ICONS
-- ============================================================================
L["Options.HealthstoneSettings"] = "Impostazioni Pietra della Salute"
L["Options.HealthstoneSettings.Note"] = "Configura visibilità e soglia scorte basse."
L["Options.SoulstoneSettings"] = "Impostazioni Pietra dell'Anima"
L["Options.SoulstoneSettings.Note"] = "Configura quando appare il promemoria pietra dell'anima."
L["Options.BronzeSettings"] = "Impostazioni Benedizione del Bronzo"
L["Options.BronzeSettings.Note"] = "Configura il promemoria Benedizione del Bronzo."
L["Options.BronzeHideInCombat"] = "Nascondi in combattimento"
L["Options.BronzeHideInCombat.Desc"] =
    "Nascondi il promemoria Benedizione del Bronzo durante il combattimento. Questo buff è meno critico e potresti non volerlo riapplicare durante lo scontro."
L["Options.PetPassiveSettings"] = "Impostazioni Pet Passivo"
L["Options.PetPassiveSettings.Note"] = "Configura il promemoria pet in modalità passiva."
L["Options.PetSummonSettings"] = "Impostazioni Evocazione Pet"
L["Options.PetSummonSettings.Note"] = "Configura il comportamento di evocazione pet."
L["Options.DelveFoodSettings"] = "Impostazioni Cibo delle Scorribande"
L["Options.DelveFoodSettings.Note"] = "Configura il comportamento del promemoria cibo delle scorribande."
L["Options.DelveFoodTimer"] = "Nascondi automaticamente dopo 30 secondi"
L["Options.DelveFoodTimer.Desc"] =
    "Se attivo, il promemoria del cibo delle scorribande appare solo per 30 secondi dopo l'ingresso, poi si nasconde automaticamente. Se disattivo, il promemoria resta visibile finché sei in una scorribanda e ti manca il buff."

-- ============================================================================
-- OPTIONS: LAYOUT
-- ============================================================================
L["Options.Layout"] = "Disposizione"
L["Options.Priority"] = "Priorità"
L["Options.Priority.Desc"] =
    "Controlla l'ordine di questa categoria nel frame combinato. I valori più bassi vengono mostrati per primi."
L["Options.SplitFrame"] = "Separa in un frame indipendente"
L["Options.SplitFrame.Desc"] = "Mostra i buff di questa categoria in un frame separato, spostabile indipendentemente"
L["Options.DisplayPriority"] = "Priorità di Visualizzazione"

-- ============================================================================
-- OPTIONS: APPEARANCE
-- ============================================================================
L["Options.CustomAppearance"] = "Usa aspetto personalizzato"
L["Options.CustomAppearance.Desc"] =
    "Se disabilitato, questa categoria eredita le impostazioni di aspetto dai Predefiniti Globali. La direzione di crescita richiede la separazione in un frame indipendente."
L["Options.Customize"] = "Personalizza"
L["Options.ResetPosition"] = "Ripristina Posizione"
L["Options.MasqueNote"] = "Le impostazioni di Zoom e Bordo sono gestite da Masque"

-- ============================================================================
-- OPTIONS: SETTINGS TAB
-- ============================================================================
L["Options.ShowLoginMessages"] = "Mostra messaggi di accesso"
L["Options.ShowMinimapButton"] = "Mostra pulsante minimappa"
L["Options.ShowOnlyInGroup"] = "Mostra solo in gruppo/incursione"

-- Hide when section
L["Options.HideWhen"] = "Nascondi quando:"
L["Options.HideWhen.Resting"] = "In zona di riposo"
L["Options.HideWhen.Resting.Title"] = "Nascondi in zona di riposo"
L["Options.HideWhen.Resting.Desc"] = "Nascondi i promemoria buff nelle locande o nelle capitali"
L["Options.HideWhen.Combat"] = "In combattimento"
L["Options.HideWhen.Expiring"] = "In scadenza in combattimento"
L["Options.HideWhen.Expiring.Title"] = "Nascondi buff in scadenza in combattimento"
L["Options.HideWhen.Expiring.Desc"] =
    "Durante il combattimento, nascondi i buff in scadenza e mostra solo quelli completamente mancanti"
L["Options.HideWhen.Vehicle"] = "In veicolo"
L["Options.HideWhen.Vehicle.Title"] = "Nascondi in veicolo"
L["Options.HideWhen.Vehicle.Desc"] =
    "Nascondi tutti i promemoria buff durante un veicolo quest. Se disabilitato, i buff del raid e di presenza restano visibili"
L["Options.HideWhen.Mounted"] = "In sella"
L["Options.HideWhen.Mounted.Title"] = "Nascondi in sella"
L["Options.HideWhen.Mounted.Desc"] =
    "Nascondi tutti i promemoria buff in sella. Sovrascrive l'impostazione di nascondimento pet per categoria"
L["Options.HideWhen.Legacy"] = "In istanze eredità"
L["Options.HideWhen.Legacy.Title"] = "Nascondi in istanze eredità"
L["Options.HideWhen.Legacy.Desc"] =
    "Nascondi tutti i promemoria buff nelle istanze banalmente vecchie (dove il bottino eredità è attivato)"
L["Options.HideWhen.Leveling"] = "Durante il livellamento"
L["Options.HideWhen.Leveling.Title"] = "Nascondi durante il livellamento"
L["Options.HideWhen.Leveling.Desc"] = "Nascondi tutti i promemoria buff quando sei sotto il livello massimo"

-- ============================================================================
-- OPTIONS: BUFF TRACKING MODE
-- ============================================================================
L["Options.BuffTracking"] = "Tracciamento buff"
L["Options.BuffTracking.All"] = "Tutti i buff, tutti i giocatori"
L["Options.BuffTracking.All.Desc"] =
    "Mostra tutti i buff del raid e di presenza per ogni classe, tracciando la copertura dell'intero gruppo."
L["Options.BuffTracking.MyBuffs"] = "Solo i miei buff, tutti i giocatori"
L["Options.BuffTracking.MyBuffs.Desc"] =
    "Mostra solo i buff che la tua classe può fornire. Traccia comunque la copertura dell'intero gruppo."
L["Options.BuffTracking.OnlyMine"] = "Solo i buff che mi servono"
L["Options.BuffTracking.OnlyMine.Desc"] =
    "Mostra tutti i tipi di buff, ma controlla solo se li hai personalmente. Nessun conteggio di gruppo."
L["Options.BuffTracking.Smart"] = "Automatico"
L["Options.BuffTracking.Smart.Desc"] =
    "I buff della tua classe tracciano la copertura dell'intero gruppo. I buff delle altre classi controllano solo te."
L["Options.BuffTracking.Mode"] = "Modalità tracciamento buff"
L["Options.BuffTracking.Mode.Desc"] =
    "Controlla quali buff del raid e di presenza vengono mostrati, e se tracciano l'intero gruppo o solo te."

-- ============================================================================
-- OPTIONS: PROFILES TAB
-- ============================================================================
L["Options.ActiveProfile"] = "Profilo Attivo"
L["Options.ActiveProfile.Desc"] = "Passa tra le configurazioni salvate. Ogni personaggio può usare un profilo diverso."
L["Options.SelectProfile"] = "Seleziona un profilo"
L["Options.Profile"] = "Profilo"
L["Options.CopyFrom"] = "Copia Da"
L["Options.Delete"] = "Elimina"
L["Options.PerSpecProfiles"] = "Profili per Specializzazione"
L["Options.PerSpecProfiles.Desc"] = "Cambia automaticamente profilo quando cambi specializzazione."
L["Options.PerSpecProfiles.Enable"] = "Abilita profili per specializzazione"

-- ============================================================================
-- OPTIONS: IMPORT/EXPORT
-- ============================================================================
L["Options.ExportSettings"] = "Esporta Impostazioni"
L["Options.ExportSettings.Desc"] = "Copia la stringa qui sotto per condividere le tue impostazioni."
L["Options.ImportSettings"] = "Importa Impostazioni"
L["Options.ImportSettings.DescPlain"] = "Incolla una stringa di impostazioni qui sotto."
L["Options.ImportSettings.Overwrite"] = "Questo sovrascriverà il profilo attivo."
L["Options.Export"] = "Esporta"
L["Options.Import"] = "Importa"
L["Options.ImportSuccess"] = "Impostazioni importate con successo!"
L["Options.FailedExport"] = "Esportazione fallita"
L["Options.UnknownError"] = "Errore sconosciuto"

-- ============================================================================
-- OPTIONS: DIALOGS
-- ============================================================================
L["Dialog.Cancel"] = "Annulla"
L["Dialog.DeleteCustomBuff"] = 'Eliminare il buff personalizzato "%s"?'
L["Dialog.ResetProfile"] =
    "Ripristinare il profilo attivo ai valori predefiniti?\n\nQuesto cancellerà tutte le personalizzazioni\nnel profilo corrente e ricaricherà l'interfaccia."
L["Dialog.Reset"] = "Ripristina"
L["Dialog.ReloadPrompt"] = "Impostazioni importate con successo!\nRicaricare l'interfaccia per applicare le modifiche?"
L["Dialog.Reload"] = "Ricarica"
L["Dialog.NewProfilePrompt"] = "Inserisci un nome per il nuovo profilo:"
L["Dialog.Create"] = "Crea"
L["Dialog.DiscordPrompt"] = "Unisciti al Discord di BuffReminders!\nCopia l'URL qui sotto (Ctrl+C):"
L["Dialog.Close"] = "Chiudi"

-- ============================================================================
-- OPTIONS: TEST / LOCK
-- ============================================================================
L["Options.LockUnlock"] = "Blocca / Sblocca"
L["Options.LockUnlock.Desc"] = "Sblocca per mostrare le maniglie di ancoraggio per riposizionare i frame buff."
L["Options.TestAppearance"] = "Testa l'aspetto delle icone"
L["Options.TestAppearance.Desc"] =
    "Mostra i buff selezionati con valori fittizi per visualizzare l'anteprima del loro aspetto."
L["Options.Test"] = "Test"
L["Options.StopTest"] = "Ferma Test"
L["Options.AnchorHint"] = "Clicca un'ancora per aggiornare il suo punto di ancoraggio o le coordinate"
L["Options.Lock"] = "Blocca"
L["Options.Unlock"] = "Sblocca"

-- ============================================================================
-- OPTIONS: CUSTOM BUFF MODAL
-- ============================================================================
L["CustomBuff.Edit"] = "Modifica Buff Personalizzato"
L["CustomBuff.Add"] = "Aggiungi Buff Personalizzato"
L["CustomBuff.AddButton"] = "+ Aggiungi Buff Personalizzato"
L["CustomBuff.SpellIDs"] = "ID Incantesimo:"
L["CustomBuff.Lookup"] = "Cerca"
L["CustomBuff.AddSpellID"] = "+ Aggiungi ID Incantesimo"
L["CustomBuff.Name"] = "Nome:"
L["CustomBuff.Text"] = "Testo:"
L["CustomBuff.LineBreakHint"] = "(usa \\n per andare a capo)"
L["CustomBuff.Appearance"] = "ASPETTO"
L["CustomBuff.ShowIn"] = "MOSTRA IN"
L["CustomBuff.ClickAction"] = "AZIONE AL CLICK"
L["CustomBuff.SettingsMovedNote"] =
    "Le impostazioni di visibilità e controllo prontezza sono state spostate nel menu di modifica di ogni buff."

-- Custom buff mode toggles
L["CustomBuff.WhenActive"] = "Quando attivo"
L["CustomBuff.WhenMissing"] = "Quando mancante"
L["CustomBuff.OnlyIfSpellKnown"] = "Solo se incantesimo conosciuto"

-- Custom buff class dropdown
L["Class.Any"] = "Qualsiasi"
L["Class.DeathKnight"] = "Cavaliere della Morte"
L["Class.DemonHunter"] = "Cacciatore di Demoni"
L["Class.Druid"] = "Druido"
L["Class.Evoker"] = "Evocatore"
L["Class.Hunter"] = "Cacciatore"
L["Class.Mage"] = "Mago"
L["Class.Monk"] = "Monaco"
L["Class.Paladin"] = "Paladino"
L["Class.Priest"] = "Sacerdote"
L["Class.Rogue"] = "Ladro"
L["Class.Shaman"] = "Sciamano"
L["Class.Warlock"] = "Stregone"
L["Class.Warrior"] = "Guerriero"

-- Custom buff fields
L["CustomBuff.Spec"] = "Spec:"
L["CustomBuff.Class"] = "Classe:"
L["CustomBuff.RequireItem"] = "Richiedi oggetto:"
L["CustomBuff.RequireItem.EquippedBags"] = "Equipaggiato/Borse"
L["CustomBuff.RequireItem.Equipped"] = "Equipaggiato"
L["CustomBuff.RequireItem.InBags"] = "Nelle borse"
L["CustomBuff.RequireItem.Hint"] = "ID oggetto — nascondi se non trovato"

-- Bar glow options
L["CustomBuff.BarGlow.WhenGlowing"] = "Rileva quando brilla"
L["CustomBuff.BarGlow.WhenNotGlowing"] = "Rileva quando non brilla"
L["CustomBuff.BarGlow.Disabled"] = "Disabilitato"
L["CustomBuff.BarGlow"] = "Bagliore barra:"
L["CustomBuff.BarGlow.Title"] = "Bagliore barra azioni di riserva"
L["CustomBuff.BarGlow.Desc"] =
    "Rilevamento di riserva tramite il bagliore degli incantesimi nella barra azioni durante M+/PvP/combattimento quando l'API dei buff è limitata. Disabilita se vuoi solo il tracciamento della presenza del buff."

-- Ready check / level
L["CustomBuff.ReadyCheckOnly"] = "Solo al controllo prontezza"
L["CustomBuff.Level"] = "Livello:"
L["CustomBuff.Level.Any"] = "Qualsiasi livello"
L["CustomBuff.Level.Max"] = "Solo livello massimo"
L["CustomBuff.Level.BelowMax"] = "Sotto il livello massimo"

-- Click action
L["CustomBuff.Action.None"] = "Nessuna"
L["CustomBuff.Action.Spell"] = "Incantesimo"
L["CustomBuff.Action.Item"] = "Oggetto"
L["CustomBuff.Action.Macro"] = "Macro"
L["CustomBuff.Action.OnClick"] = "Al click:"
L["CustomBuff.Action.Title"] = "Azione al click"
L["CustomBuff.Action.Desc"] =
    "Cosa succede quando clicchi questa icona buff. Incantesimo lancia un incantesimo, Oggetto usa un oggetto, Macro esegue un comando macro."
L["CustomBuff.Action.MacroHint"] = "es. /use item:12345\\n/use 13"

-- Save/Cancel/Delete
L["CustomBuff.Save"] = "Salva"
L["CustomBuff.ValidateError"] = "Convalida almeno un ID incantesimo"

-- Custom buff tooltip
L["CustomBuff.Tooltip.Title"] = "Buff Personalizzato"
L["CustomBuff.Tooltip.Desc"] = "Click destro per modificare o eliminare"

-- Custom buff status
L["CustomBuff.InvalidID"] = "ID non valido"
L["CustomBuff.NotFound"] = "Non trovato"
L["CustomBuff.NotFoundRetry"] = "Non trovato (riprova)"
L["CustomBuff.Error"] = "Errore:"

-- ============================================================================
-- OPTIONS: DISCORD
-- ============================================================================
L["Options.JoinDiscord"] = "Unisciti al Discord"
L["Options.JoinDiscord.Title"] = "Clicca per il link di invito"
L["Options.JoinDiscord.Desc"] = "Hai feedback, richieste di funzionalità o segnalazioni di bug?\nUnisciti al Discord!"

-- ============================================================================
-- OPTIONS: CUSTOM ANCHOR FRAMES
-- ============================================================================
L["Options.CustomAnchorFrames"] = "Frame di Ancoraggio Personalizzati"
L["Options.CustomAnchorFrames.Desc"] =
    "Aggiungi nomi di frame globali al menu di ancoraggio (es. MyAddon_PlayerFrame).\nI frame che non esistono nel gioco vengono ignorati automaticamente."
L["Options.Add"] = "Aggiungi"
L["Options.New"] = "Nuovo"
L["Options.ResetToDefaults"] = "Ripristina Predefiniti"

-- ============================================================================
-- OPTIONS: MISC
-- ============================================================================
L["Options.Off"] = "Spento"
L["Options.Always"] = "Sempre"
L["Options.ReadyCheck"] = "Controllo prontezza"
L["Options.Min"] = "min"

-- ============================================================================
-- COMPONENTS (UI/Components.lua)
-- ============================================================================
-- Content filter tooltip
L["Content.ClickToFilter"] = "Clicca per filtrare per difficoltà %s"

-- Mover labels
L["Mover.AnchorGrowth"] = "Ancora · Crescita %s"
L["Mover.AnchorGrowthFrame"] = "Ancora · Crescita %s · > %s"

-- Pet labels
L["Pet.SpiritBeast"] = "Bestia Spirito"

-- Appearance grid labels
L["Appearance.Width"] = "Larghezza"
L["Appearance.Height"] = "Altezza"
L["Appearance.Zoom"] = "Zoom"
L["Appearance.Border"] = "Bordo"
L["Appearance.Spacing"] = "Spaziatura"
L["Appearance.Alpha"] = "Opacità"
L["Appearance.Text"] = "Testo"
L["Appearance.TextX"] = "Testo X"
L["Appearance.TextY"] = "Testo Y"

-- Slider tooltip
L["Component.AdjustValue"] = "Regola valore"
L["Component.AdjustValue.Desc"] = "Clicca per digitare o usa la rotella del mouse"

-- Direction labels
L["Direction.Left"] = "Sinistra"
L["Direction.Center"] = "Centro"
L["Direction.Right"] = "Destra"
L["Direction.Up"] = "Su"
L["Direction.Down"] = "Giù"
L["Direction.Label"] = "Direzione"

-- Content visibility
L["Content.ShowIn"] = "Mostra in:"

-- Content toggle definitions
L["Content.OpenWorld"] = "Mondo Aperto"
L["Content.Housing"] = "Dimora"
L["Content.Scenarios"] = "Scenari (Scorribande, Torghast, ecc.)"
L["Content.Dungeons"] = "Spedizioni (incluse M+)"
L["Content.Raids"] = "Incursioni"
L["Content.PvP"] = "PvP (Arena e Campi di Battaglia)"

-- Scenario difficulty
L["Content.Delves"] = "Scorribande"
L["Content.OtherScenarios"] = "Altri Scenari (Torghast, ecc.)"

-- Dungeon difficulty
L["Content.NormalDungeons"] = "Spedizioni Normali"
L["Content.HeroicDungeons"] = "Spedizioni Eroiche"
L["Content.MythicDungeons"] = "Spedizioni Mitiche"
L["Content.MythicPlus"] = "Chiavi Mitiche+"
L["Content.TimewalkingDungeons"] = "Spedizioni Cavalcatempo"
L["Content.FollowerDungeons"] = "Spedizioni con Seguaci"

-- Raid difficulty
L["Content.LFR"] = "Cerca Incursione"
L["Content.NormalRaids"] = "Incursioni Normali"
L["Content.HeroicRaids"] = "Incursioni Eroiche"
L["Content.MythicRaids"] = "Incursioni Mitiche"

-- PvP types
L["Content.Arena"] = "Arena"
L["Content.Battlegrounds"] = "Campi di Battaglia"
