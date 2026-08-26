-- frFR.lua (French)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "frFR")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras gère les couleurs de seuil du compte à rebours. Configurez-les dans MiniAuras > Misc > Countdown Colours."
L["MYDRS_SWIPE_ALPHA_DESC"] = "0 % = transparent, 100 % = totalement sombre. Remplace le réglage Cooldown Swipe Alpha de MyDRs tant que cette catégorie est activée ; 100 % correspond au balayage dessiné par MyDRs."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0 % = transparent, 100 % = totalement sombre. S'applique à tous les groupes de modules MiniAuras ; 80 % correspond au balayage dessiné par MiniAuras."

-- Core
L["MiniAuras test command is unavailable."] = "La commande de test de MiniAuras n'est pas disponible."
L["MyDRs test command is unavailable."] = "La commande de test de MyDRs n'est pas disponible."
L["sArena slash command is unavailable."] = "La commande slash de sArena n'est pas disponible."

-- Category Names
L["Action Bars"] = "Barres d'action"
L["Nameplates"] = "Barres de nom"
L["Unit Frames"] = "Cadres d'unité"
L["Player Auras"] = "Auras du joueur"
L["Party / Raid Frames"] = "Cadres de groupe / raid"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Dominos"] = "Dominos"

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
L["MiniAuras Frame Types"] = "Types de cadres MiniAuras"
L["MiniAuras Module Groups"] = "Groupes de modules MiniAuras"
L["sArena Cooldown Types"] = "Types de timers sArena"
L["Aura Targets"] = "Cibles d'auras"
L["Buff Styling"] = "Style des buffs"
L["Debuff Styling"] = "Style des debuffs"
L["External Defensive Buffs Styling"] = "Style des buffs défensifs externes"

