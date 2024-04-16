--[[
AdiBags - Dragonflight - Localization
by Zottelchen
version: 2.3.35
This file contains translations for this filter.
]]
local addonName, addon = ...

--<GLOBALS
local _G = _G
local GetLocale = _G.GetLocale
local pairs = _G.pairs
local rawset = _G.rawset
local setmetatable = _G.setmetatable
local tostring = _G.tostring
--GLOBALS>

local L = setmetatable({}, {
  __index = function(self, key)
    if key ~= nil then
      rawset(self, key, tostring(key))
    end
    return tostring(key)
  end,
})
addon.L = L

L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] =
  true
L["Colored Categories"] = true
L["Colored Prefix"] = true
L["Custom Prefix"] = true
L["Enter a custom prefix for the categories."] = true
L["Filter version"] = true
L["General Settings"] = true
L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = true
L["None"] = true
L["Prefix Categories"] = true
L["Prefix Color"] = true
L["Select a color for the prefix."] = true
L["Select a prefix for the categories, if you like."] = true
L["Settings affecting all categories."] = true
L["Should Categories be colored?"] = true
L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = true
L["These settings affect all categories of this filter."] = true
--
L["%sMerge %s%s"] = true
L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] =
  true
L["Achievements & Unlockables"] = true
L["Alchemy Flasks"] = true
L["Alchemy Recipes"] = true
L["Artifacts"] = true
L["Artisan Curious"] = true
L["Awakened Elementals"] = true
L["Awakened and Rousing Elemental Trade Goods"] = true
L["Baits to attract skinnable creatures"] = true
L["Bandages"] = true
L["Bandages, to patch up your broken friends :)"] = true
L["Blacksmithing Recipes"] = true
L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] =
  true
L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = true
L["Catch-Up Weapon."] = true
L["Cauldrons"] = true
L["Cauldrons, to share your soup with friends :)"] = true
L["Cavern Clawbering (Achievement)"] = true
L["Cavern Currencies"] = true
L["Chip (Pet)"] = true
L["Cloth"] = true
L["Cloth Catch-Up Gear."] = true
L["Color"] = true
L["Consumables"] = true
L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] =
  true
L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = true
L["Contains runes & vantus runes which improving your combat ability."] = true
L["Contains various tools, helpful in the Dragon Isles."] = true
L["Contracts"] = true
L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = true
L["Cooking"] = true
L["Cooking Recipes"] = true
L["Crafting Potions"] = true
L["Crafting Reagents categorically belonging to Alchemy"] = true
L["Crafting Reagents categorically belonging to Cloth"] = true
L["Crafting Reagents categorically belonging to Cooking"] = true
L["Crafting Reagents categorically belonging to Enchanting"] = true
L["Crafting Reagents categorically belonging to Engineering"] = true
L["Crafting Reagents categorically belonging to Herbs"] = true
L["Crafting Reagents categorically belonging to Inscription"] = true
L["Crafting Reagents categorically belonging to Jewelcrafting"] = true
L["Crafting Reagents categorically belonging to Leather"] = true
L["Crafting Reagents categorically belonging to Mining"] = true
L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = true
L["Darkmoon Cards"] = true
L["Dragonflight"] = true
L["Drakewatcher Manuscripts"] = true
L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = true
L["Dreambound Armor"] = true
L["Dreambound armor is the catch-up gear of 10.1.7."] = true
L["Dreaming Crests"] = true
L["Dreamseeds"] = true
L["Dreamsurge"] = true
L["Dreamsurges are the part of the content of 10.1.7."] = true
L["Elemental Trade Goods"] = true
L["Embellishments"] = true
L["Embers of Neltharion (10.1)"] = true
L["Emerald Bounties are triggered once you plant any dreamseeds at Emerald Bounty mud piles located around the Emerald Dream."] =
  true
L["Enchanting"] = true
L["Enchanting - Insight of the Blue"] = true
L["Enchanting Recipes"] = true
L["Engineering"] = true
L["Engineering Recipes"] = true
L["Fishing Lures"] = true
L["Fishing Lures for catching specific fish"] = true
L["Food"] = true
L["Food added in the Dragonflight expansion"] = true
L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = true
L["Forbidden Reach (10.0.7)"] = true
L["Fortune Cards"] = true
L["Fyrak Assault"] = true
L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = true
L["Gems"] = true
L["General Crafting Reagents"] = true
L["General Crafting Reagents, used by multiple professions"] = true
L["General Profession Items"] = true
L["Guardians of the Dream (10.2)"] = true
L["Herbs"] = true
L["Herbs - Seeds"] = true
L["Honor Our Ancestors"] = true
L["Incense"] = true
L["Incense to improve crafting ability or just for a nice smell"] = true
L["Inscription"] = true
L["Inscription Recipes"] = true
L["Item Level Upgrades"] = true
L["Items found or used in the Zskera Vault."] = true
L["Items from the Dragonflight Pre-Event."] = true
L["Items from the Dragonflight expansion."] = true
L["Items in professions"] = true
L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = true
L["Items that provide embellishments to crafted items."] = true
L["Items that provide profession knowledge"] = true
L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] =
  true
L["Items which are used in multiple professions."] = true
L["Items which can be found and used in the Emerald Dream and related zones."] = true
L["Items which can be found and used in the Forbidden Reach."] = true
L["Items which can be found and used in the Zaralek Cavern."] = true
L["Items which upgrade the item level of crafted gear."] = true
L["Items you can eat or use to improve yourself"] = true
L["Jewelcrafting"] = true
L["Jewelcrafting Recipes"] = true
L["Leather"] = true
L["Leather - Bait"] = true
L["Leather Catch-Up Gear."] = true
L["Leatherworking Recipes"] = true
L["Leftover Elemental Slime"] = true
L["Librarian of the Reach (Achievement)"] = true
L["Lizis Reins (Mount)"] = true
L["Magmashell (Mount)"] = true
L["Mail Catch-Up Gear."] = true
L["Maps to Treasure found in the Dragon Isles"] = true
L["Merge all %s into a single category."] = true
L["Mining"] = true
L["Mossy Mammoth"] = true
L["Other Items"] = true
L["Other items not really fitting in another category."] = true
L["Otto (Mount)"] = true
L["Permanent Enhancements"] = true
L["Phials"] = true
L["Phials added in the Dragonflight expansion"] = true
L["Phoenix Wishwing (Pet)"] = true
L["Plate Catch-Up Gear."] = true
L["Potions"] = true
L["Potions added in the Dragonflight expansion"] = true
L["Potions which improve crafting or collecting"] = true
L["PreEvent"] = true
L["PreEvent Currency"] = true
L["PreEvent Gear"] = true
L["Primalist Accessories"] = true
L["Primalist Cloth"] = true
L["Primalist Gear Tokens"] = true
L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = true
L["Primalist Leather"] = true
L["Primalist Mail"] = true
L["Primalist Plate"] = true
L["Primalist Weapon"] = true
L["Primordial Stones & Onyx Annulet"] = true
L["Profession Gear"] = true
L["Profession Knowledge"] = true
L["Professions"] = true
L["Recipes"] = true
L["Recipes for all professions."] = true
L["Recipes for crafting leather and mail armor."] = true
L["Recipes for crafting potions, elixirs, and transmuting materials."] = true
L["Recipes for creating gadgets, explosives, and mechanical devices."] = true
L["Recipes for cutting gems and crafting jewelry."] = true
L["Recipes for enchanting gear with magical properties."] = true
L["Recipes for forging metal armor, weapons, and enhancements."] = true
L["Recipes for preparing food that provides buffs."] = true
L["Recipes for scribing glyphs and crafting scrolls and tomes."] = true
L["Recipes for weaving cloth armor and other cloth items."] = true
L["Reputation Items"] = true
L["Rousing Elementals"] = true
L["Ruby Feast"] = true
L["Runes"] = true
L["Scrappy Worldsnail (Mount)"] = true
L["Seeds to plant into Rich Soil which in return grants some herbs"] = true
L["Select a color for %s."] = true
L["Select a color for the merged %s category."] = true
L["Shadowflame Crests"] = true
L["Specialized gear which improves your profession"] = true
L["Statues"] = true
L["Statues crafted by Jewelcrafters. They improve various things."] = true
L["Tailoring Recipes"] = true
L["Temperamental Skyclaw (Mount)"] = true
L["Temporary & Permanent Enhancements"] = true
L["Temporary Enhancements"] = true
L["Tetrachromancer (Achievement)"] = true
L["These are gems that you can typically apply to armor to improve it."] = true
L["These are permanent enhancements that you can typically apply to armor to improve it."] = true
L["These are temporary enhancements that you can typically apply to armor to improve it."] = true
L["These artifacts can be traded in Morqut Village."] = true
L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = true
L["These items can be used to summon a rare mob in the Forbidden Reach."] = true
L["This category contains Dreaming Crests, which can be used to upgrade gear."] = true
L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] =
  true
