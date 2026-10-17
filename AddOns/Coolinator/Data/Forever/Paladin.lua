local addonTable = select(2, ...)
local class = "PALADIN"
if UnitClassBase("player") ~= class then
    return
end
addonTable.Data.Spells[class] = {
  [1] = {
    ['spells'] = {
      [1] = 19740,
      [2] = 19834,
      [3] = 19835,
      [4] = 19836,
      [5] = 19837,
      [6] = 19838
    },
    ['name'] = 'Blessing of Might',
    ['isRanked'] = true
  },
  [2] = {
    ['spells'] = {
      [1] = 679,
      [2] = 678,
      [3] = 1866,
      [4] = 680,
      [5] = 2495,
      [6] = 5569,
      [7] = 10332,
      [8] = 10333
    },
    ['name'] = 'Holy Strike',
    ['isRanked'] = true
  },
  [3] = {
    ['spells'] = {
      [1] = 20271
    },
    ['name'] = 'Judgement',
    ['isRanked'] = false
  },
  [4] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 21082,
      [2] = 20162,
      [3] = 20305,
      [4] = 20306,
      [5] = 20307,
      [6] = 20308
    },
    ['name'] = 'Seal of the Crusader',
    ['isRanked'] = true
  },
  [5] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1022,
      [2] = 5599,
      [3] = 10278
    },
    ['name'] = 'Blessing of Protection',
    ['isRanked'] = true
  },
  [6] = {
    ['spells'] = {
      [1] = 465,
      [2] = 10290,
      [3] = 643,
      [4] = 10291,
      [5] = 1032,
      [6] = 10292,
      [7] = 10293
    },
    ['name'] = 'Devotion Aura',
    ['isRanked'] = true
  },
  [7] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 498,
      [2] = 5573
    },
    ['name'] = 'Divine Protection',
    ['isRanked'] = true
  },
  [8] = {
    ['spells'] = {
      [1] = 853,
      [2] = 5588,
      [3] = 5589,
      [4] = 10308
    },
    ['name'] = 'Hammer of Justice',
    ['isRanked'] = true
  },
  [9] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1311649,
      [2] = 1311656,
      [3] = 20163,
      [4] = 20419,
      [5] = 20421,
      [6] = 20422,
      [7] = 20423
    },
    ['name'] = 'Seal of Fury',
    ['isRanked'] = true
  },
  [10] = {
    ['spells'] = {
      [1] = 635,
      [2] = 639,
      [3] = 647,
      [4] = 1026,
      [5] = 1042,
      [6] = 3472,
      [7] = 10328,
      [8] = 10329
    },
    ['name'] = 'Holy Light',
    ['isRanked'] = true
  },
  [11] = {
    ['spells'] = {
      [1] = 633,
      [2] = 2800,
      [3] = 10310
    },
    ['name'] = 'Lay on Hands',
    ['isRanked'] = true
  },
  [12] = {
    ['spells'] = {
      [1] = 1152
    },
    ['name'] = 'Purify',
    ['isRanked'] = false
  },
  [13] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 21084,
      [2] = 20287,
      [3] = 20288,
      [4] = 20289,
      [5] = 20290,
      [6] = 20291,
      [7] = 20292,
      [8] = 20293
    },
    ['name'] = 'Seal of Righteousness',
    ['isRanked'] = true
  },
  [14] = {
    ['spells'] = {
      [1] = 5502
    },
    ['name'] = 'Sense Undead',
    ['isRanked'] = false
  },
  [15] = {
    ['spells'] = {
      [1] = 19742,
      [2] = 19850,
      [3] = 19852,
      [4] = 19853,
      [5] = 19854
    },
    ['name'] = 'Blessing of Wisdom',
    ['isRanked'] = true
  },
  [16] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 7294,
      [2] = 10298,
      [3] = 10299,
      [4] = 10300,
      [5] = 10301
    },
    ['name'] = 'Retribution Aura',
    ['isRanked'] = true
  },
  [17] = {
    ['spells'] = {
      [1] = 25780
    },
    ['name'] = 'Righteous Fury',
    ['isRanked'] = false
  },
  [18] = {
    ['spells'] = {
      [1] = 1044
    },
    ['name'] = 'Blessing of Freedom',
    ['isRanked'] = false
  },
  [19] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 20217
    },
    ['name'] = 'Blessing of Kings',
    ['isRanked'] = false
  },
  [20] = {
    ['spells'] = {
      [1] = 26573,
      [2] = 20116,
      [3] = 20922,
      [4] = 20923,
      [5] = 20924
    },
    ['name'] = 'Consecration',
    ['isRanked'] = true
  },
  [21] = {
    ['spells'] = {
      [1] = 879,
      [2] = 5614,
      [3] = 5615,
      [4] = 10312,
      [5] = 10313,
      [6] = 10314
    },
    ['name'] = 'Exorcism',
    ['isRanked'] = true
  },
  [22] = {
    ['spells'] = {
      [1] = 19750,
      [2] = 19939,
      [3] = 19940,
      [4] = 19941,
      [5] = 19942,
      [6] = 19943
    },
    ['name'] = 'Flash of Light',
    ['isRanked'] = true
  },
  [23] = {
    ['spells'] = {
      [1] = 19746
    },
    ['name'] = 'Concentration Aura',
    ['isRanked'] = false
  },
  [24] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 20164
    },
    ['name'] = 'Seal of Justice',
    ['isRanked'] = false
  },
  [25] = {
    ['spells'] = {
      [1] = 7328,
      [2] = 10322,
      [3] = 10324,
      [4] = 20772,
      [5] = 20773
    },
    ['name'] = 'Redemption',
    ['isRanked'] = true
  },
  [26] = {
    ['spells'] = {
      [1] = 2878,
      [2] = 5627,
      [3] = 10326
    },
    ['name'] = 'Turn Undead',
    ['isRanked'] = true
  },
  [27] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 1038
    },
    ['name'] = 'Salvation',
    ['isRanked'] = false
  },
  [28] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 19876,
      [2] = 19895,
      [3] = 19896
    },
    ['name'] = 'Shadow Resistance Aura',
    ['isRanked'] = true
  },
  [29] = {
    ['spells'] = {
      [1] = 19752
    },
    ['name'] = 'Divine Intervention',
    ['isRanked'] = false
  },
  [30] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 20375,
      [2] = 20915,
      [3] = 20918,
      [4] = 20919,
      [5] = 20920
    },
    ['name'] = 'Seal of Command',
    ['isRanked'] = true
  },
  [31] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 20165,
      [2] = 20347,
      [3] = 20348,
      [4] = 20349
    },
    ['name'] = 'Seal of Light',
    ['isRanked'] = true
  },
  [32] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 19888,
      [2] = 19897,
      [3] = 19898
    },
    ['name'] = 'Frost Resistance Aura',
    ['isRanked'] = true
  },
  [33] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 642,
      [2] = 1020
    },
    ['name'] = 'Divine Shield',
    ['isRanked'] = true
  },
  [34] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 19891,
      [2] = 19899,
      [3] = 19900
    },
    ['name'] = 'Fire Resistance Aura',
    ['isRanked'] = true
  },
  [35] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 20166,
      [2] = 20356,
      [3] = 20357
    },
    ['name'] = 'Seal of Wisdom',
    ['isRanked'] = true
  },
  [36] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 19977,
      [2] = 19978,
      [3] = 19979
    },
    ['name'] = 'Blessing of Light',
    ['isRanked'] = true
  },
  [37] = {
    ['spells'] = {
      [1] = 1311606,
      [2] = 20473,
      [3] = 20929,
      [4] = 20930
    },
    ['name'] = 'Holy Shock',
    ['isRanked'] = true
  },
  [38] = {
    ['spells'] = {
      [1] = 750
    },
    ['name'] = 'Plate Mail',
    ['isRanked'] = false
  },
  [39] = {
    ['spells'] = {
      [1] = 4987
    },
    ['name'] = 'Cleanse',
    ['isRanked'] = false
  },
  [40] = {
    ['spells'] = {
      [1] = 24275,
      [2] = 24274,
      [3] = 24239
    },
    ['name'] = 'Hammer of Wrath',
    ['isRanked'] = true
  },
  [41] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 6940,
      [2] = 20729
    },
    ['name'] = 'Blessing of Sacrifice',
    ['isRanked'] = true
  },
  [42] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 20925,
      [2] = 20927,
      [3] = 20928
    },
    ['name'] = 'Holy Shield',
    ['isRanked'] = true
  },
  [43] = {
    ['spells'] = {
      [1] = 2812,
      [2] = 10318
    },
    ['name'] = 'Holy Wrath',
    ['isRanked'] = true
  },
  [44] = {
    ['spells'] = {
      [1] = 1310911,
      [2] = 1311590,
      [3] = 1311595
    },
    ['name'] = 'Light\'s Vigil',
    ['isRanked'] = true
  },
  [45] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 25782,
      [2] = 25916
    },
    ['name'] = 'Greater Blessing of Might',
    ['isRanked'] = true
  },
  [46] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 25894,
      [2] = 25918
    },
    ['name'] = 'Greater Blessing of Wisdom',
    ['isRanked'] = true
  },
  [47] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 25898
    },
    ['name'] = 'Greater Blessing of Kings',
    ['isRanked'] = false
  },
  [48] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 25890
    },
    ['name'] = 'Greater Blessing of Light',
    ['isRanked'] = false
  },
  [49] = {
    ['auraTag'] = 'ABILITYANDAURA',
    ['spells'] = {
      [1] = 25895
    },
    ['name'] = 'Mass Salvation',
    ['isRanked'] = false
  },
  [50] = {
    ['spells'] = {
      [1] = 20216
    },
    ['name'] = 'Divine Favor',
    ['isRanked'] = false
  },
  [51] = {
    ['spells'] = {
      [1] = 1310897
    },
    ['name'] = 'Voice of Truth',
    ['isRanked'] = false
  },
  [52] = {
    ['spells'] = {
      [1] = 1311015
    },
    ['name'] = 'Templar\'s Bulwark',
    ['isRanked'] = false
  },
  [53] = {
    ['spells'] = {
      [1] = 20066
    },
    ['name'] = 'Repentance',
    ['isRanked'] = false
  },
  [54] = {
    ['spells'] = {
      [1] = 1310994
    },
    ['name'] = 'Swift Judgement',
    ['isRanked'] = false
  },
  [55] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 1311701
    },
    ['name'] = 'Echo of Fury',
    ['isRanked'] = false
  },
  [56] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 1311703
    },
    ['name'] = 'Echo of Command',
    ['isRanked'] = false
  },
  [57] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 1311704
    },
    ['name'] = 'Echo of Righteousness',
    ['isRanked'] = false
  },
  [58] = {
    ['auraTag'] = false,
    ['spells'] = {
      [1] = 1311705
    },
    ['name'] = 'Echo of Justice',
    ['isRanked'] = false
  },
  [59] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 440667
    },
    ['name'] = 'Vindication',
    ['isRanked'] = false
  },
  [60] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 440668
    },
    ['name'] = 'Vindication',
    ['isRanked'] = false
  },
  [61] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 20050
    },
    ['name'] = 'Vengeance',
    ['isRanked'] = false
  },
  [62] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1324538
    },
    ['name'] = 'Repentance',
    ['isRanked'] = false
  },
  [63] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 20127,
      [0] = 20128
    },
    ['name'] = 'Redoubt',
    ['isRanked'] = false
  },
  [64] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 20177,
      [0] = 20178
    },
    ['name'] = 'Reckoning',
    ['isRanked'] = false
  },
  [65] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 437063
    },
    ['name'] = 'Infusion of Light',
    ['isRanked'] = false
  },
  [66] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 1310910,
      [2] = 1311594,
      [3] = 1311599
    },
    ['name'] = 'Light\'s Vigil',
    ['isRanked'] = true
  },
  [67] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1310909,
      [2] = 1311593,
      [3] = 1311597
    },
    ['name'] = 'Light\'s Vigil',
    ['isRanked'] = true
  },
  [68] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1324513,
      [0] = 1324515
    },
    ['name'] = 'Hammer of Justice',
    ['isRanked'] = false
  },
  [69] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1324543,
      [0] = 1324545
    },
    ['name'] = 'Turn Undead',
    ['isRanked'] = false
  },
  [70] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1311703
    },
    ['name'] = 'Echo of Command',
    ['isRanked'] = false
  },
  [71] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1311704
    },
    ['name'] = 'Echo of Righteousness',
    ['isRanked'] = false
  },
  [72] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1311705
    },
    ['name'] = 'Echo of Justice',
    ['isRanked'] = false
  },
  [73] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 1311701
    },
    ['name'] = 'Echo of Fury',
    ['isRanked'] = false
  },
  [74] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 21183,
      [2] = 20188,
      [3] = 20300,
      [4] = 20301,
      [5] = 20302,
      [6] = 20303
    },
    ['name'] = 'Judgement of the Crusader',
    ['isRanked'] = true
  },
  [75] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 20184
    },
    ['name'] = 'Judgement of Justice',
    ['isRanked'] = true
  },
  [76] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 20185,
      [2] = 20344,
      [3] = 20345,
      [4] = 20346
    },
    ['name'] = 'Judgement of Light',
    ['isRanked'] = true
  },
  [77] = {
    ['auraTag'] = 'HARMAURA',
    ['spells'] = {
      [1] = 20186,
      [2] = 20354,
      [3] = 20355
    },
    ['name'] = 'Judgement of Wisdom',
    ['isRanked'] = true
  },
  [78] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 465,
      [2] = 10290,
      [3] = 643,
      [4] = 10291,
      [5] = 1032,
      [6] = 10292,
      [7] = 10293
    },
    ['name'] = 'Devotion Aura',
    ['isRanked'] = true
  },
  [79] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 19740,
      [2] = 19834,
      [3] = 19835,
      [4] = 19836,
      [5] = 19837,
      [6] = 19838,
      [7] = 25291
    },
    ['name'] = 'Blessing of Might',
    ['isRanked'] = true
  },
  [80] = {
    ['auraTag'] = 'HELPAURA',
    ['spells'] = {
      [1] = 19742,
      [2] = 19850,
      [3] = 19852,
      [4] = 19853,
      [5] = 19854,
      [6] = 25290
    },
    ['name'] = 'Blessing of Wisdom',
    ['isRanked'] = true
  }
}