-- Toggles & Settings
L["Enable %s"] = "Activer %s"
L["Toggle styling for this category."] = "Active ou désactive le style pour cette catégorie."
L["Style Buffs"] = "Styliser les buffs"
L["Style Debuffs"] = "Styliser les debuffs"
L["Style External Defensive Buffs"] = "Styliser les buffs défensifs externes"
L["Style Blizzard's default player buff buttons."] = "Stylise les boutons de buffs Blizzard du joueur."
L["Style Blizzard's default player debuff buttons."] = "Stylise les boutons de debuffs Blizzard du joueur."
L["Style Blizzard's external defensive buff buttons."] = "Stylise les boutons de buffs défensifs externes Blizzard."
L["Font Face"] = "Police"
L["Font"] = "Police"
L["Size"] = "Taille"
L["Outline"] = "Contour"
L["Color"] = "Couleur"
L["Hide Numbers"] = "Masquer les chiffres"
L["Timer Inside Icon"] = "Timer dans l'icône"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Place le timer d'aura au centre de l'icône au lieu de la position externe par défaut de Blizzard."
L["Only Mine (Timer Text)"] = "Mes auras uniquement (texte du timer)"
L["Aura Visibility"] = "Visibilité des auras"
L["Only My Debuffs"] = "Seulement mes affaiblissements"
L["Only My Buffs"] = "Seulement mes améliorations"
L["Disable fading/blinking"] = "Désactiver fondu/clignotement"
L["Compact Party / Raid Aura Text"] = "Texte d'aura de groupe / raid compact"
L["Enable Party Aura Text"] = "Activer le texte d'aura du groupe"
L["Enable Raid Aura Text"] = "Activer le texte d'aura du raid"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Masque entièrement le texte (utile si vous ne voulez que le bord de balayage ou les cumuls)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "N'affiche le texte du timer que sur vos propres auras. Utilise l'heuristique Blizzard des grandes auras au lieu d'un test direct sur la source."
L["UNITFRAME_ONLY_MINE_DESC"] = "N'affiche le texte du timer que sur les auras que vous avez lancées. Les conteneurs cible/focus de MiniCE pour WoW 12.1 utilisent le filtre Joueur de Blizzard ; les cadres d'addons compatibles et anciens utilisent leurs groupes ou l'heuristique des grandes auras."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Masque les affaiblissements lancés par les autres joueurs sur les cadres de cible et de focus. MiniCE gère ces conteneurs d'auras sur WoW 12.1, le filtre d'affaiblissements de Blizzard ne s'y applique donc plus."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Masque les améliorations lancées par les autres joueurs sur les cadres de cible et de focus. MiniCE gère ces conteneurs d'auras sur WoW 12.1, le filtre d'améliorations de Blizzard ne s'y applique donc plus."
L["Cast Bar"] = "Barre d'incantation"
L["Reposition Cast Bar"] = "Repositionner la barre d'incantation"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Ancre les barres d'incantation de la cible et du focus sous la dernière rangée d'améliorations/affaiblissements. MiniCE gère ces conteneurs d'auras sur WoW 12.1 ; sans cette option, la barre de Blizzard reste collée au cadre et les recouvre."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "Garde les boutons d'auras du joueur entièrement opaques lorsqu'ils sont proches de l'expiration."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Affiche un texte de compte à rebours stylisé sur les icônes d'améliorations et d'affaiblissements de Blizzard CompactPartyFrame. La désactivation masque le texte des auras sur les cadres de groupe."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Affiche un texte de compte à rebours stylisé sur les icônes d'améliorations et d'affaiblissements de Blizzard CompactRaidFrame. La désactivation masque le texte des auras sur les cadres de raid."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "Quand un emplacement de CooldownManager affiche temporairement la durée d'une aura, utilise une couleur de buff dédiée au lieu des couleurs par seuil de temps restant."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "Appliquée pendant que l'emplacement affiche la durée d'une aura. Quand l'aura se termine et que l'emplacement repasse sur le temps de recharge, les couleurs par seuil reprennent."
L["Anchor Point"] = "Point d'ancrage"
L["Offset X"] = "Décalage X"
L["Offset Y"] = "Décalage Y"
L["Buff / Debuff Size"] = "Taille buffs / debuffs"
L["Defensive Buff Size"] = "Taille buffs défensifs"
L["Use Buff Color"] = "Utiliser une couleur de buff"
L["Buff Color"] = "Couleur du buff"
L["Essential Viewer Size"] = "Taille de l'afficheur Essential"
L["Utility Viewer Size"] = "Taille de l'afficheur Utility"
L["Buff Icon Viewer Size"] = "Taille de l'afficheur d'icônes d'améliorations"
L["Essential Viewer Stack Size"] = "Taille cumuls/charges Essential"
L["Utility Viewer Stack Size"] = "Taille cumuls/charges Utility"
L["Buff Icon Viewer Stack Size"] = "Taille cumuls/charges icônes de buffs"
L["CC Text Size"] = "Taille du texte de CC"
L["CC Frames Text Size"] = "Taille du texte (CC)"
L["CC / Friendly Frames Text Size"] = "Taille du texte CC / cadres alliés"
L["Raid Frame Auras Text Size"] = "Taille du texte des auras de cadres de raid"
L["Class Icon Text Size"] = "Taille du texte de l'icône de classe"
L["DR Cooldown Text Size"] = "Taille du texte de recharge des DR"
L["Nameplates Text Size"] = "Taille du texte des barres de nom"
L["Portraits Text Size"] = "Taille du texte des portraits"
L["Alerts / Overlay Text Size"] = "Taille du texte des alertes / superpositions"
L["Alerts / Trackers / Custom Auras Text Size"] = "Taille du texte alertes / suivis / auras personnalisées"
L["Trinket / Racial Text Size"] = "Taille du texte Bijou / Racial"
L["Toggle Test Icons"] = "Afficher ou masquer les icônes de test"
L["Show Test Frames"] = "Afficher les cadres de test"
L["Hide Test Frames"] = "Masquer les cadres de test"
L["Show Swipe Edge"] = "Afficher le bord de balayage"
L["Shows the white line indicating cooldown progress."] = "Affiche la ligne blanche indiquant la progression de la recharge."
L["Show Swipe Animation"] = "Afficher l'animation de balayage"
L["Shows the dark overlay that sweeps during a cooldown."] = "Affiche l'overlay sombre qui balaie pendant une recharge."
L["Hide Swipe"] = "Masquer le balayage"
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "Masque l'animation de balayage pour ce groupe (le texte du compte à rebours reste visible)."
L["Edge Thickness"] = "Épaisseur du bord"
L["Scale of the swipe line (1.0 = Default)."] = "Échelle de la ligne de balayage (1.0 = par défaut)."
L["Swipe Shade Alpha"] = "Opacité du balayage"
L["0% = transparent, 100% = full dark."] = "0 % = transparent, 100 % = complètement sombre."
L["Customize Stack Text"] = "Personnaliser le texte des cumuls"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Prenez le contrôle du compteur de charges (par ex. 2 charges de Conflagration)."
L["Hide Charge Timers"] = "Masquer les timers de charges"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "Masque les timers pendant la recharge des charges (n'affiche un timer que lorsque toutes les charges sont dépensées)."
L["Hide Stack Text"] = "Masquer le texte des cumuls"
L["Hide stacks and charges entirely."] = "Masque entièrement les cumuls et les charges."
L["Reset %s"] = "Réinitialiser %s"
L["Revert this category to default settings."] = "Rétablit cette catégorie à ses réglages par défaut."
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "Active ou désactive les icônes de test intégrées de MiniAuras avec /miniauras test."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "Active ou désactive les icônes de test intégrées de MyDRs avec /mydrs test."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "Les réglages de texte MiniAuras sont regroupés par famille de modules pour que les widgets similaires partagent la même taille de compte à rebours."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "S'applique aux modules MiniAuras CC, Friendly CDs et Friendly Indicators."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "S'applique au module MiniAuras CC (contrôles de foule ennemis)."
L["Applies to the MiniAuras Raid Frame Auras module."] = "S'applique au module Raid Frame Auras de MiniAuras."
L["Applies to MiniAuras portrait icons."] = "S'applique aux icônes de portrait de MiniAuras."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "S'applique aux modules Alerts, Healer CC, Kick Timer, Precognition, Trinkets et Custom Auras de MiniAuras."
L["Show sArena test frames using /sarena test."] = "Affiche les cadres de test de sArena avec /sarena test."
L["Hide sArena test frames using /sarena hide."] = "Masque les cadres de test de sArena avec /sarena hide."

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
L["Top"] = "Haut"
L["Bottom"] = "Bas"
L["Left"] = "Gauche"
L["Right"] = "Droite"

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
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "Certaines modifications nécessitent un rechargement de l'interface pour être appliquées complètement.\n\nRecharger l'interface maintenant ?"

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"
L["Retired"] = "Retiré"