L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = true
L["This category contains currencies, used in the Zaralek Cavern."] = true
L["This category contains fragments, used during the Fyrak Assault event."] = true
L["This category contains hunting companion colors needed for the achievement."] = true
L["This category contains the books looted for the Librarian of the Reach achievement."] = true
L["This category contains the item needed to get the Cavern Clawbering achievement."] = true
L["This category contains the items needed to get the Chip pet."] = true
L["This category contains the items needed to get the Phoenix Wishwing pet."] = true
L["This category contains the quest items looted for the While We Were Sleeping achievement."] = true
L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = true
L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] =
  true
L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = true
L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = true
L["Time Rifts"] = true
L["Time Rifts are the part of the content of 10.1.5."] = true
L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] =
  true
L["Tools"] = true
L["Treasure Maps"] = true
L["Treasure Sacks"] = true
L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = true
L["Untapped Forbidden Knowledge"] = true
L["Use these for a powerup!"] = true
L["While We Were Sleeping (Achievement)"] = true
L["Zskera Vault"] = true

local locale = GetLocale()
if locale == "frFR" then
  L["%sMerge %s%s"] = "%sFusionner %s%s "
--[[Translation missing --]]
--[[ L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = ""--]] 
L["Achievements & Unlockables"] = "Hauts faits et Débloquables"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags n'a jamais eu l'intention d'utiliser des icônes, c'est pourquoi elles sont défectueuses. Assurez-vous de désactiver la couleur de préfixe si vous utilisez une icône."
L["Alchemy Flasks"] = "Flasques d'alchimie"
L["Artifacts"] = "Artéfacts"
L["Artisan Curious"] = "Bibelots d’artisanat"
L["Awakened and Rousing Elemental Trade Goods"] = "Composants d'artisanat élémentaires agités et éveillés"
L["Awakened Elementals"] = "Éléments éveillés"
L["Baits to attract skinnable creatures"] = "Appâts pour attirer les créatures dépeçables"
L["Bandages"] = "Bandages"
L["Bandages, to patch up your broken friends :)"] = "Bandages, pour recoller les morceaux de vos amis :)"
L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = "Accessoires de rattrapage, contient Anneaux, Colliers, Bijoux et Capes"
L["Catch-Up Weapon."] = "Arme de rattrapage."
L["Cauldrons"] = "Chaudrons"
L["Cauldrons, to share your soup with friends :)"] = "Chaudrons, pour partager votre soupe avec vos amis :)"
--[[Translation missing --]]
--[[ L["Cavern Clawbering (Achievement)"] = ""--]] 
L["Cavern Currencies"] = "Monnaie de la Grotte"
L["Chip (Pet)"] = "Kopo ( Mascotte)"
L["Cloth"] = "Tissu"
L["Cloth Catch-Up Gear."] = "Équipement de rattrapage en tissu"
L["Color"] = "Couleur"
L["Colored Categories"] = "Catégories colorées"
L["Colored Prefix"] = "Préfixe coloré"
L["Consumables"] = "Consommables"
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = "Contient les objets pouvant être échangés directement contre de la réputation / renommée, ainsi que les objets nécessaires à Irion et Sabellian."
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
L["Contains runes & vantus runes which improving your combat ability."] = "Contient les runes et les runes de vantus qui améliorent vos statistiques dans les combat. "
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
L["Contracts"] = "Contrats"
L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = "Les contrats donnent de la réputation supplémentaire lors de l'accomplissement d'expéditions dans les îles aux Dragons."
L["Cooking"] = "Cuisine"
L["Crafting Potions"] = "Potions confectionnées"
L["Crafting Reagents categorically belonging to Alchemy"] = "Composants d'artisanat appartenant à l'alchimie."
L["Crafting Reagents categorically belonging to Cloth"] = "Composants d'artisanat appartenant à la couture."
L["Crafting Reagents categorically belonging to Cooking"] = "Composants d'artisanat appartenant à la cuisine"
L["Crafting Reagents categorically belonging to Enchanting"] = "Composants d'artisanat appartenant à l'enchantement"
L["Crafting Reagents categorically belonging to Engineering"] = "Composants d'artisanat appartenant à l'ingénierie"
L["Crafting Reagents categorically belonging to Herbs"] = "Composants d'artisanat appartenant à l'herboristerie"
L["Crafting Reagents categorically belonging to Inscription"] = "Composants d'artisanat appartenant à la calligraphie"
L["Crafting Reagents categorically belonging to Jewelcrafting"] = "Composants d'artisanat appartenant à la joaillerie"
L["Crafting Reagents categorically belonging to Leather"] = "Composants d'artisanat appartenant au dépeçage"
L["Crafting Reagents categorically belonging to Mining"] = "Composants d'artisanat appartenant au minage"
L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = "Objets semblables à des devises obtenues lors du pré-événement de Dragonflight."
L["Custom Prefix"] = "Préfixe personnalisé"
L["Darkmoon Cards"] = "Cartes de Sombrelune"
L["Dragonflight"] = "Dragonflight"
L["Drakewatcher Manuscripts"] = "Manuscrits guette-drake"
L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = "Manuscrits guette-drake pour apprendre de nouvelles personnalisations pour vos montures de vol à dos de dragon"
L["Elemental Trade Goods"] = "Composants d'artisanat élémentaires"
L["Embellishments"] = "Embellissements"
L["Embers of Neltharion (10.1)"] = "Braises de Neltharion (10.1)"
L["Enchanting"] = "Enchantement"
L["Enchanting - Insight of the Blue"] = "Enchantement - Clairvoyance du Vol bleu"
L["Engineering"] = "Ingénierie"
L["Enter a custom prefix for the categories."] = "Saisissez un préfixe personnalisé pour les catégories."
L["Filter version"] = "Version du filtre "
L["Fishing Lures"] = "Hameçons"
L["Fishing Lures for catching specific fish"] = "Leurres de pêche pour attraper des poissons spécifiques"
L["Food"] = "Nourriture"
L["Food added in the Dragonflight expansion"] = "Nourriture ajoutée à Dragonflight"
L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = "Nourriture du festin de rubis - seuls les effets cosmétiques fonctionnent en dehors du monde ouvert."
L["Forbidden Reach (10.0.7)"] = "Confins Interdits (10.0.7)"
L["Fortune Cards"] = "Cartes de bonne aventure"
L["Fyrak Assault"] = "Assaut de Fyrakka"
L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = "Équipement obtenu ou acheté durant l'événement pré-Dragonflight "
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
L["General Crafting Reagents"] = "Composants d'artisanat généraux "
L["General Crafting Reagents, used by multiple professions"] = "Composants d'artisanat généraux utilisés par différents métiers"
L["General Profession Items"] = "Objets de métier "
L["General Settings"] = "Réglages généraux"
L["Herbs"] = "Herbes"
L["Herbs - Seeds"] = "Herbes - graines "
L["Honor Our Ancestors"] = "Honorer nos ancêtres"
L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = "Si vous écrasez la couleur du préfixe ou de la catégorie, vous devez soit basculer deux fois le paramètre de couleur, soit recharger."
L["Incense"] = "Encens"
L["Incense to improve crafting ability or just for a nice smell"] = "Encens pour améliorer les capacités d'artisanat ou simplement pour une bonne odeur"
L["Inscription"] = "Calligraphie"
L["Item Level Upgrades"] = "Amélioration du nivO d'objet"
L["Items found or used in the Zskera Vault."] = "Objets trouvés ou utilisés dans la caverne de Zskera"
L["Items from the Dragonflight expansion."] = "Objets de l'extension Dragonflight."
L["Items from the Dragonflight Pre-Event."] = "Objet du pré-événement de Dragonfight."
L["Items in professions"] = "Objets dans les métiers"
L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = "Objets qui peuvent être trouvés et désenchantés lorsque 'Clairvoyance du Vol bleu' (amélioration d'enchantement) est utilisé."
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
L["Items that provide profession knowledge"] = "Objets qui octroient de la connaissance de métier"
L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = "Objets utilisés pour obtenir des hauts faits ou des montures à débloquer. La plupart d'entre eux perdent leur valeur monétaire une fois que le succès ou la monture est débloqué."
L["Items which are used in multiple professions."] = "Objets qui sont utilisés dans différents métiers."
L["Items which can be found and used in the Forbidden Reach."] = "Objets trouvés et utilisés dans les Confins Interdits"
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
L["Items you can eat or use to improve yourself"] = "Objets que vous pouvez manger ou utiliser pour vous améliorer "
L["Jewelcrafting"] = "Joaillerie"
L["Leather"] = "Cuirs"
L["Leather - Bait"] = "Cuirs - appâts"
L["Leather Catch-Up Gear."] = "Équipement de rattrapage en cuir. "
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
L["Librarian of the Reach (Achievement)"] = "Bibliothécaire des confins (Haut fait)"
L["Lizis Reins (Mount)"] = "Rênes de Lizi (Monture)"
L["Magmashell (Mount)"] = "Magmargot (Monture)"
L["Mail Catch-Up Gear."] = "Équipement de rattrapage en mailles. "
L["Maps to Treasure found in the Dragon Isles"] = "Cartes au trésor trouvées dans les îles du Dragon"
L["Merge all %s into a single category."] = "Fusionner tous les %s en une seule catégorie."
L["Mining"] = "Minage"
L["Mossy Mammoth"] = "Mammouth moussu"
L["None"] = "Aucun"
L["Other Items"] = "Autres objets"
L["Other items not really fitting in another category."] = "Autres objets ne rentrant pas vraiment dans les autres catégories."
L["Otto (Mount)"] = "Otto (monture)"
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
L["Phials"] = "Flasques"
L["Phials added in the Dragonflight expansion"] = "Flasques ajoutées avec l'extension Dragonflight"
L["Phoenix Wishwing (Pet)"] = "Phénix ailes-à-vœux (Mascotte)"
L["Plate Catch-Up Gear."] = "Équipement de rattrapage en plaques. "
L["Potions"] = "Potions"
L["Potions & Elixirs"] = "Potions et Élixirs"
L["Potions added in the Dragonflight expansion"] = "Potions ajoutées à Dragonflight"
L["Potions which improve crafting"] = "Potions qui améliore l'artisanat"
L["Potions which improve crafting or collecting"] = "Potions qui améliorent la fabrication ou la récolte"
L["PreEvent"] = "Pré-événement"
L["PreEvent Currency"] = "Monnaie pré-événement"
L["PreEvent Gear"] = "Équipement pré-événement"
L["Prefix Categories"] = "Préfixe des catégories"
L["Prefix Color"] = "Couleur du préfixe"
L["Primalist Accessories"] = "Accesoires primaliste"
L["Primalist Cloth"] = "Tissu primaliste"
L["Primalist Gear Tokens"] = "Jetons d'équipement primaliste"
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = ""--]] 
L["Primalist Leather"] = "Cuir primaliste"
L["Primalist Mail"] = "Mailles primaliste "
L["Primalist Plate"] = "Plaques primaliste"
L["Primalist Weapon"] = "Arme primaliste"
L["Primordial Stones & Onyx Annulet"] = "Pierre primordial & Annelet d'onyx"
L["Profession Gear"] = "Équipement de métier"
L["Profession Knowledge"] = "Connaissance des métiers"
L["Professions"] = "Métiers"
L["Reputation Items"] = "Objets de réputation"
L["Rousing Elementals"] = "Éléments éveillés"
L["Ruby Feast"] = "Festin rubis"
L["Runes"] = "Runes"
L["Scrappy Worldsnail (Mount)"] = "Escarmonde pugnace"
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
L["Select a color for %s."] = "Sélectionnez une couleur pour %s."
L["Select a color for the merged %s category."] = "Sélectionnez une couleur pour la catégorie fusionnée %s."
L["Select a color for the prefix."] = "Sélectionnez une couleur pour le préfixe."
L["Select a prefix for the categories, if you like."] = "Sélectionnez un préfixe pour les catégories, si vous le désirez."
L["Settings affecting all categories."] = "Réglages affectant toutes les catégories."
L["Shadowflame Crests"] = "Ecus d’ombreflamme"
L["Should Categories be colored?"] = "Les catégories doivent-elles être colorées ?"
L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = "Le préfixe doit-il être coloré en fonction de la couleur du filtre ? (Cela ne fonctionne que pour les préfixes de texte, pour des raisons évidentes)."
L["Specialized gear which improves your profession"] = "Équipement spécialisé qui améliore votre métier"
L["Statues"] = "Statues"
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
L["Temperamental Skyclaw (Mount)"] = "Griffe-du-ciel caractérielle (Monture)"
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
L["Tetrachromancer (Achievement)"] = "Tétrachromancie (Haut fait) "
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
L["These settings affect all categories of this filter."] = "Ces réglages affectent toutes les catégories de ce filtre."
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
L["Tools"] = "Outils"
L["Treasure Maps"] = "Cartes au trésor"
L["Treasure Sacks"] = "Sacs aux trésors"
L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = "Sacs aux trésors offerts par le grand Bufflon, sauveur de l'humanité des dragons."
L["Untapped Forbidden Knowledge"] = "Savoir interdit inexploité"
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
L["While We Were Sleeping (Achievement)"] = "Pendant que nous dormions (Haut fait)"
L["Zskera Vault"] = "Caveaux de Zskera"

