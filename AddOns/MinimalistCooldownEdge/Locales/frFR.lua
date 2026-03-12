-- frFR.lua (French)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "frFR")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Impossible d'ouvrir les options en combat."
L["MiniCC test command is unavailable."] = "La commande de test de MiniCC n'est pas disponible."

-- Category Names
L["Action Bars"] = "Barres d'action"
L["Nameplates"] = "Barres de nom"
L["Unit Frames"] = "Cadres d'unité"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "Autres"

-- Group Headers
L["General"] = "Général"
L["Typography (Cooldown Numbers)"] = "Typographie (chiffres de recharge)"
L["Swipe Animation"] = "Animation de balayage"
L["Stack Counters / Charges"] = "Compteurs de cumuls / charges"
L["Maintenance"] = "Maintenance"
L["Danger Zone"] = "Zone de danger"
L["Style"] = "Style"
L["Positioning"] = "Positionnement"
L["CooldownManager Viewers"] = "Afficheurs de CooldownManager"
L["MiniCC Frame Types"] = "Types de cadres MiniCC"

-- Toggles & Settings
L["Enable %s"] = "Activer %s"
L["Toggle styling for this category."] = "Active ou désactive le style pour cette catégorie."
L["Font Face"] = "Police"
L["Font"] = "Police"
L["Size"] = "Taille"
L["Outline"] = "Contour"
L["Color"] = "Couleur"
L["Hide Numbers"] = "Masquer les chiffres"
L["Compact Party / Raid Aura Text"] = "Texte d'aura de groupe / raid compact"
L["Enable Party Aura Text"] = "Activer le texte d'aura du groupe"
L["Enable Raid Aura Text"] = "Activer le texte d'aura du raid"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Masque entièrement le texte (utile si vous ne voulez que le bord de balayage ou les cumuls)."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Affiche un texte de compte à rebours stylisé sur les icônes d'améliorations et d'affaiblissements de Blizzard CompactPartyFrame. La désactivation masque le texte des auras sur les cadres de groupe."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Affiche un texte de compte à rebours stylisé sur les icônes d'améliorations et d'affaiblissements de Blizzard CompactRaidFrame. La désactivation masque le texte des auras sur les cadres de raid."
L["Anchor Point"] = "Point d'ancrage"
L["Offset X"] = "Décalage X"
L["Offset Y"] = "Décalage Y"
L["Essential Viewer Size"] = "Taille de l'afficheur Essential"
L["Utility Viewer Size"] = "Taille de l'afficheur Utility"
L["Buff Icon Viewer Size"] = "Taille de l'afficheur d'icônes d'améliorations"
L["CC Text Size"] = "Taille du texte de CC"
L["Nameplates Text Size"] = "Taille du texte des barres de nom"
L["Portraits Text Size"] = "Taille du texte des portraits"
L["Alerts / Overlay Text Size"] = "Taille du texte des alertes / superpositions"
L["Toggle Test Icons"] = "Afficher ou masquer les icônes de test"
L["Show Swipe Edge"] = "Afficher le bord de balayage"
L["Shows the white line indicating cooldown progress."] = "Affiche la ligne blanche indiquant la progression de la recharge."
L["Edge Thickness"] = "Épaisseur du bord"
L["Scale of the swipe line (1.0 = Default)."] = "Échelle de la ligne de balayage (1.0 = par défaut)."
L["Customize Stack Text"] = "Personnaliser le texte des cumuls"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Prenez le contrôle du compteur de charges (par ex. 2 charges de Conflagration)."
L["Reset %s"] = "Réinitialiser %s"
L["Revert this category to default settings."] = "Rétablit cette catégorie à ses réglages par défaut."
L["Toggle MiniCC's built-in test icons using /minicc test."] = "Active ou désactive les icônes de test intégrées de MiniCC avec /minicc test."

-- Outline Values
L["None"] = "Aucun"
L["Thick"] = "Épais"
L["Mono"] = "Mono"

-- Anchor Point Values
L["Bottom Right"] = "Bas droite"
L["Bottom Left"] = "Bas gauche"
L["Top Right"] = "Haut droite"
L["Top Left"] = "Haut gauche"
L["Center"] = "Centre"

-- General Tab
L["Factory Reset (All)"] = "Réinitialisation usine (tout)"
L["Resets the entire profile to default values and reloads the UI."] = "Réinitialise tout le profil à ses valeurs par défaut et recharge l'interface."
L["Import / Export"] = "Import / Export"
L["PROFILE_IMPORT_EXPORT_DESC"] = "Exporte le profil AceDB actif sous forme de chaîne partageable, ou importe une chaîne pour remplacer les paramètres du profil actuel."
L["Export current profile"] = "Exporter le profil actuel"
L["Generate export"] = "Générer l'export"
L["Export code"] = "Code d'export"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "Générez une chaîne d'export, puis cliquez dans cette zone pour la copier avec Ctrl+C."
L["Import profile"] = "Importer un profil"
L["Import code"] = "Code d'import"
L["Paste an exported string here, then click Import."] = "Collez ici une chaîne exportée, puis cliquez sur Importer."
L["Import"] = "Importer"
L["Importing will overwrite the current profile settings. Continue?"] = "L'importation écrasera les paramètres du profil actuel. Continuer ?"
L["Export string generated. Copy it with Ctrl+C."] = "Chaîne d'export générée. Copiez-la avec Ctrl+C."
L["Profile import completed."] = "Import du profil terminé."
L["No active profile available."] = "Aucun profil actif disponible."
L["Failed to encode export string."] = "Impossible d'encoder la chaîne d'export."
L["Paste an import string first."] = "Collez d'abord une chaîne d'import."
L["Invalid import string format."] = "Format de chaîne d'import invalide."
L["Failed to decode import string."] = "Impossible de décoder la chaîne d'import."
L["Failed to decompress import string."] = "Impossible de décompresser la chaîne d'import."
L["Failed to deserialize import string."] = "Impossible de désérialiser la chaîne d'import."