-- General Dashboard
L["Enable categories styling"] = "Activer le style des catégories"
L["LIVE_CONTROLS_DESC"] = "Les changements s'appliquent immédiatement. Ne laissez actives que les catégories que vous utilisez vraiment pour une configuration plus propre."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Activer Cadres de groupe / raid agit comme interrupteur principal pour cette catégorie. Activer le texte d'aura du raid étend le même style aux cadres de raid Blizzard."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "Le support des cadres de groupe / raid est retiré. Depuis le patch Blizzard 12.0.5, MiniCE ne hook plus et ne stylise plus les cadres compacts de groupe et de raid."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "Nouvel addon en développement : Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras est maintenant disponible sur CurseForge. Il reste séparé de MiniCE, car il utilise ses propres frames en overlay au lieu de styliser les icônes Blizzard existantes, ce qui le rend plus adapté à un addon autonome."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "Route les recharges prises en charge de Dominos vers la catégorie Barres d'action. Désactivez ceci si vous voulez que Dominos conserve son style natif inchangé."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "Route les recharges prises en charge de Bartender4 vers la catégorie Barres d'action. Désactivez ceci si vous voulez que Bartender4 conserve son style natif inchangé."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copiez ce lien pour ouvrir la page du projet CurseForge dans votre navigateur."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "Copiez ce lien pour ouvrir Raid Frame Auras sur CurseForge."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copiez ce lien pour voir les autres projets d'Anahkas sur CurseForge."

