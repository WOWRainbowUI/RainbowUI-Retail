--=====================================================================================
-- RGX | Simple Quest Plates! - frFR.lua

-- Author: DonnieDice
-- Description: French localization
--=====================================================================================

local addonName, SQP = ...
local locale = GetLocale()

if locale ~= "frFR" then return end

local L = SQP.L or {}

-- French translations
L["OPTIONS_ENABLE"] = "Activer Simple Quest Plates"
L["OPTIONS_DISPLAY"] = "Paramètres d'affichage"
L["OPTIONS_SCALE"] = "Taille de l'icône"
L["OPTIONS_OFFSET_X"] = "Décalage horizontal"
L["OPTIONS_OFFSET_Y"] = "Décalage vertical"
L["OPTIONS_ANCHOR"] = "Position de l'icône"
L["OPTIONS_TEST"] = "Test de détection"
L["OPTIONS_RESET"] = "Réinitialiser tous les paramètres"

L["CMD_ENABLED"] = "est maintenant |cff00ff00ACTIVÉ|r"
L["CMD_DISABLED"] = "est maintenant |cffff0000DÉSACTIVÉ|r"
L["CMD_VERSION"] = "Version de Simple Quest Plates: |cff58be81%s|r"
L["CMD_HELP_HEADER"] = "|cff58be81Commandes RGX | Simple Quest Plates!:|r"

L["MSG_LOADED"] = "v%s chargé avec succès. Tapez |cfffff569/sqp help|r pour les commandes."