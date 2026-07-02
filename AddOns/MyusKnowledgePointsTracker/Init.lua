local _, MKPT_env, _ = ...

local MKPT_Profession = MKPT_env.MKPT_Profession
local MKPT_UniqueTreasure = MKPT_env.MKPT_UniqueTreasure
local MKPT_UniqueBook = MKPT_env.MKPT_UniqueBook
local MKPT_Treatise = MKPT_env.MKPT_Treatise
local MKPT_WeeklyQuestItem = MKPT_env.MKPT_WeeklyQuestItem
local MKPT_WeeklyTreasure = MKPT_env.MKPT_WeeklyTreasure
local MKPT_DarkmoonQuest = MKPT_env.MKPT_DarkmoonQuest
local MKPT_CatchUp = MKPT_env.MKPT_CatchUp
local MKPT_PatronCatchUp = MKPT_env.MKPT_PatronCatchUp
local MKPT_Item = MKPT_env.MKPT_Item
local MKPT_QuestRequirement = MKPT_env.MKPT_QuestRequirement
local MKPT_CurrencyRequirement = MKPT_env.MKPT_CurrencyRequirement
local MKPT_RenownRequirement = MKPT_env.MKPT_RenownRequirement
local MKPT_ItemRequirement = MKPT_env.MKPT_ItemRequirement
local MKPT_FirstTimeRecipe = MKPT_env.MKPT_FirstTimeRecipe
local MKPT_KpItemRequirement = MKPT_env.MKPT_KpItemRequirement
local MKPT_Currency = MKPT_env.MKPT_Currency

local L = MKPT_env.L

local db = {}

MKPT_env.GetProfessions = function()
  local expansion = MKPT_env.charDb.state.expansion or Enum.ExpansionLevel.WarWithin

  local professions = {}
  for _, profession in pairs(db[expansion]) do
    if profession:HasSkillLine() then
      professions[profession.id] = profession
    end
  end

  return professions
end

MKPT_env.FindProfessionBySpellId = function(spellId)
  if not spellId then return nil end

  local expansion = MKPT_env.charDb.state.expansion

  if not expansion then return nil end

  local expansionDb = db[expansion]
  for _, profession in pairs(expansionDb) do
    if profession.spellId == spellId then
      return profession
    end
  end
  return nil
end