-- Help
L["Help & Support"] = "Aide et assistance"
L["Project"] = "Projet"
L["Useful Addons"] = "Addons utiles"
L["Support & Feedback"] = "Assistance et retours"
L["MCE_HELP_INTRO"] = "Quelques liens utiles pour le projet et deux addons qui valent le détour."
L["HELP_SUPPORT_DESC"] = "Les suggestions et les retours sont toujours les bienvenus.\n\nSi vous trouvez un bug ou avez une idée de fonctionnalité, n'hésitez pas à laisser un commentaire ou un message privé sur CurseForge."
L["HELP_COMPANION_DESC"] = "Quelques addons sobres qui vont très bien avec MiniCE."
L["HELP_MINIAURAS_DESC"] = "Suite d'affichage des auras, contrôles, temps de recharge et outils JcJ. MiniCE peut aussi styliser ses textes de recharge."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "Copiez ce lien pour ouvrir la page CurseForge de MiniAuras dans votre navigateur."
L["HELP_PVPTAB_DESC"] = "Fait en sorte que TAB cible uniquement les joueurs en JcJ. Idéal pour les arènes et les champs de bataille."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copiez ce lien pour ouvrir la page CurseForge de Smart PvP Tab Targeting dans votre navigateur."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Activez ou désactivez vos principales catégories de recharge depuis un seul endroit."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Cette action est irréversible. Votre profil sera entièrement réinitialisé et l'interface sera rechargée."
L["MAINTENANCE_DESC"] = "Rétablit cette catégorie à ses paramètres d'usine. Les autres catégories ne sont pas affectées."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Personnalisez les recharges sur vos barres d'action."
L["NAMEPLATE_DESC"] = "Personnalisez les recharges sur les barres de nom ennemies et alliées."
L["UNITFRAME_DESC"] = "Personnalisez les recharges d'auras sur les cadres de cible, de focus et les cadres d'unité pris en charge."
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames est actif. Le style des cadres d'unité de MiniCE a donc été désactivé afin d'éviter d'éventuels conflits. Un adaptateur BetterBlizzFrames dédié arrivera bientôt."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates est actif. Le style des barres de nom de MiniCE a donc été désactivé afin d'éviter d'éventuels conflits."
L["PLAYERAURA_DESC"] = "Stylise séparément les boutons de buffs, debuffs et buffs défensifs externes Blizzard du joueur, y compris le texte de durée, les cumuls, le comportement de fondu et les balayages optionnels."
L["COOLDOWNMANAGER_DESC"] = "Personnalisez les recharges des icônes de CooldownManager."
L["MINIAURAS_DESC"] = "Personnalisez les icônes de recharge de MiniAuras."
L["MYDRS_DESC"] = "Style dédié aux icônes de recharge des réductions décroissantes (DR) de MyDRs. MyDRs conserve son propre libellé d'état DR (50 % / IMM)."
L["SARENA_DESC"] = "Style dédié aux timers de recharge de sArena_Reloaded. Prend en charge le texte des recharges de l'icône de classe, des DR et des icônes bijou / racial lorsque sArena_Reloaded est chargé."
L["TELLMEWHEN_DESC"] = "Style dédié aux balayages de recharge de TellMeWhen. Prend en charge les cadres de recharge principaux et de charges des icônes TellMeWhen lorsque l'addon est chargé."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Couleurs dynamiques du texte"
L["Color by Remaining Time"] = "Colorer selon le temps restant"
L["Dynamically colors the countdown text based on how much time is left."] = "Colorie dynamiquement le texte du compte à rebours selon le temps restant."
L["DYNAMIC_COLORS_DESC"] = "Change la couleur du texte en fonction du temps de recharge restant. Remplace la couleur statique ci-dessus lorsqu'elle est activée."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Les seuils de temps restant peuvent être autorisés ou bloqués par catégorie MiniCE active. La gestion des durées reste fiable même au passage de minuit lorsque Blizzard n'expose que des valeurs cachées."
L["Allow Threshold Colors"] = "Autoriser les couleurs de seuil"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "Autorise les seuils globaux de temps restant à remplacer la couleur statique de cette catégorie."
L["Expiring Soon"] = "Expiration imminente"
L["Short Duration"] = "Courte durée"
L["Long Duration"] = "Longue durée"
L["Threshold (seconds)"] = "Seuil (secondes)"
L["Default Color"] = "Couleur par défaut"
L["Color used when the remaining time exceeds all thresholds."] = "Couleur utilisée lorsque le temps restant dépasse tous les seuils."

