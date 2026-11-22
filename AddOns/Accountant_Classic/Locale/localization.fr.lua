-- French localization for Accountant Classic

-- FR Translation, thanks to Thi0u ;)

local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "frFR", false)

if not L then return end

-- Header
L["Accountant Classic"] = "Accountant Classic"
L["A basic tool to track your monetary incomings and outgoings within WoW."] = "Un simple outil permettant de suivre vos dépenses et revenus dans WoW."
L[ [=[Left-Click to open Accountant Classic.
Right-Click for Accountant Classic options.
Left-click and drag to move this button.]=] ] = [=[Clic-Gauche pour ouvrir Accountant Classic.
Clic-Droit pour les options d'Accountant Classic.]=]
L[ [=[Left-click and drag to move this button.
Right-Click to open Accountant Classic.]=] ] = [=[Clic-gauche pour bouger ce bouton.
Clic-droit pour ouvrir Accountant Classic.]=]
L["Total Incomings"] = "Rentrées Totales"
L["Total Outgoings"] = "Dépenses Totales"
L["Net Profit / Loss"] = "Bénéfices/Pertes Nettes"
L["Net Loss"] = "Pertes Nettes "
L["Net Profit"] = "Bénéfices Nets"
L["Source"] = "Sources"
L["Incomings"] = "Rentrées"
L["Outgoings"] = "Dépenses"
L["Week Start"] = "Début de semaine"
L["Sum Total"] = "Somme Totale"
L["Character"] = "Personnage"
L["Money"] = "Argent"
L["Updated"] = "Mis à jour"

-- Section Labels
L["Quest Rewards"] = "Récompense de quêtes"
L["Merchants"] = "Marchands"
L["Trade Window"] = "Fenêtre d'échange"
L["Mail"] = "Courrier"
L["Training Costs"] = "Coût d'entraînement"
L["Taxi Fares"] = "Prix du Taxi"
L["Unknown"] = "Inconnu"
L["Repair Costs"] = "Coût de réparation"
L["LFD, LFR and Scen."] = "LFD, LFR et scénarios."

-- Buttons
L["Reset"] = "Reset"
L["Options"] = "Options"
L["Exit"] = "Exit"

-- Tabs' name
L["This Session"] = "Cette session"
L["Today"] = "Aujourd'hui"
L["Prv. Day"] = "Jour précédent "
L["This Week"] = "Cette semaine"
L["Prv. Week"] = "Semaine précédente"
L["This Month"] = "Ce mois"
L["Prv. Month"] = "Mois précédent"
L["This Year"] = "Cette Année"
L["Prv. Year"] = "Année précédente"
L["Total"] = "Total"
L["All Chars"] = "Persos"

-- Options
L["Accountant Classic Options"] = "Accountant Classic Options"
L["Show minimap button"] = "Afficher le bouton de la minimap"
L["Show money"] = "Afficher l'argent"
L["Show money on minimap button's tooltip"] = "Afficher l'argent dans le tooltip du bouton de la minimap"
L["Show session info"] = "Voir les infos de la session"
L["Show session info on minimap button's tooltip"] = "Afficher les dépenses et revenus de la session dans le tooltip du bouton de la minimap"
L["Show money on screen"] = "Afficher l'argent à l'écran"
L["Reset position"] = "Réinitialiser la position"
L["Reset money frame's position"] = "Réinitialise la position de l'affichage de l'argent"
L["Minimap Button Settings"] = "Paramètres du bouton de la minimap"
L["Minimap Button Position"] = "Position du bouton de la Minimap"
L["Start of Week"] = "Début de Semaine"
L["Done"] = "Done"
L["Display Instruction Tips"] = "Afficher les aides"
L["Toggle whether to display minimap button or floating money frame's operation tips."] = "Afficher ou non le bouton sur la minimap ou les infobulles sur les opérations"
L["Select the character to be removed:"] = "Sélectionner le personnage à supprimer:"
L["The selected character's Accountant Classic data will be removed."] = "Les données Accoutant Classic du joueur seront supprimées"
L["|cffffffff\"%s - %s|cffffffff\" character's Accountant Classic data has been removed."] = "|cffffffffLes données Accoutant Classic du joueur \"%s - %s|cffffffff\" ont été supprimées"
L["Select the date format:"] = "Sélectionnez le format de la date"
L["Date format showing in \"All Chars\" and \"Week\" tabs"] = "Format de date affiché dans les onglets \"Persos\" et \"Semaine\""
L["Show all realms' characters info"] = "Afficher les infos des personnages de chaque royaume"
L["Enable to show all characters' money info from all realms. Disable to only show current realm's character info."] = "Activer pour afficher l'argent des personnes de toutes les royaumes. Désactiver pour afficher uniquement les infos du royaume du personnage actuel."
L["Track location of incoming / outgoing money"] = "Suivre l'emplacement des dépenses et recettes"
L["Main Frame's Scale and Alpha Settings"] = "Taille et transparence de la fenêtre principale"
L["Character Data's Removal"] = "Suppression des données d'un personnage"
L["Profile Options"] = "Options du Profil"
L["Scale and Transparency"] = "Taille et transparence"
L["Remember character selected"] = "Se souvenir du personnage selectionné"
L["Remember the latest character selection in dropdown menu."] = "Se souvenir du dernier personnage sélectionné dans la liste déroulante"
L["Show all factions' characters info"] = "Afficher les infos des personnages de chaque faction"
L["Enhanced Tracking Options"] = "Options de suivi améliorées"
L["All Factions"] = "Toutes les factions"
L["All Servers"] = "Tous les serveurs"

-- Misc
L["Are you sure you want to reset the \"%s\" data?"] = "Êtes-vous certain de vouloir réinitialiser les données \"%s\" ?"
L["New Accountant Classic profile created for %s"] = "Nouveau profil Accountant Classic créé pour %s"
L["Loaded Accountant Classic Profile for %s"] = "Profil Accountant Classic chargé pour %s"
L["Accountant Classic loaded."] = "Accountant Classic chargé"
L["g "] = "g "
L["s "] = "s "
L["c"] = "c"
L["About"] = "A propos"
L["Show All Characters"] = "Montrer tous les personnages"
L["Show all characters' incoming and outgoing data."] = "Afficher les dépenses et recettes de toutes les personnages"

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) Or"
L["(%d+) Silver"] = "(%d+) Argent"
L["(%d+) Copper"] = "(%d+) Cuivre"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Afficher Accountant Classic"

-- History ledger
L["Remove, keep history"] = "Supprimer en conservant l'historique"
L["Remove with history"] = "Supprimer avec l'historique"
L["Delete the entire Accountant Classic history ledger of all characters?\nThe classic period data is not affected."] = "Supprimer l'intégralité de l'historique Accountant Classic de tous les personnages ?\nLes données par période des statistiques classiques ne seront pas affectées."
L["The history ledger has been deleted."] = "L'historique a été supprimé."
L["The history ledger was saved by a newer version of Accountant Classic and is read-only."] = "L'historique a été enregistré avec une version plus récente d'Accountant Classic et est en lecture seule."
L["History matches today's classic data (%d categories)."] = "L'historique correspond aux données d'aujourd'hui des statistiques classiques (%d catégories)."
L["%d categories differ from today's classic data."] = "%d catégories diffèrent des données d'aujourd'hui des statistiques classiques."
L["History tracking started today, so money logged earlier today exists only in the classic data."] = "Le suivi de l'historique a commencé aujourd'hui. Les mouvements d'argent enregistrés plus tôt dans la journée, avant son activation, figurent donc uniquement dans les statistiques classiques."
L["Resetting the Day tab also causes differences; the history ledger is never reset with it."] = "La réinitialisation de l'onglet du jour entraîne également des différences ; l'historique n'est jamais réinitialisé avec cet onglet."