elseif locale == "deDE" then
  L["%sMerge %s%s"] = "Wie in \"Kategorie zusammenführen\". Bitte behalte %s davor und danach."
L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = "Ein Reittier, das in Ohn'iri Springs in den Ohn'ahran Plains freigeschaltet werden kann. Erfordert die Abgabe eines dieser Gegenstände einmal pro Tag."
L["Achievements & Unlockables"] = "Errungenschaften & Freischaltbares"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags hatte nie die Absicht, Icons zu verwenden, daher sind sie fehlerhaft. Stelle sicher, dass die Präfixfarbe deaktiviert ist, wenn Sie ein Symbol verwenden."
L["Alchemy Flasks"] = "Alchemie-Fläschchen"
L["Artifacts"] = "Artefakte"
--[[Translation missing --]]
--[[ L["Artisan Curious"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened and Rousing Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Baits to attract skinnable creatures"] = ""--]] 
L["Bandages"] = "Bandagen"
L["Bandages, to patch up your broken friends :)"] = "Pflaster, um deine verletzten Freunde zu flicken :)"
--[[Translation missing --]]
--[[ L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Weapon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons, to share your soup with friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Clawbering (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Currencies"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chip (Pet)"] = ""--]] 
L["Cloth"] = "Kleider"
--[[Translation missing --]]
--[[ L["Cloth Catch-Up Gear."] = ""--]] 
L["Color"] = "Farbe"
--[[Translation missing --]]
--[[ L["Colored Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consumables"] = ""--]] 
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains runes & vantus runes which improving your combat ability."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = ""--]] 
L["Cooking"] = "Kochen"
--[[Translation missing --]]
--[[ L["Crafting Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Alchemy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
L["Darkmoon Cards"] = "Dunkelmond Karten"
L["Dragonflight"] = "Dragonflight"
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embellishments"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
L["Enchanting"] = "Verzauberkunst"
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
L["Engineering"] = "Ingenieurskunst"
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures for catching specific fish"] = ""--]] 
L["Food"] = "Essen"
--[[Translation missing --]]
--[[ L["Food added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = ""--]] 
--[[Translation missing --]]
--[[ L["Forbidden Reach (10.0.7)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fortune Cards"] = ""--]] 
L["Fyrak Assault"] = "Angriffe von Fyrakk"
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
L["Gems"] = "Edelsteine"
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Profession Items"] = ""--]] 
L["General Settings"] = "Allgemeine Einstellungen"
L["Herbs"] = "Kräuter"
L["Herbs - Seeds"] = "Kräuter - Samen"
L["Honor Our Ancestors"] = "Ehret unsere Ahnen"
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
L["Incense"] = "Räucherwerk"
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
L["Inscription"] = "Inschriftenkunde"
--[[Translation missing --]]
--[[ L["Item Level Upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items in professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
L["Jewelcrafting"] = "Juwelierskunst"
L["Leather"] = "Leder"
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
L["Lizis Reins (Mount)"] = "Lizis Zügel (Reittier)"
--[[Translation missing --]]
--[[ L["Magmashell (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mail Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
L["Mining"] = "Bergbau"
--[[Translation missing --]]
--[[ L["Mossy Mammoth"] = ""--]] 
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Otto (Mount)"] = ""--]] 
L["Permanent Enhancements"] = "Dauerhafte Gegenstandsverzauberungen"
L["Phials"] = "Phiolen"
--[[Translation missing --]]
--[[ L["Phials added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phoenix Wishwing (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Plate Catch-Up Gear."] = ""--]] 
L["Potions"] = "Tränke"
L["Potions & Elixirs"] = "Tränke & Elixiere"
--[[Translation missing --]]
--[[ L["Potions added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting or collecting"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Accessories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Mail"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Plate"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Weapon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primordial Stones & Onyx Annulet"] = ""--]] 
L["Profession Gear"] = "Berufsausrüstung"
L["Profession Knowledge"] = "Berufswissen"
L["Professions"] = "Berufe"
L["Reputation Items"] = "Ruf Gegenstände"
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ruby Feast"] = ""--]] 
--[[Translation missing --]]
--[[ L["Runes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Scrappy Worldsnail (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
L["Select a color for %s."] = "Wähle eine Farbe für %s."
L["Select a color for the merged %s category."] = "Wähle eine Farbe für die zusammengeführte Kategorie %s."
L["Select a color for the prefix."] = "Wähle eine Farbe für das Präfix."
L["Select a prefix for the categories, if you like."] = "Wählen Sie, wenn Sie möchten, ein Präfix für die Kategorien."
L["Settings affecting all categories."] = "Einstellungen, die alle Kategorien betreffen."
L["Shadowflame Crests"] = "Schattenflammenwappen"
L["Should Categories be colored?"] = "Sollen Kategorien farbig sein?"
L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = "Soll das Präfix in der Farbe des Filters eingefärbt werden? (Funktioniert aus offensichtlichen Gründen nur bei Text-Präfixen)."
L["Specialized gear which improves your profession"] = "Spezialisierte Ausrüstung, die Ihren Beruf verbessert"
L["Statues"] = "Statuen"
L["Statues crafted by Jewelcrafters. They improve various things."] = "Von Juwelieren hergestellte Statuen. Sie verbessern verschiedene Dinge."
--[[Translation missing --]]
--[[ L["Temperamental Skyclaw (Mount)"] = ""--]] 
L["Temporary & Permanent Enhancements"] = "Vorübergehende und Permanente Gegenstandsverzauberungen"
L["Temporary Enhancements"] = "Vorübergehende Gegenstandsverzauberungen"
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
L["Tools"] = "Werkzeuge"
L["Treasure Maps"] = "Schatzkarten"
--[[Translation missing --]]
--[[ L["Treasure Sacks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = ""--]] 
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = ""--]] 
L["Zskera Vault"] = "Gewölbe von Zskera"

elseif locale == "ruRU" then
  L["%sMerge %s%s"] = "%sОбъединить %s%s"
L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = "Маунт, которого можно разблокировать в ключах Он'ир на Равнинах Он'ары. Требуется сдавать один из этих предметов раз в день."
L["Achievements & Unlockables"] = "Достижения & Разблокируемые"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags никогда не предполагал использование иконок, поэтому они глючат. Обязательно отключите префиксный цвет, если вы используете иконку."
L["Alchemy Flasks"] = "Алхимические флаконы"
L["Artifacts"] = "Артефакты"
L["Artisan Curious"] = "Ремесленные сувениры"
--[[Translation missing --]]
--[[ L["Awakened and Rousing Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Baits to attract skinnable creatures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages, to patch up your broken friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Weapon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons, to share your soup with friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Clawbering (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Currencies"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chip (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cloth Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consumables"] = ""--]] 
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains runes & vantus runes which improving your combat ability."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Alchemy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Darkmoon Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dragonflight"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embellishments"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
--[[Translation missing --]]
--[[ L["Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures for catching specific fish"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = ""--]] 
--[[Translation missing --]]
--[[ L["Forbidden Reach (10.0.7)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fortune Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fyrak Assault"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Profession Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Settings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Herbs - Seeds"] = ""--]] 
--[[Translation missing --]]
--[[ L["Honor Our Ancestors"] = ""--]] 
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense"] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
--[[Translation missing --]]
--[[ L["Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Level Upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items in professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
--[[Translation missing --]]
--[[ L["Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lizis Reins (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Magmashell (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mail Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mossy Mammoth"] = ""--]] 
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Otto (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phoenix Wishwing (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Plate Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions & Elixirs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting or collecting"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Accessories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Mail"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Plate"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Weapon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primordial Stones & Onyx Annulet"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ruby Feast"] = ""--]] 
--[[Translation missing --]]
--[[ L["Runes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Scrappy Worldsnail (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for %s."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the merged %s category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the prefix."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a prefix for the categories, if you like."] = ""--]] 
--[[Translation missing --]]
--[[ L["Settings affecting all categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Shadowflame Crests"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should Categories be colored?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Specialized gear which improves your profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
--[[Translation missing --]]
--[[ L["Temperamental Skyclaw (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
--[[Translation missing --]]
--[[ L["Tools"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Maps"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = ""--]] 
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Zskera Vault"] = ""--]] 

elseif locale == "esES" then
  --[[Translation missing --]]
--[[ L["%sMerge %s%s"] = ""--]] 
--[[Translation missing --]]
--[[ L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = ""--]] 
--[[Translation missing --]]
--[[ L["Achievements & Unlockables"] = ""--]] 
--[[Translation missing --]]
--[[ L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Alchemy Flasks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artifacts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artisan Curious"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened and Rousing Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Baits to attract skinnable creatures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages, to patch up your broken friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Weapon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons, to share your soup with friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Clawbering (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Currencies"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chip (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cloth Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consumables"] = ""--]] 
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains runes & vantus runes which improving your combat ability."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Alchemy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Darkmoon Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dragonflight"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embellishments"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
--[[Translation missing --]]
--[[ L["Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures for catching specific fish"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = ""--]] 
--[[Translation missing --]]
--[[ L["Forbidden Reach (10.0.7)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fortune Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fyrak Assault"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Profession Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Settings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Herbs - Seeds"] = ""--]] 
--[[Translation missing --]]
--[[ L["Honor Our Ancestors"] = ""--]] 
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense"] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
--[[Translation missing --]]
--[[ L["Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Level Upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items in professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
--[[Translation missing --]]
--[[ L["Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lizis Reins (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Magmashell (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mail Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mossy Mammoth"] = ""--]] 
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Otto (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phoenix Wishwing (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Plate Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions & Elixirs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting or collecting"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Accessories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Mail"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Plate"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Weapon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primordial Stones & Onyx Annulet"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ruby Feast"] = ""--]] 
--[[Translation missing --]]
--[[ L["Runes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Scrappy Worldsnail (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for %s."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the merged %s category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the prefix."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a prefix for the categories, if you like."] = ""--]] 
--[[Translation missing --]]
--[[ L["Settings affecting all categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Shadowflame Crests"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should Categories be colored?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Specialized gear which improves your profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
--[[Translation missing --]]
--[[ L["Temperamental Skyclaw (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
--[[Translation missing --]]
--[[ L["Tools"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Maps"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = ""--]] 
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Zskera Vault"] = ""--]] 

elseif locale == "zhTW" then
  L["%sMerge %s%s"] = "%s合併%s%s"
--[[Translation missing --]]
--[[ L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = ""--]] 
L["Achievements & Unlockables"] = "成就 & 解鎖用"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags 從來沒有打算使用圖示，所以這只是小故障。如果你使用圖示，請確保已停用彩色前置文字。"
L["Alchemy Flasks"] = "煉金瓶"
L["Artifacts"] = "文物"
L["Artisan Curious"] = "工匠珍品"
L["Awakened and Rousing Elemental Trade Goods"] = "製造材料喚醒元素和覺醒元素"
L["Awakened Elementals"] = "覺醒元素"
L["Baits to attract skinnable creatures"] = "用來吸引一些可剝皮生物的餌"
L["Bandages"] = "繃帶"
L["Bandages, to patch up your broken friends :)"] = "繃帶, 幫你受傷的朋友包紮"
L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = "追趕機制飾品 - 包括戒指、項鍊、飾品和披風。"
L["Catch-Up Weapon."] = "追趕機制武器。"
L["Cauldrons"] = "大鍋"
L["Cauldrons, to share your soup with friends :)"] = "大鍋, 分享湯給你的朋友"
L["Cavern Clawbering (Achievement)"] = "響動爪 (成就)"
L["Cavern Currencies"] = "洞窟通貨"
L["Chip (Pet)"] = "小鑿 (寵物)"
L["Cloth"] = "布料"
L["Cloth Catch-Up Gear."] = "追趕機制布甲。"
L["Color"] = "顏色"
L["Colored Categories"] = "彩色類別名稱"
L["Colored Prefix"] = "彩色前置文字"
L["Consumables"] = "消耗品"
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = "包含直接用來繳交聲望/名望的物品，以及交給怒西昂和賽柏利安的物品。"
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
L["Contains runes & vantus runes which improving your combat ability."] = "包含符文 & 梵陀符文，可用來強化你的戰鬥能力。"
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
L["Contains various tools, helpful in the Dragon Isles."] = "包含各種在巨龍群島有用的工具。"
L["Contracts"] = "合約"
L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = "合約在你完成巨龍群島的世界任務時會給予你額外的聲望"
L["Cooking"] = "烹飪"
L["Crafting Potions"] = "加工藥水"
L["Crafting Reagents categorically belonging to Alchemy"] = "煉金術相關的製造材料"
L["Crafting Reagents categorically belonging to Cloth"] = "裁縫相關的製造材料"
L["Crafting Reagents categorically belonging to Cooking"] = "烹飪相關的製造材料"
L["Crafting Reagents categorically belonging to Enchanting"] = "附魔相關的製造材料"
L["Crafting Reagents categorically belonging to Engineering"] = "工程學相關的製造材料"
L["Crafting Reagents categorically belonging to Herbs"] = "草藥學"
L["Crafting Reagents categorically belonging to Inscription"] = "銘文學相關的製造材料"
L["Crafting Reagents categorically belonging to Jewelcrafting"] = "珠寶學相關的製造材料"
L["Crafting Reagents categorically belonging to Leather"] = "製皮相關的製造材料"
L["Crafting Reagents categorically belonging to Mining"] = "採礦相關的製造材料"
L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = "巨龍崛起前夕事件掉落的，類似貨幣的物品。"
L["Custom Prefix"] = "自訂前置文字"
L["Darkmoon Cards"] = "暗月卡"
L["Dragonflight"] = "巨龍崛起"
L["Drakewatcher Manuscripts"] = "飛龍觀察者手稿"
L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = "學習飛龍騎術坐騎新外觀的飛龍觀察者手稿"
L["Elemental Trade Goods"] = "元素"
L["Embellishments"] = "裝飾"
L["Embers of Neltharion (10.1)"] = "奈薩里奧的餘燼 (10.1)"
L["Enchanting"] = "附魔"
L["Enchanting - Insight of the Blue"] = "附魔 - 藍龍洞察力"
L["Engineering"] = "工程學"
L["Enter a custom prefix for the categories."] = "輸入分類的自訂前置文字。"
L["Filter version"] = "版本"
L["Fishing Lures"] = "魚餌"
L["Fishing Lures for catching specific fish"] = "用來釣特定魚的餌"
L["Food"] = "食物"
L["Food added in the Dragonflight expansion"] = "巨龍崛起版本的食物"
L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = "晶紅盛宴的食物 - 只有裝飾效果能在開放地圖外使用"
L["Forbidden Reach (10.0.7)"] = "禁忌之境 (10.0.7)"
L["Fortune Cards"] = "命運卡片"
L["Fyrak Assault"] = "菲拉克入侵"
L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = "巨龍崛起前夕事件掉落的或購買的裝備"
L["Gems"] = "寶石"
L["General Crafting Reagents"] = "通用材料"
L["General Crafting Reagents, used by multiple professions"] = "通用的製造材料，多種專業都會用到。"
L["General Profession Items"] = "通用專業物品"
L["General Settings"] = "一般設定"
L["Herbs"] = "草藥"
L["Herbs - Seeds"] = "草藥 - 種子"
L["Honor Our Ancestors"] = "光宗耀祖"
L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = "取代前置文字或分類顏色時，需要開關顏色設定兩次，或是重新載入介面。"
L["Incense"] = "薰香"
L["Incense to improve crafting ability or just for a nice smell"] = "薰香可以增加你製造的能力或是只是好聞的味道"
L["Inscription"] = "銘文學"
L["Item Level Upgrades"] = "提升物品等級"
L["Items found or used in the Zskera Vault."] = "在澤斯克拉密庫找到和使用物品。"
L["Items from the Dragonflight expansion."] = "巨龍崛起資料片的物品。"
L["Items from the Dragonflight Pre-Event."] = "巨龍崛起前夕事件的物品。"
L["Items in professions"] = "專業物品"
L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = "當附魔專精 '藍龍洞察力' 有點的時候可以找到並分解的物品"
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
L["Items that provide profession knowledge"] = "提供專業知識的物品"
L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = "用於成就或可用來解鎖坐騎的物品，一旦成就或坐騎解鎖後，這些物品就沒有價值了。"
L["Items which are used in multiple professions."] = "多種專業都會用到的物品。"
L["Items which can be found and used in the Forbidden Reach."] = "在禁忌之境找到和使用物品。"
L["Items which can be found and used in the Zaralek Cavern."] = "在札拉萊克洞窟找到和使用物品。"
L["Items which upgrade the item level of crafted gear."] = "用來升級製作裝備等級的物品。"
L["Items you can eat or use to improve yourself"] = "可以吃或使用，用來強化自己的物品。"
L["Jewelcrafting"] = "珠寶加工"
L["Leather"] = "皮革"
L["Leather - Bait"] = "皮革 - 誘餌"
L["Leather Catch-Up Gear."] = "追趕機制皮甲。"
L["Leftover Elemental Slime"] = "殘留的元素黏液"
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
L["Lizis Reins (Mount)"] = "莉茲 (坐騎)"
L["Magmashell (Mount)"] = "熔殼蝸牛 (坐騎)"
L["Mail Catch-Up Gear."] = "追趕機制鎖甲。"
L["Maps to Treasure found in the Dragon Isles"] = "巨龍群島的藏寶圖"
L["Merge all %s into a single category."] = "將所有%s都合併成單一類別"
L["Mining"] = "採礦"
L["Mossy Mammoth"] = "青苔猛瑪象"
L["None"] = "無"
L["Other Items"] = "其他物品"
L["Other items not really fitting in another category."] = "不屬於任何現有分類的其他物品。"
L["Otto (Mount)"] = "奧圖 (坐騎)"
L["Permanent Enhancements"] = "永久性強化"
L["Phials"] = "藥瓶"
L["Phials added in the Dragonflight expansion"] = "巨龍崛起資料片新增的藥瓶"
L["Phoenix Wishwing (Pet)"] = "鳳凰希翼 (寵物)"
L["Plate Catch-Up Gear."] = "追趕機制板甲。"
L["Potions"] = "藥水"
L["Potions & Elixirs"] = "藥水 & 精煉"
L["Potions added in the Dragonflight expansion"] = "巨龍崛起資料片的藥水"
L["Potions which improve crafting"] = "強化專業製造的藥水"
L["Potions which improve crafting or collecting"] = "強化專業製造或採集力的藥水"
L["PreEvent"] = "前夕事件"
L["PreEvent Currency"] = "前夕事件貨幣"
L["PreEvent Gear"] = "前夕事件裝備"
L["Prefix Categories"] = "類別前置文字/圖示"
L["Prefix Color"] = "前置文字顏色"
L["Primalist Accessories"] = "洪荒飾品"
L["Primalist Cloth"] = "洪荒布甲"
L["Primalist Gear Tokens"] = "洪荒裝備代幣"
L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = "洪荒裝備代幣是帳號綁定的追趕機制裝備。"
L["Primalist Leather"] = "洪荒皮甲"
L["Primalist Mail"] = "洪荒鎖甲"
L["Primalist Plate"] = "洪荒鎧甲"
L["Primalist Weapon"] = "洪荒武器"
L["Primordial Stones & Onyx Annulet"] = "原初之石&瑪瑙環飾"
L["Profession Gear"] = "專業裝備"
L["Profession Knowledge"] = "專業知識"
L["Professions"] = "專業"
L["Reputation Items"] = "聲望物品"
L["Rousing Elementals"] = "喚醒元素"
L["Ruby Feast"] = "晶紅盛宴"
L["Runes"] = "符文"
L["Scrappy Worldsnail (Mount)"] = "好鬥的天體蝸牛"
L["Seeds to plant into Rich Soil which in return grants some herbs"] = "將種子種在肥沃的土壤中，會穫得一些草藥。"
L["Select a color for %s."] = "選擇%s的顏色。"
L["Select a color for the merged %s category."] = "選擇合併的%s類別顏色。"
L["Select a color for the prefix."] = "選擇前置文字的顏色。"
L["Select a prefix for the categories, if you like."] = "如果你想的話，可以幫類別選擇前置文字/圖案。"
L["Settings affecting all categories."] = "會影響所有類別的設定。"
L["Shadowflame Crests"] = "暗焰紋章"
L["Should Categories be colored?"] = "類別是否要彩色的?"
L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = "前置文字是否要彩色的，以便篩選顏色? (很明顯的只適用於文字)"
L["Specialized gear which improves your profession"] = "強化專業的特殊裝備"
L["Statues"] = "雕像"
L["Statues crafted by Jewelcrafters. They improve various things."] = "珠寶製造的雕像. 有不同的效果"
L["Temperamental Skyclaw (Mount)"] = "暴躁的天爪 (坐騎)"
L["Temporary & Permanent Enhancements"] = "暫時 & 永久性強化"
L["Temporary Enhancements"] = "暫時性強化"
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
L["These are gems that you can typically apply to armor to improve it."] = "這些是通常用在護甲上以獲得提升的寶石。"
L["These are permanent enhancements that you can typically apply to armor to improve it."] = "這些是通常用在護甲上以獲得提升的永久性強化。"
L["These are temporary enhancements that you can typically apply to armor to improve it."] = "這些是通常用在護甲上以獲得提升的暫時性強化。"
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
L["These items can be used to summon a rare mob in the Forbidden Reach."] = "這些物品可以用來召喚禁忌之境的稀有物。"
L["These settings affect all categories of this filter."] = "這些設定會影響這個過濾程式中的所有類別。"
L["This category contains currencies, used in the Zaralek Cavern."] = "此類別包含在札拉萊克洞窟使用的貨幣。"
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
L["This category contains hunting companion colors needed for the achievement."] = "此類別包含達成成就所需的狩獵夥伴顏色。"
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
L["This category contains the items needed to get the Chip pet."] = "此類別包含獲得寵物小鑿所需的物品。"
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = "此類別只包含在甦醒海岸取得熔殼蝸牛坐騎所需的空熔岩外殼。"
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
L["Tools"] = "工具"
L["Treasure Maps"] = "藏寶圖"
L["Treasure Sacks"] = "珍寶囊"
L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = "所有龍族的救世主，大史瓦格蛙給的珍寶囊。"
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
L["Use these for a powerup!"] = "使用這些來增強能力!"
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = ""--]] 
L["Zskera Vault"] = "澤斯克拉密庫"

elseif locale == "zhCN" then
  --[[Translation missing --]]
--[[ L["%sMerge %s%s"] = ""--]] 
--[[Translation missing --]]
--[[ L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = ""--]] 
--[[Translation missing --]]
--[[ L["Achievements & Unlockables"] = ""--]] 
--[[Translation missing --]]
--[[ L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Alchemy Flasks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artifacts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artisan Curious"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened and Rousing Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Baits to attract skinnable creatures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages, to patch up your broken friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Weapon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons, to share your soup with friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Clawbering (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Currencies"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chip (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cloth Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Colored Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consumables"] = ""--]] 
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains runes & vantus runes which improving your combat ability."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Alchemy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Darkmoon Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dragonflight"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embellishments"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
--[[Translation missing --]]
--[[ L["Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures for catching specific fish"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = ""--]] 
--[[Translation missing --]]
--[[ L["Forbidden Reach (10.0.7)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fortune Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fyrak Assault"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Profession Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Settings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Herbs - Seeds"] = ""--]] 
--[[Translation missing --]]
--[[ L["Honor Our Ancestors"] = ""--]] 
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense"] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
--[[Translation missing --]]
--[[ L["Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Level Upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items in professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
--[[Translation missing --]]
--[[ L["Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lizis Reins (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Magmashell (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mail Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mossy Mammoth"] = ""--]] 
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Otto (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phoenix Wishwing (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Plate Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions & Elixirs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting or collecting"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Accessories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Mail"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Plate"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Weapon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primordial Stones & Onyx Annulet"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ruby Feast"] = ""--]] 
--[[Translation missing --]]
--[[ L["Runes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Scrappy Worldsnail (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for %s."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the merged %s category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the prefix."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a prefix for the categories, if you like."] = ""--]] 
--[[Translation missing --]]
--[[ L["Settings affecting all categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Shadowflame Crests"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should Categories be colored?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Specialized gear which improves your profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
--[[Translation missing --]]
--[[ L["Temperamental Skyclaw (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
--[[Translation missing --]]
--[[ L["Tools"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Maps"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = ""--]] 
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Zskera Vault"] = ""--]] 

elseif locale == "koKR" then
  --[[Translation missing --]]
--[[ L["%sMerge %s%s"] = ""--]] 
L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = "온아라 평야의 온이르 샘에서 잠금 해제할 수 있는 탈것입니다. 하루에 한 번 다음 아이템 중 하나를 제출해야 합니다."
L["Achievements & Unlockables"] = "업적 및 잠금 해제 가능"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags은 아이콘을 사용할 의도가 없었기 때문에 결함이 있습니다. 아이콘을 사용하는 경우 접두사 색상을 비활성화해야 합니다."
L["Alchemy Flasks"] = "연금술 영약"
L["Artifacts"] = "유물"
L["Artisan Curious"] = "장인 골동품"
--[[Translation missing --]]
--[[ L["Awakened and Rousing Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Baits to attract skinnable creatures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bandages, to patch up your broken friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Weapon."] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cauldrons, to share your soup with friends :)"] = ""--]] 
L["Cavern Clawbering (Achievement)"] = "업적: 동굴의 발톱 학살자"
--[[Translation missing --]]
--[[ L["Cavern Currencies"] = ""--]] 
L["Chip (Pet)"] = "화폐 (애완동물)"
L["Cloth"] = "천"
--[[Translation missing --]]
--[[ L["Cloth Catch-Up Gear."] = ""--]] 
L["Color"] = "색상"
L["Colored Categories"] = "색상 범주"
L["Colored Prefix"] = "색상 접두사"
L["Consumables"] = "소비용"
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains runes & vantus runes which improving your combat ability."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = ""--]] 
L["Cooking"] = "요리"
--[[Translation missing --]]
--[[ L["Crafting Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Alchemy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
L["Darkmoon Cards"] = "다크문 카드"
L["Dragonflight"] = "용 군단"
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elemental Trade Goods"] = ""--]] 
L["Embellishments"] = "장식"
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
L["Enchanting"] = "마법부여"
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
L["Engineering"] = "기계공학"
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
L["Fishing Lures"] = "낚시 미끼"
--[[Translation missing --]]
--[[ L["Fishing Lures for catching specific fish"] = ""--]] 
L["Food"] = "음식"
--[[Translation missing --]]
--[[ L["Food added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = ""--]] 
--[[Translation missing --]]
--[[ L["Forbidden Reach (10.0.7)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fortune Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fyrak Assault"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Profession Items"] = ""--]] 
L["General Settings"] = "일반 설정"
L["Herbs"] = "약초"
L["Herbs - Seeds"] = "약초 - 씨앗"
--[[Translation missing --]]
--[[ L["Honor Our Ancestors"] = ""--]] 
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense"] = ""--]] 
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
--[[Translation missing --]]
--[[ L["Inscription"] = ""--]] 
L["Item Level Upgrades"] = "아이템 레벨 업그레이드"
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
L["Items in professions"] = "전문 기술 아이템"
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
--[[Translation missing --]]
--[[ L["Jewelcrafting"] = ""--]] 
L["Leather"] = "가죽"
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
L["Librarian of the Reach (Achievement)"] = "금지된 해안의 사서 (업적)"
L["Lizis Reins (Mount)"] = "탈것: 리지의 고삐"
L["Magmashell (Mount)"] = "탈것: 용암껍질"
--[[Translation missing --]]
--[[ L["Mail Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
L["Mining"] = "채광"
L["Mossy Mammoth"] = "이끼투성이 매머드"
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
L["Otto (Mount)"] = "탈것: 오토"
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
L["Phials"] = "약병"
--[[Translation missing --]]
--[[ L["Phials added in the Dragonflight expansion"] = ""--]] 
L["Phoenix Wishwing (Pet)"] = "애완동물: 불사조 소원날개"
--[[Translation missing --]]
--[[ L["Plate Catch-Up Gear."] = ""--]] 
L["Potions"] = "물약"
L["Potions & Elixirs"] = "물약 & 비약"
--[[Translation missing --]]
--[[ L["Potions added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting or collecting"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
L["Prefix Categories"] = "접두사 범주"
L["Prefix Color"] = "접두사 색상"
L["Primalist Accessories"] = "원시술사 장신구"
L["Primalist Cloth"] = "원시술사 천"
L["Primalist Gear Tokens"] = "원시술사 장비 토큰"
L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = "원시술사 장비 토큰은 계정 전체의 공유 장비입니다."
L["Primalist Leather"] = "원시술사 가죽"
L["Primalist Mail"] = "원시술사 사슬"
L["Primalist Plate"] = "원시술사 판금"
L["Primalist Weapon"] = "원시술사 무기"
L["Primordial Stones & Onyx Annulet"] = "태고의 돌 & 흑마노 반지"
L["Profession Gear"] = "전문 기술 장비"
L["Profession Knowledge"] = "전문 기술 지식"
L["Professions"] = "전문 기술"
L["Reputation Items"] = "평판 아이템"
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
L["Ruby Feast"] = "루비 연회장"
L["Runes"] = "룬"
--[[Translation missing --]]
--[[ L["Scrappy Worldsnail (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for %s."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the merged %s category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the prefix."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a prefix for the categories, if you like."] = ""--]] 
--[[Translation missing --]]
--[[ L["Settings affecting all categories."] = ""--]] 
L["Shadowflame Crests"] = "암흑불길 문장"
--[[Translation missing --]]
--[[ L["Should Categories be colored?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Specialized gear which improves your profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
L["Temperamental Skyclaw (Mount)"] = "탈것: 신경질적인 하늘발톱"
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
L["Tetrachromancer (Achievement)"] = "업적: 사냥은 색다르게"
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
L["Tools"] = "도구"
L["Treasure Maps"] = "보물지도"
L["Treasure Sacks"] = "보물자루"
--[[Translation missing --]]
--[[ L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = ""--]] 
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
L["While We Were Sleeping (Achievement)"] = "업적: 우리가 잠든 사이에"
L["Zskera Vault"] = "지스케라 금고"

elseif locale == "ptBR" then
  L["%sMerge %s%s"] = "%sMesclar %s%s"
L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = "Uma montaria que pode ser desbloqueada nas Fontes Ohn'iri em Chapada Ohn'ahrana. É necessário entregar um desses itens uma vez por dia."
L["Achievements & Unlockables"] = "Conquistas e Desbloqueáveis"
L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = "AdiBags nunca teve a intenção de usar ícones, então eles são problemáticos. Certifique-se de desativar a cor do prefixo, se você usar um ícone."
L["Alchemy Flasks"] = "Frascos de Alquimia"
L["Artifacts"] = "Artefatos"
L["Artisan Curious"] = "Raridades de Artífice"
L["Awakened and Rousing Elemental Trade Goods"] = "Produtos de Ordem Desperta e Ordem Estimulante "
L["Awakened Elementals"] = "Ordem Desperta"
L["Baits to attract skinnable creatures"] = "Iscas para atrair criaturas que podem ser esfoladas"
L["Bandages"] = "Bandagens"
L["Bandages, to patch up your broken friends :)"] = "Bandagens, para curar seus amigos feridos :)"
L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = "Acessórios se atualizar - contém anéis, colares, berloques e capas."
L["Catch-Up Weapon."] = "Armas para se atualizar"
L["Cauldrons"] = "Caldeirões"
L["Cauldrons, to share your soup with friends :)"] = "Caldeirões, para compartilhar sopa com os amigos :)"
L["Cavern Clawbering (Achievement)"] = "Caverna Garrada (Conquista)"
L["Cavern Currencies"] = "Moedas da Caverna"
L["Chip (Pet)"] = "Pedrico (Pet)"
L["Cloth"] = "Tecido"
L["Cloth Catch-Up Gear."] = "Equipamento de Tecido para se atualizar"
L["Color"] = "Cor"
L["Colored Categories"] = "Categorias coloridas"
L["Colored Prefix"] = "Prefixo colorido"
L["Consumables"] = "Consumíveis"
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
L["Contains runes & vantus runes which improving your combat ability."] = "Contém runas e runas vantus que melhoram sua habilidade de combate."
--[[Translation missing --]]
--[[ L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
L["Contracts"] = "Contratos"
--[[Translation missing --]]
--[[ L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = ""--]] 
L["Cooking"] = "Culinária"
L["Crafting Potions"] = "Poções de Criação"
L["Crafting Reagents categorically belonging to Alchemy"] = "Reagentes de Criação pertencentes categoricamente à Alquimia"
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
L["Crafting Reagents categorically belonging to Herbs"] = "Reagentes de Criação que pertencem categoricamente à Plantas"
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
--[[Translation missing --]]
--[[ L["Darkmoon Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dragonflight"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = ""--]] 
L["Elemental Trade Goods"] = "Mercadorias de Elemental"
L["Embellishments"] = "Embelezados"
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
L["Enchanting"] = "Encantamento"
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
L["Engineering"] = "Engenharia"
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fishing Lures for catching specific fish"] = ""--]] 
L["Food"] = "Comida"
L["Food added in the Dragonflight expansion"] = "Comida adicionada na expansão Dragonflight"
L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = "Comida do Banquete Rubi - apenas efeitos cosméticos funcionam fora do mundo aberto"
--[[Translation missing --]]
--[[ L["Forbidden Reach (10.0.7)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fortune Cards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Fyrak Assault"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
L["General Profession Items"] = "Itens gerais de profissão"
L["General Settings"] = "Configurações Gerais"
L["Herbs"] = "Plantas"
L["Herbs - Seeds"] = "Plantas - Sementes"
--[[Translation missing --]]
--[[ L["Honor Our Ancestors"] = ""--]] 
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
L["Incense"] = "Incenso"
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
--[[Translation missing --]]
--[[ L["Inscription"] = ""--]] 
L["Item Level Upgrades"] = "Aprimoramentos de Nível de Item"
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items in professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
L["Items which can be found and used in the Zaralek Cavern."] = "Itens que podem ser encontrados e usados ​​na Caverna Zaralek."
L["Items which upgrade the item level of crafted gear."] = "Itens que melhoram o nível do equipamento criado."
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
--[[Translation missing --]]
--[[ L["Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
L["Leather Catch-Up Gear."] = "Equipamento de Couro para se atualizar"
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lizis Reins (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Magmashell (Mount)"] = ""--]] 
L["Mail Catch-Up Gear."] = "Equipamento de Malha para se atualizar"
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mossy Mammoth"] = ""--]] 
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
L["Otto (Mount)"] = "Otto (Montaria)"
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
L["Phials"] = "Frascos"
L["Phials added in the Dragonflight expansion"] = "Frascos adicionados na expansão Dragonflight"
--[[Translation missing --]]
--[[ L["Phoenix Wishwing (Pet)"] = ""--]] 
L["Plate Catch-Up Gear."] = "Equipamento de Placa para se atualizar"
L["Potions"] = "Poções"
L["Potions & Elixirs"] = "Poções e Elixires"
L["Potions added in the Dragonflight expansion"] = "Poções adicionadas na expansão Dragonflight"
L["Potions which improve crafting"] = "Poções que melhoram a criação"
L["Potions which improve crafting or collecting"] = "Poções que melhoram a criação ou a coleta"
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Categories"] = ""--]] 
L["Prefix Color"] = "Cor de Prefixo"
L["Primalist Accessories"] = "Acessórios Primevista"
L["Primalist Cloth"] = "Tecido Primevista"
L["Primalist Gear Tokens"] = "Tokens de Equipamento Primevista"
L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = "Tokens de Equipamento Primevista são equipamentos para se atualizar vinculados à conta."
L["Primalist Leather"] = "Couro  Primevista"
L["Primalist Mail"] = "Malha Primevista"
L["Primalist Plate"] = "Placa Primevista"
L["Primalist Weapon"] = "Arma Primevista"
L["Primordial Stones & Onyx Annulet"] = "Pedras Primordiais & Anelete de Ônix"
L["Profession Gear"] = "Equipamentos de Profissão"
L["Profession Knowledge"] = "Conhecimento de Profissão"
L["Professions"] = "Profissões"
L["Reputation Items"] = "Itens de Reputação"
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
L["Ruby Feast"] = "Banquete Rubi"
L["Runes"] = "Runas"
L["Scrappy Worldsnail (Mount)"] = "Lesmamundo Obstinada (Montaria)"
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
L["Select a color for %s."] = "Selecione uma cor para %s."
L["Select a color for the merged %s category."] = "Selecione uma cor para a categoria mesclada %s."
L["Select a color for the prefix."] = "Selecione uma cor para o prefixo"
L["Select a prefix for the categories, if you like."] = "Selecione um prefixo para as categorias, se desejar."
L["Settings affecting all categories."] = "Configurações que afetam todas as categorias."
L["Shadowflame Crests"] = "Brasões da Chama Sombria"
L["Should Categories be colored?"] = "As categorias devem ser coloridas?"
--[[Translation missing --]]
--[[ L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Specialized gear which improves your profession"] = ""--]] 
L["Statues"] = "Estátuas"
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
--[[Translation missing --]]
--[[ L["Temperamental Skyclaw (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = "Esta categoria contém Pedras Primordiais, que podem ser inseridas no Anelete de Ônix e no próprio Anelete."
L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = "Esta categoria contém Brasões da Chama Sombria, que podem ser usados para aprimorar equipamentos"
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
L["Tools"] = "Ferramentas"
L["Treasure Maps"] = "Mapas do Tesouro"
L["Treasure Sacks"] = "Saco de Tesouros"
L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = "Saco de Tesouros dados pel'O Grande Zapo, Salvador de todos os dragões."
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
L["While We Were Sleeping (Achievement)"] = "Enquanto dormíamos (Conquista)"
L["Zskera Vault"] = "Câmaras de Zskera"

elseif locale == "itIT" then
  --[[Translation missing --]]
--[[ L["%sMerge %s%s"] = ""--]] 
--[[Translation missing --]]
--[[ L["A mount that can be unlocked in Ohn'iri Springs in the Ohn'ahran Plains. Requires to hand in one of these items once a day."] = ""--]] 
--[[Translation missing --]]
--[[ L["Achievements & Unlockables"] = ""--]] 
--[[Translation missing --]]
--[[ L["AdiBags never intended to use icons, so they are glitchy. Make sure to disable prefix color, if you use an icon."] = ""--]] 
L["Alchemy Flasks"] = "Tonici di Alchimia"
L["Artifacts"] = "Manufatti"
--[[Translation missing --]]
--[[ L["Artisan Curious"] = ""--]] 
--[[Translation missing --]]
--[[ L["Awakened and Rousing Elemental Trade Goods"] = ""--]] 
L["Awakened Elementals"] = "Elementali Risvegliati"
--[[Translation missing --]]
--[[ L["Baits to attract skinnable creatures"] = ""--]] 
L["Bandages"] = "Bendaggi"
--[[Translation missing --]]
--[[ L["Bandages, to patch up your broken friends :)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Accessories - contains Rings, Necklaces, Trinkets & Cloaks."] = ""--]] 
--[[Translation missing --]]
--[[ L["Catch-Up Weapon."] = ""--]] 
L["Cauldrons"] = "Calderoni"
L["Cauldrons, to share your soup with friends :)"] = "Calderoni, per condividere la zuppa con gli amici :)"
--[[Translation missing --]]
--[[ L["Cavern Clawbering (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cavern Currencies"] = ""--]] 
--[[Translation missing --]]
--[[ L["Chip (Pet)"] = ""--]] 
L["Cloth"] = "Stoffa"
--[[Translation missing --]]
--[[ L["Cloth Catch-Up Gear."] = ""--]] 
L["Color"] = "Colore"
L["Colored Categories"] = "Categorie Colorate"
L["Colored Prefix"] = "Prefissi Colorati"
L["Consumables"] = "Consumabili"
--[[Translation missing --]]
--[[ L["CONTAINS ITEMS FROM OTHER CATEGORIES! These items can be handed in the Ohn'ahran Plains (while under the effect of Essence of Awakening) to get this achievement."] = ""--]] 
L["Contains Items which can be directly traded in for reputation/renown, as well as items needed for Wrathion & Sabellian"] = "Contiene Oggetti che possono essere direttamente scambiati per reputazione/fama, e oggetti necessari per Irathion & Sabellian"
--[[Translation missing --]]
--[[ L["Contains Items which can be directly traded in or used for reputation/renown, as well as items needed for Wrathion & Sabellian"] = ""--]] 
L["Contains runes & vantus runes which improving your combat ability."] = "Continene Rune e Rune Vantus che migliorano la tua abilità di combattimento."
L["Contains Untapped Forbidden Knowledge, used for upgrading Primalist Gear."] = "Contiene Conoscenza Proibita Inutilizzata, utilizzata per migliorare l'Equipaggiamento dei Primalisti"
--[[Translation missing --]]
--[[ L["Contains various tools, helpful in the Dragon Isles."] = ""--]] 
L["Contracts"] = "Contratti"
L["Contracts give additional reputation when completing world quests in the Dragon Isles."] = "Contratti che danno reputazione aggiuntiva quando si completano le missioni mondiali nelle Isole dei Draghi"
L["Cooking"] = "Cucina"
--[[Translation missing --]]
--[[ L["Crafting Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Alchemy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Cooking"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Enchanting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Engineering"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Crafting Reagents categorically belonging to Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Currency-like items dropped in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Custom Prefix"] = ""--]] 
L["Darkmoon Cards"] = "Carte dei Lunacupa"
L["Dragonflight"] = "Volo Draconico"
L["Drakewatcher Manuscripts"] = "Manoscritti dei Guardadrachi"
L["Drakewatcher Manuscripts for learning new customizations for your Dragonriding mounts"] = "Manoscritti dei Guardadrachi per imparare nuove customizzazioni per la tua cavalcatura del Volo Draconico"
--[[Translation missing --]]
--[[ L["Elemental Trade Goods"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embellishments"] = ""--]] 
--[[Translation missing --]]
--[[ L["Embers of Neltharion (10.1)"] = ""--]] 
L["Enchanting"] = "Incantamento"
--[[Translation missing --]]
--[[ L["Enchanting - Insight of the Blue"] = ""--]] 
L["Engineering"] = "Ingegneria"
--[[Translation missing --]]
--[[ L["Enter a custom prefix for the categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Filter version"] = ""--]] 
L["Fishing Lures"] = "Esche per Pescare"
L["Fishing Lures for catching specific fish"] = "Esche per pescare pesci specific"
L["Food"] = "Cibo"
L["Food added in the Dragonflight expansion"] = "Cibo aggiunto nell'espansione Dragonflight"
--[[Translation missing --]]
--[[ L["Food from the Ruby Feast - only cosmetic effects work outside of the open world."] = ""--]] 
L["Forbidden Reach (10.0.7)"] = "Isola Proibita (10.0.7)"
L["Fortune Cards"] = "Carte della Fortuna"
--[[Translation missing --]]
--[[ L["Fyrak Assault"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gear dropped or bought in the Dragonflight Pre-Patch Event"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gems"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Crafting Reagents, used by multiple professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["General Profession Items"] = ""--]] 
L["General Settings"] = "Settaggi Generali"
L["Herbs"] = "Erbe"
L["Herbs - Seeds"] = "Erbe - Semi"
--[[Translation missing --]]
--[[ L["Honor Our Ancestors"] = ""--]] 
--[[Translation missing --]]
--[[ L["If you overwrite prefix or categorie color, you either need to toggle the color setting twice or reload."] = ""--]] 
L["Incense"] = "Incensi"
--[[Translation missing --]]
--[[ L["Incense to improve crafting ability or just for a nice smell"] = ""--]] 
--[[Translation missing --]]
--[[ L["Inscription"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Level Upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items found or used in the Zskera Vault."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight expansion."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items from the Dragonflight Pre-Event."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items in professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that can be found & disenchanted when 'Insight of the Blue' (Enchanting Perk) is skilled."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide embellishments to crafted items."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items that provide profession knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used for achievements or unlockable mounts. Most of them lose their value, once the achievement or mount is unlocked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which are used in multiple professions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which can be found and used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items which upgrade the item level of crafted gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Items you can eat or use to improve yourself"] = ""--]] 
--[[Translation missing --]]
--[[ L["Jewelcrafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather - Bait"] = ""--]] 
--[[Translation missing --]]
--[[ L["Leather Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Leftover Elemental Slime"] = ""--]] 
--[[Translation missing --]]
--[[ L["Librarian of the Reach (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lizis Reins (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Magmashell (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mail Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Maps to Treasure found in the Dragon Isles"] = ""--]] 
--[[Translation missing --]]
--[[ L["Merge all %s into a single category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Mining"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mossy Mammoth"] = ""--]] 
--[[Translation missing --]]
--[[ L["None"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other items not really fitting in another category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Otto (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phials added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Phoenix Wishwing (Pet)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Plate Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions & Elixirs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions added in the Dragonflight expansion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Potions which improve crafting or collecting"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Currency"] = ""--]] 
--[[Translation missing --]]
--[[ L["PreEvent Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Categories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefix Color"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Accessories"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Cloth"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Gear Tokens is an account wide Catch-Up Gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Leather"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Mail"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Plate"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primalist Weapon"] = ""--]] 
--[[Translation missing --]]
--[[ L["Primordial Stones & Onyx Annulet"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Gear"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Professions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rousing Elementals"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ruby Feast"] = ""--]] 
--[[Translation missing --]]
--[[ L["Runes"] = ""--]] 
--[[Translation missing --]]
--[[ L["Scrappy Worldsnail (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Seeds to plant into Rich Soil which in return grants some herbs"] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for %s."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the merged %s category."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a color for the prefix."] = ""--]] 
--[[Translation missing --]]
--[[ L["Select a prefix for the categories, if you like."] = ""--]] 
--[[Translation missing --]]
--[[ L["Settings affecting all categories."] = ""--]] 
--[[Translation missing --]]
--[[ L["Shadowflame Crests"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should Categories be colored?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Should the prefix be colored to the filter color? (Only works for text-prefixes, for obvious reasons.)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Specialized gear which improves your profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues"] = ""--]] 
--[[Translation missing --]]
--[[ L["Statues crafted by Jewelcrafters. They improve various things."] = ""--]] 
--[[Translation missing --]]
--[[ L["Temperamental Skyclaw (Mount)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary & Permanent Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Temporary Enhancements"] = ""--]] 
--[[Translation missing --]]
--[[ L["Tetrachromancer (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["These are gems that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are permanent enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These are temporary enhancements that you can typically apply to armor to improve it."] = ""--]] 
--[[Translation missing --]]
--[[ L["These artifacts can be traded in Morqut Village."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be found in the Zskera Vault and are used to create the Mossy Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["These items can be used to summon a rare mob in the Forbidden Reach."] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings affect all categories of this filter."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains currencies, used in the Zaralek Cavern."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains fragments, used during the Fyrak Assault event."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains hunting companion colors needed for the achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Primordial Stones, which can be inserted into the Onyx Annulet and the Annulet itself."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains Shadowflame Crests, which can be used to upgrade gear."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the books looted for the Librarian of the Reach achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the item needed to get the Cavern Clawbering achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Chip pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the items needed to get the Phoenix Wishwing pet."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category contains the quest items looted for the While We Were Sleeping achievement."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Empty Magma Shell required to get the Magmashell Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This category only contains the Membership and the Magmotes required to get the Scrappy Worldsnail Mount in the Waking Shores."] = ""--]] 
--[[Translation missing --]]
--[[ L["This item can be found in the Zskera Vault and is used to create the Leftover Elemental Slime Mammoth."] = ""--]] 
--[[Translation missing --]]
--[[ L["This section contains items which are needed to unlock Otto, the fishing ottusk mount."] = ""--]] 
--[[Translation missing --]]
--[[ L["To get Temperamental Skyclaw you have to collect these 3 types of food and turn it to Zon'Wogi Stable Master at Three-Falls Lookout (Azure Span)."] = ""--]] 
--[[Translation missing --]]
--[[ L["Tools"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Maps"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks"] = ""--]] 
--[[Translation missing --]]
--[[ L["Treasure Sacks given by the Great Swog, Saviour of all Dragonkind."] = ""--]] 
--[[Translation missing --]]
--[[ L["Untapped Forbidden Knowledge"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use these for a powerup!"] = ""--]] 
--[[Translation missing --]]
--[[ L["While We Were Sleeping (Achievement)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Zskera Vault"] = ""--]] 

end

for k, v in pairs(L) do
  if v == true then
    L[k] = k
  end
end