-- Banner
L["BANNER_DESC"] = "Configuration minimaliste pour vos recharges. Sélectionnez une catégorie à gauche pour commencer."

-- Chat Messages
L["%s settings reset."] = "Paramètres de %s réinitialisés."
L["Profile reset. Reloading UI..."] = "Profil réinitialisé. Rechargement de l'interface..."

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"

-- General Dashboard
L["Enable categories styling"] = "Activer le style des catégories"
L["LIVE_CONTROLS_DESC"] = "Les changements s'appliquent immédiatement. Ne laissez actives que les catégories que vous utilisez vraiment pour une configuration plus propre."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Affiche un texte de compte à rebours stylisé sur les icônes d'améliorations et d'affaiblissements de Blizzard CompactPartyFrame et CompactRaidFrame. Le groupe et le raid peuvent être activés séparément. Cela reste indépendant de la catégorie Autres."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copiez ce lien pour ouvrir la page du projet CurseForge dans votre navigateur."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copiez ce lien pour voir les autres projets d'Anahkas sur CurseForge."

-- Help
L["Help & Support"] = "Aide et assistance"
L["Project"] = "Projet"
L["Useful Addons"] = "Addons utiles"
L["Support & Feedback"] = "Assistance et retours"
L["MCE_HELP_INTRO"] = "Quelques liens utiles pour le projet et deux addons qui valent le détour."
L["HELP_SUPPORT_DESC"] = "Les suggestions et les retours sont toujours les bienvenus.\n\nSi vous trouvez un bug ou avez une idée de fonctionnalité, n'hésitez pas à laisser un commentaire ou un message privé sur CurseForge."
L["HELP_COMPANION_DESC"] = "Quelques addons sobres qui vont très bien avec MiniCE."
L["HELP_MINICC_DESC"] = "Suivi compact des contrôles. MiniCE peut aussi en styliser le texte."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "Copiez ce lien pour ouvrir la page CurseForge de MiniCC dans votre navigateur."
L["HELP_PVPTAB_DESC"] = "Fait en sorte que TAB cible uniquement les joueurs en JcJ. Idéal pour les arènes et les champs de bataille."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copiez ce lien pour ouvrir la page CurseForge de Smart PvP Tab Targeting dans votre navigateur."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Activez ou désactivez vos principales catégories de recharge depuis un seul endroit."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Cette action est irréversible. Votre profil sera entièrement réinitialisé et l'interface sera rechargée."
L["MAINTENANCE_DESC"] = "Rétablit cette catégorie à ses paramètres d'usine. Les autres catégories ne sont pas affectées."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Personnalisez les recharges sur vos barres d'action principales, y compris Bartender4, Dominos et ElvUI."
L["NAMEPLATE_DESC"] = "Stylez les recharges affichées sur les barres de nom ennemies et alliées (Plater, KuiNameplates, etc.)."
L["UNITFRAME_DESC"] = "Ajustez le style des recharges sur les cadres du joueur, de la cible et du focus."
L["COOLDOWNMANAGER_DESC"] = "Style d'icône partagé pour les afficheurs de CooldownManager. La taille du texte du compte à rebours peut être réglée séparément pour les afficheurs Essential, Utility et d'icônes d'améliorations."
L["MINICC_DESC"] = "Style dédié aux icônes de recharge de MiniCC. Prend en charge les icônes de contrôle de foule, les barres de nom, les portraits et les modules de type superposition de MiniCC lorsqu'il est chargé."
L["OTHERS_DESC"] = "Catégorie fourre-tout pour les recharges qui n'appartiennent à aucune autre catégorie (sacs, menus, addons divers)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Couleurs dynamiques du texte"
L["Color by Remaining Time"] = "Colorer selon le temps restant"
L["Dynamically colors the countdown text based on how much time is left."] = "Colorie dynamiquement le texte du compte à rebours selon le temps restant."
L["DYNAMIC_COLORS_DESC"] = "Change la couleur du texte en fonction du temps de recharge restant. Remplace la couleur statique ci-dessus lorsqu'elle est activée."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Applique les mêmes seuils de temps restant à chaque catégorie MiniCE activée, y compris le texte d'aura de groupe / raid compact. La gestion des durées reste fiable même au passage de minuit lorsque Blizzard n'expose que des valeurs cachées."
L["Expiring Soon"] = "Expiration imminente"
L["Short Duration"] = "Courte durée"
L["Long Duration"] = "Longue durée"
L["Beyond Thresholds"] = "Au-delà des seuils"
L["Threshold (seconds)"] = "Seuil (secondes)"
L["Default Color"] = "Couleur par défaut"
L["Color used when the remaining time exceeds all thresholds."] = "Couleur utilisée lorsque le temps restant dépasse tous les seuils."

-- Abbreviation
L["Abbreviate Above"] = "Abréger au-dessus de"
L["Abbreviate Above (seconds)"] = "Abréger au-dessus de (secondes)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Les durées au-dessus de ce seuil seront abrégées (ex. 5m au lieu de 300)."
L["ABBREV_THRESHOLD_DESC"] = "Définit quand les durées passent en format abrégé. Les minuteries au-dessus de ce seuil affichent des valeurs raccourcies comme 5m ou 1h."