-- Abbreviation
L["Abbreviate Above"] = "Abréger au-dessus de"
L["Abbreviate Above (seconds)"] = "Abréger au-dessus de (secondes)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Les durées au-dessus de ce seuil seront abrégées (ex. 5m au lieu de 300)."
L["Show Tenths Below (seconds)"] = "Afficher les dixièmes en dessous de (secondes)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "Les durées en dessous de ce seuil afficheront une décimale (ex. 8,7). Mets 0 pour désactiver."
L["ABBREV_THRESHOLD_DESC"] = "Définit quand les durées passent en format abrégé. Les minuteries au-dessus de ce seuil affichent des valeurs raccourcies comme 5m ou 1h."


-- Category Names
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["Profiles"] = "Profils"
L["ShinyAuras"] = "ShinyAuras"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "Bord de balayage"

-- Toggles & Settings
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "Active le texte de compte à rebours stylisé sur les cadres de groupe / raid. Si désactivé, le style du texte d'aura de groupe et de raid est entièrement coupé."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Applique aussi le texte de compte à rebours stylisé aux icônes d'améliorations et d'affaiblissements de Blizzard CompactRaidFrame. Nécessite que Cadres de groupe / raid soit activé."
L["Essential Viewer"] = "Afficheur Essential"
L["Utility Viewer"] = "Afficheur Utility"
L["Buff Icon Viewer"] = "Afficheur d'icônes d'améliorations"
L["Reverse Swipe"] = "Inverser le balayage"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "Inverse le sens du balayage pour que l'ombre se remplisse dans la direction opposée."

-- Import / Export
L["Import string is too large."] = "La chaîne d'import est trop volumineuse."
L["Import profile contains invalid data."] = "Le profil importé contient des données invalides."
L["Failed to apply imported profile."] = "Impossible d'appliquer le profil importé."

-- Addon Integrations
L["Addon Integrations"] = "Intégrations d'addons"
L["ADDON_INTEGRATIONS_DESC"] = "Active ou désactive les passerelles d'addons optionnelles qui routent les recharges externes vers les catégories de MiniCE."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "Route les recharges de ShinyAuras vers la catégorie Cadres d'unité. Désactivez ceci si vous voulez que ShinyAuras conserve ses comptes à rebours natifs inchangés."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "Route les recharges prises en charge de barres d'action, de cadres d'unité et de barres de nom d'ElvUI vers les catégories de MiniCE. Désactivez ceci si vous voulez qu'ElvUI conserve son style natif inchangé."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered stylise aussi %s. Cela peut entraîner un léger coût en performance. Désactivez les polices de timer CMC si vous voulez que MiniCE reste le seul à gérer les timers de ces afficheurs."

-- Help
L["HELP_ARENADR_DESC"] = "Suit les réductions de dégâts croissantes des ennemis directement sur les barres de nom en arène."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "Copiez ce lien pour ouvrir ArenaDR Nameplates sur CurseForge."

-- Category Descriptions
L["HEALERCC_DESC"] = "Personnalisez les recharges d'alertes HealerCC alliées et ennemies."

-- TellMeWhen
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "La visibilité du timer, le texte du timer, le sens de l'ombrage et l'affichage du GCD restent contrôlés par TellMeWhen. La visibilité et l'épaisseur du bord de balayage sont contrôlées ici."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Redimensionne le bord de balayage de TellMeWhen lorsque MiniCE l'a activé."

-- Dynamic Text Colors
L["Behavior"] = "Comportement"
L["Advanced Threshold Settings"] = "Réglages avancés des seuils"
L["Threshold Colors"] = "Couleurs de seuil"
L["THRESHOLD_COLORS_DESC"] = "Chaque palier définit le seuil et la couleur utilisés pour cette plage de temps restant."
L["Threshold Transition Offset"] = "Décalage de transition de seuil"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "Déplace le début de chaque prochaine bande de couleur. Des valeurs négatives font basculer légèrement plus tôt."
L["Beyond Thresholds Color"] = "Couleur au-delà des seuils"

-- Performance Warning
L["PERF_WARNING_DESC"] = "Cette fonctionnalité peut affecter les performances et provoquer des chutes de FPS. À utiliser uniquement sur des configurations puissantes."

-- Font Options
L["Game Default"] = "Police par défaut du jeu"
