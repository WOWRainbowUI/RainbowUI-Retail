-- frFR.lua (French)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "frFR")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Impossible d'ouvrir les options en combat."

-- Category Names
L["Action Bars"] = "Barres d'action"
L["Nameplates"] = "Barres de nom"
L["Unit Frames"] = "Cadres d'unité"
L["CD Manager & Others"] = "Gestionnaire de CD & Autres"

-- Group Headers
L["General"] = "Général"
L["State"] = "État"
L["Typography (Cooldown Numbers)"] = "Typographie (Chiffres de recharge)"
L["Swipe Animation"] = "Animation de balayage"
L["Stack Counters / Charges"] = "Compteurs de cumul / Charges"
L["Maintenance"] = "Maintenance"
L["Performance & Detection"] = "Performance & Détection"
L["Danger Zone"] = "Zone de danger"
L["Style"] = "Style"
L["Positioning"] = "Positionnement"

-- Toggles & Settings
L["Enable %s"] = "Activer %s"
L["Toggle styling for this category."] = "Activer/désactiver le style pour cette catégorie."
L["Font Face"] = "Police"
L["Game Default"] = "Police du jeu"
L["Font"] = "Police"
L["Size"] = "Taille"
L["Outline"] = "Contour"
L["Color"] = "Couleur"
L["Hide Numbers"] = "Masquer les chiffres"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Masquer entièrement le texte (utile si vous ne voulez que le bord de balayage ou les cumuls)."
L["Anchor Point"] = "Point d'ancrage"
L["Offset X"] = "Décalage X"
L["Offset Y"] = "Décalage Y"
L["Show Swipe Edge"] = "Afficher le bord de balayage"
L["Shows the white line indicating cooldown progress."] = "Affiche la ligne blanche indiquant la progression de la recharge."
L["Edge Thickness"] = "Épaisseur du bord"
L["Scale of the swipe line (1.0 = Default)."] = "Échelle de la ligne de balayage (1.0 = Par défaut)."
L["Customize Stack Text"] = "Personnaliser le texte de cumul"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Prenez le contrôle du compteur de charges (ex : 2 cumuls de Conflagration)."
L["Reset %s"] = "Réinitialiser %s"
L["Revert this category to default settings."] = "Rétablir les paramètres par défaut de cette catégorie."

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
L["Scan Depth"] = "Profondeur de scan"
L["How deep the addon looks into UI frames to find cooldowns."] = "Profondeur de recherche de l'addon dans les cadres de l'interface pour trouver les recharges."
L["Factory Reset (All)"] = "Réinitialisation usine (Tout)"
L["Resets the entire profile to default values and reloads the UI."] = "Réinitialise le profil entier aux valeurs par défaut et recharge l'interface."

-- Banner
L["BANNER_DESC"] = "Configuration minimaliste pour vos recharges. Sélectionnez une catégorie à gauche pour commencer."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Efficace (Interface par défaut)\n|cfffff56910 - 15|r : Modéré (Bartender, Dominos)\n|cffffa500> 15|r : Lourd (ElvUI, Cadres complexes)"

-- Chat Messages
L["%s settings reset."] = "Paramètres de %s réinitialisés."
L["Profile reset. Reloading UI..."] = "Profil réinitialisé. Rechargement de l'interface..."
L["Global Scan Depth changed. A /reload is recommended."] = "Profondeur de scan globale modifiée. Un /reload est recommandé."
