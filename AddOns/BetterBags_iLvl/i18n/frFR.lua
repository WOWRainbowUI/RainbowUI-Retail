if(GetLocale() ~= 'frFR') then
    return
end

local _, ns = ...
local L = ns.L

L["CATEGORY_NAME"] = "iLvl faible";
L["OPTIONS_DESC"] = "Sélectionnez le seuil d'iLvl pour cette catégorie (tous les objets avec un iLvl strictement inférieur à cette valeur seront placés dans cette catégorie). Une fois la valeur changée, un rechargement de l'interface peut être nécessaire."
L["OPTIONS_INCLUDE_JUNK"] = "Inclure les objets de qualité médiocre dans cette catégorie";
L["OPTIONS_REFRESH"] = "Recharger l'interface";
L["OPTIONS_RESET_DEFAULT"] = "Remettre la valeur par défaut";
L["OPTIONS_THRESHOLD"] = "Seuil d'iLvl (par défaut : _default_)";
L["OPTIONS_THRESHOLD_ERROR"] = "Veuillez entrer un nombre valide pour le seuil d'iLvl.";