MKPT_env.InitProfessions = function()
  db = {
    -- TWW
    [Enum.ExpansionLevel.WarWithin] = {
      -- Alchemy
      [2871] = MKPT_Profession:New(2871, 423321, 3057, { map = 2339, x = 0.4707, y = 0.7054 })
          -- "Earthen Iron Powder"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83840 }, itemId = 226265, waypoint = { map = 2339, x = 0.3245, y = 0.6034 }, kp = 3 })
          -- "Metal Dornogal Frame"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83841 }, itemId = 226266, waypoint = { map = 2248, x = 0.5770, y = 0.6177 }, kp = 3 })
          -- "Reinforced Beaker"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83842 }, itemId = 226267, waypoint = { map = 2214, x = 0.3803, y = 0.2415 }, kp = 3 })
          -- "Engraved Stirring Rod"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83843 }, itemId = 226268, waypoint = { map = 2214, x = 0.6081, y = 0.6174 }, kp = 3 })
          -- "Chemist's Purified Water"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83844 }, itemId = 226269, waypoint = { map = 2215, x = 0.4265, y = 0.5510 }, kp = 3 })
          -- "Sanctified Mortar and Pestle"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83845 }, itemId = 226270, waypoint = { map = 2215, x = 0.4166, y = 0.5583 }, kp = 3 })
          -- "Nerubian Mixing Salts"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83846 }, itemId = 226271, waypoint = { map = 2213, x = 0.4537, y = 0.1322 }, kp = 3 })
          -- "Dark Apothecary's Vial"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83847 }, itemId = 226272, waypoint = { map = 2255, x = 0.4288, y = 0.5724 }, kp = 3 })
          -- Lyrendal. 200 - Faded Alchemist's Research
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81146 }, itemId = 227409, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459885 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal. 300 - Exceptional Alchemist's Research
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81147 }, itemId = 227420, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459886 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal. 400 - Pristine Alchemist's Research
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81148 }, itemId = 227431, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459887 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Council of Dornogal Rank 12, 1625 Resonance Crystals, 2815 - Jewel-Etched Alchemy Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83058 }, itemId = 224645, waypoint = { map = 2339, x = 0.3908, y = 0.2414 }, kp = 10, spell = 453440 })
            :AddRequirement(MKPT_RenownRequirement:New(2590, 12)))
          -- Undermine Treatise on Blacksmithing
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85734 }, itemId = 232499, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470728 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Alchemy Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87255 }, itemId = 235865, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218653 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Theories of Bodily Transmutation, Chapter 8, 565 kej (3056) - Theories of Bodily Transmutation, Chapter 8
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82633 }, itemId = 224024, waypoint = { map = 2213, x = 0.5560, y = 0.4700 }, kp = 10, spell = 450818 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Alchemy (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83725 }, itemId = 222546, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457715, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Alchemist's Notebook
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84133 }, itemId = 228773, waypoint = { map = 2339, x = 0.5916, y = 0.5527 }, kp = 2, text = L["Quest: Alchemy Services Requested"] })
          -- Alchemical Sediment +2, Treasure Hunt
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83253 }, itemId = 225234, kp = 2 })
          -- Deepstone Crucible + 2, Treasure Hunt
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83255 }, itemId = 225235, kp = 2 })
          -- DMF A Fizzy Fusion
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29506 }, waypoint = { map = 407, x = 0.5049, y = 0.6955 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(1645, 5)))
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228724, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83253)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83255)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84133)))
          )
      ,
      -- Blacksmithing
      [2872] = MKPT_Profession:New(2872, 423332, 3058, { map = 2339, x = 0.4917, y = 0.6363 })
          -- "Ancient Earthen Anvil"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83848 }, itemId = 226276, waypoint = { map = 2248, x = 0.59827, y = 0.6191 }, kp = 3 })
          -- "Dornogal Hammer"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83849 }, itemId = 226277, waypoint = { map = 2339, x = 0.4757, y = 0.2623 }, kp = 3 })
          -- "Ringing Hammer Vise"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83850 }, itemId = 226278, waypoint = { map = 2214, x = 0.4355, y = 0.3316 }, kp = 3 })
          -- "Earthen Chisels"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83851 }, itemId = 226279, waypoint = { map = 2214, x = 0.5637, y = 0.5367 }, kp = 3 })
          -- "Holy Flame Forge"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83852 }, itemId = 226280, waypoint = { map = 2215, x = 0.4758, y = 0.6106 }, kp = 3 })
          -- "Radiant Tongs"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83853 }, itemId = 226281, waypoint = { map = 2215, x = 0.4406, y = 0.5558 }, kp = 3 })
          -- "Nerubian Smith's Kit"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83854 }, itemId = 226282, waypoint = { map = 2213, x = 0.4651, y = 0.2292 }, kp = 3 })
          -- "Spiderling's Wire Brush"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83855 }, itemId = 226283, waypoint = { map = 2255, x = 0.5295, y = 0.5125 }, kp = 3 })
          -- Faded Blacksmith's Diagrams 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84226 }, itemId = 227407, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459888 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84227 }, itemId = 227418, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459889 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84228 }, itemId = 227429, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459890 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Jewel-Etched Blacksmithing Notes, Renown 12 Council of Dornogal
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83059 }, itemId = 224647, waypoint = { map = 2339, x = 0.3920, y = 0.2420 }, kp = 10, spell = 453443 })
            :AddRequirement(MKPT_RenownRequirement:New(2590, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Blacksmithing
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85735 }, itemId = 232500, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470729 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Blacksmithing Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87266 }, itemId = 235864, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218652 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Smithing After Saronite
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82631 }, itemId = 224038, waypoint = { map = 2213, x = 0.4680, y = 0.2220 }, kp = 10, spell = 450819 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Blacksmithing (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83726 }, itemId = 222554, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457717, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Blacksmith's Journal
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84127 }, itemId = 228774, waypoint = { map = 2339, x = 0.5916, y = 0.5527 }, kp = 2, text = L["Quest: Blacksmithing Services Requested"] })
          -- Dense Bladestone
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83256 }, itemId = 225233, kp = 1 })
          -- Coreway Billet
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83257 }, itemId = 225232, kp = 1 })
          -- DMF Baby Needs Two Pair of Shoes
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29508 }, waypoint = { map = 407, x = 0.5110, y = 0.8204 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228726, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83256)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83257)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84127)))
          )
      ,
      -- Enchanting
      [2874] = MKPT_Profession:New(2874, 423334, 3059, { map = 2339, x = 0.5291, y = 0.7131 })
          -- "Grinded Earthen Gem"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83856 }, itemId = 226284, waypoint = { map = 2248, x = 0.5759, y = 0.6164 }, kp = 3 })
          -- "Silver Dornogal Rod"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83859 }, itemId = 226285, waypoint = { map = 2339, x = 0.5803, y = 0.5695 }, kp = 3 })
          -- "Soot-Coated Orb"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83860 }, itemId = 226286, waypoint = { map = 2214, x = 0.4046, y = 0.22132 }, kp = 3 })
          -- "Animated Enchanting Dust"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83861 }, itemId = 226287, waypoint = { map = 2214, x = 0.6304, y = 0.6589 }, kp = 3 })
          -- "Essence of Holy Fire"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83862 }, itemId = 226288, waypoint = { map = 2215, x = 0.4006, y = 0.7055 }, kp = 3 })
          -- "Enchanted Arathi Scroll"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83863 }, itemId = 226289, waypoint = { map = 2215, x = 0.4859, y = 0.6450 }, kp = 3 })
          -- "Book of Dark Magic"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83864 }, itemId = 226290, waypoint = { map = 2213, x = 0.6172, y = 0.2200 }, kp = 3 })
          -- "Void Shard"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83865 }, itemId = 226291, waypoint = { map = 2255, x = 0.5736, y = 0.4404 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81076 }, itemId = 227411, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459891 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81077 }, itemId = 227422, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459892 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81078 }, itemId = 227433, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459893 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Jewel-Etched Enchanting Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83060 }, itemId = 224652, waypoint = { map = 2339, x = 0.3920, y = 0.2420 }, kp = 10, spell = 453444 })
            :AddRequirement(MKPT_RenownRequirement:New(2590, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Enchanting
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85736 }, itemId = 232501, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470730 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Enchanting Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87265 }, itemId = 235863, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218651 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Web Sparkles: Pretty and Powerful
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82635 }, itemId = 224050, waypoint = { map = 2213, x = 0.4580, y = 0.3320 }, kp = 10, spell = 450821 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Enchanting (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83727 }, itemId = 222550, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457718, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Enchanter's Folio
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84084, 84085, 84086 }, itemId = 227667, waypoint = { map = 2339, x = 0.5292, y = 0.7132 }, kp = 3, text = L["Enchanting trainer quest"], unique = true })
          -- "Fleeting Arcane Manifestation"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 84290, 84291, 84292, 84293, 84294 }, itemId = 227659, kp = 1, atlasIcon = "lootroll-toast-icon-disenchant-up", text = L["Randomly looted while disenchanting"] })
          -- "Gleaming Telluric Crystal"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 84295 }, itemId = 227661, kp = 4, atlasIcon = "lootroll-toast-icon-disenchant-up", text = L["Looted from disenchanting, after looting\n5 Fleeting Arcane Manifestation"] })
          -- Powdered Fulgurance
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83258 }, itemId = 225231, kp = 1 })
          -- Crystalline Repository
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83259 }, itemId = 225230, kp = 1 })
          -- DMF Putting Trash to Good Use
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29510 }, waypoint = { map = 407, x = 0.5316, y = 0.7587 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 227662, catchUpCurrencyId = 3059, atlasIcon =
            "lootroll-toast-icon-disenchant-up", kp = 1, text = L["Randomly looted while disenchanting"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84084)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84295)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84290)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83258)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83259)))
          )
      ,
      -- Engineering
      [2875] = MKPT_Profession:New(2875, 423335, 3060, { map = 2339, x = 0.4923, y = 0.5594 })
          -- "Rock Engineer's Wrench"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83866 }, itemId = 226292, waypoint = { map = 2248, x = 0.6136, y = 0.6957 }, kp = 3 })
          -- "Dornogal Spectacles"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83867 }, itemId = 226293, waypoint = { map = 2339, x = 0.6466, y = 0.5258 }, kp = 3 })
          -- "Inert Mining Bomb"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83868 }, itemId = 226294, waypoint = { map = 2214, x = 0.3852, y = 0.2729 }, kp = 3 })
          -- "Earthen Construct Blueprints"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83869 }, itemId = 226295, waypoint = { map = 2214, x = 0.6044, y = 0.5873 }, kp = 3 })
          -- "Holy Firework Dud"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83870 }, itemId = 226296, waypoint = { map = 2215, x = 0.4632, y = 0.6136 }, kp = 3 })
          -- "Arathi Safety Gloves"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83871 }, itemId = 226297, waypoint = { map = 2215, x = 0.4161, y = 0.4889 }, kp = 3 })
          -- "Puppeted Mechanical Spider"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83872 }, itemId = 226298, waypoint = { map = 2255, x = 0.5690, y = 0.3864 }, kp = 3 })
          -- "Emptied Venom Canister"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83873 }, itemId = 226299, waypoint = { map = 2213, x = 0.6317, y = 0.1133 }, kp = 3 })
          -- Lyrendal. 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84229 }, itemId = 227412, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459894 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84230 }, itemId = 227423, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459895 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84231 }, itemId = 227434, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459896 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Machine-Learned Engineering Notes, Renown 12 The Assembly of the Deeps
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83063 }, itemId = 224653, waypoint = { map = 2214, x = 0.4315, y = 0.3293 }, kp = 10, spell = 453450 })
            :AddRequirement(MKPT_RenownRequirement:New(2594, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Engineering
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85737 }, itemId = 232507, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470731 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Engineering Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87264 }, itemId = 235862, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218650 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Clocks, Gears, Sprockets, and Legs, 565 kej
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82632 }, itemId = 224052, waypoint = { map = 2213, x = 0.5787, y = 0.3205 }, kp = 10, spell = 450824 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Engineering (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83728 }, itemId = 222621, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457721, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Engineer's Notepad
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84128 }, itemId = 228775, waypoint = { map = 2339, x = 0.5916, y = 0.5527 }, kp = 1, text = L["Quest: Engineering Services Requested"] })
          -- Rust-Locked Mechanism
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83260 }, itemId = 225228, kp = 1 })
          -- Earthen Induction Coil
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83261 }, itemId = 225229, kp = 1 })
          -- DMF Talkin' Tonks
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29511 }, waypoint = { map = 407, x = 0.4925, y = 0.6078 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228730, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83260)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83261)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84128)))
          )
      ,
      -- Herbalism
      [2877] = MKPT_Profession:New(2877, 441327, 3061, { map = 2339, x = 0.4476, y = 0.6929 })
          -- "Ancient Flower"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83874 }, itemId = 226300, waypoint = { map = 2248, x = 0.5755, y = 0.6146 }, kp = 3 })
          -- "Dornogal Gardening Scythe"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83875 }, itemId = 226301, waypoint = { map = 2339, x = 0.5925, y = 0.2354 }, kp = 3 })
          -- "Earthen Digging Fork"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83876 }, itemId = 226302, waypoint = { map = 2214, x = 0.4409, y = 0.3504 }, kp = 3 })
          -- "Fungarian Slicer's Knife"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83877 }, itemId = 226303, waypoint = { map = 2214, x = 0.4876, y = 0.6581 }, kp = 3 })
          -- "Arathi Garden Trowel"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83878 }, itemId = 226304, waypoint = { map = 2215, x = 0.4778, y = 0.6331 }, kp = 3 })
          -- "Arathi Herb Pruner"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83879 }, itemId = 226305, waypoint = { map = 2215, x = 0.3597, y = 0.5501 }, kp = 3 })
          -- "Web-Entangled Lotus"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83880 }, itemId = 226306, waypoint = { map = 2213, x = 0.5459, y = 0.2089 }, kp = 3 })
          -- "Tunneler's Shovel"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83881 }, itemId = 226307, waypoint = { map = 2213, x = 0.4677, y = 0.1613 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81422 }, itemId = 227415, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459897 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81423 }, itemId = 227426, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459898 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81424 }, itemId = 227437, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459899 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Void-Lit Herbalism Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83066 }, itemId = 224656, waypoint = { map = 2215, x = 0.4120, y = 0.5300 }, kp = 10, spell = 453454 })
            :AddRequirement(MKPT_RenownRequirement:New(2570, 14))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Herbalism
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85738 }, itemId = 232503, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470732 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Herbalism Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87263 }, itemId = 235861, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218649 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Herbal Embalming Techniques
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82630 }, itemId = 224023, waypoint = { map = 2213, x = 0.4701, y = 0.1620 }, kp = 10, spell = 450793, currency = { id = 3056, quantity = 565 } })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Herbalism (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83729 }, itemId = 222552, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457723, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- "Algari Herbalist's Notes"
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 82970, 82958, 82965, 82916, 82962 }, itemId = 224817, waypoint = { map = 2339, x = 0.4476, y = 0.6929 }, kp = 3, text = L["Herbalism trainer quest."], unique = true })
          -- "Deepgrove Rose Petal"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 81416, 81417, 81418, 81419, 81420 }, itemId = 224264, kp = 1, atlasIcon = "Professions_Tracking_Herb", text = L["Randomly looted while gathering herbs"] })
          -- "Deepgrove Rose"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 81421 }, itemId = 224265, kp = 4, atlasIcon = "Professions_Tracking_Herb", text = L["Looted through herbs, after gathering 5 petals"] })
          -- DMF Herbs for Healing
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29514 }, waypoint = { map = 407, x = 0.5500, y = 0.7076 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 224835, catchUpCurrencyId = 3061, atlasIcon =
            "Professions_Tracking_Herb", kp = 1, text = L["Randomly looted while gathering herbs"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(82970)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(81416)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(81421))))
      ,
      -- Inscription
      [2878] = MKPT_Profession:New(2878, 423338, 3062, { map = 2339, x = 0.4881, y = 0.7092 })
          -- "Dornogal Scribe's Quill"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83882 }, itemId = 226308, waypoint = { map = 2339, x = 0.5725, y = 0.4690 }, kp = 3 })
          -- "Historian's Dip Pen"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83883 }, itemId = 226309, waypoint = { map = 2248, x = 0.55975, y = 0.6001 }, kp = 3 })
          -- "Runic Scroll"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83884 }, itemId = 226310, waypoint = { map = 2214, x = 0.4441, y = 0.3432 }, kp = 3 })
          -- "Blue Earthen Pigment"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83885 }, itemId = 226311, waypoint = { map = 2214, x = 0.5831, y = 0.5801 }, kp = 3 })
          -- "Informant's Fountain Pen"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83886 }, itemId = 226312, waypoint = { map = 2215, x = 0.4325, y = 0.5894 }, kp = 3 })
          -- "Calligrapher's Chiselled Marker" Get inside through the balcony door
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83887 }, itemId = 226313, waypoint = { map = 2215, x = 0.4283, y = 0.4906 }, kp = 3 })
          -- "Nerubian Texts"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83888 }, itemId = 226314, waypoint = { map = 2255, x = 0.5583, y = 0.4389 }, kp = 3 })
          -- "Venomancer's Ink Well"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83889 }, itemId = 226315, waypoint = { map = 2213, x = 0.5023, y = 0.3085 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80749 }, itemId = 227408, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459900 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80750 }, itemId = 227419, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459901 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80751 }, itemId = 227430, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459902 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Machine-Learned Inscription Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83064 }, itemId = 224654, waypoint = { map = 2214, x = 0.4315, y = 0.3293 }, kp = 10, spell = 453452 })
            :AddRequirement(MKPT_RenownRequirement:New(2594, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Inscription
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85739 }, itemId = 232508, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470733 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Inscription Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87262 }, itemId = 235860, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218648 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Eight Views on Defense against Hostile Runes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82636 }, itemId = 224053, waypoint = { map = 2213, x = 0.4228, y = 0.2616 }, kp = 10, spell = 450827 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Inscription (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83730 }, itemId = 222548, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457722, atlasIcon = "Professions-Crafting-Orders-Icon", text = L["Inscription craft/work order"] })
          -- Algari Scribe's Journal
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84129 }, itemId = 228776, waypoint = { map = 2339, x = 0.5916, y = 0.5527 }, kp = 2, text = L["Quest: Inscription Services Requested"] })
          -- Wax-Sealed Records
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83262 }, itemId = 225227, kp = 2 })
          -- Striated Inkstone
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83264 }, itemId = 225226, kp = 2 })
          -- DMF Writing the Future
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29515 }, waypoint = { map = 407, x = 0.5325, y = 0.7584 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(39354, 5)))
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228732, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83262)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83264)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84129)))
          )
      ,
      -- Jewelcrafting
      [2879] = MKPT_Profession:New(2879, 423339, 3063, { map = 2339, x = 0.4947, y = 0.7081 })
          -- "Gentle Jewel Hammer" Door at 63.05 67.20
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83890 }, itemId = 226316, waypoint = { map = 2248, x = 0.6353, y = 0.6688 }, kp = 3 })
          -- "Earthen Gem Pliers"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83891 }, itemId = 226317, waypoint = { map = 2339, x = 0.3484, y = 0.5217 }, kp = 3 })
          -- "Carved Stone File" Door at 48.12 34.69
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83892 }, itemId = 226318, waypoint = { map = 2214, x = 0.4433, y = 0.3512 }, kp = 3 })
          -- "Jeweler's Delicate Drill" Door at 57.51 54.80
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83893 }, itemId = 226319, waypoint = { map = 2214, x = 0.5283, y = 0.5454 }, kp = 3 })
          -- "Arathi Sizing Gauges"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83894 }, itemId = 226320, waypoint = { map = 2215, x = 0.4739, y = 0.6068 }, kp = 3 })
          -- "Librarian's Magnifiers" Top Floor
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83895 }, itemId = 226321, waypoint = { map = 2215, x = 0.4469, y = 0.5097 }, kp = 3 })
          -- "Ritual Caster's Crystal"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83896 }, itemId = 226322, waypoint = { map = 2213, x = 0.4782, y = 0.1952 }, kp = 3 })
          -- "Nerubian Bench Blocks"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83897 }, itemId = 226323, waypoint = { map = 2255, x = 0.5615, y = 0.5867 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81259 }, itemId = 227413, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459903 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81260 }, itemId = 227424, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459904 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81261 }, itemId = 227435, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459905 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Void-Lit Jewelcrafting Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83065 }, itemId = 224655, waypoint = { map = 2215, x = 0.4123, y = 0.5300 }, kp = 10, spell = 453453 })
            :AddRequirement(MKPT_RenownRequirement:New(2570, 14))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Jewelcrafting
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85740 }, itemId = 232504, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470735 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Jewelcrafting Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87261 }, itemId = 235859, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218647 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Emergent Crystals of the Surface-Dwellers
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82637 }, itemId = 224054, waypoint = { map = 2213, x = 0.4779, y = 0.1871 }, kp = 10, spell = 450828 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Jewelcrafting (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83731 }, itemId = 222551, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457725, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Jewelcrafter's Notebook
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84130 }, itemId = 228777, waypoint = { map = 2339, x = 0.5971, y = 0.5627 }, kp = 2, text = L["Quest: Jewelcrafting Services Requested"] })
          -- "Diaphanous Gem Shards" Kobyss Ritual Cache
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83265 }, itemId = 225224, kp = 2 })
          -- "Deepstone Fragment" Deep-Lost Satchel
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83266 }, itemId = 225225, kp = 2 })
          -- DMF Keeping the Faire Sparkling
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29516 }, waypoint = { map = 407, x = 0.5500, y = 0.7079 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228734, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83265)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83266)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84130)))
          )
      ,
      -- Leatherworking
      [2880] = MKPT_Profession:New(2880, 423340, 3064, { map = 2339, x = 0.5431, y = 0.5844 })
          -- "Earthen Lacing Tools"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83898 }, itemId = 226324, waypoint = { map = 2339, x = 0.6826, y = 0.2334 }, kp = 3 })
          -- "Dornogal Craftsman's Flat Knife"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83899 }, itemId = 226325, waypoint = { map = 2248, x = 0.5865, y = 0.3077 }, kp = 3 })
          -- "Underground Stropping Compound" Door at 47.11 33.83
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83900 }, itemId = 226326, waypoint = { map = 2214, x = 0.4290, y = 0.3489 }, kp = 3 })
          -- "Earthen Awl"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83901 }, itemId = 226327, waypoint = { map = 2214, x = 0.6013, y = 0.6528 }, kp = 3 })
          -- "Arathi Beveler Set"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83902 }, itemId = 226328, waypoint = { map = 2215, x = 0.4750, y = 0.6513 }, kp = 3 })
          -- "Arathi Leather Burnisher"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83903 }, itemId = 226329, waypoint = { map = 2215, x = 0.4150, y = 0.5783 }, kp = 3 })
          -- "Nerubian Tanning Mallet"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83904 }, itemId = 226330, waypoint = { map = 2213, x = 0.5503, y = 0.2695 }, kp = 3 })
          -- "Curved Nerubian Skinning Knife"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83905 }, itemId = 226331, waypoint = { map = 2255, x = 0.5999, y = 0.5401 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80978 }, itemId = 227414, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459906 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80979 }, itemId = 227425, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459907 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80980 }, itemId = 227436, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459908 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Void-Lit Leatherworking Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83068 }, itemId = 224658, waypoint = { map = 2215, x = 0.4123, y = 0.5300 }, kp = 10, spell = 453456 })
            :AddRequirement(MKPT_RenownRequirement:New(2570, 14))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Leatherworking
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85741 }, itemId = 232505, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470736 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Leatherworking Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87260 }, itemId = 235858, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218646 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Uses for Leftover Husks (After You Take Them Apart)
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82626 }, itemId = 224056, waypoint = { map = 2213, x = 0.4309, y = 0.2065 }, kp = 10, spell = 450835 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Leatherworking (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83732 }, itemId = 222549, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457720, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Leatherworker's Journal
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84131 }, itemId = 228778, waypoint = { map = 2339, x = 0.5971, y = 0.5627 }, kp = 2, text = L["Quest: Leatherworking Services Requested"] })
          -- Sturdy Nerubian Carapace
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83267 }, itemId = 225223, kp = 1 })
          -- Stone-Leather Swatch
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83268 }, itemId = 225222, kp = 1 })
          -- DMF Eyes on the Prizes
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29517 }, waypoint = { map = 407, x = 0.4925, y = 0.6079 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(6529, 10))
            :AddRequirement(MKPT_ItemRequirement:New(2320, 5))
            :AddRequirement(MKPT_ItemRequirement:New(6260, 5)))
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228736, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83267)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83268)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84131)))
          )
      ,
      -- Mining
      [2881] = MKPT_Profession:New(2881, 423341, 3065, { map = 2339, x = 0.5303, y = 0.5280 })
          -- "Earthen Miner's Gavel"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83906 }, itemId = 226332, waypoint = { map = 2248, x = 0.5819, y = 0.6204 }, kp = 3 })
          -- "Dornogal Chisel"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83907 }, itemId = 226333, waypoint = { map = 2339, x = 0.3670, y = 0.7935 }, kp = 3 })
          -- "Earthen Excavator's Shovel"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83908 }, itemId = 226334, waypoint = { map = 2214, x = 0.4527, y = 0.2754 }, kp = 3 })
          -- "Regenerating Ore"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83909 }, itemId = 226335, waypoint = { map = 2214, x = 0.6211, y = 0.6623 }, kp = 3 })
          -- "Arathi Precision Drill"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83910 }, itemId = 226336, waypoint = { map = 2215, x = 0.4607, y = 0.6439 }, kp = 3 })
          -- "Devout Archaeologist's Excavator"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83911 }, itemId = 226337, waypoint = { map = 2215, x = 0.4309, y = 0.5685 }, kp = 3 })
          -- "Heavy Spider Crusher"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83912 }, itemId = 226338, waypoint = { map = 2213, x = 0.4682, y = 0.2170 }, kp = 3 })
          -- "Nerubian Mining Cart"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83913 }, itemId = 226339, waypoint = { map = 2213, x = 0.4797, y = 0.4062 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81390 }, itemId = 227416, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459909 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81391 }, itemId = 227427, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459910 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 81392 }, itemId = 227438, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459911 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Machine-Learned Mining Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83062 }, itemId = 224651, waypoint = { map = 2214, x = 0.4315, y = 0.3293 }, kp = 10, spell = 453448 })
            :AddRequirement(MKPT_RenownRequirement:New(2594, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Mining
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85742 }, itemId = 232509, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470737 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Mining Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87259 }, itemId = 235857, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218645 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- A Rocky Start
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82614 }, itemId = 224055, waypoint = { map = 2213, x = 0.4680, y = 0.2220 }, kp = 10, spell = 450836 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- "Algari Miner's Notes"
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 83104, 83105, 83103, 83106, 83102 }, itemId = 224818, waypoint = { map = 2339, x = 0.5262, y = 0.5254 }, kp = 3, text = L["Mining trainer quests"], unique = true })
          -- Algari Treatise on Mining (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83733 }, itemId = 222553, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457726, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- "Slab of Slate"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83050, 83051, 83052, 83053, 83054 }, itemId = 224583, kp = 1, atlasIcon = "Professions_Tracking_Ore", text = L["Randomly looted while mining"] })
          -- "Slab of Slate"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83049 }, itemId = 224584, kp = 3, atlasIcon = "Professions_Tracking_Ore", text = L["Looted through mining, after 5 Slabs of Slate"] })
          -- DMF Rearm, Reuse, Recycle
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29518 }, waypoint = { map = 407, x = 0.4930, y = 0.6087 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 224838, catchUpCurrencyId = 3065, atlasIcon =
            "Professions_Tracking_Ore", kp = 1, text = L["Randomly looted while mining"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83104)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83049)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83050)))
          )
      ,
      -- Skinning
      [2882] = MKPT_Profession:New(2882, 423342, 3066, { map = 2339, x = 0.5426, y = 0.5738 })
          -- "Dornogal Carving Knife" Door at 30.51 56.31
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83914 }, itemId = 226340, waypoint = { map = 2339, x = 0.2877, y = 0.5166 }, kp = 3 })
          -- "Earthen Worker's Beams"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83915 }, itemId = 226341, waypoint = { map = 2248, x = 0.6004, y = 0.2800 }, kp = 3 })
          -- "Artisan's Drawing Knife"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83916 }, itemId = 226342, waypoint = { map = 2214, x = 0.4314, y = 0.2834 }, kp = 3 })
          -- "Fungarian's Rich Tannin"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83917 }, itemId = 226343, waypoint = { map = 2214, x = 0.6156, y = 0.6190 }, kp = 3 })
          -- "Arathi Tanning Agent"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83918 }, itemId = 226344, waypoint = { map = 2215, x = 0.4936, y = 0.6216 }, kp = 3 })
          -- "Arathi Craftsman's Spokeshave"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83919 }, itemId = 226345, waypoint = { map = 2215, x = 0.4229, y = 0.5393 }, kp = 3 })
          -- "Nerubian's Slicking Iron"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83920 }, itemId = 226346, waypoint = { map = 2213, x = 0.4446, y = 0.4945 }, kp = 3 })
          -- "Carapace Shiner"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83921 }, itemId = 226347, waypoint = { map = 2255, x = 0.5654, y = 0.5524 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84232 }, itemId = 227417, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459912 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84233 }, itemId = 227428, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459913 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 84234 }, itemId = 227439, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 15, spell = 459914 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Void-Lit Skinning Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83067 }, itemId = 224657, waypoint = { map = 2215, x = 0.4120, y = 0.5300 }, kp = 10, spell = 453455 })
            :AddRequirement(MKPT_RenownRequirement:New(2570, 14))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Skinning
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85744 }, itemId = 232506, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470738 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Skinning Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87258 }, itemId = 235856, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218644 })
            :AddRequirement(MKPT_RenownRequirement:New(2648, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Uses for Leftover Husks (How to Take Them Apart)
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82596 }, itemId = 224007, waypoint = { map = 2213, x = 0.4309, y = 0.2065 }, kp = 10, spell = 450698 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- "Algari Skinner's Notes"
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 83097, 83098, 83100, 82992, 82993 }, itemId = 224807, waypoint = { map = 2339, x = 0.5429, y = 0.5738 }, kp = 3, text = L["Skinning trainer quests"], unique = true })
          -- Algari Treatise on Skinning (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83734 }, itemId = 222649, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457724, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- "Toughened Tempest Pelt"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 81459, 81460, 81461, 81462, 81463 }, itemId = 224780, kp = 1, atlasIcon = "worldquest-icon-skinning", text = L["Randomly looted while skinning"] })
          -- "Toughened Tempest Pelt"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 81464 }, itemId = 224781, kp = 2, atlasIcon = "worldquest-icon-skinning", text = L["Looted through skinning, after 5 pelts"] })
          -- DMF Tan My Hide
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29519 }, waypoint = { map = 407, x = 0.5501, y = 0.7078 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 224782, catchUpCurrencyId = 3066, atlasIcon =
            "worldquest-icon-skinning", kp = 1, text = L["Randomly looted while skinning"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83097)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(81464)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(81459)))
          )
      ,
      -- Tailoring
      [2883] = MKPT_Profession:New(2883, 423343, 3067, { map = 2339, x = 0.5468, y = 0.6371 })
          -- "Dornogal Seam Ripper"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83922 }, itemId = 226348, waypoint = { map = 2339, x = 0.6155, y = 0.1852 }, kp = 3 })
          -- "Earthen Tape Measure"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83923 }, itemId = 226349, waypoint = { map = 2248, x = 0.5621, y = 0.6101 }, kp = 3 })
          -- "Runed Earthen Pins" Door at 47.63 32.17
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83924 }, itemId = 226350, waypoint = { map = 2214, x = 0.4468, y = 0.3287 }, kp = 3 })
          -- "Earthen Stitcher's Snips" Under a tent on top of a table
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83925 }, itemId = 226351, waypoint = { map = 2214, x = 0.5998, y = 0.6033 }, kp = 3 })
          -- "Arathi Rotary Cutter"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83926 }, itemId = 226352, waypoint = { map = 2215, x = 0.4932, y = 0.6231 }, kp = 3 })
          -- "Royal Outfitter's Protractor"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83927 }, itemId = 226353, waypoint = { map = 2215, x = 0.4009, y = 0.6814 }, kp = 3 })
          -- "Nerubian Quilt"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83928 }, itemId = 226354, waypoint = { map = 2255, x = 0.5327, y = 0.5312 }, kp = 3 })
          -- "Nurubian's Pincushion"
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 83929 }, itemId = 226355, waypoint = { map = 2213, x = 0.5032, y = 0.1684 }, kp = 3 })
          -- Lyrendal, 200
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80871 }, itemId = 227410, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459915 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 200)))
          -- Lyrendal, 300
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80872 }, itemId = 227421, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459916 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 300)))
          -- Lyrendal, 400
          :AddEntry(MKPT_UniqueBook:New({ questId = { 80873 }, itemId = 227432, waypoint = { map = 2339, x = 0.5983, y = 0.5643 }, kp = 10, spell = 459917 })
            :AddRequirement(MKPT_ItemRequirement:New(210814, 400)))
          -- Jewel-Etched Tailoring Notes
          :AddEntry(MKPT_UniqueBook:New({ questId = { 83061 }, itemId = 224648, waypoint = { map = 2339, x = 0.3983, y = 0.2420 }, kp = 10, spell = 453447 })
            :AddRequirement(MKPT_RenownRequirement:New(2590, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Undermine Treatise on Tailoring
          :AddEntry(MKPT_UniqueBook:New({ questId = { 85745 }, itemId = 232502, waypoint = { map = 2346, x = 0.4386, y = 0.5082 }, kp = 10, spell = 470739 })
            :AddRequirement(MKPT_RenownRequirement:New(2653, 16))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- Ethereal Tome of Tailoring Knowledge
          :AddEntry(MKPT_UniqueBook:New({ questId = { 87257 }, itemId = 235855, waypoint = { map = 2472, x = 0.4060, y = 0.2920 }, kp = 10, spell = 1218643 })
            :AddRequirement(MKPT_RenownRequirement:New(2658, 12))
            :AddRequirement(MKPT_ItemRequirement:New(210814, 50)))
          -- And That's A Web-Wrap!
          :AddEntry(MKPT_UniqueBook:New({ questId = { 82634 }, itemId = 224036, waypoint = { map = 2213, x = 0.5063, y = 0.1680 }, kp = 10, spell = 450840 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3056, 565)))
          -- Algari Treatise on Tailoring (Requires skill 25)
          :AddEntry(MKPT_Treatise:New { questId = { 83735 }, itemId = 222547, waypoint = { map = 2339, x = 0.5804, y = 0.5645 }, kp = 1, spell = 457719, atlasIcon = "Professions-Crafting-Orders-Icon" })
          -- Algari Tailor's Notebook
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 84132 }, itemId = 228779, waypoint = { map = 2339, x = 0.5971, y = 0.5627 }, kp = 2, text = L["Quest: Tailoring Services Requested"] })
          -- "Spool of Webweave"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83269 }, itemId = 225221, kp = 1 })
          -- "Machine Speaker's"
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 83270 }, itemId = 225220, kp = 1 })
          -- Banners, Banners Everywhere!
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29520 }, waypoint = { map = 407, x = 0.5555, y = 0.5500 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(2320, 1))
            :AddRequirement(MKPT_ItemRequirement:New(2604, 1))
            :AddRequirement(MKPT_ItemRequirement:New(6260, 1)))
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228738, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83269)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(83270)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(84132)))
          )
    }
    ,
    [Enum.ExpansionLevel.Midnight] = {
      -- Midnight
      -- 3211 Midnight Alchemy
      [2906] = MKPT_Profession:New(2906, 471003, 3189, { map = 2393, x = 0.4704, y = 0.5197 })
          --Freshly Plucked Peacebloom
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89115 }, itemId = 238536, waypoint = { map = 2393, x = 0.4911, y = 0.7585 }, kp = 3, vignetteId = { 6844 } })
          --Pristine Potion
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89117 }, itemId = 238538, waypoint = { map = 2393, x = 0.4775, y = 0.5169 }, kp = 3, vignetteId = { 6842 } })
          --Vial of Eversong Oddities
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89111 }, itemId = 238532, waypoint = { map = 2393, x = 0.4507, y = 0.4476 }, kp = 3, vignetteId = { 6848 } })
          --Vial of Zul'Aman Oddities
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89114 }, itemId = 238535, waypoint = { map = 2437, x = 0.4040, y = 0.5118 }, kp = 3, vignetteId = { 6845 } })
          --Measured Ladle
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89116 }, itemId = 238537, waypoint = { map = 2536, x = 0.4910, y = 0.2314 }, kp = 3, vignetteId = { 6843 } })
          --Vial of Rootlands Oddities
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89113 }, itemId = 238534, waypoint = { map = 2413, x = 0.3477, y = 0.2469 }, kp = 3, vignetteId = { 6846 } })
          --Failed Experiment
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89118 }, itemId = 238539, waypoint = { map = 2405, x = 0.3279, y = 0.4330 }, kp = 3, vignetteId = { 6841 } })
          --Vial of Voidstorm Oddities
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89112 }, itemId = 238533, waypoint = { map = 2444, x = 0.4198, y = 0.4061 }, kp = 3, vignetteId = { 6847 } })
          --Beyond the Event Horizon: Alchemy
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93794 }, itemId = 262645, waypoint = { map = 2405, x = 0.5258, y = 0.7290 }, kp = 10, spell = 1269210 })
            :AddRequirement(MKPT_RenownRequirement:New(2699, 9))
            :AddRequirement(MKPT_CurrencyRequirement:New(3256, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          --Thalassian Treatise on Alchemy
          :AddEntry(MKPT_Treatise:New({ questId = { 95127 }, itemId = 245755, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282284 })
            :AddRequirement(MKPT_ItemRequirement:New(245755, 1)))
          -- Thalassian Alchemist's Notebook
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93690 }, itemId = 263454, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 1, text = L["Quest: Alchemy Services Requested"] })
          --Lightbloomed Spore Sample
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93528 }, itemId = 259188, kp = 1 })
          --Aged Cruor
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93529 }, itemId = 259189, kp = 1 })
          -- DMF A Fizzy Fusion
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29506 }, waypoint = { map = 407, x = 0.5049, y = 0.6955 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(1645, 5)))
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 228724, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93528)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93529)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93690)))
          )
      ,
      -- 3210       Midnight Blacksmithing
      [2907] = MKPT_Profession:New(2907, 471004, 3199, { map = 2393, x = 0.4365, y = 0.5177 })
          -- Deconstructed Forge Techniques
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89177 }, itemId = 238540, waypoint = { map = 2393, x = 0.2697, y = 0.6029 }, kp = 3, vignetteId = { 6840 } })
          -- Metalworking Cheat Sheet
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89180 }, itemId = 238543, waypoint = { map = 2395, x = 0.5683, y = 0.4077 }, kp = 3, vignetteId = { 6837 } })
          -- Sin'dorei Master's Forgemace
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89183 }, itemId = 238546, waypoint = { map = 2393, x = 0.4916, y = 0.6135 }, kp = 3, vignetteId = { 6834 } })
          -- Silvermoon Blacksmith's Hammer
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89184 }, itemId = 238547, waypoint = { map = 2393, x = 0.4853, y = 0.7438 }, kp = 3, vignetteId = { 6833 } })
          -- Silvermoon Smithing Kit
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89178 }, itemId = 238541, waypoint = { map = 2395, x = 0.4837, y = 0.7583 }, kp = 3, vignetteId = { 6839 } })
          -- Carefully Racked Spear
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89179 }, itemId = 238542, waypoint = { map = 2536, x = 0.3312, y = 0.6579 }, kp = 3, vignetteId = { 6838 } })
          -- Rutaani Floratender's Sword
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89182 }, itemId = 238545, waypoint = { map = 2413, x = 0.6634, y = 0.5084 }, kp = 3, vignetteId = { 6835 } })
          -- Voidstorm Defense Spear
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89181 }, itemId = 238544, waypoint = { map = 2444, x = 0.3051, y = 0.6900 }, kp = 3, vignetteId = { 6836 } })
          -- Beyond the Event Horizon: Blacksmithing
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93795 }, itemId = 262644, waypoint = { map = 2405, x = 0.5258, y = 0.7290 }, kp = 10, spell = 1269211 })
            :AddRequirement(MKPT_RenownRequirement:New(2699, 9))
            :AddRequirement(MKPT_CurrencyRequirement:New(3257, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Thalassian Treatise on Blacksmithing
          :AddEntry(MKPT_Treatise:New({ questId = { 95128 }, itemId = 245763, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282300, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245763, 1)))
          -- Thalassian Blacksmith's Journal
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93691 }, itemId = 263455, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 2, text = L["Quest: Blacksmithing Services Requested"] })
          -- Thalassian Whestone
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93530 }, itemId = 259190, kp = 2 })
          -- Infused Quenching Oil
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93531 }, itemId = 259191, kp = 2 })
          -- DMF Baby Needs Two Pair of Shoes
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29508 }, waypoint = { map = 407, x = 0.5110, y = 0.8204 }, kp = 3 })
          -- Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 246322, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93691)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93530)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93531)))
          )
      ,
      -- 3209       Midnight Enchanting
      [2909] = MKPT_Profession:New(2909, 471006, 3198, { map = 2393, x = 0.4800, y = 0.5385 })
          -- Everblazing Sunmote
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89103 }, itemId = 238551, waypoint = { map = 2395, x = 0.6075, y = 0.5301 }, kp = 3, vignetteId = { 6829 } })
          -- Sin'dorei Enchanting Rod
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89107 }, itemId = 238555, waypoint = { map = 2395, x = 0.6349, y = 0.3259 }, kp = 3, vignetteId = { 6825 } })
          -- Enchanted Sunfire Silk
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89101 }, itemId = 238549, waypoint = { map = 2395, x = 0.4019, y = 0.6121 }, kp = 3, vignetteId = { 6831 } })
          -- Loa-Blessed Dust
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89106 }, itemId = 238554, waypoint = { map = 2437, x = 0.4041, y = 0.5118 }, kp = 3, vignetteId = { 6826 } })
          -- Enchanted Amani Mask
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89100 }, itemId = 238548, waypoint = { map = 2536, x = 0.4877, y = 0.2255 }, kp = 3, vignetteId = { 6832 } })
          -- Entropic Shard
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89104 }, itemId = 238552, waypoint = { map = 2413, x = 0.3775, y = 0.6523 }, kp = 3, vignetteId = { 6828 } })
          -- Primal Essence Orb
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89105 }, itemId = 238553, waypoint = { map = 2413, x = 0.6572, y = 0.5022 }, kp = 3, vignetteId = { 6827 } })
          -- Pure Void Crystal
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89102 }, itemId = 238550, waypoint = { map = 2405, x = 0.3546, y = 0.5882 }, kp = 3, vignetteId = { 6830 } })
          -- Skill Issue: Enchanting
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92374 }, itemId = 257600, waypoint = { map = 2395, x = 0.434, y = 0.474 }, kp = 10, spell = 1251675 })
            :AddRequirement(MKPT_RenownRequirement:New(2710, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3258, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Echo of Abundance: Enchanting
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92186 }, itemId = 250445, waypoint = { map = 2437, x = 0.3156, y = 0.2626 }, kp = 10, spell = 1251168 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3377, 1600))
            :AddRequirement(MKPT_CurrencyRequirement:New(3258, 75)))
          -- Thalassian Treatise on Enchanting
          :AddEntry(MKPT_Treatise:New({ questId = { 95129 }, itemId = 245759, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282301, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245759, 1)))
          -- Thalassian Enchanter's Folio
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93699, 93698, 93697 }, itemId = 263464, waypoint = { map = 2393, x = 0.478, y = 0.538 }, kp = 3, text = L["Enchanting trainer quests"] })
          -- Swirling Arcane Essence
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 95048, 95049, 95050, 95051, 95052 }, itemId = 267654, atlasIcon = "lootroll-toast-icon-disenchant-up", kp = 1, text = L["Looted from disenchanting"] })
          -- Brimming Mana Shard
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 95053 }, itemId = 267655, atlasIcon = "lootroll-toast-icon-disenchant-up", kp = 4, text = L["Looted from disenchanting, after looting\n5 Swirling Arcane Essence"] })
          -- Voidstorm Ashes
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93532 }, itemId = 259192, kp = 2 })
          -- Lost Thalassian Vellum
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93533 }, itemId = 259193, kp = 2 })
          -- DMF Putting Trash to Good Use
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29510 }, waypoint = { map = 407, x = 0.5316, y = 0.7587 }, kp = 3 })
          -- Shimmering Dust Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 267653, catchUpCurrencyId = 3059, atlasIcon =
            "lootroll-toast-icon-disenchant-up", text = L["Looted from disenchanting"], kp = 1 })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93532)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93533)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(95048)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(95053)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93699)))
          )
      ,
      -- 3208       Midnight Engineering
      [2910] = MKPT_Profession:New(2910, 471007, 3197, { map = 2393, x = 0.4352, y = 0.5410 })
          -- One Engineer's Junk
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89133 }, itemId = 238556, waypoint = { map = 2393, x = 0.5132, y = 0.7445 }, kp = 3, vignetteId = { 6824 } })
          -- What To Do When Nothing Works
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89139 }, itemId = 238562, waypoint = { map = 2393, x = 0.5120, y = 0.5726 }, kp = 3, vignetteId = { 6818 } })
          -- Manual of Mistakes and Mishaps
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89135 }, itemId = 238558, waypoint = { map = 2395, x = 0.3957, y = 0.4580 }, kp = 3, vignetteId = { 6822 } })
          -- Handy Wrench
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89140 }, itemId = 238563, waypoint = { map = 2437, x = 0.3420, y = 0.8780 }, kp = 3, vignetteId = { 6817 } })
          -- Offline Helper Bot
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89138 }, itemId = 238561, waypoint = { map = 2536, x = 0.6514, y = 0.3475 }, kp = 3, vignetteId = { 6819 } })
          -- Expeditious Pylon
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89136 }, itemId = 238559, waypoint = { map = 2413, x = 0.6799, y = 0.4980 }, kp = 3, vignetteId = { 6821 } })
          -- Ethereal Stormwrench
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89137 }, itemId = 238560, waypoint = { map = 2444, x = 0.5413, y = 0.5100 }, kp = 3, vignetteId = { 6820 } })
          -- Miniaturized Transport Skiff
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89134 }, itemId = 238557, waypoint = { map = 2444, x = 0.2893, y = 0.3899 }, kp = 3, vignetteId = { 6823 } })
          -- Beyond the Event Horizon: Engineering
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93796 }, itemId = 262646, waypoint = { map = 2405, x = 0.5258, y = 0.7290 }, kp = 10, spell = 1269212 })
            :AddRequirement(MKPT_RenownRequirement:New(2699, 9))
            :AddRequirement(MKPT_CurrencyRequirement:New(3259, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Thalassian Treatise on Engineering
          :AddEntry(MKPT_Treatise:New({ questId = { 95138 }, itemId = 245809, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282302, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245809, 1)))
          -- Thalassian Engineer's Notepad
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93692 }, itemId = 263456, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 1, text = L["Quest: Engineering Services Requested"] })
          -- Dance Gear
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93534 }, itemId = 259194, kp = 1 })
          -- Dawn Capacitor
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93535 }, itemId = 259195, kp = 1 })
          -- DMF Talkin' Tonks
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29511 }, waypoint = { map = 407, x = 0.4925, y = 0.6078 }, kp = 3 })
          -- Flicker of Midnight Engineering Knowledge Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 246326, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93692)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93534)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93535)))
          )
      ,
      -- 3207       Midnight Herbalism
      [2912] = MKPT_Profession:New(2912, 471009, 3196, { map = 2393, x = 0.4830, y = 0.5142 })
          -- Simple Leaf Pruners
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89160 }, itemId = 238470, waypoint = { map = 2393, x = 0.4901, y = 0.7595 }, kp = 3, vignetteId = { 6851 } })
          -- A Spade
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89158 }, itemId = 238472, waypoint = { map = 2395, x = 0.6426, y = 0.3046 }, kp = 3, vignetteId = { 6853 } })
          -- Sweeping Harvester's Scythe
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89161 }, itemId = 238469, waypoint = { map = 2437, x = 0.4191, y = 0.4591 }, kp = 3, vignetteId = { 6850 } })
          -- Harvester's Sickle
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89157 }, itemId = 238473, waypoint = { map = 2413, x = 0.7612, y = 0.5104 }, kp = 3, vignetteId = { 6854 } })
          -- Bloomed Bud
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89162 }, itemId = 238468, waypoint = { map = 2413, x = 0.3832, y = 0.6704 }, kp = 3, vignetteId = { 6849 } })
          -- Lightbloom Root
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89159 }, itemId = 238471, waypoint = { map = 2413, x = 0.3666, y = 0.2506 }, kp = 3, vignetteId = { 6852 } })
          -- Planting Shovel
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89155 }, itemId = 238475, waypoint = { map = 2413, x = 0.5111, y = 0.5571 }, kp = 3, vignetteId = { 6856 } })
          -- Peculiar Lotus
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89156 }, itemId = 238474, waypoint = { map = 2405, x = 0.3468, y = 0.5696 }, kp = 3, vignetteId = { 6855 } })
          -- Herbalism Journal
          :AddEntry(
            MKPT_FirstTimeRecipe:New({ spellId = 193290, atlasIcon = "Professions_Tracking_Herb" })
            :AddRecipe(87747, nil, 1223138) -- Argentleaf
            :AddRecipe(87741, nil, 1223137) -- Azeroot
            :AddRecipe(87749, nil, 1224882) -- Lightfused Argentleaf
            :AddRecipe(87743, nil, 1224885) -- Lightfused Azeroot
            :AddRecipe(87755, nil, 1224884) -- Lightfused Mana Lily g
            :AddRecipe(87737, nil, 1224886) -- Lightfused Sanguithorn
            :AddRecipe(87731, nil, 1224883) -- Lightfused Tranquility Bloom
            :AddRecipe(87748, nil, 1223146) -- Lush Argentleaf
            :AddRecipe(87742, nil, 1223150) -- Lush Azeroot
            :AddRecipe(87754, nil, 1223149) -- Lush Mana Lily
            :AddRecipe(87736, nil, 1223151) -- Lush Sanguithorn
            :AddRecipe(87730, nil, 1223148) -- Lush Tranquility Bloom g <- não dá kp no beta
            :AddRecipe(87753, nil, 1223139) -- Mana Lily
            :AddRecipe(87751, nil, 1224887) -- Primal Argentleaf
            :AddRecipe(87745, nil, 1224890) -- Primal Azeroot
            :AddRecipe(87757, nil, 1224889) -- Primal Mana Lily
            :AddRecipe(87739, nil, 1224891) -- Primal Sanguithorn
            :AddRecipe(87733, nil, 1224888) -- Primal Tranquility Bloom
            :AddRecipe(87735, nil, 1223135) -- Sanguithorn
            :AddRecipe(87729, nil, 1223099) -- Tranquility Bloom
            :AddRecipe(87752, nil, 1224897) -- Voidbound Argentleaf
            :AddRecipe(87746, nil, 1224900) -- Voidbound Azeroot
            :AddRecipe(87758, nil, 1224899) -- Voidbound Mana Lily g
            :AddRecipe(87740, nil, 1224901) -- Voidbound Sanguithorn
            :AddRecipe(87734, nil, 1224898) -- Voidbound Tranquility Bloom
            :AddRecipe(87750, nil, 1224892) -- Wild Argentleaf g
            :AddRecipe(87744, nil, 1224895) -- Wild Azeroot
            :AddRecipe(87756, nil, 1224894) -- Wild Mana Lily
            :AddRecipe(87738, nil, 1224896) -- Wild Sanguithorn
            :AddRecipe(87732, nil, 1224893) -- Wild Tranquility Bloom
          )
          -- Traditions of the Haranir: Herbalism
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93411 }, itemId = 258410, waypoint = { map = 2413, x = 0.510, y = 0.508 }, kp = 10, spell = 1263262 })
            :AddRequirement(MKPT_RenownRequirement:New(2704, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3260, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Echo of Abundance: Herbalism
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92174 }, itemId = 250443, waypoint = { map = 2437, x = 0.3156, y = 0.2626 }, kp = 10, spell = 1251165 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3377, 1600))
            :AddRequirement(MKPT_CurrencyRequirement:New(3260, 75)))
          -- Thalassian Treatise on Herbalism
          :AddEntry(MKPT_Treatise:New({ questId = { 95130 }, itemId = 245761, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282303, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245761, 1)))
          -- Thalassian Herbalist's Notes
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93700, 93701, 93702, 93703, 93704 }, itemId = 263462, waypoint = { map = 2393, x = 0.483, y = 0.5142 }, kp = 3, text = L["Herbalism trainer quests"] })
          -- Thalassian Phoenix Plume
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 81425, 81426, 81427, 81428, 81429 }, itemId = 238465, kp = 1, atlasIcon = "Professions_Tracking_Herb", text = L["Randomly looted while gathering herbs"] })
          -- Thalassian Phoenix Tail
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 81430 }, itemId = 238466, kp = 4, atlasIcon = "Professions_Tracking_Herb", text = L["Looted through herbs, after gathering 5 plumes"] })
          -- DMF Herbs for Healing
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29514 }, waypoint = { map = 407, x = 0.5500, y = 0.7076 }, kp = 3 })
          -- Thalassian Phoenix Ember Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 238467, catchUpCurrencyId = 3198, atlasIcon =
            "Professions_Tracking_Herb", kp = 1, text = L["Randomly looted while gathering herbs"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93700)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(81425)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(81430))))
      ,
      -- 3205, 3206 Midnight Inscription
      [2913] = MKPT_Profession:New(2913, 471010, 3195, { map = 2393, x = 0.4691, y = 0.5161 })
          -- Songwriter's Pen
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89073 }, itemId = 238578, waypoint = { map = 2393, x = 0.4759, y = 0.5041 }, kp = 3, vignetteId = { 6870 } })
          -- Songwriter's Quill
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89074 }, itemId = 238579, waypoint = { map = 2395, x = 0.4035, y = 0.6124 }, kp = 3, vignetteId = { 6869 } })
          -- Spare Ink
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89069 }, itemId = 238574, waypoint = { map = 2395, x = 0.4831, y = 0.7554 }, kp = 3, vignetteId = { 6814 } })
          -- Half-Baked Techniques
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89072 }, itemId = 238577, waypoint = { map = 2395, x = 0.3930, y = 0.4543 }, kp = 3, vignetteId = { 6871 } })
          -- Leather-Bound Techniques
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89068 }, itemId = 238573, waypoint = { map = 2437, x = 0.4048, y = 0.4935 }, kp = 3, vignetteId = { 6815 } })
          -- Intrepid Explorer's Marker
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89070 }, itemId = 238575, waypoint = { map = 2413, x = 0.5243, y = 0.5261 }, kp = 3, vignetteId = { 6813 } })
          -- Leftover Sanguithorn Pigment
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89071 }, itemId = 238576, waypoint = { map = 2413, x = 0.5275, y = 0.4998 }, kp = 3, vignetteId = { 6872 } })
          -- Void-Touched Quill
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89067 }, itemId = 238572, waypoint = { map = 2444, x = 0.6069, y = 0.8426 }, kp = 3, vignetteId = { 6816 } })
          -- Traditions of the Haranir: Inscription
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93412 }, itemId = 258411, waypoint = { map = 2413, x = 0.510, y = 0.508 }, kp = 10, spell = 1263265 })
            :AddRequirement(MKPT_RenownRequirement:New(2704, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3261, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Thalassian Treatise on Inscription
          :AddEntry(MKPT_Treatise:New({ questId = { 95131 }, itemId = 245757, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282304, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245757, 1)))
          -- Thalassian Scribe's Journal
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93693 }, itemId = 263457, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 4, text = L["Quest: Inscription Services Requested"] })
          -- Brilliant Phoenix Ink
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93536 }, itemId = 259196, kp = 2 })
          -- Loa-Blessed Rune
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93537 }, itemId = 259197, kp = 2 })
          -- DMF Writing the Future
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29515 }, waypoint = { map = 407, x = 0.5325, y = 0.7584 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(39354, 5)))
          -- Flicker of Midnight Inscription Knowledge Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 246328, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93693)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93536)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93537)))
          )
      ,
      -- 3204       Midnight Jewelcrafting
      [2914] = MKPT_Profession:New(2914, 471011, 3194, { map = 2393, x = 0.4818, y = 0.5509 })
          -- Sin'dorei Masterwork Chisel
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89122 }, itemId = 238580, waypoint = { map = 2393, x = 0.5064, y = 0.5651 }, kp = 3, vignetteId = { 6868 } })
          -- Dual-Function Magnifiers
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89124 }, itemId = 238582, waypoint = { map = 2393, x = 0.2862, y = 0.4638 }, kp = 3, vignetteId = { 6866 } })
          -- Vintage Soul Gem
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89127 }, itemId = 238585, waypoint = { map = 2393, x = 0.5544, y = 0.4782 }, kp = 3, vignetteId = { 6811 } })
          -- Poorly Rounded Vial
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89125 }, itemId = 238583, waypoint = { map = 2395, x = 0.5662, y = 0.4088 }, kp = 3, vignetteId = { 6865 } })
          -- Sin'dorei Gem Faceters
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89129 }, itemId = 238587, waypoint = { map = 2395, x = 0.3964, y = 0.3882 }, kp = 3, vignetteId = { 6809 } })
          -- Speculative Voidstorm Crystal
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89123 }, itemId = 238581, waypoint = { map = 2444, x = 0.3047, y = 0.6902 }, kp = 3, vignetteId = { 6867 } })
          -- Shattered Glass
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89126 }, itemId = 238584, waypoint = { map = 2444, x = 0.6274, y = 0.5343 }, kp = 3, vignetteId = { 6812 } })
          -- Ethereal Gem Pliers
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89128 }, itemId = 238586, waypoint = { map = 2444, x = 0.5420, y = 0.5104 }, kp = 3, vignetteId = { 6810 } })
          -- Skill Issue: Jewelcrafting
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93222 }, itemId = 257599, waypoint = { map = 2395, x = 0.434, y = 0.474 }, kp = 10, spell = 1261829 })
            :AddRequirement(MKPT_RenownRequirement:New(2710, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3262, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Thalassian Treatise on Jewelcrafting
          :AddEntry(MKPT_Treatise:New({ questId = { 95133 }, itemId = 245760, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282305, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245760, 1)))
          -- Thalassian Jewelcrafter's Notebook
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93694 }, itemId = 263458, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 3, text = L["Quest: Jewelcrafting Services Requested"] })
          -- Harandar Stone Sample
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93539 }, itemId = 259199, kp = 2 })
          -- Void-Touched Eversong Diamond Fragments
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93538 }, itemId = 259198, kp = 2 })
          -- DMF Keeping the Faire Sparkling
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29516 }, waypoint = { map = 407, x = 0.5500, y = 0.7079 }, kp = 3 })
          -- Flicker of Midnight Jewelcrafting Knowledge Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 246330, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93694)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93538)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93539)))
          )
      ,
      -- 3203       Midnight Leatherworking
      [2915] = MKPT_Profession:New(2915, 471012, 3193, { map = 2393, x = 0.4314, y = 0.5576 })
          -- Artisan's Considered Order
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89096 }, itemId = 238595, waypoint = { map = 2393, x = 0.4477, y = 0.5626 }, kp = 3, vignetteId = { 6861 } })
          -- Amani Leatherworker's Tool
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89089 }, itemId = 238588, waypoint = { map = 2437, x = 0.3308, y = 0.7891 }, kp = 3, vignetteId = { 6808 } })
          -- Prestigiously Racked Hide
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89091 }, itemId = 238590, waypoint = { map = 2437, x = 0.3075, y = 0.8398 }, kp = 3, vignetteId = { 6806 } })
          -- Bundle of Tanner's Trinkets
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89092 }, itemId = 238591, waypoint = { map = 2536, x = 0.4530, y = 0.4559 }, kp = 3, vignetteId = { 6805 } })
          -- Haranir Leatherworking Mallet
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89094 }, itemId = 238593, waypoint = { map = 2413, x = 0.5169, y = 0.5131 }, kp = 3, vignetteId = { 6863 } })
          -- Haranir Leatherworking Knife
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89095 }, itemId = 238594, waypoint = { map = 2413, x = 0.3610, y = 0.2517 }, kp = 3, vignetteId = { 6862 } })
          -- Ethereal Leatherworking Knife
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89090 }, itemId = 238589, waypoint = { map = 2405, x = 0.3471, y = 0.5692 }, kp = 3, vignetteId = { 6807 } })
          -- Patterns: Beyond the Void
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89093 }, itemId = 238592, waypoint = { map = 2444, x = 0.5374, y = 0.5168 }, kp = 3, vignetteId = { 6864 } })
          -- Whisper of the Loa: Leatherworking
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92371 }, itemId = 250922, waypoint = { map = 2437, x = 0.458, y = 0.658 }, kp = 10, spell = 1251672 })
            :AddRequirement(MKPT_RenownRequirement:New(2696, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3263, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Thalassian Treatise on Leatherworking
          :AddEntry(MKPT_Treatise:New({ questId = { 95134 }, itemId = 245758, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282306, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245758, 1)))
          -- Thalassian Leatherworker's Journal
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93695 }, itemId = 263459, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 2, text = L["Quest: Leatherworking Services Requested"] })
          -- Amani Tanning Oil
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93540 }, itemId = 259200, kp = 2 })
          -- Thalassian Mana Oil
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93541 }, itemId = 259201, kp = 2 })
          -- DMF Eyes on the Prizes
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29517 }, waypoint = { map = 407, x = 0.4925, y = 0.6079 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(6529, 10))
            :AddRequirement(MKPT_ItemRequirement:New(2320, 5))
            :AddRequirement(MKPT_ItemRequirement:New(6260, 5)))
          -- Flicker of Midnight Leatherworking Knowledge Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 246332, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93695)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93540)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93541)))
          )
      ,
      -- 3202       Midnight Mining
      [2916] = MKPT_Profession:New(2916, 471013, 3192, { map = 2393, x = 0.4259, y = 0.5286 })
          -- Solid Ore Punchers
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89147 }, itemId = 238599, waypoint = { map = 2395, x = 0.3798, y = 0.4537 }, kp = 3, vignetteId = { 6857 } })
          -- Spelunker's Lucky Charm
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89145 }, itemId = 238597, waypoint = { map = 2437, x = 0.4200, y = 0.4653 }, kp = 3, vignetteId = { 6859 } })
          -- Amani Expert's Chisel
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89149 }, itemId = 238601, waypoint = { map = 2536, x = 0.3329, y = 0.6589 }, kp = 3, vignetteId = { 6803 } })
          -- Spare Expedition Torch
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89151 }, itemId = 238603, waypoint = { map = 2413, x = 0.3884, y = 0.6586 }, kp = 3, vignetteId = { 6801 } })
          -- Star Metal Deposit
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89150 }, itemId = 238602, waypoint = { map = 2444, x = 0.3427, y = 0.7609 }, kp = 3, vignetteId = { 6802 } })
          -- Miner's Guide to Voidstorm
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89144 }, itemId = 238596, waypoint = { map = 2444, x = 0.3047, y = 0.6907 }, kp = 3, vignetteId = { 6860 } })
          -- Lost Voidstorm Satchel
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89146 }, itemId = 238598, waypoint = { map = 2444, x = 0.5424, y = 0.5160 }, kp = 3, vignetteId = { 6858 } })
          -- Glimmering Void Pearl
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89148 }, itemId = 238600, waypoint = { map = 2444, x = 0.2875, y = 0.3857 }, kp = 3, vignetteId = { 6804 } })
          -- Mining Journal
          :AddEntry(
            MKPT_FirstTimeRecipe:New({ spellId = 2656, atlasIcon = "Professions_Tracking_Ore" })
            :AddRecipe(88471, 523295, 1225348) -- Brilliant Silver
            :AddRecipe(88466, 523298, 1225357) -- Brilliant Silver Seam
            :AddRecipe(88484, 523303, 1225359) -- Lightfused Brilliant Silver
            :AddRecipe(88487, 523284, 1225351) -- Lightfused Refulgent Copper
            :AddRecipe(88488, 523294, 1225367) -- Lightfused Umbral Tin
            :AddRecipe(88490, 523299, 1225361) -- Primal Brilliant Silver
            :AddRecipe(88479, 523285, 1225354) -- Primal Refulgent Copper
            :AddRecipe(88469, 523291, 1225369) -- Primal Umbral Tin
            :AddRecipe(88475, 523281, 1225343) -- Refulgent Copper
            :AddRecipe(88480, 523283, 1225350) -- Refulgent Copper Seam
            :AddRecipe(88491, 523297, 1225355) -- Rich Brilliant Silver
            :AddRecipe(88476, 523282, 1225349) -- Rich Refulgent Copper
            :AddRecipe(88478, 523289, 1225365) -- Rich Umbral Tin
            :AddRecipe(88477, 523288, 1225347) -- Umbral Tin
            :AddRecipe(88481, 523290, 1225366) -- Umbral Tin Seam
            :AddRecipe(88465, 523301, 1225362) -- Voidbound Brilliant Silver
            :AddRecipe(88463, 523287, 1225352) -- Voidbound Refulgent Copper
            :AddRecipe(88470, 523293, 1225370) -- Voidbound Umbral Tin
            :AddRecipe(88472, 523300, 1225363) -- Wild Brilliant Silver
            :AddRecipe(88486, 523286, 1225353) -- Wild Refulgent Copper
            :AddRecipe(88485, 523292, 1225368) -- Wild Umbral Tin
          )
          -- Whisper of the Loa: Mining
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92372 }, itemId = 250924, waypoint = { map = 2437, x = 0.458, y = 0.658 }, kp = 10, spell = 1251674 })
            :AddRequirement(MKPT_RenownRequirement:New(2696, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3264, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Echo of Abundance: Mining
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92187 }, itemId = 250444, waypoint = { map = 2437, x = 0.3156, y = 0.2626 }, kp = 10, spell = 1251166 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3377, 1600))
            :AddRequirement(MKPT_CurrencyRequirement:New(3264, 75)))
          -- Thalassian Treatise on Mining
          :AddEntry(MKPT_Treatise:New({ questId = { 95135 }, itemId = 245762, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282307, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245762, 1)))
          -- Thalassian Miner's Notes
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93705, 93706, 93707, 93708, 93709 }, itemId = 263463, waypoint = { map = 2393, x = 0.426, y = 0.528 }, kp = 3, text = L["Mining trainer quests"] })
          -- Igneous Rock Specimen
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 88673, 88674, 88675, 88676, 88677 }, itemId = 237496, kp = 1, atlasIcon = "Professions_Tracking_Ore", text = L["Randomly looted while mining"] })
          -- Septarian Nodule
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 88678 }, itemId = 237506, kp = 3, atlasIcon = "Professions_Tracking_Ore", text = L["Looted through mining, after 5 Igneous Rock Specimen"] })
          -- DMF Rearm, Reuse, Recycle
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29518 }, waypoint = { map = 407, x = 0.4930, y = 0.6087 }, kp = 3 })
          -- Cloudy Quartz Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 237507, catchUpCurrencyId = 3192, atlasIcon =
            "Professions_Tracking_Ore", kp = 1, text = L["Randomly looted while mining"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93705)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(88673)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(88678))))
      ,
      -- 3201       Midnight Skinning
      [2917] = MKPT_Profession:New(2917, 471014, 3191, { map = 2393, x = 0.4320, y = 0.5557 })
          -- Sin'dorei Tanning Oil
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89171 }, itemId = 238633, waypoint = { map = 2393, x = 0.4313, y = 0.5562 }, kp = 3, vignetteId = { 6787 } })
          -- Thalassian Skinning Knife
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89173 }, itemId = 238635, waypoint = { map = 2395, x = 0.4840, y = 0.7625 }, kp = 3, vignetteId = { 6785 } })
          -- Amani Tanning Oil
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89170 }, itemId = 238632, waypoint = { map = 2437, x = 0.4039, y = 0.3601 }, kp = 3, vignetteId = { 6788 } })
          -- Amani Skinning Knife
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89172 }, itemId = 238634, waypoint = { map = 2437, x = 0.3307, y = 0.7907 }, kp = 3, vignetteId = { 6786 } })
          -- Cadre Skinning Knife
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89167 }, itemId = 238629, waypoint = { map = 2536, x = 0.4491, y = 0.4519 }, kp = 3, vignetteId = { 6791 } })
          -- Lightbloom Afflicted Hide
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89166 }, itemId = 238628, waypoint = { map = 2413, x = 0.7609, y = 0.5108 }, kp = 3, vignetteId = { 6792 } })
          -- Primal Hide
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89168 }, itemId = 238630, waypoint = { map = 2413, x = 0.6952, y = 0.4917 }, kp = 3, vignetteId = { 6790 } })
          -- Voidstorm Leather Sample
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89169 }, itemId = 238631, waypoint = { map = 2444, x = 0.4550, y = 0.4240 }, kp = 3, vignetteId = { 6789 } })
          -- Whisper of the Loa: Skinning
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92373 }, itemId = 250923, waypoint = { map = 2437, x = 0.458, y = 0.658 }, kp = 10, spell = 1251673 })
            :AddRequirement(MKPT_RenownRequirement:New(2696, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3265, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Echo of Abundance: Skinning
          :AddEntry(MKPT_UniqueBook:New({ questId = { 92188 }, itemId = 250360, waypoint = { map = 2437, x = 0.3156, y = 0.2626 }, kp = 10, spell = 1250888 })
            :AddRequirement(MKPT_CurrencyRequirement:New(3377, 1600))
            :AddRequirement(MKPT_CurrencyRequirement:New(3265, 75)))
          -- Thalassian Treatise on Skinning
          :AddEntry(MKPT_Treatise:New({ questId = { 95136 }, itemId = 245828, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282308, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245828, 1)))
          -- Thalassian Skinner's Notes
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93710, 93711, 93712, 93713, 93714 }, itemId = 263461, waypoint = { map = 2393, x = 0.432, y = 0.5556 }, kp = 3, text = L["Skinning trainer quests"] })
          -- Fine Void-Tempered Hide
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 88534, 88549, 88536, 88537, 88530 }, itemId = 238625, kp = 1, atlasIcon = "worldquest-icon-skinning", text = L["Randomly looted while skinning"] })
          -- Mana-Infused Bone
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 88529 }, itemId = 238626, kp = 3, atlasIcon = "worldquest-icon-skinning", text = L["Looted through skinning, after 5 hides"] })
          -- DMF Tan My Hide
          :AddEntry(MKPT_DarkmoonQuest:New { questId = { 29519 }, waypoint = { map = 407, x = 0.5501, y = 0.7078 }, kp = 3 })
          -- Manafused Sample Catch up mechanic
          :AddEntry(MKPT_CatchUp:New({ questId = {}, itemId = 238627, catchUpCurrencyId = 3191, atlasIcon =
            "worldquest-icon-skinning", kp = 1, text = L["Randomly looted while skinning"] })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93710)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(88534)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(88529))))
      ,
      -- 3200       Midnight Tailoring
      [2918] = MKPT_Profession:New(2918, 471015, 3190, { map = 2393, x = 0.4820, y = 0.5399 })
          -- A Really Nice Curtain
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89079 }, itemId = 238613, waypoint = { map = 2393, x = 0.3575, y = 0.6124 }, kp = 3, vignetteId = { 6799 } })
          -- Particularly Enchanting Tablecloth
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89084 }, itemId = 238618, waypoint = { map = 2393, x = 0.3179, y = 0.6828 }, kp = 3, vignetteId = { 6794 } })
          -- Sin'dorei Outfitter's Ruler
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89080 }, itemId = 238614, waypoint = { map = 2395, x = 0.4635, y = 0.3486 }, kp = 3, vignetteId = { 6798 } })
          -- Artisan's Cover Comb
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89085 }, itemId = 238619, waypoint = { map = 2437, x = 0.4053, y = 0.4937 }, kp = 3, vignetteId = { 6793 } })
          -- A Child's Stuffy
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89078 }, itemId = 238612, waypoint = { map = 2413, x = 0.7057, y = 0.5090 }, kp = 3, vignetteId = { 6800 } })
          -- Wooden Weaving Sword
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89081 }, itemId = 238615, waypoint = { map = 2413, x = 0.6976, y = 0.5105 }, kp = 3, vignetteId = { 6797 } })
          -- Book of Sin'dorei Stitches
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89082 }, itemId = 238616, waypoint = { map = 2444, x = 0.6201, y = 0.8351 }, kp = 3, vignetteId = { 6796 } })
          -- Satin Throw Pillow
          :AddEntry(MKPT_UniqueTreasure:New { questId = { 89083 }, itemId = 238617, waypoint = { map = 2444, x = 0.6139, y = 0.8513 }, kp = 3, vignetteId = { 6795 } })
          -- Skill Issue: Tailoring
          :AddEntry(MKPT_UniqueBook:New({ questId = { 93201 }, itemId = 257601, waypoint = { map = 2395, x = 0.434, y = 0.474 }, kp = 10, spell = 1261784 })
            :AddRequirement(MKPT_RenownRequirement:New(2710, 6))
            :AddRequirement(MKPT_CurrencyRequirement:New(3266, 75))
            :AddRequirement(MKPT_CurrencyRequirement:New(3316, 750)))
          -- Thalassian Treatise on Tailoring
          :AddEntry(MKPT_Treatise:New({ questId = { 95137 }, itemId = 245756, waypoint = { map = 2393, x = 0.4502, y = 0.5560 }, kp = 1, spell = 1282309, atlasIcon =
            "Professions-Crafting-Orders-Icon" })
            :AddRequirement(MKPT_ItemRequirement:New(245756, 1)))
          -- Thalassian Tailor's Notebook
          :AddEntry(MKPT_WeeklyQuestItem:New { questId = { 93696 }, itemId = 263460, waypoint = { map = 2393, x = 0.4503, y = 0.5515 }, kp = 2, text = L["Quest: Tailoring Services Requested"] })
          -- Embroidered Memento
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93542 }, itemId = 259202, kp = 2 })
          -- Finely Woven Lynx Collar
          :AddEntry(MKPT_WeeklyTreasure:New { questId = { 93543 }, itemId = 259203, kp = 2 })
          -- Banners, Banners Everywhere!
          :AddEntry(MKPT_DarkmoonQuest:New({ questId = { 29520 }, waypoint = { map = 407, x = 0.5555, y = 0.5500 }, kp = 3 })
            :AddRequirement(MKPT_ItemRequirement:New(2320, 1))
            :AddRequirement(MKPT_ItemRequirement:New(2604, 1))
            :AddRequirement(MKPT_ItemRequirement:New(6260, 1)))
          -- Flicker of Midnight Tailoring Knowledge Catch up mechanic
          :AddEntry(MKPT_PatronCatchUp:New({ questId = {}, itemId = 246334, atlasIcon =
            "Professions-Crafting-Orders-Icon", kp = 1, text = PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(
            PROFESSIONS_CRAFTER_ORDER_TAB_NPC) })
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93696)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93542)))
            :AddRequirement(MKPT_KpItemRequirement:New(MKPT_Item.FindByQuestId(93543)))
          )

    }
  }
end
